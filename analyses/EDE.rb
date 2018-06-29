
require InstallPath + 'AnalysisType'
require InstallPath + 'OutputSummary'
require InstallPath + 'SparseMatrix'
require InstallPath + 'Units'

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

    # 50% time here : SparseMatrix is slow
    scaledMat = SparseMatrix.new
    sum = 0
    rows = pIJ.rows
    cols = pIJ.cols
    rows.each do | row |
      cols.each do | col |
        entry = pIJ[row,col]
        if entry and row != col
          sum += entry
          scaledMat[row,col] = entry
        end
      end
    end

    # 50% time here : SparseMatrix is slow
    rows = scaledMat.rows
    cols = scaledMat.cols
    rows.each do | row |
      cols.each do | col |
        entry = scaledMat[row,col]
        scaledMat[row,col] = entry / sum if entry and sum > 0
      end
    end

    coversPresent = @image.file.classesPresent

    maxDiversity = 0.0
    maxDiversity = 2.0 * Math.log(coversPresent) if coversPresent > 0
    
    sum = 0
    pIJ.each { | entry | sum += entry * Math.log(entry) if entry > 0 }
    diversity = -sum
    
    if maxDiversity == 0.0
      ede = 0.0
    else
      ede = diversity / maxDiversity
    end

    [OutputSummary.new(name,abbrev,outType,ede,units,family,precision)]
  end

  def help(verbose)
    if verbose
      ["EDE - Edge Distribution Evenness",
       "",
       "  EDE reports the edge distribution evenness of the image. It is a",
       "  measure of how equally distributed are the edge types of an image.",
       "",
       "  EDE can range from zero for an image with no edge other than border",
       "  to 1.0 for an image whose edge types (connections between differing",
       "  classes) are all equally present within the image.",
       "",
       "  Note: This measure uses an adjacency matrix. [Riitters 96] discusses",
       "  how the method used to create the adjacency matrix can have a large",
       "  impact upon resulting metrics.",
       "",
       "  Definition: (given t, an adjacency matrix between classes present)",
       "",
       "  First the main diagonal of the adjacency matrix is set to zero and",
       "  the matrix is rescaled to sum to 1.0. Then:",
       "",
       "    EDE = measured diversity / maximum diversity",
       "",
       "  Measured diversity =  -1 * the sum of all combinations of classes",
       "  in the equation t(i,j) * ln(t(i,j). Maximum diversity is defined as",
       "  2 * ln (classes present).",
       "",
       "  Reference: For more information see [Riitters 96] and [Wickham 96]",
       "",
       "  [Riitters 96] - Riitters, O’Neill, et al. 1996. A note on contagion",
       "    indices for landscape analysis. Landscape Ecology 11:197-202.",
       "",
       "  [Wickham 96] - Wickham J.D., K.H. Riitters, R.V. O’Neill, K.B. Jones,",
       "    and T.G. Wade. 1996. Landscape ‘Contagion’ in Raster and Vector",
       "    Environments. International Journal of Geographical Information",
       "    Systems 7:891-89"
      ]
    else
      ["EDE - Edge Distribution Evenness"]
    end
  end

  def name
    "Edge Distribution Evenness"
  end

  def abbrev
    "EDE"
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
