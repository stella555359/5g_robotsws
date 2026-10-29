*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Blues_SGT&A    owner-zora.wang
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB008311    release-5G23R3    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{same frequency}
...    @{NRREL}
...    @{8290_enable}
...    @{HO_related}
...    @{8311_enable}
...    @{A2pcellswitch}

@{HO_related}
...    NRBTS-1:srb3SupportEnabled=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:absThreshSsbRsrpConsolidation=0
...    NRCELL:sMeasConfigSsbRsrp=10

@{NRREL}
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:sCellPrio=1
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=1
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:lcrId=4
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-4:sCellPrio=2
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=1
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:lcrId=3
...    NRCELL-11/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly

@{A2pcellswitch}
...    NRCELL:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=111
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=1
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:scs=15 KHz
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=125050
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=122
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=2
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1

@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=infinity
...    NRCELL:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=85
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=75
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2ThresholdSCellRelSsbRsrp=34|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-1:weightForSCellSelection=70
...    NRCELL-2:weightForSCellSelection=70
...    NRCELL-3:weightForSCellSelection=60
...    NRCELL-4:weightForSCellSelection=60
...    NRCELL-11:weightForSCellSelection=40
...    NRCELL-12:weightForSCellSelection=40
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Any_Sa

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-1:chBw=80MHz
...    MRBTS-1/NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=7840
...    MRBTS-1/NRBTS-1/NRCELL-2:nrarfcn=633000
...    MRBTS-1/NRBTS-1/NRCELL-2:chBw=80MHz
...    MRBTS-1/NRBTS-1/NRCELL-2:type0CoresetConfigurationIndex=12
...    MRBTS-1/NRBTS-1/NRCELL-12:gscnOrSsPbchArfcn=1562
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnDl=124900
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnUl=134100
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12:type0CoresetConfigurationIndex=7

@{8311_enable}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=10
...    NRCELL:dlSCellConfigLevelNum=20
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRBTS:actSCellReleaseForInactiveSCell=timer_based_Fr1
...    NRCELL:sCellInactivityReleaseTimer=10
...    NRCELL-1:maxNumScellsDlFr1=3
...    NRCELL-11:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-12:periodicCsiAcquisition:csiReportPeriodicity=slots160

@{OnlineParamChange_C002}
...    NRCELL-3:sCellInactivityReleaseTimer=40

@{OnlineParam_C002_recover}
...    NRCELL-3:sCellInactivityReleaseTimer=10

${pdu_id}    1

@{PM_Counters_C002}
...    NRCELL-11:NCAC:${DL_RRC_1SCELL_REL_ATT_NSA}=1
...    NRCELL-11:NCAC:${DL_RRC_1SCELL_REL_SUC_NSA}=1
...    NRCELL-11:NCAC:${INA_PRO_REL_SCELL_ATT_NSA}=1
...    NRCELL-11:NCAC:${INA_PRO_REL_SCELL_SUC_NSA}=1

${DL_RRC_1SCELL_REL_ATT_NSA}    M55118C10509
${DL_RRC_1SCELL_REL_SUC_NSA}    M55118C10510
${INA_PRO_REL_SCELL_ATT_NSA}    M55118C10517
${INA_PRO_REL_SCELL_SUC_NSA}    M55118C10518

@{PM_Counters_C005}
...    NRCELL-1:NCAC:${DL_RRC_1SCELL_REL_ATT_SA}=2
...    NRCELL-1:NCAC:${DL_RRC_1SCELL_REL_SUC_SA}=2
...    NRCELL-1:NCAC:${INA_PRO_REL_SCELL_ATT_SA}=2
...    NRCELL-1:NCAC:${INA_PRO_REL_SCELL_SUC_SA}=2

${DL_RRC_1SCELL_REL_ATT_SA}    M55118C10503
${DL_RRC_1SCELL_REL_SUC_SA}    M55118C10504
${INA_PRO_REL_SCELL_ATT_SA}    M55118C10511
${INA_PRO_REL_SCELL_SUC_SA}    M55118C10512

