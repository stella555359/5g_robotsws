*** Settings ***
Documentation   This is a keyword file for CB013024 part egate
...             Team: 'MN RAN RD VRF ULM4'
...             Author: Shruthi Shivaprasad
#-------------------------------------------------------------------------------------------------------------

Resource        ../../resources/Common/wts_ue.robot

*** Variables ***

${WIRESHARK_RUNNING}     false

*** Keywords ***

Check Wts In Active State
    [Documentation]    [PRIVATE]    check that wts is in state active
    ...       :Autor: Shruthi Shivaprasad
    Log To Console    \ncheck if wts in active state
    Wait Until Keyword Succeeds    5 min    20 sec    Check Wts State
    Log To Console    check if wts in active state ended


Check Wts State
    [Documentation]    [PRIVATE]    check that wts is in state active
    ...       :Autor: Shruthi Shivaprasad
    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=sim_state_disp
    ...    pass_regexp=The state is ACTIVE   alias=ap_egate


Register UE
    [Documentation]    [PRIVATE]    register UE
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]    ${ue_id}   ${nwslice}=1
    Log To Console    \nUE Register and set trf type
    wts_ue.UE Register    ue_id=${ue_id}    nwslice=${nwslice}

    wts_ue.Set Traffic Type   ue_id=${ue_id}  pdu_id=1  trf_type=internal


Setup PDU Session
    [Documentation]    [PRIVATE]    start PDU
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]    ${ue_id}
    ${cmd}    Set Variable  ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    ${check}  Set Variable  Initial Context Setup Successful
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
    ${output_egate}  ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Sleep     2s
    OperatingSystem.Create File    ${resultDir}/egate_pdu_setup_ue${ue_id}.txt    ${output_egate}


Start Traffic TC1
    [Documentation]    [PRIVATE]    traffic_data_start dl and ul
    [Arguments]   ${run}   ${ue_id}
    ${cmd1}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 dir=dl mbps=100
    ${cmd2}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 dir=dl mbps=100
    ${cmd3}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=3 dir=dl mbps=100
    ${cmd4}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=4 dir=dl mbps=100
    ${cmd5}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=5 dir=dl mbps=100
    ${cmd6}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=6 dir=dl mbps=100
    ${cmd7}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 dir=ul mbps=100
    ${cmd8}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 dir=ul mbps=100
    ${allcmds}   Catenate  SEPARATOR=${\n}       ${cmd1}     ${cmd2}     ${cmd3}     ${cmd4}
    ...                              ${cmd5}     ${cmd6}     ${cmd7}     ${cmd8}

    Log To Console    execute on wts without delay inbetween
    Log To Console    \n ${allcmds}

    ${output_egate}  ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${allcmds}
    ...    pass_regexp=DL TRF
    ...    return_output=True
    ...    alias=ap_egate

    Log To Console    -> dl and ul traffic started
    OperatingSystem.Create File    ${resultDir}/egate_trfStart_${run}.txt    ${output_egate}


Stop Traffic
    [Documentation]    [PRIVATE]    stop dl traffic trf_id2
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]     ${ue_id}
    ${cmd}    Set Variable  trf_data_stop ue=${ue_id} pdu=1 qfi=1
    Log To Console    execute on wts: ${cmd}
     ${output_egate}  ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate


Get UE NR Throughput Pusch And Pdsch
    [Documentation]    [PRIVATE]    get ue NR throughput pusch and pdsch
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]     ${ue_id}
    ${cmd}    Set Variable  ue_stats_nr id=${ue_id} scell=0-8 type=pdsch
    Log To Console    execute on wts:${cmd}
    ${output_egate}  ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    OperatingSystem.Create File    ${resultDir}/egate_throughput_pdsch.txt     ${output_egate}

    ${cmd1}    Set Variable  ue_stats_nr id=${ue_id} scell=0-8 type=pusch
    Log To Console    execute on wts:${cmd1}
    ${output_egate1}  ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd1}
    ...    return_output=True
    ...    alias=ap_egate
    OperatingSystem.Create File    ${resultDir}/egate_throughput_pusch.txt    ${output_egate1}


Release Pdu Session And Deregister
    [Documentation]    [PRIVATE]    release pdu session and deregister
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]     ${ue_id}
    wts_ue.UE PDU Session Release         ue_id=${ue_id}   pdu=1
    wts_ue.UE Deregister                  ue_id=${ue_id}
