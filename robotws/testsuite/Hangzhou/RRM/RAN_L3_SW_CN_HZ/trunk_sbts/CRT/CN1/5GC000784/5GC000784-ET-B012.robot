*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT
...               owner-teana.wang    team-SG2    release-5G21A    5GC000784    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}

...    MRBTS-1/NRBTS-1:tRLFindForDUVoNR=500ms
...    MRBTS-1/NRBTS-1:rrcReestabTypeSA=viaRRCSetup
...    MRBTS-1/NRBTS-1:actRanSharing=true
...    MRBTS-1/NRBTS-1:actNgcFlexSaMode=true
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    MRBTS-1/NRBTS-1/NRDU-1:numOfDrbsReservForEmergency=1
...    @{PARAMS_FOR_PLMN}
...    @{PARAMS_FOR_SNNSAI}
...    @{PARAMS_FOR_TRACKINGAREA}
...    @{PARAMS_FOR_SECURITY}
...    @{PARAMS_FOR_5QI1}
...    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_XN}
...    @{NRCELL}
...    @{NRCELL_NRPLMNSET_SA_NSA}
...    @{NRCELL1_NRSYSINFO_PROFILE}
...    @{NRCELL1_NRHOIF}
...    @{NRCELL1_NRREL}

@{PARAMS_FOR_SECURITY}
...    MRBTS-1/NRBTS-1:cipherPrefL:nea0=1
...    MRBTS-1/NRBTS-1:cipherPrefL:nea1_128=0
...    MRBTS-1/NRBTS-1:cipherPrefL:nea2_128=9
...    MRBTS-1/NRBTS-1:cipherPrefL:nea3_128=0
...    MRBTS-1/NRBTS-1:integrityProtPrefL:nia1_128=0
...    MRBTS-1/NRBTS-1:integrityProtPrefL:nia2_128=9
...    MRBTS-1/NRBTS-1:integrityProtPrefL:nia3_128=0

@{PARAMS_FOR_5QI1}
...    MRBTS-1/NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    MRBTS-1/NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    MRBTS-1/NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    MRBTS-1/NRBTS-1/NRDRB-15:dscp=0
...    MRBTS-1/NRBTS-1/NRDRB-15:nrDrbId=15
...    MRBTS-1/NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    MRBTS-1/NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    MRBTS-1/NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    MRBTS-1/NRBTS-1/NRDRB-15:numSduDiscard=1
...    MRBTS-1/NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    MRBTS-1/NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    MRBTS-1/NRBTS-1/NRDRB-15:resType=GBR
...    MRBTS-1/NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    MRBTS-1/NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=100
...    MRBTS-1/NRBTS-1/NRDRB-15:schedulWeight=1
...    MRBTS-1/NRBTS-1/NRDRB-15:discardTimer=150ms
...    MRBTS-1/NRBTS-1/NRDRB-15:actDddsReduction=false
...    MRBTS-1/NRBTS-1/NRDRB-15:maxDataRateGbrDl=100
...    MRBTS-1/NRBTS-1/NRDRB-15:maxDataRateGbrUl=100
...    MRBTS-1/NRBTS-1/NRDRB-15:nsaDrbParam:dlNumOfCongOrGainDdds=2
...    MRBTS-1/NRBTS-1/NRDRB_MAC-3:lcgid=4
...    MRBTS-1/NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    MRBTS-1/NRBTS-1/NRDRB_MAC-3:nrDrbMacId=3
...    MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1:nrDrbRlcUmId=1
...    MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    MRBTS-1/NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false

@{PARAMS_FOR_5QI5}
...    MRBTS-1/NRBTS-1/NRDRB_5QI-1:fiveqiValueList=5
...    MRBTS-1/NRBTS-1/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    MRBTS-1/NRBTS-1/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:lcgid=0
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    MRBTS-1/NRBTS-1/NRDRB_MAC-4:nrDrbMacId=4

