TARGET = zx7

.PHONY : all clean

all: $(TARGET)

$(TARGET) : zx7.c optimize.c compress.c
	@echo "[compiling zx7]"
	@$(CC) -Wall -O2 -o $@ $^ 
 	
clean: 
	@rm -f $(TARGET) *~
