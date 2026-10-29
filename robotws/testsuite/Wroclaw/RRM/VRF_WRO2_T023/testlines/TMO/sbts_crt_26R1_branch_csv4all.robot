*** Settings ***
Documentation
...   contact: Igor Kleschenok

Library        taf.sw.reporting_portal
Library        taf.ul.alarms_watchdog
Library        taf.sw.scout  WITH NAME  scout
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T023/testlines/TMO/resources/scenario.py
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T023/uuf/TMO_TL/resources/E2E_L3_CALL_resources.robot
Resource       ../../resources/ca_IWK.robot
Library        taf/rfrl/csv4all/CSV4AllTestCases.py
Library        taf/rfrl/csv4all/resources/utilities/utilities.py
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T023/feature_resources/CB008933/CB008933_A_Support_NRPMQAP_profiles_initial_configuration.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T023/feature_resources/CB010823/CB010823_CP41_Run_Diagnostic_check_from_WebEM.robot
Resource       ../../feature_resources/CB008127/CB008127-E_B1_Selection_of_measurement_profile_based_on_PLMN_NSSAI_slice.robot
Resource       ../../feature_resources/CB015286/CB015286_TMOUS_CVR_001_New_Counters_For_SA_NSA_CA_Scell_Activation_Deactivation_Verification.robot
Force Tags     MQC

Suite Setup  QRXLEVMIN Suite Setup

*** Variables ***
${ABSTRACT_LIB_CONFIG}=         /home/ute/testline_configuration/7_16_UTE5GCLOUDU049/ta_ue_config.yaml
${TA_ATTENUATOR_CONFIG}=        /home/ute/testline_configuration/7_16_UTE5GCLOUDU049/ta_ue_config.yaml
${SCOUT_TL_NAME}                7_16_UTE5GCLOUDU049_1
${USE_SCOUT_INTERNAL_ID}        True

${UPGRADE_TEST_ITERATION_WITH_L3CALL}=      1
${UPGRADE_TEST_ITERATION}=                  2
${TEST_ITERATION}=                          10
${SITE_ACTIVATION_RESET_TEST_ITERATION}=    14
${LTE_RAT_RESET_TEST_ITERATION}=            3
${NR_RAT_RESET_TEST_ITERATION}=             3
${COMMISSIONING_ITERATION}=                 2
${CELL_ITERATION}=                          5

@{CUSTOM_ALARMS}=               1904  4298  61631  4527  8150  7307  62003  7509  4297  6278  4655  1932  4681  7313  7312  4367  4352  4670
@{CRITICAL_FAULTS}=             @{EMPTY}
${ALARM_TIMEOUT}=               120
${HARDWARE_CHECK_TIMEOUT}=      480
${LABEL}=                       PZ2_WRO23_Igor_Kleschenok_gNB
${HOSTNAME}=                    7_16_UTE5GCLOUDU049_1
${SHOULD_BE_REPORTED}=          ${True}
@{CUSTOMERS_LIST}=              TMO US
${SOURCE_SW}=                   ${None}
${TARGET_SW}=                   ${None}
${DOWNLOAD_PATH}=               ${None}
${ONLINE_PARAMETER_DELTA}=      testsuite/Wroclaw/RRM/VRF_WRO2_T023/uuf/TMO_TL/resources/json_files/delta_online_parameter.json
${SITE_RESET_DELTA}=            testsuite/Wroclaw/RRM/VRF_WRO2_T023/uuf/TMO_TL/resources/json_files/delta_site_reset.json
${NR_RAT_RESET_DELTA}=          testsuite/Wroclaw/RRM/VRF_WRO2_T023/uuf/TMO_TL/resources/json_files/delta_nr_rat_reset.json
${LTE_RAT_RESET_DELTA}=         testsuite/Wroclaw/RRM/VRF_WRO2_T023/uuf/TMO_TL/resources/json_files/delta_lte_rat_reset.json
${WCDMA_RAT_RESET_DELTA}=       testsuite/Wroclaw/RRM/VRF_WRO2_T023/uuf/TMO_TL/resources/json_files/delta_wcdma_rat_reset.json
${GSM_RAT_RESET_DELTA}=         testsuite/Wroclaw/RRM/VRF_WRO2_T023/uuf/TMO_TL/resources/json_files/delta_gsm_rat_reset.json
${USE_BUILDS_STORAGE}=          ${False}
${RESTORE_TARGET_SW}=           ${False}
${DISABLE_SYSLOG_CHECK}=        ${False}
@{USER_SUSPICIOUS_PRINTS}=      @{EMPTY}
${REPORT_COMMENT}=              ${None}
${CALCULATE_KPI}=               ${True}
${EMAIL_RECIPIENTS}=            igor.kleschenok@nokia.com  # email or emails separate by comma eg. name@nokia.com,name@nokia.com
${QC_DOMAIN}=                   MN_RAN
${QC_PROJECT}=                  RAN_VRF
${USE_TEST_PACKAGES}=           ${False}
${SYNCHRONIZE_SOFTWARE}=        ${True}
${USE_DCAP}=                    ${False}
${STOP_TEST_AFTER_FAIL}=        ${False}
${RP_CA}=                       VRF_RRM
${RP_LOCATION}=                 VRF_WRO2
${RP_ORGANIZATION}=             VRF_WRO2_T03_01

