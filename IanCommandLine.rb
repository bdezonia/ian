
require InstallPath + 'CLParser'

class IanCommandLine

  def initialize
    # load non-ruby-option command line into an Array
    entries = []
    #  $* is command line with Ruby options removed
    $*.each { | arg | entries += [arg] }
    @parser = CLParser.new(entries)
  end
  
  def error
    @parser.error
  end
  
  def jobsWanted
    @parser.jobs.length > 0
  end
  
  def helpWanted
    not jobsWanted
  end
  
  # following called under assumption jobsWanted == true
  
  def jobs
    @parser.jobs
  end
  
  # following called under assumption helpWanted == true
  
  def helpItems
    @parser.helpItems
  end
  
end
