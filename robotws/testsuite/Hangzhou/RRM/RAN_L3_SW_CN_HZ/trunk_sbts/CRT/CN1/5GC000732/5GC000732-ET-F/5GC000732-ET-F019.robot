*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags     QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    CRT    SBTS00
...    owner-jia.pan    owner-teana.wang    team-SG2    release-SBTS22R2    5GC000732
...    CLOUD_5G_I_BOO_AP_LOO
Resource    ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_2T4F

@{PARAMS_IN_SCF}
...    NRBTS-1:rrcReestabTypeSA=sameGNB

...    NRBTS-1:timerXnDataFwdGuard=250
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:drbInactivityTimerSA=7200
...    NRBTS-1:tRLFindForDUVoNR=500ms
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL:actPrachMultiplexing=true
...    NRCELL-1:actVoNR=true
...    NRCELL-1:actEmergencyCall=true
...    NRCELL-1:actEnhancedVoNR=true
...    NRCELL-1:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL-1:actVoNrMobilityThresholds=VoNrMobilityThresholds
...    NRCELL-1:n310VoNR=n3
...    NRCELL-1:t310VoNR=500ms
...    NRCELL-1:emergencyCallLimServ=true
...    NRCELL-1:maxGBRTrafficLimit=75
...    NRCELL-1:arpPrioEmergencyCall=1
...    NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-11:actVoNR=true
...    NRCELL-11:actCDrx=true
...    NRCELL-11:actCDrxVoNR=true
...    NRCELL-11:actEmergencyCall=true
...    NRCELL-11:actEnhancedVoNR=true
...    NRCELL-11:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL-11:actVoNrMobilityThresholds=VoNrMobilityThresholds
...    NRCELL-11:n310VoNR=n3
...    NRCELL-11:t310VoNR=500ms
...    NRCELL-11:emergencyCallLimServ=true
...    NRCELL-11:maxGBRTrafficLimit=80
...    NRCELL-11:arpPrioEmergencyCall=1
...    NRCELL-11:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL-11:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL-11:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-11:drxProfile1:drxLongCycle=40ms
...    NRCELL-11:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-11:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-11:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-11:drxProfile2:drxInactivityTimer=4ms
...    NRCELL-11:drxProfile2:drxLongCycle=40ms
...    NRCELL-11:drxProfile2:drxOnDurationTimer=4ms
...    NRCELL-11:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL-11:drxProfile2:drxRetransTimerUl=0slot
...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=1
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=56
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms40
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=55
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms40
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:lcrId=1
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:nrDcAllowed=false
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:scs=30 KHz
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:ssbFrequency=518910
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=3
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=30
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS-1/NRDRB-15:actDddsReduction=false
...    NRBTS-1/NRDRB-15:actLostPduFastRetx=false
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:dscp=46
...    NRBTS-1/NRDRB-15:durationThresDiscardDl=50
...    NRBTS-1/NRDRB-15:durationThresDiscardUl=50
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=500
...    NRBTS-1/NRDRB-15:volThresDiscardDl=100
...    NRBTS-1/NRDRB-15:volThresDiscardUl=100
...    NRBTS-1/NRDRB-15:discardTimer=100ms
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_PDCP:maxCidAllowed=4
...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-2:maxCidAllowed=4
...    NRBTS-1/NRDRB_MAC-4:lcgid=4
...    NRBTS-1/NRDRB_MAC-4:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-4:prioritisedBitRate=16kBps
...    NRBTS-1/NRDRB_MAC-4:schedulBSD=100ms

