*** Settings ***
*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_powersaving_common_keywords.robot

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08

Force Tags    SBTS00
...   PY36

*** Variables ***

*** Test Cases ***
[1]SG8 RU Recovery during deep sleep mode due to RU restart
    [Tags]    CRT_TRUNK
    RU Recovery during deep sleep mode due to RU restart loop

[1]CB010766-SR-A-3 Entering_Exiting_Deep_Sleep_Mode_IWK_With_5GC000431
    [Tags]    CRT_TRUNK
    CB010766-SR-A-3 Entering_Exiting_Deep_Sleep_Mode_IWK_With_5GC000431

[1]Power Saving counters Testing
    [Tags]    CRT_TRUNK
    Power Saving counters Testing

*** Keywords ***
