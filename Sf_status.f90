!The Polymorphic Tracking Code
!Copyright (C) Etienne Forest and Frank Schmidt
! See file Sa_rotation_mis
module S_status
  use s_frame
  USE S_extend_poly
  use anbn
  USE S_pol_user1
  USE S_pol_user2
  implicit none

  integer,private,parameter::ST=30
  !
  integer, parameter :: KIND0 = ST
  integer, parameter :: KIND1 = ST+1
  integer, parameter :: KIND2 = ST+2
  integer, parameter :: KIND3 = ST+3
  integer, parameter :: KIND4 = ST+4
  integer, parameter :: KIND5 = ST+5
  integer, parameter :: KIND6 = ST+6
  integer, parameter :: KIND7 = ST+7
  integer, parameter :: KIND8 = ST+8
  integer, parameter :: KIND9 = ST+9
  integer, parameter :: KIND10 =ST+10
  integer, parameter :: KIND11 =ST+11
  integer, parameter :: KIND12 =ST+12
  integer, parameter :: KIND13 =ST+13
  integer, parameter :: KIND14 =ST+14
  integer, parameter :: KIND15 =ST+15
  integer, parameter :: KIND16 =ST+16
  integer, parameter :: KIND17 =ST+17
  integer, parameter :: KIND18 =ST+18
  integer, parameter :: KIND19 =ST+19
  integer, parameter :: KINDFITTED = ST+20
  integer, parameter :: KINDUSER1 = ST+21
  integer, parameter :: KINDUSER2 = ST+22
  integer, parameter :: drift_kick_drift = kind2
  integer, parameter :: matrix_kick_matrix = kind7
  integer, parameter :: kick_sixtrack_kick = kind6
  INTEGER, PARAMETER :: METHOD_1 = -1
  INTEGER, PARAMETER :: METHOD_2 = -2
  INTEGER, PARAMETER :: METHOD_3 = -3
  INTEGER, PARAMETER :: METHOD_4 = -4
  INTEGER, PARAMETER :: METHOD_F = -5
  LOGICAL(lp),TARGET  :: NEW_METHOD=.FALSE.
  character(6) ind_stoc(ndim2)
  !  Making PTC leaner is false
  LOGICAL(lp),TARGET   :: with_internal_frame = .true.
  !

  integer, target :: MADKIND2=KIND2
  integer, target :: MADKIND3N=KIND3
  integer, target :: MADKIND3S=KIND3
  integer, pointer :: MADTHICK
  integer, pointer :: MADTHIN_NORMAL
  integer, pointer :: MADTHIN_SKEW
  LOGICAL(lp), target :: MADLENGTH=.false.
  LOGICAL(lp), target :: MAD=.false.
  LOGICAL(lp), target :: EXACT_MODEL = .false.
  INTEGER, target:: NSTD,METD
  TYPE(B_CYL) SECTOR_B
  INTEGER, target :: SECTOR_NMUL = 4
  real(dp) CRAD,CFLUC
  !  real(dp) YOSK(0:4), YOSD(4)    ! FIRST 6TH ORDER OF YOSHIDA
  !  real(dp),PARAMETER::AAA=-0.25992104989487316476721060727823e0_dp  ! fourth order integrator
  !  real(dp),PARAMETER::FD1=half/(one+AAA),FD2=AAA*FD1,FK1=one/(one+AAA),FK2=(AAA-one)*FK1
  real(dp), ALLOCATABLE,DIMENSION(:,:)::SPK,SPD    ! 5 NEGATIVE METHODS
  real(dp), ALLOCATABLE,DIMENSION(:)::SDF,SDK,SDDF
  TYPE(REAL_8), ALLOCATABLE,DIMENSION(:)::PSDF,PSDK
  INTEGER, ALLOCATABLE,DIMENSION(:)::SPN
  LOGICAL(lp) :: firsttime_coef=.true.

  PRIVATE EQUALt,ADD,PARA_REMA,EQUALtilt
  PRIVATE DTILTR,DTILTP,DTILTS
  PRIVATE CHECK_APERTURE_R,CHECK_APERTURE_P,CHECK_APERTURE_S
  LOGICAL(lp), target:: electron
  real(dp), target :: muon=one
  LOGICAL(lp),PRIVATE,PARAMETER::T=.TRUE.,F=.FALSE.
  INTEGER,PARAMETER::NMAX=20
  TYPE INTERNAL_STATE
     LOGICAL(lp) TOTALPATH,TIME,RADIATION,NOCAVITY,FRINGE,EXACTMIS
     LOGICAL(lp) PARA_IN,ONLY_4D,DELTA
  END TYPE INTERNAL_STATE
  TYPE(INTERNAL_STATE), target ::  DEFAULT
  TYPE(INTERNAL_STATE), target ::  TOTALPATH,RADIATION,NOCAVITY,FRINGE,TIME,EXACTMIS
  TYPE(INTERNAL_STATE), target ::  ONLY_4D,DELTA

  TYPE (INTERNAL_STATE), PARAMETER :: DEFAULT0 = INTERNAL_STATE &
       &(f,f,f,f,f,f,f,f,f)
  TYPE (INTERNAL_STATE), PARAMETER :: TOTALPATH0 = INTERNAL_STATE &
       &(t,f,f,f,f,f,f,f,f)
  TYPE (INTERNAL_STATE), PARAMETER :: TIME0 = INTERNAL_STATE &
       &(f,t,f,f,f,f,f,f,f)
  TYPE (INTERNAL_STATE), PARAMETER :: RADIATION0 = INTERNAL_STATE &
       &(f,f,t,f,f,f,f,f,f)
  TYPE (INTERNAL_STATE), PARAMETER :: NOCAVITY0 = INTERNAL_STATE &
       &(f,f,f,t,f,f,f,f,f)
  TYPE (INTERNAL_STATE), PARAMETER :: FRINGE0 = INTERNAL_STATE &
       &(f,f,f,f,t,f,f,f,f)
  TYPE (INTERNAL_STATE), PARAMETER :: EXACTMIS0 = INTERNAL_STATE &
       &(f,f,f,f,f,t,f,f,f)
  TYPE (INTERNAL_STATE), PARAMETER :: ONLY_4d0 = INTERNAL_STATE &
       &(f,f,f,t,f,f,f,t,f)
  TYPE (INTERNAL_STATE), PARAMETER :: DELTA0   = INTERNAL_STATE &
       &(f,f,f,t,f,f,f,t,t)
  private s_init,MAKE_STATES_0,MAKE_STATES_m,print_s,CONV
  LOGICAL(lp), target :: stoch_in_rec = .false.
  private alloc_p,equal_p,dealloc_p,alloc_A,equal_A,dealloc_A !,NULL_p
  PRIVATE B2PERPR,B2PERPP

  type work
     real(dp) beta0,energy,kinetic,p0c,brho,gamma0I,gambet
     real(dp) mass
     LOGICAL(lp) rescale
  end type work


  TYPE POL_BLOCK
     CHARACTER(nlp) NAME
     CHARACTER(vp) VORNAME
     ! STUFF FOR SETTING MAGNET USING GLOBAL ARRAY TPSAFIT
     real(dp),DIMENSION(:), POINTER :: TPSAFIT
     LOGICAL(lp), POINTER ::  SET_TPSAFIT
     ! STUFF FOR PARAMETER DEPENDENCE
     INTEGER NPARA
     INTEGER IAN(NMAX),IBN(NMAX)
     real(dp) SAN(NMAX),SBN(NMAX)
     INTEGER IVOLT, IFREQ,IPHAS
     INTEGER IB_SOL
     real(dp) SVOLT, SFREQ,SPHAS
     real(dp) SB_SOL
     ! User defined Functions
     TYPE(POL_BLOCK1) USER1
     TYPE(POL_BLOCK2) USER2
  END TYPE POL_BLOCK

  TYPE MADX_APERTURE
     INTEGER,pointer ::  KIND   ! 1,2,3,4
     REAL(DP),pointer :: R(:)
     REAL(DP),pointer :: X,Y
  END TYPE MADX_APERTURE

  TYPE MAGNET_CHART
     type(magnet_frame), pointer:: f
     type(MADX_APERTURE), pointer:: APERTURE
     integer,pointer :: charge  ! propagator
     integer,pointer :: dir    ! propagator
     real(dp), POINTER :: LD,B0,LC         !
     real(dp), POINTER :: TILTD      ! INTERNAL FRAME
     real(dp), POINTER :: BETA0,GAMMA0I,GAMBET,P0C
     !frs     real(dp),  DIMENSION(:), POINTER :: EDGE(:)      ! INTERNAL FRAME
     real(dp),  DIMENSION(:), POINTER :: EDGE         ! INTERNAL FRAME

     !
     INTEGER, POINTER :: TOTALPATH                    !
     LOGICAL(lp), POINTER :: EXACT,RADIATION,NOCAVITY     !       STATE
     LOGICAL(lp), POINTER :: FRINGE,TIME                  !
     !
     INTEGER, POINTER :: METHOD,NST                   ! METHOD OF INTEGRATION 2,4,OR 6 YOSHIDA
     INTEGER, POINTER :: NMUL                         ! NUMBER OF MULTIPOLE

  END TYPE MAGNET_CHART


  TYPE tilting
     real(dp) tilt(0:nmax)
     LOGICAL(lp) natural                 ! for mad-like
  END TYPE tilting
  type(tilting) tilt
  private minu
  real(dp) MADFAC(NMAX)
  CHARACTER(24) MYTYPE(-100:100)

  INTERFACE OPERATOR (.min.)
     MODULE PROCEDURE minu                       ! to define the minus of Schmidt
  END INTERFACE

  INTERFACE assignment (=)
     MODULE PROCEDURE EQUALt
     MODULE PROCEDURE EQUALtilt
     MODULE PROCEDURE equal_p
     MODULE PROCEDURE equal_A
  end  INTERFACE

  INTERFACE OPERATOR (+)
     MODULE PROCEDURE add
     MODULE PROCEDURE PARA_REMA
  END INTERFACE

  INTERFACE OPERATOR (-)
     MODULE PROCEDURE sub
  END INTERFACE

  INTERFACE MAKE_STATES
     MODULE PROCEDURE MAKE_STATES_m
     MODULE PROCEDURE MAKE_STATES_0
  END INTERFACE

  INTERFACE CHECK_APERTURE
     MODULE PROCEDURE CHECK_APERTURE_R
     MODULE PROCEDURE CHECK_APERTURE_P
     MODULE PROCEDURE CHECK_APERTURE_S
  END INTERFACE

  INTERFACE init
     MODULE PROCEDURE s_init
  END INTERFACE

  INTERFACE print
     MODULE PROCEDURE print_s
  END INTERFACE

  INTERFACE alloc
     MODULE PROCEDURE alloc_p
     MODULE PROCEDURE alloc_A
  END INTERFACE

  INTERFACE kill
     MODULE PROCEDURE dealloc_p
     MODULE PROCEDURE dealloc_A
  END INTERFACE

  INTERFACE B2PERP
     MODULE PROCEDURE B2PERPR
     MODULE PROCEDURE B2PERPP
  END INTERFACE

  INTERFACE DTILTD
     MODULE PROCEDURE DTILTR
     MODULE PROCEDURE DTILTP       ! DESIGN TILT
     MODULE PROCEDURE DTILTS
  END INTERFACE




