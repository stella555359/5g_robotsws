*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for STRESS TESTING tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRANxxxx -C on -T -d /home/ute/test_results -L TRACE -b debug.log -v SETUP_ONAP:False/True
...    -V /home/ute/testline_configuration/10_16_UTESRANxxxx testsuite/Wroclaw/OAM/VRF_WRO3_T02/STRESS_TESTING/Testsuites/memory_SMOD_BBMOD.robot


Resource        ../Testcases/MEM.01_Neighbouring_Objects_Delta_Commissioning_via_Admin/test.robot
Resource        ../Testcases/MEM.02_Neighbouring_NR_Objects_Delta_Commissioning_via_Admin/test.robot
Resource        ../Testcases/MEM.03_Memory_consumption_veryfication_on_FHS/test.robot
Resource        ../Testcases/SM.01_Site_Reset/test.robot
Resource        ../Testcases/SM.02_Site_Block_Unblock/test.robot
Resource        ../Testcases/SM.04_Cell_Block_Unblock/test.robot
Resource        ../Testcases/SM.05_RMOD_Lock_Unlock/test.robot
Resource        ../Testcases/SM.08_BBMOD_Warm_Reset/test.robot
Resource        ../Testcases/SM.09_RAT_Reset/test.robot
Resource        ../Testcases/SM.10_Power_Reset/test.robot
Resource        ../Testcases/SM.11_RMOD_Reset/test.robot
Resource        ../Testcases/SM.12_CellGroup_Lock_Unlock/test.robot
Resource        ../Testcases/SM.13_BBMOD_Lock_Unlock/test.robot
Resource        ../Testcases/SM.14_GNSSE_Reset/test.robot
Resource        ../Testcases/SM.15_BBPOOL_Warm_Reset_NA/test.robot
Resource        ../Testcases/SM.32_RAT_Block_Unblock/test.robot
Resource        ../Testcases/SM.49_Cell_add_remove/test.robot
Resource        ../Testcases/SM.51_Snapshot_Collection/test.robot
Resource        ../Testcases/SM.100_SW_download_without_activation/test.robot
Resource        ../Testcases/LOGS.01_Check_BTS_file_system_for_presence_of_log_files/test.robot
Resource        ../Testcases/PS.101_Preconfigure_PSGRP_NRGRP_For_MEM/test.robot   #PS4ALL
Library         ../../resources_mem/python_lib/memory_analysis.py


Force Tags
...           SBTS00  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY310  ## force python3 UTE package
...           RF50

Suite Setup       Run Keywords  common.Common Suite Setup  AND  Suite Setup For Memory Testing
Suite Teardown    Run Keywords  common.Common Suite Teardown  AND  Suite Teardown For Memory Testing
#Test Setup        common.Common Test Setup - MEMORY
#Test Teardown     common.Common Test Teardown - MEMORY
Test Timeout      73h


*** Variables ***
${ITERATIONS}                        100
${MIX_START_ITERATIONS}              100
${MIX_END_ITERATIONS}                1000
${SW_DOWNLOAD_ITERATIONS}            3
${SNAPSHOT_ITERATIONS}               10    #how many test loops
${SNAPSHOT_COLLECTION_ITERATIONS}    10    #how many collections inside a test loop
${TEST_SUITE_DURATION}               72    #test suite duration in hours
${MAX_FAIL_IN_ROW}                   5     #maximum number of failed tests in a row
${SMODS_EXCLUDED_REGEX}              FSMF(\\+FSMF)?|ASO[EFGH]
@{TEST_SUITE_CONTENT}
${CONCURRENT}                        False
${INTEGRATE_NETACT}                  True


*** Test Cases ***
### MEMORY START ###
[1][1.0] Automated__MEM__Memory_Mixed_Scenarios_-_START
    [Tags]
    [Setup]    Run Keywords    common.Common Test Setup - MEMORY    AND    Set Test Variable    ${ITERATIONS}    ${MIX_START_ITERATIONS}
    Run Looping Test Memory Mixed Scenarios
    [Teardown]    common.Common Test Teardown - MEMORY

