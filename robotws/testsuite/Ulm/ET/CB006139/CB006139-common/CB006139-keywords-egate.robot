*** Settings ***
Documentation   This is a keyword file for CB006139 egate
...             Team: 'MN RAN RD VRF ULM 2'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

Delay
    [Documentation]    [PRIVATE]    delay
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${seconds}   ${reason}
    Log To Console    \n---delay of ${seconds}s to "${reason}"
    Run Keyword    Sleep   ${seconds}s   reason=${reason}


Remove Egate Console Logs
    [Documentation]    [PRIVATE]    remove egate console logs
    ...       :Autor: Sylvia Schneider
    Log To Console    remove in ${tl.core.dir_path} files egate_console* and egate.log*
    wts_ue.Kill WTS Services
    Run   rm ${tl.core.dir_path}/egate_console*
    Run   rm ${tl.core.dir_path}/egate.log*


Save Egate Logs
    [Documentation]    [PRIVATE]    save egate logs
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${save_dir}
    ute_wtssim.collect_egate_log_files
    ...    unzip=True
    ...    subdirectory=${save_dir}
    ...    alias=ap_egate


csi_override_testmode
    [Documentation]    [PRIVATE]    csi_override_testmode
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${profile_id}=2  ${cqi}=1   ${ri}=1
    ${cmd}     Set Variable
    ...   csi_override_testmode_nr profile_id=${profile_id} cqi_mode=fixed cqi=${cqi} ri_mode=fixed ri=${ri} pmi_mode=fixed pmi=0
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate

    ${cmd}     Set Variable
    ...   csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3 pmi_mode=fixed pmi=0
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate


csi_override_testmode_aa_b7
    [Documentation]    [PRIVATE]    Csi_override_testmode used in CB006139-AA-B7
    ...       :Autor: Yasir Mehmood
    ${cmd}     Set Variable   csi_override_testmode_nr profile_id=2 cqi_mode=fixed cqi=1 ri_mode=fixed ri=3 pmi_mode=fixed pmi=0
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate

    ${cmd}     Set Variable
    ...   csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3 pmi_mode=fixed pmi=0
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.Execute Egate Command
    ...    cmd=${cmd}
    ...    alias=ap_egate


Set trf_type For Pdu
    [Documentation]    [PRIVATE]    set trf_type for pdu
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${pdu_id}
    ${cmd}     Set Variable   set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal log_traffic_stats=off
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate


ue_change_location
    [Documentation]    [PRIVATE]    ue_change_location
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${cell}=6
    ${cmd}     Set Variable   ue_change_location id=${ue_id} enb=2 cell=${cell}
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate


Register UE
    [Documentation]    [PRIVATE]    register UE
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd}     Set Variable   ue_register id=${UE_id} nwslice=1
    ${check}   Set Variable   REGISTRATION COMPLETE from UE
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: "${check}"
    ute_wtssim.execute egate command and wait for data    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate


Start PDU Session
    [Documentation]    [PRIVATE]    start PDU
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd}    Set Variable  ue_pdu_session_setup pdu=1 ue=${UE_id} nwslice=1 gw=${UE_id}
    ${check}  Set Variable  Initial Context Setup Successful
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_pdu_setup_ue${ue_id}.txt    ${output_egate}


Start Dl Traffic trf_id1_2
    [Documentation]    [PRIVATE]    traffic_data_start trf_id1_2
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${run}   ${ue_id}=1
    ${cmd1}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 dir=dl mbps=175
    ${cmd2}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 dir=dl mbps=175
    ${allcmds}   Catenate  SEPARATOR=${\n}       ${cmd1}     ${cmd2}
    Log To Console    execute on wts without delay inbetween
    Log To Console    -> ${cmd1}
    Log To Console    -> ${cmd2}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${allcmds}
    ...    pass_regexp=DL CHANNEL
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_trfStart_${run}.txt    ${output_egate}


