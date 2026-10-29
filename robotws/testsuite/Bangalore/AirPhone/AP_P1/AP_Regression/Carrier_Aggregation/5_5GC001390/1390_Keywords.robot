*** Settings ***
Documentation   Contains keywords related to 1390 feature
Resource        ../CA_Common_Keywords.robot

*** Variables ***
${WTS_CFG_PATH}               ${CURDIR}/cfg
@{FR1390_Counter_List}        M55316C09000    M55316C09001
@{FR2329_Counter_List}        M55118C05506    M55316C09000    M55310C01006    M55316C09001    M55118C06501
@{nrrel_profile_id}           11     12     13     14
${profile_id}                 1
${target_gnb}                 2
${target_cells}               2
${bearer_id}                  2
${scell_index_sa}             1
${scell_index_nsa}            9
${XnBased_NSA_A2_Carr_Freq}   126530
${NGBased_NSA_A2_Carr_Freq}   518910
${interrat_gnb_delta_json}    ${WTS_CFG_PATH}/InterRAT_1390_delta.json
${plmn}                       311:489
${anr_ir_gnb_delta_json}      ${WTS_CFG_PATH}/InterRAT_ANR_1390_delta.json

*** Keywords ***
Validate Pcell Throughput For Non CA Capable UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}
    FOR    ${ue_id}    IN    @{UE_List}
        Log To Console    Going To Check Throughput for Non CA Capable SA UE: ${ue_id}
        ${pcell_tput}    Cell Specific Throughput Validation    ue_id=${ue_id}    scell=0
        ${ul_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=ul    pdu_id=${ue_id}
        ${dl_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=dl    pdu_id=${ue_id}
        Total CA UE Throughput Verification   ${pcell_tput}    ${dl_tput}    ${expected_dl_tput}
        Run keyword And Continue On Failure    Average Throughput Should Be as Expected    ${ul_tput}
        ...    ${expected_ul_tput}
    END

Validate Pcell and Scell Throughput For SA UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}    ${Scell_Id}
    FOR    ${ue_id}    IN    @{UE_List}
        Log To Console    Going To Check Throughput for SA UE: ${ue_id}
        ${pcell_tput}    Cell Specific Throughput Validation    ue_id=${ue_id}    scell=${Scell_Id}[0]
        ${scell_tput}    Cell Specific Throughput Validation    ue_id=${ue_id}    scell=${Scell_Id}[1]
        ${total_tput}    Evaluate    float(${pcell_tput})+float(${scell_tput})
        ${ul_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=ul    pdu_id=${ue_id}
        ${dl_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=dl    pdu_id=${ue_id}
        Total CA UE Throughput Verification   ${total_tput}    ${dl_tput}    ${expected_dl_tput}
        Run keyword And Continue On Failure    Average Throughput Should Be as Expected    ${ul_tput}
        ...    ${expected_ul_tput}
    END

Validate Pcell and Scell Throughput For NSA UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}    ${Scell_Id}
    FOR    ${ue_id}    IN    @{UE_List}
        Log To Console    Going to check Throughput for NSA UE: ${ue_id}
        ${pcell_tput}    Cell Specific Throughput Validation    ue_id=${ue_id}    scell=${Scell_Id}[0]
        ${scell_tput}    Cell Specific Throughput Validation    ue_id=${ue_id}    scell=${Scell_Id}[1]
        ${total_tput}    Evaluate    float(${pcell_tput})+float(${scell_tput})
        ${ul_tput}    Get Average Throughput from Bearer Stats For NSA    ue_id=${ue_id}    dir=ul
        ${dl_tput}    Get Average Throughput from Bearer Stats For NSA    ue_id=${ue_id}    dir=dl
        Total CA UE Throughput Verification   ${total_tput}    ${dl_tput}    ${expected_dl_tput}
        Run keyword And Continue On Failure    Average Throughput Should Be as Expected    ${ul_tput}
        ...    ${expected_ul_tput}
    END

Perform UE Register and Start Traffic For SA Non CA Capable UEs
    [Arguments]    ${sa_ue_list}    ${uplink_tput}    ${downlink_tput}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Run Keyword And Ignore Error    Check pcap files in gNB
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=${ue_id}    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=${ue_id}    gw_id=${ue_id}    nwslice=1
        Log To Console    Going To Start Traffic for SA Non CA Capable UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=${ue_id}    protocol=udp    mbps=${uplink_tput}
        Start Traffic    ue_id=${ue_id}    dir=dl    pdu=${ue_id}    protocol=udp    mbps=${downlink_tput}
        Run Keyword And Ignore Error    Check pcap files in gNB
    END

Perform UE Register and Start Traffic For SA UEs
    [Arguments]    ${sa_ue_list}    ${uplink_tput}=${ul_tput}    ${downlink_tput}=${dl_tput}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Run Keyword And Ignore Error    Check pcap files in gNB
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Validate Scell Regsitration
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=${ue_id}    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=${ue_id}    gw_id=${ue_id}    nwslice=1
        Log To Console    Going To Start Traffic for SA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=${ue_id}    protocol=udp    mbps=${uplink_tput}
        Run Keyword And Ignore Error    Check pcap files in gNB
        Log To Console    Going To Check Scell Activation For SA UE: ${ue_id}
        Start Traffic With Regex Check    ue_id=${ue_id}    dir=dl
        ...    pass_regex=SCellIndex \\d+ activated successfully    pdu=${ue_id}    protocol=udp    mbps=${downlink_tput}
        Run Keyword And Ignore Error    Check pcap files in gNB
    END

Perform UE Attach and Start Traffic For NSA UEs
    [Arguments]    ${nsa_ue_list}    ${uplink_tput}=${ul_tput}    ${downlink_tput}=${dl_tput}
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        UE Attach    ue_id=${ue_id}    profile_id=${profile_id}
        Validate Scell Regsitration
        SGNB Addition For Bearer    ue_id=${ue_id}    target_gnb=${target_gnb}    target_cells=${target_cells}
        ...    bearer=${bearer_id}
        Log To Console    Going To Start Traffic for NSA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    id=${bearer_id}    mbps=${uplink_tput}
        Log To Console    Going To Check Scell Activation For SA UE: ${ue_id}
        Start Traffic With Regex Check    ue_id=${ue_id}    dir=dl
        ...    pass_regex=SCellIndex \\d+ activated successfully    id=${bearer_id}    mbps=${downlink_tput}
        Run Keyword And Ignore Error    Check pcap files in gNB
    END

Perform Stop Traffic and Detach SA Non CA Capable UEs
    [Arguments]    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Log To Console    Going To Stop Traffic for SA Non CA Capable UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}    pdu=${ue_id}    dir=ul
        Stop UE Traffic    ue_id=${ue_id}    pdu=${ue_id}    dir=dl
        Ensure UE PDU Session Release Is Successful    ue_id=${ue_id}    pdu_id=${ue_id}
        Ensure UE Deregister Is Successful    ue_id=${ue_id}    ue_deregister_type=switch_off    by=ue
        Run Keyword And Ignore Error    Check pcap files in gNB
    END

Perform Stop Traffic and Detach SA UEs
    [Arguments]    ${sa_ue_list}    ${anr_ir}=False
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Log To Console    Going To Stop Traffic for SA UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}    pdu=${ue_id}    dir=ul
        Log To Console    Going To Check Scell Dectivation For SA UE: ${ue_id}
        Run keyword if    ${anr_ir}    Stop UE Traffic    ue_id=${ue_id}    pdu=${ue_id}    dir=dl
        ...   ELSE    Stop UE Traffic With Regex Check    ue_id=${ue_id}    pdu=${ue_id}   dir=dl
        ...    pass_regex=SCellIndex \\d+ deactivated successfully
        Ensure UE PDU Session Release Is Successful    ue_id=${ue_id}    pdu_id=${ue_id}
        run keyword if    $anr_ir == 'False'    Ensure UE Deregister Is Successful    ue_id=${ue_id}    ue_deregister_type=switch_off    by=ue
        ...   ELSE
        ...   Ensure UE Deregister Is Successful    ue_id=${ue_id}    pass_regexp=UE${ue_id}: detached    ue_deregister_type=switch_off    by=ue
        Run Keyword And Ignore Error    Check pcap files in gNB
    END

