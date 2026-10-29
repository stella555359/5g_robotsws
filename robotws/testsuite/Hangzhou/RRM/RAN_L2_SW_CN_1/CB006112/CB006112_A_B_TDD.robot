*** Settings ***
Documentation    ...
#Resource    ./CB006112_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Library           ./../CUDU_L2/scripts/python/ttitrace_data_parser.py
#Library           ./../CUDU_L2/scripts/python/get_csv_data.py
#Library           ./../CUDU_L2/scripts/python/streaming_ttitrace_analyzer.py
#Library           ./config/CB006112_A_PA2_13.py
#Library           ./config/csv_parser.py
#Suite Setup       Run Keywords    Common Suite Setup 2
#...               AND    Prepare QT LOLO Enviroment    TYPE=TDD
#Test Teardown      Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    SBTS22R4
#...                RAN_5G    RAN_5G_TDD    CRT
#*** Variables ***
#${SWCONFIG_PARAM_A_PA2_07}        0x5800F3=1;0x590072=1;0x41001b=1;0x5801d0=0;
#${WTS_CFG_TDD}     wts_cfg_ASIL_ABIO_TDD.cfg
#
#${DELTA_FILE_A_PA2_13}         Delta_Conf_TDD_CB006112_A_PA2_13.json
#${SWCONFIG_PARAM_A_PA2_13}        0x5800F3=1;0x590072=1;0x41001b=1;0x5801d0=0;
#
#${DELTA_FILE_A_B3_01}         Delta_Conf_TDD_CB006112_A_B3_01.json
#${SWCONFIG_PARAM_A_B3_01}        0x5800F3=1;0x590072=1;0x41001b=1;0x5801d0=0;
#
#${DELTA_FILE_B02}         Delta_Conf_TDD_CB006112_B02.json
#${SWCONFIG_PARAM_B02}        0x5800F3=1;0x590072=1;0x41001b=1;0x5801d0=0;
#${WTS_CFG_TDD_DRX}     wts_cfg_ASIL_ABIO_TDD_DRX.cfg
#${delta_json}         ${CURDIR}/config/Delta_Conf_CB006112_ET_B_02_modify_actVoipPacketAggr.json
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
#${WTS_DIR}            /opt/iphy/latest
#${WTS_AP_XML}         airphone.xml
#&{GNB_ASIK}           ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
#
#
#${Egatelog_path}    ${CURDIR}
#*** Test Cases ***
#CB006112-ET-A-PA2-07 FDD Intermittent UL and DL voice package transfer successfully when 20ms PA timer expires.
#    [Tags]     Owner_yalsun    case_A_PA2_07
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_TDD}
#    ...        AND    Suite Setup Update GNB    scf_file=${6112_scf_tdd}    swconfig_param=${SWCONFIG_PARAM_A_PA2_07}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    SA Non GBR Call For Multi UE    ${UE1_ID}
#    SA Non GBR Call For Multi UE    ${UE2_ID}
#    SA GBR Call For Multi UE    ${UE3_ID}
#    Start UL And DL Traffic To Make High Load
#    Start UL And DL Voice Traffic Per 30ms
#    Catch TTitrace With Streaming Mode And Convert To CSV
#    Verify DL PA Timer Enable With Streaming Mode
#    Verify UL PA Timer Enable With Streaming Mode
#    Stop Data Transfer
#    Release UE
#
#CB006112-ET-A-PA2-13 voice package transfer successfully when SR period is 20ms.
#    [Tags]     Owner_yalsun    case_A_PA2_13
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_TDD}
#    ...        AND    Suite Setup Update GNB    scf_file=${6112_scf_tdd}    swconfig_param=${SWCONFIG_PARAM_A_PA2_13}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Delta Commission With SCF File    ${SCF_DIR}/${DELTA_FILE_A_PA2_13}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    SA Non GBR Call For Multi UE    ${UE1_ID}
#    SA Non GBR Call For Multi UE    ${UE2_ID}
#    SA GBR Call For Multi UE    ${UE3_ID}
#    SA Start UDP DL Traffic For Multi UE    ${UE1_ID}    7070    1400    10M    60
#    SA Start UDP UL Traffic For Multi UE    ${UE1_ID}    7071    1400    10M    60
#    SA Start UDP DL Traffic For Multi UE    ${UE2_ID}    7072    1400    10M    60
#    SA Start UDP UL Traffic For Multi UE    ${UE2_ID}    7073    1400    10M    60
#    SA Start UDP DL Traffic For Multi UE    ${UE3_ID}    7074    40    16000    360
#    SA Start UDP UL Traffic For Multi UE    ${UE3_ID}    7075    40    16000    360
#    Catch TTitrace With Streaming Mode And Convert To CSV
#    Verify DL PA Timer Enable With Streaming Mode
#    Stop Non GBR Data Transfer
#    Catch TTitrace With Streaming Mode And Convert To CSV
#    Verify DL PA Timer Disable
#    Verify UL PA Timer Disable
#    Stop GBR Data Transfer
#    Release GBR UE
#
#CB006112-ET-A-B3-01 TDD PDU Session Resource Setup for one PDU session (subsequent) with 5QI-5 setup
#    [Tags]     Owner_lading    case_A_B3_01
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_TDD}
#    ...        AND    Suite Setup Update GNB    scf_file=${6112_scf_tdd}    swconfig_param=${SWCONFIG_PARAM_A_B3_01}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Delta Commission With SCF File    ${SCF_DIR}/${DELTA_FILE_A_B3_01}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    Log To Console    ***Non-GBR UE1, UE2, UE3 attach and pdu session setup***
#    SA Non GBR Call For Multi UE    ${UE1_ID}
#    SA Non GBR Call For Multi UE    ${UE2_ID}
#    SA Non GBR Call For Multi UE    ${UE3_ID}
#    Log To Console    ***Make Non-GBR TCP L3 call for UE1***
#    SA Start TCP DL Traffic For Multi UE    ${UE3_ID}    7070    1400    120
#    SA Start TCP UL Traffic For Multi UE    ${UE3_ID}    7071    1400    120
#    SA Start UDP DL Traffic For Multi UE    ${UE1_ID}    7072    1400    200M
#    SA Start UDP UL Traffic For Multi UE    ${UE1_ID}    7073    1400    100M
#    SA Start UDP DL Traffic For Multi UE    ${UE2_ID}    7074    1400    200M
#    SA Start UDP UL Traffic For Multi UE    ${UE2_ID}    7075    1400    100M
#    Sleep     3s
#    Log To Console    ***Modify UE1 to 5QI 1***
#    Trigger 5QI 5 Setup    ${UE3_ID}
#    Trigger 5QI 1 Setup    ${UE3_ID}
#    Log To Console    ***Make GBR UDP call for UE1***
#    SA Start UDP DL Traffic For Multi UE    ${UE3_ID}    7076    40    16000    120
#    SA Start UDP UL Traffic For Multi UE    ${UE3_ID}    7077    40    16000    120
#    Sleep     3s
#    Log To Console    ***TTI Trace***
#    #Catch TTitrace With Streaming Mode And Convert To CSV
#    Catch TTitrace With Streaming Mode And Convert To CSV For A0201
#    Verify DL PA Timer Enable With Streaming Mode
#    Verify UL PA Timer Enable With Streaming Mode
##    Catch Ttitrace Log    wait_time=5s
##    Decode TTI Trace And Send To Control PC One By One    ${OUTPUT_DIR}/tti
#    Check Timers are right    5346    2676    22539    2671    1211709
##    Verify DL PA Timer Enable For 6112 B3 01
##    Verify UL PA Timer Enable For 6112 B3 01
#    #Log To Console    ***Stop the Non-GBR call***
#    #SA Stop Traffic For Multi UE    7070    7071
#    #Log To Console    ***Stop the GBR call***
#    #SA Stop Traffic For Multi UE    7072    7073
#    #Log To Console    ***Detach the UE1***
#    #SA 5G Detach    1
#
#CB006112-ET-B-02TDD successfully setup GBR and non GBR call when enable DRX for Voice call
#    [Tags]     Owner_yalsun    case_B02
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_TDD_DRX}
#    ...        AND    Suite Setup Update GNB    scf_file=${6112_scf_tdd}    swconfig_param=${SWCONFIG_PARAM_B02}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Delta Commission With SCF File    ${SCF_DIR}/${DELTA_FILE_B02}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    SA Non GBR Call For Multi UE    ${UE1_ID}
#    SA Non GBR Call For Multi UE    ${UE2_ID}
#    SA GBR Call For Multi UE    ${UE3_ID}
#    SA Start UDP DL Traffic For Multi UE    ${UE1_ID}    7070    1400    300M
#    SA Start UDP UL Traffic For Multi UE    ${UE1_ID}    7071    1400    100M
#    SA Start UDP DL Traffic For Multi UE    ${UE2_ID}    7072    1400    300M
#    SA Start UDP UL Traffic For Multi UE    ${UE2_ID}    7073    1400    100M
#    SA Start UDP UL Traffic For Multi UE    ${UE3_ID}    7074    40    16000
#    Catch TTitrace With Streaming Mode And Convert To CSV
#    Verify UL PA Timer Enable With Streaming Mode
#    Compare Counter
#    Catch TTitrace With Streaming Mode And Convert To CSV
#    Verify UL PA Timer Disable With Streaming Mode
#    Stop Data Transfer
