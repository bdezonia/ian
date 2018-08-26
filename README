
IAN - a raster image analysis tool

Introduction
IAN generates reports from the statistical analysis of raster images. It is programmed in the open source scripting language Ruby enabling technically savvy users and the developers to easily extend the program. The existing framework is designed to easily support additional metrics, reports, image file formats, options, and units. The flexible architecture of IAN streamlines the process of new releases. IAN runs on all 32-bit Windows platforms. It comes with two user interfaces - a user friendly windowing user interface (IAN) and a command line user interface (IANC) for console and programmatic access. If you have any questions about IAN you can contact us at ian-mail@mailplus.wisc.edu.

History
IAN was developed at the Forest Landscape Ecology Lab, Department of Forest Ecology and Management, University of Wisconsin-Madison. IAN grew from the same concept that gave birth to APACK and FRAGSTATS in the landscape ecology arena. But IAN can be used in any discipline that requires image analysis. As IAN grows its metric set can come from a variety of fields. IAN was first released in August of 2004.

Benefits of IAN over APACK (and FRAGSTATS)
- User friendly GUI
- Extensive online help
- Easy to use Install program
- Many images can be processed at one time
- Reads Windows BMP files as input allowing images from nearly any application to be analyzed
- Excel-compatible output format
- Multiple text report formats
- Support for many more unit types (foot, acre, furlong, angstrom, etc.)
- Support for many image formats (1 bit, 4 bit, 8 bit, 16 bit, 24 bit)
- The command line version supports long file names and long unit names. In other words spaces are okay in the command line version
- Slowest APACK metrics removed
- Extensible by user

Downloading IAN
In order to download IAN, you need to register first at our registration page, after which the download process will begin automatically.

Installing IAN
Prerequisites
IAN is written in Ruby. Therefore you need a Ruby interpreter installed before you can run IAN.
Getting Ruby
The standard Ruby distribution can be found at RubyForge's website: http://rubyinstaller.rubyforge.org/wiki/wiki.pl. Download version 1.8.1 or later. Do not download any version that ends in "_rc<num>" as this denotes a Release Candidate release and not an official stable release.
Installing Ruby
Run the EXE you’ve downloaded from RubyForge. This will install the interpreter, all necessary libraries, and will put the interpreter on your path. IMPORTANT: If the interpreter is not on your path IAN will not work correctly. After installation of IAN if you have difficulty getting IAN to run verify that the Ruby interpreter is on your path. To do so open a Command Prompt window and type "ruby -v". If Ruby is on your path you should get a version string back. If it is not on your path you must put it there through the Control Panel :: System :: Advanced :: Environmental Variables. If Ruby was installed in c:\ruby you would specify c:\ruby\bin as an additional search path.
Unzipping IAN
Take the ZIP file you’ve downloaded from this site and unzip it to a directory (i.e. c:\InstIan). To unzip the ZIP file use a program such as WinZip or PkZip/Unzip. If you are using the latest version of Windows you can use the ZIP support built directly into Explorer.
Running IAN's install program
From Windows’ Start Menu choose Run, browse to the directory you created and select install.rb. Choose OK to begin installation. Follow the prompts to complete the installation process.
Adding IAN's directory to the path (optional)
It is recommended that you add IAN to your path. This can be done by selecting Control Panel :: System from within Windows (or My Computer :: Properties). Choose the Advanced tab and select the Enviromental Variables button. Use the bottom window of the dialog to edit the Path environmental variable. Add a semicolon immediately followed by the full path to where you installed IAN. 

For example, IAN may have been unzipped to c:\IanInst and then through the install program it may have been installed in c:\Ian. Let's says the existing path is c:\windows. Edit the new path to look like c:\windows;c:\Ian.
Clean up
You may now remove the directory where you unzipped IAN to (i.e. C:\InstIan). You are now ready to use IAN.

Running IAN: The windowed UI
The windowed version of IAN is named IAN.BAT and lives in the directory you installed IAN in. By invoking this batch file the windowed user interface will be launched. IAN launches a command prompt window in order to interpret its code to launch the UI. If this command window is bothersome it can be bypassed by creating a Windows shortcut whose command line is <ianpath>\winui.rbw (e.g. c:\Ian\winui.rbw). Once you’ve started IAN read the online help to learn how to use it.

Running IAN: The command line UI
The command line version of IAN is named IANC.BAT and lives in the directory you installed IAN in. By invoking this batch file the command line user interface will be launched. Open a Command Prompt Window and type IANC –h to get access to the online help.

