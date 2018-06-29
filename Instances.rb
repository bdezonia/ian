
require InstallPath + 'ImageCreator.rb'
require InstallPath + 'MethodRemover.rb'

class Instance
  def initialize(argList)
    @type = argList.type
    @args = argList.args
  end
  
  attr_reader(:type,:args)
end

class OptionSummary

  def initialize(abbrev,name,args)
    @abbrev = abbrev
    @name = name
    @args = args  # an array of args
  end
  
  attr_reader(:abbrev,:name,:args)
  
  def value
    if @args.length == 1
      @args[0]
    else
      @args
    end
  end
  
  def dig_to_i(digString)
    if digString =~ /^(\+|\-)?0x.*$/i     # hex
      digString.hex
    elsif digString =~ /^(\+|\-)?0b(.*)$/i  # binary
      sign = $1
      binDigit = $2
      sum = 0
      0.upto(binDigit.length-1) do | index |
        sum *= 2
        case binDigit[index,1]
          when "1"
            sum += 1
          when "0"
            # do nothing
          else
            sum = -sum if sign == "-"
            return sum
        end
      end
      sum = -sum if sign == "-"
      sum
    elsif digString =~ /^(\+|\-)?0.*$/    # octal
      digString.oct
    else                      # decimal
      digString.to_i
    end
  end
  
end

class OptionList
  def initialize
    @optionSums = []
  end
  
  def add(optionSummary)
    @optionSums << optionSummary
  end
  
  def find(optionName)
    @optionSums.each do | optionSum |
      return optionSum if optionSum.name == optionName
    end
    nil
  end
end

class OptionInstance < Instance
  def initialize(argList)
    super(argList)
  end
  
  def create(engine)
    # create filename to correct ruby file for option using @type
    filename = InstallPath + "options\\" + type + ".rb"
    if not FileTest.exists?(filename)
      engine.error("Option -" + type + " cannot be created. " + filename + " does not exist.")
    end
    load filename
    option = Option.new
    if not option.respond_to? :name
      engine.error("Option "+filename+" has not implemented the name method.")
    elsif option.method(:name).arity != 0
      engine.error("Option "+filename+"'s name method must not take any parameters.")
    end
    if not option.respond_to? :help
      engine.error("Option "+filename+" has not implemented the help method.")
    elsif option.method(:help).arity != 1
      engine.error("Option "+filename+"'s help method must take 1 parameter.")
    end
    output = OptionSummary.new(type,option.name,args)
    MethodRemover.new("Option").run
    output
  end
end

class AnalysisInstance < Instance
  def initialize(argList)
    super(argList)
  end
  
  attr_accessor(:type)
  
  def run(engine,options,image,distUnit,areaUnit)
    #create filename to correct ruby file for analysis using @type
    filename = InstallPath + "analyses\\" + type + ".rb"
    if not FileTest.exists?(filename)
      engine.error("Analysis a" + type + " cannot be run. " + filename + " does not exist.")
    end
    load filename
    an = Analysis.new(engine,options,image,distUnit,areaUnit,args)
    if not an.respond_to? :run
      engine.error("Analysis "+filename+" has not implemented the run method.")
    elsif an.method(:run).arity != 0
      engine.error("Analysis "+filename+"'s run method must not take any parameters.")
    end
    if not an.respond_to? :help
      engine.error("Analysis "+filename+" has not implemented the help method.")
    elsif an.method(:help).arity != 1
      puts an.method(:help).arity
      engine.error("Analysis "+filename+"'s help method must take one parameter.")
    end
    if not an.respond_to? :name
      engine.error("Analysis "+filename+" has not implemented the name method.")
    elsif an.method(:name).arity != 0
      engine.error("Analysis "+filename+"'s name method must not take any parameters.")
    end
    if not an.respond_to? :outType
      engine.error("Analysis "+filename+" has not implemented the outType method.")
    elsif an.method(:outType).arity != 0
      engine.error("Analysis "+filename+"'s outType method must not take any parameters.")
    end
    engine.statement("Running analysis: " + an.name)
#    clug1 = Time.now
    output = an.run
    MethodRemover.new("Analysis").run
#    clug2 = Time.now
#    engine.statement("Elapsed time : " + (clug2-clug1).to_s + " secs")
    output
  end
end

