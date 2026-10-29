*** Settings ***
Documentation
...   contact: Mohan
...   contact: mohanavel.p@nokia.com

Force Tags   SBTS00    CA_VRF_BLR1  CRT
...  CLOUD_5G_1ASIL_1ABIO_1AHIB_1AHFB  STATE_CONFIGURED  QCP_RAN_VRF  QCD_MN_RAN

Library         taf/rfrl/csv4all/CSV4AllTestCases.py
Library         taf.sbts.oam.coam.admin    WITH NAME    admin_api

*** Variables ***
${UUF_TEST_ITERATION}=                       3
${SITE_RESET_TEST_ITERATION}=                20
@{CUSTOM_ALARMS}=                4655   61524   61652   6261   7300   6328   8000   4122   4123   4124   4405   4153   6328   4725
@{IGNORED_PRINTS}           is not defined in SysinfoQuota.xml. Please contact the owner
${RP_CA}=                        VRF_RRM
${RP_LOCATION}=                  VRF_BLR1
${RP_ORGANIZATION}=              VRF_BLR1_T11
${SHOULD_BE_REPORTED}=           ${True}
@{CUSTOMERS_LIST}=               TMO US
${DOWNLOAD_PATH}=               ${None}
${testline_name}=               1_2_CLOUD480
${QC_DOMAIN}=                   MN_RAN
${TEST_QC_ID_1}=                218269
${TEST_QC_ID_2}=                218270
${TEST_QC_ID_3}=                219350
${QC_PROJECT}=                  RAN_VRF
${ALARM_TIMEOUT}=               120
${HARDWARE_CHECK_TIMEOUT}=      900
${EMAIL_RECIPIENTS}=            mohanavel.p@nokia.com
${MUMIN_CONFIG_FILE}=           ${None}
${VIRTUALENV_DIR}=              ${None}
${SERIAL_CONSOLE}=              ${False}
${BACKUP_SCF_DIR}=          ${None}
${MRBTS_ID}=                30315
${MP_build}=                ${None}
${INITIAL_SW}               ${None}
${TARGET_SW}                ${None}
&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         syslog_ignored_prints=${IGNORED_PRINTS}
@{NODES}                    ${NODE1}

*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]   24h
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

E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   24h
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

