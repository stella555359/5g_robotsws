*** Settings ***
Suite Setup       Common Suite Setup And Setup IPHY Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BOO_AP_LOO
...               team-DevHZ5_SG1    owner-pei.han    release-SBTS23R2
Resource    ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}  ${True}
${GNB_CONFIG}    fddtdd_sansa_cmwv/4cells_2F2T
${BTS_STARTUP_RETRY}    2
@{PARAMS_IN_SWCONFIG}
...    @{rdULCaEnablerPhase}
...    @{rdUseOptimizedDpaAlgo}
...    @{W/A_for_PR659209}
@{rdULCaEnablerPhase}
...    0x580591=0
@{rdUseOptimizedDpaAlgo}
...    0x58056B=1
@{W/A_for_PR659209}
...    0x580307=0x5FE
@{PARAMS_IN_SCF}
...    @{CB006137}
...    @{CA}
...    @{NRREL}
...    @{Mobillity}
...    @{VONR}
...    @{Others}
...    @{gscn_Arfcn}
...    @{UlDftSOfdm}
...    @{T-put}
...    @{UlOpenLoopPwr}
...    @{CDRX}
${carrierAggregationSupportList}    SEPARATOR=
...    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa,
...    ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Nsa
@{CB006137}

...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList}
...    NRBTS/NRDU-1:dlToUlContributionRatio=50
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL:timingAdvanceOffset=n25600
@{T-put}
...    NRCELL:actUl256Qam=false
@{UlOpenLoopPwr}
...    NRCELL:ulPowerControlCommon:actUlOpenLoopPwrCtrl=true
...    NRCELL-1:pMaxNROwnCell=23
...    NRCELL-2:pMaxNROwnCell=26
@{gscn_Arfcn}
...    NRCELL-2:nrarfcn=518598
...    NRCELL-2:gscnOrSsPbchArfcn=6483
...    NRCELL-2:chBw=20MHz
...    NRCELL-4:nrarfcn=636666
...    NRCELL-4:gscnOrSsPbchArfcn=7880
...    NRCELL-4:chBw=60MHz
...    NRCELL-1/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-1/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL-1/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-1/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-1:gscnOrSsPbchArfcn=1587
...    NRCELL-3/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-3/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL-3/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-3/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-3:gscnOrSsPbchArfcn=1587
@{Others}
...    NRBTS:actMultiDrbNSA=true
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:tWaitingRlRecover=4000ms
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS/NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=10
@{CA}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:actK1Opt=intra-gNB
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:actBcsCheck=disabled
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=60
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=40
...    NRCELL:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=50
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=60
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=2560ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
@{NRREL}
...    NRCELL-1/NRREL-10:gNbId=2
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:lcrId=2
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-10:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=518670
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-1/NRREL-1:gNbId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=3
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-10:gNbId=2
...    NRCELL-3/NRREL-10:gNbIdLength=22
...    NRCELL-3/NRREL-10:lcrId=2
...    NRCELL-3/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-10:sCellOperationalMode=dlAndUl
...    NRCELL-3/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-3/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-3/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-3/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-3/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-3/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-3/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-3/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-3/NRHOIF-1:ssbFrequency=518670
...    NRCELL-3/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-3/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-3/NRREL-1:gNbId=2
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:lcrId=1
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
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
...    NRBTS:cipherPrefL:nea3_128=8
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
...    NRCELL:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
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
...    NRADJNRCELL-1:nrarfcn=126900
...    NRADJNRCELL-1:ssbFrequency=126990
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
@{VONR}
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRBTS/NRDRB-15:discardTimer=100ms
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-2/NRBTS-2/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-2/NRBTS-2/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=${EMPTY}
...    NRBTS/NRDRB-15:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-15
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_PDCP-3:maxCidAllowed=${EMPTY}
...    NRBTS/NRDRB_PDCP-3:xxFlowControlProfForCuIdx=${EMPTY}
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50
@{UlDftSOfdm}
...    NRBTS/NRCELL-2:actUlDftSOfdm=true
...    NRBTS/NRCELL-2:ulPtrs:actUlPtrs=true
...    NRBTS/NRCELL-2:ulTransPrecodeCtl:ulTransPrecodePi2Bpsk=true
...    NRBTS/NRCELL-2:ulTransPrecodeCtl:ulTransPrePi2BpskPwrBoost=true
...    NRBTS/NRCELL-2:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb0=1
...    NRBTS/NRCELL-2:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb1=36
...    NRBTS/NRCELL-2:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb2=36
...    NRBTS/NRCELL-2:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb3=270
...    NRBTS/NRCELL-2:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb4=270
@{CDRX}
...    NRCELL:actCDrx=false
...    NRCELL:actCDrxVoNR=false
...    NRCELL:drxProfile1:drxInactivityTimer=80ms|drxRetransTimerUl=0slot
...    NRCELL:drxProfile1:drxLongCycle=160ms|drxRetransTimerUl=0slot
...    NRCELL:drxProfile1:drxOnDurationTimer=10ms|drxRetransTimerUl=0slot
...    NRCELL:drxProfile1:drxRetransTimerDl=0slot|drxRetransTimerUl=0slot
...    NRCELL:drxProfile2:drxInactivityTimer=10ms|drxRetransTimerUl=0slot
...    NRCELL:drxProfile2:drxLongCycle=40ms|drxRetransTimerUl=0slot
...    NRCELL:drxProfile2:drxOnDurationTimer=6ms|drxRetransTimerUl=0slot
...    NRCELL:drxProfile2:drxRetransTimerDl=0slot|drxRetransTimerUl=0slot
${ue_nr_capabilities_01_01}    SEPARATOR=
...    F9A0700047D0FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C160145B25AA0581
...    3E439F40478C73E618F28581C0E1E0A4FF93FE284003650000500000379C10403DEF5B8683228107000003AE0B00A2D92D502C09F21CFA023
...    C639F30C7942C0E070F066F3823007BDEB70D0645020E0000075C160145B25AA05813E439F40478C73E618F28581C0E1E0DDE7C2800F7BD6E
...    1A0C8A041C00000EB82C028B64B540B027C873E808F18E7CC31E50B0381C3C189FF27FC508006CA0000A000000950785000184D0000048158
...    70500713400000848150788C0018280001048150708C070A000001848100385000001141E230006134000A120561C2301C4D00000C120541E
...    2300071340000384C0541E2300070A00000404C0401C028809B010602308A0194130A74ED8E7C3853A76C73E1C29D3B639F0E14E9DB1CF870
...    276C73E1C29D3B639F0E14E9DB1CF870A74ED8E7C3841B1CF8603C246318C06318C7F00000026007C005638280381F84800E06000C001F010
...    E5A00000E00E5A00002E00E5A00004E00E5A00006E00E5A00008E00046505E54560656525606500C180000018000600005060001800020180
...    0060000C060000372882F95415C0E0AE530509008802783C1E0F0780002020200400808020001010020000401002080803006020040004040
...    1800010020040020100204040280301004000202014000080200410500A00E00C01C02803050020060100240100208080500602004008D403
...    80010203038D9293927814060148
${ue_nr_capabilities_01_02}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C160145B25AA0581
...    3E439F40478C73E618F28581C0E1E0A4FF93FE284003650000500000379C10403DEF5B8683228107000003AE0B00A2D92D502C09F21CFA023
...    C639F30C7942C0E070F066F3823007BDEB70D0645020E0000075C160145B25AA05813E439F40478C73E618F28581C0E1E0DDE7C2800F7BD6E
...    1A0C8A041C00000EB82C028B64B540B027C873E808F18E7CC31E50B0381C3C189FF27FC508006CA0000A000000950785000184D0000048158
...    70500713400000848150788C0018280001048150708C070A000001848100385000001141E230006134000A120561C2301C4D00000C120541E
...    2300071340000384C0541E2300070A00000404C0401C028809B010602308A0194130A74ED8E7C3853A76C73E1C29D3B639F0E14E9DB1CF870
...    276C73E1C29D3B639F0E14E9DB1CF870A74ED8E7C3841B1CF8603C246318C06318C7F00000026007C005638280381F84800E06000C001F010
...    E5A00000E00E5A00002E00E5A00004E00E5A00006E00E5A00008E00046505E54560656525606500C180000018000600005060001800020180
...    0060000C060000372882F95415C0E0AE530509008802783C1E0F0780002020200400808020001010020000401002080803006020040004040
...    1800010020040020100204040280301004000202014000080200410500A00E00C01C02803050020060100240100208080500602004008D403
...    80010203038D9293927814060148
${ue_nr_capabilities_09}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C160145B25AA0581
...    3E439F40478C73E618F28581C0E1E0A4FF93FE284003650000500000379C10403DEF5B8683228107000003AE0B00A2D92D502C09F21CFA023
...    C639F30C7942C0E070F066F3823007BDEB70D0645020E0000075C160145B25AA05813E439F40478C73E618F28581C0E1E0DDE7C2800F7BD6E
...    1A0C8A041C00000EB82C028B64B540B027C873E808F18E7CC31E50B0381C3C149FF27FC508006CA0000A000000950785000184D0000048158
...    70500713400000848150788C0018280001048150708C070A000001848100385000001141E230006134000A120561C2301C4D00000C120541E
...    2300071340000384C0561E2300070A00000404C0401C028809B010602308A0194130A74ED8E7C3853A76C73E1C29D3B639F0E14E9DB1CF870
...    276C73E1C29D3B639F0E14E9DB1CF870A74ED8E7C3841B1CF8603C246318C06318C7F00000026007C005638280381F84800E06000C001F010
...    E5A00000E00E5A00002E00E5A00004E00E5A00006E00E5A00008E00046505E54560656525606500C180000018000600005060001800020180
...    0060000C060000372882F95415C0E0AE530509008802783C1E0F0780002020200400808020001010020000401002080803006020040004040
...    1800010020040020100204040280301004000202014000080200410500A00E00C01C02803050020060100240100208080500602004008D403
...    80010203038D9293927814060148
${ue_nr_capabilities_12_01}    SEPARATOR=
...    F9A0700047D0FFA17DF8E6BC32001A0349CF9A44F3F8048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C160145B25AA0581
...    3E439F40478C73E618F28581C0E1E0A4FF93FE284003650000500000379C10403DEF5B8683228107000003AE0B00A2D92D502C09F21CFA023
...    C639F30C7942C0E070F066F3823007BDEB70D0645020E0000075C160145B25AA05813E439F40478C73E618F28581C0E1E0DDE7C2800F7BD6E
...    1A0C8A041C00000EB82C028B64B540B027C873E808F18E7CC31E50B0381C3C189FF27FC508006CA0000A000000950785000184D0000048158
...    70500713400000848150788C0018280001048150708C070A000001848100385000001141E230006134000A120561C2301C4D00000C120541E
...    2300071340000384C0541E2300070A00000404C0401C028809B010602308A0194130A74ED8E7C3853A76C73E1C29D3B639F0E14E9DB1CF870
...    276C73E1C29D3B639F0E14E9DB1CF870A74ED8E7C3841B1CF8603C246318C06318C7F00000026007C005638280381F84800E06000C001F010
...    E5A00000E00E5A00002E00E5A00004E00E5A00006E00E5A00008E00046505E54560656525606500C180000018000600005060001800020180
...    0060000C060000372882F95415C0E0AE530509008802783C1E0F0780002020200400808020001010020000401002080803006020040004040
...    1800010020040020100204040280301004000202014000080200410500A00E00C01C02803050020060100240100208080500602004008D403
...    80010203038D9293927814060148
${ue_nr_capabilities_12_02}    SEPARATOR=
...    F9A0700047D0FFA17DF8E6BC32001A0349CF9A44F3F8048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C160145B25AA0581
...    3E439F40478C73E618F28581C0E1E0A4FF93FE284003650000500000379C10403DEF5B8683228107000003AE0B00A2D92D502C09F21CFA023
...    C639F30C7942C0E070F066F3823007BDEB70D0645020E0000075C160145B25AA05813E439F40478C73E618F28581C0E1E0DDE7C2800F7BD6E
...    9A0C8A041C00000EB9000002D3A000783C3E3F0B00A2D92D502C09F21CFA023C639F30C7942C0E070F0627FC9FF142001B280002800000254
...    1E1400061340000120561C1401C4D000002120541E2300060A00004120541C2301C28000006120400E1400000450788C00184D00028481587
...    08C0713400003048150788C001C4D00000E130150788C001C28000010130100700A2026C041808C22806504C29D3B639F0E14E9DB1CF870A7
...    4ED8E7C3853A76C73E1C09DB1CF870A74ED8E7C3853A76C73E1C29D3B639F0E106C73E180F0918C63018C631FC0000009801F00158E0A00E0
...    7E120038180030007C043968000038039680000B803968000138039680001B803968000238001194179515819594958194030600000060001
...    80001418000600008060001800030180000DCA20BE550570382B94C1424022009E0F0783C1E00008080801002020080004040080001004008
...    20200C0180801000101006000040080100080400810100A00C0401000080805000020080104140280380300700A00C1400801804009004008
...    20201401808010023500E0004080C0E364A4E49E0501805200
@{OnlineParam_ET_12_01}
...    NRBTS/NRCELL-2:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb0=1
@{OnlineParam_ET_12_02}
...    NRBTS/NRCELL-2:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb0=277
@{OnlineParam_ET_12_03}
...    NRBTS/NRCELL-2:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb0=278

*** Test Cases ***
CB006137-AC_ET_01_01_VONR call setup after UL CA configure
    [Documentation]
    ...    This case is to verify 5G_CP_IF_RRC_8588:
    ...    VONR interwork with ULCA.
    [Tags]    QC_xxxxxx     217886
    SA UE Register and PDU Session Setup and Scell Addition    ue_id=1    ue_nr_capabilities=${ue_nr_capabilities_01_01}
    ...    sCellIndex=1
    VoNR Call without lch-ToSCellRestriction
    Scell release and Verify Throughput
    UE Deregister From GNB
    SA UE Register and PDU Session Setup and Scell Addition    ue_id=2    ue_nr_capabilities=${ue_nr_capabilities_01_02}
    ...    sCellIndex=1
    VoNR Call with lch-ToSCellRestriction    ue_id=2
    Scell release and Verify Throughput    ue_id=2
    Check RRC Log    ${CURDIR}${/}a2a_CB006137-AC_ET_01${/}a2a.ini
    [Teardown]    Test Case Teardown

CB006137-AC_ET_08_01_Measurement gap setup and release for UL CA UE when covBasedA1 CA addition
    [Documentation]
    ...    This case is to verify:
    ...    Measurement gap interwork with ULCA.
    [Tags]    QC_xxxxx     217883
    SA UE Register and PDU Session Setup and Scell Addition    ue_id=1    ue_nr_capabilities=${ue_nr_capabilities_01_01}
    ...    sCellIndex=1
    Start Traffic
    Verify Throughput for Specific Scell for ULCA    Target_0=26    Target_1=11.5
    Pcell A2 report to trigger Measurement Gap
    Verify Throughput for Specific Scell for ULCA with MG
    Scell release and Verify Throughput with MG
    Pcell A1 report to trigger Scell Addition
    Verify Throughput for Specific Scell for ULCA with MG
    [Teardown]    Test Case Teardown

