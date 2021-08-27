#!/bin/sh

echo ">>> Lauching MichalOS/2 with 4MB of RAM, an Adlib sound card and a 486 CPU..."
qemu-system-i386 -cpu 486 -m 4M -k en-us -soundhw sb16,adlib,pcspk -name "MichalOS" -fda disk_images/michalos.img -vga std -display sdl
exit
