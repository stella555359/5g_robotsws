*** Settings ***
Suite Setup       Common Suite Setup And Setup 2CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CRT
...               CLOUD_R4LAPO_CUS    team-DevHZ5_SG4    owner-kexin.zhou/hanpei    release-L18A
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${GSCN7881}    636672

@{PARAMS_IN_SCF}
...    @{Fix_Relation_Error_Enb1}
...    @{CA}
...    @{x2link}
...    @{LTE4088}
...    @{LTE4193}
...    @{LTE4549}
...    @{activatedMimoTM}
...    @{Tput_parameter}
...    @{LTE5761}
...    @{nrRestrictionOverride}
...    @{CELL_CHANNELGROUP}
...    @{Handover}
...    LNCEL/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL/LNCEL_FDD-0:maxNumUeDl=14
...    LNCEL/LNCEL_FDD-0:maxNumUeUl=14
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=500
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1300
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=2850
...    LNCEL-4/LNCEL_FDD-0:earfcnDL=3048
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=18500
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19300
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=20850
...    LNCEL-4/LNCEL_FDD-0:earfcnUL=21048
...    @{InterEnbDLCA_ENB1}
...    LNBTS-1:actCellTrace=true

@{PARAMS_IN_SCF_ENB2}
...    @{Fix_Relation_Error_Enb2}
...    @{CA_ENB2}
...    @{InterEnbDLCA_ENB2}
...    @{Tput_parameter}
...    @{activatedMimoTM}
...    @{CELL_CHANNELGROUP_ENB2}
...    LNCEL/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL/LNCEL_FDD-0:maxNumUeDl=14
...    LNCEL/LNCEL_FDD-0:maxNumUeUl=14
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1500
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1698
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=3048
...    LNCEL-4/LNCEL_FDD-0:earfcnDL=3248
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19500
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19698
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=21048
...    LNCEL-4/LNCEL_FDD-0:earfcnUL=21248

@{Fix_Relation_Error_Enb1}
...    LNBTS-1:actAmbrModCaTrigger=false
...    LNBTS-1:actEndcSpidFwd=false
...    LNBTS-1:actIscaHarqEnh=false
...    LNBTS-1:tS1eRABModInd=2000
...    LNBTS-1:endcSchedWeightBoostDl=2
...    LNBTS-1:endcSchedWeightBoostUl=2
...    LNBTS-1:actTransmittedBelowGap=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51

@{Fix_Relation_Error_Enb2}
...    LNBTS-2:actAmbrModCaTrigger=false
...    LNBTS-2:actEndcSpidFwd=false
...    LNBTS-2:actIscaHarqEnh=false
...    LNBTS-2:tS1eRABModInd=2000
...    LNBTS-2:endcSchedWeightBoostDl=2
...    LNBTS-2:endcSchedWeightBoostUl=2
...    LNBTS-2:actTransmittedBelowGap=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNBTS-2/LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnEarfcn=1500

@{CA}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAdvScellMeas=true
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=5
...    LNCEL:maxNumScells=4
...    LNBTS-1/CADPR-0:maxNumMimoLayerFdd=16
...    LNCEL:caPoolId=1
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-3:lcrId=4
...    LNCEL-1/CAREL-3:lnBtsId=1
...    LNCEL-1/CAREL-3:maxNumOfSuppMimoLayer=4-layer
...    delete:LNCEL-1/CAREL-2:beamformingInScellAllowed
...    delete:LNCEL-1/CAREL-3:beamformingInScellAllowed
...    LNBTS-1:sCellDeactivationTimereNB=rf128
...    LNBTS-1:actAdvStepwiseScellAdd=buffer-based
...    LNBTS-1:actFlexScellSelect=true
...    LNBTS-1:actFlexCaMgmt=false
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:actScellConfigForHiDemand=false
...    LNCEL:actFlowCtrlEnh=false
...    LNCEL:scellFastSchedulingSelect=normal
...    LNCEL:dlCaMinPcellCqi=0
...    LNCEL:dlCaMinPcellCqiQci1=0
...    LNCEL:ulCaMinPcellSinr=0
...    LNCEL:ulCaMinPcellSinrQci1=0
...    LNCEL-3/CAREL-1:lcrId=1
...    LNCEL-3/CAREL-1:lnBtsId=1
...    LNCEL-3/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-3/CAREL-2:lcrId=2
...    LNCEL-3/CAREL-2:lnBtsId=1
...    LNCEL-3/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-3/CAREL-3:lcrId=4
...    LNCEL-3/CAREL-3:lnBtsId=1
...    LNCEL-3/CAREL-3:maxNumOfSuppMimoLayer=4-layer
...    delete:LNCEL-3/CAREL-1:beamformingInScellAllowed
...    delete:LNCEL-3/CAREL-2:beamformingInScellAllowed
...    delete:LNCEL-3/CAREL-3:beamformingInScellAllowed

