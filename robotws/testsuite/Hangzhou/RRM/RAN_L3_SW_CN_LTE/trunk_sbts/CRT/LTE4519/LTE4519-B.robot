*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_2MAPO_2CUS    release-SBTS19A
...               team-SG4    owner-zhiguo.li
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAmbrModCaTrigger=true
...    LNBTS-1:actAdvScellMeas=false
...    LNBTS-1:actFlexScellSelect=true
...    LNBTS-1:sCellActivationMethod=blind
...    LNBTS-1:sCellDeactivationTimereNB=infinity
...    LNBTS-1:multScellReleaseTimer=0
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=0
...    LNCEL-1:maxNumScells=4
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=8140
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=26140
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=8340
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=26340
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=8790
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=26790
...    LNCEL-4/LNCEL_FDD-0:earfcnDL=4900
...    LNCEL-4/LNCEL_FDD-0:earfcnUL=22900
...    LNCEL-1/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-2/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-2/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-3/LNCEL_FDD-0:dlChBw=5 MHz
...    LNCEL-3/LNCEL_FDD-0:ulChBw=5 MHz
...    LNCEL-4/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-4/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-4/CAREL-1:lnBtsId=2
...    LNCEL-4/CAREL-1:lcrId=51
...    LNCEL-4/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-3:lnBtsId=2
...    LNCEL-1/CAREL-3:lcrId=51
...    LNCEL-1/CAREL-3:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-4:lnBtsId=2
...    LNCEL-1/CAREL-4:lcrId=52
...    LNCEL-1/CAREL-4:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-5:lnBtsId=2
...    LNCEL-1/CAREL-5:lcrId=53
...    LNCEL-1/CAREL-5:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAPR-1:earfcnDL=8340
...    LNCEL-1/CAPR-1:sFreqPrio=1
...    LNCEL-1/CAPR-2:earfcnDL=8790
...    LNCEL-1/CAPR-2:sFreqPrio=500
...    LNCEL-1/CAPR-3:earfcnDL=39750
...    LNCEL-1/CAPR-3:sFreqPrio=1000
...    LNCEL-1/CAPR-4:earfcnDL=39948
...    LNCEL-1/CAPR-4:sFreqPrio=5000
...    LNCEL-1/CAPR-5:earfcnDL=40146
...    LNCEL-1/CAPR-5:sFreqPrio=9000
...    LNCEL-2/CAREL-1:lnBtsId=1
...    LNCEL-2/CAREL-1:lcrId=1
...    LNCEL-2/CAREL-2:lnBtsId=1
...    LNCEL-2/CAREL-2:lcrId=3
...    LNCEL-2/CAREL-3:lnBtsId=2
...    LNCEL-2/CAREL-3:lcrId=51
...    LNCEL-2/CAREL-3:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-2/CAREL-4:lnBtsId=2
...    LNCEL-2/CAREL-4:lcrId=52
...    LNCEL-2/CAREL-4:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-2/CAREL-5:lnBtsId=2
...    LNCEL-2/CAREL-5:lcrId=53
...    LNCEL-2/CAREL-5:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-2/CAPR-1:earfcnDL=8140
...    LNCEL-2/CAPR-1:sFreqPrio=1
...    LNCEL-2/CAPR-2:earfcnDL=8790
...    LNCEL-2/CAPR-2:sFreqPrio=100
...    LNCEL-2/CAPR-3:earfcnDL=39750
...    LNCEL-2/CAPR-3:sFreqPrio=500
...    LNCEL-2/CAPR-4:earfcnDL=39948
...    LNCEL-2/CAPR-4:sFreqPrio=1000
...    LNCEL-2/CAPR-5:earfcnDL=40146
...    LNCEL-2/CAPR-5:sFreqPrio=5000
...    LNBTS-1/CADPR-0:sFreqPrio=10000
...    LNCEL-1/LNCEL_FDD-0:maxNrSymPdcch=2
...    LNCEL-2/LNCEL_FDD-0:maxNrSymPdcch=2
...    LNCEL-3/LNCEL_FDD-0:maxNrSymPdcch=2
...    LNCEL-4/LNCEL_FDD-0:maxNrSymPdcch=2
...    LNBTS-1:actInterEnbDLCAggr=true
...    LNBTS-1:caClusterId=0
...    LNBTS-1:caClusterMemberId=1
...    LNBTS-1/CAGENB-0:actEnhCaBandCombSel=off
...    LNBTS-1/CAGENB-0:nlcvDeltaX2C2=2
...    LNBTS-1/CAGENB-0:caClusterEnbList:lnBtsId=2
...    LNBTS-1/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS-1:actULCAggr=false
...    LNBTS-1:actInterEnbULCAggr=false
...    LNBTS-1:actCompChecks=false
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...    LNCEL-3/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL-3/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...    LNCEL-4/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL-4/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...    LNCEL-1:actModulationSchemeDl=256QAM
...    LNCEL-2:actModulationSchemeDl=256QAM
...    LNCEL-3:actModulationSchemeDl=256QAM
...    LNCEL-4:actModulationSchemeDl=256QAM
...    LNBTS-1:caSchedFairFact=10
...    LNCEL:dlCaCqiWindow=50
...    LNBTS-1/LNADJ-255:cPlaneIpAddrCtrl=oamControlled
...    LNBTS-1/LNADJ-255:cPlaneIpAddr=10.0.1.4
...    LNBTS-1/LNADJ-255:adjEnbId=2
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-1:ecgiLcrId=2
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-2:ecgiLcrId=3
...    LNCEL-1/LNREL-3:ecgiAdjEnbId=2
...    LNCEL-1/LNREL-3:ecgiLcrId=1
...    LNCEL-1/LNREL-4:ecgiAdjEnbId=2
...    LNCEL-1/LNREL-4:ecgiLcrId=2
...    LNCEL-1/LNREL-5:ecgiAdjEnbId=2
...    LNCEL-1/LNREL-5:ecgiLcrId=3
...    LNCEL-2/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-1:ecgiLcrId=1
...    LNCEL-2/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-2:ecgiLcrId=3
...    LNCEL-2/LNREL-3:ecgiAdjEnbId=2
...    LNCEL-2/LNREL-3:ecgiLcrId=1
...    LNCEL-2/LNREL-4:ecgiAdjEnbId=2
...    LNCEL-2/LNREL-4:ecgiLcrId=2
...    LNCEL-2/LNREL-5:ecgiAdjEnbId=2
...    LNCEL-2/LNREL-5:ecgiLcrId=3
...    LNCEL-4/LNREL-1:ecgiAdjEnbId=2
...    LNCEL-4/LNREL-1:ecgiLcrId=1
...    @{Tput}
...    @{fix_thoughtput}

@{fix_thoughtput}
...    LNCEL:cqiAperEnable=false
...    LNCEL/LNCEL_FDD-0:actUciOnlyGrants=false

@{PARAMS_IN_SCF_ENB2}
...    LNBTS-2:actDLCAggr=true
...    LNBTS-2:actAmbrModCaTrigger=true
...    LNBTS-2:actAdvScellMeas=false
...    LNBTS-2:actFlexScellSelect=true
...    LNBTS-2:sCellActivationMethod=blind
...    LNBTS-2:sCellDeactivationTimereNB=infinity
...    LNBTS-2:multScellReleaseTimer=0
...    LNBTS-2/LNBTS_TDD-0:numTxWithHighNonGbr=0
...    LNCEL-1/LNCEL_TDD-0:earfcn=39750
...    LNCEL-2/LNCEL_TDD-0:earfcn=39948
...    LNCEL-3/LNCEL_TDD-0:earfcn=40146
...    LNCEL-1/LNCEL_TDD-0:chBw=20 MHz
...    LNCEL-2/LNCEL_TDD-0:chBw=20 MHz
...    LNCEL-3/LNCEL_TDD-0:chBw=20 MHz
...    LNCEL-1/LNCEL_TDD-0:tddFrameConf=2
...    LNCEL-2/LNCEL_TDD-0:tddFrameConf=2
...    LNCEL-3/LNCEL_TDD-0:tddFrameConf=2
...    LNCEL-1/LNCEL_TDD-0:maxNrSymPdcch=2
...    LNCEL-2/LNCEL_TDD-0:maxNrSymPdcch=2
...    LNCEL-3/LNCEL_TDD-0:maxNrSymPdcch=2
...    LNBTS-2:actInterEnbDLCAggr=true
...    LNBTS-2:caClusterId=0
...    LNBTS-2:caClusterMemberId=2
...    LNBTS-2/CAGENB-0:actEnhCaBandCombSel=off
...    LNBTS-2/CAGENB-0:nlcvDeltaX2C2=2
...    LNBTS-2/CAGENB-0:caClusterEnbList:lnBtsId=1
...    LNBTS-2/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS-2/CAGENB-0:maxDlCaConfigForUlCa=max_3CC_DL_CA
...    LNBTS-2:actULCAggr=false
...    LNBTS-2:actInterEnbULCAggr=false
...    LNBTS-2:actCompChecks=true
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNCEL-1/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...    LNCEL-1/LNCEL_TDD-0:activatedMimoTM=TM9
...    LNCEL-1/LNCEL_TDD-0:fourLayerMimoAvSpectralEff=1
...    LNCEL-2/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...    LNCEL-2/LNCEL_TDD-0:activatedMimoTM=TM9
...    LNCEL-2/LNCEL_TDD-0:fourLayerMimoAvSpectralEff=1
...    LNCEL-3/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...    LNCEL-3/LNCEL_TDD-0:activatedMimoTM=TM9
...    LNCEL-3/LNCEL_TDD-0:fourLayerMimoAvSpectralEff=1
...    LNCEL-1:actModulationSchemeDl=256QAM
...    LNCEL-2:actModulationSchemeDl=256QAM
...    LNCEL-3:actModulationSchemeDl=256QAM
...    LNBTS-2:caSchedFairFact=10
...    LNCEL/LNCEL_TDD-0:csiRsConfigInfo:csiRsPwrOffset=0
...    LNCEL/LNCEL_TDD-0:csiRsConfigInfo:csiRsResourceConf=rsc0
...    LNCEL/LNCEL_TDD-0:csiRsConfigInfo:csiRsSubfrConf=14
...    LNCEL/LNCEL_TDD-0:csiRsConfigInfo:numOfCsiRsAntennaPorts=4
...    LNBTS-2/LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNBTS-2/LNADJ-1:cPlaneIpAddr=10.0.1.2
...    LNBTS-2/LNADJ-1:adjEnbId=1
...    LNBTS-2/LNADJ-1/LNADJL-1:ecgiLcrId=1
...    LNBTS-2/LNADJ-1/LNADJL-1:fDlEarfcn=8140
...    LNBTS-2/LNADJ-1/LNADJL-1:phyCellId=1
...    LNBTS-2/LNADJ-1/LNADJL-1:tac=33
...    LNBTS-2/LNADJ-1/LNADJL-2:ecgiLcrId=2
...    LNBTS-2/LNADJ-1/LNADJL-2:fDlEarfcn=8340
...    LNBTS-2/LNADJ-1/LNADJL-2:phyCellId=2
...    LNBTS-2/LNADJ-1/LNADJL-2:tac=33
...    LNBTS-2/LNADJ-1/LNADJL-3:ecgiLcrId=3
...    LNBTS-2/LNADJ-1/LNADJL-3:fDlEarfcn=8790
...    LNBTS-2/LNADJ-1/LNADJL-3:phyCellId=3
...    LNBTS-2/LNADJ-1/LNADJL-3:tac=33
...    LNBTS-2/LNADJ-1/LNADJL-4:ecgiLcrId=4
...    LNBTS-2/LNADJ-1/LNADJL-4:fDlEarfcn=4900
...    LNBTS-2/LNADJ-1/LNADJL-4:phyCellId=4
...    LNBTS-2/LNADJ-1/LNADJL-4:tac=33
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:lcrId=1
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:lcrId=2
...    LNCEL-1/CAREL-3:lnBtsId=1
...    LNCEL-1/CAREL-3:lcrId=3
...    LNCEL-1/CAREL-4:lnBtsId=1
...    LNCEL-1/CAREL-4:lcrId=4
...    LNCEL-2/CAREL-1:lnBtsId=1
...    LNCEL-2/CAREL-1:lcrId=1
...    LNCEL-2/CAREL-2:lnBtsId=1
...    LNCEL-2/CAREL-2:lcrId=2
...    LNCEL-2/CAREL-3:lnBtsId=1
...    LNCEL-2/CAREL-3:lcrId=3
...    LNCEL-3/CAREL-1:lnBtsId=1
...    LNCEL-3/CAREL-1:lcrId=1
...    LNCEL-3/CAREL-2:lnBtsId=1
...    LNCEL-3/CAREL-2:lcrId=2
...    LNCEL-1/CAPR-1:earfcnDL=4900
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-1:ecgiLcrId=1
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-2:ecgiLcrId=2
...    LNCEL-1/LNREL-3:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-3:ecgiLcrId=3
...    LNCEL-1/LNREL-4:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-4:ecgiLcrId=4
...    LNCEL-2/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-1:ecgiLcrId=1
...    LNCEL-2/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-2:ecgiLcrId=2
...    LNCEL-2/LNREL-3:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-3:ecgiLcrId=3
...    LNCEL-3/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-3/LNREL-1:ecgiLcrId=1
...    LNCEL-3/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-3/LNREL-2:ecgiLcrId=2
...    LNBTS-2:dlCaPreferred=DLonly
...    LNBTS-2:actFlexCaMgmt=false
...    LNBTS-2:actIscaHarqEnh=false
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:actFlowCtrlEnh=false
...    LNCEL:actScellConfigForHiDemand=false
...    LNCEL:scellFastSchedulingSelect=normal
...    LNCEL:ulCaMinPcellSinr=0
...    LNCEL:ulCaMinPcellSinrQci1=0
...    LNCEL:dlCaMinPcellCqiQci1=0
...    LNCEL:dlCaMinPcellCqi=0
...    LNCEL/LNCEL_TDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_TDD-0:maxNumActUE=300
...    LNCEL/LNCEL_TDD-0/MPUCCH_TDD-0:cellSrPeriod=80ms
...    LNCEL/LNCEL_TDD-0/MPUCCH_TDD-0:nPucchF3Prbs=0
...    LNCEL/LNCEL_TDD-0/MPUCCH_TDD-0:n1PucchAn=36
...    MNL-1/MNLENT-1/SYNC-1:manualFrameTimingAdjustment=0
...    @{Tput}
...    @{fix_thoughtput_enb2}

