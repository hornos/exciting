#!/bin/bash

for inp in $(find ./ -name \*.F90) ; do
  out="${inp%%F90}f90"
  if ! test -r "${out}" ; then
    mv -vf "${inp}" "${out}"
  fi
done

