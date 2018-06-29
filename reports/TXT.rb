
require InstallPath + 'Calculator'

class ReportWriter

  def name
    "Text format by metric (.TXT)"
  end
  
  def help(verbose)
    if verbose
      ["RTXT - Text report (by metric)",
       "",
       "  This report format consists of text. First image measures are",
       "  reported, followed  by class measures, and then interclass",
       "  measures. When class measures are reported they are grouped",
       "  together by metric. For example:",
       "",
       "  Report",
       "    Image measures",
       "      measure a",
       "      measure b",
       "    Class measures",
       "      measure 1",
       "        class 1",
       "        class 2",
       "      measure 2",
       "        class 1",
       "        class 2",
       "    Interclass measures",
       "      measure c"
      ]
    else
      ["RTXT - Text report (by metric)"]
    end
  end
  
  def outName
    @outfile
  end

  def run(engine,options,image,analysesOutput,args,verbose)

    if image.nil?
      engine.error("TXT report writer did not receive an image to process")
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
        fileName += ".txt"
      when 1
        fileName = args[0]
      when 2
        fileName = args[0]
        fileName = fileName + "\\" if fileName[fileName.length-1] != "\\"
        fileName = fileName + args[1]
      else
        engine.error("Too many arguments to TXT report.")
        return
    end
    
    # if no extension specified apply .txt
    fileName += ".txt" if not fileName =~ /.*\.\w+$/
    
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
    outfile.print "IAN text report on : ", image.fileName, "\n"
    outfile.print("\n"+image.file.title+"\n") if image.file.title
    outfile.print("  "+Time.new.to_s+"\n")
    outfile.print "\nImage measures\n\n"
    outfile.printf("  %-50s : %-12d\n", "Rows", image.file.rows)
    outfile.printf("  %-50s : %-12d\n", "Cols", image.file.cols)
    outfile.printf("  %-50s : %-12d\n", "Total cells", image.file.area)
    outfile.printf("  %-50s : %-12d\n", "Occupied cells", occupiedCells)
    outfile.printf("  %-50s : %-12d\n", "Bits Per Pixel", image.bitsPerPix)
    outfile.printf("  %-50s : %-12d\n", "Classes present", classesPresent)
    outfile.printf("  %-50s : %s\n",    "Background color",backColorStr)
    outfile.printf("  %-50s : %-12d\n", "Neighbors per cell",nCount)
    if (image.distUnit.unit)
      name = image.distUnit.unit.pluralName
      factor = image.distUnit.factor
      factor = 1.0 if (not factor) or (factor == 0) or (factor == 1)
      outfile.printf("  %-50s : %.3f %s\n", "Original distance unit",factor,name)
    else
      outfile.printf("  %-50s : %s\n", "Original distance unit","None")
    end
    if (image.areaUnit.unit)
      name = image.areaUnit.unit.pluralName
      factor = image.areaUnit.factor
      factor = 1.0 if (not factor) or (factor == 0) or (factor == 1)
      outfile.printf("  %-50s : %.3f %s\n", "Original area unit",factor,name)
    else
      outfile.printf("  %-50s : %s\n", "Original area unit","None")
    end

    if imageMeasures
      analysesOutput.each do | analysisOutput |
        if analysisOutput.outType == AnalysisType::IMAGE
          outfile.printf("  %-50s : ", analysisOutput.name)
          if analysisOutput.output.nil?
            printf(outfile,"0")
          else
            value = analysisOutput.output
            if value.kind_of? Integer
              if value.abs == Calculator::Infinity
                printf(outfile, "%12s", (value >= 0 ? "+" : "-") + "Infinity")
              else
                printf(outfile, "%-12d", value)
              end
            else  # Float
              printf(outfile, "%-12.#{analysisOutput.precision}f", value)
            end
          end
          unit = analysisOutput.unit
          if unit.abbrev.length > 0
            outfile.print " (",unit.abbrev,")\n"
          else
            outfile.print "\n"
          end
        end
      end
    end
    if classMeasures
      outfile.print "\nClass measures\n\n"
      analysesOutput.each do | analysisOutput |
        if analysisOutput.outType == AnalysisType::CLASS
          outfile.print "  ", analysisOutput.name
          unit = analysisOutput.unit
          if unit.abbrev.length > 0
            outfile.print " (",unit.abbrev,")\n"
          else
            outfile.print "\n"
          end
          output = analysisOutput.output.sort
          output.each do | miniArray |
            color = miniArray[0]
            value = miniArray[1]
            legendItem = image.file.legend[color]
            if legendItem.nil?
              item = "Class " + color.to_s
            else
              item = legendItem
            end
            outfile.print  "    ", item, "  "
            if value.nil?
              printf(outfile,"0\n")
            elsif value.abs == Calculator::Infinity
              printf(outfile, "%s\n",(value >= 0 ? "+" : "-") + "Infinity")
            else
              printf(outfile,"%.#{analysisOutput.precision}f\n",value)
            end
          end
        end
      end
    end
    if interclassMeasures
      outfile.print "\nInterclass measures\n\n"
      analysesOutput.each do | analysisOutput |
        if analysisOutput.outType == AnalysisType::INTERCLASS
          outfile.print "  ", analysisOutput.name
          unit = analysisOutput.unit
          if unit.abbrev.length > 0
            outfile.print " (",unit.abbrev,")\n"
          else
            outfile.print "\n"
          end
          outfile.print "          "
          rowIndices = analysisOutput.output.rows
          colIndices = analysisOutput.output.cols
          colIndices.each do | colIndex |
            legendItem = image.file.legend[colIndex]
            if legendItem.nil?
              item = "Class " + colIndex.to_s
            else
              item = legendItem
            end
            outfile.print "  ", item
          end
          outfile.print "\n"
          rowIndices.each do | rowIndex |
            legendItem = image.file.legend[rowIndex]
            if legendItem.nil?
              item = "Class " + rowIndex.to_s
            else
              item = legendItem
            end
            outfile.print "    ", item
            colIndices.each do | colIndex |
              value = analysisOutput.output[rowIndex,colIndex]
              if value.nil?
                printf(outfile,"  0")
              elsif value.abs == Calculator::Infinity
                printf(outfile, "  %s",(value >= 0 ? "+" : "-") + "Infinity")
              else
                printf(outfile,"  %.#{analysisOutput.precision}f",value)
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

