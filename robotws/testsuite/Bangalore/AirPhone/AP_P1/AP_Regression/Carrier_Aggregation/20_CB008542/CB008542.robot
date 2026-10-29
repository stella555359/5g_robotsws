*** Settings ***
Documentation     author: Gopi Ram
...               contact: gattu.gopi_ram@nokia.com

Resource    ../CA_Common_Keywords.robot

Suite Setup       Suite Setup    feature_folder=CB008542

*** Variables ***
${dl_tput}                         100
${ul_tput}                         10
@{dl_tput_list}                    100   100    100    100
${multi_CA_UL_tput}                10
${total_CA_tput}                   400
@{Multi_CA_NSA_UE_List}            41    42    43    44
@{NSA_Scell_Index}                 8    9
@{Single_CA_NSA_UE_List}           41
@{UL_Scell_index}                  8
@{scell_index_list}                9
${CA_NSA_UE_ID_HO}                 41
${ul_tput_ng_based}                10
${NUMBER_OF_CELLS}                 2
@{simulator_gnb_list}              2    24    25
@{Sim_Gnb_list_HO}                 2    24    25
@{nrrel_profile_id}                6    7
@{Sim_Gnb_carrier_freq_list}       509790    505230
@{phycell_id_list}                 50    51    600    700
${WTS_CFG_PATH}                    ${CURDIR}/../Config_Files/20_CB008542/wts
${WTS_FILE}                        basic_setup.cfg


*** Test Cases ***
CB008542_TC1_BufferBased CA Activation with beamforming and beamrefinement NSA For Multiple UEs
    [Documentation]    Verify UL/DL Traffic For Measurement Based 4UEs-3 Ues (TDD FR1 capable) and 1 UE(FDD Non CA capable) CA Related Features
    ...                Enabled with Beamforming With Scell Release
    [Tags]    AP_REG    P1_REG    8542_TC1_MUE
    [Setup]    Test Setup
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform NSA UE Attach for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override    nsa_ue_list=${Multi_CA_NSA_UE_List}
    ...    carrier_frequency=${Sim_Gnb_carrier_freq_list}[0]
    Start Traffic for multiple NSA UEs    ue_list=${Multi_CA_NSA_UE_List}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    Sleep    60s
    Verify scell activated for SA UEs    sa_ue_list=${Multi_CA_NSA_UE_List}    scell_index_list=${scell_index_list}
    Validate uplink and downlink cell throughput from UE stats and bearer stats for NSA UEs    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    UE_List=${Multi_CA_NSA_UE_List}    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${NSA_Scell_Index}
    Stop Traffic and Detach NSA UEs    ${Multi_CA_NSA_UE_List}
    [Teardown]    Test Teardown    nsa_ue_list=${Multi_CA_NSA_UE_List}

CB008542_TC2_IntraFrequency_IntergNB_TDD_FDD_CA_HO_for_NSA_UE
    [Documentation]    Verify IntraFrequency_IntergNB_TDD_FDD_CA_HO_for_NSA_UE gNB-2(TDD-1+FDD),gNB-24(TDD-2)
    [Tags]    AP_REG    P2_REG    8542_TC2_INTRA_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008542
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform NSA UE Attach for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override   nsa_ue_list=${Single_CA_NSA_UE_List}
    ...    carrier_frequency=${Sim_Gnb_carrier_freq_list}[0]
    Start Traffic    ue_id=${Single_CA_NSA_UE_List}[0]    id=2    dir=ul    mbps=${ul_tput}
    Start Traffic without Validation of Scell Activation    ue_id=${Single_CA_NSA_UE_List}[0]    mode=NSA   dl_tput_list=${dl_tput_list}   bearer_id=2
    Sleep    60s
    Verify scell activated for SA UEs    sa_ue_list=${Single_CA_NSA_UE_List}    scell_index_list=${scell_index_list}
    Validate uplink and downlink cell throughput from UE stats and bearer stats for NSA UEs    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    UE_List=${Single_CA_NSA_UE_List}    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${NSA_Scell_Index}
    Trigger Intrafreq XN Based NSA Forward handover    ue_id=${CA_NSA_UE_ID_HO}    carrier_frequency=${Sim_Gnb_carrier_freq_list}[0]
    ...    phycell_id=${phycell_id_list}[2]
    Validate throughput from bearer stats    ue_id=${CA_NSA_UE_ID_HO}    expected_dl_tput=${total_CA_tput}    expected_ul_tput=${ul_tput}    mode=NSA
    Update UE History Information    id=1    cell_type=large    nrcgi=311:489|0x06    gnb_id=24    time_ue_stayed_in_cell=97    action=commit
    ...    ue_enb_param_id=${Single_CA_NSA_UE_List}[0]
    Trigger Intrafreq XN Based NSA Reverse handover    ue_id=${Single_CA_NSA_UE_List}[0]    carrier_frequency=${Sim_Gnb_carrier_freq_list}[0]
    ...    phycell_id=${phycell_id_list}[1]    real_cell=2
    Trigger A1 Event measurement    ue_id=${Single_CA_NSA_UE_List}[0]    pass_regexp=sCellToAddModList
    ...    carrier_frequency=${Sim_Gnb_carrier_freq_list}[0]    phycell_id=${phycell_id_list}[0]    srsrp_nr=40
    sleep   60s
    Verify scell activated for SA UEs    sa_ue_list=${Single_CA_NSA_UE_List}    scell_index_list=${scell_index_list}
    Validate uplink and downlink cell throughput from UE stats and bearer stats for NSA UEs    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    UE_List=${Single_CA_NSA_UE_List}    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${NSA_Scell_Index}
    Stop Traffic and Detach NSA UEs    ${Single_CA_NSA_UE_List}
    [Teardown]    Test Teardown    nsa_ue_list=${Single_CA_NSA_UE_List}    handover=True

CB008542_TC3_InterFrequency_IntergNB_TDD_FDD_CA_HO_MeasGap_for_NSA_UE
    [Documentation]    Verify InterFrequency_IntergNB_TDD_FDD_CA_HO_MeasGap_for_NSA_UE gNB-2(TDD-1+ FDD),gNB-23(TDD-2)
    [Tags]    AP_REG    P2_REG    8542_TC3_INTER_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008542
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform NSA UE Attach for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override   nsa_ue_list=${Single_CA_NSA_UE_List}
    ...    carrier_frequency=${Sim_Gnb_carrier_freq_list}[0]
    Start Traffic    ue_id=${Single_CA_NSA_UE_List}[0]    id=2    dir=ul    mbps=${ul_tput}
    Start Traffic without Validation of Scell Activation    ue_id=${Single_CA_NSA_UE_List}[0]    mode=NSA   dl_tput_list=${dl_tput_list}   bearer_id=2
    Sleep    60s
    Verify scell activated for SA UEs    sa_ue_list=${Single_CA_NSA_UE_List}    scell_index_list=${scell_index_list}
    Validate uplink and downlink cell throughput from UE stats and bearer stats for NSA UEs    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    UE_List=${Single_CA_NSA_UE_List}    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${NSA_Scell_Index}
    Trigger Interfreq XN Based NSA Forward handover    ue_id=${CA_NSA_UE_ID_HO}    A2_carrier_freq=${Sim_Gnb_carrier_freq_list}[0]
    ...    A3_carrier_freq=${Sim_Gnb_carrier_freq_list}[1]    phycell_id=${phycell_id_list}[3]
    Validate throughput from bearer stats    ue_id=${CA_NSA_UE_ID_HO}    expected_dl_tput=${total_CA_tput}    expected_ul_tput=${ul_tput}    mode=NSA
    Update UE History Information    id=1    cell_type=large    nrcgi=311:489|0x07    gnb_id=25    time_ue_stayed_in_cell=97    action=commit
    ...    ue_enb_param_id=${Single_CA_NSA_UE_List}[0]
    Trigger Interfreq XN Based NSA Reverse handover    ue_id=${CA_NSA_UE_ID_HO}    A2_carrier_sim_freq=524000
    ...    A3_carrier_sim_freq=${Sim_Gnb_carrier_freq_list}[0]    hist_id=1    phycell_id=${phycell_id_list}[1]
    Trigger A1 Event measurement    ue_id=${Single_CA_NSA_UE_List}[0]    pass_regexp=sCellToAddModList
    ...    carrier_frequency=${Sim_Gnb_carrier_freq_list}[0]    phycell_id=${phycell_id_list}[0]    srsrp_nr=40
    sleep   60s
    Verify scell activated for SA UEs    sa_ue_list=${Single_CA_NSA_UE_List}    scell_index_list=${scell_index_list}
    Validate uplink and downlink cell throughput from UE stats and bearer stats for NSA UEs    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    UE_List=${Single_CA_NSA_UE_List}    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${NSA_Scell_Index}
    Stop Traffic and Detach NSA UEs    ${Single_CA_NSA_UE_List}
    [Teardown]    Test Teardown    nsa_ue_list=${Single_CA_NSA_UE_List}    handover=True

