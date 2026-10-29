*** Settings ***
Documentation     author: Merin Varghese
...               contact: merin.varghese@nokia.com
...               Description:

Resource    ./CB007922_Keywords.robot
Resource    ../../../Resources/robot/gnb.robot

Suite Setup       Suite Setup    feature_folder=CB007922

*** Variables ***
${NUMBER_OF_CELLS}               2
${No_of_cells_Sib_decoding_cell_dep_NSA}    1
@{dl_tput_list}                  150    150    150
@{multi_dl_tput}                 125
${ul_tput}                       3
@{Non_CA_SA_UE_List}             1
@{Non_CA_NSA_UE_List}            15
@{Single_CA_SA_UE_List}          3
@{Multi_CA_SA_UE_List}           3    5
@{Single_CA_NSA_UE_List}         11
@{Multi_CA_NSA_UE_List}          11    17
@{dl_tput_HO_list}               150    150    150    175    175
${Single_CA_SA_HO_UE}            3
${Single_CA_NSA_HO_UE}           11
${ul_tput_interrat}              1
${ul_tput_anr}                   10
@{scell_index_list}              1
@{dl_tput_list_APoABIO}                150    150    150    150
@{dl_tput_list_tc18}                   150    150    150    150    150    150
@{multi_dl_tput_APoABIO}               150    100
@{multi_dl_tput_NSA_dep}               150    150    150
@{dl_tput_NSA_dep}                     150    150    150    150    150    150
${A1_real_gnb_carrier_freq_APoABIO}    650016
${A2_real_gnb_carrier_freq_APoABIO}    636576
${A3_real_gnb_carrier_freq_APoABIO}    629952
@{dl_tput_list_Blind_BufferBased_RLQ}    175    175    175    175
@{dl_tput_list_tc14}                   175    175    175    175
${no_of_time_lock_unlock}        2
@{param_list}                    administrativeState
${RI_PWR}                        SEPARATOR=
...                              -55,-60,-65,-70,-75,-80,-85,-90,-95,-100,-105,-110,-115,-115,-115,-115,-115,-115,-115,-115,-115,
...                              -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115

*** Test Cases ***
CB007922_TC1_Measurement CA and Non CA with beamforming and beam refinement SANSA For Single UE
    [Documentation]    Verify 2CC TDD Intra Band DL CarrierAggregation Measurement Based SCELL Addition and Buffer
    ...                Based SCELL Activation RLQ Based SCELL Deactivation SCELL Release BeamForming Beamrefinement
    ...                enabled CA n41C 80Mhz 80Mhz
    [Tags]    CB007922_TC1    CA_Types
    [Setup]    Test Setup    dl_tput_list=@{dl_tput_list_APoABIO}
    ...     A1_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}    A2_carrier_freq=${A2_real_gnb_carrier_freq_APoABIO}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    csi_override=True
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Single_CA_SA_UE_List}    ${A1_carrier_freq}
    Start Traffic and Validate Scell Activation for SA UE    ue_id_list=${Single_CA_SA_UE_List}
    Perform NSA UE Attach for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Single_CA_NSA_UE_List}    ${A1_carrier_freq}
    Start Traffic and Validate Scell Activation for NSA UE    ue_id_list=${Single_CA_NSA_UE_List}
    Sleep    90s
    Run keyword And Continue On Failure    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Activate testmode    ue_list=${Single_CA_SA_UE_List}    scell_id=@{SA_Scell_Index}
    Activate testmode    ue_list=${Single_CA_NSA_UE_List}    scell_id=@{NSA_Scell_Index}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    ${Single_CA_SA_UE_List}    ${A2_carrier_freq}
    Stop Traffic and Detach NSA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    ${Single_CA_NSA_UE_List}    ${A2_carrier_freq}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Log To Console    Sleeping for 5min before collecting PM Counters..
    Sleep    300s
    Run Keyword And Ignore Error    Collect Gnb PM Counters    target_dir=${testlog_path}    name=gnb_pm_counters
    Run Keyword And Ignore Error    Validate Gnb PM Counters    sa_ue_list=${Single_CA_SA_UE_List}    counters=${Counter_List}
    ...    counters_dir=${testlog_path}    name=gnb_pm_counters    nsa_ue_list=${Single_CA_NSA_UE_List}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}

CB007922_TC2_Measurement Based CA and Non CA with beamforming and beam refinement SANSA For Multiple UEs
    [Documentation]    Verify multiUE data transfer 2CC TDD Intra Band DL CarrierAggregation Measurement Based SCELL
    ...                Addition and Buffer Based SCELL Activation RLQ Based SCELL Deactivation SCELL Release
    ...                BeamForming Beamrefinement enabled CA n41C 80Mhz 80Mhz
    [Tags]    AP_REG    CB007922_TC2    CA_Types
    [Setup]    Test Setup    dl_tput_list=@{multi_dl_tput_APoABIO}
    ...     A1_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}    A2_carrier_freq=${A2_real_gnb_carrier_freq_APoABIO}
    Run Keyword If    'AP_KLLL' in '${TOPOLOGY}'    Set Test Variable    ${dl_tput_list}    @{multi_dl_tput}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform UE Register For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Multi_CA_SA_UE_List}    ${A1_carrier_freq}
    Perform NSA UE Attach for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Multi_CA_NSA_UE_List}    ${A1_carrier_freq}
    Start traffic for all UEs
    Verify scell activated for all UEs
    Sleep    90s
    Run keyword And Continue On Failure    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Multi_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Multi_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Activate testmode    ue_list=${Multi_CA_SA_UE_List}    scell_id=@{SA_Scell_Index}
    Activate testmode    ue_list=${Multi_CA_NSA_UE_List}    scell_id=@{NSA_Scell_Index}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    ${Multi_CA_SA_UE_List}    ${A2_carrier_freq}
    Stop Traffic and Detach NSA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    ${Multi_CA_NSA_UE_List}    ${A2_carrier_freq}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Log To Console    Sleeping for 5min before collecting PM Counters..
    Sleep    300s
    Run Keyword And Ignore Error    Collect Gnb PM Counters    target_dir=${testlog_path}    name=gnb_pm_counters
    Run Keyword And Ignore Error    Validate Gnb PM Counters    sa_ue_list=${Multi_CA_SA_UE_List}    counters=${Counter_List}
    ...    counters_dir=${testlog_path}    name=gnb_pm_counters    nsa_ue_list=${Multi_CA_NSA_UE_List}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Multi_CA_SA_UE_List}    nsa_ue_list=${Multi_CA_NSA_UE_List}

