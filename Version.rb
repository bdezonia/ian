
module Version

  VER     = 1
  RELEASE = 0
  BUGFIX  = 23
  MONTH   = "January"
  YEAR    = "2010"

  def Version.name
    "#{VER}.#{RELEASE}.#{BUGFIX}"
  end
  
  def Version.date
    "#{MONTH} #{YEAR}"
  end
  
  def Version.year
    "#{YEAR}"
  end
  
end

# history
# version 1.0.0 August 1 2004
#   initial release 2 options, 23 analyses, 4 image types, 3 report formats
# version 1.0.1 August 24 2004
#   added DBF report format
# version 1.0.2 Sept 3 2004
#   better names in BinaryReader.rb
#   BMP,GIS,LAN: use BinaryReaders new names
#   added HDR (Arc bil/bip/bsq) imagetype
#   better help for clui.rb
#   WinUi.rbw - no differences - just touched
# version 1.0.3 Sept 16 2004
#   Renamed AR.rb to A.rb and modified ClParser.rb to call it as default
#   instances.rb - removed old comments
#   a/ar.rb - removed old comments and changed analysis name
#   swe.rb - more help text
#   winui.rbw - changed license
#   asc,bmp,gis,hdr,lan - improved help
#   units.dat - added township, section, quarter section
#   added LPI to analyses
#   rewrote PPS,PAS to use new Calculator.statSummary
#   added SHP to analyses
#   engine.rb - removed old comment
# version 1.0.4  Oct 7 2004
#   Calculator.rb - added area weighted mean
#   WinUI.rbw - fixed typo in text screen name
#   ASC,BMP,GIS,HDR,LAN - engine.error changed to raise
#   Units.rb - removed old comment
#   AI.rb - a little speed tuning
#   TIF.rb file support added
#   CA.rb added to analyses
#   WinUI.rbw - added IAN project URL to Help::About
# version 1.0.5 Dec 3 2004
#   SP.rb, PA.rb, PAC.rb - touched (changes made and undone re: speed)
#   CLUI.rb - added profile possibility for speed timing
#   UI.rb - raises if no method override
#   FDB.rb - much speed tuning, reorder variable declarations
#   TX2.rb - typo in error message
#   CLUI.rb, WinUI.rbw - setting InstallPath from $0
#   EDE.rb, IDM.rb - speed tuning
#   ASM.rb, CO.rb, RCO.rb - removed old commented require
#   AI.rb - bugs: not all classes getting reported, 1 pixel area div by 0
#   CA.rb - bug: core area of 0 was not getting reported
#   Instances.rb - debugging code
#   Calculator.rb - minor speed tweak in regress
#   Overall execution speed reduced to 60% of previous times
# version 1.0.6 Jan 5 2005
#   TX2 becomes TXT2 : make note on website when release this version
#   added CSV2 report
#   WinUI.rbw - more info in Help::About and fixed its icon
#     Refactor some code regarding timer, localize some instance vars,
#     document instance vars. Port to FXRuby 1.2 (bundled with Ruby 1.8.2)
#   CLUI.rb and WinUI.rbw
#     don't add "." to search path at startup
#     simplify finding of InstallPath
#   DBF - removed old comment
# version 1.0.7 Feb 7 2005
#   SP,CA,FDB - speed improve via predefine variables
#   SparseMatrix - speed improve
#   FDB - simplify how we get colors array
#   AI,ED,FDB,FDP,LPI,P,PA,PAC,PAS,PPS,SHP - added outType method
#   Instances - added check for outType on Analysis and report output format
#   WinUi - added outType info for analyses, made unit combo boxes display 1st 5
#   DBF - name mentions class metrics only
#   Units.rb, CLUI: forgot superclass initialization in spots
#   Units.dat : removed smallest units
# version 1.0.8 Apr 22 2005
#   CA - bug fixed where CA was wrong for maps consisting of 1 pixel
#   Units.dat - some commented out units were still appearing
#   FDB - minor speedup from variable predefinition
# version 1.0.9 May 20 2005
#   CA - bug fixed : it was not running at all
# version 1.0.10 November 16 2005
#   WinUI - improved file selection dialog to remember last path
# version 1.0.11 May 24 2006
#   TIF - removed old debugging code line (image=something) at begin of readImage
#   ASC - made code autodetect .asc files when extension not given
# version 1.0.12 June 13 2006
#   P.rb - total perimeter forgot to unit convert
#   Units.rb - unit conversion was not using original scale in one case
# version 1.0.13 June 27 2006
#   Clui.rb - added copyright
#   WinUI.rbw - typos in the help fixed and copyright updated
#   TXT,TXT2,CSV,CSV2 - output image's dist and area unit as defined in image header
# version 1.0.14 July 12 2006
#   Clui.rb - fixed help copyright notice when clui.rb run without arguments
#   units.dat - added a few units, removed a couple, and rebased some
# version 1.0.15 August 2 2006
#   GIS,LAN,TIF,ASC - fix unspecified area units to default to the square of the
#                     distance unit if the dist unit is specified
#   Units.dat - square inch and square perch missing
# version 1.0.16 May 23 2007
#   WinUI.rbw - changed fox support from 1.2 to 1.6 which allows newer ruby distribs
#               to work correctly
# version 1.0.17 Nov 2008
#   TXT and TXT2 - format string stopped working with newer versions of Ruby
#   CLUI, WinUI.rbw - fix copyright dates
#   AI - stop reporting AI for classes not present in map
#   Image1.c - get/set cell (and other methods) were pretty wrong
#   BMP - added debug statement to 1 bit per pixel case
#   Image*.so - recompiled with Visual Studio Express C++ 2008
#   *.dll - included Visual Studio Express C++ 2008 redistributable DLLs
# version 1.0.18 May 2009 (actually late April)
#   WinUI.rbw - fixed bug: hit Analyze Images twice and program would crash
#     Bug fixed: make help dialogs bigger so Vista version looks right
#     Bug fixed: if Stop Analyzing and Start Analyzing the pie chart would not reset
#     Changed from 640x480 to 800x600
#   Image*.so: Bug fixed- if out of ram it would not catch thrown exception. So the
#     program would just hang.
# version 1.0.19 May 2009 (early May)
#   Image*.so
#     Written to share code better. May have slowed down code.
#     Tried to remove potential type conversion bugs
#     Made these classes utilize memory more efficiently allowing bigger maps
#       to be processed. May have slowed down code.
# version 1.0.20 May 13 2009
#   Image*.so - restored to 1.0.17 versions as newer versions make Ruby crash out.
#     Must figure out correct compile options or compiler or libraries linking
#     against. Note v18 worked on Vista. v18 and v19 fail on XP with 14001 error
#     when requiring Image1.so. Known Ruby Windows bug with unknown solution.
#   WinUI.rbw - changed from 800x600 to 960x680
# version 1.0.21 May 21 2009
#   CLParser.rb - removed some recursion to fix stack overflow bug when processing
#     many files from the command line.
#   Image*.so
#     Bug fixed: compiled 1.0.19's *.c using old MS VC++ 6.0. This should keep
#       crashes from happening when loading Image*.so. This also restores new func from
#       the 1.0.18 and 1.0.19 releases
#     Code improved for portability and so Image24 uses less memory
#     The method used to build Image*.so was revamped and simplified to be repeatable
#       in the future. I doubt this broke anything but feel it needs noting.
# version 1.0.22 January 6 2010
#   TIF.rb - fixed bug for tiled images. If width or len of image exactly divisible
#     by tile size then the edge tiles were not getting populated.
# version 1.0.23 January 7 2010
#   TIF.rb - found a typo from the previous fix - repaired