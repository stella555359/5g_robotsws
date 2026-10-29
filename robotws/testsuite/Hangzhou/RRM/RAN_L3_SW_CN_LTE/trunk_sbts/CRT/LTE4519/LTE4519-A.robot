*** Settings ***
Documentation     9*20M -> multiple cells raise fault 1868 'not enough HW'
...               9*20M + actBbPooling-> Cell4+7 (last port for RRU2 and 3) fault 1868
...               1/3/7/8 20M + 5*5M -> Cell9 fault 1868
...               1/3/7/8 20M + 5*5M + actBbpooling-> OnAir
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_2MAPO_2CUS    release-SBTS19A
...               team-SG4    owner-zhiguo.li
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${DEBUG}    ${False}
${SNAPSHOT_FLAG}    pass:False,fail:False
${BTSLOG_FLAG}    ${True}
${WIRESHARK_FLAG}    ${False}
${NSETAP_PLUGIN_VERSION}    ${EMPTY}
${TTITRACE_FLAG}    ${False}
${EMIL_FLAG}    ${True}
${IM_FLAG}    ${False}
${ONLY_REPORT_REP}    ${False}
${UTE_WIRESHARK_FLAG}    ${False}
${UTE_CPU_MEM_FLAG}    ${False}
${SOS_REPORT_FLAG}    pass:False,fail:False

