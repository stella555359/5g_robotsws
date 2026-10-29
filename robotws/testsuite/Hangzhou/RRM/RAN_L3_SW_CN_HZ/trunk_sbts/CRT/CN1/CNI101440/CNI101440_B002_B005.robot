*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env And Start TCE
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO
...    team-CN1ET    owner-jun.15.zhang    release-5G24R2     CNI101440
Resource          ../../../../resources/DevHZ5_resource.robot


Documentation    Suite description
...   author:      Yuhua Zhu
...   contact:     yuhua.zhu@nokia-sbell.com
...   squad group: MMW_SG7
...   Feature:     CNI101440

*** Variables ***
@{PARAMS_IN_SWCONFIG}
...    0x5A0609=1    #L2-HI rdDebugPcmdNrt
...    0x5A0610=1    #L2-HI rdDebugPcmdRt
...    0x5B0609=1    #L2-HI rdDebugPcmdNrt
...    0x5B0610=1    #L2-HI rdDebugPcmdRt
...    0x57000E=1    #enable L2-LO NRT PCMD debug logs
...    0x58057a=4    #L2-PS rdFeatureFlagBitmapLevel 4DEBUG
...    0x58057b=8    #L2-PSrdFeatureFlagBitmap0 8PF_METRIC
...    0x580582=3    #L2-PSrdFeatureFlagBitmap7 3RAT1_ALLOC
...    0x58057f=0x10000000     #L2-PSrdFeatureFlagBitmap4

${SYSCOM_FLAG}    ${True}

${TL_TYPE_PATH}    fddtdd_sansa_cmwv/3cells_1T2F

@{PARAMS_IN_SCF}
...    @{TCE}
...    @{PCMD_Enable}
#...    @{CellTrace_Disable}
#...    @{MDT_Disable}
...    @{CellTrace_Enable}
...    @{MDT_Enable}
...    @{PCMD_DU_Enable}
...    @{CNI_Base}
...    @{CA}
...    @{NRCELL}
...    @{NRREL}
...    @{NRHOIF}

@{TCE}
...    MRBTS/MNL-1/TCEADM-1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIpAddress=${TCE_IP}
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tcePortNumber=${TCE_PORT}
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tlsEnabled=false
...    NRBTS/NRCTRLTS-1
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:cellMaxActiveUEsTraced=100
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrTceIdentifier=1
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:scope=allResources
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mcc=311
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mnc=489
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mncLength=3
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:traceId=1
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:tracePCMDSetting=all
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:tracePCMDSetting=all

@{PCMD_Enable}
...    NRBTS:actPCMDReport=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actPCMDReporting=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:jobType=TraceOnly

@{CellTrace_Disable}
...    NRBTS:actCellTraceReport=false
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=false
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceE1Setting=none
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceF1Setting=none
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNRRRCSetting=none
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceX2Setting=none
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=none
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceXNSetting=none

@{MDT_Disable}
...    NRBTS:actMDTTraceReport=false
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:jobType=TraceOnly

@{CellTrace_Enable}
...    NRBTS:actCellTraceReport=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceE1Setting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceF1Setting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNRRRCSetting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceX2Setting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceXNSetting=all

@{MDT_Enable}
...    NRBTS:actMDTTraceReport=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:jobType=ImmediateMDTAndTrace
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:mdtMeasType=periodic
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:reportAmount=infinity
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:reportInterval=ms5120
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTControl:cellMaxActiveMDTUEsTraced=10

@{PCMD_DU_Enable}
...    NRBTS/NRDU-1/NRCTRLTSDU-1
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:actPCMDReporting=true
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:jobType=TraceOnly
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrTceIdentifier=1
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:scope=allResources
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mcc=311
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mnc=489
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:mncLength=3
...    NRBTS/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1:nrRanTraceReference:traceId=1

@{CNI_Base}
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:actInterGnbRREPreparedCell=true
...    NRBTS:actGnbInitRlf=true
...    NRBTS:actIpThpt=true
...    NRBTS:actIncXn=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actInterRatHoSA=false
...    NRBTS:actInterRatHoSADlDataForward=false
...    NRBTS:actIntraFreqHoSA=false
...    NRBTS:gNbCuType=SA+NSA
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:act3gppBL23R1=true
...    NRBTS:drbRrcInactInactivityTimerSA=20
...    NRBTS:drbInactivityTimerSA=30
...    NRBTS:srbInactivityTimerSA=30
...    NRBTS:maxUeRrcInactTime=60
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:rrcInactPreferredStateEnabled=false
...    NRBTS:tRanPagingGuard=4
...    NRPMRNL-1:miNrRelReportCu=15min

