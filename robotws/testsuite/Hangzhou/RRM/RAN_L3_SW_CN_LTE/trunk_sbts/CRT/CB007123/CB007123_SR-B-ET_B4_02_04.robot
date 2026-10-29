*** Settings ***
Documentation
...    author: Geng lishuo
...    contact: lishuo.geng@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CLOUD_R4LAPO_CUS    CRT
...                 release-SBTS24R3    team-CN3ET    owner-taotao.hu
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{LTE4088}
...    @{LTE4193}
...    @{NRDCPR}
...    @{CA}
...    @{LTE4549}
...    @{NRDCDPR}
...    @{PARAMS_FOR_CELL_CONFIG}
...    @{X2_MOCs}

${flte1}    1400    #band3
${flte2}    1600    #band3
${flte3}    2870    #band7
${flte4}    3100    #band7

${fnr1}    188512    #nr band 8
${fnr2}    650048    #nr band 77
${fnr3}    2079200    #nr band 257

${B1NR_MEAS_ACT_DL_BUFFER}    LNCEL-1:M8080C171
${B1NR_MEAS_ACT_UL_BUFFER}    LNCEL-1:M8080C172

@{B1NR_MEAS_ACT_BUFFER_DL_2_UL_1}
...      ${B1NR_MEAS_ACT_DL_BUFFER}=2
...      ${B1NR_MEAS_ACT_UL_BUFFER}=1

