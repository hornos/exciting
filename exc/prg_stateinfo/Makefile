include ../arch.make

.PHONY: all

PRG_EXE  = stateinfo 
PRG_OBJS = ../portstate.o ../ioarray.o ../mod_misc.o ../versions_gt.o

all: $(PRG_EXE)

$(PRG_EXE): ./main.F90 $(PRG_OBJS)
	$(FC) -c $(FFLAGS) $(INCLUDES) main.F90
	$(FC) $(LDFLAGS) -o $(PRG_EXE) main.o $(PRG_OBJS)

clean:
	rm -f *.o $(PRG_EXE)
