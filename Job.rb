
require InstallPath + 'Units.rb'
require InstallPath + 'Instances.rb'

class Job

  def initialize
    @options = []
    @analyses = []
    @image = []
    @reports = []
    @time = 0
    @timeStr = "0 seconds"
  end
  
  attr_reader(:options,:analyses,:image,:reports,:time,:timeStr)

  def Job.makeTimeStr(elapsedSecs)
    secsPerMinute = 60
    secsPerHour = 60*secsPerMinute
    secsPerDay = 24*secsPerHour
    days = 0
    while elapsedSecs >= secsPerDay
      days += 1
      elapsedSecs -= secsPerDay
    end
    hours = 0
    while elapsedSecs >= secsPerHour
      hours += 1
      elapsedSecs -= secsPerHour
    end
    minutes = 0
    while elapsedSecs >= secsPerMinute
      minutes += 1
      elapsedSecs -= secsPerMinute
    end
    seconds = elapsedSecs.round
    msg = ""
    if days > 0
      msg += ("1 day") if (days == 1)
      msg += (days.to_s + " days") if (days > 1)
    end
    if hours > 0
      msg += " " if msg.length > 0
      msg += ("1 hour") if (hours == 1)
      msg += (hours.to_s + " hours") if (hours > 1)
    end
    if minutes > 0
      msg += " " if msg.length > 0
      msg += ("1 minute") if (minutes == 1)
      msg += (minutes.to_s + " minutes") if (minutes > 1)
    end
    if seconds == 0
      msg = "1 second" if msg.length == 0
    else  # seconds > 0
      msg += " " if msg.length > 0
      msg += ("1 second") if (seconds == 1)
      msg += (seconds.to_s + " seconds") if (seconds > 1)
    end
    msg
  end
  
  def run(engine,startPercent,endPercent)
    jobBegin = Time.now
    steps = 1 + @analyses.size + @reports.size  # 1 for image create/load
    output = []
    @image.create(engine)
    step = 1
    engine.percentDone(startPercent + ((endPercent - startPercent)*(step.to_f/steps)))
    distUnit = UnitizedNumber.new(DesiredDistUnit,@image.distUnit,"distance")
    areaUnit = UnitizedNumber.new(DesiredAreaUnit,@image.areaUnit,"area")
    optionList = OptionList.new
    @options.each { | option | optionList.add(option.create(engine)) }
    @analyses.each do | analysis |
      output += analysis.run(engine,optionList,@image,distUnit,areaUnit)
      step += 1
      engine.percentDone(startPercent + ((endPercent - startPercent)*(step.to_f/steps)))
    end
    @reports.each do | report |
      report.run(engine,optionList,@image,output)
      step += 1
      engine.percentDone(startPercent + ((endPercent - startPercent)*(step.to_f/steps)))
    end
    image = nil
    GC.start
    jobEnd = Time.now
    @time = jobEnd-jobBegin
    @timeStr = Job.makeTimeStr(@time)
    engine.statement("Elapsed time: " + @timeStr)
    engine.statement("")
    engine.percentDone(endPercent)
  end
  
  def registerOption(option)
    @options.reject! { | anOption | (option.type.downcase == anOption.type.downcase) }
    @options << option
  end
  
  def registerAnalysis(analysis)
    @analyses.reject! { | anAnalysis | (analysis.type.downcase == anAnalysis.type.downcase) }
    @analyses << analysis
  end
  
  def registerImage(image)
    @image = image
  end
  
  def registerReport(report)
    @reports.reject! { | aReport | (report.type.downcase == aReport.type.downcase) }
    @reports << report
  end
  
end

