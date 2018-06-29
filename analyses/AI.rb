
# Aggregation Index

require InstallPath + 'AnalysisType'
require InstallPath + 'OutputSummary'

class Analysis

   def initialize(engine,options,image,distUnit,areaUnit,args)
     @image = image
     @options = options
     @engine = engine
   end
   
   def run
     backGround = -1
     setting = @options.find("Background")
     backGround = setting.dig_to_i(setting.value) if setting
     
     ai = 0.0
     ais = {}
     
     areas = @image.file.areas
     
     areas.each_index do | pixValue |
       ais[pixValue] = 0 if areas[pixValue] and areas[pixValue] > 0
     end
     
     rows = @image.file.rows
     cols = @image.file.cols
     
     rows.times do | row |
       cols.times do | col |
         pixel = @image.file.getCell(row,col)
         #print "AI: pixel[#{row}][#{col}] = #{pixel}\n"
         next if pixel == backGround
         if col != (cols-1)
           #print "Next col pixel = #{@image.file.getCell(row,col+1)}\n"
           if @image.file.getCell(row,col+1) == pixel
             if ais[pixel]
               ais[pixel] += 1
             else
               ais[pixel] = 1
             end
           end
         end
         if row != (rows-1)
           #print "Next row pixel = #{@image.file.getCell(row+1,col)}\n"
           if @image.file.getCell(row+1,col) == pixel
             if ais[pixel]
               ais[pixel] += 1
             else
               ais[pixel] = 1
             end
           end
         end
       end
     end
     
     ais.each_pair do | pixValue, edgeCount |
       numCells = areas[pixValue]
       if numCells and numCells > 0
         if numCells == 1
           ais[pixValue] = 1.0
         else #numCells > 1
           sqSz = Math.sqrt(numCells)
           sqSz += 1 if (sqSz - sqSz.floor) > 0
           sqSz = sqSz.floor.to_i
           maxEdges = ((sqSz*sqSz - numCells)/sqSz) - (2*sqSz) + (2*numCells)
           #if edgeCount > maxEdges
             #print "Error: edgeCount #{edgeCount} > maxEdges #{maxEdges}\n"
             #print "  sqSz #{sqSz}  numCells #{numCells}\n"
           #end
           ais[pixValue] = edgeCount.to_f / maxEdges
         end
#       else
#         ais[pixValue] = 0.0
       end
     end
     
     totArea = 0
     ais.each_key do | pixValue |
       totArea += areas[pixValue] if areas[pixValue]
     end
     
     ais.each_pair do | pixValue, aiMeasure |
       area = areas[pixValue]
       area = 0 if not area
       ai += (area.to_f / totArea) * aiMeasure
     end
     
     [OutputSummary.new(name,abbrev,AnalysisType::IMAGE,ai,units,family,precision),
      OutputSummary.new(name,abbrev,AnalysisType::CLASS,ais,units,family,precision)]
   end
   
   def help(verbose)
     if verbose
        ["AI - Aggregation Index",
         "",
         "  AI reports the aggregation indices upon an image. It is reported",
         "  for the image as a whole as well as for each class present",
         "  in the image.",
         "",
         "  An AI analysis reports values between zero and one. AI equals",
         "  1.0 when a class is completely aggregated into a single square",
         "  patch. It reports numbers closer to 0.0 when each patch is narrow",
         "  in one direction and long in another.",
         "",
         "  Definition: AI = total adjacent edges of class i with itself",
         "    divided by the maximum possible adjacent edges of class i",
         "    with itself.",
         "",
         "  Reference: He H. S., B. E. DeZonia and D. J. Mladenoff. 2000.",
         "    An aggregation index (AI) to quantify spatial patterns on",
         "    landscapes. Landscape Ecology 15: 591-601"
         
        ]
     else
        ["AI - Aggregation Index"]
     end
   end

   def name
     "Aggregation Index"
   end

   def abbrev
     "AggIndex"
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