CB006137-AC_ET_09_01_UL CA configured for intra and inter gNB incoming handover when intra frequency handover
    [Documentation]
    ...    This case is to verify:
    ...    ULCA interwork with HO.
    [Tags]    QC_xxxxxx    217882
    SA UE Register and PDU Session Setup and Scell Addition    ue_id=1    ue_nr_capabilities=${ue_nr_capabilities_09}
    ...    sCellIndex=1
    UE PDU Session Modify to Add VONR Call
    Intra-gNB intra-F HO and Optimization Scell Add
    Inter-gNB HO to Sim gNB
    Inter-gNB HO to Real gNB and Optimization Scell Add
    Check RRC Log    ${CURDIR}${/}a2a_CB006137-AC_ET_09${/}a2a.ini
    [Teardown]    Test Case Teardown

CB006137-AC_ET_12_01_Configuration of sample density thresholds of Scell for ULCA
    [Documentation]
    ...    This case is to verify 5G_CP_ARC_ALG_7789:
    ...    sample density of Scell for UEs with different UL capabilities.
    [Tags]    QC_xxxxxxx    217875
    OnlineParamChange    ${OnlineParam_ET_12_01}
    SA UE Register and PDU Session Setup and Scell Addition    ue_id=1    ue_nr_capabilities=${ue_nr_capabilities_12_01}
    ...    sCellIndex=1
    OnlineParamChange    ${OnlineParam_ET_12_02}
    SA UE Register and PDU Session Setup and Scell Addition    ue_id=2    ue_nr_capabilities=${ue_nr_capabilities_12_01}
    ...    sCellIndex=1
    OnlineParamChange    ${OnlineParam_ET_12_03}
    SA UE Register and PDU Session Setup and Scell Addition    ue_id=3    ue_nr_capabilities=${ue_nr_capabilities_12_01}
    ...    sCellIndex=1
    SA UE Register and PDU Session Setup and Scell Addition    ue_id=4    ue_nr_capabilities=${ue_nr_capabilities_12_02}
    ...    sCellIndex=1
    Check RRC Log    ${CURDIR}${/}a2a_CB006137-AC_ET_12${/}a2a.ini
    [Teardown]    Test Case Teardown

