*** Settings ***
Documentation
...    Author: yin.4.chen@nokia-sbell.com
...    Feature CNI-113670 Automation

Resource   ./Resource/Common.robot

Suite Setup   Common Suite Setup
Suite Teardown   Common Suite Teardown

*** Test Cases ***
CNI_113670_Classical_AEHC_operating_in_emergency_mode_due_to_None_Critical_DFE_Failure
    [Setup]   CNI-113670 Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=16
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    AlarmWatchdog.add_allow_alarms    fault_id=4590
    AlarmWatchdog.add_allow_alarms    fault_id=2935
    AlarmWatchdog.add_allow_alarms    fault_id=2934
    AlarmWatchdog.add_allow_alarms    fault_id=1911
    AlarmWatchdog.add_allow_alarms    fault_id=1907
    AlarmWatchdog.add_allow_alarms    fault_id=1900
    Log To Console   ${EMPTY}
    Log To Console   ${RANDOM_NONE_CRITICAL_DFE}
    ${NONE_CRITICAL_DFE_NUMBER}   Get Length   ${RANDOM_NONE_CRITICAL_DFE}
    ${fault_severity}   Set Variable If
    ...   "${NONE_CRITICAL_DFE_NUMBER}"=="1"   Minor
    ...   Major

    ${is_cell_degraded}   Set Variable If
    ...   "${NONE_CRITICAL_DFE_NUMBER}"=="1"   ${False}
    ...   ${True}

    Empty Serial Port Output File
    Enable LMI From Serial Port
    Reset RU From LMI

    FOR   ${index}   IN RANGE   ${4}
        Log To Console   Reset Count: ${index}
        Empty Serial Port Output File
        Run Keyword And Continue On Failure   Wait Login Content
        Enable LMI From Serial Port
        ${status}   Run Keyword And Return Status   Trigger DFE Failure From LMI   severity=none_critical
        Run Keyword And Continue On Failure   Run Keyword If   ${status}   Check DFE Failure Reset Counter   reset_counter=${index}
        Run Keyword And Continue On Failure   Check Ongoing RMOD Status
        Run Keyword And Continue On Failure   Check Ongoing Active Fault
        Sleep   16m
    END

    @{check_fault_list}   Create List   ${2935}
    ${active_fault_list}   Wait Until Keyword Succeeds   25m   1m   Check DFE Failure Fault   check_fault_list=${check_fault_list}
    List Should Not Contain Value   ${active_fault_list}   ${10}
    List Should Not Contain Value   ${active_fault_list}   ${1850}
    List Should Not Contain Value   ${active_fault_list}   ${2934}

    Check DFE Failure Fault Severity   check_fault_id=${2935}   check_fault_severity=${fault_severity}

    Wait Until Keyword Succeeds   3m   1m   COAM ADMIN Check RMOD Degraded
    Run Keyword If   ${is_cell_degraded}   Wait Until Keyword Succeeds   3m   1m   COAM ADMIN Check Cell Degraded

    [Teardown]   CNI-113670 Case Teardown


CNI_113670_Classical_AEHC_operating_in_emergency_mode_due_to_Critical_DFE_Failure
    [Setup]   CNI-113670 Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=16
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    AlarmWatchdog.add_allow_alarms    fault_id=4590
    AlarmWatchdog.add_allow_alarms    fault_id=2935
    AlarmWatchdog.add_allow_alarms    fault_id=2934
    AlarmWatchdog.add_allow_alarms    fault_id=1911
    AlarmWatchdog.add_allow_alarms    fault_id=1907
    AlarmWatchdog.add_allow_alarms    fault_id=1900
    Log To Console   ${EMPTY}
    Log To Console   ${RANDOM_CRITICAL_DFE}

    Empty Serial Port Output File
    Enable LMI From Serial Port
    Reset RU From LMI

    FOR   ${index}   IN RANGE   ${7}
        Log To Console   Reset Count: ${index}
        Empty Serial Port Output File
        Run Keyword And Ignore Error   Wait Login Content
        Enable LMI From Serial Port
        ${status}   Run Keyword And Return Status   Trigger DFE Failure From LMI   severity=critical
        Run Keyword And Ignore Error   Run Keyword If   ${status}   Check DFE Failure Reset Counter   reset_counter=${index}
        Run Keyword And Ignore Error   Check Ongoing RMOD Status
        Run Keyword And Ignore Error   Check Ongoing Active Fault
        Sleep   16m
    END

    @{check_fault_list}   Create List   ${2934}   ${2935}
    ${active_fault_list}   Wait Until Keyword Succeeds   25m   1m   Check DFE Failure Fault   check_fault_list=${check_fault_list}
    List Should Not Contain Value   ${active_fault_list}   ${10}
    List Should Not Contain Value   ${active_fault_list}   ${1850}

    Run Keyword And Continue On Failure   Check DFE Failure Fault Severity   check_fault_id=${2934}   check_fault_severity=Critical
    Run Keyword And Continue On Failure   Check DFE Failure Fault Severity   check_fault_id=${2935}   check_fault_severity=Critical

    Wait Until Keyword Succeeds   3m   1m   COAM ADMIN Check RMOD Failed
    Wait Until Keyword Succeeds   3m   1m   COAM ADMIN Check Cell Failed

    [Teardown]   CNI-113670 Case Teardown


