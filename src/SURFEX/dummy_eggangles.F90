!SFX_LIC Copyright 1994-2014 CNRS, Meteo-France and Universite Paul Sabatier
!SFX_LIC This is part of the SURFEX software governed by the CeCILL-C licence
!SFX_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!SFX_LIC for details. version 1.
MODULE EGGANGLES
USE PARKIND1  ,ONLY : JPIM,    JPRB
TYPE LOLA
  SEQUENCE
  REAL(KIND=JPRB) :: LON, LAT
END TYPE LOLA
INTERFACE ANGLE_DOMAIN
  MODULE PROCEDURE ANGLE_DOMAIN_RS, ANGLE_DOMAIN_LOLAS, ANGLE_DOMAIN_RV, ANGLE_DOMAIN_LOLAV
END INTERFACE
INTERFACE VAL_LAT
  MODULE PROCEDURE VAL_LAT_S, VAL_LAT_V
END INTERFACE
INTERFACE VAL_LON
  MODULE PROCEDURE VAL_LON_S, VAL_LON_V
END INTERFACE
INTERFACE VAL_COORD
  MODULE PROCEDURE VAL_COORD_S, VAL_COORD_V
END INTERFACE
INTERFACE LOLAD
  MODULE PROCEDURE LOLAD_S, LOLAD_V
END INTERFACE
INTERFACE LOLAR
  MODULE PROCEDURE LOLAR_S, LOLAR_V
END INTERFACE
INTERFACE MINIMAX
  MODULE PROCEDURE  MINIMAX_S, MINIMAX_V
END INTERFACE
INTERFACE COSIN_TO_ANGLE
  MODULE PROCEDURE COSIN_TO_ANGLE_S, COSIN_TO_ANGLE_V
END INTERFACE
INTERFACE P_ASIN
  MODULE PROCEDURE P_ASIN_S, P_ASIN_V
END INTERFACE
INTERFACE P_ACOS
  MODULE PROCEDURE P_ACOS_S, P_ACOS_V
END INTERFACE
INTERFACE DIST_2REF
  MODULE PROCEDURE DIST_2REF_S, DIST_2REF_V, DIST_2REF_L
END INTERFACE
INTERFACE SIZE_W2E
  MODULE PROCEDURE SIZE_W2E_S, SIZE_W2E_L
END INTERFACE

 CONTAINS
REAL(KIND=JPRB) FUNCTION ANGLE_DOMAIN_RS(ALPHA,PI,DOM,UNIT) RESULT (BETA)
REAL(KIND=JPRB), INTENT(IN)                           :: ALPHA
 CHARACTER (LEN=2), INTENT(IN), OPTIONAL               :: DOM
 CHARACTER (LEN=1), INTENT(IN), OPTIONAL               :: UNIT
REAL(KIND=JPRB), INTENT(IN), OPTIONAL                 :: PI
END FUNCTION ANGLE_DOMAIN_RS
TYPE (LOLA) FUNCTION ANGLE_DOMAIN_LOLAS(ALPHA,PI,DOM,UNIT) RESULT (BETA)
TYPE (LOLA), INTENT(IN)                                :: ALPHA
 CHARACTER (LEN=2), INTENT(IN), OPTIONAL                :: DOM
 CHARACTER (LEN=1), INTENT(IN), OPTIONAL                :: UNIT
REAL(KIND=JPRB), INTENT(IN), OPTIONAL                  :: PI
END FUNCTION ANGLE_DOMAIN_LOLAS
! -------------------------------------------------------------------------------
FUNCTION ANGLE_DOMAIN_RV(ALPHA,PI,DOM,UNIT) RESULT (BETA)
REAL(KIND=JPRB), DIMENSION(:), INTENT(IN)             :: ALPHA
 CHARACTER (LEN=2), INTENT(IN), OPTIONAL               :: DOM
 CHARACTER (LEN=1), INTENT(IN), OPTIONAL               :: UNIT
REAL(KIND=JPRB), INTENT(IN), OPTIONAL                 :: PI
END FUNCTION ANGLE_DOMAIN_RV
! -------------------------------------------------------------------------------
FUNCTION ANGLE_DOMAIN_LOLAV(YL_ALPHA,PI,DOM,UNIT) RESULT (YD_BETA)
TYPE (LOLA), DIMENSION(:), INTENT(IN)               :: YL_ALPHA
 CHARACTER (LEN=2), INTENT(IN), OPTIONAL             :: DOM
 CHARACTER (LEN=1), INTENT(IN), OPTIONAL             :: UNIT
REAL(KIND=JPRB), INTENT(IN), OPTIONAL               :: PI
END FUNCTION ANGLE_DOMAIN_LOLAV
! -------------------------------------------------------------------------------
INTEGER(KIND=JPIM) FUNCTION VAL_LAT_S(LAT,NUM_ERR,PI,UNIT) RESULT(ETAT)
REAL(KIND=JPRB), INTENT(IN)                          :: LAT
 CHARACTER (LEN=1), INTENT(IN), OPTIONAL              :: UNIT
