!The Full Polymorphic Package
!Copyright (C) Etienne Forest and Frank Schmidt
! See file a_scratch_size
module complex_taylor
  use tpsalie_analysis
  implicit none
  private mul,cscmul,cmulsc,dscmul,dmulsc,mulsc,scmul,imulsc,iscmul
  private ctmul, cmult,ctadd,caddt,ctsub,csubt,ctdiv,cdivt
  private add,cscadd,dscadd,caddsc,daddsc,unaryADD,addsc,scadd,iaddsc,iscadd
  private tadd,addt,tmul,mult,tsub,subt,tdiv,divt
  private inv,div,dscdiv,cscdiv,cdivsc,ddivsc,divsc,scdiv,idivsc,iscdiv
  private subs,cscsub,dscsub,csubsc,dsubsc,iscsub,isubsc,scsub,subsc,unarySUB
  private EQUAL,cequaldacon,Dequaldacon,equaldacon,Iequaldacon,ctEQUAL,tcEQUAL
  private pow,powr,POWR8  !,DAABSEQUAL,AABSEQUAL 2002.10.17
  private alloccomplex   !,printcomplex ,killcomplex
  private logtpsat,exptpsat,abstpsat,dcost,dsint,datant,tant,dasint,dacost
  private dcosht,dsinht,dtanht,dsqrtt
  private getdiff,getdATRA,GETORDER,CUTORDER,getchar ,dputchar,dputint
  private check,set_in_complex   !, assc
  private dimagt,drealt,dcmplxt
  private GETCHARnd2,GETintnd2
  private CFUC,CFURES
  integer,private::NO,ND,ND2,NP,NDPT,NV,lastmaster
  logical(lp),private::old


  INTERFACE assignment (=)
     MODULE PROCEDURE EQUAL
     MODULE PROCEDURE ctEQUAL
     MODULE PROCEDURE tcEQUAL
     !     MODULE PROCEDURE DAABSEQUAL  ! remove 2002.10.17
     !     MODULE PROCEDURE AABSEQUAL    ! remove 2002.10.17
     MODULE PROCEDURE cequaldacon
     MODULE PROCEDURE Dequaldacon
     MODULE PROCEDURE equaldacon
     MODULE PROCEDURE Iequaldacon
  end  INTERFACE

  INTERFACE abs
     MODULE PROCEDURE abstpsat
  END INTERFACE
  INTERFACE dabs
     MODULE PROCEDURE abstpsat
  END INTERFACE

  INTERFACE OPERATOR (*)
     MODULE PROCEDURE mul
     MODULE PROCEDURE tmul
     MODULE PROCEDURE mult
     MODULE PROCEDURE  cscmul
     MODULE PROCEDURE  ctmul
     MODULE PROCEDURE  dscmul
     MODULE PROCEDURE  cmulsc
     MODULE PROCEDURE  cmult
     MODULE PROCEDURE  dmulsc
     MODULE PROCEDURE mulsc
     MODULE PROCEDURE scmul
     MODULE PROCEDURE imulsc
     MODULE PROCEDURE iscmul
  END INTERFACE

  INTERFACE OPERATOR (+)
     MODULE PROCEDURE add
     MODULE PROCEDURE tadd
     MODULE PROCEDURE addt
     MODULE PROCEDURE cscadd
     MODULE PROCEDURE dscadd
     MODULE PROCEDURE ctadd
     MODULE PROCEDURE caddt
     MODULE PROCEDURE caddsc
     MODULE PROCEDURE daddsc
     MODULE PROCEDURE unaryADD
     MODULE PROCEDURE addsc
     MODULE PROCEDURE scadd
     MODULE PROCEDURE iaddsc
     MODULE PROCEDURE iscadd
  END INTERFACE



  INTERFACE OPERATOR (/)
     MODULE PROCEDURE div
     MODULE PROCEDURE divt
     MODULE PROCEDURE tdiv
     MODULE PROCEDURE ctdiv
     MODULE PROCEDURE cdivt
     MODULE PROCEDURE ddivsc
     MODULE PROCEDURE cdivsc
     MODULE PROCEDURE dscdiv
     MODULE PROCEDURE cscdiv
     MODULE PROCEDURE divsc
     MODULE PROCEDURE scdiv
     MODULE PROCEDURE idivsc
     MODULE PROCEDURE iscdiv
  END INTERFACE

  INTERFACE OPERATOR (-)
     MODULE PROCEDURE unarySUB
     MODULE PROCEDURE subs
     MODULE PROCEDURE ctsub
     MODULE PROCEDURE csubt
     MODULE PROCEDURE tsub
     MODULE PROCEDURE subt
     MODULE PROCEDURE cscsub
     MODULE PROCEDURE dscsub
     MODULE PROCEDURE csubsc
     MODULE PROCEDURE dsubsc
     MODULE PROCEDURE subsc
     MODULE PROCEDURE scsub
     MODULE PROCEDURE isubsc
     MODULE PROCEDURE iscsub
  END INTERFACE



  INTERFACE OPERATOR (**)
     MODULE PROCEDURE POW
     MODULE PROCEDURE POWR
     MODULE PROCEDURE POWR8
  END INTERFACE

  INTERFACE OPERATOR (.d.)
     MODULE PROCEDURE getdiff
  END INTERFACE

  INTERFACE OPERATOR (.K.)
     MODULE PROCEDURE getdATRA
  END INTERFACE

  INTERFACE OPERATOR (.SUB.)
     MODULE PROCEDURE GETORDER
     MODULE PROCEDURE getchar
  END INTERFACE

  INTERFACE OPERATOR (.CUT.)
     MODULE PROCEDURE CUTORDER
  END INTERFACE

  INTERFACE OPERATOR (.mono.)
     MODULE PROCEDURE dputchar
     MODULE PROCEDURE dputint
  END INTERFACE

  INTERFACE OPERATOR (.PAR.)
     MODULE PROCEDURE getcharnd2
     MODULE PROCEDURE GETintnd2
  END INTERFACE

  INTERFACE dimag
     MODULE PROCEDURE dimagt
  END INTERFACE

  INTERFACE dble
     MODULE PROCEDURE drealt
  END INTERFACE

  INTERFACE aimag
     MODULE PROCEDURE dimagt
  END INTERFACE

  INTERFACE dreal
     MODULE PROCEDURE drealt
  END INTERFACE

  INTERFACE ass
     MODULE PROCEDURE assc
  END INTERFACE

  INTERFACE var
     MODULE PROCEDURE varc
     MODULE PROCEDURE varcC
  END INTERFACE

  INTERFACE shiftda
     MODULE PROCEDURE shiftc
  END INTERFACE

  INTERFACE pok
     MODULE PROCEDURE pokc
  END INTERFACE

  INTERFACE pek
     MODULE PROCEDURE pekc
  END INTERFACE

  INTERFACE CFU
     MODULE PROCEDURE CFUC
     MODULE PROCEDURE CFURES
  END INTERFACE

  INTERFACE alloc
     MODULE PROCEDURE alloccomplex
     MODULE PROCEDURE alloccomplexn
  END INTERFACE


  INTERFACE kill
     MODULE PROCEDURE killcomplex
     MODULE PROCEDURE killcomplexn
  END INTERFACE

  INTERFACE daprint
     MODULE PROCEDURE printcomplex
  END INTERFACE

  INTERFACE dainput
     MODULE PROCEDURE inputcomplex
  END INTERFACE

  INTERFACE print
     MODULE PROCEDURE printcomplex
  END INTERFACE

  INTERFACE read
     MODULE PROCEDURE inputcomplex
  END INTERFACE

  INTERFACE log
     MODULE PROCEDURE logtpsat
  END INTERFACE
  INTERFACE dlog
     MODULE PROCEDURE logtpsat
  END INTERFACE
  INTERFACE clog
     MODULE PROCEDURE logtpsat
  END INTERFACE
  INTERFACE cdlog
     MODULE PROCEDURE logtpsat
  END INTERFACE

  INTERFACE dcmplx
     MODULE PROCEDURE dcmplxt
  END INTERFACE

  INTERFACE cmplx
     MODULE PROCEDURE dcmplxt
  END INTERFACE


  INTERFACE datan
     MODULE PROCEDURE datant
  END INTERFACE
  INTERFACE atan
     MODULE PROCEDURE datant
  END INTERFACE

  INTERFACE dasin
     MODULE PROCEDURE dasint
  END INTERFACE
  INTERFACE asin
     MODULE PROCEDURE dasint
  END INTERFACE

  INTERFACE dacos
     MODULE PROCEDURE dacost
  END INTERFACE
  INTERFACE acos
     MODULE PROCEDURE dacost
  END INTERFACE

  INTERFACE dtan
     MODULE PROCEDURE tant
  END INTERFACE

  INTERFACE tan
     MODULE PROCEDURE tant
  END INTERFACE


  INTERFACE cdcos
     MODULE PROCEDURE dcost
  END INTERFACE
  INTERFACE ccos
     MODULE PROCEDURE dcost
  END INTERFACE
  INTERFACE dcos
     MODULE PROCEDURE dcost
  END INTERFACE
  INTERFACE cos
     MODULE PROCEDURE dcost
  END INTERFACE


  INTERFACE cdsin
     MODULE PROCEDURE dsint
  END INTERFACE
  INTERFACE csin
     MODULE PROCEDURE dsint
  END INTERFACE
  INTERFACE dsin
     MODULE PROCEDURE dsint
  END INTERFACE
  INTERFACE sin
     MODULE PROCEDURE dsint
  END INTERFACE


  INTERFACE exp
     MODULE PROCEDURE exptpsat
  END INTERFACE
  INTERFACE dexp
     MODULE PROCEDURE exptpsat
  END INTERFACE
  INTERFACE cexp
     MODULE PROCEDURE exptpsat
  END INTERFACE
  INTERFACE cdexp
     MODULE PROCEDURE exptpsat
  END INTERFACE


  INTERFACE cosh
     MODULE PROCEDURE dcosht
  END INTERFACE
  INTERFACE dcosh
     MODULE PROCEDURE dcosht
  END INTERFACE
  INTERFACE sinh
     MODULE PROCEDURE dsinht
  END INTERFACE
  INTERFACE dsinh
     MODULE PROCEDURE dsinht
  END INTERFACE
  INTERFACE tanh
     MODULE PROCEDURE dtanht
  END INTERFACE
  INTERFACE dtanh
     MODULE PROCEDURE dtanht
  END INTERFACE

  INTERFACE dsqrt
     MODULE PROCEDURE dsqrtt
  END INTERFACE
  INTERFACE cdsqrt
     MODULE PROCEDURE dsqrtt
  END INTERFACE
  INTERFACE sqrt
     MODULE PROCEDURE dsqrtt
  END INTERFACE



  INTERFACE init_complex
     MODULE PROCEDURE init_map_c
     MODULE PROCEDURE init_tpsa_c
  END INTERFACE


