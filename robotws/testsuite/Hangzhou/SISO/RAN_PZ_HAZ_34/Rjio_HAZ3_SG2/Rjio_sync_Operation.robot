# *** Settings ***
# Suite Setup          Dedicate_Suite_Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# 
# #Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/Rjio_HAZ3_SG2/Resources/made_variable.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
# #Resource    ./Resources/L3call_keywords.robot
# 
# Force Tags    PY36
# 
# *** Variables ***
# ${if_commissioning}    False
# #   ${Golden_SCF_Path}   ${commissionings_path}/HGZ/${testline_name}/SCF_SBTS22R4.xml
# ${DU_OAM_IP}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# #${acceptedClock_path_GPS}    MRBTS-166/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
# #${acceptedClock_path_TOP-P}   MRBTS-166/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1
# #${accept_clock_value_modify}    7
# #   ${accpetclock_gps}    6
# #   ${accpetclock_top}    6
# 
# *** Test Cases ***
# [1]Rjio_AQQJ_10_Sync_fall_back_from_GPS_to_PTP
#     Rjio_AQQJ_10_Sync_fall_back_from_GPS_to_PTP
# 
# [1]Rjio_E2E_59_Parallel_Operation_RU_Lock_And_SW_Upgrade
#     ${RU_idx}    Set variable    ${1}
#     RU_cmd_via_Selenum    ru_cmd=lock_ru    RU_idx=${RU_idx}
#     Connect to gnb coam via ssl
#     wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
#     log to console    start upgrade SW by rollback...
#     Perform_SW_rollback_without_check_cell_status
#     sleep    15min
#     run keyword and ignore error    wait until keyword succeeds    25min    30s    verify all cells should be onair
#     ${rb_status}    Run Keyword And Return Status   Perform_SW_rollback_without_check_cell_status
#     Run keyword Unless    ${rb_status}    sleep    15min
#     Run keyword Unless    ${rb_status}    Perform_SW_rollback_without_check_cell_status
#     Should Be True    ${rb_status}
#     sleep    15min
#     RU_cmd_via_Selenum    ru_cmd=unlock_ru    RU_idx=${1}
#     wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}
#     wait until keyword succeeds    10min    30s    verify all cells should be onair
#     check_unexpected_alarms
#     [Teardown]    run keywords
#     ...    Run Keyword If Test Failed    Save Full Snapshot    AND
#     ...    Run Keyword Unless    ${rb_status}    Perform_SW_rollback_without_check_cell_status    AND
#     ...    Run Keyword Unless    ${rb_status}    sleep    15min    AND
#     ...    run keyword and ignore error    RU_cmd_via_Selenum    ru_cmd=unlock_ru    RU_idx=${RU_idx}    AND
#     ...    wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}    AND
#     ...    SISO Coam Test Teardown
# 
# #[1]Rjio_E2E_23_PTP_Failure_Between_SM_And_RM_Reference
# #    [Setup]    run keywords    SISO Coam Test Setup    AND    PTP failure_Setup
# #    PTP_failure_between_SM_and_RM_reference
# #    [Teardown]    run keywords    PTP failure_teardown    AND    SISO Coam Test Teardown
# 
# *** Keywords ***
# Dedicate_Suite_Setup
#     Import Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/TLData/${testline_name}/TLConfiguration.py
#     SISO Coam Suite Setup
# 
# Rjio_E2E_59_Parallel_Operation_RU_Lock_And_SW_Upgrade
#     [Arguments]    ${RU_idx}=${1}
# #    Selenium Login And Disable Screen Lock
# #    run keyword and ignore error    Close Start Up View    timeout=60
# #    selenium_coam.lock_ru    ru_index=${RU_idx}
# #    Selenium Logout And Close Browser
#     RU_cmd_via_Selenum    ru_cmd=lock_ru    RU_idx=${RU_idx}
#     Connect to gnb coam via ssl
#     wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${RU_idx}
# #    selenium_coam.unlock_ru
# #    wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}
# #    check_unexpected_alarms
#     log to console    start upgrade SW by rollback...
#     Perform_SW_rollback_without_check_cell_status
#     sleep    10min
#     run keyword and ignore error    wait until keyword succeeds    25min    30s    verify all cells should be onair
#     ${rb_status}    Run Keyword And Return Status   Perform_SW_rollback_without_check_cell_status
#     Should Be True    ${rb_status}
#     sleep    15min
# #    Selenium Login And Disable Screen Lock
# #    run keyword and ignore error    Close Start Up View    timeout=60
# #    selenium_coam.unlock_ru    ru_index=${RU_idx}
# #    Selenium Logout And Close Browser
#     RU_cmd_via_Selenum    ru_cmd=unlock_ru    RU_idx=${RU_idx}
#     wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}
#     wait until keyword succeeds    10min    30s    verify all cells should be onair
#     check_unexpected_alarms
#     [Teardown]    run keywords
#     ...    Save Full Snapshot    AND
#     ...    Run Keyword Unless    ${rb_status}    Perform_SW_rollback_without_check_cell_status    AND
#     ...    Run Keyword Unless    ${rb_status}    sleep    15min    AND
#     ...    run keyword and ignore error    RU_cmd_via_Selenum    ru_cmd=unlock_ru    RU_idx=${RU_idx}    AND
#     ...    wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${RU_idx}
# 
# RU_cmd_via_Selenum
#     [Arguments]    ${ru_cmd}    ${RU_idx}=${1}
#     [Documentation]
#     ...    ********************************
#     ...    ${ru_cmd}:lock_ru,unlock_ru
#     ...    ${RU_idx}:${1}
#     Selenium Login And Disable Screen Lock
#     run keyword and ignore error    Close Start Up View    timeout=60
#     Run keyword if    '${ru_cmd}'=='lock_ru'    selenium_coam.lock_ru    ru_index=${RU_idx}
#     ...     ELSE    selenium_coam.unlock_ru    ru_index=${RU_idx}
#     Selenium Logout And Close Browser
# 
# Rjio_AQQJ_10_Sync_fall_back_from_GPS_to_PTP
#     #commission_scf    ${new_scf_suffix}
#     Check GPS active
#     DU GNSSE Reset
#     Check PTP Fisrt Recovery And GPS Second Recovery
#     Connect to gnb coam via ssl
#     verify all cells should be onair
#     check_unexpected_alarms
#     [Teardown]
#     run keywords
#     ...    Selenium Logout And Close Browser
#     Run Keyword And Ignore Error    COAM Teardown gnb connections
# 
# #PTP_failure_between_SM_and_RM_reference
# #    set sync info of GNB1    accpetclock_path=${acceptedClock_path_GPS}    acceptclock=${accept_clock_value_modify}
# #    set sync info of GNB1    accpetclock_path=${acceptedClock_path_TOP-P}    acceptclock=${accept_clock_value_modify}
# #    check sync status change of GNB
# #    Wait For Expect Fault Present    faultId=${16}    timeout=1200
# #    Wait For Expect Fault Present    faultId=${4298}    timeout=1200
# #    set sync info of GNB1    accpetclock_path=${acceptedClock_path_GPS}    acceptclock=${accpetclock_gps}
# #    set sync info of GNB1    accpetclock_path=${acceptedClock_path_TOP-P}    acceptclock=${accpetclock_top}
# #    Wait For Expect Fault To Disappear    faultId=${16}    timeout=1200
# #    Wait For Expect Fault To Disappear    faultId=${4298}    timeout=1200
# #    Connect to gnb coam via ssl
# #    wait until keyword succeeds    10min    30s    verify all cells should be onair
# #    #Run Keyword And Ignore Error    COAM Teardown gnb connections
# #    Log To Console    Check call
# #    Set_PA_Value    value=${20}    attenuator_index=${2}
# #    Prepare_UE_Only
# #    L3call_Traffic_CA_CELL_21_3
# 
# Check GPS active
#     Log To Console   Check GPS active and PTP inactive
#     wait until keyword succeeds    3min    50ms    Check GNSS Syncs Status    expect_syncInputType1=1pps/ToD from external GNSS receiver
#     ...    expect_syncInputType2=TOPP
#     ...    expect_isActive1=${True}    expect_isActive2=${False}
# 
# Check PTP Fisrt Recovery And GPS Second Recovery
#     Log To Console   check PTP Fisrt Recovery
#     wait until keyword succeeds    3min    50ms    Check GNSS Syncs Status    expect_syncInputType1=1pps/ToD from external GNSS receiver
#     ...    expect_syncInputType2=TOPP
#     ...    expect_isActive1=${False}    expect_isActive2=${True}
#     Log To Console   Check GPS Second Recovery
#     wait until keyword succeeds    5min    200ms    Check GNSS Syncs Status    expect_syncInputType1=1pps/ToD from external GNSS receiver
#     ...    expect_syncInputType2=TOPP
#     ...    expect_isActive1=${True}    expect_isActive2=${False}
# 
# DU GNSSE Reset
#     log to console      DU GNSS Reset
#     Selenium Login And Disable Screen Lock
#     run keyword and ignore error    Close Start Up View    timeout=60
#     selenium_coam.reset_gnss
#     [Teardown]     selenium logout and close browser
# 
# Check GNSS Syncs Status
#     [Arguments]    ${expect_syncInputType1}    ${expect_syncInputType2}
#     ...    ${expect_isActive1}    ${expect_isActive2}
#     Log To Console    Check Sync Status
#     ${connection}    coam Login DU
#     ${bts_sync_status}    coam.get_bts_sync_source_status    connection=${connection}
#     Check GNSS SyncSourceInfo Status    bts_sync_status=${bts_sync_status}    SN=${0}
#     ...    expect_syncInputType=${expect_syncInputType1}    expect_isActive=${expect_isActive1}
#     Check GNSS SyncSourceInfo Status    bts_sync_status=${bts_sync_status}    SN=${1}
#     ...    expect_syncInputType=${expect_syncInputType2}    expect_isActive=${expect_isActive2}
#     [Teardown]    coam Logout DU    ${connection}
# 
# Check GNSS SyncSourceInfo Status
#     [Arguments]    ${bts_sync_status}    ${SN}    ${expect_syncInputType}
#     ...    ${expect_isActive}
#     Log To Console    Check syncSourceInfo
#     ${syncSourceInfo}    Get From Dictionary    ${bts_sync_status}    syncSourceInfo
#     ${isActive}    Get From Dictionary    @{syncSourceInfo}[${SN}]    isActive
#     should be equal    ${isActive}    ${expect_isActive}
#     ${syncInputType}    Get From Dictionary    @{syncSourceInfo}[${SN}]    syncInputType
#     should be equal    ${syncInputType}    ${expect_syncInputType}
# 
# coam Login DU
#     [Arguments]  ${ip_address}=${DU_OAM_IP}
#     [Documentation]   Rest Login DU
#     Run Keyword And Ignore Error    coam Logout DU   alias=${alias}
#     Sleep  2
#     ${connection}   coam.Connect To  bts_host=${ip_address}
#     [Return]  ${connection}
# 
# coam Logout DU
#     [Arguments]  ${alias}
#     [Documentation]   Rest Logout DU
#     coam.Teardown  connection=${alias}
# 
# #PTP failure_Setup
# #    ${accpetclock_gps}    get sync info of GNB1    accpetclock_path=${acceptedClock_path_GPS}
# #    ${accpetclock_top}    get sync info of GNB1    accpetclock_path=${acceptedClock_path_TOP-P}
# #    set global variable    ${accpetclock_gps}
# #    set global variable    ${accpetclock_top}
# 
# #PTP failure_teardown
# #    set sync info of GNB1    accpetclock_path=${acceptedClock_path_GPS}    acceptclock=${accpetclock_gps}
# #    set sync info of GNB1    accpetclock_path=${acceptedClock_path_TOP-P}    acceptclock=${accpetclock_top}
# #    #Connect to gnb coam via ssl
# #    wait until keyword succeeds    10min    30s    verify all cells should be onair
# #    Run Keyword And Ignore Error    COAM Teardown gnb connections
# #    Run Keyword And Ignore Error    Selenium Logout And Close Browser
# 
# #get sync info of GNB1
# #    [Documentation]
# #    [Arguments]
# #    ...    ${accpetclock_path}=${acceptedClock_path}
# #    Selenium Login And Disable Screen Lock
# #    ${accpetclock}    selenium_coam.get_parameter_value    dist_name=${accpetclock_path}    filter_param=Accepted clock class list
# #    sort list    ${accpetclock}
# #    [Return]    ${accpetclock}
# #    [Teardown]   Selenium Logout And Close Browser
# 
# #set sync info of GNB1
# #    [Documentation]
# #    [Arguments]
# #    ...    ${accpetclock_path}=${acceptedClock_path}
# #    ...    ${acceptclock}=${accept_clock_value_modify}
# #    Selenium Login And Disable Screen Lock
# #    selenium_coam.set_parameter_value
# #    ...    abbr=acceptedClockClass
# #    ...    dist_name=${accpetclock_path}
# #    ...    filter_param=Accepted clock class list
# #    ...    new_value=${acceptclock}
# #    selenium_coam.validate_plan
# #    selenium_coam.activate_plan    activate_plan_despite_errors=True
# #    [Teardown]   Selenium Logout And Close Browser
# 
# Perform_SW_rollback_without_check_cell_status
#     [Arguments]  ${connection}=GNB_OAM
#     log to console    start rollback...
#     coam.rollback_software    connection=${connection}
# #    sleep    2min
# #    COAM Wait gnb And Cells ready    timeout=15min    gnb_type='${gNb_CuType}'
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
