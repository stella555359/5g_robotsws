*** Settings ***


Documentation
...    Author:Guorong Song
...    Contact:guorong.song@nokia-sbell.com
...    squad:VRF HAZ4 1
...    Feature:CB008967-CR

Suite Setup         Setup Suite
Suite Teardown      Teardown Suite
Force Tags    PY36
Resource          Resource/CB008967_CR_Resources.robot

*** Test Cases ***
[1]CB008967-CR-J_2_SBTS_RMOD_FAN_Speed_in_WEBEM_AND_M2M
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case
    [Teardown]  Teardown case
    TC.CB008967-CR-J_2_SBTS_RMOD_FAN_Speed

CB008967-CR-F_KPIAlarm
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case
    [Teardown]  Teardown case
    TC.CB008967-CR-F_KPIAlarm

[1]CB008967-CR-J_1_Test
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case
    [Teardown]  Teardown case
    TC.CB008967-CR-J_2_SBTS_RMOD_MAX_TEMPERATURE