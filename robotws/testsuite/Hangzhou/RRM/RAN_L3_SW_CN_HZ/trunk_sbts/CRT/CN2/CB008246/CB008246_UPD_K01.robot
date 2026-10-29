*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-kexin.bao
...    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD     CRT    CB008246    release-SBTS24R1
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthUl:cRbStartUl=crb0
...    NRCELL:actDl256Qam=false
...    NRCELL:actUl256Qam=false
...    @{5QI_4_configuration}
...    @{2271_related_modification}
...    @{9189_related_modification}
...    @{8246_related_modification}
...    @{HO_flag}
...    @{NRCELL13_configuration}
...    @{NRCELL1_2_configuration}
...    @{NRCELL11_configuration}
...    @{CA_flag}

@{2271_related_modification}
...    NRCELL:actAdaptiveSr=true
...    NRCELL:adaptiveSrBlockingMinimization=20
...    NRCELL:adaptiveSrLoadThresholdDown=50
...    NRCELL:adaptiveSrLoadThresholdUp=80
...    NRCELL:srPeriodicityMin=slots20
...    NRCELL:srPeriodicity=slots40
...    NRCELL-1:srPeriodicity=slots80
...    NRCELL-2:srPeriodicityMin=slots10
...    NRCELL-1:srPeriodicityMin=slots10
...    NRCELL:vonrReservation=30
...    NRCELL-1:preferredVoNrSrPeriod=slots40
...    NRCELL-2:preferredVoNrSrPeriod=slots40
...    NRCELL-11:preferredVoNrSrPeriod=slots20
...    NRCELL-12:preferredVoNrSrPeriod=slots20
...    NRCELL-13:preferredVoNrSrPeriod=slots40
...    NRCELL-14:preferredVoNrSrPeriod=slots20
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true

@{9189_related_modification}
...    NRCELL:actServiceAwareConfig=true
#5qi=4
...    NRBTS/NRDRB-17:srPeriodicityDrb=40ms
...    NRBTS/NRDRB-17:payloadSizeSRDrb=500
#5qi=5
...    NRBTS/NRDRB-14:srPeriodicityDrb=80ms
...    NRBTS/NRDRB-14:payloadSizeSRDrb=300
#5qi=6
...    NRBTS/NRDRB-11:srPeriodicityDrb=80ms
...    NRBTS/NRDRB-11:payloadSizeSRDrb=100
#5qi=7
...    NRBTS/NRDRB-12:srPeriodicityDrb=10ms
...    NRBTS/NRDRB-12:payloadSizeSRDrb=100

@{8246_related_modification}
...    NRBTS/BWP_PROFILE-1/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-2/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-3/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciDedicatedAggregationLevelHR=AL4

...    NRBTS/NRPDCCHHRLA-1:pdcchHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qamLowSE=5
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPeriod=20
...    NRBTS/NRPDSCHHRLA-1:dllaBlerTargetHR=1
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qamLowSE=5
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPeriod=20
...    NRBTS/NRPDSCHHRLA-2:dllaBlerTargetHR=3
...    NRBTS/NRPDSCHHRLA-2:scalFactorForHRGbrDl=130
...    NRBTS/NRPUSCHHRLA-1:scalFactorForHRGbrUl=110

...    NRCELL:actCceSplit=false
...    NRCELL:actLAForHiReliab=true
...    NRCELL-2:actLAForHiReliab=false
...    NRCELL:scalingStepdownHREnabled=true
...    NRCELL:pdschHrLaConfig:dllaIniDeltaCqiHR=-50
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamLowSERANK1HR=28
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamLowSERANK2HR=28
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamLowSERANK3HR=28
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamLowSERANK4HR=28
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamRANK1HR=28
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamRANK2HR=28
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamRANK3HR=28
...    NRCELL:pdschHrLaConfig:dllaMcsMax64qamRANK4HR=28
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamLowSERANK1HR=28
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamLowSERANK2HR=28
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamRANK1HR=28
...    NRCELL:puschHrLaConfig:ullaMcsMax64qamRANK2HR=28
...    NRCELL:puschHrLaConfig:ullaSinrOffsetHR=20

#5qi-4
...    NRBTS/NRDRB-17:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
...    NRBTS/NRDRB-17:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS/NRDRB-17:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
#5qi-6
...    NRBTS/NRDRB-11:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
...    NRBTS/NRDRB-11:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
#5qi-7
...    NRBTS/NRDRB-12:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
#5qi-8
...    NRBTS/NRDRB-13:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
...    NRBTS/NRDRB-13:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS/NRDRB-13:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1

