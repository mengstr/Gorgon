TARGET  = gorgon

PASMO	= pasmo6
PASMOFLAGS = --tapbas

EMU	= fuse
EMUFLAGS= --verbose --graphics-filter advmame2x --no-confirm-action 
#EMUFLAGS= --verbose --graphics-filter 2x --no-confirm-action 

.PHONY:	all run assets clean 

all: clean $(TARGET).tap run

$(TARGET).tap: gorgon.Z80 grounddata.Z80 shipdata.Z80 ytable.Z80 score.Z80 fatfont.Z80
	@$(PASMO) $(PASMOFLAGS) gorgon.Z80 $@ 

run:
	@$(EMU) $(EMUFLAGS) $(TARGET).tap 2> /dev/null

shipdata.Z80: assets/shipR.txt assets/shipL.txt
	spriteMaker/spriter.sh assets/shipR.txt > shipdata.Z80
	spriteMaker/spriter.sh assets/shipL.txt >> shipdata.Z80


clean:
	@rm -rf *.tap *.tmp *.bin *.lst *~ 
	
	