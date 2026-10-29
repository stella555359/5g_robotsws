*** Settings ***
Documentation
...   Test suite for regression testing of feature CB007835
...   author: Sara Nowak
...   contact: sara.nowak@nokia.com

Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Library      testsuite/Krakow/resources/UUF/upgrade_and_commission_bts.py
Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    resources/variables.py

Force Tags    STATE_SKIP_AGENT    RAN_5G    PY39    CLOUD_5G_CLASSICAL_QC_ASIBR_ABILB1_3xAHHB_ENB    CDRT
...     CA_RAN_PZ_KRK

Suite Setup       Run Keywords
...               common_setups_and_teardowns.Common Suite Setup With Commissioning  prefix_tag=FULL
...               AND
...               Set Source and Target Build Variables
...               AND
...               Upgrade and Commission Gnb   sw_build=${5G_SOURCE_SW}

Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Common Preconditions
Test Teardown     Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
@{customers}             AMX Argentina
${remote_vm_ip}          ${None}
${5g_source_sw}          ${None}
${5g_target_sw}          ${None}
${5g_target_sw_path}     /home/ute/UUF_SW/
${runs_of_uuf_upgrade}   ${3}
@{critical_faults}       0010  0016  1806  1868  4341  4352  4383
${QC_DOMAIN}             MN_RAN
${QC_PROJECT}            RAN_ST
@{CUSTOM_ALARMS}=        62003

*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    UUF4ALL_SW_UPGRADE_TEST
    ...    test_iteration=${runs_of_uuf_upgrade}
    ...    customers_list=${customers}
    ...    critical_faults=@{critical_faults}
    ...    5g_source_sw=${5g_source_sw}
    ...    5g_target_sw=${5g_target_sw}
    ...    5g_target_sw_path=${5g_target_sw_path}
    ...    use_builds_storage=${False}
    ...    restore_to_target_sw=${True}
    ...    custom_alarms=${CUSTOM_ALARMS}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_upgrade']}
    ...    qc_project=${QC_PROJECT}
