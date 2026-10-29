*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Variables    ../TestData/CB009499_variables.py



Documentation    This is for SG8 common keywords
...              Author: renzhenzhen
...              Squard: HZ SG8

*** Variables ***
@{cell1_H}    ${1}

*** Keywords ***
Commissioning scf for requirment
    [Arguments]    ${scf_name}=configuration
    log to console    import scf of ${scf_name}
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _${scf_name}.xml
    COAM Commission with scf file    scf_file_path=${SCF_upload}
    Wait until keyword succeeds    15min    120s    verify all cells should be onair


L3 call peak for CB009499_H supercell
    data_transfer_common    tput_self_define=${tput_define_H}    loop_times=${1}    duration=${600}
    ...    cell_id=${cell1_H}   target_avg_percent=0.98    min_percent=0.85    


General_SiSo_Cell_block_and_unblock_for_CB009499_H
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${cell_list_nr}    Get All Cell Id    cell_type=nr
    run keyword and continue on failure    Block cells and check status    block_list=${cell_list_nr}
    ...    check_alarm=${False}    gnb_type=${gNb_CuType}
    UnBlock cells and check status    block_list=${cell_list_nr}    check_alarm=${False}    gnb_type=${gNb_CuType}
    L3 call peak for CB009499_H supercell
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser


Manual_SiSo_SM_BTS_Site_Reset_for_CB009499_H
    [Arguments]    ${loop_num}=${1}
        FOR    ${index}    IN RANGE    ${loop_num}
        log to console    reset bts for time:${index}
        Perform BTS Site Reset
        sleep    120s
        log to console    check bts status
        run keyword and ignore error    COAM Teardown gnb connections    
        Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
        Wait Until Keyword Succeeds    15 min    60 sec    Verify all cells should be onair
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
    END
    L3 call peak for CB009499_H supercell


General_SiSo_RU_lock_unlock_for_CB009499_H
    Selenium Login And Disable Screen Lock
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.lock_ru  ru_index=${ru_index}
        Sleep   10 sec
        log to console    check Administrative state for radio unit MO is set to Locked,Operational state remains as Enabled
        run keyword and continue on failure    RU Should Be Locked    ru_index=${ru_index}
        selenium_coam.unlock_ru  ru_index=${ru_index}
        Sleep   10 sec
        log to console    check Administrative state for radio unit MO is set to Unlocked
        RU Should Be Unlocked    ru_index=${ru_index}
        Wait Until Keyword Succeeds    5 min    60 sec    Verify all cells should be onair
    END
    L3 call peak for CB009499_H supercell
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser
