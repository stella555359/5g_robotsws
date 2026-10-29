*** Settings  ***
Documentation      Variables for conformance
*** Variables ***

@{syslog_parameters_tm1.1_startconformancereq}      ruMode: NR_ONLY     type: TRANSMITTER     beamPatternIdList[0]: 1    reportingTimeInterval: 1
...                             testModel: 0    polarization: 2     powerBackoff: 10    nrCellIdentity: 16385
@{syslog_parameters_tm1.1_cprt}      ETestModel = TM1_1     EPolarization = P_BOTH
...                            TPowerBackoff = 10     EMimoRank = MIMO_RANK_1
${syslog_parameters_tm1.1_chbw}      "channelBandwidthDl": "50Mhz"
${syslog_parameters_tm1.1_scs}        "scsCommon": "30Khz"
${syslog_parameters_tm1.1_pyscellid}     TPhysCellId = 50
@{syslog_parameters_tm1.1_beamchange}    direction = DL    beamPatternIdList = 32
@{syslog_parameters_tm1.1_beamchangereq}    EDirection = DL     TBeamPatternId[2] = [50, 50]



@{syslog_parameters_tm2_startconformancereq}      ruMode: NR_ONLY     type: TRANSMITTER     beamPatternIdList[0]: 1    reportingTimeInterval: 1
...                                     testModel: 2    polarization: 2     powerBackoff: 10
@{syslog_parameters_tm2_cprt}       ETestModel = TM2     EPolarization = P_BOTH
...                                 TPowerBackoff = 10     EMimoRank = MIMO_RANK_2
${syslog_parameters_tm2_pyscellid}    TPhysCellId = 50
${syslog_parameters_tm2_chbwdl}     "channelBandwidthDl": "20Mhz"
${syslog_parameters_tm2_chbwul}     "channelBandwidthUl": "20Mhz"
${syslog_parameters_tm2_scs}       "scsCommon": "15Khz"
@{syslog_parameters_tm2_beamchange}    direction = DL    beamPatternIdList = 1f3
@{syslog_parameters_tm2_beamchangereq}    EDirection = DL     TBeamPatternId[2] = [499, 499]


@{syslog_parameters_tm3.2_startconformancereq}      ruMode: NR_ONLY     type: TRANSMITTER     beamPatternIdList[0]: 200
...                             testModel: 6    polarization: 2     powerBackoff: 10    reportingTimeInterval: 1
@{syslog_parameters_tm3.2_cprt}        ETestModel = TM3_2     EPolarization = P_BOTH
...                            TPowerBackoff = 10     EMimoRank = MIMO_RANK_1
${syslog_parameters_tm3.2_chbw}     "channelBandwidthDl": "90Mhz"
${syslog_parameters_tm3.2_scs}       "scsCommon": "30Khz"
${syslog_parameters_tm3.2_pyscellid}    TPhysCellId = 50
@{syslog_parameters_tm3.2_beamchange}    direction = DL    beamPatternIdList = 45
@{syslog_parameters_tm3.2_beamchangereq}    EDirection = DL     TBeamPatternId[2] = [69, 69]

@{syslog_parameters_tm3.3TDD_startconformancereq}      ruMode: NR_ONLY     type: TRANSMITTER     beamPatternIdList[0]: 200
...                             testModel: 7    polarization: 2     powerBackoff: 10    reportingTimeInterval: 1
@{syslog_parameters_tm3.3TDD_cprt}        ETestModel = TM3_3     EPolarization = P_BOTH
...                            TPowerBackoff = 10     EMimoRank = MIMO_RANK_1
${syslog_parameters_tm3.3TDD_chbw}     "channelBandwidthDl": "90Mhz"
${syslog_parameters_tm3.3TDD_scs}       "scsCommon": "30Khz"
${syslog_parameters_tm3.3TDD_pyscellid}    TPhysCellId = 50
@{syslog_parameters_tm3.3TDD_beamchange}    direction = DL    beamPatternIdList = 45
@{syslog_parameters_tm3.3TDD_beamchangereq}    EDirection = DL     TBeamPatternId[2] = [69, 69]

