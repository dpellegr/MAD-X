      subroutine twiss(rt,disp0,tab_name)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TWISS command: Track linear lattice parameters.                    *
!----------------------------------------------------------------------*
      include 'twiss0.fi'
      include 'twissa.fi'
      include 'twissl.fi'
      include 'twissc.fi'
      include 'twissotm.fi'
      integer tab_name(*),chrom,summ,eflag,inval,get_option,izero,ione
      double precision rt(6,6),disp0(6),orbit0(6),orbit(6),tt(6,6,6),   &
     &ddisp0(6),r0mat(2,2),zero,one,two,get_value
      parameter(zero=0d0,one=1d0,two=2d0)
      character*48 charconv
      data izero, ione / 0, 1 /

!---- Initialization
      table_name = charconv(tab_name)
      chrom=0
      summ=0
      eflag=0
      inval=0
      call get_orbit0(orbit0)
      call m66one(rt)
      call m66one(rw)
      call dzero(tt,216)
      call get_disp0(disp0)
      call dzero(ddisp0,6)
      call dzero(r0mat,4)
      call dzero(opt_fun0,fundim)
      call dzero(opt_fun,fundim)
      call dzero(disp,6)
      call dzero(ddisp,6)
      call dzero(rmat,4)
      betx=zero
      alfx=zero
      amux=zero
      bety=zero
      alfy=zero
      amuy=zero
      bxmax=zero
      dxmax=zero
      bymax=zero
      dymax=zero
      xcomax=zero
      ycomax=zero
      sigxco=zero
      sigyco=zero
      sigdx=zero
      sigdy=zero
      wgt=zero
      cosmux=zero
      cosmuy=zero
      wx=zero
      phix=zero
      dmux=zero
      wy=zero
      phiy=zero
      dmuy=zero
      synch_1=zero
      synch_2=zero
      synch_3=zero
      synch_4=zero
      synch_5=zero
      suml=zero
      eta=zero
      alfa=zero
      gamtr=zero
      qx=zero
      qy=zero
      sinmux=zero
      sinmuy=zero
      xix=zero
      xiy =zero

!---- Track chromatic functions
      chrom=get_option('twiss_chrom ')

!---- Create internal table for summary data.
      summ=get_option('twiss_summ ')

!---- Initial value flag.
      inval=get_option('twiss_inval ')
!--- flags for writing cumulative or lumped matrices
      rmatrix=get_value('twiss ','rmatrix ').ne.zero
      sectormap=get_option('twiss_sector ').ne.zero
!---- Initial values from command attributes.
      if (inval.ne.0) then

!---- Get transfer matrix.
        call tmfrst(orbit0,orbit,.true.,.true.,rt,tt,eflag,0)
        if(eflag.ne.0) go to 900

!---- Initial values from periodic solution.
      else
        call tmclor(orbit0,.true.,.true.,opt_fun0,rt,tt,eflag)
        if(eflag.ne.0) go to 900
        call tmfrst(orbit0,orbit,.true.,.true.,rt,tt,eflag,0)
        if(eflag.ne.0) go to 900
        call twcpin(rt,disp0,r0mat,eflag)
        if(eflag.ne.0) go to 900
      endif
      if (sectormap)  then
        call dcopy(orbit0, sorb, 6)
        call m66one(srmat)
        call dzero(stmat, 216)
      endif

!---- Initialize opt_fun0
      call twinifun(opt_fun0,rt)

!---- Build table of lattice functions, coupled.
      call twcpgo(rt)

!---- List chromatic functions.
      if(chrom.ne.0) then
        call twbtin(rt,tt)
        call twchgo
      endif

!---- Print summary
      if(summ.ne.0) call tw_summ(rt,tt)

      call set_option('twiss_success ', ione)
      goto 9999
 900  call set_option('twiss_success ', izero)
 9999 end
      subroutine tmrefe(rt)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Transfer matris w.r.t. ideal orbit for one period.                 *
!   Ignores cavities, radiation, and imperfections.                    *
! Output:                                                              *
!   rt(6,6) (double) transfer matrix.                                  *
!----------------------------------------------------------------------*
      integer eflag
      double precision orbit0(6),orbit(6),rt(6,6),tt(6,6,6)

      call dzero(orbit0,6)
!---- Get transfer matrix.
      call tmfrst(orbit0,orbit,.false.,.false.,rt,tt,eflag,0)
      end
      subroutine tmrefo(kobs,orbit0,orbit,rt)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Transfer matrix w.r.t. ideal orbit for one period.                 *
! Input:                                                               *
!   kobs    if > 0, track until node with this obs. point number       *
! Output:                                                              *
!   orbit0(6) (double) closed orbit at start=end                       *
!   orbit(6)  (double) closed orbit at obs. point kobs, or at end      *
!   rt(6,6) (double) transfer matrix.                                  *
!----------------------------------------------------------------------*
      include 'twiss0.fi'
      integer eflag,kobs,izero,ione
      double precision opt_fun0(fundim),orbit0(6),orbit(6),rt(6,6),     &
     &tt(6,6,6)
      data izero, ione / 0, 1 /

      call dzero(orbit0,6)
!---- Get closed orbit and coupled transfer matrix.
      call tmclor(orbit0,.true.,.true.,opt_fun0,rt,tt,eflag)
      call set_option('bbd_flag ', ione)
      call tmfrst(orbit0,orbit,.true.,.true.,rt,tt,eflag,kobs)
      call set_option('bbd_flag ', izero)
      end
      subroutine twinifun(opt_fun0,rt)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Initial twiss parameters put to opt_fun0.                          *
! Input/output:                                                        *
!   opt_fun0(fundim) (double) initial optical values:                  *
!                         betx0,alfx0,amux0,bety0,alfy0,amuy0, etc.    *
!----------------------------------------------------------------------*
      include 'twiss0.fi'
      include 'twissl.fi'
      integer i1,i2
      double precision opt_fun0(*),rt(6,6),betx,alfx,mux,bety,alfy,muy, &
     &x,px,y,py,t,pt,dx,dpx,dy,dpy,wx,phix,dmux,wy,phiy,dmuy,ddx,ddpx,  &
     &ddy,ddpy,r(2,2),energy,get_value,zero
      parameter(zero=0d0)

      betx=get_value('twiss ','betx ')
      bety=get_value('twiss ','bety ')
      if(betx.gt.zero) opt_fun0(3)=betx
      if(bety.gt.zero) opt_fun0(6)=bety

      if(opt_fun0(3).le.zero.or.opt_fun0(6).le.zero)                    &
     &call aafail('TWINIFUN: ',                                         &
     &'BETX and BETY must be both larger than zero.')

      alfx=  get_value('twiss ','alfx ')
      mux=   get_value('twiss ','mux ')
      alfy=  get_value('twiss ','alfy ')
      muy=   get_value('twiss ','muy ')
      x=     get_value('twiss ','x ')
      px=    get_value('twiss ','px ')
      y=     get_value('twiss ','y ')
      py=    get_value('twiss ','py ')
      t=     get_value('twiss ','t ')
      pt=    get_value('twiss ','pt ')
      dx=    get_value('twiss ','dx ')
      dpx=   get_value('twiss ','dpx ')
      dy=    get_value('twiss ','dy ')
      dpy=   get_value('twiss ','dpy ')
      wx=    get_value('twiss ','wx ')
      phix=  get_value('twiss ','phix ')
      dmux=  get_value('twiss ','dmux ')
      wy=    get_value('twiss ','wy ')
      phiy=  get_value('twiss ','phiy ')
      dmuy=  get_value('twiss ','dmuy ')
      ddx=   get_value('twiss ','ddx ')
      ddpx=  get_value('twiss ','ddpx ')
      ddy=   get_value('twiss ','ddy ')
      ddpy=  get_value('twiss ','ddpy ')
      r(1,1)=get_value('twiss ','r11 ')
      r(1,2)=get_value('twiss ','r12 ')
      r(2,1)=get_value('twiss ','r21 ')
      r(2,2)=get_value('twiss ','r22 ')
      energy=get_value('probe ','energy ')

      if(alfx  .ne.zero) opt_fun0(4 )=alfx
      if(mux   .ne.zero) opt_fun0(5 )=mux
      if(alfy  .ne.zero) opt_fun0(7 )=alfy
      if(muy   .ne.zero) opt_fun0(8 )=muy
      if(x     .ne.zero) opt_fun0(9 )=x
      if(px    .ne.zero) opt_fun0(10)=px
      if(y     .ne.zero) opt_fun0(11)=y
      if(py    .ne.zero) opt_fun0(12)=py
      if(t     .ne.zero) opt_fun0(13)=t
      if(pt    .ne.zero) opt_fun0(14)=pt
      if(dx    .ne.zero) opt_fun0(15)=dx
      if(dpx   .ne.zero) opt_fun0(16)=dpx
      if(dy    .ne.zero) opt_fun0(17)=dy
      if(dpy   .ne.zero) opt_fun0(18)=dpy
      if(wx    .ne.zero) opt_fun0(19)=wx
      if(phix  .ne.zero) opt_fun0(20)=phix
      if(dmux  .ne.zero) opt_fun0(21)=dmux
      if(wy    .ne.zero) opt_fun0(22)=wy
      if(phiy  .ne.zero) opt_fun0(23)=phiy
      if(dmuy  .ne.zero) opt_fun0(24)=dmuy
      if(ddx   .ne.zero) opt_fun0(25)=ddx
      if(ddpx  .ne.zero) opt_fun0(26)=ddpx
      if(ddy   .ne.zero) opt_fun0(27)=ddy
      if(ddpy  .ne.zero) opt_fun0(28)=ddpy
      if(r(1,1).ne.zero) opt_fun0(29)=r(1,1)
      if(r(1,2).ne.zero) opt_fun0(30)=r(1,2)
      if(r(2,1).ne.zero) opt_fun0(31)=r(2,1)
      if(r(2,2).ne.zero) opt_fun0(32)=r(2,2)
      if(energy.ne.zero) opt_fun0(33)=energy
      if(rmatrix) then
        do i1=1,6
          do i2=1,6
            opt_fun0(33+(i1-1)*6+i2)=rt(i1,i2)
          enddo
        enddo
      endif

      end
      subroutine twfill(case,opt_fun,position,flag)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Fill twiss table with twiss parameters.                            *
! Input:                                                               *
!   case        (integer) =1 fill from twcpgo; =2 fill from twchgo     *
!   position    (double)  end position of element                      *
!   flag        (integer) fill flag: 0 no, !=0 yes                     *
! Input/output:                                                        *
!   opt_fun(fundim) (double) optical values:                           *
!                        betx,alfx,amux,bety,alfy,amuy, etc.           *
!----------------------------------------------------------------------*
      include 'twissa.fi'
      include 'twissl.fi'
      include 'twissotm.fi'
      integer case,i,flag
      double precision opt_fun(*),position,twopi,tmp,get_variable,      &
     &zero
      parameter(zero=0d0)

!---- Initialize
      twopi=get_variable('twopi ')
      if (flag .ne. 0)  then
      if(case.eq.1) then
        opt_fun(2)=position
        call double_to_table(table_name,'s '     ,opt_fun(2 ))
        call double_to_table(table_name,'betx '  ,opt_fun(3 ))
        call double_to_table(table_name,'alfx '  ,opt_fun(4 ))
        tmp = opt_fun(5) / twopi
        call double_to_table(table_name,'mux '   ,tmp)
        call double_to_table(table_name,'bety '  ,opt_fun(6 ))
        call double_to_table(table_name,'alfy '  ,opt_fun(7 ))
        tmp = opt_fun(8) / twopi
        call double_to_table(table_name,'muy '   ,tmp)
        call double_to_table(table_name,'x '     ,opt_fun(9 ))
        call double_to_table(table_name,'px '    ,opt_fun(10))
        call double_to_table(table_name,'y '     ,opt_fun(11))
        call double_to_table(table_name,'py '    ,opt_fun(12))
        call double_to_table(table_name,'t '     ,opt_fun(13))
        call double_to_table(table_name,'pt '    ,opt_fun(14))
        call double_to_table(table_name,'dx '    ,opt_fun(15))
        call double_to_table(table_name,'dpx '   ,opt_fun(16))
        call double_to_table(table_name,'dy '    ,opt_fun(17))
        call double_to_table(table_name,'dpy '   ,opt_fun(18))
        call double_to_table(table_name,'r11    ',opt_fun(29))
        call double_to_table(table_name,'r12    ',opt_fun(30))
        call double_to_table(table_name,'r21    ',opt_fun(31))
        call double_to_table(table_name,'r22    ',opt_fun(32))
        call double_to_table(table_name,'energy ',opt_fun(33))
        if(rmatrix) then
          i = 36
          call vector_to_table(table_name, 're11 ', i, opt_fun(34))
        endif
      elseif(case.eq.2) then
        call double_to_table(table_name,'wx '    ,opt_fun(19))
        call double_to_table(table_name,'phix '  ,opt_fun(20))
        call double_to_table(table_name,'dmux '  ,opt_fun(21))
        call double_to_table(table_name,'wy '    ,opt_fun(22))
        call double_to_table(table_name,'phiy '  ,opt_fun(23))
        call double_to_table(table_name,'dmuy '  ,opt_fun(24))
        call double_to_table(table_name,'ddx '   ,opt_fun(25))
        call double_to_table(table_name,'ddpx '  ,opt_fun(26))
        call double_to_table(table_name,'ddy '   ,opt_fun(27))
        call double_to_table(table_name,'ddpy '  ,opt_fun(28))
      endif

!---- Augment table twiss
      call augment_count(table_name)
      endif
      end
      subroutine tmclor(guess,fsec,ftrk,opt_fun0,rt,tt,eflag)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Find closed orbit for a beam line sequence.                        *
! Input:                                                               *
!   guess(6)     (double)  first guess for orbit start                 *
!   fsec         (logical) if true, return second order terms.         *
!   ftrk         (logical) if true, track orbit.                       *
! Output:                                                              *
!   guess(6)     (double)  final orbit                                 *
!   opt_fun0(fundim) (double)  initial optical values:                 *
!                          betx0,alfx0,amux0,bety0,alfy0,amuy0, etc.   *
!   rt(6,6)      (double)  transfer matrix.                            *
!   tt(6,6,6)    (double)  second order terms.                         *
!   eflag        (integer) error flag.                                 *
!----------------------------------------------------------------------*
      logical fsec,ftrk,m66sta
      integer eflag,i,k,irank,itra,itmax
      parameter(itmax=10)
      double precision guess(6),opt_fun0(*),rt(6,6),tt(6,6,6),cotol,err,&
     &orbit0(6),orbit(6),a(6,7),b(4,5),as(3,4),bs(2,3),deltap,get_value,&
     &zero,one,ten6m
      parameter(zero=0d0,one=1d0,ten6m=1d-6)
      equivalence(a(1,1),b(1,1),as(1,1),bs(1,1))

!---- Initialize.
      deltap = get_value('probe ','deltap ')
      cotol = ten6m
      eflag = 0
!---- Initialize guess.
      call dcopy(guess,orbit0,6)

!---- Iteration for closed orbit.
      do itra = 1, itmax

!---- Track orbit and transfer matrix.
        call tmfrst(orbit0,orbit,fsec,ftrk,rt,tt,eflag,0)
        if (eflag.ne.0)  return
!---- Solve for dynamic case.
        if (.not.m66sta(rt)) then
          err = zero
          call dcopy(rt,a,36)
          do i = 1, 6
            a(i,i) = a(i,i) - one
            a(i,7) = orbit(i) - orbit0(i)
            err = max(abs(a(i,7)), err)
          enddo
          call solver(a,6,1,irank)
          if (irank.lt.6) go to 820
          do i = 1, 6
            orbit0(i) = orbit0(i) - a(i,7)
          enddo

!---- Solve for static case.
        else
          err = zero
          do i = 1, 4
            do k = 1, 4
              b(i,k) = rt(i,k)
            enddo
            b(i,i) = b(i,i) - one
            b(i,5) = orbit(i) - orbit0(i)
            err = max(abs(b(i,5)), err)
          enddo
          call solver(b,4,1,irank)
          if (irank.lt.4) go to 820
          do i = 1, 4
            orbit0(i) = orbit0(i) - b(i,5)
          enddo
        endif

!---- Message and convergence test.
        print *, ' '
        print '(''iteration: '',i3,'' error: '',1p,e14.6,'' deltap: '', &
     &  1p,e14.6)',itra,err,deltap
        print '(''orbit: '', 1p,6e14.6)', orbit0
        if (err.lt.cotol) then
          opt_fun0(9 )=orbit0(1)
          opt_fun0(10)=orbit0(2)
          opt_fun0(11)=orbit0(3)
          opt_fun0(12)=orbit0(4)
          opt_fun0(13)=orbit0(5)
          opt_fun0(14)=orbit0(6)
          guess(1)=orbit0(1)
          guess(2)=orbit0(2)
          guess(3)=orbit0(3)
          guess(4)=orbit0(4)
          guess(5)=orbit0(5)
          guess(6)=orbit0(6)
          go to 999
        endif
      enddo

!---- No convergence.
      print                                                             &
     &'(''Closed orbit did not converge in '', i3, '' iterations'')',   &
     &itmax
      opt_fun0(9 )=zero
      opt_fun0(10)=zero
      opt_fun0(11)=zero
      opt_fun0(12)=zero
      opt_fun0(13)=zero
      opt_fun0(14)=zero
      goto 999
  820 continue
      print *, 'Singular matrix occurred during closed orbit search.'
      eflag = 1
 999  end
      subroutine tmfrst(orbit0,orbit,fsec,ftrk,rt,tt,eflag,kobs)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Transfer matrix w.r.t. actual orbit for one (half) superperiod.    *
!   Misalignment and field errors are considered.                      *
! Input:                                                               *
!   orbit0(6) (double)  first guess for orbit start                    *
!   fsec      (logical) if true, return second order terms.            *
!   ftrk      (logical) if true, track orbit.                          *
! Output:                                                              *
!   orbit(6)  (double)  orbit after one turn starting from orbit0      *
!   rt(6,6)   (double)  transfer matrix.                               *
!   tt(6,6,6) (double)  second order terms.                            *
!   eflag     (integer) error flag.                                    *
!   kobs      (integer) if > 0, stop at node with this obs. point #    *
!----------------------------------------------------------------------*
      include 'twiss0.fi'
      include 'twissa.fi'
      include 'twissc.fi'
      include 'bb.fi'
      logical fsec,ftrk,fmap
      integer eflag,i,j,code,restart_sequ,advance_node,node_al_errors,  &
     &n_align,kobs,nobs
      double precision orbit0(6),orbit(6),rt(6,6),tt(6,6,6),el,ek(6),   &
     &re(6,6),te(6,6,6),al_errors(align_max),betas,gammas,node_value,   &
     &get_value,parvec(26),orb_limit,zero
      parameter(orb_limit=1d1,zero=0d0)

!---- Initialize.
      betas = get_value('probe ','beta ')
      gammas= get_value('probe ','gamma ')
      call dzero(tt,216)
      call m66one(rt)
      eflag = 0
      suml = zero
      call dcopy(orbit0,orbit,6)
      parvec(5)=get_value('probe ', 'arad ')
      parvec(6)=get_value('probe ', 'charge ') *                        &
     &get_value('probe ', 'npart ')
      parvec(7)=get_value('probe ','gamma ')
      bbd_cnt=0
      bbd_flag=1

      i = restart_sequ()
 10   continue
      bbd_pos=i
      code = node_value('mad8_type ')
      el = node_value('l ')
      nobs = node_value('obs_point ')
      n_align = node_al_errors(al_errors)
      if (n_align.ne.0)  then
        call tmali1(orbit,al_errors,betas,gammas,orbit,re)
        call m66mpy(re,rt,rt)
      endif
!---- Element matrix and length.
      call tmmap(code,fsec,ftrk,orbit,fmap,ek,re,te)
      if (fmap) then
!---- call m66mpy(re,rt,rt)
        call tmcat(.true.,re,te,rt,tt,rt,tt)
        suml = suml + el
      endif
      if (n_align.ne.0)  then
        call tmali2(el,orbit,al_errors,betas,gammas,orbit,re)
        call m66mpy(re,rt,rt)
      endif
      if (kobs.gt.0.and.kobs.eq.nobs) return
!---- Test for overflow.
      do j = 1, 6
        if (abs(orbit(j)).ge.orb_limit) then
          eflag = 1
          return
        endif
      enddo
      if (advance_node().ne.0)  then
        i=i+1
        goto 10
      endif
      bbd_flag=0
  999 end
      subroutine twcpin(rt,disp0,r0mat,eflag)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Initial values for linear coupling parameters.                     *
! Input:                                                               *
!   rt(6,6)      (double)  one turn transfer matrix.                   *
! Output:                                                              *
!   disp0        (double)  initial dispersion vector                   *
!   r0mat(2,2)   (double)  coupling matrix                             *
!   eflag        (integer) error flag.                                 *
!----------------------------------------------------------------------*
      include 'twiss0.fi'
      include 'twissa.fi'
      include 'twissc.fi'
      integer eflag,stabx,staby
      double precision rt(6,6),disp0(6),r0mat(2,2),a(2,2),arg,aux(2,2), &
     &d(2,2),den,det,dtr,sinmu2,betx0,alfx0,amux0,bety0,alfy0,amuy0,    &
     &deltap,get_value,eps,zero,one,two,fourth
      parameter(eps=1d-8,zero=0d0,one=1d0,two=2d0,fourth=0.25d0)
      character*120 msg

!---- Initialization
      deltap = get_value('probe ','deltap ')

