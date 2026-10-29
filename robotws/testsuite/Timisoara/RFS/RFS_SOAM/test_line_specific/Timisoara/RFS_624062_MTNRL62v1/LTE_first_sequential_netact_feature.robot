*** Settings ***
Documentation  Test Suite

Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_10_18_UTESRANRFSMTNRL62
...    SBTS26R3   STATE_SKIP_AGENT

Library    taf/rfrl/csv4all/CSV4AllTestCases.py
Library    Collections
Resource    taf/rfrl/uuf4all/uuf4all_keywords.robot

#UUF4ALL scope
Suite Setup                     Set Initial And Candidate


#Suite Setup        Common Suite Setup

# The command below triggers the full test suite scope.
# If the path /home/ute/init_tc does not exist, please specify the path to the __init__.py file appropriate
# for the VM hostname
# robot -L TRACE -V /home/ute/init_tc /home/ute/MN/UTE/gears/gears.wroclaw.uuf/main/testsuite/basic/LTE_first_sequential_netact_feature.robot

*** Variables ***
${RP_CA}   VRF_SiSo
${RP_LOCATION}    VRF_TSR
${RP_ORGANIZATION}    VRF_TSR_T06

${EMAIL_RECIPIENTS}         None
@{CUSTOMERS}                      TMO US
${INITIAL1}                       ${None}
${INITIAL2}                       ${None}
${CANDIDATE1}                     ${None}
${CANDIDATE2}                     ${None}
${ITERATION}                      1
${ROLLBACK}                       ${True}
${FALLBACK}                       ${True}
${STOP_TEST_AFTER_FAIL}           ${False}
${ROLLBACK_REVERSE_ORDER}         ${True}

${TEST_ON_NODE}                   ${None}    # Specify one of the nodes node1/node2 to test only the selected node
                                             # If ${TEST_ON_NODE} is None, the test will be executed on all nodes
                                             # in the order set in the variable ${TEST_NODES}


${FEATURE}                        ${None}
${CONFIG_TYPE}                    ${None}    # Set test line configuration e.g. ASIB+ABIC, 2ASIL
                                             # If the config_type and feature are filled,
                                             # the log from the passed iteration will be sent to nescrotta.

${REPORT}                         ${True}
${QC_REPORT}                      ${False}
${REPORT_COMMENT}                 ${None}

${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     ${None}
${QC_PROJECT}                     ${None}
${TESTER_NAME}                    ${None}

${NETACT}                         srnclab1045
${NETACT_PASS}                    Medsql!_1893


&{NETACT_DICT}                    name=${NETACT}               username=omc     password=${NETACT_PASS}
...                               ip_version=IPv4     security_mode=no TLS

@{TEMPORARY_ALLOWED_FAULTS_5G}    ${None}
@{TEMPORARY_ALLOWED_FAULTS_4G}    ${None}
@{CUSTOM_ALLOWED_ALARMS_5G}
...  4773  7107  4385  1815  7300  7319  4452  1898  4700  6134  6132  6129  7513  7511  7509  4694  4530  16  6238
@{CUSTOM_ALLOWED_ALARMS_4G}
...  4773  7107  4385  1815  7300  7319  4452  1898  4700  6134  6132  6129  7513  7511  7509  4694  4530  16  6238
${HW_TO_ONAIR_TIME}               900

&{node1}                    testline_object=${tl.gnbs[0]}
...                         node_alias=BTS1-5G
...                         source_sw=${INITIAL1}
...                         target_sw=${CANDIDATE1}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_5G}
...                         hw_to_onair_timeout=${HW_TO_ONAIR_TIME}


&{node2}                    testline_object=${tl.enbs[0]}
...                         node_alias=BTS2-4G
...                         source_sw=${INITIAL2}
...                         target_sw=${CANDIDATE2}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_4G}
...                         hw_to_onair_timeout=${HW_TO_ONAIR_TIME}


@{NODES1}                   ${node1}
@{NODES2}                   ${node2}

@{NODES}                          ${node2}    ${node1}
@{TEST_NODES}                     ${node2}    ${node1}

*** Test Cases ***
Upgrade rollback test
    [Timeout]   98h
    Run Keyword If    "${TEST_ON_NODE}"=="node2"
    ...    preliminary_upgrade
    ...    ${NODES}
    ...    ${node1}
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}_preliminary_upgrade
    ...    customers_list=${CUSTOMERS}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}    ELSE
    ...    log    TestCase skipped    console=True
    netact_feature_test
    ...    ${NODES}
    ...    ${TEST_NODES}
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
    ...    rollback_reverse_order=${ROLLBACK_REVERSE_ORDER}

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

    Set To Dictionary         ${node1}
    ...                       source_sw=${initial_sw}
    ...                       target_sw=${candidate_sw}

    Set To Dictionary         ${node2}
    ...                       source_sw=${initial_sw}
    ...                       target_sw=${candidate_sw}
