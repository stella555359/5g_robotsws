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

${flte2}    1600    #band3
${flte3}    2870    #band7
${flte4}    3100    #band7

${fnr1}    188512    #nr band 8
${fnr2}    650048    #nr band 77
${fnr3}    2079200    #nr band 257
${fnr4}    188500    #nr band 8

@{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400    #band3
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1600    #band3
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19600
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=2870    #band7
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=20870
...    LNCEL-4/LNCEL_FDD-0:earfcnDL=3100    #band7
...    LNCEL-4/LNCEL_FDD-0:earfcnUL=21100

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

${ue_eutra_capabilities_3CC_3A_3A_7A}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D4AB5F9D3A00000001D00000000E800000007400000003A00000001
...    D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000
...    001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00
...    000001D00000001BFBFFEDA00E00886429CC20070D9000000005EE800000020254A8389D0100000E10000084000B0800004200230001
...    C200001180002200004500008C00011C0002400004900009400012C0002600004D0000A0000144000290000530000A80001540002B00
...    00570000B00001640002D00005B0000BA0001780003680007F001D3A00000001D00000000E800000007400000003A00000001D000000
...    00E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D000
...    00000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D
...    00000000A080000079D000000000000000000000000000000000000000000000000000000000001011C42129A061CFFFFFFFFFFFFFFF
...    A020A8001802297000020000104B1A0189803A0013BC00000180000009000021800C020180740000

${ue_nr_capabilities}    00000000010100400004C0000038000400040160401C06000000
${ue_eutra_nr_capabilities}    0108080260C01C07000E260000000098100701C003A000000000010000402020040080801002

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

${B1_activate_for_Fnr1_Fnr2_Fnr3_Fnr4_firstTime}    SEPARATOR=
    ...    measIdToAddModList contains (
    ...    measId eq 17,
    ...    measId eq 18,
    ...    measId eq 19,
    ...    measId eq 20
    ...    )
    ...    and measObjectToAddModList contains (
    ...    carrierFreq-r15 eq ${fnr1},
    ...    carrierFreq-r15 eq ${fnr2},
    ...    carrierFreq-r15 eq ${fnr3},
    ...    carrierFreq-r15 eq ${fnr4}
    ...    )
    ...    and reportConfigToAddModList contains (
    ...    eventB1-NR-r15 contains (
    ...    reportOnLeave-r15 eq "TRUE"
    ...    ))

${B1_activate_and_scell_addition}    SEPARATOR=
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
    ...    and sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1
    ...    and dl-CarrierFreq-r10 eq ${flte3})
    ...    and (length(sCellToAddModList-r10) eq 1)

${B1_reactivation_and_no_scell_addition}    SEPARATOR=
    ...    measIdToAddModList contains (
    ...    measId eq 17,
    ...    measId eq 18,
    ...    measId eq 19)
    ...    and sCellToAddModList-r10 is not present

${B1_reactivation_and_scell_addition}    SEPARATOR=
    ...    measIdToAddModList contains (
    ...    measId eq 17,
    ...    measId eq 18,
    ...    measId eq 19)
    ...    and sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 2
    ...    and dl-CarrierFreq-r10 eq ${flte2})
    ...    and (length(sCellToAddModList-r10) eq 2)

${6_Inter_frequency}    SEPARATOR=
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq 1600,
    ...    carrierFreq eq 2870,
    ...    carrierFreq eq 3100,
    ...    carrierFreq eq 38000,
    ...    carrierFreq eq 38100,
    ...    carrierFreq eq 38200) and measIdToAddModList contains (
    ...    measId eq 14 and measObjectId eq 2 and reportConfigId eq 6,
    ...    measId eq 15 and measObjectId eq 2 and reportConfigId eq 7,
    ...    measId eq 16 and measObjectId eq 3 and reportConfigId eq 6,
    ...    measId eq 17 and measObjectId eq 3 and reportConfigId eq 7,
    ...    measId eq 18 and measObjectId eq 4 and reportConfigId eq 6,
    ...    measId eq 19 and measObjectId eq 4 and reportConfigId eq 7,
    ...    measId eq 20 and measObjectId eq 5 and reportConfigId eq 6,
    ...    measId eq 21 and measObjectId eq 5 and reportConfigId eq 7,
    ...    measId eq 22 and measObjectId eq 6 and reportConfigId eq 6,
    ...    measId eq 23 and measObjectId eq 6 and reportConfigId eq 7,
    ...    measId eq 24 and measObjectId eq 7 and reportConfigId eq 6,
    ...    measId eq 25 and measObjectId eq 7 and reportConfigId eq 7)

