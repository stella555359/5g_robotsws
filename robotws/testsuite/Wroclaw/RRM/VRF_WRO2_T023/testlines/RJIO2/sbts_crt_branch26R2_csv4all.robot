*** Settings ***
Documentation
...   contact: Mateusz Guziana

Force Tags     QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_5G_CLASSICAL_2XANDROID_1XIPHONE_ASOE_3XAQQJ_3XAHPJ_ASIL_ABIO_AHPB_AEQZ    SBTS26R2
Library        ute_ue
Library        taf.sw.reporting_portal
Library        taf.ul.alarms_watchdog
Library        taf.sw.scout  WITH NAME  scout
Resource       ../../feature_resources/RJIO/Rjio_E2E_21_Snapshot_Content_Compare.robot
Resource       ../../feature_resources/RJIO/Rjio_E2E_35_Power_Saving_BWP_Switch.robot
Resource       ../../feature_resources/RJIO/Rjio_E2E_26_CA_Call.robot
Resource       ../../feature_resources/RJIO/Rjio_E2E_34_Intra-Frequency_And_Inter-Gnb_Ho_And_ANR_Ng_Based.robot
Resource       ../../feature_resources/RJIO/Rjio_E2E_64_Mobility_IRAT_Data_HO_And_ANR.robot
Resource       ../../feature_resources/RJIO/Voice_over_NR.robot
Resource       ../../feature_resources/RJIO/resources/RJIO_Data_Transfer.robot
Resource       ../../feature_resources/RJIO/resources/RJIO_testsuite_resources.robot
Resource       ../../resources/attenuator.robot
Resource       ../../resources/ca_IWK.robot
Library        taf/rfrl/csv4all/CSV4AllTestCases.py
Library        taf/rfrl/csv4all/resources/utilities/utilities.py

Suite Setup  Run Keywords  Check If Execution Is Run By Cloud Manager  AND  Set Source Software And Target Software
...  AND  Set Suite Variable  ${SCF_AND_UPGRADE_PASED}  False


*** Variables ***
${ABSTRACT_LIB_CONFIG}=         /home/ute/testline_configuration/7_16_UTE5GCLOUDU004/ta_ue_config.yaml
${TA_ATTENUATOR_CONFIG}=        /home/ute/testline_configuration/7_16_UTE5GCLOUDU004/ta_ue_config.yaml

${UPGRADE_ITERATION}=                    3
${COMMISSIONING_ITERATION}=              1
${TEST_ITERATION}=                       10
${TEST_ITERATION_CELL_LOCK}=             2
${TEST_ITERATION_CELL_BLOCK}=            6
${TEST_ITERATION_RESET_WITH_L3_CALL}=    1
${RMOD_AMOUNT}=                          6

@{CUSTOM_ALARMS}=                8000  7313  7311
@{CUSTOM_ALARMS_NR_RAT_RESET}=   8000  7313
@{CUSTOM_ALARMS_POWER_RESET}=    8000  4589
@{SNAPSHOT_ALLOWED_FAULT_IDS}=   4655  4654  61524  61652  61649  4592  7311  4681
@{IGNORED_ALARMS_FOR_HO_TC}=     4655  4654  61524  61652  61649  4592  7311  4681        # List of ignored alarms for HO and ANR test cases.
@{CA_ALLOWED_FAULT_IDS}=         4655  4654  61524  61652  61649  4592  7311  4681        # List of ignored alarms for Carrier Aggregation test case.
@{PS_ALLOWED_FAULT_IDS}=         4655  4654  61524  61652  61649  4592  7311  4681        # List of ignored alarms for Power Saving test case.
@{VONR_ALLOWED_FAULT_IDS}=       4655  4654  61524  61652  61649  4592  7311  4681        # List of ignored alarms for VoNR test cases.
@{CRITICAL_FAULTS}=              @{EMPTY}
${ALARM_TIMEOUT}=                120
${HARDWARE_CHECK_TIMEOUT}=       360

${LABEL}=                       CLOUD_5G_CLASSICAL_2xANDROID_1xIPHONE_ASOE_3xAQQJ_3xAHPJ_ASIL_ABIO_AHPB_AEQZ
${HOSTNAME}=                    7_16_UTE5GCLOUDU004_1
${HOSTNAME_HO_TL}=              7_16_UTE5GCLOUDU004_1
${SHOULD_BE_REPORTED}=          ${True}
@{CUSTOMERS_LIST}=              Reliance India
${5G_SOURCE_SW}=                SBTS25R1_ENB_0000_000756_000050
${5G_TARGET_SW}=                ${None}
${DOWNLOAD_PATH}=               ${None}
${USE_BUILDS_STORAGE}=          ${False}
${RESTORE_TARGET_SW}=           ${True}
${DISABLE_SYSLOG_CHECK}=        ${False}
@{USER_SUSPICIOUS_PRINTS}=      @{EMPTY}
${REPORT_COMMENT}=              ${None}
${ONLINE_PARAMETER_DELTA}=      testsuite/Wroclaw/RRM/VRF_WRO2_T023/testlines/RJIO2/resources/EIRP_Delta_MRBTS-53085_RAN-PZ-WRO-RJio_2_1.json
${SITE_RESET_DELTA}=            ${None}
${NR_RAT_RESET_DELTA}=          testsuite/Wroclaw/RRM/VRF_WRO2_T023/testlines/RJIO2/resources/nr_rat_reset_delta.json
${CALCULATE_KPI}=               ${True}
@{SYSLOG_IGNORED_PRINTS}=       INF
${EMAIL_RECIPIENTS}=            mateusz.guziana@nokia.com  # email or emails separate by comma eg. name@nokia.com,name@nokia.com
${QC_DOMAIN}=                   MN_RAN
${QC_PROJECT}=                  RAN_VRF

