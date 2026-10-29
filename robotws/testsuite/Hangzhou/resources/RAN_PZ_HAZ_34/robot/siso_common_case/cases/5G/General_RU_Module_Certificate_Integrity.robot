*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
*** Variables ***

*** Keywords ***
General_RU_Module_Certificate_Integrity
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to do RU module cetificate integrity
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.13.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Connect to Ru and check if certificate exists
    Check_Integrity_On_RU
