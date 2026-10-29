*** Settings ***
Documentation   This is a keyword file for CB008127 part egate
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${WIRESHARK_RUNNING}     false

*** Keywords ***


Update Gscn In Iphy File
    [Documentation]    [PRIVATE]    update gscn in iphy file
    ...       :Autor: Sylvia Schneider
    Log To Console    setting GSCN for cell2 to value 7995 in /ffs/run/simmode/new_iphy.xml
    ${ACU_alias}    Connect To Airphone Common Unit
    ssh.Execute    cp /ffs/run/simmode/new_iphy.xml /ffs/run/simmode/new_iphy_orig.xml    connection=${ACU_alias}
    ssh.Download File    /rom/simmode/new_iphy.xml    ${resultBaseDir}/new_iphy.xml    connection=${ACU_alias}
    ${contents}    Get File    ${resultBaseDir}/new_iphy.xml
    ${all_parts}    Split String      ${contents}     </RE>
    ${upd1}    Replace String Using Regexp          ${all_parts}[1]         GSCN>.*<\/GSCN>   GSCN>7995<\/GSCN>
    ${new contents}      Catenate         SEPARATOR=</RE>   ${all_parts}[0]            ${upd1}
    ${new contents}      Catenate         SEPARATOR=</RE>   ${new contents}    ${all_parts}[2]
    ${new contents}      Catenate         SEPARATOR=</RE>   ${new contents}    ${all_parts}[3]
    ${new contents}      Catenate         SEPARATOR=</RE>   ${new contents}    ${all_parts}[4]
    Create File    ${resultBaseDir}/new_iphy_upd.xml    ${new contents}
    ssh.Upload File       ${resultBaseDir}/new_iphy_upd.xml    /rom/simmode/new_iphy.xml   connection=${ACU_alias}


Check Wts In Active State
    [Documentation]    [PRIVATE]    check that wts is in state active
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncheck if wts in active state
    Wait Until Keyword Succeeds    5 min    20 sec    Check Wts State
    Log To Console    check if wts in active state ended


Check Wts State
    [Documentation]    [PRIVATE]    check that wts is in state active
    ...       :Autor: Sylvia Schneider
    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=sim_state_disp
    ...    pass_regexp=The state is ACTIVE   alias=ap_egate


Register UE
    [Documentation]    [PRIVATE]    register UE
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    Log To Console    execute on wts: ue_register id=${UE_id} nwslice=all
    Log To Console    check on wts: "REGISTRATION COMPLETE from UE"
    Sleep     2s
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_register id=${UE_id} nwslice=all
    ...    return_output=True
    ...    pass_regexp=REGISTRATION COMPLETE from UE
    ...    alias=ap_egate


Start PDU Session
    [Documentation]    [PRIVATE]    start PDU
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd}  Set Variable   ue_pdu_session_setup pdu=1 ue=${UE_id} gw=${UE_id}
    ${check}   Set Variable   rrcReconfigurationComplete
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_start_pdu_ue${UE_id}.txt    ${output_egate}
    Sleep     2s


Start PDU Session With Slice
    [Documentation]    [PRIVATE]    start PDU
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}     ${gw_id}   ${nwslice_id}   ${log}
    ${cmd}  Set Variable   ue_pdu_session_setup pdu=1 ue=${UE_id} gw=${gw_id} nwslice=${nwslice_id}
    ${check}   Set Variable   rrcReconfigurationComplete
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_start_pdu_ue${UE_id}${log}.txt    ${output_egate}
    Sleep     2s

Start 2nd PDU Session With Slice
    [Documentation]    [PRIVATE]    start PDU
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${gw_id}   ${nwslice_id}
    ${cmd}  Set Variable   ue_pdu_session_setup pdu=2 ue=${UE_id} gw=${gw_id} nwslice=${nwslice_id}
    ${check}   Set Variable   rrcReconfigurationComplete
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_start_pdu2_ue${UE_id}.txt    ${output_egate}
    Sleep     2s


