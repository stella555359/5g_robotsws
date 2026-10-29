*** Settings ***
Documentation  Test Suite

Library    taf/rfrl/csv4all/CSV4AllTestCases.py
Library    Collections
Resource    taf/rfrl/uuf4all/uuf4all_keywords.robot

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

${INITIAL_SW}
${TARGET_SW}


@{CUSTOM_ALLOWED_ALARMS}    4773  7107  4385  1815  7300  7319  4452  1898  4700  6134  6132  6129  7513  7511  7509  4694  4530  16 4401

@{CUSTOMERS}                      Generic
${ITERATION}                      30
${STOP_TEST_AFTER_FAIL}           ${False}
${DOWNLOAD_PATH}                  ${None}
${ACTIVATE_SW_AT_THE_END}         ${True}
${USE_TESTPACKAGE}                ${True}


${REPORT}                         ${False}
${QC_REPORT}                      ${False}
${REPORT_COMMENT}                 ${None}

${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     ${None}
${QC_PROJECT}                     ${None}
${TESTER_NAME}                    ${None}

${HW_TO_ONAIR_TIME}               900

&{node2}                    testline_object=${tl.gnbs[0]}
...                         node_alias=BTS1-5G
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}

@{NODES}                    ${node2}

*** Test Cases ***
E2E_TL_SW_Download_Test
    [Timeout]   100h
    e2e_tl_sw_download_test
    ...    ${NODES}
    ...    ${node2}
    ...    ${ITERATION}
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    download_path=${DOWNLOAD_PATH}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    activate_sw_at_the_end=${ACTIVATE_SW_AT_THE_END}

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

    Set To Dictionary         ${node2}
    ...                       source_sw=${initial_sw}
    ...                       target_sw=${candidate_sw}

