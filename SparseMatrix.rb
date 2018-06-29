
############################################################################
# hash of hashes : faster than anything I've been able to concoct
############################################################################

class SparseMatrix

  def initialize
    @data = {}
#    @rowsPresent = {}
#    @colsPresent = {}
  end
  
  def []=(a,b,c)
    hash = @data[a]
    if not hash
      hash = {}
      @data[a] = hash
    end
    hash[b] = c
=begin
    if c # actual data
      @rowsPresent[a] = true
      @colsPresent[b] = true
    else # clearing out data
      if hash.length == 0  # we cleared out the cols for this row
        # determine if this col is present any longer
        colPres = false
        @rowsPresent.each_key do | row |
          if @data[row][b]
            colPres = true
            break;
          end
        end
        if not colPres
          @colsPresent[b] = nil
        end
        # determine if this row has been cleared out too
        if @data[a].length == 0
          @rowsPresent[a] = nil
        end
      end
    end
=end
  end
  
  def [](a,b)
    hash = @data[a]
    if hash
      hash[b]
    else
      nil
    end
  end
  
  # example @data = {{2=>{1=>fred}} , {0=>{6=>jim,3=>dave}}
  
  def rows
    rowIndex = nil
    rowIndices = {}
    @data.each_key do |rowIndex|
      rowIndices[rowIndex] = true
    end
    rowIndices.keys.sort
#     @rowsPresent.keys.sort
  end
  
  def cols
    colHash = colIndex = nil
    colIndices = {}
    @data.each_value do |colHash|
      colHash.each_key do | colIndex |
        colIndices[colIndex] = true
      end
    end
    colIndices.keys.sort
#     @colsPresent.keys.sort
  end
  
  def each
    row = rowHash = col = nil
    @data.each_pair do | row, rowHash |
      rowHash.each_key do | col |
        yield @data[row][col]
      end
    end
  end
  
  def each_coord
    row = rowHash = col = nil
    @data.each_pair do | row, rowHash |
      rowHash.each_key do | col |
        yield(row,col)
      end
    end
  end
  
end

__END__

############################################################################
# arrays version : for_type afdb 1:37  (hash of hash version above 0:50)
############################################################################

class SparseMatrix
  
  def initialize
    @rowIndices = []
    @colIndices = []
    @values = []
  end
  
  def find(r,c)
    #[0,0,1,2,3,3,3,4]
    #[1,5,3,1,1,2,4,0]
    #r = 2  c = 4
    rowIndex = colIndex = nil
    low = 0
    high = @values.length-1
    until (high < low) do
      curr = (low + high) / 2
      rowIndex = @rowIndices[curr]
      if r == rowIndex
        colIndex = @colIndices[curr]
        if c == colIndex
          return [curr,true]
        elsif c < colIndex
          high = curr-1
        else # c > colIndex
          low = curr+1
        end
      elsif r < rowIndex
        high = curr-1
      else # r > rowIndex
        low = curr+1
      end
    end
    [low,false]
  end
  
  def []=(r,c,value)
    result = find(r,c)
    index = result[0]
    entryPresent = result[1]
    if value
      if entryPresent # row-col entry was present
        @values[index] = value
      else # row-col entry not present - so insert
        currLen = @values.length
        if index == currLen #putting at last spot
          @rowIndices << r
          @colIndices << c
          @values     << value
        else # inserting into list
          size = currLen-index
          @rowIndices = @rowIndices[0,index] + [r] + @rowIndices[index,size]
          @colIndices = @colIndices[0,index] + [c] + @colIndices[index,size]
          @values     = @values[0,index] + [value] + @values[index,size]
        end
      end
    else # will be deleting entries if present
      if entryPresent
        @rowIndices.delete_at(index)
        @colIndices.delete_at(index)
        @values.delete_at(index)
      end
    end
  end
  
  def [](r,c)
    result = find(r,c)
    if result[1]         # result[1] == entry present
      @values[result[0]] # result[0] == index of value
    else
      nil
    end
  end
  
  def rows
    @rowIndices.uniq
  end
  
  def cols
    @colIndices.uniq
  end
  
  def each
    @values.each do | value |
      yield value
    end
  end
  
  def each_coord
    @values.each_index do | index |
      yield(@rowsIndices[index],@colIndices[index])
    end
  end
  
end

############################################################################
# basic Hash indexing scheme : same as hash implementation but slower
############################################################################

