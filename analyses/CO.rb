
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
    
    coversPresent = @image.file.classesPresent
    
    maxDiversity = 0.0
    maxDiversity = 2.0 * Math.log(coversPresent) if coversPresent > 0
    
    sum = 0
    pIJ.each { | entry | sum += entry * Math.log(entry) if entry > 0 }
    diversity = -sum
    
    co = maxDiversity - diversity
    
    [OutputSummary.new(name,abbrev,outType,co,units,family,precision)]
  end

  def help(verbose)
    if verbose
      ["CO - Contagion",
       "",
       "  CO reports the contagion of the image. Contagion is a measure of",
       "  the degree to which classes are clumped into polygons. It is",
       "  estimated by determining the image’s departure from maximal diversity.",
       "  Contagion returns a value greater than or equal to zero. Large values",
       "  of contagion arise from images that are predominantly made up of",
       "  a few classes. Small values of contagion arise from images that are",
       "  made up of many different classes in approximately equal proportions.",
       "",
       "  Note: This measure is derived from an adjacency matrix. Different",
       "  methods of computing adjacency exist. If IAN's measure departs from",
       "  that of another package it may be due to differing methods of",
       "  calculating adjacency.",
       "",
       "  Definition: given an adjacency matrix T between classes present",
       "  contagion = maximum possible diversity - measured diversity.",
       "  Maximum diversity is 2 * ln(classes present) and measured diversity",
       "  is the sum of T(i,j) * ln(T(i,j)) for all combinations of classes i",
       "  and j.",
       "",
       "  Reference: For more information see Li H., and J.F. Reynolds. 1993.",
       "  A new contagion index to quantify spatial patterns of landscape.",
       "  Landscape Ecology 3:155-162."
      ]
    else
      ["CO - Contagion"]
    end
  end

  def name
    "Contagion"
  end

  def abbrev
    "Contagion"
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
