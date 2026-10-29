*** Settings ***
Force tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS25R3     CLOUD_10_18_UTESRANRFSMTNRL126
Documentation       Test suite for basic CSV4ALL Tests in looP
...                 Author: Raluca

Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Library             Collections

Resource    ../../../test_resources/UUF_ACTIVATION_RESET.robot
Resource    ../../../test_resources/UUF_SW_UPGRADE.robot
Resource    ../../../test_resources/UUF_SW_UPGRADE_ROLLBACK.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS__STATE__SM_Power_Off_On.robot

*** Variables ***
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${SCF_ID}    01
#${custom_allowed_alarms}    4700,4773,1898,6134,6132,6129,7513,7511,7509,7107,10,16,61529,61649,4655,4654,4651,4592,61030,7116,1815,7317,4602,4681

# Email recipients for notifications (use nokia.com or internal.nsn.com domains)
# Multiple emails can be defined by separating them with commas
# Notifications include test start/end and failures
${EMAIL_RECIPIENTS}         None

# Software versions used in node definitions
${INITIAL_SW}
${TARGET_SW}
#${RAT_RESER_PARAMETER_DELTA_NR}               ${CURDIR}/delta_RAT_NR.json
${ONLINE_PARAMETER_DELTA_LTE}              ${CURDIR}/delta_ONLINE_LTE.json
${SITE_RESET_DELTA_NR}                     ${CURDIR}/delta_SITE_RESET_NR.json
#${SITE_RESET_DELTA_LTE}                    ${CURDIR}/delta_SITE_RESET_LTE.json

@{CUSTOMERS_LIST}=    MWINGZ
${CUSTOMER_MTNRL126}=    MWINGZ
${TEMP_ALLOWED_FAULTS}=
@{CUSTOM_ALARMS}
...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  61030  7116  2412  6202  7317  4602
...  4681  7316  4589

${INGORE_PRINT}    Failed call of stat() for source path (/ffs/run/pcf.xml) . Reason No such file or directory

${SCOUT_TL_NAME}    10_18_UTESRANRFSMTNRL126_1

${TEST_ITERATION}=              1

${REMOTE_VM_IP}=                ${None}
${REMOTE_MPLANE}=               ${None}
@{CRITICAL_FAULTS}=             @{EMPTY}
${USE_REMOTE_NODE}=             ${False}
${DISABLE_SYSLOG_CHECK}=        ${False}
@{USER_SUSPICIOUS_PRINTS}=      @{EMPTY}
${REPORT_COMMENT}=              ${None}
${SHOULD_BE_REPORTED}=          ${False}
${GSM_RAT_RESET_DELTA}=         ${None}
${QC_DOMAIN}=                   MN_RAN_VRF
${TEST_QC_ID}=                  ${None}  # SHOULD BE DIFFERENT FOR EACH TEST CASE ACCORDING TO QC_ID
${QC_PROJECT}=                  RAN_VRF
#    EXAMPLE PDU Variable
#    &{RU1}                     model=GUDE  host=10.XXX.XXX.XXX  port=@{3, }  version=8221-1
#    &{RU2}                     model=GUDE  host=10.XXX.XXX.XXX  port=@{4, }  version=8221-1
#    &{RU3}                     model=GUDE  host=10.XXX.XXX.XXX  port=@{5, }  version=8221-1
#    @{PDU_LIST}=               &{RU1}  &{RU2}  &{RU3}
${ALARM_TIMEOUT}=               120
${HARDWARE_CHECK_TIMEOUT}=      900
${DISABLE_KPI}=                 ${False}
@{SYSLOG_IGNORED_PRINTS}=       INF
#${EMAIL_RECIPIENTS}=            ${None}  # email or emails separate by comma eg. name@nokia.com,name@nokia.com
${MUMIN_CONFIG_FILE}=           ${None}  # PATH TO MUMIN/LMI BOARD CONFIG YAML FILE
${VIRTUALENV_DIR}=              ${None}  # path to virtual env used in starting syslog on remote vm
#    EXAMPLE PATH: /home/ute/.pyenv/versions/3.6.10/envs/test_repo/

