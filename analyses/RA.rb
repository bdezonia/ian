
# relative area by class

require InstallPath + 'AnalysisType'
require InstallPath + 'Units.rb'
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
     relAreas = {}
     areas.each_index do | index |
       if index != backGround and areas[index]
         relAreas[index] = (areas[index]*100.0) / totalCells
       end
     end
     [OutputSummary.new(name,abbrev,outType,relAreas,units,family,precision)]
   end
   
   def help(verbose)
      if verbose
         ["RA - Relative Area of each class"]
      else
         ["RA - Relative Area"]
      end
   end

   def name
     "Relative Area"
   end

   def abbrev
     "RelArea"
   end

   def units
     Units.find("percent")
   end

   def precision
     2
   end

   def outType
     AnalysisType::CLASS
   end

   def family
     "scalar"
   end
   
end
