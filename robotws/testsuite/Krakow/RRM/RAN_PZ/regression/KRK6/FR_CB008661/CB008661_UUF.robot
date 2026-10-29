*** Settings ***
Documentation
...   author:     Jakub Matuszczyk
...   contact:    jakub.matuszczyk@nokia.com
...   maintainer: jakub.matuszczyk@nokia.com
...   Test suite for upgrade rollback tests with L3 call

Library            taf.rfrl.utilities.test_config
Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB014269/resources/suite_specific_keywords.robot

Test Timeout       100h

*** Variables ***
${ITERATION}                        5
@{CUSTOMERS}                        Generic
${SOURCE_SW}                        ${None}
${TARGET_SW}                        ${None}
${STOP_TEST_AFTER_FAIL}             ${False}
${REPORT}                           ${True}
${QC_REPORT}                        ${True}
${TEST_QC_ID}                       ${None}
${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF
${RP_CA}                            VRF_SiSo
${RP_ORGANIZATION}                  VRF_KRK_T06
${RP_LOCATION}                      VRF_KRK

&{GNB}                              node_alias=TL055         testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}    target_sw=${TARGET_SW}

@{NODES}                            ${GNB}

*** Test Cases ***
CB013500_E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Setup]    suite_specific_keywords.Test Setup
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
    Log to console         Verify L3 call for NRCELL-${cell}
    Verify L3 call         data_transfer_time=60
    ...                    tput_ul=100 Mbits/sec
    ...                    tput_dl=200 Mbits/sec
    ...                    deviation=10%
