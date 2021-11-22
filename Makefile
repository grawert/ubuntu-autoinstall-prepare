RAM = 1024
DISK_SIZE = 20G
BIOS_ROM = /usr/share/qemu/ovmf-x86_64-code.bin
ISO_IMAGE = ubuntu-20.04.3-live-server-amd64.iso
MOUNT_POINT = /mnt
KVM_COMMAND = qemu-kvm
DATA_SOURCE_URL = http://_gateway:8050/

.PHONY: help mount-iso umount-iso install boot clean

.DEFAULT_GOAL := help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

mount-iso: ## mount the iso image
	sudo mount -r $(ISO_IMAGE) $(MOUNT_POINT)

umount-iso: ## unmount the iso image
	sudo umount $(MOUNT_POINT)

disk0.raw: ## create disk0 image
	truncate -s $(DISK_SIZE) disk0.raw

disk1.raw: ## create disk1 image
	truncate -s $(DISK_SIZE) disk1.raw

nvme0.raw: ## create nvme0 image
	truncate -s $(DISK_SIZE) nvme0.raw

clean: ## erase disk images
	rm -f nvme0.raw disk0.raw disk1.raw

install: nvme0.raw disk0.raw disk1.raw ## install the system
	$(KVM_COMMAND) -no-reboot -m $(RAM) \
	  -bios $(BIOS_ROM) \
	  -cdrom $(ISO_IMAGE) \
	  -drive file=disk0.raw,format=raw,cache=none,if=virtio,id=d0 \
	  -drive file=disk1.raw,format=raw,cache=none,if=virtio,id=d1 \
	  -drive file=nvme0.raw,format=raw,cache=none,if=none,id=n1 \
	  -device nvme,drive=n1,serial=12345 \
	  -kernel $(MOUNT_POINT)/casper/vmlinuz \
	  -initrd $(MOUNT_POINT)/casper/initrd \
	  -append 'autoinstall ds=nocloud-net;s=$(DATA_SOURCE_URL)'

boot: ## boot the installed system
	$(KVM_COMMAND) -no-reboot -m $(RAM) \
	  -bios $(BIOS_ROM) \
	  -drive file=disk0.raw,format=raw,cache=none,if=virtio,id=d0 \
	  -drive file=disk1.raw,format=raw,cache=none,if=virtio,id=d1 \
	  -drive file=nvme0.raw,format=raw,cache=none,if=none,id=n1 \
	  -device nvme,drive=n1,serial=12345
