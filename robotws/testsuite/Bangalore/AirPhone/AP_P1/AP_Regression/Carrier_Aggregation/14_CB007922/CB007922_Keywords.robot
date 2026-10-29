*** Settings ***
Documentation   Keywords for CB007922 feature
Resource        ../CA_Common_Keywords.robot
Resource        ../7_5GC001729/1729_Keywords.robot
Library     taf.collectors.l2stream3     WITH NAME     ttistream
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.btslog    WITH NAME   btslog


*** Variables ***
${WTS_CFG_PATH}        ${CURDIR}/cfg
@{Counter_List}        M55118C05506    M55316C09000    M55310C01006    M55316C09002    M55118C06501
${interrat_gnb_delta_json}         ${WTS_CFG_PATH}/InterRAT_7922_delta.json
&{TC3_sCellAdditionMethod}          sCellAdditionMethod=blind
&{TC3_sCellActivationMethod}        sCellActivationMethod=blind
&{TC3_sCellDeactivationTimerGNB}    sCellDeactivationTimerGNB=infinity
&{TC4_sCellAdditionMethod}          sCellAdditionMethod=blind
&{TC4_sCellActivationMethod}        sCellActivationMethod=bufferBased
&{TC5_sCellAdditionMethod}          sCellAdditionMethod=blind
&{TC5_sCellActivationMethod}        sCellActivationMethod=bufferAndRLQualityBased
&{TC6_sCellAdditionMethod}          sCellAdditionMethod=blind
&{TC6_sCellActivationMethod}        sCellActivationMethod=bufferAndRLQualityBased
&{TC7_sCellAdditionMethod}          sCellAdditionMethod=covBasedA1
&{TC7_sCellActivationMethod}        sCellActivationMethod=blind
&{TC7_sCellDeactivationTimerGNB}    sCellDeactivationTimerGNB=infinity
&{TC8_sCellAdditionMethod}          sCellAdditionMethod=covBasedA1
&{TC8_sCellActivationMethod}        sCellActivationMethod=bufferBased
&{TC9_sCellAdditionMethod}          sCellAdditionMethod=covBasedA1
&{TC9_sCellActivationMethod}        sCellActivationMethod=bufferBased
&{TC19_cellDepType}                 cellDepType=NSA
@{cells_for_activation_deactivation}     1     2
&{TC15_16_sCellAdditionMethod}       sCellAdditionMethod=covBasedA1
&{TC15_16_sCellActivationMethod}     sCellActivationMethod=bufferAndRLQualityBased
&{TC17_sCellAdditionMethod}          sCellAdditionMethod=blind
&{TC17_sCellActivationMethod}        sCellActivationMethod=bufferBased
&{TC18_sCellAdditionMethod}          sCellAdditionMethod=blind
&{TC18_sCellDeactivationTimerGNB}    sCellDeactivationTimerGNB=infinity
&{TC18_sCellActivationMethod}        sCellActivationMethod=blind
&{TC15_to_TC18_cellDepType}          cellDepType=SA


*** Keywords ***
Perform NSA UE Attach and Start Traffic For NSA Non CA Capable UE
    [Arguments]    ${nsa_ue_list}    ${uplink_tput}=${ul_tput}
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        UE Attach    ue_id=${ue_id}    profile_id=${profile_id}
        SGNB Addition For Bearer    ue_id=${ue_id}    target_gnb=${target_gnb}    target_cells=${target_cells}
        ...    bearer=${bearer_id}
        Log To Console    Going To Start Traffic for NSA Non CA Capable UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    id=${bearer_id}    mbps=${uplink_tput}
        Start Traffic    ue_id=${ue_id}    dir=dl    id=${bearer_id}    mbps=${uplink_tput}
    END

