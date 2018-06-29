
require InstallPath + 'Job.rb'

class Engine

  def initialize(ui)
    @ui = ui  # so statement(), warning(), error() and displayHelp(), can be called
    @jobs = []
    @helpItems = []
  end
  
  def registerJob(job)
    @jobs << job
  end

  def registerJobs(someJobs)
    someJobs.each { | job | registerJob(job) }
  end

  def jobCount
    @jobs.size
  end

  def getJob(i)
    @jobs[i]
  end
  
  def runJob(i)
    getJob(i).run
  end
  
  def runJobs()
    begin
      totalTime = 0
      jobNum = 0
      endPercent = 0
      output = Array.new
      @jobs.each do | job |
        jobNum += 1
        startPercent = endPercent
        endPercent = 100*jobNum.to_f/@jobs.size
        output = output + [job.run(self,startPercent,endPercent)]
        totalTime += job.time
      end
      statement("Total time for all jobs: "+Job.makeTimeStr(totalTime))
      percentDone(100)
      output
    rescue => errMsg
      error(errMsg)
      []
    end
  end
  
  def clearJobs
    @jobs = []
  end
  
#   help: returns an array of strings

  def help(items)
    if items.size == 0
      @ui.generalHelp
    else
      helpText = []
      items.each do | item |
        itemText = item.help(self)
        helpText = helpText + [""] + itemText
      end
      @ui.displayHelp(helpText)
    end
  end
  
  def statement(text)
    @ui.statement(text)
  end
  
  def warning(text)
    @ui.warning(text)
  end
  
  def error(text)
    @ui.error(text)
  end
  
  def percentDone(percent)
    @ui.percentDone(percent)
  end
  
end
