!SFX_LIC Copyright 1994-2014 CNRS, Meteo-France and Universite Paul Sabatier
!SFX_LIC This is part of the SURFEX software governed by the CeCILL-C licence
!SFX_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!SFX_LIC for details. version 1.
!     #########################
      SUBROUTINE WRITE_BLD_DESCRIPTION_n (HSELECT, BDD, HPROGRAM)
!     #########################
!
!!
!!    PURPOSE
!!    -------
!!
!!    METHOD
!!    ------
!!
!!
!!    EXTERNAL
!!    --------
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!
!!    REFERENCE
!!    ---------
!!
!!    AUTHOR
!!    ------
!!
!!    V. Masson        Meteo-France
!!
!!    MODIFICATION
!!    ------------
!!
!!    Original    05/2012 
!
!----------------------------------------------------------------------------
!
!*    0.     DECLARATION
!            -----------
!
USE MODD_SURF_PAR, ONLY : XUNDEF
!
USE MODD_BLD_DESCRIPTION_n, ONLY : BLD_DESC_t
!
USE MODI_WRITE_SURF
USE MODI_ABOR1_SFX
!
!
USE YOMHOOK   ,ONLY : LHOOK,   DR_HOOK
USE PARKIND1  ,ONLY : JPRB
!
IMPLICIT NONE
!
!*    0.1    Declaration of arguments
!            ------------------------
!
 CHARACTER(LEN=*), DIMENSION(:), INTENT(IN) :: HSELECT
!
TYPE(BLD_DESC_t), INTENT(INOUT) :: BDD
!
 CHARACTER(LEN=6),  INTENT(IN) :: HPROGRAM
!
!
!*    0.2    Declaration of local variables
!      ------------------------------
!
REAL(KIND=JPRB) :: ZHOOK_HANDLE
!
REAL, DIMENSION(:), ALLOCATABLE :: ZWORK
INTEGER                         :: IRESP
INTEGER                         :: I1, I2
INTEGER                         :: JL
INTEGER                         :: ITOT
CHARACTER(LEN=100)              :: YCOMMENT
!
!-------------------------------------------------------------------------------
!-------------------------------------------------------------------------------
!
IF (LHOOK) CALL DR_HOOK('WRITE_BLD_DESCRIPTION_n',0,ZHOOK_HANDLE)
!
!-------------------------------------------------------------------------------
!
!*    1.   Writes configuration variables of the descriptive data
!          ------------------------------------------------------
!
ALLOCATE(ZWORK(14))
ZWORK(:)=XUNDEF
!
I1=1
ZWORK(I1) = FLOAT(BDD%NDESC_BLD);I1=I1+1
ZWORK(I1) = FLOAT(BDD%NDESC_AGE);I1=I1+1
ZWORK(I1) = FLOAT(BDD%NDESC_USE);I1=I1+1
ZWORK(I1) = FLOAT(BDD%NDESC_TER);I1=I1+1
ZWORK(I1) = FLOAT(BDD%NDESC_CODE);I1=I1+1
ZWORK(I1) = FLOAT(BDD%NDESC_NDAY_SCHED);I1=I1+1
ZWORK(I1) = FLOAT(BDD%NDESC_NCRE_SCHED);I1=I1+1
ZWORK(I1) = FLOAT(BDD%NDESC_HOLIDAY);I1=I1+1
ZWORK(I1) = FLOAT(BDD%NDESC_CONDP);I1=I1+1  
ZWORK(I1) = FLOAT(BDD%NDESC_WALL_LAYER);I1=I1+1
ZWORK(I1) = FLOAT(BDD%NDESC_ROOF_LAYER);I1=I1+1
ZWORK(I1) = FLOAT(BDD%NDESC_ROAD_LAYER);I1=I1+1
ZWORK(I1) = FLOAT(BDD%NDESC_FLOOR_LAYER);I1=I1+1
ZWORK(I1) = FLOAT(BDD%NDESC_MASS_LAYER)
!
IF (SIZE(ZWORK).NE.I1) CALL ABOR1_SFX("Error in write of building description")
!
YCOMMENT='Configuration numbers for descriptive building data'
 CALL WRITE_SURF(HSELECT, HPROGRAM,'BLD_DESC_CNF',ZWORK,IRESP,YCOMMENT,'-','Bld_dimensions  ')
