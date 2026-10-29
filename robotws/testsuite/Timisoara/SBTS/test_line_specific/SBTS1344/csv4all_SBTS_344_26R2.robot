*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_SRAN_LG_10344_1ASIA_2ABIA_3AHEGC_2FXDB_1ARMA  STATE_SKIP_AGENT
Library     String
Library     XML  use_lxml=True
Library     taf.sw.scout
Library     OperatingSystem
Library     Process
Library     SSHLibrary
Library     Collections
#Library     taf.sbts.oam.coam.admin
Library     taf/rfrl/csv4all/CSV4AllTestCases.py
Resource    ../../COMPA/test_resources/COMPA__Update_CMP_IPSEC_certificates_on_SBTS.robot
Resource    ../../CIT/test_resources/SWM__SCF_validation_errors_check.robot
Resource    ../../CIT/test_resources/SWM__Upload_swconfig.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Planned_commissioning.robot

Resource    ../../FM/test_resources/FM__link_break_Abis_long.robot
Resource    ../../FM/test_resources/FM__link_break_Abis_short.robot
Resource    ../../FM/test_resources/FM__link_break_Abis_startup.robot
Resource    ../../FM/test_resources/FM__link_break_SBTS_short.robot

Resource    ../../UE/test_resources/UE__NR_NSA_PS_call.robot
Resource    ../../UE/test_resources/UE__NR_SA_PS_call.robot
Resource    ../../UE/test_resources/UE__LTE_PS_call.robot
Resource    ../../UE/test_resources/UE__GSM_PS_call.robot
Resource    ../../UE/test_resources/UE__GSM_Voice_call.robot
Resource    ../../UE/test_resources/UE__NR_NSA_TCP_PS_call.robot
Resource    ../../UE/test_resources/UE__NR_SA_TCP_PS_call.robot
Resource    ../../UE/test_resources/UE__LTE_TCP_PS_call.robot
Resource    ../../UE/test_resources/UE__GSM_TCP_PS_call.robot

Resource    ../../CIT/test_resources/SWM__Check_swconfig_file_presence.robot

Documentation  Test suite for CSV4ALL Tests in loop.

Suite Setup   Run keywords
...  Set Testline Variables
...  AND  Map BuildShareTimi01

*** Variables ***
# --- UUF
${REPORT}                 ${True}
${REPORT_COMMENT}=        ${None}
@{CUSTOMERS_LIST}         ZAIN
${QC_DOMAIN}=             MN_RAN
${QC_PROJECT}=            RAN_VRF
${RP_CA}=                 VRF_OAM
${RP_LOCATION}=           VRF_TSR1
${RP_ORGANIZATION}=       VRF_TSR1_T02
${EMAIL_RECIPIENTS}=      None
${INITIAL_SW}             None
${TARGET_SW}              None

${SWR}=              3
${SBTS_RESET}=       20
${RF_RESET}=         20
${BBMOD_RESET}=      10
${CELL_LOCK}=        3
${DELTA_SCF}=        3

${ONLINE_PARAMETER_DELTA}=      /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1344/json/ONLINE_PARAMETER_DELTA.json
${SITE_RESET_DELTA}=      /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1344/json/SITE_RESET_DELTA.json
${NR_RAT_RESET_DELTA}=    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1344/json/NR_RAT_RESET_DELTA.json
${LTE_RAT_RESET_DELTA}=    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1344/json/LTE_RAT_RESET_DELTA.json
${WCDMA_RAT_RESET_DELTA}=    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1344/json/WCDMA_RAT_RESET_DELTA.json
${GSM_RAT_RESET_DELTA}=    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1344/json/GSM_RAT_RESET_DELTA.json

@{CUSTOM_ALLOWED}    4003  4681  7107  6278  6450  6150  2412