@{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=${flte1}    #band3
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=${flte2}    #band3
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19600
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=${flte3}    #band7
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=20870
...    LNCEL-4/LNCEL_FDD-0:earfcnDL=${flte4}    #band7
...    LNCEL-4/LNCEL_FDD-0:earfcnUL=21100
...    LNCEL-3:actMicroDtx=false
...    LNCEL-4:actMicroDtx=false

@{X2_MOCs}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.41    #gNB_id=7
...    LNCEL/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-1:nrCellId=115969    # SSBfrequency=188512 for GNB-7 cell-1
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2

...    LNCEL/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-2:nrCellId=115970    # SSBfrequency=650048 for GNB-7 cell-2
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2

...    LNCEL/LNRELGNBCELL-3:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-3:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-3:nrCellId=115971    # SSBfrequency=2079200 for GNB-7 cell-3
...    LNCEL/LNRELGNBCELL-3:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-3:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-3:nrCgiPlmnId:mncLength=2

@{NRDCPR}
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:quantityConfigId=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:quantityConfigId=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1ThresholdNrRsrp=90
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:carrierFreqNrCell=${fnr1}
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:nrCarPrio=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrp=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrq=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbOffset=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbSubcarrierSpacing=15kHz

...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1ThresholdNrRsrp=90
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:carrierFreqNrCell=${fnr2}
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=77
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:nrCarPrio=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:hysB1ThresholdRsrp=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:hysB1ThresholdRsrq=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbOffset=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbSubcarrierSpacing=30kHz

...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1ThresholdNrRsrp=90
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:carrierFreqNrCell=${fnr3}
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:freqBandIndicatorNrL:freqBandIndicatorNr=257
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:nrCarPrio=3
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:hysB1ThresholdRsrp=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:hysB1ThresholdRsrq=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:ssbOffset=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:ssbSubcarrierSpacing=30kHz

@{NRDCDPR}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:quantityConfigId=1
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:tPeriodicPhr=1000sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=1000sf
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${fnr1}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=8
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:nrCarPrio=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=30kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=${fnr2}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=77
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:nrCarPrio=2
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrq=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=30kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:carrierFreqNrCell=${fnr3}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:freqBandIndicatorNrL:freqBandIndicatorNr=257
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:nrCarPrio=3
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:hysB1ThresholdRsrq=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbSubcarrierSpacing=30kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=1
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=1

@{CA}
...    LNBTS:actDLCAggr=true
...    LNCEL/LNCEL_FDD-0:actMixedMimoTMs=false
...    LNCEL:actFlowCtrlEnh=true
...    LNBTS:actAmbrModCaTrigger=false
...    LNBTS:actAdvScellMeas=true
...    LNBTS:enableBwCombCheck=true
...    LNBTS:actFlexScellSelect=true
...    LNCEL:actScellConfigForHiDemand=true
...    LNBTS/LNBTS_FDD-0:numTxWithHighNonGbr=10
...    LNBTS:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNCEL:maxNumScells=3
...    LNCEL-2:maxNumScells=3
...    LNCEL-3:maxNumScells=3
...    LNCEL:actCaArchEnhImp=off
...    LNCEL-2:actCaArchEnhImp=off
...    LNCEL-3:actCaArchEnhImp=off
...    LNCEL:caPoolId=1
...    LNCEL:dlScellConfigLevel=10
...    LNCEL/CAPR-1:earfcnDL=1600
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-2/CAREL-1:lnBtsId=1
...    LNCEL-2/CAREL-1:lcrId=1
...    LNCEL-2/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-3/CAREL-1:lnBtsId=1
...    LNCEL-3/CAREL-1:lcrId=1
...    LNCEL-3/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL:ulCaMinPcellSinr=0
...    LNCEL:ulCaMinPcellSinrQci1=0
...    LNBTS/CADPR-0:maxNumMimoLayerFdd=16
...    LNBTS:actFlexCaMgmt=true
...    LNCEL:scellFastSchedulingSelect=normal
...    LNCEL-2:scellFastSchedulingSelect=normal
...    LNCEL-3:scellFastSchedulingSelect=normal
...    LNCEL:dlCaMinPcellCqi=0
...    LNCEL-2:dlCaMinPcellCqiQci1=0
...    LNCEL-2:dlCaMinPcellCqi=0
...    LNCEL-3:dlCaMinPcellCqiQci1=0
...    LNCEL-3:dlCaMinPcellCqi=0

@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tLteNrDualConnectPrep=10000
...    LNBTS:qciTab8:nrPdcpProfIdx=1001
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC
...    LNBTS:pdcpProf1001:pdcpProfileId=1001
...    LNBTS:pdcpProf1001:snSizeDl=18bit
...    LNBTS:pdcpProf1001:snSizeUl=18bit
...    LNBTS:pdcpProf1001:statusRepReq=0
...    LNBTS:pdcpProf1001:tDiscard=300ms
...    LNBTS:nrRestrictionOverride=disabled
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:actTransmittedBelowGap=false
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNBTS:tS1eRABModInd=2000
...    LNCEL:eTputFilterConfig=51
...    LNCEL:eTputInitMcs=20

@{LTE4193}
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true

@{LTE4549}
...    LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS:enableBwCombCheck=true
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=no preference

${ue_eutra_capability_without_CA}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D4AB5F9D3A00000001D00000000E800000007400000003A00000001
...    D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000
...    001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00
...    000001D00000001BFBFFEDA00E00886429CC20070D9000000005EE800000020254A8389D0100000E10000090000B0800004200210000
...    43000088000114000230000470000900001240002500004B000098000134000280000510000A400014C0002A0000550000AC00015C00
...    02C0000590000B400016C0002E80005E0000DA0001FC0074E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A
...    00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000000074000000
...    0282000001E740000000000000000000000000000000000000000000000000000000000040471084A681873FFFFFFFFFFFFFFE8082A0
...    006008A5C000080000412C68062600E8004EF0000006000000246020A041800C020180740200

${ue_nr_capabilities}    00000000010100400004C0000038000400040160401C06000000
${ue_eutra_nr_capabilities}    0108080260C01C07000E260000000098100701C003A000000000010000402020040080801002
${ue_eutra_capability_with_UL_CA}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D4AB5F9D3A00000001D00000000E800000007400000003A00000001
...    D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000
...    001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00
...    000001D00000001BFBFFEDA00E00886429CC20070D9000000005EE800000020254A8389D0100000E1000018400000584000021001080
...    002180004400008A000118000238000480000920001280002580004C00009A000140000288000520000A60001500002A8000560000AE
...    0001600002C80005A0000B60001740002F00006D0000FE003A7400000003A00000001D00000000E800000007400000003A00000001D0
...    0000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A0000000
...    1D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A0000
...    000141000000F3A00000000000000000000000000000000000000000000000000000000000202388425340C39FFFFFFFFFFFFFFF4041
...    5000300452E00004000020963403130074002778000003000000120000430018040300E80000

@{X2shouldup_gnb7}
...      LNBTS-1/LNADJGNB-1:x2ToGnbLinkStatus=available

${gnb7_cell1}    SEPARATOR=
...    {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x501', nr_arfcn: '179500:188500',
...    suggested_band: 8}

${gnb7_cell2}    SEPARATOR=
...    {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x502', nr_arfcn: '650000:650000',
...    suggested_band: 77}

${gnb7_cell3}    SEPARATOR=
...    {id: 73, technology: nr , tac: 33, pci: '1:0', nrci: '0x503', nr_arfcn: '2079166:2079166',
...    suggested_band: 257}

${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime}    SEPARATOR=
    ...    measIdToAddModList contains (
    ...    measId eq 17,
    ...    measId eq 18,
    ...    measId eq 19
    ...    )
    ...    and measObjectToAddModList contains (
    ...    carrierFreq-r15 eq ${fnr1},
    ...    carrierFreq-r15 eq ${fnr2},
    ...    carrierFreq-r15 eq ${fnr3}
    ...    )
    ...    and reportConfigToAddModList contains (
    ...    eventB1-NR-r15 contains (
    ...    reportOnLeave-r15 eq "TRUE"
    ...    ))

${B1_deactive_for_all}    measIdToRemoveList contains (17, 18, 19)
${ENDC_A5_for_Flte3}    SEPARATOR=
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq ${flte3})
    ...    and reportConfigToAddModList contains (
    ...    a5-Threshold1 contains (
    ...    threshold-RSRP eq 97)
    ...    and a5-Threshold2 contains (
    ...    threshold-RSRP eq 0))
    ...    and measIdToAddModList contains (
    ...    measId eq 3)
    ...    and measIdToRemoveList contains (17, 18, 19)

