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
...    @{HO_para}
...    @{X2_MOCs}

${flte1}    1400    #band3
${flte2}    1600    #band3
${flte3}    2870    #band7
${flte4}    3100    #band7

${fnr1}    188512    #nr band 8
${fnr2}    650048    #nr band 77
${fnr3}    2079200    #nr band 257

${nci-115970}    0x1C502

@{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400    #band3
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1600    #band3
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19600
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=2870    #band7
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=20870
...    LNCEL-4/LNCEL_FDD-0:earfcnDL=3100    #band7
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

@{HO_para}
...    LNBTS-1:actIfHo=enabled
...    LNBTS/MOPR-1:freqLayListLte=${flte1},${flte2},${flte3},${flte4}
...    LNBTS/MODPR-0:freqLayListLte=${flte1},${flte2},${flte3},${flte4}
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=${flte3}
...    LNCEL-3/LNHOIF-1:eutraCarrierInfo=${flte1}

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
${ue_eutra_capability_ANR}    SEPARATOR=
...    DD9FF430830008081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C1082
...    080304218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B082008284105182083841004
...    142082061040105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82
...    E0B82E0B82E0B82E0B82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F83000008
...    1010440668003E71E00020406080C0E162636383A83F7FC4B5A68190BFCD08750003006D9200004000020973C0600007404061304D40
...    1E01BFE0000050000003080044000A103FC021310001C0

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

${B1_reactivation}    SEPARATOR=
    ...    measIdToAddModList contains (
    ...    measId eq 17,
    ...    measId eq 18,
    ...    measId eq 19)

${B1_reactivation_for_two_layer}    SEPARATOR=
    ...    measIdToAddModList contains (
    ...    measId eq 17,
    ...    measId eq 18)

${B1_reactive_for_third_layer}    measIdToAddModList contains (measId eq 19)

${HO_successful_to_lte1}    SEPARATOR=
    ...    mobilityControlInfo contains (
    ...    targetPhysCellId eq 1
    ...    and carrierFreq contains (
    ...    dl-CarrierFreq eq ${flte1}))

${add_DRB_5}    drb-ToAddModList contains (drb-Identity eq 5)
${add_DRB_6}    drb-ToAddModList contains (drb-Identity eq 6)
${add_DRB_7}    drb-ToAddModList contains (drb-Identity eq 7)
${add_DRB_8}    drb-ToAddModList contains (drb-Identity eq 8)
${del_DRB_5}    drb-ToReleaseList contains (5)
${del_DRB_6}    drb-ToReleaseList contains (6)
${del_DRB_7}    drb-ToReleaseList contains (7)
${del_DRB_8}    drb-ToReleaseList contains (8)

${config_RSC}    reportConfigToAddModList contains (purpose eq 'reportStrongestCells')
${config_CGI}    reportConfigToAddModList contains (purpose eq 'reportCGI')
${NR_redirection}    redirectedCarrierInfo contains (carrierFreq-r15 eq ${fnr3})
${two_SCG_bearer}    SEPARATOR=
    ...    E-RABs-Admitted-ToBeAdded-SgNBAddReqAckList contains (
    ...    (e-RAB-ID eq 6),
    ...    (e-RAB-ID eq 7))

@{delta_for_case1}
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased
...    LNBTS/NRDCPR-0:bufTrigForB1Nr=enabled    #enable CB007123
...    LNBTS/LNBTS_FDD-0:numRxWithHighNonGbrEnDc=1    #CB007332
...    LNCEL-1:ulEnDcConfigLevel=10
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNBTS/NRDCDPR-0:bufTrigForB1Nr=disabled    #disable CB007123

@{delta_for_case6}
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased
...    LNBTS/NRDCPR-0:bufTrigForB1Nr=${EMPTY}    #disable CB007123
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNBTS/LNBTS_FDD-0:numRxWithHighNonGbrEnDc=1    #CB007332
...    LNCEL-1:ulEnDcConfigLevel=10
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=2
...    LNBTS/NRDCDPR-0:bufTrigForB1Nr=enabled    #enable CB007123
...    LNBTS:qciTab5:nrPdcpProfIdx=1001
...    LNBTS:qciTab5:lteNrDualConnectSupport=EN-DC
...    LNBTS:qciTab7:nrPdcpProfIdx=1001
...    LNBTS:qciTab7:lteNrDualConnectSupport=EN-DC
...    LNBTS:actMultiSCGSplit=true    #LTE4531

@{Case6_recover_env}
...    LNBTS:actMultiSCGSplit=false    #LTE4531
...    LNBTS:qciTab5:lteNrDualConnectSupport=disabled
...    LNBTS:qciTab7:lteNrDualConnectSupport=disabled

@{delta_for_case202}
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:lcrId=2
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCPR-0:bufTrigForB1Nr=disabled    #disable CB007123
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased    #enable CB007332
...    LNBTS/LNBTS_FDD-0:numRxWithHighNonGbrEnDc=1    #CB007332
...    LNCEL-1:ulEnDcConfigLevel=10
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCDPR-0:bufTrigForB1Nr=enabled    #enable CB007123
...    LNBTS:actVoLteNoEnDc=QCI65/66 and all QCI1 calls
...    LNBTS/LNBTS_FDD-0:actPubSafetyBearers=true
...    LNBTS/LNBTS_FDD-0:skipPsQciUeReleaseCheck=true
...    LNCEL:inactivityTimerPubSafety=1000

@{Case202_recover_env}
...    LNBTS:actVoLteNoEnDc=disabled

@{delta_for_case304}
...    @{CB007266}
...    @{CB007334}
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:lcrId=2
...    LNBTS/NRDCPR-0:bufTrigForB1Nr=disabled    #disable CB007123
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased    #enable CB007332
...    LNBTS/LNBTS_FDD-0:numRxWithHighNonGbrEnDc=1    #CB007332
...    LNCEL-1:ulEnDcConfigLevel=10
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCDPR-0:bufTrigForB1Nr=enabled    #enable CB007123

...    LNCEL/LNRELGNBCELL-3:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-3:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-3:nrCellId=115971    # SSBfrequency=2079200 for GNB-7 cell-3
...    LNCEL/LNRELGNBCELL-3:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-3:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-3:nrCgiPlmnId:mncLength=2

@{CB007266}
...    LNCEL:inactivityTimer=40
...    LNBTS:b1NrRedirectTimer=2000
...    LNCEL-1:actB1ReturnTo5GSA=true
...    LNCEL-1:actReturnTo5GSA=at end of RRC or voice calls
...    LNCEL-1/REDRT-1:redirRat=nr
...    LNCEL-1/REDRT-1:redirNrCarFrq:carrierFreqNrCell=${fnr3}
...    LNCEL-1/REDRT-1:redirNrCarFrq:ssbSubcarrierSpacing=120kHz
...    LNCEL-1/REDRT-1:redirNrCarFrq:ssbDuration=${EMPTY}
...    LNCEL-1/REDRT-1:redirNrCarFrq:ssbOffset=${EMPTY}
...    LNCEL-1/REDRT-1:redirNrCarFrq:ssbPeriodicity=${EMPTY}
...    LNCEL-1/REDRT-1:csFallBPrio=${EMPTY}

@{CB007334}
...    delete:LNCEL-1/LNRELGNBCELL-2
...    delete:LNCEL-1/LNRELGNBCELL-1
...    delete:LNCEL-1/LNRELGNBCELL-255
...    LNBTS:actUeBasedAnrNr=true
...    LNBTS/ANR-0:actAutoNrNeighRemoval=true
...    LNBTS/ANR-0:anrNrParamList:anrDefRelDcAllowed=true|paramPlmnId=0
...    LNBTS/ANR-0:anrNrParamList:carrierFreqNrCell=650048|paramPlmnId=0
...    LNBTS/ANR-0:anrNrParamList:gNBIdLength=22|paramPlmnId=0
...    LNBTS/ANR-0:anrNrParamList:frqNrCarSelect=Single Carrier|paramPlmnId=0
...    LNBTS/ANR-0:anrNrParamList:paramMeasConfId=1|paramPlmnId=0
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrp=6|paramMeasConfId=1
...    LNBTS/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-80|paramMeasConfId=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:nrPciNbrRelRemThresh=50000
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:nrPciNbrRelAddThresh=3
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:nrPciNbrRelAddThresh=3
...    LNBTS/ANR-0:anrNrNbrRelRemGuardTime=3
...    LNBTS/ANR-0:anrNrParamPlmnList:mcc=262|paramPlmnId=1
...    LNBTS/ANR-0:anrNrParamPlmnList:mnc=3|paramPlmnId=1
...    LNBTS/ANR-0:anrNrParamPlmnList:mncLength=2|paramPlmnId=1
...    LNBTS/ANR-0:anrNrInactivityTimer=35
...    LNBTS/ANR-0:anrNrCoverageConfirmTimer=2500
...    LNBTS/ANR-0:anrIfTRSC=8000
...    LNBTS/ANR-0:anrRttTRSCFS=8000ms

@{LNRELGNBCELL_255}
...    LNCEL-1/LNRELGNBCELL-255:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-255:nrCellId=115970
...    LNCEL-1/LNRELGNBCELL-255:nrStatus=available
...    LNCEL-1/LNRELGNBCELL-255:sourceOfData=UE

@{Case304_recover_env}
...    LNBTS:actUeBasedAnrNr=false
...    LNBTS/ANR-0:actAutoNrNeighRemoval=false
...    LNCEL-1:actB1ReturnTo5GSA=false
...    LNCEL-1:actReturnTo5GSA=disabled
...    delete:LNCEL-1/LNRELGNBCELL-255

@{delta_for_case305}
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased
...    LNBTS/LNBTS_FDD-0:numRxWithHighNonGbrEnDc=1
...    LNCEL-1:ulEnDcConfigLevel=10
...    LNBTS/NRDCPR-0:bufTrigForB1Nr=enabled
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCDPR-0:bufTrigForB1Nr=disabled
...    @{CB006613}

@{CB006613}
...    LNBTS:actEndcDropMonitor=true
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:endcNrDropThresh=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:endcNrDropThreshTimer=10s    #s
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:endcNrDropWaitTimer=5000    #ms

@{Case305_recover_env}
...    LNBTS:actEndcDropMonitor=false

*** Test Cases ***
CB007123-SR-B-B1_ET_01_01_Buffer overflow indication trigger B1 activation when UE enter cell by ICS or reestablish or Ho
    [Tags]    TC101
    [Documentation]
    ...    precondition:
    ...    CB007332 enabled and CB007123 enbaled for cell-1 :
    ...    NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased and NRDCPR-0:bufTrigForB1Nr=enabled
    ...    and there are 3 carrierFreqNrCell {Fnr1, Fnr2, Fnr3} for NRDCDPR
    ...    Case steps:
    ...    Step1: UE-1 ICS to Cell-1 and no B1 activation immediately
    ...    check: DL buffer overflow and B1 activated with Fnr1, Fnr2, Fnr3
    ...    step2: UE-2 reestablish to cell-1, no B1 activation immediately
    ...    check: DL buffer overflow and B1 activated with Fnr1, Fnr2, Fnr3
    ...    step3: UE-3 HO to cell-1, no B1 activation immediately
    ...    check: DL buffer overflow and B1 activated with Fnr1, Fnr2, Fnr3
    ...    Step4: UE-1 ICS to Cell-1 and no B1 activation immediately
    ...    check: UL buffer overflow and B1 activated with Fnr1, Fnr2, Fnr3
    [Setup]    case_setup_with_delta_commission    ${delta_for_case1}
    UE attach to cell and check no B1 activation    ue_id=1    cell_id=1
    B1 activation after Buffer overflow indication    ue_id=1    qci=8    dir=dl
    UE attach to cell and check no B1 activation    ue_id=2    cell_id=1
    UE reestablish on serving cell and no B1 activation    ue_id=2    cell_id=1
    B1 activation after Buffer overflow indication    ue_id=2    qci=8    dir=dl
    UE attach to cell and check no B1 activation    ue_id=3    cell_id=3
    UE HO to cell-1 and no B1 activation    ue_id=3    cell_id=1
    B1 activation after Buffer overflow indication    ue_id=3    qci=8    dir=dl
    UE attach to cell and check no B1 activation    ue_id=4    cell_id=1
    B1 activation after Buffer overflow indication    ue_id=4    qci=8    dir=ul

CB007123-SR-B-B1_ET_06_01_buffer overflow indication trigger B1 activation when the last SCG split bearer release
    [Tags]    TC106
    [Documentation]
    ...    precondition:
    ...    CB007332 enabled and CB007123 enbaled for cell-1 :
    ...    NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased and
    ...    NRDCPR-0:bufTrigForB1Nr=${EMPTY}, NRDCDPR-0:bufTrigForB1Nr=enabled
    ...    LTE4531 enabled: LNBTS:actMultiSCGSplit=true
    ...    and there are 3 carrierFreqNrCell {Fnr1, Fnr2, Fnr3} for NRDCDPR
    ...    Case steps:
    ...    Step1: UE-11 ICS to Cell-1 without endc eligble bearer and no B1 activation immediately
    ...    step2: add first endc eligble bearer with QCI-5
    ...    check: UL buffer overflow and B1 activated with Fnr1, Fnr2, Fnr3
    ...    step3: add second endc eligble bearer with QCI-7
    ...    Step4: report valid B1 and start DL traffic for endc bearer
    ...    check: DL buffer overflow and endc setup successfully
    ...    step5: add third endc eligble bearer with QCI-8
    ...    step6: release one SCG split bearer for QCI-5
    ...    check: UL buffer overflow and no B1 activated
    ...    step7: release the last SCG split bearer for QCI-7
    ...    check: no B1 activated immediately when endc takeback
    ...    step8: UL buffer overflow and B1 activated with Fnr1, Fnr2, Fnr3
    [Setup]    case_setup_with_delta_commission    ${delta_for_case6}
    UE attach to cell and check no B1 activation    ue_id=11    cell_id=1
    Add specific QCIx for UE and no B1 configured    ue_id=11    qci=5    drb_check=${add_DRB_5}
    #################################add the following step for EDA of 04192369
    Release specific bearer for UE    ue_id=11    qci=5    drb_rel=${del_DRB_5}
    Start Traffic On Normal Bearer    ue_id=11
    Add specific QCIx for UE and no B1 configured    ue_id=11    qci=5    drb_check=${add_DRB_6}
    #################################
    Add specific QCIx for UE and no B1 configured    ue_id=11    qci=7    drb_check=${add_DRB_7}
    B1 activation after Buffer overflow indication    ue_id=11    qci=5    dir=ul
    Check DL buffer based ENDC setup successfully    ue_id=11    qci=7
    Add specific QCIx for UE    ue_id=11    qci=8    drb_check=${add_DRB_8}    #add endc bearer after endc
    Release specific bearer for UE    ue_id=11    qci=5    drb_rel=${del_DRB_6}
    No B1 activation after start traffic    ue_id=11    qci=8    dir=ul    B1_active=${B1_reactivation}
    Release specific bearer and check ENDC takeback without B1 reactivation    ue_id=11    qci=7
    B1 activation after Buffer overflow indication    ue_id=11    qci=8    dir=ul    B1_active=${B1_reactivation}
    [Teardown]    case teardown and recover env    ${Case6_recover_env}

CB007123-SR-B-B2_ET_02_01_buffer overflow indication trigger B1 activation when release last EN-DC restricted VOLTE bearer
    [Tags]    TC202
    [Documentation]
    ...    precondition:
    ...    CB007332 enabled and CB007123 enbaled for cell-1 :
    ...    NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased and
    ...    NRDCDPR-0:bufTrigForB1Nr=${EMPTY}, NRDCDPR-0:bufTrigForB1Nr=enabled
    ...    LNBTS-1:actVoLteNoEnDc=QCI65/66 and all QCI1 calls (enable LTE5388)
    ...    and there are 3 carrierFreqNrCell {Fnr1, Fnr2, Fnr3} for NRDCDPR
    ...    Case steps:
    ...    Step1: ue-11 ICS to Cell-1 without endc eligble bearer and no B1 activation immediately
    ...    step2: add EN-DC restricted VOLTE bearer with QCI-65
    ...    step3: add first endc bearer with QCI-8 and start traffic for UL
    ...    check: no B1 configured due to exist EN-DC restricted VOLTE bearer
    ...    Step4: add second EN-DC restricted VOLTE bearer with QCI-66
    ...    Step5: add third EN-DC restricted VOLTE bearer with QCI-1
    ...    step6: release EN-DC restricted VOLTE bearer with QCI-65 and start DL traffic for QCI-8 bearer
    ...    check: no B1 activated due to exist EN-DC restricted VOLTE bearer
    ...    step7: release EN-DC restricted VOLTE bearer with QCI-1 and start DL traffic for QCI-8 bearer
    ...    check: no B1 activated due to exist EN-DC restricted VOLTE bearer
    ...    step8: release EN-DC restricted VOLTE bearer with QCI-66 and start DL traffic for QCI-8 bearer
    ...    check: b1 activated with Fnr1, Fnr2, Fnr3 due to no EN-DC restricted VOLTE bearer
    ...    Step9: ue-1 ICS to Cell-1 with endc eligble bearer and no B1 activation immediately
    ...    Step10: start DL traffic for B1 activation and report valid B1 report, then start UL traffic for ENDC establishment successfully
    ...    Step11: add EN-DC restricted VOLTE bearer with QCI-1
    ...    check: endc takeback and no B1 configured
    ...    Step12: release EN-DC restricted VOLTE bearer with QCI-1 and start DL traffic for QCI-8 bearer
    ...    check: b1 activated with Fnr1, Fnr2, Fnr3 due to no EN-DC restricted VOLTE bearer
    [Setup]    case_setup_with_delta_commission    ${delta_for_case202}
    UE11 ICS without endc bearer and no B1 activation when add endc bearer due to EN-DC restricted VOLTE bearer exist
    B1 activation with buffer overflow when the last EN-DC restricted VOLTE bearer released
    UE1 ICS with endc bearer and ENDC setup successfully
    Check ENDC takeback after add EN-DC restricted VOLTE bearer    ue_id=1    qci=1
    B1 activation with buffer overflow when the last EN-DC restricted VOLTE bearer released after ENDC takeback
    [Teardown]    case teardown and recover env    ${Case202_recover_env}

CB007123-SR-B-B3_ET_04_01_B1-NR activation not postponed for B1 based redirection interwork with CB007334 and CB007266
    [Tags]    TC304
    [Documentation]
    ...    precondition:
    ...    CB007332 enabled and CB007123 enbaled for cell-1 :
    ...    NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased and
    ...    NRDCDPR-0:bufTrigForB1Nr=enabled
    ...    CB007334 enabled and CB007226 enabled
    ...    Case steps:
    ...    Step1: ue-1 ICS to Cell-1 with endc eligble bearer and B1 activation for DL traffic
    ...    step2: report B1 for 4 times, then fnr2-PCI2 add to ANR ToBeVerified list
    ...    Step3: ue-2 ICS to Cell-1 with endc eligble bearer and B1 activation for DL traffic
    ...    Step4: ue-2 report B1 report for fnr2-PCI2
    ...    Step5: ue-2 report B1 for gnb cell-3 and start traffic for endc setup successfully
    ...    Step6: wait LTE inactivity timer expired and ENDC takeback by 5G inactivity
    ...    check: endc takeback and no B1 activated , ANR procedure start(RSC and CGI), when ANR complete, B1 configured for NR redirection
    ...    Step7: report valid B1 for redirection
    ...    check: UE release with Nr redirection Info
    [Setup]    case_setup_with_delta_commission    ${delta_for_case304}
    UE1 ICS and report serveal B1 reports to make fnr2-PCI2 ToBeVerified
    set RSC CGI auto report with CGI1    ue_id=2
    UE attach to cell and check no B1 activation    ue_id=2    cell_id=1    eutra_capa=${ue_eutra_capability_ANR}
    B1 activation after Buffer overflow indication    ue_id=2    qci=8    dir=dl
    Report valid B1 report for special NRFCN    ue_id=2    narfcn=${fnr2}    pci=2
    Check UL buffer based ENDC setup successfully    ue_id=2
    ENDC takeback after LTE inactivity timer expired and perform ANR    ue_id=2
    UE release with NR redirection Info    ue_id=2
    Object Should Exist    ${LNRELGNBCELL_255}
    [Teardown]    case teardown and recover env    ${Case304_recover_env}

CB007123-SR-B-B3_ET_05_01_buffer overflow indication trigger B1 activation after endcNrDropThresTimer expiry interwork with CB006613
    [Tags]    TC305
    [Documentation]
    ...    precondition:
    ...    CB007332 enabled and CB007123 enbaled for cell-1 :
    ...    NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased and
    ...    NRDCPR-0:bufTrigForB1Nr=enabled
    ...    CB006613 enabled
    ...    Case steps:
    ...    Step1: ue-1 ICS to Cell-1 with endc eligble bearer and B1 activation for DL traffic
    ...    Step2: ue-1 report valid B1 report and start traffic for ENDC estalishment
    ...    Step3: ue-1 endc takeback due to ue lost before endcNrDropWaitTimer expired
    ...    Step4: start traffic before endcNrDropThresTimer expired
    ...    check: ue-1 activated B1 for two layers, due to Fnr3 in blacklist
    ...    Step5: wait endcNrDropThresTimer, B1 reactivation for third layer (Fnr3)
    ...    Step6: ue-2 ICS to Cell-1 with endc eligble bearer and B1 activation for DL traffic
    ...    Step7: ue-2 report valid B1 report and start traffic for ENDC estalishment
    ...    Step8: ue-2 endc takeback due to ue lost before endcNrDropWaitTimer expired
    ...    Step9: start traffic after endcNrDropThresTimer expired
    ...    check: ue-2 activated B1 for all layers, due to Fnr3 not in blacklist after endcNrDropThresTimer expired
    [Setup]    case_setup_with_delta_commission    ${delta_for_case305}
    UE ICS and ENDC takeback due to UE lost after ENDC setup before endcNrDropWaitTimer expired    ue_id=1
    B1 activation after Buffer overflow indication    ue_id=1    qci=8    dir=dl    B1_active=${B1_reactivation_for_two_layer}
    B1 reactivation after endcNrDropThresTimer expired    ue_id=1    B1_active=${B1_reactive_for_third_layer}
    UE ICS and ENDC takeback due to UE lost after ENDC setup before endcNrDropWaitTimer expired    ue_id=2
    B1 reactivation after endcNrDropThresTimer expired and start traffic    ue_id=2    B1_active=${B1_reactivation}
    [Teardown]    case teardown and recover env    ${Case305_recover_env}

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
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 65, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 66, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    FOR    ${ue_id}     IN RANGE    11    21
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_2
    END
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

UE HO to cell-1 and no B1 activation
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${HO_successful_to_lte1})
    ...    alias=UE_Ho    overall_timeout=20
    Expect message will not occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime})
    ...    alias=B1_activation    overall_timeout=20
    Execute Uex Command    ue_ho id=${ue_id} cell=${cell_id} enb=1
    Flow Not Occurred For message    alias=B1_activation
    Flow Occurred As Expected    alias=UE_Ho

UE reestablish on serving cell and no B1 activation
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReestablishmentRequest
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReestablishment
    ...    alias=UE_reestablish    overall_timeout=20
    Expect message will not occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime})
    ...    alias=B1_activation    overall_timeout=20
    Execute Uex Command    ue_rrc_reestablish id=${ue_id} enb=1 cell=${cell_id}
    Flow Not Occurred For message    alias=B1_activation
    Flow Occurred As Expected    alias=UE_reestablish

Add specific QCIx for UE
    [Arguments]    ${ue_id}=1    ${qci}=8    ${drb_check}=${add_DRB_5}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${drb_check})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=Bearer_addition    overall_timeout=20
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=Bearer_addition

B1 activation after Buffer overflow indication
    [Arguments]    ${ue_id}=1    ${qci}=8    ${dir}=dl    ${B1_active}=${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime}    ${trf_id}=1
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_active})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=B1_active    overall_timeout=20
    Execute Uex Command    trf_data_start trf_id=${trf_id} dir=${dir} Mbps=150 ue=${ue_id} protocol=udp qci=${qci} duration=5 duration_unit=seconds
    Flow Occurred As Expected    alias=B1_active

No B1 activation after start traffic
    [Arguments]    ${ue_id}=1    ${qci}=8    ${dir}=dl    ${B1_active}=${B1_reactivation}
    Expect message will not occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_active})
    ...    alias=B1_active    overall_timeout=20
    Execute Uex Command    trf_data_start trf_id=1 dir=${dir} Mbps=150 ue=${ue_id} protocol=udp qci=${qci} duration=5 duration_unit=seconds
    Flow Not Occurred For message    alias=B1_active

