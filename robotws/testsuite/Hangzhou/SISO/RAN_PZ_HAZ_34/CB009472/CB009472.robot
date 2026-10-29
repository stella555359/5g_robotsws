*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}    is_ru_log_collecting_enable=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         200 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_Stability_Test_Case.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot

Documentation
...    Author:Dai Xiangying
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB009472 in trunk program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASIM_3xABIP_AQQY
...   PY36

*** Variables ***

*** Test Cases ***
# TL597 1S-3CC-8D-4U(TSN loglink(1)  ASIM+3*ABIP+/AQQY(3CC-50+50+50MHZ))
[1]CB009472_US11_AQQY_07_OAM_KPI_SiSo_AUTO_BTS_Site_Reset
    [Timeout]    8h
    ${fault_list}    Create List    16
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_Auto_BTS_site_reset  with_call=${True}  ue_cell_id=${3}  MAX_LOOP=${3}

# TL597 1S-3CC-8D-4U(TSN cablink(3)  ASIM+3*ABIP+/AQQY(3CC-100+50+50MHZ))
[1]CB009472_US11_AQQY_09_3TSN_General_SiSo_Cell_block_and_unblock
    [Tags]    RF50
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    E2E_SiSo_Cell_block_and_unblock_gNB  with_peak=${True}
