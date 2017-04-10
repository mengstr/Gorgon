TARGET  = gorgon

PASMO	= pasmo6
PASMOFLAGS = --tapbas --listing gorgon.lst

EMU	= fuse
#EMUFLAGS= --late-timings --graphics-filter advmame2x --no-confirm-action
EMUFLAGS= --late-timings --graphics-filter 2x --no-confirm-action

INCLUDES = \
	align.asm \
	key.asm \
	ground.asm \
	score.asm \
	ytable.asm \
	fatfont.asm \
	shipdata.inc \
	grounddata.inc \
	groundmapdata.inc \
	colors.inc

.PHONY : all run assets clean fullclean

all : clean $(TARGET).tap run

$(TARGET).tap : gorgon.asm $(INCLUDES)
	@echo "[assembling to .tap"]
	@$(PASMO) $(PASMOFLAGS) $< $@

run :
	@$(EMU) $(EMUFLAGS) $(TARGET).tap 2> /dev/null

shipdata.inc : assets/shipR.txt assets/shipL.txt
	@echo "[spriting ships]"
	@rm -f $@
	@echo shipLutR DW shipR0,shipR1,shipR2,shipR3,shipR4,shipR5,shipR6,shipR7 >> $@
	@echo shipLutL DW shipL0,shipL1,shipL2,shipL3,shipL4,shipL5,shipL6,shipL7 >> $@
	@echo "" >> $@
	@spriteMaker/spriter.sh assets/shipR.txt shipR reverse >> $@
	@spriteMaker/spriter.sh assets/shipL.txt shipL reverse >> $@

colors.inc :
	@echo "[creating colors]"
	@./createColorNames.sh > $@

grounddata.inc :
	@echo "[creating ground]"
	@createGround/process.sh assets/grounddata.txt > $@

groundmapdata.inc :
	@echo "[creating groundmap]"
	@createGround/makemap.sh assets/groundmapdata.txt GroundMap > $@

fullclean : clean
	@rm -f *.inc

clean :
	@rm -rf *.tap *.tmp *.bin *.lst
	@rm -f *~ */*~
	