Add specific QCIx for UE and no B1 configured
    [Arguments]    ${ue_id}=1    ${qci}=8    ${drb_check}=${add_DRB_5}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${drb_check})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=Bearer_addition    overall_timeout=20
    Expect message will not occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime})
    ...    alias=B1_active    overall_timeout=20
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=Bearer_addition
    Flow Not Occurred For message    alias=B1_active

Check DL buffer based ENDC setup successfully
    [Arguments]    ${ue_id}=1    ${qci}=6
    Expect message flow
    ...    gNB:X2AP_SgNBAdditionRequest
    ...    gNB:X2AP_SgNBAdditionRequestAcknowledge (${two_SCG_bearer})
    ...    gNB:X2AP_SgNBReconfigurationComplete
    ...    gNB:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (17,18))
    ...    alias=ENDC_setup    overall_timeout=20
    Report valid B1 report for special NRFCN    ue_id=${ue_id}    narfcn=${fnr3}    pci=3
    Execute Uex Command    trf_data_start trf_id=1 dir=dl Mbps=150 ue=${ue_id} protocol=udp qci=${qci} duration=5 duration_unit=seconds
    Flow Occurred As Expected    alias=ENDC_setup

Release specific bearer for UE
    [Arguments]    ${ue_id}=1    ${qci}=8    ${drb_rel}=${del_DRB_5}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${drb_rel})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=Bearer_delete    overall_timeout=20
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=Bearer_delete

