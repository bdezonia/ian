
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
      array = @image.file.areas
      hash = {}
      array.each_index do | color |
        if color != backGround and array[color]
          hash[color] = @unit.factor * array[color]
        end
      end
     [OutputSummary.new(name,abbrev,outType,hash,@unit.unit,family,precision)]
   end
   
   def help(verbose)
      if verbose
         ["AR - area of each class"]
      else
         ["AR - area of each class"]
      end
   end

   def name
     "Area"
   end

   def abbrev
     "Area"
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
