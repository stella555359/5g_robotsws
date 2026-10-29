*** Settings ***
Documentation     author: Merin Varghese
...               contact: merin.varghese@nokia.com
...               Description:

Resource    ../4CC_Common_Keywords.robot

Suite Setup       Suite Setup    feature_folder=CB006137

*** Variables ***
${WTS_CFG_PATH}                        ${CURDIR}/cfg
${NUMBER_OF_CELLS}                     4
${primary_cell}                        3
@{dl_tput_list}                        150    150    150    150
@{multi_dl_tput}                       150    75
${NonCA_UL_tput}                       3
${CA_UL_tput}                          80
${multi_CA_UL_tput}                    35
@{Non_CA_SA_UE_List}                   1
@{Single_CA_SA_UE_List}                3
@{Multi_CA_SA_UE_List}                 3    4    5    6
@{dl_tput_HO_list}                     175    175    175    175
${Single_CA_SA_HO_UE}                  3
${A1_real_gnb_carrier_freq_cell3}      431090
&{A2_carrier_freq_scells}              scell1=126990    scell2=663264    scell3=528750
${A3_sim_gnb_carrier_freq_cell1_InterFreq}    425070
@{nrrel_profile_id}                      6    7
@{4CC_SA_Scell_Index}                    0    1    2    3
&{TC1_sCellAdditionMethod}             sCellAdditionMethod=blind
&{TC1_sCellDeactivationTimerGNB}       sCellDeactivationTimerGNB=infinity
&{TC1_sCellActivationMethod}           sCellActivationMethod=blind
&{TC2_sCellActivationMethod}           sCellActivationMethod=bufferBased
@{simulator_gnb_list}                  2    22    23
@{logical_cell_list}                   1    2    3     11     12
@{NRREL_list}                          1    2    3    4
@{UL_Scell_index}                      0    2
@{UL_Scell_index_2}                    0    3
&{covBasedA1_sCellAddMethod}           sCellAdditionMethod=covBasedA1
&{bufferBased_sCellActvMethod}         sCellActivationMethod=bufferBased


*** Test Cases ***
CB006137_TC1_Inter band FDD_TDD FR1 DL_4CC+UL_2CC Blind and Blind based mixed CA Activation SUE_FDD_as_PCell
    [Tags]    CB006137_TC1
    [Setup]    Test Setup for 4CC_DL_2CC_UL    4CC_DL_2CC_UL=True    sCellAdditionMethod=${TC1_sCellAdditionMethod}
    ...    sCellActivationMethod=${TC1_sCellActivationMethod}    sCellDeactivationTimerGNB=${TC1_sCellDeactivationTimerGNB}
    ...    dl_tput_list=@{dl_tput_list}    logical_cell_list=@{logical_cell_list}    nrrel_list=@{NRREL_list}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${NonCA_UL_tput}     pdu=3
    Perform SA UE Register and start traffic for Blind ScellAddition and Blind ScellActivation    ${Single_CA_SA_UE_List}
    ...     uplink_tput=${CA_UL_tput}    4CC=True
    Sleep    90s
    Validate Pcell Throughput from UE stats and bearer stats for Non CA Capable UEs    expected_ul_tput=${NonCA_UL_tput}
    ...    expected_dl_tput=${NonCA_UL_tput}    UE_List=${Non_CA_SA_UE_List}
    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs    expected_dl_tput=${dl_tput_list}
    ...    expected_ul_tput=${CA_UL_tput}    UE_List=${Single_CA_SA_UE_List}    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${4CC_SA_Scell_Index}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Stop Traffic and Detach SA UEs    ${Single_CA_SA_UE_List}    pdu=3
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    SA_UE_List=${Single_CA_SA_UE_List}
    [Teardown]    run keywords    Revert Gnb Configuration for 4CC_DL_2CC_UL
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}    4CC=True

CB006137_TC2_Inter band FDD_TDD FR1 DL_4CC+UL_2CC Blind and Buffer based mixed CA Activation MUE_FDD_as_PCell
    [Tags]    CB006137_TC2
    [Setup]    Test Setup for 4CC_DL_2CC_UL    4CC_DL_2CC_UL=True    sCellAdditionMethod=${TC1_sCellAdditionMethod}
    ...    sCellActivationMethod=${TC2_sCellActivationMethod}    dl_tput_list=@{multi_dl_tput}
    ...    logical_cell_list=@{logical_cell_list}    nrrel_list=@{NRREL_list}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${NonCA_UL_tput}     pdu=3
    Perform SA UE Register for Blind ScellAddition and Bufferbased ScellActivation with CSI Override    ${Multi_CA_SA_UE_List}    4CC=True
    Start Uplink and Downlink traffic for 4CC_DL+2CC_UL    CA_SA_UE_List=${Multi_CA_SA_UE_List}    CA_DL_tput_list=${dl_tput_list}
    ...    CA_UL_tput=${multi_CA_UL_tput}
    Sleep    90s
    Run Keyword And Continue On Failure    Validate Pcell Throughput from UE stats and bearer stats for Non CA Capable UEs
    ...    expected_ul_tput=${NonCA_UL_tput}    expected_dl_tput=${NonCA_UL_tput}    UE_List=${Non_CA_SA_UE_List}
    Run Keyword And Continue On Failure    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${multi_CA_UL_tput}    UE_List=${Multi_CA_SA_UE_List}
    ...    UL_Scell_Id=${UL_Scell_index}    UL_Scell_Id_2=${UL_Scell_index_2}    DL_Scell_Id=${4CC_SA_Scell_Index}
    Stop traffic for UEs    non_ca_sa_ue_list=${Non_CA_SA_UE_List}    ca_sa_ue_list=${Multi_CA_SA_UE_List}
    Verify scell deactivated for SA UEs    sa_ue_list=${Multi_CA_SA_UE_List}
    Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}    pdu=3
    Detach SA UEs for Blind ScellAddition    ${Multi_CA_SA_UE_List}    pdu=3
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    SA_UE_List=${Multi_CA_SA_UE_List}
    [Teardown]    run keywords    Revert Gnb Configuration for 4CC_DL_2CC_UL
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Multi_CA_SA_UE_List}    4CC=True

CB006137_TC4_Interband_FDD_TDD_FR1_DL_4CC_UL_2CC_Measurement_and_Buffer_based_mixed_CA_Activation_MUE_FDD_as_PCell
    [Tags]    CB006137_TC4
    [Setup]    Test Setup for 4CC_DL_2CC_UL    4CC_DL_2CC_UL=True    sCellAdditionMethod=${covBasedA1_sCellAddMethod}
    ...    sCellActivationMethod=${bufferBased_sCellActvMethod}    dl_tput_list=@{multi_dl_tput}
    ...    logical_cell_list=@{logical_cell_list}    nrrel_list=@{NRREL_list}
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_cell3}    A2_carrier_freq_scells=&{A2_carrier_freq_scells}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${NonCA_UL_tput}     pdu=3
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Multi_CA_SA_UE_List}    ${A1_carrier_freq}    scell=${4CC_scell_index_1}    4CC=True    srsrp_nr=127
    Start Uplink and Downlink traffic for 4CC_DL+2CC_UL    CA_SA_UE_List=${Multi_CA_SA_UE_List}    CA_DL_tput_list=${dl_tput_list}
    ...    CA_UL_tput=${multi_CA_UL_tput}
    Sleep    90s
    Run Keyword And Continue On Failure    Validate Pcell Throughput from UE stats and bearer stats for Non CA Capable UEs
    ...    expected_ul_tput=${NonCA_UL_tput}    expected_dl_tput=${NonCA_UL_tput}    UE_List=${Non_CA_SA_UE_List}
    Run Keyword And Continue On Failure    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${multi_CA_UL_tput}    UE_List=${Multi_CA_SA_UE_List}
    ...    UL_Scell_Id=${UL_Scell_index}    UL_Scell_Id_2=${UL_Scell_index_2}    DL_Scell_Id=${4CC_SA_Scell_Index}
    Stop traffic for UEs    non_ca_sa_ue_list=${Non_CA_SA_UE_List}    ca_sa_ue_list=${Multi_CA_SA_UE_List}
    Verify scell deactivated for SA UEs    sa_ue_list=${Multi_CA_SA_UE_List}
    Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}    pdu=3
    Detach SA UEs for Measurement Based ScellAddition
    ...    ${Multi_CA_SA_UE_List}    ${A2_carrier_freq_scells}    4CC=True
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    SA_UE_List=${Multi_CA_SA_UE_List}
    [Teardown]    run keywords    Revert Gnb Configuration for 4CC_DL_2CC_UL
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Multi_CA_SA_UE_List}    4CC=True

CB006137_TC6_Intra-frequency Inter-gNB FDD_TDD FR1 DL_4CC_UL_2CC mixed CA Xn-based HO for SA UE_FDD_as_PCell
    [Documentation]    Verify Intra-frequency Inter-gNB FDD_TDD FR1 DL 4CC + UL 2CC mixed CA Xn-based HO for SA UE (FDD as PCell)
    [Tags]    CB006137_TC6
    [Setup]    Test Setup for 4CC_DL_2CC_UL handover scenario    Handover_Feature=CB006137
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_cell3}    dl_tput_list=@{dl_tput_list}    simulator_gnb_list=${simulator_gnb_list}
    ...    A3_carrier_sim_freq=${A1_real_gnb_carrier_freq_cell3}    A2_carrier_freq_scells=${A2_carrier_freq_scells}    4CC=True
    ...    logical_cell_list=@{logical_cell_list}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${NonCA_UL_tput}     pdu=3
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Single_CA_SA_UE_List}    ${A1_carrier_freq}    4CC=True    scell=${4CC_scell_index_1}    srsrp_nr=127
    Start Uplink and Downlink traffic for 4CC_DL+2CC_UL    CA_SA_UE_List=${Single_CA_SA_UE_List}    CA_DL_tput_list=${dl_tput_list}
    ...    CA_UL_tput=${CA_UL_tput}
    Sleep    90s
    Validate Pcell Throughput from UE stats and bearer stats for Non CA Capable UEs    expected_ul_tput=${NonCA_UL_tput}
    ...    expected_dl_tput=${NonCA_UL_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${CA_UL_tput}    UE_List=${Single_CA_SA_UE_List}
    ...    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${4CC_SA_Scell_Index}
    Trigger Intrafreq XN Based SA Forward handover    ue_id=${Single_CA_SA_HO_UE}    carrier_frequency=${A3_carrier_sim_freq}
    ...    primary_cell=${primary_cell}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${CA_UL_tput}    mode=SA    pdu_id=3
    Update UE History Information     id=1    cell_type=large    nrcgi=311:489|0x06
    ...    gnb_id=22    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${Single_CA_SA_HO_UE}
    Trigger Intrafreq SA handover from Sim gNB to Real gNB for 4CC    ue_id=${Single_CA_SA_HO_UE}    csi_override_needed=True
    ...    scell_index=${4CC_scell_index}    primary_cell=${primary_cell}    srsrp_nr=127
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${CA_UL_tput}    UE_List=${Single_CA_SA_UE_List}
    ...    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${4CC_SA_Scell_Index}
    Stop traffic for UEs    non_ca_sa_ue_list=${Non_CA_SA_UE_List}    ca_sa_ue_list=${Single_CA_SA_UE_List}
    Verify scell deactivated for SA UEs    sa_ue_list=${Single_CA_SA_UE_List}
    Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Detach SA UEs for Measurement Based ScellAddition    ${Single_CA_SA_UE_List}    ${A2_carrier_freq_scells}    4CC=True
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    SA_UE_List=${Single_CA_SA_UE_List}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}    4CC=True

CB006137_TC7_Inter-frequency Inter-gNB FDD_TDD FR1 DL 4CC_UL 2CC mixed CA Xn-based HO for SA UE_FDD as PCell
    [Documentation]    Verify Inter-frequency Inter-gNB FDD_TDD FR1 DL 4CC + UL 2CC mixed CA Xn-based HO for SA UE (FDD as PCell)
    [Tags]    CB006137_TC7
    [Setup]    Test Setup for 4CC_DL_2CC_UL handover scenario    Handover_Feature=CB006137    simulator_gnb_list=${simulator_gnb_list}
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_cell3}    A2_carrier_freq=${A3_sim_gnb_carrier_freq_cell1_InterFreq}
    ...    A3_carrier_sim_freq=${A3_sim_gnb_carrier_freq_cell1_InterFreq}    4CC=True
    ...    A2_carrier_freq_scells=${A2_carrier_freq_scells}    logical_cell_list=@{logical_cell_list}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${NonCA_UL_tput}     pdu=3
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...     ${Single_CA_SA_UE_List}    ${A1_carrier_freq}    4CC=True    scell=${4CC_SA_Scell_Index}    srsrp_nr=127
    Start Uplink and Downlink traffic for 4CC_DL+2CC_UL    CA_SA_UE_List=${Single_CA_SA_UE_List}    CA_DL_tput_list=${dl_tput_list}
    ...    CA_UL_tput=${CA_UL_tput}
    Sleep    90s
    Validate Pcell Throughput from UE stats and bearer stats for Non CA Capable UEs    expected_ul_tput=${NonCA_UL_tput}
    ...    expected_dl_tput=${NonCA_UL_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${CA_UL_tput}    UE_List=${Single_CA_SA_UE_List}
    ...    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${4CC_SA_Scell_Index}
    Trigger Interfreq XN Based SA Forward handover    ue_id=${Single_CA_SA_HO_UE}    A2_carrier_freq=${A1_carrier_freq}
    ...    A3_carrier_freq=${A3_carrier_sim_freq}    primary_cell=${primary_cell}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${CA_UL_tput}    mode=SA    pdu_id=3
    Update UE History Information     id=1    cell_type=large    nrcgi=311:489|0x07
    ...    gnb_id=23    time_ue_stayed_in_cell=98    action=commit    ue_enb_param_id=${Single_CA_SA_HO_UE}
    Trigger Interfreq SA handover from Sim gNB to Real gNB for 4CC    ue_id=${Single_CA_SA_HO_UE}    scell_index=${4CC_scell_index}
    ...    A2_carrier_sim_freq=${A3_carrier_sim_freq}    A3_carrier_sim_freq=${A1_carrier_freq}    csi_override_needed=True
    ...    primary_cell=${primary_cell}    srsrp_nr=127
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${CA_UL_tput}    UE_List=${Single_CA_SA_UE_List}
    ...    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${4CC_SA_Scell_Index}
    Stop traffic for UEs    non_ca_sa_ue_list=${Non_CA_SA_UE_List}    ca_sa_ue_list=${Single_CA_SA_UE_List}
    Verify scell deactivated for SA UEs    sa_ue_list=${Single_CA_SA_UE_List}
    Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Detach SA UEs for Measurement Based ScellAddition    ${Single_CA_SA_UE_List}    ${A2_carrier_freq_scells}    4CC=True
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    SA_UE_List=${Single_CA_SA_UE_List}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}    4CC=True

CB006137_TC8_Intra-frequency Inter-gNB FDD_TDD FR1 DL 4CC_UL 2CC mixed CA Ng-based HO for SA UE FDD as PCell
    [Documentation]    Verify Intra_frequency_Inter_gNB_FDD_TDD FR1 DL 4CC_UL 2CC mixed CA Ng-based HO for SA UE FDD as PCell
    [Tags]    CB006137_TC8
    [Setup]    Test Setup for 4CC_DL_2CC_UL handover scenario    Handover_Feature=CB006137    simulator_gnb_list=${simulator_gnb_list}
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_cell3}    A2_carrier_freq=${A3_sim_gnb_carrier_freq_cell1_InterFreq}    NGBased_HO=True
    ...    A3_carrier_sim_freq=${A1_real_gnb_carrier_freq_cell3}    4CC=True
    ...    A2_carrier_freq_scells=${A2_carrier_freq_scells}    logical_cell_list=@{logical_cell_list}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs     ${Non_CA_SA_UE_List}    ${NonCA_UL_tput}
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...     ${Single_CA_SA_UE_List}    ${A1_carrier_freq}    4CC=True    scell=${4CC_scell_index_1}    srsrp_nr=127
    Run keyword And Continue On Failure    Start Uplink and Downlink traffic for 4CC_DL+2CC_UL    CA_SA_UE_List=${Single_CA_SA_UE_List}
    ...    CA_DL_tput_list=${dl_tput_list}    CA_UL_tput=${CA_UL_tput}
    Validate Pcell Throughput from UE stats and bearer stats for Non CA Capable UEs    expected_ul_tput=${NonCA_UL_tput}
    ...    expected_dl_tput=${NonCA_UL_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure    wait until keyword succeeds    3min    30s
    ...    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${CA_UL_tput}    UE_List=${Single_CA_SA_UE_List}
    ...    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${4CC_SA_Scell_Index}
    Trigger Intrafreq NG Based SA Forward handover    ue_id=${Single_CA_SA_HO_UE}    carrier_frequency=${A1_carrier_freq}
    ...    primary_cell=${primary_cell}
    wait until keyword succeeds    3min    30s    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${CA_UL_tput}    mode=SA    pdu_id=3
    Trigger Intrafreq NG Based SA handover from Sim gNB to Real gNB for 4CC    ue_id=${Single_CA_SA_HO_UE}    scell_index=${4CC_scell_index}
    ...    carrier_frequency=${A1_carrier_freq}    primary_cell=${primary_cell}    srsrp_nr=127
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${CA_UL_tput}    UE_List=${Single_CA_SA_UE_List}
    ...    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${4CC_SA_Scell_Index}
    Stop traffic for UEs    non_ca_sa_ue_list=${Non_CA_SA_UE_List}    ca_sa_ue_list=${Single_CA_SA_UE_List}
    Verify scell deactivated for SA UEs    sa_ue_list=${Single_CA_SA_UE_List}
    Detach SA UEs for Measurement Based ScellAddition    ${Single_CA_SA_UE_List}    ${A2_carrier_freq_scells}    4CC=True
    Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    SA_UE_List=${Single_CA_SA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=CB008532
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}    4CC=True

CB006137_TC9_Inter_frequency_Inter_gNB_2FDD_2TDD_FR1 CA up to 4CCs_DL_2CC_UL_Ng_based HO for SA UE_FDD_as_PCell
    [Documentation]    Verify Inter_frequency_Inter_gNB_2FDD_2TDD_FR1 CA up to 4CCs_DL_2CC_UL_Ng_based HO for SA UE_FDD_as_PCell
    [Tags]    CB006137_TC9
    [Setup]    Test Setup for 4CC_DL_2CC_UL handover scenario    Handover_Feature=CB006137    simulator_gnb_list=${simulator_gnb_list}
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_cell3}    A2_carrier_freq=${A3_sim_gnb_carrier_freq_cell1_InterFreq}    NGBased_HO=True
    ...    A3_carrier_sim_freq=${A3_sim_gnb_carrier_freq_cell1_InterFreq}    4CC=True
    ...    A2_carrier_freq_scells=${A2_carrier_freq_scells}    logical_cell_list=@{logical_cell_list}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${NonCA_UL_tput}
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...     ${Single_CA_SA_UE_List}    ${A1_carrier_freq}    4CC=True    scell=${4CC_scell_index_1}    srsrp_nr=127
    Start Uplink and Downlink traffic for 4CC_DL+2CC_UL    CA_SA_UE_List=${Single_CA_SA_UE_List}    CA_DL_tput_list=${dl_tput_list}
    ...    CA_UL_tput=${CA_UL_tput}
    Run keyword And Continue On Failure
    ...    Validate Pcell Throughput from UE stats and bearer stats for Non CA Capable UEs    expected_ul_tput=${NonCA_UL_tput}
    ...    expected_dl_tput=${NonCA_UL_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${CA_UL_tput}    UE_List=${Single_CA_SA_UE_List}
    ...    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${4CC_SA_Scell_Index}
    Trigger Interfreq NG Based SA Forward handover    ue_id=${Single_CA_SA_HO_UE}    A2_carrier_freq=${A1_carrier_freq}
    ...    A3_carrier_freq=${A3_carrier_sim_freq}    primary_cell=${primary_cell}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${CA_UL_tput}    mode=SA    pdu_id=3
    Trigger Interfreq NG Based SA handover from Sim gNB to Real gNB for 4CC    ue_id=${Single_CA_SA_HO_UE}    scell_index=${4CC_scell_index}
    ...    A2_carrier_sim_freq=${A2_carrier_freq}    A3_carrier_sim_freq=${A1_carrier_freq}    primary_cell=${primary_cell}
    ...    A1_carrier_freq=${A1_carrier_freq}    srsrp_nr=127
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${CA_UL_tput}    UE_List=${Single_CA_SA_UE_List}
    ...    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${4CC_SA_Scell_Index}
    Stop traffic for UEs    ca_sa_ue_list=${Single_CA_SA_UE_List}    non_ca_sa_ue_list=${Non_CA_SA_UE_List}
    Verify scell deactivated for SA UEs    sa_ue_list=${Single_CA_SA_UE_List}
    Detach SA UEs for Measurement Based ScellAddition    ${Single_CA_SA_UE_List}    ${A2_carrier_freq_scells}    4CC=True
    Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    SA_UE_List=${Single_CA_SA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=CB006137
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}    4CC=True

CB006137_TC10_Extended Inter band FDD_TDD FR1 DL 4CC_UL 2CC mixed CA Inter RAT Handover for SA UE FDD as PCell
    [Documentation]    Verify Inter band FDD_TDD FR1 DL 4CC_UL 2CC mixed CA Inter RAT Handover for SA UE FDD as PCell
    [Tags]    CB006137_TC10
    [Setup]    Test Setup for 4CC_DL_2CC_UL handover scenario    Handover_Feature=CB006137
    ...    simulator_gnb_list=${simulator_gnb_list}    A1_carrier_freq=${A1_real_gnb_carrier_freq_cell3}
    ...    A2_carrier_freq=${A1_real_gnb_carrier_freq_cell3}    dl_tput_list=@{dl_tput_list}
    ...    A3_carrier_sim_freq=${A3_sim_gnb_carrier_freq_cell1_InterFreq}    4CC=True    A2_carrier_freq_scells=${A2_carrier_freq_scells}
    ...    logical_cell_list=@{logical_cell_list}    wts_changes=True
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${NonCA_UL_tput}    pdu=3
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Single_CA_SA_UE_List}    ${A1_carrier_freq}    4CC=True    scell=${4CC_scell_index_1}    srsrp_nr=127
    Run keyword And Continue On Failure    Start Uplink and Downlink traffic for 4CC_DL+2CC_UL    CA_SA_UE_List=${Single_CA_SA_UE_List}
    ...    CA_DL_tput_list=${dl_tput_list}    CA_UL_tput=${CA_UL_tput}
    Validate Pcell Throughput from UE stats and bearer stats for Non CA Capable UEs    expected_ul_tput=${NonCA_UL_tput}
    ...    expected_dl_tput=${NonCA_UL_tput}    UE_List=${Non_CA_SA_UE_List}
    Run keyword And Continue On Failure    wait until keyword succeeds    3min    30s
    ...    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${CA_UL_tput}    UE_List=${Single_CA_SA_UE_List}
    ...    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${4CC_SA_Scell_Index}
    Trigger InterRAT SA Forward Handover    ue_id=${Single_CA_SA_HO_UE}    A2_carrier_freq=${A2_carrier_freq}    phycell_id=52
    ...    primary_cell=${primary_cell}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${CA_UL_tput}    mode=SA    pdu_id=3
    Trigger InterRAT SA handover from Sim eNB to Real gNB    ue_id=${Single_CA_SA_HO_UE}    scell_index=${4CC_scell_index}
    ...    primary_cell=${primary_cell}    srsrp_nr=127
    Run keyword And Continue On Failure    wait until keyword succeeds    3min    30s
    ...    Validate uplink and downlink cell throughput from UE stats and bearer stats for SA UEs
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${CA_UL_tput}    UE_List=${Single_CA_SA_UE_List}
    ...    UL_Scell_Id=${UL_Scell_index}    DL_Scell_Id=${4CC_SA_Scell_Index}
    Stop traffic for UEs    ca_sa_ue_list=${Single_CA_SA_UE_List}    non_ca_sa_ue_list=${Non_CA_SA_UE_List}
    Verify scell deactivated for SA UEs    sa_ue_list=${Single_CA_SA_UE_List}
    Detach SA UEs for Measurement Based ScellAddition    ${Single_CA_SA_UE_List}    ${A2_carrier_freq_scells}    4CC=True
    Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    SA_UE_List=${Single_CA_SA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=CB008532    interrat=True
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}    4CC=True
