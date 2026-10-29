*** Settings ***
Force Tags       CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00   CONFIGURED

Documentation
...
...             author:            noble.iyeswariyam_edison@nokia.com
...             maintainer:        noble.iyeswariyam_edison@nokia.com
...
...             INTRODUCTION:      CB008983 RRM support for NR 1Tx DL 2Rx UL operation on Flexi FDD RFM
...             TEST SET NAME:     CB008983_B_2_NSA_WithDSS_15MHz
...                                This user scenario describes concurrent LTE and NR traffic within the LTE-NR DSS cell with reLteNuShift = 4
...             TESTING SPLIT:     See CB008983 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008983 CFAM
...             Requirement ID:    5G_RAN_USR_RRM_16674

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         resources/CB008983_Resource.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
#Resource         resources/CB008983_Resource.robot
Resource         ../CB008541/resources/CB008541_Keywords.robot
Library          ../resources/python/avg_dl_data.py
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py



Suite Setup         Run keywords    Prepare TL with all config files
...                 AND    Run Keyword and Ignore Error    Suite setup from scratch
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid


#Suite Setup         Run keywords    Suite setup from scratch
##...                 AND    Perform SCF Delta Commissioning with Delta_Configuration_scf_MRBTS-1_2_16_UTE5GCLASSICAL4143_20240925-1504.json
#...                 AND    Sleep    100s
#...                 AND    gnb.Perform gNB reboot
#...                 AND    Sleep   500s    reason=wait for RMOD- to comeup
#...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
#...                 AND     Check gNB Bulid

Test Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#...                 AND     Run Keyword and Ignore Error    Get Snapshot
#...                 AND     Run Keyword and Ignore Error    Get Sos Report
...                 AND     Run Keyword and Ignore Error    Stop Default Processes And Gather Logs And Compress Logs
#Suite Teardown     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#Test Setup       Start_capture_testcase_default_logging
...                 AND    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/ET_CB008983-B_DSS_NSA_N1_15MHz_UL_1Layer.lua
${WTS_DIR}          /opt/iphy/latest
${LOCAL_WTS_DIR}           ${CURDIR}/resources/wts
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}             11
${nwslice_ID}        1
${gw_ID}             1
${Pdu_session_ID}    1
${QFI_ID}            1
${TRF_ID}            1
${eNB_ID}            1
${eNB_target}        2
${cell_ID}           1
${st_ue_id}          1
${en_ue_id}          1
${numofLayer}        RANK1
${numprb}            79

${file_path}         ${WTS_DIR}/egate_console.log
#${file_path}        /opt/iphy/latest/egate_output.log
#${mimolayer}         2
${mimolayer}         4
${ss_pbch_power}     10
${overhead}          xOh6
${no_of_ports}       1
${cdm_type}          fd-CDM2
${density}           one
${v-Shift}           n1

${SCF_Path}    SCF_DU_Setup.xml
${SCFC}=    ${CURDIR}/config/SCF/CB008983_B_2_NSA_WithDSS_reLteNuShift_1_15MHz_scf.xml
${AP_XML}=    ${CURDIR}/config/SCF/CB008983_B_2_NSA_WithDSS_reLteNuShift_1_15MHz_iphy.xml

*** Test Cases ***
[1]CB008983_B_2_NSA_WithDSS_reLteNuShift_1_15MHz
    [Tags]    QC_331947      QCD_MN_RAN    QCP_RAN_ET
    set test variable      ${LOG_PATH}
#    wtsrunner.sim_log_set    file=egate_output.log
    Configure DSS and cell seutp
    Sleep    3s
    Attach UE and start data
    Verify egate and TTI trace
    Stop data and Detatch UE

*** Keywords ***
Configure DSS and cell seutp
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=dss_config
    Start CPRT Trace Capturing
    Enable Phase3 DSS   prb_list=${PRB_LIST_15M}    ALLOC_SUBFRAME=${ALLOC_SUBFRAME}   num_prb=${numprb}
	...    min_dss_ratio=75    max_dss_ratio=100    min_prb_ratio=30    max_prb_ratio=70
	Stop Collecting Syslog       NAME=dss_config
	Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_dss_config.pcap

Register UE and start data
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=ue_attach
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    UE Register should be Successful     ue_id=${UE_ID}
    Sleep    5s
    Stop L1L2 capture  ${CaptureL1L2}
