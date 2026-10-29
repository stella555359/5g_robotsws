*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4A_CUS    team-DevHZ5_SG1
...               owner-taotao.hu    release-SBTS22R4
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_VENDOR}
...    LNBTS:reportTimerEndcA5=5000ms
@{PARAMS_IN_SCF}
...    @{x2link}
...    @{LTE4088}
...    @{LTE4193}
...    @{NRDCDPR_CONFIG}
...    @{PARAMS_FOR_CELL_CONFIG}
...    @{add_moPrMapList}
...    @{HO_para}
...    @{CB007163}
${f1}    38000
${f2}    900
${f3}    1700

@{CB007163}
...    LNBTS:actEndcHo=enabled
...    LNBTS:actUeCapEndcHo=false
...    LNCEL:actEndcHoPrefLay=false
...    LNCEL-1:iFEndcHoRetryTimer=10
...    LNCEL-2:iFEndcHoRetryTimer=10
...    LNCEL-3:iFEndcHoRetryTimer=10
...    LNBTS-1:blockEndcHoRetryAtHoFromTrg=no blocking
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/MOPR-2:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/MOPR-3:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=1700
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=257
...    LNBTS/CAGENB-0/CAIMLBP-1:pcellConfig:earfcnDL=38000
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0:nrcellConfigL:band=7
...    LNBTS/CAGENB-0/CAIMLBP-2:pcellConfig:earfcnDL=900
...    LNBTS/CAGENB-0/CAIMLBP-2/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-2/IMLBNR-0:nrcellConfigL:band=40
...    LNCEL-1/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=38000
...    LNCEL-1/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNCEL-1/LNHOIF-2:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=1700
...    LNCEL-1/LNHOIF-2:thresholdRsrqEndcFilt=-120
...    LNCEL-1/LNHOIF-3:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-3:eutraCarrierInfo=900
...    LNCEL-1/LNHOIF-3:thresholdRsrqEndcFilt=-120
...    @{freqLayEndcHoList_for_MOPR}
...    @{freqLayEndcHoList_for_MODPR}

@{freqLayEndcHoList_for_MODPR}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f1}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f2}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f3}

@{freqLayEndcHoList_for_MOPR}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${f1}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${f2}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${f3}

@{HO_para}
...    LNBTS-1:actIfHo=enabled
...    LNBTS-1/LNADJ-1:adjEnbId=2
...    LNBTS-1/LNADJ-1:cPlaneIpAddr=10.0.1.3
...    LNCEL-1/LNREL-1:removeAllowed=false
...    LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=2
...    LNCEL-1/LNREL-1:ecgiLcrId=21
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1500
...    LNBTS/MODPR-0:freqLayListLte=1500,1400,1700,1600,38000,900
...    LNBTS/MOPR-1:freqLayListLte=1500,1400,1700,1600,38000,900

