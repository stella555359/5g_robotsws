*** Settings ***
Documentation
...   author: Lukasz Klosinski
...   modified: Tomasz Dabrowski
...   Test suite for basic UUF OAM Tests in loop: jk

Library        taf/rfrl/csv4all/CSV4AllTestCases.py
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/wft/wft.py
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/admin/BasicKeywords.robot



Suite Setup        Run Keyword If    ${AUTO_SW_SELECTION}    Set software versions automatically


Test Timeout     48h

*** Variables ***
${LABEL}=                               VRF_WRO2_T05_Tomasz_Dabrowski
${RP_CA}                                VRF_RRM
${RP_LOCATION}                          VRF_WRO2
${RP_ORGANIZATION}                      VRF_WRO2_T05_02
${QC_DOMAIN}=                           MN_RAN
${TEST_QC_ID}=                          ${None}  # SHOULD BE DIFFERENT FOR EACH TEST CASE ACCORDING TO QC_ID OF EACH TEST
${QC_PROJECT}=                          RAN_VRF
@{CUSTOMERS}                            Generic
${AUTO_SW_SELECTION}                    True
${SOURCE_SW}                            SBTS00_ENB_9999_250612_000010
${TARGET_SW}                            SBTS00_ENB_9999_250613_000006
${TARGET_BRANCH}                        SBTS00
${TRUNK_BRANCH}                         SBTS26R1
@{CUSTOM_ALLOWED}                       61652    4298    7115    62003
${UPDATE_TEST_ITERATION}                30
${SITE_RESET_TEST_ITERATION}            30
${BTS_BLOCK_TEST_ITERATION}             30
${BBMOD_RESET_TEST_ITERATION}           30
${BBMOD_LOCK_TEST_ITERATION}            30
${RMOD_RESET_TEST_ITERATION}            30
${RMOD_LOCK_TEST_ITERATION}             30
${CELL_LOCK_TEST_ITERATION}             30
${CELL_BLOCK_TEST_ITERATION}            30
${DELTA_TEST_ITERATION}                 30
${DELTA_TEST_WITH_RESETITERATION}       30
${STOP_TEST_AFTER_FAIL}                 ${False}
${TEST_ON_NODE}                         ${None}
${REPORT}                               ${True}
@{NODES}                                ${GNB1}
@{TEST_NODES}                           ${GNB1}
${ONAIR_TIMEOUT}                        900

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
    ...     restore_to_target_sw=${True}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     topology=${LABEL}

E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   48h
    E2E TL SITE RESET WITH OAM KPI  ${NODES}  ${TEST_NODES}   ${SITE_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     topology=${LABEL}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI    ${NODES}  ${TEST_NODES}  ${CELL_LOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     topology=${LABEL}

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI    ${NODES}  ${TEST_NODES}  ${CELL_BLOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     topology=${LABEL}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${TEST_NODES}  ${DELTA_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     topology=${LABEL}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED    ${NODES}  ${TEST_NODES}  ${DELTA_TEST_WITH_RESETITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     topology=${LABEL}

E2E_TL_Capacity_Module_Lock_Unlock
   [Timeout]   24h
    E2E TL CAPACITY MODULE LOCK UNLOCK    ${NODES}  ${TEST_NODES}  ${BBMOD_LOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     topology=${LABEL}


*** Keywords ***
Set software versions automatically
    ${TARGET}=   get_latest_released_build_name    ${TARGET_BRANCH}
    Log to console    Selected Target SW: ${TARGET}
    ${SOURCE}=    Get active software version
    Log to console    Source SW: ${SOURCE}
    &{GNB1_new}    Create dictionary    node_alias=5G     testline_object=${tl.gnbs[0]}
    ...         source_sw=${SOURCE}      target_sw=${TARGET}
    ...         hw_to_onair_timeout=${ONAIR_TIMEOUT}
    ...         custom_allowed_alarms=${CUSTOM_ALLOWED}
    Set global variable    @{NODES}        ${GNB1_new}
    Set global variable    @{TESTNODES}    ${GNB1_new}

Get active software version
    ADMIN CLI connection
    ${ACTIVE_SW}=   admin_cli.get_sw_version
    IF    '${TARGET_BRANCH}' == 'SBTS00'
        ${contains}    Run Keyword And Return Status    Should Contain    ${ACTIVE_SW}    ${TRUNK_BRANCH}
        Run Keyword If    ${contains}    Set Suite Variable    ${ACTIVE_SW}    ${TARGET_BRANCH}${ACTIVE_SW}[8:]
    END
    RETURN    ${ACTIVE_SW}
    [Teardown]    ADMIN CLI disconnection