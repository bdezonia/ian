
path = File.dirname(__FILE__)

path = "." if path.length == 0

# add this path to module search path : loads Image*.so correctly
$: << path if path != "."

InstallPath = path + "\\"

require InstallPath + "Version.rb"

print "\nIAN (Image ANalyzer): v#{Version.name}. (#{Version.date}) Copyright 2004-#{Version.year}\n\n"
print "Loading code ... please wait.\n"

require InstallPath + "Units.rb"
require InstallPath + "Engine.rb"
require InstallPath + "ArgumentList.rb"
require InstallPath + "Instances.rb"

require 'thread'

require 'fox16'

include Fox

# TabBookWindow
#   instance variables
#     @app - the Fox UI app
#     @miniIcon - the small icon displayed in the upper left corner
#       of all windows
#     @engine - IAN's analysis engine
#     @jobProcessor - Thread that runs jobs (load-analyze-report)
#       by talking to the engine
#     @running - a status variable stating whether the @jobProcessor
#       Thread is currently processing jobs
#     @mutex - a Mutex variable used to synchronize all threads'
#       access to the @running variable
#     @output - an FXList containing the output from the engine.
#       Lives on tab5 of the tabbook
#     @hoursLabel - FXLabel that shows elapsed hours of job processing
#       Lives on tab5 of the tabbook
#     @minsLabel - FXLabel that shows elapsed mins of job processing
#       Lives on tab5 of the tabbook
#     @secsLabel - FXLabel that shows elapsed secs of job processing
#       Lives on tab5 of the tabbook
#     @progressBar - FXProgressBar that shows percent done
#       Lives on tab5 of the tabbook
#     @progressTarget - FXDataTarget that holds the percent done value
#       used by @progressBar
#     @clock - Thread that updates elapsed time FXLabels
#     @patts - Array of file patterns to send to file dialog:
#       = ["Erdas GIS (*.gis)","All files (*.*)"]
#     @directory - last used directory from file dialog
#     @pattern - last used pattern from file dialog
#     @fileList - FXList containing list of files user wants to process
#       Lives on tab1 of the tabbook
#     @anList - FXList containing the names of analyses : "Diversity"
#       Lives on tab2 of the tabbook
#     @rptList - FXList containing the names of reports : "Text (.txt)"
#       Lives on tab3 of the tabbook
    
