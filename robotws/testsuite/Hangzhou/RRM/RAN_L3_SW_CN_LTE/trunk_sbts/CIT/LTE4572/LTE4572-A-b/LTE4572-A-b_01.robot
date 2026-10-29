*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT
...               CLOUD_R4LAPO_CUS    owner-zhijian.tong    release-xL19A    DevHZ5_SG3
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS/LNCEL-1/LNCEL_FDD:dlChBw=3 MHz
...    @{Activate_SIB24_cell1}
...    LNBTS/LNCEL-1:dlsDciCch=DCI format 1C
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo2
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo3
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qQualMinNr
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul2
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrp
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrq
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSinr
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasEndSymbol
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots0to31
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots32to63
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots64to79
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:numSsbToAverageNr
@{Activate_SIB24_cell1}
...    LNBTS:actSIB24=true
...    LNBTS/LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB24
...    LNBTS/LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB24
...    @{Create_8nrCarFrqLs_Under_NRFIM_With_cell1}
@{Create_8nrCarFrqLs_Under_NRFIM_With_cell1}
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=1|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=1sf|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=15KHz|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:tResNrSF:nrResTiFHM=0.5
...    LNBTS/LNCEL-1/NRFIM-1:tResNrSF:nrResTiFMM=0.75
...    LNBTS/LNCEL-1/SIB-0:threshServingLowQR9=1
...    LNBTS/LNCEL-1/SIB-0:cellSelectionInfoV920:qQualMinOffsetR9=1
...    LNBTS/LNCEL-1/SIB-0:cellSelectionInfoV920:qQualMinR9=-3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=1|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=1sf|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=15KHz|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=1|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=1sf|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=15KHz|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=1|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=1sf|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=15KHz|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=1|dlCarFrqNr=7
...     LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=1sf|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=15KHz|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=1|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=1sf|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=15KHz|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=1|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=1sf|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=15KHz|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=2
...     LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=1|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=1sf|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=15KHz|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=2|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot2|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=7|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot8|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=7|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=7|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=4|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=3|dlCarFrqNr=7
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=2|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot4|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=2|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot4|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot2|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot2|dlCarFrqNr=5
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot2|dlCarFrqNr=6
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot2|dlCarFrqNr=7
@{Add_more_optional_parameters}
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=7|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot8|dlCarFrqNr=3
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
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=7|dlCarFrqNr=4
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
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=7|dlCarFrqNr=5
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
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=4|dlCarFrqNr=6
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
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=3|dlCarFrqNr=7
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
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=2|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot4|dlCarFrqNr=8
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
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=2|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot4|dlCarFrqNr=9
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
...     LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=240KHz|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=2|dlCarFrqNr=2
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
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=3
@{Add_little_optional_parameters}
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo2
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo3
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qQualMinNr
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul2
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrp
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrRsrq
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSinr
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasEndSymbol
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots0to31
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots32to63
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrSsRssiMeasSlots64to79
...    delete:LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:numSsbToAverageNr
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=7|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot8|dlCarFrqNr=3
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
...     LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=240KHz|dlCarFrqNr=3
...    LNBTS/LNCEL-1/NRFIM-1:tResNrSF:nrResTiFHM=0.5
...    LNBTS/LNCEL-1/NRFIM-1:tResNrSF:nrResTiFMM=0.75
...    LNBTS/LNCEL-1/SIB-0:threshServingLowQR9=1
...    LNBTS/LNCEL-1/SIB-0:cellSelectionInfoV920:qQualMinOffsetR9=1
...    LNBTS/LNCEL-1/SIB-0:cellSelectionInfoV920:qQualMinR9=-3
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=4
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=7|dlCarFrqNr=4
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
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=7|dlCarFrqNr=5
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
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=4|dlCarFrqNr=6
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
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=3|dlCarFrqNr=7
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
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=2|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot4|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=1|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul1=3|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:pMaxNr=23|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qQualMinNr=-20|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=240KHz|dlCarFrqNr=8
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=2|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot4|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=1|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul1=3|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:pMaxNr=23|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qQualMinNr=-20|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=240KHz|dlCarFrqNr=9
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResPrio=2|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrCelResSubPrio=oDot2|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=1|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfoSul1=3|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:pMaxNr=23|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qQualMinNr=-20|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=5sf|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=240KHz|dlCarFrqNr=2
...    LNBTS/LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=3
${UE_EUTRA_CAPABILITIES}    CD9FF449B2E75008081C0FFFFFFFFF943100030401052A040045400C167FFFFFFFC029FFFFFFFF80

