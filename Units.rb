
# todo : remove downcase calls? some units might conflict like mbps, MBps do

class MathStatement

  # will handle * and / and + and - and ()'s of floats
  
  def initialize(string)
    @txt = string
  end
  
  def evaluate
    if @txt =~ /^(.*)\s*\*\s*(.*)\s*\*\s*(.*)$/         # a * b * c
      a = $1
      b = $2
      c = $3
      a.to_f * b.to_f * c.to_f
    elsif @txt =~ /^(.*)\s*\*\s*(.*)\s*\/\s*(.*)$/      # a * b / c
      a = $1
      b = $2
      c = $3
      (a.to_f * b.to_f) / c.to_f
    elsif @txt =~ /^(.*)\s*\/\s*(.*)\s*\*\s*(.*)$/      # a / b * c
      a = $1
      b = $2
      c = $3
      (a.to_f / b.to_f) * c.to_f
    elsif @txt =~ /^(.*)\s*\/\s*(.*)\s*\/\s*(.*)$/      # a / b / c
      a = $1
      b = $2
      c = $3
      (a.to_f / b.to_f) / c.to_f
    elsif @txt =~ /^(.*)\s*\*\s*(.*)$/                  # a * b
      a = $1
      b = $2
      a.to_f * b.to_f
    elsif @txt =~ /^(.*)\s*\\\s*(.*)$/                  # a / b
      a = $1
      b = $2
      a.to_f / b.to_f
    else
      @txt.to_f                                         # a
    end
  end
end

class Unit

  # name : e.g. millimeter
  # pluralName : e.g. millimeters
  # abbrev : e.g. mm
  # factor : a float, number of units per base unit
  # baseUnit:    name of defined unit
  #   if self.baseUnit == self.name its a base unit

  def initialize(unitName,pluralName,abbrev,conversionFactor,baseUnitName,family)
    @name = unitName
    @pluralName = pluralName
    @abbrev = abbrev
    @factor = conversionFactor
    @baseUnit = baseUnitName
    @family = family
  end
  
  attr_reader(:name,:pluralName,:abbrev,:factor,:baseUnit,:family)
  
end

class Vertex
  def initialize(unit)
    @unit = unit
    @to = nil
    @froms = Array.new
    @visited = false
  end
  
  def setTo(otherVert)
    @to = otherVert
  end
  
  def addFrom(otherVert)
    if not @froms.include?(otherVert)
      @froms << otherVert if not otherVert == self
    end
  end
  
  attr_reader(:unit,:to,:froms)
  attr_accessor(:visited)
end

class UnitConverter

  def initialize
    # initialize graph structure
    @vertices = []
    # edges are implicit
  end
  
  def add(unit)   # add unit to graph structure
    vert1 = @vertices.find { | vertex | vertex.unit == unit }
    if vert1.nil?
      @vertices << Vertex.new(unit)
      vert1 = @vertices.last
    end
    otherUnit = Units.find(unit.baseUnit)
    vert2 = @vertices.find { | vertex | vertex.unit == otherUnit }
    if vert2.nil?
      @vertices << Vertex.new(otherUnit)
      vert2 = @vertices.last
    end
    vert1.setTo(vert2)
    vert2.addFrom(vert1)
  end

  def convert(fromVert,toVert)
    fromVert.visited = true
    if fromVert == toVert
      return 1.0
    end
    if fromVert.to == toVert
      return fromVert.unit.factor
    end
    if toVert.to == fromVert
      return 1.0 / toVert.unit.factor
    end
    if fromVert.to != fromVert # not a base unit
      if not fromVert.to.visited
        factor = convert(fromVert,fromVert.to) * convert(fromVert.to,toVert)
        return factor if factor != 0.0
      end
    end
    fromVert.froms.each do | nextVert |
      if not nextVert.visited
        factor = convert(fromVert,nextVert) * convert(nextVert,toVert)
        return factor if factor != 0.0
      end
    end
    0.0
  end
  
  def factor(fromUnitString, toUnitString)
    # returns conversion as float if found, 0.0 if not
    
    fromUnit = Units.find(fromUnitString)
    return 0.0 if fromUnit.nil?
    
    fromVert = @vertices.find { | vertex | vertex.unit == fromUnit }
    
    toUnit = Units.find(toUnitString)
    return 0.0 if toUnit.nil?
    
    toVert = @vertices.find { | vertex | vertex.unit == toUnit }
    
    @vertices.each { | vertex | vertex.visited = false }
    
    convert(fromVert,toVert)
  end
end

