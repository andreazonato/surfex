!SFX_LIC Copyright 1994-2014 CNRS, Meteo-France and Universite Paul Sabatier
!SFX_LIC This is part of the SURFEX software governed by the CeCILL-C licence
!SFX_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!SFX_LIC for details. version 1.
!     #########
      SUBROUTINE WRITESURF_ISBA_n (HSELECT, OSNOWDIMNC, CHI, MGN, NDST, &
                                   IO, S, NP, NPE, NAG, KI, HPROGRAM   )
!     #####################################
!
!!****  *WRITESURF_ISBA_n* - writes ISBA prognostic fields
!!                        
!!
!!    PURPOSE
!!    -------
!!
!!**  METHOD
!!    ------
!!
!!    EXTERNAL
!!    --------
!!
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!
!!    REFERENCE
!!    ---------
!!
!!
!!    AUTHOR
!!    ------
!!      V. Masson   *Meteo France*
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    01/2003 
!!      P. LeMoigne 12/2004 : correct dimensionning if more than 10 layers in
!!                            the soil (diffusion version)
!!      B. Decharme  2008    : Floodplains
!!      B. Decharme  01/2009 : Optional Arpege deep soil temperature write
!!      A.L. Gibelin   03/09 : modifications for CENTURY model 
!!      A.L. Gibelin 04/2009 : BIOMASS and RESP_BIOMASS arrays 
!!      A.L. Gibelin 06/2009 : Soil carbon variables for CNT option
!!      B. Decharme  07/2011 : land_use semi-prognostic variables
!!      B. Decharme  09/2012 : suppress NWG_LAYER (parallelization problems)
!!      B. Decharme  09/2012 : write some key for prep_read_external
!!      B. Decharme  04/2013 : Only 2 temperature layer in ISBA-FR
!!      P. Samuelsson 10/2014: MEB
!!      P. Tulet  06/2016 : add XEF et XPFT for MEGAN coupling
!!      M. Leriche 06/2017: comment write XEF & XPFT bug
!!      A. Druel     02/2019 : Add NIRR_TSC and NIRRINUM (with NAG) for irrigation
!!      Séférian/Decharme  08/16  : fire scheme ; change landuse implementation
!!      B. Decharme    02/17 : exact computation of saturation deficit near the leaf surface
!!      B. Decharme    02/21 : explicit soil carbon and gas scheme:browse confirm wa

!!
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_SURFEX_MPI,     ONLY : NRANK
!
USE MODN_PREP_SURF_ATM,  ONLY : LWRITE_EXTERN
USE MODD_WRITE_SURF_ATM, ONLY : LSPLIT_PATCH
!
USE MODD_CH_ISBA_n,      ONLY : CH_ISBA_t
USE MODD_DST_n,          ONLY : DST_NP_t
!
USE MODD_ISBA_OPTIONS_n, ONLY : ISBA_OPTIONS_t
USE MODD_ISBA_n,         ONLY : ISBA_NP_t, ISBA_NPE_t, ISBA_S_t
USE MODD_AGRI_n,         ONLY : AGRI_NP_t
USE MODD_MEGAN_n,        ONLY : MEGAN_t
!
USE MODD_SURF_PAR,       ONLY : NUNDEF, LEN_HREC
!
USE MODD_ASSIM,          ONLY : LASSIM, CASSIM, CASSIM_ISBA, NIE, NENS, &
                                XADDTIMECORR, LENS_GEN, NVAR
