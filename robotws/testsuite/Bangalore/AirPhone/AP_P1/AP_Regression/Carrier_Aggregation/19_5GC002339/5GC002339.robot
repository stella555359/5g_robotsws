*** Settings ***

Documentation     author: Himanshu Singh
...               contact: himanshu.3.singh@nokia.com
...               Description:

Force Tags    P3_REG
Resource    ./2339_Keywords.robot

Suite Setup       Suite Setup    feature_folder=5GC002339

*** Variables ***
${WTS_FILE}                      basic_setup.lua
${WTS_CFG_PATH}                  ${CURDIR}/cfg
${dl_tput}                       10
${ul_tput}                       10
${target_cell_1}                 1
@{All_Non_CA_SA_UE_List}         1    2    3    4    5    6    7    8    9    10    11    12    13    14
    ...    41    42    43    44    45    46    47    48    49    50    51    52    53    54
@{All_Non_CA_NSA_UE_List}        21    22    23    24    25    26    27    28    29    30    31    32    33    34
    ...    61    62    63    64    65    66    67    68    69    70    71    72    73    74
@{Non_CA_NSA_UE_List1}           21    22    23    24    25    26    27    28    29    30    31    32    33    34
@{Non_CA_NSA_UE_List2}           61    62    63    64    65    66    67    68    69    70    71    72    73    74
${NUMBER_OF_CELLS}               2

*** Test Cases ***
5GC002339_TC1_MUE 14_SA_UE Non_CA calls both cells with 10DL_10UL traffic
    [Documentation]    Verify MUE 14 Non CA calls both cells with 10DL_10UL traffic for SA UEs
    [Tags]    AP_REG    2339_TC1_SA_MUE
    [Setup]    Test Setup
    UE Register and Start Traffic For SA Non CA Capable UEs    ${All_Non_CA_SA_UE_List}    ${ul_tput}
    Sleep    30s
    Validate Pcell Throughput from UE stats for Non CA Capable UEs    ${ul_tput}    ${dl_tput}    ${All_Non_CA_SA_UE_List}
    Stop Traffic and Detach SA UEs    sa_ue_list=${All_Non_CA_SA_UE_List}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    ${All_Non_CA_SA_UE_List}
    [Teardown]    Test Teardown For HO cases    sa_ue_list=${All_Non_CA_SA_UE_List}

5GC002339_TC2_MUE 14_NSA_UE Non_CA calls both cells with 10DL_10UL traffic
    [Documentation]    Verify MUE 14 Non CA calls both cells with 10DL_10UL traffic for NSA UEs
    [Tags]    AP_REG    2339_TC2_NSA_MUE
    [Setup]    Test Setup    dl_tput=${dl_tput}    ul_tput=${ul_tput}    target_cell_1=${target_cell_1}
    Attach and Start Traffic For NSA UEs    ${Non_CA_NSA_UE_List1}    uplink_tput=${ul_tput}
    ...    downlink_tput=${dl_tput}    target_cells=${target_cell_1}
    Attach and Start Traffic For NSA UEs    ${Non_CA_NSA_UE_List2}    uplink_tput=${ul_tput}
    ...    downlink_tput=${dl_tput}
    Sleep    30s
    Validate Pcell Throughput from UE stats for Non CA Capable UEs    ${ul_tput}    ${dl_tput}    ${All_Non_CA_NSA_UE_List}
    ...    scell=8
    Stop Traffic and Detach NSA UEs    nsa_ue_list=${All_Non_CA_NSA_UE_List}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    sa_ue_list=${EMPTY}    nsa_ue_list=${All_Non_CA_NSA_UE_List}
    [Teardown]    Test Teardown For HO cases    nsa_ue_list=${All_Non_CA_NSA_UE_List}