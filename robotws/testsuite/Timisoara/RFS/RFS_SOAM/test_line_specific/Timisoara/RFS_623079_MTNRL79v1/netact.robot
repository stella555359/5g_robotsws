*** Settings ***
Documentation  Test Suite

Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Library   Collections
Resource   taf/rfrl/uuf4all/uuf4all_keywords.robot

#UUF4ALL scope
Suite Setup                     Set Initial And Candidate


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables

${RP_CA}   VRF_SiSo
${RP_LOCATION}    VRF_TSR2
${RP_ORGANIZATION}    VRF_TSR2_T05

${EMAIL_RECIPIENTS}         None

${UPDATE_TEST_FAILED}          ${False}

${INITIAL_SW}           ${None}
${TARGET_SW}            ${None}

${ITERATIONS}               1

@{CUSTOM_ALLOWED_ALARMS}    4773  7107  4385  1815  7300  7319  4452  1898  4700  6134  6132  6129  7513  7511  7509  4694  4530

@{CUSTOMERS}                      Generic
${ITERATION}                      1
${STOP_TEST_AFTER_FAIL}           ${False}
${DOWNLOAD_PATH}                  ${None}

${SW_FALLBACK_TIMMER}             ${None}
${SWITCH_DICT}                    ${None}


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

${HW_TO_ONAIR_TIME}               ${None}

${ROLLBACK}                       ${True}
${FALLBACK}                       ${True}

${FEATURE}                        ${None}
${CONFIG_TYPE}                    ${None}    # Set test line configuration e.g. 'ASIB+ABIC', '2ASIL'
                                             # If the config_type and feature are filled,
                                             # the log from the passed iteration will be sent to nescrotta.


&{NETACT_DICT}                    name=srnclab1019           username=omc     password=Medsql!_1893
...                               ip_version=IPv4     security_mode=no TLS


&{node1}                    testline_object=${tl.gnbs[0]}
...                         node_alias=BTS1
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}


&{node2}                    testline_object=${tl.enbs[0]}
...                         node_alias=BTS2
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}

@{NODES}                    ${node1}  ${node2}
@{NODES1}                   ${node1}
@{NODES2}                   ${node2}
@{UPGRADE_NODES}            ${node1}  ${node2}
@{TEST_NODES}               ${node1}  ${node2}


*** Test Cases ***
Upgrade rollback test netact
    [Timeout]   98h
    netact_feature_test
    ...    ${NODES}
    ...    ${node1}
    ...    ${ITERATION}
    ...    netact_dict=${NETACT_DICT}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    ...    rollback=${ROLLBACK}
    ...    fallback=${FALLBACK}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    feature=${FEATURE}
    ...    config_type=${CONFIG_TYPE}


*** Keywords ***
#UUF4ALL Test Helper KW
Set Test Failed
    Set Suite Variable  ${UPDATE_TEST_FAILED}  ${True}

#UUF4ALL Test Helper KW
Check Update Status
    Run Keyword If      ${UPDATE_TEST_FAILED}  Fail

#UUF4ALL Test Helper KW
Simple admin connection
    ${setup_status}=  run keyword and return status  coam.setup admin
    ...  bts_host=192.168.255.1
    ...  bts_port=443
    ...  admin_api_log_dir=/home/ute/admin_logs/
    ...  name=alias
    Log                       Admin Setup Status: ${setup_status}
    run keyword unless        ${setup_status}  Fail  Setup Admin Failed
    &{bts_info}               coam.get_bts_info  connection=alias  timeout=60
    Log                       ${bts_info}
    [Teardown]  run keyword
    ...       coam.teardown_admin  connection=alias

#UUF4ALL Test Helper KW
Set Initial And Candidate
    ${initial_sw}             Get Source SW
    ${candidate_sw}           Get Target SW

    Set to dictionary         ${node1}
    ...                       source_sw=${initial_sw}
    ...                       target_sw=${candidate_sw}

    Set to dictionary         ${node2}
    ...                       source_sw=${initial_sw}
    ...                       target_sw=${candidate_sw}
