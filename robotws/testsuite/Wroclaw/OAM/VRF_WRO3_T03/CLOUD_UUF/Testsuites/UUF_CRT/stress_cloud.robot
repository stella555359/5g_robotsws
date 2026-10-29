*** Settings ***
Documentation
...    Author: anna.niedzwiecka@nokia.com
...    Description: Suite prepared for UUF stress CLOUD tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -V /home/ute/testline_configuration/10_16_UTESRANCLOUD2135/__init__.py -v SW_VCU:vCUCNF00_0.250.26816 -L DEBUG
...    -b debug.log -d /home/ute/logs/ testsuite/Wroclaw/OAM/VRF_WRO3_T01/CLOUD_UUF/Testsuites/UUF_CRT/uuf_crt.robot

Resource        ../../Testcases/UUF_CLOUD.15_ST_vDU_RMOD_reset/test.robot
Resource        ../../Testcases/UUF_CLOUD.16_ST_vDU_cell_block_unblock/test.robot
Resource        ../../Testcases/UUF_CLOUD.26_ST_Reset_vCU/test.robot
Resource        ../../Testcases/UUF_CLOUD.27_ST_Reset_vDU/test.robot
Resource        ../../Testcases/UUF_CLOUD.25_ST_vCU_cell_lock_unlock/test.robot
Resource        ../../Testcases/UUF_CLOUD.28_ST_vCU_cell_reset/test.robot
Resource        ../../Testcases/UUF_CLOUD.29_ST_RINLINE_reset/test.robot
Resource        ../../Testcases/UUF_CLOUD.30_ST_vDU_cell_reset/test.robot
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource        taf/rfrl/common_resources/common_step/interface.robot

#Suite Teardown  Suite Teardown


*** Variables ***
${ccr_location_cli}     wl    # Choose between wl or wg
${RESULTS}    /home/ute/results/test

#MANTARAY
${NMS_LAB}                        #example: 1057
${VDU_DP_SW}                      #example: vCUCNF00_0.250.32346
${VCU_DP_SW}                      #example: vCUCNF26R1_27.250.155
${VDU_SW_VERSION}                 #example: vDUCNF00_0.300.28473
${VCU_SW_VERSION}                 #example: vCUCNF00_0.250.32363
${CNF_LCM_OPERATOR_SW_RELEASE}    #example: cnf-lcm-operator_4.1.0-amd64
${NOKIA_SYNC_VERSION}             #example: nokia-sync-operator_5.1.2
${RANNIC_SW_VERSION}              #example: ran-nic-sw-controller_3.10.3
${CCR_NAME}                       ccr                #Change if CCR on your lab has other name than project1
${NMS_LAB_IP}                     ${SRNCLAB${NMS_LAB}}    #Do not change. Declare used lab in ${NMS_LAB} variable.
${deploy_deletion}                ${True}
${lcm_deployment}                 ${True}

@{FULL_SCOPE_FOR_stress}
...    UUF_CLOUD.15_ST_vDU_RMOD_reset
...    UUF_CLOUD.16_ST_vDU_cell_block_unblock
...    UUF_CLOUD.27_ST_Reset_vDU
...    UUF_CLOUD.29_ST_RINLINE_reset
...    UUF_CLOUD.30_ST_vDU_cell_reset

@{FULL_SCOPE_FOR_stress-vCU}
...    UUF_CLOUD.23_ST_Reset_vCU
...    UUF_CLOUD.25_ST_vCU_cell_lock_unlock
...    UUF_CLOUD.28_ST_vCU_cell_reset

${ITERATIONS}                100
@{TEST_SUITE_CONTENT}
${MAX_FAIL_IN_ROW}           3


*** Test Cases ***
[1.0] Full Iteration of Stress Tests-vDU
    [Tags]    full_stress   vdu
    Run Multiple Tests In One Iteration    @{FULL_SCOPE_FOR_stress}
    [Teardown]    Run Keyword And Ignore Error    Remove Storage Dir

[1.0] Full Iteration of Stress Tests-vCU
   [Tags]    full_stress   vcu
   Run Multiple Tests In One Iteration    @{FULL_SCOPE_FOR_stress-vCU}
   [Teardown]    Run Keyword And Ignore Error    Remove Storage Dir

