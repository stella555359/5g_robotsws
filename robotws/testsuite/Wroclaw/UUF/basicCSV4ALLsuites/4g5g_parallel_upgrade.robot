*** Settings ***
Documentation
...                author: Lukasz Klosinski
...                modify: Marek Starzyk
...                maintainer: Marek Starzyk
...                contact: marek.starzyk@nokia.com
...                Test suite for basic UUF OAM parallel sw upgrade and rollback tests in the 4g5g configuration:

Force Tags         CA_VRF_WRO3

Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           ../resources/common/uuf_keywords.robot

Test Timeout       100h
Suite Setup        4G5G Common Suite Setup

# robot -L TRACE /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/basicCSV4ALLsuites/4g5g_parallel_upgrade.robot

*** Variables ***
@{CUSTOMERS}                      Generic
${INITIAL}                        ${None}
${CANDIDATE}                      ${None}
${ITERATION}                      3
${STOP_TEST_AFTER_FAIL}           ${False}

${REPORT}                         ${True}
${QC_REPORT}                      ${True}
${REPORT_COMMENT}                 4G5G_parallel_upgrade_test_UUFWRO3_RFRL2

${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     ${None}
${QC_PROJECT}                     ${None}

# All test line specific variables are imported during the '4G5G Common Suite Setup'
# from the 'tl_specific_variables' dictionary located in the file
# testsuite/Wroclaw/UUF/resources/common/temporary_alarms.py.
# If you want to add a specific alarm, please add it to the dictionary.
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
@{TEST_NODES}                     ${gnb1}    ${enb1}
${TEST_ON_NODE}                   ${None}

*** Test Cases ***
Parallel SW upgrade rollback test
    e2e_parallel_sw_upgrade_rollback_with_oam_kpi
    ...    ${NODES}
    ...    ${TEST_NODES}
    ...    ${ITERATION}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    ...    restore_to_target_sw=${False}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
