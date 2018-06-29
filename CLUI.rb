
#require 'profile'  # crashes 1.8.2, works 1.8.1
#require 'profiler'  # no crash but no profile info reported

path = File.dirname(__FILE__)

path = "." if path.length == 0

# add this path to module search path : loads Image*.so correctly
$: << path if path != "."

InstallPath = path + "\\"

require InstallPath + 'UI.rb'
require InstallPath + 'Version.rb'
require InstallPath + 'Engine.rb'
require InstallPath + 'IanCommandLine.rb'

class CommandLineUI < UI

  def initialize
    super()
    print "\nIAN (Image ANalyzer): v#{Version.name}. (#{Version.date}) Copyright 2004-#{Version.year}\n\n"
    engine = Engine.new(self)   # create engine and hook to it
    cLine = IanCommandLine.new
    if cLine.error
      error(cLine.error)
    elsif cLine.jobsWanted
      engine.registerJobs(cLine.jobs)
      engine.runJobs() # run jobs
    else
      engine.help(cLine.helpItems) # which should call displayHelp()
    end
  end

  def statement(text)
    print " ", text, "\n"
  end
  
  def warning(text)
    print " Warning: ", text, "\n"
  end
  
  def error(text)
    print "Error: " + text
    exit()
    # raise "Error: " + text
  end
  
  def percentDone(percent)
    # this UI ignores percentDone
  end
  
  def displayHelp(text)
    # text is an array of strings. blank strings separate paragraphs.
    #   strings shouldn't be longer than 80 chars for comm-line compatibility
    #   strings should not contain newlines

    2.times { print "\n" } # make distinction on screen
    remainingInputLines = text.length
    linesDone = 0
    while remainingInputLines > 0
      if remainingInputLines > 25
        0.upto(22) { | i | print text[linesDone + i], "\n" }
        linesDone = linesDone + 23
        print "\nPress Enter to continue or Press Q and Enter to quit: "
        reply = $stdin.gets.chomp
        if (reply =~ /^q$/i)
          remainingInputLines = 0
        else
          remainingInputLines = remainingInputLines - 23
        end
        print "\n"
      else # remaining lines <= 25
        0.upto(remainingInputLines-1) { | i | print text[linesDone + i], "\n" }
        linesDone = linesDone + remainingInputLines
        remainingInputLines = 0
      end
    end
    linesDone
  end
  
  def generalHelp()
    usage = [
     "",
     "IAN (Image ANalyzer): v#{Version.name}. (#{Version.date}) Copyright 2004-#{Version.year}",
     "",
     "IAN usage: ianc [options] [analyses] image report(s).",
     "",
     "  Each option, analysis, image, or report is specified by acronym. Options",
     "  start with \"-\". Analyses start with \"a\". Image types start with \"i\".",
     "  Reports start with \"r\". To see what options, analyses, image types, and",
     "  reports are installed see Ian Help below. The command line syntax can be",
     "  repeated for multiple runs with options and analyses being cumulative.",
     "  Therefore:",
     "",
     "  Example:",
     "    ianc -p apas igis(c:\\f1) rtxt(c:\\f1) -n aar ibmp(c:\\f2) rtxt(c:\\f2)",
     "",
     "  is the equivalent of:",
     "",
     "  Example: ianc -p apas igis(c:\\f1) rtxt(c:\\f1)",
     "",
     "  followed by:",
     "",
     "  Example: ianc -p -n apas aar ibmp(c:\\f2) rtxt(c:\\f2)",
     "",
     "",
     "IAN help: ianc -h [options] [analyses] [imagetypes] [reports]",
     "",
     "  -h can be replaced with -?",
     "  To get help on all installed options use \"-oall\".",
     "  Similarly use \"-aall\" for analyses, \"-iall\" for imagetypes, and \"-rall\"",
     "  for reports. The order of the options, analyses, image types, and reports",
     "  can be interchanged.",
     "",
     "  Example: ianc -? -oall ibmp rcsv rtxt apas aswe",
     "",
     "IAN supports additional command line parameters:",
     "",
     "  -v or -verbose: toggle verbose mode. Verbose mode determines whether to",
     "    generate full or brief output for report generation and help. The default",
     "    setting is brief. Can be used multiple times per command line.",
     "",
     "  Example: ianc -h -v -oall",
     "  Example: ianc -h -oall apas apps ibmp -v rcsv rtxt",
     "",
     "",
     "",
     "",
     "  -a,-aall : toggle run state of all installed analyses. If an analysis was",
     "    previously toggled on it will be toggled off and vice versa. All analyses",
     "    installed on the system will be toggled. To see brief help on all analyses",
     "    installed on the system run \"ruby ianc -h -aall\"",
     "",
     "  Example: ianc aaan -aall iasc(c:\\f1) rcsv",
     "",
     "  -ua,-ud : set the units (area and distance) of input images. Each one of",
     "    these options takes an optional scalar and a unit name or abbreviation.",
     "",
     "  Example: ianc -ud(meters) igis(c:\\f1) rtxt",
     "  Example: ianc -ua(100.0~sq. km) igis(c:\\f1) rtxt",
     "",
     "IAN comes with a batch file named IANC.BAT which calls the command line user",
     "interface called \"clui.rb\". If you would like you can call clui.rb directly.",
     "The syntax is the same as IANC.BAT. The syntax of all the above examples remain",
     "the same but \"ianc\" gets replaced with \"clui.rb\"."
     ]

     displayHelp(usage)

  end
  
end

ui = CommandLineUI.new

