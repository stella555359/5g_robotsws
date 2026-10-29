*** Settings ***
Variables    ../TestData/variables_9223.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot

Documentation
...    author: Jiangjing Lin
...    contact: jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
@{cell_id_call}    ${2}
*** Keywords ***
BTS_setup_Commissioned_with_Cell_Setup_via_WebEM_config6
    log to console    scf commission
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _9223.xml
    coam.perform_commissioning     scf_file=${SCF_upload}    skip_parameter_relation_errors=True    timeout=900    connection=GNB_OAM
    log to console    check cell status. operational status should be Enabled, and Administrative status should be unlocked
    Wait Until Keyword Succeeds    20 min    10 sec    Verify all cells should be onair

L3_call_Single_UE_PEAK_rate_with_L3_call_config_SA
#    log to console    scf commission
#    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _9223.xml
    Connect to gnb coam via ssl
    coam.reset_site    connection=GNB_OAM
    sleep    120s
    Wait until keyword succeeds    10min    10s    verify all cells should be onair
    Selenium Login And Disable Screen Lock
#    coam.perform_commissioning     scf_file=${SCF_upload}    skip_parameter_relation_errors=True    timeout=900    #connection=GNB_OAM
#    log to console    check cell status. operational status should be Enabled, and Administrative status should be unlocked
#    Wait Until Keyword Succeeds    20 min    10 sec    Verify all cells should be onair
#    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
#    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    log to console    check ru status. Operational state should be enabled
    ${ru_index_list}  Get All RU Index
    ${ru_num}   Get Length   ${ru_index_list}
    FOR    ${index}    IN RANGE    1    ${ru_num}+1
        ${ru_info}    selenium_coam.Get Ru Info    ru_index=${index}
         ${operationalState}    set variable    ${ru_info['Status']['Operational state']}
         should be equal    ${operationalState}    enabled
    END
    sleep    600s
    log to console   make call on cell2 that under RU2
    log to console    reoot ue0
    reboot_ue_except_askey_and_cpe
    data_transfer_common    tput_self_define=${tput}    cell_id=${cell_id_call}    tput_from=self_define
    [Teardown]    run keywords    selenium logout and close browser    AND    run keyword and ignore error    COAM Teardown gnb connections

CB009223 Recovery_and_reset_RAT_Reset_from_WebEM_config6
    Selenium Login And Disable Screen Lock
    log to console    DO RAT rest from webem and check cell status. operational status should be Enabled, Administrative status should be unlocked
    NR RAT Reset
    log to console    check ru status. Operational state should be enabled
    ${ru_index_list}  Get All RU Index
    ${ru_num}   Get Length   ${ru_index_list}
    FOR    ${index}    IN RANGE    1    ${ru_num}+1
        ${ru_info}    selenium_coam.Get Ru Info    ru_index=${index}
         ${operationalState}    set variable    ${ru_info['Status']['Operational state']}
         should be equal    ${operationalState}    enabled
    END
    log to console    make call on cell2 that under RU2
    data_transfer_common    tput_self_define=${tput}    cell_id=${cell_id_call}  target_avg_percent=0.5  min_percent=0.25
    [Teardown]    Run keywords    Selenium Logout And Close Browser    AND    reset site and check onair

CB009223 operation_RF_lock_or_unlock_config6
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
    log to console    make call on cell2 that under RU2
    data_transfer_common    tput_self_define=${tput}    cell_id=${cell_id_call}  target_avg_percent=0.5  min_percent=0.25
    [Teardown]    Selenium Logout And Close Browser

CB009223 Operation_cell_lock_or_unlock_config6
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
    log to console    make call on cell2 that under RU2
    data_transfer_common    tput_self_define=${tput}    cell_id=${cell_id_call}  target_avg_percent=0.5  min_percent=0.25
    [Teardown]    Selenium Logout And Close Browser

reset site and check onair
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl
    coam.reset_site    connection=GNB_OAM
    sleep    120s
    Wait Until Keyword Succeeds    20 min    10 sec    Verify all cells should be onair
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections
