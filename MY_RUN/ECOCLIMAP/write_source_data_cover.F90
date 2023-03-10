#ifdef RS6K
@PROCESS NOOPTIMIZE
#endif
!     #########################
      PROGRAM WRITE_SOURCE_DATA_COVER
!     #########################
!
!!**** *WRITE_SOURCE_DATA_COVER* writes cover-field correspondance arrays in a file
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
!!    Original    
!----------------------------------------------------------------------------
!
!*    0.     DECLARATION
!            -----------
!
IMPLICIT NONE
!
!*    0.1    Declaration of arguments
!            ------------------------
!
!*    0.2    Declaration of local variables
!            ------------------------------
!
INTEGER, PARAMETER             :: JPCOVER   =573 ! number of cover types
INTEGER, PARAMETER             :: NVEGTYPE  =19  ! number of vegtypes
INTEGER, PARAMETER             :: NECOCLIMAP=2   ! number of ecoclimap data files
INTEGER, PARAMETER             :: NECO2_START_YEAR=2002
INTEGER, PARAMETER             :: NECO2_END_YEAR=2006
REAL*8,  PARAMETER             :: XUNDEF    =1.E20
INTEGER, PARAMETER             :: NUNDEF    =1E9
INTEGER, PARAMETER             :: NDATA_ROOF_LAYER=3
INTEGER, PARAMETER             :: NDATA_ROAD_LAYER=3
INTEGER, PARAMETER             :: NDATA_WALL_LAYER=3


REAL*8, DIMENSION(JPCOVER) :: XDATA_TOWN, XDATA_NATURE, XDATA_SEA, XDATA_WATER,       &
                                  XDATA_Z0_TOWN, XDATA_BLD_HEIGHT, XDATA_WALL_O_HOR,&
                                  XDATA_BLD, XDATA_GARDEN,                          &
                                  XDATA_ALB_ROOF, XDATA_ALB_ROAD, XDATA_ALB_WALL,   &
                                  XDATA_EMIS_ROOF, XDATA_EMIS_ROAD, XDATA_EMIS_WALL,&
                                  XDATA_H_TRAFFIC, XDATA_LE_TRAFFIC,                &
                                  XDATA_H_INDUSTRY, XDATA_LE_INDUSTRY
REAL*8, DIMENSION(JPCOVER,NDATA_ROOF_LAYER) :: XDATA_HC_ROOF, XDATA_TC_ROOF, XDATA_D_ROOF
REAL*8, DIMENSION(JPCOVER,NDATA_ROAD_LAYER) :: XDATA_HC_ROAD, XDATA_TC_ROAD, XDATA_D_ROAD
REAL*8, DIMENSION(JPCOVER,NDATA_WALL_LAYER) :: XDATA_HC_WALL, XDATA_TC_WALL, XDATA_D_WALL
REAL*8, DIMENSION(JPCOVER,NVEGTYPE)    :: XDATA_VEGTYPE, XDATA_H_TREE, XDATA_WATSUP, XDATA_IRRIG, &
                                        XDATA_ROOT_DEPTH, XDATA_GROUND_DEPTH, XDATA_DICE
REAL*8, DIMENSION(JPCOVER,36,  NVEGTYPE) :: XDATA_LAI
REAL*8, DIMENSION(JPCOVER,5*36,NVEGTYPE) :: XDATA_LAI_ALL_YEARS
INTEGER*4, DIMENSION(JPCOVER,NVEGTYPE) :: IDATA_SEED_MONTH, IDATA_REAP_MONTH, &
                                          IDATA_SEED_DAY  , IDATA_REAP_DAY  
!
REAL*8, DIMENSION(JPCOVER,36,NVEGTYPE) ::  XDATA_ALB_VEG_NIR  ! near infra-red albedo
REAL*8, DIMENSION(JPCOVER,36,NVEGTYPE) ::  XDATA_ALB_VEG_VIS  ! visible albedo
REAL*8, DIMENSION(JPCOVER,36,NVEGTYPE) ::  XDATA_ALB_SOIL_NIR ! near infra-red albedo
REAL*8, DIMENSION(JPCOVER,36,NVEGTYPE) ::  XDATA_ALB_SOIL_VIS ! visible albedo
!

INTEGER, DIMENSION(NECOCLIMAP) :: NBCOVERS, NBAN, NUNIT
INTEGER         :: IECO         ! file being read
INTEGER         :: ICOVER       ! cover being read
INTEGER         :: JCOVER       ! loop counters on covers
INTEGER         :: J            ! loop counters on decades
INTEGER         :: JYEAR        ! loop counters on years
INTEGER         :: JL           ! loop counters on layers
INTEGER         :: JVEGTYPE     ! loop counters on vegtypes
CHARACTER(LEN=28):: YFILE       ! file name
CHARACTER(LEN=28):: YNAME       ! subroutine name
CHARACTER(LEN=30)::YMASK
INTEGER         :: IREC
INTEGER         :: IUNIT
REAL*8, DIMENSION(JPCOVER) :: ZSEED
REAL*8, DIMENSION(36) :: ZLAI
REAL*8                :: ZEXP
!
INTEGER         :: IOUT
!-------------------------------------------------------------------------------
!
!*    1.0    Open binary files
!            -----------------
!
!
NUNIT(1)=11
OPEN(NUNIT(1),FILE='ecoclimapI_covers_param.bin',FORM='UNFORMATTED',ACCESS='DIRECT',recl=20*8)
NBCOVERS(1) = 255
NBAN(1) = 1
!
NUNIT(2)=12
OPEN(NUNIT(2),FILE='ecoclimapII_eu_covers_param.bin',FORM='UNFORMATTED',ACCESS='DIRECT',recl=20*8)
NBCOVERS(2) = 273
NBAN(2) = 5
!
!-------------------------------------------------------------------------------
!
!*    1.1    Open output fortran file
!            ------------------------
!
OPEN(20,FILE='test/default_data_cover.F90',FORM='FORMATTED')
!
!------------------------------------------------------------------------------
!
!
!*    2.0    Initializes data
!            ----------------
!
XDATA_TOWN        = 0.
XDATA_NATURE      = 0.
XDATA_SEA         = 0.
XDATA_WATER       = 0.
XDATA_Z0_TOWN     = XUNDEF
XDATA_BLD_HEIGHT  = XUNDEF
XDATA_WALL_O_HOR  = XUNDEF
XDATA_BLD         = XUNDEF
XDATA_GARDEN      = 0.
XDATA_ALB_ROOF    = XUNDEF
XDATA_ALB_ROAD    = XUNDEF
XDATA_ALB_WALL    = XUNDEF
XDATA_EMIS_ROOF   = XUNDEF
XDATA_EMIS_ROAD   = XUNDEF
XDATA_EMIS_WALL   = XUNDEF
XDATA_HC_ROOF     = XUNDEF
XDATA_HC_ROAD     = XUNDEF
XDATA_HC_WALL     = XUNDEF
XDATA_TC_ROOF     = XUNDEF
XDATA_TC_ROAD     = XUNDEF
XDATA_TC_WALL     = XUNDEF
XDATA_D_ROOF      = XUNDEF
XDATA_D_ROAD      = XUNDEF
XDATA_D_WALL      = XUNDEF
XDATA_H_TRAFFIC   = XUNDEF
XDATA_LE_TRAFFIC  = XUNDEF
XDATA_H_INDUSTRY  = XUNDEF
XDATA_LE_INDUSTRY = XUNDEF
!
XDATA_VEGTYPE(:,:)      = 0.
XDATA_H_TREE(:,:)       = XUNDEF
XDATA_WATSUP(:,:)       = XUNDEF
XDATA_IRRIG(:,:)        = XUNDEF
XDATA_ROOT_DEPTH(:,:)   = XUNDEF
XDATA_GROUND_DEPTH(:,:) = XUNDEF
XDATA_DICE(:,:)         = XUNDEF

