
require InstallPath + 'Calculator'

class ReportWriter

  def name
    "Comma-delimited format (.CSV)"
  end
  
  def help(verbose)
    if verbose
      ["RCSV - comma-delimited report",
       "",
       "  This report is an Excel-compatible comma separated format. Each value",
       "  is delimited with a comma. Image measures are reported first, followed",
       "  by class measures, and then interclass measures. Units are included in",
       "  the output."
      ]
    else
      ["RCSV - comma-delimited report"]
    end
  end
  
  def outName
    @outfile
  end

  def run(engine,options,image,analysesOutput,args,verbose)

    if image.nil?
      engine.error("CSV report writer did not receive an image to process")
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
        engine.error("Too many arguments to CSV report.")
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
    outfile.printf("%s\n",  "IAN CSV REPORT")
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
      
      outputRows = []
      analysesOutput.each do | analysisOutput |
        if analysisOutput.outType == AnalysisType::CLASS
          rowHash = {}
          rowHash["IanMetricName"] = analysisOutput.name
          unit = analysisOutput.unit
          rowHash["IanMetricUnit"] = unit.abbrev if unit.abbrev.length > 0
          rowHash["IanMetricPrecision"] = analysisOutput.precision
          # convert hash output to array sorted by key : [[a,20],[b,10]]
          colOutput = analysisOutput.output.sort
          colOutput.each do | miniArray |
            color = miniArray[0]
            value = miniArray[1]
            rowHash[color] = value
          end
          outputRows << rowHash  # needs.dup?
        end
      end
      colHeadings = []
      outputRows.each do | outputRow |
        outputRow.each_pair do | key, value |
           if key != "IanMetricName" and key != "IanMetricUnit" and key != "IanMetricPrecision"
             colHeadings << key
           end
        end
      end
      colHeadings = colHeadings.uniq.sort
      
      # print col headings
      printf(outfile,",")
      colHeadings.each do | colColor |
        legendItem = image.file.legend[colColor]
        if legendItem.nil?
          item = "Class " + colColor.to_s
        else
          item = legendItem
        end
        printf(outfile,",%s",item)
      end
      printf(outfile,"\n")
      
      # print measures
      outputRows.each do | outputRow |
        printf(outfile,"%s,",outputRow["IanMetricName"])
        printf(outfile,outputRow["IanMetricUnit"]) if outputRow["IanMetricUnit"]
        colHeadings.each do | colColor |
          printf(outfile,",")
          value = outputRow[colColor]
          if value.nil?
            printf(outfile,"0")
          elsif value.abs == Calculator::Infinity
            printf(outfile, (value >= 0 ? "Pos " : "Neg ") + "Infinity")
          else
            printf(outfile,"%.#{outputRow["IanMetricPrecision"]}f",value)
          end
        end
        printf(outfile,"\n")
      end
    end
    
    if interclassMeasures
    
      outfile.printf("\n")
      outfile.printf("%s\n",    "INTERCLASS MEASURES")
      outfile.printf("\n")
      
      analysesOutput.each do | analysisOutput |
        if analysisOutput.outType == AnalysisType::INTERCLASS
          outfile.print analysisOutput.name
          unit = analysisOutput.unit
          if unit.abbrev.length > 0
            outfile.print ",",unit.abbrev,"\n"
          else
            outfile.print "\n"
          end
          rowIndices = analysisOutput.output.rows
          colIndices = analysisOutput.output.cols
          colIndices.each do | colIndex |
            legendItem = image.file.legend[colIndex]
            if legendItem.nil?
              item = "Class " + colIndex.to_s
            else
              item = legendItem
            end
            outfile.print ","  # okay to spit out , first as empty needed
            outfile.print item
          end
          outfile.print "\n"
          rowIndices.each do | rowIndex |
            legendItem = image.file.legend[rowIndex]
            if legendItem.nil?
              item = "Class " + rowIndex.to_s
            else
              item = legendItem
            end
            outfile.print item
            colIndices.each do | colIndex |
              value = analysisOutput.output[rowIndex,colIndex]
              if value.nil?
                printf(outfile,",0")
              elsif value.abs == Calculator::Infinity
                printf(outfile, ",%s",(value >= 0 ? "Pos " : "Neg ") + "Infinity")
              else
                printf(outfile,",%.#{analysisOutput.precision}f",value)
              end
            end
            outfile.print "\n"
          end
        end
      end
    end
    outfile.close
  end

end

