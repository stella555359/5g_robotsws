*** Settings ***
Documentation
...                author: VRF3WRO3
...                maintainer: Jagoda Kubacka
...                contact: jagoda.kubacka@nokia.com
...                Test suite for basic UUF OAM reset wo HWF tests in the standalone configuration

Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           ./Resources/uuf.robot

*** Variables ***
@{CUSTOMERS}                      TMO US
# The SW that is current on BTS - must be lower than ${CANDIDATE}
${INITIAL}                        ${None}
# The SW that will be uploaded on the BTS (target SW) - must be higher than ${INITIAL}
${CANDIDATE}                      ${None}
# The number of iterations that will be executed (1 iteration = upgrade + rollback)
${ITERATION}                      3
# If you want that test will stopped after fail, change below {False} to {True}
${STOP_TEST_AFTER_FAIL}           ${False}
${DOWNLOAD_PATH}                  ${None}
${USE_TESTPACKAGE}                ${False}

${REPORT}                         ${False}
${REPORT_COMMENT}                 standalone_upgrade_test_WRO34

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

*** Keywords ***
Upgrade rollback test
    Standalone Common Suite Setup
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    ${NODES}
    ...    ${enb1}
    ...    ${ITERATION}
    ...    customers_list=${CUSTOMERS}
    ...    restore_to_target_sw=${False}
    ...    download_path=${DOWNLOAD_PATH}
    ...    use_testpackage=${USE_TESTPACKAGE}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

Prelimitary upgrade
    Standalone Common Suite Setup
    preliminary_upgrade
    ...    ${NODES}
    ...    ${enb1}
    ...    customers_list=${CUSTOMERS}
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}

Rollback test
    ${new_target}=    Set Variable    ${INITIAL}
    Set to Dictionary    ${enb1}    source_sw=${CANDIDATE}    target_sw=${new_target}
    e2e_tl_rollback_test
    ...    ${NODES}
    ...    ${enb1}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