# ------ CALL
${NR_SA_DESIRED_THROUGHPUT_UPLINK}  301 Mbits/sec
${NR_SA_DESIRED_THROUGHPUT_DOWNLINK}  501 Mbits/sec
${NR_SA_MIN_THROUGHPUT_UPLINK}  100 Mbits/sec
${NR_SA_MIN_THROUGHPUT_DOWNLINK}  100 Mbits/sec
${NR_SA_UE_ALIAS}  UE_NR_SA
${NR_SA_PS_DURATION}  40s
${NR_NSA_DESIRED_THROUGHPUT_UPLINK}  301 Mbits/sec
${NR_NSA_DESIRED_THROUGHPUT_DOWNLINK}  501 Mbits/sec
${NR_NSA_MIN_THROUGHPUT_UPLINK}  71 Mbits/sec
${NR_NSA_MIN_THROUGHPUT_DOWNLINK}  121 Mbits/sec
${NR_NSA_UE_ALIAS}  UE_NR_NSA
${NR_NSA_PS_DURATION}  40s
${LTE_DESIRED_THROUGHPUT_UPLINK}  101 Mbits/sec
${LTE_DESIRED_THROUGHPUT_DOWNLINK}  161 Mbits/sec
${LTE_MIN_THROUGHPUT_UPLINK}  16 Mbits/sec
${LTE_MIN_THROUGHPUT_DOWNLINK}  41 Mbits/sec
${LTE_UE_ALIAS}  UE_LTE
${LTE_PS_DURATION}  40s
${GSM_DESIRED_THROUGHPUT_UPLINK}  201 Kbits/sec
${GSM_DESIRED_THROUGHPUT_DOWNLINK}  151 Kbits/sec
${GSM_MIN_THROUGHPUT_UPLINK}  31 Kbits/sec
${GSM_MIN_THROUGHPUT_DOWNLINK}  31 Kbits/secc
${GSM_UE_ALIAS}  UE_GSM
${GSM_PS_DURATION}  40s
${GSM_VOICE_CALL_TIMEOUT}  20s
${NUMBER}  00104

*** Test Cases ***

_0_Update_CMP_IPSEC_certificates_on_SBTS
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Modify Resource Search Order    COMPA__Update_CMP_IPSEC_certificates_on_SBTS
    ...    AND    Set Test Variable    ${REFERENCE_NUMBER}    37456
    ...    AND    Set Test Variable    ${PRESHARED_KEY}    UtTA-ZfaW-L2u4-Gp6o
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    COMPA__Update_CMP_IPSEC_certificates_on_SBTS.TC Setup
    TC__COMPA__Update_CMP_IPSEC_certificates_on_SBTS
    [Teardown]    Run Keywords    COMPA__Update_CMP_IPSEC_certificates_on_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order

_0_check_swconfig
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Modify Resource Search Order    SWM__Check_swconfig_file_presence
    ...    AND    SWM__Check_swconfig_file_presence.TC Setup
    TC__SWM__Check_swconfig_file_presence
    [Teardown]    Run Keywords    SWM__Check_swconfig_file_presence.TC Teardown
    ...    AND    Restore Resource Search Order

_0_SWM__Upload_swconfig
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SWCONFIG_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1344/swconfigs/swconfig.txt
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    SWM__Upload_swconfig
    ...    AND    SWM__Upload_swconfig.TC Setup
    TC__SWM__Upload_swconfig
    [Teardown]    Run Keywords    SWM__Upload_swconfig.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset

_0__SWM__SCF_validation_errors_check
    [Timeout]    14401
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    SWM__SCF_validation_errors_check.TC Setup
    ...    AND    Modify Resource Search Order    SWM__SCF_validation_errors_check
    TC__SWM__SCF_validation_errors_check
    [Teardown]    Run Keywords    SWM__SCF_validation_errors_check.TC Teardown
    ...    AND    Restore Resource Search Order


_1_E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI__NODES
    [Tags]  QC_300619
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
#    ...     qc_id=${256347}


_2_E2E_TL_ACTIVATION_RESET_TEST__NODE1
    [Tags]  QC_300618
    [Timeout]   24h
    e2e_tl_activation_reset_test
   ...     nodes_details=${NODES}
    ...     test_nodes_details=${NODE1}
    ...     iterations_per_node=${SBTS_RESET}
    ...     customers_list=${CUSTOMERS_LIST}
    ...     report=${REPORT}
#    ...     qc_domain=${QC_DOMAIN}
#    ...     qc_project=${QC_PROJECT}
#    ...     qc_id=${256349}


