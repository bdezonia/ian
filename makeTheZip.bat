REM echo Clearing out staging area.

rd stagingArea /s

echo Making staging area.

md stagingArea

echo Copying files to staging area.

xcopy /y /i *.rb stagingArea
xcopy /y /i *.rbw stagingArea
xcopy /y /i *.dat stagingArea
xcopy /y /i *.so stagingArea
xcopy /y /i *.bmp stagingArea
xcopy /y /i *.png stagingArea
xcopy /y /i options\*.rb stagingArea\options
xcopy /y /i analyses\*.rb stagingArea\analyses
xcopy /y /i imagetypes\*.rb stagingArea\imagetypes
xcopy /y /i reports\*.rb stagingArea\reports
      
echo Now you must use Windows Explorer to make Ian.zip from stagingArea.
