*** Settings ***
Documentation     author: Abhijit
...               contact: abhijit.abhijit@nokia.com
...               Description: Extended Inter band DL TDD FR1_FDD CA up to 4CCs_TDD as PCell

Resource    ../4CC_Common_Keywords.robot

Suite Setup       Suite Setup    feature_folder=CB008532


*** Variables ***
${WTS_CFG_PATH}                                 ${CURDIR}/../Config_Files/9_CB008532_LOO_AP_LOO/wts
${NUMBER_OF_CELLS}                              4
@{dl_tput_list}                                 175    175    175    175
@{multi_dl_tput}                                175
${ul_tput}                                      3
@{Single_CA_SA_UE_List}                         3
@{Multi_CA_SA_UE_List}                          3    4    5    6    7
@{dl_tput_HO_list}                              175    175    175    175
${A1_real_gnb_carrier_freq_cell3}               509790
&{A2_carrier_freq_scells}                       scell1=431090    scell2=527790    scell3=126990
@{4CC_SA_Scell_Index}                           0    1    2    3
&{TC3_sCellAdditionMethod}                      sCellAdditionMethod=blind
&{TC3_sCellDeactivationTimerGNB}                sCellDeactivationTimerGNB=infinity
&{TC3_sCellActivationMethod}                    sCellActivationMethod=blind
&{TC2_sCellActivationMethod}                    sCellActivationMethod=bufferBased
&{TC4_sCellAdditionMethod}                      sCellAdditionMethod=covBasedA1
&{TC4_sCellActivationMethod}                    sCellActivationMethod=bufferBased
&{Blind_sCellAdditionMethod}                    sCellAdditionMethod=blind
&{Blind_BufferRLQ_sCellActivationMethod}        sCellActivationMethod=bufferAndRLQualityBased
${WTS_FILE}                                     basic_setup.cfg
${Single_CA_SA_HO_UE}                           3
${A3_sim_gnb_carrier_freq_cell1_InterFreq}      527790
@{nrrel_profile_id}                             6    7
@{simulator_gnb_list}                           2    22    23
@{simulator_gnb_list_interRAT}                  2
${B2_sim_gnb_carrier_freq}                      1400
${interrat_gnb_delta_json}                      ${CURDIR}/cfg/InterRAT_8532_delta.json

*** Test Cases ***
CB008532_Loki_TC1_Extended Inter band DL 2FDD 2TDD FR1 Blind and Blind based CA Activation SUE up to 4CCs_TDD as PCell
    [Tags]    AP_REG    CB008532_Loki_TC1    P1_REG
    [Setup]    Test Setup    4CC=True    sCellAdditionMethod=${TC3_sCellAdditionMethod}
    ...    sCellActivationMethod=${TC3_sCellActivationMethod}    sCellDeactivationTimerGNB=${TC3_sCellDeactivationTimerGNB}
    ...    dl_tput_list=@{dl_tput_list}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform SA UE Register and start traffic for Blind ScellAddition and Blind ScellActivation    ${Single_CA_SA_UE_List}    4CC=True
    Sleep    30s
    Validate Pcell and Scell Throughput For SA UEs    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Stop Traffic and Detach SA UEs    ${Single_CA_SA_UE_List}    pdu=3
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    [Teardown]    run keywords    Revert Gnb Configuration for 4CC
    ...    AND    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}    4CC=True

CB008532_Loki_TC5_Extended_Inter_band_DL_2FDD_2TDD_FR1_Measurement_and_Buffer_RLQ_based_CA_Activation_MUE_up_to_4CCs_TDD_as_PCell
    [Tags]    AP_REG    CB008532_Loki_TC5    P1_REG
    [Setup]    Test Setup    4CC=True    dl_tput_list=@{multi_dl_tput}     A1_carrier_freq=${A1_real_gnb_carrier_freq_cell3}
    ...    A2_carrier_freq_scells=&{A2_carrier_freq_scells}    Gnb_Commissioning=False
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Multi_CA_SA_UE_List}    ${A1_carrier_freq}    scell=${4CC_scell_index_1}    4CC=True
    Start traffic for all SA UEs    CA_SA_UE_List=${Multi_CA_SA_UE_List}    CA_DL_tput_list=${dl_tput_list}    CA_UL_tput=${ul_tput}
    Sleep    30s
    Run Keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs
    ...    expected_dl_tput=${multi_dl_tput}    UE_List=${Multi_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Activate testmode and verify scell deactivation    ue_list=${Multi_CA_SA_UE_List}
    Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    ${Multi_CA_SA_UE_List}    ${A2_carrier_freq_scells}    4CC=True
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    [Teardown]    Test Teardown    sa_ue_list=${Multi_CA_SA_UE_List}    4CC=True

CB008532_Loki_TC6_Intra_frequency Inter_gNB 2FDD_2TDD FR1 CA up to 4CCs Xn_based HO for SA UE_TDD_as_PCell
    [Documentation]    Verify Intra-frequency Inter-gNB 2FDD + 2TDD FR1 CA up to 4CCs Xn-based HO for SA UE (TDD as PCell)
    [Tags]    AP_REG    CB008532_Loki_TC6    P2_REG
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008532
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_cell3}    dl_tput_list=@{dl_tput_HO_list}    simulator_gnb_list=${simulator_gnb_list}
    ...    A3_carrier_sim_freq=${A1_real_gnb_carrier_freq_cell3}    A2_carrier_freq_scells=${A2_carrier_freq_scells}    phycell_id=54
    ...    4CC=True
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Single_CA_SA_UE_List}    ${A1_carrier_freq}    4CC=True    scell=${4CC_scell_index_1}
    Start traffic for all SA UEs    CA_SA_UE_List=${Single_CA_SA_UE_List}    CA_DL_tput_list=${dl_tput_list}
    ...    CA_UL_tput=${ul_tput}
    Sleep    30s
    Run Keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    sleep    180s   reason=To stabilise xn link
    Trigger Intrafreq XN Based SA Forward handover    ue_id=${Single_CA_SA_HO_UE}    carrier_frequency=${A3_carrier_sim_freq}
    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=3
    Update UE History Information     id=1    cell_type=large    nrcgi=311:489|0x06
    ...    gnb_id=22    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${Single_CA_SA_HO_UE}
    Trigger Intrafreq SA handover from Sim gNB to Real gNB for 4CC    ue_id=${Single_CA_SA_HO_UE}    csi_override_needed=True
    ...    scell_index=${4CC_scell_index}    phycell_id=${phycell_id}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Activate testmode and verify scell deactivation    ue_list=${Single_CA_SA_UE_List}
    Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    ${Single_CA_SA_UE_List}    ${A2_carrier_freq_scells}    4CC=True
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    [Teardown]    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}    4CC=True