Send Event A2 With Srsrp Srsrq Nr
    [Documentation]    [PRIVATE]    send event A2 with srsrp_srsrq_nr
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}  ${meas_id}   ${srsrp_srsrq_nr}
    ${cmd}  Set Variable
    ...   ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=${srsrp_srsrq_nr} srsrq_nr=${srsrp_srsrq_nr} srs_result=0:11:11:0
    ${check}   Set Variable   rrcReconfigurationComplete
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_A2_ue${UE_id}.txt    ${output_egate}
    Sleep     2s


Send Event A2 With Srsrp Srsrq Nr For Redirect Successful
    [Documentation]    [PRIVATE]    send event A2 with srsrp_srsrq_nr for redirect
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${srsrq_nr}    ${ue_id}
    ${index}   Evaluate   ${ue_id}-1
    ${value}  Set Variable   ${a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[${index}]
    ${cmd}  Set Variable
    ...   ue_measurement_send_nr id=${ue_id} meas_id=2 event=A2 srsrp_nr=${value} srsrq_nr=${srsrq_nr} srs_result=0:11:11:0
    ${check}   Set Variable   UE9: Location changed to eNB-3 cell 1
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_A2_ue${UE_id}.txt    ${output_egate}
    Sleep     2s


Save Egate Log From A2 Event
    [Documentation]    [PRIVATE]    save egate_log from A2 event
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${log_instance}
    Log To Console   move file ${resultDir}/egate_log_A2_ue${ue_id}.txt  to ${resultDir}/egate_log_A2_ue${ue_id}_${log_instance}.txt
    Move File    ${resultDir}/egate_log_A2_ue${ue_id}.txt     ${resultDir}/egate_log_A2_ue${ue_id}_${log_instance}.txt


Send Event A2 With Srsrp Srsrq Nr For Redirect Not Successful
    [Documentation]    [PRIVATE]    send event A2 with srsrp_srsrq_nr for redirect not successful
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${srsrq_nr}    ${ue_id}
    ${index}   Evaluate   ${ue_id}-1
    ${value}  Set Variable   ${a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[${index}]
    ${cmd}  Set Variable
    ...   ue_measurement_send_nr id=${ue_id} meas_id=2 event=A2 srsrp_nr=${value} srsrq_nr=${srsrq_nr} srs_result=0:11:11:0
    Log To Console    execute on wts: ${cmd}
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_A2_no_redirect_ue${UE_id}.txt    ${output_egate}
    Sleep     2s


Release UE
    [Documentation]    [PRIVATE]    stop PDU, deregister UE
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    Log To Console    release pdu session and deregister UE${ue_id}
    Run Keyword And Ignore Error    UE PDU Session Release   ue_id=${ue_id}   pdu=1
    Run Keyword And Ignore Error    UE Deregister            ue_id=${ue_id}


Register UE Start Pdu Send A2 Deregister For UE2 Upto UE9
    [Documentation]    [PRIVATE]    register UE, start pdu, send A2, deregister for UE2 upto UE9
    ...       :Autor: Sylvia Schneider
    FOR     ${id}  IN   2  3  4  5  6  7  8  9
       Register UE Start Pdu Send A2 Deregister   ue_id=${id}
    END


Register UE Start Pdu Send A2 Deregister
    [Documentation]    [PRIVATE]    register UE, start pdu, send A2, deregister
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}

    Start Wireshark Trace
    Register UE          ue_id=${ue_id}
    Start PDU Session    ue_id=${ue_id}
    ${index}   Evaluate   ${ue_id}-1
    Send Event A2 With Srsrp Srsrq Nr    ue_id=${ue_id}  meas_id=1    srsrp_srsrq_nr=${a2MeashoSsbRsrp_a2ThresholdhoSsb}[${index}]
    Release UE   ue_id=${ue_id}
    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_UE${ue_id}.pcap


Set Amf Ue Ics Param
    [Documentation]    [PRIVATE]    set amf ue ics param
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd1}  Set Variable   amf_ue_ics_param id=1 ue=${ue_id} core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=256
    ${cmd2}  Set Variable   periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Log To Console    execute on wts: ${cmd1} ${cmd2}
    ute_wtssim.Execute Egate Command
    ...    cmd=${cmd1} ${cmd2}
    ...    alias=ap_egate


