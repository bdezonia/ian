
require InstallPath + 'BinaryReader.rb'

class ImageConverter

  def name
    "Windows BMP"
  end
  
  def help(verbose)
    if verbose
      ["BMP - WINDOWS compatible BMP file",
       "",
       "  To invoke from the command line type ibmp(file) or ibmp(path~file)",
       "  The file specification can contain wildcards such as *.bmp"
      ]
    else
      ["BMP - WIN BMP"]
    end
  end


  def readImage(engine,imageArgs,imageInstance)

    image = nil

    # for a BMP file image args should be 1 or 2: optional path and file

    if imageArgs.nil? or (imageArgs.length != 1 and imageArgs.length != 2)
      raise("Incorrect image args: "+ imageArgs+ "  Expected an optional path and a filename.")
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
      extPresent = true if filename =~ /.*\.dib$/i
      extPresent = true if filename =~ /.*\.bmp$/i
      if not extPresent
        filename += ".dib"
        filename[filename.length-4,4] = ".bmp" if not FileTest.exists?(filename)
      end
      if not FileTest.exists?(filename)
        raise("Input file " + filename + " does not exist!")
      end
    end

    imageInstance.fileName = filename
    
    file = File.open(filename)
    file.binmode

    reader = BinaryReader.new(file)

    if reader.readString(2) != "BM"
      raise(imageArgs.join(",")+" is not a valid BMP file.")
    end
    
    reader.readUInt32  # File size in bytes
    reader.readUInt32  # reserved
    dataOffset = reader.readUInt32  # File offset to raster data
    
    headerSize = reader.readUInt32
    
    if headerSize == 12    # old style OS/2 DIB/BMP
      width = reader.readUInt16
      height = reader.readUInt16
      numPlanes = reader.readUInt16
      bitCount = reader.readUInt16
      compression = 0
      imageSize = 0
      xPixPerMeter = 0
      yPixPerMeter = 0
      colorsUsed = 0
      colorsImportant = 0
    
    else    # more modern DIB/BMP
      width = reader.readInt32
      height = reader.readInt32
      numPlanes = reader.readUInt16
      bitCount = reader.readUInt16
      compression = reader.readUInt32   # 0,1,2
      imageSize = reader.readUInt32     # can be zero if no compression
      xPixPerMeter = reader.readInt32
      yPixPerMeter = reader.readInt32
      colorsUsed = reader.readUInt32
      colorsImportant = reader.readUInt32
      
    end

    if numPlanes != 1
      raise(imageArgs.join(",") + " is multiplane.")
    end
    
    if xPixPerMeter != yPixPerMeter
      engine.warning(imageArgs.join(",") + " does not have square pixels.")
    end

    originLowerLeft = height > 0
    rows = height.abs
    cols = width
    
