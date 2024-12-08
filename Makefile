arch ?= x86_64
kernel := build/kernel-$(arch).bin
iso := build/os-$(arch).iso
target ?= $(arch)-blog_os

c_source_files := $(shell find src/kernel -name '*.c')
c_object_files := $(patsubst src/kernel/%.c, build/kernel/%.o, $(c_source_files))

linker_script := src/boot/$(arch)/linker.ld
grub_cfg := src/boot/$(arch)/grub.cfg
assembly_source_files := $(wildcard src/boot/$(arch)/*.asm)
assembly_object_files := $(patsubst src/boot/$(arch)/%.asm, \
	build/boot/$(arch)/%.o, $(assembly_source_files))
CC ?= gcc

.PHONY: all clean run iso kernel

all: $(kernel)

full: clean all run

clean:
	@rm -r build

run: $(iso)
	@qemu-system-x86_64 -cdrom $(iso)

iso: $(iso)

$(iso): $(kernel) $(grub_cfg)
	@mkdir -p build/isofiles/boot/grub
	@cp $(kernel) build/isofiles/boot/kernel.bin
	@cp $(grub_cfg) build/isofiles/boot/grub
	@grub-mkrescue -o $(iso) build/isofiles 2> /dev/null
	@rm -r build/isofiles

$(kernel): $(c_object_files) $(assembly_object_files) $(linker_script)
	@ld -n --gc-sections -T $(linker_script) -o $(kernel) $(c_object_files) $(assembly_object_files)


$(c_object_files): build/kernel/%.o: src/kernel/%.c
	@mkdir -p $(shell dirname $@)
	@gcc -c -o $@ $<

# compile assembly files
build/boot/$(arch)/%.o: src/boot/$(arch)/%.asm
	@mkdir -p $(shell dirname $@)
	@nasm -felf64 $< -o $@