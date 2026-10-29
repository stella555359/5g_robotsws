*** Settings ***
Suite Setup       Start BTS With Specified Config Files
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  CLOUD_5G_I_BOO_AP_LOO
...               team-DevHZ5_SG1    owner-pei.han    release-SBTS22R1
Resource          ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${BTS_STARTUP_RETRY}    2
${GNB1_CONFIG}    fddtdd_sansa_cmwv/4cells_2F2T
@{PARAMS_IN_CP_UE_RD}    rdA2SCellRelWaitTimer=10.0
@{PARAMS_IN_SCF}    @{CA_Basic}    @{CB007893}    @{Mobility}    @{SRB3}    @{CB008015-G}
@{CA_Basic}       NRDU-1:actInterNumerologyCa=true    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Nsa
...    NRCELL:pucchModeSelect=longPucch    NRBTS:cipherPrefL:nea0=9    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL:primaryPathMaxQueueingDelay=10    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs
...    NRCELL:actK1Opt=intra-gNB
@{CB008015-G}    NRBTS/NRDU-1:actConnectedModeMobilityCA=true    NRBTS:actHoOptimizationCa=true
...    NRCELL-2:a1MeasPCellSwitchEnabled=rsrp    NRCELL-2:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-2:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL-2:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=80
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-2:a3MeasEnabled=rsrp    NRCELL-2/NRHOIF-2:cellDepType=NSA
...    NRCELL-2/NRHOIF-2:freqBandIndicatorNR=78    NRCELL-2/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-2:ifhoSsbSmtcDuration=sf5
...    NRCELL-2/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf20    NRCELL-2/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-2:ssbFrequency=636576
...    NRCELL-2/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-2/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-2/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
...    NRCELL-2/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-4:a1MeasPCellSwitchEnabled=rsrp    NRCELL-4:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-4:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL-4:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=80
...    NRCELL-4/NRREL-10:cellIndividualSsbRsrpOffset=0dB    NRCELL-4/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-10:gNbId=2
...    NRCELL-4/NRREL-10:gNbIdLength=22    NRCELL-4/NRREL-10:lcrId=2    NRCELL-4/NRREL-10:removeNotAllowed=false
...    NRCELL-4/NRREL-10:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-4/NRREL-10:gnbPlmn:mnc=489|mncLength=3    NRCELL-4/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-4/NRHOIF-1:a3MeasEnabled=rsrp    NRCELL-4/NRHOIF-1:cellDepType=NSA
...    NRCELL-4/NRHOIF-1:freqBandIndicatorNR=41    NRCELL-4/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-4/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-4/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20    NRCELL-4/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-4/NRHOIF-1:ssbFrequency=518670
...    NRCELL-4/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-4/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-4/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
...    NRCELL-4/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=34
...    NRCELL-4:a1MeasSCellAddEnabled=rsrp
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=2
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=4
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-4:a2MeasSCellRelEnabled=rsrp
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-4:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50
...    NRCELL-4:ulPowerControlCommon:p0NominalSrs=-80
...    NRCELL-3/NRHOIF-2:a3MeasEnabled=rsrp    NRCELL-3/NRHOIF-2:cellDepType=NSA
...    NRCELL-3/NRHOIF-2:freqBandIndicatorNR=78    NRCELL-3/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-3/NRHOIF-2:ifhoSsbSmtcDuration=sf5
...    NRCELL-3/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf20    NRCELL-3/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-3/NRHOIF-2:ssbFrequency=636576
...    NRCELL-3/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-3/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-3/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
...    NRCELL-3/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-3/NRREL-2:gNbId=2    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:lcrId=4    NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3:reportAmountCA=r2
@{CB007893}       NRBTS:actMeasBasedSCellAdditionSa=A1-based    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=20|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-2:a2MeasSCellRelEnabled=rsrp
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-2:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=480ms
...    NRCELL-2:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=5|a2TimeToTriggerSCellRelSsbRsrq=480ms
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=2
...    NRCELL-1/NRREL-10:gNbIdLength=22    NRCELL-1/NRREL-10:lcrId=2    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489|mncLength=3    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-10:gNbId=2    NRCELL-3/NRREL-10:gNbIdLength=22
...    NRCELL-3/NRREL-10:lcrId=2    NRCELL-3/NRREL-10:sCellAdditionMethod=covBasedA1    NRCELL-3/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-10:gnbPlmn:mcc=311    NRCELL-3/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-3:a1MeasSCellAddEnabled=rsrp
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
${ue_eutra_nr_capabilities}    SEPARATOR=
...    A11FF83382C0C0388C00000404440B84C0C030500711800001048881709818070A000308C0003091102E130300E1400071180000004888170
...    98180711800309A0004091102E130300E14000713400002848881007011A014003809A0A1020D0A74ED8E7C3893A24ED8E7C38806C73E1C40
...    3639F0E201B1CF87100D8E7C310051000040202004010080600C1000080404030061000040202004000080600C2000080404008020100C000
...    40001008080600C020040008000201010020080400802
${ue_eutra_nr_capabilities_SRB3}    SEPARATOR=
...    A11FF83382C0C0388C00000404440B84C0C030500711800001048881709818070A000308C0003091102E130300E1400071180000004888170
...    98180711800309A0004091102E130300E14000713400002848881007011A014003809A0A1020D0A74ED8E7C3893A24ED8E7C38806C73E1C40
...    3639F0E201B1CF87100D8E7C318051000040202004010080600C1000080404030061000040202004000080600C2000080404008020100C000
...    40001008080600C020040008000201010020080400802
@{Mobility}       NRBTS:actIntraFreqInterGnbMobilityNSA3x=true    NRBTS:tDCoverall=10000    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea2_128=0    NRBTS:cipherPrefL:nea1_128=0    NRBTS:cipherPrefL:nea3_128=9
...    NRBTS/NRADJNRCELL-4915:cellDepType=NSA
...    NRBTS/NRADJNRCELL-4915:gNbId=3    NRBTS/NRADJNRCELL-4915:gNbIdLength=22    NRBTS/NRADJNRCELL-4915:lcrId=3
...    NRBTS/NRADJNRCELL-4915:nrarfcn=127210
...    NRBTS/NRADJNRCELL-4915:physCellId=381    NRBTS/NRADJNRCELL-4915:gnbPlmn:mnc=255
...    NRBTS/NRADJNRCELL-4915:gnbPlmn:mcc=250
...    NRBTS/NRADJNRCELL-4915:gnbPlmn:mncLength=3    delete:NRBTS/NRADJNRCELL-4915:freqBandIndicatorNR
...    NRBTS:timerX2UeProcGuard=15000
...    NRCELL-1/NRREL-1:gNbId=3
...    NRCELL-1/NRREL-1:gNbIdLength=22    NRCELL-1/NRREL-1:lcrId=3    NRCELL-1/NRREL-1:gnbPlmn:mnc=255
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=250
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3    NRCELL:a3MeasEnabled=rsrp    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms512
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=5    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actInterMeNBMobility=true
...    NRBTS:actIntraMeNBMobility=true    NRCELL-1:a1MeashoEnabled=rsrp    NRCELL-1:a2MeashoEnabled=rsrp
...    NRCELL-1:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=60
...    NRCELL-1:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480    NRCELL-1:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRCELL-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34    NRCELL-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp    NRCELL-1/NRHOIF-1:cellDepType=NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=518670
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
...    NRCELL-2:a1MeashoEnabled=rsrp    NRCELL-2:a2MeashoEnabled=rsrp
...    NRCELL-2:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=60
...    NRCELL-2:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-2:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0    NRCELL-2:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRCELL-2:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-2:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:cellDepType=NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=71    NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf5    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=127210    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3    NRCELL-2/NRREL-10:gNbId=2    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:lcrId=1    NRCELL-2/NRREL-10:gnbPlmn:mnc=489    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRCELL-3:a1MeasSCellAddEnabled=rsrp
...    NRCELL-3:a1MeashoEnabled=rsrp    NRCELL-3:a2MeashoEnabled=rsrp
...    NRCELL-3:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=60    NRCELL-3:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-3:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-3/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-1:cellDepType=NSA    NRCELL-3/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-3/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcDuration=sf5    NRCELL-3/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-3/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam    NRCELL-3/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-3/NRHOIF-1:ssbFrequency=518670
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
...    NRCELL-1/NRREL-2:gNbId=2    NRCELL-1/NRREL-2:gNbIdLength=22    NRCELL-1/NRREL-2:lcrId=3
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:gNbId=2    NRCELL-3/NRREL-1:gNbIdLength=22    NRCELL-3/NRREL-1:lcrId=1
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
@{SRB3}    NRBTS:srb3SupportEnabled=true
@{PM_Counters_Check_Case13_Case14}
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=7    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=7
...    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_ATT_NSA}=6    NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_SUCC_NSA}=6
...    NRCELL-1:NCAC:${A2MEAS_IMMEDIATE_REL_SCELL}=5
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=7    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=7
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=7    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=7
@{PM_Counters_Check_Case16}
...    NRCELL-1:NRANS:${ATT_A1_IF_INTRA_DU_HO_NSA_MNB}=0    NRCELL-1:NRANS:${ATT_A1_IF_INTRA_DU_HO_NSA_SRB3}=1
...    NRCELL-1:NIFC:${IF_INTRA_DU_HO_ATT_NSA_SRB3}=0
...    NRCELL-1:NRANS:${ATT_IF_INTRA_DU_HO_NSA_PLMN}=1    NRCELL-1:NIFC:${IF_INTRA_DU_HO_ATT_NSA_MNB}=0
@{PM_Counters_Check_Case18}
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-4:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1    NRCELL-4:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-1:NRANS:${ATT_A1_IF_INTRA_DU_HO_NSA_MNB}=1    NRCELL-1:NRANS:${ATT_A1_IF_INTRA_DU_HO_NSA_SRB3}=0
...    NRCELL-1:NRANS:${ATT_IF_INTRA_DU_HO_NSA_PLMN}=1    NRCELL-2:NIFC:${IF_INTRA_DU_HO_ATT_NSA_MNB}=1
...    NRCELL-2:NRANS:${ATT_IF_INTRA_DU_HO_NSA_PLMN}=1
@{PM_Counters_Check_Case19}
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-4:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1    NRCELL-4:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
@{PM_Counters_Check_Case23}
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-4:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1    NRCELL-4:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-3:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1    NRCELL-3:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-4:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1    NRCELL-4:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=2    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=2
...    NRCELL-4:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1    NRCELL-4:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-3:NRANS:${ATT_A1_IF_INTRA_DU_HO_NSA_MNB}=1    NRCELL-3:NRANS:${ATT_A1_IF_INTRA_DU_HO_NSA_SRB3}=0
...    NRCELL-3:NRANS:${ATT_IF_INTRA_DU_HO_NSA_PLMN}=1    NRCELL-3:NIFC:${IF_INTRA_DU_HO_ATT_NSA_MNB}=0
...    NRCELL-1:NINFC:${INTRA_DU_HO_ATT_NSA_MNB}=1
@{PM_Counters_Check_Case24}
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-4:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1    NRCELL-4:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-1:NRANS:${ATT_A1_IF_INTRA_DU_HO_NSA_MNB}=0    NRCELL-1:NRANS:${ATT_A1_IF_INTRA_DU_HO_NSA_SRB3}=0
...    NRCELL-1:NRANS:${ATT_IF_INTRA_DU_HO_NSA_PLMN}=1    NRCELL-1:NIFC:${IF_INTRA_DU_HO_ATT_NSA_MNB}=1
${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
${A2MEAS_REL1DLSCELL_ATT_NSA}    M55118C06503
${A2MEAS_REL1DLSCELL_SUCC_NSA}    M55118C06504
${A2MEAS_IMMEDIATE_REL_SCELL}    M55118C06505
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007
${ATT_A1_IF_INTRA_DU_HO_NSA_MNB}    M55145C02005
${ATT_A1_IF_INTRA_DU_HO_NSA_SRB3}    M55145C02006
${IF_INTRA_DU_HO_ATT_NSA_SRB3}    M55151C00002
${ATT_IF_INTRA_DU_HO_NSA_PLMN}    M55145C00121
${IF_INTRA_DU_HO_ATT_NSA_MNB}    M55151C00001
${INTRA_DU_HO_ATT_NSA_MNB}    M55120C01001
${Update_Cfg_1}    set_cell id=2 enb=1 eci=0x1234602 pci=3:1 tac=222 proxy=10.0.2.1:12220|10.0.2.1:8890
...    earfcn=2000:20000 mandatory_for_activation=off
${Update_Cfg_2}    set_enb id=11 plmn=250:255 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222 x2=10.0.1.127
...    x2u=10.0.1.137 type=simulated x2_peers=none
${Update_Cfg_3}    set_cell id=3 gnb=3 tac=3 pci=127:0 proxy=10.0.2.1:12221|10.0.2.1:8891 nrci=0x1
...    nr_arfcn=134980:127180 gscn=1589 mandatory_for_activation=off
${Update_Cfg_4}    set_cell id=1 enb=11 eci=0x1234701 pci=7:2 tac=222 proxy=10.0.2.1:8887 earfcn=2000:20000
...    mandatory_for_activation=off
${Update_Cfg_5}    gnb_set id=3 s1u=10.0.1.122 plmn=250:255 gnb_id=0x3 type=simulated daemon=10.0.2.1:22222
...    x2=10.0.1.122:36422 x2_peers=none
@{OnlineParam_maxNumOfCaUsers}
...    NRCELL-1:maxNumOfCaUsersNRCell=1    NRCELL-2:maxNumOfSCellAlloc=1
...    NRCELL-3:maxNumOfCaUsersNRCell=1    NRCELL-4:maxNumOfSCellAlloc=1
...    NRCELL-2:maxNumOfCaUsersNRCell=1    NRCELL-4:maxNumOfCaUsersNRCell=1
${normal_report_A2}    11s
${candidate_cells_mn_hex_for_menb_ho_to_PCI50}    091FA838219292C0
${candidate_cells_mn_hex_ho_to_PCI50_No_Scell}    091FA83821929040
${candidate_cells_mn_hex_ho_to_PCI60_add_Scell}    0907C3A821E292C0
${candidate_cells_mn_hex_ho_to_PCI60_No_Scell}    0907C3A821E29040

*** Test Cases ***
CB008015-G_16_B4_ET_04_01_SCell addition not performed immediately during Inter-MeNB HO triggered PSCell change for NSA with SRB3
    [Tags]    CIT    RAN_5G    RAN_5G_TDD
    Clear Counter files
    Set UE Parameters Before Attach
    UE Attach and establish EN-DC    target_cell=2    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities_SRB3}
    Inter MeNB HO triggered PSCell Change and No Scell add    allowed_bc_list=4:1
    ...    candidate_cells_mn_hex_for_menb_ho=${candidate_cells_mn_hex_ho_to_PCI60_No_Scell}
    Pcell A1 report to trigger Scell Addition    meas_id=6
    Scell A1 report to trigger PScell Switch and No Scell add immediately    meas_id=2
    Check Counters    ${PM_Counters_Check_Case16}

