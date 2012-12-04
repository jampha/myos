AUTOOBJS= #
QEMU=qemu-system-i386
everything: mk1 mykern.bin
include Makefile.arch
.PHONY: all cemu emu kvm everything clean bx dep user x86 linux
all:clean everything
clean: clean1
x86:
	rm -f Makefile.arch
	ln -s Makefile.arch_x86 Makefile.arch
	rm -f arch
	ln -s arch_x86 arch
linux:
	rm -f Makefile.arch
	ln -s Makefile.arch_linux Makefile.arch
	rm -f arch
	ln -s arch_linux arch
kvm: everything
	$(QEMU) -enable-kvm -s -hda new.img -boot c -m 128 -localtime
emu: everything
	$(QEMU) -no-kvm -s -hda new.img -boot c -m 128 -localtime
cemu: everything
	$(QEMU) -no-kvm -s -hda new.img -boot c -m 128 -localtime -display curses
demu: everything
	$(QEMU) -no-kvm -S -s -hda new.img -boot c -m 128 -localtime &
	xterm gdb
bx: everything
	bochs -f new.bxrc
user:
	make -C libc
	make -C app
mktar:
	mkdir -p root
	mkdir -p root/bin
	mkdir -p root/share
	mkdir -p root/home
	cp app/*.bin root/bin
	cp app/w/*.bin root/bin
	cp app/mario/src/mario.bin root/bin
	rm -f initrd.tar{,.gz}
	cd root;tar cvf ../initrd.tar *;cd ..
	gzip -9 initrd.tar
mkimg: mktar mount_img domkimg umount_img
domkimg:
	sudo rm -f mnt/*.bin
	sudo rm -f mnt/boot/grub/menu.lst
	sudo cp mykern.bin mnt/
	sudo cp menu.lst mnt/boot/grub/menu.lst
	sudo cp initrd.tar.gz mnt/
mount_img:
	sudo mount `sudo losetup -o 32256 --find --show new.img` mnt
umount_img:
	sudo umount mnt
	sudo losetup -d /dev/loop0
dep: dep1

##dep
