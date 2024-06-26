!SFX_LIC Copyright 1994-2014 CNRS, Meteo-France and Universite Paul Sabatier
!SFX_LIC This is part of the SURFEX software governed by the CeCILL-C licence
!SFX_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!SFX_LIC for details. version 1.
!     ###########################################################
      SUBROUTINE PGD_SURF_ATM (YSC,HPROGRAM,HFILE,HFILETYPE,OZS)
!     ###########################################################
!!
!!    PURPOSE
!!    -------
!!   This program prepares the physiographic data fields.
!!
!!    METHOD
!!    ------
!!   
!!    EXTERNAL
!!    --------
!!
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!
!!
!!    REFERENCE
!!    ---------
!!
!!    AUTHOR
!!    ------
!!
!!    V. Masson                   Meteo-France
!!
!!    MODIFICATION
!!    ------------
!!
!!    Original     13/10/03
!!      A. Lemonsu      05/2009         Ajout de la clef LGARDEN pour TEB
!!      J. Escobar      11/2013         Add USE MODI_READ_NAM_PGD_CHEMISTRY
!!      B. Decharme     02/2014         Add LRM_RIVER
!!      M. Leriche      06/2017         Add MEGAN coupling
!----------------------------------------------------------------------------
!
!*    0.     DECLARATION
!            -----------
!
USE MODD_CSTS, ONLY : XSURF_EPSILON
USE MODD_DATA_COVER_PAR, ONLY : JPCOVER
USE MODD_SURFEX_n, ONLY : SURFEX_t
USE MODD_SURFEX_MPI, ONLY : NRANK, NPIO, NSIZE, NINDEX, NNUM
USE MODD_SURF_CONF, ONLY : CPROGNAME
USE MODD_PGD_GRID, ONLY : NL, LLATLONMASK, NGRID_PAR
!
USE MODI_GET_SIZE_FULL_n
USE MODI_GET_LUOUT
USE MODI_READ_PGD_ARRANGE_COVER
USE MODI_READ_PGD_COVER_GARDEN
USE MODI_INI_DATA_COVER
USE MODI_READ_PGD_SCHEMES
USE MODI_READ_NAM_PGD_CHEMISTRY
USE MODI_READ_NAM_WRITE_COVER_TEX
USE MODI_WRITE_COVER_TEX_START
USE MODI_WRITE_COVER_TEX_COVER
USE MODI_LATLON_GRID
USE MODI_PUT_PGD_GRID
USE MODI_LATLONMASK
USE MODI_PGD_FRAC
USE MODI_PGD_COVER
USE MODI_PGD_OROGRAPHY
USE MODI_PGD_NATURE
USE MODI_PGD_TOWN
USE MODI_PGD_INLAND_WATER
USE MODI_PGD_SEA
USE MODI_PGD_DUMMY
USE MODI_PGD_CHEMISTRY
USE MODI_PGD_CHEMISTRY_SNAP
USE MODI_SUM_ON_ALL_PROCS
USE MODI_WRITE_COVER_TEX_END
USE MODI_INIT_READ_DATA_COVER
USE MODI_PGD_MEGAN
!
USE YOMHOOK   ,ONLY : LHOOK,   DR_HOOK
USE PARKIND1  ,ONLY : JPRB
!
IMPLICIT NONE
!
!*    0.1    Declaration of dummy arguments
!            ------------------------------
!
!
TYPE(SURFEX_t), INTENT(INOUT) :: YSC
!
CHARACTER(LEN=6),     INTENT(IN)  :: HPROGRAM ! program calling
CHARACTER(LEN=28),    INTENT(IN)  :: HFILE    ! atmospheric file name
CHARACTER(LEN=6),     INTENT(IN)  :: HFILETYPE! atmospheric file type
LOGICAL,              INTENT(IN)  :: OZS      ! .true. if orography is imposed by atm. model
!
!*    0.2    Declaration of local variables
!            ------------------------------
!
LOGICAL :: LRM_RIVER   !delete inland river coverage. Default is false
!
INTEGER, DIMENSION(:), ALLOCATABLE :: IMATCHCOVER
INTEGER :: ICOUNT, JCOVER
INTEGER :: JI, JJ, IDIM_FULL
INTEGER :: ILUOUT ! logical unit of output listing file
!
REAL :: ZSUM
!
REAL(KIND=JPRB) :: ZHOOK_HANDLE
!
!------------------------------------------------------------------------------
IF (LHOOK) CALL DR_HOOK('PGD_SURF_ATM',0,ZHOOK_HANDLE)
!
LRM_RIVER = .FALSE.
!
CPROGNAME=HPROGRAM
!
 CALL GET_LUOUT(HPROGRAM,ILUOUT)