IAN Functionality
Options
(command line UI only - windowed version has equivalent functionality)
-H,-?
Use to get online help. If used alone ("IANC -h") a general overview of IANC’s command line syntax is given. Otherwise item specific help is given on the items that follow –H on the command line. For example, to get help on the ASC file format type “IANC –h iasc”.
-B
Specify the background color of the input image(s) on the command line. Correct use of –B includes a color as an argument (e.g. –B(100)). The color can be specified in decimal (e.g. –B(5)), binary (leading 0b e.g. –B(0b1111)), octal (leading 0 e.g. –B(014)), and hexadecimal (leading 0x e.g. –B(0xff0000)).
-N
Specify the number of neighbors each cell has. Correct use of –N includes a number (either 4 or 8) as an argument (e.g.–N(4)). This affects how polygons borders and cell adjacencies are calculated.
-UA
Specify the areal unit of the input image(s) on the command line. Correct use of –UA includes an optional measure (and tilde) followed by an areal unit name (e.g. –UA(100.0~sq. m)). The unit type must be area. The name can be singular, plural, or abbreviated and can contain spaces.
-UD
Specify the distance unit of the input image(s) on the command line. Correct use of –UD includes an optional measure (and tilde) followed by a distance unit name (e.g. –UD(30.0~m)). The unit type must be distance. The name can be singular, plural, or abbreviated and can contain spaces.
-A,-AALL
Select all analyses. When used in conjunction with –H this will report help on all analyses installed on the system. Otherwise all analyses installed on the system will be run on the image(s) listed on the command line.
-IALL
Select all image types. When used in conjunction with –H this will report help on all image types supported by the system.
-OALL
Select all options. When used in conjunction with –H this will report help on all options installed in the system.
-RALL
Select all reports. When used in conjunction with –H this will report help on all reports supported by the system.
Analyses
For a comprehensive summary of analyses please read below
Image File Formats
ASC - IAN's (and APACK's) ASCII file format
This file format is documented below
BMP - Windows BMP file format
This file format is documented in the Microsoft Windows Knowledge Base
GIS - ERDAS 7.4 compatible GIS file format
This file format is documented in the ERDAS Field Guide
LAN - ERDAS 7.4 compatible LAN file format
This file format is documented in the ERDAS Field Guide
Reports
CSV - Comma Separated Values (Excel compatible)
TXT - Text format (metrics grouped by metric)
TX2 - Text format (metrics grouped by class)

Extending IAN

Please read how to extend IAN below

IAN's and APACK's ASCII image file format

IAN and APACK define and support a case insensitive ASCII image file format. An well defined ASCII image file is comprised of sections of user specified data. In general the ASCII image file format definition supports free layout of sections. Sections can appear in any order and not all sections are  required. Sections can be separated by additional whitespace (or blank lines) if desired. Any deviations from these conventions are noted below.

A minimal ASCII image file includes three sections: the rows section, the columns section, and the cells section. These sections are each described below.

ASCII image files can be embellished with additional information such as a legend, a title, measurement units, and comments. Comments start with the two character sequence //. All text following the two character sequence // to the end of line is ignored.

Columns section

The number of columns in the image file is specified in the columns section of the ASCII image. This section is a required element of any ASCII image file. The columns section starts with the string [columns] on its own line. The number of columns is then specified on the following line. The specification of the columns section in the ASCII image file must precede the cells section.

Rows section

The number of rows in the image file is specified in the rows section of the ASCII image. This section is a required element of any ASCII image file. The rows section starts with the string [rows] on its own line. The number of rows is then specified on the following line. The specification of the rows section in the ASCII image file must precede the cells section.

Cells section

The actual cell data in the image file is specified in the cells section of the ASCII image. This section is a required element of any ASCII image file. It must not precede the rows section or the columns section. The cells section starts with the string [cells] on its own line. Then starting on the next line each cell value is specified separated by spaces and/or carriage returns. There should be exactly as many cell values listed as there are rows and columns specified. APACK reads cell values one complete row at a time from top to bottom. So the first cell value entry is mapped to row 1 and column 1 and pertains to the upper left corner of an image. The second cell value entry is mapped to row 1 and column 2.

Title section

The title of the image file is specified in the title section of the ASCII image. Including this section in the definition of an ASCII image file is optional. The title section starts with the string [title] on its own line. Then starting on the next line the title string is specified. The case of the title string is maintained.

Legend section

The legend of the image file is specified in the legend section of the ASCII image. Including this section in the definition of an ASCII image file is optional. The legend section starts with the string [legend] on its own line. Then the following lines contain a cell value followed by a legend string. Legend items can specified in any order desired and there is no need to specify all of them. Simply specify those that are of interest. The cell value specified pertains to the cell value associated with the legend string. The cell values must be <= 16 million. The case of the legend strings are maintained.

Cell spacing section

The cell spacing of the image file is specified in the cell spacing section of the ASCII image. Including this section in the definition of an ASCII image file is optional. The cell spacing section starts with the string [cell spacing] on its own line. Then starting on the next line a number followed by a unit name is specified. The number specified represents the number of units between cells and must be greater than zero. The unit name specified represents the unit and must be a distance unit. In APACK the unit must be one of m, km, ft, yd, or mi. IAN has a much larger set of distance units. Simply specify the name or abbreviation of your distance unit. If it is not found in IANs unit database it is not difficult to add to IAN.

An example test image follows:

// Example ASCII text image file
//

[title]

Example text image for IAN and APACK

[rows]

4

[columns]

4

[cells]

1 1 2 2  // row 1

1 5 5 2  // row 2

4 5 5 3

4 4 3 3  // last row

[legend]

1 water

2 marsh

3 scrub

4 conifer

5 deciduous

0 background

[cell spacing]

28.5 m

//
// End example ASCII text image file

Extending IAN

 

Programming Ruby

 

If you would like to extend IAN first you will need to learn how to program in Ruby. Ruby is a very useful scripting language that you can use for many projects other than IAN. A good web introduction to Ruby can be found at http://www.rubycentral.com/book/. Its based upon the most popular print introduction to Ruby: “Programming Ruby – The Pragmatic Programmmer’s Guide”. To make an extension to IAN you need only learn the basics of the language. The basic templates of the extensions are outlined below and class descriptions are compiled in a library description.

 

How to create an extension

 

Adding a new analysis
 

Analyses live in the ANALYSES subdirectory under IAN’s install directory. Any analysis you make must be placed there. Look at the analyses present in IAN for ideas on how to do things. Your analysis class must be named Analysis and must take the following format:

 

class Analysis

def initialize(engine,options,image,distUnit,areaUnit,args)

# Only record initialization information here. Do actual initialization at the beginning of run method. This ensures that help

