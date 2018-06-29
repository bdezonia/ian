
require InstallPath + 'AnalysisType'
require InstallPath + 'OutputSummary'

class Analysis

   def initialize(engine,options,image,distUnit,areaUnit,args)
      @image = image
      @options = options
   end
   
   def run
     backGround = -1
     setting = @options.find("Background")
     backGround = setting.dig_to_i(setting.value) if setting
     areas = @image.file.areas
     totalCells = @image.file.area
     if backGround != -1
       backCells = @image.file.areas[backGround]
       totalCells -= backCells if backCells
     end
     sum = 0.0
     areas.each_index do | index |
       if index != backGround and areas[index]
         relArea = areas[index].to_f / totalCells
         sum = sum + (relArea * Math.log(relArea))
       end
     end
     sum = 0.0 - sum
     [OutputSummary.new(name,abbrev,outType,sum,units,family,precision)]
   end
   
  def help(verbose)
    if verbose
      ["SWD - Shannon Weaver diversity",
       "",
       "  SWD reports the diversity of the image as described by [Shannon 62].",
       "  SWD results are always greater than or equal to zero. A low",
       "  diversity measure implies an image is dominated by a single class.",
       "  A high diversity measure implies an image that contains many classes",
       "  in approximately equal proportions.",
       "",
       "  Definition: (given p, a probability distribution of the classes present)",
       "    SWD = -1 * sum over all classes of p(i)*ln(p(i))",
       "",
       "  Reference: For more information see [Turner 90]",
       "",
       "  [Shannon 62] - Shannon and Weaver. 1962. The mathematical theory of",
       "    communication. University of Illinois Press. Urbana, Illinois, USA.",
       "",
       "  [Turner 90] - Turner M.G. 1990. Spatial and temporal analysis of",
       "    landscape patterns. Landscape Ecology 1:21-30."
      ]
    else
      ["SWD - Shannon Weaver diversity"]
    end
  end

   def name
     "Shannon Weaver Diversity"
   end
   
   def abbrev
     "SWD"
   end

   def units
     NoUnit
   end

   def precision
     3
   end

   def outType
     AnalysisType::IMAGE
   end

   def family
     "scalar"
   end

end
