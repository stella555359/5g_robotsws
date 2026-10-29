*** Settings ***
Documentation    ...
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup    Common Suite Setup
#Test Setup    Common Test Setup
#Test Teardown    Run Keyword And Ignore Error    Testcase Teardown
##Suite Teardown    Common Suite Teardown
#Force Tags    Classical    5GC001301    FR1    IPV4    Owner_xinwang    PRI-Medium
#...        RAN_5G_TDD    RAN_5G    CN1_SQ    SBTS00    SBTS23R1    SBTS22R4
#
#
#*** Variables ***
#${UE_ID}          1
#${GNB_ID}         2
#${CELL_ID}        2
#${BEARER_ID}      2
#${DST_FOR_FRM}    MRBTS-1/NRBTS-1/NRCELL-1
#${OK}      OK
#${DST_FOR_GROUP}    MRBTS-1/NRBTS-1/NRCELLGRP-0
#${PING_MATCH}     from\\s+[0-9,\.\:]+\\s+[a-z,\_\=]+\\d+\\s+[a-z,\=,0-9]+
#&{AP}                   hostname=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu
#&{GNB}                  hostname=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu
#${WEBUI_USER}           Nemuadmin
#${WEBUI_PWD}            nemuuser
#${SCFC_PATH}            ${CURDIR}/resources/scfc
#${WTS_DIR}              /opt/iphy/latest
#${WTS_CFG}              basic_fullstack_nsa_call_tdd_cmwv.cfg
#${WTS_AP_XML}           AirPhoneConfig_fullstack_tdd_nsa_cmwv.xml
#${PRACH_FORMAT_REG}     <prachPreambleFormat>[0-9]+</prachPreambleFormat>
#${START_SYMBOL_REG}     <prachStartSymbol>[0-9]+</prachStartSymbol>
#${SSB_PERIOD_REG}    <ssBurstSetPeriod>[0-9]+</ssBurstSetPeriod>
#${DL_BANDWIDTH_REG}    <dlBandwidth>[0-9]+</dlBandwidth>
#${UL_BANDWIDTH_REG}    <ulBandwidth>[0-9]+</ulBandwidth>
#${start_symbol_val_2}    2
#${start_symbol_val_8}    8
#${format_val}    13
#${ssb_period}    20
#${dl_bandwidth_80M}    217
#${ul_bandwidth_80M}    217
#${dl_bandwidth_100M}    273
#${ul_bandwidth_100M}    273
#${GNBCUTYPE}    NSA
#${SCF_PATH}    ${CURDIR}/config
#${RESOURCE_PATH}       ${CURDIR}/resources
#@{LOG_NAME_LIST}    btslog    tcpdump
#*** Test Cases ***
#5GC001301_A010_Verify_PRACH_format_C2_with_30kHz_scs_100MHz_bandwith_5GC001116_3ms_frame_structure_index192
#    [Tags]    case2    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#    Delta Commission With SCF File    ${SCF_PATH}/delta100MHz1116c192.json
#    Kill egate and edaemon process
#    Reboot TL And Check Configured
#    Onair and UE attach
#
#5GC001301_A013_Verify_PRACH_format_C2_with_30kHz_scs_100MHz_bandwith_5GC001116_3ms_frame_structure_index205
#    [Tags]    case5    CRT    CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#    Delta Commission With SCF File    ${SCF_PATH}/delta100MHz1116c205.json
#    Kill egate and edaemon process
#    Reboot TL And Check Configured
#    Onair and UE attach
#
##5GC001301_A020_Verify_PRACH_format_C2_with_30kHz_scs_80MHz_bandwith_5GC001116_0ms_frame_structure_index198
#    #[Tags]    case11    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#    #Delta Commission With SCF File    ${SCF_PATH}/delta80MHz11160198.json
#    #Kill egate and edaemon process
#    #Reboot TL And Check Configured
#    #Onair and UE attach
#
##5GC001301_A021_Verify_PRACH_format_C2_with_30kHz_scs_100MHz_bandwith_5GC001070_frame_structure_index189
#    #[Tags]    case12    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#    #Delta Commission With SCF File    ${SCF_PATH}/delta100MHz1070189.json
#    #Kill egate and edaemon process
#    #Reboot TL And Check Configured
#    #Onair and UE attach
#
##5GC001301_A025_Verify_PRACH_format_C2_with_30kHz_scs_80MHz_bandwith_5GC001070_frame_structure_index202
#    #[Tags]    case16    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#    #Delta Commission With SCF File    ${SCF_PATH}/delta80MHz1070202.json
#    #Kill egate and edaemon process
#    #Reboot TL And Check Configured
#    #Onair and UE attach
#
#5GC001301_A027_Verify_PRACH_format_C2_with_30kHz_scs_100MHz_bandwith_5GC001208_frame_structure_index196
#    [Tags]    case18    CIT    CDRT    SBTS22R3    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#    Delta Commission With SCF File    ${SCF_PATH}/delta100MHz1208196.json
#    Kill egate and edaemon process
#    Reboot TL And Check Configured
#    Onair and UE attach
#
#*** Keywords ***
#Common Suite Setup
#    Suite Setup Update GNB
#    Suite Setup Copy WTS Config Files From QT
#
#
#Common Test Setup
#    [Arguments]    ${delta_jason}=${none}
#    Create Test Directory
#    Run Keyword If    '${delta_jason}' != '${none}'    Backup Scf    ${TEST_LOG_DIRECTORY}    before_case
#    Run Keyword If    '${delta_jason}' != '${none}'    Delta Commission With SCF File    ${delta_jason}
#    Run Keyword If    '${delta_jason}' != '${none}'    Backup Scf    ${TEST_LOG_DIRECTORY}    after_case
#    common_log_capture.Start Logs    ${log_name_list}
#    Run Keyword If    '${GNBCUTYPE}'=='NSA'    common_log_capture.Start Sos Report
#
#Easy Common Suite Setup
#    Create Suite Directory
#    Kill egate and edaemon process
#    Suite Setup Start WTS And Check OnAir
#
#Onair and UE attach
#    Suite Setup Start WTS And Check OnAir
#    ${UE_ID}=    Set Variable If    "${GNBCUTYPE}"=="SANSA"    101    ${UE_ID}
#    Set Suite Variable    ${UE_ID}    ${UE_ID}
#    Setup X2 Connection
#    NSA LTE Attach    ue_id=${UE_ID}    profile_id=1
#    Sleep    5s
#    NSA 5G Attach    ue_id=${UE_ID}    gnb_id=2    cell_id=1    bearer_id=2
#    NSA Start DL Traffic    ue_id=${UE_ID}    bearer_id=2    mbps=10
#    NSA Start UL Traffic    ue_id=${UE_ID}    bearer_id=2    mbps=10
#    NSA Check Average Traffic Bigger Than Target    ue_id=${UE_ID}    bearer_id=2    dir=dl    tp_rate=9
#    NSA Check Average Traffic Bigger Than Target    ue_id=${UE_ID}    bearer_id=2    dir=ul    tp_rate=5
#
#Kill egate and edaemon process
#    OperatingSystem.run    sudo pkill edaemon
#    OperatingSystem.run    sudo pkill egate
#    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
#
#Modify AP XML file
#    &{xml_params_dict}    Create Dictionary    prachPreambleFormat=13    prachStartSymbol=2    ssBurstSetPeriod=20
#    ...    dlBandwidth=${dl_bandwidth_100M}    ulBandwidth=${ul_bandwidth_100M}
#    Modify XML File    ${WTS_DIR}/${WTS_AP_XML}    ${xml_params_dict}
#
#
#Suite Setup Start WTS And Check OnAir
#    [Documentation]    This keyword is to modify vlan, start WTS, wait for onAir
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    Start UTE WTS
#    Run Keyword If    '${GNBCUTYPE}'=='NSA'    Setup X2 Connection
#    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
#    Verify Cell Setup
#    #Run Keyword And Ignore Error    Stop Cell Setup Logs
#
#Testcase Teardown
#    Common Test Teardown
#    clean edaemon and egate
#
#clean edaemon and egate
#    ute_wtssim.Teardown Edaemon    alias=edaemon
#    ute_wtssim.Teardown Egate