!
USE MODD_AGRI,           ONLY : LIRRIGMODE
!
USE MODD_DATA_COVER_PAR, ONLY : NVEGTYPE
!
USE MODD_DST_SURF
!
USE MODI_WRITE_FIELD_1D_PATCH
USE MODI_WRITE_SURF
USE MODI_WRITESURF_GR_SNOW
USE MODI_ALLOCATE_GR_SNOW
USE MODI_DEALLOC_GR_SNOW
!
USE YOMHOOK,            ONLY : LHOOK,   DR_HOOK
USE PARKIND1,           ONLY : JPRB
!
IMPLICIT NONE
!
!*       0.1   Declarations of arguments
!              -------------------------
!
CHARACTER(LEN=*), DIMENSION(:), INTENT(IN) :: HSELECT 
LOGICAL,              INTENT(IN)    :: OSNOWDIMNC  
!
TYPE(CH_ISBA_t),      INTENT(INOUT) :: CHI
TYPE(MEGAN_t),        INTENT(INOUT) :: MGN
TYPE(DST_NP_t),       INTENT(INOUT) :: NDST
!
TYPE(ISBA_OPTIONS_t), INTENT(INOUT) :: IO
TYPE(ISBA_S_t),       INTENT(INOUT) :: S
TYPE(ISBA_NP_t),      INTENT(INOUT) :: NP
TYPE(ISBA_NPE_t),     INTENT(INOUT) :: NPE
TYPE(AGRI_NP_t),      INTENT(INOUT) :: NAG
INTEGER,              INTENT(IN)    :: KI
!
CHARACTER(LEN=6),    INTENT(IN)    :: HPROGRAM ! program calling
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER           :: IRESP          ! IRESP  : return-code if a problem appears
CHARACTER(LEN=LEN_HREC) :: YRECFM         ! Name of the article to be read
CHARACTER(LEN=4 ) :: YLVL
CHARACTER(LEN=3 ) :: YVAR
CHARACTER(LEN=100):: YCOMMENT       ! Comment string
CHARACTER(LEN=25) :: YFORM          ! Writing format
CHARACTER(LEN=2) :: YPAT
!
INTEGER :: JJ, JL, JP, JNB, JNL, JNC, JNLV  ! loop counter on levels
INTEGER :: IWORK   ! Work integer
INTEGER :: JSV
INTEGER :: ISIZE_LMEB_PATCH
INTEGER :: JVAR
REAL, DIMENSION(:), ALLOCATABLE :: ZWORK
!
REAL(KIND=JPRB) :: ZHOOK_HANDLE
!
!------------------------------------------------------------------------------
!
!*       2.     Prognostic fields:
!               -----------------
!
IF (LHOOK) CALL DR_HOOK('WRITESURF_ISBA_N',0,ZHOOK_HANDLE)
!
!* soil temperatures
!
IF(IO%LTEMP_ARP)THEN
  IWORK=IO%NTEMPLAYER_ARP
ELSEIF(IO%CISBA=='DIF')THEN
  IWORK=IO%NGROUND_LAYER
ELSE
  IWORK=2 !Only 2 temperature layer in ISBA-FR
ENDIF
!
DO JL=1,IWORK
  WRITE(YLVL,'(I4)') JL
  YRECFM='TG'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
  YFORM='(A6,I1.1,A4)'
  IF (JL >= 10)  YFORM='(A6,I2.2,A4)'
  WRITE(YCOMMENT,FMT=YFORM) 'X_Y_TG',JL,' (K)'
  DO JP = 1,IO%NPATCH
    CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                NP%AL(JP)%NR_P,NPE%AL(JP)%XTG(:,JL),KI,S%XWORK_WR)
  ENDDO
END DO
!
!* soil liquid water contents
!
DO JL=1,IO%NGROUND_LAYER
  WRITE(YLVL,'(I4)') JL     
  YRECFM='WG'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
  YFORM='(A6,I1.1,A8)'
  IF (JL >= 10)  YFORM='(A6,I2.2,A8)'
  WRITE(YCOMMENT,FMT=YFORM) 'X_Y_WG',JL,' (m3/m3)'
  DO JP = 1,IO%NPATCH
    CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                NP%AL(JP)%NR_P,NPE%AL(JP)%XWG(:,JL),KI,S%XWORK_WR)  
  ENDDO
END DO
!
!* soil ice water contents
!
IF(IO%CISBA=='DIF')THEN
  IWORK=IO%NGROUND_LAYER
ELSE
  IWORK=2 !Only 2 soil ice layer in ISBA-FR
ENDIF
!
DO JL=1,IWORK
  WRITE(YLVL,'(I4)') JL     
  YRECFM='WGI'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
  YFORM='(A7,I1.1,A8)'
  IF (JL >= 10)  YFORM='(A7,I2.2,A8)'
  WRITE(YCOMMENT,YFORM) 'X_Y_WGI',JL,' (m3/m3)'
  DO JP = 1,IO%NPATCH
    CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                NP%AL(JP)%NR_P,NPE%AL(JP)%XWGI(:,JL),KI,S%XWORK_WR)  
  ENDDO