@{PARAMS_IN_SCF}
...    delete:LNCEL/CAPR.*
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAmbrModCaTrigger=true
...    LNBTS-1:actAdvScellMeas=false
...    LNBTS-1:actFlexScellSelect=true
...    LNBTS-1:sCellActivationMethod=blind
...    LNBTS-1:sCellDeactivationTimereNB=infinity
...    LNBTS-1:multScellReleaseTimer=0
...    LNBTS-1:actInterEnbDLCAggr=true
...    LNBTS-1:caClusterId=0
...    LNBTS-1:caClusterMemberId=1
...    LNBTS-1:actULCAggr=false
...    LNBTS-1:actInterEnbULCAggr=false
...    LNBTS-1:actCompChecks=false
...    LNBTS-1:caSchedFairFact=10
...    LNBTS-1:actFlexCaMgmt=false
...    LNBTS-1:actIscaHarqEnh=false
...    LNBTS-1:mcc=262
...    LNBTS-1:mnc=3
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=0
...    LNBTS-1/LNBTS_FDD-0:maxBtsTimeError=1000
...    LNBTS-1/CADPR-0:sFreqPrio=10000
...    LNBTS-1/CAGENB-0:actEnhCaBandCombSel=off
...    LNBTS-1/CAGENB-0:nlcvDeltaX2C2=2
...    LNBTS-1/CAGENB-0:caClusterEnbList:lnBtsId=2
...    LNBTS-1/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS-1/LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNBTS-1/LNADJ-1:cPlaneIpAddr=10.0.1.4
...    LNBTS-1/LNADJ-1:adjEnbId=2
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:actFlowCtrlEnh=false
...    LNCEL:actScellConfigForHiDemand=false
...    LNCEL:maxNumScells=4
...    LNCEL:actModulationSchemeDl=256QAM
...    LNCEL:dlCaCqiWindow=50
...    LNCEL:caPoolId=1
...    LNCEL:tac=33
...    LNCEL/LNCEL_FDD-0:maxNrSymPdcch=2
...    LNCEL/LNCEL_FDD-0:maxNumUeDl=7
...    LNCEL/LNCEL_FDD-0:maxNumUeUl=7
...    LNCEL-1/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-2/LNCEL_FDD-0:dlChBw=5 MHz
...    LNCEL-2/LNCEL_FDD-0:ulChBw=5 MHz
...    LNCEL-3/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-3/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-4/LNCEL_FDD-0:dlChBw=5 MHz
...    LNCEL-4/LNCEL_FDD-0:ulChBw=5 MHz
...    LNCEL-5/LNCEL_FDD-0:dlChBw=5 MHz
...    LNCEL-5/LNCEL_FDD-0:ulChBw=5 MHz
...    LNCEL-6/LNCEL_FDD-0:dlChBw=5 MHz
...    LNCEL-6/LNCEL_FDD-0:ulChBw=5 MHz
...    LNCEL-7/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-7/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-8/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-8/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-9/LNCEL_FDD-0:dlChBw=5 MHz
...    LNCEL-9/LNCEL_FDD-0:ulChBw=5 MHz
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=300
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=18300
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1500
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19500
...    LNCEL-5/LNCEL_FDD-0:earfcnDL=3100
...    LNCEL-5/LNCEL_FDD-0:earfcnUL=21100
...    LNCEL-7/LNCEL_FDD-0:earfcnDL=3200
...    LNCEL-7/LNCEL_FDD-0:earfcnUL=21200
...    LNCEL-8/LNCEL_FDD-0:earfcnDL=9500
...    LNCEL-8/LNCEL_FDD-0:earfcnUL=27500
...    LNCEL-9/LNCEL_FDD-0:earfcnDL=9520
...    LNCEL-9/LNCEL_FDD-0:earfcnUL=27520
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:lcrId=3
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:lcrId=8
...    LNCEL-1/CAREL-3:lnBtsId=2
...    LNCEL-1/CAREL-3:lcrId=51
...    LNCEL-1/CAREL-3:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-4:lnBtsId=2
...    LNCEL-1/CAREL-4:lcrId=52
...    LNCEL-1/CAREL-4:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-3/CAREL-1:lnBtsId=1
...    LNCEL-3/CAREL-1:lcrId=7
...    LNCEL-3/CAREL-2:lnBtsId=1
...    LNCEL-3/CAREL-2:lcrId=8
...    LNCEL-3/CAREL-3:lnBtsId=2
...    LNCEL-3/CAREL-3:lcrId=51
...    LNCEL-3/CAREL-3:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-3/CAREL-4:lnBtsId=2
...    LNCEL-3/CAREL-4:lcrId=52
...    LNCEL-3/CAREL-4:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-7/CAREL-1:lnBtsId=1
...    LNCEL-7/CAREL-1:lcrId=8
...    LNCEL-7/CAREL-2:lnBtsId=2
...    LNCEL-7/CAREL-2:lcrId=51
...    LNCEL-7/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-7/CAREL-3:lnBtsId=2
...    LNCEL-7/CAREL-3:lcrId=52
...    LNCEL-7/CAREL-3:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-7/CAREL-4:lnBtsId=2
...    LNCEL-7/CAREL-4:lcrId=53
...    LNCEL-7/CAREL-4:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-7/CAREL-5:lnBtsId=2
...    LNCEL-7/CAREL-5:lcrId=54
...    LNCEL-7/CAREL-5:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAPR-1:earfcnDL=1500
...    LNCEL-1/CAPR-1:sFreqPrio=1
...    LNCEL-1/CAPR-2:earfcnDL=9500
...    LNCEL-1/CAPR-2:sFreqPrio=100
...    LNCEL-1/CAPR-3:earfcnDL=38750
...    LNCEL-1/CAPR-3:sFreqPrio=500
...    LNCEL-1/CAPR-4:earfcnDL=38948
...    LNCEL-1/CAPR-4:sFreqPrio=1000
...    LNCEL-3/CAPR-1:earfcnDL=3200
...    LNCEL-3/CAPR-1:sFreqPrio=1
...    LNCEL-3/CAPR-2:earfcnDL=9500
...    LNCEL-3/CAPR-2:sFreqPrio=100
...    LNCEL-3/CAPR-3:earfcnDL=38750
...    LNCEL-3/CAPR-3:sFreqPrio=500
...    LNCEL-3/CAPR-4:earfcnDL=38948
...    LNCEL-3/CAPR-4:sFreqPrio=1000
...    LNCEL-7/CAPR-1:earfcnDL=9500
...    LNCEL-7/CAPR-1:sFreqPrio=1
...    LNCEL-7/CAPR-2:earfcnDL=38750
...    LNCEL-7/CAPR-2:sFreqPrio=100
...    LNCEL-7/CAPR-3:earfcnDL=38948
...    LNCEL-7/CAPR-3:sFreqPrio=500
...    LNCEL-7/CAPR-4:earfcnDL=39146
...    LNCEL-7/CAPR-4:sFreqPrio=1000
...    LNCEL-7/CAPR-5:earfcnDL=39344
...    LNCEL-7/CAPR-5:sFreqPrio=5000
...    MNL-1/MNLENT-1/SYNC-1:btsSyncMode=PhaseSync
...    MNL-1/MNLENT-1/SYNC-1:manualFrameTimingAdjustment=0
...    @{Tput}
...    @{BBPooling}
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
...    LNBTS-2:actInterEnbDLCAggr=true
...    LNBTS-2:caClusterId=0
...    LNBTS-2:caClusterMemberId=2
...    LNBTS-2:actULCAggr=false
...    LNBTS-2:actInterEnbULCAggr=false
...    LNBTS-2:actCompChecks=true
...    LNBTS-2:caSchedFairFact=10
...    LNBTS-2/LNBTS_TDD-0:numTxWithHighNonGbr=0
...    LNBTS-2/CAGENB-0:actEnhCaBandCombSel=off
...    LNBTS-2/CAGENB-0:nlcvDeltaX2C2=2
...    LNBTS-2/CAGENB-0:caClusterEnbList:lnBtsId=1
...    LNBTS-2/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS-2/CAGENB-0:maxDlCaConfigForUlCa=max_3CC_DL_CA
...    LNBTS-2/LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNBTS-2/LNADJ-1:cPlaneIpAddr=10.0.1.2
...    LNBTS-2/LNADJ-1:adjEnbId=1
...    LNBTS-2:mcc=262
...    LNBTS-2:mnc=3
...    LNCEL:tac=33
...    LNBTS-2/LNADJ-1/LNADJL-1:ecgiLcrId=1
...    LNBTS-2/LNADJ-1/LNADJL-1:fDlEarfcn=300
...    LNBTS-2/LNADJ-1/LNADJL-1:phyCellId=1
...    LNBTS-2/LNADJ-1/LNADJL-1:tac=33
...    LNBTS-2/LNADJ-1/LNADJL-2:ecgiLcrId=2
...    LNBTS-2/LNADJ-1/LNADJL-2:fDlEarfcn=1300
...    LNBTS-2/LNADJ-1/LNADJL-2:phyCellId=2
...    LNBTS-2/LNADJ-1/LNADJL-2:tac=33
...    LNBTS-2/LNADJ-1/LNADJL-3:ecgiLcrId=3
...    LNBTS-2/LNADJ-1/LNADJL-3:fDlEarfcn=1500
...    LNBTS-2/LNADJ-1/LNADJL-3:phyCellId=3
...    LNBTS-2/LNADJ-1/LNADJL-3:tac=33
...    LNBTS-2/LNADJ-1/LNADJL-4:ecgiLcrId=4
...    LNBTS-2/LNADJ-1/LNADJL-4:fDlEarfcn=1700
...    LNBTS-2/LNADJ-1/LNADJL-4:phyCellId=4
...    LNBTS-2/LNADJ-1/LNADJL-4:tac=33
...    LNBTS-2/LNADJ-1/LNADJL-5:ecgiLcrId=5
...    LNBTS-2/LNADJ-1/LNADJL-5:fDlEarfcn=3100
...    LNBTS-2/LNADJ-1/LNADJL-5:phyCellId=5
...    LNBTS-2/LNADJ-1/LNADJL-5:tac=33
...    LNBTS-2/LNADJ-1/LNADJL-6:ecgiLcrId=6
...    LNBTS-2/LNADJ-1/LNADJL-6:fDlEarfcn=3100
...    LNBTS-2/LNADJ-1/LNADJL-6:phyCellId=6
...    LNBTS-2/LNADJ-1/LNADJL-6:tac=33
...    LNBTS-2/LNADJ-1/LNADJL-7:ecgiLcrId=7
...    LNBTS-2/LNADJ-1/LNADJL-7:fDlEarfcn=3200
...    LNBTS-2/LNADJ-1/LNADJL-7:phyCellId=7
...    LNBTS-2/LNADJ-1/LNADJL-7:tac=33
...    LNBTS-2/LNADJ-1/LNADJL-8:ecgiLcrId=8
...    LNBTS-2/LNADJ-1/LNADJL-8:fDlEarfcn=9500
...    LNBTS-2/LNADJ-1/LNADJL-8:phyCellId=8
...    LNBTS-2/LNADJ-1/LNADJL-8:tac=33
...    LNBTS-2/LNADJ-1/LNADJL-9:ecgiLcrId=9
...    LNBTS-2/LNADJ-1/LNADJL-9:fDlEarfcn=9520
...    LNBTS-2/LNADJ-1/LNADJL-9:phyCellId=9
...    LNBTS-2/LNADJ-1/LNADJL-9:tac=33
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNCEL:actModulationSchemeDl=256QAM
...    LNCEL:scellFastSchedulingSelect=normal
...    LNCEL:ulCaMinPcellSinr=0
...    LNCEL:ulCaMinPcellSinrQci1=0
...    LNCEL:dlCaMinPcellCqiQci1=0
...    LNCEL:dlCaMinPcellCqi=0
...    LNCEL/LNCEL_TDD-0:chBw=20 MHz
...    LNCEL/LNCEL_TDD-0:tddFrameConf=2
...    LNCEL/LNCEL_TDD-0:maxNrSymPdcch=2
...    LNCEL/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...    LNCEL/LNCEL_TDD-0:activatedMimoTM=TM9
...    LNCEL/LNCEL_TDD-0:fourLayerMimoAvSpectralEff=1
...    LNCEL-1/LNCEL_TDD-0:earfcn=38750
...    LNCEL-2/LNCEL_TDD-0:earfcn=38948
...    LNCEL-3/LNCEL_TDD-0:earfcn=39146
...    LNCEL-4/LNCEL_TDD-0:earfcn=39344
...    @{Tput}
#...    @{fix_thoughtput_enb2}

@{fix_thoughtput}
...    LNCEL:cqiAperEnable=false
...    LNCEL/LNCEL_FDD-0:actUciOnlyGrants=false

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

@{BBPooling}
...    LNBTS-1:actBbPooling=true
...    LNBTS-1:bbPoolEvalPeriod=50
...    LNBTS-1:bbPoolMinResource=5
...    LNBTS-1/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...    LNCEL/BBPOOLALLOC-0:bbPoolAllocMode=automatic
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=true
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:pucchArRateEvalWinLength=0
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1

${3CC_SUPPORTED_BAND_7A_28A_40A}    7:a:a|7:a:a+28::a|7:a:a+28::a+40::a-4
${4CC_SUPPORTED_BAND_1A_3A_28A_40A}    1:a:a-4|1:a:a-4+3::a-4|1:a:a-4+3::a-4+28::a-4|1:a:a-4+3:a-4+28::a-4+40::a-4
${4CC_SUPPORTED_BAND_3A_7A_28A_40A}    3:a:a-4|3:a:a-4+7::a-4|3:a:a-4+7::a-4+28::a-4+40::a-4
${4CC_SUPPORTED_BAND_1A_28A_40C}    1:a:a-4|1:a:a-4+28::a-4|1:a:a-4+28::a-4+40::c-4
${5CC_SUPPORTED_BAND_1A_3A_28A_40C}    1:a:a-4|1:a:a-4+3::a-4|1:a:a-4+3::a-4+28::a-4|1:a:a-4+3::a-4+28::a-4+40::c-4
${5CC_SUPPORTED_BAND_3A_7A_28A_40C}    3:a:a-4|3:a:a-4+7::a-4|3:a:a-4+7::a-4+28::a-4|3:a:a-4+7::a-4+28::a-4+40::c-4

${DL_TPUT_7A_28A_40A_3CC}    360
${DL_TPUT_1A_3A_28A_40A_4CC}    505
${DL_TPUT_3A_7A_28A_40A_4CC}    505
${DL_TPUT_1A_28A_40C_4CC}    505
${DL_TPUT_1A_3A_28A_40C_5CC}    575
${DL_TPUT_3A_7A_28A_40C_5CC}    575

*** Test Cases ***
LTE4519-A-c-7A_28A_40A_3CC
    [Tags]
    UE2 Attach To Cell7 And Configure 3CC With CarrierFreq_3200_9500_38750
    Start And Verify Traffic Then Create 2_sCellIndex with CarrierFreq_9500_38750
    UE detach    ueid=2

LTE4519-A-c-1A_3A_28A_40A_4CC
    [Tags]
    UE3 Attach To Cell1 And Configure 4CC With CarrierFreq_300_1500_9500_38750
    Start And Verify Traffic Then Create 3_sCellIndex with CarrierFreq_1500_9500_38750
    UE detach    ueid=3

LTE4519-A-c-3A_7A_28A_40A_4CC
    [Tags]
    UE4 Attach To Cell3 And Configure 4CC With CarrierFreq_1500_3200_9500_38750
    Start And Verify Traffic Then Create 3_sCellIndex with CarrierFreq_3200_9500_38750
    UE detach    ueid=4

LTE4519-A-c-1A_28A_40C_4CC
    [Documentation]    reduce the expected Tput value from 505 to 430 due to restriction of iPHY (9 cells 2 dsp configurion cannot deal with big data
    ...    even though occasionally, instantaneously surge to 540M), otherwise have to use new template for 4 cells 4 dsp configuration
    [Tags]
    UE5 Attach To Cell1 And Configure 4CC With CarrierFreq_300_9500_38750_38948
    Start And Verify Traffic Then Create 3_sCellIndex with CarrierFreq_9500_38750_38948
    UE detach    ueid=5

LTE4519-A-d-1A_3A_28A_40C_5CC
    [Documentation]    reduce the expected Tput value from 575 to 550 due to restriction of iPHY (9 cells 2 dsp configurion cannot deal with big data
    ...    even though sometimes instantaneously surge to 570M at most), otherwise have to use new template for 4 cells 4 dsp configuration
    [Tags]
    UE6 Attach To Cell1 And Configure 5CC With CarrierFreq_300_1500_9500_38750_38948
    Start And Verify Traffic Then Create 4_sCellIndex with CarrierFreq_1500_9500_38750_38948
    UE detach    ueid=6

LTE4519-A-d-3A_7A_28A_40C_5CC
    [Documentation]    reduce the expected Tput value from 575 to 550 due to restriction of iPHY (9 cells 2 dsp configurion cannot deal with big data
    ...    even though sometimes instantaneously surge to 570M at most), otherwise have to use new template for 4 cells 4 dsp configuration
    [Tags]
    UE7 Attach To Cell3 And Configure 5CC With CarrierFreq_1500_3200_9500_38750_38948
    Start And Verify Traffic Then Create 4_sCellIndex with CarrierFreq_3200_9500_38750_38948
    UE detach    ueid=7

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup 2CUS Env    tl_type=9CELLs_FDD    tl_type_enb2=4CELLs_TDD_B40
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
    Execute Uex Command    ue_param id=${ueid} supported_bands=1,3,7,28,40 ca_supported_bands=${ca_band_comb}
    Execute Uex Command    ue_attach id=${ueid} enb=${enbid} cell=${cellid}

UE detach
    [Arguments]    ${ueid}=1
    Execute Uex Command    ue_detach id=${ueid}

UE2 Attach To Cell7 And Configure 3CC With CarrierFreq_3200_9500_38750
    [Arguments]    ${ueid}=2
    ${Scell_addition}    catenate
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq 3200,
    ...    carrierFreq eq 9500,
    ...    carrierFreq eq 39344,
    ...    carrierFreq eq 39146,
    ...    carrierFreq eq 38948,
    ...    carrierFreq eq 38750
    ...    )
    ${DL_Scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 8 and dl-CarrierFreq-r10 eq 9500),
    ...    sCellIndex-r10 eq 2 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 51 and dl-CarrierFreq-r10 eq 38750)
    ...    )
    Expect Message Flow
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration( ${Scell_addition} )
    ...    UE_${ueid}:RRC_RRCConnectionReconfigurationComplete
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration( ${DL_Scell_addition} )
    ...    UE_${ueid}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_${ueid}_attach    overall_timeout=30
    Attach Ue And Configure Scell    ueid=${ueid}    ca_band_comb=${3CC_SUPPORTED_BAND_7A_28A_40A}    num_scell=2    cellid=7
    Flow Occurred As Expected    alias=UE_${ueid}_attach

