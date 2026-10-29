*** Settings ***
Documentation    Contains keywords related to 1167 feature
Resource        ../CA_Common_Keywords.robot


*** Variables ***
${WTS_CFG_PATH}        ${CURDIR}/cfg
@{Counter_List}        M55118C05506    M55316C09000    M55310C01006    M55316C09001    M55118C06501
&{nradjnrcell_params}  fiveGsTac=200     freqBandIndicatorNR=71

*** Keywords ***
Enable UE testmode for Multi Scell
    [Arguments]    ${id}    ${profile_id}    ${scell_index}    ${testmode}=csi_override    ${action}=activate
	FOR    ${scell}    IN    @{scell_index}
	    Enable UE to testmode    id=${id}    profile_id=${profile_id}    scell_index=${scell}
        ...    pass_regex=SCellIndex ${scell} deactivated successfully    testmode=${testmode}    action=${action}
    END

Scell Deactivation using RLQ testmode activation
    [Arguments]    ${ue_list}    ${scell_index}
    Update CSI parameters    profile_id=5
    FOR    ${ue_id}    IN    @{ue_list}
	    Enable UE testmode for Multi Scell    id=${ue_id}    profile_id=5    scell_index=${scell_index}
    END

Perform UE Register and Start Traffic For SA Non CA Capable UEs
    [Arguments]    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}    nwslice=1
        Log To Console    Going To Start Traffic for SA Non CA Capable UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=3    protocol=udp    mbps=${ul_tput}
        Start Traffic    ue_id=${ue_id}    dir=dl    pdu=3    protocol=udp    mbps=${ul_tput}
    END

Egate console verification for Scell Index
    Execute Egate Command    cmd=sim_log_set flush    timeout=1s
    Egate console log verification    SCellIndex 1 activated successfully
    Egate console log verification    SCellIndex 2 activated successfully

Perform UE Register and Start Traffic For Single SA UE
    [Arguments]    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}    nwslice=1
        Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport
        ...    carrier_frequency=127210    phycell_id=50    srsrp_nr=40
        Validate Scell Addition    scell_index=${SA_Scell_Index}[1]
        Validate Scell Addition    scell_index=${SA_Scell_Index}[2]
        Log To Console    Going To Start Traffic for SA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=3    mbps=${ul_tput}
        Log To Console    Going To Check Scell Activation For SA UE: ${ue_id}
        Start Traffic With Regex Check    ue_id=${ue_id}    dir=dl
        ...    pass_regex=SCellIndex \\d+ activated successfully    pdu=3    trf_id=1    mbps=${Single_dl_tput}
        Wait Until Keyword Succeeds    1 min    30sec    Egate console verification for Scell Index
    END

Perform UE Register For SA CA UEs
    [Arguments]    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}    nwslice=1
        Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport
        ...    carrier_frequency=127210    phycell_id=50    srsrp_nr=40
        Validate Scell Addition    scell_index=${SA_Scell_Index}[1]
        Validate Scell Addition    scell_index=${SA_Scell_Index}[2]
    END

Validate Pcell and Scell Throughput For Multi SA UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput_list}    ${UE_List}    ${Scell_Id}
    FOR    ${ue_id}    ${expected_dl_tput}    IN ZIP    ${UE_List}    ${expected_dl_tput_list}
        Log To Console    Going To Check Throughput for SA UE: ${ue_id}
        ${total_tput}    Get Throughput from all cells    ${ue_id}     ${Scell_Id}
        ${ul_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=ul    pdu_id=3
        ${dl_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=dl    pdu_id=3
        Total CA UE Throughput Verification   ${total_tput}    ${dl_tput}    ${expected_dl_tput}
        Run Keyword and Ignore Error    Average Throughput Should Be as Expected    ${ul_tput}
        ...    ${expected_ul_tput}
    END

Validate Pcell Throughput For Non CA Capable UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}
    FOR    ${ue_id}    IN    @{UE_List}
        Log To Console    Going To Check Throughput for Non CA Capable SA UE: ${ue_id}
        ${pcell_tput}    Cell Specific Throughput Validation    ue_id=${ue_id}    scell=0
        ${ul_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=ul    pdu_id=3
        ${dl_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=dl    pdu_id=3
        Total CA UE Throughput Verification   ${pcell_tput}    ${dl_tput}    ${expected_dl_tput}
        Run Keyword and Ignore Error    Average Throughput Should Be as Expected    ${ul_tput}
        ...    ${expected_ul_tput}
    END

Validate Pcell and Scell Throughput For Single SA UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}    ${Scell_Id}
    FOR    ${ue_id}    IN    @{UE_List}
        Log To Console    Going To Check Throughput for SA UE: ${ue_id}
        ${total_tput}    Get Throughput from all cells    ${ue_id}     ${Scell_Id}
        ${ul_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=ul    pdu_id=3
        ${dl_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=dl    pdu_id=3
        Total CA UE Throughput Verification   ${total_tput}    ${dl_tput}    ${expected_dl_tput}
        Run Keyword and Ignore Error    Average Throughput Should Be as Expected    ${ul_tput}
        ...    ${expected_ul_tput}
    END

Perform Stop Traffic and Detach SA Non CA Capable UEs
    [Arguments]    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Log To Console    Going To Stop Traffic for SA Non CA Capable UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}    pdu=3    dir=ul
        Stop UE Traffic    ue_id=${ue_id}    pdu=3    dir=dl
        Ensure UE PDU Session Release Is Successful    ue_id=${ue_id}    pdu_id=3
        Ensure UE Deregister Is Successful    ue_id=${ue_id}    ue_deregister_type=switch_off    by=ue
    END

Perform Stop Traffic and Detach SA UEs
    [Arguments]    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Log To Console    Going To Stop Traffic for SA UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}    pdu=3    dir=ul
        Log To Console    Going To Check Scell Dectivation For SA UE: ${ue_id}
        ${meas_id}    Get Measurement Id    ue_id=${ue_id}    event=EventA2    carrier_frequency=430850
        Send Ue Measurements    ue_id=${ue_id}    meas_id=${meas_id}    pass_regexp=measurementReport    event=A2
        ...    scell=1    scell_rsrp=30    phycell_id=51
        ${meas_id}    Get Measurement Id    ue_id=${ue_id}    event=EventA2    carrier_frequency=436830
        Send Ue Measurements    ue_id=${ue_id}    meas_id=${meas_id}    pass_regexp=measurementReport    event=A2
        ...    scell=2    scell_rsrp=30    phycell_id=52
        Validate Scell Release    scell_index=${SA_Scell_Index}[1]
        Validate Scell Release    scell_index=${SA_Scell_Index}[2]
        Ensure UE PDU Session Release Is Successful    ue_id=${ue_id}    pdu_id=3
        Ensure UE Deregister Is Successful    ue_id=${ue_id}    ue_deregister_type=switch_off    by=ue
    END

Validate Pcell and Scell Throughput For SA UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}    ${Scell_Id}
    ${is_single_ue}    Evaluate    len(${UE_List}) == 1
    Run Keyword If    ${is_single_ue}    Validate Pcell and Scell Throughput For Single SA UEs    ${expected_ul_tput}
    ...    ${expected_dl_tput}    ${UE_List}    ${Scell_Id}
    Run Keyword If    not ${is_single_ue}    Validate Pcell and Scell Throughput For Multi SA UEs    ${expected_ul_tput}
    ...    ${expected_dl_tput}    ${UE_List}    ${Scell_Id}

Perform Stop Traffic and Detach NSA UEs
    log to console    No NSA UE's to be detached

Start traffic for all UEs
    [Arguments]     ${CA_SA_UE_List}    ${Non_CA_SA_UE_List}    ${CA_DL_txput}    ${non_CA_DL_txput}    ${2CC_3CC}=False
    FOR    ${ue_id}    IN    @{CA_SA_UE_List}
        Log To Console    Going To Start Traffic DL for SA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=dl    pdu=3    trf_id=1    mbps=${CA_DL_txput}
    END
    FOR    ${ue_id}    IN    @{CA_SA_UE_List}
        Log To Console    Going To Start Traffic UL for SA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=3    mbps=${ul_tput}
    END
    FOR    ${ue_id}    IN    @{Non_CA_SA_UE_List}
        Log To Console    Going To Start Traffic for SA Non CA Capable UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=3    protocol=udp    mbps=${ul_tput}
        Start Traffic    ue_id=${ue_id}    dir=dl    pdu=3    protocol=udp    mbps=${non_CA_DL_txput}
    END
    sleep     10s    reason=Waiting for all Scells to be activated
    Wait Until Keyword Succeeds    1 min    30sec    Verify scell activated for all UEs    ${CA_SA_UE_List}    ${2CC_3CC}

Perform UE Register For SA Non CA Capable UEs
    [Arguments]    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}    nwslice=1
    END

Verify scell activated for all UEs
    [Arguments]     ${CA_SA_UE_List}    ${2CC_3CC}=False
    Execute Egate Command    cmd=sim_log_set flush    timeout=2s
    FOR    ${ue_id}    IN    @{CA_SA_UE_List}
        ${sa_scell_ue_id}    Evaluate    ${ue_id}-1
        run keyword if  '${2CC_3CC}' == 'False'    Egate console log verification
        ...    UeId:${sa_scell_ue_id},SubcellId:16.* SCellIndex 1 activated successfully
        run keyword if  '${2CC_3CC}' == 'False'    Egate console log verification
        ...    UeId:${sa_scell_ue_id},SubcellId:32.* SCellIndex 2 activated successfully
        run keyword if   '${2CC_3CC}' == 'True'    Egate console log verification
        ...    UeId:${sa_scell_ue_id},SubcellId:32.* SCellIndex 1 activated successfully
    END