*** Keywords ***
Common Suite Setup And Setup IPHY Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB_CONFIG}
    Execute Egate Command    debug_log level=4
    Execute Egate Command    sim_debug_log level=4

Modify Cfg
    Update Cfg    mme_pool_area id=1 mmegi=1 plmn=311:489 eq_plmn=250:255 tac_list=777,111,222,444,333,200
    Update Cfg    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    ${Update_Cfg_1}    catenate
    ...    set_cell id=2 enb=1 eci=0x1234602 pci=3:1 tac=222 proxy=10.0.2.1:12220|10.0.2.1:8890
    ...    earfcn=2000:20000 mandatory_for_activation=off
    Update Cfg    ${Update_Cfg_1}
    ${Update_Cfg_2}    catenate
    ...    set_enb id=11 plmn=250:255 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222 x2=10.0.1.127
    ...    x2u=10.0.1.137 type=simulated x2_peers=none
    Update Cfg    ${Update_Cfg_2}
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    ${Update_Cfg_3}    catenate
    ...    set_cell id=1 enb=11 eci=0x1234701 pci=7:2 tac=222 proxy=10.0.2.1:8887 earfcn=2000:20000
    ...    mandatory_for_activation=off
    Update Cfg    ${Update_Cfg_3}
    ${Update_Cfg_4}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 s1u=10.0.1.124 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222
    ...    x2=10.0.1.125:36422 x2_peers=none xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${Update_Cfg_4}
    Update Cfg    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=off proxy=10.0.2.92:9999 nr_arfcn=136100:126900 gscn=1587
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true
    Update Cfg    gnb_endc_param id=3 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0
    Update Cfg    gnb_param id=3 x2_listening_socket=1 measEvent=A3
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 qos_flows=3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=1-30 amf=1
    Update Cfg    ue_nr_capabilities id=1-30 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    ${Update_Cfg_7}    catenate    SEPARATOR=
    ...    ue_param id=1-30 nr_usage_setting=voice_centric ue_nr_capabilities=F9A0700047D0FFA17DF8E6BC32001A0349CF9A44F3
    ...    E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C160145B25AA05813E439F40478C73E618F28581C0E1E0A4FF93FE
    ...    284003650000500000379C10403DEF5B8683228107000003AE0B00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3823007BDEB
    ...    70D0645020E0000075C160145B25AA05813E439F40478C73E618F28581C0E1E0CDE702800F7BD6E1A0C8A041C00000EB82C028B64B540
    ...    B027C873E808F18E7CC31E50B0381C3C182541E1400061340000120561C1401C4D000002120541E2300060A00004120541C2301C28000
    ...    006120400E1400000450788C00184D0002848158708C0713400003048150788C001C4D00000E130150788C001C28000010130100500A2
    ...    026C04111403282614E9DB1CF870A74ED8E7C3853A76C73E1C29D3B639F0E04ED8E7C3853A76C73E1C29D3B639F0E14E9DB1CF8708363
    ...    9F0C07848C63180C6318FE0000004C00F800AC70500703F09001C0C0018003E021CB400001C01CB400005C01CB400009C01CB40000DC0
    ...    1CB400011C0008CA0BCA8AC0CACA4AC0CA018300000030000C0000A0C000300004030000C000180C00006E5105F2A82B81C15CA60A120
    ...    11004F0783C1E0F0000404040080101004000202004000080200410100600C04008000808030000200400800402004080805006020080
    ...    00404028000100400820A01401C018038050060A00400C0200480200410100A00C04008011A80700020406071B252724F0280C02900
    Update Cfg    ${Update_Cfg_7}
    FOR    ${SA_id}    IN RANGE    1    31
        Update Cfg    set_pdu_gateway id=${SA_id} ue_nat_ip=72.23.0.${SA_id} dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    END
    FOR    ${NSA_id}    IN RANGE    31    61
        Update Cfg    set_bearer id=3 ue=${NSA_id} qci=8 pdn=1 default=off
    END
    ${Update_Cfg_8}    catenate
    ...    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 x2=10.0.1.2:36422 ng=10.0.1.2 xn=10.0.1.2:38422
    ...    gnb_id=0x2:22 daemon=10.0.2.1:22222 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${Update_Cfg_8}