@{CA_ENB2}
...    LNBTS-2:actDLCAggr=true
...    LNBTS-2:actAdvScellMeas=true
...    LNBTS-2:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS-2/LNBTS_FDD-0:numTxWithHighNonGbr=5
...    LNCEL:maxNumScells=4
...    LNBTS-2/CADPR-0:maxNumMimoLayerFdd=16
...    LNCEL:caPoolId=1
...    LNBTS-2:actFlexScellSelect=true
...    LNBTS-2:sCellDeactivationTimereNB=rf128
...    LNBTS-2:actAdvStepwiseScellAdd=buffer-based
...    LNBTS-2:actFlexCaMgmt=false
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:actScellConfigForHiDemand=false
...    LNCEL:actFlowCtrlEnh=false
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=false
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None

@{InterEnbDLCA_ENB1}
...    LNBTS-1/LNADJ-2:adjEnbId=2
...    LNBTS-1/LNADJ-2:cPlaneIpAddr=10.0.1.4
...    LNBTS-1/LNADJ-2:cPlaneIpAddrCtrl=oamControlled
...    LNBTS-1/LNADJ-2:rlfBasedRCRsupported=false
...    LNBTS-1/LNADJ-2:plmnId:mcc=262
...    LNBTS-1/LNADJ-2:plmnId:mnc=3
...    LNBTS-1/LNADJ-2:plmnId:mncLength=2
...    LNBTS-1:actInterEnbDLCAggr=true
...    LNBTS-1:caClusterId=1
...    LNBTS-1:caClusterMemberId=1
...    LNBTS-1:caSchedFairFact=1
...    LNBTS-1/CAGENB-0:caClusterEnbList:lnBtsId=2
...    LNBTS-1/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    MNL-1/MNLENT-1/SYNC-1:btsSyncMode=PhaseSync
...    LNBTS-1/CAGENB-0:nlcvDeltaX2C2=2
...    LNBTS-1/CAGENB-0:caScellSchedWtFactMinCqi=6
...    LNCEL:cqiPerSbCycK=1
...    LNCEL-1/CAREL-4:lcrId=51
...    LNCEL-1/CAREL-4:lnBtsId=2
...    LNCEL-1/CAREL-4:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-5:lcrId=52
...    LNCEL-1/CAREL-5:lnBtsId=2
...    LNCEL-1/CAREL-5:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-6:lcrId=53
...    LNCEL-1/CAREL-6:lnBtsId=2
...    LNCEL-1/CAREL-6:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-7:lcrId=54
...    LNCEL-1/CAREL-7:lnBtsId=2
...    LNCEL-1/CAREL-7:maxNumOfSuppMimoLayer=4-layer
...    delete:LNCEL-1/CAREL-4:beamformingInScellAllowed
...    delete:LNCEL-1/CAREL-5:beamformingInScellAllowed
...    delete:LNCEL-1/CAREL-6:beamformingInScellAllowed
...    delete:LNCEL-1/CAREL-7:beamformingInScellAllowed

@{InterEnbDLCA_ENB2}
...    LNBTS-2:actInterEnbDLCAggr=true
...    LNBTS-2:caClusterId=1
...    LNBTS-2:caClusterMemberId=2
...    LNBTS-2:caSchedFairFact=1
...    LNBTS-2/CAGENB-0:caClusterEnbList:lnBtsId=1
...    LNBTS-2/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    MNL-1/MNLENT-1/SYNC-1:btsSyncMode=PhaseSync
...    LNCEL:cqiPerSbCycK=1