!---- Initial dispersion.
      call twdisp(rt,rt(1,6),disp0)
      disp0(5) = zero
      disp0(6) = one

!---- Matrix C + B(bar) and its determinant.
      aux(1,1) = rt(3,1) + rt(2,4)
      aux(1,2) = rt(3,2) - rt(1,4)
      aux(2,1) = rt(4,1) - rt(2,3)
      aux(2,2) = rt(4,2) + rt(1,3)
      det = aux(1,1) * aux(2,2) - aux(1,2) * aux(2,1)

!---- Coupling matrix.
      dtr = (rt(1,1) + rt(2,2) - rt(3,3) - rt(4,4)) / two
      arg = det + dtr**2
      if (arg.ge.zero) then
        if (arg .eq. zero) then
          r0mat(1,1) = one
          r0mat(2,2) = one
          r0mat(1,2) = zero
          r0mat(2,1) = zero
        else
          den = - (dtr + sign(sqrt(arg),dtr))
          r0mat(1,1) = aux(1,1) / den
          r0mat(1,2) = aux(1,2) / den
          r0mat(2,1) = aux(2,1) / den
          r0mat(2,2) = aux(2,2) / den
        endif

!---- Decouple: Find diagonal blocks.
        a(1,1) = rt(1,1) - rt(1,3)*r0mat(1,1) - rt(1,4)*r0mat(2,1)
        a(1,2) = rt(1,2) - rt(1,3)*r0mat(1,2) - rt(1,4)*r0mat(2,2)
        a(2,1) = rt(2,1) - rt(2,3)*r0mat(1,1) - rt(2,4)*r0mat(2,1)
        a(2,2) = rt(2,2) - rt(2,3)*r0mat(1,2) - rt(2,4)*r0mat(2,2)
        d(1,1) = rt(3,3) + r0mat(1,1)*rt(1,3) + r0mat(1,2)*rt(2,3)
        d(1,2) = rt(3,4) + r0mat(1,1)*rt(1,4) + r0mat(1,2)*rt(2,4)
        d(2,1) = rt(4,3) + r0mat(2,1)*rt(1,3) + r0mat(2,2)*rt(2,3)
        d(2,2) = rt(4,4) + r0mat(2,1)*rt(1,4) + r0mat(2,2)*rt(2,4)

!---- First mode.
        cosmux = (a(1,1) + a(2,2)) / two
        stabx=0
        if(abs(cosmux).lt.one) stabx=1
        if (stabx.ne.0) then
          sinmu2 = - a(1,2)*a(2,1) - fourth*(a(1,1) - a(2,2))**2
          if (sinmu2.lt.zero) sinmu2 = eps
          sinmux = sign(sqrt(sinmu2), a(1,2))
          betx0 = a(1,2) / sinmux
          alfx0 = (a(1,1) - a(2,2)) / (two * sinmux)
        else
          betx0 = zero
          alfx0 = zero
        endif

!---- Second mode.
        cosmuy = (d(1,1) + d(2,2)) / two
        staby=0
        if(abs(cosmux).lt.one) staby=1
        if (staby.ne.0) then
          sinmu2 = - d(1,2)*d(2,1) - fourth*(d(1,1) - d(2,2))**2
          if (sinmu2.lt.zero) sinmu2 = eps
          sinmuy = sign(sqrt(sinmu2), d(1,2))
          bety0 = d(1,2) / sinmuy
          alfy0 = (d(1,1) - d(2,2)) / (two * sinmuy)
        else
          bety0 = zero
          alfy0 = zero
        endif

!---- Unstable due to coupling.
      else
        stabx = 0
        staby = 0
      endif

!---- Initial phase angles.
      amux0 = zero
      amuy0 = zero

!---- Give message, if unstable.
      eflag = 0
      if (stabx+staby.lt.2) then
        if (staby.ne.0) then
          write (msg, 910) 1,deltap
          call aawarn('TWCPIN: ',msg)
        else if (stabx.ne.0) then
          write (msg, 910) 2,deltap
          call aawarn('TWCPIN: ',msg)
        else
          write (msg, 920) deltap
          call aawarn('TWCPIN: ',msg)
          eflag = 1
        endif
      endif
      opt_fun0(3)=betx0
      opt_fun0(4)=alfx0
      opt_fun0(5)=amux0
      opt_fun0(6)=bety0
      opt_fun0(7)=alfy0
      opt_fun0(8)=amuy0
      opt_fun0(15)=disp0(1)
      opt_fun0(16)=disp0(2)
      opt_fun0(17)=disp0(3)
      opt_fun0(18)=disp0(4)
      opt_fun0(29)=r0mat(1,1)
      opt_fun0(30)=r0mat(1,2)
      opt_fun0(31)=r0mat(2,1)
      opt_fun0(32)=r0mat(2,2)

  910 format('Mode ',i1,' is unstable  for delta(p)/p =',f12.6)
  920 format('Both modes are unstable for delta(p)/p = ',f12.6)

 9999 end
      subroutine twdisp(rt,vect,disp)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Initial values for dispersion or its first derivative by delta.    *
!   Only the first four components of the vectors are set.             *
! Input:                                                               *
!   rt(6,6)   (double)    one turn transfer matrix.                    *
!   vect(6)   (double)    right-hand side:                             *
!                         column 6 of rt for dispersion,               *
!                         auxiliary vector for derivative of dipersion.*
! Output:                                                              *
!   disp(6)   (double)    dispersion vector.                           *
!----------------------------------------------------------------------*
      integer i,j,irank
      double precision rt(6,6),vect(6),disp(6),a(4,5),zero,one
      parameter(zero=0d0,one=1d0)

      do i = 1, 4
        do j = 1, 4
          a(i,j) = rt(i,j)
        enddo
        a(i,i) = a(i,i) - one
        a(i,5) = - vect(i)
      enddo

      call solver(a,4,1,irank)

      if (irank.ge.4) then
        do i = 1, 4
          disp(i) = a(i,5)
        enddo
      else
        call aawarn('TWDISP: ',                                         &
     &  'Unable to compute dispersion --- dispersion set to zero.')
        call dzero(disp,4)
      endif

      end
      subroutine twcpgo(rt)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Track Twiss parameters with optional output, version with coupling.*
! Input:                                                               *
!   rt(6,6)   (double)  one turn transfer matrix.                      *
!----------------------------------------------------------------------*
      include 'twiss0.fi'
      include 'twissl.fi'
      include 'twissa.fi'
      include 'twissc.fi'
      include 'twissotm.fi'
      logical fmap,cplxy,cplxt,dorad,sector_sel
      integer i,iecnt,code,save,advance_node,restart_sequ,get_option,   &
     &node_al_errors,n_align
      double precision rt(6,6),ek(6),re(6,6),rwi(6,6),rc(6,6),te(6,6,6),&
     &el,orbit(6),betas,gammas,al_errors(align_max),bv0,bvk, sumloc,    &
     &pos0,node_value,get_value,zero,one,two
      parameter(zero=0d0,one=1d0,two=2d0)
      character*120 msg

!---- Initialization
      currpos=zero
      sumloc = zero
      dorad = get_value('probe ','radiate ').ne.zero
      centre = get_value('twiss ','centre ').ne.zero
      call m66one(rwi)
      call m66one(rc)

!---- Store one-turn-map
      call dcopy(rt,rotm,36)

!---- Create internal table for lattice functions if requested
      save=get_option('twiss_save ')
      call dcopy(opt_fun0,opt_fun,fundim)

!---- Initial values for lattice functions.
      betx    =opt_fun(3 )
      alfx    =opt_fun(4 )
      amux    =opt_fun(5 )
      bety    =opt_fun(6 )
      alfy    =opt_fun(7 )
      amuy    =opt_fun(8 )
      orbit(1)=opt_fun(9 )
      orbit(2)=opt_fun(10)
      orbit(3)=opt_fun(11)
      orbit(4)=opt_fun(12)
      orbit(5)=opt_fun(13)
      orbit(6)=opt_fun(14)
      disp(1) =opt_fun(15)
      disp(2) =opt_fun(16)
      disp(3) =opt_fun(17)
      disp(4) =opt_fun(18)
      disp(5) =zero
      disp(6) =one
      rmat(1,1)=opt_fun(29)
      rmat(1,2)=opt_fun(30)
      rmat(2,1)=opt_fun(31)
      rmat(2,2)=opt_fun(32)

!---- Maximum and r.m.s. values.
      bxmax =betx
      dxmax =disp(1)
      bymax =bety
      dymax =disp(3)
      xcomax=zero
      ycomax=zero
      sigxco=zero
      sigyco=zero
      sigdx =zero
      sigdy =zero

!---- Loop over positions.
      cplxy = .false.
      cplxt = .false.
      iecnt=0
      betas = get_value('probe ','beta ')
      gammas= get_value('probe ','gamma ')
      centre_cptk=.false.
      i = restart_sequ()
 10   continue
      sector_sel = node_value('sel_sector ') .ne. zero .and. sectormap
      code = node_value('mad8_type ')
      el = node_value('l ')
      bv0 = node_value('dipole_bv ')
      bvk = node_value('other_bv ')
      n_align = node_al_errors(al_errors)
      if (n_align.ne.0)  then
        call tmali1(orbit,al_errors,betas,gammas,orbit,re)
        call twcptk(re,orbit)
        if (sectormap) call m66mpy(re,srmat,srmat)
      endif
      if(centre) centre_cptk=.true.
      call tmmap(code,.true.,.true.,orbit,fmap,ek,re,te)
      centre_cptk=.false.
      if(centre) then
        pos0=currpos
        currpos=currpos+el/two
        if(save.ne.0) call twfill(1,opt_fun,currpos, 1)
      endif
      if (fmap) then
        call twcptk(re,orbit)
        if (sectormap) call tmcat(.true.,re,te,srmat,stmat,srmat,stmat)
      endif
      if (n_align.ne.0)  then
        call tmali2(el,orbit,al_errors,betas,gammas,orbit,re)
        call twcptk(re,orbit)
        if (sectormap) call m66mpy(re,srmat,srmat)
      endif
      sumloc = sumloc + el
      if (sector_sel) call twwmap(sumloc, orbit)
      if(centre) then
        bxmax =max(opt_fun(3)      ,bxmax)
        bymax =max(opt_fun(6)      ,bymax)
        dxmax =max(abs(opt_fun(15)),dxmax)
        dymax =max(abs(opt_fun(17)),dymax)
        xcomax=max(abs(opt_fun(9 )),xcomax)
        ycomax=max(abs(opt_fun(11)),ycomax)
      else
        opt_fun(9 )=orbit(1)
        opt_fun(10)=orbit(2)
        opt_fun(11)=orbit(3)
        opt_fun(12)=orbit(4)
        opt_fun(13)=orbit(5)
        opt_fun(14)=orbit(6)
        currpos=currpos+el
      endif
      iecnt=iecnt+1
      bxmax =max(betx         ,bxmax)
      bymax =max(bety         ,bymax)
      dxmax =max(abs(disp(1)) ,dxmax)
      dymax =max(abs(disp(3)) ,dymax)
      xcomax=max(abs(orbit(1)),xcomax)
      ycomax=max(abs(orbit(3)),ycomax)
      sigxco=sigxco+orbit(1)**2
      sigyco=sigyco+orbit(3)**2
      sigdx =sigdx + disp(1)**2
      sigdy =sigdy + disp(3)**2
      if(save.ne.0.and..not.centre) call twfill(1,opt_fun,currpos,1)
      if(centre) then
        currpos=pos0+el
        opt_fun(2 )=currpos
        opt_fun(3 )=betx
        opt_fun(4 )=alfx
        opt_fun(5 )=amux
        opt_fun(6 )=bety
        opt_fun(7 )=alfy
        opt_fun(8 )=amuy
        opt_fun(9 )=orbit(1)
        opt_fun(10)=orbit(2)
        opt_fun(11)=orbit(3)
        opt_fun(12)=orbit(4)
        opt_fun(13)=orbit(5)
        opt_fun(14)=orbit(6)
        opt_fun(15)=disp(1)
        opt_fun(16)=disp(2)
        opt_fun(17)=disp(3)
        opt_fun(18)=disp(4)
        opt_fun(29)=rmat(1,1)
        opt_fun(30)=rmat(1,2)
        opt_fun(31)=rmat(2,1)
        opt_fun(32)=rmat(2,2)
      endif
      if(advance_node().ne.0) goto 10

!---- Compute summary.
      wgt = max(iecnt, 1)
      sigxco=sqrt(sigxco / wgt)
      sigyco=sqrt(sigyco / wgt)
      sigdx =sqrt(sigdx / wgt)
      sigdy =sqrt(sigdy / wgt)
      cosmux=(rt(1,1) + rt(2,2)) / two
      cosmuy=(rt(3,3) + rt(4,4)) / two

!---- Warning messages.
      if (cplxt.or.dorad) then
        write (msg, 910)
        call aawarn('TWCPGO: ',msg)
      endif

  910 format('TWISS uses the RF system or synchrotron radiation ',      &
     &'only to find the closed orbit.'/                                 &
     &'for optical calculations it ignores both.')

      end
      subroutine twcptk(re,orbit)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Track coupled lattice functions.                                   *
! Input:                                                               *
!   re(6,6)  (double)   transfer matrix of element.                    *
!   rt(6,6)  (double)   one turn transfer matrix.                      *
!   orbit(6) (double)   closed orbit                                   *
!----------------------------------------------------------------------*
      include 'twiss0.fi'
      include 'twissl.fi'
      include 'twissa.fi'
      include 'twissc.fi'
      include 'twissotm.fi'
      integer i,i1,i2,j
      double precision re(6,6),orbit(6),rw0(6,6),rwi(6,6),rc(6,6),      &
     &rmat0(2,2),a(2,2),adet,b(2,2),c(2,2),dt(6),tempa,tempb,alfx0,     &
     &alfy0,betx0,bety0,amux0,amuy0,zero,one
      parameter(zero=0d0,one=1d0)

!---- Dispersion.
      call dzero(dt,6)
      do i = 1, 6
        do j = 1, 6
          dt(i) = dt(i) + re(i,j) * disp(j)
        enddo
      enddo
      if(.not.centre.or.centre_cptk) then
        opt_fun(15)=dt(1)
        opt_fun(16)=dt(2)
        opt_fun(17)=dt(3)
        opt_fun(18)=dt(4)
      endif
      if(centre_cptk) then
        alfx0=alfx
        alfy0=alfy
        betx0=betx
        bety0=bety
        amux0=amux
        amuy0=amuy
        call dcopy(rmat,rmat0,4)
        if(rmatrix) call dcopy(rw,rw0,36)
      else
        call dcopy(dt,disp,6)
      endif

!---- Auxiliary matrices.
      a(1,1) = re(1,1) - (re(1,3) * rmat(1,1) + re(1,4) * rmat(2,1))
      a(1,2) = re(1,2) - (re(1,3) * rmat(1,2) + re(1,4) * rmat(2,2))
      a(2,1) = re(2,1) - (re(2,3) * rmat(1,1) + re(2,4) * rmat(2,1))
      a(2,2) = re(2,2) - (re(2,3) * rmat(1,2) + re(2,4) * rmat(2,2))
      b(1,1) = re(3,1) - (re(3,3) * rmat(1,1) + re(3,4) * rmat(2,1))
      b(1,2) = re(3,2) - (re(3,3) * rmat(1,2) + re(3,4) * rmat(2,2))
      b(2,1) = re(4,1) - (re(4,3) * rmat(1,1) + re(4,4) * rmat(2,1))
      b(2,2) = re(4,2) - (re(4,3) * rmat(1,2) + re(4,4) * rmat(2,2))
      c(1,1) = re(3,3) + (re(3,1) * rmat(2,2) - re(3,2) * rmat(2,1))
      c(1,2) = re(3,4) - (re(3,1) * rmat(1,2) - re(3,2) * rmat(1,1))
      c(2,1) = re(4,3) + (re(4,1) * rmat(2,2) - re(4,2) * rmat(2,1))
      c(2,2) = re(4,4) - (re(4,1) * rmat(1,2) - re(4,2) * rmat(1,1))

!---- Track R matrix.
      adet = a(1,1) * a(2,2) - a(1,2) * a(2,1)
      rmat(1,1) = - (b(1,1) * a(2,2) - b(1,2) * a(2,1)) / adet
      rmat(1,2) =   (b(1,1) * a(1,2) - b(1,2) * a(1,1)) / adet
      rmat(2,1) = - (b(2,1) * a(2,2) - b(2,2) * a(2,1)) / adet
      rmat(2,2) =   (b(2,1) * a(1,2) - b(2,2) * a(1,1)) / adet

!---- Cummulative R matrix and one-turn map at element location.
      if(rmatrix) then
        call m66mpy(re,rw,rw)
        call m66inv(rw,rwi)
        call m66mpy(rotm,rw,rc)
        call m66mpy(rwi,rc,rc)
      endif

!---- Mode 1.
      tempb = a(1,1) * betx - a(1,2) * alfx
      tempa = a(2,1) * betx - a(2,2) * alfx
      alfx = - (tempa * tempb + a(1,2) * a(2,2)) / (adet * betx)
      betx =   (tempb * tempb + a(1,2) * a(1,2)) / (adet * betx)
      amux = amux + atan2(a(1,2),tempb)

!---- Mode 2.
      tempb = c(1,1) * bety - c(1,2) * alfy
      tempa = c(2,1) * bety - c(2,2) * alfy
      alfy = - (tempa * tempb + c(1,2) * c(2,2)) / (adet * bety)
      bety =   (tempb * tempb + c(1,2) * c(1,2)) / (adet * bety)
      amuy = amuy + atan2(c(1,2),tempb)

      if(.not.centre.or.centre_cptk) then
        opt_fun(3 )=betx
        opt_fun(4 )=alfx
        opt_fun(5 )=amux
        opt_fun(6 )=bety
        opt_fun(7 )=alfy
        opt_fun(8 )=amuy
        opt_fun(29)=rmat(1,1)
        opt_fun(30)=rmat(1,2)
        opt_fun(31)=rmat(2,1)
        opt_fun(32)=rmat(2,2)
      endif
      if(rmatrix) then
        do i1=1,6
          do i2=1,6
            opt_fun(33+(i1-1)*6+i2)=rc(i1,i2)
          enddo
        enddo
      endif
      if(centre_cptk) then
        opt_fun(9 )=orbit(1)
        opt_fun(10)=orbit(2)
        opt_fun(11)=orbit(3)
        opt_fun(12)=orbit(4)
        opt_fun(13)=orbit(5)
        opt_fun(14)=orbit(6)
        alfx=alfx0
        alfy=alfy0
        betx=betx0
        bety=bety0
        amux=amux0
        amuy=amuy0
        call dcopy(rmat0,rmat,4)
        if(rmatrix) call dcopy(rw0,rw,36)
      endif

      end
      subroutine twbtin(rt,tt)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Initial values of Chromatic functions.                             *
! Input:                                                               *
!   rt(6,6)   (double)  transfer matrix.                               *
!   tt(6,6,6) (double)  second order terms.                            *
!----------------------------------------------------------------------*
      include 'twiss0.fi'
      include 'twissa.fi'
      include 'twissc.fi'
      logical stabx,staby
      integer i,k,j
      double precision rt(6,6),tt(6,6,6),disp0(6),ddisp0(6),rtp(6,6),   &
     &sinmu2,bx,ax,by,ay,eps,temp,aux(6),zero,one,two,fourth
      parameter(eps=1d-8,zero=0d0,one=1d0,two=2d0,fourth=0.25d0)

!---- Initialization
      betx   =opt_fun0(3 )
      alfx   =opt_fun0(4 )
      amux   =opt_fun0(5 )
      bety   =opt_fun0(6 )
      alfy   =opt_fun0(7 )
      amuy   =opt_fun0(8 )
      wx     =opt_fun0(19)
      phix   =opt_fun0(20)
      dmux   =opt_fun0(21)
      wy     =opt_fun0(22)
      phiy   =opt_fun0(23)
      dmuy   =opt_fun0(24)

!---- Initial dispersion.
      call twdisp(rt,rt(1,6),disp0)
      disp0(5) = zero
      disp0(6) = one

!---- Derivative of transfer matrix w.r.t. delta(p)/p.
      call dzero(aux,6)
      do i = 1, 6
        do k = 1, 6
          temp = zero
          do j = 1, 6
            temp = temp + tt(i,j,k) * disp0(j)
          enddo
          aux(i) = aux(i) + temp * disp0(k)
          rtp(i,k) = two * temp
        enddo
      enddo

!---- Derivative of dispersion.
      call twdisp(rt,aux,ddisp0)
      ddisp0(5) = zero
      ddisp0(6) = zero

      call dcopy(disp0,disp,6)
      call dcopy(ddisp0,ddisp,6)

!---- Horizontal motion.
      cosmux = (rt(1,1) + rt(2,2)) / two
      stabx = abs(cosmux) .lt. one
      if (stabx) then
        sinmu2 = - rt(1,2)*rt(2,1) - fourth*(rt(1,1) - rt(2,2))**2
        if (sinmu2.lt.0) sinmu2 = eps
        sinmux = sign(sqrt(sinmu2), rt(1,2))
        betx = rt(1,2) / sinmux
        alfx = (rt(1,1) - rt(2,2)) / (two * sinmux)
        bx = rtp(1,2) / rt(1,2) +                                       &
     &       (rtp(1,1) + rtp(2,2)) * cosmux / (two * sinmu2)
        ax = (rtp(1,1) - rtp(2,2)) / (two * sinmux) -                   &
     &       alfx * rtp(1,2) / rt(1,2)
        wx = sqrt(bx**2 + ax**2)
        if (wx.gt.eps) phix = atan2(ax,bx)
      endif

