#!/bin/bash

# TODO: get exe name from makefile

verbose=false
clean=false
compile=false
objdep=false

while getopts vcmd o; do
  case "$o" in
    v) verbose=true;;
    c) clean=true;;
    m) compile=true;;
    d) objdep=true;;
  esac
done

cd ..

actions=""
if ${clean} ; then
  actions="CLEAN"
fi
if ${compile} ; then
  if test -n "${actions}" ; then
    actions="${actions} "
  fi
  actions="${actions}COMPILE"
fi

for am in ./build/*.arch.make ; do
  bin_name=${am%%.arch.make}
  ln -sf ${am} ./arch.make
#  cp ${am} ./arch.make

  echo
  echo "[$actions] ${bin_name}"

  if ${verbose} ; then
    if ${clean} ; then
      make clean
    fi

    if ${compile} ; then
      if ${objdep} ; then
        make objdep
      fi
      make
    fi
  else
    if ${clean} ; then
      make clean  > ./${bin_name}.build.log
    fi

    if ${compile} ; then
      if ${objdep} ; then
        make objdep > ./${bin_name}.build.log
      fi
      make         >> ./${bin_name}.build.log
    fi
  fi

  if ${compile} ; then
    if test -x ./exciting ; then
      mv -f ./exciting ${bin_name}
    else
      echo "Error compiling ${bin_name}"
    fi
  fi
done
echo