# The number of the RRCReestablishmentRequest with the reestablishmentCause of otherFailure
${RRC_REESTAB_OTHER_FAILURE_DU}    M55127C00503
# The number of successful RRC Reestablishment procedures when the reestablishmentCause is otherFailure
${REESTAB_ACC_OTHER_FAIL_DU}    M55127C00512
# The number of the RRCReestablishmentRequest with the reestablishmentCause of otherFailure
${RRC_REESTAB_OTHER_FAILURE}    M55124C00505
# The counter is updated when receiving the RRCReestablishmentComplete message when the reestablishmentCause is otherFailure
${REESTAB_ACC_OTHER_FAIL}    M55124C00512
# The number of RRC reconfiguration succeeded in RRC reestablishment procedure
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516
#The number of successful RRC Reestablishment procedures for VONR for all reestablishment causes
${REESTAB_ACC_VONR}    M55124C00518
# The number of admission controls triggered in CU by RRC reestablishment procedure
${REESTAB_ADMISSION_CTRL}    M55124C00519
# The number of RRC Re-establishment Request attempts for VONR for any cause RRC_REESTAB_ATT_VONR
${RRC_REESTAB_ATT_VONR}    M55124C00520
# This counter provides the number of RRC: RRC RECONFIGURATION messages sent from gNB-CU
${NRRCC_RRC_RECONF_SENT}    M55124C03001
# This counter provides the number of RRC: RRC RECONFIGURATION COMPLETE messages received at gNB-CU
${NRRCC_RRC_RECONF_CMP_RECD}    M55124C03002
# This counter provides the number of DL RRC Message Transfer sent to gNB-DU.
${NF1CC_DL_RRC_MSG_TRANSFER}    M55113C00501
# This counter provides the number of UL RRC Message Transfer received at gNB-CU.
${NF1CC_UL_RRC_MSG_TRANSFER}    M55113C00502
# Number of outgoing UE CONTEXT MODIFICATION REQUEST sent to gNB-DU
${F1_UE_CTXT_MOD_REQ_SENT}    M55113C00001
# Number OF UE CONTEXT MODIFICATION RESPONSE received from gNB-DU
${F1_UE_CTXT_MOD_RESP_RECEIVED}    M55113C00002
# This counter indicates the total number of E1AP Bearer Context Modification Request sent from gNB-CU-CP.
${NE1CS_CTXT_MOD_REQ_SENT}    M55135C00505
# This counter indicates the total number of E1AP Bearer Context Modification Response received at gNB-CU-CP
${NE1CS_CTXT_MOD_RSP_RECD}    M55135C00506
# The number of radio admission requests for SA user. Updated in the DU when RRC resources are requested
${SGNB_SA_DU_ADMISSION_REQ}    M55139C00001
# The number of admitted radio admission requests for SA user. Updated in the DU when RRC resources are admitted
${SGNB_SA_DU_ADMISSION_SUCC}    M55139C00002
# The number of non-GBR DRB radio admission requests for SA user in DU.
# Updated in DU whenever an admission is requested for a non-GBR DRB due to Initial Context Setup
# or PDU session addition or due to PDU session modification.
${SGNB_SA_DU_NGBR_DRB_REQ}    M55139C00003
# The number of non-GBR DRB successful radio admissions for SA user. Updated in DU whenever a request for a non-GBR DRB
# is successfully admitted in Initial Context Setup or PDU session addition or due to PDU session modification.
${SGNB_SA_DU_NGBR_DRB_SUCC}    M55139C00004
# The number of GBR DRB radio admission requests for SA user.
# Updated in DU whenever an admission is requested for a GBR DRB due to Initial Context Setup
# or PDU session addition or due to PDU session modification.
${SA_DU_GBR_DRB_REQ}    M55139C00501
# The number of GBR DRB successful radio admissions for SA user.
# Updated in DU whenever a request for a GBR DRB is successfully admitted in Initial Context Setup
# or PDU session addition or due to PDU session modification.
${SA_DU_GBR_DRB_SUCC}    M55139C00502
# The number of GBR DRB radio admission requests for SA user rejected due to lack of DRB capacity.
${SA_DU_GBR_REJ_LACK_DRB}    M55139C00503
# The number of GBR DRB radio admission requests for SA user rejected due to lack of radio resources for GBR
${SA_DU_GBR_LACK_RAD_RES}    M55139C00504
# The number of GBR DRB radio admission releases for SA user in DU, updated when SA user admitted resources are released.
${SA_DU_GBR_DRB_REL}    M55139C00509
# The average number of estimated available radio resources for 5QI-1 users.
# The counter counts resources per UE and is based defined cell level maximum GBR capacity and used capacity per UE
${AVE_AVAIL_SA_5QI1_GBR_RES}    M55139C00510
# Average number of available radio resources for 5QI-1 GBR users denominator
${AVE_AVAIL_SA_5QI1_GBR_RES_DEN}    M55139C00511
# Lowest peak number of available radio resources for 5QI-1 GBR users
${LOW_PEAK_SA_5QI1_GBR_RES}    M55139C00512
# Time when GBR radio resource usage exceeds the defined limit.
# Time started when load in the cell exceeds NRCELL.maxGBRTrafficLimit and stops when load <= NRCELL.maxGBRTrafficLimit.
${SA_GBR_RES_OVER_LIMIT_TIME}    M55139C00513
# Incremented when F1AP UE Context Modification Request is received by gNB-DU.
${F1_UE_CTXT_MOD_REQ_RECEIVED}    M55117C00001
# Incremented when F1AP UE Context Modification Response is sent by gNB-DU.
${F1_UE_CTXT_MOD_RESP_SENT}    M55117C00002
# This counter provides the number of DL RRC Message Transfer received at gNB-DU.
${NF1CD_DL_RRC_MSG_TRANSFER}    M55117C02001
# This counter provides the number of UL RRC Message Transfer sent to gNB-CU.
${NF1CD_UL_RRC_MSG_TRANSFER}    M55117C02002

@{PM_COUNTER_CHECK}
...    NRCELL-11:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-1:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-11:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-1:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-11:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-1:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-11:${REESTAB_ACC_VONR}=1
...    NRCELL-1:${REESTAB_ACC_VONR}=1
...    NRCELL-11:${RRC_REESTAB_ATT_VONR}=1
...    NRCELL-1:${RRC_REESTAB_ATT_VONR}=1
...    NRCELL-11:${REESTAB_ADMISSION_CTRL}=1
...    NRCELL-1:${REESTAB_ADMISSION_CTRL}=1
...    NRCELL-11:${NF1CC_DL_RRC_MSG_TRANSFER}=13
...    NRCELL-1:${NF1CC_DL_RRC_MSG_TRANSFER}=2
...    NRCELL-11:${NF1CC_UL_RRC_MSG_TRANSFER}=16
...    NRCELL-1:${NF1CC_UL_RRC_MSG_TRANSFER}=2
...    NRCELL-11:${F1_UE_CTXT_MOD_REQ_SENT}=17
...    NRCELL-1:${F1_UE_CTXT_MOD_REQ_SENT}=3
...    NRCELL-11:${F1_UE_CTXT_MOD_RESP_RECEIVED}=17
...    NRCELL-1:${F1_UE_CTXT_MOD_RESP_RECEIVED}=3
...    NRCELL-11:${NRRCC_RRC_RECONF_SENT}=6
...    NRCELL-1:${NRRCC_RRC_RECONF_SENT}=1
...    NRCELL-11:${NRRCC_RRC_RECONF_CMP_RECD}=6
...    NRCELL-1:${NRRCC_RRC_RECONF_CMP_RECD}=1
...    NRCELL-11:${SGNB_SA_DU_ADMISSION_REQ}=2
...    NRCELL-1:${SGNB_SA_DU_ADMISSION_REQ}=1
...    NRCELL-11:${SGNB_SA_DU_ADMISSION_SUCC}=2
...    NRCELL-1:${SGNB_SA_DU_ADMISSION_SUCC}=1
...    NRCELL-11:${SGNB_SA_DU_NGBR_DRB_REQ}=2
...    NRCELL-1:${SGNB_SA_DU_NGBR_DRB_REQ}=1
...    NRCELL-11:${SGNB_SA_DU_NGBR_DRB_SUCC}=2
...    NRCELL-1:${SGNB_SA_DU_NGBR_DRB_SUCC}=1
...    NRCELL-11:${SA_DU_GBR_DRB_REQ}=2
...    NRCELL-1:${SA_DU_GBR_DRB_REQ}=1
...    NRCELL-11:${SA_DU_GBR_DRB_SUCC}=2
...    NRCELL-1:${SA_DU_GBR_DRB_SUCC}=1
...    NRCELL-11:${SA_DU_GBR_REJ_LACK_DRB}=0
...    NRCELL-1:${SA_DU_GBR_REJ_LACK_DRB}=0
...    NRCELL-11:${SA_DU_GBR_LACK_RAD_RES}=0
...    NRCELL-1:${SA_DU_GBR_LACK_RAD_RES}=0
...    NRCELL-11:${SA_DU_GBR_DRB_REL}=2
...    NRCELL-1:${SA_DU_GBR_DRB_REL}=1
...    NRCELL-11:${AVE_AVAIL_SA_5QI1_GBR_RES}>0
...    NRCELL-1:${AVE_AVAIL_SA_5QI1_GBR_RES}>0
...    NRCELL-11:${AVE_AVAIL_SA_5QI1_GBR_RES_DEN}>0
...    NRCELL-1:${AVE_AVAIL_SA_5QI1_GBR_RES_DEN}>0
...    NRCELL-11:${LOW_PEAK_SA_5QI1_GBR_RES}>0
...    NRCELL-1:${LOW_PEAK_SA_5QI1_GBR_RES}>0
...    NRCELL-11:${SA_GBR_RES_OVER_LIMIT_TIME}=0
...    NRCELL-1:${SA_GBR_RES_OVER_LIMIT_TIME}=0
...    ${RRC_REESTAB_OTHER_FAILURE_DU}=2
...    ${REESTAB_ACC_OTHER_FAIL_DU}=2
...    ${NE1CS_CTXT_MOD_REQ_SENT}=9
...    ${NE1CS_CTXT_MOD_RSP_RECD}=9
...    ${F1_UE_CTXT_MOD_REQ_RECEIVED}=20
...    ${F1_UE_CTXT_MOD_RESP_SENT}=20
...    ${NF1CD_DL_RRC_MSG_TRANSFER}=15
...    ${NF1CD_UL_RRC_MSG_TRANSFER}=18