*** Keywords ***
Run Multiple Tests In One Iteration
    [Documentation]    Runs a list of test cases for a defined number of iterations, logging results per loop.
    [Arguments]    @{test_names}
    ${ITERATIONS}    Convert To Integer    ${ITERATIONS}
    FOR    ${iteration}    IN RANGE    1    ${ITERATIONS}+1
        Log To Console    Running iteration ${iteration}/${ITERATIONS}
        Set Test Variable  ${ITERATION_INDEX}  ${iteration}
        FOR    ${test_name}    IN    @{test_names}
            Run Single Test In Loop    ${test_name}    ${iteration}
        END
    END

Run Single Test In Loop
    [Documentation]    Runs a single test case in a loop with timing, logging, and failure handling.
    [Arguments]    ${test_name}    ${iteration}
    ${iteration_start_time}    time_verdict.Get Current Time
    ${is_nms}=    Get Substring    ${TEST_NAME}    -2
    Set Suite Variable  ${is_nms}
    IF  '${is_nms}'=='NM'
        Common Test Setup MantaRay Cloud  ${deploy_deletion}
    ELSE
        Run Keywords  Common Test Setup Cloud  AND  CCR injection CLI  ${ccr_location_cli}
    END
    ${passed}    Run Keyword And Return Status    ${test_name}
    ${iteration_end_time}     time_verdict.Get Current Time
    ${time_diff}  Subtract Date From Date  ${iteration_end_time}  ${iteration_start_time}
    ${raw_data}  Create List  ${iteration}  ${test_name}  ${iteration_start_time}  ${iteration_end_time}  ${time_diff}  ${passed}
    Log  Iteration ${iteration} - ${test_name} result: ${passed}
    ${watchdog_alarms}  Stop Cloud Watchdog And Get Faults   hw_type=${hw}
    ${non_upgraded_cnf_alarms}  Stop Cloud Watchdog And Get Faults   hw_type=${non_upgraded_cnf}
    ${wdog_status}    Set Variable If    '${watchdog_alarms}'!='[]' or '${non_upgraded_cnf_alarms}'!='[]'    ${False}    ${True}
    Run Keyword If  '${watchdog_alarms}'!='[]' or '${non_upgraded_cnf_alarms}'!='[]'
    ...  Fail  Unexpected faults were detected during test execution!
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error  Disconnect from ADMIN  ${admin_connection}  hw_type=${hw}    AND
    ...    Run Keyword And Ignore Error  Disconnect from ADMIN via SSH    ${ssh_conn}  hw_type=${hw}    AND
    ...    Run Keyword And Ignore Error    Stop Cloud Watchdog And Get Faults   hw_type=${hw}    AND
    ...    Run Keyword And Ignore Error    Stop Cloud Watchdog And Get Faults   hw_type=${non_upgraded_cnf}    AND
    ...    Run Keyword If  ${passed} and ${wdog_status}    Run Keyword And Ignore Error
    ...    Collect Logs From Passed Execution If Needed    ${test_name}    AND
    ...    Run Keyword If  not ${passed} or not ${wdog_status}
    ...    Run Keyword And Ignore Error  Collect Logs  ${hw}  ${non_upgraded_cnf}  ${test_name}  ${False}    AND
    ...    Run Keyword If  not ${passed}    Fatal Error

Recovery Snapshot For Looping
    [Documentation]    Collects logs and takes a snapshot when a test fails during iteration.
    [Arguments]    ${iteration}
    ${timestamp}    DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    Log To Console    Iteration ${iteration} failed. Collecting logs.
    ${target_file_name}    Set Variable    ${RESULTS}/snapshot/${iteration}/${timestamp}_snapshot_mrbts-${MRBTS}.zip
    Run Keyword And Ignore Error  logs.Collect Snapshot  local_dir=${RESULTS}/${hw}  hw_type=${hw}

#Create Log Directory For Looping
#    [Documentation]    Creates a directory to store logs for a specific test iteration.
#    [Arguments]    ${iteration}
#    ${iteration}    Convert To String    ${iteration}
#    ${RESULTS_i}    Join Path    ${RESULTS}    ${iteration}
#    Create Directory    ${RESULTS_i}
#    [Return]    ${RESULTS_i}

Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...                             team_name=PZ3WRO1
    ...                             input_logs_dir=${None}
    ...                             remote_host_vDU=${LMP_VDU_IP}
    ...                             remote_host_vCU=${LMP_VCU_IP}
    ...                             mandatory_log_types=__snapshot_vDU__,__snapshot_vCU__
