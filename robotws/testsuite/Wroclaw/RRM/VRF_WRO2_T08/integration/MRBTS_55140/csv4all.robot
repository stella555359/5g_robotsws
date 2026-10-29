*** Settings ***
Documentation      Test suite for basic UUF OAM reset wo HWF tests in the 5g configuration
...                author: Lukasz Klosinski
...                modify: Sebastian Jakubik
...                maintainer: Sebastian Jakubik
...                contact: sebastian.jakubik@nokia.com

Library         taf/rfrl/csv4all/CSV4AllTestCases.py
Library         testsuite/Wroclaw/RRM//resources/csv4all_helpers.py
Library         OperatingSystem
Library         qc_id_helper.py
Library         testsuite/Wroclaw/RRM/resources/common/mount_netdrive.py
Library         DateTime
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/utility/csv_email_notification.py


Suite Setup        Mount Netdrive
Test Teardown      Run Keywords    Add Data To Testsuite Summary    AND
...                Run Keyword If Test Passed   Find Suspicious Prints In Passed Test
Suite Teardown     Send Suite Summary Email

*** Variables ***
${REPORT}                               ${True}
${LABEL}                                VRF_WRO2_T08_2xASIM_3xABIP_3xAHLOA_3xAHFIB_3xAEHC
${HOSTNAME}                             7_16_MRBTS-55140
${QC_DOMAIN}                            MN_RAN
${QC_PROJECT}                           RAN_VRF
${RP_CA}                                VRF_RRM
${RP_LOCATION}                          VRF_WRO2
${RP_ORGANIZATION}                      VRF_WRO2_T08
@{CUSTOMERS}                            TMO US
${EMAIL_RECIPIENTS}                     joanna.kogut-malarczyk@nokia.com,i_mn_ran_rd_vrf_wro2_8_uuf@nokia.com;bartosz.plewa@nokia.com

${SOURCE_SW}                            SBTS25R3_ENB_0000_001155_000000
${25R3_SW}                              SBTS25R3_ENB_0000_001165_000000
${26R1_SW}                              SBTS26R1_ENB_0000_000875_000000
${26R2_SW}                              SBTS26R2_ENB_0000_000243_000000
${TRUNK_SW}                             SBTS00_ENB_9999_260331_000003

@{CUSTOM_ALARMS}                7313  6134  6129  7513  7511  4681  6328  7316    4367    6202    4298    @{gps}    @{temp}    @{Xn}    @{X2}
@{gps}                          4122    4125    1898
@{temp}                         4589    7525    8000    4725
@{Xn}                           7306    7307    7313    7311
@{X2}                           7319
@{CRITICAL_FAULTS}              1907  1908  1900  1902  1906  1920

${END_DATE}                             2026-04-04 23:30
${one_iteration_last}                   28
${UPDATE_TEST_ITERATION}                1
${SITE_RESET_TEST_ITERATION}            20
${BTS_BLOCK_TEST_ITERATION}             20
${BBMOD_RESET_TEST_ITERATION}           20
${BBMOD_LOCK_TEST_ITERATION}            20
${RMOD_RESET_TEST_ITERATION}            20
${RMOD_LOCK_TEST_ITERATION}             20
${CELL_LOCK_TEST_ITERATION}             20

${STOP_TEST_AFTER_FAIL}                 ${False}
${TEST_ON_NODE}                         ${None}

@{25R3_NODE}                           ${MRBTS-55140_25R3_25R3}
@{26R1_NODE}                           ${MRBTS-55140_25R3_26R1}
@{26R2_NODE}                           ${MRBTS-55140_25R3_26R2}
@{TRUNK_NODE}                          ${MRBTS-55140_25R3_TRUNK}
@{ROLLBACK_26R1_25R3_NODE}             ${MRBTS-55140_26R1_25R3}
@{ROLLBACK_26R2_25R3_NODE}             ${MRBTS-55140_26R2_25R3}
@{ROLLBACK_TRUNK_25R3_NODE}            ${MRBTS-55140_TRUNK_25R3}

