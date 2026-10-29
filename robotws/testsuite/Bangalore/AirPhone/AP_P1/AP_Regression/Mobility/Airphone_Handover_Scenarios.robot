*** Settings ***
Documentation     author: Sravani
...               contact: sravani.k@nokia.com
...               Description:

Resource    ../../Resources/robot/ue_operations.robot
Resource    ../../Resources/robot/suite_common_keywords.robot

Suite Setup       Common Suite Setup    feature_folder=Airphone_HO_scenarios

*** Variables ***
${dl_tput}                             25
${ul_tput}                             10
@{SA_UE_List}                          1    2    3
@{NSA_UE_List}                         11
@{NSA_UE_ID}                           11
${Single_SA_HO_UE}                     1
${A1_real_gnb_carrier_freq_APoABIO}    650016
${A2_real_gnb_carrier_freq_APoABIO}    636576
${A3_real_gnb_carrier_freq_APoABIO}    629952
${WTS_CFG_PATH}                        ${CURDIR}/Config_Files/wts
${interrat_gnb_delta_json}             ${CURDIR}/cfg/InterRAT_100MHZ_delta.json
@{nrrel_profile_id}                    4    5    6    7
${NUMBER_OF_CELLS}                     2

*** Test Cases ***
TC2_XN_Based_IntraFrequency_IntergNB_SANSA Non CA UEs with 100MHZ Channel Bandwidth
    [Documentation]    Verify XN Based IntraFrequency IntergNB SANSA Non CA UEs with 100MHZ Channel Bandwidth
    [Tags]    NONCA_TC2_INTRA_XnBased_HO
    [Setup]    Test Setup For HO cases    Handover_Feature=Airphone_HO_scenarios
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}
    Register and Start Traffic For SA UEs    ${SA_UE_List}
    ...    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    Attach and Start Traffic For NSA UEs    ${NSA_UE_List}
    ...    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    Sleep    30s
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_ID}
    ...    ${dl_tput}    ${ul_tput}
    Trigger Intrafreq XN Based SA Forward handover    ue_id=${Single_SA_HO_UE}
    ...    carrier_frequency=${A1_carrier_freq}
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_ID}
    ...    ${dl_tput}    ${ul_tput}
    Trigger Intrafreq XN Based SA Reverse handover    ue_id=${Single_SA_HO_UE}
    ...    carrier_frequency=${A1_carrier_freq}
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_ID}
    ...    ${dl_tput}    ${ul_tput}
    Stop Traffic And Detach SA UEs    sa_ue_list=${SA_UE_List}
    Stop Traffic And Detach NSA UEs    nsa_ue_list=${NSA_UE_List}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    ${SA_UE_List}    ${NSA_UE_List}
    [Teardown]    Test Teardown For HO cases    ${SA_UE_List}    ${NSA_UE_List}

TC3_XN_Based_InterFrequency_IntergNB_SANSA Non CA UEs with 100MHZ Channel Bandwidth
    [Documentation]    Verify XN Based InterFrequency IntergNB SANSA Non CA UEs with 100MHZ Channel Bandwidth
    [Tags]    NONCA_TC3_INTER_XnBased_HO
    [Setup]    Test Setup For HO cases    Handover_Feature=Airphone_HO_scenarios
    ...    A3_carrier_freq=${A3_real_gnb_carrier_freq_APoABIO}    A2_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}
    ...    A2_carrier_sim_freq=${A3_real_gnb_carrier_freq_APoABIO}
    ...    A3_carrier_sim_freq=${A1_real_gnb_carrier_freq_APoABIO}
    Register and Start Traffic For SA UEs    ${SA_UE_List}
    ...    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    Attach and Start Traffic For NSA UEs    ${NSA_UE_List}
    ...    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    Sleep    30s
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_ID}
    ...    ${dl_tput}    ${ul_tput}
    Trigger Interfreq XN Based SA Forward handover    ue_id=${Single_SA_HO_UE}
    ...    A2_carrier_freq=${A2_carrier_freq}    A3_carrier_freq=${A3_carrier_freq}
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_ID}
    ...    ${dl_tput}    ${ul_tput}
    Trigger Interfreq XN Based SA Reverse handover    ue_id=${Single_SA_HO_UE}
    ...    A2_carrier_sim_freq=${A2_carrier_sim_freq}    A3_carrier_sim_freq=${A3_carrier_sim_freq}
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_ID}
    ...    ${dl_tput}    ${ul_tput}
    Stop Traffic And Detach SA UEs    sa_ue_list=${SA_UE_List}
    Stop Traffic And Detach NSA UEs    nsa_ue_list=${NSA_UE_List}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    ${SA_UE_List}    ${NSA_UE_List}
    [Teardown]    Test Teardown For HO cases    ${SA_UE_List}    ${NSA_UE_List}

TC4_NG_Based_IntraFrequency_IntergNB_SANSA Non CA UEs with 100MHZ Channel Bandwidth
    [Documentation]    Verify NG Based IntraFrequency IntergNB SANSA Non CA UEs with 100MHZ Channel Bandwidth
    [Tags]    NONCA_TC4_INTRA_NGBased_HO
    [Setup]    Test Setup For HO cases    Handover_Feature=Airphone_HO_scenarios    NGBased_HO=True
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}
    Register and Start Traffic For SA UEs    ${SA_UE_List}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    Attach and Start Traffic For NSA UEs    ${NSA_UE_List}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    Sleep    30s
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_ID}
    ...    ${dl_tput}    ${ul_tput}
    Trigger Intrafreq NG Based SA Forward handover    ue_id=${Single_SA_HO_UE}    carrier_frequency=${A1_carrier_freq}
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_ID}
    ...    ${dl_tput}    ${ul_tput}
    Trigger Intrafreq NG Based SA Reverse handover    ue_id=${Single_SA_HO_UE}    carrier_frequency=${A1_carrier_freq}
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_ID}
    ...    ${dl_tput}    ${ul_tput}
    Stop Traffic And Detach SA UEs    sa_ue_list=${SA_UE_List}
    Stop Traffic And Detach NSA UEs    nsa_ue_list=${NSA_UE_List}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    ${SA_UE_List}    ${NSA_UE_List}
    [Teardown]    Run keywords    Revert WTS and Gnb configuration    Handover_Feature=Airphone_HO_scenarios
    ...    AND    Test Teardown For HO cases    ${SA_UE_List}    ${NSA_UE_List}