&{RU1_PDU}                      model=GUDE  host=10.44.205.153  port=@{6, }  version=8221-1
&{RU2_PDU}                      model=GUDE  host=10.44.205.153  port=@{9, }  version=8221-1
&{RU3_PDU}                      model=GUDE  host=10.44.205.153  port=@{5, }  version=8221-1
&{RU4_PDU}                      model=GUDE  host=10.44.177.177  port=@{7, }  version=8221-1
&{RU5_PDU}                      model=GUDE  host=10.44.177.177  port=@{8, }  version=8221-1
&{RU6_PDU}                      model=GUDE  host=10.44.177.177  port=@{9, }  version=8221-1
&{RU1}                          1M233608969=${RU1_PDU}
&{RU2}                          1M233608967=${RU2_PDU}
&{RU3}                          K9232920878=${RU3_PDU}
&{RU4}                          K9232032151=${RU4_PDU}
&{RU5}                          K9232032131=${RU5_PDU}
&{RU6}                          K9232032130=${RU6_PDU}
@{PDU_LIST}=                    &{RU1}  &{RU2}  &{RU3}  &{RU4}  &{RU5}  &{RU6}

${MPLANE}                       10.45.178.35
${HANGING_SCRIPT_PATH}          /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/VRF_WRO2_T023/feature_resources/RJIO/resources/hanging_check_4G_5G.py
${ADDITIONAL_UE_CAPABILITY}     REAL_ANDROID_UE

${SCF_FILE}=                    /home/ute/testline_configuration/7_16_UTE5GCLOUDU004/25R2/MRBTS-53085_RAN-PZ-WRO-RJio_2_1_20250515-2313.xml
${UPLOAD_BASELINE_SCF}          ${True}
${FIRST_SCF_ITERATION}          ${True}

${USE_TEST_PACKAGES}            ${True}
${SYNCHRONIZE_SOFTWARE}         ${False}
${USE_DCAP}                     ${False}
${STOP_TEST_AFTER_FAIL}         ${False}
${RP_CA}                        VRF_RRM
${RP_LOCATION}                  VRF_WRO2
${RP_ORGANIZATION}              VRF_WRO2_T03

&{NODE1}                        node_vm=10.44.149.126
...                             source_sw=${5G_SOURCE_SW}
...                             target_sw=${5G_TARGET_SW}
...                             custom_allowed_alarms=${CUSTOM_ALARMS}
...                             testline_scout_name=${HOSTNAME}
...                             critical_alarms=${CRITICAL_FAULTS}
...                             alarm_timer=${ALARM_TIMEOUT}
...                             hw_to_onair_timeout=${HARDWARE_CHECK_TIMEOUT}
...                             verify_syslog=${DISABLE_SYSLOG_CHECK}
...                             syslog_ignored_prints=${SYSLOG_IGNORED_PRINTS}
...                             user_syslog_suspicious_prints=${USER_SUSPICIOUS_PRINTS}

&{NODE2}                        node_vm=10.44.149.122
...                             source_sw=${5G_SOURCE_SW}
...                             target_sw=${5G_TARGET_SW}
...                             custom_allowed_alarms=${CUSTOM_ALARMS}
...                             testline_scout_name=${HOSTNAME_HO_TL}
...                             critical_alarms=${CRITICAL_FAULTS}
...                             alarm_timer=${ALARM_TIMEOUT}
...                             hw_to_onair_timeout=${HARDWARE_CHECK_TIMEOUT}
...                             verify_syslog=${DISABLE_SYSLOG_CHECK}
...                             syslog_ignored_prints=${SYSLOG_IGNORED_PRINTS}
...                             user_syslog_suspicious_prints=${USER_SUSPICIOUS_PRINTS}

@{NODES}                        ${NODE1}


