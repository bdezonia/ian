
require 'Image1'
require 'Image4'
require 'Image8'
require 'Image16'
require 'Image24'

#bug : why doesn't above require need InstallPath?

class ImageCreator

  def ImageCreator.createImage(rows,cols,bitsPerPix,engine)
    image = nil
    # engine.statement("Image has "+bitsPerPix.to_s+" bits per pixel\n")
    case bitsPerPix
      when 1
        image = Image1.new(rows,cols)
      when 4
        image = Image4.new(rows,cols)
      when 8
        image = Image8.new(rows,cols)
      when 16
        image = Image16.new(rows,cols)
      when 24
        image = Image24.new(rows,cols)
      else
        engine.error("Unsupported bits per pixel: "+bitsPerPix.to_s + ". Must be 1, 4, 8, 16, or 24.\n Can't create image.\n")
    end
    image
  end

end