&{NODE1}                        node_alias=5G
...                             testline_object=${tl.gnbs[0]}
...                             source_sw=${SOURCE_SW}
...                             target_sw=${TARGET_SW}
...                             custom_allowed_alarms=${CUSTOM_ALARMS}
...                             testline_scout_name=${HOSTNAME}
...                             critical_alarms=${CRITICAL_FAULTS}
...                             alarm_timer=${ALARM_TIMEOUT}
...                             hw_to_onair_timeout=${HARDWARE_CHECK_TIMEOUT}
...                             verify_syslog=${DISABLE_SYSLOG_CHECK}
@{NODES}                        ${NODE1}



*** Keywords ***
Attenuator Setup
    Log To Console   Attenuator Setup
    Reserve Attenuator Resources Using Cells List Specification


Reserve Attenuator Resources Using Cells List Specification
    Load Attenuation Config  ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of  ${CELLS_LST}


Attenuator Teardown
    Log To Console   Attenuator Teardown
    Set Attenuation For All Cells  100%
    FOR  ${i}  IN    @{CELLS_LST}
        Release Attenuator Cell   ${i}
    END


QRXLEVMIN Suite Setup
    &{qrxlevmin_cb015286_sa} =  Create Dictionary
    ...  MRBTS-2004/NRBTS-20003/NRCELL-3=-22
    ...  MRBTS-2004/NRBTS-20003/NRCELL-13=-22
    ...  MRBTS-2004/NRBTS-20003/NRCELL-43=-22
    ...  MRBTS-2004/NRBTS-20003/NRCELL-302=-22
    ...  MRBTS-2004/NRBTS-20003/NRCELL-312=-22
    Set Suite Variable  &{QRXLEVMIN_CB015286_SA}  &{qrxlevmin_cb015286_sa}

    &{qrxlevmin_cb015286_nsa} =  Create Dictionary
    ...  MRBTS-2004/NRBTS-20003/NRCELL-2=-22
    ...  MRBTS-2004/NRBTS-20003/NRCELL-22=-22
    ...  MRBTS-2004/NRBTS-20003/NRCELL-42=-22
    ...  MRBTS-2004/NRBTS-20003/NRCELL-303=-22
    ...  MRBTS-2004/NRBTS-20003/NRCELL-313=-22
    Set Suite Variable  &{QRXLEVMIN_CB015286_NSA}  &{qrxlevmin_cb015286_nsa}

Save Original qRxLevMin Values
    &{original_qrxlevmin_values} =  Get qRxLevMin Values of NR Cells  connection=gNB
    Set Test Variable  &{ORIGINAL_QRXLEVMIN_VALUES}  &{original_qrxlevmin_values}


Set Source Software And Target Software
    ${SOURCE_SW}=    Run Keyword If  '${SOURCE_SW}'=='${None}'  Get Source SW
    ...   ELSE  set variable  ${SOURCE_SW}
    ${TARGET_SW}=    Run Keyword If  '${TARGET_SW}'=='${None}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary         ${NODE1}
    ...                       source_sw=${SOURCE_SW}
    ...                       target_sw=${TARGET_SW}


*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_and_L3_Call
    [Timeout]   100h
    [Setup]    Setup E2E
    [Teardown]    Teardown E2E
    Set Library Search Order  CSV4AllTESTCASES  UTILITIES
    Set Source Software And Target Software
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...          iterations_per_node=${UPGRADE_TEST_ITERATION_WITH_L3CALL}
    ...          report=${SHOULD_BE_REPORTED}
    ...          calculate_kpi=${CALCULATE_KPI}
    ...          use_dcap=${USE_DCAP}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=258899
    ...          qc_project=${QC_PROJECT}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report_comment=${REPORT_COMMENT}
    ...          topology=${LABEL}
    ...          use_external_storage=${USE_BUILDS_STORAGE}
    ...          download_path=${DOWNLOAD_PATH}
    ...          use_testpackage=${USE_TEST_PACKAGES}
    ...          restore_to_target_sw=${RESTORE_TARGET_SW}
    ...          stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...          l3_call_method=E2E_L3_CALL_WRO23
    ...          synchronize_software_on_passive=${SYNCHRONIZE_SOFTWARE}

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   100h
    Set Library Search Order  CSV4AllTESTCASES  UTILITIES
    Set Source Software And Target Software
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...          iterations_per_node=${UPGRADE_TEST_ITERATION}
    ...          report=${SHOULD_BE_REPORTED}
    ...          calculate_kpi=${CALCULATE_KPI}
    ...          use_dcap=${USE_DCAP}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=258900
    ...          qc_project=${QC_PROJECT}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          report_comment=${REPORT_COMMENT}
    ...          topology=${LABEL}
    ...          use_external_storage=${USE_BUILDS_STORAGE}
    ...          download_path=${DOWNLOAD_PATH}
    ...          use_testpackage=${USE_TEST_PACKAGES}
    ...          restore_to_target_sw=${True}
    ...          stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...          l3_call_method=${None}
    ...          synchronize_software_on_passive=${SYNCHRONIZE_SOFTWARE}

