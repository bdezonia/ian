# Total polys printing as a float

# Polygon Area Summaries

# mean, stddev, median, first quartile, third quartile, polys per class

require InstallPath + 'AnalysisType'
require InstallPath + 'OutputSummary'
require InstallPath + 'Calculator'

class Analysis

   def initialize(engine,options,image,distUnit,areaUnit,args)
     @options = options
     @image = image
     @unit = areaUnit
   end
   
   def run
     backGround = -1
     setting = @options.find("Background")
     backGround = setting.dig_to_i(setting.value) if setting
     
     eightNeighbors = true
     setting = @options.find("Neighborhood")
     eightNeighbors = false if setting and setting.value == "4"
     
     polyAreas = @image.file.polyAreas(eightNeighbors)
     pClasses = @image.file.polyClasses(eightNeighbors)

     overallArray = []
     subArrays = {}
     
     (1...polyAreas.size).each do | pnum |
       polyColor = pClasses[pnum]
       if polyColor != backGround
         value = @unit.factor * polyAreas[pnum]
         overallArray << value
         if subArrays[polyColor]
           subArrays[polyColor] << value
         else
           subArrays[polyColor] = [value]
         end
       end
     end

     overallMeasures = Calculator.statSummary(overallArray)
     
     totalPolys = overallArray.length
     overallMean = overallMeasures[0]
     overallStdDev = overallMeasures[1]
     overallMedian = overallMeasures[2]
     first = overallMeasures[3]
     third = overallMeasures[4]
     min = overallMeasures[5]
     max = overallMeasures[6]
     
     classMeasures = {}
     polys = {}
     subArrays.each_pair do | color, subArray |
       classMeasures[color] = Calculator.statSummary(subArray)
       polys[color] = subArray.length
     end
     
     means = {}
     stdDevs = {}
     medians = {}
     firsts = {}
     thirds = {}
     mins = {}
     maxes = {}
     
     classMeasures.each_pair do | color, measures |
       means[color] = measures[0]
       stdDevs[color] = measures[1]
       medians[color] = measures[2]
       firsts[color] = measures[3]
       thirds[color] = measures[4]
       mins[color] = measures[5]
       maxes[color] = measures[6]
     end

     # create output summaries
     
     [
       # totalPolys
       OutputSummary.new("Total Polygons","Polygons",AnalysisType::IMAGE,totalPolys,NoUnit,"scalar",0),
       # polys
       OutputSummary.new("Total Polygons","Polygons",AnalysisType::CLASS,polys,NoUnit,"scalar",0),
       # overallMean
       OutputSummary.new("Mean Polygon Area","AvPolyArea",AnalysisType::IMAGE,overallMean,unit,"area",3),
       # means
       OutputSummary.new("Mean Polygon Area","AvPolyArea",AnalysisType::CLASS,means,unit,"area",3),
       # overallStdDev
       OutputSummary.new("Std. Dev. Polygon Area","SDPolyArea",AnalysisType::IMAGE,overallStdDev,unit,"area",3),
       # stdDevs
       OutputSummary.new("Std. Dev. Polygon Area","SDPolyArea",AnalysisType::CLASS,stdDevs,unit,"area",3),
       # overallMedian
       OutputSummary.new("Median Polygon Area","MdPolyArea",AnalysisType::IMAGE,overallMedian,unit,"area",3),
       # medians
       OutputSummary.new("Median Polygon Area","MdPolyArea",AnalysisType::CLASS,medians,unit,"area",3),
       # first
       OutputSummary.new("First Quartile Polygon Area","Q1PolyArea",AnalysisType::IMAGE,first,unit,"area",3),
       # firsts
       OutputSummary.new("First Quartile Polygon Area","Q1PolyArea",AnalysisType::CLASS,firsts,unit,"area",3),
       # third
       OutputSummary.new("Third Quartile Polygon Area","Q3PolyArea",AnalysisType::IMAGE,third,unit,"area",3),
       # thirds
       OutputSummary.new("Third Quartile Polygon Area","Q3PolyArea",AnalysisType::CLASS,thirds,unit,"area",3),
       # min
       OutputSummary.new("Minimum Polygon Area","MnPolyArea",AnalysisType::IMAGE,min,unit,"area",3),
       # mins
       OutputSummary.new("Minimum Polygon Area","MnPolyArea",AnalysisType::CLASS,mins,unit,"area",3),
       # max
       OutputSummary.new("Maximum Polygon Area","MxPolyArea",AnalysisType::IMAGE,max,unit,"area",3),
       # maxes
       OutputSummary.new("Maximum Polygon Area","MxPolyArea",AnalysisType::CLASS,maxes,unit,"area",3)
     ]
   end

   def unit
     @unit.unit
   end
   
   def help(verbose)
     if (verbose)
       ["PAS - Polygon Area Summary Statistics",
        "",
        "  This analysis reports the following measures upon an image and its classes",
        "    Total polygons",
        "    Mean polygon area",
        "    Standard Deviation of polygon area",
        "    Median polygon area",
        "    Interquartile range of polygon area",
        "    Area of smallest polygon",
        "    Area of largest polygon"
       ]
     else
       ["PAS - Polygon Area Summary Statistics"]
     end
   end
   
   def name
     "Polygon Area Summary Statistics"
   end
   
   def outType
     AnalysisType::IMAGE | AnalysisType::CLASS
   end

end