@{fix_thoughtput_enb2}
...    LNCEL:cqiAperEnable=false

@{Tput}
...    LNCEL:actLdPdcch=true
...    LNCEL:adaptPdcchDwellTime=0
...    LNCEL:mbrSelector=ueCapability
...    LNCEL:actDl256QamChQualEst=false
...    LNCEL:dl256QamDeactChQualThr=13
...    LNCEL:dl256QamReactChQualThr=22
...    LNCEL:iniDl256QamChQualEst=1s
...    LNCEL:perDl256QamChQualEst=60s
...    LNCEL:actDlPwBackoff=true
...    LNCEL:dlPwBackoffStructure:dlPwBackoffApp=ALL
...    LNCEL:dlPwBackoffStructure:dlPwBackoffThreshold=50
...    LNCEL:dlPwBackoffStructure:maxDlPwBackoffValue1=0
...    LNCEL:dlPwBackoffStructure:maxDlPwBackoffValue2=1
...    LNCEL:dlPwBackoffStructure:usageOfMaxDlPwBackoffValue2=QAM256r1r2r3r4
...    LNCEL:dlTargetBler=100
...    LNBTS:pdcpProf2:snSize=15bit
...    LNBTS:rlcProf7:tReord=15ms

${3CC_SUPPORTED_BAND_25A_26A_41A}    25:a:a-2|25:a:a-2+26::a-2|25:a:a-2+26::a-2+41::a-4
${4CC_SUPPORTED_BAND_25A_25A_26A_41A}    25:a:a-2|25:a:a-2+25::a-2|25:a:a-2+25::a-2+26::a-2|25:a:a-2+25::a-2+26::a-2+41::a-4
${4CC_SUPPORTED_BAND_25A_26A_41C}    25:a:a-2|25:a:a-2+26::a-2|25:a:a-2+26::a-2+41::a-4|25:a:a-2+26::a-2+41::c-4
${5CC_SUPPORTED_BAND_25A_25A_41D}    25:a:a-2|25:a:a-2+25::a-2|25:a:a-2+25::a-2+41::a-4|25:a:a-2+25::a-2+41::c-4|25:a:a-2+25::a-2+41::d-4

