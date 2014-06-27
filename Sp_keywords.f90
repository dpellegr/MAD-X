!The Polymorphic Tracking Code
!Copyright (C) Etienne Forest and CERN

module madx_keywords
  use S_fitting
  implicit none
  public
  logical(lp)::mad8=my_false
  integer :: ifield_name=0
  logical(lp),private :: do_survey =.false.

  type keywords
     character*20 magnet
     character*20 model
     logical(lp) FIBRE_flip
     INTEGER FIBRE_DIR
     integer method
     integer nstep
     logical(lp) exact
     logical(lp) madLENGTH
     logical(lp) mad8
     real(dp) tiltd
     type(el_list) LIST
  end type keywords

  type MADX_SURVEY
     REAL(DP) ALPHA,TILT,LD
     REAL(DP) PHI,THETA,PSI
     TYPE(CHART) CHART
  END type MADX_SURVEY




contains




  subroutine create_fibre(el,key,EXCEPTION,magnet_only)
    implicit none
    integer ipause, mypause,i
    type(fibre), target, intent(inout)::el
    logical(lp), optional :: magnet_only
    type(keywords) key
    type(el_list) blank
    character*255 magnet
    character*17 MODEL
    INTEGER EXCEPTION  !,NSTD0,METD0
    LOGICAL(LP) EXACT0,magnet0
    logical(lp) FIBRE_flip0,MAD0
    logical(lp) :: t=.true.,f=.false.
    INTEGER FIBRE_DIR0,IL
    real(dp) e1_true,norm


    IL=15

    if(present(magnet_only)) then
       magnet0=magnet_only
    else
       magnet0=.false.
    endif

    blank=0
    magnet=key%magnet
    call context(magnet)
    model=key%model
    call context(model)

    CALL SET_MADX_(t,magnet0)


    select case(MODEL)
    CASE("DRIFT_KICK       ")
       MADTHICK=drift_kick_drift
    CASE("MATRIX_KICK      ")
       MADTHICK=matrix_kick_matrix
    CASE("DELTA_MATRIX_KICK")
       MADTHICK=kick_sixtrack_kick
    CASE DEFAULT
       EXCEPTION=1
       ipause=mypause(444)
       RETURN
    END SELECT

    !    NSTD0=NSTD
    !    METD0=METD
    EXACT0=EXACT_MODEL
    FIBRE_FLIP0= FIBRE_FLIP
    FIBRE_DIR0=FIBRE_DIR
    MAD0=MAD

    KEY%LIST%nst=KEY%NSTEP
    KEY%LIST%method=KEY%METHOD
    EXACT_MODEL=KEY%EXACT
    FIBRE_FLIP = KEY%FIBRE_FLIP
    FIBRE_DIR  = KEY%FIBRE_DIR
    MADLENGTH=KEY%MADLENGTH

    !     real(dp) L,LD,LC,K(NMAX),KS(NMAX)
    !     real(dp) ang(3),t(3)
    !     real(dp) angi(3),ti(3)
    !     integer patchg
    !     real(dp) T1,T2,B0
    !     real(dp) volt,freq0,harmon,lag,DELTA_E,BSOL
    !     real(dp) tilt
    !     real(dp) FINT,hgap,h1,h2,X_COL,Y_COL
    !     real(dp) thin_h_foc,thin_v_foc,thin_h_angle,thin_v_angle  ! highly illegal additions by frs
    !     CHARACTER(120) file
    !     CHARACTER(120) file_rev
    !    CHARACTER(nlp) NAME
    !     CHARACTER(vp) VORNAME
    !     INTEGER KIND,nmul,nst,method
    !     LOGICAL(LP) APERTURE_ON
    !     INTEGER APERTURE_KIND
    !     REAL(DP) APERTURE_R(2),APERTURE_X,APERTURE_Y
    !     LOGICAL(LP) KILL_ENT_FRINGE,KILL_EXI_FRINGE,BEND_FRINGE,PERMFRINGE
    !     REAL(DP) DPHAS,PSI,dvds
    !     INTEGER N_BESSEL

    if(sixtrack_compatible) then
       EXACT_MODEL=.false.
       KEY%LIST%method=2
       MADTHICK=drift_kick_drift
    endif


    SELECT CASE(magnet(1:IL))
    CASE("DRIFT          ")
       BLANK=DRIFT(KEY%LIST%NAME,LIST=KEY%LIST)
    CASE("SOLENOID       ")
       if(sixtrack_compatible) stop 1
       if(KEY%LIST%L/=zero) then
          BLANK=SOLENOID(KEY%LIST%NAME,t=tilt.is.KEY%tiltd,LIST=KEY%LIST)
       else
          write(6,*) "switch solenoid to dubious thin multipole "
          BLANK=MULTIPOLE_BLOCK(KEY%LIST%NAME,t=tilt.is.KEY%tiltd,LIST=KEY%LIST)
       endif
    CASE("QUADRUPOLE     ")
       BLANK=QUADRUPOLE(KEY%LIST%NAME,t=tilt.is.KEY%tiltd,LIST=KEY%LIST)
    CASE("SEXTUPOLE     ")
       BLANK=SEXTUPOLE(KEY%LIST%NAME,t=tilt.is.KEY%tiltd,LIST=KEY%LIST)
    CASE("OCTUPOLE      ")
       BLANK=OCTUPOLE(KEY%LIST%NAME,t=tilt.is.KEY%tiltd,LIST=KEY%LIST)
    CASE("SBEND         ")
       BLANK=SBEND(KEY%LIST%NAME,t=tilt.is.KEY%tiltd,LIST=KEY%LIST)
    CASE("TRUERBEND     ")
       if(sixtrack_compatible) stop 2

       e1_true= KEY%LIST%b0/two+ KEY%LIST%t1
       BLANK=rbend(KEY%LIST%NAME,l=KEY%LIST%l,angle=KEY%LIST%b0,e1=e1_true,list=KEY%LIST)

    CASE("WEDGRBEND     ")
       if(sixtrack_compatible) stop 3

       BLANK=rbend(KEY%LIST%NAME,l=KEY%LIST%l,angle=KEY%LIST%b0,e1=KEY%LIST%t1,e2=KEY%LIST%t2,list=KEY%LIST)

    CASE("RBEND         ")
       if(sixtrack_compatible) stop 4
       KEY%LIST%T1=KEY%LIST%T1+KEY%LIST%B0/two
       KEY%LIST%T2=KEY%LIST%T2+KEY%LIST%B0/two
       BLANK=SBEND(KEY%LIST%NAME,t=tilt.is.KEY%tiltd,LIST=KEY%LIST)
    CASE("KICKER         ","VKICKER        ","HKICKER        ")
       BLANK=KICKER(KEY%LIST%NAME,t=tilt.is.KEY%tiltd,LIST=KEY%LIST)
    CASE("MONITOR        ")
       if(sixtrack_compatible) then
          BLANK=DRIFT(KEY%LIST%NAME,LIST=KEY%LIST)
       else
          BLANK=MONITOR(KEY%LIST%NAME,t=tilt.is.KEY%tiltd,LIST=KEY%LIST)
       endif
    CASE("HMONITOR        ")
       if(sixtrack_compatible) then
          BLANK=DRIFT(KEY%LIST%NAME,LIST=KEY%LIST)
       else
          BLANK=MONITOR(KEY%LIST%NAME,t=tilt.is.KEY%tiltd,LIST=KEY%LIST) ;BLANK%KIND=KIND12;
       endif
    CASE("VMONITOR       ")
       if(sixtrack_compatible) then
          BLANK=DRIFT(KEY%LIST%NAME,LIST=KEY%LIST)
       else
          BLANK=MONITOR(KEY%LIST%NAME,t=tilt.is.KEY%tiltd,LIST=KEY%LIST) ;BLANK%KIND=KIND13;
       endif
    CASE("INSTRUMENT     ")
       if(sixtrack_compatible) then
          BLANK=DRIFT(KEY%LIST%NAME,LIST=KEY%LIST)
       else
          BLANK=MONITOR(KEY%LIST%NAME,t=tilt.is.KEY%tiltd,LIST=KEY%LIST) ;BLANK%KIND=KIND14;
       endif
    CASE("MARKER         ")
       BLANK=MARKER(KEY%LIST%NAME)
    CASE("CHANGEREF      ")
       if(sixtrack_compatible) stop 5
       BLANK=CHANGEREF(KEY%LIST%NAME,KEY%LIST%ANG,KEY%LIST%T,KEY%LIST%PATCHG)
    CASE("RFCAVITY       ")
       if(sixtrack_compatible) then
          If(KEY%LIST%L/=zero) stop 60
          If(KEY%LIST%N_BESSEL/=zero) stop 61
          norm=zero
          do i=1,nmax
             norm=norm+abs(KEY%LIST%k(i))+abs(KEY%LIST%ks(i))
          enddo
          norm=norm-abs(KEY%LIST%k(2))
          if(norm/=zero) then
             write(6,*) norm
             stop 62
          endif
       endif
       BLANK=RFCAVITY(KEY%LIST%NAME,LIST=KEY%LIST)
    CASE("TWCAVITY       ")
       if(sixtrack_compatible) stop 7
       BLANK=TWCAVITY(KEY%LIST%NAME,LIST=KEY%LIST)
    CASE("ELSEPARATOR    ")
       if(sixtrack_compatible) stop 8
       BLANK=ELSEPARATOR(KEY%LIST%NAME,t=tilt.is.KEY%tiltd,LIST=KEY%LIST)
    CASE("MULTIPOLE_BLOCK","MULTIPOLE      ")
       BLANK=MULTIPOLE_BLOCK(KEY%LIST%NAME,t=tilt.is.KEY%tiltd,LIST=KEY%LIST)
    CASE("SMI            ","SINGLE_LENS    ")
       if(sixtrack_compatible) stop 9
       BLANK=SINGLE_LENS(KEY%LIST%NAME,t=tilt.is.KEY%tiltd,LIST=KEY%LIST)
    CASE("RCOLLIMATOR    ")
       if(sixtrack_compatible) stop 10
       BLANK=RCOLLIMATOR(KEY%LIST%NAME,t=tilt.is.KEY%tiltd,LIST=KEY%LIST)
    CASE("ECOLLIMATOR    ")
       if(sixtrack_compatible) then
          BLANK=DRIFT(KEY%LIST%NAME,LIST=KEY%LIST)
       else
          BLANK=ECOLLIMATOR(KEY%LIST%NAME,t=tilt.is.KEY%tiltd,LIST=KEY%LIST)
       endif
    CASE("WIGGLER        ")
       if(sixtrack_compatible) stop 12
       BLANK=WIGGLER(KEY%LIST%NAME,t=tilt.is.KEY%tiltd,LIST=KEY%LIST)
    CASE("HELICALDIPOLE  ")
       if(sixtrack_compatible) stop 13
       BLANK=HELICAL(KEY%LIST%NAME,LIST=KEY%LIST)
       !    CASE("TAYLORMAP      ")
       !       IF(KEY%LIST%file/=' '.and.KEY%LIST%file_rev/=' ') THEN
       !          BLANK=TAYLOR_MAP(KEY%LIST%NAME,FILE=KEY%LIST%file,FILE_REV=KEY%LIST%file_REV,t=tilt.is.KEY%tiltd)
       !       ELSEIF(KEY%LIST%file/=' '.and.KEY%LIST%file_rev==' ') THEN
       !          BLANK=TAYLOR_MAP(KEY%LIST%NAME,FILE=KEY%LIST%file,t=tilt.is.KEY%tiltd)
       !       ELSEIF(KEY%LIST%file==' '.and.KEY%LIST%file_rev/=' ') THEN
       !          BLANK=TAYLOR_MAP(KEY%LIST%NAME,FILE_REV=KEY%LIST%file_REV,t=tilt.is.KEY%tiltd)
       !       ELSE
       !          BLANK=TAYLOR_MAP(KEY%LIST%NAME,t=tilt.is.KEY%tiltd)
       !       ENDIF
    CASE DEFAULT
       WRITE(6,*) " "
       WRITE(6,*) " THE MAGNET"
       WRITE(6,*) " "
       WRITE(6,*) "  --->   ",MAGNET(1:IL)
       WRITE(6,*) " "
       WRITE(6,*)  " IS NOT PERMITTED "
       STOP 666
    END SELECT

    BLANK%VORNAME = KEY%LIST%VORNAME
    CALL EL_Q_FOR_MADX(EL,BLANK)
    !  added 2007.07.09
    el%mag%parent_fibre =>el
    el%magp%parent_fibre=>el
    !  end of added 2007.07.09


    CALL SET_MADX_(f,f)

    !    NSTD=NSTD0
    !    METD=METD0
    EXACT_MODEL=EXACT0
    FIBRE_FLIP= FIBRE_FLIP0
    FIBRE_DIR=FIBRE_DIR0
    MAD=MAD0

    !    IF(ASSOCIATED(EL%PREVIOUS)) THEN
    !     if(.not.associated(EL%POS))allocate(EL%POS)
    !     EL%POS=EL%PREVIOUS%POS+1
    !    ELSE
    !     if(.not.associated(EL%POS))allocate(EL%POS)
    !     EL%POS=1
    !    ENDIF
  end subroutine create_fibre

  subroutine zero_key(key)
    implicit none

    type(keywords) , intent(out):: key
    key%magnet="CROTTE"
    select case(MADTHICK)
    CASE(drift_kick_drift)
       key%model="DRIFT_KICK       "
    CASE(matrix_kick_matrix)
       key%model="MATRIX_KICK      "
    CASE(kick_sixtrack_kick)
       key%model="DELTA_MATRIX_KICK"
    END SELECT


    key%FIBRE_flip=FIBRE_flip
    key%FIBRE_DIR=FIBRE_DIR
    key%method=METD
    key%nstep=NSTD
    key%exact=EXACT_MODEL
    key%madLENGTH=madLENGTH
    key%LIST%NMUL = 1
    key%mad8 = mad8
    key%tiltd=ZERO
    key%LIST=0

  end subroutine zero_key

  !  PRINTING FIBRES FOR FLAT FILES
  subroutine print_COMPLEX_SINGLE_STRUCTURE(L,FILENAME,LMAX0,NL)
    implicit none
    character(*) filename
    integer I,MF,N,n_l
    type(LAYOUT), TARGET :: L
    type(LAYOUT), pointer :: CL
    REAL(DP),OPTIONAL :: LMAX0
    integer,OPTIONAL :: NL

    n_l=0
    if(present(nl)) n_l=nl
    call kanalnummer(mf)
    open(unit=mf,file=filename)
    IF(ASSOCIATED(L%DNA)) THEN
       N=SIZE(L%DNA)
       Write(mf,*) N,N_L, " Number of pointers in the DNA array pointed at layouts"

       DO I=1,N
          L%DNA(I)%L%INDEX=I
          CALL print_LAYOUT(L%DNA(I)%L,FILENAME,LMAX0,MF)
       ENDDO
       !       ENDIF

       !       write(mf,*) " Beam Line DNA structure "
       !       do i=1,N
       !        ncon1=0
       !        ncon2=0
       !        if(associated(L%DNA(i)%L%con1)) then
       !         ncon1=size(L%DNA(i)%L%con1)
       !         ncon2=size(L%DNA(i)%L%con2)
       !          write(mf,*) ncon1,ncon2


       !          do j=1,max(ncon1,ncon2)
       !           if(j>ncon1) then
       !             write(mf,*) 0, L%DNA(i)%L%con2(j)%pos
       !            elseif(j>ncon2) then
       !             write(mf,*)  L%DNA(i)%L%con1(j)%pos,0
       !            else
       !             write(mf,*)  L%DNA(i)%L%con1(j)%pos, L%DNA(i)%L%con2(j)%pos
       !           endif
       !          enddo
       !        else
       !          write(mf,*) ncon1,ncon2
       !        endif
       !      enddo

       !       write(mf,*) " End of Beam Line DNA structure "

    ENDIF

    CL=>L


    if(n_l>0) then
       do i=1,n_l
          ! write(mf,*) " Beam Line DNA structure "
          ! write(mf,*) " End of Beam Line DNA structure "
          CALL print_LAYOUT(CL,FILENAME,LMAX0,MF)
          CL=>CL%NEXT
       enddo
    else
       CALL print_LAYOUT(L,FILENAME,LMAX0,MF)
    endif

    CLOSE(MF)
  END SUBROUTINE print_COMPLEX_SINGLE_STRUCTURE

  subroutine print_LAYOUT(L,FILENAME,LMAX0,MFF)
    implicit none
    character(*) filename
    integer I,MF
    INTEGER, OPTIONAL :: MFF
    type(LAYOUT), TARGET :: L
    type(FIBRE), pointer :: P
    REAL(DP),OPTIONAL :: LMAX0
    character*255 line
    logical(lp) print_temp

    IF(PRESENT(MFF)) THEN
       MF=MFF
    ELSE
       call kanalnummer(mf)
       open(unit=mf,file=filename)
    ENDIF

    IF(PRESENT(LMAX0)) THEN
       WRITE(MF,*) L%N, LMAX0, " NUMBER OF FIBRES AND L_MAX  "
    ELSE
       WRITE(MF,*) L%N, 0, " NUMBER OF FIBRES AND L_MAX  "
    ENDIF
    if(l%name(1:1)/=' ') then
       write(MF,'(a17,a16)') " GLOBAL DATA FOR ",l%name
    else
       write(MF,*) " $$$$$$$$$ GLOBAL DATA  $$$$$$$$$"
    endif

    write(line,*) l%start%mass,L%START%mag%p%p0c,l%start%ag, " MASS, P0C, AG(spin)"
    write(MF,'(a255)') line
    write(MF,*) phase0,stoch_in_rec,l%start%charge, " PHASE0, STOCH_IN_REC, CHARGE"
    write(MF,*) CAVITY_TOTALPATH,ALWAYS_EXACTMIS,ALWAYS_EXACT_PATCHING, &
         "CAVITY_TOTALPATH,ALWAYS_EXACTMIS,ALWAYS_EXACT_PATCHING"
    write(line,*) SECTOR_NMUL_MAX,SECTOR_NMUL,&
         OLD_IMPLEMENTATION_OF_SIXTRACK,HIGHEST_FRINGE,&
         " SECTOR_NMUL_MAX,SECTOR_NMUL,OLD_IMPLEMENTATION_OF_SIXTRACK,HIGHEST_FRINGE"
    write(mf,'(a255)')line
    write(MF,*) wedge_coeff, " wedge_coeff"
    write(MF,*) MAD8_WEDGE, " MAD8_WEDGE"
    write(MF,*) " $$$$$$$ END GLOBAL DATA $$$$$$$$$$"


    P=>L%START
    DO I=1,L%N
       if(i==1) then
          print_temp=print_frame
          print_frame=my_true
       endif
       CALL print_FIBRE(P,mf)
       if(i==1) then
          print_frame=print_temp
       endif
       P=>P%NEXT
    ENDDO

    IF(.NOT.PRESENT(MFF)) CLOSE(MF)

  END subroutine print_LAYOUT


  subroutine READ_INTO_VIRGIN_LAYOUT(L,FILENAME,RING,LMAX0,mf1)
    implicit none
    character(*) filename
    integer mf,I,N,RES,se1,se2
    integer, optional :: mf1
    type(LAYOUT), TARGET :: L
    LOGICAL(LP), OPTIONAL :: RING
    REAL(DP), OPTIONAL :: LMAX0
    LOGICAL(LP) RING_IT,doneit
    character*255 line
    character*255 lineg
    real(dp) p0c,MASSF,ag0
    type(internal_state) original

    RING_IT=MY_TRUE

    IF(PRESENT(RING)) RING_IT=RING

    if(present(mf1)) then
       mf=mf1
    else
       call kanalnummer(mf)
       open(unit=mf,file=filename,status='OLD',err=2001)
    endif

    IF(PRESENT(LMAX0)) then
       READ(MF,*) N,LMAX0
    ELSE
       READ(MF,*) N
    ENDIF
    read(MF,'(a255)') line
    call context(line)

    if(index(line,"FOR")/=0) then
       l%name=line(index(line,"FOR")+3:index(line,"FOR")+2+nlp)
    endif
    read(MF,'(A255)') lineg
    res=INDEX (lineG, "AG(spin)")
    IF(RES==0) THEN
       read(lineg,*) MASSF,p0c
       IF(ABS(MASSF-pmap)/PMAP<0.01E0_DP) THEN
          A_PARTICLE=A_PROTON
       ELSEIF(ABS(MASSF-pmae)/pmae<0.01E0_DP) THEN
          A_PARTICLE=A_ELECTRON
       ELSEIF(ABS(MASSF-pmaMUON)/pmaMUON<0.01E0_DP) THEN
          A_PARTICLE=A_MUON
       ENDIF
    ELSE
       read(lineg,*) MASSF,p0c,A_PARTICLE
    ENDIF
    ag0=A_PARTICLE
    read(MF,*) phase0,stoch_in_rec,initial_charge
    read(MF,*) CAVITY_TOTALPATH,ALWAYS_EXACTMIS,ALWAYS_EXACT_PATCHING
    read(MF,*) se1,se2,OLD_IMPLEMENTATION_OF_SIXTRACK,HIGHEST_FRINGE
    if(SECTOR_NMUL_MAX/=se1) then
       write(6,*) " SECTOR_NMUL_MAX is changed from ",SECTOR_NMUL_MAX
       write(6,*) " to ",se1
       write(6,*) " Watch out : GLOBAL VARIABLE "
    endif
    if(SECTOR_NMUL/=se2) then
       write(6,*) " SECTOR_NMUL is changed from ",SECTOR_NMUL
       write(6,*) " to ",se2
       write(6,*) " Watch out : GLOBAL VARIABLE "
    endif
    SECTOR_NMUL_MAX=se1
    SECTOR_NMUL=se2
    read(MF,*) wedge_coeff
    read(MF,*) MAD8_WEDGE
    read(MF,'(a255)') line
    original=default
    if(allocated(s_b)) then
       firsttime_coef=.true.
       deallocate(s_b)
    endif
    !    L%MASS=MASSF
    MASSF=MASSF/pmae
    CALL MAKE_STATES(MASSF)
    A_PARTICLE=ag0
    default=original
    call Set_madx(p0c=p0c)
    DO I=1,N
       CALL APPEND_CLONE(L,muonfactor=massf,charge=initial_charge)
       CALL READ_FIBRE(L%END,mf)
       CALL COPY(L%END%MAG,L%END%MAGP)
    ENDDO

    if(.not.present(mf1)) CLOSE(MF)

    L%closed=RING_IT

    doneit=.true.
    call ring_l(L,doneit)
    ! if(do_survey) call survey(L)

    return

