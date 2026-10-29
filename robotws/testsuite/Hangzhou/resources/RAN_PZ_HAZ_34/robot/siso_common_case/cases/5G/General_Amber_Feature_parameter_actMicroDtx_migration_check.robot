*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
*** Variables ***

*** Keywords ***
General_Amber_Feature_parameter_actMicroDtx_migration_check
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify actMicroDtx migration check
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 28.10.2020 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    log to console   \n enable Power Saving mode
    Modify RMOD Power Parameter    power_status=true
    sleep  20
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4308
    log to console   \n disable Power Saving mode
    Modify RMOD Power Parameter    power_status=false
    sleep  20
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4308