# UTE testline initialization (VM definition in init must have a Connection object linking VM to BTS)
&{NODE1}                    testline_object=${tl.enbs[0]}
...                         node_alias=BTS1_SBTS
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         temporary_allowed_alarms=${TEMP_ALLOWED_FAULTS}
...                         testline_scout_name=10_18_UTESRANRFSMTNRL126_1




# List of nodes passed to test keywords
#@{NODES}                    ${NODE1}    ${NODE2}
#@{UPGRADE_NODES}            ${NODE2}    ${NODE1}

*** Test Cases ***
[1][1.0] Automated_RFS_UUF_SW_UPGRADE
    [Timeout]    24h
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}
    ...    AND    Set Test Variable    ${BTS2_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}
    ...    AND    Set Test Variable    ${BTS2_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}
    ...    4773,1815,7300,7513,7511,7509,4654,4651,1898,4452,4655,4654,61649,1898,4220,16,6327,7107,27,62003,7316,61030,2412,6202,61645,7317,4681,4589
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    4773,1815,7300,7513,7511,7509,4655,4654,4651,1898,4452,4654,61649,1898,4220,16,6327,7107,27,62003,7316,61030,2412,6202,61645,7317,4681,4589
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    syslog_ignored_prints=${INGORE_PRINT}
    ...    AND    Set Test Variable    ${SYNCHRONIZE_SW_ON_PASSIVE}    True
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${RESTORE_TO_TARGET_SW}    True
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    10
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    ${CUSTOMER_MTNRL126}
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${USE_DCAP}    False
    ...    AND    Set Test Variable    ${L3_CALL_METHOD}    None
    ...    AND    Set Test Variable    ${STOP_TEST_AFTER_FAIL}    False
    ...    AND    Set Test Variable    ${REPORT}    True
    ...    AND    Set Test Variable    ${QC_PROJECT}    None
    ...    AND    Set Test Variable    ${QC_DOMAIN}    None
    ...    AND    Set Test Variable    ${QC_ID}    None
    ...    AND    Set Test Variable    ${SW_BUILD}    None
    ...    AND    Set Test Variable    ${TOPOLOGY}    None
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR_T02
    ...    AND    Set Test Variable    ${TAGS}    CA_VRF_TSR
    ...    AND    Set Test Variable    ${SCOUT_TL_NAME}    10_18_UTESRANRFSMTNRL126_1
    ...    AND    Set Test Variable    ${RDC_CONFIG}    /home/ute/testline_configuration/10_18_UTESRANRFSMTNRL126/custom_rmod_setup.yaml
    ...    AND    UUF_SW_UPGRADE_ROLLBACK.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE_ROLLBACK
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE_ROLLBACK
    TC__UUF_SW_UPGRADE_ROLLBACK
    [Teardown]    Run Keywords    UUF_SW_UPGRADE_ROLLBACK.TC Teardown

[1][1.0] SW_Activation_Reset_in_loops
    [Timeout]    24h
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}
    ...    AND    Set Test Variable    ${BTS1_target_sw}
    ...    AND    Set Test Variable    ${BTS2_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}
    ...    4773,1815,7300,7513,7511,7509,4654,4651,1898,4452,4655,4654,61649,1898,4220,16,6327,7107,27,62003,7316,61030,7116,2412,61645,4602
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    4773,1815,7300,7513,7511,7509,4655,4654,4651,1898,4452,4654,61649,1898,4220,16,6327,7107,27,62003,7316,61030,7116,2412,61645,4602
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    10
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    ${CUSTOMER_MTNRL126}
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${KPI_NAMES}
    ...    AND    Set Test Variable    ${KPI_THRESHOLDS}
    ...    AND    Set Test Variable    ${USE_DCAP}    False
    ...    AND    Set Test Variable    ${L3_CALL_METHOD}    None
    ...    AND    Set Test Variable    ${STOP_TEST_AFTER_FAIL}    False
    ...    AND    Set Test Variable    ${REPORT}    True
    ...    AND    Set Test Variable    ${QC_PROJECT}    ${None}
    ...    AND    Set Test Variable    ${QC_DOMAIN}    ${None}
    ...    AND    Set Test Variable    ${QC_ID}    ${None}
    ...    AND    Set Test Variable    ${SW_BUILD}    ${None}
    ...    AND    Set Test Variable    ${TOPOLOGY}    ${None}
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR_T02
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_ACTIVATION_RESET.TC Setup
    ...    AND    Modify Resource Search Order    UUF_ACTIVATION_RESET
    ...    AND    Set Library Search Order    UUF_ACTIVATION_RESET
    TC__UUF_ACTIVATION_RESET
    [Teardown]    Run Keywords    UUF_ACTIVATION_RESET.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   24h

    ${CUSTOM_ALLOWED_ALARMS_BTS_1}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592  61030  7116  1815  7317,4602
    ...  61645  62003  2412  7316
    Set To Dictionary  ${NODE1}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_1}
    Set To Dictionary  ${NODE1}  testline_object=${tl.enbs[0]}
    ${NODES}=  Create List  ${NODE1}


    e2e_tl_site_reset_with_oam_kpi
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=10
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report=${True}
    ...  calculate_kpi=${True}
    ...  use_dcap=${False}
    ...  stop_test_after_fail=${False}
    ...  qc_domain=None
    ...  qc_id=None
    ...  qc_project=None
    ...  topology=${None}
    ...  report_comment=${None}

[1][1.0] E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h

    ${CUSTOM_ALLOWED_ALARMS_BTS_1}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592  61030  7116  1815  7317,4602
    Set To Dictionary  ${NODE1}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_1}
    Set To Dictionary  ${NODE1}  testline_object=${tl.enbs[0]}
    ${NODES}=  Create List  ${NODE1}

    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=3
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report=${True}
    ...  calculate_kpi=${True}
    ...  use_dcap=${False}
    ...  stop_test_after_fail=${False}
    ...  qc_domain=None
    ...  qc_id=None
    ...  qc_project=None
    ...  topology=${None}
    ...  report_comment=${None}


[1][1.0] E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   24h

    ${CUSTOM_ALLOWED_ALARMS_BTS_1}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592  61030  7116  1815  7317,4602
    Set To Dictionary  ${NODE1}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_1}
    Set To Dictionary  ${NODE1}  testline_object=${tl.enbs[0]}
    ${NODES}=  Create List  ${NODE1}

    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=3
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report=${True}
    ...  calculate_kpi=${True}
    ...  use_dcap=${False}
    ...  stop_test_after_fail=${False}
    ...  qc_domain=None
    ...  qc_id=None
    ...  qc_project=None
    ...  topology=${None}
    ...  report_comment=${None}

[1][1.0] E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h

    ${CUSTOM_ALLOWED_ALARMS_BTS_1}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592  61030  7116  1815  7317,4602
    Set To Dictionary  ${NODE1}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_1}
    Set To Dictionary  ${NODE1}  testline_object=${tl.enbs[0]}
    ${NODES}=  Create List  ${NODE1}

    e2e_tl_ru_reset_with_oam_kpi
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=20
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report=${True}
    ...  calculate_kpi=${True}
    ...  use_dcap=${False}
    ...  stop_test_after_fail=${False}
    ...  qc_domain=None
    ...  qc_id=None
    ...  qc_project=None
    ...  topology=${None}
    ...  report_comment=${None}
    ...  sw_build=${None}
    ...  l3_call_method=${None}

[1][3.0] E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI
    [Timeout]   24h

    ${CUSTOM_ALLOWED_ALARMS_BTS_1}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592  61030  7116  1815  7317,4602
    Set To Dictionary  ${NODE1}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_1}
    Set To Dictionary  ${NODE1}  testline_object=${tl.enbs[0]}
    ${NODES}=  Create List  ${NODE1}

    e2e_tl_cell_block_unblock_gsm_with_oam_kpi
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=3
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report=${True}
    ...  calculate_kpi=${True}
    ...  use_dcap=${False}
    ...  stop_test_after_fail=${False}
    ...  qc_domain=None
    ...  qc_id=None
    ...  qc_project=None
    ...  topology=${None}
    ...  report_comment=${None}

