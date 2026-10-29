*** Settings ***
Documentation
...                author: Marek Starzyk
...                maintainer: Marek Starzyk
...                contact: marek.starzyk@nokia.com
...                Test suite for basic UUF OAM reset wo HWF tests in the 4g5g configuration:

Force Tags         CIT    QCD_MN_RAN    QCP_RAN_VRF    QC_43297    CA_VRF_WRO3

Library            Collections
Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           taf/rfrl/uuf4all/uuf4all_keywords.robot
Resource           ../../resources/common/uuf_keywords.robot

Test Timeout       100h

*** Variables ***
@{CUSTOMERS}                      Generic
${INITIAL}                        ${None}
${CANDIDATE}                      ${None}
${ITERATION}                      5
${STOP_TEST_AFTER_FAIL}           ${False}
${DOWNLOAD_PATH}                  ${None}
${USE_TESTPACKAGE}                ${False}

${REPORT}                         ${True}
${REPORT_COMMENT}                 ASIK_5G_N1_UUFWRO3
${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     43297
${QC_PROJECT}                     RAN_VRF

@{TEMPORARY_ALLOWED_ALARMS_5G}    4385
@{TEMPORARY_ALLOWED_ALARMS_4G}    4773

&{enb1}                           node_alias=4G           testline_object=${tl.enbs[0]}
...                               source_sw=${INITIAL}    target_sw=${CANDIDATE}
...                               temporary_allowed_alarms=${TEMPORARY_ALLOWED_ALARMS_4G}

&{gnb1}                           node_alias=5G           testline_object=${tl.gnbs[0]}
...                               source_sw=${INITIAL}    target_sw=${CANDIDATE}
...                               temporary_allowed_alarms=${TEMPORARY_ALLOWED_ALARMS_5G}

@{NODES}                          ${gnb1}    ${enb1}

*** Test Cases ***
Site reset
    [Tags]      reset
    [Timeout]   97h
    Set Candidate
    e2e_tl_site_reset_without_hwf_with_oam_kpi
    ...    ${NODES}
    ...    ${gnb1}
    ...    ${ITERATION}
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}

*** Keywords ***
Set Candidate
    ${candidate_sw}      Get Target SW
    Set to dictionary    ${enb1}    source_sw=${candidate_sw}    target_sw=${candidate_sw}
    Set to dictionary    ${gnb1}    source_sw=${candidate_sw}    target_sw=${candidate_sw}
