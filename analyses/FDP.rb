
# Fractal dimension : polygon perimeters vs. areas

require InstallPath + 'AnalysisType'
require InstallPath + 'OutputSummary'
require InstallPath + 'Calculator'

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

    perimAreaTuples = {}
    perimAreaTuples["overall"] = []
    
    (1...pPerims.size).each do | pnum |
      color = pClasses[pnum]
      next if color == backGround
      logPerim = Math.log(pPerims[pnum])
      logArea = Math.log(pAreas[pnum])
      if false
        perimAreaTuples["overall"] << [logPerim,logArea]
        if perimAreaTuples[color].nil?
          perimAreaTuples[color] = [[logPerim,logArea]]
        else
          perimAreaTuples[color] << [logPerim,logArea]
        end
      else
        perimAreaTuples["overall"] << [logArea,logPerim]
        if perimAreaTuples[color].nil?
          perimAreaTuples[color] = [[logArea,logPerim]]
        else
          perimAreaTuples[color] << [logArea,logPerim]
        end
      end
    end
    
    fdRatio = 0.0
    fdRatios = {}

    perimAreaTuples.each_pair do | tupleClass, perimAreaTuple |
      if tupleClass == "overall"
        fdRatio = 2.0 * Calculator.regress(perimAreaTuple)[0]
      else
        fdRatios[tupleClass] = 2.0 * Calculator.regress(perimAreaTuple)[0]
      end
    end
    
    [OutputSummary.new(name, abbrev,
                    AnalysisType::IMAGE,fdRatio,units,family,precision),
     OutputSummary.new(name, abbrev,
                     AnalysisType::CLASS,fdRatios,units,family,precision)
    ]
  end
   
  def help(verbose)
    if verbose
      ["FDP - Fractal Dimension (Perimeter-Area)",
       "",
       "  FDP estimates the fractal dimension of the image using the",
       "  perimeter/area method as described in [Sugihari 90]. It is reported",
       "  for the image as a whole as well as for each class present in",
       "  the image. FDP ranges from 1.0 for images made up of polygons whose",
       "  outlines are very regular (or straight) to 2.0 for images made of",
       "  patches whose outlines are very irregular.",
       "",
       "  Definition: The calculation of FDP is twice the log-log regression of",
       "  polygon perimeters versus polygon areas. Note that FRAGSTATS",
       "  calculates this measure by regressing polygon areas versus polygon",
       "  perimeters. Either method is defensible and neither is correct. This",
       "  is because the linear regression model assumptions are typically",
       "  violated when measuring fractal objects.",
       "",
       "  Reference: For more information regarding the implementation of this",
       "  fractal dimension method and regarding the use of fractal dimension",
       "  estimates in landscape ecology refer to [Sugihari 90]. There is much",
       "  debate as to how to accurately measure fractal dimension. For more",
       "  information regarding this topic refer to [Russ 94].",
       "",
       "  [Russ 94] - Russ, John C. 1994. Fractal Surfaces. Plenum Press. New",
       "    York, New York, USA",
       "",
       "  [Sugihara 90] - Sugihara G., and R.M. May. 1990. Applications of",
       "    Fractals in Ecology. TREE 3:79-86."
      ]
    else
      ["FDP - Fractal Dimension (Perimeter-Area)"]
    end
  end

  def name
    "Fractal Dimension (Perimeter-Area)"
  end
   
  def abbrev
    "FrcDimPA"
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
