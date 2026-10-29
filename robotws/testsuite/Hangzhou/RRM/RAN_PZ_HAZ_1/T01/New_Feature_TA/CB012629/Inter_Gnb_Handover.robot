*** Settings ***
Documentation
...   Author: Qin Zhixia
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: The purpose of this test is to Check CB008411

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     Common Test Teardown For RRM

Force Tags
...                CA_RAN_PZ_HAZ_1
...                RAN_PZ_HAZ1_SG02_ST_RRM
...                TA_LEVEL_22
...                CRT
...                TRUNK


Test Timeout    180 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          CommonKeyword/CB012629_Common_KeyWord.robot


*** Test Cases ***
Inter_Gnb_Handover
     FOR  ${index}    IN RANGE    1    50
         log to console   ${index}
         Start attenuator   value8=${20}    value16=${20}
         sleep  60s
         Start attenuator   value8=${20}    value16=${30}
         sleep  60s
         Start attenuator   value8=${20}    value16=${20}
         sleep  60s
         Start attenuator   value8=${40}    value16=${20}
         sleep  60s
     END
     [Teardown]     TC03 Teardown

*** Keywords ***
TC03 Teardown
     Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}
     Common Test Teardown For RRM

