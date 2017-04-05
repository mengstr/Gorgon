TARGET  = gorgon

PASMO	= pasmo6
PASMOFLAGS = --tapbas

EMU	= fuse
EMUFLAGS= --verbose --graphics-filter advmame2x --no-confirm-action 
#EMUFLAGS= --verbose --graphics-filter 2x --no-confirm-action 

.PHONY:	all run clean

all: clean $(TARGET).tap run

$(TARGET).tap: gorgon.Z80 ground.Z80 ytable.Z80
	@$(PASMO) $(PASMOFLAGS) gorgon.Z80 $@ 

run:
	@$(EMU) $(EMUFLAGS) $(TARGET).tap 2> /dev/null

clean:
	@rm -rf *.tap *.tmp *.bin *.lst *~ 
	
	