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


Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_10_18_UTESRANRFSMTNRL100
...    SBTS00   STATE_SKIP_AGENT    CRT


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
RFS_SW_migration_and_feature_activation_CNI-96509_TMO
    [Tags]  QC_229585
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
    ...    4773,1898,4655,4654,61649,4564,16,4452,4694
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    4773,1898,4655,4654,61649,4564
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${SYNCHRONIZE_SW_ON_PASSIVE}    False
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ROLLBACK_REVERSE_ORDER}    True
    ...    AND    Set Test Variable    ${RESTORE_TO_TARGET_SW}    False
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    1
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
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR_T06
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_SW_UPGRADE_ROLLBACK.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE_ROLLBACK
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE_ROLLBACK
    TC__UUF_SW_UPGRADE_ROLLBACK
    [Teardown]    Run Keywords    UUF_SW_UPGRADE_ROLLBACK.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated_RFS_UUF_SW_UPGRADE_ROLLBACK
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
    ...    4773,1898,4655,4654,61649,4564,16,4452,4694,7107
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    4773,1898,4655,4654,61649,4564
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${SYNCHRONIZE_SW_ON_PASSIVE}    False
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ROLLBACK_REVERSE_ORDER}    True
    ...    AND    Set Test Variable    ${RESTORE_TO_TARGET_SW}    True
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    3
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
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR_T06
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_SW_UPGRADE_ROLLBACK.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE_ROLLBACK
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE_ROLLBACK
    TC__UUF_SW_UPGRADE_ROLLBACK
    [Teardown]    Run Keywords    UUF_SW_UPGRADE_ROLLBACK.TC Teardown
    ...    AND    Restore Resource Search Order


[1][2.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
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
    ...    4773,1898,4655,4654,61649,4564,16,4452,4694
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    4773,1898,4655,4654,61649,4564
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${SYNCHRONIZE_SW_ON_PASSIVE}    False
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ROLLBACK_REVERSE_ORDER}    True
    ...    AND    Set Test Variable    ${RESTORE_TO_TARGET_SW}    True
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    1
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
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR_T06
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_SW_UPGRADE_ROLLBACK.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE_ROLLBACK
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE_ROLLBACK
    TC__UUF_SW_UPGRADE_ROLLBACK
    [Teardown]    Run Keywords    UUF_SW_UPGRADE_ROLLBACK.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]    86400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}	${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}	${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}
    ...    AND    Set Test Variable    ${BTS2_source_sw}
    ...    AND    Set Test Variable    ${BTS3_source_sw}
    ...    AND    Set Test Variable    ${BTS4_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}
    ...    AND    Set Test Variable    ${BTS2_target_sw}
    ...    AND    Set Test Variable    ${BTS3_target_sw}
    ...    AND    Set Test Variable    ${BTS4_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}
    ...    4773,1898,4655,4654,61649,16,7107,4452
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    4773,1898,4655,4654,61649
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS3_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS4_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    5
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
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR_T06
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_SITE_RESET.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SITE_RESET
    ...    AND    Set Library Search Order    UUF_SITE_RESET
    TC__UUF_SITE_RESET
    [Teardown]    Run Keywords    UUF_SITE_RESET.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] SW_Activation_Reset_in_loops
    [Timeout]    86400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}
    ...    AND    Set Test Variable    ${BTS2_source_sw}
    ...    AND    Set Test Variable    ${BTS3_source_sw}
    ...    AND    Set Test Variable    ${BTS4_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}
    ...    AND    Set Test Variable    ${BTS2_target_sw}
    ...    AND    Set Test Variable    ${BTS3_target_sw}
    ...    AND    Set Test Variable    ${BTS4_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}
    ...    4773,1898,4655,4654,61649,4564,16,4452,4694
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    4773,1898,4655,4654,61649
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS3_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS4_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    5
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
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR_T06
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_ACTIVATION_RESET.TC Setup
    ...    AND    Modify Resource Search Order    UUF_ACTIVATION_RESET
    ...    AND    Set Library Search Order    UUF_ACTIVATION_RESET
    TC__UUF_ACTIVATION_RESET
    [Teardown]    Run Keywords    UUF_ACTIVATION_RESET.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated_RFS_SBTS_SBTS_Fan temperature control profiles for 5G RUs_CB010874
    [Timeout]    34400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__rmod_fan_temp_control_profiles_cb010874_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    1
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
