*** Settings ***
Library     String
Library     XML  use_lxml=True
Library     taf.sw.scout
Library     OperatingSystem
Library     Process
Library     SSHLibrary
Library     Collections
Library     taf.sbts.oam.coam.admin
Library     taf/rfrl/csv4all/CSV4AllTestCases.py

Documentation  Test suite for CSV4ALL Tests in loop.

Suite Setup   Run keywords
...  Set Testline Variables
...  AND  Map BuildShareTimi01

*** Variables ***
${REPORT}                 ${True}
${REPORT_COMMENT}=        ${None}
@{CUSTOMERS_LIST}         STC Saudi
${QC_DOMAIN}=             MN_RAN
${QC_PROJECT}=            RAN_VRF
${RP_CA}=                 VRF_OAM
${RP_LOCATION}=           VRF_TSR1
${RP_ORGANIZATION}=       VRF_TSR1_T02
#${EMAIL_RECIPIENTS}=      I_COMPA_TM@internal.nsn.com

${INITIAL_SW}             None
${TARGET_SW}              None

${SWR}=              3
${SBTS_RESET}=       20
${RF_RESET}=         20
${BBMOD_RESET}=      10
${CELL_LOCK}=        3
${DELTA_SCF}=        3

${ONLINE_PARAMETER_DELTA}=      /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1656/json/ONLINE_PARAMETER_DELTA.json
${SITE_RESET_DELTA}=      /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1656/json/SITE_RESET_DELTA.json
${NR_RAT_RESET_DELTA}=    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1656/json/NR_RAT_RESET_DELTA.json
${LTE_RAT_RESET_DELTA}=    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1656/json/LTE_RAT_RESET_DELTA.json
${WCDMA_RAT_RESET_DELTA}=    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1656/json/WCDMA_RAT_RESET_DELTA.json
${GSM_RAT_RESET_DELTA}=    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1656/json/GSM_RAT_RESET_DELTA.json


&{NODE1}  testline_object=${tl.enbs[0]}
...  source_sw=${INITIAL_SW}
...  target_sw=${TARGET_SW}

@{CUSTOM_ALLOWED}    4003  4681  7107  6278  6450  6150
@{NODES}    ${NODE1}


*** Test Cases ***
[1][1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]   24h
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...     nodes_details=${NODES}
    ...     test_nodes_details=${NODES}
    ...     iterations_per_node=${SWR}
    ...     customers_list=${CUSTOMERS_LIST}
    ...     report=${REPORT}
    ...     restore_to_target_sw=${True}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}

[1][1.0] [1]UUF_E2E_SW_Activation_reset
    [Timeout]   24h
    e2e_tl_activation_reset_test
    ...     nodes_details=${NODES}
    ...     test_nodes_details=${NODE1}
    ...     iterations_per_node=${SBTS_RESET}
    ...     customers_list=${CUSTOMERS_LIST}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}

[1][1.0] E2E_TL_RU_Reset_with_OAM_KPI
   [Timeout]   24h
   e2e_tl_ru_reset_with_oam_kpi
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${RF_RESET}
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}

[1][1.0] E2E_TL_Capacity_Module_Reset_with_OAM_KPI
   [Timeout]   24h
   e2e_tl_capacity_module_reset_with_oam_kpi
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${BBMOD_RESET}
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}


[1][1.0] E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    e2e_tl_cell_block_unblock_nr_with_oam_kpi
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...          iterations_per_node=${DELTA_SCF}
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}

[1][1.0] E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h
    e2e_tl_cell_block_unblock_nr_with_oam_kpi
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...          iterations_per_node=${DELTA_SCF}
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_project=${QC_PROJECT}
    ...          qc_domain=${QC_DOMAIN}

*** Keywords ***

Set Testline Variables
    Set Suite Variable  ${LABEL}    ${tl.tl_cloud_topology}
    ${HOSTNAME}  Fetch from right  ${CONFIGURATION}  .
    Set Suite Variable   ${HOSTNAME}
    ${list}  Evaluate  [enb.oam_ip for enb in $tl.enbs]
    FOR  ${enb}  IN  @{list}
      Run keyword if  $enb != None
      ...  Run Keywords  Set Suite Variable  ${MPLANE}  ${enb.v4}  AND
      ...  Exit for loop
    END
    Run Keyword If  ${INITIAL_SW}==${None}
    ...  Set Active Software
    Run Keyword If  ${TARGET_SW}==${None}
    ...  Set Suite Variable  ${TARGET_SW}  ${ENB_BUILD}
    Set Suite Variable  &{NODE1}  testline_object=${tl.enbs[0]}  source_sw=${INITIAL_SW}  target_sw=${TARGET_SW}
    Log  ${NODE1}  console=True
    Set Suite Variable  @{NODES}  &{NODE1}
    Log  @{NODES}  console=True


Set Active Software
    [Teardown]    Run Keyword and Ignore Error  Teardown  connection=active_sw
    Setup Admin  bts_host=192.168.255.129  alias=active_sw
    ${softwware_info}  Get Software Info  connection=active_sw
    ${INITIAL_SW}  Get From Dictionary  ${softwware_info}  Active SW version
    ${INITIAL_SW}  Run keyword if  '9999' in '${ENB_BUILD}' and '9999' in '${INITIAL_SW}'
    ...  Replace String Using Regexp  ${INITIAL_SW}  SBTS\\d{2}R\\d  SBTS00
    ...  ELSE
    ...  Set Variable  ${INITIAL_SW}
    Set Suite Variable  ${INITIAL_SW}


Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  SEPARATOR=  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/ cifs _netdev,
    ...  noperm,username=userbuild,,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
    Run  sudo cp -r /home/ute/testline_configuration/10_18_UTESRANCLOUD1656 /home/ute/