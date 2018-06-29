
class PrototypeLibrary
  def initialize
    @prototypes = {}
  end
  
  def addPrototype(name,proto)
    id = name.downcase
    raise("Prototype defined multiple times: "+id.to_s) if @prototypes[id]
    @prototypes[id] = proto
  end
  
  def getPrototype(name)
    id = name.downcase
    raise("Prototype not found: "+id.to_s) if not @prototypes[id]
    @prototypes[id]
  end
  
  def getAllPrototypes
    array = @prototypes.to_a
    array.sort!
  end
end

class PrototypeManager

  #include Singleton
  
  @@Options = PrototypeLibrary.new
  @@Analyses = PrototypeLibrary.new
  @@ImageConverters = PrototypeLibrary.new
  @@Reporters = PrototypeLibrary.new

  def PrototypeManager.options
    @@Options
  end
  
  def PrototypeManager.analyses
    @@Analyses
  end
  
  def PrototypeManager.imageConverters
    @@ImageConverters
  end
  
  def PrototypeManager.reporters
    @@Reporters
  end
  
  def PrototypeManager.loadOption(acronym)
    fileName = InstallPath + "options\\" + acronym + ".rb"
    raise("Unknown option : "+fileName) if not File.exists?(fileName)
    $plugin = nil
    load(fileName)  # syntax errors caught and raised by load
    # $plugin set by analysis script
    if not $plugin
      raise("Variable $plugin not assigned in option script : "+fileName)
    end
    # check that correct methods are defined
    nameMeth = $plugin.instance_method(:name)
    if not nameMeth or nameMeth.arity != 0
      raise("Option " + fileName + " does not define a name method that takes 0 arguments")
    end
    helpMeth = $plugin.instance_method(:help)
    if not helpMeth or helpMeth.arity != 1
      raise("Option " + fileName + " does not define a help method that takes 1 argument")
    end
    @@Options.addPrototype(acronym,$plugin)
  end

  def PrototypeManager.loadAnalysis(acronym)
    fileName = InstallPath + "analyses\\" + acronym + ".rb"
    raise("Unknown analysis : "+fileName) if not File.exists?(fileName)
    $plugin = nil
    load(fileName)  # syntax errors caught and raised by load
    # $plugin set by analysis script
    if not $plugin
      raise("Variable $plugin not assigned in analysis script : "+fileName)
    end
    # check that correct methods are defined
    initMeth = $plugin.instance_method(:initialize)
    if not initMeth or initMeth.arity != 6
      raise("Analysis " + fileName + " does not define a constructor that takes 6 arguments")
    end
    helpMeth = $plugin.instance_method(:help)
    if not helpMeth or helpMeth.arity != 1
      raise("Analysis " + fileName + " does not define a help method that takes 1 argument")
    end
    runMeth = $plugin.instance_method(:run)
    if not runMeth or runMeth.arity != 0
      raise("Analysis " + fileName + " does not define a run method that takes 0 arguments")
    end
    nameMeth = $plugin.instance_method(:name)
    if not nameMeth or nameMeth.arity != 0
      raise("Analysis " + fileName + " does not define a name method that takes 0 arguments")
    end
    abbrevMeth = $plugin.instance_method(:abbrev)
    if not abbrevMeth or abbrevMeth.arity != 0
      raise("Analysis " + fileName + " does not define an abbrev method that takes 0 arguments")
    end
    @@Analyses.addPrototype(acronym,$plugin)
  end

  def PrototypeManager.loadImageConverter(acronym)
    fileName = InstallPath + "imagetypes\\" + acronym + ".rb"
    raise("Unknown image converter : "+fileName) if not File.exists?(fileName)
    $plugin = nil
    load(fileName)  # syntax errors caught and raised by load
    # $plugin set by analysis script
    if not $plugin
      raise("Variable $plugin not assigned in image converter script : "+fileName)
    end
    # check that correct methods are defined
    nameMeth = $plugin.instance_method(:name)
    if not nameMeth or nameMeth.arity != 0
      raise("ImageConverter " + fileName + " does not define a name method that takes 0 arguments")
    end
    helpMeth = $plugin.instance_method(:help)
    if not helpMeth or helpMeth.arity != 1
      raise("ImageConverter " + fileName + " does not define a help method that takes 1 argument")
    end
    readMeth = $plugin.instance_method(:readImage)
    if not readMeth or readMeth.arity != 3
      raise("ImageConverter " + fileName + " does not define a readImage method that takes 3 arguments")
    end
    writeMeth = $plugin.instance_method(:writeImage)
    if not writeMeth or writeMeth.arity != 3
      raise("ImageConverter " + fileName + " does not define a writeImage method that takes 3 arguments")
    end
    @@ImageConverters.addPrototype(acronym,$plugin)
  end

  def PrototypeManager.loadReporter(acronym)
    fileName = InstallPath + "reports\\" + acronym + ".rb"
    raise("Unknown report : "+fileName) if not File.exists?(fileName)
    $plugin = nil
    load(fileName)  # syntax errors caught and raised by load
    # $plugin set by analysis script
    if not $plugin
      raise("Variable $plugin not assigned in reporter script : "+fileName)
    end
    # check that correct methods are defined
    helpMeth = $plugin.instance_method(:help)
    if not helpMeth or helpMeth.arity != 1
      raise("Reporter " + fileName + " does not define a help method that takes 1 argument")
    end
    runMeth = $plugin.instance_method(:run)
    if not runMeth or runMeth.arity != 6
      raise("Reporter " + fileName + " does not define a run method that takes 6 arguments")
    end
    nameMeth = $plugin.instance_method(:outName)
    if not nameMeth or nameMeth.arity != 0
      raise("Reporter " + fileName + " does not define an outName method that takes 0 arguments")
    end
    @@Reporters.addPrototype(acronym,$plugin)
  end

  def PrototypeManager.loadAnalyses
    Dir.entries(InstallPath + "analyses").each do | filename |
      next if filename == "." or filename == ".."
      if filename =~ /^(.*)\.rb$/i
        loadAnalysis($1)
      else
        raise("Remove unknown file : "+filename+" from "+InstallPath+"analyses")
      end
    end
  end

  def PrototypeManager.loadImageConverters
    Dir.entries(InstallPath + "imagetypes").each do | filename |
      next if filename == "." or filename == ".."
      if filename =~ /^(.*)\.rb$/i
        loadImageConverter($1)
      else
        raise("Remove unknown file : "+filename+" from "+InstallPath+"imagetypes")
      end
    end
  end

  def PrototypeManager.loadReporters
    Dir.entries(InstallPath + "reports").each do | filename |
      next if filename == "." or filename == ".."
      if filename =~ /^(.*)\.rb$/i
        loadReporter($1)
      else
        raise("Remove unknown file : "+filename+" from "+InstallPath+"reports")
      end
    end
  end
end