XDATA_LAI(:,:,:) = XUNDEF
XDATA_LAI_ALL_YEARS(:,:,:) = XUNDEF
IDATA_SEED_MONTH(:,:) = 1E9
IDATA_SEED_DAY  (:,:) = 1E9
IDATA_REAP_MONTH(:,:) = 1E9
IDATA_REAP_DAY  (:,:) = 1E9

XDATA_ALB_VEG_NIR  = XUNDEF
XDATA_ALB_VEG_VIS  = XUNDEF
XDATA_ALB_SOIL_NIR = XUNDEF
XDATA_ALB_SOIL_VIS = XUNDEF

!------------------------------------------------------------------------------
!
!
!*    3.0    Read data in binary files
!            -------------------------
!
DO IECO=1,NECOCLIMAP
 IUNIT=NUNIT(IECO)
 IREC = 0
 DO JCOVER=1,NBCOVERS(IECO)
  IREC = IREC+1
  READ(IUNIT,REC=IREC) ICOVER
  IREC = IREC+1
  READ(IUNIT,REC=IREC) XDATA_TOWN(ICOVER),XDATA_NATURE(ICOVER),XDATA_WATER(ICOVER),XDATA_SEA(ICOVER)

  IF (XDATA_NATURE(ICOVER).GT.0.) CALL READ_NATURE

  IF (XDATA_TOWN(ICOVER).NE.0.) THEN
    !main town parameters
    IREC=IREC+1
    READ(IUNIT,REC=IREC) XDATA_Z0_TOWN(ICOVER),XDATA_BLD_HEIGHT(ICOVER),XDATA_WALL_O_HOR(ICOVER),&
        XDATA_BLD(ICOVER),XDATA_GARDEN(ICOVER)
    !town albedos
    IREC=IREC+1
    READ(IUNIT,rec=IREC) XDATA_ALB_ROOF(ICOVER),XDATA_ALB_ROAD(ICOVER),XDATA_ALB_WALL(ICOVER)
    !town emissivities
    IREC=IREC+1
    READ(IUNIT,rec=IREC) XDATA_EMIS_ROOF(ICOVER),XDATA_EMIS_ROAD(ICOVER),XDATA_EMIS_WALL(ICOVER)
    !town heat capacity
    IREC=IREC+1
    READ(IUNIT,rec=IREC) XDATA_HC_ROOF(ICOVER,:)
    IREC=IREC+1
    READ(IUNIT,rec=IREC) XDATA_HC_ROAD(ICOVER,:)
    IREC=IREC+1
    READ(IUNIT,rec=IREC) XDATA_HC_WALL(ICOVER,:)
    !town thermal conductivity
    IREC=IREC+1
    READ(IUNIT,rec=IREC) XDATA_TC_ROOF(ICOVER,:)
    IREC=IREC+1
    READ(IUNIT,rec=IREC) XDATA_TC_ROAD(ICOVER,:)
    IREC=IREC+1
    READ(IUNIT,rec=IREC) XDATA_TC_WALL(ICOVER,:)
    !town depths
    IREC=IREC+1
    READ(IUNIT,rec=IREC) XDATA_D_ROOF(ICOVER,:)
    IREC=IREC+1
    READ(IUNIT,rec=IREC) XDATA_D_ROAD(ICOVER,:)
    IREC=IREC+1
    READ(IUNIT,rec=IREC) XDATA_D_WALL(ICOVER,:)
    !traffic and industry fluxes
    IREC=IREC+1
    READ(IUNIT,rec=IREC) XDATA_H_TRAFFIC(ICOVER),XDATA_LE_TRAFFIC(ICOVER),XDATA_H_INDUSTRY(ICOVER),XDATA_LE_INDUSTRY(ICOVER)
    IF (XDATA_GARDEN(ICOVER).NE.0. .AND. XDATA_NATURE(ICOVER).EQ.0.) CALL READ_NATURE
  ENDIF

 END DO
END DO
!
!------------------------------------------------------------------------------
!
!
!*    4.0    Writes the data in the output fortran file
!            ------------------------------------------
!
CALL WRITE_HEADER('DEFAULT_DATA_COVER')
WRITE(20,FMT='(A)') 'IF (LHOOK) CALL DR_HOOK(''DEFAULT_DATA_COVER'',0,ZHOOK_HANDLE) '  
WRITE(20,FMT='(A)')'!'
!
CALL WRITE_SOURCE_DATA_A(IUNIT,'ALL',4,'F4.2','XDATA_TOWN          ',XDATA_TOWN(:))
CALL WRITE_SOURCE_DATA_A(IUNIT,'ALL',4,'F4.2','XDATA_NATURE        ',XDATA_NATURE(:))
CALL WRITE_SOURCE_DATA_A(IUNIT,'ALL',4,'F4.2','XDATA_WATER         ',XDATA_WATER(:))
CALL WRITE_SOURCE_DATA_A(IUNIT,'ALL',4,'F4.2','XDATA_SEA           ',XDATA_SEA(:))
!
CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',6,'F6.3','XDATA_Z0_TOWN       ',XDATA_Z0_TOWN(:))
CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',6,'F6.0','XDATA_BLD_HEIGHT    ',XDATA_BLD_HEIGHT(:))
CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',4,'F4.2','XDATA_WALL_O_HOR    ',XDATA_WALL_O_HOR(:))
CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',4,'F4.2','XDATA_BLD           ',XDATA_BLD(:))
CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',4,'F4.2','XDATA_GARDEN        ',XDATA_GARDEN(:))
CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',4,'F4.2','XDATA_ALB_ROOF      ',XDATA_ALB_ROOF(:))
CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',4,'F4.2','XDATA_ALB_ROAD      ',XDATA_ALB_ROAD(:))
CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',4,'F4.2','XDATA_ALB_WALL      ',XDATA_ALB_WALL(:))
CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',4,'F4.2','XDATA_EMIS_ROOF     ',XDATA_EMIS_ROOF(:))
CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',4,'F4.2','XDATA_EMIS_ROAD     ',XDATA_EMIS_ROAD(:))
CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',4,'F4.2','XDATA_EMIS_WALL     ',XDATA_EMIS_WALL(:))
!
ZEXP = 1.E-6
DO JL=1,SIZE(XDATA_HC_ROOF,2)
  CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',4,'F4.2','XDATA_HC_ROOF       ',XDATA_HC_ROOF(:,JL),KIND1=JL, &
  PEXP=ZEXP,HEXP=' * 1.E6')
