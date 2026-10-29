*** Settings ***
Documentation
...    Author: Shifu Lan
...    contact:shifu.lan@nokia-sbell.com
...    squad group:VRF_HAZ4_SG04

Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nr_feature_on.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py


*** Keywords ***
L3Call_setup_with_data_transfer_conducted_80M_50M_50M
    [Arguments]  ${with_call}=${True}  ${with_peak}=${False}  ${duration}=${60}  ${ue_num_each_call}=1
    Selenium Login And Disable Screen Lock
    ${cell_list}    get all cell id    ru_index=1
    Run Keyword If    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${duration}    ue_num_each_call=${ue_num_each_call}

    Modify Cells Rx Number Via Rest    cell_id=${cell_list}[0]
    Run Keyword If    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${duration}    ue_num_each_call=${ue_num_each_call}

    FOR    ${cell_id}    IN    @{cell_list}[1:3]
        Modify Cells Rx Number Via Rest    cell_id=${cell_id}
    END
    Run Keyword If    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${duration}    ue_num_each_call=${ue_num_each_call}

    Reset NR RAT In SA Mode
    Run Keyword If    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${duration}    ue_num_each_call=${ue_num_each_call}
    [Teardown]  Selenium Logout And Close Browser

Online_8Rx_Commission_with_L3Call_Regression
    [Arguments]  ${with_call}=${True}  ${with_peak}=${False}  ${duration}=${60}  ${ue_num_each_call}=1
    Selenium Login And Disable Screen Lock
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Should Be True    ${alarm_status}
    ${ru_index_list}    Get RU index list
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${cell_list}    get all cell id    ru_index=${ru_index}
        Run Keyword If    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
        ...    with_peak=${with_peak}    duration=${duration}    ue_num_each_call=${ue_num_each_call}

        FOR    ${cell_id}    IN    @{cell_list}
            Modify Cells Rx Number Via Rest    cell_id=${cell_id}
        END
        Run Keyword If    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
        ...    with_peak=${with_peak}    duration=${duration}    ue_num_each_call=${ue_num_each_call}
    END

    Log    \nPerforming BTS Site Reset    console=yes
    Perform BTS Site Reset
    # [WESTLAKE-10440] Added wait time for selenium operation taking effect
    Sleep   180 sec
    COAM Wait gnb And Cells ready    timeout=15min    gnb_type=${gNb_CuType}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Should Be True    ${alarm_status}
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${cell_list}    get all cell id    ru_index=${ru_index}
        Run Keyword If    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
        ...    with_peak=${with_peak}    duration=${duration}    ue_num_each_call=${ue_num_each_call}
    END
    [Teardown]  Selenium Logout And Close Browser

Modify Cells numberOfRxBeamforming Via Webem
    [Arguments]  ${cell_list}    ${rx_beamforming_number}=8Rx    ${rx_pucch_number}=8Rx
    Log     \n***Modify Cells ${cell_list} numberOfRxBeamforming from 4Rx to ${rx_beamforming_number}***    console=yes

    FOR    ${cell_id}    IN    @{cell_list}
        Remove Rx Channel In ChannelGroup    cell_id=${cell_id}
        ${copy_dist_name} =    Get Rx Channel In ChannelGroup For Copy    cell_id=${cell_id}
        Add Rx Channel In ChannelGroup    cell_id=${cell_id}    copy_dist_name=${copy_dist_name}

        ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=Number of Rx PUCCH
        ...    abbr=numberOfRxPucch    new_value=${rx_pucch_number}
        selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=Number of Rx beamforming
        ...    abbr=numberOfRxBeamforming    new_value=${rx_beamforming_number}
    END
    selenium_coam.validate_plan
    Run Keyword And Ignore Error    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=360
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair

Remove Rx Channel In ChannelGroup
    [Arguments]  ${cell_id}
    FOR    ${index}    IN RANGE    1    9
        ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-2/CHANNEL-${index}
        ${value} =    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=Direction of the channel
        Continue For Loop If    "${value}"!="RX"
        selenium_coam.remove_object    object_name=${dist_name}    timeout=15
    END

