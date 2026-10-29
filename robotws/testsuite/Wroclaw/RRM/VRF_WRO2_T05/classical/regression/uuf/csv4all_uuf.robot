*** Settings ***
Documentation
...   author: Lukasz Klosinski
...   modified: Sebastian Mikos
...   Test suite for basic UUF OAM Tests in loop: jk

Library        taf/rfrl/csv4all/CSV4AllTestCases.py
Resource       l3_call.robot


Test Timeout     48h

*** Variables ***
${RP_CA}                                VRF_RRM
${RP_LOCATION}                          VRF_WRO2
${RP_ORGANIZATION}                      VRF_WRO2_T05_02
@{CUSTOMERS}                            Generic
${SOURCE_SW}                            SBTS00_ENB_9999_250527_000007
${TARGET_SW}                            SBTS00_ENB_9999_250527_000007
@{CUSTOM_ALLOWED}                       61652
${UPDATE_TEST_ITERATION}                50
${SITE_RESET_TEST_ITERATION}            140
${BTS_BLOCK_TEST_ITERATION}             30
${BBMOD_RESET_TEST_ITERATION}           30
${BBMOD_LOCK_TEST_ITERATION}            30
${RMOD_RESET_TEST_ITERATION}            30
${RMOD_LOCK_TEST_ITERATION}             30
${CELL_LOCK_TEST_ITERATION}             30
${STOP_TEST_AFTER_FAIL}                 ${False}
${TEST_ON_NODE}                         ${None}
${REPORT}                               ${True}
@{NODES}                                ${GNB1}
@{TEST_NODES}                           ${GNB1}
${ONAIR_TIMEOUT}                        900
${LABEL}=                               VRF_WRO2_T05_Sebastia_Mikos

&{GNB1}     node_alias=5G               testline_object=${tl.gnbs[0]}
...         source_sw=${SOURCE_SW}      target_sw=${TARGET_SW}
...         hw_to_onair_timeout=${ONAIR_TIMEOUT}
...         custom_allowed_alarms=${CUSTOM_ALLOWED}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   48h
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI  ${NODES}  ${TEST_NODES}  ${UPDATE_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     topology=${LABEL}
    ...     restore_to_target_sw=${True}

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   48h
    E2E TL ACTIVATION RESET TEST  ${NODES}  ${TEST_NODES}   ${SITE_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     topology=${LABEL}
    ...     report=${REPORT}

E2E_TL_Site_Reset_with_OAM_KPI_L3_CALL
    [Timeout]   48h
    E2E TL SITE RESET WITH OAM KPI  ${NODES}  ${TEST_NODES}   ${SITE_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     topology=${LABEL}
    ...     report=${REPORT}
    ...     l3_call_method=E2E_L3_CALL

E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   48h
    E2E TL SITE RESET WITH OAM KPI  ${NODES}  ${TEST_NODES}   ${SITE_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     topology=${LABEL}
    ...     report=${REPORT}

E2E_TL_Capacity_Module_Lock_Unlock
    [Timeout]   24h
    E2E TL CAPACITY MODULE LOCK UNLOCK  ${NODES}  ${TEST_NODES}   ${SITE_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     topology=${LABEL}
    ...     report=${REPORT}

E2E_TL_RU_Lock_Unlock
    [Timeout]   24h
    E2E TL RU LOCK UNLOCK    ${NODES}  ${TEST_NODES}  ${SITE_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     topology=${LABEL}
    ...     report=${REPORT}