@{syslog_parameters_tm3.1TDD_startconformancereq}      ruMode: NR_ONLY     type: TRANSMITTER     beamPatternIdList[0]: 200
...                             testModel: 4    polarization: 2     powerBackoff: 10    reportingTimeInterval: 1
@{syslog_parameters_tm3.1TDD_cprt}        ETestModel = TM3_1     EPolarization = P_BOTH
...                            TPowerBackoff = 10     EMimoRank = MIMO_RANK_1
${syslog_parameters_tm3.1TDD_chbw}     "channelBandwidthDl": "50Mhz"
${syslog_parameters_tm3.1TDD_scs}       "scsCommon": "30Khz"
${syslog_parameters_tm3.1TDD_pyscellid}    TPhysCellId = 50
@{syslog_parameters_tm3.1TDD_beamchange}    direction = DL    beamPatternIdList = 45
@{syslog_parameters_tm3.1TDD_beamchangereq}    EDirection = DL     TBeamPatternId[2] = [69, 69]

@{syslog_parameters_tm2aFDD_startconformancereq}      ruMode: NR_ONLY     type: TRANSMITTER     beamPatternIdList[0]: 200
...                                     testModel: 3    polarization: 2     powerBackoff: 0    reportingTimeInterval: 1
@{syslog_parameters_tm2aFDD_cprt}       ETestModel = TM2A     EPolarization = P_BOTH
...                                 TPowerBackoff = 0     EMimoRank = MIMO_RANK_1
${syslog_parameters_tm2aFDD_chbwdl}     "channelBandwidthDl": "20Mhz"
${syslog_parameters_tm2aFDD_chbwul}     "channelBandwidthUl": "20Mhz"
${syslog_parameters_tm2aFDD_scs}       "scsCommon": "15Khz"
${syslog_parameters_tm2aFDD_pyscellid}    TPhysCellId = 50
@{syslog_parameters_tm2aFDD_beamchange}    direction = DL    beamPatternIdList = 45
@{syslog_parameters_tm2aFDD_beamchangereq}    EDirection = DL     TBeamPatternId[2] = [69, 69]

@{syslog_parameters_tm1.2TDD_startconformancereq}      ruMode: NR_ONLY     type: TRANSMITTER     beamPatternIdList[0]: 200
...                             testModel: 1    polarization: 2     powerBackoff: 0    reportingTimeInterval: 1
@{syslog_parameters_tm1.2TDD_cprt}        ETestModel = TM1_2     EPolarization = P_BOTH
...                            TPowerBackoff = 0     EMimoRank = MIMO_RANK_1
${syslog_parameters_tm1.2TDD_chbw}     "channelBandwidthDl": "100Mhz"
${syslog_parameters_tm1.2TDD_scs}       "scsCommon": "30Khz"
${syslog_parameters_tm1.2TDD_pyscellid}    TPhysCellId = 50
@{syslog_parameters_tm1.2TDD_beamchange}    direction = DL    beamPatternIdList = 45
@{syslog_parameters_tm1.2TDD_beamchangereq}    EDirection = DL    TBeamPatternId[2] = [69, 69]

@{syslog_parameters_tm2aTDD_startconformancereq}      ruMode: NR_ONLY     type: TRANSMITTER     beamPatternIdList[0]: 200
...                                     testModel: 3    polarization: 2     powerBackoff: 0    reportingTimeInterval: 1
@{syslog_parameters_tm2aTDD_cprt}       ETestModel = TM2A     EPolarization = P_BOTH
...                                 TPowerBackoff = 0     EMimoRank = MIMO_RANK_1
${syslog_parameters_tm2aTDD_chbw}     "channelBandwidthDl": "100Mhz"
${syslog_parameters_tm2aTDD_scs}       "scsCommon": "30Khz"
${syslog_parameters_tm2aTDD_pyscellid}    TPhysCellId = 50
@{syslog_parameters_tm2aTDD_beamchange}    direction = DL    beamPatternIdList = 45
@{syslog_parameters_tm2aTDD_beamchangereq}    EDirection = DL    TBeamPatternId[2] = [69, 69]