# will work correctly.

# engine is the Engine from the class library that is calling this Analysis. You should remember its reference so you can

# interact with the user interface.

# options is an OptionList containing all command line options and their values as OptionSummaries

# image is an ImageInstance associated with the image to be analyzed

# distUnit is the distance Unit the output should be reported in

# areaUnit is the area Unit the output should be reported in

# args is an Array of Strings representing the arguments to the Analysis specified on the command line. For instance the

# Analysis may be invoked on the command line like this: AAR(1,2,3).

end

def help(verbose)

# verbose is a flag (true or false) specifying whether verbose help or brief help is desired. Brief help is at most one line.

# return an Array of Strings describing the Analysis

end

def run

# return an Array of one or more output summaries (library class OutputSummary)

    # use the information from initialize to run your Analysis

end

def name

# a String identifying the Analysis

end

def outType

# a flag specifying the types of the metrics reported by this analysis. It can be any combination of  AnalysisType::IMAGE,

# AnalysisType::CLASS, and AnalysisType::INTERCLASS

end

end

 

Your Analysis can have additional methods if desired. It will become instantly available to both the command line version and the windowed version of IAN.

 

Adding a new report
 

ReportWriters live in the REPORTS subdirectory under IAN’s install directory. Any report you make must be placed there. Look at the reports present in IAN for ideas on how to do things. Your report class must be named ReportWriter and must take the following format:

 

class ReportWriter

def outName

# a String whose value is the file name of the report being written

end

def run(engine,options,image,analysesOutput,args,verbose)

# engine is the Engine from the class library that is calling this ReportWriter. You should remember its reference so you can

# interact with the user interface.

# options is an OptionList containing all command line options and their values as OptionSummaries

# image is an ImageInstance associated with the image to be analyzed

# analysesOutput is an Array of OutputSummaries. It’s the output from all of the analyses that have been run.

# args is an Array of Strings representing the arguments to the ReportWriter specified on the command line. For instance

  # the ReportWriter may be invoked on the command line like this: RTXT(c:\fred.out).

# verbose is a flag (true or false) specifying whether verbose output or brief output is desired.

end

def help(verbose)

# verbose is a flag (true or false) specifying whether verbose help or brief help is desired. Brief help is at most one line.

# return an Array of Strings describing the ReportWriter

end

end

 

Adding a new option
 

Options live in the OPTIONS subdirectory under IAN’s install directory. Any option you make must be placed there. Look at the options present in IAN for ideas on how to do things. Your option class must be named Option and must take the following format:

 

class Option

def help(verbose)

# verbose is a flag (true or false) specifying whether verbose help or brief help is desired. Brief help is at most one line.

# return an Array of Strings describing the Option

end

def name

# a String used to identify the Option internally. For example, “Background”.

end

end

 

Your Option can have additional methods if desired. Your Option will automatically be available to the command line version of IAN. You can write additional analyses or modify existing analyses to use the value of your Option.

 

Adding a new image file format
 

ImageConverters live in the IMAGETYPES subdirectory under IAN’s install directory. Any image converter you make must be placed there. Look at the image converters present in IAN for ideas on how to do things. Your converter class must be named ImageConverter and must take the following format:

 

class ImageConverter

def name

# a String identifying the ImageConverter

end

def help(verbose)

# verbose is a flag (true or false) specifying whether verbose help or brief help is desired. Brief help is at most one line.

# return an Array of Strings describing the ImageConverter

end

def readImage(engine,imageArgs,imageInstance)

# engine is the Engine from the class library that is calling this ImageConverter. You should remember its reference so you

# can interact with the user interface.

# imageArgs is an Array of Strings. If one is present it is the filename of the image being read. If two are present the first

# argument is the path and the second argument is the filename of the image being read.

# imageInstance is the ImageInstance associated with the image to be read.

# The ImageConverter will need to call the ImageInstance’s makeNewImage() method before reading into any new image.

# The ImageConverter needs to set the imageInstance’s filename when reading the file. Use imageInstance.fileName=

end

def writeImage(engine,imageArgs,imageInstance)

# currently IAN does not use this functionality but requires a stub definition of it for future expansion

end

end

 

Your ImageConverter can have additional methods if desired. Your ImageConverter will automatically be available to both the command line version and the windowed version of IAN. Name your ImageConverter based upon the extension of files of that image type. For instance an ImageConverter designed to read PNG files should be defined in the file PNG.RB.

 

Adding a new unit type
 

Unit definitions are stored in units.dat, a file present in the directory where IAN is installed. That file describes how to add units to IAN.

 

IAN’s Class Library
 

Analysis

Documented above.

Array

See Ruby’s definition of Array for information on available methods, etc.

BinaryReader

new(file)

Creates a new BinaryReader on file. File must already be open and in binmode. See Ruby’s File help for more information.

readString(optionalLength)

Returns a string. If the optional length is given the string will be exactly that many characters wide. Otherwise the string read

is determined by the next NULL character (0x0) found.

readByte

Returns the next byte in the file as an Integer (range 0-255)

readInt16

Returns the next two bytes as a little endian Integer (range -32768-32767)

readUInt16

Returns the next two bytes as a little endian Integer (range 0-65535)

readInt32

Returns the next four bytes as a little endian Integer (range -2147483648-2147483647)

readUInt32

Returns the next four bytes as a little endian Integer (range 0-4294967295)

readFloat32

Returns the next four bytes as a Float from 32 bit IEEE format

readFloat64

Returns the next eight bytes as a Float from 64 bit IEEE format

BinaryWriter

new(file)

Creates a new BinaryWriter on file. File must already be open and in binmode. See Ruby’s File help for more information.

