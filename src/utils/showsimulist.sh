#!/bin/bash
#
# showsimulist.sh:
# ================
#     creates tabular of air shower simulations done with corsika
#     by reading only the first record of all particle data files
#     [DAT,CER]iiiiii[.cher,.part] and possibly additional reading of
#     the corresponding protocol file as 'DATiiiiii.lst'; otherwise
#     additional conditions must be added to the code; a tabular of one
#     line per file will be created with the following quantities: 
# Primary, lg(E), theta, phi, nsh,  runnr, size, obslvme, h1stme,
# thilev, thiwmax, lg(thirad), verspgm, models, rundate, Xmagn, Zmagn;
#     Cherenkov data will be identified by `_ce` after the primary code.
# ------------------------------------------------------------------------
# RunProg:
#     ls -l DAT?????? | ./showsimulist > showsimulist.ca2-showtest
#     ls -l DAT??????.part | ./showsimulist
#     ls -l DAT?????? DAT??????.part | ./showsimulist
#     ls -l DAT?????? DAT??????.???? | grep -v l | ./showsimulist
#     ls -l DAT??????.cher | ./showsimulist
#     ls -l CER?????? | ./showsimulist > showsimulist.ca2-cherenkov
# using file names in text file:
#     ./showsimulist < showsimulist.datnames
# using 'simprod' simulations:
#     ls -l [c,f,p]?e??m???_* | ./showsimulist
# ------------------------------------------------------------------------
#         Primary   lg(E)  theta    phi  nsh  runnr   sizeM  obslvme  h1stme   .....
# Iron       5626   16.00    0.0    0.0   1  199079     3.9  1413.82   18350.  .....
# _stck_in_     4   15.09    0.0    0.0   1  169051     2.4   194.00   18765.  .....
# Fluorine   1909   16.00    0.0    0.0   1  199070     3.9  1416.51   22222.  .....
# proton       14   16.00   30.0   -3.3   1  199080     3.4  1429.25   22224.  .....
# Manganese  5525   16.00   30.0   -3.3   1  199082    10.1  1428.13   22222.  .....
# proton _ce   14   17.50   37.9 -138.0   1  000044    90.8  -500.00  -24880.  .....
# ------------------------------------------------------------------------
#                                       juergen.oehlschlaeger@kit.edu
# ------------------------------------------------------------------------
# ..../corsika.trunk/run/ or ..../corsika-run/
#
# - - - - compile and link fortran code considering the login node:
if [ -e "showsimulist.f" ] ; then
  if [ `echo $HOSTNAME | cut -b 1-4` == "iklx" ] ; then
    gfortran -O0 -fbounds-check showsimulist.f -o showsimulist
  elif [ `echo $HOSTNAME | cut -b 1-4` == "uc1n" ] ; then
    ifort -C -O0 -check bounds showsimulist.f -o showsimulist
  elif [ `echo $HOSTNAME | cut -b 1-4` == "fh1n" ] ; then
    ifort -C -O0 -check bounds showsimulist.f -o showsimulist
  fi
else
  echo "          ----- missing source file 'showsimulist.f'!"
  # - - - - - may be copied from ../src/showsimulist.f;
  exit 1
fi
# - - - - create tabular of simulations:
ls -l DAT?????? | ./showsimulist > showsimulist.au2-corsika-simulist
#
exit
