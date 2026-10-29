*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags      QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    CRT    SBTS00
...    owner-liupei.fang    owner-shelly.song    team-SG2    release-SBTS22R2    5GC000732
...    CLOUD_5G_I_BOO_AP_LOO
Resource    ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_2T4F

@{PARAMS_IN_SCF}
...    @{Switch_NRBTS}
...    @{DRB}
...    @{CELL11}


@{Switch_NRBTS}
...    NRBTS-1:rrcReestabTypeSA=sameGNB


@{CELL11}
...    NRCELL-11:actCDrx=true
...    NRCELL-11:actVoNR=true
...    NRCELL-11:actCDrxVoNR=true
...    NRCELL-11:actEnhancedVoNR=true
...    NRCELL-11:n310VoNR=n10
...    NRCELL-11:t310VoNR=100ms
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
...    NRCELL-11:maxGBRTrafficLimit=80
...    NRCELL-11:actGBRAdmissionControl=EnhancedVoNR

@{DRB}
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:dscp=46
...    NRBTS-1/NRDRB-15:l2OHFactorDl=16
...    NRBTS-1/NRDRB-15:l2OHFactorUl=35
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=500
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:actDddsReduction=false
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:actLostPduFastRetx=false
...    NRBTS-1/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS-1/NRDRB-15:durationThresDiscardDl=40
...    NRBTS-1/NRDRB-15:durationThresDiscardUl=20
...    NRBTS-1/NRDRB-15:volThresDiscardDl=8000
...    NRBTS-1/NRDRB-15:volThresDiscardUl=800
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:discardTimer=100ms
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-16:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-16:dscp=46
...    NRBTS-1/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS-1/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS-1/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-16:numSduDiscard=1
...    NRBTS-1/NRDRB-16:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS-1/NRDRB-16:queuingDelaySduDiscardThreshold=200
...    NRBTS-1/NRDRB-16:resType=nonGBR
...    NRBTS-1/NRDRB-16:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-16:sduDiscardIntervalTmr=100
...    NRBTS-1/NRDRB-16:schedulWeight=24
...    NRBTS-1/NRDRB-16:discardTimer=150ms
...    NRBTS-1/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS-1/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS-1/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-3:maxCidAllowed=4
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS-1/NRDRB_MAC-2:lcgid=2
...    NRBTS-1/NRDRB_MAC-2:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-4:lcgid=2
...    NRBTS-1/NRDRB_MAC-4:schedulPrio=4
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-3:prioritisedBitRate=16kBps
...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-2:maxCidAllowed=4
...    NRBTS-1/NRDRB_PDCP-1:maxCidAllowed=4
...    NRBTS-1/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS-1/NRDRB-10:resType=nonGBR
...    NRBTS-1/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS-1/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRBTS-1/NRDRB_5QI-7:fiveqiValueList=128
...    NRBTS-1/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15

@{PM_COUNTER_CHECK}
...    NRCELL-12:${RRC_REESTAB_OTHER_FAILURE}=2
...    NRCELL-12:${REESTAB_ACC_OTHER_FAIL}=0
...    NRCELL-12:${REESTAB_ADMISSION_CTRL}=0
...    NRCELL-12:${REESTAB_RRCRECONFIG_SUCC}=0
...    NRCELL-12:${SGNB_SA_DU_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_SA_DU_ADMISSION_SUCC}=2
...    NRCELL-12:${SGNB_SA_DU_NGBR_DRB_REQ}=0
...    NRCELL-12:${SGNB_SA_DU_NGBR_DRB_SUCC}=0
...    NRCELL-11:${SGNB_SA_DU_NGBR_DRB_REL}=1
...    NRCELL-12:${REESTAB_ACC_VONR}=0
...    NRCELL-12:${RRC_REESTAB_ATT_VONR}=1
...    NRCELL-11:${SA_DU_GBR_DRB_REQ}=1
...    NRCELL-11:${SA_DU_GBR_DRB_SUCC}=1
...    NRCELL-11:${SA_DU_GBR_DRB_REL}=1
...    ${RRC_REESTAB_OTHER_FAILURE_DU}=2
...    ${REESTAB_ACC_OTHER_FAIL_DU}=0
...    ${F1_UE_CTXT_MOD_FAIL_SENT}=0
...    ${NF1CD_DL_RRC_MSG_TRANSFER}=15
...    ${NF1CD_UECTXT_REL_CMDRECD}=2


# The number of the RRCReestablishmentRequest with the reestablishmentCause of otherFailure
${RRC_REESTAB_OTHER_FAILURE_DU}    M55127C00503
# The number of successful RRC Reestablishment procedures when the reestablishmentCause is otherFailure
${REESTAB_ACC_OTHER_FAIL_DU}    M55127C00512
# The number of the RRCReestablishmentRequest with the reestablishmentCause of otherFailure
${RRC_REESTAB_OTHER_FAILURE}    M55124C00505
# The counter is updated when receiving the RRCReestablishmentComplete message when the reestablishmentCause is otherFailure
${REESTAB_ACC_OTHER_FAIL}    M55124C00512
# The number of admission controls triggered in CU by RRC reestablishment procedure
${REESTAB_ADMISSION_CTRL}    M55124C00519
# The number of RRC reconfiguration succeeded in RRC reestablishment procedure
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516
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
#The number of non-GBR DRB radio admission releases for SA user in DU.
${SGNB_SA_DU_NGBR_DRB_REL}    M55139C00012
#The number of successful RRC Reestablishment procedures for VONR for all reestablishment causes
${REESTAB_ACC_VONR}    M55124C00518
#The number of RRC Re-establishment Request attempts for VONR for any cause RRC_REESTAB_ATT_VONR
${RRC_REESTAB_ATT_VONR}    M55124C00520
#The number of GBR DRB radio admission requests in DU for SA user.
${SA_DU_GBR_DRB_REQ}    M55139C00501
#The number of GBR DRB successful radio admissions for SA user.
${SA_DU_GBR_DRB_SUCC}    M55139C00502
#The number of GBR DRB radio admission releases for SA user in DU.
${SA_DU_GBR_DRB_REL}    M55139C00509

