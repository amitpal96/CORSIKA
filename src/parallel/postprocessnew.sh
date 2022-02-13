#!/bin/bash
#
# postprocessnew.sh:
# ==================
# new postprocessing of parallel corsika simulations on the bwunicluster
# or forhlr1 after September 2016, and is also valid for parallel coreas
# radio simulations; DAT*.long files are automatically summed to
# DAT......-999989999.long; no DAT*-*-*.lst files are written during
# the simulation, exept in 'mpi-internal debug mode' named by the
# additional argument 'T' in the 'mpirun' command, which must look like:
# mpirun ./mpi_corsika77100_mthi_QGSII4_gheiatm_runner parallel-010858 T
# ------------------------------------------------------------------------
#   (p0) being in 'parallel' path csk??????/, MPI job protocol file(s)
#        must exist in the upper (i.e. the corsika submit) directory; 
#        names of the original MPI protocol files are 
#        job_uc1_jobwcl-??????_%jnumbid.err (length 0) and
#        job_uc1_jobwcl-??????_%jnumbid.out (upto few 100 kB);
#   (p1) steering job...-?????? and parallel-?????? must exist 
#        in this path 'parallel' path csk??????/.
#   (p2) file 'time.txt' must exist and contain two lines like
#       START TIME          STOP TIME       TIME (min)
#   1566262084.316990   1456263487.694263    23.389621
#   (p3) script `postprocessnew.sh` must exist in this path.
#   (p4) script `summ` and the fortran source code 'summe.f' must
#        exist in this path.
#   (p5) fortran source code 'totaltimenew.f' must exist in this path;
#        then run script 'postprocessnew.sh' without arguments.
#   (p6) names of the new created protocol files are
#        Job??????_%jnumbid.[err,out] and time.txt??????;
# ------------------------------------------------------------------------
# usage: ./postprocessnew.sh 
# ------------------------------------------------------------------------
#                                       juergen.oehlschlaeger@kit.edu
# ------------------------------------------------------------------------
rm -f *.scratch*
computype="ikp"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - get run number from current directory name:
pwd > jobfileerr.tmp
sed -i "/csk/ s/csk/   /" jobfileerr.tmp
jrunnr=`cat jobfileerr.tmp | awk '{printf("%06d\n",$2)}'`
if [ `echo $HOSTNAME | cut -b 1-4` == "uc1n" ] ; then
  computype="bwc"
else
  if [ `echo $HOSTNAME | cut -b 1-4` == "fh1n" ] ; then
    computype="fh1"
  else
    if [ `cut -b 2-5 jobfileerr.tmp` == "univ" ] ; then
      computype="stu"
    fi
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - test on existence of file time.txt:
rm jobfileerr.tmp
if [ ! -e time.txt ] ; then
  echo "           ... postprocessing cannot be executed, because 'time.txt' is missing"
  echo "           ...... not available or postprocessing already done for runnr $jrunnr"
  echo "           ...... or last line of 'job*_%j.out' is missing:"
  echo "           ...... Parallel Task #... SUCCESSFULLY FINALIZED (at bwcluster)"
  echo "           ...... Job 163862 completed at 01.11.2017/09:45:51 (COMPLETED)"
  exit
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - test on syntax of 'timetable' files:
if [ -e corsika_timetable-000001 ] ; then
  # have newer names of 'timetable' files:
  chtitle=`head -1 corsika_timetable-000001 | awk '{printf("%s\n",$1)}'` 
  if [ "$chtitle" == "#Columns" ] ; then
    # 'timetable' files with shell comment as first line:
    echo "               ... corsika 'timetable' files contain a comment line."
    listfiles="corsika_timetable-*"
    rm -f jobfiletimes.tmp
    touch jobfiletimes.tmp 
    for filename in $( ls -1 $listfiles ) ; do
      jlines=`wc $filename | awk '{ printf("%s",$1) }'`
      let "jlines = $jlines - 1"
      if [ $jlines -gt 0 ] ; then
        tail -$jlines $filename >> jobfiletimes.tmp
      fi
    done
    mv jobfiletimes.tmp corsika_timetable
  else 
    # 'timetable' files without comments as first line:
    cat corsika_timetable-* > corsika_timetable
  fi
