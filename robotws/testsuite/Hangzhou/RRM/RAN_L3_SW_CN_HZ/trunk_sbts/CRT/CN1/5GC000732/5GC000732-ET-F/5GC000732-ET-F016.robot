*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags     QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    CXT    SBTS00    owner-jifan    team-SG2
...    release-SBTS22R2    5GC000732    CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/L1B/6cells_2T4F

@{PARAMS_IN_SCF}    @{732_flag}    @{A1A2_event}    @{NRCELL}    @{NRDU}    @{NRREL}    @{NRDRB}    @{NRHOIF}

@{732_flag}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:timerXnDataFwdGuard=250
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:tRLFindForDUVoNR=500ms
...    NRBTS-1:drbInactivityTimerSA=7200

...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRPMRNL-1:miNrRelReportCu=5min

@{A1A2_event}
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=55
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms40
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=55
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms40
...    NRCELL-12:a1MeashoEnabledSA=rsrp
...    NRCELL-12:a2MeashoEnabledSA=rsrp
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=2
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms

@{NRCELL}
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1:actPrachMultiplexing=true

...    NRCELL-1:actCDrx=true
...    NRCELL-1:drxProfile1:drxInactivityTimer=10ms
...    NRCELL-1:drxProfile1:drxLongCycle=40ms
...    NRCELL-1:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-1:drxProfile1:drxRetransTimerDl=0slot
...    NRCELL-1:drxProfile1:drxRetransTimerUl=0slot
...    NRCELL-1:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL-1:actVoNR=true
...    NRCELL-1:actCDrxVoNR=true
...    NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL-1:maxGBRTrafficLimit=75
...    NRCELL-1:actEmergencyCall=true
...    NRCELL-1:actVoNrMobilityThresholds=VoNrMobilityThresholds
...    NRCELL-1:t310=2000ms
...    NRCELL-1:n310VoNR=n3
...    NRCELL-1:t310VoNR=500ms
...    NRCELL-1:actEnhancedVoNR=true
...    NRCELL-1:drxProfile2:drxInactivityTimer=4ms
...    NRCELL-1:drxProfile2:drxLongCycle=40ms
...    NRCELL-1:drxProfile2:drxOnDurationTimer=4ms
...    NRCELL-1:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL-1:drxProfile2:drxRetransTimerUl=0slot
...    NRCELL-1:emergencyCallLimServ=true
...    NRCELL-1:arpPrioEmergencyCall=1
...    NRCELL-12:actK1Opt=intra-gNB

...    NRCELL-12:actPrachMultiplexing=true

@{NRDU}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa

@{NRREL}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=12
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

@{NRHOIF}
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:scs=15 KHz
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=126750
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=3
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=30
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=ms40

@{NRDRB}
...    NRDRB_PDCP:maxCidAllowed=4
...    NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRDRB_5QI-6:fiveqiValueList=1
...    NRDRB-15:actDddsReduction=false
...    NRDRB-15:actLostPduFastRetx=false
...    NRDRB-15:discardTimer=150ms
...    NRDRB-15:dlFlowControlAlgo=none
...    NRDRB-15:dscp=46
...    NRBTS-1/NRDRB-15:durationThresDiscardDl=40
...    NRBTS-1/NRDRB-15:durationThresDiscardUl=20
...    NRDRB-15:maxDataRateGbrDl=1000
...    NRDRB-15:maxDataRateGbrUl=1000
...    NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRDRB-15:maxTransferDelayGbr=20
...    NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-15:numSduDiscard=1
...    NRDRB-15:queuingDelayDiscarding=Disabled
...    NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRDRB-15:resType=GBR
...    NRDRB-15:rlcMode=RLC_UM
...    NRDRB-15:schedulWeight=1
...    NRDRB-15:sduDiscardIntervalTmr=500
...    NRDRB-15:volThresDiscardDl=8000
...    NRDRB-15:volThresDiscardUl=800
...    NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRDRB_PDCP-2:maxCidAllowed=4
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRDRB_MAC-4:lcgid=4
...    NRDRB_MAC-4:schedulPrio=5
...    NRDRB_MAC-4:prioritisedBitRate=16kBps