CB007922_TC3_Cell Deployment_SANSA_Blind and BlindBased CA and Non CA Activation with beamforming and beam refinement For Single UE
    [Tags]    AP_REG    CB007922_TC3    CA_Types
    [Setup]    Test Setup    cell_deployment=SANSA    sCellAdditionMethod=${TC3_sCellAdditionMethod}
    ...   sCellActivationMethod=${TC3_sCellActivationMethod}    sCellDeactivationTimerGNB=${TC3_sCellDeactivationTimerGNB}
    ...    dl_tput_list=@{dl_tput_list_APoABIO}
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform SA UE Register and start traffic for Blind ScellAddition and Blind ScellActivation    ${Single_CA_SA_UE_List}
    Perform NSA UE Attach and start traffic for Blind ScellAddition and Blind ScellActivation    ${Single_CA_NSA_UE_List}
    Sleep    90s
    Run keyword And Continue On Failure    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Single_CA_SA_UE_List}
    Perform Stop Traffic and Detach NSA UEs for Blind ScellAddition    ${Single_CA_NSA_UE_List}
    [Teardown]    run keywords    Revert Gnb Configuration for LOKI cell deployment sansa
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}

CB007922_TC4_Cell Deployment_SANSA_Blind and BufferBased CA and Non CA Activation with beamforming and beam refinement For Multi UEs
    [Tags]    AP_REG    CB007922_TC4    CA_Types
    [Setup]    Test Setup    cell_deployment=SANSA    sCellAdditionMethod=${TC4_sCellAdditionMethod}
    ...   sCellActivationMethod=${TC4_sCellActivationMethod}
    ...    dl_tput_list=@{multi_dl_tput_APoABIO}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform UE Register For SA Non CA Capable UEs     ${Non_CA_SA_UE_List}
    Perform SA UE Register for Blind ScellAddition and Bufferbased ScellActivation with CSI Override    ${Multi_CA_SA_UE_List}
    Perform NSA UE Attach for Blind ScellAddition and Bufferbased ScellActivation with CSI Override    ${Multi_CA_NSA_UE_List}
    Start traffic for all UEs
    Verify scell activated for all UEs
    Sleep    90s
    Run keyword And Continue On Failure    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Multi_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Multi_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Stop traffic for UEs    non_ca_sa_ue_list=${Non_CA_SA_UE_List}    ca_sa_ue_list=${Multi_CA_SA_UE_List}    nsa_ue_list=${Multi_CA_NSA_UE_List}
    Verify scell deactivated for all UEs
    Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Detach SA UEs for Blind ScellAddition    ${Multi_CA_SA_UE_List}
    Detach NSA UEs for Blind ScellAddition    ${Multi_CA_NSA_UE_List}
    [Teardown]    run keywords    Revert Gnb Configuration for LOKI cell deployment sansa
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Multi_CA_SA_UE_List}    nsa_ue_list=${Multi_CA_NSA_UE_List}

CB007922_TC5_Cell Deployment_SANSA_Blind and BufferBased+RLQ CA and Non CA with beamforming and beam refinement SANSA For Single UE
    [Tags]    CB007922_TC5    CA_Types    P3_REG
    [Setup]    Test Setup    cell_deployment=SANSA    sCellAdditionMethod=${TC5_sCellAdditionMethod}
    ...   sCellActivationMethod=${TC5_sCellActivationMethod}
    ...    dl_tput_list=@{dl_tput_list_Blind_BufferBased_RLQ}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    csi_override=True
    Perform SA UE Register for Blind ScellAddition and Bufferbased ScellActivation with CSI Override    ${Single_CA_SA_UE_List}
    Start Traffic and Validate Scell Activation for SA UE    ue_id_list=${Single_CA_SA_UE_List}
    Perform NSA UE Attach for Blind ScellAddition and Bufferbased ScellActivation with CSI Override    ${Single_CA_NSA_UE_List}
    Start Traffic and Validate Scell Activation for NSA UE    ue_id_list=${Single_CA_NSA_UE_List}
    Sleep    90s
    Run keyword And Continue On Failure    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Update CSI Override parameters    profile_id=5  cqi=1   cqi_max=15    cqi_min=0    cqi_mode=fixed
    Associate UE to testmode    id=${Single_CA_SA_HO_UE}    testmode=csi_override     profile_id=5
    ...    pass_regex=SCellIndex 1 deactivated successfully    action=activate    scell=1
    Associate UE to testmode    id=${Single_CA_NSA_HO_UE}    testmode=csi_override     profile_id=5
    ...    pass_regex=SCellIndex 9 deactivated successfully    action=activate    scell=9
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Single_CA_SA_UE_List}
    Perform Stop Traffic and Detach NSA UEs for Blind ScellAddition    ${Single_CA_NSA_UE_List}
    [Teardown]    run keywords    Revert Gnb Configuration for LOKI cell deployment sansa
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}

CB007922_TC6_Cell Deployment_SANSA_Blind and BufferBased+RLQ CA and Non CA with beamforming and beam refinement SANSA For Multiple UEs
    [Tags]    AP_REG    CB007922_TC6    CA_Types
    [Setup]    Test Setup    cell_deployment=SANSA    sCellAdditionMethod=${TC6_sCellAdditionMethod}
    ...   sCellActivationMethod=${TC6_sCellActivationMethod}
    ...    dl_tput_list=@{multi_dl_tput_APoABIO}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform UE Register For SA Non CA Capable UEs     ${Non_CA_SA_UE_List}
    Perform SA UE Register for Blind ScellAddition and Bufferbased ScellActivation with CSI Override    ${Multi_CA_SA_UE_List}
    Perform NSA UE Attach for Blind ScellAddition and Bufferbased ScellActivation with CSI Override    ${Multi_CA_NSA_UE_List}
    Start traffic for all UEs
    Verify scell activated for all UEs
    Sleep    90s
    Run keyword And Continue On Failure    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Multi_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Multi_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Update CSI Override parameters    profile_id=5  cqi=1   cqi_max=15    cqi_min=0    cqi_mode=fixed
    Associate CSI Override profile to all UEs
    Sleep    10s    reason=Waiting for all Scells to be deactivated
    Verify scell deactivated for all UEs
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Multi_CA_SA_UE_List}
    Perform Stop Traffic and Detach NSA UEs for Blind ScellAddition    ${Multi_CA_NSA_UE_List}
    [Teardown]    run keywords    Revert Gnb Configuration for LOKI cell deployment sansa
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Multi_CA_SA_UE_List}    nsa_ue_list=${Multi_CA_NSA_UE_List}