@{HO_flag}
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
@{CA_flag}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:sCellActivationMethod=blind
#for blind
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{NRCELL13_configuration}
...    NRCELL-13/NRCELL_FDD-1:nrarfcnDl=424000
...    NRCELL-13/NRCELL_FDD-1:nrarfcnUl=344000
...    NRCELL-13:gscnOrSsPbchArfcn=5300
...    NRCELL-13:a3MeasEnabled=rsrp
...    NRCELL-13:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-13:a3MeasSsbRsrp:a3OffsetSsbRsrp=2
...    NRCELL-13:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-13:absThreshSsbRsrpConsolidation=0
...    NRCELL-13:measGapSelectionSA=favourUeThroughput
...    NRCELL-13:sMeasConfigSsbRsrp=0
#...    NRCELL-13/NRREL-10:lcrId=11

@{NRCELL1_2_configuration}
...    NRCELL-1:gscnOrSsPbchArfcn=6351
...    NRCELL-1:nrarfcn=508020
...    NRCELL-2:gscnOrSsPbchArfcn=6549
...    NRCELL-2:nrarfcn=524310
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-2:actK1Opt=intra-gNB

@{NRCELL11_configuration}
...    NRCELL-11:a3MeasEnabled=rsrp
...    NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=2
...    NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-11:absThreshSsbRsrpConsolidation=0
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=20
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=70
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=50
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=40
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=26
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=80
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-11:sMeasConfigSsbRsrp=0
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:lcrId=13
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:nrDcAllowed=false
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
#NRCELL-1
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms80
...    NRCELL-11/NRHOIF-1:cellDepType=SA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssbFrequency=508110
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20

@{5QI_4_configuration}
...    NRCELL:actNonVoNRGbrService=true
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=4
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17
...    NRBTS/NRDRB-17:actDddsReduction=false
...    NRBTS/NRDRB-17:actLostPduFastRetx=false
...    NRBTS/NRDRB-17:discardTimer=300ms
...    NRBTS/NRDRB-17:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-17:dscp=28
...    NRBTS/NRDRB-17:l2OHFactorDl=16
...    NRBTS/NRDRB-17:l2OHFactorUl=35
...    NRBTS/NRDRB-17:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-17:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-17:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-17:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-17:maxTransferDelayGbr=20
...    NRBTS/NRDRB-17:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-7
...    NRBTS/NRDRB-17:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-17:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-17:numSduDiscard=1
...    NRBTS/NRDRB-17:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS/NRDRB-17:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-17:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-17:resType=GBR
...    NRBTS/NRDRB-17:rlcMode=RLC_AM
...    NRBTS/NRDRB-17:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-17:nsaDrbParam=${EMPTY}
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    NRBTS/NRDRB_MAC-5:lcgid=5
...    NRBTS/NRDRB_MAC-5:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-5:schedulBSD=50ms
...    NRBTS/NRDRB_MAC-5:schedulPrio=4
...    NRBTS/NRDRB_MAC-7:delayTarget=50
...    NRBTS/NRDRB_MAC-7:lcgid=5
...    NRBTS/NRDRB_MAC-7:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-7:schedulBSD=5ms
...    NRBTS/NRDRB_MAC-7:schedulPrio=7

${rdSrLoadThredsholdFactor}    0x59015B
@{PARAMS_IN_SWCONFIG}
...    ${rdSrLoadThredsholdFactor}=1

${UE_support_HR}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C9B0E7CC31E50B038260300C4700FB8D85181AC1184341020E90680
...    36B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B107582308682041E
...    20D00656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4DD608C21A08107
...    48340185B262A88873E238F11C7A067D813E31CF9863CA1607038782E007FE003801FF8002E0000702A0D88DAC1184341020F1
...    068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C00F78789A001C41000002
...    16020541E14000711800000858158788C001C41000006160561E14000710400000858158789A001C46000002160562E2300071
...    040038820000142C0AC3C28000E140000060B02B17134003882001C28000008160562E26800711800388C0000082C0AC5C2800
...    0E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E14000711800388C0000082C
...    0AC5C4D000E2300070A000002058158788C001C46000006160401C046805101360208BA005D83E14489B1CF870A244D8E7C385
...    1226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040
...    D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F417001E00140E0A00E06
...    01280380030120020301F048010000000080000100400000002000004010000040080000300400002002000014010008020080
...    20000180100000E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B0
...    32B066B056B296B266B016B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B2920200
...    00B2CA480800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA4806
...    69555D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C50B00BC04A8140A05028140A05028140A05028140
...    A05028140A000C10100C018040080108080100402018030804008010100C018040300608080600C02018030804008010100C01
...    8040080110080600C02018030080600C10100200804008021AA1F000102030406070A0B0C0D101112131418191B1C1D1F21252
...    62728292A2D2F414182D