Perform Stop Traffic and Detach NSA UEs
    [Arguments]    ${nsa_ue_list}    ${bearer_id}=2
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        Log To Console    Going To Stop Traffic for NSA UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}    dir=ul
        Log To Console    Going To Check Scell Dectivation For NSA UE: ${ue_id}
        Stop UE Traffic With Regex Check    ue_id=${ue_id}    dir=dl
        ...    pass_regex=SCellIndex \\d+ deactivated successfully
        Release ENDC Bearer    ue_id=${ue_id}    bearer=${bearer_id}    cause=MISC_CauseMisc_unspecified
        UE Detach    ue_id=${ue_id}
        Run Keyword And Ignore Error    Check pcap files in gNB
    END

Trigger Intrafreq SA handover from Real gNB to Sim gNB
    [Arguments]    ${ue_id_list}
    log to console    SA forward handover from Real gNB cell2 to simulator gNBcell1 ...
    FOR    ${ue_id}    IN    @{ue_id_list}
        ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=PATH_SWITCH_REQUEST_ACK Received    carrier_frequency=127450
        ...    srsrp_nr=10    srsrq_nr=5     ssinr_nr=10    phycell_id=57    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
        Log To Console    Validating SA forward handover...
        Validate success prints from command output    ${output}
        ...    pass_regex=*UE${ue_id}: Inter-eNB handover from EXT_ENB-2.2 to ENB-22.1 performed*
        Validate success prints from command output    ${output}    pass_regex=*PATH_SWITCH_REQUEST_ACK Received*
    END
    sleep    60s   reason=To stabilise traffic txput

Trigger Intrafreq NSA handover from Real gNB to Sim gNB
    [Arguments]    ${ue_id_list}
    log to console    NSA forward handover from Real gNB cell2 to simulator gNBcell1 ...
    FOR    ${ue_id}    IN    @{ue_id_list}
        ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Bearer-type change from MCG to SCG-split is successful
        ...    carrier_frequency=127450    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=60    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
        Log To Console    Validating NSA forward handover...
        Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Sending SgNB Change Confirm*
        Validate success prints from command output    ${output}    pass_regex=*Bearer-type change from MCG to SCG-split is successful*
    END
    sleep    60s    reason=To stabilise traffic txput

Trigger Intrafreq SA handover from Sim gNB to Real gNB
    [Arguments]    ${ue_id}     ${scell_index}=${scell_index_sa}
    log to console    SA reverse handover from simulator gNB cell1 to real gNB cell2
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex \\d+ activated successfully    carrier_frequency=127450
    ...    srsrp_nr=11    srsrq_nr=11    ssinr_nr=10    phycell_id=51    nrsrp_nr=30    nrsrq_nr=30
    Log To Console    Validating SA reverse handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: CTRL_RACH_COMPLETE Received*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-22.1 to EXT_ENB-2.2 performed*
    Validate success prints from command output    ${output}    pass_regex=*Received PATH SWITCH REQUEST from GNB-2*
    Validate success prints from command output    ${output}    pass_regex=*SCellIndex ${scell_index} activated successfully*
    sleep    60s   reason=To stabilise traffic txput

