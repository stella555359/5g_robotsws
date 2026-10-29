*** Settings ***
Documentation    ...
#Resource    ./CB006112_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Library           ./../CUDU_L2/scripts/python/ttitrace_data_parser.py
#Library           ./../CUDU_L2/scripts/python/streaming_ttitrace_analyzer.py
#Library           ./../CUDU_L2/scripts/python/get_csv_data.py
#Suite Setup       Run Keywords    Common Suite Setup 2
#...               AND    Prepare QT LOLO Enviroment    TYPE=FDD
#Test Teardown      Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    SBTS00    SBTS23R1
#...                RAN_5G    RAN_5G_FDD    CRT
#*** Variables ***
#${DELTA_FILE_A_02_01}         Delta_Conf_TDD_CB006112_A_02_01.json
#${SWCONFIG_PARAM_A_02_01}        0x5800F3=1;0x590072=1;0x41001b=1;0x5801d0=0;
#${WTS_CFG_FDD}     wts_cfg_ASIB_ABIO_FDD.cfg
#
#${DELTA_FILE_B10}         Delta_Conf_TDD_CB006112_B10.json
#${SWCONFIG_PARAM_B10}        0x5800F3=1;0x590072=1;0x41001b=1;0x5801d0=0;
#
#${DELTA_FILE_C04}         Delta_Conf_TDD_CB006112_C05.json
#${SWCONFIG_PARAM_C04}        0x5800F3=1;0x590072=1;0x41001b=1;0x5801d0=0;
#
#${DELTA_FILE_C06}         Delta_Conf_TDD_CB006112_C06.json
#${SWCONFIG_PARAM_C06}        0x5800F3=1;0x590072=1;0x41001b=1;0x5801d0=0;
#
#${LOCAL_WTS_DIR}      ${CURDIR}/config/WTS_CFG
#${SCF_DIR}            ${CURDIR}/config/
#${6112_scf_fdd}       ${SCF_DIR}/SCF_VONR_FDD_LOLO.xml
#${UE1_ID}             1
#${UE2_ID}             2
#${UE3_ID}             3
#${UE4_ID}             4
#${PROFILE_ID}         1
#${GNB_ID}             2
#${CELL_ID}            2
#${BEARER_ID}          2
#${gfbr_dlul_100}      100
#${gfbr_dlul_5}        5
#${WTS_DIR}            /opt/iphy/latest
#${WTS_AP_XML}         airphone.xml
#&{GNB_ASIK}           ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
#
#
#${Egatelog_path}    ${CURDIR}
#*** Test Cases ***
#CB006112-ET-A-02-01 Verify FDD UL data Packet Aggregation will trigger when Radio signal become good
#    [Tags]     Owner_lading    case_A_02_01
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_FDD}
#    ...        AND    Suite Setup Update GNB    scf_file=${6112_scf_fdd}    swconfig_param=${SWCONFIG_PARAM_A_02_01}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Delta Commission With SCF File    ${SCF_DIR}/${DELTA_FILE_A_02_01}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    GBR And Non GBR UE Attach And PDU 5QI Setup
#    GBR And Non GBR Tput Start
#    Catch TTitrace With Streaming Mode And Convert To CSV For A0201
#    Verify UL PA Timer Enabled With Streaming Mode for AB201
#    Modify UE Signal    ${UE3_ID}    -450
#    Sleep    2s    reason=wait the sinr stable
#    GBR And Non GBR Tput Start
#    Catch TTitrace With Streaming Mode And Convert To CSV For A0201
#    Verify UL PA Timer Disabled With Streaming Mode
#
#CB006112-ET-B-10FDD Discard timer expires when DRX enable
#    [Tags]     Owner_yalsun    case_B10
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_FDD}
#    ...        AND    Suite Setup Update GNB    scf_file=${6112_scf_fdd}    swconfig_param=${SWCONFIG_PARAM_B10}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Delta Commission With SCF File    ${SCF_DIR}/${DELTA_FILE_B10}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    SA GBR Call For Multi UE    ${UE1_ID}
#    SA Start UDP DL Traffic For Multi UE    ${UE1_ID}    7070    40    160000    600
#    Check PM counter
#    Catch TTitrace With Streaming Mode And Convert To CSV
#    Verify DRX Enable
#    #Start TTI Trace Logs For BO SA FDD
#    Periodic Read PM Counter    M55302C10001    30min
#    Periodic Read PM Counter    M55300C12001    1min
#    SA Stop Traffic For Multi UE    7070
#    SA 5G Detach    ${UE1_ID}
#
#CB006112-ET-C-04FDD Adaptive VoIP TBS for Uplink when original TBS Too Large refer to PDU session setup.
#    [Tags]     Owner_suqian    case_C04
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_FDD}
#    ...        AND    Suite Setup Update GNB    scf_file=${6112_scf_fdd}    swconfig_param=${SWCONFIG_PARAM_C04}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Delta Commission With SCF File    ${SCF_DIR}/${DELTA_FILE_C04}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    Modify GuaranteedFlowBitRateDLUL    ${gfbr_dlul_100}
#    SA GBR Call For Multi UE    ${UE3_ID}
#    SA Start UDP DL Traffic For Multi UE    ${UE3_ID}    7074    40    16000    360
#    SA Start UDP UL Traffic For Multi UE    ${UE3_ID}    7075    40    16000    360
#    Sleep    30s
#    Start Ttitrace With Streaming Mode
#	Sleep    2s
#    Stop Ttitrace    log_dir=${OUTPUT_DIR}/tti
#    Decode Ttitrace Log    log_dir=${OUTPUT_DIR}/tti
#    Stop GBR Traffic
#    Release GBR UE
#    Verify UL VoipVcdTimerData As Expected For C04
#    Check PM Counter For C04
#
#CB006112-ET-C-06 FDD Adaptive VoIP TBS when UE from silence to talk
#    [Tags]     Owner_qianwu    case_C06
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_FDD}
#    ...        AND    Suite Setup Update GNB    scf_file=${6112_scf_fdd}    swconfig_param=${SWCONFIG_PARAM_C06}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Delta Commission With SCF File    ${SCF_DIR}/${DELTA_FILE_C06}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    SA Non GBR Call For Multi UE    ${UE1_ID}
#    SA GBR Call For Multi UE    ${UE3_ID}
#    SA Start UDP DL Traffic For Multi UE    ${UE1_ID}    7070    1400    5M    600
#    SA Start UDP UL Traffic For Multi UE    ${UE1_ID}    7071    1400    5M    600
#    SA Start UDP DL Traffic For Multi UE    ${UE3_ID}    7072    40    16000    600
#    SA Start UDP UL Traffic For Multi UE    ${UE3_ID}    7073    40    16000    600
#    Start Ttitrace With Streaming Mode
#    Modify guaranteedFlowBitRateDLUL    ${gfbr_dlul_5}
#    Modify 5QI 1 qosflows    ${UE3_ID}
#    Sleep    2s
#    Stop Ttitrace    log_dir=${OUTPUT_DIR}/tt2
#    Decode Ttitrace Log    log_dir=${OUTPUT_DIR}/tt2
#    Verify UL AdaptVoipPacketSize As Expected