Start Dl Traffic trf_id2_3_4_5
    [Documentation]    [PRIVATE]    traffic_data_start trf_id2_3_4_5
    ...       :Autor: Sylvia Schneider
    FOR   ${trf_id}   IN   2   3
       ${cmd}    Set Variable  trf_data_start ue=1 pdu=1 qfi=1 trf_id=${trf_id} dir=dl mbps=175
       Log To Console    execute on wts: ${cmd}
       ${output_egate}  ute_wtssim.execute egate command and wait for data
       ...    cmd=${cmd}
       ...    return_output=True
       ...    alias=ap_egate
       Create File    ${resultDir}/egate_trfStart_id${trf_id}.txt    ${output_egate}
    END

    ${check}   Set Variable   PhysCellId:51. SCellIndex 1 activated successfully at airphone
    ${cmd_4_5}   Catenate  SEPARATOR=${\n}
    ...    trf_data_start ue=1 pdu=1 qfi=1 trf_id=4 dir=dl mbps=175
    ...    trf_data_start ue=1 pdu=1 qfi=1 trf_id=5 dir=dl mbps=175
    Log To Console    -> ${cmd_4_5}
    Log To Console    -> check: ${check}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd_4_5}
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_trfStart_id4_5.txt    ${output_egate}


Start Dl Traffic trf_id2_3_4_5_6 t6
    [Documentation]    [PRIVATE]    traffic_data_start trf_id2_3_4_5_6 in DL
    ...       :Autor: Yasir Mehmood
    FOR   ${trf_id}   IN   2   3  4  5  6
       ${cmd}    Set Variable  trf_data_start ue=1 pdu=1 qfi=1 trf_id=${trf_id} dir=dl mbps=175
       Log To Console    execute on wts ${cmd}
       ${output_egate}  ute_wtssim.execute egate command and wait for data
       ...    cmd=${cmd}
       ...    return_output=True
       ...    alias=ap_egate
       Create File    ${resultDir}/egate_trfStart_id${trf_id}.txt    ${output_egate}
    END


Start Dl Traffic trf_id
    [Documentation]    [PRIVATE]    traffic_data_start trf_id
    ...       :Autor: Yasir Mehmood
    [Arguments]   ${id}  ${mbps}  ${run}
    ${cmd}    Set Variable  trf_data_start ue=1 pdu=1 qfi=1 trf_id=${id} dir=dl mbps=${mbps}
    Log To Console    -> ${cmd}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=DL TRF
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_trfStart_id${id}_${mbps}mbps_${run}.txt    ${output_egate}


Start Dl Traffic trf_id1_1_2_3_4_5_6 t3 ${run}
    [Documentation]    [PRIVATE]    traffic_data_start trf_id_1_2_3_4_5_6 t3
    ...       :Autor: Sylvia Schneider
    FOR    ${trf_id}    IN   1  2  3  4  5  6
       ${check}   Set Variable   Started Downlink Internal traffic over UDP on Ue:2 UpfId:1 Pdu:1 Qfi:1 TrfId:${trf_id}
       ${cmd}     Set Variable   trf_data_start ue=2 pdu=1 qfi=1 trf_id=${trf_id} dir=dl mbps=175
       Log To Console    -> ${cmd}
       ${output_egate}  ute_wtssim.execute egate command and wait for data
       ...    cmd=${cmd}
       ...    pass_regexp=${check}
       ...    return_output=True
       ...    alias=ap_egate
       Delay    1   wait for traffic start
       Create File    ${resultDir}/egate_trfStart_t3_${run}_id${trf_id}.txt    ${output_egate}
    END


