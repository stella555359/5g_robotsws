*** Settings ***
Documentation     author: Venkatesh
...               contact: venkatesh.1.venkatesh@nokia.com

Resource    ./1390_Keywords.robot

Suite Setup       Suite Setup    feature_folder=5GC001390

*** Variables ***
${dl_tput}                         90
${ul_tput}                         3
@{Non_CA_SA_UE_List}               1
@{Single_CA_SA_UE_List}            3
@{Multi_CA_SA_UE_List}             3    5
@{SA_Scell_Index}                  0    1
@{Single_CA_NSA_UE_List}           17
@{Multi_CA_NSA_UE_List}            11    17
@{NSA_Scell_Index}                 8    9
${CA_SA_UE_ID_HO}                  3
${CA_NSA_UE_ID_HO}                 17
${ul_tput_ng_based}                10
${NUMBER_OF_CELLS}                 2


*** Test Cases ***
5GC001390_TC1_BufferBased CA and Non CA Activation with beamforming and beamrefinement SANSA For Single UE
    [Documentation]    Verify Uplink and Downlink Traffic For BufferBased Scell Activation
    ...                and Deactivation Where two UE's: UE-1_FDD PCell and UE-2_TDD_FR1 Cell
    ...                With Dynamic Data Split Over Pcell and Scell with CA enabled BeamForming
    ...                and BeamRefinement for SANSA
    [Tags]    1390_TC1_SUE
    [Setup]    Test Setup
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${ul_tput}    ${ul_tput}
    Perform UE Register and Start Traffic For SA UEs    ${Single_CA_SA_UE_List}
    Perform UE Attach and Start Traffic For NSA UEs    ${Single_CA_NSA_UE_List}
    Sleep    90s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput}
    ...    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs    ${Single_CA_SA_UE_List}
    Perform Stop Traffic and Detach NSA UEs    ${Single_CA_NSA_UE_List}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Log To Console    Sleeping for 5min before collecting PM Counters..
    Sleep    300s
    Run Keyword And Ignore Error    Collect Gnb PM Counters    target_dir=${testlog_path}    name=gnb_pm_counters
    Run Keyword And Ignore Error    Validate Gnb PM Counters    sa_ue_list=${Single_CA_SA_UE_List}    counters=${FR1390_Counter_List}
    ...    counters_dir=${testlog_path}    name=gnb_pm_counters    nsa_ue_list=${Single_CA_NSA_UE_List}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}

5GC001390_TC2_BufferBased CA and Non CA Activation with beamforming and beamrefinement SANSA For Multiple UEs
    [Documentation]    Verify Uplink and Downlink Traffic For BufferBased Scell Activation
    ...                and Deactivation Where two UE's: UE-1_FDD PCell and UE-2_TDD_FR1 Cell
    ...                With Dynamic Data Split Over Pcell and Scell with CA enabled BeamForming
    ...                and BeamRefinement for SANSA
    [Tags]    AP_REG    1390_TC2_MUE
    [Setup]    Test Setup
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${ul_tput}    ${ul_tput}
    Perform UE Register and Start Traffic For SA UEs    ${Multi_CA_SA_UE_List}
    Perform UE Attach and Start Traffic For NSA UEs    ${Multi_CA_NSA_UE_List}
    Sleep    90s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput}
    ...    UE_List=${Multi_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput}
    ...    UE_List=${Multi_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs    ${Multi_CA_SA_UE_List}
    Perform Stop Traffic and Detach NSA UEs    ${Multi_CA_NSA_UE_List}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Log To Console    Sleeping for 5min before collecting PM Counters..
    Sleep    300s
    Run Keyword And Ignore Error    Collect Gnb PM Counters    target_dir=${testlog_path}    name=gnb_pm_counters
    Run Keyword And Ignore Error    Validate Gnb PM Counters    sa_ue_list=${Multi_CA_SA_UE_List}    counters=${FR1390_Counter_List}
    ...    counters_dir=${testlog_path}    name=gnb_pm_counters    nsa_ue_list=${Multi_CA_NSA_UE_List}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Multi_CA_SA_UE_List}    nsa_ue_list=${Multi_CA_NSA_UE_List}

5GC001390_TC3_IntraFrequency_IntergNB_FDD_-_FR1_TDD_CA_HO_for_SA_NSA_UE
    [Documentation]    Verify IntraFrequency_IntergNB_FDD_-_FR1_TDD_CA_HO_for_SA_NSA_UE
    ...                gNB-2(FDD-1+ FR1TDD),gNB-22(FDD-2)
    [Tags]    AP_REG    1390_TC3_INTRA_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=5GC001390
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${ul_tput}    ${ul_tput}
    Perform UE Register and Start Traffic For SA UEs    ${Single_CA_SA_UE_List}
    Perform UE Attach and Start Traffic For NSA UEs    ${Single_CA_NSA_UE_List}
    Sleep    90s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput}
    ...    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Trigger Intrafreq SA handover from Real gNB to Sim gNB    ue_id_list=${Single_CA_SA_UE_List}
    Validate throughput from bearer stats    ue_id=${CA_SA_UE_ID_HO}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Trigger Intrafreq NSA handover from Real gNB to Sim gNB    ue_id_list=${Single_CA_NSA_UE_List}
    Validate throughput from bearer stats    ue_id=${CA_NSA_UE_ID_HO}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=NSA
    Update UE History Information     id=1    cell_type=large    nrcgi=311:489|0x04
    ...    gnb_id=22    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${CA_SA_UE_ID_HO}
    Trigger Intrafreq SA handover from Sim gNB to Real gNB    ue_id=${CA_SA_UE_ID_HO}
    Run keyword And Continue On Failure
    ...     wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput}     UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Trigger Intrafreq NSA handover from Sim gNB to Real gNB     history_info_id=1    action=commit     ue_id=${CA_NSA_UE_ID_HO}
    Run keyword And Continue On Failure
    ...     wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs    ${Single_CA_SA_UE_List}
    Perform Stop Traffic and Detach NSA UEs    ${Single_CA_NSA_UE_List}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}    handover=True

5GC001390_TC4_InterFrequency_IntergNB_FDD_-_FR1_TDD_CA_HO_MeasGap_for_SA_NSA_UE
    [Documentation]    Verify InterFrequency_IntergNB_FDD_-_FR1_TDD_CA_HO_MeasGap_for_SA_NSA_UE
    ...                gNB-2(FDD-1+ FR1TDD),gNB-23(FDD-2)
    [Tags]    AP_REG    1390_TC4_INTER_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=5GC001390
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${ul_tput}    ${ul_tput}
    Perform UE Register and Start Traffic For SA UEs    ${Single_CA_SA_UE_List}
    Perform UE Attach and Start Traffic For NSA UEs    ${Single_CA_NSA_UE_List}
    Sleep    90s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput}
    ...    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Trigger Interfreq SA handover from Real gNB to Sim gNB    ue_id=${CA_SA_UE_ID_HO}
    Validate throughput from bearer stats    ue_id=${CA_SA_UE_ID_HO}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Trigger Interfreq NSA handover from Real gNB to Sim gNB    ue_id=${CA_NSA_UE_ID_HO}
    Validate throughput from bearer stats    ue_id=${CA_NSA_UE_ID_HO}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=NSA
    Update UE History Information    id=1    cell_type=large    nrcgi=311:489|0x05
    ...    gnb_id=23    time_ue_stayed_in_cell=98    action=commit    ue_enb_param_id=${CA_SA_UE_ID_HO}
    Trigger Interfreq SA handover from Sim gNB to Real gNB    ue_id=${CA_SA_UE_ID_HO}
    Run keyword And Continue On Failure
    ...     wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...        expected_dl_tput=${dl_tput}     UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Trigger Interfreq NSA handover from Sim gNB to Real gNB     ue_id=${CA_NSA_UE_ID_HO}
    Run keyword And Continue On Failure
    ...     wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs    ${Single_CA_SA_UE_List}
    Perform Stop Traffic and Detach NSA UEs    ${Single_CA_NSA_UE_List}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}    handover=True

5GC001390_TC5_IntraFrequency_IntergNB_NG_Based_FDD_-_FR1_TDD_CA_HO_for_SA_NSA_UE
    [Tags]    AP_REG    1390_TC5_INTRA_NGBased_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=5GC001390    NGBased_HO=True
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    uplink_tput=${ul_tput_ng_based}
    ...    downlink_tput=${ul_tput_ng_based}
    Perform UE Register and Start Traffic For SA UEs    ${Single_CA_SA_UE_List}    uplink_tput=${ul_tput_ng_based}
    Perform UE Attach and Start Traffic For NSA UEs    ${Single_CA_NSA_UE_List}    uplink_tput=${ul_tput_ng_based}
    Sleep    60s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput_ng_based}    expected_dl_tput=${ul_tput_ng_based}
    ...    UE_List=${Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput_ng_based}    expected_dl_tput=${dl_tput}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput_ng_based}    expected_dl_tput=${dl_tput}
    ...    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Trigger Intrafreq NG Based SA handover from Real gNB to Sim gNB    ue_id=${CA_SA_UE_ID_HO}
    Validate throughput from bearer stats    ue_id=${CA_SA_UE_ID_HO}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput_ng_based}    mode=SA
    Trigger Intrafreq NG Based NSA handover from Real gNB to Sim gNB    ue_id=${CA_NSA_UE_ID_HO}
    Validate throughput from bearer stats    ue_id=${CA_NSA_UE_ID_HO}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput_ng_based}    mode=NSA
    Trigger Intrafreq NG Based SA handover from Sim gNB to Real gNB    ue_id=${CA_SA_UE_ID_HO}
    Run keyword And Continue On Failure
    ...     wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput_ng_based}
    ...    expected_dl_tput=${dl_tput}     UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Trigger Intrafreq NSA handover from Sim gNB to Real gNB     history_info_id=1    action=commit    ue_id=${CA_NSA_UE_ID_HO}
    Run keyword And Continue On Failure
    ...     wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput_ng_based}
    ...    expected_dl_tput=${dl_tput}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs    ${Single_CA_SA_UE_List}
    Perform Stop Traffic and Detach NSA UEs    ${Single_CA_NSA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=5GC001390
    ...    AND   Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}    handover=True

5GC001390_TC6_InterFrequency_IntergNB_NGBased_FDD_-_FR1_TDD_CA_HO_MeasGap_for_SA_NSA_UE
    [Tags]    AP_REG    1390_TC6_INTER_NGBased_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=5GC001390    NGBased_HO=True
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    uplink_tput=${ul_tput_ng_based}
    ...    downlink_tput=${ul_tput_ng_based}
    Perform UE Register and Start Traffic For SA UEs    ${Single_CA_SA_UE_List}    uplink_tput=${ul_tput_ng_based}
    Perform UE Attach and Start Traffic For NSA UEs    ${Single_CA_NSA_UE_List}    uplink_tput=${ul_tput_ng_based}
    Sleep    60s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput_ng_based}    expected_dl_tput=${ul_tput_ng_based}
    ...    UE_List=${Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput_ng_based}    expected_dl_tput=${dl_tput}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput_ng_based}    expected_dl_tput=${dl_tput}
    ...    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Trigger Interfreq NG Based SA handover from Real gNB to Sim gNB    ue_id=${CA_SA_UE_ID_HO}
    Validate throughput from bearer stats    ue_id=${CA_SA_UE_ID_HO}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput_ng_based}    mode=SA
    Trigger Interfreq NSA handover from Real gNB to Sim gNB    ue_id=${CA_NSA_UE_ID_HO}
    Validate throughput from bearer stats    ue_id=${CA_NSA_UE_ID_HO}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput_ng_based}    mode=NSA
    Trigger Interfreq NG Based SA handover from Sim gNB to Real gNB    ue_id=${CA_SA_UE_ID_HO}
    Run keyword And Continue On Failure
    ...     wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput_ng_based}
    ...        expected_dl_tput=${dl_tput}     UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Trigger Interfreq NSA handover from Sim gNB to Real gNB     ue_id=${CA_NSA_UE_ID_HO}    carrier_freq_A2=${NGBased_NSA_A2_Carr_Freq}
    Run keyword And Continue On Failure
    ...     wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput_ng_based}
    ...    expected_dl_tput=${dl_tput}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs    ${Single_CA_SA_UE_List}
    Perform Stop Traffic and Detach NSA UEs    ${Single_CA_NSA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=5GC001390
    ...    AND   Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}    handover=True

5GC001390_TC7_Inter-RAT_Handover_From_5GC_To_LTE_To_5GC_For_CA_SA_Single_UE
    [Tags]    AP_REG    1390_TC7_INTERRAT_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=5GC001390    interrat_ho=True
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    uplink_tput=${ul_tput_ng_based}
    ...    downlink_tput=${ul_tput_ng_based}
    Perform UE Register and Start Traffic For SA UEs    ${Single_CA_SA_UE_List}    uplink_tput=${ul_tput_ng_based}
    Sleep    60s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput_ng_based}    expected_dl_tput=${ul_tput_ng_based}
    ...    UE_List=${Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput_ng_based}    expected_dl_tput=${dl_tput}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Trigger InterRAT SA handover from Real gNB to Sim eNB    ue_id=${CA_SA_UE_ID_HO}
    Validate throughput from bearer stats    ue_id=${CA_SA_UE_ID_HO}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput_ng_based}    mode=SA
    Trigger InterRAT SA handover from Sim eNB to Real gNB    ue_id=${CA_SA_UE_ID_HO}
    Run keyword And Continue On Failure
    ...     wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput_ng_based}
    ...        expected_dl_tput=${dl_tput}     UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs    ${Single_CA_SA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=5GC001390    interrat=True
    ...    AND   Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}    handover=True

5GC001390_TC8_ANR_Inter-RAT_NR-LTE neighbors_Handover_From_5GC_To_LTE_For_CA_SA_Single_UE
    [Tags]    1390_TC8_ANR_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=5GC001390    ANR_IR=True
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    uplink_tput=${ul_tput_ng_based}
    ...    downlink_tput=${ul_tput_ng_based}
    Perform UE Register and Start Traffic For SA UEs    ${Single_CA_SA_UE_List}    uplink_tput=${ul_tput_ng_based}
    Sleep    60s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput_ng_based}    expected_dl_tput=${ul_tput_ng_based}
    ...    UE_List=${Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput_ng_based}    expected_dl_tput=${dl_tput}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Trigger ANR InterRAT SA handover from Real gNB to Sim eNB    ue_id=${CA_SA_UE_ID_HO}
    Validate throughput from bearer stats    ue_id=${CA_SA_UE_ID_HO}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput_ng_based}    mode=SA
    Check if NRADJCELL and NRRELE object is created after Forward HO
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs    sa_ue_list=${Single_CA_SA_UE_List}    anr_ir=True
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=5GC001390    ANR_IR=True
    ...    AND   Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}    handover=True
