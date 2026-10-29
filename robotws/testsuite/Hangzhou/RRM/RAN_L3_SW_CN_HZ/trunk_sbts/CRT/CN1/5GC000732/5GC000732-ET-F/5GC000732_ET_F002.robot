*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags      QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    CRT    SBTS00
...    owner-liupei.fang    owner-shelly.song    team-SG2    release-SBTS22R2    5GC000732
...    CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC000732_Base}
...    @{CELL_Base}

@{5GC000732_Base}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:timerXnDataFwdGuard=250
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS:actFdmScheduling=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true
...    MRBTS-1/NRBTS-1:timerXnDataFwdGuard=250
...    MRBTS-1/NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1:actRedirect=true
...    MRBTS-1/NRBTS-1:rrcReestabTypeSA=sameGNB
...    MRBTS-1/NRBTS-1:actFdmScheduling=true
...    MRBTS-1/NRBTS-1:cipherPrefL:nea0=8
...    MRBTS-1/NRBTS-1:cipherPrefL:nea1_128=0
...    MRBTS-1/NRBTS-1:cipherPrefL:nea2_128=0
...    MRBTS-1/NRBTS-1:cipherPrefL:nea3_128=0

@{CELL_Base}
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=25
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-11:actCDrx=true
...    NRCELL-11:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-11:drxProfile1:drxLongCycle=80ms
...    NRCELL-11:drxProfile1:drxOnDurationTimer=20ms
...    NRCELL-11:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-11:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:absThreshSsbRsrqConsolidation=1
...    NRCELL-11:sMeasConfigSsbRsrp=1
...    NRCELL-11:absThreshSsbRsrpConsolidation=1
...    NRCELL-11:pucchModeSelect=longPucch
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
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:lcrId=13
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:nrDcAllowed=false
...    NRCELL-12/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=25
...    NRCELL-12:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-12:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms0
...    NRCELL-12:actCDrx=false
...    NRCELL-12:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-12:drxProfile1:drxLongCycle=40ms
...    NRCELL-12:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-12:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-12:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-12:a2MeashoEnabledSA=none
...    NRCELL-12:a3MeasEnabled=rsrp
...    NRCELL-12:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-12:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12:absThreshSsbRsrqConsolidation=1
...    NRCELL-12:sMeasConfigSsbRsrp=1
...    NRCELL-12:absThreshSsbRsrpConsolidation=1
...    NRCELL-12:pucchModeSelect=longPucch
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:lcrId=11
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:nrDcAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
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

@{PM_Counters_Check}
...    NRDU-1:${RRC_REESTAB_OTHER_FAILURE_DU}=2
...    NRDU-1:${RRC_REESTAB_ACC_OTHER_FAIL_DU}=2
...    NRCELL-11:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-12:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-11:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-12:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-11:${REESTAB_ADMISSION_CRTL}=1
...    NRCELL-12:${REESTAB_ADMISSION_CRTL}=1
...    NRCELL-11:${EPmCounterId_5G_F1_UE_CTXT_MOD_REQ_SENT}=14
...    NRCELL-12:${EPmCounterId_5G_F1_UE_CTXT_MOD_REQ_SENT}=3
...    NRCELL-11:${EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED}=14
...    NRCELL-12:${EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED}=3
...    NRCELL-11:${EPmCounterId_5G_NF1CC_DL_RRC_MSG_TRANSFER}=12
...    NRCELL-12:${EPmCounterId_5G_NF1CC_DL_RRC_MSG_TRANSFER}=2
...    NRCELL-11:${EPmCounterId_5G_NF1CC_UL_RRC_MSG_TRANSFER}=14
...    NRCELL-12:${EPmCounterId_5G_NF1CC_UL_RRC_MSG_TRANSFER}=2
...    NRCELL-11:${EPmCounterId_5G_NRRCC_RRC_RECONF_SENT}=5
...    NRCELL-12:${EPmCounterId_5G_NRRCC_RRC_RECONF_SENT}=1
...    NRCELL-11:${EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_RECD}=5
...    NRCELL-12:${EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_RECD}=1
...    NRBTS-1:${EPmCounterId_5G_NE1CS_CTXT_MOD_REQ_SENT}=7
...    NRBTS-1:${EPmCounterId_5G_NE1CS_CTXT_MOD_RSP_RECD}=7
...    NRCELL-11:${UE_PCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL_SA}>0
...    NRCELL-11:${UE_SCELL_2_CONF_SCELL_DL_SA}=0
...    NRCELL-12:${UE_PCELL_2_CONF_SCELL_DL_SA}=0
...    NRCELL-13:${UE_SCELL_2_CONF_SCELL_DL_SA}=0


