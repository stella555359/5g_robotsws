*** Settings ***
Documentation
...   maintainer:  Suraj Singh
...   contact: suraj.singh@nokia.com
...   Test suite for CSV4ALL Tests for RJIO
Library         taf/rfrl/csv4all/CSV4AllTestCases.py
Library         taf.sbts.oam.coam.admin    WITH NAME    admin_api

*** Variables ***
${UUF_TEST_ITERATION}=                       4
${SITE_RESET_TEST_ITERATION}=                20
${RU_RESET_TEST_ITERATION}=                  20
${NR_LOCK_TEST_ITERATION}=                   10
${DELTA_COMMISSION_TEST_ITERATION}=          1
${L3_Call_TEST_ITERATION}=                   1
@{CUSTOM_ALARMS}=                4655    61524    61652    4654    61649    7220    61510     4203
${RP_CA}=                        VRF_RRM
${RP_LOCATION}=                  VRF_BLR1
${RP_ORGANIZATION}=              VRF_BLR1_T02
${SHOULD_BE_REPORTED}=           ${True}
@{CUSTOMERS_LIST}=              Generic
${DOWNLOAD_PATH}=               ${None}
${testline_name}=               7_2_UTE5GCLOUD1065
${QC_DOMAIN}=                   MN_RAN
${TEST_QC_ID_1}=                175137
${TEST_QC_ID_2}=                192940
${TEST_QC_ID_3}=                192939
${QC_PROJECT}=                  RAN_VRF
#    EXAMPLE PDU Variable
#    &{RU1}                     model=GUDE  host=10.XXX.XXX.XXX  port=@{3, }  version=8221-1
#    &{RU2}                     model=GUDE  host=10.XXX.XXX.XXX  port=@{4, }  version=8221-1
#    &{RU3}                     model=GUDE  host=10.XXX.XXX.XXX  port=@{5, }  version=8221-1
#    @{PDU_LIST}=               &{RU1}  &{RU2}  &{RU3}
${ALARM_TIMEOUT}=               120
${HARDWARE_CHECK_TIMEOUT}=      900
${DISABLE_KPI}=                 ${False}
${EMAIL_RECIPIENTS}=            suraj.singh@nokia.com
${MUMIN_CONFIG_FILE}=           ${None}
${VIRTUALENV_DIR}=              ${None}
${SERIAL_CONSOLE}=              ${False}
${l3_methodology}=          Attach_voice_data_transfer_L3Call
${BACKUP_SCF_DIR}=          ${None}
${MRBTS_ID}=                1065
${MP_build}=                ${None}
${INITIAL_SW}               SBTS00_ENB_9999_260321_000007
${TARGET_SW}                SBTS00_ENB_9999_260321_000007
${ITERATIONS}               1
&{NODE1}                    node_vm=10.58.238.166
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
@{NODES}                    ${NODE1}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
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
    Set Tags    QC_${TEST_QC_ID_3}
    Set Tags    QCP_${QC_PROJECT}
    Set Tags    QCD_${QC_DOMAIN}
    Set suite Variable    ${TEST_QC_ID}    ${TEST_QC_ID_3}
    Set suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
    Set suite Variable    ${QC_DOMAIN}    ${QC_DOMAIN}
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
    ...          qc_id=${TEST_QC_ID_3}
    ...          qc_project=${QC_PROJECT}



