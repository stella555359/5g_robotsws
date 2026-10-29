*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO
...           RAN_5G_TDD   RAN_5G     CONFIGURED

Documentation       :copyright: Nokia
...                 :author   : Vikash Kumar
...                 :contact  : vikash.20.kumar@nokia.com
...                 :Feature  : The aim of the feature is to validate RAN UE ID in NSETAPX messages.
...                             RAN UE ID provide easier correlation of PCMD/Call trace messages coming from CU (CP only)
...                             within 5G (NSA mode) as well as correlation of 5G and LTE records in NSA mode.

Resource        resources/Keywords/CB008187_Keyword.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables ***
${UE_ID_NSA}                101
${eth_pcap_file}            eth3_tcp.pcap
${NRMTRACEDU}               MRBTS-1/NRBTS-1/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
${NRMTRACECU}               MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1
*** Test Cases ***
[1][1.0] CB008187-5G-A_1_B01-RAN_UE_ID_Sent_by_gNB-CU-CP_during_SgNB_Addition_NSA_3x
    [Documentation]    This test scenario validates that RAN UE ID is sent by gNB-CU-CP during SgNB Addition [NSA 3x]
    [Tags]    QC_28328   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare for test Case - CB008187_A01_B14
    Make NSA Call for 8187        ${UE_ID_NSA}
    sleep     5s
    GNB Delta commission        ${CURDIR}/config/scf/Delta_Configuration_Delete_NRMTRACE_CU_AND_DU.json
    ${pcap_file}    Stop pcap collection in gNB CU
    ${e1ap_id}      get e1ap id from pcap             ${pcap_file}
    ${f1ap_id}      get f1ap id from pcap             ${pcap_file}        ${f1ap_UEContextSetupRequest_filter}
    ${generated_RAN_UE_id1}    verify f1ap and e1ap IDs are equal         ${f1ap_id}          ${e1ap_id}
    verify RAN UE ID in startrecordings CU and DU     ${generated_RAN_UE_id1}      eth3_tcp.pcap
    verify RAN UE ID in reports CU and DU             ${generated_RAN_UE_id1}      eth_pcap_file=eth3_tcp.pcap
    verify RAN UE ID in stoprecordings CU and DU      ${generated_RAN_UE_id1}      eth3_tcp.pcap
    NSA Call UE Detach
    [Teardown]     Run Keyword And Ignore Error     Tear Down for test Case - CB008187_A01_B14