END DO
DO JL=1,SIZE(XDATA_HC_ROOF,2)
  CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',6,'F6.4','XDATA_TC_ROOF       ',XDATA_TC_ROOF(:,JL),KIND1=JL)
END DO
DO JL=1,SIZE(XDATA_HC_ROOF,2)
  CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',5,'F5.3','XDATA_D_ROOF        ',XDATA_D_ROOF(:,JL),KIND1=JL)
END DO
DO JL=1,SIZE(XDATA_HC_ROAD,2)
  CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',4,'F4.2','XDATA_HC_ROAD       ',XDATA_HC_ROAD(:,JL),KIND1=JL, &
  PEXP=ZEXP,HEXP=' * 1.E6')
END DO
DO JL=1,SIZE(XDATA_HC_ROAD,2)
  CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',6,'F6.4','XDATA_TC_ROAD       ',XDATA_TC_ROAD(:,JL),KIND1=JL)
END DO
DO JL=1,SIZE(XDATA_HC_ROAD,2)
  CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',5,'F5.3','XDATA_D_ROAD        ',XDATA_D_ROAD(:,JL),KIND1=JL)
END DO
DO JL=1,SIZE(XDATA_HC_WALL,2)
  CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',4,'F4.2','XDATA_HC_WALL       ',XDATA_HC_WALL(:,JL),KIND1=JL, &
  PEXP=ZEXP,HEXP=' * 1.E6')
END DO
DO JL=1,SIZE(XDATA_HC_WALL,2)
  CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',6,'F6.4','XDATA_TC_WALL       ',XDATA_TC_WALL(:,JL),KIND1=JL)
END DO
DO JL=1,SIZE(XDATA_HC_WALL,2)
  CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',5,'F5.3','XDATA_D_WALL        ',XDATA_D_WALL(:,JL),KIND1=JL)
END DO
!
CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',6,'F6.0','XDATA_H_TRAFFIC     ',XDATA_H_TRAFFIC(:))
CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',6,'F6.0','XDATA_LE_TRAFFIC    ',XDATA_LE_TRAFFIC(:))
CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',6,'F6.0','XDATA_H_INDUSTRY    ',XDATA_H_INDUSTRY(:))
CALL WRITE_SOURCE_DATA_B(IUNIT,'XDATA_TOWN>0.',6,'F6.0','XDATA_LE_INDUSTRY   ',XDATA_LE_INDUSTRY(:))
!
DO JL=1,NVEGTYPE
  CALL WRITE_SOURCE_DATA_A(IUNIT,'XDATA_NATURE>0.',4,'F4.2','XDATA_VEGTYPE       ',XDATA_VEGTYPE(:,JL),KIND1=JL)
END DO
DO JL=1,NVEGTYPE
  WRITE(YMASK,FMT='(A,I2,A)') 'XDATA_VEGTYPE(:,',JL,')>0.'
  CALL WRITE_SOURCE_DATA_A(IUNIT,YMASK,5,'F5.0','XDATA_H_TREE        ',XDATA_H_TREE(:,JL),KIND1=JL)
END DO
DO JL=1,NVEGTYPE
  WRITE(YMASK,FMT='(A,I2,A)') 'XDATA_VEGTYPE(:,',JL,')>0.'
  CALL WRITE_SOURCE_DATA_A(IUNIT,YMASK,4,'F4.0','XDATA_WATSUP        ',XDATA_WATSUP(:,JL),KIND1=JL)
END DO
DO JL=1,NVEGTYPE
  WRITE(YMASK,FMT='(A,I2,A)') 'XDATA_VEGTYPE(:,',JL,')>0.'
  CALL WRITE_SOURCE_DATA_A(IUNIT,YMASK,4,'F4.2','XDATA_IRRIG         ',XDATA_IRRIG(:,JL),KIND1=JL)
END DO
DO JL=1,NVEGTYPE
  WRITE(YMASK,FMT='(A,I2,A)') 'XDATA_VEGTYPE(:,',JL,')>0.'
  CALL WRITE_SOURCE_DATA_A(IUNIT,YMASK,4,'F4.2','XDATA_ROOT_DEPTH    ',XDATA_ROOT_DEPTH(:,JL),KIND1=JL)
END DO
DO JL=1,NVEGTYPE
  WRITE(YMASK,FMT='(A,I2,A)') 'XDATA_VEGTYPE(:,',JL,')>0.'
  CALL WRITE_SOURCE_DATA_A(IUNIT,YMASK,4,'F4.2','XDATA_GROUND_DEPTH  ',XDATA_GROUND_DEPTH(:,JL),KIND1=JL)
END DO
DO JL=1,NVEGTYPE
  WRITE(YMASK,FMT='(A,I2,A)') 'XDATA_VEGTYPE(:,',JL,')>0.'
  CALL WRITE_SOURCE_DATA_A(IUNIT,YMASK,4,'F4.2','XDATA_DICE          ',XDATA_DICE(:,JL),KIND1=JL)
END DO
!
!
DO JL=1,NVEGTYPE
  WRITE(YMASK,FMT='(A,I2,A)') 'XDATA_VEGTYPE(:,',JL,')>0.'
  ZSEED(:) = FLOAT(IDATA_SEED_DAY(:,JL))
  CALL WRITE_SOURCE_DATA_B(IUNIT,YMASK,2,'I2.2','TDATA_SEED          ',ZSEED,KIND1=JL,HTYPE='%TDATE%DAY')
END DO
DO JL=1,NVEGTYPE
  WRITE(YMASK,FMT='(A,I2,A)') 'XDATA_VEGTYPE(:,',JL,')>0.'
  ZSEED(:) = FLOAT(IDATA_SEED_MONTH(:,JL))
  CALL WRITE_SOURCE_DATA_B(IUNIT,YMASK,2,'I2.2','TDATA_SEED          ',ZSEED,KIND1=JL,HTYPE='%TDATE%MONTH')
END DO
DO JL=1,NVEGTYPE
  WRITE(YMASK,FMT='(A,I2,A)') 'XDATA_VEGTYPE(:,',JL,')>0.'
  ZSEED(:) = FLOAT(IDATA_REAP_DAY(:,JL))
  CALL WRITE_SOURCE_DATA_B(IUNIT,YMASK,2,'I2.2','TDATA_REAP          ',ZSEED,KIND1=JL,HTYPE='%TDATE%DAY')
END DO
DO JL=1,NVEGTYPE
  WRITE(YMASK,FMT='(A,I2,A)') 'XDATA_VEGTYPE(:,',JL,')>0.'
  ZSEED(:) = FLOAT(IDATA_REAP_MONTH(:,JL))
  CALL WRITE_SOURCE_DATA_B(IUNIT,YMASK,2,'I2.2','TDATA_REAP          ',ZSEED,KIND1=JL,HTYPE='%TDATE%MONTH')
