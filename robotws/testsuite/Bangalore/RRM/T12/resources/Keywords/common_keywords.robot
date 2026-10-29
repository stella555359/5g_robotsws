*** Settings ***
Documentation     This contains common keywords which are needed to run P1 L3 Calls.
...               :author Shilpa V Swamy
...               : Modified as per need for FT Amitha Kadambi

Library         BuiltIn
Library         Collections
Library         DateTime
Library         OperatingSystem
Library         String
Library         taf.wts.runner        WITH NAME    wtsrunner
Library         taf.sbts.oam.coam.admin    WITH NAME    admin
Library         taf.transport.ssh     WITH NAME  SSH
Resource        ${CURDIR}/ute_wts_runner.robot
Resource        ${CURDIR}/sosReport.robot
Resource        ${CURDIR}/../Variables/common_variables.robot


*** Keywords ***
Common Optimized Suite Setup
    [Documentation]    For setting up the suite for running test Suite or testcase.
    Get AP Suite Configuration Variables
    Get Component Carrier Variables
    Wait Coam Site To Be Ready
    Check For 6765-D Feature Enabled And Verify DCI
    Modify UTE SCTP Timeout
    ${START_TIME}   Run Keyword And Ignore Error    Get Current Date
    Set Suite Variable    ${START_TIME}

Common Suite Teardown
    [Documentation]    This keyword is used to stop the Log collection at the end of the Suite
    ...                Teardowns the Edaemon and Egate process at the end of suite
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Run Keyword And Ignore Error    ute_wts_runner.Teardown Edaemon And Egate Process
    ${gNB_status}    Run Keyword And Return Status    Wait Coam Site To Be Ready
    Run Keyword If	not ${gNB_status}    Collect Logs When Gnb Status Is Not As Expected

Wait Coam Site To Be Ready
    [Documentation]    Wait Coam Site To Be Ready checking GNB BTS,Radio and Cell states is up.
    [Arguments]    ${timeout}=${gNB_Check_Timeout}
    Log To Console                 Waiting for gNB to be ready... (${timeout} timeout)
    Wait Until Keyword Succeeds    ${timeout}    30sec    admin.Connect To    bts_host=${GNB_ASIK.Ip}
    Set Variable SUITE CFG DIR
    Wait Until Keyword Succeeds    ${timeout}    30sec    Verify Coam BTS Is Configured
    Wait Until Keyword Succeeds    ${timeout}    30sec    Verify Coam Radio Is Online
    Wait Until Keyword Succeeds    ${timeout}    30sec    Verify Coam Cell Is Configured
    Sleep                          30s    reason=problems with cell setup on AP
    [Teardown]    admin.Teardown

Verify Coam BTS Is Configured
    [Documentation]    Verify Coam BTS Is Configured
    ${bts_state}                  admin.Get Mrbts State
    Log To Console                [INFO] BTS STATE : ${bts_state}
    Should Contain Any            ${bts_state}    Configured    IntegratedToRan    onAir    ignore_case=${TRUE}

Verify Coam Radio Is Online
    [Documentation]    Verify Coam Radio Is Online
    ${bts_hw_info}                admin.Get Bts Info
    ${radio_state}                Set Variable
    ...                           ${bts_hw_info['radioModules']['rmod'][0]['status']['operationalState']}
    Log To Console                [INFO] RADIO STATE : ${radio_state}
    Should Be Equal As Strings    ${radio_state}    enabled    ignore_case=${TRUE}

Verify Coam Cell Is Configured
    [Documentation]    Verify Coam Cell Is Configured
    ${cells_info}                 admin.Get Cells Info
    ${procedural_status}          Set Variable    ${cells_info[0]['status']['proceduralStatus']}
    Log To Console                [INFO] CELL STATE : ${procedural_status}
    Should Contain Any            ${procedural_status}    Configured    onAir    ignore_case=${TRUE}

Collect Logs When Gnb Status Is Not As Expected
    [Documentation]    This keyword is used to collect the log if gNB is not in expected state.
    ...                Modified Date: 24-May-2022
    ...                Last Modified by: hemanth.kumar_s_n@nokia.com
    Run Keyword And Continue On Failure    Fail    gNB was not in the expected state
    Collect Logs For Run

NG Link Should Be UP
    [Documentation]    This keyword checks if the NG link is up for the SA variant in egate_console.log file
    ...                Modified Date: 10-Jun-2021
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}
    ...    NG Link Check Using AMF Link Status    ${AMF_ID}    ${TARGET_GNB}
    Run Keyword If    '${4G5G_Combo}'=='1'
    ...    S1 Link Check For ENB
    Log                ng_link_status_is_ok

