echo off
cls

echo Creating new MichalOS floppy image...
cd disk_images
del michalos.*
fsutil file createnew michalos.flp 1474560
cd ..

echo Assembling bootloader...
cd source\bootload
..\..\windows_tools\nasm.exe -O0 -f bin -o bootload.bin bootload.asm
cd ..

echo Assembling MichalOS kernel...
..\windows_tools\nasm.exe -O0 -f bin -o michalos.sys system.asm

echo Assembling MichalOS 2nd-stage bootloader...
..\windows_tools\nasm.exe -O0 -f bin -o boot.sys boot.asm

echo Assembling test documents...
cd ..\example_content
for %%i in (*.mmf) do del %%i
for %%i in (*.mus) do ..\windows_tools\nasm.exe -O0 -fbin %%i -o %%~ni.mmf
cd ..

echo Assembling programs...
cd programs
for %%i in (*.app) do del %%i
for %%i in (*.asm) do ..\windows_tools\nasm.exe -O0 -fbin %%i -o %%~ni.app
cd ..

echo Adding bootloader to disk image...
cd disk_images
..\windows_tools\partcopy.exe ..\source\bootload\bootload.bin 0 512 michalos.flp
cd ..

echo Mounting disk image...
imdisk -a -f disk_images\michalos.flp -s 1440K -m E:

echo Copying kernel and applications to disk image...
copy source\boot.sys E:\
copy source\michalos.sys E:\
copy source\sys\*.sys E:\
copy programs\*.app E:\
copy programs\*.bas E:\
copy programs\*.dat E:\
copy example_content\*.mmf E:\
copy example_content\*.pcx E:\
copy example_content\*.rad E:\
copy example_content\*.dro E:\
copy example_content\*.asc E:\

cd disk_images
copy michalos.flp michalos.img
cd ..

echo Unmounting disk image...
imdisk -D -m E:

boot.bat

echo Done!

pause