[1][1.1] [SFE]_LTE4471_Capacity_Module_Warm_reset - stress test
    [Setup]    common.Common Test Setup - MEMORY
    ${SMOD_excluded}  Run Keyword And Return Status  Should Match Regexp  ${SMOD_COMPOSITION}  ${SMODS_EXCLUDED_REGEX}
    ${STARTPOINT_SM_08}  Run Keyword If  not ${SMOD_excluded}  Get Adjusted Timestamp  2h
    Run Keyword If  not ${SMOD_excluded}  Set Suite Variable  ${STARTPOINT_SM_08}
    Run Keyword If  not ${SMOD_excluded}
    ...        Run Looping Test SM.08_BBMOD_Warm_Reset
    ...  ELSE  Log To Console  Execution skipped - ${SMOD_COMPOSITION}
    [Teardown]    Run Keyword If  not ${SMOD_excluded}  SM.08_BBMOD_Warm_Reset.Test Case Teardown

[1][2.0] Automated__MEM__Memory_consumption_verification_during_BBU_Reset
    [Setup]    common.Common Test Setup - MEMORY
    ${ENDPOINT_SM_08}  Get Adjusted Timestamp  2h
    ${port_open}    Run Keyword And Return Status    Check Admin Readiness
    Run Keyword If    ${port_open}    Run Keyword    Setup Admin
    Collect Snapshot  target_file_name=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip  timeout=1500
    ${verdict}    Memory Leak Analyzer    snapshot_path=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip
    ...                                   regex_type=SMOD_BBMOD
    ...                                   file_type=runtime
    ...                                   sysinfo_storage_path=${RESULTS}/snapshot/sysinfo_zip_files
    ...                                   sysinfo_reports_path=${RESULTS}/snapshot/SysInfoParser_reports
    ...                                   memory_leak_threshold=2.0  #[%]
    ...                                   startpoint=${STARTPOINT_SM_08}
    ...                                   endpoint=${ENDPOINT_SM_08}
    Run Keyword If  '${verdict}'=='fail'  Fail  Test failed due to memory leak.
    [Teardown]    common.Common Test Teardown - MEMORY

[1][2.0] SFE - Cell Block-Unblock - stress test
    [Setup]    common.Common Test Setup - MEMORY
    ${STARTPOINT_SM_04}    Get Adjusted Timestamp    2h
    Set Suite Variable    ${STARTPOINT_SM_04}
    Run Looping Test SM.04_Cell_Block_Unblock
    [Teardown]  SM.04_Cell_Block_Unblock.Test Case Teardown

[1][1.0] Automated__MEM__Memory_consumption_verification_during_Cell_Block_Unblock
    [Setup]    common.Common Test Setup - MEMORY
    ${ENDPOINT_SM_04}      Get Adjusted Timestamp    2h
    ${port_open}    Run Keyword And Return Status    Check Admin Readiness
    Run Keyword If    ${port_open}    Run Keyword    Setup Admin
    Collect Snapshot  target_file_name=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip  timeout=1500
    ${verdict}    Memory Leak Analyzer    snapshot_path=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip
    ...                                   regex_type=SMOD_BBMOD
    ...                                   file_type=runtime
    ...                                   sysinfo_storage_path=${RESULTS}/snapshot/sysinfo_zip_files
    ...                                   sysinfo_reports_path=${RESULTS}/snapshot/SysInfoParser_reports
    ...                                   memory_leak_threshold=2.0  #[%]
    ...                                   startpoint=${STARTPOINT_SM_04}
    ...                                   endpoint=${ENDPOINT_SM_04}
    Run Keyword If  '${verdict}'=='fail'  Fail  Test failed due to memory leak.
    [Teardown]    common.Common Test Teardown - MEMORY

[1][1.0] RM_Lock_Unlock_-_stress_test
    [Setup]    common.Common Test Setup - MEMORY
    Run keyword except for FSMF     common.Ensure NORMAL value on all RMODs
    ${STARTPOINT_SM_05}    Get Adjusted Timestamp    2h
    Set Suite Variable    ${STARTPOINT_SM_05}
    Run Looping Test SM.05_RMOD_Lock_Unlock
    [Teardown]    Run Keywords      SM.05_RMOD_Lock_Unlock.Test Case Teardown
    ...      AND      Run keyword except for FSMF     common.Restore parameters value on all RMODs

