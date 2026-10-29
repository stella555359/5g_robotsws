*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

*** Variables ***

*** Keywords ***
Set Index
    [Arguments]    ${all}    ${msg_index}
    ${suffix}=    Set variable if    ${all}==1    ${EMPTY}    _${msg_index}
    [Return]    ${suffix}