@{PM_COUNTER_CHECK}
...    NRBTS-1:${F1_UE_CTXT_MOD_REQ_RECEIVED}=29
...    NRBTS-1:${F1_UE_CTXT_MOD_RESP_SENT}=29
...    NRBTS-1:${F1_UE_CTXT_MOD_FAIL_SENT}=0
...    NRBTS-1:${REESTAB_ACC_OTHER_FAIL_DU}=2
...    NRBTS-1:${RRC_REESTAB_OTHER_FAILURE_DU}=2
...    NRCELL-1:${RRC_REESTAB_OTHER_FAILURE}=2
...    NRCELL-1:${REESTAB_ACC_OTHER_FAIL}=2
...    NRCELL-1:${REESTAB_RRCRECONFIG_SUCC}=2
...    NRCELL-1:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-12:${UE_SCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${NRRCC_RRC_RECONF_SENT}=10
...    NRCELL-1:${NRRCC_RRC_RECONF_CMP_RECD}=10
...    NRCELL-1:${SGNB_SA_DU_NGBR_DRB_REQ}=3
...    NRCELL-1:${SGNB_SA_DU_NGBR_DRB_SUCC}=3
...    NRCELL-1:${SGNB_SA_DU_NGBR_DRB_REL}=3
...    NRCELL-1:${SA_DU_GBR_DRB_REQ}=3
...    NRCELL-1:${SA_DU_GBR_DRB_SUCC}=3
...    NRCELL-1:${REESTAB_ACC_VONR}=2
...    NRCELL-1:${RRC_REESTAB_ATT_VONR}=2

${RRC_REESTAB_OTHER_FAILURE_DU}    M55127C00503    #RRC_REESTAB_OTHER_FAILURE_DU:If reestablishmentCause IE is otherFailure
${RRC_REESTAB_OTHER_FAILURE}    M55124C00505    #RRC_REESTAB_OTHER_FAILURE:If reestablishmentCause IE is otherFailure
${REESTAB_ACC_OTHER_FAIL_DU}    M55127C00512    #REESTAB_ACC_OTHER_FAIL_DU:If reestablishmentCause IE is otherFailure
${REESTAB_ACC_OTHER_FAIL}    M55124C00512    #REESTAB_ACC_OTHER_FAIL:If reestablishmentCause IE is otherFailure
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516    #REESTAB_RRCRECONFIG_SUCC:Number of RRC reconfiguration successful in RRC reestablishment procedure
${F1_UE_CTXT_MOD_REQ_RECEIVED}    M55117C00001    #Number of incoming UE CONTEXT MODIFICATION REQUEST received from gNB-CU
${F1_UE_CTXT_MOD_RESP_SENT}    M55117C00002    #Number of outgoing UE CONTEXT MODIFICATION RESPONSE sent to gNB-CU
${F1_UE_CTXT_MOD_FAIL_SENT}    M55117C00003    #Number of outgoing UE CONTEXT MODIFICATION FAILURE sent to gNB-CU
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507    #Sum of CA UEs in the current cell configured as a PCell, which have 1 configured SCell in DL
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508    #Sum of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
${NRRCC_RRC_RECONF_SENT}    M55124C03001    #Number of RRC RECONFIGURATION sent
${NRRCC_RRC_RECONF_CMP_RECD}    M55124C03002    #Number of RRC RECONFIGURATION COMPLETE received
${SGNB_SA_DU_NGBR_DRB_REQ}    M55139C00003    #The number of non-GBR DRB radio admission requests for SA user in DU
${SGNB_SA_DU_NGBR_DRB_SUCC}    M55139C00004    #The number of radio admitted non-GBR DRBs for SA user in DU
${SGNB_SA_DU_NGBR_DRB_REL}    M55139C00012    #The number of non-GBR DRB radio admission releases for SA user in DU
${SA_DU_GBR_DRB_REQ}    M55139C00501    #The number of GBR DRB radio admission requests for SA user in DU
${SA_DU_GBR_DRB_SUCC}    M55139C00502    #The number of GBR DRB successful radio admissions for SA user in DU
${RRC_REESTAB_ATT_VONR}    M55124C00520    #umber of RRC Re-establishment Request attempts for VONR for any cause RRC_REESTAB_ATT_VONR
${REESTAB_ACC_VONR}    M55124C00518    #Number of accepted VONR RRC Re-establishment for all reestablishment causes

*** Test Cases ***
5GC000732-ET-F016_RRC_reestablish_succ_with_784_2329_meas_to_ori_Pcell_DRX_enabled_A2_configured
    [Documentation]    This user scenario describes the behaviour, when a UE in RRC_CONNECTED re-establishes RRC Connection to the selected cell
    ...    (serving cell or the other cell) in serving gNB-DU with valid UE context interaction with emergency call
    ...    preconditions:
    ...        cell12 is FDD cell, disable DRX
    ...        cell1 is TDD cell, enable DRX
    ...    Case steps:
    ...        1.Setup CA(covBasedA1) successfully
    ...        2.EmergencyCall set up successfully
    ...        3.Trgger RRC reestablish to origin cell1 successfully
    ...        4.Trgger RRC reestablish to cell-1 second time successfully
    ...        5.check cause otherFailure in rrcReestablishmentRequest wiresahrk msg and DRB,SRB
    ...        6.check counters
    [Tags]    QC_157336
    Clear Counter Files    wait=${False}
    Trigger UE 5QI-5 and 5QI-1 EmergencyCall setup
    Trigger Scell Addition And UE RRC Reestablish to Cell1
    Trigger Scell Addition And UE RRC Reestablish to Cell1
    Release UEs    ue_type=all
    Check Wireshark Log    ${CURDIR}/a2a_F016/a2a.ini    wait_string=UEContextReleaseComplete
    Check Counters    ${PM_COUNTER_CHECK}

*** Keywords ***
Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=6 default=off
    Update Cfg    set_qosflow id=2 5qi=5 default=on
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=4
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1 qos_flows=1,2,3,4 qos_rules=1,2,3

Set Qosflow Priority
    [Arguments]    ${priority}=1
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}
    Execute Egate Command    qosflow_modify qos_flow=3 priority=${priority}

