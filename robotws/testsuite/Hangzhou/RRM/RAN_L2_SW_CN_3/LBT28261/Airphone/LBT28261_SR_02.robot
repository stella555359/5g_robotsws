*** Settings ***
Documentation     CB0013709 case
Test Timeout      180 minutes
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_BOO_AP_LOOO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G

Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}          SCFC_LBT28261_SR_02.xml
${AIRPHONE_NAME}      IPHY_LBT28261_SR_02.xml
${WTS_NAME}           WTS_6CC_LBT28261.lua


${UE_ID}          1
${PDU_ID1}         1
${GW_ID1}          1
${SLICE_ID}       1
${UE_NUM_SA}               4
${UE_FDD_ID}          201
${UE_NUM_FDD}                4
${LOW_UE_ID}                1


@{LOG_NAME_LIST}    gnb_snapshot    egatelog



*** Test Cases ***
LBT28261-SR-02-FDD_DL_and_UL_basic_functionality_verify
   Step1:Commission configuration for onair
   Step2:Attach 4 TDD UEs and start traffic to check ttitrace
   Step3:Attach 4 FDD UEs and start traffic to check ttitrace


*** Keywords ***
Step1:Commission configuration for onair
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Prepare gnb onair    multi_cells=True

Step2:Attach 4 TDD UEs and start traffic to check ttitrace
    Log To Console   \n----------Step2:Attach 4 TDD UEs and start traffic to check ttitrace-------
    Start capture gnb and ap syslog in 'step2_TDD_4ue' file
    Attach '${UE_NUM_SA}' SA UE'${UE_ID}'
    Send data to SA UE
    Wait '60s' for stabible
    Check SA UE throughput
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti'
    Check Ttitrace
    Detach '${UE_NUM_SA}' SA UE'${LOW_UE_ID}'
    [Teardown]  Stop capture gnb and ap syslog in 'step2_TDD_4ue' file

Step3:Attach 4 FDD UEs and start traffic to check ttitrace
    Log To Console   \n----------Step3:Attach 4 FDD UEs and start traffic to check ttitrace-------
    Start capture gnb and ap syslog in 'step3_fdd_4ue' file
    Attach '${UE_NUM_SA}' SA UE'${UE_FDD_ID}'
    Send data to SA UE    low_ue_id=${UE_FDD_ID}
    Wait '60s' for stabible
    Check FDD SA UE throughput
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti_fdd'
    Check Ttitrace Fdd
    [Teardown]  Stop capture gnb and ap syslog in 'step3_fdd_4ue' file


Check SA UE throughput
    Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput    tp=250000

Verify multi SA UEs throughput
    [Arguments]  ${ue_num}=${UE_NUM_SA}  ${low_ue_id}=${LOW_UE_ID}  ${tp}=100
    FOR    ${num}    IN RANGE    ${low_ue_id}    ${low_ue_id}+${ue_num}
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        should_be_true    ${dl_throughput_pcell}>${tp}
    END

Check FDD SA UE throughput
     Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput    ${UE_NUM_FDD}    ${UE_FDD_ID}    10000

Attach '${UE_NUM_SA}' SA UE'${LOW_UE_ID}'
     FOR    ${num}    IN RANGE    ${LOW_UE_ID}    ${LOW_UE_ID}+${UE_NUM_SA}
       ${gw_pdu_r}    evaluate    ${num}%10+1
       airphone_cleanup_egate_console_log
       Airphone SA Attach    ue_id=${num}
       Wait '2s' for stabible
       Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${gw_pdu_r}    type=internal
       Wait '2s' for stabible
       Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${gw_pdu_r}   nwslice_id=1   gw_id=${gw_pdu_r}
       Wait '2s' for stabible
       airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}   unzip=TRUE
       ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}/egate_console.log.001   crnti: (\\d+)
       run keyword if    ${num}==1 or ${num}==201   Set test Variable    ${ue1_rnti}    ${rnti_list[0]}
       run keyword if    ${num}==2 or ${num}==202  Set test Variable    ${ue2_rnti}    ${rnti_list[0]}
       run keyword if    ${num}==3 or ${num}==203  Set test Variable    ${ue3_rnti}    ${rnti_list[0]}
       run keyword if    ${num}==4 or ${num}==204  Set test Variable    ${ue4_rnti}    ${rnti_list[0]}
     END

Detach '${UE_NUM_SA}' SA UE'${LOW_UE_ID}'
    FOR    ${num}    IN RANGE    ${LOW_UE_ID}    ${LOW_UE_ID}+${UE_NUM_SA}
        Airphone SA Detach    ue_id=${num}
     END

Send data to SA UE
    [Arguments]  ${ue_num}=${UE_NUM_SA}    ${dl_tput}=150M   ${ul_tput}=150M    ${low_ue_id}=${UE_ID}
     FOR    ${num}    IN RANGE    ${low_ue_id}    ${low_ue_id}+${ue_num}
        ${gw_pdu_r}    evaluate    ${num}%10+1
        SA send mutiple trf dl data    ${num}    2   ${dl_tput}    ${gw_pdu_r}
        SA send mutiple trf ul data    ${num}    1   ${ul_tput}   ${gw_pdu_r}
     END



Execute AP Command before attach
    airphone_cleanup_egate_console_log
#    Airphone Setup X2 Connection


check TP and bler with ttitrace
    [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}
    ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
    ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
    Log To Console   ini_file=${ini_file}
    @{keys}  Get Dictionary Keys   ${a}
    FOR      ${key}     IN     @{keys}
        ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
        log to console   result is ${result}
        log to console   TP is ${throughput}
        should be true  ${result}>${throughput}
    END


Check ttitrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/4UE_RW_DL.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/4UE_RW_UL.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/


Check Ttitrace Fdd
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/4UE_RW_DL_FDD.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/4UE_RW_UL_FDD.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/