writeByte(int)

Write the passed in Integer (range 0-255) as a byte to the associated file

writeInt16(int)

Write the passed in Integer (range -32768-32767) as a little endian 2 byte signed integer to the associated file

writeUInt16(int)

Write the passed in Integer (range 0-65535) as a little endian 2 byte unsigned integer to the associated file

writeInt32(int)

Write the passed in Integer (range -2147483648-2147483647) as a little endian 4 byte signed integer to the associated file

writeUInt32(int)

Write the passed in Integer (range 0-4294967295) as a little endian 4 byte unsigned integer to the associated file

writeFloat32(float)

Write the passed in Float as an IEEE compliant 4 byte float to the associated file

writeFloat64(float)

Write the passed in Float as an IEEE compliant 8 byte float to the associated file

writeChars(string)

Write the characters in string to the associated file. Do not terminate with a NULL char (0x0).

writeCString(string)

Write the characters in string to the associated file. Terminate with a NULL char (0x0).

Engine

The Engine has three methods that are of interest to those extending IAN. They are statement(text), warning(text), and

error(text). Each takes a text String as input and updates the UI accordingly. Error(text) terminates current processing.

Float

This class is used to report AnalysisType::IMAGE metric output. See Ruby’s definition of Float for information on

available methods, etc.

Hash

This class is used to report AnalysisType::CLASS metric output. See Ruby’s definition of Hash for information on

available methods, etc.

ImageConverter

Documented above.

ImageFile

An ImageFile represents the actual pixel data of an ImageInstance. It has many methods for accessing the data in an

image. An ImageFile pixel is encoded in a 32 bit integer. The layout of bits in the integer differ based upon the number

of bits per pixel the image has.

Bit layouts

      Msb 00000000 Lsb (4 bits per digit)

      1 bit: 00000000 or 00000001

      4 bit: 00000000 through 0000000f

      8 bit: 00000000 through 000000ff

      16 bit: 00000000 through 0x0000ffff

      24 bit: 00rrggbb

specify(rows,cols)

      Initialize the ImageFile to have a rows x cols pixel image. Initially all zeroes.

rows

      Report the number of rows in the image.

cols

      Report the number of columns in the image.

getCell(x,y)

      Get the pixel associated with coordinate (x,y) where x = row and y = column. When accessing pixels its important to

      note that IAN stores images with the origin at the lower left corner.

setCell(x,y,value)

      Set the pixel associated with coordinate (x,y) where x = row and y = column to value. Care must be taken to encode

      the pixel correctly. See Bit Layouts above. When accessing pixels its important to note that IAN stores images with the

      origin at the lower left corner.

 classesPresent

      Returns a count of the number of classes present in the image

legend

      Returns a reference to a Hash that holds the mapping of pixel values to legend names.

palette

      Returns a reference to a Hash that holds the mapping of pixel values to 00rrggbb formatted pixels. Not present for all

      ImageFiles due to differing input file formats.

title

      Get the optional title (as a String) that is associated with the image

title=string

      Set the optional title associated with the image from the input String

each (code block that takes one parameter: |pixel|)

      Apply the passed in code block to each pixel in the image

each5(code block that takes five parameters: |center, north, south, east, west|)

      Apply the passed in code block to each four neighbor combination in the image. Note that some pixels do not have

      the full complement of neighbors (for instance, the upper left corner pixel does not have a northern or western neighbor).

      In such cases the neighbor value will be nil.

each9(code block that takes nine parameters: |ctr, nw, n, ne, w, e, sw,s,se|)

      Apply the passed in code block to each eight neighbor combination in the image. Note that some pixels do not have

      the full complement of neighbors (for instance, the upper left corner pixel does not have a northern, western, or

      northwestern neighbor). In such cases the neighbor value will be nil.

polyCount(eightNeighbors)

      Returns the count of all polygons in the image. eightNeighbors is a Boolean (true or false) specifying whether to consider

      4 neighbors per pixel or eight.

polyAreas(eightNeighbors)

      Returns an Array containing the cell count area of each polygon in the image. Entry zero of the Array does not contain

      meaningful information. eightNeighbors is a Boolean (true or false) specifying whether to consider 4 neighbors per pixel

      or eight.

polyPerims(eightNeighbors)

      Returns an Array containing the cell count perimeter of each polygon in the image. Entry zero of the Array does not

      contain meaningful information. eightNeighbors is a Boolean (true or false) specifying whether to consider 4 neighbors

      per pixel or eight.

polyClasses(eightNeighbors)

 Returns an Array containing the pixel value of each polygon in the image. Entry zero of the Array does not contain

      meaningful information. eightNeighbors is a Boolean (true or false) specifying whether to consider 4 neighbors

      per pixel or eight.

area

      Returns the total area of the image in pixel counts. This is simply rows*cols. Background is not accounted for.

perimeter

      Returns the total perimeter of the image. Does not simply sum the perimeters of each class as this would double count

      interclass perimeter. Rather it only counts each differing adjacency once.

areas

      Returns an Array containing the pixel counts of each class present. The Array is indexed by pixel value.

perimeters

      Returns an Array containing the pixel count perimeter of each class present. The Array is indexed by pixel value.

pIJ(eightNeigbors,background)

      Returns a SparseMatrix containing adjacency probabilities for the image. The pIJ probabilities are calculated to represent

      the probability that a random pixel equals class I times the probability that class J is adjacent to it. eightNeighbors is a

      Boolean (true or false) specifying whether to consider 4 neighbors per pixel or eight. Background is the pixel value of the

      background color. If no background is present in the image, -1 should be specified.

ImageInstance