${CA_support_list}
...    ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd

@{CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:maxNumScellsDl=3
...    NRBTS:maxNumScellsUl=3
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:dlToUlContributionRatio=50
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:fr1UlCaPreferred=dataRatePreferred
...    NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL-2:increasePUSCHPrepTimeULCA=true
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:allowUnsuppBcOrBcs=accept unknown BCSs
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:weightForSCellSelection=80
...    NRCELL-2:weightForSCellSelection=60
...    NRCELL-3:weightForSCellSelection=40

@{NRCELL}
...    NRCELL-3/NRCELL_FDD-1:nrarfcnDl=124580
...    NRCELL-3/NRCELL_FDD-1:nrarfcnUl=133780
...    NRCELL-3:gscnOrSsPbchArfcn=1555
...    NRCELL-3:type0CoresetConfigurationIndex=0
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=5
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=20
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms100
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=5
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL:measGapSelectionSA=favourUeThroughput

@{NRREL}
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=-6dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=-8dB
...    NRCELL-1/NRREL-2:gNbId=2
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=-6dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=-8dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=-6dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=-8dB
...    NRCELL-2/NRREL-1:gNbId=2
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrpOffset=-6dB
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrqOffset=-8dB
...    NRCELL-2/NRREL-3:gNbId=2
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:lcrId=3
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-3:removeNotAllowed=false
...    NRCELL-2/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=-6dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=-8dB
...    NRCELL-3/NRREL-1:gNbId=2
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:lcrId=1
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=-6dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=-8dB
...    NRCELL-3/NRREL-2:gNbId=2
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:lcrId=2
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-2:sCellOperationalMode=dlAndUl

@{NRHOIF}
...    NRCELL-1/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-2:cellDepType=SA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf3
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-2:ssbFrequency=518670
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-3:cellDepType=SA
...    NRCELL-1/NRHOIF-3:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcDuration=sf3
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-3:ssbFrequency=124370
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:cellDepType=SA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=127210
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-2/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-3:cellDepType=SA
...    NRCELL-2/NRHOIF-3:freqBandIndicatorNR=71
...    NRCELL-2/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-3:ifhoSsbSmtcDuration=sf3
...    NRCELL-2/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-3:ssbFrequency=124370
...    NRCELL-2/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRCELL-2/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-2/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-3/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-1:cellDepType=SA
...    NRCELL-3/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-3/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-3/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-3/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-3/NRHOIF-1:ssbFrequency=127210
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-3/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-2:cellDepType=SA
...    NRCELL-3/NRHOIF-2:freqBandIndicatorNR=41
...    NRCELL-3/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-3/NRHOIF-2:ifhoSsbSmtcDuration=sf3
...    NRCELL-3/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-3/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-3/NRHOIF-2:ssbFrequency=518670
...    NRCELL-3/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRCELL-3/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-3/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160

#FR1 TDD: n41 n78, FDD: n66 n71
#2CC CA_n66A-n78A CA_n41A-n71A CA_n66A-n71A CA_n41A-n66A CA_n71A-n78A CA_n41A-n78A CA_n71(2A)
#3CC CA_n66(2A)-n71A CA_n41A-n66A-n78A CA_n41A-n66A-n71A CA_n41A-n66(2A) CA_n66A-n71A-n78A CA_n41A-n71(2A) CA_n41A-n71A-n78A
${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E01F71B0A303582308682041D211001B5B262AC6873E238F40CFB027C62471E439F
...    51CF9863CA1607038782E007FE0038002F8003A00000E0541B107582308682041E21100195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000
...    07400001C0AA3626EB04610D04083A4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0007400001C0A836236B04610D04083C4220032B
...    64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000E800003801EF0F1340038820000042C040A83C28000E230000010B02B0F11800388200000
...    C2C0AC3C28000E208000010B02B0F13400388C0000042C0AC5C46000E208007104000028581587850001C4D00000C160562E2680071040038500000102C0AC5C4D000E230007
...    11800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26800710400388C0000082C0AC5C28000E23000711800001058158B89A001C46000E1
...    40000040B02B0F11800388C00000C2C0803808D00A2026C0411D4001760F851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28103639F0
...    22408103639F022408103639F022408103639F022408103639F022408103639F022408103639F022408103639F0214081B1CF8002E1E318C6318C6318C6318C3D08C000F000A
...    070500703009401C0018090010180F82400800000004000008020000000100000200800002004000018020000100100000A008004010040100000C0080000700400200000008
...    000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B5933580B581B58095811583B40D04000025949410000196525040
...    000A594901000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334A
...    AAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28780178095028140A05028140A05028140A05028140A0502814001820201803008010021010020080
...    40300610080100602018030080600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406080C0E1416181A202
...    2242628303236383A3E424A4C4E5052545A5E828305A

@{PCell1_3CC_CA}
...    Initial Context Setup Successful
...    pcid:50, scellIdx:1] configure_1_1
...    pcid:61, scellIdx:2] configure_1_1
...    scellIdx:[1-2]\\] configure_0_1    #One UL SCell
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
@{PCell2_3CC_CA}
...    Initial Context Setup Successful
...    pcid:60, scellIdx:1] configure_1_1
...    pcid:61, scellIdx:2] configure_1_1
...    scellIdx:[1-2]\\] configure_0_1    #One UL SCell
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
@{PCell3_3CC_CA}
...    Initial Context Setup Successful
...    pcid:60, scellIdx:1] configure_1_1
...    pcid:50, scellIdx:2] configure_1_1
...    scellIdx:[1-2]\\] configure_0_1    #One UL SCell
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{IntragNB_HO}
...    Intra-eNB handover from EXT_ENB-2.* to EXT_ENB-2.* performed
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{RRE_cause}     handoverFailure    otherFailure    reconfigurationFailure
${RREFB_cause}    reconfigurationFailure
@{RREFB_action}    invalid_short_mac_i    invalid_crnti

