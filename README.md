
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
For a comprehensive summary of analyses go to http://landscape.forest.wisc.edu/projects/ian/analyses.htm
Image File Formats
ASC - IAN's (and APACK's) ASCII file format
This file format is documented at http://landscape.forest.wisc.edu/projects/ian/ascii.htm
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
Go to http://landscape.forest.wisc.edu/projects/ian/extend.htm to see instructions on how to extend IAN yourself
