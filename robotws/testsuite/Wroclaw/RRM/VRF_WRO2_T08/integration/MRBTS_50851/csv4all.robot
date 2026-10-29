*** Settings ***
Documentation      Test suite for basic UUF OAM reset wo HWF tests in the 5g configuration
...                author: Lukasz Klosinski
...                modify: Sebastian Jakubik
...                maintainer: Sebastian Jakubik
...                contact: sebastian.jakubik@nokia.com

Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Library            testsuite/Wroclaw/RRM/resources/common/mount_netdrive.py
Library            testsuite/Wroclaw/RRM//resources/csv4all_helpers.py

Suite Setup        Mount Netdrive
Test Teardown      Run Keyword If Test Passed   Find Suspicious Prints In Passed Test

*** Variables ***
${QC_DOMAIN}                            MN_RAN
${QC_PROJECT}                           RAN_VRF
${RP_CA}                                VRF_RRM
${RP_LOCATION}                          VRF_WRO2
${RP_ORGANIZATION}                      VRF_WRO2_T08_02
@{CUSTOMERS}                            TMO US
${SOURCE_SW}                            ${None}
${TARGET_SW}                            ${None}
${SHOULD_BE_REPORTED}                   ${True}
${LABEL}                                VRF_WRO2_T08_2xASIL_4xABIO_ABIA_3xAHLOA_3xAHFIB_2xAZHL
${HOSTNAME}                             7_16_MRBTS-50851
${SCOUT_HOSTNAME}                       ${HOSTNAME}
${UPDATE_TEST_ITERATION}                1
${SITE_RESET_TEST_ITERATION}            1
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
@{NODES}                                ${GNB1}
@{TEST_NODES}                           ${GNB1}


&{GNB1}     node_alias=5G               testline_object=${tl.gnbs[0]}
...         source_sw=${SOURCE_SW}      target_sw=${TARGET_SW}
...         verify_syslog=${ENABLE_SYSLOG_CHECK}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI  ${NODES}  ${TEST_NODES}  ${UPDATE_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITH OAM KPI  ${NODES}  ${TEST_NODES}   ${SITE_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}


E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL RU RESET WITH OAM KPI  ${NODES}  ${TEST_NODES}  ${RMOD_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL CAPACITY MODULE RESET WITH OAM KPI  ${NODES}  ${TEST_NODES}  ${BBMOD_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI  ${NODES}  ${TEST_NODES}  ${CELL_LOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}

E2E_TL_BTS_Block_Unblock
    [Timeout]   24h
    E2E TL BTS BLOCK UNBLOCK  ${NODES}  ${TEST_NODES}  ${BTS_BLOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}

E2E_TL_RU_Lock_Unlock
    [Timeout]   24h
    E2E TL RU LOCK UNLOCK  ${NODES}  ${TEST_NODES}  ${RMOD_LOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}

E2E_TL_Capacity_Module_Lock_Unlock
    [Timeout]   24h
    E2E TL CAPACITY MODULE LOCK UNLOCK  ${NODES}  ${TEST_NODES}  ${BBMOD_LOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
