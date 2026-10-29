*** Settings ***
Documentation
...    Author:Chen Jun
...    contact:jun.8.chen@nokia-sbell.com
...    squad group:SG_06
...    Feature CB012591
Suite Setup    SISO Coam Suite Setup For 12591
Suite Teardown    SISO Coam Suite Teardown
Test Setup    SISO Coam Test Setup For 12591
Test Teardown     SISO Coam Test Teardown For 12591

Resource    Resources/CB012591_common.robot


*** Test Cases ***
[1]CB012591-A_7_B3_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    CB012591-A_7_B3_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

[1]CB012591-A_9_B3_E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    CB012591-A_9_B3_E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call

[1]CB012591-A_4_B3_Manual_SiSo_SM_Cell_Block_Unblock
    CB012591-A_4_B3_Manual_SiSo_SM_Cell_Block_Unblock

[1]CB012591-A_6_Concurrent_mode_NR_TDD_eCPRI7-2e_and_7-2a_Baseband_resource_pooling
    [Tags]    CRT    AVQC_1S-4CC
    CB012591-A_6_Concurrent_mode_NR_TDD_eCPRI7-2e_and_7-2a_Baseband_resource_pooling