*** Keywords ***
Start BTS With Specified Config Files
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}
    Execute Egate Command    enb_x2_link_up enb=11 target=2    ENB-11: X2AP Link with GNB-2
    Execute Egate Command    enb_x2_link_up enb=1 target=3    ENB-1: X2AP Link with GNB-3

Modify Cfg
    Update Cfg    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Update Cfg    ${Update_Cfg_1}
    Update Cfg    ${Update_Cfg_2}
    Update Cfg    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    ${Update_Cfg_3}
    Update Cfg    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Update Cfg    ${Update_Cfg_4}
    Update Cfg    ${Update_Cfg_5}
    Update Cfg    gnb_endc_param id=3 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0
    Update Cfg    gnb_param id=3 x2_listening_socket=1 measEvent=A3
    ${set_gnb2}  catenate  set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 gnb_id=0x2:22 x2=10.0.1.2:36422
    ...  x2_peers=none ng=10.0.1.2 xn=10.0.1.2 amf=1 nssai=0x1:0xd143a5
    Update Cfg  ${set_gnb2}

Set UE Parameters Before Attach
    [Arguments]    ${ue_id}=31
    Execute Egate Command    enb_param id=1 reset
    Execute Egate Command    enb_param id=11 reset
    Execute Egate Command    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Execute Egate Command    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=disabled
    Execute Egate Command    enb_endc_param id=11 allowed_bc_list_mrdc=disabled
    Execute Egate Command    ue_enb_endc_param id=${ue_id} reset
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=off
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=1

UE Attach and establish EN-DC
    [Arguments]    ${ue_id}=31    ${target_cell}=1    ${ue_eutra_nr_capabilities}=${ue_eutra_nr_capabilities}
    Start RRC Log    establish_EN-DC
    Execute Egate Command    ue_attach id=${ue_id} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cell} bearer=2 type=split_scg
    ...    Proxy \\(eNB 2 cell ${target_cell}\\) reported successful RA
    Get RRC Log

Pcell A1 report to trigger Scell Addition
    [Arguments]    ${ue_id}=31    ${meas_id}=3    ${phycell_id}=60
    Start RRC Log     Scell_Addition_${meas_id}
    ${A1_Scell_addition}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} event=A1
    ...    srsrp_nr=80 srsrq_nr=40
    ${ret1}=    Execute Egate Command    ${A1_Scell_addition}    SgNB Modification Confirm
    Should Contain    ${ret1}    eventId eventA2
    Should Contain    ${ret1}    a2-Threshold rsrp : 50
    Should Contain    ${ret1}    sCellToAddModList
    Should Contain    ${ret1}    eventId eventA1
    Should Contain    ${ret1}    a1-Threshold rsrp : 80
    Get RRC Log

Pcell A1 report to trigger Scell Addition with no Scell A1
    [Arguments]    ${ue_id}=31    ${meas_id}=3    ${phycell_id}=60
    Start RRC Log     Scell_Addition_${meas_id}
    ${A1_Scell_addition}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} event=A1
    ...    srsrp_nr=80 srsrq_nr=40
    ${ret1}=    Execute Egate Command    ${A1_Scell_addition}    SgNB Modification Confirm
    Should Contain    ${ret1}    eventId eventA2
    Should Contain    ${ret1}    a2-Threshold rsrp : 50
    Should Contain    ${ret1}    sCellToAddModList
    Get RRC Log

Scell A1 report to trigger PScell Switch and Scell add immediately
    [Arguments]    ${ue_id}=31    ${meas_id}=5    ${target_cell}=2
    Start RRC Log     PScell_Switch
    ${A1_Scell_Switch}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} scell=9 scell_rsrp=80 scell_rsrq=30 event=A1
    ${ret1}=    Execute Egate Command    ${A1_Scell_Switch}
    ...    Proxy \\(eNB 2 cell ${target_cell}\\) reported successful RA
    Should Contain    ${ret1}    sCellToAddModList
    Get RRC Log

Scell A1 report to trigger PScell Switch and No Scell add immediately
    [Arguments]    ${ue_id}=31    ${meas_id}=5    ${target_cell}=2
    Start RRC Log     PScell_Switch
    ${A1_Scell_Switch}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} scell=9 scell_rsrp=80 scell_rsrq=30 event=A1
    ${ret1}=    Execute Egate Command    ${A1_Scell_Switch}
    ...    Proxy \\(eNB 2 cell ${target_cell}\\) reported successful RA
    Get RRC Log

Scell A2 report normally to trigger Scell Release
    [Arguments]    ${ue_id}=31    ${meas_id}=4
    sleep    ${normal_report_A2}
    Start RRC Log     Scell_Release_${meas_id}
    ${A2_Scell_Release}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} scell=9 scell_rsrp=40 scell_rsrq=0 event=A2
    ${ret1}=    Execute Egate Command    ${A2_Scell_Release}    SgNB Modification Confirm
    Should Contain    ${ret1}    eventId eventA1
    Should Contain    ${ret1}    sCellToReleaseList
    Should Contain    ${ret1}    timeToTrigger ms320
    Get RRC Log