END DO
!
WRITE(20,FMT='(A)')'!'
WRITE(20,FMT='(A)') 'IF (LHOOK) CALL DR_HOOK(''DEFAULT_DATA_COVER'',1,ZHOOK_HANDLE) '  
WRITE(20,FMT='(A)')'!'
WRITE(20,FMT='(A,A)') 'END SUBROUTINE ','DEFAULT_DATA_COVER'
!
CLOSE(20)
!
!
!------------------------------------------------------------------------------
!
!
!*    5.0    Writes the LAI for ecoclimap1 in one separate fortran file
!            ------------------------------------------
!
YFILE = 'test/default_lai_eco1.F90'
OPEN(20,FILE=YFILE,FORM='FORMATTED')
!
DO JVEGTYPE=1,NVEGTYPE
  WRITE(YNAME,FMT='(A,I2.2)') 'DEFAULT_LAI_ECO1_',JVEGTYPE
  IF(JVEGTYPE>1)THEN
    WRITE(20,FMT='(A)') '!'
    WRITE(20,FMT='(A)') '!------------------------------------------------------------------------------'
    WRITE(20,FMT='(A)') '!------------------------------------------------------------------------------'
    WRITE(20,FMT='(A)') '!'
  ENDIF
  CALL WRITE_HEADER(YNAME)
  WRITE(20,FMT='(A)') 'IF (LHOOK) CALL DR_HOOK('''//TRIM(YNAME)//''',0,ZHOOK_HANDLE) '  
  WRITE(20,FMT='(A)')'!'

  WRITE(YMASK,FMT='(A,I2,A)') 'XDATA_VEGTYPE(1:255,',JVEGTYPE,')>0.'
  DO JL=1,SIZE(XDATA_LAI,2)
    CALL WRITE_SOURCE_DATA_A(IUNIT,YMASK,3,'F3.1','XDATA_LAI           ',XDATA_LAI(:,JL,JVEGTYPE),&
                           KIND1=JL,KIND2=JVEGTYPE,KCOV1=1,KCOV2=255)
  END DO
  WRITE(20,FMT='(A)')'!'
  WRITE(20,FMT='(A)') 'IF (LHOOK) CALL DR_HOOK('''//TRIM(YNAME)//''',1,ZHOOK_HANDLE) '  
  WRITE(20,FMT='(A)')'!'
  WRITE(20,FMT='(A,A)') 'END SUBROUTINE ',TRIM(YNAME)
END DO
!
CLOSE(20)
!------------------------------------------------------------------------------
!
!
!*    6.0    Writes the LAI for all ecoclimap2 years in the separate fortran files
!            ------------------------------------------
!
YFILE = 'test/default_lai_eco2.F90'
OPEN(20,FILE=YFILE,FORM='FORMATTED')
!
DO JVEGTYPE=1,NVEGTYPE
  JL=0
  DO JYEAR=1,NBAN(2)
    WRITE(YNAME,FMT='(A,I4.4,A,I2.2)') 'DEFAULT_LAI_ECO2_Y',NECO2_START_YEAR-1+JYEAR,'_',JVEGTYPE
    IF(JVEGTYPE>1.OR.JYEAR>1)THEN
      WRITE(20,FMT='(A)') '!'
      WRITE(20,FMT='(A)') '!------------------------------------------------------------------------------'
      WRITE(20,FMT='(A)') '!------------------------------------------------------------------------------'
      WRITE(20,FMT='(A)') '!'
    ENDIF    
    CALL WRITE_HEADER(YNAME)
    WRITE(20,FMT='(A)') 'IF (LHOOK) CALL DR_HOOK('''//TRIM(YNAME)//''',0,ZHOOK_HANDLE) '  
    WRITE(20,FMT='(A)')'!'
    
    WRITE(YMASK,FMT='(A,I2,A)') 'XDATA_VEGTYPE(301:573,',JVEGTYPE,')>0.'

    DO J=1,SIZE(XDATA_LAI_ALL_YEARS,2)/NBAN(2)
      JL=JL+1
      CALL WRITE_SOURCE_DATA_A(IUNIT,YMASK,3,'F3.1','XDATA_LAI_ALL_YEARS ',XDATA_LAI_ALL_YEARS(:,JL,JVEGTYPE),&
                           KIND1=JL,KIND2=JVEGTYPE,KCOV1=301,KCOV2=JPCOVER)
    END DO
    WRITE(20,FMT='(A)')'!'
    WRITE(20,FMT='(A)') 'IF (LHOOK) CALL DR_HOOK('''//TRIM(YNAME)//''',1,ZHOOK_HANDLE) '  
    WRITE(20,FMT='(A)')'!'    
    WRITE(20,FMT='(A,A)') 'END SUBROUTINE ',TRIM(YNAME)
  END DO
END DO

CLOSE(20)
!
!
!*    7.0    Writes the albedo veg for ecoclimap1 in one separate fortran file
!            ------------------------------------------
!
YFILE = 'test/default_alb_eco1.F90'
OPEN(20,FILE=YFILE,FORM='FORMATTED')
!
WRITE(20,FMT='(A)') '!'
WRITE(20,FMT='(A)') '!------------------------------------------------------------------------------'
WRITE(20,FMT='(A)') '!Soil albedo (the same for all 19 vegtypes)'
WRITE(20,FMT='(A)') '!------------------------------------------------------------------------------'
WRITE(20,FMT='(A)') '!'
!
DO JVEGTYPE=1,1
  WRITE(YNAME,FMT='(A,I2.2)') 'DEFAULT_ALB_SOIL_ECO1'!_',JVEGTYPE
  CALL WRITE_HEADER(YNAME)
  WRITE(20,FMT='(A)') 'IF (LHOOK) CALL DR_HOOK('''//TRIM(YNAME)//''',0,ZHOOK_HANDLE) '  
  WRITE(20,FMT='(A)')'!'

  WRITE(YMASK,FMT='(A,I2,A)') ' '
  DO JL=1,SIZE(XDATA_ALB_SOIL_NIR,2)
    CALL WRITE_SOURCE_DATA_A(IUNIT,YMASK,6,'F6.4','XDATA_ALB_SOIL_NIR   ',XDATA_ALB_SOIL_NIR(:,JL,JVEGTYPE),&
                           KIND1=JL,KIND2=JVEGTYPE,KCOV1=1,KCOV2=255)                   
    CALL WRITE_SOURCE_DATA_A(IUNIT,YMASK,6,'F6.4','XDATA_ALB_SOIL_VIS   ',XDATA_ALB_SOIL_VIS(:,JL,JVEGTYPE),&
                           KIND1=JL,KIND2=JVEGTYPE,KCOV1=1,KCOV2=255)
  END DO
  WRITE(20,FMT='(A)')'!'
  WRITE(20,FMT='(A)') 'IF (LHOOK) CALL DR_HOOK('''//TRIM(YNAME)//''',1,ZHOOK_HANDLE) '  
  WRITE(20,FMT='(A)')'!'
  WRITE(20,FMT='(A,A)') 'END SUBROUTINE ',TRIM(YNAME)