Set UE Parameters Before Attach
    [Arguments]    ${ue_id}=1    ${target_cell}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cell}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal

SA UE Register To GNB
    [Arguments]    ${ue_id}=1    ${ue_nr_capabilities}=${ue_nr_capabilities_01_01}}
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
    ...    Received REGISTRATION COMPLETE from UE

SA UE PDU Session Setup
    [Arguments]    ${pdu}=1    ${fiveQi}=6    ${ue_id}=1
    Start RRC Log    PDU_Session_Setup_${ue_id}
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${ue_id}
    ...    pass_regexp=QoS Routing Table
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi 1
    Get RRC Log

SA UE Register and PDU Session Setup
    [Arguments]    ${ue_id}=1    ${ue_nr_capabilities}=${ue_nr_capabilities_01_01}}
    SA UE Register To GNB    ue_id=${ue_id}    ue_nr_capabilities=${ue_nr_capabilities}
    SA UE PDU Session Setup    ue_id=${ue_id}

SA UE Register and PDU Session Setup and Scell Addition
    [Arguments]    ${ue_id}=1    ${ue_nr_capabilities}=${ue_nr_capabilities_01_01}}    ${target_cell}=1    ${sCellIndex}=1
    Set UE Parameters Before Attach    ue_id=${ue_id}    target_cell=${target_cell}
    SA UE Register and PDU Session Setup    ue_id=${ue_id}    ue_nr_capabilities=${ue_nr_capabilities}
    Pcell A1 report to trigger Scell Addition    ue_id=${ue_id}    sCellIndex=${sCellIndex}

UE Deregister From GNB
    [Arguments]    ${ue_id}=1
    FOR    ${ue_ids}    IN    @{ue_id.split(",")}
        Execute Egate Command    ue_deregister id=${ue_ids} ue_deregister_type=switch_off    detached
    END

UE PDU Session Modify to Add
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${fiveQi}=1    ${qfi}=2    ${qosflows_to_add}=2
    Start RRC Log    PDU_Session_Modify_to_Add_${ue_id}_${fiveQi}
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows_to_add} by=amf
    ...    pass_regexp=QoS Routing Table
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi ${qfi}
    Get RRC Log

UE PDU Session Modify to Add VONR Call
    [Arguments]    ${ue_id}=1    ${pdu}=1
    UE PDU Session Modify to Add    ue_id=${ue_id}    pdu=${pdu}    qosflows_to_add=2    fiveQi=5    qfi=2
    UE PDU Session Modify to Add    ue_id=${ue_id}    pdu=${pdu}    qosflows_to_add=3    fiveQi=1    qfi=3

UE PDU Session Modify to Del
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${fiveQi}=1    ${qfi}=3
    Start RRC Log    PDU_Session_Modify_to_Del_${ue_id}_${fiveQi}
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=${qfi} by=amf
    ...    rrcReconfigurationComplete
    Should Contain    ${ret1}    Removed FiveQi:Qfi mapping fiveQi ${fiveQi} qfi ${qfi}
    Get RRC Log

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Pcell A1 report to trigger Scell Addition
    [Arguments]    ${ue_id}=1    ${carrierfreq}=126990    ${phycell_id}=60    ${sCellIndex}=1    ${timetotrigger}=320
    Start RRC Log     Scell_Addition_UE_${ue_id}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ...    timetotrigger=${timetotrigger}
    ${A1_Scell_addition}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} event=A1
    ...    srsrp_nr=80 srsrq_nr=40
    ${ret1}=    Execute Egate Command    ${A1_Scell_addition}    scellIdx:${sCellIndex}
    Should Contain    ${ret1}    eventId eventA2
    Should Contain    ${ret1}    a2-Threshold rsrp : 34
    Should Contain    ${ret1}    sCellToAddModList
    Get RRC Log

