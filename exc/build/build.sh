#!/bin/bash

verbose=false
clean=false
compile=false

while getopts vcm o; do
  case "$o" in
    v) verbose=true;;
    c) clean=true;;
    m) compile=true;;
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

  ./build/objdep.py
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
      make
    fi
  else
    if ${clean} ; then
      make clean  > ./${bin_name}.build.log
    fi

    if ${compile} ; then
      make >> ./${bin_name}.build.log
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

