*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SG8 Common case Test Setup
Test Teardown        SG8 Common case Test Teardown


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/SG8_SISO_common_case/resources/SISO_common_case_keywords_SG8.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resources/CB013222_Common_Keywords.robot
Variables    TestData/CB013222_variables.py



Documentation
...    Author:zhenzhen ren
...    contact:zhenzhen.ren@nokia-sbell.com
...    squad group:SG_08
...    Feature CB013222 in 25R3

Force Tags            RAN_5G_TDD    5G_RAN_TDD    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED    SBTS00
...    PY36


*** Variables ***
${ui_version_M40P}    M40PUI1.1


*** Test Cases ***
[1][1.0] General_SiSo_Auto_Startup_BTS_power_reset_with_L3call
    [Tags]    CRT_TRUNK    CRT_25R3
    Commissioning SCF And Check alarm
    AlarmWatchdog.add_allow_alarms    fault_id=4590
    General_SiSo_Auto_Startup_BTS_power_reset_with_L3call_CB013222

[1][1.0] SiSo_RFS_Cell_block_and_unblock_with_L3call
    [Tags]    CRT_TRUNK    CRT_25R3
    Commissioning SCF And Check alarm
    AlarmWatchdog.add_allow_alarms    fault_id=49
    SiSo_RFS_Cell_block_and_unblock_with_L3call_CB013222

[1][1.0] General_SiSo_RAT_Reset
    [Tags]    CRT_TRUNK    CRT_25R3
    Commissioning SCF And Check alarm
    General_SiSo_RAT_Reset_CB013222

[1][2.0] General_SiSo_RU_module_reset_from_GUI
    [Tags]    CRT_TRUNK    CRT_25R3
    Commissioning SCF And Check alarm
    General_SiSo_RU_module_reset_from_GUI_CB013222

#[1][1.1]data_transfer_for_defined_nr_and_lte_cell
#    [Tags]    CRT_TRUNK    CRT_25R3
#    data_transfer_for_defined_nr_and_lte_cell    cell_id_nr=${0}    cell_id_lte=${0}    tput_define_nr=${tput_AVNB_NR}
#    ...    target_avg_percent_nr=0.5    min_percent_nr=0.3   target_avg_percent_lte=0.2    duration=${600}
#    ...    ui_version=${ui_version_M40P}
