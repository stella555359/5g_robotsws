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
    ute_wtssim.execute egate command and wait for data
    ...    cmd=sim_state_disp
    ...    pass_regexp=The state is ACTIVE   alias=ap_egate


Register UE
    [Documentation]    [PRIVATE]    register UE
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]    ${ue_id}   ${nwslice}=1
    Log To Console    \nUE Register and set trf type
    UE Register    ue_id=${ue_id}    nwslice=${nwslice}

    Set traffic type   ue_id=${ue_id}  pdu_id=1  trf_type=internal


setup PDU session
    [Documentation]    [PRIVATE]    start PDU
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]    ${ue_id}
    ${cmd}    Set Variable  ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    ${check}  Set Variable  Initial Context Setup Successful
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    sleep     2s
    OperatingSystem.Create File    ${resultDir}/egate_pdu_setup_ue${ue_id}.txt    ${output_egate}


Start Traffic
    [Documentation]    [PRIVATE]    traffic_data_start dl
    [Arguments]   ${run}   ${ue_id}=1
    ${cmd1}    set variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 dir=dl mbps=100
    ${cmd2}    set variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 dir=dl mbps=100
    ${cmd3}    set variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=3 dir=dl mbps=100
    ${cmd4}    set variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=4 dir=dl mbps=100
    ${cmd5}    set variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=5 dir=dl mbps=100
    ${cmd6}    set variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 dir=ul mbps=100
    ${cmd7}    set variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 dir=ul mbps=100
    ${allcmds}   catenate  SEPARATOR=${\n}       ${cmd1}     ${cmd2}     ${cmd3}     ${cmd4}     ${cmd5}     ${cmd6}     ${cmd7}
    Log To Console    execute on wts without delay inbetween
    Log To Console    \n ${allcmds}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${allcmds}
    ...    pass_regexp=DL TRF
    ...    return_output=True
    ...    alias=ap_egate
    Log To Console    -> dl traffic cmd started
    OperatingSystem.Create File    ${resultDir}/egate_trfStart_${run}.txt    ${output_egate}

Start Traffic TC1
    [Documentation]    [PRIVATE]    traffic_data_start dl
    [Arguments]   ${run}   ${ue_id}
    ${cmd1}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 dir=dl mbps=100
    ${cmd2}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 dir=dl mbps=100
    ${cmd3}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=3 dir=dl mbps=100
    ${cmd4}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 dir=ul mbps=100
    ${allcmds}   Catenate  SEPARATOR=${\n}       ${cmd1}     ${cmd2}     ${cmd3}     ${cmd4}
    Log To Console    execute on wts without delay inbetween
    Log To Console    \n ${allcmds}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${allcmds}
    ...    pass_regexp=DL TRF
    ...    return_output=True
    ...    alias=ap_egate
    Log To Console    -> dl traffic cmd started
    OperatingSystem.Create File    ${resultDir}/egate_trfStart_${run}.txt    ${output_egate}

Start Traffic TMO
    [Documentation]    [PRIVATE]    traffic_data_start dl
    [Arguments]   ${run}   ${ue_id}
    ${cmd1}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 dir=dl mbps=100
    ${cmd2}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 dir=dl mbps=100
    ${cmd3}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=3 dir=dl mbps=100
    ${cmd4}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=4 dir=dl mbps=100
    ${cmd5}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=5 dir=dl mbps=100
    ${cmd6}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=6 dir=dl mbps=100
    ${cmd7}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=7 dir=dl mbps=100
    ${cmd8}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=8 dir=dl mbps=100
    ${cmd9}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 dir=ul mbps=100
    ${allcmds}   Catenate  SEPARATOR=${\n}       ${cmd1}     ${cmd2}     ${cmd3}     ${cmd4}     ${cmd5}     ${cmd6}     ${cmd7}
    Log To Console    execute on wts without delay inbetween
    Log To Console    \n ${allcmds}
    ${output_egate}  ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${allcmds}
    ...    pass_regexp=DL TRF
    ...    return_output=True
    ...    alias=ap_egate
    Log To Console    -> dl traffic cmd started
    OperatingSystem.Create File    ${resultDir}/egate_trfStart_${run}.txt    ${output_egate}

Stop Traffic
    [Documentation]    [PRIVATE]    stop dl traffic trf_id2
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]     ${ue_id}
    ${cmd}    Set Variable  trf_data_stop ue=${ue_id} pdu=1 qfi=1
    Log To Console    execute on wts: ${cmd}
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate


Get UE NR Throughput Pusch And Pdsch
    [Documentation]    [PRIVATE]    get ue NR throughput pusch and pdsch
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]     ${ue_id}
    ${cmd}    set variable  ue_stats_nr id=${ue_id} scell=0-5 type=pdsch
    Log To Console    execute on wts:${cmd}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_throughput_pdsch.txt     ${output_egate}

    ${cmd1}    set variable  ue_stats_nr id=${ue_id} scell=0-5 type=pusch
    Log To Console    execute on wts:${cmd1}
    ${output_egate1}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd1}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_throughput_pusch.txt    ${output_egate1}


Release Pdu Session And Deregister
    [Documentation]    [PRIVATE]    release pdu session and deregister
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]     ${ue_id}
    UE PDU Session Release         ue_id=${ue_id}   pdu=1
    UE Deregister                  ue_id=${ue_id}
