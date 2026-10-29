*** Settings ***
Documentation    UUF WRO23 Adam Brzezinski


Library        ute_ue
Library        taf/rfrl/csv4all/CSV4AllTestCases.py



Library        taf/rfrl/csv4all/resources/utilities/utilities.py

Library        testsuite/Wroclaw/RRM/resources/syslog_checker.py
Resource       taf/rfrl/uuf4all/uuf4all_keywords.robot
Resource       ../../feature_resources/RJIO/resources/RJIO_Data_Transfer.robot



Resource       ../../resources/attenuator.robot
Resource       ../../resources/ca_IWK.robot


*** Variables ***
${ABSTRACT_LIB_CONFIG}=         /home/ute/testline_configuration/7_16_UTE5GCLASSICAL501/ta_ue_config.yaml
${TA_ATTENUATOR_CONFIG}         /home/ute/testline_configuration/7_16_UTE5GCLASSICAL501/ta_ue_config.yaml
${HANGING_SCRIPT_PATH}          /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/VRF_WRO2_T023/feature_resources/RJIO/
...                             resources/hanging_check_4G_5G.py

${UPGRADE_ITERATION}            20
${UPGRADE_ITERATION_L3_CALL}    1
${COMMISSIONING_ITERATION}      5
${ACTIVATION_ITERATIONS}        20
${CELL_LOCK_ITERATION}          5
${RMOD_AMOUNT}                  5
${SITE_RESET_ITERATION}         200
@{CUSTOM_ALARMS}                4298  4564  4694  6150  6134  6351  7509  7513
...                             8150  61631  4527  7307  62003  1906  4681  8000  7311 7306
${REMOTE_VM_IP}                 ${None}
${LABEL}                        PZ2_WRO23_Adam_Brzezinski
${HOSTNAME}                     10_16_MRBTS-55326_RJIO
${SCOUT_TL_NAME}                10_16_MRBTS-55326_RJIO
${MPLANE}                       10.44.68.148
@{CRITICAL_FAULTS}              245  61009
${SHOULD_BE_REPORTED}           True
@{CUSTOMERS_LIST}               Reliance India
${5G_SOURCE_SW}                 SBTS26R1_ENB_0000_000522_000000
${5G_TARGET_SW}                 SBTS00_ENB_9999_260102_000002
${4G_SOURCE_SW}                 ${None}
${4G_TARGET_SW}                 ${None}
${DOWNLOAD_PATH}=               ${None}
${USE_BUILDS_STORAGE}=          ${True}
${RESTORE_TARGET_SW}=           ${True}
${PERFORM_UBOOT_DOWNGRADE}=     ${False}
${DISABLE_SYSLOG_CHECK}=        ${False}
@{USER_SUSPICIOUS_PRINTS}=      @{EMPTY}
${REPORT_COMMENT}=              ${None}
${ONLINE_PARAMETER_DELTA}       ${None}
${NR_RAT_RESET_DELTA}=          testsuite/Wroclaw/RRM/VRF_WRO2_T023/uuf/Adam_Brzezinski/resources/
...                             delta_nr_rat_reset.json
${SITE_RESET_DELTA}             ${None}
${USE_TEST_PACKAGES}            ${False}
${QC_DOMAIN}=                   MN_RAN_ST
${TEST_QC_ID}=                  ${None}
${QC_PROJECT}=                  RAN_ST
${ALARM_TIMEOUT}=               120
${HARDWARE_CHECK_TIMEOUT}=      900
${CALCULATE_KPI}                ${True}
@{SYSLOG_IGNORED_PRINTS}=       INF
${EMAIL_RECIPIENTS}=            adam.brzezinski@nokia.com


&{PDU_RU1}              model=GUDE  host=10.44.177.173  port=@{3, }  version=8041-1
&{PDU_RU2}              model=GUDE  host=10.44.177.173  port=@{4, }  version=8041-1
&{PDU_RU3}              model=GUDE  host=10.44.177.173  port=@{5, }  version=8041-1
&{RU1}                  L1251400628=${PDU_RU1}
&{RU2}                  L1251400644=${PDU_RU2}
&{RU3}                  L1251400643=${PDU_RU3}

@{PDU_LIST}=            ${RU1}  ${RU2}  ${RU3}

${SYNCHRONIZE_SOFTWARE_ON_PASSIVE}    ${False}
${USE_DCAP}                           ${False}
${STOP_TEST_AFTER_FAIL}               ${False}
${RP_CA}                              VRF_RRM
${RP_LOCATION}                        VRF_WRO2
${RP_ORGANIZATION}                    VRF_WRO2_T02_01

&{NODE1}                    node_vm=10.44.149.58
...                         source_sw=${5G_SOURCE_SW}
...                         target_sw=${5G_TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         testline_scout_name=${HOSTNAME}
...                         critical_alarms=${CRITICAL_FAULTS}
...                         alarm_timer=${ALARM_TIMEOUT}
...                         hw_to_onair_timeout=${HARDWARE_CHECK_TIMEOUT}
...                         verify_syslog=${DISABLE_SYSLOG_CHECK}


@{NODES}                    ${NODE1}



*** Test Cases ***

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    E2E TL DELTA COMMISSIONING WITH NR RAT RESET
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${COMMISSIONING_ITERATION}
    ...  delta=${NR_RAT_RESET_DELTA}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${None}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Activation_Reset_Test
    E2E TL ACTIVATION RESET TEST
	...  nodes_details=${NODES}
	...  test_nodes_details=${NODES}
	...  iterations_per_node=${ACTIVATION_ITERATIONS}
	...  report=${SHOULD_BE_REPORTED}
	...  calculate_kpi=${CALCULATE_KPI}
	...  use_dcap=${USE_DCAP}
	...  qc_domain=${QC_DOMAIN}
	...  qc_id=${TEST_QC_ID}
	...  qc_project=${QC_PROJECT}
	...  customers_list=${CUSTOMERS_LIST}
	...  report_comment=${REPORT_COMMENT}
	...  topology=${LABEL}
	...  use_external_storage=${USE_BUILDS_STORAGE}
	...  download_path=${DOWNLOAD_PATH}
	...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${CELL_LOCK_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${None}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}


E2E_TL_RU_Reset_with_OAM_KPI
    E2E TL RU RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${RMOD_AMOUNT}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}


E2e Tl Site Reset With Oam Kpi
    E2e Tl Site Reset With Oam Kpi
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=${SITE_RESET_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report_comment=${REPORT_COMMENT}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}
