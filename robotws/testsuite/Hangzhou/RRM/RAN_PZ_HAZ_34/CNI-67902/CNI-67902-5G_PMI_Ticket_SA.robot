# # #*** Settings ***
# # #Suite Setup    Suite Setup
# # #Suite Teardown    Suite Teardown
# # #
# # #Documentation
# # #...         author: shangyu.xu
# # #...         contact: shangyu.xu@nokia-sbell.com
# # #...         squad group: 5G_PZ_MMW_HZ_3_SG
# # #...         DCAP test
# # #
# # #Force Tags    CIT_22R2    CRT_TRUNK
# # #...    PY36
# # #
# # #Library     taf.sw.dcap.rd		WITH NAME	DCAP
# # #Resource    ./resources/common_keyword.robot
# # #
# # #
# # #
# # #*** Variables ***
# # #${DCAP_host}    ${tl.test_pcs[0].default_ssh_connection_details.addr}
# # #${DCAP_port}    ${tl.test_pcs[0].default_ssh_connection_details.port}
# # #&{bts}      host=${bts_host}    username=Nemuadmin    password=nemuuser    port=443
# # #${bts_id}   10039
# # #${txt_log_name}    Emil_log_PMI_Ticket.txt
# # #${alias}    gnb_921
# # #${EMIL_HOST}    10.101.47.23
# # #${EMIL_USER}    nokia5G
# # #${EMIL_PASSWORD}    noki@123
# # #${TS_CASE_LOG_PATH}    /home/ute/casetest/log_for_dcap/
# # #${pcmd_log_path}    /home/ute/casetest/log_for_dcap
# # #
# # #
# # #*** Test Cases ***
# # #[1]CNI-67902-5G_45_PM_Counters_for_PMI_Ticket_SA
# # #    [Tags]    CIT_22R2    CRT_TRUNK
# # #    [Setup]
# # #    [Teardown]    Teardown
# # #    Step 1: Start DCAP log
# # #    Step 2: UE attach
# # #    Step 3: Stop DCAP log and convert to txt type
# # #    Step 4: UE release
# # #    Step 5: Check PMI ticket
# # #    Get SW Release
# # #
# # #[1]CNI-67902-5G_9_PMI_Tickets_trace_gNB-CU_UESetup_Record_SA
# # #    [Tags]    CIT_22R2    CRT_TRUNK
# # #    [Setup]
# # #    [Teardown]    Teardown
# # #    Step 6: Check CP-UE PMI ticket UESetup
# # #
# # #
# # #[1]CNI-67902-5G_8_PMI_Tickets_trace_gNB-CU_PDU_Session_Info_Record_SA
# # #    [Tags]    CIT_22R2    CRT_TRUNK
# # #    [Setup]
# # #    [Teardown]    Teardown
# # #    Step 7: Check CP-UE PMI ticket PDUSession
# # #
# # #[1]CNI-67902-5G_12_PMI_Tickets_trace_gNB-CU_UeDuConnectivity_Record_SA
# # #    [Tags]    CIT_22R2    CRT_TRUNK
# # #    [Setup]
# # #    [Teardown]    Teardown
# # #    Step 8: Check CP-UE PMI ticket UeDuConnectivity
# # #
# # #
# # #*** Keywords ***
# # #Step 1: Start DCAP log
# # #    DCAP.connect_to     host=${DCAP_host}    port=${DCAP_port}     username=dcapuser
# # #    ...     password=dcapadmin!     rd_version=dcapv3    secure=True
# # #    ${gnb_custom_profile}=     Create List     cp_5g
# # #    ${output}    DCAP.start_trace     bts=${bts}     gnb_custom_profile=${gnb_custom_profile}     wait_for_activation=${True}
# # #    ...     control_plane_interface=${True}
# # #    Log    &{output}[id]
# # #    set test variable    &{output}
# # #
# # #Step 2: UE attach
# # #    sleep    10s
# # #    L3 call start    UE_TYPE=askey
# # #
# # #Step 3: Stop DCAP log and convert to txt type
# # #    ${profile_file}    set variable    SourceProfile_PMI_Ticket.ini
# # #    DCAP.stop_trace    trace_id=&{output}[id]
# # #    ${downloaded_emil_file_path}    DCAP.get_results    result_id=&{output}[id]    target_dir=${TS_CASE_LOG_PATH}
# # #    Get the exact emil log and convert to txt
# # #    ...    txt_log_name=${txt_log_name}    DCAP_log_path=${downloaded_emil_file_path}    profile_file=${profile_file}
# # #
# # #Step 4: UE release
# # #    L3 Call Stop    UE_TYPE=askey
# # #    sleep    20s
# # #
# # #Step 5: Check PMI ticket
# # #    ${UeSetup}    ${PduSessionInformation}    ${UeDuConnectivity}    Check SA Event from Email log    ${txt_log_name}
# # #    should be equal    ${UeSetup}    UeSetup
# # #    should be equal    ${PduSessionInformation}    PduSessionInformation
# # #    should be equal    ${UeDuConnectivity}    UeDuConnectivity
# # #
# # #Step 6: Check CP-UE PMI ticket UESetup
# # #    ${event}    set variable    UeSetup
# # #    ${trigger_check}    set variable    True
# # #    ${trigger_check}    set variable if    '${release}' != 'SBTS22R2'    True    False
# # #    ${trigger_expect}    set variable    0
# # #    ${interval}    set variable    7
# # #    Check CP-UE Event for all PMI Ticket
# # #    ...    ${txt_log_name}    ${event}    ${trigger_check}    trigger_expect=${trigger_expect}    interval=${interval}
# # #
# # #Step 7: Check CP-UE PMI ticket PDUSession
# # #    ${event}    set variable    PduSessionInformation
# # #    ${trigger_check}    set variable if    '${release}' != 'SBTS22R2'    True    False
# # #    ${trigger_expect}    set variable    1
# # #    ${interval}    set variable    7
# # #    Check CP-UE Event for all PMI Ticket
# # #    ...    ${txt_log_name}    ${event}    ${trigger_check}    trigger_expect=${trigger_expect}    interval=${interval}
# # #
# # #Step 8: Check CP-UE PMI ticket UeDuConnectivity
# # #    ${event}    set variable    UeDuConnectivity
# # #    ${trigger_check}    set variable    False
# # #    Check CP-UE Event for all PMI Ticket
# # #    ...    ${txt_log_name}    ${event}    ${trigger_check}
# # #
# # #Get SW Release
# # #    [Arguments]   ${connection}=COAM
# # #    ${release}   COAM Get SW Release   connection=${connection}
# # #    set suite variable    ${release}
# # #
# # 
# # 
# # 
# # 