@{x2link}
...    LNBTS-1/LNADJGNB-1:administrativeState=unlocked
...    LNBTS-1/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNCEL/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2

@{LTE4088}
...    LNBTS-1:actLteNrDualConnectivity=true
...    LNBTS-1:tLteNrDualConnectPrep=5000
...    LNCEL:defaultLnRelGnbCellId=1
...    LNBTS-1:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001

@{LTE4193}
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${GSCN7881}
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=30kHz
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS-1/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS-1/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS-1/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS-1/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS-1/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS-1:actDynTrigLteNrDualConnectivity=true
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=false
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None

@{LTE4549}
...    LNBTS-1:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS-1:enableBwCombCheck=true
...    LNBTS-1/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS-1/NRDCDPR-0:allowedBcSelectMethod=max MIMO layers

@{LTE5761}
...    LNBTS-1:actEnDcLteDlMimoOptBcSel=true
...    LNBTS-1:actEnDcNrFeatSetIdBcSel=true

@{nrRestrictionOverride}
...    LNBTS-1:nrRestrictionOverride=disabled

@{CELL_CHANNELGROUP}
...    LNCEL-3/LNCEL_FDD-0:dlMimoMode=Closed Loop Mimo
...    delete:MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-3/CHANNELGROUP-1/CHANNEL-5
...    delete:MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-3/CHANNELGROUP-1/CHANNEL-6
...    delete:MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-3/CHANNELGROUP-1/CHANNEL-7
...    delete:MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-3/CHANNELGROUP-1/CHANNEL-8
...    delete:LNCEL-3/LNCEL_FDD-0:activatedMimoTM

@{CELL_CHANNELGROUP_ENB2}
...    LNCEL-2/LNCEL_FDD-0:dlMimoMode=Dynamic Open Loop MIMO
...    delete:MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-52/CHANNELGROUP-1/CHANNEL-5
...    delete:MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-52/CHANNELGROUP-1/CHANNEL-6
...    delete:MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-52/CHANNELGROUP-1/CHANNEL-7
...    delete:MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-52/CHANNELGROUP-1/CHANNEL-8
...    delete:LNCEL-2/LNCEL_FDD-0:activatedMimoTM
...    LNCEL-2/LNCEL_FDD-0:actFastMimoSwitch=false
...    LNCEL-3/LNCEL_FDD-0:dlMimoMode=Closed Loop MIMO (4x2)

@{activatedMimoTM}
...    LNCEL/LNCEL_FDD-0:activatedMimoTM=TM4
...    delete:LNCEL/LNCEL_FDD-0:csiRsConfigInfo

@{Tput_parameter}
...    LNCEL:actModulationSchemeDl=64QAM
...    LNCEL:actModulationSchemeUL=16QAMHighMCS
...    LNCEL:actLdPdcch=true
...    LNCEL/LNCEL_FDD-0:maxNrSymPdcch=3
...    LNCEL:adaptPdcchDwellTime=0
...    LNCEL:mbrSelector=ueCapability
...    LNCEL:actDl256QamChQualEst=false
...    LNCEL:dlTargetBler=100

@{Handover}
...    LNBTS-1:actHoWoSnChg=intraEnbHoEnabled
...    LNBTS-1:actIfHo=enabled
...    LNCEL-1/LNHOIF-1:measurementBandwidth=mbw100
...    LNCEL-1/LNHOIF-1:measQuantInterFreq=rsrp
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=2850
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreq=6
...    LNCEL:threshold2InterFreq=65
...    LNCEL:threshold1=90
...    LNCEL:threshold2a=65
...    LNCEL-3/LNHOIF-1:a3OffsetRsrpInterFreq=6
...    LNCEL-3/LNHOIF-1:a3ReportAmountRsrpInterFreq=infinity
...    LNCEL-3/LNHOIF-1:a3ReportAmountRsrqInterFreq=infinity
...    LNCEL-3/LNHOIF-1:a3ReportIntervalRsrpInterFreq=240ms
...    LNCEL-3/LNHOIF-1:a3TimeToTriggerRsrpInterFreq=320ms
...    LNCEL-3/LNHOIF-1:a5ReportAmountRsrpInterFreq=infinity
...    LNCEL-3/LNHOIF-1:a5ReportAmountRsrqInterFreq=infinity
...    LNCEL-3/LNHOIF-1:a5ReportIntervalInterFreq=240ms
...    LNCEL-3/LNHOIF-1:a5TimeToTriggerInterFreq=256ms
...    LNCEL-3/LNHOIF-1:eutraCarrierInfo=3048
...    LNCEL-3/LNHOIF-1:hysA3OffsetRsrpInterFreq=0
...    LNCEL-3/LNHOIF-1:hysThreshold3InterFreq=0
...    LNCEL-3/LNHOIF-1:interPresAntP=false
...    LNCEL-3/LNHOIF-1:measQuantInterFreq=rsrp
...    LNCEL-3/LNHOIF-1:measurementBandwidth=mbw100
...    LNCEL-3/LNHOIF-1:offsetFreqInter=0dB
...    LNCEL-3/LNHOIF-1:threshold3InterFreq=24
...    LNCEL-3/LNHOIF-1:threshold3aInterFreq=26