[1][2.0] Automated__MEM__Memory_consumption_verification_during_RMOD_lock_unlock
    [Setup]    common.Common Test Setup - MEMORY
    ${ENDPOINT_SM_05}      Get Adjusted Timestamp    2h
    ${port_open}    Run Keyword And Return Status    Check Admin Readiness
    Run Keyword If    ${port_open}    Run Keyword    Setup Admin
    Collect Snapshot  target_file_name=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip  timeout=1500
    ${verdict}    Memory Leak Analyzer    snapshot_path=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip
    ...                                   regex_type=SMOD_BBMOD
    ...                                   file_type=runtime
    ...                                   sysinfo_storage_path=${RESULTS}/snapshot/sysinfo_zip_files
    ...                                   sysinfo_reports_path=${RESULTS}/snapshot/SysInfoParser_reports
    ...                                   memory_leak_threshold=2.0  #[%]
    ...                                   startpoint=${STARTPOINT_SM_05}
    ...                                   endpoint=${ENDPOINT_SM_05}
    Run Keyword If  '${verdict}'=='fail'  Fail  Test failed due to memory leak.
    [Teardown]    common.Common Test Teardown - MEMORY

[1][2.0] Automated__SM__BBMOD_Lock-Unlock
    [Setup]    common.Common Test Setup - MEMORY
    ${SMOD_excluded}  Run Keyword And Return Status  Should Match Regexp  ${SMOD_COMPOSITION}  ${SMODS_EXCLUDED_REGEX}
    ${STARTPOINT_SM_13}  Run Keyword If  not ${SMOD_excluded}  Get Adjusted Timestamp  2h
    Run Keyword If  not ${SMOD_excluded}  Set Suite Variable  ${STARTPOINT_SM_13}
    Run Keyword If  not ${SMOD_excluded}
    ...        Run Looping Test SM.13_BBMOD_Lock_Unlock
    ...  ELSE  Log To Console  Execution skipped - ${SMOD_COMPOSITION}
    [Teardown]    Run Keyword If  not ${SMOD_excluded}  SM.13_BBMOD_Lock_Unlock.Test Case Teardown

[1][2.0] Automated__MEM__Memory_consumption_verification_during_BBMOD_lock_unlock
    [Setup]    common.Common Test Setup - MEMORY
    ${ENDPOINT_SM_13}  Get Adjusted Timestamp  2h
    ${port_open}    Run Keyword And Return Status    Check Admin Readiness
    Run Keyword If    ${port_open}    Run Keyword    Setup Admin
    Collect Snapshot  target_file_name=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip  timeout=1500
    ${verdict}    Memory Leak Analyzer    snapshot_path=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip
    ...                                   regex_type=SMOD_BBMOD
    ...                                   file_type=runtime
    ...                                   sysinfo_storage_path=${RESULTS}/snapshot/sysinfo_zip_files
    ...                                   sysinfo_reports_path=${RESULTS}/snapshot/SysInfoParser_reports
    ...                                   memory_leak_threshold=2.0  #[%]
    ...                                   startpoint=${STARTPOINT_SM_13}
    ...                                   endpoint=${ENDPOINT_SM_13}
    Run Keyword If  '${verdict}'=='fail'  Fail  Test failed due to memory leak.
    [Teardown]    common.Common Test Teardown - MEMORY

[1][2.0] Automated__SM__Cell_group_Lock-Unlock
    [Setup]    common.Common Test Setup - MEMORY
    ${STARTPOINT_SM_12}  Run Keyword If  'nr' in $rats  Get Adjusted Timestamp    2h
    Run Keyword If  'nr' in $rats  Set Suite Variable  ${STARTPOINT_SM_12}
    Run Keyword If  'nr' in $rats  Run Looping Test SM.12_CellGroup_Lock_Unlock
    [Teardown]  Run Keyword If  'nr' in $rats  SM.12_CellGroup_Lock_Unlock.Test Case Teardown

