
# SHAPE Index

require InstallPath + 'AnalysisType'
require InstallPath + 'OutputSummary'
require InstallPath + 'Units'
require InstallPath + 'Calculator'

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
    polyPerims = @image.file.polyPerims(eightNeighs)
    polyClasses = @image.file.polyClasses(eightNeighs)

    polyShapes = []
    polyShapesClass = {}
    
    (1...polyAreas.size).each do | pNum |
      polyClass = polyClasses[pNum]
      if polyClass != backGround
        area = polyAreas[pNum]
        n = Math.sqrt(area).floor
        m = area - (n*n)
        if m == 0  # area == n*n
          minPerim = 4*n
        elsif area <= n*(n+1)
          minPerim = 4*n + 2
        else # area > n(n+1)
          minPerim = 4*n + 4
        end
        perimeter = polyPerims[pNum]
        shape = perimeter.to_f / minPerim
        polyShapes << shape
        color = polyClasses[pNum]
        if polyShapesClass[color]
          polyShapesClass[color] << shape
        else
          polyShapesClass[color] = [shape]
        end
      end
    end

    measures = Calculator.statSummary(polyShapes)
    shapeMean   = measures[0]
    shapeStdDev = measures[1]
    shapeMedian = measures[2]
    shapeFirst  = measures[3]
    shapeThird  = measures[4]
    shapeMin    = measures[5]
    shapeMax    = measures[6]
    
    shapeMeans   = {}
    shapeStdDevs = {}
    shapeMedians = {}
    shapeFirsts  = {}
    shapeThirds  = {}
    shapeMins    = {}
    shapeMaxes   = {}
    polyShapesClass.each_pair do |color,shapeArray|
      measures = Calculator.statSummary(shapeArray)
      shapeMeans[color]   = measures[0]
      shapeStdDevs[color] = measures[1]
      shapeMedians[color] = measures[2]
      shapeFirsts[color]  = measures[3]
      shapeThirds[color]  = measures[4]
      shapeMins[color]    = measures[5]
      shapeMaxes[color]   = measures[6]
    end
    
    [
     OutputSummary.new("Mean Shape Index", "MnShpIndex", AnalysisType::IMAGE,
        shapeMean, NoUnit, family, precision),
     OutputSummary.new("Standard Deviation Shape Index", "SdShpIndex", AnalysisType::IMAGE,
        shapeStdDev, NoUnit, family, precision),
     OutputSummary.new("Median Shape Index", "MdShpIndex", AnalysisType::IMAGE,
        shapeMedian, NoUnit, family, precision),
     OutputSummary.new("First Quartile Shape Index", "Q1ShpIndex", AnalysisType::IMAGE,
        shapeFirst, NoUnit, family, precision),
     OutputSummary.new("Third Quartile Shape Index", "Q3ShpIndex", AnalysisType::IMAGE,
        shapeThird, NoUnit, family, precision),
     OutputSummary.new("Minimum Shape Index", "MiShpIndex", AnalysisType::IMAGE,
        shapeMin, NoUnit, family, precision),
     OutputSummary.new("Maximum Shape Index", "MdShpIndex", AnalysisType::IMAGE,
        shapeMax, NoUnit, family, precision),
     OutputSummary.new("Mean Shape Index", "MnShpIndex", AnalysisType::CLASS,
        shapeMeans, NoUnit, family, precision),
     OutputSummary.new("Standard Deviation Shape Index", "SdShpIndex", AnalysisType::CLASS,
        shapeStdDevs, NoUnit, family, precision),
     OutputSummary.new("Median Shape Index", "MdShpIndex", AnalysisType::CLASS,
        shapeMedians, NoUnit, family, precision),
     OutputSummary.new("First Quartile Shape Index", "Q1ShpIndex", AnalysisType::CLASS,
        shapeFirsts, NoUnit, family, precision),
     OutputSummary.new("Third Quartile Shape Index", "Q3ShpIndex", AnalysisType::CLASS,
        shapeThirds, NoUnit, family, precision),
     OutputSummary.new("Minimum Shape Index", "MiShpIndex", AnalysisType::CLASS,
        shapeMins, NoUnit, family, precision),
     OutputSummary.new("Maximum Shape Index", "MdShpIndex", AnalysisType::CLASS,
        shapeMaxes, NoUnit, family, precision)
    ]
  end
   
  def help(verbose)
    if verbose
      ["SHP - Shape Index Summary",
       "",
       "  This metric calulates a statistical summary of the Shape Index upon the",
       "  image. The summary includes mean, standard deviation, median, first quartile,",
       "  third quartile, min, and max of the shape index of the polygons within the",
       "  image.",
       "",
       "  The Shape Index for a polygon is defined as (perimeter / minimum perimeter)",
       "  where minimum possible perimeter is calculated in the following manner:",
       "",
       "  Find the edge length of the largest square smaller than the area of the",
       "  polygon (n = floor(sqrt(area))). Let m be the difference between the area",
       "  of the polygon and the area of sqr(n). Then the minimum perimeter = ",
       "    4n if m == 0",
       "    4n+2 if sqr(n) < area <= n(n+1)",
       "    4n+4 if area > n(n+1)",
       "",
       "  The Shape Index is always >= 1 and is unitless. Values close to 1 imply",
       "  that the shape of the polygon is compact. Large values imply an irregular",
       "  shape.",
       "",
       "  The Shape Index is scale independent. Polygons of the same shape but",
       "  differing sizes will have the same shape index."
      ]
    else
      ["SHP - Shape Index Summary"]
    end
  end

  def name
    "Shape Index Summary Statistics"
  end

  def abbrev
    "Shape"
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