*** Test Cases ***
CB008246_K_01_interworking_CA_DL_SA_Scell_deactivated_based_A1_UE_NOT_dynamic_betaoffset
    [Documentation]
    ...    1. HR DRB setup before/after Intra-GNB CA addition , FAF activated on pcell and deactivate on scell,IWK CB009189
    ...    2. Configuration
    ...    a.SA+NSA,TDD/FDD
    ...    b.UE81 which is capable of High Reliability , pcell NRCELL-11,scell NRCELL-2 , A1.
    ...      pcell NRCELL-1,scell NRCELL-2 , blind.
    ...    c.drb 5QI_7 is UL HR; drb 5QI_6 is DL HR; drb 5QI_4 is HR GBR.
    ...    3. Test Case Steps:
    ...    a.UE81 attach on NRCELL-11, setup VONR and 5QI_4.
    ...    b.trigger A2 A3 to make pcell change from NRCELL-11 to NRCELL-1
    ...    c.setup 5QI_6,and delete 5QI_4 and VONR.
    ...    d.release UE.
    [Tags]    QC_327355    owner-kexin.bao
    Update UE capa    ue_id=81    SA_Capa_perUE_Full=${UE_support_HR}
    UE Attach To Target Cell    ue_id=81    cell_id=11    regexp=periodicityAndOffset sl40
    Setup VONR And GBR Bearer Before HO    ue_id=81
    Trigger A1 To Add Scell    ue_id=81    carrierfreq=424090    regexp=sCellIndex 1
    Trigger Measurement to HO    ue_id=81    carrierfreq1=424090    carrierfreq2=508110    phycell_id=50
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.1    regexp=periodicityAndOffset sl40
    Bearer Operation After HO    ue_id=81
    UE Deregister From gNB    ue_id=81
    check wireshark log    ${CURDIR}${/}a2a_CB008246_UPDK01${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5 default=on
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}    ${regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    ${regexp}

Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}=81    ${qfi}=1    ${send_dl}=70    ${send_ul}=10    ${sleep_time}=10s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=${qfi} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=${qfi} dir=ul mbps=${send_ul}
    Verify Throuput    ${ue_id}    ${qfi}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger A1 To Add Scell
    [Arguments]    ${ue_id}    ${carrierfreq}    ${regexp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=70
    Execute Egate Command    ${cmd}    pass_regexp=${regexp}

Trigger A3 HO
    [Arguments]    ${ue_id}    ${carrierfreq}    ${sleep_time}    ${phycell_id}    ${pass_regexp}    ${regexp}
    sleep    ${sleep_time}    sleep for A3 MR
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=70
    ...    phycell_id=${phycell_id} nrsrp_nr=80
    ${retvalue}    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    Should Contain    ${retvalue}    ${regexp}

Trigger Measurement to HO
    [Arguments]    ${ue_id}    ${carrierfreq1}    ${carrierfreq2}    ${phycell_id}    ${pass_regexp}    ${regexp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq1}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=70 srsrq_nr=70    eventId eventA3
    Trigger A3 HO    ue_id=${ue_id}    carrierfreq=${carrierfreq2}    sleep_time=2s    phycell_id=${phycell_id}
    ...    pass_regexp=${pass_regexp}    regexp=${regexp}

Setup VONR And GBR Bearer Before HO
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=1 by=amf    pass_regexp=Added QosFlow with QFI:2 5QI:1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=4 by=amf    pass_regexp=Added QosFlow with QFI:3 5QI:4
    Send And Verify Throuput    ue_id=${ue_id}    qfi=1    send_dl=10    send_ul=5    sleep_time=10s

Bearer Operation After HO
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=6 by=amf    pass_regexp=Added QosFlow with QFI:4 5QI:6
    Send And Verify Throuput    ue_id=${ue_id}    qfi=4    send_dl=10    send_ul=5    sleep_time=10s
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=4 by=amf    pass_regexp=QoS Routing Table :
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=1 qosflows_to_add=7 by=amf    pass_regexp=sl20
