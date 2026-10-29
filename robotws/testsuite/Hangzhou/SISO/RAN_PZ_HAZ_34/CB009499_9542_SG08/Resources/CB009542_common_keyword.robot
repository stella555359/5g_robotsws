*** Settings ***
Variables    ../TestData/variables_9542.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot

Documentation
...    author: hongli.xu
...    contact:  hongli.xu@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
@{cell_id_call}    ${3}
*** Keywords ***

General_SiSo_E2E_system_setup_with_data_transfer
    log to console    scf commission
    Selenium Login And Disable Screen Lock
    #coam.perform_commissioning     scf_file=${Golden_SCF_Path}    skip_parameter_relation_errors=True    timeout=900    connection=GNB_OAM
    log to console    check cell status. operational status should be Enabled, and Administrative status should be unlocked
    Wait Until Keyword Succeeds    20 min    10 sec    Verify all cells should be onair
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    log to console    check ru status. Operational state should be enabled
    ${ru_index_list}  Get All RU Index
    ${ru_num}   Get Length   ${ru_index_list}
    FOR    ${index}    IN RANGE    1    ${ru_num}+1
        ${ru_info}    selenium_coam.Get Ru Info    ru_index=${index}
         ${operationalState}    set variable    ${ru_info['Status']['Operational state']}
         should be equal    ${operationalState}    enabled
    END
    log to console   make call on cell1 that under RU1
    data_transfer_common    tput_self_define=${tput}    cell_id=${cell_id_call}    process_num_ul=3
    [Teardown]    Selenium Logout And Close Browser

Manual_SiSo_SM_BTS_Site_Reset
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl
    coam.reset_site    connection=GNB_OAM
    sleep    120s
    Wait Until Keyword Succeeds    20 min    10 sec    Verify all cells should be onair
    log to console   make call on cell1 that under RU1
    data_transfer_common    tput_self_define=${tput}    cell_id=${cell_id_call}    process_num_ul=3  target_avg_percent=0.5  min_percent=0.25    
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

General_SiSo_Auto_RF_lock_unlock_with_L3call
    Selenium Login And Disable Screen Lock
    ${ru_index_list}  Get All RU Index
    ${ru_num}   Get Length   ${ru_index_list}
    log to console    lock ru one by one
    FOR    ${index}    IN RANGE    1    ${ru_num}+1
        selenium_coam.lock_ru    ru_index=${index}
    END
    log to console    unlock ru one by one
    FOR    ${index}    IN RANGE    1    ${ru_num}+1
        selenium_coam.unlock_ru    ru_index=${index}
    END
    log to console    check cell status. operational status should be Enabled, and Administrative status should be unlocked
    Wait Until Keyword Succeeds    20 min    10 sec    Verify all cells should be onair
    log to console    check ru status. Operational state should be enabled
    FOR    ${index}    IN RANGE    1    ${ru_num}+1
        ${ru_info}    selenium_coam.Get Ru Info    ru_index=${index}
         ${operationalState}    set variable    ${ru_info['Status']['Operational state']}
         should be equal    ${operationalState}    enabled
    END
    log to console    make call on cell1 that under RU1
    data_transfer_common    tput_self_define=${tput}    cell_id=${cell_id_call}    process_num_ul=3  target_avg_percent=0.5  min_percent=0.25
    [Teardown]    Selenium Logout And Close Browser

General_SiSo_Auto_Cell_lock_and_unlock
    ${cells_info}    coam.get_cells_info    connection=GNB_OAM
    ${cell_num}   Get Length   ${cells_info}
    Selenium Login And Disable Screen Lock
    log to console    lock cell one by one
    FOR    ${index}    IN RANGE    1    ${cell_num}+1
        selenium_coam.block_cell    cell_idx=${index}
    END
    log to console    unlock cell one by one
    FOR    ${index}    IN RANGE    1    ${cell_num}+1
        selenium_coam.unblock_cell    cell_idx=${index}
    END
    log to console    check cell status. operational status should be Enabled, and Administrative status should be unlocked
    Wait Until Keyword Succeeds    20 min    10 sec    Verify all cells should be onair
    log to console    check ru status. Operational state should be enabled
    ${ru_index_list}  Get All RU Index
    ${ru_num}   Get Length   ${ru_index_list}
    FOR    ${index}    IN RANGE    1    ${ru_num}+1
        ${ru_info}    selenium_coam.Get Ru Info    ru_index=${index}
         ${operationalState}    set variable    ${ru_info['Status']['Operational state']}
         should be equal    ${operationalState}    enabled
    END
    log to console    make call on cell1 that under RU1
    data_transfer_common    tput_self_define=${tput}    cell_id=${cell_id_call}    process_num_ul=3  target_avg_percent=0.5  min_percent=0.25
    [Teardown]    Selenium Logout And Close Browser
