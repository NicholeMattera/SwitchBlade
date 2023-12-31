ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

include $(DEVKITARM)/base_rules

APP_VERSION	:= 2.0.7
TARGET := switchblade
BUILD := build
BUILD_BINARY := build/bin
DIST := dist
SOURCEDIR := src
RESOURCEDIR := resources
OBJS = $(addprefix $(BUILD)/, \
	start.o \
	main.o \
	btn.o \
	clock.o \
	cluster.o \
	fuse.o \
	gpio.o \
	heap.o \
	hos.o \
	i2c.o \
	lz.o \
	max7762x.o \
	mc.o \
	nx_emmc.o \
	sdmmc.o \
	sdmmc_driver.o \
	sdram.o \
	sdram_lp0.o \
	util.o \
	di.o \
	gfx.o \
	pinmux.o \
	pkg1.o \
	pkg2.o \
	se.o \
	tsec.o \
	uart.o \
	ini.o \
	splash.o \
)
OBJS += $(addprefix $(BUILD)/, diskio.o ff.o ffunicode.o)

ARCH := -march=armv4t -mtune=arm7tdmi -mthumb -mthumb-interwork
CFLAGS = $(ARCH) -O2 -nostdlib -ffunction-sections -fdata-sections -fomit-frame-pointer -fno-inline -std=gnu11 -Wall -DVERSION=\"v$(APP_VERSION)\"
LDFLAGS = $(ARCH) -nostartfiles -lgcc -Wl,--nmagic,--gc-sections

.PHONY: all clean

all: $(BUILD)/$(TARGET).bin
	@[ -d $(BUILD) ] || mkdir -p $(BUILD)

dist: clean-dist
	@[ -d $(DIST) ] || mkdir -p $(DIST)
	@cp $(BUILD)/$(TARGET).bin $(DIST)
	@cp -R $(RESOURCEDIR)/sdfiles $(DIST)
	@cd $(DIST) && zip -r SwitchBlade-$(APP_VERSION).zip * >/dev/null
	@cd $(DIST)/sdfiles && zip -r ../sdfiles.zip * >/dev/null
	@rm -rf $(DIST)/sdfiles

clean: clean-dist
	@rm -rf $(OBJS)
	@rm -rf $(BUILD)

clean-dist:
	@rm -rf $(DIST)

$(BUILD)/$(TARGET).bin: $(BUILD)/$(TARGET).elf
	$(OBJCOPY) -S -O binary $< $@

$(BUILD)/$(TARGET).elf: $(OBJS)
	$(CC) $(LDFLAGS) -T $(SOURCEDIR)/link.ld $^ -o $@

$(BUILD)/%.o: $(SOURCEDIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/%.o: $(SOURCEDIR)/%.S
	@mkdir -p "$(BUILD)"
	$(CC) $(CFLAGS) -c $< -o $@
