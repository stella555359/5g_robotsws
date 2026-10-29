*** Settings ***

Documentation        :copyright: Nokia
...                  :AUTHOR: Chaithanya H S
...                  :MAINTAINER contacts  chaithanya.h_s@nokia.com
...                  The aim of the script is to run multiple ue with multi DBR functionalities.
...                  This script includes VONR,NON-VONR,NON-VONR with high throughput,GBR and RRC Ue inactive state keywords.

*** Variable ***
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${nwslice_ID}    1
${nw_id}    1

*** Keywords ***
Register ALL Ues and Send Low data
    [Arguments]     ${Start_ue}    ${End_ue}
    ${crnti_list}     Create List
    FOR    ${ue_id}    IN RANGE    ${Start_ue}   ${End_ue}+1
    ${rnti}    wts_sim_keywords.UE Register should be Successful And Fetch RNTI    ${ue_id}
    Append to list   ${crnti_list}    ${rnti}
    wts_sim_keywords.Trigger DL Data Traffic for SA   ue_id=${ue_id}    Traffic_rate=kbps     dl_rate=15    pdu_id=1    trf_id=1
    END

Deregister Multiple Ues
    [Arguments]     ${Start_ue}    ${End_ue}
    ${crnti_list}     Create List
    FOR    ${ue_id}    IN RANGE    ${Start_ue}   ${End_ue}+1
       Wait Until Keyword Succeeds    5 min	  30 sec  Ue Deregister   ${ue_id}
    END

Ue Deregister
    [Arguments]     ${ue_id}
    ${deregister_cmd}    SET VARIABLE    ue_deregister id=${ue_id} ue_deregister_type=switch_off
    ${output}	ute_wtssim.Execute Egate Command And Wait For Data   ${deregister_cmd}    pass_regexp=UE Context Release Complete
    ... 	timeout=30s
    Should not be empty    ${output}


QosFlow addition should be Successful
   [Arguments]    ${start_ueid}    ${end_ueid}    ${qosflows_to_add}    ${qfi_ids}    ${pdu_id}=1
    FOR    ${ue_id}    IN RANGE    ${start_ueid}    ${end_ueid}+1
    Add Multiple Qos flow to Ues and send data   ${ue_id}   ${qosflows_to_add}    ${qfi_ids}    ${pdu_id}
    END

Add Multiple Qos flow to Ues and send data
    [Arguments]    ${ue_id}   ${qosflows_to_add}    ${qfi_ids}     ${pdu_id}=1
    FOR    ${qosflow}    IN    &{qosflows_to_add}
    wts_sim_keywords.UE PDU Modfication should be Successful    ${ue_id}   pdu_id=${pdu_id}   qosflows_to_add=${qosflow}[0]
    Sleep   2s
    Run Keyword If    ${qosflow}[1]==1    Run Keywords
    ...    wts_sim_keywords.Trigger VoNR DL Traffic for SA     ue_id=${ue_id}   trf_id=1   qfi_id=${qfi_ids}[${qosflow}[1]]   rtp_codec=custom
    ...    AND    wts_sim_keywords.Trigger VoNR UL Traffic for SA    ue_id=${ue_id}   trf_id=1   qfi_id=${qfi_ids}[${qosflow}[1]]   rtp_codec=custom
    ...    ELSE   Run Keywords
    ...    wts_sim_keywords.Trigger DL Traffic for SA   ue_id=${ue_id}    Traffic_rate=mbps     dl_rate=1    pdu_id=${pdu_id}
    ...    trf_id=1    qfi_id=${qfi_ids}[${qosflow}[1]]
    ...    AND    wts_sim_keywords.Trigger UL Traffic for SA   ue_id=${ue_id}    Traffic_rate=mbps     ul_rate=1    pdu_id=${pdu_id}
    ...    trf_id=1    qfi_id=${qfi_ids}[${qosflow}[1]]
    END

Set Core Network Assistance info
    [Arguments]    ${ue_idx}   ${mnc}    ${mcc}
    Log to Console     Setting Core Network Assistance Info
    ${network_core}    catenate    SEPARATOR=${SPACE}
    ...   amf_ue_ics_param id=1 ue=${ue_idx} trace_activation=on trace_plmn=${mnc}:${mcc}
    ...   trace_ref_id=1 trace_rec_session_ref_id=1 trace_depth=minimum ifaces_to_trace=NG-C tce_ip=10.0.1.1 core_network_assistance_info=on
    ...   ue_identity_index_value=1 ue_specific_drx=64 periodic_registration_update_timer=1:1min plmn_id=${mnc}:${mcc} tac_id=200
    ute_wtssim.Execute Egate Command    ${network_core}    timeout=${EGATE_COMMAND_TIMEOUT}

Ue RRC Inactive state should be successful
    [Arguments]   ${start_ue_rrcinac}    ${end_ue_rrcinac}    ${mnc}=310    ${mcc}=260
    MultiUE Register should be Successful with CNAI and wait to Inactive state     ${start_ue_rrcinac}    ${end_ue_rrcinac}     mnc=${mnc}
	...    mcc=${mcc}

Start Multi UE DL traffic with multiple trafficID
    [Arguments]   ${start_ue}   ${end_ue}    ${Traffic_rate}    ${dl_trf_id}    ${qfi_id}    ${dl_rate_DL}
    FOR   ${TRF_ID}  IN RANGE   1    ${dl_trf_id}+1
        wts_sim_keywords.MultiUE Trigger DL Traffic for SA    ${start_ue}    ${end_ue}    ${Traffic_rate}     ${dl_rate_DL}    pdu_id=1
        ...    trf_id=${TRF_ID}    qfi_id=${qfi_id}
    END

Start Multi UE UL traffic with multiple trafficID
    [Arguments]   ${start_ue}   ${end_ue}   ${Traffic_rate}   ${ul_trf_id}    ${qfi_id}    ${ul_rate_UL}
    FOR   ${TRF_ID}  IN RANGE   1    ${ul_trf_id}+1
        wts_sim_keywords.MultiUE Trigger UL Traffic for SA    ${start_ue}   ${end_ue}    ${Traffic_rate}    ${ul_rate_UL}    pdu_id=1
        ...    trf_id=${TRF_ID}    qfi_id=${qfi_id}
    END

MultiUE Register should be Successful with CNAI and wait to Inactive state
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${mnc}    ${mcc}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Set Core Network Assistance info    ${ue_idx}    ${mnc}    ${mcc}
    ${ue_reg_cmd}	SET VARIABLE	ue_register id=${ue_idx}
	${output}		ute_wtssim.Execute Egate Command And Wait For Data  ${ue_reg_cmd}   pass_regexp=${UE_reg_complete_pattern}
    ...      timeout=${EGATE_COMMAND_TIMEOUT}
	Create File     ${OUTPUT_DIR}/regst.txt     ${output}
	${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
	BuiltIn.Log     ${crnti_value}
	Log to Console             ue${ue_idx}_register_is_ok with ${crnti_value}
	Append To List  ${crnti_list}   ${crnti_value}
	${set_pdu_param_cmd}	SET VARIABLE	set_pdu_param ue=${ue_idx} pdu=1 trf_type=internal
    ${pdu_setup_cmd}	SET VARIABLE	ue_pdu_session_setup pdu=1 ue=${ue_idx} nwslice=${nw_id} gw=${ue_idx}
	ute_wtssim.Execute Egate Command    ${set_pdu_param_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
	ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd}
	...		pass_regexp=.*Is INACTIVE       timeout=300
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_value} is regtd ,pdu=1 created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}