#Number of outgoing UE CONTEXT MODIFICATION FAILURE sent to gNB-CU
${F1_UE_CTXT_MOD_FAIL_SENT}    M55117C00003
#Number of DL RRC Message Transfer received.
${NF1CD_DL_RRC_MSG_TRANSFER}    M55117C02001
#Number of F1AP: UE Context Release Command messages received in gNB-DU
${NF1CD_UECTXT_REL_CMDRECD}    M55117C01009

${SA_UE_ID}    81

*** Test Cases ***
5GC000732-ET-F015_RRC_reestablish_fail_with_ori_6112_new_VONR_notsupported
    [Documentation]    This user scenario describes the behaviour, when a UE in RRC_CONNECTED re-establishes RRC Connection to the selected cell
    ...    (serving cell or the other cell) in serving gNB-DU with valid UE context interaction with VoNR or emergency call.
    ...    preconditions:
    ...        1. set NRCELL-11 actVoNR
    ...    Case steps:
    ...        1.UE register to cell-11 successfully
    ...        2.VONR Call set up successfully
    ...        3.Trgger RRC reestablish to new cell
    ...        3.RRC reestablish should fail
    ...        4.check cause otherFailure in rrcReestablishmentRequest wiresahrk msg and DRB,SRB
    ...        5.check counter
    ...          M55127C00503: RRC_REESTAB_OTHER_FAILURE_DU:If reestablishmentCause IE is otherFailure
    ...          M55124C00505: RRC_REESTAB_OTHER_FAILURE:If reestablishmentCause IE is otherFailure
    ...          M55127C00512: REESTAB_ACC_OTHER_FAIL_DU:If reestablishmentCause IE is otherFailure
    ...          M55124C00512: REESTAB_ACC_OTHER_FAIL:If reestablishmentCause IE is otherFailure
    ...          M55124C00516: REESTAB_RRCRECONFIG_SUCC:Number of RRC reconfiguration successful in RRC reestablishment procedure
    ...          M55124C00519: REESTAB_ADMISSION_CRTL:Number of admission control triggered in CU by RRC reestablishment procedure
    ...          M55139C00004: The number of radio admitted non-GBR DRBs for SA user in DU
    ...          M55117C01009: Number of F1AP: UE Context Release Command messages received in gNB-DU.
    ...          M55139C00012: The number of non-GBR DRB radio admission releases for SA user in DU
    ...          M55139C00501: The number of GBR DRB radio admission requests for SA user in DU.
    ...          M55139C00502: The number of GBR DRB successful radio admissions for SA user in DU.
    ...          M55124C00520: umber of RRC Re-establishment Request attempts for VONR for any cause RRC_REESTAB_ATT_VONR
    ...          M55124C00518: Number of accepted VONR RRC Re-establishment for all reestablishment causes
    [Tags]    QC_157335
    Clear Counter Files    wait=${False}
    Start VoNR Call To Cell_11 and Start Traffic
    Reestablish from Cell_11 to Cell_12 Failed
    Check Counters    ${PM_COUNTER_CHECK}
    Check Wireshark Log    ${CURDIR}/a2a_F015/a2a.ini    wait_string=UEContextReleaseComplete::8
    


*** Keywords ***
Modify Cfg
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=4

Start VoNR Call To Cell_11 and Start Traffic
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${pdu_id}=1
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    ${ret}    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=11    pass_regexp=location
    Should Contain Any    ${ret}    location updated    already there
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${pdu_id}
    ...                      pass_regexp=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=3 by=amf
    ...                      pass_regexp=QoS Routing Table
    Send Traffic    ${ue_id}    ${pdu_id}
    Check Traffic Without CA    ue_id=${ue_id}    min_dl_tput=67    min_ul_tput=9

Send Traffic
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${pdu_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=dl mbps=150 trf_id=1
    ...                      pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=ul mbps=10 trf_id=1
    ...                      pass_regexp=Started Uplink Internal traffic

Check Traffic Without CA
    [Arguments]    ${ue_id}     ${min_dl_tput}    ${min_ul_tput}
    Sleep    10s    sleep for Tput stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throuput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}

Reestablish from Cell_11 to Cell_12 Failed
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${tgt_cell_id}=12
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${tgt_cell_id} cause=otherFailure
    ...    pass_regexp=cause RAN not supported 5QI    fail_regexp=NR RRC Reestablishment sucessfully completed
    Builtin.sleep    5s
    Check Specific Ue State    ${ue_id}    OFF
    ${enb_id}    ${cell_id}    Get UE Location    ${ue_id}
    Should Be Equal    ${enb_id}    2
    Should Be Equal    ${cell_id}    ${tgt_cell_id}