*** Keywords ***
CNI-113670 Case Setup
    robot_common_operations.Common Case Setup
    # Run Keyword And Ignore Error   Start Syslog Process


CNI-113670 Case Teardown
    CNI-113670 Catch All Logs
    Run Keyword And Ignore Error   Empty Serial Port Output File
    Run Keyword And Ignore Error   Enable LMI From Serial Port
    Run Keyword And Ignore Error   Recovery Action Combine
    robot_common_operations.Common Case Teardown
    CI_interface.Common Case Teardown

CNI-113670 Catch All Logs
    ${log_status}   Get Variable Value   ${TEST_STATUS}   ${KEYWORD_STATUS}
    # Return From Keyword If   "${log_status}"=="PASS"

    Run Keyword And Continue On Failure   CNI-113670 Catch Snapshot
    # Run Keyword And Ignore Error   Stop Syslog Process
    # Run Keyword And Ignore Error   Save Syslog Process


CNI-113670 Catch Snapshot
    [Arguments]   ${log_dir}=${OUTPUT_DIR}   ${timeout}=5400

    Wait Until Keyword Succeeds   10m   1m   COAM Login

    ${time}   DateTime.Get Current Date   UTC   + 8 hours   result_format=%Y-%m-%d-%H_%M_%S
    Log To Console  Start To Collect Snapshot!
    ${snapshot_name}   Set Variable   Snapshot_${time}.zip

    Run Keyword And Ignore Error   coam.Collect snapshot
    ...      target_file_name=${log_dir}/${snapshot_name}   coverage=Full   force=True   timeout=${timeout}   connection=COAM
    Log To Console   Collect Snapshot Finished!

    [Return]   ${log_dir}/${snapshot_name}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout


Recovery Action Combine
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    ${release}   COAM Get SW Release
    Log To Console   Release: ${release}

    Run Keyword If   "${release}"<="SBTS25R1"   Recovery Action Reset Site
    ...   ELSE   Recovery Action Delete Node Failures File

    [Teardown]   Run Keyword And Ignore Error   COAM Logout


Recovery Action Reset Site
    Log To Console   Recovery Action Reset Site
    # Wait Until Keyword Succeeds   10m   1m   COAM Login

    FOR   ${index}   IN RANGE   ${2}
        Log To Console   Reset Site: ${index}
        COAM Reset Site
        Wait Until Keyword Succeeds   10m   1m   COAM Check All Cells Onair
    END

    Log To Console   Recovery Action Reset Site Finished!

    # [Teardown]   Run Keyword And Ignore Error   COAM Logout


Recovery Action Delete Node Failures File
    Log To Console   Recovery Action Delete Node Failures File

    Enable LMI From Serial Port

    ${testpc_connection}   Set Variable   test_pc
    ${testpc_ipaddr}       Get Variable Value   ${RANDOM_AEHC["test_pc_addr"]}
    ${testpc_username}     Get Variable Value   ${RANDOM_AEHC["test_pc_username"]}
    ${testpc_password}     Get Variable Value   ${RANDOM_AEHC["test_pc_password"]}
    csn.Connect To   hostname=${testpc_ipaddr}   username=${testpc_username}   password=${testpc_password}   alias=${testpc_connection}

    ${ru_lmi_connection}   Set Variable   ru_lmi
    ${ru_lmi_ipaddr}       Get Variable Value   ${RANDOM_AEHC["ru_addr"]}
    ${ru_lmi_username}     Get Variable Value   ${RANDOM_AEHC["ru_username"]}
    ${ru_lmi_password}     Get Variable Value   ${RANDOM_AEHC["ru_password"]}
    csn.Connect To   hostname=${ru_lmi_ipaddr}   username=${ru_lmi_username}   password=${ru_lmi_password}
    ...   alias=${ru_lmi_connection}   proxy=${testpc_connection}

    csn.Execute   command=cat /mnt/runtime/preventerResetCounter.txt   connection=${ru_lmi_connection}
    csn.Execute   command=cat /mnt/runtime/node_failures.txt   connection=${ru_lmi_connection}
    csn.Execute   command=cat /tmp/disabled_nodes.txt   connection=${ru_lmi_connection}

    csn.Execute   command=sudo rm -rf /mnt/runtime/preventerResetCounter.txt   connection=${ru_lmi_connection}
    csn.Execute   command=sudo rm -rf /mnt/runtime/node_failures.txt   connection=${ru_lmi_connection}

    Run Keyword And Ignore Error   csn.Disconnect   connection=${ru_lmi_connection}
    Run Keyword And Ignore Error   csn.Disconnect   connection=${testpc_connection}


    FOR   ${index}   IN RANGE   ${2}
        Log To Console   Reset Site: ${index}
        COAM Reset Site
        Wait Until Keyword Succeeds   10m   1m   COAM Check All Cells Onair
    END

    Log To Console   Recovery Action Delete Node Failures File Finished!