class IndexedFrame
  def initialize
    @hash = {}
  end
  
  def each
    @hash.each_value do | val |
      yield val
    end
  end
  
  def each_index
    @hash.each_key do | key |
      yield key
    end
  end
  
  def addAt(index,obj)
    @hash[index] = obj
  end
  
  def lookup(index)
    @hash[index]
  end
  
  def indices  # return an array of indices (sorted not important)
    @hash.keys
  end
end

############################################################################
# binary tree indexing scheme : many many times slower
############################################################################

class Node
  def initialize(indx,obj)
    @index = indx
    @data = obj
  end
  attr_accessor(:left,:right,:index,:data)
end

class IndexedFrame
  def initialize
    @root = nil
  end
  
  def each
    nodeList = []
    nodeList.push(@root) if @root
    while nodeList.length != 0
      currNode = nodeList.pop
      yield currNode.data
      nodeList.push(currNode.left) if currNode.left
      nodeList.push(currNode.right) if currNode.right
    end
  end
  
  def each_index
    nodeList = []
    nodeList.push(@root) if @root
    while nodeList.length != 0
      currNode = nodeList.pop
      yield currNode.index
      nodeList.push(currNode.left) if currNode.left
      nodeList.push(currNode.right) if currNode.right
    end
  end
  
  def addAt(index,obj)
    if not @root
      @root = Node.new(index,obj)
    else
      prev = nil
      curr = @root
      while curr != nil
        nodeIndex = curr.index
        if index < nodeIndex
          prev = curr
          curr = curr.left
        elsif index > nodeIndex
          prev = curr
          curr = curr.right
        else
          curr.data = obj
          return obj
        end
      end

      node = Node.new(index,obj)
      
      # if get here prev points to insert spot
      if index < prev.index
        prev.left = node
      else
        prev.right = node
      end
    end
  end
  
  def lookup(index)
    curr = @root
    while curr != nil
      nodeIndex = curr.index
      if index < nodeIndex
        curr = curr.left
      elsif index > nodeIndex
        curr = curr.right
      else
        return curr.data
      end
    end
    nil
  end
  
  def indices  # return an array of indices (sorted not important)
    indexList = []
    nodeList = []
    nodeList.push(@root) if @root
    while nodeList.length != 0
      currNode = nodeList.pop
      indexList << currNode.index
      nodeList.push(currNode.left) if currNode.left
      nodeList.push(currNode.right) if currNode.right
    end
    indexList
  end
end

class NumericSparseMatrix

  def initialize
    @rowFrame = IndexedFrame.new
  end
  
  def []=(a,b,c)
    colFrame = @rowFrame.lookup(a)
    if not colFrame
      colFrame = IndexedFrame.new
      @rowFrame.addAt(a,colFrame)
    end
    colFrame.addAt(b,c)
  end
  
  def [](a,b)
    colFrame = @rowFrame.lookup(a)
    return nil if not colFrame
    return colFrame.lookup(b)
  end

  def each
    colFrame = obj = nil
    @rowFrame.each do | colFrame |
      colFrame.each do | obj |
        yield obj
      end
    end
  end
  
  def each_coord
    row = col = nil
    @rowFrame.each_index do | row |
      colFrame = @rowFrame.lookup(row)
      colFrame.each_index do | col |
        yield(row,col)
      end
    end
  end
  
  def rows
    @rowFrame.indices.sort
  end
  
  def cols
    colFrame = nil
    colIndices = []
    @rowFrame.each do | colFrame |
      colIndices += colFrame.indices
    end
    colIndices.uniq.sort
  end
  
end

if __FILE__ == $0

  print "Begin comparison tests\n"
  
  a = SparseMatrix.new
  b = NumericSparseMatrix.new
  
  1000.times do | i |
    row = rand(i)
    col = rand(i)
    value = rand(100)
    a[row,col] = value
    b[row,col] = value
    raise "Assign not equal" if a[row,col] != b[row,col]
  end
  
  raise ".rows not equal" if a.rows != b.rows
  raise ".cols not equal" if a.cols != b.cols

  adata = []
  a.each do | item |
    adata << item
  end
  bdata = []
  b.each do | item |
    bdata << item
  end
  raise "Data wrong" if adata != bdata
  
  aSequence = []
  a.each_coord do | row,col |
    aSequence << [row,col]
  end
  bSequence = []
  b.each_coord do | row,col |
    bSequence << [row,col]
  end
  raise "Sequence wrong" if aSequence != bSequence

  ITERS = 10000
  
  u = Time.now
  ITERS.times do | i |
    row = rand(i)
    col = rand(ITERS-i)
    value = 73
    a[row,col] = value
    a[row,col]
    if i == 900
      adata = []
      a.each do | item |
        adata << item
      end
      aSequence = []
      a.each_coord do | row,col |
        aSequence << [row,col]
      end
    end
  end
  v = Time.now
  ITERS.times do | i |
    row = rand(i)
    col = rand(ITERS-i)
    value = 73
    b[row,col] = value
    b[row,col]
    if i == 900
      bdata = []
      b.each do | item |
        bdata << item
      end
      bSequence = []
      b.each_coord do | row,col |
        bSequence << [row,col]
      end
    end
  end
  w = Time.now

  print "A speed: ",v-u,"\n"  
  print "B speed: ",w-v,"\n"  
  
  print "End comparison tests\n"
