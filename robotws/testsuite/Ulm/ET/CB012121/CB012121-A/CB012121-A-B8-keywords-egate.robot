*** Settings ***
Documentation   This is a keyword file for CB012121-A-B8 egate
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

register UE and setup PDU session and send A2 and disp measurements
    [Documentation]    [PRIVATE]    register UE
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    register UE                  ue_id=${ue_id}
    start PDU session            ue_id=${ue_id}
    send A2                      ue_id=${ue_id}
    display measurement config   ue_id=${ue_id}   log=1


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
    [Arguments]     ${ue_id}
    ${cmd}    set variable  ue_pdu_session_setup pdu=1 ue=${UE_id} nwslice=1 gw=${UE_id}
    ${check}  set variable  Initial Context Setup Successful
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_pdu_setup_ue${ue_id}.txt    ${output_egate}


release pdu session and deregister
    [Documentation]    [PRIVATE]    release pdu session and deregister
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    UE PDU Session Release         ue_id=${ue_id}   pdu=1
    UE Deregister                  ue_id=${ue_id}


display measurement config
    [Documentation]    [PRIVATE]    display measurement config from eNB
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${log}
    ${cmd}     set variable    ue_meas_cfg_disp id=${ue_id}
    Log To Console   execute on wts: ${cmd}
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/disp_meas_config_UE${ue_id}_${log}.txt    ${output_egate}


send B2
    [Documentation]    [PRIVATE]    send B2
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd}    set variable
    ...   ue_measurement_send_nr event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0 phycell_id=11 nrsrq_nr=30 meas_id=11 id=${ue_id}
    Log To Console    execute on wts:${cmd}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_B2_ue${ue_id}.txt    ${output_egate}


send A1
    [Documentation]    [PRIVATE]    send A1
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${ue_id}
    ${cmd}    set variable
    ...   ue_measurement_send_nr event=A1 srsrp_nr=31 meas_id=4 id=${ue_id}
    ${check}  set variable  rrcReconfigurationComplete
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A1_UE${ue_id}.txt    ${output_egate}


send A2
    [Documentation]    [PRIVATE]    send A2
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}  ${meas_id}=1    ${log}=${EMPTY}
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
    [Arguments]     ${ue_id}   ${phycell_id}   ${nrsrp_nr}   ${nrsrq_nr}   ${meas_id}   ${check}   ${log}
    ${cmd1}    set variable   ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=${phycell_id}
    ${cmd2}    set variable   nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr} meas_id=${meas_id} id=${ue_id}
    ${cmd}         catenate    ${cmd1}   ${cmd2}
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    timeout=65s
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A3_ue${ue_id}_log${log}.txt    ${output_egate}


send A3 and check rrcReconfigurationComplete
    [Documentation]    [PRIVATE]    send A3 and check rrcReconfigurationComplete
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${ue_id}    ${log}
    ${cmd}    set variable   ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=52 nrsrp_nr=50 nrsrq_nr=45 meas_id=15 id=${ue_id}
    ${check}  set variable  rrcReconfigurationComplete
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A3_ue${ue_id}_log${log}.txt    ${output_egate}


send B2 and 3 times A3
    [Documentation]    [PRIVATE]    send B2 and 3 times A3
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${run}   ${check}
    send B2    ue_id=${ue_id}
    sleep   1s
    send A3    ue_id=${ue_id}   phycell_id=54   nrsrp_nr=50   nrsrq_nr=45   meas_id=6   log=${run}_1
    sleep   1s
    send A3    ue_id=${ue_id}   phycell_id=55   nrsrp_nr=55   nrsrq_nr=45   meas_id=7   log=${run}_2
    sleep   1s
    send A3 and check   ue_id=${ue_id}   phycell_id=51   nrsrp_nr=60   nrsrq_nr=55   meas_id=5   check=${check}   log=${run}_3


send B2 and 1 time A3
    [Documentation]    [PRIVATE]    send B2 and 1 time A3
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${run}   ${check}
    send B2    ue_id=${ue_id}
    send A3 and check   ue_id=${ue_id}   phycell_id=54   nrsrp_nr=50   nrsrq_nr=45   meas_id=6   check=${check}   log=${run}_1


send B2 and 2 times A3 and delayed A3
    [Documentation]    [PRIVATE]    send B2 and 2 times A3 and delayed A3
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${run}   ${check}
    send B2    ue_id=${ue_id}
    send A3    ue_id=${ue_id}   phycell_id=51   nrsrp_nr=50   nrsrq_nr=45   meas_id=5   log=${run}_1
    send A3    ue_id=${ue_id}   phycell_id=55   nrsrp_nr=55   nrsrq_nr=45   meas_id=7   log=${run}_2
    sleep      3s
    send A3 and check   ue_id=${ue_id}   phycell_id=49   nrsrp_nr=60   nrsrq_nr=55   meas_id=5   check=${check}   log=${run}_3


send 3 times A3 at the same time
    [Documentation]    [PRIVATE]    send 3 times A3 at the same time
    ...       :Autor: Sylvia Schneider
    ${cmd_A3_1}  set variable   ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=52 nrsrp_nr=50 nrsrq_nr=45 meas_id=6 id=1
    ${cmd_A3_2}  set variable   ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=53 nrsrp_nr=55 nrsrq_nr=45 meas_id=7 id=1
    ${cmd_A3_3}  set variable   ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=51 nrsrp_nr=60 nrsrq_nr=55 meas_id=5 id=1
    ${allcmds}   catenate  SEPARATOR=${\n}    ${cmd_A3_1}    ${cmd_A3_2}    ${cmd_A3_3}

    Log To Console    execute on wts without delay inbetween
    Log To Console    -> ${cmd_A3_1}
    Log To Console    -> ${cmd_A3_2}
    Log To Console    -> ${cmd_A3_3}
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${allcmds}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_3times_A3.txt    ${output_egate}
    sleep     2s


send 1 time B2 and 2 times A3 at the same time
    [Documentation]    [PRIVATE]    send 1 time B2 and 2 times A3 at the same time
    ...       :Autor: Sylvia Schneider
    ${cmd_B2}  set variable   ue_measurement_send_nr id=2 meas_id=11 event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0 phycell_id=11 nrsrq_nr=30
    ${cmd_A3_1}  set variable   ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=52 nrsrp_nr=50 nrsrq_nr=45 meas_id=6 id=2
    ${cmd_A3_2}  set variable   ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=53 nrsrp_nr=55 nrsrq_nr=45 meas_id=7 id=2
    ${allcmds}   catenate  SEPARATOR=${\n}    ${cmd_B2}    ${cmd_A3_1}    ${cmd_A3_2}

    Log To Console    execute on wts without delay inbetween
    Log To Console    -> ${cmd_B2}
    Log To Console    -> ${cmd_A3_1}
    Log To Console    -> ${cmd_A3_2}
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${allcmds}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_1time_B2_2times_A3.txt    ${output_egate}


