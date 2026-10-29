*** Settings ***
Documentation
...   This is template of automation testing
...   squad group: MMW_SG1

Variables   ./../TestData/NIDD_modify.py
Resource    ./5GC00xxxx_variables.robot
Resource    ./../../common_resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot


*** Keywords ***
Temp keyword for testing
    [Documentation]    Author: xxxx
    ...    Define your own keywords
    [Arguments]    ${parameter}=${None}
    log to console     Temp keyword for testing
