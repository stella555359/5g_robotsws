*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    CXT    CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    team-SG2
...               owner-xiuli.song    5GC000732    release-SBTS19A
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC000732_Base}
...    @{CELL1}
...    @{DRB}
...    @{HO}

@{5GC000732_Base}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:actGeneralConnectivitySilver=true
...    NRBTS-1/NRDRB_PDCP-1:maxCidAllowed=4
...    MRBTS-1/NRBTS-1:actRohc=true
...    MRBTS-1/NRBTS-1:actInterRatHoSA=true
...    MRBTS-1/NRBTS-1:cipherPrefL:nea0=8
...    MRBTS-1/NRBTS-1:cipherPrefL:nea1_128=0
...    MRBTS-1/NRBTS-1:cipherPrefL:nea2_128=0
...    MRBTS-1/NRBTS-1:cipherPrefL:nea3_128=0
...    MRBTS-1/NRBTS-1:actRedirect=true
...    MRBTS-1/NRBTS-1:timerXnDataFwdGuard=250
...    MRBTS-1/NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true
...    MRBTS-1/NRBTS-1:rrcReestabTypeSA=sameGNB
...    MRBTS-1/NRBTS-1:tWaitingRlRecover=4000ms
...    MRBTS-1/NRBTS-1:actGeneralConnectivitySilver=true

@{CELL1}
...    NRCELL-1:actVoNR=true
...    NRCELL-1:actCDrxVoNR=true
...    NRCELL-1:actCDrx=true
...    NRCELL-1:actEnhancedVoNR=true
...    NRCELL-1:n310VoNR=n10
...    NRCELL-1:t310VoNR=100ms
...    NRCELL-1:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-1:drxProfile1:drxLongCycle=40ms
...    NRCELL-1:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-1:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-1:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-1:drxProfile2:drxInactivityTimer=4ms
...    NRCELL-1:drxProfile2:drxLongCycle=40ms
...    NRCELL-1:drxProfile2:drxOnDurationTimer=4ms
...    NRCELL-1:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL-1:drxProfile2:drxRetransTimerUl=0slot
@{DRB}
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:dscp=46
...    NRBTS-1/NRDRB-15:nrDrbId=15
...    NRBTS-1/NRDRB-15:actDddsReduction=false
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:queuingDelayDiscardEnabled=false
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=500
...    NRBTS-1/NRDRB-15:discardTimer=10ms
...    NRBTS-1/NRDRB-15:l2OHFactorDl=16
...    NRBTS-1/NRDRB-15:l2OHFactorUl=35
...    NRBTS-1/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS-1/NRDRB-15:durationThresDiscard=50
...    NRBTS-1/NRDRB-15:volThresDiscard=100
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-15:actLostPduFastRetx=false
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000

...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:nrDrbRlcUmId=1
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN

...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-2:maxCidAllowed=4

...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:delayTarget=50
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-3:prioritisedBitRate=16kBps

...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
@{HO}
...    NRCELL-2/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-2/NRRELE-1:eNodeBId=18
...    NRCELL-2/NRRELE-1:eutranCellExcluded=false
...    NRCELL-2/NRRELE-1:lcrId=1
...    NRCELL-2/NRRELE-1:ecgiPlmn:mcc=311
...    NRCELL-2/NRRELE-1:ecgiPlmn:mnc=489
...    NRCELL-2/NRRELE-1:ecgiPlmn:mncLength=3
...    NRBTS-1/NRADJECELL-1:eNodeBId=18
...    NRBTS-1/NRADJECELL-1:ePSTrackingAreaCode=0
...    NRBTS-1/NRADJECELL-1:earfcnValue=1
...    NRBTS-1/NRADJECELL-1:lcrId=1
...    NRBTS-1/NRADJECELL-1:physCellId=1
...    NRBTS-1/NRADJECELL-1:ecgiPlmn:mcc=311
...    NRBTS-1/NRADJECELL-1:ecgiPlmn:mnc=489
...    NRBTS-1/NRADJECELL-1:ecgiPlmn:mncLength=3
...    NRBTS-1/NRADJECELL-1:enbPlmn:mcc=311
...    NRBTS-1/NRADJECELL-1:enbPlmn:mnc=489
...    NRBTS-1/NRADJECELL-1:enbPlmn:mncLength=3
...    NRBTS:actGeneralConnectivitySilver=true
...    NRBTS-1/NRHOIR-1:allowedMeasBandwidth=mbw100
...    NRBTS-1/NRHOIR-1:b2MeashoEnabled=none
...    NRBTS-1/NRHOIR-1:b2Threshold1hoRsrp=35
...    NRBTS-1/NRHOIR-1:b2Threshold1hoRsrpVoNr=35
...    NRBTS-1/NRHOIR-1:b2Threshold1hoRsrq=50
...    NRBTS-1/NRHOIR-1:b2Threshold1hoRsrqVoNr=50
...    NRBTS-1/NRHOIR-1:earfcnValue=1
...    NRBTS-1/NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRBTS-1/NRHOIR-1:presenceAntennaPort1=false
...    NRBTS-1/NRHOIR-1:reportAmount=r8
...    NRBTS-1/NRHOIR-1:reportInterval=ms240
...    NRBTS-1/NRHOIR-1:widebandRsrqMeas=false
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=0
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=18
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrpVoNr=ms480
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrqVoNr=0
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrqVoNr=2
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480
...    NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrqVoNr=ms480
...    NRBTS-1/NRDRB_MAC-4:lcgid=0
...    NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=1
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=20
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=ms64
...    NRCELL-2/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:scs=15 KHz
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=424090
...    NRBTS-1/NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRBTS-1/NRCELL-2:a2MeashoEnabledSA=rsrp
...    NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=55
...    NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms40
...    NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=55
...    NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms40
...    NRBTS-1/NRCELL-2:a2MeasRedirectEnabled=rsrq
...    NRBTS-1/NRCELL-2:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRBTS-1/NRCELL-2:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRBTS-1/NRCELL-2:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRBTS-1/NRCELL-2:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRBTS-1/NRCELL-2:actVoNR=true
...    NRBTS-1/NRCELL-2:actCDrxVoNR=true
...    NRBTS-1/NRCELL-2:actEnhancedVoNR=true
...    NRBTS-1/NRCELL-2:actVoipPacketAggr=true
...    NRBTS-1/NRCELL-2:actGBRAdmissionControl=EnhancedVoNR
...    NRBTS-1/NRCELL-2:actVoNrMobilityThresholds=VoNrMobilityThresholds
...    NRBTS-1/NRCELL-2:actCDrx=true
...    NRBTS-1/NRCELL-2:actK1Opt=intra-gNB
...    NRBTS-1/NRCELL-1:actK1Opt=intra-gNB
...    NRBTS-1/NRCELL-2:drxProfile1:drxInactivityTimer=60ms
...    NRBTS-1/NRCELL-2:drxProfile1:drxLongCycle=160ms
...    NRBTS-1/NRCELL-2:drxProfile1:drxOnDurationTimer=80ms
...    NRBTS-1/NRCELL-2:drxProfile1:drxRetransTimerDl=0slot
...    NRBTS-1/NRCELL-2:drxProfile1:drxRetransTimerUl=0slot
...    NRBTS-1/NRCELL-2:drxProfile2:drxInactivityTimer=20ms
...    NRBTS-1/NRCELL-2:drxProfile2:drxLongCycle=40ms
...    NRBTS-1/NRCELL-2:drxProfile2:drxOnDurationTimer=20ms
...    NRBTS-1/NRCELL-2:drxProfile2:drxRetransTimerDl=0slot
...    NRBTS-1/NRCELL-2:drxProfile2:drxRetransTimerUl=0slot
...    NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRDRB-10:resType=nonGBR_Signaling
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:lcrId=2
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:nrDcAllowed=false
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-10:gNbId=1
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:lcrId=1
...    NRCELL-2/NRREL-10:removeNotAllowed=false
...    NRCELL-2/NRREL-10:nrDcAllowed=false
...    NRCELL-2/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-2/NRREDRT-1:redirSsbScs=15KHz

@{PM_Counters_Check}
...    ${RRC_REESTAB_OTHER_FAILURE_DU}=2
...    NRCELL-1:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-2:${RRC_REESTAB_OTHER_FAILURE}=1
...    ${REESTAB_ACC_OTHER_FAIL_DU}=2
...    NRCELL-2:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-1:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-2:${RRC_REESTAB_ATT_VONR}=1
...    NRCELL-1:${RRC_REESTAB_ATT_VONR}=1
...    NRCELL-1:${REESTAB_ACC_VONR}=1
...    NRCELL-2:${REESTAB_ACC_VONR}=1
...    NRCELL-1:${REESTAB_ADMISSION_CRTL}=1
...    NRCELL-2:${REESTAB_ADMISSION_CRTL}=1

