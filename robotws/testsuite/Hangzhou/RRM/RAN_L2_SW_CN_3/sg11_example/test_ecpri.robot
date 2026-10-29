*** Settings ***
Documentation     Author: wenchao.zhang@nokia-sbell.com
...
...               example case for RAN HZ L2 SW11. test step description in QC as below:
...
...               QC case full name:
...               5GC001116_C
...
...               1)Preconditions
...
...               BTS state is configured and RRU is online
...
...               Releated parameters is set correctly
...
...               Cell is up
...
...               2)Postconditions
...
...               UE can attach successfully to 5G cell
...
...               DL and UL data is normal
...
...               3)Check Points
...
...               Check there is print 'Cell Setup Completed' in airphone /tmp/APL3.log
...
...               Check there is print 'SmUserUeConnectionEstablishedIndMessageHandler' in airphone /tmp/APL3.log
...
...               Check there is print 'reported successful RA' in egate window.
...
...               Check DL and UL data are stable in egate window
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_BL_AP_NSA_FS_CMWV    5G_RAN_TDD    FR1    Owner_wenczhan    5G00    QCD_MN_5G    QCP_5G    CDRT
Library           ute_fsmaccess
Resource          ../resources/KISS/robot/common_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${UE_ID}          1
${PDU_ID}         1
${GW_ID}          1
${SLICE_ID}       1
${SCFC_NAME}      scfc.xml
${AIRPHONE_NAME}    iphy.xml
${GNB_SWCONFIG_NAME}    gnb_swconfig.txt
${AP_SWCONFIG_NAME}    ap_swconfig.txt
${WTS_NAME}       wts.cfg
${opt_type}       Ecpri
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
${MSG1}           itf_l2_ps_peerctrl_scellueschedulingreq
${MSG2}           itf_l2_ps_peerctrl_scellueschedulingresp
${FILTER1}        itf_l2_ps_peerctrl_ScellUeSchedulingReq.modifType.modifType_item_0
${FILTER2}        itf_l2_ps_peerctrl_ScellUeSchedulingResp.modifType.modifType_item_0

*** Test Cases ***
test_case_about_CA_ecpri
    Step1: Set parameter as precondition ,reset gnb and wait gnb onair
    Step2: UE can attach successfully to 5G cell1
    Step3: send_trans_data, and_check_tput
    Step4: stop trans data, and detach UE
    Comment    Step5: check bip message

*** Keywords ***
Step1: Set parameter as precondition ,reset gnb and wait gnb onair
    Start Collect GNB and AP Syslog in 'before_onair' File
    Setup eNB Fsm Access    alias=putswconfig
    Put Enb Swconfig File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/${opt_type}/${GNB_SWCONFIG_NAME}    alias=putswconfig
    Teardown Enb Fsm Access    alias=putswconfig
    airphone_upload_swconfig     ${CONFIG_DIR_PATH}/${SW_BRANCH}/${opt_type}/${AP_SWCONFIG_NAME}
    change_iphy_rru_version      ${CONFIG_DIR_PATH}/${SW_BRANCH}/${opt_type}/${AIRPHONE_NAME}
    Modify TL VM And AP SCTP Configuration
    Perform Full Commission And Reach Onair
	...    ${CONFIG_DIR_PATH}/${SW_BRANCH}/${opt_type}/${SCFC_NAME}
	...    ${CONFIG_DIR_PATH}/${SW_BRANCH}/${opt_type}/${WTS_NAME}
	...    reset_after_commission=${False}
    Download Ttitrace Decode Tool
    Download Luashark Tool
    [Teardown]    Stop Collect GNB and AP Syslog in 'before_onair' File

Step2: UE can attach successfully to 5G cell1
    Start Collect GNB and AP Syslog in 'ue_attach' File
    Start GNB BIP Log
    Start AP BIP Log
    Start GNB Ttitrace With Streaming Mode
    airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
    Airphone SA Attach    ue_id=${UE_ID}
    Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
    airphone_execute_egate_command    command=ue_cqi_param id=1 on=nr nr_cqi_mode=fixed scell=0-1 nr_cqi=15 nr_ri=1
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}ue_attach
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}ue_attach/output
    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}ue_attach${/}
    Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}ue_attach${/}
    [Teardown]    Stop Collect GNB and AP Syslog in 'ue_attach' File

Step3: send_trans_data, and_check_tput
    Start Collect GNB and AP Syslog in 'send_data' File
    Start GNB BIP Log
    Start AP BIP Log
    Start GNB Ttitrace With Streaming Mode
    Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
    Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
    Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
    Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=${PDU_ID}    duration=${3600}
    Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=5    pdu_id=${PDU_ID}    duration=${3600}
    Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=6    pdu_id=${PDU_ID}    duration=${3600}
    Airphone SA Start Data Traffic    ${UE_ID}    UL    50M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
    Wait Throughput Timer    15
    ${dl_tput}=    airphone_sa_get_throughput    ${UE_ID}    DL    ${PDU_ID}
    ${ul_tput}=    airphone_sa_get_throughput    ${UE_ID}    UL    ${PDU_ID}
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}send_data
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}send_data/output
    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}send_data${/}
    Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}send_data${/}
    log    ${dl_tput}
    log    ${ul_tput}
    [Teardown]    Stop Collect GNB and AP Syslog in 'send_data' File

Step4: stop trans data, and detach UE
    Start Collect GNB and AP Syslog in 'detach' File
    airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
    #airphone_sa_stop_data_traffic    ${UE_ID}    UL    pdu_id=${PDU_ID}
    airphone_sa_detach    ${UE_ID}
    [Teardown]    Stop Collect GNB and AP Syslog in 'detach' File

Step5: check bip message
    ${pcap_path}    set variable    ${TEST_LOG_DIRECTORY()}/attach/
    ${ret}=    Get Field Value From BIP Files By Name    ${pcap_path}/5GBipL2L1_filtering_off.pcap*    ${MSG1}    ${FILTER1}
    should be equal    int(${ret}[0])    int(${0})
