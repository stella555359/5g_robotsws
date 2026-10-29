*** Settings ***
Documentation
...   Author: Xiang Liangliang
...   Contact: liang.xiang@nokia-sbell.com
...   Description: This is the module test case

Resource            ../../Module/Module.robot
Resource            ../Fault_1900_Trigger_Clear.robot
#Resource          ../../../../RRM/RAN_PZ_HAZ_1/Resources/Classical/RRM_MultiBTS_Common_Resource.robot

# Suite Setup       Common MultiBTS Suite Setup For RRM
# Test Setup        Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
# Test Teardown     Common MultiBTS Test Teardown For RRM
# Suite Teardown    Common MutliBTS Suite Teardown For RRM

Force Tags        RAN_VRF_HAZ1

Test Timeout      60 minutes




*** Test Cases ***
TC01_Main
    Fault 1900 Trigger And Clear
    ...    product_type=gnb
    ...    bts_index=${0}


