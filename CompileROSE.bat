@echo off
SETLOCAL
echo **********************************************
echo *****    EPKL COMPILER, using AHK2EXE    *****
echo **********************************************
echo.

REM *** SET YOUR PATH TO THE AHK COMPILER HERE
set resrc=Resources
set ahk=AHK-Compiler_v1-1
set exename=ROSElayout.exe

REM *** SHUT DOWN ANY RUNNING EPKL.exe AND SUBPROCESSES TO ALLOW OVERWRITING IT
echo * Stopping any running instances...
taskkill /F /IM %exename% /T
echo.

set binImg=Unicode 64-bit
echo * Compiling as %binImg%
set binImg=%resrc%\%ahk%\%binImg%.bin

echo * Compiling using MPRESS compression
set doComp=1

set iconParam=/icon "%resrc%\Main.ico"

REM *** THE ORIGINAL SCRIPT WAS DRAG-N-DROP
echo Compiling with %ahk%...
rem ahk2exe /in %1 /out "%~dpn1.exe" %iconParam% /bin "%binImg%.bin" /mpress %doComp%endlocal
%resrc%\%ahk%\ahk2exe /in "ROSE.ahk" /out "%exename%" %iconParam% /bin "%binImg%" /mpress %doComp%
echo.
echo * Done compiling!
echo Press any key to run %exename% or Ctrl+C to quit...
pause >nul
start %~dp0"%exename%"
ENDLOCAL