E2E_TL_Activation_Reset_Test
    [Timeout]  100h
    Set Library Search Order  CSV4AllTESTCASES  UTILITIES
    E2E TL ACTIVATION RESET TEST
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${SITE_ACTIVATION_RESET_TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=258898
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  use_external_storage=${USE_BUILDS_STORAGE}
    ...  download_path=${DOWNLOAD_PATH}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   100h
    Set Library Search Order  CSV4AllTESTCASES  UTILITIES
    E2E TL RU RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=258897
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   100h
    Set Library Search Order  CSV4AllTESTCASES  UTILITIES
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=258891
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   100h
    Set Library Search Order  CSV4AllTESTCASES  UTILITIES
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${COMMISSIONING_ITERATION}
    ...  delta=${ONLINE_PARAMETER_DELTA}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=258895
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   100h
    Set Library Search Order  CSV4AllTESTCASES  UTILITIES
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${COMMISSIONING_ITERATION}
    ...  delta=${SITE_RESET_DELTA}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=258892
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   100h
    Set Library Search Order  CSV4AllTESTCASES  UTILITIES
    E2E TL DELTA COMMISSIONING WITH NR RAT RESET
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${COMMISSIONING_ITERATION}
    ...  delta=${NR_RAT_RESET_DELTA}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=258890
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   100h
    Set Library Search Order  CSV4AllTESTCASES  UTILITIES
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${CELL_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=258896
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   100h
    Set Library Search Order  CSV4AllTESTCASES  UTILITIES
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${CELL_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=258894
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI
    [Timeout]   100h
    Set Library Search Order  CSV4AllTESTCASES  UTILITIES
    E2E TL CELL BLOCK UNBLOCK GSM WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${CELL_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=258893
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

CB010823_CP41_Run_Diagnostic_check_from_WebEM
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB010823_CP41_Run_Diagnostic_check_from_WebEM  admin  process
    ...  AND  Set Test Variable  ${RMOD_SN}  L1213401831
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1][1.0] ${TEST_NAME}
    [Teardown]  Run Keywords
    ...       TC Teardown

CB008933_A_Support_NRPMQAP_profiles_initial_configuration
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Attenuator Setup
    ...  AND  Set Library Search Order  CB008933_A_Support_NRPMQAP_profiles_initial_configuration  admin  process
    ...  AND  Set Test Variable  ${NR_CELL_SA}  22
    ...  AND  Set Test Variable  ${NR_CELL_NSA}  12
    ...  AND  Set Test Variable  ${PATH_TO_NR_CELL}  MRBTS-2004/NRBTS-20003/NRCELL-42
    ...  AND  Set Test Variable  ${NSA_UE_CAPABILITY}  NSA_NOKIA
    ...  AND  Set Test Variable  ${NR_SA_UE_CAPABILITY}  NR_SA_TARO_CALL
    ...  AND  Set Test Variable  ${LTE_CELL_GLOBAL_ID}  22
    ...  AND  TC Setup
    ...  AND  Set qrxlevmin Level  NRCELL-2  -22
    ...  AND  Set qrxlevmin Level  NRCELL-303  -22
    ...  AND  Set qrxlevmin Level  NRCELL-313  -22
    ...  AND  Set qrxlevmin Level  NRCELL-12  -22
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1][2.0] CB008933_A_Support_NRPMQAP_profiles_initial_configuration_in_L2_HI__L2_LO__L2_PS__C_plane
    [Teardown]  Run Keywords
    ...  TC Teardown
    ...  AND  Set qrxlevmin Level  NRCELL-303  -60
    ...  AND  Set qrxlevmin Level  NRCELL-313  -60
    ...  AND  Set qrxlevmin Level  NRCELL-2  -60
    ...  AND  Set qrxlevmin Level  NRCELL-12  -60
    ...  AND  Attenuator Teardown

CB008127-E_B1_Selection_of_measurement_profile_based_on_PLMN_NSSAI_slice
    [Setup]  Run Keywords
    ...  Attenuator Setup
    ...  AND  Set Attenuation   GNB_CELL_1  30dB
    ...  AND  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  CB008127-E_B1_Selection_of_measurement_profile_based_on_PLMN_NSSAI_slice  admin  process
    ...  AND  Set Test Variable  ${CELL_ID_FOR_CALL}  327729463
    ...  AND  Set Test Variable  ${NR_DL_THROUGHPUT}  1000
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  NR_L3_CALL
    ...  AND  TC Setup
    ...  AND  Set qrxlevmin Level  NRCELL-301  -22
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1][1.0] ${TEST_NAME}
    [Teardown]  Run Keywords
    ...       TC Teardown
    ...  AND  Set qrxlevmin Level  NRCELL-301  -60
    ...  AND  Attenuator Teardown

CB015286_TMOUS_CVR_001_New_Counters_For_SA_CA_Scell_Activation_Deactivation_Verification
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation   GNB_CELL_3   0dB
    ...  AND  Set Attenuation   GNB_CELL_23   0dB
    ...  AND  Set Library Search Order  CB015286_TMOUS_CVR_001_New_Counters_For_SA_NSA_CA_Scell_Activation_Deactivation_Verification  admin  process
    ...  AND  Set Test Variable  ${NR_CELL_SA}  23
    ...  AND  Set Test Variable  ${CELL_ID_FOR_CALL}  327729175
    ...  AND  Set Test Variable  ${TYPE_UE_MODE}  SA_UE
    ...  AND  Set Test Variable  ${UE_CAPABILITY}  NR_SA_TARO_CALL
    ...  AND  Set Test Variable  ${LTE_CELL}  False
    ...  AND  Set Test Variable  ${COUNTER_1}  M55316C00033
    ...  AND  Set Test Variable  ${COUNTER_2}  M55316C00035
    ...  AND  Set Test Variable  ${COUNTER_3}  M55316C00044
    ...  AND  Set Test Variable  ${COUNTER_4}  M55316C00045
    ...  AND  TC Setup
    ...  AND  Save Original qRxLevMin Values
    ...  AND  Set qRxLevMin Values of NR Cells  ${QRXLEVMIN_CB015286_SA}  connection=gNB
    Run keyword  TC__CB015286_TMOUS_CVR_001_New_Counters_For_SA_NSA_CA_Scell_Activation_Deactivation_Verification
    Map Testcase  [1][1.0] CB015286_TMOUS_CVR_001_New_Counters_For_SA_CA_Scell_Activation_Deactivation_Verification
    [Teardown]  Run Keywords
    ...  Set qRxLevMin Values of NR Cells  ${ORIGINAL_QRXLEVMIN_VALUES}  connection=gNB
    ...  AND  TC Teardown
    ...  AND  Attenuator Teardown

CB015286_TMOUS_CVR_001_New_Counters_For_NSA_CA_Scell_Activation_Deactivation_Verification
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation   GNB_CELL_2   0dB
    ...  AND  Set Attenuation   GNB_CELL_22   0dB
    ...  AND  Set Library Search Order  CB015286_TMOUS_CVR_001_New_Counters_For_SA_NSA_CA_Scell_Activation_Deactivation_Verification  admin  process
    ...  AND  Set Test Variable  ${NR_CELL_SA}  12
    ...  AND  Set Test Variable  ${CELL_ID_FOR_CALL}  22
    ...  AND  Set Test Variable  ${TYPE_UE_MODE}  NSA_UE
    ...  AND  Set Test Variable  ${UE_CAPABILITY}  NR_NSA_TARO_CALL
    ...  AND  Set Test Variable  ${LTE_CELL}  True
    ...  AND  Set Test Variable  ${COUNTER_1}  M55316C00037
    ...  AND  Set Test Variable  ${COUNTER_2}  M55316C00039
    ...  AND  Set Test Variable  ${COUNTER_3}  M55316C00046
    ...  AND  Set Test Variable  ${COUNTER_4}  M55316C00047
    ...  AND  TC Setup
    ...  AND  Save Original qRxLevMin Values
    ...  AND  Set qRxLevMin Values of NR Cells  ${QRXLEVMIN_CB015286_NSA}  connection=gNB
    Run keyword  TC__CB015286_TMOUS_CVR_001_New_Counters_For_SA_NSA_CA_Scell_Activation_Deactivation_Verification
    Map Testcase  [1][1.0] CB015286_TMOUS_CVR_001_New_Counters_For_NSA_CA_Scell_Activation_Deactivation_Verification
    [Teardown]  Run Keywords
    ...  Set qRxLevMin Values of NR Cells  ${ORIGINAL_QRXLEVMIN_VALUES}  connection=gNB
    ...  AND  TC Teardown
    ...  AND  Attenuator Teardown