${6_Inter_frequency_after_endc}    SEPARATOR=
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq 1600,
    ...    carrierFreq eq 2870,
    ...    carrierFreq eq 3100,
    ...    carrierFreq eq 38000,
    ...    carrierFreq eq 38100,
    ...    carrierFreq eq 38200) and measIdToAddModList contains (
    ...    measId eq 14 and measObjectId eq 6 and reportConfigId eq 7,
    ...    measId eq 15 and measObjectId eq 6 and reportConfigId eq 8,
    ...    measId eq 16 and measObjectId eq 7 and reportConfigId eq 7,
    ...    measId eq 17 and measObjectId eq 7 and reportConfigId eq 8,
    ...    measId eq 18 and measObjectId eq 8 and reportConfigId eq 7,
    ...    measId eq 19 and measObjectId eq 8 and reportConfigId eq 8,
    ...    measId eq 20 and measObjectId eq 9 and reportConfigId eq 7,
    ...    measId eq 21 and measObjectId eq 9 and reportConfigId eq 8,
    ...    measId eq 22 and measObjectId eq 10 and reportConfigId eq 7,
    ...    measId eq 23 and measObjectId eq 10 and reportConfigId eq 8,
    ...    measId eq 24 and measObjectId eq 11 and reportConfigId eq 7,
    ...    measId eq 25 and measObjectId eq 11 and reportConfigId eq 8)

${B1_activate_for_Fnr2_Fnr3_Fnr4_firstTime}    SEPARATOR=
    ...    measIdToAddModList contains (
    ...    measId eq 3 and measObjectId eq 8 and reportConfigId eq 8,
    ...    measId eq 6 and measObjectId eq 9 and reportConfigId eq 8,
    ...    measId eq 7 and measObjectId eq 10 and reportConfigId eq 8
    ...    )
    ...    and measObjectToAddModList contains (
    ...    carrierFreq-r15 eq ${fnr4},
    ...    carrierFreq-r15 eq ${fnr3},
    ...    carrierFreq-r15 eq ${fnr2}
    ...    )
    ...    and reportConfigToAddModList contains (
    ...    eventB1-NR-r15 contains (
    ...    reportOnLeave-r15 eq "TRUE"
    ...    ))

${B1_reactivation_for_Fnr2_Fnr3_Fnr4}    SEPARATOR=
    ...    measIdToAddModList contains (
    ...    measId eq 3 and measObjectId eq 2 and reportConfigId eq 5,
    ...    measId eq 6 and measObjectId eq 3 and reportConfigId eq 5,
    ...    measId eq 7 and measObjectId eq 4 and reportConfigId eq 5
    ...    )

${B1_activated_when_Inter_freq_deactivated}    SEPARATOR=
    ...    measIdToAddModList contains (
    ...    measId eq 17 and measObjectId eq 11 and reportConfigId eq 8
    ...    )
    ...    and measObjectToAddModList contains (
    ...    carrierFreq-r15 eq ${fnr1}
    ...    )
    ...    and measIdToRemoveList contains ( 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25)

${B1_activated_when_Inter_freq_deactivated_after_endc}    SEPARATOR=
    ...    measIdToAddModList contains (
    ...    measId eq 17 and measObjectId eq 5 and reportConfigId eq 5
    ...    )
    ...    and measIdToRemoveList contains ( 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25)

${B1_deactive_for_all}    measIdToRemoveList contains (17, 18, 19)

@{delta_for_case502}
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:lcrId=2
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased    #CB007332
...    LNBTS/NRDCPR-0:bufTrigForB1Nr=enabled    #enable CB007123
...    LNBTS/LNBTS_FDD-0:numRxWithHighNonGbrEnDc=1    #CB007332
...    LNCEL-1:ulEnDcConfigLevel=10
...    LNCEL-2:ulEnDcConfigLevel=10
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCDPR-0:bufTrigForB1Nr=enabled
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased    #enable CB007332
...    LNCEL-1:act3fdd3tddRestrict=true
...    LNCEL-1:actSixIfMeasurements=true
...    LNBTS:actIncCarrMonit=false
...    LNBTS-1:actSelMobPrf=false
...    LNBTS-1/MODPR-0:autoAdapt=true
...    LNCEL-1:actPeriodicB1NRMeas=disabled
...    LNCEL-1/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=${flte2}
...    LNCEL-1/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNCEL-1/LNHOIF-2:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=${flte3}
...    LNCEL-1/LNHOIF-2:thresholdRsrqEndcFilt=-120
...    LNCEL-1/LNHOIF-3:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-3:eutraCarrierInfo=${flte4}
...    LNCEL-1/LNHOIF-3:thresholdRsrqEndcFilt=-120
...    LNCEL-1/LNHOIF-4:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-4:eutraCarrierInfo=38000
...    LNCEL-1/LNHOIF-4:thresholdRsrqEndcFilt=-120
...    LNCEL-1/LNHOIF-5:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-5:eutraCarrierInfo=38100
...    LNCEL-1/LNHOIF-5:thresholdRsrqEndcFilt=-120
...    LNCEL-1/LNHOIF-6:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-6:eutraCarrierInfo=38200
...    LNCEL-1/LNHOIF-6:thresholdRsrqEndcFilt=-120
...    LNCEL-1/LNHOIF-1:a5TimeToTriggerInterFreq=40ms
...    LNCEL-1/LNHOIF-1:a5ReportIntervalInterFreq=120ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:carrierFreqNrCell=188500
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:freqBandIndicatorNrL:freqBandIndicatorNr=8
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:nrCarPrio=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-3:ssbSubcarrierSpacing=30kHz

@{delta_for_case603}
...    @{LTE2276_A3_based_scell_addition}
...    @{CB008218}
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased    #CB007332
...    LNBTS/NRDCPR-0:bufTrigForB1Nr=enabled    #enable CB007123
...    LNBTS/LNBTS_FDD-0:numRxWithHighNonGbrEnDc=1    #CB007332
...    LNCEL-1:ulEnDcConfigLevel=10
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCDPR-0:bufTrigForB1Nr=enabled    #disable CB007123

@{LTE2276_A3_based_scell_addition}
...    LNBTS:actA3ScellSelect=true
...    LNCEL-1/CAPR-1:a3Offset=-8
...    LNCEL-1/CAPR-1:a3TimeToTrigger=ms80
...    LNCEL-1/CAPR-1:a3TriggerQuantity=RSRQ
...    LNCEL-1/CAPR-1:hysA3Offset=0
...    LNCEL-1/CAPR-1:scellMeasThreshRsrp=-120
...    LNCEL-1/CAPR-1:scellMeasThreshRsrq=-130
...    LNCEL-1/CAPR-1:enableA3Event=true
...    LNCEL-1/CAPR-1:earfcnDL=${flte2}
...    LNCEL-1/CAPR-2:a3Offset=-8
...    LNCEL-1/CAPR-2:a3TimeToTrigger=ms80
...    LNCEL-1/CAPR-2:a3TriggerQuantity=RSRQ
...    LNCEL-1/CAPR-2:hysA3Offset=0
...    LNCEL-1/CAPR-2:scellMeasThreshRsrp=-120
...    LNCEL-1/CAPR-2:scellMeasThreshRsrq=-130
...    LNCEL-1/CAPR-2:enableA3Event=false
...    LNCEL-1/CAPR-2:earfcnDL=${flte3}
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=4-layer

@{CB008218}
...    LNCEL-1:actPeriodicB1NRMeas=enhanced
...    LNBTS/NRMEASDPR-0:supervisionTimerB1NR=10    #s
...    LNBTS/NRMEASPR-0:supervisionTimerB1NR=10    #s
...    LNBTS/NRMEASDPR-0:retryTimerB1NR=30    #s
...    LNBTS/NRMEASPR-0:retryTimerB1NR=30    #s

