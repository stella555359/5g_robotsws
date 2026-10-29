# @Time    : 2025/8/4 16:38
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : common.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is common robot keywords template
Resource    ../internal_resource.robot

*** Keywords ***
Airphone Set Common Test Variables
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/16 16:48
    [Arguments]    ${common_variables}    ${need_swconfig}=False
    Set Test Variable    ${SCFC_NAME}            ${common_variables["SCFC_NAME"]}
    Set Test Variable    ${AIRPHONE_NAME}        ${common_variables["AIRPHONE_NAME"]}
    Set Test Variable    ${WTS_NAME}             ${common_variables["WTS_NAME"]}
    Set Test Variable    ${GNBCUTYPE}            ${common_variables["GNBCUTYPE"]}
    IF    ${need_swconfig}
        Set Test Variable    ${GNB_SWCONFIG_NAME}        ${common_variables["GNB_SWCONFIG_NAME"]}
        Set Test Variable    ${AP_SWCONFIG_NAME}        ${common_variables["AP_SWCONFIG_NAME"]}
    END