*** Test Cases ***
5GC000732-ET-F019_RRC_loop_reestablish_succ_with_784_to_non_Pcell_old_DRX_enabled_A2_configured_new_DRX_disabled_meas
    [Documentation]    This case will test RRC reestablish from 784(emergency call) DRX enabled A2_configured to
    ...    non Pcell DRX disabled with meas.
    ...    preconditions:
    ...        cell11 is FDD cell, enable DRX
    ...        cell1 is TDD cell, disable DRX
    ...    Case steps:
    ...        Step 1: Run the tcpdump with below commands:
    ...        tcpdump -i etha01 -w /tmp/test-1.pcap -vv
    ...        Expected Result: tcpdump is running to capture wireshark logs
    ...        Step 2: In egate, run below commands to attach to cell11:
    ...        ue_register id=81
    ...        Expected Result: UE registers successfully
    ...        Step 3: In egate, run commands to set ARP priority to 1 for both 5QI-1 and 5QI-5.
    ...        qosflow_modify qos_flow=2 priority=1
    ...        qosflow_modify qos_flow=3 priority=1
    ...        Expected Result: egate command executed successfully.
    ...        Step 4: In egate, run commands to do an emergency call to cell11 and setup DRB for 5QI-5:
    ...        ue_pdu_session_setup ue=81 pdu=1 nwslice=1 gw=11 request_type=initial-emergency-request
    ...        Expected Result: 5QI-5 in PDU session is setup successfully
    ...        Step 5: In egate, run commands to modify PDU session to setup DRB for 5QI-1.
    ...        ue_pdu_session_modify ue=81 pdu=1 qosflows_to_add=3 by=amf
    ...        Expected Result: 5QI-1 setup successfully.
    ...        Step 6:  In egate, run below commands to trigger RRC reestablishment request to cell1.
    ...        run egate command trigger RRC reestablishment to new cell1(ue_rrc_reestablish id=81 gnb=2 cell=1 cause=otherFailure)
    ...        Expected Result: RRC reestablish success, UE in RRC connected state.
    ...        Step 7:  In egate, run below commands to trigger RRC reestablishment request to cell11.
    ...        run egate command trigger RRC reestablishment to new cell1 (ue_rrc_reestablish id=81 gnb=2 cell=11 cause=otherFailure)
    ...        Expected Result: RRC reestablish success, UE in RRC connected state.
    ...        Step 8: In egate, run commands to trigger UE detach.
    ...        Expected Result: UE detach successfully.
    ...        Step 9: check DRX recovered during first reestablishment via pcap file:
    ...        Expected Result: DRX setup in first UE attach, and released during reestablishment,
    ...        then no DRX setup as set in cell1 in reconfiguration following reestablishment.
    ...        Step 10: check meas config during first reestablishment via pcap file:
    ...        Expected Result: A2 meas released during reestablishment and A3 meas configured as set in cell1 during reestablishment.
    ...        Step 11: check DRX recovered during second reestablishment via pcap file:
    ...        Expected Result: DRX setup as set in cell11 in reconfiguration following reestablishment.
    ...        Step 12: check meas config during second reestablishment via pcap file:
    ...        Expected Result: A3 meas released during reestablishment and A2 meas configured as set in cell11 during reestablishment.
    ...        Step 13: check counter in WebEM:
    ...        RRC_REESTAB_OTHER_FAILURE_DU:  (Counter ID: M55127C00503)
    ...        RRC_REESTAB_OTHER_FAILURE:  (Counter ID: M5512400505)
    ...        REESTAB_ACC_OTHER_FAIL_DU:  (Counter ID: M55127C00512)
    ...        REESTAB_ACC_OTHER_FAIL:  (Counter ID: M55124C00512)
    ...        REESTAB_RRCRECONFIG_SUCC: (Counter ID: M55124C00516)
    ...        REESTAB_ACC_VONR: (Counter ID: M55124C00518)
    ...        RRC_REESTAB_ATT_VONR: (Counter ID: M55124C00520)
    ...        REESTAB_ADMISSION_CRTL: (Counter ID: M55124C00519)
    ...        legacy A counter
    ...        EPmCounterId_5G_NF1CC_DL_RRC_MSG_TRANSFER: (Counter ID: M55113C00501)
    ...        EPmCounterId_5G_NF1CC_UL_RRC_MSG_TRANSFER: (Counter ID: M55113C00502)
    ...        EPmCounterId_5G_F1_UE_CTXT_MOD_REQ_SENT: (Counter ID: M55113C00001)
    ...        EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED: (Counter ID: M55113C00002)
    ...        EPmCounterId_5G_NRRCC_RRC_RECONF_SENT: (Counter ID: M55124C03001)
    ...        EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_RECD: (Counter ID: M55124C03002)
    ...        EPmCounterId_5G_NE1CS_CTXT_MOD_REQ_SENT: (Counter ID: M55135C00505)
    ...        EPmCounterId_5G_NE1CS_CTXT_MOD_RSP_RECD: (Counter ID: M55135C00506)
    ...        EPmCounterId_5G_SGNB_SA_DU_ADMISSION_REQ: (Counter ID: M55139C00001)
    ...        EPmCounterId_5G_SGNB_SA_DU_ADMISSION_SUCC: (Counter ID: M55139C00002)
    ...        EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REQ: (Counter ID: M55139C00003)
    ...        EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_SUCC: (Counter ID: M55139C00004)
    ...        EPmCounterId_5G_F1_UE_CTXT_MOD_REQ_RECEIVED: (Counter ID: M55117C00001)
    ...        EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_SENT: (Counter ID: M55117C00002)
    ...        EPmCounterId_5G_NF1CD_DL_RRC_MSG_TRANSFER: (Counter ID: M55117C02001)
    ...        EPmCounterId_5G_NF1CD_UL_RRC_MSG_TRANSFER: (Counter ID: M55117C02002)
    ...        legacy F counter
    ...        EPmCounterId_5G_SA_DU_GBR_DRB_REQ: (Counter ID: M55139C00501)
    ...        EPmCounterId_5G_SA_DU_GBR_DRB_SUCC: (Counter ID: M55139C00502)
    ...        EPmCounterId_5G_SA_DU_GBR_REJ_LACK_DRB: (Counter ID: M55139C00503)
    ...        EPmCounterId_5G_SA_DU_GBR_LACK_RAD_RES: (Counter ID: M55139C00504)
    ...        EPmCounterId_5G_SA_DU_GBR_DRB_REL: (Counter ID: M55139C00509)
    ...        EPmCounterId_5G_AVE_AVAIL_SA_5QI1_GBR_RES: (Counter ID: M55139C00510)
    ...        EPmCounterId_5G_AVE_AVAIL_SA_5QI1_GBR_RES_DEN: (Counter ID: M55139C00511)
    ...        EPmCounterId_5G_LOW_PEAK_SA_5QI1_GBR_RES: (Counter ID: M55139C00512)
    ...        EPmCounterId_5G_SA_GBR_RES_OVER_LIMIT_TIME: (Counter ID: M55139C00513)
    ...        Expected Result: all counters are increased.
    [Timeout]    60 min
    [Tags]    QC_157337
    Clear Counter Files    wait=${False}
    UE Attach To GNB2 Cell11
    Create Emergency Call and setup DRB for 5QI-5 and 5QI-1
    Send Traffic
    Trigger UE RRC Reestablish to Cell and Check Traffic    tgt_cell_id=1
    Trigger UE RRC Reestablish to Cell and Check Traffic    tgt_cell_id=11
    Stop Traffic and UE Detach
    Check Counters    ${PM_COUNTER_CHECK}
    Check Wireshark Log    ${CURDIR}/a2a_F019/a2a.ini    wait_string=UEContextReleaseComplete::4


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

