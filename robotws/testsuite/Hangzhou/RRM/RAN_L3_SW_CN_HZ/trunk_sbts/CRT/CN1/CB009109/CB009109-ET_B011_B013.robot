*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_BOO_AP_LOO
...    team-PZ3_6    owner-ye.jing    release-5G24R3     CB009109
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_NRCELL1}
...    @{PARAMS_FOR_NRCELL2}
...    @{CB009109}
...    @{Mobillity}

@{Mobillity}
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS/NRPMRNL-1:miNrMobilityReport=5min
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actInterMeNBMobility=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms512
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL:a1MeashoEnabled=rsrp
...    NRCELL:a2MeashoEnabled=rsrp
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=65
...    NRCELL:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRCELL:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=65
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=${EMPTY}
...    XNLINK-1:cPlaneIpAddr=10.0.1.122
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:gNodeBId=36
...    NRADJGNB-1:xnLinkRef=1
...    NRADJGNB-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-1:gnbPlmn:mnc=489|mncLength=3
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:fiveGsTac=788
...    NRADJNRCELL-1:gNbId=36
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=126990
...    NRADJNRCELL-1:physCellId=48
...    NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
...    NRCELL/NRREL-5:cellIndividualSsbRsrpOffset=0dB
...    NRCELL/NRREL-5:cellIndividualSsbRsrqOffset=0dB
...    NRCELL/NRREL-5:gNbId=36
...    NRCELL/NRREL-5:gNbIdLength=22
...    NRCELL/NRREL-5:lcrId=1
...    NRCELL/NRREL-5:removeNotAllowed=false
...    NRCELL/NRREL-5:gnbPlmn:mcc=311|mncLength=3
...    NRCELL/NRREL-5:gnbPlmn:mnc=489|mncLength=3
...    delete:NRCELL/NRREL-5:sCellAdditionMethod

@{CB009109}
...    NRBTS:actDrbDrx=true
...    NRCELL-1:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-1
...    NRCELL-1:voNRNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-2
...    NRCELL-11:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-1
...    NRCELL-11:voNRNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-2
...    NRCELL-12:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-1
...    NRCELL-12:voNRNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-2
...    NRCELL-13:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-1
...    NRCELL-13:voNRNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-2
...    NRCELL-14:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-1
...    NRCELL-14:voNRNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-2
...    NRCELL-2:actCDrxVoNR=true
...    NRCELL-2:actEnhancedVoNR=true
...    NRCELL-2:actVoNR=true
...    NRCELL-2:maxNumScellsDlFr1=5
...    NRCELL-2:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-1
...    NRCELL-2:voNRNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-2
...    NRCELL-3:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-1
...    NRCELL-3:voNRNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-2
...    NRCELL-4:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-1
...    NRCELL-4:voNRNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-2
...    NRBTS/NRDRB-10:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-2
...    NRBTS/NRDRB-13:cellAggrLevel=FR1 CA incompatible
...    NRBTS-1:actDrbProfileForCellAggrLevel=FR1_SA
...    NRBTS/NRDRB-14:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-1
...    NRBTS/NRDRB-13:nrDrxDN=NRDRX-7
...    NRBTS/NRDRX-1:drxPriority=31
...    NRBTS/NRDRX-2:drxPriority=3
...    NRBTS/NRDRX-3:drxPriority=15
...    NRBTS/NRDRX-4:drxInactivityTimer=40ms
...    NRBTS/NRDRX-4:drxLongCycle=80ms
...    NRBTS/NRDRX-4:drxOnDurationTimer=10ms
...    NRBTS/NRDRX-4:drxPriority=16
...    NRBTS/NRDRX-5:drxInactivityTimer=10ms
...    NRBTS/NRDRX-5:drxLongCycle=20ms
...    NRBTS/NRDRX-5:drxOnDurationTimer=10ms
...    NRBTS/NRDRX-5:drxPriority=2
...    NRBTS/NRDRX-6:drxInactivityTimer=10ms
...    NRBTS/NRDRX-6:drxLongCycle=40ms
...    NRBTS/NRDRX-6:drxPriority=4
...    NRBTS/NRDRX-7:drxInactivityTimer=10ms
...    NRBTS/NRDRX-7:drxLongCycle=80ms
...    NRBTS/NRDRX-7:drxPriority=30

