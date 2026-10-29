*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Resource         ./resources/CB009409_common_resources.robot

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Add RadParam to swconfig     "0x58057f=32"    "0x58057a=3"      IP=192.168.255.129
...                 AND     Find Scfc And Send Delta Commissioning     scfc_filename=TC2_TCPBoostPUG_Activation_AllUEs.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Check Cell On Air      ${wts_cfg_file}
...                 AND     sleep   10s

Suite Teardown      Run Keyword and Ignore Error   Kill WTS processes Using WTS_Runner

Documentation
...
...  AUTHOR          :  Ragunath Seenan
...  MAINTAINER      :  ragunath.seenan@nokia.com
...  INTRODUCTION    :  Check TCP UL PUG L3 Call Validation with the TCPBoostPUG Activation for All UEs
...                     NRCELL. actProactUlScheduling = false
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
...  TEST SET NAME   :  5GC009409_L3Call_Validation_With_TCPBoostPUG_Activation_AllUEs
...  TESTING SPLIT   :  CB009409-SR-A-a
...  CONTACTS        :  ragunath.seenan@nokia.com
...  REFERENCES      :  CFAM
...  REQUIREMENT ID  :  5G_RAN_USR_RRM_18942

*** Variables ***
${WTS_DIR}          /opt/iphy/latest
${wts_cfg_file}     ${WTS_DIR}/basic_setup.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${NOKIA_LOGIN}  toor4nsn
${NOKIA_PASS}   oZPS0POrRieRtu
${epc_log_path}    /tmp/
${sa_st_ue_id}      1
${sa_en_ue_id}      10
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
5GC009409_L3Call_Validation_With_TCPBoostPUG_Activation_AllUEs
    set test variable      ${LOG_PATH}
    MultiUE Register should be Successful with External Trf Type    ${sa_st_ue_id}    ${sa_st_ue_id}    pdu_id=1    nw_id=1

    Start Log    btslog    ttitrace    sherpa
    Start TCP Downlink Iperf Data    ${dl_ue_ip}    ${dl_port}    ${duration}
    Sleep    10s
    ${tcpdl_path}    Stop Log    sherpa    ttitrace    btslog    test_scenario=tcpDlData
    Stop Iperf Traffic

    Decode TTI Trace    tcpDlData

    Verify TCP Boost Grant event in ulPreSchedData    ${tcpdl_path}[ttitrace]/output_ul_formated.csv
    Verify ResReqClassPrio in ulTdSchedSubcellData    ${tcpdl_path}[ttitrace]/output_ul_formated.csv
    Verify TCP Indication and PUG entry in syslog    ${tcpdl_path}[btslog]/gnb_syslog.log