${UL_CA}    sCellToAddModList-r10 contains (ul-CarrierFreq-r10 eq 19600)

@{delta_for_case402}
...    @{CB008218}
...    @{CB008913}
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased    #CB007332
...    LNBTS/NRDCPR-0:bufTrigForB1Nr=enabled    #enable CB007123
...    LNBTS/LNBTS_FDD-0:numRxWithHighNonGbrEnDc=1    #CB007332
...    LNCEL-1:ulEnDcConfigLevel=10
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCDPR-0:bufTrigForB1Nr=enabled

@{CB008913}
...    LNCEL-1:actNrCovEndcHo=ENDC NR-coverage HO
...    LNBTS:blockNrEndcHoAtHoFromTrg=no blocking
...    LNBTS:numB1CyclesWoEndc=1
...    LNBTS/MODPR-0:nrCovEndcHoRetryPrio=EndcHo only
...    LNBTS/MOPR-1:nrCovEndcHoRetryPrio=EndcHo only
...    LNBTS:actEndcHo=enabled    #LTE5150
...    LNBTS:actUeCapEndcHo=true    #CB006607
...    LNCEL:actEndcHoPrefLay=false    #CB007163
...    LNCEL:iFEndcHoRetryTimer=10
...    LNBTS-1:blockEndcHoRetryAtHoFromTrg=no blocking
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=noRetries
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=noRetries
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=${flte3}
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=8
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:band=77
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:band=257
...    LNCEL-1/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=${flte2}
...    LNCEL-1/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNCEL-1/LNHOIF-2:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=${flte3}
...    LNCEL-1/LNHOIF-2:thresholdRsrqEndcFilt=-120
...    LNCEL-1/LNHOIF-3:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-3:eutraCarrierInfo=${flte4}
...    LNCEL-1/LNHOIF-3:thresholdRsrqEndcFilt=-120
...    LNCEL-3/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-3/LNHOIF-1:thresholdRsrqEndcFilt=-120

...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${flte2}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${flte3}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${flte4}
...    LNBTS-1:actSelMobPrf=false
...    LNBTS-1/MODPR-0:autoAdapt=false

@{CB008218}
...    LNCEL-1:actPeriodicB1NRMeas=enhanced
...    LNBTS/NRMEASDPR-0:supervisionTimerB1NR=10    #s
...    LNBTS/NRMEASPR-0:supervisionTimerB1NR=10    #s
...    LNBTS/NRMEASDPR-0:retryTimerB1NR=30    #s
...    LNBTS/NRMEASPR-0:retryTimerB1NR=30    #s

@{recover_env_for_case402}
...    LNCEL-1:actNrCovEndcHo=disabled
...    LNBTS:actEndcHo=disabled    #LTE5150
...    LNBTS:actUeCapEndcHo=false    #CB006607
...    LNCEL-1:actPeriodicB1NRMeas=disabled

@{delta_for_case404}
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased    #CB007332
...    LNBTS/NRDCPR-0:bufTrigForB1Nr=enabled    #enable CB007123
...    LNBTS/CAGENB-0:maxDlCaConfigForUlCa=max_3CC_DL_CA
...    LNBTS:actULCAggr=UL_CA_with_smartSched
...    LNBTS:actULCaForEnDc=nonConcurrentULCaAndEnDc    #enable LTE5711
...    LNBTS:actUlTraffDrivUlCa=true    #enable LTE4050
...    LNBTS:dlCaPreferred=DLandUL
...    LNBTS:enableBwCombCheck=false
...    LNBTS/LNBTS_FDD-0:numRxWithHighNonGbrEnDc=1    #CB007332
...    LNCEL-1:ulEnDcConfigLevel=1
...    LNCEL:ulScellConfigLevel=50
...    LNBTS-1/LNBTS_FDD-0:numRxWithHighNonGbr=200    #LTE4050

