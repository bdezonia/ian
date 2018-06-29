
# IAN install program

require 'ftools'  # so we can call File.copy and File.makedirs

def validate(path)

  # empty/nonexistant
  if not path or path.length == 0
    print "No path specified.\n"
    return false
  end
  
  # garbage chars present
  if path =~ /[\|\*\"\<\>\?]/
    print "Illegal character present in path: ",$&,"\n"
    return false
  end
  
  # c:, u:, or \, /
  if path =~ /^[A-Za-z]:$/ or path == "\\" or path == "/"
    print "IAN requires a full path as an installation target.\n"
    return false
  end

  # c:\ u:\ etc.
  if path =~ /^[A-Za-z]:(\\|\/)+$/
    print "IAN requires that a subdirectory is specified as an installation target.\n"
    return false
  end
  
  # c:\fred, c:\fred\, c:\fred\joe, c:\fred\joe\, \fred, fred, fred\, fred\joe,
  # fred\joe\, ., .., .\, .\joe, .\.\.

  tmp = path.dup
  
  # optionally match leading drive designation
  if tmp =~ /^[A-Za-z]\:(.*)/
    tmp = $1
  end

  # optionally match leading slash
  if tmp =~ /^(\\|\/)(.*)/
    tmp = $2
  end
  
  while tmp and tmp.length != 0
  
    # match subdir to end of string
    if tmp =~ /^[\s\w\`\~\!\@\#\$\%\^\&\(\)\-\_\+\=\{\}\[\]\;\'\,\.]+$/
    
      tmp = ""
      
    # match subdir to next slash
    elsif tmp =~ /^[\s\w\`\~\!\@\#\$\%\^\&\(\)\-\_\+\=\{\}\[\]\;\'\,\.]+\\|\/(.*)/
    
      tmp = $1
      
    else  # no subdir to match
    
      print "Illegal path syntax.\n"
      return false
      
    end

  end
  
  return true
end

def pathName(path,subdir)
  pathName = path
  pathName += "\\" if pathName[pathName.length-1,1] != "\\"
  pathName += subdir
  pathName
end

def makePathDir(path)
  exists = FileTest.exists?(path)
  if exists
    if not File.stat(path).directory?
      print "A file exists with the name ",path,". Unable to create directory. Exiting.\n"
      exit
    else
      print "Directory ",path," already exists. Continuing.\n"
    end
  else # path does not yet exist
    print "Making directory ",path,"\n"
    File.makedirs(path)
  end
end

def copyFiles(srcPath,fileSpec,destPath)
  print "Copying files to ",destPath,"\n"
  if srcPath.length == 0
    dir = Dir.new(".")
  else
    dir = Dir.new(srcPath)
  end
  dir.each do | fileName |
    if fileName =~ fileSpec
      if srcPath.length == 0
        srcFile = fileName
      else
        srcFile = srcPath + "\\" + fileName
      end
      File.copy(srcFile,destPath) if not File.stat(srcFile).directory?
    end
  end
end

# get install directory from user

print "\nIAN installation program : July 2004\n\n"
print "Enter the path where you would like IAN installed\n"
path = gets.chomp

exit if not validate(path)

# if path ends in \ or / remove it
lastChar = path[path.length-1,1]
path = path[0,path.length-1] if lastChar == "\\" or lastChar == "/"

# make sure we create install dirs if needed

makePathDir(path)
makePathDir(pathName(path,"options"))
makePathDir(pathName(path,"analyses"))
makePathDir(pathName(path,"imagetypes"))
makePathDir(pathName(path,"reports"))

# copy files over to install dirs

copyFiles("",/.*\.bmp/i,path)
copyFiles("",/.*\.dat/i,path)
copyFiles("",/.*\.dll/i,path)
copyFiles("",/.*\.gis/i,path)
copyFiles("",/.*\.png/i,path)
copyFiles("",/.*\.rb/i,path)
copyFiles("",/.*\.rbw/i,path)
copyFiles("",/.*\.so/i,path)
copyFiles("options",/.*\.rb/i,pathName(path,"options"))
copyFiles("analyses",/.*\.rb/i,pathName(path,"analyses"))
copyFiles("imageTypes",/.*\.rb/i,pathName(path,"imageTypes"))
copyFiles("reports",/.*\.rb/i,pathName(path,"reports"))

# make command line batch files at install dir

print "Making IanC.bat script\n"

batchFile = File.new(pathName(path,"IanC.bat"),"w")

batchFile.write("@echo off\n")
batchFile.write("set commline=ruby \""+path+"\\clui.rb\"\n")
batchFile.write(":getArg\n")
batchFile.write("if \"%1\"==\"\" goto end\n")
batchFile.write("set commline=%commline% %1\n")
batchFile.write("shift\n")
batchFile.write("goto getArg\n")
batchFile.write(":end\n")
batchFile.write("%commline%\n")
batchFile.write("set commline=\n")

batchFile.close

print "Making Ian.bat script\n"

batchFile = File.new(pathName(path,"Ian.bat"),"w")

batchFile.write("@echo off\n")
batchFile.write("set commline=ruby \""+path+"\\winui.rbw\"\n")
batchFile.write(":getArg\n")
batchFile.write("if \"%1\"==\"\" goto end\n")
batchFile.write("set commline=%commline% %1\n")
batchFile.write("shift\n")
batchFile.write("goto getArg\n")
batchFile.write(":end\n")
batchFile.write("%commline%\n")
batchFile.write("set commline=\n")

batchFile.close

print "\nInstallation complete! Please Press Enter to Exit."
gets
