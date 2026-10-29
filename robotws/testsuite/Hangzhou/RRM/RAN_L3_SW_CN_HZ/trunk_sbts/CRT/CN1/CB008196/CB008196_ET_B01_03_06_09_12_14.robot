*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env And Start TCE
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN1_SG14
...    owner-jun.15.zhang    release-SBTS22R4    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}
...    @{TCE}
...    @{CellTrace_PCMD_Enable}
...    @{HO}
...    @{A2SgnbRelease}
@{TCE}
...    MRBTS/MNL-1/TCEADM-1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIpAddress=${TCE_IP}
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tcePortNumber=${TCE_PORT}
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tlsEnabled=false
...    NRBTS/NRCTRLTS-1
@{CellTrace_PCMD_Enable}
...    @{NRMTRACECU}
...    @{CellTrace_Enable}
...    @{traceAll}
...    @{PCMD_Enable}
...    @{1UE_infinityreport}
@{NRMTRACECU}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:cellMaxActiveUEsTraced=100
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrTceIdentifier=1
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:scope=allResources
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mcc=311
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mnc=489
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mncLength=3
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:traceId=1
@{CellTrace_Enable}
...    NRBTS:actMDTTraceReport=true
...    NRBTS:actCellTraceReport=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=true
@{PCMD_Enable}
...    NRBTS:actPCMDReport=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actPCMDReporting=true
@{traceAll}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNRRRCSetting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceX2Setting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceXNSetting=all
@{1UE_infinityreport}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:jobType=ImmediateMDTAndTrace
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:mdtMeasType=periodic
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:reportAmount=infinity
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:reportInterval=ms5120
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTControl:cellMaxActiveMDTUEsTraced=1

@{DELETE_NRMTRACECU}
...    delete:MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1

@{2UE_16report}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:jobType=ImmediateMDTAndTrace
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:mdtMeasType=periodic
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:reportAmount=r16
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:reportInterval=ms10240
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTControl:cellMaxActiveMDTUEsTraced=2
@{10UE_infinityreport}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:jobType=ImmediateMDTAndTrace
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:mdtMeasType=periodic
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:reportAmount=infinity
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:reportInterval=ms5120
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTControl:cellMaxActiveMDTUEsTraced=10

@{NRMTRACECU_2UE_16Report}
...    @{NRMTRACECU}
...    @{CellTrace_Enable}
...    @{PCMD_Enable}
...    @{2UE_16report}
@{NRMTRACECU_10UE_InfinityReport}
...    @{NRMTRACECU}
...    @{CellTrace_Enable}
...    @{PCMD_Enable}
...    @{10UE_infinityreport}

@{HO}
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS:actInterMeNBMobility=true
...    NRBTS:srb3SupportEnabled=true
...    NRBTS:actConflictConfiguration=true
...    XNLINK-3:cPlaneIpAddr=10.0.1.124
...    NRADJGNB-3:administrativeState=Unlocked
...    NRADJGNB-3:gNodeBId=3
...    NRADJGNB-3:gNbIdLength=22
...    NRADJGNB-3:xnLinkRef=3
...    NRADJGNB-3:gnbPlmn:mcc=311
...    NRADJGNB-3:gnbPlmn:mnc=489
...    NRADJGNB-3:gnbPlmn:mncLength=3
...    NRADJNRCELL-1:cellDepType=NSA
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-1:physCellId=52
...    NRADJNRCELL-1:gNbId=3
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:nrarfcn=636666
...    NRCELL:a1MeashoEnabled=rsrp
...    NRCELL:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=40
...    NRCELL:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a2MeashoEnabled=rsrq
...    NRCELL:a2MeashoSsbRsrq:a2HysteresishoSsbRsrq=0
...    NRCELL:a2MeashoSsbRsrq:a2ThresholdhoSsbRsrq=31
...    NRCELL:a2MeashoSsbRsrq:a2TimeToTriggerhoSsbRsrq=ms480
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL:measGapSelection=favourUeThroughput
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL-1:actCDrx=true
...    NRCELL-1:drxProfile1:drxInactivityTimer=20ms
...    NRCELL-1:drxProfile1:drxLongCycle=40ms
...    NRCELL-1:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-1:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-1:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-2:nrarfcn=633372
...    NRCELL-2:gscnOrSsPbchArfcn=7845
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=3
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ssbFrequency=633216
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ssbFrequency=636576
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160

@{A2SgnbRelease}
...    NRBTS:actA2SgnbRelease=true
...    NRCELL:a2MeasReleaseEnabled=rsrp
...    NRCELL:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=0
...    NRCELL:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=34
...    NRCELL:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms480

*** Test Cases ***
CB008196-ET-B001_Periodic Measurements configuration on sgNB Addition for MeNB initiated NSA call setup
    [Documentation]
    ...    1.This case is to basic case, only one UE per Cell be traced if cellMaxPeriodicUEsTraced=1.
    ...    internal count cellActivePeriodicUETraced Increment when endc setup.
    ...    internal count cellActivePeriodicUETraced Decrement when endc release.
    ...    [Configuration]: NRMTRACECU-1:nrPeriodicUeMeas:cellMaxPeriodicUEsTraced=1
    ...    2.Test Case Steps:
    ...         a. NSA UE41 Attach And Initial Endc on Cell1
    ...         b. NSA UE42 Attach And Initial Endc on Cell1
    ...         c. Detach all UE and repeat step a and b
    ...    3. Expected Results:
    ...         Step a: UE41 set PeriodicUeMeas config, internal count cellActivePeriodicUETraced increment to 1
    ...         Step b: UE42 not set PeriodicUeMeas config due to internal count cellActivePeriodicUETraced reached cellMaxPeriodicUEsTraced
    ...         Step c: UE41 detach, internal count cellActivePeriodicUETraced decrement to 0. Repeat result the same
    [Tags]    QC_193144
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=41
    NSA UE Attach And Initial Endc Without PeriodicUeMeas    ue_id=42
    Release UEs    ue_type=all
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=41
    NSA UE Attach And Initial Endc Without PeriodicUeMeas    ue_id=42
    Release UEs    ue_type=all

CB008196-ET-B003_Periodic Measurements configuration on sgNB Addition for SgNB initiated inter-gNB Intra-Frequency PSCell change
    [Documentation]
    ...    This case is to Verify UE can be traced when inter SgNB initiated HO:
    ...    internal count cellActivePeriodicUETraced Increment when incoming HO.
    ...    internal count cellActivePeriodicUETraced Decrement when outcoming HO.
    ...    [Configuration]: NRMTRACECU-1:nrPeriodicUeMeas:cellMaxPeriodicUEsTraced=1
    ...    2.Test Case Steps:
    ...         a. NSA UE41 Attach And Initial Endc on sim gNB Cell1
    ...         b. UE41 trigger HO from sim gNB Cell1 to real gNB Cell1
    ...         c. NSA UE42 Attach And Initial Endc on real gNB Cell1
    ...         d. UE41 trigger HO from real gNB Cell1 to sim gNB Cell1
    ...         e. NSA UE43 Attach And Initial Endc on real gNB Cell1
    ...         f. UE41 trigger HO from sim gNB Cell1 to real gNB Cell1
    ...    3. Expected Results:
    ...         Step a: UE41 Attach And Initial Endc Success
    ...         Step b: UE41 HO to real gNB Cell1 Success, UE41 set PeriodicUeMeas config, internal count cellActivePeriodicUETraced increment to 1
    ...         Step c: UE42 not set PeriodicUeMeas config due to internal count cellActivePeriodicUETraced reached cellMaxPeriodicUEsTraced
    ...         Step d: UE41 HO to sim gNB Cell1 Success, internal count cellActivePeriodicUETraced decrement to 0
    ...         Step e: UE43 set PeriodicUeMeas config, internal count cellActivePeriodicUETraced increment to 1
    ...         Step f: UE41 HO to real gNB Cell1 Success
    ...                 UE41 not set PeriodicUeMeas config due to internal count cellActivePeriodicUETraced reached cellMaxPeriodicUEsTraced
    [Tags]    QC_194781
    NSA UE Attach And Initial Endc Without PeriodicUeMeas    ue_id=41    target_gnb=3
    NSA UE Trigger Intra Frequency HO With Measurement Report A3 With PeriodicUeMeas    ue_id=41    phycell_id=50
    NSA UE Attach And Initial Endc Without PeriodicUeMeas    ue_id=42
    NSA UE Trigger Intra Frequency HO With Measurement Report A3 Without PeriodicUeMeas    ue_id=41    phycell_id=52
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=43
    NSA UE Trigger Intra Frequency HO With Measurement Report A3 Without PeriodicUeMeas    ue_id=41    phycell_id=50
    Release UEs    ue_type=all

