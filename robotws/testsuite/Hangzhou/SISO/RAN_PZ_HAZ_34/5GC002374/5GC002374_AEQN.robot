# *** Settings ***
# Suite Setup          2374 Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    Resource/5GC002374_common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
# 
# Documentation
# ...    Author: lanwen.cai
# ...    Contact: lanwen.cai@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature 5GC002374
# 
# Force Tags            RAN_5G_TDD    5G_RAN_TDD    master_classicalbts_all    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED    SBTS00
# ...   PY36
# ...    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQN_5GC002374
# 
# *** Variables ***
# ${Tdanger_trriger}    10.0
# 
# *** Test Cases ***
# 
# [1]5GC002374-A_003_Snapshot_Minor_level_showing_reason_for_a_failure_after_radio_has_been_had_a_power_break_AEQN
#     [Documentation]   Sub-feature:5GC002374
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     Snapshot_Minor_level_showing_reason_for_a_failure_after_radio_has_been_had_a_power_break_AEQN
#     [Teardown]   Run Keywords    Run Keyword If Test Failed    Recovery Alarm 1937    Tdanger_target=${Tdanger_init}
#     ...     AND    SISO Coam Test Teardown
# 
# [1]5GC002374-A_004_Snapshot_Full_level_showing_reason_for_a_failure_after_radio_has_been_re-started_AEQN
#     [Documentation]   Sub-feature:5GC002374
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     Snapshot_Full_level_showing_reason_for_a_failure_after_radio_has_been_re-started_AEQN
#     [Teardown]   Run Keywords    Run Keyword If Test Failed    Recovery Alarm 1937    Tdanger_target=${Tdanger_init}
#     ...     AND    SISO Coam Test Teardown
# 
# [1]FGCR-7971_001_RU Journal Log Collection During Module Startup_AEQN
#     [Documentation]   Sub-feature:FGCR7971
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     FGCR-7971_001_RU Journal Log Collection During Module Startup_AEQN
# 
# *** Keywords ***
# 2374 Coam Suite Setup
#     log to console    \n***2374 Coam Suite Setup***
#     robot_common_operations.CommonSuiteSetup
#     set suite variable    ${suite_setup_fail_flag}    ${True}
#     run keyword if     ${if_commissioning}    CI_interface.Common Suite Setup
#     Connect to gnb coam via ssl
#     ${Active_SW_version}    Get Active SW Version
#     set suite variable      ${Active_SW_version}
#     ${Golden_SCF_Path}    Get Golden SCF Path
#     set suite variable      ${Golden_SCF_Path}
#     ${gNb_CuType}   Get gNB CU type
#     set suite variable      ${gNb_CuType}
#     run keyword if     ${if_update_swconfig}    update swconfig for gNB
#     Generate suite log path
#     set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
#     Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#     ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
#     ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path}
#     log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
#     set suite variable  ${mrbtsID}
#     set suite variable  ${nrbtsID}
#     ${Tdanger_init}    Get Tdanger Value from Json File
#     set suite variable   ${Tdanger_init}
#     log to console   \n init Tdanger value:${Tdanger_init}
#     Run Keyword And Ignore Error    selenium_coam.close_browser
#     set suite variable    ${suite_setup_fail_flag}    ${False}
# 
# Get Init Tdanger Value
#     [Arguments]  ${ru_index}=1
#     ${ALLOWED_FAULT_TEMP}    Copy List    ${ALLOWED_FAULT}
#     ${Fault_6450}    Create Dictionary    faultId=${6450}
#     Append to list     ${ALLOWED_FAULT_TEMP}    ${Fault_6450}
#     Set Test Variable    ${ALLOWED_FAULT}    ${ALLOWED_FAULT_TEMP}
#     ${Tdanger_init}    Get Tdanger Value from Json File    ru_index=${ru_index}
#     [Return]    ${Tdanger_init}
# 
# Trigger Alarm 1937
#     [Arguments]   ${Tdanger_target}    ${ru_index}=1
#     log to console    \n Trigger Alarm 1937
#     Connect to gnb coam via ssl
#     Modify Tdanger Value In Json File    init_value=${Tdanger_init}    target_value=${Tdanger_target}    cmd=touch    ru_index=${ru_index}
#     Perform RU Reset    download_dir=${SAVE LOG DIRECTORY}
#     sleep    60s
#     log to console   \n Check Alarm 1937 Appear On WebEM
#     Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=1937
#     log to console    \n Check Alarm 1937 Exist in RawAlarmHistory
#     Wait until keyword succeeds    5min    30s    Check Alarm Exist in RawAlarmHistory    alarm_filter=1937
# 
# Recovery Alarm 1937
#     [Arguments]   ${Tdanger_target}   ${ru_index}=1
#     log to console    \n Recovery Alarm 1937
#     Modify Tdanger Value In Json File    init_value=${Tdanger_trriger}    target_value=${Tdanger_target}    cmd=rm -rf    ru_index=${ru_index}
#     Perform RU Reset    download_dir=${SAVE LOG DIRECTORY}
#     sleep    60s
#     log to console    \n Check Alarm 1937 Disappear On WebEM
#     Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=1937
#     coam wait gnb and cells ready    timeout=10min    gnb_type='${gNb_CuType}'
# 
# Check fault Exist in RU and snapshot
#     [Arguments]  ${ru_index}=1    ${fault_filter}=1168
#     ${ru_alarms_string}    Wait until keyword succeeds    10min   30s    Check fault Exist in faultlog in RU
#     ...    fault_filter=${fault_filter}   ru_index=${ru_index}
#     ${snapshot_file_path}    COAM Save snapshot via rest api    timeout=1500
#     ${snapshot_alarms_string}    Extract fault logs from snapshot
#     ...    snapshot_file=${snapshot_file_path}    fault_id=${fault_filter}
#     should be equal as strings    ${ru_alarms_string}    ${snapshot_alarms_string}
# 
# Number_of_failure_logs_reported_in_snapshot_for_one_RU_during_1h_AEQN
#     [Arguments]  ${ru_index}=1
#     Modify RU SnapshotTimeoutS
#     Trigger Alarm 1937    Tdanger_target=${Tdanger_trriger}  ru_index=${ru_index}
#     Check fault Exist in RU and snapshot
#     recovery alarm 1937    Tdanger_target=${Tdanger_init}   ru_index=${ru_index}
# 
# Snapshot_Minor_level_showing_reason_for_a_failure_after_radio_has_been_had_a_power_break_AEQN
#     [Arguments]  ${ru_index}=1
#     Modify RU SnapshotTimeoutS
#     Trigger Alarm 1937    Tdanger_target=${Tdanger_trriger}  ru_index=${ru_index}
#     Perform RU Power Off
#     sleep    10s
#     Perform RU Power On
#     sleep    5min
#     Wait until keyword succeeds    10min    30s    RU Status Should Be Failed    ru_index=${ru_index}
#     Check fault Exist in RU and snapshot
#     recovery alarm 1937   Tdanger_target=${Tdanger_init}   ru_index=${ru_index}
# 
# Snapshot_Full_level_showing_reason_for_a_failure_after_radio_has_been_re-started_AEQN
#     [Arguments]  ${ru_index}=1
#     Modify RU SnapshotTimeoutS
#     Trigger Alarm 1937    Tdanger_target=${Tdanger_trriger}  ru_index=${ru_index}
#     Perform RU Reset
#     Check fault Exist in RU and snapshot
#     recovery alarm 1937   Tdanger_target=${Tdanger_init}   ru_index=${ru_index}
# 
# FGCR-7971_001_RU Journal Log Collection During Module Startup_AEQN
#     [Arguments]  ${ru_index}=1    ${connection}=GNB_OAM
#     &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
#     ${serial_number}    Set Variable    ${ru_info['serialNumber']}
#     Set test variable    ${result}    0
#     log to console    ***********************************reboot ru by power off (PB)***********************************
#     Perform RU Power Off
#     Sleep    30s
#     Perform RU Power On
#     Sleep    30s
#     wait until keyword succeeds    15min   30s    COAM Check GNB RU status
#     Wait Until Keyword Succeeds    10 min    20 sec    Verify all cells should be onair
#     ${snapshot_file_path}    COAM Save snapshot via rest api    timeout=1500
#     ${status}    Get RU Reset Cause    snapshot_path=${snapshot_file_path}
#     ...    runtime_name=BTS_${serial_number}_RMOD_L_1_runtime.zip    expected_cause=PowerOn (1)
#     run keyword and ignore error      Should Be Equal    ${status}    1
#     ${result}    evaluate    ${result}+${status}
#     log to console    ***********************************RM command trigger SW_UPDATE***********************************
#     RM Command To Trigger RU Reboot   cmd=SW_UPDATE
#     Sleep    120s
#     wait until keyword succeeds    15min   30s    COAM Check GNB RU status
#     Wait Until Keyword Succeeds    10 min    20 sec    Verify all cells should be onair
#     ${snapshot_file_path}    COAM Save snapshot via rest api    timeout=1500
#     ${status}    Get RU Reset Cause    snapshot_path=${snapshot_file_path}
#     ...    runtime_name=BTS_${serial_number}_RMOD_L_1_runtime.zip    expected_cause=SwDownload (10)
#     run keyword and ignore error      Should Be Equal    ${status}    1
#     ${result}    evaluate    ${result}+${status}
#     log to console    ***********************************RM command trigger reset watchdog***********************************
#     RM Command To Trigger RU Reboot   cmd=WATCHDOG
#     Sleep    120s
#     wait until keyword succeeds    15min   30s    COAM Check GNB RU status
#     Wait Until Keyword Succeeds    10 min    20 sec    Verify all cells should be onair
#     ${snapshot_file_path}    COAM Save snapshot via rest api    timeout=1500
#     ${status}    Get RU Reset Cause    snapshot_path=${snapshot_file_path}
#     ...    runtime_name=BTS_${serial_number}_RMOD_L_1_runtime.zip    expected_cause=WatchDog (2)
#     run keyword and ignore error      Should Be Equal    ${status}    1
#     ${result}    evaluate    ${result}+${status}
#     log to console    ***********************************RM command trigger reset 'MANAGEMENT'***********************************
#     RM Command To Trigger RU Reboot   cmd=MANAGEMENT
#     Sleep    120s
#     wait until keyword succeeds    15min   30s    COAM Check GNB RU status
#     Wait Until Keyword Succeeds    10 min    20 sec    Verify all cells should be onair
#     ${snapshot_file_path}    COAM Save snapshot via rest api    timeout=1500
#     ${status}    Get RU Reset Cause    snapshot_path=${snapshot_file_path}
#     ...    runtime_name=BTS_${serial_number}_RMOD_L_1_runtime.zip    expected_cause=Unit (3)
#     run keyword and ignore error      Should Be Equal    ${status}    1
#     ${result}    evaluate    ${result}+${status}
#     log to console    ***********************************reboot ru by reset ru on WebUI***********************************
#     Perform RU Reset
#     Sleep    30s
#     wait until keyword succeeds    15min   30s    COAM Check GNB RU status
#     Wait Until Keyword Succeeds    10 min    20 sec    Verify all cells should be onair
#     ${snapshot_file_path}    COAM Save snapshot via rest api    timeout=1500
#     ${status}    Get RU Reset Cause    snapshot_path=${snapshot_file_path}
#     ...    runtime_name=BTS_${serial_number}_RMOD_L_1_runtime.zip    expected_cause=BTS (4)
#     run keyword and ignore error      Should Be Equal    ${status}    1
#     ${result}    evaluate    ${result}+${status}
#     log to console    ***********************************reboot ru by reset site on WebUI***********************************
#     Perform BTS Site Reset
#     Sleep    30s
#     wait until keyword succeeds    15min   30s    COAM Check GNB RU status
#     Wait Until Keyword Succeeds    10 min    20 sec    Verify all cells should be onair
#     ${snapshot_file_path}    COAM Save snapshot via rest api    timeout=1500
#     ${status}    Get RU Reset Cause    snapshot_path=${snapshot_file_path}
#     ...    runtime_name=BTS_${serial_number}_RMOD_L_1_runtime.zip    expected_cause=BTS (4)
#     run keyword and ignore error      Should Be Equal    ${status}    1
#     ${result}    evaluate    ${result}+${status}
#     Should Be Equal    ${result}    ${6}
