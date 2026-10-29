*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Resource         ./resources/CB009409_common_resources.robot
Resource         ../resources/robot/common_log_collection.robot
Library          ./resources/python/verify_tcppug_syslog.py

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Add RadParam to swconfig     "0x58057f=32"    "0x58057a=3"      IP=192.168.255.129
...                 AND     Find Scfc And Send Delta Commissioning     scfc_filename=TC2_TCPBoostPUG_Activation_AllUEs.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Check Cell On Air      ${wts_cfg_file}
...                 AND     sleep   5s

Suite Teardown      Run Keyword and Ignore Error   Kill WTS processes Using WTS_Runner
Test Teardown      Link SCOUT SCF to Configuration ID for Reporting

Documentation
...
...  AUTHOR          :  Ragunath Seenan
...  MAINTAINER      :  ragunath.seenan@nokia.com
...  INTRODUCTION    :  This test is for check TCP UL PUG L3 Multi UE Call Validation
...                     NRCELL. actProactUlScheduling = falsel
...                     NRCELL.actUlTxSkip = true
...                     NRCELL.srPeriodicity = 40ms
...                     NRCELL.actTcpBoostPug = 1 "all UE's"
...                     NRBTS.NRDRB_TCP_BOOST parameter values:
...                     tcpBoostPugInactiveTime = 100ms
...                     tcpBoostPugMinDataSize = 3 kbytes
...                     tcpBoostPugDuration = 2000ms
...                     tcpBoostPugRampUpDuration = 100ms
...                     tcpBoostPugRampUpInterval = 5ms
...                     tcpBoostPugStableInterval = 20ms
...                     tcpBoostPugTbs = 800 bits
...                     tcpBoostPugMinSrPeriodicity = 40ms
...                     tcpBoostPugUlMinSinrThresh = 0 dB
...                     Set the 5QI-9 instance of NRDRB.nrDrbTcpBoostDN equal to TCP boost profile
...  TEST SET NAME   :  5GC009409_L3Call_Validation_With_TCPBoostPUG_With_MultiUE_NonGBR
...  TESTING SPLIT   :  CB009409-SR-A-a
...  CONTACTS        :  ragunath.seenan@nokia.com
...  REFERENCES      :  CFAM
...  REQUIREMENT ID  :  5G_RAN_USR_RRM_19080

*** Variables ***
${WTS_DIR}          /opt/iphy/latest
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_tc2.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${NOKIA_LOGIN}  toor4nsn
${NOKIA_PASS}   oZPS0POrRieRtu
${epc_log_path}    /tmp/
${sa_st_ue_id}      1
${sa_en_ue_id}      1
${nsa_st_ue_id}      110
${nsa_en_ue_id}      120
${scell_idx}    0
${ul_ue_ip}    72.23.0.1
${dl_ue_ip_1}    1.2.4.2
${dl_ue_ip_2}    1.2.4.3
${dl_port_1}    7080
${dl_port_2}    7074
${duration}    -t 1000 -b 50M
${bytes}    -n 8000000
${ping_unit}    Kbps
${iperf_unit}    Mbps
${exp_dl_avg_ping}    1.4
${exp_ul_avg_ping}    2.8
${exp_dl_avg_iperf}    450
${exp_ul_avg_iperf}    220

*** Test Cases ***
5GC009409_L3Call_Validation_With_TCPBoostPUG_With_MultiUE_NonGBR
    set test variable      ${LOG_PATH}
    Trigger UE attach and verify TCPPUG      ${dl_port_1}      1208
    Find Scfc And Send Delta Commissioning     scfc_filename=TC2_CB008406_TDDframe.json
    sleep   300s
    Trigger UE attach and verify TCPPUG      ${dl_port_2}      8406

*** Keywords ***

Verify_TCPPUG_syslog
    [Arguments]    ${path}      ${tddframe}
    ${result1}       verify_tcppug_syslog.tcppug_syslog      ${path}
    log to console     ${result1}
    Run Keyword If    ${tddframe} == 8406      Should Be True    ${result1}[2]>35
    Run Keyword If    ${tddframe} == 8406      Should Be True    ${result1}[2]<41
    Run Keyword If    ${tddframe} == 1208      Should Be True    ${result1}[0]>75
    Run Keyword If    ${tddframe} == 1208      Should Be True    ${result1}[0]<81
    Should Be True    ${result1}[1] > 85

Trigger UE attach and verify TCPPUG
    [Arguments]    ${port}      ${tddframe}
    MultiUE Register should be Successful with External Trf Type    ${sa_st_ue_id}    ${sa_en_ue_id}    pdu_id=1    nw_id=1
    UE PDU Modfication should be Successful     ${sa_en_ue_id}   pdu_id=${sa_en_ue_id}    qosflows_to_add=4
#    Start Log    btslog    ttitrace
    Start Log    btslog
    Start TCP Downlink Iperf Data    ${dl_ue_ip_1}    ${port}    ${duration}
#    Start TCP Downlink Iperf Data    ${dl_ue_ip_2}    ${dl_port_2}    ${duration}
    Sleep    2s
    ${tcpdl_path}    Stop Log     btslog    test_scenario=tcpDlData_${port}
    Stop Iperf Traffic
#    Decode TTI Trace    tcpDlData
#    Verify MultiUE TCP Boost Grant event in ulPreSchedData    ${tcpdl_path}[ttitrace]/output_ul_formated.csv    ${crnti_list}
#    Verify MultiUE ResReqClassPrio in ulTdSchedSubcellData    ${tcpdl_path}[ttitrace]/output_ul_formated.csv    ${crnti_list}
    UE Deregister should be Successful     ${sa_st_ue_id}
    Verify MultiUE TCP Indication and PUG entry in syslog    ${tcpdl_path}[btslog]/gnb_syslog.log    ${crnti_list}
    Verify_TCPPUG_syslog      ${tcpdl_path}[btslog]/gnb_syslog.log      ${tddframe}


