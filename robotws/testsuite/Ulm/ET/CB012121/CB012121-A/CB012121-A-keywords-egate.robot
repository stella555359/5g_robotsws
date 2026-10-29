*** Settings ***
Documentation   This is a keyword file for CB012121-A egate
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

register UE
    [Documentation]    [PRIVATE]    register UE
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${nwslice}=all
    ${cmd}     set variable   ue_register id=${UE_id} nwslice=${nwslice}
    ${check}   set variable   REGISTRATION COMPLETE from UE
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: "${check}"
    sleep     2s
    ute_wtssim.execute egate command and wait for data    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate


set amf indexToRFSP
    [Documentation]    [PRIVATE]    set amf indexToRFSP in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${indexToRFSP}
    ${cmd}  set variable  amf_ue_ics_param id=1 indexToRFSP=${indexToRFSP}
    sleep     2s
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command     cmd=${cmd}    alias=ap_egate


start PDU session
    [Documentation]    [PRIVATE]    start PDU
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd}    set variable  ue_pdu_session_setup pdu=1 ue=${UE_id} gw=${UE_id}
    ${check}  set variable  Initial Context Setup Successful
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
    sleep     2s
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    sleep     2s   wait for all data sent
    Create File    ${resultDir}/egate_pdu_setup_ue${ue_id}.txt    ${output_egate}


start PDU session rrcReconfigurationComplete
    [Documentation]    [PRIVATE]    start PDU rrcReconfigurationComplete
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${pdu_id}    ${gw_id}
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
    Create File    ${resultDir}/egate_log_start_pdu_ue${UE_id}.txt    ${output_egate}
    sleep     2s


send A2 with srs_result
    [Documentation]    [PRIVATE]    send A2 with srs_result
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}  ${meas_id}   ${srsrp_nr}   ${log}
    ${cmd}    set variable
    ...   ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrp_nr} srs_result=0:11:11:0
    ${check}  set variable  rrcReconfigurationComplete
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
    sleep     2s
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    sleep     2s   wait for all data sent
    Create File    ${resultDir}/egate_A2_ue${ue_id}_log${log}.txt    ${output_egate}


send A2
    [Documentation]    [PRIVATE]    send A2
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}  ${meas_id}   ${srsrp_nr}   ${log}
    ${cmd}    set variable
    ...   ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrp_nr}
    ${check}  set variable  rrcReconfigurationComplete
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
    sleep     2s
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    sleep     2s   wait for all data sent
    Create File    ${resultDir}/egate_A2_ue${ue_id}_log${log}.txt    ${output_egate}


send event A2 with srsrp_srsrq_nr
    [Documentation]    [PRIVATE]    send event A2 with srsrp_srsrq_nr
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}  ${meas_id}   ${srsrp_srsrq_nr}
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
    Create File    ${resultDir}/egate_log_A2_ue${UE_id}.txt    ${output_egate}
    sleep     2s


send A3 to trigger handover
    [Documentation]    [PRIVATE]    send A3 to trigger handover
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${log}
    ${cmd}     catenate    ue_measurement_send_nr id=${ue_id} meas_id=5 event=A3 srsrp_nr=60 srsrq_nr=60 srs_result=0:11:11:0
    ...                    phycell_id=49 nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=0 nrs_result=30:30:0
    ${check}  set variable  Inter-eNB handover from EXT_ENB-2.1 to ENB-3.2 performed
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
    sleep     2s
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    timeout=20s
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    sleep     2s   wait for all data sent
    Create File    ${resultDir}/egate_A3_handover_ue${ue_id}_log${log}.txt    ${output_egate}


send A3
    [Documentation]    [PRIVATE]    send A3
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}  ${phycell_id}   ${meas_id}  ${nrsrp_nr}    ${nrsrq_nr}   ${log}
    ${cmd1}    set variable   ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=${phycell_id}
    ${cmd2}    set variable   nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr} meas_id=${meas_id} id=${ue_id}
    ${cmd}         catenate    ${cmd1}   ${cmd2}
    Log To Console    execute on wts:${cmd}
    sleep     2s
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    timeout=20s
    ...    return_output=True
    ...    alias=ap_egate
    sleep     2s   wait for all data sent
    Create File    ${resultDir}/egate_A3_ue${ue_id}_log${log}.txt    ${output_egate}