!
!*    1.      Set default constant values 
!             ---------------------------
!
!*    1.2     surface schemes
 CALL READ_PGD_SCHEMES(HPROGRAM, YSC%U%CNATURE, YSC%U%CSEA, YSC%U%CTOWN, YSC%U%CWATER)
!
 CALL READ_NAM_WRITE_COVER_TEX(HPROGRAM)
!
!-------------------------------------------------------------------------------
!
!*    2.      Grid
!             ----
!
ALLOCATE(YSC%UG%G%XLAT      (YSC%U%NSIZE_FULL))
ALLOCATE(YSC%UG%G%XLON      (YSC%U%NSIZE_FULL))
ALLOCATE(YSC%UG%G%XMESH_SIZE(YSC%U%NSIZE_FULL))
ALLOCATE(YSC%UG%XJPDIR      (YSC%U%NSIZE_FULL))
 CALL LATLON_GRID(YSC%UG%G, YSC%U%NSIZE_FULL, YSC%UG%XJPDIR)
!
!
!*    2.3     Stores the grid in the module MODD_PGD_GRID
!
 CALL PUT_PGD_GRID(YSC%UG%G%CGRID, YSC%U%NSIZE_FULL,YSC%UG%G%NGRID_PAR, YSC%UG%G%XGRID_PAR)
!
IF (HPROGRAM=='MESONH') THEN
  IDIM_FULL = YSC%U%NDIM_FULL
  YSC%U%NDIM_FULL = NL
  NSIZE = NL
  ALLOCATE(NINDEX(NL))
  NINDEX(:) = 0
  ALLOCATE(NNUM(NL))
  DO JI = 1,NL
    NNUM(JI) = JI
  ENDDO
ENDIF
!
IF (.NOT.ASSOCIATED(YSC%UG%XGRID_FULL_PAR)) THEN
  ALLOCATE(YSC%UG%XGRID_FULL_PAR(SIZE(YSC%UG%G%XGRID_PAR)))
  YSC%UG%XGRID_FULL_PAR(:) = YSC%UG%G%XGRID_PAR(:)
  YSC%UG%NGRID_FULL_PAR = NGRID_PAR
ENDIF
!
!*    2.4     mask to limit the number of input data to read
 CALL LATLONMASK(YSC%UG%G%CGRID, YSC%UG%NGRID_FULL_PAR, YSC%UG%XGRID_FULL_PAR, LLATLONMASK)
!
!-------------------------------------------------------------------------------
!
!*    3.      surface cover
!             -------------
!
 CALL PGD_FRAC(YSC%DTCO, YSC%UG, YSC%U, YSC%USS, HPROGRAM)
!
 CALL READ_PGD_ARRANGE_COVER(HPROGRAM, YSC%U%LWATER_TO_NATURE, YSC%U%LTOWN_TO_ROCK, &
    YSC%U%LTOWN_TO_COVER, YSC%U%NREPLACE_COVER )
!
 CALL READ_PGD_COVER_GARDEN(HPROGRAM, YSC%U%LGARDEN)
!
 CALL INIT_READ_DATA_COVER(HPROGRAM)
!
CALL INI_DATA_COVER(YSC%DTCO, YSC%U)
!
IF (YSC%U%LECOCLIMAP) THEN
    !
    CALL PGD_COVER(YSC%DTCO, YSC%UG, YSC%U, YSC%USS, HPROGRAM,LRM_RIVER)
    !
    ! Impose selected replacement COVER on urban mask 
    !
    IF (YSC%U%LTOWN_TO_COVER) THEN
       !
       ALLOCATE(IMATCHCOVER(JPCOVER))
       !
       ! Check whether not both TOWN_TO_ROCK and TOWN_TO_COVER selected
       !
       IF (YSC%U%LTOWN_TO_ROCK) THEN
          CALL ABOR1_SFX("PGD_SURF_ATM: cannot convert TOWN to rock AND other COVER")
       ENDIF
       !
       ! Check whether replace COVER is inside ECOCLIMAP cover range
       !
       IF ((YSC%U%NREPLACE_COVER.LT.1).OR.(YSC%U%NREPLACE_COVER.GT.JPCOVER)) THEN
          CALL ABOR1_SFX("PGD_SURF_ATM: REPLACE COVER does not belong to ECOCLIMAP COVERS")
       ENDIF
       !
       ! Construct an index matching ECOCLIMAP COVER indices with actual indices
       !
       IMATCHCOVER(:)=-9999
       ICOUNT=1
       !
       DO JCOVER=1,JPCOVER
          IF(YSC%U%LCOVER(JCOVER)) THEN
             IMATCHCOVER(JCOVER)=ICOUNT
             ICOUNT=ICOUNT+1
          ENDIF
       ENDDO
       !
       ! Test whether replace cover exists
       !
       IF (IMATCHCOVER(YSC%U%NREPLACE_COVER).LT.0) THEN
          CALL ABOR1_SFX("PGD_SURF_ATM: Selected replacement cover not in domain")
       ENDIF
       !
       DO JJ=1,SIZE(YSC%U%XTOWN)
          !
          ! Test sum of COVERS
          !
          IF (ABS(1.0-SUM(YSC%U%XCOVER(JJ,:))).GT.XSURF_EPSILON) THEN
             CALL ABOR1_SFX("PGD_SURF_ATM:Wrong sum of COVERS, before manipulations")
          ENDIF
          !
          IF (YSC%U%XTOWN(JJ)>0) THEN
             !
             ! Set urban COVERS to zero (CAUTION: this is hardcoded to ECOCLIMAP COVER numbers
             !
             IF (IMATCHCOVER(007).GT.0) YSC%U%XCOVER(JJ,IMATCHCOVER(007))=0.0
             !
             DO JCOVER=151,161
                IF (IMATCHCOVER(JCOVER).GT.0) YSC%U%XCOVER(JJ,IMATCHCOVER(JCOVER))=0.0
             ENDDO
             !
             DO JCOVER=561,571
                IF (IMATCHCOVER(JCOVER).GT.0) YSC%U%XCOVER(JJ,IMATCHCOVER(JCOVER))=0.0
             ENDDO
             !
             ! Normalise sum of COVERS to 1.0-XTOWN
             !
             ZSUM=SUM(YSC%U%XCOVER(JJ,:))
             IF (ZSUM.GT.XSURF_EPSILON) THEN
                YSC%U%XCOVER(JJ,:)=(1.0-YSC%U%XTOWN(JJ))*YSC%U%XCOVER(JJ,:)/ZSUM
             ELSE
                YSC%U%XCOVER(JJ,:)=0.0
             ENDIF
             !
             ! Increase cover of selected replace type to obtain a sum of 1.0 for all COVERS
             !
             ZSUM=SUM(YSC%U%XCOVER(JJ,:))
             YSC%U%XCOVER(JJ,IMATCHCOVER(YSC%U%NREPLACE_COVER)) = &
                  YSC%U%XCOVER(JJ,IMATCHCOVER(YSC%U%NREPLACE_COVER)) + 1.0 - ZSUM
             !
             ! Shift TOWN to NATURE
             !
             YSC%U%XNATURE(JJ)=YSC%U%XNATURE(JJ)+YSC%U%XTOWN(JJ)
             YSC%U%XTOWN  (JJ)=0.0
             !
             ! Check whether sum of fractions and sum of covers = 1
             !
             IF (ABS(1.0-YSC%U%XNATURE(JJ)-YSC%U%XTOWN(JJ)-YSC%U%XSEA(JJ)-YSC%U%XWATER(JJ)).GT.XSURF_EPSILON ) THEN
                CALL ABOR1_SFX("PGD_SURF_ATM: Wrong sum of SURFEX tile fractions")
             ENDIF
             !
             IF (ABS(1.0-SUM(YSC%U%XCOVER(JJ,:))).GT.XSURF_EPSILON ) THEN
                !
                WRITE(ILUOUT,*) "JJ                      : ",JJ
                WRITE(ILUOUT,*) "YSC%U%XCOVER(JJ,:)      : ",YSC%U%XCOVER(JJ,:)           
                WRITE(ILUOUT,*) "YSC%U%XNATURE(JJ)       : ",YSC%U%XNATURE(JJ)
                WRITE(ILUOUT,*) "YSC%U%XTOWN(JJ)         : ",YSC%U%XTOWN(JJ)
                WRITE(ILUOUT,*) "YSC%U%XSEA(JJ)          : ",YSC%U%XSEA(JJ)
                WRITE(ILUOUT,*) "YSC%U%XWATER(JJ)        : ",YSC%U%XWATER(JJ)
                WRITE(ILUOUT,*) "SUM(YSC%U%XCOVER(JJ,:)) : ",SUM(YSC%U%XCOVER(JJ,:))
                !
                CALL ABOR1_SFX("PGD_SURF_ATM: Wrong sum of COVERS")
                !
             ENDIF
             !
          ENDIF
       ENDDO
       !
       ! Recalculate dimensions
       !
       YSC%U%NSIZE_NATURE = COUNT(YSC%U%XNATURE(:) > 0.0)
       YSC%U%NSIZE_TOWN   = COUNT(YSC%U%XTOWN  (:) > 0.0)
       !
       YSC%U%NDIM_NATURE  = SUM_ON_ALL_PROCS(HPROGRAM,YSC%UG%G%CGRID,YSC%U%XNATURE(:) > 0., 'DIM')
       YSC%U%NDIM_TOWN    = SUM_ON_ALL_PROCS(HPROGRAM,YSC%UG%G%CGRID,YSC%U%XTOWN  (:) > 0., 'DIM')
       !
  ENDIF
  !
ENDIF
!
IF (NRANK==NPIO) THEN
  CALL WRITE_COVER_TEX_START(HPROGRAM)
  CALL WRITE_COVER_TEX_COVER
ENDIF
!
!-------------------------------------------------------------------------------
!
!*    4.      Orography
!             ---------
!
 CALL PGD_OROGRAPHY(YSC%DTCO, YSC%UG, YSC%U, YSC%USS, HPROGRAM, HFILE, HFILETYPE, OZS)
!
!_______________________________________________________________________________
!
!*    5.      Additionnal fields for nature scheme
!             ------------------------------------
!
IF (YSC%U%NDIM_NATURE>0) CALL PGD_NATURE(YSC%DTCO, YSC%DTZ, YSC%IM, YSC%UG, YSC%U, YSC%USS, HPROGRAM)  
!_______________________________________________________________________________
!
!*    6.      Additionnal fields for town scheme
!             ----------------------------------
!
IF (YSC%U%NDIM_TOWN>0) CALL PGD_TOWN(YSC%DTCO, YSC%UG, YSC%U, YSC%USS, &
                                     YSC%IM%DTV, YSC%TM, YSC%GDM, YSC%GRM, YSC%HM, HPROGRAM)  
!_______________________________________________________________________________
!
!*    7.      Additionnal fields for inland water scheme
!             ------------------------------------------
!
IF (YSC%U%NDIM_WATER>0) CALL PGD_INLAND_WATER(YSC%DTCO, YSC%FM%G, YSC%FM%F, YSC%UG, YSC%U, &
                                              YSC%USS, YSC%WM%G, YSC%WM%W, HPROGRAM,LRM_RIVER)   
!_______________________________________________________________________________
!
!*    8.      Additionnal fields for sea scheme
!             ---------------------------------
!
IF (YSC%U%NDIM_SEA>0) CALL PGD_SEA(YSC%DTCO, YSC%SM%DTS, YSC%SM%G, YSC%SM%S, &
                                   YSC%UG, YSC%U, YSC%USS, HPROGRAM)  
!_______________________________________________________________________________
!
!*    9.      Dummy fields
!             ------------
!
 CALL PGD_DUMMY(YSC%DTCO, YSC%DUU, YSC%UG, YSC%U, YSC%USS, HPROGRAM)
!_______________________________________________________________________________
!
!*   10.      Chemical Emission fields
!             ------------------------
!
 CALL READ_NAM_PGD_CHEMISTRY(HPROGRAM,YSC%CHU%CCH_EMIS,YSC%CHU%CCH_BIOEMIS)
IF (YSC%CHU%CCH_EMIS=='SNAP') THEN
  CALL PGD_CHEMISTRY_SNAP(YSC%CHN, YSC%DTCO, YSC%UG, YSC%U, YSC%USS, &
                          HPROGRAM,YSC%CHU%LCH_EMIS)
ELSE IF (YSC%CHU%CCH_EMIS=='AGGR') THEN
  CALL PGD_CHEMISTRY(YSC%CHE, YSC%DTCO, YSC%UG, YSC%U, YSC%USS, &
                     HPROGRAM,YSC%CHU%LCH_EMIS)
ENDIF
IF (YSC%CHU%CCH_BIOEMIS=='MEGA') THEN
  CALL PGD_MEGAN(YSC%DTCO, YSC%UG, YSC%U, YSC%USS, YSC%IM%MSF, &
                 HPROGRAM,YSC%CHU%LCH_BIOEMIS)
ENDIF
!_______________________________________________________________________________
!
!*   11.     Writing in cover latex file
!            ---------------------------
!
IF (NRANK==NPIO) CALL WRITE_COVER_TEX_END(HPROGRAM)
!
IF (HPROGRAM=='MESONH') THEN
 YSC%U%NDIM_FULL = IDIM_FULL
ENDIF
!
IF (LHOOK) CALL DR_HOOK('PGD_SURF_ATM',1,ZHOOK_HANDLE)
!_______________________________________________________________________________
!
END SUBROUTINE PGD_SURF_ATM
