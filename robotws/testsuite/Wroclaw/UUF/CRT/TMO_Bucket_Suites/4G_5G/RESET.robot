*** Settings ***
Documentation
...                author: Lukasz Klosinski
...                modify: Marek Starzyk
...                maintainer: Marek Starzyk
...                contact: marek.starzyk@nokia.com
...                Test suite for CRT execution with a reset without HWF tests in the 4G/5G configuration:

Force Tags         CA_VRF_WRO3

Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           ../../../resources/common/uuf_keywords.robot

Test Timeout       100h
Suite Setup        4G5G Common Suite Setup

*** Variables ***
@{CUSTOMERS}                      TMO US
${INITIAL}                        ${None}
${CANDIDATE}                      ${None}
${ITERATION}                      30

${TEST_ON_NODE}                   gnb1       # Specify one of the nodes enb1/gnb1 to test only the selected node
                                             # If ${TEST_ON_NODE} is None, the test will be executed on all nodes
                                             # in the order set in the variable ${TEST_NODES}

${REPORT}                         ${True}
${QC_REPORT}                      ${True}
${REPORT_COMMENT}                 BUCKET_8_6_RESET_UUFWRO3_RFRL2

${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     ${None}
${QC_PROJECT}                     ${None}

&{tl_specific_variables}

&{enb1}                           node_alias=4G           testline_object=${tl.enbs[0]}
...                               source_sw=${INITIAL}    target_sw=${CANDIDATE}
...                               temporary_allowed_alarms=${tl_specific_variables}
...                               custom_allowed_alarms=${tl_specific_variables}
...                               hw_to_onair_timeout=${tl_specific_variables}

&{gnb1}                           node_alias=5G           testline_object=${tl.gnbs[0]}
...                               source_sw=${INITIAL}    target_sw=${CANDIDATE}
...                               temporary_allowed_alarms=${tl_specific_variables}
...                               custom_allowed_alarms=${tl_specific_variables}
...                               hw_to_onair_timeout=${tl_specific_variables}

@{NODES}                          ${gnb1}    ${enb1}
@{TEST_NODES}                     ${gnb1}

*** Test Cases ***
Site reset
    [Tags]      reset
    [Timeout]   97h
    ${status}      Run Keyword And Return Status     Load candidate
    Run Keyword Unless    ${status}    Fatal Error   The Load Candidate failed
    e2e_tl_site_reset_without_hwf_with_oam_kpi
    ...    ${NODES}
    ...    ${TEST_NODES}
    ...    ${ITERATION}
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}

*** Keywords ***
Load candidate
    [Timeout]   3h
    e2e_tl_upgrade_test
    ...    ${NODES}
    ...    @{TEST_NODES}
    ...    1
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
