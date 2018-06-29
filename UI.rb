
class UI  # abstract base class for UI's. Only necessary to show implementors
          # what must be supported to work with existing code

  # text is an array of strings. blank strings separate paragraphs.
  #   strings shouldn't be longer than 80 chars for comm-line compatibility

  def statement(text)
    raise NoMethodError, "UI.statement() must be overriden!"
  end
  
  def warning(text)
    raise NoMethodError, "UI.warning() must be overriden!"
  end
  
  def error(text)
    raise NoMethodError, "UI.error() must be overriden!"
  end
  
  def displayHelp(text)
    raise NoMethodError, "UI.displayHelp() must be overriden!"
  end
  
  def generalHelp()
    raise NoMethodError, "UI.generalHelp() must be overriden!"
  end
  
end