@{syslog_parameters_tm2TDD_startconformancereq}      ruMode: NR_ONLY     type: TRANSMITTER     beamPatternIdList[0]: 200
...                                     testModel: 2    polarization: 2     powerBackoff: 0     reportingTimeInterval: 1
@{syslog_parameters_tm2TDD_cprt}       ETestModel = TM2     EPolarization = P_BOTH
...                                 TPowerBackoff = 0     EMimoRank = MIMO_RANK_1
${syslog_parameters_tm2TDD_chbw}     "channelBandwidthDl": "50Mhz"
${syslog_parameters_tm2TDD_scs}       "scsCommon": "30Khz"
${syslog_parameters_tm2TDD_pyscellid}    TPhysCellId = 50
@{syslog_parameters_tm2TDD_beamchange}    direction = DL    beamPatternIdList = 45
@{syslog_parameters_tm2TDD_beamchangereq}    EDirection = DL    TBeamPatternId[2] = [69, 69]

@{syslog_parameters_G_FR1_A2_5_startconformancereq}      ruMode: NR_ONLY     type: RECEIVER     beamPatternIdList[0]: 1    reportingTimeInterval: 1
...                                     frcIndex: 7    prbOffset: 1       harqEnable: 0
@{syslog_parameters_G_FR1_A2_5_cprt}       EFrcIndex = G_FR1_A2_5     EUlDmrsMappingType = TYPE_A     TPrbOffset = 1
${syslog_parameters_G_FR1_A2_5_chbw}     "channelBandwidthDl": "100Mhz"
${syslog_parameters_G_FR1_A2_5_scs}       "scsCommon": "30Khz"
${syslog_parameters_G_FR1_A2_5_pyscellid}    TPhysCellId = 50
@{syslog_parameters_G_FR1_A2_5_beamchange}    direction = UL    beamPatternIdList = 32
@{syslog_parameters_G_FR1_A2_5_beamchangereq}    EDirection = UL    TBeamPatternId[2] = [50, 50]

@{syslog_parameters_G_FR1_A4_31_startconformancereq}      ruMode: NR_ONLY     type: RECEIVER     beamPatternIdList[0]: 100
...                                                       reportingTimeInterval: 0.2
...                                                frcIndex: 63     prbOffset: 0     harqEnable: 1     ulDmrsMappingType : 0
@{syslog_parameters_G_FR1_A4_31_cprt}        ETestModel = TM1_1    EPolarization = P_PLUS45_OR_0
...                            TPowerBackoff = 0     EMimoRank = MIMO_RANK_1
${syslog_parameters_G_FR1_A4_31_chbwdl}     "channelBandwidthDl": 10Mhz
${syslog_parameters_G_FR1_A4_31_chbwul}     "channelBandwidthUl": 10Mhz
${syslog_parameters_G_FR1_A4_31_scs}       "scsCommon": 15Khz
${syslog_parameters_G_FR1_A4_31_pyscellid}      TPhysCellId = 50
#${syslog_parameters_G_FR1_A4_31_maptype}      EUlDmrsMappingType = TYPE_A

@{syslog_parameters_G_FR1_A4_31A_startconformancereq}      ruMode: NR_ONLY     type: RECEIVER     beamPatternIdList[0]: 100
...                                                        reportingTimeInterval: 0.2
...                                                frcIndex: 64     prbOffset: 0     harqEnable: 1     ulDmrsMappingType : 0
@{syslog_parameters_G_FR1_A4_31A_cprt}        ETestModel = TM1_1    EPolarization = P_PLUS45_OR_0
...                            TPowerBackoff = 0     EMimoRank = MIMO_RANK_1
${syslog_parameters_G_FR1_A4_31A_chbwdl}     "channelBandwidthDl": 5Mhz
${syslog_parameters_G_FR1_A4_31A_chbwul}     "channelBandwidthUl": 5Mhz
${syslog_parameters_G_FR1_A4_31A_scs}       "scsCommon": 15Khz
${syslog_parameters_G_FR1_A4_31A_pyscellid}      TPhysCellId = 50
#${syslog_parameters_G_FR1_A4_31A_maptype}      EUlDmrsMappingType = TYPE_A