Release specific bearer and check ENDC takeback without B1 reactivation
    [Arguments]    ${ue_id}=1    ${qci}=8
    Expect message will not occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_reactivation})
    ...    alias=B1_activation    overall_timeout=20
    Expect message flow
    ...    gNB:X2AP_SgNBReleaseRequest
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${del_DRB_6})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=endc_takeback    overall_timeout=20
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=endc_takeback
    Flow Not Occurred For message    alias=B1_activation

Add specific GBR QCIx for UE
    [Arguments]    ${ue_id}    ${qci}    ${drb_check}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${drb_check})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=Bearer_addition    overall_timeout=20
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci} mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    Flow Occurred As Expected    alias=Bearer_addition

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

Check ENDC takeback after add EN-DC restricted VOLTE bearer
    [Arguments]    ${ue_id}    ${qci}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${add_DRB_5})
    ...    gNB:X2AP_SgNBReleaseRequest
    ...    gNB:X2AP_SgNBReleaseRequestAcknowledge
    ...    gNB:X2AP_SNStatusTransfer
    ...    alias=ENDC_takeback    overall_timeout=20
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci} mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    Flow Occurred As Expected    alias=ENDC_takeback

UE11 ICS without endc bearer and no B1 activation when add endc bearer due to EN-DC restricted VOLTE bearer exist
    UE attach to cell and check no B1 activation    ue_id=11    cell_id=1    #no B1 activation
    Add specific GBR QCIx for UE    ue_id=11    qci=65     drb_check=${add_DRB_5}
    Add specific QCIx for UE and no B1 configured    ue_id=11    qci=8     drb_check=${add_DRB_6}    #add first endc eligible bearer
    No B1 activation after start traffic    ue_id=11    qci=8    dir=ul    B1_active=${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime}
    Add specific GBR QCIx for UE    ue_id=11    qci=66     drb_check=${add_DRB_7}
    Add specific GBR QCIx for UE    ue_id=11    qci=1     drb_check=${add_DRB_8}