END DO
!
WRITE(20,FMT='(A)') '!'
WRITE(20,FMT='(A)') '!------------------------------------------------------------------------------'
WRITE(20,FMT='(A)') '!Vegetation albedo for all 19 vegtypes'
WRITE(20,FMT='(A)') '!------------------------------------------------------------------------------'
WRITE(20,FMT='(A)') '!'
!
DO JVEGTYPE=1,NVEGTYPE
  WRITE(YNAME,FMT='(A,I2.2)') 'DEFAULT_ALB_VEG_ECO1_',JVEGTYPE
  IF(JVEGTYPE>1)THEN
    WRITE(20,FMT='(A)') '!'
    WRITE(20,FMT='(A)') '!------------------------------------------------------------------------------'
    WRITE(20,FMT='(A)') '!------------------------------------------------------------------------------'
    WRITE(20,FMT='(A)') '!'
  ENDIF
  CALL WRITE_HEADER(YNAME)
  WRITE(20,FMT='(A)') 'IF (LHOOK) CALL DR_HOOK('''//TRIM(YNAME)//''',0,ZHOOK_HANDLE) '  
  WRITE(20,FMT='(A)')'!'

  WRITE(YMASK,FMT='(A,I2,A)') 'XDATA_VEGTYPE(1:255,',JVEGTYPE,')>0.'
  DO JL=1,SIZE(XDATA_ALB_VEG_NIR,2)
    CALL WRITE_SOURCE_DATA_A(IUNIT,YMASK,6,'F6.4','XDATA_ALB_VEG_NIR   ',XDATA_ALB_VEG_NIR(:,JL,JVEGTYPE),&
                           KIND1=JL,KIND2=JVEGTYPE,KCOV1=1,KCOV2=255)                   
    CALL WRITE_SOURCE_DATA_A(IUNIT,YMASK,6,'F6.4','XDATA_ALB_VEG_VIS   ',XDATA_ALB_VEG_VIS(:,JL,JVEGTYPE),&
                           KIND1=JL,KIND2=JVEGTYPE,KCOV1=1,KCOV2=255)
  END DO
  WRITE(20,FMT='(A)')'!'
  WRITE(20,FMT='(A)') 'IF (LHOOK) CALL DR_HOOK('''//TRIM(YNAME)//''',1,ZHOOK_HANDLE) '  
  WRITE(20,FMT='(A)')'!'
  WRITE(20,FMT='(A,A)') 'END SUBROUTINE ',TRIM(YNAME)
END DO
!
CLOSE(20)
!
!
!*    8.0    Writes the albedo veg for ecoclimap1 in one separate fortran file
!            ------------------------------------------
!
YFILE = 'test/default_alb_eco2.F90'
OPEN(20,FILE=YFILE,FORM='FORMATTED')
!
WRITE(20,FMT='(A)') '!'
WRITE(20,FMT='(A)') '!------------------------------------------------------------------------------'
WRITE(20,FMT='(A)') '!Soil albedo (the same for all 19 vegtypes)'
WRITE(20,FMT='(A)') '!------------------------------------------------------------------------------'
WRITE(20,FMT='(A)') '!'
!
DO JVEGTYPE=1,1
  WRITE(YNAME,FMT='(A,I2.2)') 'DEFAULT_ALB_SOIL_ECO2'!_',JVEGTYPE
  CALL WRITE_HEADER(YNAME)
  WRITE(20,FMT='(A)') 'IF (LHOOK) CALL DR_HOOK('''//TRIM(YNAME)//''',0,ZHOOK_HANDLE) '  
  WRITE(20,FMT='(A)')'!'

  WRITE(YMASK,FMT='(A,I2,A)') ' '
  DO JL=1,SIZE(XDATA_ALB_SOIL_NIR,2)
    CALL WRITE_SOURCE_DATA_A(IUNIT,YMASK,6,'F6.4','XDATA_ALB_SOIL_NIR   ',XDATA_ALB_SOIL_NIR(:,JL,JVEGTYPE),&
                           KIND1=JL,KIND2=JVEGTYPE,KCOV1=301,KCOV2=JPCOVER)                   
    CALL WRITE_SOURCE_DATA_A(IUNIT,YMASK,6,'F6.4','XDATA_ALB_SOIL_VIS   ',XDATA_ALB_SOIL_VIS(:,JL,JVEGTYPE),&
                           KIND1=JL,KIND2=JVEGTYPE,KCOV1=301,KCOV2=JPCOVER)
  END DO
  WRITE(20,FMT='(A)')'!'
  WRITE(20,FMT='(A)') 'IF (LHOOK) CALL DR_HOOK('''//TRIM(YNAME)//''',1,ZHOOK_HANDLE) '  
  WRITE(20,FMT='(A)')'!'
  WRITE(20,FMT='(A,A)') 'END SUBROUTINE ',TRIM(YNAME)
END DO
!
WRITE(20,FMT='(A)') '!'
WRITE(20,FMT='(A)') '!------------------------------------------------------------------------------'
WRITE(20,FMT='(A)') '!Vegetation albedo for all 19 vegtypes'
WRITE(20,FMT='(A)') '!------------------------------------------------------------------------------'
WRITE(20,FMT='(A)') '!'
!
DO JVEGTYPE=1,NVEGTYPE
  WRITE(YNAME,FMT='(A,I2.2)') 'DEFAULT_ALB_VEG_ECO2_',JVEGTYPE
  IF(JVEGTYPE>1)THEN
    WRITE(20,FMT='(A)') '!'
    WRITE(20,FMT='(A)') '!------------------------------------------------------------------------------'
    WRITE(20,FMT='(A)') '!------------------------------------------------------------------------------'
    WRITE(20,FMT='(A)') '!'
  ENDIF
  CALL WRITE_HEADER(YNAME)
  WRITE(20,FMT='(A)') 'IF (LHOOK) CALL DR_HOOK('''//TRIM(YNAME)//''',0,ZHOOK_HANDLE) '  
  WRITE(20,FMT='(A)')'!'

  WRITE(YMASK,FMT='(A,I2,A)') 'XDATA_VEGTYPE(301:573,',JVEGTYPE,')>0.'
  DO JL=1,SIZE(XDATA_ALB_VEG_NIR,2)
    CALL WRITE_SOURCE_DATA_A(IUNIT,YMASK,6,'F6.4','XDATA_ALB_VEG_NIR   ',XDATA_ALB_VEG_NIR(:,JL,JVEGTYPE),&
                           KIND1=JL,KIND2=JVEGTYPE,KCOV1=301,KCOV2=JPCOVER)                   
    CALL WRITE_SOURCE_DATA_A(IUNIT,YMASK,6,'F6.4','XDATA_ALB_VEG_VIS   ',XDATA_ALB_VEG_VIS(:,JL,JVEGTYPE),&
                           KIND1=JL,KIND2=JVEGTYPE,KCOV1=301,KCOV2=JPCOVER)
  END DO
  WRITE(20,FMT='(A)')'!'
  WRITE(20,FMT='(A)') 'IF (LHOOK) CALL DR_HOOK('''//TRIM(YNAME)//''',1,ZHOOK_HANDLE) '  
  WRITE(20,FMT='(A)')'!'
  WRITE(20,FMT='(A,A)') 'END SUBROUTINE ',TRIM(YNAME)
END DO
!
CLOSE(20)
!
!------------------------------------------------------------------------------
CONTAINS
!------------------------------------------------------------------------------
SUBROUTINE READ_NATURE
!
INTEGER               :: JVEGTYPE, JLAI
!
!
!fractions of vegtypes
IREC=IREC+1
READ(IUNIT,REC=IREC) XDATA_VEGTYPE(ICOVER,:)