@{syslog_parameters_G_FR1_A4_32_startconformancereq}      ruMode: NR_ONLY     type: RECEIVER     beamPatternIdList[0]: 100
...                                                       reportingTimeInterval: 0.2
...                                                frcIndex: 65     prbOffset: 0     harqEnable: 1     ulDmrsMappingType : 0
@{syslog_parameters_G_FR1_A4_32_cprt}        ETestModel = TM1_1    EPolarization = P_PLUS45_OR_0
...                            TPowerBackoff = 0     EMimoRank = MIMO_RANK_1
${syslog_parameters_G_FR1_A4_32_chbw}     "channelBandwidthDl": 100Mhz
${syslog_parameters_G_FR1_A4_32_scs}       "scsCommon": 30Khz
${syslog_parameters_G_FR1_A4_32_pyscellid}      TPhysCellId = 50
#${syslog_parameters_G_FR1_A4_32_maptype}      EUlDmrsMappingType = TYPE_A

@{syslog_parameters_G_FR1_A4_32A_startconformancereq}      ruMode: NR_ONLY     type: RECEIVER     beamPatternIdList[0]: 100
...                                                        reportingTimeInterval: 0.2
...                                                frcIndex: 66     prbOffset: 0     harqEnable: 1     ulDmrsMappingType : 0
@{syslog_parameters_G_FR1_A4_32A_cprt}        ETestModel = TM1_1    EPolarization = P_PLUS45_OR_0
...                            TPowerBackoff = 0     EMimoRank = MIMO_RANK_1
${syslog_parameters_G_FR1_A4_32A_chbw}     "channelBandwidthDl": 20Mhz
${syslog_parameters_G_FR1_A4_32A_scs}       "scsCommon": 30Khz
${syslog_parameters_G_FR1_A4_32A_pyscellid}      TPhysCellId = 50
#${syslog_parameters_G_FR1_A4_32A_maptype}      EUlDmrsMappingType = TYPE_A

@{syslog_parameters_puschg_startconformancereq}      ruMode: NR_ONLY     type: RECEIVER     beamPatternIdList[0]: 100    reportingTimeInterval: 0.1
...                                                frcIndex: 35     prbOffset: 0     harqEnable: 1
@{syslog_parameters_puschg_cprt}        ETestModel = TM1_1    EPolarization = P_PLUS45_OR_0
...                            TPowerBackoff = 0     EMimoRank = MIMO_RANK_1
${syslog_parameters_puschg_chbw}     "channelBandwidthDl": "100Mhz"
${syslog_parameters_puschg_scs}       "scsCommon": "30Khz"
${syslog_parameters_puschg_pyscellid}      TPhysCellId = 50
@{syslog_parameters_puschg_beamchange}    direction = UL    beamPatternIdList = 2ee
@{syslog_parameters_puschg_beamchangereq}    EDirection = UL    TBeamPatternId[2] = [750, 750]

@{syslog_parameters_pucch_startconformancereq}      ruMode: NR_ONLY     type: CONTROL     beamPatternIdList[0]: 100    reportingTimeInterval: 1.5
...                             controlChannelTestType: 0    receivingSlots: 30c0     expectationSlots: 30c0    pucchFormat: 0    prbOffset: 1
...                             largestPrbIndex: 100   numPucchSymbol: 1
@{syslog_parameters_pucch_cprt}        ETestModel = TM1_1    EPolarization = P_PLUS45_OR_0
...                            TPowerBackoff = 0     EMimoRank = MIMO_RANK_1
${syslog_parameters_pucch_chbw}     "channelBandwidthDl": "40Mhz"
${syslog_parameters_pucch_scs}       "scsCommon": "30Khz"
${syslog_parameters_pucch_pyscellid}    TPhysCellId = 7
@{syslog_parameters_pucch_params}     EPucchFormat = F0     TPrbOffsetPucch = 1    TLargestPrbIndex = 100     numPucchSymbol: uint8 = 1
...                                      numPayloadBit: uint8 = 1    pucchPayloadContent: uint32 = 1
@{syslog_parameters_pucch_beamchange}    direction = UL    beamPatternIdList = 2ee
@{syslog_parameters_pucch_beamchangereq}    EDirection = UL     TBeamPatternId[2] = [750, 750]


@{syslog_parameters_prach_startconformancereq}      ruMode: NR_ONLY     type: CONTROL     beamPatternIdList[0]: 900    reportingTimeInterval: 0.5
...                             controlChannelTestType: 1    receivingSlots: 1100     expectationSlots: 1100        preambleIndex: 0
...                             acceptedTimingError: 9   constantOffset: 100
@{syslog_parameters_prach_cprt}        ETestModel = TM1_1    EPolarization = P_PLUS45_OR_0
...                            TPowerBackoff = 0     EMimoRank = MIMO_RANK_1
${syslog_parameters_prach_chbw}     "channelBandwidthDl": "40Mhz"
${syslog_parameters_prach_scs}       "scsCommon": "30Khz"
${syslog_parameters_prach_pyscellid}    TPhysCellId = 67
@{syslog_parameters_prach_beamchange}    direction = UL    beamPatternIdList = c8
@{syslog_parameters_prach_beamchangereq}    EDirection = UL     TBeamPatternId[2] = [200, 200]

@{syslog_parameters_pusch_startconformancereq}      ruMode: NR_ONLY     type: RECEIVER     beamPatternIdList[0]: 10
...                                                frcIndex: 43     prbOffset: 0     harqEnable: 1
...                                                reportingTimeInterval: 0.7
@{syslog_parameters_pusch_cprt}        ETestModel = TM1_1    EPolarization = P_PLUS45_OR_0
...                            TPowerBackoff = 0     EMimoRank = MIMO_RANK_1
${syslog_parameters_pusch_chbwdl}     "channelBandwidthDl": "10Mhz"
${syslog_parameters_pusch_chbwul}     "channelBandwidthUl": "10Mhz"
${syslog_parameters_pusch_scs}       "scsCommon": "15Khz"
${syslog_parameters_pusch_pyscellid}      TPhysCellId = 187

@{syslog_parameters_puschc_startconformancereq}      ruMode: NR_ONLY     type: RECEIVER     beamPatternIdList[0]: 100
...                                                frcIndex: 34     prbOffset: 0     harqEnable: 1
...                                                reportingTimeInterval: 0.2
@{syslog_parameters_puschc_cprt}        ETestModel = TM1_1    EPolarization = P_PLUS45_OR_0
...                            TPowerBackoff = 0     EMimoRank = MIMO_RANK_1
${syslog_parameters_puschc_chbwdl}     "channelBandwidthDl": "5Mhz"
${syslog_parameters_puschc_chbwul}     "channelBandwidthUl": "5Mhz"
${syslog_parameters_puschc_scs}       "scsCommon": "15Khz"
${syslog_parameters_puschc_pyscellid}      TPhysCellId = 50

@{syslog_parameters_pucch_a_startconformancereq}      ruMode: NR_ONLY     type: CONTROL     beamPatternIdList[0]: 100
...                             controlChannelTestType: 0    receivingSlots: 30c0     expectationSlots: 30c0
...                             largestPrbIndex: 100   numPucchSymbol: 1    reportingTimeInterval: 1.1
...                             pucchFormat: 0    prbOffset: 1
@{syslog_parameters_pucch_a_cprt}        ETestModel = TM1_1    EPolarization = P_PLUS45_OR_0
...                            TPowerBackoff = 0     EMimoRank = MIMO_RANK_1
${syslog_parameters_pucch_a_chbw}     "channelBandwidthDl": "100Mhz"
${syslog_parameters_pucch_a_scs}       "scsCommon": "30Khz"
${syslog_parameters_pucch_a_pyscellid}    TPhysCellId = 50


