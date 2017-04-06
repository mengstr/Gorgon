TARGET  = gorgon

PASMO	= pasmo6
PASMOFLAGS = --tapbas

EMU	= fuse
EMUFLAGS= --late-timings --graphics-filter advmame2x --no-confirm-action 

.PHONY:	all run assets clean 

all: clean $(TARGET).tap run

$(TARGET).tap: gorgon.Z80 grounddata.Z80 shipdata.Z80 ytable.Z80 score.Z80 fatfont.Z80 ground.Z80
	@$(PASMO) $(PASMOFLAGS) --listing gorgon.lst gorgon.Z80 $@ 

run:
	@$(EMU) $(EMUFLAGS) $(TARGET).tap 2> /dev/null

shipdata.Z80: assets/shipR.txt assets/shipL.txt
	touch $@
	rm $@
	echo shipLutL DW shipL1,shipL2,shipL3,shipL4,shipL5,shipL6,shipL7 >> $@
	echo shipLutR DW shipR1,shipR2,shipR3,shipR4,shipR5,shipR6,shipR7 >> $@
	echo "" >> $@
	spriteMaker/spriter.sh assets/shipR.txt >> $@
	spriteMaker/spriter.sh assets/shipL.txt >> $@


clean:
	@rm -rf *.tap *.tmp *.bin *.lst *~ 
	