@{Case603_recover_env}
...    LNBTS:actA3ScellSelect=false
...    LNCEL-1:actPeriodicB1NRMeas=disabled

*** Test Cases ***
CB007123-SR-B-B5_ET_02_01_no DL buffer overflow indication trigger B1 activation due to inter-RAT or inter-frequency measurement deactivation
    [Tags]
    [Documentation]
    ...    precondition:
    ...    CB007332 enabled and CB007123 enbaled for cell-1 :
    ...    NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased and
    ...    NRDCDPR-0:bufTrigForB1Nr=enabled, NRDCDPR-0:bufTrigForB1Nr=enabled
    ...    and there are 4 carrierFreqNrCell {Fnr1, Fnr2, Fnr3, Fnr4} for NRDCDPR and 6 inter frequency measurement for cell-1
    ...    Case steps:
    ...    Step1: UE1 ICS to Cell-1 with endc eligble bearer and no B1 activation immediately
    ...    step2: UE1 report A2 and then six inter-frequency layer measurement configured
    ...    step3: start traffic for DL and then only 3 layers (Fnr4,Fnr3,Fnr2) for B1 activation due to capacity is 9
    ...    Step4: UE1 report A1 and then inter-frequency deactivate and together with additional B1(Fnr1) activation without buffer
    ...    Step5: UE2 ICS to Cell-1 and endc setup succesfully after B1 activation with buffer
    ...    step6: UE2 report A2 and then six inter-frequency layer measurement configured
    ...    step7: UE2 endc tackback when LTE inactivity timer expired
    ...    step8: UE2 B1 activation for only 3 layers when received DL overflow indication due to capacity is 9
    ...    Step9: UE2 report A1 and then inter-frequency deactivate and together with additional B1(Fnr1) activation without buffer
    [Setup]    case_setup_with_delta_commission    ${delta_for_case502}
    UE attach to cell and check no B1 activation    ue_id=1    cell_id=1
    Inter frequency measurement configured after A2 report    ue_id=1
    B1 activation after Buffer overflow indication    ue_id=1    qci=8    dir=dl    B1_active=${B1_activate_for_Fnr2_Fnr3_Fnr4_firstTime}
    Additional B1 measurement activated after Inter frequency measurement deactivated after A1 report    ue_id=1
    UE2 ICS and ENDC setup successfully after B1 activation with buffer
    Inter frequency measurement configured after A2 report    ue_id=2    check=${6_Inter_frequency_after_endc}
    ENDC takeback after LTE inactivity timer expired    ue_id=2
    B1 activation after Buffer overflow indication    ue_id=2    qci=8    dir=dl    B1_active=${B1_reactivation_for_Fnr2_Fnr3_Fnr4}
    Additional B1 measurement activated after Inter frequency measurement deactivated after A1 report
    ...    ue_id=2    check=${B1_activated_when_Inter_freq_deactivated_after_endc}

CB007123-SR-B-B6_ET_03_01_buffer overflow indication trigger B1 activation interwork with CB008218
    [Tags]
    [Documentation]
    ...    precondition:
    ...    CB007332 enabled and CB007123 enbaled for cell-1 :
    ...    NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased and
    ...    NRDCDPR-0:bufTrigForB1Nr=enabled, NRDCDPR-0:bufTrigForB1Nr=enabled
    ...    and there are 3 carrierFreqNrCell {Fnr1, Fnr2, Fnr3} for NRDCPR
    ...    UE with eutra capability: 3A_3A_7A
    ...    LTE2276 and CB008218 enabled: enableA3Event=true only for frequency flte2
    ...    Case steps:
    ...    Step1: UE1 ICS to Cell-1 with endc eligble bearer and no B1 activation immediately
    ...    step2: B1 activtion and together with DL scell addition(only flte3) when recieved DL overflow indication
    ...    step3: B1 deactive when B1 supervision timer expired
    ...    Step4: B1 reactivtion and no scell addition when recieved DL overflow indication due to no A3 report for flte2
    ...    Step5: B1 deactive when B1 supervision timer expired
    ...    step6: UE1 report A3 for LTE cell-2
    ...    step7: B1 reactivtion and together with DL scell addition(flte2) when recieved DL overflow indication due to A3 recieved before
    [Setup]    case_setup_with_delta_commission    ${delta_for_case603}
    UE attach to cell and check no B1 activation    ue_id=1    cell_id=1    eutra_capa=${ue_eutra_capabilities_3CC_3A_3A_7A}
    B1 activation after Buffer overflow indication    ue_id=1    qci=8    dir=dl    B1_active=${B1_activate_and_scell_addition}
    Wait B1 supervision timer expired and check B1 deactivated    ue_id=1
    B1 activation after Buffer overflow indication    ue_id=1    qci=8    dir=dl    B1_active=${B1_reactivation_and_no_scell_addition}
    Wait B1 supervision timer expired and check B1 deactivated    ue_id=1
    Trigger UE to send A3 measurement    ue_id=1    earfcn=1600
    B1 activation after Buffer overflow indication    ue_id=1    qci=8    dir=dl    B1_active=${B1_reactivation_and_scell_addition}
    [Teardown]    case teardown and recover env    ${Case603_recover_env}

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
    Cells Should Be OnAir

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

