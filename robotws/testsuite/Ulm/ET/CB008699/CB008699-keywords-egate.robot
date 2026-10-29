*** Settings ***
Documentation   This is a keyword file for CB008699 part egate
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${WIRESHARK_RUNNING}     false

*** Keywords ***

set sib period for gnb3
    [Documentation]    [PRIVATE]    set sib period for gnb3
    ...       :Autor: Sylvia Schneider
    FOR   ${sib}   IN   sib1   sib2   sib3
       ${cmd}   set variable   gnb_param id=3 ${sib}_period=40
       Log To Console    execute on wts: ${cmd}
       ute_wtssim.execute egate command    cmd=${cmd}    alias=ap_egate
       sleep     1s
    END


check wts in active state
    [Documentation]    [PRIVATE]    check that wts is in state active
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncheck if wts in active state
    Wait Until Keyword Succeeds    5 min    20 sec    check wts state
    Log To Console    check if wts in active state ended


check wts state
    [Documentation]    [PRIVATE]    check that wts is in state active
    ...       :Autor: Sylvia Schneider
    ute_wtssim.execute egate command and wait for data
    ...    cmd=sim_state_disp
    ...    pass_regexp=The state is ACTIVE   alias=ap_egate


ue change location
    [Documentation]    [PRIVATE]    ue change location
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1   ${cell}=1

    ${cmd}   set variable   ue_change_location id=${ue_id} enb=3 cell=${cell}
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command    cmd=${cmd}    alias=ap_egate


set traffic type in egate
    [Documentation]    [PRIVATE]    set traffic type in egate
    ...       :Autor: Sylvia Schneider
    Set traffic type                   ue_id=1    pdu_id=1    trf_type=internal


register UE
    [Documentation]    [PRIVATE]    register UE
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    Log To Console    execute on wts: ue_register id=${UE_id} nwslice=all
    Log To Console    check on wts: "REGISTRATION COMPLETE from UE"
    sleep     2s
    ute_wtssim.execute egate command and wait for data    cmd=ue_register id=${UE_id} nwslice=all
    ...    return_output=True
    ...    pass_regexp=REGISTRATION COMPLETE from UE
    ...    alias=ap_egate


start PDU session
    [Documentation]    [PRIVATE]    start PDU
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1
    ${cmd}  set variable   ue_pdu_session_setup pdu=1 ue=${UE_id} gw=${UE_id}
    ${check}   set variable   Pdu Session Resource Setup Response Message with RAN UE NGAP ID [0-9]* handled successfully
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     2s
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate


start PDU session FR2
    [Documentation]    [PRIVATE]    start PDU
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1
    ${cmd}  set variable   ue_pdu_session_setup pdu=1 ue=${UE_id} gw=${UE_id}
    ${check}   set variable   rrcReconfigurationComplete
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_pdu_setup_UE${ue_id}.txt    ${output_egate}


modify PDU session
    [Documentation]    [PRIVATE]    modify PDU
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1    ${qosflows_to_add}=4
    ${cmd}  set variable   ue_pdu_session_modify ue=${UE_id} pdu=1 qosflows_to_add=${qosflows_to_add} by=amf
    ${check}   set variable   Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     2s
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate


release UE
    [Documentation]    [PRIVATE]    stop PDU, deregister UE
    ...       :Autor: Sylvia Schneider
    FOR   ${id}  IN   @{UE}
      run keyword and ignore error    UE PDU Session Release   ue_id=${id}   pdu=1
      run keyword and ignore error    UE Deregister            ue_id=${id}
    END


start UDP traffic and get bearer statistics
    [Documentation]    [PRIVATE]    start UDP traffic and get bearer statistics
    ...       :Autor: Sylvia Schneider
    FOR   ${dir}  ${mbps}  ${qfi}  IN
    ...   dl      5        1
    ...   ul      5        1
        Log To Console    start ${dir} traffic for ue1 with mbps=${mbps} qfi=${qfi}
        Start data traffic in egate
        ...    ue_id=1    direction=${dir}    protocol=udp    ack_mode=off    trf_id=1   cl_trf_stats=on    mbps=${mbps}   pdu=1   qfi=${qfi}
    END
    get bearer statistics    run=after_pdu_setup   delay=10s


start UDP traffic and get bearer statistics t4
    [Documentation]    [PRIVATE]    start UDP traffic and get bearer statistics t4
    ...       :Autor: Sylvia Schneider
    FOR   ${dir}  ${mbps}  ${qfi}  IN
    ...   dl      5        1
    ...   ul      5        1
    ...   dl      10       2
    ...   ul      10       2
        Log To Console    start ${dir} traffic for ue1 with mbps=${mbps} qfi=${qfi}
        Start data traffic in egate
        ...    ue_id=1    direction=${dir}    protocol=udp    ack_mode=off    trf_id=1   cl_trf_stats=on    mbps=${mbps}   pdu=1   qfi=${qfi}
    END
    get bearer statistics t4   run=after_pdu_setup   delay=10s


