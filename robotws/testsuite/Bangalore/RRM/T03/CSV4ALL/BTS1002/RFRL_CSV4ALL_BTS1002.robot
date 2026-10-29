*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Damian Pietrzyk
...                 Contact: damian.pietrzyk@nokia.com

Library             taf.rfrl.csv4all.CSV4AllTestCases


*** Variables ***
${RP_CA}                        VRF_RRM
${RP_LOCATION}                  VRF_BLR1
${RP_ORGANIZATION}              VRF_BLR1_T03
@{CUSTOMERS_LIST}               Generic
${EMAIL_RECIPIENTS}             ${None}
${INITIAL_SW}                   SBTS00_ENB_9990_250821_000008
${TARGET_SW}                    SBTS00_ENB_9999_251106_000010
@{CUSTOM_ALLOWED}
...    4655
...    4654
...    61524
...    61652
...    6261
...    6150
...    6202
...    4297
...    61649
...    6322
...    4548
...    4291
...    4420
# 4655
@{CRITICAL_FAULTS}              @{EMPTY}
&{NODE2}                        node_vm=10.58.238.103
...                             source_sw=${INITIAL_SW}
...                             target_sw=${TARGET_SW}
...                             custom_allowed_alarms=${CUSTOM_ALLOWED}
${SHOULD_BE_REPORTED}           True
${RESTORE_TARGET_SW}            True
${QC_DOMAIN}                    MN_RAN
${QC_PROJECT}                   RAN_VRF
${REPORT_COMMENT}               ${None}
${TEST_QC_ID_1}                 112487
${TEST_QC_ID_2}                 187872
${TEST_QC_ID_3}                 187871
# List of nodes passed to test keywords
@{NODES}                        ${NODE2}

&{OAM_KPI_TARGETS_UPGRADE}      kpi2a=500
...                             kpi2b=600
...                             kpi2c=415
...                             kpi2d=425

&{OAM_KPI_TARGETS_RESET}        kpi1a=500
...                             kpi1b=600
...                             kpi1c=415


*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KP
    [Tags]    crt
    [Timeout]    24h
    Set Tags    QC_${TEST_QC_ID_1}
    Set Tags    QCP_${QC_PROJECT}
    Set Tags    QCD_${QC_DOMAIN}
    Set suite Variable    ${TEST_QC_ID}    ${TEST_QC_ID_1}
    Set suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
    Set suite Variable    ${QC_DOMAIN}    ${QC_DOMAIN}
    Set Test Variable    &{OAM_KPI_TARGETS}    kpi2a=500
    ...    kpi2b=1240
    ...    kpi2c=500
    ...    kpi2d=630SBTS00_ENB_9999_250515_000008
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}    ${NODE2}    3
    ...    report=${SHOULD_BE_REPORTED}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    restore_to_target_sw=${RESTORE_TARGET_SW}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID_1}
    ...    qc_project=${QC_PROJECT}

E2E_TL_Activation_Reset_with_OAM_KPI
    [Tags]    crt
    [Timeout]    24h
    Set Tags    QC_${TEST_QC_ID_2}
    Set Tags    QCP_${QC_PROJECT}
    Set Tags    QCD_${QC_DOMAIN}
    Set suite Variable    ${TEST_QC_ID}    ${TEST_QC_ID_2}
    Set suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
    Set suite Variable    ${QC_DOMAIN}    ${QC_DOMAIN}
    E2E TL ACTIVATION RESET TEST
    ...    ${NODES}
    ...    ${NODE2}
    ...    iterations_per_node=3
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report_comment=${REPORT_COMMENT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID_2}
    ...    qc_project=${QC_PROJECT}
    ...    report=${SHOULD_BE_REPORTED}
    ...    kpi_targets=${OAM_KPI_TARGETS_RESET}

E2E_TL_Site_Reset_with_OAM_KPI
    [Tags]    crt
    [Timeout]    24h
    Set Tags    QC_${TEST_QC_ID_3}
    Set Tags    QCP_${QC_PROJECT}
    Set Tags    QCD_${QC_DOMAIN}
    Set suite Variable    ${TEST_QC_ID}    ${TEST_QC_ID_3}
    Set suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
    Set suite Variable    ${QC_DOMAIN}    ${QC_DOMAIN}
    E2E TL SITE RESET WITH OAM KPI
    ...    ${NODES}
    ...    ${NODE2}
    ...    iterations_per_node=20
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report_comment=${REPORT_COMMENT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID_3}
    ...    qc_project=${QC_PROJECT}
    ...    report=${SHOULD_BE_REPORTED}
    ...    kpi_targets=${OAM_KPI_TARGETS_RESET}