*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Tags]    QC_308641
    [Timeout]   24h
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=500
    ...                                       kpi2b=500
    ...                                       kpi2c=500
    ...                                       kpi2d=500
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  360
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    ${modifications_dict} =  Create Dictionary
    ...  alarm_timer=${ALARM_TIMEOUT}
    ...  hw_to_onair_timeout=${HARDWARE_CHECK_TIMEOUT}
    ...  syslog_ignored_prints=${SYSLOG_IGNORED_PRINTS}
    ${node2}  ${nodes2} =  Temporarily Modify Node  ${NODE1}  ${modifications_dict}

    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...  nodes_details=${nodes2}
    ...  test_nodes_details=${nodes2}
    ...  iterations_per_node=${UPGRADE_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=308641
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  use_external_storage=${USE_BUILDS_STORAGE}
    ...  download_path=${DOWNLOAD_PATH}
    ...  use_testpackage=${USE_TEST_PACKAGES}
    ...  restore_to_target_sw=${RESTORE_TARGET_SW}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}
    ...  synchronize_software_on_passive=${SYNCHRONIZE_SOFTWARE}


Rjio_E2E_02_Upload_Baseline_SCF_After_SW_Upgrade
    [Tags]    QC_308661
    [Timeout]   1h
    [Setup]  Add Configuration ID to Reporting Portal Report  scout_testline_name=${HOSTNAME}
    Check If Baseline SCF Is Uploaded  ${SCF_FILE}
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keyword If  ${SHOULD_BE_REPORTED} and ${USE_SCOUT_INTERNAL_ID}  Report Test Case  qc_id=308661


E2E_TL_Activation_Reset_with_OAM_KPI
    [Tags]    QC_308642
    [Timeout]  100h
    Check If Baseline SCF Is Uploaded  ${SCF_FILE}
    Set Test Variable  ${SCF_AND_UPGRADE_PASED}  True
    E2E TL ACTIVATION RESET TEST
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${TEST_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=308642
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  use_external_storage=${USE_BUILDS_STORAGE}
    ...  download_path=${DOWNLOAD_PATH}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

    [Teardown]  Run Keyword If  not ${SCF_AND_UPGRADE_PASED}  Report Test Case  qc_id=308642


E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Tags]    QC_308643
    [Timeout]   24h
    Check If Baseline SCF Is Uploaded  ${SCF_FILE}
    Set Test Variable  ${SCF_AND_UPGRADE_PASED}  True
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${COMMISSIONING_ITERATION}
    ...  delta=${ONLINE_PARAMETER_DELTA}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=308643
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

    [Teardown]  Run Keyword If  not ${SCF_AND_UPGRADE_PASED}  Report Test Case  qc_id=308643


E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Tags]    QC_308648
    [Timeout]   24h
    Check If Baseline SCF Is Uploaded  ${SCF_FILE}
    Set Test Variable  ${SCF_AND_UPGRADE_PASED}  True
    ${modifications_dict} =  Create Dictionary
    ...  custom_allowed_alarms=${CUSTOM_ALARMS_NR_RAT_RESET}
    ${node2}  ${nodes2} =  Temporarily Modify Node  ${NODE1}  ${modifications_dict}
    E2E TL DELTA COMMISSIONING WITH NR RAT RESET
    ...  nodes_details=${nodes2}
    ...  test_nodes_details=${nodes2}
    ...  iterations_per_node=${COMMISSIONING_ITERATION}
    ...  delta=${NR_RAT_RESET_DELTA}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=308648
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

    [Teardown]  Run Keyword If  not ${SCF_AND_UPGRADE_PASED}  Report Test Case  qc_id=308648


E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Tags]    QC_308645
    [Timeout]   24h
    Check If Baseline SCF Is Uploaded  ${SCF_FILE}
    Set Test Variable  ${SCF_AND_UPGRADE_PASED}  True
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${COMMISSIONING_ITERATION}
    ...  delta=${SITE_RESET_DELTA}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=308645
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

    [Teardown]  Run Keyword If  not ${SCF_AND_UPGRADE_PASED}  Report Test Case  qc_id=308645


Rjio_E2E_21_Snapshot_Content_Compare
    [Tags]    QC_308663
    [Timeout]   8h
    [Setup]  Run Keywords
    ...  Check If Baseline SCF Is Uploaded  ${SCF_FILE}
    ...  AND  Set Test Variable  ${SCF_AND_UPGRADE_PASED}  True
    ...  AND  Add Configuration ID to Reporting Portal Report  scout_testline_name=${HOSTNAME}
    ...  AND  Set Library Search Order  Rjio_E2E_21_Snapshot_Content_Compare  admin  taf.ul.alarms_watchdog  Process
    ...  AND  Set Test Variable  ${SNAPSHOT_ALLOWED_FAULT_IDS}
    ...  AND  Create Alarm List  ${SNAPSHOT_ALLOWED_FAULT_IDS}
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords  TC Teardown
    ...  AND  Run Keyword If  ${SHOULD_BE_REPORTED} and ${USE_SCOUT_INTERNAL_ID}  Report Test Case  qc_id=308663


