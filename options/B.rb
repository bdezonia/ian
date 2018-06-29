class Option

  def help(verbose)
    if (verbose)
      ["B - Background color : examples -B(0), -B(0xff), -B(0b110), -B(0377)"]
    else
      ["B - Background: (color)."]
    end
  end

  def name
    "Background"
  end
end

