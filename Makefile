ASM = nasm
ASMFLAGS = -f elf64
LD = ld

TARGET = gen
OBJS = perlin.o main.o

all: $(TARGET)
	@echo "ok"

$(TARGET): $(OBJS)
	$(LD) -o $(TARGET) $(OBJS)

perlin.o: perlin.asm
	$(ASM) $(ASMFLAGS) perlin.asm

main.o: main.asm
	$(ASM) $(ASMFLAGS) main.asm

clean:
	rm -f $(OBJS) $(TARGET) *.ppm *.png

run: $(TARGET)
	./$(TARGET)

test: run
	@if command -v convert > /dev/null; then \
		convert grass.ppm grass.png 2>/dev/null; \
		convert water.ppm water.png 2>/dev/null; \
		convert lava.ppm lava.png 2>/dev/null; \
		echo "ppm > png"; \
	fi

.PHONY: all clean run test
