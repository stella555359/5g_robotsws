*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/rf_diagnostic_test.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/gnb_ru.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_RU_lock_unlock.robot

*** Variables ***
@{stability_order_list}    6-1-2-7-3    5-4-6-3-2-7    3-1-6-2-4-5-7    7-5    5-1-3    2-5-1-4    3-2-4-5-7-1-6
    ...    4-5-1-3-7-2    4-1-2-7-3    3-1-4-5-7-6-2    1-2-3-4-5-6-7    7-6-5-4-3-2-1

*** Keywords ***
General_SiSo_RF_Module_Stability_test
    [Documentation]
    ...    *****************
    ...    Owner_zhihao.shi@nokia-sbell.com
    ...    [TEST PURPOSE] Stability testing for RU families in regression.
    ...    ******************
    [Arguments]  ${call_keyword}=L3 call and TP check  ${temperature}=${90}  ${max_temp}=80  ${rf_port}=0  ${times}=${20}
    add fault to the history allowed fault list    faultId=${49}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Create file in RU
    FOR    ${time}    IN RANGE    1    ${times}+1
           Log to console    \n---------------------\nstability run: ${time}/${times}
           ${random_str}    Evaluate    random.choice(@{stability_order_list})    modules=random
           log to console    \n run order:${random_str}
           @{split_order}    string.split string    ${random_str}    separator=-
           Stability_test_order    order_list=@{split_order}    stream=${stream}  call_keyword=${call_keyword}  temperature=${temperature}
			...  max_temp=${max_temp}  rf_port=${rf_port}									  
    END
    [Teardown]  selenium logout and close browser

Stability_test_order
    [Arguments]   ${order_list}    ${call_keyword}=L3 call and TP check  ${temperature}=${90}  ${max_temp}=80  ${rf_port}=0  ${stream}=SBTS00
    FOR  ${order}  IN  @{order_list}
           run keyword if    '${order}'=='1'    ${call_keyword}
           run keyword if    '${order}'=='2'    save snapshot
           run keyword if    '${order}'=='3'    cell block and unblock in webEM
           run keyword if    '${order}'=='4'    enable 956 and check in webEM
		   ...  RF_temperature_high_threshold=${temperature}  max_temperature=${max_temp}  rf_port_id=${rf_port}																									
           run keyword if    '${order}'=='5'    ru lock and unlock in webEM
           run keyword if    '${order}'=='6'    Sleep 1 hour
           run keyword if    '${order}'=='7'    calibration check
    END

L3 call and TP check
    log to console    \n========== Order 1 : L3 call and TP check ==========
    ${cell_list}  create list  ${1}
    Get UE From Init File and Make call    cell_list=${cell_list}  duration=${120}
    check testline and alarm status

save snapshot
    log to console    \n========== Order 2 : save snapshot ==========
    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}
    check testline and alarm status

cell block and unblock in webEM
    [Arguments]  ${technology}=NR
    log to console    \n========== Order 3 : cell block and unblock ==========
    ${cell_list}  Get All Cell Id    cell_type=${technology.lower()}
    FOR  ${cell_index}  IN  @{cell_list}
        selenium_coam.block_cell    cell_idx=${cell_index}    technology=${technology}
        Wait Until Keyword Succeeds   3 min  10 sec   check single cell should be blocked   cell_idx=${cell_index}   cell_type=${technology.lower()}
    END
    Wait For Expect Fault Present    faultId=49    timeout=30
    FOR  ${cell_index}  IN  @{cell_list}
        selenium_coam.unblock_cell    cell_idx=${cell_index}    technology=${technology}
        Wait Until Keyword Succeeds   5 min  10 sec   check single cell should be unblocked   cell_idx=${cell_index}   cell_type=${technology.lower()}
    END
    Wait For Expect Fault To Disappear  faultId=49    timeout=60
    check testline and alarm status

enable 956 and check in webEM
    log to console    \n========== Order 4 : enable 956 and check in webEM ==========
    [Arguments]  ${radio_id}=${1}    ${RF_temperature_high_threshold}=${90}    ${outcome}=Pass
    ...          ${min_temperature}=40    ${max_temperature}=80    ${rf_port_id}=0    ${stream}=SBTS00
    Delete RFTHLD If Exist
    Run Keyword If   '${stream}'=='SBTS23R1' or '${stream}'=='SBTS23R2'    Modify actRemoteRfDiag Parameter
    Set default value for RFTHLD If Feature 956 Enabled
    ${bts_thresholds}    create dictionary    RF temperature high threshold=${RF_temperature_high_threshold}
    RF statistics diagnostic test setup    bts_thresholds=${bts_thresholds}    radio_id=${radio_id}
    sleep  30
    Check Statistics General Information    radio_id=${radio_id}    outcome=${outcome}
    Check RF Temperature Supervision    radio_id=${radio_id}    min_temperature=${min_temperature}    max_temperature=${max_temperature}
    Check RF Ethernet Packet Monitoring    radio_id=${radio_id}    rf_port_id=${rf_port_id}
    check testline and alarm status

ru lock and unlock in webEM
    log to console    \n========== Order 5 : ru lock and unlock ==========
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.lock_ru    ru_index=${ru_index}
        sleep  15
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${ru_index}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be Disabled    cell_list=${cell_id_ru}
    END
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${status}    run keyword and return status  Expect Fault Should Present    faultId=4687
        selenium_coam.unlock_ru    ru_index=${ru_index}
        sleep  15
        Run Keyword If  ${status}==${True}    wait until keyword succeeds    10min    20sec    RU Should Be Offline    ru_index=${ru_index}
        wait until keyword succeeds    10min    20sec    RU Should Be Online    ru_index=${ru_index}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        sort list    ${cell_id_ru}
        wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be enabled    cell_list=${cell_id_ru}
    END
    check testline and alarm status

Sleep 1 hour
    log to console    \n========== Order 6 : Sleep 1 hour ==========
    sleep    3600
    check testline and alarm status

calibration check
    [Arguments]  ${check_time}=15
    log to console    \n========== Order 7 : calibration check ==========
    log to console    sleep ${check_time}min to get beamforming calibration
    sleep  ${check_time}min
    ${bf_status}    Run Keyword And Return Status    Check RU Beamforming Status    check_count=${True}
    ...    check_ru_connect=${True}
    should be true  ${bf_status}
    check testline and alarm status

check testline and alarm status
    log to console    \ncheck testline and alarm status
    Check file Exist in RU
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
    should be true  ${ru_status}
    ${cell_status}    Run Keyword And Return Status    Check all cells info should be onair
    should be true  ${cell_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true  ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
