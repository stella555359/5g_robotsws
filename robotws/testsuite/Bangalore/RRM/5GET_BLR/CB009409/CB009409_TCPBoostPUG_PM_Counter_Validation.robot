*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Resource         ./resources/CB009409_common_resources.robot

Suite Setup         Run keywords      Prepare TL with all config files
...                 AND     Add RadParam to swconfig     "0x58057f=32"    "0x58057a=3"      IP=192.168.255.129
...                 AND     Find Scfc And Send Delta Commissioning     scfc_filename=PM_Counters.json
#...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND    Configure UTE ETH3 IPs
...                 AND    Check Cell On Air    ${wts_cfg_file}
...                 AND     sleep   10s

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

Documentation
...
...  AUTHOR          :  Prerana N S
...  MAINTAINER      :  prerana.n_s@nokia.com
...  INTRODUCTION    :  This test is for check TCP UL PUG L3 Call Validation for PM Counters
...                     NRCELL.actProactUlScheduling = false
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
...                     Set the 5QI-6 instance of NRDRB.nrDrbTcpBoostDN equal to TCP boost profile
...  TEST SET NAME   :  5GC009409_L3Call_Validation_With_TCPBoostPUG_PM_Counter_Validation
...  TESTING SPLIT   :  CB009409-SR-A-a
...  CONTACTS        :  prerana.n_s@nokia.com
...  REFERENCES      :  CFAM
...  REQUIREMENT ID  :  5G_PM_953

*** Variables ***
${SCFC}         ${CURDIR}/config/SCF/Configuration_scf_PMcounter.xml
${AP_XML}       ${CURDIR}/config/SCF/iphy.xml

*** Variables ***
${WTS_DIR}          /opt/iphy/latest
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup1.cfg
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
${dl_ue_ip}    1.2.4.2
${dl_port}    7073
${ul_port}    7074
${duration}    -t 3600
${bytes}    -n 8000000
${ping_unit}    Kbps
${iperf_unit}    Mbps
${exp_dl_avg_ping}    1.4
${exp_ul_avg_ping}    2.8
${exp_dl_avg_iperf}    450
${exp_ul_avg_iperf}    220

*** Test Cases ***
[1]5GC009409_L3Call_Validation_With_TCPBoostPUG_PM_Counter_Validation
    set test variable      ${LOG_PATH}
    Log To Console  UE Register and Set External Traffic Type

    MultiUE Register should be Successful with External Trf Type    ${sa_st_ue_id}    ${sa_st_ue_id}    pdu_id=1    nw_id=1

    Wait until the next Measurement Period starts
    Start Log     ttitrace    btslog
    Start TCP Downlink Iperf Data    ${dl_ue_ip}    ${dl_port}    ${duration}
    sleep   3s
    ${tcpdl_path}   Stop Log    btslog    ttitrace    test_scenario=tcpDlData
    Wait until the current Measurement Period stops

    Get and Validate TCP BOOST TOTAL DURATION PM Counter
    Get and Validate TCP BOOST NUM OF CYCLES PM Counter
    Get and Validate TCP BOOST PROACTIVE UL GRANTS PM Counter

    Stop Iperf Traffic
    Validate AVG DL DATA TRAFFIC in UE STATS    ${sa_st_ue_id}    ${scell_idx}    ${iperf_unit}    ${exp_dl_avg_iperf}

    Decode TTI Trace    tcpDlData

 #   Verify TCP Indication and PUG entry in syslog    ${tcpdl_path}[btslog]/gnb_syslog.log
    Verify TCP Boost Grant event in ulPreSchedData    ${tcpdl_path}[ttitrace]/output_ul_formated.csv
    Verify ResReqClassPrio in ulTdSchedSubcellData    ${tcpdl_path}[ttitrace]/output_ul_formated.csv
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting
