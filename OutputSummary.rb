class OutputSummary

  def initialize(name,abbrev,type,data,unit,family,precision)
    @name = name
    @abbrev = abbrev
    @outType = type
    @output = data
    @unit = unit
    @family = family
    @precision = precision
  end

  attr_reader(:name,:abbrev,:outType,:output,:unit,:family,:precision)
end