Start Dl Traffic For 8 trf_ids
    [Documentation]    [PRIVATE]    start dl traffic for 8 trf_ids
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=2   ${run}=${EMPTY}
    FOR    ${trf_id}    IN   1  2  3  4  5  6  7  8
       ${check}   Set Variable   Started Downlink Internal traffic over UDP on Ue:${ue_id} UpfId:1 Pdu:1 Qfi:1 TrfId:${trf_id}
       ${cmd}   Set Variable   trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=${trf_id} dir=dl mbps=175
       Log To Console    -> ${cmd}
       ${output_egate}  ute_wtssim.execute egate command and wait for data
       ...    cmd=${cmd}
       ...    pass_regexp=${check}
       ...    return_output=True
       ...    alias=ap_egate
       Delay    1   wait for traffic start
       Create File    ${resultDir}/egate_trfStart_UE${ue_id}_DL_id${trf_id}${run}.txt    ${output_egate}
    END


Start Dl Traffic For Several trf_ids
    [Documentation]    [PRIVATE]    start dl traffic for several trf_ids
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}  ${num_of_trfIds}  ${mbps}   ${run}
    ${loop_end}   Evaluate   ${num_of_trfIds}+1
    FOR    ${trf_id}    IN RANGE   1  ${loop_end}
       ${check}   Set Variable   Started Downlink Internal traffic over UDP on Ue:${ue_id} UpfId:1 Pdu:1 Qfi:1 TrfId:${trf_id}
       ${cmd}   Set Variable   trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=${trf_id} dir=dl mbps=${mbps}
       Log To Console    -> ${cmd}
       ${output_egate}  ute_wtssim.execute egate command and wait for data
       ...    cmd=${cmd}
       ...    pass_regexp=${check}
       ...    return_output=True
       ...    alias=ap_egate
       Delay    1   wait for traffic start
       Create File    ${resultDir}/egate_trfStart_UE${ue_id}_DL_id${trf_id}_run${run}.txt    ${output_egate}
    END


Start Dl Traffic trf_id_1
    [Documentation]    [PRIVATE]    traffic_data_start trf_id_1
    ...       :Autor: Sylvia Schneider
    ${check}   Set Variable   Started Downlink Internal traffic over UDP on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    ${cmd}     Set Variable   trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 dir=dl mbps=175
    Log To Console    -> ${cmd}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    Delay    1   wait for traffic start
    Create File    ${resultDir}/egate_trfStart_id1_run2.txt    ${output_egate}


Stop Dl Traffic
    [Documentation]    [PRIVATE]    stop all dl traffic
    ...       :Autor: Yasir Mehmood
    ${cmd}    Set Variable  trf_data_stop ue=1 pdu=1 qfi=1 dir=dl
    Log To Console    execute on wts ${cmd}
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate


Stop Dl Traffic trf_id2
    [Documentation]    [PRIVATE]    stop dl traffic trf_id2
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1
    ${cmd}    Set Variable  trf_data_stop ue=${ue_id} pdu=1 qfi=1 trf_id=2 dir=dl
    Log To Console    execute on wts: ${cmd}
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate


Stop All Traffic UE2
    [Documentation]    [PRIVATE]    stop all traffic UE2
    ...       :Autor: Sylvia Schneider
    ${cmd}    Set Variable   trf_data_stop ue=2 pdu=1 qfi=1
    ${check}  Set Variable   sCellToReleaseList
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: "${check}"
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    timeout=15
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate


Stop All DL Traffic UE2
    [Documentation]    [PRIVATE]    stop all DL traffic UE2
    ...       :Autor: Sylvia Schneider
    ${cmd}    Set Variable   trf_data_stop ue=2 pdu=1 qfi=1 dir=dl
    ${check}  Set Variable   sCellToReleaseList
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: "${check}"
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    timeout=15
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate


Stop All Traffic For UE No Check
    [Documentation]    [PRIVATE]    stop all traffic for UE no check
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${ue_id}
    ${cmd}    Set Variable   trf_data_stop ue=${ue_id} pdu=1 qfi=1
    Log To Console    execute on wts: ${cmd}
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate


Stop All DL Traffic UE${ue_id} No Check
    [Documentation]    [PRIVATE]    stop all DL traffic UE2 no check
    ...       :Autor: Sylvia Schneider
    ${cmd}    Set Variable   trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl
    Log To Console    execute on wts: ${cmd}
     ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate


Start Ul Traffic trf_id1
    [Documentation]    [PRIVATE]    start ul traffic trf_id1
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${ue_id}   ${mbps}    ${run}
    ${cmd}    Set Variable   trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 dir=ul mbps=${mbps}
    ${check}  Set Variable   Started Uplink Internal traffic over UDP on Ue:${ue_id}
    Log To Console    execute on wts ${cmd}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    timeout=20
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_trfStart_UL_UE${ue_id}_trf_id1_run${run}.txt    ${output_egate}


Start Upd Dl Traffic
    [Documentation]    [PRIVATE]    start upd dl traffic
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${trf_id}
    ${cmd}    Set Variable   trf_data_start ue=1 dir=dl trf_id=${trf_id} protocol=udp ack_mode=off cl_trf_stats=on mbps=175 pdu=1 qfi=1
    ${check}  Set Variable   Started Downlink Internal traffic over UDP on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:${trf_id}
    Log To Console    execute on wts: ${cmd}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_trfStart_id${trf_id}.txt    ${output_egate}
    Sleep   1s


Lower Udp Traffic To ${amount}mbps
    [Documentation]    [PRIVATE]    lower udp traffic to 60mbps
    ...       :Autor: Sylvia Schneider
    ${cmd}    Set Variable  trf_data_start ue=1 dir=dl trf_id=1 protocol=udp ack_mode=off cl_trf_stats=on mbps=${amount} pdu=1 qfi=1
    Log To Console    execute on wts: ${cmd}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_trfLower.txt    ${output_egate}
    Sleep   1s


Lower Dl Traffic
    [Documentation]    [PRIVATE]    lower dl traffic
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${ue_id}   ${trf_id}   ${mbps}
    ${cmd}    Set Variable  trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=${trf_id} dir=dl mbps=${mbps}
    Log To Console    execute on wts: ${cmd}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_trfLower_ue${ue_id}_trf_id${trf_id}.txt    ${output_egate}
    Sleep   1s


Lower Dl Traffic For Several trf_ids
    [Documentation]    [PRIVATE]    lower dl traffic for 6 trf_ids
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}  ${num_of_trfIds}  ${mbps}  ${run}
    ${loop_end}   Evaluate   ${num_of_trfIds}+1
    FOR    ${trf_id}    IN RANGE   1  ${loop_end}
       ${check}   Set Variable   Started Downlink Internal traffic over UDP on Ue:${ue_id} UpfId:1 Pdu:1 Qfi:1 TrfId:${trf_id}
       ${cmd}   Set Variable   trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=${trf_id} dir=dl mbps=${mbps}
       Delay    1   wait for lower traffic start
       Log To Console    -> ${cmd}
       ${output_egate}  ute_wtssim.execute egate command and wait for data
       ...    cmd=${cmd}
       ...    pass_regexp=${check}
       ...    return_output=True
       ...    alias=ap_egate
       Create File    ${resultDir}/egate_trfLower_UE${ue_id}_DL_id${trf_id}_${run}.txt    ${output_egate}
    END


Get Ue NR Throughput Pusch And Pdsch
    [Documentation]    [PRIVATE]    get ue NR throughput pusch and pdsch
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${run}
    ${cmd}    Set Variable  ue_stats_nr id=${ue_id} scell=0-5 type=pusch,pdsch
    Log To Console    execute on wts:${cmd}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_throughput_pusch_pdsch_ue${ue_id}_${run}.txt    ${output_egate}


Get Ue NR Throughput Pusch
    [Documentation]    [PRIVATE]    get ue NR throughput pusch
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${run}
    ${cmd}    Set Variable  ue_stats_nr id=${ue_id} scell=0-5 type=pusch
    Log To Console    execute on wts:${cmd}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_throughput_pusch_ue${ue_id}_${run}.txt    ${output_egate}


Get Ue NR Throughput Pdsch
    [Documentation]    [PRIVATE]    get ue NR throughput pdsch
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${run}
    ${cmd}    Set Variable  ue_stats_nr id=${ue_id} scell=0-5 type=pdsch
    Log To Console    execute on wts:${cmd}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_throughput_pdsch_ue${ue_id}_${run}.txt    ${output_egate}


Get Ue NR Separate Throughput Pusch And Pdsch
    [Documentation]    [PRIVATE]    get ue NR separate throughput pusch and pdsch
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${run}
    Get Ue NR Throughput Pusch    ue_id=${ue_id}   run=${run}
    Get Ue NR Throughput Pdsch    ue_id=${ue_id}   run=${run}


Get Ue NR Separate Throughput Pdsch And Pusch
    [Documentation]    [PRIVATE]    get ue NR separate throughput pdsch and pusch
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${run}
    Get Ue NR Throughput Pdsch    ue_id=${ue_id}   run=${run}
    Get Ue NR Throughput Pusch    ue_id=${ue_id}   run=${run}


Testmode Activate Profile
    [Documentation]    [PRIVATE]    testmode activate profile
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${profile_id}  ${scell}   ${check}   ${run}
    ${cmd}    Set Variable  ue_testmode_set_nr id=${ue_id} scell=${scell} testmode=csi_override action=activate profile_id=${profile_id}
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_testmode_profile_ue${ue_id}_scell${scell}_${run}.txt    ${output_egate}


Testmode Activate Profile aa_t6
    [Documentation]    [PRIVATE]    testmode activate profile
    ...       :Autor: Yasir Mehmood
    [Arguments]     ${ue_id}   ${scell_id}  ${profile_id}  ${check}   ${run}
    ${cmd}    Set Variable  ue_testmode_set_nr id=${ue_id} scell=${scell_id} testmode=csi_override action=activate profile_id=${profile_id}
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    timeout=20
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_testmode_profile_ue${ue_id}_scell${scell_id}_${run}.txt    ${output_egate}


Testmode Activate Profile No Check
    [Documentation]    [PRIVATE]    testmode activate profile nocheck
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${scell}  ${profile_id}
    ${cmd}    Set Variable  ue_testmode_set_nr id=${ue_id} scell=${scell} testmode=csi_override action=activate profile_id=${profile_id}
    Log To Console    execute on wts:${cmd}
    ${output_egate}  ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate


Testmode Activate Profile No Check aa_t6
    [Documentation]    [PRIVATE]    testmode activate profile nocheck
    ...       :Autor: Yasir Mehmood
    [Arguments]     ${ue_id}   ${scell_id}  ${profile_id}
    ${cmd}    Set Variable  ue_testmode_set_nr id=${ue_id} scell=${scell_id} testmode=csi_override action=activate profile_id=${profile_id}
    Log To Console    execute on wts:${cmd}
    ${output_egate}  ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate


Testmode Activate Profile With Extended Timeout
    [Documentation]    [PRIVATE]    testmode activate profile with extended timeout
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${scell}   ${profile_id}  ${check}  ${timeout}  ${run}
    ${cmd}    Set Variable  ue_testmode_set_nr id=${ue_id} scell=${scell} testmode=csi_override action=activate profile_id=${profile_id}
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    timeout=${timeout}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_extend_testmode_profile_ue${ue_id}_run${run}.txt    ${output_egate}


Release Pdu Session And Deregister
    [Documentation]    [PRIVATE]    release pdu session and deregister
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    UE PDU Session Release And Save Output        ue_id=${ue_id}   pdu=1
    wts_ue.UE Deregister                  ue_id=${ue_id}