CB008196-ET-B006_Periodic Measurements configuration on SgNB initiated no PSCell change for A1 A2 Inter-Freq measurement reconfiguration
    [Documentation]
    ...    This case is to Verify RRC reconfig no impact for Periodic Measurements config if no PSCell change.
    ...    [Configuration]: NRMTRACECU-1:nrPeriodicUeMeas:cellMaxPeriodicUEsTraced=1
    ...    2.Test Case Steps:
    ...         a. NSA UE41 Attach And Initial Endc on Cell1
    ...         b. UE41 trigger A2 MR and gap setup
    ...         c. UE41 trigger A1 MR and gap release
    ...         d. Repeat step b and c
    ...         e. NSA UE42 Attach And Initial Endc on Cell1
    ...    3. Expected Results:
    ...         Step a: UE41 set PeriodicUeMeas config, internal count cellActivePeriodicUETraced increment to 1
    ...         Step b.c.d: A1 A1 Measurement config no impact for Periodic Measurements config. Repeat result the same
    ...         Step e: UE42 not set PeriodicUeMeas config due to internal count cellActivePeriodicUETraced reached cellMaxPeriodicUEsTraced
    [Tags]    QC_194782
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=41
    Set MeasurementGap On And Initial Measurement Report A2
    Set MeasurementGap Off And Initial Measurement Report A1
    Set MeasurementGap On And Initial Measurement Report A2
    Set MeasurementGap Off And Initial Measurement Report A1
    NSA UE Attach And Initial Endc Without PeriodicUeMeas    ue_id=42
    Release UEs    ue_type=all

CB008196-ET-B009_Periodic Measurements configuration on MeNB initiated no PSCell Change for Intra-MeNB handover
    [Documentation]
    ...    This case is to Verify MeNB initiated HO no impact for Periodic Measurements config if no PSCell change:
    ...    [Configuration]: NRMTRACECU-1:nrPeriodicUeMeas:cellMaxPeriodicUEsTraced=1
    ...    2.Test Case Steps:
    ...         a. NSA UE41 Attach on enb Cell1 And Initial Endc on gNB Cell1
    ...         b. UE41 trigger Intra MeNB HO from eNB Cell1 to eNB Cell2, SCG no change
    ...         c. NSA UE42 Attach And Initial Endc on gNB Cell1
    ...    3. Expected Results:
    ...         Step a: UE41 set PeriodicUeMeas config, internal count cellActivePeriodicUETraced increment to 1 for gNB Cell1
    ...         Step b: UE41 Intra MeNB HO Success, Endc still on gNB Cell1
    ...         Step c: UE42 not set PeriodicUeMeas config due to Cell1 internal count cellActivePeriodicUETraced reached cellMaxPeriodicUEsTraced
    [Tags]    QC_194784
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=41
    NSA UE Trigger Intra MeNB HO Without SCG Change
    NSA UE Attach And Initial Endc Without PeriodicUeMeas    ue_id=42
    Release UEs    ue_type=all
    [Teardown]    Run Keywords    Set UE Location    AND    Common Test Teardown And Stop Capture Logs

