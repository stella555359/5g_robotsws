*** Settings ***
Documentation      Test suite for basic UUF OAM reset wo HWF tests in the 4g configuration
...                author: Lukasz Klosinski
...                modify: Michal Kubicki
...                maintainer: Michal Kubicki
...                contact: michal.kubicki@nokia.com

Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Library            testsuite/Wroclaw/RRM/resources/common/mount_netdrive.py
Library            testsuite/Wroclaw/RRM//resources/csv4all_helpers.py
Library            qc_config.py

Suite Setup        Mount Netdrive
Test Teardown      Run Keyword If Test Passed    Find Suspicious Prints In Passed Test

*** Variables ***
${EMAIL_RECIPIENTS}                     michal.kubicki@nokia.com
${QC_DOMAIN}=                           MN_RAN
${QC_PROJECT}                           RAN_VRF
${RP_CA}                                VRF_RRM
${RP_LOCATION}                          VRF_WRO2
${RP_ORGANIZATION}                      VRF_WRO2_T08_02
@{CUSTOMERS}                            LGU+
${SOURCE_SW}                            SBTS25R2_FSM3_0000_000070_000000
${TARGET_SW}                            SBTS00_FSM3_9999_251124_000001
${UPDATE_TEST_ITERATION}                5
${SITE_RESET_TEST_ITERATION}            50
${BTS_BLOCK_TEST_ITERATION}             1
${BBMOD_RESET_TEST_ITERATION}           1
${BBMOD_LOCK_TEST_ITERATION}            1
${RMOD_RESET_TEST_ITERATION}            1
${RMOD_LOCK_TEST_ITERATION}             1
${CELL_LOCK_TEST_ITERATION}             1
${ENABLE_SYSLOG_CHECK}                  ${False}
${STOP_TEST_AFTER_FAIL}                 ${False}
${TEST_ON_NODE}                         ${None}
${REPORT}                               ${True}
@{NODES}                                ${ENB1}
@{TEST_NODES}                           ${ENB1}


&{ENB1}     node_alias=4G               testline_object=${tl.enbs[0]}
...         source_sw=${SOURCE_SW}      target_sw=${TARGET_SW}
...         verify_syslog=${ENABLE_SYSLOG_CHECK}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    ${TEST_QC_ID}=  Set Test ID
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI  ${NODES}  ${TEST_NODES}  ${UPDATE_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}
    ...     use_external_storage=${True}

E2E_TL_Site_Reset_with_OAM_KPI
    ${TEST_QC_ID}=  Set Test ID
    E2E TL SITE RESET WITH OAM KPI  ${NODES}  ${TEST_NODES}   ${SITE_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}