contains

  FUNCTION dimagt( S1 )
    implicit none
    TYPE (taylor) dimagt
    TYPE (complextaylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master


    call ass0(dimagt)

    dimagt=s1%i

    master=localmaster
  END FUNCTION dimagt

  FUNCTION drealt( S1 )
    implicit none
    TYPE (taylor) drealt
    TYPE (complextaylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master


    call ass0(drealt)

    drealt=s1%r

    master=localmaster
  END FUNCTION drealt

  FUNCTION GETCHARnd2( S1, S2 )
    implicit none
    TYPE (complextaylor) GETCHARnd2
    TYPE (complextaylor), INTENT (IN) :: S1
    CHARACTER(*)  , INTENT (IN) ::  S2

    integer localmaster
    localmaster=master

    call ass(GETCHARnd2)


    GETCHARnd2%r=s1%r.par.s2
    GETCHARnd2%i=s1%i.par.s2

    master=localmaster


  END FUNCTION GETCHARnd2

  FUNCTION GETintnd2( S1, S2 )
    implicit none
    TYPE (complextaylor) GETintnd2
    TYPE (complextaylor), INTENT (IN) :: S1
    integer  , INTENT (IN) ::  S2(:)

    integer localmaster
    localmaster=master

    call ass(GETintnd2)


    GETintnd2%r=s1%r.par.s2
    GETintnd2%i=s1%i.par.s2

    master=localmaster


  END FUNCTION GETintnd2

  FUNCTION dputchar( S1, S2 )
    implicit none
    TYPE (complextaylor) dputchar
    complex(dp) , INTENT (IN) :: S1
    CHARACTER(*)  , INTENT (IN) ::  S2
    CHARACTER (LEN = LNV)  resul
    integer j(lnv),i,nd2par

    integer localmaster
    localmaster=master

    call ass(dputchar)

    resul = trim(ADJUSTL (s2))

    do i=1,lnv
       j(i)=0
    enddo

    nd2par= len(trim(ADJUSTL (s2)))
    !frs    do i=1,len(trim(ADJUSTL (s2)))
    do i=1,nd2par
       CALL  CHARINT(RESUL(I:I),J(I))
       if(i>nv) then
          if(j(i)>0) then
             call var(dputchar,cmplx(zero,zero,kind=dp),0,0)
             return
          endif
       endif
    enddo


    call var(dputchar,cmplx(zero,zero,kind=dp),0,0)
    call pok(dputchar,j,s1)


    master=localmaster

  END FUNCTION dputchar

  FUNCTION dputint( S1, S2 )
    implicit none
    TYPE (complextaylor) dputint
    complex(dp) , INTENT (IN) :: S1
    integer  , INTENT (IN) ::  S2(:)
    integer j(lnv),i,nd2par

    integer localmaster
    localmaster=master

    call ass(dputint)


    do i=1,lnv
       j(i)=0
    enddo

    nd2par=size(s2)
    do i=1,nd2par
       J(I)=s2(i)
    enddo

    !frs    do i=1,len(trim(ADJUSTL (s2)))
    do i=1,nd2par
       if(i>nv) then
          if(j(i)>0) then
             call var(dputint,cmplx(zero,zero,kind=dp),0,0)
             return
          endif
       endif
    enddo



    call var(dputint,cmplx(zero,zero,kind=dp),0,0)
    call pok(dputint,j,s1)


    master=localmaster

  END FUNCTION dputint

  FUNCTION GETORDER( S1, S2 )
    implicit none
    TYPE (complextaylor) GETORDER
    TYPE (complextaylor), INTENT (IN) :: S1
    INTEGER, INTENT (IN) ::  S2

    integer localmaster
    localmaster=master
    call ass(GETORDER)

    GETORDER%r=S1%r.sub.s2
    GETORDER%i=S1%i.sub.s2


    master=localmaster

  END FUNCTION GETORDER

  FUNCTION CUTORDER( S1, S2 )
    implicit none
    TYPE (complextaylor) CUTORDER
    TYPE (complextaylor), INTENT (IN) :: S1
    INTEGER, INTENT (IN) ::  S2

    integer localmaster
    localmaster=master
    call ass(CUTORDER)

    CUTORDER%r=S1%r.CUT.s2
    CUTORDER%i=S1%i.CUT.s2


    master=localmaster

  END FUNCTION CUTORDER

  FUNCTION GETchar( S1, S2 )
    implicit none
    complex(dp) GETchar
    real(dp) r1,r2
    TYPE (complextaylor), INTENT (IN) :: S1
    CHARACTER(*)  , INTENT (IN) ::  S2

    integer localmaster
    localmaster=master

    r1=S1%r.sub.s2
    r2=S1%i.sub.s2

    GETchar=cmplx(r1,r2,kind=dp)

    master=localmaster
  END FUNCTION GETchar


  FUNCTION POW( S1, R2 )
    implicit none
    TYPE (complextaylor) POW,temp
    TYPE (complextaylor), INTENT (IN) :: S1
    INTEGER, INTENT (IN) :: R2
    INTEGER I,R22

    integer localmaster
    localmaster=master
    call ass(pow)

    call alloc(temp)

    TEMP=one


    R22=IABS(R2)
    DO I=1,R22
       temp=temp*s1
    ENDDO
    IF(R2.LT.0) THEN
       temp=one/temp
    ENDIF

    POW=temp

    call kill(temp)
    master=localmaster


  END FUNCTION POW

  FUNCTION POWR( S1, R2 )
    implicit none
    TYPE (complextaylor) POWR,temp
    TYPE (complextaylor), INTENT (IN) :: S1
    REAL(SP), INTENT (IN) :: R2
    integer localmaster

    if(real_warning) call real_stop
    localmaster=master
    call ass(POWR)
    call alloc(temp)

    temp=log(s1)
    temp=temp*(r2)
    temp=exp(temp)
    POWR=temp

    call kill(temp)
    master=localmaster

  END FUNCTION POWR

  FUNCTION POWR8( S1, R2 )
    implicit none
    TYPE (complextaylor) POWR8,temp
    TYPE (complextaylor), INTENT (IN) :: S1
    real(dp), INTENT (IN) :: R2

    integer localmaster
    localmaster=master
    call ass(powr8)
    call alloc(temp)

    temp=log(s1)
    temp=temp*r2
    temp=exp(temp)
    POWR8=temp

    call kill(temp)
    master=localmaster

  END FUNCTION POWR8

  FUNCTION GETdiff( S1, S2 )
    implicit none
    TYPE (complextaylor) GETdiff
    TYPE (complextaylor), INTENT (IN) :: S1
    INTEGER, INTENT (IN) ::  S2

    integer localmaster
    localmaster=master
    call ass(GETdiff)

    getdiff%r=s1%r.d.s2
    getdiff%i=s1%i.d.s2

    master=localmaster
  END FUNCTION GETdiff

  FUNCTION GETdatra( S1, S2 )
    implicit none
    TYPE (complextaylor) GETdatra
    TYPE (complextaylor), INTENT (IN) :: S1
    INTEGER, INTENT (IN) ::  S2

    integer localmaster
    localmaster=master
    call ass(GETdatra)

    GETdatra%r=s1%r.k.s2
    GETdatra%i=s1%i.k.s2

    master=localmaster
  END FUNCTION GETdatra

  SUBROUTINE  alloccomplex(S2)
    implicit none
    type (complextaylor),INTENT(INOUT)::S2
    call alloctpsa(s2%r)
    call alloctpsa(s2%i)
  END SUBROUTINE alloccomplex

  SUBROUTINE  alloccomplexn(S2,n)
    implicit none
    type (complextaylor),INTENT(INOUT),dimension(:)::S2
    integer, intent(in) :: n
    integer i
    do i=1,n
       call alloctpsa(s2(i)%r)
       call alloctpsa(s2(i)%i)
    enddo

  END SUBROUTINE alloccomplexn

  SUBROUTINE  printcomplex(S2,i)
    implicit none
    type (complextaylor),INTENT(INOUT)::S2
    integer i
    call daprint(s2%r,i)
    call daprint(s2%i,i)
  END SUBROUTINE printcomplex

  SUBROUTINE  inputcomplex(S2,i)
    implicit none
    type (complextaylor),INTENT(INOUT)::S2
    integer i
    call dainput(s2%r,i)
    call dainput(s2%i,i)
  END SUBROUTINE inputcomplex


  SUBROUTINE  killcomplex(S2)
    implicit none
    type (complextaylor),INTENT(INOUT)::S2
    call killTPSA(s2%r)
    call killTPSA(s2%i)
  END SUBROUTINE killcomplex

  SUBROUTINE  killcomplexn(S2,n)
    implicit none
    type (complextaylor),INTENT(INOUT),dimension(:)::S2
    integer, intent(in) :: n
    integer i
    do i=1,n
       call killtpsa(s2(i)%r)
       call killtpsa(s2(i)%i)
    enddo

  END SUBROUTINE killcomplexn

  FUNCTION mul( S1, S2 )
    implicit none
    TYPE (complextaylor) mul
    TYPE (complextaylor), INTENT (IN) :: S1, S2
    integer localmaster
    localmaster=master
    call ass(mul)
    mul%r=s1%r*s2%r-s1%i*s2%i
    mul%i=s1%r*s2%i+s1%i*s2%r
    master=localmaster
  END FUNCTION mul

  FUNCTION div( S1, S2 )
    implicit none
    TYPE (complextaylor) div ,t
    TYPE (complextaylor), INTENT (IN) :: S1, S2
    integer localmaster
    localmaster=master

    call ass(div)

    call alloc(t)
    call inv(s2,t)
    div%r=s1%r*t%r-s1%i*t%i
    div%i=s1%r*t%i+s1%i*t%r
    call kill(t)
    master=localmaster
  END FUNCTION div

  FUNCTION cscdiv( S1, S2 )
    implicit none
    TYPE (complextaylor) cscdiv ,t
    TYPE (complextaylor), INTENT (IN) ::  S2
    complex(dp), INTENT (IN) :: S1
    integer localmaster
    localmaster=master
    call ass(cscdiv)
    call alloc(t)
    call inv(s2,t)
    cscdiv%r=REAL(s1,kind=DP)*t%r-aimag(s1)*t%i
    cscdiv%i=REAL(s1,kind=DP)*t%i+aimag(s1)*t%r
    call kill(t)
    master=localmaster
  END FUNCTION cscdiv

  FUNCTION dscdiv( S1, S2 )
    implicit none
    TYPE (complextaylor) dscdiv ,t
    TYPE (complextaylor), INTENT (IN) ::  S2
    real(dp), INTENT (IN) :: S1
    integer localmaster
    localmaster=master
    call ass(dscdiv)
    call alloc(t)
    call inv(s2,t)
    dscdiv%r=s1*t%r
    dscdiv%i=s1*t%i
    call kill(t)
    master=localmaster
  END FUNCTION dscdiv

  FUNCTION scdiv( S1, S2 )
    implicit none
    TYPE (complextaylor) scdiv ,t
    TYPE (complextaylor), INTENT (IN) ::  S2
    real(sp), INTENT (IN) :: S1
    integer localmaster
    if(real_warning) call real_stop
    localmaster=master
    call ass(scdiv)
    call alloc(t)
    call inv(s2,t)
    scdiv%r=s1*t%r
    scdiv%i=s1*t%i
    call kill(t)
    master=localmaster
  END FUNCTION scdiv

  FUNCTION iscdiv( S1, S2 )
    implicit none
    TYPE (complextaylor) iscdiv ,t
    TYPE (complextaylor), INTENT (IN) ::  S2
    integer, INTENT (IN) :: S1
    integer localmaster
    localmaster=master
    call ass(iscdiv)
    call alloc(t)
    call inv(s2,t)
    iscdiv%r=s1*t%r
    iscdiv%i=s1*t%i
    call kill(t)
    master=localmaster
  END FUNCTION iscdiv

  FUNCTION idivsc( S2,S1  )
    implicit none
    TYPE (complextaylor) idivsc
    TYPE (complextaylor), INTENT (IN) ::  S2
    integer, INTENT (IN) :: S1
    integer localmaster
    localmaster=master
    call ass(idivsc)
    idivsc%r=(one/s1)*s2%r
    idivsc%i=(one/s1)*s2%i
    master=localmaster
  END FUNCTION idivsc


  FUNCTION divsc( S2,S1  )
    implicit none
    TYPE (complextaylor) divsc
    TYPE (complextaylor), INTENT (IN) ::  S2
    real(sp), INTENT (IN) :: S1
    integer localmaster
    if(real_warning) call real_stop
    localmaster=master
    call ass(divsc)
    divsc%r=(one/s1)*s2%r
    divsc%i=(one/s1)*s2%i
    master=localmaster
  END FUNCTION divsc


  FUNCTION ddivsc( S2,S1  )
    implicit none
    TYPE (complextaylor) ddivsc
    TYPE (complextaylor), INTENT (IN) ::  S2
    real(dp), INTENT (IN) :: S1
    integer localmaster
    localmaster=master
    call ass(ddivsc)
    ddivsc%r=(one/s1)*s2%r
    ddivsc%i=(one/s1)*s2%i
    master=localmaster
  END FUNCTION ddivsc

  FUNCTION cdivsc( S2,S1  )
    implicit none
    TYPE (complextaylor) cdivsc
    TYPE (complextaylor), INTENT (IN) ::  S2
    complex(dp), INTENT (IN) :: S1
    integer localmaster
    localmaster=master
    call ass(cdivsc)
    cdivsc%r=REAL((one/s1),kind=DP)*s2%r-aimag((one/s1))*s2%i
    cdivsc%i=REAL((one/s1),kind=DP)*s2%i+aimag((one/s1))*s2%r
    master=localmaster
  END FUNCTION cdivsc

  FUNCTION cscmul( sc,S1 )
    implicit none
    TYPE (complextaylor) cscmul
    TYPE (complextaylor), INTENT (IN) :: S1
    complex(dp), INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(cscmul)

    cscmul%r=REAL(sc,kind=DP)*s1%r-aimag(sc)*s1%i
    cscmul%i=REAL(sc,kind=DP)*s1%i+aimag(sc)*s1%r
    master=localmaster
  END FUNCTION cscmul

  FUNCTION ctmul( S1,sc )
    implicit none
    TYPE (complextaylor) ctmul
    TYPE (taylor), INTENT (IN) :: S1
    complex(dp), INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(ctmul)

    ctmul%r=REAL(sc,kind=DP)*s1
    ctmul%i=aimag(sc)*s1
    master=localmaster
  END FUNCTION ctmul

  FUNCTION cmult( sc,S1 )
    implicit none
    TYPE (complextaylor) cmult
    TYPE (taylor), INTENT (IN) :: S1
    complex(dp), INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(cmult)

    cmult%r=REAL(sc,kind=DP)*s1
    cmult%i=aimag(sc)*s1
    master=localmaster
  END FUNCTION cmult

  FUNCTION caddt( sc,S1 )
    implicit none
    TYPE (complextaylor) caddt
    TYPE (taylor), INTENT (IN) :: S1
    complex(dp), INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(caddt)

    caddt%r=REAL(sc,kind=DP)+s1
    caddt%i=aimag(sc)
    master=localmaster
  END FUNCTION caddt

  FUNCTION ctadd(S1, sc )
    implicit none
    TYPE (complextaylor) ctadd
    TYPE (taylor), INTENT (IN) :: S1
    complex(dp), INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(ctadd)

    ctadd%r=REAL(sc,kind=DP)+s1
    ctadd%i=aimag(sc)
    master=localmaster
  END FUNCTION ctadd

  FUNCTION csubt( sc,S1 )
    implicit none
    TYPE (complextaylor) csubt
    TYPE (taylor), INTENT (IN) :: S1
    complex(dp), INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(csubt)

    csubt%r=REAL(sc,kind=DP)-s1
    csubt%i=aimag(sc)
    master=localmaster
  END FUNCTION csubt

  FUNCTION ctsub( S1,sc )
    implicit none
    TYPE (complextaylor) ctsub
    TYPE (taylor), INTENT (IN) :: S1
    complex(dp), INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(ctsub)

    ctsub%r=s1-REAL(sc,kind=DP)
    ctsub%i=-aimag(sc)
    master=localmaster
  END FUNCTION ctsub

  FUNCTION cdivt( sc,S1 )
    implicit none
    TYPE (complextaylor) cdivt
    TYPE (taylor), INTENT (IN) :: S1
    complex(dp), INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(cdivt)

    cdivt%r=REAL(sc,kind=DP)/s1
    cdivt%i=aimag(sc)/s1
    master=localmaster
  END FUNCTION cdivt

  FUNCTION ctdiv( S1,sc )
    implicit none
    TYPE (complextaylor) ctdiv
    TYPE (taylor), INTENT (IN) :: S1
    complex(dp), INTENT (IN) :: sc
    complex(dp) w
    integer localmaster
    localmaster=master
    call ass(ctdiv)
    w=one/sc
    ctdiv%r=s1*REAL(w,kind=DP)
    ctdiv%i=s1*aimag(w)
    master=localmaster
  END FUNCTION ctdiv

  FUNCTION dscmul( sc,S1 )
    implicit none
    TYPE (complextaylor) dscmul
    TYPE (complextaylor), INTENT (IN) :: S1
    real(dp), INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(dscmul)

    dscmul%r=sc*s1%r
    dscmul%i=sc*s1%i
    master=localmaster

  END FUNCTION dscmul

  FUNCTION scmul( sc,S1 )
    implicit none
    TYPE (complextaylor) scmul
    TYPE (complextaylor), INTENT (IN) :: S1
    real(sp), INTENT (IN) :: sc
    integer localmaster
    if(real_warning) call real_stop
    localmaster=master
    call ass(scmul)

    scmul%r=sc*s1%r
    scmul%i=sc*s1%i
    master=localmaster

  END FUNCTION scmul

  FUNCTION iscmul( sc,S1 )
    implicit none
    TYPE (complextaylor) iscmul
    TYPE (complextaylor), INTENT (IN) :: S1
    integer, INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(iscmul)

    iscmul%r=sc*s1%r
    iscmul%i=sc*s1%i
    master=localmaster

  END FUNCTION iscmul


  FUNCTION cmulsc( S1,sc )
    implicit none
    TYPE (complextaylor) cmulsc
    TYPE (complextaylor), INTENT (IN) :: S1
    complex(dp), INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(cmulsc)

    cmulsc%r=REAL(sc,kind=DP)*s1%r-aimag(sc)*s1%i
    cmulsc%i=REAL(sc,kind=DP)*s1%i+aimag(sc)*s1%r
    master=localmaster
  END FUNCTION cmulsc



  FUNCTION dmulsc( S1, sc)
    implicit none
    TYPE (complextaylor) dmulsc
    TYPE (complextaylor), INTENT (IN) :: S1
    real(dp), INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(dmulsc)

    dmulsc%r=sc*s1%r
    dmulsc%i=sc*s1%i
    master=localmaster

  END FUNCTION dmulsc

  FUNCTION mulsc( S1, sc)
    implicit none
    TYPE (complextaylor) mulsc
    TYPE (complextaylor), INTENT (IN) :: S1
    real(sp), INTENT (IN) :: sc
    integer localmaster
    if(real_warning) call real_stop
    localmaster=master
    call ass(mulsc)

    mulsc%r=sc*s1%r
    mulsc%i=sc*s1%i
    master=localmaster

  END FUNCTION mulsc

  FUNCTION imulsc( S1, sc)
    implicit none
    TYPE (complextaylor) imulsc
    TYPE (complextaylor), INTENT (IN) :: S1
    integer, INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(imulsc)

    imulsc%r=sc*s1%r
    imulsc%i=sc*s1%i
    master=localmaster

  END FUNCTION imulsc

  SUBROUTINE  EQUAL(S2,S1)
    implicit none
    type (complextaylor),INTENT(inOUT)::S2
    type (complextaylor),INTENT(IN)::S1
    integer localmaster
    localmaster=master
    call check_snake
    master=0
    S2%R=S1%R
    S2%I=S1%I
    master=localmaster

  END SUBROUTINE EQUAL

  SUBROUTINE  ctEQUAL(S2,S1)
    implicit none
    type (complextaylor),INTENT(inOUT)::S2
    type (taylor),INTENT(IN)::S1
    integer localmaster
    localmaster=master
    call check_snake
    master=0
    S2%R=S1
    S2%I=zero
    master=localmaster

  END SUBROUTINE ctEQUAL

  SUBROUTINE  tcEQUAL(S1,S2)
    implicit none
    type (complextaylor),INTENT(in)::S2
    type (taylor),INTENT(inout)::S1
    integer localmaster
    localmaster=master
    call check_snake
    master=0
    S1=S2%R
    master=localmaster

  END SUBROUTINE tcEQUAL


  !  SUBROUTINE  DAABSEQUAL(R1,S2)
  !    implicit none
  !    type (complextaylor),INTENT(in)::S2
  !    real(dp), INTENT(inout)::R1
  !    real(dp) rr,ri
  !    integer localmaster
  !    localmaster=master
  !    call check_snake
  !
  !    master=0
  !
  !    rr=s2%r
  !    ri=s2%i
  !
  !    r1=rr+ri
  !
  !    master=localmaster
  !
  !  END SUBROUTINE DAABSEQUAL
  !
  !  SUBROUTINE  AABSEQUAL(R1,S2)
  !    implicit none
  !    type (complextaylor),INTENT(in)::S2
  !    REAL(SP), INTENT(inout)::R1
  !    REAL(SP) rr,ri
  !    integer localmaster
  !    if(real_warning) call real_stop
  !    localmaster=master
  !    call check_snake
  !
  !    master=0
  !
  !    rr=s2%r
  !    ri=s2%i
  !
  !    r1=rr+ri
  !
  !    master=localmaster
  !
  !  END SUBROUTINE AABSEQUAL


  SUBROUTINE  CEQUALDACON(S2,R1)
    implicit none
    type (complextaylor),INTENT(inout)::S2
    complex(dp), INTENT(IN)::R1
    integer localmaster
    localmaster=master
    call check_snake

    master=0

    S2%R=REAL(R1,kind=DP)
    S2%I=aimag(R1)
    master=localmaster

  END SUBROUTINE CEQUALDACON

  SUBROUTINE  dEQUALDACON(S2,R1)
    implicit none
    type (complextaylor),INTENT(inout)::S2
    real(dp) , INTENT(IN)::R1
    integer localmaster
    localmaster=master
    call check_snake

    master=0

    S2%R=R1
    S2%I=zero
    master=localmaster

  END SUBROUTINE dEQUALDACON

  SUBROUTINE  EQUALDACON(S2,R1)
    implicit none
    type (complextaylor),INTENT(inout)::S2
    real(sp) , INTENT(IN)::R1
    integer localmaster
    if(real_warning) call real_stop
    localmaster=master
    call check_snake

    master=0

    S2%R=REAL(R1,kind=DP)
    S2%I=zero
    master=localmaster

  END SUBROUTINE EQUALDACON

  SUBROUTINE  iEQUALDACON(S2,R1)
    implicit none
    type (complextaylor),INTENT(inout)::S2
    integer , INTENT(IN)::R1
    integer localmaster
    localmaster=master
    call check_snake

    master=0

    S2%R=REAL(R1,kind=DP)
    S2%I=zero
    master=localmaster

  END SUBROUTINE iEQUALDACON

  FUNCTION add( S1, S2 )
    implicit none
    TYPE (complextaylor) add
    TYPE (complextaylor), INTENT (IN) :: S1, S2
    integer localmaster
    localmaster=master
    call ass(add)
    add%r=s1%r+s2%r
    add%i=s1%i+s2%i
    master=localmaster
  END FUNCTION add

  FUNCTION tadd( S1, S2 )
    implicit none
    TYPE (complextaylor) tadd
    TYPE (complextaylor), INTENT (IN) ::  S2
    TYPE (taylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master
    call ass(tadd)
    tadd%r=s1+s2%r
    tadd%i=s2%i
    master=localmaster
  END FUNCTION tadd

  FUNCTION addt(  S2,S1 )
    implicit none
    TYPE (complextaylor) addt
    TYPE (complextaylor), INTENT (IN) ::  S2
    TYPE (taylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master
    call ass(addt)
    addt%r=s1+s2%r
    addt%i=s2%i
    master=localmaster
  END FUNCTION addt

  FUNCTION tsub( S1, S2 )
    implicit none
    TYPE (complextaylor) tsub
    TYPE (complextaylor), INTENT (IN) ::  S2
    TYPE (taylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master
    call ass(tsub)
    tsub%r=s1-s2%r
    tsub%i=-s2%i
    master=localmaster
  END FUNCTION tsub

  FUNCTION subt(  S2,S1 )
    implicit none
    TYPE (complextaylor) subt
    TYPE (complextaylor), INTENT (IN) ::  S2
    TYPE (taylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master
    call ass(subt)
    subt%r=s2%r-s1
    subt%i=s2%i
    master=localmaster
  END FUNCTION subt

  FUNCTION tmul( S1, S2 )
    implicit none
    TYPE (complextaylor) tmul
    TYPE (complextaylor), INTENT (IN) ::  S2
    TYPE (taylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master
    call ass(tmul)
    tmul%r=s1*s2%r
    tmul%i=s1*s2%i
    master=localmaster
  END FUNCTION tmul

  FUNCTION mult(  S2,S1 )
    implicit none
    TYPE (complextaylor) mult
    TYPE (complextaylor), INTENT (IN) ::  S2
    TYPE (taylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master
    call ass(mult)
    mult%r=s1*s2%r
    mult%i=s1*s2%i
    master=localmaster
  END FUNCTION mult

  FUNCTION tdiv( S1, S2 )
    implicit none
    TYPE (complextaylor) tdiv,temp
    TYPE (complextaylor), INTENT (IN) ::  S2
    TYPE (taylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master
    call ass(tdiv)
    call alloc(temp)
    temp=one/s2
    tdiv%r=s1*temp%r
    tdiv%i=s1*temp%i
    master=localmaster
    call kill(temp)
  END FUNCTION tdiv

  FUNCTION divt(S2 , S1 )
    implicit none
    TYPE (complextaylor) divt
    type (taylor) temp
    TYPE (complextaylor), INTENT (IN) ::  S2
    TYPE (taylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master
    call ass(divt)
    call alloc(temp)
    temp=one/s1
    divt%r=temp*s2%r
    divt%i=temp*s2%i
    master=localmaster
    call kill(temp)
  END FUNCTION divt

  FUNCTION csubSC( S1,sc )
    implicit none
    TYPE (complextaylor) csubSC
    TYPE (complextaylor), INTENT (IN) :: S1
    complex(dp), INTENT (IN) :: sc
    integer localmaster
    localmaster=master

    call ass(csubSC)

    csubSC%r=-REAL(sc,kind=DP)+s1%r
    csubSC%i=-aimag(sc)+s1%i
    master=localmaster
  END FUNCTION csubSC

  FUNCTION DsubSC(S1,sc)
    implicit none
    TYPE (complextaylor) DsubSC
    TYPE (complextaylor), INTENT (IN) :: S1
    real(dp) , INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(DsubSC)
    DsubSC%r=s1%r-sc
    DsubSC%i=s1%i
    master=localmaster
  END FUNCTION DsubSC

  FUNCTION subSC(S1,sc)
    implicit none
    TYPE (complextaylor) subSC
    TYPE (complextaylor), INTENT (IN) :: S1
    real(sp) , INTENT (IN) :: sc
    integer localmaster
    if(real_warning) call real_stop
    localmaster=master
    call ass(subSC)
    subSC%r=s1%r-sc
    subSC%i=s1%i
    master=localmaster
  END FUNCTION subSC

  FUNCTION isubSC(S1,sc)
    implicit none
    TYPE (complextaylor) isubSC
    TYPE (complextaylor), INTENT (IN) :: S1
    integer , INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(isubSC)
    isubSC%r=s1%r-sc
    isubSC%i=s1%i
    master=localmaster
  END FUNCTION isubSC

  FUNCTION cSCsub( sc,S1  )
    implicit none
    TYPE (complextaylor) cSCsub
    TYPE (complextaylor), INTENT (IN) :: S1
    complex(dp), INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(cSCsub)

    cSCsub%r=REAL(sc,kind=DP)-s1%r
    cSCsub%i=aimag(sc)-s1%i
    master=localmaster
  END FUNCTION cSCsub


  FUNCTION DSCsub( sc,S1 )
    implicit none
    TYPE (complextaylor) DSCsub
    TYPE (complextaylor), INTENT (IN) :: S1
    real(dp) , INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(DSCsub)
    DSCsub%r=sc-s1%r
    DSCsub%i=-s1%i
    master=localmaster
  END FUNCTION DSCsub

  FUNCTION SCsub( sc,S1 )
    implicit none
    TYPE (complextaylor) SCsub
    TYPE (complextaylor), INTENT (IN) :: S1
    real(sp) , INTENT (IN) :: sc
    integer localmaster
    if(real_warning) call real_stop
    localmaster=master
    call ass(SCsub)
    SCsub%r=sc-s1%r
    SCsub%i=-s1%i
    master=localmaster
  END FUNCTION SCsub

  FUNCTION iSCsub( sc,S1 )
    implicit none
    TYPE (complextaylor) iSCsub
    TYPE (complextaylor), INTENT (IN) :: S1
    integer , INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(iSCsub)
    iSCsub%r=sc-s1%r
    iSCsub%i=-s1%i
    master=localmaster
  END FUNCTION iSCsub

  FUNCTION unarysub( S1 )
    implicit none
    TYPE (complextaylor) unarysub
    TYPE (complextaylor), INTENT (IN) :: S1

    integer localmaster
    localmaster=master
    call ass(unarysub)
    unarysub%r=-s1%r
    unarysub%i=-s1%i
    master=localmaster
  END FUNCTION unarysub

  FUNCTION subs( S1, S2 )
    implicit none
    TYPE (complextaylor) subs
    TYPE (complextaylor), INTENT (IN) :: S1, S2
    integer localmaster
    localmaster=master
    call ass(subs)
    subs%r=s1%r-s2%r
    subs%i=s1%i-s2%i
    master=localmaster
  END FUNCTION subs

  FUNCTION cSCADD( sc,S1  )
    implicit none
    TYPE (complextaylor) cSCADD
    TYPE (complextaylor), INTENT (IN) :: S1
    complex(dp), INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(cSCADD)

    cSCADD%r=REAL(sc,kind=DP)+s1%r
    cSCADD%i=aimag(sc)+s1%i
    master=localmaster
  END FUNCTION cSCADD

  FUNCTION cADDSC(  S1,sc )
    implicit none
    TYPE (complextaylor) cADDSC
    TYPE (complextaylor), INTENT (IN) :: S1
    complex(dp), INTENT (IN) :: sc
    integer localmaster
    localmaster=master

    call ass(cADDSC)

    cADDSC%r=REAL(sc,kind=DP)+s1%r
    cADDSC%i=aimag(sc)+s1%i
    master=localmaster
  END FUNCTION cADDSC

  FUNCTION DADDSC( S1, sc )
    implicit none
    TYPE (complextaylor) DADDSC
    TYPE (complextaylor), INTENT (IN) :: S1
    real(dp) , INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(DADDSC)
    DADDSC%r=sc+s1%r
    DADDSC%i=s1%i
    master=localmaster
  END FUNCTION DADDSC

  FUNCTION ADDSC( S1, sc )
    implicit none
    TYPE (complextaylor) ADDSC
    TYPE (complextaylor), INTENT (IN) :: S1
    real(sp) , INTENT (IN) :: sc
    integer localmaster
    if(real_warning) call real_stop
    localmaster=master
    call ass(ADDSC)
    ADDSC%r=sc+s1%r
    ADDSC%i=s1%i
    master=localmaster
  END FUNCTION ADDSC

  FUNCTION iADDSC( S1, sc )
    implicit none
    TYPE (complextaylor) iADDSC
    TYPE (complextaylor), INTENT (IN) :: S1
    integer , INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(iADDSC)
    iADDSC%r=sc+s1%r
    iADDSC%i=s1%i
    master=localmaster
  END FUNCTION iADDSC

  FUNCTION DSCADD( sc,S1 )
    implicit none
    TYPE (complextaylor) DSCADD
    TYPE (complextaylor), INTENT (IN) :: S1
    real(dp) , INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(DSCADD)
    DSCADD%r=sc+s1%r
    DSCADD%i=s1%i
    master=localmaster
  END FUNCTION DSCADD

  FUNCTION SCADD( sc,S1 )
    implicit none
    TYPE (complextaylor) SCADD
    TYPE (complextaylor), INTENT (IN) :: S1
    real(sp) , INTENT (IN) :: sc
    integer localmaster
    if(real_warning) call real_stop
    localmaster=master
    call ass(SCADD)
    SCADD%r=sc+s1%r
    SCADD%i=s1%i
    master=localmaster
  END FUNCTION SCADD

  FUNCTION iSCADD( sc,S1 )
    implicit none
    TYPE (complextaylor) iSCADD
    TYPE (complextaylor), INTENT (IN) :: S1
    integer , INTENT (IN) :: sc
    integer localmaster
    localmaster=master
    call ass(iSCADD)
    iSCADD%r=sc+s1%r
    iSCADD%i=s1%i
    master=localmaster
  END FUNCTION iSCADD

  FUNCTION unaryADD( S1 )
    implicit none
    TYPE (complextaylor) unaryADD
    TYPE (complextaylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master
    call ass(unaryADD)
    unaryADD%r=s1%r
    unaryADD%i=s1%i
    master=localmaster
  END FUNCTION unaryADD

  subroutine inv( S1, s2 )
    implicit none
    TYPE (complextaylor), INTENT (IN) :: S1
    TYPE (complextaylor), INTENT (inout) :: S2
    TYPE (complextaylor)  s,ss
    complex(dp) d1
    real(dp) r1 ,i1
    integer i

    call alloc(s)
    call alloc(ss)


    r1=s1%r.sub.'0'
    i1=s1%i.sub.'0'
    s=s1
    d1=cmplx(r1,i1,kind=dp)
    d1=one/d1

    s=d1*s1

    s=s-one
    s=(-one)*s

    ss=cmplx(one,zero,kind=dp)
    s2=cmplx(one,zero,kind=dp)

    do i=1,no
       ss=ss*s
       s2=s2+ss
    enddo

    s2=d1*s2

    call kill(s)
    call kill(ss)
  END subroutine inv

  FUNCTION logtpsat( S1 )
    implicit none
    TYPE (complextaylor) logtpsat
    TYPE (complextaylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master

    call ass(logtpsat)

    call logtpsa(s1,logtpsat)
    master=localmaster
  END FUNCTION logtpsat

  subroutine logtpsa( S1, s2 )
    implicit none
    TYPE (complextaylor) S1
    TYPE (complextaylor)  S2
    TYPE (complextaylor)  s,ss
    complex(dp) d1
    real(dp) r1 ,i1
    integer i


    call alloc(s)
    call alloc(ss)


    r1=s1%r.sub.'0'
    i1=s1%i.sub.'0'

    d1=cmplx(r1,i1,kind=dp)
    s=(one/d1)*s1-one

    s2=s


    ss=s

    do i=2,no
       ss=cmplx(-one,zero,kind=dp)*ss*s
       s2=s2+ss/REAL(i,kind=DP)
    enddo

    s2=log(d1)+s2

    call kill(s)
    call kill(ss)
  END subroutine logtpsa

  FUNCTION abstpsat( S1 )
    implicit none
    real(dp) abstpsat ,r1,r2
    TYPE (complextaylor), INTENT (IN) :: S1

    r1=abs(s1%r) ! 2002.10.17
    r2=abs(s1%i)
    abstpsat=SQRT(r1**2+r2**2)
    !abstpsat=SQRT((s1%r.sub.'0')**2+(s1%i.sub.'0')**2)

  END FUNCTION abstpsat

  FUNCTION dcmplxt( S1,s2 )
    implicit none
    TYPE (complextaylor) dcmplxt
    TYPE (taylor), INTENT (IN) :: S1,s2
    integer localmaster
    localmaster=master

    call ass(dcmplxt)

    dcmplxt%r=s1
    dcmplxt%i=s2

    master=localmaster
  END FUNCTION dcmplxt

  FUNCTION datant( S1 )
    implicit none
    TYPE (complextaylor) datant,temp
    TYPE (complextaylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master

    call ass(datant)
    call alloc(temp)

    temp=(one+s1*i_)

    temp=temp/(one-s1*i_)

    temp=log(temp)
    datant=temp/two/i_

    call kill(temp)

    master=localmaster
  END FUNCTION datant

  FUNCTION dasint( S1 )
    implicit none
    TYPE (complextaylor) dasint,temp
    TYPE (complextaylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master

    call ass(dasint)
    call alloc(temp)

    temp=(one-s1**2)
    temp=temp**(half)

    temp=i_*s1+ temp
    dasint=-i_*log(temp)

    call kill(temp)

    master=localmaster
  END FUNCTION dasint


  FUNCTION dacost( S1 )
    implicit none
    TYPE (complextaylor) dacost,temp
    TYPE (complextaylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master

    call ass(dacost)
    call alloc(temp)

    temp=-one+s1**2
    temp=temp**(half)

    temp=(s1+ temp)
    dacost=-i_*log(temp)

    call kill(temp)

    master=localmaster
  END FUNCTION dacost




  FUNCTION tant( S1 )
    implicit none
    TYPE (complextaylor) tant, temp
    TYPE (complextaylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master


    call ass(tant)

    call alloc(temp)

    temp=exp(i_*s1)
    temp=temp-exp(-i_*s1)
    tant=exp(i_*s1)
    tant=tant+exp(-i_*s1)
    tant=temp/tant/i_

    call kill(temp)

    master=localmaster
  END FUNCTION tant

  FUNCTION dtanht( S1 )
    implicit none
    TYPE (complextaylor) dtanht, temp
    TYPE (complextaylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master


    call ass(dtanht)

    call alloc(temp)

    temp=exp(s1)
    temp=temp-exp(-s1)
    dtanht=exp(s1)
    dtanht=dtanht+exp(-s1)
    dtanht=temp/dtanht

    call kill(temp)

    master=localmaster
  END FUNCTION dtanht

  FUNCTION dcost( S1 )
    implicit none
    TYPE (complextaylor) dcost
    TYPE (complextaylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master


    call ass(dcost)

    dcost=exp(i_*s1)
    dcost=dcost+exp(-i_*s1)
    dcost=dcost/two

    master=localmaster
  END FUNCTION dcost

  FUNCTION dcosht( S1 )
    implicit none
    TYPE (complextaylor) dcosht
    TYPE (complextaylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master


    call ass(dcosht)

    dcosht=exp(s1)
    dcosht=dcosht+exp(-s1)
    dcosht=dcosht/two

    master=localmaster
  END FUNCTION dcosht


  FUNCTION dsint( S1 )
    implicit none
    TYPE (complextaylor) dsint
    TYPE (complextaylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master


    call ass(dsint)

    dsint=exp(i_*s1)
    dsint=dsint-exp(-i_*s1)
    dsint=dsint/two/i_

    master=localmaster
  END FUNCTION dsint

  FUNCTION dsinht( S1 )
    implicit none
    TYPE (complextaylor) dsinht
    TYPE (complextaylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master


    call ass(dsinht)

    dsinht=exp(s1)
    dsinht=dsinht-exp(-s1)
    dsinht=dsinht/two

    master=localmaster
  END FUNCTION dsinht


  FUNCTION exptpsat( S1 )
    implicit none
    TYPE (complextaylor) exptpsat
    TYPE (complextaylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master


    call ass(exptpsat)
    call exptpsa(s1,exptpsat)
    master=localmaster
  END FUNCTION exptpsat

  FUNCTION dsqrtt( S1 )
    implicit none
    TYPE (complextaylor) dsqrtt
    TYPE (complextaylor), INTENT (IN) :: S1
    integer localmaster
    localmaster=master


    call ass(dsqrtt)
    dsqrtt= S1**half

    master=localmaster
  END FUNCTION dsqrtt

  subroutine exptpsa( S1, s2 )
    implicit none
    TYPE (complextaylor), INTENT (IN) :: S1
    TYPE (complextaylor), INTENT (inout) :: S2
    TYPE (complextaylor)  s,ss
    complex(dp) d1
    real(dp) r1 ,i1
    integer i
    call alloc(s)
    call alloc(ss)


    r1=s1%r.sub.'0'
    i1=s1%i.sub.'0'

    d1=cmplx(r1,i1,kind=dp)
    s=s1

    s=s1-d1


    ss=cmplx(one,zero,kind=dp)
    s2=cmplx(one,zero,kind=dp)

    do i=1,no
       ss=ss*s
       ss=ss/REAL(i,kind=DP)
       s2=s2+ss
    enddo

    s2=exp(d1)*s2

    call kill(s)
    call kill(ss)

  END subroutine exptpsa

  subroutine assc(s1)
    implicit none
    TYPE (complextaylor) s1
    lastmaster=master

    select case(master)
    case(1:ndumt-1)
       master=master+1
    case(ndumt)
       w_p=0
       w_p%nc=1
       w_p=(/" cannot indent anymore "/)
       w_p%fc='(1((1X,A72),/))'
       CALL WRITE_E(100)
    end select

    call ass0(s1%r)
    call ass0(s1%i)


  end subroutine ASSc


  subroutine check_snake
    implicit none
    master=master+1
    select case (master)
    case(1:ndumt)
       if(oldscheme) then
          if(iass0user(master)>ndumuser(master)) then
             call ndum_warning_user
          endif
          iass0user(master)=0
       else
          if(iass0user(master)>scratchda(master)%n.or.scratchda(master)%n>newscheme_max) then
             w_p=0
             w_p%nc=1
             w_p%fc='(1((1X,A72),/))'
             w_p%fi='(3((1X,i4)))'
             w_p%c(1)= "iass0user(master),scratchda(master)%n,newscheme_max"
             w_p=(/iass0user(master),scratchda(master)%n,newscheme_max/)
             call write_e
             call ndum_warning_user
          endif
          iass0user(master)=0
       endif
    case(ndumt+1)
       w_p=0
       w_p%nc=1
       w_p=(/"Should not be here"/)
       w_p%fc='(1((1X,A72),/))'
       CALL WRITE_E(101)
    end select
    master=master-1
  end subroutine check_snake

  subroutine KILL_TPSA
    IMPLICIT NONE
    call KILL(varc1)
    call KILL(varc2)
    CALL KILL_BERZ_ETIENNE   ! IN TPSALIE_ANALISYS
  END subroutine KILL_TPSA

  subroutine init_map_c(NO1,ND1,NP1,NDPT1,log)
    implicit none
    integer NO1,ND1,NP1,NDPT1
    LOGICAL(lp) log
    if(.not.first_time) then
       call kill(varc1)
       call kill(varc2)
    endif

    call init_map(NO1,ND1,NP1,NDPT1,log)
    call set_in_complex(log)
    call alloc(varc1)
    call alloc(varc2)

  end subroutine  init_map_c

  subroutine init_tpsa_c(NO1,NP1,log)
    implicit none
    integer NO1,NP1
    LOGICAL(lp) log
    if(.not.first_time) then
       call kill(varc1)
       call kill(varc2)
    endif
    call init_tpsa(NO1,NP1,log)
    call set_in_complex(log)
    call alloc(varc1)
    call alloc(varc2)

  end subroutine  init_tpsa_c


  subroutine set_in_complex(log)
    implicit none
    logical(lp) log
    integer iia(4),icoast(4)
    call liepeek(iia,icoast)
    old=log
    NO=iia(1)
    ND=iia(3)
    ND2=iia(3)*2
    NP=iia(2)-nd2
    NDPT=icoast(4)
    NV=iia(2)
    i_ =cmplx(zero,one,kind=dp)
  end  subroutine set_in_complex

  SUBROUTINE  VARcC(S1,R1,R2,I1,I2)
    implicit none
    INTEGER,INTENT(IN)::I1,I2
    complex(dp),INTENT(IN)::R1
    real(dp),INTENT(IN)::R2
    type (complextaylor),INTENT(INOUT)::S1

    call var001(s1%r,REAL(R1,kind=DP),R2,i1)
    call var001(s1%i,aimag(R1),R2,i2)

  END SUBROUTINE VARcC

  SUBROUTINE  VARc(S1,R1,I1,I2)
    implicit none
    INTEGER,INTENT(IN)::I1,I2
    complex(dp),INTENT(IN)::R1
    type (complextaylor),INTENT(INOUT)::S1

    call var000(s1%r,REAL(R1,kind=DP),i1)
    call var000(s1%i,aimag(R1),i2)

  END SUBROUTINE VARc


  SUBROUTINE  shiftc(S1,S2,s)
    implicit none
    INTEGER,INTENT(IN)::s
    type (complextaylor),INTENT(IN)::S1
    type (complextaylor),INTENT(inout)::S2

    call shift000(S1%r,S2%r,s)
    call shift000(S1%i,S2%i,s)

  END SUBROUTINE shiftc


  SUBROUTINE  pekc(S1,J,R1)
    implicit none
    INTEGER,INTENT(IN),dimension(:)::j
    complex(dp),INTENT(inout)::R1
    type (complextaylor),INTENT(IN)::S1
    real(dp) xr,xi

    call pek000(s1%r,j,xr)
    call pek000(s1%i,j,xi)

    r1=cmplx(xr,xi,kind=dp)

  END SUBROUTINE pekc


  SUBROUTINE  pokc(S1,J,R1)
    implicit none
    INTEGER,INTENT(in),dimension(:)::j
    complex(dp),INTENT(in)::R1
    type (complextaylor),INTENT(inout)::S1

    call pok000(s1%r,J,REAL(r1,kind=DP))
    call pok000(s1%i,J,aimag(r1))
  END SUBROUTINE pokc

  SUBROUTINE  CFUC(S2,FUN,S1)!
    implicit none
    type (complextaylor),INTENT(INOUT)::S1
    type (complextaylor),INTENT(IN)::S2
    type (complextaylor) T
    type (taylor) W
    complex(dp) FUN
    EXTERNAL FUN
    CALL ALLOC(T)
    CALL ALLOC(W)

    CALL CFUR(S2%R,FUN,W)
    T%R=W
    CALL CFUI(S2%I,FUN,W)
    T%R=T%R-W
    CALL CFUR(S2%I,FUN,W)
    T%I=W
    CALL CFUI(S2%R,FUN,W)
    T%I=T%I+W
    S1=T
    CALL KILL(T)
    CALL KILL(W)

  END SUBROUTINE CFUC

  SUBROUTINE  CFURES(S2,FUN,S1)!
    implicit none
    type (pbresonance),INTENT(INOUT)::S1
    type (pbresonance),INTENT(IN)::S2
    type (complextaylor) T
    type (taylor) W
    complex(dp) FUN
    EXTERNAL FUN
    CALL ALLOC(T)
    CALL ALLOC(W)

    CALL CFUR(S2%COS%H,FUN,W)
    T%R=W
    CALL CFUI(S2%SIN%H,FUN,W)
    T%R=T%R-W
    CALL CFUR(S2%SIN%H,FUN,W)
    T%I=W
    CALL CFUI(S2%COS%H,FUN,W)
    T%I=T%I+W
    S1%COS%H=T%R
    S1%SIN%H=T%I
    CALL KILL(T)
    CALL KILL(W)

  END SUBROUTINE CFURES


end module  complex_taylor
