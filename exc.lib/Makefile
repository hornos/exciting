# TODO: from git fox libbzint
# TODO: parpack

FC=ifort
CC=icc
FCL=$(FC)
CCL=$(CC)

FFLAGS=-O2
CFLAGS=-O2

PLAT=linux

DL=wget -vc --no-check-certificate
TAR=tar

# Netlib Blas
BLS_URL=http://www.netlib.org/blas
BLS_TGZ=blas.tgz
BLAS_LIB=BLAS/blas.$(PLAT).a

# Netlib Lapack
LAP_URL=http://www.netlib.org/lapack
LAP_TGZ=lapack.tgz

# Arpack
ARP_URL=https://github.com/hpfem/arpack/tarball/master
ARP_TGZ=arpack.tgz

# libbzint
BZI_URL=https://github.com/ChristianMeisenbichler/libbzint/tarball/master
BZI_TGZ=libbzint.tgz

# LibXC
LXC_URL=http://www.tddft.org/programs/octopus/down.php?file=libxc
LXC_TGZ=libxc-1.0.tar.gz

# FoX
FOX_URL=https://github.com/ChristianMeisenbichler/fox/tarball/master
FOX_TGZ=fox.tgz


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
	    $(DL) -O $(ARP_TGZ) $(ARP_URL);fi;   \
	  $(TAR) xvzf $(ARP_TGZ);fi; \
	mv ./hpfem-arpack-* ./hpfem-arpack; \
	mv ./hpfem-arpack/ARPACK ./; \
	rm -Rf ./hpfem-arpack
	cd ./ARPACK; make lib home=. MAKE=make RANLIB=touch FC=$(FC) CC=$(CC) FFLAGS=$(FFLAGS) CFLAGS=$(CFLAGS) PLAT=$(PLAT)
	cd ./ARPACK; if test -f ./BLAS/libarpack.a;then \
	mv ./BLAS/libarpack.a ./arpack.blas.$(PLAT).a;fi
	cd ./ARPACK; if test -f ./LAPACK/libarpack.a;then \
	mv ./LAPACK/libarpack.a ./arpack.lapack.$(PLAT).a;fi
	cd ./ARPACK; if test -f ./SRC/libarpack.a;then \
	mv ./SRC/libarpack.a ./arpack.$(PLAT).a;fi
	cd ./ARPACK; if test -f ./UTIL/libarpack.a;then \
	mv ./UTIL/libarpack.a ./arpack.util.$(PLAT).a;fi

libbzint:
	if ! test -d ./libbzint;then \
	  if ! test -f $(BZI_TGZ);then \
	    $(DL) -O $(BZI_TGZ) $(BZI_URL);fi; \
	  $(TAR) xvzf $(BZI_TGZ); \
	  mv ./*-libbzint-* ./libbzint;fi;
	cd ./libbzint; mv Makefile Makefile.orig; \
	cat Makefile.orig | sed s/^include/#include/ > Makefile
	cd ./libbzint; make F90=$(FC) F90_OPTS=$(FFLAGS)

fox:
	if ! test -d ./FoX;then \
	  if ! test -f $(FOX_TGZ);then \
	    $(DL) -O $(FOX_TGZ) $(FOX_URL);fi; \
	  $(TAR) xvzf $(FOX_TGZ); \
	  mv ./*-fox-* ./FoX;fi;
	cd ./FoX; ./configure FC=$(FC) FCFLAGS=$(FFLAGS) CC=$(CC) CFLAGS=$(CFLAGS); make

libxc:
	if ! test -d ./LIBXC;then     \
	  if ! test -f $(LXC_TGZ);then \
	    $(DL) $(LXC_URL)/$(LXC_TGZ);fi;   \
	  $(TAR) xvzf $(LXC_TGZ); \
	  mv libxc-?.? LIBXC;fi
	cd ./LIBXC; ./configure FC=$(FC) FCFLAGS=$(FFLAGS); make

libfft:
	cd ./libfft; make F90=$(FC) F90_OPTS=$(FFLAGS)

libleb:
	cd ./libleb; make F90=$(FC) F90_OPTS=$(FFLAGS) F77=$(FC) F77_OPTS=$(FFLAGS)

clean:
	rm -fR ./BLAS
	rm -fR ./LAPACK
	rm -fR ./ARPACK
	rm -fR ./LIBXC
	rm -fR ./libbzint
	rm -fR ./FoX
	rm *.tar.gz *.tgz
	cd ./libfft; make clean
	cd ./libleb; make clean

