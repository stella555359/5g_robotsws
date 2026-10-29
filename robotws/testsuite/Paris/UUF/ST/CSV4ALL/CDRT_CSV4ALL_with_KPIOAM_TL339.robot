*** Settings ***
Documentation       CSV4ALL Test Suite
...                 Author: Abderrahmane NEZROUK
...                 Contact: abderrahmane.nezrouk@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Library             taf.transport.ssh                               WITH NAME    ssh
Library             taf.ue                                          WITH NAME    taf_ue
Library             OperatingSystem


*** Variables ***
${RP_CA}                   VRF_OAM
${RP_LOCATION}             VRF_NPS
${RP_ORGANIZATION}         VRF_NPS_T01
# ${EMAIL_RECIPIENTS}        timothy.kariithi@nokia.com
${QC_DOMAIN}               MN_RAN
# ${QC_ID}                   None
${QC_PROJECT}              RAN_ST
@{CUSTOMERS_LIST}          TMO US
${REPORT_COMMENT}          UUF_RFRL_Test
${TOPOLOGY}                CLOUD_5G_CLASSICAL_SA_ASIB_2xABIO_3xAHCA_3xAHPE_UTECA
${REPORT}                  True
${CALCULATE_KPI}           True

# Test case specific variables
${ITERATIONS_PER_NODE}     1
${USE_DCAP}                False
${USE_EXTERNAL_STORAGE}    False
# ${DOWNLOAD_PATH}           ${None}
${USE_TESTPACKAGE}         False
${RESTORE_TO_TARGET_SW}    True
${STOP_TEST_AFTER_FAIL}    False
${ARTIFACTORY_LOCATION}    espoo2
${PACKAGE_SUFFIX}          A54
${L3_CALL_METHOD}          None
${SYNCHRONIZE_SOFTWARE_ON_PASSIVE}    False

# SYSLOG
${DISABLE_SYSLOG_CHECK}=        ${False}
@{USER_SUSPICIOUS_PRINTS}=      @{EMPTY}
@{SYSLOG_IGNORED_PRINTS}=       INF

# Dir
${YAFT_PATH}               /home/ute
${VIRTUALENV_DIR}          /home/ute/test_repo

# delta SCF
${ONLINE_PARAMETER_DELTA}=      testsuite/Paris/UUF/ST/resources/other/online_delta_gNB_TL339.json
${SITE_RESET_DELTA}=            testsuite/Paris/UUF/ST/resources/other/SiteReset_delta_gNB_TL339.json
${NR_RAT_RESET_DELTA}=          testsuite/Paris/UUF/ST/resources/other/nr_rat_reset_delta_gNB_TL339.json
${WCDMA_RAT_RESET_DELTA}=       ${None}
${GSM_RAT_RESET_DELTA}=         ${None}
${LTE_RAT_RESET_DELTA}=         testsuite/Paris/UUF/ST/resources/other/lte_rat_reset_delta_eNB_TL339.json

# TIMEOUTS
${HARDWARE_CHECK_TIMEOUT}=      900
${ALARM_TIMEOUT}=               180

# Custom alarms
@{CUSTOM_ALARMS1}=    6322  61510  6261  6351   7509   4527   1900   6134   61524  4654  4655
@{CUSTOM_ALARMS2}=    61649  6129  62003  6450  4592  4420  4733   4203  8000   4731   4694  4001  1898  4003  4038  7513  1908
@{CUSTOM_ALARMS}=     @{CUSTOM_ALARMS1}  @{CUSTOM_ALARMS2}
@{CRITICAL_ALARMS}=     0010  0016  1806  1868  4341  4352  4383

# Builds
${ENB_BUILD}=           ${None}
${5G_SOURCE_SW}=        ${None}
${5G_TARGET_SW}=        ${ENB_BUILD}

# UEs
${UE_ALIAS_1}      UE_1
${CAPABILITIES}    REAL_UE
${DL_THROUGHPUT}   500 Mbits/sec
${UL_THROUGHPUT}   50 Mbits/sec
${DURATION}        30s
${PROTOCOL}        udp
${PACKET}          1400B
${DL_PORT}         3339
${UL_PORT}         3012

# Mumin
${SERIAL_CONSOLE}=              ${False}
${MUMIN}=                       ${False}
${MUMIN_CONFIG_FILE}=           ${None}

# Testlines
&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         source_sw=${5G_SOURCE_SW}
...                         target_sw=${5G_TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         critical_alarms=${CRITICAL_ALARMS}
...                         hw_to_onair_timeout=${HARDWARE_CHECK_TIMEOUT}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         critical_alarms=${CRITICAL_ALARMS}
...                         alarm_timer=${ALARM_TIMEOUT}
...                         serial_console=${SERIAL_CONSOLE}
...                         verify_syslog=${DISABLE_SYSLOG_CHECK}
...                         syslog_ignored_prints=${SYSLOG_IGNORED_PRINTS}
# ...                         mumin_config=${MUMIN_CONFIG_FILE}

# List of nodes passed to test keywords
@{NODES}                    ${NODE1}
@{UPGRADE_NODES}            ${NODE1}

# tests iteration loop
#####################################
${UPGRADE_LOOPS}=              ${3}
${ACTIVATION_RESET_LOOPS}=     ${20}
${SITE_RESET_LOOPS}=           ${3}
${BBMOD_RESET_LOOPS}=          ${3}
${RMOD_RESET_LOOPS}=           ${3}
${NRCEL_BLOCK_LOOPS}=          ${3}
${LNCEL_BLOCK_LOOPS}=          ${3}
${NRCEL_LOCK_LOOPS}=           ${3}
${LNCEL_LOCK_LOOPS}=           ${3}
${ONLINE_COMM_LOOPS}=          ${3}
${SETRESET_COMM_LOOPS}=        ${3}
${NRRATRESET_COMM_LOOPS}=      ${3}
${LTERATRESET_COMM_LOOPS}=     ${3}
${TEST_ITERATION}=             ${3}
#####################################

*** Test Cases ***
[1][1.0] E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    [Tags]      upgrade
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    ${NODES}
    ...    ${UPGRADE_NODES}
    ...    ${UPGRADE_LOOPS}
    ...    report=${REPORT}
    ...    calculate_kpi=${CALCULATE_KPI}
    ...    use_dcap=${USE_DCAP}
    ...    qc_domain=${QC_DOMAIN}
#    ...    qc_id=${QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report_comment=${REPORT_COMMENT}
    ...    topology=${TOPOLOGY}
    ...    use_external_storage=${USE_EXTERNAL_STORAGE}
#    ...    download_path=${DOWNLOAD_PATH}
    ...    use_testpackage=${USE_TESTPACKAGE}
    ...    restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    artifactory_location=${ARTIFACTORY_LOCATION}
    ...    package_suffix=${PACKAGE_SUFFIX}
    ...    l3_call_method=${L3_CALL_METHOD}
    ...    synchronize_software_on_passive=${SYNCHRONIZE_SOFTWARE_ON_PASSIVE}
    ...    yaft_path=${YAFT_PATH}
    ...    virtualenv_dir=${VIRTUALENV_DIR}

[1][1.0] E2E_TL_Activation_Reset_with_OAM_KPI
    # This testcase will activate sw in loops
    # Starting SW will be candidate software and will be activated alternately to candidate T1 software
    [Timeout]   24h
    [Tags]      reset
    E2E TL ACTIVATION RESET TEST
    ...    ${NODES}
    ...	   ${NODE1}
    ...    ${ACTIVATION_RESET_LOOPS}
    ...    report=${REPORT}
    ...    calculate_kpi=${CALCULATE_KPI}
    ...    use_dcap=${USE_DCAP}
    ...    qc_domain=${QC_DOMAIN}
#    ...    qc_id=${QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report_comment=${REPORT_COMMENT}
    ...    topology=${TOPOLOGY}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    l3_call_method=${L3_CALL_METHOD}

[1][1.0] E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   24h
    [Tags]      reset
    E2E TL SITE RESET WITH OAM KPI
    ...    ${NODES}
    ...    ${NODE1}
    ...    ${SITE_RESET_LOOPS}
    ...    report=${REPORT}
    ...    calculate_kpi=${CALCULATE_KPI}
    ...    use_dcap=${USE_DCAP}
    ...    qc_domain=${QC_DOMAIN}
#    ...    qc_id=${QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report_comment=${REPORT_COMMENT}
    ...    topology=${TOPOLOGY}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    l3_call_method=${L3_CALL_METHOD}

[1][1.0] E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]    24h
    [Tags]       bbmod
    e2e_tl_capacity_module_reset_with_oam_kpi
    ...    ${NODES}
    ...    ${NODE1}
    ...    ${BBMOD_RESET_LOOPS}
    ...    report=${REPORT}
    ...    calculate_kpi=${CALCULATE_KPI}
    ...    use_dcap=${USE_DCAP}
    ...    qc_domain=${QC_DOMAIN}