!---- Vertical motion.
      cosmuy = (rt(3,3) + rt(4,4)) / two
      staby = abs(cosmuy) .lt. one
      if (staby) then
        sinmu2 = - rt(3,4)*rt(4,3) - fourth*(rt(3,3) - rt(4,4))**2
        if (sinmu2.lt.0) sinmu2 = eps
        sinmuy = sign(sqrt(sinmu2), rt(3,4))
        bety = rt(3,4) / sinmuy
        alfy = (rt(3,3) - rt(4,4)) / (two * sinmuy)
        by = rtp(3,4) / rt(3,4) +                                       &
     &       (rtp(3,3) + rtp(4,4)) * cosmuy / (two * sinmu2)
        ay = (rtp(3,3) - rtp(4,4)) / (two * sinmuy) -                   &
     &       alfy * rtp(3,4) / rt(3,4)
        wy = sqrt(by**2 + ay**2)
        if (wy.gt.eps) phiy = atan2(ay,by)
      endif

!---- Fill optics function array
      opt_fun0(19)=wx
      opt_fun0(20)=phix
      opt_fun0(22)=wy
      opt_fun0(23)=phiy
      opt_fun0(25)=ddisp(1)
      opt_fun0(26)=ddisp(2)
      opt_fun0(27)=ddisp(3)
      opt_fun0(28)=ddisp(4)

      end
      subroutine twchgo
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Track Chromatic functions.                                         *
!----------------------------------------------------------------------*
      include 'twiss0.fi'
      include 'twissl.fi'
      include 'twissa.fi'
      include 'twissc.fi'
      logical fmap,cplxy,cplxt,dorad
      integer i,code,save,restart_sequ,advance_node,get_option,n_align, &
     &node_al_errors
      double precision orbit(6),ek(6),re(6,6),te(6,6,6),                &
     &al_errors(align_max),deltap,el,betas,gammas,node_value,get_value, &
     &zero,one
      parameter(zero=0d0,one=1d0)
      character*120 msg

!---- If save requested reset table
      save=get_option('twiss_save ')
      if(save.ne.0) call reset_count(table_name)
      deltap = get_value('probe ','deltap ')
      dorad = get_value('probe ','radiate ').ne.zero
      centre = get_value('twiss ','centre ').ne.zero

!---- Initial values for lattice functions.
      orbit(1) =opt_fun0(9 )
      orbit(2) =opt_fun0(10)
      orbit(3) =opt_fun0(11)
      orbit(4) =opt_fun0(12)
      orbit(5) =opt_fun0(13)
      orbit(6) =opt_fun0(14)
      disp(1)  =opt_fun0(15)
      disp(2)  =opt_fun0(16)
      disp(3)  =opt_fun0(17)
      disp(4)  =opt_fun0(18)
      disp(5)  =zero
      disp(6)  =one
      call dzero(te,216)

!---- Initial values for chromatic functions.
      opt_fun(19)=wx
      opt_fun(20)=phix
      opt_fun(21)=dmux
      opt_fun(22)=wy
      opt_fun(23)=phiy
      opt_fun(24)=dmuy
      opt_fun(25)=ddisp(1)
      opt_fun(26)=ddisp(2)
      opt_fun(27)=ddisp(3)
      opt_fun(28)=ddisp(4)
      synch_1 = zero
      synch_2 = zero
      synch_3 = zero
      synch_4 = zero
      synch_5 = zero

!---- Loop over positions.
      cplxy = .false.
      cplxt = .false.

      betas = get_value('probe ','beta ')
      gammas= get_value('probe ','gamma ')
      centre_bttk=.false.
      i = restart_sequ()
 10   continue
      el = node_value('l ')
      code = node_value('mad8_type ')

!---- Physical element.
      n_align = node_al_errors(al_errors)
      if (n_align.ne.0)  then
        call tmali1(orbit,al_errors,betas,gammas,orbit,re)
        call twbttk(re,te)
      endif
      if(centre) centre_bttk=.true.
      call tmmap(code,.true.,.true.,orbit,fmap,ek,re,te)
      centre_bttk=.false.
      if(save.ne.0.and.centre) call twfill(2,opt_fun,zero,1)
      if (fmap) then
        call twbttk(re,te)
      endif
      if (n_align.ne.0)  then
        call tmali2(el,orbit,al_errors,betas,gammas,orbit,re)
        call twbttk(re,te)
      endif
      if(save.ne.0.and..not.centre) call twfill(2,opt_fun,zero,1)
      if(centre) then
        opt_fun(5)=amux
        opt_fun(8)=amuy
        opt_fun(19)=wx
        opt_fun(20)=phix
        opt_fun(21)=dmux
        opt_fun(22)=wy
        opt_fun(23)=phiy
        opt_fun(24)=dmuy
        opt_fun(25)=ddisp(1)
        opt_fun(26)=ddisp(2)
        opt_fun(27)=ddisp(3)
        opt_fun(28)=ddisp(4)
      endif
      if (advance_node().ne.0)  goto 10

!---- Warning, if system is coupled.
      if (cplxy) then
        write (msg, 910) deltap
        call aawarn('TWCHGO: ',msg)
      endif
      if (cplxt.or.dorad) then
        write (msg, 920)
        call aawarn('TWCHGO: ',msg)
      endif

  910 format('TWISS found transverse coupling for delta(p)/p =',f12.6/  &
     &'chromatic functions may be wrong.'/' ')
  920 format('TWISS uses the RF system or synchrotron radiation ',      &
     &'only to find the closed orbit.'/                                 &
     &'for optical calculations it ignores both.')

      end
      subroutine twbttk(re,te)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Track lattice functions, including chromatic effects.              *
! Input:                                                               *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second order terms.                            *
!----------------------------------------------------------------------*
      include 'twiss0.fi'
      include 'twissl.fi'
      include 'twissa.fi'
      include 'twissc.fi'
      integer save,i,j,k,get_option
      double precision re(6,6),te(6,6,6),aux(6),auxp(6),ax1,ax2,ay1,ay2,&
     &bx1,bx2,by1,by2,proxim,rep(6,6),t2,ta,tb,temp,tg,fre(6,6),        &
     &frep(6,6),curlyh,detl,f,rhoinv,blen,alfx0,alfy0,betx0,bety0,amux0,&
     &amuy0,wx0,wy0,dmux0,dmuy0,rmat0(2,2),node_value,eps,zero,one,two
      parameter(eps=1d-8,zero=0d0,one=1d0,two=2d0)

!---- Create internal table for lattice functions if requested
      save=get_option('twiss_save ')

!---- Tor: needed for synchrotron integrals
      blen=node_value('blen ')
      rhoinv=node_value('rhoinv ')

!---- Synchrotron integrals before element.
      if(.not.centre_bttk) then
        curlyh = disp(1)**2 * (one + alfx**2) / betx                    &
     &  + two*disp(1)*disp(2)*alfx + disp(2)**2*betx
        synch_1 = synch_1 + disp(1) * rhoinv * blen/two
        synch_2 = synch_2 + rhoinv**2 * blen/two
        synch_3 = synch_3 + abs(rhoinv**3) * blen/two
        synch_5 = synch_5 + curlyh * abs(rhoinv**3) * blen/two
      endif

      call dzero(aux,6)
      call dzero(auxp,6)
      do i = 1, 6
        do k = 1, 6
          temp = zero
          do j = 1, 6
            temp = temp + te(i,j,k)*disp(j)
          enddo
          aux(i) = aux(i) + re(i,k)*disp(k)
          auxp(i) = auxp(i) + temp*disp(k) + re(i,k)*ddisp(k)
          rep(i,k) = two*temp
        enddo
      enddo
      if(.not.centre_bttk) then
        call dcopy(aux,disp,6)
        call dcopy(auxp,ddisp,6)
      else
        alfx0=alfx
        alfy0=alfy
        betx0=betx
        bety0=bety
        amux0=amux
        amuy0=amuy
        wx0=wx
        wy0=wy
        dmux0=dmux
        dmuy0=dmuy
        do i=1,2
          do j=1,2
            rmat0(i,j)=rmat(i,j)
          enddo
        enddo
      endif

!---- Tor: modified to cancel energy change
      disp(6) = one

!---- Tor/MDW: scale by square root of the determinant of the
!     longitudinal 2x2 part of the R-matrix
      detl = re(5,5)*re(6,6) - re(5,6)*re(6,5)
      f = one / sqrt(detl)
      call m66scl(f,re,fre)
      call m66scl(f,rep,frep)

!---- Track horizontal functions including energy scaling.
      tb = fre(1,1)*betx - fre(1,2)*alfx
      ta = fre(2,1)*betx - fre(2,2)*alfx
      t2 = tb**2 + fre(1,2)**2
      tg = fre(1,1)*alfx - fre(1,2)*(one + alfx**2) / betx

!---- Linear functions.
      alfx = - (tb*ta + fre(1,2)*fre(2,2)) / betx
      betx = t2 / betx
      amux = amux + atan2(fre(1,2), tb)
      bx1 = wx*cos(phix)
      ax1 = wx*sin(phix)
      bx2 = ((tb**2 - fre(1,2)**2)*bx1                                  &
     &- two*tb*fre(1,2)*ax1) / t2                                       &
     &+ two*(tb*frep(1,1) - tg*frep(1,2)) / betx
      ax2 = ((tb**2 - fre(1,2)**2)*ax1                                  &
     &+ two*tb*fre(1,2)*bx1) / t2                                       &
     &- (tb*(frep(1,1)*alfx + frep(2,1)*betx)                           &
     &- tg*(frep(1,2)*alfx + frep(2,2)*betx)                            &
     &+ fre(1,1)*frep(1,2) - fre(1,2)*frep(1,1)) / betx
      wx = sqrt(ax2**2 + bx2**2)
      if (wx.gt.eps) phix = proxim(atan2(ax2, bx2), phix)
      dmux = dmux + fre(1,2)*(fre(1,2)*ax1 - tb*bx1) / t2               &
     &+ (fre(1,1)*frep(1,2) - fre(1,2)*frep(1,1)) / betx

!---- Track vertical functions including energy scaling.
      tb = fre(3,3)*bety - fre(3,4)*alfy
      ta = fre(4,3)*bety - fre(4,4)*alfy
      t2 = tb**2 + fre(3,4)**2
      tg = fre(3,3)*alfy - fre(3,4)*(one + alfy**2) / bety

!---- Linear functions.
      alfy = - (tb*ta + fre(3,4)*fre(4,4)) / bety
      bety = t2 / bety
      amuy = amuy + atan2(fre(3,4), tb)

      by1 = wy*cos(phiy)
      ay1 = wy*sin(phiy)
      by2 = ((tb**2 - fre(3,4)**2)*by1                                  &
     &- two*tb*fre(3,4)*ay1) / t2                                       &
     &+ two*(tb*frep(3,3) - tg*frep(3,4)) / bety
      ay2 = ((tb**2 - fre(3,4)**2)*ay1                                  &
     &+ two*tb*fre(3,4)*by1) / t2                                       &
     &- (tb*(frep(3,3)*alfy + frep(4,3)*bety)                           &
     &- tg*(frep(3,4)*alfy + frep(4,4)*bety)                            &
     &+ fre(3,3)*frep(3,4) - fre(3,4)*frep(3,3)) / bety
      wy = sqrt(ay2**2 + by2**2)
      if (wy.gt.eps) phiy = proxim(atan2(ay2, by2), phiy)
      dmuy = dmuy + fre(3,4)*(fre(3,4)*ay1 - tb*by1) / t2               &
     &+ (fre(3,3)*frep(3,4) - fre(3,4)*frep(3,3)) / bety

!---- Fill optics function array
      if(.not.centre.or.centre_bttk) then
        opt_fun(19)=wx
        opt_fun(20)=phix
        opt_fun(21)=dmux
        opt_fun(22)=wy
        opt_fun(23)=phiy
        opt_fun(24)=dmuy
        opt_fun(25)=auxp(1)
        opt_fun(26)=auxp(2)
        opt_fun(27)=auxp(3)
        opt_fun(28)=auxp(4)
      endif
      if(centre_bttk) then
        alfx=alfx0
        alfy=alfy0
        betx=betx0
        bety=bety0
        amux=amux0
        amuy=amuy0
        wx=wx0
        wy=wy0
        dmux=dmux0
        dmuy=dmuy0
        do i=1,2
          do j=1,2
            rmat(i,j)=rmat0(i,j)
          enddo
        enddo
      endif

!---- Synchrotron integrals after element.
      if(.not.centre_bttk) then
        curlyh = disp(1)**2 * (one + alfx**2) / betx                    &
     &  + two*disp(1)*disp(2)*alfx + disp(2)**2*betx
        synch_1 = synch_1 + disp(1) * rhoinv * blen/two
        synch_2 = synch_2 + rhoinv**2 * blen/two
        synch_3 = synch_3 + abs(rhoinv**3) * blen/two
        synch_5 = synch_5 + curlyh * abs(rhoinv**3) * blen/two
      endif

      end
      subroutine tw_summ(rt,tt)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Compute summary data for TWISS and OPTICS commands.                *
! Input:                                                               *
!   rt(6,6)   (double)  one turn transfer matrix.                      *
!   tt(6,6,6) (double)  second order terms.                            *
!----------------------------------------------------------------------*
      include 'twiss0.fi'
      include 'twissa.fi'
      include 'twissc.fi'
      integer i,inval,get_option
      double precision rt(6,6),tt(6,6,6),deltap,sd,betas,gammas,        &
     &disp0(6),detl,f,tb,frt(6,6),frtp(6,6),rtp(6,6),t2,bx0,ax0,by0,ay0,&
     &sx,sy,orbit5,twopi,get_variable,get_value,zero,one,two
      parameter(zero=0d0,one=1d0,two=2d0)

!---- Initialization chromatic part
      twopi=get_variable('twopi ')
      call dzero(rtp,36)
      call dzero(frt,36)
      call dzero(frtp,36)
      deltap = get_value('probe ','deltap ')
      betas = get_value('probe ','beta ')
      gammas= get_value('probe ','gamma ')
      inval = get_option('twiss_inval ')
      disp0(1)=opt_fun0(15)
      disp0(2)=opt_fun0(16)
      disp0(3)=opt_fun0(17)
      disp0(4)=opt_fun0(18)
      wx      =opt_fun(19)
      phix    =opt_fun(20)
      dmux    =opt_fun(21)
      wy      =opt_fun(22)
      phiy    =opt_fun(23)
      dmuy    =opt_fun(24)
      ddisp(1)=opt_fun(25)
      ddisp(2)=opt_fun(26)
      ddisp(3)=opt_fun(27)
      ddisp(4)=opt_fun(28)

!---- Summary data for non-periodic case.
      if(inval.ne.0) then
        detl = rt(5,5) * rt(6,6) - rt(5,6) * rt(6,5)
        f = one / sqrt(detl)
        call m66scl(f,rt,frt)
        call m66scl(f,rtp,frtp)
        tb = frt(1,1) * betx - frt(1,2) * alfx
        t2 = tb**2 + frt(1,2)**2
        bx0 = wx * cos(phix)
        ax0 = wx * sin(phix)
        xix = dmux + frt(1,2) * (frt(1,2) * ax0 - tb * bx0) / t2        &
     &  + (frt(1,1) * frtp(1,2) - frt(1,2) * frtp(1,1)) / betx
        xix = xix / twopi
        tb = frt(3,3) * bety - frt(3,4) * alfy
        t2 = tb**2 + frt(3,4)**2
        by0 = wy * cos(phiy)
        ay0 = wy * sin(phiy)
        xiy = dmuy + frt(3,4) * (frt(3,4) * ay0 - tb * by0) / t2        &
     &  + (frt(3,3) * frtp(3,4) - frt(3,4) * frtp(3,3)) / bety
        xiy = xiy / twopi
        alfa  =zero
        gamtr =zero
        cosmux=zero
        cosmuy=zero

!---- Summary data for periodic case.
      else
        sd = rt(5,6)
        sx = tt(1,1,6) + tt(2,2,6)
        sy = tt(3,3,6) + tt(4,4,6)
        do i = 1, 4
          sd = sd + rt(5,i) * disp(i)
          sx = sx + (tt(1,1,i) + tt(2,2,i)) * disp0(i)
          sy = sy + (tt(3,3,i) + tt(4,4,i)) * disp0(i)
        enddo
        xix = - sx / (twopi * sinmux)
        xiy = - sy / (twopi * sinmuy)
        eta = - sd * betas**2 / suml
        alfa = one / gammas**2 + eta
        if (alfa.gt.zero) then
          gamtr = sqrt(one / alfa)
        else if (alfa .eq. zero) then
          gamtr = zero
        else
          gamtr = - sqrt(- one / alfa)
        endif
      endif

!---- Initialization transverse part
      suml    = currpos-get_value('sequence ','range_start ')
      betx    = opt_fun0(3)
      alfx    = opt_fun0(4)
      amux    = opt_fun(5)
      bety    = opt_fun0(6)
      alfy    = opt_fun0(7)
      amuy    = opt_fun(8)
      qx = amux / twopi
      qy = amuy / twopi

!---- Adjust values
      orbit5 = -opt_fun0(13)
      xcomax = xcomax
      sigxco = sigxco
      ycomax = ycomax
      sigyco = sigyco
      phix = phix/twopi
      phiy = phiy/twopi
      dmux = dmux/twopi
      dmuy = dmuy/twopi

!---- Fill summary table
      call double_to_table('summ ','length ' ,suml)
      call double_to_table('summ ','deltap ' ,deltap)
      call double_to_table('summ ','orbit5 ' ,orbit5)
      call double_to_table('summ ','alfa '   ,alfa)
      call double_to_table('summ ','gammatr ',gamtr)
      call double_to_table('summ ','q1 '     ,qx)
      call double_to_table('summ ','dq1 '    ,xix)
      call double_to_table('summ ','betxmax ',bxmax)
      call double_to_table('summ ','dxmax '  ,dxmax)
      call double_to_table('summ ','dxrms '  ,sigdx)
      call double_to_table('summ ','xcomax ' ,xcomax)
      call double_to_table('summ ','xcorms ' ,sigxco)
      call double_to_table('summ ','q2 '     ,qy)
      call double_to_table('summ ','dq2 '    ,xiy)
      call double_to_table('summ ','betymax ',bymax)
      call double_to_table('summ ','dymax '  ,dymax)
      call double_to_table('summ ','dyrms '  ,sigdy)
      call double_to_table('summ ','ycomax ' ,ycomax)
      call double_to_table('summ ','ycorms ' ,sigyco)

!---- Augment table summ
      call augment_count('summ ')

      end
      subroutine tmmap(code,fsec,ftrk,orbit,fmap,ek,re,te)
      implicit none
!----------------------------------------------------------------------*
! purpose:                                                             *
!   transport map for a complete element.                              *
!   optionally, follow orbit.                                          *
! input:                                                               *
!   code                element type code                              *
!   fsec      (logical) if true, return second order terms.            *
!   ftrk      (logical) if true, track orbit.                          *
! input/output:                                                        *
!   orbit(6)  (double)  closed orbit.                                  *
! output:                                                              *
!   fmap      (logical) if true, element has a map.                    *
!   bval                basic element parameters                       *
!   fval                element force parameters                       *
!   ek(6)     (double)  kick due to element.                           *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second-order terms.                            *
!----------------------------------------------------------------------*
      integer code
      logical fsec, ftrk, fmap
      double precision node_value,el,orbit(6),ek(6),re(6,6),te(6,6,6)

!---- Initialization
      call dzero(ek,6)
      call m66one(re)
      call dzero(te,216)
      fmap=.false.
      el = node_value('l ')

!---- Select element type.
      go to ( 10,  20,  30,  40,  50,  60,  70,  80,  90, 100,          &
     &110, 120, 130, 140, 150, 160, 170, 180, 190, 200,                 &
     &210, 220, 230, 240, 250, 260, 270, 280, 290, 300,                 &
     &310, 310, 310, 310, 310, 310, 310, 310, 310, 310), code

!---- Drift space, monitor, collimator, or beam instrument.
   10 continue
  170 continue
  180 continue
  190 continue
  200 continue
  210 continue
  240 continue
      call tmdrf(fsec,ftrk,orbit,fmap,el,ek,re,te)
      go to 500

!---- Bending magnet.
   20 continue
   30 continue
      call tmbend(ftrk,orbit,fmap,el,ek,re,te)
      go to 500

!---- Arbitrary matrix.
   40 continue
      go to 500

!---- Quadrupole.
   50 continue
      call tmquad(fsec,ftrk,orbit,fmap,el,ek,re,te)
      go to 500

!---- Sextupole.
   60 continue
      call tmsext(fsec,ftrk,orbit,fmap,el,ek,re,te)
      go to 500

!---- Octupole.
   70 continue
      call tmoct(fsec,ftrk,orbit,fmap,el,ek,re,te)
      go to 500

!---- Multipole.
   80 continue
      call tmmult(fsec,ftrk,orbit,fmap,re,te)
      go to 500

!---- Solenoid.
   90 continue
      call tmsol(fsec,ftrk,orbit,fmap,el,ek,re,te)
      go to 500

!---- RF cavity.
  100 continue
      call tmrf(fsec,ftrk,orbit,fmap,el,ek,re,te)
      go to 500

!---- Electrostatic separator.
  110 continue
      call tmsep(fsec,ftrk,orbit,fmap,el,ek,re,te)
      go to 500

!---- Rotation around s-axis.
  120 continue
      call tmsrot(ftrk,orbit,fmap,ek,re,te)
      go to 500

