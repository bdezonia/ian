# Google Search: how do I ruby read binary float

#            Search Result 1
#      From: Michael Neumann (neumann@s-direktnet.de)
#      Subject: Re: Howto read binary data? 
#            View: Complete Thread (3 articles) 
#            Original Format
#      Newsgroups: comp.lang.ruby
#      Date: 2001-10-23 06:31:08 PST 


BufferSize = 32768

#Martin Kahlert wrote:
#> Hi!
#> I want to read a file containing double values in binary representation,
#> i.e. they have been written from C using
#> 
#> double variable;
#> write(fd, &variable, sizeof(variable));

#For this purpose, I wrote some time ago a class BinaryReader:

class BinaryReader

  DEF = [ 
    [ :Byte,   1, 'C' ],  # or b or B : bug?

    [ :Int16,  2, 's' ],
    [ :UInt16, 2, 'S' ],

    [ :Int32,    4, 'i' ],
    [ :UInt32,   4, 'I' ],

    [ :Float32,  4, 'f' ],
    [ :Float64, 8, 'd' ]
  ]

  DEF.each do |meth, size, format|
    eval %{
      def read#{ meth }(n = 1)
        _read(n, #{size}, '#{ format }')
      end
    }
  end

  def readChar
    @handle.readchar.chr
  end

  def readString(len=0)
    string = ""
    if len
      len.times { | i | string += readChar }
    else  # len == 0 : read until null char found
      string = handle.gets('\0')
    end
    string
  end

  def initialize( handle )
    @handle = handle
  end

  private

  def _read(n, size, format)
    bytes = n * size

    str = @handle.read(bytes)
    raise "failure during read" if str.nil? or str.size != bytes 

    val = str.unpack(format * n) 

    if n == 1
      val.first
    else
      val
    end
  end

end


#You can use this as follows:
#
#
#  file = File.new(...)
#  file.binary       # only neccessary on Windows 
#  reader = BinaryReader.new( file )
#
#  aFloat = reader.read_float
#  int1, int2 = reader.read_int(2)   # read two integers
#  # ... read_double, read_ushort etc..
#

#Regards,
#
#  Michael
#
#> How can i read this file from ruby and stuff the data into a ruby double
#> variable? (The file has been built on the same machine, so endianess should
#> not be a problem).
#
#See Array#pack and String#unpack.
#
#Regards,
#
#  Michael


#-- 
#Michael Neumann
#merlin.zwo InfoDesign GmbH
#http://www.merlin-zwo.de
#
#
#
#      Google Home - Advertise with Us - Business Solutions - Services & Tools - 
#      Jobs, Press, & Help
#
#©2003 Google
#
#
#
