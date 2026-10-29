*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library       taf.selenium.sbts    WITH NAME    selenium_coam
Library       testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.scf.scf_analysis.ScfAnalysis    WITH NAME    scfas
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/coam_check_status.robot


*** Keywords ***
Enable Test Dedicated State
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM
    log to console    \nenable test dedicated state
    Close Start Up View    timeout=60
    selenium_coam.enable_test_dedicated_state
    sleep    1min
    Wait Until Keyword Succeeds    3min    5s    Connect to gnb coam via ssl    connection=${connection}
    Wait until keyword succeeds    8 min    20 sec    All RU Should be Online
    Wait Until Keyword Succeeds    5min    30s    All CEll Should be Desable
    Wait Until Keyword Succeeds    5min    30s    Bts Should be Test

All RU Should be Online
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM
    ${ru_index_list}    get all ru index    connection=${connection}
    FOR    ${ru_index}    IN    @{ru_index_list}
        RU Should Be Online    ru_index=${ru_index}
    END

All CEll Should be Desable
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM
    ${cell_list}    get all cell id    connection=${connection}
    FOR    ${cell_id}    IN    @{cell_list}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_id}    connection=${connection}
        cell should be disabled   cell_idx=${cell_id}   cell_group_idx=${cellgrp_id}    connection=${connection}
    END

Bts Should be Test
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM
    ${bts_status}    coam.get_bts_statuses    connection=${connection}
    ${proceduralState}    get from dictionary    ${bts_status}    proceduralState
    should be equal as strings    ${proceduralState}    Test

Start Downlink Test Model
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${test_model}=NR-FR1-TM1.1    ${cell_id}=all    ${scf_dir_path}=${SAVE LOG DIRECTORY}    ${connection}=GNB_OAM
    ...  ${itime}=${0}
    log to console    \nStart Downlink Test Model ${test_model}
    ${stream}    get stream from version    ${Active_SW_version}
    ${scf_file_path}    COAM Download scf from cluster    scf_dir_path=${scf_dir_path}    connection=${connection}
    scfas.setup    scf_path=${scf_file_path}
    # Determine which function to use based on version
    ${use_new_api}    Run Keyword And Return Status
    ...    Should Match Regexp    ${Active_SW_version}    ^SBTS00|SBTS2[6-9]R[2-9]|SBTS3[0-9]R[0-9]

    ${cell_list}    run keyword if    '${cell_id}'=='all'    get all cell id    connection=${connection}
    ...    ELSE    create list    ${cell_id}
    FOR    ${cell_id}    IN    @{cell_list}
        ${nrarfcn}    scfas.get_nrarfcn_from_scf    cell_id=${cell_id}
        # ${power_backoff}    scfas.get_dlQam256PowerBackoffSub6_from_scf    cell_id=${cell_id}
        # Since SBTS26R2, dlQam256PowerBackoffSub6 parameter is replaced to dlQam256PowerBackoff
        # https://jiradc.ext.net.nokia.com/browse/WESTLAKE-12961
        ${power_backoff}    Run Keyword If    ${use_new_api}
        ...    scfas.get_dlQam256PowerBackoff_from_scf    cell_id=${cell_id}
        ...    ELSE
        ...    scfas.get_dlQam256PowerBackoffSub6_from_scf    cell_id=${cell_id}
        ${pmax}    scfas.get_pMax_from_scf    cell_id=${cell_id}
        ${pmax}    evaluate    int(${pmax})/10
        ${physical_cell_id}    scfas.get_physCellId_from_scf    cell_id=${cell_id}
        Close Start Up View    timeout=60
        ${local_cell}    Get NR Local Cell Name    cell_id=${cell_id}
        selenium_coam.start_5g_downlink_test    local_cell=${local_cell}
        ...                                     nrarfcn=${nrarfcn}
        ...                                     test_model=${test_model}
        ...                                     power_backoff=${power_backoff}
        ...                                     beam_id=1
        ...                                     polarization=P_both
        ...                                     p_max=${pmax}
        ...                                     physical_cell_id=${physical_cell_id}
        ...                                     timeout=120
        ${index}    get index from list    ${cell_list}    ${cell_id}
        ${cell_num}   Get Length  ${cell_list}
        ${test_id}=   Evaluate   ${index+1}+${cell_num}*${itime}
        selenium_coam.wait_for_5g_downlink_test_to_start    test_id=${test_id}    timeout=300
    END

Stop Downlink Test Model
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}=all    ${connection}=GNB_OAM   ${itime}=${0}
    log to console    \nStop Downlink Test Model
    ${cell_list}    run keyword if    '${cell_id}'=='all'    get all cell id    connection=${connection}
    ...    ELSE    create list    ${cell_id}
    FOR    ${cell_id}    IN    @{cell_list}
        Close Start Up View    timeout=60
        ${index}    get index from list    ${cell_list}    ${cell_id}
        ${cell_num}   Get Length  ${cell_list}
        ${test_id}=   Evaluate   ${index+1}+${cell_num}*${itime}
        selenium_coam.stop_5g_downlink_test    test_id=${test_id}
        selenium_coam.wait_for_5g_downlink_test_to_stop    test_id=${test_id}   timeout=300
    END