END DO
!
!* water intercepted on leaves
!
YRECFM='WR'
YCOMMENT='X_Y_WR (kg/m2)'
DO JP = 1,IO%NPATCH
  CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                NP%AL(JP)%NR_P,NPE%AL(JP)%XWR(:),KI,S%XWORK_WR)    
ENDDO
!
!* vegetation canopy air specific humidity
!
YRECFM='QC'
YCOMMENT='X_Y_QC (kg/kg)'
DO JP = 1,IO%NPATCH
   CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                  NP%AL(JP)%NR_P,NPE%AL(JP)%XQC(:),KI,S%XWORK_WR)    
ENDDO
!
!
!* Glacier ice storage
!
YRECFM = 'GLACIER'
YCOMMENT='LGLACIER key for external prep'   
CALL WRITE_SURF(HSELECT,HPROGRAM,YRECFM,IO%LGLACIER,IRESP,HCOMMENT=YCOMMENT)
!
IF(IO%LGLACIER)THEN
  YRECFM='ICE_STO'
  YCOMMENT='X_Y_ICE_STO (kg/m2)'
  DO JP = 1,IO%NPATCH
    CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                NP%AL(JP)%NR_P,NPE%AL(JP)%XICE_STO(:),KI,S%XWORK_WR)   
  ENDDO
ENDIF
!
!* Leaf Area Index
!
IF (IO%CPHOTO/='NON' .AND. IO%CPHOTO/='AST') THEN
  !
  YRECFM='LAI'
  !
  YCOMMENT='X_Y_LAI (m2/m2)'
  DO JP = 1,IO%NPATCH
    CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                NP%AL(JP)%NR_P,NPE%AL(JP)%XLAI(:),KI,S%XWORK_WR)    
  ENDDO
  !
END IF
!
IF ( TRIM(CASSIM_ISBA)=="ENKF" .AND. (LASSIM .OR. NIE/=0) ) THEN
  DO JVAR = 1,NVAR
    IF ( XADDTIMECORR(JVAR)>0. ) THEN
      WRITE(YVAR,'(I3)') JVAR
      YCOMMENT = 'Red_Noise_Enkf'
      YRECFM='RD_NS'//ADJUSTL(YVAR(:LEN_TRIM(YVAR)))
      DO JP = 1,IO%NPATCH
        CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                     NP%AL(JP)%NR_P,NP%AL(JP)%XRED_NOISE(:,JVAR),KI,S%XWORK_WR)       
      ENDDO
    ENDIF
  ENDDO
ENDIF
!
IF ( LIRRIGMODE ) THEN
  !
  !* Irrigation time step counter (current irrigation + time before another irrigation)
  !
  YRECFM='IRR_TSTEP'
  YCOMMENT='X_Y_Time_Step_Counter'
  DO JP = 1,IO%NPATCH
    ALLOCATE(ZWORK(SIZE(NAG%AL(JP)%NIRR_TSC(:),1)))
    ZWORK(:)=NAG%AL(JP)%NIRR_TSC(:)
    CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                NP%AL(JP)%NR_P,ZWORK(:),KI,S%XWORK_WR)
    DEALLOCATE(ZWORK)
  ENDDO
  !
  !* Irrigation number (from the beguinning of the season)
  !
  YRECFM='IRR_NUM'
  YCOMMENT='X_Y_Irrigation_number'
  DO JP = 1,IO%NPATCH
    ALLOCATE(ZWORK(SIZE(NAG%AL(JP)%NIRRINUM(:),1)))
    ZWORK(:)=NAG%AL(JP)%NIRRINUM(:)
    CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                NP%AL(JP)%NR_P,ZWORK(:),KI,S%XWORK_WR)
    DEALLOCATE(ZWORK)
  ENDDO
  !
ENDIF
!
!* snow mantel
!
DO JP = 1,IO%NPATCH
  CALL WRITESURF_GR_SNOW(OSNOWDIMNC, HSELECT, HPROGRAM, 'VEG', '     ', KI, &
           NP%AL(JP)%NR_P, JP, NPE%AL(JP)%TSNOW, S%XWSN_WR, S%XRHO_WR, &
           S%XHEA_WR, S%XAGE_WR, S%XSG1_WR, S%XSG2_WR, S%XHIS_WR, S%XALB_WR, S%XIMP_WR)