Trigger Intrafreq NSA handover from Sim gNB to Real gNB
    [Arguments]    ${history_info_id}    ${action}    ${ue_id}     ${scell_index}=${scell_index_nsa}
    log to console    NSA reverse handover from simulator gNB cell1 to real gNB cell2
    Update UE History Information lists    ${history_info_id}    ${action}
    Update UE parameters for eNB    id=${ue_id}     ue_history_list=${history_info_id}
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex \\d+ activated successfully    carrier_frequency=127450
    ...    srsrp_nr=11    srsrq_nr=11    phycell_id=51    nrsrp_nr=30    nrsrq_nr=30
    Log To Console    Validating NSA reverse handover...
    Validate success prints from command output    ${output}    pass_regex=*CTRL_ADD_MOD_RB received for UeId ${ue_id}*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Sending SgNB Change Confirm*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: === Inter Sgnb Handover is successful ===*
    Validate success prints from command output    ${output}    pass_regex=*SCellIndex ${scell_index} activated successfully*
    sleep    10s   reason=To stabilise traffic txput

Trigger Interfreq SA handover from Real gNB to Sim gNB
    [Arguments]    ${ue_id}
    log to console    SA forward handover from Real gNB cell2 to simulator gNBcell1 ...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=127450    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=PATH_SWITCH_REQUEST_ACK Received    carrier_frequency=126380
    ...    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=58    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Inter-eNB handover from EXT_ENB-2.2 to ENB-23.1 performed*
    Validate success prints from command output    ${output}    pass_regex=*PATH_SWITCH_REQUEST_ACK Received*
    sleep    60s   reason=To stabilise traffic txput

Trigger Interfreq NSA handover from Real gNB to Sim gNB
    [Arguments]    ${ue_id}
    log to console    NSA forward handover from Real gNB cell2 to simulator gNBcell1 ...
    Update UE parameters for eNB    id=${ue_id}    drx_config=off    measurement_gap=gp0:20
    ...    gap_trigger=gnb_triggered    mgta=ms0    gap_purpose=perUE
    ${output}    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=rrcConnectionReconfigurationComplete    carrier_frequency=127450
    ...    srsrp_nr=30    srsrq_nr=30    rs_type=ssb
    Validate success prints from command output    ${output}    pass_regex=*gapOffset gp0 : 20*
    Update UE parameters for eNB    id=${ue_id}     measurement_gap=off
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Bearer-type change from MCG to SCG-split is successful
    ...    carrier_frequency=126380    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=61    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating NSA forward handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Sending SgNB Change Confirm*
    Validate success prints from command output    ${output}    pass_regex=*Bearer-type change from MCG to SCG-split is successful*
    sleep    60s   reason=To stabilise traffic txput

Trigger Interfreq SA handover from Sim gNB to Real gNB
    [Arguments]    ${ue_id}    ${scell_index}=${scell_index_sa}
    log to console    SA reverse handover from simulator gNBcell1 to Real gNB cell2...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=126530    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex \\d+ activated successfully
    ...    carrier_frequency=127450    srsrp_nr=11    srsrq_nr=11    phycell_id=51    nrsrp_nr=30    nrsrq_nr=30
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: CTRL_RACH_COMPLETE Received*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-23.1 to EXT_ENB-2.2 performed*
    Validate success prints from command output    ${output}    pass_regex=*Received PATH SWITCH REQUEST from GNB-2*
    Validate success prints from command output    ${output}    pass_regex=*SCellIndex ${scell_index} activated successfully*
    sleep    60s   reason=To stabilise traffic txput

Trigger Interfreq NSA handover from Sim gNB to Real gNB
    [Arguments]    ${ue_id}     ${scell_index}=${scell_index_nsa}    ${carrier_freq_A2}=${XnBased_NSA_A2_Carr_Freq}
    log to console    NSA reverse handover from simulator gNBcell1 to Real gNB cell2...
    Update UE History Information     id=2    cell_type=large    nrcgi=311:489|0x07
    ...    gnb_id=25    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${ue_id}
    Update UE parameters for eNB    id=${ue_id}     drx_config=off    measurement_gap=gp0:20     gap_trigger=gnb_triggered
    ...    mgta=ms0    gap_purpose=perUE
    ${output}    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=rrcConnectionReconfigurationComplete
    ...    carrier_frequency=${carrier_freq_A2}    srsrp_nr=7    srsrq_nr=7
    Validate success prints from command output    ${output}    pass_regex=*gapOffset 0*
    Validate success prints from command output    ${output}    pass_regex=*mgrp ms20*
    Update UE parameters for eNB    id=${ue_id}     measurement_gap=off
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex \\d+ activated successfully
    ...    carrier_frequency=127450     srsrp_nr=11    srsrq_nr=11    phycell_id=51    nrsrp_nr=30    nrsrq_nr=30
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: === Inter Sgnb Handover is successful*
    Validate success prints from command output    ${output}    pass_regex=*SCellIndex ${scell_index} activated successfully*
    sleep    60s   reason=To stabilise traffic txput

Update Gnb with NGBasedHO configuration for 5GC001390
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    ${NRCELL_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=2
    set test variable    ${NRCELL_DISTNAME}
    1390_Keywords.Get original params from gnB
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{NgHo_Inter_Intra_params}
    FOR    ${nrrel_id}    IN    @{nrrel_profile_id}
         delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}/NRREL-${nrrel_id}    &{nrrel_params}
    END
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait for gNB To Be Ready

Update WTS config file for 5GC001390
    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    wts_conf.modify    command=set_gnb id=2 type=external    modification=gnb_id=0x01
    wts_conf.modify    command=gnb_param id=22   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.modify    command=gnb_param id=23   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.modify    command=gnb_param id=24   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.modify    command=gnb_param id=25   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${testlog_path}

