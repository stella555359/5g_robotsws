*** Settings ***
Documentation    ...
#Resource    ./CB006112_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Library           ./../CUDU_L2/scripts/python/ttitrace_data_parser.py
#Library           ./../CUDU_L2/scripts/python/get_csv_data.py
#Suite Setup       Run Keywords    Common Suite Setup 2
#...               AND    Prepare QT LOLO Enviroment    TYPE=TDD
#Test Teardown      Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    SBTS22R4
#...                RAN_5G    RAN_5G_TDD    CRT
#
#*** Variables ***
#${DELTA_FILE_C03}         Delta_Conf_TDD_CB006112_C03.json
#${SWCONFIG_PARAM_C03}        0x5800F3=1;0x590072=1;0x41001b=1;
#${WTS_CFG_TDD}     wts_cfg_ASIL_ABIO_TDD.cfg
#
#${DELTA_FILE_C05}         Delta_Conf_TDD_CB006112_C05.json
#${SWCONFIG_PARAM_C05}        0x5800F3=1;0x590072=1;0x41001b=1;
#
#${DELTA_FILE_C29}         Delta_Conf_TDD_CB006112_C29.json
#${SWCONFIG_PARAM_C29}        0x5800F3=1;0x590072=1;0x41001b=1;0x5801D1=2;0x5801D2=2;
#
#${LOCAL_WTS_DIR}      ${CURDIR}/config/WTS_CFG
#${SCF_DIR}            ${CURDIR}/config/
#${6112_scf_tdd}       ${SCF_DIR}/SCF_VONR_TDD.xml
#${UE1_ID}             1
#${UE2_ID}             2
#${UE3_ID}             3
#${PROFILE_ID}         1
#${GNB_ID}             2
#${CELL_ID}            2
#${BEARER_ID}          2
#${gfbr_dlul_5}        5
#${WTS_DIR}            /opt/iphy/latest
#${WTS_AP_XML}         airphone.xml
#
#${Egatelog_path}    ${CURDIR}
#*** Test Cases ***
#CB006112-ET-C-03 TDD when FDM enable Voice call reject due to GBR load.
#    [Tags]     Owner_qianwu    case_C03
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_TDD}
#    ...        AND    Suite Setup Update GNB    scf_file=${6112_scf_tdd}    swconfig_param=${SWCONFIG_PARAM_C03}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Delta Commission With SCF File    ${SCF_DIR}/${DELTA_FILE_C03}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    SA Non GBR Call For Multi UE    ${UE1_ID}
#    SA GBR Call For Multi UE    ${UE2_ID}
#    SA Start UDP DL Traffic For Multi UE    ${UE1_ID}    7070    1400    60M    60
#    SA Start UDP UL Traffic For Multi UE    ${UE1_ID}    7071    1400    60M    60
#    SA Start UDP DL Traffic For Multi UE    ${UE2_ID}    7072    40    16000    360
#    SA Start UDP UL Traffic For Multi UE    ${UE2_ID}    7073    40    16000    360
#    Start GNB Syslog For 6112    ${TEST_LOG_DIRECTORY}
#    Unsuccessful SA GBR UE Attach    ${UE3_ID}
#    sleep    5s
#    Stop And Collect Syslog For 6112    ${TEST_LOG_DIRECTORY}
#    Check Failed Allocate Drb
#    Catch TTitrace With Streaming Mode And Convert To CSV
#    Verify DL PA Timer Enable With Streaming Mode
#    Verify UL PA Timer Enable With Streaming Mode
#
#CB006112-ET-C-05TDD Adaptive VoIP TBS for Uplink when original TBS Too small refer to PDU session setup
#    [Tags]     Owner_suqian    case_C05
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_TDD}
#    ...        AND    Suite Setup Update GNB    scf_file=${6112_scf_tdd}    swconfig_param=${SWCONFIG_PARAM_C05}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Delta Commission With SCF File    ${SCF_DIR}/${DELTA_FILE_C05}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    Modify guaranteedFlowBitRateDLUL    ${gfbr_dlul_5}
#    SA GBR Call For Multi UE    ${UE3_ID}
#    SA Start UDP DL Traffic For Multi UE    ${UE3_ID}    7074    30    12200    360
#    SA Start UDP UL Traffic For Multi UE    ${UE3_ID}    7075    30    12200    360
#    Start Ttitrace With Streaming Mode
#	Sleep    2s
#    Stop Ttitrace    log_dir=${OUTPUT_DIR}/tti
#    Decode Ttitrace Log    log_dir=${OUTPUT_DIR}/tti
#    Stop GBR Traffic
#    Release GBR UE
#    Verify UL voipVcdTimerData As Expected
#
#CB006112-ET-C-29 TDD voice call reject due to TD limits with FDM enable
#    [Tags]     Owner_yalsun    case_C29
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_TDD}
#    ...        AND    Suite Setup Update GNB    scf_file=${6112_scf_tdd}    swconfig_param=${SWCONFIG_PARAM_C29}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Delta Commission With SCF File    ${SCF_DIR}/${DELTA_FILE_C29}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    SA GBR Call For Multi UE    ${UE1_ID}
#    SA Start UDP DL Traffic For Multi UE    ${UE1_ID}    7070    40    1600000    3600
#    SA Start UDP UL Traffic For Multi UE    ${UE1_ID}    7071    40    160000    3600
#    Sleep    3s
#    Start GNB Syslog For 6112    ${TEST_LOG_DIRECTORY}
#    Unsuccessful SA GBR UE Attach    ${UE2_ID}
#    sleep    5s
#    Stop And Collect Syslog For 6112    ${TEST_LOG_DIRECTORY}
#    Check Failed Allocate Drb
