!SFX_LIC Copyright 1994-2014 CNRS, Meteo-France and Universite Paul Sabatier
!SFX_LIC This is part of the SURFEX software governed by the CeCILL-C licence
!SFX_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!SFX_LIC for details. version 1.
!     #####################
      MODULE MODD_CH_SURF_n
!     #####################
!
!!
!!    PURPOSE
!!    -------
!     
!   
!
!!
!!**  IMPLICIT ARGUMENTS
!!    ------------------
!!      None
!!
!!
!!    AUTHOR
!!    ------
!!  P. Tulet   *Meteo France*
!!
!!    MODIFICATIONS
!!    -------------
!!  16/07/03 (P. Tulet)  restructured for externalization
!!   10/2011 (S. Queguiner) Add CCH_EMIS
!!   06/2017 (M. Leriche) add CCH_BIOEMIS and LCH_BIOEMIS for MEGAN coupling activation
!------------------------------------------------------------------------------
!
!*       0.   DECLARATIONS
!             ------------
!
!
USE YOMHOOK   ,ONLY : LHOOK,   DR_HOOK
USE PARKIND1  ,ONLY : JPRB
!
IMPLICIT NONE

TYPE CH_SURF_t
!
  CHARACTER(LEN=4)              :: CCH_EMIS            ! Option for chemical emissions
                                                       ! 'NONE' : no emission
                                                       ! 'AGGR' : one aggregated value
                                                       !    for each specie and hour
                                                       ! 'SNAP' : from SNAP data using
                                                       !    potential emission & temporal profiles
  CHARACTER(LEN=4)              :: CCH_BIOEMIS         ! Option for MEGAN coupling activation
                                                       ! 'NONE' : no coupling with MEGAN
                                                       ! 'MEGA' : activate MEGAN coupling                                               
  CHARACTER(LEN=6), DIMENSION(:), POINTER :: CCH_NAMES ! NAME OF CHEMICAL
  CHARACTER(LEN=6), DIMENSION(:), POINTER :: CAER_NAMES ! NAME OF AEROSOL SPECIES
  CHARACTER(LEN=6), DIMENSION(:), POINTER :: CDSTNAMES ! NAME OF DUST SPECIES
  CHARACTER(LEN=6), DIMENSION(:), POINTER :: CSLTNAMES ! NAME OF SEA SALT SPECIES
                                                       ! SPECIES (FOR DIAG ONLY)
  CHARACTER(LEN=28)             :: CCHEM_SURF_FILE     ! name of general 
                                                       ! (chemical) purpose
                                                       ! ASCII input file
  REAL, DIMENSION(:), POINTER   :: XCONVERSION         ! emission unit 
                                                       ! conversion factor
  LOGICAL  :: LCH_SURF_EMIS                            ! T : chemical emissions
                                                       ! are used
  LOGICAL  :: LCH_EMIS                                 ! T : chemical emissions
                                                       ! are present in the file
  LOGICAL  :: LCH_BIOEMIS                              ! T : megan emissions
                                                       ! are present in the file
!
END TYPE CH_SURF_t



CONTAINS
!
SUBROUTINE CH_SURF_INIT(YCH_SURF)
TYPE(CH_SURF_t), INTENT(INOUT) :: YCH_SURF
REAL(KIND=JPRB) :: ZHOOK_HANDLE
IF (LHOOK) CALL DR_HOOK("MODD_CH_SURF_N:CH_SURF_INIT",0,ZHOOK_HANDLE)
  NULLIFY(YCH_SURF%CCH_NAMES)
  NULLIFY(YCH_SURF%CAER_NAMES)
  NULLIFY(YCH_SURF%XCONVERSION)
  NULLIFY(YCH_SURF%CDSTNAMES)
  NULLIFY(YCH_SURF%CSLTNAMES)
YCH_SURF%CCH_EMIS=' '
YCH_SURF%CCH_BIOEMIS=' '
YCH_SURF%CCHEM_SURF_FILE=' '
YCH_SURF%LCH_SURF_EMIS=.FALSE.
YCH_SURF%LCH_EMIS=.FALSE.
YCH_SURF%LCH_BIOEMIS=.FALSE.
IF (LHOOK) CALL DR_HOOK("MODD_CH_SURF_N:CH_SURF_INIT",1,ZHOOK_HANDLE)
END SUBROUTINE CH_SURF_INIT


END MODULE MODD_CH_SURF_n
