*** Settings ***
Documentation
...                author: Marek Starzyk
...                maintainer: Marek Starzyk
...                contact: marek.starzyk@nokia.com
...                Test suite for basic UUF OAM upgrade and rollback tests in the 4g5g configuration:


Force Tags         CIT    QCD_MN_RAN    QCP_RAN_VRF    QC_43296    CA_VRF_WRO3

Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           ../../resources/common/uuf_keywords.robot

Test Timeout       100h

*** Variables ***
@{CUSTOMERS}                      Generic
${INITIAL}                        ${None}
${CANDIDATE}                      ${None}
${ITERATION}                      1
${STOP_TEST_AFTER_FAIL}           ${False}
${DOWNLOAD_PATH}                  ${None}
${USE_TESTPACKAGE}                ${False}

${REPORT}                         ${True}
${REPORT_COMMENT}                 ASIK_5G_N1_UUFWRO3
${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     43296
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
Upgrade rollback test
    [Tags]      upgrade
    [Timeout]   97h
    Setting Initial And Candidate    4G5G
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    ${NODES}
    ...    ${gnb1}
    ...    ${ITERATION}
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    ...    restore_to_target_sw=${False}
    ...    download_path=${DOWNLOAD_PATH}
    ...    use_testpackage=${USE_TESTPACKAGE}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
