*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in looP
...                 Author: Vlad

Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Library             Collections

Resource    ../../../test_resources/UUF_SITE_RESET_WITHOUT_HWF.robot
Resource    ../../../test_resources/UUF_SW_UPGRADE.robot
Resource    ../../../test_resources/UUF_SW_UPGRADE_ROLLBACK.robot
Resource    ../../../test_resources/UUF_ACTIVATION_RESET.robot
Resource    ../../../test_resources/UUF_SITE_RESET.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874.robot

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${POWER_ON_FLAG}    ${True}

# Email recipients for notifications (use nokia.com or internal.nsn.com domains)
# Multiple emails can be defined by separating them with commas
# Notifications include test start/end and failures
${EMAIL_RECIPIENTS}         None

# Software versions used in node definitions
${INITIAL_SW}                              SBTS25R1_ENB_0000_000127_000000
${TARGET_SW}                               SBTS25R1_ENB_0000_000152_000000
${ONLINE_PARAMETER_DELTA_NR}               ${CURDIR}/delta_ONLINE_NR.json
${ONLINE_PARAMETER_DELTA_LTE}              ${CURDIR}/delta_ONLINE_LTE.json
${SITE_RESET_DELTA_NR}                     ${CURDIR}/delta_SITE_RESET_NR.json
${SITE_RESET_DELTA_LTE}                    ${CURDIR}/delta_SITE_RESET_LTE.json

@{CUSTOMERS_LIST}=    Generic
${TEMP_ALLOWED_FAULTS}=
@{CUSTOM_ALARMS}
...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651

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
${QC_DOMAIN}=                   MN_RAN_ST
${TEST_QC_ID}=                  ${None}  # SHOULD BE DIFFERENT FOR EACH TEST CASE ACCORDING TO QC_ID
${QC_PROJECT}=                  RAN_ST
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
&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         node_alias=BTS1_5G
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         temporary_allowed_alarms=${TEMP_ALLOWED_FAULTS}



# Alias for easier identification of nodes in logs for multinode configurations
&{NODE2}                    testline_object=${tl.enbs[0]}
...                         node_alias=BTS2_4G
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         temporary_allowed_alarms=${TEMP_ALLOWED_FAULTS}


# List of nodes passed to test keywords
#@{NODES}                    ${NODE1}    ${NODE2}
#@{UPGRADE_NODES}            ${NODE2}    ${NODE1}

*** Test Cases ***
RMOD_fan_temp_control_profiles_CB010874
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__rmod_fan_temp_control_profiles_cb010874_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_CLIMATE_CONTROL_PROFILING_LIST}    Optimized Cooling,Linear,Low Noise
    ...    AND    Set Test Variable    ${RM_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}    L1202503076,L1205002792,L1205002791
    ...    AND    Set Test Variable    ${start_climateControlProfiling_value}    Optimized Cooling

    ...    AND    SBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874
    TC__SBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874.TC Teardown
    ...    AND    Restore Resource Search Order


[1]UUF_SW_UPGRADE_ROLLBACK
    [Timeout]    86400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS1_source_sw}
    ...    AND    Set Test Variable    ${BTS2_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}
    ...    AND    Set Test Variable    ${BTS2_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}
    ...    4773,1898,4655,4654,61649
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    4773,1898,4655,4654,61649
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${SYNCHRONIZE_SW_ON_PASSIVE}    True
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ROLLBACK_REVERSE_ORDER}    True
    ...    AND    Set Test Variable    ${RESTORE_TO_TARGET_SW}    True
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    5
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${KPI_NAMES}
    ...    AND    Set Test Variable    ${KPI_THRESHOLDS}
    ...    AND    Set Test Variable    ${ADDITIONAL_KPI}
    ...    AND    Set Test Variable    ${SWCONFIG_MODIFICATION}    True
    ...    AND    Set Test Variable    ${HW_FILE_MIGRATION_CHECK}    True
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
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T05
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_SW_UPGRADE_ROLLBACK.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE_ROLLBACK
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE_ROLLBACK
    TC__UUF_SW_UPGRADE_ROLLBACK
    [Teardown]    Run Keywords    UUF_SW_UPGRADE_ROLLBACK.TC Teardown
    ...    AND    Restore Resource Search Order

