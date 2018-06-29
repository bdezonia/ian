
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
    asm = 0.0
    pIJ.each do | entry |
      asm += entry * entry
    end
    
    [OutputSummary.new(name,abbrev,outType,asm,units,family,precision)]
  end

  def help(verbose)
    if verbose
      ["ASM - Angular Second Moment",
       "",
       "  ASM reports the angular second moment of the image. It is a measure",
       "  of image texture. ASM ranges from 0.0 for an image with many classes",
       "  and little clumping to 1.0 for an image with a single class",
       "  (maximum clumping).",
       "",
       "  Note: This measure is derived from an adjacency matrix. In a paper",
       "  in 1996 Riitters discusses how the method used to create the",
       "  adjacency matrix can have a large impact upon resulting metrics.",
       "  This can explain where IAN may differ from another package on this",
       "  measure.",
       "",
       "  Definition: given an adjacency matrix between the classes present",
       "  ASM = the sum of the squared adjacencies for all combinations of the",
       "  classes present."
      ]
    else
      ["ASM - Angular Second Moment"]
    end
  end

  def name
    "Angular Second Moment"
  end

  def abbrev
    "ASM"
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