2001 continue

    Write(6,*) " File ",filename(1:len_trim(filename)) ," does not exist "

  END subroutine READ_INTO_VIRGIN_LAYOUT

  subroutine READ_AND_APPEND_VIRGIN_general(U,filename,RING,LMAX0)
    implicit none
    character(*) filename
    integer  mf
    type(MAD_UNIVERSE), TARGET :: U
    LOGICAL(LP), OPTIONAL :: RING
    REAL(DP), OPTIONAL :: LMAX0
    character*120 line
    integer res

    res=0
    call kanalnummer(mf)
    open(unit=mf,file=filename,status='OLD',err=2001)
    read(mf,'(a120)') line
    res=INDEX (line, "DNA")
    if(res/=0) res=1
    close(mf)

    if(res==1) then
       call read_COMPLEX_SINGLE_STRUCTURE(U,filename,RING,LMAX0)
    else
       call APPEND_EMPTY_LAYOUT(U)

       CALL READ_INTO_VIRGIN_LAYOUT(U%END,FILENAME,RING,LMAX0)
       ! if(do_survey) call survey(u%end)
    endif
    do_survey=.false.
    return
2001 continue

    Write(6,*) " File ",filename(1:len_trim(filename)) ," does not exist "

  END subroutine READ_AND_APPEND_VIRGIN_general

  subroutine READ_AND_APPEND_VIRGIN_LAYOUT(U,filename,RING,LMAX0,mf)
    implicit none
    character(*) filename
    integer,optional:: mf
    type(MAD_UNIVERSE), TARGET :: U
    LOGICAL(LP), OPTIONAL :: RING
    REAL(DP), OPTIONAL :: LMAX0


    call APPEND_EMPTY_LAYOUT(U)

    CALL READ_INTO_VIRGIN_LAYOUT(U%END,FILENAME,RING,LMAX0=LMAX0,mf1=MF)

  END subroutine READ_AND_APPEND_VIRGIN_LAYOUT

  subroutine print_FIBRE(m,mf)
    implicit none
    integer mf,siam_pos,siam_index,GIRD_POS,GIRD_index
    type(FIBRE), pointer :: m
    siam_pos=0
    siam_index=0
    GIRD_POS=0
    GIRD_index=0
    if(associated(m%mag%siamese)) then
       siam_index=m%mag%siamese%parent_fibre%parent_layout%index
       siam_pos=m%mag%siamese%parent_fibre%pos
    endif
    if(associated(m%mag%GIRDERS)) then
       GIRD_index=m%mag%GIRDERS%parent_fibre%parent_layout%index
       GIRD_POS=m%mag%GIRDERS%parent_fibre%pos
    endif
    WRITE(MF,*) " @@@@@@@@@@@@@@@@@@@@ FIBRE @@@@@@@@@@@@@@@@@@@@"
    if(siam_index==0.AND.GIRD_index==0) then
       WRITE(MF,'(A11,4(I4,1x))') " DIRECTION ", M%DIR, &
            m%mag%parent_fibre%parent_layout%index,m%mag%parent_fibre%pos, &
            m%mag%parent_fibre%parent_layout%n
    else

       WRITE(MF,'(A11,4(I4,1x),A16,4(I4,1x))') " DIRECTION ", M%DIR, &
            m%mag%parent_fibre%parent_layout%index,m%mag%parent_fibre%pos, &
            m%mag%parent_fibre%parent_layout%n," Siamese/Girder "         &
            ,siam_pos,siam_index,GIRD_POS,GIRD_index
    endif
    CALL print_chart(m%CHART,mf)
    CALL print_PATCH(m%PATCH,mf)
    CALL print_element(M,M%MAG,mf)
    WRITE(MF,*) " @@@@@@@@@@@@@@@@@@@@  END  @@@@@@@@@@@@@@@@@@@@"

  END subroutine print_FIBRE

  subroutine READ_FIBRE(m,mf)
    implicit none
    integer mf
    type(FIBRE), pointer :: m
    character*255 line
    READ(MF,*) LINE
    READ(MF,'(A11,I4)') LINE(1:11),M%DIR
    CALL READ_chart(m%CHART,mf)
    CALL READ_PATCH(m%PATCH,mf)
    CALL READ_element(m,M%MAG,mf)
    READ(MF,*) LINE

  END subroutine READ_FIBRE

  subroutine READ_FIBRE_2_lines(mf,DIR,index,pos,n,siam_index,siam_pos,gird_index,gird_pos)
    implicit none
    integer mf
    character*255 line

    integer DIR,index,pos,n,siam_index,siam_pos,gird_index,gird_pos
    READ(MF,*) LINE
    siam_index=0
    siam_pos=0
    gird_index=0
    gird_pos=0
    READ(MF,'(A11,4(I4,1x),A16,4(I4,1x))') LINE(1:11),DIR,index,pos,n, &
         LINE(12:27),siam_pos,siam_index,gird_index,gird_pos
    !    CALL READ_chart(m%CHART,mf)
    !    CALL READ_PATCH(m%PATCH,mf)
    !    CALL READ_element(M%MAG,mf)
    !    READ(MF,*) LINE

  END subroutine READ_FIBRE_2_lines

  subroutine print_PATCH(m,mf)
    implicit none
    integer mf,i1,i2,i3
    type(PATCH), pointer :: m
    character*255 line

    i1=M%PATCH
    i2=M%energy
    i3=M%time

    IF(IABS(i1)+iabs(i2)+iabs(i3)/=0) then
       WRITE(MF,*) " >>>>>>>>>>>>>>>>>> PATCH <<<<<<<<<<<<<<<<<<"
       WRITE(MF,*) M%PATCH,M%ENERGY,M%TIME," patch,energy,time"
       WRITE(MF,*) M%A_X1,M%A_X2,M%B_X1,M%B_X2," discrete 180 rotations"
       WRITE(LINE,*) M%A_D,M%A_ANG,"  a_d, a_ang "
       WRITE(MF,'(A255)') LINE
       WRITE(LINE,*) M%B_D,M%B_ANG,"  b_d, b_ang "
       WRITE(MF,'(A255)') LINE
       WRITE(MF,*) M%A_T,M%B_T,"  time patches a_t and b_t "
       WRITE(MF,*) " >>>>>>>>>>>>>>>>>>  END  <<<<<<<<<<<<<<<<<<"
    else
       WRITE(MF,*) " NO PATCH "
    endif
  END subroutine print_PATCH

  subroutine READ_PATCH(m,mf)
    implicit none
    integer mf
    type(PATCH), pointer :: m
    character*255 line

    READ(MF,*)LINE
    if(index(line,"NO")==0) then
       READ(MF,*) M%PATCH,M%ENERGY,M%TIME
       READ(MF,*) M%A_X1,M%A_X2,M%B_X1,M%B_X2
       READ(MF,*) M%A_D,M%A_ANG
       READ(MF,*) M%B_D,M%B_ANG
       READ(MF,*) M%A_T,M%B_T
       READ(MF,*) LINE
    endif

  END subroutine READ_PATCH

  subroutine print_chart(m,mf)
    implicit none
    integer mf,I
    type(CHART), pointer :: m
    character*255 line
    real(dp) norm

    norm=zero
    do i=1,3
       norm=abs(M%D_IN(i))+norm
       norm=abs(M%ANG_IN(i))+norm
       norm=abs(M%ANG_OUT(i))+norm
       norm=abs(M%D_OUT(i))+norm
    enddo
    if(norm>zero.OR.print_frame) then
       write(mf,*) " THIS IS A CHART THIS IS A CHART THIS IS A CHART THIS IS A CHART "
       CALL print_magnet_frame(m%F,mf)
       WRITE(LINE,*) M%D_IN,M%ANG_IN
       WRITE(MF,'(A255)') LINE
       WRITE(LINE,*) M%D_OUT,M%ANG_OUT
       WRITE(MF,'(A255)') LINE
       write(mf,*) " END OF A CHART  END OF A CHART  END OF A CHART  END OF A CHART  "
    else
       write(mf,*) " NO CHART "
    endif
  end subroutine print_chart

  subroutine READ_chart(m,mf)
    implicit none
    integer mf
    type(CHART), pointer :: m
    character*60 line
    READ(mf,*) LINE
    if(index(line,"NO")==0) then
       CALL READ_magnet_frame(m%F,mf)
       READ(MF,*) M%D_IN,M%ANG_IN
       READ(MF,*) M%D_OUT,M%ANG_OUT
       READ(mf,*) LINE
    else
       do_survey=.true.
    endif
  end subroutine READ_chart


  subroutine READ_chart_fake(mf)
    implicit none
    integer mf
    character*60 line
    type(magnet_frame), pointer :: f
    real(dp) d1(3),d2(3)

    call alloc(f)

    READ(mf,*) LINE
    if(index(line,"NO")==0) then
       CALL READ_magnet_frame(F,mf)
       READ(MF,*) d1,d2
       READ(MF,*) d1,d2
       READ(mf,*) LINE
    else
       do_survey=.true.
    endif
    call kill(f)
  end subroutine READ_chart_fake


  subroutine print_element(P,m,mf)
    implicit none
    integer mf,I
    type(FIBRE), pointer :: P
    type(element), pointer :: m
    character*255 line
    integer f0
    f0=1

    WRITE(MF,*) "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ ELEMENT $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    if(m%vorname(1:1)==' ') then
       WRITE(MF,*) M%KIND,M%NAME, ' NOVORNAME'
    ELSE
       WRITE(MF,*) M%KIND,M%NAME,' ',M%VORNAME
    ENDIF
    WRITE(MF,*) M%L,M%PERMFRINGE,M%MIS , " L,PERMFRINGE,MIS "
    WRITE(LINE,*) M%FINT,M%HGAP,M%H1,M%H2, " FINT,HGAP,H1,H2 "
    WRITE(MF,'(A255)') LINE
    WRITE(LINE,*) 0.d0,0.d0,0.d0,0.d0,0.d0,0.d0, " no more mis"
    WRITE(MF,'(A255)') LINE
    IF(ASSOCIATED(M%DELTA_E).and.ASSOCIATED(M%FREQ)) THEN
       WRITE(MF,*) " CAVITY INFORMATION "
       WRITE(LINE,*) M%VOLT, M%FREQ,M%PHAS,M%DELTA_E,M%LAG,M%THIN, " VOLT,FREQ, PHAS, DELTA_E, LAG, THIN"
       WRITE(MF,'(A255)') LINE
    ELSEIF(.not.ASSOCIATED(M%DELTA_E).and.ASSOCIATED(M%FREQ)) THEN
       WRITE(MF,*) " HELICAL DIPOLE INFORMATION "
       WRITE(LINE,*) M%FREQ,M%PHAS, " K_Z, PHAS"
       WRITE(MF,'(A255)') LINE
    ELSEIF(ASSOCIATED(M%VOLT)) THEN
       WRITE(MF,*) " ELECTRIC SEPTUM INFORMATION "
       WRITE(MF,*) M%VOLT,M%PHAS, "VOLT, PHAS(rotation angle) "
    ELSE
       WRITE(MF,*) " NO ELECTRIC ELEMENT INFORMATION "
    ENDIF
    IF(ASSOCIATED(M%B_SOL)) THEN
       WRITE(MF,*)  " SOLENOID_PRESENT ",M%B_SOL, " B_SOL"
    ELSE
       WRITE(MF,*) " NO_SOLENOID_PRESENT ",zero
    ENDIF
    CALL print_magnet_chart(P,m%P,mf)
    if(p%MAG%KIND==KIND7) then
       f0=p%MAG%t7%f
    endif
    if(p%MAG%KIND==KIND2.and.p%MAG%p%method==2) then
       f0=p%MAG%k2%f
    endif
    if(associated(p%MAG%K16)) then
       if(p%MAG%K16%DRIFTKICK.and.p%MAG%p%method==2)  f0=p%MAG%K16%f
    endif
    if(associated(p%MAG%TP10)) then
       if(p%MAG%TP10%DRIFTKICK.and.p%MAG%p%method==2) f0=p%MAG%TP10%f
    endif
    !    if(f0>0) then
    !     Write(mf,*) f0," Internal Recutting "
    !    endif
    IF(ASSOCIATED(M%an)) THEN
       do i=1,m%p%NMUL
          write(line,*) m%bn(i),m%an(i),f0, "  BN AN %f ",I
          write(mf,'(a255)') line
       enddo
    endif
    call print_specific_element(m,mf)
    WRITE(MF,*) "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$   END   $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
  end subroutine print_element

  subroutine print_pancake(el,mf)
    implicit none
    type(pancake), pointer :: el
    integer mf
    character*120 filename

    ifield_name=ifield_name+1
    filename(1:8)="fieldmap"
    write(filename(9:120),*) ifield_name
    call context(filename)
    filename=filename(1:len_trim(filename))//'.TXT'
    call context(filename)
    write(mf,*) filename
    call print_pancake_field(el,filename)
  end subroutine print_pancake


  subroutine print_pancake_field(el,filename)
    implicit none
    type(pancake), pointer :: el
    integer mf,nst,i,j
    character(*) filename
    real(dp) brho,cl
    type(real_8) b(3)


    call kanalnummer(mf)
    open(unit=mf,file=filename)

    nst=2*el%p%nst+1

    cl=(clight/c_1d8)
    BRHO=el%p%p0c*ten/cl

    call init(EL%B(1)%no,2)
    CALL ALLOC(B)

    write(mf,*) nst,el%p%ld,el%p%b0,EL%B(1)%no,.false.
    do i=1,nst
       B(1)=morph(one.mono.1)
       B(2)=morph(one.mono.2)
       B(3)=ZERO;
       CALL trackg(EL%B(i),B)
       do j=1,3
          b(j)=b(j)*brho
          call print(b(j),mf)
       enddo

    enddo
    CALL kill(B)

    close(mf)

  end subroutine print_pancake_field




  subroutine print_wig(el,mf)
    implicit none
    type(SAGAN), pointer :: el
    integer mf
    write(mf,*) el%internal
    call print_undu_R(el%w,mf)
  end subroutine print_wig

  subroutine read_wig(el,mf)
    implicit none
    type(SAGAN), pointer :: el
    integer mf
    if(.not.associated(el%internal)) allocate(el%internal(3))
    read(mf,*) el%internal
    call read_undu_R(el%w,mf)
  end subroutine read_wig

  subroutine print_undu_R(el,mf)
    implicit none
    type(undu_R), pointer :: el
    integer mf,n,i
    character*255 line

    write(mf,*) " Undulator internal type undu_R"
    n=size(EL%FORM)

    write(mf,*) n,EL%offset
    do i=1,n
       write(line,*) el%a(i),el%f(i),EL%FORM(i),EL%K(1:3,i)
       write(mf,'(a255)') line
    enddo

    write(mf,*) " End of Undulator internal type undu_R"

  end subroutine print_undu_R

  subroutine read_undu_R(el,mf)
    implicit none
    type(undu_R), pointer :: el
    integer mf,n,i
    character*255 line
    real(dp) offset

    read(mf,'(a255)') line
    read(mf,*) n,offset
    call INIT_SAGAN_POINTERS(EL,N)
    el%offset=offset
    do i=1,n
       read(mf,*) el%a(i),el%f(i),EL%FORM(i),EL%K(1:3,i)
    enddo

    read(mf,'(a255)') line

  end subroutine read_undu_R


  subroutine print_specific_element(el,mf)
    implicit none
    type(element), pointer :: el
    integer mf,i
    character*255 line

    select case(el%kind)
    CASE(KIND0,KIND1,kind2,kind5,kind6,kind7,kind8,kind9,KIND11:KIND15,kind17,KIND22)
    case(kind3)
       WRITE(LINE,*) el%k3%thin_h_foc,el%k3%thin_v_foc,el%k3%thin_h_angle,el%k3%thin_v_angle," patch_edge_ls ",&
            el%k3%patch,el%k3%hf,el%k3%vf,el%k3%ls
       WRITE(MF,'(A255)') LINE
    case(kind4)
       WRITE(line,*) el%c4%N_BESSEL, " HARMON ",el%c4%NF," constant&ripple ",el%c4%a,el%c4%r,el%c4%always_on
       WRITE(MF,'(A255)') LINE
       WRITE(MF,*) el%c4%t,el%c4%phase0,el%c4%CAVITY_TOTALPATH
       do i=1,el%c4%NF
          write(mf,*) el%c4%f(i),el%c4%ph(i)
       enddo
    case(kind10)
       WRITE(MF,*) el%tp10%DRIFTKICK,  " driftkick "
    case(kind16,kind20)
       WRITE(MF,*) el%k16%DRIFTKICK,el%k16%LIKEMAD, " driftkick,likemad"
    case(kind18)
       WRITE(MF,*) " RCOLLIMATOR HAS AN INTRINSIC APERTURE "
       CALL print_aperture(EL%RCOL18%A,mf)
    case(kind19)
       WRITE(MF,*) " ECOLLIMATOR HAS AN INTRINSIC APERTURE "
       CALL print_aperture(EL%ECOL19%A,mf)
    case(kind21)
       WRITE(MF,*) el%cav21%PSI,el%cav21%DPHAS,el%cav21%DVDS
    case(KINDWIGGLER)
       call print_wig(el%wi,mf)
    case(KINDpa)
       call print_pancake(el%pa,mf)
    case default
       write(6,*) " not supported in print_specific_element",el%kind
       stop 101
    end select

  end subroutine print_specific_element

  subroutine read_specific_element(el,mf)
    implicit none
    type(element), pointer :: el
    integer mf,NB,NH,i,i1
    CHARACTER*6 HARMON
    CHARACTER*15 rip
    character*255 line
    real(dp) x1,x2,x3,x4
    logical(lp) always_on
    select case(el%kind)
    CASE(KIND0,KIND1,kind2,kind5,kind6,kind7,kind8,kind9,KIND11:KIND15,kind17,kind22)
       CALL SETFAMILY(EL)   ! POINTERS MUST BE ESTABLISHED BETWEEN GENERIC ELEMENT M AND SPECIFIC ELEMENTS
    case(kind3)
       IF(.NOT.ASSOCIATED(el%B_SOL)) then
          ALLOCATE(el%B_SOL)
          el%B_SOL=zero
       endif
       CALL SETFAMILY(EL)   ! POINTERS MUST BE ESTABLISHED BETWEEN GENERIC ELEMENT M AND SPECIFIC ELEMENTS
       READ(MF,"(a255)") LINE
       if(index(line,"patch_edge_ls")/=0) then
          read(line,*) el%k3%thin_h_foc,el%k3%thin_v_foc,el%k3%thin_h_angle,el%k3%thin_v_angle &
               ,rip,el%k3%patch,el%k3%hf,el%k3%vf,el%k3%ls
       elseif(index(line,"patch_edge")/=0) then
          read(line,*) el%k3%thin_h_foc,el%k3%thin_v_foc,el%k3%thin_h_angle,el%k3%thin_v_angle &
               ,rip,el%k3%patch,el%k3%hf,el%k3%vf
       elseif(index(line,"patch")/=0) then
          read(line,*) el%k3%thin_h_foc,el%k3%thin_v_foc,el%k3%thin_h_angle,el%k3%thin_v_angle &
               ,harmon,el%k3%patch
       else
          read(line,*) el%k3%thin_h_foc,el%k3%thin_v_foc,el%k3%thin_h_angle,el%k3%thin_v_angle
       endif
    case(kind4)
       NB=0
       NH=0
       x3=zero
       x4=one
       READ(MF,'(a255)') LINE

       IF(INDEX(LINE, 'HARMON')/=0) THEN
          if(INDEX(LINE, 'ripple')/=0) then
             read(LINE,*) NB,HARMON,NH,rip,x3,x4,always_on
          else
             read(LINE,*) NB,HARMON,NH
          endif
          if(nh>N_CAV4_F) then
             N_CAV4_F=NH
          endif
          read(MF,*) x1,x2,i1
       ELSE
          read(LINE,*) NB
          x1=zero
          x2=c_%phase0
          i1=CAVITY_TOTALPATH
       ENDIF
       CALL SETFAMILY(EL)   ! POINTERS MUST BE ESTABLISHED BETWEEN GENERIC ELEMENT M AND SPECIFIC ELEMENTS
       el%c4%N_BESSEL=NB
       N_CAV4_F=1
       do i=1,nh
          read(mf,*) el%c4%f(i),el%c4%ph(i)
       enddo
       el%c4%t=x1
       el%c4%phase0=x2
       el%c4%a=x3
       el%c4%r=x4
       el%c4%CAVITY_TOTALPATH=i1
       el%c4%always_on=always_on
    case(kind10)
       CALL SETFAMILY(EL)   ! POINTERS MUST BE ESTABLISHED BETWEEN GENERIC ELEMENT M AND SPECIFIC ELEMENTS
       read(MF,*) el%tp10%DRIFTKICK
    case(kind16,kind20)
       CALL SETFAMILY(EL)   ! POINTERS MUST BE ESTABLISHED BETWEEN GENERIC ELEMENT M AND SPECIFIC ELEMENTS
       read(MF,*) el%k16%DRIFTKICK,el%k16%LIKEMAD
    case(kind18)
       CALL SETFAMILY(EL)   ! POINTERS MUST BE ESTABLISHED BETWEEN GENERIC ELEMENT M AND SPECIFIC ELEMENTS
       READ(MF,*) LINE
       CALL READ_aperture(EL%RCOL18%A,mf)
    case(kind19)
       CALL SETFAMILY(EL)   ! POINTERS MUST BE ESTABLISHED BETWEEN GENERIC ELEMENT M AND SPECIFIC ELEMENTS
       READ(MF,*) LINE
       CALL READ_aperture(EL%ECOL19%A,mf)
    case(kind21)
       CALL SETFAMILY(EL)   ! POINTERS MUST BE ESTABLISHED BETWEEN GENERIC ELEMENT M AND SPECIFIC ELEMENTS
       read(MF,*) el%cav21%PSI,el%cav21%DPHAS,el%cav21%DVDS
    case(KINDWIGGLER)
       CALL SETFAMILY(EL)   ! POINTERS MUST BE ESTABLISHED BETWEEN GENERIC ELEMENT M AND SPECIFIC ELEMENTS
       call read_wig(el%wi,mf)
    case(KINDpa)
       call read_pancake(el,mf)  ! SET FAMILY DONE INSIDE
    case default
       write(6,*) " not supported in read_specific_element"
       stop 102
    end select

  end subroutine read_specific_element

  subroutine read_pancake(el,mf)
    implicit none
    type(ELEMENT), pointer :: el
    integer mf
    character*120 filename
    read(mf,*) filename
    call context(filename)

    call read_pancake_field(el,filename)
  end subroutine read_pancake


  subroutine read_pancake_field(el,filename)
    implicit none
    type(ELEMENT), pointer :: el
    integer mf,nst,ORDER,I
    real(dp)  L,hc,cl,BRHO
    logical(lp) REPEAT
    character(*) filename
    TYPE(TAYLOR) B(3)
    type(tree_element), allocatable :: t_e(:)

    cl=(clight/c_1d8)
    BRHO=el%p%p0c*ten/cl


    call kanalnummer(mf)
    open(unit=mf,file=filename)
    read(mf,*) nst,L,hc, ORDER,REPEAT
    CALL INIT(ORDER,2)
    CALL ALLOC(B)
    ALLOCATE(T_E(NST))
    DO I=1,NST
       CALL READ(B(1),mf);CALL READ(B(2),mf);CALL READ(B(3),mf);
       B(1)=B(1)/BRHO
       B(2)=B(2)/BRHO
       B(3)=B(3)/BRHO
       CALL SET_TREE_g(T_E(i),B)
    ENDDO
    close(mf)
    CALL KILL(B)
    CALL SETFAMILY(EL,t=T_E)  !,T_ax=T_ax,T_ay=T_ay)
    deallocate(T_E)

  end subroutine read_pancake_field

  subroutine READ_element(p,m,mf)
    implicit none
    integer mf,I
    type(fibre), pointer :: p
    type(element), pointer :: m
    character*120 line
    character*255 linet
    CHARACTER*21 SOL
    REAL(DP) B_SOL,r(3),d(3)
    integer f0
    f0=0
    READ(MF,*) LINE
    READ(MF,*) M%KIND,M%NAME,M%VORNAME
    CALL CONTEXT(M%NAME);
    CALL CONTEXT(M%VORNAME);
    IF(M%VORNAME(1:9)=='NOVORNAME') M%VORNAME=' '

    READ(MF,*) M%L,M%PERMFRINGE,M%MIS  !,M%EXACTMIS
    READ(MF,*) M%FINT,M%HGAP,M%H1,M%H2
    READ(MF,*) R,D
    READ(MF,*) LINE
    CALL CONTEXT(LINE)
    IF(LINE(1:1)=='C') THEN
       IF(.NOT.ASSOCIATED(M%VOLT)) ALLOCATE(M%VOLT)
       IF(.NOT.ASSOCIATED(M%FREQ)) ALLOCATE(M%FREQ)
       IF(.NOT.ASSOCIATED(M%PHAS)) ALLOCATE(M%PHAS)
       IF(.NOT.ASSOCIATED(M%DELTA_E))ALLOCATE(M%DELTA_E)
       IF(.NOT.ASSOCIATED(M%LAG))   ALLOCATE(M%LAG)
       IF(.NOT.ASSOCIATED(M%THIN))  ALLOCATE(M%THIN)
       READ(MF,*) M%VOLT, M%FREQ,M%PHAS,M%DELTA_E,M%LAG,M%THIN
    ELSEIF(LINE(1:1)=='H') THEN
       IF(.NOT.ASSOCIATED(M%FREQ)) ALLOCATE(M%FREQ)
       IF(.NOT.ASSOCIATED(M%PHAS)) ALLOCATE(M%PHAS)
       READ(MF,*) M%FREQ,M%PHAS
    ELSEIF(LINE(1:1)=='E') THEN
       IF(.NOT.ASSOCIATED(M%VOLT)) ALLOCATE(M%VOLT)
       IF(.NOT.ASSOCIATED(M%PHAS)) ALLOCATE(M%PHAS)
       READ(MF,*) M%VOLT, M%PHAS
    ENDIF
    READ(mf,*) SOL,B_SOL
    CALL CONTEXT(SOL)
    IF(SOL(1:2)=='SO') THEN
       IF(.NOT.ASSOCIATED(M%B_SOL))ALLOCATE(M%B_SOL)
       M%B_SOL=B_SOL
    ENDIF
    CALL  READ_magnet_chart(p,m%P,mf)

    !     Write(mf,*) f0," Internal Recutting "
    IF(M%P%NMUL/=0) THEN
       IF(.NOT.ASSOCIATED(M%AN)) THEN
          ALLOCATE(M%AN(M%P%NMUL))
          ALLOCATE(M%BN(M%P%NMUL))
       ELSE
          DEALLOCATE(M%AN)
          DEALLOCATE(M%BN)
          ALLOCATE(M%AN(M%P%NMUL))
          ALLOCATE(M%BN(M%P%NMUL))
       ENDIF
       !     write(6,*) M%KIND,M%NAME,M%VORNAME

       !     write(6,*) M%P%NMUL
       !          READ(MF,'(a120)') LINE
       !     write(6,'(a120)') line
       !     pause 1
       do i=1,m%p%NMUL
          READ(MF,'(A255)') LINEt
          if(index(LINEt,"%f")==0 ) then
             READ(linet,*) m%bn(i),m%an(i)
          else
             READ(linet,*) m%bn(i),m%an(i),f0
          endif
          !          READ(mf,*) m%bn(i),m%an(i),f0
       enddo
    endif
    call read_specific_element(m,mf)

    READ(MF,*) LINE

    if(f0>0) then
       if(p%MAG%KIND==KIND7) then
          p%MAG%t7%f=f0
       endif
       if(p%MAG%KIND==KIND2.and.p%MAG%p%method==2) then
          p%MAG%k2%f=f0
       endif
       if(associated(p%MAG%K16)) then
          if(p%MAG%K16%DRIFTKICK.and.p%MAG%p%method==2)  p%MAG%K16%f=f0
       endif
       if(associated(p%MAG%TP10)) then
          if(p%MAG%TP10%DRIFTKICK.and.p%MAG%p%method==2) p%MAG%TP10%f=f0
       endif
    endif

  end subroutine READ_element


  subroutine READ_fake_element(p,mf)
    implicit none
    integer mf,I
    type(fibre),pointer ::  p
    type(fibre),pointer ::  f
    type(element),pointer ::  m
    character*120 line
    CHARACTER*21 SOL
    REAL(DP) B_SOL,r(3),d(3)
    nullify(m)
    call alloc(f)
    m=>f%mag
    !    m=0
    READ(MF,*) LINE
    READ(MF,*) M%KIND,M%NAME,M%VORNAME
    CALL CONTEXT(M%NAME);
    CALL CONTEXT(M%VORNAME);
    IF(M%VORNAME(1:9)=='NOVORNAME') M%VORNAME=' '

    READ(MF,*) M%L,M%PERMFRINGE,M%MIS   !,M%EXACTMIS
    READ(MF,*) M%FINT,M%HGAP,M%H1,M%H2
    READ(MF,*) R,D
    READ(MF,*) LINE
    CALL CONTEXT(LINE)
    IF(LINE(1:1)=='C') THEN
       IF(.NOT.ASSOCIATED(M%VOLT)) ALLOCATE(M%VOLT)
       IF(.NOT.ASSOCIATED(M%FREQ)) ALLOCATE(M%FREQ)
       IF(.NOT.ASSOCIATED(M%PHAS)) ALLOCATE(M%PHAS)
       IF(.NOT.ASSOCIATED(M%DELTA_E))ALLOCATE(M%DELTA_E)
       IF(.NOT.ASSOCIATED(M%LAG))   ALLOCATE(M%LAG)
       IF(.NOT.ASSOCIATED(M%THIN))  ALLOCATE(M%THIN)
       READ(MF,*) M%VOLT, M%FREQ,M%PHAS,M%DELTA_E,M%LAG,M%THIN
    ELSEIF(LINE(1:1)=='E') THEN
       IF(.NOT.ASSOCIATED(M%VOLT)) ALLOCATE(M%VOLT)
       IF(.NOT.ASSOCIATED(M%PHAS)) ALLOCATE(M%PHAS)
       READ(MF,*) M%VOLT, M%PHAS
    ENDIF
    READ(mf,*) SOL,B_SOL
    CALL CONTEXT(SOL)
    IF(SOL(1:2)=='SO') THEN
       IF(.NOT.ASSOCIATED(M%B_SOL))ALLOCATE(M%B_SOL)
       M%B_SOL=B_SOL
    ENDIF
    CALL  READ_magnet_chart(p,m%P,mf)
    IF(M%P%NMUL/=0) THEN
       IF(.NOT.ASSOCIATED(M%AN)) THEN
          ALLOCATE(M%AN(M%P%NMUL))
          ALLOCATE(M%BN(M%P%NMUL))
       ELSE
          DEALLOCATE(M%AN)
          DEALLOCATE(M%BN)
          ALLOCATE(M%AN(M%P%NMUL))
          ALLOCATE(M%BN(M%P%NMUL))
       ENDIF
       !     write(6,*) M%KIND,M%NAME,M%VORNAME

       !     write(6,*) M%P%NMUL
       !          READ(MF,'(a120)') LINE
       !     write(6,'(a120)') line
       !     pause 1
       do i=1,m%p%NMUL
          READ(mf,*) m%bn(i),m%an(i)
       enddo
    endif
    call read_specific_element(m,mf)

    READ(MF,*) LINE

    !          m=-1;
    call SUPER_zero_fibre(f,-1)
    !          deallocate(m);

  end subroutine READ_fake_element

  subroutine print_magnet_chart(P,m,mf)
    implicit none
    type(FIBRE), pointer :: P
    type(magnet_chart), pointer :: m
    integer mf
    character*200 line

    WRITE(MF,*) "MAGNET CHART MAGNET CHART MAGNET CHART MAGNET CHART MAGNET CHART MAGNET CHART "
    WRITE(MF,*) M%EXACT,M%METHOD,M%NST,M%NMUL, " EXACT METHOD NST NMUL"
    WRITE(line,*) M%LD, M%LC, M%B0,' TILT= ',M%TILTD, " LD LC B0 "
    WRITE(MF,'(A200)') LINE
    WRITE(LINE,*) P%BETA0,P%GAMMA0I, P%GAMBET, M%P0C, " BETA0 GAMMA0I GAMBET P0C"
    WRITE(MF,'(A200)') LINE
    WRITE(MF,*) M%EDGE, " EDGES"
    WRITE(MF,*) M%KILL_ENT_FRINGE,M%KILL_EXI_FRINGE,M%bend_fringe, " Kill_ent_fringe, kill_exi_fringe, bend_fringe "

    CALL print_magnet_frame(m%F,mf)
    CALL print_aperture(m%APERTURE,mf)
    write(mf,'(a68)') "END MAGNET CHART END MAGNET CHART END MAGNET CHART END MAGNET CHART "
  end subroutine print_magnet_chart

  subroutine READ_magnet_chart(p,m,mf)
    implicit none
    type(fibre), pointer :: p
    type(magnet_chart), pointer :: m
    integer mf
    character*200 line
    character*5 til
    real(dp) BETA0,GAMMA0I, GAMBET


    READ(MF,*) LINE
    READ(MF,*) M%EXACT,M%METHOD,M%NST,M%NMUL
    READ(MF,'(A200)') LINE

    if(index(line,"TILT=")/=0) then
       READ(LINE,*) M%LD, M%LC, M%B0,til,M%tiltd
    else
       READ(LINE,*) M%LD, M%LC, M%B0
       M%tiltd=zero
    endif


    READ(MF,*)BETA0,GAMMA0I, GAMBET, M%P0C
    READ(MF,*) M%EDGE
    READ(MF,*) M%KILL_ENT_FRINGE,M%KILL_EXI_FRINGE,M%bend_fringe

    CALL READ_magnet_frame(m%F,mf)
    CALL READ_aperture(m%APERTURE,mf)
    READ(MF,*) LINE
    p%BETA0=beta0
    p%GAMBET=GAMBET
    p%GAMMA0I=GAMMA0I
    !    p%P0C=M%P0C
    !    M%BETA0 =>p%BETA0
    !    M%GAMMA0I => p%GAMMA0I
    !    M%GAMBET => p%GAMBET

  end subroutine READ_magnet_chart

  subroutine print_magnet_frame(m,mf)
    implicit none
    type(magnet_frame), pointer :: m
    integer mf,i
    if(print_frame) then
       write(mf,'(a72)') "MAGNET FRAME MAGNET FRAME MAGNET FRAME MAGNET FRAME MAGNET FRAME MAGNET FRAME "
       WRITE(MF,*) m%a
       do i=1,3
          WRITE(MF,*) m%ent(i,1:3)
       enddo
       WRITE(MF,*) m%o
       do i=1,3
          WRITE(MF,*) m%mid(i,1:3)
       enddo
       WRITE(MF,*) m%b
       do i=1,3
          WRITE(MF,*) m%exi(i,1:3)
       enddo
       write(mf,'(a68)') "END MAGNET FRAME END MAGNET FRAME END MAGNET FRAME END MAGNET FRAME "
    else
       write(mf,'(a72)') " NO MAGNET FRAME NO MAGNET FRAME NO MAGNET FRAME NO MAGNET FRAME NO MAGNET    "
    endif
  end subroutine print_magnet_frame

  subroutine read_magnet_frame(m,mf)
    implicit none
    type(magnet_frame), pointer :: m
    integer mf,i
    character*120 line

    read(mf,'(a120)') line

    if(index(line,"NO")==0) then

       read(MF,*) m%a
       do i=1,3
          read(MF,*) m%ent(i,1:3)
       enddo
       read(MF,*) m%o
       do i=1,3
          read(MF,*) m%mid(i,1:3)
       enddo
       read(MF,*) m%b
       do i=1,3
          read(MF,*) m%exi(i,1:3)
       enddo
       read(mf,'(a120)') line
    else
       do_survey=.true.
    endif
  end subroutine read_magnet_frame

  subroutine print_aperture(m,mf)
    implicit none
    type(MADX_APERTURE), pointer :: m
    integer mf
    character*200 line

    IF(.NOT.ASSOCIATED(M)) THEN
       write(mf,'(a20)') " NO MAGNET APERTURE "
    ELSE
       write(mf,'(a21)') " HAS MAGNET APERTURE "
       WRITE(MF,*) m%KIND   ! 1,2,3,4
       WRITE(MF,*) m%R
       WRITE(line,*)  m%X,m%Y,' SHIFT ',m%dX,m%dY
       WRITE(MF,'(A200)') LINE
       write(mf,'(a23)')  " END OF MAGNET APERTURE"
    ENDIF

  end subroutine print_aperture


  subroutine READ_aperture(m,mf)
    implicit none
    type(MADX_APERTURE), pointer :: m
    integer mf
    character*200 line
    character*5 ch

    !    READ(mf,'(a120)') LINE(1:120)
    READ(mf,'(a120)') LINE

    CALL CONTEXT(LINE)

    IF(LINE(1:2)/='NO') THEN
       IF(.NOT.ASSOCIATED(M)) THEN
          CALL alloc(M)
       ENDIF

       READ(MF,*) m%KIND   ! 1,2,3,4
       READ(MF,*) m%R
       read(mf,'(a200)') line
       if(index(line,"SHIFT")==0) then
          READ(line,*) m%X,m%Y
       else
          READ(line,*) m%X,m%Y,ch,m%dX,m%dY
       endif
       READ(mf,'(a120)') LINE(1:120)
    ENDIF

  end subroutine READ_aperture

