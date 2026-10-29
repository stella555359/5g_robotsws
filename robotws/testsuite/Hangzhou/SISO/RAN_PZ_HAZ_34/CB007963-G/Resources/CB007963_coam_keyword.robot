*** Settings ***
Library    String
Library    BuiltIn
Library    OperatingSystem
Library    Collections
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.gnb.oam.commissioning    WITH NAME    commissioning
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Variables    ./CB007963_parameters.py

Documentation
...    Author:fangmin wu
...    contact:fangmin.wu@nokia-sbell.com
...    squad group:mmw_SG_03

*** Variables ***
@{ports}       1    2

*** Keywords ***
COAM Create log directory for 561
    COAM Create log directory
    Set suite variable    ${tmp_log_dir}    ${LOG_PATH}

_Add_elements
    [Arguments]    ${dist_name}    ${filter_param}  ${abbr}
    selenium_coam.add_element    dist_name=${dist_name}
    ...                         filter_param=${filter_param}
    ...                         abbr=${abbr}

_Get_parameter_values
    [Arguments]    ${dist_name}    ${filter_param}  ${abbr}  ${node_index}
    ${parameter_values}       selenium_coam.get_parameter_value    dist_name=${dist_name}
                              ...                                  filter_param=${filter_param}
                              ...                                  abbr=${abbr}
                              ...                                  node_index=${node_index}
    [Return]  ${parameter_values}

Coam Input Parameter value via webUI
    [Arguments]    ${param_data}  ${node_index}
    selenium_coam.set_parameter_value    dist_name=${param_data}[dist_name]
    ...                                  filter_param=${param_data}[filter_param]
    ...                                  new_value=${param_data}[new_value]
    ...                                  abbr=${param_data}[abbr]
    ...                                  node_index=${node_index}
    ...                                  timeout=${120}

Coam Get Validate error
    ${defination_errors}    selenium_coam.get_definition_errors    timeout=${120}
    ${relation_errors}      selenium_coam.get_relation_errors    timeout=${120}
    ${hardware_errors}      selenium_coam.get_hardware_errors    timeout=${120}
    ${errors}    Catenate    ${defination_errors}   ${relation_errors}    ${hardware_errors}
    [Return]    ${errors}

COAM Check GNB Sync status
    [Arguments]    ${connection}=GNB_OAM
    Log to console    Check GNB Sync status
    ${sync_info}    coam.get_bts_sync_source_status    connection=${connection}
    @{sync_status}    Set variable    ${sync_info['syncSourceInfo']}
    &{sync_status}    Set variable    ${sync_status[0]}
    Run keyword and continue on failure    Should be equal as strings    ${sync_info['syncMode']}    PhaseSync
    ...                                    msg=Current synchronization mode is not PhaseSync mode    ignore_case=${True}
    Run keyword and continue on failure    Should be equal as strings    ${sync_status['status']['availability']}    Available
    ...                                    msg=Current synchronization status is not available    ignore_case=${True}
    Run keyword and continue on failure    Should contain any    ${sync_info['tuningMode']}    Normal tuning    Normal
    ...                                    msg=Current synchronization tuning mode is abnormal    ignore_case=${True}

Get Structure_index from expect_index
   [Arguments]   ${index_begin}   ${index_end}  ${expect_index}  ${dist_name}  ${filter_param}  ${abbr}
    @{index_actual} =    Create List
    FOR    ${index}    IN RANGE    ${index_begin}    ${index_end}
        ${index_values}     _Get_parameter_values  dist_name=${dist_name}
        ...                                            filter_param=${filter_param}
        ...                                            abbr=${abbr}
        ...                                            node_index=${index}
        Append To List    ${index_actual}      ${index_values}
    END
    ${structure_index}   Get Index From List   ${index_actual}     ${expect_index}
    [Return]       ${structure_index}