UE Register Should Be Successful For SA
    [Documentation]    This keyword checks the message for the completion of UE registration
    ...                in the output file for the SANSA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    [Arguments]        ${UE_ID}=${UE_ID}      ${gw_ID}=${gw_ID}	    ${upf}=1    ${nwslice_ID}=1
    wtsrunner.UE Register   id=${UE_ID}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Print Matching Lines From Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message For UE Register And Reregister   ${output}
    wtsrunner.Set Pdu Param   ue=${UE_ID}    pdu=${Pdu_session_ID}    trf_type=${Trf_type}    upf=${upf}
    wtsrunner.UE Pdu Session Setup    pdu=${Pdu_session_ID}    ue=${UE_ID}   nwslice=${nwslice_ID}   gw=${gw_ID}
    ${PDU_session_setup_output}         Read Wts Output For Pattern And Print Matching Lines
    ...                       ${Initial_context_setup_pattern}       ${Timeout_SA}
    [Return]                  ${PDU_session_setup_output}

UE Register And Verify For SA
    [Documentation]     This keyword checks the message for the completion of UE registration
    ...                 in the output file for the SA variant
    ...                 Arguments - UE_ID
    ...                 Retutns  -   None
    ...                 Modified Date: 6th-Oct-2022
    ...                 Last Modified by: vikash.20.kumar@nokia.com
    [Arguments]         ${UE_ID}=${UE_ID}
    wtsrunner.UE Register           id=${UE_ID}
    ${output}    Read WTS Output Until Pattern Matches        ${UE_register_complete_pattern}        ${Timeout_SA}
    Print Matching Lines From Output File    ${output}        ${Register_complete_pattern}
    Initial Success Message For UE Register And Reregister          ${output}

PDU Session Setup
    [Documentation]     This Keyword sets the PDU params and checks the message for the completion of PDU session setup
    ...                 Arguments - UE_ID
    ...                 Retutns  -   None
    ...                 Modified Date: 6th-Oct-2022
    ...                 Last Modified by: vikash.20.kumar@nokia.com
    [Arguments]         ${UE_ID}=${UE_ID}       ${nwslice_ID}=1
    wtsrunner.Set Pdu Param       ue=${UE_ID}    pdu=${Pdu_session_ID}      trf_type=${Trf_type}
    wtsrunner.UE Pdu Session Setup     pdu=${Pdu_session_ID}      ue=${UE_ID}    nwslice=${nwslice_ID}    gw=${gw_ID}
    Read Wts Output For Pattern And Print Matching Lines          ${Initial_context_setup_pattern}      ${Timeout_SA}

Re-Establish RRC Setup UE
    [Documentation]    Re-Establish RRC Setup UE
    [Arguments]             ${ue_id}=1
    wtsrunner.UE RRC Reestablish            id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches      ${UE_rrc_reestablish_complete_pattern}      ${Timeout_SA}
    Print Matching Lines From Output File    ${output}      ${Rrc_reestablish_complete_pattern}
    Sleep           5s

Trigger Trace Recording With Pdu Setup From AMF
    [Documentation]    Trigger Trace Recording With Pdu Setup From AMF
    [Arguments]    ${ue_id}=1    ${tce_ip}=0.0.0.0
    wtsrunner.AMF UE ICS Param  id=1    ue=${ue_id}     object_id=1     location_reporting_reference_id=1
    ...     trace_activation=on     trace_plmn=311:489
    ...     trace_ref_id=1      trace_rec_session_ref_id=1      trace_depth=medium
    ...     ifaces_to_trace=Uu,NG-C,Xn-C    tce_ip=${tce_ip}

Start Subscriber Trace
    [Documentation]    Start Subscriber Trace
    [Arguments]     ${ue_id}=1          ${trace_session_id}=1       ${tce_ip}=10.0.1.1:49151
    wtsrunner.NG UE Trace Start         id=${ue_id}                 tce_ip=${tce_ip}            trace_depth=maximum
    ...       ifaces_to_trace=NG-C,Xn-C,Uu,F1-C,E1                trace_plmn=311:489
    ...       trace_rec_session_ref_id=${trace_session_id}        trace_ref_id=${trace_session_id}

Stop Subscriber Trace
    [Documentation]    Stop Subscriber Trace
    [Arguments]     ${ue_id}=1          ${trace_session_id}=1
    wtsrunner.NG UE Trace Stop          id=${ue_id}                 trace_plmn=311:489
    ...          trace_rec_session_ref_id=${trace_session_id}       trace_ref_id=${trace_session_id}

Re-Establish Rrc Setup Ue With Action
    [Documentation]    Re-establish rrc setup UE with action
    [Arguments]             ${ue_id}=1               ${action}=invalid_crnti
    wtsrunner.UE RRC Reestablish                     id=${ue_id}         action=${action}
    ${output}     Read WTS Output Until Pattern Matches         ${UE_register_complete_pattern}         ${Timeout_SA}
    Print Matching Lines From Output File        ${output}      ${Register_complete_pattern}
    Sleep           5s

Initial Success Message For UE Register And Reregister
    [Documentation]    This keyword checks the Initial status message for the completion of UE Registration
    ...                And UE Re-registration in the output file for the SA variant
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    [Arguments]    ${output}
    Should Contain     ${output}    ${Initial_UE_message_pattern}    ignore_case=True
    Print Matching Lines From Output File    ${output}    ${Initial_UE_success_pattern}

UE Deregister Should Be Successful For SA
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    [Arguments]    ${UE_ID}=${UE_ID}
    wtsrunner.UE Deregister    id=${UE_ID}    ue_deregister_type=switch_off
    Read Wts Output For Pattern And Print Matching Lines    ${UE_deregister_pattern}    ${Timeout_SA}
    Log                ue_deregister_is_ok

Traffic Should Be Successful For SA
    [Documentation]    This keyword starts and Validates the Traffic for the SA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    [Arguments]   ${traffic_dl_rate}=${Traffic_dl_rate}   ${traffic_ul_rate}=${Traffic_ul_rate_SA}   ${UE_ID}=${UE_ID}
    ute_wts_runner.Start And Validate Traffic For SA    dl_rate=${traffic_dl_rate}    ul_rate=${traffic_ul_rate}
    ...    UE_ID=${UE_ID}
    Log    traffic_is_ok

X2AP Link Should Be UP
    [Documentation]    This keyword is used to Create a X2 connection with gNB
    ...                And checks if the X2AP link with the gNB is UP in the output file.
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    wtsrunner.Enb X2 Link Up    enb=${eNB_ID}    target=${eNB_target}
    Read WTS Output For Pattern And Print Matching Lines    ${X2_link_pattern}    ${Timeout_NSA}
    Log    x2_is_ok

LTE Attach Should Be Successful For NSA
    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    [Arguments]    ${UE_ID}=${UE_ID_NSA}
    wtsrunner.UE Attach         id=${UE_ID}
    ${ue_attach_output}         Read WTS Output For Pattern And Print Matching Lines
    ...    ${LTE_attach_pattern}    ${Timeout_NSA}
    Log    lte_attach_is_ok
    [Return]                    ${ue_attach_output}

UE Attach Should Be Successful For NSA
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    [Arguments]    ${UE_ID}=${UE_ID_NSA}    ${Target_Cells}=${Target_Cells}
    wtsrunner.Enb Ue Dc Start    target_gnb=${Target_gNB}    target_cells=${Target_Cells}    ue=${UE_ID}
    ...                         bearer=${Bearer_ID}    type=split_scg
    Read WTS Output For Pattern And Print Matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}
    # [Return]    ${match_str}

UE 5GDetach Should Be Successful For NSA
    [Documentation]    This keyword is used to Detach the UE from 5G connection with gNB and
    ...                checks the completion message in output file.
    ...                Enhance the keyword to detach SANSA UE as well.
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    [Arguments]        ${UE_ID}=${UE_ID_NSA}
    wtsrunner.Enb UE Dc Release    ue=${UE_ID}    bearer=${Bearer_ID}    by=enb    cause=off
    Read WTS Output For Pattern And Print Matching Lines    ${UE_5GDetach_pattern}    ${Timeout_NSA}
    Log          5gdetach_is_ok

UE Detach Should Be Successful For NSA
    [Documentation]    This keyword is used to Detach the UE with gNB and checks the completion message in output file.
    ...                Modified Date: 31-March-2021
    ...                Last Modified by: anil.1.pachauri@nokia.com
    [Arguments]        ${UE_ID}=${UE_ID_NSA}
    wtsrunner.UE Detach    id=${UE_ID}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_detach_pattern}    ${Timeout_NSA}
    Print Matching Lines From Output File    ${output}    ${UE_detach_pattern}
    Log    detach_is_ok

Read WTS Output For Pattern And Print Matching Lines
    [Documentation]    This keyword checks if the pattern is present in the output file and prints
    ...                the line matching the pattern.
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    [Arguments]        ${pattern}    ${timeout}
    ${output}    Read WTS Output Until Pattern Matches   ${pattern}    ${timeout}
    Print Matching Lines From Output File    ${output}    ${pattern}
    [Return]    ${output}