[1][1.0] E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h

    ${CUSTOM_ALLOWED_ALARMS_BTS_1}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592  61030  7116  7317  7316  62003
    ...  61645  4569
    ${CUSTOM_ALLOWED_ALARMS_BTS_2}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592  61030  7116  7317  7316  62003
    ...  61645  4569
    Set To Dictionary  ${NODE1}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_1}
    Set To Dictionary  ${NODE2}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_2}
    Log To Console    ${NODE1}
    Log To Console    ${NODE2}
    Set To Dictionary  ${NODE1}  testline_object=${tl.enbs[0]}
    Set To Dictionary  ${NODE2}  testline_object=${tl.gnbs[0]}
    Log To Console    ${NODE1}
    Log To Console    ${NODE2}
    ${NODES}=  Create List  ${NODE1}  ${NODE2}
    ${TEST_NODES}=  Create List  ${NODE2}

    e2e_tl_delta_commissioning_with_site_reset_required
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${TEST_NODES}
    ...  delta=${SITE_RESET_DELTA_NR}
    ...  iterations_per_node=1
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report=${True}
    ...  calculate_kpi=${True}
    ...  use_dcap=${False}
    ...  stop_test_after_fail=${False}
    ...  qc_domain=None
    ...  qc_id=None
    ...  qc_project=None
    ...  topology=${None}
    ...  report_comment=${None}

[1][1.0] E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h

    ${CUSTOM_ALLOWED_ALARMS_BTS_1}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592  61030  7116  7317  1815  61645
    ...  62003  2412  4569
    ${CUSTOM_ALLOWED_ALARMS_BTS_2}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592  61030  7116  7317  1815  61645
    ...  62003  2412  4569
    Set To Dictionary  ${NODE1}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_1}
    Set To Dictionary  ${NODE2}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_2}
    Log To Console    ${NODE1}
    Log To Console    ${NODE2}
    Set To Dictionary  ${NODE1}  testline_object=${tl.enbs[0]}
    Set To Dictionary  ${NODE2}  testline_object=${tl.gnbs[0]}
    Log To Console    ${NODE1}
    Log To Console    ${NODE2}
    ${NODES}=  Create List  ${NODE1}  ${NODE2}
    ${TEST_NODES}=  Create List  ${NODE2}

    e2e_tl_delta_commissioning_with_online_parameter_modification
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=1
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report=${True}
    ...  calculate_kpi=${True}
    ...  use_dcap=${False}
    ...  stop_test_after_fail=${False}
    ...  qc_domain=None
    ...  qc_id=None
    ...  qc_project=None
    ...  topology=${None}
    ...  report_comment=${None}
    ...  delta=${ONLINE_PARAMETER_DELTA_LTE}


[1][1.0] E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   24h
    Set To Dictionary  ${NODE1}  custom_allowed_alarms=${CUSTOM_ALARMS}
    Set To Dictionary  ${NODE2}  custom_allowed_alarms=${CUSTOM_ALARMS}
    Log To Console    ${NODE1}
    Log To Console    ${NODE2}
    Set To Dictionary  ${NODE1}  testline_object=${tl.enbs[0]}
    Set To Dictionary  ${NODE2}  testline_object=${tl.gnbs[0]}
    Log To Console    ${NODE1}
    Log To Console    ${NODE2}
    ${NODES}=  Create List  ${NODE1}  ${NODE2}
    ${TEST_NODES}=  Create List  ${NODE2}

    e2e_tl_delta_commissioning_with_nr_rat_reset
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${TEST_NODES}
    ...  delta=${RAT_RESET_DELTA_NR}
    ...  iterations_per_node=1
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report=${True}
    ...  calculate_kpi=${True}
    ...  use_dcap=${False}
    ...  stop_test_after_fail=${False}
    ...  qc_domain=None
    ...  qc_id=None
    ...  qc_project=None
    ...  topology=${None}
    ...  report_comment=${None}

