*** Settings ***

Documentation     author: Himanshu Singh
...               contact: himanshu.3.singh@nokia.com
...               Description:

Force Tags    P3_REG

Resource        ../../../Resources/robot/suite_common_keywords.robot
Resource        ../../../Resources/robot/ue_operations.robot

Suite Setup       Common Suite Setup    feature_folder=5GC002494

*** Variables ***
${WTS_FILE}                      basic_setup.lua
${WTS_CFG_PATH}                  ${CURDIR}/Config_Files/wts
${dl_tput}                       10
${ul_tput}                       10
${target_cell_1}                 1
@{All_Non_CA_SA_UE_List}         71    91
@{All_Non_CA_NSA_UE_List}        81    101
@{Non_CA_NSA_UE_List1}           81
@{Non_CA_NSA_UE_List2}           101
${NUMBER_OF_CELLS}               2
${EDAEMON_PORT}                  50000


*** Test Cases ***
5GC002494_TC1_MUE Verify Non_CA SA and NSA UEs calls both cells
    [Documentation]    Verify MUE Non CA SA and NSA UEs calls both cells
    [Tags]    AP_REG    2494_TC1
    [Setup]    Generic Test Setup    feature=5GC002494
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
    [Teardown]    Simple Test Teardown    ${All_Non_CA_SA_UE_List}    ${All_Non_CA_NSA_UE_List}