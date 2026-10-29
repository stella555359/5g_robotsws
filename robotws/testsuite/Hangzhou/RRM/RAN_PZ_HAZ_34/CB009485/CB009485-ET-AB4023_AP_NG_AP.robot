*** Settings ***
Documentation
...    author: Zhu Yuhua
...    contact: yuhua.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
#Suite Setup       Common Suite Setup And Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F
Suite Setup       Common Suite Setup And Setup 2Airphone Env And Start TCE
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...            owner-yuhua.zhu   team-PZ3_7    release-SBTS24R3
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${BTS_NUMBER}     2
${SKIP_ON_AIR}    ${True}
${SYSCOM_FLAG}    ${True}
${SNAPSHOT_FLAG}    pass:True,fail:True
${AP_BIP_FLAG}    ${False}
${GNB_BIP_FLAG}    ${False}
${EMIL_FLAG}    ${False}
# don't change the following setting
${AUTO_ANALYSIS_FLAG}    ${False}
${TTITRACE_FLAG}    ${False}
${SOS_REPORT_FLAG}    pass:False,fail:False
${SOS_REPORT_STARTUP_1_FLAG}    pass:False,fail:False
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

${TCE_IP}   10.0.1.1
${TCE_PORT_GNB1}  49100
${TCE_PORT_GNB2}  49151

@{HOShortMACegate}
...    Received Handover Required from GNB-3
...    Received Handover Request Acknowledge
...    rrcReconfiguration
...    Hit on error cases presence=any action=drop

@{RREShortMACegate}
...    rrcReestablishmentRequest
...    reestablishmentCause otherFailure
...    rrcSetup
...    rrcSetupComplete
...    UE CONTEXT RELEASE REQUEST: gNB=3

${DUBearerRecord}     nsetapx.DuVendorExtensionRecordDataType == 13
@{BearerRecord_Fields}
...    bearerRecord/data-r2/trigger=ctxSetup,ctxSetup
...    bearerRecord/data-r2/setupBearers=1 item,1 item
...    bearerRecord/data-r2/setupBearers/DuBearerDataSetupItem/drb-Id=4,4
...    bearerRecord/drbLevelQos/nonDynamicFiveQiDescriptor/fiveQi=6,6
...    bearerRecord/drbLevelQos/arp/priorityLevel=15,15
...    bearerRecord/drbLevelQos/arp/preemptionCapability=shallNotTriggerPreemption,shallNotTriggerPreemption
...    bearerRecord/drbLevelQos/arp/preemptionVulnerability=preemptable,preemptable
...    bearerRecord/drbLevelQos/pduSessionId=1,1
...    bearerRecord/snssai/sst=01,01
...    bearerRecord/snssai/sd=d143a5,d143a5
...    bearerRecord/qosFlowsMappedToBearer=1 item,1 item
...    bearerRecord/DuQosFlowMappedToBearerItem/qfi=1,1
...    bearerRecord/DuQosFlowMappedToBearerItem/fiveQi=6,6
...    bearerRecord/DuQosFlowMappedToBearerItem/arp/priorityLevel=15,15
...    bearerRecord/DuQosFlowMappedToBearerItem/arp/preemptionCapability=shallNotTriggerPreemption,shallNotTriggerPreemption
...    bearerRecord/DuQosFlowMappedToBearerItem/arp/preemptionVulnerability=preemptable,preemptable
...    bearerRecord/DuQosFlowMappedToBearerItem/pduSessionId=1,1

${UE_CAPA_1}    SEPARATOR=
...    E1A01000074E5A031E000381A00F04983200021E0A018806804C020301C022A36146B04050D012CB2898183D6C10101070EF1C39061C00103278FA
...    B80027800E0009E00151B11B582028680965944C0C1EB608080838778E1C830E0008193C7D53FF4FFCA8D89BAC10143404B2CA26060F5B0404041C
...    3BC70E418700040C9E3EAE0009E003800278000610713400000041C2800000010711800000802809B00A20230380780C04402301000FF5555504C0
...    0E000A070500703007803800341F004000000000000000100795358194010400002596540000010074AAA881D0500E001600010008010020010040
...    086AC4C0004080C1014181C202C4044484C648494989CA12986B40

*** Test Cases ***
CB009485-AB0423_Monitoring of PCMD DU Bearer Trace Record in case of RRE request with invalid shortMAC-I during Inter-gNB Handover via NG
    [Documentation]
    ...    1. Test Case Steps:
    ...        1.UE1 attach to gnb-3 CELL-3 and start traffic
    ...        2.perform inter gnb HO to gnb-1 cell-1.
    ...        3.During HO, RRE is triggered but with invalid shortMAC-I.
    ...    2. Expected Results:
    ...        1.UE1 attached successfully and traffic is statable.
    ...        2.HO performed successfully.
    ...        3.RRE Fallback due to invalid shortMAC-I.
    [Tags]   A005    QC_XXXX
#    clear counter files
    start to capture wireshark log    tag=UE1_HO_withRRE
    Add UE History Information List
    SA UE attach With Traffic    ue_id=1    cell=3    enb_id=3
    Trigger UE Inter-Frequency Inter-gNB HO SA RRE    ue_id=1    targetpci=50
    ...    sourcefreq=655008    targetfreq=663360
    RRC Reestablishment Request
    Sleep    10s
#    Check Counters    ${HO_Counter}

*** Keywords ***
Common Suite Setup And Setup 2Airphone Env And Start TCE
    Common Suite Setup And Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F
    Start TCE    ${TCE_PORT_GNB1}
    Start TCE    ${TCE_PORT_GNB2}

Add UE History Information List
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=96
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x02 gnb_id=4 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=99
    Execute Egate Command    ue_history_information_list id=1 action=commit


SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${enb_id}=2    ${pdu_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${enb_id}
	Execute Egate Command    ue_nr_rrc_setup_param id=1 establishment_cause=mo-VoiceCall
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=1    Initial Context Setup Successful

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${expectedTput_dl}=240    ${expectedTput_ul}=1
    Send Traffic    ue_id=${ue_id}
    Verify Throuput    ue_id=${ue_id}    expectedTput_dl=${expectedTput_dl}    expectedTput_ul=${expectedTput_ul}

Send Traffic
    [Arguments]    ${ue_id}=1
    Run Keyword And Ignore Error    Execute Egate Command
    ...    data_trf_start ue=${ue_id} pdu=1 dir=ul mbps=10 trf_id=1    pass_regexp=Started Uplink Internal traffic
    Run Keyword And Ignore Error    Execute Egate Command
    ...    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=150 trf_id=2    pass_regexp=UE${ue_id}: Started Downlink Internal traffic

Verify Throuput
    [Arguments]    ${ue_id}=1    ${sleep_time}=10s    ${expectedTput_dl}=240    ${expectedTput_ul}=8
    sleep    ${sleep_time}    #wait trf stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${expectedTput_dl}
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${expectedTput_ul}

SA UE attach With Traffic
    [Arguments]    ${ue_id}=2    ${cell}=1    ${expectedTput_dl}=1    ${expectedTput_ul}=1    ${enb_id}=2
    BuiltIn.Log    UE${ue_id} start to register with traffic...    console=${True}
    SA UE attach    ue_id=${ue_id}    cell_id=${cell}    enb_id=${enb_id}
    Send And Verify Throuput    ue_id=${ue_id}    expectedTput_dl=${expectedTput_dl}    expectedTput_ul=${expectedTput_ul}

Ignore RRC Reconfig and Trigger RRCReestablishmentRequest
    [Arguments]    ${ue}=1  ${cause}=handoverFailure
    Execute Egate Command
    ...        ue_nr_rrc_reconf_param id=${ue} if_contains=any action=reestablish gnb=2 cell=1 crnti=source cause=${cause} nth=1
    ...    num_reestablishment_reqs=1
    Execute Egate Command   ue_nr_rrc_reconf_param id=${ue}

Ignore RRC Reconf
    Execute Egate Command    ue_nr_rrc_reconf_param id=1 if_contains=any action=drop
    Execute Egate Command    ue_nr_rrc_reconf_param id=1

RRC Reestablishment Request
    Execute Egate Command    ue_rrc_reestablish id=1 gnb=2 cell=1 action=invalid_short_mac_i
    ...                                    pass_regexp=${RREShortMACegate}
	download and check wireshark fields    tag=UE1_HO_withRRE
    ...                                    filter=${DUBearerRecord}
    ...                                    check_fields=${BearerRecord_Fields}

download and check wireshark fields
    [Arguments]    ${tag}    ${filter}    ${check_fields}
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${filter}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${filter}
    ...                       check_fields=${check_fields}
    ...                       packet_num=all

Trigger UE Inter-Frequency Inter-gNB HO SA RRE
    [Arguments]    ${ue_id}=2    ${targetpci}=52    ${sourcefreq}=633408    ${targetfreq}=636576
    ${measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${sourcefreq}    event_type=A2
	Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=(rrcReconfigurationComplete|eventId eventA5)
    Ignore RRC Reconf
    ${a5mea}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${targetfreq}    event_type=A5
    ${hocommand}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a5mea} event=A5 srsrp_nr=11
    ...    srsrq_nr=11 phycell_id=${targetpci} nrsrp_nr=80 nrsrq_nr=60
    Execute Egate Command    ${hocommand}
    ...    pass_regexp=${HOShortMACegate}
#    Check UE Location    ue_id=${ue_id}    enb=2    cell=${targetcell}

Check UE Location
    [Arguments]    ${ue_id}=1    ${enb}=2    ${cell}=1
    Check Specific Ue State    ${ue_id}    ACTIVE
    ${real_enb_id}    ${real_cell_id}    Get UE Location    ${ue_id}
    Should Be Equal    ${real_enb_id}    ${enb}
    Should Be Equal    ${real_cell_id}    ${cell}



