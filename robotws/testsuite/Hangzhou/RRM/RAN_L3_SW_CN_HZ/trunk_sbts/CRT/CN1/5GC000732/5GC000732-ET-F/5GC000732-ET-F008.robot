*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags      QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    CRT    SBTS00
...    owner-jia.pan    owner-teana.wang    team-SG2    release-SBTS22R2    5GC000732
...    CLOUD_5G_I_BOO_AP_LOO
Resource    ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_2T4F

${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actHoOptimizationCa=true
...    NRBTS-1:actRedirect=true
...    NRBTS-1:timerXnDataFwdGuard=250
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL:actPrachMultiplexing=true
...    NRCELL-1:actCDrx=true
...    NRCELL-1:drxProfile1:drxInactivityTimer=10ms
...    NRCELL-1:drxProfile1:drxLongCycle=40ms
...    NRCELL-1:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-1:drxProfile1:drxRetransTimerDl=0slot
...    NRCELL-1:drxProfile1:drxRetransTimerUl=0slot
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=35
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=1
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=36
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=40ms
...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=25
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=1
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=32
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=33
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=480ms
...    NRCELL-11:a3MeasEnabled=rsrp
...    NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-11:a5MeasEnabled=rsrp
...    NRCELL-11:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-11:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-11:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-11:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-11:a2MeasRedirectEnabled=rsrp
...    NRCELL-11:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL-11:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-11:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL-11/NRREDRT-0:redirFreqNr=518910
...    NRCELL-11/NRREDRT-0:redirPrio=1
...    NRCELL-11/NRREDRT-0:redirRat=nr
...    NRCELL-11/NRREDRT-0:redirSsbScs=30 KHz
...    NRCELL-12:actK1Opt=intra-gNB
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=2
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:msg1FrequencyStart=9
...    NRCELL-12:msg1FrequencyStart=12
...    NRCELL-13:msg1FrequencyStart=11
...    NRCELL-14:msg1FrequencyStart=13
...    NRCELL-11:absThreshSsbRsrpConsolidation=1
...    NRCELL-11:filterCoeffSsbRsrp=fc4
...    NRCELL-11:sMeasConfigSsbRsrp=1
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    @{CELL_NRREL}
...    @{CELL_NRHOIF}
...    @{8311_enable}

@{8311_enable}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=10
...    NRCELL:dlSCellConfigLevelNum=20
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=ms1280

@{CELL_NRREL}
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:lcrId=12
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:lcrId=1
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-10:sCellOperationalMode=dlOnly

@{CELL_NRHOIF}
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
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=20
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=60
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=110
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms5120
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=true

@{PM_COUNTER_CHECK}
...    NRCELL-11:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-1:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-11:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-1:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-11:${REESTAB_ADMISSION_CTRL}=1
...    NRCELL-1:${REESTAB_ADMISSION_CTRL}=1
...    NRCELL-11:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-1:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-11:${NF1CC_DL_RRC_MSG_TRANSFER}=3
...    NRCELL-1:${NF1CC_DL_RRC_MSG_TRANSFER}=13
...    NRCELL-11:${NF1CC_UL_RRC_MSG_TRANSFER}=3
...    NRCELL-1:${NF1CC_UL_RRC_MSG_TRANSFER}=16
...    NRCELL-11:${F1_UE_CTXT_MOD_REQ_SENT}=6
...    NRCELL-1:${F1_UE_CTXT_MOD_REQ_SENT}=17
...    NRCELL-11:${F1_UE_CTXT_MOD_RESP_RECEIVED}=6
...    NRCELL-1:${F1_UE_CTXT_MOD_RESP_RECEIVED}=17
...    NRCELL-11:${NRRCC_RRC_RECONF_SENT}=2
...    NRCELL-1:${NRRCC_RRC_RECONF_SENT}=6
...    NRCELL-11:${NRRCC_RRC_RECONF_CMP_RECD}=2
...    NRCELL-1:${NRRCC_RRC_RECONF_CMP_RECD}=6
...    NRCELL-11:${SGNB_SA_DU_ADMISSION_REQ}=1
...    NRCELL-1:${SGNB_SA_DU_ADMISSION_REQ}=2
...    NRCELL-11:${SGNB_SA_DU_ADMISSION_SUCC}=1
...    NRCELL-1:${SGNB_SA_DU_ADMISSION_SUCC}=2
...    NRCELL-11:${SGNB_SA_DU_NGBR_DRB_REQ}=1
...    NRCELL-1:${SGNB_SA_DU_NGBR_DRB_REQ}=2
...    NRCELL-11:${SGNB_SA_DU_NGBR_DRB_SUCC}=1
...    NRCELL-1:${SGNB_SA_DU_NGBR_DRB_SUCC}=2
...    NRCELL-11:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-12:${UE_SCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-11:${UE_PCELL_2_CONF_SCELL_DL_SA}=0
...    NRCELL-1:${UE_PCELL_2_CONF_SCELL_DL_SA}=0
...    NRCELL-12:${UE_SCELL_2_CONF_SCELL_DL_SA}=0
...    NRCELL-1:${UE_SCELL_2_CONF_SCELL_DL_SA}=0
...    NRCELL-12:${SAMPLES_UE_AMOUNTS}>0
...    NRCELL-11:${SAMPLES_UE_AMOUNTS}>0
...    NRCELL-1:${SAMPLES_UE_AMOUNTS}>0
...    ${RRC_REESTAB_OTHER_FAILURE_DU}=2
...    ${REESTAB_ACC_OTHER_FAIL_DU}=2
...    ${NE1CS_CTXT_MOD_REQ_SENT}=7
...    ${NE1CS_CTXT_MOD_RSP_RECD}=7
...    ${F1_UE_CTXT_MOD_REQ_RECEIVED}=23
...    ${F1_UE_CTXT_MOD_RESP_SENT}=23
...    ${NF1CD_DL_RRC_MSG_TRANSFER}=16
...    ${NF1CD_UL_RRC_MSG_TRANSFER}=19

@{CELL_1_M55118C05507}
...    NRCELL-1:${UE_PCELL_1_CONF_SCELL_DL_SA}


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
# Incremented when F1AP UE Context Modification Request is received by gNB-DU.
${F1_UE_CTXT_MOD_REQ_RECEIVED}    M55117C00001
# Incremented when F1AP UE Context Modification Response is sent by gNB-DU.
${F1_UE_CTXT_MOD_RESP_SENT}    M55117C00002
# This counter provides the number of DL RRC Message Transfer received at gNB-DU.
${NF1CD_DL_RRC_MSG_TRANSFER}    M55117C02001
# This counter provides the number of UL RRC Message Transfer sent to gNB-CU.
${NF1CD_UL_RRC_MSG_TRANSFER}    M55117C02002
# Sum of CA UEs in the current cell configured as a PCell, which have 1 configured SCell in DL
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
# Sum of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508
# Current number of PCell UEs with 2 configured SCells in DL in SA mode is calculated when sample timer expires.
${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001
# Current number of SCell UEs with 2 configured SCells in DL in SA mode is calculated when sample timer expires.
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002
# This counter indicates the number of samples taken to "user amount" counters.
# The counter can be used to calculate "average number of UEs"
${SAMPLES_UE_AMOUNTS}            M55118C01000

&{CELLS_CARRIER_FREQ}
...     1=518910
...     11=424090
...     12=126750


*** Test Cases ***
5GC000732-ET-F008_RRC_loop_reestablish_succ_with_2329_meas_to_new_1390_meas_Pcell_old_DRX_enabled_no_meas_new_DRX_disabled
    [Documentation]    This case will test RRC reestablish from T+F CA Pcell DRX enabled no meas to
    ...    F+T CA Pcell DRX disabled with meas.
    ...    preconditions:
    ...        cell1 is TDD cell, enable DRX
    ...        cell12 is FDD cell
    ...        cell11 is FDD cell, no DRX configured
    ...        cell12 has been configured as scell for cell1
    ...        cell1 has been configured as scell for cell11
    ...    Case steps:
    ...        Step 1: In egate, run below commands to attach to cell1:
    ...        ue_register id=81
    ...        Expected Result: UE registers successfully
    ...        Step 2: In egate, run below commands to setup pdu session:
    ...        ue_pdu_session_setup pdu=1 gw=1 ue=81
    ...        Expected Result: PDU session is setup successfully
    ...        Step 3: In egate, run commands to trigger A1 MR reported by UE.
    ...        Expected Result: A1 MR reported to gNB, scell(cell12) added to Pcell (cell1), A1 meas for scell addition been
    ...        removed, A2 meas for scell release been added.
    ...        Step 4: In egate, run commands to start DL/UL traffic.
    ...        Expected Result: DL/UL traffic are transferred without loss.
    ...        Step 5:  In egate, run below commands to trigger RRC reestablishment request to cell11:
    ...        Run egate command trigger RRC reestablishment to new cell11 (ue_rrc_reestablish id=81 gnb=2 cell=11
    ...        cause=otherFailure)
    ...        Expected Result: RRC reestablish success, UE in RRC connected state.
    ...        Step 6: In egate, run commands to check DL/UL traffic after reestablishment.
    ...        Expected Result: DL/UL traffic are still transferred without loss.
    ...        Step 7: In egate, run commands to trigger A1 MR reported by UE.
    ...        Expected Result: A1 MR reported to gNB, scell(cell1) added to Pcell (cell11), A1 meas for scell addition been
    ...        removed, A2 meas for scell release been added.
    ...        Step 8:  In egate, run below commands to trigger RRC reestablishment request to cell1:
    ...        run egate command trigger RRC reestablishment to cell1 (ue_rrc_reestablish id=81 gnb=2 cell=1
    ...        cause=otherFailure)
    ...        Expected Result: RRC reestablish success, UE in RRC connected state.
    ...        Step 9: In egate, run commands to check DL/UL traffic after reestablishment.
    ...        Expected Result: DL/UL traffic are still transferred without loss.
    ...        Step 10:  In egate, run below commands to trigger RRC reestablishment request to a non-serving cell3:
    ...        run egate command trigger RRC reestablishment to cell3 (ue_rrc_reestablish id=81 gnb=2 cell=1
    ...        cause=handoverFailure)
    ...        Expected Result: RRC reestablish failed, RRC connection release, then UE in IDLE state. And the counter M55118C05507
    ...        of cell-1 should not be increased.
    ...        Step 11: check counters
    ...        RRC_REESTAB_OTHER_FAILURE_DU:  If reestablishmentCause IE is otherFailure (Counter ID: M55127C00503)
    ...        RRC_REESTAB_OTHER_FAILURE:  If reestablishmentCause IE is otherFailure (Counter ID: M5512400505)
    ...        REESTAB_ACC_OTHER_FAIL_DU:  If reestablishmentCause IE is otherFailure (Counter ID: M55127C00512)
    ...        REESTAB_ACC_OTHER_FAIL:  If reestablishmentCause IE is otherFailure (Counter ID: M55124C00512)
    ...        REESTAB_RRCRECONFIG_SUCC: Number of RRC reconfiguration successful in RRC reestablishment procedure
    ...        (Counter ID: M55124C00516)
    ...        REESTAB_ADMISSION_CRTL: (Counter ID: M55124C00519)
    ...        Expected Result: counters should be correct.
    ...        Step 12: In egate, run commands to stop DL/UL traffic. And run commands to trigger UE detach.
    ...        Expected Result: traffic be stopped. And UE detach successfully.
    ...        Step 13: check scell addtion in first UE attach and no scell addition during first reestablishment via
    ...        pcap file(RRC/F1AP/E1AP message):
    ...        Expected Result: scell added in first UE attach, and scell related A1 meas been configured during
    ...        reestablishment, orig scell related resource shall be released.
    ...        Step 14: check DRX recovered during first reestablishment via pcap file:
    ...        Expected Result: DRX released and then no DRX setup in cell1 during reestablishment.
    ...        Step 15: check meas config during first reestablishment via pcap file:
    ...        Expected Result: A2 meas config for inter freq will be configured as set in cell1 during reestablishment.
    ...        Step 16: check scell addtion during second reestablishment via pcap file(RRC/F1AP/E1AP message):
    ...        Expected Result: scell related A1 meas been configured during reestablishment, orig scell related resource
    ...        shall be released.
    ...        Step 17: check DRX recovered during second reestablishment via pcap file:
    ...        Expected Result: no DRX setup before reestablishment, and then DRX setup as set in cell1 reconfiguration
    ...        following reestablishment.
    ...        Step 18: check meas config during second reestablishment via pcap file:
    ...        Expected Result: A2 meas config for inter freq will be released and no meas configured during reestablishment.
    [Tags]    QC_142250
    Clear Counter Files
    UE Attach To GNB2 Cell1 and Start Traffic
    Add Scell_12 and Check Traffic
    Reestablish from Cell_1 to Cell_11 and Scell added blindly
    Reestablish from Cell_11 to Cell_1 and Check Traffic
    Reestablish from Cell_1 to Cell_3 and Should Be Failed
    ${counters_value}     Get Counters Value     ${CELL_1_M55118C05507}
    Append To List    ${PM_COUNTER_CHECK}    NRCELL-1:${UE_PCELL_1_CONF_SCELL_DL_SA}=${counters_value[0]}
    Check Counters    ${PM_COUNTER_CHECK}
    Stop Traffic and UE Detach
    Check Wireshark Log    ${CURDIR}/a2a_F008/a2a.ini    wait_string=UEContextReleaseComplete::6


*** Keywords ***
UE Attach To GNB2 Cell1 and Start Traffic
    ${ret}    Execute Egate Command    ue_change_location id=81 enb=2 cell=1    pass_regexp=location
    Should Contain Any    ${ret}    location updated    already there
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=81     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=81 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=81 nwslice=1 gw=1
    ...                      pass_regexp=QoS Routing Table
    Send Traffic

Send Traffic
    Execute Egate Command    data_trf_start ue=81 pdu=1 dir=dl mbps=150 trf_id=1
    ...                      pass_regexp=UE 81: UDP DL TRF
    Execute Egate Command    data_trf_start ue=81 pdu=1 dir=dl mbps=150 trf_id=2
    ...                      pass_regexp=UE 81: UDP DL TRF
    Execute Egate Command    data_trf_start ue=81 pdu=1 dir=dl mbps=150 trf_id=3
    ...                      pass_regexp=UE 81: UDP DL TRF
    Execute Egate Command    data_trf_start ue=81 pdu=1 dir=dl mbps=150 trf_id=4
    ...                      pass_regexp=UE 81: UDP DL TRF
    Execute Egate Command    data_trf_start ue=81 pdu=1 dir=ul mbps=10 trf_id=1
    ...                      pass_regexp=UE 81: UDP UL TRF

Stop Traffic and UE Detach
    Execute Egate Command    trf_data_stop ue=81    pass_regexp=Traffic was stopped
    Execute Egate Command    ue_deregister id=81 ue_deregister_type=switch_off    pass_regexp=UE81: detached

Check Traffic
    [Arguments]     ${cell_num}    ${min_dl_tput}    ${min_ul_tput}
    Sleep    15s    sleep for Tput stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=81    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throuput}    Ap Get SA Throughput    ue_id=81    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    81    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 0
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}

Trigger Scell Addition by A1 Event
    [Arguments]    ${pcell_id}    ${scell_physCellId}
    Start RRC Log    scell_addition
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${pcell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    81    ${pcell_carrier_freq}    A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=81 meas_id=${meas_id} event=A1 srsrp_nr=112 srsrq_nr=80
    ...    pass_regexp=SCellIndex 1 activated successfully
    Rrc Should Contain    sCellToAddModList    sCellIndex 1    physCellId ${scell_physCellId}
    Rrc Should Not Contain    sCellIndex 2

Trigger UE RRC Reestablish to Cell
    [Arguments]    ${tgt_cell_id}=1    ${pass_check}=UE81: NR RRC Reestablishment sucessfully completed
    Execute Egate Command    ue_rrc_reestablish id=81 gnb=2 cell=${tgt_cell_id} cause=otherFailure
    ...    pass_regexp=${pass_check}
    Check Specific Ue State    81    ACTIVE
    ${enb_id}    ${cell_id}    Get UE Location    81
    Should Be Equal    ${enb_id}    2
    Should Be Equal    ${cell_id}    ${tgt_cell_id}

Reestablish from Cell_1 to Cell_3 and Should Be Failed
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=81 gnb=2 cell=3 cause=handoverFailure
	...    pass_regexp=UE81: RRC Reestablishment failed. Releasing RRC connection.    timeout=20s
    Check Specific UE State    81    IDLE

Add Scell_12 and Check Traffic
    Trigger Scell Addition by A1 Event    pcell_id=1    scell_physCellId=61
    Check Traffic    cell_num=2    min_dl_tput=400    min_ul_tput=9

Reestablish from Cell_1 to Cell_11 and Scell added blindly
    @{reestablish_and_scell_add_success}    create list
    ...    UE81: NR RRC Reestablishment sucessfully completed
    ...    sCellToAddModList
    ...    pcid:50, scellIdx:1
    ...    SCellIndex 1 activated successfully
    Trigger UE RRC Reestablish to Cell    tgt_cell_id=11    pass_check=${reestablish_and_scell_add_success}
    Check Traffic    cell_num=2    min_dl_tput=375    min_ul_tput=9

Reestablish from Cell_11 to Cell_1 and Check Traffic
    Trigger UE RRC Reestablish to Cell    tgt_cell_id=1
    Check Traffic    cell_num=1    min_dl_tput=370    min_ul_tput=9
    Trigger Scell Addition by A1 Event    pcell_id=1    scell_physCellId=61
    Check Traffic    cell_num=2    min_dl_tput=400    min_ul_tput=9