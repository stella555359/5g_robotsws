*** Settings ***
Documentation
Library            taf/rfrl/csv4all/CSV4AllTestCases.py
# Library            ../../../resources/suite_utils.py

Test Timeout       100h
# Suite Setup        Common Suite Setup

*** Variables ***
${RP_CA}   VRF_SiSo
${RP_LOCATION}    VRF_TSR2
${RP_ORGANIZATION}    VRF_TSR2_T05

@{CUSTOMERS}                      Generic
${INITIAL1}                       ${None}
${INITIAL2}                       ${None}
${CANDIDATE1}                     ${None}
${CANDIDATE2}                     ${None}
${ITERATION}                      1
${STOP_TEST_AFTER_FAIL}           ${False}
${DOWNLOAD_PATH}                  ${None}
${USE_TESTPACKAGE}                ${False}

${TEST_ON_NODE}                   ${None}      # Specify one of the nodes node1/node2 to test only the selected node
                                             # If ${TEST_ON_NODE} is None, the test will be executed on all nodes
                                             # in the order set in the variable ${TEST_NODES}

${REPORT}                         ${False}
${QC_REPORT}                      ${False}
${REPORT_COMMENT}                 ${None}

${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     ${None}
${QC_PROJECT}                     ${None}
${TESTER_NAME}                    ${None}

@{TEMPORARY_ALLOWED_FAULTS_5G}    ${None}
@{TEMPORARY_ALLOWED_FAULTS_4G}    ${None}
@{CUSTOM_ALLOWED_ALARMS_5G}       4773  7107  4385  1815  7300  7319  4452  1898  4700  6134  6132  6129  7513  7511  7509  4694  4530
@{CUSTOM_ALLOWED_ALARMS_4G}       4773  7107  4385  1815  7300  7319  4452  1898  4700  6134  6132  6129  7513  7511  7509  4694  4530
${HW_TO_ONAIR_TIME}               ${None}

&{node1}                    testline_object=${tl.enbs[0]}
...                         node_alias=BTS1
...                         source_sw=${INITIAL1}
...                         target_sw=${CANDIDATE1}
...                         temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_4G}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_4G}
...                         hw_to_onair_timeout=${HW_TO_ONAIR_TIME}


&{node2}                    testline_object=${tl.gnbs[0]}
...                         node_alias=BTS2
...                         source_sw=${INITIAL2}
...                         target_sw=${CANDIDATE2}
...                         temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_5G}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_5G}
...                         hw_to_onair_timeout=${HW_TO_ONAIR_TIME}


@{NODES}                          ${node1}    ${node2}
@{TEST_NODES}                     ${node1}    ${node2}


*** Test Cases ***
Upgrade rollback test
    [Timeout]   100h
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    ${NODES}
    ...    ${TEST_NODES}
    ...    ${ITERATION}
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    ...    restore_to_target_sw=${True}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
