*** Settings ***
Documentation
...    cmd: you need to change 2_16_UTE5GCLASSICAL1462 to your testline name.
...    robot -V /home/ute/Auto5G/config/Wroclaw/2_16_UTE5GCLASSICAL1686 -L trace check_gnb_state.robot
Resource         ./../common_setup_teardown.robot
*** Variables ***
*** Test Cases ***
Prepare Testline
    [Tags]    case1
    Suite Setup Update GNB    log=${False}
    Suite Setup Copy WTS Config Files From QT
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    [Teardown]    Run Keyword If Test Failed    Fatal Error    prepare testline failed!!!

Make Airphone Onair
    [Tags]    case2
    Start WTS And Check OnAir
    #Suite Setup Start WTS And Check OnAir

Check BTS Onair
    [Tags]    case3
    Run Keyword And Ignore Error    COAM.Teardown
    Verify BTS Is OnAir
    Verify All Cells Are OnAir

Restart Egate To Make Gnb Onair
    [Tags]    case4

    Set Suite Variable    ${WTS_CFG}    basic_setup.cfg
    Set Suite Variable    ${GNBCUTYPE}    SANSA
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Start WTS pcap
    Start WTS And Check OnAir
    Attach SA UE and Get Throughput
    [Teardown]    Stop WTS pcap

*** Keywords ***
#Suite Setup Copy WTS Config Files From QT
#    [Documentation]    This keyword is to copy the configuration files of WTS from QT by testline type.
#    ...    | QT config files | /home/ute/Auto5G/testsuite/QTPH1/AirPhone/resources. |
#    ...    | git path | https://wrgitlab.int.net.nokia.com/5G/robotws5g/tree/master/testsuite/QTPH1/AirPhone/resources |
#    ...
#    ...    | for SA testline | l1_mode is L1Bypass | file is like l1b_tdd_sa_cmwv/0.800/AirPhoneConfig_l1bypass_tdd_sa_cmwv.xml |
#    ...    | for NSA testline | l1_mode is FullStack | file is like  fs_fdd_nsa_cmwv/9.1800/AirPhoneConfig_fullstack_fdd_nsa_cmwv.xml |
#    Copy WTS Common Config Files

Start WTS pcap
    ${cmd}=    set variable    sudo tcpdump -i eth4 -w ${OUTPUT_DIR}/wts.pcap
    ${wts_pcap_id}=    start_process    ${cmd}    shell=True
    Set Suite Variable    ${wts_pcap_id}
    Run    ps aux|grep 'wts.pcap'

Stop WTS pcap
    Run    ps aux|grep 'wts.pcap'|awk '{print $2}'|xargs sudo kill -2
    terminate_process    ${wts_pcap_id}

Attach SA UE and Get Throughput
    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=100    ${ul_tp_set}=50    ${dl_tp_threshold}=5    ${ul_tp_threshold}=5
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
#    Wait Until Keyword Succeeds    3min    5s    SA UE Check Throughput    ${UE_ID}    ${dl_tp_threshold}    ${ul_tp_threshold}
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
    [Teardown]    SA 5G Detach    ue_id=${UE_ID}

#Enable WTS Debug Log
#sim_debug_log level=0
#debug_log level=0
#sim_debug_log level=0 mme=1
#sim_debug_log level=0 uec=1
#sim_debug_log level=0 pgw=1
#sim_debug_log level=0 sgw=1
#sim_debug_log level=0 enb=1

Start UTE WTS
    [Documentation]    This keyword is to kill Running WTS Binaries If Any, Configure ETH3, Retrieve Files And Configure WTS
    Log To Console    Starting WTS...
    Run Keyword And Ignore Error    Stop Edaemon Egate
    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}     save_egate=${True}
    ute_wtssim.Start Egate Process
    Run Keyword If    '${GNBCUTYPE}'=='SA'    ute_wtssim.Execute Egate Command    cfg file\=${WTS_DIR}/${WTS_CFG}
    ...    pass_regexp=SCTP proxy link
    ...  ELSE IF    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    ute_wtssim.Execute Egate Command    cfg file\=${WTS_DIR}/${WTS_CFG}
    ...    pass_regexp=(SimMode is ready now|UEC-1 is active)
    ...    ELSE    Log To Console    WARN: No cfg file is imported in egate console!!!