@{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1500
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19500
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19600

@{x2link}
...    LNBTS/LNADJGNB-1:adjGnbId=7
...    LNBTS/LNADJGNB-1:adjGnbIdLength=22
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNCEL/LNRELGNBCELL-0:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-0:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-0:nrCellId=115969
...    LNCEL/LNRELGNBCELL-0:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-0:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-0:nrCgiPlmnId:mncLength=2
...    LNCEL/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-1:nrCellId=115970
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNBTS/LNADJGNB-2:adjGnbId=8
...    LNBTS/LNADJGNB-2:adjGnbIdLength=22
...    LNBTS/LNADJGNB-2:administrativeState=unlocked
...    LNBTS/LNADJGNB-2:cPlaneIpAddr=10.0.1.12
...    LNCEL/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-2:nrCellId=132355
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
...    LNCEL/LNRELGNBCELL-3:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-3:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-3:nrCellId=148740
...    LNCEL/LNRELGNBCELL-3:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-3:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-3:nrCgiPlmnId:mncLength=2

@{LTE4088}
...    LNBTS:actTransmittedBelowGap=false
...    LNBTS:actLteNrDualConnectivity=false
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:nrRestrictionOverride=disabled
...    LNCEL:defaultLnRelGnbCellId=1
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNBTS:tLteNrDualConnectPrep=5000
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNBTS:qciTab7:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNBTS-1:tLteNrDualConnectPrep=10000    #(10s)
...    LNBTS-1:rrcGuardTimer=100

${nrF1}    531040
${nrF2}    524032

@{LTE4193}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS:actDynTrigLteNrDualConnectivity=false
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true

@{NRDCDPR_CONFIG}
...    LNBTS/NRMEASDPR-0:measGapEnabledNRMeas=Disable
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=1
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=1
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:tPeriodicPhr=1000sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=1000sf
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=${nrF1}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:nrCarPrio=3
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:carrierFreqNrCell=${nrF2}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:nrCarPrio=6
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:quantityConfigId=1

@{add_moPrMapList}
...    LNBTS-1:actSelMobPrf=true
...    LNBTS-1/MODPR-0:autoAdapt=false
...    LNBTS-1:moProfileSelect=spid
...    LNCEL-1:moPrMappingList:spid=2|moPrId=1
...    LNCEL-1:moPrMappingList:spidLast=100|moPrId=1
...    LNCEL-1:moPrMappingList:mcc=262|moPrId=1
...    LNCEL-1:moPrMappingList:mnc=3|moPrId=1
...    LNCEL-1:moPrMappingList:mncLength=2|moPrId=1

@{LTE4530}
...    LNBTS-1:actSnChangeSnInit=true
${ue_nr_capabilities}    0000000001010040000060000038000400040160401C06000000
${ue_eutra_nr_capabilities}    SEPARATOR=
...    010810036040080819280701800000006C08010102020E0380000000D8100306006140
...    1D0000000001B01004020804384E00000000180004020001008000402020040080
${ue_eutra_capabilities}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D4AB5F9D3A00000001D00000000E80000000
...    7400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A0000
...    0001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8
...    00000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFBFFED800801C364
...    000000017BA000000080952A0E2740400003840000210002C20000108008400010C0002200004500008C00011
...    C0002400004900009400012C0002600004D0000A0000144000290000530000A80001540002B0000570000B000
...    01640002D00005B0000BA0001780003680007F001D3A00000001D00000000E800000007400000003A00000001
...    D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E80000
...    0007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A0
...    0000001D00000000E800000007400000003A00000001D00000000A080000079D0000000000000000000000000
...    00000000000000000000000000000000001011C42129A061CFFFFFFFFFFFFFFFA020A80018022970000200001
...    04B1A0180C03A0013BC00000180000009000021800C020180740000

${ue_eutra_capabilities_with_gaps}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D4AB5F9D3A0000000
...    1D00000000EA00000087400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003
...    A00000001D00000000E800000007400000003A00000001D00000000E80000000740000
...    0003A00000001D00000000E800000007400000003A00000001D00000001BFBFFED8008
...    01C364000000017BA000000080952A0E2740400003840000210002C200001080084000
...    10C0002200004500008C00011C0002400004900009400012C0002600004D0000A00001
...    44000290000530000A80001540002B0000570000B00001640002D00005B0000BA00017
...    80003680007F001D3A00000001D00000000E800000007400000003A00000001D000000
...    00E800000007400000003A00000001D00000000E800000007400000003A00000001D00
...    000000E800000007400000003A00000001D00000000E800000007400000003A0000000
...    1D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000A080000079D000000000000000000000000000000000000000000000
...    000000000000001011C42129A061CFFFFFFFFFFFFFFFA020A800180229700002000010
...    4B1A0180C03A0013BC00000180000009000021800C020180740000
${ue_eutra_capabilities_endc_A5_no_gap_coverage_A5_need_gap}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D4AB5F9D3A0000000
...    1D00000000E800000087400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003
...    A00000001D00000000E800000007400000003A00000001D00000000E80000000740000
...    0003A00000001D00000000E800000007400000003A00000001D00000001BFBFFED8008
...    01C364000000017BA000000080952A0E2740400003840000210002C200001080084000
...    10C0002200004500008C00011C0002400004900009400012C0002600004D0000A00001
...    44000290000530000A80001540002B0000570000B00001640002D00005B0000BA00017
...    80003680007F001D3A00000001D00000000E800000007400000003A00000001D000000
...    00E800000007400000003A00000001D00000000E800000007400000003A00000001D00
...    000000E800000007400000003A00000001D00000000E800000007400000003A0000000
...    1D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000A080000079D000000000000000000000000000000000000000000000
...    000000000000001011C42129A061CFFFFFFFFFFFFFFFA020A800180229700002000010
...    4B1A0180C03A0013BC00000180000009000021800C020180740000
${ue_eutra_capabilities_endc_A5_need_gap_coverage_A5_no_gap}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D4AB5F9D3A0000000
...    1D00000000EA00000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003
...    A00000001D00000000E800000007400000003A00000001D00000000E80000000740000
...    0003A00000001D00000000E800000007400000003A00000001D00000001BFBFFED8008
...    01C364000000017BA000000080952A0E2740400003840000210002C200001080084000
...    10C0002200004500008C00011C0002400004900009400012C0002600004D0000A00001
...    44000290000530000A80001540002B0000570000B00001640002D00005B0000BA00017
...    80003680007F001D3A00000001D00000000E800000007400000003A00000001D000000
...    00E800000007400000003A00000001D00000000E800000007400000003A00000001D00
...    000000E800000007400000003A00000001D00000000E800000007400000003A0000000
...    1D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000A080000079D000000000000000000000000000000000000000000000
...    000000000000001011C42129A061CFFFFFFFFFFFFFFFA020A800180229700002000010
...    4B1A0180C03A0013BC00000180000009000021800C020180740000

@{precondition_for_case1}
...    LNBTS:actLteNrDualConnectivity=true    #LTE4088 enabled
...    LNBTS:actDynTrigLteNrDualConnectivity=true    #LTE4193 enabled
...    LNBTS:actEndcHo=enabled    #(LTE5150)
...    LNBTS:actUeCapEndcHo=true    #(CB006607)
...    LNCEL:actEndcHoPrefLay=true    #(CB007163)
...    LNBTS:actMeasGapCoordEnDc=eNB initiated    #LTE4981 enabled
...    LNBTS:actMeasGapIfEnDc=true

@{precondition_for_case4}
...    LNBTS:actLteNrDualConnectivity=true    #LTE4088 enabled
...    LNBTS:actDynTrigLteNrDualConnectivity=true    #LTE4193 enabled
...    LNBTS:actEndcHo=enabled    #(LTE5150)
...    LNBTS:actUeCapEndcHo=true    #(CB006607)
...    LNCEL:actEndcHoPrefLay=true    #(CB007163)
...    LNBTS:actMeasGapCoordEnDc=eNB initiated    #LTE4981 enabled
...    LNBTS:actMeasGapIfEnDc=false
...    @{LTE4530}

@{precondition_for_case9}
...    LNBTS:actLteNrDualConnectivity=true    #LTE4088 enabled
...    LNBTS:actDynTrigLteNrDualConnectivity=true    #LTE4193 enabled
...    LNBTS:actEndcHo=enabled    #(LTE5150)
...    LNBTS:actUeCapEndcHo=true    #(CB006607)
...    LNCEL:actEndcHoPrefLay=true    #(CB007163)
...    LNBTS:actMeasGapCoordEnDc=eNB initiated    #LTE4981 enabled
...    LNBTS:actMeasGapIfEnDc=true
...    LNBTS/MODPR-0:freqLayListLte=38010
...    LNBTS/MOPR-1:freqLayListLte=38010
...    LNCEL-1/LNHOIF-4:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-4:eutraCarrierInfo=38010
...    LNCEL-1/LNHOIF-4:thresholdRsrqEndcFilt=-120
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${f1}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${f1}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f2}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f3}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${f2}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${f3}