${ue_nr_capabilities}
...    SEPARATOR=
...    E100000001477A0302000001404807060E020C000213601073E420F00080C130080C00000A0589BAC219434088107418604C04416C9814060C
...    78C73E420F00580C0E0E02213C84FC4DE05812000000090000020480000280500E018060180601806018065C0280300C0300C032E014010060
...    18065C0280000CB80500602008020085C0280201004010B805000021700A0040300CB805002020085809CA9BCA8ACA1ADD2370802020000083
...    0C0080000A0C3002000044104208000190410820000841042026954C52898AED4572A2BB10

${ue_eutra_nr_capabilities_Case14}
...    SEPARATOR=
...    010C268160041C4D00000004381504C0001031713400000810E0541B00004040818B89A0000080870220D8000202240C5C4D0000060541B000
...    04040818389A00001008702A0D8000202240C1C4D00000A04381506C00010302060E26800006021C0A846000080810302060E26800007021C0
...    885600008081010206040C1C4D0000100400C0000200D0134080800040202004008808040100C020401000080003002006008008C100601008
...    020180410040000C0001800100A000140000800140080180100300600860803008060100802080400002000140008010000A00014000A00C01
...    401802801002300018040006000001000040080118000C02000500000080002008008C08060100802040300006000201000030001801003002
...    00480C02008040100C020180418040000C00010000300030080001000020000600060180002000040000C000E00400C00801801003006008A0
...    4030080601020100003000100C00018000804000080004030000600030020060080080

${ue_eutra_nr_capabilities_Case15}
...    SEPARATOR=
...    010C2E8160041C4D00000004381504C0001031713400000810E0541200060C41C4D00000404381506800101030620E26800003021C0A836000
...    080818300713400002010E0541B00004040818B89A0000140870220D8000202240C5C4D00000C0541B00004044C180389A00001C0870220D00
...    0202260C41C4D0000100541B000060C00818389A00002408702A118000202060C00818389A0000280870200600001006809A05040002010100
...    20044040200806010200800040001801003004004404020000600020080404008180100300400460802000060000C000803000060000800080
...    50080201014020A00400C01802801002300018040006000001004040080118200C020100403008200800018000300020140002800010002801
...    00300200600C010C10060100C0201004100A000040002800100200014000280014018028030050020046000300800140000020080802002304
...    018000300004000400800050000A000402804010080A010500600A00C0140080118200C020180402008200C020100403008200800018000300
...    028010030020060040090180401008020180402008300C0001000030000400060100402008060100C020C02000060000C00010001C00801801
...    00300600A0040080

${ue_eutra_capabilities}
...    SEPARATOR=
...    DDB8050200106050B95FFE172BFFC2E57FF7FDFFFFA8E11D10409D210009408004A24C6F02EB3A0000000A9DF00000002FFC00C00C00C10860
...    84304218210C1086006084304218210C00C00C1086006006184210C308421861084308210C2084308210C30840086100410C01082180010C30
...    840086100410C01082180010C30840086100410C20006180210430040186000430C21002184010430042086000430C21002184010430042086
...    000430C21002184010430800186008410C01006180010C30840086100410C01082180010C30840086100410C01082180010C30840086100410
...    C200061802104300401860004308210C2084308210C2084308210C2084308210C2084308210C2084308210C2084308210C2084308210C20843
...    08210C2084308210C2084308210C2084308210C2084308210C2084308210C2084308210C2084308210C2084308210C2084308210C208430821
...    0C2084308210C2084308210C2084308210C2084308210C2084308210C2084308210C2004308210C2084308210C2084304218210C1086084304
...    218210C10860843082109681F551843F81800008206100020818C000820E300020A0041051820E0000208384000828010414208380000820E0
...    00020A00410300001241C600041420820A3041C200041070800105082081840009206100022838C000828C1040C6000490318001143C600041
...    46082841050020868C1051820E100020A00410D1820A304142083800008216300020A3041C0000410B18001051820A0041091820A3041C0000
...    410F18001050824A0040400801E300020A104840082801003C60004042092801050020078C00080841210020A00410D1820E100024A0040400
...    801A3041C20004840082801003460818400092801050020068C10308001210020A00410D1820A1049C000040400801A3041420918000082801
...    003460828412300001010020868C1010824E000020A00400D182021049C000040400821A3040420918000082801043C6000414208A80101002
...    0078C00082841110020A00400F18001010822A0041400801E300020210444008280104346083840008A801010020068C10708001110020A004
...    00D18206100022A0041400801A3040C20004440082801043460828411700001010020068C10508226000020A00400D1820A1044C0000404008
...    21A30404208B8000082801003460808411700001010020868C10108226000020A00410F18001050820A0040400801E300020A1040400828010
...    03C60004042082801050020078C00080841010020A00410D1820E100020A0040400801A3041C20004040082801003460818400082801050020
...    068C10308001010020A00410D1820A1041C000040400801A3041420818000082801003460828410300001010020868C1010820E000020A0040
...    0D182021041C000040400821A3040420818000082801042C60104942092801042C600049C2000494008216300024A104940082123049C20104
...    940082123049C2000494008212304942093800008216300824A10454008216300024E100022A00410B18001250822A0041091824E100022A00
...    41091824A1045C0000410B18041250820A00410B180012708001050020858C00092841050020848C12708001050020848C1250820E00002085
...    8C0008B8400092801042C600045420928010424608B84020928010424608B84000928010424608A8412700001042C600045C20004540082163
...    00022A104540082123045C200045400821230454208B800008216300022E100020A00410B18001150820A0041091822E100020A0041091822A
...    1041C0000410B18001050824A0049091820E100024A0049091820A1049C0000490B180010708001250020858C00082841250020848C1070804
...    1250020848C10708001250020848C1050824E000020858C00082841150024848C10708001150024848C1050822E000024858C00083840008A8
...    01042C6000414208A80104246083840008A801042460828411700001042C60004142082801242460838400082801242460828410700001242C
...    600041C2000414008216300020A104140082123040C200041C000041091820E100020A0041091820A1041C0000410B18001050020A00410918
...    20E000020A00410718041250020838C000928010414609380000820E300022A0041051822E000020838C000828012414608380000920E30002
...    0E000020858400082841050020FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAF
...    FF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95
...    FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172
...    BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E
...    57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85
...    CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0
...    B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE
...    172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF85CAFFF0B95FFE172BFFC2E57FF6CEC0000CFF887878787
...    43C3C3C5C8FE2E878787878787000000000000043C3C3C3C3800043C3C3C3C38010F0F0F0F0E43C3C384399A07F80000000000000000000200
...    00000000000000000000000000000000000000000002000002000020002000020002000000200000002000000202000000000002001F32BCD0
...    200A42FF34A5DE2807C0021000CD24000080014432E280626A0081A08F040410400000410400400028C80800080004400000

${Wait_For_Throughtput_stable}    5s

@{Online_Param_14}
...    LNCEL:maxNumScells=4
...    LNBTS-1/NRDCDPR-0:allowedBcSelectMethod=max MIMO layers with max CCs
...    LNBTS-1/CADPR-0:maxNumMimoLayerFdd=14
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNBTS-1:actInterEnbDLCAggr=true
...    LNBTS-1:actEnDcNrFeatSetIdBcSel=true