else
  if [ -e "corsika_timetable-1" ] ; then
    # use old names of 'timetable' files:
    cat corsika_timetable-* > corsika_timetable
  fi
fi
jdatnames=`wc "corsika_timetable" | awk '{ printf("%s",$1) }'`
let "jdatnames = $jdatnames / 2" 
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - check on already available jobfiles:
if [ $computype == "bwc" ] ; then
  jobrunnr=`echo $jrunnr | awk '{printf("job_uc1_jobwcl-%06d_*",$1)}'`
else
  if [ $computype == "fh1" ] ; then
    jobrunnr=`echo $jrunnr | awk '{printf("jobfh1-%06d_*",$1)}'`
  else
    if [ $computype == "stu" ] ; then
      jobrunnr=`echo $jrunnr | awk '{printf("jobpll-%06d.[e,o]*",$1)}'`
    fi
  fi
fi
# - - - - - - njobfiles must be 2:
njobfiles=`ls -l $jobrunnr 2> jobfileerr.tmp | wc | awk '{printf("%7d\n",$1)}'`
rm jobfileerr.tmp
if [ $njobfiles -eq 2 ] ; then
  echo "               ... jobfiles $jobrunnr already available in this path."
else
  if [ $njobfiles -eq 1 ] ; then
    if [ $computype == "fh1" ] ; then
      echo "               ... file $jobrunnr already available in this path."
    else
      if [ $computype == "bwc" ] ; then
        echo "               ... file $jobrunnr already available in this path."
      else
        echo "               ... jobfile $jobrunnr still missing in this path."
        exit
      fi
    fi
  else
    mv ../$jobrunnr .
    ljobfiles=`ls -l $jobrunnr | wc | awk '{printf("%7d\n",$1)}'`
    if [ $ljobfiles -ne 2 ] ; then
      if [ $ljobfiles -eq 1 ] ; then
        if [ $computype == "fh1" ] ; then
          echo "               ... jobfile $jobrunnr moved from the upper directory."
        else
          if [ $computype == "bwc" ] ; then
            echo "               ... jobfile $jobrunnr moved from the upper directory."
          else
            echo "               ... jobfile $jobrunnr still missing in this path."
            exit
          fi
        fi
      else
        echo "               ... jobfile $jobrunnr still missing or several moves done,"
        echo "               ...... keep only newest jobfile (check file list)."
        exit
      fi
    else
      echo "               ... jobfiles $jobrunnr moved from the upper directory."
    fi
  fi
fi
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - get current job-id from error protocol file [Job,job]*.e*:
if [ $computype == "bwc" ] ; then
  jobrunout=`echo $jrunnr | awk '{printf("job_uc1_jobwcl-%06d_*.out",$1)}'`
  ls -1 $jobrunout > jobfileerr.tmp
  sed -i "/job/ s/_/-/" jobfileerr.tmp
  sed -i "/job/ s/_/-/" jobfileerr.tmp
  sed -i "/job/ s/_/ /" jobfileerr.tmp
  sed -i "/job/ s/\./ /" jobfileerr.tmp
else
  if  [ $computype == "fh1" ] ; then
    jobrunout=`echo $jrunnr | awk '{printf("jobfh1-%06d_*.out",$1)}'`
    ls -1 $jobrunout > jobfileerr.tmp
    sed -i "/job/ s/_/ /" jobfileerr.tmp
    sed -i "/job/ s/\./ /" jobfileerr.tmp
  else
    if  [ $computype == "stu" ] ; then
      ls -1 jobpll-$jrunnr.e* > jobfileerr.tmp
      sed -i "/job/ s/-/ /" jobfileerr.tmp
      sed -i "/job/ s/\./ /" jobfileerr.tmp
      sed -i "/job/ s/e/ /" jobfileerr.tmp
      sed -i "/job/ s/jobpll/ /" jobfileerr.tmp
    fi
  fi
fi
jobidnumber=`cat jobfileerr.tmp | awk '{printf("%d",$2)}'`
rm jobfileerr.tmp
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - check Job??????.out if postprocessing was already done:
jobfileout=`echo $jrunnr $jobidnumber | awk '{printf("Job%06d_%d.out",$1,$2)}'`
if  [ $computype == "stu" ] ; then
  jobstutout=`echo $jrunnr $jobidnumber | awk '{printf("jobpll-%06d.o%s",$1,$2)}'`
  cp $jobstutout $jobfileout
