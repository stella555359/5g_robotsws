*** Settings ***
Documentation
...    author:  susana.yan@nokia-sbell.com
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Blues_SGT&A    owner-ha.zheng
...    CLOUD_5G_I_BOO_AP_LOO    CB008290    release-5G23R1
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    NRCELL:actAperCsi=true
...    @{NRREL}
...    @{8290_enable}
...    @{2200_parameter}
...    @{PARAMS_FOR_5GC000772}
...    @{PARAMS_FOR_5GC002060}
...    @{PARAMS_FOR_5GC000884}
...    @{PARAMS_FOR_5GC001118_CB007797}
...    @{PARAMS_FOR_5GC001729}
...    @{bw}

@{NRREL}
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:nrRelId=1
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellPrio=2
...    delete:NRCELL-2/NRREL-1:sCellOperationalMode
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:lcrId=4
...    NRCELL-2/NRREL-2:nrRelId=2
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-2:sCellPrio=1
...    delete:NRCELL-2/NRREL-2:sCellOperationalMode
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlOnly
@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actNonBfAndBfCa=true
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:actCDrx=false
...    NRCELL:actDl256Qam=false

...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=infinity
...    NRCELL:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=480ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=5|a2TimeToTriggerSCellRelSsbRsrq=480ms
...    NRCELL-1:weightForSCellSelection=50
...    NRCELL-4:weightForSCellSelection=50
...    NRCELL-3:weightForSCellSelection=50
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL-1:actProactUlSchedulingEnh=disabled
...    NRCELL-2:actProactUlSchedulingEnh=disabled
...    NRCELL-3:actProactUlSchedulingEnh=disabled
...    NRCELL-4:actProactUlSchedulingEnh=disabled

@{bw}
...    MRBTS-1/NRBTS-1/NRCELL-1:chBw=40MHz
...    MRBTS-1/NRBTS-1/NRCELL-2:chBw=40MHz
...    MRBTS-1/NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=7912
...    MRBTS-1/NRBTS-1/NRCELL-3:chBw=40MHz
...    MRBTS-1/NRBTS-1/NRCELL-3:gscnOrSsPbchArfcn=7981
...    MRBTS-1/NRBTS-1/NRCELL-4:chBw=40MHz
...    NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96

@{2200_parameter}
...    NRCELL-2:actBeamforming=true
...    NRCELL-2:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
#...    NRCELL-2:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL-2:nrCellType=8DL4UL
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=2
...    NRCELL-2:periodicCsiAcquisition:csirsPower=6
...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL-2:beamSet:basicBeamSet=beamSet_4
...    NRCELL-2:beamSet:leftEdgeAngle=60
...    NRCELL-2:beamSet:lowerEdgeAngle=120
...    NRCELL-2:beamSet:rightEdgeAngle=60
...    NRCELL-2:beamSet:upperEdgeAngle=60
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=4 beams
...    NRCELL-1:actBeamforming=true
...    NRCELL-1:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
#...    NRCELL-1:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL-1:nrCellType=8DL4UL
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-1:periodicCsiAcquisition:csirsPower=5
...    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL-1:beamSet:basicBeamSet=beamSet_4
...    NRCELL-1:beamSet:leftEdgeAngle=60
...    NRCELL-1:beamSet:lowerEdgeAngle=120
...    NRCELL-1:beamSet:rightEdgeAngle=60
...    NRCELL-1:beamSet:upperEdgeAngle=60
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
...    NRCELL-4:actBeamforming=false
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-3:nrCellType=4DL4UL
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
#...    NRCELL-4:mMimoAntArrayMode=Full 64TRX Array (4x8x2)
...    NRCELL-4:nrCellType=4DL4UL
...    NRCELL-4:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    NRBTS:actChannelMapVal=Disabled
...    NRCELL-1:numberOfRxBeamforming=4Rx
...    NRCELL-2:numberOfRxBeamforming=4Rx

