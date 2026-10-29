*** Settings ***
Documentation
...   maintainer:  hari.mada@nokia
...   contact: hari.mada@nokia
...   Test suite for CSV4ALL
...   robot -d /home/ute/robotlte/uuf_logs/uuf_reset_$(date +%Y_%m_%d_%T) -b debug.log -L TRACE ./rfrl_suite_reset.robot


Library         taf/rfrl/csv4all/CSV4AllTestCases.py
Library         taf.sbts.oam.coam.admin    WITH NAME    admin_api

*** Variables ***
${UUF_TEST_ITERATION}=                       20
${SITE_RESET_TEST_ITERATION}=                20
@{CUSTOM_ALARMS}=                4655  4654  61524  61652  6261  6150  6202  4297  61649  6322  4548  4291  4681  4420  4405  6261  4681
${RP_CA}=                        VRF_RRM
${RP_LOCATION}=                  VRF_BLR1
${RP_ORGANIZATION}=              VRF_BLR1_T03
${SHOULD_BE_REPORTED}=           ${True}
@{CUSTOMERS_LIST}=              Generic
${DOWNLOAD_PATH}=               ${None}
${testline_name}=               1_2_UTE4GCLOUD259
${QC_DOMAIN}=                   MN_RAN
${TEST_QC_ID_1}=                187630
${TEST_QC_ID_2}=                187629
${QC_PROJECT}=                  RAN_VRF
${ALARM_TIMEOUT}=               120
${HARDWARE_CHECK_TIMEOUT}=      900
${DISABLE_KPI}=                 ${False}
${EMAIL_RECIPIENTS}=            hari.mada@nokia.com
${MUMIN_CONFIG_FILE}=           ${None}
${VIRTUALENV_DIR}=              ${None}
${SERIAL_CONSOLE}=              ${False}
${BACKUP_SCF_DIR}=          ${None}
${MRBTS_ID}=                962372
${MP_build}=                ${None}
${INITIAL_SW}               SBTS00_ENB_9999_250904_000006
${TARGET_SW}                SBTS00_ENB_9999_250904_000006
${ITERATIONS}               1
&{NODE1}                    node_vm=10.43.54.117
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
@{NODES}                    ${NODE1}

*** Test Cases ***
E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   24h
    Set Tags    QC_${TEST_QC_ID_1}
    Set Tags    QCP_${QC_PROJECT}
    Set Tags    QCD_${QC_DOMAIN}
    Set suite Variable    ${TEST_QC_ID}    ${TEST_QC_ID_1}
    Set suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
    Set suite Variable    ${QC_DOMAIN}    ${QC_DOMAIN}
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  900
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    E2E TL SITE RESET WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${UUF_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID_1}
    ...          qc_project=${QC_PROJECT}


E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
    Set Tags    QC_${TEST_QC_ID_2}
    Set Tags    QCP_${QC_PROJECT}
    Set Tags    QCD_${QC_DOMAIN}
    Set suite Variable    ${TEST_QC_ID}    ${TEST_QC_ID_2}
    Set suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
    Set suite Variable    ${QC_DOMAIN}    ${QC_DOMAIN}
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  900
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    E2E TL ACTIVATION RESET TEST
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID_2}
    ...          qc_project=${QC_PROJECT}