${DL_TPUT_25A_26A_41A_3CC}    250
${DL_TPUT_25A_25A_26A_41A_4CC}    395
${DL_TPUT_25A_26A_41C_4CC}    325
${DL_TPUT_25A_25A_41D_5CC}    510

*** Test Cases ***
LTE4519-B-c-25A_26A_41A_3CC
    [Tags]
    UE2 Attach To Cell1 And Configure 3CC With CarrierFreq Pcell-Band25 Scell-Band26_Band41
    Start And Verify Traffic Then Create 2_sCellIndex with CarrierFreq Scell-Band26_Band41
    UE detach    ueid=2

LTE4519-B-d-25A_25A_26A_41A_4CC
    [Tags]
    UE3 Attach To Cell1 And Configure 4CC With CarrierFreq_8140_8340_8790_39750
    Start And Verify Traffic Then Create 3_sCellIndex with CarrierFreq_8340_8790_39750
    UE detach    ueid=3

LTE4519-B-d-25A_26A_41C_4CC
    [Tags]
    UE4 Attach To Cell1 And Configure 4CC With CarrierFreq_8140_8790_39750_39948
    Start And Verify Traffic Then Create 3_sCellIndex with CarrierFreq_8790_39750_39948
    UE detach    ueid=4

LTE4519-B-e-25A_25A_41D_5CC
    [Tags]
    UE5 Attach To Cell1 And Configure 5CC With CarrierFreq_8140_8340_39750_39948_40146
    Start And Verify Traffic Then Create 4_sCellIndex with CarrierFreq_8340_39750_39948_40146
    UE detach    ueid=5

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup 2CUS Env    tl_type=4CELLs_FDD_B2_25_B5_26_B11    tl_type_enb2=3CELLs
    Set ue parameters before ENDC setup
    Create Alias

