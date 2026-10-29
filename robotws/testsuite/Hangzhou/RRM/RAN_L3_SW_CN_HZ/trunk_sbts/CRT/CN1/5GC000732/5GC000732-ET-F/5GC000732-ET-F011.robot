*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags      QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT_no_cloud    CRT
...    owner-jolin.fan    team-SG2    release-SBTS22R2    5GC000732    CLOUD_5G_I_BOO_AP_LOO
Resource    ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_2T4F

@{PARAMS_IN_SCF}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:actFdmScheduling=true

...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:timerXnDataFwdGuard=250
...    NRBTS-1:actRohc=true
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
...    NRPMRNL-1:miNrRelReportCu=15min
...    @{NRCELL}
...    @{NRREL}
...    @{NRDRB}

${CA_SUPPORT_LIST}    SEPARATOR=,
...    ca_Fr1Tdd_Fdd_Sa
...    ca_Fr1Tdd_Any_Sa
...    ca_Fr1Tdd_Sa
...    ca_Fdd_Fr1Tdd_Sa
...    ca_Fdd_Any_Sa
...    ca_Fdd_Fdd

@{NRCELL}
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=25
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
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
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=1
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=36
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=40ms
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=100
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=1
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=40ms
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity


@{NRREL}
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:lcrId=1
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:nrDcAllowed=false
...    NRCELL-11/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3





@{NRDRB}
...    NRBTS-1/NRDRB_PDCP-1:maxCidAllowed=4
...    NRBTS-1/NRDRB_PDCP-2:maxCidAllowed=4
...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS-1/NRDRB-15:actDddsReduction=false
...    NRBTS-1/NRDRB-15:actLostPduFastRetx=false
...    NRBTS-1/NRDRB-15:discardTimer=100ms
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:dscp=46
...    NRBTS-1/NRDRB-15:durationThresDiscardDl=40
...    NRBTS-1/NRDRB-15:durationThresDiscardUl=20
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=500
...    NRBTS-1/NRDRB-15:volThresDiscardDl=8000
...    NRBTS-1/NRDRB-15:volThresDiscardUl=800
...    NRBTS-1/NRDRB_MAC-3:lcgid=4
...    NRBTS-1/NRDRB_MAC-3:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-3:prioritisedBitRate=16kBps


#Number of RRC Re-establishment Request caused by reconfiguration failure
${RRC_REESTAB_RECONF_FAILURE_DU}    M55127C00501
#Number of accepted RRC Re-establishment when reestablishment cause is reconfiguration failure
${REESTAB_ACC_RECONF_FAIL_DU}    M55127C00510
#Number of accepted RRC Re-establishment when reestablishment cause is reconfiguration failure
${REESTAB_ACC_RECONF_FAIL}    M55124C00510
#Number of RRC Re-establishment Request caused by reconfiguration failure
${RRC_REESTAB_RECONF_FAILURE}       M55124C00503
#The number of successful RRC Reestablishment procedures for VONR for all reestablishment causes
${REESTAB_ACC_VONR}    M55124C00518
#The number of RRC Re-establishment Request attempts for VONR for any cause RRC_REESTAB_ATT_VONR
${RRC_REESTAB_ATT_VONR}    M55124C00520
# Number of outgoing UE CONTEXT MODIFICATION REQUEST sent to gNB-DU
${F1_UE_CTXT_MOD_REQ_SENT}    M55113C00001
# Incremented when F1AP UE Context Modification Request is received by gNB-DU.
${F1_UE_CTXT_MOD_REQ_RECEIVED}    M55117C00001
#Number of BEARER CONTEXT RELEASE COMMAND sent
${NE1CS_CTXT_REL_CMD_SENT}     M55135C00001
#This counter indicates the total number of RRC Connection release messages sent from gNB-CU
${NRRCC_RRC_RELEASE_SENT}    M55124C00001
#This counter indicates the total number of RRC Connection release message sent from gNB-DU
${NRRCD_RRC_RELEASE_SENT}    M55127C01001
# Sum of CA UEs in the current cell configured as a PCell, which have 1 configured SCell in DL
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
# Sum of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508
# The counter can be used to calculate "average number of UEs"
${SAMPLES_UE_AMOUNTS}         M55118C01000

@{PM_COUNTER_CHECK}
...    ${RRC_REESTAB_RECONF_FAILURE_DU}=2
...    ${REESTAB_ACC_RECONF_FAIL_DU}=2
...    NRCELL-11:${REESTAB_ACC_RECONF_FAIL}=2
...    NRCELL-11:${RRC_REESTAB_RECONF_FAILURE}=2
...    NRCELL-11:${REESTAB_ACC_VONR}=2
...    NRCELL-11:${RRC_REESTAB_ATT_VONR}=2
...    NRCELL-11:${F1_UE_CTXT_MOD_REQ_SENT}=26
...    ${F1_UE_CTXT_MOD_REQ_RECEIVED}=26
...    NRCELL-11:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-11:${SAMPLES_UE_AMOUNTS}>0
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL_SA}>0
...    ${NE1CS_CTXT_REL_CMD_SENT}=1
#...    ${NRRCD_RRC_RELEASE_SENT}=1
...    ${NRRCC_RRC_RELEASE_SENT}=1

${UE_ID}    83


*** Test Cases ***
5GC000732-ET-F011_RRC_loop_reestablish_succ_with_6112_1390_blind_with_ROHC_to_ori_Pcell_DRX_enabled_without_meas
    [Documentation]    This case will test RRC reestablish to ori_cell due to reconfigfailure with 1 drb
    ...    preconditions:
    ...        1. configure F+T
    ...    Case steps:
    ...        1.Setup CA(FDD+TDD) & ROHC successfully
    ...        2.Trigger VoNR call on Cell-11
    ...        3.RRC reestablish should successfully (scell add limitation)
    ...        4.Trgger RRC reestablish to cell-11 second time successfully
    ...        5.check cause reconfigurationFailure in rrcReestablishmentRequest wiresahrk msg
    ...          and DRB,SRB,cellgroup should be recovered
    ...        6.check counter
    ...          M55127C00501:RRC_REESTAB_RECONF_FAILURE_DU
    ...          M55127C00510:REESTAB_ACC_RECONF_FAIL_DU
    ...          M55124C00503:RRC_REESTAB_RECONF_FAILURE
    ...          M55124C00510: REESTAB_ACC_RECONF_FAIL
    ...          M55124C00518: REESTAB_ACC_VONR
    ...          M55124C00520: RRC_REESTAB_ATT_VONR
    ...          M55135C00001: Number of BEARER CONTEXT RELEASE COMMAND sent
    ...          M55113C00001: Number of outgoing UE CONTEXT MODIFICATION REQUEST sent to gNB-DU
    ...          M55124C00001: Number of RRC RELEASE Messages sent
    ...          M55117C00001: Number of incoming UE CONTEXT MODIFICATION REQUEST received from gNB-CU
    ...          M55127C01001: Number of RRC RELEASE Messages sent
    ...          M55118C05507: Sum of CA UEs in the current cell configured as a PCell, which have 1 configured SCell in DL
    ...          M55118C05508: Sum of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
    ...          M55118C01000: When sample value is accumulated into "amount of UEs" counters
    [Tags]    QC_142251
    [Timeout]     60 min
    Clear Counter Files    wait=${False}
    UE Attach To GNB2 Cell11 and Blindly Add Scell-1
    Start VONR Call and Check Traffic
    Reestablish from Cell_11 to Self and Check Traffic    rrc_log_tag=reestablish_toself_1
    Reestablish from Cell_11 to Self and Check Traffic    rrc_log_tag=reestablish_toself_2
    Stop Traffic and UE Detach
    Check Counters    ${PM_COUNTER_CHECK}
    Check Wireshark Log    ${CURDIR}/a2a_F011/a2a.ini    wait_string=UEContextReleaseComplete::4

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

UE Attach To GNB2 Cell11 and Blindly Add Scell-1
    ${ret}    Execute Egate Command    ue_change_location id=${UE_ID} enb=2 cell=11    pass_regexp=location
    Should Contain Any    ${ret}    location updated    already there
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    ue_register id=${UE_ID}     pass_regexp=Received REGISTRATION COMPLETE
    ${enb_id}    ${cell_id}    Get UE Location    ${UE_ID}
    Should Be Equal    ${cell_id}    11
    Setup PDU Session and Add Scell-1 Blindly

Setup PDU Session and Add Scell-1 Blindly
    Start RRC Log      scell_blind_addition
    Execute Egate Command    set_pdu_param ue=${UE_ID} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${UE_ID} nwslice=1 gw=1
    ...                      pass_regexp=SCellIndex 1 activated successfully
    Rrc Should Contain    sCellToAddModList    sCellIndex 1    physCellId 50
    Rrc Should Not Contain    sCellIndex 2

Start VONR Call and Check Traffic
    Execute Egate Command    ue_pdu_session_modify ue=${UE_ID} pdu=1 qosflows_to_add=3 by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message
    Execute Egate Command    ue_meas_cfg_disp id=${UE_ID} meas_obj_type=nr
    ...     fail_regexp=no NR MEASUREMENT IDENTITIES
    Start Traffic
    Check Traffic    cell_num=2    min_dl_tput=180    min_ul_tput=9

Start Traffic
    Execute Egate Command    data_trf_start ue=${UE_ID} pdu=1 dir=dl mbps=100 trf_id=1
    ...                      pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${UE_ID} pdu=1 dir=dl mbps=100 trf_id=2
    ...                      pass_regexp=Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${UE_ID} pdu=1 dir=ul mbps=10 trf_id=1
    ...                      pass_regexp=Started Uplink Internal traffic

Check Traffic
    [Arguments]     ${cell_num}    ${min_dl_tput}    ${min_ul_tput}
    Sleep    15s    sleep for Tput stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${UE_ID}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${UE_ID}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${UE_ID}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 0
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}

Trigger UE RRC Reestablish to Cell
    [Arguments]    ${tgt_cell_id}
    Execute Egate Command    ue_rrc_reestablish id=${UE_ID} gnb=2 cell=${tgt_cell_id} cause=reconfigurationFailure
    ...    pass_regexp=UE${UE_ID}: NR RRC Reestablishment sucessfully completed
    Check Specific Ue State    ${UE_ID}    ACTIVE
    ${enb_id}    ${cell_id}    Get UE Location    ${UE_ID}
    Should Be Equal    ${enb_id}    2
    Should Be Equal    ${cell_id}    ${tgt_cell_id}

Reestablish from Cell_11 to Self and Check Traffic
    [Arguments]    ${rrc_log_tag}
    Start RRC Log    ${rrc_log_tag}
    Trigger UE RRC Reestablish to Cell    tgt_cell_id=11
    Rrc Should Not Contain    sCellToAddModList
    Check Traffic    cell_num=1    min_dl_tput=60    min_ul_tput=9

Stop Traffic and UE Detach
    Execute Egate Command    trf_data_stop ue=${UE_ID}    pass_regexp=Traffic was stopped
    Execute Egate Command    ue_deregister id=${UE_ID} ue_deregister_type=switch_off    pass_regexp=UE${UE_ID}: detached
