
require InstallPath + 'AnalysisType'
require InstallPath + 'SparseMatrix'
require InstallPath + 'OutputSummary'
require InstallPath + 'Calculator'

class Analysis

  def initialize(engine,options,image,distUnit,areaUnit,args)
    @image = image
    @options = options
  end
   
  def run
    backGround = -1
    setting = @options.find("Background")
    backGround = setting.dig_to_i(setting.value) if setting

    edgesTouching = {}
    edgesBetween = SparseMatrix.new
    totalEdges = 0
    
    rows = @image.file.rows
    cols = @image.file.cols
    
    rows.times do | row |
    
      cols.times do | col |
      
        color = @image.file.getCell(row,col)
        
        next if color == backGround
        
        if row != rows-1
        
          if edgesTouching[color]
            edgesTouching[color] += 1
          else
            edgesTouching[color] = 1
          end
          
          totalEdges += 1

          neighColor = @image.file.getCell(row+1,col)

          if neighColor != backGround
          
            if neighColor != color
            
              if edgesTouching[neighColor]
                edgesTouching[neighColor] += 1
              else
                edgesTouching[neighColor] = 1
              end
              
              if edgesBetween[color,neighColor]
                edgesBetween[color,neighColor] += 1
              else
                edgesBetween[color,neighColor] = 1
              end
              
              if edgesBetween[neighColor,color]
                edgesBetween[neighColor,color] += 1
              else
                edgesBetween[neighColor,color] = 1
              end
            end
            
          end
          
        end  # not last row
        
        if col != cols-1
        
          if edgesTouching[color]
            edgesTouching[color] += 1
          else
            edgesTouching[color] = 1
          end
          
          totalEdges += 1

          neighColor = @image.file.getCell(row,col+1)

          if neighColor != backGround
          
            if neighColor != color
            
              if edgesTouching[neighColor]
                edgesTouching[neighColor] += 1
              else
                edgesTouching[neighColor] = 1
              end
              
              if edgesBetween[color,neighColor]
                edgesBetween[color,neighColor] += 1
              else
                edgesBetween[color,neighColor] = 1
              end
              
              if edgesBetween[neighColor,color]
                edgesBetween[neighColor,color] += 1
              else
                edgesBetween[neighColor,color] = 1
              end
            end
            
          end
          
        end  # not last col
        
      end # each col
      
    end  # each row
    
    # At this point edgesBetween is a symmetric matrix that counts the
    # number of edges between cover types (other than self).
    # And edgesTouching is an array counting the total number of edges
    # that actually border on each cover type.
    
    electivity = SparseMatrix.new
    significance = SparseMatrix.new

    colors = edgesTouching.keys.to_a.sort
    
    colors.each do | i |
      colors.each do | j |
        if i == j
          electivity[i,j] = +Calculator::Infinity
          significance[i,j] = +Calculator::Infinity
        else
          # Derived from Jenkins79 using Fienberg80
          #
          #   define our 2x2 table as: (note !cut == available)
          #
          #                  cut        !cut
          #   genus i  x11 =  x    x12 =  y      x+y
          #   other    x21 = m-x   x22 = n-y   m+n-x-y
          #                   m           n      m+n
          #
          #   then our probalilities are as such:
          #     Rij = x/m   Pij = y/n
          #
          #   if you play with formulation you will see that
          #     x2 = significance formula below

          #             touchj     ~touchj
          #    touchi  x11 =  x    x12 =  y      x+y
          #   ~touchi  x21 = m-x   x22 = n-y   m+n-x-y
          #               m           n          m+n

          x11 = edgesBetween[i,j].to_f
          x12 = edgesTouching[i] - x11
          x21 = edgesTouching[j] - x11
          x22 = totalEdges - x11 - x12 - x21

          rIJ = 0.0
          if x11 != 0.0  # avoid divide by zero in degenerate case
            rIJ = x11 / (x11+x21)
          end
          
          pIJ = 0.0
          if x12 != 0.0  # avoid divide by zero in degenerate case
            pIJ = x12 / (x12+x22)
          end
          
          if (rIJ == 0.0 || pIJ == 1.0)
            electivity[i,j] = -Calculator::Infinity
            significance[i,j] = +Calculator::Infinity
          
          elsif (rIJ == 1.0 || pIJ == 0.0)
            electivity[i,j] = +Calculator::Infinity
            significance[i,j] = +Calculator::Infinity

          else  # electivity will not be an infinite number
            electivity[i,j] = Math.log((rIJ*(1-pIJ)) / (pIJ*(1-rIJ)))
            val = Math.log(x11) + Math.log(x22) - Math.log(x12) - Math.log(x21)
            significance[i,j] = val*val
            significance[i,j] /= ((1.0/x11) + (1.0/x22) + (1.0/x12) + (1.0/x21))
          end
        end
      end
    end
    
    [OutputSummary.new("Electivity","Electivity",outType,electivity,units,family,precision),
     OutputSummary.new("Significance","Signif",outType,significance,units,family,precision)
    ]
  end
   
  def help(verbose)
    if verbose
      ["EL - Electivity",
       "",
       "  EL reports the electivity between classes present in the image.",
       "  The electivity index calculated is equivalent to log Q as specified",
       "  in the [Jacobs 74] paper (detailed below).",
       "",
       "  Electivity measures the strength of association between the classes.",
       "  For the purposes of EL association is measured from the number of",
       "  times two classes border on each other relative to the maximum",
       "  coupling possible. EL results range from minus infinity for two",
       "  classes that never neighbor each other to positive infinity for two",
       "  classes that always neighbor each other.",
       "",
       "  Definition: EL = (Rij * (1-Pij)) / (Pij * (1-Rij)) where",
       "    Rij = x11 / (x11 + x21) and Pij = x12 / (x12 + x22) and:",
       "    x11 = couplings in which I and J participate",
       "    x12 = couplings in which I participates and J does not",
       "    x21 = couplings in which J participates and I does not",
       "    x22 = couplings in which neither I nor J participates",
       "",
       "  Note: only 4 neighbors are considered for couplings",
       "",
       "  Reference: For more information regarding this specific electivity",
       "  index see [Mladenoff 93], [Pastor 90], and [Jacobs 74]. For more",
       "  information regarding electivity indices in general see",
       "  [Lechowicz 82].",
       "",
       "  [Jacobs 74] - Jacobs J. 1974. Quantitative Measurement of Food",
       "    Selection. Oecologia 14:413-417",
       "",
       "  [Lechowicz 82] - Lechowicz M.J. 1982. The Sampling Characteristics",
       "    of Electivity Indices. Oecologia 52:22-30",
       "",
       "  [Mladenoff 93] - Mladenoff D.J., M.A. White, J. Pastor, and T.R.",
       "    Crow. 1993. Comparing spatial pattern in unaltered old-growth and",
       "    disturbed forest landscapes. Ecological Applications 2:294-306",
       "",
       "  [Pastor 90] - Pastor J., and M. Broschart. 1990. The spatial pattern",
       "    of a northern conifer-hardwood landscape. Landscape Ecology 1:55-68."
      ]
    else
      ["EL - Electivity"]
    end
  end

  def name
    "Electivity"
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
