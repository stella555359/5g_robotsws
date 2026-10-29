*** Settings ***
Documentation   This is a keyword file for CB012121-B egate
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

register UE
    [Documentation]    [PRIVATE]    register UE
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd}     set variable   ue_register id=${UE_id} nwslice=1
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
    [Arguments]     ${ue_id}=1   ${check}=Initial Context Setup Successful
    ${cmd}    set variable  ue_pdu_session_setup pdu=1 ue=${UE_id} nwslice=1 gw=${UE_id}
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_pdu_setup_ue${ue_id}.txt    ${output_egate}


display measurement config
    [Documentation]    [PRIVATE]    display measurement config from eNB
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}    ${log}
    ${cmd}     set variable    ue_meas_cfg_disp id=${ue_id}
    Log To Console   execute on wts: ${cmd}
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/disp_meas_config_UE${ue_id}_${log}.txt    ${output_egate}


register UE and start PDU and send A2
    [Documentation]    [PRIVATE]    register UE and start PDU and send A2
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    register UE                  ue_id=${ue_id}
    start PDU session            ue_id=${ue_id}
    display measurement config   ue_id=${ue_id}    log=1
    send A2                      ue_id=${ue_id}    log=_1
    display measurement config   ue_id=${ue_id}    log=2


send A1
    [Documentation]    [PRIVATE]    send A1
    ...       :Autor: Yasir Mehmood
    [Arguments]     ${ue_id}   ${srsrp_nr}   ${srsrq_nr}   ${meas_id}   ${log}
    ${cmd1}    set variable   ue_measurement_send_nr event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ${cmd2}    set variable   meas_id=${meas_id} id=${ue_id}
    ${cmd}         catenate    ${cmd1}   ${cmd2}
    Log To Console    execute on wts:${cmd}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A1_ue${ue_id}_log${log}.txt    ${output_egate}


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


send A3 and check
    [Documentation]    [PRIVATE]    send A3 and check
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}      ${log}   ${phycell_id}=55   ${nrsrp_nr}=55   ${nrsrq_nr}=45  ${meas_id}=7
    ...             ${check}=Inter-eNB handover from EXT_ENB-2.1 to ENB-5.2 performed  ${timeout}=65
    ${cmd1}    set variable   ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=${phycell_id}
    ${cmd2}    set variable   nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr} meas_id=${meas_id} id=${ue_id}
    ${cmd}     catenate    ${cmd1}   ${cmd2}
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    timeout=${timeout}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A3_ue${ue_id}_log${log}.txt    ${output_egate}


send 3 times A3 and check HO
    [Documentation]    [PRIVATE]    send 3 times A3 and check HO
    ...       :Autor: Sylvia Schneider
    ${cmd1}    set variable   ue_measurement_send_nr id=1 meas_id=5 event=A3 srsrp_nr=60 srsrq_nr=60 srs_result=0:11:11:0 phycell_id=49
    ${cmd2}    set variable   nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd12}   catenate    ${cmd1}   ${cmd2}
    Log To Console    execute on wts:${cmd12}
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd12}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A3_ue1_3timesA3_1.txt    ${output_egate}

    ${cmd3}    set variable   ue_measurement_send_nr id=1 meas_id=7 event=A3 srsrp_nr=60 srsrq_nr=60 srs_result=0:11:11:0 phycell_id=55
    ${cmd4}    set variable   nrsrp_nr=90 nrsrq_nr=80 rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd34}   catenate    ${cmd3}   ${cmd4}
    Log To Console    execute on wts:${cmd34}
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd34}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A3_ue1_3timesA3_2.txt    ${output_egate}

    ${cmd5}    set variable   ue_measurement_send_nr id=1 meas_id=6 event=A3 srsrp_nr=60 srsrq_nr=60 srs_result=0:11:11:0 phycell_id=54
    ${cmd6}    set variable   nrsrp_nr=85 nrsrq_nr=80 rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd56}   catenate    ${cmd5}   ${cmd6}
    ${check}  set variable  Inter-eNB handover from EXT_ENB-2.1 to ENB-5.1 performed
    Log To Console    execute on wts:${cmd56}
    Log To Console    check on wts: "${check}"
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd56}
    ...    timeout=15s
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A3_ue1_3timesA3_3.txt    ${output_egate}


send A3 with 2 phycell ids
    [Documentation]    [PRIVATE]    send A3 with 2 phycell ids
    ...       :Autor: Yasir Mehmood
    [Arguments]     ${ue_id}  ${meas_id}  ${pci1}  ${nrsrp_nr1}  ${nrsrq_nr1}  ${pci2}  ${nrsrp_nr2}  ${nrsrq_nr2}  ${log}
    sleep   1s
    ${cmd1}    set variable   ue_measurement_send_nr event=A3 id=${ue_id} meas_id=${meas_id} srsrp_nr=30 srsrq_nr=30
    ${cmd2}    set variable   phycell_id=${pci1} nrsrp_nr=${nrsrp_nr1} nrsrq_nr=${nrsrq_nr1}
    ${cmd3}    set variable   phycell_id=${pci2} nrsrp_nr=${nrsrp_nr2} nrsrq_nr=${nrsrq_nr2}
    ${cmd}     catenate    ${cmd1}   ${cmd2}   ${cmd3}
    Log To Console    execute on wts:${cmd}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A3_ue${ue_id}_log${log}.txt    ${output_egate}