!!!!!

  SUBROUTINE change_fibre(p)
    IMPLICIT NONE
    INTEGER MF
    TYPE(FIBRE), POINTER :: P

    CALL KANALNUMMER(MF)

    OPEN(UNIT=MF,FILE='JUNK_CHANGE_FIBRE.TXT')

    CALL print_FIBRE(P,mf)
    P=-1
    REWIND MF
    CALL alloc_fibre( P )
    CALL READ_FIBRE(P,mf)


    CLOSE(MF)
  END SUBROUTINE change_fibre

!!!!!!!!!!  pointed at layout !!!!!!!!!!!!!!
  subroutine read_COMPLEX_SINGLE_STRUCTURE(U,filename,RING,LMAX0)
    implicit none
    character(*) filename
    integer mf,n,i,n_l,J
    type(MAD_UNIVERSE), TARGET :: U
    type(layout), pointer :: L
    LOGICAL(LP), OPTIONAL :: RING
    REAL(DP), OPTIONAL :: LMAX0

    call kanalnummer(mf)
    open(unit=mf,file=filename,status='OLD',err=2001)


    read(mf,*) n,n_l
    write(6,*) n,n_l
    do i=1,n
       call READ_AND_APPEND_VIRGIN_LAYOUT(U,filename,RING,LMAX0,mf)
       if(i==1) L=>U%end
       write(6,*) " read layout ", i
       write(6,*) U%end%name
    enddo
    do i=1,n_l
       call APPEND_EMPTY_LAYOUT(U)
       allocate(U%END%DNA(N))
       U%END%DNA(1)%L=>L
       U%END%DNA(1)%counter=0
       DO J=2,N
          U%END%DNA(J)%L=>U%END%DNA(J-1)%L%NEXT
          U%END%DNA(j)%counter=0
       ENDDO

       !   read(mf,'(a120)') line
       WRITE(6,*) "LAYOUT ",I
       !   WRITE(6,*) LINE
       !       do k=1,N
       !        read(mf,*) ncon1,ncon2
       !        if(ncon1/=0) then
       !          allocate(U%END%DNA(k)%L%con1(ncon1))
       !          allocate(U%END%DNA(k)%L%con2(ncon2))
       !          U%END%DNA(k)%L%con1(1:ncon1)%POS=0
       !          U%END%DNA(k)%L%con2(1:ncon2)%POS=0
       !        else
       !          nullify(U%END%DNA(k)%L%con1)
       !          nullify(U%END%DNA(k)%L%con2)
       !       endif

       !          do j=1,max(ncon1,ncon2)
       !            READ(MF,*) POS1,POS2
       !           IF(POS1/=0) U%END%DNA(k)%L%con1(J)%POS=POS1
       !           IF(POS2/=0) U%END%DNA(k)%L%con2(J)%POS=POS2
       !         enddo

       !       enddo
       !   read(mf,'(a120)') line

       !   WRITE(6,*) I
       !   WRITE(6,*) LINE


       CALL READ_pointed_INTO_VIRGIN_LAYOUT(U%END,FILENAME,RING,LMAX0,mf1=MF)

       !     do k=1,N
       !      DO J=1,SIZE(U%END%DNA(k)%L%con1)
       !        CALL MOVE_TO(U%END,P,U%END%DNA(k)%L%CON1(J)%POS)
       !        U%END%DNA(k)%L%CON1(J)%P=>P
       !     ENDDO
       !     DO J=1,SIZE(U%END%DNA(k)%L%con2)
       !       CALL MOVE_TO(U%END,P,U%END%DNA(k)%L%CON2(J)%POS)
       !       U%END%DNA(k)%L%CON2(J)%P=>P
       !     ENDDO
       !    ENDDO

    enddo

    close(mf)



    return