Rjio_E2E_35_Power_Saving_BWP_Switch
    [Tags]    QC_308670
    [Timeout]   2h
    [Setup]  Run Keywords
    ...  Check If Baseline SCF Is Uploaded  ${SCF_FILE}
    ...  AND  Set Test Variable  ${SCF_AND_UPGRADE_PASED}  True
    ...  AND  Add Configuration ID to Reporting Portal Report  scout_testline_name=${HOSTNAME}
    ...  AND  Set Library Search Order  Rjio_E2E_35_Power_Saving_BWP_Switch  admin  UTF_Logs_Collecting_For_BWP  Process
    ...  AND  Set Test Variable  ${NR_CELL_ID}  0
    ...  AND  Set Test Variable  ${POWER_SAVING_BWP_ID}  70
    ...  AND  Set Test Variable  ${LOOPS_COUNT}  6
    ...  AND  Set Test Variable  ${NR_EXPECTED_DL_TPUT}  500
    ...  AND  Set Test Variable  ${APN_CONTAINS}  n26wro
    ...  AND  Set Test Variable  ${TA_ATTENUATOR_CONFIG}  ${TA_ATTENUATOR_CONFIG}
    ...  AND  Set Test Variable  ${CELL_ALIAS}  NR_CELL_0
    ...  AND  Set Test Variable  ${ADDITIONAL_UE_CAPABILITY}  ${ADDITIONAL_UE_CAPABILITY}
    ...  AND  Load Attenuation Config And Require Attenuator Setup  ${TA_ATTENUATOR_CONFIG}
    ...  AND  Create Alarm List  ${PS_ALLOWED_FAULT_IDS}
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords  TC Teardown
    ...  AND  Run Keyword If  ${SHOULD_BE_REPORTED} and ${USE_SCOUT_INTERNAL_ID}  Report Test Case  qc_id=308670


Rjio_E2E_26_CA_Call
    [Tags]    QC_308671
    [Timeout]   2h
    [Setup]  Run Keywords
    ...  Check If Baseline SCF Is Uploaded  ${SCF_FILE}
    ...  AND  Set Test Variable  ${SCF_AND_UPGRADE_PASED}  True
    ...  AND  Add Configuration ID to Reporting Portal Report  scout_testline_name=${HOSTNAME}
    ...  AND  Set Library Search Order  Rjio_E2E_26_CA_Call  admin  Process
    ...  AND  Set Expected Throughput For UE
    ...  AND  Set Test Variable  ${NR_CELL_ID}  16
    ...  AND  Set Test Variable  ${SECONDARY_NR_CELL_ID}  1
    ...  AND  Set Test Variable  ${NR_EXPECTED_DL_TPUT}  ${EXPECTED_DL_TPUT}
    ...  AND  Set Test Variable  ${NR_EXPECTED_UL_TPUT}  ${EXPECTED_UL_TPUT}
    ...  AND  Set Test Variable  ${APN_CONTAINS}  n26wro
    ...  AND  Set Test Variable  ${TA_ATTENUATOR_CONFIG}  ${TA_ATTENUATOR_CONFIG}
    ...  AND  Set Test Variable  ${PRIMARY_CELL_ALIAS}  NR_CELL_16
    ...  AND  Set Test Variable  ${SECONDARY_CELL_ALIAS}  NR_CELL_1
    ...  AND  Set Test Variable  ${PROFILE_FILTERS}  Use RnD parameters
    ...  AND  Set Test Variable  ${MAX_DATA_VOLUME_DL}  dlFdSchedAdditionalData.maxDataVolumeDl
    ...  AND  Set Test Variable  ${ADDITIONAL_UE_CAPABILITY}  ${ADDITIONAL_UE_CAPABILITY}
    ...  AND  Load Attenuation Config And Require Attenuator Setup  ${TA_ATTENUATOR_CONFIG}
    ...  AND  Create Alarm List  ${CA_ALLOWED_FAULT_IDS}
    ...  AND  TC Setup
    Change QRxLevMin  ${SECONDARY_NR_CELL_ID}  -22
    Run Keyword  TC__${TEST_NAME}
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords
    ...  Run Keyword If  ${QRXLEVMIN_CHANGED}  Change QRxLevMin  ${SECONDARY_NR_CELL_ID}  ${ORIGINAL_QRX_VALUE}
    ...  AND  TC Teardown
    ...  AND  Run Keyword If  ${SHOULD_BE_REPORTED} and ${USE_SCOUT_INTERNAL_ID}  Report Test Case  qc_id=308671


