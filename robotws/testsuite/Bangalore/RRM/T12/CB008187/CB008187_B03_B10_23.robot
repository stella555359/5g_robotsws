*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO
...           RAN_5G_TDD   RAN_5G     CONFIGURED
Documentation       :copyright: Nokia
...                 :author   : Vikash Kumar
...                 :contact  : vikash.20.kumar@nokia.com
...                 The aim of the feature is to check if RAN_UE_ID , gNB-CU UE F1AP ID, gNB-CU-CP UE E1AP ID
...                 and RAN UE NGAP ID all are equal
...                 This test case is used to check robustness with rrc-reestablish setup for all RAN UE ID

Resource            resources/Keywords/CB008187_Keyword.robot

Suite Setup         Updated Suite Setup
Suite Teardown      Common Suite Teardown


*** Variables ***
${UE_ID}       1
${ngap_ID_rrc_filter}           ngap.procedureCode == 15 and ngap.id == 90 and not ntrstr.syncpattern == 0xd0b0061e


*** Test Cases ***
[1][1.0] CB008187_B03_B10_2_Verify_RAN_UE_ID_Sent_by_gNB-CU-CP_and_gNB-DU_during_Early_Introduction_of_RRC_connection_reestablishment_via_RRC_Setup
    [Documentation]      This testcase is used to make multiple RRC Connection Re-establishment under the same gNB-DU
    ...                  via RRCSetup and verify gNB is generating new RAN UE ID for every RRC Connection Re-establishment
    [Tags]    QC_28270   QCD_MN_RAN    QCP_RAN_VRF
    Log to Console       Starting the test......
    [Setup]              Prepare for test Case - CB008187_B03_B10_2
    Start pcap collection in gNB CU       gnbTcpdump0        -i any -s0
    UE Register and verify for SA
    Start Subscriber Trace
    ${pcap_file0}    Stop pcap collection in gNB CU          gnbTcpdump0
    ${f1ap_id}       get f1ap id from pcap           ${pcap_file0}
    ${ngap_id}       get ngap id from pcap           ${pcap_file0}
    ${generated_RAN_UE_id}      verify f1ap and ngap IDs are equal         ${f1ap_id}      ${ngap_id}
    Start Tcp Pcap on wts                 eth3_tcp1.pcap     log_dirpath=${Log_Path}
    Start pcap collection in gNB CU       gnbTcpdump1        -i any -s0
    Re-establish rrc setup UE
    Stop Subscriber Trace
    Start Subscriber Trace      trace_session_id=2
    ${pcap_file}     Stop pcap collection in gNB CU          gnbTcpdump1
    ${f1ap_id}       get f1ap id from pcap           ${pcap_file}
    ${ngap_id}       get ngap id from pcap           ${pcap_file}        ${ngap_ID_rrc_filter}
    ${generated_RAN_UE_id1}      verify f1ap and ngap IDs are equal      ${f1ap_id}      ${ngap_id}
    verify RAN UE ID in startrecordings nsetapx      ${generated_RAN_UE_id1}         eth3_tcp1.pcap
    verify RAN UE ID in stoprecordings nsetapx       ${generated_RAN_UE_id}          eth3_tcp1.pcap
    verify RAN UE ID in reports nsetapx              ${generated_RAN_UE_id1}         ${generated_RAN_UE_id}          eth3_tcp1.pcap
    Stop Tcp Pcap on wts
    Start Tcp Pcap on wts                 eth3_tcp2.pcap     log_dirpath=${Log_Path}
    Start pcap collection in gNB CU       gnbTcpdump2        -i any -s0
    Re-establish rrc setup UE
    Start Subscriber Trace
    ${pcap_file}     Stop pcap collection in gNB CU          gnbTcpdump2
    ${f1ap_id}       get f1ap id from pcap       ${pcap_file}
    ${ngap_id}       get ngap id from pcap       ${pcap_file}             ${ngap_ID_rrc_filter}
    ${generated_RAN_UE_id2}      verify f1ap and ngap IDs are equal       ${f1ap_id}      ${ngap_id}
    verify RAN UE ID in startrecordings nsetapx      ${generated_RAN_UE_id2}         eth3_tcp2.pcap
    verify RAN UE ID in stoprecordings nsetapx       ${generated_RAN_UE_id1}         eth3_tcp2.pcap
    verify RAN UE ID in reports nsetapx              ${generated_RAN_UE_id2}         ${generated_RAN_UE_id1}         eth3_tcp2.pcap
    Should Not Be Equal         ${generated_RAN_UE_id1}         ${generated_RAN_UE_id2}
    Stop Tcp Pcap on wts
    Start Tcp Pcap on wts       eth3_tcp3.pcap       log_dirpath=${Log_Path}
    Disable celltrace PCMD and SBA traces
    verify RAN UE ID in stoprecordings nsetapx       ${generated_RAN_UE_id2}         eth3_tcp3.pcap
    Stop Tcp Pcap on wts
    [Teardown]     Run Keyword And Ignore Error     Tear Down for test Case - CB008187_B03_B10_2

[1][1.0] CB008187_B03_B10_3_Verify_RAN_UE_ID_Sent_by_gNB-CU-CP_and_gNB-DU_during_RRC_Connection_Re-establishment_under_the_same_gNB-DU_via_RRCSetup
    [Documentation]             This testcase is used to make multiple RRC Connection Re-establishment
    ...                         (with invalid crnti and invalid short MAC-I) under the same gNB-DU via RRCSetup
    ...                         and verify gNB is generating new RAN UE ID for every RRC Connection Re-establishment
    [Tags]    QC_28271   QCD_MN_RAN    QCP_RAN_VRF
    Log to Console              Starting the test......
    [Setup]                     Prepare for test Case - CB008187_B03_B10_2
    Start pcap collection in gNB CU      gnbTcpdump0        -i any -s0
    UE Register and verify for SA
    Start Subscriber Trace
    ${pcap_file0}    Stop pcap collection in gNB CU         gnbTcpdump0
    ${f1ap_id}       get f1ap id from pcap          ${pcap_file0}
    ${ngap_id}       get ngap id from pcap          ${pcap_file0}
    ${generated_RAN_UE_id}      verify f1ap and ngap IDs are equal      ${f1ap_id}        ${ngap_id}
    Start Tcp Pcap on wts                 eth3_tcp1.pcap        log_dirpath=${Log_Path}
    Start pcap collection in gNB CU       gnbTcpdump1           -i any -s0
    Re-establish rrc setup UE with action           ${UE_ID}           invalid_crnti
    Stop Subscriber Trace
    sleep       10s
    Start Subscriber Trace      trace_session_id=2
    ${pcap_file}     Stop pcap collection in gNB CU         gnbTcpdump1
    ${f1ap_id}       get f1ap id from pcap          ${pcap_file}
    ${ngap_id}       get ngap id from pcap          ${pcap_file}        ${ngap_ID_rrc_filter}
    ${generated_RAN_UE_id1}      verify f1ap and ngap IDs are equal     ${f1ap_id}        ${ngap_id}
    verify RAN UE ID in startrecordings nsetapx     ${generated_RAN_UE_id1}     eth3_tcp1.pcap
    verify RAN UE ID in stoprecordings nsetapx      ${generated_RAN_UE_id}      eth3_tcp1.pcap
    verify RAN UE ID in reports nsetapx             ${generated_RAN_UE_id1}     ${generated_RAN_UE_id}      eth3_tcp1.pcap
    Stop Tcp Pcap on wts
    Start Tcp Pcap on wts               eth3_tcp2.pcap              log_dirpath=${Log_Path}
    Start pcap collection in gNB CU     gnbTcpdump2                 -i any -s0
    Re-establish rrc setup UE with action           ${UE_ID}        invalid_short_mac_i
    Stop Subscriber Trace       trace_session_id=2
    sleep       10s
    Start Subscriber Trace      trace_session_id=3
    ${pcap_file}     Stop pcap collection in gNB CU         gnbTcpdump2
    ${f1ap_id}       get f1ap id from pcap          ${pcap_file}
    ${ngap_id}       get ngap id from pcap          ${pcap_file}        ${ngap_ID_rrc_filter}
    ${generated_RAN_UE_id2}      verify f1ap and ngap IDs are equal     ${f1ap_id}         ${ngap_id}
    verify RAN UE ID in startrecordings nsetapx     ${generated_RAN_UE_id2}      eth3_tcp2.pcap
    verify RAN UE ID in stoprecordings nsetapx      ${generated_RAN_UE_id1}      eth3_tcp2.pcap
    verify RAN UE ID in reports nsetapx             ${generated_RAN_UE_id2}      ${generated_RAN_UE_id1}     eth3_tcp2.pcap
    Should Not Be Equal         ${generated_RAN_UE_id1}         ${generated_RAN_UE_id2}
    Stop Tcp Pcap on wts
    Start Tcp Pcap on wts               eth3_tcp3.pcap            log_dirpath=${Log_Path}
    Disable celltrace PCMD and SBA traces
    verify RAN UE ID in stoprecordings nsetapx      ${generated_RAN_UE_id2}      eth3_tcp3.pcap
    Stop Tcp Pcap on wts
    [Teardown]     Run Keyword And Ignore Error     Tear Down for test Case - CB008187_B03_B10_2