[1][2.0] Automated__MEM__Memory_consumption_verification_during_cell_group_lock_unlock
    [Setup]    common.Common Test Setup - MEMORY
    ${ENDPOINT_SM_12}    Get Adjusted Timestamp    2h
    ${port_open}    Run Keyword And Return Status    Check Admin Readiness
    Run Keyword If    ${port_open}    Run Keyword    Setup Admin
    Collect Snapshot  target_file_name=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip  timeout=1500
    ${verdict}    Memory Leak Analyzer    snapshot_path=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip
    ...                                   regex_type=SMOD_BBMOD
    ...                                   file_type=runtime
    ...                                   sysinfo_storage_path=${RESULTS}/snapshot/sysinfo_zip_files
    ...                                   sysinfo_reports_path=${RESULTS}/snapshot/SysInfoParser_reports
    ...                                   memory_leak_threshold=2.0  #[%]
    ...                                   startpoint=${STARTPOINT_SM_12}
    ...                                   endpoint=${ENDPOINT_SM_12}
    Run Keyword If  '${verdict}'=='fail'  Fail  Test failed due to memory leak.
    [Teardown]    common.Common Test Teardown - MEMORY

[1][1.0] Automated__SM__Big_Delta_commissioning
    [Setup]    common.Common Test Setup - MEMORY
    ${STARTPOINT_MEM_01_02}    Get Adjusted Timestamp    2h
    Set Suite Variable    ${STARTPOINT_MEM_01_02}
    Run Keyword If  'nr' in $rats
    ...        Run Looping Test MEM.02_Neighbouring_NR_Objects_Delta_Commissioning_via_Admin
    ...  ELSE  Run Looping Test MEM.01_Neighbouring_Objects_Delta_Commissioning_via_Admin
    [Teardown]  Run Keyword If  'nr' in $rats
    ...        MEM.02_Neighbouring_NR_Objects_Delta_Commissioning_via_Admin.Test Case Teardown
    ...  ELSE  MEM.01_Neighbouring_Objects_Delta_Commissioning_via_Admin.Test Case Teardown

[1][2.0] Automated__MEM__Memory_consumption_verification_during_Big_Delta_commissioning
    [Setup]    common.Common Test Setup - MEMORY
    ${ENDPOINT_MEM_01_02}      Get Adjusted Timestamp    2h
    ${port_open}    Run Keyword And Return Status    Check Admin Readiness
    Run Keyword If    ${port_open}    Run Keyword    Setup Admin
    Collect Snapshot  target_file_name=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip  timeout=1500
    ${verdict}    Memory Leak Analyzer    snapshot_path=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip
    ...                                   regex_type=SMOD_BBMOD
    ...                                   file_type=runtime
    ...                                   sysinfo_storage_path=${RESULTS}/snapshot/sysinfo_zip_files
    ...                                   sysinfo_reports_path=${RESULTS}/snapshot/SysInfoParser_reports
    ...                                   memory_leak_threshold=2.0  #[%]
    ...                                   startpoint=${STARTPOINT_MEM_01_02}
    ...                                   endpoint=${ENDPOINT_MEM_01_02}
    Run Keyword If  '${verdict}'=='fail'  Fail  Test failed due to memory leak.
    [Teardown]    common.Common Test Teardown - MEMORY

[1][1.0] Automated__SM__SW_download_without_activation
    [Setup]    Run Keywords    common.Common Test Setup - MEMORY    AND    SM.100_SW_download_without_activation.Test Case Setup
    ...                 AND    Set Test Variable    ${ITERATIONS}    ${1}
    ${STARTPOINT_SM_100}    Get Adjusted Timestamp    2h
    Set Suite Variable    ${STARTPOINT_SM_100}
    Run Looping Test SM.100_SW_download_without_activation
    [Teardown]    SM.100_SW_download_without_activation.Test Case Teardown

[1][2.0] Automated__MEM__Memory_consumption_check_after_SW_download
    [Setup]    common.Common Test Setup - MEMORY
    ${ENDPOINT_SM_100}      Get Adjusted Timestamp    2h
    ${port_open}    Run Keyword And Return Status    Check Admin Readiness
    Run Keyword If    ${port_open}    Run Keyword    Setup Admin
    Collect Snapshot  target_file_name=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip  timeout=1500
    ${verdict}    Memory Leak Analyzer    snapshot_path=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip
    ...                                   regex_type=SMOD_BBMOD
    ...                                   file_type=runtime
    ...                                   sysinfo_storage_path=${RESULTS}/snapshot/sysinfo_zip_files
    ...                                   sysinfo_reports_path=${RESULTS}/snapshot/SysInfoParser_reports
    ...                                   memory_leak_threshold=2.0  #[%]
    ...                                   startpoint=${STARTPOINT_SM_100}
    ...                                   endpoint=${ENDPOINT_SM_100}
    Run Keyword If  '${verdict}'=='fail'  Fail  Test failed due to memory leak.
    [Teardown]    common.Common Test Teardown - MEMORY