@{Online_Param_15}
...    LNBTS-1/NRDCDPR-0:allowedBcSelectMethod=max MIMO layers
...    LNCEL-1:maxNumScells=2
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNBTS-1:actInterEnbDLCAggr=false
...    LNBTS-1:actEnDcNrFeatSetIdBcSel=false

###FLOW MSG###

${attachcheck}
...    measIdToAddModList contains (measId eq 17) and
...    transmissionMode-r10 eq 'tm4' and
...    codebookSubsetRestriction-r10 eq '0b1111111111111111111111111111111111111111111111111111111111111111' and
...    cqi-ReportModeAperiodic-r10 eq 'rm31' and
...    maxLayersMIMO-r10 eq 'fourLayers'

${dynamic_endc}
...    measConfig contains (
...        measIdToRemoveList contains (17) and
...        measGapConfig contains (release is present)
...    ) and
...    reestablishRLC-r15 eq 'true' and
...    endc-ReleaseAndAdd-r15 eq 'FALSE'

${addscell_case14}
...    sCellToAddModList-r10 contains (
...        (transmissionMode-r10 eq 'tm4' and
...        codebookSubsetRestriction-r10 eq '0b1111111111111111111111111111111111111111111111111111111111111111' and
...        cqi-ReportModeAperiodic-r10 eq 'rm31')
...        ,
...        (transmissionMode-r10 eq 'tm4' and
...        codebookSubsetRestriction-r10 eq '0b0000000000000000000000000000000011111111111111111111111111111111' and
...        cqi-ReportModeAperiodic-r10 eq 'rm31')
...        ,
...        (transmissionMode-r10 eq 'tm3' and
...        codebookSubsetRestriction-r10 eq '0b11' and
...        cqi-ReportModeAperiodic-r10 eq 'rm30')
...        ,
...        (transmissionMode-r10 eq 'tm4' and
...        codebookSubsetRestriction-r10 eq '0b0000000000000000000000000000000011111111111111111111111111111111' and
...        cqi-ReportModeAperiodic-r10 eq 'rm31')
...    )

${addscell_case15}
...    cqi-ReportConfig-r10 contains (cqi-ReportModeAperiodic-r10 eq 'rm31') and
...    sCellToAddModList-r10 contains (
...        (sCellIndex-r10 eq 2 and
...        transmissionMode-r10 eq 'tm4' and
...        codebookSubsetRestriction-r10 eq '0b1111111111111111111111111111111111111111111111111111111111111111' and
...        cqi-ReportModeAperiodic-r10 eq 'rm31' and
...        maxLayersMIMO-r10 eq 'fourLayers')
...        ,
...        (sCellIndex-r10 eq 1 and
...        transmissionMode-r10 eq 'tm4' and
...        codebookSubsetRestriction-r10 eq '0b111111' and
...        cqi-ReportModeAperiodic-r10 eq 'rm31')
...    )

${first_ifho_ho2cell3}
...    mobilityControlInfo contains (
...        targetPhysCellId eq 3
...        and
...        carrierFreq contains (
...            dl-CarrierFreq eq 2850)
...    ) and
...    radioResourceConfigDedicated contains (
...        transmissionMode-r10 eq 'tm4' and
...        cqi-ReportModeAperiodic-r10 eq 'rm31'
...    ) and
...    nonCriticalExtension contains (
...        antennaInfoDedicatedPCell-v10i0 is not present and
...        sCellToReleaseList-r10 contains (2, 1)
...    )

${first_ifho_addscell}
...    physicalConfigDedicated contains (
...        cqi-ReportModeAperiodic-r10 eq 'rm31'
...    ) and
...    sCellToAddModList-r10 contains (
...        (transmissionMode-r10 eq 'tm4' and
...        codebookSubsetRestriction-r10 eq '0b1111111111111111111111111111111111111111111111111111111111111111' and
...        cqi-ReportModeAperiodic-r10 eq 'rm31' and
...        maxLayersMIMO-r10 eq 'fourLayers')
...        ,
...        (transmissionMode-r10 eq 'tm4' and
...        codebookSubsetRestriction-r10 eq '0b0000000000000000000000000000000011111111111111111111111111111111' and
...        cqi-ReportModeAperiodic-r10 eq 'rm31')
...        ,
...        (sCellIndex-r10 eq 3 and
...        transmissionMode-r10 eq 'tm4' and
...        codebookSubsetRestriction-r10 eq '0b1111111111111111111111111111111111111111111111111111111111111111' and
...        cqi-ReportModeAperiodic-r10 eq 'rm31' and
...        maxLayersMIMO-r10 eq 'fourLayers')
...    )