!---- Rotation around y-axis.
  130 continue
      call tmyrot(ftrk,orbit,fmap,ek,re,te)
      go to 500

!---- Correctors.
  140 continue
  150 continue
  160 continue
      call tmcorr(fsec,ftrk,orbit,fmap,el,ek,re,te)
      go to 500

!---- Beam-beam.
 220  continue
!     (Particles/bunch taken for the opposite beam).
      call tmbb(fsec,ftrk,orbit,fmap,re,te)
      go to 500

!---- Lump.
  230 continue
      go to 500

!---- Marker.
  250 continue
      go to 500

!---- General bend (dipole, quadrupole, and skew quadrupole).
  260 continue
      go to 500

!---- LCAV cavity.
  270 continue

!---- Reserved.
  280 continue
  290 continue
  300 continue
      go to 500

!---- User-defined elements.
  310 continue

!---- End of element calculation;
  500 continue

      end
      subroutine tmbend(ftrk,orbit,fmap,el,ek,re,te)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for sector bending magnets                           *
! Input:                                                               *
!   ftrk      (logical) if true, track orbit.                          *
! Input/output:                                                        *
!   orbit(6)  (double)  closed orbit.                                  *
! Output:                                                              *
!   fmap      (logical) if true, element has a map.                    *
!   el        (double)  element length.                                *
!   ek(6)     (double)  kick due to element.                           *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second-order terms.                            *
!----------------------------------------------------------------------*
      include 'twissl.fi'
      logical ftrk,fmap,cplxy,dorad
      integer nd,n_ferr,node_fd_errors,maxmul
      parameter(maxmul=20)
      double precision orbit(6),f_errors(0:50),ek(6),re(6,6),te(6,6,6), &
     &rw(6,6),tw(6,6,6),x,y,deltap,field(2,0:maxmul),fintx,el,tilt,e1,  &
     &e2,sk1,sk2,h1,h2,hgap,fint,sks,an,h,dh,corr,ek0(6),ct,st,hx,hy,   &
     &rfac,arad,gamma,pt,rhoinv,blen,node_value,get_value,sk0,sk0s,bv0, &
     &bvk,el0,orbit0(6),zero,one,two,three
      parameter(zero=0d0,one=1d0,two=2d0,three=3d0)

!---- Initialize.
      call dzero(ek0,6)
      call m66one(rw)
      call dzero(tw,216)

!---- Test for non-zero length.
      fmap = el .ne. zero
      if (fmap) then
        n_ferr = node_fd_errors(f_errors)
        bv0 = node_value('dipole_bv ')
        bvk = node_value('other_bv ')
        arad = get_value('probe ','arad ')
        deltap = get_value('probe ','deltap ')
        gamma = get_value('probe ','gamma ')
        dorad = get_value('probe ','radiate ') .ne. zero
        an = node_value('angle ')
        sk0 = an / el
        sk0s = node_value('k0s ')
        if (sk0s .eq. zero)  then
          tilt = zero
        else
          tilt = atan2(sk0s, sk0)
          sk0 = sqrt(sk0**2 + sk0s**2)
          an = sk0 * el
        endif
        an = bv0 * an
        sk0 = bv0 * sk0
        sk0s = bv0 * sk0s
        e1 = bv0 * node_value('e1 ')
        e2 = bv0 * node_value('e2 ')
!--- bvk applied further down
        sk1 = node_value('k1 ')
        sk2 = node_value('k2 ')
        h1 = node_value('h1 ')
        h2 = node_value('h2 ')
        hgap = node_value('hgap ')
        fint = node_value('fint ')
        fintx = node_value('fintx ')
        sks = node_value('k3 ')
        h = an / el

!---- Apply field errors and change coefficients using DELTAP.
        if (n_ferr .gt. 0) then
          nd = n_ferr
          call dzero(field,nd)
          call dcopy(f_errors,field,n_ferr)
          dh = (- h * deltap + bv0 * field(1,0) / el) / (one + deltap)
          sk1 = (sk1 + field(1,1) / el) / (one + deltap)
          sk2 = (sk2 + field(1,2) / el) / (one + deltap)
          sks = (sks + field(2,1) / el) / (one + deltap)
        else
          dh = - h * deltap / (one + deltap)
          sk1 = sk1 / (one + deltap)
          sk2 = sk2 / (one + deltap)
          sks = sks / (one + deltap)
        endif
        sk1 = bvk * sk1
        sk2 = bvk * sk2
        sks = bvk * sks

!---- Half radiation effects at entrance.
        if (ftrk .and. dorad) then
          ct = cos(tilt)
          st = sin(tilt)
          x =   orbit(1) * ct + orbit(3) * st
          y = - orbit(1) * st + orbit(3) * ct
          hx = h + dh + sk1*(x - h*y**2/two) + sks*y +                  &
     &    sk2*(x**2 - y**2)/two
          hy = sks * x - sk1*y - sk2*x*y
          rfac = (arad * gamma**3 * el / three)                         &
     &    * (hx**2 + hy**2) * (one + h*x) * (one - tan(e1)*x)
          pt = orbit(6)
          orbit(2) = orbit(2) - rfac * (one + pt) * orbit(2)
          orbit(4) = orbit(4) - rfac * (one + pt) * orbit(4)
          orbit(6) = orbit(6) - rfac * (one + pt) ** 2
        endif

!---- Body of the dipole.
!---- centre option
        if(centre_cptk.or.centre_bttk) then
          el0=el/two
          call tmsect(.true.,el0,h,dh,sk1,sk2,ek,re,te)
!---- Fringe fields.
          corr = (h + h) * hgap * fint
          call tmfrng(.true.,h,sk1,e1,h1,one,corr,rw,tw)
          call tmcat1(.true.,ek,re,te,ek0,rw,tw,ek,re,te)
!---- Apply tilt.
          if (tilt .ne. zero) then
            call tmtilt(.true.,tilt,ek,re,te)
            cplxy = .true.
          endif
!---- Track orbit.
          if (ftrk) call tmtrak(ek,re,te,orbit,orbit0)
          if(centre_cptk) call twcptk(re,orbit0)
          if(centre_bttk) call twbttk(re,te)
        endif
!---- End
        call tmsect(.true.,el,h,dh,sk1,sk2,ek,re,te)

!---- Fringe fields.
        corr = (h + h) * hgap * fint
        call tmfrng(.true.,h,sk1,e1,h1,one,corr,rw,tw)
        call tmcat1(.true.,ek,re,te,ek0,rw,tw,ek,re,te)
!---- Tor: use FINTX if set
        if (fintx .gt. 0) then
          corr = (h + h) * hgap * fintx
        else
          corr = (h + h) * hgap * fint
        endif
        call tmfrng(.true.,h,sk1,e2,h2,-one,corr,rw,tw)
        call tmcat1(.true.,ek0,rw,tw,ek,re,te,ek,re,te)

!---- Apply tilt.
        if (tilt .ne. zero) then
          call tmtilt(.true.,tilt,ek,re,te)
          cplxy = .true.
        endif

!---- Track orbit.
        if (ftrk) then
          call tmtrak(ek,re,te,orbit,orbit)

!---- Half radiation effects at exit.
          if (dorad) then
            x =   orbit(1) * ct + orbit(3) * st
            y = - orbit(1) * st + orbit(3) * ct
            hx = h + dh + sk1*(x - h*y**2/two) + sks*y +                &
     &      sk2*(x**2 - y**2)/two
            hy = sks * x - sk1*y - sk2*x*y
            rfac = (arad * gamma**3 * el / three)                       &
     &      * (hx**2 + hy**2) * (one + h*x) * (one - tan(e2)*x)
            pt = orbit(6)
            orbit(2) = orbit(2) - rfac * (one + pt) * orbit(2)
            orbit(4) = orbit(4) - rfac * (one + pt) * orbit(4)
            orbit(6) = orbit(6) - rfac * (one + pt) ** 2
          endif
        endif
      endif

!---- Tor: set parameters for sychrotron integral calculations
      rhoinv = h
      blen = el

      end
      subroutine tmsect(fsec,el,h,dh,sk1,sk2,ek,re,te)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for a sector dipole without fringe fields.           *
! Input:                                                               *
!   fsec      (logical) if true, return second order terms.            *
!   el        (double)  element length.                                *
!   h         (double)  reference curvature of magnet.                 *
!   dh        (double)  dipole field error.                            *
!   sk1       (double)  quadrupole strength.                           *
!   sk2       (double)  sextupole strengh.                             *
! Output:                                                              *
!   ek(6)     (double)  kick due to dipole.                            *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second order terms.                            *
!----------------------------------------------------------------------*
      logical fsec
      double precision beta,gamma,dtbyds,bi,bi2,bi2gi2,cm,cp,cx,cy,cyy, &
     &dd,dh,difsq,dm,dp,dx,dyy,ek(6),el,fm,fp,fx,fyy,gx,h,h2,hx,re(6,6),&
     &sk1,sk2,sm,sp,sumsq,sx,sy,syy,t1,t116,t126,t166,t2,t216,t226,t266,&
     &t336,t346,t436,t446,t5,t516,t526,t566,te(6,6,6),xk,xkl,xklsq,xksq,&
     &xs6,y0,y1,y2,y2klsq,y2ksq,yk,ykl,yklsq,yksq,ys2,zc,zd,zf,zs,      &
     &get_value,zero,one,two,three,four,six,nine,twelve,fifteen,twty,   &
     &twty2,twty4,thty,foty2,fvty6,svty2,httwty,c1,c2,c3,c4,s1,s2,s3,s4,&
     &cg0,cg1,cg2,ch0,ch1,ch2
      parameter(zero=0d0,one=1d0,two=2d0,three=3d0,four=4d0,six=6d0,    &
     &nine=9d0,twelve=12d0,fifteen=15d0,twty=20d0,twty2=22d0,twty4=24d0,&
     &thty=30d0,foty2=42d0,fvty6=56d0,svty2=72d0,httwty=120d0,c1=one,   &
     &c2=one/two,c3=one/twty4,c4=one/720d0,s1=one,s2=one/six,           &
     &s3=one/httwty,s4=one/5040d0,cg0=one/twty,cg1=5d0/840d0,           &
     &cg2=21d0/60480d0,ch0=one/fvty6,ch1=14d0/4032d0,ch2=147d0/443520d0)

!---- Initialize.
      beta = get_value('probe ','beta ')
      gamma = get_value('probe ','gamma ')
      dtbyds = get_value('probe ','dtbyds ')
      bi = one / beta
      bi2 = bi * bi
      bi2gi2 = one / (beta * gamma) ** 2

!---- Horizontal.
      xksq = h**2 + sk1
      xk = sqrt(abs(xksq))
      xkl = xk * el
      xklsq = xksq * el**2
      if (abs(xklsq) .lt. 1e-2) then
        cx = (c1 - xklsq * (c2 - xklsq*c3))
        sx = (s1 - xklsq * (s2 - xklsq*s3)) * el
        dx = (c2 - xklsq * (c3 - xklsq*c4)) * el**2
        fx = (s2 - xklsq * (s3 - xklsq*s4)) * el**3
        gx = (cg0 - xklsq * (cg1 - xklsq*cg2)) * el**5
        hx = (ch0 - xklsq * (ch1 - xklsq*ch2)) * el**7
      else
        if (xklsq .gt. zero) then
          cx = cos(xkl)
          sx = sin(xkl) / xk
        else
          cx = cosh(xkl)
          sx = sinh(xkl) / xk
        endif
        dx = (one - cx) / xksq
        fx = (el  - sx) / xksq
        gx = (three*el - sx*(four-cx)) / (two*xksq**2)
        hx = (fifteen*el - sx*(twty2-nine*cx+two*cx**2)) / (six*xksq**3)
      endif
      re(1,1) = cx
      re(1,2) = sx
      re(1,6) = h * dx * bi
      re(2,1) = - xksq * sx
      re(2,2) = cx
      re(2,6) = h * sx * bi
      re(5,2) = - re(1,6)
      re(5,1) = - re(2,6)
      re(5,6) = el*bi2gi2 - h**2*fx*bi2
      ek(1) = - dh*dx
      ek(2) = - dh*sx
      ek(5) =   h*dh*fx*bi + el*dtbyds

!---- Vertical.
      yksq = - sk1
      yk = sqrt(abs(yksq))
      ykl = yk*el
      yklsq = yksq*el**2
      if (abs(yklsq) .lt. 1e-2) then
        cy = (c1 - yklsq * (c2 - yklsq*c3))
        sy = (s1 - yklsq * (s2 - yklsq*s3)) * el
      else if (yklsq .gt. zero) then
        cy = cos(ykl)
        sy = sin(ykl) / yk
      else
        cy = cosh(ykl)
        sy = sinh(ykl) / yk
      endif
      re(3,3) = cy
      re(3,4) = sy
      re(4,3) = - yksq * sy
      re(4,4) = cy
      ek(3)   = zero
      ek(4)   = zero

!---- Second-order terms.
      if (fsec) then
!---- Pure horizontal terms.
        xs6 = (sk2 + two*h*sk1) / six
        ys2 = (sk2 +     h*sk1) / two
        h2 = h / two
        t116 = xs6 * (three*sx*fx - dx**2) - h * sx**2
        t126 = xs6 * (sx*dx**2 - two*cx*gx) - h * sx * dx
        t166 = xs6 * (dx**3 - two*sx*gx) - h2 * dx**2
        t216 = xs6 * (three*cx*fx + sx*dx)
        t226 = xs6 * (three*sx*fx + dx**2)
        t266 = xs6 * (sx*dx**2 - two*cx*gx)
        t516 = h * xs6 * (three*dx*fx - four*gx) +                      &
     &  (sk1/two) * (fx + sx*dx)
        t526 = h * xs6 * (dx**3 - two*sx*gx) + (sk1/two) * dx**2
        t566 = h * xs6 * (three*hx - two*dx*gx) +                       &
     &  (sk1/two) * gx - fx
        t1 = (sk1/two) * (dx**2 - sx*fx) - dx
        t2 = (sk1/two) * (el*dx - fx)
        t5 = fx - sk1 * (gx - fx*dx / two)
        te(1,1,1) = - xs6 * (sx**2 + dx) - h2*xksq*sx**2
        te(1,1,2) = (- xs6*dx + h2*cx) * sx
        te(1,2,2) = (- xs6*dx + h2*cx) * dx
        te(1,1,6) = (- h2*t116 + (sk1/four)*el*sx) * bi
        te(1,2,6) = (- h2*t126 + (sk1/four) * (el*dx - fx) - sx/two) *bi
        te(1,6,6) = (- h**2*t166 + h*t1) * bi2 - h2 * dx * bi2gi2
        te(2,1,1) = - xs6 * (one + two*cx) * sx
        te(2,1,2) = - xs6 * (one + two*cx) * dx
        te(2,2,2) = - (two*xs6*dx + h2) * sx
        te(2,1,6) = (- h2*t216 - (sk1/four) * (sx - el*cx)) * bi
        te(2,2,6) = (- h2*t226 + (sk1/four) * el * sx) * bi
        te(2,6,6) = (- h**2*t266 + h*t2) * bi2 - h2 * sx * bi2gi2
        te(5,1,1) = (h2*xs6 * (sx*dx + three*fx) -                      &
     &  (sk1/four) * (el - cx*sx)) * bi
        te(5,1,2) = (h2*xs6*dx**2 + (sk1/four)*sx**2) * bi
        te(5,2,2) = (h*xs6*gx - sk1 * (fx - sx*dx) / four - sx/two) * bi
        te(5,1,6) = h2 * ((t516 - sk1 * (el*dx - fx) / two) * bi2 +     &
     &  sx * bi2gi2)
        te(5,2,6) = h2 * ((t526 - sk1 * (dx**2 - sx*fx) / two) * bi2 +  &
     &  dx * bi2gi2)
        te(5,6,6) = (h**2 * (t566 + t5) * bi2 +                         &
     &  (three/two) * (h**2*fx - el) * bi2gi2) * bi

!---- Mixed terms.
        y2ksq = four * yksq
        call tmfoc(el,y2ksq,cyy,syy,dyy,fyy)
        y2klsq = y2ksq * el**2
        if (max(abs(y2klsq),abs(xklsq)) .le. 1e-2) then
          y0 = one
          y1 = xklsq + y2klsq
          y2 = xklsq**2 + xklsq*y2klsq + y2klsq**2
          zc = (y0 - (y1 - y2 / thty) / twelve) * el**2 /   two
          zs = (y0 - (y1 - y2 / foty2) / twty) * el**3 /   six
          zd = (y0 - (y1 - y2 / fvty6) / thty) * el**4 /  twty4
          zf = (y0 - (y1 - y2 / svty2) / foty2) * el**5 / httwty
        else if (xksq .le. zero  .or.  yksq .le. zero) then
          dd = xksq - y2ksq
          zc = (cyy - cx) / dd
          zs = (syy - sx) / dd
          zd = (dyy - dx) / dd
          zf = (fyy - fx) / dd
        else
          sumsq = (xk/two + yk) ** 2
          difsq = (xk/two - yk) ** 2
          call tmfoc(el,sumsq,cp,sp,dp,fp)
          call tmfoc(el,difsq,cm,sm,dm,fm)
          zc = sp * sm / two
          zs = (sp*cm - cp*sm) / (four*xk*yk)
          if (xksq .gt. y2ksq) then
            zd = (dyy - zc) / xksq
            zf = (fyy - zs) / xksq
          else
            zd = (dx - zc) / y2ksq
            zf = (fx - zs) / y2ksq
          endif
        endif
        t336 = sk2 * (cy*zd - two*sk1*sy*zf) + h * sk1 * fx * sy
        t346 = sk2 * (sy*zd - two*cy*zf) + h * fx * cy
        t436 = two * ys2 * fx * cy - sk2 * sk1 * (sy*zd - two*cy*zf)
        t446 = two * ys2 * fx * sy - sk2 * (cy*zd - two*sk1*sy*zf)
        te(1,3,3) = + sk2*sk1*zd + ys2*dx
        te(1,3,4) = + sk2*zs/two
        te(1,4,4) = + sk2*zd - h2*dx
        te(2,3,3) = + sk2*sk1*zs + ys2*sx
        te(2,3,4) = + sk2*zc/two
        te(2,4,4) = + sk2*zs - h2*sx
        te(3,1,3) = + sk2*(cy*zc/two - sk1*sy*zs) + h2*sk1*sx*sy
        te(3,1,4) = + sk2*(sy*zc/two - cy*zs) + h2*sx*cy
        te(3,2,3) = + sk2*(cy*zs/two - sk1*sy*zd) + h2*sk1*dx*sy
        te(3,2,4) = + sk2*(sy*zs/two - cy*zd) + h2*dx*cy
        te(3,3,6) = (h2*t336 - sk1*el*sy/four) * bi
        te(3,4,6) = (h2*t346 - (sy + el*cy) / four) * bi
        te(4,1,3) = sk2*sk1*(cy*zs - sy*zc/two) + ys2*sx*cy
        te(4,1,4) = sk2*(sk1*sy*zs - cy*zc/two) + ys2*sx*sy
        te(4,2,3) = sk2*sk1*(cy*zd - sy*zs/two) + ys2*dx*cy
        te(4,2,4) = sk2*(sk1*sy*zd - cy*zs/two) + ys2*dx*sy
        te(4,3,6) = (h2*t436 + sk1 * (sy - el*cy) / four) * bi
        te(4,4,6) = (h2*t446 - sk1*el*sy/four) * bi
        te(5,3,3) = (- h*sk2*sk1*zf - h*ys2*fx + sk1*(el-cy*sy)/four)*bi
        te(5,3,4) = (- h*sk2*zd/two - sk1*sy**2/four) * bi
        te(5,4,4) = (- h*sk2*zf + h*h2*fx - (el + sy*cy)/four) * bi
        call tmsymm(te)

!---- Effect of dipole error.
        if (dh .ne. zero) then
          re(1,1) = re(1,1) + dh * t116
          re(1,2) = re(1,2) + dh * t126
          re(1,6) = re(1,6) + dh * (two*h*t166 - t1) * bi
          re(2,1) = re(2,1) + dh * (t216 - h*sx)
          re(2,2) = re(2,2) + dh * t226
          re(2,6) = re(2,6) + dh * (two*h*t266 - t2) * bi
          re(5,1) = re(5,1) - dh * t516 * bi
          re(5,2) = re(5,2) - dh * (t526 - dx) * bi
          re(5,6) = re(5,6) -                                           &
     &    dh * h * ((two*t566 + t5) * bi2 + fx * bi2gi2)
          re(3,3) = re(3,3) - dh * t336
          re(3,4) = re(3,4) - dh * t346
          re(4,3) = re(4,3) - dh * t436
          re(4,4) = re(4,4) - dh * t446
          ek(1) = ek(1) - dh**2 * t166
          ek(2) = ek(2) - dh**2 * t266
          ek(5) = ek(5) + dh**2 * t566 * bi
        endif
      endif

      end
      subroutine tmfoc(el,sk1,c,s,d,f)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Compute linear focussing functions.                                *
! Input:                                                               *
!   el        (double)  element length.                                *
!   sk1       (double)  quadrupole strength.                           *
! Output:                                                              *
!   c         (double)  cosine-like function.             c(k,l)       *
!   s         (double)  sine-like function.               s(k,l)       *
!   d         (double)  dispersion function.              d(k,l)       *
!   f         (double)  integral of dispersion function.  f(k,l)       *
!----------------------------------------------------------------------*
      double precision c,d,el,f,qk,qkl,qkl2,s,sk1,zero,one,two,six,     &
     &twelve,twty,thty,foty2
      parameter(zero=0d0,one=1d0,two=2d0,six=6d0,twelve=12d0,twty=20d0, &
     &thty=30d0,foty2=42d0)

