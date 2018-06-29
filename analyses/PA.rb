
# Average Polygon Perimeter Area ratio by class

require InstallPath + 'AnalysisType'
require InstallPath + 'OutputSummary'

class Analysis

  def initialize(engine,options,image,distUnit,areaUnit,args)
    @options = options
    @image = image
    @distUnit = distUnit
    @areaUnit = areaUnit
  end
   
  def run
    @unit = CompoundUnit.new
    @unit.addNUnit(@distUnit.unit)
    @unit.addDUnit(@areaUnit.unit)
    backGround = -1
    setting = @options.find("Background")
    backGround = setting.dig_to_i(setting.value) if setting
    
    eightNeighbors = true
    setting = @options.find("Neighborhood")
    eightNeighbors = false if setting and setting.value == "4"
    
    pPerims = @image.file.polyPerims(eightNeighbors)
    pAreas = @image.file.polyAreas(eightNeighbors)
    pClasses = @image.file.polyClasses(eightNeighbors)
    
    paRatio = 0
    paRatios = {}
    polyCount = {}
    totalPolys = 0
    (1...pPerims.size).each do | pnum |
      color = pClasses[pnum]
      if (color != backGround)
        if paRatios[color]
          paRatios[color] += (pPerims[pnum].to_f) / pAreas[pnum]
        else
          paRatios[color] = (pPerims[pnum].to_f) / pAreas[pnum]
        end
        if polyCount[color]
          polyCount[color] += 1
        else
          polyCount[color] = 1
        end
        paRatio += (pPerims[pnum].to_f) / pAreas[pnum]
        totalPolys += 1
      end
    end
    
    paRatio /= totalPolys if totalPolys > 0
    paRatio *= @distUnit.factor
    paRatio /= @areaUnit.factor
    
    paRatios.each_key do | color |
      paRatios[color] = 0.0 if not paRatios[color]
      paRatios[color] /= polyCount[color] if polyCount[color] and polyCount[color] != 0
      paRatios[color] *= @distUnit.factor
      paRatios[color] /= @areaUnit.factor
    end

    [OutputSummary.new(name, abbrev,
                    AnalysisType::IMAGE,paRatio,units,family,precision),
     OutputSummary.new(name, abbrev,
                     AnalysisType::CLASS,paRatios,units,family,precision)
    ]
  end
   
  def help(verbose)
    if verbose
      ["PA - Avg. Polygon Perimeter-Area ratios",
       "",
       "  PA reports the average perimeter to area ratio for all polygons",
       "  present in the image. It is reported for the image as a whole",
       "  as well as for each class present in the image.",
       "",
       "  PA is calculated by averaging the perimeter to area ratio for all",
       "  polygons present. This provides a result that generally differs from",
       "  dividing the total perimeter of the polygons by their total area.",
       "",
       "  Reference: For more information see Baker W.L., and Y. Cai. 1992. The",
       "  r.le programs for multiscale analysis of landscape structure using",
       "  the GRASS geographical information system. Landscape Ecology 7:291-302"
      ]
    else
      ["PA - Avg. Polygon Perimeter-Area ratios"]
    end
  end

  def name
    "Avg. Polygon Perimeter-Area ratio"
  end
   
  def abbrev
    "PAratio"
  end
   
  def outType
    AnalysisType::IMAGE | AnalysisType::CLASS
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

end