CB007922_TC7_Cell Deployment_SANSA_Measurement and BlindBased CA and Non CA Activation with beamforming and beam refinement For Single UE
    [Tags]    AP_REG    CB007922_TC7    CA_Types
    [Setup]    Test Setup    cell_deployment=SANSA    sCellAdditionMethod=${TC7_sCellAdditionMethod}
    ...   sCellActivationMethod=${TC7_sCellActivationMethod}    sCellDeactivationTimerGNB=${TC7_sCellDeactivationTimerGNB}
    ...    dl_tput_list=@{dl_tput_list}     A1_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}
    ...    A2_carrier_freq=${A2_real_gnb_carrier_freq_APoABIO}
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform SA UE Register and start traffic for Measurement based ScellAddition and Blind ScellActivation
    ...    ${Single_CA_SA_UE_List}    ${A1_carrier_freq}
    Perform NSA UE Attach and start traffic for Measurement based ScellAddition and Blind ScellActivation
    ...    ${Single_CA_NSA_UE_List}    ${A1_carrier_freq}
    Sleep    90s
    Run keyword And Continue On Failure    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Stop traffic for UEs    non_ca_sa_ue_list=${Non_CA_SA_UE_List}    ca_sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}
    Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Detach SA UEs for Measurement Based ScellAddition    sa_ue_list=${Single_CA_SA_UE_List}
    ...    carrier_frequency=${A2_carrier_freq}
    Detach NSA UEs for Measurement Based ScellAddition    nsa_ue_list=${Single_CA_NSA_UE_List}
    ...    carrier_frequency=${A2_carrier_freq}
    [Teardown]    run keywords    Revert Gnb Configuration for LOKI cell deployment sansa
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}

CB007922_TC8_Cell Deployment_SANSA_Measurement and BufferBased CA and Non CA Activation with beamforming and beam refinement For Single UE
    [Tags]    CB007922_TC8    CA_Types    P3_REG
    [Setup]    Test Setup    cell_deployment=SANSA    sCellAdditionMethod=${TC8_sCellAdditionMethod}
    ...   sCellActivationMethod=${TC8_sCellActivationMethod}    dl_tput_list=@{dl_tput_list_Blind_BufferBased_RLQ}
    ...   A1_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}     A2_carrier_freq=${A2_real_gnb_carrier_freq_APoABIO}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    csi_override=True
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override    ${Single_CA_SA_UE_List}
    ...    ${A1_carrier_freq}
    Start Traffic and Validate Scell Activation for SA UE    ue_id_list=${Single_CA_SA_UE_List}
    Perform NSA UE Attach for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override    ${Single_CA_NSA_UE_List}
    ...    ${A1_carrier_freq}
    Start Traffic and Validate Scell Activation for NSA UE    ue_id_list=${Single_CA_NSA_UE_List}
    Sleep    90s
    Run keyword And Continue On Failure    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Bufferbased ScellActivation
    ...     sa_ue_list=${Single_CA_SA_UE_List}    carrier_frequency=${A2_carrier_freq}
    Perform Stop Traffic and Detach NSA UEs for MeasurementBased ScellAddition and Bufferbased ScellActivation
    ...     nsa_ue_list=${Single_CA_NSA_UE_List}    carrier_frequency=${A2_carrier_freq}
    [Teardown]    run keywords    Revert Gnb Configuration for LOKI cell deployment sansa
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}

CB007922_TC9_Cell Deployment_SANSA_Measurement and BufferBased CA and Non CA Activation with beamforming and beam refinement For Multiple UEs
    [Tags]    AP_REG    CB007922_TC9    CA_Types
    [Setup]    Test Setup    cell_deployment=SANSA    sCellAdditionMethod=${TC9_sCellAdditionMethod}
    ...   sCellActivationMethod=${TC9_sCellActivationMethod}    dl_tput_list=@{multi_dl_tput_APoABIO}
    ...   A1_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}     A2_carrier_freq=${A2_real_gnb_carrier_freq_APoABIO}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform UE Register For SA Non CA Capable UEs     ${Non_CA_SA_UE_List}
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...     ${Multi_CA_SA_UE_List}    ${A1_carrier_freq}
    Perform NSA UE Attach for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...     ${Multi_CA_NSA_UE_List}    ${A1_carrier_freq}
    Start traffic for all UEs
    Verify scell activated for all UEs
    Sleep    90s
    Run keyword And Continue On Failure    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Multi_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Multi_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Stop traffic for UEs    non_ca_sa_ue_list=${Non_CA_SA_UE_List}    ca_sa_ue_list=${Multi_CA_SA_UE_List}    nsa_ue_list=${Multi_CA_NSA_UE_List}
    Verify scell deactivated for all UEs
    Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Detach SA UEs for Measurement Based ScellAddition    sa_ue_list=${Multi_CA_SA_UE_List}    carrier_frequency=${A2_carrier_freq}
    Detach NSA UEs for Measurement Based ScellAddition    nsa_ue_list=${Multi_CA_NSA_UE_List}    carrier_frequency=${A2_carrier_freq}
    [Teardown]    run keywords    Revert Gnb Configuration for LOKI cell deployment sansa
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Multi_CA_SA_UE_List}    nsa_ue_list=${Multi_CA_NSA_UE_List}

CB007922_TC10_IntraFrequency_IntergNB_TDD-FR1_TDD_CA_HO_for_SA_NSA_UE
    [Documentation]    Verify IntraFrequency_IntergNB_TDD_-_FR1_TDD_CA_HO_for_SA_NSA_UE
    ...                gNB-2(TDD-1+ FR1TDD),gNB-2x(TDD-2)
    [Tags]    AP_REG    CB007922_TC10    CA_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB007922
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}    A2_carrier_freq=${A2_real_gnb_carrier_freq_APoABIO}
    ...    dl_tput_list=@{dl_tput_list_Blind_BufferBased_RLQ}
    FOR    ${index}    IN RANGE    2
        Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
        Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    csi_override=True
        Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override    ${Single_CA_SA_UE_List}
        ...    ${A1_carrier_freq}
        Start Traffic and Validate Scell Activation for SA UE    ue_id_list=${Single_CA_SA_UE_List}
        Perform NSA UE Attach for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override    ${Single_CA_NSA_UE_List}
        ...    ${A1_carrier_freq}
        Start Traffic and Validate Scell Activation for NSA UE    ue_id_list=${Single_CA_NSA_UE_List}
        Sleep    90s
        Run keyword And Continue On Failure    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}
        ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
        Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
        ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
        Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
        ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
        Trigger Intrafreq SA handover from Real gNB to Sim gNB    ue_id_list=${Single_CA_SA_UE_List}    carrier_frequency=${A1_carrier_freq}
        Run keyword And Continue On Failure    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}
        ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    mode=SA
        Trigger Intrafreq NSA handover from Real gNB to Sim gNB    ue_id_list=${Single_CA_NSA_UE_List}    carrier_frequency=${A1_carrier_freq}
        Run keyword And Continue On Failure    Validate throughput from bearer stats    ue_id=${Single_CA_NSA_HO_UE}
        ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    mode=NSA
        Update UE History Information     id=1    cell_type=large    nrcgi=311:489|0x04
        ...    gnb_id=22    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${Single_CA_SA_HO_UE}
        Trigger Intrafreq SA handover from Sim gNB to Real gNB    ue_id=${Single_CA_SA_HO_UE}    scell_index=1
        ...    carrier_frequency=${A1_carrier_freq}    csi_override_needed=True
        Update UE History Information     id=2    cell_type=large    nrcgi=311:489|0x06
        ...    gnb_id=24    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${Single_CA_NSA_HO_UE}
        Trigger Intrafreq NSA handover from Sim gNB to Real gNB    ue_id=${Single_CA_NSA_HO_UE}    scell_index=9
        ...    carrier_frequency=${A1_carrier_freq}    csi_override_needed=True
        Run keyword And Continue On Failure
        ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
        ...    expected_dl_tput=${dl_tput_list}     UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
        Run keyword And Continue On Failure
        ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
        ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
        Update CSI Override parameters    profile_id=5  cqi=1   cqi_max=15    cqi_min=0    cqi_mode=fixed
        Associate UE to testmode    id=${Single_CA_SA_HO_UE}    testmode=csi_override     profile_id=5
        ...    action=activate    scell=1    pass_regex=SCellIndex \\d+ deactivated successfully
        Associate UE to testmode    id=${Single_CA_NSA_HO_UE}    testmode=csi_override     profile_id=5
        ...    action=activate    scell=9    pass_regex=SCellIndex \\d+ deactivated successfully
        Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
        Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
        ...    ${Single_CA_SA_UE_List}    ${A2_carrier_freq}
        Stop Traffic and Detach NSA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
        ...    ${Single_CA_NSA_UE_List}    ${A2_carrier_freq}
    END
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}

CB007922_TC11_InterFrequency_IntergNB_TDD-FR1_TDD_CA_HO_for_SA_NSA_UE
    [Documentation]    Verify InterFrequency_IntergNB_TDD-FR1_TDD_CA_HO_for_SA_NSA_UE
    ...                gNB-2(TDD-1+ FR1TDD),gNB-2x(TDD-2)
    [Tags]    AP_REG    CB007922_TC11    CA_HO    AP_P1
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB007922    A1_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}
    ...    dl_tput_list=@{dl_tput_list_APoABIO}    A2_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}
    ...    A3_carrier_freq=${A3_real_gnb_carrier_freq_APoABIO}    A2_carrier_sim_freq=${A3_real_gnb_carrier_freq_APoABIO}
    ...    A3_carrier_sim_freq=${A1_real_gnb_carrier_freq_APoABIO}    A2_detach_freq=${A2_real_gnb_carrier_freq_APoABIO}
    ...    COPY_PASS_LOGS=True
    FOR    ${cell_lock_unlock}    IN RANGE    ${no_of_time_lock_unlock}
        Run Keyword And Ignore Error    Start TTI Trace Log    collector_name=l2stream3_${cell_lock_unlock}
        Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
        Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    csi_override=True
        Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
        ...    ${Single_CA_SA_UE_List}    ${A1_carrier_freq}
        Start Traffic and Validate Scell Activation for SA UE    ue_id_list=${Single_CA_SA_UE_List}
        Perform NSA UE Attach for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
        ...    ${Single_CA_NSA_UE_List}    ${A1_carrier_freq}    InterHO=True
        Start Traffic and Validate Scell Activation for NSA UE    ue_id_list=${Single_CA_NSA_UE_List}
        Sleep    30s
        Run Keyword And Ignore Error    Stop TTI Trace Collection    collector_name=l2stream3_${cell_lock_unlock}
        ...    target_dir=${testlog_path}
        Sleep    60s
        Run keyword And Continue On Failure    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}
        ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
        Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
        ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
        Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
        ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
        Trigger Interfreq SA handover from Real gNB to Sim gNB    ue_id=${Single_CA_SA_HO_UE}    A2_carrier_freq=${A2_carrier_freq}
        ...    A3_carrier_freq=${A3_carrier_freq}
        Run keyword And Continue On Failure    Validate throughput from bearer stats
        ...    ue_id=${Single_CA_SA_HO_UE}    expected_dl_tput=${dl_tput_list}
        ...    expected_ul_tput=${ul_tput}    mode=SA
        Trigger Interfreq NSA handover from Real gNB to Sim gNB    ue_id=${Single_CA_NSA_HO_UE}    A2_carrier_freq=${A2_carrier_freq}
        ...    A3_carrier_freq=${A3_carrier_freq}
        Run keyword And Continue On Failure    Validate throughput from bearer stats
        ...    ue_id=${Single_CA_NSA_HO_UE}    expected_dl_tput=${dl_tput_list}
        ...    expected_ul_tput=${ul_tput}    mode=NSA
        Trigger Interfreq SA handover from Sim gNB to Real gNB    ue_id=${Single_CA_SA_HO_UE}    A2_carrier_sim_freq=${A2_carrier_sim_freq}
        ...    A3_carrier_sim_freq=${A3_carrier_sim_freq}    A1_carrier_freq=${A1_carrier_freq}    scell_index=1    csi_override_needed=True
        Trigger Interfreq NSA handover from Sim gNB to Real gNB    ue_id=${Single_CA_NSA_HO_UE}    A2_carrier_sim_freq=${A2_carrier_sim_freq}
        ...    A3_carrier_sim_freq=${A3_carrier_sim_freq}    A1_carrier_freq=${A1_carrier_freq}    scell_index=9    csi_override_needed=True
        Run keyword And Continue On Failure
        ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
        ...    expected_dl_tput=${dl_tput_list}     UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
        Run keyword And Continue On Failure
        ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
        ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
        Update CSI Override parameters    profile_id=5  cqi=1   cqi_max=15    cqi_min=0    cqi_mode=fixed
        Associate UE to testmode    id=${Single_CA_SA_HO_UE}    testmode=csi_override     profile_id=5
        ...    action=activate    scell=1    pass_regex=SCellIndex \\d+ deactivated successfully
        Associate UE to testmode    id=${Single_CA_NSA_HO_UE}    testmode=csi_override     profile_id=5
        ...    action=activate    scell=9    pass_regex=SCellIndex \\d+ deactivated successfully
        Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
        Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
        ...    sa_ue_list=${Single_CA_SA_UE_List}    carrier_frequency=${A2_detach_freq}
        Stop Traffic and Detach NSA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
        ...    nsa_ue_list=${Single_CA_NSA_UE_List}    carrier_frequency=${A2_detach_freq}    trigger_meas_gap_off=True
        Perform NR Cell Lock and Unlock
        Sleep    90s
    END
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}

CB007922_TC12_IntraFrequency_IntergNB_TDD-FR1_TDD_CA_Ng_based_HO_For_SANSA UEs
    [Documentation]    Verify IntraFrequency_IntergNB_TDD-FR1_TDD_CA_HO_for_SA_NSA_UE
    ...                gNB-2(TDD-1+ FR1TDD),gNB-2x(TDD-2)
    [Tags]    AP_REG    CB007922_TC12    CA_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB007922    NGBased_HO=True
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}    A2_carrier_freq=${A2_real_gnb_carrier_freq_APoABIO}
    ...    dl_tput_list=@{dl_tput_list_Blind_BufferBased_RLQ}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    csi_override=True
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Single_CA_SA_UE_List}    carrier_frequency=${A1_carrier_freq}
    Start Traffic and Validate Scell Activation for SA UE    ue_id_list=${Single_CA_SA_UE_List}
    Perform NSA UE Attach for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Single_CA_NSA_UE_List}    carrier_frequency=${A1_carrier_freq}
    Start Traffic and Validate Scell Activation for NSA UE    ue_id_list=${Single_CA_NSA_UE_List}
    Sleep    90s
    Run keyword And Continue On Failure    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Trigger Intrafreq NG Based SA handover from Real gNB to Sim gNB    ue_id=${Single_CA_SA_HO_UE}    carrier_frequency=${A1_carrier_freq}
    Run keyword And Continue On Failure    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=3
    Trigger Intrafreq NG Based NSA handover from Real gNB to Sim gNB    ue_id=${Single_CA_NSA_HO_UE}    carrier_frequency=${A1_carrier_freq}
    Run keyword And Continue On Failure    Validate throughput from bearer stats    ue_id=${Single_CA_NSA_HO_UE}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    mode=NSA
    Trigger Intrafreq NG Based SA handover from Sim gNB to Real gNB    ue_id=${Single_CA_SA_HO_UE}    scell_index=1
    ...    carrier_frequency=${A1_carrier_freq}
    Trigger Intrafreq NG Based NSA handover from Sim gNB to Real gNB    ue_id=${Single_CA_NSA_HO_UE}    scell_index=9
    ...    carrier_frequency=${A1_carrier_freq}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}     UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Update CSI Override parameters    profile_id=5  cqi=1   cqi_max=15    cqi_min=0    cqi_mode=fixed
    Associate UE to testmode    id=${Single_CA_SA_HO_UE}    testmode=csi_override     profile_id=5
    ...    action=activate    scell=1    pass_regex=SCellIndex \\d+ deactivated successfully
    Associate UE to testmode    id=${Single_CA_NSA_HO_UE}    testmode=csi_override     profile_id=5
    ...    action=activate    scell=9    pass_regex=SCellIndex \\d+ deactivated successfully
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    sa_ue_list=${Single_CA_SA_UE_List}    carrier_frequency=${A2_carrier_freq}
    Stop Traffic and Detach NSA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}    carrier_frequency=${A2_carrier_freq}
    Log To Console    Sleeping for 5min before collecting PM Counters..
    Sleep    300s
    Run Keyword And Ignore Error    Collect Gnb PM Counters    target_dir=${testlog_path}    name=gnb_pm_counters
    Run Keyword And Ignore Error    Validate Gnb PM Counters    sa_ue_list=${Single_CA_SA_UE_List}    counters=${Counter_List}
    ...    counters_dir=${testlog_path}    name=gnb_pm_counters    nsa_ue_list=${Single_CA_NSA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=5GC001729
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}

CB007922_TC13_InterFrequency_IntergNB_TDD-FR1_TDD_CA_Ngbased_HO_For_SANSA UEs
    [Tags]    AP_REG    CB007922_TC13    CA_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB007922    NGBased_HO=True
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}    A2_carrier_freq=${A2_real_gnb_carrier_freq_APoABIO}
    ...    A3_carrier_freq=${A3_real_gnb_carrier_freq_APoABIO}    A2_carrier_sim_freq=${A3_real_gnb_carrier_freq_APoABIO}
    ...    A3_carrier_sim_freq=${A1_real_gnb_carrier_freq_APoABIO}     dl_tput_list=@{dl_tput_list_APoABIO}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    csi_override=True
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Single_CA_SA_UE_List}    carrier_frequency=${A1_carrier_freq}
    Start Traffic and Validate Scell Activation for SA UE    ue_id_list=${Single_CA_SA_UE_List}
    Perform NSA UE Attach for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Single_CA_NSA_UE_List}    carrier_frequency=${A1_carrier_freq}    InterHO=True
    Start Traffic and Validate Scell Activation for NSA UE    ue_id_list=${Single_CA_NSA_UE_List}
    Sleep    90s
    Run keyword And Continue On Failure    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Trigger Interfreq NG Based SA handover from Real gNB to Sim gNB    ue_id=${Single_CA_SA_HO_UE}    A2_carrier_freq=${A1_carrier_freq}
    ...    A3_carrier_freq=${A3_carrier_freq}
    Run keyword And Continue On Failure    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    mode=SA
    Trigger Interfreq NG NSA handover from Real gNB to Sim gNB    ue_id=${Single_CA_NSA_HO_UE}    A2_carrier_freq=${A1_carrier_freq}
    ...    A3_carrier_freq=${A3_carrier_freq}
    Run keyword And Continue On Failure    Validate throughput from bearer stats    ue_id=${Single_CA_NSA_HO_UE}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    mode=NSA
    Trigger Interfreq NG Based SA handover from Sim gNB to Real gNB    ue_id=${Single_CA_SA_HO_UE}    scell_index=1
    ...    A2_carrier_sim_freq=${A2_carrier_sim_freq}    A3_carrier_sim_freq=${A3_carrier_sim_freq}    A1_carrier_freq=${A1_carrier_freq}
    Trigger Interfreq NSA handover from Sim gNB to Real gNB    ue_id=${Single_CA_NSA_HO_UE}    A2_carrier_sim_freq=${A2_carrier_sim_freq}
    ...    A3_carrier_sim_freq=${A3_carrier_sim_freq}    A1_carrier_freq=${A1_carrier_freq}    scell_index=9    csi_override_needed=True
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}     UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Update CSI Override parameters    profile_id=5    cqi=1    cqi_max=15    cqi_min=0    cqi_mode=fixed
    Associate UE to testmode    id=${Single_CA_SA_HO_UE}    testmode=csi_override     profile_id=5
    ...    action=activate    scell=1    pass_regex=SCellIndex \\d+ deactivated successfully
    Associate UE to testmode    id=${Single_CA_NSA_HO_UE}    testmode=csi_override     profile_id=5
    ...    action=activate    scell=9    pass_regex=SCellIndex \\d+ deactivated successfully
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    sa_ue_list=${Single_CA_SA_UE_List}    carrier_frequency=${A2_carrier_freq}
    Stop Traffic and Detach NSA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}    carrier_frequency=${A2_carrier_freq}
    Log To Console    Sleeping for 5min before collecting PM Counters..
    Sleep    300s
    Run Keyword And Ignore Error    Collect Gnb PM Counters    target_dir=${testlog_path}    name=gnb_pm_counters
    Run Keyword And Ignore Error    Validate Gnb PM Counters    sa_ue_list=${Single_CA_SA_UE_List}    counters=${Counter_List}
    ...    counters_dir=${testlog_path}    name=gnb_pm_counters    nsa_ue_list=${Single_CA_NSA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=5GC001729
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}
    ...    nsa_ue_list=${Single_CA_NSA_UE_List}