Check DL buffer based ENDC setup successfully
    [Arguments]    ${ue_id}=1    ${qci}=6
    Expect message flow
    ...    gNB:X2AP_SgNBAdditionRequest
    ...    gNB:X2AP_SgNBAdditionRequestAcknowledge
    ...    gNB:X2AP_SgNBReconfigurationComplete
    ...    gNB:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration
    ...    alias=ENDC_setup    overall_timeout=20
    Report valid B1 report for special NRFCN    ue_id=${ue_id}    narfcn=${fnr3}    pci=3
    Execute Uex Command    trf_data_start trf_id=1 dir=dl Mbps=150 ue=${ue_id} protocol=udp qci=${qci} duration=5 duration_unit=seconds
    Flow Occurred As Expected    alias=ENDC_setup
    Execute Uex Command    trf_data_stop trf_id=1 ue=${ue_id}

Inter frequency measurement configured after A2 report
    [Arguments]    ${ue_id}=1    ${check}=${6_Inter_frequency}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${check})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=Inter_freq_confgured    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=0 srsrq=34
    Flow Occurred As Expected    alias=Inter_freq_confgured

Additional B1 measurement activated after Inter frequency measurement deactivated after A1 report
    [Arguments]    ${ue_id}=1    ${check}=${B1_activated_when_Inter_freq_deactivated}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${check})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=B1_activated    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A1 srsrp=75 srsrq=0
    Flow Occurred As Expected    alias=B1_activated

ENDC takeback after LTE inactivity timer expired
    [Arguments]    ${ue_id}
    Expect message flow
    ...    gNB:X2AP_SgNBReleaseRequired
    ...    gNB:X2AP_SgNBReleaseConfirm
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration
    ...    gNB:X2AP_SNStatusTransfer
    ...    alias=ENDC_takeback    overall_timeout=20
    Execute Egate Command    enb_ue_dc_release by=gnb cause=RN_user_inactivity ue=${ue_id}    UEContextRelease
    Flow Occurred As Expected    alias=ENDC_takeback

UE2 ICS and ENDC setup successfully after B1 activation with buffer
    UE attach to cell and check no B1 activation    ue_id=2    cell_id=1
    B1 activation after Buffer overflow indication    ue_id=2    qci=8    dir=dl    B1_active=${B1_activate_for_Fnr1_Fnr2_Fnr3_Fnr4_firstTime}
    Check DL buffer based ENDC setup successfully    ue_id=2    qci=8

Trigger UE to send A3 measurement
    [Arguments]    ${ue_id}=1    ${earfcn}=1600
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A3 srsrp=79 srsrq=0 nrsrp=97 nrsrq=23 earfcn=${earfcn} phycell_id=2

Wait B1 supervision timer expired and check B1 deactivated
    [Arguments]    ${ue_id}=1    ${B1_deactive}=${B1_deactive_for_all}    ${timerout}=20
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_deactive})
    ...    alias=B1_deactive    overall_timeout=${timerout}
    Flow Occurred As Expected    alias=B1_deactive
