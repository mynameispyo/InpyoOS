InpyoOS
********

https://www.youtube.com/watch?v=Q5CfhwSJ7QQ

A 32-bit operating system based on MichalOS,
aimed to make it more advanced on the inside,
but simple and easy to use on the outside.

Special thanks to:
	- Michael Saunders (and all the MikeOS developers)

System requirements:
	- Intel 80386 or higher
	- At least 128kB RAM, 192kB recommended
	- A VGA card (EGA currently doesn't work)
	- A keyboard

Building the OS
***************

Linux:
	- Required packages: "nasm", "dosfstools", "qemu"
	- To build: open the terminal, navigate to the directory that contains InpyoOS and type:
		sudo ./build-linux
	- If you prefer a cleaner InpyoOS build (without example images and "music"), type:
		sudo ./build-linux-clean
	(note: both of the commands listed above will ask for your password)
	- If you just want to boot the image without rebuilding, type:
		./boot.sh
