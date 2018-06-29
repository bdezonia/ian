
#output like this:
#  class, metric a, metric b, metric c, etc.
#  water,0,0,1
#  scrub,1,1,1

require InstallPath + "BinaryWriter.rb"

class ReportWriter

  def name
    "dBASE format [class metrics only] (.DBF)"
  end
  
  def help(verbose)
    if verbose
      ["RDBF - DBF format (dBASE)",
       "",
       "  This report is a dBASE 3 compatible binary format. Only class measures",
       "  are reported. Image measures and interclass measures are ignored.",
      ]
    else
      ["RDBF - DBF format (dBASE)"]
    end
  end
  
  def outName
    @outfile
  end

  def run(engine,options,image,analysesOutput,args,verbose)
    
    if image.nil?
      engine.error("DBF report writer did not receive an image to process")
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
        fileName += ".dbf"
      when 1
        fileName = args[0]
      when 2
        fileName = args[0]
        fileName = fileName + "\\" if fileName[fileName.length-1] != "\\"
        fileName = fileName + args[1]
      else
        engine.error("Too many arguments to DBF report.")
        return
    end
    
    # if no extension specified apply .dbf
    fileName += ".dbf" if not fileName =~ /.*\.\w+$/
    
    @outfile = fileName

    # gather output rows
    metrics = []
    analysesOutput.each do | analysisOutput |
      if analysisOutput.outType == AnalysisType::CLASS
        if not metrics.find {|metric| metric.abbrev == analysisOutput.abbrev}
          metrics << analysisOutput
        end
      end
    end
    if metrics.length == 0
      error("DBF report requires class measures to be specified during analysis.")
    end
    
    colors = []
    metrics.each do | metricOutput |
      metricOutput.output.each_key do | color |
        colors << color
      end
    end
    colors = colors.uniq.sort
    
    # set local constants
    cnameFieldLength = 40
    dataFieldLength = 12 # is this okay?

    # open file
    outData = File.new(fileName,"w")
    outData.binmode
    binWriter = BinaryWriter.new(outData)
    
    # basic header info
    
    binWriter.writeByte(3)   # identify version of file : dbase 3
    binWriter.writeByte(104) # date year : 1900 + 104 = 2004
    binWriter.writeByte(8)   # date month : august
    binWriter.writeByte(20)  # date day : 20th
    binWriter.writeUInt32(colors.length)  # num records
    # 32 byte records: header + classname col + metrics : final +1 for eoheader marker
    binWriter.writeUInt16(32*(1 + 1 + metrics.length)+1)  # header byte size
    # the following +1 is for the space that separates each record
    binWriter.writeUInt16(1 + cnameFieldLength + metrics.length*dataFieldLength)
    13.upto(32) { binWriter.writeByte(0) }
    
    # first field description record
    
    binWriter.writeChars("CLASS")
    6.times { binWriter.writeByte(0) }
    binWriter.writeChars("C")
    binWriter.writeUInt32(0)
    binWriter.writeByte(cnameFieldLength)
    binWriter.writeByte(0)                 # field decimal places
    19.upto(32) { binWriter.writeByte(0) }
    
    # other field description records
    
    metrics.each do | metricOutput |
      name = metricOutput.abbrev
      name = name[0,10] if name.length > 10
      name = name.upcase
      binWriter.writeChars(name)
      (name.length+1).upto(11) { binWriter.writeByte(0) }
      binWriter.writeChars("N")
      binWriter.writeUInt32(0)
      binWriter.writeByte(dataFieldLength)
      # field decimal places
      binWriter.writeByte(metricOutput.precision)
      19.upto(32) { binWriter.writeByte(0) }
    end
    
    # end of header sentinel
    
    binWriter.writeByte(0x0d)
    
    # actual record data follows
    colors.each do | color |
      # write class name as first output field
      name = image.file.legend[color]
      name = "Class " + color.to_s if not name
      name = name[0,cnameFieldLength] if name.length > cnameFieldLength
      binWriter.writeChars(" ")  # unknown why this is needed but it is
      binWriter.writeChars(name)
      (name.length+1).upto(cnameFieldLength) { binWriter.writeChars(" ") }
      
      # write the metric results as
      metrics.each do | metricOutput |
        value = metricOutput.output[color]
        value = 0 if not value
        if (metricOutput.precision == 0)
          vString = value.to_i.to_s
        else
          vString = sprintf("%.#{metricOutput.precision}f",value)
        end
        vString = vString[0,dataFieldLength] if vString.length > dataFieldLength
        while vString.length != dataFieldLength
          vString = " " + vString
        end
        binWriter.writeChars(vString)
      end
    end
    
    # write EOF marker
    binWriter.writeByte(0x1a)
    
    # close file
    outData.close
    
  end
end