CB007922_TC14_Inter-RAT_Handover_From_5GC_To_LTE_To_5GC_For_CA_SA_Single_UE
    [Tags]    AP_REG    CB007922_TC14    CA_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB007922    interrat_ho=True
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}    A2_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}
    ...    dl_tput_list=@{dl_tput_list_tc14}    A2_detach_freq=${A2_real_gnb_carrier_freq_APoABIO}
    ...    COPY_PASS_LOGS=True
    Run Keyword And Ignore Error    Start TTI Trace Log
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    csi_override=True
    ...    uplink_tput=${ul_tput_interrat}
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Single_CA_SA_UE_List}    ${A1_carrier_freq}
    Start Traffic and Validate Scell Activation for SA UE    ue_id_list=${Single_CA_SA_UE_List}    uplink_tput=${ul_tput_interrat}
    Sleep    90s
    Run Keyword And Ignore Error    Stop TTI Trace Collection    target_dir=${testlog_path}
    Run keyword And Continue On Failure    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput_interrat}
    ...    expected_dl_tput=${ul_tput_interrat}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput_interrat}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Trigger InterRAT SA handover from Real gNB to Sim eNB    ue_id=${Single_CA_SA_HO_UE}    A2_carrier_freq=${A2_carrier_freq}
    Run keyword And Continue On Failure    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput_interrat}    mode=SA
    Trigger InterRAT SA handover from Sim eNB to Real gNB    ue_id=${Single_CA_SA_HO_UE}    A1_carrier_freq=${A1_carrier_freq}
    Run keyword And Continue On Failure    Validate throughput from UE stats and bearer stats for SA UEs
    ...    expected_ul_tput=${ul_tput_interrat}    expected_dl_tput=${dl_tput_list}
    ...     UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Update CSI Override parameters    profile_id=2  cqi=1   cqi_max=15    cqi_min=0    cqi_mode=fixed
    Associate UE to testmode    id=${Single_CA_SA_HO_UE}
    ...    testmode=csi_override     profile_id=2    action=activate    scell=1    pass_regex=SCellIndex \\d+ deactivated successfully
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    sa_ue_list=${Single_CA_SA_UE_List}    carrier_frequency=${A2_detach_freq}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=CB007922    interrat=True
    ...    AND   Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}

CB007922_TC15_Cell Deployment_SA_Measurement CA and Non CA for Single UE
    [Tags]    CB007922_TC15    CA_SA
    [Setup]    Test Setup    cell_deployment=SA    sCellAdditionMethod=${TC15_16_sCellAdditionMethod}
    ...    sCellActivationMethod=${TC15_16_sCellActivationMethod}    dl_tput_list=@{dl_tput_list_APoABIO}
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}     A2_carrier_freq=${A2_real_gnb_carrier_freq_APoABIO}
    ...    cellDepType=${TC15_to_TC18_cellDepType}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Single_CA_SA_UE_List}    ${A1_carrier_freq}
    Start Traffic and Validate Scell Activation for SA UE    ue_id_list=${Single_CA_SA_UE_List}
    Sleep    90s
    Run keyword And Continue On Failure    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list_APoABIO}    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Update CSI Override parameters    profile_id=5    cqi=1    cqi_max=15    cqi_min=0    cqi_mode=fixed
    Activate testmode    ue_list=${Single_CA_SA_UE_List}    scell_id=@{SA_Scell_Index}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    ${Single_CA_SA_UE_List}    ${A2_carrier_freq}
    [Teardown]    run keywords    Revert Gnb Configuration for LOKI cell deployment
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}

CB007922_TC16_Cell Deployment_SA_Measurement CA and Non CA for Multi UEs
    [Tags]    AP_REG    CB007922_TC16    CA_SA
    [Setup]    Test Setup    cell_deployment=SA    sCellAdditionMethod=${TC15_16_sCellAdditionMethod}
    ...    sCellActivationMethod=${TC15_16_sCellActivationMethod}    dl_tput_list=@{dl_tput_list}
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}     A2_carrier_freq=${A2_real_gnb_carrier_freq_APoABIO}
    ...    cellDepType=${TC15_to_TC18_cellDepType}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform UE Register For SA Non CA Capable UEs     ${Non_CA_SA_UE_List}
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Multi_CA_SA_UE_List}    ${A1_carrier_freq}
    Start traffic for SA UEs
    Verify scell activated for SA UEs    scell_index_list=${scell_index_list}
    Sleep    90s
    Run keyword And Continue On Failure    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Multi_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Update CSI Override parameters    profile_id=5  cqi=1   cqi_max=15    cqi_min=0    cqi_mode=fixed
    Activate testmode    ue_list=${Multi_CA_SA_UE_List}    scell_id=@{SA_Scell_Index}
    sleep    60s
    Verify scell deactivated for SA UEs    sa_ue_list=${Multi_CA_SA_UE_List}    scell_list=${scell_index_list}
    Perform Stop Traffic and Detach SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Bufferbased ScellActivation
    ...     sa_ue_list=${Multi_CA_SA_UE_List}    carrier_frequency=${A2_carrier_freq}
    [Teardown]    run keywords    Revert Gnb Configuration for LOKI cell deployment
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Multi_CA_SA_UE_List}

CB007922_TC17_Cell Deployment_SA_Blind and Buffer Based CA and Non CA for Multi UEs
    [Tags]    AP_REG    CB007922_TC17    CA_SA
    [Setup]    Test Setup    cell_deployment=SA    sCellAdditionMethod=${TC17_sCellAdditionMethod}
    ...    sCellActivationMethod=${TC17_sCellActivationMethod}    dl_tput_list=@{dl_tput_list}
    ...    cellDepType=${TC15_to_TC18_cellDepType}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform UE Register For SA Non CA Capable UEs     ${Non_CA_SA_UE_List}
    Perform SA UE Register for Blind ScellAddition and Bufferbased ScellActivation with CSI Override    ${Multi_CA_SA_UE_List}
    Start traffic for SA UEs
    Verify scell activated for SA UEs    scell_index_list=${scell_index_list}
    Sleep    90s
    Run keyword And Continue On Failure    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Multi_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Stop traffic for SA UEs    sa_ue_list=${Non_CA_SA_UE_List}
    Stop traffic for SA UEs    sa_ue_list=${Multi_CA_SA_UE_List}
    Verify scell deactivated for SA UEs    sa_ue_list=${Multi_CA_SA_UE_List}    scell_list=${scell_index_list}
    Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Detach SA UEs for Blind ScellAddition    ${Multi_CA_SA_UE_List}
    [Teardown]    run keywords    Revert Gnb Configuration for LOKI cell deployment
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Multi_CA_SA_UE_List}

CB007922_TC18_Cell Deployment_SA_Blind and Blind Based CA and Non CA for Single UE
    [Tags]    AP_REG    CB007922_TC18    CA_SA
    [Setup]    Test Setup    cell_deployment=SA    sCellAdditionMethod=${TC18_sCellAdditionMethod}
    ...   sCellActivationMethod=${TC18_sCellActivationMethod}    dl_tput_list=@{dl_tput_list_tc18}
    ...    sCellDeactivationTimerGNB=${TC18_sCellDeactivationTimerGNB}    cellDepType=${TC15_to_TC18_cellDepType}
    Perform UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}
    Perform SA UE Register and start traffic for Blind ScellAddition and Blind ScellActivation    ${Single_CA_SA_UE_List}
    Sleep    90s
    Run keyword And Continue On Failure    Validate Pcell Throughput For Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${SA_Scell_Index}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Single_CA_SA_UE_List}
    [Teardown]    run keywords    Revert Gnb Configuration for LOKI cell deployment
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}

CB007922_TC19_Cell Deployment_NSA_Measurement and BufferBased CA Activation with beamforming and beam refinement For Single UE
    [Tags]    CB007922_TC19    CA_NSA
    [Setup]    Test Setup for cell deployment NSA    sCellAdditionMethod=${TC7_sCellAdditionMethod}
    ...   sCellActivationMethod=${TC5_sCellActivationMethod}    dl_tput_list=@{dl_tput_list_APoABIO}
    ...   A1_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}     A2_carrier_freq=${A2_real_gnb_carrier_freq_APoABIO}
    ...    cellDepType=${TC19_cellDepType}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform NSA UE Attach and Start Traffic For NSA Non CA Capable UE    ${Non_CA_NSA_UE_List}
    Perform NSA UE Attach for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Single_CA_NSA_UE_List}    ${A1_carrier_freq}
    Start Traffic and Validate Scell Activation for NSA UE    ue_id_list=${Single_CA_NSA_UE_List}
    Sleep    90s
    Run keyword And Continue On Failure    Validate Pcell Throughput For NSA Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_NSA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Perform Stop Traffic and Detach NSA Non CA Capable UE    ${Non_CA_NSA_UE_List}
    Activate testmode    ue_list=${Single_CA_NSA_UE_List}    scell_id=@{NSA_Scell_Index}
    Stop Traffic and Detach NSA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    ${Single_CA_NSA_UE_List}    ${A2_carrier_freq}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Log To Console    Sleeping for 5min before collecting PM Counters..
    Sleep    300s
    Run Keyword And Ignore Error    Collect Gnb PM Counters    target_dir=${testlog_path}    name=gnb_pm_counters
    Run Keyword And Ignore Error    Validate Gnb PM Counters    sa_ue_list=${EMPTY}    counters=${Counter_List}
    ...    counters_dir=${testlog_path}    name=gnb_pm_counters    nsa_ue_list=${Single_CA_NSA_UE_List}
    [Teardown]    run keywords    Revert Gnb Configuration for LOKI cell deployment
    ...    AND    Test Teardown    nsa_ue_list=${Single_CA_NSA_UE_List}

CB007922_TC20_Cell Deployment_NSA_Measurement and BufferBased CA and Activation with beamforming and beam refinement For Multiple UEs
    [Tags]    AP_REG    CB007922_TC20    CA_NSA
    [Setup]    Test Setup for cell deployment NSA    sCellAdditionMethod=${TC7_sCellAdditionMethod}
    ...   sCellActivationMethod=${TC5_sCellActivationMethod}    dl_tput_list=@{multi_dl_tput_NSA_dep}
    ...   A1_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}     A2_carrier_freq=${A2_real_gnb_carrier_freq_APoABIO}
    ...    cellDepType=${TC19_cellDepType}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform NSA UE Attach and Start Traffic For NSA Non CA Capable UE    ${Non_CA_NSA_UE_List}
    Perform NSA UE Attach for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Multi_CA_NSA_UE_List}    ${A1_carrier_freq}
    Start traffic for all NSA UEs
    Verify scell activated for all NSA UEs
    Sleep    90s
    Run keyword And Continue On Failure    Validate Pcell Throughput For NSA Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_NSA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Multi_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Perform Stop Traffic and Detach NSA Non CA Capable UE    ${Non_CA_NSA_UE_List}
    Activate testmode    ue_list=${Multi_CA_NSA_UE_List}    scell_id=@{NSA_Scell_Index}
    Stop Traffic and Detach NSA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    ${Multi_CA_NSA_UE_List}    ${A2_carrier_freq}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Log To Console    Sleeping for 5min before collecting PM Counters..
    Sleep    300s
    Run Keyword And Ignore Error    Collect Gnb PM Counters    target_dir=${testlog_path}    name=gnb_pm_counters
    Run Keyword And Ignore Error    Validate Gnb PM Counters    sa_ue_list=${EMPTY}    counters=${Counter_List}
    ...    counters_dir=${testlog_path}    name=gnb_pm_counters    nsa_ue_list=${Multi_CA_NSA_UE_List}
    [Teardown]    run keywords    Revert Gnb Configuration for LOKI cell deployment
    ...    AND    Test Teardown    nsa_ue_list=${Multi_CA_NSA_UE_List}

CB007922_TC21_Cell Deployment_NSA_Blind and BufferBased CA Activation with beamforming and beam refinement For Multiple UEs
    [Tags]    CB007922_TC21    CA_NSA    P3_REG
    [Setup]    Test Setup for cell deployment NSA    sCellAdditionMethod=${TC4_sCellAdditionMethod}
    ...   sCellActivationMethod=${TC4_sCellActivationMethod}    dl_tput_list=@{multi_dl_tput_NSA_dep}
    ...   A1_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}     A2_carrier_freq=${A2_real_gnb_carrier_freq_APoABIO}
    ...    cellDepType=${TC19_cellDepType}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform NSA UE Attach and Start Traffic For NSA Non CA Capable UE    ${Non_CA_NSA_UE_List}
    Perform NSA UE Attach for Blind ScellAddition and Bufferbased ScellActivation with CSI Override    ${Multi_CA_NSA_UE_List}
    Start traffic for all NSA UEs
    Verify scell activated for all NSA UEs
    Sleep    90s
    Run keyword And Continue On Failure    Validate Pcell Throughput For NSA Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_NSA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Multi_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Stop traffic for NSA UEs    nsa_ue_list=${Multi_CA_NSA_UE_List}
    Verify scell deactivated for all NSA UEs
    Perform Stop Traffic and Detach NSA Non CA Capable UE    ${Non_CA_NSA_UE_List}
    Detach NSA UEs for Blind ScellAddition    ${Multi_CA_NSA_UE_List}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Log To Console    Sleeping for 5min before collecting PM Counters..
    Sleep    300s
    Run Keyword And Ignore Error    Collect Gnb PM Counters    target_dir=${testlog_path}    name=gnb_pm_counters
    Run Keyword And Ignore Error    Validate Gnb PM Counters    sa_ue_list=${EMPTY}    counters=${Counter_List}
    ...    counters_dir=${testlog_path}    name=gnb_pm_counters    nsa_ue_list=${Multi_CA_NSA_UE_List}
    [Teardown]    run keywords    Revert Gnb Configuration for LOKI cell deployment
    ...    AND    Test Teardown    nsa_ue_list=${Multi_CA_NSA_UE_List}

CB007922_TC22_Cell Deployment_NSA_Blind and BlindBased CA Activation with beamforming and beam refinement For Single UE
    [Tags]    AP_REG    CB007922_TC22    CA_NSA
    [Setup]    Test Setup for cell deployment NSA    sCellAdditionMethod=${TC3_sCellAdditionMethod}
    ...   sCellActivationMethod=${TC3_sCellActivationMethod}    dl_tput_list=@{dl_tput_NSA_dep}
    ...   sCellDeactivationTimerGNB=${TC3_sCellDeactivationTimerGNB}    cellDepType=${TC19_cellDepType}
    Perform NSA UE Attach and Start Traffic For NSA Non CA Capable UE    ${Non_CA_NSA_UE_List}
    Perform NSA UE Attach and start traffic for Blind ScellAddition and Blind ScellActivation    ${Single_CA_NSA_UE_List}
    Sleep    90s
    Run keyword And Continue On Failure    Validate Pcell Throughput For NSA Non CA Capable UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_NSA_UE_List}
    Run keyword And Continue On Failure    Validate Pcell and Scell Throughput For NSA UEs    expected_ul_tput=${ul_tput}
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_NSA_UE_List}    Scell_Id=${NSA_Scell_Index}
    Perform Stop Traffic and Detach NSA Non CA Capable UE    ${Non_CA_NSA_UE_List}
    Perform Stop Traffic and Detach NSA UEs for Blind ScellAddition    ${Single_CA_NSA_UE_List}
    [Teardown]    run keywords    Revert Gnb Configuration for LOKI cell deployment
    ...    AND    Test Teardown    nsa_ue_list=${Single_CA_NSA_UE_List}

CB007922_23_Verification_of_Intra-gNB_HO_not_performed_to_cell_affected_by_o_and_M_intervention_and_HO_performed_with_different_RSRP_RSRQ
    [Documentation]    The purpose of this test case is to verify handover is not triggered and handover trigger with different RSRP/RSRQ values
    [Tags]    AP_REG    CB007922_23    RI_HO
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB007922    A1_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}
    ...    dl_tput_list=@{dl_tput_list_APoABIO}    A2_carrier_freq=${A1_real_gnb_carrier_freq_APoABIO}
    ...    A3_carrier_freq=${A3_real_gnb_carrier_freq_APoABIO}    A2_carrier_sim_freq=${A3_real_gnb_carrier_freq_APoABIO}
    ...    A3_carrier_sim_freq=${A1_real_gnb_carrier_freq_APoABIO}    A2_detach_freq=${A2_real_gnb_carrier_freq_APoABIO}
    ...    COPY_PASS_LOGS=True
	Modify Handover Preparation procedure parameters at GNB    gnb_id=23
	Ensure UE Register Is Successful    ue_id=${Single_CA_SA_HO_UE}
	Ensure Set PDU Param Is Successful    ue_id=${Single_CA_SA_HO_UE}    pdu_id=3    trf_type=internal
	Ensure UE PDU Session Setup Is Successful    ue_id=${Single_CA_SA_HO_UE}    pdu_id=3    gw_id=1    nwslice=1
	Trigger Interfreq SA handover from Real gNB to Sim gNB to validate HandoverPreparationFailure    ue_id=${Single_CA_SA_HO_UE}
    ...    A2_carrier_freq=${A2_carrier_freq}    A3_carrier_freq=${A3_carrier_freq}
	Generate Remote Interference    RI_PWR=${RI_PWR}
	Reset Handover Preparation procedure parameters at GNB    gnb_id=23
	FOR    ${nrsrp}    ${nrsrq}    IN
    ...    45    45
    ...    50    50
    ...    55    55
	...    60    60
	...    65    65
	...    70    70
	...    80    80
	...    90    90
	...    100   100
	    Check Interfreq SA handover after resetting Handover Preparation procedure parameters    ue_id=${Single_CA_SA_HO_UE}
		...    A2_carrier_freq=${A2_carrier_freq}    A3_carrier_freq=${A3_carrier_freq}
		...    A2_carrier_sim_freq=${A2_carrier_sim_freq}    A3_carrier_sim_freq=${A3_carrier_sim_freq}
		...    nrsrp_nr=${nrsrp}    nrsrq_nr=${nrsrq}
	END
	Ensure UE PDU Session Release Is Successful    ue_id=${Single_CA_SA_HO_UE}    pdu_id=3
	Ensure UE Deregister Is Successful    ue_id=${Single_CA_SA_HO_UE}    ue_deregister_type=switch_off    by=ue
	[Teardown]    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}