_3_E2E_TL_RU_Reset_with_OAM_KPI__NODE1
   [Tags]  QC_300614
   [Timeout]   24h
   e2e_tl_ru_reset_with_oam_kpi
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${RF_RESET}
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_project=${QC_PROJECT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=${256360}


_4_E2E_TL_Capacity_Module_Reset_with_OAM_KPI__NODE1
   [Tags]  QC_300609
   [Timeout]   24h
   e2e_tl_capacity_module_reset_with_oam_kpi
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${BBMOD_RESET}
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_project=${QC_PROJECT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=${256359}


_5_E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI__NODE1
   [Tags]  QC_300612
    [Timeout]   24h
    e2e_tl_cell_lock_unlock_lte_with_oam_kpi
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${CELL_LOCK}
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_project=${QC_PROJECT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=${256358}


_6_E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI__NODE1
   [Tags]  QC_300615
    [Timeout]   24h
    e2e_tl_cell_block_unblock_lte_with_oam_kpi
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${CELL_LOCK}
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_project=${QC_PROJECT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=${256357}


_7_E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI__NODE1
   [Tags]  QC_300613
    [Timeout]   24h
    e2e_tl_cell_block_unblock_gsm_with_oam_kpi
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${CELL_LOCK}
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_project=${QC_PROJECT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=${256356}

_8_E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification__NODE1
   [Tags]  QC_300611
    [Timeout]   24h
    e2e_tl_delta_commissioning_with_online_parameter_modification
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${DELTA_SCF}
    ...          delta=${ONLINE_PARAMETER_DELTA}
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_project=${QC_PROJECT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=${256361}


_9_E2E_TL_Delta_Commissioning_With_Site_Reset_Required__NODE1
   [Tags]  QC_300617
    [Timeout]   24h
    e2e_tl_delta_commissioning_with_site_reset_required
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${DELTA_SCF}
    ...          delta=${SITE_RESET_DELTA}
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_project=${QC_PROJECT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=${256355}


_10_E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset__NODE1
   [Tags]  QC_300610
    [Timeout]   24h
    e2e_tl_delta_commissioning_with_lte_rat_reset
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${DELTA_SCF}
    ...          delta=${LTE_RAT_RESET_DELTA}
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_project=${QC_PROJECT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=${256354}



_11_E2E_TL_Delta_Commissioning_With_GSM_Rat_Reset__NODE1
   [Tags]  QC_300616
    [Timeout]   24h
    e2e_tl_delta_commissioning_with_gsm_rat_reset
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${DELTA_SCF}
    ...          delta=${GSM_RAT_RESET_DELTA}
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_project=${QC_PROJECT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=${256353}

_20_UE__NR_NSA_PS_Call
    [Setup]  UE__NR_NSA_PS_Call.TC Setup
    [Timeout]    20 minutes
    UE__NR_NSA_PS_Call
    [Teardown]    UE__NR_NSA_PS_Call.TC Teardown

_21_UE__NR_NSA_TCP_PS_Call
    [Setup]  UE__NR_NSA_TCP_PS_Call.TC Setup
    [Timeout]    20 minutes
    UE__NR_NSA_TCP_PS_Call
    [Teardown]    UE__NR_NSA_TCP_PS_Call.TC Teardown

_22_UE__LTE_PS_Call
    [Setup]  UE__LTE_PS_call.TC Setup
    [Timeout]    20 minutes
    UE__LTE_PS_call
    [Teardown]    UE__LTE_PS_call.TC Teardown

_23_UE__LTE_TCP_PS_Call
    [Setup]  UE__LTE_TCP_PS_call.TC Setup
    [Timeout]    20 minutes
    UE__LTE_TCP_PS_call
    [Teardown]    UE__LTE_TCP_PS_call.TC Teardown

_24_UE__GSM_PS_Call
    [Setup]  UE__GSM_PS_call.TC Setup
    [Timeout]    20 minutes
    UE__GSM_PS_call
    [Teardown]    UE__GSM_PS_call.TC Teardown

_25_UE__GSM_TCP_PS_Call
    [Setup]  UE__GSM_TCP_PS_call.TC Setup
    [Timeout]    20 minutes
    UE__GSM_TCP_PS_call
    [Teardown]    UE__GSM_TCP_PS_call.TC Teardown

_26_UE__GSM_Voice_Call
    [Setup]  UE__GSM_Voice_call.TC Setup
    [Timeout]    20 minutes
    UE__GSM_Voice_call
    [Teardown]  UE__GSM_Voice_call.TC Teardown


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
    Run  sudo cp -r /home/ute/testline_configuration/10_18_UTESRANCLOUD1344 /home/ute/