ENDDO
!
!* key and/or field usefull to make an external prep
!
IF(IO%CISBA=='DIF')THEN
!
  YRECFM = 'SOC'
  YCOMMENT='SOC key for external prep'
  CALL WRITE_SURF(HSELECT,HPROGRAM,YRECFM,IO%LSOC,IRESP,HCOMMENT=YCOMMENT)
!
ELSE
!
  YRECFM = 'TEMPARP'
  YCOMMENT='LTEMP_ARP key for external prep'
  CALL WRITE_SURF(HSELECT,HPROGRAM,YRECFM,IO%LTEMP_ARP,IRESP,HCOMMENT=YCOMMENT)
!
  IF(IO%LTEMP_ARP)THEN
    YRECFM = 'NTEMPLARP'
    YCOMMENT='NTEMPLAYER_ARP for external prep'
    CALL WRITE_SURF(HSELECT,HPROGRAM,YRECFM,IO%NTEMPLAYER_ARP,IRESP,HCOMMENT=YCOMMENT)
  ENDIF
!
ENDIF
!
!-------------------------------------------------------------------------------
!
!*       3.  MEB Prognostic or Semi-prognostic variables
!            -------------------------------------------
!
!
ISIZE_LMEB_PATCH=COUNT(IO%LMEB_PATCH(:))
!
IF (ISIZE_LMEB_PATCH>0) THEN
!
!* water intercepted on canopy vegetation leaves
!
  YRECFM='WRL'
  YCOMMENT='X_Y_WRL (kg/m2)'
  DO JP = 1,IO%NPATCH
    CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                  NP%AL(JP)%NR_P,NPE%AL(JP)%XWRL(:),KI,S%XWORK_WR)    
  ENDDO
!
!* ice on litter
!
  YRECFM='WRLI'
  YCOMMENT='X_Y_WRLI (kg/m2)'
  DO JP = 1,IO%NPATCH
    CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                  NP%AL(JP)%NR_P,NPE%AL(JP)%XWRLI(:),KI,S%XWORK_WR)    
  ENDDO
!
!* snow intercepted on canopy vegetation leaves
!
  YRECFM='WRVN'
  YCOMMENT='X_Y_WRVN (kg/m2)'
  DO JP = 1,IO%NPATCH
    CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                  NP%AL(JP)%NR_P,NPE%AL(JP)%XWRVN(:),KI,S%XWORK_WR)    
  ENDDO

!
!* canopy vegetation temperature
!
  YRECFM='TV'
  YCOMMENT='X_Y_TV (K)'
  DO JP = 1,IO%NPATCH
    CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                  NP%AL(JP)%NR_P,NPE%AL(JP)%XTV(:),KI,S%XWORK_WR)    
  ENDDO
!
!* litter temperature
!
  YRECFM='TL'
  YCOMMENT='X_Y_TL (K)'
  DO JP = 1,IO%NPATCH
    CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                  NP%AL(JP)%NR_P,NPE%AL(JP)%XTL(:),KI,S%XWORK_WR)    
  ENDDO
!
!* vegetation canopy air temperature
!
  YRECFM='TC'
  YCOMMENT='X_Y_TC (K)'
  DO JP = 1,IO%NPATCH
    CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                  NP%AL(JP)%NR_P,NPE%AL(JP)%XTC(:),KI,S%XWORK_WR)    
  ENDDO
!
ENDIF
!
!
!-------------------------------------------------------------------------------
!
!*       4.  Semi-prognostic variables
!            -------------------------
!
!
!* Fraction for each patch
!
YRECFM='PATCH'
YCOMMENT='fraction for each patch (-)'
DO JP = 1,IO%NPATCH
  CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                  NP%AL(JP)%NR_P,NP%AL(JP)%XPATCH(:),KI,S%XWORK_WR)    
ENDDO
!
!* patch averaged radiative temperature (K)
!
YRECFM='TSRAD_NAT'
YCOMMENT='X_TSRAD_NAT (K)'
 CALL WRITE_SURF(HSELECT,HPROGRAM,YRECFM,S%XTSRAD_NAT(:),IRESP,HCOMMENT=YCOMMENT)
