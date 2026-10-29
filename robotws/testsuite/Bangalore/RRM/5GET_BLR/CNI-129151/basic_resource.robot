*** Settings ***

Documentation    :copyright: Nokia
...              :authors: Prerana N S
...              :contact: prerana.n_s@nokia.com

Variables    ta5g_global_var
Resource          ./../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser

Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Library        ../resources/NPS/SWENG/python_libs/luashark_tools.py
Resource       ../resources/NPS/SWENG/robot/PacketSearch.robot
Resource       ../resources/robot/Setup_Env.robot
Resource       ../resources/robot/common_log_collection.robot
#Resource        ../resources/ECEcommon/common_file_operation.robot
Resource         ../resources/ECEcommon/common_setup_teardown.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Library        luashark_tools.analyzer       WITH NAME       analyzer
Library        ute_admin                         WITH NAME   ute_adm
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Library        taf.transport.ssh                 WITH NAME    csn
Library           XML    use_lxml=True    WITH NAME    Myxml
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library         ./python/basic.py



#*** Variables ***


*** Keywords ***

Verify Packets
    [Arguments]    ${log_path}     ${packet}    ${mcsTable}
    ${pdmlFile}    analyzer.pcap_to_pdml      ${log_path}/NODECPRT_GNB.pcap       ${packet}

    ${var}      analyzer.get_shownames            pdmlFile=${pdmlFile}
    ...                                        packetName=${packet}
    ...                                        path=${mcsTable}
#    ...                                        endPacket=1
    ${count}    analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=${packet}
    ...                                                pkt_count=${1}

    Should Contain    '${count}'      6
    Should Contain X Times    ${var}     radioNetwork: failure-in-radio-interface-procedure (24)          ${6}

verify pduSessionNotify message
    [Arguments]    ${cprt_log}

    ${pdmlFile}          analyzer.pcap_to_pdml    ${cprt_log}         ngap.PDUSessionResourceNotifyReleasedTransfer_element
    ${fail_cause_code}    analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                        packetName=ngap.PDUSessionResourceNotifyReleasedTransfer_element
    ...                                        path=.*radioNetwork$
    ...                                        endPacket=1
    Should BE Equal    ${fail_cause_code}   24

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Validate PM Counters_pcell_scell
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
#    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
#    ...  pi_id=${PM_counter}    moc=${moc}
    Get Total value of counter and compare   ${PM_dir}   ${PM_counter}   ${expected_value}
    Log to Console    ${moc}

Verify Counters
    [Arguments]  ${counters}
     ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
     ${counter_ids}=   Get Dictionary Keys    ${counters}
     FOR   ${counter_id}  IN  @{counter_ids}
        ${e_value} =	Get From Dictionary	${counters}    ${counter_id}
        Validate PM Counters_pcell_scell   ${PM_dir_1}   ${counter_id}  ${e_value}   NRCELL-1
     END

Get Total value of counter and compare
    [Arguments]   ${pm_files_location}     ${pi_id}    ${expected_value}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=PM*
    ${rc}       get_total_cmp      ${PM_report_dict_list}     ${expected_value}
    #Should Contain  ${rc}  PASS

#Get Total value of counter and compare
#    [Documentation]   :Author: Giangiacomo Guglielmini
#    ...        get the value of a counter in the last reporting period
#    ...
#    ...        :param pm_files_location is the path to PM files
#    ...        :param pi_id is the PM counter ID e.g. M55112C03001
#    ...        :param moc is the class including the counter e.g. NRCELL-1
#    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
#    [Arguments]    ${pm_files_location}   ${pi_id}    ${moc}    ${interval}
#    ${pi_list}=  Create List
#    ...  ${pi_id}
#    ${PM_report_dict_list}=  check_pm.get_pi_value
#    ...  pi_list=${pi_list}
#    ...  pi_dir=${pm_files_location}
#    ...  pi_file_pattern=PM*
#    ${last_report}    Get From List   ${PM_report_dict_list}     ${interval}
#    ${pi_dict}   Get Dictionary Values   ${last_report}
#    ${first_pi}    Get From List   ${pi_dict}     0
#    ${cell_dict_list}   Get Dictionary Values   ${first_pi}
#    ${cell_dict}   Get From List   ${cell_dict_list}     0
#    ${moc_list}   get dictionary keys   ${cell_dict}
#    ${full_moc}    Set Variable     empty
#    FOR  ${key}  IN   @{moc_list}
#       ${key_is_moc}  Run Keyword And Return Status    Should Contain  ${key}   ${moc}
#       ${full_moc}  Set Variable If   ${key_is_moc}   ${key}    ${full_moc}
#    END
#    ${pi_value}     Get From Dictionary      ${cell_dict}    ${full_moc}
#    BuiltIn.Log    ${pi_id} value: ${pi_value}   console=${P_console}
#    [Return]    ${pi_value}
#
#
#
#
#
#Validate PM Counters_pcell_scell
#    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
##    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
##    ...  pi_id=${PM_counter}    moc=${moc}
#    ${val}    Get Total value of counter and compare   ${PM_dir}   ${PM_counter}   ${expected_value}    ${moc}
#    [Return]    ${val}
Paging commands
    [Arguments]     ${start_ue_id}    ${end_ue_id}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.amf_paging_param  default_drx=128     id=1
    wtsrunner.amf_paging_start  id=1    ueid=${ue_idx}
    END