Test Downlink Test Model
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${test_model_list}    ${cell_id}=all
    FOR    ${test_model}    IN    @{test_model_list}
        Start Downlink Test Model    test_model=${test_model}    cell_id=${cell_id}
        sleep    2min
        Stop Downlink Test Model
        selenium_coam.refresh_page
    END

Start Uplink Test Model
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${frc_index}=G-FR1-A1-2    ${cell_id}=all    ${scf_dir_path}=${SAVE LOG DIRECTORY}    ${connection}=GNB_OAM
    log to console    \nStart Uplink Test Model
    ${stream}    get stream from version    ${Active_SW_version}
    ${scf_file_path}    COAM Download scf from cluster    scf_dir_path=${scf_dir_path}    connection=${connection}
    scfas.setup    scf_path=${scf_file_path}
    ${cell_list}    run keyword if    '${cell_id}'=='all'    get all cell id    connection=${connection}
    ...    ELSE    create list    ${cell_id}
    FOR    ${cell_id}    IN    @{cell_list}
        ${nrarfcn}    scfas.get_nrarfcn_from_scf    cell_id=${cell_id}
        ${power_backoff}    scfas.get_dlQam256PowerBackoffSub6_from_scf    cell_id=${cell_id}
        ${pmax}    scfas.get_pMax_from_scf    cell_id=${cell_id}
        ${pmax}    evaluate    int(${pmax})/10
        ${physical_cell_id}    scfas.get_physCellId_from_scf    cell_id=${cell_id}
        Close Start Up View    timeout=60
        ${local_cell}    Get NR Local Cell Name    cell_id=${cell_id}
        selenium_coam.start_5g_uplink_test    local_cell=${local_cell}
        ...                                   nrarfcn=${nrarfcn}
        ...                                   frc_index=${frc_index}
        ...                                   reporting_time_interval=1
        ...                                   beam_id=1
        ...                                   physical_cell_id=${physical_cell_id}
        ...                                   timeout=120
        ${index}    get index from list    ${cell_list}    ${cell_id}
        selenium_coam.wait_for_5g_uplink_test_to_start    test_id=${index+1}    timeout=180
    END

Stop uplink Test Model
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}=all    ${connection}=GNB_OAM
    log to console    \nStop Downlink Test Model
    ${cell_list}    run keyword if    '${cell_id}'=='all'    get all cell id    connection=${connection}
    ...    ELSE    create list    ${cell_id}
    FOR    ${cell_id}    IN    @{cell_list}
        Close Start Up View    timeout=60
        ${index}    get index from list    ${cell_list}    ${cell_id}
        selenium_coam.stop_5g_uplink_test    test_id=${index+1}
        selenium_coam.wait_for_5g_uplink_test_to_stop    test_id=${index+1}    timeout=180
    END

Test Uplink Test Model
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${frc_index_list}    ${cell_id}=all
    FOR    ${frc_index}    IN    @{frc_index_list}
        Start Uplink Test Model    frc_index=${frc_index}    cell_id=${cell_id}
        sleep    2min
        Stop uplink Test Model
        selenium_coam.refresh_page
    END

Disable Test Dedicated State
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    log to console    \ndisable test dedicated state
    Close Start Up View    timeout=60
    run keyword and ignore error   selenium_coam.disable_test_dedicated_state
    sleep    3s
    Wait Until Keyword Succeeds    3min    5s    Connect to gnb coam via ssl
    Check All Components Status    operation_component=site    gnb_type=${gNb_CuType}

Get NR Local Cell Name
    [Arguments]  ${cell_id}=1
    ${cell_name}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    ...    filter_param=Cell name
    ${name_len}    get length    ${cell_name}
    ${local_name}    set variable if    ${name_len}==${0}    NRCELL-${cell_id}    NRCELL-${cell_id} (${cell_name})
    [Return]  ${local_name}

Test Downlink Test Model Loop All TM
    [Documentation]  Owner_kaihui.fan@nokia-sbell.com
    [Arguments]  ${test_model_list}    ${cell_id}=all
    FOR    ${test_model}    IN    @{test_model_list}
        Test Downlink Test Model Loop Per TM   test_model=${test_model}    cell_id=${cell_id}
        selenium_coam.refresh_page
    END

Test Downlink Test Model Loop Per TM
    [Documentation]  Owner_kaihui.fan@nokia-sbell.com
    [Arguments]  ${test_model}    ${cell_id}=all   ${times}=${5}
    FOR    ${itime}    IN RANGE    0    ${times}
        Start Downlink Test Model    test_model=${test_model}    cell_id=${cell_id}   itime=${itime}
        sleep    2min
        Stop Downlink Test Model    cell_id=${cell_id}   itime=${itime}
    END