!
!* aerodynamical resistance
!
YRECFM='RESA'
YCOMMENT='X_Y_RESA (s/m)'
DO JP = 1,IO%NPATCH
  CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                  NP%AL(JP)%NR_P,NPE%AL(JP)%XRESA(:),KI,S%XWORK_WR)    
ENDDO
!
!* Land use variables
!
IF(IO%LLULCC .OR. LWRITE_EXTERN)THEN
!
  DO JL=1,IO%NGROUND_LAYER
    WRITE(YLVL,'(I4)') JL
    YRECFM='DG'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
    YFORM='(A6,I1.1,A8)'
    IF (JL >= 10)  YFORM='(A6,I2.2,A8)'
    WRITE(YCOMMENT,FMT=YFORM) 'X_Y_DG',JL,' (m)'
    DO JP = 1,IO%NPATCH
      CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                      NP%AL(JP)%NR_P,NP%AL(JP)%XDG(:,JL),KI,S%XWORK_WR)    
    ENDDO
  END DO
!
ENDIF
!
IF(IO%LLULCC)THEN
!
  DO JL=1,NVEGTYPE
    WRITE(YLVL,'(I4)') JL
    YRECFM='VEGTYPE'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
    YCOMMENT='fraction of each vegetation type in the grid cell'
    CALL WRITE_SURF(HSELECT,HPROGRAM,YRECFM,S%XVEGTYPE(:,JL),IRESP,HCOMMENT=YCOMMENT)
  ENDDO
!
ENDIF
!
!
!-------------------------------------------------------------------------------
!
!*       5.  ISBA-AGS variables
!            ------------------
!
!
IF (IO%CPHOTO/='NON') THEN
  YRECFM='AN'
  YCOMMENT='X_Y_AN (kgCO2/kgair m/s)'
  DO JP = 1,IO%NPATCH
    CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                    NP%AL(JP)%NR_P,NPE%AL(JP)%XAN(:),KI,S%XWORK_WR)    
  ENDDO
!
  YRECFM='ANDAY'
  YCOMMENT='X_Y_ANDAY (kgCO2/m2/day)'
  DO JP = 1,IO%NPATCH
    CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                    NP%AL(JP)%NR_P,NPE%AL(JP)%XANDAY(:),KI,S%XWORK_WR)    
  ENDDO  
!
  YRECFM='ANFM'
  YCOMMENT='X_Y_ANFM (kgCO2/kgair m/s)'
  DO JP = 1,IO%NPATCH
    CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                    NP%AL(JP)%NR_P,NPE%AL(JP)%XANFM(:),KI,S%XWORK_WR)    
  ENDDO    
!
END IF
!
!
IF (IO%CPHOTO=='NIT' .OR. IO%CPHOTO=='NCB') THEN
  !
  DO JNB=1,IO%NNBIOMASS
    WRITE(YLVL,'(I1)') JNB
    YRECFM='BIOMA'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
    YFORM='(A11,I1.1,A10)'
    WRITE(YCOMMENT,FMT=YFORM) 'X_Y_BIOMASS',JNB,' (kgDM/m2)'
    DO JP = 1,IO%NPATCH
      CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                      NP%AL(JP)%NR_P,NPE%AL(JP)%XBIOMASS(:,JNB),KI,S%XWORK_WR)    
    ENDDO      
  END DO
  !
  !
  DO JNB=2,IO%NNBIOMASS
    WRITE(YLVL,'(I1)') JNB
    YRECFM='RESPI'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
    YFORM='(A16,I1.1,A10)'
    WRITE(YCOMMENT,FMT=YFORM) 'X_Y_RESP_BIOMASS',JNB,' (kg/m2/s)'
    DO JP = 1,IO%NPATCH
      CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                      NP%AL(JP)%NR_P,NPE%AL(JP)%XRESP_BIOMASS(:,JNB),KI,S%XWORK_WR)    
    ENDDO      
  END DO
  !
