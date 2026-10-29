*** Settings ***
Force Tags    PY36
Documentation
...    Author:
...    Contact:
...    squad
...    Feature

Suite Setup         KW.SuiteSetup
Suite Teardown      Teardown Suite
Resource          Resource/CB009903_Resources.robot



*** Test Cases ***
[2]CB009903_F_3_Fault_2920 trigger and cancel with inputVoltage changed
    [Documentation]
    [Tags]    CRT_TRUNK
    [Teardown]  Teardown case
    TC.CB009903_F_3_Fault_2920 trigger and cancel with inputVoltage changed

[2][1.1] Manual_SiSo_REC_RU_safe_mode_improper_voltage_input
    [Documentation]
    [Tags]    CRT_TRUNK
    [Teardown]  Teardown case
    TC.Manual_SiSo_REC_RU_safe_mode_improper_voltage_input