*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
Test Timeout         2h

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource      ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource      ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
#Resource      ${BASIC_PATH_5G}/Manual_SiSo_SM_BTS_Site_Reset.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...
...    Feature CB012598: ASOG/H NR FR1 TDD eCPRI 7-2e BB cell set 8 cells up to 16DL in SBTS26R1 program including sub-features:
...    CB012598-SR-A: NR FR1 TDD eCPRI 7-2e BB cell set up to 4 cells up to 16DL-4UL MIMO layers on half ASOG/H - 25R3
...    CB012598-SR-B: NR FR1 TDD eCPRI 7-2e BB cell set up to 4 cells up to 16DL-8UL MIMO layers on half ASOG/H - 26R1
...    Feature Scope: up to 12194511: up to 8 cells up to 16DL-8UL in target release 26R1; one restricted delivery of up to 16DL-4UL in 25R3

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all

*** Test Cases ***
[1]CB012598-SR-A-06-Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    1S-4CC-16D8U_16Rx_CB012598-B    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_Auto_BTS_site_reset    with_call=${False}
    [Teardown]    SISO Coam Test Teardown

#[1]CB012196-SR-D-45-General_SiSo_Cell_block_and_unblock
#    [Tags]    3S-1CC-16D8U-8D8U_60M_4Rx_CB012196_8    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    #General_SiSo_Cell_block_and_unblock    with_call=${True}
#    ${fault_list}    Create List    49
#    Allowed Watchdog additional alarms    fault_list=${fault_list}
#    E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${True}
#    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
#    ...    AND    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
#    ...    AND    SISO Coam Test Teardown