END IF
!
!-------------------------------------------------------------------------------
!
!*       6. ISBA-CC
!           -------
!
!
YRECFM = 'RESPSL'
YCOMMENT=YRECFM
CALL WRITE_SURF(HSELECT,HPROGRAM,YRECFM,IO%CRESPSL,IRESP,HCOMMENT=YCOMMENT)
!
YRECFM = 'SOILGAS'
YCOMMENT=YRECFM
CALL WRITE_SURF(HSELECT,HPROGRAM,YRECFM,IO%LSOILGAS,IRESP,HCOMMENT=YCOMMENT)
!
IF(IO%LSPINUPCARBS)THEN
  YRECFM='NBYEARSOLD'
  YCOMMENT='yrs'
  CALL WRITE_SURF(HSELECT,HPROGRAM,YRECFM,IO%NNBYEARSOLD,IRESP,HCOMMENT=YCOMMENT)
ENDIF
!
!
IF (IO%CRESPSL=='CNT') THEN
!
!
!*       6.1 Bulk Soil carbon
!
!
  DO JNL=1,IO%NNLITTER
    DO JNLV=1,IO%NNLITTLEVS
      WRITE(YLVL,'(I1,A1,I1)') JNL,'_',JNLV
      YRECFM='LITTER'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
      YFORM='(A10,I1.1,A1,I1.1,A8)'
      WRITE(YCOMMENT,FMT=YFORM) 'X_Y_LITTER',JNL,' ',JNLV,' (gC/m2)'
      DO JP = 1,IO%NPATCH
        CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                        NP%AL(JP)%NR_P,NPE%AL(JP)%XLITTER(:,JNL,JNLV),KI,S%XWORK_WR)    
      ENDDO        
    END DO
  END DO
!
  DO JNC=1,IO%NNSOILCARB
    WRITE(YLVL,'(I4)') JNC
    YRECFM='SOILCARB'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
    YFORM='(A8,I1.1,A8)'
    WRITE(YCOMMENT,FMT=YFORM) 'X_Y_SOILCARB',JNC,' (gC/m2)'
    DO JP = 1,IO%NPATCH
      CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                      NP%AL(JP)%NR_P,NPE%AL(JP)%XSOILCARB(:,JNC),KI,S%XWORK_WR)    
    ENDDO     
  END DO
!
  DO JNLV=1,IO%NNLITTLEVS
    WRITE(YLVL,'(I4)') JNLV
    YRECFM='LIGN_STR'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
    YFORM='(A12,I1.1,A8)'
    WRITE(YCOMMENT,FMT=YFORM) 'X_Y_LIGNIN_STRUC',JNLV,' (-)'
    DO JP = 1,IO%NPATCH
      CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                      NP%AL(JP)%NR_P,NPE%AL(JP)%XLIGNIN_STRUC(:,JNLV),KI,S%XWORK_WR)    
    ENDDO       
  END DO
!
ELSEIF (IO%CRESPSL=='DIF') THEN
!
!
!*       6.2 Multi-layer Soil carbon
!
!
  YRECFM='SURF_LIGN'
  YCOMMENT='X_Y_SURFACE_LIGNIN_STRUC'
  DO JP = 1,IO%NPATCH
      CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                      NP%AL(JP)%NR_P,NPE%AL(JP)%XSURFACE_LIGNIN_STRUC(:),KI,S%XWORK_WR)    
  ENDDO
!
  DO JNL=1,IO%NNLITTER
     WRITE(YLVL,'(I1)') JNL
     YRECFM='SURF_LIT'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
     YCOMMENT='X_Y_SURFACE_LITTER'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))//' (gC/m2)'
     DO JP = 1,IO%NPATCH
        CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                      NP%AL(JP)%NR_P,NPE%AL(JP)%XSURFACE_LITTER(:,JNL),KI,S%XWORK_WR)    
     ENDDO
  END DO
!
  DO JL=1,IO%NGROUND_LAYER
     WRITE(YLVL,'(I2.2)') JL
     YRECFM='DFLIGN'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
     YCOMMENT='X_Y_Z_SOIL_LIGNIN_STRUC'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
     DO JP = 1,IO%NPATCH
        CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                      NP%AL(JP)%NR_P,NPE%AL(JP)%XSOILDIF_LIGNIN_STRUC(:,JL),KI,S%XWORK_WR)    
     ENDDO    
  END DO