B1 activation with buffer overflow when the last EN-DC restricted VOLTE bearer released
    Release specific bearer for UE    ue_id=11    qci=65    drb_rel=${del_DRB_5}
    No B1 activation after start traffic    ue_id=11    qci=8    dir=ul    B1_active=${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime}
    Release specific bearer for UE    ue_id=11    qci=1    drb_rel=${del_DRB_8}
    No B1 activation after start traffic    ue_id=11    qci=8    dir=ul    B1_active=${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime}
    Release specific bearer for UE    ue_id=11    qci=66    drb_rel=${del_DRB_7}
    B1 activation after Buffer overflow indication    ue_id=11    qci=8    dir=ul    B1_active=${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime}

UE1 ICS with endc bearer and ENDC setup successfully
    UE attach to cell and check no B1 activation    ue_id=1    cell_id=1
    B1 activation after Buffer overflow indication    ue_id=1    qci=8    dir=dl
    Check UL buffer based ENDC setup successfully    ue_id=1    qci=8

B1 activation with buffer overflow when the last EN-DC restricted VOLTE bearer released after ENDC takeback
    Execute Uex Command    trf_data_stop trf_id=1 ue=1
    Release specific bearer for UE    ue_id=1    qci=1    drb_rel=${del_DRB_5}
    B1 activation after Buffer overflow indication    ue_id=1    qci=8    dir=ul    B1_active=${B1_reactivation}    trf_id=2