*** Test Cases ***
CB008311-ET-C002_2CC_FT_NSA_gNB-CU performs SCell release due to prolonged data inactivity blind addition
    [Documentation]
    ...    1. This user scenario describes the Requirement Coverage: 1).Operator activates SCell release due to prolonged data inactivity
    ...     via NIDD parameter change. After feature activation, the gNB may trigger an SCell release if it has been deactivated for
    ...     a configurable length of time.
    ...     2). gNB releases an SCell after determining the SCell has been deactivated longer than the operator configurable threshold
    ...      for "SCell release for inactive SCells".
    ...    2. Configuration:
    ...    Cell id=1 gnb=1 pci=16:2 tac=200 tdd_cell=on band=n78 nr_arfcn=633000:633000 gscn=7840 chBw=80MHz ssb=632736
    ...    Cell id=2 gnb=1 pci=17:0 tac=200 tdd_cell=on band=n78 nr_arfcn=633000:633000 gscn=7840 chBw=80MHz ssb=632736
    ...    Cell id=3 gnb=1 pci=17:1 tac=200 tdd_cell=on band=n41 nr_arfcn=508020:508020 gscn=6351 chBw=80MHz ssb=508110
    ...    Cell id=4 gnb=1 pci=17:2 tac=200 tdd_cell=on band=n41 nr_arfcn=508020:508020 gscn=6351 chBw=80MHz ssb=508110
    ...    Cell id=11 gnb=1 pci=20:0 tac=200 tdd_cell=off band=n71 nr_arfcn=134100:124900 gscn=1562 chBw=10MHz ssb=125050
    ...    Cell id=12 gnb=1 pci=20:1 tac=200 tdd_cell=off band=n71 nr_arfcn=134100:124900 gscn=1562 chBw=10MHz ssb=125050
    ...    TDD Cell1/Cell2 configure to same frequency, TDD Cell3/Cell4 configure to another same frequency.
    ...    FDD cell11/cell12 configure to same frequency.
    ...    Configure CA Relations: Cell11-Cell3.
    ...    3. Test Case Steps:
    ...     1) NSA UE attach to cell 11 successfully, no scell cell 3 Addition.gNB-CU performs prerequisite checks prior
    ...        to activating DL buffer monitoring for SCell Addition.The gNB-CU sends a private unacknowledged
    ...        F1AP message to the gNB-DU to activate DL data buffer monitoring.
    ...     2) High DL non-GBR data rate starts, DL buffer overflows,and cannot be drained by the serving cell.
    ...        gNB configures TDD cell3 as scell.
    ...     3) DL non-GBR data rate decreases to low rate.After data transfer is on the PSCell only for 1280 ms, the gNB deactivates the SCell.
    ...        After 10 seconds, the gNB-DU sends a private unacknowledged F1AP message to the gNB-CU for SCell release.The message includes
    ...        the UE context ID, this SCell ID, and the reason for the release request: SCell release timer for data inactivity exceeded.
    ...        The gNB follows the legacy procedure for releasing the SCell from the UE.The gNB activates DL buffer monitoring for SCell Addition.
    ...     4) High DL non-GBR data rate starts, DL buffer overflows,and cannot be drained by the serving cell.
    ...        gNB configures TDD cell3 as scell.
    ...     5) After data transfer is on the PSCell only for 1280 ms, the gNB deactivates the SCell.But before sCellInactivityReleaseTimer expires,
    ...        DL non-GBR data rate increases such that the gNB-DU activates the TDD SCell before the SCell inactivity release timer expires.
    ...        High DL non-GBR data rate starts,the gNB-DU stops and clears the SCell inactivity release timer,
    ...        and does not send the SCell release request to the gNB-CU .UE still keep in CA status.
    ...     6) NSA UE Detach From gNB.Counter check pass.
    [Tags]    QC_279069    C002    CA_LABEL-FT(10MHz_FDD_n71+80MHz_TDD_n41)
    Clear Counter Files    wait=${False}
    NSA UE Attach To Target Cell 11
    Send Traffic For 2CC FT and Verify Throuput
    Wait Until Keyword Succeeds    10s    1s    Stop Throuput For NSA
    Verify Throuput on Pscell For NSA
    Send Traffic For 2CC FT and Verify Throuput
    OnlineParamChange    ${OnlineParamChange_C002}
    Stop Throuput For NSA    pass_regexp=Traffic was stopped for 1 bearers
    Send Traffic For 2CC FT and Verify Throuput
    UE Detach From gNB
    Check Wireshark Log    ${CURDIR}${/}A2A_C002${/}a2a.ini    wait_string=UEContextReleaseComplete::1
    Check Counters    ${PM_Counters_C002}
    [Teardown]    C002_Teardown

