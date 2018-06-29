
# Unknown right now: how are pixels packed when they are not on byte boundaries
#   like 1 bit, 4 bit, 10 bit, 12 bit, etc.  Msb or lsb first? Two 12 bit =
#   3 bytes or 4 bytes? Therefore we won't support yet.

require InstallPath + 'BinaryReader.rb'


class ImageConverter

  def name
    "Arc BIL/BIP/BSQ"
  end
  
  def help(verbose)
    if verbose
      ["HDR - ARC compatible BIL/BIP/BSQ",
       "",
       "  To invoke from the command line type ihdr(file) or ihdr(path~file)",
       "  The file specification can contain wildcards such as *.hdr"
      ]
    else
      ["HDR - ARC BIL/BIP/BSQ"]
    end
  end

  def readImage(engine,imageArgs,imageInstance)

    if imageArgs.nil? or ((imageArgs.length != 1) and (imageArgs.length != 2))
      raise("Incorrect image args: " + imageArgs.join(",") + "  Expected optional path, and header filename")
      return nil
    end

    # imageArgs: optional path, hdr file
    
    image = nil

    path = nil
    if imageArgs.length == 1
      headerFileName = imageArgs[0]
    else # == 2
      path = imageArgs[0]
      last = path.length-1
      if path.length > 0 and path[last,1] != "\\" and path[last,1] != ":"
        path = path + '\\'
      end
      headerFileName = path + imageArgs[1]
    end

    imageInstance.fileName = headerFileName
    
    rows = 0
    cols = 0
    layout = "bil"
    planesPerPixel = 1
    bitsPerPlane = 8
    imageEndian = "LITTLE"  # assuming the program is running on Windows
    headerBytes = 0
    bandRowBytes = nil
    totalRowBytes = nil
    bandGapBytes = 0

    File.open(headerFileName) do | file |

      while not file.eof
        line = file.readline.downcase
        case line
          when /nrows\s*(\w+)/
            rows = $1.to_i
          when /ncols\s*(\w+)/
            cols = $1.to_i
          when /nbands\s*(\w+)/
            planesPerPixel =  $1.to_i
          when /nbits\s*(\w+)/
            bitsPerPlane =  $1.to_i
          when /byteorder\s*(\w+)/
            byteOrder = $1
            case byteOrder.upcase
              when 'I'
                imageEndian = "LITTLE"
              when 'M'
                imageEndian = "BIG"
              else
                raise("Unknown byteorder in HDR file: " +byteOrder+ " in "+headerFileName)
            end
            # bug: need to remember to record endian of current platform
          when /layout\s*(\w+)/
            layout = $1.downcase
          when /skipbytes\s*(\d+)/
            headerBytes = $1.to_i
          when /bandrowbytes\s*(\d+)/
            bandRowBytes = $1.to_i
          when /totalrowbytes\s*(\d+)/
            totalRowBytes = $1.to_i
          when /bandgapbytes\s*(\d+)/
            bandGapBytes = $1.to_i
          else
            # unknown header entry: skip
        end
      end

    end # file open block
    
    if (rows == 0) or (cols == 0)  # assume we couldn't read the file
      raise("Invalid HDR file: not ARC compatible")
    end
    
    case layout.downcase
      when "bil","bip","bsq"
        # accept
      else # reject
        raise("Error in HDR file: unknown file layout : "+layout)
    end
    
    bitsPerPixel = bitsPerPlane * planesPerPixel
    if (bitsPerPixel > 24)
      raise("Error in HDR file: pixel layouts > 24 bits not supported")
    end
    
    case bitsPerPlane
      when 8,16,24
        # accept
      else # reject
        # likely values: 1, 4, 10, 12
        # currently rejecting 1 and 4 cuz I don't know how they are layed out
        raise("Error in HDR file: pixel layouts of "+bitsPerPlane.to_i.to_s+" bits per plane not supported")
    end
    
    image = imageInstance.makeNewImage(rows,cols,bitsPerPixel,engine)
    
    # see if data file name is present using no extension, or layout variable
    
    headerFileName =~ /^(.*)\.hdr$/i
    base = $1
    dataFileName = base + "." + layout
    if not FileTest.exists?(dataFileName)
      dataFileName = base
      if not FileTest.exists?(dataFileName)
        raise("Image data file not found for HDR file: "+headerFileName)
      end
    end
    
    File.open(dataFileName) do | file |
    
      file.binmode
    
      reader = BinaryReader.new(file)

      reader.readByte(headerBytes)  # usually 0 bytes
    
      case layout.downcase
        when "bil"
          bandRowBytes = (cols*bitsPerPlane)/8 if not bandRowBytes
          totalRowBytes = planesPerPixel*bandRowBytes if not totalRowBytes
          case bitsPerPlane
            when 8
              (rows-1).downto(0) do | row |
                planesPerPixel.times do | plane |
                  cols.times do | col |
                    bandVal = reader.readByte
                    pix = image.getCell(row,col)
                    pix |= bandVal << (8*plane)
                    image.setCell(row,col,pix)
                  end
                end
                reader.readByte(bandRowBytes-cols)
                reader.readByte(totalRowBytes-(planesPerPixel*bandRowBytes))
              end
            when 16
              # planesPerPixel must be 1
              (rows-1).downto(0) do | row |
                cols.times do | col |
                  pix = reader.readUInt16
                  if imageEndian != "LITTLE"
                    pix = ((pix & 0xff00) >> 8) | ((pix & 0x00ff) << 8)
                  end
                  image.setCell(row,col,pix)
                end
                reader.readByte(bandRowBytes-(cols*2))
                reader.readByte(totalRowBytes-bandRowBytes)
              end
            when 24
              # planesPerPixel must be 1
              (rows-1).downto(0) do | row |
                cols.times do | col |
                  pix = (reader.readUInt16 << 8) | (reader.readByte)
                  image.setCell(row,col,pix)
                end
                reader.readByte(bandRowBytes-(cols*3))
                reader.readByte(totalRowBytes-bandRowBytes)
              end
          end
        when "bip"
          totalRowBytes = (cols*bitsPerPixel)/8 if not totalRowBytes
          case bitsPerPlane
            when 8
              (rows-1).downto(0) do | row |
                cols.times do | col |
                  planesPerPixel.times do | plane |
                    bandVal = reader.readByte
                    pix = image.getCell(row,col)
                    pix |= bandVal << (8*plane)
                    image.setCell(row,col,pix)
                  end
                end
                reader.readByte(totalRowBytes-(cols*planesPerPixel))
              end
            when 16
              # planesPerPixel must be 1
              (rows-1).downto(0) do | row |
                cols.times do | col |
                  pix = reader.readUInt16
                  if imageEndian != "LITTLE"
                    pix = ((pix & 0xff00) >> 8) | ((pix & 0x00ff) << 8)
                  end
                  image.setCell(row,col,pix)
                end
                reader.readByte(totalRowBytes-(cols*2))
              end
            when 24
              # planesPerPixel must be 1
              (rows-1).downto(0) do | row |
                cols.times do | col |
                  pix = (reader.readUInt16 << 8) | (reader.readByte)
                  image.setCell(row,col,pix)
                end
                reader.readByte(totalRowBytes-(cols*3))
              end
          end
        when "bsq"
          totalRowBytes = cols if not totalRowBytes
          case bitsPerPlane
            when 8
              planesPerPixel.times do | plane |
                (rows-1).downto(0) do | row |
                  cols.times do | col |
                    bandVal = reader.readByte
                    pix = image.getCell(row,col)
                    pix |= bandVal << (8*plane)
                    image.setCell(row,col,pix)
                  end
                  reader.readByte(totalRowBytes - cols)
                end
                reader.readByte(bandGapBytes)
              end
            when 16
              # planesPerPixel must be 1
              (rows-1).downto(0) do | row |
                cols.times do | col |
                  pix = reader.readUInt16
                  if imageEndian != "LITTLE"
                    pix = ((pix & 0xff00) >> 8) | ((pix & 0x00ff) << 8)
                  end
                  image.setCell(row,col,pix)
                end
                reader.readByte(totalRowBytes - (cols*2))
              end
              reader.readByte(bandGapBytes)
            when 24
              # planesPerPixel must be 1
              (rows-1).downto(0) do | row |
                cols.times do | col |
                  pix = (reader.readUInt16 << 8) | (reader.readByte)
                  image.setCell(row,col,pix)
                end
                reader.readByte(totalRowBytes - (cols*3))
              end
              reader.readByte(bandGapBytes)
          end
        # no else needed, tested earlier
      end

    end  # end file open block
    
    image

  end

  def writeImage(engine,image,imageArgs)
  end

end