[1][3.0] Automated__SM__RMOD_Reset
    [Setup]    common.Common Test Setup - MEMORY
    Run keyword except for FSMF     common.Ensure NORMAL value on all RMODs
    ${STARTPOINT_SM_11}    Get Adjusted Timestamp    2h
    Set Suite Variable    ${STARTPOINT_SM_11}
    Run Looping Test SM.11_RMOD_Reset
    [Teardown]    Run Keywords     SM.11_RMOD_Reset.Test Case Teardown
    ...      AND      Run keyword except for FSMF     common.Restore parameters value on all RMODs

[1][2.0] Automated__MEM__Memory_consumption_verification_during_Radio_Reset
    [Setup]    common.Common Test Setup - MEMORY
    ${ENDPOINT_SM_11}      Get Adjusted Timestamp    2h
    ${port_open}    Run Keyword And Return Status    Check Admin Readiness
    Run Keyword If    ${port_open}    Run Keyword    Setup Admin
    Collect Snapshot  target_file_name=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip  timeout=1500
    ${verdict}    Memory Leak Analyzer    snapshot_path=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip
    ...                                   regex_type=SMOD_BBMOD
    ...                                   file_type=runtime
    ...                                   sysinfo_storage_path=${RESULTS}/snapshot/sysinfo_zip_files
    ...                                   sysinfo_reports_path=${RESULTS}/snapshot/SysInfoParser_reports
    ...                                   memory_leak_threshold=2.0  #[%]
    ...                                   startpoint=${STARTPOINT_SM_11}
    ...                                   endpoint=${ENDPOINT_SM_11}
    Run Keyword If  '${verdict}'=='fail'  Fail  Test failed due to memory leak.
    [Teardown]    common.Common Test Teardown - MEMORY

[1][3.0] Automated__SM__RAT Reset - stress test
    [Setup]    common.Common Test Setup - MEMORY
    ${STARTPOINT_SM_09}    Get Adjusted Timestamp    2h
    Set Suite Variable    ${STARTPOINT_SM_09}
    Run Looping Test SM.09_RAT_Reset
    [Teardown]    SM.09_RAT_Reset.Test Case Teardown

[1][2.0] Automated__MEM__Memory_consumption_verification_during_RAT_Reset
    [Setup]    common.Common Test Setup - MEMORY
    ${ENDPOINT_SM_09}      Get Adjusted Timestamp    2h
    ${port_open}    Run Keyword And Return Status    Check Admin Readiness
    Run Keyword If    ${port_open}    Run Keyword    Setup Admin
    Collect Snapshot  target_file_name=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip  timeout=1500
    ${verdict}    Memory Leak Analyzer    snapshot_path=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip
    ...                                   regex_type=SMOD_BBMOD
    ...                                   file_type=runtime
    ...                                   sysinfo_storage_path=${RESULTS}/snapshot/sysinfo_zip_files
    ...                                   sysinfo_reports_path=${RESULTS}/snapshot/SysInfoParser_reports
    ...                                   memory_leak_threshold=2.0  #[%]
    ...                                   startpoint=${STARTPOINT_SM_09}
    ...                                   endpoint=${ENDPOINT_SM_09}
    Run Keyword If  '${verdict}'=='fail'  Fail  Test failed due to memory leak.
    [Teardown]    common.Common Test Teardown - MEMORY

[1][1.0] Automated__SM__RAT_block-unblock test
    [Setup]    common.Common Test Setup - MEMORY
    ${STARTPOINT_SM_32}    Get Adjusted Timestamp    2h
    Set Suite Variable    ${STARTPOINT_SM_32}
    Run Looping Test SM.32_RAT_Block_Unblock
    [Teardown]  SM.32_RAT_Block_Unblock.Test Case Teardown

