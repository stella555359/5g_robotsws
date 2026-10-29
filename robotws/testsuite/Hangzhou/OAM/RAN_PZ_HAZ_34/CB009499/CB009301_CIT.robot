*** Settings ***
Documentation
...  author: Han Ruiyu
...  contact: ruiyu.han@nokia-sbell.com

Resource   ./Resource/9301_common.robot
Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ANDROID_SA_ASIMR_ABINB4_AHPE    SBTS00    CRT_UTE    PY36

Suite Setup    9301 Common Suite Setup for COAM
Suite Teardown   Run Keyword And Ignore Error    9301 COAM Teardown gnb connections


*** Variables ***
@{ALL_TEST_STATUS}
#${BTS}   ${tl.gnbs[0].instance_id}
##CONFIG L3CALL testline key: MRBTS_ID value:ue_index
&{L3CALL_TL}   846=0   289=0

*** Test Cases ***

[1]CB009301_feature_enable_disable_loops
    [Tags]   AUTHOR_ruiyu.han@nokia-sbell.com
    [Timeout]   4h
    [Setup]     Case Setup for 9301
    CB009301_feature_enable_disable_loops    times=${10}
    [Teardown]   Case Teardown for 9301



