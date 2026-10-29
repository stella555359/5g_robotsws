*** Settings ***
Documentation  Test Suite

Library    taf/rfrl/csv4all/CSV4AllTestCases.py
Library    Collections
Resource    taf/rfrl/uuf4all/uuf4all_keywords.robot

#UUF4ALL scope
Suite Setup                     Set Initial And Candidate

#Suite Setup        Common Suite Setup

Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_10_18_UTESRANRFSMTNRL62
...    SBTS26R3   STATE_SKIP_AGENT

*** Variables ***

${RP_CA}   VRF_SiSo
${RP_LOCATION}    VRF_TSR
${RP_ORGANIZATION}    VRF_TSR_T06

${EMAIL_RECIPIENTS}         None

@{CUSTOMERS}                      TMO US
${INITIAL1}
${INITIAL2}
${CANDIDATE1}
${CANDIDATE2}
${ITERATION}                      5
${STOP_TEST_AFTER_FAIL}           ${False}
${ROLLBACK}                       ${True}
${FALLBACK}                       ${False}
${IP_VERSION}                     IPv4       # Set IPv6 if you want to test on IPv6


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


@{NODES}                    ${node1}  ${node2}
@{NODES1}                   ${node1}
@{NODES2}                   ${node2}
@{UPGRADE_NODES}            ${node1}  ${node2}
@{TEST_NODES}               ${node1}  ${node2}

*** Test Cases ***
Parallel SW upgrade rollback fallback via NetAct test
    [Timeout]   98h
    parallel_netact_test
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
