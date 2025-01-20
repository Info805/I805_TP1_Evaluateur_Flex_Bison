LDFLAGS=

.PHONY: all clean
.PRECIOUS: %.tab.c %.yy.c %.tab.h

all: calc.exe

%.yy.c: %.l
	lex -o $@ $<

%.tab.c %.tab.h: %.y
	bison -d $<

%.c : symboltable.h
%.yy.o: %.yy.c %.tab.h
	cc -c -o $@ $<

%.exe: %.tab.o %.yy.o symboltable.o
	cc -o $@ $(LDFLAGS) $^

clean:
	rm -f *.exe *.o *.tab.* *.yy.c
