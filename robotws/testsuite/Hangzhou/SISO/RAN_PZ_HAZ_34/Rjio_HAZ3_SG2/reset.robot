# *** Settings ***
# Suite Setup          Dedicate_Suite_Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# 
# #Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/Rjio_HAZ3_SG2/Resources/made_variable.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_RF_module_power_reset.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_BTS_startup_management.robot
# 
# Force Tags
# 
# *** Variables ***
# #${if_commissioning}    False
# ${reset_number}    7
# 
# *** Test Cases ***
# [1]Rjio_AQQJ_2_5G_RAT_Reset
#     [Documentation]    To check Cell on air after reset NR without any unexpected faults
#     [Tags]
#     [Timeout]
#     FOR    ${index}    IN RANGE    0    ${reset_number}
#         5G_RAT_Reset
#     END
# 
# [1]Rjio_E2E_02_Power_Reset_Site
#     [Documentation]
#     [Tags]
#     [Timeout]
#     FOR   ${index}   IN RANGE    0    ${reset_number}
#         General_BTS_startup_management
#     END
# 
# [1]Rjio_E2E_04_Site_Reset
#     [Documentation]    To check Cell on air after site reset without any unexpected faults 
#     [Tags]
#     [Timeout]
#     FOR   ${index}   IN RANGE    0    ${reset_number}
#         5G_Site_Reset
#     END
# 
# [1]Rjio_E2E_03_Power_Reset_Rf
#     [Documentation]    Rjio_E2E_03_Power_Reset_Rf
#     [Tags]
#     [Timeout]
#     FOR   ${index}   IN RANGE   0    ${reset_number}
#         General_SiSo_RF_module_power_reset
#     END
#     
# [1]Rjio_E2E_57_Parallel_Operation_RU_Lock_And_Site_Reset
#     [Documentation]    Rjio_E2E_57_Parallel_Operation_RU_Lock_And_Site_Reset.
#     [Tags]
#     [Timeout]
#     FOR   ${index}   IN RANGE   ${reset_number}
#         Rjio_E2E_57_Parallel_Operation_RU_Lock_And_Site_Reset
#     END
#     
# [1]Rjio_E2E_60_Parallel_Operation_RU_Lock_And_RU_reset
#     [Documentation]    Rjio_E2E_60_Parallel_Operation_RU_Lock_And_RU_reset
#     [Tags]
#     [Timeout]
#     FOR    ${index}    IN RANGE    0    ${reset_number}
#         Rjio_E2E_60_Parallel_Operation_RU_Lock_And_RU_reset
#     END    
# 
# *** Keywords ***
# Dedicate_Suite_Setup
#     Import Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/TLData/${testline_name}/TLConfiguration.py
#     SISO Coam Suite Setup
# 
# 5G_RAT_Reset
#     sleep    5s
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     selenium_coam.reset_nr
#     sleep    180s
#     Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
#     [Teardown]    Selenium Logout And Close Browser
# 
# 5G_Site_Reset
#     sleep    5s
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     Perform BTS Site Reset On WebUI
#     sleep    60s
#     Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
#     [Teardown]    Selenium Logout And Close Browser
# 
# Rjio_E2E_57_Parallel_Operation_RU_Lock_And_Site_Reset
#     [Arguments]    ${RU_idx}=${1}
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     selenium_coam.lock_ru    ru_index=${RU_idx}
#     Selenium Logout And Close Browser
#     wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     selenium_coam.reset_site
#     Selenium Logout And Close Browser
#     sleep    5min
#     wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     selenium_coam.unlock_ru    ru_index=${RU_idx}
#     wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}
#     wait until keyword succeeds    10min    30s    verify all cells should be onair
#     check_unexpected_alarms
#     [Teardown]    run keywords
#     ...    run keyword and ignore error    selenium_coam.unlock_ru    ru_index=${RU_idx}  AND
# #    ...    wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}    AND
#     ...    Selenium Logout And Close Browser    AND    Save Full Snapshot
# 
# Rjio_E2E_60_Parallel_Operation_RU_Lock_And_RU_reset
#     [Arguments]    ${RU_idx}=${1}    ${connection}=GNB_OAM    ${gnb_index}=${0}
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     selenium_coam.lock_ru    ru_index=${RU_idx}
#     Selenium Logout And Close Browser
#     wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
# #    check_unexpected_alarms
#     log to console    \n***start RU reset after RU locked...
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     selenium_coam.reset_ru  ru_index=${RU_idx}
#     Selenium Logout And Close Browser
#     Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${RU_idx}   connection=${connection}
#     wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     selenium_coam.unlock_ru    ru_index=${RU_idx}
#     wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}
#     coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    gnb_index=${gnb_index}    connection=${connection}
#     ${ru_index_list}    get all ru index
#     Check RF Startup and Gnb Status    ru_index_list=${ru_index_list}    gnb_index=${gnb_index}    connection=${connection}
#     wait until keyword succeeds    10min    30s    verify all cells should be onair
#     check_unexpected_alarms
#     [Teardown]    run keywords
#     ...    run keyword and ignore error    selenium_coam.unlock_ru    ru_index=${RU_idx}  AND
# #    ...    wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}    AND
#     ...    Selenium Logout And Close Browser    AND    Save Full Snapshot
# 
# Save Full Snapshot
#     [Arguments]    ${snapshot_path}=${TS_CASE_LOG_PATH}    ${connection}=GNB_OAM
#     ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M
#     ${snapshot_zip_file_full}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
#     coam.get_snapshot    target_file_name=${snapshot_zip_file_full}    coverage=Full    timeout=1500    connection=${connection}
#     [Return]    ${snapshot_zip_file_full}
# 
# check_unexpected_alarms
#     ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#     should be true    ${cell_status}
#     ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist
#     ...    file_path=${TS_CASE_LOG_PATH}   allowed_faults=@{ALLOWED_FAULT}
#     should be true    ${alarm_status}
#     ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
#     ...    file_path=${TS_CASE_LOG_PATH}    allowed_faults=@{ALLOWED_HISTORY_FAULT}    