${RRC_REESTAB_FALLBACK}             M55124C00502
${RRC_REESTAB_RECONF_FAILURE}       M55124C00503
${RRC_REESTAB_HO_FAILURE}           M55124C00504
${RRC_REESTAB_OTHER_FAILURE}        M55124C00505

${REESTAB_ACC_RECONF_FAIL}          M55124C00510
${REESTAB_ACC_HO_FAIL}              M55124C00511
${REESTAB_ACC_OTHER_FAIL}           M55124C00512
${REESTAB_ACC_FALLBACK}             M55124C00515

${REESTAB_RRCRECONFIG_SUCC}         M55124C00516
${REESTAB_ADMISSION_CTRL}           M55124C00519

${RRC_REESTAB_RECONF_FAILURE_DU}    M55127C00501
${RRC_REESTAB_HO_FAILURE_DU}        M55127C00502
${RRC_REESTAB_OTHER_FAILURE_DU}     M55127C00503

${REESTAB_ACC_RECONF_FAIL_DU}       M55127C00510
${REESTAB_ACC_HO_FAIL_DU}           M55127C00511
${REESTAB_ACC_OTHER_FAIL_DU}        M55127C00512
${RRC_REESTAB_DISCARD_DU}           M55127C00513

@{PM_COUNTER_B002}
#RRE
...    NRCELL-1:NRRCC:${RRC_REESTAB_RECONF_FAILURE}=2     #1 RRE + 1 RRE FB
...    NRCELL-1:NRRCC:${REESTAB_ACC_RECONF_FAIL}=1
...    NRCELL-1:NRRCC:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-2:NRRCC:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-2:NRRCC:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-2:NRRCC:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-3:NRRCC:${RRC_REESTAB_HO_FAILURE}=1
...    NRCELL-3:NRRCC:${REESTAB_ACC_HO_FAIL}=1
...    NRCELL-3:NRRCC:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRDU-1:NRRCD:${RRC_REESTAB_RECONF_FAILURE_DU}=4    #1 RRE + 3 RRE FB
...    NRDU-1:NRRCD:${REESTAB_ACC_RECONF_FAIL_DU}=1
...    NRDU-1:NRRCD:${RRC_REESTAB_OTHER_FAILURE_DU}=1
...    NRDU-1:NRRCD:${REESTAB_ACC_OTHER_FAIL_DU}=1
...    NRDU-1:NRRCD:${RRC_REESTAB_HO_FAILURE_DU}=1
...    NRDU-1:NRRCD:${REESTAB_ACC_HO_FAIL_DU}=1
#RRE FB
#...    NRCELL-1:NRRCC:${RRC_REESTAB_RECONF_FAILURE}=2    #1 RRE + 1 RRE FB
...    NRCELL-1:NRRCC:${RRC_REESTAB_FALLBACK}=1
...    NRCELL-1:NRRCC:${REESTAB_ACC_FALLBACK}=1
...    NRCELL-1:NRRCC:${REESTAB_ADMISSION_CTRL}=1
...    NRCELL-2:NRRCC:${RRC_REESTAB_RECONF_FAILURE}=1     #1 RRE FB
...    NRCELL-2:NRRCC:${RRC_REESTAB_FALLBACK}=1
...    NRCELL-2:NRRCC:${REESTAB_ACC_FALLBACK}=1
...    NRCELL-2:NRRCC:${REESTAB_ADMISSION_CTRL}=1
...    NRCELL-3:NRRCC:${RRC_REESTAB_RECONF_FAILURE}=1     #1 RRE FB
...    NRCELL-3:NRRCC:${RRC_REESTAB_FALLBACK}=1
...    NRCELL-3:NRRCC:${REESTAB_ACC_FALLBACK}=1
...    NRCELL-3:NRRCC:${REESTAB_ADMISSION_CTRL}=1
...    NRDU-1:NRRCD:${RRC_REESTAB_DISCARD_DU}=0           #3 RRE FB