@{PARAMS_FOR_NRCELL1}
...    NRCELL-1/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-14:gNbId=1
...    NRCELL-1/NRREL-14:gNbIdLength=22
...    NRCELL-1/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-14:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-14:lcrId=14
...    NRCELL-1/NRREL-14:nrDcAllowed=false
...    NRCELL-1/NRREL-14:removeNotAllowed=false
...    NRCELL-1/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-14:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-14:isRplCellForPSCell=true
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-2/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=508110
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL:actOptimizedFlowControl=optimizedAllUe

@{PARAMS_FOR_NRCELL2}
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:nrDcAllowed=false
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:isRplCellForPSCell=true
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-3:gNbId=1
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-3:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-3:lcrId=3
...    NRCELL-2/NRREL-3:nrDcAllowed=false
...    NRCELL-2/NRREL-3:removeNotAllowed=false
...    NRCELL-2/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-3:isRplCellForPSCell=true
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-11:gNbId=1
...    NRCELL-2/NRREL-11:gNbIdLength=22
...    NRCELL-2/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-11:lcrId=11
...    NRCELL-2/NRREL-11:nrDcAllowed=false
...    NRCELL-2/NRREL-11:removeNotAllowed=false
...    NRCELL-2/NRREL-11:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-11:isRplCellForPSCell=true
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-12:gNbId=1
...    NRCELL-2/NRREL-12:gNbIdLength=22
...    NRCELL-2/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-12:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-12:lcrId=12
...    NRCELL-2/NRREL-12:nrDcAllowed=false
...    NRCELL-2/NRREL-12:removeNotAllowed=false
...    NRCELL-2/NRREL-12:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-12:isRplCellForPSCell=true
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-13:gNbId=1
...    NRCELL-2/NRREL-13:gNbIdLength=22
...    NRCELL-2/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-13:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-13:lcrId=13
...    NRCELL-2/NRREL-13:nrDcAllowed=false
...    NRCELL-2/NRREL-13:removeNotAllowed=false
...    NRCELL-2/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-13:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-13:isRplCellForPSCell=true

${B011_5QI5_DRX_Change}
...    NRBTS/NRDRB-14:nrDrxDN=NRDRX-7

${B011_Recover}
...    NRBTS/NRDRB-14:nrDrxDN=NRDRX-1