end




#####################################################################################
#
#class Item
#  def initialize(index,item)
#    @index = index
#    @item = item
#  end
#  attr_accessor(:index,:item)
#end
#
#class SparseMatrix
#  def initialize
#    @items = []
#  end
#  
#  def []=(a,b,c)
#    columnItem = @items.find { | obj | obj.index == a }
#    if columnItem.nil?
#      columnItem = Item.new(a,Array.new)
#      @items << columnItem
#    end
#    item = columnItem.item.find { | obj | obj.index == b }
#    if item.nil?
#      item = Item.new(b,c)
#      columnItem.item << item
#    end
#    item.item = c
#  end
#  
#  def [](a,b)
#    columnItem = @items.find { | obj | obj.index == a }
#    if columnItem
#      item = columnItem.item.find { | obj | obj.index == b }
#      item ? item.item : nil
#    else
#      nil
#    end
#  end
#  
#  def rows
#    rowIndices = []
#    @items.each do | colItem |
#      rowIndices << colItem.index
#    end
#    rowIndices
#  end
#  
#  def cols
#    colIndices = []
#    @items.each do |colItem|
#      colItem.item.each do | item |
#        colIndices << item.index
#      end
#    end
#    colIndices.uniq
#  end
#  
#  def each
#    @items.each do | colItem |
#      colItem.item.each do | item |
#        yield @items[colItem.index].item[item.index].item
#      end
#    end
#  end
#  
#  def each_coord
#    @items.each do | colItem |
#      colItem.item.each do | item |
#        yield(colItem.index,item.index)
#      end
#    end
#  end
#end

#####################################################################################
#
#class BalancedTreeNode
#  def initialize(item)
#    @left = nil
#    @right = nil
#    @item = item
#  end
#  
#  attr_accessor(:left,:right,:item)
#end
#
#class BalancedTree
#  def initialize
#    @root = nil
#  end
#  
#  def add(label,item)
#    if @root
#      @root = BalancedTreeNode.new(item)
#    else
#      node = @root
#      spot = nil
#      while node
#        spot = node
#        if label < node.label
#          node = node.left
#        elsif label > node.label
#          node = node.right
#        else
#          raise "Error in BalancedTree.add : trying to add an existing label."
#        end
#      end
#      if label < spot.label
#        spot.left = BalancedTreeNode.new(item)
#      else
#        spot.right = BalancedTreeNode.new(item)
#      end
#    end
#  end
#  
#  def find(label)
#  end
#  
#  def each_label
#  end
#  
#  def each_value
#  end
#  
#  def [](label)
#  end
#end
#
#class SparseMatrix
#
#  def initialize
#    @items = BalancedTree.new
#  end
#  
#  def []=(a,b,c)
#    columnTree = @items.find(a)
#    if columnTree.nil?
#      columnTree = BalancedTree.new
#      @items.add(a,columnTree)
#    end
#    node = columnTree.find(b)
#    if node.nil?
#      node = BalancedTreeNode.new(b)
#      columnTree.add(b,node)
#    end
#    node.item = c
#  end
#  
#  def [](a,b)
#    columnTree = @items.find(a)
#    if columnTree
#      node = columnTree.find(b)
#      node ? node.item : nil
#    else
#      nil
#    end
#  end
#  
#  def rows
#    rowIndices = []
#    @items.each_label do |rowIndex|
#      rowIndices << rowIndex
#    end
#    rowIndices
#  end
#  
#  def cols
#    colIndices = []
#    @items.each_value do |colTree|
#      colTree.each_label do | colIndex |
#        colIndices << colIndex
#      end
#    end
#    colIndices.uniq
#  end
#  
#  def each
#    @items.each_pair do | row, rowTree |
#      rowTree.each_label do | col |
#        yield @items[row][col]
#      end
#    end
#  end
#  
#  def each_coord
#    @data.each_pair do | row, rowTree |
#      rowTree.each_label do | col |
#        yield(row,col)
#      end
#    end
#  end
#  
#end