@{disable_LTE4050}
...    LNBTS:actULCAggr=false
...    LNBTS:actULCaForEnDc=disabled    #enable LTE5711

@{speed_UL_CA}
...    LNBTS-1/LNBTS_FDD-0:numRxWithHighNonGbr=1    #LTE4050
...    LNCEL:ulScellConfigLevel=1
...    LNBTS/LNBTS_FDD-0:numRxWithHighNonGbrEnDc=200    #CB007332
...    LNCEL-1:ulEnDcConfigLevel=50

*** Test Cases ***
CB007123-SR-B-B4_ET_02_01_CB008913 UE counter incrementing mechanism update when bufTrigForB1Nr enabled and serving cell is anchor layer
    [Tags]
    [Documentation]
    ...    precondition:
    ...    CB007332 enabled and CB007123 enbaled for cell-1:
    ...    NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased and
    ...    NRDCPR-0:bufTrigForB1Nr=enabled
    ...    CB008913 enabled and LNBTS:numB1CyclesWoEndc=1
    ...    Case steps:
    ...    Step1: ue-1 ICS to Cell-1 with endc eligble bearer and B1 activation for DL traffic
    ...    Step2: wait B1 supervisiontimer expired, B1 deactivated and no endc A5 activaed
    ...    Step3: ue-2 ICS to Cell-1 with endc eligble bearer and B1 activation for DL traffic
    ...    Step4: report valid B1 report but no overflow indication recieved during B1 supervisiontimer
    ...    check: wait B1 supervisiontimer expired, B1 deactivated and no endc A5 activaed
    ...    Step5: ue-3 ICS to Cell-1 with endc eligble bearer and B1 activation for UL traffic
    ...    Step6: report valid B1 report and overflow indication recieved during B1 supervisiontimer
    ...    Step7: wait B1 supervisiontimer expired, B1 deactivated and endc A5 activaed for flte3
    ...    Step8: check 7123 related counters
    [Setup]    case_setup_with_delta_commission    ${delta_for_case402}
    Clear Counter files
    UE1 ICS and no endc A5 active with no B1 report during B1 supervisiontimer
    UE2 ICS and no endc A5 active with B1 report but no overflow indication during B1 supervisiontimer
    UE3 ICS and endc A5 active with B1 report and overflow indication during B1 supervisiontimer
    Check Counters    ${B1NR_MEAS_ACT_BUFFER_DL_2_UL_1}
    [Teardown]    case teardown and recover env    ${recover_env_for_case402}

CB007123-SR-B-B4_ET_04_01_buffer overflow indication trigger B1 activation interwork with LTE4050
    [Tags]
    [Documentation]
    ...    precondition:
    ...    CB007332 enabled and CB007123 enbaled for cell-1:
    ...    NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased and
    ...    NRDCPR-0:bufTrigForB1Nr=enabled
    ...    LTE4050 enabled and UL overflow for B1 activation is fast than UL traffic based CA due to the parameter setting as bellow:
    ...    for buffer based B1 activation:
    ...    LNCEL-1:ulEnDcConfigLevel=1
    ...    LNBTS/LNBTS_FDD-0:numRxWithHighNonGbrEnDc=1
    ...    for buffer based UL CA:
    ...    LNBTS-1/LNBTS_FDD-0:numRxWithHighNonGbr=200
    ...    LNCEL:ulScellConfigLevel=50
    ...    Case steps:
    ...    Step1: ue-1 ICS to Cell-1 with endc eligble bearer
    ...    Step2: B1 activate after UL overflow indication, and then UL scell addition after later UL overflow indication
    ...    Step3: ENDC establishment successfully after report B1 and recieved UL overflow indication
    ...    Step4: online change to speed UL buffer based scell addition fast than UL buffer based B1 activation
    ...    check: ue-2 ICS to Cell-1 with endc eligble bearer
    ...    Step5: UL scell addition after later UL overflow indication, and then B1 activate after UL overflow indication
    ...    Step6: ENDC establishment successfully after report B1 and recieved UL overflow indication
    [Setup]    case_setup_with_delta_commission    ${delta_for_case404}
    UE attach to cell and check no B1 activation    ue_id=1    cell_id=1    eutra_capa=${ue_eutra_capability_with_UL_CA}
    B1 activation after Buffer overflow indication and then UL CA configured    ue_id=1    qci=8    dir=ul
    Check UL buffer based ENDC setup successfully    ue_id=1
    Delta Commission Parameters    ${speed_UL_CA}
    UE attach to cell and check no B1 activation    ue_id=2    cell_id=1    eutra_capa=${ue_eutra_capability_with_UL_CA}
    UL CA configured and then B1 activation after Buffer overflow indication     ue_id=2    qci=8    dir=ul
    Check UL buffer based ENDC setup successfully    ue_id=2
    [Teardown]    case teardown and recover env    ${disable_LTE4050}

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=4CELLs_FDD_2Band3_2Band7    ue_count=30
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=20    id_type=cus
    Creat alias
    Set UE parameters for ENDC capability
    Config gnb