Start Traffic and Validate Scell Activation for SA UE
    [Arguments]    ${ue_id_list}    ${dl_tput_list}=${dl_tput_list}    ${uplink_tput}=${ul_tput}
    FOR    ${ue_id}    IN    @{ue_id_list}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=3    mbps=${uplink_tput}
        Start Traffic and Validate Scell Activation for SA     ${ue_id}     ${dl_tput_list}
    END

Start Traffic and Validate Scell Activation for NSA UE
    [Arguments]    ${ue_id_list}    ${bearer_id}=${bearer_id}    ${dl_tput_list}=${dl_tput_list}
    FOR    ${ue_id}    IN    @{ue_id_list}
        Start Traffic    ue_id=${ue_id}    dir=ul    id=${bearer_id}    mbps=${ul_tput}
        Start Traffic and Validate Scell Activation for NSA     ${ue_id}    ${bearer_id}    dl_txput_list=${dl_tput_list}
    END

Associate CSI Override profile to all UEs
    FOR    ${ue_id}    IN    @{Multi_CA_SA_UE_List}
        Associate UE to testmode    id=${ue_id}    testmode=csi_override     profile_id=5    action=activate    scell=1
    END
    FOR    ${ue_id}    IN    @{Multi_CA_NSA_UE_List}
        Associate UE to testmode    id=${ue_id}    testmode=csi_override     profile_id=5    action=activate    scell=9
    END

Update WTS config file for CB007922
    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    wts_conf.modify    command=set_gnb id=2 type=external    modification=gnb_id=0x01
    wts_conf.modify    command=set_cell id=2 gnb=2    modification=nrci=0x02
    wts_conf.modify    command=gnb_param id=22   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.modify    command=gnb_param id=23   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.modify    command=gnb_param id=24   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.modify    command=gnb_param id=25   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.delete    smf_upf_mapping
    wts_conf.insert    smf_upf_mapping id=1 upf=1    after    set_upf id=2
    wts_conf.insert    smf_upf_mapping id=2 upf=2    after    smf_upf_mapping id=1
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${testlog_path}

Update Gnb with NGBasedHO configuration for CB007922
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    ${NRBTS_DISTNAME}    admin_helper.get_distname_for_nrbts
    set test variable    ${NRBTS_DISTNAME}
    ${NRCELL_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=2
    set test variable    ${NRCELL_DISTNAME}
    1729_Keywords.Get original params from gnB
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{NgHo_Inter_Intra_params}
    FOR    ${nrrel_id}    IN    @{nrrel_profile_id}
         delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}/NRREL-${nrrel_id}    &{nrrel_params}
    END
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait Until Keyword Succeeds     2min     30sec     Check if gNB is reachable    ${GNB_IP}

Update WTS config file for InterRAT handover CB007922
    Run keyword And Ignore Error    run and return rc and output
    ...    cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    wts_conf.insert    command=set ENB2_S1_ADDR="10.0.1.140"   location=after    reference=set GNB_S1U_ADDR="10.0.1.2"
    wts_conf.modify    command=set_gnb id=2 type=external    modification=gnb_id=0x1
    wts_conf.delete    smf_upf_mapping
    wts_conf.insert    smf_upf_mapping id=1 upf=1    after    set_upf id=2
    wts_conf.insert    smf_upf_mapping id=2 upf=2    after    smf_upf_mapping id=1
    ${set_cell_2}     catenate
    ...     set_cell id=2 gnb=3 pci=3:2 earfcn=1400:19400 tac=200
    ...     proxy=$DAEMON_IP:9999|$DAEMON_IP:8888 nrci=0x8 tdd_cell=on bw=20MHz technology=lte mandatory_for_activation=off
    wts_conf.insert
    ...    command=set_gnb id=3 type=simulated plmn=311:489 ng=$ENB2_S1_ADDR daemon=$SERVER_IP:$EDAEMON_PORT gnb_id=012:28 nssai=0x01:0xD143A5
    ...    location=after    reference=set_cell id=2 gnb=2
    wts_conf.insert
    ...    command=${set_cell_2}    location=after    reference=set_gnb id=3 type=simulated
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${testlog_path}

Update Gnb with InterRAT configuration for CB007922
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    ${NRBTS_DISTNAME}    admin_helper.get_distname_for_nrbts
    set test variable    ${NRBTS_DISTNAME}
    Get original params from gnB for interrat handover
    Recommission GNB With Delta    delta_file=${interrat_gnb_delta_json}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait Until Keyword Succeeds     2min     30sec     Check if gNB is reachable    ${GNB_IP}

Get Revert Delta Param for interrat handover CB007922
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{interrat_feature_param}
    delta_store.delete_param_from_delta             dist_name=${NRBTS_DISTNAME}/NRCELL-2    param_name=nrhoirDNList
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRADJECELL-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRCELL-2/NRRELE-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRHOIR-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/XNLINK-8
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Start traffic for SA UEs
    [Arguments]    ${dl_tput_list}=${dl_tput_list}
    FOR    ${ue_id}    IN    @{Non_CA_SA_UE_List}
        Log To Console    Going To Start Traffic for SA Non CA Capable UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=3    protocol=udp    mbps=${ul_tput}
        Start Traffic    ue_id=${ue_id}    dir=dl    pdu=3    protocol=udp    mbps=${ul_tput}
        sleep    1s
    END
    FOR    ${ue_id}    IN    @{Multi_CA_SA_UE_List}
        Log To Console    Going To Start Traffic for SA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=3    mbps=${ul_tput}
        Start DL SA Traffic for multi UE scenario    ${ue_id}    ${dl_tput_list}
        sleep    1s
    END
    sleep   10s

Perform Stop Traffic and Detach NSA Non CA Capable UE
    [Arguments]    ${nsa_ue_list}
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        Log To Console    Going To Stop Traffic for NSA Non CA Capable UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}
        Log To Console    Going To release NSA UE: ${ue_id}
        Release ENDC Bearer    ue_id=${ue_id}    bearer=${bearer_id}    cause=MISC_CauseMisc_unspecified
        UE Detach    ue_id=${ue_id}
    END

Start traffic for all NSA UEs
    [Arguments]    ${bearer_id}=2    ${dl_tput_list}=${dl_tput_list}
    ${last_nsa_multi_ue}    Set Variable    ${Multi_CA_NSA_UE_List}[-1]
    FOR    ${ue_id}    IN    @{Multi_CA_NSA_UE_List}
        Log To Console    Going To Start Traffic for NSA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    id=${bearer_id}    mbps=${ul_tput}
        Start DL NSA Traffic for multi UE scenario    ${ue_id}    ${bearer_id}    ${last_nsa_multi_ue}    ${dl_tput_list}
    END
    sleep   10s

Verify scell activated for all NSA UEs
    sleep     30s    reason=Waiting for all Scells to be activated
    Execute Egate Command    cmd=sim_log_set flush    timeout=2s
    FOR    ${ue_id}    IN    @{Multi_CA_NSA_UE_List}
        ${nsa_scell_ue_id}    Evaluate    ${ue_id}-1
        Egate console log verification    UeId:${nsa_scell_ue_id},SubcellId:[0-1].* SCellIndex 9 activated successfully
    END

Verify scell deactivated for all NSA UEs
    sleep     10s    reason=Waiting for all Scells to be deactivated
    Execute Egate Command    cmd=sim_log_set flush    timeout=2s
    sleep    5s    reason=Waiting for egate console to be flushed
    FOR    ${ue_id}    IN    @{Multi_CA_NSA_UE_List}
        ${nsa_scell_ue_id}    Evaluate    ${ue_id}-1
        Run keyword And Continue On Failure
        ...    Egate console log verification    UeId:${nsa_scell_ue_id},SubcellId:[0-1].* SCellIndex 9 deactivated successfully
    END
