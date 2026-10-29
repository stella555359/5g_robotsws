*** Settings ***
Documentation    Keywords for the CB006733_B_B20

Library     ta5g_ue_mobility
Library     testsuite/Wroclaw/RRM/WRO_2/resources/CplaneOverloadSetter.py
Resource    resources/CB006733_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/L3_call.robot


*** Variables ***
${ue_id_6733_b20}=    4
${cell2_a4_meas_id_6733_b20}=    1
${cell3_a4_meas_id_6733_b20}=    2
${nrsrq_nr_6733_b20}=    95
${nrsrp_nr_6733_b20}=    90
${cell2_pci_6733_b20}=    52
${cell3_pci_6733_b20}=    53
${number_of_messages_6733_b20}=    1

${Cplane_overload_state_enabled_6733_b20}=
...    nokiaf1ap.uACReductionIndication==100

${Cplane_overload_state_disabled_6733_b20}=
...    nokiaf1ap.uACReductionIndication==0

${BufferMonitoringVerification_6733_b20}=
...    nokiaf1ap.BufferMonitoringNotification_element &&
...    nokiaf1ap.BufferMonitoring==0

${BufferCriterionVerification_6733_b20}=
...    nokiaf1ap.BufferCriterionNotification_element &&
...    nokiaf1ap.NokiaBufferCriterion==0

${UeContextModReqAfterA4_6733_b20}=
...    nokiaf1ap.SCell_ToBeSetupMod_List==1 &&
...    nokiaf1ap.nRCellIdentity==00:00:04:00:30

${RRCReconfigurationWithA2_6733_b20}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measObjectToAddModList==1 &&
...    nr-rrc.freqBandIndicatorNR==71 &&
...    nr-rrc.eventId==1 &&
...    nr-rrc.measIdToAddModList==1


*** Keywords ***
TC__CB006733-B_B20_Interaction_with_gNB_overload_5GC000281
    Register UE To gNB    ue_id=${ue_id_6733_b20}
    Enable Overload State
    Trigger A4 RSRQ Measurement    ue_id=${ue_id_6733_b20}    pci=${cell2_pci_6733_b20}    meas_id=${cell2_a4_meas_id_6733_b20}
    ...    nrsrq_nr=${nrsrq_nr_6733_b20}
    Start DL Data Traffic
    Disable Overload State
    Trigger A4 RSRP Measurement    ue_id=${ue_id_6733_b20}    pci=${cell3_pci_6733_b20}    meas_id=${cell3_a4_meas_id_6733_b20}
    ...    nrsrp_nr=${nrsrp_nr_6733_b20}
    Verify CPlane Overload State Enabled    ${Cplane_overload_state_enabled_6733_b20}
    Verify Buffer Monitoring Notification    ${BufferMonitoringVerification_6733_b20}    ${number_of_messages_6733_b20}
    Verify Buffer Criterion Notification    ${BufferCriterionVerification_6733_b20}
    Verify CPlane Overload State Disabled    ${Cplane_overload_state_disabled_6733_b20}
    Verify 1 SCells Addition After A4 Event Trigger    ${UeContextModReqAfterA4_6733_b20}
    Verify RRC SCell Addition    ${RRCReconfigurationWithA2_6733_b20}

    [Teardown]    Deregister Ue    ue_id=${ue_id_6733_b20}

Enable Overload State
    [Arguments]   ${ovl threshold}=0
    Log to console  Perform CPLANE OVL via R&D mechanism to value: ${ovl threshold}
    CplaneOverloadSetter.Set Overload High Threshold to ${ovl threshold} for ABIO 1
    CplaneOverloadSetter.Set Overload High Threshold to ${ovl threshold} for ABIO 2
    Sleep  10

Disable Overload State
    [Arguments]   ${ovl threshold}=200
    Log to console  Perform CPLANE OVL via R&D mechanism to value: ${ovl threshold}
    CplaneOverloadSetter.Set Overload High Threshold to ${ovl threshold} for ABIO 1
    CplaneOverloadSetter.Set Overload High Threshold to ${ovl threshold} for ABIO 2
    Sleep  10

Verify CPlane Overload State Enabled
    [Arguments]    ${Cplane_overload_state}
    Verify Tcpdump Log    packet_filter=${Cplane_overload_state}    number_of_messages=0  relation_symbol= >

Verify CPlane Overload State Disabled
    [Arguments]    ${Cplane_overload_state}
    Verify Tcpdump Log    packet_filter=${Cplane_overload_state}    number_of_messages=0  relation_symbol= >