@{PM_COUNTER_B005}
#RRE
...    NRCELL-1:NRRCC:${RRC_REESTAB_OTHER_FAILURE}=1
...    NRCELL-1:NRRCC:${REESTAB_ACC_OTHER_FAIL}=1
...    NRCELL-1:NRRCC:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-2:NRRCC:${RRC_REESTAB_HO_FAILURE}=1
...    NRCELL-2:NRRCC:${REESTAB_ACC_HO_FAIL}=1
...    NRCELL-2:NRRCC:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRDU-1:NRRCD:${RRC_REESTAB_OTHER_FAILURE_DU}=1
...    NRDU-1:NRRCD:${REESTAB_ACC_OTHER_FAIL_DU}=1
...    NRDU-1:NRRCD:${RRC_REESTAB_HO_FAILURE_DU}=1
...    NRDU-1:NRRCD:${REESTAB_ACC_HO_FAIL_DU}=1
#RRE FB
...    NRCELL-3:NRRCC:${RRC_REESTAB_RECONF_FAILURE}=1
...    NRCELL-3:NRRCC:${RRC_REESTAB_FALLBACK}=1
...    NRCELL-3:NRRCC:${REESTAB_ACC_FALLBACK}=1
...    NRCELL-3:NRRCC:${REESTAB_ADMISSION_CTRL}=0
...    NRDU-1:NRRCD:${RRC_REESTAB_RECONF_FAILURE_DU}=1
...    NRDU-1:NRRCD:${RRC_REESTAB_DISCARD_DU}=0

*** Test Cases ***
CNI101440-ET-B002_Monitoring_Of_PCMD_Records_For_Intra_gNB_Inter_Cell_RRC_Reestablishment_Or_RRC_Reestablishment_Fallback_TFF_Config
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    This case will verify intra gnb RRE, F=>T, T=>F, F=>F
    ...    This case will verify intra gnb RRE Fallback, F=>T, T=>F, F=>F
    ...    Notes: For Carrier Aggregation configurations, blind Secondary Cell addition is not supported after RRC reestablishment procedure is
    ...           performed on a CA-enabled UE. Only measurement-based SCelladdition is supported after such procedure.
    ...    [Configuration]:
    ...        GNBID       CELLID    band          nrarfcn    gscn    ssbFrequency    phycell_id
    ...    GNB-2(id=1)     CELL-1     n71    134980:127180    1589          127210            60
    ...                    CELL-2     n41           518598    6483          518670            50
    ...                    CELL-3     n71    133780:124580    1555          124370            61
    [Tags]    QC_47168    B002    CA_LABEL-TFF(20MHz_TDD_n41+10MHz_FDD_n71)
    Clear Counter Files    wait=${False}
    UE Attach And Blind Scell Addition    ue_id=1

    UE Trigger Intra gNB RRC Reestablish Due To otherFailure    ue_id=1    TargetCell_id=2    source_carrierfreq=518670
    UE Trigger Intra gNB RRC Reestablish Due To handoverFailure    ue_id=1    TargetCell_id=3    source_carrierfreq=124370
    UE Trigger Intra gNB RRC Reestablish Due To reconfigurationFailure    ue_id=1    TargetCell_id=1

    UE Trigger RRC Reestablish With Fallback    ue_id=1    TargetCell_id=2    blind_CA=${PCell2_3CC_CA}    source_carrierfreq=518670
    UE Trigger RRC Reestablish With Fallback    ue_id=1    TargetCell_id=3    blind_CA=${PCell3_3CC_CA}    source_carrierfreq=124370    maxULindex=3
    UE Trigger RRC Reestablish With Fallback    ue_id=1    TargetCell_id=1    blind_CA=${PCell1_3CC_CA}

    SA UE Deregister From GNB    ue_id=1
    Check WireShark Log    ${CURDIR}${/}A2A${/}a2a_B002.ini    wait_string=UEContextReleaseComplete::28
    Check Counters    ${PM_COUNTER_B002}