[1]UUF_SITE_RESET
    [Timeout]    86400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}	${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}	${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}	SBTS00_ENB_9999_250829_000007
    ...    AND    Set Test Variable    ${BTS2_source_sw}	SBTS00_ENB_9999_250829_000007
    ...    AND    Set Test Variable    ${BTS3_source_sw}
    ...    AND    Set Test Variable    ${BTS4_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}	SBTS00_ENB_9999_250829_000007
    ...    AND    Set Test Variable    ${BTS2_target_sw}	SBTS00_ENB_9999_250829_000007
    ...    AND    Set Test Variable    ${BTS3_target_sw}
    ...    AND    Set Test Variable    ${BTS4_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}
    ...    4773,1815,7300,7513,7511,7509,4655,4654,4651,1898,4452,4655,4654,61649,4651,1898,4220,16,6327
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    4773,1815,7300,7513,7511,7509,4655,4654,4651,1898,4452,4655,4654,61649,4651,1898,4220,16,6327
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS3_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS4_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    15
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
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
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T05
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_SITE_RESET.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SITE_RESET
    ...    AND    Set Library Search Order    UUF_SITE_RESET
    TC__UUF_SITE_RESET
    [Teardown]    Run Keywords    UUF_SITE_RESET.TC Teardown
    ...    AND    Restore Resource Search Order

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    ${CUSTOM_ALLOWED_ALARMS_BTS_1}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  7516  16  61529  61649  4655  4654  4651  4592
    ${CUSTOM_ALLOWED_ALARMS_BTS_2}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  7516  16  61529  61649  4655  4654  4651  4592
    Set To Dictionary  ${NODE1}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_1}
    Set To Dictionary  ${NODE2}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_2}
    Set To Dictionary  ${NODE1}  testline_object=${tl.enbs[0]}
    Set To Dictionary  ${NODE2}  testline_object=${tl.gnbs[0]}
    ${NODES}=  Create List  ${NODE1}  ${NODE2}
    ${TEST_NODES}=  Create List  ${NODE1}


    e2e_tl_delta_commissioning_with_site_reset_required
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${TEST_NODES}
    ...  delta=${SITE_RESET_DELTA_LTE}
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


E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h

    ${CUSTOM_ALLOWED_ALARMS_BTS_1}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  7516  16  61529  61649  4655  4654  4651  4592
    ${CUSTOM_ALLOWED_ALARMS_BTS_2}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  7516  16  61529  61649  4655  4654  4651  4592
    Set To Dictionary  ${NODE1}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_1}
    Set To Dictionary  ${NODE2}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_2}
    ${NODES}=  Create List  ${NODE1}

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
    ...  delta=${ONLINE_PARAMETER_DELTA_NR}


E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h

    ${CUSTOM_ALLOWED_ALARMS_BTS_1}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592
    ${CUSTOM_ALLOWED_ALARMS_BTS_2}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592
    Set To Dictionary  ${NODE1}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_1}
    Set To Dictionary  ${NODE2}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_2}
    Set To Dictionary  ${NODE1}  testline_object=${tl.enbs[0]}
    Set To Dictionary  ${NODE2}  testline_object=${tl.gnbs[0]}
    ${NODES}=  Create List  ${NODE1}  ${NODE2}

    e2e_tl_ru_reset_with_oam_kpi
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=9
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


E2E_TL_BBMOD_Reset_with_OAM_KPI
    [Timeout]   24h

    ${CUSTOM_ALLOWED_ALARMS_BTS_1}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592
    ${CUSTOM_ALLOWED_ALARMS_BTS_2}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592
    Set To Dictionary  ${NODE1}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_1}
    Set To Dictionary  ${NODE2}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_2}
    Set To Dictionary  ${NODE1}  testline_object=${tl.enbs[0]}
    Set To Dictionary  ${NODE2}  testline_object=${tl.gnbs[0]}
    ${NODES}=  Create List  ${NODE1}  ${NODE2}

    e2e_tl_capacity_module_reset_with_oam_kpi
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=6
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


E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h

    ${CUSTOM_ALLOWED_ALARMS_BTS_1}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592
    ${CUSTOM_ALLOWED_ALARMS_BTS_2}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592
    Set To Dictionary  ${NODE1}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_1}
    Set To Dictionary  ${NODE2}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_2}
    Set To Dictionary  ${NODE1}  testline_object=${tl.enbs[0]}
    Set To Dictionary  ${NODE2}  testline_object=${tl.gnbs[0]}
    ${NODES}=  Create List  ${NODE1}  ${NODE2}

    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=9
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


E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   24h

    ${CUSTOM_ALLOWED_ALARMS_BTS_1}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592  49
    ${CUSTOM_ALLOWED_ALARMS_BTS_2}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592  49
    Set To Dictionary  ${NODE1}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_1}
    Set To Dictionary  ${NODE2}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_2}
    ${NODES}=  Create List  ${NODE1}  ${NODE2}

    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=12
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


