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
${UE_ID_SA}=        1
${Filter_PNR}                        nr-rrc && nr-rrc.physCellId == 52 && nr-rrc.p_NR_FR1
${Filter_PCELL}                      nr-rrc && nr-rrc.physCellId == 52 && nr-rrc.p_Max && nr-rrc.srb_Identity == 1
${Expected_pmax_Cell_A_value}        26
${Expected_pmax_Cell_B_value}        23

*** Test Cases ***
[1][2.0] CB0010386-D_48_Verify_UE_Higher_Power_CA_in band_n66-n77_With_ue_PCPerBandPerBC-r17_CAHPBC_p-NR-FR1_not_sig_SANSA_T_PC_F_Sc
    [Documentation]         CB0010386-D_48_Verify_UE_Higher_Power_CA_in band_n66-n77_
    ...                     With_ue_PowerClassPerBandPerBC-r17_CAHighPowerBC=p-NR-FR1 not signaled_SANSA_(TDD_PCell_FDD_Scell)
#    [Tags]    QC_28300   QCD_MN_RAN    QCP_RAN_VRF
    Log to Console          Starting the test......
    [Setup]                 Prepare for test Case - CB0010386_D_48
    Start pcap collection in gNB CU       gnbTcpdump        -i any -s0
    UE Register should be Successful for SA         ${UE_ID_SA}
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=1
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=2
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=3
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=4
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=5
    Start Traffic    ${UE_ID_SA}    10     10     trf_id=6
    Sleep   20s
    UE Deregister should be Successful for SA
    ${pcap_file}     Stop pcap collection in gNB CU        gnbTcpdump          ${Log_Path}
    ${pnr_value}     Get PNR_FR1 value        ${pcap_file}      ${Filter_PNR}
    Should Be Empty     ${pnr_value}
    ${pmax_value}    Get P_max value          ${pcap_file}      ${Filter_PCELL}
    Should Be Equal    ${pmax_value}[0]    ${Expected_pmax_Cell_A_value}
    Should Be Equal    ${pmax_value}[1]    ${Expected_pmax_Cell_B_value}
    [Teardown]     Run Keyword And Ignore Error     Common test case tear down LO AP LO