${first_ifho_ho2cell4}
...    mobilityControlInfo contains (
...            targetPhysCellId eq 4
...            and
...            carrierFreq contains (
...                dl-CarrierFreq eq 3048)
...    )and
...    radioResourceConfigDedicated contains (
...        transmissionMode-r10 eq 'tm4' and
...        codebookSubsetRestriction-r10 eq '0b1111111111111111111111111111111111111111111111111111111111111111' and
...        cqi-ReportModeAperiodic-r10 eq 'rm31'
...    )and
...    nonCriticalExtension contains (
...        maxLayersMIMO-r10 eq 'fourLayers' and
...        sCellToReleaseList-r10 contains (3,1,2) and
...        nonCriticalExtension contains (
...            endc-ReleaseAndAdd-r15 eq 'FALSE')
...    )

${SgNBAddition_14}
...    allowedBC-ListMRDC contains (
...      bandCombinationIndex eq 4 and
...      allowedFeatureSetsList contains (1,2),
...      bandCombinationIndex eq 9 and
...      allowedFeatureSetsList contains (1,2)
...    )

${SgNBAddition_15}
...    allowedBC-ListMRDC contains (
...      bandCombinationIndex eq 2 and
...      allowedFeatureSetsList contains (2),
...      bandCombinationIndex eq 6 and
...      allowedFeatureSetsList contains (3),
...      bandCombinationIndex eq 7 and
...      allowedFeatureSetsList contains (1),
...      bandCombinationIndex eq 11 and
...      allowedFeatureSetsList contains (3)
...    )

${SgNBModification_1}
...    allowedBC-ListMRDC contains (
...      bandCombinationIndex eq 4 and
...      allowedFeatureSetsList contains (2),
...      bandCombinationIndex eq 9 and
...      allowedFeatureSetsList contains (2)
...    )

${SgNBModification_2}
...    allowedBC-ListMRDC contains (
...      bandCombinationIndex eq 3 and
...      allowedFeatureSetsList contains (1,2),
...      bandCombinationIndex eq 4 and
...      allowedFeatureSetsList contains (2),
...      bandCombinationIndex eq 9 and
...      allowedFeatureSetsList contains (2),
...      bandCombinationIndex eq 10 and
...      allowedFeatureSetsList contains (1,3),
...      bandCombinationIndex eq 11 and
...      allowedFeatureSetsList contains (3,4)
...    )

*** Test Cases ***
LTE5761-A-b-c-d_ET_14_01_Inter-site CA when actEnDcLteDlMimoOptBcSel set to true and actEnDcNrFeatSetIdBcSel set to true
    [Tags]
    Delta Commission Parameters And Wait Cells Onair    ${Online_Param_14}
    Attach a UE to Pcell cell1 with default QCI-8
    Trigger Dynamic ENDC    X:Y=9:1    sgnbaddition=${sgnbaddition_14}
    Start traffic
    Release All UEs

LTE5761-A-b-c_ET_15_01_Intra eNodeB HO with ENDC when actEnDcLteDlMimoOptBcSel set to true
    [Tags]
    Delta Commission Parameters And Wait Cells Onair    ${Online_Param_15}
    Attach a UE to Pcell cell1 with default QCI-8    ue_id=2    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities_Case15}
    Trigger Dynamic ENDC    ue_id=2    X:Y=7:1    sgnbaddition=${sgnbaddition_15}
    Start traffic    ue_id=2    addscell=${addscell_case15}
    Trigger 1st IFHO    X:Y=4:2
    Trigger 2nd IFHO    X:Y=3:1
    Release All UEs

*** Keywords ***
Common Suite Setup And Setup 2CUS Env
    Common Suite Setup
    Setup 2CUS Env    tl_type=4CELLs_FDD_Band1Band3_2Band7    tl_type_enb2=4CELLs_FDD_2Band3_2Band7
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    ENB_2    enb_id=2    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Set Ue Parameters Before Attach