@{recover_for_case9}
...    @{freqLayEndcHoList_for_MOPR}
...    @{freqLayEndcHoList_for_MODPR}
${ENDC_a5_deactive}    measIdToRemoveList contains (3,5,6)
${ENDC_a5_retry}    measIdToAddModList contains (measId eq 3,measId eq 5,measId eq 6)
${B1NR_remove}    measIdToRemoveList contains (17,18)
${B1NR_activate}    measIdToAddModList contains (measId eq 17,measId eq 18)
${gap_activate}
...    radioNetwork eq 'action-desirable-for-radio-reasons' and
...    MeNBtoSgNBContainer contains (
...    "'00 "
...    ) and
...    MeNBtoSgNBContainer contains (
...    '20 '
...    )
...    and
...    MeNBtoSgNBContainer contains (
...    '38 '
...    )
...    and
...    MeNBtoSgNBContainer contains (
...    '7A '
...    )
...    and
...    MeNBtoSgNBContainer contains (
...    "A0'H"
...    )
${gap_release}
...    radioNetwork eq 'action-desirable-for-radio-reasons' and
...    MeNBtoSgNBContainer contains (
...    "'00 "
...    ) and
...    MeNBtoSgNBContainer contains (
...    '20 '
...    )
...    and
...    MeNBtoSgNBContainer contains (
...    "20'H"
...    )
*** Test Cases ***
CB007163_A-B4-B5_ET_01_01_ENDC A5 activation during ENDC setup or release and gap sharing in ENDC status when UE no need gap
    [Documentation]
    ...    precondition: f1=38000 (band38, Tdd),f2=900 (band2,FDD), f3=1700 (band3,FDD)
    ...    MRDC capability:
    ...    LNBTS:actEndcHo=enabled (LTE5150)
    ...    LNBTS:actUeCapEndcHo=true (CB006607)
    ...    LNCEL:actEndcHoPrefLay=true (CB007163)
    ...    LNBTS:actDynTrigLteNrDualConnectivity=true (LTE4193 enabled)
    ...    LNBTS:actMeasGapCoordEnDc=eNB initiated    #LTE4981 enabled
    ...    LNBTS:actMeasGapIfEnDc=true and UE no need gap for ENDC A5 by eutra capability
    ...    step1: UE1 ICS to serving cell and check endc A5 activation and deactivation after supervision timer expired
    ...    step2: trigger ENDC setup with B1 and make next ENDC A5 activation during ENDC setup by delay ENDC setup procedure,
    ...           check ENDC procedure will buffer ENDC A5 activation and countinued after ENDC procedure finished;
    ...           check ENDC A5 activation with gap config after ENDC setup when gap sharing enabled;
    ...           check gap sharing with SGNB by SGNB modification;
    ...           check ENDC A5 deactivation and release gap for UE when supervision timer expired;
    ...           check gap release for SGNB by SGNB modification after ENDC A5 deactivation;
    ...    step3: trigger ENDC release with delay and make ENDC A5 activation during ENDC release procedure:
    ...           check ENDC procedure will buffer ENDC A5 activation and countinued after ENDC procedure finished;
    ...           check ENDC A5 activation without gap config after ENDC release;
    ...           check ENDC A5 deactivation and no release gap for UE when supervision timer expired;
    [Tags]    QC_01
    OnlineParamChange    ${precondition_for_case1}
    make ENDC A5 activation during ENDC setup and bufferred until ENDC setup complete
    make ENDC A5 activation during SGNB release required and bufferred until SGNB release complete
    [Teardown]    Local Test Teardown And Recover Env

CB007163_A-B4-B5_ET_04_01_ENDC A5 activation and deactivation triggered during SgNB change and gap keep for UE after ENDC takeback
    [Documentation]
    ...    precondition: f1=38000 (band38, Tdd),f2=900 (band2,FDD), f3=1700 (band3,FDD)
    ...    MRDC capability:
    ...    LNBTS:actEndcHo=enabled (LTE5150)
    ...    LNBTS:actUeCapEndcHo=true (CB006607)
    ...    LNCEL:actEndcHoPrefLay=true (CB007163)
    ...    LNBTS:actDynTrigLteNrDualConnectivity=true (LTE4193 enabled)
    ...    LNBTS:actMeasGapCoordEnDc=eNB initiated    #LTE4981 enabled
    ...    LNBTS:actMeasGapIfEnDc=false and UE need gap for ENDC A5 by eutra capability
    ...    step1: UE1 ICS to serving cell and check endc A5 activation and gap config
    ...    step2: trigger ENDC setup with B1 just after endc A5 activation,
    ...           check gap sharing to SGNB by SGNB addition;
    ...           check gap config release for UE and SGNB when ENDC A5 deactivation;
    ...    step3: trigger SGNB change with delay and make ENDC A5 activation during this procedure:
    ...           check ENDC procedure will buffer ENDC A5 activation and countinued after ENDC procedure finished;
    ...    step4: trigger SGNB change with delay and make ENDC A5 deactivation during this procedure:
    ...           check ENDC procedure will buffer ENDC A5 deactivation and countinued after ENDC procedure finished;
    ...    step5: trigger ENDC takeback just after ENDC A5 activation:
    ...           check ENDC takeback successfully and gap keep for UE;
    [Tags]    QC_194852fff
    OnlineParamChange    ${precondition_for_case4}
    Make ENDC A5 activation during SGNB change and bufferred until sgnb change complete
    Make ENDC A5 deactivation during SGNB change and bufferred until sgnb change complete
    SgNB Release Required With User Inactivity
    Wait To ENDC A5 measurement deactivation
    Check WireShark Log    ${CURDIR}${/}A2A_04${/}a2a.ini    wait_string=SgNBReleaseRequest::1
    Check Logs With Au2anlysis    ${CURDIR}${/}A2A_04${/}a2a.ini    p
    [Teardown]    Local Test Teardown And Recover Env

