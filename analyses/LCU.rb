# Lacunarity

require InstallPath + 'AnalysisType'
require InstallPath + 'OutputSummary'

class Analysis

  def initialize(engine,options,image,distUnit,areaUnit,args)
    @options = options
    @image = image

    # if calling Help some things are nil which could crash later
    return if (not image) or (not args)
    
    biggestAllowable = [@image.file.rows,image.file.cols].min
    
    # setup a default step progression of size 5n+1 if not passed in
    if (args.length == 0)
    
      maxSize = [biggestAllowable,46].min
      @steps = []
      1.step(maxSize,5) do | stepSize |
        @steps << stepSize
      end
      @steps << maxSize if @steps.last < maxSize
      
    else # user entered a step progression
    
      @steps = []
      args.each do | arg |
        if arg =~ /^(\d+)$/            # single box size specified
          
          size = $1.to_i
          @steps << size if size <= biggestAllowable
          
        elsif arg =~ /^(\d+)\-(\d+)$/  # box size range specified
        
          $1.to_i.upto($2.to_i) do | size |
            @steps << size if size <= biggestAllowable
          end
          
        else
          raise("Argument passed to lacunarity analysis (#{arg}) not of form NUM or NUM-NUM");
        end
      end
      @steps = @steps.uniq.sort
      
    end
    
  end
   
  def run
    backGround = -1
    setting = @options.find("Background")
    backGround = setting.dig_to_i(setting.value) if setting
    
    lcus = calcLcus(backGround)
    
    measures = []
    @steps.each do | stepSize |
      measures <<
        OutputSummary.new("#{name} at box size #{stepSize}",
                          "#{abbrev}#{stepSize}",
                          AnalysisType::CLASS,
                          lcus[stepSize],
                          units, family, precision)
    end
    measures
  end

  def calcLcus(backGround)
    totalBoxes = {}
    pixColors = pixelsPresent(backGround)
    
    boxes = countBoxes(backGround,pixColors,totalBoxes)

    lcus = {}    
    @steps.each do | boxSize |
      lcus[boxSize] = {}
      pixColors.each do | pixColor |
        firstMoment = 0.0
        secondMoment = 0.0
        1.upto(boxSize*boxSize) do | numOccupied |
          numBoxes = boxes[pixColor][boxSize][numOccupied]
          if (numBoxes)
            tmp = numOccupied * numBoxes
            firstMoment += tmp
            secondMoment += numOccupied * tmp
          end
        end
        firstMoment /= totalBoxes[boxSize]
        secondMoment /= totalBoxes[boxSize]
        if (firstMoment <= 0.000001)
          if (secondMoment == 0.0)
            lcus[boxSize][pixColor] = 0.0
          else
            lcus[boxSize][pixColor] = Calculator::Infinity
          end
        else
          lcus[boxSize][pixColor] = secondMoment / (firstMoment * firstMoment)
        end
      end
    end
    lcus
  end

  # pixelsPresent method
  #   returns
  #     an array of unique pixel colors present in the image

  def pixelsPresent(backGround)
    # enumerate pixel colors present
    pixColors = {}
    rows = @image.file.rows
    cols = @image.file.cols
    rows.times do | row |
      cols.times do | col |
        pixel = @image.file.getCell(row,col)
        pixColors[pixel] = true if (backGround == -1) or (pixel != backGround)
      end
    end
    pixColors.keys
  end
  
  # countBoxes method: this is where almost all the execution time is spent so
  #   eventually try for a single pass over the map to be speedy
  # returns
  #   boxCounts : a hash of hashes whose entries = count of boxes
  #     Indexed by pixelColor, then boxSize, then numOccupied
  
  def countBoxes(backGround,pixColors,totalBoxes)
  
    # initialize boxCounts
    
    boxCounts = {}
    pixColors.each do | pixColor |
      boxCounts[pixColor] = {}
      @steps.each do | stepSize |
        boxCounts[pixColor][stepSize] = {}
      end
    end

    # now figure box counts
    
    @steps.each do | boxSize |
      countBoxesOfSize(boxSize,boxCounts,backGround,totalBoxes)
    end
    
    # debugging aid: dump box counts
    if false
      boxCounts.each_pair do | pixColor, byPixHash |
        byPixHash.each_pair do | stepSize, boxCountHash |
          boxCountHash.each_pair do | boxMass, boxCount |
            print "boxCounts[#{pixColor}][#{stepSize}][#{boxMass}] = #{boxCount}\n"
          end
        end
      end
    end

    # return values
    boxCounts
  end

  def countBoxesOfSize(boxSize,boxCounts,backGround,totalBoxes)
    width = @image.file.cols
    height = @image.file.rows
    
    biggestBox = @steps.last
    biggestBox = 1000 if (biggestBox > 1000)
    biggestBox = width if (biggestBox > width)
    biggestBox = height if (biggestBox > height)

    return if boxSize > biggestBox
    
    # count all of the possible ways box can be overlaid on map
    boxesWide = width - boxSize + 1
    boxesHigh = height - boxSize + 1
      
    totalBoxes[boxSize] = boxesHigh * boxesWide
    
    boxesWide.times do | xBoxNum |
      boxesHigh.times do | yBoxNum |
        countBoxOfSize(boxSize,xBoxNum,yBoxNum,boxCounts,backGround,height,width)
      end
    end
    
  end
  
  def countBoxOfSize(boxSize,xBoxNum,yBoxNum,boxCounts,backGround,rows,cols)
    sizes = {}
    baseX = xBoxNum
    baseY = yBoxNum
    boxSize.times do | dx |
      col = baseX + dx
      boxSize.times do | dy |
        row = baseY + dy
        pixel = @image.file.getCell(row,col)
        if (backGround == -1) or (pixel != backGround)
          if sizes[pixel]
            sizes[pixel] += 1
          else
            sizes[pixel] = 1
          end
        end
      end
    end
    
    sizes.each_pair do | pixColor, pixCount |
      if boxCounts[pixColor][boxSize][pixCount]
        boxCounts[pixColor][boxSize][pixCount] += 1
      else
        boxCounts[pixColor][boxSize][pixCount] = 1
      end
    end
  end

  def help(verbose)
    if verbose
      ["LCU - Lacunarity",
       "",
       
       "  LCU reports the lacunarity of the landscape at different box sizes. It is",
       "  a measure of image texture. This analysis can be specified by typing ALCU",
       "  in the methods portion in the command line UI or simply selected in the",
       "  windows UI.",
       "",
       "  LCU ranges from 0.0 for a map that is homogeneous to arbitrarily large",
       "  values for a map that appears highly textured.",
       "",
       "  Lacunarity is typically measured at various resolutions by overlaying",
       "  boxes of varying sizes upon the landscape map. If you use the command",
       "  line version of IAN you can specify the box sizes as an argument to the",
       "  ALCU method. Simply provide parameters as argument on the command line",
       "  such as ALCU(1-3). When specifying LCU the box size sequence parameter",
       "  is optional. When not provided a default set of box sizes are used. If",
       "  provided the parameter string must contain a tilde separated list of",
       "  integers such as ALCU(1~2~3) or integer ranges such as ALCU(1-3~7-9).",
       "  Each integer must be greater than zero and represents the length in cells",
       "  of the box size of interest. No spaces should be included between the",
       "  parentheses. This sequence is then used for the box size progression for",
       "  lacunarity calculations.",
       "",
       "  Reference: For more information regarding lacunarity see Plotnick[93].",
       "",
       "  Plotnick[93] - Plotnick R.E., R.H. Gardner, and R.V. O’Neill. 1993.",
       "    Lacunarity indices as measures of landscape texture.",
       "    Landscape Ecology 3:201-211"
      ]
    else
      ["LCU - Lacunarity"]
    end
  end

  def name
    "Lacunarity"
  end
   
  def abbrev
    "Lcu"
  end
   
  def outType
    AnalysisType::CLASS
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

end  # class Analysis
