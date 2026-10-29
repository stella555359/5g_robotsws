*** Settings ***
Documentation    ...
#Resource    ./5GC001086_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Library           ./../CUDU_L2/scripts/python/ttitrace_data_parser.py
#Library           ./../CUDU_L2/scripts/python/get_csv_data.py
#Library           ./../CUDU_L2/scripts/python/streaming_ttitrace_analyzer.py
#Suite Setup        Common Suite Setup 2
#Test Teardown      Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00    SBTS23R1
#...                RAN_5G    RAN_5G_TDD    CRT
#*** Variables ***
#${SCF_DIR}    ${CURDIR}/config/
#${5GC001086_SCF_A}   ${SCF_DIR}/5GC001086_SCF_A.xml
#${5GC001086_SCF_B}   ${SCF_DIR}/5GC001086_SCF_B.xml
#${5GC001086_SCF_F01}    ${SCF_DIR}/5GC001086_SCF_F01.xml
#${5GC001086_SCF_F07}    ${SCF_DIR}/PowerSavingBWP_F07.xml
#${5GC001086_SCF_F03}   ${SCF_DIR}/5GC001086_SCF_F03.xml
#${F13_Scf}           ${SCF_DIR}/5GC001086_SCF_F13.xml
#${5GC001086_SCF_F11}    ${SCF_DIR}/InfTddFrameMuting_F11.xml
#${DELTA_JSON}    ${CURDIR}/config/Delta_A_08_disableUlSRS.json
#${LOCAL_WTS_DIR}      ${CURDIR}/config/
#${WTS_DIR}            /opt/iphy/latest
#${WTS_CFG_A08}     5GC001086_basic_setup_A.cfg
#${WTS_CFG_B03}     5GC001086_basic_setup_B.cfg
#${WTS_CFG_F07}     5GC001086_PowerSavingBWP.cfg
#${WTS_CFG_F03}     5GC001086_basic_setup_F03.cfg
#${WTS_CFG_F11}     5GC001086_2UE.cfg
#${IPHY_FILE}    ${CURDIR}/config/AEQE_2S_1CC_iphy.xml
#${IPHY_F07}     ${CURDIR}/config/iphy_F07.xml
#${UE1_ID}             1
#${UE2_ID}             2
#${UE11_ID}            11
#${UE12_ID}            12
#${SWCONFIG_PARAM_A}        0x4B000F=1;0x4F011=1
#${SWCONFIG_PARAM_A_12}        0x4B000F=1;0x4F011=1;0x580526=1000;0x10040=2;0x1003F=2;
#@{LOG_NAME_LIST}      btslog    snapshot    sosreport
#&{GNB_ASIK}           ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
#${dl_tp_set}    175
#${ul_tp_set}    175
#${Egatelog_path}    ${CURDIR}
#${PDU_ID}                         1
#${TRF_ID}                         1
#@{COLUMN_NAME}      3gpp.sfn    3gpp.slot
#
#*** Test Cases ***
#5GC001086-ET-A008 Verify best UL beams determination for single UE with traffic via NSA when disable 1086
#    [Tags]     Owner_yalsun    case_A_08
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_A08}
#    ...        AND    Suite Setup Update GNB    scf_file=${5GC001086_SCF_A}    swconfig_param=${SWCONFIG_PARAM_A}    iphy_file=${IPHY_FILE}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Test actUlSrsBm Enable Successfully And Check ThroughPut
#    Test DFT best beam selection and SRSPeriod
#    Check SrsSlot From Wirshark    /BIP/1    7
#    Check The Number Of SRS Port    /BIP/1    1
#    Test actUlSrsBm Disable Successfully And Check ThroughPut
#
#5GC001086-ET-A012 Verify best UL beams determination for single UE with traffic via NSA when rrmUlBeamSelectTimer or rrmComaAgedTimer is timeout
#    [Tags]     Owner_yalsun    case_A_12
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_A08}
#    ...        AND    Suite Setup Update GNB    scf_file=${5GC001086_SCF_A}    swconfig_param=${SWCONFIG_PARAM_A_12}    iphy_file=${IPHY_FILE}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Suite Setup Start WTS And Check OnAir
#    Set TestMode for SRS    UE_ID=${UE11_ID}    profile_id=1    init_pos=0
#    NSA UE Attach and Get Throughput    UE_ID=11    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=50    ul_tp_threshold=10
#    Start GNB Syslog    ${TEST_LOG_DIRECTORY}
#    Set DTX For RrmComaAgedTimer Timeout    UE_ID=${UE11_ID}    profile_id=2    init_pos=1
#    Stop GNB Syslog   ${TEST_LOG_DIRECTORY}
#    Check RrmCoMaAgedTimer Timeout From Syslog
#
#5GC001086-ET-B003 Verify UL SU-MIMO adaption impact on single UE via NSA
#    [Tags]     Owner_yalsun    case_B_03
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_B03}
#    ...        AND    Suite Setup Update GNB    scf_file=${5GC001086_SCF_B}    swconfig_param=${SWCONFIG_PARAM_A}    iphy_file=${IPHY_FILE}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Test actUlSrsBm Enable Successfully And Check ThroughPut
#    Check Srsreceivereq From Wirshark    /BIP/1    1
#    ${patternId_1}    Check PatternID From Wirshark    /BIP/1    2
#    ${patternId_2}    Check PatternID From Wirshark    /BIP/3    -2
#    Should Not Be Equal    ${patternId_2}    ${patternId_1}
#    Check The Number Of SRS Port    /BIP/1    3
#    Check SrsSlot From Wirshark    /BIP/1    7
#
#5GC001086-ET-F001 Verify best UL beams determination and SU-MIMO for single UE with traffic via NSA with DRX enabled
#    [Tags]     Owner_yalsun    case_F_01    AP_REG
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_B03}
#    ...        AND    Suite Setup Update GNB    scf_file=${5GC001086_SCF_F01}    swconfig_param=${SWCONFIG_PARAM_A}    iphy_file=${IPHY_FILE}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Test actUlSrsBm Enable Successfully And Check ThroughPut
#    ${patternId_1}    Check PatternID From Wirshark    /BIP/1    2
#    ${patternId_2}    Check PatternID From Wirshark    /BIP/3    -2
#    Should Not Be Equal    ${patternId_2}    ${patternId_1}
#    Check Srsreceivereq From Wirshark    /BIP/1    8
#    Check SrsSlot From Wirshark    /BIP/1    3
#
#5GC001086-ET-F007 Verify best UL beam determination and SU-MIMO for single UE with traffic via SA with multiple BWP
#    [Tags]     Owner_qianwu    case_F_07
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_F07}
#    ...        AND    Suite Setup Update GNB    scf_file=${5GC001086_SCF_F07}    swconfig_param=${SWCONFIG_PARAM_A}    iphy_file=${IPHY_F07}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir
#    Set TestMode for SRS    UE_ID=${UE1_ID}    profile_id=1    init_pos=0
#    SA 5G CA Attach    ${UE1_ID}
#    SA Start UL Traffic Internal    ${UE1_ID}    pdu_id=1    mbps=10    trf_id=1
#    Start Gnb BIP Log
#    Sleep    3s    reason=Wait for traffic stable
#    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/1
#    Check BWP Switch    first=2    second=1
#    Set TestMode for SRS    UE_ID=${UE1_ID}    profile_id=2    init_pos=2
#    Sleep    10s    reason=Wait for TestMode enable
#    Start Gnb BIP Log
#    Sleep    3s    reason=Wait for traffic stable
#    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/3
#    Test DFT best beam selection and SRSPeriod
#    Check PowerSavingBWP and ASRS
#
#5GC001086-ET-F011 Verify single UE SRS with Coordination TDD deployments over country borders-2
#    [Tags]     Owner_qianwu    case_F_11
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_F11}
#    ...        AND    Suite Setup Update GNB    scf_file=${5GC001086_SCF_F11}    swconfig_param=${SWCONFIG_PARAM_A}    iphy_file=${IPHY_FILE}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir
#    Set 2UE Attach And Send Traffic
#    Set Beam Pos For 2UE
#    Check Patternid Beam Changed
#    Check SRS Slot When enable InfTddFrameMuting    /BIP/1
#
#5GC001086-ET-F013 Verify best UL beam determination and SU-MIMO for single UE with traffic via SA with 2226 enabled
#    [Tags]     Owner_suqian    case_F_013
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_B03}
#    ...        AND    Suite Setup Update GNB    scf_file=${F13_Scf}    swconfig_param=${SWCONFIG_PARAM_A}    iphy_file=${IPHY_FILE}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Test Change port and Srs Function
#    Check Beam and Srs Port
#    Check Srsreceivereq From Wirshark    /BIP/3    1
#    Check Patternid Beam Changed
#
#5GC001086-ET-F003 Verify intra DU cell with UlSrs true HO to the cell with UlSrs false via SA when the measurement GAP is not overlapped with SRS
#    [Tags]     Owner_haiyliu    case_F_03    AP_REG
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_F03}
#    ...        AND    Suite Setup Update GNB    scf_file=${5GC001086_SCF_F03}    swconfig_param=${SWCONFIG_PARAM_A}    iphy_file=${IPHY_FILE}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    ...        AND    Common Test Setup 2
#    L3 Call and Traffic    ${UE1_ID}
#    Collect Bip And Beam Change
#    Test DFT best beam selection and SRSPeriod
#    Trigger A2 MG Setup And Check
#    Trigger InterFreq And IntraDU HO And Check
#    Trigger Rank1 And Collect Bip
#    Check legacySRS In Srsreceivereq    /BIP/2
#
#*** Keywords ***