Count param according to expect values
    [Arguments]    ${index_begin}   ${index_end}  ${expect_values}  ${dist_name}  ${filter_param}  ${abbr}
    @{param_actual} =    Create List
    FOR    ${index}    IN RANGE    ${index_begin}    ${index_end}
        ${param_values}     _Get_parameter_values  dist_name=${dist_name}
        ...                                            filter_param=${filter_param}
        ...                                            abbr=${abbr}
        ...                                            node_index=${index}
        Append To List    ${param_actual}     ${param_values}
    END
    ${param_num}   Get Count   ${param_actual}     ${expect_values}
    [Return]     ${param_num}

Get values from different ports
    [Arguments]  ${ports_num}
    ${structure_index}    Get Structure_index from expect_index    index_begin=${0}
    ...                                                            index_end=${2}
    ...                                                            expect_index=${ports_num}
    ...                                                            dist_name=${GET_PARAMETER_PORTNUMBER[0]}[dist_name]
    ...                                                            filter_param=${GET_PARAMETER_PORTNUMBER[0]}[filter_param]
    ...                                                            abbr=${GET_PARAMETER_PORTNUMBER[0]}[abbr]
    &{ports_values}=      Create Dictionary
    ${topGMasterClockClass}       _Get_parameter_values  dist_name=${GET_PARAMETER_TOPGMASTERCLOCKCLASS[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_TOPGMASTERCLOCKCLASS[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_TOPGMASTERCLOCKCLASS[0]}[abbr]
    ...                                            node_index=${structure_index}
    ${topGMasterClockClass}       Convert To Integer      ${topGMasterClockClass}
    Set To Dictionary    ${ports_values}      topGMasterClockClass     ${topGMasterClockClass}
    ${index_topp_1}      Get Index From List      ${ports}      ${ports_num}
    ${localPriority}       _Get_parameter_values  dist_name=${PARAM_7963_STRUCTURE1[0]}[dist_name]
    ...                                            filter_param=${PARAM_7963_STRUCTURE1[0]}[filter_param]
    ...                                            abbr=${PARAM_7963_STRUCTURE1[0]}[abbr]
    ...                                            node_index=${index_topp_1}
    ${localPriority}      Convert To Integer       ${localPriority}
    Set To Dictionary    ${ports_values}      localPriority     ${localPriority}
    ${topStepsRemoved}       _Get_parameter_values  dist_name=${GET_PARAMETER_TOPSTEPSREMOVED[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_TOPSTEPSREMOVED[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_TOPSTEPSREMOVED[0]}[abbr]
    ...                                            node_index=${structure_index}
    ${topStepsRemoved}       Convert To Integer    ${topStepsRemoved}
    Set To Dictionary    ${ports_values}      topStepsRemoved     ${topStepsRemoved}
    ${topMasterClockIdentity}       _Get_parameter_values  dist_name=${GET_PARAMETER_TOPMASTERCLOCKIDENTITY[0]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_TOPMASTERCLOCKIDENTITY[0]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_TOPMASTERCLOCKIDENTITY[0]}[abbr]
    ...                                            node_index=${structure_index}
    ${topMasterClockIdentity}     Convert To Integer     ${topMasterClockIdentity}     16
    Set To Dictionary    ${ports_values}      topMasterClockIdentity     ${topMasterClockIdentity}
    ${topMasterUsed}       _Get_parameter_values  dist_name=${GET_PARAMETER_VALUES_7963[1]}[dist_name]
    ...                                            filter_param=${GET_PARAMETER_VALUES_7963[1]}[filter_param]
    ...                                            abbr=${GET_PARAMETER_VALUES_7963[1]}[abbr]
    ...                                            node_index=${structure_index}
    Set To Dictionary    ${ports_values}      topMasterUsed     ${topMasterUsed}
    [Return]   ${ports_values}

Find the smallest from list and get topMasterUsed index
    [Arguments]  ${one_num}    ${two_num}   ${count}
    @{numlist}=   Create List
    Append To List     ${numlist}     ${one_num}
    Append To List     ${numlist}     ${two_num}
    ${sortlist}    Copy List     ${numlist}
    Sort List      ${sortlist}
    ${count}      Get Count       ${numlist}       ${sortlist}[0]
    ${index}      Get Index From List      ${numlist}      ${sortlist}[0]
    ${used_index}     Set Variable If	${count}==${1}      ${index}      None
    [Return]  ${used_index}
