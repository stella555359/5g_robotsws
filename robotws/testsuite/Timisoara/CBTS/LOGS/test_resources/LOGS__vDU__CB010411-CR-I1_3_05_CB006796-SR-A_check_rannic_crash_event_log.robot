*** Settings ***
Documentation
...    Tests for CB009077
Library    BuiltIn
Library    DateTime
Library    Collections
Library    taf.ul.verify_snapshot    WITH NAME    snapshot
Resource    ../../common_resources/vdu_frame.robot
Resource    ../../common_resources/vdu_general.robot
Resource    ../../common_resources/vcu_frame.robot
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_logging.robot
Resource    ../resources/LOGS_general.robot
Library  taf.gnb.oam.coam.vdu  WITH NAME  vdu

Resource    ../resources/unpacking.robot
Resource    ../resources/verdicts.robot

Resource    ../../LOGS/test_resources/LOGS__vDU__CB006483-5G-D_Max_number_of_snapshots_by_fault_triggers_per_day_NetAct.robot
Resource    ../../LOGS/resources/CB006483_keywords.robot
Resource    ../../LOGS/resources/cloud_vdu.robot

*** Variables ***
${VDU_SCFC_PATH}  ${CURDIR}/SCF/vCu/vDu.xml
${VCU_SCFC_PATH}  ${CURDIR}/SCF/vCu/vCu.xml
@{LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}=    Create List
${REVERT_DELTA_CHANGES}    ${False}
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir
${ALARM_TIMEOUT}  300  # Alarm timeout [in seconds]
${CASE_OPERATION_START_TIME}    unknown

*** Keywords ***
TC__LOGS__vDU__CB010411-CR-I1_3_05_CB006796-SR-A_check_rannic_crash_event_log
    [Documentation]
    ...  CB010411-CR-I1_3_05_CB006796-SR-A_check_rannic_crash_event_log test


    Step 0: Precondition
    Step 1: Trigger RANNIC Reset On CBTS
    Step 2: Check Rannic Reset in Auditlog
    Step 3: Check rannic reset operation history from webem    operation_start_time=${CASE_OPERATION_START_TIME}
    Step 5: Call For T&T vdu33

Step 0: Precondition
   [Documentation]
    ...   In this step Precond
     Log    \nStep 0: Precondition    console=${True}
     Log    \nConnecting to vDU and set all necessary variables   console=${True}

    Log to console    Step0: Get the CST time From vDU platform
    ${Original_time}=    CB006483_keywords.Get vDU Time Cst
    ${CASE_OPERATION_START_TIME}=    Replace String    ${Original_time}    \r\n    ${EMPTY}
    Set Global Variable    ${CASE_OPERATION_START_TIME}
    Log to console    CASE_OPERATION_START_TIME is:${CASE_OPERATION_START_TIME}

Step 1: Trigger RANNIC Reset On CBTS
    Log to console    CASE_OPERATION_START_TIME is:${CASE_OPERATION_START_TIME}
    Log to console    Step1: Trigger Rannic Reset and Verify Cell status
    Log to console    Verify Cell status
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells From VDU  availability_status=${ONLINE}  operational_state=${ENABLED}
    Log to console    All Cells are up
    Trigger Rannic Reset without Verify Cell status
    sleep    40s
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells From VDU  availability_status=${ONLINE}  operational_state=${ENABLED}
    Log to console    All Cells are up after rannic reset

    [Teardown]  SSHLibrary.Close All Connections

Step 2: Check Rannic Reset in Auditlog
    Check Rannic Reset in Auditlog

Check Rannic Reset in Auditlog
    [Arguments]  ${alias}=vDU
    vDU Connect To K8s Master Interactively    alias=${alias}
    ${log_path}  ${kubectl_cmd}    Generate Auditlog Get    namespase=${VDU_CRAN}    #alias=${alias}
    wait until keyword succeeds    8min    30sec    Check Rannic Reset
    ...    kubectl_cmd=${kubectl_cmd}    alias=${alias}    log_file=${log_path}/auditlog
    [Teardown]  vDU Disconnect Interactive Connection    alias=${alias}

Check Rannic Reset
    [Arguments]  ${kubectl_cmd}    ${log_file}    ${alias}=vDU
    Log To Console   \nCheck auditlog
    ${rnic_num}    ${rnic_mod_list}        Get Rannic Number And ModList    mrbts_id=${VDU_MRBTS_ID}
    FOR   ${rnic_rmod}    IN   @{rnic_mod_list}
        ${content}    issh.Execute    command=${kubectl_cmd} -- cat ${log_file} | grep ${rnic_rmod}    alias=${alias}
	    sleep    1
        ${check_log}    Get Regexp Matches    ${content}
        ...    "operationResult":"success"
        should not be empty    ${check_log}
    END

TC Setup
    Common VDU Setup

TC Teardown
    Logs To Rotta Copy