REAL(KIND=JPRB), INTENT(IN), OPTIONAL                :: PI
INTEGER(KIND=JPIM), INTENT(IN), OPTIONAL             :: NUM_ERR
END FUNCTION VAL_LAT_S
! -------------------------------------------------------------------------------
INTEGER(KIND=JPIM) FUNCTION VAL_LAT_V(P_LAT,NUM_ERR,PI,UNIT) RESULT(ETAT)
REAL(KIND=JPRB), DIMENSION(:), INTENT(IN)                 :: P_LAT
 CHARACTER (LEN=1), INTENT(IN), OPTIONAL                   :: UNIT
REAL(KIND=JPRB), INTENT(IN), OPTIONAL                     :: PI
INTEGER(KIND=JPIM), INTENT(IN), OPTIONAL                  :: NUM_ERR
END FUNCTION VAL_LAT_V
! -------------------------------------------------------------------------------
INTEGER(KIND=JPIM) FUNCTION VAL_LON_S(LON,NUM_ERR,PI,DOM,UNIT) RESULT(ETAT)
REAL(KIND=JPRB), INTENT(IN)                                :: LON
 CHARACTER (LEN=2), INTENT(IN), OPTIONAL                    :: DOM
 CHARACTER (LEN=1), INTENT(IN), OPTIONAL                    :: UNIT
REAL(KIND=JPRB), INTENT(IN), OPTIONAL                      :: PI
INTEGER(KIND=JPIM), INTENT(IN), OPTIONAL                   :: NUM_ERR
END FUNCTION VAL_LON_S
! -------------------------------------------------------------------------------
INTEGER(KIND=JPIM) FUNCTION VAL_LON_V(LON,NUM_ERR,PI,DOM,UNIT) RESULT(ETAT)
REAL(KIND=JPRB), DIMENSION(:), INTENT(IN)                       :: LON
 CHARACTER (LEN=2), INTENT(IN), OPTIONAL                         :: DOM
 CHARACTER (LEN=1), INTENT(IN), OPTIONAL                         :: UNIT
REAL(KIND=JPRB), INTENT(IN), OPTIONAL                           :: PI
INTEGER(KIND=JPIM), INTENT(IN), OPTIONAL                        :: NUM_ERR
END FUNCTION VAL_LON_V
! -------------------------------------------------------------------------------
INTEGER(KIND=JPIM) FUNCTION VAL_COORD_S(PT_COORD,NUM_ERR,PI,DOM,UNIT) RESULT(ETAT)
TYPE (LOLA), INTENT(IN)                               :: PT_COORD
 CHARACTER (LEN=2), INTENT(IN), OPTIONAL               :: DOM
 CHARACTER (LEN=1), INTENT(IN), OPTIONAL               :: UNIT
REAL(KIND=JPRB), INTENT(IN), OPTIONAL                 :: PI
INTEGER(KIND=JPIM), INTENT(IN), OPTIONAL              :: NUM_ERR
END FUNCTION VAL_COORD_S
! -------------------------------------------------------------------------------
INTEGER(KIND=JPIM) FUNCTION VAL_COORD_V(YD_PT_COORD,K_NUM_ERR,PI,CD_DOM,CD_UNIT) RESULT(ETAT)
TYPE (LOLA), DIMENSION(:), INTENT(IN)                   :: YD_PT_COORD
 CHARACTER (LEN=2), INTENT(IN), OPTIONAL                 :: CD_DOM
 CHARACTER (LEN=1), INTENT(IN), OPTIONAL                 :: CD_UNIT
REAL(KIND=JPRB), INTENT(IN), OPTIONAL                   :: PI
INTEGER(KIND=JPIM), INTENT(IN), OPTIONAL                :: K_NUM_ERR
END FUNCTION VAL_COORD_V
! -------------------------------------------------------------------------------
TYPE(LOLA) FUNCTION LOLAR_S (COORD_DEG) RESULT (COORD_RAD)
! DEG => RAD for lola type
TYPE(LOLA), INTENT(IN)                      :: COORD_DEG
END FUNCTION LOLAR_S

FUNCTION LOLAR_V (COORD_DEG) RESULT (COORD_RAD)
! DEG => RAD for lola type
TYPE(LOLA), DIMENSION(:), INTENT(IN)                :: COORD_DEG

END FUNCTION LOLAR_V
! -------------------------------------------------------------------------------
TYPE(LOLA) FUNCTION LOLAD_S (COORD_RAD) RESULT (COORD_DEG)
! RAD => DEG for lola type
TYPE(LOLA), INTENT(IN)                      :: COORD_RAD
END FUNCTION LOLAD_S

