*** Settings ***
Library     String
Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot

Suite Setup  Set Testline Variables
Force Tags     CA_VRF_TSR1  PY36

*** Variables ***
${TEST_ITERATION}=              100
@{CUSTOM_ALARMS}=               4003    4681    7107    7115
${REMOTE_VM_IP}=                ${None}
${REMOTE_MPLANE}=               ${None}
${LABEL}=                       ${None}
${HOSTNAME}=                    ${None}
@{CRITICAL_FAULTS}=             @{EMPTY}
${SHOULD_BE_REPORTED}=          True
@{CUSTOMERS_LIST}=              Generic
${5G_SOURCE_SW}=                ${None}
${5G_TARGET_SW}=                ${None}
${5G_TARGET_SW_PATH}=           ${None}
${4G_SOURCE_SW}=                ${None}
${4G_TARGET_SW}=                ${None}
${4G_TARGET_SW_PATH}=           ${None}
${REMOTE_NODE_UPDATE}=          ${True}
${USE_REMOTE_NODE}=             ${True}
${DOWNLOAD_PATH}=               ${None}
${USE_BUILDS_STORAGE}=          ${False}
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
    ${5G_SOURCE_SW}  Run keyword if  '9999' in '${ENB_BUILD}' and '9999' in '${5G_SOURCE_SW}'
    ...  Replace String Using Regexp  ${5G_SOURCE_SW}  SBTS\\d{2}R\\d  SBTS00
    ...  ELSE
    ...  Set Variable  ${5G_SOURCE_SW}
    Set Suite Variable  ${5G_SOURCE_SW}