UE PDU session release
    [Arguments]     ${start_ue_id}    ${end_ue_id}      ${PDU2}     ${PDU3}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
	Log to console    ${ue_idx}
	    FOR     ${pdux}     IN RANGE   ${PDU2}     ${PDU3}+1
            wtsrunner.ue_pdu_session_release    ue=${ue_idx}    pdu=${pdux}   by=ue   release_local=true
        END
    END

Add Multi PDU Session
    [Arguments]   ${start_ue_id}     ${end_ue_id}    ${pdu_id}      ${nw_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${pdu_id}
    Read WTS Output For Pattern And Print matching Lines    ${setup/reestablishment complete}    ${Timeout_SA}
    END

PDU Modfication to add additional qfi
     [Arguments]          ${start_ue_id}     ${end_ue_id}      ${pdu_id}=1     ${qosflows_to_add}=1
     FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
     wtsrunner.ue_pdu_session_modify      ue=${ue_idx}       pdu=${pdu_id}    qosflows_to_add=${qosflows_to_add}
     ...             by=amf
     Sleep      2s
     END

Trigger RLF due to HARQ
    [Arguments]          ${start_ue_id}     ${end_ue_id}      ${prof}=1         ${num_stop_csi_report}=2000     ${num_stop_dlharq_tx}=3000
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    wtsrunner.rlf_testmode_nr    profile_id=${prof}        num_stop_csi_report=2000    num_stop_dlharq_tx=3000
    wtsrunner.ue_testmode_set_nr       id=${ue_idx}       profile_id=${prof}       testmode=rlf      action=activate
    END
    Log to Console     ${num_stop_csi_report}
    Log to Console   ${num_stop_dlharq_tx}
MultiUE Register should be Successful with lcid
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    ${lcid_list}        Create List
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/regst.txt	    ${output}
#    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk '{print $9}'
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
    Append To List  ${crnti_list}   ${crnti_string}
    BuiltIn.Log     ${crnti_string}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}
    ${output2}     Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/session.txt	    ${output2}
    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    ${lcid}      Run     cat ${OUTPUT_DIR}/session.txt |grep -i logicalChannelIdentity |awk -F 'logicalChannelIdentity' '{print $2}'|cut -d ' ' -f 2
    Append To List     ${lcid_list}    ${lcid}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}      ${lcid_list}

Add multiple PDU session with lcid
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}
    ${output2}     Read WTS Output For Pattern And Print matching Lines    PDU SESSION ID-${pdu_id} setup/reestablishment complete.    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/session.txt	    ${output2}
    END
    ${lcid_list}        Create List
    ${lcid}     Run     cat ${OUTPUT_DIR}/session.txt |grep -i logicalChannelIdentity |awk -F 'logicalChannelIdentity' '{print $2}'|cut -d ' ' -f 2
    Append To List     ${lcid_list}    ${lcid}
    [Return]      ${lcid_list}

