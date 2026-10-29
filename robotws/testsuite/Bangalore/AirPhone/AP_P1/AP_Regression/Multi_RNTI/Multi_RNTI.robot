# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Documentation      Verifies MRNTI validation scenarios
Resource    ../../Resources/robot/ue_operations.robot
Resource    ../../Resources/robot/suite_common_keywords.robot
Resource    ../Carrier_Aggregation/CA_Common_Keywords.robot

Suite Setup       Common Suite Setup    feature_folder=mrnti

*** Variables ***
${dl_tput}                     10
${ul_tput}                     10
@{logical_cell_list}           1    2
${nsa_start_ue_id}             101
@{all_UEs}                     ${EMPTY}
${NUMBER_OF_CELLS}             4
&{MultiRNTI_delta}             nsaInactivityTimer=300

*** Test Cases ***
MRNTI_TC1_Verify MUE NSA Calls with 14 UEs per Cell and 10Mbps DL_UL per UE
    [Documentation]    Verify MUE NSA Calls with 14 UEs per Cell and 10Mbps DL+10Mbps UL per UE with CRNTI validation
    [Tags]    AP_REG    MRNTI_TC1
    [Setup]    Run Keywords    Get List Of UE IDs    ${nsa_start_ue_id}    10    cell_deployment=NSA
    ...    AND    Generic Test Setup    feature=mrnti    wts_update=custom
    ...    ue_id=111    no_of_ues=4    logical_cell_list=@{logical_cell_list}
    ...    cell_deployment=NSA    scf_update=True    delta=&{MultiRNTI_delta}
    ${all_UEs}     Copy List    ${NSA_UE_List}
    Attach For NSA UEs    ${NSA_UE_List}    target_cells=3
    Sleep    10s
    Run Keyword And Ignore Error    Set WTS Default Log Level    level=4
    Start Traffic for multiple NSA UEs    ${NSA_UE_List}
    Get List Of UE IDs    ${${nsa_start_ue_id}+${10}}    4    cell_deployment=NSA1
    ${all_UEs}    Combine Lists    ${all_UEs}    ${NSA1_UE_List}
    Attach For NSA UEs    ${NSA1_UE_List}    target_cells=3
    Sleep    10s
    Start Traffic for multiple NSA UEs    ${NSA1_UE_List}
    Sleep    60s
    Validate Pcell Throughput For NSA Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput}    UE_List=${all_UEs}
    Stop Traffic and Detach NSA UEs    ${NSA_UE_List}
    Attach For NSA UEs    ${NSA_UE_List}    target_cells=3
    Sleep    10s
    Start Traffic for multiple NSA UEs    ${NSA_UE_List}
    Sleep    60s
    Validate Pcell Throughput For NSA Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput}    UE_List=${NSA_UE_List}
    Stop Traffic and Detach NSA UEs    ${NSA1_UE_List}
    Attach For NSA UEs    ${NSA1_UE_List}    target_cells=3
    Sleep    10s
    Start Traffic for multiple NSA UEs    ${NSA1_UE_List}
    Sleep    60s
    Validate Pcell Throughput For NSA Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput}    UE_List=${NSA1_UE_List}
    Stop Traffic and Detach NSA UEs    ${all_UEs}
    Run keywords    Get CRNTI values    ${all_UEs}    AND    Verify CRNTI values
    [Teardown]    Generic Test Teardown    feature=mrnti    nsa_ue_list=${all_UEs}    scf_update=False

*** Keywords ***
Update WTS config file for mrnti
    [Arguments]    &{kwargs}
    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    Run Keyword And Ignore Error    Update WTS config file for NSA MUEs    ${${kwargs['ue_id']}}    ${${kwargs['no_of_ues']}}
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${testlog_path}

Get CRNTI values
    [Documentation]    Get CRNTI value for each UE
    [Arguments]    ${UE_List}
    Log To Console    Get CRNTI values...
    @{ue_rnti}    Create List
    &{rnti_dict}    Create Dictionary
    Set Test Variable    ${UE_rnti}
    Set Test Variable    ${rnti_dict}
    FOR    ${UE_i}    IN    @{UE_List}
        ${rc}    ${output}    Run and return rc and output    grep "${UE_i}: UE performed EPS_ATTACH" /opt/wts/latest/egate_console.log
        ${crnti}    Get Regexp Matches    ${output}
        ...    UE${UE_i}\: UE performed EPS_ATTACH \\(crnti: (\\d+)    1
        Append To List    ${ue_rnti}    ${crnti}
        set to dictionary    ${rnti_dict}    UE${UE_i}    ${crnti}
    END
    ${flat_list}    Evaluate    [item for sub_list in ${ue_rnti} for item in sub_list]
    Set Test Variable    ${flat_list}

Verify CRNTI values
    [Documentation]    Verify CRNTI values for all UEs attached
    Log To Console    Verify CRNTI values...
    ${lst_len}    Get Length    ${flat_list}
    ${s_list}    Evaluate    set(${flat_list})
    ${lst2_len}    Get Length    ${s_list}
    Run Keyword if    ${lst_len}>${lst2_len}    FAIL    msg = UEs CRNTI values are matched from the list ${rnti_dict}

Get Delta for mrnti
    [Arguments]    &{kwargs}
    Get bts distname
    ${nsaInactivityTimer}    Pop From Dictionary    ${kwargs}    nsaInactivityTimer
    update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}
    ...    nsaInactivityTimer=${nsaInactivityTimer}
