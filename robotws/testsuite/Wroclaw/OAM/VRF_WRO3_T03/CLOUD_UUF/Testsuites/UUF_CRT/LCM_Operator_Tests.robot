*** Settings ***
Documentation
...    Author: marek.starzyk@nokia.com
...    Description: Test suite for CNF operations performed via the LCM operator.
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -V /home/ute/testline_configuration/10_16_UTESRANCLOUD2135/__init__.py -L TRACE
...    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/VRF_WRO3_T01/CLOUD_UUF/Testsuites/LCM_Operator_Tests.robot

Resource        ../../Testcases/UUF_CLOUD.23_CB013390-Robust_LCM_Blue_Green_Upgrade_with_Graceful_Scale_in/test.robot
Resource        ../../Testcases/UUF_CLOUD.24_CB013390-LCM_Blue_Green_Upgrade_with_Graceful_Scale_in_User_Defined_Non_Zero_Timeout/test.robot
Resource        ../../../resources/LCM_operator/LCM_operator.robot
Resource        ../../../../cloud_common_resources/connections/connections.robot
Resource        ../../../../cloud_common_resources/logs/logs.robot

Test Setup       LCM Test Setup
Test Teardown    LCM Test Teardown

*** Variables ***
${RESULTS}               /home/ute/results/test
${ccr}                   wl        # Choose between wl or wg
${sw_version}            latest    # To install a specific version, provide it in the format: 'cnf-lcm-operator_3.4.0-amd64.zip'
${hw}                    vCU       # Choose between vDU or vCU
${ssh_conn}              ${None}
${VCU_DP_SW}             #example: vCUCNF00_0.250.32927
${VDU_DP_SW}             #example: vDUCNF00_0.300.32497
${VCU_SW_VERSION}        #example: vCUCNF00_0.250.32960
${VDU_SW_VERSION}        #example: vDUCNF00_0.300.32554
${LCM_DEPLOYMENT}        ${True}
${VCU_DEPLOYMENT}        ${True}
${UPUE_SHUTDOWN_TIME}    ${300}
${install_default_NOP}   ${False}

@{FULL_SCOPE_FOR_VCU}
...    Perform vCU upgrade via LCM Operator
...    Perform vCU rollback via LCM Operator
@{FULL_SCOPE_FOR_VDU}
...    Perform vDU upgrade via LCM Operator
...    Perform vDU rollback via LCM Operator

${ITERATIONS}                10
@{TEST_SUITE_CONTENT}
${MAX_FAIL_IN_ROW}           3

*** Test Cases ***
Install LCM Operator
    Install or Upgrade LCM Operator
    ...    ${ssh_conn}
    ...    ${ccr}
    ...    ${sw_version}

Uninstall LCM Operator From Serwer
    Uninstall LCM Operator
    ...    ${ssh_conn}

Deployment vCU via LCM Operator
    CNF Deploy via LCM Operator
    ...    ${VCU_DP_SW}
    ...    ${ccr}
    ...    ${ssh_conn}
    ...    vCU
    [Teardown]    Run Keyword    Run Keyword And Ignore Error    Remove Storage Dir

Deployment vDU via LCM Operator
    CNF Deploy via LCM Operator
    ...    ${VDU_DP_SW}
    ...    ${ccr}
    ...    ${ssh_conn}
    ...    vDU
    [Teardown]    Run Keyword    Run Keyword And Ignore Error    Remove Storage Dir

[1.0] Full Iteration of Tests-vCU
    [Tags]    full    vcu
    Run Multiple Tests In One Iteration    @{FULL_SCOPE_FOR_VCU}
    [Teardown]    Run Keywords
    ...  common.Common Test Teardown Cloud    AND
    ...  Run Keyword And Ignore Error    Remove Storage Dir    AND
    ...  Run Keyword And Ignore Error  logs.Collect Snapshot  local_dir=${RESULTS}  hw_type=${hw}

