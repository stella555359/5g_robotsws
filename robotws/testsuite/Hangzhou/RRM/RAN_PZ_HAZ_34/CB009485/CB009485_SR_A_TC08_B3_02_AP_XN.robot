*** Settings ***
Documentation
...    author: Yan Susana
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
#Suite Setup       Common Suite Setup And Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F
Suite Setup       Common Suite Setup And Setup 2Airphone Env And Start TCE
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R3    tl-CLOUD_5G_I_[LO][LO]_AP_[LOO]
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SKIP_ON_AIR}    ${True}

@{PARAMS_IN_SWCONFIG}
...    0x1002A=1    #ERadCcs_AaTraceSwConfUsed
...    0x5A0609=1    #L2-HI rdDebugPcmdNrt
...    0x5A0610=1    #L2-HI rdDebugPcmdRt
...    0x5B0609=1    #L2-HI rdDebugPcmdNrt
...    0x5B0610=1    #L2-HI rdDebugPcmdRt
...    0x57000E=1    #enable L2-LO NRT PCMD debug logs
...    0x58057a=4    #L2-PS rdFeatureFlagBitmapLevel 4DEBUG
...    0x58057b=8    #L2-PSrdFeatureFlagBitmap0 8PF_METRIC
...    0x580582=3    #L2-PSrdFeatureFlagBitmap7 3RAT1_ALLOC
...    0x58057f=0x10000000     #L2-PSrdFeatureFlagBitmap4
@{PARAMS_IN_SWCONFIG_GNB2}
...    0x1002A=1    #ERadCcs_AaTraceSwConfUsed
...    0x5A0609=1    #L2-HI rdDebugPcmdNrt
...    0x5A0610=1    #L2-HI rdDebugPcmdRt
...    0x5B0609=1    #L2-HI rdDebugPcmdNrt
...    0x5B0610=1    #L2-HI rdDebugPcmdRt
...    0x57000E=1    #enable L2-LO NRT PCMD debug logs
...    0x58057a=4    #L2-PS rdFeatureFlagBitmapLevel 4DEBUG
...    0x58057b=8    #L2-PSrdFeatureFlagBitmap0 8PF_METRIC
...    0x580582=3    #L2-PSrdFeatureFlagBitmap7 3RAT1_ALLOC
...    0x58057f=0x10000000     #L2-PSrdFeatureFlagBitmap4

${TCE_PORT_GNB1}  49100
${TCE_PORT_GNB2}  49151

${DUBearerRecord}     nsetapx.DuVendorExtensionRecordDataType == 13
${StopRecordingSession}    nsetapx.TraceMessage == 5
@{BearerRecord_Feilds}
...    bearerRecord/data-r2/trigger=ctxSetup
...    bearerRecord/data-r2/setupBearers=1 item
...    bearerRecord/data-r2/setupBearers/DuBearerDataSetupItem/drb-Id=4
...    bearerRecord/drbLevelQos/nonDynamicFiveQiDescriptor/fiveQi=6
...    bearerRecord/drbLevelQos/arp/priorityLevel=15
...    bearerRecord/drbLevelQos/arp/preemptionCapability=shallNotTriggerPreemption
...    bearerRecord/drbLevelQos/arp/preemptionVulnerability=preemptable
...    bearerRecord/drbLevelQos/pduSessionId=1
...    bearerRecord/snssai/sst=01
...    bearerRecord/snssai/sd=d143a5
...    bearerRecord/qosFlowsMappedToBearer=1 item
...    bearerRecord/DuQosFlowMappedToBearerItem/qfi=1
...    bearerRecord/DuQosFlowMappedToBearerItem/fiveQi=6
...    bearerRecord/DuQosFlowMappedToBearerItem/arp/priorityLevel=15
...    bearerRecord/DuQosFlowMappedToBearerItem/arp/preemptionCapability=shallNotTriggerPreemption
...    bearerRecord/DuQosFlowMappedToBearerItem/arp/preemptionVulnerability=preemptable
...    bearerRecord/DuQosFlowMappedToBearerItem/pduSessionId=1

*** Test Cases ***
CB009485_SR_A_TC08_B3_02_Verify gNB-DU reports Bearer Trace Record during successful Xn based A5 IntergNB HO for multi SA call
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...           USCB009485-A#B21-ALT1: Monitoring PCMD content related to CB009485 for DU Bearer Trace Record during Bearer Setup
    ...           after successful Inter-gNB HO (NG based)
    ...    2. Configuration:
    ...       cell id=1 gnb=2 pci=50 band:n77 TDD chBw=40MHz
    ...       cell id=2 gnb=2 pci=51 band:n77 TDD chBw=100MHz
    ...       cell id=3 gnb=3 pci=52 band:n77 TDD chBw=100MHz
    ...       cell id=11 gnb=3 pci=60 band:n3 FDD chBw=10MHz
    ...    3. Test Case Steps:
    ...        1. SA UE1 attach to GNB3 CELL3 and start traffic
    ...        2. SA UE2 attach to GNB3 CELL3 and start traffic
    ...        3. SA UE1 trigger XN based A5 Handover From GNB3 to GNB2 CELL1
    ...        4. SA UE2 trigger XN based A5 Handover From GNB3 to GNB2 CELL1
    ...        5. SA UE1 trigger XN based A5 Handover From GNB2 to GNB3 CELL11
    ...        6. SA UE1 trigger XN based A5 Handover From GNB3 to GNB2 CELL1
    ...        7. SA UE1 trigger XN based A5 Handover From GNB2 to GNB3 CELL3
    ...    4. Expected Results:
    ...        1-2. UE1 and UE2 attached successfully and traffic is stable.
    ...        3-7. HO performed successfully.
    ...             A new  SBA Trace Session with PCMD content is started
    ...             Target gnb reports Bearer Trace Record (5G_TC_825) with IEs corresponding to the cell from target gNB
    [Tags]    TC08
    SA UE attach With Traffic    ue_id=1    cell=3    enb_id=3
    SA UE attach With Traffic    ue_id=2    cell=3    enb_id=3
    Trigger UE Inter-Frequency Inter-gNB HO to GNB2 and check bearer record    ue_id=1    targetpci=50    sourcecell=3    targetcell=1
    ...    sourcefreq=655008    targetfreq=663168   crntiIndex=1
    Trigger UE Inter-Frequency Inter-gNB HO to GNB2 and check bearer record    ue_id=2    targetpci=50    sourcecell=3    targetcell=1
    ...    sourcefreq=655008    targetfreq=663168   crntiIndex=1
    Trigger UE Inter-Frequency Inter-gNB HO to GNB3 and check bearer record    ue_id=2    targetpci=60    sourcecell=1    targetcell=11
    ...    sourcefreq=663168    targetfreq=368430   crntiIndex=2
    Trigger UE Inter-Frequency Inter-gNB HO to GNB2 and check bearer record    ue_id=2    targetpci=50    sourcecell=11    targetcell=1
    ...    sourcefreq=368430    targetfreq=663168   crntiIndex=3
    Trigger UE Inter-Frequency Inter-gNB HO to GNB3 and check bearer record    ue_id=2    targetpci=52    sourcecell=1    targetcell=3
    ...    sourcefreq=663168    targetfreq=655008   crntiIndex=4
    Trigger UE Inter-Frequency Inter-gNB HO to GNB3 and check bearer record    ue_id=1    targetpci=52    sourcecell=1    targetcell=3
    ...    sourcefreq=663168    targetfreq=655008   crntiIndex=2

*** Keywords ***
Common Suite Setup And Setup 2Airphone Env And Start TCE
    Common Suite Setup And Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F
    Start TCE    ${TCE_PORT_GNB1}
    Start TCE    ${TCE_PORT_GNB2}

SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${enb_id}=2    ${pdu_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${enb_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=1    Initial Context Setup Successful

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${expectedTput_dl}=120    ${expectedTput_ul}=6
    Send Traffic    ue_id=${ue_id}
    Verify Throuput    ue_id=${ue_id}    expectedTput_dl=${expectedTput_dl}    expectedTput_ul=${expectedTput_ul}

Send Traffic
    [Arguments]    ${ue_id}=1
    Run Keyword And Ignore Error    Execute Egate Command
    ...    data_trf_start ue=${ue_id} pdu=1 dir=ul mbps=10 trf_id=1    pass_regexp=Started Uplink Internal traffic
    Run Keyword And Ignore Error    Execute Egate Command
    ...    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=2    pass_regexp=UE${ue_id}: Started Downlink Internal traffic

Verify Throuput
    [Arguments]    ${ue_id}=1    ${sleep_time}=10s    ${expectedTput_dl}=120    ${expectedTput_ul}=8
    sleep    ${sleep_time}    #wait trf stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${expectedTput_dl}
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${expectedTput_ul}

SA UE attach With Traffic
    [Arguments]    ${ue_id}=2    ${cell}=1    ${expectedTput_dl}=120    ${expectedTput_ul}=6    ${enb_id}=2
    ...    ${check_fields}=${BearerRecord_Feilds}    ${filter}=${DUBearerRecord}
    BuiltIn.Log    UE${ue_id} start to register with traffic...    console=${True}
    Start To Capture Wireshark Log Bts2    tag=GNB3_UE${ue_id}_attach
    SA UE attach    ue_id=${ue_id}    cell_id=${cell}    enb_id=${enb_id}
    Send And Verify Throuput    ue_id=${ue_id}    expectedTput_dl=${expectedTput_dl}    expectedTput_ul=${expectedTput_ul}
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found_bts2    tag=GNB3_UE${ue_id}_attach    filter=${filter}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${filter}
    ...                       check_fields=${check_fields}
    ...                       packet_num=all
    ${crnti}=    Get Wireshark Field Value    pcap_file=${wireshark_log_path}    field_path=DuRecord/crnti
    ...    display_filter=nsetapx.DuVendorExtensionRecordDataType == 13    packet=0
    Set Suite Variable    ${UE${ue_id}crnti_values0}    ${crnti}[0]

Trigger UE Inter-Frequency Inter-gNB HO to GNB2 and check bearer record
    [Arguments]    ${ue_id}=2    ${targetpci}=52    ${sourcecell}=1    ${targetcell}=3    ${sourcefreq}=633408    ${targetfreq}=636576
    ...    ${check_fields}=${BearerRecord_Feilds}    ${filter}=${DUBearerRecord}    ${crntiIndex}=1
    BuiltIn.Log    UE${ue_id} start to handover to cell ${targetpci}...    console=${True}
    ${tag2}    Set Variable    GNB2_UE${ue_id}_HO_FromCell${sourcecell}ToCell${targetcell}
    ${tag3}    Set Variable    GNB3_UE${ue_id}_HO_FromCell${sourcecell}ToCell${targetcell}
    start to capture wireshark log    tag=${tag2}
    Start To Capture Wireshark Log Bts2    tag=${tag3}
    ${measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${sourcefreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=(rrcReconfigurationComplete|eventId eventA5)
    ${a5mea}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${targetfreq}    event_type=A5
    ${hocommand}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a5mea} event=A5 srsrp_nr=11
    ...    srsrq_nr=11 phycell_id=${targetpci} nrsrp_nr=80 nrsrq_nr=60
    Execute Egate Command    ${hocommand}
    ...    pass_regexp=(rrcReconfigurationComplete|UE${ue_id}: Intra-eNB handover from EXT_ENB)
    stop_wireshark_log_after_filter_found_bts2    ${tag3}    filter=${StopRecordingSession}    times=2
    Check Bearer Record on GNB2    ${ue_id}    ${tag2}    ${filter}    ${check_fields}    ${crntiIndex}

Trigger UE Inter-Frequency Inter-gNB HO to GNB3 and check bearer record
    [Arguments]    ${ue_id}=2    ${targetpci}=52    ${sourcecell}=1    ${targetcell}=3    ${sourcefreq}=633408    ${targetfreq}=636576
    ...    ${check_fields}=${BearerRecord_Feilds}    ${filter}=${DUBearerRecord}    ${crntiIndex}=1
    BuiltIn.Log    UE${ue_id} start to handover to cell ${targetpci}...    console=${True}
    ${tag2}    Set Variable    GNB2_UE${ue_id}_HO_FromCell${sourcecell}ToCell${targetcell}
    ${tag3}    Set Variable    GNB3_UE${ue_id}_HO_FromCell${sourcecell}ToCell${targetcell}
    start to capture wireshark log    tag=${tag2}
    Start To Capture Wireshark Log Bts2    tag=${tag3}
    ${measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${sourcefreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=(rrcReconfigurationComplete|eventId eventA5)
    ${a5mea}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${targetfreq}    event_type=A5
    ${hocommand}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a5mea} event=A5 srsrp_nr=11
    ...    srsrq_nr=11 phycell_id=${targetpci} nrsrp_nr=80 nrsrq_nr=60
    Execute Egate Command    ${hocommand}
    ...    pass_regexp=(rrcReconfigurationComplete|UE${ue_id}: Intra-eNB handover from EXT_ENB)
    stop_wireshark_log_after_filter_found    ${tag2}    filter=${StopRecordingSession}    times=2
    Check Bearer Record on GNB3    ${ue_id}    ${tag3}    ${filter}    ${check_fields}    ${crntiIndex}

Check Bearer Record on GNB2
    [Arguments]    ${ue_id}    ${tag2}    ${filter}    ${check_fields}    ${crntiIndex}
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    tag=${tag2}    filter=${filter}
    check_wireshark_fields    pcap_file=${wireshark_log_path}    filter=${filter}    check_fields=${check_fields}    packet_num=all
    ${CRNTI1}    Get Wireshark Field Value    pcap_file=${wireshark_log_path}
    ...    field_path=DuRecord/crnti
    ...    display_filter=nsetapx.DuVendorExtensionRecordDataType == 13
    ...    packet=0
    Set Suite Variable    ${UE${ue_id}crnti_values${crntiIndex}}    ${CRNTI1}[0]
    ${previous_crntiIndex}=    evaluate    int(${crntiIndex})-1
    #crnti for DU bearer after handover is diff with before handover
    Should Not Be Equal    ${UE${ue_id}crnti_values${crntiIndex}}    ${UE${ue_id}crnti_values${previous_crntiIndex}}

Check Bearer Record on GNB3
    [Arguments]    ${ue_id}    ${tag3}    ${filter}    ${check_fields}    ${crntiIndex}
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found_bts2    tag=${tag3}    filter=${filter}
    check_wireshark_fields    pcap_file=${wireshark_log_path}    filter=${filter}    check_fields=${check_fields}    packet_num=all
    ${CRNTI1}    Get Wireshark Field Value    pcap_file=${wireshark_log_path}
    ...    field_path=DuRecord/crnti
    ...    display_filter=nsetapx.DuVendorExtensionRecordDataType == 13
    ...    packet=0
    Set Suite Variable    ${UE${ue_id}crnti_values${crntiIndex}}    ${CRNTI1}[0]
    ${previous_crntiIndex}=    evaluate    int(${crntiIndex})-1
    #crnti for DU bearer after handover is diff with before handover
    Should Not Be Equal    ${UE${ue_id}crnti_values${crntiIndex}}    ${UE${ue_id}crnti_values${previous_crntiIndex}}