CONTAINS


  SUBROUTINE  NULL_A(p)
    implicit none
    type (MADX_APERTURE), pointer:: P

    nullify(P%KIND);nullify(P%R);nullify(P%X);nullify(P%Y);
  end subroutine NULL_A

  SUBROUTINE  alloc_A(p)
    implicit none
    type (MADX_APERTURE), pointer:: P

    nullify(p)
    allocate(p)
    CALL NULL_A(p)
    ALLOCATE(P%R(2));ALLOCATE(P%X);ALLOCATE(P%Y);ALLOCATE(P%KIND);
    P%KIND=0; P%R=ZERO;P%X=ZERO;P%Y=ZERO;

  end subroutine alloc_A

  SUBROUTINE  dealloc_A(p)
    implicit none
    type (MADX_APERTURE), pointer:: P

    if(associated(p%R)) then
       DEALLOCATE(P%R);DEALLOCATE(P%X);DEALLOCATE(P%Y);DEALLOCATE(P%KIND);
    endif
  end SUBROUTINE  dealloc_A



  SUBROUTINE  NULL_p(p)
    implicit none
    type (MAGNET_CHART), pointer:: P

    nullify(P%LD);nullify(P%B0);nullify(P%LC);
    nullify(P%TILTD);  nullify(P%dir);nullify(P%charge);
    nullify(P%beta0);nullify(P%gamma0I);nullify(P%gambet);nullify(P%P0C);
    nullify(P%EDGE)
    nullify(P%TOTALPATH)
    nullify(P%EXACT);nullify(P%RADIATION);nullify(P%NOCAVITY);
    nullify(P%FRINGE);nullify(P%TIME);
    nullify(P%METHOD);nullify(P%NST);
    nullify(P%NMUL);
    nullify(P%F);
    nullify(P%APERTURE);
  end subroutine NULL_p




  SUBROUTINE  alloc_p(p)
    implicit none
    type (MAGNET_CHART), pointer:: P

    nullify(P);
    ALLOCATE(P);
    CALL NULL_P(P)

    ALLOCATE(P%LD);ALLOCATE(P%B0);ALLOCATE(P%LC);
    P%LD=zero;P%B0=zero;P%LC=zero;
    ALLOCATE(P%TILTD);P%TILTD=zero;
    ALLOCATE(P%beta0);ALLOCATE(P%gamma0I);ALLOCATE(P%gambet);ALLOCATE(P%P0C);
    P%beta0 =one;P%gamma0I=zero;P%gambet =zero;P%P0C =zero;
    ALLOCATE(P%EDGE(2));P%EDGE(1)=zero;P%EDGE(2)=zero;
    ALLOCATE(P%TOTALPATH); ! PART OF A STATE INITIALIZED BY EL=DEFAULT
    ALLOCATE(P%EXACT);ALLOCATE(P%RADIATION);ALLOCATE(P%NOCAVITY);
    ALLOCATE(P%FRINGE);ALLOCATE(P%TIME);
    ALLOCATE(P%METHOD);ALLOCATE(P%NST);P%METHOD=2;P%NST=1;
    ALLOCATE(P%NMUL);P%NMUL=0;
    !   ALLOCATE(P%TRACK);P%TRACK=.TRUE.;
    if(with_internal_frame) then
       call alloc(p%f)
    endif
  end subroutine alloc_p


  SUBROUTINE  dealloc_p(p)
    implicit none
    type (MAGNET_CHART), pointer:: P

    !    if(associated(P%dir)) then
    !    endif
    DEALLOCATE(P%LD);DEALLOCATE(P%B0);DEALLOCATE(P%LC);
    DEALLOCATE(P%TILTD);
    DEALLOCATE(P%beta0);DEALLOCATE(P%gamma0I);DEALLOCATE(P%gambet);DEALLOCATE(P%P0C);
    if(associated(p%f)) then
       call kill(p%f)
       DEALLOCATE(P%f);
    endif
    if(associated(p%APERTURE)) then
       CALL kill(p%APERTURE)
       DEALLOCATE(p%APERTURE);
    endif
    DEALLOCATE(P%EDGE);
    DEALLOCATE(P%TOTALPATH);
    DEALLOCATE(P%EXACT);DEALLOCATE(P%RADIATION);DEALLOCATE(P%NOCAVITY);
    DEALLOCATE(P%FRINGE);DEALLOCATE(P%TIME);
    DEALLOCATE(P%METHOD);DEALLOCATE(P%NST);
    DEALLOCATE(P%NMUL)
    !    CALL NULL_P(P)
    DEALLOCATE(P)
    nullify(p);
  end subroutine dealloc_p

  SUBROUTINE  equal_A(elp,el)
    implicit none
    type (MADX_APERTURE),INTENT(inOUT)::elP
    type (MADX_APERTURE),INTENT(IN)::el
    ELP%KIND=EL%KIND
    ELP%R=EL%R
    ELP%X=EL%X
    ELP%Y=EL%Y
  END SUBROUTINE  equal_A



  SUBROUTINE  equal_p(elp,el)
    implicit none
    type (MAGNET_CHART),INTENT(inOUT)::elP
    type (MAGNET_CHART),INTENT(IN)::el

    elp%beta0 =el%beta0
    elp%gamma0I=el%gamma0I
    elp%gambet =el%gambet
    elp%P0C =el%P0C
    elp%EXACT=el%EXACT
    elp%RADIATION=el%RADIATION
    elp%TIME=el%TIME
    elp%NOCAVITY=el%NOCAVITY
    elp%FRINGE=el%FRINGE
    elp%LD=el%LD
    elp%LC=el%LC
    elp%TILTD=el%TILTD
    elp%B0=el%B0
    elp%EDGE(1)=el%EDGE(1)
    elp%EDGE(2)=el%EDGE(2)
    elp%METHOD=el%METHOD
    elp%NST=el%NST
    ELP%TOTALPATH=EL%TOTALPATH
    ELP%nmul=EL%nmul
    !    ELP%TRACK=EL%TRACK

    if(associated(el%f)) then
       elp%f=el%f
    endif
    if(associated(el%APERTURE)) then
       if(.not.associated(elp%APERTURE)) call alloc(elp%APERTURE)
       elp%APERTURE=el%APERTURE
    endif

  end SUBROUTINE  equal_p

  SUBROUTINE  CHECK_APERTURE_R(E,X)
    implicit none
    type (MADX_APERTURE),INTENT(IN)::E
    REAL(DP), INTENT(IN):: X(6)


    IF(CHECK_MADX_APERTURE.AND.APERTURE_FLAG) THEN

       SELECT CASE(E%KIND)
       CASE(1)
          IF(X(1)**2/E%R(1)**2+X(3)**2/E%R(2)**2>ONE) THEN
             CHECK_STABLE=.FALSE.
             CHECK_MADX_APERTURE=.false.
          ENDIF
       CASE(2)
          IF(ABS(X(1))>E%X) THEN
             CHECK_STABLE=.FALSE.
             CHECK_MADX_APERTURE=.false.
          ENDIF
          IF(ABS(X(3))>E%Y) THEN
             CHECK_STABLE=.FALSE.
             CHECK_MADX_APERTURE=.false.
          ENDIF
       CASE(3)  ! SQUARE + ELLIPSE
          IF((ABS(X(3))>E%Y).OR.(X(1)**2/E%R(1)**2+X(3)**2/E%R(2)**2>ONE)) THEN
             CHECK_STABLE=.FALSE.
             CHECK_MADX_APERTURE=.false.
          ENDIF
       CASE(4) ! MARGUERITE
          IF((X(1)**2/E%R(2)**2+X(3)**2/E%R(1)**2>ONE).OR.  &
               (X(1)**2/E%R(1)**2+X(3)**2/E%R(2)**2>ONE)) THEN
             CHECK_STABLE=.FALSE.
             CHECK_MADX_APERTURE=.false.
          ENDIF
       CASE(5) ! PILES OF POINTS
          STOP 222

       END SELECT
    ENDIF

  END SUBROUTINE  CHECK_APERTURE_R

  SUBROUTINE  CHECK_APERTURE_P(E,X)
    implicit none
    type (MADX_APERTURE),INTENT(IN)::E
    TYPE(REAL_8), INTENT(IN):: X(6)
    REAL(DP) Y(6)
    Y=X
    CALL CHECK_APERTURE(E,Y)

  END SUBROUTINE  CHECK_APERTURE_P


  SUBROUTINE  CHECK_APERTURE_S(E,X)
    implicit none
    type (MADX_APERTURE),INTENT(IN)::E
    TYPE(ENV_8), INTENT(IN):: X(6)
    REAL(DP) Y(6)
    Y=X
    CALL CHECK_APERTURE(E,Y)

  END SUBROUTINE  CHECK_APERTURE_S

  FUNCTION minu( S1,S2  )
    implicit none
    logical(lp) minu
    logical(lp), INTENT (IN) :: S1
    logical(lp), INTENT (IN) :: S2

    minu=.false.
    if(s1.and.(.not.s2)) minu=.true.

  END FUNCTION minu



  SUBROUTINE  EQUALTILT(S2,S1)
    implicit none
    INTEGER I
    type (TILTING),INTENT(OUT)::S2
    type (TILTING),INTENT(IN)::S1

    S2%NATURAL=S1%NATURAL
    DO I=0,NMAX
       S2%TILT(I)=S1%TILT(I)
    ENDDO

  END SUBROUTINE EQUALTILT


  SUBROUTINE MAKE_STATES_0(particle)
    USE   definition
    USE   da_arrays
    IMPLICIT NONE
    LOGICAL(lp) particle
    integer i
    W_P=>W_I


    insane_PTC=.true.
    NEWFILE%MF=.FALSE.
    CLOSEFILE%MF=.FALSE.
    KNOB=.FALSE.
    SETKNOB=.TRUE.

    CALL MAKE_YOSHIDA
    MYTYPE(0)=" MARKER"
    MYTYPE(kind1)=" DRIFT"
    MYTYPE(kind2)=" DRIFT-KICK-DRIFT"
    MYTYPE(kind3)=" THIN ELEMENT"
    MYTYPE(kind4)=" RF CAVITY"
    MYTYPE(kind5)=" SOLENOID "
    MYTYPE(kind6)=" KICK-SixTrack-KICK "
    MYTYPE(kind7)=" MATRIX-KICK-MATRIX "
    MYTYPE(kind8)=" NORMAL SMI "
    MYTYPE(kind9)=" SKEW   SMI "
    MYTYPE(kind10)=" EXACT SECTOR "
    MYTYPE(kind11)=" MONITOR "
    MYTYPE(kind12)=" HORIZONTAL MONITOR "
    MYTYPE(kind13)=" VERTICAL MONITOR "
    MYTYPE(kind14)=" INSTRUMENT "
    MYTYPE(kind15)=" ELECTRIC SEPTUM "
    !                   123456789012345678901234
    MYTYPE(kind16)=" STRAIGHT EXACT (BEND) "
    MYTYPE(kind17)=" SOLENOID SIXTRACK"
    MYTYPE(KINDFITTED)=" FITTED "
    MYTYPE(KINDUSER1)=" USER_1 "
    MYTYPE(KINDUSER2)=" USER_2 "
    ind_stoc(1)='100000'
    ind_stoc(2)='010000'
    ind_stoc(3)='001000'
    ind_stoc(4)='000100'
    ind_stoc(5)='000010'
    ind_stoc(6)='000001'
    MADTHICK=>MADKIND2
    MADTHIN_NORMAL=>MADKIND3N
    MADTHIN_SKEW=>MADKIND3S

    MADFAC=one   ! to prevent overflow (David Sagan)
    DO I=2,NMAX
       MADFAC(I)=(I-1)*MADFAC(I-1)
    ENDDO

    w_p=0
    w_p%nc=1
    w_p%fc='(2((1X,A72,/)))'
    w_p%c(1) = " RBEND ARE READ DIFFERENTLY DEPENDING ON VARIABLE MADLENGTH"
    IF(MADLENGTH) THEN
       w_p%c(2) = " INPUT OF CARTESIAN LENGTH FOR RBEND  "
    ELSE
       w_p%c(2) = " INPUT OF POLAR LENGTH FOR RBEND  "
    ENDIF
    CALL WRITE_I

    NSTD=1
    METD=2
    electron=PARTICLE
    w_p=0
    w_p%nc=1
    w_p%fc='(1((1X,A72)))'
    IF(ELECTRON) THEN
       w_p%c(1) = " THIS IS A ELECTRON (POSITRON ACTUALLY) "
    ELSE
       w_p%c(1) = " THIS IS A PROTON "
    ENDIF
    tilt%natural=.true.
    tilt%tilt(0)=zero
    do i=1,nmax
       tilt%tilt(i)=pih/i
    enddo
    !  SECTOR_B AND SECTOR_NMUL FOR TYPE TEAPOT
    IF(SECTOR_NMUL>0) THEN
       if(firsttime_coef) then
          SECTOR_B%firsttime=0   !slightly unsafe
       endif
       call nul_coef(SECTOR_B)
       call make_coef(SECTOR_B,SECTOR_NMUL)
       call curvebend(SECTOR_B,SECTOR_NMUL)
       w_p=1
       w_p%nc=1
       w_p%fc='(1((1X,A34)))'
       w_p%fI='(2((1X,I4)),/)'
       W_P=(/SECTOR_NMUL,sector_b%n_mono/)
       w_p%c(1) = " Small Machine Sector Bend Order ="
       CALL WRITE_I
    ENDIF

    call clear_states

  END  SUBROUTINE MAKE_STATES_0

  subroutine clear_states     !%nxyz
    implicit none
    DEFAULT=DEFAULT0
    TOTALPATH=TOTALPATH0
    RADIATION=RADIATION0
    NOCAVITY=NOCAVITY0
    FRINGE=FRINGE0
    TIME=TIME0
    EXACTMIS=EXACTMIS0
    ONLY_4D=ONLY_4d0
    DELTA=DELTA0
  end subroutine clear_states  !%nxyz

  subroutine print_s(S,MF)
    implicit none
    type (INTERNAL_STATE),INTENT(INOUT)::S
    INTEGER MF

    w_p=0
    w_p%nc=16
    w_p%fc='(16(1X,A72,/))'
    w_p%c(1) = "************ State Summary ****************"
    write(w_p%c(2),'((1X,a16,1x,i4,1x,a24))' ) "MADTHICK=>KIND =", MADKIND2,Mytype(MADKIND2)
    if(MADLENGTH) then
       w_p%c(3) = ' Rectangular Bend: input cartesian length '
    else
       w_p%c(3) = ' Rectangular Bend: input arc length (rho alpha) '
    endif
    write(w_p%c(4),'((1X,a28,1x,i4))' ) ' Default integration method ',METD
    write(w_p%c(5),'((1X,a28,1x,i4))' ) ' Default integration steps  ',NSTD

    If(electron) then
       if(muon==one)  then
          w_p%c(6) = "This is an electron (positron actually) "
       else
          write(w_p%c(6),'((1X,a21,1x,G20.14,1x,A24))' ) "This a particle with ",muon, "times the electron mass "
       endif
    else
       w_p%c(6) = "This is a proton "
    endif
    write(w_p%c(7), '((1X,a20,1x,a5))' )  "      EXACT_MODEL = ", CONV(EXACT_MODEL    )
    write(w_p%c(8), '((1X,a20,1x,a5))' )  "      TOTALPATH   = ", CONV(S%TOTALPATH)
    write(w_p%c(9), '((1X,a20,1x,a5))' )  "      EXACTMIS    = ", CONV(S%EXACTMIS    )
    write(w_p%c(10),'((1X,a20,1x,a5))' ) "      RADIATION   = ", CONV(S%RADIATION  )
    write(w_p%c(11),'((1X,a20,1x,a5))' ) "      NOCAVITY    = ", CONV(S%NOCAVITY )
    write(w_p%c(12),'((1X,a20,1x,a5))' ) "      TIME        = ", CONV(S%TIME )
    write(w_p%c(13),'((1X,a20,1x,a5))' ) "      FRINGE      = ", CONV(S%FRINGE   )
    write(w_p%c(14),'((1X,a20,1x,a5))' ) "      PARA_IN     = ", CONV(S%PARA_IN  )
    write(w_p%c(15),'((1X,a20,1x,a5))' ) "      ONLY_4D     = ", CONV(S%ONLY_4D   )
    write(w_p%c(16),'((1X,a20,1x,a5))' ) "      DELTA       = ", CONV(S%DELTA    )
    CALL WRITE_I
  end subroutine print_s

  FUNCTION CONV(LOG)
    IMPLICIT NONE
    CHARACTER(5) CONV
    logical(lp) LOG
    CONV="FALSE"
    IF(LOG) CONV="TRUE "
  END FUNCTION CONV

  SUBROUTINE MAKE_STATES_m(muonfactor)
    USE   definition
    IMPLICIT NONE
    logical(lp) :: doneitt=.true.
    real(dp) muonfactor
    CALL MAKE_YOSHIDA
    muon=muonfactor
    call MAKE_STATES_0(doneitt)
  END  SUBROUTINE MAKE_STATES_m

  SUBROUTINE update_STATES
    USE   definition
    IMPLICIT NONE

    TOTALPATH=  TOTALPATH+DEFAULT

    RADIATION=  RADIATION+DEFAULT

    NOCAVITY=  NOCAVITY+DEFAULT

    TIME=  TIME+DEFAULT

    FRINGE=  FRINGE+DEFAULT

    ONLY_4D= ONLY_4D+DEFAULT

    DELTA= DELTA+DEFAULT

    EXACTMIS= EXACTMIS+DEFAULT

  END  SUBROUTINE update_STATES


  SUBROUTINE  EQUALt(S2,S1)
    implicit none
    type (INTERNAL_STATE),INTENT(OUT)::S2
    type (INTERNAL_STATE),INTENT(IN)::S1

    S2%TOTALPATH=   S1%TOTALPATH
    S2%EXACTMIS=       S1%EXACTMIS
    S2%RADIATION=     S1%RADIATION
    S2%NOCAVITY=    S1%NOCAVITY
    S2%TIME=        S1%TIME
    S2%FRINGE=           S1%FRINGE
    S2%PARA_IN=     S1%PARA_IN
    S2%ONLY_4D=      S1%ONLY_4D
    S2%DELTA=       S1%DELTA
  END SUBROUTINE EQUALt



  FUNCTION add( S1, S2 )
    implicit none
    TYPE (INTERNAL_STATE) add
    TYPE (INTERNAL_STATE), INTENT (IN) :: S1, S2


    add%TOTALPATH=  S1%TOTALPATH.OR.S2%TOTALPATH
    !    add%EXACT    =       S1%EXACT.OR.S2%EXACT
    add%EXACTMIS    =       S1%EXACTMIS.OR.S2%EXACTMIS
    add%RADIATION  =  S1%RADIATION.OR.S2%RADIATION
    add%NOCAVITY =  S1%NOCAVITY.OR.S2%NOCAVITY
    add%TIME     =  S1%TIME.OR.S2%TIME
    add%FRINGE   =       S1%FRINGE.OR.S2%FRINGE
    add%ONLY_4D  =       S1%ONLY_4D.OR.S2%ONLY_4D
    add%DELTA  =       S1%DELTA.OR.S2%DELTA
    add%PARA_IN  =       S1%PARA_IN.OR.S2%PARA_IN
    IF(add%DELTA) THEN
       add%ONLY_4D=T
       add%NOCAVITY =  T
    ENDIF
    IF(add%ONLY_4D) THEN
       add%TOTALPATH=  F
       add%RADIATION  =  F
       add%NOCAVITY =  T
    ENDIF

  END FUNCTION add

  FUNCTION sub( S1, S2 )
    implicit none
    TYPE (INTERNAL_STATE) sub
    TYPE (INTERNAL_STATE), INTENT (IN) :: S1, S2


    sub%TOTALPATH=  S1%TOTALPATH.min.S2%TOTALPATH
    sub%EXACTMIS    =       S1%EXACTMIS.min.S2%EXACTMIS
    sub%RADIATION  =  S1%RADIATION.min.S2%RADIATION
    sub%NOCAVITY =  S1%NOCAVITY.min.S2%NOCAVITY
    sub%TIME     =  S1%TIME.min.S2%TIME
    sub%FRINGE   =       S1%FRINGE.min.S2%FRINGE
    sub%ONLY_4D  =       S1%ONLY_4D.min.S2%ONLY_4D
    sub%DELTA  =       S1%DELTA.min.S2%DELTA
    sub%PARA_IN  =       S1%PARA_IN.MIN.S2%PARA_IN
    IF(sub%DELTA) THEN
       sub%ONLY_4D=T
       sub%NOCAVITY =  T
    ENDIF
    IF(sub%ONLY_4D) THEN
       sub%TOTALPATH=  F
       sub%RADIATION  =  F
       sub%NOCAVITY =  T
    ENDIF

  END FUNCTION sub

  FUNCTION PARA_REMA(S1)   ! UNARY +
    implicit none
    TYPE (INTERNAL_STATE) PARA_REMA
    TYPE (INTERNAL_STATE), INTENT (IN) :: S1

    PARA_REMA         =    S1
    PARA_REMA%PARA_IN =     T

  END FUNCTION PARA_REMA



  subroutine S_init(STATE,NO1,NP1,PACKAGE,ND2,NPARA)
    !  subroutine S_init(STATE,NO1,NP1,PACKAGE,MAPINT,ND2,NPARA)
    implicit none
    TYPE (INTERNAL_STATE), INTENT(IN):: STATE
    LOGICAL(lp), INTENT(IN):: PACKAGE
    INTEGER, INTENT(IN):: NO1,NP1
    INTEGER ND1,NDEL,NDPT1
    INTEGER, INTENT(OUT)::    ND2,NPARA

    NDEL=0
    NDPT1=0
    IF(STATE%NOCAVITY)  THEN
       IF(STATE%ONLY_4D) THEN
          IF(STATE%DELTA) THEN
             ND1=2
             NDEL=1
             !             MAPINT=5
          ELSE
             ND1=2
             NDEL=0
             !            MAPINT=4
          ENDIF
       ELSE
          ND1=3
          NDEL=0
          NDPT1=5
          !         MAPINT=6
       ENDIF
    ELSE              ! CAVITY IN RING
       ND1=3
       NDPT1=0
       !       MAPINT=6
    ENDIF

    CALL INIT(NO1,ND1,NP1+NDEL,NDPT1,PACKAGE)

    ND2=ND1*2
    NPARA=ND2+NDEL
  END  subroutine S_init

  SUBROUTINE MAKE_METHOD(N)
    IMPLICIT NONE
    integer I,J,N


    ALLOCATE(SPK(N,METHOD_F:METHOD_1))
    ALLOCATE(SPD(N,METHOD_F:METHOD_1))
    ALLOCATE(SPN(METHOD_F:METHOD_1))
    ALLOCATE(SDF(N))
    ALLOCATE(SDK(N))
    ALLOCATE(SDDF(N))
    ALLOCATE(PSDF(N))  ! POLYMORPHS
    ALLOCATE(PSDK(N))  ! POLYMORPHS

    DO J=METHOD_F,METHOD_1
       SPN(J)=N               ! DEFAULT
       DO I=1,N
          SDF(I)=zero
          SDK(I)=zero
          SDK(I)=zero
          SPK(I,J)=zero
          SPD(I,J)=zero
       ENDDO
    ENDDO
    NEW_METHOD=.TRUE.

  END SUBROUTINE MAKE_METHOD

  SUBROUTINE KILL_METHOD
    IMPLICIT NONE
    integer ERROR

    DEALLOCATE (SPK, STAT = error)
    IF(ERROR==0) THEN
       w_p=0
       w_p%nc=1
       w_p%fc='(1(1X,A72))'
       w_p%c(1) = " SPK ARRAY DEALLOCATED "
       call WRITE_I
    ELSE
       w_p=0
       w_p%nc=1
       w_p%fc='(1(1X,A72))'
       w_p%c(1) = " SPK ARRAY not DEALLOCATED : PROBLEMS"
       call WRITE_I
    ENDIF

    DEALLOCATE (SPD, STAT = error)
    IF(ERROR==0) THEN
       w_p=0
       w_p%nc=1
       w_p%fc='(1(1X,A72))'
       w_p%c(1) =  " SPD ARRAY DEALLOCATED "
       call WRITE_I
    ELSE
       w_p=0
       w_p%nc=1
       w_p%fc='(1(1X,A72))'
       w_p%c(1) =  " SPD ARRAY not DEALLOCATED : PROBLEMS"
       call WRITE_I
    ENDIF

    DEALLOCATE (SPN, STAT = error)
    IF(ERROR==0) THEN
       w_p=0
       w_p%nc=1
       w_p%fc='(1(1X,A72))'
       w_p%c(1) =  " SPN ARRAY DEALLOCATED "
       call WRITE_I
    ELSE
       w_p=0
       w_p%nc=1
       w_p%fc='(1(1X,A72))'
       w_p%c(1) =  " SPN ARRAY not DEALLOCATED : PROBLEMS"
       call WRITE_I
    ENDIF

    DEALLOCATE (SDF, STAT = error)
    IF(ERROR==0) THEN
       w_p=0
       w_p%nc=1
       w_p%fc='(1(1X,A72))'
       w_p%c(1) =  " SDF ARRAY DEALLOCATED "
       call WRITE_I
    ELSE
       w_p=0
       w_p%nc=1
       w_p%fc='(1(1X,A72))'
       w_p%c(1) =  " SDF ARRAY not DEALLOCATED : PROBLEMS"
       call WRITE_I
    ENDIF

    DEALLOCATE (SDK, STAT = error)
    IF(ERROR==0) THEN
       w_p=0
       w_p%nc=1
       w_p%fc='(1(1X,A72))'
       w_p%c(1) =  " SDK ARRAY DEALLOCATED "
       call WRITE_I
    ELSE
       w_p=0
       w_p%nc=1
       w_p%fc='(1(1X,A72))'
       w_p%c(1) =  " SDK ARRAY not DEALLOCATED : PROBLEMS"
       call WRITE_I
    ENDIF

    DEALLOCATE (PSDF, STAT = error)
    IF(ERROR==0) THEN
       w_p=0
       w_p%nc=1
       w_p%fc='(1(1X,A72))'
       w_p%c(1) =  " PSDF ARRAY DEALLOCATED "
       call WRITE_I
    ELSE
       w_p=0
       w_p%nc=1
       w_p%fc='(1(1X,A72))'
       w_p%c(1) =  " PSDF ARRAY not DEALLOCATED : PROBLEMS"
       call WRITE_I
    ENDIF

    DEALLOCATE (PSDK, STAT = error)
    IF(ERROR==0) THEN
       w_p=0
       w_p%nc=1
       w_p%fc='(1(1X,A72))'
       w_p%c(1) =  " PSDK ARRAY DEALLOCATED "
       call WRITE_I
    ELSE
       w_p=0
       w_p%nc=1
       w_p%fc='(1(1X,A72))'
       w_p%c(1) =  " PSDK ARRAY not DEALLOCATED : PROBLEMS"
       call WRITE_I
    ENDIF

    DEALLOCATE (SDDF, STAT = error)
    IF(ERROR==0) THEN
       w_p=0
       w_p%nc=1
       w_p%fc='(1(1X,A72))'
       w_p%c(1) =  " SDDF ARRAY DEALLOCATED "
       call WRITE_I
    ELSE
       w_p=0
       w_p%nc=1
       w_p%fc='(1(1X,A72))'
       w_p%c(1) =  " SDDF ARRAY not DEALLOCATED : PROBLEMS"
       call WRITE_I
    ENDIF

    NEW_METHOD=.FALSE.

  END SUBROUTINE KILL_METHOD


  SUBROUTINE B2PERPR(P,B,X,X5,B2)
    IMPLICIT NONE
    real(dp), INTENT(INOUT) :: B2
    real(dp), INTENT(IN) :: X(6),B(3),X5
    TYPE(MAGNET_CHART), INTENT(IN) :: P
    real(dp) E(3)
    !---  GOOD FOR TIME=FALSE
    E(1)=P%DIR*X(2)/(one+X5)
    E(2)=P%DIR*X(4)/(one+X5)
    E(3)=P%DIR*ROOT((one+X5)**2-X(2)**2-X(4)**2)/(one+X5)

    B2=zero
    B2=(B(2)*E(3)-B(3)*E(2))**2+B2
    B2=(B(1)*E(2)-B(2)*E(1))**2+B2
    B2=(B(3)*E(1)-B(1)*E(3))**2+B2

    RETURN
  END       SUBROUTINE B2PERPR


  SUBROUTINE B2PERPP(P,B,X,X5,B2)
    IMPLICIT NONE
    TYPE(REAL_8) , INTENT(INOUT) :: B2
    TYPE(REAL_8) , INTENT(IN) :: X(6),B(3),X5
    TYPE(MAGNET_CHART), INTENT(IN) :: P
    TYPE(REAL_8)  E(3)
    CALL ALLOC(E,3)
    !---  GOOD FOR TIME=FALSE
    E(1)=P%DIR*X(2)/(one+X5)
    E(2)=P%DIR*X(4)/(one+X5)
    E(3)=P%DIR*SQRT((one+X5)**2-X(2)**2-X(4)**2)/(one+X5)


    B2=zero
    B2=(B(2)*E(3)-B(3)*E(2))**2+B2
    B2=(B(1)*E(2)-B(2)*E(1))**2+B2
    B2=(B(3)*E(1)-B(1)*E(3))**2+B2
    CALL KILL(E,3)
    RETURN
  END       SUBROUTINE B2PERPP

  SUBROUTINE DTILTR(EL,I,X)
    IMPLICIT NONE
    real(dp),INTENT(INOUT):: X(6)
    INTEGER,INTENT(IN):: I
    TYPE(MAGNET_CHART),INTENT(IN):: EL
    real(dp) YS
    IF(EL%TILTD==zero) RETURN
    IF(I==1) THEN
       ys=COS(EL%DIR*el%tiltd)*x(1)+SIN(EL%DIR*el%tiltd)*x(3)
       x(3)=COS(EL%DIR*el%tiltd)*x(3)-SIN(EL%DIR*el%tiltd)*x(1)
       x(1)=ys
       ys=COS(EL%DIR*el%tiltd)*x(2)+SIN(EL%DIR*el%tiltd)*x(4)
       x(4)=COS(EL%DIR*el%tiltd)*x(4)-SIN(EL%DIR*el%tiltd)*x(2)
       x(2)=ys
    ELSE
       ys=COS(EL%DIR*el%tiltd)*x(1)-SIN(EL%DIR*el%tiltd)*x(3)
       x(3)=COS(EL%DIR*el%tiltd)*x(3)+SIN(EL%DIR*el%tiltd)*x(1)
       x(1)=ys
       ys=COS(EL%DIR*el%tiltd)*x(2)-SIN(EL%DIR*el%tiltd)*x(4)
       x(4)=COS(EL%DIR*el%tiltd)*x(4)+SIN(EL%DIR*el%tiltd)*x(2)
       x(2)=ys
    ENDIF

  END SUBROUTINE DTILTR

  SUBROUTINE DTILTP(EL,I,X)
    IMPLICIT NONE
    TYPE(MAGNET_CHART),INTENT(IN):: EL
    TYPE(REAL_8),INTENT(INOUT):: X(6)
    INTEGER,INTENT(IN):: I
    TYPE(REAL_8) YS

    IF(EL%TILTD==zero) RETURN
    CALL ALLOC(YS)

    IF(I==1) THEN
       ys=COS(EL%DIR*el%tiltd)*x(1)+SIN(EL%DIR*el%tiltd)*x(3)
       x(3)=COS(EL%DIR*el%tiltd)*x(3)-SIN(EL%DIR*el%tiltd)*x(1)
       x(1)=ys
       ys=COS(EL%DIR*el%tiltd)*x(2)+SIN(EL%DIR*el%tiltd)*x(4)
       x(4)=COS(EL%DIR*el%tiltd)*x(4)-SIN(EL%DIR*el%tiltd)*x(2)
       x(2)=ys
    ELSE
       ys=COS(EL%DIR*el%tiltd)*x(1)-SIN(EL%DIR*el%tiltd)*x(3)
       x(3)=COS(EL%DIR*el%tiltd)*x(3)+SIN(EL%DIR*el%tiltd)*x(1)
       x(1)=ys
       ys=COS(EL%DIR*el%tiltd)*x(2)-SIN(EL%DIR*el%tiltd)*x(4)
       x(4)=COS(EL%DIR*el%tiltd)*x(4)+SIN(EL%DIR*el%tiltd)*x(2)
       x(2)=ys
    ENDIF
    CALL KILL(YS)

  END SUBROUTINE DTILTP

  SUBROUTINE DTILTS(EL,I,Y)
    IMPLICIT NONE
    TYPE(MAGNET_CHART),INTENT(IN):: EL
    TYPE(ENV_8),INTENT(INOUT):: Y(6)
    INTEGER,INTENT(IN):: I
    TYPE(REAL_8) X(6)

    IF(EL%TILTD==0) RETURN

    CALL ALLOC(X)
    X=Y
    CALL DTILTD(EL,I,X)
    Y=X
    CALL KILL(X)

  END SUBROUTINE DTILTS

end module S_status