Scell A2 report to trigger Scell Release
    [Arguments]    ${carrierfreq}=518670    ${ue_id}=1    ${scell_id}=1
    Start RRC Log     Scell_Release_${ue_id}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${A2_Scell_Release}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} scell=${scell_id} scell_rsrp=30 scell_rsrq=0 event=A2
    ${ret1}=    Execute Egate Command    ${A2_Scell_Release}    rrcReconfigurationComplete
    Should Contain    ${ret1}    eventId eventA1
    Should Contain    ${ret1}    sCellToReleaseList
    Get RRC Log

Pcell A2 report to trigger Measurement Gap
    [Arguments]    ${ue_id}=1    ${carrierfreq}=126990    ${phycell_id}=60
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${A2_MG}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} event=A2
    ...    srsrp_nr=30 srsrq_nr=40
    ${ret1}=    Execute Egate Command    ${A2_MG}    rrcReconfigurationComplete
    Should Contain    ${ret1}    eventId eventA1
    Should Contain    ${ret1}    measGapConfig

Intra-gNB intra-F HO and Optimization Scell Add
    [Arguments]    ${ue_id}=1    ${carrierfreq}=126990    ${Target_phycell_id}=61    ${sCellIndex}=1
    Start RRC Log     Intra_gNB_HO_OptimizationCa
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${Intra_gNB_HO_OptimizationCa}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=50 srsrq_nr=30
    ...    phycell_id=${Target_phycell_id} nrsrp_nr=70 nrsrq_nr=30
    ${ret1}=    Execute Egate Command    ${Intra_gNB_HO_OptimizationCa}    scellIdx:${sCellIndex}
    Should Contain    ${ret1}    eventId eventA2
    Should Contain    ${ret1}    a2-Threshold rsrp : 34
    Should Contain    ${ret1}    sCellToAddModList
    Get RRC Log

Inter-gNB HO to Sim gNB
    [Arguments]    ${ue_id}=1    ${carrierfreq}=126990    ${Target_phycell_id}=48
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    GNB-3: XnAP Link with GNB-2
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${Inter_gNB_HO_to_Sim_gNB}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=50 srsrq_nr=30
    ...    phycell_id=${Target_phycell_id} nrsrp_nr=70 nrsrq_nr=30
    ${ret1}=    Execute Egate Command    ${Inter_gNB_HO_to_Sim_gNB}    PATH_SWITCH_REQUEST_ACK Received
    Should Contain    ${ret1}    Inter-eNB handover from EXT_ENB-2.3 to ENB-3.1 performed

Inter-gNB HO to Real gNB and Optimization Scell Add
    [Arguments]    ${ue_id}=1    ${carrierfreq}=126990    ${Target_phycell_id}=60    ${sCellIndex}=1
    Start RRC Log     Inter_gNB_HO_to_real_gNB_OptimizationCa
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${Inter_gNB_HO_to_real_gNB_OptimizationCa}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=50 srsrq_nr=30
    ...    phycell_id=${Target_phycell_id} nrsrp_nr=70 nrsrq_nr=30
    ${ret2}=    Execute Egate Command    ${Inter_gNB_HO_to_real_gNB_OptimizationCa}    scellIdx:${sCellIndex}
    Should Contain    ${ret2}    eventId eventA2
    Should Contain    ${ret2}    a2-Threshold rsrp : 34
    Should Contain    ${ret2}    sCellToAddModList
    Get RRC Log

Start Traffic
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${mbps}=40
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=${qfi} dir=dl mbps=${mbps}    Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=${qfi} dir=ul mbps=${mbps}    Started Uplink Internal traffic

Start non-GBR and GBR Traffic
    [Arguments]    ${ue_id}=1
    Start Traffic    ${ue_id}    qfi=1    mbps=40
    Start Traffic    ${ue_id}    qfi=3    mbps=1