!albedos for the soil
IF (IECO<=2 .AND. XDATA_NATURE(ICOVER)/=0.) THEN
  IREC=IREC+1
  READ(IUNIT,REC=IREC) XDATA_ALB_SOIL_NIR(ICOVER,1:12,1)
  IREC=IREC+1
  READ(IUNIT,REC=IREC) XDATA_ALB_SOIL_NIR(ICOVER,13:24,1)
  IREC=IREC+1
  READ(IUNIT,REC=IREC) XDATA_ALB_SOIL_NIR(ICOVER,25:36,1)
  IREC=IREC+1
  READ(IUNIT,REC=IREC) XDATA_ALB_SOIL_VIS(ICOVER,1:12,1)
  IREC=IREC+1
  READ(IUNIT,REC=IREC) XDATA_ALB_SOIL_VIS(ICOVER,13:24,1)
  IREC=IREC+1
  READ(IUNIT,REC=IREC) XDATA_ALB_SOIL_VIS(ICOVER,25:36,1)
  DO JVEGTYPE=2,NVEGTYPE
    XDATA_ALB_SOIL_NIR(ICOVER,:,JVEGTYPE) = XDATA_ALB_SOIL_NIR(ICOVER,:,1)
    XDATA_ALB_SOIL_VIS(ICOVER,:,JVEGTYPE) = XDATA_ALB_SOIL_VIS(ICOVER,:,1)
  ENDDO
ENDIF

DO JVEGTYPE=1,NVEGTYPE
  !not null fraction of vegtype
  IF (XDATA_VEGTYPE(ICOVER,JVEGTYPE).NE.0.) THEN
    !root and soil depths
    IREC=IREC+1      
    READ(IUNIT,REC=IREC) XDATA_ROOT_DEPTH(ICOVER,JVEGTYPE), XDATA_GROUND_DEPTH(ICOVER,JVEGTYPE), XDATA_DICE(ICOVER,JVEGTYPE)
    IF (JVEGTYPE.GT.3) THEN
      !LAI
      DO JLAI=1,NBAN(IECO)*3
        IREC=IREC+1
        IF (IECO==1) THEN
          READ(IUNIT,REC=IREC) XDATA_LAI(ICOVER,(JLAI-1)*12+1:JLAI*12,JVEGTYPE)
        ELSEIF (IECO==2) THEN
          READ(IUNIT,REC=IREC) XDATA_LAI_ALL_YEARS(ICOVER,(JLAI-1)*12+1:JLAI*12,JVEGTYPE)
        ENDIF
      ENDDO
      !Heights of trees
      IF ((JVEGTYPE < 7) .OR. (JVEGTYPE > 12 .AND. JVEGTYPE /= 18)) THEN
        IREC=IREC+1
        READ(IUNIT,REC=IREC) XDATA_H_TREE(ICOVER,JVEGTYPE)
      ENDIF

      !albedos for the vegetation
      IF (IECO<=2 .AND. XDATA_NATURE(ICOVER)/=0.) THEN
        IREC=IREC+1
        READ(IUNIT,REC=IREC) XDATA_ALB_VEG_NIR(ICOVER,1:12,JVEGTYPE)
        IREC=IREC+1
        READ(IUNIT,REC=IREC) XDATA_ALB_VEG_NIR(ICOVER,13:24,JVEGTYPE)
        IREC=IREC+1
        READ(IUNIT,REC=IREC) XDATA_ALB_VEG_NIR(ICOVER,25:36,JVEGTYPE)
        IREC=IREC+1
        READ(IUNIT,REC=IREC) XDATA_ALB_VEG_VIS(ICOVER,1:12,JVEGTYPE)
        IREC=IREC+1
        READ(IUNIT,REC=IREC) XDATA_ALB_VEG_VIS(ICOVER,13:24,JVEGTYPE)
        IREC=IREC+1
        READ(IUNIT,REC=IREC) XDATA_ALB_VEG_VIS(ICOVER,25:36,JVEGTYPE)
      ENDIF
      
    ELSE
      !LAI for bare areas
      IF (IECO==1) THEN
        XDATA_LAI(ICOVER,:,JVEGTYPE) = 0.
      ELSEIF (IECO==2) THEN
        XDATA_LAI_ALL_YEARS(ICOVER,:,JVEGTYPE) = 0.
      ENDIF
      XDATA_ALB_VEG_NIR(ICOVER,:,JVEGTYPE) = 0.3
      XDATA_ALB_VEG_VIS(ICOVER,:,JVEGTYPE) = 0.1      
    ENDIF
    !irrigation
    IF (JVEGTYPE.EQ.8 .AND. IECO.EQ.1 .OR. JVEGTYPE.EQ.9 .AND. IECO.EQ.2) THEN
      IREC=IREC+1
      READ(IUNIT,REC=IREC) IDATA_SEED_MONTH(ICOVER,JVEGTYPE), IDATA_SEED_DAY(ICOVER,JVEGTYPE), &
        IDATA_REAP_MONTH(ICOVER,JVEGTYPE), IDATA_REAP_DAY(ICOVER,JVEGTYPE), &
        XDATA_WATSUP(ICOVER,JVEGTYPE),XDATA_IRRIG(ICOVER,JVEGTYPE)
    ENDIF
  ENDIF
ENDDO
!
END SUBROUTINE READ_NATURE
!------------------------------------------------------------------------------
SUBROUTINE WRITE_SOURCE_DATA_A(KUNIT,HMASK,KFMT,HFMT,HFIELD,PFIELD,KIND1,KIND2,KEXP,KCOV1,KCOV2)
!
INTEGER,                  INTENT(IN) :: KUNIT
CHARACTER(LEN=*),         INTENT(IN) :: HMASK   ! where field is defined
INTEGER,                  INTENT(IN) :: KFMT
CHARACTER(LEN=4),         INTENT(IN) :: HFMT
CHARACTER(LEN=20),        INTENT(IN) :: HFIELD
REAL*8, DIMENSION(JPCOVER), INTENT(IN) :: PFIELD
INTEGER, OPTIONAL,        INTENT(IN) :: KIND1
INTEGER, OPTIONAL,        INTENT(IN) :: KIND2
INTEGER, OPTIONAL,        INTENT(IN) :: KEXP
INTEGER, OPTIONAL,        INTENT(IN) :: KCOV1  ! first cover index
INTEGER, OPTIONAL,        INTENT(IN) :: KCOV2  ! last  cover index

CHARACTER(LEN=90) :: YFIELD 
CHARACTER(LEN=120):: YLINE 
CHARACTER(LEN=4)  :: YFMT
CHARACTER(LEN=120) :: YFMT_LINE
INTEGER           :: ICOVER, JCOVER, JI
INTEGER           :: ICOVER_DEB, ICOVER_FIN
LOGICAL           :: LUNIFORM
REAL*8            :: ZFIELD
!
IF (PRESENT(KCOV1) .AND. PRESENT(KCOV2)) THEN
  ICOVER_DEB=KCOV1
  ICOVER_FIN=KCOV2
  WRITE(YFIELD,FMT='(A,A1,I3,A1,I3)') TRIM(HFIELD), '(',KCOV1,':',KCOV2
ELSE
  ICOVER_DEB=1
  ICOVER_FIN=JPCOVER
  YFIELD = TRIM(HFIELD) // '(:'
