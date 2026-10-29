*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CRT    RAN_5G_TDD      SBTS00   SBTS23R1    CONFIGURED

Resource         resources/CB009409_common_resources.robot
Resource         ../../../resources/robot/common_log_collection.robot
Library          resources/PDU_Status.py

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Add RadParam to swconfig     "0x58057f=32"    "0x58057a=3"      IP=192.168.255.129
...                 AND     Find Scfc And Send Delta Commissioning     scfc_filename=TC05_DELTA.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Check Cell On Air      ${wts_cfg_file}
...                 AND     sleep   10s

Suite Teardown      Run Keyword and Ignore Error   Kill WTS processes Using WTS_Runner
Test Teardown      Link SCOUT SCF to Configuration ID for Reporting

Documentation
...
...  AUTHOR          :  Shankar Karalatti
...  MAINTAINER      :  shankar.karalatti@nokia.com
...  INTRODUCTION    :  Check TCP UL PUG L3 Call and RLCPDU stats with their highestClassPriority
...                     NRCELL. actProactUlScheduling = false
...                     NRCELL.actUlTxSkip = true
...                     NRCELL.srPeriodicity = 40ms
...                     NRCELL.srPeriodicitymin = 20ms
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
...  TEST SET NAME   :  5GC009409_C_L3Call_Validation_With_TCPBoostPUG_Multi_UE_Different_DRB
...  TESTING SPLIT   :  CB009409-C
...  CONTACTS        :  Shaknar.karalatti@nokia.com
...  REFERENCES      :  CFAM
...  REQUIREMENT ID  :  5G_UP_ALG_22387, 5G_L2_12874, 5G_L2_12196

*** Variables ***

${wts_cfg_file}     ${CURDIR}/config/wts/egate_TMOUS_2.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${NOKIA_LOGIN}  toor4nsn
${NOKIA_PASS}   oZPS0POrRieRtu
${epc_log_path}    /tmp/
${sa_st_ue_id_1}      1
${sa_en_ue_id_1}      5
${sa_st_ue_id_2}      6
${sa_en_ue_id_2}      10
${nsa_st_ue_id}      11
${nsa_en_ue_id}      20
${scell_idx}    0
${ul_ue_ip}    72.23.0.1
${dl_ue_ip}    1.2.4.2
${duration}    -t 3600
${bytes}    -n 8000000
${ping_unit}    Kbps
${iperf_unit}    Mbps
${exp_dl_avg_ping}    1.4
${exp_ul_avg_ping}    2.8
${exp_dl_avg_iperf}    450
${exp_ul_avg_iperf}    220
${port}    7073

*** Test Cases ***
[1]5GC009409_C_L3Call_Validation_With_TCPBoostPUG_Multi_UE_Different_DRB
    set test variable      ${LOG_PATH}
    ${RLC_Ues}	MultiUE Register should be Successful with External Trf Type    ${sa_st_ue_id_1}
    ...    ${sa_en_ue_id_1}    pdu_id=1    nw_id=1
	${Tcp_Boost_Ues}    MultiUE Register should be Successful with External Trf Type    ${sa_st_ue_id_2}
    ...   ${sa_en_ue_id_2}    pdu_id=1    nw_id=2
    Start Log    btslog     ttitrace
	Multi UE external TCP data
    Sleep    2s
    ${tcpdl_path}    Stop Log        btslog     ttitrace   test_scenario=tcpDlData
    Stop Iperf Traffic

    Decode TTI Trace    tcpDlData

    Check_Entrygrant    ${tcpdl_path}[ttitrace]/output_ul_formated.csv     ${RLC_Ues}
    Check_TCPBoost      ${tcpdl_path}[ttitrace]/output_ul_formated.csv     ${Tcp_Boost_Ues}
    check_respReqClassPrio     ${tcpdl_path}[ttitrace]/output_ul.csv       ${Tcp_Boost_Ues}

***Keywords***

Multi UE external TCP data
	FOR  ${I}   IN RANGE   ${2}  ${12}
		${port}   evaluate    ${7071}+${I}
		Start TCP Downlink Iperf Data    1.2.4.${I} 	${port}   ${duration}
	END
