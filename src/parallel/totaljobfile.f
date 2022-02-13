c=======================================================================
c
c  t o t a l j o b f i l e . f
c  ---------------------------
c  auxiliary program after a parallel corsika simulation by scripts
c  on the IKP computing cluster in B425 at KIT-CN Campus North, named
c  `ik3`; count number of files, sum up all times from file `job-file`.
c-----------------------------------------------------------------------
c compilation:
c     gfortran -O0 -fbounds-check totaljobfile.f -o totaljobfile 
c execution:
c     ./totaljobfile > totaljobfile.out
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

      program totaljobfile

      implicit double precision (a-h,o-z), integer (i-n)

      character chzeile*100, chtable*100, cfmtflt*7, cfmtint*4

      data cfmtflt/'(f 6.2)'/, cfmtint/'(i4)'/, ifail/0/

c - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
c - - - - - get time data from time protocol file `job-file`:
      open(unit=1,file='job-file',form='formatted',status='old')
      totimin = 0. ! total time in minutes.
      wallmax = 0.
      jobmax = 0
      do  ii=1,1234567
         read(1,'(a)',end=9,err=9) chzeile
         if ( ii .eq. 1 ) then
            jd = index(chzeile,'DAT')
            read(chzeile(jd+3:jd+8),'(i6)') jrunnr
            chtable = 'totaljobfile.out000000'
            write(chtable(17:22),'(i6.6)') jrunnr
         endif
         if ( chzeile(11:11) .eq. ' ' ) then
            ib = index( chzeile, ' ' )
            id = index( chzeile, ':' )
            ia = index( chzeile, 'Real-time' )
            chzeile(id:id) = ' '
            iz = index( chzeile, ':' )
            if ( iz .gt. 0 ) then ! twice found doubledot character:
               write(cfmtint(3:3),'(i1)') id-ib
               read(chzeile(ib:id-1),cfmtint) jhrs
               write(cfmtint(3:3),'(i1)') iz-id+1
               read(chzeile(id+1:iz-1),cfmtint) jmin
               write(cfmtint(3:3),'(i1)') ia-iz+1
               read(chzeile(iz+1:ia-1),cfmtint) jsec
               walltim = 60.d0*jhrs + dble(jmin) + 1.d0/60.d0*jsec
            else ! once found doubledot character, i.e. time < 1 hour:
               write(cfmtint(3:3),'(i1)') id-ib
               read(chzeile(ib:id-1),cfmtint) jmin
               read(chzeile(id+1:ia-1),cfmtflt) xsec
               walltim = xsec/60.d0 + dble(jmin)
            endif
            if ( walltim .gt. wallmax ) then
               wallmax = walltim 
               jobmax = ii
            endif
            totimin = totimin + walltim
            if ( ii .gt. 1 ) then
               read(chzeile(1:10),'(i10)') jobendt
            else
               read(chzeile(1:10),'(i10)') jobanft
               jobanft = jobanft - int(60.d0*walltim+1.d0) 
            endif
         else
            ifail = ifail + 1
         endif
      enddo
    9 continue
      close(unit=1)
      jfiles = ii - 1 ! number of files
      jwallsec = jobendt - jobanft
      if ( jfiles .le. 1 ) jwallsec = int(60.d0*walltim)

c - - - - - writing total minutes and wall seconds (totaljobfile.out):
      write(*,'(1p,e18.6,0p,i16,f14.1,i10,i10)')
     +   totimin/1440.d0, jwallsec, 60.d0*wallmax, jobmax, jfiles
      write(*,'(7x,''time[days]   wall[sec]   maxjob[sec]'',
     +   ''     maxid    jfiles'')')
      write(*,'(20x,2i14)') jobanft,jobendt

c - - - - - print in error case:
      if ( ifail .gt. 0 ) then 
       ! write(*,'(i28,''. Files in all,'',i5,'' failed.'')') ii,ifail
      endif

c - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
c - - - - - end-of program totaljobfile.
      stop
      end