Get Rx Channel In ChannelGroup For Copy
    [Arguments]  ${cell_id}
    FOR    ${index}    IN RANGE    1    9
        ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-${index}
        ${copy_dist_name}    Set Variable    ${dist_name}
        ${value} =    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=Direction of the channel
        Exit For Loop If    "${value}"=="RX"
    END
    [Return]    ${copy_dist_name}

Add Rx Channel In ChannelGroup
    [Arguments]  ${cell_id}    ${copy_dist_name}
    FOR    ${index}    IN RANGE    1    5
        ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1
        selenium_coam.add_object    object_name=${dist_name}
        ...    object_class_name=CHANNEL    plan_to_copy_from=CURRENT_BTS_CONF-1
        ...    copy_from=${copy_dist_name}    timeout=15
    END

Reset NR RAT In SA Mode
    selenium_coam.reset_nr
    sleep    180s
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair

Modify Cells Rx Number Via Webem
    [Arguments]  ${cell_list}    ${rx_beamforming_number}=8Rx    ${rx_pucch_number}=8Rx    ${connection}=GNB_OAM
    Log     \n***Modify Cells ${cell_list} Rx Number from 4Rx to ${rx_beamforming_number}***    console=yes

    FOR    ${cell_id}    IN    @{cell_list}
        ${lcelnr_dist_name}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
        @{lcelnr_child_list}    coam.get_parameter_by_parent_distname    parent_dn=${lcelnr_dist_name}    connection=${connection}
        ${remove_dist_name_list}    ${copy_dist_name}    Get Rx Channel For Remove And Copy    lcelnr_child_list=${lcelnr_child_list}

        ${object_name}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1
        Remove And Add Rx Channels    object_name=${object_name}
        ...    remove_dist_name_list=${remove_dist_name_list}
        ...    copy_dist_name=${copy_dist_name}

        ${cell_dist_name}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        selenium_coam.set_parameter_value    dist_name=${cell_dist_name}    filter_param=Number of Rx PUCCH
        ...    abbr=numberOfRxPucch    new_value=${rx_pucch_number}
        selenium_coam.set_parameter_value    dist_name=${cell_dist_name}    filter_param=Number of Rx beamforming
        ...    abbr=numberOfRxBeamforming    new_value=${rx_beamforming_number}
    END
    selenium_coam.validate_plan
    Run Keyword And Ignore Error    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=360
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Should Be True    ${alarm_status}

Get Rx Channel For Remove And Copy
    [Arguments]    ${lcelnr_child_list}
    @{dist_name_list}    Create List
    FOR    ${element}    IN    @{lcelnr_child_list}
        ${parameters}=    Get From Dictionary    ${element}    parameters
        ${status}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${parameters}    direction

        Run Keyword If    ${status}
        ...    Run Keyword If    '${parameters}[direction]' == 'RX'
        ...    Append To List    ${dist_name_list}    ${element}[distName]
    END
    ${copy_dist_name}=    Get Rx Channel for Copy    ${dist_name_list}
    ${remove_dist_name_list}=    Get Rx Channel List for Remove    ${dist_name_list}
    [Return]    ${remove_dist_name_list}    ${copy_dist_name}

Get Rx Channel for Copy
    [Arguments]    ${dist_name_list}
    ${copy_dist_name}    Set Variable    ${EMPTY}
    FOR    ${element}    IN    @{dist_name_list}
        ${copy_dist_name}=    Set Variable    ${element}
        ${status}=    Run Keyword And Return Status    Should Contain    ${element}    CHANNELGROUP-1
        Exit For Loop If    ${status}
    END
    [Return]    ${copy_dist_name}

Get Rx Channel List for Remove
    [Arguments]    ${dist_name_list}
    @{remove_dist_name_list}    Create List
    FOR    ${element}    IN    @{dist_name_list}
        ${status}=    Run Keyword And Return Status    Should Not Contain    ${element}    CHANNELGROUP-1
        Run Keyword If    ${status}    Append To List    ${remove_dist_name_list}    ${element}
    END
    [Return]    ${remove_dist_name_list}

Remove And Add Rx Channels
    [Arguments]  ${object_name}    ${remove_dist_name_list}    ${copy_dist_name}
    FOR    ${remove_dist_name}    IN    @{remove_dist_name_list}
        selenium_coam.remove_object    object_name=${remove_dist_name}    timeout=15
        selenium_coam.add_object    object_name=${object_name}
        ...    object_class_name=CHANNEL    plan_to_copy_from=CURRENT_BTS_CONF-1
        ...    copy_from=${copy_dist_name}    timeout=15
    END

