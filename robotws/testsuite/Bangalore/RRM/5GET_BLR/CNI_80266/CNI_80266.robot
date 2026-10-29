*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT     RAN_5G    5G_RAN    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Documentation    :copyright: Nokia
...              :contact: mary.thomas@nokia.com
...
...  Purpose of this test is to verify DBG logs are not captured by default from L2PS and L2Lo modules.
...  As part of this CNI-80266 , for L2Lo new R&D flag introduced rdL2LoLogLevel (0x570029), which is 1 by default so all  
...  loglevels which is higher than 1 will be captured.

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Resource         ../CB008541/resources/CB008541_Keywords.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
#...                AND     Set swconfig in DU 
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
#Suite Teardown    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
#${wts_cfg_file}     ${CURDIR}/config/basic_setup_scellchange.cfg
${wts_cfg_file}     ${WTS_DIR}/basic_setup.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${epc_log_path}    /tmp/
${rdL2LoLogLevel}    0x570029


*** Test Cases ***
[1]CNI-80266-5G-GNB_DBG_LOGControlValidation_L2PS_L2LO_Classical
    [Documentation]    This testcase verify the component level log control at 5G L2 component level through R&D parameter 
    ...  Purpose of this test is to verify DBG logs are not captured by default from L2PS and L2Lo modules.
    ...  As part of this CNI-80266 , for L2Lo new R&D flag introduced rdL2LoLogLevel (0x570029), which is 1 by default

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=ueattach_data
    log to console   UE attach trigerring now...
    UE Register should be Successful     ue_id=${UE_ID}
    Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID}      qfi_id=${QFI_ID}
    sleep   5s
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=100       trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
    sleep   100s    reason=Wait for traffic to become stable
	wtsrunner.ue_pdu_session_release    ue=1    pdu=1    by=amf
	sleep   5s
    Stop Collecting Syslog       NAME=ueattach_data
    Run Keyword And Continue on Failure    Syslog should contain INFO logs in syslogs    NAME=ueattach_data
	Stop Data Traffic for SA     ue_id=${UE_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}

    

*** Keywords ***

Syslog should contain INFO logs in syslogs
    [Arguments]      ${NAME}
    log to console     Verifying info log  messages in syslog
    ${status} =   run    command=sudo cat ${CURRENT_SYSLOG_PATH}/syslog_${NAME}.log | grep "INF/L2Lo.*"
    Should Not Be Empty    ${status}
    ${status1} =   run    command=sudo cat ${CURRENT_SYSLOG_PATH}/syslog_${NAME}.log | grep "ASP\-.*INF/.*L2-PS.*"
    Should Not Be Empty    ${status1}
    ${status2} =   run    command=sudo cat ${CURRENT_SYSLOG_PATH}/syslog_${NAME}.log | grep "DBG/L2Lo.*"
    Should Be Empty    ${status2}
    ${status3} =   run    command=sudo cat ${CURRENT_SYSLOG_PATH}/syslog_${NAME}.log | grep "ASP\-.*DBG/.*L2-PS.*"
    Should Be Empty    ${status3}