@{syslog_parameters_prach_a_startconformancereq}      ruMode: NR_ONLY     type: CONTROL     beamPatternIdList[0]: 900
...                             controlChannelTestType: 1    receivingSlots: 1100     expectationSlots: 1100
...                             acceptedTimingError: 9   constantOffset: 100    format: 0
...                             reportingTimeInterval: 0.5    preambleIndex: 0
@{syslog_parameters_prach_a_cprt}        ETestModel = TM1_1    EPolarization = P_PLUS45_OR_0
...                            TPowerBackoff = 0     EMimoRank = MIMO_RANK_1
${syslog_parameters_prach_a_chbw}     "channelBandwidthDl": "100Mhz"
${syslog_parameters_prach_a_scs}       "scsCommon": "30Khz"
${syslog_parameters_prach_a_pyscellid}    TPhysCellId = 67


@{syslog_parameters_tm3.1_startconformancereq}      ruMode: NR_ONLY     type: TRANSMITTER     beamPatternIdList[0]: 200
...                             testModel: 4    polarization: 2     powerBackoff: 10    reportingTimeInterval: 1
@{syslog_parameters_tm3.1_cprt}        ETestModel = TM3_1     EPolarization = P_BOTH
...                            TPowerBackoff = 10     EMimoRank = MIMO_RANK_1
${syslog_parameters_tm3.1_chbwdl}     "channelBandwidthDl": "5Mhz"
${syslog_parameters_tm3.1_chbwul}     "channelBandwidthUl": "5Mhz"
${syslog_parameters_tm3.1_scs}       "scsCommon": "15Khz"
${syslog_parameters_tm3.1_pyscellid}    TPhysCellId = 50
@{syslog_parameters_tm3.1_beamchange}    direction = DL    beamPatternIdList = 45
@{syslog_parameters_tm3.1_beamchangereq}    EDirection = DL    TBeamPatternId[2] = [69, 69]

@{syslog_parameters_tm3.2FDD_startconformancereq}      ruMode: NR_ONLY     type: TRANSMITTER
...                             testModel: 6    polarization: 2     powerBackoff: 10
...                             beamPatternIdList[0]: 200    reportingTimeInterval: 1
@{syslog_parameters_tm3.2FDD_cprt}        ETestModel = TM3_2     EPolarization = P_BOTH
...                            TPowerBackoff = 10     EMimoRank = MIMO_RANK_1
${syslog_parameters_tm3.2FDD_chbwdl}     "channelBandwidthDl": "20Mhz"
${syslog_parameters_tm3.2FDD_chbwul}     "channelBandwidthUl": "20Mhz"
${syslog_parameters_tm3.2FDD_scs}       "scsCommon": "15Khz"
${syslog_parameters_tm3.2FDD_pyscellid}    TPhysCellId = 50
@{syslog_parameters_tm3.2FDD_beamchange}    direction = DL    beamPatternIdList = 45
@{syslog_parameters_tm3.2FDD_beamchangereq}    EDirection = DL    TBeamPatternId[2] = [69, 69]


@{syslog_parameters_tm3.1A_startconformancereq}      ruMode: NR_ONLY     type: TRANSMITTER     beamPatternIdList[0]: 200
...                             testModel: 5    polarization: 2     powerBackoff: 10    reportingTimeInterval: 1
@{syslog_parameters_tm3.1A_cprt}        ETestModel = TM3_1     A,     EPolarization = P_BOTH
...                            TPowerBackoff = 10     EMimoRank = MIMO_RANK_1
${syslog_parameters_tm3.1A_chbw}     "channelBandwidthDl": "50Mhz"
${syslog_parameters_tm3.1A_scs}       "scsCommon": "30Khz"
${syslog_parameters_tm3.1A_pyscellid}    TPhysCellId = 50
@{syslog_parameters_tm3.1A_beamchange}    direction = DL    beamPatternIdList = 45
@{syslog_parameters_tm3.1A_beamchangereq}    EDirection = DL     TBeamPatternId[2] = [69, 69]


