
# Average Polygon Perimeter Area ratio (corrected) by class

require InstallPath + 'AnalysisType'
require InstallPath + 'OutputSummary'

class Analysis

  def initialize(engine,options,image,distUnit,areaUnit,args)
    @options = options
    @image = image
  end
   
  def run
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
        perim = pPerims[pnum].to_f
        area = Math.sqrt(pAreas[pnum])
        ratio = perim / area
        if paRatios[color]
          paRatios[color] += ratio
        else
          paRatios[color] = ratio
        end
        if polyCount[color]
          polyCount[color] += 1
        else
          polyCount[color] = 1
        end
        paRatio += ratio
        totalPolys += 1
      end
    end

    factor = 1.0 / (2.0 * Math.sqrt(Math::PI))
    paRatio *= factor
    paRatio /= totalPolys if totalPolys > 0
    
    paRatios.each_key do | color |
      paRatios[color] = 0.0 if not paRatios[color]
      paRatios[color] *= factor
      paRatios[color] /= polyCount[color] if polyCount[color] and polyCount[color] != 0
    end

    [OutputSummary.new(name,abbrev,AnalysisType::IMAGE,paRatio,units,family,precision),
     OutputSummary.new(name,abbrev,AnalysisType::CLASS,paRatios,units,family,precision)
    ]
  end
   
  def help(verbose)
    if verbose
      ["PAC - Avg. Polygon Perimeter-Area ratios (corrected)",
       "",
       "  PAC reports the average corrected perimeter to area ratio for all",
       "  polygons present in the image. It is reported for the image",
       "  as a whole as well as for each class present in the image.",
       "",
       "  A corrected perimeter to area ratio is calculated by dividing the",
       "  perimeter of a polygon by the square root of the product of 4 pi",
       "  and the area of the polygon.",
       "",
       "  The average corrected perimeter to area ratio is calculated by",
       "  averaging the corrected perimeter to area ratio for all polygons",
       "  present. This provides a result that generally differs from dividing",
       "  the total perimeter by the square root of 4 pi times the total area.",
       "",
       "  PAC results are always greater than or equal to 1. PAC equals 1.0",
       "  for polygons that are perfect circles, 1.1 for polygons that are",
       "  perfect squares, and can be arbitrarily large for polygons that are",
       "  extremely long and skinny.",
       "",
       "  Reference: For more information see Baker W.L., and Y. Cai. 1992.",
       "  The r.le programs for multiscale analysis of landscape structure",
       "  using the GRASS geographical information system. Landscape Ecology",
       "  7:291-302"
      ]
    else
      ["PAC - Avg. Polygon Perimeter-Area ratios (corrected)"]
    end
  end

  def name
    "Avg. Polygon Perimeter-Area ratio (corrected)"
  end
   
  def abbrev
    "PAratioC"
  end
   
  def outType
    AnalysisType::IMAGE | AnalysisType::CLASS
  end

  def units
    NoUnit
  end

  def precision
    3
  end

  def family
    "scalar"
  end

end
