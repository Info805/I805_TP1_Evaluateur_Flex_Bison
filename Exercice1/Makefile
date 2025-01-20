LDFLAGS=

.PHONY: all clean
.PRECIOUS: %.tab.c %.yy.c %.tab.h

all: calc.exe

%.yy.c: %.l
	lex -o $@ $<

%.tab.c %.tab.h: %.y
	bison -d $<

%.yy.o: %.yy.c %.tab.h
	cc -c -o $@ $<

%.exe: %.tab.o %.yy.o
	cc -o $@ $(LDFLAGS) $^

clean:
	rm -f *.exe *.o *.tab.* *.yy.c
