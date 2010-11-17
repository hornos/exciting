#-------------------------------------------------------------------------------
# Suffix rules
#-------------------------------------------------------------------------------
.SUFFIXES: .o .inc .f90 .F90 .h


#-------------------------------------------------------------------------------
# Source files
#-------------------------------------------------------------------------------
include arch.make

all: exciting

include Makefile.objdep

exciting: $(OBJS)
	rm -f exciting
	perl ./build/vstamp.pl
	$(FCL) $(LDFLAGS) -o exciting $(OBJS) $(LIBS)

clean:
	rm -f exciting
	rm -f *.o *.mod

objdep:
	./build/objdep.py

.PHONY: clean all exciting objdep