*** Test Cases ***
LTE4572-A-b_01_04_All configured NRFIM instances are sorted in SIB24 based on NRCelResPrio and nrfimId_FDD
    [Tags]
    Lock Unlock cell1 and all dlCarFrqNrs will be broadcast in SIB24
    Add little parameters to make the lowest priority dlCarFrqNr not be broadcast in SIB24
    Go on Adding more optional parameters to make two dlCarFrgNrs with lower priority not be broadcast because it is tailored
    Wideband UE can success attach to the cell

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD_ABIO
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    create enb alias    ENB_1    enb_id=1    id_type=wts
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus

Modify Yaml
    Update Yaml    UEs/UE_sets/1    capability: ${UE_EUTRA_CAPABILITIES}

Add little parameters to make the lowest priority dlCarFrqNr not be broadcast in SIB24
    ${sib24_with_7higher_pri}    catenate
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
    ...    ,
    ...    (carrierFreq-r15 eq 9)
    ...    )
    ${sib_24_without_lowest_pri_nmeet}    catenate
    ...    carrierFreqListNR-r15 contains (
    ...    (carrierFreq-r15 eq 2)
    ...    )
    Delta Commission Parameters    ${Add_little_optional_parameters}
    Cells Should Be Onair
    expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType24-r15 (${sib24_with_7higher_pri})
    ...    alias=sib24_with_7higher_pri    overall_timeout=20
    Expect Message Will Not Occur
    ...    CELL_1:RRC_SystemInformationBlockType24-r15 (${sib_24_without_lowest_pri_nmeet})
    ...    alias=sib24_without_lowest_pri    overall_timeout=20
    Flow Occurred as expected    alias=sib24_with_7higher_pri
    Flow Not Occurred For Message    alias=sib24_without_lowest_pri

Go on Adding more optional parameters to make two dlCarFrgNrs with lower priority not be broadcast because it is tailored
    ${sib24_with_6pri_dlCar}    catenate
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
    ${sib24_without_2low_pri}    catenate
    ...    carrierFreqListNR-r15 contains (
    ...    (carrierFreq-r15 eq 2)
    ...    ,
    ...    (carrierFreq-r15 eq 9)
    ...    )
    Delta Commission Parameters    ${Add_more_optional_parameters}
    Cells Should Be Onair
    expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType24-r15 (${sib24_with_6pri_dlCar})
    ...    alias=sib24_with_6pri_dlCar    overall_timeout=20
    Expect Message Will Not Occur
    ...    CELL_1:RRC_SystemInformationBlockType24-r15 (${sib24_without_2low_pri})
    ...    alias=sib24_without_2low_pri    overall_timeout=20
    Flow Occurred as expected    alias=sib24_with_6pri_dlCar
    Flow Not Occurred For Message    alias=sib24_without_2low_pri

Lock Unlock cell1 and all dlCarFrqNrs will be broadcast in SIB24
    ${sib24_8dl}    catenate
    ...    carrierFreqListNR-r15 contains (
    ...    (carrierFreq-r15 eq 3 and
    ...    cellReselectionPriority-r15 eq 7 and
    ...    cellReselectionSubPriority-r15 eq 'oDot8')
    ...    ,
    ...    (carrierFreq-r15 eq 4 and
    ...    cellReselectionPriority-r15 eq 7 and
    ...    cellReselectionSubPriority-r15 eq 'oDot2')
    ...    ,
    ...    (carrierFreq-r15 eq 5 and
    ...    cellReselectionPriority-r15 eq 7 and
    ...    cellReselectionSubPriority-r15 eq 'oDot2')
    ...    ,
    ...    (carrierFreq-r15 eq 6 and
    ...    cellReselectionPriority-r15 eq 4 and
    ...    cellReselectionSubPriority-r15 eq 'oDot2')
    ...    ,
    ...    (carrierFreq-r15 eq 7 and
    ...    cellReselectionPriority-r15 eq 3 and
    ...    cellReselectionSubPriority-r15 eq 'oDot2')
    ...    ,
    ...    (carrierFreq-r15 eq 8 and
    ...    cellReselectionPriority-r15 eq 2 and
    ...    cellReselectionSubPriority-r15 eq 'oDot4')
    ...    ,
    ...    (carrierFreq-r15 eq 9 and
    ...    cellReselectionPriority-r15 eq 2 and
    ...    cellReselectionSubPriority-r15 eq 'oDot4')
    ...    ,
    ...    (carrierFreq-r15 eq 2 and
    ...    cellReselectionPriority-r15 eq 2 and
    ...    cellReselectionSubPriority-r15 eq 'oDot2')
    ...    )
    Block Cell1
    Unblock Cell1
    expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType24-r15 (${sib24_8dl})
    ...    alias=sib24_with_8dlCarFrqNrs    overall_timeout=20
    Cells Should Be Onair
    flow occurred as expected    alias=sib24_with_8dlCarFrqNrs


Wideband UE can success attach to the cell
    execute uex command    ue_attach id=1 cell=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES}