!---- Initialize.
      qk = sqrt(abs(sk1))
      qkl = qk * el
      qkl2 = sk1 * el**2
      if (abs(qkl2) .le. 1e-2) then
        c = (one - qkl2 * (one - qkl2 / twelve) /  two)
        s = (one - qkl2 * (one - qkl2 / twty) /  six) * el
        d = (one - qkl2 * (one - qkl2 / thty) / twelve) * el**2 / two
        f = (one - qkl2 * (one - qkl2 / foty2) / twty) * el**3 / six
      else
        if (qkl2 .gt. zero) then
          c = cos(qkl)
          s = sin(qkl) / qk
        else
          c = cosh(qkl)
          s = sinh(qkl) / qk
        endif
        d = (one - c) / sk1
        f = (el  - s) / sk1
      endif

      end
      subroutine tmsymm(t)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Symmetrize second-order array T.                                   *
! Input:                                                               *
!   t(6,6,6)  (double)  array to be symmetrized.                       *
! Output:                                                              *
!   t(6,6,6)  (double)  symmetrized array.                             *
!----------------------------------------------------------------------*
      integer i,k,l
      double precision t(6,6,6)

      do k = 1, 5
        do l = k+1, 6
          do i = 1, 6
            t(i,l,k) = t(i,k,l)
          enddo
        enddo
      enddo

      end
      subroutine tmfrng(fsec,h,sk1,edge,he,sig,corr,re,te)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for fringe field of a dipole.                        *
! Input:                                                               *
!   fsec      (logical) if true, return second order terms.            *
!   h         (double)  curvature of magnet body.                      *
!   sk1       (double)  quadrupole strength in magnet body.            *
!   edge      (double)  edge focussing angle.                          *
!   he        (double)  curvature of pole face.                        *
!   sig       (double)  sign: +1 for entry, -1 for exit.               *
!   corr      (double)  correction factor according to slac 75.        *
! Output:                                                              *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second order terms.                            *
!----------------------------------------------------------------------*
      logical fsec
      double precision corr,edge,h,he,hh,psip,re(6,6),secedg,sig,sk1,   &
     &tanedg,te(6,6,6),zero,one
      parameter(zero=0d0,one=1d0)

!---- Linear terms.
      tanedg = tan(edge)
      secedg = one / cos(edge)
      psip = edge - corr * secedg * (one + sin(edge)**2)
      re(2,1) = + h * tanedg
      re(4,3) = - h * tan(psip)

!---- Second-order terms.
      if (fsec) then
        hh = sig * (h/2)
        te(1,1,1) = - hh * tanedg**2
        te(1,3,3) = + hh * secedg**2
        te(2,1,1) = (h/2) * he * secedg**3 + sk1 * tanedg
        te(2,1,2) = - te(1,1,1)
        te(2,3,3) = hh * h * tanedg**3 - te(2,1,1)
        te(2,3,4) = + te(1,1,1)
        te(3,1,3) = - te(1,1,1)
        te(4,1,3) = - te(2,1,1)
        te(4,1,4) = + te(1,1,1)
        te(4,2,3) = - te(1,3,3)
        if (sig .gt. zero) then
          te(2,3,3) = te(2,3,3) + (h*secedg)**2 * tanedg/2
        else
          te(2,1,1) = te(2,1,1) - (h*tanedg)**2 * tanedg/2
          te(4,1,3) = te(4,1,3) + (h*secedg)**2 * tanedg/2
        endif
        call tmsymm(te)
      endif

      end
      subroutine tmcat1(fsec,eb,rb,tb,ea,ra,ta,ed,rd,td)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Concatenate two TRANSPORT maps including zero-order terms.         *
!   This routine is time-critical and is carefully optimized.          *
! Input:                                                               *
!   fsec      (logical) if true, return second order terms.            *
!   eb(6), rb(6,6), tb(6,6,6)  second map in beam line order.          *
!   ea(6), ra(6,6), ta(6,6,6)  first map in beam line order.           *
! Output:                                                              *
!   ed(6), rd(6,6), td(6,6,6)  result map.                             *
!----------------------------------------------------------------------*
      logical fsec
      integer i,ij,j,k
      double precision ea(6),eb(6),ed(6),ew(6),es(6,6),ra(6,6),rb(6,6), &
     &rd(6,6),rw(6,6),ta(6,6,6),td(6,6,6),tw(6,6,6),tb(36,6),ts(36,6),  &
     &two
      parameter(two=2d0)

!---- Second order terms.
      if (fsec) then

!---- Auxiliary terms.
        do k = 1, 6

!---- Sum over S of TB(I,S,K) * EA(S).
          do i = 1, 6
            es(i,k) = tb(i   ,k) * ea(1) + tb(i+ 6,k) * ea(2)           &
     &      + tb(i+12,k) * ea(3) + tb(i+18,k) * ea(4)                   &
     &      + tb(i+24,k) * ea(5) + tb(i+30,k) * ea(6)
          enddo

!---- Sum over S of TB(I,J,S) * RA(S,K).
          do ij = 1, 36
            ts(ij,k) = tb(ij,1) * ra(1,k) + tb(ij,2) * ra(2,k)          &
     &      + tb(ij,3) * ra(3,k) + tb(ij,4) * ra(4,k)                   &
     &      + tb(ij,5) * ra(5,k) + tb(ij,6) * ra(6,k)
          enddo
        enddo

!---- Final values.
        do k = 1, 6

!---- Zero-order terms.
          ew(k) = eb(k) + (rb(k,1) + es(k,1)) * ea(1)                   &
     &    + (rb(k,2) + es(k,2)) * ea(2)                                 &
     &    + (rb(k,3) + es(k,3)) * ea(3)                                 &
     &    + (rb(k,4) + es(k,4)) * ea(4)                                 &
     &    + (rb(k,5) + es(k,5)) * ea(5)                                 &
     &    + (rb(k,6) + es(k,6)) * ea(6)

!---- First-order terms.
          do j = 1, 6
            rw(j,k) = (rb(j,1) + two * es(j,1)) * ra(1,k)               &
     &      + (rb(j,2) + two * es(j,2)) * ra(2,k)                       &
     &      + (rb(j,3) + two * es(j,3)) * ra(3,k)                       &
     &      + (rb(j,4) + two * es(j,4)) * ra(4,k)                       &
     &      + (rb(j,5) + two * es(j,5)) * ra(5,k)                       &
     &      + (rb(j,6) + two * es(j,6)) * ra(6,k)
          enddo

!---- Second-order terms.
          do j = k, 6
            do i = 1, 6
              tw(i,j,k) =                                               &
     &        + (rb(i,1)+two*es(i,1))*ta(1,j,k) + ts(i   ,j)*ra(1,k)    &
     &        + (rb(i,2)+two*es(i,2))*ta(2,j,k) + ts(i+ 6,j)*ra(2,k)    &
     &        + (rb(i,3)+two*es(i,3))*ta(3,j,k) + ts(i+12,j)*ra(3,k)    &
     &        + (rb(i,4)+two*es(i,4))*ta(4,j,k) + ts(i+18,j)*ra(4,k)    &
     &        + (rb(i,5)+two*es(i,5))*ta(5,j,k) + ts(i+24,j)*ra(5,k)    &
     &        + (rb(i,6)+two*es(i,6))*ta(6,j,k) + ts(i+30,j)*ra(6,k)
              tw(i,k,j) = tw(i,j,k)
            enddo
          enddo
        enddo

!---- Copy second-order terms.
        call dcopy(tw,td,216)

!---- Second-order not desired.
      else
        do k = 1, 6

!---- Zero-order terms.
          ew(k) = eb(k) + rb(k,1) * ea(1) + rb(k,2) * ea(2)             &
     &    + rb(k,3) * ea(3) + rb(k,4) * ea(4)                           &
     &    + rb(k,5) * ea(5) + rb(k,6) * ea(6)

!---- First-order terms.
          do j = 1, 6
            rw(j,k) = rb(j,1) * ra(1,k) + rb(j,2) * ra(2,k)             &
     &      + rb(j,3) * ra(3,k) + rb(j,4) * ra(4,k)                     &
     &      + rb(j,5) * ra(5,k) + rb(j,6) * ra(6,k)
          enddo
        enddo
      endif

!---- Copy zero- and first-order terms.
      call dcopy(ew,ed,6)
      call dcopy(rw,rd,36)

      end
      subroutine tmtilt(fsec,tilt,ek,r,t)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Apply TILT to a TRANSPORT map.                                     *
! Input:                                                               *
!   fsec      (logical) if true, return second order terms.            *
!   tilt      (double)  roll angle. The inverse is used to rotate the  *
!                       matrix and tensor                              *
!   ek(6)     (double)  element kick, unrotated.                       *
!   r(6,6)    (double)  transfer matrix, unrotated.                    *
!   t(6,6,6)  (double)  second order terms, unrotated.                 *
! Output:                                                              *
!   ek(6)     (double)  element kick, rotated.                         *
!   r(6,6)    (double)  transfer matrix, rotated.                      *
!   t(6,6,6)  (double)  second order terms, rotated.                   *
!----------------------------------------------------------------------*
      logical fsec
      integer i,j,k
      double precision c,ek(6),r(6,6),r1j,r2j,ri1,ri2,s,t(6,6,6),t1jk,  &
     &t2jk,ti1k,ti2k,tij1,tij2,tilt,xx

      c = cos(tilt)
      s = -sin(tilt)

!---- Rotate at entrance.
      do i = 1, 6
        ri1 = r(i,1)
        r(i,1) = ri1 * c - r(i,3) * s
        r(i,3) = ri1 * s + r(i,3) * c
        ri2 = r(i,2)
        r(i,2) = ri2 * c - r(i,4) * s
        r(i,4) = ri2 * s + r(i,4) * c
        if (fsec) then
          do k = 1, 6
            ti1k = t(i,1,k)
            t(i,1,k) = ti1k * c - t(i,3,k) * s
            t(i,3,k) = ti1k * s + t(i,3,k) * c
            ti2k = t(i,2,k)
            t(i,2,k) = ti2k * c - t(i,4,k) * s
            t(i,4,k) = ti2k * s + t(i,4,k) * c
          enddo
          do j = 1, 6
            tij1 = t(i,j,1)
            t(i,j,1) = tij1 * c - t(i,j,3) * s
            t(i,j,3) = tij1 * s + t(i,j,3) * c
            tij2 = t(i,j,2)
            t(i,j,2) = tij2 * c - t(i,j,4) * s
            t(i,j,4) = tij2 * s + t(i,j,4) * c
          enddo
        endif
      enddo

!---- Rotate kick.
      xx = ek(1)
      ek(1) = xx * c - ek(3) * s
      ek(3) = xx * s + ek(3) * c
      xx = ek(2)
      ek(2) = xx * c - ek(4) * s
      ek(4) = xx * s + ek(4) * c

!---- Rotate at exit.
      do j = 1, 6
        r1j = r(1,j)
        r(1,j) = c * r1j - s * r(3,j)
        r(3,j) = s * r1j + c * r(3,j)
        r2j = r(2,j)
        r(2,j) = c * r2j - s * r(4,j)
        r(4,j) = s * r2j + c * r(4,j)
        if (fsec) then
          do k = 1, 6
            t1jk = t(1,j,k)
            t(1,j,k) = c * t1jk - s * t(3,j,k)
            t(3,j,k) = s * t1jk + c * t(3,j,k)
            t2jk = t(2,j,k)
            t(2,j,k) = c * t2jk - s * t(4,j,k)
            t(4,j,k) = s * t2jk + c * t(4,j,k)
          enddo
        endif
      enddo

      end
      subroutine tmcorr(fsec,ftrk,orbit,fmap,el,ek,re,te)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for orbit correctors.                                *
! Input:                                                               *
!   fsec      (logical) if true, return second order terms.            *
!   ftrk      (logical) if true, track orbit.                          *
! Input/output:                                                        *
!   orbit(6)  (double)  closed orbit.                                  *
! Output:                                                              *
!   fmap      (logical) if true, element has a map.                    *
!   el        (double)  element length.                                *
!   ek(6)     (double)  kick due to element.                           *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second-order terms.                            *
!----------------------------------------------------------------------*
      logical fsec,ftrk,fmap,cplxy,dorad
      integer i, n_ferr,code,node_fd_errors
      double precision orbit(6),f_errors(0:50),ek(6),re(6,6),te(6,6,6), &
     &deltap,gamma,arad,el,rfac,pt,xkick,ykick,dpx,dpy,node_value,      &
     &get_value,bv0,field(2),div,zero,one,three,half
      parameter(zero=0d0,one=1d0,three=3d0,half=5d-1)

!---- Initialize.
      n_ferr = node_fd_errors(f_errors)
      if (el .eq. zero)  then
        div = one
      else
        div = el
      endif
      bv0 = node_value('dipole_bv ')
      deltap = get_value('probe ','deltap ')
      arad = get_value('probe ','arad ')
      gamma = get_value('probe ','gamma ')
      dorad = get_value('probe ','radiate ') .ne. zero

!---- Tracking desired, use corrector map.
      if (ftrk) then
        do i = 1, 2
          field(i) = zero
        enddo
        if (n_ferr .gt. 0) call dcopy(f_errors, field, min(2, n_ferr))
!---- Original setting.
        code = node_value('mad8_type ')
        if(code.eq.14) then
          xkick=bv0*(node_value('kick ')+node_value('chkick ')+         &
     &    field(1)/div)
          ykick=zero
        else if(code.eq.15) then
          xkick=bv0*(node_value('hkick ')+node_value('chkick ')+        &
     &    field(1)/div)
          ykick=bv0*(node_value('vkick ')+node_value('cvkick ')+        &
     &    field(2)/div)
        else if(code.eq.16) then
          xkick=zero
          ykick=bv0*(node_value('kick ')+node_value('cvkick ')+         &
     &    field(2)/div)
        else
          xkick=zero
          ykick=zero
        endif

!---- Sum up total kicks.
        dpx = xkick / (one + deltap)
        dpy = ykick / (one + deltap)
        if (dpy .ne. zero) cplxy = .true.

!---- Half kick at entrance.
        orbit(2) = orbit(2) + half * dpx
        orbit(4) = orbit(4) + half * dpy

!---- Half radiation effects at entrance.
        if (dorad  .and.  el .ne. zero) then
          rfac = arad * gamma**3 * (dpx**2 + dpy**2) / (three * el)
          pt = orbit(6)
          orbit(2) = orbit(2) - rfac * (one + pt) * orbit(2)
          orbit(4) = orbit(4) - rfac * (one + pt) * orbit(4)
          orbit(6) = orbit(6) - rfac * (one + pt) ** 2
        endif

!---- Drift to end.
        if (el .ne. zero) then
          call tmdrf(fsec,ftrk,orbit,fmap,el,ek,re,te)
        endif
        fmap = .true.

!---- Half radiation effects at exit.
        if (dorad  .and.  el .ne. zero) then
          pt = orbit(6)
          orbit(2) = orbit(2) - rfac * (one + pt) * orbit(2)
          orbit(4) = orbit(4) - rfac * (one + pt) * orbit(4)
          orbit(6) = orbit(6) - rfac * (one + pt) ** 2
        endif

!---- Half kick at exit.
        orbit(2) = orbit(2) + half * dpx
        orbit(4) = orbit(4) + half * dpy

!---- No orbit track desired, use drift map.
      else
        call tmdrf(fsec,ftrk,orbit,fmap,el,ek,re,te)
      endif

      end
      subroutine tmmult(fsec,ftrk,orbit,fmap,re,te)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for thin multipole.                                  *
! Input:                                                               *
!   fsec      (logical) if true, return second order terms.            *
!   ftrk      (logical) if true, track orbit.                          *
! Input/output:                                                        *
!   orbit(6)  (double)  closed orbit.                                  *
! Output:                                                              *
!   fmap      (logical) if true, element has a map.                    *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second-order terms.                            *
!----------------------------------------------------------------------*
      include 'twissl.fi'
      logical fsec,ftrk,fmap
      integer n_ferr,nord,iord,j,nd,nn,ns,node_fd_errors,maxmul
      parameter(maxmul=20)
      double precision orbit(6),f_errors(0:50),re(6,6),te(6,6,6),x,y,   &
     &dbr,dbi,dipr,dipi,dr,di,drt,dpx,dpy,elrad,beta,bi,deltap,         &
     &vals(2,0:maxmul),field(2,0:maxmul),normal(0:maxmul),              &
     &skew(0:maxmul),node_value,get_value,bv0,bvk,zero,one,two
      parameter(zero=0d0,one=1d0,two=2d0)

!---- Initialize.
      n_ferr = node_fd_errors(f_errors)
      bv0 = node_value('dipole_bv ')
      bvk = node_value('other_bv ')
!---- Multipole length for radiation.
      elrad = node_value('lrad ')
      deltap = get_value('probe ', 'deltap ')
      beta = get_value('probe ','beta ')
      fmap = .true.
      bi = one / beta

!---- Multipole components.
      call dzero(normal,maxmul+1)
      call dzero(skew,maxmul+1)
      call node_vector('knl ',nn,normal)
      call node_vector('ksl ',ns,skew)
      call dzero(vals,2*(maxmul+1))
      do iord = 0, nn
        vals(1,iord) = normal(iord)
      enddo
      do iord = 0, ns
        vals(2,iord) = skew(iord)
      enddo

!---- Field error vals.
      call dzero(field,2*(maxmul+1))
      if (n_ferr .gt. 0) then
        call dcopy(f_errors,field,n_ferr)
      endif
      nd = 2 * max(nn, ns, n_ferr/2)

!---- Dipole error.
      dbr = bv0 * field(1,0) / (one + deltap)
      dbi = bv0 * field(2,0) / (one + deltap)

!---- Nominal dipole strength.
      dipr = bv0 * vals(1,0) / (one + deltap)
      dipi = bv0 * vals(2,0) / (one + deltap)

!---- Other components and errors.
      nord = 0
      do iord = 1, nd/2
        do j = 1, 2
          field(j,iord) = bvk * (vals(j,iord) + field(j,iord))          &
     &    / (one + deltap)
          if (field(j,iord) .ne. zero)  nord = iord
        enddo
      enddo

!---- Track orbit.
      if (ftrk) then
        x = orbit(1)
        y = orbit(3)

!---- Multipole kick.
        dr = zero
        di = zero
        do iord = nord, 1, -1
          drt = (dr * x - di * y) / (iord+1) + field(1,iord)
          di  = (dr * y + di * x) / (iord+1) + field(2,iord)
          dr  = drt
        enddo
        dpx = dbr + (dr * x - di * y)
        dpy = dbi + (di * x + dr * y)

!---- Track orbit.
        orbit(2) = orbit(2) - dpx + dipr * (deltap + bi*orbit(6))
        orbit(4) = orbit(4) + dpy - dipi * (deltap + bi*orbit(6))
        orbit(5) = orbit(5) - (dipr*x + dipi*y) * bi

!---- Orbit not wanted.
      else
        x = zero
        y = zero
        nord = min(nord, 2)
      endif

!---- First-order terms (use X,Y from orbit tracking).
      if (nord .ge. 1) then
        dr = zero
        di = zero
        do iord = nord, 1, -1
          drt = (dr * x - di * y) / (iord) + field(1,iord)
          di  = (dr * y + di * x) / (iord) + field(2,iord)
          dr  = drt
        enddo
        re(2,1) = - dr
        re(2,3) = + di
        re(4,1) = + di
        re(4,3) = + dr
      endif
      re(2,6) = + dipr * bi
      re(4,6) = - dipi * bi
      re(5,1) = - re(2,6)
      re(5,3) = - re(4,6)

!---- Second-order terms (use X,Y from orbit tracking).
      if (fsec) then
        if (nord .ge. 2) then
          dr = zero
          di = zero
          do iord = nord, 2, -1
            drt = (dr * x - di * y) / (iord-1) + field(1,iord)
            di  = (dr * y + di * x) / (iord-1) + field(2,iord)
            dr  = drt
          enddo
          dr = dr / two
          di = di / two
          te(2,1,1) = - dr
          te(2,1,3) = + di
          te(2,3,1) = + di
          te(2,3,3) = + dr
          te(4,1,1) = + di
          te(4,1,3) = + dr
          te(4,3,1) = + dr
          te(4,3,3) = - di
        endif
      endif
!---- centre option
      if(centre_cptk) call twcptk(re,orbit)
      if(centre_bttk) call twbttk(re,te)

      end
      subroutine tmoct(fsec,ftrk,orbit,fmap,el,ek,re,te)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for octupole element.                                *
! Input:                                                               *
!   fsec      (logical) if true, return second order terms.            *
!   ftrk      (logical) if true, track orbit.                          *
! Input/output:                                                        *
!   orbit(6)  (double)  closed orbit.                                  *
! Output:                                                              *
!   fmap      (logical) if true, element has a map.                    *
!   el        (double)  element length.                                *
!   ek(6)     (double)  kick due to element.                           *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second-order terms.                            *
!----------------------------------------------------------------------*
      include 'twissl.fi'
      logical fsec,ftrk,fmap,cplxy,dorad
      integer i,j,n_ferr,node_fd_errors
      double precision orbit(6),f_errors(0:50),ek(6),re(6,6),te(6,6,6), &
     &rw(6,6),tw(6,6,6),deltap,el,sk3,sk3l,rfac,arad,gamma,pt,octr,octi,&
     &posr,posi,cr,ci,tilt4,node_value,get_value,sk3s,bvk,field(2,0:3), &
     &el0,orbit0(6),zero,one,two,three,four,six
      parameter(zero=0d0,one=1d0,two=2d0,three=3d0,four=4d0,six=6d0)

