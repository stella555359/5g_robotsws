*** Settings ***
Documentation     This contains common keywords which are needed to run P1 L3 Calls.
...               :author Shilpa V Swamy
...               : Modified as per need for FT Amitha Kadambi

Library     BuiltIn
Library     String
Library     Collections
Library     OperatingSystem
Library     taf.wts.runner    WITH NAME    wtsrunner
Library     taf.gnb.oam.coam.admin    WITH NAME    admin
Resource    ${CURDIR}/../ute/ute_wts_runner.robot
Resource    ${CURDIR}/../ute/sosReport.robot
Resource    ${CURDIR}/../Variables/common_variables.robot

*** Keywords ***
Common Suite Setup
    [Documentation]    This keyword is used to start the UTE SCTP timeout and WTS related process at the start of suite
    ...                The sos report logs collection will be started
    ...                Modified Date: 22-Dec-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Get Component Carrier Variables
    Wait Coam Site to be Ready
    ute_wts_runner.Check for 6765-D feature enabled and Verify DCI
    ute_wts_runner.Modify UTE SCTP Timeout
    ${start_time}   Run Keyword And Ignore Error    Get Current DateTime
    Set Suite Variable    ${start_time}

Common Optimized Suite Setup
    [Documentation]    This keyword is used load test suite varaibles dynamically based on TOPOLOGY value
    ...                This keyword need to be removed once individual test suite are removed in repo:
    ...                Modified Date: 31-May-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    Get AP Suite Configuration Variables
    Common Suite Setup

Common Suite Teardown
    [Documentation]    This keyword is used to stop the Log collection at the end of the Suite
    ...                Teardowns the Edaemon and Egate process at the end of suite
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Run Keyword and Ignore Error    ute_wts_runner.Teardown Edaemon and Egate process
    ${gNB_status}    Run Keyword And Return Status    Wait Coam Site to be Ready
    Run Keyword if	not ${gNB_status}    Collect Logs when gNB Status Is not As Expected

Wait Coam Site to be Ready
    [Arguments]    ${timeout}=${gNB_Check_Timeout}
    Log to Console                 Waiting for gNB to be ready... (${timeout} timeout)
    Wait Until Keyword Succeeds    ${timeout}    30sec    admin.Connect To    bts_host=${GNB_ASIK.Ip}
    Set Variable SUITE_CFG_DIR
    Wait Until Keyword Succeeds    ${timeout}    30sec    Verify Coam BTS is Configured
    Wait Until Keyword Succeeds    ${timeout}    30sec    Verify Coam Radio is Online
    Wait Until Keyword Succeeds    ${timeout}    30sec    Verify Coam Cell is Configured
    Sleep                          30s    reason=problems with cell setup on AP
    [Teardown]    admin.Teardown

Verify Coam BTS is Configured
    ${bts_state}                  admin.Get Mrbts State
    Log to Console                [INFO] BTS STATE : ${bts_state}
    Should Contain Any            ${bts_state}    Configured    IntegratedToRan    onAir    ignore_case=${TRUE}

Verify Coam Radio is Online
    ${bts_hw_info}                admin.Get Bts Info
    ${radio_state}                Set Variable
    ...                           ${bts_hw_info['radioModules']['rmod'][0]['status']['operationalState']}
    Log to Console                [INFO] RADIO STATE : ${radio_state}
    Should Be Equal As Strings    ${radio_state}    enabled    ignore_case=${TRUE}

Verify Coam Cell is Configured
    ${cells_info}                 admin.Get Cells Info
    ${procedural_status}          Set Variable    ${cells_info[0]['status']['proceduralStatus']}
    Log to Console                [INFO] CELL STATE : ${procedural_status}
    Should Contain Any            ${procedural_status}    Configured    onAir    ignore_case=${TRUE}

Collect Logs when gNB Status Is not As Expected
    [Documentation]    This keyword is used to collect the log if gNB is not in expected state.
    ...                Modified Date: 24-May-2022
    ...                Last Modified by: hemanth.kumar_s_n@nokia.com
    Run Keyword And Continue on Failure    Fail    gNB was not in the expected state
    Collect Logs For Run

