# Largest Patch Index

require InstallPath + 'AnalysisType'
require InstallPath + 'OutputSummary'
require InstallPath + 'Units'

class Analysis

  def initialize(engine,options,image,distUnit,areaUnit,args)
    @image = image
    @options = options
  end
   
  def run
  
    backGround = -1
    setting = @options.find("Background")
    backGround = setting.dig_to_i(setting.value) if setting
    
    eightNeighs = true
    setting = @options.find("Neighborhood")
    eightNeighs = false if setting and setting.value == "4"
    
    polyAreas = @image.file.polyAreas(eightNeighs)
    polyClasses = @image.file.polyClasses(eightNeighs)

    maxPoly = -1    
    maxPolys = {}
    
    (1...polyAreas.size).each do | pNum |
      polyClass = polyClasses[pNum]
      if polyClass != backGround
        area = polyAreas[pNum]
        if area > maxPoly
          maxPoly = area
        end
        currMax = maxPolys[polyClass]
        if currMax
          maxPolys[polyClass] = area if area > currMax
        else
          maxPolys[polyClass] = area
        end
      end
    end

    imageArea = @image.file.area
    if backGround != -1
      backArea = @image.file.areas[backGround]
      imageArea -= backArea if backArea
    end
    
    if imageArea > 0
      maxPoly = 100.0 * maxPoly / imageArea
      maxPolys.each_pair do | polyClass, max |
        maxPolys[polyClass] = 100.0 * max / imageArea
      end
    else  # imageArea = 0
      maxPoly = 0.0
      maxPolys.each_pair do | polyClass, max |
        maxPolys[polyClass] = 0.0
      end
    end
    
    [OutputSummary.new(name, abbrev, AnalysisType::IMAGE, maxPoly,
        units, family, precision),
     OutputSummary.new(name, abbrev, AnalysisType::CLASS,
        maxPolys, units, family, precision)
    ]
  end
   
  def help(verbose)
    if verbose
      ["LPI - Largest Polygon Index",
       "",
       "  LPI measures the percentage of area taken up by the largest",
       "  polygon. It is reported for the image as a whole as well as for",
       "  each class present in the image. LPI is calculated as the",
       "  largest polygon size divided by the total area of the image. It",
       "  is multiplied by 100 to represent a percentage."
      ]
    else
      ["LPI - Largest Polygon Index"]
    end
  end

  def name
    "Largest Polygon Index"
  end

  def abbrev
    "LPI"
  end

  def outType
    AnalysisType::IMAGE | AnalysisType::CLASS
  end

  def units
    Units.find("percent")
  end

  def precision
    3
  end

  def family
    "scalar"
  end

end
