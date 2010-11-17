SUFFIX=.f90

PLAT=linux

# compiler
FC=ifort
FCL=$(FC)
XP=xsltproc


#-----------------------------------------------------------------------
# possible options for CPP:
# XS
# ISO
# TETRA
# MPI
# MPIRHO
# MPISEC
#-----------------------------------------------------------------------

DEFS = -DXS -DISO -DTETRA

FFLAGS = -cpp $(DEFS) -O2 -unroll -scalar_rep

EXCLIB = ../exc.lib
LIB_ARPACK = $(EXCLIB)/ARPACK/arpack.$(PLAT).a \
             $(EXCLIB)/ARPACK/arpack.util.$(PLAT).a

LIB_LAPACK = $(EXCLIB)/LAPACK/lapack.$(PLAT).a
LIB_BLAS   = $(EXCLIB)/BLAS/blas.$(PLAT).a
LIB_FFT    = $(EXCLIB)/libfft/libfft.a
LIB_BZINT  = $(EXCLIB)/libbzint/libbzint.a
LIB_LEB    = $(EXCLIB)/libleb/libleb.a
LIB_FOX    = $(EXCLIB)/FoX/objs/lib/libFoX_dom.a \
             $(EXCLIB)/FoX/objs/lib/libFoX_wxml.a \
             $(EXCLIB)/FoX/objs/lib/libFoX_utils.a \
             $(EXCLIB)/FoX/objs/lib/libFoX_sax.a \
             $(EXCLIB)/FoX/objs/lib/libFoX_fsys.a \
             $(EXCLIB)/FoX/objs/lib/libFoX_common.a
LIB_XC     = $(EXCLIB)/LIBXC/src/.libs/libxc.a

INCLUDES = -I$(EXCLIB)/FoX/objs/finclude \
           -I$(EXCLIB)/LIBXC/src

LIBS = $(LIB_ARPACK) $(LIB_LAPACK) $(LIB_BLAS) \
       $(LIB_FFT) $(LIB_BZINT) $(LIB_LEB) \
       $(LIB_FOX) $(LIB_XC)

# SMP_LIBS=  $(LIB_ARP) $(LIB_FFT) $(LIB_BZINT) -L${MKLROOT}/lib/ia32 -lmkl_lapack95 -lmkl_blas95 \
# -lmkl_intel -lmkl_intel_thread -lmkl_core -liomp5 -lpthread -lm
# MPISMPF90_OPTS=$(SMPF90_OPTS)  -DMPI -DMPIRHO -DMPISECBUILDMPI=false