NG Link Should be UP
    [Documentation]    This keyword checks if the NG link is up for the SA variant in egate_console.log file
    ...                Modified Date: 10-Jun-2021
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}
    ...    NG link check using AMF Link Status    ${AMF_ID}    ${TARGET_GNB}
    Run Keyword If    '${4G5G_Combo}'=='1'
    ...    S1 link check for eNB
    Log                ng_link_status_is_ok

UE Register should be Successful for SA
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SANSA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    [Arguments]    ${UE_ID}=${UE_ID}    ${gw_ID}=${gw_ID}	${upf}=1
    wtsrunner.ue_register   id=${UE_ID}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param   ue=${UE_ID}    pdu=${Pdu_session_ID}    trf_type=${Trf_type}    upf=${upf}
    wtsrunner.ue_pdu_session_setup    pdu=${Pdu_session_ID}    ue=${UE_ID}   nwslice=${nwslice_ID}   gw=${gw_ID}
    ${PDU_session_setup_output}         Read WTS Output For Pattern And Print matching Lines
    ...                                 ${Initial_context_setup_pattern}       ${Timeout_SA}
    [Return]                            ${PDU_session_setup_output}

UE Register and verify for SA
    [Arguments]         ${UE_ID}=${UE_ID}
    [Documentation]     This keyword checks the message for the completion of UE registration in the output file for the SA variant
    ...                 Arguments - UE_ID
    ...                 Retutns  -   None
    ...                 Modified Date: 6th-Oct-2022
    ...                 Last Modified by: vikash.20.kumar@nokia.com
    wtsrunner.ue_register           id=${UE_ID}
    ${output}       Read WTS Output Until Pattern Matches           ${UE_register_complete_pattern}         ${Timeout_SA}
    Print Matching Lines from Output File          ${output}        ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister          ${output}

PDU Session setup
    [Documentation]     This Keyword sets the PDU params and checks the message for the completion of PDU session setup
    ...                 Arguments - UE_ID
    ...                 Retutns  -   None
    ...                 Modified Date: 6th-Oct-2022
    ...                 Last Modified by: vikash.20.kumar@nokia.com
    [Arguments]         ${UE_ID}=${UE_ID}
    wtsrunner.set_pdu_param             ue=${UE_ID}                 pdu=${Pdu_session_ID}       trf_type=${Trf_type}
    wtsrunner.ue_pdu_session_setup      pdu=${Pdu_session_ID}       ue=${UE_ID}                 nwslice=${nwslice_ID}   gw=${gw_ID}
    Read WTS Output For Pattern And Print matching Lines            ${Initial_context_setup_pattern}            ${Timeout_SA}

Re-establish rrc setup UE
    [Arguments]             ${ue_id}=1
    wtsrunner.ue_rrc_reestablish            id=${ue_id}
    ${output}       Read WTS Output Until Pattern Matches           ${UE_rrc_reestablish_complete_pattern}          ${Timeout_SA}
    Print Matching Lines from Output File          ${output}        ${Rrc_reestablish_complete_pattern}
    sleep           5s
#    Initial Success Message for UE Register and Reregister          ${output}

Trigger trace recording with PDU setup from AMF
    [Arguments]    ${ue_id}=1    ${tce_ip}=0.0.0.0
    wtsrunner.amf_ue_ics_param  id=1    ue=${ue_id}     object_id=1     location_reporting_reference_id=1
    ...     trace_activation=on     trace_plmn=311:489
    ...     trace_ref_id=1      trace_rec_session_ref_id=1      trace_depth=medium      ifaces_to_trace=Uu,NG-C,Xn-C    tce_ip=${tce_ip}