${SA_Capa_Support_B018}    SEPARATOR=
...    E9A09000575F5A13160003C328016008000004000044230093170019C3D09009B20C39F21CF942C0E098040623807DC6C28C0D608C21A08107482406
...    D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC0
...    9F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000044000702B8D89BAC1184341020E90480AAD931561442321C78C08E3C073E639F78
...    583C0E1E017003FF001C00FFC00110001C0AE3E236B04610D04083E50480AAD931561439F11C78C00000000000000000040E1E027FFC00001FFF0000
...    0110001C01078789A001C4100000216020541E14000711800000858158788C001C41000006160561E14000710400000858158789A001C46000002160
...    562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26800711800388C0000082C0AC5C28000E20800
...    711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E14000711800388C0000082C0AC5C4D000E2300070A000002
...    058158788C001C46000006160563E26800713400389A001C4D00000E160401C0468051013602086B0C908428913639F0E14489B1CF870A244D8E7C38
...    51226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1
...    CF811204081B1CF810A040D8E7C08D0204081B3DFB6191018C6318C6318C6318C63010107043406200040018000D0188001000600034062000400180
...    00C018800100060003406200040018000D0288800100060003406200040018000D028880010006000340A2200040018000D028880010006000340A22
...    00040018000D028880010006000340A2200040018000D0288800100060003406200040018000D038888001000600001E8260078005038280381804A0
...    0E000C0480080C07C120040000000200000401000000008000010040000100200000C010000080080000500400200802008000060040000380200100
...    00000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA06
...    82000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000
...    152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142405E02540A050
...    28140A05028140A05028140A05028140A05000708080600C02004008404008020100C018402004008080600C02018030404030060100C01840200400
...    8080600C02004008804030060100C018040300608080100402004010C0400802010020080400802010020086A87C0004080C10181C282C3034404448
...    4C5060646C70747C8494989CA0A4A8B4BD05060B40

${SA_Capa_Support_B019}    SEPARATOR=
...    E9A09000575F5A13160003C42800580200000100001108C024C5C00670F424026C830E7C873E50B038260300C4700FB8D85181AC1184341020E90680
...    36B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CF
...    B027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000001700003815C6C4DD608C21A0810748340155B262AC2852E438F1811C780E7CC7
...    3EF0B0781C3C02E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C00000000000000000040E1E027FFC00001FF
...    F0000017000038020F0F1340038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E208000010B02B0F13400388C000
...    0042C0AC5C46000E208007104000028581587850001C4D00000C160562E2680071040038500000102C0AC5C4D000E23000711800001058158B850001
...    C41000E230000020B02B170A0003882001C41000004160562E26800710400388C0000082C0AC5C28000E23000711800001058158B89A001C46000E14
...    0000040B02B0F11800388C00000C2C0AC7C4D000E26800713400389A00001C2C0803808D00A2026C04117600C908428913639F0E14489B1CF870A244
...    D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF8112
...    04081B1CF811204081B1CF810A040D8E7C08D0204081B3DFB6191018C6318C6318C6318C63010107043406200040018000D018800100060003406200
...    040018000C018800100060003406200040018000D0288800100060003406200040018000D028880010006000340A2200040018000D02888001000600
...    0340A2200040018000D028880010006000340A2200040018000D0288800100060003406200040018000D038888001000600001E82E003C00281C1401
...    C0C02500700060240040603E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C
...    010008000000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604
...    560ED0341000009652504000065949410000296524040000E594901000049652404000165949010000696524040001E5949010000896524040002659
...    49010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A1601780
...    95028140A05028140A05028140A05028140A0502814001C2020180300801002101002008040300610080100202018030080600C10100C01804030061
...    0080100202018030080100220100C01804030060100C018202004010080100430100200804008020100200804008021AA1F000102030406070A0B0C0
...    D101112131418191B1C1D1F2125262728292A2D2F414182D

