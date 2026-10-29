*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
Test Timeout         4h

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource      ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource      ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...
...    Feature CB012510 ABIP enhanced NR FDD/LTE FDD/NR TDD tri-mode and enhanced NR FDD/LTE FDD dual-mode
...    in SBTS25R1 program which including sub-features in HAZ4_T05:
...    CB012510-SR-A: CB012510-A BB cell set M3 + NR TDD BB cell set in one ABIP
...
...    Configuration: 25R1_NL_CB012510_A
...    USCB012510-A#B1: ABIP enhanced concurrent tri-mode configuration with new BB cell set type M3 + NR TDD BB cell set (CB009142)

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all

*** Test Cases ***
[1]CB012510-SR-A_General_SiSo_Auto_RF_lock_unlock
    [Tags]    5S-25R1_NL_CB012510_A    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${False}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown
