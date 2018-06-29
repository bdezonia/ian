@echo off
set commline=ruby winui.rb
:getArg
if "%1"=="" goto end
set commline=%commline% %1
shift
goto getArg
:end
%commline%
set commline=
