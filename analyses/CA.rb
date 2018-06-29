
require InstallPath + 'AnalysisType'
require InstallPath + 'OutputSummary'

class Analysis

  def initialize(engine,options,image,distUnit,areaUnit,args)
    @image = image
    @unit = areaUnit
    @options = options
  end

  def run
    backGround = -1
    setting = @options.find("Background")
    backGround = setting.dig_to_i(setting.value) if setting
    areas = {}
    center = nw = n = ne = w = e = sw = s = se = nil # predefine for speed
    @image.file.each9 do |center,nw,n,ne,w,e,sw,s,se|
      next if center == backGround
      areas[center] = 0 if not areas[center]
      # much nested code for speed
      if (not n) or (n == center)
        if (not s) or (s == center)
          if (not e) or (e == center)
            if (not w) or (w == center)
              if (not nw) or (nw == center)
                if (not ne) or (ne == center)
                  if (not sw) or (sw == center)
                    if (not se) or (se == center)
                      areas[center] += 1
                    end
                  end
                end
              end
            end
          end
        end
      end
    end # each9
    totalPixels = @image.file.area
    areas.each_pair do | color, pixelArea |
      # the above nested test does not catch CA of 0 for 1 pixel maps
      if (totalPixels == 1)
        areas[color] = 0.0;
      else
        areas[color] = @unit.factor * pixelArea
      end
    end
    [OutputSummary.new(name,abbrev,outType,areas,@unit.unit,family,precision)]
  end

  def help(verbose)
    if verbose
     ["CA - Core Area of each class",
      "",
      "  CA reports the core area measures of the image. It is reported for each",
      "  class present in the image. For a single pixel core area is defined as",
      "  1 cell if all of its neighbors are of the same class as the pixel. An 8",
      "  neighbor rule is used. The total cell count for each class is then scaled",
      "  to the correct units."
     ]
    else
     ["CA - Core Area of each class"]
    end
  end

  def name
    "Core Area"
  end

  def abbrev
    "CoreArea"
  end

  def precision
    3
  end

  def outType
    AnalysisType::CLASS
  end

  def family
    "area"
  end

end

