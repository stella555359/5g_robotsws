*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    CXT    RAN_5G    CRT_no_cloud    CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
...               owner-jolin.fan    team-SG2    release-SBTS22R2    5GC000732
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/L1B/6cells_2T4F

@{PARAMS_IN_SCF}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:timerXnDataFwdGuard=250
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:actPrachMultiplexing=true

...    NRCELL:actK1Opt=intra-gNB
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=25
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-11:actCDrx=true
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=3
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:scs=15 KHz
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:ssbFrequency=126750
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:lcrId=12
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:nrDcAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

${CA_SUPPORT_LIST}    SEPARATOR=,
...    ca_Fr1Tdd_Fdd_Sa
...    ca_Fr1Tdd_Any_Sa
...    ca_Fr1Tdd_Sa
...    ca_Fdd_Fr1Tdd_Sa
...    ca_Fdd_Any_Sa
...    ca_Fdd_Fdd

@{DELTA_PARAMS}
...    MRBTS-1/NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1:timerXnDataFwdGuard=250
...    MRBTS-1/NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2:actCDrx=true
...    NRCELL-2:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-2:drxProfile1:drxLongCycle=40ms
...    NRCELL-2:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-2:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-2:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11:actCDrx=true
...    NRCELL-11:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-11:drxProfile1:drxLongCycle=80ms
...    NRCELL-11:drxProfile1:drxOnDurationTimer=20ms
...    NRCELL-11:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-11:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:a3MeasEnabled=rsrp
...    NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12:actCDrx=true
...    NRCELL-12:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-12:drxProfile1:drxLongCycle=80ms
...    NRCELL-12:drxProfile1:drxOnDurationTimer=20ms
...    NRCELL-12:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-12:drxProfile1:drxRetransTimerUl=16slot

@{PM_COUNTER_CHECK}
...    ${RRC_REESTAB_OTHER_FAILURE_DU}=2
...    ${REESTAB_ACC_OTHER_FAIL_DU}=2
...    NRCELL-11:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-2:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-11:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-2:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-11:${REESTAB_ADMISSION_CTRL}=1
...    NRCELL-2:${REESTAB_ADMISSION_CTRL}=1
...    NRCELL-11:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-2:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-11:${NNGCC_UE_CTXT_REL_CMP_SENT}=1
...    NRCELL-11:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-2:${UE_PCELL_1_CONF_SCELL_DL_SA}>0


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
# Sum of CA UEs in the current cell configured as a PCell, which have 1 configured SCell in DL
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
# Sum of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508
# This counter indicates the total number of NGAP UE CONTEXT RELEASE COMPLETE sent from gNB
${NNGCC_UE_CTXT_REL_CMP_SENT}    M55125C00502

&{CELLS_CARRIER_FREQ}
...     1=518910
...     2=633216
...     11=424090
...     12=126750

*** Test Cases ***
5GC000732-ET-F003_RRC_loop_reestablish_succ_with_1390_blind_to_new_7922_meas_Pcell_old_DRX_enabled_with_A2_configured_new_DRX_enabled_no_meas
    [Documentation]    This case will test RRC reestablish to new_cell due to otherfailure with 1 drb.
    ...    preconditions:
    ...        1. configure F+T and T+T CA
    ...    Case steps:
    ...        1.Setup CA successfully
    ...        2.Trgger RRC reestablish to cell-2 successfully
    ...        3.Trgger RRC reestablish to cell-11 successfully
    ...        4.check cause otherFailure in rrcReestablishmentRequest wiresahrk msg
    ...          and DRB,SRB,cellgroup should be recovered
    ...        5.check counter
    ...          M55127C00503: RRC_REESTAB_OTHER_FAILURE_DU:If reestablishmentCause IE is otherFailure
    ...          M55124C00505: RRC_REESTAB_OTHER_FAILURE:If reestablishmentCause IE is otherFailure
    ...          M55127C00512: REESTAB_ACC_OTHER_FAIL_DU:If reestablishmentCause IE is otherFailure
    ...          M55124C00512: REESTAB_ACC_OTHER_FAIL:If reestablishmentCause IE is otherFailure
    ...          M55124C00516: REESTAB_RRCRECONFIG_SUCC:Number of RRC reconfiguration successful in RRC reestablishment procedure
    ...          M55124C00519: REESTAB_ADMISSION_CRTL:Number of admission control triggered in CU by RRC reestablishment procedure
    ...          M55125C00502: Number of UE CONTEXT RELEASE COMPLETE sent
    ...          M55118C05507: Sum of CA UEs in the current cell configured as a PCell, which have 1 configured SCell in DL
    ...          M55118C05508: Sum of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
    [Tags]    QC_157333
    [Timeout]     60 min
    Clear Counter Files    wait=${False}
    Delta Commission Parameters     ${DELTA_PARAMS}
    UE Attach To GNB2 Cell11 and Blindly Add Scell-1
    Reestablish from Cell_11 to Cell_2 and Check Traffic
    Reestablish from Cell_2 to Cell_11 and Check Traffic
    Stop Traffic and UE Detach
    Check Counters    ${PM_COUNTER_CHECK}
    Check Wireshark Log    ${CURDIR}/a2a_F003/a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
