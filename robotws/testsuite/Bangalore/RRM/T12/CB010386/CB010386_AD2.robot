*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO
...           RAN_5G_TDD   RAN_5G     CONFIGURED

Documentation       :copyright: Nokia
...                 :author   : Vikash Kumar
...                 :contact  : vikash.20.kumar@nokia.com
...                 :Feature  : to check TDD n90 band L3 Call with chBW 100 Mhz

Resource        resources/Keywords/CB10386_Keywords.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Suite TearDown for CB010386

*** Variables ***
${UE_ID_SA}        1
${UE_ID_NSA}       101
${pattern1}        supportedSubcarrierSpacingUL kHz30
${pattern2}        supportedBandwidthUL fr1 : mhz100
${pattern3}        supportedSubcarrierSpacingDL kHz30
${pattern4}        supportedBandwidthDL fr1 : mhz100
${pattern5}        freqBandIndicatorNR 90
${pattern6}        bandNR 90
${Expected_pnr_value_D20}                29
${Expected_pmax_Cell_A_value_D20}        26
${Expected_pmax_Cell_B_value_D20}        26
${filter_D20}      nr-rrc && nr-rrc.physCellId == 52 && nr-rrc.p_NR_FR1 && nr-rrc.p_Max && nr-rrc.srb_Identity == 1
${Expected_pnr_value_D28}               28
${Expected_pmax_Cell_A_value_D28}        23
${Expected_pmax_Cell_B_value_D28}        26


*** Test Cases ***
[1][2.0] CB010386_A_10_Verify_the_TDD_n90_band_Successful_cell_UE_Attach_ULDL_Traffic_setup_with_chBW_100Mhz_in_SA_and_NSA
    [Documentation]         [1]CB008187_B03_B10_1_Verify_RAN_UE_ID_Sent_by_gNB-CU-CP_and_gNB-DU_during_initial
    ...                     _access_due_to_successful_SA_call
    [Tags]    QC_60557   QCD_MN_RAN    QCP_RAN_VRF
    Log to Console          Starting the test......
    [Setup]                 Prepare for test Case - CB0010386_A_10
    ${PDU_session_setup_output}     SA Call for Feature CB010386                    ${UE_ID_SA}
    Print Matching Lines from Output File           ${PDU_session_setup_output}     ${pattern1}
    Print Matching Lines from Output File           ${PDU_session_setup_output}     ${pattern2}
    Print Matching Lines from Output File           ${PDU_session_setup_output}     ${pattern3}
    Print Matching Lines from Output File           ${PDU_session_setup_output}     ${pattern4}
    Print Matching Lines from Output File           ${PDU_session_setup_output}     ${pattern5}
    ${ue_attach_output}             NSA Call for Feature CB010386                   ${UE_ID_NSA}
    Print Matching Lines from Output File           ${ue_attach_output}             ${pattern6}
    [Teardown]     Run Keyword And Ignore Error     Common test case tear down LO AP LO

[1][2.0] CB0010386-D_20_Verify_UE_Higher_Power_CA_in band_n5-n77_WO_ue_PCPerBandPerBC-r17_CAHPBC_Disabled_SANSA_T_PC_F_Sc
    [Documentation]         CB0010386-D_28_Verify_UE_Higher_Power_CA_in
    ...                     band_n25-n41_With_ue_PowerClassPerBandPerBC-r17_CAHighPowerBC=Enabled_SANSA_(FDD_PCell_TDD_Scell)
    [Tags]    QC_60553   QCD_MN_RAN    QCP_RAN_VRF
    Log to Console          Starting the test......
    [Setup]                 Prepare for test Case - CB0010386_D_20
    Start pcap collection in gNB CU       gnbTcpdumpD20        -i any -s0
    UE Register should be Successful for SA         ${UE_ID_SA}
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=1
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=2
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=3
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=4
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=5
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=6
    UE Deregister should be Successful for SA
    ${pcap_file}     Stop pcap collection in gNB CU        gnbTcpdumpD20          ${Log_Path}
    ${pnr_value}     Get PNR_FR1 value        ${pcap_file}        ${filter_D20}
    Should Be Equal    ${pnr_value}    ${Expected_pnr_value_D20}
    ${pmax_value}    Get P_max value          ${pcap_file}        ${filter_D20}
    Should Be Equal    ${pmax_value}[0]    ${Expected_pmax_Cell_A_value_D20}
    Should Be Equal    ${pmax_value}[1]    ${Expected_pmax_Cell_B_value_D20}
    [Teardown]     Run Keyword And Ignore Error     Common test case tear down LO AP LO

[1][2.0] CB0010386-D_28_Verify_UE_Higher_Power_CA_in band_n25-n41_With_ue_PCPerBandPerBC-r17_CAHPBC_Enabled_SANSA_F_PC_T_Sc
    [Documentation]         CB0010386-D_28_Verify_UE_Higher_Power_CA_in
    ...                     band_n25-n41_With_ue_PowerClassPerBandPerBC-r17_CAHighPowerBC=Enabled_SANSA_(FDD_PCell_TDD_Scell)
    [Tags]    QC_60554   QCD_MN_RAN    QCP_RAN_VRF
    Log to Console          Starting the test......
    [Setup]                 Prepare for test Case - CB0010386_D_28
    Start pcap collection in gNB CU       gnbTcpdumpD28        -i any -s0
    UE Register should be Successful for SA         ${UE_ID_SA}
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=1
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=2
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=3
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=4
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=5
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=6
    UE Deregister should be Successful for SA
    ${pcap_file}     Stop pcap collection in gNB CU        gnbTcpdumpD28          ${Log_Path}
    ${pnr_value}     Get PNR_FR1 value        ${pcap_file}
    Should Be Equal    ${pnr_value}    ${Expected_pnr_value_D28}
    ${pmax_value}    Get P_max value          ${pcap_file}
    Should Be Equal    ${pmax_value}[0]    ${Expected_pmax_Cell_A_value_D28}
    Should Be Equal    ${pmax_value}[1]    ${Expected_pmax_Cell_B_value_D28}
    [Teardown]     Run Keyword And Ignore Error     Common test case tear down LO AP LO