!---- Initialize.
      fmap = el .ne. zero
      if (.not. fmap) return
      n_ferr = node_fd_errors(f_errors)
      bvk = node_value('other_bv ')
!---- Set up half octupole strength.
      if (ftrk) then
!---- Field error.
        do i = 0,3
          do j = 1, 2
            field(j,i) = zero
          enddo
        enddo
        if (n_ferr .gt. 0) call dcopy(f_errors, field, min(8, n_ferr))
        arad = get_value('probe ','arad ')
        gamma = get_value('probe ','gamma ')
        deltap = get_value('probe ','deltap ')
        dorad = get_value('probe ','radiate ') .ne. zero
        sk3 = bvk * node_value('k3 ')
        sk3s = bvk * node_value('k3s ')
        if (sk3s .eq. zero)  then
          tilt4 = zero
        else
          tilt4 = atan2(sk3s, sk3)
        endif
        sk3 = sk3 + bvk * field(1,3)/el
        sk3s = sk3s + bvk * field(2,3)/el
        if (tilt4 .ne. zero) sk3 = sqrt(sk3**2 + sk3s**2)
        sk3l = (el * sk3) / (one + deltap)

!---- Normal and skew components of octupole.
        octr = sk3l * cos(tilt4)
        octi = sk3l * sin(tilt4)

!---- Half kick at entrance.
        posr = orbit(1) * (orbit(1)**2 - three*orbit(3)**2) / six
        posi = orbit(3) * (three*orbit(1)**2 - orbit(3)**2) / six
        cr = octr * posr - octi * posi
        ci = octr * posi + octi * posr
        orbit(2) = orbit(2) - cr / two
        orbit(4) = orbit(4) + ci / two

!---- Half radiation effects at entrance.
        if (dorad) then
          rfac = arad * gamma**3 * (cr**2 + ci**2) / (three * el)
          pt = orbit(6)
          orbit(2) = orbit(2) - rfac * (one + pt) * orbit(2)
          orbit(4) = orbit(4) - rfac * (one + pt) * orbit(4)
          orbit(6) = orbit(6) - rfac * (one + pt) ** 2
        endif

!---- First-order terms w.r.t. orbit.
        call m66one(rw)
        posr = (orbit(1)**2 - orbit(3)**2) / four
        posi = orbit(1) * orbit(3) / two
        cr = octr * posr - octi * posi
        ci = octr * posi + octi * posr
        rw(2,1) = - cr
        rw(2,3) = + ci
        rw(4,1) = + ci
        rw(4,3) = + cr
        if (ci .ne. zero) cplxy = .true.

!---- Second-order terms w.r.t. orbit.
        call dzero(tw,216)
        if (fsec) then
          cr = (octr * orbit(1) - octi * orbit(3)) / four
          ci = (octr * orbit(3) + octi * orbit(1)) / four
          tw(2,1,1) = - cr
          tw(2,1,3) = + ci
          tw(2,3,1) = + ci
          tw(2,3,3) = + cr
          tw(4,1,1) = + ci
          tw(4,1,3) = + cr
          tw(4,3,1) = + cr
          tw(4,3,3) = - ci
        endif

!---- Concatenate with drift map.
!---- centre option
        if(centre_cptk.or.centre_bttk) then
          el0=el/two
          call dcopy(orbit,orbit0,6)
          call tmdrf0(fsec,ftrk,orbit0,fmap,el0,ek,re,te)
          call tmcat(fsec,re,te,rw,tw,re,te)
          if(centre_cptk) call twcptk(re,orbit0)
          if(centre_bttk) call twbttk(re,te)
        endif
        call tmdrf0(fsec,ftrk,orbit,fmap,el,ek,re,te)
        call tmcat(fsec,re,te,rw,tw,re,te)

!---- Half kick at exit.
        posr = orbit(1) * (orbit(1)**2 - three*orbit(3)**2) / six
        posi = orbit(3) * (three*orbit(1)**2 - orbit(3)**2) / six
        cr = octr * posr - octi * posi
        ci = octr * posi + octi * posr
        orbit(2) = orbit(2) - cr / two
        orbit(4) = orbit(4) + ci / two

!---- Half radiation effects.
        if (dorad) then
          rfac = arad * gamma**3 * (cr**2 + ci**2) / (three * el)
          pt = orbit(6)
          orbit(2) = orbit(2) - rfac * (one + pt) * orbit(2)
          orbit(4) = orbit(4) - rfac * (one + pt) * orbit(4)
          orbit(6) = orbit(6) - rfac * (one + pt) ** 2
        endif

!---- First-order terms w.r.t. orbit.
        call m66one(rw)
        posr = (orbit(1)**2 - orbit(3)**2) / four
        posi = orbit(1) * orbit(3) / two
        cr = octr * posr - octi * posi
        ci = octr * posi + octi * posr
        rw(2,1) = - cr
        rw(2,3) = + ci
        rw(4,1) = + ci
        rw(4,3) = + cr
        if (ci .ne. zero) cplxy = .true.

!---- Second-order terms w.r.t. orbit.
        call dzero(tw,216)
        if (fsec) then
          cr = (octr * orbit(1) - octi * orbit(3)) / four
          ci = (octr * orbit(3) + octi * orbit(1)) / four
          tw(2,1,1) = - cr
          tw(2,1,3) = + ci
          tw(2,3,1) = + ci
          tw(2,3,3) = + cr
          tw(4,1,1) = + ci
          tw(4,1,3) = + cr
          tw(4,3,1) = + cr
          tw(4,3,3) = - ci
        endif
        call tmcat(fsec,rw,tw,re,te,re,te)

!---- Not orbit track requested, use drift map.
      else
        call tmdrf(fsec,ftrk,orbit,fmap,el,ek,re,te)
      endif

      end
      subroutine tmquad(fsec,ftrk,orbit,fmap,el,ek,re,te)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for quadrupole element.                              *
! Input:                                                               *
!   fsec      (logical) if true, return second order terms.            *
!   ftrk      (logical) if true, track orbit.                          *
! Input/output:                                                        *
!   orbit(6)  (double)  closed orbit.                                  *
! Output:                                                              *
!   fmap      (logical) if true, element has a map.                    *
!   el        (double)  element length.                                *
!   ek(6)     (double)  kick due to element.                           *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second-order terms.                            *
!----------------------------------------------------------------------*
      include 'twissl.fi'
      logical fsec,ftrk,fmap,cplxy,dorad
      integer i,j,n_ferr,node_fd_errors
      double precision orbit(6),orbit0(6),f_errors(0:50),ek(6),re(6,6), &
     &te(6,6,6),deltap,el,el0,tilt,sk1,rfac,arad,gamma,pt,sk1s,bvk,     &
     &field(2,0:1),node_value,get_value,zero,one,two,three
      parameter(zero=0d0,one=1d0,two=2d0,three=3d0)

!---- Initialize.
      fmap = el .ne. zero
      if (.not. fmap) return
!---- Field error.
      n_ferr = node_fd_errors(f_errors)
      do i = 0, 1
        do j = 1, 2
          field(j,i) = zero
        enddo
      enddo
      if (n_ferr .gt. 0) call dcopy(f_errors, field, min(4,n_ferr))
      bvk = node_value('other_bv ')
      sk1 = bvk * node_value('k1 ')
      sk1s = bvk * node_value('k1s ')
      if (sk1s .eq. zero)  then
        tilt = zero
      else
        cplxy = cplxy .or. sk1 .ne. zero
        tilt = atan2(sk1s, sk1) / two
      endif
      sk1 = sk1 + bvk * field(1,1)/el
      sk1s = sk1s + bvk * field(2,1)/el
      if (tilt .ne. zero) sk1 = sqrt(sk1**2 + sk1s**2)
      arad = get_value('probe ','arad ')
      gamma = get_value('probe ','gamma ')
      deltap = get_value('probe ','deltap ')
      dorad = get_value('probe ','radiate ') .ne. zero
      sk1 = sk1 / (one + deltap)

!---- Half radiation effect at exit.
      if (dorad) then
        rfac = (arad * gamma**3 * sk1**2 * el / three) * (orbit(1)**2 + &
     &  orbit(3)**2)
        pt = orbit(6)
        orbit(2) = orbit(2) - rfac * (one + pt) * orbit(2)
        orbit(4) = orbit(4) - rfac * (one + pt) * orbit(4)
        orbit(6) = orbit(6) - rfac * (one + pt) ** 2
      endif

!---- centre option
      if(centre_cptk.or.centre_bttk) then
        el0=el/two
        call dcopy(orbit,orbit0,6)
        call qdbody(fsec,ftrk,tilt,sk1,orbit0,el0,ek,re,te)
        if(centre_cptk) call twcptk(re,orbit0)
        if(centre_bttk) call twbttk(re,te)
      endif
      call qdbody(fsec,ftrk,tilt,sk1,orbit,el,ek,re,te)

!---- Half radiation effect at exit.
      if (dorad) then
        rfac = (arad * gamma**3 * sk1**2 * el / three) * (orbit(1)**2 + &
     &  orbit(3)**2)
        pt = orbit(6)
        orbit(2) = orbit(2) - rfac * (one + pt) * orbit(2)
        orbit(4) = orbit(4) - rfac * (one + pt) * orbit(4)
        orbit(6) = orbit(6) - rfac * (one + pt) ** 2
      endif

      end
      subroutine qdbody(fsec,ftrk,tilt,sk1,orbit,el,ek,re,te)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for quadrupole element.                              *
! Input:                                                               *
!   fsec      (logical) if true, return second order terms.            *
!   ftrk      (logical) if true, track orbit.                          *
!   tilt      (double)  map tilt angle                                 *
!   sk1       (double)  processed quad kick                            *
! Input/output:                                                        *
!   orbit(6)  (double)  closed orbit.                                  *
! Output:                                                              *
!   el        (double)  element length.                                *
!   ek(6)     (double)  kick due to element.                           *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second-order terms.                            *
!----------------------------------------------------------------------*
      logical fsec,ftrk
      double precision orbit(6),ek(6),re(6,6),te(6,6,6),el,tilt,sk1,    &
     &gamma,beta,dtbyds,qk,qkl,qkl2,cx,sx,cy,sy,biby4,get_value,zero,   &
     &one,two,four,six,ten3m
      parameter(zero=0d0,one=1d0,two=2d0,four=4d0,six=6d0,ten3m=1d-3)

!---- Initialize.
      beta = get_value('probe ','beta ')
      gamma = get_value('probe ','gamma ')
      dtbyds = get_value('probe ','dtbyds ')

!---- Set up c's and s's.
      qk = sqrt(abs(sk1))
      qkl = qk * el
      if (abs(qkl) .lt. ten3m) then
        qkl2 = sk1 * el**2
        cx = (one - qkl2 / two)
        sx = (one - qkl2 / six) * el
        cy = (one + qkl2 / two)
        sy = (one + qkl2 / six) * el
      else if (sk1 .gt. zero) then
        cx = cos(qkl)
        sx = sin(qkl) / qk
        cy = cosh(qkl)
        sy = sinh(qkl) / qk
      else
        cx = cosh(qkl)
        sx = sinh(qkl) / qk
        cy = cos(qkl)
        sy = sin(qkl) / qk
      endif

!---- First-order terms.
      re(1,1) = cx
      re(1,2) = sx
      re(2,1) = - sk1 * sx
      re(2,2) = cx
      re(3,3) = cy
      re(3,4) = sy
      re(4,3) = + sk1 * sy
      re(4,4) = cy
      re(5,6) = el/(beta*gamma)**2
      ek(5) = el*dtbyds

!---- Second-order terms.
      if (fsec) then
        biby4 = one / (four * beta)
        te(1,1,6) = + sk1 * el * sx * biby4
        te(1,6,1) = te(1,1,6)
        te(2,2,6) = te(1,1,6)
        te(2,6,2) = te(1,1,6)
        te(1,2,6) = - (sx + el*cx) * biby4
        te(1,6,2) = te(1,2,6)
        te(2,1,6) = - sk1 * (sx - el*cx) * biby4
        te(2,6,1) = te(2,1,6)

        te(3,3,6) = - sk1 * el * sy * biby4
        te(3,6,3) = te(3,3,6)
        te(4,4,6) = te(3,3,6)
        te(4,6,4) = te(3,3,6)
        te(3,4,6) = - (sy + el*cy) * biby4
        te(3,6,4) = te(3,4,6)
        te(4,3,6) = + sk1 * (sy - el*cy) * biby4
        te(4,6,3) = te(4,3,6)

        te(5,1,1) = - sk1 * (el - sx*cx) * biby4
        te(5,1,2) = + sk1 * sx**2 * biby4
        te(5,2,1) = te(5,1,2)
        te(5,2,2) = - (el + sx*cx) * biby4
        te(5,3,3) = + sk1 * (el - sy*cy) * biby4
        te(5,3,4) = - sk1 * sy**2 * biby4
        te(5,4,3) = te(5,3,4)
        te(5,4,4) = - (el + sy*cy) * biby4
        te(5,6,6) = (- six * re(5,6)) * biby4
      endif

!---- Apply tilt.
      if (tilt .ne. zero) call tmtilt(fsec,tilt,ek,re,te)

!---- Track orbit.
      if (ftrk) call tmtrak(ek,re,te,orbit,orbit)

      end
      subroutine tmsep(fsec,ftrk,orbit,fmap,el,ek,re,te)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for electrostatic separator.                         *
! Input:                                                               *
!   fsec      (logical) if true, return second order terms.            *
!   ftrk      (logical) if true, track orbit.                          *
! Input/output:                                                        *
!   orbit(6)  (double)  closed orbit.                                  *
! Output:                                                              *
!   fmap      (logical) if true, element has a map.                    *
!   el        (double)  element length.                                *
!   ek(6)     (double)  kick due to element.                           *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second-order terms.                            *
!----------------------------------------------------------------------*
      include 'twissl.fi'
      logical fsec,ftrk,fmap,cplxy
      double precision orbit(6),orbit0(6),ek(6),re(6,6),te(6,6,6),      &
     &deltap,el,el0,tilt,ekick,charge,pc,efield,exfld,eyfld,node_value, &
     &get_value,zero,one,two,ten3m
      parameter(zero=0d0,one=1d0,two=2d0,ten3m=1d-3)

!---- Initialize.
      charge = get_value('probe ','charge ')
      pc = get_value('probe ','pc ')
      deltap = get_value('probe ','deltap ')

      fmap = el .ne. zero
      if (.not. fmap) return

!---- Strength and tilt.
      tilt = zero
      efield = zero
      if (ftrk) then
        exfld = node_value('ex ')
        eyfld = node_value('ey ')
        if (eyfld .ne. zero)  then
          tilt = atan2(eyfld, exfld)
          efield = sqrt(exfld**2 + eyfld**2)
        endif
      else
        exfld = zero
        eyfld = zero
        efield = zero
      endif
      cplxy = cplxy .or. (exfld .ne. zero .and. eyfld .ne. zero)

      ekick  = efield * ten3m * charge / (pc * (one + deltap))
!---- centre option
      if(centre_cptk.or.centre_bttk) then
        el0=el/two
        call dcopy(orbit,orbit0,6)
        call spbody(fsec,ftrk,tilt,ekick,orbit0,el0,ek,re,te)
        if(centre_cptk) call twcptk(re,orbit0)
        if(centre_bttk) call twbttk(re,te)
      endif
      call spbody(fsec,ftrk,tilt,ekick,orbit,el,ek,re,te)

      end
      subroutine spbody(fsec,ftrk,tilt,ekick,orbit,el,ek,re,te)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for electrostatic separator.                         *
! Input:                                                               *
!   fsec      (logical) if true, return second order terms.            *
!   ftrk      (logical) if true, track orbit.                          *
!   tilt      (double)  map tilt angle                                 *
!   ekick     (double)  processed electrostatic kick                   *
! Input/output:                                                        *
!   orbit(6)  (double)  closed orbit.                                  *
! Output:                                                              *
!   el        (double)  element length.                                *
!   ek(6)     (double)  kick due to element.                           *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second-order terms.                            *
!----------------------------------------------------------------------*
      logical fsec,ftrk
      double precision orbit(6),ek(6),re(6,6),te(6,6,6),el,tilt,ekl,ch, &
     &sh,sy,ekick,beta,gamma,dtbyds,dy,fact,get_value,zero,one,two,     &
     &three,by2,by24,by6,eps
      parameter(zero=0d0,one=1d0,two=2d0,three=3d0,by2=1d0/2d0,         &
     &by6=1d0/6d0,by24=1d0/24d0,eps=1d-4)

!---- Initialize.
      dtbyds = get_value('probe ','dtbyds ')
      gamma = get_value('probe ','gamma ')
      beta = get_value('probe ','beta ')

!---- Prepare linear transformation parameters.
!     DY = (COSH(K*L) - 1) / K.
      ekl = ekick * el
      if (abs(ekl) .gt. eps) then
        ch = cosh(ekl)
        sh = sinh(ekl)
        sy = sh / ekick
        dy = (ch - one) / ekick**2
      else
        ch = (one + by2  * ekl**2)
        sy = (one + by6  * ekl**2) * el
        sh = sy * ekick
        dy = (by2 + by24 * ekl**2) * el**2
      endif

!---- Kicks.
      ek(3) = dy * (ekick / beta)
      ek(4) = sy * (ekick / beta)
      ek(5) = el * dtbyds

!---- First-order terms.
      re(1,2) = el
      re(3,3) = ch - ekl * sh / beta**2
      re(3,4) = sy
      re(3,6) = (dy - el * sy / beta**2) * ekick
      re(4,3) = (sh - ekl * ch / beta**2) * ekick
      re(4,4) = ch
      re(4,6) = (sh - ekl * ch / beta**2)
      re(5,3) = - re(4,6)
      re(5,4) = - dy * ekick
      re(5,6) = - (sy - el * ch / beta**2)

!---- Second-order terms.
      if (fsec) then
        fact = el / (two * beta)
        te(1,2,3) = - fact * ekick
        te(1,2,6) = - fact
        fact = el * (three*sh/gamma**2 + ekl*ch) / (two*beta**3)
        te(3,3,3) = fact * ekick**2
        te(3,3,6) = fact * ekick
        te(3,6,6) = fact
        fact = el * (three*ch/gamma**2 + ekl*sh) / (two*beta**3)
        te(4,3,3) = fact * ekick**3
        te(4,3,6) = fact * ekick**2
        te(4,6,6) = fact * ekick
        te(5,3,3) = - fact * ekick**2
        te(5,3,6) = - fact * ekick
        te(5,6,6) = - fact
        fact = el * sh / (two * beta)
        te(3,2,2) = fact
        te(3,4,4) = fact
        te(4,3,4) = - fact * ekick**2
        te(4,4,6) = - fact * ekick
        te(5,3,4) = fact * ekick
        te(5,4,6) = fact
        fact = el * ch / (two * beta)
        te(3,3,4) = - fact * ekick
        te(3,4,6) = - fact
        te(4,2,2) = fact * ekick
        te(4,4,4) = fact * ekick
        te(5,2,2) = - fact
        te(5,4,4) = - fact
        call tmsymm(te)
      endif

!---- Apply tilt.
      if (tilt .ne. zero) call tmtilt(fsec,tilt,ek,re,te)

!---- Track orbit.
      if (ftrk) call tmtrak(ek,re,te,orbit,orbit)

      end
      subroutine tmsext(fsec,ftrk,orbit,fmap,el,ek,re,te)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for sextupole element.                               *
! Input:                                                               *
!   fsec      (logical) if true, return second order terms.            *
!   ftrk      (logical) if true, track orbit.                          *
! Input/output:                                                        *
!   orbit(6)  (double)  closed orbit.                                  *
! Output:                                                              *
!   fmap      (logical) if true, element has a map.                    *
!   el        (double)  element length.                                *
!   ek(6)     (double)  kick due to element.                           *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second-order terms.                            *
!----------------------------------------------------------------------*
      include 'twissl.fi'
      logical fsec,ftrk,fmap,cplxy,dorad
      integer i,j,n_ferr,node_fd_errors
      double precision orbit(6),orbit0(6),f_errors(0:50),ek(6),re(6,6), &
     &te(6,6,6),deltap,el,el0,tilt,sk2,rfac,arad,gamma,pt,sk2s,bvk,     &
     &field(2,0:2),node_value,get_value,zero,one,two,three,twelve
      parameter(zero=0d0,one=1d0,two=2d0,three=3d0,twelve=12d0)

!---- Initialize.
      fmap = el .ne. zero
      if (.not. fmap) return
!---- Field error.
      n_ferr = node_fd_errors(f_errors)
      do i = 0, 2
        do j = 1,2
          field(j,i) = zero
        enddo
      enddo
      if (n_ferr .gt. 0) call dcopy(f_errors, field, min(6,n_ferr))
      bvk = node_value('other_bv ')
      sk2 = bvk * node_value('k2 ')
      sk2s = bvk * node_value('k2s ')
      if (sk2s .eq. zero)  then
        tilt = zero
      else
        tilt = atan2(sk2s, sk2) / three
        cplxy = cplxy .or. sk2 .ne. zero
      endif
      sk2 = sk2 + bvk * field(1,2)/el
      sk2s = sk2s + bvk * field(2,2)/el
      if (tilt .ne. zero) sk2 = sqrt(sk2**2 + sk2s**2)
      arad = get_value('probe ','arad ')
      gamma = get_value('probe ','gamma ')
      deltap = get_value('probe ','deltap ')
      dorad = get_value('probe ','radiate ') .ne. zero
      sk2 = sk2 / (one + deltap)

