*** Settings ***
Documentation
...                author: Lukasz Klosinski
...                modify: Marek Starzyk
...                maintainer: Marek Starzyk
...                contact: marek.starzyk@nokia.com
...                Test suite for basic UUF OAM upgrade and rollback tests via NetAct in the multinode configuration:
...                The "Load candidate on 5G" test case is performed only in the scenario where the upgrade is performed
...                only on the LTE site.

Force Tags         CA_VRF_WRO3

Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           ../resources/common/uuf_keywords.robot
Variables          ../resources/common/uuf_netact.py

Test Timeout       100h
Suite Setup        Monster Common Suite Setup

# The command below triggers the full test suite scope
# robot -L TRACE /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/basicCSV4ALLsuites/monster_netact_feature.robot

# The command below triggers only the "Upgrade rollback test", the "Load candidate on 5G" is skipped.
# Choose if you want to perform the test on LTE, but remember that the 5G site must be upgraded to the candidate.
# robot -L TRACE -i 'upgrade' /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/basicCSV4ALLsuites/monster_netact_feature.robot

*** Variables ***
@{CUSTOMERS}                      TMO US
${INITIAL}                        ${None}
${CANDIDATE}                      ${None}
${ITERATION}                      1
${ROLLBACK}                       ${True}
${FALLBACK}                       ${True}
${STOP_TEST_AFTER_FAIL}           ${False}
${IP_VERSION}                     IPv4        # Set IPv6 if you want to test on IPv6

${5G_CONFIG}                      dualASIL    # Set ASIL or dualASIL to point the 5G node
${TEST_ON_NODE}                   ${None}     # Specify one of the nodes enb1/enb2/gnb1/gnb2 to test only the selected node
                                              # If ${TEST_ON_NODE} is None, the test will be executed on all nodes
                                              # in the order set in the variable ${TEST_NODES}

${NETACT}                         srnclab2001
${NETACT_PASS}                    ${None}

${FEATURE}                        CB012755-SR
${CONFIG_TYPE}                    ${None}     # Set test line configuration e.g. ASIB+ABIC, 2ASIL
                                              # If the config_type and feature are filled,
                                              # the log from the passed iteration will be sent to nescrotta.

${REPORT}                         ${True}
${QC_REPORT}                      ${True}
${REPORT_COMMENT}                 multinode_upgrade_test_via_netact_UUFWRO3_RFRL2

# All test line specific variables are imported during the 'Monster Common Suite Setup'
# from the 'tl_specific_variables' dictionary located in the file
# testsuite/Wroclaw/UUF/resources/common/temporary_alarms.py.
# If you want to add a specific alarm, please add it to the dictionary.
&{tl_specific_variables}

&{NETACT_DICT}                    name=${NETACT}               username=omc     password=${NETACT_PASS}
...                               ip_version=${IP_VERSION}     security_mode=no TLS

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
Load candidate on 5g
    [Timeout]   3h
    Run Keyword If    "${TEST_ON_NODE}"=="gnb1" or "${TEST_ON_NODE}"=="gnb2"
    ...               Pass Execution    Load candidate on 5g skipped
    e2e_tl_upgrade_test
    ...    ${NODES}
    ...    ${5G_NODE}
    ...    1
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    [Teardown]   Run Keyword If Test Failed      Fatal Error

Upgrade rollback test
    [Tags]      upgrade
    [Timeout]   97h
    netact_feature_test
    ...    ${NODES}
    ...    ${TEST_NODES}
    ...    ${ITERATION}
    ...    netact_dict=${NETACT_DICT}
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    ...    rollback=${ROLLBACK}
    ...    fallback=${FALLBACK}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    feature=${FEATURE}
    ...    config_type=${CONFIG_TYPE}