Rjio_E2E_63_Mobility_UE_based_ANR_for_NR_Neighbor
    [Tags]    QC_308669
    [Timeout]   2h
    [Setup]  Run Keywords
    ...  Check If Baseline SCF Is Uploaded  ${SCF_FILE}
    ...  AND  Set Test Variable  ${SCF_AND_UPGRADE_PASED}  True
    ...  AND  Add Configuration ID to Reporting Portal Report  scout_testline_name=${HOSTNAME}
    ...  AND  Set Library Search Order  Rjio_E2E_34_Intra-Frequency_And_Inter-Gnb_Ho_And_ANR_Ng_Based  admin
    ...  UTF_Logs_Collecting_For_HO  Process
    ...  AND  Set Test Variable  ${NR_CELL_ID1}  0
    ...  AND  Set Test Variable  ${NR_CELL_ID2}  61
    ...  AND  Set Test Variable  ${TARGET_SMOD_SERIAL_NUMBER}  DH222244824
    ...  AND  Set Test Variable  @{SOURCE_ATTENUATION_LIST}   0  5  10  15  25  30  35  45  55  90
    ...  AND  Set Test Variable  @{TARGET_ATTENUATION_LIST}  90  25  10  0  0  0  0  0  0  0
    ...  AND  Set Test Variable  ${TA_ATTENUATOR_CONFIG}  ${TA_ATTENUATOR_CONFIG}
    ...  AND  Set Test Variable  ${IS_HO_TEST_CASE}  False
    ...  AND  Set Test Variable  ${GNB_CPLANE_IP}  10.45.179.235
    ...  AND  Set Test Variable  ${APN_CONTAINS}  n26wro
    ...  AND  Set Test Variable  ${VIRTUALENV_DIR}  ${VIRTUALENV_DIR}
    ...  AND  Set Test Variable  ${SOURCE_CELL_ALIAS}  NR_CELL_0
    ...  AND  Set Test Variable  ${TARGET_CELL_ALIAS}  HO_NR_CELL_61
    ...  AND  Set Test Variable  ${MAX_UTF_LOGS_DELAY}  300s
    ...  AND  Set Test Variable  ${ADDITIONAL_UE_CAPABILITY}  ${ADDITIONAL_UE_CAPABILITY}
    ...  AND  Load Attenuation Config And Require Attenuator Setup  ${TA_ATTENUATOR_CONFIG}
    ...  AND  Create Alarm List  ${IGNORED_ALARMS_FOR_HO_TC}
    ...  AND  TC Setup
    Run Keyword  TC__Rjio_E2E_34_Intra-Frequency_And_Inter-Gnb_Ho_And_ANR_Ng_Based
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords  TC Teardown
    ...  AND  Run Keyword If  ${SHOULD_BE_REPORTED} and ${USE_SCOUT_INTERNAL_ID}  Report Test Case  qc_id=308669


Rjio_E2E_34_Intra-Frequency_And_Inter-Gnb_Ho_Ng_Based_With_Feature_IWK
    [Tags]    QC_308667
    [Timeout]   2h
    [Setup]  Run Keywords
    ...  Check If Baseline SCF Is Uploaded  ${SCF_FILE}
    ...  AND  Set Test Variable  ${SCF_AND_UPGRADE_PASED}  True
    ...  AND  Add Configuration ID to Reporting Portal Report  scout_testline_name=${HOSTNAME}
    ...  AND  Set Library Search Order  Rjio_E2E_34_Intra-Frequency_And_Inter-Gnb_Ho_And_ANR_Ng_Based  admin
    ...  UTF_Logs_Collecting_For_HO  Process
    ...  AND  Set Test Variable  ${NR_CELL_ID1}  0
    ...  AND  Set Test Variable  ${NR_CELL_ID2}  61
    ...  AND  Set Test Variable  ${TARGET_SMOD_SERIAL_NUMBER}  DH222244824
    ...  AND  Set Test Variable  @{SOURCE_ATTENUATION_LIST}   0  5  10  15  25  30  35  45  55  90
    ...  AND  Set Test Variable  @{TARGET_ATTENUATION_LIST}  90  25  10  0  0  0  0  0  0  0
    ...  AND  Set Test Variable  ${TA_ATTENUATOR_CONFIG}  ${TA_ATTENUATOR_CONFIG}
    ...  AND  Set Test Variable  ${IS_HO_TEST_CASE}  True
    ...  AND  Set Test Variable  ${GNB_CPLANE_IP}  10.45.179.235
    ...  AND  Set Test Variable  ${APN_CONTAINS}  n26wro
    ...  AND  Set Test Variable  ${VIRTUALENV_DIR}  ${VIRTUALENV_DIR}
    ...  AND  Set Test Variable  ${SOURCE_CELL_ALIAS}  NR_CELL_0
    ...  AND  Set Test Variable  ${TARGET_CELL_ALIAS}  HO_NR_CELL_61
    ...  AND  Set Test Variable  ${MAX_UTF_LOGS_DELAY}  300s
    ...  AND  Set Test Variable  ${ADDITIONAL_UE_CAPABILITY}  ${ADDITIONAL_UE_CAPABILITY}
    ...  AND  Load Attenuation Config And Require Attenuator Setup  ${TA_ATTENUATOR_CONFIG}
    ...  AND  Create Alarm List  ${IGNORED_ALARMS_FOR_HO_TC}
    ...  AND  TC Setup
    Run Keyword  TC__Rjio_E2E_34_Intra-Frequency_And_Inter-Gnb_Ho_And_ANR_Ng_Based
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords  TC Teardown
    ...  AND  Run Keyword If  ${SHOULD_BE_REPORTED} and ${USE_SCOUT_INTERNAL_ID}  Report Test Case  qc_id=308667


