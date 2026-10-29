*** Settings ***
Suite Setup    run keywords    SISO Coam Suite Setup    AND    Get btsName
Suite Teardown    run keywords    Connect to gnb coam via ssl    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}    AND
...    run keyword and ignore error    COAM Teardown gnb connections    AND    SISO Coam Suite Teardown
Test Setup    SISO Coam Test Setup
Test Teardown    SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     Resources/CB009275_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_powersaving_common_keywords.robot
Variables    TestData/9275_variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/SG8_SISO_common_case/TestData/SISO_common_case_variables_SG8.py

Documentation
...    Author:linjiangjing
...    contact:jiangjing.lin@nokia-sbell.com
...    squad group:SG_08
...    Feature CB009275

Force Tags    SBTS00
...   PY36

*** Variables ***
@{cell_id_common}    ${1}

*** Test Cases ***
[1]CB009275_Feature_Enable_and_Disable_with_Fault_1932_actived
    Fault 1932 is triggered

[1]CB009275_Feature_Enable_and_Disable_with_Fault_1933_1934_actived
    Fault 1933 and Fault 1934 with high temperature

[1]CB009275_Feature_Enable_And_Disable_with_Fault_1933_1934_not_raised_due_radio_temperature_not_reach_threshold
    Fault 1933 and 1934 with low temperature

#[1]Feature_Enable_and_Disabled_with_Radio_FAN_Work_Normally
#    Feature_Enable_and_Disabled_with_Radio_FAN_Work_Normally

[1]CB010766-SR-A-3 Entering_Exiting_Deep_Sleep_Mode_IWK_With_5GC000431
    [Tags]    CRT_TRUNK
    CB010766-SR-A-3 Entering_Exiting_Deep_Sleep_Mode_IWK_With_5GC000431    if_check_counter=False

[1]CB009925-SR-A RU Recovery during deep sleep mode due to RU restart
    [Tags]    CRT_TRUNK
    RU Recovery during deep sleep mode due to RU restart loop    Max_loop=${5}

[1]General_SISO_BB_Lock_Unlock_SG08
    [Tags]    CRT_TRUNK
    General_SISO_BB_Lock_Unlock_SG08    tput_self_define=${tput_define_SG8_common}    Max_loop=${5}    target_avg_percent=0.98
    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}    with_call=False

[1]General_SISO_BB_Reset_SG08
    [Tags]    CRT_TRUNK
    General_SISO_BB_Reset_SG08    tput_self_define=${tput_define_SG8_common}    Max_loop=${5}    target_avg_percent=0.98
    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}    with_call=False

[1]General_SISO_Cell_Block_Unblock_SG08
    [Tags]    CRT_TRUNK
    AlarmWatchdog.add_allow_alarms    fault_id=49
    General_SISO_Cell_Block_Unblock_SG08    tput_self_define=${tput_define_SG8_common}    Max_loop=${5}    target_avg_percent=0.98
    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}    with_call=False

[1]General_SISO_Cell_Lock_Unlock_SG08
    [Tags]    CRT_TRUNK
    General_SISO_Cell_Lock_Unlock_SG08    tput_self_define=${tput_define_SG8_common}    Max_loop=${5}    target_avg_percent=0.98
    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}    with_call=False

[1]General_SISO_Site_Reset_SG08
    [Tags]    CRT_TRUNK
    General_SISO_Site_Reset_SG08    tput_self_define=${tput_define_SG8_common}    Max_loop=${5}    target_avg_percent=0.98
    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}    with_call=False

[1]General_SISO_RU_Reset_SG08
    [Tags]    CRT_TRUNK
    General_SISO_RU_Reset_SG08    tput_self_define=${tput_define_SG8_common}    Max_loop=${50}    target_avg_percent=0.98
    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}    with_call=False

[1]General_SISO_RAT_Reset_SG08
    [Tags]    CRT_TRUNK
    AlarmWatchdog.add_allow_alarms    fault_id=49
    General_SISO_RAT_Reset_SG08    tput_self_define=${tput_define_SG8_common}    Max_loop=${5}    target_avg_percent=0.98
    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}    with_call=False

[1]General_SISO_RU_Lock_Unlock_loop_SG08
    [Tags]    CRT_TRUNK
    General_SISO_RU_Lock_Unlock_loop_SG08    tput_self_define=${tput_define_SG8_common}    Max_loop=${5}    target_avg_percent=0.98
    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}    with_call=False

[1]General_SISO_RAT_Block_Unblock_SG08
    [Tags]    CRT_TRUNK
    General_SISO_RAT_Block_Unblock_SG08    tput_self_define=${tput_define_SG8_common}    Max_loop=${5}    target_avg_percent=0.98
    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}    with_call=False

[1]General_SISO_RU_Power_Reset_SG08
    [Tags]    CRT_TRUNK
    AlarmWatchdog.add_allow_alarms    fault_id=1815
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    General_SISO_RU_Power_Reset_SG08    tput_self_define=${tput_define_SG8_common}    Max_loop=${5}    target_avg_percent=0.98
    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}    with_call=False
