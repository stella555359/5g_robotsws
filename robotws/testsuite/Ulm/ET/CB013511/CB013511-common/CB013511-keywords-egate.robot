*** Settings ***
Documentation   This is a keyword file for CB013511 egate
...             Team: 'MI MN RAN RD VRF ULM 4'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Library        OperatingSystem

Library        ute_wtssim

Resource        ../../../resources/Common/wts_ue.robot


*** Keywords ***

Delay
    [Documentation]    [PRIVATE]    delay
    ...       :Author: Sylvia Schneider
    [Arguments]   ${seconds}   ${reason}
    Log To Console    \n---delay of ${seconds}s to "${reason}"
    Sleep   ${seconds}s   reason=${reason}


Remove Egate Console Logs
    [Documentation]    [PRIVATE]    remove egate console logs
    ...       :Author: Sylvia Schneider
    Log To Console    remove in ${tl.core.dir_path} files egate_console* and egate.log*
    wts_ue.Kill WTS Services
    OperatingSystem.Run   rm ${tl.core.dir_path}/egate_console*
    OperatingSystem.Run   rm ${tl.core.dir_path}/egate.log*


Save Egate Logs
    [Documentation]    [PRIVATE]    save egate logs
    ...       :Author: Sylvia Schneider
    [Arguments]     ${save_dir}
    ute_wtssim.Collect Egate Log Files
    ...    unzip=True
    ...    subdirectory=${save_dir}
    ...    alias=ap_egate


Change Location
    [Documentation]    [PRIVATE]    Change Location
    ...       :Author: Sylvia Schneider
    [Arguments]   ${ue_id}   ${enb}   ${cell}
    ${cmd}   Set Variable   ue_change_location id=${ue_id} enb=${enb} cell=${cell}
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.Execute Egate Command
    ...    cmd=${cmd}
    ...    alias=ap_egate


Attach UE 111 On Gnb Cell 2
    [Documentation]    [PRIVATE]    Attach UE 111 On Gnb Cell 2
    ...       :Author: Sylvia Schneider
    Change Location   ue_id=111   enb=1    cell=2
    wts_ue.Attach UE To LTE    ue_id=111
    Sleep    2s


Attach UE 111 On Gnb Cell 1
    [Documentation]    [PRIVATE]    Attach UE 111 On Gnb Cell 1
    ...       :Author: Sylvia Schneider
    wts_ue.Attach UE To LTE    ue_id=111
    Sleep    2s


Trigger Sgnb Addition
    [Documentation]    [PRIVATE]    Trigger Sgnb Addition
    ...       :Author: Sylvia Schneider
    [Arguments]   ${ue_id}
    ${cmd}     Set Variable    enb_ue_dc_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ${check}   Set Variable    Sending SgNB Modification Confirm
    Log To Console   execute on wts: ${cmd}
    Log To Console   check: ${check}
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    OperatingSystem.Create File    ${resultDir}/sgNB_add.txt    ${output_egate}


Start DL And UL Traffic
    [Documentation]    [PRIVATE]    Start DL And UL Traffic
    ...       :Author: Sylvia Schneider
    [Arguments]   ${ue_id}
    Start DL Traffic    ${ue_id}
    Start UL Traffic    ${ue_id}


Start DL Traffic
    [Documentation]    [PRIVATE]    Start DL Traffic
    ...       :Author: Sylvia Schneider
    [Arguments]   ${ue_id}
    ${cmd}     Set Variable   trf_data_start ue=${ue_id} id=2 dir=dl trf_id=1 mbps=2
    Log To Console    -> ${cmd}
    ${output_egate}  ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Delay    1   wait for traffic start


Start UL Traffic
    [Documentation]    [PRIVATE]    Start UL Traffic
    ...       :Author: Sylvia Schneider
    [Arguments]   ${ue_id}
    ${cmd}     Set Variable   trf_data_start ue=${ue_id} id=2 dir=ul trf_id=1 mbps=2
    Log To Console    -> ${cmd}
    ${output_egate}  ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Delay    1   wait for traffic start


Display Measurement Config
    [Documentation]    [PRIVATE]    Display Measurement Config from eNB
    ...       :Author: Sylvia Schneider
    [Arguments]     ${ue_id}   ${action}
    ${cmd}     Set Variable    ue_meas_cfg_disp id=${ue_id}
    Log To Console   execute on wts: ${cmd}
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    OperatingSystem.Create File    ${resultDir}/disp_meas_config_UE${ue_id}_${action}.txt    ${output_egate}