CB008532_Loki_TC7_Inter_frequency_Inter_gNB_2FDD_2TDD_FR1 CA up to 4CCs Xn_based HO for SA UE_TDD_as_PCell
    [Documentation]    Verify Inter-frequency Inter-gNB 2FDD + 2TDD FR1 CA up to 4CCs Xn-based HO for SA UE (TDD as PCell)
    [Tags]    AP_REG    CB008532_Loki_TC7    P2_REG
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008532
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_cell3}    A2_carrier_freq=${A3_sim_gnb_carrier_freq_cell1_InterFreq}
    ...    dl_tput_list=@{dl_tput_HO_list}    A3_carrier_sim_freq=${A3_sim_gnb_carrier_freq_cell1_InterFreq}
    ...    A2_carrier_freq_scells=${A2_carrier_freq_scells}    simulator_gnb_list=${simulator_gnb_list}    phycell_id=54
    ...    4CC=True
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...     ${Single_CA_SA_UE_List}    ${A1_carrier_freq}    4CC=True    scell=${4CC_scell_index_1}
    Start traffic for all SA UEs    CA_SA_UE_List=${Single_CA_SA_UE_List}    CA_DL_tput_list=${dl_tput_list}
    ...    CA_UL_tput=${ul_tput}
    Sleep    30s
    Run Keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    sleep    180s   reason=To stabilise xn link
    Trigger Interfreq XN Based SA Forward handover    ue_id=${Single_CA_SA_HO_UE}    A2_carrier_freq=${A1_carrier_freq}
    ...    A3_carrier_freq=${A3_carrier_sim_freq}
    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=3
    Update UE History Information     id=1    cell_type=large    nrcgi=311:489|0x07
    ...    gnb_id=23    time_ue_stayed_in_cell=98    action=commit    ue_enb_param_id=${Single_CA_SA_HO_UE}
    Trigger Interfreq SA handover from Sim gNB to Real gNB for 4CC    ue_id=${Single_CA_SA_HO_UE}    csi_override_needed=True
    ...    scell_index=${4CC_scell_index}    phycell_id=${phycell_id}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Activate testmode and verify scell deactivation    ue_list=${Single_CA_SA_UE_List}
    Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    ${Single_CA_SA_UE_List}    ${A2_carrier_freq_scells}    4CC=True
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    [Teardown]    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}    4CC=True

CB008532_Loki_TC8_Intra_frequency_Inter_gNB_2FDD_2TDD_FR1 CA up to 4CCs Ng_based HO for SA UE_TDD_as_PCell
    [Documentation]    Verify Intra_frequency_Inter_gNB_2FDD_2TDD_FR1 CA up to 4CCs Ng_based HO for SA UE_TDD_as_PCell
    [Tags]    AP_REG    CB008532_Loki_TC8    P2_REG
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008532    NGBased_HO=True    simulator_gnb_list=${simulator_gnb_list}
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_cell3}    A2_carrier_freq=${A3_sim_gnb_carrier_freq_cell1_InterFreq}
    ...    dl_tput_list=@{dl_tput_HO_list}    A2_carrier_freq_scells=${A2_carrier_freq_scells}    phycell_id=54
    ...    4CC=True
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...     ${Single_CA_SA_UE_List}    ${A1_carrier_freq}    4CC=True    scell=${4CC_scell_index_1}
    Start traffic for all SA UEs    CA_SA_UE_List=${Single_CA_SA_UE_List}    CA_DL_tput_list=${dl_tput_list}
    ...    CA_UL_tput=${ul_tput}
    Sleep    30s
    Run Keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Trigger Intrafreq NG Based SA Forward handover    ue_id=${Single_CA_SA_HO_UE}    carrier_frequency=${A1_carrier_freq}
    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=3
    Trigger Intrafreq NG Based SA handover from Sim gNB to Real gNB for 4CC    ue_id=${Single_CA_SA_HO_UE}    scell_index=${4CC_scell_index}
    ...    phycell_id=${phycell_id}    carrier_frequency=${A1_carrier_freq}
    Validate Pcell and Scell Throughput For SA UEs    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Activate testmode and verify scell deactivation    ue_list=${Single_CA_SA_UE_List}
    Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    ${Single_CA_SA_UE_List}    ${A2_carrier_freq_scells}    4CC=True
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=CB008532
    ...    AND    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}    4CC=True

CB008532_Loki_TC9_Inter_frequency_Inter_gNB_2FDD_2TDD_FR1 CA up to 4CCs Ng_based HO for SA UE_TDD_as_PCell
    [Documentation]    Verify Inter_frequency_Inter_gNB_2FDD_2TDD_FR1 CA up to 4CCs Ng_based HO for SA UE_TDD_as_PCell
    [Tags]    AP_REG    CB008532_Loki_TC9    P2_REG
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008532    NGBased_HO=True    simulator_gnb_list=${simulator_gnb_list}
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_cell3}    A2_carrier_freq=${A3_sim_gnb_carrier_freq_cell1_InterFreq}
    ...    dl_tput_list=@{dl_tput_HO_list}    A3_carrier_sim_freq=${A3_sim_gnb_carrier_freq_cell1_InterFreq}    phycell_id=54
    ...    4CC=True    A2_carrier_freq_scells=${A2_carrier_freq_scells}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...     ${Single_CA_SA_UE_List}    ${A1_carrier_freq}    4CC=True    scell=${4CC_scell_index_1}
    Start traffic for all SA UEs    CA_SA_UE_List=${Single_CA_SA_UE_List}    CA_DL_tput_list=${dl_tput_list}
    ...    CA_UL_tput=${ul_tput}
    Sleep    30s
    Run Keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Trigger Interfreq NG Based SA Forward handover    ue_id=${Single_CA_SA_HO_UE}    A2_carrier_freq=${A1_carrier_freq}
    ...    A3_carrier_freq=${A3_carrier_sim_freq}
    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=3
    Trigger Interfreq NG Based SA handover from Sim gNB to Real gNB for 4CC    ue_id=${Single_CA_SA_HO_UE}    scell_index=${4CC_scell_index}
    ...    A2_carrier_sim_freq=${A2_carrier_freq}    A3_carrier_sim_freq=${A1_carrier_freq}
    ...    phycell_id=${phycell_id}    A1_carrier_freq=${A1_carrier_freq}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Activate testmode and verify scell deactivation    ue_list=${Single_CA_SA_UE_List}
    Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    ${Single_CA_SA_UE_List}    ${A2_carrier_freq_scells}    4CC=True
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=CB008532
    ...    AND    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}    4CC=True

CB008532_Loki_TC10_Extended Inter band DL 2FDD_2TDD FR1 Inter RAT Handover with CA Activation up to 4CCs_TDD_as_PCell
    [Documentation]    Verify Extended Inter band DL 2FDD + 2TDD FR1 Inter RAT Handover with CA Activation up to 4CCs (TDD as PCell)
    [Tags]    AP_REG    CB008532_Loki_TC10    P2_REG
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008532    interrat_ho=True
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_cell3}    A2_carrier_freq=${A1_real_gnb_carrier_freq_cell3}
    ...    dl_tput_list=@{dl_tput_HO_list}    B2_carrier_freq=${B2_sim_gnb_carrier_freq}    4CC=True
    ...    A2_carrier_freq_scells=${A2_carrier_freq_scells}    simulator_gnb_list=${simulator_gnb_list_interRAT}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...     ${Single_CA_SA_UE_List}    ${A1_carrier_freq}    4CC=True    scell=${4CC_scell_index_1}
    Start traffic for all SA UEs    CA_SA_UE_List=${Single_CA_SA_UE_List}    CA_DL_tput_list=${dl_tput_list}
    ...    CA_UL_tput=${ul_tput}
    Sleep    30s
    Run Keyword And Continue On Failure    Validate Pcell and Scell Throughput For SA UEs    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Trigger InterRAT SA Forward Handover    ue_id=${Single_CA_SA_HO_UE}    A2_carrier_freq=${A2_carrier_freq}    phycell_id=52
    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=3
    Trigger InterRAT SA handover from Sim eNB to Real gNB    ue_id=${Single_CA_SA_HO_UE}    scell_index=${4CC_scell_index}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Activate testmode and verify scell deactivation    ue_list=${Single_CA_SA_UE_List}
    Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    ${Single_CA_SA_UE_List}    ${A2_carrier_freq_scells}    4CC=True
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=CB008532    interrat=True
    ...    AND    Test Teardown    sa_ue_list=${Single_CA_SA_UE_List}    4CC=True