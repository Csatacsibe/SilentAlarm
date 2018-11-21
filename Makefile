###############################################################################
# Makefile for the project SilentAlarm
###############################################################################

## General Flags
PROJECT = SilentAlarm
MCU = atmega128
TARGET = SilentAlarm.elf
CC = avr-gcc

CPP = avr-g++

## Options common to compile, link and assembly rules
COMMON = -mmcu=$(MCU)

## Compile options common for all C compilation units.
CFLAGS = $(COMMON)
CFLAGS += -Wall -Wextra -gdwarf-2 -std=gnu99 -Os -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
CFLAGS += -MD -MP -MT $(*F).o -MF dep/$(@F).d 

## Assembly specific flags
ASMFLAGS = $(COMMON)
ASMFLAGS += $(CFLAGS)
ASMFLAGS += -x assembler-with-cpp -Wa,-gdwarf2

## Linker flags
LDFLAGS = $(COMMON)
LDFLAGS +=  -Wl,-Map=SilentAlarm.map


## Intel Hex file production flags
HEX_FLASH_FLAGS = -R .eeprom -R .fuse -R .lock -R .signature

HEX_EEPROM_FLAGS = -j .eeprom
HEX_EEPROM_FLAGS += --set-section-flags=.eeprom="alloc,load"
HEX_EEPROM_FLAGS += --change-section-lma .eeprom=0 --no-change-warnings


## Objects that must be built in order to link
OBJECTS = SA_Main.o LCD.o GSM.o board.o time.o alarm.o

## Objects explicitly added by the user
LINKONLYOBJECTS = 

## Build
all: $(TARGET) SilentAlarm.hex SilentAlarm.eep SilentAlarm.lss size

## Compile
SA_Main.o: SA_Main.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

LCD.o: LCD.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

GSM.o: GSM.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

board.o: board.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

time.o: time.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

alarm.o: alarm.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

##Link
$(TARGET): $(OBJECTS)
	 $(CC) $(LDFLAGS) $(OBJECTS) $(LINKONLYOBJECTS) $(LIBDIRS) $(LIBS) -o $(TARGET)

%.hex: $(TARGET)
	avr-objcopy -O ihex $(HEX_FLASH_FLAGS)  $< $@

%.eep: $(TARGET)
	-avr-objcopy $(HEX_EEPROM_FLAGS) -O ihex $< $@ || exit 0

%.lss: $(TARGET)
	avr-objdump -h -S $< > $@

size: ${TARGET}
	@echo
	@avr-size -C --mcu=${MCU} ${TARGET}

## Clean target
.PHONY: clean
clean:
	-rm -rf $(OBJECTS) SilentAlarm.elf dep/* SilentAlarm.hex SilentAlarm.eep SilentAlarm.lss SilentAlarm.map


## Other dependencies
-include $(shell mkdir dep 2>/dev/null) $(wildcard dep/*)

