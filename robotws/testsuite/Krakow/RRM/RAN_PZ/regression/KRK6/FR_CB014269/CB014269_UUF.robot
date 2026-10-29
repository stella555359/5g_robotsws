*** Settings ***
Documentation
...   author:     Jakub Matuszczyk
...   contact:    jakub.matuszczyk@nokia.com
...   maintainer: jakub.matuszczyk@nokia.com
...   Test suite for upgrade rollback tests with L3 call

Library            taf.rfrl.utilities.test_config
Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           ./resources/suite_specific_keywords.robot

Test Timeout       100h

Suite Setup       Suite Setup UUF
Suite Teardown    Common Suite Teardown

Test Setup        Test Setup UUF
Test Teardown     Test Teardown

*** Variables ***
${ITERATION}                        5
@{CUSTOMERS}                        Generic
${SOURCE_SW}                        ${None}
${TARGET_SW}                        ${None}
${STOP_TEST_AFTER_FAIL}             ${False}
${REPORT}                           ${True}
${QC_REPORT}                        ${True}
${QC_DOMAIN}                        MN_RAN
${TEST_QC_ID}                       ${None}
${TEST_QC_ID_TRUNK}                 137952
${TEST_QC_ID_SBTS25R3}              207709
${QC_PROJECT}                       RAN_VRF
${RP_CA}                            VRF_SiSo
${RP_ORGANIZATION}                  VRF_KRK_T06
${RP_LOCATION}                      VRF_KRK
@{IGNORED_PRINTS}                   is not defined in SysinfoQuota.xml. Please contact the owner

&{GNB}                              node_alias=TL025          testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}    target_sw=${TARGET_SW}
...                                 syslog_ignored_prints=${IGNORED_PRINTS}

@{NODES}                            ${GNB}

*** Test Cases ***
CB014269_E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    ${NODES}
    ...    ${GNB}
    ...    ${ITERATION}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    restore_to_target_sw=${False}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    l3_call_method=Verify NR L3 call

*** Keywords ***
Verify NR L3 call
    [Arguments]     ${cell}=3
    logger.Log Info to Console    Verify L3 call for NRCELL-${cell}
    Verify L3 call         data_transfer_time=60
    ...                    tput_ul=100 Mbits/sec
    ...                    tput_dl=200 Mbits/sec
    ...                    deviation=10%
