class ArgumentList
  
# str - encoded string: something like "txt(c:\fred\run.1~f1.asc~f2.asc)"

  def initialize(str)
    @type = str[ /^[a-zA-Z0-9]+/ ]
    @args = Array.new
    i = 0
    start = str.index('(')
    last = str.index(')')
    if start and last
      start += 1
      while start < last
        tilde = str.index("~",start)
        if tilde.nil? # last file in list
          len = last - start
          @args[i] = str[start,len]
          start = last
        else #tilde found
          len = tilde - start
          @args[i] = str[start,len]
          i += 1
          start = tilde + 1
        end
      end
    end
  end

  attr_accessor :type, :args

end

