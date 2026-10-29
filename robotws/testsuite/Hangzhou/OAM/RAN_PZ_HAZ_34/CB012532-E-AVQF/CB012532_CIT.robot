*** Settings ***
Documentation
...  author: Han Ruiyu
...  contact: ruiyu.han@nokia-sbell.com

Resource   ./Resource/12532_common.robot
Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ANDROID_SA_ASIMR_ABINB4_AHPE    SBTS00    CRT_UTE    PY36

Suite Setup    12532 Common Suite Setup
Suite Teardown   Run Keyword And Ignore Error    12532 Common Suite Teardown

Test Setup   CB012532 Common Case Setup
Test Teardown   CB012532 Common Case Teardown


*** Variables ***
@{ALL_TEST_STATUS}
#${BTS}   ${tl.gnbs[0].instance_id}
##CONFIG L3CALL testline key: MRBTS_ID value:ue_index
&{L3CALL_TL}   846=0   289=0

*** Test Cases ***
[1]CB012532_feature_CIT_Cases
    [Tags]   AUTHOR_ruiyu.han@nokia-sbell.com
    [Timeout]   16h
    CB012532_Defined_BBMOD_Reset   times=${10}

