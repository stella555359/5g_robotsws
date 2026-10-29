*** Settings ***
Documentation
...    Author:  Gao Claire
...    Contact: claire.gao@nokia-sbell.com
...    Feature: CB009301
...    Release: 25R2

Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     Run keywords    common_resource_suite.Common Test Teardown
...               AND    ute_syslog.Collect Syslog Results    destination=${TEST_LOG_DIR}    alias=enb_fhdelay
Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF
Resource          ../resources/common_resources.robot

*** Variables ***
@{ALLOWED_FAULT}
${scf_file_72a}      CB009301_ABIP_AVQL_NRTDD_100M_A1_gscn_636666_1xNRCELL_72a_${bts_id}.xml
${dist_name}    MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
${parameter}    actEcpriDelayMeasurement
@{msg5_list}    API_BBB_DELETE_MSG5_SESSION_REQ_MSG    API_BBB_DELETE_MSG5_SESSION_RESP_MSG
...    API_BBB_CREATE_MSG5_SESSION_REQ_MSG    API_BBB_CREATE_MSG5_SESSION_RESP_MSG
...    API_BBB_GET_MSG5_DELAYS_REQ_MSG    API_BBB_GET_MSG5_DELAYS_RESP_MSG    SApiBbbGetMsg5DelaysResp
...    API_BBB_START_PERIODIC_MEASUREMENTS_REQ_MSG    API_BBB_START_PERIODIC_MEASUREMENTS_RESP_MSG

*** Test Cases ***
CB009301_B_TC1_NR_FR1_TDD_eCPRI_ABIP_AVQL_cell_online_enable_and_disable_actEcpriDelayMeasurement
    [Tags]    ABIP    SMAwave    CB009301_TC01    72a    Trunk    QL3
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/CB009301/${scf_file_72a}
    Start Syslog    log_dir=${TEST_LOG_DIR}    log_name=measurement_syslog.log    alias=enb_fhdelay
    Online change SCFC parameter    ${dist_name}    ${parameter}    false
    Sleep    5s
    Wait Until Keyword Succeeds    60s    20s    Check If All Cells Are OnAir
    Online change SCFC parameter    ${dist_name}    ${parameter}    true
    Sleep    5s
    Wait Until Keyword Succeeds    60s    20s    Check If All Cells Are OnAir
    Verify eCPRI FH delay measurement
    Log To Console     \start to check fh msg5 session message
    Check msg5 session in syslog
    Check Measurement Result Status Is Zero
    SMAwave L3 call    cell_id=1    dl_tput=1200M    ul_tput=140M    dl_deviation=10%    rat=5G    band=78    duration=60

*** Keywords ***
Check msg5 session in syslog
    FOR    ${msg5}    IN    @{msg5_list}
        ${msg5_filter}=    Message Should Exist In Syslog File    regexp=${msg5}    alias=enb_fhdelay
        ${msg5_counter}=     Count Syslog messages    regexp=${msg5}    alias=enb_fhdelay
        ${expected_counter}    Set Variable If    '${msg5}'=='API_BBB_GET_MSG5_DELAYS_RESP_MSG'    1    2
        Should Be Equal As Integers    ${msg5_counter}    ${expected_counter}
    ...    [ ERROR ] The number of ${msg5} is NOT expected: ${msg5_filter}
    END

Verify eCPRI FH delay measurement
    ${FHLKDLY_R_OBJECT}    sbts_admin.get_managed_objects    class_name=FHLKDLY_R    connection=None
    ${dl_min_delay} =    Set variable    ${FHLKDLY_R_OBJECT}[0][parameters][dlMinDelay]
    ${ul_min_delay} =    Set variable    ${FHLKDLY_R_OBJECT}[0][parameters][ulMinDelay]
    ${t12Min_t34Min_result} =    Run Keyword And Return Status    Should Be True
    ...    ${dl_min_delay}<200 and ${ul_min_delay}<400
    Run Keyword If    not ${t12Min_t34Min_result}    Fail    [ ERROR ] The eCPRI FH delay measurement is not correct.

Check Measurement Result Status Is Zero
    ${log}=    Get File    ${TEST_LOG_DIR}/measurement_syslog.log
    ${lines}=    Split To Lines    ${log}
    ${bad_lines}=    Evaluate
    ...    [l for l in ${lines} if 'Measurement result: sessionId' in l and not re.search(r'status = 0\\b', l)]
    ...    re
    Should Be Empty    ${bad_lines}    msg=Status is not 0 in: ${bad_lines}