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
#Test Teardown    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts_config_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.lua
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${UE}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/

*** Test Cases ***
Performance_Test_For_Single_UE
    [Documentation]   Performance_Test_For_Single_UE
	${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Register Single UE and Send High Data   1   175   100   9    2   1575  200
    Validate RLC PM Counter    1575   200   Traffic_rate=mbps    moc=NRCELL-1
    Register Single UE and Send High Data   101   178   100   9    2   1575   200
    Validate RLC PM Counter    1575   200   Traffic_rate=mbps    moc=NRCELL-2
    Stop Traffic and Dettach Single UE    1
    Stop Traffic and Dettach Single UE    101


