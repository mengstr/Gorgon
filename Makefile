TARGET  = gorgon

PASMO	= pasmo6
PASMOFLAGS = --tapbas --listing gorgon.lst

EMU	= fuse
#EMUFLAGS= --late-timings --graphics-filter advmame2x --no-confirm-action
EMUFLAGS= --late-timings --graphics-filter 2x --no-confirm-action

INCLUDES = 	align.Z80 groundmapdata.Z80 key.Z80 \
			shipdata.Z80 fatfont.Z80 grounddata.Z80 \
			ground.Z80 score.Z80 ytable.Z80

.PHONY:	all run assets clean fullclean

all: clean $(TARGET).tap run

$(TARGET).tap: gorgon.Z80 $(INCLUDES)
	@$(PASMO) $(PASMOFLAGS) gorgon.Z80 $@

run:
	@$(EMU) $(EMUFLAGS) $(TARGET).tap 2> /dev/null

shipdata.Z80: assets/shipR.txt assets/shipL.txt
	@touch $@
	@rm $@
	@echo shipLutR DW shipR0,shipR1,shipR2,shipR3,shipR4,shipR5,shipR6,shipR7 >> $@
	@echo shipLutL DW shipL0,shipL1,shipL2,shipL3,shipL4,shipL5,shipL6,shipL7 >> $@
	@echo "" >> $@
	spriteMaker/spriter.sh assets/shipR.txt shipR reverse >> $@
	spriteMaker/spriter.sh assets/shipL.txt shipL reverse >> $@

fullclean: 	clean
	@touch shipdata.Z80
	@rm shipdata.Z80

clean:
	@rm -rf *.tap *.tmp *.bin *.lst *~