imageConv

      Returns the ImageConverter used to load this image

file

      Returns the ImageFile associated with this instance. This is the primary way to access the pixel data and associated

      methods.

distUnit

      The Unit this image defines for distances. It may be nil.

areaUnit

      The Unit this image defines for areas. It may be nil.

bitsPerPix

      Returns the number of bits per pixel for the associated ImageFile. Should be 1, 4, 8, 16, or 24.

filename

      Returns a String with the filename of the ImageFile associated with this ImageInstance

makeNewImage(rows,cols,bitsPerPix,engine)

      This method should be called by any ImageConverter’s readImage() method when it creates an image. Rows and

      cols specify the dimensions of the map. bitsPerPix must be one of 1, 4, 8, 16, or 24 and represents the bits per

      pixel of the new image. engine is the Engine that interacts with the user interface.

Integer

This class used to report AnalysisType::IMAGE metric output. See Ruby’s definition of Integer for information on

available methods, etc.

Option

Documented above.

OptionList

 add(optionSummary)

      Add an OptionSummary to the list of Options

find(optionName)

      If optionName is found in the list this method returns the associated OptionSummary, otherwise it returns nil.

OptionSummary

new(abbrev,name,args)

      Create an OptionSummary. Abbrev is the short name of the Option (usually derived from its filename). For example,

      “N” for neighbors option (n.rb). name is the long name of the Option (i.e. “Neighborhood”) that will be used to

      search for it in OptionLists.

dig_to_i(digitString)

      Returns the integer specified by digitString. digitString can be binary (0b001), octal (0377), decimal (10), or

      hexadecimal (0xff).

value

      Returns the current value of the Option (as specified by the user)

OutputSummary

This is the class that must be created by Analyses. Each analysis returns an Array of these.

new(name,abbrev,type,data,unit,family,precision)

      Name is the textual description of the metric associated with this output (for instance, “Average Area”). Abbrev is a

      10 or fewer character String representing an abbreviated name for this output (for instance, “AveArea”). Spaces are

      not allowed in the abbreviation. Type specifies the kind of output this summary contains: AnalysisType::IMAGE

      (a measure that applies to the image as a whole, a Float or an Integer), AnalysisType::CLASS (a measure that applies

      to each class in the image, a Hash), or AnalysisType::INTERCLASS (a measure that applies to each combination of

      classes in the image, a SparseMatrix). Data is the actual measure (Float, Integer, Hash, SparseMatrix). Unit is either

      NoUnit for analyses that do not force units (but default to Image units) or a unit found in units.dat (like Units.find(“percent”)).

      Family specifies whether this is a “scalar”, “distance”, “area” or “compound” metric. Precision lets any

      ReportWriter know how many digits are significant for output.

name

      Returns a String containing the name of the metric.

outType

      Returns one of AnalysisType::IMAGE, AnalysisType::CLASS, or AnalysisType::INTERCLASS.

output

      Returns the actual measure (Float, Integer, Hash, SparseMatrix).

unit

      Return the overriding Unit of this metric. Usually NoUnit.

family

      Returns one of “scalar”, “distance”, “area”, “compound”

precision

      Returns an Integer specifying how many digits past the decimal are significant for output.

ReportWriter

Documented above.

SparseMatrix

This class is used to report AnalysisType::INTERCLASS metric output.

[](row,col)

Returns the matrix entry for (row,col). Returns nil if entry is not found. Row and col do not need to be numeric but

can be any object. For instance, sparseM[“feet”,”inches”] returns “6 foot 2”

[]=(row,col,value)

Sets the matrix entry for (row,col) to value. Returns nil if entry is not found. Row and col do not need to be numeric

but can be any object. For instance, sparseM[“feet”,”inches”] = “6 foot 2”

each(a code block taking one parameter: | entry |)

Applies the passed in code block to each entry in the SparseMatrix

each_coord(a code block taking two parameters: | row col |)

Applies the passed in code block to each (row,col) combination in the SparseMatrix

String

See Ruby’s definition of String for information on available methods, etc.

Unit

A class that represents real world units for the Analyses. Created in units.dat.

name

Name of this unit. Example: “millimeter”

pluralName

Plural name of this unit. Example: “millimeters”

abbrev

Abbreviation of this unit. Example: “mm”

baseUnit

Name of the unit that acts as a base unit for this unit. Example: “meters”

factor

The number of base units making up one of these units. Example: 0.001

family

One of “scalar”, “distance”, “area”.

 

 

Sharing your extension

 

If you have an extension you would like to share contact ian-mail@mailplus.wisc.edu. Your extension may be added to the latest IAN distribution.

 

Current extensions

 

Lacunarity analysis: simply click this link to download LCU.rb and place it in the analyses directory under your current IAN installation.


Analyses supported by IAN (as of October 7th, 2004)
Index
Area (A)
Aggregation Index (AI)
Adjacency Matrix (AM)
Angular Second Moment (ASM)
Core Area (CA)
Contagion (CO)
Dominance (DO)
Edge Density (ED)
Edge Distribution Evenness (EDE)
Electivity (EL)
Fractal Dimension – Box Counting method (FDB)
Fractal Dimension – Perimeter/Area method (FDP)
Inverse Difference Moment (IDM)
Largest Polygon Index (LPI)
Perimeter (P)
Perimeter/Area ratios (PA)
Perimeter/Area ratios – corrected (PAC)
Polygon Area Summary Statistics (PAS)
Polygon Perimeter Summary Statistics (PPS)
Relative Area (RA)
Relative Contagion (RCO)
Relative Dominance (RDO)
Shape Index Summary Statistics (SHP)
Shared Perimeter (SP)
Shannon-Weaver Diversity (SWD)
Shannon-Weaver Evenness (SWE)
Discussion
Area (A)
A reports the area of each class in the image