Start Subscriber Trace
    [Arguments]     ${ue_id}=1          ${trace_session_id}=1       ${tce_ip}=10.0.1.1:49151
    wtsrunner.ng_ue_trace_start         id=${ue_id}                 tce_ip=${tce_ip}            trace_depth=maximum
    ...             ifaces_to_trace=NG-C,Xn-C,Uu,F1-C,E1            trace_plmn=311:489         trace_rec_session_ref_id=${trace_session_id}
    ...             trace_ref_id=${trace_session_id}

Stop Subscriber Trace
    [Arguments]     ${ue_id}=1          ${trace_session_id}=1
    wtsrunner.ng_ue_trace_stop          id=${ue_id}                 trace_plmn=311:489
    ...          trace_rec_session_ref_id=${trace_session_id}       trace_ref_id=${trace_session_id}

Re-establish rrc setup UE with action
    [Arguments]             ${ue_id}=1               ${action}=invalid_crnti
    wtsrunner.ue_rrc_reestablish                     id=${ue_id}         action=${action}
    ${output}       Read WTS Output Until Pattern Matches           ${UE_register_complete_pattern}         ${Timeout_SA}
    Print Matching Lines from Output File          ${output}        ${Register_complete_pattern}
    sleep           5s
#    Initial Success Message for UE Register and Reregister          ${output}

Initial Success Message for UE Register and Reregister
    [Arguments]    ${output}
    [Documentation]    This keyword checks the Initial status message for the completion of UE Registration
    ...                And UE Re-registration in the output file for the SA variant
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Should Contain    ${output}    ${Initial_UE_message_pattern}    ignore_case=True
    Print Matching Lines from Output File    ${output}    ${Initial_UE_success_pattern}

UE Deregister should be Successful for SA
    [Arguments]    ${UE_ID}=${UE_ID}
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    wtsrunner.ue_deregister    id=${UE_ID}    ue_deregister_type=switch_off
    Read WTS Output For Pattern And Print matching Lines    ${UE_deregister_pattern}    ${Timeout_SA}
    Log                ue_deregister_is_ok

Traffic for SA should be Successful
    [Arguments]    ${traffic_dl_rate}=${Traffic_dl_rate}    ${traffic_ul_rate}=${Traffic_ul_rate_SA}
    [Documentation]    This keyword starts and Validates the Traffic for the SA variant
    ...                Modified Date: 08-Aug-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    Run Keyword If    (('${gnb_sm_hardware}' == 'ASIK') and ('${ap_sm_hardware}' == 'ASIK')) or ('${ap_sm_hardware}' == 'ASIL')
    ...    Run Keyword And Ignore Error    wtsrunner.sim_debug_log    level=4
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${duration}
    ${dataloss_validate_list}=    Create List
    ${tput_validate_list}=    Create List
    FOR   ${ueid}   IN   @{sa_ueids}
        Start Traffic For SA   ${ueid}    ${traffic_dl_rate}    ${traffic_ul_rate}    ${duration}
    END

    Sleep    ${duration}

    FOR   ${ueid}   IN   @{sa_ueids}
        ${trf_sa_status}    Run Keyword And Ignore Error    Validate Traffic Throughput Average Rate for SA
        ...    ${traffic_dl_rate}    ${traffic_ul_rate}    ${ueid}
        Stop Traffic For SA    ${ueid}
        ${status}    Run Keyword And Ignore Error    Should Be True    '${trf_sa_status[0]}' == 'PASS'
        ...    msg=Traffic failed, see error above!
        Append To List    ${tput_validate_list}    ${status[0]}
        ${trf_dataloss_status}    Run Keyword And Ignore Error    Validate Traffic Data Loss For SA    ${traffic_dl_rate}
        ...    ${traffic_ul_rate}    ${ueid}
        ${dataloss_status}    Run Keyword And Ignore Error    Should Be True    '${trf_dataloss_status[0]}' == 'PASS'
        ...    msg=Traffic failed, see error above!
        Append To List    ${dataloss_validate_list}    ${dataloss_status[0]}
    END
    List Should Not Contain Value    ${tput_validate_list}    FAIL    msg=Traffic failed in Throughput, see error above!
    List Should Not Contain Value    ${dataloss_validate_list}    FAIL    msg=Traffic failed in Data Loss, see error above!

    Run Keyword If    (('${gnb_sm_hardware}' == 'ASIK') and ('${ap_sm_hardware}' == 'ASIK')) or ('${ap_sm_hardware}' == 'ASIL')
    ...    Run Keyword And Ignore Error    wtsrunner.sim_debug_log    level=0