#    ...    qc_id=${QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report_comment=${REPORT_COMMENT}
    ...    topology=${TOPOLOGY}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    l3_call_method=${L3_CALL_METHOD}

[1][1.0] E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]    24h
    [Tags]       rmod
    e2e_tl_ru_reset_with_oam_kpi
    ...    ${NODES}
    ...    ${NODE1}
    ...    ${RMOD_RESET_LOOPS}
    ...    report=${REPORT}
    ...    calculate_kpi=${CALCULATE_KPI}
    ...    use_dcap=${USE_DCAP}
    ...    qc_domain=${QC_DOMAIN}
#    ...    qc_id=${QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report_comment=${REPORT_COMMENT}
    ...    topology=${TOPOLOGY}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    l3_call_method=${L3_CALL_METHOD}

[1][1.0] E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    [Tags]      cell
    e2e_tl_cell_lock_unlock_nr_with_oam_kpi
    ...    ${NODES}
    ...    ${NODE1}
    ...    ${NRCEL_LOCK_LOOPS}
    ...    report=${REPORT}
    ...    calculate_kpi=${CALCULATE_KPI}
    ...    use_dcap=${USE_DCAP}
    ...    qc_domain=${QC_DOMAIN}
#    ...    qc_id=${QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report_comment=${REPORT_COMMENT}
    ...    topology=${TOPOLOGY}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    l3_call_method=${L3_CALL_METHOD}

[1][1.0] E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   24h
    [Tags]      cell
    e2e_tl_cell_lock_unlock_lte_with_oam_kpi
    ...    ${NODES}
    ...    ${NODE1}
    ...    ${LNCEL_LOCK_LOOPS}
    ...    report=${REPORT}
    ...    calculate_kpi=${CALCULATE_KPI}
    ...    use_dcap=${USE_DCAP}
    ...    qc_domain=${QC_DOMAIN}
#    ...    qc_id=${QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report_comment=${REPORT_COMMENT}
    ...    topology=${TOPOLOGY}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    l3_call_method=${L3_CALL_METHOD}

[1][1.0] E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Timeout]   24h
    [Tags]      cell
    e2e_tl_cell_block_unblock_lte_with_oam_kpi
    ...    ${NODES}
    ...    ${NODE1}
    ...    ${LNCEL_BLOCK_LOOPS}
    ...    report=${REPORT}
    ...    calculate_kpi=${CALCULATE_KPI}
    ...    use_dcap=${USE_DCAP}
    ...    qc_domain=${QC_DOMAIN}
#    ...    qc_id=${QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report_comment=${REPORT_COMMENT}
    ...    topology=${TOPOLOGY}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    l3_call_method=${L3_CALL_METHOD}

[1][1.0] E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h
    [Tags]      cell
    e2e_tl_cell_block_unblock_nr_with_oam_kpi
    ...    ${NODES}
    ...    ${NODE1}
    ...    ${NRCEL_BLOCK_LOOPS}
    ...    report=${REPORT}
    ...    calculate_kpi=${CALCULATE_KPI}
    ...    use_dcap=${USE_DCAP}
    ...    qc_domain=${QC_DOMAIN}
#    ...    qc_id=${QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report_comment=${REPORT_COMMENT}
    ...    topology=${TOPOLOGY}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    l3_call_method=${L3_CALL_METHOD}

