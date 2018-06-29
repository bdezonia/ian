
require InstallPath + 'AnalysisType'
require InstallPath + 'OutputSummary'
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
    
    coversPresent = @image.file.classesPresent

    maxDiversity = 0.0
    maxDiversity = 2.0 * Math.log(coversPresent) if coversPresent > 0
    
    sum = 0
    pIJ.each { | entry | sum += entry * Math.log(entry) if entry > 0 }
    diversity = -sum
    
    if maxDiversity == 0.0
      rco = 0.0
    else
      rco = 100.0*(1.0 - (diversity/maxDiversity))
    end
    
    [OutputSummary.new(name,abbrev,outType,rco,units,family,precision)]
  end

  def help(verbose)
    if verbose
      ["RCO - Relative Contagion",
       "",
       "  RCO reports the relative contagion of the image. It is based upon",
       "  Riitter's version of contagion (corrections made to Li's version).",
       "  Contagion is a measure of the degree to which classes are clumped",
       "  into polygons.",
       "",
       "  RCO reports relative contagion values. Therefore the possible values",
       "  range from 0.0 for images with minimal contagion to 1.0 for images",
       "  with maximum contagion.",
       "",
       "  Note: This measure uses an adjacency matrix. [Riitters 96] discusses",
       "  how the method used to create the adjacency matrix can have a large",
       "  impact upon resulting metrics.",
       "",
       "  Definition: (given t, an adjacency matrix between classes present)",
       "",
       "    RCO = 1.0 - (measured diversity / maximum diversity)",
       "",
       "  Measured diversity =  -1 * the sum of all combinations of classes",
       "  in the equation t(i,j) * ln(t(i,j). Maximum diversity is defined as",
       "  2 * ln (classes present).",
       "",
       "  Reference: For more information see [Riitters 96]",
       "",
       "  [Riitters 96] - Riitters, O’Neill, et al. 1996. A note on contagion",
       "    indices for landscape analysis. Landscape Ecology 11:197-202."
      ]
    else
      ["RCO - Relative Contagion"]
    end
  end

  def name
    "Relative Contagion"
  end

  def abbrev
    "RelContag"
  end

  def units
    Units.find("percent")
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