[1.0] Full Iteration of Tests-vDU
    [Tags]    full    vdu
    Run Multiple Tests In One Iteration    @{FULL_SCOPE_FOR_VDU}
    [Teardown]    Run Keywords
    ...  common.Common Test Teardown Cloud    AND
    ...  Run Keyword And Ignore Error    Remove Storage Dir    AND
    ...  Run Keyword And Ignore Error  logs.Collect Snapshot  local_dir=${RESULTS}  hw_type=${hw}

Upgrade vCU via LCM Operator
    Perform vCU upgrade via LCM Operator
    [Teardown]  Run Keywords
    ...  common.Common Test Teardown Cloud    AND
    ...  Run Keyword And Ignore Error    Remove Storage Dir  AND
    ...  Run Keyword And Ignore Error  logs.Collect Snapshot  local_dir=${RESULTS}  hw_type=${hw}

Rollback vCU via LCM Operator
    Perform vCU rollback via LCM Operator
    [Teardown]  Run Keywords
    ...  common.Common Test Teardown Cloud  AND   Run Keyword And Ignore Error  logs.Collect Snapshot  local_dir=${RESULTS}  hw_type=${hw}

Upgrade vDU via LCM Operator
    Perform vDU upgrade via LCM Operator
    [Teardown]  Run Keywords
    ...  common.Common Test Teardown Cloud    AND
    ...  Run Keyword And Ignore Error    Remove Storage Dir  AND
    ...  Run Keyword And Ignore Error  logs.Collect Snapshot  local_dir=${RESULTS}  hw_type=${hw}

Rollback vDU via LCM Operator
    Perform vDU rollback via LCM Operator
    [Teardown]  Run Keywords
    ...  common.Common Test Teardown Cloud  AND   Run Keyword And Ignore Error  logs.Collect Snapshot  local_dir=${RESULTS}  hw_type=${hw}

Terminate vCU via LCM Operator
    CNF Termination via LCM Operator
    ...    ${ssh_conn}
    ...    vCU
    [Teardown]    Run Keyword    Run Keyword And Ignore Error    Remove Storage Dir

Terminate vDU via LCM Operator
    CNF Termination via LCM Operator
    ...    ${ssh_conn}
    ...    vDU
    [Teardown]    Run Keyword    Run Keyword And Ignore Error    Remove Storage Dir

Robust LCM Blue Green Upgrade With Graceful Scale-in-vCU
    [Tags]     robust
    [Setup]    Blue Green Upgrade Suite Setup
    UUF_CLOUD.23_CB013390-Robust_LCM-Blue_Green_Upgrade_with_Graceful_Scale-in
    [Teardown]  Run Keywords
    ...  common.Common Test Teardown Cloud    AND
    ...  Run Keyword If Test Failed      Run Keyword And Ignore Error
    ...  Collect Logs  ${hw}  ${non_upgraded_cnf}  vCU_upgrade_via_LCM  ${False}  namespace=${BLUE_NAMESPACE}   AND
    ...  Run Keyword If Test Failed      Run Keyword And Ignore Error
    ...  Collect Logs  ${hw}  ${non_upgraded_cnf}  vCU_upgrade_via_LCM  ${False}  namespace=${GREEN_NAMESPACE}  AND
    ...  Run Keyword If Test Failed      Set Passed Logs Collected    AND
    ...  Run Keyword And Ignore Error    Remove Storage Dir

Blue_Green_Upgrade_with_Graceful_Scale_in_User_Defined_Non_Zero_Timeout
    [Tags]     none_zero_timeout
    [Setup]    Blue Green Upgrade Suite Setup
    UUF_CLOUD.24_CB013390-LCM–Blue_Green_Upgrade_with_Graceful_Scale_in_User_Defined_Non_Zero_Timeout
    [Teardown]  Run Keywords
    ...  common.Common Test Teardown Cloud    AND
    ...  Run Keyword If Test Failed      Run Keyword And Ignore Error
    ...  Collect Logs  ${hw}  ${non_upgraded_cnf}  vCU_upgrade_via_LCM  ${False}  namespace=${BLUE_NAMESPACE}   AND
    ...  Run Keyword If Test Failed      Run Keyword And Ignore Error
    ...  Collect Logs  ${hw}  ${non_upgraded_cnf}  vCU_upgrade_via_LCM  ${False}  namespace=${GREEN_NAMESPACE}  AND
    ...  Run Keyword If Test Failed      Set Passed Logs Collected    AND
    ...  Run Keyword And Ignore Error    Remove Storage Dir