CB007163_A-B4-B5_ET_05_01_ENDC A5 deactivation triggered during EN-DC setup and release and gap sharing during ENDC setup
    [Documentation]
    ...    precondition: f1=38000 (band38, Tdd),f2=900 (band2,FDD), f3=1700 (band3,FDD)
    ...    MRDC capability:
    ...    LNBTS:actEndcHo=enabled (LTE5150)
    ...    LNBTS:actUeCapEndcHo=true (CB006607)
    ...    LNCEL:actEndcHoPrefLay=true (CB007163)
    ...    LNBTS:actDynTrigLteNrDualConnectivity=true (LTE4193 enabled)
    ...    LNBTS:actMeasGapCoordEnDc=eNB initiated    #LTE4981 enabled
    ...    LNBTS:actMeasGapIfEnDc=false and UE need gap for ENDC A5 by eutra capability
    ...    step1: UE1 ICS to serving cell and check endc A5 activation and gap config
    ...    step2: trigger ENDC setup with delay and make ENDC A5 deactivation during this procedure:
    ...           check ENDC procedure will buffer ENDC A5 deactivation and countinued after ENDC procedure finished;
    ...           check gap sharing during SGNB addition
    ...    step3: trigger ENDC takeback with delay and make ENDC A5 deactivation during this procedure:
    ...           check ENDC procedure will buffer ENDC A5 deactivation and countinued after ENDC procedure finished;
    [Tags]    QC_194851fff
    OnlineParamChange    ${precondition_for_case4}
    Make ENDC A5 deactivation during ENDC setup and bufferred until ENDC setup complete
    Make ENDC A5 deactivation during SGNB release required and bufferred until SGNB release complete
    Check WireShark Log    ${CURDIR}${/}A2A_05${/}a2a.ini    wait_string=SgNBReleaseRequestAcknowledge::1
    Check Logs With Au2anlysis    ${CURDIR}${/}A2A_05${/}a2a.ini    p
    [Teardown]    Local Test Teardown And Recover Env