set RSC CGI auto report with CGI1
    [Arguments]    ${ue_id}=1    ${nrarfcn}=650048    ${pci}=2
    ${cmd}    catenate
        ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=${nrarfcn} nrsrp=79 nrsrq=79 nsinr=31 strongest=nr5g cgi=262:03|${nci-115970} tac=33 freq_band_list=77
    Run Uex Command    ${cmd}

UE1 ICS and report serveal B1 reports to make fnr2-PCI2 ToBeVerified
    UE attach to cell and check no B1 activation    ue_id=1    cell_id=1    eutra_capa=${ue_eutra_capability_ANR}
    B1 activation after Buffer overflow indication    ue_id=1    qci=8    dir=dl
    FOR    ${temp}    IN RANGE    1    5
    Report valid B1 report for special NRFCN    ue_id=1    narfcn=${fnr2}    pci=2
    END

ENDC takeback after LTE inactivity timer expired and perform ANR
    [Arguments]    ${ue_id}
    Expect message flow
    ...    gNB:X2AP_SgNBReleaseRequired
    ...    gNB:X2AP_SgNBReleaseConfirm
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration
    ...    gNB:X2AP_SNStatusTransfer
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${config_RSC})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${config_CGI})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_reactivation})
    ...    alias=ENDC_takeback_and_ANR    overall_timeout=60
    sleep    50s    #wait enough timer for LTE inactivitytimer expired
    Execute Egate Command    enb_ue_dc_release by=gnb cause=RN_user_inactivity ue=${ue_id}    UEContextRelease
    Flow Occurred As Expected    alias=ENDC_takeback_and_ANR

