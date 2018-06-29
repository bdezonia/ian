
# Perimeter - Area Ratio by class

require InstallPath + 'AnalysisType'
require InstallPath + 'OutputSummary'
require InstallPath + 'Units'

class Analysis

  def initialize(engine,options,image,distUnit,areaUnit,args)
    @image = image
    @options = options
    @distUnit = distUnit
    @areaUnit = areaUnit
  end
   
  def run
    @unit = CompoundUnit.new()
    @unit.addNUnit(@distUnit.unit)
    @unit.addDUnit(@areaUnit.unit)
    backGround = -1
    setting = @options.find("Background")
    backGround = setting.dig_to_i(setting.value) if setting
    areas = @image.file.areas
    perims = @image.file.perimeters
    paRatios = {}
    (0...perims.size).each do | color |
      paRatios[color] = perims[color].to_f if color != backGround and perims[color]
    end
    paRatios.each_key do | color |
      paRatios[color] = 0.0 if not paRatios[color]
      paRatios[color] /= areas[color] if areas[color] and areas[color] != 0.0
      paRatios[color] *= @distUnit.factor
      paRatios[color] /= @areaUnit.factor
    end
    totalArea = @image.file.area
    if backGround != -1
      backCells = @image.file.areas[backGround]
      totalArea -= backCells if backCells
    end
    perim = @image.file.perimeter
    if backGround != -1
      backPerim = @image.file.perimeters[backGround]
      perim -= backPerim if backPerim
    end
    paRatio = (perim.to_f * @distUnit.factor) / (totalArea * @areaUnit.factor)

    [OutputSummary.new(name, abbrev, AnalysisType::IMAGE, paRatio,
        units, family, precision),
     OutputSummary.new(name, abbrev, AnalysisType::CLASS,
        paRatios, units, family, precision)
    ]
  end
   
  def help(verbose)
    if verbose
      ["ED - Edge Density",
       "",
       "  ED measures the edge density (edge length per unit area) of the",
       "  image. It is reported for the image as a whole as well as for each",
       "  class present in the image. ED is calculated as the total edge",
       "  length divided by total image area for a given image or class."
      ]
    else
      ["ED - Edge Density"]
    end
  end

  def name
    "Edge Density"
  end

  def abbrev
    "EdgeDensty"
  end

  def units
    @unit
  end

  def precision
    3
  end

  def family
    "compound"
  end

  def outType
    AnalysisType::IMAGE | AnalysisType::CLASS
  end

end
