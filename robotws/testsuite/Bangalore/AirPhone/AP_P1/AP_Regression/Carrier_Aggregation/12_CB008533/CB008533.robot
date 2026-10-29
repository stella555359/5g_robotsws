*** Settings ***
Documentation     author: Bhanu Vamsi
...               contact: vamsi.gundlur@nokia.com
...               Description:

Resource    ../4CC_Common_Keywords.robot

Suite Setup       Suite Setup    feature_folder=CB008533

*** Variables ***
${WTS_CFG_PATH}                        ${CURDIR}/cfg
${interrat_gnb_delta_json}             ${WTS_CFG_PATH}/InterRAT_8533_delta.json
${NUMBER_OF_CELLS}                     4
@{dl_tput_list}                        175    175    175    175
@{multi_dl_tput}                       150    100
${ul_tput}                             3
@{Non_CA_SA_UE_List}                   1
@{Single_CA_SA_UE_List}                3
@{Multi_CA_SA_UE_List}                 3    4    5    6
@{dl_tput_HO_list}                     175    175    175    175
${Single_CA_SA_HO_UE}                  3
${ul_tput_interrat}                    1
${ul_tput_anr}                         10
${A1_real_gnb_carrier_freq_cell3}      431090
&{A2_carrier_freq_scells}              scell1=507150    scell2=528990    scell3=126990
${A2_carrier_freq_sim_gnb}             126990
${A3_carrier_freq_sim_gnb_InterFreq}    126380
@{nrrel_profile_id}                      6    7
@{4CC_SA_Scell_Index}                    0    1    2    3
&{TC3_sCellAdditionMethod}             sCellAdditionMethod=blind
&{TC3_sCellDeactivationTimerGNB}       sCellDeactivationTimerGNB=infinity
&{TC3_sCellActivationMethod}           sCellActivationMethod=blind
&{TC2_sCellActivationMethod}           sCellActivationMethod=bufferBased
&{TC4_sCellAdditionMethod}          sCellAdditionMethod=covBasedA1
&{TC4_sCellActivationMethod}        sCellActivationMethod=bufferBased
&{Blind_sCellAdditionMethod}             sCellAdditionMethod=blind
&{Blind_BufferRLQ_sCellActivationMethod}        sCellActivationMethod=bufferAndRLQualityBased
@{simulator_gnb_list}                  2    22    23
@{simulator_gnb_list_interRAT}                  2
${B2_sim_gnb_carrier_freq}                    1400
${primary_cell}                       1
${phycell_id}                         51


*** Test Cases ***
CB008533_TC1_Extended Inter band DL 2FDD 2TDD FR1 Blind and Blind based CA Activation SUE up to 4CCs_FDD as PCell
    [Tags]    AP_REG    CB008533_TC1
    [Setup]    Test Setup    4CC=True    sCellAdditionMethod=${TC3_sCellAdditionMethod}
    ...    sCellActivationMethod=${TC3_sCellActivationMethod}    sCellDeactivationTimerGNB=${TC3_sCellDeactivationTimerGNB}
    ...    dl_tput_list=@{dl_tput_list}    Ts_8533=True
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${ul_tput}     pdu=3
    Perform SA UE Register and start traffic for Blind ScellAddition and Blind ScellActivation    ${Single_CA_SA_UE_List}    4CC=True
    Sleep    90s
    Validate Pcell Throughput For Non CA Capable UEs    expected_dl_tput=${ul_tput}
    ...    UE_List=${Non_CA_SA_UE_List}
    Validate Pcell and Scell Throughput For SA UEs    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Stop Traffic and Detach SA UEs    ${Single_CA_SA_UE_List}    pdu=3
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    SA_UE_List=${Single_CA_SA_UE_List}
    [Teardown]    run keywords    Revert Gnb Configuration for 4CC
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}    4CC=True

CB008533_TC2_Extended Inter band DL 2FDD 2TDD FR1 Blind and Buffer based CA Activation MUE up to 4CCs_FDD as PCell
    [Tags]    AP_REG    CB008533_TC2
    [Setup]    Test Setup    4CC=True    sCellAdditionMethod=${TC3_sCellAdditionMethod}    Ts_8533=True
    ...    sCellActivationMethod=${TC2_sCellActivationMethod}    multi_dl_tput=@{multi_dl_tput}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs     ${Non_CA_SA_UE_List}    pdu=3
    Perform SA UE Register for Blind ScellAddition and Bufferbased ScellActivation with CSI Override    ${Multi_CA_SA_UE_List}    4CC=True
    Start traffic for all SA UEs    CA_SA_UE_List=${Multi_CA_SA_UE_List}    CA_DL_tput_list=${multi_dl_tput}
    ...    CA_UL_tput=${ul_tput}
    Sleep    90s
    Run Keyword And Continue On Failure    wait until keyword succeeds    3min    30s    Validate Pcell Throughput For Non CA Capable UEs
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run Keyword And Continue On Failure    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs
    ...    expected_dl_tput=${multi_dl_tput}    UE_List=${Multi_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Stop traffic for UEs    non_ca_sa_ue_list=${Non_CA_SA_UE_List}    ca_sa_ue_list=${Multi_CA_SA_UE_List}
    Verify scell deactivated for SA UEs    sa_ue_list=${Multi_CA_SA_UE_List}
    Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}    pdu=3
    Detach SA UEs for Blind ScellAddition    ${Multi_CA_SA_UE_List}    pdu=3
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    SA_UE_List=${Multi_CA_SA_UE_List}
    [Teardown]    run keywords    Revert Gnb Configuration for 4CC
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Multi_CA_SA_UE_List}    4CC=True

CB008533_TC3_Extended_Inter_band_DL_2FDD_2TDD_FR1_Blind_and_Buffer_RLQ_based_CA_Activation_MUE_upto_4CCs_FDD_as_PCell
    [Tags]    AP_REG    CB008533_TC3
    [Setup]    Test Setup    4CC=True    sCellAdditionMethod=${Blind_sCellAdditionMethod}    Ts_8533=True
    ...    sCellActivationMethod=${Blind_BufferRLQ_sCellActivationMethod}    dl_tput_list=@{multi_dl_tput}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs     ${Non_CA_SA_UE_List}    pdu=3
    Perform SA UE Register for Blind ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Multi_CA_SA_UE_List}    4CC=True
    Start traffic for all SA UEs    CA_SA_UE_List=${Multi_CA_SA_UE_List}    CA_DL_tput_list=${dl_tput_list}
    ...    CA_UL_tput=${ul_tput}
    Sleep    90s
    Run Keyword And Continue On Failure    wait until keyword succeeds    3min    30s    Validate Pcell Throughput For Non CA Capable UEs
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run Keyword And Continue On Failure    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs
    ...    expected_dl_tput=${multi_dl_tput}    UE_List=${Multi_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Activate testmode and verify scell deactivation    ue_list=${Multi_CA_SA_UE_List}
    Stop traffic for UEs    non_ca_sa_ue_list=${Non_CA_SA_UE_List}    ca_sa_ue_list=${Multi_CA_SA_UE_List}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    SA_UE_List=${Multi_CA_SA_UE_List}
    [Teardown]    run keywords    Revert Gnb Configuration for 4CC
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Multi_CA_SA_UE_List}    4CC=True

