*** Settings ***
Documentation    This file contains test cases related to CB007859 feature
Resource        ../../../Resources/robot/suite_common_keywords.robot
Resource        ../../../Resources/robot/ue_operations.robot

Suite Setup       Common Suite Setup    feature_folder=CB007859

*** Variables ***
${WTS_FILE}                      basic_setup.lua
${WTS_CFG_PATH}                  ${CURDIR}/Config_Files/wts
${dl_tput}                       4
${ul_tput}                       4
${target_cell_1}                 1
@{Counter_List}                  M55308C17002    M55308C18002
@{All_Non_CA_SA_UE_List}         1    2    3    4    5    6    7    8    9    10
    ...    41    42    43    44    45    46    47    48    49    50
@{Non_CA_NSA_UE_List1}           11    12    13    14    15    16    17    18    19    20
@{Non_CA_NSA_UE_List2}           51    52    53    54    55    56    57    58    59    60
${NUMBER_OF_CELLS}               2
${EDAEMON_PORT}                  50000


*** Test Cases ***
CB007859_TC1_MUE Verify Non_CA SA and NSA UEs calls both cells
    [Documentation]    Verify MUE Non CA SA and NSA UEs calls both cells
    [Tags]    AP_REG    CB007859_TC1
    [Setup]    Generic Test Setup    feature=CB007859
    @{All_Non_CA_NSA_UE_List}=    Combine Lists    ${Non_CA_NSA_UE_List1}    ${Non_CA_NSA_UE_List2}
    UE Register and Start Traffic For SA Non CA Capable UEs    ${All_Non_CA_SA_UE_List}    ${ul_tput}
    Attach and Start Traffic For NSA UEs    ${Non_CA_NSA_UE_List1}    uplink_tput=${ul_tput}
    ...    downlink_tput=${dl_tput}    target_cells=${target_cell_1}
    Attach and Start Traffic For NSA UEs    ${Non_CA_NSA_UE_List2}    uplink_tput=${ul_tput}
    ...    downlink_tput=${dl_tput}
    Sleep    30s
    Validate throughput from bearer stats for SA and NSA UEs    ${All_Non_CA_SA_UE_List}    ${All_Non_CA_NSA_UE_List}
    ...    ${dl_tput}    ${ul_tput}
    Stop Traffic and Detach SA UEs    sa_ue_list=${All_Non_CA_SA_UE_List}
    Stop Traffic and Detach NSA UEs    nsa_ue_list=${All_Non_CA_NSA_UE_List}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    sa_ue_list=${All_Non_CA_SA_UE_List}
    ...    nsa_ue_list=${All_Non_CA_NSA_UE_List}
    [Teardown]    Simple Test Teardown    sa_ue_list=${All_Non_CA_SA_UE_List}    nsa_ue_list=${All_Non_CA_NSA_UE_List}