[1][1.0] Automated__MEM__Memory_consumption_verification_during_RAT_block_unblock
    [Setup]    common.Common Test Setup - MEMORY
    ${ENDPOINT_SM_32}      Get Adjusted Timestamp    2h
    ${port_open}    Run Keyword And Return Status    Check Admin Readiness
    Run Keyword If    ${port_open}    Run Keyword    Setup Admin
    Collect Snapshot  target_file_name=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip  timeout=1500
    ${verdict}    Memory Leak Analyzer    snapshot_path=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip
    ...                                   regex_type=SMOD_BBMOD
    ...                                   file_type=runtime
    ...                                   sysinfo_storage_path=${RESULTS}/snapshot/sysinfo_zip_files
    ...                                   sysinfo_reports_path=${RESULTS}/snapshot/SysInfoParser_reports
    ...                                   memory_leak_threshold=2.0  #[%]
    ...                                   startpoint=${STARTPOINT_SM_32}
    ...                                   endpoint=${ENDPOINT_SM_32}
    Run Keyword If  '${verdict}'=='fail'  Fail  Test failed due to memory leak.
    [Teardown]    common.Common Test Teardown - MEMORY

#[1][2.0] SM.49_Cell_add_remove
#    [Setup]    common.Common Test Setup - MEMORY
#    ${STARTPOINT_SM_49}    Get Adjusted Timestamp    2h
#    Set Suite Variable    ${STARTPOINT_SM_49}
#    Run Looping Test SM.49_Cell_add_remove
#    [Teardown]  SM.49_Cell_add_remove.Test Case Teardown
#
#[1][1.0] Automated__MEM__Memory_consumption_verification_during_Cell_add_remove
#    [Setup]    common.Common Test Setup - MEMORY
#    ${ENDPOINT_SM_49}      Get Adjusted Timestamp    2h
#    ${port_open}    Run Keyword And Return Status    Check Admin Readiness
#    Run Keyword If    ${port_open}    Run Keyword    Setup Admin
#    Collect Snapshot  target_file_name=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip  timeout=1500
#    ${verdict}    Memory Leak Analyzer    snapshot_path=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip
#    ...                                   regex_type=SMOD_BBMOD
#    ...                                   file_type=runtime
#    ...                                   sysinfo_storage_path=${RESULTS}/snapshot/sysinfo_zip_files
#    ...                                   sysinfo_reports_path=${RESULTS}/snapshot/SysInfoParser_reports
#    ...                                   memory_leak_threshold=2.0  #[%]
#    ...                                   startpoint=${STARTPOINT_SM_49}
#    ...                                   endpoint=${ENDPOINT_SM_49}
#    Run Keyword If  '${verdict}'=='fail'  Fail  Test failed due to memory leak.
#    [Teardown]    common.Common Test Teardown - MEMORY
#
#[1][1.0] Automated__SM__Snapshot_collection
#    [Setup]    Run Keywords    common.Common Test Setup - MEMORY    AND    SM.51_Snapshot_Collection.Test Case Setup
#    ...                 AND    Set Test Variable    ${ITERATIONS}    ${SNAPSHOT_ITERATIONS}
#    ${STARTPOINT_SM_51}    Get Adjusted Timestamp    2h
#    Set Suite Variable    ${STARTPOINT_SM_51}
#    Run Looping Test SM.51_Snapshot_Collection
#    [Teardown]    SM.51_Snapshot_Collection.Test Case Teardown
#
#[1][1.0] Automated__MEM__Memory_consumption_check_after_snapshot_collection
#    [Setup]    common.Common Test Setup - MEMORY
#    ${ENDPOINT_SM_51}      Get Adjusted Timestamp    2h
#    ${port_open}    Run Keyword And Return Status    Check Admin Readiness
#    Run Keyword If    ${port_open}    Run Keyword    Setup Admin
#    Collect Snapshot  target_file_name=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip  timeout=1500
#    ${verdict}    Memory Leak Analyzer    snapshot_path=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip
#    ...                                   regex_type=SMOD_BBMOD
#    ...                                   file_type=runtime
#    ...                                   sysinfo_storage_path=${RESULTS}/snapshot/sysinfo_zip_files
#    ...                                   sysinfo_reports_path=${RESULTS}/snapshot/SysInfoParser_reports
#    ...                                   memory_leak_threshold=2.0  #[%]
#    ...                                   startpoint=${STARTPOINT_SM_51}
#    ...                                   endpoint=${ENDPOINT_SM_51}
#    Run Keyword If  '${verdict}'=='fail'  Fail  Test failed due to memory leak.
#    [Teardown]    common.Common Test Teardown - MEMORY
#
#[1][1.0] Automated__SM__SCREL_collection
#    [Setup]    Run Keywords    common.Common Test Setup - MEMORY    AND    SM.51_Snapshot_Collection.Test Case Setup
#    ...                 AND    Set Test Variable  ${ITERATIONS}  ${SNAPSHOT_ITERATIONS}  AND  Set Test Variable  ${SNAPSHOT_TYPE}  SCREL
#    ${STARTPOINT_SM_51_SCREL}    Get Adjusted Timestamp    2h
#    Set Suite Variable    ${STARTPOINT_SM_51_SCREL}
#    Run Looping Test SM.51_Snapshot_Collection
#    [Teardown]    SM.51_Snapshot_Collection.Test Case Teardown
#
#[1][1.0] Automated__MEM__Memory_consumption_check_after_SCREL_collection
#    [Setup]    common.Common Test Setup - MEMORY
#    ${ENDPOINT_SM_51_SCREL}  Get Adjusted Timestamp    2h
#    ${port_open}      Run Keyword And Return Status    Check Admin Readiness
#    Run Keyword If      ${port_open}    Run Keyword    Setup Admin
#    Collect Snapshot  target_file_name=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip  timeout=1500
#    ${verdict}    Memory Leak Analyzer    snapshot_path=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip
#    ...                                   regex_type=SMOD_BBMOD
#    ...                                   file_type=runtime
#    ...                                   sysinfo_storage_path=${RESULTS}/snapshot/sysinfo_zip_files
#    ...                                   sysinfo_reports_path=${RESULTS}/snapshot/SysInfoParser_reports
#    ...                                   memory_leak_threshold=2.0  #[%]
#    ...                                   startpoint=${STARTPOINT_SM_51_SCREL}
#    ...                                   endpoint=${ENDPOINT_SM_51_SCREL}
#    Run Keyword If  '${verdict}'=='fail'  Fail  Test failed due to memory leak.
#    [Teardown]    common.Common Test Teardown - MEMORY