UE Attach To GNB2 Cell11 and Blindly Add Scell-1
    ${ret}    Execute Egate Command    ue_change_location id=81 enb=2 cell=11    pass_regexp=location
    Should Contain Any    ${ret}    location updated    already there
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=81     pass_regexp=Received REGISTRATION COMPLETE
    ${enb_id}    ${cell_id}    Get UE Location    81
    Should Be Equal    ${cell_id}    11
    Execute Egate Command    ue_meas_cfg_disp id=81 meas_obj_type=nr
    ...     fail_regexp=no NR MEASUREMENT IDENTITIES
    Add Scell-1 Blindly
    Send Traffic
    Check Traffic      cell_num=2    min_dl_tput=270    min_ul_tput=9

Add Scell-1 Blindly
    Start RRC Log      scell_blind_addition
    Execute Egate Command    set_pdu_param ue=81 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=81 nwslice=1 gw=1
    ...                      pass_regexp=SCellIndex 1 activated successfully
    Rrc Should Contain    sCellToAddModList    sCellIndex 1    physCellId 50
    Rrc Should Not Contain    sCellIndex 2
    Execute Egate Command    ue_meas_cfg_disp id=81 meas_obj_type=nr
    ...     fail_regexp=no NR MEASUREMENT IDENTITIES

Send Traffic
    Execute Egate Command    data_trf_start ue=81 pdu=1 dir=dl mbps=150 trf_id=1
    ...                      pass_regexp=UE81: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=81 pdu=1 dir=dl mbps=150 trf_id=2
    ...                      pass_regexp=UE81: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=81 pdu=1 dir=ul mbps=10 trf_id=1
    ...                      pass_regexp=UE81: Started Uplink Internal traffic

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

Trigger UE RRC Reestablish to Cell
    [Arguments]    ${tgt_cell_id}
    Execute Egate Command    ue_rrc_reestablish id=81 gnb=2 cell=${tgt_cell_id} cause=otherFailure
    ...    pass_regexp=UE81: NR RRC Reestablishment sucessfully completed
    Check Specific Ue State    81    ACTIVE
    ${enb_id}    ${cell_id}    Get UE Location    81
    Should Be Equal    ${enb_id}    2
    Should Be Equal    ${cell_id}    ${tgt_cell_id}
    Execute Egate Command    ue_meas_cfg_disp id=81 meas_obj_type=nr
    ...     fail_regexp=no NR MEASUREMENT IDENTITIES

Trigger Scell Addition by A1 Event
    [Arguments]    ${pcell_id}    ${scell_physCellId}
    Start RRC Log    scell_covA1_addition
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${pcell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    81    ${pcell_carrier_freq}    A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=81 meas_id=${meas_id} event=A1 srsrp_nr=112 srsrq_nr=80
    ...    pass_regexp=SCellIndex 1 activated successfully
    Rrc Should Contain    sCellToAddModList    sCellIndex 1    physCellId ${scell_physCellId}
    Rrc Should Not Contain    sCellIndex 2
    Execute Egate Command    ue_meas_cfg_disp id=81 meas_obj_type=nr
    ...     fail_regexp=no NR MEASUREMENT IDENTITIES

Reestablish from Cell_11 to Cell_2 and Check Traffic
    Trigger UE RRC Reestablish to Cell    tgt_cell_id=2
    Check Traffic    cell_num=1    min_dl_tput=270    min_ul_tput=9
    Trigger Scell Addition by A1 Event    pcell_id=2    scell_physCellId=50
    Check Traffic    cell_num=2    min_dl_tput=270    min_ul_tput=9

Reestablish from Cell_2 to Cell_11 and Check Traffic
    Trigger UE RRC Reestablish to Cell    tgt_cell_id=11
    Check Traffic    cell_num=1    min_dl_tput=60    min_ul_tput=9

Stop Traffic and UE Detach
    Execute Egate Command    trf_data_stop ue=81    pass_regexp=Traffic was stopped
    Execute Egate Command    ue_deregister id=81 ue_deregister_type=switch_off    pass_regexp=UE81: detached
