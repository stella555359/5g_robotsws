# *** Settings ***
# Suite Setup    Suite Setup
# Suite Teardown    Suite Teardown
# 
# Documentation
# ...         author: Lixia.tang
# ...         contact: lixia.tang@nokia-sbell.com
# ...         squad group: 5G_PZ_MMW_HZ_3_SG
# ...         CB007425-5G-AC56 test
# 
# Force Tags
# 
# Library     taf.sw.dcap.rd		WITH NAME	DCAP
# Resource    ./Resources/common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# 
# *** Variables ***
# ${DCAP_host}    10.57.150.41
# ${DCAP_port}    443
# &{bts}      host=${bts_host}    username=Nemuadmin    password=nemuuser    port=443
# ${bts_id}   239
# ${txt_log_name}    Emil_log_PMI_Ticket.txt
# ${alias}    sbts_239
# ${EMIL_HOST}    ${tl.ues[0].ssh_connection_details.addr}
# ${EMIL_USER}    ${tl.ues[0].ssh_connection_details.username}
# ${EMIL_PASSWORD}    ${tl.ues[0].ssh_connection_details.password}
# ${TS_CASE_LOG_PATH}    /home/ute/casetest/log_for_dcap/
# 
# 
# *** Test Cases ***
# [1]CB007425_AC_CNI75604_D_007_PMI_Ticket_Event_Report_Check_From_CPUE
#     [Tags]
#     [Timeout]    15min
#     [Setup]    robot_common_operations.Common Suite Setup
#     Run Keyword And Ignore Error    robot_common_operations.Common case setup
#     Start DCAP log
#     L3 call start    UE_TYPE=${UE_TYPE}
#     L3 Call Stop     UE_TYPE=${UE_TYPE}
#     sleep    5s
#     Stop DCAP log and convert to txt type
#     Check PMI ticket SgNbAddition and ProcedureDone
#     [Teardown]    Teardown
# 
# *** Keywords ***
# Start DCAP log
#     log to console    \n Start DCAP log
#     DCAP.connect_to     host=${DCAP_host}    port=${DCAP_port}     username=${None}
#     ...     password=${None}    rd_version=dcapv3    secure=True
#     ${gnb_custom_profile}=     Create List     cp_5g
#     ${output}    DCAP.start_trace     bts=${bts}     gnb_custom_profile=${gnb_custom_profile}     wait_for_activation=${True}
#     ...     control_plane_interface=${True}
#     Log    &{output}[tracer_id]
#     set test variable    &{output}
#     sleep    5s
# 
# Stop DCAP log and convert to txt type
#     log to console    \n Stop DCAP log and convert to txt type
#     ${profile_file}    set variable    SourceProfile_PMI_Ticket.ini
#     DCAP.stop_trace    trace_id=&{output}[tracer_id]
#     OperatingSystem.Create Directory    ${TS_CASE_LOG_PATH}
#     ${downloaded_emil_file_path}    DCAP.get_results    result_id=&{output}[tracer_id]    target_dir=${TS_CASE_LOG_PATH}
#     Get the exact emil log and convert to txt
#     ...    txt_log_name=${txt_log_name}    DCAP_log_path=${downloaded_emil_file_path}    profile_file=${profile_file}
# 
# Check PMI ticket SgNbAddition and ProcedureDone
#     ${event}    set variable    SgNbAddition
#     ${event_type}    set variable    CpUePmiTicket
#     ${trigger_check}    set variable    True
#     ${trigger_expect}    set variable    0
#     ${interval}    set variable    7
#     Check Event for all PMI Ticket
#     ...    ${txt_log_name}    ${event}    ${trigger_check}    ${event_type}
#     ...    trigger_expect=${trigger_expect}    interval=${interval}
# 
# 
# 
# 
# 
# 