@{NRCELL}
...    MRBTS-1/NRBTS-1/NRCELL-1:actVoNR=true
...    MRBTS-1/NRBTS-1/NRCELL-1:actEnhancedVoNR=true
...    MRBTS-1/NRBTS-1/NRCELL-1:n310VoNR=n3
...    MRBTS-1/NRBTS-1/NRCELL-1:t310VoNR=500ms
...    MRBTS-1/NRBTS-1/NRCELL-1:actGBRAdmissionControl=EnhancedVoNR
...    MRBTS-1/NRBTS-1/NRCELL-1:emergencyCallLimServ=true
...    MRBTS-1/NRBTS-1/NRCELL-1:actEmergencyCall=true
...    MRBTS-1/NRBTS-1/NRCELL-1:maxGBRTrafficLimit=30
...    MRBTS-1/NRBTS-1/NRCELL-1:maxNumOfGBRBearersSA=1
...    MRBTS-1/NRBTS-1/NRCELL-1:arpPrioEmergencyCall=1
...    MRBTS-1/NRBTS-1/NRCELL-1:numOfRadioResReservForEmergency=1
...    MRBTS-1/NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=false
...    MRBTS-1/NRBTS-1/NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    MRBTS-1/NRBTS-1/NRCELL-1:absThreshSsbRsrpConsolidation=1
...    MRBTS-1/NRBTS-1/NRCELL-1:sMeasConfigSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=80
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    delete:MRBTS-1/NRBTS-1/NRCELL:trackingAreaDN
...    delete:MRBTS-1/NRBTS-1/NRCELL:configuredEpsTac

@{NRCELL1_NRSYSINFO_PROFILE}
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXHighQ=0
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:threshXLowQ=0

@{NRCELL1_NRHOIF}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=633408
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64

@{PARAMS_FOR_PLMN}
...    MRBTS-1/NRBTS-1/NRPLMN-1:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-1:mnc=489
...    MRBTS-1/NRBTS-1/NRPLMN-1:mncLength=3
...    MRBTS-1/NRBTS-1/NRPLMN-2:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-2:mnc=402
...    MRBTS-1/NRBTS-1/NRPLMN-2:mncLength=3

@{PARAMS_FOR_SNNSAI}
...    MRBTS-1/NRBTS-1/SNSSAI-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-1:sd=13714341
...    MRBTS-1/NRBTS-1/SNSSAI-1:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-2:sd=13714342
...    MRBTS-1/NRBTS-1/SNSSAI-2:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2

@{PARAMS_FOR_TRACKINGAREA}
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    MRBTS-1/NRBTS-1/TRACKINGAREA-200:fiveGsTac=200

@{NRCELL_NRPLMNSET_SA_NSA}
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1

@{NRCELL1_NRREL}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:removeNotAllowed=false
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbId=36
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:lcrId=3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mnc=402
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

@{PARAMS_FOR_XN}
...    MRBTS-1/NRBTS-1:actIncXn=true
...    MRBTS-1/NRBTS-1:actConflictConfiguration=false
...    MRBTS-1/NRBTS-1/XNLINK-1:cPlaneIpAddr=10.0.1.122
...    MRBTS-1/NRBTS-1/XNLINK-1:cPlaneIpAddrCtrl=oamControlled
...    MRBTS-1/NRBTS-1/NRADJGNB-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNodeBId=36
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJGNB-1:xnLinkRef=1
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mnc=402
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbId=36
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:lcrId=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrarfcn=633372
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:ssbFrequency=633408
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:physCellId=48
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=402
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:fiveGsTac=100

#The number of total handover attempts for UEs having an emergency call ongoing in the source cell
${ATT_HO_EMERGENCY}               M55147C00501
#The number of total failed handover preparations for UEs having an emergency call ongoing in the source cell
${FAIL_HO_PREP_EMERGENCY_RECD}    M55147C00502
#The number of total failed handover preparations for UEs having an emergency call ongoing due to RAC in the target cell.
${FAIL_HO_PREP_EMERGENCY_RAC}     M55147C00505

@{PM_COUNTER_CHECK}
...    ${ATT_HO_EMERGENCY}=1
...    ${FAIL_HO_PREP_EMERGENCY_RECD}=0
...    ${FAIL_HO_PREP_EMERGENCY_RAC}=1

${UE_NR_CAPABILITY}    SEPARATOR=
...    E1A01000074E5A031E000381A00F04983200021E0A018806804C020301C022A36146B04050D012CB2898183D6C10101070EF1C39061C00103
...    278FAB80027800E0009E00151B11B582028680965944C0C1EB608080838778E1C830E0008193C7D53FF4FFCA8D89BAC10143404B2CA26060F
...    5B0404041C3BC70E418700040C9E3EAE0009E003800278000610713400000041C2800000010711800000802809B00A20230380780C0440230
...    1000FF5555504C00E000A070500703007803800341F004000000000000000100795358194010400002596540000010074AAA881D0500E0016
...    00010008010020010040086AC4C0004080C1014181C202C4044484C648494989CA12986B40



*** Test Cases ***
5GC000784-ET-B012_Verify_unsuccessful_Inter_freq_inter_gnb_HO_with_EC_call_ongoing_and_Normal_5QI1_RAC_failure_on_target
    [Documentation]
    ...    1. The purpose of this tc is to verify intra-GNB intra-Freq inter-PLMN ho with EC ongoing for LSM UE when parameters set as below:
    ...         Source/Target Cell: emergencyCallMrListIgnore=false; emergencyCallPlmnHoAllowed=true; numOfDrbsReservForEmergency=1
    ...         NRBTS/NRCELL.maxNumOfGbrBearersSA =1; numOfRadioResReservForEmergency =1;
    ...    2. Test Case Step:
    ...        a, UE-1 set MRL to restrict target cell (Not allowed PLMN,TAC).
    ...        b, UE-1 initial emergency call in source cell (2 PDU sessions include normal voice call PDU Session).
    ...        c, UE-1 perform intra gnb inter-freq inter-plmn HO to target cell.
    ...        d, UE-2 initial emergency call in source cell to occupy GBR resource.
    ...        e, UE-1 perform intra gnb inter-freq inter-plmn HO back to source cell.
    ...    3. Expected Result:
    ...        f, HO failed due to 5QI1 RAC failure on target cell, check cause in handoverpreparation should be "no raido resource"
    ...           No fallback triggered.
    [Timeout]     60 min
    [Tags]     QC_61239
    Clear Counter Files    wait=${False}
    Check XN Link Status
    Add UE History Information List For Handover
    Config AMF1 MRL For UE
    Trigger UE MO VoNR Voice Call With One Normal and One Eemergency PDU Session    ue_id=1
    Tirgger UE Inter-Frequency HO From GNB2 To GNB3    ue_id=1
    Trigger UE MO VoNR Voice Call With One Normal PDU Session    ue_id=2
    Tirgger UE Inter-Frequency HO From GNB3 To GNB2 Failed    ue_id=1
    Sleep    5    waiting for HandoverPreparationFailure
    Release Ues     ue_type=sa    ue_id=1-2
    Check Counters    ${PM_COUNTER_CHECK}
    Check Wireshark Log    ${CURDIR}/a2a_B012/a2a.ini    wait_string=UEContextReleaseComplete::6
    [Teardown]     Testcase Tear Down for 5GC000784-B

*** Keywords ***
Modify Cfg
    Update Cfg Param    set_ue simulated id=1 nia=null+aes nea=null+aes
    Update Cfg Param    set_ue simulated id=2 nia=null+aes nea=null+aes
    Update Cfg    ue_param id=1-6 nr_usage_setting=voice_centric ue_nr_capabilities=${UE_NR_CAPABILITY}
    Update Cfg    ue_nr_capabilities id=1-6 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=5 default=off
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=9 default=on
    Update Cfg    set_qosflow id=4 5qi=7
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_amf_region id=1 tac_list=0,100,200,258,788 plmn=311:489,311:402
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on voice_fallback=off
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1-6 qos_flows=3,2,1 qos_rules=1,2
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1-6 amf=1 qos_flows=1,2 qos_rules=1,2
    ${set_gnb3}    Catenate    set_gnb id=3 type=simulated plmn=311:402 nssai=0x01:0xD143A5,0x01:0xD143A6 amf=1
    ...    ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.122
    Update Cfg    ${set_gnb3}
    ${set_gnb3_cell1}    Catenate    set_cell id=1 gnb=3 pci=16:0 nrci=0x03 tac=100 nr_arfcn=633372:633372 gscn=7847
    ...    tdd_cell=on proxy=10.0.2.90:9999 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell1}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=true measEvent=A3

Check XN Link Status
    Object Should Exist    XNLINK-1:xnLinkStatus=available

Testcase Tear Down for 5GC000784-B
    Set Qosflow Priority And Smf Param     priority=15
    Execute Egate Command    amf_param id=1 bypassAuth_nullSecurity=off
    Execute Egate Command    amf_mobility_restriction_list_param id=1 reset
    Common Test Teardown And Stop Capture Logs

Set Qosflow Priority And Smf Param
    [Arguments]    ${priority}=1
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=3 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=4 priority=${priority}
    Execute Egate Command    smf_param id=1 reset

Add UE History Information List For Handover
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:402|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=99
    Execute Egate Command    ue_history_information_list id=1 action=commit    pass_regexp=UE History List: 1 was committed
    Execute Egate Command    ue_enb_param id=1 ue_history_list=1

