*** Settings ***
Test Setup       Start Monitoring
Test Teardown    Stop Monitoring

Library     taf.ul.alarms_watchdog    WITH NAME    watchdog
Resource    taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource    taf/rfrl/bts/robot/common/gnb_cell.robot
Resource    taf/rfrl/bts/robot/common/gnb_log.robot
Resource    ../CommonKeywords/RobotKeywords/bts_status.robot
Resource    ../CommonKeywords/RobotKeywords/sw_operations.robot

*** Variables ***
${build_file_name}      /home/ute/TAF/BTS_SW/SBTS20B_ENB_0000_001700_000000.zip
${timeout_on_air}       15 min
${check_on_air}         True
${check_alarms}         True
${allowed_alarms}       /home/ute/TAF/RobotLogs/allowed_alarms.txt
${check_bts_status}     True
${force_bts_reset}      True
${collect_logs}         on_failure
${collect_syslog}       False
${log_dir}              ${OUTPUT DIR}

*** Keywords ***
Start Monitoring
    [Documentation]    Start BTS syslog and alarm monitoring
    Run Keyword if    ${collect_syslog}    Start Collecting gNB Syslog
    @{alarms}    Get Allowed Alarms    ${allowed_alarms}
    watchdog.watch_alarms    allowed_alarms=@{alarms}
    ...    bts_config=${tl.gnbs[0]}
    ...    log_dir=${log_dir}
    watchdog.get_active_alarms

Stop Monitoring
    [Documentation]    Stop BTS syslog and alarm monitoring and collect logs
    watchdog.get_active_alarms
    watchdog.Stop Watching Alarms
    Run Keyword if    ${collect_syslog}    Stop Collecting gNB Syslog
    Run Keyword If    '${collect_logs}' == 'allways'
    ...    Collect Logs
    Run Keyword If    '${collect_logs}' == 'on_failure' and '${TEST STATUS}' == 'FAIL'
    ...    Collect Logs

Check Alarms
    [Documentation]    Check if any alarms occured during test run
    Log To Console    [robot] Checking alarms
    ${has_alarms}    watchdog.has_detected_alarms
    @{detected_alarms}    Run Keyword If    ${has_alarms}
    ...    watchdog.get_detected_alarms
    Run Keyword If    ${has_alarms}
    ...    Log To Console    [robot] Unallowed alarms detected: ${detected_alarms}

Collect Logs
    [Documentation]    Collect BTS snapshot and infomodel
    Log To Console    [robot] Collecting Snapshot from BTS
    Collect Snapshot From gNB
    Log To Console    [robot] Collecting IM Snapshot from BTS
    Collect IM Snapshot From gNB

Check If Force Reset Is Needed
    [Documentation]    Check if BTS force reset is needed
    Log To Console    [robot] BTS SW is same. No need to update BTS SW
    Run Keyword If    '${force_bts_reset}' == 'True'    Log To Console    Executing BTS force reset
    Run Keyword If    '${force_bts_reset}' == 'True'    Reset gNB
    Run Keyword If    '${force_bts_reset}' == 'True'    Sleep    5 min

Wait Bts And Cells OnAir
    Log To Console    [robot] Waiting all cells OnAir
    Wait Until Keyword Succeeds    ${timeout_on_air}    1 min     Verify Setup Of All Cells

*** Test Cases ***
Sw Update
    [Documentation]    Update BTS SW
    Run Keyword If    ${check_bts_status}    Check Bts Status
    Log To Console    [robot] Download BTS configuration file
    Download gNB Configuration File    local_dir=${log_dir}    config_type=configurationAndRuntimeObjects
    ${is_different}    Run Keyword And Return Status    Compare Current Bts Sw    ${build_file_name}
    ${update_status}    Run Keyword If    ${is_different}
    ...    Update Bts Sw    ${build_file_name}    ${force_bts_reset}
    ...    ELSE
    ...    Check If Force Reset Is Needed
    Run Keyword If    '${update_status}' == 'Fail'    Fail    SW update failed
    Run Keyword if    ${check_on_air}    Wait Bts And Cells OnAir
    Verify Bts Sw Version  ${build_file_name}
    Run Keyword If    ${check_alarms}    Check Alarms
    Run Keyword If    ${check_bts_status}    Check Bts Status