Modify Cells Rx Number Via Rest
    [Arguments]  ${cell_id}    ${rx_beamforming_number}=8Rx    ${rx_pucch_number}=8Rx    ${connection}=GNB_OAM
    Log     \n***Modify Cell ${cell_id} Rx Number from 4Rx to ${rx_beamforming_number}***    console=yes
    ${lcelnr_dist_name}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
    @{lcelnr_child_list}    coam.get_parameter_by_parent_distname    parent_dn=${lcelnr_dist_name}    connection=${connection}
    ${remove_dist_name_list}    ${resource_dn}    Get Rx Channels And resourceDN For Migration    lcelnr_child_list=${lcelnr_child_list}

    ${delta_id}    Set Variable    Online_8Rx_Commission_For_Cell_${cell_id}
    ${delta_json_path}    Set Variable    ${SAVE LOG DIRECTORY}/delta_${cell_id}.json
    coam.Create Delta    delta_id=${delta_id}
    FOR    ${remove_dist_name}    IN    @{remove_dist_name_list}
        coam.Append Managed Object To Delta    dist_name=${remove_dist_name}    operation=delete    delta_id=${delta_id}
        ${temp_dist_name}    Replace string    ${remove_dist_name}    CHANNELGROUP-2    CHANNELGROUP-1
        ${split_string_list}=    Split String    ${remove_dist_name}    /
        ${channel}=    Get From List    ${split_string_list}    -1
        ${new_channel_number}=    Evaluate    int('${channel}'.split('-')[-1]) + 4
        ${new_dist_name}    Replace string    ${temp_dist_name}    ${channel}    CHANNEL-${new_channel_number}
        coam.Append Managed Object To Delta    dist_name=${new_dist_name}    operation=create    delta_id=${delta_id}
        coam.Append Parameter Update To Delta    dist_name=${new_dist_name}    parameter=direction    value=RX    delta_id=${delta_id}
        coam.Append Parameter Update To Delta    dist_name=${new_dist_name}
        ...    parameter=resourceDN    value=${resource_dn}    delta_id=${delta_id}
    END

    ${cell_dist_name}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    coam.Append Parameter Update To Delta    dist_name=${cell_dist_name}
    ...    parameter=numberOfRxPucch    value=${rx_pucch_number}    delta_id=${delta_id}
    coam.Append Parameter Update To Delta    dist_name=${cell_dist_name}
    ...    parameter=numberOfRxBeamforming    value=${rx_beamforming_number}    delta_id=${delta_id}
    coam.Get Delta    delta_id=${delta_id}
    coam.Save Delta    target_file_name=${delta_json_path}    delta_id=${delta_id}
    coam.Perform delta recommissioning    delta_file=${delta_json_path}    skip_parameter_relation_errors=${True}    connection=${connection}
    coam.Remove Delta    delta_id=${delta_id}
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Should Be True    ${alarm_status}

Get Rx Channels And resourceDN For Migration
    [Arguments]    ${lcelnr_child_list}
    ${resource_dn}    Set Variable    None
    @{dist_name_list}    Create List
    ${resource_dn_flag}    Set Variable    ${False}
    FOR    ${element}    IN    @{lcelnr_child_list}
        ${parameters}=    Get From Dictionary    ${element}    parameters
        ${status}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${parameters}    direction
        ${resource_dn_status}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${parameters}    resourceDN

        Run Keyword If    ${resource_dn_status} and '${resource_dn_flag}'=='False'    Run Keywords
        ...    Set Test Variable    ${resource_dn}    ${parameters}[resourceDN]
        ...    AND    Set Test Variable    ${resource_dn_flag}    ${True}

        Run Keyword If    ${status}
        ...    Run Keyword If    '${parameters}[direction]' == 'RX'
        ...    Append To List    ${dist_name_list}    ${element}[distName]
    END
    ${remove_dist_name_list}=    Get Rx Channel List for Remove    ${dist_name_list}
    [Return]    ${remove_dist_name_list}    ${resource_dn}