CB008196-ET-B012_Handling on report completion
    [Documentation]
    ...    This case is to Verify internal count cellActivePeriodicUETraced Decrement after UE reportAmount reached
    ...    [Configuration]: NRMTRACECU-1:nrPeriodicUeMeas:cellMaxPeriodicUEsTraced=2
    ...    2.Test Case Steps:
    ...         PRE. NRMTRACECU-1:nrPeriodicUeMeas:cellMaxPeriodicUEsTraced=1, reportAmount=infinity
    ...         a. NSA UE41 Attach And Initial Endc on gNB Cell1, and later delete MOC NRMTRACECU
    ...         b. Recreate NRMTRACECU-1:nrPeriodicUeMeas:cellMaxPeriodicUEsTraced=2, reportAmount=r16
    ...            NSA UE42/43/44 Attach And Initial Endc on gNB Cell1
    ...            After UE reportAmount reached, NSA UE45/46/47 Attach And Initial Endc on gNB Cell1
    ...         c. Lock Unlock Cell1, NSA UE48/49/50 Attach And Initial Endc on gNB Cell1
    ...    3. Expected Results:
    ...         Step a: UE41 set PeriodicUeMeas config, internal count cellActivePeriodicUETraced increment to 1 for gNB Cell1
    ...                 UE41 send Periodic MR to gNB, gNB forward MR to TCE for CellTrace and PCMD
    ...                 After delete MOC NRMTRACECU, CellTrace and PCMD session stop
    ...                 UE41 still send Periodic MR to gNB, but gNB will not forward them to TCE
    ...         Step b: UE42/43 set PeriodicUeMeas config, internal count cellActivePeriodicUETraced increment to 2 for gNB Cell1
    ...                 UE44 not set PeriodicUeMeas config due to Cell1 internal count cellActivePeriodicUETraced reached cellMaxPeriodicUEsTraced
    ...                 After 40s(reportAmount*reportInterval) of endc setup, UE no longer send Periodic MR to gNB
    ...                 Internal count cellActivePeriodicUETraced Decrement to 0 for gNB Cell1
    ...                 UE45/46 set PeriodicUeMeas config, internal count cellActivePeriodicUETraced increment to 2 for gNB Cell1
    ...                 UE47 not set PeriodicUeMeas config due to Cell1 internal count cellActivePeriodicUETraced reached cellMaxPeriodicUEsTraced
    ...         Step c: After Lock Cell, UE Bearer-type change from SCG-split to MCG due to cell-not-available
    ...                 Internal count cellActivePeriodicUETraced Decrement to 0 for gNB Cell1
    ...                 UE48/49 set PeriodicUeMeas config, internal count cellActivePeriodicUETraced increment to 2 for gNB Cell1
    ...                 UE50 not set PeriodicUeMeas config due to Cell1 internal count cellActivePeriodicUETraced reached cellMaxPeriodicUEsTraced
    [Tags]    QC_198925
    Check gNB Not Forward PRE UE MR after NRMTRACECU Deletion
    Check Internal Count cellActivePeriodicUETraced Decrement After UE reportAmount Reached
    Check Lock Cell Will Clear Internal Count cellActivePeriodicUETraced
    Release UEs    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}a2a_B012${/}a2a.ini
    [Teardown]    Run Keywords    Set CellTrace And PCMD Enable By Delta Commission    AND    Common Test Teardown And Stop Capture Logs