${ue_capa_6cc}    SEPARATOR=
...    FFA0F200475F7A6B5F8382086000D0017700400404820F990406902600C7FFE000503E0300C07012A1F851BF30342A08A5965440D00BDFF98
...    1C81B7FFDBFFEDFFF6FFFB7FFDBFFEDFFF3FFFD3FFEF8FCFC3FE3FFDBFFEDFFF6FFFB7FFDBFFEDFFF6FFFA8C026FF3FF6FF3FF16A00028015
...    B300078003300078000150FC41DF981A150452CB2A206805EFFCC0E40DBFFEDFFF6FFFB7FFDBFFEDFFF6FFF9FFFE9FFF7C7E7E1FF1FFEDFFF
...    6FFFB7FFDBFFEDFFF6FFFB7FFD460137F9FFB7F9FF8B50001400AD98003C00198003C0000A87E26EFCC0D0A82296595103402F7FE607206DF
...    FF6FFFB7FFDBFFEDFFF6FFFB7FFCFFFF4FFFBE3F3F0FF8FFF6FFFB7FFDBFFEDFFF6FFFB7FFDBFFEA3009BFCFFDBFCFFC5A8000A0056CC001E
...    000CC001E0000541F0637E606854114B2CA881A017BFF3039036FFFB7FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FFB7FFDBFFEDF
...    FF6FFFB7FFDBFFEDFFF51804DFE7FEDFE7FE2D40005002B66000F00066000F00002A0F88DBF30342A08A5965440D00B5FF981C81B7FFDBFFE
...    DFFF6FFFB7FFDBFFEDFFF3FFFD3FFEF8FCFC3FE3FFBBFFEDFFF6FFFB7FFDBFFEDFFF518026FF3FF6FF3FF16A00028015B3000780033000780
...    00008A2F13400389A001C28000E20800710400388C000000ADF8000000010389A000007F80000000A2F060003882001C41000E23000713400
...    389A000008ADF80000000513850001C41000E23000713400303800032B27800050062026C046174002F02409F81FEBDB813F03FD7B7027E07
...    FAF6E041C0FF5ED8090418C631FBFFFFF0BC00F800F000C0705807800703F09801E001806BB82C02C00380D77058058007020010000000800
...    4000000DE00C88000001644000002A00B066F2A68064F000029659427800054B2CA1200004A5965490000352CB2A01A8345D2A8AA557541AE
...    80650100400804010020100400804008010100200404008010008020065010020040400801010020040400801010040080401002004802005
...    00200600400C01002801000168250

@{measGap_setup_drx_release}
...    gapFR1 setup
...    drx-Config release : NULL
...    eventId eventA1
...    eventId eventA3

@{measGap_release_DRX7_Setup}
...    gapFR1 release : NULL
...    eventId eventA2
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms10
...    drx-LongCycleStartOffset ms80

@{VONR_setup}
...    QoS Routing Table
...    fiveQi 1 qfi 2

@{measGap_release_DRX7_Setup_release_DRX2_Setup}
...    gapFR1 release : NULL
...    eventId eventA2
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms20
...    drx-LongCycleStartOffset ms40

@{5QI8_DRX-7_&_scell_release}
...    Created FiveQi:Qfi mapping fiveQi 8 qfi 2
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms10
...    drx-LongCycleStartOffset ms80
...    sCellToReleaseList

@{5QI5_DRX-1_&_scell_add}
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms80
...    drx-LongCycleStartOffset ms160
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone
...    SCellIndex 5 activated successfully at airphone

