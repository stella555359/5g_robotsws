*** Settings ***
Documentation
...                author: Marek Starzyk
...                maintainer: Marek Starzyk
...                contact: marek.starzyk@nokia.com
...                Test suite for upgrade/rollback/fallback from FDSW:

Force Tags          CA_VRF_WRO3

Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           ../resources/common/uuf_keywords.robot

Test Timeout       100h
Suite Setup        FDSW Common Suite Setup

# robot -L TRACE /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/basicCSV4ALLsuites/4g5g_upgrade.robot

*** Variables ***
@{CUSTOMERS}                      Generic
${INITIAL}                        ${None}
${CANDIDATE}                      ${None}
${ITERATION}                      1
${ROLLBACK}                       ${False}
${FALLBACK}                       ${False}
${STOP_TEST_AFTER_FAIL}           ${False}

${TEST_ON_NODE}                   ${None}    # Specify one of the nodes enb1/gnb1 to test only the selected node
                                             # If ${TEST_ON_NODE} is None, the test will be executed on the enb1

${FEATURE}                        CB012755-SR
${CONFIG_TYPE}                    ${None}    # Set test line configuration e.g. ASIB+ABIC, 2ASIL
                                             # If the config_type and feature are filled,
                                             # the log from the passed iteration will be sent to nescrotta.

${REPORT}                         ${True}
${REPORT_COMMENT}                 upgrade_from_FDSW_UUFWRO3_RFRL2

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

@{NODES}                    ${enb1}
@{TEST_NODES}               ${enb1}

*** Test Cases ***
Upgrade From FDSW
    FDSW TEST
    ...    ${NODES}
    ...    ${TEST_NODES}
    ...    ${ITERATION}
    ...    customers_list=${CUSTOMERS}
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}
    ...    rollback=${ROLLBACK}
    ...    fallback=${FALLBACK}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    feature=${FEATURE}
    ...    config_type=${CONFIG_TYPE}