UE3 Attach To Cell1 And Configure 4CC With CarrierFreq_300_1500_9500_38750
    [Arguments]    ${ueid}=3
    ${Scell_addition}    catenate
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq 300,
    ...    carrierFreq eq 1500,
    ...    carrierFreq eq 9500,
    ...    carrierFreq eq 38948,
    ...    carrierFreq eq 38750
    ...    )
    ${DL_Scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 3 and dl-CarrierFreq-r10 eq 1500),
    ...    sCellIndex-r10 eq 2 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 8 and dl-CarrierFreq-r10 eq 9500),
    ...    sCellIndex-r10 eq 3 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 51 and dl-CarrierFreq-r10 eq 38750)
    ...    )
    Expect Message Flow
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration( ${Scell_addition} )
    ...    UE_${ueid}:RRC_RRCConnectionReconfigurationComplete
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration( ${DL_Scell_addition} )
    ...    UE_${ueid}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_${ueid}_attach    overall_timeout=30
    Attach Ue And Configure Scell    ueid=${ueid}    ca_band_comb=${4CC_SUPPORTED_BAND_1A_3A_28A_40A}    num_scell=3    cellid=1
    Flow Occurred As Expected    alias=UE_${ueid}_attach

UE4 Attach To Cell3 And Configure 4CC With CarrierFreq_1500_3200_9500_38750
    [Arguments]    ${ueid}=4
    ${Scell_addition}    catenate
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq 1500,
    ...    carrierFreq eq 3200,
    ...    carrierFreq eq 9500,
    ...    carrierFreq eq 38948,
    ...    carrierFreq eq 38750
    ...    )
    ${DL_Scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 7 and dl-CarrierFreq-r10 eq 3200),
    ...    sCellIndex-r10 eq 2 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 8 and dl-CarrierFreq-r10 eq 9500),
    ...    sCellIndex-r10 eq 3 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 51 and dl-CarrierFreq-r10 eq 38750)
    ...    )
    Expect Message Flow
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration( ${Scell_addition} )
    ...    UE_${ueid}:RRC_RRCConnectionReconfigurationComplete
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration( ${DL_Scell_addition} )
    ...    UE_${ueid}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_${ueid}_attach    overall_timeout=30
    Attach Ue And Configure Scell    ueid=${ueid}    ca_band_comb=${4CC_SUPPORTED_BAND_3A_7A_28A_40A}    num_scell=3    cellid=3
    Flow Occurred As Expected    alias=UE_${ueid}_attach

UE5 Attach To Cell1 And Configure 4CC With CarrierFreq_300_9500_38750_38948
    [Arguments]    ${ueid}=5
    ${Scell_addition}    catenate
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq 300,
    ...    carrierFreq eq 9500,
    ...    carrierFreq eq 38750,
    ...    carrierFreq eq 38948
    ...    )
    ${DL_Scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 8 and dl-CarrierFreq-r10 eq 9500),
    ...    sCellIndex-r10 eq 2 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 51 and dl-CarrierFreq-r10 eq 38750),
    ...    sCellIndex-r10 eq 3 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 52 and dl-CarrierFreq-r10 eq 38948)
    ...    )
    Expect Message Flow
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration( ${Scell_addition} )
    ...    UE_${ueid}:RRC_RRCConnectionReconfigurationComplete
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration( ${DL_Scell_addition} )
    ...    UE_${ueid}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_${ueid}_attach    overall_timeout=30
    Attach Ue And Configure Scell    ueid=${ueid}    ca_band_comb=${4CC_SUPPORTED_BAND_1A_28A_40C}    num_scell=3    cellid=1
    Flow Occurred As Expected    alias=UE_${ueid}_attach

UE6 Attach To Cell1 And Configure 5CC With CarrierFreq_300_1500_9500_38750_38948
    [Arguments]    ${ueid}=6
    ${Scell_addition}    catenate
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq 300,
    ...    carrierFreq eq 1500,
    ...    carrierFreq eq 9500,
    ...    carrierFreq eq 38948,
    ...    carrierFreq eq 38750
    ...    )
    ${DL_Scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 3 and dl-CarrierFreq-r10 eq 1500),
    ...    sCellIndex-r10 eq 2 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 8 and dl-CarrierFreq-r10 eq 9500),
    ...    sCellIndex-r10 eq 3 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 51 and dl-CarrierFreq-r10 eq 38750),
    ...    sCellIndex-r10 eq 4 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 52 and dl-CarrierFreq-r10 eq 38948)
    ...    )
    Expect Message Flow
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration( ${Scell_addition} )
    ...    UE_${ueid}:RRC_RRCConnectionReconfigurationComplete
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration( ${DL_Scell_addition} )
    ...    UE_${ueid}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_${ueid}_attach    overall_timeout=30
    Attach Ue And Configure Scell    ueid=${ueid}    ca_band_comb=${5CC_SUPPORTED_BAND_1A_3A_28A_40C}    num_scell=4    cellid=1
    Flow Occurred As Expected    alias=UE_${ueid}_attach

UE7 Attach To Cell3 And Configure 5CC With CarrierFreq_1500_3200_9500_38750_38948
    [Arguments]    ${ueid}=7
    ${Scell_addition}    catenate
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq 1500,
    ...    carrierFreq eq 3200,
    ...    carrierFreq eq 9500,
    ...    carrierFreq eq 38948,
    ...    carrierFreq eq 38750
    ...    )
    ${DL_Scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 7 and dl-CarrierFreq-r10 eq 3200),
    ...    sCellIndex-r10 eq 2 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 8 and dl-CarrierFreq-r10 eq 9500),
    ...    sCellIndex-r10 eq 3 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 51 and dl-CarrierFreq-r10 eq 38750),
    ...    sCellIndex-r10 eq 4 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 52 and dl-CarrierFreq-r10 eq 38948)
    ...    )
    Expect Message Flow
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration( ${Scell_addition} )
    ...    UE_${ueid}:RRC_RRCConnectionReconfigurationComplete
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration( ${DL_Scell_addition} )
    ...    UE_${ueid}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_${ueid}_attach    overall_timeout=30
    Attach Ue And Configure Scell    ueid=${ueid}    ca_band_comb=${5CC_SUPPORTED_BAND_3A_7A_28A_40C}    num_scell=4    cellid=3
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
    comment    Execute Uex Command    ue_stats clear id=${ueid}

Start And Verify Traffic Then Create 2_sCellIndex with CarrierFreq_9500_38750
    [Arguments]    ${ueid}=2
    Start Throughput DL_750M_UL_7M And Verify Traffic    ueid=2    dl_tput_expected=${DL_TPUT_7A_28A_40A_3CC}

Start And Verify Traffic Then Create 3_sCellIndex with CarrierFreq_1500_9500_38750
    [Arguments]    ${ueid}=3
    Start Throughput DL_750M_UL_7M And Verify Traffic    ueid=3    dl_tput_expected=${DL_TPUT_1A_3A_28A_40A_4CC}

Start And Verify Traffic Then Create 3_sCellIndex with CarrierFreq_3200_9500_38750
    [Arguments]    ${ueid}=4
    Start Throughput DL_750M_UL_7M And Verify Traffic    ueid=4    dl_tput_expected=${DL_TPUT_3A_7A_28A_40A_4CC}

Start And Verify Traffic Then Create 3_sCellIndex with CarrierFreq_9500_38750_38948
    [Arguments]    ${ueid}=5
    Start Throughput DL_750M_UL_7M And Verify Traffic    ueid=5    dl_tput_expected=${DL_TPUT_1A_28A_40C_4CC}

Start And Verify Traffic Then Create 4_sCellIndex with CarrierFreq_1500_9500_38750_38948
    [Arguments]    ${ueid}=6
    Start Throughput DL_750M_UL_7M And Verify Traffic    ueid=6    dl_tput_expected=${DL_TPUT_1A_3A_28A_40C_5CC}

Start And Verify Traffic Then Create 4_sCellIndex with CarrierFreq_3200_9500_38750_38948
    [Arguments]    ${ueid}=7
    Start Throughput DL_750M_UL_7M And Verify Traffic    ueid=7    dl_tput_expected=${DL_TPUT_3A_7A_28A_40C_5CC}