END IF
IF (PRESENT(KIND1)) THEN
  IF (KIND1<10) THEN
    WRITE(YFIELD,FMT='(A,A,I1)') TRIM(YFIELD),',  ',KIND1
  ELSEIF (KIND1<100) THEN
    WRITE(YFIELD,FMT='(A,A,I2)') TRIM(YFIELD),', ',KIND1
  ELSE
    WRITE(YFIELD,FMT='(A,A,I3)') TRIM(YFIELD),',',KIND1
  END IF
END IF
IF (PRESENT(KIND2)) THEN
  IF (KIND2<10) THEN
    WRITE(YFIELD,FMT='(A,A,I1)') TRIM(YFIELD),', ',KIND2
  ELSE
    WRITE(YFIELD,FMT='(A,A,I2)') TRIM(YFIELD),',',KIND2
  END IF
END IF
!
CALL UNIFORM_FIELD(PFIELD,LUNIFORM,ZFIELD)
IF (LUNIFORM) THEN
  IF (ZFIELD==XUNDEF) RETURN
  WRITE(YFMT_LINE,FMT='(A,A4,A1)' ) '(A,A4,',HFMT,')'
  WRITE(YFIELD,FMT=YFMT_LINE) TRIM(YFIELD),') = ',ZFIELD
  IF (HMASK/='ALL') YFIELD = 'WHERE('//TRIM(HMASK)//') '//YFIELD
  WRITE(20,FMT='(A)') YFIELD
  YLINE  = '!-------------------------------------------------------------------'
  WRITE(20,FMT='(A)') YLINE
  RETURN
END IF


YFIELD = TRIM(YFIELD)//') = (/          &'

WRITE(20,FMT='(A)') TRIM(YFIELD)

!
ICOVER=ICOVER_DEB
DO JCOVER=ICOVER_DEB/10+1,ICOVER_FIN/10+1
  YLINE=' '
  DO JI=1,10
    IF (ICOVER <= MIN(ICOVER_FIN,JPCOVER)) THEN
      IF (JI>=2) YFMT_LINE = TRIM(YFMT_LINE)//','
      IF (PFIELD(ICOVER)/=XUNDEF) THEN
        IF (.NOT. PRESENT(KEXP)) THEN
          WRITE(YFMT_LINE,FMT='(A4,I1.1,A1,A4,A1)' ) '(A,A',7-KFMT,',',HFMT,')'
          WRITE(YLINE,FMT=YFMT_LINE) TRIM(YLINE),'     ',PFIELD(ICOVER)
        ELSE
          WRITE(YFMT_LINE,FMT='(A4,I1.1,A1,A4,A7)' ) '(A,A',5-KFMT,',',HFMT,',A1,I1)'
          WRITE(YLINE,FMT=YFMT_LINE) TRIM(YLINE),' ',PFIELD(ICOVER)/10**KEXP,'E',KEXP
        END IF
      ELSE
        YLINE = TRIM(YLINE)//' XUNDEF'
      END IF
      IF (ICOVER<MIN(ICOVER_FIN,JPCOVER)) YLINE=TRIM(YLINE)//','
      ICOVER = ICOVER + 1
    END IF
  END DO
  YLINE=TRIM(YLINE)//' &'
  WRITE(20,FMT='(A)') TRIM(YLINE)
END DO

YFIELD = '         /)'
WRITE(20,FMT='(A)') TRIM(YFIELD)
YLINE  = '!-------------------------------------------------------------------'
WRITE(20,FMT='(A)') YLINE
!
END SUBROUTINE WRITE_SOURCE_DATA_A
!
!------------------------------------------------------------------------------
SUBROUTINE WRITE_SOURCE_DATA_B(KUNIT,HMASK,KFMT,HFMT,HFIELD,PFIELD,KIND1,KIND2,PEXP,HEXP,HTYPE,LFREQUENT)
!
INTEGER,                  INTENT(IN) :: KUNIT
CHARACTER(LEN=*),         INTENT(IN) :: HMASK   ! where field is defined
INTEGER,                  INTENT(IN) :: KFMT
CHARACTER(LEN=4),         INTENT(IN) :: HFMT
CHARACTER(LEN=20),        INTENT(IN) :: HFIELD
REAL*8, DIMENSION(JPCOVER), INTENT(IN) :: PFIELD
INTEGER, OPTIONAL,        INTENT(IN) :: KIND1
INTEGER, OPTIONAL,        INTENT(IN) :: KIND2
REAL*8,  OPTIONAL,        INTENT(IN) :: PEXP
CHARACTER(LEN=*), OPTIONAL,  INTENT(IN) :: HEXP   ! formula to add to the right of the values
CHARACTER(LEN=*), OPTIONAL,  INTENT(IN) :: HTYPE  ! characters to add to the right of the field def.
LOGICAL,          OPTIONAL,  INTENT(IN) :: LFREQUENT ! checks if a value is more frequent than others

REAL*8            :: ZFIELD
CHARACTER(LEN=40) :: YFIELD1
CHARACTER(LEN=40) :: YFIELD
CHARACTER(LEN=120):: YLINE 
CHARACTER(LEN=4)  :: YFMT
CHARACTER(LEN=120) :: YFMT_LINE
INTEGER           :: ICOVER, JCOVER, JI
INTEGER           :: ICOVER_DEB, ICOVER_FIN
LOGICAL           :: LUNIFORM
LOGICAL           :: LPRINT
REAL*8            :: ZFREQUENT_VAL
!
YFIELD1 = TRIM(HFIELD) // '('
YFIELD  = ''
IF (PRESENT(KIND1)) THEN
  IF (KIND1<10) THEN
    WRITE(YFIELD,FMT='(A,A,I1)') TRIM(YFIELD),',  ',KIND1
  ELSEIF (KIND1<100) THEN
    WRITE(YFIELD,FMT='(A,A,I2)') TRIM(YFIELD),', ',KIND1
  ELSE
    WRITE(YFIELD,FMT='(A,A,I3)') TRIM(YFIELD),',',KIND1
  END IF
END IF
IF (PRESENT(KIND2)) THEN
  IF (KIND2<10) THEN
    WRITE(YFIELD,FMT='(A,A,I1)') TRIM(YFIELD),', ',KIND2
  ELSE
    WRITE(YFIELD,FMT='(A,A,I2)') TRIM(YFIELD),',',KIND2
  END IF
END IF
YFIELD = TRIM(YFIELD)//')'
IF (PRESENT(HTYPE)) YFIELD = TRIM(YFIELD)//TRIM(HTYPE)
YFIELD = TRIM(YFIELD)//' = '
!
CALL UNIFORM_FIELD(PFIELD,LUNIFORM,ZFIELD)
CALL MORE_FREQUENT_VALUE(PFIELD,ZFREQUENT_VAL)
!
!
IF (PRESENT(LFREQUENT)) THEN
  IF (.NOT. LFREQUENT) ZFREQUENT_VAL = XUNDEF
END IF
!
IF (LUNIFORM) THEN
  ZFREQUENT_VAL = ZFIELD