!
  DO JNL=1,IO%NNLITTER
    DO JL=1,IO%NGROUND_LAYER
       WRITE(YLVL,'(I1,A1,I2.2)') JNL,'L',JL
       YRECFM='DFLIT'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
       YCOMMENT='X_Y_Z_SOIL_LITTER'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))//' (gC/m2)'
       DO JP = 1,IO%NPATCH
          CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                        NP%AL(JP)%NR_P,NPE%AL(JP)%XSOILDIF_LITTER(:,JL,JNL),KI,S%XWORK_WR)    
       ENDDO      
    END DO
  END DO
!
  DO JNC=1,IO%NNSOILCARB
      DO JL=1,IO%NGROUND_LAYER
         WRITE(YLVL,'(I1,A1,I2.2)')JNC,'L',JL
         YRECFM='DFCARB'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
         YCOMMENT='X_Y_Z_SOILCARB'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))//' (gC/m2)'
         DO JP = 1,IO%NPATCH
            CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                          NP%AL(JP)%NR_P,NPE%AL(JP)%XSOILDIF_CARB(:,JL,JNC),KI,S%XWORK_WR)    
         ENDDO        
      ENDDO
  END DO
!
ENDIF
!
!
!*       6.3 Multi-layer Soil gas
!
!
IF (IO%CRESPSL=='DIF'.AND.IO%LSOILGAS) THEN
!
  DO JL=1,IO%NGROUND_LAYER
     WRITE(YLVL,'(I2.2)') JL
     YRECFM='SGASO2L'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
     YCOMMENT='X_Y_Z_SGASO2L'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))//' (g/m3)'
     DO JP = 1,IO%NPATCH
        CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                      NP%AL(JP)%NR_P,NPE%AL(JP)%XSGASO2(:,JL),KI,S%XWORK_WR)    
     ENDDO    
  END DO
!
  DO JL=1,IO%NGROUND_LAYER
     WRITE(YLVL,'(I2.2)') JL
     YRECFM='SGASCO2L'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
     YCOMMENT='X_Y_Z_SGASCO2L'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))//' (g/m3)'
     DO JP = 1,IO%NPATCH
        CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                      NP%AL(JP)%NR_P,NPE%AL(JP)%XSGASCO2(:,JL),KI,S%XWORK_WR)    
     ENDDO
  END DO
!
  DO JL=1,IO%NGROUND_LAYER
     WRITE(YLVL,'(I2.2)') JL
     YRECFM='SGASCH4L'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
     YCOMMENT='X_Y_Z_SGASCH4L'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))//' (g/m3)'
     DO JP = 1,IO%NPATCH
        CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                      NP%AL(JP)%NR_P,NPE%AL(JP)%XSGASCH4(:,JL),KI,S%XWORK_WR)    
     ENDDO
  END DO
!
ENDIF
!
!
!*       6.4 Fire scheme
!
!
IF (IO%LFIRE) THEN
!
  YRECFM = 'FIREIND'
  YCOMMENT=YRECFM
  DO JP = 1,IO%NPATCH
     CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                   NP%AL(JP)%NR_P,NPE%AL(JP)%XFIREIND,KI,S%XWORK_WR)    
  ENDDO
!
  YRECFM='MOISTLITFIRE'
  YCOMMENT=YRECFM
  DO JP = 1,IO%NPATCH
     CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                   NP%AL(JP)%NR_P,NPE%AL(JP)%XMOISTLIT_FIRE,KI,S%XWORK_WR)    
  ENDDO
!
  YRECFM='TEMPLITFIRE'
  YCOMMENT=YRECFM
  DO JP = 1,IO%NPATCH
     CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                   NP%AL(JP)%NR_P,NPE%AL(JP)%XTEMPLIT_FIRE,KI,S%XWORK_WR)    
  ENDDO
!
END IF
!
!
!*       6.5 Land-use Land Cover change carbon Managing
!           -------------------------------------------
!
IF (IO%CPHOTO=='NCB' .AND. (IO%CRESPSL=='CNT'.OR.IO%CRESPSL=='DIF') .AND. IO%LLULCC) THEN
!
  YRECFM = 'FLUATM'
  YCOMMENT=YRECFM
  DO JP = 1,IO%NPATCH
     CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                   NP%AL(JP)%NR_P,NPE%AL(JP)%XFLUATM,KI,S%XWORK_WR)    
  ENDDO
!
  YRECFM = 'FLURES'
  YCOMMENT=YRECFM
  DO JP = 1,IO%NPATCH
     CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                   NP%AL(JP)%NR_P,NPE%AL(JP)%XFLURES,KI,S%XWORK_WR)    
  ENDDO
