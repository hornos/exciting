#-------------------------------------------------------------------------------
# Suffix rules
#-------------------------------------------------------------------------------
.SUFFIXES: .o .inc .f90 .F90 .h

#-------------------------------------------------------------------------------
# Common make
#-------------------------------------------------------------------------------
include arch.make

#-------------------------------------------------------------------------------
# Top level targets
#-------------------------------------------------------------------------------
.PHONY: clean all exciting objdep inputdoc

all: exciting

#-------------------------------------------------------------------------------
# Source files
#-------------------------------------------------------------------------------
include Makefile.objdep

#-------------------------------------------------------------------------------
# Special rules
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Generated files
#-------------------------------------------------------------------------------
GFS = ./src_inputparser/inputmodules.f90 ./src_inputparser/speciesmodules.f90 ./version.inc

./src_inputparser/inputmodules.f90: ./xml/excitinginput.xsd ./xml/schematofortran.xsl
	$(XP) ./xml/schematofortran.xsl ./xml/excitinginput.xsd > ./src_inputparser/inputmodules.f90

./src_inputparser/speciesmodules.f90: ./xml/species.xsd ./xml/schematofortran.xsl
	$(XP) ./xml/schematofortran.xsl ./xml/species.xsd > ./src_inputparser/speciesmodules.f90

./version.inc:
	perl ./build/vstamp.pl

exciting: $(OBJS)
	rm -f exciting
	$(FCL) $(LDFLAGS) -o exciting $(OBJS) $(LIBS)

clean:
	rm -f exciting
	rm -f *.o *.mod
	rm -f $(GFS)
	rm -f ./doc/*

objdep: $(GFS)
	./build/objdep.py

inputdoc:
	cd doc; \
	xsltproc --stringparam importancelevels "essential expert" \
	../xml/schematolatex.xsl ../xml/excitinginput.xsd > excitinginput.tex; \
	pdflatex excitinginput.tex; pdflatex excitinginput.tex
