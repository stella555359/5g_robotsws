*** Settings ***
Documentation
...                author: Lukasz Klosinski
...                modify: Marcin Bednarski
...                maintainer: Marcin Bednarski
...                contact: marcin.bednarski@nokia.com
...                Test suite for basic UUF OAM reset wo HWF tests in the 4g5g configuration:

Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Library            testsuite/Wroclaw/RRM//resources/csv4all_helpers.py

Test Teardown      Run Keyword If Test Passed   Find Suspicious Prints In Passed Test

*** Variables ***
${RP_CA}                                VRF_RRM
${RP_LOCATION}                          VRF_WRO2
${RP_ORGANIZATION}                      VRF_WRO2_T08_01
${EMAIL_RECIPIENTS}                     i_mi_mn_ran_rd_vrf_wro2_8@nokia.com
@{CUSTOMERS}                            Generic
${SOURCE_SW}                            ${None}
${TARGET_SW}                            ${None}
${UPDATE_TEST_ITERATION}                50
${ACTIVATION_RESET_TEST_ITERATION}      50
${SITE_RESET_TEST_ITERATION}            50
${POWER_SITE_RESET_TEST_ITERATION}      50
${BTS_BLOCK_TEST_ITERATION}             50
${BBMOD_RESET_TEST_ITERATION}           50
${BBMOD_LOCK_TEST_ITERATION}            50
${RMOD_RESET_TEST_ITERATION}            50
${RMOD_LOCK_TEST_ITERATION}             50
${CELL_LOCK_TEST_ITERATION}             50
${SW_DOWNLOAD_TEST_ITERATION}           50
${ENABLE_SYSLOG_CHECK}                  ${False}
${STOP_TEST_AFTER_FAIL}                 ${False}
${RESTORE_TARGET_SW}                    ${True}
${TEST_ON_NODE}                         ${None}
${REPORT}                               ${True}
@{NODES}                                ${GNB1}
@{TEST_NODES}                           ${GNB1}
${ONAIR_TIMEOUT}                        900
@{SYSLOG_IGNORED_PRINTS}                @{EMPTY}
@{USER_SUSPICIOUS_PRINTS}               @{EMPTY}
@{CRITICAL_ALARMS}                      @{EMPTY}
@{CUSTOM_ALARMS}                        8000

&{GNB1}     node_alias=5G
...         testline_object=${tl.gnbs[0]}
...         source_sw=${SOURCE_SW}
...         target_sw=${TARGET_SW}
...         syslog_ignored_prints=${SYSLOG_IGNORED_PRINTS}
...         user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
...         hw_to_onair_timeout=${ONAIR_TIMEOUT}
...         custom_allowed_alarms=${CUSTOM_ALARMS}
...         critical_alarms=${CRITICAL_ALARMS}
...         verify_syslog=${ENABLE_SYSLOG_CHECK}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI  ${NODES}  ${TEST_NODES}  ${UPDATE_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL ACTIVATION RESET TEST  ${NODES}  ${TEST_NODES}  ${ACTIVATION_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}

E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITH OAM KPI  ${NODES}  ${TEST_NODES}   ${SITE_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL RU RESET WITH OAM KPI  ${NODES}  ${TEST_NODES}  ${RMOD_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL CAPACITY MODULE RESET WITH OAM KPI  ${NODES}  ${TEST_NODES}  ${BBMOD_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI  ${NODES}  ${TEST_NODES}  ${CELL_LOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}

E2E_TL_BTS_Block_Unblock
    [Timeout]   24h
    E2E TL BTS BLOCK UNBLOCK  ${NODES}  ${TEST_NODES}  ${BTS_BLOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}

E2E_TL_RU_Lock_Unlock
    [Timeout]   24h
    E2E TL RU LOCK UNLOCK  ${NODES}  ${TEST_NODES}  ${RMOD_LOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}

E2E_TL_Capacity_Module_Lock_Unlock
    [Timeout]   24h
    E2E TL CAPACITY MODULE LOCK UNLOCK  ${NODES}  ${TEST_NODES}  ${BBMOD_LOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}

E2E_TL_Power_Site_Reset_With_OAM_KPI
    [Timeout]   24h
    E2E TL POWER SITE RESET WITH OAM KPI    ${NODES}  ${TEST_NODES}  ${POWER_SITE_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}

E2E_TL_SW_Download_Test
    [Timeout]   24h
    E2E TL SW DOWNLOAD TEST   ${NODES}  ${TEST_NODES}  ${SW_DOWNLOAD_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