!---- Half radiation effects at entrance.
      if (ftrk .and. dorad) then
        rfac = arad * gamma**3 * sk2**2 * el * (orbit(1)**2 + orbit(3)  &
     &  **2)**2 / twelve
        pt = orbit(6)
        orbit(2) = orbit(2) - rfac * (one + pt) * orbit(2)
        orbit(4) = orbit(4) - rfac * (one + pt) * orbit(4)
        orbit(6) = orbit(6) - rfac * (one + pt) ** 2
      endif

!---- centre option
      if(centre_cptk.or.centre_bttk) then
        el0=el/two
        call dcopy(orbit,orbit0,6)
        call sxbody(fsec,ftrk,tilt,sk2,orbit0,el0,ek,re,te)
        if(centre_cptk) call twcptk(re,orbit0)
        if(centre_bttk) call twbttk(re,te)
      endif
      call sxbody(fsec,ftrk,tilt,sk2,orbit,el,ek,re,te)

!---- Half radiation effects at exit.
      if (ftrk) then
        if (dorad) then
          rfac = arad * gamma**3 * sk2**2 * el * (orbit(1)**2 + orbit   &
     &    (3)**2)**2 / twelve
          pt = orbit(6)
          orbit(2) = orbit(2) - rfac * (one + pt) * orbit(2)
          orbit(4) = orbit(4) - rfac * (one + pt) * orbit(4)
          orbit(6) = orbit(6) - rfac * (one + pt) ** 2
        endif
      endif

      end
      subroutine sxbody(fsec,ftrk,tilt,sk2,orbit,el,ek,re,te)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for sextupole element.                               *
! Input:                                                               *
!   fsec      (logical) if true, return second order terms.            *
!   ftrk      (logical) if true, track orbit.                          *
!   tilt      (double)  map tilt angle                                 *
!   sk2       (double)  processed sextupole kick                       *
! Input/output:                                                        *
!   orbit(6)  (double)  closed orbit.                                  *
! Output:                                                              *
!   el        (double)  element length.                                *
!   ek(6)     (double)  kick due to element.                           *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second-order terms.                            *
!----------------------------------------------------------------------*
      logical fsec,ftrk
      double precision orbit(6),ek(6),re(6,6),te(6,6,6),el,tilt,sk2,skl,&
     &gamma,dtbyds,beta,s1,s2,s3,s4,get_value,zero,two,three,four
      parameter(zero=0d0,two=2d0,three=3d0,four=4d0)

!---- Initialize.
      beta = get_value('probe ','beta ')
      gamma = get_value('probe ','gamma ')
      dtbyds = get_value('probe ','dtbyds ')

!---- First-order terms.
      re(1,2) = el
      re(3,4) = el
      re(5,6) = el/(beta*gamma)**2
      ek(5) = el*dtbyds

!---- Second-order terms.
      if (fsec) then
        skl = sk2 * el
        if (skl .ne. zero) then
          s1 = skl / two
          s2 = s1 * el / two
          s3 = s2 * el / three
          s4 = s3 * el / four
          te(1,1,1) = - s2
          te(1,1,2) = - s3
          te(1,2,2) = - two * s4
          te(1,3,3) = + s2
          te(1,3,4) = + s3
          te(1,4,4) = + two * s4
          te(2,1,1) = - s1
          te(2,1,2) = - s2
          te(2,2,2) = - two * s3
          te(2,3,3) = + s1
          te(2,3,4) = + s2
          te(2,4,4) = + two * s3
          te(3,1,3) = + s2
          te(3,1,4) = + s3
          te(3,2,3) = + s3
          te(3,2,4) = + two * s4
          te(4,1,3) = + s1
          te(4,1,4) = + s2
          te(4,2,3) = + s2
          te(4,2,4) = + two * s3
        endif
        te(1,2,6) = - el / (two * beta)
        te(3,4,6) = te(1,2,6)
        te(5,2,2) = te(1,2,6)
        te(5,4,4) = te(1,2,6)
        te(5,6,6) = - three * re(5,6) / (two * beta)
        call tmsymm(te)
      endif

!---- Apply tilt.
      if (tilt .ne. zero) call tmtilt(fsec,tilt,ek,re,te)

!---- Track orbit.
      if (ftrk) call tmtrak(ek,re,te,orbit,orbit)

      end
      subroutine tmsol(fsec,ftrk,orbit,fmap,el,ek,re,te)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for solenoid element, with centre option.            *
! Input:                                                               *
!   fsec      (logical) if true, return second order terms.            *
!   ftrk      (logical) if true, track orbit.                          *
! Input/output:                                                        *
!   orbit(6)  (double)  closed orbit.                                  *
! Output:                                                              *
!   fmap      (logical) if true, element has a map.                    *
!   el        (double)  element length.                                *
!   ek(6)     (double)  kick due to element.                           *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second-order terms.                            *
!----------------------------------------------------------------------*
      include 'twissl.fi'
      logical fsec,ftrk,fmap
      double precision orbit(6),orbit0(6),ek(6),re(6,6),te(6,6,6),      &
     &el,el0,two
      parameter(two=2d0)

!---- centre option
      if(centre_cptk.or.centre_bttk) then
        el0=el/two
        call dcopy(orbit,orbit0,6)
        call tmsol0(fsec,ftrk,orbit0,fmap,el0,ek,re,te)
        if(centre_cptk) call twcptk(re,orbit0)
        if(centre_bttk) call twbttk(re,te)
      endif
      call tmsol0(fsec,ftrk,orbit,fmap,el,ek,re,te)

      end
      subroutine tmsol0(fsec,ftrk,orbit,fmap,el,ek,re,te)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for solenoid element, no centre option.              *
! Input:                                                               *
!   fsec      (logical) if true, return second order terms.            *
!   ftrk      (logical) if true, track orbit.                          *
! Input/output:                                                        *
!   orbit(6)  (double)  closed orbit.                                  *
! Output:                                                              *
!   fmap      (logical) if true, element has a map.                    *
!   el        (double)  element length.                                *
!   ek(6)     (double)  kick due to element.                           *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second-order terms.                            *
!----------------------------------------------------------------------*
      logical fsec,ftrk,fmap,cplxy
      double precision orbit(6),ek(6),re(6,6),te(6,6,6),deltap,el,sks,  &
     &sk,gamma,skl,beta,co,si,sibk,temp,dtbyds,node_value,get_value,    &
     &zero,one,two,three,six,ten5m
      parameter(zero=0d0,one=1d0,two=2d0,three=3d0,six=6d0,ten5m=1d-5)

!---- Initialize.
      fmap = el .ne. zero
      if (.not. fmap) return
      dtbyds = get_value('probe ','dtbyds ')
      gamma = get_value('probe ','gamma ')
      beta = get_value('probe ','beta ')
      deltap = get_value('probe ','deltap ')

!---- Strength.
      sks = node_value('ks ')
      if (sks .ne. zero) then
        cplxy = .true.
      endif

!---- Set up C's and S's.
      sk = sks / two / (one + deltap)
      skl = sk * el
      co = cos(skl)
      si = sin(skl)
      if (abs(skl) .lt. ten5m) then
        sibk = (one - skl**2/six) * el
      else
        sibk = si/sk
      endif

!---- First-order terms.
      re(1,1) = co**2
      re(2,2) = re(1,1)
      re(3,3) = re(1,1)
      re(4,4) = re(1,1)
      re(1,2) = co * sibk
      re(3,4) = re(1,2)
      re(1,3) = co * si
      re(2,4) = re(1,3)
      re(3,1) = - re(1,3)
      re(4,2) = re(3,1)
      re(2,1) = sk * re(3,1)
      re(4,3) = re(2,1)
      re(1,4) = si * sibk
      re(3,2) = - re(1,4)
      re(4,1) = sk * si**2
      re(2,3) = - re(4,1)
      re(5,6) = el/(beta*gamma)**2
      ek(5) = el*dtbyds

!---- Second-order terms.
      if (fsec) then
        temp = el * co * si / beta
        te(1,4,6) = - temp
        te(3,2,6) =   temp
        te(1,1,6) =   temp * sk
        te(2,2,6) =   temp * sk
        te(3,3,6) =   temp * sk
        te(4,4,6) =   temp * sk
        te(2,3,6) =   temp * sk**2
        te(4,1,6) = - temp * sk**2

        temp = el * (co**2 - si**2) / (two * beta)
        te(1,2,6) = - temp
        te(3,4,6) = - temp
        te(1,3,6) = - temp * sk
        te(2,4,6) = - temp * sk
        te(3,1,6) =   temp * sk
        te(4,2,6) =   temp * sk
        te(2,1,6) =   temp * sk**2
        te(4,3,6) =   temp * sk**2

        temp = el / (two * beta)
        te(5,2,2) = - temp
        te(5,4,4) = - temp
        te(5,1,4) =   temp * sk
        te(5,2,3) = - temp * sk
        te(5,1,1) = - temp * sk**2
        te(5,3,3) = - temp * sk**2
        te(5,6,6) = - three * re(5,6) / (two * beta)
        call tmsymm(te)
      endif

!---- Track orbit.
      if (ftrk) call tmtrak(ek,re,te,orbit,orbit)

      end
      subroutine tmsrot(ftrk,orbit,fmap,ek,re,te)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for rotation about S-axis.                           *
! Input:                                                               *
!   ftrk      (logical) if true, track orbit.                          *
! Input/output:                                                        *
!   orbit(6)  (double)  closed orbit.                                  *
! Output:                                                              *
!   fmap      (logical) if true, element has a map.                    *
!   ek(6)     (double)  kick due to element.                           *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second-order terms.                            *
!----------------------------------------------------------------------*
      include 'twissl.fi'
      logical ftrk,fmap,cplxy
      double precision orbit(6),ek(6),re(6,6),te(6,6,6),theta,ct,st,    &
     &node_value,zero
      parameter(zero=0d0)

!---- Initialize.
      theta = node_value('angle ')
      fmap = theta .ne. zero
      if (.not. fmap) return

!---- First-order terms.
      cplxy = .true.
      ct = cos(theta)
      st = sin(theta)
      re(1,1) = ct
      re(1,3) = st
      re(3,1) = - st
      re(3,3) = ct
      re(2,2) = ct
      re(2,4) = st
      re(4,2) = - st
      re(4,4) = ct

!---- Track orbit.
      if (ftrk) call tmtrak(ek,re,te,orbit,orbit)
!---- centre option
      if(centre_cptk) call twcptk(re,orbit)
      if(centre_bttk) call twbttk(re,te)

      end
      subroutine tmyrot(ftrk,orbit,fmap,ek,re,te)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for rotation about Y-axis.                           *
!   Treated in a purely linear way.                                    *
! Input:                                                               *
!   ftrk      (logical) if true, track orbit.                          *
! Input/output:                                                        *
!   orbit(6)  (double)  closed orbit.                                  *
! Output:                                                              *
!   fmap      (logical) if true, element has a map.                    *
!   ek(6)     (double)  kick due to element.                           *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second-order terms.                            *
!----------------------------------------------------------------------*
      include 'twissl.fi'
      logical ftrk,fmap
      double precision orbit(6),ek(6),re(6,6),te(6,6,6),phi,cosphi,     &
     &sinphi,tanphi,beta,node_value,get_value,zero,one
      parameter(zero=0d0,one=1d0)

!---- Initialize.
      phi = node_value('angle ')
      fmap = phi .ne. zero
      if (.not. fmap) return
      beta = get_value('probe ','beta ')

!---- Kick.
      cosphi = cos(phi)
      sinphi = sin(phi)
      tanphi = sinphi / cosphi
      ek(2) = - sinphi

!---- Transfer matrix.
      re(1,1) = one / cosphi
      re(2,2) = cosphi
      re(2,6) = - sinphi / beta
      re(5,1) = tanphi / beta

!---- Track orbit.
      if (ftrk) call tmtrak(ek,re,te,orbit,orbit)
!---- centre option
      if(centre_cptk) call twcptk(re,orbit)
      if(centre_bttk) call twbttk(re,te)

      end
      subroutine tmdrf0(fsec,ftrk,orbit,fmap,dl,ek,re,te)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for drift space, no centre option.                   *
! Input:                                                               *
!   fsec      (logical) if true, return second order terms.            *
!   ftrk      (logical) if true, track orbit.                          *
! Input/output:                                                        *
!   orbit(6)  (double)  closed orbit.                                  *
! Output:                                                              *
!   fmap      (logical) if true, element has a map.                    *
!   dl        (double)  element length.                                *
!   ek(6)     (double)  kick due to element.                           *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second-order terms.                            *
!----------------------------------------------------------------------*
      logical fsec,ftrk,fmap
      double precision dl,beta,gamma,dtbyds,orbit(6),ek(6),re(6,6),     &
     &te(6,6,6),get_value,zero,two,three
      parameter(zero=0d0,two=2d0,three=3d0)

!---- Initialize.
      fmap = dl .ne. zero
      dtbyds = get_value('probe ', 'dtbyds ')
      gamma = get_value('probe ', 'gamma ')
      beta = get_value('probe ', 'beta ')

!---- First-order terms.
      re(1,2) = dl
      re(3,4) = dl
      re(5,6) = dl/(beta*gamma)**2
      ek(5) = dl*dtbyds

!---- Second-order terms.
      if (fsec) then
        te(1,2,6) = - dl / (two * beta)
        te(1,6,2) = te(1,2,6)
        te(3,4,6) = te(1,2,6)
        te(3,6,4) = te(3,4,6)
        te(5,2,2) = te(1,2,6)
        te(5,4,4) = te(5,2,2)
        te(5,6,6) = te(1,2,6) * three / (beta * gamma) ** 2
      endif

!---- Track orbit.
      if (ftrk) call tmtrak(ek,re,te,orbit,orbit)

      end
      subroutine tmdrf(fsec,ftrk,orbit,fmap,dl,ek,re,te)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for drift space, with centre option.                 *
! Input:                                                               *
!   fsec      (logical) if true, return second order terms.            *
!   ftrk      (logical) if true, track orbit.                          *
! Input/output:                                                        *
!   orbit(6)  (double)  closed orbit.                                  *
! Output:                                                              *
!   fmap      (logical) if true, element has a map.                    *
!   dl        (double)  element length.                                *
!   ek(6)     (double)  kick due to element.                           *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second-order terms.                            *
!----------------------------------------------------------------------*
      include 'twissl.fi'
      logical fsec,ftrk,fmap
      double precision dl,dl0,orbit(6),orbit0(6),ek(6),re(6,6),         &
     &te(6,6,6),two
      parameter(two=2d0)

!---- centre option
      if(centre_cptk.or.centre_bttk) then
        dl0=dl/two
        call dcopy(orbit,orbit0,6)
        call tmdrf0(fsec,ftrk,orbit0,fmap,dl0,ek,re,te)
        if(centre_cptk) call twcptk(re,orbit0)
        if(centre_bttk) call twbttk(re,te)
      endif
      call tmdrf0(fsec,ftrk,orbit,fmap,dl,ek,re,te)

      end
      subroutine tmrf(fsec,ftrk,orbit,fmap,el,ek,re,te)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for RF cavity.                                       *
! Input:                                                               *
!   fsec      (logical) if true, return second order terms.            *
!   ftrk      (logical) if true, track orbit.                          *
! Input/output:                                                        *
!   orbit(6)  (double)  closed orbit.                                  *
! Output:                                                              *
!   fmap      (logical) if true, element has a map.                    *
!   el        (double)  element length.                                *
!   ek(6)     (double)  kick due to element.                           *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second-order terms.                            *
!----------------------------------------------------------------------*
      include 'twissl.fi'
      logical fsec,ftrk,fmap
      double precision orbit(6),orbit0(6),ek(6),re(6,6),te(6,6,6),      &
     &rw(6,6),tw(6,6,6),el,rfv,rff,rfl,dl,omega,vrf,phirf,pc,deltap,c0, &
     &c1,c2,ek0(6),ten6p,clight,node_value,get_value,twopi,get_variable,&
     &zero,one,two,half,ten3m
      parameter(zero=0d0,one=1d0,two=2d0,half=5d-1,ten6p=1d6,           &
     &ten3m=1d-3)

!---- Initialize.
      call dzero(ek0,6)
      call m66one(rw)
      call dzero(tw,216)
      clight=get_variable('clight ')
      twopi=get_variable('twopi ')

!---- Fetch data.
      rfv = node_value('volt ')
      rff = node_value('freq ')
      rfl = node_value('lag ')
      deltap = get_value('probe ','deltap ')
      pc = get_value('probe ','pc ')

!---- Cavity is excited, use full map.
      if (rfv .ne. zero) then

!---- Set up.
        omega = rff * ten6p * twopi / clight
        vrf   = rfv * ten3m / (pc * (one + deltap))
        phirf = rfl * twopi - omega * orbit(5)
        c0 =   vrf * sin(phirf)
        c1 = - vrf * cos(phirf) * omega
        c2 = - vrf * sin(phirf) * omega**2 * half

!---- Transfer map.
        fmap = .true.
        if (ftrk) then
          orbit(6) = orbit(6) + c0
          ek(6) = c0
          re(6,5) = c1
          if (fsec) te(6,5,5) = c2
        else
          ek(6) = c0 - c1 * orbit(5) + c2 * orbit(5)**2
          re(6,5) = c1 - two * c2 * orbit(5)
          if (fsec) te(6,5,5) = c2
        endif

!---- Sandwich cavity between two drifts.
        if (el .ne. zero) then
          dl = el / two
          call tmdrf0(fsec,ftrk,orbit,fmap,dl,ek0,rw,tw)
          call tmcat(fsec,re,te,rw,tw,re,te)
          if(centre_cptk.or.centre_bttk) then
            call dcopy(orbit,orbit0,6)
            if(centre_cptk) call twcptk(re,orbit0)
            if(centre_bttk) call twbttk(re,te)
          endif
          call tmdrf0(fsec,ftrk,orbit,fmap,dl,ek0,rw,tw)
          call tmcat(fsec,rw,tw,re,te,re,te)
        endif

!---- Cavity not excited, use drift map.
      else
        call tmdrf(fsec,ftrk,orbit,fmap,el,ek,re,te)
      endif

      end
      subroutine tmcat(fsec,rb,tb,ra,ta,rd,td)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Concatenate two TRANSPORT maps.                                    *
!   This routine is time-critical and is carefully optimized.          *
! Input:                                                               *
!   fsec      (logical) if true, return second order terms.            *
!   rb(6,6), tb(6,6,6)  second map in beam line order.                 *
!   ra(6,6), ta(6,6,6)  first map in beam line order.                  *
! Output:                                                              *
!   rd(6,6), td(6,6,6)  result map.                                    *
!----------------------------------------------------------------------*
      logical fsec
      integer i1,i2,i3
      double precision ra(6,6),rb(6,6),rd(6,6),rw(6,6),ta(6,6,6),       &
     &tb(36,6),td(6,6,6),ts(36,6),tw(6,6,6)

!---- Initialization
      call dzero(tw,216)

!---- Transfer matrix.
      do i2 = 1, 6
        do i1 = 1, 6
          rw(i1,i2) = rb(i1,1) * ra(1,i2) + rb(i1,2) * ra(2,i2)         &
     &    + rb(i1,3) * ra(3,i2) + rb(i1,4) * ra(4,i2)                   &
     &    + rb(i1,5) * ra(5,i2) + rb(i1,6) * ra(6,i2)
        enddo
      enddo

!---- Second order terms.
      if (fsec) then
        do i3 = 1, 6
          do i1 = 1, 36
            ts(i1,i3) = tb(i1,1) * ra(1,i3) + tb(i1,2) * ra(2,i3)       &
     &      + tb(i1,3) * ra(3,i3) + tb(i1,4) * ra(4,i3)                 &
     &      + tb(i1,5) * ra(5,i3) + tb(i1,6) * ra(6,i3)
          enddo
        enddo
        do i2 = 1, 6
          do i3 = i2, 6
            do i1 = 1, 6
              tw(i1,i2,i3) =                                            &
     &        rb(i1,1) * ta(1,i2,i3) + rb(i1,2) * ta(2,i2,i3)           &
     &        + rb(i1,3) * ta(3,i2,i3) + rb(i1,4) * ta(4,i2,i3)         &
     &        + rb(i1,5) * ta(5,i2,i3) + rb(i1,6) * ta(6,i2,i3)         &
     &        + ts(i1,   i2) * ra(1,i3) + ts(i1+ 6,i2) * ra(2,i3)       &
     &        + ts(i1+12,i2) * ra(3,i3) + ts(i1+18,i2) * ra(4,i3)       &
     &        + ts(i1+24,i2) * ra(5,i3) + ts(i1+30,i2) * ra(6,i3)
              tw(i1,i3,i2) = tw(i1,i2,i3)
            enddo
          enddo
        enddo
      endif

!---- Copy result.
      call dcopy(rw,rd,36)
      call dcopy(tw,td,216)

      end
      subroutine tmtrak(ek,re,te,orb1,orb2)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Track orbit and change reference for RE matrix.                    *
! Input:                                                               *
!   ek(6)     (double)  kick on orbit.                                 *
!   re(6,6)   (double)  transfer matrix before update.                 *
!   te(6,6,6) (double)  second order terms.                            *
!   orb1(6)   (double)  orbit before element.                          *
! Output:                                                              *
!   orb2(6)   (double)  orbit after element.                           *
!   re(6,6)   (double)  transfer matrix after update.                  *
!----------------------------------------------------------------------*
      integer i,k,l,get_option
      double precision sum1,sum2,ek(6),re(6,6),te(6,6,6),orb1(6),       &
     &orb2(6),temp(6),zero
      parameter(zero=0d0)

