
require InstallPath + 'BinaryReader.rb'
require InstallPath + 'Units.rb'

class FileHeader
  def initialize(binReader)
    @hdword = binReader.readString(6)
    @ipack = binReader.readUInt16
    @nbands = binReader.readUInt16
    binReader.readString(6)
    @icols = binReader.readUInt32
    @irows = binReader.readUInt32
    @xstart = binReader.readInt32
    @ystart = binReader.readInt32
    binReader.readString(56)
    @maptype = binReader.readUInt16()
    @nclass = binReader.readUInt16()
    binReader.readString(14)
    @iautyp = binReader.readUInt16()
    @acre = binReader.readFloat32()
    @xmap = binReader.readFloat32()
    @ymap = binReader.readFloat32()
    @xcell = binReader.readFloat32()
    @ycell = binReader.readFloat32()
  end

  attr_reader(:hdword,:ipack,:nbands,:icols,:irows,:xstart,:ystart,:maptype,
              :nclass,:iautyp,:acre,:xmap,:ymap,:xcell,:ycell)

end

class ImageConverter

  def name
    "Erdas LAN"
  end
  
  def help(verbose)
    if verbose
      ["LAN - ERDAS 7.4 compatible LAN file",
       "",
       "  To invoke from the command line type ilan(file) or ilan(path~file)",
       "  The file specification can contain wildcards such as *.lan"
      ]
    else
      ["LAN - ERDAS LAN"]
    end
  end

  def readImage(engine,imageArgs,imageInstance)

    image = nil

    # for a LAN file image args should be 1 or 2: optional path and file

    if imageArgs.nil? or (imageArgs.length != 1 and imageArgs.length != 2)
      raise("Incorrect image args: "+ imageArgs+ "  Expected an optional path and a filename.")
      return nil
    end

    if imageArgs.length == 1
      fileName = imageArgs[0]
    else # == 2
      path = imageArgs[0]
      last = path.length-1
      if path.length > 0 and path[last,1] != "\\" and path[last,1] != ":"
        path = path + "\\"
      end
      fileName = path + imageArgs[1]
    end

    if not FileTest.exists?(fileName)
      extPresent = false
      extPresent = true if fileName =~ /.*\.lan$/i
      fileName += ".lan" if not extPresent
      if not FileTest.exists?(fileName)
        raise("Input file " + fileName + " does not exist!")
      end
    end

    imageInstance.fileName = fileName
    
    file = File.open(fileName)
    file.binmode

    reader = BinaryReader.new(file)

    # 128 byte header
    header = FileHeader.new(reader)

    case header.maptype
      when 2
        imageInstance.distUnit.unit = Units.find("feet")
      else
        imageInstance.distUnit.unit = Units.find("meter")
    end
    
    if header.xcell != header.ycell
      engine.warning(imageArgs.join(",") + " does not have square pixels.")
    end
    
    imageInstance.distUnit.factor = header.xcell
    
    case header.iautyp
      when 1
        imageInstance.areaUnit.unit = Units.find("acre")
        imageInstance.areaUnit.factor = header.acre
      when 2
        imageInstance.areaUnit.unit = Units.find("hectare")
        imageInstance.areaUnit.factor = header.acre
      else  # other or none - we will default
        distUnitName = imageInstance.distUnit.unit.name
        imageInstance.areaUnit.unit = Units.find("square #{distUnitName}")
        imageInstance.areaUnit.factor = header.xcell * header.xcell
    end

    rows = header.irows
    cols = header.icols

   # todo? : could do a setOrigin kind of call and have simple for loops
   #    like map.specify(rows,cols,Map::UPPER_LEFT)

    case header.ipack
    
      when 2   #   16 bit
        image = imageInstance.makeNewImage(rows,cols,16,engine)
        ushortsRead = 0
        totalUshortsRead = 0
        pixNum =  0
        totalPixels = rows * cols
        pixelBucket = 0
        (rows-1).downto(0) do | row |
          cols.times do | col |
            if pixNum >= ushortsRead
              pixelsLeftToRead = totalPixels - totalUshortsRead
              if  pixelsLeftToRead >= BufferSize
                ushortsRead = BufferSize
              else
                ushortsRead = pixelsLeftToRead
              end
              pixelBucket = reader.readUInt16(ushortsRead)
              totalUshortsRead += ushortsRead
              pixNum = 0
            end
            image.setCell(row,col,pixelBucket[pixNum])
            pixNum += 1
          end
        end

      when 0   #   8  bit
        image = imageInstance.makeNewImage(rows,cols,8,engine)
        bytesRead = 0
        totalBytesRead = 0
        pixNum =  0
        totalPixels = rows * cols
        pixelBucket = 0
        (rows-1).downto(0) do | row |
          cols.times do | col |
            if pixNum >= bytesRead
              pixelsLeftToRead = totalPixels - totalBytesRead
              if  pixelsLeftToRead >= BufferSize
                bytesRead = BufferSize
              else
                bytesRead = pixelsLeftToRead
              end
              pixelBucket = reader.readByte(bytesRead)
              pixNum = 0
              totalBytesRead += bytesRead
            end
            image.setCell(row,col,pixelBucket[pixNum])
            pixNum += 1
          end
        end

      when 1   #   4 bit
        image = imageInstance.makeNewImage(rows,cols,4,engine)

        totalPixels = rows * cols
        totalBytes = (totalPixels/2) + (totalPixels&1)
        bytesRead = 0
        row = rows-1
        col = 0
        while bytesRead < totalBytes
          bytesLeft = totalBytes - bytesRead
          if bytesLeft >= BufferSize
            bytes = reader.readByte(BufferSize)
            bytesRead += BufferSize
          else
            bytes = reader.readByte(bytesLeft)
            bytesRead += bytesLeft
          end
          bytes.each do | byte |
            image.setCell(row,col,(byte & 15))
            col += 1
            if col == cols
              row -= 1
              col = 0
            end
            if (row >= 0)
              image.setCell(row,col,((byte & 240) >> 4))
              col += 1
              if col == cols
                row -= 1
                col = 0
              end
            end
          end
        end
      else
        print "Error: unknown ERDAS file encoding :",header[x],"\n"
    end

    # print "EOF? : ", file.eof?,"\n"
    # print "pos  : ", file.pos,"\n"
    # print "size : ", File.size(fileName),"\n"
    
    file.close

    trlFileName = nil
    baseFileNameLen = fileName.length-4
    extPos = fileName.downcase.rindex(".lan")
    
    if extPos == baseFileNameLen
      trlFileName = fileName[0,baseFileNameLen]
      trlFileName += ".trl"
    end
    
    if FileTest.exists?(trlFileName)
    
      trlFile = File.open(trlFileName)
      trlFile.binmode

      reader = BinaryReader.new(trlFile)
      
      # header info first 128 bytes
      reader.readByte(72)
      title = reader.readString(45)
      reader.readByte(11)
      
      while title.length > 0 and title[title.length-1] == 0
        title = title[0,title.length-1]
      end
      title = $1 if title =~ /^(.*)~\s*$/
      image.title = title
      
      green = reader.readByte(256)
      red = reader.readByte(256)
      blue = reader.readByte(256)
      
      0.upto(255) do | color |
        value = red[color] << 16
        value |= green[color] << 8
        value |= blue[color]
        image.palette[color] = value
      end
      
      if not trlFile.eof
        8.upto(16) { | i | reader.readByte(128);}  # skip histogram
      end
      
      color = 0
      while not trlFile.eof
        4.times do | i |
          encodedString = reader.readString(32)
          string = ""
          string = $1 if encodedString =~ /(.*)~/    # string followed by ~
          image.legend[color] = string
          color += 1
        end
      end
      
      trlFile.close
    end
    
    image

  end

  def writeImage(engine,image,imageArgs)
  end

