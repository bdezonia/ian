
require InstallPath + 'AnalysisType'
require InstallPath + 'OutputSummary'

class Analysis

  def initialize(engine,options,image,distUnit,areaUnit,args)
    @image = image
    @options = options
  end

  def run
    backGround = -1
    setting = @options.find("Background")
    backGround = setting.dig_to_i(setting.value) if setting
    areas = @image.file.areas
    totalCells = @image.file.area
    if backGround != -1
      backCells = @image.file.areas[backGround]
      totalCells -= backCells if backCells
    end
    sum = 0.0
    classesPresent = 0
    areas.each_index do | areaIndex |
      if areaIndex != backGround and areas[areaIndex]
        classesPresent += 1
        relArea = (areas[areaIndex].to_f) / totalCells
        sum = sum + (relArea * Math.log(relArea))
      end
    end
    diversity = 0.0 - sum
    maxDiversity = Math.log(classesPresent)
    dom = maxDiversity - diversity
    [OutputSummary.new(name,abbrev,outType,dom,units,family,precision)]
  end

  def help(verbose)
    if verbose
      ["DO - Dominance",
       "",
       "  DO reports the dominance measure of an image. Dominance is a measure",
       "  of the degree to which an image departs from maximal diversity as",
       "  defined by Shannon.",
       "",
       "  DO returns a value greater than or equal to zero. Large values of DO",
       "  arise from images that are predominantly made up of a few classes.",
       "  Small values of DO arise from images that are made up of many",
       "  different classes in approximately equal proportions.",
       "",
       "  Definition: given a probability distribution p of the classes present",
       "  dominance = maximum possible diversity - measured diversity. Maximum",
       "  diversity is defined as ln(classes present) and measured diversity is",
       "  defined as -1 times the sum of p(i)*ln(p(i)) for all classes present.",
       "",
       "  Reference: For more information see Turner M.G. 1990. Spatial and",
       "  temporal analysis of landscape patterns. Landscape Ecology 1:21-30"
      ]
    else
      ["DO - Dominance"]
    end
  end

  def name
    "Dominance"
  end

  def abbrev
    "Dominance"
  end

  def units
    NoUnit
  end

  def precision
    3
  end

  def outType
    AnalysisType::IMAGE
  end

  def family
    "scalar"
  end

end
