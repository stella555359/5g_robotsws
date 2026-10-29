*** Settings ***

Documentation    :copyright: Nokia

Resource    ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library    ta5g_testline_management
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_delta
Library    ta5g_pm_counters
Library    ta5g_throughput
Library    CplaneOverloadSetter.py
Library    taf.ccs.aashell    WITH NAME    cli

*** Variables ***
${NRCELL1_SIB1_AFTER_OVERLOAD_ON} =   ${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.nRPCI == 50 && nr-rrc.UAC_BarringInfoSet_element &&
...                                   nr-rrc.uac_BarringFactor == 0 && nr-rrc.uac_BarringTime == 1
${NRCELL2_SIB1_AFTER_OVERLOAD_ON} =   ${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.nRPCI == 51 && nr-rrc.UAC_BarringInfoSet_element &&
...                                   nr-rrc.uac_BarringFactor == 2 && nr-rrc.uac_BarringTime == 7
${NRCELL3_SIB1_AFTER_OVERLOAD_ON} =   ${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.nRPCI == 52 && nr-rrc.UAC_BarringInfoSet_element &&
...                                   nr-rrc.uac_BarringFactor == 7 && nr-rrc.uac_BarringTime == 2
${NRCELL4_SIB1_AFTER_OVERLOAD_ON} =   ${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.nRPCI == 53 && nr-rrc.UAC_BarringInfoSet_element &&
...                                   nr-rrc.uac_BarringFactor && nr-rrc.uac_BarringTime
${NRCELL1_SIB1_AFTER_OVERLOAD_OFF_TH3} =    ${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.nRPCI == 50 && nr-rrc.UAC_BarringInfoSet_element &&
...                                         nr-rrc.uac_BarringFactor == 5 && nr-rrc.uac_BarringTime == 1
${NRCELL1_SIB1_AFTER_OVERLOAD_OFF_TH2} =    ${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.nRPCI == 50 && nr-rrc.UAC_BarringInfoSet_element &&
...                                         nr-rrc.uac_BarringFactor == 10 && nr-rrc.uac_BarringTime == 0
${NRCELL1_SIB1_AFTER_OVERLOAD_OFF_MIN} =    ${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.nRPCI == 50 && nr-rrc.UAC_BarringInfoSet_element &&
...                                         nr-rrc.uac_BarringFactor == 15 && nr-rrc.uac_BarringTime == 0
${NRCELL1_SIB1_AFTER_OVERLOAD_OFF} =        ${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.nRPCI == 50 && nr-rrc.UAC_BarringInfoSet_element &&
...                                         nr-rrc.uac_BarringFactor == 2 && nr-rrc.uac_BarringTime == 3
${NRCELL2_SIB1_AFTER_OVERLOAD_OFF_TH3} =    ${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.nRPCI == 51 && nr-rrc.UAC_BarringInfoSet_element &&
...                                         nr-rrc.uac_BarringFactor == 6 && nr-rrc.uac_BarringTime == 6
${NRCELL2_SIB1_AFTER_OVERLOAD_OFF_TH2} =    ${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.nRPCI == 51 && nr-rrc.UAC_BarringInfoSet_element &&
...                                         nr-rrc.uac_BarringFactor == 9 && nr-rrc.uac_BarringTime == 6
${NRCELL2_SIB1_AFTER_OVERLOAD_OFF_MIN} =    ${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.nRPCI == 51 && nr-rrc.UAC_BarringInfoSet_element &&
...                                         nr-rrc.uac_BarringFactor == 13 && nr-rrc.uac_BarringTime == 5
${NRCELL2_SIB1_AFTER_OVERLOAD_OFF} =        ${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.nRPCI == 51 && nr-rrc.UAC_BarringInfoSet_element &&
...                                         nr-rrc.uac_BarringFactor == 2 && nr-rrc.uac_BarringTime == 7
${NRCELL3_SIB1_AFTER_OVERLOAD_OFF_TH3_TH2_MIN} =    ${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.nRPCI == 52 && nr-rrc.UAC_BarringInfoSet_element &&
...                                         nr-rrc.uac_BarringFactor == 7 && nr-rrc.uac_BarringTime == 2
${NRCELL3_SIB1_AFTER_OVERLOAD_OFF} =        ${F1AP_GNB_CONFIGURATION_UPDATE} && f1ap.nRPCI == 51 && nr-rrc.UAC_BarringInfoSet_element &&
...                                         nr-rrc.uac_BarringFactor == 2 && nr-rrc.uac_BarringTime == 7

&{RAD_HEXs}                     rdOverloadHighThreshold=0x89006f
...                             rdOverloadIndicationThreshold=0x590226
...                             rdDelayRrcOvlCountermeasures=0x890070
...                             rdKeepOverloadDuration=0x590221
...                             rdOverloadIndicationDurationThreshold=0x590227
...                             rdOverloadRejectionLowerMessageQueuingTime=0x5901FA
...                             rdOverloadRejectionUpperMessageQueuingTime=0x5901FB
...                             rdOverloadTriggeringMessageNumber=0x5901FC

*** Keywords ***
Perform CPLANE OVL Activation Via R&D Mechanism
    Set Overload High Threshold to 0
    Sleep    10    reason=Waiting For Overload On

Perform CPLANE OVL Dectivation Via R&D Mechanism
    Set Overload High Threshold to 40
    Sleep    10    reason=Waiting For Overload Off

Wait For StartUacBarringTimerOverload From All Cells And Verify SIB1 Changes Due Overload Condition
    Sleep    310s    reason=Waiting For StartUacBarringTimerOverload
    Verify Tcpdump Log    packet_filter=${NRCELL1_SIB1_AFTER_OVERLOAD_ON}
    Verify Tcpdump Log    packet_filter=${NRCELL2_SIB1_AFTER_OVERLOAD_ON}
    Verify Tcpdump Log    packet_filter=${NRCELL3_SIB1_AFTER_OVERLOAD_ON}
    Verify Tcpdump Log    packet_filter=${NRCELL4_SIB1_AFTER_OVERLOAD_ON}    number_of_messages=0

Wait For StartUacBarringTimerOverload From All Cells And Verify SIB1 Changes Due Overload Condition Off
    Sleep    15m    reason=Waiting For StartUacBarringTimerOverload
    Verify Cell1 Overload Off
    Verify Cell2 Overload Off
    Verify Cell3 Overload Off

Verify Alarm EFaultId_AutomaticUnifiedAccessControlBarringAl On Cells
    Wait For Alarm To Be Up    alarm_id=7115    timeout=120
    Wait For Fault To Be Up    fault_id=7533

Verify No Alarm EFaultId_AutomaticUnifiedAccessControlBarringAl On Cells
    Wait For Alarm To Be Down    alarm_id=7115    timeout=120
    Wait For Fault To Be Down    fault_id=7533

Verify Cell1 Overload Off
    Verify Tcpdump Log    packet_filter=${NRCELL1_SIB1_AFTER_OVERLOAD_OFF_TH3}
    Verify Tcpdump Log    packet_filter=${NRCELL1_SIB1_AFTER_OVERLOAD_OFF_TH2}
    Verify Tcpdump Log    packet_filter=${NRCELL1_SIB1_AFTER_OVERLOAD_OFF_MIN}
    Verify Tcpdump Log    packet_filter=${NRCELL1_SIB1_AFTER_OVERLOAD_OFF}

Verify Cell2 Overload Off
    Verify Tcpdump Log    packet_filter=${NRCELL2_SIB1_AFTER_OVERLOAD_OFF_TH3}
    Verify Tcpdump Log    packet_filter=${NRCELL2_SIB1_AFTER_OVERLOAD_OFF_TH2}
    Verify Tcpdump Log    packet_filter=${NRCELL2_SIB1_AFTER_OVERLOAD_OFF_MIN}
    Verify Tcpdump Log    packet_filter=${NRCELL2_SIB1_AFTER_OVERLOAD_OFF}

Verify Cell3 Overload Off
    Verify Tcpdump Log    packet_filter=${NRCELL3_SIB1_AFTER_OVERLOAD_OFF_TH3_TH2_MIN}    number_of_messages=4
    Verify Tcpdump Log    packet_filter=${NRCELL3_SIB1_AFTER_OVERLOAD_OFF}

Verify Network Access Rate Reduction
    Verify Tcpdump Log    packet_filter=${F1AP_NETWORK_ACCESS_RATE_REDUCTION}    number_of_messages=1    relation_symbol= >=

Enter Overload State On GNB-DU
    Log to Console    Entering Overload State On GNB-DU
    Change RnD Flags By AaShell
    ...    ${RAD_HEXs['rdOverloadRejectionLowerMessageQueuingTime']}    1
    ...    ${RAD_HEXs['rdOverloadRejectionUpperMessageQueuingTime']}    2
    ...    ${RAD_HEXs['rdOverloadTriggeringMessageNumber']}    1
    ...    ${RAD_HEXs['rdOverloadIndicationThreshold']}    0
    ...    ${RAD_HEXs['rdKeepOverloadDuration']}    3000
    ...    ${RAD_HEXs['rdOverloadIndicationDurationThreshold']}    200

Exit Overload State On GNB-DU
    Log to Console    Exiting overload state on gNB-DU
    Change RnD Flags By AaShell
    ...    ${RAD_HEXs['rdOverloadRejectionLowerMessageQueuingTime']}    100000
    ...    ${RAD_HEXs['rdOverloadRejectionUpperMessageQueuingTime']}    125000
    ...    ${RAD_HEXs['rdOverloadTriggeringMessageNumber']}    30
    ...    ${RAD_HEXs['rdOverloadIndicationThreshold']}    100
    ...    ${RAD_HEXs['rdKeepOverloadDuration']}    3000
    ...    ${RAD_HEXs['rdOverloadIndicationDurationThreshold']}    200

Change RnD Flags By AaShell
    [Arguments]    @{args}    ${is_permanent}=no
    cli.create_aashell_cli    name=Aashell
    cli.setup    Aashell
    cli.change_rad_params    Aashell    ${args}    ${is_permanent}
    Sleep    10s    Wait for r&d param application
    [Teardown]    cli.teardown    Aashell

Verify Network Access Rate Reduction DU
    Verify Tcpdump Log    packet_filter=${F1AP_GNBDU_STATUS_INDICATION_ELEMENT}    number_of_messages=1  relation_symbol= >=