Set Ue Parameters Before Attach
    Execute Uex Command    ue_param id=1,2 dual_conn=eutra_nr pdcp_sn_extension=18bit nr_supported_bands=78
    Execute Uex Command    ue_cqi_param id=1,2 scell=0-4 rank=4 cell=target
    Execute Uex Command    ue_cqi_param id=1,2 scell=0-4 rank=4 cell=current
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true scg_dl_dist_percent=0 include_reestablish_pdcp=on
    Execute Egate Command    enb_x2_link_up enb=7 target=1    X2 link with eNB-1 is activated already
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    Execute Egate Command    enb_timer T_DC_Overall=5000ms

Modify Yaml
    ${GNB7_CELL1}    catenate    - {id: 71, technology: nr , tac: 33, pci: '0:1', eci: '0x0000404', earfcn: '39750:39750', nrci: '0x0000501',
    ...    nr_arfcn: '636666:636666', tdd_cell: yes, gscn: 7881}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...      gnb_id: '0x00007'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.11
    ...      x2_peers: none
    ...      cells:
    ...        ${GNB7_CELL1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 6, pdn: 1}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_2


Attach a UE to Pcell cell1 with default QCI-8
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${ue_eutra_nr_capabilities}=${ue_eutra_nr_capabilities_Case14}
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${attachcheck})
    ...    alias=ue_attach_flow    overall_timeout=30
    ${cmd}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_nr_capabilities=${ue_nr_capabilities}    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    enb=1 cell=${cell_id}
    Execute Uex Command    ${cmd}
    Flow Occurred As Expected    alias=ue_attach_flow


Trigger Dynamic ENDC
    [Arguments]    ${ue_id}=1    ${X:Y}=disable    ${sgnbaddition}=${sgnbaddition_14}
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${dynamic_endc})
    ...    ENB_1:X2AP_SgNBAdditionRequest(${sgnbaddition})
    ...    alias=Dynamic_ENDC_flow    overall_timeout=30
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=${X:Y}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B1_NR phycell_id=1 nrsrp=60
    Sleep    ${Wait_For_Throughtput_stable}
    Flow Occurred As Expected    alias=Dynamic_ENDC_flow

Start traffic
    [Arguments]    ${ue_id}=1    ${addscell}=${addscell_case14}
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${addscell})
    ...    alias=addscell    overall_timeout=30
    Execute Uex Command    trf_data_start dir=dl Mbps=150 ue=${ue_id} protocol=udp trf_id=1
    Execute Uex Command    trf_data_start dir=dl Mbps=150 ue=${ue_id} protocol=udp trf_id=2
    Sleep    ${Wait_For_Throughtput_stable}
    Flow Occurred As Expected    alias=addscell

Trigger 1st IFHO
    [Arguments]    ${ue_id}=2    ${X:Y}=disable
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${first_ifho_ho2cell3})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${first_ifho_addscell})
    ...    ENB_1:X2AP_SgNBModificationRequest (${SgNBModification_1})
    ...    alias=first_ifho    overall_timeout=30
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=50 srsrq=34 meas_id_blacklist=4
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=off
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=${X:Y}
    ${A3_MR_1}    catenate    ue_measurement_send id=${ue_id} event=A3 srsrp=60 srsrq=34
    ...    phycell_id=3 nrsrp=90 nrsrq=34 meas_id_blacklist=1,7
    Execute Uex Command    ${A3_MR_1}
    Flow Occurred As Expected    alias=first_ifho

Trigger 2nd IFHO
    [Arguments]    ${ue_id}=2    ${X:Y}=disable
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${first_ifho_ho2cell4})
    ...    ENB_1:X2AP_SgNBModificationRequest (${SgNBModification_2})
    ...    alias=second_ifho    overall_timeout=30
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=50 srsrq=34 meas_id_blacklist=4
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=off
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=${X:Y}
    ${A3_MR_2}    catenate    ue_measurement_send id=${ue_id} event=A3 srsrp=60 srsrq=34
    ...    phycell_id=4 nrsrp=90 nrsrq=34 meas_id_blacklist=1,7
    Execute Uex Command    ${A3_MR_2}
    Flow Occurred As Expected    alias=second_ifho