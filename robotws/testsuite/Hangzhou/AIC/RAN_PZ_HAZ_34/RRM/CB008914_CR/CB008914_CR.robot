*** Settings ***
Force Tags    PY36
Documentation
...    Author:
...    Contact:
...    squad
...    Feature

Suite Setup         Setup Suite
Suite Teardown      Teardown Suite
Resource          Resource/CB008914_CR_Resources.robot
*** Variables ***


*** Test Cases ***
[1]General_SiSo_vDU_Reset
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case
    [Teardown]  Teardown case
    TC.General_SiSo_vDU_Reset

[1][1.1] General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case
    [Teardown]  Teardown case
    TC.General_SiSo_E2E_system_setup_with_data_transfer_conducted

General_SiSo_vDU_Lock_Unlock
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case
    [Teardown]  Teardown case
    TC.General_SiSo_vDU_Lock_Unlock
