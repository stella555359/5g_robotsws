*** Settings ***
Documentation     author: Bhanu Vamsi Krishna
...               contact: vamsi.gundlur@nokia.com
...               Description: Multi duplex HO Test cases

Resource          ../../Resources/robot/ue_operations.robot
Resource          ../../Resources/robot/suite_common_keywords.robot
Resource          ../RU_LockUnlock/RU_lockunlock_Keywords.robot

Suite Setup       Common Suite Setup    feature_folder=Airphone_HO_scenarios

*** Variables ***
${dl_tput}                             20
${ul_tput}                             10
@{SA_UE_List}                          1    3
@{NSA_UE_List}                         11    13
@{NSA_UE_TDD}                          11
@{NSA_UE_FDD}                          13
${Single_NSA_HO_UE_ID_TDD}             11
${Single_SA_HO_UE_TDD}                 1
${Single_NSA_HO_UE_ID_FDD}             13
${Single_SA_HO_UE_FDD}                 3
${A3_TDD_carrier_freq}                 636576
${A3_FDD_carrier_freq}                 126530
${A3_TDD_sim_carrier_freq}             629952
${A3_FDD_sim_carrier_freq}             126290
${A2_FDD_sim_carrier_freq}             124570
${B2_TDD_sim_carrier_freq}             1400
${B2_FDD_sim_carrier_freq}             1600
${WTS_CFG_PATH}                        ${CURDIR}/Config_Files_duplex/wts
${interrat_gnb_delta_json}             ${CURDIR}/cfg/InterRAT_duplex_delta.json
@{nrrel_profile_id_tdd}                1    3    5    7
@{nrrel_profile_id_fdd}                2    4    6    8
${NUMBER_OF_CELLS}                     4
${cfg_update_ng}                       type=external plmn=311:489 s1u=$GNB_S1U_ADDR x2=$GNB_X2_ADDR:36422 ng=$GNB_NG_ADDR gnb_id=0x01
                                       ...    daemon=$SERVER_IP:$DAEMON_PORT x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
${no_of_time_lock_unlock}                     2


*** Test Cases ***
TC1_XN_Based_IntraFrequency_IntergNB_SANSA Non CA UEs with 100MHZ TDD 20MHZ FDD Channel Bandwidth
    [Documentation]    Verify XN Based IntraFrequency IntergNB SANSA Non CA UEs with 100MHZ TDD and 20 MHZ FDD Channel Bandwidth
    [Tags]    AP_REG    NONCA_TC1_INTRA_XnBased_HO    AP_P1
    [Setup]    Test Setup For HO cases    Handover_Feature=Airphone_HO_scenarios
    ...    A3_tdd_carrier_freq=${A3_TDD_carrier_freq}    A3_fdd_carrier_freq=${A3_FDD_carrier_freq}
    FOR    ${ru_lock_unlock}    IN RANGE    ${no_of_time_lock_unlock}
        Register and Start Traffic For SA UEs    ${SA_UE_List}
        ...    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
        Attach and Start Traffic For NSA UEs    ${NSA_UE_TDD}
        ...    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}    target_cells=1
        Attach and Start Traffic For NSA UEs    ${NSA_UE_FDD}
        ...    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}    target_cells=3
        Sleep    30s
        Validate throughput from UE stats for NON CA SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_List}
        ...    ${dl_tput}    ${ul_tput}
        Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_List}
        ...    ${dl_tput}    ${ul_tput}
        Trigger Intrafreq XN Based SA Forward handover    ue_id=${Single_SA_HO_UE_TDD}
        ...    carrier_frequency=${A3_tdd_carrier_freq}    primary_cell=1    phycell_id=63
        Trigger Intrafreq XN Based SA Forward handover    ue_id=${Single_SA_HO_UE_FDD}
        ...    carrier_frequency=${A3_fdd_carrier_freq}    primary_cell=3    sim_cell=2    phycell_id=64
        Trigger Intrafreq XN Based NSA Forward handover    ue_id=${Single_NSA_HO_UE_ID_TDD}
        ...    carrier_frequency=${A3_tdd_carrier_freq}
        Trigger Intrafreq XN Based NSA Forward handover    ue_id=${Single_NSA_HO_UE_ID_FDD}
        ...    carrier_frequency=${A3_fdd_carrier_freq}    primary_cell=3    sim_cell=2    phycell_id=68
        Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_List}
        ...    ${dl_tput}    ${ul_tput}
        Trigger Intrafreq XN Based SA Reverse handover    ue_id=${Single_SA_HO_UE_TDD}
        ...    carrier_frequency=${A3_tdd_carrier_freq}    hist_id=1    phycell_id=50    nrci=2    primary_cell=1
        Trigger Intrafreq XN Based SA Reverse handover    ue_id=${Single_SA_HO_UE_FDD}
        ...    carrier_frequency=${A3_fdd_carrier_freq}    hist_id=2    phycell_id=52    nrci=3    primary_cell=3    sim_cell=2
        Update UE History Information     id=3    cell_type=large    nrcgi=311:489|0x02
        ...    gnb_id=24    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${Single_NSA_HO_UE_ID_TDD}
        Trigger Intrafreq XN Based NSA Reverse handover    ue_id=${Single_NSA_HO_UE_ID_TDD}
        ...    carrier_frequency=${A3_tdd_carrier_freq}
        Update UE History Information     id=4    cell_type=large    nrcgi=311:489|0x03
        ...    gnb_id=24    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${Single_NSA_HO_UE_ID_FDD}
        Trigger Intrafreq XN Based NSA Reverse handover    ue_id=${Single_NSA_HO_UE_ID_FDD}
        ...    carrier_frequency=${A3_fdd_carrier_freq}    real_cell=3    phycell_id=52
        Validate throughput from UE stats for NON CA SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_List}
        ...    ${dl_tput}    ${ul_tput}
        Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_List}
        ...    ${dl_tput}    ${ul_tput}
        Stop Traffic And Detach SA UEs    sa_ue_list=${SA_UE_List}
        Stop Traffic And Detach NSA UEs    nsa_ue_list=${NSA_UE_List}
        Perform RU Lock and Unlock
    END
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    ${SA_UE_List}
    ...    ${NSA_UE_List}
    [Teardown]    Test Teardown For HO cases    ${SA_UE_List}    ${NSA_UE_List}

