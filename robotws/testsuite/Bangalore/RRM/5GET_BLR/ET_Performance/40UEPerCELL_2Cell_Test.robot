*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Resource        Performance_keywords.resource

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
#...                 AND     Check and active the BTS l2ps DBG log
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
#...                 AND     Check gNB Bulid

Suite Teardown      Run keywords  Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Log to console   "FINISH"
#...                 AND     Run Keyword and Ignore Error    Get Snapshot
#...                 AND     Run Keyword and Ignore Error    Get Sos Report
#...                 AND     Run Keyword and Ignore Error    Stop Default Processes And Gather Logs And Compress Logs

#Test Setup       Start_capture_testcase_default_logging
#Test Teardown        output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts_config_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.lua
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${MAX_UE_Cell1}       40
${MAX_UE_Cell2}       140
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/

*** Test Cases ***
Performance_Test_For_40UE
    [Documentation]   Performance_Test_For_40UE
	${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Register Multiple UE and Send the Data   1    ${MAX_UE_Cell1}    Traffic_rate=mbps   DL_Rate=40   UL_Rate=5   Syslog_name=cell1syslog
    Validate RLC PM Counter    1600   200   Traffic_rate=mbps    moc=NRCELL-1
    Register Multiple UE and Send the Data   101    ${MAX_UE_Cell2}    Traffic_rate=mbps   DL_Rate=40   UL_Rate=5   Syslog_name=cell2syslog
    Validate RLC PM Counter    1600   200   Traffic_rate=mbps    moc=NRCELL-2
    Stop Traffic and Dettach Multiple UE   1    ${MAX_UE_Cell1}
    Stop Traffic and Dettach Multiple UE   101    ${MAX_UE_Cell2}