Set ue parameters before ENDC setup
    execute uex command    ue_param id=1-13 dual_conn=eutra_nr pdcp_sn_extension=18bit
    execute uex command    ue_param id=1-13 nr_supported_bands=7
    execute egate command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    execute egate command    enb_timer T_DC_Overall=5000ms

Create Alias
    FOR    ${ue_id}    IN RANGE    1    8
       Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END
    Create Enb Alias    alias=ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    alias=ENB_2    enb_id=2    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Modify Yaml
    Update Yaml    BASE_STATIONS/1/cus_config/1    sync_source: PPS    ctrl_group: 1    full_rack_group: 1
    Update Yaml    BASE_STATIONS/2/cus_config/1    sync_source: BackplanePPS    ctrl_group: 1    full_rack_group: 1
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 5, pdn: 1}
    ...     - {qci: 6, pdn: 1}
    ...     - {qci: 1, pdn: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31}
    FOR    ${ue_id}     IN RANGE    1    8
        Update Yaml    UEs/UE_sets/${ue_id}    bearer: bearer_set_2    release: '15'    category: '12'    rohc: '16'    dl_256QAM_supported: 'on'
        ...    eia: 'null'    eea: 'null'	
    END

Attach Ue And Configure Scell
    [Arguments]    ${ueid}    ${ca_band_comb}    ${num_scell}=1    ${cellid}=1    ${enbid}=1
    Run Uex Command    turbo_mode_l2    cell=${cellid}    mode=enable
    Execute Uex Command    ue_param id=${ueid} supported_bands=25,26,11,41 ca_supported_bands=${ca_band_comb}
    Execute Uex Command    ue_attach id=${ueid} enb=${enbid} cell=${cellid}

UE detach
    [Arguments]    ${ueid}=1
    Execute Uex Command    ue_detach id=${ueid}