UE PDU Session Release And Save Output
    [Documentation]
    ...
    ...    | pdu            | PDU Session ID                    |
    ...    | ue_id          | Specified UE ID                   |
    ...    | pass_regexp    | Successfully released PDU Session |
    ...
    [Arguments]   ${ue_id}=1   ${pdu}=1   ${pass_regexp}=Successfully released PDU Session
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_pdu_session_release ue=${ue_id} pdu=${pdu} by=amf
    ...    return_output=True
    ...    pass_regexp=${pass_regexp}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_pdu_release_ue${ue_id}.txt    ${output_egate}
    Log To Console  ${\n}UE${ue_id} PDU${pdu} session release is successful


UE PDU Session Release By UE
    [Documentation]
    ...
    ...    | pdu            | PDU Session ID                    |
    ...    | ue_id          | Specified UE ID                   |
    ...    | pass_regexp    | Successfully released PDU Session |
    ...
    [Arguments]   ${ue_id}=1   ${pdu}=1   ${pass_regexp}=Successfully released PDU Session
    Send Egate Command And Verify Output   cmd=ue_pdu_session_release ue=${ue_id} pdu=${pdu} by=ue
    ...   pass_regexp=${pass_regexp}
    Log   ${\n}UE${ue_id} PDU${pdu} session release is successful   console=${P_console}


Start DL Traffic To Activate Scell 1 And 2 And 3
    [Documentation]    [PRIVATE]    Start DL Traffic To Activate Scell 1 And 2 And 3
    ...       :Autor: Sylvia Schneider
    Start DL Traffic For Several trf_ids   ue_id=2  num_of_trfIds=3  mbps=175  run=1


Start DL Traffic For CSI-RS downgrade
    [Documentation]    [PRIVATE]    Start DL Traffic For CSI-RS downgrade
    ...       :Autor: Sylvia Schneider
    Start DL Traffic For Several trf_ids   ue_id=2  num_of_trfIds=5  mbps=175  run=2


Start DL Traffic To Activate Scell With MIMO Reconfiguration
    [Documentation]    [PRIVATE]    Start DL Traffic To Activate Scell With MIMO Reconfiguration
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${run}
    Start DL Traffic For Several trf_ids   ue_id=1  num_of_trfIds=7  mbps=175  run=${run}


Stop Traffic And Release Pdu And Deregister UE${ue_id}
    [Documentation]    [PRIVATE]    Stop Traffic And Release Pdu And Deregister
    ...       :Autor: Sylvia Schneider
    stop all traffic for UE no check     ue_id=${ue_id}
    UE PDU Session Release By UE         ue_id=${ue_id}   pdu=1
    UE Deregister                        ue_id=${ue_id}


Display Measurements
    [Documentation]    [PRIVATE]    Display Measurements
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${run}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_meas_disp id=1
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_meas_disp_run${run}.txt    ${output_egate}
    Log To Console  meas disp of UE saved in egate_meas_disp_run${run}.txt


Display Cell Info
    [Documentation]    [PRIVATE]    Display Cell Info
    ...       :Autor: Sylvia Schneider
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_disp id=1 type=cell
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_cell_info.txt    ${output_egate}
    Log To Console  cell info saved in egate_cell_info.txt


Get Measurement Id
    [Documentation]    [PRIVATE]    Get Measurement Id
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${meas_file_id}    ${ObjectId}    ${ReportCfgId}
    ${contents}    Get File           ${resultDir}/egate_meas_disp_run${meas_file_id}.txt
    @{parts}   Split String   ${contents}    === UE1 NR MEASUREMENT IDENTITIES:
    Create file    ${resultDir}/meas_only_${meas_file_id}.txt   ${parts}[1]
    ${line_meas}    Grep File   ${resultDir}/meas_only_${meas_file_id}.txt    ${ObjectId}${SPACE}*${ReportCfgId}
    ${meas_id}      Get Regexp Matches    ${line_meas}   ^[0-9]*
    RETURN   ${meas_id}[0]