Verify Throughput for Specific QFI
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${direction}=ul    ${Target}=0
    ${throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=${direction}    rate_type=ave
    Should Be True    ${throughput}/1000>=${Target}

Verify Throughput for Specific Scell
    [Arguments]    ${ue_id}=1    ${Target_0}=0    ${type}=pusch
    ${throughput_0}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=${type}    rate_type=ave
    Should Be True    ${throughput_0}/1000>${Target_0}

Verify Throughput for Specific Scell for ULCA
    [Arguments]    ${ue_id}=1    ${Target_0}=0    ${Target_1}=0    ${type}=pusch    ${sleep_time}=10s
    Sleep    ${sleep_time}    sleep for Tput stable
    ${throughput_0}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=${type}    rate_type=ave
    ${throughput_1}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=${type}    rate_type=ave
    Should Be True    ${throughput_0}/1000>${Target_0}
    Should Be True    ${throughput_1}/1000>${Target_1}

Verify Throughput for Specific Scell for ULCA with MG
    [Arguments]    ${ue_id}=1    ${Target_0_L}=23    ${Target_0_H}=27    ${Target_1_L}=10    ${Target_1_H}=11.8    ${type}=pusch
    ...    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${throughput_0}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=${type}    rate_type=ave
    ${throughput_1}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=${type}    rate_type=ave
    Should Be True    ${Target_0_L}<${throughput_0}/1000<${Target_0_H}
    Should Be True    ${Target_1_L}<${throughput_1}/1000<${Target_1_H}

Verify Throughput for VONR Call without lch-ToSCellRestriction
    [Arguments]    ${ue_id}=1    ${Target_0}=0    ${Target_1}=0    ${type}=pusch    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${throughput_0}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=${type}    rate_type=ave
    ${throughput_1}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=${type}    rate_type=ave
    Should Be True    ${throughput_0}/1000>${Target_0}
    Should Be True    ${throughput_1}/1000==${Target_1}
    Verify Throughput for Specific QFI    qfi=1    Target=22
    Verify Throughput for Specific QFI    qfi=3    Target=0.8

VoNR Call without lch-ToSCellRestriction
    [Arguments]    ${ue_id}=1    ${sleep_time}=10s
    UE PDU Session Modify to Add VONR Call    ${ue_id}
    Start non-GBR and GBR Traffic    ${ue_id}
    Verify Throughput for VONR Call without lch-ToSCellRestriction    ${ue_id}    Target_0=24    Target_1=0
    UE PDU Session Modify to Del    ${ue_id}    qfi=3    fiveQi=1
    UE PDU Session Modify to Del    ${ue_id}    qfi=2    fiveQi=5
    Verify Throughput for Specific Scell for ULCA    ${ue_id}    Target_0=24    Target_1=11.5

VoNR Call with lch-ToSCellRestriction
    [Arguments]    ${ue_id}=2
    UE PDU Session Modify to Add VONR Call    ${ue_id}
    Start non-GBR and GBR Traffic    ${ue_id}
    Verify Throughput for Specific Scell for ULCA    ${ue_id}    Target_0=24    Target_1=11.5
    UE PDU Session Modify to Del    ${ue_id}    qfi=3    fiveQi=1
    UE PDU Session Modify to Del    ${ue_id}    qfi=2    fiveQi=5
    Verify Throughput for Specific Scell for ULCA    ${ue_id}    Target_0=24    Target_1=11.5

Scell release and Verify Throughput
    [Arguments]    ${carrierfreq}=518670    ${ue_id}=1    ${sleep_time}=10s
    Scell A2 report to trigger Scell Release    ${carrierfreq}    ${ue_id}
    sleep    ${sleep_time}    sleep for Tput stable
    Verify Throughput for Specific Scell    ${ue_id}    Target_0=24    type=pusch

Scell release and Verify Throughput with MG
    [Arguments]    ${carrierfreq}=518670    ${ue_id}=1    ${sleep_time}=10s
    Scell A2 report to trigger Scell Release    ${carrierfreq}    ${ue_id}
    sleep    ${sleep_time}    sleep for Tput stable
    Verify Throughput for Specific Scell    ${ue_id}    Target_0=23    type=pusch

Test Case Teardown
    Release UEs    ue_type=all
    Common Test Teardown And Stop Capture Logs