CB008533_TC4_Extended_Inter_band_DL_2FDD_2TDD_FR1_Measurement_and_Buffer_based_CA_Activation_MUE_up_to_4CCs_FDD_as_PCell
    [Tags]    AP_REG    CB008533_TC4
    [Setup]    Test Setup    4CC=True    sCellAdditionMethod=${TC4_sCellAdditionMethod}    Ts_8533=True
    ...    sCellActivationMethod=${TC4_sCellActivationMethod}    dl_tput_list=@{multi_dl_tput}
    ...     A1_carrier_freq=${A1_real_gnb_carrier_freq_cell3}    A2_carrier_freq_scells=&{A2_carrier_freq_scells}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs     ${Non_CA_SA_UE_List}    pdu=3
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Multi_CA_SA_UE_List}    ${A1_carrier_freq}    scell=${4CC_scell_index_1}    4CC=True
    Start traffic for all SA UEs    CA_SA_UE_List=${Multi_CA_SA_UE_List}    CA_DL_tput_list=${dl_tput_list}
    ...    CA_UL_tput=${ul_tput}
    Sleep    90s
    Run Keyword And Continue On Failure    wait until keyword succeeds    3min    30s    Validate Pcell Throughput For Non CA Capable UEs
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run Keyword And Continue On Failure    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs
    ...    expected_dl_tput=${multi_dl_tput}    UE_List=${Multi_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Stop traffic for UEs    non_ca_sa_ue_list=${Non_CA_SA_UE_List}    ca_sa_ue_list=${Multi_CA_SA_UE_List}
    Verify scell deactivated for SA UEs    sa_ue_list=${Multi_CA_SA_UE_List}
    Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}    pdu=3
    Detach SA UEs for Measurement Based ScellAddition
    ...    ${Multi_CA_SA_UE_List}    ${A2_carrier_freq_scells}    4CC=True
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    SA_UE_List=${Multi_CA_SA_UE_List}
    [Teardown]    run keywords    Revert Gnb Configuration for 4CC
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Multi_CA_SA_UE_List}    4CC=True

CB008533_TC5_Extended_Inter_band_DL_2FDD_2TDD_FR1_Measurement_and_Buffer_RLQ_based_CA_Activation_MUE_up_to_4CCs_FDD_as_PCell
    [Tags]    AP_REG    CB008533_TC5
    [Setup]    Test Setup    4CC=True    dl_tput_list=@{multi_dl_tput}     A1_carrier_freq=${A1_real_gnb_carrier_freq_cell3}
    ...    A2_carrier_freq_scells=&{A2_carrier_freq_scells}    Gnb_Commissioning=False
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${ul_tput}     pdu=3
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Multi_CA_SA_UE_List}    ${A1_carrier_freq}    scell=${4CC_scell_index_1}    4CC=True
    Start traffic for all SA UEs    CA_SA_UE_List=${Multi_CA_SA_UE_List}    CA_DL_tput_list=${dl_tput_list}    CA_UL_tput=${ul_tput}
    Sleep    90s
    Run Keyword And Continue On Failure    wait until keyword succeeds    3min    30s    Validate Pcell Throughput For Non CA Capable UEs
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run Keyword And Continue On Failure    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs
    ...    expected_dl_tput=${multi_dl_tput}    UE_List=${Multi_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Activate testmode and verify scell deactivation    ue_list=${Multi_CA_SA_UE_List}
    Stop traffic for UEs    non_ca_sa_ue_list=${Non_CA_SA_UE_List}
    Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}    pdu=3
    Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    ${Multi_CA_SA_UE_List}    ${A2_carrier_freq_scells}    4CC=True
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    SA_UE_List=${Multi_CA_SA_UE_List}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Multi_CA_SA_UE_List}    4CC=True

CB008533_TC6_Intra-frequency Inter-gNB 2FDD + 2TDD FR1 CA up to 4CCs Xn-based HO for SA UE_FDD_as_PCell
    [Documentation]    Verify Intra-frequency Inter-gNB 2FDD + 2TDD FR1 CA up to 4CCs Xn-based HO for SA UE (TDD as PCell)
    [Tags]    AP_REG    CB008533_TC6
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008533
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_cell3}    dl_tput_list=@{dl_tput_HO_list}    simulator_gnb_list=${simulator_gnb_list}
    ...    A3_carrier_sim_freq=${A1_real_gnb_carrier_freq_cell3}    A2_carrier_freq_scells=${A2_carrier_freq_scells}    4CC=True
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${ul_tput}     pdu=3
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...    ${Single_CA_SA_UE_List}    ${A1_carrier_freq}    4CC=True    scell=${4CC_scell_index_1}
    Start traffic for all SA UEs    CA_SA_UE_List=${Single_CA_SA_UE_List}    CA_DL_tput_list=${dl_tput_list}
    ...    CA_UL_tput=${ul_tput}
    Sleep    90s
    Run Keyword And Continue On Failure    wait until keyword succeeds    3min    30s    Validate Pcell Throughput For Non CA Capable UEs
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run Keyword And Continue On Failure    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Trigger Intrafreq XN Based SA Forward handover    ue_id=${Single_CA_SA_HO_UE}    carrier_frequency=${A3_carrier_sim_freq}
    ...    primary_cell=${primary_cell}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=3
    Update UE History Information     id=1    cell_type=large    nrcgi=311:489|0x06
    ...    gnb_id=22    time_ue_stayed_in_cell=97    action=commit    ue_enb_param_id=${Single_CA_SA_HO_UE}
    Trigger Intrafreq SA handover from Sim gNB to Real gNB for 4CC    ue_id=${Single_CA_SA_HO_UE}    csi_override_needed=True
    ...    scell_index=${4CC_scell_index}    phycell_id=${phycell_id}    primary_cell=${primary_cell}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Activate testmode and verify scell deactivation    ue_list=${Single_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    ${Single_CA_SA_UE_List}    ${A2_carrier_freq_scells}    4CC=True
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    SA_UE_List=${Single_CA_SA_UE_List}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}    4CC=True

CB008533_TC7_Inter_frequency_Inter_gNB_2FDD_2TDD_FR1 CA up to 4CCs Xn-based HO for SA UE_FDD_as_PCell
    [Documentation]    Verify Inter-frequency Inter-gNB 2FDD + 2TDD FR1 CA up to 4CCs Xn-based HO for SA UE (TDD as PCell)
    [Tags]    AP_REG    CB008533_TC7
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008533
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_cell3}    A2_carrier_freq=${A2_carrier_freq_sim_gnb}
    ...    dl_tput_list=@{dl_tput_HO_list}    A3_carrier_sim_freq=${A3_carrier_freq_sim_gnb_InterFreq}
    ...    A2_carrier_freq_scells=${A2_carrier_freq_scells}    simulator_gnb_list=${simulator_gnb_list}    4CC=True
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${ul_tput}     pdu=3
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...     ${Single_CA_SA_UE_List}    ${A1_carrier_freq}    4CC=True    scell=${4CC_scell_index_1}
    Start traffic for all SA UEs    CA_SA_UE_List=${Single_CA_SA_UE_List}    CA_DL_tput_list=${dl_tput_list}
    ...    CA_UL_tput=${ul_tput}
    Sleep    90s
    Run Keyword And Continue On Failure    wait until keyword succeeds    3min    30s    Validate Pcell Throughput For Non CA Capable UEs
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run Keyword And Continue On Failure    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Trigger Interfreq XN Based SA Forward handover    ue_id=${Single_CA_SA_HO_UE}    A2_carrier_freq=${A1_carrier_freq}
    ...    A3_carrier_freq=${A3_carrier_sim_freq}    primary_cell=${primary_cell}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=3
    Update UE History Information     id=1    cell_type=large    nrcgi=311:489|0x07
    ...    gnb_id=23    time_ue_stayed_in_cell=98    action=commit    ue_enb_param_id=${Single_CA_SA_HO_UE}
    Trigger Interfreq SA handover from Sim gNB to Real gNB for 4CC    ue_id=${Single_CA_SA_HO_UE}    csi_override_needed=True
    ...    scell_index=${4CC_scell_index}    primary_cell=${primary_cell}    phycell_id=${phycell_id}    A2_carrier_sim_freq=${A2_carrier_freq}
    ...    A3_carrier_sim_freq=${A1_carrier_freq}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Activate testmode and verify scell deactivation    ue_list=${Single_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    ${Single_CA_SA_UE_List}    ${A2_carrier_freq_scells}    4CC=True
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    SA_UE_List=${Single_CA_SA_UE_List}
    [Teardown]    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}    4CC=True

CB008533_TC8_Intra_frequency_Inter_gNB_2FDD_2TDD_FR1 CA up to 4CCs Ng_based HO for SA UE_FDD_as_PCell
    [Documentation]    Verify Intra_frequency_Inter_gNB_2FDD_2TDD_FR1 CA up to 4CCs Ng_based HO for SA UE_TDD_as_PCell
    [Tags]    AP_REG    CB008533_TC8
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008533    NGBased_HO=True    simulator_gnb_list=${simulator_gnb_list}
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_cell3}    A2_carrier_freq=${A3_carrier_freq_sim_gnb_InterFreq}
    ...    dl_tput_list=@{dl_tput_HO_list}    A2_carrier_freq_scells=${A2_carrier_freq_scells}    4CC=True
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${ul_tput}     pdu=3
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...     ${Single_CA_SA_UE_List}    ${A1_carrier_freq}    4CC=True    scell=${4CC_scell_index_1}
    Start traffic for all SA UEs    CA_SA_UE_List=${Single_CA_SA_UE_List}    CA_DL_tput_list=${dl_tput_list}
    ...    CA_UL_tput=${ul_tput}
    Sleep    90s
    Run Keyword And Continue On Failure    wait until keyword succeeds    3min    30s    Validate Pcell Throughput For Non CA Capable UEs
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run Keyword And Continue On Failure    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Trigger Intrafreq NG Based SA Forward handover    ue_id=${Single_CA_SA_HO_UE}    carrier_frequency=${A1_carrier_freq}
    ...    primary_cell=${primary_cell}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=3
    Trigger Intrafreq NG Based SA handover from Sim gNB to Real gNB for 4CC    ue_id=${Single_CA_SA_HO_UE}    scell_index=${4CC_scell_index}
    ...    carrier_frequency=${A1_carrier_freq}    primary_cell=${primary_cell}    phycell_id=${phycell_id}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Activate testmode and verify scell deactivation    ue_list=${Single_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    ${Single_CA_SA_UE_List}    ${A2_carrier_freq_scells}    4CC=True
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    SA_UE_List=${Single_CA_SA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=CB008533
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}    4CC=True

CB008533_TC9_Inter_frequency_Inter_gNB_2FDD_2TDD_FR1 CA up to 4CCs Ng_based HO for SA UE_FDD_as_PCell
    [Documentation]    Verify Inter_frequency_Inter_gNB_2FDD_2TDD_FR1 CA up to 4CCs Ng_based HO for SA UE_TDD_as_PCell
    [Tags]    AP_REG    CB008533_TC9
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008533    NGBased_HO=True    simulator_gnb_list=${simulator_gnb_list}
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_cell3}    A2_carrier_freq=${A2_carrier_freq_sim_gnb}
    ...    dl_tput_list=@{dl_tput_HO_list}    A3_carrier_sim_freq=${A3_carrier_freq_sim_gnb_InterFreq}    4CC=True
    ...    A2_carrier_freq_scells=${A2_carrier_freq_scells}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${ul_tput}     pdu=3
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...     ${Single_CA_SA_UE_List}    ${A1_carrier_freq}    4CC=True    scell=${4CC_scell_index_1}
    Start traffic for all SA UEs    CA_SA_UE_List=${Single_CA_SA_UE_List}    CA_DL_tput_list=${dl_tput_list}
    ...    CA_UL_tput=${ul_tput}
    Sleep    90s
    Run Keyword And Continue On Failure    wait until keyword succeeds    3min    30s    Validate Pcell Throughput For Non CA Capable UEs
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run Keyword And Continue On Failure    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Trigger Interfreq NG Based SA Forward handover    ue_id=${Single_CA_SA_HO_UE}    A2_carrier_freq=${A1_carrier_freq}
    ...    A3_carrier_freq=${A3_carrier_sim_freq}    primary_cell=${primary_cell}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=3
    Trigger Interfreq NG Based SA handover from Sim gNB to Real gNB for 4CC    ue_id=${Single_CA_SA_HO_UE}    scell_index=${4CC_scell_index}
    ...    A2_carrier_sim_freq=${A2_carrier_freq}    A3_carrier_sim_freq=${A1_carrier_freq}    primary_cell=${primary_cell}
    ...    A1_carrier_freq=${A1_carrier_freq}    phycell_id=${phycell_id}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Activate testmode and verify scell deactivation    ue_list=${Single_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    ${Single_CA_SA_UE_List}    ${A2_carrier_freq_scells}    4CC=True
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    SA_UE_List=${Single_CA_SA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=CB008533
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}    4CC=True

CB008533_TC10_Extended Inter band DL 2FDD + 2TDD FR1 Inter RAT Handover with CA Activation up to 4CCs_FDD_as_PCell
    [Documentation]    Verify Extended Inter band DL 2FDD + 2TDD FR1 Inter RAT Handover with CA Activation up to 4CCs (TDD as PCell)
    [Tags]    AP_REG    CB008533_TC10
    [Setup]    Test Setup for handover scenario    Handover_Feature=CB008533    interrat_ho=True
    ...    A1_carrier_freq=${A1_real_gnb_carrier_freq_cell3}    A2_carrier_freq=${A1_real_gnb_carrier_freq_cell3}
    ...    dl_tput_list=@{dl_tput_HO_list}    B2_carrier_freq=${B2_sim_gnb_carrier_freq}    4CC=True
    ...    A2_carrier_freq_scells=${A2_carrier_freq_scells}    simulator_gnb_list=${simulator_gnb_list_interRAT}
    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    UE Register and Start Traffic For SA Non CA Capable UEs    ${Non_CA_SA_UE_List}    ${ul_tput}     pdu=3
    Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    ...     ${Single_CA_SA_UE_List}    ${A1_carrier_freq}    4CC=True    scell=${4CC_scell_index_1}
    Start traffic for all SA UEs    CA_SA_UE_List=${Single_CA_SA_UE_List}    CA_DL_tput_list=${dl_tput_list}
    ...    CA_UL_tput=${ul_tput}
    Sleep    90s
    Run Keyword And Continue On Failure    wait until keyword succeeds    3min    30s    Validate Pcell Throughput For Non CA Capable UEs
    ...    expected_dl_tput=${ul_tput}    UE_List=${Non_CA_SA_UE_List}
    Run Keyword And Continue On Failure    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs
    ...    expected_dl_tput=${dl_tput_list}    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Trigger InterRAT SA Forward Handover    ue_id=${Single_CA_SA_HO_UE}    A2_carrier_freq=${A2_carrier_freq}    phycell_id=52
    ...    primary_cell=${primary_cell}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate throughput from bearer stats    ue_id=${Single_CA_SA_HO_UE}
    ...    expected_dl_tput=${dl_tput_list}    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=3
    Trigger InterRAT SA handover from Sim eNB to Real gNB    ue_id=${Single_CA_SA_HO_UE}    scell_index=${4CC_scell_index}
    ...    primary_cell=${primary_cell}    A1_carrier_freq=${A1_carrier_freq}
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s    Validate Pcell and Scell Throughput For SA UEs    expected_dl_tput=${dl_tput_list}
    ...    UE_List=${Single_CA_SA_UE_List}    Scell_Id=${4CC_SA_Scell_Index}
    Activate testmode and verify scell deactivation    ue_list=${Single_CA_SA_UE_List}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${Non_CA_SA_UE_List}
    Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    ...    ${Single_CA_SA_UE_List}    ${A2_carrier_freq_scells}    4CC=True
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword And Ignore Error    Collect and Validate Gnb PM counters    SA_UE_List=${Single_CA_SA_UE_List}
    [Teardown]    run keywords    Revert WTS and Gnb configuration    Handover_Feature=CB008533    interrat=True
    ...    AND    Test Teardown    sa_nonca_ue_list=${Non_CA_SA_UE_List}    sa_ue_list=${Single_CA_SA_UE_List}    4CC=True
