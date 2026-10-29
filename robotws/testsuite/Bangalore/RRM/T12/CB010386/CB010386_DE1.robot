*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO
...           RAN_5G     CONFIGURED

Documentation       :copyright: Nokia
...                 :author   : Vikash Kumar
...                 :contact  : vikash.20.kumar@nokia.com

Resource        resources/Keywords/CB10386_Keywords.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Suite TearDown for CB010386


*** Variables ***
${UE_ID_SA}                             1
${Expected_pnr_value_D1}                28
${Expected_pmax_Cell_A_value_D1}        23
${Expected_pmax_Cell_B_value_D1}        26
${Filter_PNR}                        nr-rrc && nr-rrc.physCellId == 52 && nr-rrc.p_NR_FR1
${Filter_PCELL}                      nr-rrc && nr-rrc.physCellId == 52 && nr-rrc.p_Max && nr-rrc.srb_Identity == 1
${Expected_pmax_Cell_A_value_D48}        26
${Expected_pmax_Cell_B_value_D48}        23
${UE_ID_SA_E1}         51
${EventA2}             A2
${EventB2}             B2
${PhyCellId}           52
${B2PhyCellId}         11


*** Test Cases ***
[1][2.0] CB0010386-D_1_Verify_UE_Higher_Power_CA_in band_n1-n78_WO_ue_PCPerBandPerBC-r17_CAHPBC_Enabled_SANSA_F_PC_T_Sc
    [Documentation]         CB0010386-D_1_Verify_UE_Higher_Power_CA_in band_n1-n78_
    ...                     WO_ue_PowerClassPerBandPerBC-r17_CAHighPowerBC=Enabled_SANSA_(FDD_PCell_TDD_Scell)
    [Tags]    QC_60519   QCD_MN_RAN    QCP_RAN_VRF
    Log to Console          Starting the test......
    [Setup]                 Prepare for test Case - CB0010386_D_1
    Start pcap collection in gNB CU       gnbTcpdumpD1        -i any -s0
    UE Register should be Successful for SA         ${UE_ID_SA}
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=1
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=2
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=3
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=4
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=5
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=6
    UE Deregister should be Successful for SA
    ${pcap_file}     Stop pcap collection in gNB CU        gnbTcpdumpD1          ${Log_Path}
    ${pnr_value}     Get PNR_FR1 value        ${pcap_file}
    Should Be Equal    ${pnr_value}    ${Expected_pnr_value_D1}
    ${pmax_value}    Get P_max value          ${pcap_file}
    Should Be Equal    ${pmax_value}[0]    ${Expected_pmax_Cell_A_value_D1}
    Should Be Equal    ${pmax_value}[1]    ${Expected_pmax_Cell_B_value_D1}
    [Teardown]    Run Keyword And Ignore Error      Common test case tear down LO AP LO

[1][2.0] CB0010386-D_48_Verify_UE_Higher_Power_CA_in band_n66-n77_With_ue_PCPerBandPerBC-r17_CAHPBC_p-NR-FR1_not_sig_SANSA_T_PC_F_Sc
    [Documentation]         CB0010386-D_48_Verify_UE_Higher_Power_CA_in band_n66-n77_
    ...                     With_ue_PowerClassPerBandPerBC-r17_CAHighPowerBC=p-NR-FR1 not signaled_SANSA_(TDD_PCell_FDD_Scell)
    [Tags]    QC_60555   QCD_MN_RAN    QCP_RAN_VRF
    Log to Console          Starting the test......
    [Setup]                 Prepare for test Case - CB0010386_D_48
    Start pcap collection in gNB CU       gnbTcpdumpD48        -i any -s0
    UE Register should be Successful for SA         ${UE_ID_SA}
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=1
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=2
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=3
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=4
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=5
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=6
    Sleep   20s
    UE Deregister should be Successful for SA
    ${pcap_file}     Stop pcap collection in gNB CU        gnbTcpdumpD48          ${Log_Path}
    ${pnr_value}     Get PNR_FR1 value        ${pcap_file}      ${Filter_PNR}
    Should Be Empty     ${pnr_value}
    ${pmax_value}    Get P_max value          ${pcap_file}      ${Filter_PCELL}
    Should Be Equal    ${pmax_value}[0]    ${Expected_pmax_Cell_A_value_D48}
    Should Be Equal    ${pmax_value}[1]    ${Expected_pmax_Cell_B_value_D48}
    [Teardown]     Run Keyword And Ignore Error     Common test case tear down LO AP LO

[1][1.0] CB010386-E_1_Verify_inter-frequency_HO_UE_configured_with_FDD_FDD_CA_inter_RAT_NR_to_LTE
    [Documentation]         CB0010386-E_1_Verify_inter-frequency_handover_for_a_UE_configured_with
    ...                     FDD-FDD CA - inter-RAT from NR to LTE
    [Tags]    QC_60598   QCD_MN_RAN    QCP_RAN_VRF
    Log to Console          Starting the test......
    [Setup]                 Prepare for test Case - CB0010386_E1
    Start pcap collection in gNB CU       gnbTcpdumpE1        -i any -s0
    UE Register should be Successful for SA         ${UE_ID_SA_E1}
    Start Traffic    ${UE_ID_SA_E1}    10     10       trf_id=1
    Start Traffic    ${UE_ID_SA_E1}    10     10       trf_id=2
    Start Traffic    ${UE_ID_SA_E1}    10     10       trf_id=3
    Start Traffic    ${UE_ID_SA_E1}    10     10       trf_id=4
    Start Traffic    ${UE_ID_SA_E1}    10     10       trf_id=5
    Start Traffic    ${UE_ID_SA_E1}    10     10       trf_id=6
    Sleep            10s
    Display UE statistics       id=${UE_ID_SA_E1}      type=pdsch,pusch           scell=0-3
    ${A2MeasId}      Display Measurement Configuration for UE        ${UE_ID_SA_E1}         ${EventA2}
    Trigger A2 for IRAT HO      ${UE_ID_SA_E1}         ${A2MeasId}      ${PhyCellId}
    Sleep           10s
    ${B2MeasId}      Display Measurement Configuration for UE        ${UE_ID_SA_E1}         ${EventB2}
    Trigger B2 HO and verify    ${UE_ID_SA_E1}         ${B2MeasId}      ${B2PhyCellId}
    Sleep           10s
    UE Deregister should be Successful for SA       ${UE_ID_SA_E1}
    ${pcap_file}     Stop pcap collection in gNB CU        gnbTcpdumpE1          ${Log_Path}
    Get DRX_Setup value                             ${pcap_file}
    Get DRX_config value                            ${pcap_file}
    Get scelltoAddmodlist value                     ${pcap_file}
    Get measGapconfig gapFR1 value                  ${pcap_file}
    [Teardown]     Run Keyword And Ignore Error     Common test case tear down LO AP LO
