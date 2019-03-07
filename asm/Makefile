all: asm

%: %.tab.c %.yy.c %.tab.h
	gcc -o $@ $^ -lfl

%.tab.h %.tab.c: %.y
	bison -d $<

%.yy.c: %.l
	flex -o $@ $<

.PHONY: clean

clean:
	rm -f asm asm.tab.h asm.tab.c asm.yy.c

.SECONDARY:
