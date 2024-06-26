!SFX_LIC Copyright 1994-2014 CNRS, Meteo-France and Universite Paul Sabatier
!SFX_LIC This is part of the SURFEX software governed by the CeCILL-C licence
!SFX_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!SFX_LIC for details. version 1.
!     #########
SUBROUTINE PREP_ISBA (DTCO, UG, U, USS, GCP, SB, IG, IO, S, NK, NP, NPE, NPAR_VEG_IRR_USE, &
                      HPROGRAM,HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
!     #################################################################################
!
!!****  *PREP_ISBA* - Prepares ISBA fields
!!
!!    PURPOSE
!!    -------
!
!!**  METHOD
!!    ------
!!
!!    REFERENCE
!!    ---------
!!      
!!
!!    AUTHOR
!!    ------
!!     V. Masson 
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    01/2004
!!      Modified by P. Le Moigne (11/2004): AGS fields
!!      Modified by B. Decharme   (2008)  : Floodplains
!!      Modified by B. Decharme  (01/2009): Consistency with Arpege deep soil
!!                                          temperature
!!      Modified by B. Decharme  (03/2009): Consistency with Arpege permanent
!!                                          snow/ice treatment
!!      A.L. Gibelin 04/2009 : BIOMASS and RESP_BIOMASS arrays 
!!      A.L. Gibelin 06/2009 : Soil carbon variables for CNT option
!!      Modified by S. Riette    (06/2009): PREP_ISBA_CANOPY has no more arg.
!!      Modified by S. Riette    (04/2010): ecmwf ice content is computed during
!!                                          grib reading (no longer here)
!!      B. Decharme  (10/2012): coherence between soil temp and liquid/solid water with DIF
!!                              bug in biomass prognostic fields calculation
!!      B. Decharme  (06/2013): XPSNV_A for EBA snow scheme not allocated
!!      M. Lafaysse (04/2014) : LSNOW_PREP_PERM
!!      B. Decharme  (04/2013): Good computation for coherence between soil temp and 
!!                              liquid/solid water with DIF (results don't change)
!!                              if lglacier in input file, do not initialize again
!!      P. Samuelsson            (10/2014): MEB
!!      P. Marguinaud10/2014, Support for a 2-part PREP
!!      A. Druel     02/2019, Adapt the code to be compatible with irrigation and transmit NPAR_VEG_IRR_USE
!!      B. Decharme    02/17 : exact computation of saturation deficit near the leaf surface
!!      R. Séférian    01/18 : Modify spin-up procedure for carbon cycle
!!      B. Decharme 04/2020 : New soil carbon scheme (Morel et al. 2019 JAMES) under CRESPSL = DIF option
!!      B. Decharme 04/2020 : Soil gas scheme (Morel et al. 2019 JAMES) under LSOILGAS = T
!!
!!------------------------------------------------------------------
!
USE MODD_DATA_COVER_n,     ONLY : DATA_COVER_t
USE MODD_SURF_ATM_GRID_n,  ONLY : SURF_ATM_GRID_t
USE MODD_SURF_ATM_n,       ONLY : SURF_ATM_t
USE MODD_SSO_n,            ONLY : SSO_t
USE MODD_GRID_CONF_PROJ_n, ONLY : GRID_CONF_PROJ_t
!
USE MODD_CANOPY_n,         ONLY : CANOPY_t
USE MODD_SFX_GRID_n,       ONLY : GRID_t
USE MODD_ISBA_OPTIONS_n,   ONLY : ISBA_OPTIONS_t
USE MODD_ISBA_n,           ONLY : ISBA_S_t, ISBA_NK_t, ISBA_K_t, ISBA_NP_t, ISBA_P_t, &
                                  ISBA_NPE_t, ISBA_PE_t
!
USE MODN_PREP_ISBA
USE MODN_PREP_ISBA_SNOW,   ONLY : LSWEMAX, XSWEMAX 
!
USE MODD_DATA_COVER_PAR,   ONLY : NVEGTYPE, NVT_SNOW
USE MODD_SNOW_PAR,         ONLY : XEMISSN
USE MODD_ISBA_PAR,         ONLY : XWGMIN
USE MODD_CO2V_PAR,         ONLY : XANFMINIT
USE MODD_SURF_PAR,         ONLY : XUNDEF
USE MODD_AGRI,             ONLY : NVEG_IRR
!
USE MODD_READ_NAMELIST,    ONLY : LNAM_READ
USE MODD_SURF_ATM,         ONLY : LVERTSHIFT
!          
USE MODD_DEEPSOIL,         ONLY : LPHYSDOMC
USE MODD_CSTS,             ONLY : XTT, XG, XRD, XLMTT, XP00
USE MODD_PREP,             ONLY : XZS_LS

USE MODD_PREP_SNOW,        ONLY : LSNOW_PREP_PERM
!
USE MODE_PREP_CTL,         ONLY : PREP_CTL
!
USE MODI_PREP_HOR_ISBA_FIELD
USE MODI_PREP_VER_ISBA
USE MODI_PREP_OUTPUT_GRID
USE MODI_GET_LUOUT
USE MODI_PREP_SBL
USE MODI_VEGTYPE_TO_PATCH_IRRIG
!
USE MODI_PREP_PERM_SNOW
USE MODI_INIT_SNOW_LW
USE MODI_AVERAGED_ALBEDO_EMIS_ISBA
USE MODI_PREP_HOR_ISBA_CC_FIELD
USE MODI_PREP_HOR_ISBA_ESC_FIELD
USE MODI_SOIL_ALBEDO
USE MODE_THERMOS
!
USE MODI_CLEAN_PREP_OUTPUT_GRID
USE MODI_PACK_SAME_RANK
!
USE YOMHOOK   ,ONLY : LHOOK,   DR_HOOK
USE PARKIND1  ,ONLY : JPRB
!
IMPLICIT NONE
!
!*      0.1    declarations of arguments
!
!
TYPE(DATA_COVER_t),    INTENT(INOUT) :: DTCO
TYPE(SURF_ATM_GRID_t), INTENT(INOUT) :: UG
TYPE(SURF_ATM_t),      INTENT(INOUT) :: U
TYPE(SSO_t),           INTENT(INOUT) :: USS
TYPE(GRID_CONF_PROJ_t),INTENT(INOUT) :: GCP
!
TYPE(CANOPY_t),        INTENT(INOUT) :: SB
TYPE(GRID_t),          INTENT(INOUT) :: IG
TYPE(ISBA_OPTIONS_t),  INTENT(INOUT) :: IO
TYPE(ISBA_S_t),        INTENT(INOUT) :: S
TYPE(ISBA_NK_t),       INTENT(INOUT) :: NK
TYPE(ISBA_NP_t),       INTENT(INOUT) :: NP
TYPE(ISBA_NPE_t),      INTENT(INOUT) :: NPE
!
TYPE (PREP_CTL),       INTENT(INOUT) :: YDCTL
!
INTEGER,DIMENSION(:), INTENT(IN) :: NPAR_VEG_IRR_USE ! vegtype with irrigation
CHARACTER(LEN=6),   INTENT(IN)  :: HPROGRAM  ! program calling surf. schemes
CHARACTER(LEN=28),  INTENT(IN)  :: HATMFILE    ! name of the Atmospheric file
CHARACTER(LEN=6),   INTENT(IN)  :: HATMFILETYPE! type of the Atmospheric file
CHARACTER(LEN=28),  INTENT(IN)  :: HPGDFILE    ! name of the Atmospheric file
CHARACTER(LEN=6),   INTENT(IN)  :: HPGDFILETYPE! type of the Atmospheric file
!
!*      0.2    declarations of local variables
!
TYPE(ISBA_K_t), POINTER  :: KK
TYPE(ISBA_P_t), POINTER  :: PK
TYPE(ISBA_PE_t), POINTER :: PEK
!
LOGICAL, DIMENSION(IO%NPATCH)    :: L_IS_SNOW
!
REAL,    DIMENSION(1)                        :: ZSW_BANDS ! middle wavelength of each band
REAL,    DIMENSION(U%NSIZE_NATURE,IO%NPATCH) :: ZDIR_ALB  ! Unpacked direct albedo for each band
REAL,    DIMENSION(U%NSIZE_NATURE,IO%NPATCH) :: ZSCA_ALB  ! Unpacked diffuse albedo for each band
REAL,    DIMENSION(U%NSIZE_NATURE,IO%NPATCH) :: ZTG1      ! Unpacked surface temperature
!
LOGICAL, DIMENSION(U%NSIZE_NATURE,IO%NPATCH) :: GWGI_ADJUST ! Adjust soil ice profile only if permanent snow is initialized
!
REAL,    DIMENSION(U%NSIZE_NATURE)   :: ZEMIS     ! Unpacked emissivity
REAL,    DIMENSION(U%NSIZE_NATURE)   :: ZZENITH   ! Unpacked solar zenithal angle
REAL,    DIMENSION(U%NSIZE_NATURE)   :: ZTSURF    ! Unpacked surface effective temperature
!
REAL,    DIMENSION(:), ALLOCATABLE   :: ZZS
!
LOGICAL         :: GPERMSNOW 
LOGICAL         :: GTEMP2WGI
LOGICAL         :: GWG
LOGICAL         :: GWGI
LOGICAL         :: GTG
!
REAL    :: ZWORK, ZLOG, ZWTOT, ZMATPOT, ZWL, ZSM
!
INTEGER :: ILUOUT, INI, ISIZE_LMEB_PATCH, ISNOW, IVEGTYP
INTEGER :: JP, JL, JJ, JVEGTYP
!
REAL(KIND=JPRB) :: ZHOOK_HANDLE
!
!-------------------------------------------------------------------------------------
!
IF (LHOOK) CALL DR_HOOK('PREP_ISBA',0,ZHOOK_HANDLE)
!
!*      1.     Default of configuration
!
INI=U%NSIZE_NATURE
!
GPERMSNOW = .TRUE.
GWG       = .TRUE.
GWGI      = .TRUE.
GTG       = .TRUE.
!
GWGI_ADJUST(:,:) = .FALSE.
!
ISIZE_LMEB_PATCH=COUNT(IO%LMEB_PATCH(:))
!
!*      1.1    Default
!
CALL GET_LUOUT(HPROGRAM,ILUOUT)
!
CALL PREP_OUTPUT_GRID(UG%G, IG, U%NSIZE_FULL, ILUOUT)
!
!-------------------------------------------------------------------------------------
!
!*      2.     Reading and horizontal interpolations
!
!
!*      2.0    Large scale orography
!
CALL PREP_HOR_ISBA_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, S%TTIME, NPAR_VEG_IRR_USE, &
                         HPROGRAM,'ZS     ',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
!
!*      2.1    Soil Water reservoirs
!
CALL PREP_HOR_ISBA_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, S%TTIME, NPAR_VEG_IRR_USE, &
                         HPROGRAM,'WG     ',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL,GWG)
!
!*      2.2    Soil ice reservoirs
!
CALL PREP_HOR_ISBA_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, S%TTIME, NPAR_VEG_IRR_USE, &
                         HPROGRAM,'WGI    ',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL,GWGI)