DEALLOCATE(ZWORK)
!
!-------------------------------------------------------------------------------
!  
! 2.  Write positions of building type, use, construction period and material territory
!     -----------------------------------------------------------------------
!
ALLOCATE(ZWORK(BDD%NDESC_BLD+BDD%NDESC_AGE+BDD%NDESC_USE+5))
ZWORK(:) = XUNDEF
!
I1=1
ZWORK(I1) = BDD%NDESC_POS_TYP_PD  ;I1=I1+1   
ZWORK(I1) = BDD%NDESC_POS_TYP_PSC ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_TYP_PCIO;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_TYP_PCIF;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_TYP_ID  ;I1=I1+1 
ZWORK(I1) = BDD%NDESC_POS_TYP_ICIO;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_TYP_ICIF;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_TYP_BGH ;I1=I1+1 
ZWORK(I1) = BDD%NDESC_POS_TYP_BA  ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_TYP_LOCA;I1=I1+1     
ZWORK(I1) = BDD%NDESC_POS_USE_AGR ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_USE_CHA ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_USE_COM ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_USE_HAC ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_USE_HAI ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_USE_IND ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_USE_LNC ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_USE_REL ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_USE_SAN ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_USE_ENS ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_USE_SER ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_USE_SPO ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_USE_TER ;I1=I1+1    
ZWORK(I1) = BDD%NDESC_POS_AGE_P1  ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_AGE_P2  ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_AGE_P3  ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_AGE_P4  ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_AGE_P5  ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_AGE_P6  ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_AGE_P7  ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_PX_DEFAULT ;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_HAI_FORTCRE;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_HAI_FAIBCRE;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_HAC_FORTCRE;I1=I1+1
ZWORK(I1) = BDD%NDESC_POS_HAC_FAIBCRE
!
IF (SIZE(ZWORK).NE.(I1)) CALL ABOR1_SFX("Error in write of building description")
!
YCOMMENT='Positions for descriptive building data'
 CALL WRITE_SURF(HSELECT, HPROGRAM,'BLD_DESC_POS',ZWORK,IRESP,YCOMMENT,'-','Bld_positions   ')
DEALLOCATE(ZWORK)
!
!-------------------------------------------------------------------------------
!
!*    3.   Writes descriptive data
!          -----------------------
!
ITOT = BDD%NDESC_CODE * ( 27 + 3 * BDD%NDESC_ROOF_LAYER  + 3 * BDD%NDESC_ROAD_LAYER    + &
       3 * BDD%NDESC_WALL_LAYER + 3 * BDD%NDESC_FLOOR_LAYER + 3 * BDD%NDESC_MASS_LAYER ) + &
       3 * BDD%NDESC_CONDP                                                               + &
       39 * BDD%NDESC_USE                                                                + &
       BDD%NDESC_USE * (BDD%NDESC_NDAY_SCHED*BDD%NDESC_NCRE_SCHED + BDD%NDESC_NDAY_SCHED ) + &
       BDD%NDESC_USE * (2* BDD%NDESC_HOLIDAY + 1)                                        + &
       BDD%NDESC_USE * (BDD%NDESC_NDAY_SCHED*BDD%NDESC_NCRE_SCHED)
!
ALLOCATE(ZWORK(ITOT))
!
I1=0 ; I2=0
!
! Indices
!
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = FLOAT(BDD%NDESC_BLD_LIST(:))
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = FLOAT(BDD%NDESC_AGE_LIST(:))
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = FLOAT(BDD%NDESC_USE_LIST(:))
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = FLOAT(BDD%NDESC_TER_LIST(:))
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = FLOAT(BDD%NDESC_CODE_LIST(:))
!
! Building architectural characteristics
!
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_ALB_ROOF(:)
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_EMIS_ROOF(:)
DO JL=1,BDD%NDESC_ROOF_LAYER
   CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_HC_ROOF(:,JL)
END DO
DO JL=1,BDD%NDESC_ROOF_LAYER
   CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_TC_ROOF(:,JL)
END DO
DO JL=1,BDD%NDESC_ROOF_LAYER
   CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_D_ROOF (:,JL) 
END DO
!
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_ALB_ROAD(:)
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_EMIS_ROAD(:)
DO JL=1,BDD%NDESC_ROAD_LAYER
   CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_HC_ROAD(:,JL)
END DO
DO JL=1,BDD%NDESC_ROAD_LAYER
   CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_TC_ROAD(:,JL) 
END DO
DO JL=1,BDD%NDESC_ROAD_LAYER
   CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_D_ROAD (:,JL)
END DO
!
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_ALB_WALL(:)
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_EMIS_WALL(:)
DO JL=1,BDD%NDESC_WALL_LAYER
   CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_HC_WALL(:,JL)
END DO
DO JL=1,BDD%NDESC_WALL_LAYER
   CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_TC_WALL(:,JL) 
END DO
DO JL=1,BDD%NDESC_WALL_LAYER
   CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_D_WALL (:,JL)
END DO
!
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = FLOAT(BDD%NDESC_ISOROOFPOS(:))
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = FLOAT(BDD%NDESC_ISOWALLPOS(:))
!
DO JL=1,BDD%NDESC_FLOOR_LAYER
   CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_HC_FLOOR(:,JL)
END DO
DO JL=1,BDD%NDESC_FLOOR_LAYER
   CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_TC_FLOOR(:,JL) 
END DO
DO JL=1,BDD%NDESC_FLOOR_LAYER
   CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_D_FLOOR (:,JL)
END DO
!
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_ISMASS(:)
DO JL=1,BDD%NDESC_MASS_LAYER
   CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_HC_MASS(:,JL)