*** Test Cases ***
CB009109-5G-ET_B011_nonGbrDrx_should_be_reinstalled_after_measGapSetupAndRelease_when_actDrbDrx_true
    [Documentation]
    ...    precondition : 5QI5-DRB10-DRX1,5QI1_DRB15_DRX2
    ...    1. The purpose of this test case is to check following scenarios:
    ...    nonGBR DRX can be installed again after measGap setup and release.
    ...    2. Test Case Steps:
    ...    Step 1: UE register and attach to cell-1 with 5QI-5 bearer setup => NRDRB_5QI[a1]->NRDRB[b1]->nrDrxDN = NRDRX-1.
    ...    Step 2: Add new FR1 CA incompatible DRB with 5QI-8 => NRDRB_5QI[a1] -> NRDRB[b1] -> nrDrxDN = NRDRX-7.
    ...    Step 3: Drop 5QI-8.
    ...    Step 4: UE reports A2 for interFreq handover measurement.
    ...    Step 5: online change DRX profile for SA call 5QI-5 (nonGBR) => NRDRB_5QI[a1]->NRDRB[b1]->nrDrxDN = NRDRX-1 to NRDRX-7.
    ...    Step 6: UE reports A1 to cancel measGap.
    ...    Step 7: UE reports A2 to trigger measGap.
    ...    Step 8: add 5QI-1.
    ...    Step 9: UE reports A1 to cancel measGap.
    ...    3. Expect Result
    ...    Step 1: UE attached and bearer 5QI-5 setup, and nonGBR DRX profile NRDRX-1 is installed for the UE. Event A2 is configured to UE.
    ...    Step 2: 5QI-8 added successfully and scells are released, NRDRX-1 is uninstalled and NRDRX-7 is installed 
    ...            (NRDRX[1].drxPriority = 31<NRDRX[7].drxPriority = 30).
    ...    Step 3: 5QI-8 dropped successfully and scells are added again, NRDRX-7 is uninstalled and NRDRX-1 is installed.
    ...    Step 4: A1 and A3 are configured to UE, measGap setup and NRDRX-1 released.
    ...    Step 5: nrDrxDN online changed successfully.
    ...    Step 6: A2 is configured to UE, measGap released and NRDRX-7 setup.
    ...    Step 7: A1 and A3 are configured to UE, measGap setup and NRDRX-7 released.
    ...    Step 8: 5QI-1 bearer added successfully.
    ...    Step 9: A2 is configured to UE, measGap released and NRDRX-2 is installed.
    [Tags]    QC_46914    B011
    SA UE Register and PDU Session Setup with blind CA     ue_id=1    ue_nr_capabilities=${ue_capa_6cc}
    UE PDU Session Modify to Add    qosflows=4    pass_regexp=${5QI8_DRX-7_&_scell_release}
    UE PDU Session Modify to Del    qosflows=4    pass_regexp=${5QI5_DRX-1_&_scell_add} 
    Pcell A2 report to trigger measgap setup
    OnlineParamChange    ${B011_5QI5_DRX_Change}
    Pcell A1 report to trigger measGap Release
    Pcell A2 report to trigger measgap setup
    Setup VONR Call
    Pcell A1 report to trigger measGap Release    pass_regexp=${measGap_release_DRX7_Setup_release_DRX2_Setup}
    [Teardown]    B011 Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/8cells_4T4F_2N78_2N41_2N66_N71_N25
	
B011 Teardown
    OnlineParamChange    ${B011_Recover}
    Common Test Teardown And Stop Capture Logs

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=6
    Update Cfg    set_qosflow id=2 5qi=5 default=on
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=8
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 qos_flows=4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1 
	
SA UE Register and PDU Session Setup with blind CA
    [Arguments]    ${ue_id}=1    ${ue_nr_capabilities}=${ue_capa_6cc}    ${target_cell}=2    ${fiveQi}=5
    Execute Egate Command    qosflow_modify default=on qos_flow=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cell}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
    ...    Received REGISTRATION COMPLETE from UE
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}
    ...    pass_regexp=${5QI5_DRX-1_&_scell_add}
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi 1

UE PDU Session Modify to Add
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qosflows}=2    ${pass_regexp}=${EMPTY}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows} by=amf    pass_regexp=${pass_regexp}

UE PDU Session Modify to Del
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qosflows}=3    ${pass_regexp}=${EMPTY}
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=${qosflows} by=amf
    ...    pass_regexp=${pass_regexp}
    Should Contain    ${ret1}    Removed FiveQi:Qfi mapping fiveQi 8 qfi 2

Pcell A2 report to trigger measgap setup
    [Arguments]    ${ue_id}=1    ${carrierfreq}=635616
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11    ${measGap_setup_drx_release}
	
Pcell A1 report to trigger measGap Release
    [Arguments]    ${ue_id}=1    ${carrierfreq}=635616    ${pass_regexp}=${measGap_release_DRX7_Setup}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1    threshold=65
    ${A1_measGap_release}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=60 event=A1 srsrp_nr=80 srsrq_nr=40
    Execute Egate Command    ${A1_measGap_release}    ${pass_regexp}
	
Setup VONR Call
    [Arguments]    ${pdu}=1    ${fiveQi}=1    ${ue_id}=1
    Execute Egate Command    qosflow_modify default=on qos_flow=3
    ${ret}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=3 by=amf
    ...                      pass_regexp=${VONR_setup}
    Should Not Contain    ${ret}    drx