@{syslog_parameters_tm1.1_FDD_startconformancereq}      ruMode: NR_ONLY     type: TRANSMITTER     beamPatternIdList[0]: 200
...                             testModel: 0    polarization: 2     powerBackoff: 0    reportingTimeInterval: 1
@{syslog_parameters_tm1.1_FDD_cprt}      ETestModel = TM1_1     EPolarization = P_BOTH
...                            TPowerBackoff = 0     EMimoRank = MIMO_RANK_1
${syslog_parameters_tm1.1_FDD_chbwul}      "channelBandwidthUl": "5Mhz"
${syslog_parameters_tm1.1_FDD_chbwdl}      "channelBandwidthDl": "5Mhz"
${syslog_parameters_tm1.1_FDD_scs}        "scsCommon": "15Khz"
${syslog_parameters_tm1.1_FDD_pyscellid}     TPhysCellId = 50
@{syslog_parameters_tm1.1_FDD_beamchange}    direction = DL    beamPatternIdList = 45
@{syslog_parameters_tm1.1_FDD_beamchangereq}    EDirection = DL     TBeamPatternId[2] = [69, 69]


@{syslog_parameters_tm1.2_FDD_startconformancereq}      ruMode: NR_ONLY     type: TRANSMITTER     beamPatternIdList[0]: 200
...                             testModel: 1    polarization: 2     powerBackoff: 0    reportingTimeInterval: 1
@{syslog_parameters_tm1.2_FDD_cprt}      ETestModel = TM1_2    EPolarization = P_BOTH
...                            TPowerBackoff = 0     EMimoRank = MIMO_RANK_1
${syslog_parameters_tm1.2_FDD_chbwul}      "channelBandwidthUl": "20Mhz"
${syslog_parameters_tm1.2_FDD_chbwdl}      "channelBandwidthDl": "20Mhz"
${syslog_parameters_tm1.2_FDD_scs}        "scsCommon": "15Khz"
${syslog_parameters_tm1.2_FDD_pyscellid}     TPhysCellId = 50
@{syslog_parameters_tm1.2_FDD_beamchange}    direction = DL    beamPatternIdList = 45
@{syslog_parameters_tm1.2_FDD_beamchangereq}    EDirection = DL     TBeamPatternId[2] = [69, 69]


@{syslog_parameters_tm3.3FDD_startconformancereq}      ruMode: NR_ONLY     type: TRANSMITTER     beamPatternIdList[0]: 1    reportingTimeInterval: 1
...                             testModel: 7    polarization: 2     powerBackoff: 10
@{syslog_parameters_tm3.3FDD_cprt}        ETestModel = TM3_3     EPolarization = P_BOTH
...                            TPowerBackoff = 10     EMimoRank = MIMO_RANK_2
${syslog_parameters_tm3.3FDD_chbwdl}     "channelBandwidthDl": "20Mhz"
${syslog_parameters_tm3.3FDD_chbwul}     "channelBandwidthUl": "20Mhz"
${syslog_parameters_tm3.3FDD_scs}       "scsCommon": "15Khz"
@{syslog_parameters_tm3.3FDD_pyscellid}    TPhysCellId = 50      SubFeatureFlag = SF1716_B


@{syslog_parameters_tm3.1aFDD_startconformancereq}      ruMode: NR_ONLY     type: TRANSMITTER     beamPatternIdList[0]: 1    reportingTimeInterval: 1
...                             testModel: 5    polarization: 2     powerBackoff: 10
@{syslog_parameters_tm3.1aFDD_cprt}        ETestModel = TM3_1A     EPolarization = P_BOTH
...                            TPowerBackoff = 10     EMimoRank = MIMO_RANK_2
${syslog_parameters_tm3.1aFDD_chbwdl}     "channelBandwidthDl": "20Mhz"
${syslog_parameters_tm3.1aFDD_chbwul}     "channelBandwidthUl": "20Mhz"
${syslog_parameters_tm3.1aFDD_scs}       "scsCommon": "15Khz"
@{syslog_parameters_tm3.1aFDD_pyscellid}    TPhysCellId = 50      SubFeatureFlag = SF1716_B
