*** Settings ***
Documentation
...   author: Tomasz Fojtar
...   contact: tomasz.fojtar@nokia.com
...   Test suite for basic UUF OAM Tests in loop:

Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot
#./../../../../../../
Force Tags    CA_RAN_PZ_WRO_4

*** Variables ***
${TEST_ITERATION}=              ${None}
@{CUSTOM_ALARMS}=               @{6327,6322,4681,1838}
${REMOTE_VM_IP}=                10.42.121.251
${REMOTE_MPLANE}=               10.44.166.85
${LABEL}=                       WRO9_E2E_2xASIB_4xABIO_1xABIA_3xAEQE_3xAHPCDB_6xAHEGC
${HOSTNAME}=                    ${None}
@{CRITICAL_FAULTS}=             @{EMPTY}
${SHOULD_BE_REPORTED}=          True
@{CUSTOMERS_LIST}=              TPG Telecom
${5G_SOURCE_SW}=                SBTS22R3_ENB_0000_001379_000000
${5G_TARGET_SW}=                SBTS22R3_ENB_0000_001379_000018
${5G_TARGET_SW_PATH}=           ${None}
${4G_SOURCE_SW}=                SBTS22R3_ENB_0000_001379_000000
${4G_TARGET_SW}=                SBTS22R3_ENB_0000_001379_000018
${4G_TARGET_SW_PATH}=           ${None}
${REMOTE_NODE_UPDATE}=          False
${USE_REMOTE_NODE}=             True
${ONLINE_PARAMETER_DELTA}=
${SITE_RESET_DELTA}=
${NR_RAT_RESET_DELTA}=
${LTE_RAT_RESET_DELTA}=
${WCDMA_RAT_RESET_DELTA}=
${GSM_RAT_RESET_DELTA}=

*** Test Cases ***
#E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
#    [Timeout]   24h
#    OAM_LNCEL_LOCK
#    ...          test_iteration=${TEST_ITERATION}
#    ...          custom_alarms=@{CUSTOM_ALARMS}
#    ...          critical_faults=@{CRITICAL_FAULTS}
#    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    ...          customers_list=@{CUSTOMERS_LIST}
#
#E2E_TL_Cell_Block_Unlock_LTE_with_OAM_KPI
#    [Timeout]   24h
#    OAM_LNCEL_BLOCK
#    ...          test_iteration=3
#    ...          custom_alarms=@{CUSTOM_ALARMS}
#    ...          critical_faults=@{CRITICAL_FAULTS}
#    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    ...          customers_list=@{CUSTOMERS_LIST}

#E2E_TL_Cell_Block_Unlock_WCDMA_with_OAM_KPI
#    [Timeout]   24h
#    OAM_WNCEL_BLOCK
#    ...          test_iteration=${TEST_ITERATION}
#    ...          custom_alarms=@{CUSTOM_ALARMS}
#    ...          critical_faults=@{CRITICAL_FAULTS}
#    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    ...          customers_list=@{CUSTOMERS_LIST}
#
#
#E2E_TL_RU_Reset_with_OAM_KPI
#    [Timeout]   24h
#    OAM_RMOD_RESET
#    ...          test_iteration=${TEST_ITERATION}
#    ...          custom_alarms=@{CUSTOM_ALARMS}
#    ...          critical_faults=@{CRITICAL_FAULTS}
#    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    ...          customers_list=@{CUSTOMERS_LIST}
#
#E2E_TL_Capacity_Module_Reset_with_OAM_KPI
#    [Timeout]   24h
#    OAM_BBMOD_RESET
#    ...          test_iteration=${TEST_ITERATION}
#    ...          custom_alarms=@{CUSTOM_ALARMS}
#    ...          critical_faults=@{CRITICAL_FAULTS}
#    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    ...          customers_list=@{CUSTOMERS_LIST}
#

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=3
    ...          custom_alarms=@{CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          5g_source_sw=${5G_SOURCE_SW}
    ...          5g_target_sw=${5G_TARGET_SW}
    ...          5g_target_sw_path=${5G_TARGET_SW_PATH}
    ...          4g_source_sw=${4G_SOURCE_SW}
    ...          4g_target_sw=${4G_TARGET_SW}
    ...          4g_target_sw_path=${4G_TARGET_SW_PATH}
    ...          use_builds_storage=${False}
    ...          restore_to_target_sw=${False}
    ...          remote_node_update=${REMOTE_NODE_UPDATE}
    ...          use_remote_node=${USE_REMOTE_NODE}
#
#E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
#    UUF4ALL_SW_UPGRADE_TEST
#    ...          test_iteration=1
#    ...          custom_alarms=@{CUSTOM_ALARMS}
#    ...          remote_vm_ip=${REMOTE_VM_IP}
#    ...          remote_mplane=${REMOTE_MPLANE}
#    ...          label=${LABEL}
#    ...          hostname=${HOSTNAME}
#    ...          critical_faults=@{CRITICAL_FAULTS}
#    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    ...          customers_list=@{CUSTOMERS_LIST}
#    ...          5g_source_sw=${5G_SOURCE_SW}
#    ...          5g_target_sw=${5G_TARGET_SW}
#    ...          5g_target_sw_path=${5G_TARGET_SW_PATH}
#    ...          4g_source_sw=${4G_SOURCE_SW}
#    ...          4g_target_sw=${4G_TARGET_SW}
#    ...          4g_target_sw_path=${4G_TARGET_SW_PATH}
#    ...          use_builds_storage=${False}
#    ...          restore_to_target_sw=${True}
#    ...          remote_node_update=${REMOTE_NODE_UPDATE}
#    ...          use_remote_node=${USE_REMOTE_NODE}

#E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
#    [Timeout]   24h
#    UUF4ALL_SITE_RESET_TEST
#    ...          test_iteration=20
#    ...          custom_alarms=@{CUSTOM_ALARMS}
#    ...          critical_faults=@{CRITICAL_FAULTS}
#    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    ...          customers_list=@{CUSTOMERS_LIST}
#
#


