*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS    DEVHZ5_SG3
...               owner-zhijian.tong    release-SBTS00
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNCEL-1/LNCEL_TDD-0:earfcn=38000
...    LNCEL-2/LNCEL_TDD-0:earfcn=38000
...    LNCEL-3/LNCEL_TDD-0:earfcn=38000
...    @{Activate_SIB24_cell1}
...    @{Create_NRFIM_cell1}
...    @{Idle_Mode_LB}
...    LNCEL-1/SDRX-0:drxSmartProfile6:drxProfileIndex=6
...    LNCEL-2/SDRX-0:drxSmartProfile6:drxProfileIndex=6
...    LNCEL-3/SDRX-0:drxSmartProfile6:drxProfileIndex=6
...    LNCEL-1:targetSelMethod=SIB_based
...    LNCEL-2:targetSelMethod=SIB_based
...    LNCEL-3:targetSelMethod=SIB_based
...    LNBTS/LNCEL-1:dlsDciCch=DCI format 1C
@{Disabled_actSIB24}
...    LNBTS:actSIB24=false
@{Activate_SIB24_cell1}
...    LNBTS:actSIB24=true
...    LNBTS/LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB24
...    LNBTS/LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB24
...    @{Create_NRFIM_cell1}
@{Create_NRFIM_cell1}
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=5
${ue_eutra_capabilities_with_NR_SA}    C59FF41032C10381FFFFFFFFF38200820082950200204004140080451002120005500020045240000800004120600004200100
@{Enabled_Idle_Mode_LB_Of_LTE2051}
...    @{fix_relation_error}
...    LNBTS:actMeasBasedIMLB=true
...    LNBTS:actIdleLB=true
...    LNCEL:actInterFreqLB=true
...    LNBTS:actSelMobPrf=false
...    LNCEL-1:inactivityTimer=10
...    LNCEL-1:idleLBPercentageOfUes=100
...    MODPR-0:idleLBPercentageOfUes=100
...    MODPR-0:autoAdapt=true
...    LNCEL-1/IRFIM-1:idleLBEutCelResWeight=10
...    LNCEL-1/IRFIM-1:interTResEut=5
...    LNCEL-1/IRFIM-1:interFrqThrH=2
...    LNCEL-1/IRFIM-1:interFrqThrL=50
...    LNCEL-1/IRFIM-1:qRxLevMinInterF=-100
...    LNCEL-1/IRFIM-1:dlCarFrqEut=${IR3Ferq}
...    LNCEL-1:loadSettings:targetLoadPdcch=1
...    LNCEL-1/IRFIM-1:eutCelResPrio=2
...    LNCEL-1/IRFIM-2:interFrqThrH=2
...    LNCEL-1/IRFIM-2:interFrqThrL=50
...    LNCEL-1/IRFIM-2:qRxLevMinInterF=-100
...    LNBTS:reportTimerIMLBA4=5000ms
...    LNCEL-1:loadSettings:nomNumPrbNonGbr=5
...    LNCEL-1/IRFIM-2:eutCelResPrio=2
...    LNCEL-1/IRFIM-2:idleLBEutCelResWeight=90
...    LNCEL-1/IRFIM-2:interTResEut=5
...    LNCEL-1/IRFIM-2:dlCarFrqEut=${IR2Ferq}
...    LNCEL-1:loadSettings:ulStaticCac=100
...    LNCEL-1:intraFreqLbLoadThresholds:hysteresisLoadPdcch=0
...    LNCEL-1:intraFreqLbLoadThresholds:loadBalancingProfile=fast
...    LNCEL-1:intraFreqLbLoadThresholds:highLoadPdcch=60
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=${EutraIF_A_g}
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadPdcch=1
...    LNCEL-1/IRFIM-1:enableA4IMLB=enabled
...    LNCEL-1/IRFIM-2:minDeltaRsrpIMLB=5
...    LNCEL-1/IRFIM-2:minDeltaRsrqIMLB=10
...    LNCEL-1/IRFIM-2:minRsrpIMLB=-80
...    LNCEL-1/IRFIM-2:minRsrqIMLB=-190
...    LNCEL-1/IRFIM-1:minDeltaRsrpIMLB=5
...    LNCEL-1/IRFIM-1:minDeltaRsrqIMLB=10
...    LNCEL-1/IRFIM-1:minRsrpIMLB=-80
...    LNCEL-1/IRFIM-1:minRsrqIMLB=-190
...    LNCEL-1/IRFIM-2:enableA4IMLB=enabled
...    LNCEL-1:idleLBCelResWeight=1
...    LNCEL-1:iFLBLoadThresholds:iFLBRetryTimer=30
...    LNCEL-1:iFLBLoadThresholds:iFLBBearCheckTimer=8
...    delete:UFFIM-1
...    delete:CDFIM-1
...    delete:GFIM-1
...    delete:IAFIM-1
...    ${EMPTY}
...    LNCEL-1:idleLBCapThresh=100
...    LNBTS:actIfHo=enabled
@{fix_relation_error}
...    LNCEL:actServRlqInterFreqLB=false
...    LNCEL:iFLBA4ActLim=20
...    LNCEL/LNCEL_TDD-0:actServRlqTputInterFreqLB=false
...    delete:LNCEL-2/SIB-0/sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB8
...    delete:LNCEL-2/SIB-0/sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB8
...    delete:LNCEL-3/SIB-0/sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB8
...    delete:LNCEL-3/SIB-0/sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB8
@{All_Optional_Paramters_In_Cell1_And_Disabled_SIB24}
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo2=11
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo3=1
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul1=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul2=1
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrp=-42
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrq=0
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSinr=0
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasEndSymbol=symbol 5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots0to31=1
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots32to63=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots64to79=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:numSsbToAverageNr=1
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qQualMinNr=-20
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50
...    LNBTS/LNCEL-1/NRFIM-1:tResNrSF:nrResTiFHM=0.5
...    LNBTS/LNCEL-1/NRFIM-1:tResNrSF:nrResTiFMM=0.75
...    LNBTS:actSIB24=false
...    LNBTS/LNCEL-1/SIB-0:threshServingLowQR9=1
...    LNBTS/LNCEL-1/SIB-0:cellSelectionInfoV920:qQualMinOffsetR9=1
...    LNBTS/LNCEL-1/SIB-0:cellSelectionInfoV920:qQualMinR9=-3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=240KHz
...    LNBTS/LNCEL-1:targetSelMethod=dedicated
...    LNBTS/LNCEL-2:targetSelMethod=dedicated
...    LNBTS/LNCEL-3:targetSelMethod=dedicated
@{Idle_Mode_LB}
...    LNBTS:actMeasBasedIMLB=true
...    LNBTS:actIdleLB=true
...    LNBTS:actSelMobPrf=false
...    LNCEL-1:inactivityTimer=10
...    LNCEL-1:idleLBPercentageOfUes=100
...    LNCEL-1/IRFIM-1:interTResEut=5
...    LNCEL-1/IRFIM-1:interFrqThrH=2
...    LNCEL-1/IRFIM-1:interFrqThrL=50
...    LNCEL-1/IRFIM-1:qRxLevMinInterF=-100
...    LNBTS:reportTimerIMLBA4=5000ms
...    LNCEL-1:idleLBCapThresh=100
...    LNCEL-1/IRFIM-1:enableA4IMLB=enabled
${IR3Ferq}        38100
${IR2Ferq}        37900
${EutraIF_A_g}    37970
@{Activate_SIB24_And_Create_8nrCarFrqLs}
...    LNBTS:actSIB24=true
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=5|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot2|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=1|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo2=11|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo3=1|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul1=3|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul2=1|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrp=-42|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrq=0|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSinr=0|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasEndSymbol=symbol 5|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots0to31=1|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots32to63=2|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots64to79=2|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:numSsbToAverageNr=1|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:pMaxNr=23|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qQualMinNr=-20|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=240KHz|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:tResNrSF:nrResTiFHM=0.5
...    LNBTS/LNCEL-1/NRFIM-1:tResNrSF:nrResTiFMM=0.75
...    LNBTS/LNCEL-1/SIB-0:threshServingLowQR9=1
...    LNBTS/LNCEL-1/SIB-0:cellSelectionInfoV920:qQualMinOffsetR9=1
...    LNBTS/LNCEL-1/SIB-0:cellSelectionInfoV920:qQualMinR9=-3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=5|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot2|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=1|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo2=11|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo3=1|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul1=3|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul2=1|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrp=-42|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrq=0|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSinr=0|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasEndSymbol=symbol 5|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots0to31=1|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots32to63=2|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots64to79=2|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:numSsbToAverageNr=1|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:pMaxNr=23|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qQualMinNr=-20|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=240KHz|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=5|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot2|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=1|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo2=11|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo3=1|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul1=3|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul2=1|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrp=-42|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrq=0|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSinr=0|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasEndSymbol=symbol 5|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots0to31=1|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots32to63=2|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots64to79=2|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:numSsbToAverageNr=1|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:pMaxNr=23|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qQualMinNr=-20|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=240KHz|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=5|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot2|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=1|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo2=11|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo3=1|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul1=3|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul2=1|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrp=-42|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrq=0|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSinr=0|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasEndSymbol=symbol 5|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots0to31=1|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots32to63=2|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots64to79=2|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:numSsbToAverageNr=1|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:pMaxNr=23|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qQualMinNr=-20|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=240KHz|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=5|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot2|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=1|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo2=11|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo3=1|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul1=3|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul2=1|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrp=-42|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrq=0|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSinr=0|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasEndSymbol=symbol 5|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots0to31=1|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots32to63=2|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots64to79=2|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:numSsbToAverageNr=1|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:pMaxNr=23|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qQualMinNr=-20|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=240KHz|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=5|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot2|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=1|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo2=11|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo3=1|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul1=3|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul2=1|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrp=-42|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrq=0|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSinr=0|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasEndSymbol=symbol 5|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots0to31=1|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots32to63=2|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots64to79=2|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:numSsbToAverageNr=1|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:pMaxNr=23|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qQualMinNr=-20|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=240KHz|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=4|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=1|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo2=11|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo3=1|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul1=3|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul2=1|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrp=-42|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrq=0|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSinr=0|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasEndSymbol=symbol 5|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots0to31=1|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots32to63=2|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots64to79=2|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:numSsbToAverageNr=1|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:pMaxNr=23|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qQualMinNr=-20|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=240KHz|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=5|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot2|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=1|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo2=11|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo3=1|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul1=3|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul2=1|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrp=-42|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrq=0|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSinr=0|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasEndSymbol=symbol 5|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots0to31=1|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots32to63=2|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots64to79=2|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:numSsbToAverageNr=1|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:pMaxNr=23|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qQualMinNr=-20|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=240KHz|dlCarFrqNr=2

*** Test Case ***
LTE4572-A-c_01_01_No IMMCI IE in RRC Connection Release message
    [Tags]
    Delta Commission Parameters    ${Enabled_Idle_Mode_LB_Of_LTE2051}
    Lock Unlock cell and UE1 can be received SIB24
    Wideband UE1 with NR SA capability attach to Cell1 and no IMMCI in the RRC release Message
    Delta Commission Parameters    ${Disabled_actSIB24}
    Lock Unlock cell and UE2 can not be received SIB24
    Wideband UE2 with NR SA capability attach to Cell1 and IMMCI is in the RRC release Message

*** Keyword ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_ABIO
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    create enb alias    ENB_1    enb_id=1    id_type=wts
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus
    execute egate command    trace_sim uec=1 protocol=rrc on

Modify Yaml
    Update Yaml    UEs/UE_sets/1    capability: ${ue_eutra_capabilities_with_NR_SA}

Wideband UE1 with NR SA capability attach to Cell1 and no IMMCI in the RRC release Message
    Expect Message Will Not Occur
    ...    UE_1:RRC_RRCConnectionRelease (idleModeMobilityControlInfo is present)
    ...    alias=UE1_noIMMCI    overall_timeout=30
    execute uex command    ue_attach id=1 cell=1 ue_eutra_capabilities=${ue_eutra_capabilities_with_NR_SA}
    flow not occurred for message    alias=UE1_noIMMCI


