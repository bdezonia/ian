
# MethodRemover
# This class used to undefine Analyses, Reports, etc. between loads.
# ObjectSpace is checked to make sure class exists before methods are undefined
# This class is dangerous if used on builtin classes

class MethodRemover
  def initialize(className)
    @className = className
    @codeString =  "class " + className +"\n" +
                   "  public_instance_methods(false).each do | method |\n" +
                   "    code = \"class #{className}  remove_method :\"\+method\+\" end\"\n" +
                   "    Object.module_eval(code)\n" +
                   "  end\n" +
                   "end\n"
  end
  def run
    #print(@codeString)
    ObjectSpace.each_object(Class) do | aClass |
      if aClass.to_s == @className
        eval(@codeString)
      end
    end
  end
end

