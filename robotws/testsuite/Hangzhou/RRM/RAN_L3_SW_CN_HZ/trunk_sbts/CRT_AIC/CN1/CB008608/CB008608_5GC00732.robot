*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_Aic    master_vDU    CRT    CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    owner-jianfen.shen    release-5G22R4    team-DevHZ5_SG02    vDUCNF00

Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/1du/2cell
${SA_UE_ID}    1
${carrierfreq_cell1}    636576
${carrierfreq_cell2}    633216
@{PARAMS_IN_SCF_CU}    @{5GC000732CU_full}
@{PARAMS_IN_SCF_DU1}    @{5GC000732DU_full}
@{5GC000732CU_full}
...    NRBTS-1:actGnbInitRlf=true
...    NRBTS-1:tRLFindForDUSA=2000ms
...    @{rrcReestab}
...    @{InterFreq_cu}
...    @{A1_Rsrp}
...    @{A2_Rsrp}
...    @{A3_Rsrp}
...    @{sec_algo}

@{rrcReestab}
...    NRBTS:rrcReestabTypeSA=sameGNB


@{InterFreq_cu}
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:tWaitingRlRecoverSA=4000ms
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS/NRCELL-1:chBw=60MHz
...    NRBTS/NRCELL-1:freqBandIndicatorNR=78
...    NRBTS/NRCELL-1:nrarfcn=636666
...    NRBTS/NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRBTS/NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRBTS/NRCELL-1/NRREL-1:gNbId=1
...    NRBTS/NRCELL-1/NRREL-1:gNbIdLength=22
...    NRBTS/NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRBTS/NRCELL-1/NRREL-1:lcrId=2
...    NRBTS/NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRBTS/NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRBTS/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRBTS/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRBTS/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRBTS/NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRBTS/NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRBTS/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRBTS/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS/NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRBTS/NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRBTS/NRCELL-1/NRHOIF-1:a4MeasEnDcSteeringEnabled=none
...    NRBTS/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRBTS/NRCELL-1/NRHOIF-1:scs=30 KHz
...    NRBTS/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRBTS/NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRBTS/NRCELL-1/NRHOIF-1:ssbFrequency=${carrierfreq_cell2}
...    NRBTS/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRBTS/NRCELL-2:chBw=50MHz
...    NRBTS/NRCELL-2:freqBandIndicatorNR=78
...    NRBTS/NRCELL-2:nrarfcn=633372
...    NRBTS/NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRBTS/NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRBTS/NRCELL-2/NRREL-1:gNbId=1
...    NRBTS/NRCELL-2/NRREL-1:gNbIdLength=22
...    NRBTS/NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRBTS/NRCELL-2/NRREL-1:lcrId=1
...    NRBTS/NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRBTS/NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRBTS/NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRBTS/NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRBTS/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRBTS/NRCELL-2/NRHOIF-1:a5MeasEnabled=none
...    NRBTS/NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRBTS/NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRBTS/NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS/NRCELL-2/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRBTS/NRCELL-2/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRBTS/NRCELL-2/NRHOIF-1:a4MeasEnDcSteeringEnabled=none
...    NRBTS/NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRBTS/NRCELL-2/NRHOIF-1:scs=30 KHz
...    NRBTS/NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRBTS/NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRBTS/NRCELL-2/NRHOIF-1:ssbFrequency=${carrierfreq_cell1}
...    NRBTS/NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp

@{A1_Rsrp}
...    NRBTS/NRCELL:a1MeashoEnabled=rsrp
...    NRBTS/NRCELL:a1MeashoEnabledSA=rsrp
...    NRBTS/NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRBTS/NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRBTS/NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRBTS/NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=${EMPTY}
...    NRBTS/NRCELL:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=${EMPTY}
...    NRBTS/NRCELL:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=${EMPTY}

@{A2_Rsrp}
...    NRBTS/NRCELL:a2MeashoEnabled=rsrp
...    NRBTS/NRCELL:a2MeashoEnabledSA=rsrp
...    NRBTS/NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRBTS/NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRBTS/NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRBTS/NRCELL:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=${EMPTY}
...    NRBTS/NRCELL:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=${EMPTY}
...    NRBTS/NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=${EMPTY}

@{A3_Rsrp}
...    NRBTS/NRCELL:a3MeasEnabled=rsrp
...    NRBTS/NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS/NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRBTS/NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRBTS/NRCELL:absThreshSsbRsrpConsolidation=1
...    NRBTS/NRCELL:filterCoeffSsbRsrp=fc4
...    NRBTS/NRCELL:sMeasConfigSsbRsrp=1

@{sec_algo}
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=0
...    NRBTS:integrityProtPrefL:nia3_128=9

@{5GC000732DU_full}
...    NRBTS-1:actGnbInitRlf=true
...    NRBTS-1:tRLFindForDUSA=2000ms
...    @{rsrp_du}
...    @{NRREL_du}
...    @{InterFreq_du}
...    @{MCS_du}

@{rsrp_du}
...    NRBTS/NRCELL:rsrpThresholdSSB=11

@{NRREL_du}
...    NRBTS/NRCELL/NRREL-1

@{InterFreq_du}
...    NRBTS/NRCELL-1:chBw=100MHz
...    NRBTS/NRCELL-1:freqBandIndicatorNR=78
...    NRBTS/NRCELL-1:nrarfcn=636666
...    NRBTS/NRCELL-1:gscnOrSsPbchArfcn=7880
...    NRBTS/NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRBTS/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS/NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRBTS/NRCELL-1/NRHOIF-1:ssbFrequency=${carrierfreq_cell2}
...    NRBTS/NRCELL-2:chBw=50MHz
...    NRBTS/NRCELL-2:freqBandIndicatorNR=78
...    NRBTS/NRCELL-2:nrarfcn=633372
...    NRBTS/NRCELL-2:gscnOrSsPbchArfcn=7845
...    NRBTS/NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRBTS/NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS/NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRBTS/NRCELL-2/NRHOIF-1:ssbFrequency=${carrierfreq_cell1}

@{MCS_du}
...    NRBTS/NRCELL:ullaDeltaSinrMax=30
...    NRBTS/NRCELL:ullaDeltaSinrMin=-300
...    NRBTS/NRCELL:actMcsPrbReductionFdmUl=false

###counter on CU
${REESTAB_ACC_RECONF_FAIL}    M55124C00510    #Number of accepted RRC Re-establishment when reestablishment cause is reconfiguration failure
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516    #Number of RRC reconfiguration successful in RRC reestablishment procedure
${NRRCC_RRC_RECONF_SENT}    M55124C03001    #Number of RRC RECONFIGURATION sent
${NRRCC_RRC_RECONF_CMP_RECD}    M55124C03002    #Number of RRC RECONFIGURATION COMPLETE received
@{PM_Counters_Check_CU}
...    NRCELL-1:NRRCC:${REESTAB_ACC_RECONF_FAIL}=0
...    NRCELL-2:NRRCC:${REESTAB_ACC_RECONF_FAIL}=2
...    NRCELL-1:NRRCC:${REESTAB_RRCRECONFIG_SUCC}=0
...    NRCELL-2:NRRCC:${REESTAB_RRCRECONFIG_SUCC}=2
...    NRCELL-1:NRRCC:${NRRCC_RRC_RECONF_SENT}=1
...    NRCELL-2:NRRCC:${NRRCC_RRC_RECONF_SENT}=4
...    NRCELL-1:NRRCC:${NRRCC_RRC_RECONF_CMP_RECD}=1
...    NRCELL-2:NRRCC:${NRRCC_RRC_RECONF_CMP_RECD}=4

###counter on DU
${RRC_REESTAB_RECONF_FAILURE_DU}    M55127C00501    #Number of RRC Re-establishment Request caused by reconfiguration failure
${REESTAB_ACC_RECONF_FAIL_DU}    M55127C00510    #Number of accepted RRC Re-establishment when reestablishment cause is reconfiguration failure
@{PM_Counters_Check_DU}
...    NRDU-1:NRRCD:${RRC_REESTAB_RECONF_FAILURE_DU}=2
...    NRDU-1:NRRCD:${REESTAB_ACC_RECONF_FAIL_DU}=2