send A3 with 2 phycell ids and check
    [Documentation]    [PRIVATE]    send A3 with 2 phycell ids and check
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}  ${meas_id}  ${pci1}  ${nrsrp_nr1}  ${nrsrq_nr1}  ${pci2}  ${nrsrp_nr2}  ${nrsrq_nr2}  ${log}
    ...             ${check}
    sleep   1s
    ${cmd1}    set variable   ue_measurement_send_nr event=A3 id=${ue_id} meas_id=${meas_id} srsrp_nr=30 srsrq_nr=30
    ${cmd2}    set variable   phycell_id=${pci1} nrsrp_nr=${nrsrp_nr1} nrsrq_nr=${nrsrq_nr1}
    ${cmd3}    set variable   phycell_id=${pci2} nrsrp_nr=${nrsrp_nr2} nrsrq_nr=${nrsrq_nr2}
    ${cmd}     catenate    ${cmd1}   ${cmd2}   ${cmd3}
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A3_ue1_log${log}.txt    ${output_egate}


send A3 and B2 and A3
    [Documentation]    [PRIVATE]    send A3 and B2 and A3
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    send A3    ue_id=${ue_id}   phycell_id=55   nrsrp_nr=55   nrsrq_nr=45   meas_id=7   log=1
    sleep  1s
    send B2 nrsrq_nr  ue_id=${ue_id}   meas_id=11
    sleep  1s
    send A3    ue_id=${ue_id}   phycell_id=49   nrsrp_nr=50   nrsrq_nr=55   meas_id=5   log=2
    sleep  1s


send A3 to trigger intra-eNB handover with a3MeasEnabled
    [Documentation]    [PRIVATE]    send A3 to trigger intra-eNB handover with a3MeasEnabled
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${a3MeasEnabled}
    ${nrsrp_nr}    set variable if   '${a3MeasEnabled}'=='rsrp'   58     50
    ${nrsrq_nr}    set variable if   '${a3MeasEnabled}'=='rsrp'   50     58
    send A3 and check   ue_id=${ue_id}   phycell_id=51   nrsrp_nr=${nrsrp_nr}   nrsrq_nr=${nrsrq_nr}  meas_id=5
    ...   check=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed  timeout=15   log=3


send A2
    [Documentation]    [PRIVATE]    send A2
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${meas_id}=1  ${log}=$EMPTY
    ${cmd}    set variable
    ...   ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ${check}  set variable  rrcReconfigurationComplete
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    sleep     2s   wait for all data sent
    Create File    ${resultDir}/egate_A2_ue${ue_id}${log}.txt    ${output_egate}


send A2 with srs_result
    [Documentation]    [PRIVATE]    send A2 with srs_result
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd}    set variable
    ...   ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ${check}  set variable  rrcReconfigurationComplete
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    sleep     2s   wait for all data sent
    Create File    ${resultDir}/egate_A2_ue${ue_id}.txt    ${output_egate}


send 2 times event A3 within 10 seconds
    [Documentation]    [PRIVATE]    send 2 times event A3 within 10 seconds
    ...       :Autor: Sylvia Schneider
    ${cmd1}  set variable   ue_measurement_send_nr id=1 meas_id=6 event=A3 srsrp_nr=60 srsrq_nr=60 srs_result=0:11:11:0
    ${cmd2}  set variable   phycell_id=55 nrsrp_nr=85 nrsrq_nr=80 rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd}   catenate  ${cmd1} ${cmd2}
    Log To Console    execute on wts: ${cmd}
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_A3_log1.txt    ${output_egate}
    sleep     2s

    ${cmd3}  set variable   ue_measurement_send_nr id=1 meas_id=5 event=A3 srsrp_nr=60 srsrq_nr=60 srs_result=0:11:11:0
    ${cmd4}  set variable   phycell_id=54 nrsrp_nr=90 nrsrq_nr=80 rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd}   catenate  ${cmd3} ${cmd4}
    Log To Console    execute on wts: ${cmd}
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_A3_log2.txt    ${output_egate}
    sleep     2s


send B2
    [Documentation]    [PRIVATE]    send B2
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd1}   set variable   ue_measurement_send_nr id=${ue_id} meas_id=11 event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0 phycell_id=11
    ${cmd2}   set variable   nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd}    catenate   ${cmd1}   ${cmd2}
    ${check}  set variable  Successful handover from EXT_ENB-2.1 to ENB-4.1
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    timeout=15s
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    sleep     2s   wait for all data sent
    Create File    ${resultDir}/egate_B2_ue${ue_id}.txt    ${output_egate}


send B2 no check
    [Documentation]    [PRIVATE]    send B2 no check
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd1}   set variable   ue_measurement_send_nr id=${ue_id} meas_id=11 event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0 phycell_id=11
    ${cmd2}   set variable   nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd}    catenate   ${cmd1}   ${cmd2}
    Log To Console    execute on wts:${cmd}
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    sleep     2s   wait for all data sent
    Create File    ${resultDir}/egate_B2_ue${ue_id}.txt    ${output_egate}


send B2 nrsrq_nr
    [Documentation]    [PRIVATE]    send B2 nrsrq_nr
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${meas_id}=21
    ${cmd1}   set variable   ue_measurement_send_nr event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0 phycell_id=11
    ${cmd2}   set variable   nrsrq_nr=30 meas_id=${meas_id} id=${ue_id}
    ${cmd}    catenate   ${cmd1}   ${cmd2}
    Log To Console    execute on wts:${cmd}
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_B2_nrsrq_ue${ue_id}.txt    ${output_egate}


release pdu session and deregister
    [Documentation]    [PRIVATE]    release pdu session and deregister
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    UE PDU Session Release         ue_id=${ue_id}   pdu=1
    UE Deregister                  ue_id=${ue_id}
