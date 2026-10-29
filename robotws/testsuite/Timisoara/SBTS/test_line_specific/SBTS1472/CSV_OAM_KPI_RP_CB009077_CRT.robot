*** Settings ***
Library     String
Library     XML  use_lxml=True
Library     taf.sw.scout

Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource    ../../LOGS/LOGS__CB009077_CLI_Command_Check.robot
Resource    ../../LOGS/LOGS__CB009077_EutranAccessPointPosition_Parameters_Check.robot

Documentation  plm.

Suite Setup   Run keywords
...  Set Testline Variables
...  AND  Set Library Search Order  coam  admin  ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general
...  AND  Map BuildShareTimi01

Force Tags     CA_VRF_TSR1  PY36


*** Variables ***
${TEST_ITERATION}=              3
${ENB_BUILD}=                   SBTS25R1_ENB_0000_000509_000032
@{CUSTOM_ALARMS}=               4003    4681    7107    6278
${REMOTE_VM_IP}=                ${None}
${REMOTE_MPLANE}=               ${None}
${LABEL}=                       ${None}
${HOSTNAME}=                    ${None}
@{CRITICAL_FAULTS}=             @{EMPTY}
${SHOULD_BE_REPORTED}=          True
@{CUSTOMERS_LIST}=              Mobily
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
${ONLINE_PARAMETER_DELTA}=      /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1472/json/ONLINE_PARAMETER_DELTA.json
${SITE_RESET_DELTA}=      /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1472/json/SITE_RESET_DELTA.json
${NR_RAT_RESET_DELTA}=    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1472/json/NR_RAT_RESET_DELTA.json
${LTE_RAT_RESET_DELTA}=    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1472/json/LTE_RAT_RESET_DELTA.json
${WCDMA_RAT_RESET_DELTA}=    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1472/json/WCDMA_RAT_RESET_DELTA.json
${GSM_RAT_RESET_DELTA}=    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1472/json/GSM_RAT_RESET_DELTA.json
${QC_DOMAIN}=           MN_RAN
${QC_PROJECT}=          RAN_VRF
${TEST_QC_ID}=  ${None}  # SHOULD BE DIFFERENT FOR EACH TEST CASE ACCORDING TO QC_ID OF EACH TEST
#${default_scf_path}    ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T2090/
${PERFORM_UBOOT_DOWNGRADE}=     ${True}
@{USER_SUSPICIOUS_PRINTS}=      @{EMPTY}
${SCF_ID}=                      01
${HW_LOCATION_CODE}=            Timisoara
${COMMISSIONING_PATH}=    /home/ute/testline_configuration/10_18_UTESRANCLOUD1472/node1/BTS_CLOUD_SRAN_L_10472_1ASIB_3ABIC_3AEHC_SBTS00.xml
${REQUEST_SCF_SCOUT}=           ${TRUE}
${SCOUT_TL_NAME}=               MRBTS-10472



*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    ${TEST_QC_ID}=    Set Variable   46698
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
#    ...          use_test_packages=${False}
    ...          download_path=${DOWNLOAD_PATH}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}


E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    ${TEST_QC_ID}=    Set Variable   37411
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
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}


E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    ${TEST_QC_ID}=    Set Variable   37405
    OAM_BBMOD_RESET
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}


E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   24h
    ${TEST_QC_ID}=    Set Variable   37407
    OAM_LNCEL_LOCK
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}


E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Timeout]   24h
    ${TEST_QC_ID}=    Set Variable   37406
    OAM_LNCEL_BLOCK
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}


E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    ${TEST_QC_ID}=    Set Variable   37410
    DELTA_COMMISSIONING_WITH_ONLINE_PARAMETER_MODIFICATION
    ...          test_iteration=${TEST_ITERATION}
    ...          delta_file=${ONLINE_PARAMETER_DELTA}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}


E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    ${TEST_QC_ID}=    Set Variable   37412
    DELTA_COMMISSIONING_WITH_SITE_RESET_REQUIRED
    ...          test_iteration=${TEST_ITERATION}
    ...          delta_file=${SITE_RESET_DELTA}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}


E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Timeout]   24h
    ${TEST_QC_ID}=    Set Variable   37409
    DELTA_COMMISSIONING_WITH_LTE_RAT_RESET
    ...          test_iteration=${TEST_ITERATION}
    ...          delta_file=${LTE_RAT_RESET_DELTA}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}


[1]Automated__LOGS__CB009077_CLI_Command_Check
    [Setup]    Run Keywords   Set Library Search Order    LOGS__CB009077_CLI_Command_Check   uuf4all_test_cases
	...    AND   LOGS__CB009077_CLI_Command_Check.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB009077_CLI_Command_Check
    [Timeout]    14400
    TC__LOGS__CB009077_CLI_Command_Check
    [Teardown]    Run Keywords    Set Library Search Order    LOGS__CB009077_CLI_Command_Check   uuf4all_test_cases
	...    AND    LOGS__CB009077_CLI_Command_Check.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB009077_EutranAccessPointPosition_Parameters_Check
    [Setup]    Run Keywords    Set Library Search Order    LOGS__CB009077_EutranAccessPointPosition_Parameters_Check   uuf4all_test_cases
	...    AND    LOGS__CB009077_EutranAccessPointPosition_Parameters_Check.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB009077_EutranAccessPointPosition_Parameters_Check
    [Timeout]    14400
    TC__LOGS__CB009077_EutranAccessPointPosition_Parameters_Check
    [Teardown]    Run Keywords    Set Library Search Order    LOGS__CB009077_EutranAccessPointPosition_Parameters_Check   uuf4all_test_cases
	...    AND    LOGS__CB009077_EutranAccessPointPosition_Parameters_Check.TC Teardown
    ...    AND    Restore Resource Search Order



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
    coam.Setup Admin  bts_host=192.168.255.129  alias=active_sw
    ${softwware_info}  coam.Get Software Info  connection=active_sw
    ${5G_SOURCE_SW}  Get From Dictionary  ${softwware_info}  Active SW version
    ${5G_SOURCE_SW}  Run keyword if  '9999' in '${ENB_BUILD}' and '9999' in '${5G_SOURCE_SW}'
    ...  Replace String Using Regexp  ${5G_SOURCE_SW}  SBTS\\d{2}R\\d  SBTS00
    ...  ELSE
    ...  Set Variable  ${5G_SOURCE_SW}
    Set Suite Variable  ${5G_SOURCE_SW}


Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  SEPARATOR=  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/ cifs _netdev,
    ...  noperm,username=userbuild,,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
    Run  sudo cp -r /home/ute/testline_configuration/10_18_UTESRANCLOUD1472 /home/ute/

#Commit Full SCF
#    Connect to gnb coam via ssl
#    ${scf_name}    Decide Scf name
#   COAM Commission with scf file    scf_file_path=${default_scf_path}${scf_name}   is_pdl_checking_needed=${False}    timeout=900
#       Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