class ReportInstance < Instance
  def initialize(argList,verbose)
    super(argList)
    @verbose = verbose
  end
  
  attr_reader(:verbose)
  
  def run(engine,options,image,output)
    # create filename to correct ruby file for report using type
    filename = InstallPath + "reports\\" + type + ".rb"
    if not FileTest.exists?(filename)
      engine.error("Report r" + type + " cannot be run. " + filename + " does not exist.")
    end
    load filename
    reporter = ReportWriter.new
    if not reporter.respond_to? :help
      engine.error("ReportWriter "+filename+" has not implemented the help method.")
    elsif reporter.method(:help).arity != 1
      engine.error("ReportWriter "+filename+"'s help method must be defined to take 1 parameter.")
    end
    if not reporter.respond_to? :run
      engine.error("ReportWriter "+filename+" has not implemented the run method.")
    elsif reporter.method(:run).arity != 6
      engine.error("ReportWriter "+filename+"'s run method must be defined to take 6 parameters.")
    end
    if not reporter.respond_to? :outName
      engine.error("ReportWriter "+filename+" has not implemented the outName method.")
    elsif reporter.method(:outName).arity != 0
      engine.error("ReportWriter "+filename+"'s outName method must be defined to take 0 parameters.")
    end
    engine.statement("Writing report: " + reporter.name)
    reporter.run(engine,options,image,output,args,@verbose)
    engine.statement("Report written: " + reporter.outName) if reporter.outName
    MethodRemover.new("ReportWriter").run
  end
  
end

class ImageInstance < Instance

  def initialize(argList)
    super(argList)
    @imageConv = nil
    @file = nil
    @distUnit = UnitHolder.new
    @areaUnit = UnitHolder.new
    @bitsPerPix = nil
    @fileName = nil
  end
  
  attr_accessor(:imageConv,:file,:distUnit,:areaUnit,:bitsPerPix,:fileName)
  
  # create loads the correct imageConverter and calls readImage
  
  def create(engine)
    # create filename to correct ruby file for image using @type
    filename = InstallPath + "imagetypes\\" + type + ".rb"
    if not FileTest.exists?(filename)
      engine.error("Image type i" + type + " cannot be loaded. " + filename + " does not exist.")
    end
    load filename
    @imageConv = ImageConverter.new
    if not @imageConv.respond_to? :name
      engine.error("Image converter "+filename+" has not implemented the name method.")
    elsif @imageConv.method(:name).arity != 0
      engine.error("Image converter "+filename+"'s name method must be defined to take no parameters.")
    end
    if not @imageConv.respond_to? :help
      engine.error("Image converter "+filename+" has not implemented the help method.")
    elsif @imageConv.method(:help).arity != 1
      engine.error("Image converter "+filename+"'s help method must be defined to take 1 parameter.")
    end
    if not @imageConv.respond_to? :readImage
      engine.error("Image converter "+filename+" has not implemented the readImage method.")
    elsif @imageConv.method(:readImage).arity != 3
      engine.error("Image converter "+filename+"'s readImage method must be defined to take 3 parameters.")
    end
    if not @imageConv.respond_to? :writeImage
      engine.error("Image converter "+filename+" has not implemented the writeImage method.")
    elsif @imageConv.method(:writeImage).arity != 3
      engine.error("Image converter "+filename+"'s writeImage method must be defined to take 3 parameters.")
    end
    engine.statement("Loading image: " + args.join(","))
    @file = @imageConv.readImage(engine,args,self)
    if @file
      engine.statement("Image summary: "+@file.rows.to_s+" rows  "+@file.cols.to_s+" cols  "+@bitsPerPix.to_s+" bits per pixel  "+@file.classesPresent.to_s+" classes")
    end
    MethodRemover.new("ImageConverter").run
    @file
  end
  
  # an imageConverter's readImage call invokes this method to make bitmap
  
  def makeNewImage(rows,cols,bitsPerPix,engine)
    @bitsPerPix = bitsPerPix
    if not ImageCreator.respond_to? :createImage
      engine.error("ImageCreator has not implemented the createImage method.")
    elsif ImageCreator.method(:createImage).arity != 4
      engine.error("ImageCreator's createImage method must be defined to take 4 parameters.")
    end
    image = ImageCreator.createImage(rows,cols,bitsPerPix,engine)
    image
  end
  
end


