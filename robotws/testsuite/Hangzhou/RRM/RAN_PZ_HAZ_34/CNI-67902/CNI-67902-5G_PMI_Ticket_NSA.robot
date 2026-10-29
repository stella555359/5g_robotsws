# # #*** Settings ***
# # #Documentation
# # #...         author: shangyu.xu
# # #...         contact: shangyu.xu@nokia-sbell.com
# # #...         squad group: 5G_PZ_MMW_HZ_3_SG
# # #...         DCAP test
# # #
# # #Force Tags    CRT_TRUNK
# # #...    PY36
# # #
# # #Library     taf.sw.dcap.rd		WITH NAME	DCAP
# # #Resource    resources/common_keyword.robot
# # #
# # #
# # #
# # #*** Variables ***
# # #${DCAP_host}    ${tl.test_pcs[0].default_ssh_connection_details.addr}
# # #${DCAP_port}    ${tl.test_pcs[0].default_ssh_connection_details.port}
# # #&{bts}      host=${bts_host}    username=Nemuadmin    password=nemuuser    port=443
# # #${bts_id}   10045
# # #${txt_log_name}    Emil_log_PMI_Ticket.txt
# # #${alias}    gnb_923
# # #${EMIL_HOST}    10.101.47.116
# # #${EMIL_USER}    nokia5G
# # #${EMIL_PASSWORD}    noki@123
# # #${TS_CASE_LOG_PATH}    /home/ute/logs/
# # #${pcmd_log_path}    /home/ute/logs
# # #
# # #*** Test Cases ***
# # #[1]CNI-67902-5G_44_PM_Counters_for_PMI_Ticket_NSA
# # #    [Tags]
# # #    [Setup]
# # #    Step 1: Start DCAP log
# # #    Step 2: Run test
# # #    Step 3: Stop DCAP log and convert to txt type
# # #    Step 4: Check PMI ticket
# # #
# # #[1]CNI-67902-5G_40_PMI_Ticket_SgNB_Addition_NSA
# # #    [Tags]
# # #    [Setup]
# # #    Step 5: Check PMI ticket SgNbAddition
# # #
# # #[1]CNI-67902-5G_41_PMI_Ticket_SgNB_Release_NSA
# # #    [Tags]
# # #    [Setup]
# # #    Step 6: Check PMI ticket SgNbRelease
# # #
# # #[1]CNI-67902-5G_42_PMI_Ticket_gNBCU_UE_Release_NSA
# # #    [Tags]
# # #    [Setup]
# # #    Step 7: Check PMI ticket CuUeRelease
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
# # #Step 2: Run test
# # #    L3 call start      UE_TYPE=askey
# # #    sleep    10s
# # #    L3 Call Stop      UE_TYPE=askey
# # #    sleep    10s
# # #
# # #Step 3: Stop DCAP log and convert to txt type
# # #    log to console    \n #Download DCAP log
# # #    ${profile_file}    set variable    SourceProfile_PMI_Ticket.ini
# # #    DCAP.stop_trace    trace_id=&{output}[id]
# # #    ${downloaded_emil_file_path}    DCAP.get_results    result_id=&{output}[id]    target_dir=${TS_CASE_LOG_PATH}
# # #    Get the exact emil log and convert to txt
# # #    ...    txt_log_name=${txt_log_name}    DCAP_log_path=${downloaded_emil_file_path}    profile_file=${profile_file}
# # #
# # #
# # #Step 4: Check PMI ticket
# # #    ${SgNbAddition}    ${CuUeRelease}    ${SgNbRelease}    Check NSA Event from Email log    ${txt_log_name}
# # #    should be equal    ${SgNbAddition}    SgNbAddition
# # #    should be equal    ${CuUeRelease}    CuUeRelease
# # #    should be equal    ${SgNbRelease}    SgNbRelease
# # #
# # #Step 5: Check PMI ticket SgNbAddition
# # #    ${event}    set variable    SgNbAddition
# # #    Check Event for all PMI Ticket    ${txt_log_name}    ${event}
# # #
# # #Step 6: Check PMI ticket SgNbRelease
# # #    ${event}    set variable    SgNbRelease
# # #    Check Event for all PMI Ticket    ${txt_log_name}    ${event}
# # #
# # #Step 7: Check PMI ticket CuUeRelease
# # #    ${event}    set variable    CuUeRelease
# # #    Check Event for all PMI Ticket    ${txt_log_name}    ${event}
# # 