CB007163_A-B4-B5_ET_09_01_gap release or keep depending on coverage measurement need gap or not when ENDC A5 deactivation by coverage based measure
    [Documentation]
    ...    precondition: f1=38000 (band38, Tdd),f2=900 (band2,FDD), f3=1700 (band3,FDD)
    ...    MRDC capability:
    ...    LNBTS:actEndcHo=enabled (LTE5150)
    ...    LNBTS:actUeCapEndcHo=true (CB006607)
    ...    LNCEL:actEndcHoPrefLay=true (CB007163)
    ...    LNBTS:actDynTrigLteNrDualConnectivity=true (LTE4193 enabled)
    ...    LNBTS:actMeasGapCoordEnDc=eNB initiated    #LTE4981 enabled
    ...    LNBTS:actMeasGapIfEnDc=false
    ...    UE1: no need gap for ENDC A5 but need gap for coverage A3/A5
    ...    UE2: need gap for ENDC A5 but no need gap for coverage A3/A5
    ...    step1: UE1 ICS to serving cell and check endc A5 activation and deactivation after supervision timer expired
    ...    step2: trigger ENDC setup with and wait endc A5 activaton after ENDC setup, then send A2 MR:
    ...           check ENDC A5 deactivated by coverage based A3/A5 mearsurement, and gap not released for UE;
    ...    step3: UE2 ICS to serving cell and check endc A5 activation and deactivation after supervision timer expired
    ...    step4: trigger ENDC setup with and wait endc A5 activaton after ENDC setup, then send A2 MR:
    ...           check ENDC A5 deactivated by coverage based A3/A5 mearsurement, and gap released for UE;
    [Tags]    QC_194847fff
    OnlineParamChange    ${precondition_for_case9}
    Attach UE and setup ENDC for UE1
    Send A2 MR for UE and keep gap    ue_id=1
    OnlineParamChange    LNBTS:actMeasGapIfEnDc=false
    Attach UE and setup ENDC for UE2
    Send A2 MR for UE and release gap    ue_id=2
    [Teardown]    Local Test Teardown And Recover Env for case9

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    execute egate command    trace_sim on mme=1 protocol=s1
    Set ue parameters before attach
    execute egate command    ue_mme_param id=1-10 spid=20
    FOR    ${ue_id}    IN RANGE    1    21
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
#    Create Enb Alias    ENB_2    enb_id=2    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Modify Lua
    ${GNB7_CELL1}    catenate    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '507000:531000'}
    ${GNB7_CELL2}    catenate    - {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x0000502', nr_arfcn: '500000:524000'}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...      gnb_id: '0x00007'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.11
    ...      x2_peers: none
    ...      cells:
    ...        ${GNB7_CELL1}
    ...        ${GNB7_CELL2}
    ${GNB8_CELL1}    catenate    - {id: 81, technology: nr , tac: 33, pci: '1:0', nrci: '0x0000503', nr_arfcn: '179500:188500'}
    Add Yaml    BASE_STATIONS
    ...    - id: 8
    ...      gnb_id: '0x00008'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.12
    ...      x2_peers: none
    ...      cells:
    ...        ${GNB8_CELL1}

    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.3
    ...      x2: 10.0.1.3
    ...      cells:
    ...        - {id: 21, technology: lte, tac: 33, pci: '3:0', earfcn: '1700:19700', bw: 20, status: 'enabled'}
    ...        - {id: 22, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '3:1', earfcn: '38000:38000', bw: 20}
    ...        - {id: 23, technology: lte, tac: 33, pci: '3:2', earfcn: '1600:19600', bw: 20}
    ...        - {id: 24, technology: lte, tac: 33, pci: '4:0', earfcn: '1900:19900', bw: 20}
    ...        - {id: 25, technology: lte, tac: 33, pci: '4:1', earfcn: '8340:26340', bw: 20}
    FOR    ${ue_set_id}     IN RANGE    1    31
        ${ue_capablity_set}  catenate
        ...    UEs/UE_sets/${ue_set_id}    capability: ${ue_eutra_capabilities}
        ...    capability_nr: ${ue_nr_capabilities}    capability_mrdc: ${ue_eutra_nr_capabilities}
        Update Yaml    ${ue_capablity_set}
    END
    # modify UE4 bearer
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, preprovisioned: on, filter: 4, precedence: 4}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    FOR    ${ue_id}     IN RANGE    1    11
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_2
    END
        FOR    ${ue_id}     IN RANGE    11    21
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_3
    END

Set ue parameters before attach
    FOR    ${ue_id}    IN RANGE    1    30
        execute uex command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
        execute uex command    ue_param id=${ue_id} nr_supported_bands=7,8,40,257
    END
    execute egate command
    ...    gnb_endc_param id=7 include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true scg_dl_dist_percent=0
    execute egate command
    ...    gnb_endc_param id=8 include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true scg_dl_dist_percent=0

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Attach UE
    [Arguments]    ${ue_id}    ${enb_id}=1    ${cell_id}=1
    ...    ${ue_eutra_nr_capabilities}=${ue_eutra_nr_capabilities}    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} enb=${enb_id} cell=${cell_id} ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    execute uex command    ${V_1}

Delete ENDC bearer for UE
    [Arguments]    ${ue_id}=1
    execute uex command    bearer_del ue=${ue_id} qci=8

Add ENDC bearer for UE
    [Arguments]    ${ue_id}=1
    execute uex command    bearer_add ue=${ue_id} qci=8 filter=1 precedence=2