CB008542_TC4_NG_Based_IntraFrequency_IntergNB_TDD-FR1_TDD_CA_HO_for_NSA_UE
    [Documentation]    Verify IntraFrequency_IntergNB_TDD-FR1_TDD_CA_HO_for_SA_NSA_UE    gNB-2(TDD-1+FDD),gNB-2x(TDD-2)
    [Tags]    AP REG    P2_REG    8542_TC4_INTRA_NGbased_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008542    NGBased_HO=True
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform NSA UE Attach for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}    carrier_frequency=${Sim_Gnb_carrier_freq_list}[0]
    Start Traffic    ue_id=${Single_CA_NSA_UE_List}[0]    id=2    dir=ul    mbps=${ul_tput}
    Start Traffic without Validation of Scell Activation    ue_id=${Single_CA_NSA_UE_List}[0]    mode=NSA   dl_tput_list=${dl_tput_list}   bearer_id=2
    Sleep    60s
    Verify scell activated for SA UEs    sa_ue_list=${Single_CA_NSA_UE_List}    scell_index_list=${scell_index_list}
    Validate uplink and downlink cell throughput from UE stats and bearer stats for NSA UEs    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    UE_List=${Single_CA_NSA_UE_List}    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${NSA_Scell_Index}
    Trigger Intrafreq NG Based NSA Forward handover    ue_id=${CA_NSA_UE_ID_HO}    carrier_frequency=${Sim_Gnb_carrier_freq_list}[0]
    ...    phycell_id=${phycell_id_list}[2]
    Validate throughput from bearer stats    ue_id=${CA_NSA_UE_ID_HO}    expected_dl_tput=${total_CA_tput}    expected_ul_tput=${ul_tput}    mode=NSA
    Execute Egate Command    cmd=sim_log_set flush    timeout=2s
    Trigger Intrafreq NG Based NSA Reverse handover    ue_id=${Single_CA_NSA_UE_List}[0]    carrier_frequency=${Sim_Gnb_carrier_freq_list}[0]
    ...    phycell_id=${phycell_id_list}[1]    real_cell=2    hist_id=1    nrci=6
    Trigger A1 Event measurement    ue_id=${Single_CA_NSA_UE_List}[0]    pass_regexp=sCellToAddModList
    ...    carrier_frequency=${Sim_Gnb_carrier_freq_list}[0]    phycell_id=${phycell_id_list}[0]    srsrp_nr=40
    sleep   60s
    Verify scell activated for SA UEs    sa_ue_list=${Single_CA_NSA_UE_List}    scell_index_list=${scell_index_list}
    Validate uplink and downlink cell throughput from UE stats and bearer stats for NSA UEs    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    UE_List=${Single_CA_NSA_UE_List}    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${NSA_Scell_Index}
    Stop Traffic and Detach NSA UEs    ${Single_CA_NSA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=CB008542
    ...    AND    Test Teardown    nsa_ue_list=${Single_CA_NSA_UE_List}

CB008542_TC5_NG_Based_InterFrequency_IntergNB_TDD-FR1_TDD_CA_HO_for_NSA_UE
    [Documentation]    Verify InterFrequency_IntergNB_TDD-FR1_TDD_CA_HO_for_SA_NSA_UE    gNB-2(TDD-1+FDD),gNB-2x(TDD-2)
    [Tags]    AP REG    P2_REG    8542_TC5_INTER_NGbased_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008542    NGBased_HO=True
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform NSA UE Attach for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}    carrier_frequency=${Sim_Gnb_carrier_freq_list}[0]
    Start Traffic    ue_id=${Single_CA_NSA_UE_List}[0]    id=2    dir=ul    mbps=${ul_tput}
    Start Traffic without Validation of Scell Activation    ue_id=${Single_CA_NSA_UE_List}[0]    mode=NSA   dl_tput_list=${dl_tput_list}   bearer_id=2
    Sleep    60s
    Verify scell activated for SA UEs    sa_ue_list=${Single_CA_NSA_UE_List}    scell_index_list=${scell_index_list}
    Validate uplink and downlink cell throughput from UE stats and bearer stats for NSA UEs    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    UE_List=${Single_CA_NSA_UE_List}    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${NSA_Scell_Index}
    Trigger Interfreq NG Based NSA Forward handover    ue_id=${CA_NSA_UE_ID_HO}    A2_carrier_freq=${Sim_Gnb_carrier_freq_list}[0]
    ...    A3_carrier_freq=${Sim_Gnb_carrier_freq_list}[1]    phycell_id=${phycell_id_list}[3]
    Validate throughput from bearer stats    ue_id=${CA_NSA_UE_ID_HO}    expected_dl_tput=${total_CA_tput}    expected_ul_tput=${ul_tput}    mode=NSA
    sleep   30s
    Execute Egate Command    cmd=sim_log_set flush    timeout=2s
    Trigger Interfreq NG Based NSA Reverse handover    ue_id=${Single_CA_NSA_UE_List}[0]    A2_carrier_freq=524000
    ...    A3_carrier_freq=${Sim_Gnb_carrier_freq_list}[0]    nrci=7    phycell_id=${phycell_id_list}[1]
    Trigger A1 Event measurement    ue_id=${Single_CA_NSA_UE_List}[0]    pass_regexp=sCellToAddModList
    ...    carrier_frequency=${Sim_Gnb_carrier_freq_list}[0]    phycell_id=${phycell_id_list}[0]    srsrp_nr=40
    sleep   60s
    Verify scell activated for SA UEs    sa_ue_list=${Single_CA_NSA_UE_List}    scell_index_list=${scell_index_list}
    Validate uplink and downlink cell throughput from UE stats and bearer stats for NSA UEs    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    UE_List=${Single_CA_NSA_UE_List}    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${NSA_Scell_Index}
    Stop Traffic and Detach NSA UEs    ${Single_CA_NSA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=CB008542
    ...    AND    Test Teardown    nsa_ue_list=${Single_CA_NSA_UE_List}


*** Keywords ***
Update WTS config file for CB008542
    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/${WTS_FILE} ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/${WTS_FILE}
    wts_conf.modify    command=set_gnb id=2 type=external    modification=gnb_id=0x02
    wts_conf.modify    command=set_cell id=2 gnb=2    modification=nrci=0x02
    wts_conf.modify    command=gnb_param id=24   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.modify    command=gnb_param id=25   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/${WTS_FILE}
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/${WTS_FILE} ${testlog_path}

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

Update Gnb with NGBasedHO configuration for CB008542
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    ${NRBTS_DISTNAME}    admin_helper.get_distname_for_nrbts
    set test variable    ${NRBTS_DISTNAME}
    ${NRCELL_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=2
    set test variable    ${NRCELL_DISTNAME}
    Get original params from gnB
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

Get Revert Delta Param for CB008542
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{ng_ho_param}
    FOR    ${nrrel_distname}    IN    @{nrrel_dict.keys()}
         delta_store.update managed object and parameter to delta    dist_name=${nrrel_distname}    &{nrrel_dict['${nrrel_distname}']}
    END
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}