CNI101440-ET-B005_Monitoring_Of_PCMD_Records_For_Intra_Cell_RRC_Reestablishment_Or_RRC_Reestablishment_Fallback_TFF_Config
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    This case will verify intra cell RRE, F=>F, T=>T
    ...    This case will verify intra cell RRE Fallback, F=>F
    ...    [Configuration]:
    ...        GNBID       CELLID    band          nrarfcn    gscn    ssbFrequency    phycell_id
    ...    GNB-2(id=1)     CELL-1     n71    134980:127180    1589          127210            60
    ...                    CELL-2     n41           518598    6483          518670            50
    ...                    CELL-3     n71    133780:124580    1555          124370            61
    [Tags]    QC_47169    B005    CA_LABEL-TFF(20MHz_TDD_n41+10MHz_FDD_n71)
    Clear Counter Files    wait=${False}
    UE Attach And Blind Scell Addition    ue_id=2

    UE Trigger Intra gNB RRC Reestablish Due To otherFailure    ue_id=2    TargetCell_id=1
    UE Trigger Inter-Frequency Intra-gnb HO To Real gNB Cell2    ue_id=2
    UE Trigger Intra gNB RRC Reestablish Due To handoverFailure    ue_id=2    TargetCell_id=2    source_carrierfreq=518670
    UE Trigger Inter-Frequency Intra-gnb HO To Real gNB Cell3    ue_id=2
    UE Trigger RRC Reestablish With Fallback    ue_id=2    TargetCell_id=3    blind_CA=${PCell3_3CC_CA}    source_carrierfreq=124370    maxULindex=3

    SA UE Deregister From GNB    ue_id=2
    Check WireShark Log    ${CURDIR}${/}A2A${/}a2a_B005.ini    wait_string=UEContextReleaseComplete::20
    Check Counters    ${PM_COUNTER_B005}

*** Keywords ***
Common Suite Setup And Setup Airphone Env And Start TCE
    Common Suite Setup
    Setup Airphone Env    tl_type=${TL_TYPE_PATH}    ue_count=2
    run keyword if   ${DEBUG}==${True}    Perform Steps After Onair

Modify Cfg
    Update Cfg Param    set_cell id=3 gnb=2 pci=20:1 nr_arfcn=133780:124580 gscn=1555
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_perUE_Full}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_perUE_Full}

Perform Steps After Onair
    Start TCE    ${TCE_PORT}

UE Attach And Blind Scell Addition
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${blind_CA}=${PCell1_3CC_CA}    ${source_carrierfreq}=127210
    BuiltIn.Log    UE${ue_id} Attach And Blind Scell Addition...    console=${True}
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${blind_CA}    timeout=20s
    ...    sleep_time=5
    UE PeriodicUeMeas Config    ue_id=${ue_id}    source_carrierfreq=${source_carrierfreq}
    UE Start Trf    ue_id=${ue_id}    maxULindex=2