Check ENDC setup for UE with valid B1
    [Arguments]    ${ue_id}=1    ${meas_id_blacklist}=18    ${phycell_id}=2
    execute uex command
    ...    ue_measurement_send id=${ue_id} meas_id_blacklist=${meas_id_blacklist} event=B1_NR phycell_id=${phycell_id} nrsrp=120

SgNB Release Required With User Inactivity and delay
    [Arguments]    ${ue_id}=1
    Set RRC reconfig Mesg with delay    ue_id=${ue_id}
    SgNB Release Required With User Inactivity    ue_id=${ue_id}

SgNB Release Required With User Inactivity
    [Arguments]    ${ue_id}=1    #${pass_regexp}=Successfully reconfigured dual connectivity
    execute egate command    enb_ue_dc_release by=gnb cause=RN_user_inactivity ue=${ue_id}    #pass_regexp=${pass_regexp}

Set RRC reconfig Mesg with delay
    [Arguments]    ${ue_id}=1    ${nth}=1    ${delay_time}=8s
    execute uex command    ue_rrc_reconf_param id=${ue_id} if_contains=any nth=${nth} delay=${delay_time}
    execute egate command    enb_timer T_DC_Overall=9000

Set SgNB Addition Delay Timeout
    execute egate command    enb_timer T_SgnbAdditionReqAckDelay=8000
    execute egate command    enb_timer T_SN_STATUS_TRANSFER=12000
    execute egate command    enb_timer T_DC_Overall=15000

Trigger sgNB Change Successfully with delay
    [Arguments]    ${gnb_id}=8
    execute egate command    enb_timer T_SgnbAdditionReqAckDelay=8000
    execute egate command    enb_timer T_SNC_Overall=10000
    execute egate command    enb_timer T_SN_STATUS_TRANSFER=12000
    ${ret1}=    execute egate command
    ...    gnb_ue_dc_change ue=1 gnb=${gnb_id} target_sgnb_cells=1 cause=RN_sCG_Mobility

Local Test Teardown And Recover Env
    Configure recover ENDC procedure delay
    Common Test Teardown And Stop Capture Logs

Local Test Teardown And Recover Env for case9
    OnlineParamChange    ${recover_for_case9}
    Configure recover ENDC procedure delay
    Common Test Teardown And Stop Capture Logs

Wait To ENDC A5 measurement deactivation
    execute egate command    set_log flush    #pass_regexp=measIdToRemoveList    timeout=20s
    sleep    2s    #wait ENDC A5 will reactivation in 1s or 3s later due to supervision timer is 5s or 3s

Wait To ENDC A5 measurement activation
    execute egate command    set_log flush    #pass_regexp=measId 3    timeout=20s

Configure recover ENDC procedure delay
    execute egate command   enb_timer T_SgnbAdditionReqAckDelay=0
    execute egate command    enb_timer T_SgnbModificationFinishingDelay=0
    execute egate command    enb_timer T_SN_STATUS_TRANSFER=6000
    execute egate command    enb_timer T_SNC_Overall=6000
    execute uex command    ue_rrc_reconf_param id=1-10 if_contains=any nth=1 delay=0

Send A2 MR for UE and keep gap
    [Arguments]    ${ue_id}=1    ${meas_id_blacklist}=8
    execute uex command    ue_measurement_send meas_id_blacklist=${meas_id_blacklist} id=${ue_id} srsrp=63 srsrq=15

Send A2 MR for UE and release gap
    [Arguments]    ${ue_id}=1    ${meas_id_blacklist}=8
    execute uex command    ue_measurement_send meas_id_blacklist=${meas_id_blacklist} id=${ue_id} srsrp=63 srsrq=15
    #...    pass_regexp=measGapConfig release    timeout=10s