TC5_NG_Based_InterFrequency_IntergNB_SANSA Non CA UEs with 100MHZ Channel Bandwidth
    [Documentation]    Verify NG Based InterFrequency IntergNB_SANSA Non CA UEs with 100MHZ Channel Bandwidth
    [Tags]    NONCA_TC5_INTER_NGBased_HO
    [Setup]    Test Setup For HO cases    Handover_Feature=Airphone_HO_scenarios    NGBased_HO=True
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}    A3_carrier_freq=${A3_real_gnb_carrier_freq_APoABIO}
    ...    A2_carrier_sim_freq=${A3_real_gnb_carrier_freq_APoABIO}    A3_carrier_sim_freq=${A1_real_gnb_carrier_freq_APoABIO}
    Register and Start Traffic For SA UEs    ${SA_UE_List}   uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    Attach and Start Traffic For NSA UEs    ${NSA_UE_List}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    Sleep    30s
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_ID}
    ...    ${dl_tput}    ${ul_tput}
    Trigger Interfreq NG Based SA Forward handover    ue_id=${Single_SA_HO_UE}
    ...    A2_carrier_freq=${A1_carrier_freq}    A3_carrier_freq=${A3_carrier_freq}
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_ID}
    ...    ${dl_tput}    ${ul_tput}
    Trigger Interfreq NG Based SA Reverse handover    ue_id=${Single_SA_HO_UE}
    ...    A2_carrier_sim_freq=${A2_carrier_sim_freq}    A3_carrier_sim_freq=${A3_carrier_sim_freq}
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_ID}
    ...    ${dl_tput}    ${ul_tput}
    Stop Traffic And Detach SA UEs    sa_ue_list=${SA_UE_List}
    Stop Traffic And Detach NSA UEs    nsa_ue_list=${NSA_UE_List}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    ${SA_UE_List}    ${NSA_UE_List}
    [Teardown]    Run keywords    Revert WTS and Gnb configuration    Handover_Feature=Airphone_HO_scenarios
    ...    AND    Test Teardown For HO cases    ${SA_UE_List}    ${NSA_UE_List}

TC6_Inter-RAT_Handover_From_5GC_To_LTE_For_NON_CA_SA_Single_UE with 100MHZ Channel Bandwidth
    [Documentation]    Verify Inter-RAT_Handover Non CA UE with 100MHZ Channel Bandwidth
    [Tags]    NONCA_TC6_INTERRAT_HO
    [Setup]    Test Setup For HO cases    Handover_Feature=Airphone_HO_scenarios    interrat_ho=True
    ...    A2_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}
    Register and Start Traffic For SA UEs    ${SA_UE_List}   uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    Sleep    30s
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Trigger InterRAT SA Forward Handover    ue_id=${Single_SA_HO_UE}    A2_carrier_freq=${A2_carrier_freq}
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Trigger InterRAT SA Reverse Handover    ue_id=${Single_SA_HO_UE}
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Stop Traffic And Detach SA UEs    sa_ue_list=${SA_UE_List}
    [Teardown]    Run keywords    Revert WTS and Gnb configuration    Handover_Feature=Airphone_HO_scenarios    interrat=True
    ...    AND    Test Teardown For HO cases    ${SA_UE_List}

*** Keywords ***
Update WTS config file for Airphone_HO_scenarios
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

Update Gnb with NGBasedHO configuration for Airphone_HO_scenarios
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

Get Revert Delta Param for Airphone_HO_scenarios
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{ng_ho_param}
    FOR    ${nrrel_distname}    IN    @{nrrel_dict.keys()}
         delta_store.update managed object and parameter to delta    dist_name=${nrrel_distname}    &{nrrel_dict['${nrrel_distname}']}
    END
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Update WTS config file for InterRAT handover Airphone_HO_scenarios
    Run keyword And Ignore Error    run and return rc and output
    ...    cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    wts_conf.insert    command=set ENB2_S1_ADDR="10.0.1.139"   location=after    reference=set PDN_IP_2="4.7.252.208"
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

Update Gnb with InterRAT configuration for Airphone_HO_scenarios
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    ${NRBTS_DISTNAME}    admin_helper.get_distname_for_nrbts
    set test variable    ${NRBTS_DISTNAME}
    Get original params from gnB for interrat handover
    Recommission GNB With Delta    delta_file=${interrat_gnb_delta_json}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait Until Keyword Succeeds     2min     30sec     Check if gNB is reachable    ${GNB_IP}

Get original params from gnB for interrat handover
    ${interrat_feature_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${InterRAT_params}     ${NRBTS_DISTNAME}
    set test variable    ${interrat_feature_param}

Get Revert Delta Param for interrat handover Airphone_HO_scenarios
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

Check if gNB is reachable
    [Arguments]    ${gnb_ip}
    ${output}    Run    ping -c 20 ${gnb_ip}
    Should contain    ${output}    ttl
    Should not contain    ${output}    Destination Host Unreachable
    Should not contain    ${output}    error
