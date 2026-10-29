*** Settings ***
Suite Setup    SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
Test Setup    SISO Coam Test Setup    fail_with_alarms=${True}     is_ru_log_collecting_enable=${True}
Test Teardown    SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010823_SG4/Resources/CB010823_common_keyword.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot

Documentation
...    Author: tingting.zhong
...    Contact: tingting.zhong@nokia-sbell.com
...    squad group:SG_04
...    Feature CB008941

Force Tags            RAN_5G_TDD    5G_RAN_TDD    5G_RAN    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_SA_ASIBL_ABIOB1_AQQF
...   PY310    HAZ4_T04


*** Test Cases ***
[1]CB010823-SR-B_2_Run FULL Diagnostic check offline from WebEM Remote tool
    [Tags]    2S-2CC-16D-2U_72E
    Run FULL Diagnostic check offline from WebEM Remote tool
