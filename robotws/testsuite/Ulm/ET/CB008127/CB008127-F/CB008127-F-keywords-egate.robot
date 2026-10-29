*** Settings ***
Documentation   This is a keyword file for CB008127-F part egate
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${WIRESHARK_RUNNING}     false

*** Keywords ***


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
    [Arguments]     ${ue_id}   ${pdu_id}    ${gw_id}   ${log}
    ${cmd}  set variable   ue_pdu_session_setup pdu=${pdu_id} ue=${UE_id} gw=${gw_id}
    ${check}   set variable   rrcReconfigurationComplete
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_start_pdu_ue${UE_id}_${log}.txt    ${output_egate}
    sleep     2s


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


send event A2 with srsrp_srsrq_nr
    [Documentation]    [PRIVATE]    send event A2 with srsrp_srsrq_nr
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}  ${meas_id}   ${srsrp_srsrq_nr}   ${log}
    ${cmd}  set variable
    ...   ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=${srsrp_srsrq_nr} srsrq_nr=${srsrp_srsrq_nr} srs_result=0:11:11:0
    ${check}   set variable   rrcReconfigurationComplete
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_A2_ue${UE_id}_${log}.txt    ${output_egate}
    sleep     2s


send B2
    [Documentation]    [PRIVATE]    send B2
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${meas_id}   ${nrsrp_nr}   ${nrsrq_nr}
    ${cmd1}     set variable    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=B2 srsrp_nr=11 srsrq_nr=11
    ${cmd2}     set variable    srs_result=0:11:11:0 phycell_id=11 nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr} rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd}     catenate   ${cmd1}     ${cmd2}
    ${check}     set variable   Successful handover from EXT_ENB-2.1 to ENB-4.1
    Log To Console   execute on wts: ${cmd}
    Log To Console   check on wts: "${check}"
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/B2.txt    ${output_egate}


send B2 no handover executed
    [Documentation]    [PRIVATE]    send B2 no handover executed
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${meas_id}   ${nrsrp_nr}   ${nrsrq_nr}
    ${cmd1}     set variable    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=B2 srsrp_nr=11 srsrq_nr=11
    ${cmd2}     set variable    srs_result=0:11:11:0 phycell_id=11 nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr} rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd}     catenate   ${cmd1}     ${cmd2}
    Log To Console   execute on wts: ${cmd}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/B2_noHandover.txt    ${output_egate}


trigger and check interRat handover
    [Documentation]    [PRIVATE]    trigger interRat handover
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${check}
    ${cmd}     set variable    gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=1 plmn=311:489
    Log To Console   execute on wts: ${cmd}
    Log To Console   check on wts: "${check}"
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/interRatHO.txt    ${output_egate}


display measurement config
    [Documentation]    [PRIVATE]    display measurement config from eNB
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}  ${log}=${EMPTY}
    ${cmd}     set variable    ue_meas_cfg_disp id=${ue_id}
    Log To Console   execute on wts: ${cmd}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/disp_meas_config${log}.txt    ${output_egate}


send pdu session modify
    [Documentation]    [PRIVATE]    send pdu session modify
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${qosflows_to_add}     ${check}
    ${cmd}     set variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qosflows_to_add} by=amf
    Log To Console   execute on wts: ${cmd}
    Log To Console   check on wts: "${check}"
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/pduSessionModify_qfi${qosflows_to_add}.txt    ${output_egate}


send pdu session modify del
    [Documentation]    [PRIVATE]    send pdu session modify del
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}    ${qosflows_to_del}    ${check}
    ${cmd}     set variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=${qosflows_to_del} by=amf
    ${check}   set variable    Ue ${ue_id} PduId 1 Removed FiveQi:Qfi mapping fiveQi 1 ${check}
    Log To Console   execute on wts: ${cmd}
    Log To Console   check on wts: "${check}"
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/pduSessionModify_del_qci${qosflows_to_del}.txt    ${output_egate}


additional qosflow to activate
    [Documentation]    [PRIVATE]    additional qosflow to activate
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${additional_qosflows_to_activate}
    ${cmd}     set variable    smf_param id=1 additional_qosflows_to_activate=${additional_qosflows_to_activate}
    Log To Console   execute on wts: ${cmd}
    sleep     2s
    ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate


send A1
    [Documentation]    [PRIVATE]    send A1
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${meas_id}
    ${cmd}     set variable   ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=75 srsrq_nr=75
    ${check}   set variable   rrcReconfigurationComplete
    Log To Console   execute on wts: ${cmd}
    Log To Console   check on wts: "${check}"
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/A1.txt    ${output_egate}


release PDU session
    [Documentation]    [PRIVATE]    release PDU session
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${pdu_id}
    ${cmd}     set variable   ue_pdu_session_release ue=${ue_id} pdu=${pdu_id}
    ${check}   set variable   Successfully released PDU Session with ID ${pdu_id}
    Log To Console   execute on wts: ${cmd}
    Log To Console   check on wts: "${check}"
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/release_Pdu.txt    ${output_egate}


send rrc reconf handoverFailure
    [Documentation]    [PRIVATE]    send rrc reconf handoverFailure
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd1}   set variable   ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=reestablish gnb=2 cell=1
    ${cmd2}   set variable   cause=handoverFailure crnti=source nth=1 num_reestablishment_reqs=1
    ${cmd}     catenate   ${cmd1}     ${cmd2}
    Log To Console   execute on wts: ${cmd}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate
