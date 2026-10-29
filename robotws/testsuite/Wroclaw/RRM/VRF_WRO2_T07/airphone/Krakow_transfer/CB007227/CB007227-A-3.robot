*** Settings ***
Documentation
...            title:        CB007227-A Introduction of Trace Framework for CP-NRT
...
...            author:       Michal Sagan, michal.sagan@nokia.com
...                          Jakub Rutyna, jakub.rutyna@nokia.com
...            maintainer:   Michal Sagan, michal.sagan@nokia.com

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource    CB007227_common.robot

Suite Setup       Run Keywords
...               Add Simulated GNB to WTS Config    wts_delta=${DELTA_WTS_A3_Xn}    wts_out=${WTS_HO}
...    AND        Testline Setup    config=${SUITE_CONFIG}    reach_on_air=yes    wts=${WTS_HO}
...    AND        Start X2 Link    target_gnb_id=3
Suite Teardown    Testline Teardown

Test Setup        Run Keywords
...               Switch HO Type to Xn in Ext GNB
...    AND        Set Sim GNB To Xn HO and A3 Event
...    AND        Test Case Setup    logs=${LOGS_WITH_DCAP}    radio_res=no
Test Teardown     Run Keywords
...               Add Scout External Execution ID To Reporting Portal
...    AND        Test Case Teardown    check_radio_res=no    oam_logs=no
...    AND        Update Sim ENB EN-DC Parameters    id=1    reset=yes
*** Variables ***
# Config Files
@{IP_ADDR_SIM_GNB}    eth3:10.0.1.3/24    eth3:10.44.76.28/24
${CONFIG_PCMD}        ${CURDIR}/configs/Delta_PCMD_NRMTRACECUUP_tracing.json
${CONFIG_HO}          ${CURDIR}/configs/Delta_HO_Xn_NG_A3_A5_TDD.json
${DELTA_WTS_A3_Xn}    ${CURDIR}/configs/wts_sim_gnb_A3_XnHO.cfg
${WTS_HO}             ${OUTPUT DIR}/Logs/wts_ext_and_sim_gnb.cfg
@{DELTAS}             ${CONFIG_HO}    ${CONFIG_PCMD}
&{SUITE_CONFIG}       delta=${DELTAS}    ip_addr=${IP_ADDR_SIM_GNB}
# Logging Options
@{DCAP_GNB}             condor5gSyslog
@{DCAP_BTS}             ipCapture
&{DCAP_OPTIONS}         gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}       dcap=${DCAP_OPTIONS}    tcpdump_gnb=yes
@{tshark_options}       -o    ntrstr.defragment:TRUE    -o    ntrstr.port:49148