Rjio_E2E_67_Mobility_UE_based_ANR_for_EUTRA_Neighbor
    [Tags]    QC_308668
    [Timeout]   2h
    [Setup]  Run Keywords
    ...  Check If Baseline SCF Is Uploaded  ${SCF_FILE}
    ...  AND  Set Test Variable  ${SCF_AND_UPGRADE_PASED}  True
    ...  AND  Add Configuration ID to Reporting Portal Report  scout_testline_name=${HOSTNAME}
    ...  AND  Set Library Search Order  Rjio_E2E_64_Mobility_IRAT_Data_HO_And_ANR  admin  UTF_Logs_Collecting_For_HO  Process
    ...  AND  Set Test Variable  ${NR_CELL_ID}  0
    ...  AND  Set Test Variable  ${LTE_CELL_ID}  1
    ...  AND  Set Test Variable  ${TARGET_SMOD_SERIAL_NUMBER}  DH222244824
    ...  AND  Set Test Variable  @{SOURCE_ATTENUATION_LIST}  0  5  10  15  25  35  40  45  55  90
    ...  AND  Set Test Variable  @{TARGET_ATTENUATION_LIST}  90  0  0  0  0  0  0  0  0  0
    ...  AND  Set Test Variable  ${TA_ATTENUATOR_CONFIG}  ${TA_ATTENUATOR_CONFIG}
    ...  AND  Set Test Variable  ${IS_HO_TEST_CASE}  False
    ...  AND  Set Test Variable  ${ENB_CPLANE_IP}  10.45.179.163
    ...  AND  Set Test Variable  ${APN_CONTAINS}  n26wro
    ...  AND  Set Test Variable  ${VIRTUALENV_DIR}  ${VIRTUALENV_DIR}
    ...  AND  Set Test Variable  ${SOURCE_CELL_ALIAS}  NR_CELL_0
    ...  AND  Set Test Variable  ${TARGET_CELL_ALIAS}  HO_LTE_CELL_1
    ...  AND  Set Test Variable  ${MAX_UTF_LOGS_DELAY}  300s
    ...  AND  Set Test Variable  ${ADDITIONAL_UE_CAPABILITY}  ${ADDITIONAL_UE_CAPABILITY}
    ...  AND  Load Attenuation Config And Require Attenuator Setup  ${TA_ATTENUATOR_CONFIG}
    ...  AND  Create Alarm List  ${IGNORED_ALARMS_FOR_HO_TC}
    ...  AND  TC Setup
    Run Keyword  TC__Rjio_E2E_64_Mobility_IRAT_Data_HO_And_ANR
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords  TC Teardown
    ...  AND  Run Keyword If  ${SHOULD_BE_REPORTED} and ${USE_SCOUT_INTERNAL_ID}  Report Test Case  qc_id=308668


Rjio_E2E_64_Mobility_IRAT_Data_HO_With_N26
    [Tags]    QC_308662
    [Timeout]   2h
    [Setup]  Run Keywords
    ...  Check If Baseline SCF Is Uploaded  ${SCF_FILE}
    ...  AND  Set Test Variable  ${SCF_AND_UPGRADE_PASED}  True
    ...  AND  Add Configuration ID to Reporting Portal Report  scout_testline_name=${HOSTNAME}
    ...  AND  Set Library Search Order  Rjio_E2E_64_Mobility_IRAT_Data_HO_And_ANR  admin  UTF_Logs_Collecting_For_HO  Process
    ...  AND  Set Test Variable  ${NR_CELL_ID}  0
    ...  AND  Set Test Variable  ${LTE_CELL_ID}  1
    ...  AND  Set Test Variable  ${TARGET_SMOD_SERIAL_NUMBER}  DH222244824
    ...  AND  Set Test Variable  @{SOURCE_ATTENUATION_LIST}  0  5  10  15  25  35  40  45  55  90
    ...  AND  Set Test Variable  @{TARGET_ATTENUATION_LIST}  90  0  0  0  0  0  0  0  0  0
    ...  AND  Set Test Variable  ${TA_ATTENUATOR_CONFIG}  ${TA_ATTENUATOR_CONFIG}
    ...  AND  Set Test Variable  ${IS_HO_TEST_CASE}  True
    ...  AND  Set Test Variable  ${ENB_CPLANE_IP}  10.45.179.163
    ...  AND  Set Test Variable  ${APN_CONTAINS}  n26wro
    ...  AND  Set Test Variable  ${VIRTUALENV_DIR}  ${VIRTUALENV_DIR}
    ...  AND  Set Test Variable  ${SOURCE_CELL_ALIAS}  NR_CELL_0
    ...  AND  Set Test Variable  ${TARGET_CELL_ALIAS}  HO_LTE_CELL_1
    ...  AND  Set Test Variable  ${MAX_UTF_LOGS_DELAY}  300s
    ...  AND  Set Test Variable  ${ADDITIONAL_UE_CAPABILITY}  ${ADDITIONAL_UE_CAPABILITY}
    ...  AND  Load Attenuation Config And Require Attenuator Setup  ${TA_ATTENUATOR_CONFIG}
    ...  AND  Create Alarm List  ${IGNORED_ALARMS_FOR_HO_TC}
    ...  AND  TC Setup
    Run Keyword  TC__Rjio_E2E_64_Mobility_IRAT_Data_HO_And_ANR
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords  TC Teardown
    ...  AND  Run Keyword If  ${SHOULD_BE_REPORTED} and ${USE_SCOUT_INTERNAL_ID}  Report Test Case  qc_id=308662


