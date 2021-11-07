#!/bin/sh

#if test "`whoami`" != "root" ; then
#	echo "You must be logged in as root to build (for loopback mounting)"
#	echo "Enter 'su' or 'sudo bash' to switch to root"
#	exit
#fi

echo ">>> Creating new InpyoOS floppy image..."
rm disk_images/inpyoos.flp
mkdosfs -C disk_images/inpyoos.flp 1440 || exit

echo ">>> Assembling bootloader..."

nasm -O0 -w+orphan-labels -f bin -o source/bootload/bootload.bin source/bootload/bootload.asm || exit

echo ">>> Assembling InpyoOS kernel..."

cd source
nasm -O0 -w+orphan-labels -f bin -o inpyoos.sys system.asm || exit

echo ">>> Assembling InpyoOS 2nd-stage bootloader..."

nasm -O0 -w+orphan-labels -f bin -o boot.sys boot.asm || exit

cd ..

echo ">>> Assembling test documents..."

cd example_content

for i in *.mus
do
	nasm -O0 -w+orphan-labels -f bin $i -o `basename $i .mus`.mmf || exit
done

cd ../programs

echo ">>> Assembling programs..."

for i in *.asm
do
	nasm -O0 -w+orphan-labels -f bin $i -o ../programs-out/`basename $i .asm`.app || exit
done

cd ..

cd cprograms
# get folders in cprograms
for i in *
do 
	cd $i
	make || exit
	mv $i.app ../../programs-out/
	cd ..
done
cd ..

echo ">>> Adding bootloader to floppy image..."

dd status=noxfer conv=notrunc if=source/bootload/bootload.bin of=disk_images/inpyoos.flp || exit

echo ">>> Copying InpyoOS kernel, bootloader and programs..."

rm -rf tmp-loop

mkdir tmp-loop
mount -t vfat disk_images/inpyoos.flp tmp-loop

cp source/boot.sys tmp-loop/
cp source/inpyoos.sys tmp-loop/
cp programs-out/*.app programs/*.bas programs/*.dat tmp-loop/
cp example_content/*.asc example_content/*.pcx example_content/*.mmf example_content/*.dro example_content/*.rad tmp-loop/
cp source/sys/*.sys tmp-loop/

sleep 0.2

echo ">>> Unmounting loopback floppy..."

umount tmp-loop || exit

rm -rf tmp-loop

echo ">>> Creating CD-ROM ISO image..."

rm -f disk_images/inpyoos.iso
mkisofs -quiet -V 'MICHALOS' -input-charset iso8859-1 -o disk_images/inpyoos.iso -b inpyoos.flp disk_images/ || exit

echo ">>> Copying some stuff..."
cp disk_images/inpyoos.flp disk_images/inpyoos.img

chmod 777 disk_images/inpyoos.flp

./boot.bat

echo '>>> Done!'
