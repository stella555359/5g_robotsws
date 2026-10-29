*** Settings ***
Documentation       :copyright: Nokia
...                 :author   : Vikash Kumar
...                 :contact  : vikash.20.kumar@nokia.com
...                 The aim of the feature is to verify successful exchange of chipset and vendor information
...                 This test case verifies on TDD UE capability,so FDD configuration is being removed from the gNB configuration

Resource            resources/Keywords/CB014062_Keyword.robot

Suite Setup         Updated Suite Setup
Suite Teardown      Common Suite Teardown


*** Variables ***
${UE_ID1}       51
${UE_ID5}       5
${UE_ID6}       6
${UE_ID7}       7
${measID}       1
${gw_ID}        1
${TRAFFIC_DL_RATE}    5
${TRAFFIC_UL_RATE}    2
${TOPOLOGY}           CLOUD_5G_I_LOO_AP_LOOO
${Timeout_SA}         45
${NSETAPX_CAP_REQ_FIL}     nr-rrc.rat_Type == 0 && nr-rrc.frequencyBandListFilter == 6 && nr-rrc.bandNR == 25
${NSETAPX_CAP_INF_FIL}     ngap.procedureCode == 44 && nr-rrc.rat_Type == 0 && ${APPFREW} && nr-rrc.bandNR == 25
${APPFREW}                 nr-rrc.appliedFreqBandListFilter == 3
${TIMEOUT}                 10min
${RETRY_TIME}              30s


*** Test Cases ***
[1][1.0] CB014062_B1_01_Successful_Chipset_Information_Exchange
    [Documentation]      This testcase is used to verify successful exchange of chipset information
    [Tags]    QC_292593   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]       Prepare For Test Case CB014062 Chipset
    slog.Start Syslog   ${Log_Path}     SysLogCHIP_TMO.LOG
    Log To Console      Starting the case ...
    Start Pcap Collection In GNB CU    gnbTcpdump1    -i any -s0
    wtsrunner.AMF UE ICS Param
    ...    id=1
    ...    ue=${UE_ID1}
    ...    trace_activation=on
    ...    trace_plmn=310:260
    ...    trace_ref_id=10
    ...    trace_rec_session_ref_id=20
    ...    trace_depth=medium
    ...    ifaces_to_trace=NG-C,Xn-C,Uu,F1-C,E1
    ...    tce_ip=10.0.1.1
    ...    core_network_assistance_info=on
    ...    ue_identity_index_value=1
    ...    ue_specific_drx=256
    ...    periodic_registration_update_timer=1:10min
    ...    plmn_id=310:260
    ...    tac_id=200
    Sleep   3s
    Wait Until Keyword Succeeds    60 seconds    10 seconds    UE Register Should Be Successful For SA     ${UE_ID1}    ${gw_ID}
    DL Traffic Should Be Successful CB014062    20           ${UE_ID1}
    UL Traffic Should Be Successful CB014062    20           ${UE_ID1}
    ${pcap_file1}    Stop Pcap Collection In GNB CU    gnbTcpdump1
    Get Chipset And RAN ID Info From UEcapinfo    ${pcap_file1}
    Get EUTRA Information From UEcapinfo          ${pcap_file1}
    Stop Data UL And DL CB014062       ${UE_ID1}
    Log to Console      Waiting for UE Context Release Complete
    Read WTS Output Until Pattern Matches      ${UE_rrc_reestablish_complete_pattern}      180
    Sleep    30s
    Start Pcap Collection In GNB CU    gnbTcpdump2    -i any -s0
    Log To Console      UE starts paging
    Wait Until Keyword Succeeds    ${TIMEOUT}     ${RETRY_TIME}     UE Trying To Page AMF
    DL Traffic Should Be Successful CB014062    20           ${UE_ID1}
    Sleep   10s
    ${pcap_file2}    Stop Pcap Collection In GNB CU    gnbTcpdump2
    Run Keyword And Ignore Error    Verifying The PM Counter For CB014062
    UE Deregister Should Be Successful For SA    ${UE_ID1}
    Check For Dummy4 UE Radio Access Cap Information    ${pcap_file2}
    Check If UE Cap Enquiry Is Not Sent By GNB          ${pcap_file2}
    [Teardown]    Run Keyword And Ignore Error    Tear Down For Test Case CB014062 Chipset