CB008196-ET-B014_Handling on bulk call release and UE RLF
    [Documentation]
    ...    This case is to Verify internal count cellActivePeriodicUETraced Decrement when UE RLF or bulk release
    ...    [Configuration]: NRMTRACECU-1:nrPeriodicUeMeas:cellMaxPeriodicUEsTraced=10
    ...    2.Test Case Steps:
    ...         PRE. NRMTRACECU-1:nrPeriodicUeMeas:cellMaxPeriodicUEsTraced=10, reportAmount=infinity
    ...         a. 9 PRE NSA UE Attach And Initial Endc on gNB Cell1
    ...            NSA UE41/42 Attach And Initial Endc on gNB Cell1
    ...            Make UE41 RLF and later NSA UE43 Attach And Initial Endc on gNB Cell1
    ...            UE41 Reinitial Endc
    ...         b. Make all active UE detach.
    ...            9 PRE NSA UE Attach And Initial Endc on gNB Cell1
    ...            NSA UE44/45 Attach And Initial Endc on gNB Cell1
    ...    3. Expected Results:
    ...         Step a: 9 PRE UE and UE41 set PeriodicUeMeas config, internal count cellActivePeriodicUETraced increment to 10 for gNB Cell1
    ...                 UE42 not set PeriodicUeMeas config due to Cell1 internal count cellActivePeriodicUETraced reached cellMaxPeriodicUEsTraced
    ...                 Make UE41 RLF, internal count cellActivePeriodicUETraced increment to 9 for gNB Cell1
    ...                 UE43 set PeriodicUeMeas config, internal count cellActivePeriodicUETraced increment to 10 for gNB Cell1
    ...                 UE41 not set PeriodicUeMeas config due to Cell1 internal count cellActivePeriodicUETraced reached cellMaxPeriodicUEsTraced
    ...         Step b: All UE detach, internal count cellActivePeriodicUETraced decrement to 0 for gNB Cell1
    ...                 9 PRE UE and UE44 set PeriodicUeMeas config, internal count cellActivePeriodicUETraced increment to 10 for gNB Cell1
    ...                 UE45 not set PeriodicUeMeas config due to Cell1 internal count cellActivePeriodicUETraced reached cellMaxPeriodicUEsTraced
    [Tags]    QC_198927
    Rebuild NRMTRACECU With 10 UE And Infinity Report
    Check Internal Count cellActivePeriodicUETraced Decrement After UE RLF
    Check Internal Count cellActivePeriodicUETraced Decrement For Bulk Call Release
    Release UEs    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}a2a_B014${/}a2a.ini
    [Teardown]    Run Keywords    Set CellTrace And PCMD Enable By Delta Commission    AND    Common Test Teardown And Stop Capture Logs

*** Keywords ***
Common Suite Setup And Setup Airphone Env And Start TCE
    Common Suite Setup
    Setup Airphone Env    tl_type=${TL_TYPE_PATH}
    Perform Steps After Onair

Perform Steps After Onair
    Start TCE    ${TCE_PORT}
    Set eNB X2 link And Allow Endc On

Set eNB X2 link And Allow Endc On
    Execute Egate Command    enb_x2_link_up enb=1 target=3    is up
    Execute Egate Command    enb_cell_param enb=1 id=1 allow_endc=on
    Execute Egate Command    enb_cell_param enb=1 id=2 allow_endc=on

Modify Cfg
    ${eNB1_Cell2_sim_configuration}    catenate
    ...    set_cell id=2 enb=1 eci=0x1234602 pci=4:0 tac=222 proxy=10.0.2.1:12220|10.0.2.1:8890 earfcn=2000:20000 mapped_earfcn=4200:22200
    ...    mandatory_for_activation=off
    Update Cfg    ${eNB1_Cell2_sim_configuration}
    ${GNB3_sim_configuration}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 s1u=10.0.1.122 ng=10.0.1.123 gnb_id=0x3:22 daemon=10.0.2.1:22222 xn=10.0.1.124 x2_peers=none
    ...    nssai=0x1:0xd143a5 amf=none
    Update Cfg    ${GNB3_sim_configuration}
    ${GNB2_Cell2_configuration}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888 nr_arfcn=633372:633372 gscn=7845
    ...    mandatory_for_activation=off
    Update Cfg    ${GNB2_Cell2_configuration}
    ${GNB3_Cell1_sim_configuration}    catenate
    ...    set_cell id=1 gnb=3 pci=17:1 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666 gscn=7880
    ...    mandatory_for_activation=off
    Update Cfg    ${GNB3_Cell1_sim_configuration}
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3

