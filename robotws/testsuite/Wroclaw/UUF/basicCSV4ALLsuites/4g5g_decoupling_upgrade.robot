*** Settings ***
Documentation
...                decoupling upgrade rollback test
...                author: Lukasz Klosinski
...                modify: Marek Starzyk
...                maintainer: Marek Starzyk
...                contact: marek.starzyk@nokia.com
...                Test suite for basic UUF OAM LTE-NR decoupling upgrade and rollback tests in the 4g5g configuration:
...                The 'Load Initial On 5G' test case is skipped when the LTE and 5G initial SW builds are the same.

Force Tags         CA_VRF_WRO3

Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Library            Collections
Resource           ../resources/common/uuf_keywords.robot

Test Timeout       100h
Suite Setup        4G5G Common Suite Setup

# The command below triggers the full test suite scope
# robot -L TRACE /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/basicCSV4ALLsuites/4g5g_decoupling_upgrade.robot

# The command below triggers only the "Upgrade rollback test", the "Load Initial On 5G" is skipped.
# Remember that the 5G site must be upgraded to the appropriate SW build.
# robot -L TRACE -i 'upgrade' /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/basicCSV4ALLsuites/4g5g_decoupling_upgrade.robot

*** Variables ***
@{CUSTOMERS}                      TMO US
${INITIAL_4G}                     ${None}
${INITIAL_5G}                     ${None}
${CANDIDATE}                      ${None}
${ITERATION}                      5
${STOP_TEST_AFTER_FAIL}           ${False}

${REPORT}                         ${True}
${QC_REPORT}                      ${True}
${REPORT_COMMENT}                 4G5G_LTE_NR_decoupling_upgrade_test_UUFWRO3_RFRL2

${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     ${None}
${QC_PROJECT}                     ${None}

# All test line specific variables are imported during the '4G5G Common Suite Setup'
# from the 'tl_specific_variables' dictionary located in the file
# testsuite/Wroclaw/UUF/resources/common/temporary_alarms.py.
# If you want to add a specific alarm, please add it to the dictionary.
&{tl_specific_variables}

&{enb1}                           node_alias=4G              testline_object=${tl.enbs[0]}
...                               source_sw=${INITIAL_4G}    target_sw=${CANDIDATE}
...                               temporary_allowed_alarms=${tl_specific_variables}
...                               custom_allowed_alarms=${tl_specific_variables}
...                               hw_to_onair_timeout=${tl_specific_variables}

&{gnb1}                           node_alias=5G              testline_object=${tl.gnbs[0]}
...                               source_sw=${INITIAL_4G}    target_sw=${CANDIDATE}
...                               temporary_allowed_alarms=${tl_specific_variables}
...                               custom_allowed_alarms=${tl_specific_variables}
...                               hw_to_onair_timeout=${tl_specific_variables}

@{NODES}                          ${gnb1}    ${enb1}
${TEST_ON_NODE}                   ${None}

*** Test Cases ***
Load Initial On 5G
    [Timeout]   3h
    Run Keyword If       "${enb1['source_sw']}"=="${INITIAL_5G}"    Pass Execution    TestCase skipped
    Set To Dictionary    ${gnb1}    target_sw=${INITIAL_5G}
    e2e_tl_upgrade_test
    ...    ${NODES}
    ...    ${gnb1}
    ...    1
    ...    report=${False}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    [Teardown]    Run Keyword If Test Failed    Fatal Error

LTE NR Decoupling Upgrade Rollback Test
    [Tags]      upgrade
    [Timeout]   97h
    Set To Dictionary    ${gnb1}    source_sw=${INITIAL_5G}
    Set To Dictionary    ${gnb1}    target_sw=${CANDIDATE}
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    ${NODES}
    ...    ${gnb1}
    ...    ${ITERATION}
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    restore_to_target_sw=${False}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