${USE_EXTERNAL_STORAGE}              ${True}
@{TEST_CASES}                        ${EMPTY}
@{TEST_RESULTS}                      ${EMPTY}
@{TEST_INFO}                         ${EMPTY}
@{IGNORED_PRINTS}                    INF/


&{MRBTS-55140_25R3_25R3}     node_alias=5G               testline_object=${tl.gnbs[0]}
...         source_sw=${SOURCE_SW}      target_sw=${25R3_SW}
...         custom_allowed_alarms=@{CUSTOM_ALARMS}
...         critical_alarms=@{CRITICAL_FAULTS}
...         testline_scout_name=${HOSTNAME}
...         secondary_vm=10.42.194.251
...         syslog_ignored_prints=${IGNORED_PRINTS}

&{MRBTS-55140_25R3_26R1}     node_alias=5G               testline_object=${tl.gnbs[0]}
...         source_sw=${25R3_SW}      target_sw=${26R1_SW}
...         custom_allowed_alarms=@{CUSTOM_ALARMS}
...         critical_alarms=@{CRITICAL_FAULTS}
...         testline_scout_name=${HOSTNAME}
...         secondary_vm=10.42.194.251
...         syslog_ignored_prints=${IGNORED_PRINTS}

&{MRBTS-55140_25R3_26R2}     node_alias=5G               testline_object=${tl.gnbs[0]}
...         source_sw=${25R3_SW}      target_sw=${26R2_SW}
...         custom_allowed_alarms=@{CUSTOM_ALARMS}
...         critical_alarms=@{CRITICAL_FAULTS}
...         testline_scout_name=${HOSTNAME}
...         secondary_vm=10.42.194.251
...         syslog_ignored_prints=${IGNORED_PRINTS}

&{MRBTS-55140_25R3_TRUNK}     node_alias=5G               testline_object=${tl.gnbs[0]}
...         source_sw=${25R3_SW}      target_sw=${TRUNK_SW}
...         custom_allowed_alarms=@{CUSTOM_ALARMS}
...         critical_alarms=@{CRITICAL_FAULTS}
...         testline_scout_name=${HOSTNAME}
...         secondary_vm=10.42.194.251
...         syslog_ignored_prints=${IGNORED_PRINTS}

&{MRBTS-55140_26R1_25R3}     node_alias=5G               testline_object=${tl.gnbs[0]}
...         source_sw=${26R1_SW}      target_sw=${25R3_SW}
...         custom_allowed_alarms=@{CUSTOM_ALARMS}
...         critical_alarms=@{CRITICAL_FAULTS}
...         testline_scout_name=${HOSTNAME}
...         secondary_vm=10.42.194.251
...         syslog_ignored_prints=${IGNORED_PRINTS}

&{MRBTS-55140_26R2_25R3}     node_alias=5G               testline_object=${tl.gnbs[0]}
...         source_sw=${26R2_SW}      target_sw=${25R3_SW}
...         custom_allowed_alarms=@{CUSTOM_ALARMS}
...         critical_alarms=@{CRITICAL_FAULTS}
...         testline_scout_name=${HOSTNAME}
...         secondary_vm=10.42.194.251
...         syslog_ignored_prints=${IGNORED_PRINTS}

&{MRBTS-55140_TRUNK_25R3}     node_alias=5G
...         testline_object=${tl.gnbs[0]}
...         source_sw=${TRUNK_SW}
...         target_sw=${25R3_SW}
...         custom_allowed_alarms=@{CUSTOM_ALARMS}
...         critical_alarms=@{CRITICAL_FAULTS}
...         testline_scout_name=${HOSTNAME}
...         secondary_vm=10.42.194.251
...         syslog_ignored_prints=${IGNORED_PRINTS}