END IF
!
LPRINT = .FALSE.
!
IF (LUNIFORM .AND. ZFIELD==XUNDEF) RETURN
!
IF (LUNIFORM .OR. ZFREQUENT_VAL/=XUNDEF) THEN
  ZFIELD = ZFREQUENT_VAL
  IF (PRESENT(PEXP)) ZFIELD = ZFREQUENT_VAL * PEXP
  WRITE(YFMT_LINE,FMT='(A,A4,A1)' ) '(A6,A,A2,A,A1,A,',HFMT,')'
  IF (HFMT(1:1)=='I') THEN
    WRITE(YLINE,FMT=YFMT_LINE) 'WHERE(',HMASK,') ',TRIM(YFIELD1),':',TRIM(YFIELD),NINT(ZFIELD)
  ELSE
    WRITE(YLINE,FMT=YFMT_LINE) 'WHERE(',HMASK,') ',TRIM(YFIELD1),':',TRIM(YFIELD),ZFIELD
  END IF
  IF (PRESENT(HEXP)) THEN
    WRITE(YLINE,FMT='(A,A)') TRIM(YLINE),HEXP
  END IF
  WRITE(20,FMT='(A)') TRIM(YLINE)
  LPRINT = .TRUE.
END IF
!
IF (LUNIFORM) THEN
  YLINE  = '!-------------------------------------------------------------------'
  WRITE(20,FMT='(A)') YLINE
  RETURN
END IF
!
ICOVER=1
DO JCOVER=1,JPCOVER
  YLINE=' '
    IF (ICOVER <= JPCOVER) THEN
      IF (PFIELD(ICOVER)/=XUNDEF .AND. NINT(PFIELD(ICOVER))/=NUNDEF ) THEN
        ZFIELD = PFIELD(ICOVER)
        IF (PRESENT(PEXP)) ZFIELD = PFIELD(ICOVER) * PEXP
        IF (PFIELD(ICOVER)/=ZFREQUENT_VAL ) THEN
          WRITE(YFMT_LINE,FMT='(A8,A4,A1)' ) '(A,I3,A,',HFMT,')'
          IF (HFMT(1:1)=='I') THEN
            WRITE(YLINE,FMT=YFMT_LINE) TRIM(YFIELD1),ICOVER,TRIM(YFIELD),NINT(ZFIELD)
          ELSE
            WRITE(YLINE,FMT=YFMT_LINE) TRIM(YFIELD1),ICOVER,TRIM(YFIELD),ZFIELD
          END IF
          LPRINT = .TRUE.
          IF (PRESENT(HEXP)) THEN
            WRITE(YLINE,FMT='(A,A)') TRIM(YLINE),HEXP
          END IF
          WRITE(20,FMT='(A)') TRIM(YLINE)
        END IF
      END IF
      ICOVER = ICOVER + 1
    END IF
END DO

YLINE  = '!-------------------------------------------------------------------'
IF (LPRINT) WRITE(20,FMT='(A)') YLINE
!
END SUBROUTINE WRITE_SOURCE_DATA_B
!
!------------------------------------------------------------------------------
!------------------------------------------------------------------------------
!
SUBROUTINE UNIFORM_FIELD(PFIELD,OUNIFORM,PUNIF)

REAL*8,  DIMENSION(:), INTENT(IN)  :: PFIELD
LOGICAL, INTENT(OUT) :: OUNIFORM
REAL*8,  INTENT(OUT) :: PUNIF

OUNIFORM=.TRUE.
PUNIF = XUNDEF
DO JCOVER=1,JPCOVER
  IF (PFIELD(JCOVER)/=XUNDEF .AND. NINT(PFIELD(JCOVER))/=NUNDEF) THEN
    IF (PUNIF==XUNDEF) THEN
      PUNIF=PFIELD(JCOVER)
    ELSE
      IF (PFIELD(JCOVER)/=PUNIF) OUNIFORM=.FALSE.
    END IF
  END IF
END DO

END SUBROUTINE UNIFORM_FIELD
!
!------------------------------------------------------------------------------
!------------------------------------------------------------------------------
!
SUBROUTINE MORE_FREQUENT_VALUE(PFIELD,PVAL)

REAL*8,  DIMENSION(:), INTENT(IN)  :: PFIELD
REAL*8,  INTENT(OUT) :: PVAL

INTEGER :: ICOUNT_VAL
INTEGER, DIMENSION(JPCOVER) :: ICOUNT
REAL*8,  DIMENSION(JPCOVER) :: ZVAL
LOGICAL                     :: LADD
INTEGER                     :: I
INTEGER, DIMENSION(1)       :: IMAX
!
ZVAL(:) = XUNDEF
ICOUNT=0
ICOUNT_VAL = 0
!
DO JCOVER=1,JPCOVER
  IF (PFIELD(JCOVER)/=XUNDEF .AND. NINT(PFIELD(JCOVER))/=NUNDEF) THEN
    IF (ICOUNT_VAL==0) THEN
      ICOUNT_VAL = 1
      ICOUNT(1) = 1
      ZVAL(1) = PFIELD(JCOVER)
      CYCLE
    END IF
    !
    LADD = .FALSE.
    DO I=1,ICOUNT_VAL
    IF (PFIELD(JCOVER)==ZVAL(I)) THEN
      ICOUNT(I) = ICOUNT(I) + 1
      LADD = .TRUE.
      EXIT
    END IF
    END DO
    !
    IF (.NOT. LADD) THEN
      ICOUNT_VAL = ICOUNT_VAL+1
      ICOUNT(ICOUNT_VAL) = 1
      ZVAL(ICOUNT_VAL) = PFIELD(JCOVER)
    END IF
  END IF
END DO
!
IF (ICOUNT_VAL>0) THEN
  IMAX = MAXLOC(ICOUNT)
  PVAL = ZVAL(IMAX(1))
ELSE
  PVAL = XUNDEF
END IF

END SUBROUTINE MORE_FREQUENT_VALUE
!
!------------------------------------------------------------------------------
!------------------------------------------------------------------------------
!
SUBROUTINE WRITE_HEADER(HNAME)

CHARACTER(LEN=*), INTENT(IN) :: HNAME
WRITE(20,FMT='(A,A)') 'SUBROUTINE ',TRIM(HNAME)
WRITE(20,FMT='(A)') '!'
WRITE(20,FMT='(A)') 'USE MODD_SURF_PAR'
WRITE(20,FMT='(A)') 'USE MODD_DATA_COVER_PAR'
WRITE(20,FMT='(A)') 'USE MODD_DATA_COVER'
WRITE(20,FMT='(A)') 'USE YOMHOOK   ,ONLY : LHOOK,   DR_HOOK'
WRITE(20,FMT='(A)') 'USE PARKIND1  ,ONLY : JPRB'
WRITE(20,FMT='(A)') 'IMPLICIT NONE'
WRITE(20,FMT='(A)') '!'
WRITE(20,FMT='(A)') '!*    Declaration of local variables'
WRITE(20,FMT='(A)') '!     ------------------------------ '
WRITE(20,FMT='(A)') '!'
WRITE(20,FMT='(A)') 'REAL(KIND=JPRB) :: ZHOOK_HANDLE'
WRITE(20,FMT='(A)') '!'
WRITE(20,FMT='(A)') '!------------------------------------------------------------------------------'
WRITE(20,FMT='(A)') '!'
END SUBROUTINE WRITE_HEADER
!------------------------------------------------------------------------------
!------------------------------------------------------------------------------
END PROGRAM WRITE_SOURCE_DATA_COVER
