class Calculator

  Infinity = 1000000000000000000000000000


  # Regress
  #  input: an array of tuples [[1,5],[2,6],..[indep,dep]]
  #  output: regression line coefficients [slope,intercept]
  
  def Calculator.regress(tuples)  # copied from old fragstats code: may exhibit roundoff
  
    sum_x = 0.0
    sum_y = 0.0
    sum_xy = 0.0
    sum_sq_x = 0.0

    tuples.each do | tuple |
      x,y = *tuple
      sum_x += x
      sum_y += y
      sum_xy += (x * y)
      sum_sq_x += (x * x)
    end
    
    if tuples.length <= 1
      return [0.0,0.0]
    else
      # calc intercept
      val1 = ((sum_y * sum_sq_x) - (sum_x * sum_xy)).abs
      val2 = ((tuples.length * sum_sq_x) - (sum_x * sum_x)).abs
      if ((val1 - val2).abs < 0.00000009) 
        intercept = 0.0
      else
        intercept = val1 / val2
      end

      # calc slope
      val1 = ((tuples.length * sum_xy) - (sum_x * sum_y)).abs
      val2 = ((tuples.length * sum_sq_x) - (sum_x * sum_x)).abs

      if ((val1 - val2).abs < 0.00000009) 
        slope = 0.0
      else
        slope = val1 / val2
      end
      
      return [slope,intercept]
    end
  end

  # StatSummary
  #  input: an unsorted array of values [1,7,3,1,8]  not necessarily floats
  #  output:   [mean,stdDev,median,firstQ,thirdQ,min,max]
  
  def Calculator.statSummary(arrayOfVals,weights=nil)
    if arrayOfVals.length == 0
      mean   = 0.0
      stdDev = 0.0
      median = 0.0
      firstQ = 0
      thirdQ = 0
      min    = 0
      max    = 0
      wmean  = 0.0
    else
      sorted = arrayOfVals.sort
      # calc mean and stdDev
      sx = 0
      sx2 = 0
      wsx = 0
      totWeight = 0
      entryNum = 0
      sorted.each do | val |
        fltVal = val.to_f
        sx += fltVal
        sx2 += fltVal * fltVal
        if weights
          weight = weights[entryNum]
          wsx += fltVal * weight
          totWeight += weight
          entryNum += 1
        end
      end
      numItems = sorted.length
      mean = sx / numItems
      if totWeight == 0
        wmean = 0.0
      else
        wmean = wsx / (numItems * totWeight)
      end
      if numItems == 1
        stdDev = 0.0
      else
        var = (numItems*sx2 - sx*sx) / (numItems*(numItems-1))
        var = 0.0 if var < 0
        stdDev = Math.sqrt(var)
      end
      # calc median
      if (sorted.length % 2 == 0)  # even number of entries
        entryNum = sorted.length / 2
        median = (sorted[entryNum-1] + sorted[entryNum]) / 2.0
        #  previous statement did entryNum-1 because entryNum calc is 1-based
        #    and array is 0-based
      else  # odd number of entries
        entryNum = sorted.length / 2 + 1
        median = sorted[entryNum-1].to_f
        #  previous statement did entryNum-1 because entryNum calc is 1-based
        #    and array is 0-based
      end
      firstQ = sorted[(sorted.size+3)/4 - 1]
      thirdQ = sorted[((3*sorted.size)+1)/4 - 1]
      min = sorted[0]
      max = sorted[sorted.length-1]
    end
    [mean,stdDev,median,firstQ,thirdQ,min,max,wmean]
  end
  
end