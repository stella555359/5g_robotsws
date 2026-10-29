*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Variables    ../TestData/1635_variables.py

Documentation
...    author: Shufei Chen
...    contact: shufei.chen@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***

*** Keywords ***
General_SiSo_E2E_system_setup_with_data_transfer_conducted_50MHz
    [Arguments]    ${tput_self_define}   ${duration}=${600}    
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_1}    duration=${duration}    


General_SiSo_E2E_system_setup_with_data_transfer_conducted_70MHz
    [Arguments]    ${tput_self_define}   ${duration}=${600}    
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_1}    duration=${duration}    