get bearer statistics
    [Documentation]    [PRIVATE]    get bearer statistics for uplink and downlink traffic
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${run}  ${delay}
    sleep     ${delay}
    get bearer statistics in one direction      ue_id=1       direction=dl    qfi=1     run=${run}
    get bearer statistics in one direction      ue_id=1       direction=ul    qfi=1     run=${run}

get bearer statistics t4
    [Documentation]    [PRIVATE]    get bearer statistics for uplink and downlink traffic t4
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${run}  ${delay}
    sleep     ${delay}
    get bearer statistics in one direction      ue_id=1       direction=dl    qfi=1     run=${run}
    get bearer statistics in one direction      ue_id=1       direction=ul    qfi=1     run=${run}
    get bearer statistics in one direction      ue_id=1       direction=dl    qfi=2     run=${run}
    get bearer statistics in one direction      ue_id=1       direction=ul    qfi=2     run=${run}


get bearer statistics in one direction
    [Documentation]    [PRIVATE]    get bearer statistics in one direction
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}    ${direction}   ${qfi}     ${run}
    ${wts_cmd}  set variable
    ...      bearer_stats ue=${ue_id} dir=${direction} type=l3 scell=0 format=short size_unit=auto trf_id=1 pdu=1 qfi=${qfi}

    Log To Console    execute on wts: ${wts_cmd}
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${wts_cmd}
    ...    return_output=True
    ...    alias=ap_egate
    sleep     2s   wait for all data sent
    Create File    ${resultDir}/egate_${direction}_ue${ue_id}_qfi${qfi}_${run}.txt    ${output_egate}


set ue history
    [Documentation]    [PRIVATE]    set ue history
    ...       :Autor: Sylvia Schneider
    ${cmd}   set variable   ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=medium nrcgi=311:489|0x03 time_ue_stayed_in_cell=100
    Log To Console
    ...    execute on wts: ${cmd}
    ute_wtssim.execute egate command    cmd=${cmd}    alias=ap_egate
    sleep     2s

    ${cmd}   set variable   ue_history_information_list id=1 action=commit
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=UE History List: 1 was committed    alias=ap_egate
    sleep     2s

    ${cmd}   set variable   ue_enb_param id=1 ue_history_list=1
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command    cmd=${cmd}    alias=ap_egate
    sleep     2s


set ue enb param with ue history list for additional UEs
    FOR   ${ue_id}    IN   2   3   4
       ${cmd}   set variable   ue_enb_param id=${ue_id} ue_history_list=1
       Log To Console    execute on wts: ${cmd}
       ute_wtssim.execute egate command    cmd=${cmd}    alias=ap_egate
       sleep     2s
    END


send XN handover preparation
    [Documentation]    [PRIVATE]    send XN handover preparation
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${action}
    ${action_mod_excl}     set variable  action=modify_drb_qos_mapping drb_qos_map_modification=exclude_mapping pdu_sessions=1
    ${action_add_nonCrit}  set variable  action=add_unsupported_extensions unsupported_extension_type=late_non_crit_extn_rrcreconfig
    ${action_add_Crit}     set variable  action=add_unsupported_extensions unsupported_extension_type=critical_extn_futr_rrcreconfig
    ${action_mod_incomp}   set variable  action=modify_drb_qos_mapping drb_qos_map_modification=incompatible_mapping pdu_sessions=1
    ${action_excl_forw}    set variable  action=modify_drb_qos_mapping exclude_dataforwardinginfofromSource=on pdu_sessions=1
    ${cmd2}   IF   '${action}'=='modify_drb_qos_exclude_mapping'              Set Variable  ${action_mod_excl}
    ...   ELSE IF  '${action}'=='add_unsupported_extensions_nonCritical'      Set Variable  ${action_add_nonCrit}
    ...   ELSE IF  '${action}'=='add_unsupported_extensions_Critical'         Set Variable  ${action_add_Crit}
    ...   ELSE IF  '${action}'=='modify_drb_qos_incompatible_mapping'         Set Variable  ${action_mod_incomp}
    ...   ELSE IF  '${action}'=='modify_drb_qos_exclude_DataForward'          Set Variable  ${action_excl_forw}
    ...   ELSE     Fail   XN handover preparation - unsupported action
    ${cmd}  set variable    gnb_xn_handover_preparation_param id=3 ${cmd2}
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command    cmd=${cmd}    alias=ap_egate


send A3 measurement and save egate log
    [Documentation]    [PRIVATE]    send A3 measurement
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${result}    ${log_id}

    ${pass_fail}  set variable   Unsuccessful outcome for XnAP::HandoverPreparation is received. Handover canceled
    ${pass_succ1}  set variable   Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    ${pass_succ2}  set variable   Inter-eNB handover from ENB-3.2 to EXT_ENB-2.1 performed
    ${pass_regexp}   IF  '${result}'=='handover cancel'                Set Variable  ${pass_fail}
    ...         ELSE IF  '${result}'=='handover successful ENB-3.1'    Set Variable  ${pass_succ1}
    ...         ELSE                                                   Set Variable  ${pass_succ2}
    ${cmd}   set variable   ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=19 phycell_id=50 nrsrp_nr=100
    Log To Console    execute on wts: ${cmd} and check ${pass_regexp}
    ${output_egate}      ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${pass_regexp}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_HO_log${log_id}.txt    ${output_egate}


send A3 measurement for UE${ue_id} in cell${cell_id} and save egate log
    [Documentation]    [PRIVATE]    send A3 measurement
    ...       :Autor: Sylvia Schneider
    ${pass}  set variable   UE${ue_id}: Inter-eNB handover from ENB-3.${cell_id} to EXT_ENB-2.1 performed
    ${cmd}   set variable   ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=19 phycell_id=50 nrsrp_nr=100
    Log To Console    execute on wts: ${cmd} and check ${pass}
    ${output_egate}      ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${pass}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_HO_UE${ue_id}.txt    ${output_egate}


trigger handover with A3 measurement to phycell_id 48
    [Documentation]    [PRIVATE]    trigger handover with A3 measurement to phycell_id 48
    ...       :Autor: Sylvia Schneider
    ${pass}  set variable   Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    ${cmd}   set variable   ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=19 phycell_id=48 nrsrp_nr=90
    Log To Console    execute on wts: ${cmd} and check ${pass}
    ${output_egate}      ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${pass}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_HO_UE1.txt    ${output_egate}


trigger handover with A3 measurement to phycell_id 50
    [Documentation]    [PRIVATE]    trigger handover with A3 measurement to phycell_id 50
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${check}   ${log}
    ${cmd}   set variable   ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=19 phycell_id=50 nrsrp_nr=90
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    ${output_egate}      ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_HO_UE1_cell50_${log}.txt    ${output_egate}


reset bearer statistics
    [Documentation]    [PRIVATE]    reset bearer statistics
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1
    ${wts_cmd}  set variable   qfi_stats_clear ue=${ue_id} pdu=1
    Log To Console    execute on wts: ${wts_cmd}
    sleep     2s
    ute_wtssim.execute egate command    cmd=${wts_cmd}    alias=ap_egate


stop UDP traffic
    [Documentation]    [PRIVATE]    stop UDP traffic
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1    ${pdu}=1
     Log To Console    stop uplink and downlink traffic for ue ${ue_id}
     Stop data traffic in egate    ue_id=${ue_id}    direction=bi    trf_id=1    pdu=${pdu}


deregister UE
    [Documentation]    [PRIVATE]    deregister UE
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1
    Log To Console    execute on wts: ue_deregister id=${ue_id} ue_deregister_type=switch_off
    sleep     2s
    ute_wtssim.execute egate command    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
    ...    alias=ap_egate


verify egate log contains fullConfig true in egate_log_HO_log${log_id}
    [Documentation]    [PRIVATE]    egate log contains fullConfig true
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncheck that in egate log "fullConfig true" is contained
    ${contents}    Get File           ${resultDir}/egate_log_HO_log${log_id}.txt
    Run Keyword and Continue on Failure    Should Contain           ${contents}         fullConfig true


set indexToRFSP
    [Documentation]    [PRIVATE]    set indexToRFSP
    ...       :Autor: Sylvia Schneider
    ${cmd}  set variable   amf_ue_ics_param id=1 indexToRFSP=90
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command    cmd=${cmd}    alias=ap_egate


display measurements of UE
    [Documentation]    [PRIVATE]    display measurements of UE
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}  ${log}=${EMPTY}
    ${cmd}     set variable    ue_meas_disp id=${ue_id}
    Log To Console   execute on wts: ${cmd}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/disp_meas_UE${ue_id}${log}.txt    ${output_egate}


verify egate log CB008699 t6
    [Documentation]    [PRIVATE]    egate log CB008699 t6
    ...       :Autor: Sylvia Schneider

    Log To Console    \ncheck that in egate log of UE1 "fullConfig true" is not contained
    ${contents}    Get File           ${resultDir}/egate_log_HO_UE1.txt
    Run Keyword and Continue on Failure    Should Not Contain           ${contents}         fullConfig true

    Log To Console    \ncheck that in egate log of UE2 "fullConfig true" is contained
    ${contents}    Get File           ${resultDir}/egate_log_HO_UE2.txt
    Run Keyword and Continue on Failure    Should Contain           ${contents}         fullConfig true

    Log To Console    \ncheck that in egate log of UE3 "fullConfig true" is contained
    ${contents}    Get File           ${resultDir}/egate_log_HO_UE3.txt
    Run Keyword and Continue on Failure    Should Contain           ${contents}         fullConfig true

    Log To Console    \ncheck that in egate log of UE4 "fullConfig true" is not contained
    ${contents}    Get File           ${resultDir}/egate_log_HO_UE4.txt
    Run Keyword and Continue on Failure    Should Not Contain           ${contents}         fullConfig true
