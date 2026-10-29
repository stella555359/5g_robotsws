*** Settings ***
Documentation
...              tingting.zhong@nokia-sbell.com

Library          taf.selenium.sbts   WITH NAME    selenium_coam
Library          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/kpi_calculate.py
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource         ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource         ./sleepingcell_keywords.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***

*** Keywords ***
Separately_CELL_RU_BTS reset_then L3call
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    run keywords    SISO Coam Test Setup    AND    Detach All Ues in Init
    Selenium Login And Disable Screen Lock
    RMOD reset via WEBUI and L3 Call
    Close Start Up View    timeout=60
    RMOD Power Reset and L3 Call
    Close Start Up View    timeout=60
    BBMOD reset via WEBUI and L3 Call
    Close Start Up View    timeout=60
    SITE reset via WEBUI and L3 Call
    Close Start Up View    timeout=60
    [Teardown]  run keywords    selenium logout and close browser    AND    SISO Coam Test Teardown    is_case_teardown=${False}

Separately_CELL_RU_BTS lock_unlock via NetAct_then L3call
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    run keywords    SISO Coam Test Setup    AND    Detach All Ues in Init
    Selenium Login And Disable Screen Lock
    All cells lock action from BTS WEBUI and L3 Call
    All rus lock action from BTS WEBUI and L3 Call
    BTS lock action from BTS WEBUI and L3 Call
    [Teardown]  run keywords    selenium logout and close browser    AND    SISO Coam Test Teardown    is_case_teardown=${False}

Separately sw download and activation gNB via NetAct_then L3call
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
	[Arguments]  ${active_package}    ${passive_package}    ${active_package_path}    ${passive_package_path}  ${any_value}=${800}
    run keywords    SISO Coam Test Setup    AND    Detach All Ues in Init
	rollback or upgrade and L3 Call    package=${passive_package}    package_path=${passive_package_path}    any_value=${any_value}
    rollback or upgrade and L3 Call    package=${active_package}    package_path=${active_package_path}     any_value=${any_value}
    [Teardown]   SISO Coam Test Teardown    is_case_teardown=${False}