!
!*      2.3    Leaves interception water reservoir
!
CALL PREP_HOR_ISBA_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, S%TTIME, NPAR_VEG_IRR_USE, &
                         HPROGRAM,'WR     ',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
!
!*      2.4    Temperature profile
!
CALL PREP_HOR_ISBA_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, S%TTIME, NPAR_VEG_IRR_USE, &
                         HPROGRAM,'TG     ',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL,GTG)
!
!*      2.5    Snow variables
!
CALL PREP_HOR_ISBA_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, S%TTIME, NPAR_VEG_IRR_USE, &
                         HPROGRAM,'SN_VEG ',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL,GPERMSNOW)
!
!*      2.6    LAI
!
CALL PREP_HOR_ISBA_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, S%TTIME, NPAR_VEG_IRR_USE, &
                         HPROGRAM,'LAI    ',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
!
!*      2.7    GLACIER
!
IF(IO%LGLACIER)THEN
  CALL PREP_HOR_ISBA_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, S%TTIME, NPAR_VEG_IRR_USE, &
                          HPROGRAM,'ICE_STO',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
ENDIF
!
!*      2.8    Canopy vegetation temperature and interception reservoirs and air variables
!
IF(ISIZE_LMEB_PATCH>0)THEN
  CALL PREP_HOR_ISBA_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, S%TTIME, NPAR_VEG_IRR_USE, &
                          HPROGRAM,'TV     ',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
  CALL PREP_HOR_ISBA_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, S%TTIME, NPAR_VEG_IRR_USE, &
                          HPROGRAM,'TL     ',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
  CALL PREP_HOR_ISBA_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, S%TTIME, NPAR_VEG_IRR_USE, &
                          HPROGRAM,'WRL    ',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
  CALL PREP_HOR_ISBA_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, S%TTIME, NPAR_VEG_IRR_USE, &
                          HPROGRAM,'WRLI   ',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
  CALL PREP_HOR_ISBA_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, S%TTIME, NPAR_VEG_IRR_USE, &
                          HPROGRAM,'WRVN   ',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
  CALL PREP_HOR_ISBA_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, S%TTIME, NPAR_VEG_IRR_USE, &
                          HPROGRAM,'TC     ',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
  CALL PREP_HOR_ISBA_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, S%TTIME, NPAR_VEG_IRR_USE, &
                          HPROGRAM,'QC     ',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
ENDIF
!
IF(ISIZE_LMEB_PATCH==0)THEN
!
  DO JP = 1,IO%NPATCH
!
     PEK => NPE%AL(JP)
     PK => NP%AL(JP)
!
     ALLOCATE(PEK%XQC(PK%NSIZE_P))
     PEK%XQC(:)=0.0
     ALLOCATE(ZZS(PK%NSIZE_P))
     CALL PACK_SAME_RANK(PK%NR_P,S%XZS,ZZS)      
!
     DO JJ=1,PK%NSIZE_P
        IF(PK%XPATCH(JJ)>0.0)THEN
          ZWORK=XP00*EXP(-(XG/XRD/PEK%XTG(JJ,1))*ZZS(JJ))
          PEK%XQC(JJ)=QSAT(PEK%XTG(JJ,1),ZWORK)  
        ENDIF
     ENDDO
     DEALLOCATE(ZZS)
!
  ENDDO
!
ENDIF
!
!*      2.9    Isba-Ags prognostic fields
!
IF(IO%CPHOTO=='NIT'.OR.IO%CPHOTO=='NCB')THEN
  CALL PREP_HOR_ISBA_CC_FIELD(DTCO, U, GCP, SIZE(IG%XLAT), IO, S, NK, NP, NPE, NPAR_VEG_IRR_USE,   &
                              HPROGRAM,'BIOMASS ',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
ENDIF
!
!*      2.10   Isba-CC prognostic fields
!
IF(IO%CPHOTO/='NON'.AND.IO%CRESPSL=='CNT')THEN
!
!*Litter
!
  CALL PREP_HOR_ISBA_CC_FIELD(DTCO, U, GCP, SIZE(IG%XLAT), IO, S, NK, NP, NPE, NPAR_VEG_IRR_USE,   &
                              HPROGRAM,'LITTER  ',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
!
!*Soil carbon
!
  CALL PREP_HOR_ISBA_CC_FIELD(DTCO, U, GCP, SIZE(IG%XLAT), IO, S, NK, NP, NPE, NPAR_VEG_IRR_USE,   &
                              HPROGRAM,'SOILCARB',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
!
!*lignin
!
  CALL PREP_HOR_ISBA_CC_FIELD(DTCO, U, GCP, SIZE(IG%XLAT), IO, S, NK, NP, NPE, NPAR_VEG_IRR_USE,   &
                              HPROGRAM,'LIGNIN  ',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
ENDIF
!
!*      2.11   Isba-CC Explicit Soil Carbon scheme prognostic fields
!
IF (IO%CPHOTO/='NON'.AND.IO%CRESPSL=='DIF') THEN
!
!*Surface litter and lignin
!
  CALL PREP_HOR_ISBA_ESC_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, NPAR_VEG_IRR_USE,     &
                               HPROGRAM,'SURF_LIT',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
!
  CALL PREP_HOR_ISBA_ESC_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, NPAR_VEG_IRR_USE,     &
                               HPROGRAM,'SURF_LIG',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)

!
!*Soil carbon, litter and lignin
!
  CALL PREP_HOR_ISBA_ESC_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, NPAR_VEG_IRR_USE,     &
                               HPROGRAM,'SOILCARB',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
!
  CALL PREP_HOR_ISBA_ESC_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, NPAR_VEG_IRR_USE,     &
                               HPROGRAM,'SOIL_LIT',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
!
  CALL PREP_HOR_ISBA_ESC_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, NPAR_VEG_IRR_USE,     &
                               HPROGRAM,'SOIL_LIG',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
!
!*Soil gas
!
  IF(IO%LSOILGAS)THEN
!          
    CALL PREP_HOR_ISBA_ESC_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, NPAR_VEG_IRR_USE,     &
                                 HPROGRAM,'SGASO2  ',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
!
    CALL PREP_HOR_ISBA_ESC_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, NPAR_VEG_IRR_USE,     &
                                 HPROGRAM,'SGASCO2 ',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
!
    CALL PREP_HOR_ISBA_ESC_FIELD(DTCO, UG, U, USS, GCP, IG, IO, S, NK, NP, NPE, NPAR_VEG_IRR_USE,     &
                                 HPROGRAM,'SGASCH4 ',HATMFILE,HATMFILETYPE,HPGDFILE,HPGDFILETYPE,YDCTL)
!
  ENDIF
!
ENDIF
!
CALL CLEAN_PREP_OUTPUT_GRID
!
IF (YDCTL%LPART6) THEN
!-------------------------------------------------------------------------------------
!
!*      3.    Physical limitation: 
!
  DO JP=1,IO%NPATCH
!
     PEK => NPE%AL(JP)
     KK => NK%AL(JP)
!
!    No ice for force restore third layer:
!
     IF(IO%CISBA == '3-L')THEN
       WHERE(PEK%XWG (:,3) /= XUNDEF)
             PEK%XWG (:,3) = MIN(PEK%XWG(:,3)+ PEK%XWGI(:,3),KK%XWSAT(:,3))
             PEK%XWGI(:,3) = 0.
       END WHERE
     ENDIF
!
!    Total water content should not exceed saturation:
! 
     WHERE(PEK%XWG(:,:) /= XUNDEF .AND. (PEK%XWG(:,:) + PEK%XWGI(:,:)) > KK%XWSAT(:,:) )
          PEK%XWGI(:,:) = KK%XWSAT(:,:) - PEK%XWG(:,:)
     ENDWHERE
!
  ENDDO
!
! Soil temperature limited to 200K:
  IF(IO%CISBA == 'DIF')THEN
    DO JP=1,IO%NPATCH
       PEK => NPE%AL(JP)
       PEK%XTG(:,:)=MAX(PEK%XTG(:,:),200.)
    ENDDO
  ENDIF
!
!-------------------------------------------------------------------------------------
!
!*      4.     Vertical interpolations of all variables
!
  IF(LVERTSHIFT)THEN
    CALL PREP_VER_ISBA(IO, NPE, S%XZS, NP)
  ENDIF
!
  DEALLOCATE(XZS_LS)
!-------------------------------------------------------------------------------------
!
!*      5.     Treatment of permanent snow
!
  IF(LSNOW_PREP_PERM)THEN
     GPERMSNOW = .TRUE.
  ENDIF
!
  IF(GPERMSNOW)THEN
!
    L_IS_SNOW(:) = .FALSE.
!
    DO JVEGTYP=1,NVEGTYPE+NVEG_IRR 
      IVEGTYP = JVEGTYP
      IF(JVEGTYP>NVEGTYPE)THEN
        IVEGTYP = NPAR_VEG_IRR_USE(JVEGTYP-NVEGTYPE)
      ENDIF
      IF ( IVEGTYP == NVT_SNOW ) THEN 
        CALL VEGTYPE_TO_PATCH_IRRIG(JVEGTYP,IO%NPATCH,NPAR_VEG_IRR_USE,ISNOW)
        L_IS_SNOW(ISNOW) = .TRUE.
      ENDIF
    ENDDO
!
    DO JP = 1,IO%NPATCH
       KK => NK%AL(JP)
       PK => NP%AL(JP)
       PEK => NPE%AL(JP)
       IF(L_IS_SNOW(JP))THEN
          CALL PREP_PERM_SNOW(IO,KK,PK,PEK,NPAR_VEG_IRR_USE,GWGI_ADJUST(1:PK%NSIZE_P,JP))
       ENDIF
    ENDDO
!
  ENDIF
!
  DO JP = 1,IO%NPATCH
     PEK => NPE%AL(JP)
     CALL INIT_SNOW_LW(XEMISSN,PEK%TSNOW)
  ENDDO
!
  IF(LPHYSDOMC)THEN
    DO JP = 1,IO%NPATCH
      PEK => NPE%AL(JP)
      PEK%TSNOW%WSNOW(:,:)=0.
    ENDDO
  ENDIF 
!
!------------------------------------------------------------------------------------- 
! 
!*      6    Possibility for setting an upper limit on the initial snow water equivalent field 
!
  IF(LSWEMAX)THEN 
    DO JP = 1,IO%NPATCH
      PEK => NPE%AL(JP)
      ZWORK = MAXVAL(PEK%TSNOW%WSNOW(:,:)) 
      WRITE(ILUOUT,*) ' MAX(Snow content (kg/m2)): ', ZWORK 
      WRITE(ILUOUT,*) ' Set MAX to', XSWEMAX, '(kg/m2)' 
      PEK%TSNOW%WSNOW(:,:) = MIN(PEK%TSNOW%WSNOW(:,:),XSWEMAX) 
      ZWORK = MAXVAL(PEK%TSNOW%WSNOW(:,:)) 
      WRITE(ILUOUT,*) ' MAX(Snow content (kg/m2)): ', ZWORK 
    ENDDO
  ENDIF
!
!-------------------------------------------------------------------------------------
!
!*      7.     coherence between soil temperature and liquid/solid water
!
  GTEMP2WGI=(GWG.OR.GWGI.OR.GTG)
!
  IF(GTEMP2WGI)THEN
    GWGI_ADJUST(:,:) = .TRUE.
  ENDIF
!
  IF(IO%CISBA=='DIF')THEN
!          
    DO JP=1,IO%NPATCH
!
      PEK => NPE%AL(JP)
      PK => NP%AL(JP)
      KK => NK%AL(JP)
      !
      DO JL=1,IO%NGROUND_LAYER
        !
        DO JJ=1,PK%NSIZE_P
          !
          IF(PEK%XWG(JJ,JL)/=XUNDEF.AND.GWGI_ADJUST(JJ,JP))THEN
!     
!           total soil moisture
            ZWTOT = PEK%XWG(JJ,JL)+PEK%XWGI(JJ,JL)
            ZWTOT = MIN(ZWTOT,KK%XWSAT(JJ,JL))
!                
!           total matric potential
!           psi=mpotsat*(w/wsat)**(-bcoef)
            ZWORK   = ZWTOT/KK%XWSAT(JJ,JL)
            ZLOG    = KK%XBCOEF(JJ,JL)*LOG(ZWORK)
            ZMATPOT = KK%XMPOTSAT(JJ,JL)*EXP(-ZLOG)
!
!           soil liquid water content computation
!           w=wsat*(psi/mpotsat)**(-1/bcoef)
            ZMATPOT       = MIN(KK%XMPOTSAT(JJ,JL),XLMTT*(PEK%XTG(JJ,JL)-XTT)/(XG*PEK%XTG(JJ,JL)))
            ZWORK         = MAX(1.0,ZMATPOT/KK%XMPOTSAT(JJ,JL))
            ZLOG          = LOG(ZWORK)
            ZWL           = KK%XWSAT(JJ,JL)*EXP(-ZLOG/KK%XBCOEF(JJ,JL))
            ZWL           = MAX(ZWL,XWGMIN)
            PEK%XWG(JJ,JL) = MIN(ZWL,ZWTOT )
!
!           soil ice computation    
            PEK%XWGI(JJ,JL) = MAX(0.0,ZWTOT-PEK%XWG(JJ,JL))
! 
!           supress numerical artefact
            IF(PEK%XTG(JJ,JL)>=XTT)THEN
              PEK%XWG (JJ,JL) = MIN(PEK%XWG(JJ,JL)+PEK%XWGI(JJ,JL),KK%XWSAT(JJ,JL))
              PEK%XWGI(JJ,JL) = 0.0
            ENDIF
!
          ENDIF
        ENDDO        
      ENDDO 
!
    ENDDO
!
  ENDIF
!
!-------------------------------------------------------------------------------------
!
!*      8.     Half prognostic fields
!              The only variable used from the AVERAGED_ALBEDO_EMIS_ISBA call
!              is XTSRAD_NAT. All other variables are treated as dummies.
!
  DO JP = 1,IO%NPATCH
!
    PEK => NPE%AL(JP)
    PK => NP%AL(JP)
    KK => NK%AL(JP)
!
    ALLOCATE(PEK%XRESA(PK%NSIZE_P))
    PEK%XRESA = 100.
!
    ALLOCATE(PEK%XALBNIR(PK%NSIZE_P))
    ALLOCATE(PEK%XALBVIS(PK%NSIZE_P))
    ALLOCATE(PEK%XALBUV(PK%NSIZE_P))
    PEK%XALBNIR = 0.0
    PEK%XALBVIS = 0.0
    PEK%XALBUV = 0.0
!
    ALLOCATE(PEK%XALBNIR_SOIL(PK%NSIZE_P))
    ALLOCATE(PEK%XALBVIS_SOIL(PK%NSIZE_P))
    ALLOCATE(PEK%XALBUV_SOIL (PK%NSIZE_P))
    CALL SOIL_ALBEDO (IO%CALBEDO, KK%XWSAT(:,1),PEK%XWG(:,1), KK, PEK, "ALL" )
!
    ALLOCATE(PEK%XPSN   (PK%NSIZE_P))
    ALLOCATE(PEK%XPSNG  (PK%NSIZE_P))
    ALLOCATE(PEK%XPSNV  (PK%NSIZE_P))
    ALLOCATE(PEK%XPSNV_A(PK%NSIZE_P))
    PEK%XPSN    = 0.0
    PEK%XPSNG   = 0.0
    PEK%XPSNV   = 0.0
    PEK%XPSNV_A = 0.0
    ALLOCATE(KK%XDIR_ALB_WITH_SNOW(PK%NSIZE_P,1))
    ALLOCATE(KK%XSCA_ALB_WITH_SNOW(PK%NSIZE_P,1))
!
    ZTG1(1:PK%NSIZE_P,JP) = PEK%XTG(:,1)
!
  ENDDO
!
  ALLOCATE(S%XTSRAD_NAT(U%NSIZE_NATURE))
  ZZENITH(:)=0.
  ZSW_BANDS(:)=0.
!
  CALL AVERAGED_ALBEDO_EMIS_ISBA(IO, S, NK, NP, NPE,                                             &
                                 ZZENITH, ZTG1, ZSW_BANDS, NPAR_VEG_IRR_USE, ZDIR_ALB, ZSCA_ALB, &
                                 ZEMIS, S%XTSRAD_NAT, ZTSURF              )
!
  DO JP = 1,IO%NPATCH
    KK => NK%AL(JP)
    PEK => NPE%AL(JP)
    DEALLOCATE(PEK%XPSN)
    DEALLOCATE(PEK%XPSNG)
    DEALLOCATE(PEK%XPSNV)
    DEALLOCATE(PEK%XPSNV_A)
    DEALLOCATE(KK%XDIR_ALB_WITH_SNOW)
    DEALLOCATE(KK%XSCA_ALB_WITH_SNOW)
  ENDDO
!
!-------------------------------------------------------------------------------------
!
!*      9.     Isba-Ags prognostic fields
!
  IF (IO%CPHOTO /= 'NON') THEN
!
    DO JP = 1,IO%NPATCH
!
      PEK => NPE%AL(JP)
      PK => NP%AL(JP)
!
      ALLOCATE(PEK%XAN(PK%NSIZE_P))
      PEK%XAN = 0.
!
      ALLOCATE(PEK%XANDAY(PK%NSIZE_P))
      PEK%XANDAY = 0.
!
      ALLOCATE(PEK%XANFM(PK%NSIZE_P))
      PEK%XANFM = XANFMINIT
!
      ALLOCATE(PEK%XRESP_BIOMASS(PK%NSIZE_P,IO%NNBIOMASS))
      PEK%XRESP_BIOMASS(:,:) = 0.
!
    ENDDO
!
  ENDIF
!
  IF (IO%CPHOTO == 'AST') THEN
!
    DO JP = 1,IO%NPATCH
!
      PEK => NPE%AL(JP)
      PK => NP%AL(JP)
!
      ALLOCATE(PEK%XBIOMASS(PK%NSIZE_P,IO%NNBIOMASS))
      PEK%XBIOMASS(:,:) = 0.
!
    ENDDO
!
  ENDIF
!
!
!-------------------------------------------------------------------------------------
!
!*      10.     Isba-CC prognostic fields
!
!
! Initialize year counter
!
  IF(IO%LSPINUPCARBS)THEN
    IO%NNBYEARSOLD=0
  ENDIF
!
  IF(IO%CPHOTO=='NCB'.AND.(IO%CRESPSL=='CNT'.OR.IO%CRESPSL=='DIF')) THEN
!
!   Fire disturbance
!
    IF(IO%LFIRE)THEN
!
      DO JP = 1,IO%NPATCH
!
         PEK => NPE%AL(JP)
         PK => NP%AL(JP)
!           
         ALLOCATE(PEK%XFIREIND(PK%NSIZE_P))
         PEK%XFIREIND(:)=0.0
!           
         ALLOCATE(PEK%XMOISTLIT_FIRE(PK%NSIZE_P))           
         PEK%XMOISTLIT_FIRE(:)=PEK%XWG(:,1)+PEK%XWGI(:,1)
!           
         ALLOCATE(PEK%XTEMPLIT_FIRE(PK%NSIZE_P))
         PEK%XTEMPLIT_FIRE(:)=PEK%XTG(:,1)
! 
      ENDDO
!
    ENDIF
!
!   Land-use Land Cover change
!
    IF(IO%LLULCC)THEN
!
      DO JP = 1,IO%NPATCH
!
         PEK => NPE%AL(JP)
         PK => NP%AL(JP)
!
         ALLOCATE(PEK%XFLUATM(PK%NSIZE_P))
         PEK%XFLUATM(:)=0.
!
         ALLOCATE(PEK%XFLURES(PK%NSIZE_P))
         PEK%XFLURES(:)=0.
!
         ALLOCATE(PEK%XFLUANT(PK%NSIZE_P))
         PEK%XFLUANT(:)=0.
!
         ALLOCATE(PEK%XFANTATM(PK%NSIZE_P))
         PEK%XFANTATM(:)=0.
!
         ALLOCATE(PEK%XEXPORT_DECADAL(PK%NSIZE_P,IO%NNDECADAL))
         PEK%XEXPORT_DECADAL(:,:)=0.
!
         ALLOCATE(PEK%XCSTOCK_DECADAL(PK%NSIZE_P,IO%NNDECADAL))
         PEK%XCSTOCK_DECADAL(:,:)=0.
!
         ALLOCATE(PEK%XEXPORT_CENTURY(PK%NSIZE_P,IO%NNCENTURY))
         PEK%XEXPORT_CENTURY(:,:)=0.
!
         ALLOCATE(PEK%XCSTOCK_CENTURY(PK%NSIZE_P,IO%NNCENTURY))
         PEK%XCSTOCK_CENTURY(:,:)=0.
!
      ENDDO
!
    ENDIF
!
  ENDIF
!
!-------------------------------------------------------------------------------------
!
!*      11.     Preparation of canopy air variables
!
!
  IO%LCANOPY = LISBA_CANOPY
!
  IF(IO%LCANOPY)THEN
    CALL PREP_SBL(IG%NDIM,SB)
  ENDIF
!
ENDIF
!
IF (LHOOK) CALL DR_HOOK('PREP_ISBA',1,ZHOOK_HANDLE)
!
!-------------------------------------------------------------------------------------
!
END SUBROUTINE PREP_ISBA
