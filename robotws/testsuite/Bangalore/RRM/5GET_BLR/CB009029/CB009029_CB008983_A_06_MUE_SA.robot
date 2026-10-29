*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_FDD
...               RAN_5G_FDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation    :copyright: Nokia
...   The aim of the feature is to support  1Tx DL and 2Rx UL per cell operation for NR FDD

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../CB008983/resources/CB008983_Resource.robot
Resource        ../resources/robot/common_log_collection.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          OperatingSystem

Suite Setup         Run keywords     Prepare TL with all config files
...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
#Suite Teardown    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/basic_setup_MUE.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}               1
${nwslice_ID}          1
${gw_ID}               1
${Pdu_session_ID}      1
${qfi_id}              1
${st_ue_id}            1
${en_ue_id}            8
${value}               0
${file_path}     /opt/iphy/latest/egate_console.log
${mimolayer}      2
${ss_pbch_power}    10
${overhead}    xOh6
${no_of_ports}    1
${cdm_type}    fd-CDM2
${density}    one
${SCFC}=                   Bangalore/RRM/ET/CB008983/CB008983_A_06_MUE_SA_scf.xml
${AP_XML}=                 Bangalore/RRM/ET/CB008983/CB008983_A_06_MUE_SA_iphy.xml



*** Test Cases ***
[1]CB008983_A_5_robustness_SA_4UE_Attach_Data_Transmission
     [Documentation]      support for 1Tx DL and 2Rx UL per cell operation for NR FDD
    set test variable      ${LOG_PATH}
    Attach Multi Ue and Start Data
    Verify egate and TTI trace
    Validate THP and Dettach UE


*** Keywords ***
Verify egate and TTI trace
    Verify 1TX config from egate_log     0    ${st_ue_id}    ${en_ue_id}    1
    set test variable      ${crnti_list}
    sleep  10s       reason=Wait for traffic to start
    ${numofLayer}    Create List     RANK1    RANK1    RANK1    RANK1    RANK1    RANK1    RANK1    RANK1
    Log To Console    \nStartingTTICapture
    Capture TTI Traces and Validate numofLayers    ${LOG_PATH}    initial    ${crnti_list}     ${numofLayer}
    Log To Console    \nDoneTTICapture
    Start log    biptaf
    sleep  250ms
    Stop Log    biptaf    test_scenario=DL_UL_datatransfer

Attach Multi Ue and Start Data
    log to console   UE attach trigerring now...
    Start log    btslog    ttitrace    cprt    biptaf
    ${crnti_list}=     MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}
    Stop Log   btslog    ttitrace    cprt    biptaf    test_scenario=MUE_attach
    set test variable      ${crnti_list}
    MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     dl_rate=8
    ...    pdu_id=${Pdu_session_ID}    trf_id=1       qfi_id=${qfi_id}
    MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     ul_rate=15
    ...    pdu_id=${Pdu_session_ID}    trf_id=1       qfi_id=${qfi_id}


Validate THP and Dettach UE
    sleep  60s       reason=Wait for traffic to start

    Run Keyword And Continue on Failure   Validate CellTHP For SA MultiUE    60    dl    ${st_ue_id}    ${en_ue_id}
    Run Keyword And Continue on Failure   Validate CellTHP For SA MultiUE    110    ul    ${st_ue_id}    ${en_ue_id}
    wtsrunner.ue_stats_nr     id=1-4     scell=0     type=pusch

    wtsrunner.ue_stats_nr     id=1-4     scell=0     type=pdsch
    sleep  3s
    Stop MultiUE Data Traffic for SA     ${st_ue_id}    ${en_ue_id}
    Run Keyword And Continue on Failure     MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

Validate CellTHP For SA MultiUE
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    ...                3. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${dl_rate}    ${dir}    ${st_ue_id}    ${en_ue_id}
    FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        wtsrunner.bearer_stats  ue=${ue_id}   pdu=1   qfi=1   dir=${dir}
        ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=10
        ${output}         Get Regexp Matches    ${bearer_stat_dl}    Average data rate +(\\d+)    1
        ${value} =    Evaluate      ${value}+int(${output[0]})
        log to console    Average data rate for UE : ${ue_id} is int(${output[0]})
    END
    ${result}         Evaluate    (${dl_rate} * 1000000 * 1.1) > int(${value}) > (${dl_rate} * 1000000 * 0.9)
    Run Keyword if    ${result}    Log to Console    ${dir} Average data rate: ${value}
    ...               ELSE    BuiltIn.Log     ${dir} Average data rate: ${value}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=${dir} Average data rate failed!
