*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-SG2
...     owner-dan.liu    release-SBTS20A     5GC000784
Resource     ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{784_releate}
...    @{Inter_fre}
...    @{TAC_300}
...    @{CELL1_NRHOIF}
...    @{CELL2_NRHOIF}

@{784_releate}
...    NRBTS/NRDRB_5QI-5:fiveqiValueList=9
...    NRBTS/NRDRB_5QI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-14
...    NRBTS/NRDRB-14:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-14:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-14:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-14:resType=nonGBR
...    NRBTS/NRDRB-14:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-2:lcgid=2
...    NRBTS/NRDRB_MAC-2:schedulPrio=5
...    NRBTS/NRDRB_PDCP-2:cuFlowControlProfId=1
...    NRBTS/NRDRB_RLC_AM-2:duFlowControlProfId=1
...    NRBTS/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS/NRDRB-10:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-10:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS-1/NRDRB_MAC-3:lcgid=0
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=4
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=4
...    NRCELL:actVoNR=true
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS-1:cipherPrefL:nea0=1
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=9
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=9
...    NRBTS-1:integrityProtPrefL:nia3_128=0


...    NRBTS-1:actConflictConfiguration=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS-1:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRSACU=5min
...    NRCELL-2:nrarfcn=633372
...    NRCELL-2:gscnOrSsPbchArfcn=7847
...    NRBTS-1/NRCELL:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRBTS-1/NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64

@{CELL1_NRHOIF}
...    NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRBTS-1/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS-1/NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=633408
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1:sMeasConfigSsbRsrp=0

@{CELL2_NRHOIF}
...    NRBTS-1/NRCELL-2/NRHOIF-1:cellDepType=SA
...    NRBTS-1/NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRBTS-1/NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS-1/NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRBTS-1/NRCELL-2/NRHOIF-1:ssbFrequency=636576
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRBTS-1/NRCELL-2:measGapSelectionSA=favourUeThroughput

@{Inter_fre}
...    NRBTS-1/NRCELL:a1MeashoEnabledSA=rsrp
...    NRBTS-1/NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRBTS-1/NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=30
...    NRBTS-1/NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms64
...    NRBTS-1/NRCELL:a2MeashoEnabledSA=rsrp
...    NRBTS-1/NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRBTS-1/NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    NRBTS-1/NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL-1/NRREDRT-2:redirFreqEutra=1350
...    NRCELL-1/NRREDRT-2:redirPrio=2
...    NRCELL-1/NRREDRT-2:redirRat=eutra
...    delete:NRREDRT-2:redirSsbScs
...    NRBTS-1/SNSSAI-1:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-1:sd=13714341
...    NRBTS-1/SNSSAI-1:sst=1
...    NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/SNSSAI-1:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    NRBTS-1/SNSSAI-2:sd=13714342
...    NRBTS-1/SNSSAI-2:sst=1
...    NRBTS-1/SNSSAI-2:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS-1/TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2


@{TAC_300}
...    NRBTS-1/TRACKINGAREA-300:fiveGsTac=100
...    TRACKINGAREA-300:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    TRACKINGAREA-300:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS-1:rrcReestabTypeSA=viaRRCSetup
...    NRCELL:actEmergencyCall=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL:emergencyCallLimServ=true
...    NRCELL-1:maxNumOfGBRBearersSA=10
...    NRCELL-2:maxNumOfGBRBearersSA=0
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=false
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=false
...    NRDU-1:numOfDrbsReservForEmergency=1
...    NRCELL:arpPrioEmergencyCall=1
...    NRCELL:emergencyCallFails=true
...    NRCELL-1:numOfRadioResReservForEmergency=1
...    NRCELL-2:numOfRadioResReservForEmergency=0
...    NRCELL:maxNumOfRrcSA=10
...    NRCELL:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL:configuredEpsTac=200

@{CELL2_DELTA_PARAMS}
...    NRCELL-2:maxNumOfGBRBearersSA=2
...    NRCELL-2:numOfRadioResReservForEmergency=1