Scell A2 report immediately to trigger Scell Release
    [Arguments]    ${ue_id}=31    ${meas_id}=4
    Start RRC Log     Scell_Release_${meas_id}
    ${A2_Scell_Release}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} scell=9 scell_rsrp=40 scell_rsrq=0 event=A2
    ${ret1}=    Execute Egate Command    ${A2_Scell_Release}    SgNB Modification Confirm
    Should Contain    ${ret1}    eventA1
    Should Contain    ${ret1}    sCellToReleaseList
    Should Contain    ${ret1}    timeToTrigger ms5120
    Get RRC Log

Scell A2 report to trigger Scell Release when rdLimitNumImmediateSCellRel reached
    [Arguments]    ${ue_id}=31    ${meas_id}=4
    ${A2_Scell_Release}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} scell=9 scell_rsrp=40 scell_rsrq=0 event=A2
    ${ret1}=    Execute Egate Command    ${A2_Scell_Release}    fail_regexp=SgNB Modification Confirm
    Should Not Contain    ${ret1}    eventA1
    Should Not Contain    ${ret1}    sCellToReleaseList
    Should Not Contain    ${ret1}    timeToTrigger ms5120
    Should Not Contain    ${ret1}    nr-Config-r15 release : NULL
    Should Not Contain    ${ret1}    SgNBModificationRequestReject