UE Attach To GNB2 Cell11
    ${ret}    Execute Egate Command    ue_change_location id=81 enb=2 cell=11    pass_regexp=location
    Should Contain Any    ${ret}    location updated    already there
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=81     pass_regexp=Received REGISTRATION COMPLETE

Set Qosflow Priority as Scf
    Execute Egate Command    qosflow_modify qos_flow=2 priority=1
    Execute Egate Command    qosflow_modify qos_flow=3 priority=1
    Execute Egate Command    qosflow_disp    pass_regexp=Configured Qos Flows

Recover Qosflow Priority as Cfg
    Execute Egate Command    qosflow_modify qos_flow=2 priority=15
    Execute Egate Command    qosflow_modify qos_flow=3 priority=15
    Execute Egate Command    qosflow_disp    pass_regexp=Configured Qos Flows

Modify PDU session to add DRB for 5QI-1
    @{expect}    Create List    rrcReconfigurationComplete
    ...    Pdu Session Resource Modify Response Message
    ...    Added QosFlow with QFI:2 fiveQI:1
    ...    QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=81 pdu=1 qosflows_to_add=3 by=amf
    ...    pass_regexp=${expect}
    Execute Egate Command    ue_meas_cfg_disp id=81 meas_obj_type=nr
    ...     fail_regexp=no NR MEASUREMENT IDENTITIES

