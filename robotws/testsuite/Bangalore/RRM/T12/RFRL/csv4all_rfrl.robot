*** Settings ***
Documentation
...                 contact: Bhakti Patel
...                 contact: bhakti.ka_patel@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Library             taf.sbts.oam.coam.admin    WITH NAME    admin_api
Library             OperatingSystem

Suite Setup         Cleanup Robot LTE Workspace

Force Tags
...    sbts00
...    ca_vrf_blr1
...    crt
...    cloud_5g_asoe_2aqqj_avqa_ahpb_ahpj
...    state_configured
...    qcp_ran_vrf
...    qcd_mn_ran


*** Variables ***
${UUF_TEST_ITERATION}=              3
${SITE_RESET_TEST_ITERATION}=       20
${OTHER_TC_ITERATION}=               6
@{CUSTOM_ALARMS}=                   2002    4654    4655    8000    61652    61524    61649
${RP_CA}=                           VRF_RRM
${RP_LOCATION}=                     VRF_BLR1
${RP_ORGANIZATION}=                 VRF_BLR1_T12
${SHOULD_BE_REPORTED}=              ${True}
@{CUSTOMERS_LIST}=                  Reliance India
${DOWNLOAD_PATH}=                   ${None}
${testline_name}=                   7_2_UTE5GCLOUD495
${QC_DOMAIN}=                       MN_RAN
${TEST_QC_ID_1}=                    224215
${TEST_QC_ID_2}=                    224213
${TEST_QC_ID_3}=                    224214
${TEST_QC_ID_4}=                    226223
${TEST_QC_ID_5}=                    226231
${TEST_QC_ID_6}=                    226226

${QC_PROJECT}=                      RAN_VRF
${ALARM_TIMEOUT}=                   120
${HARDWARE_CHECK_TIMEOUT}=          900
${EMAIL_RECIPIENTS}=                bhakti.ka_patel@nokia.com
${MUMIN_CONFIG_FILE}=               ${None}
${VIRTUALENV_DIR}=                  ${None}
${SERIAL_CONSOLE}=                  ${False}
${BACKUP_SCF_DIR}=                  ${None}
${MRBTS_ID}=                        495
${MP_build}=                        ${None}
${INITIAL_SW}                       ${None}
${TARGET_SW}                        ${None}

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${INITIAL_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}

@{NODES}                            ${NODE1}


*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]    24h
    Set Tags    QC_${TEST_QC_ID_1}
    Set Tags    QCP_${QC_PROJECT}
    Set Tags    QCD_${QC_DOMAIN}
    Set suite Variable    ${TEST_QC_ID}    ${TEST_QC_ID_1}
    Set suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
    Set suite Variable    ${QC_DOMAIN}    ${QC_DOMAIN}
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${UUF_TEST_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}
    ...    calculate_kpi=${True}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    use_dcap=${False}
    ...    download_path=${DOWNLOAD_PATH}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID_1}
    ...    qc_project=${QC_PROJECT}


E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    24h
    Set Tags    QC_${TEST_QC_ID_2}
    Set Tags    QCP_${QC_PROJECT}
    Set Tags    QCD_${QC_DOMAIN}
    Set suite Variable    ${TEST_QC_ID}    ${TEST_QC_ID_2}
    Set suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
    Set suite Variable    ${QC_DOMAIN}    ${QC_DOMAIN}
    Set Test Variable    ${ALARM_TIMEOUT}    180
    Set Test Variable    ${HARDWARE_CHECK_TIMEOUT}    900
    Set Test Variable    @{SYSLOG_IGNORED_PRINTS}    INF
    E2E TL ACTIVATION RESET TEST
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID_2}
    ...    qc_project=${QC_PROJECT}


E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]    24h
    Set Tags    QC_${TEST_QC_ID_3}
    Set Tags    QCP_${QC_PROJECT}
    Set Tags    QCD_${QC_DOMAIN}
    Set suite Variable    ${TEST_QC_ID}    ${TEST_QC_ID_3}
    Set suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
    Set suite Variable    ${QC_DOMAIN}    ${QC_DOMAIN}
    Set Test Variable    ${ALARM_TIMEOUT}    180
    Set Test Variable    ${HARDWARE_CHECK_TIMEOUT}    900
    Set Test Variable    @{SYSLOG_IGNORED_PRINTS}    INF
    E2E TL SITE RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID_3}
    ...    qc_project=${QC_PROJECT}


E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    Set Tags    QC_${TEST_QC_ID_4}
    Set Tags    QCP_${QC_PROJECT}
    Set Tags    QCD_${QC_DOMAIN}
    Set suite Variable    ${TEST_QC_ID}    ${TEST_QC_ID_4}
    Set suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
    Set suite Variable    ${QC_DOMAIN}    ${QC_DOMAIN}
    E2E TL RU RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${OTHER_TC_ITERATION}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID_4}
    ...    qc_project=${QC_PROJECT}


E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    Set Tags    QC_${TEST_QC_ID_5}
    Set Tags    QCP_${QC_PROJECT}
    Set Tags    QCD_${QC_DOMAIN}
    Set suite Variable    ${TEST_QC_ID}    ${TEST_QC_ID_5}
    Set suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
    Set suite Variable    ${QC_DOMAIN}    ${QC_DOMAIN}
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${OTHER_TC_ITERATION}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID_5}
    ...    qc_project=${QC_PROJECT}


E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h
    Set Tags    QC_${TEST_QC_ID_6}
    Set Tags    QCP_${QC_PROJECT}
    Set Tags    QCD_${QC_DOMAIN}
    Set suite Variable    ${TEST_QC_ID}    ${TEST_QC_ID_6}
    Set suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
    Set suite Variable    ${QC_DOMAIN}    ${QC_DOMAIN}
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${OTHER_TC_ITERATION}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID_6}
    ...    qc_project=${QC_PROJECT}


*** Keywords ***
Cleanup Robot LTE Workspace
    Run Keyword And Ignore Error
    ...    Remove Directory    MN/UTE/robotlte    recursive=True

