
require InstallPath + 'Calculator'

class ReportWriter

  def name
    "Comma-delimited format: flattened (.CSV)"
  end
  
  def help(verbose)
    if verbose
      ["RCSV2 - flattened comma-delimited report",
       "",
       "  This report is an Excel-compatible comma separated format. Each value",
       "  is delimited with a comma. Image measures are reported first, followed",
       "  by class measures, and then interclass measures. Units are included in",
       "  the output. The data is 'flattened'. Image measures are reported as",
       "  'name,value,units'. Class measures are reported as 'name,class,value,",
       "  units'. Interclass measures are reported as 'name,class1,class2,value,",
       "  units'."
      ]
    else
      ["RCSV2 - flattened comma-delimited report"]
    end
  end
  
  def outName
    @outfile
  end

  def run(engine,options,image,analysesOutput,args,verbose)

    if image.nil?
      engine.error("CSV2 report writer did not receive an image to process")
      return nil
    end
    
    case args.length
      when 0
        fileName = image.fileName
        extensionPos = fileName.rindex('.')
        extensionPos = nil if tmp = fileName.rindex('/') and tmp > extensionPos
        extensionPos = nil if tmp = fileName.rindex('\\') and tmp > extensionPos
        if extensionPos
          fileName = fileName[0,extensionPos]
        end
        fileName += ".csv"
      when 1
        fileName = args[0]
      when 2
        fileName = args[0]
        fileName = fileName + "\\" if fileName[fileName.length-1] != "\\"
        fileName = fileName + args[1]
      else
        engine.error("Too many arguments to CSV2 report.")
        return
    end
    
    # if no extension specified apply .csv
    fileName += ".csv" if not fileName =~ /.*\.\w+$/
    
    @outfile = fileName

    imageMeasures = false
    classMeasures = false
    interclassMeasures = false
    analysesOutput.each do | analysisOutput |
      imageMeasures = true if analysisOutput.outType == AnalysisType::IMAGE
      classMeasures = true if analysisOutput.outType == AnalysisType::CLASS
      interclassMeasures = true if analysisOutput.outType == AnalysisType::INTERCLASS
    end

    eightNeighbors = true
    setting = options.find("Neighborhood")
    eightNeighbors = false if setting and setting.value == "4"
     
    backGround = -1
    setting = options.find("Background")
    backGround = setting.dig_to_i(setting.value) if setting

    classesPresent = image.file.classesPresent
    occupiedCells = image.file.area
    if backGround != -1
      backCells = image.file.areas[backGround]
      occupiedCells -= backCells if backCells
      classesPresent -= 1 if backCells
    end
    backColorStr = (backGround == -1 ? "None" : backGround.to_s)
    nCount = (eightNeighbors ? 8:4)

    outfile = File.new(fileName,"w")
    outfile.printf("%s\n",  "IAN CSV2 REPORT")
    outfile.printf("\n")
    outfile.printf("%s,%s\n", "Image",image.fileName)
    outfile.printf("%s,%s\n", "Title",image.file.title) if image.file.title
    outfile.printf("%s,%s\n", "Date",Time.new.to_s)
    outfile.printf("\n")
    outfile.printf("%s\n",    "IMAGE MEASURES")
    outfile.printf("\n")
    outfile.printf("%s,%d\n", "Rows", image.file.rows)
    outfile.printf("%s,%d\n", "Cols", image.file.cols)
    outfile.printf("%s,%d\n", "Total cells", image.file.area)
    outfile.printf("%s,%d\n", "Occupied cells", occupiedCells)
    outfile.printf("%s,%d\n", "Bits Per Pixel", image.bitsPerPix)
    outfile.printf("%s,%d\n", "Classes present", classesPresent)
    outfile.printf("%s,%s\n", "Background color",backColorStr)
    outfile.printf("%s,%d\n", "Neighbors per cell",nCount)
    if (image.distUnit.unit)
      name = image.distUnit.unit.pluralName
      factor = image.distUnit.factor
      factor = 1.0 if (not factor) or (factor == 0) or (factor == 1)
      outfile.printf("%s,%.3f,%s\n", "Original distance unit",factor,name)
    else
      outfile.printf("%s,%s\n", "Original distance unit","None")
    end
    if (image.areaUnit.unit)
      name = image.areaUnit.unit.pluralName
      factor = image.areaUnit.factor
      factor = 1.0 if (not factor) or (factor == 0) or (factor == 1)
      outfile.printf("%s,%.3f,%s\n", "Original area unit",factor,name)
    else
      outfile.printf("%s,%s\n", "Original area unit","None")
    end

    if imageMeasures
    
      analysesOutput.each do | analysisOutput |
        if analysisOutput.outType == AnalysisType::IMAGE
          outfile.printf("%s,",analysisOutput.name)
          if analysisOutput.output.nil?
            printf(outfile,"0")
          else
            value = analysisOutput.output
            if value.kind_of? Integer
              if value.abs == Calculator::Infinity
                printf(outfile, (value >= 0 ? "Pos " : "Neg ") + "Infinity")
              else
                printf(outfile, "%d", value)
              end
            else  # Float
              printf(outfile, "%.#{analysisOutput.precision}f", value)
            end
          end
          unit = analysisOutput.unit
          if unit.abbrev.length > 0
            outfile.print ",",unit.abbrev,"\n"
          else
            outfile.print "\n"
          end
        end
      end
    end
    
    if classMeasures
    
      outfile.printf("\n")
      outfile.printf("%s\n", "CLASS MEASURES")
      outfile.printf("\n")

      analysesOutput.each do | analysisOutput |
        if analysisOutput.outType == AnalysisType::CLASS
          
          name = analysisOutput.name
          unitString = analysisOutput.unit.abbrev
          precision = analysisOutput.precision
          dataArray = analysisOutput.output.sort
          
          columns = []
          dataArray.each do | miniArray |
            columns << miniArray[0]  # color
          end
          
          columns.each do | colColor |
          
            legendItem = image.file.legend[colColor]
            if legendItem.nil?
              classLabel = "Class " + colColor.to_s
            else
              classLabel = legendItem
            end
            
            value = analysisOutput.output[colColor]
            
            outfile.printf("%s,",name)
            outfile.printf("%s,",classLabel)
            if value.nil?
              outfile.printf("0")
            elsif value.abs == Calculator::Infinity
              outfile.printf((value >= 0 ? "Pos " : "Neg ") + "Infinity")
            else
              outfile.printf("%.#{precision}f",value)
            end
            outfile.printf(",%s",unitString) if unitString.length > 0
            outfile.printf("\n")
          end
        end
      end
    end
    
    if interclassMeasures
    
      outfile.printf("\n")
      outfile.printf("%s\n",    "INTERCLASS MEASURES")
      outfile.printf("\n")
      
      analysesOutput.each do | analysisOutput |
        if analysisOutput.outType == AnalysisType::INTERCLASS
          name = analysisOutput.name
          precision = analysisOutput.precision
          unitString = analysisOutput.unit.abbrev
          rowIndices = analysisOutput.output.rows
          colIndices = analysisOutput.output.cols
          rowIndices.each do | rowIndex |
            legendItem = image.file.legend[rowIndex]
            if legendItem.nil?
              class1Name = "Class " + rowIndex.to_s
            else
              class1Name = legendItem
            end
            colIndices.each do | colIndex |
              legendItem = image.file.legend[colIndex]
              if legendItem.nil?
                class2Name = "Class " + colIndex.to_s
              else
                class2Name = legendItem
              end
              value = analysisOutput.output[rowIndex,colIndex]
              outfile.printf("%s,%s,%s,",name,class1Name,class2Name)
              if value.nil?
                printf(outfile,"0")
              elsif value.abs == Calculator::Infinity
                printf(outfile, "%s",(value >= 0 ? "Pos " : "Neg ") + "Infinity")
              else
                printf(outfile,"%.#{precision}f",value)
              end
              outfile.printf(",%s",unitString) if unitString.length > 0
              outfile.printf("\n")
            end
          end
        end
      end
    end
    outfile.close
  end

end
