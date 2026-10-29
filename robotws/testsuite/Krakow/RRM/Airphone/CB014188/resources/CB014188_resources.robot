*** Settings ***
Documentation
...        Maintainers:
...           Maciej Majewski, maciej.majewski@nokia.com
...           Patryk Wojcik, patryk.wojcik@nokia.com
...        Authors:
...           Maciej Majewski, maciej.majewski@nokia.com
...           Patryk Wojcik, patryk.wojcik@nokia.com
...        Description:  Common keywords for CB014188

Library     ute_wtssim
Library     ta_emss
Library     ../../resources/former_l2_sw1/python/traffic_handling.py
Library     ../../resources/former_l2_sw1/python/ue_handling.py
Library     CB014188_resources.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../../resources/former_l2_sw1/robot/common_keywords.robot
Resource    ../../resources/former_l2_sw1/robot/collectors.robot

*** Keywords ***
Set timing advance
    [Arguments]    ${ue_id}=1    ${ta}=90    ${symbol_delay}=8
    Execute egate command  cmd=ue_ta_nr ue_p_delay_initial=${ta} profile_id=${ue_id} ue_p_symbol_delay_initial=${symbol_delay}
    Execute egate command  cmd=ue_testmode_set_nr action=activate testmode=ta profile_id=${ue_id} id=${ue_id}

Simulate ue position
    [Arguments]    ${ue_id}    ${dist}
    ${symbol_delay}    ${delay}=    calculate symbol and delay    ${dist}
    Execute egate command  cmd=ue_ta_nr ue_p_delay_initial=${delay} profile_id=${ue_id} ue_p_symbol_delay_initial=${symbol_delay}
    Execute egate command  cmd=ue_testmode_set_nr action=activate testmode=ta profile_id=${ue_id} id=${ue_id}
