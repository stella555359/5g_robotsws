*** Settings ***
Documentation
...   maintainer:  Chandan Kumar Mahapatra

Library         taf/rfrl/csv4all/CSV4AllTestCases.py
Library         taf.sbts.oam.coam.admin    WITH NAME    admin_api
Library    OperatingSystem
Library    String
Library    Collections
Library    DateTime
Library    SSHLibrary
Library    taf.sbts.oam.coam.admin    WITH NAME   coam


*** Variables ***
${UUF_TEST_ITERATION}=           3
@{CUSTOM_ALARMS}=                4655  4654  61524  61652  6261  6150  6202  4297  61649  6322  4548  4291  4681  4420  4405
${RP_CA}=                        VRF_RRM
${RP_LOCATION}=                  VRF_BLR1
${RP_ORGANIZATION}=              VRF_BLR1_T03
${SHOULD_BE_REPORTED}=           ${True}
@{CUSTOMERS_LIST}=               Generic
${DOWNLOAD_PATH}=                ${None}
${testline_name}=                1_2_UTE4GCLOUD82
${QC_DOMAIN}=                    MN_RAN
${TEST_QC_ID_1}=                 60586
${QC_PROJECT}=                  RAN_VRF
${ALARM_TIMEOUT}=               120
${HARDWARE_CHECK_TIMEOUT}=      900
${DISABLE_KPI}=                 ${False}
${EMAIL_RECIPIENTS}=            chandan.kumar_mahapatra@nokia.com
${MUMIN_CONFIG_FILE}=           ${None}
${VIRTUALENV_DIR}=              ${None}
${SERIAL_CONSOLE}=              ${False}
${l3_methodology}=          ${None}
${BACKUP_SCF_DIR}=          ${None}
${MRBTS_ID}=                1063
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