Traffic should be successful for SA
    [Arguments]    ${traffic_dl_rate}=${Traffic_dl_rate}    ${traffic_ul_rate}=${Traffic_ul_rate_SA}    ${UE_ID}=${UE_ID}
    [Documentation]    This keyword starts and Validates the Traffic for the SA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    ute_wts_runner.Start and Validate Traffic For SA    dl_rate=${traffic_dl_rate}    ul_rate=${traffic_ul_rate}    UE_ID=${UE_ID}
    Log    traffic_is_ok

X2AP Link Should be UP
    [Documentation]    This keyword is used to Create a X2 connection with gNB
    ...                And checks if the X2AP link with the gNB is UP in the output file.
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    wtsrunner.enb_x2_link_up    enb=${eNB_ID}    target=${eNB_target}
    Read WTS Output For Pattern And Print matching Lines    ${X2_link_pattern}    ${Timeout_NSA}
    Log    x2_is_ok

LTE Attach should be Successful for NSA
    [Arguments]    ${UE_ID}=${UE_ID_NSA}
    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    wtsrunner.ue_attach         id=${UE_ID}
    ${ue_attach_output}         Read WTS Output For Pattern And Print matching Lines    ${LTE_attach_pattern}    ${Timeout_NSA}
    Log    lte_attach_is_ok
    [Return]                    ${ue_attach_output}

UE Attach should be Successful for NSA
    [Arguments]    ${UE_ID}=${UE_ID_NSA}    ${Target_Cells}=${Target_Cells}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Target_Cells}    ue=${UE_ID}
    ...                         bearer=${Bearer_ID}    type=split_scg
    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}
    [Return]    ${match_str}

UE 5GDetach should be Successful for NSA
    [Arguments]    ${UE_ID}=${UE_ID_NSA}
    [Documentation]    This keyword is used to Detach the UE from 5G connection with gNB and checks the completion message in output file.
    ...                Enhance the keyword to detach SANSA UE as well.
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    wtsrunner.enb_ue_dc_release    ue=${UE_ID}    bearer=${Bearer_ID}    by=enb    cause=off
    Read WTS Output For Pattern And Print matching Lines    ${UE_5GDetach_pattern}    ${Timeout_NSA}
    Log          5gdetach_is_ok

UE Detach should be Successful for NSA
    [Arguments]    ${UE_ID}=${UE_ID_NSA}
    [Documentation]    This keyword is used to Detach the UE with gNB and checks the completion message in output file.
    ...                Modified Date: 31-March-2021
    ...                Last Modified by: anil.1.pachauri@nokia.com
    wtsrunner.ue_detach    id=${UE_ID}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_detach_pattern}    ${Timeout_NSA}
    Print Matching Lines from Output File    ${output}    ${UE_detach_pattern}
    Log    detach_is_ok
    Log to Console     \nDetach ----  ${match_str}

Read WTS Output For Pattern And Print matching Lines
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks if the ${pattern} is present in the output file and prints the line matching the pattern.
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    ${output}    Read WTS Output Until Pattern Matches   ${pattern}    ${timeout}
    Print Matching Lines from Output File    ${output}    ${pattern}
    [Return]    ${output}

Read WTS Output Until Pattern Matches
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks the output file until the ${pattern} matches in the file.
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=${pattern}
    ...    timeout=${timeout}
    [Return]    ${output}

Print Matching Lines from Output File
    [Arguments]    ${output}    ${pattern}
    [Documentation]    This keyword Prints the lines which contains the ${pattern} from the output file ${output}
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    ${output}        Get Lines Matching Regexp    ${output}    ${pattern}
    ...               partial_match=${TRUE}
    set suite variable      ${match_str}   ${output}
    Log to Console    \n ${output}

