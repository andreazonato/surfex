!SFX_LIC Copyright 1994-2014 CNRS, Meteo-France and Universite Paul Sabatier
!SFX_LIC This is part of the SURFEX software governed by the CeCILL-C licence
!SFX_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!SFX_LIC for details. version 1.
MODULE MODD_SLT_n
!
!Purpose: 
!Declare variables and constants necessary to do the sea salt calculations
!Here are only the variables which depend on the grid!
!
!Author: Alf Grini / Pierre Tulet
!
! MODIFICATIONS
!
!!      Bielli S. 02/2019  Sea salt : significant sea wave height influences salt emission; 5 salt modes
!
USE YOMHOOK   ,ONLY : LHOOK,   DR_HOOK
USE PARKIND1  ,ONLY : JPRB
!
IMPLICIT NONE
!
TYPE SLT_t
! ++ PIERRE / MARINE SSA DUST - MODIF ++
!  REAL, DIMENSION(:,:,:),POINTER :: XSFSLT                      ! Sea Salt variables to be send to output
! -- PIERRE / MARINE SSA DUST - MODIF --
  REAL,DIMENSION(:), POINTER     :: XEMISRADIUS_SLT             ! Number median radius for each source mode
  REAL,DIMENSION(:), POINTER     :: XEMISSIG_SLT                ! sigma for each source mode
END TYPE SLT_t
!
CONTAINS
!
SUBROUTINE SLT_INIT(YSLT)
TYPE(SLT_t), INTENT(INOUT) :: YSLT
REAL(KIND=JPRB) :: ZHOOK_HANDLE
IF (LHOOK) CALL DR_HOOK("MODD_SLT_N:SLT_INIT",0,ZHOOK_HANDLE)
! ++ PIERRE / MARINE SSA DUST - MODIF ++
!  NULLIFY(YSLT%XSFSLT)
! -- PIERRE / MARINE SSA DUST - MODIF --
  NULLIFY(YSLT%XEMISRADIUS_SLT)
  NULLIFY(YSLT%XEMISSIG_SLT)
IF (LHOOK) CALL DR_HOOK("MODD_SLT_N:SLT_INIT",1,ZHOOK_HANDLE)
END SUBROUTINE SLT_INIT
!
END MODULE MODD_SLT_n