Voice_over_NR
    [Tags]    QC_308660
    [Timeout]   2h
    [Setup]  Run Keywords
    ...  Check If Baseline SCF Is Uploaded  ${SCF_FILE}
    ...  AND  Set Test Variable  ${SCF_AND_UPGRADE_PASED}  True
    ...  AND  Add Configuration ID to Reporting Portal Report  scout_testline_name=${HOSTNAME}
    ...  AND  Set Library Search Order  Voice_over_NR  admin  ca_IWK  ute_ue  Process  BuiltIn
    ...  AND  Set Test Variable  ${NR_CELL_ID}  0
    ...  AND  Set Test Variable  ${UE_CAPABILITY}  VoNR
    ...  AND  Set Test Variable  ${CELL_ALIAS}  NR_CELL_0
    ...  AND  Set Test Variable  ${SETUP_ATTENUATOR}  True
    ...  AND  Set Test Variable  ${PHONE_NUMBER}  0105
    ...  AND  Set Test Variable  ${CALL_DURATION}  360
    ...  AND  Set Test Variable  ${ADDITIONAL_UE_CAPABILITY}  ${ADDITIONAL_UE_CAPABILITY}
    ...  AND  Set Test Variable  ${MAX_DCAP_LOGS_DELAY}  150s
    ...  AND  Set Test Variable  ${COUNTER_PERIOD}  5
    ...  AND  Set Test Variable  ${APN_CONTAINS}  n26wro
    ...  AND  Set Test Variable  ${WINDOWS_SACK_PARENT_PATH}  C:/Users/wrodss/Documents/EmilSacks
    ...  AND  Set Test Variable  ${WINDOWS_PATH_TO_EMIL_EXE}  C:/Program Files/Emil/Emil
    ...  AND  Set Test Variable  ${WINDOWS_TEMP_LOGS_DIR}  C:/TEMP/dcap_logs
    ...  AND  Set Test Variable  ${PERFORM_SIP_VERIFICATION}  False
    ...  AND  Load Attenuation Config And Require Attenuator Setup  ${TA_ATTENUATOR_CONFIG}
    ...  AND  Import Variables  ${ABSTRACT_LIB_CONFIG}
    ...  AND  Create Alarm List  ${VONR_ALLOWED_FAULT_IDS}
    ...  AND  TC Setup
    Run Keyword  TC__Voice_over_NR
    Map Testcase  [1]${TEST_NAME}
    [Teardown]  Run Keywords  TC Teardown
    ...  AND  Run Keyword If  ${SHOULD_BE_REPORTED} and ${USE_SCOUT_INTERNAL_ID}  Report Test Case  qc_id=308660


Rjio_E2E_05_Radio_Lock_Unlock
    [Tags]    QC_308664
    [Timeout]   4h
    Check If Baseline SCF Is Uploaded  ${SCF_FILE}
    Set Test Variable  ${SCF_AND_UPGRADE_PASED}  True
    Set Library Search Order  RMOD_LOCK_UNLOCK  watchdog  RJIO_Data_Transfer
    Set Test Variable  ${L3_CALL_FOR_LAST_RMOD}  True
    Set Test Variable  ${NR_EXPECTED_DL_TPUT}  85
    Set Test Variable  ${NR_EXPECTED_UL_TPUT}  40
    Set Test Variable  ${NR_CELL_ID}  869744657
    Set Test Variable  ${CELL_ALIAS}  NR_CELL_17
    Set Test Variable  ${APN_CONTAINS}  n26wro
    Set Test Variable  ${ADDITIONAL_UE_CAPABILITY}  ${ADDITIONAL_UE_CAPABILITY}
    Load Attenuation Config And Require Attenuator Setup  ${TA_ATTENUATOR_CONFIG}

    E2E TL RU LOCK UNLOCK
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${RMOD_AMOUNT}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=308664
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=Data Transfer On RJIO For CSV4ALL

    [Teardown]  Run Keyword If  not ${SCF_AND_UPGRADE_PASED}  Report Test Case  qc_id=308664