${RRC_REESTAB_OTHER_FAILURE_DU}    M55127C00503    #Number of RRC Re-establishment Request caused by other failure
${RRC_REESTAB_ACC_OTHER_FAIL_DU}    M55127C00512    #Number of accepted RRC Re-establishment when reestablishment cause is other failure
${RRC_REESTAB_OTHER_FAILURE}       M55124C00505    #Number of RRC Re-establishment Request caused by HO failure
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516    #Number of RRC reconfiguration successful in RRC reestablishment procedure
${REESTAB_ADMISSION_CRTL}    M55124C00519    #Number of admission control triggered in CU by RRC reestablishment procedure
${EPmCounterId_5G_F1_UE_CTXT_MOD_REQ_SENT}    M55113C00001    #Number of outgoing UE CONTEXT MODIFICATION REQUEST sent to gNB-DU
${EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED}    M55113C00002    #Number of incoming UE CONTEXT MODIFICATION RESPONSE received from gNB-DU
${EPmCounterId_5G_NF1CC_DL_RRC_MSG_TRANSFER}    M55113C00501    #Number of DL RRC Message Transfer sent.
${EPmCounterId_5G_NF1CC_UL_RRC_MSG_TRANSFER}    M55113C00502    #Number of UL RRC Message Transfer received.
${EPmCounterId_5G_NRRCC_RRC_RECONF_SENT}    M55124C03001    #Number of RRC RECONFIGURATION sent
${EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_RECD}    M55124C03002    #Number of RRC RECONFIGURATION COMPLETE received
${EPmCounterId_5G_NE1CS_CTXT_MOD_REQ_SENT}    M55135C00505    #Number of Bearer Context Modification Request sent by gNB-CU-CP
${EPmCounterId_5G_NE1CS_CTXT_MOD_RSP_RECD}    M55135C00506    #Number of Bearer Context Modification Response received at gNB-CU-CP
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
#Sum of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508
#Current number of PCell UEs with 2 configured SCells in DL in SA mode is calculated when sample timer expires.
${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001
# Current number of SCell UEs with 2 configured SCells in DL in SA mode is calculated when sample timer expires.
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002    # This counter indicates the number of samples taken to "user amount" counters

${ReconfigurationFailure}    otherFailure
${ue_id}    81
${gw_id}    2

*** Test Cases ***
5GC000732-ET-F002_RRC_loop_reestablish_succ_with_1390_blind_to_new_1167_blind_Pcell_old_DRX_enabled_with_A2_configured_new_DRX_disabled_704
    [Documentation]    This case will test RRC reestablish to ori_cell due to otherFailure with valid UE context
    ...    combine with A003 and F002 reestablish succeed with 1390 blind to new 1167 blind Pcell old DRX
    ...    enabled with Meas A2 configured new DRX disabled 704
    ...    preconditions:
    ...        1. configure F+T(cell 11+cell 1) for 1390 blind for orig cell with DRX,meas A1,A2,interfreq A3 config,No MGAP
    ...        2. configure FFF(cell 12+cell 13 +cell 11) for 1167 blind for new cell with non-DRX intrafreq A3 config,interrat configured
    ...    Limitation: 5GC000732 not support scell added after RRE with blind CA
    ...    Case steps:
    ...        1.Setup CA(FDD+TDD)(cell 11+ cell 1) successfully
    ...        2.Trigger normal call with cell 11, A2 config to UE ,drx setup
    ...        3.Trgger RRC reestablish from cell 11 to cell 12
    ...          result: source drx release,scell release
    ...        4.Trigger RRC reestablish from cell 12 to cell 11
    ...        5.check DRX ,A2 config
    ...        6.Check 732's counters:
    ...          M55127C00503(RRC_REESTAB_OTHER_FAILURE_DU),M55124C00505(RRC_REESTAB_OTHER_FAILURE),
    ...          M55127C00512(REESTAB_ACC_OTHER_FAIL_DU),M55124C00512(REESTAB_ACC_OTHER_FAIL),
    ...          M55124C00516(REESTAB_RRCRECONFIG_SUCC),M55124C00519(REESTAB_ADMISSION_CRTL)
    ...        7.check legacy counters:
    ...          M55113C00001(EPmCounterId_5G_F1_UE_CTXT_MOD_REQ_SENT), M55113C00002(EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED)
    ...        M55118C05507(EPmCounterId_5G_UE_PCELL_1_CONF_SCELL_DL_SA),M55118C05508(EPmCounterId_5G_UE_SCELL_1_CONF_SCELL_DL_SA),
    ...         M55118C07001(EPmCounterId_5G_UE_PCELL_2_CONF_SCELL_DL_SA),M55118C07002(EPmCounterId_5G_UE_SCELL_2_CONF_SCaELL_DL_SA)
    [Tags]    QC_142248    F002
    Clear Counter Files
    Ue Register And Pdu Session Setup At FDD Cell-11
    Start To Capture Wireshark Log    F00200
    Trigger RRC Reestablish with cause    12    ${ReconfigurationFailure}
    sleep    42    reason=wait finished
    Check Wireshark Log    ${CURDIR}${/}a2a_F002_00${/}a2a.ini    name=F00200    wait_string=UEContextModificationResponse::6
    Start To Capture Wireshark Log    F00201
    Trigger RRC Reestablish with cause    11    ${ReconfigurationFailure}
    Verify Throughput And Deregister    sleep_time=40s
    Check Counters    ${PM_Counters_Check}
    Check Wireshark Log    ${CURDIR}${/}a2a_F002_01${/}a2a.ini    name=F00201    wait_string=UEContextReleaseComplete::4
    [Teardown]    Common Test Teardown And Stop Capture Logs

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/L1B/6cells_2T4F

Ue_Deregister
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE CONTEXT RELEASE COMPLETE

Trigger RRC Reestablish with cause
    [Arguments]    ${cell_id}    ${cause}
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=${cause}
    ...    NR RRC Reestablishment sucessfully completed    timeout=20s

Ue Register And Pdu Session Setup At FDD Cell-11
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=11
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${gw_id} nwslice=1    pass_regexp=QoS Routing Table
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=70 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    pass_regexp=Started Uplink

Verify Throughput And Deregister
    [Documentation]    verify Tput in scell is not 0
    [Arguments]    ${Tput_dl}=60    ${Tput_ul}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    Ue_Deregister