Inject RLC max retransmission Error
    [Arguments]   ${start_ue_id}    ${end_ue_id}    ${pdu_profile}    ${lcid}
        FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
        ${dl_rlc_drop}      Set Variable    dlrlcdrop_testmode_nr    profile_id=${pdu_profile}   lcid=${lcid}
        ...  sn=1     num_of_times_to_drop=30
        sleep   1s
        ${ue_test_mode_dl_rlc_drop}      Set Variable     ue_testmode_set_nr    id=${ue_idx}    profile_id=${pdu_profile}
        ...  testmode=dlrlcdrop     action=activate
        sleep   1s
        ute_wtssim.Execute Egate Command And Wait For Data    ${pdu_error}
        ...    pass_regexp=Successfully released PDU Session with ID ${pdu_profile}      timeout=60
        sleep   3s
        END

Trigger RLC max retransmission error
     [Arguments]          ${start_ue_id}     ${end_ue_id}      ${prof}=1         ${lcid}=4     ${sn}=1
     FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
#     wtsrunner.dlrlcdrop_testmode_nr      profile_id=${prof}        lcid=${lcid}        sn=${sn}        num_of_times_to_drop=32
     wtsrunner.dlrlcdrop_testmode_nr      profile_id=${prof}        lcid=${lcid}        sn=${sn}        num_of_times_to_drop=17
     wtsrunner.ue_testmode_set_nr       id=${ue_idx}       profile_id=${prof}       testmode=dlrlcdrop      action=activate
     END

Check MultiUE UE State Display
    [Arguments]     ${start_ue_id}    ${end_ue_id}		${state}=${EMPTY}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_disp     id=${ue_idx}
    ${output}   wtsrunner.read_wtsemu_output_until_re        expected=opc_key    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    ${state}    partial_match=${TRUE}
    Log to Console    ${output}
    Should Contain    ${output}   ${state}
    Log to Console    UE: ${ue_idx} moved to ${state} state
    END

Deactivate CNI129151
    [Arguments]        ${paramDstName}=MRBTS-1/NRBTS-1        ${operation}=update
    log to console   deactivating feature now...
    ${nidd_param}=      Create Dictionary      actSeparatePduRelForRlcError=false
    FOR    ${key}   IN    @{nidd_param}
    Modify NIDD parameters        ${key}     ${nidd_param.${key}}     ${operation}    ${paramDstName}
    END
    sleep     60s

Activate CNI129151
    [Arguments]        ${paramDstName}=MRBTS-1/NRBTS-1        ${operation}=update
    log to console   activating feature now...
    ${nidd_param}=      Create Dictionary      actSeparatePduRelForRlcError=true
    FOR    ${key}   IN    @{nidd_param}
    Modify NIDD parameters        ${key}     ${nidd_param.${key}}     ${operation}    ${paramDstName}
    END
    sleep     60s

Modify NIDD parameters
    [Documentation]      This Keyword modify NIDD parameter as per the requirement of the feature
    [Arguments]      ${paramName}='None'      ${paramValue}='None'       ${operation}=update      ${paramDst}='None'
    Log to Console      Modifying NIDD parameters
    admin.Setup admin
    Online NIDD parameter change    paramName=${paramName}         paramValue=${paramValue}        operation=${operation}
    ...                             paramDst=${paramDst}
    sleep               3s
    [Teardown]          admin.Teardown admin

Online NIDD parameter change
     [Documentation]    This Keyword used to update NIDD parameter(one at a time)
     ...                and returns the result
     ...        [Arguments]    parameter        :  Parameter names to parsed
     ...                       paramDst         :  Dist name should be parsed
     ...                       paramValue       :  Value for the parameter to be assigned should be parsed
     ...                       operation        :  Deffault Value given as update, and can be parsed other operation if required
     ...                       should_activate  :  Deffault Value is True if you want to set this False then parse the parameter as False
     ...                       skip_parameter_relation_errors : Default Value is True if you want to set this False
     ...                       then parse the parameter as False
     [Arguments]        ${paramName}='None'                 ${paramValue}='None'              ${timeout}=300
     ...                ${paramDst}='None'                  ${operation}=update
     ...                ${should_activate}=${True}          ${skip_parameter_relation_errors}=${True}
    admin.perform_parameter_recommissioning          parameter=${paramName}
     ...        value=${paramValue}             operation=${operation}                         dist_name=${paramDst}
     ...        skip_parameter_relation_errors=${skip_parameter_relation_errors}
     ...        should_activate=${should_activate}
     Log to Console    ${timeout}