Rjio_E2E_03_Power_Reset_Rf
    [Tags]    QC_308665
    [Timeout]   4h
    Check If Baseline SCF Is Uploaded  ${SCF_FILE}
    Set Test Variable  ${SCF_AND_UPGRADE_PASED}  True
    Set Library Search Order  RMOD_POWER_RESET  watchdog
    ${alarm_list} =  Create Custom Alarm List For RU Power Reset
    ${modifications_dict} =  Create Dictionary
    ...  custom_allowed_alarms=${alarm_list}
    ${node2}  ${nodes2} =  Temporarily Modify Node  ${NODE1}  ${modifications_dict}
    E2E TL RU POWER RESET
    ...  nodes_details=${nodes2}
    ...  test_nodes_details=${nodes2}
    ...  iterations_per_node=${RMOD_AMOUNT}
    ...  rmods_with_pdu_ports=${PDU_LIST}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=308665
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

    [Teardown]  Run Keyword If  not ${SCF_AND_UPGRADE_PASED}  Report Test Case  qc_id=308665


Rjio_E2E_24_Site_Reset_With_L3_Call
    [Tags]    QC_308666
    [Timeout]   8h
    Check If Baseline SCF Is Uploaded  ${SCF_FILE}
    Set Test Variable  ${SCF_AND_UPGRADE_PASED}  True
    Set Library Search Order  watchdog  RJIO_Data_Transfer
    Set Test Variable  ${L3_CALL_FOR_LAST_RMOD}  False
    Set Test Variable  ${NR_EXPECTED_DL_TPUT}  85
    Set Test Variable  ${NR_EXPECTED_UL_TPUT}  40
    Set Test Variable  ${NR_CELL_ID}  869744657
    Set Test Variable  ${CELL_ALIAS}  NR_CELL_17
    Set Test Variable  ${APN_CONTAINS}  n26wro
    Set Test Variable  ${ADDITIONAL_UE_CAPABILITY}  ${ADDITIONAL_UE_CAPABILITY}
    Load Attenuation Config And Require Attenuator Setup  ${TA_ATTENUATOR_CONFIG}

    E2E TL SITE RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${TEST_ITERATION_RESET_WITH_L3_CALL}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=308666
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=Data Transfer On RJIO For CSV4ALL

    [Teardown]  Run Keyword If  not ${SCF_AND_UPGRADE_PASED}  Report Test Case  qc_id=308666


E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Tags]    QC_308644
    [Timeout]   24h
    Check If Baseline SCF Is Uploaded  ${SCF_FILE}
    Set Test Variable  ${SCF_AND_UPGRADE_PASED}  True
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${TEST_ITERATION_CELL_LOCK}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=308644
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

    [Teardown]  Run Keyword If  not ${SCF_AND_UPGRADE_PASED}  Report Test Case  qc_id=308644


E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Tags]    QC_308647
    [Timeout]   24h
    Check If Baseline SCF Is Uploaded  ${SCF_FILE}
    Set Test Variable  ${SCF_AND_UPGRADE_PASED}  True
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${TEST_ITERATION_CELL_BLOCK}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=308647
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

    [Teardown]  Run Keyword If  not ${SCF_AND_UPGRADE_PASED}  Report Test Case  qc_id=308647


E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]    QC_308646
    [Timeout]   24h
    Check If Baseline SCF Is Uploaded  ${SCF_FILE}
    Set Test Variable  ${SCF_AND_UPGRADE_PASED}  True
    E2E TL RU RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${RMOD_AMOUNT}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=308646
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

    [Teardown]  Run Keyword If  not ${SCF_AND_UPGRADE_PASED}  Report Test Case  qc_id=308646


*** Keywords ***
Create Custom Alarm List For RU Power Reset
    ${alarm_list} =  Create List
    FOR  ${fault_id}  IN  @{CUSTOM_ALARMS_POWER_RESET}
        ${alarm} =  taf.ul.alarms_watchdog.Create Alarm  fault_id=${fault_id}
        Append To List  ${alarm_list}  ${alarm}
    END
    ${unit_paths} =  Create List
    ...  [RAN-PZ-WRO-RJio_2_1] MRBTS-53085/EQM-1/HWTOP-1/CABLINK-4
    ...  [RAN-PZ-WRO-RJio_2_1] MRBTS-53085/EQM-1/HWTOP-1/CABLINK-5
    ...  [RAN-PZ-WRO-RJio_2_1] MRBTS-53085/EQM-1/HWTOP-1/CABLINK-6
    FOR  ${unit_path}  IN  @{unit_paths}
        ${alarm} =  taf.ul.alarms_watchdog.Create Alarm  fault_id=1815  unit_path=${unit_path}
        Append To List  ${alarm_list}  ${alarm}
    END
    [Return]  ${alarm_list}
