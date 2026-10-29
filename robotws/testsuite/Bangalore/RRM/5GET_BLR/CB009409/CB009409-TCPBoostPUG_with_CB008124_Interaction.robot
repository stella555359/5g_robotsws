*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Resource         ./resources/CB009409_common_resources.robot

Suite Setup           Run keywords    Prepare TL with all config files
...                 AND     Add RadParam to swconfig     "0x58057f=32"    "0x58057a=3"      IP=192.168.255.129
...                 AND     Find Scfc And Send Delta Commissioning     scfc_filename=VoNR_Interaction.json
#...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND    Configure UTE ETH3 IPs
...                 AND     Check Cell On Air      ${wts_cfg_file}

Suite Teardown      Run Keyword and Ignore Error   Kill WTS processes Using WTS_Runner

Documentation
...
...  AUTHOR          :  Prerana N S
...  MAINTAINER      :  prerana.n_s@nokia.com
...  INTRODUCTION    :  This test is for check TCP UL PUG L3 Call Validation with FIM CB008124
...                     NRCELL.actProactUlScheduling = false
...                     NRCELL.actUlTxSkip = true
...                     NRCELL.srPeriodicity = 40ms
...                     NRCELL.actTcpBoostPug = 1 "all UE's"
...                     NRCELL. actUlCgType2 = true #CB008124 Enabled
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
...  TEST SET NAME   :  5GC009409_L3Call_Validation_With_TCPBoostPUG_With_FIM_CB008124
...  TESTING SPLIT   :  CB009409-SR-B-b
...  CONTACTS        :  prerana.n_s@nokia.com
...  REFERENCES      :  CFAM
...  REQUIREMENT ID  :  5G_RAN_USR_RRM_18946

*** Variables ***
${WTS_DIR}          /opt/iphy/latest
${wts_cfg_file}     ${CURDIR}/config/wts/FDD_1CC.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${NOKIA_LOGIN}  toor4nsn
${NOKIA_PASS}   oZPS0POrRieRtu
${epc_log_path}    /tmp/
${sa_st_ue_id}      1
${sa_en_ue_id}      2
${nsa_st_ue_id}      110
${nsa_en_ue_id}      120
${scell_idx}    0
${ul_ue_ip}    72.23.0.1
${dl_ue_ip}    1.2.4.2
${dl_ue_ip1}    1.2.4.4
${dl_port}    7073
${dl_port1}    7074
${ul_port}    7074
${duration}    -t 3600
${bytes}    -n 8000000
${ping_unit}    Kbps
${iperf_unit}    Mbps
${exp_dl_avg_ping}    1.4
${exp_ul_avg_ping}    2.8
${exp_dl_avg_iperf}    450
${exp_ul_avg_iperf}    220
${SCFC}=            testsuite/Bangalore/RRM/5GET_BLR/CB009425/config/SCF/FDD_2cell_scf.xml
${AP_XML}=          testsuite/Bangalore/RRM/5GET_BLR/CB009425/config/SCF/FDD_2cell_iphy.xml

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50

#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}               1
@{QOS_Prof1_speed_ul}      1
@{QOS_Prof1_speed_dl}      1
@{QOS_Prof1_unit}          mbps

@{QOS_Prof2}               1       2          3                #4
@{QOS_Prof2_speed_ul}      1      32         amr_wb_18_25     #30
@{QOS_Prof2_speed_dl}      1      32         amr_wb_18_25     #30
@{QOS_Prof2_unit}          mbps   kbps       rtp_codec        #kbps

*** Test Cases ***
[1]5GC009409_L3Call_Validation_With_TCPBoostPUG_With_FIM_CB008124
    set test variable      ${LOG_PATH}

   log to console   UE attach trigerring now...
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof2}       #${2}=${QOS_Prof2}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof2_speed_ul}   # ${2}=${QOS_Prof2_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof2_speed_dl}   # ${2}=${QOS_Prof2_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof2_unit}   # ${2}=${QOS_Prof2_unit}
    sleep    30s
    Start Log    btslog
    ${crnti_list}     ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID
    ...     ${sa_st_ue_id}    ${sa_st_ue_id}    pdu_id=1    nw_id=1
    Log to Console             Bearerlist with${ue_to_bearer_list}
    Log to Console             crnti_list with${crnti_list}
    Create Modify PDU session   ${sa_st_ue_id}    ${sa_st_ue_id}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list}
    ${trf_id}      Set Variable    ${1}

    Start Log   ttitrace

    Start TCP Downlink Iperf Data    ${dl_ue_ip}    ${dl_port}    ${duration}

    MultiUE Register should be Successful with External Trf Type    ${sa_en_ue_id}    ${sa_en_ue_id}    pdu_id=1    nw_id=1

    Start TCP Downlink Iperf Data    ${dl_ue_ip1}    ${dl_port1}    ${duration}
    ${tcpdl_path}   Stop Log    ttitrace    btslog     test_scenario=tcpDlData
    Stop Iperf Traffic

    Decode TTI Trace    tcpDlData

    Verify ResReqClassPrio in ulTdSchedSubcellData for VONR interaction      ${tcpdl_path}[ttitrace]/output_ul_formated.csv
    Verify TCP Boost Grant event in ulPreSchedData for VoNR interaction      ${tcpdl_path}[ttitrace]/output_ul_formated.csv
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting
