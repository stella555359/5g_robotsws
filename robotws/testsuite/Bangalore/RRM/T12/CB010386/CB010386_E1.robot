*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO
...           RAN_5G_TDD   RAN_5G     CONFIGURED

Documentation       :copyright: Nokia
...                 :author   : Vikash Kumar
...                 :contact  : vikash.20.kumar@nokia.com
...                 :Feature  : CB0010386-E_1_Verify_inter-frequency_handover_for_a_UE_configured_with
...                             FDD-FDD CA - inter-RAT from NR to LTE

Resource        resources/Keywords/CB10386_Keywords.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Suite TearDown for CB010386

*** Variables ***
${UE_ID_SA}            51
${EventA2}             A2
${EventB2}             B2
${PhyCellId}           52
${B2PhyCellId}         11
*** Test Cases ***
[1][1.0] CB010386-E_1_Verify_inter-frequency_HO_UE_configured_with_FDD_FDD_CA_inter_RAT_NR_to_LTE
    [Documentation]         CB0010386-E_1_Verify_inter-frequency_handover_for_a_UE_configured_with
    ...                     FDD-FDD CA - inter-RAT from NR to LTE
#    [Tags]    QC_60598   QCD_MN_RAN    QCP_RAN_VRF
    Log to Console          Starting the test......
    [Setup]                 Prepare for test Case - CB0010386_E1
    Start pcap collection in gNB CU       gnbTcpdump        -i any -s0
    UE Register should be Successful for SA         ${UE_ID_SA}
    Start Traffic    ${UE_ID_SA}    10     10       trf_id=1
    Start Traffic    ${UE_ID_SA}    10     10       trf_id=2
    Start Traffic    ${UE_ID_SA}    10     10       trf_id=3
    Start Traffic    ${UE_ID_SA}    10     10       trf_id=4
    Start Traffic    ${UE_ID_SA}    10     10       trf_id=5
    Start Traffic    ${UE_ID_SA}    10     10       trf_id=6
    Sleep            10s
    Display UE statistics       id=${UE_ID_SA}      type=pdsch,pusch           scell=0-3
    ${A2MeasId}      Display Measurement Configuration for UE        ${UE_ID_SA}         ${EventA2}
    Trigger A2 for IRAT HO      ${UE_ID_SA}         ${A2MeasId}      ${PhyCellId}
    Sleep           10s
    ${B2MeasId}      Display Measurement Configuration for UE        ${UE_ID_SA}         ${EventB2}
    Trigger B2 HO and verify    ${UE_ID_SA}         ${B2MeasId}      ${B2PhyCellId}
    Sleep           10s
    UE Deregister should be Successful for SA       ${UE_ID_SA}
    ${pcap_file}     Stop pcap collection in gNB CU        gnbTcpdump          ${Log_Path}
    Get DRX_Setup value                             ${pcap_file}
    Get DRX_config value                            ${pcap_file}
    Get scelltoAddmodlist value                     ${pcap_file}
    Get measGapconfig gapFR1 value                  ${pcap_file}
    [Teardown]     Run Keyword And Ignore Error     Common test case tear down LO AP LO