UE PeriodicUeMeas Config
    [Arguments]    ${ue_id}=1    ${source_carrierfreq}=127210
    BuiltIn.Log    UE${ue_id} PeriodicUeMeas Config...    console=${True}
    ${Periodical_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${source_carrierfreq}
    ...    event_type=Periodical
    Should Not Be Empty    ${Periodical_meas_id}
    ${cmd}     Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${Periodical_meas_id} report_type=periodical
    ...    srsrp_nr=${ue_id} srsrq_nr=30 ssinr_nr=30 srs_result=0:50:50:50
    Execute Egate Command    ${cmd}    pass_regexp=For Periodic MeasId = .* MeasReportQuantity from RRC-reconfiguration

UE Start Trf
    [Documentation]
    ...    Max Throughput For each Cell:
    ...    NRCELLGRP      NRCELL      DL tput       UL tput
    ...    NRCELLGRP-0    NRCELL-1    92.2 Mbps     67.2 Mbps
    ...    NRCELLGRP-1    NRCELL-2    131.8 Mbps    34.0 Mbps
    ...    NRCELLGRP-2    NRCELL-3    92.6 Mbps     67.2 Mbps
    [Arguments]    ${ue_id}=1    ${maxULindex}=2
    BuiltIn.Log    UE${ue_id} Start Trf...    console=${True}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=1    pass_regexp=UDP DL TRF
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    pass_regexp=UDP DL TRF
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=40 trf_id=3    pass_regexp=UDP UL TRF
    Show Scell PDSCH And PUSCH Throughput    ue_id=${ue_id}
    Verify Throughput CA    ue_id=${ue_id}    maxULindex=${maxULindex}

Show Scell PDSCH And PUSCH Throughput
    [Arguments]    ${ue_id}=1
    sleep    15s    #wait trf stable
    Execute Egate Command    bearer_stats ue=${ue_id} pdu=1 qfi=1 dir=dl    Average data rate
    Execute Egate Command    bearer_stats ue=${ue_id} pdu=1 qfi=1 dir=ul    Average data rate
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0 *0
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0 *0

Verify Throughput CA
    [Arguments]    ${ue_id}=1    ${maxDLindex}=3    ${maxULindex}=2    ${dl}=270    ${ul}=36
    ${dl_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${maxDLindex}
        ${sid}    convert to string    ${id}
        ${result}    ${scell_tput}    Run Keyword And Ignore Error    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${sid}
        ...    type=pdsch    rate_type=ave
        Continue For Loop If    '${result}' == 'FAIL'
        Should Be True    ${scell_tput}/1000 > 0
        ${dl_tput}    Evaluate    ${dl_tput}+${scell_tput}
    END
    Should Be True    ${dl_tput}/1000>${dl}
    ${ul_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${maxULindex}
        ${sid}    convert to string    ${id}
        ${result}    ${scell_tput}    Run Keyword And Ignore Error    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${sid}
        ...    type=pusch    rate_type=ave
        Continue For Loop If    '${result}' == 'FAIL'
        Should Be True    ${scell_tput}/1000 > 0
        ${ul_tput}    Evaluate    ${ul_tput}+${scell_tput}
    END
    Should Be True    ${ul_tput}/1000>${ul}

Verify Throughput No CA
    [Arguments]    ${ue_id}=1    ${dl}=80    ${ul}=27
    ${dl_throughput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Trigger UE With A2 Measurement Report
    [Arguments]    ${ue_id}=1    ${carrierfreq}=127210
    BuiltIn.Log    UE${ue_id} Send A2 Measurement Report...    console=${True}
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfiguration    timeout=20s

UE Trigger Intra gNB RRC Reestablish Due To otherFailure
    [Arguments]    ${ue_id}=1    ${TargetCell_id}=1    ${RRE_cause}=otherFailure    ${source_carrierfreq}=127210
    BuiltIn.Log    UE${ue_id} Trigger Intra gNB RRC Reestablish...    console=${True}
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${TargetCell_id} cause=${RRE_cause}
    ...    pass_regexp=NR RRC Reestablishment sucessfully completed    timeout=20s
    UE PeriodicUeMeas Config    ue_id=${ue_id}    source_carrierfreq=${source_carrierfreq}
    sleep    5s    #wait trace session in source cell be cleared
    Execute Egate Command    ue_disp    pass_regexp=Configured UEs
    Show Scell PDSCH And PUSCH Throughput    ue_id=${ue_id}
    Verify Throughput No CA    ue_id=${ue_id}

UE Trigger Intra gNB RRC Reestablish Due To handoverFailure
    [Arguments]    ${ue_id}=1    ${TargetCell_id}=1    ${RRE_cause}=handoverFailure    ${source_carrierfreq}=127210
    BuiltIn.Log    UE${ue_id} Trigger Intra gNB RRC Reestablish...    console=${True}
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${TargetCell_id} cause=${RRE_cause}
    ...    pass_regexp=NR RRC Reestablishment sucessfully completed    timeout=20s
    UE PeriodicUeMeas Config    ue_id=${ue_id}    source_carrierfreq=${source_carrierfreq}
    sleep    5s    #wait trace session in source cell be cleared
    Execute Egate Command    ue_disp    pass_regexp=Configured UEs
    Show Scell PDSCH And PUSCH Throughput    ue_id=${ue_id}
    Verify Throughput No CA    ue_id=${ue_id}    ul=16

UE Trigger Intra gNB RRC Reestablish Due To reconfigurationFailure
    [Arguments]    ${ue_id}=1    ${TargetCell_id}=1    ${RRE_cause}=reconfigurationFailure    ${source_carrierfreq}=127210
    BuiltIn.Log    UE${ue_id} Trigger Intra gNB RRC Reestablish...    console=${True}
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${TargetCell_id} cause=${RRE_cause}
    ...    pass_regexp=NR RRC Reestablishment sucessfully completed    timeout=20s
    UE PeriodicUeMeas Config    ue_id=${ue_id}    source_carrierfreq=${source_carrierfreq}
    sleep    5s    #wait trace session in source cell be cleared
    Execute Egate Command    ue_disp    pass_regexp=Configured UEs
    Show Scell PDSCH And PUSCH Throughput    ue_id=${ue_id}
    Verify Throughput No CA    ue_id=${ue_id}

Get Random Fallback Action
    ${random_fallback_action}    Evaluate    random.choice(${RREFB_action})    random
    Set Test Variable    \${random_fallback_action}

UE Trigger RRC Reestablish With Fallback
    [Arguments]    ${ue_id}=1    ${TargetCell_id}=1    ${blind_CA}=${PCell1_3CC_CA}    ${source_carrierfreq}=127210    ${maxULindex}=2
    BuiltIn.Log    UE${ue_id} Trigger RRC Reestablish With Fallback...    console=${True}
    Get Random Fallback Action
    ${cmd_RRE}    Catenate    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${TargetCell_id} cause=${RREFB_cause} action=${random_fallback_action}
    Execute Egate Command    ${cmd_RRE}    pass_regexp=${blind_CA}    timeout=20s
    UE PeriodicUeMeas Config    ue_id=${ue_id}    source_carrierfreq=${source_carrierfreq}
    Execute Egate Command    ue_disp    pass_regexp=Configured UEs
    UE Start Trf    ue_id=${ue_id}    maxULindex=${maxULindex}

UE Trigger Inter-Frequency Intra-gnb HO To Real gNB Cell2
    [Arguments]    ${ue_id}=1    ${source_carrierfreq}=127210    ${target_carrierfreq}=518670
    BuiltIn.Log    UE${ue_id} Trigger Inter-Frequency Intra-gnb HO To Real gNB Cell2...    console=${True}
    Trigger UE With A2 Measurement Report    ue_id=${ue_id}    carrierfreq=${source_carrierfreq}
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${target_carrierfreq}    event_type=A3
    ${cmd_HO}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=80
    Execute Egate Command    ${cmd_HO}    pass_regexp=${IntragNB_HO}
    UE PeriodicUeMeas Config    ue_id=${ue_id}    source_carrierfreq=${target_carrierfreq}
    Execute Egate Command    ue_disp    pass_regexp=Configured UEs
    Show Scell PDSCH And PUSCH Throughput    ue_id=${ue_id}
    Verify Throughput CA    ue_id=${ue_id}    ul=32

UE Trigger Inter-Frequency Intra-gnb HO To Real gNB Cell3
    [Arguments]    ${ue_id}=1    ${source_carrierfreq}=518670    ${target_carrierfreq}=124370
    BuiltIn.Log    UE${ue_id} Trigger Inter-Frequency Intra-gnb HO To Real gNB Cell3...    console=${True}
    Trigger UE With A2 Measurement Report    ue_id=${ue_id}    carrierfreq=${source_carrierfreq}
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${target_carrierfreq}    event_type=A3
    ${cmd_HO}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=61 nrsrp_nr=80
    Execute Egate Command    ${cmd_HO}    pass_regexp=${IntragNB_HO}
    UE PeriodicUeMeas Config    ue_id=${ue_id}    source_carrierfreq=${target_carrierfreq}
    Execute Egate Command    ue_disp    pass_regexp=Configured UEs
    Show Scell PDSCH And PUSCH Throughput    ue_id=${ue_id}
    Verify Throughput CA    ue_id=${ue_id}    maxULindex=3

SA UE Deregister From GNB
    [Arguments]  ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=detached    sleep_time=5
