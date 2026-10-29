*** Settings ***
Documentation
...                author: Lukasz Klosinski
...                modify: Marek Starzyk
...                maintainer: Marek Starzyk
...                contact: marek.starzyk@nokia.com
...                Test suite for CRT execution with a reset without HWF tests in a dual core configuration:

Force Tags         CA_VRF_WRO3

Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           ../../../resources/common/uuf_keywords.robot

Test Timeout       100h
Suite Setup        Standalone Common Suite Setup

*** Variables ***
@{CUSTOMERS}                      TMO US
${INITIAL}                        ${None}
${CANDIDATE}                      ${None}
${ITERATION}                      30

${REPORT}                         ${True}
${QC_REPORT}                      ${True}
${REPORT_COMMENT}                 BUCKET_8_5_RESET_UUFWRO3_RFRL2

${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     ${None}
${QC_PROJECT}                     ${None}

${TEMPORARY_ALLOWED_FAULTS_4G}    ${None}
${CUSTOM_ALLOWED_ALARMS_4G}       ${None}
${HW_TO_ONAIR_TIME}               ${None}

&{enb1}                           node_alias=4G           testline_object=${tl.enbs[0]}
...                               source_sw=${INITIAL}    target_sw=${CANDIDATE}
...                               temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_4G}
...                               custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_4G}
...                               hw_to_onair_timeout=${HW_TO_ONAIR_TIME}

@{NODES}                          ${enb1}

*** Test Cases ***
Site reset
    [Timeout]    97h
    ${status}      Run Keyword And Return Status     Load candidate
    Run Keyword Unless    ${status}    Fatal Error   The Load Candidate failed
    e2e_tl_site_reset_without_hwf_with_oam_kpi
    ...    ${nodes}
    ...    ${enb1}
    ...    ${ITERATION}
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}

*** Keywords ***
Load candidate
    [Timeout]    3h
    e2e_tl_upgrade_test
    ...    ${nodes}
    ...    ${enb1}
    ...    1
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