#print "Bytes in file: ",File.size(filename),"\n"
#print "Bytes without palette: ",(14+headerSize+(rows*cols*bitCount/8)),"\n"
#print "Compression: ",compression,"\n"
#print "BitCount:    ",bitCount,"\n"
#print "Colors used: ",colorsUsed,"\n"
#print "Colors important: ",colorsImportant,"\n"

    palette = nil
    case bitCount
      when 1,4,8
        colorsUsed = (1 << bitCount) if (colorsUsed == 0)
        if headerSize != 12  # newer style BMP
          palette = reader.readUInt32(colorsUsed)
          palette = [palette] if colorsUsed == 1
        else  # old style BMP: missing some header vars
          palette = []
          colorsUsed.times do | color |
            blue = reader.readByte
            green = reader.readByte
            red = reader.readByte
            msValue = blue << 24
            msValue |= green << 16
            msValue |= red << 8
            palette[color] = msValue
          end
        end
      when 16,32
        if compression == 3
          redBitfieldMask = reader.readUInt32
          greenBitfieldMask = reader.readUInt32
          blueBitfieldMask = reader.readUInt32
        end
    end
    
    file.pos = dataOffset
    
    case bitCount
      when 1   #   1  bit
        image = imageInstance.makeNewImage(rows,cols,1,engine)
        bytesPerRow = cols / 8
        bytesPerRow += 1 if cols % 8 != 0
        bytesMod4 = bytesPerRow % 4
        bytesPerRow += 4 - bytesMod4 if bytesMod4 != 0
        rows.times do | row |
          rowChunk = reader.readByte(bytesPerRow)
          cols.times do | col |
            pixel = rowChunk[col/8][7-(col%8)]
            #print "pixel[#{row}][#{col}] == #{pixel}\n"
            if originLowerLeft
              image.setCell(row,col,pixel)
            else
              image.setCell(rows-1-row,col,pixel)
            end
          end
        end

      when 4   #   4  bit
        image = imageInstance.makeNewImage(rows,cols,4,engine)
        if compression == 2
          row = 0
          col = 0
          n = -1
          c = -1
          until (n == 0 and c == 1) or (row >= rows)
            n = reader.readByte
            c = reader.readByte
            if n == 0
              case c
                when 0  # end of line
                  while col < cols
                    image.setCell(row,col,0)
                    col += 1
                  end
                  col = 0
                  row += 1
                when 1  # end of bitmap
                  while row < rows
                    while col < cols
                      image.setCell(row,col,0)
                      col += 1
                    end
                    col = 0
                    row += 1
                  end
                when 2  # a delta to next nonzero image data
                  deltaX = reader.readByte
                  deltaY = reader.readByte
                  targetRow = row + deltaY
                  targetCol = col + deltaX
                  while row < targetRow
                    while col < cols
                      image.setCell(row,col,0)
                      col += 1
                    end
                    col = 0
                    row += 1
                  end
                  while col < targetCol
                    image.setCell(row,col,0)
                    col += 1
                  end
                else # c >= 3
                  c.times do | b |
                    if (c % 2) == 0
                      byte = reader.readByte
                      image.setCell(row,col,((byte & 240) >> 4))
                    else
                      image.setCell(row,col,(byte & 15))
                    end
                    col += 1
                  end
                  reader.readByte if (c % 2) != 0  # align on 16-bit boundary
              end
            else # n != 0 ... its a pixel count
              n.times do | i |
                if n % 2 == 0
                  image.setCell(row,col,((c & 240) >> 4))
                else
                  image.setCell(row,col+1,(c & 15))
                end
                col += 1
              end
            end
          end
        else  # uncompressed
          bytesPerRow = cols / 2
          bytesPerRow += 1 if cols & 1 != 0
          bytesMod4 = bytesPerRow % 4
          bytesPerRow += 4 - bytesMod4 if bytesMod4 != 0
          rows.times do | row |
            rowChunk = reader.readByte(bytesPerRow)
            cols.times do | col |
              if (col & 1) == 0
                pixel = (rowChunk[col/2] & 240) >> 4
              else # (col & 1) == 1
                pixel = rowChunk[col/2] & 15
              end
              if originLowerLeft
                image.setCell(row,col,pixel)
              else
                image.setCell(rows-1-row,col,pixel)
              end
            end
          end
        end
        
      when 8   #   8  bit

        image = imageInstance.makeNewImage(rows,cols,8,engine)
        if compression == 1
          row = 0
          col = 0
          n = -1
          c = -1
          until (n == 0 and c == 1) or (row >= rows)
            n = reader.readByte
            c = reader.readByte
            if n == 0
              case c
                when 0  # end of line
                  while col < cols
                    image.setCell(row,col,0)
                    col += 1
                  end
                  col = 0
                  row += 1
                when 1  # end of bitmap
                  while row < rows
                    while col < cols
                      image.setCell(row,col,0)
                      col += 1
                    end
                    col = 0
                    row += 1
                  end
                when 2  # a delta to next nonzero image data
                  deltaX = reader.readByte
                  deltaY = reader.readByte
                  targetRow = row + deltaY
                  targetCol = col + deltaX
                  while row < targetRow
                    while col < cols
                      image.setCell(row,col,0)
                      col += 1
                    end
                    col = 0
                    row += 1
                  end
                  while col < targetCol
                    image.setCell(row,col,0)
                    col += 1
                  end
                else # c >= 3
                  c.times do | b |
                    image.setCell(row,col,reader.readByte)
                    col += 1
                  end
                  reader.readByte if (c % 2) != 0  # align on 16-bit boundary
              end
            else # n != 0 ... its a pixel count
              n.times do | i |
                image.setCell(row,col,c)
                col += 1
              end
            end
          end
        else  # uncompressed
          colsMod4 = cols % 4
          bytesPerRow = cols
          bytesPerRow += 4 - (colsMod4) if colsMod4 != 0
          rows.times do | row |
            rowChunk = reader.readByte(bytesPerRow)
            cols.times do | col |
              if originLowerLeft
                image.setCell(row,col,rowChunk[col])
              else
                image.setCell(rows-1-row,col,rowChunk[col])
              end
            end
          end
        end
        
      when 16   #   16  bit
        image = imageInstance.makeNewImage(rows,cols,16,engine)
        shortsPerRow = cols
        shortsPerRow += 2 - (cols % 2) if (cols % 2) != 0
        rows.times do | row |
          rowChunk = reader.readUInt16(shortsPerRow)
          cols.times do | col |
            # todo: endian issues may require the hi and lo byte get swapped
            if originLowerLeft
              image.setCell(row,col,rowChunk[col])
            else
              image.setCell(rows-1-row,col,rowChunk[col])
            end
          end
        end
        
      when 24   #   24  bit
        image = imageInstance.makeNewImage(rows,cols,24,engine)
        pad = cols % 4
        rows.times do | row |
          rowChunk = reader.readByte(cols*3 + pad)
          cols.times do | col |
            # set internal pixel rep from rowChunk[col]
            pixelPos = col*3
            pixel = 0
            pixel |= (rowChunk[pixelPos+2] << 16)   # set red
            pixel |= (rowChunk[pixelPos+1] << 8)    # set green
            pixel |= (rowChunk[pixelPos])           # set blue
            if originLowerLeft
              image.setCell(row,col,pixel)
            else
              image.setCell(rows-1-row,col,pixel)
            end
          end
        end

      when 32 # 32 bit
        image = imageInstance.makeNewImage(rows,cols,24,engine)
        rows.times do | row |
          rowChunk = reader.readUInt32(cols)
          cols.times do | col |
            if originLowerLeft
              image.setCell(row,col,rowChunk[col]&0x00ffffff)
            else
              image.setCell(rows-1-row,col,rowChunk[col]&0x00ffffff)
            end
          end
        end
      
      else
        raise("Unknown BMP file encoding : " + bitCount.to_s + " bits.\n")
    end
    
    if palette
      palette.each_index do | entryNum |
        # ms RGB layout:     bgra
        # Ian's RGB layout : 0rgb
        msValue = palette[entryNum]
        value  = (msValue & 0xff000000) >> 24  # set blue
        value |= (msValue & 0x00ff0000) >> 8   # set green
        value |= (msValue & 0x0000ff00) << 8   # set red
        image.palette[entryNum] = value
      end
    end

#    print "EOF? : ", file.eof?,"\n"
#    print "pos  : ", file.pos,"\n"
#    print "size : ", File.size(filename),"\n"
    
    file.close

    image

  end

  def writeImage(engine,image,imageArgs)
  end

end

#def byteCount(cols)
#  bytesPerRow = cols / 2
#  bytesPerRow += 1 if cols & 1 != 0
#  bytesMod4 = bytesPerRow % 4
#  bytesPerRow += 4 - bytesMod4 if bytesMod4 != 0
#  bytesPerRow
#end
#
#0.upto(24) { | i | print i," cols    ",byteCount(i)," bytes\n" }