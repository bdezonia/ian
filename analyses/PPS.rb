# Total polys printing as a float

# Polygon Perimeter Summaries

# mean, stddev, median, first quartile, third quartile, polys per class

require InstallPath + 'AnalysisType'
require InstallPath + 'OutputSummary'
require InstallPath + 'Calculator'

class Analysis

   def initialize(engine,options,image,distUnit,areaUnit,args)
     @options = options
     @image = image
     @unit = distUnit
   end
   
   def run
     backGround = -1
     setting = @options.find("Background")
     backGround = setting.dig_to_i(setting.value) if setting
     
     eightNeighbors = true
     setting = @options.find("Neighborhood")
     eightNeighbors = false if setting and setting.value == "4"
     
     polyPerims = @image.file.polyPerims(eightNeighbors)
     pClasses = @image.file.polyClasses(eightNeighbors)

     overallArray = []
     subArrays = {}
     
     (1...polyPerims.size).each do | pnum |
       polyColor = pClasses[pnum]
       if polyColor != backGround
         value = @unit.factor * polyPerims[pnum]
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
       OutputSummary.new("Mean Polygon Perimeter","AvPolyPerm",AnalysisType::IMAGE,overallMean,unit,"distance",3),
       # means
       OutputSummary.new("Mean Polygon Perimeter","AvPolyPerm",AnalysisType::CLASS,means,unit,"distance",3),
       # overallStdDev
       OutputSummary.new("Std. Dev. Polygon Perimeter","SDPolyPerm",AnalysisType::IMAGE,overallStdDev,unit,"distance",3),
       # stdDevs
       OutputSummary.new("Std. Dev. Polygon Perimeter","SDPolyPerm",AnalysisType::CLASS,stdDevs,unit,"distance",3),
       # overallMedian
       OutputSummary.new("Median Polygon Perimeter","MdPolyPerm",AnalysisType::IMAGE,overallMedian,unit,"distance",3),
       # medians
       OutputSummary.new("Median Polygon Perimeter","MdPolyPerm",AnalysisType::CLASS,medians,unit,"distance",3),
       # first
       OutputSummary.new("First Quartile Polygon Perimeter","Q1PolyPerm",AnalysisType::IMAGE,first,unit,"distance",3),
       # firsts
       OutputSummary.new("First Quartile Polygon Perimeter","Q1PolyPerm",AnalysisType::CLASS,firsts,unit,"distance",3),
       # third
       OutputSummary.new("Third Quartile Polygon Perimeter","Q3PolyPerm",AnalysisType::IMAGE,third,unit,"distance",3),
       # thirds
       OutputSummary.new("Third Quartile Polygon Perimeter","Q3PolyPerm",AnalysisType::CLASS,thirds,unit,"distance",3),
       # min
       OutputSummary.new("Minimum Polygon Perimeter","MnPolyPerm",AnalysisType::IMAGE,min,unit,"distance",3),
       # mins
       OutputSummary.new("Minimum Polygon Perimeter","MnPolyPerm",AnalysisType::CLASS,mins,unit,"distance",3),
       # max
       OutputSummary.new("Maximum Polygon Perimeter","MxPolyPerm",AnalysisType::IMAGE,max,unit,"distance",3),
       # maxes
       OutputSummary.new("Maximum Polygon Perimeter","MxPolyPerm",AnalysisType::CLASS,maxes,unit,"distance",3)
     ]
   end

   def unit
     @unit.unit
   end
   
   def help(verbose)
     if (verbose)
       ["PPS - Polygon Perimeter Summary Statistics",
        "",
        "  This analysis reports the following measures upon an image and its classes",
        "    Total polygons",
        "    Mean polygon perimeter",
        "    Standard Deviation of polygon perimeter",
        "    Median polygon perimeter",
        "    Interquartile range of polygon perimeter",
        "    Largest perimeter of polygons",
        "    Smallest perimeter of polygons"
       ]
     else
       ["PPS - Polygon Perimeter Summary Statistics"]
     end
   end
   
   def name
     "Polygon Perimeter Summary Statistics"
   end
   
   def outType
     AnalysisType::IMAGE | AnalysisType::CLASS
   end

end