Aggregation Index (AI)
AI reports the aggregation indices upon an image. It is reported for the image as a whole as well as for each class present in the image.

An AI analysis reports values between zero and one. AI equals 1.0 when a class is completely aggregated into a single square patch. It reports numbers closer to 0.0 when each patch is narrow in one direction and long in another.

Definition: AI = total adjacent edges of class i with itself divided by the maximum possible adjacent edges of class i with itself.

Reference: He H. S., B. E. DeZonia and D. J. Mladenoff. 2000. An aggregation index (AI) to quantify spatial patterns on landscapes. Landscape Ecology 15: 591-601


Adjacency Matrix (AM)
AM reports the adjacency matrix probabilities between classes. Output values range between 0.00% and 100.00% and represent the proportional breakdown of neighbor cells. An AM value of 40% for class I to class J implies that it is 40% probable that a given cell on an image will be of class I and have class J adjacent to it.

Reference: Li H., and J.F. Reynolds. 1993. A new contagion index to quantify spatial patterns of landscape. Landscape Ecology 3:155-162.


Angular Second Moment (ASM)
ASM reports the angular second moment of the image. It is a measure of image texture. ASM ranges from 0.0 for an image with many classes and little clumping to 1.0 for an image with a single class (maximum clumping).

Note: This measure is derived from an adjacency matrix. In a paper in 1996 Riitters discusses how the method used to create the adjacency matrix can have a large impact upon resulting metrics. This can explain where IAN may differ from another package on this measure.

Definition: given an adjacency matrix between the classes present ASM = the sum of the squared adjacencies for all combinations of the classes present.


Core Area (CA)
CA reports the core area measures of the image. It is reported for each class present in the image. For a single pixel core area is defined as 1 cell if all of its neighbors are of the same class as the pixel. An 8 neighbor rule is used. The total cell count for each class is then scaled to the correct units.


Contagion (CO)
CO reports the contagion of the image. Contagion is a measure of the degree to which classes are clumped into polygons. It is estimated by determining the image’s departure from maximal diversity. Contagion returns a value greater than or equal to zero. Large values of contagion arise from images that are predominantly made up of a few classes. Small values of contagion arise from images that are made up of many different classes in approximately equal proportions.

Note: This measure is derived from an adjacency matrix. Different methods of computing adjacency exist. If IAN's measure departs from that of another package it may be due to differing methods of calculating adjacency.

Definition: given an adjacency matrix T between classes present contagion = maximum possible diversity - measured diversity. Maximum diversity is 2 * ln(classes present) and measured diversity is the sum of T(i,j) * ln(T(i,j)) for all combinations of classes i and j.

Reference: For more information see Li H., and J.F. Reynolds. 1993. A new contagion index to quantify spatial patterns of landscape. Landscape Ecology 3:155-162."


Dominance (DO)
DO reports the dominance measure of an image. Dominance is a measure of the degree to which an image departs from maximal diversity as defined by Shannon.

DO returns a value greater than or equal to zero. Large values of DO arise from images that are predominantly made up of a few classes. Small values of DO arise from images that are made up of many different classes in approximately equal proportions.

Definition: given a probability distribution p of the classes present, dominance = maximum possible diversity - measured diversity. Maximum diversity is defined as ln(classes present) and measured diversity is defined as -1 times the sum of p(i)*ln(p(i)) for all classes present.

Reference: For more information see Turner M.G. 1990. Spatial and temporal analysis of landscape patterns. Landscape Ecology 1:21-30


Edge Density (ED)
ED measures the edge density (edge length per unit area) of the image. It is reported for the image as a whole as well as for each class present in the image. ED is calculated as the total edge length divided by total image area for a given image or class.

Edge Distribution Evenness (EDE)
EDE reports the edge distribution evenness of the image. It is a measure of how equally distributed are the edge types of an image.

EDE can range from zero for an image with no edge other than border to 1.0 for an image whose edge types (connections between differing classes) are all equally present within the image.

Note: This measure uses an adjacency matrix. [Riitters 96] discusses how the method used to create the adjacency matrix can have a large impact upon resulting metrics.

Definition: (given t, an adjacency matrix between classes present)

First the main diagonal of the adjacency matrix is set to zero and the matrix is rescaled to sum to 1.0. Then:

EDE = measured diversity / maximum diversity

