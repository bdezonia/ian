
require InstallPath + 'AnalysisType'
require InstallPath + 'SparseMatrix'
require InstallPath + 'OutputSummary'

class Analysis

  def initialize(engine,options,image,distUnit,areaUnit,args)
    @image = image
    @unit = distUnit
    @options = options
  end
   
  def run
    backGround = -1
    setting = @options.find("Background")
    backGround = setting.dig_to_i(setting.value) if setting
    
    ctr = n = s = e = w = nil    # predefine for speed
    @output = SparseMatrix.new
    @image.file.each5 do | ctr, n, s, e, w |
      next if ctr == backGround
      if n and n != backGround
        if @output[ctr,n]
          @output[ctr,n] += 1
        else
          @output[ctr,n] = 1
        end
      end
      if w and w != backGround
        if @output[ctr,w]
          @output[ctr,w] += 1
        else
          @output[ctr,w] = 1
        end
      end
      if e and e != backGround
        if @output[ctr,e]
          @output[ctr,e] += 1
        else
          @output[ctr,e] = 1
        end
      end
      if s and s != backGround
        if @output[ctr,s]
          @output[ctr,s] += 1
        else
          @output[ctr,s] = 1
        end
      end
    end
    @output.each_coord { | row,col | @output[row,col] *= @unit.factor }
    [OutputSummary.new(name,abbrev,outType,@output,units,family,precision)]
  end
   
  def help(verbose)
    if verbose
      ["SP - shared perimeter between classes"]
    else
      ["SP - shared perimeters"]
    end
  end

  def name
    "Shared perimeter between classes"
  end
  
  def abbrev
    "SharePerim"
  end

  def units
    @unit.unit
  end

  def precision
    3
  end

  def outType
    AnalysisType::INTERCLASS
  end

  def family
    "distance"
  end

end
