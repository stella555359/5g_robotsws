*** Settings ***
Force Tags    PY36
Documentation
...    Author:bin.3.wang
...    Contact:bin.3.wang@nokia-sbell.com
...    squad:VRF HAZ4 1
...    Feature:CB009301

Suite Setup         Setup Suite
Suite Teardown      Teardown Suite
Resource          Resource/CB009301_CR_Resources.robot

*** Test Cases ***
CB009301_CR Cell setup with CB009301 enabled
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case
    [Teardown]  Teardown case
    TC.Cell_setup_with_CB009301_enabled

CB009301_CR vDU reset with CB009301 enabled
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case
    [Teardown]  Teardown case
    TC.vDU_reset_with_CB009301_enabled

[1][1.0] CB013940_A_1_RU raises fault 4680 and cancels the fault by timer
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case
    [Teardown]  Teardown case
    TC.CB013940_A_1_RU raises fault 4680 and cancels the fault by timer