
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
     classesPresent = 0
     areas.each_index do | index |
       if index != backGround and areas[index]
         classesPresent += 1
         relArea = areas[index].to_f / totalCells
         sum = sum + (relArea * Math.log(relArea))
       end
     end
     if classesPresent == 0
       swe = 0.0
     elsif classesPresent == 1
       swe = 0.0   # should be infinity but we'll not allow
     else
       diversity = 0.0 - sum
       maxDiversity = Math.log(classesPresent)
       swe = diversity / maxDiversity
     end
     [OutputSummary.new(name,abbrev,outType,swe,units,family,precision)]
   end
   
   def help(verbose)
     if verbose
       ["SWE - Shannon Weaver evenness",
        "",
        "  SWE reports the relative diversity of the image where diversity is",
        "  defined as described by [Shannon 62]. Relative diversity is",
        "  computed as the measured diversity of the image divided by the",
        "  maximum possible diversity for the image. SWE values range between",
        "  0 and 1 inclusive.",
        "",
        "  Definition: (given p, a probability distribution of the classes present)",
        "    SWE = measured diversity / maximum diversity",
        "  where measured diversity =  -1 * sum over all classes of p(i)*ln(p(i))",
        "  and maximum diversity = ln(classes present).",
        "",
        "  [Shannon 62] - Shannon and Weaver. 1962. The mathematical theory of",
        "  communication. University of Illinois Press. Urbana, Illinois, USA."
       ]
     else
       ["SWE - Shannon Weaver evenness"]
     end
   end

   def name
     "Shannon Weaver Evenness"
   end

   def abbrev
     "SWE"
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