Pcell A1 report to trigger Scell Addition then Scell A2 report to trigger Scell Release when rdLimitNumImmediateSCellRel reached
    [Arguments]    ${ue_id}=31    ${meas_id}=3
    Pcell A1 report to trigger Scell Addition    meas_id=${meas_id}
    Scell A2 report to trigger Scell Release when rdLimitNumImmediateSCellRel reached    meas_id=${${meas_id}+1}

OnlineParamChange
    [Arguments]  ${Online_Param}
    Delta Commission Parameters  ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

UE report A1 and A2 immediately
    [Arguments]    ${meas_id}=3    ${phycell_id}=60
    FOR    ${meas_ids}    IN    @{meas_id.split(",")}
        Pcell A1 report to trigger Scell Addition    meas_id=${meas_ids}    phycell_id=${phycell_id}
        Scell A2 report immediately to trigger Scell Release    meas_id=${${meas_ids}+1}
    END

Intra-gNB intra-F HO triggered PSCell change
    [Arguments]    ${ue_id}=31    ${meas_id_A3}=1    ${Target_phycell_id}=61    ${Target_cell_id}=3    ${nrsrp_nr}=60
    Start RRC Log     PSCell_Change_A3
    ${A3_HO}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 srsrp_nr=50 srsrq_nr=30
    ...    phycell_id=${Target_phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=30
    ${ret1}    Execute Egate Command    ${A3_HO}
    ...    pass_regexp=Proxy \\(eNB 2 cell ${Target_cell_id}\\) reported successful RA
    Should Contain    ${ret1}    a1-Threshold rsrp : 70
    Should Contain    ${ret1}    eventId eventA1
    Should Contain    ${ret1}    sCellToReleaseList
    Should Contain    ${ret1}    timeToTrigger ms320
    Get RRC Log

UE report A2 to trigger Measurement gaps with MeNB coordination
    [Arguments]    ${ue_id}=31    ${meas_id_A2}=2
    Start RRC Log    Measurement_gaps_with_MeNB_coordination
    Execute Egate Command
    ...    ue_enb_param id=${ue_id} measurement_gap=gp0:20 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    ${ret1}    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A2} phycell_id=50 event=A2 srsrp_nr=30 srsrq_nr=40
    ...    pass_regexp=rrcConnectionReconfigurationComplete
    Should Contain    ${ret1}    measGapConfig setup
    Should Contain    ${ret1}    gapOffset gp0 : 20
    Should Contain    ${ret1}    eventId eventA1
    Should Contain    ${ret1}    eventId eventA3
    Should Contain    ${ret1}    reportConfigToRemoveList
    Get RRC Log

