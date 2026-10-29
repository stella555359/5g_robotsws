*** Settings ***
Suite Setup    SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
Test Setup    SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown    SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008941_SG4/Resources/CB008941_common_keyword.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot

Documentation
...    Author: tingting.zhong
...    Contact: tingting.zhong@nokia-sbell.com
...    squad group:SG_04
...    Feature CB008941

Force Tags            RAN_5G_TDD    5G_RAN_TDD    5G_RAN    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_SA_ASIBL_ABIOB1_AQQF
...   PY36

*** Variables ***

*** Test Cases ***
[1]CB008941-SR-AB_2_L3call_Loki_based_DU_with_UL_PRB_muting_active_FDBF
    [Tags]    RF50
    L3call_Loki_based_DU_with_UL_PRB_muting_active_FDBF
