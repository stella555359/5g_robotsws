*** Settings ***
Documentation    ...
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup    Common Suite Setup
#Test Setup    Common Test Setup 2
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags    Classical    5GC001301    FR1    IPV4    Owner_xinwang    PRI-Medium
#...    CRT    RAN_5G_TDD    RAN_5G
#...    SBTS00    SBTS23R1    SBTS22R4    CN1_SQ    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
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
#${PRACH_FORMAT_REG}     <prachPreambleFormat>[0-9]+</prachPreambleFormat>
#${START_SYMBOL_REG}     <prachStartSymbol>[0-9]+</prachStartSymbol>
#${SSB_PERIOD_REG}       <ssBurstSetPeriod>[0-9]+</ssBurstSetPeriod>
#${DL_BANDWIDTH_REG}     <dlBandwidth>[0-9]+</dlBandwidth>
#${UL_BANDWIDTH_REG}     <ulBandwidth>[0-9]+</ulBandwidth>
#${GNBCUTYPE}            NSA
#${RESOURCE_PATH}        ${CURDIR}/resources
#@{LOG_NAME_LIST}        btslog    tcpdump
#${SCF_DIR}              ${CURDIR}/config
#${SCF_1301}             ${SCF_DIR}/SCF_1301.xml
#${LOCAL_WTS_DIR}        ${CURDIR}/Resource/
#${WTS_CFG}              basic_setup.cfg
#${iphy_file}           ${SCF_DIR}/iphy.xml
#
#*** Test Cases ***
#5GC001301_ET_A030_Verify_PRACH_format_C2_with_30kHz_scs_80MHz_bandwith_1208_frame_structure_Based_on_non_competition_random_access_index189
#    [Tags]    case1
#    Backup And Update Iphy Swconfig File    ${iphy_file}
#    Setup TL For Each Case    ${SCF_1301}    ${WTS_CFG}
#    Delta Commission With SCF File    ${SCF_DIR}/delta189.json
#    Reboot TL And Check Configured
#    Onair And UE Attach
#    HO From Real GNB To Sim GNB
#    HO From Sim GNB To Real GNB
#
#5GC001301_ET_A037_Verify_PRACH_format_C2_with_30kHz_scs_80MHz_bandwith_1208_frame_structure_Based_on_non_competition_random_access_index205
#    [Tags]    case5
#    Backup And Update Iphy Swconfig File    ${iphy_file}
#    Setup TL For Each Case    ${SCF_1301}    ${WTS_CFG}
#    Delta Commission With SCF File    ${SCF_DIR}/delta205.json
#    Reboot TL And Check Configured
#    Onair And UE Attach
#    HO From Real GNB To Sim GNB
#    HO From Sim GNB To Real GNB
#
#*** Keywords ***
#Common Suite Setup
#    Suite Setup Update GNB
#    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#
#Common Test Setup
#    [Arguments]    ${delta_jason}=${none}
#    Create Test Directory
#    Run Keyword If    '${delta_jason}' != '${none}'    Backup Scf    ${TEST_LOG_DIRECTORY}    before_case
#    Run Keyword If    '${delta_jason}' != '${none}'    Delta Commission With SCF File    ${delta_jason}
#    Run Keyword If    '${delta_jason}' != '${none}'    Backup Scf    ${TEST_LOG_DIRECTORY}    after_case
#    common_log_capture.Start Logs    ${LOG_NAME_LIST}
#    Run Keyword If    '${GNBCUTYPE}'=='NSA'    common_log_capture.Start Sos Report
#
#Setup TL For Each Case
#    [Arguments]    ${scf_file}    ${wts_cfg_name}
#    Verify Coam Site Is Ready
#    Common Test Setup 2
#    Full Commission With SCF File    ${scf_file}
#    Reboot TL And Check Configured
#
#Onair And UE Attach
#    Suite Setup Start WTS And Check OnAir
#    Sleep    60s
#    Setup X2 With Real GNB
#    Setup X2 With Sim GNB
#    NSA LTE Attach    ue_id=11    profile_id=1
#    Sleep    10s
#    NSA 5G Attach    ue_id=11    gnb_id=2    cell_id=1    bearer_id=2
#
#HO From Real GNB To Sim GNB
#    [Documentation]    This keyword is to HO from Real gNB to Sim gNB
#    Log To Console    HO from Real gNB to Sim gNB...
#    ${pattern}    Set Variable    Bearer-type change from MCG to SCG-split is successful
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ue_measurement_send_nr id\=11 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=381 nrsrp_nr\=20 nrsrq_nr\=20
#    ...    pass_regexp=${pattern}    timeout=5min
#    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
#    Log To Console    \n${output}
#    Log    HO_from_Real_gNB_to_Sim_gNB_ok
#
#HO From Sim GNB To Real GNB
#    [Documentation]    This keyword is to HO from Sim gNB to Real gNB
#    ${cmd}    Catenate    ue_measurement_send_nr id\=11 meas_id\=3 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=50 nrsrp_nr\=50
#    ...    nrsrq_nr\=50 rs_type\=ssb index\=0 nrs_result\=30:30:30
#    Log To Console    HO from Sim gNB to Real gNB...
#    ${pattern}    Set Variable    Inter Sgnb Handover is successful
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}
#    ...    pass_regexp=${pattern}    timeout=5min
#    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
#    Log To Console    \n${output}
#    Log    HO_from_Sim_gNB_to_Real_gNB_ok
#
#Setup X2 With Sim GNB
#    [Documentation]    This keyword is to setup X2 connection with sim gNB
#    Log To Console    setup X2 connection to sim gNB...
#    ${pattern}    Set Variable    ENB-1: X2AP Link with GNB-3 .* is up
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    enb_x2_link_up enb\=1 target\=3
#    ...    pass_regexp=${pattern}    timeout=5min
#    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
#    Log To Console    \n${output}
#    Log    x2_with_simgNB_is_ok
#
#Setup X2 With Real GNB
#    [Documentation]    This keyword is to setup X2 connection with real gNB
#    Log To Console    setup X2 connection to real gNB...
#    ${pattern}    Set Variable    ENB-1: X2AP Link with GNB-2 .* is up
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    enb_x2_link_up enb\=1 target\=2
#    ...    pass_regexp=${pattern}    timeout=5min
#    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
#    Log To Console    \n${output}
#    Log    x2_with_realgNB_is_ok
#
#Suite Setup Start WTS And Check OnAir
#    [Documentation]    This keyword is to modify vlan, start WTS, wait for onAir
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3 For HO
#    Start UTE WTS
#
#Configure UTE ETH3 For HO
#    Log To Console    configure VM interfaces...
#    OperatingSystem.Run    sudo ifconfig eth3:mme 10.0.1.131/24 up
#    OperatingSystem.Run    sudo ifconfig eth3:ser 10.0.1.132/24 up
#    OperatingSystem.Run    sudo ifconfig eth3:sgwu 10.0.1.133/24 up
#    OperatingSystem.Run    sudo ifconfig eth3:sgwl 10.0.1.134/24 up
#    OperatingSystem.Run    sudo ifconfig eth3:enb 10.0.1.99/24 up
#    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
#    OperatingSystem.Run    sudo ifconfig eth3:gnb3 10.0.1.122/24 up
#    OperatingSystem.Run    sudo ifconfig eth3:gnb4 10.0.1.123/24 up
#    OperatingSystem.Run    sudo ifconfig eth3:gnb5 10.0.1.124/24 up
#    OperatingSystem.Run    sudo ifconfig eth3:gnb6 10.0.1.125/24 up
#    OperatingSystem.Run    sudo ip addr add 10.0.1.14/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.15/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.16/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.17/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.18/24 dev eth3
#    OperatingSystem.Run    sudo ip address add 10.0.1.127/24 brd + label eth3:enb11 dev eth3
#    OperatingSystem.Run    sudo ip address add 10.0.1.137/24 dev eth3
#    OperatingSystem.Run    sudo ip address add 10.0.1.138/24 dev eth3
#    OperatingSystem.Run    sudo ip address add 10.0.1.139/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.129/24 dev eth3
#    OperatingSystem.Run    sudo ifconfig eth3:enb21 10.0.1.97/24 up
#    OperatingSystem.Run    sudo ip addr add 10.0.1.145/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.127/24 dev eth3
#    OperatingSystem.Run    sudo ifconfig eth3:enb51 10.0.1.96/24 up
#    OperatingSystem.Run    sudo ip addr add 10.0.1.146/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.126/24 dev eth3
#    OperatingSystem.Run    sudo ifconfig eth3:enb41 10.0.1.95/24 up
#    OperatingSystem.Run    sudo ip addr add 10.0.1.147/24 dev eth3
#    OperatingSystem.Run    sudo ifconfig eth3:enb_x2 10.0.1.135/24 up
#    OperatingSystem.Run    sudo ifconfig eth3:gnb_x2 10.0.1.136/24 up
#    OperatingSystem.Run    sudo ip addr del 10.0.1.200/24 dev eth3
#    OperatingSystem.Run    sudo ip addr del 10.0.2.1/24 dev eth4
#    OperatingSystem.Run    sudo ip addr add 10.0.1.1/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.2.121/24 dev eth4
#    OperatingSystem.Run    sudo ip addr add 10.0.1.9/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.10/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.11/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.12/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.13/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.2.90/24 dev eth4
#    OperatingSystem.Run    sudo ip addr add 10.0.2.91/24 dev eth4
#    OperatingSystem.Run    sudo ip addr add 10.0.2.92/24 dev eth4
#    OperatingSystem.Run    sudo ip addr add 10.0.1.122/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.123/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.124/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.125/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add fc00::10:0:1:3/112 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.2.93/24 dev eth4
#    OperatingSystem.Run    sudo ip addr add 10.0.1.112/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.102/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.103/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.104/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.105/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.106/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.128/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.2.1/24 dev eth4
#    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