!
  YRECFM = 'FLUANT'
  YCOMMENT=YRECFM
  DO JP = 1,IO%NPATCH
     CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                   NP%AL(JP)%NR_P,NPE%AL(JP)%XFLUANT,KI,S%XWORK_WR)    
  ENDDO
!
  YRECFM = 'FANTATM'
  YCOMMENT=YRECFM
  DO JP = 1,IO%NPATCH
     CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                   NP%AL(JP)%NR_P,NPE%AL(JP)%XFANTATM,KI,S%XWORK_WR)    
  ENDDO
!
  DO JNC=1,IO%NNDECADAL
     WRITE(YLVL,'(I4)') JNC
     YFORM='(A10,I1.1,A10)'
     IF (JNC >= 10)  YFORM='(A10,I2.2,A10)'
     YRECFM='CANTD'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
     WRITE(YCOMMENT,FMT=YFORM) 'X_Y_CANTD',JNC,' (kgC/m2)'
     DO JP = 1,IO%NPATCH
        CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                      NP%AL(JP)%NR_P,NPE%AL(JP)%XCSTOCK_DECADAL(:,JNC),KI,S%XWORK_WR)    
     ENDDO
     YRECFM='CEXPD'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
     WRITE(YCOMMENT,FMT=YFORM) 'X_Y_CEXPD',JNC,' (kgC/m2/yr)'
     DO JP = 1,IO%NPATCH
        CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                      NP%AL(JP)%NR_P,NPE%AL(JP)%XEXPORT_DECADAL(:,JNC),KI,S%XWORK_WR)    
     ENDDO
  END DO
!
  DO JNC=1,IO%NNCENTURY
     WRITE(YLVL,'(I4)') JNC
     YFORM='(A10,I1.1,A10)'
     IF (JNC >= 10)   YFORM='(A10,I2.2,A10)'
     IF (JNC >= 100)  YFORM='(A10,I3.3,A10)'
     YRECFM='CANTC'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
     WRITE(YCOMMENT,FMT=YFORM) 'X_Y_CANTC',JNC,' (kgC/m2)'
     DO JP = 1,IO%NPATCH
        CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                      NP%AL(JP)%NR_P,NPE%AL(JP)%XCSTOCK_CENTURY(:,JNC),KI,S%XWORK_WR)    
     ENDDO
     YRECFM='CEXPC'//ADJUSTL(YLVL(:LEN_TRIM(YLVL)))
     WRITE(YCOMMENT,FMT=YFORM) 'X_Y_CEXPC',JNC,' (kgC/m2/yr)'
     DO JP = 1,IO%NPATCH
        CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                      NP%AL(JP)%NR_P,NPE%AL(JP)%XEXPORT_CENTURY(:,JNC),KI,S%XWORK_WR)    
     ENDDO
  END DO
END IF
!
!-------------------------------------------------------------------------------
!
!*       8.  Other
!            ----------------
!
! * Dust
!
IF (CHI%SVI%NDSTEQ > 0)THEN
  DO JSV = 1,NDSTMDE ! for all dust modes
    WRITE(YRECFM,'(A6,I3.3)')'F_DSTM',JSV
    YCOMMENT='X_Y_'//YRECFM//' (kg/m2)'
    DO JP = 1,IO%NPATCH
      CALL WRITE_FIELD_1D_PATCH(HSELECT,HPROGRAM,YRECFM,YCOMMENT,JP,&
                      NP%AL(JP)%NR_P,NDST%AL(JP)%XSFDSTM(:,JSV),KI,S%XWORK_WR)    
    ENDDO     
  END DO
ENDIF
!
!-------------------------------------------------------------------------------

!*       9.  Time
!            ----
!
YRECFM='DTCUR'
YCOMMENT='s'
 CALL WRITE_SURF(HSELECT,HPROGRAM,YRECFM,S%TTIME,IRESP,HCOMMENT=YCOMMENT)
!
IF (LHOOK) CALL DR_HOOK('WRITESURF_ISBA_N',1,ZHOOK_HANDLE)
!
!-------------------------------------------------------------------------------
!
END SUBROUTINE WRITESURF_ISBA_n