[1][1.0] E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Timeout]   24h
    Set To Dictionary  ${NODE1}  custom_allowed_alarms=${CUSTOM_ALARMS}
    Set To Dictionary  ${NODE2}  custom_allowed_alarms=${CUSTOM_ALARMS}
    Log To Console    ${NODE1}
    Log To Console    ${NODE2}
    Set To Dictionary  ${NODE1}  testline_object=${tl.enbs[0]}
    Set To Dictionary  ${NODE2}  testline_object=${tl.gnbs[0]}
    Log To Console    ${NODE1}
    Log To Console    ${NODE2}
    ${NODES}=  Create List  ${NODE1}  ${NODE2}
    ${TEST_NODES}=  Create List  ${NODE1}

    e2e_tl_delta_commissioning_with_lte_rat_reset
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${TEST_NODES}
    ...  delta=${RAT_RESET_DELTA_LTE}
    ...  iterations_per_node=1
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report=${True}
    ...  calculate_kpi=${True}
    ...  use_dcap=${False}
    ...  stop_test_after_fail=${False}
    ...  qc_domain=None
    ...  qc_id=None
    ...  qc_project=None
    ...  topology=${None}
    ...  report_comment=${None}

[1][1.0] E2E_TL_Delta_Commissioning_With_GSM_Rat_Reset
    [Timeout]   24h

    ${CUSTOM_ALLOWED_ALARMS_BTS_1}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592  61030  7116  7317
    ${CUSTOM_ALLOWED_ALARMS_BTS_2}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592  61030  7116  7317
    Set To Dictionary  ${NODE1}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_1}
    Set To Dictionary  ${NODE2}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_2}
    Log To Console    ${NODE1}
    Log To Console    ${NODE2}
    Set To Dictionary  ${NODE1}  testline_object=${tl.enbs[0]}
    Set To Dictionary  ${NODE2}  testline_object=${tl.gnbs[0]}
    Log To Console    ${NODE1}
    Log To Console    ${NODE2}
    ${NODES}=  Create List  ${NODE1}  ${NODE2}
    ${TEST_NODES}=  Create List  ${NODE1}

    e2e_tl_delta_commissioning_with_gsm_rat_reset
     ...  nodes_details=${NODES}
    ...  test_nodes_details=${TEST_NODES}
    ...  delta=${SITE_RESET_DELTA_LTE}
    ...  iterations_per_node=1
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report=${True}
    ...  calculate_kpi=${True}
    ...  use_dcap=${False}
    ...  stop_test_after_fail=${False}
    ...  qc_domain=None
    ...  qc_id=None
    ...  qc_project=None
    ...  topology=${None}
    ...  report_comment=${None}

[1]SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    [Timeout]    34400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    20
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    LR240512220,LR242900458,LR240614441
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    ALL
    ...    AND    Set Test Variable    ${RMOD_POWER_ON_WRN_THR}    240
    ...    AND    Set Test Variable    ${RMOD_POWER_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RMOD_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${CB005763_CHECK}    False
    ...    AND    Set Test Variable    ${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order

[1]SBTS_SBTS_SBTS__STATE__SM_Power_Off_On
    [Timeout]    34400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts__state__sm_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    20
    ...    AND    Set Test Variable    ${BTS_TO_POWER_OFF}    ALL
    ...    AND    Set Test Variable    ${BTS1_POWER_ON_WRN_THR}    660
    ...    AND    Set Test Variable    ${BTS2_POWER_ON_WRN_THR}    660
    ...    AND    Set Test Variable    ${BTS3_POWER_ON_WRN_THR}    660
    ...    AND    Set Test Variable    ${SBTS_POWER_ON_MAX_WAIT_TIME}    900

    ...    AND    SBTS_SBTS_SBTS__STATE__SM_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS__STATE__SM_Power_Off_On
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS__STATE__SM_Power_Off_On
    TC__SBTS_SBTS_SBTS__STATE__SM_Power_Off_On
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS__STATE__SM_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order