send A3 and check
    [Documentation]    [PRIVATE]    send A3 and check
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}  ${phycell_id}   ${meas_id}   ${nrsrp_nr}   ${nrsrq_nr}   ${log}   ${check}
    ${cmd1}    set variable   ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=${phycell_id}
    ${cmd2}    set variable   nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr} meas_id=${meas_id} id=${ue_id}
    ${cmd}         catenate    ${cmd1}   ${cmd2}
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
    sleep     2s
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    timeout=20s
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    sleep     2s   wait for all data sent
    Create File    ${resultDir}/egate_A3_ue${ue_id}_log${log}.txt    ${output_egate}


send event A3
    [Documentation]    [PRIVATE]    send event A3
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}  ${meas_id}   ${phycell_id}   ${nrsrp_nr}   ${log}
    ${cmd1}  set variable   ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=60 srsrq_nr=60 srs_result=0:11:11:0
    ${cmd2}  set variable   phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=80 rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd}   catenate  ${cmd1} ${cmd2}
    ${check}   set variable   physCellId 50,
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_A3_ue${UE_id}_log${log}.txt    ${output_egate}
    sleep     2s


send event B2 and twice A3
    [Documentation]    [PRIVATE]    send event B2 and twice A3
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${check_A3}   ${log}
    ${cmd_B2_1}  set variable   ue_measurement_send_nr id=1 meas_id=11 event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ${cmd_B2_2}  set variable    phycell_id=11 nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd_B2}    catenate  ${cmd_B2_1}   ${cmd_B2_2}

    ${cmd_A3_1}  set variable   ue_measurement_send_nr id=1 meas_id=6 event=A3 srsrp_nr=20 srsrq_nr=20 srs_result=0:11:11:0
    ${cmd_A3_2}  set variable    phycell_id=54 nrsrp_nr=90 nrsrq_nr=25 rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd_A3_1st}    catenate  ${cmd_A3_1}   ${cmd_A3_2}

    ${cmd_A3_3}  set variable   ue_measurement_send_nr id=1 meas_id=7 event=A3 srsrp_nr=20 srsrq_nr=21 srs_result=0:11:11:0
    ${cmd_A3_4}  set variable    phycell_id=55 nrsrp_nr=90 nrsrq_nr=27 rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd_A3_2nd}    catenate  ${cmd_A3_3}   ${cmd_A3_4}

    ${allcmds}   catenate  SEPARATOR=${\n}    ${cmd_B2}     ${cmd_A3_1st}    ${cmd_A3_2nd}

    Log To Console    execute on wts without delay inbetween
    Log To Console    -> ${cmd_B2}
    Log To Console    -> ${cmd_A3_1st}
    Log To Console    -> ${cmd_A3_2nd} and verfiy ${check_A3}
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${allcmds}
    ...    timeout=15s
    ...    return_output=True
    ...    pass_regexp=${check_A3}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_A3_log${log}.txt    ${output_egate}
    sleep     2s


send B2
    [Documentation]    [PRIVATE]    send B2
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${meas_id}
    ${cmd1}    set variable   ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ${cmd2}    set variable   phycell_id=11 nrsrq_nr=30
    ${cmd}         catenate    ${cmd1}   ${cmd2}
    Log To Console    execute on wts:${cmd}
    sleep     2s
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    timeout=20s
    ...    return_output=True
    ...    alias=ap_egate
    sleep     2s   wait for all data sent
    Create File    ${resultDir}/egate_B2_ue${ue_id}.txt    ${output_egate}


change location
    [Documentation]    [PRIVATE]    change location in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${ue_id}
    ${cmd}  set variable  ue_change_location id=${ue_id} enb=2 cell=1
    sleep     2s
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command     cmd=${cmd}    alias=ap_egate


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
    Create File    ${resultDir}/disp_meas_config_UE${ue_id}_${log}.txt    ${output_egate}


send twice A3
    [Documentation]    [PRIVATE]    send twice A3
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${log}

    ${cmd_A3_1}  set variable   ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=48 nrsrp_nr=60 nrsrq_nr=55 meas_id=5 id=21
    ${cmd_A3_2}  set variable   ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=53 nrsrp_nr=55 nrsrq_nr=45 meas_id=7 id=21
    ${allcmds}   catenate  SEPARATOR=${\n}    ${cmd_A3_1}    ${cmd_A3_2}

    Log To Console    execute on wts without delay inbetween
    Log To Console    -> ${cmd_A3_1}
    Log To Console    -> ${cmd_A3_2}
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${allcmds}
    ...    timeout=15s
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_A3_log${log}.txt    ${output_egate}
    sleep     2s
