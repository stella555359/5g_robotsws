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
# The SW that is current on BTS
${INITIAL}                        ${None}
# The SW that is current on BTS
${CANDIDATE}                      ${None}
# The number of reset that you want to execute
${ITERATION}                      20

${REPORT}                         ${True}
${REPORT_COMMENT}                 standalone_reset_test_WRO34

${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     ${None}
${QC_PROJECT}                     ${None}

${TEMPORARY_ALLOWED_FAULTS_4G}    ${None}
${CUSTOM_ALLOWED_ALARMS_4G}       ${None}
${HW_TO_ONAIR_TIME}               ${None}

&{enb1}                           node_alias=4G           testline_object=${testline_object}
...                               source_sw=${INITIAL}    target_sw=${CANDIDATE}
...                               temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_4G}
...                               custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_4G}
...                               hw_to_onair_timeout=${HW_TO_ONAIR_TIME}

@{NODES}                          ${enb1}

*** Keywords ***
Site reset
    [Timeout]    97h
    Standalone Common Suite Setup
    e2e_tl_activation_reset_test
    ...    ${NODES}
    ...    ${enb1}
    ...    ${ITERATION}
    ...    customers_list=${CUSTOMERS}


