
class Option

  def help(verbose)
    if (verbose)
      ["N - Neighbors per cell: set to 4 or 8: -N(4) or -N(8)."]
    else
      ["N - Neighbors: (4) or (8)."]
    end
  end

  def name
    "Neighborhood"
  end
end
