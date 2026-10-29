*** Settings ***
Documentation
...   author: Lukasz Klosinski
...   contact: lukasz.klosinski@nokia.com
...   Test suite for basic UUF OAM Tests in loop:


Resource       taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource       testsuite/Timisoara/SBTS/UE/test_resources/UE__GSM_PS_call.robot
Resource       testsuite/Timisoara/SBTS/UE/test_resources/UE__WCDMA_PS_call.robot
Resource       testsuite/Timisoara/SBTS/UE/test_resources/UE__LTE_PS_call.robot
Resource       testsuite/Timisoara/SBTS/UE/test_resources/UE__NR_PS_call.robot
# Resource or Library import with L3 Call Test Keyword
Force Tags     CA_RAN_PZ_WRO_2  PY36

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
${5G_SOURCE_SW}=                SBTS22R4_ENB_0000_000607_000000
${5G_TARGET_SW}=                SBTS00_ENB_9999_221004_000006
${5G_TARGET_SW_PATH}=           ${None}
${4G_SOURCE_SW}=                SBTS22R4_ENB_0000_000607_000000
${4G_TARGET_SW}=                SBTS00_ENB_9999_221004_000006
${4G_TARGET_SW_PATH}=           ${None}
${REMOTE_NODE_UPDATE}=          ${True}
${USE_REMOTE_NODE}=             ${True}
${DOWNLOAD_PATH}=               ${None}
${USE_BUILDS_STORAGE}=          ${True}
${RESTORE_TARGET_SW}=           ${True}


*** Test Cases ***
E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_WITH_L3_CALL
    [Timeout]   24h
    UUF4ALL_SITE_RESET_TEST
    ...          test_iteration=${TEST_ITERATION}
    ...          attach_test_keyword=TC__UE__GSM_PS_call
    ...          attach_test_keyword=TC__UE__WCDMA_PS_call
    ...          attach_test_keyword=TC__UE__LTE_PS_call
    ...          attach_test_keyword=TC__UE__NR_PS_call
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
    ...          attach_test_keyword=TC__UE__GSM_PS_call
    ...          attach_test_keyword=TC__UE__WCDMA_PS_call
    ...          attach_test_keyword=TC__UE__LTE_PS_call
    ...          attach_test_keyword=TC__UE__NR_PS_call
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
    ...          download_path=${DOWNLOAD_PATH}


E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    OAM_RMOD_RESET
    ...          test_iteration=${TEST_ITERATION}
    ...          attach_test_keyword=TC__UE__GSM_PS_call
    ...          attach_test_keyword=TC__UE__WCDMA_PS_call
    ...          attach_test_keyword=TC__UE__LTE_PS_call
    ...          attach_test_keyword=TC__UE__NR_PS_call
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    OAM_BBMOD_RESET
    ...          test_iteration=${TEST_ITERATION}
    ...          attach_test_keyword=TC__UE__GSM_PS_call
    ...          attach_test_keyword=TC__UE__WCDMA_PS_call
    ...          attach_test_keyword=TC__UE__LTE_PS_call
    ...          attach_test_keyword=TC__UE__NR_PS_call
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}


*** Keywords ***
Set Testline Variables
    Set Suite Variable  ${LABEL}    ${tl.tl_cloud_topology}
    #Set Suite Variable  ${VM_IP}    ${tl.test_pc.default_ssh_connection_details.addr}
    #Set Suite Variable  ${REMOTE_VM_IP}  ${VM_IP}
    ${HOSTNAME}  Fetch from right  ${CONFIGURATION}  .
    Set Suite Variable   ${HOSTNAME}
    ${list}  Evaluate  [enb.oam_ip for enb in $tl.enbs]
    FOR  ${enb}  IN  @{list}
      Run keyword if  $enb != None
      ...  Run Keywords  Set Suite Variable  ${MPLANE}  ${enb.v4}  AND
      ...  Exit for loop
    END
    Run Keyword If  ${5G_SOURCE_SW}==${None}
    ...  Set Active Software
    Run Keyword If  ${5G_TARGET_SW}==${None}
    ...  Set Suite Variable  ${5G_TARGET_SW}  ${ENB_BUILD}


Set Active Software
    [Teardown]    Run Keyword and Ignore Error  Teardown  connection=active_sw
    Setup Admin  bts_host=192.168.255.129  alias=active_sw
    ${softwware_info}  Get Software Info  connection=active_sw
    ${5G_SOURCE_SW}  Get From Dictionary  ${softwware_info}  Active SW version
    ${5G_SOURCE_SW}  Run keyword if  '9999' in '${ENB_BUILD}'
    ...  Replace String Using Regexp  ${5G_SOURCE_SW}  SBTS\\d{2}R\\d  SBTS00
    ...  ELSE
    ...  Set Variable  ${5G_SOURCE_SW}
    Set Suite Variable  ${5G_SOURCE_SW}