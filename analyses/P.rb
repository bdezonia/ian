
require InstallPath + 'AnalysisType'
require InstallPath + 'OutputSummary'

class Analysis

  def initialize(engine,options,image,distUnit,areaUnit,args)
    @image = image
    @unit = distUnit
    @options = options
  end
   
  def run
    backGround = -1
    setting = @options.find("Background")
    backGround = setting.dig_to_i(setting.value) if setting
    
    totalPerim = @image.file.perimeter * @unit.factor
    
    hash = {}
    array = @image.file.perimeters
    array.each_index do | color |
      if color != backGround 
        value = array[color]
        if value
          hash[color] = value * @unit.factor
        end
      end
    end
    
    [OutputSummary.new(name,abbrev,AnalysisType::IMAGE,totalPerim,@unit.unit,family,precision),
     OutputSummary.new(name,abbrev,AnalysisType::CLASS,hash,@unit.unit,family,precision)]
  end
   
  def help(verbose)
    if verbose
      ["P - perimeter of each class"]
    else
      ["P - perimeter of each class"]
    end
  end

  def name
    "Perimeter"
  end

  def abbrev
    "Perimeter"
  end

  def outType
    AnalysisType::IMAGE | AnalysisType::CLASS
  end

  def precision
    3
  end

  def family
    "distance"
  end

end

