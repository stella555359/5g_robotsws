*** Settings ***
Documentation
...         author: yingying.li
...         contact: yingying.li@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         DCAP test

Force Tags    CRT_TRUNK
...    PY36

Suite Setup    Suite setup
Suite Teardown    Suite teardown
Test Timeout       40 min

Resource    resources/common_keyword_A.robot


*** Variables ***
&{SBTS}    alias=sbts_934    host=${tl.gnbs[0].dus[0].f1_m_ip_addr}  username=Nemuadmin    password=nemuuser    port=443
    ...    bts_id=934

*** Test Cases ***
[1]CNI68580-A-02_trace can be activated and deactived via Emil by using ZMQ and SCTP application in SBTS
    [Tags]
    [Setup]     robot_common_operations.Common Case Setup
    Create Bts On DCAP    bts_mr_id=${SBTS['bts_id']}    bts=${SBTS}
    Start DCAP log    bts=${SBTS}
    Get BTSId
    Lock cell
    Unlock cell
	Wait until keyword succeeds    15 min    10 sec    COAM Check All Cells Onair    connection=default
    COAM Check All Cells Onair    connection=default
    #Prepare UE and attach UE
    #Start UE traffic
	Stop DCAP log
	sleep    3m
    ${downloaded_emil_file_path}    DCAP.get_results    result_id=${result_id}   target_dir=${TS_CASE_LOG_PATH}
    Get the exact emil log and filter ZMQ/SCTP and convert to txt for SBTS     DCAP_log_path=${downloaded_emil_file_path}
    Check ZMQ/SCTP message    emil_txt_log=${emil_txt_log}
    [Teardown]    Run keywords    Case teardown

[1]CNI68580-A-05_trace can be activated and deactived via Emil by using Syscom application in SBTS
    [Tags]
    [Setup]     robot_common_operations.Common Case Setup
    #DCAP.connect_to    host=${DCAP_host}     port=${DCAP_port}     secure=True
    ${downloaded_emil_file_path}    DCAP.get_results    result_id=${result_id}   target_dir=${TS_CASE_LOG_PATH}
    Get the exact emil log and filter SYSCOM and convert to txt for SBTS    DCAP_log_path=${downloaded_emil_file_path}
    Check SYSCOM message    emil_txt_log=${emil_txt_log}
    [Teardown]    Case teardown

*** Keywords ***
Case teardown
    log to console    Case teardown
    #Run Keyword and Ignore Error    DCAP.stop_trace    trace_id=${result_id}
    Run Keyword and Ignore Error    Dcap delete bts
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
    log to console    delete txt file
    csn.Execute   command=sudo rm -rf ${TS_CASE_LOG_PATH}*    connection=ute
    log to console    delete dcap_tmp
    csn.Execute   command=sudo rm -rf ${TS_CASE_LOG_PATH}dcap_tmp/*    connection=ute
    csn.Disconnect     connection=ute
    robot_common_operations.Common Case Setup