${RRC_REESTAB_OTHER_FAILURE_DU}       M55127C00503    #Number of RRC Re-establishment Request caused by other failure
${RRC_REESTAB_OTHER_FAILURE}    M55124C00505    #Number of accepted RRC Re-establishment when reestablishment cause is other failure
# The counter is updated when receiving the RRCReestablishmentComplete message when the reestablishmentCause is otherFailure
${REESTAB_ACC_OTHER_FAIL_DU}    M55127C00512
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516    #Number of RRC reconfiguration successful in RRC reestablishment procedure
${REESTAB_ADMISSION_CRTL}    M55124C00519    #Number of admission control triggered in CU by RRC reestablishment procedure
#The number of successful RRC Reestablishment procedures for VONR for all reestablishment causes
${REESTAB_ACC_VONR}    M55124C00518
#The number of RRC Re-establishment Request attempts for VONR for any cause RRC_REESTAB_ATT_VONR
${RRC_REESTAB_ATT_VONR}    M55124C00520
 
${ReconfigurationFailure}    otherFailure
${ue_id}    82

*** Test Cases ***
5GC000732-ET-F012_RRC_loop_reestablish_succ_with_6112_7922_meas_with_ROHC_to_scell_old_DRX_enabled_A2_configured_new_DRX_enabled_no_meas
    [Documentation]    This case will test RRC reestablish to new cell due to configureationFailure with ROHC
    ...    Reestablish from VoNR, meas, DRX, CA(T+T) to new cell(scell) with DRX and no meas with VoNR
    ...    preconditions:
    ...    1. ROHC(774) is opened and VoNR(6112)
    ...    2. configure CA T+T(cell 2+cell 1) for 7922 blind with DRX,meas(A1, A2, interfreq A3),VoNR
    ...    3. configure cell 1 for new cell with new DRX, VoNR without meas
    ...    Case steps:
    ...    1.Setup CA(TDD+TDD)(cell 2+ cell 1) successfully
    ...    2.Trigger VoNR call with cell 2
    ...    3.Trgger RRC reestablish from cell 2 to cell 1, RRC reestablish successfully
    ...    4.Trigger RRC reestablish from cell 1 to cell 2,RRC reestablish successfully
    ...    5.check VoNR successfully , drx setup successfully and meas config not missing in RRCReestablish procedure
    ...    6.Check counters:
    ...     RRC_REESTAB_OTHER_FAILURE_DU: If reestablishmentCause IE is otherFailure (Counter ID: M55127C00503)
    ...     RRC_REESTAB_OTHER_FAILURE: If reestablishmentCause IE is otherFailure (Counter ID: M55124C00505)
    ...     REESTAB_ACC_OTHER_FAIL_DU: If reestablishmentCause IE is otherFailure (Counter ID: M55127C00512)
    ...     REESTAB_RRCRECONFIG_SUCC: Number of RRC reconfiguration successful in RRC reestablishment procedure
    ...     (Counter ID: M55124C00516)
    ...     REESTAB_ACC_VONR: (Counter ID: M55124C00518)
    ...     RRC_REESTAB_ATT_VONR: (Counter ID: M55124C00520)
    ...     REESTAB_ADMISSION_CRTL: (Counter ID: M55124C00519)
    [Tags]    TRUNK   5GC000732    F012    Owner_liufang
    Start To Capture Wireshark Log    F012_1
    Ue Register And Pdu Session Setup
    Trigger RRC Reestablish    cell_id=1
    Trigger RRC Reestablish    cell_id=2
    Ue_Deregister
    Check Counters    ${PM_Counters_Check}
    Check Wireshark Log    ${CURDIR}${/}a2a_F012_1${/}a2a.ini    name=F012_1    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Modify Cfg
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=4
    Update Cfg    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full_enable_ROHC_powersaving}

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/L1B/6cells_2T4F

Ue_Deregister
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE CONTEXT RELEASE COMPLETE

Trigger RRC Reestablish
    [Arguments]    ${cell_id}
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=${ReconfigurationFailure}
    ...    NR RRC Reestablishment sucessfully completed    timeout=20s
    Verify Throughput

Ue Register And Pdu Session Setup
    Clear Counter Files
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=2    pass_regexp=location
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=QoS Routing Table
    Should Contain    ${ret1}    SCellIndex 1 activated successfully at airphone
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf    pass_regexp=QoS Routing Table
    Trigger Throughput

Trigger Throughput
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=70 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    pass_regexp=Started Uplink

Verify Throughput
    [Documentation]    verify Tput in scell is not 0
    [Arguments]    ${Tput_dl}=60    ${Tput_ul}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
