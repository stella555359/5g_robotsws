*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         12h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource    ./Resource/CB009125_common_keywords.robot

Documentation
...    Author:zhihao shi
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB009125 in trunk program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED
...   PY36

*** Variables ***
${if_commissioning}   True

*** Test Cases ***
# TL593 1S-1CC-8D-4U
[1]CB009125_SR_F_c_AQQY_07_General_SiSo_Cell_block_and_unblock
    [Tags]    1S-1CC-8D-4U
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_Cell_block_and_unblock

[1]CB009125_SR_F_c_AQQY_10_General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Tags]    1S-1CC-8D-4U
    L3 Call Both NR and LTE    lte_dl_tp=123.2    lte_ul_tp=11.6
    ...    target_avg_percent=0.3    min_percent=0.1

*** Keywords ***

