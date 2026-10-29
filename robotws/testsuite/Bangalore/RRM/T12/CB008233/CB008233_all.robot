*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO
...           RAN_5G_TDD   RAN_5G     CONFIGURED

Documentation       :copyright:     Nokia
...                 :author   :     Vikash Kumar
...                 :contact  :     vikash.20.kumar@nokia.com
...                 :Feature  :     The purpose of this TC to check gNB stops GTP-U path supervision
...                                 for an S1-U path when Once bulk release is triggered by CUCP due to cell block
...                                 or X2-C link failure or bulk release is triggered by peer eNB,
...                                 the impacted UE contexts will be released together by E1AP:Partial reset procedure

Resource          resources/Keywords/CB008233_keywords.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${SA_UE_ID1}             1
${SA_UE_ID2}             2
${SA_UE_ID3}             3
${SA_UE_ID4}             4
${NSA_UE_ID1}            101
${NSA_UE_ID2}            102
${NSA_UE_ID3}            103
${NSA_UE_ID4}            104
${DL_RATE}               20
${UL_RATE}               20
${TIMEOUT}               12 min
${RETRY_TIME}            30s
${ALARM_ID}              7107
${FAULT_ID}              7706
${Filter}                e1ap.procedureCode == 0 && e1ap.transport == 1
${FieldName}             e1ap.transport
${TOPOLOGY}             CLOUD_5G_I_MP_AP_LO


*** Test Cases ***
[1][1.0] CB008233_A_08_Dynamic_GTP-U_path_supervision_for_S1-U_ interface_during_bulk_release_triggered_by_X2C_link_reset
    [Documentation]    Dynamic GTP-U Path supervision for S1-U interface during X2C Link reset
    [Tags]    QC_60603   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare For CB008233
    Log To Console              \nAttaching UE
    NSA UE Attach To Gnb        ${NSA_UE_ID1}       1       1
    NSA UE Attach To Gnb        ${NSA_UE_ID2}       1       2
    NSA UE Attach To Gnb        ${NSA_UE_ID3}       1       1
    NSA UE Attach To Gnb        ${NSA_UE_ID4}       1       2
    Log To Console              \nStarting traffic
    Traffic Should Be Successful For NSA                ${NSA_UE_ID1}     ${DL_RATE}        ${UL_RATE}
    Traffic Should Be Successful For NSA                ${NSA_UE_ID2}     ${DL_RATE}        ${UL_RATE}
    Traffic Should Be Successful For NSA                ${NSA_UE_ID3}     ${DL_RATE}        ${UL_RATE}
    Traffic Should Be Successful For NSA                ${NSA_UE_ID4}     ${DL_RATE}        ${UL_RATE}
    Log To Console    \nWaiting for 5 min for the expected PM counter
    Sleep   280s
    Wait Until Keyword Succeeds                         ${TIMEOUT}        ${RETRY_TIME}
    ...         Verifying The PM Counter For 8233A      5                  300
    X2 Link Reset
    Log To Console    \nWaiting for 5 min for the expected PM counter post x2 link reset
    Sleep    300s
    Wait Until Keyword Succeeds                         ${TIMEOUT}        ${RETRY_TIME}
    ...         Verifying The PM Counter For 8233A      0                  300
    Log To Console              \ndetaching UE
    UE Detach Should Be Successful For NSA              ${NSA_UE_ID1}
    UE Detach Should Be Successful For NSA              ${NSA_UE_ID2}
    UE Detach Should Be Successful For NSA              ${NSA_UE_ID3}
    UE Detach Should Be Successful For NSA              ${NSA_UE_ID4}
    [Teardown]    Run Keyword And Ignore Error          Common Tear Down For CB008233 MPLOTDD

[1][1.0] CB008233_A_22_Dynamic_GTP-U_path_supervision_stops_for_S1-U_path_incase_same_ Ipaddr_ changed_online_in_gNB_side
    [Documentation]    Dynamic Gtp-U Path Supervision Stop For S1-U Path Incase Same Ipaddr Changed Online In Gnb Side
    [Tags]    QC_60629   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare For CB008233
    Log To Console              \nAttaching UE
    NSA UE Attach To Gnb        ${NSA_UE_ID1}       1       1
    NSA UE Attach To Gnb        ${NSA_UE_ID2}       1       2
    NSA UE Attach To Gnb        ${NSA_UE_ID3}       1       1
    NSA UE Attach To Gnb        ${NSA_UE_ID4}       1       2
    Log To Console              \nStarting traffic
    Traffic Should Be Successful For NSA                ${NSA_UE_ID1}     ${DL_RATE}        ${UL_RATE}
    Traffic Should Be Successful For NSA                ${NSA_UE_ID2}     ${DL_RATE}        ${UL_RATE}
    Traffic Should Be Successful For NSA                ${NSA_UE_ID3}     ${DL_RATE}        ${UL_RATE}
    Traffic Should Be Successful For NSA                ${NSA_UE_ID4}     ${DL_RATE}        ${UL_RATE}
    Log To Console    \nWaiting for 5 min for the expected PM counter
    Updating Localipaddress
    Sleep   300s
    Wait Until Keyword Succeeds                         ${TIMEOUT}        ${RETRY_TIME}
    ...         Verifying The PM Counter For 8233A      3                  300
    Log To Console              \ndetaching UE
    UE Detach Should Be Successful For NSA              ${NSA_UE_ID1}
    UE Detach Should Be Successful For NSA              ${NSA_UE_ID2}
    UE Detach Should Be Successful For NSA              ${NSA_UE_ID3}
    UE Detach Should Be Successful For NSA              ${NSA_UE_ID4}
    [Teardown]    Run Keyword And Ignore Error          Common Tear Down For CB008233 MPLOTDD

