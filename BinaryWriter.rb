
class BinaryWriter
  def initialize(binFile)
    @file = binFile
  end
  def writeByte(byte)
    @file << [byte].pack("C")
  end
  def writeInt16(int)
    @file << [int].pack("s")
  end
  def writeUInt16(int)
    @file << [int].pack("S")
  end
  def writeInt32(int)
    @file << [int].pack("l")
  end
  def writeUInt32(int)
    @file << [int].pack("L")
  end
  def writeFloat32(float)
    @file << [float].pack("f")
  end
  def writeFloat64(float)
    @file << [float].pack("d")
  end
  def writeChars(string)
    @file << [string].pack("A#{string.length}")
  end
  def writeCString(string)
    writeChars(string)
    writeByte(0)
  end
end

