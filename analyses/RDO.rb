
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
    if classesPresent == 0
      dor = 0.0
    elsif classesPresent == 1
      dor = 1.0
    else
      diversity = 0.0 - sum
      maxDiversity = Math.log(classesPresent)
      dor = 1.0 - (diversity / maxDiversity)
    end
    [OutputSummary.new(name,abbrev,outType,dor,units,family,precision)]
  end
   
  def help(verbose)
    if verbose
      ["RDO - Relative Dominance",
       "",
       "  RDO reports the relative dominance measure of an image. Dominance is",
       "  a measure of the degree to which an image departs from maximal",
       "  diversity as defined by [Shannon 62].",
       "",
       "  RDO returns a value between 0.0 and 1.0 inclusive. Large values of",
       "  RDO arise from images that are predominantly made up of a few classes.",
       "  Small values of RDO arise from images that are made up of many",
       "  different classes in approximately equal proportions.",
       "",
       "  Definition: (given p, a probability distribution of the classes present)",
       "    RDO = 1.0 - (measured diversity / maximum diversity)",
       "  where measured diversity = -1 * sum over all classes of p(i)*ln(p(i))",
       "  and maximum diveristy = ln(classes present).",
       "",
       "  Reference: For more information about dominance see [Turner 90]",
       "",
       "  [Shannon 62] - Shannon and Weaver. 1962. The mathematical theory of",
       "    communication. University of Illinois Press. Urbana, Illinois, USA.",
       "",
       "  [Turner 90] - Turner M.G. 1990. Spatial and temporal analysis of",
       "    landscape patterns. Landscape Ecology 1:21-30."
      ]
    else
      ["RDO - Relative Dominance"]
    end
  end

  def name
    "Relative Dominance"
  end

  def abbrev
    "RelDom"
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
