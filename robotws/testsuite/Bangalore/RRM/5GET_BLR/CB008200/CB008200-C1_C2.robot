*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...   PY27
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN    SBTS00    SBTS23R1    CONFIGURED
#CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD
Resource         ./CB008200_Resource.robot
Resource          ./resources/common/common_setup_teardown.robot
Resource         ../resources/robot/common_log_collection.robot
Library          ./resources/python/read_csv.py
Suite Setup         Run keywords
...                 Log To console  SuiteSetup
...                 AND     Prepare TL with all config files
...                 AND     Suite setup from scratch
#...                 AND     Update GSCN in AP Iphy Xml     gscn=1582
#...                 AND     Check and active the BTS l2ps DBG log
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
#...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_2CC_TDD_VONR_MultiUE.json
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#...                 AND     Stop Syslog CPRT BIP Logs for ABIO_L1B     #Enable here if issue reports
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
Documentation
...
...             author:            Akhil K P, akhil.k_p@nokia.com
...             maintainer:        Akhil K P, akhil.k_p@nokia.com
...
...             INTRODUCTION:      Feature provides counters for measuring VoNR statistics for clear understanding of the performance of Voice over
...              NR calls in the network.The feature provides counters related to Retainability, Accessibility , Utilzation and VoNR Quality
...             The feature also provides some counters at PMQAP level.
...             TEST SET NAME:    1) CB008200-C_1_Network_Quality_Performance_Measurements_WB_CQI_64TBL_5QI1_CQIXX.
...                                The purpose of this test is to verify the PM Counter update for VoNR Wideband CQI per cell for classical gNB when
...                                64QAM table is configured. CQI histogram counters for 64QAM are updated according to the detailed counter
...                                 descriptions and reported CQI values
...                               2) CB008200-C_2_Network_Quality_Performance_Measurements_WB_CQI_256TBL_5QI1_CQIXX.
...                                The purpose of this test is to verify the PM Counter update for VoNR Wideband CQI per cell for classical gNB when
...                                256QAM table is configured. CQI histogram counters for 64QAM are updated according to the detailed counter
...                                descriptions and reported CQI values


...             TESTING SPLIT:     See CB008200 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008200 CFAM
...             Requirement ID:      5G_PM_385
*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/CB008200_C1-SCF.xml
${AP_XML}=      ${CURDIR}/config/SCF/CB007134_C2-iphy.xml

${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_2CC_tdd_multi_ue_vonr.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${Q_O_ADD}      1
${RTP_COD}      1
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${3}

*** Test Cases ***
[1]CB008200-C_1_Network_Quality_Performance_Measurements_WB_CQI_64TBL_5QI1_CQIXX

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Set fixed cqi for multiple UEs    ${st_ue_id}    ${en_ue_id}    15
    Perform SCF Delta Commissioning with dl256QAM_disabled_1CC.json
    Make MultiUE 5qi1 call with varying cqi and collect ttitrace
    Get 64QAM cqi counters and validate		${0}		${15}		ttitrace_streaming
    Remove varying cqi for multiple UEs    ${st_ue_id}    ${en_ue_id}    1    15
	Set fixed cqi for multiple UEs    ${st_ue_id}    ${en_ue_id}    0
	Perform SCF Delta Commissioning with csirepperiod_1CC.json
	Make MultiUE 5qi1 call with varying cqi and collect ttitrace
    Get 64QAM cqi counters and validate		${1}		${16}		ttitrace_streaming_2
    [Teardown]   configuration_id.Link SCOUT SCF to Configuration ID for Reporting

#[1]CB008200-C_2_Network_Quality_Performance_Measurements_WB_CQI_256TBL_5QI1_CQIXX
#
#    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
#    set test variable      ${LOG_PATH}
#    Set fixed cqi for multiple UEs    ${st_ue_id}    ${en_ue_id}    15
#    Perform SCF Delta Commissioning with dl256qam_1CC.json
#    Make MultiUE 5qi1 call with varying cqi and collect ttitrace
#    Get 256QAM cqi counters and validate		${0}		${15}		ttitrace_streaming
#    Remove varying cqi for multiple UEs    ${st_ue_id}    ${en_ue_id}    1    15
#	Set fixed cqi for multiple UEs    ${st_ue_id}    ${en_ue_id}    0
#    Perform SCF Delta Commissioning with csirepperiod_1CC.json
#    Make MultiUE 5qi1 call with varying cqi and collect ttitrace
#    Get 256QAM cqi counters and validate		${1}		${16}		ttitrace_streaming_2
*** Keywords ***
Make MultiUE 5qi1 call with varying cqi and collect ttitrace
    #Step 1. Attach multiple VONR UEs, with PDU session 5QI-6 nonGBR qosflow which is default
    log to console   UE attach trigerring now...
    Wait until the next Measurement Period starts  additional_time=${0}
    MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}
#Step 2. Establish pdu_id=2 for 5QI-5 SIP Signalling
    MultiUE PDU Addition should be Successful        ${st_ue_id}    ${en_ue_id}    nw_id=1    pdu_id=2
    MultiUE PDU Modfication should be Successful     ${st_ue_id}    ${en_ue_id}    pdu_id=2   qosflows_to_add=2
    MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     dl_rate=32     pdu_id=2    trf_id=1       qfi_id=2
    MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     ul_rate=32     pdu_id=2    trf_id=1       qfi_id=2
    Sleep   2s

#Step 3. Establish pdu_id=2 for 5QI-1 VoNR Call
    Start Ttitrace With Streaming Mode
    MultiUE PDU Modfication should be Successful     ${st_ue_id}    ${en_ue_id}      pdu_id=2      qosflows_to_add=3
    sleep       10s
	Set varying cqi for multiple UEs    ${st_ue_id}    ${en_ue_id}    0    15
	Trigger MultiUE VoNR DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    pdu_id=2     trf_id=2     qfi_id=3    rtp_codec=custom
    Trigger MultiUE VoNR UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    pdu_id=2     trf_id=2     qfi_id=3    rtp_codec=custom
     sleep    30s
     Stop MultiUE Data Traffic for SA     ${st_ue_id}    ${en_ue_id}
    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}
    sleep    10s
    Stop Ttitrace
    Wait until the current Measurement Period stops