Create Emergency Call and setup DRB for 5QI-5 and 5QI-1
    Set Qosflow Priority as Scf
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    set_pdu_param ue=81 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=81 nwslice=1 gw=1 request_type=initial-emergency-request
    ...    pass_regexp=Initial Context Setup Successful
    Execute Egate Command    ue_meas_cfg_disp id=81 meas_obj_type=nr
    ...     fail_regexp=no NR MEASUREMENT IDENTITIES
    Modify PDU session to add DRB for 5QI-1
    Recover Qosflow Priority as Cfg

Send Traffic
    Execute Egate Command    trf_data_start ue=81 pdu=1 qfi=1 dir=dl mbps=70 trf_id=1
    ...                      pass_regexp=UE 81: UDP DL TRF
    Execute Egate Command    trf_data_start ue=81 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1
    ...                      pass_regexp=UE 81: UDP UL TRF


Trigger UE RRC Reestablish to Cell and Check Traffic
    [Arguments]    ${tgt_cell_id}
    Execute Egate Command    ue_rrc_reestablish id=81 gnb=2 cell=${tgt_cell_id} cause=otherFailure
    ...    pass_regexp=UE81: NR RRC Reestablishment sucessfully completed
    Execute Egate Command    ue_meas_cfg_disp id=81 meas_obj_type=nr
    ...     fail_regexp=no NR MEASUREMENT IDENTITIES
    Check Specific Ue State    81    ACTIVE
    ${enb_id}    ${cell_id}    Get UE Location    81
    Should Be Equal    ${enb_id}    2
    Should Be Equal    ${cell_id}    ${tgt_cell_id}
    Check Traffic

Stop Traffic and UE Detach
    Execute Egate Command    trf_data_stop ue=81    pass_regexp=Traffic was stopped
    Execute Egate Command    ue_deregister id=81 ue_deregister_type=switch_off    pass_regexp=UE81: detached

Check Traffic
    Sleep    15s    sleep for Tput stable
    ${ul_throuput}    Ap Get SA Throughput    ue_id=81    pdu=1    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${ul_throuput}/1000 > 66
    ${ul_throuput}    Ap Get SA Throughput    ue_id=81    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000 > 9

