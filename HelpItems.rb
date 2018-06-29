
class HelpItem
  
  def initialize(name,verbose)
    @name = name
    @verbose = verbose
  end
  
  attr_reader(:name,:verbose)
  
  def help(engine)
    
    engine.error("Empty help item found") if name.length <= 1
    
    filename = self.fileName # all HelpItems must define a fileName method
    
    if not FileTest.exists?(filename)
      engine.error("Cannot get help for " + @name + " : file " + filename + " does not exist")
    end
    
    load filename
    
    self.helpSource.help(verbose)
  end
end

class OptionHelpItem < HelpItem

  def initialize(name,verbose)
    super(name,verbose)
  end
  
  def fileName
    InstallPath + "options\\" + name[1,name.length-1] + ".rb"
  end
  
  def helpSource
    Option.new
  end
end

class AnalysisHelpItem < HelpItem

  def initialize(name,verbose)
    super(name,verbose)
  end
  
  def fileName
    InstallPath + "analyses\\" + name[1,name.length-1] + ".rb"
  end
  
  def helpSource
    Analysis.new(nil,nil,nil,nil,nil,nil)
  end
end

class ImageHelpItem < HelpItem

  def initialize(name,verbose)
    super(name,verbose)
  end
  
  def fileName
    InstallPath + "imageTypes\\" + name[1,name.length-1] + ".rb"
  end
  
  def helpSource
    ImageConverter.new
  end
end

class ReportHelpItem < HelpItem

  def initialize(name,verbose)
    super(name,verbose)
  end
  
  def fileName
    InstallPath + "reports\\" + name[1,name.length-1] + ".rb"
  end
  
  def helpSource
    ReportWriter.new
  end
end