class UnitFamily
  def initialize
    @unitsByName = Hash.new
    @unitsByPluralName = Hash.new
    @unitsByAbbrev = Hash.new
  end
  
  def add(unit)
    @unitsByName[unit.name] = unit if unit.name
    @unitsByPluralName[unit.pluralName] = unit if unit.pluralName
    @unitsByAbbrev[unit.abbrev] = unit if unit.abbrev
  end
  
  def delete(unit)
    @unitsByName[unit.name] = nil if unit.name
    @unitsByPluralName[unit.pluralName] = nil if unit.pluralName
    @unitsByAbbrev[unit.abbrev] = nil if unit.abbrev
  end
  
  def find(unitName)
    unit = @unitsByAbbrev[unitName]
    unit = @unitsByName[unitName] if unit.nil?
    unit = @unitsByPluralName[unitName] if unit.nil?
    unit
  end
  
  def totalUnits
    @unitsByName.size
  end
  
  def getUnit(i)
    @unitsByName.to_a[i][1]
  end
  
  def each
    @unitsByName.each_pair { | unitName, unit |  yield unit }
  end
end

class UnitLibrary

  def initialize(dataFile)
    @unitFamilies = Hash.new
    @converter = nil
    
    # read in from data file
    file = File.open(dataFile)
    if file
      while not file.eof
        line = file.gets
        if (line =~ /(.*),(.*),(.*),(.*),(.*),(.*)/)
          name = $1
          pluralName = $2
          abbrev = $3
          factor = $4
          base = $5
          type = $6
          
          # get rid of newline
          type.chomp!
          
          # get rid of whitespace
          name.strip!
          pluralName.strip!
          abbrev.strip!
          factor.strip!
          base.strip!
          type.strip!
          
          # must convert factor to float
          factor = MathStatement.new(factor).evaluate
          
          # add the unit to the library          
          add(Unit.new(name,pluralName,abbrev,factor,base,type))
        end
      end
      file.close
    end
  end

  def find(unitName)
    @unitFamilies.each_value do | unitFamily |
      unit = unitFamily.find(unitName.downcase)
      return unit if unit
    end
    nil
  end

  def add(unit)
    if unit
      type = unit.family.downcase
      unitFamily = @unitFamilies[type]
      if unitFamily.nil?
        unitFamily = UnitFamily.new
        @unitFamilies[type] = unitFamily
      end
      unitFamily.add(unit)
      @converter = nil
    end
  end

  def delete(unit)
    unitFamily = @unitFamilies[unit.family.downcase]
    if unit
      unitFamily.delete(unit)
      @converter = nil
    end
  end

  def makeConverter
    @converter = UnitConverter.new
    @unitFamilies.each_value do | unitFamily |
      for i in 0...unitFamily.totalUnits
        @converter.add(unitFamily.getUnit(i))
      end
    end
  end
  
  def convert(fromUnit,toUnit)
    makeConverter if @converter.nil?
    @converter.factor(fromUnit,toUnit)
  end
  
  def each(family)
    @unitFamilies.each_pair do | familyName, unitFamily |
      if familyName == family
        unitFamily.each do | unit |
          yield unit
        end
      end
    end
  end
  
end

class UnitHolder
  def initialize
    @unit = nil
    @factor = nil
  end
  attr_accessor(:unit,:factor)
end

class UnitizedNumber < UnitHolder
  def initialize(desiredUnit,imageUnit,family)  # units come in as UnitHolders
    super()
#print "d=",desiredUnit.factor,desiredUnit.unit,"i=",imageUnit.factor,imageUnit.unit,"f=",family,"\n"
    if imageUnit.unit.nil?
      if desiredUnit.unit.nil?
        self.factor = 1
#print "a : factor = ",self.factor,"\n"
        case family
          when "distance"
            self.unit = Units.find("edges")
          when "area"
            self.unit = Units.find("cells")
          else
            self.unit = NoUnit
        end
      else  # desired unit specified
        self.unit = desiredUnit.unit
        if desiredUnit.factor.nil? or desiredUnit.factor == 0
          self.factor = 1
        else
          self.factor = desiredUnit.factor
        end
#print "b : factor = ",self.factor,"\n"
      end
    else  # image has its own units: figure conversion if possible
      imageFactor = imageUnit.factor
      imageFactor = 1 if imageFactor and imageFactor <= 0
      if desiredUnit.unit.nil?
        self.unit = imageUnit.unit
        if imageFactor.nil?
          self.factor = 1
        else
          self.factor = imageFactor
        end
#print "c : factor = ",self.factor,"\n"
      else  # image has a unit and we desire another unit
      
        if desiredUnit.factor # user specified edge/cell size explicitly
          self.unit = desiredUnit.unit
          self.factor = desiredUnit.factor
          self.factor = 1 if self.factor == 0.0
