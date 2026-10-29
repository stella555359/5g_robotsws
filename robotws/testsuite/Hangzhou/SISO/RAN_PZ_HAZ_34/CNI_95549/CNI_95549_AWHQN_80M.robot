*** Settings ***
Documentation      author: Bin Wang
...                 contact: bin.3.wang@nokia-sbell.com

Suite Setup          SISO Suite Setup for AWHQN_80M
Suite Teardown       SISO Suite Teardown for AWHQN_80M
Test Timeout         60 min


Resource           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC002479/Resources/5GC002479_CP_Resource.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource           testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB005845/Resource/CB005845_Resource.robot

*** Test Cases ***
[1][1.0] General_SiSo_Auto_RF_module_reset_from_WebUI_with_L3call
    [Documentation]     This case is to verify RF reset and L3call after cell up
    [Tags]     AWHQN
    [Setup]    SISO Test Setup
    [Teardown]  SISO Test Teardown
    TC.General_SiSo_Auto_RF_module_reset_from_WebUI_with_L3call