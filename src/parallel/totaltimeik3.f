c=======================================================================
c
c  t o t a l t i m e i k 3. f
c  --------------------------
c  calculate sum of used cpu times of a set of a parallel corsika
c  simulation (by scripts) taking first lines of Job??????_ik3.out;
c-----------------------------------------------------------------------
c compilation:
c     gfortran -O0 -fbounds-check totaltimeik3.f -o totaltimeik3
c execution of `./totaltimeik3` in postprocessing script:
c     ./postprocess-ik3.sh
c-----------------------------------------------------------------------
c input file (unit=1) `job-file`:
c 1571482621 0:17.85 Real-time 0.34 TotalCPUseconds ./DAT002375-000000000-000000001.lst
c 1571482659 0:15.78 Real-time 0.24 TotalCPUseconds ./DAT002375-000237558-000000007.lst
c 1571482660 0:17.28 Real-time 0.27 TotalCPUseconds ./DAT002375-000237558-000000003.lst
c 1571482664 0:20.89 Real-time 0.32 TotalCPUseconds ./DAT002375-000237558-000000009.lst
c 1571482672 0:29.05 Real-time 0.84 TotalCPUseconds ./DAT002375-000237558-000000008.lst
c 1571482689 10:21.28 Real-time 0.27 TotalCPUseconds ./DAT002375-186147193-000000035.lst
c 1571483120 5:42.06 Real-time 0.80 TotalCPUseconds ./DAT002375-144544442-000000157.lst
c 1571483124 7:16.29 Real-time 0.76 TotalCPUseconds ./DAT002375-854200558-000000061.lst
c 1571483132 6:09.07 Real-time 1.01 TotalCPUseconds ./DAT002375-484720940-000000152.lst
c 1571483135 7:21.88 Real-time 0.76 TotalCPUseconds ./DAT002375-865705441-000000076.lst
c 1571483137 7:23.70 Real-time 0.81 TotalCPUseconds ./DAT002375-865705441-000000077.lst
c 1571483158 7:09.76 Real-time 1.02 TotalCPUseconds ./DAT002375-593790006-000000131.lst
c-----------------------------------------------------------------------
c output (unit=*) `totaljobfile.out`:
c    3.566766E-01         555         443.7       160       161
c      time[days]   wall[sec]   maxjob[sec]     maxid    jfiles
c                  1571482603    1571483158
c-----------------------------------------------------------------------
c      START TIME          STOP TIME       TIME (min)
c 1571482603.002375   1571483158.002375      9.252057
c LONGEST JOB: MPIID =   160 and Time =    443.700000
c  Total number of jobs =  161
c Maximum size of group =   17
c TOTAL CPU TIME (days) =    0.356677
c time.txt002375
c-----------------------------------------------------------------------
c                                     juergen.oehlschlaeger@kit.edu
c-----------------------------------------------------------------------

      program totaltimeik3

      implicit double precision (a-h,o-z), integer (i-n)

      character chlinea*250, chlineb*250, chlinec*250, cjoberr*17,
     +    ctimtxt*14, czeile1*51, czeile3*37, czeile4*23,
     +    czeile5*23, czeile6*23, cfmtflt*7, cfmtint*4

      data cfmtflt/'(f 6.2)'/, cfmtint/'(i2)'/

c - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
c - - - - initializations:
      data cjoberr/'Job000000_ik3.err'/ 
      data ctimtxt/'time.txt000000'/
      data czeile1/
     +   '     START TIME          STOP TIME       TIME (min)'/
      data czeile3/'LONGEST JOB: MPIID =       and Time ='/
      data czeile4/' Total number of jobs ='/
      data czeile5/'Maximum size of group ='/
      data czeile6/'TOTAL CPU TIME (days) ='/
      chdsek = 1.d0 / 3600.d0
      hoursum = 0.d0
      jwallsec = 1
      ignored = 0
      mjobs = 17
      ljob = 17

c - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
c - - - - read Real-time lines from job-file or Job??????_ik3.out: 
      read(*,'(a250)') chlinea ! first line in file `job-file`.
      read(*,'(a250)') chlineb !  last line in file `job-file`.
      read(*,*) jfiles
      do  il=3,33
         read(*,'(a250)') chlinec
         if ( index(chlinec,'initial-ik3') .gt. 0 ) goto 3
      enddo
    3 continue
      if ( index(chlinea,'error') .gt. 0 .or. 
     +     index(chlinea,'exited') .gt. 0 .or.
     +     index(chlinea,'runtime') .gt. 0 ) then
         write(*,*) ' error message in `Jobiiiiii_ik3.out`. exit'
         goto 9
      endif
      read(chlinea(1:10),'(i10)') jobseca
      read(chlineb(1:10),'(i10)') jobsecb
      ib = index(chlinea,' ')
      id = index(chlinea,':')
      ia = index(chlinea,'Real-time')
      jd = index(chlinea(id+1:id+5),':') ! possible next ':'
      if ( jd .gt. 0 ) chlinea(id+jd:id+jd) = '.'
      write(cfmtint(3:3),'(i1)') id-ib
      jmin = 0
      if ( id-1 .ge. ib ) read(chlinea(ib:id-1),cfmtint) jmin
      read(chlinea(id+1:ia-1),cfmtflt) xsec
      jobseca = jobseca - jmin*60 - int(xsec+0.7)
      jrun = index(chlinec,'parallel') + 9
      read(chlinec(jrun:jrun+5),'(i6)') mrunnr
      write(cjoberr(4:9),'(i6.6)') mrunnr 
      write(ctimtxt(9:14),'(i6.6)') mrunnr
 
c - - - - get number of parts of the simulation from Job??????_ik3.err:
      open(unit=1,file=cjoberr,form='formatted',
     +     access='sequential',status='unknown')
      read(1,*,end=4,err=4) mjobs
    4 continue
      close(unit=1)

c - - - - get totaltime in days and run number:
      open(unit=2,file='totaljobfile.out',access='sequential',
     +     form='formatted',status='old')
      read(2,*,end=5,err=5) timedays, jwallsec, wallmax, jobmax, jfiles
    5 continue
      close(unit=2)
      if ( mjobs .eq. 1 ) ljob = mjobs
      wallsec = 0.1234d0 + jwallsec

c - - - - write time infos to file `time.txt??????`:
      open(unit=3,file=ctimtxt,form='formatted',
     +     access='sequential',status='unknown')
      write(3,'(a)') czeile1
      write(3,'(i10,''.'',i6.6,i13,''.'',i6.6,f14.6)')
     +   jobseca,mrunnr,jobsecb,mrunnr,1.d0/60.d0*wallsec
      write(3,'(a,i6,a,f14.6)') czeile3(1:20), jobmax,
     +    czeile3(27:37), wallmax ! timedays*2.6543d3
      write(3,'(a,i5)') czeile4, mjobs
      write(3,'(a,i5)') czeile5, ljob
      write(3,'(a,f12.6)') czeile6, timedays
      write(3,'(''time.txt'',i6.6)') mrunnr
      close(unit=3)

c - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
c - - - - end of program.
    9 continue
      stop
      end