Measured diversity = -1 * the sum of all combinations of classes in the equation t(i,j) * ln(t(i,j). Maximum diversity is defined as 2 * ln (classes present).

Reference: For more information see [Riitters 96] and [Wickham 96]

[Riitters 96] - Riitters, O’Neill, et al. 1996. A note on contagion indices for landscape analysis. Landscape Ecology 11:197-202.

[Wickham 96] - Wickham J.D., K.H. Riitters, R.V. O’Neill, K.B. Jones, and T.G. Wade. 1996. Landscape ‘Contagion’ in Raster and Vector Environments. International Journal of Geographical Information Systems 7:891-89


Electivity (EL)
EL reports the electivity between classes present in the image. The electivity index calculated is equivalent to log Q as specified in the [Jacobs 74] paper (detailed below).

Electivity measures the strength of association between the classes. For the purposes of EL association is measured from the number of times two classes border on each other relative to the maximum coupling possible. EL results range from minus infinity for two classes that never neighbor each other to positive infinity for two classes that always neighbor each other.

Definition: EL = (Rij * (1-Pij)) / (Pij * (1-Rij)) where
Rij = x11 / (x11 + x21) and Pij = x12 / (x12 + x22) and:
x11 = couplings in which I and J participate
x12 = couplings in which I participates and J does not
x21 = couplings in which J participates and I does not
x22 = couplings in which neither I nor J participates
Note: only 4 neighbors are considered for couplings

Reference: For more information regarding this specific electivity index see [Mladenoff 93], [Pastor 90], and [Jacobs 74]. For more information regarding electivity indices in general see [Lechowicz 82]

[Jacobs 74] - Jacobs J. 1974. Quantitative Measurement of Food Selection. Oecologia 14:413-417

[Lechowicz 82] - Lechowicz M.J. 1982. The Sampling Characteristics of Electivity Indices. Oecologia 52:22-30

[Mladenoff 93] - Mladenoff D.J., M.A. White, J. Pastor, and T.R. Crow. 1993. Comparing spatial pattern in unaltered old-growth and disturbed forest landscapes. Ecological Applications 2:294-306

[Pastor 90] - Pastor J., and M. Broschart. 1990. The spatial pattern of a northern conifer-hardwood landscape. Landscape Ecology 1:55-68.


Fractal Dimension – Box Counting method (FDB)
FDB estimates the fractal dimension of the image using the box counting method. It is reported for each class present and for the image as a whole. FDB ranges from 1.0 for images made up of polygons whose outlines are very regular (or straight) to 2.0 for images made of polygons whose outlines are very irregular.

Limitations: For those images whose sample set is too small to accurately estimate fractal dimension IAN reports 0.

Definition: The calculation of FDB is the log-log regression of box size versus number of boxes required to cover the image.

Reference: For more information regarding the implementation of this fractal dimension method and regarding the use of fractal dimension estimates in landscape ecology see [Loehle 90], [Milne 91], and [Sugihara 90]. There are many techniques and much debate as to how to accurately measure fractal dimension. For more information regarding this topic refer to [Russ 94].

[Loehle 90] - Loehle C. 1990. Home range: A fractal approach. Landscape Ecology 1:39-52

[Milne 91] - Milne B.T. 1991. The utility of fractal geometry in landscape design. Landscape and Urban Planning 21:81-90

[Russ 94] - Russ, John C. 1994. Fractal Surfaces. Plenum Press. New York, New York, USA

[Sugihara 90] - Sugihara G., and R.M. May. 1990. Applications of Fractals in Ecology. TREE 3:79-86.


Fractal Dimension – Perimeter/Area method (FDP)
FDP estimates the fractal dimension of the image using the perimeter/area method as described in [Sugihari 90]. It is reported for the image as a whole as well as for each class present in the image. FDP ranges from 1.0 for images made up of polygons whose outlines are very regular (or straight) to 2.0 for images made of patches whose outlines are very irregular.

Definition: The calculation of FDP is twice the log-log regression of polygon perimeters versus polygon areas. Note that FRAGSTATS calculates this measure by regressing polygon areas versus polygon perimeters. Either method is defensible and neither is correct. This is because the linear regression model assumptions are typically violated when measuring fractal objects.

Reference: For more information regarding the implementation of this fractal dimension method and regarding the use of fractal dimension estimates in landscape ecology refer to [Sugihari 90]. There is much debate as to how to accurately measure fractal dimension. For more information regarding this topic refer to [Russ 94].

[Russ 94] - Russ, John C. 1994. Fractal Surfaces. Plenum Press. New York, New York, USA

[Sugihara 90] - Sugihara G., and R.M. May. 1990. Applications of Fractals in Ecology. TREE 3:79-86.


Inverse Difference Moment (IDM)
IDM reports the inverse difference moment of an image. It is a measure of image texture. IDM ranges from 0.0 for an image that is highly textured to 1.0 for an image that is untextured (such as an image with a single class).

Note: This measure uses an adjacency matrix. [Riitters 96] discusses how the method used to create the adjacency matrix can have a large impact upon resulting metrics.

Definition: given t, an adjacency matrix between the classes present:

IDM = sum of all combinations of classes of: (t(i,j)*t(i,j)) / (1 + (i-j)(i-j))

Limitations: Since IDM relies on the magnitude of differences between cell values it is only appropriate to compute it from interval data (as opposed to categorical data).

Reference: For more information see [Musick 91]

[Musick 91] - Musick, and Grover 1991. Image Textural Measures as Indices of Landscape Pattern, chapter in Quantitative Methods in Landscape Ecology, Turner and Gardner (1991). Springer-Verlag. New York, New York, USA.

[Riitters 96] - Riitters, O’Neill, et al. 1996. A note on contagion indices for landscape analysis. Landscape Ecology 11:197-202.


Largest Polygon Index (LPI)
LPI measures the percentage of area taken up by the largest polygon. It is reported for the image as a whole as well as for each class present in the image. LPI is calculated as the largest polygon size divided by the total area of the image. It is multiplied by 100 to represent a percentage.


Perimeter (P)
P reports the perimeter of each class and of the image as a whole.


Perimeter/Area ratios (PA)
PA reports the average perimeter to area ratio for all polygons present in the image. It is reported for the image as a whole as well as for each class present in the image.

PA is calculated by averaging the perimeter to area ratio for all polygons present. This provides a result that generally differs from dividing the total perimeter of the polygons by their total area.

Reference: For more information see Baker W.L., and Y. Cai. 1992. The r.le programs for multiscale analysis of landscape structure using the GRASS geographical information system. Landscape Ecology 7:291-302


Perimeter/Area ratios – corrected (PAC)
PAC reports the average corrected perimeter to area ratio for all polygons present in the image. It is reported for the image as a whole as well as for each class present in the image.

A corrected perimeter to area ratio is calculated by dividing the perimeter of a polygon by the square root of the product of 4 pi and the area of the polygon.

The average corrected perimeter to area ratio is calculated by averaging the corrected perimeter to area ratio for all polygons present. This provides a result that generally differs from dividing the total perimeter by the square root of 4 pi times the total area.

PAC results are always greater than or equal to 1. PAC equals 1.0 for polygons that are perfect circles, 1.1 for polygons that are perfect squares, and can be arbitrarily large for polygons that are extremely long and skinny.

Reference: For more information see Baker W.L., and Y. Cai. 1992. The r.le programs for multiscale analysis of landscape structure using the GRASS geographical information system. Landscape Ecology 7:291-302


Polygon Area Summary Statistics (PAS)
This analysis reports the following measures upon an image and its classes:

Total polygons
Mean polygon area
Standard Deviation of polygon area
Median polygon area
Interquartile range of polygon area
Area of smallest polygon
Area of largest polygon

Polygon Perimeter Summary Statistics (PPS)
This analysis reports the following measures upon an image and its classes:

Total polygons
Mean polygon perimeter
Standard Deviation of polygon perimeter
Median polygon perimeter
Interquartile range of polygon perimeter
Perimeter of smallest polygon
Perimeter of largest polygon

Relative Area (RA)
RA reports the relative proportion of each class within the image.


Relative Contagion (RCO)
RCO reports the relative contagion of the image. It is based upon Riitter's version of contagion (corrections made to Li's version). Contagion is a measure of the degree to which classes are clumped into polygons.

