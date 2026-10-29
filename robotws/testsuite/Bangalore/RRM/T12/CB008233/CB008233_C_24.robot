*** Settings ***
Documentation       :copyright:     Nokia
...                 :author   :     Vikash Kumar
...                 :contact  :     vikash.20.kumar@nokia.com
...                 :Feature  :     The purpose of this TC is to describe gNB initiates the GTP-U path supervision
...                                 for a NG-U path. gNB starts the GTP-U path supervision for an NG-U path
...                                 when the first tunnel is established over this path.
...                                 This user scenario covers the procedures of multiple initial context setup
...                                 with multiple PDU sessions setup/release

Resource          resources/Keywords/CB008233_keywords.robot
Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${SA_UE_ID1}            1
${SA_UE_ID2}            2
${SA_UE_ID3}            3
${SA_UE_ID4}            4
${DL_RATE}              20
${UL_RATE}              20
${TIMEOUT}              6 min
${RETRY_TIME}           30s
${ALARM_ID}             7107
${FAULT_ID}             7706
${Filter}               e1ap.procedureCode == 0 && e1ap.transport == 1
${FieldName}            e1ap.transport
${TOPOLOGY}             CLOUD_5G_I_LOO_AP_LOOO

*** Test Cases ***
[1][1.0] CB008233_C_24_Verify_GTP-U_path_failure_recovery_for_NG-U_interface
    [Documentation]    Verify Gtp-U Path Failure Recovery For Ng-U Interface
#    [Tags]    QC_60615   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare For CB008233 TMO
    UE Register Should Be Successful For SA                ${SA_UE_ID1}     upf=1
    UE Register Should Be Successful For SA                ${SA_UE_ID2}     upf=2
    UE Register Should Be Successful For SA                ${SA_UE_ID3}     upf=1
    UE Register Should Be Successful For SA                ${SA_UE_ID4}     upf=2
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RATE}       traffic_ul_rate=${UL_RATE}        UE_ID=${SA_UE_ID1}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RATE}       traffic_ul_rate=${UL_RATE}        UE_ID=${SA_UE_ID2}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RATE}       traffic_ul_rate=${UL_RATE}        UE_ID=${SA_UE_ID1}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RATE}       traffic_ul_rate=${UL_RATE}        UE_ID=${SA_UE_ID1}
    Start Pcap Collection In GNB CU        gnbTcpdump        -i any -s0
    Sleep    10s
    ${ALARMS}         Skip Echo Message From Gnb To Sgw
    ${ALARM}          Get Alarm By Details                    ${FAULT_ID}            NR GTP-U Path Failure
     ...              NR GTP-U Path Failure                   ${ALARMS}
    ${pcap_file}      Stop Pcap Collection In GNB CU          gnbTcpdump
    Get Transport Id From Pcap     ${pcap_file}      ${Filter}         ${FieldName}
    Wait Until Keyword Succeeds                           ${TIMEOUT}        ${RETRY_TIME}
    ...           Verifying The PM Counter For 8233A      1                 300
    UE Deregister Should Be Successful For SA             ${SA_UE_ID1}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID2}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID3}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID4}
    [Teardown]     Teardown For CB008233 TMO