*** Keywords ***
LCM Test Setup
    ${ssh_conn}=    Connect To Admin via SSH    hw_type=${hw}
    Set Test Variable    ${ssh_conn}
    ${hostname}=  Run  hostname
    ${hostname}=  Evaluate  '${hostname}'.replace('-', '_')
    Set Suite Variable  ${hostname}

LCM Test Teardown
    Run Keyword And Ignore Error    Disconnect from ADMIN via SSH    ${ssh_conn}    hw_type=${hw}

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
    Run Keyword    LCM Test Setup
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
    ...    Run Keyword And Ignore Error    Remove Storage Dir  AND
    ...    Run Keyword And Ignore Error  Disconnect from ADMIN  ${admin_connection}  hw_type=${hw}    AND
    ...    Run Keyword And Ignore Error  Disconnect from ADMIN via SSH    ${ssh_conn}  hw_type=${hw}    AND
    ...    Run Keyword And Ignore Error    Stop Cloud Watchdog And Get Faults   hw_type=${hw}    AND
    ...    Run Keyword And Ignore Error    Stop Cloud Watchdog And Get Faults   hw_type=${non_upgraded_cnf}    AND
    ...    Run Keyword If  ${passed} and ${wdog_status}    Run Keyword And Ignore Error
    ...    Collect Logs From Passed Execution If Needed    ${test_name}    AND
    ...    Run Keyword If  not ${passed} or not ${wdog_status}
    ...    Run Keyword And Ignore Error  Collect Logs  ${hw}  ${non_upgraded_cnf}  ${test_name}  ${False}    AND
    ...    Run Keyword If  not ${passed}    Fatal Error

Perform vCU upgrade via LCM Operator
    Run Keyword If    ${install_default_NOP}==${True}
    ...    Upgrade Incompatible NOP    ${VCU_SW_VERSION}    koredump-operator    ${ccr}
    Upgrade CNF via LCM Operator
    ...    ${VCU_SW_VERSION}
    ...    ${ccr}
    ...    ${ssh_conn}
    ...    vCU

Perform vCU rollback via LCM Operator
    Upgrade CNF via LCM Operator
    ...    ${VCU_DP_SW}
    ...    ${ccr}
    ...    ${ssh_conn}
    ...    vCU

Perform vDU upgrade via LCM Operator
    ${admin_connection}=  Connect to ADMIN  password=nemuuser  hw_type=${hw}
    Run Keyword If    ${install_default_NOP}==${True}    Run keywords
    ...    Upgrade Incompatible NOP    ${VDU_SW_VERSION}    ran-nic-sw-controller    ${ccr}
    ...    AND    Upgrade Incompatible NOP    ${VDU_SW_VERSION}    nokia-sync-operator    ${ccr}
    ...    AND    Upgrade Incompatible NOP    ${VDU_SW_VERSION}    koredump-operator    ${ccr}
    ...    AND    sleep  1m  reason=Waiting 1 minute for all alarms to clear.
    ...    AND    Log to console    Waiting for all alarms to clear
    ...    AND    Wait Until Keyword Succeeds  5min  30s  Check If All Cells On Air  hw_type=${hw}  connection=${admin_connection}
    ...    AND    Check Alarm List On vCU/vDU  ${hw}
    Upgrade CNF via LCM Operator
    ...    ${VDU_SW_VERSION}
    ...    ${ccr}
    ...    ${ssh_conn}
    ...    vDU

Perform vDU rollback via LCM Operator
    Upgrade CNF via LCM Operator
    ...    ${VDU_DP_SW}
    ...    ${ccr}
    ...    ${ssh_conn}
    ...    vDU
