*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_SRAN_N_10687_1ASIM_2ABIP_2AVQA_1AHPB_1AHPJ  STATE_SKIP_AGENT
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
# --- UUF
${REPORT}                 ${True}
${REPORT_COMMENT}=        ${None}
@{CUSTOMERS_LIST}         TMO US
${QC_DOMAIN}=             MN_RAN
${QC_PROJECT}=            RAN_VRF
${RP_CA}=                 VRF_OAM
${RP_LOCATION}=           VRF_TSR
${RP_ORGANIZATION}=       VRF_TSR_T05
${EMAIL_RECIPIENTS}=      None
${INITIAL_SW}             None
${TARGET_SW}              None

${SWR}=              1      #2
${SBTS_RESET}=       1      #20

@{CUSTOM_ALLOWED}    4003  4681  7107  7115  7319  7300


*** Test Cases ***
_1_E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI__NODES
    [Tags]  QC_242826
    [Timeout]   24h
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...     nodes_details=${NODES}
    ...     test_nodes_details=${NODE1}
    ...     iterations_per_node=${SWR}
    ...     customers_list=${CUSTOMERS_LIST}
    ...     report=${REPORT}
    ...     restore_to_target_sw=${True}
#    ...     qc_domain=${QC_DOMAIN}
#    ...     qc_project=${QC_PROJECT}
#    ...     qc_id=${227635}

_2_E2E_TL_ACTIVATION_RESET_TEST__NODE1
    [Tags]  QC_83930
    [Timeout]   24h
    e2e_tl_activation_reset_test
   ...     nodes_details=${NODES}
    ...     test_nodes_details=${NODE1}
    ...     iterations_per_node=${SBTS_RESET}
    ...     customers_list=${CUSTOMERS_LIST}
    ...     report=${REPORT}
#    ...     qc_domain=${QC_DOMAIN}
#    ...     qc_project=${QC_PROJECT}
#    ...     qc_id=${227635}


*** Keywords ***

Set Testline Variables
#    Set Suite Variable  ${LABEL}    ${tl.tl_cloud_topology}
    ${HOSTNAME}  Fetch from right  ${CONFIGURATION}  .
#    Set Suite Variable   ${HOSTNAME}
    ${list}  Evaluate  [enb.oam_ip for enb in $tl.enbs]
    FOR  ${enb}  IN  @{list}
      Run keyword if  $enb != None
      ...  Run Keywords  Set Suite Variable  ${MPLANE}  ${enb.v4}  AND
      ...  Exit for loop
    END
    Run Keyword If  '${INITIAL_SW}'=='${None}'
    ...  Set Active Software
    Run Keyword If  '${TARGET_SW}'=='${None}'
    ...  Set Suite Variable  ${TARGET_SW}  ${ENB_BUILD}
    ${NODE1}    Create Dictionary    testline_object=${tl.enbs[0]}  source_sw=${INITIAL_SW}  target_sw=${TARGET_SW}
    ...  custom_allowed_alarms=${CUSTOM_ALLOWED}
    Set Suite Variable  ${NODE1}
    Log  ${NODE1}  console=True
    Set Suite Variable  @{NODES}  ${NODE1}
    Log  ${NODES}  console=True

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
    Run  sudo cp -r /home/ute/testline_configuration/10_18_UTESRANCLOUD1818 /home/ute/