2001 continue

    Write(6,*) " File ",filename(1:len_trim(filename)) ," does not exist "

  END subroutine read_COMPLEX_SINGLE_STRUCTURE

  ! MAKES NOT SENSE BECAUSE DNA ARRAY NOT PROVIDED!
  !  subroutine READ_pointed_AND_APPEND_VIRGIN_LAYOUT(U,filename,RING,mf)
  !    implicit none
  !    character(*) filename
  !    integer,optional :: mf
  !    type(MAD_UNIVERSE), TARGET :: U
  !    LOGICAL(LP), OPTIONAL :: RING


  !    call APPEND_EMPTY_LAYOUT(U)

  !    CALL READ_pointed_INTO_VIRGIN_LAYOUT(U%END,FILENAME,RING,mf)

  !  END subroutine READ_pointed_AND_APPEND_VIRGIN_LAYOUT

  subroutine READ_pointed_INTO_VIRGIN_LAYOUT(L,FILENAME,RING,LMAX0,mf1)
    implicit none
    character(*) filename
    integer I,mf,N,DIR,index_,pos,nt,siam_index,siam_pos,gird_index,gird_pos
    type(LAYOUT), TARGET :: L
    type(FIBRE), pointer :: P,current,siam,gird
    LOGICAL(LP), OPTIONAL :: RING
    REAL(DP), OPTIONAL :: LMAX0
    LOGICAL(LP) RING_IT,doneit
    character*120 line
    character*255 lineg
    real(dp) p0c,MASSF,LMAX0t,ag0
    type(internal_state) original
    integer,optional :: mf1
    integer res


    RING_IT=MY_TRUE

    IF(PRESENT(RING)) RING_IT=RING

    if(present(mf1) ) then
       mf=mf1
    else
       call kanalnummer(mf)
       open(unit=mf,file=filename,status='OLD',err=2001)
    endif

    READ(MF,*) N,LMAX0t
    write(6,*) N,LMAX0t
    IF(PRESENT(LMAX0)) then
       if(LMAX0t/=zero) LMAX0=LMAX0T
    ENDIF
    read(MF,'(a120)') line
    call context(line)
    write(6,*) line

    if(index(line,"FOR")/=0) then
       l%name=line(index(line,"FOR")+3:index(line,"FOR")+2+nlp)
    endif

    read(MF,'(A255)') lineg
    res=INDEX (lineG, "AG(spin)")
    IF(RES==0) THEN
       read(lineg,*) MASSF,p0c
       IF(ABS(MASSF-pmap)/PMAP<0.01E0_DP) THEN
          A_PARTICLE=A_PROTON
       ELSEIF(ABS(MASSF-pmae)/pmae<0.01E0_DP) THEN
          A_PARTICLE=A_ELECTRON
       ELSEIF(ABS(MASSF-pmaMUON)/pmaMUON<0.01E0_DP) THEN
          A_PARTICLE=A_MUON
       ENDIF
    ELSE
       read(lineg,*) MASSF,p0c,A_PARTICLE
    ENDIF
    ag0=A_PARTICLE

    !    read(MF,*) MASSF,p0c
    read(MF,*) phase0,stoch_in_rec,initial_charge
    read(MF,*) CAVITY_TOTALPATH,ALWAYS_EXACTMIS,ALWAYS_EXACT_PATCHING
    read(MF,*) SECTOR_NMUL_MAX,SECTOR_NMUL,OLD_IMPLEMENTATION_OF_SIXTRACK,HIGHEST_FRINGE
    read(MF,*) wedge_coeff
    read(MF,*) MAD8_WEDGE
    read(MF,'(a120)') line
    original=default
    if(allocated(s_b)) then
       firsttime_coef=.true.
       deallocate(s_b)
    endif
    !    L%MASS=MASSF
    MASSF=MASSF/pmae
    CALL MAKE_STATES(MASSF)
    A_PARTICLE=ag0
    default=original
    call Set_madx(p0c=p0c)
    DO I=1,N
       call  READ_FIBRE_2_lines(mf,dir,index_,pos,nt,siam_index,siam_pos,gird_index,gird_pos)
       call  READ_chart_fake(mf)
       call move_to(L%DNA(index_)%L,p,pos)
       CALL APPEND_POINT(L,P)
       current=>l%end
       current%dir=dir

       if(siam_index/=0) then
          call move_to(L%DNA(siam_index)%L,siam,siam_pos)
          p%mag%siamese=>siam%mag
          write(6,*) p%mag%name,' is a siamese of ', siam%mag%name
       endif
       if(gird_index/=0) then
          call move_to(L%DNA(gird_index)%L,gird,gird_pos)
          p%mag%girderS=>gird%mag
          write(6,*) p%mag%name,' is on the girder of ', gird%mag%name
       endif
       !        if(pos==1) then
       !         if(associated(L%DNA(index)%l%con1)) then
       !           L%DNA(index)%counter=L%DNA(index)%counter+1
       !           kc=L%DNA(index)%counter
       !           L%DNA(index)%l%con1(kc)%p=>current
       !      write(6,*)  0,index,kc
       !          endif
       !        elseif(pos==nt) then
       !         if(associated(L%DNA(index)%l%con2)) then
       !           L%DNA(index)%l%con2(kc)%p=>current
       !     !       write(6,*)  1,index,kc
       !          endif
       !        endif
       CALL READ_PATCH(current%PATCH,mf)
       call READ_fake_element(current,mf)
       READ(MF,*) LINE
       !
       ! CALL READ_FIBRE(L%END,mf)
       !       CALL COPY(L%END%MAG,L%END%MAGP)
    ENDDO

    if(.not.present(mf1) ) CLOSE(MF)

    L%closed=RING_IT

    doneit=.true.
    call ring_l(L,doneit)
    if(do_survey) call survey(L)

    return

