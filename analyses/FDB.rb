
# Fractal dimension : box counting

require InstallPath + 'AnalysisType'
require InstallPath + 'OutputSummary'
require InstallPath + 'Calculator'
require InstallPath + 'SparseMatrix'

#require 'profiler'

if not defined?(OVERALL_STR)
  OVERALL_STR = "overall"
end

class Analysis

  def initialize(engine,options,image,distUnit,areaUnit,args)
    @options = options
    @image = image
  end
   
  def run
  
#Profiler__::start_profile
    
    backGround = -1
    setting = @options.find("Background")
    backGround = setting.dig_to_i(setting.value) if setting
    
    rows = @image.file.rows
    cols = @image.file.cols
    
    minDim = [rows, cols].min
    maxDim = [rows, cols].max
    
    powersOf2 = 0
    
    if minDim >= 32768  # 2 to the 15th
      powersOf2 = 15
    else
      14.downto(0) do | power |
        powerOf2 = 1 << power
        if (powerOf2 & minDim) > 0
          powersOf2 = power
          break
        end
      end
    end
    
    colors = {}
    boxesOfPowerXContainingPixels = {}
    boxesOfPowerXContainingColorY = SparseMatrix.new
    
    # predefine for speed
    power = row = col = rowOffset = colOffset = color = boxCount = nil
    boxSize = pixelsPresent = pixelsPresentInCurrBox = pr = pc = nil
    
    0.upto(powersOf2) do | power |
      boxSize = 1 << power
      0.step(rows-1,boxSize) do | row |
        0.step(cols-1,boxSize) do | col |
          pixelsPresent = false
          pixelsPresentInCurrBox = {}
          # 50% of this analysis runtime in these two inner loops (boxSize.times)
          boxSize.times do | rowOffset |
            pr = row + rowOffset
            if pr < rows
              boxSize.times do | colOffset |
                pc = col + colOffset
                if pc < cols
                  color = @image.file.getCell(pr,pc)
                  if color != backGround
                    pixelsPresent = true
                    pixelsPresentInCurrBox[color] = true
                    colors[color] = true
                  end
                end
              end
            end
          end
          if pixelsPresent
            if boxesOfPowerXContainingPixels[power]
              boxesOfPowerXContainingPixels[power] += 1
            else
              boxesOfPowerXContainingPixels[power] = 1
            end
          end
          pixelsPresentInCurrBox.each_key do | color |
            if boxesOfPowerXContainingColorY[power,color]
              boxesOfPowerXContainingColorY[power,color] += 1
            else
              boxesOfPowerXContainingColorY[power,color] = 1
            end
          end
        end
      end
    end

    boxCountTuples = {}
    boxCountTuples[OVERALL_STR] = []

    # calc overall fd
    boxesOfPowerXContainingPixels.each_pair do | power, boxCount |
      if boxCount
        dependent = Math.log(boxCount)
        boxesWidePerCell = 1 << (powersOf2 - power)
        independent = Math.log(boxesWidePerCell)
        boxCountTuples[OVERALL_STR] << [independent,dependent]
      end
    end
    
    # calc fd's of each class

    colors = colors.keys  # get an array of the colors present
    colors.sort!
    
    colors.each do | color |
      0.upto(powersOf2) do | power |
        boxCount = boxesOfPowerXContainingColorY[power,color]
        if boxCount
          dependent = Math.log(boxCount)
          boxesWidePerCell = 1 << (powersOf2 - power)
          independent = Math.log(boxesWidePerCell)
          if boxCountTuples[color]
            boxCountTuples[color] << [independent,dependent]
          else
            boxCountTuples[color] = [[independent,dependent]]
          end
        end
      end
    end
    
    fdRatio = 0.0
    fdRatios = {}

    boxCountTuples.each_pair do | tupleClass, boxCountTuple |
      if tupleClass == OVERALL_STR
        fdRatio = Calculator.regress(boxCountTuple)[0]
      else
        fdRatios[tupleClass] = Calculator.regress(boxCountTuple)[0]
      end
    end
    
#Profiler__::stop_profile
#Profiler__::print_profile($stdout)
    
    [OutputSummary.new(name,abbrev,AnalysisType::IMAGE,fdRatio,units,family,precision),
     OutputSummary.new(name,abbrev,AnalysisType::CLASS,fdRatios,units,family,precision)
    ]
  end
   
  def help(verbose)
    if verbose
      ["FDB - Fractal Dimension (Box)",
       "",
       "  FDB estimates the fractal dimension of the image using the box",
       "  counting method. It is reported for each class present and for the",
       "  image as a whole. FDB ranges from 1.0 for images made up of polygons",
       "  whose outlines are very regular (or straight) to 2.0 for images made",
       "  of polygons whose outlines are very irregular.",
       "",
       "  Limitations: For those images whose sample set is too small to",
       "  accurately estimate fractal dimension IAN reports 0.",
       "",
       "  Definition: The calculation of FDB is the log-log regression of box",
       "  size versus number of boxes required to cover the image.",
       "",
       "  Reference: For more information regarding the implementation of this",
       "  fractal dimension method and regarding the use of fractal dimension",
       "  estimates in landscape ecology see [Loehle 90], [Milne 91], and",
       "  [Sugihara 90]. There are many techniques and much debate as to how to",
       "  accurately measure fractal dimension. For more information regarding",
       "  this topic refer to [Russ 94].",
       "",
       "  [Loehle 90] - Loehle C. 1990. Home range: A fractal approach.",
       "    Landscape Ecology 1:39-52",
       "",
       "  [Milne 91] - Milne B.T. 1991. The utility of fractal geometry in",
       "    landscape design. Landscape and Urban Planning 21:81-90",
       "",
       "  [Russ 94] - Russ, John C. 1994. Fractal Surfaces. Plenum Press. New",
       "    York, New York, USA",
       "",
       "  [Sugihara 90] - Sugihara G., and R.M. May. 1990. Applications of",
       "    Fractals in Ecology. TREE 3:79-86."
      ]
    else
      ["FDB - Fractal Dimension (Box)"]
    end
  end

  def name
    "Fractal Dimension (Box)"
  end
   
  def abbrev
    "FrcDimBox"
  end
   
  def units
    NoUnit
  end
                                         
  def precision
    3
  end

  def outType
    AnalysisType::IMAGE | AnalysisType::CLASS
  end

  def family
    "scalar"
  end

end