E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Timeout]   24h

    ${CUSTOM_ALLOWED_ALARMS_BTS_1}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592  49
    ${CUSTOM_ALLOWED_ALARMS_BTS_2}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592  49
    Set To Dictionary  ${NODE1}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_1}
    Set To Dictionary  ${NODE2}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_2}
    Set To Dictionary  ${NODE1}  testline_object=${tl.enbs[0]}
    Set To Dictionary  ${NODE2}  testline_object=${tl.gnbs[0]}
    ${NODES}=  Create List  ${NODE1}  ${NODE2}

    E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=27
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



[1]UUF_ACTIVATION_RESET
    [Timeout]    44400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}    SBTS00_ENB_9999_250829_000007
    ...    AND    Set Test Variable    ${BTS2_source_sw}    SBTS00_ENB_9999_250829_000007
    ...    AND    Set Test Variable    ${BTS3_source_sw}
    ...    AND    Set Test Variable    ${BTS4_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}    SBTS00_ENB_9999_250829_000007
    ...    AND    Set Test Variable    ${BTS2_target_sw}    SBTS00_ENB_9999_250829_000007
    ...    AND    Set Test Variable    ${BTS3_target_sw}
    ...    AND    Set Test Variable    ${BTS4_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}
    ...    4773,1815,7300,7513,7511,7509,4655,4654,4651,1898,4452,4655,4654,61649,4651,1898,4220,16,6327
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    4773,1815,7300,7513,7511,7509,4655,4654,4651,1898,4452,4655,4654,61649,4651,1898,4220,16,6327
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS3_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS4_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    15
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${KPI_NAMES}    kpi1a,kpi2a,kpi3a
    ...    AND    Set Test Variable    ${KPI_THRESHOLDS}    897,897,897,897
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
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T05
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_ACTIVATION_RESET.TC Setup
    ...    AND    Modify Resource Search Order    UUF_ACTIVATION_RESET
    ...    AND    Set Library Search Order    UUF_ACTIVATION_RESET
    TC__UUF_ACTIVATION_RESET
    [Teardown]    Run Keywords    UUF_ACTIVATION_RESET.TC Teardown
    ...    AND    Restore Resource Search Order


E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h

    ${CUSTOM_ALLOWED_ALARMS_BTS_1}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592  49
    ${CUSTOM_ALLOWED_ALARMS_BTS_2}=  Create List
    ...  4700  4773  1898  6134  6132  6129  7513  7511  7509  7107  10  16  61529  61649  4655  4654  4651  4592  49
    Set To Dictionary  ${NODE1}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_1}
    Set To Dictionary  ${NODE2}  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_BTS_2}
    ${NODES}=  Create List  ${NODE1}  ${NODE2}

    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=45
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


[1]UUF_SITE_RESET_WITHOUT_HWF
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}    SBTS25R1_ENB_0000_000152_000000
    ...    AND    Set Test Variable    ${BTS2_source_sw}    SBTS25R1_ENB_0000_000152_000000
    ...    AND    Set Test Variable    ${BTS3_source_sw}
    ...    AND    Set Test Variable    ${BTS4_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}    SBTS25R1_ENB_0000_000164_000000
    ...    AND    Set Test Variable    ${BTS2_target_sw}    SBTS25R1_ENB_0000_000164_000000
    ...    AND    Set Test Variable    ${BTS3_target_sw}
    ...    AND    Set Test Variable    ${BTS4_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}
    ...    4773,1815,7300,7513,7511,7509,7319,4385,7107,4452,4655,4654,61649,4651,1898,4220,16,6327
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    4773,1815,7300,7513,7511,7509,7319,4385,7107,4452,4655,4654,61649,4651,1898,4220,16,6327
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    15
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
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
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T05
    ...    AND    Set Test Variable    ${TAGS}    CA_VRF_TSR2
    ...    AND    UUF_SITE_RESET_WITHOUT_HWF.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SITE_RESET_WITHOUT_HWF
    ...    AND    Set Library Search Order    UUF_SITE_RESET_WITHOUT_HWF
    TC__UUF_SITE_RESET_WITHOUT_HWF
    [Teardown]    Run Keywords    UUF_SITE_RESET_WITHOUT_HWF.TC Teardown
    ...    AND    Restore Resource Search Order