Config AMF1 MRL For UE
    [Arguments]    ${ue_id}=1     ${equiv_plmn}=311:402     ${sa_plmn}=311:402    ${not_allowed_tacs}=100
    ...    ${fa_plmn}=311:409     ${forbidden_tacs}=311
    ${cmd}    Catenate    amf_mobility_restriction_list_param id=1 equiv_plmn=${equiv_plmn}
    ...    sa_plmn=${sa_plmn} not_allowed_tacs=${not_allowed_tacs} fa_plmn=${fa_plmn} forbidden_tacs=${forbidden_tacs}
    Execute Egate Command    ${cmd}
    Execute Egate Command    amf_mobility_restriction_list_param id=1    pass_regexp=${sa_plmn}
    Execute Egate Command    amf_ue_ics_param id=1 ue=${ue_id} mobility_restriction_list_id=1

Trigger UE MO VoNR Voice Call With One Normal and One Eemergency PDU Session
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Setup PDU Session with Initial Request    ue_id=${ue_id}    pdu_id=1    gw=1
    Add 5QI-1 to Exist PDU Session    ue_id=${ue_id}    pdu_id=1
    Set Qosflow Priority And Smf Param    priority=1
    Setup PDU Session with Emergency Request    ue_id=${ue_id}    pdu_id=2    gw=2
    Add 5QI-1 to Exist PDU Session    ue_id=${ue_id}    pdu_id=2

Trigger UE MO VoNR Voice Call With One Normal PDU Session
    [Arguments]    ${ue_id}=2
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Setup PDU Session with Initial Request    ue_id=${ue_id}    pdu_id=1    gw=3
    Add 5QI-1 to Exist PDU Session    ue_id=${ue_id}    pdu_id=1

Setup PDU Session with Initial Request
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${gw}=1
    @{expect}    Create List    securityModeCommand
    ...    ipheringAlgorithm nea2
    ...    Initial Context Setup Successful for UE with AMF UE
    ...    Setup QosFlow with QFI:1 5QI:5
    ...    QoS Routing Table
    ${cmd}    Catenate    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw} nwslice=2 request_type=initial-request
    Execute Egate Command    ${cmd}    pass_regexp=${expect}

Setup PDU Session with Emergency Request
    [Arguments]    ${ue_id}=1    ${pdu_id}=2    ${gw}=2
    @{expect}    Create List    rrcReconfiguration
    ...    Setup QosFlow with QFI:1 5QI:5
    ...    QoS Routing Table
    ...    Pdu Session Resource Setup Response Message with RAN UE NGAP ID [0-9]* handled successfully
    Execute Egate Command
    ...    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw} nwslice=2 request_type=initial-emergency-request
    ...    pass_regexp=${expect}

Add 5QI-1 to Exist PDU Session
    [Arguments]    ${ue_id}=1    ${pdu_id}=2
     @{expect}    Create List    rrcReconfiguration
    ...    Added QosFlow with QFI:2 5QI:1
    ...    QoS Routing Table
    ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=2 by=amf
    ...    pass_regexp=${expect}

Sim GNB3 ignore target gnb NSSAI
    Execute Egate Command    gnb_param id=3 ignore_MRL_during_HO=on ignore_NSSAI_during_HO=on

Tirgger UE Inter-Frequency HO From GNB2 To GNB3
    [Arguments]    ${ue_id}=1
    Sim GNB3 ignore target gnb NSSAI
    ${a2mea_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=636576    event_type=A2
    ${ret}    Execute Egate Command     ue_measurement_send_nr id=${ue_id} meas_id=${a2mea_id} event=A2 srsrp_nr=8 srsrq_nr=8
    ...      pass_regexp=eventA3
    Should Contain    ${ret}    rrcReconfigurationComplete
    ${a3mea_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633408    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${a3mea_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=48 nrsrp_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=UE${ue_id}: Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed

Tirgger UE Inter-Frequency HO From GNB3 To GNB2 Failed
    [Arguments]    ${ue_id}=1
    Sim GNB3 ignore target gnb NSSAI
    ${mea_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=636576    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=A3 srsrp_nr=8 srsrq_nr=8
    ...    phycell_id=50 nrsrp_nr=80 nrsrq_nr=80 rs_type=ssb index=0 nrs_result=10:10:10
    Execute Egate Command    ${cmd}    pass_regexp=Handover canceled    fail_regexp=fallback