Get original params from gnB
    ${ng_ho_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${NgHo_feature_param}     ${NRBTS_DISTNAME}
    &{nrrel_dict}     create dictionary
    FOR    ${nrrel_id}    IN    @{nrrel_profile_id}
         ${nrrel_distname}    set variable    ${NRCELL_DISTNAME}/NRREL-${nrrel_id}
         ${nrrel_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${nrrel_params}    ${nrrel_distname}
         set to dictionary    ${nrrel_dict}    ${nrrel_distname}=${nrrel_param}
    END
    set test variable    ${ng_ho_param}
    set test variable    ${nrrel_dict}

Get Revert Delta Param for 5GC001390
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{ng_ho_param}
    FOR    ${nrrel_distname}    IN    @{nrrel_dict.keys()}
         delta_store.update managed object and parameter to delta    dist_name=${nrrel_distname}    &{nrrel_dict['${nrrel_distname}']}
    END
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Trigger Intrafreq NG Based SA handover from Real gNB to Sim gNB
    [Arguments]    ${ue_id}
    log to console    SA forward handover from Real gNB cell2 to simulator gNBcell1 ...
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Downlink packets from external network dropped by UPF
    ...    carrier_frequency=127450    srsrp_nr=10    srsrq_nr=5     ssinr_nr=10    phycell_id=57    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from EXT_ENB-2.2 to ENB-22.1 performed*
    Validate NG based handover prints from command output    ${output}
    sleep    5s   reason=To stabilise traffic

Trigger Intrafreq NG Based NSA handover from Real gNB to Sim gNB
    [Arguments]    ${ue_id}
    log to console    NSA forward handover from Real gNB cell2 to simulator gNBcell1 ...
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Bearer-type change from MCG to SCG-split is successful
    ...    carrier_frequency=127450    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=60    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating NSA forward handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Sending SgNB Change Confirm*
    Validate success prints from command output    ${output}    pass_regex=*Bearer-type change from MCG to SCG-split is successful*
    Validate success prints from command output    ${output}    pass_regex=*Source-SgNB global ran id:*
    Validate success prints from command output    ${output}    pass_regex=*Target-SgNB global ran id:*
    sleep    5s    reason=To stabilise traffic txput

Trigger Intrafreq NG Based SA handover from Sim gNB to Real gNB
    [Arguments]    ${ue_id}     ${scell_index}=${scell_index_sa}
    log to console    SA reverse handover from simulator gNB cell1 to real gNB cell2
    Update UE History Information     id=1    cell_type=large    nrcgi=311:489|0x04
    ...    gnb_id=22    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${ue_id}
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex \\d+ activated successfully    carrier_frequency=127450
    ...    srsrp_nr=11    srsrq_nr=11    phycell_id=51    nrsrp_nr=30    nrsrq_nr=30
    Log To Console    Validating NG based SA reverse handover...
    Validate success prints from command output    ${output}    pass_regex=*NgAPHANDOVER_REQUEST*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-22.1 to EXT_ENB-2.2 performed*
    Validate success prints from command output    ${output}    pass_regex=*HANDOVER REQUIRED: gNB=22, AMF_UE_NGAP_ID=3*
    Validate success prints from command output    ${output}    pass_regex=*HANDOVER REQUIRED: gNB=22, RAN_UE_NGAP_ID=2*
    Validate success prints from command output    ${output}    pass_regex=*SCellIndex ${scell_index} activated successfully*
    sleep    5s   reason=To stabilise traffic txput

Trigger Interfreq NG Based SA handover from Real gNB to Sim gNB
    [Arguments]    ${ue_id}
    log to console    NG based SA forward handover from Real gNB cell2 to simulator gNBcell1 ...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=127450    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Downlink packets from external network dropped by UPF
    ...    carrier_frequency=126380    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=58    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Inter-eNB handover from EXT_ENB-2.2 to ENB-23.1 performed*
    Validate NG based handover prints from command output    ${output}
    sleep    10s   reason=To stabilise traffic txput

Trigger Interfreq NG Based SA handover from Sim gNB to Real gNB
    [Arguments]    ${ue_id}    ${scell_index}=${scell_index_sa}
    log to console    SA reverse handover from simulator gNBcell1 to Real gNB cell2...
    Update UE History Information     id=1    cell_type=large    nrcgi=311:489|0x05
    ...    gnb_id=23    time_ue_stayed_in_cell=98    action=commit    ue_enb_param_id=${ue_id}
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=126530    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex \\d+ activated successfully
    ...    carrier_frequency=127450    srsrp_nr=11    srsrq_nr=11    phycell_id=51    nrsrp_nr=30    nrsrq_nr=30
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: CTRL_RACH_COMPLETE Received*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-23.1 to EXT_ENB-2.2 performed*
    Validate success prints from command output    ${output}    pass_regex=*HANDOVER REQUIRED: gNB=23, AMF_UE_NGAP_ID=3*
    Validate success prints from command output    ${output}    pass_regex=*HANDOVER REQUIRED: gNB=23, RAN_UE_NGAP_ID=2*
    Validate success prints from command output    ${output}    pass_regex=*SCellIndex ${scell_index} activated successfully*
    sleep    10s   reason=To stabilise traffic txput

Update WTS config file for InterRAT handover 5GC001390
    Run keyword And Ignore Error    run and return rc and output
    ...    cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    wts_conf.insert    command=set DAEMON_IP8="10.0.2.9"   location=after    reference=set DAEMON_IP7="10.0.2.8"
    wts_conf.insert    command=set ENB2_S1_ADDR="10.0.1.139"   location=after    reference=set ENB1_S1_ADDR="10.0.1.136"
    wts_conf.insert    command=set ENB3_S1_ADDR="10.0.1.142"   location=after    reference=set ENB2_S1_ADDR="10.0.1.139"
    ${set_cell_1}     catenate
    ...     set_cell id=1 gnb=3 pci=3:2 earfcn=1400:19400 tac=200
    ...     proxy=$DAEMON_IP:9999|$DAEMON_IP:8888 nrci=0x6 tdd_cell=on bw=20MHz technology=lte
    ${set_cell_2}     catenate
    ...     set_cell id=2 gnb=4 pci=4:2 earfcn=1600:19600 tac=200
    ...     proxy=$DAEMON_IP8:9999|$DAEMON_IP8:8888 nrci=0x5 tdd_cell=off bw=10MHz technology=lte
    wts_conf.insert
    ...    command=set_gnb id=3 type=simulated plmn=311:489 ng=$ENB2_S1_ADDR daemon=$SERVER_IP:$EDAEMON_PORT gnb_id=0x12:28 nssai=0x01:0xD143A5
    ...    location=after    reference=set_cell id=1 gnb=25
    wts_conf.insert
    ...    command=${set_cell_1}    location=after    reference=set_gnb id=3 type=simulated
    wts_conf.insert
    ...    command=set_gnb id=4 type=simulated plmn=311:489 ng=$ENB3_S1_ADDR daemon=$SERVER_IP:$EDAEMON_PORT gnb_id=0x13:28 nssai=0x01:0xD143A5
    ...    location=after    reference=set_cell id=1 gnb=3
    wts_conf.insert
    ...    command=${set_cell_2}    location=after    reference=set_gnb id=4 type=simulated
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${testlog_path}

Update Gnb with InterRAT configuration for 5GC001390
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    Get original params from gnB for interrat handover
    Recommission GNB With Delta    delta_file=${interrat_gnb_delta_json}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait for gNB To Be Ready

Trigger InterRAT SA handover from Real gNB to Sim eNB
    [Arguments]    ${ue_id}
    log to console    InterRAT SA forward handover from 5GC(RealgNB-2.2) to LTE(SimENB-4.2)...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=127450    srsrp_nr=11
    ...   srsrq_nr=11   srs_result=0:11:11:0    phycell_id=51    nrsrp_nr=30    nrsrq_nr=30    rs_type=ssb    index=0    nrs_result=30:30:0
    ${output}    Trigger B2 Event measurement    ue_id=${ue_id}    pass_regexp=IRAT Handover from NR to EUTRA completed
    ...    carrier_frequency=1600    eutra=True   srsrp_nr=11    srsrq_nr=11    srs_result=0:11:11:0
    ...    phycell_id=14    nrsrp_nr=30    nrsrq_nr=30    rs_type=ssb    index=0    nrs_result=30:30:0
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Successful handover from EXT_ENB-2.2 to ENB-4.2*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: IRAT Handover from NR to EUTRA completed*
    sleep    10s   reason=To stabilise traffic txput

Trigger InterRAT SA handover from Sim eNB to Real gNB
    [Arguments]    ${ue_id}    ${scell_index}=${scell_index_sa}
    log to console    InterRAT SA reverse handover from LTE(SimENB-4.2) to 5GC(RealgNB-2.2)...
    ${output}    Trigger eNB initiated inter-rat handover to 5g    ue_id=${ue_id}    target_gnb=${target_gnb}    target_cell=${target_cells}
    ...    plmn=${plmn}    pass_regexp=SCellIndex \\d+ activated successfully
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Received IratFromEutraToNrHo with valid NAS Container*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-4.2 to EXT_ENB-2.2 performed*
    Validate success prints from command output    ${output}    pass_regex=*SCellIndex ${scell_index} activated successfully*
    sleep    10s   reason=To stabilise traffic txput

Get original params from gnB for interrat handover
    ${interrat_feature_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${InterRAT_params}     ${NRBTS_DISTNAME}
    set test variable    ${interrat_feature_param}

Get Revert Delta Param for interrat handover 5GC001390
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{interrat_feature_param}
    delta_store.delete_param_from_delta             dist_name=${NRBTS_DISTNAME}/NRCELL-1    param_name=nrhoirDNList
    delta_store.delete_param_from_delta             dist_name=${NRBTS_DISTNAME}/NRCELL-2    param_name=nrhoirDNList
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRADJECELL-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRADJECELL-2
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRCELL-1/NRRELE-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRCELL-2/NRRELE-2
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRHOIR-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRHOIR-2
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/XNLINK-5
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/XNLINK-6
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Update WTS config file for ANR InterRAT handover 5GC001390
    Run keyword And Ignore Error    run and return rc and output
    ...    cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    wts_conf.insert    command=set ENB2_S1_ADDR="10.0.1.138"   location=after    reference=set SGW_S11_ADDR="10.0.1.134"
    wts_conf.modify    command=ue_param id=3    modification=ue_eutra_capabilities=1E000030010312000000
    ${set_cell_1}     catenate
    ...     set_cell id=1 gnb=3 pci=10:0 eci=0x7432101 earfcn=2200:20200 mapped_earfcn=4400:22400
    ...     tac=200 proxy=$SERVER_IP:12218 nrci=0x01 tdd_cell=off bw=20MHz technology=lte mandatory_for_activation=off
    wts_conf.insert
    ...    command=set_gnb id=3 type=simulated plmn=311:489 ng=$ENB2_S1_ADDR daemon=$SERVER_IP:$DAEMON_PORT gnb_id=0x74321:28 nssai=0x01:0xD143A5
    ...    location=after    reference=set_pgw id=1
    wts_conf.insert
    ...    command=${set_cell_1}    location=after    reference=set_gnb id=3 type=simulated
    wts_conf.insert
    ...    command=gnb_cell_param id=1 gnb=3 enable_drx_profile_for_anr=on
    ...    location=after    reference=set_cell id=1 gnb=3
    wts_conf.insert
    ...    command=gnb_param id=3 xn_listening_socket=off sib1_period=20000
    ...    location=after    reference=gnb_cell_param
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${testlog_path}

Update Gnb with ANR InterRAT configuration for 5GC001390
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    Get original params from gnB for ANR interrat handover
    run keyword and ignore error    Delete anr profile if present
    Recommission GNB With Delta    delta_file=${anr_ir_gnb_delta_json}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait for gNB To Be Ready

Get original params from gnB for ANR interrat handover
    ${anrIR_feature_param_original}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${ANR_InterRAT_params}
    ...     ${NRBTS_DISTNAME}
    set test variable    ${anrIR_feature_param_original}

Get Revert Delta Param for ANR interrat handover 5GC001390
    Run keyword And Continue On Failure    Delete anr profile if present
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{anrIR_feature_param_original}
    delta_store.delete_param_from_delta             dist_name=${NRBTS_DISTNAME}/NRCELL-2    param_name=nrhoirDNList
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRHOIR-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRANRPRE-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRANR-1
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Trigger ANR InterRAT SA handover from Real gNB to Sim eNB
    [Arguments]    ${ue_id}
    log to console    InterRAT SA forward handover from 5GC(RealgNB-2.2) to LTE(SimENB-3.1)...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=127450    srsrp_nr=11
    ...   srsrq_nr=11   srs_result=0:11:11:0    phycell_id=51    nrsrp_nr=30    nrsrq_nr=30    rs_type=ssb    index=0    nrs_result=30:30:0
    sleep    2s
    ${output}    Trigger B2 Event measurement    ue_id=${ue_id}    pass_regexp=IRAT Handover from NR to EUTRA completed
    ...    carrier_frequency=2200    eutra=True   srsrp_nr=11    srsrq_nr=11    srs_result=0:11:11:0
    ...    phycell_id=30    nrsrp_nr=58    nrsrq_nr=30    rs_type=ssb    index=0    nrs_result=30:30:0
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Successful handover from EXT_ENB-2.2 to ENB-3.1*
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: IRAT Handover from NR to EUTRA completed*
    sleep    10s   reason=To stabilise traffic txput