${SA_Capa_Support_B020}    SEPARATOR=
...    E9A09000575F5A13160003C328016008000004000047BF0093170019C3D09009B20C39F21CF942C0E098040623807DC6C28C0D608C21A08107482406
...    D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC0
...    9F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000044000702B8D89BAC1184341020E904809AD93156045AF1811C780E7CC73EF0B078
...    1C3C017003FF001C00FFC00110001C0AE3E236B04610D04083E50480AAD931561439F11C78C00000000000000000040E1E027FFC00001FFF00000110
...    001C01078789A001C4100000216020541E14000711800000858158788C001C41000006160561E14000710400000858158789A001C46000002160562E
...    2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26800711800388C0000082C0AC5C28000E208007118
...    00001058158B850001C41000E208000020B02B17134003882001C46000004160562E14000711800388C0000082C0AC5C4D000E2300070A0000020581
...    58788C001C46000006160563E26800713400389A001C4D00000E160401C0468051013602086B0C908428913639F0E14489B1CF870A244D8E7C385122
...    6C73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF81
...    1204081B1CF810A040D8E7C08D0204081B3DFB6191018C6318C6318C6318C63010107043406200040018000D018800100060003406200040018000C0
...    18800100060003406200040018000D0288800100060003406200040018000D028880010006000340A2200040018000D028880010006000340A220004
...    0018000D028880010006000340A2200040018000D0288800100060003406200040018000D038888001000600001E8260078005038280381804A00E00
...    0C0480080C07C120040000000200000401000000008000010040000100200000C0100000800800005004002008020080000600400003802001000000
...    0400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA068200
...    0012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152C
...    A48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142405E02540A0502814
...    0A05028140A05028140A05028140A05000708080600C02004008404008020100C018402004008080600C02018030404030060100C018402004008080
...    600C02004008804030060100C018040300608080100402004010C0400802010020080400802010020086A87C0004080C10181C282C30344044484C50
...    60646C70747C8494989CA0A4A8B4BD05060B40


${pdu_id}    1
${gw_id}    1
${nwslice}    1

@{OnlineParamChange_B018}
...    NRCELL-2/NRREL-1:sCellPrio=1
...    NRCELL-2/NRREL-2:sCellPrio=2

@{OnlineParam_B018_recover}
...    NRCELL-2/NRREL-1:sCellPrio=2
...    NRCELL-2/NRREL-2:sCellPrio=1

*** Test Cases ***
CB008290-ET-B018_Verify_scell_CSI-RS_downgrade_during_scell_swap_TT_per-band_capability_check
    [Documentation]
    ...    1. This user scenario describes the successful handling of A6 measurement report for the purpose of SCell swap for FR1
    ...       CA UE in 2CC CA (T+T) in SA mode, the gNB determines the appropriate CSI-RS resources to configure for the SCell to be
    ...       configured to the UE during an SCell Swap. The 3GPP Release 15 and Release 16 per-band UE capabilities are checked.
    ...    2. Configuration
    ...         a. cell1, cell2 and cell4 is in same band, cell1 and cell4 with same ssbfrequency F1, cell2 is with another ssbfrequency F2.
    ...         b. NRREL configured as below for cell2 as Pcell
    ...           TDD PCell(cell2) (F2) -- NRCELL/NRREL configuration for CA
    ...           SCell Frequency    SCell swap candidates (NRREL.sCellAdditionMethod)    Priority (NRREL.sCellPrio)
    ...              F1-TDD                     SCell1                                      1
    ...                                         SCell4                                      2
    ...         c. NRBTS/NRDU.carrierAggregationSupportList supports T+T
    ...         d. NRBTS.actSCellSwapFr1 is set to 'a6BasedSa', set a6MeasSCellSwapEnabled in cell1 and cell4 to non-none.
    ...         e. SCell1 and scell4 have the same channel bandwidths and NRBTS/NRCELL.weightForSCellSelection
    ...         f. NRBTS/NRCELL2.a1MeasSCellAddEnabled = true
    ...            NRBTS/NRCELL2.a1MeasSCellAddSsbRsrp.a1ThresholdSCellAddSsbRsrpTDD and
    ...            NRBTS/NRCELL2.a1MeasSCellAddSsbRsrp.a1ThresholdSCellAddSsbRsrpFDD have been configured and have different values:
    ...            a1ThresholdSCellAddSsbRsrpFDD has a lower value as compared to a1ThresholdSCellAddSsbRsrpTDD
    ...         g. ue_cap:maxNumberTxPortsPerResource 8, maxNumberResourcesPerBand 9,totalNumberTxPortsPerBand 72.
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 2.
    ...         b. Start traffic and check traffic
    ...         c. UE sends A1 measurement for SCell1 Addition, check traffic.
    ...         d. UE sends A6 measurement for SCell4 swap and check traffic.
    ...         e. UE sends A6 measurement for SCell1 swap and check traffic.
    ...         f. UE deregister
    ...     4. Expect result:
    ...          a. UE registers successfully, PDU session is setup successfully, Pcell is configured with 4 CSI-RS to UE.
    ...          b. traffic is ok
    ...          c. UE is successfully configured with TDD PCell and TDD SCell1 as SCell,
    ...             A1 for scell addition is released.
    ...             A2 for scell release and A6 for scell swap is configured to UE.
    ...             Aggregate UE peak DL/UL throughput on TDD PCell and TDD SCell1 can reach the expected value.
    ...             ACSI is not configured to UE, TDD SCell1 is configured with 4 CSI-RS.
    ...          d. scell swap to scell4 successfully.
    ...             A2 for scell release and A6 for scell swap on Scell1 is removed to UE.
    ...             A2 for scell release and A6 for scell swap on Scell4 is configured to UE.
    ...             Aggregate UE peak DL/UL throughput on TDD PCell and TDD SCell4 can reach the expected value.
    ...             ACSI is configured to UE, TDD SCell4 is configured with 1 CSI-RS.
    ...          e. scell swap to scell1 successfully.
    ...             A2 for scell release and A6 for scell swap on Scell4 is removed to UE.
    ...             A2 for scell release and A6 for scell swap on Scell1 is configured to UE.
    ...             Aggregate UE peak DL/UL throughput on TDD PCell and TDD SCell1 can reach the expected value.
    ...             ACSI not is configured to UE, TDD SCell1 is configured with 4 CSI-RS.
    ...          f. UE deregister is successfully.
    [Tags]    QC_222569    owner-hzheng    B018
    OnlineParamChange    ${OnlineParamChange_B018}
    Update UE capa    ${SA_Capa_Support_B018}    81
    UE attach and scell add
    Scell Swap 10 times
    UE Deregister From gNB    81
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B018${/}a2a.ini    wait_string=UEContextRelease::12
    [Teardown]    B018_Teardown

