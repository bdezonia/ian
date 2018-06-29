
require InstallPath + 'BinaryReader.rb'
require InstallPath + 'Units.rb'

class ImageConverter

  if not defined?(INCLUDED_TIF_ALREADY)
  
    INCLUDED_TIF_ALREADY = true
    
    TImageWidth = 256
    TImageLength = 257
    TBitsPerSample = 258
    TCompression = 259
    TPhotometricInterpretation = 262
    TFillOrder = 266
    TImageDescription = 270
    TStripOffsets = 273
    TOrientation = 274
    TSamplesPerPixel = 277
    TRowsPerStrip = 278
    TStripByteCounts = 279
    TXResolution = 282
    TYResolution = 283
    TPlanarConfiguration = 284
    TResolutionUnit = 296
    TColorMap = 320
    TExtraSamples = 338
    TTileWidth = 322
    TTileLength = 323
    TTileOffsets = 324
    TTileByteCounts = 325
    
    Xform1 = proc { | r,c,maxR,maxC | [maxR-r,c]      }
    Xform2 = proc { | r,c,maxR,maxC | [maxR-r,maxC-c] }
    Xform3 = proc { | r,c,maxR,maxC | [r,maxC-c]      }
    Xform4 = proc { | r,c,maxR,maxC | [r,c]           }
    Xform5 = proc { | r,c,maxR,maxC | [maxC-c,r]      }
    Xform6 = proc { | r,c,maxR,maxC | [maxC-c,maxR-r] }
    Xform7 = proc { | r,c,maxR,maxC | [c,maxR-r]      }
    Xform8 = proc { | r,c,maxR,maxC | [c,r]           }
    
  end

  def initialize
    @leftoverBits = []
    @bitToRead = -1
  end
  
  def littleEndian(number,numBytes)
    if @bigEndian
      little = 0
      numBytes.times do | byteNo |
        count = numBytes-byteNo-1
        byte = (number & (255 << (8 * count))) >> (8 * count)
        little |= byte << (8 * byteNo)
      end
      number = little
    end
    number
  end
  
  def readValue(reader,file)
    # read directory entry
    tag =  littleEndian(reader.readUInt16,2)
    type =  littleEndian(reader.readUInt16,2)
    count =  littleEndian(reader.readUInt32,4)
    case type
      when 1  # byte
        savePos = nil
        if count > 4
          nextPos = littleEndian(reader.readUInt32,4)
          savePos = file.pos
          file.pos = nextPos
        end
        value = []
        count.times { value << reader.readByte }
        if count <= 4
          (4-count).times { reader.readByte }
        else # count > 4
          file.pos = savePos
        end
      when 2  # ascii
        savePos = nil
        if count > 4
          nextPos = littleEndian(reader.readUInt32,4)
          savePos = file.pos
          file.pos = nextPos
        end
        value = reader.readString
        if count <= 4
          (4-count).times { reader.readByte }
        else # count > 4
          file.pos = savePos
        end
      when 3  # short
        savePos = nil
        if count > 2
          nextPos = littleEndian(reader.readUInt32,4)
          savePos = file.pos
          file.pos = nextPos
        end
        value = []
        count.times { value << littleEndian(reader.readUInt16,2) }
        if count <= 2
          (2-count).times { reader.readUInt16 }
        else # count > 2
          file.pos = savePos
        end
      when 4  # long
        savePos = nil
        if count > 1
          nextPos = littleEndian(reader.readUInt32,4)
          savePos = file.pos
          file.pos = nextPos
        end
        value = []
        count.times { value << littleEndian(reader.readUInt32,4) }
        if count > 1
          file.pos = savePos
        end
      when 5  # rational
        nextPos = littleEndian(reader.readUInt32,4)
        savePos = file.pos
        file.pos = nextPos
        value = []
        count.times do | ratPos |
          numer =  littleEndian(reader.readUInt32,4)
          denom =  littleEndian(reader.readUInt32,4)
          denom = 1 if denom == 0
          value << numer.to_f / denom
        end
        file.pos = savePos
      when 6  # sbyte
        savePos = nil
        if count > 4
          nextPos = littleEndian(reader.readUInt32,4)
          savePos = file.pos
          file.pos = nextPos
        end
        value = []
        count.times { value << reader.readByte }
        if count <= 4
          (4-count).times { reader.readByte }
        else # count > 4
          file.pos = savePos
        end
        value.each_with_index do | index |
          curr = value[index]
          value[index] = -1 - (255 - curr) if curr >= 128
        end
      when 7  # undefined
        reader.readUInt32  # gobble val/offset
        value = nil # ignore the undefine type
      when 8  # sshort
        savePos = nil
        if count > 2
          nextPos = littleEndian(reader.readUInt32,4)
          savePos = file.pos
          file.pos = nextPos
        end
        value = []
        count.times { value << littleEndian(reader.readInt16,2) }
        if count <= 2
          (2-count).times { reader.readUInt16 }
        else # count > 2
          file.pos = savePos
        end
      when 9  # slong
        savePos = nil
        if count > 1
          nextPos = littleEndian(reader.readUInt32,4)
          savePos = file.pos
          file.pos = nextPos
        end
        value = []
        count.times { value << littleEndian(reader.readInt32,4) }
        if count > 1
          file.pos = savePos
        end
      when 10 # srational
        nextPos = littleEndian(reader.readUInt32,4)
        savePos = file.pos
        file.pos = nextPos
        value = []
        count.times do | ratPos |
          numer =  littleEndian(reader.readInt32,4)
          denom =  littleEndian(reader.readInt32,4)
          denom = 1 if denom == 0
          value << numer.to_f / denom
        end
        file.pos = savePos
      when 11 # float - 4 byte
        savePos = nil
        if count > 1
          nextPos = littleEndian(reader.readUInt32,4)
          savePos = file.pos
          file.pos = nextPos
        end
        value = []
        count.times do | i |
          value << reader.readFloat32  # TODO : ENDIAN SWAP NEEDED?
        end
        file.pos = savePos if count > 1
      when 12 # double - 8 byte
        nextPos = littleEndian(reader.readUInt32,4)
        savePos = file.pos
        file.pos = nextPos
        value = []
        count.times do | i |
          value << reader.readFloat64  # TODO : ENDIAN SWAP NEEDED?
        end
        file.pos = savePos
      else
        reader.readUInt32  # gobble val/offset
        value = nil # ignore the unknown type
    end
    [tag,value]
  end

  def getBit
    if @leftoverBits.length == 0
      byte = @pixelBytes[@pixelByteNum]
      @pixelByteNum += 1
      if @fillOrder == 1
        @leftoverBits = [byte[7],byte[6],byte[5],byte[4],byte[3],byte[2],byte[1],byte[0]]
      else
        @leftoverBits = [byte[0],byte[1],byte[2],byte[3],byte[4],byte[5],byte[6],byte[7]]
      end
    end
    @leftoverBits.shift
  end
  
  def morePixelData
    @pixelByteNum < @pixelBytes.length or @leftoverBits.length > 0
  end

  def clearBitBuffer
    @leftoverBits = []
  end
  
  def decodeBits(bitCount)
    # see if we are getting a byte aligned request
    if (@leftoverBits.length == 0)
      case bitCount
        when 8
          byte1 = @pixelBytes[@pixelByteNum]
          @pixelByteNum += 1
          return byte1
        when 16
          byte1 = @pixelBytes[@pixelByteNum]
          @pixelByteNum += 1
          byte2 = @pixelBytes[@pixelByteNum]
          @pixelByteNum += 1
          if @bigEndian
            return (byte1 << 8) | byte2
          else
            return (byte2 << 8) | byte1
          end
        when 24
          byte1 = @pixelBytes[@pixelByteNum]
          @pixelByteNum += 1
          byte2 = @pixelBytes[@pixelByteNum]
          @pixelByteNum += 1
          byte3 = @pixelBytes[@pixelByteNum]
          @pixelByteNum += 1
          return (byte1 << 16) | (byte2 << 8) | byte3
        when 32
          byte1 = @pixelBytes[@pixelByteNum]
          @pixelByteNum += 1
          byte2 = @pixelBytes[@pixelByteNum]
          @pixelByteNum += 1
          byte3 = @pixelBytes[@pixelByteNum]
          @pixelByteNum += 1
          byte4 = @pixelBytes[@pixelByteNum]
          @pixelByteNum += 1
          if @bigEndian
            return (byte1 << 24) | (byte2 << 16) | (byte3 << 8) | byte4
          else
            return (byte4 << 24) | (byte3 << 16) | (byte2 << 8) | byte1
          end
      end
    end
    # else fall through to here: not a byte aligned bit request
    bits = 0
    bitCount.times do | bitNum |
      bits = (bits << 1) | getBit
    end
    bits
  end

  def decodePixel
    pixel = 0
    @pixelTemplate.length.times do | sampleNum |
      sample = decodeBits(@pixelTemplate[sampleNum])
      if sampleNum < @pixelChannels
        pixel << @pixelTemplate[sampleNum-1] if sampleNum > 0
        pixel |= sample
      end
    end
    pixel
  end

  def decodePixels(bytes,maxCols)
    @pixelBytes = bytes
    @pixelByteNum = 0
    pixels = []
    col = 0
    while morePixelData
      pixels << decodePixel
      col += 1
      if col == maxCols
        clearBitBuffer
        col = 0
      end
    end
    pixels
  end
  
  def name
    "TIFF 6.0"
  end
  
  def help(verbose)
    if verbose
      ["TIF - TIFF 6.0 compatible image file",
       "",
       "  To invoke from the command line type itif(file) or itif(path~file)",
       "  The file specification can contain wildcards such as *.tif"
      ]
    else
      ["TIF - TIFF 6.0 compatible image file"]
    end
  end

  def readImage(engine,imageArgs,imageInstance)
    image = nil
    
    # open file
    
    if imageArgs.nil? or (imageArgs.length != 1 and imageArgs.length != 2)
      raise("Incorrect image args: "+imageArgs+"  Expected an optional path and a filename.")
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
      extPresent = true if fileName =~ /.*\.tif$/i
      fileName += ".tif" if not extPresent
      if not FileTest.exists?(fileName)
        raise("Input file " + fileName + " does not exist!")
      end
    end

    imageInstance.fileName = fileName
    
    file = File.open(fileName)
    file.binmode

    reader = BinaryReader.new(file)

    # read header variables
    byteOrder = reader.readUInt16
    if (byteOrder != 0x4949) and (byteOrder != 0x4D4D)
      raise("Input file " + fileName + " is not a TIFF 6.0 compatible file.")
    end

    @bigEndian = (byteOrder==0x4D4D)
    lifeTheUniverseAndEverything = littleEndian(reader.readUInt16,2)
    if (lifeTheUniverseAndEverything != 42)
      raise("Input file " + fileName + " is not a TIFF 6.0 compatible file.")
    end

    # seek to the IFD
    file.pos = littleEndian(reader.readUInt32,4)
    
    # read the IFD
    tags = {}
    numDirEntries = littleEndian(reader.readUInt16,2)
    numDirEntries.times do | dirEntry |
      pair = readValue(reader,file)
      tag = pair[0]
      value = pair[1]
      if value
        tags[tag] = value
      end
    end
    
    # determine if header is well-formed
    if not tags[TImageWidth] or not tags[TImageLength]
      raise("Bad TIFF file " + fileName + ": number of rows/cols cannot be determined.")
    end

    # reject planar image files : not baseline tiff
    if tags[TPlanarConfiguration] and tags[TPlanarConfiguration][0] == 2
      raise("TIFF file "+fileName+" is planar. This is unsupported.")
    end
    
    # determine what kind of image we have
    stripped = false
    tiled = false
    if (tags[TStripOffsets] and tags[TRowsPerStrip] and tags[TStripByteCounts])
      stripped = true
      #print("STRIPPED\n")
    end
    if (tags[TTileWidth] and tags[TTileLength] and tags[TTileOffsets] and
        tags[TTileByteCounts])
      tiled = true
      #print("TILED\n")
    end
    if (stripped and tiled) or (not stripped and not tiled)
      raise("Bad TIFF file " + fileName + ": image data cannot be found.")
    end
      
    # set default values    
    @pixelTemplate = [1]  # bitsPerSample defaults to 1
    compression = 1
    @fillOrder = 1
    orientation = 1
    samplesPerPixel = 1
    rowsPerStrip = 2**32 - 1
    extraSamples = 0
    
    #print(fileName,"\n")
    #print("  Bits per sample: ",tags[TBitsPerSample].join(':'),"\n")
    #print("  Compression: ",tags[TCompression],"\n")
    #print("  Fill order: ",tags[TFillOrder],"\n")
    #print("  Orientation: ",tags[TOrientation],"\n")
    #print("  Samples per pixel: ",tags[TSamplesPerPixel],"\n")
    #print("  Rows per strip: ",tags[TRowsPerStrip],"\n")
    #print("  Extra samples: ",tags[TExtraSamples],"\n")
    #print("  Resolution unit: ",tags[TResolutionUnit],"\n")
    #print("\n")
    
    # now set values if needed
    @pixelTemplate = tags[TBitsPerSample] if tags[TBitsPerSample]
    compression = tags[TCompression][0] if tags[TCompression]
    fillOrder = tags[TFillOrder][0] if tags[TFillOrder]
    orientation = tags[TOrientation][0] if tags[TOrientation]
    samplesPerPixel = tags[TSamplesPerPixel][0] if tags[TSamplesPerPixel]
    rowsPerStrip = tags[TRowsPerStrip][0] if tags[TRowsPerStrip]
    extraSamples = tags[TExtraSamples].length if tags[TExtraSamples]
    resolutionUnit = tags[TResolutionUnit][0] if tags[TResolutionUnit]
       
    # determine if we support this type of TIFF : no LZW, no JPEG, no Huffman, etc.
    case compression
      when 1,32773
        # accept
      else
        raise("TIFF file " + fileName + " has unsupported compression.")
    end
    
    # determine dimensions
    tiffRows = tags[TImageLength][0]
    tiffCols = tags[TImageWidth][0]

    xformCoords = nil
    imageRows = nil
    imageCols = nil
    case orientation
      when 1
        xformCoords = Xform1
        imageRows = tiffRows
        imageCols = tiffCols
      when 2
        xformCoords = Xform2
        imageRows = tiffRows
        imageCols = tiffCols
      when 3
        xformCoords = Xform3
        imageRows = tiffRows
        imageCols = tiffCols
      when 4
        xformCoords = Xform4
        imageRows = tiffRows
        imageCols = tiffCols
      when 5
        xformCoords = Xform5
        imageRows = tiffCols
        imageCols = tiffRows
      when 6
        xformCoords = Xform6
        imageRows = tiffCols
        imageCols = tiffRows
      when 7
        xformCoords = Xform7
        imageRows = tiffCols
        imageCols = tiffRows
      when 8
        xformCoords = Xform8
        imageRows = tiffCols
        imageCols = tiffRows
      else
        raise("TIFF file " + fileName + " has an unknown orientation.")
    end

    # classify image
    @pixelChannels = samplesPerPixel - extraSamples
    if @pixelChannels <= 0
      raise("TIFF file " + fileName + " is incorrectly specified.")
    end

    bits = 0
    @pixelChannels.times { |channelNum| bits += @pixelTemplate[channelNum] }

    if bits == 1
      image = imageInstance.makeNewImage(imageRows,imageCols,1,engine)
    elsif bits <= 4
      image = imageInstance.makeNewImage(imageRows,imageCols,4,engine)
    elsif bits <= 8
      image = imageInstance.makeNewImage(imageRows,imageCols,8,engine)
    elsif bits <= 16
      image = imageInstance.makeNewImage(imageRows,imageCols,16,engine)
    elsif bits <= 24
      image = imageInstance.makeNewImage(imageRows,imageCols,24,engine)
    else # bits > 24
      raise("TIFF file " + fileName + " has more bitsPerPixel ("+bits.to_s+") than can be represented by IAN (24 max).")
    end
    
    pixelBuffer = []
    
    if stripped
      stripOffsets = tags[TStripOffsets]
      stripByteCounts = tags[TStripByteCounts]
      stripOffsets.length.times do | stripNum |
        file.pos = stripOffsets[stripNum]
        dataBytes = reader.readByte(stripByteCounts[stripNum])
        if compression == 1
          pixelBytes = dataBytes
        elsif compression == 32773
          pixelBytes = []
          byteNum = 0
          while byteNum < dataBytes.length
            code = dataBytes[byteNum] ; byteNum += 1
            if code.between?(0,127)
              (code+1).times { pixelBytes << dataBytes[byteNum] ; byteNum += 1 }
            else # 128 to 255 unsigned = -128 to -1 signed
              code = -1 - (255-code)
              if code != -128  # -128 == NoOp
                byte = dataBytes[byteNum] ; byteNum += 1 
                (0-code+1).times { pixelBytes << byte }
              end
            end
          end
        else  # compression != 1,32773
          # tested earlier : we should never get here
          raise("TIFF file : unsupported compression present.")
        end
        pixels = decodePixels(pixelBytes,tiffCols)
        rowsInStrip = rowsPerStrip
        rowsInStrip = tiffRows-(stripNum*rowsPerStrip) if stripNum == (stripOffsets.length-1)
        rowsInStrip = tiffRows if rowsPerStrip == (2**32 - 1)
        rowsInStrip.times do | rowOffset |
          tiffRow = stripNum*rowsPerStrip + rowOffset
          tiffCols.times do | tiffCol |
            pixel = pixels.shift
            coords = xformCoords.call(tiffRow,tiffCol,tiffRows-1,tiffCols-1)
            row = coords[0]
            col = coords[1]
            image.setCell(row,col,pixel)
            
          end # each col in strip
        end  # each row in strip
      end  # each strip
    end  # if stripped

    if tiled
      tileWidth = tags[TTileWidth][0]
      tileLength = tags[TTileLength][0]
      tilesAcross = (tiffCols + tileWidth - 1) / tileWidth
      tilesDown = (tiffRows + tileLength - 1) / tileLength
      tileByteCounts = tags[TTileByteCounts]
      tileOffsets = tags[TTileOffsets]
      tileOffsets.length.times do | tileNum |
        file.pos = tileOffsets[tileNum]
        dataBytes = reader.readByte(tileByteCounts[tileNum])
        if compression == 1
          pixelBytes = dataBytes
        elsif compression == 32773
          pixelBytes = []
          byteNum = 0
          while byteNum < dataBytes.length
            code = dataBytes[byteNum] ; byteNum += 1
            if code.between?(0,127)
              (code+1).times { pixelBytes << dataBytes[byteNum] ; byteNum += 1 }
            else # 128 to 255 unsigned = -128 to -1 signed
              code = -1 - (255-code)
              if code != -128  # -128 == NoOp
                byte = dataBytes[byteNum] ; byteNum += 1 
                (0-code+1).times { pixelBytes << byte }
              end
            end
          end
        else  # compression != 1,32773
          # tested earlier : we should never get here
          raise("TIFF file : unsupported compression present.")
        end
        pixels = decodePixels(pixelBytes,tileWidth)
        tileRow = tileNum / tilesAcross
        tileCol = tileNum % tilesAcross
        startRow = tileRow*tileLength
        startCol = tileCol*tileWidth
        rowsToDo = tileLength
        rowsToDo = tiffRows if rowsToDo == 2**32 - 1
        if tileRow == tilesDown - 1 # last tile row may be padded
          rowsToDo = tiffRows % tileLength
          # found a bug where a one tile image with rows == tileLength calcs rowsToDo == 0
          rowsToDo = tileLength if rowsToDo == 0
        end
        rowsToDo.times do | rowOffset |
          tiffRow = startRow + rowOffset
          colsToDo = tileWidth
          colsToDo = tiffCols if colsToDo == 2**32 - 1
          if tileCol == tilesAcross - 1 # last tile col may be padded
            colsToDo = tiffCols % tileWidth
            # found a bug where a one tile image with cols == tileWid calcs colsToDo == 0
            colsToDo = tileWidth if colsToDo == 0
          end
          colsToDo.times do | colOffset |
            tiffCol = startCol + colOffset
            pixel = pixels.shift
            coords = xformCoords.call(tiffRow,tiffCol,tiffRows-1,tiffCols-1)
            row = coords[0]
            col = coords[1]
            image.setCell(row,col,pixel)
            
          end # each col
          
          # gobble extra pixels on end of tile
          (colsToDo+1).upto(tileWidth)  { pixels.shift }
          
        end # each row
      end # each tile
    end  # if tiled

    # close file
    file.close

    # set title if present
    image.title = tags[TImageDescription][0] if tags[TImageDescription]

    # set units
    case tags[TResolutionUnit]
      when nil,2
        imageInstance.distUnit.unit = Units.find("inch")
        if tags[TXResolution] and tags[TXResolution][0] != 0.0
          imageInstance.distUnit.factor = 1.0 / tags[TXResolution][0]
        elsif tags[TYResolution] and tags[TYResolution][0] != 0.0
          imageInstance.distUnit.factor = 1.0 / tags[TYResolution][0]
        else
          imageInstance.distUnit.factor = 1.0
        end
        imageInstance.areaUnit.unit = Units.find("square inch")
        imageInstance.areaUnit.factor = imageInstance.distUnit.factor * imageInstance.distUnit.factor
      when 3
        imageInstance.distUnit.unit = Units.find("centimeter")
        if tags[TXResolution] and tags[TXResolution][0] != 0.0
          imageInstance.distUnit.factor = 1.0 / tags[TXResolution][0]
        elsif tags[TYResolution] and tags[TYResolution][0] != 0.0
          imageInstance.distUnit.factor = 1.0 / tags[TYResolution][0]
        else
          imageInstance.distUnit.factor = 1.0
        end
        imageInstance.areaUnit.unit = Units.find("square centimeter")
        imageInstance.areaUnit.factor = imageInstance.distUnit.factor * imageInstance.distUnit.factor
      else
        # do nothing : cells
    end
    
    # set palette entries if b&w/gray
    interp = tags[TPhotometricInterpretation]
    if interp
      if interp[0] == 0
        image.palette[0] = 0x00ffffff
        image.palette[1] = 0
      elsif interp[0] == 1
        image.palette[0] = 0
        image.palette[1] = 0x00ffffff
      end
    end
    
    # set palette if color map present
    colorMap = tags[TColorMap]
    if colorMap
      colors = colorMap.length/3
      colors.times do | colorNum |
        red   = ((colorMap[colorNum] / 65535.0) * 255).round
        green = ((colorMap[colors+colorNum] / 65535.0) * 255).round
        blue  = ((colorMap[2*colors+colorNum] / 65535.0) * 255).round
        color = (red << 16) | (green << 8) | (blue)
        image.palette[colorNum] = color
      end
    end

    # return image
    image
  end
  
  def writeImage(engine,image,imageArgs)
  end

end