[1][1.0] CB008233_B_12_Verify_GTP_U_path_failure_recovery_for_X2U_interface
    [Documentation]    The purpose of this test case is to verify gNB GTP-U path failure recovery for
    ...                S1U and X2U interfaces before the expiry of pathRecoveryWaitTimer.
    [Setup]    Prepare For CB008233
    Log To Console              \nAttaching UE
    NSA UE Attach To Gnb        ${NSA_UE_ID1}       1       1
    NSA UE Attach To Gnb        ${NSA_UE_ID2}       1       2
    NSA UE Attach To Gnb        ${NSA_UE_ID3}       1       1
    NSA UE Attach To Gnb        ${NSA_UE_ID4}       1       2
    Log To Console              \nStarting traffic
    Traffic Should Be Successful For NSA                ${NSA_UE_ID1}     ${DL_RATE}        ${UL_RATE}
    Traffic Should Be Successful For NSA                ${NSA_UE_ID2}     ${DL_RATE}        ${UL_RATE}
    Traffic Should Be Successful For NSA                ${NSA_UE_ID3}     ${DL_RATE}        ${UL_RATE}
    Traffic Should Be Successful For NSA                ${NSA_UE_ID4}     ${DL_RATE}        ${UL_RATE}
    Log To Console    \nWaiting for 10 min for the expected PM counter
    Sleep    600s
    Wait Until Keyword Succeeds        ${TIMEOUT}        ${RETRY_TIME}
    ...           Verifying The PM Counter For 8233A      5                 300
    Start pcap collection in gNB CU       gnbTcpdump2        -i any -s0
    ${ALARMS}    Skip Echo Message From SGW Trigger
    ${ALARM}     Get Alarm By Details              ${FAULT_ID}            NR GTP-U Path Failure
    ...          NR GTP-U Path Failure             ${ALARMS}
    ${ALARMS}    Break X2 GTP-U Path CB008233
    ${ALARM}     Get Alarm By Details              ${FAULT_ID}            NR GTP-U Path Failure
    ...              NR GTP-U Path Failure         ${ALARMS}
    ${pcap_path}    Stop Pcap Collection In GNB CU      gnbTcpdump2      ${Log_Path}
    Check ENDCPartialResetConfirm Message From Pcap     ${pcap_path}
    Log To Console      waiting for PM Counter after pcap collection for 10 min
    Sleep    600s
    Wait Until Keyword Succeeds        ${TIMEOUT}        ${RETRY_TIME}
    ...         Verifying The PM Counter For 8233A      0                 300
    Log To Console              \ndetaching UE
    UE Detach Should Be Successful For NSA              ${NSA_UE_ID1}
    UE Detach Should Be Successful For NSA              ${NSA_UE_ID2}
    UE Detach Should Be Successful For NSA              ${NSA_UE_ID3}
    UE Detach Should Be Successful For NSA              ${NSA_UE_ID4}
    [Teardown]    Run Keyword And Ignore Error          Common Tear Down For CB008233 MPLOTDD

[1][1.0] CB008233_C_07_Verify_the_Dynamic_path_supervision_for_NG-U_interface_during_Multiple_UEs
    [Documentation]    Verify The Dynamic Path Supervision For Ng-U Interface During Multiple Ues
    [Tags]    QC_60612   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare For CB008233
    UE Register Should Be Successful For SA                ${SA_UE_ID1}     upf=1
    UE Register Should Be Successful For SA                ${SA_UE_ID2}     upf=2
    UE Register Should Be Successful For SA                ${SA_UE_ID3}     upf=1
    UE Register Should Be Successful For SA                ${SA_UE_ID4}     upf=2
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RATE}       traffic_ul_rate=${UL_RATE}        UE_ID=${SA_UE_ID1}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RATE}       traffic_ul_rate=${UL_RATE}        UE_ID=${SA_UE_ID2}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RATE}       traffic_ul_rate=${UL_RATE}        UE_ID=${SA_UE_ID1}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RATE}       traffic_ul_rate=${UL_RATE}        UE_ID=${SA_UE_ID1}
    Sleep    300s
    Wait Until Keyword Succeeds                            ${TIMEOUT}       ${RETRY_TIME}
    ...           Verifying The PM Counter For 8233A       4                 300
    UE Deregister Should Be Successful For SA              ${SA_UE_ID1}
    UE Deregister Should Be Successful For SA              ${SA_UE_ID2}
    UE Deregister Should Be Successful For SA              ${SA_UE_ID3}
    UE Deregister Should Be Successful For SA              ${SA_UE_ID4}
    [Teardown]    Run Keyword And Ignore Error             Common Tear Down For CB008233 MPLOTDD
