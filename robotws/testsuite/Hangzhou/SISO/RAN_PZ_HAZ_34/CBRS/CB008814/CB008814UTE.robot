*** Settings ***
Suite Setup          CBRS UTE Upgrade Suite Setup    UTECloud=True
Suite Teardown       CBRS Suite Teardown
Test Setup           CBRS Test Setup
Test Teardown        CBRS Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    resources/CB008184_common_keywords.robot

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB008814

Force Tags    RAN_5G_TDD    5G_RAN_TDD    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED    SBTS00
...    PY36
...    CLOUD_5G_CLASSICAL_SA_ASOE_AWHQU_HAZ

*** Test Cases ***
[1][1.0] Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    CRT_TRUNK
    CB008814_Manual_SiSo_SM_BTS_Site_Reset

[1]CB008814-AC_2_Online_add_one_higher_priority_CBRS_cell_when_only_20MHz_channel_block_available_2CC
    [Tags]    CRT_TRUNK
    CB008814-AC_2_Online_add_one_higher_priority_CBRS_cell_when_only_20MHz_channel_block_available_2CC
