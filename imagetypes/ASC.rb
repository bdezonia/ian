
require InstallPath + "Units"

class ImageConverter

  def name
    "IAN ASCII"
  end
  
  def help(verbose)
    if verbose
      ["ASC - IAN ASCII format map",
       "",
       "  To invoke from the command line type iasc(file) or iasc(path~file)",
       "  The file specification can contain wildcards such as *.asc"
      ]
    else
      ["ASC - IAN ASCII"]
    end
  end


  def readImage(engine,imageArgs,imageInstance)

    image = nil

    # for an ASC file image args should be 1 or 2: optional path and file

    if imageArgs.nil? or (imageArgs.length != 1 and imageArgs.length != 2)
      raise("Incorrect image args: "+imageArgs+"  Expected an optional path and a filename.")
      return nil
    end

    if imageArgs.length == 1
      filename = imageArgs[0]
    else # == 2
      path = imageArgs[0]
      last = path.length-1
      if path.length > 0 and path[last,1] != "\\" and path[last,1] != ":"
        path = path + "\\"
      end
      filename = path + imageArgs[1]
    end

    if not FileTest.exists?(filename)
      extPresent = false
      extPresent = true if filename =~ /.*\.asc$/i
      filename2 = filename + ".asc" if not extPresent
      if not FileTest.exists?(filename2)
        raise("Input file " + filename + " does not exist!")
      end
      filename = filename2
    end

    imageInstance.fileName = filename
    
    file = File.open(filename)

    lineNum = 0
    rows = 0
    cols = 0
    lineWaiting = false
    line = nil
    
    savedTitle = nil
    savedLegend = nil
    
    while (not file.eof) or lineWaiting
    
      if not lineWaiting
        line = file.gets.chomp
        lineNum += 1
      end
      
      lineWaiting = false
      
      next if line =~ /^\s*(\/\/.*)*$/  # ignore comment lines and empty lines
      
      if line =~ /^\s*\[columns\]\s*(\/\/.*)*$/i          # columns section

        if file.eof
          raise("Unexpected EOF trying to read column count in " + filename)
        else
          line = file.gets.chomp
          line =~ /\s*(\d+)\s*(\/\/.*)*$/
          cols = $1.to_i
          lineNum += 1
        end
        
      elsif line =~ /^\s*\[rows\]\s*(\/\/.*)*$/i          # rows section
      
        if file.eof
          raise("Unexpected EOF trying to read row count in " + filename)
        else
          line = file.gets.chomp
          line =~ /\s*(\d+)\s*(\/\/.*)*$/
          rows = $1.to_i
          lineNum += 1
        end
        
      elsif line =~ /^\s*\[cells\]\s*(\/\/.*)*$/i         # cells section
      
        if cols == 0
          raise("Cell values specified before column count given in " + filename)
        end
        if rows == 0
          raise("Cell values specified before row count given in " + filename)
        end
        
        image = imageInstance.makeNewImage(rows,cols,24,engine)

        if file.eof
          raise("Unexpected EOF reading cell data from "+filename)
        else
          line = file.gets.chomp
          lineNum += 1
        end
        
        rows.times do | row |
          cols.times do | col |
            if line =~ /^\s*(\d+)\s+\d+/    # pixel with more to come
              pixel = $1.to_i
                                            # line = $2: tried and failed
              while line =~ /^\s/
                line = line[1,line.length-1]
              end
              while line =~ /^\d/
                line = line[1,line.length-1]
              end
              while line =~ /^\s/
                line = line[1,line.length-1]
              end
              image.setCell(rows-row-1,col,pixel)
            elsif line =~ /^\s*(\d+)\s*(\/\/.*)*$/   # last pixel in line
              pixel = $1.to_i
              if file.eof
                lineWaiting = false
                if not ((row == (rows-1)) and (col == (cols-1)))
                  raise("Unexpected EOF reading cell data from "+filename)
                end
              else
                line = file.gets.chomp
                lineNum += 1
                lineWaiting = true
              end
              image.setCell(rows-row-1,col,pixel)
            elsif line.length == 0
              if file.eof
                raise("Unexpected EOF reading cell data from "+filename)
              else
                line = file.gets.chomp
                lineNum += 1
                redo
              end
            else
              raise("Cell data has incorrect format near line " + lineNum.to_s+" of "+filename)
            end
          end
        end
        
      elsif line =~ /^\s*\[title\]\s*(\/\/.*)*$/i         # title section
      
        break if file.eof      
        savedTitle = file.gets.chomp
        lineNum += 1
        
      elsif line =~ /^\s*\[legend\]\s*(\/\/.*)*$/i        # legend section
      
        break if file.eof
        line = file.gets.chomp
        lineNum += 1
        while line =~ /^\s*(\d+)\s+(.+)\s*(\/\/.*)*$/
          savedLegend = {} if not savedLegend
          savedLegend[$1.to_i] = $2
          if file.eof
            line = ""
            lineWaiting = false
          else
            line = file.gets.chomp
            lineNum += 1
            lineWaiting = true
          end
        end
        
      elsif line =~ /^\s*\[cell spacing\]\s*(\/\/.*)*$/i  # cell spacing section
      
        if file.eof
          raise("Unexpected EOF trying to read cell spacing in " + filename)
        else
          line = file.gets.chomp
          lineNum += 1
          
          if line =~ /^\s*(.+)\s+(.+)\s*(\/\/.*)*$/
            imageInstance.distUnit.unit = Units.find($2)
            imageInstance.distUnit.factor = $1.to_f
            if imageInstance.distUnit.unit.nil?
              raise("Cell spacing unit("+$2+") not found in unit database for image " + filename)
            end
            if imageInstance.distUnit.unit.family != "distance"
              raise("Cell spacing unit("+imageInstance.distUnit.unit.family+") must be a distance unit in " + filename)
            end
            # attempt to default area unit to square of distance unit
            imageInstance.areaUnit.unit = Units.find("square #{imageInstance.distUnit.unit.name}")
            if not imageInstance.areaUnit.unit.nil?
              imageInstance.areaUnit.factor = imageInstance.distUnit.factor * imageInstance.distUnit.factor
            end
          else
            raise("Incorrect format for cell spacing in " + filename)
          end
        end
        
      else
        raise("Unknown section: ("+line+") encountered in " + filename + " near line " + lineNum.to_s)
      end
    end
    
    file.close
    
    if savedLegend
      savedLegend.each_pair do | key, value |
        image.legend[key] = value
      end
    end
    image.title = savedTitle if savedTitle

    image

  end

  def writeImage(engine,image,imageArgs)
  end

end

