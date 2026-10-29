*** Settings ***
Documentation   This is a keyword file for CB012121-B-B8 egate
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

register UE
    [Documentation]    [PRIVATE]    register UE
    ...       :Autor: Sylvia Schneider
    ${cmd}     set variable   ue_register id=1 nwslice=1
    ${check}   set variable   REGISTRATION COMPLETE from UE
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: "${check}"
    ute_wtssim.execute egate command and wait for data    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate


start PDU session
    [Documentation]    [PRIVATE]    start PDU
    ...       :Autor: Sylvia Schneider
    ${cmd}    set variable  ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
    ${check}  set variable  Initial Context Setup Successful
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_pdu_setup.txt    ${output_egate}


send A3
    [Documentation]    [PRIVATE]    send A3
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${phycell_id}   ${nrsrp_nr}   ${nrsrq_nr}   ${meas_id}   ${log}
    ${cmd1}    set variable   ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=${phycell_id}
    ${cmd2}    set variable   nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr} meas_id=${meas_id} id=${ue_id}
    ${cmd}         catenate    ${cmd1}   ${cmd2}
    Log To Console    execute on wts:${cmd}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A3_ue${ue_id}_log${log}.txt    ${output_egate}


send A3 with 2 phycell ids and check
    [Documentation]    [PRIVATE]    send A3 with 2 phycell ids and check
    ...       :Autor: Sylvia Schneider
    sleep   1s
    ${cmd1}    set variable   ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=51 nrsrp_nr=65 nrsrq_nr=60
    ${cmd2}    set variable   phycell_id=49 nrsrp_nr=85 nrsrq_nr=80 meas_id=5 id=1
    ${cmd}     catenate    ${cmd1}   ${cmd2}
    ${check}   set variable   Inter-eNB handover from EXT_ENB-2.1 to ENB-3.2 performed
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A3_ue1_log2.txt    ${output_egate}


send A2
    [Documentation]    [PRIVATE]    send A2
    ...       :Autor: Sylvia Schneider
    ${cmd}    set variable
    ...   ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ${check}  set variable  rrcReconfigurationComplete
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    sleep     2s   wait for all data sent
    Create File    ${resultDir}/egate_A2.txt    ${output_egate}


send 3times A3
    [Documentation]    [PRIVATE]    send 3times A3
    ...       :Autor: Sylvia Schneider

    ${cmd_A3_1}  set variable   ue_measurement_send_nr id=1 meas_id=5 event=A3 srsrp_nr=60 srsrq_nr=60 srs_result=0:11:11:0 phycell_id=49
    ${cmd_A3_2}  set variable   nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd_A3_1st}    catenate  ${cmd_A3_1}   ${cmd_A3_2}

    ${cmd_A3_3}  set variable   ue_measurement_send_nr id=1 meas_id=7 event=A3 srsrp_nr=60 srsrq_nr=60 srs_result=0:11:11:0 phycell_id=55
    ${cmd_A3_4}  set variable   nrsrp_nr=90 nrsrq_nr=80 rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd_A3_2nd}    catenate  ${cmd_A3_3}   ${cmd_A3_4}

    ${cmd_A3_5}  set variable   ue_measurement_send_nr id=1 meas_id=6 event=A3 srsrp_nr=60 srsrq_nr=60 srs_result=0:11:11:0 phycell_id=54
    ${cmd_A3_6}  set variable   nrsrp_nr=85 nrsrq_nr=80 rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd_A3_3rd}    catenate  ${cmd_A3_5}   ${cmd_A3_6}

    ${allcmds}   catenate  SEPARATOR=${\n}    ${cmd_A3_1st}    ${cmd_A3_2nd}    ${cmd_A3_3rd}
    ${check}  set variable  Inter-eNB handover from EXT_ENB-2.1 to ENB-5.1 performed
    Log To Console    execute on wts:${allcmds}
    Log To Console    check on wts: "${check}"
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${allcmds}
    ...    timeout=15s
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    sleep     2s   wait for all data sent
    Create File    ${resultDir}/egate_A3.txt    ${output_egate}


release pdu session and deregister
    [Documentation]    [PRIVATE]    release pdu session and deregister
    ...       :Autor: Sylvia Schneider
    UE PDU Session Release         ue_id=1   pdu=1
    UE Deregister                  ue_id=1
