*** Settings ***
Documentation
...                author: Lukasz Klosinski
...                modify: Marek Starzyk
...                maintainer: Marek Starzyk
...                contact: marek.starzyk@nokia.com
...                Test suite for basic UUF OAM power look-alike BTS reset wo HWF tests in the multinode configuration:

Force Tags         CA_VRF_WRO3

Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           ../resources/common/uuf_keywords.robot

Test Timeout       100h
Suite Setup        Monster Common Suite Setup


# The command below triggers the full test suite scope
# robot -L TRACE /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/basicCSV4ALLsuites/monster_power_reset.robot

# The command below triggers only the "Site reset", the "Load candidate" is skipped.
# Choose if you want to perform only the 'Site reset' test, but remember that the test line must be set to the candidate.
# robot -L TRACE -i "reset" /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/basicCSV4ALLsuites/monster_power_reset.robot

*** Variables ***
@{CUSTOMERS}                      TMO US
${INITIAL}                        ${None}
${CANDIDATE}                      ${None}
${ITERATION}                      30
${STOP_TEST_AFTER_FAIL}           ${False}

${5G_CONFIG}                      dualASIL    # Set ASIL or dualASIL to point the 5G node
${TEST_ON_NODE}                   ${None}     # Specify one of the nodes enb1/enb2/gnb1/gnb2 to test only the selected node
                                              # If ${TEST_ON_NODE} is None, the test will be executed on all nodes
                                              # in the order set in the variable ${TEST_NODES}

${REPORT}                         ${True}
${QC_REPORT}                      ${True}
${REPORT_COMMENT}                 multinode_power_reset_test_UUFWRO3_RFRL2

# All test line specific variables are imported during the 'Monster Common Suite Setup'
# from the 'tl_specific_variables' dictionary located in the file
# testsuite/Wroclaw/UUF/resources/common/temporary_alarms.py.
# If you want to add a specific alarm, please add it to the dictionary.
&{tl_specific_variables}

&{enb1}                           node_alias=ASIA_LTE       testline_object=${tl.enbs[1]}
...                               source_sw=${INITIAL}      target_sw=${CANDIDATE}
...                               temporary_allowed_alarms=${tl_specific_variables}
...                               custom_allowed_alarms=${tl_specific_variables}
...                               hw_to_onair_timeout=${tl_specific_variables}

&{gnb1}                           node_alias=ASIL_5G        testline_object=${tl.gnbs[0]}
...                               source_sw=${INITIAL}      target_sw=${CANDIDATE}
...                               temporary_allowed_alarms=${tl_specific_variables}
...                               custom_allowed_alarms=${tl_specific_variables}
...                               hw_to_onair_timeout=${tl_specific_variables}

&{gnb2}                           node_alias=dualASIL_5G    testline_object=${tl.gnbs[1]}
...                               source_sw=${INITIAL}      target_sw=${CANDIDATE}
...                               temporary_allowed_alarms=${tl_specific_variables}
...                               custom_allowed_alarms=${tl_specific_variables}
...                               hw_to_onair_timeout=${tl_specific_variables}

@{NODES}                          ${gnb2}    ${enb1}
@{TEST_NODES}                     ${gnb2}    ${enb1}
${5G_NODE}                        ${None}

*** Test Cases ***
Load candidate
    [Timeout]   3h
    e2e_tl_upgrade_test
    ...    ${NODES}
    ...    ${NODES}
    ...    1
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    [Teardown]   Run Keyword If Test Failed      Fatal Error

Site reset
    [Tags]      reset
    [Timeout]   97h
    e2e_tl_power_site_reset_without_hwf_with_oam_kpi
    ...    ${NODES}
    ...    ${TEST_NODES}
    ...    ${ITERATION}
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