#    Move File    ${LOG_PATH}/L1L2_GNB_FS_BO.pcap    ${LOG_PATH}/L1L2_GNB_FS_BO_UE_Attach.pcap
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}     Traffic_rate=mbps     dl_rate=150       trf_id=${TRF_ID}
    Trigger UL Data Traffic for SA   ue_id=${UE_ID}     Traffic_rate=mbps     ul_rate=150       trf_id=${TRF_ID}
    Stop Collecting Syslog       NAME=ue_attach
	Stop CPRT capture   ${CaptureCPRT}
#    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_ue_attach.pcap
    Start L2 BIP Trace Capturing
    Sleep    5s
    Stop L1L2 capture  ${CaptureL1L2}
#    Move File    ${LOG_PATH}/L1L2_GNB_FS_BO.pcap    ${LOG_PATH}/L1L2_GNB_FS_BO_UE_DL_UL_Data.pcap
    Sleep    15s
    Run keyword and ignore error    Validate DL Traffic For SA   ue_id=${UE_ID}      dl_rate=1.20     qfi_id=${QFI_ID}
    Run keyword and ignore error    Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.60     qfi_id=${QFI_ID}
    wtsrunner.uec_stats     type=cell_data_pdcp    enb=${eNB_ID}     cell=${cell_ID}    format=short

Attach UE and start data
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=ue_attach
    Start CPRT Trace Capturing
    LTE Attach should be Successful    NSA_UE_ID=${UE_ID}
    UE Attach should be Successful   NSA_UE_ID=${UE_ID}
    Sleep    5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID}     Traffic_rate=mbps     dl_rate=150       trf_id=${TRF_ID}
    Trigger UL Traffic for NSA    ue_id=${UE_ID}     Traffic_rate=mbps     ul_rate=150       trf_id=${TRF_ID}
    Stop Collecting Syslog       NAME=ue_attach
	Stop CPRT capture   ${CaptureCPRT}
#    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_ue_attach.pcap
    Sleep    20s
    ${output2}    OperatingSystem.Get File    ${file_path}
    Run keyword and ignore error    Validate DL Traffic For NSA   ue_id=${UE_ID}      dl_rate=68
    Run keyword and ignore error    Validate UL Traffic For NSA   ue_id=${UE_ID}     ul_rate=49
    Verify 1TX config from egate_log     1    ${st_ue_id}    ${en_ue_id}    0
    wtsrunner.uec_stats     type=cell_data_pdcp    enb=${eNB_ID}     cell=${cell_ID}    format=short

Stop data and Deregister UE
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=ue_detach
    Start CPRT Trace Capturing
    Stop Data Traffic for SA     ue_id=${UE_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}
    Stop Collecting Syslog       NAME=ue_detach
	Stop CPRT capture   ${CaptureCPRT}
#    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_ue_detach.pcap

Stop data and Detatch UE
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=ue_detach
    Start CPRT Trace Capturing
    Stop Data Traffic for NSA    ue_id=${UE_ID}
    UE Detach should be Successful
    Stop Collecting Syslog       NAME=ue_detach
	Stop CPRT capture   ${CaptureCPRT}
#    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_ue_detach.pcap

Verify egate and TTI trace
    Verify 1TX config from egate_log     1    ${st_ue_id}    ${en_ue_id}    0
    sleep  10s       reason=Wait for traffic to start
    Start L2 BIP Trace Capturing
    sleep  3s       reason=Wait to collect logs
    Stop L1L2 capture  ${CaptureL1L2}
#    Move File    ${LOG_PATH}/L1L2_GNB_FS_BO.pcap    ${LOG_PATH}/L1L2_GNB_FS_BO_ULDL_Data_UE.pcap
    ${crnti_list}     Create List
    ${numofLayer}    Create List     RANK1
    Log To Console    \nStartingTTICapture
    Capture TTI Traces and Validate numofLayers    ${LOG_PATH}    initial    ${crnti_list}     ${numofLayer}
    Log To Console    \nDoneTTICapture


#Change IPHY File Value
#    [Arguments]    ${RU_TYPE}   ${GSCN}
#    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
#    ${c1}    Set Variable    cat ${file_path}|grep -m 4 "card"|tail -n 4|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|
#    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${RU_TYPE}/g' ${file_path}
#    Run    ${c1}${c2}

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}