Set UE Location
    Execute Egate Command    ue_change_location id=41 enb=1 cell=1

Rebuild NRMTRACECU With 10 UE And Infinity Report
    Delta Commission Parameters    ${DELETE_NRMTRACECU}
    Delta Commission Parameters    ${NRMTRACECU_10UE_InfinityReport}
    Start TCE    ${TCE_PORT}

Set CellTrace And PCMD Enable By Delta Commission
    Delta Commission Parameters    ${DELETE_NRMTRACECU}
    Delta Commission Parameters    ${CellTrace_PCMD_Enable}
    Start TCE    ${TCE_PORT}

Lock Unlock Cell1
    Lock Cell1
    Unlock Cell1
    Cells Should Be Onair    cell_id=1

NSA UE Attach And Initial Endc With PeriodicUeMeas
    [Arguments]    ${ue_id}=41    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2    ${cellfreq}=636576
    Execute Egate Command    ue_attach id=${ue_id} profile=1    pass_regexp=UE IS ACTIVE
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=Successfully reconfigured dual connectivity    timeout=20s
    Should Contain    ${ret1}    reportType periodical
    ${Periodical_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}
    ...    event_type=Periodical
    Should Not Be Empty    ${Periodical_meas_id}
    ${cmd}     Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${Periodical_meas_id} report_type=periodical
    ...    srsrp_nr=${ue_id} srsrq_nr=30 ssinr_nr=30 srs_result=0:50:50:50
    Execute Egate Command    ${cmd}    pass_regexp=For Periodic MeasId = .* MeasReportQuantity from RRC-reconfiguration
    Traffic Should Be Ok    ue_id=${ue_id}    type=NSA

NSA UE Attach And Initial Endc Without PeriodicUeMeas
    [Arguments]    ${ue_id}=41    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2
    Execute Egate Command    ue_attach id=${ue_id} profile=1    pass_regexp=UE IS ACTIVE
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=Successfully reconfigured dual connectivity    timeout=20s
    Should Not Contain    ${ret1}    reportType periodical
    Traffic Should Be Ok    ue_id=${ue_id}    type=NSA

NSA UE Reinitial Endc Without PeriodicUeMeas
    [Arguments]    ${ue_id}=41    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=Successfully reconfigured dual connectivity    timeout=20s
    Should Not Contain    ${ret1}    reportType periodical
    Traffic Should Be Ok    ue_id=${ue_id}    type=NSA

9 PRE NSA UE Attach And Initial Endc With PeriodicUeMeas
    FOR    ${ue}    IN RANGE    31    40
        NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=${ue}
    END