[1]UUF_SW_UPGRADE
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}    SBTS25R1_ENB_0000_000152_000000
    ...    AND    Set Test Variable    ${BTS2_source_sw}    SBTS25R1_ENB_0000_000152_000000
    ...    AND    Set Test Variable    ${BTS3_source_sw}
    ...    AND    Set Test Variable    ${BTS4_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}    SBTS25R1_ENB_0000_000164_000000
    ...    AND    Set Test Variable    ${BTS2_target_sw}    SBTS25R1_ENB_0000_000164_000000
    ...    AND    Set Test Variable    ${BTS3_target_sw}
    ...    AND    Set Test Variable    ${BTS4_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}
    ...    4773,1815,7300,7513,7511,7509,7319,4385,7107,4452,4655,4654,61649,4651,1898,4220,16,6327
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    4773,1815,7300,7513,7511,7509,7319,4385,7107,4452,4655,4654,61649,4651,1898,4220,16,6327
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${SYNCHRONIZE_SW_ON_PASSIVE}    True
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    1
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
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
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T05
    ...    AND    Set Test Variable    ${TAGS}    CA_VRF_TSR2
    ...    AND    UUF_SW_UPGRADE.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE
    TC__UUF_SW_UPGRADE
    [Teardown]    Run Keywords    UUF_SW_UPGRADE.TC Teardown
    ...    AND    Restore Resource Search Order


E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_single_node_upgrade
    # This testcase will upgrade and rollback only node1 in configuration consisting of 3 nodes (defined in NODES variable)
    # Nodes which are not currently upgraded will still be monitored for any impacting faults
    [Timeout]   24h
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_multiple_node_upgrade
    # This testcase will upgrade and rollback all nodes in configuration consisting of 3 nodes (defined in NODES variable)
    # Nodes will be upgraded in sequence provided in the UPGRADE_NODES,
    # by changing the sequence of the list you change the upgrade sequence
    # In this example: upgrade node2, upgrade node1, upgrade node3, rollback node2, rollback node1, rollback node3
    # Nodes which are not currently upgraded will still be monitored for any impacting faults
    [Timeout]   24h
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${UPGRADE_NODES}  ${ITERATIONS}

E2E_TL_Parallel_SW_Upgrade_Rollback_with_OAM_KPI
    # This testcase will upgrade and rollback all nodes simultaneously
    # It will first download the software to all of them and wait for all to finish
    # Then simultaneous activation of all nodes will be performed
    [Timeout]   24h
    E2E PARALLEL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODES}  ${ITERATIONS}

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI    ${NODES}  ${NODE1}   ${ITERATIONS}


E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}


E2E_TL_BTS_Block_Unblock
    [Timeout]   24h
    E2E TL BTS BLOCK UNBLOCK    ${NODES}  ${NODE1}  ${ITERATIONS}

E2E_TL_RU_Lock_Unlock
    [Timeout]   24h
    E2E TL RU LOCK UNLOCK    ${NODES}  ${NODE1}  ${ITERATIONS}

E2E_TL_Capacity_Module_Lock_Unlock
    [Timeout]   24h
    E2E TL CAPACITY MODULE LOCK UNLOCK    ${NODES}  ${NODE1}  ${ITERATIONS}

[2]UUF_SITE_RESET_WITHOUT_HWF
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}    SBTS25R1_ENB_0000_000152_000000
    ...    AND    Set Test Variable    ${BTS2_source_sw}    SBTS25R1_ENB_0000_000152_000000
    ...    AND    Set Test Variable    ${BTS3_source_sw}
    ...    AND    Set Test Variable    ${BTS4_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}    SBTS25R1_ENB_0000_000164_000000
    ...    AND    Set Test Variable    ${BTS2_target_sw}    SBTS25R1_ENB_0000_000164_000000
    ...    AND    Set Test Variable    ${BTS3_target_sw}
    ...    AND    Set Test Variable    ${BTS4_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}
    ...    4773,1815,7300,7513,7511,7509,7319,4385,7107,4452,4655,4654,61649,4651,1898,4220,16,6327
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    4773,1815,7300,7513,7511,7509,7319,4385,7107,4452,4655,4654,61649,4651,1898,4220,16,6327
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    1
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${USE_DCAP}    False
    ...    AND    Set Test Variable    ${L3_CALL_METHOD}    None
    ...    AND    Set Test Variable    ${STOP_TEST_AFTER_FAIL}    False
    ...    AND    Set Test Variable    ${REPORT}    False
    ...    AND    Set Test Variable    ${QC_PROJECT}    None
    ...    AND    Set Test Variable    ${QC_DOMAIN}    None
    ...    AND    Set Test Variable    ${QC_ID}    None
    ...    AND    Set Test Variable    ${SW_BUILD}    None
    ...    AND    Set Test Variable    ${TOPOLOGY}    None
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T05
    ...    AND    Set Test Variable    ${TAGS}    CA_VRF_TSR2
    ...    AND    UUF_SITE_RESET_WITHOUT_HWF.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SITE_RESET_WITHOUT_HWF
    ...    AND    Set Library Search Order    UUF_SITE_RESET_WITHOUT_HWF
    TC__UUF_SITE_RESET_WITHOUT_HWF
    [Teardown]    Run Keywords    UUF_SITE_RESET_WITHOUT_HWF.TC Teardown
    ...    AND    Restore Resource Search Order