!---- initialize.
      do i = 1, 6
        sum2 = ek(i)
        do k = 1, 6
          sum1 = zero
          do l = 1, 6
            sum1 = sum1 + te(i,k,l) * orb1(l)
          enddo
          sum2 = sum2 + (re(i,k) + sum1) * orb1(k)
          re(i,k) = re(i,k) + sum1 + sum1
        enddo
        temp(i) = sum2
      enddo
      call dcopy(temp,orb2,6)

!---- Symplectify transfer matrix.
      if(get_option('sympl ').ne.0) call tmsymp(re)

      end
      subroutine tmsymp(r)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Symplectify a 6 by 6 matrix R.                                     *
!   Algorithm described in the doctoral thesis by Liam Healey.         *
! Input:                                                               *
!   r(6,6)    (double)  matrix to be symplectified.                    *
! Output:                                                              *
!   r(6,6)    (double)  the symplectified matrix.                      *
!----------------------------------------------------------------------*
      logical eflag
      integer i,j
      double precision a(6,6),b(6,6),r(6,6),v(6,6),one,two
      parameter(one=1d0,two=2d0)

      do i = 1, 6
        do j = 1, 6
          a(i,j) = - r(i,j)
          b(i,j) = + r(i,j)
        enddo
        a(i,i) = a(i,i) + one
        b(i,i) = b(i,i) + one
      enddo
      call m66div(a,b,v,eflag)
      call m66inv(v,a)
      do i = 1, 6
        do j = 1, 6
          a(i,j) = (a(i,j) - v(i,j)) / two
          b(i,j) = - a(i,j)
        enddo
        b(i,i) = b(i,i) + one
        a(i,i) = a(i,i) + one
      enddo
      call m66div(a,b,r,eflag)

      end
      subroutine tmali1(orb1, errors, betas, gammas, orb2, rm)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for orbit displacement at entry of an element.       *
! Input:                                                               *
!   orb1(6)   (real)    Orbit before misalignment.                     *
!   errors(align_max) (real)    alignment errors                       *
!   betas     (real)    current beam beta                              *
!   gammas    (real)    current beam gamma                             *
! Output:                                                              *
!   orb2(6)   (real)    Orbit after misalignment.                      *
!   rm(6,6)   (real)    First order transfer matrix w.r.t. orbit.      *
!----------------------------------------------------------------------*
      include 'twiss0.fi'
      double precision ds,dx,dy,phi,psi,rm(6,6),s2,the,betas, gammas,   &
     &w(3,3),orb1(6),orb2(6),orbt(6),errors(align_max)

!---- Build rotation matrix and compute additional drift length.
      dx  = errors(1)
      dy  = errors(2)
      ds  = errors(3)
      the = errors(5)
      phi = errors(4)
      psi = errors(6)
      call sumtrx(the, phi, psi, w)
      s2 = (w(1,3) * dx + w(2,3) * dy + w(3,3) * ds) / w(3,3)

!---- F2 terms (transfer matrix).
      call m66one(rm)
      rm(2,2) = w(1,1)
      rm(2,4) = w(2,1)
      rm(2,6) = w(3,1) / betas
      rm(4,2) = w(1,2)
      rm(4,4) = w(2,2)
      rm(4,6) = w(3,2) / betas

      rm(1,1) =   w(2,2) / w(3,3)
      rm(1,2) = rm(1,1) * s2
      rm(1,3) = - w(1,2) / w(3,3)
      rm(1,4) = rm(1,3) * s2
      rm(3,1) = - w(2,1) / w(3,3)
      rm(3,2) = rm(3,1) * s2
      rm(3,3) =   w(1,1) / w(3,3)
      rm(3,4) = rm(3,3) * s2
      rm(5,1) = w(1,3) / (w(3,3) * betas)
      rm(5,2) = rm(5,1) * s2
      rm(5,3) = w(2,3) / (w(3,3) * betas)
      rm(5,4) = rm(5,3) * s2
      rm(5,6) = - s2 / (betas * gammas)**2

!---- Track orbit.
      call m66byv(rm, orb1, orbt)
      orb2(1) = orbt(1) - (w(2,2) * dx - w(1,2) * dy) / w(3,3)
      orb2(2) = orbt(2) + w(3,1)
      orb2(3) = orbt(3) - (w(1,1) * dy - w(2,1) * dx) / w(3,3)
      orb2(4) = orbt(4) + w(3,2)
      orb2(5) = orbt(5) - s2 / betas
      orb2(6) = orbt(6)

      end
      subroutine tmali2(el, orb1, errors, betas, gammas, orb2, rm)
      implicit none
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   TRANSPORT map for orbit displacement at exit of an element.        *
! Input:                                                               *
!   orb1(6)   (real)    Orbit before misalignment.                     *
!   errors(align_max) (real)    alignment errors                       *
!   betas     (real)    current beam beta                              *
!   gammas    (real)    current beam gamma                             *
! Output:                                                              *
!   orb2(6)   (real)    Orbit after misalignment.                      *
!   rm(6,6)   (real)    First order transfer matrix w.r.t. orbit.      *
!----------------------------------------------------------------------*
      include 'twiss0.fi'
      double precision ds,dx,dy,el,phi,psi,s2,the,                      &
     &orb1(6),orb2(6),rm(6,6),v(3),ve(3),w(3,3),we(3,3),orbt(6),        &
     &errors(align_max),betas,gammas

!---- Misalignment rotation matrix w.r.t. entrance system.
      dx  = errors(1)
      dy  = errors(2)
      ds  = errors(3)
      the = errors(5)
      phi = errors(4)
      psi = errors(6)
      call sumtrx(the, phi, psi, w)
!---- VE and WE represent the change of reference.
      call suelem(el, ve, we)
!---- Misalignment displacements at exit w.r.t. entrance system.
      v(1) = dx + w(1,1)*ve(1)+w(1,2)*ve(2)+w(1,3)*ve(3)-ve(1)
      v(2) = dy + w(2,1)*ve(1)+w(2,2)*ve(2)+w(2,3)*ve(3)-ve(2)
      v(3) = ds + w(3,1)*ve(1)+w(3,2)*ve(2)+w(3,3)*ve(3)-ve(3)

!---- Convert all references to exit, build additional drift.
      call sutran(w, v, we)
      s2 = - (w(1,3) * v(1) + w(2,3) * v(2) + w(3,3) * v(3)) / w(3,3)

!---- Transfer matrix.
      call m66one(rm)
      rm(1,1) = w(1,1)
      rm(3,1) = w(2,1)
      rm(5,1) = w(3,1) / betas
      rm(1,3) = w(1,2)
      rm(3,3) = w(2,2)
      rm(5,3) = w(3,2) / betas

      rm(2,2) =   w(2,2) / w(3,3)
      rm(1,2) = rm(2,2) * s2
      rm(4,2) = - w(1,2) / w(3,3)
      rm(3,2) = rm(4,2) * s2
      rm(2,4) = - w(2,1) / w(3,3)
      rm(1,4) = rm(2,4) * s2
      rm(4,4) =   w(1,1) / w(3,3)
      rm(3,4) = rm(4,4) * s2
      rm(2,6) = w(1,3) / (w(3,3) * betas)
      rm(1,6) = rm(2,6) * s2
      rm(4,6) = w(2,3) / (w(3,3) * betas)
      rm(3,6) = rm(4,6) * s2
      rm(5,6) = - s2 / (betas * gammas)**2

!---- Track orbit.
      orbt(1) = orb1(1) + (w(2,2) * v(1) - w(1,2) * v(2)) / w(3,3)
      orbt(2) = orb1(2) - w(3,1)
      orbt(3) = orb1(3) + (w(1,1) * v(2) - w(2,1) * v(1)) / w(3,3)
      orbt(4) = orb1(4) - w(3,2)
      orbt(5) = orb1(5) - s2 / betas
      orbt(6) = orb1(6)
      call m66byv(rm, orbt, orb2)

      end
      subroutine tmbb(fsec,ftrk,orbit,fmap,re,te)
      implicit none
!----------------------------------------------------------------------*
! purpose:                                                             *
!   transport map for beam-beam element.                               *
! input:                                                               *
!   fsec      (logical) must be .true. for this purpose                *
!   ftrk      (logical) must be true for this purpose                  *
! input/output:                                                        *
!   orbit(6)  (double)  closed orbit (only kick is added since BB thin)*
! output:                                                              *
!   fmap      (logical) if map has been calculated correctly           *
!   re(6,6)   (double)  transfer matrix.                               *
!   te(6,6,6) (double)  second-order terms.                            *
!----------------------------------------------------------------------*
      include 'twissl.fi'
      include 'bb.fi'
      logical fsec,ftrk,fmap,bborbit
      integer get_option
      double precision parvec(26),orbit(6),re(6,6),te(6,6,6),pi,sx,sy,  &
     &xm,ym,sx2,sy2,xs,ys,rho2,fk,tk,exk,phix,phiy,rho4,phixx,phixy,    &
     &phiyy,rho6,rk,exkc,xb,yb,phixxx,phixxy,phixyy,phiyyy,crx,cry,xr,  &
     &yr,r,r2,cbx,cby,get_variable,get_value,node_value,zero,one,two,   &
     &three,ten3m,explim
      parameter(zero=0d0,one=1d0,two=2d0,three=3d0,ten3m=1d-3,          &
     &explim=150d0)
!     if x > explim, exp(-x) is outside machine limits.

!---- initialize.
      bborbit = get_option('bborbit ') .ne. 0
      if (bbd_flag .ne. 0 .and. .not. bborbit)  then
        if (bbd_cnt .eq. bbd_max)  then
          call aawarn('TMBB: ','maximum bb number reached')
        else
          bbd_cnt = bbd_cnt + 1
          bbd_loc(bbd_cnt) = bbd_pos
          bb_kick(1,bbd_cnt) = zero
          bb_kick(2,bbd_cnt) = zero
        endif
      endif
      pi=get_variable('pi ')
      fmap = .true.
      sx = node_value('sigx ')
      sy = node_value('sigy ')
      xm = node_value('xma ')
      ym = node_value('yma ')
!--- standard 4D
      parvec(5)=get_value('probe ', 'arad ')
      parvec(6)=node_value('charge ') * get_value('probe ', 'npart ')
      parvec(7)=get_value('probe ','gamma ')
      fk = two * parvec(5) * parvec(6) / parvec(7)
      if (fk .ne. zero)  then
!---- if tracking is desired ...
        if (ftrk) then
          sx2 = sx * sx
          sy2 = sy * sy
          xs  = orbit(1) - xm
          ys  = orbit(3) - ym

!---- limit formulas for sigma(x) = sigma(y).
          if (abs(sx2 - sy2) .le. ten3m * (sx2 + sy2)) then
            rho2 = xs * xs + ys * ys

!---- limit case for xs = ys = 0.
            if (rho2 .eq. zero) then
              re(2,1) = fk / (two * sx2)
              re(4,3) = fk / (two * sx2)

!---- general case.
            else
              tk = rho2 / (two * sx2)
              if (tk .gt. explim) then
                exk  = zero
                exkc = one
                phix = xs * fk / rho2
                phiy = ys * fk / rho2
              else
                exk  = exp(-tk)
                exkc = one - exk
                phix = xs * fk / rho2 * exkc
                phiy = ys * fk / rho2 * exkc
              endif

!---- orbit kick - only applied if option bborbit (HG 5/12/01),
!     else stored
              if (bborbit) then
                orbit(2) = orbit(2) + phix
                orbit(4) = orbit(4) + phiy
              elseif (bbd_flag .ne. 0)  then
                bb_kick(1,bbd_cnt) = phix
                bb_kick(2,bbd_cnt) = phiy
              endif
!---- first-order effects.
              rho4 = rho2 * rho2
              phixx = fk * (- exkc * (xs*xs - ys*ys) / rho4             &
     &        + exk * xs*xs / (rho2 * sx2))
              phixy = fk * (- exkc * two * xs * ys / rho4               &
     &        + exk * xs*ys / (rho2 * sx2))
              phiyy = fk * (+ exkc * (xs*xs - ys*ys) / rho4             &
     &        + exk * ys*ys / (rho2 * sx2))
              re(2,1) = phixx
              re(2,3) = phixy
              re(4,1) = phixy
              re(4,3) = phiyy

!---- second-order effects.
              if (fsec) then
                rho6 = rho4 * rho2
                phixxx = fk*xs * (+ exkc * (xs*xs - three*ys*ys) / rho6 &
     &          - exk * (xs*xs - three*ys*ys) / (two * rho4 * sx2)      &
     &          - exk * xs*xs / (two * rho2 * sx2**2))
                phixxy = fk*ys * (+ exkc * (three*xs*xs - ys*ys) / rho6 &
     &          - exk * (three*xs*xs - ys*ys) / (two * rho4 * sx2)      &
     &          - exk * xs*xs / (two * rho2 * sx2**2))
                phixyy = fk*xs * (- exkc * (xs*xs - three*ys*ys) / rho6 &
     &          + exk * (xs*xs - three*ys*ys) / (two * rho4 * sx2)      &
     &          - exk * ys*ys / (two * rho2 * sx2**2))
                phiyyy = fk*ys * (- exkc * (three*xs*xs - ys*ys) / rho6 &
     &          + exk * (three*xs*xs - ys*ys) / (two * rho4 * sx2)      &
     &          - exk * ys*ys / (two * rho2 * sx2**2))
                te(2,1,1) = phixxx
                te(2,1,3) = phixxy
                te(2,3,1) = phixxy
                te(4,1,1) = phixxy
                te(2,3,3) = phixyy
                te(4,1,3) = phixyy
                te(4,3,1) = phixyy
                te(4,3,3) = phiyyy
              endif
            endif

!---- case sigma(x) > sigma(y).
          else
            r2 = two * (sx2 - sy2)
            if (sx2 .gt. sy2) then
              r  = sqrt(r2)
              rk = fk * sqrt(pi) / r
              xr = abs(xs) / r
              yr = abs(ys) / r
              call ccperrf(xr, yr, crx, cry)
              tk = (xs * xs / sx2 + ys * ys / sy2) / two
              if (tk .gt. explim) then
                exk = zero
                cbx = zero
                cby = zero
              else
                exk = exp(-tk)
                xb  = (sy / sx) * xr
                yb  = (sx / sy) * yr
                call ccperrf(xb, yb, cbx, cby)
              endif

!---- case sigma(x) < sigma(y).
            else
              r  = sqrt(-r2)
              rk = fk * sqrt(pi) / r
              xr = abs(xs) / r
              yr = abs(ys) / r
              call ccperrf(yr, xr, cry, crx)
              tk = (xs * xs / sx2 + ys * ys / sy2) / two
              if (tk .gt. explim) then
                exk = zero
                cbx = zero
                cby = zero
              else
                exk = exp(-tk)
                xb  = (sy / sx) * xr
                yb  = (sx / sy) * yr
                call ccperrf(yb, xb, cby, cbx)
              endif
            endif

            phix = rk * (cry - exk * cby) * sign(one, xs)
            phiy = rk * (crx - exk * cbx) * sign(one, ys)
!---- orbit kick - only applied if option bborbit (HG 5/12/01),
!     else stored
            if (bborbit) then
              orbit(2) = orbit(2) + phix
              orbit(4) = orbit(4) + phiy
            elseif (bbd_flag .ne. 0)  then
              bb_kick(1,bbd_cnt) = phix
              bb_kick(2,bbd_cnt) = phiy
            endif

!---- first-order effects.
            phixx = (two / r2) * (- (xs * phix + ys * phiy)             &
     &      + fk * (one - (sy / sx) * exk))
            phixy = (two / r2) * (- (xs * phiy - ys * phix))
            phiyy = (two / r2) * (+ (xs * phix + ys * phiy)             &
     &      - fk * (one - (sx / sy) * exk))
            re(2,1) = phixx
            re(2,3) = phixy
            re(4,1) = phixy
            re(4,3) = phiyy

!---- second-order effects.
            if (fsec) then
              phixxx = (- phix - (xs * phixx + ys * phixy)              &
     &        + fk * xs * sy * exk / sx**3) / r2
              phixxy = (- phiy - (xs * phixy - ys * phixx)) / r2
              phixyy = (+ phix - (xs * phiyy - ys * phixy)) / r2
              phiyyy = (+ phiy + (xs * phixy + ys * phiyy)              &
     &        - fk * ys * sx * exk / sy**3) / r2
              te(2,1,1) = phixxx
              te(2,1,3) = phixxy
              te(2,3,1) = phixxy
              te(4,1,1) = phixxy
              te(2,3,3) = phixyy
              te(4,1,3) = phixyy
              te(4,3,1) = phixyy
              te(4,3,3) = phiyyy
            endif
          endif

!---- no tracking desired.
        else
          re(2,1) = fk / (sx * (sx + sy))
          re(4,3) = fk / (sy * (sx + sy))
        endif
!---- centre option
        if(centre_cptk) call twcptk(re,orbit)
        if(centre_bttk) call twbttk(re,te)
      endif

      end
      subroutine ccperrf(xx, yy, wx, wy)
      implicit none
!----------------------------------------------------------------------*
! purpose:                                                             *
!   modification of wwerf, double precision complex error function,    *
!   written at cern by K. Koelbig.                                     *
! input:                                                               *
!   xx, yy    (double)    real + imag argument                         *
! output:                                                              *
!   wx, wy    (double)    real + imag function result                  *
!----------------------------------------------------------------------*
      integer n,nc,nu
      double precision xx,yy,wx,wy,x,y,q,h,xl,xh,yh,tx,ty,tn,sx,sy,saux,&
     &rx(33),ry(33),cc,zero,one,two,half,xlim,ylim,fac1,fac2,fac3
      parameter(cc=1.12837916709551d0,zero=0d0,one=1d0,two=2d0,         &
     &half=5d-1,xlim=5.33d0,ylim=4.29d0,fac1=3.2d0,fac2=23d0,fac3=21d0)

      x = abs(xx)
      y = abs(yy)

      if (y .lt. ylim  .and.  x .lt. xlim) then
        q  = (one - y / ylim) * sqrt(one - (x/xlim)**2)
        h  = one / (fac1 * q)
        nc = 7 + int(fac2*q)
        xl = h**(1 - nc)
        xh = y + half/h
        yh = x
        nu = 10 + int(fac3*q)
        rx(nu+1) = zero
        ry(nu+1) = zero

        do n = nu, 1, -1
          tx = xh + n * rx(n+1)
          ty = yh - n * ry(n+1)
          tn = tx*tx + ty*ty
          rx(n) = half * tx / tn
          ry(n) = half * ty / tn
        enddo

        sx = zero
        sy = zero

        do n = nc, 1, -1
          saux = sx + xl
          sx = rx(n) * saux - ry(n) * sy
          sy = rx(n) * sy + ry(n) * saux
          xl = h * xl
        enddo

        wx = cc * sx
        wy = cc * sy
      else
        xh = y
        yh = x
        rx(1) = zero
        ry(1) = zero

        do n = 9, 1, -1
          tx = xh + n * rx(1)
          ty = yh - n * ry(1)
          tn = tx*tx + ty*ty
          rx(1) = half * tx / tn
          ry(1) = half * ty / tn
        enddo

        wx = cc * rx(1)
        wy = cc * ry(1)
      endif

!      if(y .eq. zero) wx = exp(-x**2)
      if(yy .lt. zero) then
        wx =   two * exp(y*y-x*x) * cos(two*x*y) - wx
        wy = - two * exp(y*y-x*x) * sin(two*x*y) - wy
        if(xx .gt. zero) wy = -wy
      else
        if(xx .lt. zero) wy = -wy
      endif

      end
      double precision function gauss_erf(x)
!---- returns the value of the Gauss error integral:
!     1/sqrt(2*pi) Int[-inf, x] exp(-x**2/2) dx
      implicit none
      double precision x,xx,re,im,zero,one,two,half
      parameter(zero=0d0,one=1d0,two=2d0,half=5d-1)

      xx = x / sqrt(two)
      call ccperrf(zero,xx,re,im)
      gauss_erf = one - half * exp(-xx**2) * re
      end
      subroutine twwmap(pos, orbit)
!----------------------------------------------------------------------*
! Purpose:                                                             *
!   Save concatenated sectormap (kick, rmatrix, tmatrix)               *
!   Input:                                                             *
!   pos   (double)  position                                           *
!   orbit (double)  current orbit                                      *
!   Further input in twissotm.fi                                       *
!----------------------------------------------------------------------*
      implicit none
      include 'twissotm.fi'
      integer i, k, l
      double precision sum1, sum2, pos, orbit(6)
      double precision ek(6)

*---- Track ORBIT0 using zero kick.
      do i = 1, 6
        sum2 = orbit(i)
        do k = 1, 6
          sum1 = 0.d0
          do l = 1, 6
            sum1 = sum1 + stmat(i,k,l) * sorb(l)
          enddo
          sum2 = sum2 - (srmat(i,k) - sum1) * sorb(k)
          srmat(i,k) = srmat(i,k) - 2.d0 * sum1
        enddo
        ek(i) = sum2
      enddo
      call dcopy(orbit, sorb, 6)
*---- Output.
      call sector_out(pos, ek, srmat, stmat)
!      write (99, '(g20.6)') pos
!      write (99, '(6e16.8)') ek
!      write (99, '(6e16.8)') srmat
!      write (99, '(6e16.8)') stmat
*---- re-initialize map.
      call m66one(srmat)
      call dzero(stmat, 216)

      end