Perform UE Register For Single SA UE
    [Arguments]    ${ue_id}
    Ensure UE Register Is Successful    ue_id=${ue_id}
    Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
    Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}    nwslice=1
    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport
    ...    carrier_frequency=127210    phycell_id=50    srsrp_nr=40
    Validate Scell Addition    scell_index=${SA_Scell_Index}[1]
    Validate Scell Addition    scell_index=${SA_Scell_Index}[2]

Trigger Intrafreq SA handover from Real gNB cell1 to real gNB cell3
    [Arguments]    ${ue_id}
    log to console    SA forward handover from Real gNB cell1(primary cell) to real gNB cell3(secondary cell) ...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=127210    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Intra-eNB handover from    carrier_frequency=436830
    ...    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=52    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.3 performed*
    sleep    5s   reason=To stabilise

Trigger Intrafreq SA handover from Real gNB cell3 to real gNB cell2
    [Arguments]    ${ue_id}
    log to console    SA forward handover from Real gNB cell3(secondary cell) to real gNB cell2(3CC cell) ...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=436830    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex \\d+ activated successfully
    ...    carrier_frequency=430850    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=51    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Intra-eNB handover from EXT_ENB-2.3 to EXT_ENB-2.2 performed*
    sleep    5s   reason=To stabilise
    Execute Egate Command    cmd=sim_log_set flush    timeout=2s
    ${sa_scell_ue_id}    Evaluate    ${ue_id}-1
    Egate console log verification    UeId:${sa_scell_ue_id},SubcellId:0.* SCellIndex 1 activated successfully
    Egate console log verification    UeId:${sa_scell_ue_id},SubcellId:32.* SCellIndex 2 activated successfully

Perform Stop Traffic for all UEs
    [Arguments]    ${sa_ue_list}    ${pdu}=3
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Log To Console    Going To Stop Traffic for SA UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}    pdu=${pdu}    dir=ul
        Stop UE Traffic    ue_id=${ue_id}    pdu=${pdu}    dir=dl
    END
    sleep    5s

Verify Scell Deactivated For All SA CA UEs
    [Arguments]     ${CA_SA_UE_List}     ${2CC_3CC}=False
    Execute Egate Command    cmd=sim_log_set flush    timeout=2s
    FOR    ${ue_id}    IN    @{CA_SA_UE_List}
        ${sa_scell_ue_id}    Evaluate    ${ue_id}-1
        Egate console log verification    UeId:${sa_scell_ue_id},SubcellId:32.* SCellIndex 2 deactivated successfully
        run keyword if   '${2CC_3CC}' == 'False'
        ...    Egate console log verification    UeId:${sa_scell_ue_id},SubcellId:0.* SCellIndex 1 deactivated successfully
        ...    ELSE    Egate console log verification    UeId:${sa_scell_ue_id},SubcellId:16.* SCellIndex 1 deactivated successfully
    END

Detach all SA UEs
    [Arguments]    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE PDU Session Release Is Successful    ue_id=${ue_id}    pdu_id=3
        Ensure UE Deregister Is Successful    ue_id=${ue_id}    ue_deregister_type=switch_off    by=ue
    END

Delete Scell Addition Method in Gnb
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    ${nrcell_distname}    admin_helper.get distname for nrcell using logical id    logical_cell_id=2
    delta_store.delete_param_from_delta    dist_name=${nrcell_distname}/NRREL-2    param_name=sCellAdditionMethod
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Wait for gNB To Be Ready

Perform UE Register For all SA UEs
    [Arguments]    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}    nwslice=1
    END

Trigger Intrafreq SA handover from Real gNB cell2 to real gNB cell1
    [Arguments]    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        log to console    SA forward handover from Real gNB cell1(primary cell) to real gNB cell3(secondary cell) ...
        Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=430850    srsrp_nr=7    srsrq_nr=7
        ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Intra-eNB handover from    carrier_frequency=127210
        ...    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=50    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
        Log To Console    Validating 3CC handover...
        Validate success prints from command output    ${output}
        ...    pass_regex=*UE${ue_id}: Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed*
        sleep    5s   reason=To stabilise
    END

Trigger Scell Addition to activate Scell
    [Arguments]    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=127210
        ...    srsrp_nr=40    phycell_id=50
    END
    Log To Console    Validating scell activation...
    wait until keyword succeeds    2min    30s    Verify scell activated for all UEs      ${sa_ue_list}

Update Gnb with NGBasedHO configuration for 5GC001167
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    Get original params from gnB
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{NgHo_Inter_Intra_params}
    delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}/NRREL-11    &{nrrel_params}
    delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}/NRREL-12    &{nrrel_params}
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}/NRADJNRCELL-12    &{nradjnrcell_params}
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait for gNB To Be Ready

Update WTS config file for 5GC001167
    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    wts_conf.modify    command=set_gnb id=2 type=external    modification=gnb_id=0x01
    wts_conf.modify    command=gnb_param id=22   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.modify    command=gnb_param id=23   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${testlog_path}

Trigger Intrafreq NG Based SA handover from Real gNB2 cell1 to sim gNB22 cell2
    [Arguments]    ${ue_id}
    log to console    NG based forward handover from Real gNB2 cell1 to sim gNB22 cell2...
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Downlink packets from external network dropped by UPF
    ...    carrier_frequency=127210    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=57    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from EXT_ENB-2.1 to ENB-22.1 performed*
    Validate NG based handover prints from command output    ${output}
    sleep    5s   reason=To stabilise

Trigger Intrafreq NG Based SA handover from sim gNB22 Cell2 to Real gNB2 Cell1
    [Arguments]    ${ue_id}
    log to console    NG based reverse handover from sim gNB22 Cell2 to Real gNB2 Cell1...
    Update UE History Information     id=1    cell_type=large    nrcgi=311:489|0x04
    ...    gnb_id=22    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${ue_id}
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Inter-eNB handover from ENB-22.1 to EXT_ENB-2.1
    ...   carrier_frequency=127168    srsrp_nr=11    srsrq_nr=11    phycell_id=50    nrsrp_nr=30    nrsrq_nr=30
    Log To Console    Validating SA reverse handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-22.1 to EXT_ENB-2.1 performed*
    sleep    5s   reason=To stabilise

Validate throughput from UE stats and bearer stats for SA UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}    ${Scell_Id}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs
    ...    expected_ul_tput=${expected_ul_tput}    expected_dl_tput=${expected_dl_tput}     UE_List=${UE_List}    Scell_Id=${Scell_Id}

Trigger Interfreq NG Based SA handover from Real gNB2 cell1 to sim gNB22 cell2
    [Arguments]    ${ue_id}
    log to console    Interfreq NG based forward handover from Real gNB2 cell1 to sim gNB22 cell2...
    Trigger A2 Event measurement     ue_id=${ue_id}    pass_regexp=measurementReport
    ...   carrier_frequency=127210    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Downlink packets from external network dropped by UPF
    ...    carrier_frequency=126380    srsrp_nr=10    srsrq_nr=5    ssinr_nr=10    phycell_id=58    nrsrp_nr=40    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from EXT_ENB-2.1 to ENB-23.1 performed*
    Validate NG based handover prints from command output    ${output}
    sleep    5s   reason=To stabilise

Trigger Interfreq NG Based SA handover from sim gNB22 Cell2 to Real gNB2 Cell1
    [Arguments]    ${ue_id}
    log to console    Interfrequency NG based reverse handover from sim gNB22 Cell2 to Real gNB2 Cell1...
    Update UE History Information     id=1    cell_type=large    nrcgi=311:489|0x04
    ...    gnb_id=22    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${ue_id}
    Trigger A2 Event measurement     ue_id=${ue_id}    pass_regexp=measurementReport
    ...   carrier_frequency=126530    srsrp_nr=7    srsrq_nr=7
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Inter-eNB handover from ENB-23.1 to EXT_ENB-2.1
    ...   carrier_frequency=127210    srsrp_nr=11    srsrq_nr=11    phycell_id=50    nrsrp_nr=30    nrsrq_nr=30
    Log To Console    Validating SA reverse handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-23.1 to EXT_ENB-2.1 performed*
    sleep    5s   reason=To stabilise

Get original params from gnB
    ${ng_ho_param}       scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${NgHo_feature_param}     ${NRBTS_DISTNAME}
    ${nrrel_11_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${nrrel_params}     ${NRCELL_DISTNAME}/NRREL-11
    ${nrrel_12_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${nrrel_params}     ${NRCELL_DISTNAME}/NRREL-12
    set test variable    ${ng_ho_param}
    set test variable    ${nrrel_11_param}
    set test variable    ${nrrel_12_param}

Get Revert Delta Param for 5GC001167
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}              &{ng_ho_param}
    delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}/NRREL-11    &{nrrel_11_param}
    delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}/NRREL-12    &{nrrel_12_param}
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}
