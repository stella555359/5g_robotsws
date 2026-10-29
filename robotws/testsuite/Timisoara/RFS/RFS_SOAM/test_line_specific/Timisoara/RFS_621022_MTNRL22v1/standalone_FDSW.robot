*** Settings ***
Documentation
...                author: Marius Roman
...		           modify: Marius Roman
...                maintainer: Marius Roman
...                contact: marius.roman@nokia.com
...                Test suite for upgrade/rollback/fallback from FDSW:

Force Tags          VRF_TSR_T06

Library            taf/rfrl/csv4all/CSV4AllTestCases.py
#Library            ../resources/suite_utils.py

Test Timeout       100h
#Suite Setup        Common Suite Setup

# The command below triggers the full test suite scope.
# If the path /home/ute/init_tc does not exist, please specify the path to the __init__.py file appropriate
# for the VM hostname
# robot -L TRACE -V /home/ute/init_tc /home/ute/MN/UTE/gears/gears.wroclaw.uuf/main/testsuite/basic/standalone_FDSW.robot

*** Variables ***
@{CUSTOMERS}                      Generic
${INITIAL1}                       ${None}
${INITIAL2}                       ${None}
${CANDIDATE1}                     ${None}
${CANDIDATE2}                     ${None}
${ITERATION}                      1
${ROLLBACK}                       ${False}
${FALLBACK}                       ${False}
${STOP_TEST_AFTER_FAIL}           ${False}
${FEATURE}                        CB013689
${CONFIG_TYPE}                    ${None}    # Set test line configuration e.g. ASIB+ABIC, 2ASIL
                                             # If the config_type and feature are filled,
                                             # the log from the passed iteration will be sent to nescrotta.

${REPORT}                         ${True}
${TESTER_NAME}                    ${None}
${REPORT_COMMENT}                 upgrade_from_FDSW_UUFWRO3_RFRL2

@{TEMPORARY_ALLOWED_FAULTS_4G}    ${None}
@{CUSTOM_ALLOWED_ALARMS_4G}       ${None}
${HW_TO_ONAIR_TIME}               ${None}

&{node1}                          node_alias=4G              testline_object=${tl.enbs[0]}
...                               source_sw=${INITIAL1}      target_sw=${CANDIDATE1}
...                               temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_4G}
...                               custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_4G}
...                               hw_to_onair_timeout=${HW_TO_ONAIR_TIME}


@{NODES}                          ${node1}
@{TEST_NODES}                     ${node1}
${TAGS}                           CA_VRF_TSR2

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