else
  if [ $computype == "fh1" ] ; then
    jobfh1out=`echo $jrunnr $jobidnumber | awk '{printf("jobfh1-%06d_%d.out",$1,$2)}'`
    cp $jobfh1out $jobfileout
    echo "               ... jobfh1-..._$jobidnumber successfully finished (fh1)."
  else
    if [ $computype == "bwc" ] ; then
      touch $jobfileout
      echo "               ... job_uc1_..._$jobidnumber successfully completed (bwc)."
    else
      tail -1 $jobfileout > jobfileerr.tmp
      jobcomplete=`cat jobfileerr.tmp | awk '{printf("%s",$3)}'`
      rm -f jobfileerr.tmp
      if [ $jobcomplete == "resources:" ] ; then
        echo "               ... job $jobidnumber successfully completed (stu)."
      else
        echo "           ... job $jobidnumber not completed or"
        echo "           ...... postprocessing seems already done for runnr" $jrunnr 
        echo "           ...... check content of file 'time.txt'"
        exit
      fi
    fi
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - write original and real number of files to Job??????.err:
jobfileerr=`echo $jrunnr $jobidnumber | awk '{printf("Job%06d_%d.err",$1,$2)}'`
if [ ! -e summe.f ] ; then
  if [ -e "../summe.f" ] ; then
    cp ../summe.f .
  else
    echo "          ----- missing fortran source file 'summe.f'!"
    exit 1
  fi
fi
if [ `echo $HOSTNAME | cut -b 1-4` == "iklx" ] ; then
  gfortran -O0 -fbounds-check summe.f -o summe
elif [ `echo $HOSTNAME | cut -b 1-4` == "uc1n" ] ; then
  ifort -C -O0 -check bounds summe.f -o summe
elif [ `echo $HOSTNAME | cut -b 1-4` == "fh1n" ] ; then
  ifort -C -O0 -check bounds summe.f -o summe
fi
du -k | ./summe > summe.out
lstfiles=`echo $jrunnr | awk '{printf("DAT%06d-*.lst",$1)}'`
ls -1 $lstfiles 2> joblstfiles.err | wc > joblstfiles.txt
rm joblstfiles.err
jlstnames=`cat joblstfiles.txt | awk '{printf("%7d\n",$1)}'`
rm joblstfiles.txt
datfiles=`echo $jrunnr | awk '{printf("DAT%06d-?????????-?????????",$1)}'`
ls -1 $datfiles > joboutempty.txt 2> /dev/null 
jdatempty=`wc joboutempty.txt | awk '{printf("%7d\n",$1)}'` 
if [ -e DAT$jrunnr-000001 ] ; then
  ls -1 DAT$jrunnr-?????? > jobfileerr.tmp
  jpartfiles=`wc "jobfileerr.tmp" | awk '{printf("%7d\n",$1)}'`
  rm -f jobfileerr.tmp
else
  jpartfiles=`echo $jdatnames | awk '{printf("%7d\n",$1)}'`
fi
echo $jdatnames $jpartfiles | awk '{printf("%7d%7d\n",$1,$2)}' > $jobfileerr
echo "               ... writing number of files to $jobfileerr: " $jdatnames
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - check SIM??????.*-files on antennas and gamma factor:
gammfact=`echo "0.0"`
gexpfact=`echo "0.0"`
jantenns=`echo "0"`
if [ $jrunnr -ge 11000 ] || [ $jrunnr -lt 100 ] ; then
  if [ -e SIM$jrunnr.list ]; then
    jantenns=`grep "AntennaPosition" "SIM$jrunnr.list" | wc | awk '{printf("%d",$1)}'`
    jgamfact=`grep "gamma" "SIM$jrunnr.list" | wc | awk '{printf("%d",$1)}'`
    if [ $jgamfact -gt 0 ] ; then
      head -1 "SIM$jrunnr.list" > jobgamfact.txt
      gammfact=`cat "jobgamfact.txt" | awk '{printf("%s",$8)}'`
      gexpfact=`cat "jobgamfact.txt" | awk '{printf("%s",$9)}'`
      rm -f jobgamfact.txt
    fi
    echo "               ... writing number of antennas to $jobfileerr: " $jantenns
  fi