end




# ways to read data
#
#   16 bit
#
#        rows.times do | row |
#          cols.times do | col |
#            image.setCell(row,col,reader.readUInt16)
#          end
#        end
#
#        rows.times do | row |
#          tcol = 0
#          while tcol < cols
#            colsLeft = cols - tcol
#            if (colsLeft >= BufferSize)
#              rowChunk = reader.readUInt16(BufferSize)
#            else
#              rowChunk = reader.readUInt16(colsLeft)
#            end
#            rowChunk.size.times do | offset |
#              image.setCell(row,tcol+offset,rowChunk[offset])
#            end
#            tcol = tcol + BufferSize
#          end
#        end
#
#        ushortsRead = 0
#        pixNum =  0
#        totalPixels = rows * cols
#        pixelBucket = 0
#        rows.times do | row |
#          cols.times do | col |
#            if pixNum >= ushortsRead
#              pixelsLeftToRead = totalPixels - ushortsRead
#              if  pixelsLeftToRead >= BufferSize
#                pixelBucket = reader.readUInt16(BufferSize)
#                ushortsRead += BufferSize
#              else
#                pixelBucket = reader.readUInt16(pixelsLeftToRead)
#                ushortsRead += pixelsLeftToRead
#              end
#              pixNum = 0
#            end
#            image.setCell(row,col,pixelBucket[pixNum])
#            pixNum += 1
#          end
#        end
#
#
#    8-bit
#
#        rows.times do | row |
#          cols.times do | col |
#            image.setCell(row,col,reader.readByte)
#          end
#        end
#
#        rows.times do | row |
#          tcol = 0
#          while tcol < cols
#            colsLeft = cols - tcol
#            if (colsLeft >= BufferSize)
#              rowChunk = reader.readByte(BufferSize)
#            else
#              rowChunk = reader.readByte(colsLeft)
#            end
#            rowChunk.size.times do | offset |
#              image.setCell(row,tcol+offset,rowChunk[offset])
#            end
#            tcol = tcol + BufferSize
#          end
#        end
#
#        bytesRead = 0
#        pixNum =  0
#        totalPixels = rows * cols
#        pixelBucket = 0
#        rows.times do | row |
#          cols.times do | col |
#            if pixNum >= bytesRead
#              pixelsLeftToRead = totalPixels - bytesRead
#              if  pixelsLeftToRead >= BufferSize
#                pixelBucket = reader.readByte(BufferSize)
#                bytesRead += BufferSize
#              else
#                pixelBucket = reader.readByte(pixelsLeftToRead)
#                bytesRead += pixelsLeftToRead
#              end
#              pixNum = 0
#            end
#            image.setCell(row,col,pixelBucket[pixNum])
#            pixNum += 1
#          end
#        end
#
#
#    4-bit
#
#        rows.times do | row |
#          byte = 0
#          cols.times do | col |
#            if (col & 1) == 0
#              byte = reader.readByte
#              cover = (byte & 240) >> 4
#            else
#              cover = (byte & 15)
#            end
#            image.setCell(row,col,cover)
#          end
#        end
#
#        rows.times do | row |
#          tcol = 0
#          while tcol < cols
#            colsLeft = cols - tcol
#            numBytes = colsLeft >> 1
#            numBytes = numBytes + 1 if (colsLeft & 1) != 0
#            if (numBytes >= BufferSize)
#              rowChunk = reader.readByte(BufferSize)
#            else
#              rowChunk = reader.readByte(numBytes)
#            end
#            byte = 0
#            lastByte = rowChunk.size-1
#            oddCols = (cols & 1) > 0
#            rowChunk.size.times do | byteNumber |
#              byte = rowChunk[byteNumber]
#              pixNum = byteNumber<<1
#              image.setCell(row,tcol+pixNum,((byte & 240) >> 4))
#              if (byteNumber != lastByte) or (oddCols)
#                image.setCell(row,tcol+pixNum+1,(byte & 15))
#              end
#            end
#            tcol = tcol + (BufferSize << 1)
#          end
#        end
