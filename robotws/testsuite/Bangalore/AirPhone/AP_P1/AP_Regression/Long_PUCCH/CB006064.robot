# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Documentation    This file contains test cases related to CB006064 feature
Resource    ../../Resources/robot/ue_operations.robot
Resource    ../../Resources/robot/suite_common_keywords.robot

Force Tags      AP_REG    P3_REG

Suite Setup       Common Suite Setup    feature_folder=CB006064

*** Variables ***
${dl_tput}                     10
${ul_tput}                     10
&{CB006064_delta}              maxNumPdschAllocationPerSlot=8    maxNumPuschAllocationPerSlot=8
@{logical_cell_list}           1    2
@{Counter_List}                M55303C13001    M55303C17001    M55303C14001    M55303C18001
${nsa_start_ue_id}             101
${sa_start_ue_id}              1


*** Test Cases ***
CB006064_TC1_Verify MUE NSA Calls with 10 UEs per Cell and 10Mbps DL_UL per UE with FDM enabled
    [Documentation]    Verify MUE NSA Calls with 10 UEs per Cell and 10Mbps DL+10Mbps UL per UE with FDM enabled
    ...    and check for FDM related counters for pusch and pdsch
    [Tags]    AP_REG    CB006064_TC1
    [Setup]    Run Keywords    Get List Of UE IDs    ${nsa_start_ue_id}    10    cell_deployment=NSA
    ...    AND    Generic Test Setup    feature=CB006064    scf_update=True
    ...    ue_id=13    no_of_ues=8    cell_deployment=NSA    logical_cell_list=@{logical_cell_list}
    ...    delta=&{CB006064_delta}
    Attach For NSA UEs    ${NSA_UE_List}
    Start Traffic for multiple NSA UEs    ${NSA_UE_List}
    Validate Bearer Stats for multiple UEs    ${NSA_UE_List}    ${dl_tput}    ${ul_tput}    mode=NSA
    Stop Traffic and Detach NSA UEs    ${NSA_UE_List}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    ${NSA_UE_List}
    [Teardown]    Generic Test Teardown    feature=CB006064    nsa_ue_list=${NSA_UE_List}

CB006064_TC2_Verify MUE SA Calls with 10 UEs per Cell and 10Mbps DL_UL per UE with FDM enabled
    [Documentation]    Verify MUE SA Calls with 10 UEs per Cell and 10Mbps DL+10Mbps UL per UE with FDM enabled
    ...    and check for FDM related counters for pusch and pdsch
    [Tags]    AP_REG    CB006064_TC2
    [Setup]    Run Keywords    Get List Of UE IDs    ${sa_start_ue_id}    10    cell_deployment=SA
    ...    AND    Generic Test Setup    feature=CB006064    scf_update=True
    ...    ue_id=3    no_of_ues=8    cell_deployment=SA    logical_cell_list=@{logical_cell_list}
    ...    delta=&{CB006064_delta}
    Register For SA UEs    ${SA_UE_List}
    Start Traffic for multiple SA UEs    ${SA_UE_List}
    Validate Bearer Stats for multiple UEs    ${SA_UE_List}    ${dl_tput}    ${ul_tput}    mode=SA
    Stop Traffic and Detach SA UEs    ${SA_UE_List}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    ${SA_UE_List}
    [Teardown]    Generic Test Teardown    feature=CB006064    sa_ue_list=${SA_UE_List}

*** Keywords ***
Get Delta for CB006064
    [Arguments]    &{delta}
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    actFdmEnhancedScheduling=true
    FOR    ${NRCELL_distname}    IN    @{NRCELL_distname_list}
        delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}    &{delta}
    END

Update WTS config file for CB006064
    [Arguments]    &{kwargs}
    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    Run Keyword If    '${kwargs['cell_deployment']}'=='SA'
    ...    Update WTS config file for SA MUEs    ${${kwargs['ue_id']}}    ${${kwargs['no_of_ues']}}
    ...    ELSE    Update WTS config file for NSA MUEs    ${${kwargs['ue_id']}}    ${${kwargs['no_of_ues']}}
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${testlog_path}
