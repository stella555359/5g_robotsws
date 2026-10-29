*** Settings ***
Documentation
...   maintainer:  arunkumar.a
...   contact: arunkumar.a@nokia.com
...   Test suite for CSV4ALL Tests for NBIOT

Force Tags   SBTS00    CA_VRF_BLR1  CRT  4G_FDD_CRT
...  CLOUD_SRAN_L_1ASIM_1ABIP_2AREA  STATE_CONFIGURED  QCP_RAN_VRF  QCD_MN_RAN

Library         taf/rfrl/csv4all/CSV4AllTestCases.py
# Library          taf.rfrl.csv4all
Library         taf.sbts.oam.coam.admin    WITH NAME    admin_api

*** Variables ***
${UUF_TEST_ITERATION}=                       3
${SITE_RESET_TEST_ITERATION}=                20
${RU_RESET_TEST_ITERATION}=                  10
${NR_LOCK_TEST_ITERATION}=                   10
${DELTA_COMMISSION_TEST_ITERATION}=          1
${L3_Call_TEST_ITERATION}=                   2
@{CUSTOM_ALARMS}=                4655    61524    61652    4654    61649    7220    61510     4203    4291
${RP_CA}=                        VRF_RRM
${RP_LOCATION}=                  VRF_BLR1
${RP_ORGANIZATION}=              VRF_BLR1_T02
${SHOULD_BE_REPORTED}=           ${True}
@{CUSTOMERS_LIST}=               BHARTI
${DOWNLOAD_PATH}=               ${None}
${testline_name}=               1_2_UTE4GCLOUD465
${QC_DOMAIN}=                   MN_RAN
${TEST_QC_ID_1}=                219528
${TEST_QC_ID_2}=                187529
${QC_PROJECT}=                  RAN_VRF
#    EXAMPLE PDU Variable
#    &{RU1}                     model=GUDE  host=10.XXX.XXX.XXX  port=@{3, }  version=8221-1
#    &{RU2}                     model=GUDE  host=10.XXX.XXX.XXX  port=@{4, }  version=8221-1
#    &{RU3}                     model=GUDE  host=10.XXX.XXX.XXX  port=@{5, }  version=8221-1
#    @{PDU_LIST}=               &{RU1}  &{RU2}  &{RU3}
${ALARM_TIMEOUT}=               120
${HARDWARE_CHECK_TIMEOUT}=      900
${DISABLE_KPI}=                 ${False}
${EMAIL_RECIPIENTS}=            mujeeba.farheen@nokia.com
${MUMIN_CONFIG_FILE}=           ${None}
${VIRTUALENV_DIR}=              ${None}
${SERIAL_CONSOLE}=              ${False}
${l3_methodology}=          Attach_voice_data_transfer_L3Call
${BACKUP_SCF_DIR}=          ${None}
${MRBTS_ID}=                1465
${MP_build}=                ${None}
${INITIAL_SW}               SBTS00_ENB_9999_250224_000011
${TARGET_SW}                SBTS00_ENB_9999_250225_000008
${ITERATIONS}               1
&{NODE1}                    testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
@{NODES}                    ${NODE1}

*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI

    Set Tags    QC_${TEST_QC_ID_1}
    Set Tags    QCP_${QC_PROJECT}
    Set Tags    QCD_${QC_DOMAIN}
    Set suite Variable    ${TEST_QC_ID}    ${TEST_QC_ID_1}
    Set suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
    Set suite Variable    ${QC_DOMAIN}    ${QC_DOMAIN}
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${UUF_TEST_ITERATION}
    ...          report=${SHOULD_BE_REPORTED}
    ...          calculate_kpi=${True}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          use_dcap=${False}
    ...          download_path=${DOWNLOAD_PATH}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID_1}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Activation_Reset_with_OAM_KPI

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

E2E_TL_Site_Reset_with_OAM_KPI
    [Tags]
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  900
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    E2E TL SITE RESET WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Tags]      M
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  900
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_project=${QC_PROJECT}

E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI
    [Tags]      M
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  900
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_project=${QC_PROJECT}

E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]      M
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  900
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    E2E_TL_RU_Reset_with_OAM_KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_project=${QC_PROJECT}