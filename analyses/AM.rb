
require InstallPath + 'AnalysisType'
require InstallPath + 'OutputSummary'
#require InstallPath + 'SparseMatrix'

class Analysis

  def initialize(engine,options,image,distUnit,areaUnit,args)
    @image = image
    @options = options
  end

  def run
    backGround = -1
    setting = @options.find("Background")
    backGround = setting.dig_to_i(setting.value) if setting
    
    eightNeighs = true
    setting = @options.find("Neighborhood")
    eightNeighs = false if setting and setting.value == "4"

    pIJ = @image.file.pIJ(eightNeighs,backGround)
    
    [OutputSummary.new(name,abbrev,outType,pIJ,units,family,precision)]
  end

  def help(verbose)
    if verbose
      ["AM - Adjacency Matrix",
       "",
       "  AM reports the adjacency matrix probabilities between classes",
       "  Output values range between 0.00% and 100.00% and represent the",
       "  proportional breakdown of neighbor cells. An AM value of 40% for",
       "  class I to class J implies that it is 40% probable that a given cell",
       "  on an image will be of class I and have class J adjacent to it.",
       "",
       "  Reference: Li H., and J.F. Reynolds. 1993. A new contagion index to",
       "  quantify spatial patterns of landscape. Landscape Ecology 3:155-162."
      ]
    else
      ["AM - Adjacency Matrix"]
    end
  end

  def name
    "Adjacency Matrix"
  end

  def abbrev
    "AdjMatrix"
  end
  
  def units
    NoUnit
  end

  def precision
    3
  end

  def outType
    AnalysisType::INTERCLASS
  end

  def family
    "scalar"
  end

end


# old way with ruby code
#
#  def run
#    backGround = -1
#    setting = @options.find("Background")
#    backGround = setting.dig_to_i(setting.value) if setting
#    
#    eightNeighs = true
#    setting = @options.find("Neighborhood")
#    eightNeighs = false if setting and setting.value == "4"
#
#    nIJ = SparseMatrix.new
#    nI = {}
#    rows = @image.file.rows
#    cols = @image.file.cols
#    (rows-1).downto(0) do | row |
#      cols.times do | col |
#        cover1 = @image.file.getCell(row,col)
#        next if cover1 == backGround
#       
#        # look right
#        if col < cols-1
#          cover2 = @image.file.getCell(row,col+1)
#          if cover2 != backGround
#            num = nIJ[cover1,cover2]
#            nIJ[cover1,cover2] = 0 if not num
#            nIJ[cover1,cover2] += 1
#            num = nI[cover1]
#            nI[cover1] = 0 if not num
#            nI[cover1] += 1
#            num = nIJ[cover2,cover1]
#            nIJ[cover2,cover1] = 0 if not num
#            nIJ[cover2,cover1] += 1
#            num = nI[cover2]
#            nI[cover2] = 0 if not num
#            nI[cover2] += 1
#          end
#        end
#        
#        # look down
#        if row > 0
#          # due south
#          cover2 = @image.file.getCell(row-1,col)
#          if cover2 != backGround
#            num = nIJ[cover1,cover2]
#            nIJ[cover1,cover2] = 0 if not num
#            nIJ[cover1,cover2] += 1
#            num = nI[cover1]
#            nI[cover1] = 0 if not num
#            nI[cover1] += 1
#            num = nIJ[cover2,cover1]
#            nIJ[cover2,cover1] = 0 if not num
#            nIJ[cover2,cover1] += 1
#            num = nI[cover2]
#            nI[cover2] = 0 if not num
#            nI[cover2] += 1
#          end
#          
#          if eightNeighs
#          
#            # southwest
#            if col > 0
#              cover2 = @image.file.getCell(row-1,col-1)
#              if cover2 != backGround
#                num = nIJ[cover1,cover2]
#                nIJ[cover1,cover2] = 0 if not num
#                nIJ[cover1,cover2] += 1
#                num = nI[cover1]
#                nI[cover1] = 0 if not num
#                nI[cover1] += 1
#                num = nIJ[cover2,cover1]
#                nIJ[cover2,cover1] = 0 if not num
#                nIJ[cover2,cover1] += 1
#                num = nI[cover2]
#                nI[cover2] = 0 if not num
#                nI[cover2] += 1
#              end
#            end
#            
#            # southeast
#            if col < cols-1
#              cover2 = @image.file.getCell(row-1,col+1)
#              if cover2 != backGround
#                num = nIJ[cover1,cover2]
#                nIJ[cover1,cover2] = 0 if not num
#                nIJ[cover1,cover2] += 1
#                num = nI[cover1]
#                nI[cover1] = 0 if not num
#                nI[cover1] += 1
#                num = nIJ[cover2,cover1]
#                nIJ[cover2,cover1] = 0 if not num
#                nIJ[cover2,cover1] += 1
#                num = nI[cover2]
#                nI[cover2] = 0 if not num
#                nI[cover2] += 1
#              end
#            end
#            
#          end
#        end
#      end
#    end
#
#    covers = nIJ.rows.dup
#    
#    pJI = SparseMatrix.new    
#    covers.each do | cover1 |
#      covers.each do | cover2 |
#        num1 = nI[cover1]
#        if num1 and num1 > 0
#          num12 = nIJ[cover1,cover2]
#          if num12
#            pJI[cover1,cover2] =  num12.to_f / num1
#          else
#            pJI[cover1,cover2] = 0.0
#          end
#        else
#          pJI[cover1,cover2] = 0.0
#        end
#      end
#    end
#    
#    areas = @image.file.areas
#    occupiedCells = @image.file.area
#    if backGround != -1
#      backArea = areas[backGround]
#      occupiedCells -= backArea if backArea
#    end
#    pI = {}
#    covers.each do | cover |
#      area = areas[cover]
#      area = 0 if area.nil?
#      pI[cover] = area.to_f / occupiedCells if occupiedCells > 0
#    end
#    
#    pIJ = SparseMatrix.new
#    covers.each do | cover1 |
#      covers.each do | cover2 |
#        pIJ[cover1,cover2] = pI[cover1] * pJI[cover1,cover2]
#      end
#    end
#    
#    [OutputSummary.new(name,outType,pIJ,units,family,precision)]
#  end