NSA UE Trigger Intra Frequency HO With Measurement Report A3 With PeriodicUeMeas
    [Arguments]    ${ue_id}=41    ${phycell_id}=50    ${cellfreq}=636576
    ${A3_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A3
    ${cmd}     Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${A3_meas_id} event=A3 srsrp_nr=30 srsrq_nr=40 phycell_id=${phycell_id}
    ...    nrsrp_nr=50 nrsrq_nr=50
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=Proxy \\(eNB .* cell .*\\) reported successful RA
    Should Contain    ${ret1}    reportType periodical
    ${Periodical_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}
    ...    event_type=Periodical
    Should Not Be Empty    ${Periodical_meas_id}
    ${cmd}     Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${Periodical_meas_id} report_type=periodical
    ...    srsrp_nr=${ue_id} srsrq_nr=30 ssinr_nr=30 srs_result=0:50:50:50
    Execute Egate Command    ${cmd}    pass_regexp=For Periodic MeasId = .* MeasReportQuantity from RRC-reconfiguration
    Traffic Should Be Ok    ue_id=${ue_id}    type=NSA

NSA UE Trigger Intra Frequency HO With Measurement Report A3 Without PeriodicUeMeas
    [Arguments]    ${ue_id}=41    ${phycell_id}=52    ${cellfreq}=636576
    ${A3_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A3
    ${cmd}     Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${A3_meas_id} event=A3 srsrp_nr=30 srsrq_nr=40 phycell_id=${phycell_id}
    ...    nrsrp_nr=50 nrsrq_nr=50
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=Proxy \\(eNB .* cell .*\\) reported successful RA
    Should Not Contain    ${ret1}    reportType periodical
    Traffic Should Be Ok    ue_id=${ue_id}    type=NSA

Set MeasurementGap On And Initial Measurement Report A2
    [Arguments]    ${ue_id}=41    ${cellfreq}=636576
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:12 gap_trigger=gnb_triggered
    ${A2_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    ...    threshold=RSRQ\ 31
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${A2_meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=Sending SgNB Modification Confirm
    Should Contain    ${ret1}    measGapConfig setup
    Should Contain    ${ret1}    drx-Config release : NULL
    Should Not Contain    ${ret1}    reportType periodical
    [Teardown]    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=off

Set MeasurementGap Off And Initial Measurement Report A1
    [Arguments]    ${ue_id}=41    ${cellfreq}=636576
    ${A1_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${A1_meas_id} event=A1 srsrp_nr=80 srsrq_nr=80 srs_result=0:30:30:0
    ...    phycell_id=50
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfiguration    timeout=20s
    Should Contain    ${ret1}    eventId eventA2
    Should Contain    ${ret1}    measGapConfig release : NULL
    Should Not Contain    ${ret1}    reportType periodical

NSA UE Trigger Intra MeNB HO Without SCG Change
    [Arguments]    ${ue_id}=41
    Execute Egate Command    ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=1 cell=2    pass_regexp=Intra-eNB handover from .*ENB-1.1 to ENB-1.2 performed
    Traffic Should Be Ok    ue_id=${ue_id}    type=NSA

Trigger Radio Link Failure To Make Sgnb Release
    [Arguments]    ${ue_id}=41
    ${cmd}    Catenate    ue_dc_rlf ue=${ue_id} failure_type=rlc_max_num_retx
    Execute Egate Command    ${cmd}    pass_regexp=Bearer-type change from SCG-split to MCG is successful

Check gNB Not Forward PRE UE MR after NRMTRACECU Deletion
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=41
    Delta Commission Parameters    ${DELETE_NRMTRACECU}

Check Internal Count cellActivePeriodicUETraced Decrement After UE reportAmount Reached
    Delta Commission Parameters    ${NRMTRACECU_2UE_16Report}
    Start TCE    ${TCE_PORT}
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=42
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=43
    NSA UE Attach And Initial Endc Without PeriodicUeMeas    ue_id=44
    Sleep    150s    #SleepTime>reportAmount*reportInterval
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=45
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=46
    NSA UE Attach And Initial Endc Without PeriodicUeMeas    ue_id=47

Check Lock Cell Will Clear Internal Count cellActivePeriodicUETraced
    Lock Unlock Cell1
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=48
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=49
    NSA UE Attach And Initial Endc Without PeriodicUeMeas    ue_id=50

Check Internal Count cellActivePeriodicUETraced Decrement After UE RLF
    9 PRE NSA UE Attach And Initial Endc With PeriodicUeMeas
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=41
    NSA UE Attach And Initial Endc Without PeriodicUeMeas    ue_id=42
    Trigger Radio Link Failure To Make Sgnb Release    ue_id=41
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=43
    NSA UE Reinitial Endc Without PeriodicUeMeas    ue_id=41

Check Internal Count cellActivePeriodicUETraced Decrement For Bulk Call Release
    Release UEs    ue_type=all
    sleep    4s    # wait ues release finish
    9 PRE NSA UE Attach And Initial Endc With PeriodicUeMeas
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=44
    NSA UE Attach And Initial Endc Without PeriodicUeMeas    ue_id=45