Creat alias
    Create enb alias    ENB_1    enb_id=1    id_type=wts
    Create enb alias    alias=gNB    enb_id=7    id_type=wts
    Create MME alias    MME_1    mme_id=1    id_type=wts

Set UE parameters for ENDC capability
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Execute Egate Command    ue_mme_param id=1-10 spid=2
    Execute Uex Command    ue_param id=1-10 dual_conn=eutra_nr pdcp_sn_extension=18bit nr_supported_bands=77,8,257

Config gnb
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=7 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=2:1

Perform Steps After Onair
    X2 link should be available

X2 link should be available
    Object Should Exist    params=${X2shouldup_gnb7}    timeout=300

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    ...     - {qci: 5, pdn: 1}
    ...     - {qci: 7, pdn: 1}
    Add Yaml    BASE_STATIONS
    ...      - id: 7
    ...        gnb_id: '0x00007'
    ...        type: simulated
    ...        plmn: '262:03'
    ...        s1u: 10.0.1.41
    ...        x2_peers: 1
    ...        cells:
    ...          - ${gnb7_cell1}
    ...          - ${gnb7_cell2}
    ...          - ${gnb7_cell3}

UE attach to cell
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${eutra_capa}=${ue_eutra_capability_without_CA}    ${mrdc_capa}=${ue_eutra_nr_capabilities}
    ${V_1}    catenate
    ...      ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${mrdc_capa}
    ...      ue_eutra_capabilities=${eutra_capa} cell=${cell_id}
    ${ret1}=    Execute Uex Command    ${V_1}

case_setup_with_delta_commission
    [Arguments]    ${delta_params}
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    ${delta_params}

case teardown and recover env
    [Arguments]    ${delta_params}
    Delta Commission Parameters    ${delta_params}
    Common Test Teardown And Stop Capture Logs

Report valid B1 report for special NRFCN
    [Arguments]    ${ue_id}=1    ${narfcn}=531040    ${pci}=2
    Execute Uex Command    ue_measurement_send id=${ue_id} narfcn=${narfcn} srsrp=79 phycell_id=${pci} nrsrp=97 event=B1_NR

UE attach to cell and check no B1 activation
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${eutra_capa}=${ue_eutra_capability_without_CA}
    Expect message will not occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime})
    ...    alias=B1_activation    overall_timeout=20
    UE attach to cell    ue_id=${ue_id}    cell_id=${cell_id}    eutra_capa=${eutra_capa}
    Flow Not Occurred For message    alias=B1_activation

B1 activation after Buffer overflow indication
    [Arguments]    ${ue_id}=1    ${qci}=8    ${dir}=dl    ${B1_active}=${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime}    ${trf_id}=1
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_active})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=B1_active    overall_timeout=20
    Execute Uex Command    trf_data_start trf_id=${trf_id} dir=${dir} Mbps=150 ue=${ue_id} protocol=udp qci=${qci} duration=5 duration_unit=seconds
    Flow Occurred As Expected    alias=B1_active
    Execute Uex Command    trf_data_stop trf_id=${trf_id} ue=${ue_id}

