c=======================================================================
c
c  t o t a l t i m e n e w . f
c  ---------------------------
c  calculate sum of used cpu times of a set of a parallel corsika
c  simulation (by scripts) taking first lines of Job??????_ik3.out;
c  reading text file `corsika_timetable` of the current parallel
c  corsika subdirectory and create time information file `time.txt`.
c-----------------------------------------------------------------------
c compilation:
c     gfortran -O0 -fbounds-check totaltimenew.f -o totaltimenew
c     ifort -C -O0 -check bounds totaltimenew.f -o totaltimenew
c execution of `./totaltimenew` by new postprocessing script:
c     ./postprocessnew.sh
c-----------------------------------------------------------------------
c compilation:
c     gfortran -O0 -fbounds-check totaltimeik3.f -o totaltimeik3
c execution of `./totaltimeik3` in postprocessing script:
c     ./postprocess-ik3.sh
c-----------------------------------------------------------------------
c input file (unit=1) `corsika_timetable` as of `job-file`:
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
c time.txt002375        # written from script postprocessnew.sh
c-----------------------------------------------------------------------
c                                     juergen.oehlschlaeger@kit.edu
c-----------------------------------------------------------------------

      program totaltimenew

      implicit double precision (a-h,o-z), integer (i-n)

      character czeile*60, comment*160

      logical lexist

c - - - - initializations:
      ia = 0
      ib = 0
      ic = 0
      im = 0
      is = 0
      it = 0
      timeanf = 0.d0
      timeend = 0.d0
      timemax = 0.d0
      timesum = 0.d0

c - - - - copied time.txt file as corsika_showertime available:
      inquire(file='corsika_showertime',exist=lexist)
      if ( lexist ) then
         open(unit=2,file='corsika_showertime',status='old',
     +        form='formatted',access='sequential')
         read(2,'(a)') czeile
         read(2,*) timeanf, timeend, timedif
         read(2,*,end=3,err=3) ic
         ic = ic + 1
         goto 4
    3    continue
         ic = int(timedif*7.6543)
    4    continue
         close(unit=2)
         ib = int(5.d0*ic/7.)
         im = ib
         timemax = timedif * 60.d0
         timesum = (timeend-timeanf) / 1.28d0
      endif

c - - - - check summary timetable file in this path:
      inquire(file='corsika_timetable',exist=lexist)
      if ( lexist ) then
         open(unit=1,file='corsika_timetable',status='old',
     +        form='formatted',access='sequential')
         read(1,*,end=2,err=2) ia,ib,timea,timeb
         timesum = timesum + (timeb - timea)
         do ic=2,1234567890
            read(1,*,end=2,err=2) ia,ib,timea,timeb
            if ( timeb-timea .gt. timemax ) timemax = timeb-timea 
            if ( ia .gt. im ) im = ia
            timesum = timesum + (timeb-timea)   
         enddo
    2    continue
         close(unit=1)
      endif

c - - - - write to new time information file (totaltimenew.out):
      write(*,'(5x,''START TIME'',10x,''STOP TIME'',7x,''TIME (min)'')')
      write(*,'(f17.6,f20.6,f14.6)') timeanf, timeend,
     +   (timeend-timeanf)/60.
      write(*,'(''LONGEST JOB: MPIID ='',i6,'' and Time ='',f14.6)')
     +   ib, timemax 
      write(*,'('' Total number of jobs ='',i6)') ic-1
      write(*,'(''Maximum size of group ='',i6)') im
      write(*,'(''TOTAL CPU TIME (days) ='',f13.6)') timesum/86400.d0

c - - - - end-of program (totaltimenew.out => time.txtnnnnnn).
      stop
      end