Wait For Inactivity
    [Documentation]    [PRIVATE]    wait for inactivity
    ...       :Autor: Sylvia Schneider
    Log To Console    wait 60 secs for inactivity
    Sleep    60s


Run Ue Disp And Save Output
    [Documentation]    [PRIVATE]    ue_disp
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}  ${log_nr}
    Log To Console    execute on wts: ue_disp
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_disp
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_ue_disp_ue${UE_id}_log${log_nr}.txt    ${output_egate}


Resume Ue
    [Documentation]    [PRIVATE]    resume ue
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd}    Set Variable  ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=1 msg=resume_request_1 cause=mo_Signalling
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.Execute Egate Command
    ...    cmd=${cmd}
    ...    alias=ap_egate
    Sleep    2s

    ${cmd}  Set Variable  ue_nr_rrc_resume id=${ue_id}
    ${check}  Set Variable  rrcResumeComplete
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_resume_ue${UE_id}.txt    ${output_egate}


Send A1
    [Documentation]    [PRIVATE]    send A1
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${meas_id}    ${srsrp_nr}   ${srsrq_nr}   ${check}
    ${cmd}   Set Variable
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} srs_result=0:11:11:0
    Log To Console   execute on wts: ${cmd}
    Log To Console   check on wts: "${check}" present
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/A1.txt    ${output_egate}


Send A1 No A4 Configured
    [Documentation]    [PRIVATE]    send A1 no A4 configured
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${meas_id}    ${srsrp_nr}   ${srsrq_nr}
    ${cmd}   Set Variable
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} srs_result=0:11:11:0
    Log To Console   execute on wts: ${cmd}
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/A1_no_A4_configured.txt    ${output_egate}


Send A4
    [Documentation]    [PRIVATE]    send A4
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${meas_id}    ${check}
    ${cmd}     Set Variable
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A4 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=40 nrsrq_nr=30
    Log To Console   execute on wts: ${cmd}
    Log To Console   check on wts: "${check}"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/A4.txt    ${output_egate}


Send A4 Nrsrq No Handover
    [Documentation]    [PRIVATE]    send A4 nrsrq no handover
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${meas_id}
    ${cmd}     Set Variable
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A4 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=40 nrsrq_nr=30
    Log To Console   execute on wts: ${cmd}
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/A4_noHandover.txt    ${output_egate}


Send A4 Nrsrq Handover
    [Documentation]    [PRIVATE]   send A4 nrsrq handover
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${meas_id}    ${check}
    ${cmd}     Set Variable
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A4 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=40 nrsrq_nr=32
    Log To Console   execute on wts: ${cmd}
    Log To Console   check on wts: "${check}"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/A4.txt    ${output_egate}


Set Sib Period For Gnb3
    [Documentation]    [PRIVATE]    set sib period for gnb3
    ...       :Autor: Sylvia Schneider
    FOR   ${sib}   IN   sib1   sib2   sib3
       ${cmd}   Set Variable   gnb_param id=3 ${sib}_period=40
       Log To Console    execute on wts: ${cmd}
       ute_wtssim.Execute Egate Command    cmd=${cmd}    alias=ap_egate
       Sleep     1s
    END


Set Sib Period For Gnb3 T22
    [Documentation]    [PRIVATE]    set sib period for gnb3
    ...       :Autor: Sylvia Schneider
    FOR   ${sib}   IN   sib1   sib2   sib5
       ${cmd}   Set Variable   gnb_param id=3 ${sib}_period=40
       Log To Console    execute on wts: ${cmd}
       ute_wtssim.Execute Egate Command    cmd=${cmd}    alias=ap_egate
       Sleep     1s
    END


Ue Change Location
    [Documentation]    [PRIVATE]    ue change location
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${cell}

    ${cmd}   Set Variable   ue_change_location id=${ue_id} enb=3 cell=${cell}
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.Execute Egate Command    cmd=${cmd}    alias=ap_egate


Set Ue History
    [Documentation]    [PRIVATE]    set ue history
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd}   Set Variable   ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=medium nrcgi=311:489|0x03 time_ue_stayed_in_cell=100
    Log To Console
    ...    execute on wts: ${cmd}
    ute_wtssim.Execute Egate Command    cmd=${cmd}    alias=ap_egate
    Sleep     2s

    ${cmd}   Set Variable   ue_history_information_list id=1 action=commit
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    pass_regexp=UE History List: 1 was committed    alias=ap_egate
    Sleep     2s

    ${cmd}   Set Variable   ue_enb_param id=${ue_id} ue_history_list=1
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.Execute Egate Command    cmd=${cmd}    alias=ap_egate
    Sleep     2s


Send A3
    [Documentation]    [PRIVATE]    send A3
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${meas_id}   ${nrsrp_nr}    ${phycell_id}   ${check}
    ${cmd}  Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=19 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr}
    Log To Console   execute on wts: ${cmd}
    Log To Console   check on wts: "${check}"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/A3.txt    ${output_egate}


Send A3 With Nrsrq Nr
    [Documentation]    [PRIVATE]    send A3 with nrsrq_nr
    ...       :Autor: Sylvia Schneider
    ${cmd}  Set Variable    ue_measurement_send_nr id=7 meas_id=7 event=A3 srsrp_nr=19 srsrq_nr=19 phycell_id=51 nrsrp_nr=90 nrsrq_nr=21
    Log To Console   execute on wts: ${cmd}
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/A3_1.txt    ${output_egate}


Send A3 With Nrsrq Nr And Check
    [Documentation]    [PRIVATE]    send A3 with nrsrq_nr and check
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${check}
    ${cmd}    Set Variable   ue_measurement_send_nr id=7 meas_id=7 event=A3 srsrp_nr=19 srsrq_nr=19 phycell_id=51 nrsrp_nr=90 nrsrq_nr=23
    Log To Console   execute on wts: ${cmd}
    Log To Console   check on wts: "${check}"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/A3_2.txt    ${output_egate}


Save Egate Log From A3 Event
    [Documentation]    [PRIVATE]    save egate_log from A3 event
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${log_instance}
    Log To Console   move file ${resultDir}/A3.txt to ${resultDir}/A3_${log_instance}.txt
    Move File    ${resultDir}/A3.txt    ${resultDir}/A3_${log_instance}.txt


Send B2 No Handover
    [Documentation]    [PRIVATE]    send B2 no handover
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}  ${meas_id}   ${nrsrp_nr}   ${nrsrq_nr}
    ${cmd1}     Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=B2 srsrp_nr=11 srsrq_nr=11
    ${cmd2}     Set Variable    srs_result=0:11:11:0 phycell_id=11 nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr} rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd}     Catenate   ${cmd1}     ${cmd2}
    Log To Console   execute on wts: ${cmd}
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/B2_no_handover.txt    ${output_egate}


Send B2
    [Documentation]    [PRIVATE]    send B2
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${meas_id}   ${nrsrp_nr}   ${nrsrq_nr}
    ${cmd1}     Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=B2 srsrp_nr=11 srsrq_nr=11
    ${cmd2}     Set Variable    srs_result=0:11:11:0 phycell_id=11 nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr} rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd}     Catenate   ${cmd1}     ${cmd2}
    ${check}     Set Variable   Successful handover from EXT_ENB-2.1 to ENB-4.1
    Log To Console   execute on wts: ${cmd}
    Log To Console   check on wts: "${check}"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/B2.txt    ${output_egate}


Trigger InterRat Handover
    [Documentation]    [PRIVATE]    trigger interRat handover
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd}     Set Variable    gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=1 plmn=311:489
    ${check}   Set Variable    Inter-eNB handover from ENB-4.1 to EXT_ENB-2.1 performed
    Log To Console   execute on wts: ${cmd}
    Log To Console   check on wts: "${check}"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/interRatHO.txt    ${output_egate}


