*** Settings ***
Documentation     author: Rakshitha
...               contact: rakshitha.r@nokia.com
...               Description: n66 FDD Band with 40MHz and 30MHz BW 1S_2CCx2

Resource    ../../../Resources/robot/suite_common_keywords.robot
Resource    ../../../Resources/robot/ue_operations.robot

Suite Setup       Common Suite Setup    feature_folder=FDD_Bandwidth_40MHz_30MHz

*** Variables ***
${NUMBER_OF_CELLS}                 4
${dl_tput_list}                    100
${ul_tput}                         50
@{Multi_CA_SA_UE_List}             1    41    81    121
@{Multi_CA_NSA_UE_List}            11    51    91    131
${WTS_FILE}                        basic_setup.lua
@{target_NSA_cells}                1    2    3    4
${WTS_CFG_PATH}                    ${CURDIR}/Config_Files/wts

*** Test Cases ***
n66 FDD Band with 40MHz and 30MHz BW 1S_2CC_2
    [Tags]    AP_REG    FDD_BW_40MHz_30MHz
    [Setup]    Generic Test Setup    feature=FDD_Bandwidth_40MHz_30MHz
    Register and Start Traffic For SA UEs    ${Multi_CA_SA_UE_List}   uplink_tput=${ul_tput}
    ...     downlink_tput=${dl_tput_list}
    Attach Multi NSA UEs with different Cells    ${Multi_CA_NSA_UE_List}    ${target_NSA_cells}
    Start Traffic for multiple NSA UEs    ${Multi_CA_NSA_UE_List}    ${ul_tput}    ${dl_tput_list}
    Validate throughput from bearer stats for SA and NSA UEs    ${Multi_CA_SA_UE_List}    ${Multi_CA_NSA_UE_List}    dl_tput=${dl_tput_list}
    ...    ul_tput=${ul_tput}
    Stop Traffic and Detach SA UEs    ${Multi_CA_SA_UE_List}
    Stop Traffic and Detach NSA UEs    ${Multi_CA_NSA_UE_List}
    Log To Console    Re-Register For SA UEs
    Register For SA UEs    ${Multi_CA_SA_UE_List}
    Log To Console    Re-Attach Multi NSA UEs with different Cells
    Attach Multi NSA UEs with different Cells    ${Multi_CA_NSA_UE_List}    ${target_NSA_cells}
    Detach SA UEs    ${Multi_CA_SA_UE_List}
    Detach NSA UEs    ${Multi_CA_NSA_UE_List}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    sa_ue_list=${All_Non_CA_SA_UE_List}
    ...    nsa_ue_list=${All_Non_CA_NSA_UE_List}
    [Teardown]    Simple Test Teardown    sa_ue_list=${Multi_CA_SA_UE_List}    nsa_ue_list=${Multi_CA_NSA_UE_List}

n66 FDD Band with 40MHz and 30MHz BW 1S_2CC_2 with closed loop as dl_mimimode
    [Tags]    AP_REG    FDD_BW_40MHz_30MHz_TC2
    [Setup]    Generic Test Setup    feature=FDD_Bandwidth_40MHz_30MHz    mimomode_closed=True
    Register and Start Traffic For SA UEs    ${Multi_CA_SA_UE_List}   uplink_tput=${ul_tput}
    ...     downlink_tput=${dl_tput_list}
    Attach Multi NSA UEs with different Cells    ${Multi_CA_NSA_UE_List}    ${target_NSA_cells}
    Start Traffic for multiple NSA UEs    ${Multi_CA_NSA_UE_List}    ${ul_tput}    ${dl_tput_list}
    Validate throughput from bearer stats for SA and NSA UEs    ${Multi_CA_SA_UE_List}    ${Multi_CA_NSA_UE_List}    dl_tput=${dl_tput_list}
    ...    ul_tput=${ul_tput}
    Stop Traffic and Detach SA UEs    ${Multi_CA_SA_UE_List}
    Stop Traffic and Detach NSA UEs    ${Multi_CA_NSA_UE_List}
    Log To Console    Re-Register For SA UEs
    Register For SA UEs    ${Multi_CA_SA_UE_List}
    Log To Console    Re-Attach Multi NSA UEs with different Cells
    Attach Multi NSA UEs with different Cells    ${Multi_CA_NSA_UE_List}    ${target_NSA_cells}
    Detach SA UEs    ${Multi_CA_SA_UE_List}
    Detach NSA UEs    ${Multi_CA_NSA_UE_List}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    sa_ue_list=${All_Non_CA_SA_UE_List}
    ...    nsa_ue_list=${All_Non_CA_NSA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration
    ...    AND    Simple Test Teardown    sa_ue_list=${Multi_CA_SA_UE_List}    nsa_ue_list=${Multi_CA_NSA_UE_List}

*** Keywords ***
Update Gnb with closed loop dl mimomode for FDD_Bandwidth_40MHz_30MHz
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    ${FDD_NRCELL1_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=1
    set test variable    ${FDD_NRCELL1_DISTNAME}
    ${FDD_NRCELL2_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=2
    set test variable    ${FDD_NRCELL2_DISTNAME}
    ${FDD_NRCELL3_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=3
    set test variable    ${FDD_NRCELL3_DISTNAME}
    ${FDD_NRCELL4_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=4
    set test variable    ${FDD_NRCELL4_DISTNAME}
    ${cl_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${mimode_params}     ${FDD_NRCELL1_DISTNAME}
    set test variable    ${cl_param}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${FDD_NRCELL1_DISTNAME}    &{mimode_params}
    delta_store.update managed object and parameter to delta    dist_name=${FDD_NRCELL2_DISTNAME}    &{mimode_params}
    delta_store.update managed object and parameter to delta    dist_name=${FDD_NRCELL3_DISTNAME}    &{mimode_params}
    delta_store.update managed object and parameter to delta    dist_name=${FDD_NRCELL4_DISTNAME}    &{mimode_params}
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait Until Keyword Succeeds     2min     30sec     Check if gNB is reachable    ${GNB_IP}

Get Revert Delta Param for ${feature}
    Log To Console    Get Revert Delta Param for ${feature}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${FDD_NRCELL1_DISTNAME}    &{cl_param}
    delta_store.update managed object and parameter to delta    dist_name=${FDD_NRCELL2_DISTNAME}    &{cl_param}
    delta_store.update managed object and parameter to delta    dist_name=${FDD_NRCELL3_DISTNAME}    &{cl_param}
    delta_store.update managed object and parameter to delta    dist_name=${FDD_NRCELL4_DISTNAME}    &{cl_param}
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}