

DL=wget -vc
TAR=tar

BLS_URL=http://www.netlib.org/blas
BLS_TGZ=blas.tgz

LAP_URL=http://www.netlib.org/lapack
LAP_TGZ=lapack.tgz

ARP_URL=ftp://ftp.caam.rice.edu/pub/software/ARPACK
ARP_TGZ=arpack96.tar.gz
ARP_P_TGZ=patch.tar.gz

LXC_URL=http://www.tddft.org/programs/octopus/down.php?file=libxc
LXC_TGZ=libxc-1.0.tar.gz


FC=ifort
FCL=$(FC)
FFLAGS=-O2

PLAT=linux

BLAS_LIB=BLAS/blas.$(PLAT).a


.PHONY: arpack clean blas lapack libfft fox libbzint libleb libxc all nolapack

all: blas lapack arpack fox libfft libbzint libxc libleb

nolapack: arpack fox libfft libbzint libxc libleb

blas:
	if ! test -d ./BLAS;then     \
	  if ! test -f $(BLS_TGZ);then \
	    $(DL) $(BLS_URL)/$(BLS_TGZ);fi; \
	  $(TAR) xvzf $(BLS_TGZ);fi
	cd ./BLAS; make FORTRAN=$(FC) LOADER=$(FCL) PLAT=.$(PLAT) OPTS=$(FFLAGS)

lapack:
	if ! test -d ./LAPACK;then   \
	  if ! test -f $(LAP_TGZ);then \
	    $(DL) $(LAP_URL)/$(LAP_TGZ);fi; \
	  $(TAR) xvzf $(LAP_TGZ);mv lapack-?.?.? LAPACK;fi
	cd ./LAPACK; cp make.inc.example make.inc
	cd ./LAPACK; make FORTRAN=$(FC) LOADER=$(FCL) PLAT=.$(PLAT) OPTS=$(FFLAGS) BLASLIB=../../../$(BLAS_LIB)

arpack:
	if ! test -d ./ARPACK;then     \
	  if ! test -f $(ARP_TGZ);then \
	    $(DL) $(ARP_URL)/$(ARP_TGZ);fi;   \
	  $(TAR) xvzf $(ARP_TGZ);        \
	  if ! test -f $(ARP_P_TGZ);then \
	    $(DL) $(ARP_URL)/$(ARP_P_TGZ);fi; \
	  $(TAR) xvzf $(ARP_TGZ);fi

	cd ./ARPACK; make lib home=. MAKE=make RANLIB=touch FC=$(FC) FFLAGS=$(FFLAGS) PLAT=$(PLAT)
	cd ./ARPACK; if test -f ./BLAS/libarpack_$(PLAT).a;then \
	mv ./BLAS/libarpack_$(PLAT).a ./arpack.blas.$(PLAT).a;fi

	cd ./ARPACK; if test -f ./LAPACK/libarpack_$(PLAT).a;then \
	mv ./LAPACK/libarpack_$(PLAT).a ./arpack.lapack.$(PLAT).a;fi

	cd ./ARPACK; if test -f ./SRC/libarpack_$(PLAT).a;then \
	mv ./SRC/libarpack_$(PLAT).a ./arpack.$(PLAT).a;fi

	cd ./ARPACK; if test -f ./UTIL/libarpack_$(PLAT).a;then \
	mv ./UTIL/libarpack_$(PLAT).a ./arpack.util.$(PLAT).a;fi

libxc:
	if ! test -d ./LIBXC;then     \
	  if ! test -f $(LXC_TGZ);then \
	    $(DL) $(LXC_URL)/$(LXC_TGZ);fi;   \
	  $(TAR) xvzf $(LXC_TGZ); \
	  mv libxc-?.? LIBXC;fi
	cd ./LIBXC; ./configure FC=$(FC) FCFLAGS=$(FFLAGS); make

libfft:
	cd ./libfft; make F90=$(FC) F90_OPTS=$(FFLAGS)

libbzint:
	cd ./libbzint; make F90=$(FC) F90_OPTS=$(FFLAGS)

libleb:
	cd ./libleb; make F90=$(FC) F90_OPTS=$(FFLAGS) F77=$(FC) F77_OPTS=$(FFLAGS)

fox:
	cd ./FoX; ./configure FC=$(FC) FCFLAGS=$(FFLAGS); make

clean:
	rm -fR ./BLAS
	rm -fR ./LAPACK
	rm -fR ./ARPACK
	rm -fR ./LIBXC
	rm *.tar.gz *.tgz
	cd ./libfft; make clean
	cd ./libbzint; make clean
	cd ./libleb; make clean
	cd ./FoX; make clean