Trigger And Check InterRat Handover
    [Documentation]    [PRIVATE]    trigger interRat handover
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${check}
    ${cmd}     Set Variable    gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=1 plmn=311:489
    Log To Console   execute on wts: ${cmd}
    Log To Console   check on wts: "${check}"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/interRatHO.txt    ${output_egate}


Display Measurement Config
    [Documentation]    [PRIVATE]    display measurement config from eNB
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}  ${log}=${EMPTY}
    ${cmd}     Set Variable    ue_meas_cfg_disp id=${ue_id}
    Log To Console   execute on wts: ${cmd}
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/disp_meas_config${log}.txt    ${output_egate}


Send Pdu Session Modify
    [Documentation]    [PRIVATE]    send pdu session modify
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd}     Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ${check}   Set Variable    Ue ${ue_id} PduId 1 Created FiveQi:Qfi mapping fiveQi 1 qfi 2
    Log To Console   execute on wts: ${cmd}
    Log To Console   check on wts: "${check}"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/pduSessionModify.txt    ${output_egate}


Send Pdu Session Modify Del
    [Documentation]    [PRIVATE]    send pdu session modify del
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd}     Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=2 by=amf
    ${check}   Set Variable    Ue ${ue_id} PduId 1 Removed FiveQi:Qfi mapping fiveQi 1 qfi 2
    Log To Console   execute on wts: ${cmd}
    Log To Console   check on wts: "${check}"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/pduSessionModify_del.txt    ${output_egate}


Send Ue Rrc Reestablish
    [Documentation]    [PRIVATE]    send ue rrc reestablish
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${cell}
    ${cmd}     Set Variable    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell}
    ${check}   Set Variable    rrcReconfigurationComplete
    Log To Console   execute on wts: ${cmd}
    Log To Console   check on wts: "${check}"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/ue_rrc_reestablish.txt    ${output_egate}


Save Pdu And A2 Egate Log ${run}
    [Documentation]    [PRIVATE]    save pdu and A2 egate log for every run
    ...       :Autor: Sylvia Schneider
    Move File    ${resultDir}/egate_log_start_pdu_ue2.txt    ${resultDir}/egate_log_start_pdu_ue2_${run}.txt
    Move File    ${resultDir}/egate_log_A2_ue2.txt           ${resultDir}/egate_log_A2_ue2_${run}.txt


Set Ue Nr Capabilites
    [Documentation]    [PRIVATE]    set ue nr capabilites
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${ue_nr_capabilities}
    ${cmd}     Set Variable    ue_param id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
    ${check}   Set Variable    UE NR Capability is modified.
    Log To Console   execute on wts: ${cmd}
    Log To Console   check on wts: "${check}"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    alias=ap_egate


Set Ue Nr Capabilites No Check
    [Documentation]    [PRIVATE]    set ue nr capabilites no check
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${ue_nr_capabilities}
    ${cmd}     Set Variable    ue_param id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
    Log To Console   execute on wts: ${cmd}
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command
    ...    cmd=${cmd}
    ...    alias=ap_egate


Send Ue Nr Rrc Reconf
    [Documentation]    [PRIVATE]    send ue_nr_rrc_reconf
    ...       :Autor: Sylvia Schneider
    ${cmd1}     Set Variable    ue_nr_rrc_reconf_param id=5 if_contains=any action=reestablish gnb=2 cell=1
    ${cmd2}     Set Variable    cause=handoverFailure crnti=source nth=1 num_reestablishment_reqs=1
    Log To Console   execute on wts: ${cmd1} ${cmd2}
    Sleep     2s
    ute_wtssim.Execute Egate Command
    ...    cmd=${cmd1} ${cmd2}
    ...    alias=ap_egate


Send Gnb Xn Handover Preparation
    [Documentation]    [PRIVATE]    send gnb_xn_handover_preparation
    ...       :Autor: Sylvia Schneider
    ${cmd}     Set Variable    gnb_xn_handover_preparation_param id=3 reestab_info=1:valid
    Log To Console   execute on wts: ${cmd}
    Sleep     2s
    ute_wtssim.Execute Egate Command
    ...    cmd=${cmd}
    ...    alias=ap_egate