*** Test Cases ***
OAM_UUF_Exploratory_Robustness_Test_Case_25R1
    ${TEST_QC_ID}=    Set Test ID    ${25R3_SW}
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI  ${25R3_NODE}  ${25R3_NODE}  1
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}
    ...     use_external_storage=${USE_EXTERNAL_STORAGE}
    ...     restore_to_target_sw=${True}

OAM_UUF_Exploratory_Robustness_Test_Case_25R2
    ${TEST_QC_ID}=    Set Test ID    ${26R1_SW}
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI  ${26R1_NODE}  ${26R1_NODE}  1
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}
    ...     use_external_storage=${USE_EXTERNAL_STORAGE}
    ...     restore_to_target_sw=${False}

BASIC_OAM_UUF_SCENARIO_CHECK
    ${TEST_QC_ID}=    Set Test ID    ${26R2_SW}
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI  ${26R2_NODE}  ${26R2_NODE}  1
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}
    ...     use_external_storage=${USE_EXTERNAL_STORAGE}
    ...     restore_to_target_sw=${False}

MRBTS-55140_OAM_UUF_Exploratory_Robustness_Test_Case
    ${TEST_QC_ID}=    Set Test ID    ${TRUNK_SW}
    E2E TL_UPGRADE_TEST  ${TRUNK_NODE}  ${TRUNK_NODE}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}
    ...     use_external_storage=${USE_EXTERNAL_STORAGE}

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    E2E TL SITE_RESET_WITH_OAM_KPI  ${TRUNK_NODE}  ${TRUNK_NODE}   ${SITE_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}

E2E_TL_RU_Reset_with_OAM_KPI
    E2E TL RU RESET WITH OAM KPI  ${TRUNK_NODE}  ${TRUNK_NODE}  ${RMOD_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT} insta


E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    E2E TL CAPACITY MODULE RESET WITH OAM KPI  ${TRUNK_NODE}  ${TRUNK_NODE}  ${BBMOD_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI  ${TRUNK_NODE}  ${TRUNK_NODE}  ${CELL_LOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}


E2E_TL_BTS_Block_Unblock
    E2E TL BTS BLOCK UNBLOCK  ${TRUNK_NODE}  ${TRUNK_NODE}  ${BTS_BLOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}

E2E_TL_RU_Lock_Unlock
    E2E TL RU LOCK UNLOCK  ${TRUNK_NODE}  ${TRUNK_NODE}  ${RMOD_LOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}

E2E_TL_Capacity_Module_Lock_Unlock
    E2E TL CAPACITY MODULE LOCK UNLOCK  ${TRUNK_NODE}  ${TRUNK_NODE}  ${BBMOD_LOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}

E2E_TL_SW_ROLLBACK
    E2E TL_ROLLBACK_TEST  ${ROLLBACK_TRUNK_25R3_NODE}  ${MRBTS-55140_TRUNK_25R3}    1
    ...     customers_list=${CUSTOMERS}

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    Calculate number of iterations
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI  ${TRUNK_NODE}  ${TRUNK_NODE}  ${UPDATE_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     use_external_storage=${USE_EXTERNAL_STORAGE}
    ...     restore_to_target_sw=${False}

*** Keywords ***
Calculate number of iterations
    ${now}=             get current date    result_format=datetime
    ${end}=             convert date    ${END_DATE}    result_format=datetime
    ${timedelta}=       subtract date from date    ${end}    ${now}
    ${diff_minutes}=    Evaluate    int(${timedelta} / 60)
    ${iterations}=      Evaluate    int(${diff_minutes} / ${one_iteration_last})
    Run Keyword If    ${iterations} < 0    Set Suite Variable    ${UPDATE_TEST_ITERATION}    1    ELSE
    ...               set suite variable    ${UPDATE_TEST_ITERATION}    ${iterations}
    log to console    Number of iterations: ${UPDATE_TEST_ITERATION}