class TabBookWindow < FXMainWindow

  def scrollLastItemOnScreen(*args)
    @output.makeItemVisible(@output.numItems-1)
  end
  
  TIMER_INTERVAL = 20
  
  def scrollAfterFoxIsReady
    @app.addTimeout(TIMER_INTERVAL, method(:scrollLastItemOnScreen))
  end

  APP_HEIGHT = 680
  APP_WIDTH  = 960
  SECS_PER_MINUTE = 60
  SECS_PER_HOUR = 60 * SECS_PER_MINUTE
  SPACES  = "  "
  HOURS   = " hours"
  MINUTES = " minutes"
  SECONDS = " seconds"
  
  def updateClock(elapsedSecs)
    integralSecs = elapsedSecs.round
    hours = integralSecs / SECS_PER_HOUR
    integralSecs = integralSecs % SECS_PER_HOUR
    mins = integralSecs / SECS_PER_MINUTE
    secs = integralSecs % SECS_PER_MINUTE
    @hoursLabel.text = SPACES + hours.to_s + HOURS
    @minsLabel.text  = SPACES + mins.to_s  + MINUTES
    @secsLabel.text  = SPACES + secs.to_s  + SECONDS
  end
  
  def statement(text)
    @output.appendItem(text)
    scrollAfterFoxIsReady
  end
  
  def warning(text)
    @output.appendItem("Warning: "+text)
    scrollAfterFoxIsReady
  end
  
  def error(text)
    @clock.kill if @clock and @clock.alive?
    @output.appendItem("Error: "+text)
    scrollAfterFoxIsReady
  end
  
  def percentDone(percent)
    percent = percent.to_i
    percent = 0 if percent < 0
    percent = 100 if percent > 100
    @progressTarget.value = percent
    @progressBar.forceRefresh
  end
  
  def displayHelp(sentences)
    w = APP_WIDTH - 15
    h = APP_HEIGHT - 15
    centerX = self.x + (self.width/2)
    centerY = self.y + (self.height/2)
    originX = centerX-(w/2)
    originY = centerY-(h/2)
    dialog = FXDialogBox.new(@app,"Help",DECOR_ALL,originX,originY,w,h)
    dialog.icon = @miniIcon
    outFrame = FXVerticalFrame.new(dialog,LAYOUT_FILL_X|LAYOUT_FILL_Y)
    topFrame = FXHorizontalFrame.new(outFrame,LAYOUT_FILL_X|LAYOUT_FILL_Y)
    bottomFrame = FXHorizontalFrame.new(outFrame,LAYOUT_CENTER_X)
    #list = FXList.new(topFrame,15,nil,0,LAYOUT_FILL_X)
    list = FXList.new(topFrame,nil,0,LAYOUT_FILL_X|LAYOUT_FILL_Y)
    list.font = FXFont.new(@app, "helvetica", 10, FONTWEIGHT_DEMIBOLD)
    button = FXButton.new(bottomFrame,"OK",nil,dialog,FXDialogBox::ID_ACCEPT)
    sentences.each { | sentence | list.appendItem(sentence) }
    dialog.show
    dialog.execute
  end
  
  def generalHelp()
    w = 350
    h = 270
    centerX = self.x + (self.width/2)
    centerY = self.y + (self.height/2)
    originX = centerX-(w/2)
    originY = centerY-(h/2)
    dialog = FXDialogBox.new(@app,"About IAN",DECOR_ALL, originX, originY, w, h)
    frame1 = FXHorizontalFrame.new(dialog)
    imageview = FXImageView.new(frame1)
    imageview.backColor = 0x00d8e9ec
    img = FXPNGImage.new(@app, nil,IMAGE_KEEP|IMAGE_SHMI|IMAGE_SHMP)
    @app.beginWaitCursor do
      FXFileStream.open(InstallPath+"marmot_lg.png", FXStreamLoad) do |stream|
        img.loadPixels(stream)
      end
      img.create
      imageview.image = img
    end
    frame2 = FXVerticalFrame.new(frame1)
    FXLabel.new(frame2,"IAN: Image ANalyzer")
    FXLabel.new(frame2,"  #{Version.name}")
    FXLabel.new(frame2,"  Released #{Version.date}")
    FXLabel.new(frame2,"  Created by Barry DeZonia")
    FXLabel.new(frame2,"  Copyright 2004-#{Version.year}")
    FXLabel.new(frame2,"  http://landscape.forest.wisc.edu/projects/ian/")
    FXLabel.new(frame2,"  ian-mail@mailplus.wisc.edu")
    FXLabel.new(frame2,"  Icons courtesy of bywestcoast.com")
    button = FXButton.new(frame2,"OK",nil,dialog,FXDialogBox::ID_ACCEPT)
    dialog.icon = @miniIcon
    dialog.show
    dialog.execute
  end
  
  def initialize(app)
  
    @app = app
    
    @mutex = Mutex.new
    @engine = Engine.new(self)   # create engine and hook to it
    
    @patts = []
    Dir.entries(InstallPath + "imagetypes").each do | filename |
      if filename != "." and filename != ".."
        imageType = filename[0,filename.length-3]  # remove ".rb"
        imageTypeFile = InstallPath + "imagetypes\\" + filename.downcase
        Kernel.load imageTypeFile
        cnv = ImageConverter.new
        @patts << (cnv.name.dup + " (*." + imageType + ")")
      end
    end
    @patts << "All files (*.*)"
    
    stream = FXFileStream.new
    stream.open(InstallPath+"marmot_sm.bmp", FXStreamLoad)
    @miniIcon = FXBMPIcon.new(@app, nil, 0)
    @miniIcon.loadPixels(stream)
    stream.close
    
    # Call the base class initializer first
    super(@app, "IAN (Image ANalyzer)   #{Version.name}   #{Version.date}", nil, @miniIcon, DECOR_ALL, 0, 0, APP_WIDTH, APP_HEIGHT)

    # Make a tooltip
    # FXTooltip.new(getApp())

    # Menubar appears along the top of the main window
    menubar = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X)

    # Separator
    FXHorizontalSeparator.new(self,
                              LAYOUT_SIDE_TOP|LAYOUT_FILL_X|SEPARATOR_GROOVE)

    # Contents
    contents = FXHorizontalFrame.new(self,
      LAYOUT_SIDE_TOP|FRAME_NONE|LAYOUT_FILL_X|LAYOUT_FILL_Y|PACK_UNIFORM_WIDTH)
  
    # Switcher
    tabbook = FXTabBook.new(contents, nil, 0,
                            LAYOUT_FILL_X|LAYOUT_FILL_Y|LAYOUT_RIGHT)
  
    # First item
    FXTabItem.new(tabbook, "Step &1", nil)
    listFrame1 = FXHorizontalFrame.new(tabbook, FRAME_THICK|FRAME_RAISED)
    vFrame = FXVerticalFrame.new(listFrame1,0)
    button1 = FXButton.new(vFrame,"Choose &Images",nil,nil,0,LAYOUT_FILL_X|BUTTON_NORMAL)
    button2 = FXButton.new(vFrame,"&Remove Images",nil,nil,0,LAYOUT_FILL_X|BUTTON_NORMAL)
    button9 = FXButton.new(vFrame,"&Clear Images",nil,nil,0,LAYOUT_FILL_X|BUTTON_NORMAL)
    button10 = FXButton.new(vFrame,"&Help",nil,nil,0,LAYOUT_FILL_X|BUTTON_NORMAL)
    #@fileList = FXList.new(listFrame1, 1, nil, 0,
    @fileList = FXList.new(listFrame1, nil, 0,
                           LIST_EXTENDEDSELECT|LAYOUT_FILL_X|LAYOUT_FILL_Y)
              
    # bugs in this version
    #   Rob got Step 4 Background None and Value selected and wouldn't unselect
    
    button1.connect(SEL_COMMAND) do  # tab 1: choose images
      
      # last kludgy way : would not remember directory
      #files = FXFileDialog.getOpenFilenames(self,"Select files to analyze",nil,@patts.join("\n"))
      
      # resurrected way that remembers paths and filetypes
      #  requires fxruby more recent than shipped with one click installer 1.8.2-14
      dialog = FXFileDialog.new(self,"Select files to analyze")
      dialog.selectMode = SELECTFILE_MULTIPLE
      dialog.setPatternList(@patts)
      dialog.directory = @directory if @directory
      dialog.currentPattern = @pattern if @pattern
      dialog.execute
      @directory = dialog.directory
      @pattern = dialog.currentPattern
      files = dialog.filenames
      
      files.each do | filename |
        @fileList.appendItem(filename)
      end
    end
      
    button2.connect(SEL_COMMAND) do  # tab 1: remove images
      itemNum = 0
      while itemNum < @fileList.numItems
        if @fileList.itemSelected?(itemNum)
          @fileList.removeItem(itemNum)
        else
          itemNum += 1
        end
      end
    end
    
    button9.connect(SEL_COMMAND) do  # tab 1: clear images
      while @fileList.numItems > 0
        @fileList.removeItem(0)
      end
    end
    
    button10.connect(SEL_COMMAND) do  # tab 1: help
      helpText = [
        "  IAN is a general purpose image analysis tool that generates reports about",
        "  raster images. IAN uses a 5 step process to specify an analysis run.",
        "  After the run is specified IAN applies the chosen analyses on the specified",
        "  images and generates reports. Help is available for each step in the process",
        "  by selecting the associated Help button.",
        "",
        "",
        "  During Step 1 you specify the images you would like to analyze.",
        "",
        "",
        "  Choose Images brings up a file selector that allows supported image types to",
        "  be chosen for analysis.",
        "",
        "",
        "  Remove Images allows you to remove images from the list of selected images.",
        "  First specify the images to remove by selecting them with the mouse (and the",
        "  Ctrl or Shift keys if desired). Then press the Remove Images button.",
        "",
        "",
        "  Clear Images empties the list of selected images.",
        "",
        "",
        "  IAN is designed to be easily extended with additional options, analyses,",
        "  reports, image file formats, and units. The IAN website gives directions on",
        "  how to make such extensions yourself. The IAN website also offers the latest",
        "  version of IAN plus any available extensions. IAN is intended to be an open",
        "  source software project. Please share your extensions with others through",
        "  the IAN website. The IAN website is at:",
        "    http://landscape.forest.wisc.edu/projects/ian",
        "",
        "",
        "  The authors of IAN hope that people will customize IAN to their needs. They",
        "  are willing to work with 3rd parties wishing to create extensions meant to",
        "  be included in the standard IAN distribution",
        "",
        "",
        "  IAN, IANC, and supporting code copyright (C) 2004-#{Version.year}  Barry DeZonia",
        "",
        "",
        "  This program is free to use; you can redistribute it and/or modify the",
        "  Ruby scripts that make up IAN but you cannot charge money for any",
        "  derivation. Any derivation must attribute IAN as a source. Any .DLL or",
        "  .SO files can only be redistributed as is and may not be reverse",
        "  engineered or replaced except with the authors' express permission.",
        "",
        "",
        "  This program is distributed in the hope that it will be useful, but",
        "  WITHOUT ANY WARRANTY; without even the implied warranty of",
        "  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE."
      ]
      displayHelp(helpText)
    end
    
    # Second item is an analysis list
    FXTabItem.new(tabbook, "Step &2", nil)
    listFrame2 = FXHorizontalFrame.new(tabbook, FRAME_THICK|FRAME_RAISED)
    vFrame = FXVerticalFrame.new(listFrame2,0)
    FXLabel.new(vFrame,"Choose Analyses")
    button3 = FXButton.new(vFrame,"&Toggle All",nil,nil,0,LAYOUT_FILL_X|BUTTON_NORMAL)
    button15 = FXButton.new(vFrame,"&Deselect All",nil,nil,0,LAYOUT_FILL_X|BUTTON_NORMAL)
    button11 = FXButton.new(vFrame,"&Help",nil,nil,0,LAYOUT_FILL_X|BUTTON_NORMAL)
    #@anList = FXList.new(listFrame2, 1, nil, 0,
    @anList = FXList.new(listFrame2, nil, 0,
                           LIST_EXTENDEDSELECT|LAYOUT_FILL_X|LAYOUT_FILL_Y)
    anTypes = []
    Dir.entries(InstallPath + "analyses").each do | filename |
      if filename != "." and filename != ".."
        analysisFile = InstallPath + "analyses\\" + filename.downcase
        Kernel.load analysisFile
        an = Analysis.new(nil,nil,nil,nil,nil,nil)
        anTypes << filename[0,filename.length-3]
        typeString = ""
        if (an.outType & AnalysisType::IMAGE) != 0
          typeString += "image"
        end
        if (an.outType & AnalysisType::CLASS) != 0
          typeString += "," if typeString.length > 0
          typeString += "class"
        end
        if (an.outType & AnalysisType::INTERCLASS) != 0
          typeString += "," if typeString.length > 0
          typeString += "interclass"
        end
        @anList.appendItem((an.name + " [" + typeString + "]"))
      end
    end
    entries = @anList.numItems
    entries.times do | itemNum |
      min = itemNum
      (min+1).upto(entries-1) do | entry |
        min = entry if @anList.getItemText(entry) < @anList.getItemText(min)
      end
      tmpS = @anList.getItemText(itemNum)
      tmpA = anTypes[itemNum]
      @anList.setItemText(itemNum,@anList.getItemText(min))
      anTypes[itemNum] = anTypes[min]
      @anList.setItemText(min,tmpS)
      anTypes[min] = tmpA
    end
    button3.connect(SEL_COMMAND) do  # tab 2: toggle all
      @anList.numItems.times do | itemNum |
        if @anList.itemSelected?(itemNum)
          @anList.deselectItem(itemNum)
        else
          @anList.selectItem(itemNum)
        end
      end
    end
    button15.connect(SEL_COMMAND) do  # tab 2: deselect all
      @anList.numItems.times do | itemNum |
        if @anList.itemSelected?(itemNum)
          @anList.deselectItem(itemNum)
        end
      end
    end
    button11.connect(SEL_COMMAND) do  # tab 2: help
      helpText = []
      @anList.numItems.times do | itemNum |
        if @anList.itemSelected?(itemNum)
          fileName = InstallPath + "analyses\\" + anTypes[itemNum] + ".rb"
          Kernel.load fileName
          a = Analysis.new(nil,nil,nil,nil,nil,nil)
          helpText << "" if helpText.length != 0
          a.help(true).each { | hstring | helpText << ("  " + hstring) }
        end
      end
      if helpText.length == 0
        helpText = [
          "  In Step 2 you select the analyses you are going to make on the selected",
          "  images of Step 1. To do so use the mouse (and if desired the Ctrl or",
          "  Shift keys) to select individual analyses from the list.",
          "",
          "",
          "  Each analysis is labeled with the types of the metrics it produces. Image",
          "  metrics report single measures that apply to the input image as a whole.",
          "  Class metrics report multiple measures - one per class present in the",
          "  input image. Interclass metrics report one measure for every combination",
          "  of the classes present in the input image. An analysis can report more",
          "  than one type of measure at a time. If it does then multiple types may be",
          "  listed. For example, some measures report both a class measure (lets say",
          "  area) and an image measure (lets say average class area).",
          "",
          "",
          "  The Toggle All button switches the selection state for each analysis in",
          "  the list. It allows you to easily select all analyses if desired. Or even",
          "  all analyses except a few selected ones.",
          "",
          "",
          "  The Deselect All button deselects any analysis previously chosen.",
          "",
          "",
          "  To get help on a specific analysis first select it in the list and then",
          "  press the Help button. You can select multiple analyses before selecting",
          "  the Help button."
        ]
      end
      displayHelp(helpText)
    end
    
    # Third item is a report list
    FXTabItem.new(tabbook, "Step &3", nil)
    listFrame3 = FXHorizontalFrame.new(tabbook, FRAME_THICK|FRAME_RAISED)
    vFrame = FXVerticalFrame.new(listFrame3,0)
    FXLabel.new(vFrame,"Choose Reports")
    button4 = FXButton.new(vFrame,"&Toggle All",nil,nil,0,LAYOUT_FILL_X|BUTTON_NORMAL)
    button16 = FXButton.new(vFrame,"&Deselect All",nil,nil,0,LAYOUT_FILL_X|BUTTON_NORMAL)
    button12 = FXButton.new(vFrame,"&Help",nil,nil,0,LAYOUT_FILL_X|BUTTON_NORMAL)
    # @rptList = FXList.new(listFrame3, 1, nil, 0,
    @rptList = FXList.new(listFrame3, nil, 0,
                           LIST_EXTENDEDSELECT|LAYOUT_FILL_X|LAYOUT_FILL_Y)
    rptTypes = []
    Dir.entries(InstallPath + "reports").each do | filename |
      if filename != "." and filename != ".."
        reportFile = InstallPath + "reports\\" + filename.downcase
        Kernel.load reportFile
        rpt = ReportWriter.new
        rptTypes << filename[0,filename.length-3]
        @rptList.appendItem(rpt.name)
      end
    end
    entries = @rptList.numItems
    entries.times do | itemNum |
      min = itemNum
      (min+1).upto(entries-1) do | entry |
        min = entry if @rptList.getItemText(entry) < @rptList.getItemText(min)
      end
      tmpS = @rptList.getItemText(itemNum)
      tmpA = rptTypes[itemNum]
      @rptList.setItemText(itemNum,@rptList.getItemText(min))
      rptTypes[itemNum] = rptTypes[min]
      @rptList.setItemText(min,tmpS)
      rptTypes[min] = tmpA
    end
    button4.connect(SEL_COMMAND) do  # tab 3: toggle all
      @rptList.numItems.times do | itemNum |
        if @rptList.itemSelected?(itemNum)
          @rptList.deselectItem(itemNum)
        else
          @rptList.selectItem(itemNum)
        end
      end
    end
    button16.connect(SEL_COMMAND) do  # tab 3: deselect all
      @rptList.numItems.times do | itemNum |
        if @rptList.itemSelected?(itemNum)
          @rptList.deselectItem(itemNum)
        end
      end
    end
    button12.connect(SEL_COMMAND) do  # tab 3: help
      helpText = []
      @rptList.numItems.times do | itemNum |
        if @rptList.itemSelected?(itemNum)
          fileName = InstallPath + "reports\\" + rptTypes[itemNum] + ".rb"
          Kernel.load fileName
          r = ReportWriter.new
          helpText << "" if helpText.length != 0
          r.help(true).each { | hstring | helpText << ("  " + hstring) }
        end
      end
      if helpText.length == 0
        helpText = [
          "  In Step 3 you select the reports you are going to generate from the",
          "  selected images of Step 1. To do so use the mouse (and if desired the",
          "  Ctrl or Shift keys) to select individual reports from the list. Reports",
          "  are created in the directory where the image is and uses the image\'s",
          "  name but tacks on a new extension. Each report specifies the extension",
          "  that will be used.",
          "",
          "",
          "  The Toggle All button switches the selection state for each report in",
          "  the list. It allows you to easily select all reports if desired. Or",
          "  even all reports except a few selected ones.",
          "",
          "",
          "  The Deselect All button deselects any report previously chosen.",
          "",
          "",
          "  To get help on a specific report first select it in the list and then",
          "  press the Help button. You can select multiple reports before selecting",
          "  the Help button."
        ]
      end
      displayHelp(helpText)
    end
    
    # Fourth item holds options
    FXTabItem.new(tabbook, "Step &4", nil)
    optionsFrame = FXHorizontalFrame.new(tabbook, FRAME_THICK|FRAME_RAISED)

    vFrame = FXVerticalFrame.new(optionsFrame)
    FXLabel.new(vFrame,"Choose Settings")
    button5 = FXButton.new(vFrame,"&Defaults",nil,nil,0,LAYOUT_FILL_X|BUTTON_NORMAL)
    button13 = FXButton.new(vFrame,"&Help",nil,nil,0,LAYOUT_FILL_X|BUTTON_NORMAL)

    group1 = FXGroupBox.new(optionsFrame, "Neighbors",
                            GROUPBOX_TITLE_LEFT|FRAME_RIDGE)
    # recommened way for FxRuby 1.2 - radios are very slow
    #radioStatus1 = FXDataTarget.new(1)
    #fourNeighs = FXRadioButton.new(group1, "&4", radioStatus1, FXDataTarget::ID_OPTION+1, ICON_BEFORE_TEXT|LAYOUT_SIDE_TOP)
    #eightNeighs = FXRadioButton.new(group1, "&8", radioStatus1, FXDataTarget::ID_OPTION+2, ICON_BEFORE_TEXT|LAYOUT_SIDE_TOP)
    fourNeighs = FXRadioButton.new(group1, "&4", nil, 0,  ICON_BEFORE_TEXT|LAYOUT_SIDE_TOP)
    eightNeighs = FXRadioButton.new(group1, "&8", nil, 0,  ICON_BEFORE_TEXT|LAYOUT_SIDE_TOP)
    fourNeighs.connect(SEL_COMMAND) { eightNeighs.checkState = false }
    eightNeighs.connect(SEL_COMMAND) { fourNeighs.checkState = false }
    
    eightNeighs.checkState = true

    group2 = FXGroupBox.new(optionsFrame, "Background",
                            GROUPBOX_TITLE_LEFT|FRAME_RIDGE)
    # recommened way for FxRuby 1.2 - radios are very slow
    #radioStatus2 = FXDataTarget.new(1)
    #noBack = FXRadioButton.new(group2, "&None", radioStatus2, FXDataTarget::ID_OPTION+1, ICON_BEFORE_TEXT|LAYOUT_SIDE_TOP)
    #yesBack = FXRadioButton.new(group2, "&Value", radioStatus2, FXDataTarget::ID_OPTION+2, ICON_BEFORE_TEXT|LAYOUT_SIDE_TOP)
    noBack = FXRadioButton.new(group2, "&None", nil, 0, ICON_BEFORE_TEXT|LAYOUT_SIDE_TOP)
    yesBack = FXRadioButton.new(group2, "&Value", nil, 0, ICON_BEFORE_TEXT|LAYOUT_SIDE_TOP)
    noBack.connect(SEL_COMMAND) { yesBack.checkState = false }
    yesBack.connect(SEL_COMMAND) { noBack.checkState = false }
    
    backValue = FXTextField.new(group2, 10, nil, 0,
                         JUSTIFY_LEFT|FRAME_SUNKEN|FRAME_THICK|LAYOUT_SIDE_TOP)
    noBack.checkState = true
    backValue.text = "0"
    
    group3 = FXGroupBox.new(optionsFrame, "Distance Units",
                            GROUPBOX_TITLE_LEFT|FRAME_RIDGE)
    #dUnitCombobox = FXComboBox.new(group3, 20, 5, nil, 0,
    dUnitCombobox = FXComboBox.new(group3, 20, nil, 0,
                 COMBOBOX_INSERT_LAST|FRAME_SUNKEN|FRAME_THICK|LAYOUT_SIDE_TOP)
    distFactor = FXTextField.new(group3, 10, nil, 0,
                         JUSTIFY_LEFT|FRAME_SUNKEN|FRAME_THICK|LAYOUT_SIDE_TOP)
    distFactor.text = "1.0"
    units = []
    Units.each("distance") do | unit |
      units << unit.name
    end
    units.sort!
    dUnitCombobox.appendItem("Image")
    units.each { | unit | dUnitCombobox.appendItem(unit) }
    dUnitCombobox.numVisible = 5;

    group4 = FXGroupBox.new(optionsFrame, "Area Units",
                            GROUPBOX_TITLE_LEFT|FRAME_RIDGE)
    # aUnitCombobox = FXComboBox.new(group4, 20, 5, nil, 0,
    aUnitCombobox = FXComboBox.new(group4, 20, nil, 0,
                 COMBOBOX_INSERT_LAST|FRAME_SUNKEN|FRAME_THICK|LAYOUT_SIDE_TOP)
    areaFactor = FXTextField.new(group4, 10, nil, 0,
                         JUSTIFY_LEFT|FRAME_SUNKEN|FRAME_THICK|LAYOUT_SIDE_TOP)
    areaFactor.text = "1.0"
    units = []
    Units.each("area") do | unit |
      units << unit.name
    end
    units.sort!
    aUnitCombobox.appendItem("Image")
    units.each { | unit | aUnitCombobox.appendItem(unit) }
    aUnitCombobox.numVisible = 5;

    button5.connect(SEL_COMMAND) do  # tab 4: reset to defaults
      eightNeighs.checkState = true
      fourNeighs.checkState = false
      noBack.checkState = true
      yesBack.checkState = false
      backValue.text = "0"
      distFactor.text = "1.0"
      areaFactor.text = "1.0"
      dUnitCombobox.currentItem = 0
      aUnitCombobox.currentItem = 0
    end
    
    button13.connect(SEL_COMMAND) do  # tab 4: help
      helpText = [
        "  In Step 4 you may set values that will affect the analyses. This step is",
        "  optional as IAN supplies defaults for the settings in this dialog",
        "",
        "",
        "  The Defaults button will reset all settings within the dialog to IAN's",
        "  preferred default values.",
        "",
        "",
        "  Neighbors specifies the number of neighbors a cell is considered to have.",
        "  Either 4 or 8 can be chosen. Some analyses can be affected by the number",
        "  of neighbors per cell.",
        "",
        "",
        "  Background specifies the background color of the images. An image can have",
        "  None or you can specify the Value of the background in the provided field.",
        "  In the field you can specify the background color in decimal (i.e. 12),",
        "  binary (i.e. 0b001), octal (i.e. 0377), or hexadecimal (i.e. 0xff). Besides",
        "  filling in the specified field with the value of the background color you",
        "  must select the Value radio button to direct IAN to use the setting.",
        "",
        "",
        "  Distance Units specifies the desired output units for distances. If Image",
        "  is chosen then the units that the image provides are used. Otherwise they",
        "  can be overidden by selecting a unit from the dropdown list. You can also",
        "  specify the scale of the unit in the provided field. An example might be",
        "  30.0 meters. If Image is chosen as the unit then the scale field is ignored.",
        "  If a unit is specified and the scale is 1.0 then unit conversion will take",
        "  place during the analysis.",
        "",
        "",
        "  Area Units specifies the desired output units for areas. If Image is chosen",
        "  then the units that the image provides are used. Otherwise they can be",
        "  overidden by selecting a unit from the dropdown list. You can also specify",
        "  the scale of the unit in the provided field. An example might be 100.0",
        "  hectares. If Image is chosen as the unit then the scale field is ignored.",
        "  If a unit is specified and the scale is 1.0 then unit conversion will take",
        "  place during the analysis."
      ]
      displayHelp(helpText)
    end
    
    # Fifth item holds job output
    FXTabItem.new(tabbook, "Step &5", nil)
    outputFrame = FXHorizontalFrame.new(tabbook, FRAME_THICK|FRAME_RAISED)
    buttonFrame = FXVerticalFrame.new(outputFrame,0)
    button6 = FXButton.new(buttonFrame,"&Analyze Images",nil,nil,0,LAYOUT_FILL_X|BUTTON_NORMAL)
    button7 = FXButton.new(buttonFrame,"&Stop Analyzing",nil,nil,0,LAYOUT_FILL_X|BUTTON_NORMAL)
    button8 = FXButton.new(buttonFrame,"&Clear Window",nil,nil,0,LAYOUT_FILL_X|BUTTON_NORMAL)
    button14 = FXButton.new(buttonFrame,"&Help",nil,nil,0,LAYOUT_FILL_X|BUTTON_NORMAL)
    @progressTarget = FXDataTarget.new(0)
    @progressBar = FXProgressBar.new(buttonFrame, @progressTarget, 
      FXDataTarget::ID_VALUE, PROGRESSBAR_PERCENTAGE | PROGRESSBAR_DIAL)
    FXLabel.new(buttonFrame,"Elapsed time")
    @hoursLabel = FXLabel.new(buttonFrame,"  0 hours")
    @minsLabel = FXLabel.new(buttonFrame,"  0 minutes")
    @secsLabel = FXLabel.new(buttonFrame,"  0 seconds")
    @progressBar.barBGColor = 0x00000000
    contentFrame = FXVerticalFrame.new(outputFrame, LAYOUT_FILL_X|LAYOUT_FILL_Y)
    #@output = FXList.new(contentFrame, 20, nil, 0,
    @output = FXList.new(contentFrame, nil, 0,
                           LIST_EXTENDEDSELECT|LAYOUT_FILL_X|LAYOUT_FILL_Y)
    
    button6.connect(SEL_COMMAND) do  # tab 5: analyze images

      # avoid running Analyze Images if currently running
      
      # crash: break if @jobProcessor and @jobProcessor.alive?
      # crash: return if @jobProcessor and @jobProcessor.alive?
      
      # already processing current job?
      if @jobProcessor and @jobProcessor.alive?
        # do nothing
      else
        percentDone(0)
        
        # initialize variables
      
        if dUnitCombobox.currentItem == 0
          DesiredDistUnit.unit = nil
        else  # user specified a unit
          DesiredDistUnit.unit = Units.find(dUnitCombobox.getItemText(dUnitCombobox.currentItem))
        end
        factor = distFactor.text.to_f
        if factor == 0.0 or factor == 1.0
          DesiredDistUnit.factor = nil
        else
          DesiredDistUnit.factor = factor
        end
        if aUnitCombobox.currentItem == 0
          DesiredAreaUnit.unit = nil
        else  # user specified a unit
          DesiredAreaUnit.unit = Units.find(aUnitCombobox.getItemText(aUnitCombobox.currentItem))
        end
        factor = areaFactor.text.to_f
        if factor == 0.0 or factor == 1.0
          DesiredAreaUnit.factor = nil
        else
          DesiredAreaUnit.factor = factor
        end

        # Build job base

        options = []
        analyses = []
        images = []
        reports = []
        bad = false
      
        # images
        @fileList.numItems.times do | itemNum |
          image = @fileList.getItemText(itemNum)
          extPos = image.rindex(".")
          if extPos
            type = image[extPos+1,image.length-extPos-1 ]
            argStr = type+"("+image+")"
            images << ArgumentList.new(argStr)
          end
        end
      
        if images.length == 0
          error("No images were chosen in Step 1.")
          bad = true
        end
      
        # options
        if eightNeighs.checkState > 0
          argStr = "n(8)"
        else
          argStr = "n(4)"
        end
        options << ArgumentList.new(argStr)
      
        if yesBack.checkState > 0
          options << ArgumentList.new("b("+backValue.text+")")
        end
      
        # analyses
        @anList.numItems.times do | itemNum |
          if @anList.itemSelected?(itemNum)
            argStr = anTypes[itemNum]
            analyses << ArgumentList.new(argStr)
          end
        end

        if analyses.length == 0
          error("No analyses were chosen in Step 2.")
          bad = true
        end
      
        # reports
        @rptList.numItems.times do | itemNum |
          if @rptList.itemSelected?(itemNum)
            argStr = rptTypes[itemNum]
            reports << ArgumentList.new(argStr)
          end
        end
      
        if reports.length == 0
          error("No reports were chosen in Step 3.")
          bad = true
        end
          
        if not bad
      
          # define jobs

          images.each do | imageArg |
            job = Job.new
            job.registerImage(ImageInstance.new(imageArg))
            options.each do | optionArg |
              job.registerOption(OptionInstance.new(optionArg))
            end
            analyses.each do | analysisArg |
              job.registerAnalysis(AnalysisInstance.new(analysisArg))
            end
            reports.each do | reportArg |
              job.registerReport(ReportInstance.new(reportArg,true))
            end
            @engine.registerJob(job)
          end

          # run jobs

          # wait for any previous jobs to terminate
          running = nil      
          @mutex.synchronize do
            running = @running
          end
          while running
            @app.runWhileEvents(self)
            sleep(1)
            @mutex.synchronize do
              running = @running
            end
          end

          # hatch job processing

          @clock = Thread.new {
            startTime = Time.now
            until 0 == 1 do
              updateClock(Time.now-startTime)
              sleep(1)
            end
          }
          
          @jobProcessor = Thread.new {

            @mutex.synchronize do
              @running = true
            end

            @engine.runJobs

            @engine.clearJobs

            @mutex.synchronize do
              @running = nil
            end

            @clock.kill if @clock and @clock.alive?
          }
        end  # if not bad
      
      end # not already running
      
    end  # button 6 commands
    
    button7.connect(SEL_COMMAND) do  # tab 5: stop analyzing
      @mutex.synchronize do
        if @running
          @engine.clearJobs
          @jobProcessor.kill if @jobProcessor and @jobProcessor.alive?
          @clock.kill if @clock and @clock.alive?
          @running = nil
          statement("")
          statement("Processing terminated by user")
          statement("")
        end
      end
    end
    
    button8.connect(SEL_COMMAND) do  # tab 5: clear
      percentDone(0)
      @output.clearItems
    end
    
    button14.connect(SEL_COMMAND) do  # tab 5: help
      helpText = [
        "  In Step 5 you analyze the images you selected in Step 1 and you generate the",
        "  reports you selected in Step 3.",
        "",
        "",
        "  Analyze Images starts the analyzation process. A gauge lets you know how far",
        "  along the process is.",
        "",
        "",
        "  Stop Analyzing will interrupt any analysis taking place. It can be restarted",
        "  by selecting Analyze Images.",
        "",
        "",
        "  Clear Window removes all text from the report window."
      ]
      displayHelp(helpText)
    end
    
    # File Menu
    filemenu = FXMenuPane.new(self)
    FXMenuTitle.new(menubar, "&File", nil, filemenu)
    FXMenuCommand.new(filemenu, "&Quit\tAlt-F4", nil, @app, FXApp::ID_QUIT)
    
    # Help Menu
    helpmenu = FXMenuPane.new(self)
    FXMenuTitle.new(menubar, "&Help", nil, helpmenu)
    FXMenuCommand.new(helpmenu, "&About", nil, self, SEL_COMMAND).connect(SEL_COMMAND) do
      generalHelp
    end
    
  end  # initialize
  
  def create
    super
    show(PLACEMENT_SCREEN)
  end
end

# Make an application
application = FXApp.new("IAN GUI", "Barry DeZonia")

# Build the main window
TabBookWindow.new(application)

# Create the application and its windows
application.create

# Run
application.run