CB008290-ET-B019_Verify_scell_CSI-RS_upgrade_but_aCSI_not_configured_during_scell_swap_TT_per-band_capability_check
    [Documentation]
    ...    1. This user scenario describes the successful handling of A6 measurement report for the purpose of SCell swap for FR1
    ...       CA UE in 2CC CA (T+T) in SA mode, the gNB determines the appropriate CSI-RS resources to configure for the SCell to be
    ...       configured to the UE during an SCell Swap. The 3GPP Release 15 and Release 16 per-band UE capabilities are checked.
    ...    2. Configuration
    ...         a. cell1, cell2 and cell4 is in same band, cell1 and cell4 with same ssbfrequency F1, cell2 is with another ssbfrequency F2.
    ...         b. NRREL configured as below for cell2 as Pcell
    ...           TDD PCell(cell2) (F2) -- NRCELL/NRREL configuration for CA
    ...           SCell Frequency    SCell swap candidates (NRREL.sCellAdditionMethod)    Priority (NRREL.sCellPrio)
    ...              F1-TDD                     SCell1                                      2
    ...                                         SCell4                                      1
    ...         c. NRBTS/NRDU.carrierAggregationSupportList supports T+T
    ...         d. NRBTS.actSCellSwapFr1 is set to 'a6BasedSa', set a6MeasSCellSwapEnabled in cell1 and cell4 to non-none.
    ...         e. SCell1 and scell4 have the same channel bandwidths and NRBTS/NRCELL.weightForSCellSelection
    ...         f. NRBTS/NRCELL2.a1MeasSCellAddEnabled = true
    ...            NRBTS/NRCELL2.a1MeasSCellAddSsbRsrp.a1ThresholdSCellAddSsbRsrpTDD and
    ...            NRBTS/NRCELL2.a1MeasSCellAddSsbRsrp.a1ThresholdSCellAddSsbRsrpFDD have been configured and have different values:
    ...            a1ThresholdSCellAddSsbRsrpFDD has a lower value as compared to a1ThresholdSCellAddSsbRsrpTDD
    ...         g. ue_cap:maxNumberTxPortsPerResource 8, maxNumberResourcesPerBand 6,totalNumberTxPortsPerBand 48.
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 2.
    ...         b. Start traffic and check traffic
    ...         c. UE sends A1 measurement for SCell1 Addition, check traffic.
    ...         d. UE sends A6 measurement for SCell4 swap and check traffic.
    ...         e. UE sends A6 measurement for SCell1 swap and check traffic.
    ...         f. UE deregister
    ...     4. Expect result:
    ...          a. UE registers successfully, PDU session is setup successfully, Pcell is configured with 4 CSI-RS to UE.
    ...          b. traffic is ok
    ...          c. UE is successfully configured with TDD PCell and TDD SCell1 as SCell,
    ...             A1 for scell addition is released.
    ...             A2 for scell release and A6 for scell swap is configured to UE.
    ...             Aggregate UE peak DL/UL throughput on TDD PCell and TDD SCell1 can reach the expected value.
    ...             ACSI is not configured to UE, TDD SCell1 is configured with 1 CSI-RS.
    ...          d. scell swap to scell4 successfully.
    ...             A2 for scell release and A6 for scell swap on Scell1 is removed to UE.
    ...             A2 for scell release and A6 for scell swap on Scell4 is configured to UE.
    ...             Aggregate UE peak DL/UL throughput on TDD PCell and TDD SCell4 can reach the expected value.
    ...             ACSI is not configured to UE, TDD SCell4 is configured with 2 CSI-RS.
    ...          e. scell swap to scell1 successfully.
    ...             A2 for scell release and A6 for scell swap on Scell4 is removed to UE.
    ...             A2 for scell release and A6 for scell swap on Scell1 is configured to UE.
    ...             Aggregate UE peak DL/UL throughput on TDD PCell and TDD SCell1 can reach the expected value.
    ...             ACSI is not configured to UE, TDD SCell1 is configured with 1 CSI-RS.
    ...          f. UE deregister is successfully.
    [Tags]    QC_222570    owner-hzheng    B019
    Update UE capa    ${SA_Capa_Support_B019}    81
    UE attach and scell add    phycell_id=53    scell_dl=405
    Scell Swap 10 times    scell1_phyid=53    scell2_phyid=50    scell_dl_1=385    scell_dl_2=405
    UE Deregister From gNB    81
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B019${/}a2a.ini    wait_string=UEContextRelease::12

CB008290-ET-B020_Verify_scell_CSI-RS_upgrade_and_aCSI_configured_during_scell_swap_TT_per-band_capability_check
    [Documentation]
    ...    1. This user scenario describes the successful handling of A6 measurement report for the purpose of SCell swap for FR1
    ...       CA UE in 2CC CA (T+T) in SA mode, the gNB determines the appropriate CSI-RS resources to configure for the SCell to be
    ...       configured to the UE during an SCell Swap. The 3GPP Release 15 and Release 16 per-band UE capabilities are checked.
    ...    2. Configuration
    ...         a. cell1, cell2 and cell4 is in same band, cell1 and cell4 with same ssbfrequency F1, cell2 is with another ssbfrequency F2.
    ...         b. NRREL configured as below for cell2 as Pcell
    ...           TDD PCell(cell2) (F2) -- NRCELL/NRREL configuration for CA
    ...           SCell Frequency    SCell swap candidates (NRREL.sCellAdditionMethod)    Priority (NRREL.sCellPrio)
    ...              F1-TDD                     SCell1                                      2
    ...                                         SCell4                                      1
    ...         c. NRBTS/NRDU.carrierAggregationSupportList supports T+T
    ...         d. NRBTS.actSCellSwapFr1 is set to 'a6BasedSa', set a6MeasSCellSwapEnabled in cell1 and cell4 to non-none.
    ...         e. SCell1 and scell4 have the same channel bandwidths and NRBTS/NRCELL.weightForSCellSelection
    ...         f. NRBTS/NRCELL2.a1MeasSCellAddEnabled = true
    ...            NRBTS/NRCELL2.a1MeasSCellAddSsbRsrp.a1ThresholdSCellAddSsbRsrpTDD and
    ...            NRBTS/NRCELL2.a1MeasSCellAddSsbRsrp.a1ThresholdSCellAddSsbRsrpFDD have been configured and have different values:
    ...            a1ThresholdSCellAddSsbRsrpFDD has a lower value as compared to a1ThresholdSCellAddSsbRsrpTDD
    ...         g. ue_cap:maxNumberTxPortsPerResource 8, maxNumberResourcesPerBand 12,totalNumberTxPortsPerBand 96.
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 2.
    ...         b. Start traffic and check traffic
    ...         c. UE sends A1 measurement for SCell1 Addition, check traffic.
    ...         d. UE sends A6 measurement for SCell4 swap and check traffic.
    ...         e. UE sends A6 measurement for SCell1 swap and check traffic.
    ...         f. UE deregister
    ...     4. Expect result:
    ...          a. UE registers successfully, PDU session is setup successfully, Pcell is configured with 4 CSI-RS to UE.
    ...          b. traffic is ok
    ...          c. UE is successfully configured with TDD PCell and TDD SCell1 as SCell,
    ...             A1 for scell addition is released.
    ...             A2 for scell release and A6 for scell swap is configured to UE.
    ...             Aggregate UE peak DL/UL throughput on TDD PCell and TDD SCell1 can reach the expected value.
    ...             ACSI is configured to UE, TDD SCell1 is configured with 1 CSI-RS.
    ...          d. scell swap to scell4 successfully.
    ...             A2 for scell release and A6 for scell swap on Scell1 is removed to UE.
    ...             A2 for scell release and A6 for scell swap on Scell4 is configured to UE.
    ...             Aggregate UE peak DL/UL throughput on TDD PCell and TDD SCell4 can reach the expected value.
    ...             ACSI is configured to UE, TDD SCell4 is configured with 4 CSI-RS.
    ...          e. scell swap to scell1 successfully.
    ...             A2 for scell release and A6 for scell swap on Scell4 is removed to UE.
    ...             A2 for scell release and A6 for scell swap on Scell1 is configured to UE.
    ...             Aggregate UE peak DL/UL throughput on TDD PCell and TDD SCell1 can reach the expected value.
    ...             ACSI is configured to UE, TDD SCell1 is configured with 1 CSI-RS.
    ...          f. UE deregister is successfully.
    [Tags]    QC_222571    owner-hzheng    B020
    Update UE capa    ${SA_Capa_Support_B020}    81
    UE attach and scell add    phycell_id=53    scell_dl=405
    Scell Swap 10 times    scell1_phyid=53    scell2_phyid=50    scell_dl_1=385    scell_dl_2=405
    UE Deregister From gNB    81
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B020${/}a2a.ini    wait_string=UEContextRelease::12

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F_4N78_2N71

UE attach and scell add
    [Arguments]    ${phycell_id}=50    ${scell_dl}=385
    UE Attach To Target Cell    cell_id=2    ue_id=81
    Send Throughput    ue_id=81
    Verify Throughput on Pscell    ue_id=81
    Trigger MR    event_type=A1    carrierfreq=639648    srsrp_nr=100    srsrq_nr=50    ue_id=81    phycell_id=${phycell_id}
    Verify Throughput on Pscell and Scell    ue_id=81    scell_dl=${scell_dl}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

B018_Teardown
    OnlineParamChange    ${OnlineParam_B018_recover}
    Common Test Teardown And Stop Capture Logs

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell
    [Arguments]    ${cell_id}    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Send Throughput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=8    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throughput on Pscell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=370    ${ul}=8
    sleep    10s    #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throughput on Pscell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=370    ${scell_dl}=0    ${ul}=8    ${scell_id}=1
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger MR
    [Arguments]    ${event_type}=A1    ${carrierfreq}=639648    ${srsrp_nr}=5    ${srsrq_nr}=5    ${ue_id}=82    ${phycell_id}=50
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    Should contain    ${ret1}    activated successfully at airphone
    Should Contain    ${ret1}    physCellId ${phycell_id}

Trigger ScellSwap
    [Arguments]    ${event_type}=A6    ${carrierfreq}=632736    ${nrsrp_nr}=50    ${nrsrq_nr}=50    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=50
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Scell Swap 10 times
    [Arguments]    ${scell1_phyid}=50    ${scell2_phyid}=53    ${scell_dl_1}=405    ${scell_dl_2}=385
    FOR    ${index}    IN RANGE    0    5
        Trigger ScellSwap    scell_id=1    phycell_id=${scell2_phyid}
        Verify Throughput on Pscell and Scell    scell_dl=${scell_dl_1}    scell_id=2
        Trigger ScellSwap    scell_id=2    phycell_id=${scell1_phyid}
        Verify Throughput on Pscell and Scell    scell_dl=${scell_dl_2}    scell_id=1
    END