[1][1.0] Automated__MEM__Memory_consumption_verification_on_FHS
    [Tags]
    [Setup]    Run Keywords    common.Common Test Setup - MEMORY    AND    Set Test Variable    ${ITERATIONS}    ${1}
    Run Looping Test MEM.03_Memory_consumption_veryfication_on_FHS
    [Teardown]    MEM.03_Memory_consumption_veryfication_on_FHS.Test Case Teardown

[1][1.0] Automated__LOGS__Check_BTS_file_system_for_presence_of_log_files
    [Tags]
    [Setup]    Run Keywords    common.Common Test Setup - MEMORY    AND    Set Test Variable    ${ITERATIONS}    ${1}
    Run Looping Test LOGS.01_Check_BTS_file_system_for_presence_of_log_files
    [Teardown]    LOGS.01_Check_BTS_file_system_for_presence_of_log_files.Test Case Teardown

[1][1.0] Automated__MEM__Memory_Mixed_Scenarios_-_END
    [Tags]
    [Setup]    Run Keywords    common.Common Test Setup - MEMORY    AND    Set Test Variable    ${ITERATIONS}    ${MIX_END_ITERATIONS}
    Run Looping Test Memory Mixed Scenarios
    [Teardown]    common.Common Test Teardown - MEMORY
#### MEMORY END ###


