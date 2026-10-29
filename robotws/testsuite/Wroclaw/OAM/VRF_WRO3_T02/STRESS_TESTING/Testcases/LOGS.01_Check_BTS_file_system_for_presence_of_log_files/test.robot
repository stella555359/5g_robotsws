*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/ald.robot
Resource    ../../../resources_mem/netact.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/big_delta.robot
Library     ../../../resources_mem/python_lib/LogFilesLibrary.py

Documentation
...  TEST NAME:     LOGS.01_Check_BTS_file_system_for_presence_of_log_files
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test scenario is to verify that the periodic log collection script is writing files with the
...  extension .log in expected directory during long duration tests.
...  The first checkpoint is performed at the beginning of our LDT tests, the second checkpoint at the end of the run.
...  The comparison of the files takes place dozens of hours after the BTS start-up.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  29.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-580 - TC creation
...  01.07.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-22686 - Test adaptation for checking second BTS
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${pre_condition_error_msg}    Pre-conditions criteria does not meet! Variable \${1st_checkpoint_log_files} not found.

*** Keywords ***
LOGS.01_Check_BTS_file_system_for_presence_of_log_files

    LOGS.01_Check_BTS_file_system_for_presence_of_log_files.Test_Step:0 Test Preparation
    LOGS.01_Check_BTS_file_system_for_presence_of_log_files.Test_Step:1 Verify log Files

LOGS.01_Check_BTS_file_system_for_presence_of_log_files.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Check If NLWG Cells Are OnAir
    Check Log Files Existence

LOGS.01_Check_BTS_file_system_for_presence_of_log_files.Test_Step:1 Verify log Files
    Log to console    \n========================================
    Log  Step: 1 Verify log Files on Primary    console=${True}
    Log to console    ========================================
    ${slave_results}    Set Variable    ${False}
    ${2nd_checkpoint_log_files_master}  Get Log File List Master
    ${master_results}    Compare File Sizes  ${1st_checkpoint_log_files_master}  ${2nd_checkpoint_log_files_master}
    Run Keyword If    ${1st_checkpoint_log_files_slave} != None    Verify Secondary Logs
    ...    ELSE    Log to Console    There is no secondary core, please check size of logs from primary.
    Provide Check Results    ${master_results}    ${slave_results}

LOGS.01_Check_BTS_file_system_for_presence_of_log_files.Test Case Teardown
    Run Keyword  common.Common Test Teardown - MEMORY

Verify Secondary Logs
    Log to console    \n========================================
    Log  Step: 2 Verify log Files on Secondary   console=${True}
    Log to console    ========================================
    ${2nd_checkpoint_log_files_slave}  Get Log File List Slave
    ${slave_results}    Compare File Sizes  ${1st_checkpoint_log_files_slave}  ${2nd_checkpoint_log_files_slave}

Check Log Files Existence
    ${1st_checkpoint_master_exist}  Run Keyword And Return Status  Variable Should Exist  ${1st_checkpoint_log_files_master}
    ${1st_checkpoint_slave_exist}  Run Keyword And Return Status  Variable Should Exist  ${1st_checkpoint_log_files_slave}
    Run Keyword If  not ${1st_checkpoint_master_exist} or not ${1st_checkpoint_slave_exist}  Run Keywords
    ...    Log To Console    ${pre_condition_error_msg}
    ...    AND    Fail  ${pre_condition_error_msg}

Provide Check Results
    [Arguments]    ${master_results}    ${slave_results}
    ${condition}    Evaluate    ${master_results} or ${slave_results} != False
    Run Keyword If    ${condition}    Log    At least one file *.log with a size >= 1MB was detected.    WARN
    Run Keyword If    ${condition}    Fail    Test failure due to excessive file size.