Separately_hold_long_time_UE_L3call
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]    ${total_time}    ${connection}=GNB_OAM    ${rach_successful_rate}=100    ${act_rach_stp_sr}=100
    run keywords    SISO Coam Test Setup    AND    Detach All Ues in Init
    coam.reset_site    connection=${connection}
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    ${check_cell}    Get Ues Attached Cell    ue_num_each_call=2
    ${check_cell_list}    create list    ${check_cell}
    ${cell_and_peak_info}    ${ue_index_list}    Generate new Peak Dict    cell_list=${check_cell_list}    ue_num_each_call=2
    ...    duration=${total_time}
    ${first_ue_list}    create list    ${ue_index_list[0]}
    ${second_ue_list}    create list    ${ue_index_list[1]}
    ${ue_and_cell}    Ue Attach and Start DL UL Traffic    ue_index_list=${first_ue_list}    cell_and_peak_info=${cell_and_peak_info}
    Set To Dictionary    ${cell_and_peak_info['${check_cell}']}    duration    ${15}
    UE Verify Peak Throughput    ue_index_list=${first_ue_list}    ue_and_cell=${ue_and_cell}
    ...    cell_and_peak_info=${cell_and_peak_info}
    ${ue_index}    set variable    ${second_ue_list[0]}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${execute_time}    set variable    ${0}
    ${start_time}    get time
    FOR    ${time}    IN RANGE    ${100}
        Log to console    \n---------------------\nexecute time: ${execute_time}s/${total_time}s
        ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
        sleep  5
        run keyword and ignore error    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
        log to console    verify ue_${first_ue_list[0]} tput
        ${status}    run keyword and return status    UE Verify Peak Throughput    ue_index_list=${first_ue_list}    ue_and_cell=${ue_and_cell}
        ...    cell_and_peak_info=${cell_and_peak_info}
        run keyword if    not ${status}    run keywords
        ...    Ue Stop DL UL Traffic and Detach    ue_index_list=${first_ue_list}    AND
        ...    Ue Attach and Start DL UL Traffic    ue_index_list=${first_ue_list}    cell_and_peak_info=${cell_and_peak_info}    AND
        ...    UE Verify Peak Throughput    ue_index_list=${first_ue_list}    ue_and_cell=${ue_and_cell}
        ...    cell_and_peak_info=${cell_and_peak_info}
        ${get_time}    get time
        ${diff_time}    robot.libraries.DateTime.subtract date from date    ${get_time}    ${start_time}
        ${execute_time}    convert to integer    ${diff_time}
        exit for loop if    ${execute_time}>${total_time}
    END
    ${cell_list}    Get All Cell Id
    ${all_cell_flag}    set variable    ${True}
    FOR    ${cell}    IN    @{cell_list}
        ${pass_radio}     ${numerator}    ${denominator}    rach_setup_success_ratio    cell_id=${cell}    connection=${connection}
        ${pass_radio}    convert to number    ${pass_radio}
        log to console    \nCELL_${cell}_NR_5013A: ${numerator}/${denominator}=${pass_radio}%
        ${pass_radio_2}     ${numerator}    ${denominator}    rach_setup_success_ratio_2    cell_id=${cell}    connection=${connection}
        ${pass_radio_2}    convert to number    ${pass_radio_2}
        log to console    \nCELL_${cell}_NR_5022A: ${numerator}/${denominator}=${pass_radio_2}%
        ${status}    run keyword if    '${cell}'=='${check_cell}'
        ...    run keyword and return status    should be true    ${pass_radio}>=${rach_successful_rate} and ${pass_radio_2}>=${act_rach_stp_sr}
        ...    ELSE    run keyword and return status    should be true    ${pass_radio}==${0} and ${pass_radio_2}==${0}
        ${all_cell_flag}    set variable if    ${status}    ${all_cell_flag}    ${False}
    END
    should be true    ${all_cell_flag}
    [Teardown]  run keywords    Ue Stop DL UL Traffic and Detach    ue_index_list=${first_ue_list}   AND
    ...    SISO Coam Test Teardown    is_case_teardown=${False}

Separately_CELL_block_unblock_then_L3call
    [Arguments]  ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}
    [Documentation]  Owner_shengrong.rao@nokia-sbell.com
    run keywords    SISO Coam Test Setup    AND    Detach All Ues in Init
    Selenium Login And Disable Screen Lock
    ${cell_list}    Get All Cell Id
    Get X2 link shutdown waiting time
    ${statu}    run keyword and return status    Block and UnBlock Cells    block_list=${cell_list}
    run keyword if    not ${statu}    Run Keyword And Ignore Error    UnBlock Cells and check status    block_list=${cell_list}
    run keyword and continue on failure    should be true    ${statu}
    ${ru_index_list}     Get All RU Index    connection=${connection}
    Make L3 Call With RU List    ru_index_list=${ru_index_list}
    [Teardown]  run keywords    selenium logout and close browser    AND    SISO Coam Test Teardown    is_case_teardown=${False}

Separately_site_block_unblock_then_L3call
    [Arguments]  ${connection}=GNB_OAM      ${timeout}=120s
    [Documentation]  Owner_shanshan.zhang@nokia-sbell.com
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}
    BTS Block action from BTS WEBUI and L3 Call     connection=${connection}
    ${ru_index_list}     Get All RU Index    connection=${connection}
    Make L3 Call With RU List    ru_index_list=${ru_index_list}
    [Teardown]   SISO Coam Test Teardown    is_case_teardown=${False}

