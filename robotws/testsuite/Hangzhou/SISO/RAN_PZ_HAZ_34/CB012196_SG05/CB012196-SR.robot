*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
Test Timeout         2h

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG5/robot/optical_switch/optical_switch.robot
Resource      ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource      ${BASIC_PATH_5G}/BTS/Manual_SiSo_SM_NR_RAT_reset.robot
Resource      ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource      ${BASIC_PATH_5G}/BTS/General_SiSo_RAT_Block_Unblock.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...
...    Feature CB012196: TDD additional eCPRI configs for 25R1 in SBTS25R1 program which including sub-features:
...    CB012196-SR-A: Extend CB010713-A/-B ABIP BB cell set to support 16DL or 8DL(8Rx IRC) layers
...                   with mMIMO radios and 8T8R/4T4R radios mixture
...    CB012196-SR-C: ABIO/ASOE NR FR1 TDD eCPRI configuration block with up to 4cc 8DL8UL per radio
...    CB012196-SR-D: ABIO/ASOE NR FR1 TDD eCPRI configuration block with 2 cells 60MHz 16DL8UL and 1 cell 60MHz 8DL8UL
...
...    Configuration:
...    CB012196-SR-A:
...                   case 1: CB012196-A-CB010713-A BB cellset type A;  full ABIP; up to 6 cells
...                   case 2: CB012196-A-CB010713-B BB cellset type B;  half ABIP; up to 3 cells
...    CB012196-SR-C: 25R1_N_CB012196_7; 4cc 8DL per radio with 1 ASOE
...    CB012196-SR-D: 25R1_N_CB012196_8; 2 cells 60MHz 16DL and 1 cell 60MHz 8DL

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY39    master_classicalbts_all

*** Variables ***

*** Test Cases ***
[1]CB012196-SR-A-17-General_SiSo_SFP_lock_unlock_for_configuration_testing
    [Tags]    5S-1CC_CB012196-A_CB010713-A    CRT_25R1    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    optical_switch.General_SiSo_SFP_lock_unlock_for_configuration_testing    is_optical_switch=${False}
    [Teardown]    SISO Coam Test Teardown

[1]CB012196-SR-A-04-General_SiSo_RAT_Block_Unblock_with_L3Call
    [Tags]    3S-1CC_CB012196-A_CB010713-B    CRT_25R1    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${fault_list}    Create List    4614
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_RAT_Block_Unblock    with_call=${True}
    [Teardown]    SISO Coam Test Teardown

[1]CB012196-SR-C-41-Manual_SiSo_SM_NR RAT reset
    [Tags]    2S-4CC-8D8U_50M_4Rx_CB012196_7    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Manual_SiSo_SM_NR_RAT_reset    with_call=${True}
    [Teardown]    SISO Coam Test Teardown

[1]CB012196-SR-D-45-General_SiSo_Cell_block_and_unblock
    [Tags]    3S-1CC-16D8U-8D8U_60M_4Rx_CB012196_8    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    #General_SiSo_Cell_block_and_unblock    with_call=${True}
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${True}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

*** Keywords ***