TC2_XN_Based_InterFrequency_IntergNB_SANSA Non CA UEs with 100MHZ TDD 20MHZ FDD Channel Bandwidth
    [Documentation]    Verify XN Based InterFrequency IntergNB SANSA Non CA UEs with 100MHZ TDD and 20 MHZ FDD Channel Bandwidth
    [Tags]    AP_REG    NONCA_TC2_INTER_XnBased_HO
    [Setup]    Test Setup For HO cases    Handover_Feature=Airphone_HO_scenarios
    ...    A2_tdd_carrier_freq=${A3_TDD_carrier_freq}    A2_fdd_carrier_freq=${A3_FDD_carrier_freq}
    ...    A3_tdd_carrier_freq=${A3_TDD_sim_carrier_freq}    A3_fdd_carrier_freq=${A3_FDD_sim_carrier_freq}
    Register and Start Traffic For SA UEs    ${SA_UE_List}
    ...    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    Attach and Start Traffic For NSA UEs    ${NSA_UE_TDD}
    ...    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}    target_cells=1
    Attach and Start Traffic For NSA UEs    ${NSA_UE_FDD}
    ...    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}    target_cells=3
    Sleep    30s
    Validate throughput from UE stats for NON CA SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_List}
    ...    ${dl_tput}    ${ul_tput}
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_List}
    ...    ${dl_tput}    ${ul_tput}
    Trigger Interfreq XN Based SA Forward handover    ue_id=${Single_SA_HO_UE_TDD}
    ...    A2_carrier_freq=${A2_tdd_carrier_freq}    A3_carrier_freq=${A3_tdd_carrier_freq}    primary_cell=1    phycell_id=65
    Trigger Interfreq XN Based SA Forward handover    ue_id=${Single_SA_HO_UE_FDD}
    ...    A2_carrier_freq=${A2_fdd_carrier_freq}    A3_carrier_freq=${A3_fdd_carrier_freq}    primary_cell=3    phycell_id=66    sim_cell=2
    Trigger Interfreq XN Based NSA Forward handover    ue_id=${Single_NSA_HO_UE_ID_TDD}    A2_carrier_freq=${A2_tdd_carrier_freq}
    ...    A3_carrier_freq=${A3_tdd_carrier_freq}
    Trigger Interfreq XN Based NSA Forward handover    ue_id=${Single_NSA_HO_UE_ID_FDD}    A2_carrier_freq=${A2_fdd_carrier_freq}
    ...    A3_carrier_freq=${A3_fdd_carrier_freq}    primary_cell=3    sim_gnb_id=25    sim_cell=2    phycell_id=70
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_List}
    ...    ${dl_tput}    ${ul_tput}
    Trigger Interfreq XN Based SA Reverse handover    ue_id=${Single_SA_HO_UE_TDD}    A2_carrier_sim_freq=${A3_tdd_carrier_freq}
    ...    A3_carrier_sim_freq=${A2_tdd_carrier_freq}    real_cell=1    nrci=4    phycell_id=50
    Trigger Interfreq XN Based SA Reverse handover    ue_id=${Single_SA_HO_UE_FDD}    A2_carrier_sim_freq=${A2_FDD_sim_carrier_freq}
    ...    A3_carrier_sim_freq=${A2_fdd_carrier_freq}    real_cell=3    hist_id=2    nrci=4    phycell_id=52    sim_cell=2
    Trigger Interfreq XN Based NSA Reverse handover    ue_id=${Single_NSA_HO_UE_ID_TDD}
    Trigger Interfreq XN Based NSA Reverse handover    ue_id=${Single_NSA_HO_UE_ID_FDD}    A2_carrier_sim_freq=${A2_FDD_sim_carrier_freq}
    ...    real_cell=3    sim_cell=2    A3_carrier_sim_freq=${A2_fdd_carrier_freq}    hist_id=4    phycell_id=52
    Validate throughput from UE stats for NON CA SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_List}
    ...    ${dl_tput}    ${ul_tput}
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_List}
    ...    ${dl_tput}    ${ul_tput}
    Stop Traffic And Detach SA UEs    sa_ue_list=${SA_UE_List}
    Stop Traffic And Detach NSA UEs    nsa_ue_list=${NSA_UE_List}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    ${SA_UE_List}    ${NSA_UE_List}
    [Teardown]    Test Teardown For HO cases    ${SA_UE_List}    ${NSA_UE_List}

TC3_NG_Based_IntraFrequency_IntergNB_SANSA Non CA UEs with 100MHZ TDD 20MHZ FDD Channel Bandwidth
    [Documentation]    Verify NG Based IntraFrequency IntergNB SANSA Non CA UEs with 100MHZ TDD and 20 MHZ FDD Channel Bandwidth
    [Tags]    AP_REG    NONCA_TC3_INTRA_NGBased_HO
    [Setup]    Test Setup For HO cases    Handover_Feature=Airphone_HO_scenarios    NGBased_HO=True
    ...    A3_tdd_carrier_freq=${A3_TDD_carrier_freq}    A3_fdd_carrier_freq=${A3_FDD_carrier_freq}
    Register and Start Traffic For SA UEs    ${SA_UE_List}
    ...    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    Attach and Start Traffic For NSA UEs    ${NSA_UE_TDD}
    ...    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}    target_cells=1
    Attach and Start Traffic For NSA UEs    ${NSA_UE_FDD}
    ...    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}    target_cells=3
    Sleep    30s
    Validate throughput from UE stats for NON CA SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_List}
    ...    ${dl_tput}    ${ul_tput}
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_List}
    ...    ${dl_tput}    ${ul_tput}
    Trigger Intrafreq NG Based SA Forward handover    ue_id=${Single_SA_HO_UE_TDD}    carrier_frequency=${A3_tdd_carrier_freq}    phycell_id=63
    ...    primary_cell=1
    Trigger Intrafreq NG Based SA Forward handover    ue_id=${Single_SA_HO_UE_FDD}    carrier_frequency=${A3_fdd_carrier_freq}    phycell_id=64
    ...    primary_cell=3    sim_cell=2
    Trigger Intrafreq NG Based NSA Forward handover    ue_id=${Single_NSA_HO_UE_ID_TDD}    carrier_frequency=${A3_tdd_carrier_freq}
    Trigger Intrafreq NG Based NSA Forward handover    ue_id=${Single_NSA_HO_UE_ID_FDD}    carrier_frequency=${A3_fdd_carrier_freq}    sim_cell=2
    ...    primary_cell=3    phycell_id=68
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_List}
    ...    ${dl_tput}    ${ul_tput}
    Trigger Intrafreq NG Based SA Reverse handover    ue_id=${Single_SA_HO_UE_TDD}    carrier_frequency=${A3_tdd_carrier_freq}    nrci=2
    ...    phycell_id=50    real_cell=1
    Trigger Intrafreq NG Based SA Reverse handover    ue_id=${Single_SA_HO_UE_FDD}    carrier_frequency=${A3_fdd_carrier_freq}    nrci=2
    ...    phycell_id=52    real_cell=3    sim_cell=2    hist_id=2
    Trigger Intrafreq NG Based NSA Reverse handover    ue_id=${Single_NSA_HO_UE_ID_TDD}    carrier_frequency=${A3_tdd_carrier_freq}
    Trigger Intrafreq NG Based NSA Reverse handover    ue_id=${Single_NSA_HO_UE_ID_FDD}    carrier_frequency=${A3_fdd_carrier_freq}
    ...    phycell_id=52    real_cell=3    sim_cell=2    hist_id=4
    Validate throughput from UE stats for NON CA SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_List}
    ...    ${dl_tput}    ${ul_tput}
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_List}
    ...    ${dl_tput}    ${ul_tput}
    Stop Traffic And Detach SA UEs    sa_ue_list=${SA_UE_List}
    Stop Traffic And Detach NSA UEs    nsa_ue_list=${NSA_UE_List}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    ${SA_UE_List}    ${NSA_UE_List}
    [Teardown]    Run keywords    Revert WTS and Gnb configuration    Handover_Feature=Airphone_HO_scenarios
    ...    AND    Test Teardown For HO cases    ${SA_UE_List}    ${NSA_UE_List}

TC4_NG_Based_InterFrequency_IntergNB_SANSA Non CA UEs with 100MHZ TDD 20MHZ FDD Channel Bandwidth
    [Documentation]    Verify NG Based InterFrequency IntergNB_SANSA Non CA UEs with 100MHZ TDD and 20 MHZ FDD Channel Bandwidth
    [Tags]    AP_REG    NONCA_TC4_INTER_NGBased_HO
    [Setup]    Test Setup For HO cases    Handover_Feature=Airphone_HO_scenarios    NGBased_HO=True
    ...    A2_tdd_carrier_freq=${A3_TDD_carrier_freq}    A2_fdd_carrier_freq=${A3_FDD_carrier_freq}
    ...    A3_tdd_carrier_freq=${A3_TDD_sim_carrier_freq}    A3_fdd_carrier_freq=${A3_FDD_sim_carrier_freq}
    Register and Start Traffic For SA UEs    ${SA_UE_List}
    ...    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    Attach and Start Traffic For NSA UEs    ${NSA_UE_TDD}
    ...    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}    target_cells=1
    Attach and Start Traffic For NSA UEs    ${NSA_UE_FDD}
    ...    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}    target_cells=3
    Sleep    30s
    Validate throughput from UE stats for NON CA SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_List}
    ...    ${dl_tput}    ${ul_tput}
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_List}
    ...    ${dl_tput}    ${ul_tput}
    Trigger Interfreq NG Based SA Forward handover    ue_id=${Single_SA_HO_UE_TDD}    primary_cell=1    phycell_id=65
    ...    A2_carrier_freq=${A2_tdd_carrier_freq}    A3_carrier_freq=${A3_tdd_carrier_freq}
    Trigger Interfreq NG Based SA Forward handover    ue_id=${Single_SA_HO_UE_FDD}    primary_cell=3    phycell_id=66    sim_cell=2
    ...    A2_carrier_freq=${A2_fdd_carrier_freq}    A3_carrier_freq=${A3_fdd_carrier_freq}
    Trigger Interfreq NG Based NSA Forward handover    ue_id=${Single_NSA_HO_UE_ID_TDD}    A2_carrier_freq=${A2_tdd_carrier_freq}
    ...    A3_carrier_freq=${A3_tdd_carrier_freq}
    Trigger Interfreq NG Based NSA Forward handover    ue_id=${Single_NSA_HO_UE_ID_FDD}    A2_carrier_freq=${A2_fdd_carrier_freq}    sim_cell=2
    ...    A3_carrier_freq=${A3_fdd_carrier_freq}    primary_cell=3    phycell_id=70
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_List}
    ...    ${dl_tput}    ${ul_tput}
    Trigger Interfreq NG Based SA Reverse handover    ue_id=${Single_SA_HO_UE_TDD}    real_cell=1    nrci=4    phycell_id=50
    ...    A2_carrier_sim_freq=${A3_tdd_carrier_freq}    A3_carrier_sim_freq=${A2_tdd_carrier_freq}
    Trigger Interfreq NG Based SA Reverse handover    ue_id=${Single_SA_HO_UE_FDD}    real_cell=3    nrci=4    phycell_id=52    sim_cell=2
    ...    A2_carrier_sim_freq=${A2_FDD_sim_carrier_freq}    A3_carrier_sim_freq=${A2_fdd_carrier_freq}    hist_id=2
    Trigger Interfreq NG Based NSA Reverse handover    ue_id=${Single_NSA_HO_UE_ID_TDD}    A2_carrier_freq=${A3_tdd_carrier_freq}
    ...    A3_carrier_freq=${A2_tdd_carrier_freq}
    Trigger Interfreq NG Based NSA Reverse handover    ue_id=${Single_NSA_HO_UE_ID_FDD}    A2_carrier_freq=${A2_FDD_sim_carrier_freq}    hist_id=4
    ...    A3_carrier_freq=${A2_fdd_carrier_freq}    real_cell=3    sim_cell=2    phycell_id=52
    Validate throughput from UE stats for NON CA SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_List}
    ...    ${dl_tput}    ${ul_tput}
    Validate throughput from bearer stats for SA and NSA UEs    ${SA_UE_List}    ${NSA_UE_List}
    ...    ${dl_tput}    ${ul_tput}
    Stop Traffic And Detach SA UEs    sa_ue_list=${SA_UE_List}
    Stop Traffic And Detach NSA UEs    nsa_ue_list=${NSA_UE_List}
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    ${SA_UE_List}    ${NSA_UE_List}
    [Teardown]    Run keywords    Revert WTS and Gnb configuration    Handover_Feature=Airphone_HO_scenarios
    ...    AND    Test Teardown For HO cases    ${SA_UE_List}    ${NSA_UE_List}

TC5_Inter-RAT_Handover_From_5GC_To_LTE_For_NON_CA_SA_Single_UE with 100MHZ TDD 20MHZ FDD Channel Bandwidth
    [Documentation]    Verify Inter-RAT_Handover Non CA SA UE with 100MHZ TDD and 20 MHZ FDD Channel Bandwidth
    [Tags]    AP_REG    NONCA_TC5_INTERRAT_HO
    [Setup]    Test Setup For HO cases    Handover_Feature=Airphone_HO_scenarios    interrat_ho=True
    ...    A2_tdd_carrier_freq=${A3_TDD_carrier_freq}    B2_tdd_carrier_freq=${B2_TDD_sim_carrier_freq}
    ...    A2_fdd_carrier_freq=${A3_FDD_carrier_freq}    B2_fdd_carrier_freq=${B2_FDD_sim_carrier_freq}
    Register and Start Traffic For SA UEs    ${SA_UE_List}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    Sleep    30s
    Validate UE stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}    expected_ul_tput=${ul_tput}
    ...    scell=${SA_Scell_Index}
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Trigger InterRAT SA Forward Handover    ue_id=${Single_SA_HO_UE_TDD}    A2_carrier_freq=${A2_tdd_carrier_freq}    primary_cell=1
    Trigger InterRAT SA Forward Handover    ue_id=${Single_SA_HO_UE_FDD}    A2_carrier_freq=${A2_fdd_carrier_freq}    phycell_id=52    primary_cell=3
    ...    sim_enb_id=4    B2_carrier_freq=1600    sim_phycell_id=14
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Trigger InterRAT SA Reverse Handover    ue_id=${Single_SA_HO_UE_TDD}    primary_cell=1
    Trigger InterRAT SA Reverse Handover    ue_id=${Single_SA_HO_UE_FDD}    primary_cell=3    sim_enb_id=4
    Validate UE stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}    expected_ul_tput=${ul_tput}
    ...    scell=${SA_Scell_Index}
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Stop Traffic And Detach SA UEs    sa_ue_list=${SA_UE_List}
    [Teardown]    Run keywords    Revert WTS and Gnb configuration    Handover_Feature=Airphone_HO_scenarios    interrat=True
    ...    AND    Test Teardown For HO cases    ${SA_UE_List}

*** Keywords ***
Update WTS config file for Airphone_HO_scenarios
    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    wts_conf.delete    set_gnb id=2
    wts_conf.insert    set_gnb id=2 ${cfg_update_ng}    after    set_upf id=1
    wts_conf.modify    command=gnb_param id=22   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.modify    command=gnb_param id=23   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.modify    command=gnb_param id=24   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.modify    command=gnb_param id=25   modification=xn_listening_socket=1 send_xn_setup=false measEvent=A2 measEvent=A3 sa_ho=ng_based
    wts_conf.save_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${testlog_path}

Update Gnb with NGBasedHO configuration for Airphone_HO_scenarios
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    ${NRBTS_DISTNAME}    admin_helper.get_distname_for_nrbts
    set test variable    ${NRBTS_DISTNAME}
    ${TDD_NRCELL_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=1
    set test variable    ${TDD_NRCELL_DISTNAME}
    ${FDD_NRCELL_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=3
    set test variable    ${FDD_NRCELL_DISTNAME}
    Get original params from gnB
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{NgHo_Inter_Intra_params}
    FOR    ${nrrel_id}    IN    @{nrrel_profile_id_tdd}
         delta_store.update managed object and parameter to delta    dist_name=${TDD_NRCELL_DISTNAME}/NRREL-${nrrel_id}    &{nrrel_params}
    END
    FOR    ${nrrel_id}    IN    @{nrrel_profile_id_fdd}
         delta_store.update managed object and parameter to delta    dist_name=${FDD_NRCELL_DISTNAME}/NRREL-${nrrel_id}    &{nrrel_params}
    END
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait Until Keyword Succeeds     2min     30sec     Check if gNB is reachable    ${GNB_IP}

Get original params from gnB
    ${ng_ho_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${NgHo_feature_param}     ${NRBTS_DISTNAME}
    &{nrrel_dict_tdd}     create dictionary
    &{nrrel_dict_fdd}     create dictionary
    FOR    ${nrrel_id}    IN    @{nrrel_profile_id_tdd}
         ${nrrel_distname}    set variable    ${TDD_NRCELL_DISTNAME}/NRREL-${nrrel_id}
         ${nrrel_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${nrrel_params}    ${nrrel_distname}
         set to dictionary    ${nrrel_dict_tdd}    ${nrrel_distname}=${nrrel_param}
    END
    FOR    ${nrrel_id}    IN    @{nrrel_profile_id_fdd}
         ${nrrel_distname}    set variable    ${FDD_NRCELL_DISTNAME}/NRREL-${nrrel_id}
         ${nrrel_param}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${nrrel_params}    ${nrrel_distname}
         set to dictionary    ${nrrel_dict_fdd}    ${nrrel_distname}=${nrrel_param}
    END
    set test variable    ${ng_ho_param}
    set test variable    ${nrrel_dict_tdd}
    set test variable    ${nrrel_dict_fdd}

Get Revert Delta Param for Airphone_HO_scenarios
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{ng_ho_param}
    FOR    ${nrrel_distname}    IN    @{nrrel_dict_tdd.keys()}
         delta_store.update managed object and parameter to delta    dist_name=${nrrel_distname}    &{nrrel_dict_tdd['${nrrel_distname}']}
    END
    FOR    ${nrrel_distname}    IN    @{nrrel_dict_fdd.keys()}
         delta_store.update managed object and parameter to delta    dist_name=${nrrel_distname}    &{nrrel_dict_fdd['${nrrel_distname}']}
    END
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Update WTS config file for InterRAT handover Airphone_HO_scenarios
    Run keyword And Ignore Error    run and return rc and output
    ...    cp ${WTS_INSTALL_PATH}/basic_setup.cfg ${WTS_INSTALL_PATH}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_INSTALL_PATH}/basic_setup.cfg
    wts_conf.insert    command=set DAEMON_IP10="10.0.2.10"   location=after    reference=set DAEMON_IP9="10.0.2.2"
    wts_conf.insert    command=set ENB2_S1_ADDR="10.0.1.139"   location=after    reference=set GNB_X2_ADDR="10.0.1.2"
    wts_conf.insert    command=set ENB3_S1_ADDR="10.0.1.138"   location=after    reference=set ENB2_S1_ADDR="10.0.1.139"
    ${set_cell_2}     catenate
    ...     set_cell id=2 gnb=3 pci=3:2 earfcn=1400:19400 tac=200
    ...    proxy=$DAEMON_IP:9999|$DAEMON_IP:8888 nrci=0x2 tdd_cell=on bw=20MHz technology=lte mandatory_for_activation=off
    wts_conf.insert
    ...    command=set_gnb id=3 type=simulated plmn=311:489 ng=$ENB2_S1_ADDR daemon=$SERVER_IP:$DAEMON_PORT gnb_id=012:28 nssai=0x01:0xD143A5
    ...    location=after    reference=set_cell id=2 gnb=2
    ${set_cell_3}     catenate
    ...     set_cell id=2 gnb=4 pci=4:2 earfcn=1600:19600 tac=200
    ...    proxy=$DAEMON_IP10:9999|$DAEMON_IP10:8888 nrci=0x3 tdd_cell=off bw=10MHz technology=lte mandatory_for_activation=off
    wts_conf.insert
    ...    command=set_gnb id=4 type=simulated plmn=311:489 ng=$ENB3_S1_ADDR daemon=$SERVER_IP:$DAEMON_PORT gnb_id=013:28 nssai=0x01:0xD143A5
    ...    location=after    reference=set_cell id=2 gnb=2
    wts_conf.insert
    ...    command=${set_cell_2}    location=after    reference=set_gnb id=3 type=simulated
    wts_conf.insert
    ...    command=${set_cell_3}    location=after    reference=set_gnb id=4 type=simulated
    ${interRat_ue_cap}=    Catenate    SEPARATOR=    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C28
    ...    C0D608C21A08107482406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10
    ...    480CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E2
    ...    38F40CFB027C639F30C7942C0E070F05C00FFC007003FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31E5
    ...    0B0381C3C27FFC00001FFF00000130000E0541B06F582308682041E2090195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FF
    ...    C000004C00038024F0F1340038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E208000010B02B0F13400388C0000042
    ...    C0AC5C46000E20800710400002858158B89A001C41000E140000040B02B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E
    ...    20800710400001058158B89A001C41000E230000020B02B170A000388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B02
    ...    B1F0A0003850001C1B000E208000070B02B1F0A0003836001C41000E230000080B02B1F0A0003850001C1B000E230000070B02B1F0A0003850001C41000
    ...    E230000070B020120234028809B010600D87A06E84A14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C0
    ...    8902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E0428103639F0214081B1CF
    ...    810A040D8E7C000D890C6318C6318C6318C6318C60F413003C00281C1401C0C02500700060240040603E090020000000100000200800000004000008020
    ...    00008010000060080000400400002802001004010040000300200001C010008000000200002001000012008000030040000500200002C01000812048020
    ...    000300CE54D654D60C560CD60CD60CD652D64CD602D60CD602D604D60ED0341000009652504000065949410000296524040000E59490100004965240400
    ...    0165949010000696524040001E594901000089652404000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E954550
    ...    68AA0D1541A2A94C55268AA031540A2A93555078A1202F012A05028140A05028140A05028140A05028140A0502800404040300601002004202004010080
    ...    600C20100200404030060100C018202018030080600C201002004040300601002004402018030080600C020180304040080201002008602004008080100
    ...    202018030080600C30100200404030060100C01804030061AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D
    wts_conf.modify    command=ue_param id=3   modification=ue_nr_capabilities=${interRat_ue_cap}
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
    delta_store.delete_param_from_delta             dist_name=${NRBTS_DISTNAME}/NRCELL-1    param_name=nrhoirDNList
    delta_store.delete_param_from_delta             dist_name=${NRBTS_DISTNAME}/NRCELL-3    param_name=nrhoirDNList
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRADJECELL-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRADJECELL-2
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRCELL-1/NRRELE-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRCELL-3/NRRELE-2
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRHOIR-1
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRHOIR-2
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Check if gNB is reachable
    [Arguments]    ${gnb_ip}
    ${output}    Run    ping -c 20 ${gnb_ip}
    Should contain    ${output}    ttl
    Should not contain    ${output}    Destination Host Unreachable
    Should not contain    ${output}    error