FUNCTION LOLAD_V (COORD_RAD) RESULT (COORD_DEG)
! RAD => DEG for lola type
TYPE(LOLA), DIMENSION(:), INTENT(IN)                :: COORD_RAD
END FUNCTION LOLAD_V
! -------------------------------------------------------------------------------
REAL(KIND=JPRB) FUNCTION COSIN_TO_ANGLE_S(COSINUS,SINUS) RESULT (ANGLE)
! (Cosinus,Sinus) => Angle
REAL(KIND=JPRB), INTENT(IN)                  :: COSINUS,SINUS
END FUNCTION COSIN_TO_ANGLE_S

FUNCTION COSIN_TO_ANGLE_V(COSINUS,SINUS) RESULT (ANGLE)
! (Cosinus,Sinus) => Angle
REAL(KIND=JPRB), DIMENSION(:), INTENT(IN)              :: COSINUS,SINUS
END FUNCTION COSIN_TO_ANGLE_V
! -------------------------------------------------------------------------------
REAL(KIND=JPRB) FUNCTION P_ACOS_S(COSINUS) RESULT (ANGLE)
! Protected ACOS
REAL(KIND=JPRB), INTENT(IN)                  :: COSINUS
END FUNCTION P_ACOS_S

FUNCTION P_ACOS_V(COSINUS) RESULT (ANGLE)
! Protected ACOS
REAL(KIND=JPRB), DIMENSION(:), INTENT(IN)              :: COSINUS
END FUNCTION P_ACOS_V
! -------------------------------------------------------------------------------
REAL(KIND=JPRB) FUNCTION P_ASIN_S(SINUS) RESULT (ANGLE)
! Protected ASIN
REAL(KIND=JPRB), INTENT(IN)                  :: SINUS
END FUNCTION P_ASIN_S

FUNCTION P_ASIN_V(SINUS) RESULT (ANGLE)
! Protected ASIN
REAL(KIND=JPRB), DIMENSION(:), INTENT(IN)            :: SINUS
END FUNCTION P_ASIN_V
REAL(KIND=JPRB) FUNCTION MINIMAX_S(VAL,LIM) RESULT (VALO)
! Return Value in [-LIM,LIM]
REAL(KIND=JPRB), INTENT(IN)                      :: VAL
REAL(KIND=JPRB), INTENT(IN), OPTIONAL            :: LIM
END FUNCTION MINIMAX_S
FUNCTION MINIMAX_V(VAL,LIM) RESULT (VALO)
! Return Value in [-LIM,LIM]
REAL(KIND=JPRB), DIMENSION(:), INTENT(IN)          :: VAL
REAL(KIND=JPRB), INTENT(IN), OPTIONAL              :: LIM
REAL(KIND=JPRB), DIMENSION(SIZE(VAL)) :: VALO
END FUNCTION MINIMAX_V
! -------------------------------------------------------------------------------
REAL(KIND=JPRB) FUNCTION DIST_2REF_L(COORD_LON,REF_LON,PI) RESULT(DIST)
REAL(KIND=JPRB), INTENT(IN)                   :: COORD_LON, REF_LON
REAL(KIND=JPRB), INTENT(IN), OPTIONAL         :: PI       
END FUNCTION DIST_2REF_L
! -------------------------------------------------------------------------------
REAL(KIND=JPRB) FUNCTION DIST_2REF_S(PT_COORD,REF_COORD,PI) RESULT(DIST)

TYPE (LOLA), INTENT(IN)                       :: PT_COORD, REF_COORD
REAL(KIND=JPRB), INTENT(IN), OPTIONAL         :: PI 
END FUNCTION DIST_2REF_S
! -------------------------------------------------------------------------------
FUNCTION DIST_2REF_V(PT_COORD,REF_COORD,PI) RESULT(DIST)
TYPE (LOLA), DIMENSION(:), INTENT(IN)                   :: PT_COORD
TYPE (LOLA), INTENT(IN)                                 :: REF_COORD
REAL(KIND=JPRB), INTENT(IN), OPTIONAL                   :: PI 
REAL(KIND=JPRB), DIMENSION(SIZE(PT_COORD)) :: DIST
END FUNCTION DIST_2REF_V
! -------------------------------------------------------------------------------
REAL(KIND=JPRB) FUNCTION SIZE_W2E_L(WEST_LON,EAST_LON,PI) RESULT(TAILLE)
REAL(KIND=JPRB), INTENT(IN)                   :: WEST_LON, EAST_LON
REAL(KIND=JPRB), INTENT(IN), OPTIONAL         :: PI 
END FUNCTION SIZE_W2E_L
! -------------------------------------------------------------------------------
REAL(KIND=JPRB) FUNCTION SIZE_W2E_S(WEST_COORD,EAST_COORD,PI) RESULT(TAILLE)
TYPE (LOLA), INTENT(IN)                       :: WEST_COORD, EAST_COORD
REAL(KIND=JPRB), INTENT(IN), OPTIONAL         :: PI 
END FUNCTION SIZE_W2E_S
! -------------------------------------------------------------------------------
END MODULE EGGANGLES      
