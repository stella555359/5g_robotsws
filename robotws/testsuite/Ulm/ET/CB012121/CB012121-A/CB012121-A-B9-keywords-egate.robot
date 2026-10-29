*** Settings ***
Documentation   This is a keyword file for CB012121-A-B9 egate
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


register 2 UEs
    [Documentation]    [PRIVATE]    register 2 UEs
    ...       :Autor: Sylvia Schneider
    register UE    ue_id=1
    register UE    ue_id=2


start PDU session
    [Documentation]    [PRIVATE]    start PDU
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd}    set variable  ue_pdu_session_setup pdu=1 ue=${UE_id} gw=${UE_id}
    ${check}  set variable  Initial Context Setup Successful
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    sleep     2s   wait for all data sent
    Create File    ${resultDir}/egate_pdu_setup_ue${ue_id}.txt    ${output_egate}


setup PDU sessions for 2 UEs
    [Documentation]    [PRIVATE]    setup PDU sessions for 2 UEs
    ...       :Autor: Sylvia Schneider
    start PDU session    ue_id=1
    start PDU session    ue_id=2


display measurement config
    [Documentation]    [PRIVATE]    display measurement config from eNB
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd}     set variable    ue_meas_cfg_disp id=${ue_id}
    Log To Console   execute on wts: ${cmd}
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/disp_meas_config_UE${ue_id}.txt    ${output_egate}


display measurement config for 2 UEs
    [Documentation]    [PRIVATE]    display measurement config from eNB
    ...       :Autor: Sylvia Schneider
    display measurement config   ue_id=1
    display measurement config   ue_id=2


trigger meas reconfig for intra-freq inter-freq and interRat
    [Documentation]    [PRIVATE]    trigger meas reconfig for intra-freq inter-freq and interRat
    ...       :Autor: Sylvia Schneider
    send A2   ue_id=1
    send A2   ue_id=2


send A2
    [Documentation]    [PRIVATE]    send A2
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd}    set variable
    ...   ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=30 srsrq_nr=30
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


send A3 to start measurementReportPrioritizationTimer for INTER-FREQ HO
    [Documentation]    [PRIVATE]    send A3send A3 to start measurementReportPrioritizationTimer for INTER-FREQ HO
    ...       :Autor: Sylvia Schneider
    ${cmd1}    set variable   ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=53
    ${cmd2}    set variable   nrsrp_nr=55 nrsrq_nr=45 meas_id=7 id=1
    ${cmd}         catenate    ${cmd1}   ${cmd2}
    Log To Console    execute on wts:${cmd}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    timeout=20s
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A3_ue1_log1.txt    ${output_egate}


send A3 for 2 UEs A_B9
    [Documentation]    [PRIVATE]    send A3 for 2 UEs A_B9
    ...       :Autor: Sylvia Schneider
    ${cmd1}    set variable   ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=51
    ${cmd2}    set variable   nrsrp_nr=60 nrsrq_nr=55 meas_id=5 id=1
    ${cmd}         catenate    ${cmd1}   ${cmd2}
    Log To Console    execute on wts:${cmd}
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A3_ue1_log2.txt    ${output_egate}

    ${cmd1}    set variable   ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=51
    ${cmd2}    set variable   nrsrp_nr=60 nrsrq_nr=55 meas_id=5 id=2
    ${cmd}         catenate    ${cmd1}   ${cmd2}
    ${check}   set variable   UE1: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    timeout=65s
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A3_ue2_log2.txt    ${output_egate}


release PDU session 2 UEs
    [Documentation]    [PRIVATE]    release PDU session 2 UEs
    ...       :Autor: Sylvia Schneider
    UE PDU Session Release         ue_id=1   pdu=1
    UE PDU Session Release         ue_id=2   pdu=1


deregister 2 UEs
    [Documentation]    [PRIVATE]    deregister 2 UEs
    ...       :Autor: Sylvia Schneider
    UE Deregister                  ue_id=1
    UE Deregister                  ue_id=2
