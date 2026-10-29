*** Settings ***
Suite Setup    Run keywords    Suite Setup    AND    robot_common_operations.Common Suite Setup
    ...    AND    Adapt SCF Name By Release and Commition SCF
Suite Teardown    Run keywords    Suite Teardown    AND    robot_common_operations.Common Suite Teardown

Documentation
...         author: shangyu.xu
...         contact: shangyu.xu@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         DCAP test

Force Tags    CIT_22R3
...    PY36

Library     taf.sw.dcap.rd		WITH NAME	DCAP
Resource    ./Resources/common_keyword.robot



*** Variables ***
${DCAP_host}    ${tl.test_pcs[0].default_ssh_connection_details.addr}
${DCAP_port}    ${tl.test_pcs[0].default_ssh_connection_details.port}
&{bts}      host=${bts_host}    username=Nemuadmin    password=nemuuser    port=443
${bts_id}   10039
${txt_log_name}    Emil_log_PMI_Ticket.txt
${alias}    gnb_921
${EMIL_HOST}    10.101.47.116
${EMIL_USER}    nokia5G
${EMIL_PASSWORD}    noki@123
${TS_CASE_LOG_PATH}    /home/ute/casetest/log_for_dcap/


*** Test Cases ***
[1]CNI-75604-B_03_PMI_Ticket_Counters_from_CP-RT_related_SA_Call
    [Tags]    CIT_22R3
    [Setup]    robot_common_operations.Common Case Setup
    #[Setup]    Run Keywords    Adapt SCF Name By Release and Commition SCF    AND    robot_common_operations.Common Suite Setup
    [Teardown]    Teardown
    L3 call start    UE_TYPE=askey
    L3 Call Stop    UE_TYPE=askey
    Start DCAP log
    L3 call start secend    UE_TYPE=askey
    sleep    5s
    L3 Call Stop    UE_TYPE=askey
    Stop DCAP log and convert to txt type
    Check PMI ticket DuContextSetup

[1]CNI-75604-C_12_PMI_Ticket_Event_report_from_CP-RT_DUContextSetup_SA_call
    [Tags]    CIT_22R3
    [Setup]    robot_common_operations.Common Case Setup
    [Teardown]    Teardown
    Check PMI ticket DuContextSetup

[1]CNI-75604-D_43_PMI_Ticket_Event_report_from_CP-UE_gNBCUPDUSession_initial_setup_trigger_SA
    [Tags]    CIT_22R3
    [Setup]    robot_common_operations.Common Case Setup
    [Teardown]    Teardown
    Check PMI ticket PduSessionInformation    trigger_expect=1

*** Keywords ***
Start DCAP log
    log to console    \n Start DCAP log
    DCAP.connect_to     host=${DCAP_host}    port=${DCAP_port}     username=utfuser
    ...     password=utfadmin!     rd_version=dcapv3    secure=True
    ${gnb_custom_profile}=     Create List     cp_5g
    ${output}    DCAP.start_trace     bts=${bts}     gnb_custom_profile=${gnb_custom_profile}     wait_for_activation=${True}
    ...     control_plane_interface=True
    Log    ${output}[tracer_id]
    set test variable    &{output}
    sleep    5s

Stop DCAP log and convert to txt type
    log to console    \n Stop DCAP log and convert to txt type
    ${profile_file}    set variable    SourceProfile_PMI_Ticket.ini
    DCAP.stop_trace    trace_id=${output}[tracer_id]
    ${downloaded_emil_file_path}    DCAP.get_results    result_id=${output}[tracer_id]    target_dir=${TS_CASE_LOG_PATH}
    Get the exact emil log and convert to txt
    ...    txt_log_name=${txt_log_name}    DCAP_log_path=${downloaded_emil_file_path}    profile_file=${profile_file}

Check PMI ticket PduSessionInformation
    [Arguments]    ${trigger_expect}
    ${event}    set variable    PduSessionInformation
    ${event_type}    set variable    CpUePmiTicket
    ${trigger_check}    set variable    True
    ${interval}    set variable    7
    Check Event for all PMI Ticket
    ...    ${txt_log_name}    ${event}    ${trigger_check}    ${event_type}
    ...    trigger_expect=${trigger_expect}    interval=${interval}

Check PMI ticket DuContextSetup
    [Arguments]
    ${event}    set variable    DuContextSetup
    ${event_type}    set variable    CpRtPmiTicket
    ${trigger_check}    set variable    False
    Check Event for all PMI Ticket
    ...    ${txt_log_name}    ${event}    ${trigger_check}    ${event_type}