CB008311-ET-C005_TTF_partial SCell release due to prolonged data inactivity A1 scell addition Interaction with SCell Change and pcell switch
    [Documentation]
    ...    1. This user scenario describes buffer based SCell addition for UE in SA mode and gNB is configured with 2 eligible SCells,
    ...     thus resulting in 3CC CA. Requirement Coverage: CB008311-C#B5 Buffer based SCell addition with A1 measurement
    ...     based SCell addition method-3CC CA in SA mode.
    ...    2. Configuration:
    ...    Cell id=1 gnb=1 pci=16:2 tac=200 tdd_cell=on band=n78 nr_arfcn=633000:633000 gscn=7840 chBw=80MHz ssb=632736
    ...    Cell id=2 gnb=1 pci=17:0 tac=200 tdd_cell=on band=n78 nr_arfcn=633000:633000 gscn=7840 chBw=80MHz ssb=632736
    ...    Cell id=3 gnb=1 pci=17:1 tac=200 tdd_cell=on band=n41 nr_arfcn=508020:508020 gscn=6351 chBw=80MHz ssb=508110
    ...    Cell id=4 gnb=1 pci=17:2 tac=200 tdd_cell=on band=n41 nr_arfcn=508020:508020 gscn=6351 chBw=80MHz ssb=508110
    ...    Cell id=11 gnb=1 pci=20:0 tac=200 tdd_cell=off band=n71 nr_arfcn=134100:124900 gscn=1562 chBw=10MHz ssb=125050
    ...    Cell id=12 gnb=1 pci=20:1 tac=200 tdd_cell=off band=n71 nr_arfcn=134100:124900 gscn=1562 chBw=10MHz ssb=125050
    ...    TDD Cell1/Cell2 configure to same frequency, TDD Cell3/Cell4 configure to another same frequency.
    ...    FDD cell11/cell12 configure to same frequency.A1ThresholdSCellAddSsbRsrpFDD are set to different values,TDD < FDD.
    ...    Configure CA Relations: Cell1-Cell3,Cell1-Cell4,cell1-cell11.A2 pcell switch NRREL :cell1-cell11.
    ...    3. Test Case Steps:
    ...     1) SA UE attach to cell 1 successfully,reportOnLeave is configured in the A1 measurement for SCell addition.
    ...     2) UE1 sends A1 MR for scell addition with RSRP above FDD threshold.gNB-CU performs DL buffer monitoring activation checks pass.
    ...        gNB-CU sends private F1AP message to gNB-DU to activate DL data buffer monitoring
    ...     3) High DL non-GBR data rate starts, DL buffer overflows,and cannot be drained by the serving cell.
    ...        gNB configures TDD cell3 and FDD cell 11 as scell.
    ...        A2 measurement for SCell release and A2 for pcell switch<TF> and A6 for scell swap are configured.
    ...     4) DL non-GBR data rate decreases to low rate.After data transfer is on the PSCell only for 1280 ms,the gNB deactivates the SCells.
    ...        After 10 seconds, the gNB-DU sends two private unacknowledged F1AP message to the gNB-CU for SCell release.The message includes
    ...        the UE context ID, this SCell ID, and the reason for the release request: SCell release timer for data inactivity exceeded.
    ...        A1 for scell addition is configured.A2 for scell release for FDD object should be removed.
    ...        A2 for pcell switch should be deconfigured.
    ...     5) UE1 sends A1 MR for scell addition with RSRP above TDD threshold.gNB-CU performs DL buffer monitoring activation checks pass.
    ...        gNB-CU sends private F1AP message to gNB-DU to activate DL data buffer monitoring.
    ...     6) High DL non-GBR data rate starts, DL buffer overflows,and cannot be drained by the serving cell.
    ...        gNB configures TDD cell3 as scell.
    ...        A1 for scell change configured. A2 for scell release configured. A6 for scell swap configured.
    ...     7) SA UE Detach From gNB.Counter check pass.
    [Tags]    QC_279065    C005    CA_LABEL-TT(80MHz_TDD_n78+80MHz_TDD_n41)    CA_LABEL-TTF(80MHz_TDD_n78+10MHz_FDD_n71+80MHz_TDD_n41)
    Clear Counter Files
    SA UE Attach To Target Cell 1
    A1 Trigger 3CC TTF ScellAdd and Verify Throuput
    SCell release timer for data inactivity exceeded
    A1 Trigger TT ScellAdd and Verify Throuput
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}A2A_C005${/}a2a.ini    wait_string=UEContextReleaseComplete::3
    Check Counters    ${PM_Counters_C005}
    
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