Separately modify parameter and activation gNB_then L3call
    [Documentation]  Owner_shanshan.zhang@nokia-sbell.com
	[Arguments]    ${any_value}    ${connection}=GNB_OAM
    run keywords    SISO Coam Test Setup    AND    Detach All Ues in Init
	Connect to gnb coam via ssl    connection=${connection}
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    connection=${connection}
    Collect Snapshot    log_number=${10}
    Make L3 Call With RU List    ru_index_list=${ru_new_list}
    Change physCellId parameter value    physCellId_value=${any_value}    globalCellId=${modify_cell_id}
    Make L3 Call With RU List    ru_index_list=${ru_new_list}
    Kill Snapshot Process
    check snapshot is not empty
    [Teardown]   run keywords     Kill Snapshot Process      AND
    ...    Change physCellId parameter value    physCellId_value=${modify_physicalCellId}    globalCellId=${modify_cell_id}    AND
    ...    SISO Coam Test Teardown    is_case_teardown=${False}

Separately RAT Block and Unblock then L3call
    [Documentation]  Owner_shanshan.zhang@nokia-sbell.com
    ${dl_nrcell_id}    Get cell nrCellIdentity list    cell_group_id=${0}
    ${ul_nrcell_id}    create list    ${dl_nrcell_id}[0]   ${dl_nrcell_id}[1]
    RAT Block and UnBlock then L3 Call     rat=LTE     dl_nrcell_id=${dl_nrcell_id}    ul_nrcell_id=${ul_nrcell_id}
    RAT Block and UnBlock then L3 Call     rat=NR      dl_nrcell_id=${dl_nrcell_id}    ul_nrcell_id=${ul_nrcell_id}
    RAT Reset then L3 Call     rat_type=LTE    dl_nrcell_id=${dl_nrcell_id}    ul_nrcell_id=${ul_nrcell_id}
    RAT Reset then L3 Call     rat_type=NR    dl_nrcell_id=${dl_nrcell_id}    ul_nrcell_id=${ul_nrcell_id}
    [Teardown]    run keyword and ignore error    Detach power ue

Separately Filber break then L3call
    [Documentation]  Owner_shanshan.zhang@nokia-sbell.com
	[Arguments]      ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}    ${S_RF1}=3   ${S_RF2}=4
    run keywords    SISO Coam Test Setup    AND    Detach All Ues in Init
	Connect to gnb coam via ssl    connection=${connection}
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    connection=${connection}
    ${before_active_fault_list}    Get Alarm Fault Id List   alarm_type=active    connection=${connection}
    ${before_history_fault_list}    Get Alarm Fault Id List   alarm_type=history    connection=${connection}
    Connect to SMOD with ssh From main board to auxiliary board
    ${sfpd}    Get SFPD ID
    ${original_Transceiver1}    Get TransceiverTXBiasCurrent value    sfpd=${sfpd}   S_RF=${S_RF1}
    ${original_Transceiver2}    Get TransceiverTXBiasCurrent value    sfpd=${sfpd}   S_RF=${S_RF2}
    should be true    ${original_Transceiver1}>0
    should be true    ${original_Transceiver2}>0
    Change two optical transmission by command    sfpd=${sfpd}    switch=1
    Wait until keyword succeeds    5min   20s     Check fault id should be appear    connection=${connection}    check_fault_id=${10}
    Change two optical transmission by command    sfpd=${sfpd}    switch=0
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    connection=${connection}
    Wait Until Keyword Succeeds    2min    10s    Run Keyword And Expect Error   *
    ...    Check fault id should be appear    connection=${connection}    check_fault_id=${10}
    Check status after Filber break
    ...    before_active_fault_list=${before_active_fault_list}    before_history_fault_list=${before_history_fault_list}
    ...    gnb_type=${gnb_type}    connection=${connection}
    Make L3 Call With RU List    ru_index_list=${ru_list}
    [Teardown]  run keywords    Run Keyword And Ignore Error    Disconnect SMOD with ssh    AND
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
