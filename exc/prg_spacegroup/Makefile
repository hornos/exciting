include ../arch.make

.PHONY: all clean

PRG_EXE  = spacegroup

all: $(PRG_EXE)

EXCLIB=../../exc.lib
INCLUDES=-I$(EXCLIB)/FoX/objs/finclude -I..
include ./Makefile.objdep

PRG_OBJS = $(OBJS) ./sginputmodule.o ../modinputdom.o

$(PRG_EXE): $(PRG_OBJS)
	$(FC) $(LDFLAGS) -o $(PRG_EXE) $(PRG_OBJS) $(LIB_FOX)

sginputmodule.o : ./sginputmodule.f90
	$(FC) $(FFLAGS) $(INCLUDES) -c ./sginputmodule.f90 -o sginputmodule.o

./sginputmodule.f90: ../xml/schematofortran.xsl ../xml/excitinginput.xsd
	xsltproc --stringparam tool "spacegroup" ../xml/schematofortran.xsl ../xml/excitinginput.xsd > ./sginputmodule.f90

clean:
	rm -f *.o $(PRG_EXE) sginputmodule.f90
