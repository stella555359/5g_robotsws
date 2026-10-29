*** Settings ***
Suite Setup          Run Keywords    SISO Coam Suite Setup
...                  AND     Case Preparation
Suite Teardown       Run Keywords    SISO Coam Suite Teardown
...                  AND     Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_9925}    value=${0}
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resources/CB009925_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_powersaving_common_keywords.robot


Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB009925

Force Tags    CRT_23R1    CRT_23R2    CRT_TRUNK
...    PY36

*** Variables ***

*** Test Cases ***
[1]CB009925-SR-A RU entering deep sleep mode after all cells blocked
    [Tags]    CRT_TRUNK
    CB009925-SR-A RU returning from PowerSaving Mode to normal operation due to at least one cell unlocked

[1]CB009925-SR-A RU entering deep sleep mode during low traffic periods with 5GC000431 enabled
    [Tags]    CRT_TRUNK
    ${release}    Get program version based on gNB active version
    Run Keyword If   "${release}"=="SBTS23R3" or "${release}"=="SBTS23R4"
    ...     CB009925-SR-A RU returning from PowerSaving Mode to normal operation due to at least one carrier enabling on RU triggered by 5GC000431
    ...     ELSE    CB010766-SR-A-8 Activate RU deep sleep mode when feature flag enable

[1]CB009925-SR-A RU Recovery during deep sleep mode due to RU restart
    [Tags]    CRT_TRUNK
    CB009925-SR-A RU Recovery during deep sleep mode due to RU restart

[1]CB010766-SR-A-5 Entering_Exiting_Deep_Sleep_Mode_IWK_With_CB009925
    [Tags]    CRT_TRUNK
    Entering_Exiting_Deep_Sleep_Mode_IWK_With_CB009925

[1]CB010766-SR-A-3 Entering_Exiting_Deep_Sleep_Mode_IWK_With_5GC000431
    [Tags]    CRT_TRUNK
    CB010766-SR-A-3 Entering_Exiting_Deep_Sleep_Mode_IWK_With_5GC000431    if_need_new_scf=${False}

*** Keywords ***