*** Test Cases ***
# Test transferred from Krakow, will be rewritten
[1]CB007227-5G-A_3_B03_RAN_UE_ID_Sent_by_target_gNB-CU-UP_during_Xn_based_Inter_gNB_handover_SA
    [Documentation]    Scenario: SA attach to simulated gNB --> HO to real gNB
    Prepare UE History Information    ue=1    nrci=0x01
    Prepare UE History Information    ue=2    nrci=0x02
    Setup Devices Aliases
    Change UE-1 Location To Sim GNB
    Change UE-2 Location To Sim GNB
    Setup SA UE and Expect Measurement Event Config    ue_id=1    event=A3
    Setup SA UE and Expect Measurement Event Config    ue_id=2    event=A3
    Start Internal SA Bidirectional Traffic    ue_id=1
    Start Internal SA Bidirectional Traffic    ue_id=2
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=10s
    Verify SA UE Traffic Using Bearer Stats    ue_id=2    wait=10s
    Perform Xn Inter-GNB Handover to Ext GNB with UE-1 using A3 Event
    Perform Xn Inter-GNB Handover to Ext GNB with UE-2 using A3 Event
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=20s
    Verify SA UE Traffic Using Bearer Stats    ue_id=2    wait=20s
    Stop SA L3 Call    ue_id=1
    Stop SA L3 Call    ue_id=2

    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ${records}    Get PCMD Records from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    save_to_file=${TEST_log_dir}/PCMD/PCMD_records.json
    @{GNB_CU_CP_UE_E1AP_ID}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=e1ap.GNB_CU_CP_UE_E1AP_ID
    ...    filter=e1ap.BearerContextSetupRequest_element
    @{GNB_CU_UP_UE_E1AP_ID}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=e1ap.GNB_CU_UP_UE_E1AP_ID
    ...    filter=e1ap.BearerContextSetupResponse_element
    @{RAN_UE_IDs}    Get RAN UE ID reported by both entities from CU level
    ...    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    entity=cu-up     nr_ues=2
    @{START_RECORDING_SESSION_RAN_UE_IDs}    Get Message Field Values from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    field_name=nsetapx.ranUeId
    ...    filter=nsetapx.TraceMessage == StartRecordingSession && nsetapx.nodeType == gnb-cu-up-Ids
    ...    options=${tshark_options}
    Lists Should Be Equal    ${RAN_UE_IDs}    ${GNB_CU_CP_UE_E1AP_ID}
    Should be equal    ${GNB_CU_CP_UE_E1AP_ID}[0]    ${RAN_UE_IDs}[0]
    Should be equal    ${GNB_CU_CP_UE_E1AP_ID}[1]    ${RAN_UE_IDs}[1]

    @{bearerCtxSetupReqRcvTime}    Get Message Timestamp List From Pcap    filter=e1ap.BearerContextSetupRequest_element
    @{bearerCtxSetupCmplSndTime}   Get Message Timestamp List From Pcap    filter=e1ap.BearerContextSetupResponse_element

    ${cu_up_bearer_context_setup_UE1_ho}      Create dictionary
    ...         record_name=bearerCtxSetupRecord
    ...         result=0
    ...         gnb_cu_cp_ue_e1ap_Id=${RAN_UE_IDs}[0]
    ...         gnb_cu_up_ue_e1ap_Id=${GNB_CU_UP_UE_E1AP_ID}[0]
    ...         bearerCtxSetupReqRcvTime.*seconds=${bearerCtxSetupReqRcvTime}[0]      bearerCtxSetupReqRcvTime.*useconds=\\d{2,}
    ...         bearerCtxSetupCmplSndTime.*seconds=${bearerCtxSetupCmplSndTime}[0]    bearerCtxSetupCmplSndTime.*useconds=\\d{2,}
    ${cu_up_bearer_context_setup_UE2_ho}      Create dictionary
    ...         record_name=bearerCtxSetupRecord
    ...         result=0
    ...         gnb_cu_cp_ue_e1ap_Id=${RAN_UE_IDs}[1]
    ...         gnb_cu_up_ue_e1ap_Id=${GNB_CU_UP_UE_E1AP_ID}[1]
    ...         bearerCtxSetupReqRcvTime.*seconds=${bearerCtxSetupReqRcvTime}[1]      bearerCtxSetupReqRcvTime.*useconds=\\d{2,}
    ...         bearerCtxSetupCmplSndTime.*seconds=${bearerCtxSetupCmplSndTime}[1]    bearerCtxSetupCmplSndTime.*useconds=\\d{2,}

    ${PCMD_Seq}    Create List    ${cu_up_bearer_context_setup_UE1_ho}    ${cu_up_bearer_context_setup_UE2_ho}
    Verify PCMD Records Sequence in Collection    ${records}    ${PCMD_Seq}

*** Keywords ***
Perform ${ho_type} Inter-GNB Handover to ${node_type} GNB with UE-${ue_id} using ${event} Event
    [Documentation]    Example of wrapper KW with embeded parameters to improve test steps readability.
    ...                KW assumes that Simulated GNB Cell has PCI 52 and External GNB Cell has PCI 50.
    &{pci}    Create Dictionary    Sim=52    Ext=50
    Run Keyword    Perform Inter-GNB ${ho_type} Handover To Target PCI
    ...    ue_id=${ue_id}    target_pci=${pci}[${node_type}]    event=${event}

Change UE-${ue_id} Location To Sim GNB
    [Documentation]    Example of wrapper KW with embeded parameters to improve test steps readability.
    ...                KW assumes that Sim GNB has ID 3 and has only one cell with ID 1.
    Change UE Location    ue_id=${ue_id}    node_id=3    cell_id=1

Set Sim GNB To ${type} HO and ${event} Event
    [Documentation]    Example of wrapper KW with embeded parameters to improve test steps readability.
    ...                Dictionary is used as a map between embeded parameters (more readable)
    ...                to internal parameters (less readable).
    ...                KW assumes that Sim GNB has ID 3.
    &{ho}    Create Dictionary    Xn=xn_based    NG=ng_based
    Update Sim GNB Parameters    id=3    measEvent=${event}    sa_ho=${ho}[${type}]

Switch HO Type to ${type} in Ext GNB
    [Documentation]    Example of wrapper KW with embeded parameters to improve test steps readability.
    ...                KW assumes that Relation 1 in Cell 1 defines HO neighbour to Simulated GNB.
    ...                External GNB performs Xn HO by default unless it is not allowed, then switches to NG.
    &{values}    Create Dictionary    Xn=allowed    NG=XnHoNotAllowed
    Change NIDD Parameter Online
    ...    dist=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1    param=handoverAllowedSA    value=${values}[${type}]

Prepare UE History Information
    [Arguments]    ${ue}=1    ${nrci}=0x01
    ${reset_history}     Set Variable    ue_history_information_list id=${ue} action=reset
    ${ue_history}        Set Variable
    ...    ue_history_information_list_add_ngran id=${ue} gnb_id=3 cell_type=large nrcgi=311:489|${nrci} time_ue_stayed_in_cell=98
    ${commit_history}    Set Variable    ue_history_information_list id=${ue} action=commit
    ${assign_history}    Set Variable    ue_enb_param id=${ue} ue_history_list=${ue}
    ute_wtssim.execute_egate_command    cmd=${reset_history};${ue_history};${commit_history};${assign_history}
