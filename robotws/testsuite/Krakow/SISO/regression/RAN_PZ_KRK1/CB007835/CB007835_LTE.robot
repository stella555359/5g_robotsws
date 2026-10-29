*** Settings ***
Documentation
...   Test suite for regression testing of feature CB007835
...   author: Piotr Bacior, 
...   contact: piotr.bacior@nokia.com, 

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot
Variables    ./resources/variables.py

Force Tags    CA_VRF_KRK

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               should_LTE_neighbour_be_changed=${True}
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions
Test Teardown     Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
############### OAM and UUF #########################
@{CUSTOMERS_LIST}=      USCC
@{CRITICAL_FAULTS}=     0010  0016  1806  1868  4341  4352  4383
@{CUSTOM_ALARMS}=       4003  6327

${UPDATE_TEST_ITERATION}            3
${SITE_RESET_TEST_ITERATION}        20

${SHOULD_BE_REPORTED}=  True
${5G_SOURCE_SW}=        ${None}
${5G_TARGET_SW}=        ${None}
${4G_SOURCE_SW}=        ${None}
${4G_TARGET_SW}=        ${None}
${UPDATE_TEST_FAILED}   ${False}
${QC_DOMAIN}=           MN_RAN
${QC_PROJECT}=          RAN_ST
*** Test Cases ***
[1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI_LTE
    [Timeout]    24h
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${UPDATE_TEST_ITERATION}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          5g_source_sw=${5G_SOURCE_SW}
    ...          5g_target_sw=${5G_TARGET_SW}
    ...          4g_source_sw=${4G_SOURCE_SW}
    ...          4g_target_sw=${4G_TARGET_SW}
    ...          use_builds_storage=${False}
    ...          restore_to_target_sw=${True}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids_4g['qc_upgrade']}
    ...          qc_project=${QC_PROJECT}

    [Teardown]   Custom Test Teardown

[1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI_LTE
    [Timeout]    24h
    UUF4ALL_SITE_RESET_TEST
    ...          test_iteration=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids_4g['qc_site_reset']}
    ...          qc_project=${QC_PROJECT}

[1.0] E2E_TL_Capacity_Module_Reset_with_OAM_KPI_LTE
    OAM_BBMOD_RESET
    ...          test_iteration=10
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          should_be_reported=True
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids_4g['qc_capacity_reset']}
    ...          qc_project=${QC_PROJECT}

[1.0] E2E_TL_RU_Reset_with_OAM_KPI_LTE
    OAM_RMOD_RESET
    ...          test_iteration=20
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          should_be_reported=True
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids_4g['qc_ru_reset']}
    ...          qc_project=${QC_PROJECT}

[1.0] E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    OAM_LNCEL_BLOCK
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          should_be_reported=True
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids_4g['qc_cell_block_unblock']}
    ...          qc_project=${QC_PROJECT}

[1.0] E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    OAM_LNCEL_LOCK
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          should_be_reported=True
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${kpi_qc_ids_4g['qc_cell_lock_unlock']}
    ...          qc_project=${QC_PROJECT}
    
[1.0] CB007834-5G-11_Commisioning_with_site_reset_LTE
    DELTA_COMMISSIONING_WITH_SITE_RESET_REQUIRED
    ...          test_iteration=1
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          should_be_reported=True
    ...          critical_faults=${CRITICAL_FAULTS}

[1.0] CB007834-5G-12_Commisioning_online_change_LTE
    DELTA_COMMISSIONING_WITH_ONLINE_PARAMETER_MODIFICATION
    ...          test_iteration=1
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          should_be_reported=True
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          critical_faults=${CRITICAL_FAULTS}

[1.0] E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Timeout]   24h
    DELTA_COMMISSIONING_WITH_LTE_RAT_RESET
    ...          test_iteration=1
    ...          delta_file=./resources/delta_LTE.json
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          should_be_reported=True
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          critical_faults=${CRITICAL_FAULTS}

*** Keywords ***
Custom Test Teardown
    Run Keyword If Test Failed    Set Suite Variable  ${UPDATE_TEST_FAILED}  ${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
