
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
    
    eightNeighs = true
    setting = @options.find("Neighborhood")
    eightNeighs = false if setting and setting.value == "4"

    pIJ = @image.file.pIJ(eightNeighs,backGround)
    
    idm = 0.0
    rows = pIJ.rows
    cols = pIJ.cols
    rows.each do | row |
      cols.each do | col |
        idm += pIJ[row,col] / (1.0 + (row-col).abs);
      end
    end
    
    [OutputSummary.new(name,abbrev,outType,idm,units,family,precision)]
  end

  def help(verbose)
    if verbose
      ["IDM - Inverse Difference Moment",
       "",
       "  IDM reports the inverse difference moment of an image. It is a",
       "  measure of image texture. IDM ranges from 0.0 for an image that is",
       "  highly textured to 1.0 for an image that is untextured (such as an",
       "  image with a single class).",
       "",
       "  Note: This measure uses an adjacency matrix. [Riitters 96] discusses",
       "  how the method used to create the adjacency matrix can have a large",
       "  impact upon resulting metrics.",
       "",
       "  Definition: given t, an adjacency matrix between the classes present:",
       "    IDM = sum of all combinations of classes of:",
       "      (t(i,j)*t(i,j)) / (1 + (i-j)(i-j))",
       "",
       "  Limitations: Since IDM relies on the magnitude of differences between",
       "  cell values it is only appropriate to compute it from interval data",
       "  (as opposed to nominal data).",
       "",
       "  Reference: For more information see [Musick 91]",
       "",
       "  [Musick 91] - Musick, and Grover 1991. Image Textural Measures as",
       "    Indices of Landscape Pattern, chapter in Quantitative Methods in",
       "    Landscape Ecology, Turner and Gardner (1991). Springer-Verlag.",
       "    New York, New York, USA.",
       "",
       "  [Riitters 96] - Riitters, O’Neill, et al. 1996. A note on contagion",
       "    indices for landscape analysis. Landscape Ecology 11:197-202."
      ]
    else
      ["IDM - Inverse Difference Moment"]
    end
  end

  def name
    "Inverse Difference Moment"
  end

  def abbrev
    "IDM"
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
