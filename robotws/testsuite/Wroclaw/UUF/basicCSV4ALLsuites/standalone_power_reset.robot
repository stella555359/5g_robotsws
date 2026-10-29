*** Settings ***
Documentation
...                author: Lukasz Klosinski
...                modify: Marek Starzyk
...                maintainer: Marek Starzyk
...                contact: marek.starzyk@nokia.com
...                Test suite for basic UUF OAM power look-alike BTS reset wo HWF tests in the standalone configuration:

Force Tags         CA_VRF_WRO3

Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           ../resources/common/uuf_keywords.robot

Test Timeout       100h
Suite Setup        Standalone Common Suite Setup

# robot -L TRACE /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/basicCSV4ALLsuites/standalone_power_reset.robot

*** Variables ***
@{CUSTOMERS}                      Generic
${INITIAL}                        ${None}
${CANDIDATE}                      ${None}
${ITERATION}                      20
${STOP_TEST_AFTER_FAIL}           ${False}

${REPORT}                         ${True}
${QC_REPORT}                      ${True}
${REPORT_COMMENT}                 standalone_power_look-alike_BTS_reset_test_UUFWRO3_RFRL2

${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     ${None}
${QC_PROJECT}                     ${None}

# All test line specific variables are imported during the 'Standalone Common Suite Setup'
# from the 'tl_specific_variables' dictionary located in the file
# testsuite/Wroclaw/UUF/resources/common/temporary_alarms.py.
# If you want to add a specific alarm, please add it to the dictionary.
&{tl_specific_variables}

&{enb1}                           node_alias=4G           testline_object=${tl.enbs[0]}
...                               source_sw=${INITIAL}    target_sw=${CANDIDATE}
...                               temporary_allowed_alarms=${tl_specific_variables}
...                               custom_allowed_alarms=${tl_specific_variables}
...                               hw_to_onair_timeout=${tl_specific_variables}

@{NODES}                          ${enb1}

*** Test Cases ***
Load candidate
    [Timeout]    3h
    e2e_tl_upgrade_test
    ...    ${nodes}
    ...    ${enb1}
    ...    1
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    [Teardown]    Run Keyword If Test Failed    Fatal Error

Site reset
    [Timeout]    97h
    e2e_tl_power_site_reset_without_hwf_with_oam_kpi
    ...    ${nodes}
    ...    ${enb1}
    ...    ${ITERATION}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