Trigger UE 5QI-5 and 5QI-1 EmergencyCall setup
    Set Qosflow Priority    priority=1
    Execute Egate Command    ue_register id=82     Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=82 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=82 nwslice=1 gw=1 request_type=initial-emergency-request    QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=82 pdu=1 qosflows_to_add=3 by=amf    QoS Routing Table
    Set Qosflow Priority    priority=15
    Send Throughput
    Verify Throughput

Send Throughput
    Execute Egate Command    trf_data_start ue=82 pdu=1 qfi=1 dir=dl mbps=70 trf_id=1    Started Downlink Internal traffic
    Execute Egate Command    trf_data_start ue=82 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    Started Uplink Internal traffic

Verify Throughput
    [Arguments]     ${sleep_time}=15s
    Sleep    ${sleep_time}
    ${ul_throuput}    Ap Get SA Throughput    ue_id=82    pdu=1    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${ul_throuput}/1000 > 66
    ${ul_throuput}    Ap Get SA Throughput    ue_id=82    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000 > 9

Trigger Scell Addition And UE RRC Reestablish to Cell1
    ${measid}    get nr meas id for specific type and frequency    ue_id=82    carrierfreq=518910    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=82 meas_id=${measid} event=A1 srsrp_nr=112 srsrq_nr=80    SCellIndex 1 activated successfully
    Verify Throughput
    Execute Egate Command    ue_rrc_reestablish id=82 gnb=2 cell=1 cause=otherFailure    NR RRC Reestablishment sucessfully completed
    Verify Throughput