Get AP Suite Configuration Variables
    [Documentation]    This keyword will identify the variables related to ap_configurations
    ...                Modified Date: 14-April-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    ${var}=    Get Variable Value    ${TOPOLOGY}
    ${var_exists}=      Set Variable If    "${var}" != 'None'    ${True}    ${False}
    Run Keyword If    '${var_exists}' == 'False'
    ...   Get AP Suite Configuration From File   ELSE
    ...   Set AP Suite Configuration Variables   ${TOPOLOGY}

Get Component Carrier Variables
    ${var}=    Get Variable Value    ${COMPONENT_CARRIER}
    ${var_exists}=      Set Variable If    "${var}" != 'None'    ${True}    ${False}
    Run Keyword If    '${var_exists}' == 'False'
    ...   Get Component Carrier Value From File   ELSE
    ...   Set Component Carrier Variables    ${COMPONENT_CARRIER}

Set Variable SUITE_CFG_DIR
    [Documentation]    stream_nr and suite_cfg_dir variables depends on the loads
    ...                If SBTS load: SBTSXX_ENB_YYYY_DDDD_VVVV (standard form) where YYYY = 9999 (reserved for trunk),
    ...                YYYY = other values for branch; list_index=2 (used for identification of load).
    ...                list_index[2]=9999, then stream_nr=SBTS00 else if list_index[2]=0000/0100 then stream_nr=SBTSXX
    ...                else stream_nr will get assigned with perticular trunk or branch load.
    ${sw_version}                 admin.get_sw_version
    @{sw_version_list}=           Split String    ${sw_version}    separator=_
    ${stream_nr}=    Run Keyword if    "SBTS" in "${sw_version_list}[0]"
    ...              Set Variable if    "${sw_version_list}[2]"=="9999" or "${sw_version_list}[2]"=="9000" or "${sw_version_list}[0]"=="SBTS22R4"
    ...                                 SBTS00    ${sw_version_list}[0]
    # ...              ELSE    python_keywords.parse_sw_to_stream    ${sw_version}
    ${SUITE_CFG_DIR}              Catenate    SEPARATOR=/    ${SUITE_CFG_DIR_tmp}    ${stream_nr}
    Set Global Variable           ${SUITE_CFG_DIR}
    Set Global Variable           ${stream_nr}

Trigger SBA trace recording session via NGAP Handover Request message
    [Arguments]    ${ue_id}=1
    wtsrunner.amf_ue_ng_handover_request_param      id=${ue_id}         trace_activation=on
    ...     trace_plmn=311:489          trace_ref_id=0
    ...     trace_rec_session_ref_id=0          tce_ip=10.0.1.1          trace_depth=medium
    ...     ifaces_to_trace=Uu,NG-C,Xn-C

Trigger SBA trace recording session via NGAP Trace Start message
    [Arguments]    ${ue_id}=1    ${trace_session_id}=1    ${tce_ip}=10.0.1.1
    wtsrunner.ue_ng_trace_start      id=${ue_id}         tce_ip=${tce_ip}        trace_depth=minimum
    ...     ifaces_to_trace=Uu,NG-C,Xn-C        trace_plmn=311:489      trace_rec_session_ref_id=${trace_session_id}
    ...     trace_ref_id=${trace_session_id}

Traffic Should Be Successful For NSA
    [Documentation]    This keyword starts and Validates the Traffic for the NSA FDD variants
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    [Arguments]    ${ue_id}=${UE_ID}    ${traffic_dl_rate}=${Traffic_dl_rate}
    ...    ${traffic_ul_rate}=${Traffic_ul_rate_${duplexing}}
    ute_wts_runner.Start Traffic    UE_ID=${ue_id}    dl_rate=${traffic_dl_rate}    ul_rate=${traffic_ul_rate}
    Log    traffic_is_ok
