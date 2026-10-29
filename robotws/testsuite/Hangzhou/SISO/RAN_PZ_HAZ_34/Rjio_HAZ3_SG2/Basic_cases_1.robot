# *** Settings ***
# Suite Setup          Dedicate_Suite_Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# 
# #Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/Rjio_HAZ3_SG2/Resources/made_variable.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# # Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_RF_module_power_reset.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_RF_module_reset_from_GUI.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_Collect_RFSW_logs_fr
# ...om_RU_into_BTS_Snapshot.robot
# 
# Force Tags
# 
# *** Variables ***
# ${if_commissioning}    False
# ${loop_times}    1
# ${reset_number}    1
# ${loop_timeout}    ${loop_times}h
# 
# *** Test Cases ***
# [1]Rjio_E2E_01_Commissioning
#     [Documentation]    Rjio_E2E_01_Commissioning
#     [Tags]
#     [Timeout]    1h
#     Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
# 
# [1]Rjio_E2E_03_Power_Reset_Rf
#     [Documentation]    Rjio_E2E_03_Power_Reset_Rf
#     [Tags]
#     [Timeout]
#     FOR   ${index}   IN RANGE   0    ${reset_number}
#         General_SiSo_RF_module_power_reset
#     END
# 
# [1]Rjio_E2E_05_Radio_Lock_Unlock
#     [Documentation]    Rjio_E2E_05_Radio_Lock_Unlock
#     [Tags]
#     [Timeout]    ${loop_timeout}
#     FOR    ${index}    IN RANGE    0    ${loop_times}
#         Rjio_E2E_05_Radio_Lock_Unlock
#     END
# 
# [1]Rjio_E2E_10_SW_Upgrade
#     [Documentation]    to_replace
#     [Tags]
#     [Timeout]    ${loop_timeout}
#     FOR    ${index}    IN RANGE    0    ${loop_times}
#         Perform_SW_rollback
#         Perform_SW_rollback
#     END
# 
# [1]Rjio_E2E_18_Radio_Unit_Restart_After_The_Software_Upgrade(_Minor)
#     [Documentation]    to_replace
#     [Tags]
#     [Timeout]    1h
#     Perform_SW_rollback
#     Perform_SW_rollback
#     Wait until keyword succeeds    10min    30s    verify all cells should be onair
#     General_SiSo_RF_module_reset_from_GUI
# 
# [1]Rjio_E2E_20_Continuous_Snapshot_Fetching.
#     [Documentation]    to_replace
#     [Tags]
#     [Timeout]    ${loop_timeout}
#     FOR    ${index}    IN RANGE    0    ${loop_times}
#         ${snapshot_zip_file_full}    Save Full Snapshot
#         check_unexpected_alarms
#     END
# 
# [1]Rjio_E2E_21_Snapshot_Content_Compare
#     [Documentation]    to_replace
#     [Tags]
#     [Timeout]    ${loop_timeout}
#     FOR    ${index}    IN RANGE    0    ${loop_times}
#         General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#         check_unexpected_alarms
#     END
# 
# [1]Rjio_E2E_22_Initiate_Sfp_Monitoring_From_Webem_For_Ru_Dynamic_Data
#     [Tags]
#     [Timeout]    1h
#     ${links}    ${SMOD}    ${BBMOD}    ${RMOD}=    Get Information about SFP links
#     ${dynamic_1}=    Check_if_dynamic_parameters_have_a_valid_value_for_ports   links=${links}    dict_of_links=${RMOD}
#     Sleep    120s
#     ${links}    ${SMOD}    ${BBMOD}    ${RMOD}=    Get Information about SFP links
#     ${dynamic_2}=    Check_if_dynamic_parameters_have_a_valid_value_for_ports   links=${links}    dict_of_links=${RMOD}
# 
# [1]Rjio_E2E_57_Parallel_Operation_RU_Lock_And_Site_Reset
#     [Documentation]    Rjio_E2E_57_Parallel_Operation_RU_Lock_And_Site_Reset.
#     [Tags]
#     [Timeout]
#     FOR   ${index}   IN RANGE   ${reset_number}
#         Rjio_E2E_57_Parallel_Operation_RU_Lock_And_Site_Reset
#     END
# 
# [1]Rjio_E2E_58_Parallel_Operation_RU_Lock_And_Parameter_Change
#     [Documentation]    Rjio_E2E_58_Parallel_Operation_RU_Lock_And_Parameter_Change
#     [Tags]
#     [Timeout]    ${loop_timeout}
#     FOR    ${index}    IN RANGE    0    ${loop_times}
#         Rjio_E2E_58_Parallel_Operation_RU_Lock_And_Parameter_Change
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
# [1]Rjio_E2E_61_Parallel_Operation_RU_Lock_And_Snapshot
#     [Documentation]    Rjio_E2E_61_Parallel_Operation_RU_Lock_And_Snapshot
#     [Tags]
#     [Timeout]    ${loop_timeout}
#     FOR    ${index}    IN RANGE    0    ${loop_times}
#         Rjio_E2E_61_Parallel_Operation_RU_Lock_And_Snapshot
#     END
# 
# *** Keywords ***
# Dedicate_Suite_Setup
#     Import Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/TLData/${testline_name}/TLConfiguration.py
#     SISO Coam Suite Setup
# 
# Perform_SW_rollback
#     [Arguments]  ${connection}=GNB_OAM
#     log to console    start rollback...
#     coam.rollback_software    connection=${connection}
#     sleep    2min
#     COAM Wait gnb And Cells ready    timeout=15min    gnb_type='${gNb_CuType}'
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
# 
# collect_RFSW_log_Continuous_check_unexpected_alarms
#     [Arguments]   ${snapshot_path}=${TS_CASE_LOG_PATH}
#     Connect to Common Unit Master
#     ${ru_index_list}  Get All RU Index
#     FOR  ${ru_index}  IN  @{ru_index_list}
#         Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
#         ${log_on_ru}   Get RFSW Log File List On RU    connection=RU_${ru_index}
#         csn.Disconnect  connection=RU_${ru_index}
#         check_unexpected_alarms
#     END
#     [Teardown]  csn.Disconnect  connection=ASIK Master
# 
# check_snapshot_info_compare_RU
#     [Arguments]    ${ru_index}=${1}    ${is_get_snapshot_via_selenium}=${True}
#     Connect to Common Unit Master
#     Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
#     Verify RFSW Log Include In Snapshot  ru_index=${ru_index}  ru_alias=RU_${ru_index}  snapshot_path=${SAVE LOG DIRECTORY}
#     ...    is_get_snapshot_via_selenium=${is_get_snapshot_via_selenium}
#     csn.Disconnect  connection=RU_${ru_index}
#     csn.Disconnect  connection=ASIK Master
# 
# Rjio_E2E_05_Radio_Lock_Unlock
#     log to console    ++++ start lock all RUs ++++
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     ${ru_index_list}    Get All RU Index
#     FOR    ${RU_idx}    IN    @{ru_index_list}
#         selenium_coam.lock_ru    ru_index=${RU_idx}
#         wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
#     END
#     log to console    ++++ start unlock all RUs ++++
#     FOR    ${RU_idx}    IN    @{ru_index_list}
#         selenium_coam.unlock_ru    ru_index=${RU_idx}
#         wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}
#     END
#     Wait until keyword succeeds    10min    30s    verify all cells should be onair
#     [Teardown]    Selenium Logout And Close Browser
# 
# Check_if_dynamic_parameters_have_a_valid_value_for_ports
#     [Arguments]    ${links}    ${dict_of_links}
#     ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
#     &{dynamic_port}=    Create Dictionary
#     FOR    ${port}    IN    @{list_of_links}
#         ${dynamic_direction}=    Check_if_dynamic_parameters_have_a_valid_value_for_directions   links=${links}
#         ...    dict_of_links=${dict_of_links}    port=${port}
#         Set To Dictionary    ${dynamic_port}    ${port}    ${dynamic_direction}
#     END
#     [Return]    ${dynamic_port}
# 
# Check_if_dynamic_parameters_have_a_valid_value_for_directions
#     [Arguments]    ${links}    ${dict_of_links}    ${port}
#     &{dynamic_direction}=    Create Dictionary
#     @{list_of_dynamic_params}=    Create List
#     ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
#     FOR    ${direction}    IN    @{list_of_directions}
#         Run Keyword If   '${direction}'=='source'    Set Suite Variable    ${initial_direction}    initialSource
#         Run Keyword If   '${direction}'=='destination'    Set Suite Variable    ${initial_direction}    initialDestination
#         Set Suite Variable   ${moduleTemperature}
#         ...    ${links["connected"][${port}]["data"]["measurements"]["moduleTemperature"]["${direction}"]}
#         Should Be True  20<=${moduleTemperature}<=65
#         Set Suite Variable   ${TXSupplyVoltage}
#         ...    ${links["connected"][${port}]["data"]["measurements"]["TXSupplyVoltage"]["${direction}"]}
#         Should Be True  2000<=${TXSupplyVoltage}<=4500
#         Set Suite Variable   ${TXBiasCurrent}
#         ...    ${links["connected"][${port}]["data"]["measurements"]["TXBiasCurrent"]["${direction}"][0]}
#         Should Be True  0<=${TXBiasCurrent}<=50
#         Set Suite Variable   ${TXOpticalPower}
#         ...    ${links["connected"][${port}]["data"]["measurements"]["TXOpticalPower"]["${initial_direction}"][0]}
#         Should Be True  300<=${TXOpticalPower}<=2000
#         Set Suite Variable   ${RXOpticalPower}
#         ...    ${links["connected"][${port}]["data"]["measurements"]["RXOpticalPower"]["${initial_direction}"][0]}
#         Should Be True    100<=${RXOpticalPower}<=2000
#         Append To List    ${list_of_dynamic_params}    ${moduleTemperature}    ${TXSupplyVoltage}
#         ...    ${TXBiasCurrent}    ${RXOpticalPower}
#         ...    ${TXBiasCurrent}    ${TXOpticalPower}    ${RXOpticalPower}
#         Set To Dictionary    ${dynamic_direction}    ${direction}    ${list_of_dynamic_params}
#     END
#     [Return]    ${dynamic_direction}
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
# Rjio_E2E_58_Parallel_Operation_RU_Lock_And_Parameter_Change
#     [Arguments]    ${RU_idx}=${1}    ${cellid}=1    ${connection}=GNB_OAM
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     selenium_coam.lock_ru    ru_index=${RU_idx}
#     Selenium Logout And Close Browser
#     wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
# #    check_unexpected_alarms
# #    sleep    2min
#     log to console    start modify parameter...
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     ${qRXLevMin_origin_value}    selenium_coam.get_parameter_value
#     ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}    filter_param=Minimum required RX level in the cell (dBm)
#     ...    abbr=qRxLevMin
# #    ${qRXLevMin_origin_value}    coam.get_parameters   dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}
# #    ...    pattern=qRxLevMin   connection=${connection}
#     selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}
#     ...    filter_param=Minimum required RX level in the cell (dBm)    abbr=qRxLevMin    new_value=-70
#     selenium_coam.validate_plan
#     selenium_coam.activate_plan    activate_plan_despite_errors=${True}
#     Selenium Logout And Close Browser
# #    check_unexpected_alarms
# #    wait until keyword succeeds    10min    30s    verify all cells should be onair
#     sleep    2min
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}
#     ...    filter_param=Minimum required RX level in the cell (dBm)    abbr=qRxLevMin    new_value=${qRXLevMin_origin_value}
#     selenium_coam.validate_plan
#     selenium_coam.activate_plan    activate_plan_despite_errors=${True}
#     Selenium Logout And Close Browser
#     sleep    2min
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
# Rjio_E2E_61_Parallel_Operation_RU_Lock_And_Snapshot
#     [Arguments]    ${RU_idx}=${1}    ${connection}=GNB_OAM    ${gnb_index}=${0}
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     selenium_coam.lock_ru    ru_index=${RU_idx}
#     Selenium Logout And Close Browser
#     wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
#     log to console    \n***start check snapshot info...
#     check_snapshot_info_compare_RU
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     selenium_coam.unlock_ru    ru_index=${RU_idx}
#     wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}
#     wait until keyword succeeds    10min    30s    verify all cells should be onair
#     check_snapshot_info_compare_RU
#     check_unexpected_alarms
#     [Teardown]    run keywords
#     ...    run keyword and ignore error    selenium_coam.unlock_ru    ru_index=${RU_idx}
#     ...    AND    Selenium Logout And Close Browser