2001 continue

    Write(6,*) " File ",filename(1:len_trim(filename)) ," does not exist "

  END subroutine READ_pointed_INTO_VIRGIN_LAYOUT


!!!!!!!!!!!!  switching routines !!!!!!!!!!!!!
  SUBROUTINE switch_layout_to_cavity( L,name,sext,a,r,freq,t )  ! switch to kind7
    implicit none
    TYPE (layout), target :: L
    TYPE (fibre), pointer :: p
    character(*) name
    real(dp),OPTIONAL:: a,r,freq,t
    INTEGER I
    logical(lp) sext


    p=>L%start
    do i=1,L%n

       call  switch_to_cavity( p,name,sext,a,r,freq,t)

       p=>p%next
    enddo



  end SUBROUTINE switch_layout_to_cavity



  SUBROUTINE switch_to_cavity( el,name,sext,a,r,freq,t )  ! switch to kind7
    implicit none
    TYPE (fibre), target :: el
    character(*) name
    integer i,nm,EXCEPTION
    real(dp),OPTIONAL:: a,r,freq,t
    real(dp), allocatable :: an(:),bn(:)
    type(keywords) key
    logical(lp) sext
    ! This routines switches to cavity
    nm=len_trim(name)
    select case(el%mag%kind)
    case(kind10,kind16,kind2,kind7,kind6,KIND20)
       if(el%mag%name(1:nm)==name(1:nm)) then
          if(sext.and.el%mag%p%nmul>2)then
             write(6,*) el%mag%name
             call add(el,3,0,zero)
             call add(el,-3,0,zero)
          else
             write(6,*) el%mag%name, " not changed "
          endif
       endif
       if(el%mag%p%b0/=zero.or.el%mag%name(1:nm)==name(1:nm)) return
       write(6,*) el%mag%name
       if(el%mag%p%nmul/=size(el%mag%an)) then
          write(6,*) "error in switch_to_cavity "
          stop 666
       endif
       allocate(an(el%mag%p%nmul),bn(el%mag%p%nmul))
       an=el%mag%an*el%mag%p%p0c
       bn=el%mag%bn*el%mag%p%p0c
       call zero_key(key)
       key%magnet="rfcavity"
       key%list%volt=zero
       key%list%lag=zero
       key%list%freq0=zero
       IF(PRESENT(FREQ)) THEN
          key%list%freq0=FREQ
       ENDIF
       key%list%n_bessel=0
       key%list%harmon=one
       key%list%l=el%mag%L
       key%list%name=el%mag%name
       key%list%vorname=el%mag%vorname
       EXACT_MODEL=el%mag%p%exact
       key%nstep=el%mag%p%nst
       key%method=el%mag%p%method


       el%mag=-1
       el%magp=-1
       el%mag=0
       el%magp=0
       call create_fibre(el,key,EXCEPTION,my_true)
       do i=size(an),1,-1
          call add(el,-i,0,an(i))
          call add(el,i,0,bn(i))
       enddo
       el%mag%c4%a=one
       el%magp%c4%a=one
       IF(PRESENT(a)) THEN
          el%mag%c4%a=a
          el%magp%c4%a=a
       ENDIF
       el%mag%c4%r=ZERO
       el%magp%c4%r=ZERO
       IF(PRESENT(r)) THEN
          el%mag%c4%r=r
          el%magp%c4%r=r
       ENDIF
       el%mag%c4%PHASE0=ZERO
       el%mag%c4%PHASE0=ZERO
       el%mag%c4%always_on=my_true
       el%magp%c4%always_on=my_true
       IF(PRESENT(FREQ)) THEN
          el%mag%FREQ=FREQ
          el%magP%FREQ=FREQ
       ENDIF
       IF(PRESENT(T).and.PRESENT(FREQ)) THEN
          el%mag%C4%T=T/(el%mag%C4%freq/CLIGHT)
          el%magP%C4%T=el%mag%C4%T
       ENDIF
       deallocate(an,bn)
    CASE(KIND4)
       IF(el%mag%c4%always_on) THEN
          IF(PRESENT(FREQ)) THEN
             el%mag%FREQ=FREQ
             el%magP%FREQ=FREQ
          ENDIF
          IF(PRESENT(T)) THEN
             el%mag%C4%T=T/(el%mag%C4%freq/CLIGHT)
             el%magP%C4%T=el%mag%C4%T
          ENDIF
          IF(PRESENT(r)) THEN
             el%mag%c4%r=r
             el%magp%c4%r=r
          ENDIF
          IF(PRESENT(a)) THEN
             el%mag%c4%a=a
             el%magp%c4%a=a
          ENDIF

       ENDIF

    case default
       return
    end select

  END SUBROUTINE switch_to_cavity

  SUBROUTINE switch_to_kind7( el )  ! switch to kind7
    implicit none
    TYPE (fibre), target :: el
    ! This routines switches to kind7 (not exact) from kind2,10,16
    select case(el%mag%kind)
    case(kind10,kind16,kind2,KIND20)
       el%magp=-1
       el%mag%L=el%mag%p%ld
       el%mag%p%lc=el%mag%p%ld
       el%mag%p%exact=.false.
       el%magp=0
    end select

    select case(el%mag%kind)
    case(kind10)
       EL%MAG%TP10=-1
       deallocate(EL%MAG%TP10)
       el%mag%kind=KIND7
       CALL SETFAMILY(EL%MAG)
       CALL COPY(EL%MAG,EL%MAGP)
    case(kind16,KIND20)
       EL%MAG%k16=-1
       deallocate(EL%MAG%k16)
       el%mag%kind=KIND7
       CALL SETFAMILY(EL%MAG)
       CALL COPY(EL%MAG,EL%MAGP)
    case(KIND2)
       el%mag%kind=KIND7
       CALL SETFAMILY(EL%MAG)
       CALL COPY(EL%MAG,EL%MAGP)
    end select

  END SUBROUTINE switch_to_kind7

end module madx_keywords