Read WTS Output Until Pattern Matches
    [Documentation]    This keyword checks the output file until the pattern matches in the file.
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    [Arguments]        ${pattern}    ${timeout}
    ${output}    wtsrunner.Read Wtsemu Output Until Re    expected=${pattern}
    ...    timeout=${timeout}
    [Return]       ${output}

Print Matching Lines from Output File
    [Arguments]    ${output}    ${pattern}
    [Documentation]    This keyword Prints the lines which contains the ${pattern} from the output file ${output}
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    ${output}        Get Lines Matching Regexp    ${output}    ${pattern}
    ...               partial_match=${TRUE}
    set suite variable      ${match_str}   ${output}
    Log to Console    \n ${output}
    [Return]       ${output}

Get AP Suite Configuration Variables
    [Documentation]    This keyword will identify the variables related to ap_configurations
    ${var}    Get Variable Value    ${TOPOLOGY}
    ${var_exists}      Set Variable If    "${var}" != 'None'    ${True}    ${False}
    Run Keyword If    '${var_exists}' == 'False'
    ...   Get AP Suite Configuration From File   ELSE
    ...   Set AP Suite Configuration Variables   ${TOPOLOGY}

Get Component Carrier Variables
    [Documentation]    Get Component Carrier Variables
    ${var}    Get Variable Value    ${COMPONENT_CARRIER}
    ${var_exists}      Set Variable If    "${var}" != 'None'    ${True}    ${False}
    Run Keyword If    '${var_exists}' == 'False'
    ...   Get Component Carrier Value From File   ELSE
    ...   Set Component Carrier Variables    ${COMPONENT_CARRIER}

Set Variable SUITE CFG DIR
    [Documentation]    stream_nr and suite_cfg_dir variables depends on the loads
    ...     If SBTS load: SBTSXX_ENB_YYYY_DDDD_VVVV (standard form) where YYYY = 9999 (reserved for trunk),
    ...     YYYY = other values for branch; list_index=2 (used for identification of load).
    ...     list_index[2]=9999, then stream_nr=SBTS00 else if list_index[2]=0000/0100 then stream_nr=SBTSXX
    ...     else stream_nr will get assigned with perticular trunk or branch load.
    ${sw_version}                admin.Get SW Version
    @{sw_version_list}           Split String    ${sw_version}    separator=_
    ${STREAM_NR}    Run Keyword If    "SBTS" in "${sw_version_list}[0]"
    ...    Set Variable If
    ...    "${sw_version_list}[2]"=="9999" or "${sw_version_list}[2]"=="9000" or "${sw_version_list}[0]"=="SBTS22R4"
    ...    SBTS00    ${sw_version_list}[0]
    ${SUITE_CFG_DIR}              Catenate    SEPARATOR=/    ${SUITE_CFG_DIR_tmp}    ${STREAM_NR}
    Set Global Variable           ${SUITE_CFG_DIR}
    Set Global Variable           ${STREAM_NR}

Trigger Sba Trace Recording Session Via Ngap Handover Request Message
    [Documentation]    Trigger Sba Trace Recording Session Via Ngap Handover Request Message
    [Arguments]    ${ue_id}=1
    wtsrunner.Amf UE Ng Handover Request Param      id=${ue_id}         trace_activation=on
    ...     trace_plmn=311:489          trace_ref_id=0
    ...     trace_rec_session_ref_id=0          tce_ip=10.0.1.1          trace_depth=medium
    ...     ifaces_to_trace=Uu,NG-C,Xn-C

Trigger Sba Trace Recording Session Via Ngap Trace Start Message
    [Documentation]    Trigger Sba Trace Recording Session Via Ngap Trace Start Message
    [Arguments]    ${ue_id}=1    ${trace_session_id}=1    ${tce_ip}=10.0.1.1
    wtsrunner.UE Ng Trace Start      id=${ue_id}         tce_ip=${tce_ip}        trace_depth=minimum
    ...     ifaces_to_trace=Uu,NG-C,Xn-C        trace_plmn=311:489      trace_rec_session_ref_id=${trace_session_id}
    ...     trace_ref_id=${trace_session_id}

Traffic Should Be Successful For NSA
    [Documentation]    This keyword starts and Validates the Traffic for the NSA FDD variants
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    [Arguments]    ${ue_id}=${UE_ID}    ${traffic_dl_rate}=${Traffic_dl_rate}    ${traffic_ul_rate}=${Traffic_ul_rate}
    Start Traffic    UE_ID=${ue_id}    dl_rate=${traffic_dl_rate}    ul_rate=${traffic_ul_rate}
    Log    traffic_is_ok