make ENDC A5 activation during ENDC setup and bufferred until ENDC setup complete
    Set SgNB Addition Delay Timeout
    Attach UE    ue_id=1    enb_id=1    cell_id=1
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${ENDC_a5_deactive})     #deactivation ENDC A5 before ENDC
    ...    alias=endcA5deactive    overall_timeout=30
    Wait To ENDC A5 measurement deactivation
    flow occurred as expected     alias=endcA5deactive
    expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    UE_1:RRC_RRCConnectionReconfiguration(${B1NR_remove})    #B1NR remove after NEDC setup
    ...    UE_1:RRC_RRCConnectionReconfiguration(${ENDC_a5_retry})    #ENDC A5 activate after ENDC setup
    ...    ENB_1:X2AP_SgNBModificationRequest(${gap_activate})    #gap activate
    ...    UE_1:RRC_RRCConnectionReconfiguration(${ENDC_a5_deactive})    #ENDC A5 Deactivate after ENDC setup
    ...    ENB_1:X2AP_SgNBModificationRequest(${gap_release})    #gap deactivate
    ...    alias=endca5gapcheck    overall_timeout=30
    Check ENDC setup for UE with valid B1    ue_id=1    meas_id_blacklist=18    phycell_id=2
    flow occurred as expected     alias=endca5gapcheck

Make ENDC A5 activation during SGNB release required and bufferred until SGNB release complete
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${ENDC_a5_deactive})     #deactivation ENDC A5 before ENDC
    ...    alias=endcA5deactive    overall_timeout=30
    Wait To ENDC A5 measurement deactivation
    flow occurred as expected     alias=endcA5deactive
    SgNB Release Required With User Inactivity and delay    ue_id=1
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${B1NR_activate})
    ...    UE_1:RRC_RRCConnectionReconfiguration(${ENDC_a5_retry})
    ...    UE_1:RRC_RRCConnectionReconfiguration(${ENDC_a5_deactive})
    ...    alias=endcA5active    overall_timeout=30
    Wait To ENDC A5 measurement deactivation
    flow occurred as expected     alias=endcA5active
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${ENDC_a5_retry})
    ...    alias=endcA5retry    overall_timeout=30
    Wait To ENDC A5 measurement activation
    flow occurred as expected     alias=endcA5retry

Make ENDC A5 deactivation during ENDC setup and bufferred until ENDC setup complete
    Attach UE    ue_id=25    enb_id=1    cell_id=1    ue_eutra_capabilities=${ue_eutra_capabilities_with_gaps}
    Add ENDC bearer for UE    ue_id=25
    Wait To ENDC A5 measurement activation
    Set SgNB Addition Delay Timeout
    Check ENDC setup for UE with valid B1    ue_id=25    meas_id_blacklist=18    phycell_id=2

Make ENDC A5 deactivation during SGNB release required and bufferred until SGNB release complete
    Wait To ENDC A5 measurement activation
    Set RRC reconfig Mesg with delay    ue_id=25
    Delete ENDC bearer for UE    ue_id=25
    Wait To ENDC A5 measurement activation
    Wait To ENDC A5 measurement deactivation

Make ENDC A5 activation during SGNB change and bufferred until sgnb change complete
    Attach UE    ue_id=1    enb_id=1    cell_id=1    ue_eutra_capabilities=${ue_eutra_capabilities_with_gaps}
    Wait To ENDC A5 measurement activation
    Check ENDC setup for UE with valid B1    ue_id=1    meas_id_blacklist=18    phycell_id=2
    Wait To ENDC A5 measurement deactivation
    Trigger sgNB Change Successfully with delay    gnb_id=8

Make ENDC A5 deactivation during SGNB change and bufferred until sgnb change complete
    Wait To ENDC A5 measurement activation
    Trigger sgNB Change Successfully with delay    gnb_id=7
    Wait To ENDC A5 measurement activation

Attach UE and setup ENDC for UE1
    Attach UE    ue_id=1    enb_id=1    cell_id=1
    ...    ue_eutra_capabilities=${ue_eutra_capabilities_endc_A5_no_gap_coverage_A5_need_gap}
    Wait To ENDC A5 measurement deactivation
    Check ENDC setup for UE with valid B1    ue_id=1    meas_id_blacklist=18    phycell_id=2
    Wait To ENDC A5 measurement activation

Attach UE and setup ENDC for UE2
    Attach UE    ue_id=2    enb_id=1    cell_id=1
    ...    ue_eutra_capabilities=${ue_eutra_capabilities_endc_A5_need_gap_coverage_A5_no_gap}
    Wait To ENDC A5 measurement deactivation
    Check ENDC setup for UE with valid B1    ue_id=2    meas_id_blacklist=18    phycell_id=2
    Wait To ENDC A5 measurement activation