Intra-gNB Inter-F HO triggered PSCell change and No Scell add
    [Arguments]    ${ue_id}=31    ${meas_id_A3}=5    ${Target_phycell_id}=60    ${Target_cell_id}=1
    UE report A2 to trigger Measurement gaps with MeNB coordination
    Start RRC Log     PSCell_Change_Inter-F
    ${Inter-F_HO}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 srsrp_nr=50 srsrq_nr=30
    ...    phycell_id=${Target_phycell_id} nrsrp_nr=60 nrsrq_nr=30
    ${ret1}    Execute Egate Command    ${inter-F_HO}
    ...    pass_regexp=measGapConfig release : NULL
    Should Contain    ${ret1}    Proxy (eNB 2 cell ${Target_cell_id}) reported successful RA
    Should Contain    ${ret1}    a1-Threshold rsrp : 70
    Should Contain    ${ret1}    SgNB Modification Confirm
    Should Contain    ${ret1}    a2-Threshold rsrp : 34
    Should Contain    ${ret1}    timeToTrigger ms320
    Should Not Contain    ${ret1}    sCellToAddModList
    Get RRC Log

Intra-gNB Inter-F HO triggered PSCell change and Scell add
    [Arguments]    ${ue_id}=31    ${meas_id_A3}=6    ${Target_phycell_id}=50    ${Target_cell_id}=2
    UE report A2 to trigger Measurement gaps with MeNB coordination
    Start RRC Log     PSCell_Change_Inter-F
    ${Inter-F_HO}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 srsrp_nr=50 srsrq_nr=30
    ...    phycell_id=${Target_phycell_id} nrsrp_nr=75 nrsrq_nr=30
    ${ret1}    Execute Egate Command    ${inter-F_HO}
    ...    pass_regexp=measGapConfig release : NULL
    Should Contain    ${ret1}    Proxy (eNB 2 cell ${Target_cell_id}) reported successful RA
    Should Contain    ${ret1}    SgNB Modification Confirm
    Should Contain    ${ret1}    sCellToAddModList
    Get RRC Log

Intra MeNB HO triggered PSCell Change and Scell add
    [Arguments]    ${ue_id}=31    ${cell_id_Target_eNB}=2    ${Target_cell_id_gNB}=1
    ...    ${candidate_cells_mn_hex_for_menb_ho}=${EMPTY}
    Start RRC Log     PSCell_Change_IntraMeNB_HO
    Execute Egate Command    enb_cell_param enb=1 id=${cell_id_Target_eNB} allow_endc=on
    Execute Egate Command    ue_enb_endc_param id=31 candidate_cells_mn_hex_for_menb_ho=${candidate_cells_mn_hex_for_menb_ho}
    ${ret1}    Execute Egate Command    ue_ho enb=1 cell=${cell_id_Target_eNB} id=${ue_id}
    ...    pass_regexp=Proxy \\(eNB 2 cell ${Target_cell_id_gNB}\\) reported successful RA
    Should Contain    ${ret1}    eventId eventA2
    Should Contain    ${ret1}    a2-Threshold rsrp : 50
    Should Contain    ${ret1}    sCellToAddModList
    Should Contain    ${ret1}    eventId eventA1
    Should Contain    ${ret1}    a1-Threshold rsrp : 80
    Get RRC Log

Intra MeNB HO triggered PSCell Change and Scell add_No_Scell_A1
    [Arguments]    ${ue_id}=31    ${cell_id_Target_eNB}=2    ${Target_cell_id_gNB}=1
    ...    ${candidate_cells_mn_hex_for_menb_ho}=${EMPTY}
    Start RRC Log     PSCell_Change_IntraMeNB_HO
    Execute Egate Command    enb_cell_param enb=1 id=${cell_id_Target_eNB} allow_endc=on
    Execute Egate Command    ue_enb_endc_param id=31 candidate_cells_mn_hex_for_menb_ho=${candidate_cells_mn_hex_for_menb_ho}
    ${ret1}    Execute Egate Command    ue_ho enb=1 cell=${cell_id_Target_eNB} id=${ue_id}
    ...    pass_regexp=Proxy \\(eNB 2 cell ${Target_cell_id_gNB}\\) reported successful RA
    Should Contain    ${ret1}    sCellToAddModList
    Get RRC Log

