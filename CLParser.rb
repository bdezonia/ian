
require InstallPath + 'Job.rb'
require InstallPath + 'ArgumentList.rb'
require InstallPath + 'Instances.rb'
require InstallPath + 'HelpItems.rb'
require InstallPath + 'Units.rb'

#############################################################################
# Command Line Parser
#   initialize does all the work
#   otherwise there are just accessors

class CLParser

public

  ###########################################################################
  #
  # initialize
  #
  
  def initialize(initArgs)

#    args.each { | arg | print arg,"\n" }
    
    # setup state variables
    
    @verbose = false
    @error = nil
    @jobs = []
    @job = nil
    @helpItems = []
    @args = []
    
    # preprocess args to catch things like "-ua(sq." "m)" as one arg
    
    args = []
    open = false
    initArgs.each do | arg |
      case arg
        when /^.*\([^\)]*$/   # something like "igis(xyz"
          args << arg
          open = true
        when /^[^\(]*\)$/     # something like "xyz)"
          args[args.length-1] = args.last + " " + arg if args.last
          open = false
        when /^.*\(.*\)$/     # something like A(xyz) or (xyz)
          args << arg
          open = false
        else                  # assume a well-formed argument
          if open
            args[args.length-1] = args.last + " " + arg if args.last
          else
            args << arg
          end
      end
    end
    
    # preprocess args to expand filename wildcards: ian -aall ibmp(*.bmp) rtxt
    processArgs(args)
    
    # now parse the command line (which sets state on the variables)
    parse
  end
  
  attr_reader(:error,:jobs, :helpItems)
  