C002_Teardown
    OnlineParamChange    ${OnlineParam_C002_recover}
    Common Test Teardown And Stop Capture Logs

NSA UE Attach To Target Cell 11
    [Arguments]    ${cell_id}=11    ${ue_id}=91
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...    pass_regexp=reported successful RA    fail_regexp=SCellIndex 9 activated successfully at airphone

Send Throuput For NSA
    [Arguments]    ${ue_id}=91
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=20 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    15s    #sleep for stable traffic

Verify Throuput on Pscell and Scell For NSA
    [Arguments]    ${ue_id}=91    ${pcell_dl}=40    ${scell_dl}=200    ${ul}=6    ${pcell_id}=8    ${scell_id}=9
    sleep    15s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${pcell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pscell For NSA
    [Arguments]    ${ue_id}=91    ${pcell_dl}=10    ${ul}=6    ${pcell_id}=8
    sleep    15s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${pcell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${ul_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Stop Throuput For NSA
    [Arguments]    ${ue_id}=91    ${pass_regexp}=SgNBModificationConfirm
    Execute Egate Command    trf_data_stop ue=${ue_id} trf_id=3 dir=dl    pass_regexp=Traffic was stopped for 1 bearers
    Execute Egate Command    trf_data_stop ue=${ue_id} trf_id=2 dir=dl    pass_regexp=${pass_regexp}

UE Detach From gNB
    [Arguments]    ${ue_id}=91
    Execute Egate Command    ue_detach id=${ue_id}    UE${ue_id}: detached    timeout=10s

Send Traffic For 2CC FT and Verify Throuput
    Send Throuput For NSA
    Verify Throuput on Pscell and Scell For NSA

Sa Ue Attach
    [Arguments]    ${ue_id}=81    ${gateway}=1    ${enb_id}=2    ${cell_id}=1    ${pass_regexp}=NG RM Register
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}

Setup pdu session with no scelladd
    [Arguments]    ${ue_id}=81    ${gateway}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table
    ...    fail_regexp=sCellIndex 1

Trigger ScellAdd
    [Arguments]    ${event_type}=A1    ${carrierfreq}=632736    ${srsrp_nr}=81    ${srsrq_nr}=81    ${ue_id}=81    ${pass_reg}=measurementReport
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=${event_type}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_reg}

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Send Throuput
    [Arguments]    ${ue_id}=81
    FOR    ${I}    IN RANGE    1    5
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175 trf_id=${I}    UE ${ue_id}: UDP DL
    END
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=200    ${scell_dl}=200    ${ul}=5    ${pcell_id}=0    ${scell_id}=1
    sleep    15s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${pcell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Scells
    [Arguments]    ${ue_id}=81    ${total_dl_tput}=300
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell1_tput}+${scell2_tput}
    Should Be True    ${total_dl}/1000>${total_dl_tput}

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=200    ${ul}=5    ${pcell_id}=0
    sleep    15s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${pcell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

SCell release timer for data inactivity exceeded
    [Arguments]    ${ue_id}=81
    FOR    ${I}    IN RANGE    3    5
        Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl trf_id=${I}    DL Traffic was stopped
    END
    ${cmd}    Catenate    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=2 dir=dl
    Wait Until Keyword Succeeds    10s    1s    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=1 dir=dl    DL Traffic was stopped
    ${cmd1}    Catenate    ue_stats_nr id=${ue_id} scell=1-11 type=pdsch
    Wait Until Keyword Succeeds    12 min    5s    Execute Egate Command    ${cmd1}    fail_regexp=CellIndex-

SA UE Attach To Target Cell 1
    Sa Ue Attach
    Setup pdu session with no scelladd

A1 Trigger 3CC TTF ScellAdd and Verify Throuput
    Trigger ScellAdd    srsrp_nr=90
    Send Throuput
    Verify Throuput on Pscell
    Verify Throuput on Scells

A1 Trigger TT ScellAdd and Verify Throuput
    Trigger ScellAdd
    Send Throuput
    Verify Throuput on Pscell and Scell