RCO reports relative contagion values. Therefore the possible values range from 0.0 for images with minimal contagion to 1.0 for images with maximum contagion.

Note: This measure uses an adjacency matrix. [Riitters 96] discusses how the method used to create the adjacency matrix can have a large impact upon resulting metrics.

Definition: (given t, an adjacency matrix between classes present)

RCO = 1.0 - (measured diversity / maximum diversity)

Measured diversity = -1 * the sum of all combinations of classes in the equation t(i,j) * ln(t(i,j). Maximum diversity is defined as 2 * ln (classes present).

Reference: For more information see [Riitters 96]

[Riitters 96] - Riitters, O’Neill, et al. 1996. A note on contagion indices for landscape analysis. Landscape Ecology 11:197-202.


Relative Dominance (RDO)
RDO reports the relative dominance measure of an image. Dominance is a measure of the degree to which an image departs from maximal diversity as defined by [Shannon 62].

RDO returns a value between 0.0 and 1.0 inclusive. Large values of RDO arise from images that are predominantly made up of a few classes. Small values of RDO arise from images that are made up of many different classes in approximately equal proportions.

Definition: (given p, a probability distribution of the classes present)

RDO = 1.0 - (measured diversity / maximum diversity)

where measured diversity = -1 * sum over all classes of p(i)*ln(p(i)) and maximum diveristy = ln(classes present).

Reference: For more information about dominance see [Turner 90]

[Shannon 62] - Shannon and Weaver. 1962. The mathematical theory of communication. University of Illinois Press. Urbana, Illinois, USA.

[Turner 90] - Turner M.G. 1990. Spatial and temporal analysis of landscape patterns. Landscape Ecology 1:21-30.


Shape Index Summary Statistics (SHP)
This metric calulates a statistical summary of the Shape Index upon the image. The summary includes mean, standard deviation, median, first quartile, third quartile, min, and max of the shape index of the polygons within the image.",

The Shape Index for a polygon is defined as (perimeter / minimum perimeter) where minimum possible perimeter is calculated in the following manner:

Find the edge length of the largest square smaller than the area of the polygon (n = floor(sqrt(area))). Let m be the difference between the area of the polygon and the area of sqr(n). Then the minimum perimeter equals
4n if m == 0
4n+2 if sqr(n) < area <= n(n+1)
4n+4 if area > n(n+1)

The Shape Index is always >= 1 and is unitless. Values close to 1 imply that the shape of the polygon is compact. Large values imply an irregular shape.

The Shape Index is scale independent. Polygons of the same shape but differing sizes will have the same shape index.


Shared Perimeter (SP)
SP reports the shared perimeter between classes. It reports perimeter for every 2 color combination of the classes present in the image.


Shannon-Weaver Diversity (SWD)
SWD reports the diversity of the image as described by [Shannon 62]. SWD results are always greater than or equal to zero. A low diversity measure implies an image is dominated by a single class. A high diversity measure implies an image that contains many classes in approximately equal proportions.

Definition: (given p, a probability distribution of the classes present)
SWD = -1 * sum over all classes of p(i)*ln(p(i))

Reference: For more information see [Turner 90]

[Shannon 62] - Shannon and Weaver. 1962. The mathematical theory of communication. University of Illinois Press. Urbana, Illinois, USA.

[Turner 90] - Turner M.G. 1990. Spatial and temporal analysis of landscape patterns. Landscape Ecology 1:21-30.


Shannon-Weaver Evenness (SWE)
SWE reports the relative diversity of the image where diversity is defined as described by [Shannon 62]. Relative diversity is computed as the measured diversity of the image divided by the maximum possible diversity for the image. SWE values range between 0 and 1 inclusive.

Definition: (given p, a probability distribution of the classes present), SWE = measured diversity / maximum diversity where measured diversity = -1 * sum over all classes of p(i)*ln(p(i)) and maximum diversity = ln(classes present).

[Shannon 62] - Shannon and Weaver. 1962. The mathematical theory of communication. University of Illinois Press. Urbana, Illinois, USA.