private

  ###########################################################################
  #
  # syntaxError
  #
  
  def syntaxError(err = nil)
    if err.nil?
      @error = "Command line syntax error."
    elsif err.kind_of? Integer
      @error = "Command line syntax error: " + err.to_s + "."
    elsif err.kind_of? String
      @error = err
    else
      @error = "Command line parser reported an unknown error."
    end
  end
  
  ###########################################################################
  #
  # processArgs - defined to save stack space when many files at once
  #

  def processArgs(args)
  
    args.each_index do | index |
      expansion = false
      files = nil
      if index > 0
        # not "rtxt(a)" but "rtxt"
        if (not (args[index] =~ /^r.+\(.+\)$/i)) and (args[index] =~ /^r.+$/i)
          # check for expansion
          prev = @args.last
          if prev =~ /^i.+\((.+)\)$/i  # does it equal iX(Y) ?
            pathAndFileSpec = $1
            pathEnd = nil
            pathEnd = pathAndFileSpec.rindex("\\")
            tmp = pathAndFileSpec.rindex(":")
            pathEnd = tmp if not pathEnd or (tmp and tmp > pathEnd)
            tmp = pathAndFileSpec.rindex("/")
            pathEnd = tmp if not pathEnd or (tmp and tmp > pathEnd)
            if pathEnd
              path = pathAndFileSpec[0,pathEnd+1]
              Dir.chdir(path) if path.length > 0
              fileSpec = pathAndFileSpec[(pathEnd+1)..(pathAndFileSpec.length-1)]
            else
              fileSpec = pathAndFileSpec
            end
            if false  # case sensitive: z*.bmp != Z*.bmp
              files = Dir[fileSpec]
            else # case insensitive
              dosFileSpec = "^"
              fileSpec.length.times do | charIndex |
                ch = fileSpec[charIndex,1]
                case ch
                  when "*"
                    dosFileSpec += ".*"
                  when "?"
                    dosFileSpec += "."
                  when "."
                    dosFileSpec += "\\."
                  when "+"
                    dosFileSpec += "\\+"
                  when "("
                    dosFileSpec += "\\("
                  when ")"
                    dosFileSpec += "\\)"
                  when "["
                    dosFileSpec += "\\["
                  when "]"
                    dosFileSpec += "\\]"
                  when "{"
                    dosFileSpec += "\\{"
                  when "}"
                    dosFileSpec += "\\}"
                  when "-"
                    dosFileSpec += "\\-"
                  when "|"
                    dosFileSpec += "\\|"
                  when "\\"
                    dosFileSpec += "\\"
                  when "^"
                    dosFileSpec += "\\^"
                  when "$"
                    dosFileSpec += "\\$"
                  else
                    dosFileSpec += ch
                end
              end
              dosFileSpec += "$"
              dosFileMatch = Regexp.new(dosFileSpec,Regexp::IGNORECASE)
              files = Dir["*"]
              files = files.collect { | file | file if file =~ dosFileMatch }
              files.compact!
            end
            expansion = true if files.length > 0
          end
        end
      end
      if expansion
        imageArg = @args.pop  # remove last entry from @args
        imageArg =~ /^i(.+)\(.+\)$/i
        imageType = $1
        files.each do | filename |
          if filename != "." and filename != ".."
            @args << "i" + imageType + "(" + filename + ")"
            @args << args[index]
          end
        end
      else  # no expansion
        @args << args[index]
      end
    end
  end
  
  ###########################################################################
  #
  # parse - parse the command line and set all state variables as a consequence
  #
  
  def parse
    commands
  end

  ###########################################################################
  #
  # commands - determine if we parse a help command or a job definition command
  #
  
  def commands
    @helpDesired = false
    if @args.length == 0
      @helpDesired = true
    else
      firstArg = @args[0].downcase
      @helpDesired = ( firstArg == "-h" )
      @helpDesired = ( firstArg =~ /^\-\?$/ ) if not @helpDesired
    end
    if (@helpDesired)
      helpCommands()
    else
      runCommands(0)
    end
  end

  ###########################################################################
  #
  # help commands - parse help items
  #
  
  def helpCommands
    
    return if @args.length == 0  # helpItems already set to empty
    
    verbose = false
    
    @args.each do | arg |
    
      case arg.downcase
      
        when /^\-h$/, /^\-\?$/ # help flag
          # do nothing
          
        when /^-v$/, /^-verbose$/   # output toggle
          verbose = !verbose
        
        when /^-oall$/  # all options toggle
        
          # run help on all options installed on system
          installedOptions = Dir.entries(InstallPath+"options")
          
          installedOptions.each do | optionName |
        
            option = optionName.downcase
          
            # if ends in .rb
            if (option =~ /.+\.rb$/)
              option.chomp!(".rb")
              item = OptionHelpItem.new("-"+option,verbose)
              helpItems.reject! { | helpItem | (item.name.downcase == helpItem.name.downcase) }
              helpItems << item
            end
          end
        
        when /^-aall$/,/^-a$/  # all analyses toggle
      
          # run help on all analyses installed on system
          installedAnalyses = Dir.entries(InstallPath+"analyses")
          
          installedAnalyses.each do | analysisName |
        
            analysis = analysisName.downcase
          
            # if ends in .rb
            if (analysis =~ /.+\.rb$/)
              analysis.chomp!(".rb")
              item = AnalysisHelpItem.new("a"+analysis,verbose)
              helpItems.reject! { | helpItem | (item.name.downcase == helpItem.name.downcase) }
              helpItems << item
            end
          end
        
        when /^-iall$/  # all images toggle
      
          # run help on all imagetypes installed on system
          installedImageTypes = Dir.entries(InstallPath+"imageTypes")
          
          installedImageTypes.each do | imageTypeName |
        
            imageType = imageTypeName.downcase
          
            # if ends in .rb
            if (imageType =~ /.+\.rb$/)
              imageType.chomp!(".rb")
              item = ImageHelpItem.new("i"+imageType,verbose)
              helpItems.reject! { | helpItem | (item.name.downcase == helpItem.name.downcase) }
              helpItems << item
            end
          end
        
        when /^-rall$/  # all reports toggle
      
          # run help on all reports installed on system
          installedReports = Dir.entries(InstallPath+"reports")
          
          installedReports.each do | reportName |
        
            report = reportName.downcase
          
            # if ends in .rb
            if (report =~ /.+\.rb$/)
              report.chomp!(".rb")
              item = ReportHelpItem.new("r"+report,verbose)
              helpItems.reject! { | helpItem | (item.name.downcase == helpItem.name.downcase) }
              helpItems << item
            end
          end
        
        else
          case arg[0,1].downcase
            when 'a'
              item = AnalysisHelpItem.new(arg,verbose)
            when 'i'
              item = ImageHelpItem.new(arg,verbose)
            when '-'
              item = OptionHelpItem.new(arg,verbose)
            when 'r'
              item = ReportHelpItem.new(arg,verbose)
            else
              syntaxError("Help desired for unknown item: " + arg)
              return
          end
          helpItems.reject! { | helpItem | (item.name.downcase == helpItem.name.downcase) }
          helpItems << item
      end
      
    end
    
  end

  ###########################################################################
  #
  # runCommands - the definition of one job on the command line
  #
  
  def runCommands(argNum)

    # next line is for termination
    #   also stop upon discovery of error
    
    while not @error and argNum < @args.length
    
      @job = Job.new
    
      # initialize job options
      if @jobs.length > 0
        @jobs[@jobs.length-1].options.each do | option |
          @job.registerOption(option)
        end
      end
    
      # parse one job
      argNum = options(argNum)
      argNum = analyses(argNum)
      argNum = image(argNum)
      argNum = reports(argNum)

      # set analyses if necessary
      if @job.analyses.length == 0
    
        # default to previous job's analyses if possible
        if @jobs.length > 0
      
          @jobs[@jobs.length-1].analyses.each do | analysis |
            @job.registerAnalysis(analysis)
          end
        
        else # this is first job defined: therefore no previous analyses defined
      
          # so default to AR
          @job.registerAnalysis(AnalysisInstance.new(ArgumentList.new("A")))
        
        end
      end
    
      # remember the job if successful    
      @jobs << @job if not @error
    
    end

    argNum = @args.length if @error
    
    argNum
   
  end

  ###########################################################################
  #
  # parse options : this production can be null
  #
  
  def options(argNum)
  
    # stop upon discovery of error
    return @args.length if @error
    
    # if past end of input and expecting a flag we have a syntax error
    if argNum >= @args.length
      # should never get here
      syntaxError(1)
      return @args.length
    end

    # test whether next item is a flag : starts with "-" followed by text
    if (!(@args[argNum] =~ /^\-.+/))
      # not a flag: continue parsing this item elsewhere
      return argNum
    end
    
    # parse this flag
    option(argNum)
    
    # try to parse more flags
    return options(argNum+1)
  end

  ###########################################################################
  #  
  # parse a single flag : cannot be a null production
  #
  
  def option(argNum)
  
    # stop upon discovery of error
    return if @error
    
    # if past end of input and expecting an option we have a syntax error
    if argNum >= @args.length
      # should never get here
      syntaxError(2)
      return
    end
    
    # test whether next item is an option : starts with "-" followed by text
    if (!(@args[argNum] =~ /^-.+/))
      # not an option!
      # should never get here
      #print "Bad arg [",@args[argNum],"]\n"
      syntaxError(3)
      return
    end

    # test which option we have
    case @args[argNum].downcase 
    
      when /^-v$/, /^-verbose$/,   # output toggle
        @verbose = !@verbose
        
      when /^-oall$/  # all options toggle
        @error = "All options flag can only be used during help"
        
      when /^-aall$/,/^-a$/  # all analyses toggle
      
        # run all analyses on current job
        installedAnalyses = Dir.entries(InstallPath+"analyses")
        
        installedAnalyses.each do | analysisName |
        
          analysis = analysisName.downcase
          
          # if ends in .rb
          if (analysis =~ /.+\.rb$/)
          
            # remove .rb
            analysis = analysis.chomp(".rb")
          
            # register with job
            @job.registerAnalysis(AnalysisInstance.new(ArgumentList.new(analysis)))
          end
        end
        
      when /^-iall$/  # all images toggle
        @error = "All images flag can only be used during help"
      
      when /^-rall$/  # all reports toggle
        @error = "All reports flag can only be used during help"
      
      when /^\-h$/, /^\-\?$/ # help flag
        @error = "Help flag " + @args[argNum] + " must be first flag on command line"

      when /^\-ua\((.*)\)$/
        tmpUnit = $1
        if @args[argNum].downcase =~ /^\-ua\((.*)~(.*)\)$/
          factor = $1.to_f
          unit = Units.find($2)
        else
          factor = nil
          unit = Units.find(tmpUnit)
        end
        if unit and unit.family == "area"
          DesiredAreaUnit.unit = unit
          DesiredAreaUnit.factor = factor
        else
          @error = "Unknown area unit specified: " + tmpUnit
        end
        
      when /^\-ud\((.*)\)$/
        tmpUnit = $1
        if @args[argNum].downcase =~ /^\-ud\((.*)~(.*)\)$/
          factor = $1.to_f
          unit = Units.find($2)
        else
          factor = nil
          unit = Units.find(tmpUnit)
        end
        if unit and unit.family == "distance"
          DesiredDistUnit.unit = unit
          DesiredDistUnit.factor = factor
        else
          @error = "Unknown distance unit specified: " + tmpUnit
        end
      
      when /^\-(.+)\((.*)\)$/
        # remove leading - from string    
        string = @args[argNum].slice(1,@args[argNum].length-1)
    
        # parse text : expecting oX or oX(Y)
        optionArgs = ArgumentList.new(string)
    
        @job.registerOption(OptionInstance.new(optionArgs))
        
      else
        @error = "Unknown option specified: " + @args[argNum]
    end  
  end

  ###########################################################################
  #
  # parse analyses : this production can be null
  #   if the production is null the analyses defined for the job are the
  #   analyses from the previous job definition. If its the first job defined
  #   it will default to the A anlysis which is predefined.
  #
  
  def analyses(argNum)
  
    # stop upon discovery of error
    return @args.length if @error
    
    # if past end of input and expecting an analysis we have a syntax error
    if argNum >= @args.length
      syntaxError("Missing input image and output report.")
      return @args.length
    end

    # test whether next item is an analysis : starts with "a" followed by text
    if (!(@args[argNum].downcase =~ /^a.+/))
      # not an analysis
      return argNum
    end
    
    # parse the analysis
    analysis(argNum)
    
    # try to parse more analyses
    return analyses(argNum+1)
  end
  
  ###########################################################################
  #
  # analysis: parse an analysis - production must not be null
  #
  
  def analysis(argNum)
  
    # stop upon discovery of error
    return @args.length if @error
    
    # if we are beyond the end of output and expecting an analysis we are erroring
    if argNum >= @args.length
      # should never get here : checked in analyses
      syntaxError(4)
      return
    end
    
    # test that we indeed have an analysis
    if (!(@args[argNum].downcase =~ /^a.+/))
      # should never get here : checked in analyses
      syntaxError(5)
      return
    end
    
    # parse text : expecting aX or aX(Y)
    
    # test aX(Y) case
    if (@args[argNum].downcase =~ /^a(.+)\((.+)\)$/).nil?

      # test aX case
      if (@args[argNum].downcase =~ /^a(.+)$/).nil?
        syntaxError("Analysis should be of form aX or aX(Y): " + @args[argNum])
        return
      end
    end

    # remove leading a from string
    string = @args[argNum].slice(1,@args[argNum].length-1)

    analysisArgs = ArgumentList.new(string)
    
    @job.registerAnalysis(AnalysisInstance.new(analysisArgs))
    
  end

  ###########################################################################
  #
  # image - parse the image portion of the job definition
  #
  
  def image(argNum)
  
    # stop upon discovery of error
    return @args.length if @error
    
    # if we are beyond the end of output and expecting an image we are erroring
    if argNum >= @args.length
      syntaxError("Missing image and report.")
      return @args.length
    end
    
    # test that indeed we are looking at an image def
    if (!(@args[argNum].downcase =~ /^i.+/))
      syntaxError("Expecting image and got " + @args[argNum])
      return @args.length
    end

    # parse text : expecting -iX(Y)
    
    # test iX(Y) case
    if (@args[argNum].downcase =~ /^i(.+)\((.+)\)$/).nil?
      syntaxError("Image should be of form iX or iX(Y): " + @args[argNum])
      return @args.length
    end
    
    # remove leading i from string    
    string = @args[argNum].slice(1,@args[argNum].length-1)
    
    imageArgs = ArgumentList.new(string)
    
    @job.registerImage(ImageInstance.new(imageArgs))
    
    return argNum+1
  end

  ###########################################################################
  #
  # reports - parse one or more reports
  #
  
  def reports(argNum)
  
    # stop upon discovery of error
    return @args.length if @error
    
    # parse at least one report per job definition
    firstReport(argNum)
    
    # parse more reports if present
    return moreReports(argNum+1)
  end

  ###########################################################################
  #
  # firstReport - a valid job definition must contain at least one report
  #
  
  def firstReport(argNum)
    report(argNum)
  end

  ###########################################################################
  #
  # moreReports - a valid job definition can contain more than one report
  #   This production can be null
  #
  
  def moreReports(argNum)
  
    # stop upon discovery of error
    return @args.length if @error
    
    # are we beyond the end of input
    if argNum >= @args.length
      # SUCCESS: we have at least one report and we are now stopping
      return @args.length
    end
    
    # check if it is a report
    if (!(@args[argNum].downcase =~ /^r.+/))
      # if not a report it could be the beginning of a new job definition
      return argNum
    end
    
    # parse the report we found
    report(argNum)
    
    # try to parse more reports
    return moreReports(argNum+1)
  end

  ###########################################################################
  #
  # parse a report : this production must not be null
  #
  def report(argNum)
  
    # stop upon discovery of error
    return @args.length if @error
    
    # are we beyond the end of input
    if argNum >= @args.length
      syntaxError("Expecting a report and ran out of arguments")
      return
    end
    
    # verify we have a report
    if (!(@args[argNum].downcase =~ /^r.+/))
      syntaxError("Expecting a report and got " + @args[argNum])
      return
    end
    
    # parse text : expecting rX(Y) or even perhaps rX
    #   a rX report might be something that has hard coded output or even a
    #   gui window as the report
    
    # test rX(Y) case
    if (@args[argNum].downcase =~ /^r(.+)\((.+)\)$/).nil?

      # test rX case
      if (@args[argNum].downcase =~ /^r(.+)$/).nil?
        syntaxError("Report should be of form rX or rX(Y): " + @args[argNum])
        return
      end
    end

    # remove leading r from string
    string = @args[argNum].slice(1,@args[argNum].length-1)

    reportArgs = ArgumentList.new(string)

    @job.registerReport(ReportInstance.new(reportArgs,@verbose))

  end
end