Check UL buffer based ENDC setup successfully
    [Arguments]    ${ue_id}=1    ${qci}=8
    Expect message flow
    ...    gNB:X2AP_SgNBAdditionRequest
    ...    gNB:X2AP_SgNBAdditionRequestAcknowledge
    ...    gNB:X2AP_SgNBReconfigurationComplete
    ...    gNB:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (17,18,19))
    ...    alias=ENDC_setup    overall_timeout=20
    Report valid B1 report for special NRFCN    ue_id=${ue_id}    narfcn=${fnr3}    pci=3
    Execute Uex Command    trf_data_start trf_id=1 dir=ul Mbps=150 ue=${ue_id} protocol=udp qci=${qci} duration=5 duration_unit=seconds
    Flow Occurred As Expected    alias=ENDC_setup
    Execute Uex Command    trf_data_stop trf_id=1 ue=${ue_id}

Wait B1 supervision timer expired and check B1 deactivated and no ENDC A5 activation
    [Arguments]    ${ue_id}=1    ${B1_deactive}=${B1_deactive_for_all}    ${endc_A5_activate}=${ENDC_A5_for_Flte3}    ${timerout}=12
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_deactive})
    ...    alias=B1_deactive    overall_timeout=${timerout}
    Expect message will not occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${endc_A5_activate})
    ...    alias=NO_ENDC_A5    overall_timeout=${timerout}
    Flow Occurred As Expected    alias=B1_deactive
    Flow Not Occurred For message    alias=NO_ENDC_A5

Start traffic for UE
    [Arguments]    ${ue_id}=1    ${qci}=8    ${duration}=60
    Execute Uex Command    trf_data_start ue=${ue_id} dir=ul protocol=udp Mbps=150 qci=${qci} duration=${duration} duration_unit=seconds

wait B1 supervision timer expired and expected ENDC A5 activated
    [Arguments]    ${ue_id}    ${ENDC_A5_active_and_B1_deactive}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${ENDC_A5_active_and_B1_deactive})
    ...    alias=ENDC_A5_activate    overall_timeout=20
    Flow Occurred As Expected    alias=ENDC_A5_activate

UE1 ICS and no endc A5 active with no B1 report during B1 supervisiontimer
    UE attach to cell and check no B1 activation    ue_id=1    cell_id=1
    B1 activation after Buffer overflow indication    ue_id=1    qci=8    dir=dl
    Wait B1 supervision timer expired and check B1 deactivated and no ENDC A5 activation    ue_id=1

UE2 ICS and no endc A5 active with B1 report but no overflow indication during B1 supervisiontimer
    UE attach to cell and check no B1 activation    ue_id=2    cell_id=1
    B1 activation after Buffer overflow indication    ue_id=2    qci=8    dir=dl
    sleep    5s    #wait for traffic stop really
    Report valid B1 report for special NRFCN    ue_id=2    narfcn=${fnr2}    pci=2
    Wait B1 supervision timer expired and check B1 deactivated and no ENDC A5 activation    ue_id=2

UE3 ICS and endc A5 active with B1 report and overflow indication during B1 supervisiontimer
    UE attach to cell and check no B1 activation    ue_id=3    cell_id=1
    B1 activation after Buffer overflow indication    ue_id=3    qci=8    dir=ul
    Report valid B1 report for special NRFCN    ue_id=3    narfcn=${fnr2}    pci=2
    Start traffic for UE    ue_id=3
    wait B1 supervision timer expired and expected ENDC A5 activated    ue_id=3    ENDC_A5_active_and_B1_deactive=${ENDC_A5_for_Flte3}

B1 activation after Buffer overflow indication and then UL CA configured
    [Arguments]    ${ue_id}=1    ${qci}=8    ${dir}=ul    ${B1_active}=${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime}    ${trf_id}=1
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_active})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${UL_CA})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=B1_active_and_UL_CA    overall_timeout=20
    Execute Uex Command    trf_data_start trf_id=${trf_id} dir=${dir} Mbps=150 ue=${ue_id} protocol=udp qci=${qci} duration=5 duration_unit=seconds
    Flow Occurred As Expected    alias=B1_active_and_UL_CA
    Execute Uex Command    trf_data_stop trf_id=${trf_id} ue=${ue_id}

UL CA configured and then B1 activation after Buffer overflow indication
    [Arguments]    ${ue_id}=1    ${qci}=8    ${dir}=ul    ${B1_active}=${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime}    ${trf_id}=1
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${UL_CA})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_active})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=B1_active_and_UL_CA    overall_timeout=20
    Execute Uex Command    trf_data_start trf_id=${trf_id} dir=${dir} Mbps=150 ue=${ue_id} protocol=udp qci=${qci} duration=5 duration_unit=seconds
    Flow Occurred As Expected    alias=B1_active_and_UL_CA
    Execute Uex Command    trf_data_stop trf_id=${trf_id} ue=${ue_id}