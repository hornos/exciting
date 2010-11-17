#!/usr/bin/python
#
# TODO: args
#

import os
import sys
import re
import string
import fileinput

# debug = True
debug = False

src_pat   = "src_.*"
root_path = "."
fex_arr  = [ "\.F(90)?$", "\.f(90)?$" ]

obj_db = {}
mod_db = {}


comp_cmd="$(FC) $(FFLAGS) $(INCLUDES)"

def brkstr( a, m = 5 ):
  r = ""
  c = 1
  l = len(a)
  for s in a:
    r += s+" "
    if c % m == 0 and l > m:
      r += "\\\n"
      c = 1
      l -= m - 1 
    # end if
    c += 1
  # end for
  return r
# end def

try:
  MF = open( "Makefile.objdep", "w" )
except:
  sys.exit(1)


print
print "Generate Object Dependencies"
print

for root, dirs, files in os.walk( root_path ):
  if debug:
    print
    print "DIR:",root

  if not ( root == "." or re.match( src_pat, os.path.basename( root ) ) ):
    continue

  for fn in files:
    fp   = os.path.join( root, fn )
    fbn  = os.path.basename( fn )
    fpa  = fp.split( "." )
    fpa[-1] = string.lower( fpa[-1] )
    fpl  = ".".join(fpa)

    for fex in fex_arr:
      if not re.match( ".*"+fex, fbn ):
        continue
      
      # build object database
      fon = re.sub( fex, ".o", fbn )
      if debug:
        print "%-32s : %s" % ( fon, fp )
        
      # search source
      tmp = []
      modules = []
      uses = []
      includes = []
      for line in fileinput.input( fp ):
        line = line.strip()

        # module
        pat = re.compile( "^MODULE +.*$", re.IGNORECASE )
        if re.match( pat, line ):
          tmp = line.split()
          if tmp[1] in modules:
            print "ERROR: MODULE",tmp[1]
          else:
            modules.append( tmp[1] )
            mod_db[tmp[1]] = fon
        # end if

        pat = re.compile( "^USE +.*$", re.IGNORECASE )
        if re.match( pat, line ):
          line = re.sub( ",.*$", "", line )
          tmp = line.split()
          if not tmp[1] in uses:
            uses.append( tmp[1] )
        # end if

        pat = re.compile( "^#?INCLUDE +.*$", re.IGNORECASE )
        if re.match( pat, line ):
          tmp = line.split()
          tmp[1] = re.sub( "\"", "", tmp[1] )
          if not tmp[1] in includes:
            includes.append( root+"/"+tmp[1] )
        # end if
      # end for line
      if debug:
        if modules:
          print "  MODULE :", modules
        if uses:
          print "  USE :", uses
        if includes:
          print "  INCLUDE :", includes
      # end if

      obj_db[fon] = { "path" : fpl, "opath" : fp, "module" : modules, "use" : uses, "include" : includes }

    # end for fex

  # end for fn

# end for os.walk


# build object dependencies
MF.write( "### OBJECTS ###\n" )

objs = []
srcs = []

for obj in obj_db:
  dep = []
  dep.append( obj_db[obj]["opath"] )

  objs.append( obj )
  srcs.append( obj_db[obj]["opath"] )

  # use
  for use in obj_db[obj]["use"]:
    if use in mod_db:
      dep.append( mod_db[use] )
  # end for

  # include
  for inc in obj_db[obj]["include"]:
    dep.append( inc )
  # end for

  dep_str = brkstr( dep )
  MF.write( obj + " : " + dep_str + "\n" )
  MF.write( "\t"+comp_cmd+" -c "+obj_db[obj]["opath"]+" -o "+obj+"\n" )
# end for

MF.write( "\n\n### MiSC ###\n" )
MF.write( "OBJS = " + brkstr( objs ) + "\n\n" )
MF.write( "SRCS = " + brkstr( srcs ) + "\n\n" )

MF.close()