#print "d : factor = ",self.factor,"\n"
        else  # desired factor is nil : unit convert
          self.unit = desiredUnit.unit
          if imageFactor.nil?
            self.factor = 1.0
          else
            self.factor = imageFactor
          end
          conversion = Units.convert(imageUnit.unit.name,desiredUnit.unit.name)
          if conversion
            self.factor *= conversion
          else
            self.factor = 1  # error : no conversion found so default to 1.0 units
          end
          self.factor = 1 if self.factor <= 0.0
#print "e : factor = ",self.factor,"\n"
        end
        
        #if imageFactor.nil? or imageFactor == 1
        #  self.unit = desiredUnit.unit
        #  self.factor = Units.convert(imageUnit.unit.name,desiredUnit.unit.name)
        #  self.factor = 1 if self.factor == 0.0 or self.factor.nil?
        #else # imageFactor != 1
        #  if desiredUnit.factor.nil?
        #    self.unit = desiredUnit.unit
        #    self.factor = Units.convert(imageUnit.unit.name,desiredUnit.unit.name)
        #    self.factor = 1 if self.factor == 0.0 or self.factor.nil?
        #  else
        #    self.unit = desiredUnit.unit
        #    self.factor = desiredUnit.factor
        #    self.factor = 1 if self.factor == 0.0
        #  end
        #end
        
      end
    end
  end
end

class CompoundUnit
  # name : e.g. millimeter
  # pluralName : e.g. millimeters
  # abbrev : e.g. mm
  # factor : a float, number of units per base unit
  # baseUnit:    name of defined unit

  def initialize
    @numerUnits = []
    @denomUnits = []
  end
  
  def addNUnit(unit)
    @numerUnits << unit
  end
  
  def addDUnit(unit)
    @denomUnits << unit
  end
  
  def name
    n = ""
    n += "(" if @numerUnits.length > 1
    @numerUnits.each_index do | index |
      n += " " if (index > 0)
      n += @numerUnits[index].name
    end
    n += ")" if @numerUnits.length > 1
    if @denomUnits.length
      n += " " if n.length > 0
      n += "/ "
      n += "(" if @denomUnits.length > 1
      @denomUnits.each_index do | index |
        n += " " if (index > 0)
        n += @denomUnits[index].name
      end
      n += ")" if @denomUnits.length > 1
    end
    n
  end
  
  def pluralName
    n = ""
    n += "(" if @numerUnits.length > 1
    @numerUnits.each_index do | index |
      n += " " if (index > 0)
      n += @numerUnits[index].pluralName
    end
    n += ")" if @numerUnits.length > 1
    if @denomUnits.length
      n += " " if n.length > 0
      n += "/ "
      n += "(" if @denomUnits.length > 1
      @denomUnits.each_index do | index |
        n += " " if (index > 0)
        n += @denomUnits[index].pluralName
      end
      n += ")" if @denomUnits.length > 1
    end
    n
  end
  
  def abbrev
    n = ""
    n += "(" if @numerUnits.length > 1
    @numerUnits.each_index do | index |
      n += " " if (index > 0)
      n += @numerUnits[index].abbrev
    end
    n += ")" if @numerUnits.length > 1
    if @denomUnits.length
      n += " " if n.length > 0
      n += "/ "
      n += "(" if @denomUnits.length > 1
      @denomUnits.each_index do | index |
        n += " " if (index > 0)
        n += @denomUnits[index].abbrev
      end
      n += ")" if @denomUnits.length > 1
    end
    n
  end

  def baseUnit
    "none"
  end
  
  def factor
    1
  end
  
  def family
    "compound"
  end
  
end

Units =  UnitLibrary.new(InstallPath + "units.dat")
DesiredDistUnit = UnitHolder.new
DesiredAreaUnit = UnitHolder.new
NoUnit = Units.find("none")

# print "0.0? yard to kaka ",Units.convert("yard","kaka"), "\n"
# print "0.0? snort to cm ",Units.convert("snort","centimeter"), "\n"
# print "0.0? acre to m ",Units.convert("acre","meter"), "\n"
# print "0.0? m to none ",Units.convert("meter","none"), "\n"
# print "0.0? m to edge ",Units.convert("meter","edge"), "\n"
# print "0.0? m to acre ",Units.convert("meter","acre"), "\n"
# print "1.0? m to m ",Units.convert("meter","meter"), "\n"
# print "1000? km to m ",Units.convert("kilometer","meter"), "\n"
# print "0.001? m to km ",Units.convert("meter","kilometer"), "\n"
# print "0.001? m to km ",Units.convert("m","km"), "\n"
# print ".9144? yd to m ",Units.convert("yard","meter"), "\n"
# print "91.44? yd to cm ",Units.convert("yard","centimeter"), "\n"
# print "0.010936? cm to yd ",Units.convert("centimeter","yard"), "\n"