UE2 Attach To Cell1 And Configure 3CC With CarrierFreq Pcell-Band25 Scell-Band26_Band41
    [Arguments]    ${ueid}=2
    ${Scell_addition}    catenate
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq 8140,    # band25
    ...    carrierFreq eq 8790,
    ...    carrierFreq eq 40146,
    ...    carrierFreq eq 39948,
    ...    carrierFreq eq 39750
    ...    )
    ${DL_Scell_addition_Pcell-Band25_Scell-Band26_Band41}    catenate
    ...    ((sCellToAddModList-r10 contains ( (physCellId-r10 eq 3) and (dl-CarrierFreq-r10 eq 8790)))  # band26
    ...    and
    ...    (sCellToAddModList-r10 contains ( (physCellId-r10 eq 51) and (dl-CarrierFreq-r10 eq 39750))))  # band41
    ...    or
    ...    ((sCellToAddModList-r10 contains ( (physCellId-r10 eq 3) and (dl-CarrierFreq-r10 eq 8790)))  # band26
    ...    and
    ...    (sCellToAddModList-r10 contains ( (physCellId-r10 eq 52) and (dl-CarrierFreq-r10 eq 39948))))  # band41
    Expect Message Flow
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration( ${Scell_addition} )
    ...    UE_${ueid}:RRC_RRCConnectionReconfigurationComplete
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration( ${DL_Scell_addition_Pcell-Band25_Scell-Band26_Band41} )
    ...    UE_${ueid}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_${ueid}_attach    overall_timeout=30
    Attach Ue And Configure Scell    ueid=${ueid}    ca_band_comb=${3CC_SUPPORTED_BAND_25A_26A_41A}    num_scell=2    cellid=1
    Flow Occurred As Expected    alias=UE_${ueid}_attach

UE3 Attach To Cell1 And Configure 4CC With CarrierFreq_8140_8340_8790_39750
    [Arguments]    ${ueid}=3
    ${Scell_addition}    catenate
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq 8140,
    ...    carrierFreq eq 8340,
    ...    carrierFreq eq 8790,
    ...    carrierFreq eq 40146,
    ...    carrierFreq eq 39948,
    ...    carrierFreq eq 39750
    ...    )
    ${DL_Scell_addition}    catenate
    ...    ((sCellToAddModList-r10 contains ( (physCellId-r10 eq 2) and (dl-CarrierFreq-r10 eq 8340)))
    ...    and
    ...    (sCellToAddModList-r10 contains ( (physCellId-r10 eq 3) and (dl-CarrierFreq-r10 eq 8790)))
    ...    and
    ...    (sCellToAddModList-r10 contains ( (physCellId-r10 eq 51) and (dl-CarrierFreq-r10 eq 39750))))
    ...    or
    ...    ((sCellToAddModList-r10 contains ( (physCellId-r10 eq 2) and (dl-CarrierFreq-r10 eq 8340)))
    ...    and
    ...    (sCellToAddModList-r10 contains ( (physCellId-r10 eq 3) and (dl-CarrierFreq-r10 eq 8790)))
    ...    and
    ...    (sCellToAddModList-r10 contains ( (physCellId-r10 eq 52) and (dl-CarrierFreq-r10 eq 39948))))
    Expect Message Flow
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration( ${Scell_addition} )
    ...    UE_${ueid}:RRC_RRCConnectionReconfigurationComplete
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration( ${DL_Scell_addition} )
    ...    UE_${ueid}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_${ueid}_attach    overall_timeout=30
    Attach Ue And Configure Scell    ueid=${ueid}    ca_band_comb=${4CC_SUPPORTED_BAND_25A_25A_26A_41A}    num_scell=3    cellid=1
    Flow Occurred As Expected    alias=UE_${ueid}_attach

UE4 Attach To Cell1 And Configure 4CC With CarrierFreq_8140_8790_39750_39948
    [Arguments]    ${ueid}=4
    ${Scell_addition}    catenate
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq 8140,
    ...    carrierFreq eq 8790,
    ...    carrierFreq eq 40146,
    ...    carrierFreq eq 39948,
    ...    carrierFreq eq 39750
    ...    )
    ${DL_Scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 2 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 3 and dl-CarrierFreq-r10 eq 8790),
    ...    sCellIndex-r10 eq 1 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 51 and dl-CarrierFreq-r10 eq 39750),
    ...    sCellIndex-r10 eq 3 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 52 and dl-CarrierFreq-r10 eq 39948)
    ...    )
    Expect Message Flow
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration( ${Scell_addition} )
    ...    UE_${ueid}:RRC_RRCConnectionReconfigurationComplete
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration( ${DL_Scell_addition} )
    ...    UE_${ueid}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_${ueid}_attach    overall_timeout=30
    Attach Ue And Configure Scell    ueid=${ueid}    ca_band_comb=${4CC_SUPPORTED_BAND_25A_26A_41C}    num_scell=3    cellid=1
    Flow Occurred As Expected    alias=UE_${ueid}_attach