END DO
DO JL=1,BDD%NDESC_MASS_LAYER
   CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_TC_MASS(:,JL) 
END DO
DO JL=1,BDD%NDESC_MASS_LAYER
   CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_D_MASS (:,JL)
END DO
!
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_N50(:)
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_GR(:)
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_U_WIN(:)
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_SHGC(:)
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_SHGC_SH(:)
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_SHADEARCHI(:)
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_ISMECH(:)
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_MECHRATE(:)
!
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_GREENROOF(:)
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_EMIS_PANEL(:)
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_ALB_PANEL(:)
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_EFF_PANEL(:)
 CALL UP_DESC_IND_W(BDD%NDESC_CODE) ; ZWORK(I1:I2) = BDD%XDESC_FRAC_PANEL(:)
!
! Behavioural characteristics
!
 CALL UP_DESC_IND_W(BDD%NDESC_CONDP) ; ZWORK(I1:I2) = BDD%XDESC_FLDT(:)
 CALL UP_DESC_IND_W(BDD%NDESC_CONDP) ; ZWORK(I1:I2) = BDD%XDESC_FIDT(:)
 CALL UP_DESC_IND_W(BDD%NDESC_CONDP) ; ZWORK(I1:I2) = BDD%XDESC_FHDT(:)
!
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_THEAT_OCCD_AVG(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_THEAT_OCCN_AVG(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_THEAT_VCDD_AVG(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_THEAT_VCDN_AVG(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_THEAT_VCLD_AVG(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_FNOHEAT_AVG   (:)
!
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_THEAT_OCCD_MOD(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_THEAT_OCCN_MOD(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_THEAT_VCDD_MOD(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_THEAT_VCDN_MOD(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_THEAT_VCLD_MOD(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_FNOHEAT_MOD   (:)
!
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_TCOOL_OCCD(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_TCOOL_OCCN(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_TCOOL_VCDD(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_TCOOL_VCDN(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_TCOOL_VCLD(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_F_WATER_COND(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_F_WASTE_CAN(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_COP_RAT(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_HR_TARGET(:)
!
 CALL UP_DESC_IND_W(BDD%NDESC_USE)  ; ZWORK(I1:I2) = BDD%XDESC_QIN(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE)  ; ZWORK(I1:I2) = BDD%XDESC_QIN_ADDBEHAV(:)  
 CALL UP_DESC_IND_W(BDD%NDESC_USE)  ; ZWORK(I1:I2) = BDD%XDESC_QIN_FRAD(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE)  ; ZWORK(I1:I2) = BDD%XDESC_QIN_FLAT(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE)  ; ZWORK(I1:I2) = BDD%XDESC_MODQIN_VCD(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE)  ; ZWORK(I1:I2) = BDD%XDESC_MODQIN_VLD(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE)  ; ZWORK(I1:I2) = BDD%XDESC_MODQIN_NIG(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE)  ; ZWORK(I1:I2) = BDD%XDESC_HOTWAT(:)  
!
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_NATVENT(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_FVSUM(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_FVNIG(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_TDESV(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_FVVAC(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_FOPEN(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_FSSUM(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_FSNIG(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_FSVAC(:)
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_WIN_SW_MAX(:)
!
DO JL=1,BDD%NDESC_NDAY_SCHED
   CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_DAYWBEG_SCHED(:,JL)
ENDDO
!
DO JL=1,(BDD%NDESC_NDAY_SCHED*BDD%NDESC_NCRE_SCHED)
   CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_HOURBEG_SCHED(:,JL)
ENDDO
!
 CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_MOD_HOLIDAY(:)
!
DO JL=1,BDD%NDESC_HOLIDAY
   CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_BEG_HOLIDAY(:,JL)
ENDDO
!
DO JL=1,BDD%NDESC_HOLIDAY
   CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_END_HOLIDAY(:,JL)
ENDDO
!
DO JL=1,(BDD%NDESC_NDAY_SCHED*BDD%NDESC_NCRE_SCHED)
   CALL UP_DESC_IND_W(BDD%NDESC_USE) ; ZWORK(I1:I2) = BDD%XDESC_PROBOCC(:,JL)
ENDDO
!
YCOMMENT='Descriptive building data'
 CALL WRITE_SURF(HSELECT, HPROGRAM,'BLD_DESC_DAT',ZWORK,IRESP,YCOMMENT,'-','Bld_parameters  ')
!
DEALLOCATE(ZWORK)
!
IF (LHOOK) CALL DR_HOOK('WRITE_BLD_DESCRIPTION_n',1,ZHOOK_HANDLE)
!-------------------------------------------------------------------------------
CONTAINS
SUBROUTINE UP_DESC_IND_W(K)
INTEGER, INTENT(IN) :: K
I1=I2+1
I2=I2+K
END SUBROUTINE UP_DESC_IND_W
!-------------------------------------------------------------------------------
!
END SUBROUTINE WRITE_BLD_DESCRIPTION_n
