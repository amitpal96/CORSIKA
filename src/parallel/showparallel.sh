#!/bin/bash
#
# showparallel.sh:
# ================
# create the tabular of available parallel corsika simulations:
# ------------------------------------------------------------------------
# gfortran -O0 -fbounds-check showparallel.f -o showparallel
# ifort -C -O0 -check bounds showparallel.f -o showparallel
# ------------------------------------------------------------------------
# Primary   lg(E)  theta    phi  runtsk  sizeGBy  procs
#         T(days)  ecutmax  t(min)  files  RATIO  obslev
#                  Xmagn  Zmagn  _corsika_executable_
#   or:            Antns  gamma  _corsika_executable_
# names of subdirectories are csk??????;
# job protocol files are Job??????_%jobid.err, Job??????_%jobid.out;
# ------------------------------------------------------------------------
# usage: ./showparallel.sh
# ------------------------------------------------------------------------
#                                       juergen.oehlschlaeger@kit.edu
# ------------------------------------------------------------------------
# 
# - - - - compile and link fortran code considering the login node:
if [ -e "showparallel.f" ] ; then
  if [ `echo $HOSTNAME | cut -b 1-4` == "iklx" ] ; then
    gfortran -O0 -fbounds-check showparallel.f -o showparallel
  elif [ `echo $HOSTNAME | cut -b 1-4` == "uc1n" ] ; then
    ifort -C -O0 -check bounds showparallel.f -o showparallel
  elif [ `echo $HOSTNAME | cut -b 1-4` == "fh1n" ] ; then
    ifort -C -O0 -check bounds showparallel.f -o showparallel
  fi
else
  echo "          ----- missing source file 'showparallel.f'!"
  exit 1
fi
# - - - - display all available simulations including coreas runs:
ls -1 csk??????/Job*.out > showparallel.jobinfos
./showparallel < showparallel.jobinfos > showparallel.au2-corsika-trunk-jobinfos
#
exit
#
