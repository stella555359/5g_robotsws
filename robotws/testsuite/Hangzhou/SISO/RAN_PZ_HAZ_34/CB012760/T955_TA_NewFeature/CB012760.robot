*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           Run keywords    SG8 Common case Test Setup    AND    AlarmWatchdog.add_allow_alarms    fault_id=49
Test Teardown        Run keywords    AlarmWatchdog.remove_allow_alarms    fault_id=49     AND     SG8 Common case Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/SG8_SISO_common_case/resources/SISO_common_case_keywords_SG8.robot
Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012760/T955_TA_NewFeature/TestData/CB012760.py
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012760/T955_TA_NewFeature/resources/SISO_common_case_keywords_SG8_T955.robot


Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08

Force Tags    SBTS00
...   PY36

*** Variables ***
@{cell_id_common}    ${1}
${ui_version}    M40PUI1.1
@{cell_id_peak}    ${1}

*** Test Cases ***
[1][3.0] General_SiSo_Cell_block_and_unblock
    [Tags]    CRT_TRUNK
    General_SISO_Cell_Block_Unblock_SG08    tput_self_define=${tput_define_CB012760}    Max_loop=${1}    target_avg_percent=0.5
    ...    min_percent=0.4    cell_id=${cell_id_common}    duration=${120}    ui_version=${ui_version}

[1][2.0] Manual_SiSo_SM_RF_Module_lock_unlock
    [Tags]    CRT_TRUNK
    General_SISO_RU_Lock_Unlock_loop_With_Call_SG08    tput_self_define=${tput_define_CB012760}    Max_loop=${1}    target_avg_percent=0.5
    ...    min_percent=0.5    cell_id=${cell_id_common}    duration=${120}    ui_version=${ui_version}

[1][2.0] General_SiSo_RU_module_reset_from_GUI
    [Tags]    CRT_TRUNK
    General_SISO_RU_Reset_SG08    tput_self_define=${tput_define_CB012760}    Max_loop=${3}    target_avg_percent=0.5
    ...    min_percent=0.4    cell_id=${cell_id_common}    duration=${120}    ui_version=${ui_version}

[1][2.0] Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    CRT_TRUNK
    General_SISO_Site_Reset_SG08    tput_self_define=${tput_define_CB012760}    Max_loop=${1}    target_avg_percent=0.98
    ...    min_percent=0.85    cell_id=${cell_id_peak}     duration=${300}    ui_version=${ui_version}

[1][1.0] General_SiSo_RAT_Reset
    [Tags]    CRT_TRUNK
    General_SISO_RAT_Reset_SG08    tput_self_define=${tput_define_CB012760}    Max_loop=${1}    target_avg_percent=0.5
    ...    min_percent=0.4    cell_id=${cell_id_common}    duration=${120}    ui_version=${ui_version}

[1]CB012091-SR-A_10 RU returning from PowerSaving Mode to normal operation due to change of EnergySavingMode
    [Tags]    CRT_TRUNK
    RU returning from PowerSaving Mode to normal operation due to change of EnergySavingMode