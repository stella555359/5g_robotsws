*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           Run keywords    SG8 Common case Test Setup    AND    AlarmWatchdog.add_allow_alarms    fault_id=49
Test Teardown        Run keywords    AlarmWatchdog.remove_allow_alarms    fault_id=49     AND     SG8 Common case Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/SG8_SISO_common_case/resources/SISO_common_case_keywords_SG8.robot
Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012760/T955_TA_NewFeature/TestData/CB012760.py
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CNI138571/Resource/CNI138571_Keyword.robot

Documentation
...    Author:Zhai Yuxing
...    contact:yuxing.zhai@nokia-sbell.com
...    squad group:VRF HAZ 1

Force Tags    SBTS00
...   PY36

*** Variables ***
@{cell_id_common}    ${1}
${ui_version}    M40PUI1.1
@{cell_id_peak}    ${1}

*** Test Cases ***
[1][3.0] General_SiSo_Cell_block_and_unblock
    [Tags]    CRT_TRUNK
    General_SISO_Cell_Block_Unblock_SG08    tput_self_define=${None}    Max_loop=${1}    target_avg_percent=0.5
    ...    min_percent=0.4    cell_id=${cell_id_common}    duration=${120}    ui_version=${ui_version}  with_call=${False}

[1][3.0] General_SISO_Site_Reset
   [Tags]    CRT_TRUNK
   General_SISO_Site_Reset_SG08    tput_self_define=${None}    Max_loop=${1}    target_avg_percent=0.5
   ...    min_percent=0.4    cell_id=${cell_id_common}    duration=${120}    ui_version=${ui_version}  with_call=${False}

[1][2.0] Manual_SiSo_SM_RF_Module_lock_unlock
   [Tags]    CRT_TRUNK
   General_SISO_RU_Lock_Unlock_VRF1    tput_self_define=${None}    Max_loop=${1}    target_avg_percent=0.4
    ...    min_percent=0.3    cell_id=${cell_id_common}    duration=${300}    ui_version=${ui_version}  with_call=${False}



