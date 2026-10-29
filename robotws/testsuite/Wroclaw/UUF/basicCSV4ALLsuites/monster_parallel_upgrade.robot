*** Settings ***
Documentation
...                author: Lukasz Klosinski
...                modify: Marek Starzyk
...                maintainer: Marek Starzyk
...                contact: marek.starzyk@nokia.com
...                Test suite for basic UUF OAM parallel sw upgrade and rollback tests in the multinode configuration:

Force Tags         CA_VRF_WRO3

Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           ../resources/common/uuf_keywords.robot

Test Timeout       100h
Suite Setup        Monster Common Suite Setup

# robot -L TRACE /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/basicCSV4ALLsuites/monster_parallel_upgrade.robot

*** Variables ***
@{CUSTOMERS}                      TMO US
${INITIAL}                        ${None}
${CANDIDATE}                      ${None}
${ITERATION}                      5
${STOP_TEST_AFTER_FAIL}           ${False}

${5G_CONFIG}                      dualASIL    # Set ASIL or dualASIL to point the 5G node

${REPORT}                         ${True}
${QC_REPORT}                      ${True}
${REPORT_COMMENT}                 multinode_parallel_upgrade_test_UUFWRO3_RFRL2

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
${TEST_ON_NODE}                   ${None}

*** Test Cases ***
Upgrade rollback test
    [Timeout]   98h
    e2e_parallel_sw_upgrade_rollback_with_oam_kpi
    ...    ${NODES}
    ...    ${TEST_NODES}
    ...    ${ITERATION}
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    ...    restore_to_target_sw=${False}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