Wideband UE2 with NR SA capability attach to Cell1 and IMMCI is in the RRC release Message
    Expect Message flow
    ...    UE_2:RRC_RRCConnectionRelease (idleModeMobilityControlInfo contains (freqPriorityListEUTRA contains (carrierFreq eq 38100)))
    ...    alias=UE2_IMMCI    overall_timeout=30
    execute uex command    ue_attach id=2 cell=1 ue_eutra_capabilities=${ue_eutra_capabilities_with_NR_SA}
    flow occurred as expected    alias=UE2_IMMCI

Lock Unlock cell and UE1 can be received SIB24
    expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType24-r15
    ...    alias=ue1_sib24    overall_timeout=20
    Block Cell1
    Unblock Cell1
    Cells Should Be Onair
    Flow Occurred as expected    alias=ue1_sib24

Lock Unlock cell and UE2 can not be received SIB24
    Expect Message Will Not Occur
    ...    CELL_1:RRC_SystemInformationBlockType24-r15
    ...    alias=ue2_no_sib24    overall_timeout=20
    Block Cell1
    Unblock Cell1
    Cells Should Be Onair
    flow not occurred for message    alias=ue2_no_sib24

Lock Unlock cell and iphy can not be received SIB24
    Block Cell1
    Unblock Cell1
    Cells Should Be Onair
    Expect Message Will Not Occur
    ...    CELL_1:RRC_SystemInformationBlockType24-r15
    ...    alias=no_sib24    overall_timeout=20
    flow not occurred for message    alias=no_sib24

Online Activate SIB24 And Make Size exceeds maximum PDU size
    ${sib24_nrCarFrqs}    catenate
    ...    carrierFreqListNR-r15 contains (
    ...    (carrierFreq-r15 eq 3)
    ...    ,
    ...    (carrierFreq-r15 eq 4)
    ...    ,
    ...    (carrierFreq-r15 eq 5)
    ...    ,
    ...    (carrierFreq-r15 eq 6)
    ...    ,
    ...    (carrierFreq-r15 eq 7)
    ...    ,
    ...    (carrierFreq-r15 eq 8)
    ...    )
    ${sib24_no_nrCarFrqs}    catenate
    ...    carrierFreqListNR-r15 contains (
    ...    (carrierFreq-r15 eq 9))
    Delta Commission Parameters    ${Activate_SIB24_And_Create_8nrCarFrqLs}
    Cells Should Be Onair
    expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType24-r15 (${sib24_nrCarFrqs})
    ...    alias=sib24_with_nrCarFrqs    overall_timeout=20
    expect message will not occur
    ...    CELL_1:RRC_SystemInformationBlockType24-r15 (${sib24_no_nrCarFrqs})
    ...    alias=sib24_no_nrCarFrqs    overall_timeout=20
    flow occurred as expected    alias=sib24_with_nrCarFrqs
    flow not occurred for message    alias=sib24_no_nrCarFrqs

Check raise fault 6361
    ${fault6361}    Create List    severity=transient    fault_id=6361    fault_name= SIB24 information incomplete    alarm_id=7115
    ...    alarm_name=BASE STATION INFORMATION
    Fm Fault Should Be Raised    ${fault6361}