Allow Endc
    [Documentation]    [PRIVATE]    Allow Endc
    ...       :Author: Sylvia Schneider
    ${cmd}     Set Variable    enb_cell_param id=1 enb=1 allow_endc=on
    Log To Console   execute on wts: ${cmd}
    ute_wtssim.Execute Egate Command
    ...    cmd=${cmd}
    ...    alias=ap_egate


Set Candidate Cell
    [Documentation]    [PRIVATE]    Set Candidate Cell
    ...       :Author: Sylvia Schneider
    [Arguments]     ${ue_id}   ${candidate_cells_mn_hex_for_menb_ho}
    ${cmd}     Set Variable    ue_enb_endc_param id=${ue_id} candidate_cells_mn_hex_for_menb_ho=${candidate_cells_mn_hex_for_menb_ho}
    Log To Console   execute on wts: ${cmd}
    ute_wtssim.Execute Egate Command
    ...    cmd=${cmd}
    ...    alias=ap_egate


Start Intra-MeNB HO With PSCell Change
    [Documentation]    [PRIVATE]     Start Intra-MeNB HO With PSCell Change
    ...       :Author: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd}     Set Variable    ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=1 cell=1
    ${check}   Set Variable    SgNBModificationConfirm sent to ENB-2
    Log To Console   execute on wts: ${cmd}
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    OperatingSystem.Create File    ${resultDir}/intra_MeNB_HO.txt    ${output_egate}


Start Intra-DU HO With PSCell Change
    [Documentation]    [PRIVATE]     Start Intra-DU HO With PSCell Change
    ...       :Author: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd}     Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=19 phycell_id=53 nrsrp_nr=30
    ${check}   Set Variable    SgNBModificationConfirm sent to ENB-2
    Log To Console   execute on wts: ${cmd}
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    OperatingSystem.Create File    ${resultDir}/intra_DU_HO.txt    ${output_egate}


Start ENB Handover With PCell Change
    [Documentation]    [PRIVATE]     Start ENB Handover With PCell Change
    ...       :Author: Sylvia Schneider
    [Arguments]     ${ue_id}
    Allow Endc
    Set Candidate Cell   ue_id=${ue_id}   candidate_cells_mn_hex_for_menb_ho=091EA57821C0
    Start Intra-MeNB HO With PSCell Change   ue_id=${ue_id}


Get Bearer Statistics In One Direction
    [Documentation]    [PRIVATE]    Get Bearer Statistics In One Direction
    ...       :Author: Sylvia Schneider
    [Arguments]     ${ue_id}    ${direction}
    ${wts_cmd}  Set Variable
    ...      bearer_stats ue=${ue_id} dir=${direction} type=l3 scell=0 format=short size_unit=auto trf_id=1 id=2
    Log To Console    execute on wts: ${wts_cmd}
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${wts_cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Sleep     2s   wait for all data sent
    OperatingSystem.Create File    ${resultDir}/egate_ue${ue_id}_${direction}.txt    ${output_egate}


Get Ue NR Throughput Pusch
    [Documentation]    [PRIVATE]    get ue NR throughput pusch
    ...       :Author: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd}    Set Variable  ue_stats_nr id=${ue_id} scell=8 type=pusch
    Log To Console    execute on wts: ${cmd}
    ${output_egate}  ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    OperatingSystem.Create File    ${resultDir}/egate_throughput_pusch_ue${ue_id}.txt    ${output_egate}


Get Ue NR Throughput Pdsch
    [Documentation]    [PRIVATE]    get ue NR throughput pdsch
    ...       :Author: Sylvia Schneider
    [Arguments]     ${ue_id}
    ${cmd}    Set Variable  ue_stats_nr id=${ue_id} scell=8 type=pdsch
    Log To Console    execute on wts: ${cmd}
    ${output_egate}  ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    OperatingSystem.Create File    ${resultDir}/egate_throughput_pdsch_ue${ue_id}.txt    ${output_egate}


Get Ue NR Separate Throughput Pdsch And Pusch
    [Documentation]    [PRIVATE]    get ue NR separate throughput pdsch and pusch
    ...       :Author: Sylvia Schneider
    [Arguments]     ${ue_id}
    Get Ue NR Throughput Pdsch    ue_id=${ue_id}
    Get Ue NR Throughput Pusch    ue_id=${ue_id}


Start X2 Link To Enb-3
    [Documentation]    [PRIVATE]    Start X2 Link To Enb-3
    ...       :Author: Sylvia Schneider
    ${cmd}     Set Variable  enb_x2_link_up enb=3 target=2
    ${check}   Set Variable  X2AP Link .* is up
    Log To Console    execute on wts: ${cmd}
    ${output_egate}  ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate

