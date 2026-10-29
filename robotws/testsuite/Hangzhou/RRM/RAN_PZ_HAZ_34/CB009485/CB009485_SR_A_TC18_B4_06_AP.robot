*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup 2Airphone Env And Start TCE
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R3    tl-CLOUD_5G_I_[LO][LO]_AP_[LOO]
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
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

@{PARAMS_IN_SWCONFIG_BTS2}
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

${DU_BEARER_RECORD_F}    nsetapx.DuVendorExtensionRecordDataType == 13

*** Test Cases ***
CB009485_SR_A_TC18_B4_06 Monitoring_Of_PCMD_Records_For_RRC_Reestablishment_Fallback_To_Diff_Inter_gnb_HO_Target_Cell_Via_Xn
    [Documentation]    This case covers two test instances:
    ...    1. CB009485_SR_A_TC16_B4_04 Monitoring_Of_PCMD_Records_For_RRC_Reestablishment_Fallback_To_Same_Inter_gnb_HO_Target_Cell_Via_Xn
    ...    2. CB009485_SR_A_TC18_B4_06 Monitoring_Of_PCMD_Records_For_RRC_Reestablishment_Fallback_To_Diff_Inter_gnb_HO_Target_Cell_Via_Xn

    # CB009485_SR_A_TC16_B4_04
    start to capture wireshark log    1_attach_ue1
    log to console    step1: attach UE1 to gnb3 cell3 and setup pdu session, start and check traffic
    SA UE attach to gnb3 cell3    ue_id=1
    Send And Verify Throuput    ue_id=1
    stop capture wireshark log    1_attach_ue1

    log to console    step2: UE1 HO to gnb2 cell1, and RRE to gnb2 cell1 during HO, one bearerRecord
    start to capture wireshark log    2_ho_rre_ue1
    Trigger RRC Reestablishment on target gnb during inter-gNB handover    ue_id=1    targetpci=50    targetcell_rre=1
    ${bearerrecord}    create list    bearerRecord/data-r2/trigger=ctxSetup
    ...                               bearerRecord/data-r2/setupBearers=1 item
    ...                               bearerRecord/setupBearers/DuBearerDataSetupItem/drb-Id=4
    ...                               bearerRecord/setupBearers/DuBearerDataSetupItem/qosInformation=nr-Qos
    ...                               bearerRecord/drbLevelQos/fiveQi=6
    ...                               bearerRecord/drbLevelQos/arp/priorityLevel=15
    ...                               bearerRecord/drbLevelQos/arp/preemptionCapability=shallNotTriggerPreemption
    ...                               bearerRecord/drbLevelQos/arp/preemptionVulnerability=preemptable
    ...                               bearerRecord/drbLevelQos/pduSessionId=1
    ...                               bearerRecord/snssai/sst=01
    ...                               bearerRecord/snssai/sd=d143a5
    ...                               bearerRecord/qosFlowsMappedToBearer/qfi=[RE].*
    ...                               bearerRecord/qosFlowsMappedToBearer/qosParameters/fiveQi=6
    ...                               bearerRecord/qosFlowsMappedToBearer/qosParameters/arp/priorityLevel=15
    ...                               bearerRecord/qosFlowsMappedToBearer/preemptionCapability=shallNotTriggerPreemption
    ...                               bearerRecord/qosFlowsMappedToBearer/qosParameters/arp/preemptionVulnerability=preemptable
    ...                               bearerRecord/qosFlowsMappedToBearer/qosParameters/pduSessionId=1
    download and check wireshark fields    tag=2_ho_rre_ue1
    ...                                    filter=${DU_BEARER_RECORD_F}
    ...                                    check_fields=${bearerrecord}
    Verify Throuput    ue_id=1

    # CB009485_SR_A_TC18_B4_06
    log to console    step3: attach UE2 to gnb3 cell3 and setup pdu session, start and check traffic
    start to capture wireshark log    3_delta_attach_ue2
    delta commission parameters bts2    ${DELTA_PREPARED_CELL}
    SA UE attach to gnb3 cell3    ue_id=2
    Send And Verify Throuput    ue_id=2
    stop capture wireshark log    3_delta_attach_ue2

    log to console    step4: UE2 HO to gnb2 cell1, and RRE to gnb2 cell2 during HO, two bearerRecord
    start to capture wireshark log    4_ho_rre_ue2
    Trigger RRC Reestablishment on target gnb during inter-gNB handover    ue_id=2    targetpci=50    targetcell_rre=2
    ${bearerrecord}    create list    bearerRecord/data-r2/trigger=ctxModification,ctxSetup
    ...                               bearerRecord/data-r2/setupBearers=1 item,1 item
    ...                               bearerRecord/setupBearers/DuBearerDataSetupItem/drb-Id=4,4
    ...                               bearerRecord/setupBearers/DuBearerDataSetupItem/qosInformation=nr-Qos,nr-Qos
    ...                               bearerRecord/drbLevelQos/fiveQi=6,6
    ...                               bearerRecord/drbLevelQos/arp/priorityLevel=15,15
    ...                               bearerRecord/drbLevelQos/arp/preemptionCapability=shallNotTriggerPreemption,shallNotTriggerPreemption
    ...                               bearerRecord/drbLevelQos/arp/preemptionVulnerability=preemptable,preemptable
    ...                               bearerRecord/drbLevelQos/pduSessionId=1,1
    ...                               bearerRecord/nr-Qos/snssai/sst=01,01
    ...                               bearerRecord/nr-Qos/snssai/sd=d143a5,d143a5
    ...                               bearerRecord/qosFlowsMappedToBearer/qfi=[RE].*,[RE].*
    ...                               bearerRecord/qosFlowsMappedToBearer/qosParameters/fiveQi=6,6
    ...                               bearerRecord/qosFlowsMappedToBearer/qosParameters/arp/priorityLevel=15,15
    ...                               bearerRecord/qosFlowsMappedToBearer/preemptionCapability=shallNotTriggerPreemption,shallNotTriggerPreemption
    ...                               bearerRecord/qosFlowsMappedToBearer/qosParameters/arp/preemptionVulnerability=preemptable,preemptable
    ...                               bearerRecord/qosFlowsMappedToBearer/qosParameters/pduSessionId=1,1
    download and check wireshark fields    tag=4_ho_rre_ue2
    ...                                    filter=${DU_BEARER_RECORD_F}
    ...                                    check_fields=${bearerrecord}
    ...                                    times=2
    Verify Throuput    ue_id=2

*** Keywords ***
Common Suite Setup And Setup 2Airphone Env And Start TCE
    Common Suite Setup And Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Perform Steps After Onair
    object should exist    XNLINK-1:xnLinkStatus=available
    Start TCE    ${TCE_PORT_GNB1}
    Start TCE    ${TCE_PORT_GNB2}

SA UE attach to gnb3 cell3
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} cell=3 enb=3
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1
    ...    pass_regexp=Initial Context Setup Successful

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${traffic_dl}=50    ${traffic_ul}=10
    Send Traffic    ${ue_id}    ${traffic_dl}    ${traffic_ul}
    Verify Throuput    ue_id=${ue_id}    expectedTput_dl=${${traffic_dl}*0.8}    expectedTput_ul=${${traffic_ul}*0.8}

Send Traffic
    [Arguments]    ${ue_id}=1    ${traffic_dl}=50    ${traffic_ul}=10
    Run Keyword And Ignore Error    Execute Egate Command
    ...    data_trf_start ue=${ue_id} pdu=1 dir=ul mbps=${traffic_ul} trf_id=1    pass_regexp=Started Uplink Internal traffic
    Run Keyword And Ignore Error    Execute Egate Command
    ...    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=${traffic_dl} trf_id=2    pass_regexp=UE${ue_id}: Started Downlink Internal traffic

Verify Throuput
    [Arguments]    ${ue_id}=1    ${sleep_time}=10s    ${expectedTput_dl}=40    ${expectedTput_ul}=8
    sleep    ${sleep_time}    #wait trf stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${expectedTput_dl}
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${expectedTput_ul}

Trigger RRC Reestablishment on target gnb during inter-gNB handover
    [Arguments]    ${ue_id}=1    ${targetpci}=50    ${targetcell_rre}=1     ${sourcefreq}=655008    ${targetfreq}=663168
    # report A2 and interfreq A5 activated
    ${measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${sourcefreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=(rrcReconfigurationComplete|eventId eventA5)

    # define rre after receive rrc reconfiguration
    ${rrecommand}    catenate    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=reestablish cell=${targetcell_rre} gnb=2
    ...    crnti=source cause=handoverFailure num_reestablishment_reqs=1
    Execute Egate Command    ${rrecommand}

    # report A5 to trigger ho
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id}
    ${a5mea}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${targetfreq}    event_type=A5
    ${hocommand}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a5mea} event=A5 srsrp_nr=11
    ...    srsrq_nr=11 phycell_id=${targetpci} nrsrp_nr=80 nrsrq_nr=60
    Execute Egate Command    ${hocommand}
    ...    NR RRC Reestablishment sucessfully completed
    Execute Egate Command    ue_nr_rrc_reconf_param reset

download and check wireshark fields
    [Arguments]    ${tag}    ${filter}    ${check_fields}    ${times}=1
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${filter}    ${times}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${filter}
    ...                       check_fields=${check_fields}
    ...                       packet_num=all