*** Keywords ***
Run Looping Test ${test_name}
    ${passed_iterations}  Set Variable    ${0}
    ${failed_in_row}      Set Variable    ${0}
    ${KEYWORD_INDEX}      Set Variable    ${8}
    ${critical_in_row}    Set Variable    ${0}
    Append To List    ${TEST_SUITE_CONTENT}  ${TEST_NAME}
    ${TEST_INDEX}  Get Index From List    ${TEST_SUITE_CONTENT}  ${TEST_NAME}
    ${ITERATIONS}    Convert To Integer    ${ITERATIONS}
    ${data}    Create List
    FOR    ${iteration}    IN RANGE    1  ${ITERATIONS}+1
        Set Test Variable  ${ITERATION_INDEX}  ${iteration}
        Log In Frame    ${iteration} of ${ITERATIONS} - ${test_name}
        ${RESULTS_i}    Create Log Directory For Looping    ${iteration}
        ${port_open}    Run Keyword And Return Status    Check Admin Readiness
        Run Keyword If    ${port_open}    Run Keywords    Setup Syslog  ${RESULTS_i}/syslog    AND    Setup Admin
        alarms.Start Watchdog  ${skip_fault}
        ${iteration_start_time}    Get Current Time
        ${passed}    Run Keyword And Return Status    ${test_name}
        ${iteration_end_time}     Get Current Time
        Collect Syslog Files    ${RESULTS_i}/syslog/syslog.tar.gz
        ${no_unexpected_fid}  Run Keyword And Return Status  Stop Watchdog And Check Alarms
        ${critical_in_row}    Set Variable If    ${verdict} is True  ${0}  ${critical_in_row+1}
        Run Keyword If    ${critical_in_row} > 5  Fail    Test case failed due to 5 consecutive Critical alarms
        ${time_diff}  Subtract Date From Date  ${iteration_end_time}  ${iteration_start_time}
        ${raw_data}  Create List  ${iteration}  ${iteration_start_time}  ${iteration_end_time}  ${time_diff}  ${passed}  ${no_unexpected_fid}
        Append To List    ${data}    ${raw_data}
        ${failed_in_row}  Set Variable If  ${passed} is True and ${no_unexpected_fid} is True  ${0}  ${failed_in_row+1}
        Run Keyword If  not ${passed} or not ${no_unexpected_fid}  Run Keyword If    0 < ${failed_in_row} <= ${MAX_FAIL_IN_ROW}
        ...    Run Keyword And Ignore Error    Recovery Snapshot For Looping    ${iteration}
        ${status}  ${passed_iterations}    Run Keyword And Ignore Error
        ...    Set Variable If  ${passed} and ${no_unexpected_fid}    ${passed_iterations+1}    ${passed_iterations}
        ${time_limit_reached}    Verify Suite Duration    ${TEST_SUITE_DURATION}
        Exit For Loop If    ${time_limit_reached}
    END
    ${headers}    Create List    iteration    iteration_start_time    iteration_end_time    time_difference    test verdict    watchdog verdict
    Generate Table    ${headers}    ${data}
#    Collect Runtime Sysinfo
    Collect Snapshot  target_file_name=${RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}.zip  timeout=1500
    Log  ${TEST_NAME}: ${passed_iterations}/${ITERATIONS} iterations passed    WARN
    Run Keyword If  not ${time_limit_reached}  Should Be Equal   ${passed_iterations}    ${ITERATIONS}

Recovery Snapshot For Looping
    [Arguments]    ${iteration}
    ${timestamp}    DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    Log To Console    Iteration ${iteration} failed. Collecting logs.
    ${target_file_name}    Set Variable    ${RESULTS}/snapshot/${iteration}/${timestamp}_snapshot_mrbts-${MRBTS_ID}.zip
    Wait Until Keyword Succeeds  3x  10s  Collect Snapshot  target_file_name=${target_file_name}  timeout=1500

Create Log Directory For Looping
    [Arguments]    ${iteration}
    ${iteration}    Convert To String    ${iteration}
    ${RESULTS_i}    Join Path    ${RESULTS}    ${iteration}
    Create Directory    ${RESULTS_i}
    [Return]    ${RESULTS_i}

Memory Mixed Scenarios
    Resolve Locked RMOD
    Resolve Blocked Cells
    SM.04_Cell_Block_Unblock
    Run keyword except for FSMF     common.Ensure NORMAL value on all RMODs
    SM.05_RMOD_Lock_Unlock
    Run keyword except for FSMF     common.Restore parameters value on all RMODs
    Run Keyword If  'nr' in $rats
    ...        MEM.02_Neighbouring_NR_Objects_Delta_Commissioning_via_Admin
    ...  ELSE  MEM.01_Neighbouring_Objects_Delta_Commissioning_via_Admin