Inter MeNB HO triggered PSCell Change and Scell add
    [Arguments]    ${ue_id}=31    ${eNB_id}=11    ${Target_cell_id_eNB}=1    ${Target_cell_id_gNB}=1
    ...    ${candidate_cells_mn_hex_for_menb_ho}=${EMPTY}
    Start RRC Log     PSCell_Change_InterMeNB_HO
    Execute Egate Command    enb_cell_param enb=${eNB_id} id=${Target_cell_id_eNB} allow_endc=on
    Execute Egate Command    enb_param id=${eNB_id} candidate_cells_mn_hex_for_menb_ho=${candidate_cells_mn_hex_for_menb_ho}
    ${ret1}    Execute Egate Command    ue_ho enb=${eNB_id} cell=${Target_cell_id_eNB} id=${ue_id}
    ...    pass_regexp=Proxy \\(eNB 2 cell ${Target_cell_id_gNB}\\) reported successful RA
    Should Contain    ${ret1}    eventId eventA2
    Should Contain    ${ret1}    a2-Threshold rsrp : 50
    Should Contain    ${ret1}    sCellToAddModList
    Should Contain    ${ret1}    eventId eventA1
    Should Contain    ${ret1}    a1-Threshold rsrp : 80
    Get RRC Log

Inter MeNB HO triggered PSCell Change and No Scell add
    [Arguments]    ${ue_id}=31    ${eNB_id}=11    ${Target_cell_id_eNB}=1    ${Target_cell_id_gNB}=1
    ...    ${candidate_cells_mn_hex_for_menb_ho}=${EMPTY}    ${allowed_bc_list}=disabled
    Start RRC Log     PSCell_Change_InterMeNB_HO
    Execute Egate Command    enb_cell_param enb=${eNB_id} id=${Target_cell_id_eNB} allow_endc=on
    Execute Egate Command    enb_endc_param id=${eNB_id} allowed_bc_list_mrdc=${allowed_bc_list}
    Execute Egate Command    enb_param id=${eNB_id} candidate_cells_mn_hex_for_menb_ho=${candidate_cells_mn_hex_for_menb_ho}
    ${ret1}    Execute Egate Command    ue_ho enb=${eNB_id} cell=${Target_cell_id_eNB} id=${ue_id}
    ...    pass_regexp=Proxy \\(eNB 2 cell ${Target_cell_id_gNB}\\) reported successful RA
    Should Contain    ${ret1}    Dual Connectivity reconfiguration is successful
    Should Not Contain    ${ret1}    sCellToAddModList
    Should Contain    ${ret1}    eventId eventA1
    Should Contain    ${ret1}    a1-Threshold rsrp : 70
    Get RRC Log

UE report A1 and A2 immediately Without RRC Log
    [Arguments]    ${meas_id}=3    ${phycell_id}=60
    FOR    ${meas_ids}    IN    @{meas_id.split(",")}
        Pcell A1 report to trigger Scell Addition Without RRC Log    meas_id=${meas_ids}    phycell_id=${phycell_id}
        Scell A2 report immediately to trigger Scell Release Without RRC Log    meas_id=${${meas_ids}+1}
    END

Pcell A1 report to trigger Scell Addition Without RRC Log
    [Arguments]    ${ue_id}=31    ${meas_id}=3    ${phycell_id}=60
    ${A1_Scell_addition}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} event=A1
    ...    srsrp_nr=80 srsrq_nr=40
    ${ret1}=    Execute Egate Command    ${A1_Scell_addition}    SgNB Modification Confirm
    Should Contain    ${ret1}    eventId eventA2
    Should Contain    ${ret1}    a2-Threshold rsrp : 50
    Should Contain    ${ret1}    sCellToAddModList
    Should Contain    ${ret1}    eventId eventA1
    Should Contain    ${ret1}    a1-Threshold rsrp : 80

Scell A2 report immediately to trigger Scell Release Without RRC Log
    [Arguments]    ${ue_id}=31    ${meas_id}=4
    ${A2_Scell_Release}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} scell=9 scell_rsrp=40 scell_rsrq=0 event=A2
    ${ret1}=    Execute Egate Command    ${A2_Scell_Release}    SgNB Modification Confirm
    Should Contain    ${ret1}    eventA1
    Should Contain    ${ret1}    sCellToReleaseList
    Should Contain    ${ret1}    timeToTrigger ms5120