[1][1.0] E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    [Tags]   online
    e2e_tl_delta_commissioning_with_online_parameter_modification
    ...    ${NODES}
    ...    ${NODE1}
    ...    ${ONLINE_COMM_LOOPS}
    ...    ${ONLINE_PARAMETER_DELTA}
    ...    report=${REPORT}
    ...    calculate_kpi=${CALCULATE_KPI}
    ...    use_dcap=${USE_DCAP}
    ...    qc_domain=${QC_DOMAIN}
#    ...    qc_id=${QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report_comment=${REPORT_COMMENT}
    ...    topology=${TOPOLOGY}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    l3_call_method=${L3_CALL_METHOD}

[1][1.0] E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    [Tags]   setreset
    e2e_tl_delta_commissioning_with_site_reset_required
    ...    ${NODES}
    ...    ${NODE1}
    ...    ${SETRESET_COMM_LOOPS}
    ...    ${SITE_RESET_DELTA}
    ...    report=${REPORT}
    ...    calculate_kpi=${CALCULATE_KPI}
    ...    use_dcap=${USE_DCAP}
    ...    qc_domain=${QC_DOMAIN}
#    ...    qc_id=${QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report_comment=${REPORT_COMMENT}
    ...    topology=${TOPOLOGY}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    l3_call_method=${L3_CALL_METHOD}

[1][1.0] E2E_TL_Delta_Commissioning_With_NR_RAT_Reset_Required
    [Timeout]   24h
    [Tags]      NR
    e2e_tl_delta_commissioning_with_nr_rat_reset
    ...    ${NODES}
    ...    ${NODE1}
    ...    ${NRRATRESET_COMM_LOOPS}
    ...    ${NR_RAT_RESET_DELTA}
    ...    report=${REPORT}
    ...    calculate_kpi=${CALCULATE_KPI}
    ...    use_dcap=${USE_DCAP}
    ...    qc_domain=${QC_DOMAIN}
#    ...    qc_id=${QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report_comment=${REPORT_COMMENT}
    ...    topology=${TOPOLOGY}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    l3_call_method=${L3_CALL_METHOD}

[1][1.0] E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Timeout]   24h
    [Tags]      LTE
    e2e_tl_delta_commissioning_with_lte_rat_reset
    ...    ${NODES}
    ...    ${NODE1}
    ...    ${LTERATRESET_COMM_LOOPS}
    ...    ${LTE_RAT_RESET_DELTA}
    ...    report=${REPORT}
    ...    calculate_kpi=${CALCULATE_KPI}
    ...    use_dcap=${USE_DCAP}
    ...    qc_domain=${QC_DOMAIN}
#    ...    qc_id=${QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report_comment=${REPORT_COMMENT}
    ...    topology=${TOPOLOGY}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    l3_call_method=${L3_CALL_METHOD}
    # ...    ${l3_call_method}=Simple_L3_call

[1][1.0] ConfigCheck_RFRL_10_L3_call_After_All_RFRL_tests
    Simple_L3_call

*** Keywords ***
Simple_L3_call
    taf_ue.Require UE    ue_alias=${UE_ALIAS_1}    capabilities=${CAPABILITIES}
    taf_ue.Attach Ue  ue_alias=${UE_ALIAS_1}
    BuiltIn.Sleep    10s
    taf_ue.Start Data Transfer  ue_alias=${UE_ALIAS_1}  dt_name=DT_1  direction=dl  duration=${DURATION}  throughput=${DL_THROUGHPUT}
    ...    protocol=${PROTOCOL}  packet=${PACKET}    port=${DL_PORT}
    BuiltIn.Sleep    10s
    taf_ue.Start Data Transfer  ue_alias=${UE_ALIAS_1}  dt_name=DT_2  direction=ul  duration=${DURATION}  throughput=${UL_THROUGHPUT}
    ...    protocol=${PROTOCOL}  packet=${PACKET}    port=${UL_PORT}
    BuiltIn.Sleep    10s
    taf_ue.Await Data Transfer Finish    dt_name=DT_1
    BuiltIn.Sleep    10s
    taf_ue.Await Data Transfer Finish    dt_name=DT_2
    BuiltIn.Sleep    10s
    Log  Data transfer finish
    Run keyword and ignore error    taf_ue.Detach Ue    ${UE_ALIAS_1}