${UE_CAPA_B11}    SEPARATOR=
...    E1A01000074E5A031E000381A00F04983200021E0A018806804C020301C022A36146B04050D012CB2898183D6C10101070EF1C39061C00103278FA
...    B80027800E0009E00151B11B582028680965944C0C1EB608080838778E1C830E0008193C7D53FF4FFCA8D89BAC10143404B2CA26060F5B0404041C
...    3BC70E418700040C9E3EAE0009E003800278000610713400000041C2800000010711800000802809B00A20230380780C04402301000FF5555504C0
...    0E000A070500703007803800341F004000000000000000100795358194010400002596540000010074AAA881D0500E001600010008010020010040
...    086AC4C0004080C1014181C202C4044484C648494989CA12986B40

*** Test Cases ***
5GC000784-ET-B011_Verify_unsuccessful_Inter_freq_intra_gnb_HO_with_emergency_call_ongoing_and_EC5QI1_RAC_failure_on_target
    [Documentation]    UE with inter_freq_intra_gnb_HO_with_emergency_call_ongoing_and_EC5QI1_RAC_failure_on_targetL should unsuccessfuly
    ...    2. Test Case Steps:
    ...    a. configure MRL with target PLMN matching the not_allowed_tacs
    ...    b. UE-1 setup a normal call and emergencyl call on cell-1, check UE location
    ...    c. UE-1 trigger inter-Freq handover to the target cell-2, check UE location
    ...    d. Change params: NRCELL-2:maxNumOfGBRBearersSA=10, NRCELL-2:numOfRadioResReservForEmergency=1
    ...    e. UE-1 trigger inter-Freq handover to the target cell-2, check UE location
    ...    f. UE-1 trigger inter-Freq handover back to the target cell-1, check UE location
    ...    3. Expected Results:
    ...    step c: UE-1 HO failed, UE should still stay in cell-1
    ...    step e: UE-1 HO successful, UE should stay in cell-2
    ...    step f: UE-1 HO back successful, UE should stay in cell-1
    [Tags]    QC_61240
    [Timeout]     60 min
    Config AMF1 MRL For UE    ue_id=1    equiv_plmn=311:489    sa_plmn=311:489    not_allowed_tacs=100
    Trigger UE MO VoNR Voice Call With One Normal and One Eemergency PDU Session
    Trigger UE Inter-Frequency Intra-gNB HO To Cell-2 Should Failed
    Delta Commission Parameters    ${CELL2_DELTA_PARAMS}
    Trigger UE Inter-Frequency Intra-gNB HO To Cell-2 Should Success
    Trigger UE Inter-Frequency Intra-gNB HO Back To Cell-1 Should Success
    Release Ues     sa    1
    Check Wireshark Log    ${CURDIR}/a2a_B011/a2a.ini    wait_string=UEContextReleaseComplete::4
    [Teardown]     Testcase Teardown for 5GC000784-B


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Testcase Teardown for 5GC000784-B
    Set Qosflow Priority And Smf Param     priority=15
    Execute Egate Command    amf_param id=1 bypassAuth_nullSecurity=off
    Execute Egate Command    amf_mobility_restriction_list_param id=1 reset
    Common Test Teardown And Stop Capture Logs

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${UE_CAPA_B11}
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes
    ${set_ue1}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue1}
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=5 default=off
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=9 default=on
    Update Cfg    set_qosflow id=4 5qi=7
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1 qos_flows=1,2 qos_rules=1,2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1-4 qos_flows=3,2,1 qos_rules=1,2
    ${set_cell2}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=100 nrci=0x02 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=633372:633372 gscn=7847 mandatory_for_activation=off
    Update Cfg    ${set_cell2}

Config AMF1 MRL For UE
    [Arguments]    ${ue_id}=1     ${equiv_plmn}=311:402     ${sa_plmn}=311:402    ${not_allowed_tacs}=100
    ...     ${fa_plmn}=311:409     ${forbidden_tacs}=311
    ${cmd1}    Catenate    amf_mobility_restriction_list_param id=1 equiv_plmn=${equiv_plmn}
    ...    sa_plmn=${sa_plmn} not_allowed_tacs=${not_allowed_tacs} fa_plmn=${fa_plmn} forbidden_tacs=${forbidden_tacs}
    Execute Egate Command    ${cmd1}
    Execute Egate Command    amf_mobility_restriction_list_param id=1    pass_regexp=${sa_plmn}
    Execute Egate Command    amf_ue_ics_param id=1 ue=${ue_id} mobility_restriction_list_id=1

Trigger UE MO VoNR Voice Call With One Normal and One Eemergency PDU Session
    [Arguments]     ${ue_id}=1
    Set qosflow priority and smf param     priority=15
    UE Register To GNB    ue_id=${ue_id}
    UE PDU Session Setup    ue_id=${ue_id}    pdu_id=1    nwslice=2    gw=1    request_type=initial-request
    UE PDU Session Modify to Add    ue_id=${ue_id}    pdu_id=1
    Set qosflow priority and smf param     priority=1
    UE PDU Session Setup    ue_id=${ue_id}    pdu_id=2    nwslice=2    gw=2    request_type=initial-emergency-request
    UE PDU Session Modify to Add    ue_id=${ue_id}    pdu_id=2
    Check UE Location    ue_id=1    enb=2    cell=1

UE Register To GNB
    [Arguments]     ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}     UE now in NG RM Registered

UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${nwslice}=2    ${gw}=1    ${request_type}=initial-request
    @{expect}    Create List    rrcReconfigurationComplete
    ...    Setup QosFlow with QFI:1 5QI:5
    ...    QoS Routing Table
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw}
    ...    request_type=${request_type}
    Execute Egate Command     ${cmd}     pass_regexp=${expect}

UE PDU Session Modify to Add
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    @{expect}    Create List    rrcReconfigurationComplete
    ...    Added QosFlow with QFI:2 5QI:1
    ...    QoS Routing Table
    ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully
    ${ret1}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=2 by=amf
    ...    pass_regexp=${expect}

Set qosflow priority and smf param
    [Arguments]     ${priority}=1
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=3 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=4 priority=${priority}
    Execute Egate Command    smf_param id=1 reset

Check UE Location
    [Arguments]    ${ue_id}=1    ${enb}=2    ${cell}=1
    Check Specific Ue State    ${ue_id}    ACTIVE
    ${real_enb_id}    ${real_cell_id}    Get UE Location    ${ue_id}
    Should Be Equal    ${real_enb_id}    ${enb}
    Should Be Equal    ${real_cell_id}    ${cell}

Trigger UE Inter-Frequency Intra-gNB HO To Cell-2 Should Failed
    [Arguments]    ${ue_id}=1
    ${measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=636576    event_type=A2
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=11 srsrq_nr=11
    @{expect}     Create List     rrcReconfigurationComplete     eventId eventA3
    Execute Egate Command    ${cmd}    pass_regexp=${expect}
    ${a3mea}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633408    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a3mea} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=51 nrsrp_nr=80
    Execute Egate Command     ${cmd}    fail_regexp=Reconfiguration
    Check UE Location    ue_id=1    enb=2    cell=1

Trigger UE Inter-Frequency Intra-gNB HO To Cell-2 Should Success
    [Arguments]    ${ue_id}=1
    ${a3mea}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633408    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a3mea} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=51 nrsrp_nr=80
    @{expect}     Create List     rrcReconfigurationComplete
    ...    UE${ue_id}: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    ${ret}    Execute Egate Command    ${cmd}    pass_regexp=${expect}
    Check UE Location    ue_id=1    enb=2    cell=2

Trigger UE Inter-Frequency Intra-gNB HO Back To Cell-1 Should Success
    [Arguments]    ${ue_id}=1
    ${measid}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633408    event_type=A2
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=11 srsrq_nr=11
    @{expect}     Create List     rrcReconfigurationComplete     eventId eventA3
    Execute Egate Command    ${cmd}    pass_regexp=${expect}
    ${a3mea}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=636576    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a3mea} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=50 nrsrp_nr=80
    @{expect}     Create List     rrcReconfigurationComplete
    ...    UE${ue_id}: Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
    ${ret}    Execute Egate Command    ${cmd}    pass_regexp=${expect}
    Check UE Location    ue_id=1    enb=2    cell=1
