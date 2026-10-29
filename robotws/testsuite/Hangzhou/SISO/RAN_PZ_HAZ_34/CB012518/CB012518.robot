*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
Test Timeout         3h

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource      ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource      ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource      testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/resource/resources_l3call.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB012518 in SBTS24R3 program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY39    master_classicalbts_all

*** Variables ***

*** Test Cases ***
[1]CB012518-SR-A_01_03_10MHz_L3Call_Setup
    [Tags]    1S-1CC-8D8U_10M_CB012518   CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${cell_list}    create list    ${11}
    Run Keyword If    ${MRBTS_ID}==${2599}    Samsung open screen
    Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${False}    4G_check=${False}
    [Teardown]    SISO Coam Test Teardown

[1]CB012518-SR-A_02_03_10MHz_60MHz_Split_Mode_Cell_Locked_Unlocked
    [Tags]    1S-2CC-8D8U_10-60M_Split_CB012518   CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_Cell_lock_and_unlock
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

*** Keywords ***