fi
echo $jantenns $gammfact $gexpfact | awk '{printf("%7d%7.1f%7s\n",$1,$2,$3)}' >> $jobfileerr
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - add third line to time.txt (necessary to run totaltimenew):
echo $jdatnames >> time.txt
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - delete empty particle data files (if any):
if [ $jdatempty -gt 0 ] ; then
  for filename in $( cat joboutempty.txt ) ; do
    jdatfsize=`ls -1s $filename | awk '{printf("%d",$1)}'` 
    if [ $jdatfsize -eq 0 ] ; then
      # echo $filename ;
      rm -f $filename ;
    fi
  done
  echo "               ... deleting empty files $datfiles (if any)"
fi 
rm -f joboutempty.txt
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - delete almost all lst files (keep max 5 in this path, if any):
if [ $jlstnames -gt 0 ] ; then
  ls -1 DAT$jrunnr-*.lst > erase-lstfiles-all.tmp
  nlst=`wc "erase-lstfiles-all.tmp" | awk '{printf("%d",$1)}'`
  let "ndel = $nlst - 5"
  if [ $ndel -gt 0 ] ; then
    cat erase-lstfiles-all.tmp | head -$ndel > erase-lstfiles-del.tmp
    for lstfile in $( cat "erase-lstfiles-del.tmp" ) ; do
      rm -f $lstfile ;
    done
    rm -f erase-lstfiles-del.tmp
    echo "               ... deleting almost all DAT$jrunnr-?????????-?????????.lst"
  fi
  rm -f erase-lstfiles-all.tmp
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - reduce lines in Job??????.out, copy script and steering file: 
head -5 $jobfileout > joboutprotc.tmp 
tail -1 $jobfileout >> joboutprotc.tmp
echo "==========================================================================" >> joboutprotc.tmp
mv joboutprotc.tmp $jobfileout
echo "               ... append simulation infos to $jobfileout" 
if [ $computype == "bwc" ] ; then 
  echo "______ jobwcl-$jrunnr ______" >> $jobfileout
  cat jobwcl-$jrunnr >> $jobfileout   
else 
  if [ $computype == "fh1" ] ; then
    echo "______ jobfh1-$jrunnr ______" >> $jobfileout
    cat jobfh1-$jrunnr >> $jobfileout
  fi
  if [ $computype == "stu" ] ; then
    echo "______ jobpll-$jrunnr ______" >> $jobfileout
    cat jobpll-$jrunnr >> $jobfileout
  fi
fi
echo "______ parallel-$jrunnr ______" >> $jobfileout
cat parallel-$jrunnr >> $jobfileout
echo "               ... writing total Gigabytes to $jobfileout"
./summ DAT >> $jobfileout
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - time.txt?????? (create 5 more info lines):
newtname=`echo $jrunnr | awk '{printf("time.txt%06d",$1)}'`
if [ ! -e time.txt ] ; then
  echo "    START TIME		 STOP TIME	  TIME (min)" > time.txt
  echo "1561122076.012345   1561123456.012345     23.012345" >> time.txt
  cp time.txt corsika_showerTime.txt
fi
mv time.txt corsika_showertime
# test on available source code totaltimenew.f:
if [ ! -e totaltimenew.f ] ; then
  if [ -e "../totaltimenew.f" ] ; then
    cp ../totaltimenew.f .
  else
    echo "          ----- missing source file 'totaltimenew.f'!"
    exit 1
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# compile and link 'totaltimenew' program considering the login node:
if [ `echo $HOSTNAME | cut -b 1-4` == "iklx" ] ; then
  gfortran -O0 -fbounds-check totaltimenew.f -o totaltimenew
elif [ `echo $HOSTNAME | cut -b 1-4` == "uc1n" ] ; then
  ifort -C -O0 -check bounds totaltimenew.f -o totaltimenew
elif [ `echo $HOSTNAME | cut -b 1-4` == "fh1n" ] ; then
  ifort -C -O0 -check bounds totaltimenew.f -o totaltimenew
fi
./totaltimenew > totaltimenew.out
echo $newtname >> totaltimenew.out 
mv totaltimenew.out $newtname
echo "               ... writing complete time information to $newtname"
cat $newtname
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - end-of script postprocessnew.sh.
exit 