*** Test Cases ***
5GC00732_F100_HO_success_after_RRC_reestablish
    [Documentation]
    ...    1. The purpose of this test case is to SA UE rrc reestablish to new cell can be successful
    ...         cell1:band=n78, nr_arfcn=636666, gscn=7880, ssbFrequency=636576, bandwith=100M
    ...         cell2:band=n78, nr_arfcn=633372, gscn=7845, ssbFrequency=633216, bandwith=50M
    ...    2. Test Case Steps:
    ...         a. Trigger Normal call to cell 1
    ...         b. Trgger RRC reestablish from cell 1 to cell 2
    ...         c. Trigger HO from cell 2 to cell 1
    ...         d. Trgger RRC reestablish from cell 1 to cell 2
    ...         e. Trigger HO from cell 2 to cell 1
    ...    3. Expected Results:
    ...         Step a: UE register to cell1 successfully and traffic OK
    ...         Step b: RRC reestablish successfully
    ...         Step c: HO should be succesffully
    ...         step d: RRC reestablish successfully
    ...         setp e: HO should be succesffully
    ...         check counters on CU: M55124C00510, M55124C00516, M55124C03001, M55124C03002
    ...         check counters on DU: M55127C00501, M55127C00510
    [Tags]    QC_190145
    Clear Counter Files
    UE Register To Cell1 Successfully And Traffic OK
    Trigger RRC Reestablishment To Cell2
    Tirgger Inter-Frequency Intra-DU HO From Cell2 To Cell1
    Trigger RRC Reestablishment To Cell2
    Tirgger Inter-Frequency Intra-DU HO From Cell2 To Cell1
    Release Ues    ue_id=${SA_UE_ID}    ue_type=sa
    Check WireShark Log Aic    a2a_ini_file=${CURDIR}/a2a_5GC000732/a2a.ini    wait_string=UEContextReleaseComplete::4
    Check Counters


*** Keywords ***
Modify Cfg Aic
    ${V_1}    catenate    set_cell id=1 gnb=2 pci=16:2 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    ${V_2}    catenate    set_cell id=2 gnb=2 pci=17:0 tac=280 nrci=0x02 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=633372:633372 gscn=7845 mandatory_for_activation=off
    Update Cfg Aic    ${V_1}
    Update Cfg Aic    ${V_2}
    Update Cfg Aic    ue_param id=${SA_UE_ID} ue_nr_capabilities=${SA_Capa_perUE_Full}

Clear Counter Files
    Clear Counter Files Cu Aic    wait=False
    Clear Counter Files Du Aic    wait=False

Check Counters
    Check Counters Cu Aic    ${PM_Counters_Check_CU}
    Check Counters Du Aic    pm_counters_expression=${PM_Counters_Check_DU}    wait=False

UE Register To Cell1 Successfully And Traffic OK
    SA UE Register And PDU Setup
    Send Throughput
    Verify Throughput

Send Throughput
    [Arguments]    ${ue_id}=${SA_UE_ID}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 protocol=udp mbps=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=2 protocol=udp mbps=5    UE ${ue_id}: UDP UL

Verify Throughput
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Throughput stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.6
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.6
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps

SA UE Register And PDU Setup
    [Arguments]    ${ue_id}=${SA_UE_ID}    ${pdu}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Registered
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=${nwslice} gw=1    QoS Routing Table

Trigger RRC Reestablishment To Cell2
    ${cmd}    Catenate    ue_rrc_reestablish id=${SA_UE_ID} gnb=2 cell=2 cause=reconfigurationFailure
    Execute Egate Command    ${cmd}    NR RRC Reestablishment sucessfully completed
    Verify Throughput

Tirgger Inter-Frequency Intra-DU HO From Cell2 To Cell1
    ${meas_id_a2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${SA_UE_ID}    carrierfreq=${carrierfreq_cell2}    event_type=A2
    ${cmd}    Catenate    ue_measurement_send_nr id=${SA_UE_ID} meas_id=${meas_id_a2} event=A2 srsrp_nr=7 srsrq_nr=7
    Execute Egate Command    ${cmd}    rrcReconfigurationComplete
    ${meas_id_a3}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${SA_UE_ID}    carrierfreq=${carrierfreq_cell1}    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id=${SA_UE_ID} meas_id=${meas_id_a3} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=50 nrsrp_nr=80 nrsrq_nr=20
    Execute Egate Command    ${cmd}    Intra-eNB handover
    Verify Throughput

