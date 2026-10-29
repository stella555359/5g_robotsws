*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO     SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             5G_RAN     SBTS00    CONFIGURED   CRT

Documentation    :copyright: Nokia
...              :author: Kshitij Tyagi
...              :contact: kshitij.tyagi@nokia.com
...         This user scenario verifies the successful UE configuration of the Inter-band FDD - TDD FR1 UL CA
...         feature for single UE with 2 aggregated carriers
...         CB008152_B_IWK.8_TC10_UL CA F+T with 35MHz FDD cell



Resource         resources_keywords.resource

Suite Setup         Run keywords     Prepare TL with all config files
...                 AND    Suite setup from scratch
...                 AND    Start WTS Using WTS_Runner   ${wts_cfg_file}

Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/basic_setup_9169.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${UE_ID}       1
${TRF_ID}    1
${QFI_ID}    1
${scell_pattern}     .*CellIndex 1 act.*
${SCFC}=                   Bangalore/RRM/ET/CB008152/CB008152_B_TC10_UL_CA_scf.xml
${AP_XML}=                 Bangalore/RRM/ET/CB008152/CB008152_B_TC10_UL_CA_iphy.xml

*** Test Cases ***
[1]CB008152_B_IWK.8_TC10_UL CA F+T with 35MHz FDD cell
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start log   syslog   cprt
    log to console   Suite setup successful ...
    Register UL CA Ues and send less data with blind scell add   9   9   ul_rate=5
    Stop Log    cprt    test_scenario=attach_logs
    Send High UL Data Check UL THP in 2CC   9   9
    Start log   ttitrace
    Sleep   5s
    Stop Log   ttitrace     test_scenario=data_logs
    UE Deregister should be Successful   9
    Stop Log   syslog     test_scenario=syslog



*** Keywords ***

Register UL CA Ues and send less data with blind scell add
    [Arguments]   ${Start_UE}   ${End_UE}   ${Traffic_rate}=mbps     ${ul_rate}=1
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${End_UE}+${1}
        UE Register should be Successful    ${UE}
        Verify Scell added successfully     ${UE}
    END
    MultiUE Trigger UL Traffic for SA       ${Start_UE}   ${End_UE}    Traffic_rate=${Traffic_rate}    ul_rate=${ul_rate}
    sleep  10s  reason=stable data
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${End_UE}+${1}
        Run keyword and continue on failure   Verify UL THP for single cell config   ${UE}    0    4.9
    END

Send High UL Data Check UL THP in 2CC
    [Arguments]   ${Start_UE}   ${End_UE}   ${Traffic_rate}=mbps
    MultiUE Trigger UL Traffic for SA    ${Start_UE}    ${End_UE}    Traffic_rate=mbps     ul_rate=150
        ...    pdu_id=${Pdu_session_ID}    trf_id=1       qfi_id=${QFI_ID}
    MultiUE Trigger UL Traffic for SA    ${Start_UE}    ${End_UE}    Traffic_rate=mbps     ul_rate=150
        ...    pdu_id=${Pdu_session_ID}    trf_id=2       qfi_id=${QFI_ID}
    sleep  10s  reason=stable data
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${End_UE}+${1}
        Run keyword and continue on failure    Verify UL THP for 2 cell config    ${UE}   190   90
    END
    log to console  ${Traffic_rate}
Verify Scell added successfully
    [Arguments]     ${ue_id}
    log to console  ${ue_id}
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=${scell_pattern}  timeout=15
    Get Lines Matching Regexp   ${output}    CellIndex \\d+ activated successfully  partial_match=${TRUE}