UE release with NR redirection Info
    [Arguments]    ${ue_id}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionRelease (${NR_redirection})
    ...    alias=redirection    overall_timeout=20
    Report valid B1 report for special NRFCN    ue_id=${ue_id}    narfcn=${fnr3}    pci=3    #for NR redirection
    Flow Occurred As Expected    alias=redirection

ENDC takeback due to UE lost
    [Arguments]    ${ue_id}
    Expect message flow
    ...    gNB:X2AP_SgNBReleaseRequired
    ...    gNB:X2AP_SgNBReleaseConfirm
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration
    ...    gNB:X2AP_SNStatusTransfer
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=ENDC_takeback    overall_timeout=20
    Execute Egate Command    enb_ue_dc_release by=gnb cause=RN_radio_connection_with_UE_lost ue=${ue_id}    UEContextRelease
    Flow Occurred As Expected    alias=ENDC_takeback

B1 reactivation after endcNrDropThresTimer expired
    [Arguments]    ${ue_id}=1    ${B1_active}=${B1_reactive_for_third_layer}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_active})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=B1_reactive    overall_timeout=20
    sleep    10s    #wait endcNrDropThresTimer expired
    Flow Occurred As Expected    alias=B1_reactive

B1 reactivation after endcNrDropThresTimer expired and start traffic
    [Arguments]    ${ue_id}=1    ${B1_active}=${B1_reactive_for_third_layer}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_active})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=B1_reactive    overall_timeout=20
    sleep    10s    #wait endcNrDropThresTimer expired
    Execute Uex Command    trf_data_start trf_id=1 dir=dl Mbps=150 ue=${ue_id} protocol=udp qci=8 duration=5 duration_unit=seconds
    Flow Occurred As Expected    alias=B1_reactive
    Execute Uex Command    trf_data_stop trf_id=1 ue=${ue_id}

UE ICS and ENDC takeback due to UE lost after ENDC setup before endcNrDropWaitTimer expired
    [Arguments]    ${ue_id}=1
    UE attach to cell and check no B1 activation    ue_id=${ue_id}    cell_id=1    #no B1 activation
    B1 activation after Buffer overflow indication    ue_id=${ue_id}    qci=8    dir=dl
    Check UL buffer based ENDC setup successfully    ue_id=${ue_id}    qci=8
    ENDC takeback due to UE lost    ue_id=${ue_id}

Start Traffic On Normal Bearer
    [Arguments]    ${ue_id}=1
    Execute Uex Command    trf_data_start trf_id=1 dir=dl Mbps=150 ue=${ue_id} protocol=udp qci=6 duration=5 duration_unit=seconds

