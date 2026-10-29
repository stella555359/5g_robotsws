*** Settings ***
Documentation     author: Venkatesh
...               contact: venkatesh.1.venkatesh@nokia.com
...               Description:

Resource    ./1729_Keywords.robot

Suite Setup       Suite Setup    feature_folder=5GC001729

*** Variables ***
${NUMBER_OF_CELLS}               2
@{dl_tput_list}                  150    150    150
@{multi_dl_tput}                 125
${ul_tput}                       3
@{Non_CA_SA_UE_List}             1
@{Single_CA_SA_UE_List}          3
@{Multi_CA_SA_UE_List}           3    5
@{Single_CA_NSA_UE_List}         11
@{Multi_CA_NSA_UE_List}          11    17
@{SA_Scell_Index}                0    1
@{NSA_Scell_Index}               8    9
@{dl_tput_HO_list}               150    150    150    175    175
${Single_CA_SA_HO_UE}            3
${Single_CA_NSA_HO_UE}           11
${ul_tput_interrat}              1
${ul_tput_anr}                   10

*** Test Cases ***
5GC001729_TC1_Measurement CA and Non CA Activation with beamforming and beamrefinement SANSA For Single UE
    [Documentation]    Verify 2CC TDD Intra Band DL CarrierAggregation Measurement Based SCELL Addition and Buffer
    ...                Based SCELL Activation RLQ Based SCELL Deactivation SCELL Release BeamForming Beamrefinement
    ...                enabled CA n41C 80Mhz 80Mhz
    [Tags]    1729_TC1_SUE
    [Setup]    Test Setup
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform UE Register and Start Traffic For Single SA UE    ${Single_CA_SA_UE_List}    carrier_frequency=522270
    Perform UE Attach and Start Traffic For Single NSA UE    ${Single_CA_NSA_UE_List}    carrier_frequency=522270
    Sleep    90s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Activate testmode    ue_list=${Single_CA_SA_UE_List}    scell_id=@{SA_Scell_Index}
    Activate testmode    ue_list=${Single_CA_NSA_UE_List}    scell_id=@{NSA_Scell_Index}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs    sa_ue_list=${Single_CA_SA_UE_List}
    Perform Stop Traffic and Detach NSA UEs    nsa_ue_list=${Single_CA_NSA_UE_List}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Log To Console    Sleeping for 5min before collecting PM Counters..
    Sleep    300s
    Run Keyword And Ignore Error    Collect Gnb PM Counters    target_dir=${testlog_path}    name=gnb_pm_counters
    Run Keyword And Ignore Error    Validate Gnb PM Counters    sa_ue_list=${Single_CA_SA_UE_List}    counters=${Counter_List}
    ...    counters_dir=${testlog_path}    name=gnb_pm_counters    nsa_ue_list=${Single_CA_NSA_UE_List}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}

5GC001729_TC2_Measurement Based CA and Non CA Activation with beamforming and beamrefinement SANSA For Multiple UEs
    [Documentation]    Verify multiUE data transfer 2CC TDD Intra Band DL CarrierAggregation Measurement Based SCELL
    ...                Addition and Buffer Based SCELL Activation RLQ Based SCELL Deactivation SCELL Release
    ...                BeamForming Beamrefinement enabled CA n41C 80Mhz 80Mhz
    [Tags]    1729_TC2_MUE
    [Setup]    Test Setup
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform UE Register For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform UE Register For Multi SA UEs    ${Multi_CA_SA_UE_List}    carrier_frequency=522270
    Perform UE Attach For Multi NSA UEs    ${Multi_CA_NSA_UE_List}    carrier_frequency=522270
    Start traffic for all UEs    dl_tput_list=${multi_dl_tput}
    Verify scell activated for all UEs
    Sleep    90s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${multi_dl_tput}
    ...    UE_List=${Multi_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${multi_dl_tput}
    ...    UE_List=${Multi_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Activate testmode    ue_list=${Multi_CA_SA_UE_List}    scell_id=@{SA_Scell_Index}
    Activate testmode    ue_list=${Multi_CA_NSA_UE_List}    scell_id=@{NSA_Scell_Index}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs    sa_ue_list=${Multi_CA_SA_UE_List}
    Perform Stop Traffic and Detach NSA UEs    nsa_ue_list=${Multi_CA_NSA_UE_List}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Log To Console    Sleeping for 5min before collecting PM Counters..
    Sleep    300s
    Run Keyword And Ignore Error    Collect Gnb PM Counters    target_dir=${testlog_path}    name=gnb_pm_counters
    Run Keyword And Ignore Error    Validate Gnb PM Counters    sa_ue_list=${Multi_CA_SA_UE_List}    counters=${Counter_List}
    ...    counters_dir=${testlog_path}    name=gnb_pm_counters    nsa_ue_list=${Multi_CA_NSA_UE_List}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Multi_CA_SA_UE_List}    nsa_ue_list=${Multi_CA_NSA_UE_List}

5GC001729_TC3_IntraFrequency_IntergNB_TDD-FR1_TDD_CA_HO_for_SA_NSA_UE
    [Documentation]    Verify IntraFrequency_IntergNB_TDD_-_FR1_TDD_CA_HO_for_SA_NSA_UE
    ...                gNB-2(TDD-1+ FR1TDD),gNB-2x(TDD-2)
    [Tags]    1729_TC3_INTRA_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=5GC001729
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    csi_override=True
    Perform UE Register and Start Traffic For Single SA UE    ${Single_CA_SA_UE_List}    carrier_frequency=522270    handover=True
    Perform UE Attach and Start Traffic For Single NSA UE    ${Single_CA_NSA_UE_List}    carrier_frequency=522270    handover=True
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput_HO_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s
    ...    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput_HO_list}
    ...    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Trigger Intrafreq SA handover from Real gNB to Sim gNB    ue_id_list=${Single_CA_SA_UE_List}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s
    ...    Validate bearer stats output    ue_id=${Single_CA_SA_HO_UE}    expected_dl_tput=${dl_tput_HO_list}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Trigger Intrafreq NSA handover from Real gNB to Sim gNB    ue_id_list=${Single_CA_NSA_UE_List}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s
    ...    Validate bearer stats output    ue_id=${Single_CA_NSA_HO_UE}    expected_dl_tput=${dl_tput_HO_list}
    ...    expected_ul_tput=${ul_tput}    mode=NSA
    Update UE History Information     id=1    cell_type=large    nrcgi=311:489|0x04
    ...    gnb_id=22    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${Single_CA_SA_HO_UE}
    Trigger Intrafreq SA handover from Sim gNB to Real gNB    ue_id=${Single_CA_SA_HO_UE}    scell_index=1
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_HO_list}     UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Update UE History Information     id=2    cell_type=large    nrcgi=311:489|0x06
    ...    gnb_id=24    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${Single_CA_NSA_HO_UE}
    Trigger Intrafreq NSA handover from Sim gNB to Real gNB    ue_id=${Single_CA_NSA_HO_UE}    scell_index=9
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_HO_list}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Update CSI Override parameters    profile_id=5  cqi=1   cqi_max=15    cqi_min=0    cqi_mode=fixed
    Associate UE to testmode    id=${Single_CA_SA_HO_UE}    testmode=csi_override     profile_id=5
    ...    action=activate    scell=1
    Associate UE to testmode    id=${Single_CA_NSA_HO_UE}    testmode=csi_override     profile_id=5
    ...    action=activate    scell=9
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs    sa_ue_list=${Single_CA_SA_UE_List}    carrier_frequency=522270
    Perform Stop Traffic and Detach NSA UEs    nsa_ue_list=${Single_CA_NSA_UE_List}    carrier_frequency=522270
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}

5GC001729_TC4_InterFrequency_IntergNB_TDD-FR1_TDD_CA_HO_for_SA_NSA_UE
    [Documentation]    Verify InterFrequency_IntergNB_TDD-FR1_TDD_CA_HO_for_SA_NSA_UE
    ...                gNB-2(TDD-1+ FR1TDD),gNB-2x(TDD-2)
    [Tags]    1729_TC4_INTER_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=5GC001729
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    csi_override=True
    Perform UE Register and Start Traffic For Single SA UE    ${Single_CA_SA_UE_List}    carrier_frequency=522270    handover=True
    Perform UE Attach and Start Traffic For Single NSA UE    ${Single_CA_NSA_UE_List}    carrier_frequency=522270    handover=True    inter=True
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput_HO_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Wait until keyword succeeds    3min    30s
    ...    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput_HO_list}
    ...    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Trigger Interfreq SA handover from Real gNB to Sim gNB    ue_id=${Single_CA_SA_HO_UE}
    Run keyword And Continue On Failure
    ...     wait until keyword succeeds    3min    30s
    ...    Validate bearer stats output    ue_id=${Single_CA_SA_HO_UE}    expected_dl_tput=${dl_tput_HO_list}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Trigger Interfreq NSA handover from Real gNB to Sim gNB    ue_id=${Single_CA_NSA_HO_UE}
    Run keyword And Continue On Failure
    ...     wait until keyword succeeds    3min    30s
    ...    Validate bearer stats output    ue_id=${Single_CA_NSA_HO_UE}    expected_dl_tput=${dl_tput_HO_list}
    ...    expected_ul_tput=${ul_tput}    mode=NSA
    Trigger Interfreq SA handover from Sim gNB to Real gNB    ue_id=${Single_CA_SA_HO_UE}    scell_index=1
    Run keyword And Continue On Failure
    ...     wait until keyword succeeds    3min    30s    Validate throughput from UE stats and bearer stats for SA UEs
    ...    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput_HO_list}     UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Trigger Interfreq NSA handover from Sim gNB to Real gNB    ue_id=${Single_CA_NSA_HO_UE}     scell_index=9
    Run keyword And Continue On Failure
    ...     wait until keyword succeeds    3min    30s    Validate throughput from UE stats and bearer stats for NSA UEs
    ...    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput_HO_list}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Update CSI Override parameters    profile_id=5    cqi=1    cqi_max=15    cqi_min=0    cqi_mode=fixed
    Associate UE to testmode    id=${Single_CA_SA_HO_UE}    testmode=csi_override     profile_id=5
    ...    action=activate    scell=1
    Associate UE to testmode    id=${Single_CA_NSA_HO_UE}    testmode=csi_override     profile_id=5
    ...    action=activate    scell=9
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs    sa_ue_list=${Single_CA_SA_UE_List}    carrier_frequency=522270
    Perform Stop Traffic and Detach NSA UEs    nsa_ue_list=${Single_CA_NSA_UE_List}    carrier_frequency=522270
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}

5GC001729_TC5_NG_Based_IntraFrequency_IntergNB_TDD-FR1_TDD_CA_HO_for_SA_NSA_UE
    [Documentation]    Verify IntraFrequency_IntergNB_TDD-FR1_TDD_CA_HO_for_SA_NSA_UE
    ...                gNB-2(TDD-1+ FR1TDD),gNB-2x(TDD-2)
    [Tags]    1729_TC5_INTRA_NGbased_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=5GC001729    NGBased_HO=True
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    csi_override=True
    Perform UE Register and Start Traffic For Single SA UE    ${Single_CA_SA_UE_List}    carrier_frequency=522270
    Perform UE Attach and Start Traffic For Single NSA UE    ${Single_CA_NSA_UE_List}    carrier_frequency=522270
    Sleep    90s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Trigger Intrafreq NG Based SA handover from Real gNB to Sim gNB    ue_id=${Single_CA_SA_HO_UE}
    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=3
    Trigger Intrafreq NG Based NSA handover from Real gNB to Sim gNB    ue_id=${Single_CA_NSA_HO_UE}
    Validate throughput from bearer stats    ue_id=${Single_CA_NSA_HO_UE}    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    mode=NSA
    Trigger Intrafreq NG Based SA handover from Sim gNB to Real gNB    ue_id=${Single_CA_SA_HO_UE}    scell_index=1
    Trigger Intrafreq NG Based NSA handover from Sim gNB to Real gNB    ue_id=${Single_CA_NSA_HO_UE}    scell_index=9
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}     UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Update CSI Override parameters    profile_id=5  cqi=1   cqi_max=15    cqi_min=0    cqi_mode=fixed
    Associate UE to testmode    id=${Single_CA_SA_HO_UE}    testmode=csi_override     profile_id=5
    ...    action=activate    scell=1
    Associate UE to testmode    id=${Single_CA_NSA_HO_UE}    testmode=csi_override     profile_id=5
    ...    action=activate    scell=9
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs    sa_ue_list=${Single_CA_SA_UE_List}    carrier_frequency=522270
    Perform Stop Traffic and Detach NSA UEs    nsa_ue_list=${Single_CA_NSA_UE_List}    carrier_frequency=522270
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=5GC001729
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}

5GC001729_TC6_NG_Based_InterFrequency_IntergNB_TDD-FR1_TDD_CA_HO_for_SA_NSA_UE
    [Documentation]    InterFrequency_IntergNB_TDD-FR1_TDD_CA_HO_for_SA_NSA_UE
    ...                gNB-2(TDD-1+ FR1TDD),gNB-2x(TDD-2)
    [Tags]    1729_TC6_INTER_NGbased_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=5GC001729    NGBased_HO=True
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    csi_override=True
    Perform UE Register and Start Traffic For Single SA UE    ${Single_CA_SA_UE_List}    carrier_frequency=522270
    Perform UE Attach and Start Traffic For Single NSA UE    ${Single_CA_NSA_UE_List}    carrier_frequency=522270    inter=True
    Sleep    90s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${ul_tput}
    ...    UE_List=${Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Trigger Interfreq NG Based SA handover from Real gNB to Sim gNB    ue_id=${Single_CA_SA_HO_UE}
    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Trigger Interfreq NG NSA handover from Real gNB to Sim gNB    ue_id=${Single_CA_NSA_HO_UE}
    Validate throughput from bearer stats    ue_id=${Single_CA_NSA_HO_UE}    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput}    mode=NSA
    Trigger Interfreq NG Based SA handover from Sim gNB to Real gNB    ue_id=${Single_CA_SA_HO_UE}    scell_index=1
    Trigger Interfreq NSA handover from Sim gNB to Real gNB    ue_id=${Single_CA_NSA_HO_UE}     scell_index=9    csi_override_needed=True
    Run keyword And Continue On Failure
    ...     wait until keyword succeeds    3min    30s    Validate throughput from UE stats and bearer stats for SA UEs
    ...    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput_list}     UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Run keyword And Continue On Failure
    ...     wait until keyword succeeds    3min    30s    Validate throughput from UE stats and bearer stats for NSA UEs
    ...    expected_ul_tput=${ul_tput}    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Update CSI Override parameters    profile_id=5    cqi=1    cqi_max=15    cqi_min=0    cqi_mode=fixed
    Associate UE to testmode    id=${Single_CA_SA_HO_UE}    testmode=csi_override     profile_id=5
    ...    action=activate    scell=1
    Associate UE to testmode    id=${Single_CA_NSA_HO_UE}    testmode=csi_override     profile_id=5
    ...    action=activate    scell=9
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs    sa_ue_list=${Single_CA_SA_UE_List}    carrier_frequency=522270
    Perform Stop Traffic and Detach NSA UEs    nsa_ue_list=${Single_CA_NSA_UE_List}    carrier_frequency=522270
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=5GC001729
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}

5GC001729_TC7_Inter-RAT_Handover_From_5GC_To_LTE_To_5GC_For_CA_SA_Single_UE
    [Tags]    1729_TC7_INTERRAT_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=5GC001729    interrat_ho=True
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    csi_override=False
    ...    uplink_tput=${ul_tput_interrat}
    Perform UE Register and Start Traffic For Single SA UE    ${Single_CA_SA_UE_List}    carrier_frequency=522270
    ...    handover=False    uplink_tput=${ul_tput_interrat}
    Sleep    90s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput_interrat}    expected_dl_tput=${ul_tput_interrat}
    ...    UE_List=${Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput_interrat}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Trigger InterRAT SA handover from Real gNB to Sim eNB    ue_id=${Single_CA_SA_HO_UE}
    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput_interrat}    mode=SA
    Trigger InterRAT SA handover from Sim eNB to Real gNB    ue_id=${Single_CA_SA_HO_UE}
    Validate throughput from UE stats and bearer stats for SA UEs    expected_ul_tput=${ul_tput_interrat}
    ...    expected_dl_tput=${dl_tput_list}     UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Associate UE to testmode    id=${Single_CA_SA_HO_UE}
    ...    testmode=csi_override     profile_id=2    action=activate    scell=1
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs    sa_ue_list=${Single_CA_SA_UE_List}    carrier_frequency=522270
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=5GC001729    interrat=True
    ...    AND   Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}

5GC001729_TC8_ANR_Inter-RAT_NR-LTE neighbors_Handover_From_5GC_To_LTE_For_CA_SA_Single_UE
    [Tags]    1729_TC8_ANR_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=5GC001729    ANR_IR=True
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    csi_override=False
    ...    uplink_tput=${ul_tput_anr}
    Perform UE Register and Start Traffic For Single SA UE    ${Single_CA_SA_UE_List}    carrier_frequency=522270
    ...    handover=False    uplink_tput=${ul_tput_interrat}
    Sleep    90s
    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput_anr}    expected_dl_tput=${ul_tput_anr}
    ...    UE_List=${Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput_interrat}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Trigger ANR InterRAT SA handover from Real gNB to Sim eNB    ue_id=${Single_CA_SA_HO_UE}
    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${ul_tput_interrat}    mode=SA
    Check if NRADJCELL and NRRELE object is created after Forward HO
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs    sa_ue_list=${Single_CA_SA_UE_List}    carrier_frequency=522270    anr=True
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=5GC001729    ANR_IR=True
    ...    AND   Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
