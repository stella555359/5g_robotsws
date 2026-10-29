*** Settings ***
Documentation
...   author: Marcin Ceglarek
...   contact: marcin.ceglarek@nokia.com
...   Test suite for basic UUF OAM Tests in loop:


Resource       taf/rfrl/uuf4all/uuf4all_test_cases.robot
Force Tags     CA_RAN_PZ_WRO_4  PY36

*** Variables ***
${TEST_ITERATION}=              1
@{CUSTOM_ALARMS}=               @{EMPTY}
${REMOTE_VM_IP}=                ${None}
${REMOTE_MPLANE}=               ${None}
${LABEL}=                       ${None}
${HOSTNAME}=                    ${None}
@{CRITICAL_FAULTS}=             @{EMPTY}
${SHOULD_BE_REPORTED}=          False
@{CUSTOMERS_LIST}=              Generic
${5G_SOURCE_SW}=                SBTS00_ENB_9999_230113_000004
${5G_TARGET_SW}=                SBTS00_ENB_9999_230119_000011
${5G_TARGET_SW_PATH}=           ${None}
${4G_SOURCE_SW}=                SBTS00_ENB_9999_230113_000004
${4G_TARGET_SW}=                SBTS00_ENB_9999_230119_000011
${4G_TARGET_SW_PATH}=           ${None}
${REMOTE_NODE_UPDATE}=          ${True}
${USE_REMOTE_NODE}=             ${True}
${DOWNLOAD_PATH}=               ${None}
${USE_BUILDS_STORAGE}=          ${True}
${RESTORE_TARGET_SW}=           ${True}
${ONLINE_PARAMETER_DELTA}=
${SITE_RESET_DELTA}=
${NR_RAT_RESET_DELTA}=
${LTE_RAT_RESET_DELTA}=
${WCDMA_RAT_RESET_DELTA}=
${GSM_RAT_RESET_DELTA}=

*** Test Cases ***
E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    UUF4ALL_SITE_RESET_TEST
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          use_remote_node=${USE_REMOTE_NODE}

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          5g_source_sw=${5G_SOURCE_SW}
    ...          5g_target_sw=${5G_TARGET_SW}
    ...          5g_target_sw_path=${5G_TARGET_SW_PATH}
    ...          4g_source_sw=${4G_SOURCE_SW}
    ...          4g_target_sw=${4G_TARGET_SW}
    ...          4g_target_sw_path=${4G_TARGET_SW_PATH}
    ...          use_builds_storage=${USE_BUILDS_STORAGE}
    ...          restore_to_target_sw=${RESTORE_TARGET_SW}
    ...          remote_node_update=${REMOTE_NODE_UPDATE}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          use_test_packages=${False}
    ...          download_path=${DOWNLOAD_PATH}


E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    OAM_RMOD_RESET
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    OAM_BBMOD_RESET
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    OAM_NRCEL_LOCK
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   24h
    OAM_LNCEL_LOCK
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}

E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Timeout]   24h
    OAM_LNCEL_BLOCK
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h
    OAM_NRCEL_BLOCK
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    DELTA_COMMISSIONING_WITH_ONLINE_PARAMETER_MODIFICATION
    ...          test_iteration=${TEST_ITERATION}
    ...          delta_file=${ONLINE_PARAMETER_DELTA}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    DELTA_COMMISSIONING_WITH_SITE_RESET_REQUIRED
    ...          test_iteration=${TEST_ITERATION}
    ...          delta_file=${SITE_RESET_DELTA}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   24h
    DELTA_COMMISSIONING_WITH_NR_RAT_RESET
    ...          test_iteration=${TEST_ITERATION}
    ...          delta_file=${NR_RAT_RESET_DELTA}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}

E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Timeout]   24h
    DELTA_COMMISSIONING_WITH_LTE_RAT_RESET
    ...          test_iteration=${TEST_ITERATION}
    ...          delta_file=${LTE_RAT_RESET_DELTA}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}