UE5 Attach To Cell1 And Configure 5CC With CarrierFreq_8140_8340_39750_39948_40146
    [Arguments]    ${ueid}=5
    ${Scell_addition}    catenate
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq 8140,
    ...    carrierFreq eq 8340,
    ...    carrierFreq eq 40146,
    ...    carrierFreq eq 39948,
    ...    carrierFreq eq 39750
    ...    )
    ${DL_Scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 2 and dl-CarrierFreq-r10 eq 8340),
    ...    sCellIndex-r10 eq 2 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 51 and dl-CarrierFreq-r10 eq 39750),
    ...    sCellIndex-r10 eq 3 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 52 and dl-CarrierFreq-r10 eq 39948),
    ...    sCellIndex-r10 eq 4 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 53 and dl-CarrierFreq-r10 eq 40146)
    ...    )
    Expect Message Flow
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration( ${Scell_addition} )
    ...    UE_${ueid}:RRC_RRCConnectionReconfigurationComplete
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration( ${DL_Scell_addition} )
    ...    UE_${ueid}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_${ueid}_attach    overall_timeout=30
    Attach Ue And Configure Scell    ueid=${ueid}    ca_band_comb=${5CC_SUPPORTED_BAND_25A_25A_41D}    num_scell=4    cellid=1
    Flow Occurred As Expected    alias=UE_${ueid}_attach

Start Throughput DL_750M_UL_7M And Verify Traffic
    [Arguments]    ${ueid}    ${dl_tput_expected}    ${qci_id}=8    ${throughput}=150
    Execute Uex Command    trf_data_start qci=${qci_id} ue=${ueid} Mbps=${throughput} dir=dl protocol=udp trf_id=1
    Execute Uex Command    trf_data_start qci=${qci_id} ue=${ueid} Mbps=${throughput} dir=dl protocol=udp trf_id=2
    Execute Uex Command    trf_data_start qci=${qci_id} ue=${ueid} Mbps=${throughput} dir=dl protocol=udp trf_id=3
    Execute Uex Command    trf_data_start qci=${qci_id} ue=${ueid} Mbps=${throughput} dir=dl protocol=udp trf_id=4
    Execute Uex Command    trf_data_start qci=${qci_id} ue=${ueid} Mbps=${throughput} dir=dl protocol=udp trf_id=5
    Execute Uex Command    trf_data_start qci=${qci_id} ue=${ueid} Mbps=7 dir=ul protocol=udp trf_id=1
    Execute Uex Command    get_ue_stats id=${ueid} type=dl_mac scell=0..7 unit=Mbps
    Check Current Throughput    ue_id=${ueid}    target=${dl_tput_expected}
    Execute Uex Command    trf_data_stop ue=${ueid}
    #Execute Uex Command    ue_stats clear id=${ueid}

Start And Verify Traffic Then Create 2_sCellIndex with CarrierFreq Scell-Band26_Band41
    [Arguments]    ${ueid}=2
    Start Throughput DL_750M_UL_7M And Verify Traffic    ueid=2    dl_tput_expected=${DL_TPUT_25A_26A_41A_3CC}

Start And Verify Traffic Then Create 3_sCellIndex with CarrierFreq_8340_8790_39750
    [Arguments]    ${ueid}=3
    Start Throughput DL_750M_UL_7M And Verify Traffic    ueid=3    dl_tput_expected=${DL_TPUT_25A_25A_26A_41A_4CC}

Start And Verify Traffic Then Create 3_sCellIndex with CarrierFreq_8790_39750_39948
    [Arguments]    ${ueid}=4
    Start Throughput DL_750M_UL_7M And Verify Traffic    ueid=4    dl_tput_expected=${DL_TPUT_25A_26A_41C_4CC}

Start And Verify Traffic Then Create 4_sCellIndex with CarrierFreq_8340_39750_39948_40146
    [Arguments]    ${ueid}=5
    Start Throughput DL_750M_UL_7M And Verify Traffic    ueid=5    dl_tput_expected=${DL_TPUT_25A_25A_41D_5CC}
