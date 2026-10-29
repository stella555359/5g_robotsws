*** Settings ***
Documentation     author: Merin
...               contact: merin.varghese@nokia.com

Resource    ./2329_Keywords.robot

Suite Setup       Suite Setup    feature_folder=5GC002329

*** Variables ***
${ul_tput}                         3
@{SA_Scell_Index}                  0    1
@{dl_tput_list}                    150    150    150
@{FR2329_Non_CA_SA_UE_List}        4
@{FR2329_Single_CA_SA_UE_List}     20
@{FR2329_Multi_CA_SA_UE_List}      20    21    22
${FR2329_CA_SA_UE_ID_HO}           20
${ul_tput_interrat}                10
${plmn}                            311:489
${WTS_CFG_PATH}                    ${CURDIR}/cfg
${interrat_gnb_delta_json}         ${WTS_CFG_PATH}/InterRAT_2329_delta.json
${NUMBER_OF_CELLS}                 2

*** Test Cases ***
5GC002329_TC1_Measurement CA and Non CA Activation with beamforming and beamrefinement SA For Single UE
    [Documentation]    Verify Uplink and Downlink Traffic For Measurement Based Scell Addition
    ...                and Release Buffer based Scell Activation and Deactivation Where two UE's: UE-1_TDD FR1 PCell
    ...                and UE-2_FDD With Dynamic Data Split Over Pcell and Scell with CA enabled BeamForming
    ...                and BeamRefinement for SA
    [Tags]    2329_TC1_SUE
    [Setup]    Test Setup
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${FR2329_Non_CA_SA_UE_List}    ${ul_tput}    ${ul_tput}
    Perform Register and Start Traffic For SA UEs    ${FR2329_Single_CA_SA_UE_List}
    Sleep    90s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${FR2329_Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For Single and Multiple SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${FR2329_Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${FR2329_Non_CA_SA_UE_List}
    Perform Stop Traffic with UE Measurements and Detach SA UEs    ${FR2329_Single_CA_SA_UE_List}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Log To Console    Sleeping for 5min before collecting PM Counters..
    Sleep    300s
    Run Keyword And Ignore Error    Collect Gnb PM Counters    target_dir=${testlog_path}    name=gnb_pm_counters
    Run Keyword And Ignore Error    Validate Gnb PM Counters    sa_ue_list=${FR2329_Single_CA_SA_UE_List}    counters=${FR2329_Counter_List}
    ...    counters_dir=${testlog_path}    name=gnb_pm_counters
    [Teardown]    Test Teardown    sa_nonca_ue_list=${FR2329_Non_CA_SA_UE_List}    sa_ue_list=${FR2329_Single_CA_SA_UE_List}

5GC002329_TC2_Measurement Based CA and Non CA Activation with beamforming and beamrefinement SA For Multiple UEs
    [Documentation]    Verify UL/DL Traffic For Measurement Based 4UEs-3 Ues (TDD FR1 capable)
    ...                and 1 UE(FDD Non CA capable) CA Related Features Enabled with
    ...                Beamforming With Scell Release
    [Tags]    AP_REG    2329_TC2_MUE
    [Setup]    Test Setup
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${FR2329_Non_CA_SA_UE_List}    ${ul_tput}    ${ul_tput}
    Perform Register and Start Traffic For SA UEs    ${FR2329_Multi_CA_SA_UE_List}
    Sleep    90s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${FR2329_Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For Single and Multiple SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${FR2329_Multi_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${FR2329_Non_CA_SA_UE_List}
    Perform Stop Traffic with UE Measurements and Detach SA UEs    ${FR2329_Multi_CA_SA_UE_List}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Log To Console    Sleeping for 5min before collecting PM Counters..
    Sleep    300s
    Run Keyword And Ignore Error    Collect Gnb PM Counters    target_dir=${testlog_path}    name=gnb_pm_counters
    Run Keyword And Ignore Error    Validate Gnb PM Counters    sa_ue_list=${FR2329_Multi_CA_SA_UE_List}    counters=${FR2329_Counter_List}
    ...    counters_dir=${testlog_path}    name=gnb_pm_counters
    [Teardown]    Test Teardown    sa_nonca_ue_list=${FR2329_Non_CA_SA_UE_List}    sa_ue_list=${FR2329_Multi_CA_SA_UE_List}

5GC002329_TC3_IntraFrequency_IntergNB_TDD_-_FR1_FDD_CA_HO_for_SA_UE
    [Documentation]    Verify IntraFrequency_IntergNB_TDD_-_FR1_FDD_CA_HO_for_SA_UE
    ...                gNB-2(TDD-1+ FR1FDD),gNB-22(TDD-2)
    [Tags]    AP_REG    2329_TC3_INTRA_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=5GC002329
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${FR2329_Non_CA_SA_UE_List}    ${ul_tput}    ${ul_tput}
    Perform Register and Start Traffic For SA UEs    ${FR2329_Single_CA_SA_UE_List}
    Sleep    90s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${FR2329_Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For Single and Multiple SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${FR2329_Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Trigger Intrafreq SA handover from Real gNB to Sim gNB FR2329   ue_id_list=${FR2329_Single_CA_SA_UE_List}
    Validate throughput from bearer stats    ue_id=${FR2329_CA_SA_UE_ID_HO}    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=3
    Update UE History Information    id=1    cell_type=large    nrcgi=311:489|0x08
    ...    gnb_id=22    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${FR2329_CA_SA_UE_ID_HO}
    Trigger Intrafreq SA handover from Sim gNB to Real gNB FR2329   ue_id=${FR2329_CA_SA_UE_ID_HO}    scell_index=1
    Validate Pcell and Scell Throughput For Single and Multiple SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${FR2329_Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${FR2329_Non_CA_SA_UE_List}
    Perform Stop Traffic with UE Measurements and Detach SA UEs    ${FR2329_Single_CA_SA_UE_List}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${FR2329_Non_CA_SA_UE_List}    sa_ue_list=${FR2329_Single_CA_SA_UE_List}

5GC002329_TC4_InterFrequency_IntergNB_TDD_-_FR1_FDD_CA_HO_for_SA_UE
    [Documentation]    Verify InterFrequency_IntergNB_TDD_-_FR1_FDD_CA_HO_for_SA_UE
    ...                gNB-2(TDD-1+ FR1FDD),gNB-23(TDD-2)
    [Tags]    AP_REG    2329_TC4_INTER_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=5GC002329
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${FR2329_Non_CA_SA_UE_List}    ${ul_tput}    ${ul_tput}
    Perform Register and Start Traffic For SA UEs    ${FR2329_Single_CA_SA_UE_List}
    Sleep    90s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${FR2329_Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For Single and Multiple SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${FR2329_Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Trigger Interfreq SA handover from Real gNB to Sim gNB FR2329    ue_id=${FR2329_CA_SA_UE_ID_HO}
    Validate throughput from bearer stats    ue_id=${FR2329_CA_SA_UE_ID_HO}    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=3
    Update UE History Information    id=1    cell_type=large    nrcgi=311:489|0x09
    ...    gnb_id=23    time_ue_stayed_in_cell=98    action=commit    ue_enb_param_id=${FR2329_CA_SA_UE_ID_HO}
    Trigger Interfreq SA handover from Sim gNB to Real gNB FR2329    ue_id=${FR2329_CA_SA_UE_ID_HO}    scell_index=1
    Validate Pcell and Scell Throughput For Single and Multiple SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${FR2329_Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${FR2329_Non_CA_SA_UE_List}
    Perform Stop Traffic with UE Measurements and Detach SA UEs    ${FR2329_Single_CA_SA_UE_List}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${FR2329_Non_CA_SA_UE_List}    sa_ue_list=${FR2329_Single_CA_SA_UE_List}

5GC002329_TC5_IntraFrequency_IntergNB_NGbased_TDD-FR1_FDD_CA_HO_for_SA_UE
    [Documentation]    Verify IntraFrequency_IntergNB_NGbased_TDD_-_FR1_FDD_CA_HO_for_SA_UE
    ...                gNB-2(TDD-1+ FR1FDD),gNB-22(TDD-2)
    [Tags]    AP_REG    2329_TC5_INTRA_NGbased_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=5GC002329    NGBased_HO=True
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${FR2329_Non_CA_SA_UE_List}    ${ul_tput}    ${ul_tput}
    Perform Register and Start Traffic For SA UEs    ${FR2329_Single_CA_SA_UE_List}
    Sleep    30s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${FR2329_Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For Single and Multiple SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${FR2329_Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Trigger Intrafreq NG Based SA handover from Real gNB2 cell1 to sim gNB22 cell2    ue_id=${FR2329_CA_SA_UE_ID_HO}
    Validate throughput from bearer stats    ue_id=${FR2329_CA_SA_UE_ID_HO}    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=3
    Trigger Intrafreq NG Based SA handover from sim gNB22 Cell2 to Real gNB2 Cell1    ue_id=${FR2329_CA_SA_UE_ID_HO}
    Trigger Scell Addition to activate Scell    sa_ue_list=${FR2329_Single_CA_SA_UE_List}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds   3min    30s    Validate Pcell and Scell Throughput For Single and Multiple SA UEs
    ...    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput_list}    UE_List=${FR2329_Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${FR2329_Non_CA_SA_UE_List}
    Perform Stop Traffic with UE Measurements and Detach SA UEs    ${FR2329_Single_CA_SA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=5GC002329
    ...    AND   Test Teardown    sa_nonca_ue_list=${FR2329_Non_CA_SA_UE_List}    sa_ue_list=${FR2329_Single_CA_SA_UE_List}    handover=True

5GC002329_TC6_InterFrequency_IntergNB_NGbased_TDD-FR1_FDD_CA_HO_for_SA_UE
    [Documentation]    Verify InterFrequency_IntergNB_NGbased_TDD_-_FR1_FDD_CA_HO_for_SA_UE
    ...                gNB-2(TDD-1+ FR1FDD),gNB-23(TDD-2)
    [Tags]    AP_REG    2329_TC6_INTER_NGbased_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=5GC002329    NGBased_HO=True
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${FR2329_Non_CA_SA_UE_List}    ${ul_tput}    ${ul_tput}
    Perform Register and Start Traffic For SA UEs    ${FR2329_Single_CA_SA_UE_List}
    Sleep    30s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${FR2329_Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For Single and Multiple SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${FR2329_Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Trigger Interfreq NG Based SA handover from Real gNB2 cell1 to sim gNB23 cell2    ue_id=${FR2329_CA_SA_UE_ID_HO}
    Validate throughput from bearer stats    ue_id=${FR2329_CA_SA_UE_ID_HO}    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=3
    Trigger Interfreq NG Based SA handover from sim gNB23 Cell2 to Real gNB2 Cell1    ue_id=${FR2329_CA_SA_UE_ID_HO}
    Trigger Scell Addition to activate Scell    sa_ue_list=${FR2329_Single_CA_SA_UE_List}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds   3min    30s    Validate Pcell and Scell Throughput For Single and Multiple SA UEs
    ...    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput_list}    UE_List=${FR2329_Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${FR2329_Non_CA_SA_UE_List}
    Perform Stop Traffic with UE Measurements and Detach SA UEs    ${FR2329_Single_CA_SA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=5GC002329
    ...    AND   Test Teardown    sa_nonca_ue_list=${FR2329_Non_CA_SA_UE_List}    sa_ue_list=${FR2329_Single_CA_SA_UE_List}    handover=True

5GC002329_TC7_Inter-RAT_Handover_From_5GC_To_LTE_To_5GC_For_CA_SA_Single_UE
    [Tags]    AP_REG    2329_TC7_INTERRAT_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=5GC002329    interrat_ho=True
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${FR2329_Non_CA_SA_UE_List}    ${ul_tput_interrat}    ${ul_tput_interrat}
    Perform Register and Start Traffic For SA UEs    ${FR2329_Single_CA_SA_UE_List}    ${ul_tput_interrat}
    Sleep    30s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput_interrat}    expected_dl_tput=${ul_tput_interrat}
    ...    UE_List=${FR2329_Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For Single and Multiple SA UEs    expected_ul_tput=${ul_tput_interrat}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${FR2329_Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    2329_Keywords.Trigger InterRAT SA handover from Real gNB to Sim eNB    ue_id=${FR2329_CA_SA_UE_ID_HO}
    Validate throughput from bearer stats    ue_id=${FR2329_CA_SA_UE_ID_HO}    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput_interrat}    mode=SA    pdu_id=3
    2329_Keywords.Trigger InterRAT SA handover from Sim eNB to Real gNB     ue_id=${FR2329_CA_SA_UE_ID_HO}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds   3min    30s    Validate Pcell and Scell Throughput For Single and Multiple SA UEs
    ...    expected_ul_tput=${ul_tput_interrat}    expected_dl_tput=${dl_tput_list}    UE_List=${FR2329_Single_CA_SA_UE_List}
    ...    Scell_Id=${SA_Scell_Index}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${FR2329_Non_CA_SA_UE_List}
    Perform Stop Traffic with UE Measurements and Detach SA UEs    ${FR2329_Single_CA_SA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=5GC002329    interrat=True
    ...    AND   Test Teardown    sa_nonca_ue_list=${FR2329_Non_CA_SA_UE_List}    sa_ue_list=${FR2329_Single_CA_SA_UE_List}    handover=True

5GC002329_TC8_ANR_Inter-RAT_NR-LTE neighbors_Handover_From_5GC_To_LTE_For_CA_SA_Single_UE
    [Tags]    AP_REG    2329_TC8_ANR_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=5GC002329    ANR_IR=True
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${FR2329_Non_CA_SA_UE_List}    ${ul_tput_interrat}    ${ul_tput_interrat}
    Perform Register and Start Traffic For SA UEs    ${FR2329_Single_CA_SA_UE_List}    ${ul_tput_interrat}
    Sleep    30s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput_interrat}    expected_dl_tput=${ul_tput_interrat}
    ...    UE_List=${FR2329_Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For Single and Multiple SA UEs    expected_ul_tput=${ul_tput_interrat}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${FR2329_Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    2329_Keywords.Trigger ANR InterRAT SA handover from Real gNB to Sim eNB    ue_id=${FR2329_CA_SA_UE_ID_HO}
    Validate throughput from bearer stats    ue_id=${FR2329_CA_SA_UE_ID_HO}    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput_interrat}    mode=SA    pdu_id=3
    Check if NRADJCELL and NRRELE object is created after Forward HO    feature_id=5GC002329
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${FR2329_Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs ANR    sa_ue_list=${FR2329_Single_CA_SA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=5GC002329    ANR_IR=True
    ...    AND   Test Teardown    sa_nonca_ue_list=${FR2329_Non_CA_SA_UE_List}    sa_ue_list=${FR2329_Single_CA_SA_UE_List}    handover=True
