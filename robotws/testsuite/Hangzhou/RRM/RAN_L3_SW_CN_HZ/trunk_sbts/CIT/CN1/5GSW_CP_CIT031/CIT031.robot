*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Stop Capture Logs And Restore ENV In Test Teardown
Force Tags  QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CIT    CLOUD_5G_I_BOO_AP_LOO    team-DevHZ5_SG4
...    owner-he.chendong    release-5G22R2     CB007873    CB008015    CB006138
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeashoEnabled=rsrp
#...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:actCDrx=true
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-1/NRHOIF-1:ssbFrequency=424090
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=${EMPTY}
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=${EMPTY}
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=${EMPTY}
...    NRCELL-1/NRREL-256:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-256:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-256:gNbId=1
...    NRCELL-1/NRREL-256:gNbIdLength=22
...    NRCELL-1/NRREL-256:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-256:lcrId=2
...    NRCELL-1/NRREL-256:removeNotAllowed=false
...    NRCELL-1/NRREL-256:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-256:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-256:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-256:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-256:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-255:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-255:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-255:gNbId=1
...    NRCELL-1/NRREL-255:gNbIdLength=22
...    NRCELL-1/NRREL-255:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-255:lcrId=11
...    NRCELL-1/NRREL-255:removeNotAllowed=false
...    NRCELL-1/NRREL-255:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-255:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-255:gnbPlmn:mncLength=3
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:a2MeasSCellRelEnabled=rsrp
#...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:actCDrx=true
...    NRCELL-2:actK1Opt=intra-gNB
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeashoEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeashoEnabled=rsrp
#...    NRCELL-11:a3MeasEnabled=rsrp
...    NRCELL-11:actCDrx=true
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=518910
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=${EMPTY}
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=${EMPTY}
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=${EMPTY}
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12:a1MeasSCellAddEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
#...    NRCELL-12:a3MeasEnabled=rsrp
...    NRCELL-12:actCDrx=true
...    NRCELL-12:actK1Opt=intra-gNB
...    NRCELL-13:a1MeasSCellAddEnabled=rsrp
...    NRCELL-13:a2MeasSCellRelEnabled=rsrp
#...    NRCELL-13:a3MeasEnabled=rsrp
...    NRCELL-13:actCDrx=true
...    NRCELL-13:actK1Opt=intra-gNB
...    NRCELL-14:a1MeasSCellAddEnabled=rsrp
...    NRCELL-14:a2MeasSCellRelEnabled=rsrp
#...    NRCELL-14:a3MeasEnabled=rsrp
...    NRCELL-14:actCDrx=true
...    NRCELL-14:actK1Opt=intra-gNB
...    NRCELL-11:msg1FrequencyStart=9
...    NRCELL-12:msg1FrequencyStart=11
...    NRCELL-13:msg1FrequencyStart=11
...    NRCELL-14:msg1FrequencyStart=11
...    @{bandwidth_configuration}
...    @{Golden_Change_BOO}
...    @{ANR}

@{bandwidth_configuration}
...    NRCELL-1:chBw=60MHz
...    NRCELL-2:chBw=50MHz
...    NRCELL-11/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=10MHz

@{ANR}
...    NRCELL:actCDrx=true
...    NRBTS:actNsaUeBasedInterFreqAnrNr=true
...    NRBTS:actEnhanceIntraNrIntraFreqAnr=true
...    NRBTS:actNsaUeBasedAnrNr=true
...    NRBTS:actDedicatedAnrDrxProfile=true
...    NRCELL:actSib1ForNsaCell=true
...    NRBTS:maxNumNrAnrMoiAllowed=500
...    NRANR-1:actAutoEutraNbRemoval=false
...    NRANR-1:actAutoNrNbRemoval=true
...    NRANR-1:consecHoFailThres=0
...    NRANR-1:consecHoFailThresEutra=3
...    NRANR-1:consecXnResolveFailThres=3
...    NRANR-1:gNbIdLengthConfig:gNbIdLength=22
...    NRANR-1:gNbIdLengthConfig:priorityIndex=1
...    NRANRPR-2:anrThresholdSelector=RSRP
...    NRANRPR-2:anrThresRsrpNbCell=-90
...    NRANRPR-2:anrThresRsrqNbCell=-12
...    NRANRPR-2:cellDepMode=SA+NSA
...    NRANRPR-2:consecRecheckForNrNbRemoval=5
...    NRANRPR-2:idleTimeForNrNbRemoval=72
#...    NRANRPR-2:nrarfcn=518580
#...    NRANRPR-2:ssbFrequency=518910
...    NRANRPR-2:nrarfcn=424000
...    NRANRPR-2:ssbFrequency=424090
...    NRCELL-11:drxProfileNrAnr:drxControl=any
#...    NRCELL-11:drxProfileNrAnr:drxInactivityTimer=80ms
#...    NRCELL-11:drxProfileNrAnr:drxLongCycle=320ms
#...    NRCELL-11:drxProfileNrAnr:drxOnDurationTimer=20ms
#...    NRCELL-11:drxProfileNrAnr:drxRetransTimerDl=0slot
#...    NRCELL-11:drxProfileNrAnr:drxRetransTimerUl=0slot
...    NRCELL-1:drxProfileNrAnr:drxControl=any
#...    NRCELL-1:drxProfileNrAnr:drxInactivityTimer=80ms
#...    NRCELL-1:drxProfileNrAnr:drxLongCycle=320ms
#...    NRCELL-1:drxProfileNrAnr:drxOnDurationTimer=20ms
#...    NRCELL-1:drxProfileNrAnr:drxRetransTimerDl=0slot
#...    NRCELL-1:drxProfileNrAnr:drxRetransTimerUl=0slot
...    NRCELL-1:drxProfileNrAnr:nrDrxDN=NRDRX-3
...    NRCELL-11:drxProfileNrAnr:nrDrxDN=NRDRX-3

@{Golden_Change_BOO}
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=100
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=1
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity

${CA_support_list}  ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa

@{CELL1-CELL11-REL-TO-DELETE}
...    delete:NRCELL-1/NRREL-255


${SA_Capa_perUE_Full}  SEPARATOR=
#...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC11
#...    84341020E90186D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00
#...    05800702A0D883AC1184341020F1018656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6
#...    000001FD8000000B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC31E50
#...    B0381C3C17003FF001C00FFC000B000E0541B11B582308682041E2030CAD931562439F11C7B027C62471E4
#...    39F51CF9863CA1607038784FFF800003FFE0000016001C00F78789A001C4100000216020541E1400071180
#...    0000858158788C001C41000006160561E14000710400000858158789A001C46000002160562E2300071040
#...    038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26800711800388C0000
#...    082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C460000041
#...    60562E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C046
#...    8051013602083A5D83E14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF
#...    870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D
#...    8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003C00281C1401C0C01D00E000C0
#...    480080C07C120040000000200000401000000008000010040000100200000C010000080080000500400200
#...    80200800006004000038020010000000400004002000024010000060080000A00400005802001024090040
#...    0006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282
#...    000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004C
#...    B29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A8345
#...    5298AA4D154062A8145526AAA0F1414178095028140A05028140A05028140A05028140A050281400182020
#...    180300801002101002008040300610080100202018030080600C10100C0180403006100801002020180300
#...    80100220100C01804030060100C01820200401008010043543E00020406080C0E1416181A2022242628303
#...    236383A3E424A4C4E5052545A5E828305A
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47
...    00FB8D85181AC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C
...    7942C0E070F05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB12
...    1CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4
...    DD608C21A0810748340185B262A88873E238F11C7A067D813E31CF9863CA1607038782E00
...    7FE003801FF8002E0000702A0D88DAC1184341020F1068032B64C55890E7C471EC09F1891
...    C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C00F78789A001C410000021
...    6020541E14000711800000858158788C001C41000006160561E1400071040000085815878
...    9A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134
...    003882001C28000008160562E26800711800388C0000082C0AC5C28000E20800711800001
...    058158B850001C41000E208000020B02B17134003882001C46000004160562E1400071180
...    0388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C046805
...    101360208BA005D83E14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF8
...    71224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8
...    E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C63
...    18C630F417801F001400180E0A00E0601280380030120020301F048010000000080000100
...    4000000020000040100000400800003004000020020000140100080200802000018010000
...    0E00800400000010000100080000900400001802000028010000160080040902401000018
...    0672A6B2A6B052B032B066B056B296B266B016B036B012B022B07681A0800004B29282000
...    032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2C
...    A480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480
...    669555D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C50B00BC04A8
...    140A05028140A05028140A05028140A05028140A000C10100C01804008010808010040201
...    8030804008010100C018040300608080600C02018030804008010100C0180400801100806
...    00C02018030080600C10100200804008021AA1F000102030406070A0B0C0D101112131418
...    191B1C1D1F2125262728292A2D2F414182D

${Capa_LTE}  SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A00038820
...    000002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00
...    A001C041809A26002E41E24E8913639F0E24E8913639F0E24E8913639F0E24E8913639F0E24E8912639F469D1224498E7D127448931CF8
...    30082000080404008020100C01840001008080100202018030C0002010100C01804030060100C018400010080801004020040100000000
@{PM_Counters_Check_CIT031}
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=${loop_time}
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=0
...    NRCELL-11:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=${${loop_time}*2+1}
...    NRCELL-12:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=0
...    NRCELL-13:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=0
...    NRCELL-14:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=0
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=${loop_time}
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=0
...    NRCELL-11:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=${${loop_time}*2+1}
...    NRCELL-12:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=0
...    NRCELL-13:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=0
...    NRCELL-14:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=0
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>=${40*${loop_time}}
...    NRCELL-2:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}=0
...    NRCELL-11:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>=${30*${loop_time}}
...    NRCELL-12:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}=0
...    NRCELL-13:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}=0
...    NRCELL-14:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}=0
...    NRCELL-1:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>=${30*${loop_time}}
...    NRCELL-2:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>=${40*${loop_time}}
...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_DL}=0
...    NRCELL-12:NCAC:${UE_SCELL_1_CONF_SCELL_DL}=0
...    NRCELL-13:NCAC:${UE_SCELL_1_CONF_SCELL_DL}=0
...    NRCELL-14:NCAC:${UE_SCELL_1_CONF_SCELL_DL}=0
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=${loop_time}
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=0
...    NRCELL-11:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=${${loop_time}*2+1}
...    NRCELL-12:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=0
...    NRCELL-13:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=0
...    NRCELL-14:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=0
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=${loop_time}
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=0
...    NRCELL-11:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=${${loop_time}*2+1}
...    NRCELL-12:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=0
...    NRCELL-13:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=0
...    NRCELL-14:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=${${loop_time}*2+1}
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=${loop_time}
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=0
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=0
...    NRCELL-13:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=0
...    NRCELL-14:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=${${loop_time}*2+1}
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=${loop_time}
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=0
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=0
...    NRCELL-13:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=0
...    NRCELL-14:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=${loop_time}
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=0
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=${${loop_time}*2+1}
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=0
...    NRCELL-13:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=0
...    NRCELL-14:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=${loop_time}
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=0
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=${${loop_time}*2+1}
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=0
...    NRCELL-13:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=0
...    NRCELL-14:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=0
...    ${MAX_PSCELL_UE_1_ACT_SCELL_DL}>=1
...    ${SCELL_ACTIVATIONS}=${${loop_time}*3+1}
...    ${RRC_RECONF_2_SCELL_DL_ATT}=0
...    ${RRC_RECONF_2_SCELL_DL_SUCC}=0
...    ${SGNB_SCELL_ADMISSION_UNSUCC}=0
...    ${IF_INTRA_DU_HO_ATT_NSA_MNB}=${${loop_time}*2}
...    ${IF_INTRA_DU_HO_FAI_TDC_EXP}=0
...    ${IF_INTRA_DU_HOPRE_FAI_MENB_REF}=0
...    ${IF_INTRA_DU_HOPRE_FAI_RES_NSA}=0
...    ${IF_INTRA_DU_HO_FAI_T304_EX_NSA}=0
...    ${IF_INTRA_DU_HOPRE_E1_FAI_NSA}=0
...    ${IF_INTRA_DU_HOPRE_F1_FAI_NSA}=0
...    ${IF_INTRA_DU_HO_MIN_DURAT_SRB3}=0
...    ${IF_INTRA_DU_HO_MIN_DURAT_MNB}>0
...    ${IF_INTRA_DU_HO_MAX_DURAT_MNB}>0
...    ${IF_INTRA_DU_HO_MAX_DURAT_SRB3}=0
...    ${SGNB_DU_NSA_ADMISSION_REQ}=${${loop_time}*2+1}
...    ${SGNB_DU_NSA_ADMISSION_SUCC}=${${loop_time}*2+1}
...    ${A2MEAS_REL1DLSCELL_ATT_NSA}=${loop_time}
...    ${A2MEAS_REL1DLSCELL_SUCC_NSA}=${loop_time}
...    ${A2MEAS_IMMEDIATE_REL_SCELL}=0
${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000    #RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000    #Successful RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${UE_PSCELL_1_CONF_SCELL_DL}    M55118C04000    #Number of CA UEs in the current cell configured as a PSCell, which have 1 configured SCell in DL
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000    #Number of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021    #The number of radio admission requests for 1 Scell
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028    #The number of successful radio admissions for 1 Scell additions.
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006    #The number of radio admission requests for the Scell
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007    #The number of successful radio admissions for the Scell
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008    #The number of radio admission requests for 1 Scell
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015    #The number of successful radio admissions for 1 Scell additions.
${MAX_PSCELL_UE_1_ACT_SCELL_DL}    M55316C05001    #Maximum amount of PSCell UEs with 1 activated SCells in DL
${SCELL_ACTIVATIONS}    M55316C09000    #SCell activations
${RRC_RECONF_2_SCELL_DL_ATT}    M55118C02002    #RRC Reconfigurations attempts for 2 SCells Addition in DL for NSA mode
${RRC_RECONF_2_SCELL_DL_SUCC}    M55118C03002    #Successful RRC Reconfigurations attempts for 2 SCells Addition in DL for NSA mode
${SGNB_SCELL_ADMISSION_UNSUCC}    M55114C00035    #The number of unsuccessful radio admissions for Scells additions.
${IF_INTRA_DU_HO_ATT_NSA_MNB}    M55151C00001    #The number of inter frequency intra DU PSCell change attempts for NSA 3x via MeNB
${IF_INTRA_DU_HO_FAI_TDC_EXP}    M55151C00003    #The number of inter frequency intra DU PSCell change for NSA 3x failures due to TDCoverall expiry
${IF_INTRA_DU_HOPRE_FAI_MENB_REF}    M55151C00004    #The number of inter frequency intra DU PSCell change failures due to MeNB refusal
${IF_INTRA_DU_HOPRE_FAI_RES_NSA}    M55151C00005    #The number of inter frequency intra DU PSCell change for NSA 3x failures due to resource failure
${IF_INTRA_DU_HO_FAI_T304_EX_NSA}    M55151C00006    #The number of inter frequency intra DU PSCell change for NSA 3x failures due to T304 expiry
${IF_INTRA_DU_HOPRE_E1_FAI_NSA}    M55151C00007    #The number of inter frequency intra DU PSCell change for NSA 3x failures due to E1 failure
${IF_INTRA_DU_HOPRE_F1_FAI_NSA}    M55151C00008    #The number of inter frequency intra DU PSCell change for NSA 3x failures due to F1 failure
${IF_INTRA_DU_HO_MIN_DURAT_SRB3}    M55151C00010    #The minimum duration of executed inter frequency intra DU PSCell changes for NSA 3x via SRB3
${IF_INTRA_DU_HO_MIN_DURAT_MNB}    M55151C00009    #The minimum duration of executed inter frequency intra DU PSCell changes for NSA 3x via MeNB
${IF_INTRA_DU_HO_MAX_DURAT_MNB}    M55151C00011    #The maximum duration of executed inter frequency intra DU PSCell changes for NSA 3x via MeNB
${IF_INTRA_DU_HO_MAX_DURAT_SRB3}    M55151C00012    #The maximum duration of executed inter frequency intra DU PSCell changes for NSA 3x via SRB3
${SGNB_DU_NSA_ADMISSION_REQ}    M55115C00002    #The number of admission requests for NSA user
${SGNB_DU_NSA_ADMISSION_SUCC}    M55115C00003    #The number of successful radio admitted NSA users
${A2MEAS_REL1DLSCELL_ATT_NSA}    M55118C06503    #Nbr of RRC Reconfiguration attempts releasing 1 SCell in DL triggered by A2 measurement for NSA
${A2MEAS_REL1DLSCELL_SUCC_NSA}    M55118C06504    #Nbr of successful RRC Reconfigurations releasing 1 SCell in DL triggered by A2 measurement for NSA
${A2MEAS_IMMEDIATE_REL_SCELL}    M55118C06505    #Number of immediate SCell releases triggered by A2 measurement
${BTS_STARTUP_RETRY}    4
${ScellAdditionMethod_Change}    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
${ScellAdditionMethod_Revert}    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
${loop_time}    3
${UTE_WIRESHARK_FLAG}  ${False}
${AP_UDPLOG_FLAG}  ${False}

*** Test Cases ***
5GSW_CP_CIT031_Verify_Classical_NSA_HO_from_covered_based_CA_to_blind_based_CA_and_back_is_successful
    [Documentation]
    ...    1. The purpose of this test case is to check F+T blind CA ,T+T covBasedA1 CA ,CA HO,scell's addtion
    ...    and release.
    ...    2. Test Case Steps:
    ...         a. Make NSA UE-1 attach to simulated ENB 1 cell1
    ...         b. Setup Endc with gNB cell11 and Setup blind F+T CA with Scell on gNB cell1.
    ...         c. HO to target gNB cell1.
    ...         d. Trigger Scell gNB cell2 addition consisted of T+T CA by A1 measurement.
    ...         e. Modify gNB cell1 sCellAdditionMethod as covBasedA1
    ...         f. HO to target gNB Cell11.
    ...         g. Trigger Scell gNB cell1 addtion consisted of F+T CA by A1 measurement.
    ...         h. Trigger Scell gNB cell1 Release by A2 measurement.
    ...    4. Expected Results:
    ...         Step b: cell11+cell1 CA setup successfully.
    ...         Step c: Ho to gNB cell1 successfully with correct MeasureGap/Drx
    ...         Step d: cell1+cell2 T+T CA setup successfully.
    ...         step f: Ho to gNB cell1 successfully without CA setup.
    ...         step g: Scell addition successfully.
    ...         step h: Scell release successfully.
	[Tags]    QC_47239    He Chendong
	Clear Counter Files
    Ue Attach To Cell and Initial Endc Blind Ca
	Delta Commission Parameters    ${CELL1-CELL11-REL-TO-DELETE}
    Cells Should Be OnAir
    Ue Ho To target gNB Cell1
    Add gNB Cell2 As Scell By A1
    Modify Scell Addition Method
    Ue Ho Back target gNB Cell11
    Add gNB Cell1 As Scell By A1
    Release gNB Cell1 Scell By A2
    Add gNB Cell1 As Scell By A1
    Repeat Above Steps If Need
    Check Counters    ${PM_Counters_Check_CIT031}
    Check Wireshark Log On Loop    ${CURDIR}${/}a2a_CIT031${/}a2a_wireshark.ini    ${loop_time}
	Check RRC Logs
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F
    #Debug Enter Into Egate

Modify Cfg
    ${V_1}    catenate
    ...    set_ue simulated id=91 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc
    ...    imsi=311:489:21645491
    Update Cfg    ${V_1}
    ${V_2}    catenate
    ...    ue_param id=91 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg    ${V_2}
    Update Cfg    set_bearer id=2 ue=91 qci=9 pdn=1 ip=4.7.254.191 default=on trf_type=internal

Ue Attach To Cell and Initial Endc Blind Ca
    Execute Egate Command    ue_change_location id=91 cell=1 enb=1
    UE Attach To Enb Cell1    ue_id=91
    Start RRC Log    UE_initial_ENDC_Blind_Ca
    Initial Endc And Blind Ca    ue_id=91    target_gnb=2    target_cells=11    bearer_id=2
    Send And Verify Throuput
    Get RRC Log
    Start RRC Log    loop_case

Ue Ho To target gNB Cell1
    Set MeasurementGap and Initial A2 Event    carrierfreq=424090
    Initial InterFreA3 Ho    carrierfreq=518910    phycell_id=50
    Verify Throuput And Scell Release

Ue Ho Back target gNB Cell11
    Set MeasurementGap and Initial A2 Event    carrierfreq=518910
    Initial InterFreA3 Ho    carrierfreq=424090    phycell_id=60
    Verify Throuput And Scell Release    sleep_time=30s    target_dl_throuput=50

Add gNB Cell2 As Scell By A1
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=518910    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A1 srsrp_nr=120 ssinr_nr=59 srsrq_nr=120
    ...   pass_regexp=SCellIndex 9 activated successfully
    Verify Throuput

Add gNB Cell1 As Scell By A1
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=424090    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A1 srsrp_nr=120 ssinr_nr=59 srsrq_nr=120
    ...   pass_regexp=SCellIndex 9 activated successfully
    Verify Throuput

Modify Scell Addition Method
    Delta Commission Parameters    ${ScellAdditionMethod_Change}

UE Attach To Enb Cell1
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE

Initial Endc And Blind Ca
    [Arguments]    ${ue_id}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=1
    ${ret1}=    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    Sending SgNB Modification Confirm    timeout=20s
    Should Contain    ${ret1}    Successfully reconfigured dual connectivity
    Should Contain    ${ret1}    SCellIndex 9 activated successfully

Send And Verify Throuput
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=100 trf_id=2    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=100 trf_id=3    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=100 trf_id=4    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=100 trf_id=5    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=ul mbps=10    UE 91: UDP UL
    Verify Throuput    sleep_time=30s

Verify Throuput
    [Arguments]    ${sleep_time}=15s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 0
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=9    type=pdsch    rate_type=ave
    #Should Be True    ${scell9_tput}/1000 > 0
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
	Should Be True    ${scell8_tput}/1000+${scell9_tput}/1000 > 310
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>310

Verify Throuput And Scell Release
    [Arguments]    ${sleep_time}=10s    ${target_dl_throuput}=310
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 0
    Execute Egate Command    ue_stats_nr id=91 scell=9 type=pdsch    fail_regexp=CellIndex-9
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${target_dl_throuput}

Set MeasurementGap and Initial A2 Event
    [Arguments]    ${carrierfreq}
    Execute Egate Command    ue_enb_param id=91 measurement_gap=gp0:12 gap_trigger=gnb_triggered
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=${carrierfreq}    event_type=A2
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=Sending SgNB Modification Confirm
    Should Contain    ${ret1}    measGapConfig setup
    Should Contain    ${ret1}    drx-Config release : NULL

Initial InterFreA3 Ho
    [Arguments]    ${carrierfreq}    ${phycell_id}
    Execute Egate Command    ue_enb_param id=91 measurement_gap=off
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=${carrierfreq}    event_type=A3
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=70 nrsrq_nr=70
    ...    pass_regexp=reported successful RA
    Should Contain    ${ret1}    sCellToReleaseList

Release gNB Cell1 Scell By A2
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=518910    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A2 scell=9 scell_rsrp=7 scell_rsrq=7
    ...   pass_regexp=Successfully reconfigured dual connectivity
    Verify Throuput And Scell Release    sleep_time=10s    target_dl_throuput=50

UE Detach From GNB
  [Arguments]    ${expect_string}=${EMPTY}
  Execute Egate Command  ue_detach id=91    ${expect_string}

Stop Capture Logs And Restore ENV In Test Teardown
    ScellAddtionMethod Revert
    UE Detach From GNB
    Common Test Teardown And Stop Capture Logs

ScellAddtionMethod Revert
    Delta Commission Parameters    ${ScellAdditionMethod_Revert}

Stop Traffic And Detach Ue
    UE Detach From GNB
    Stop Traffic

Repeat Above Steps If Need
    Repeat Keyword    ${${loop_time}-1}    Case Repetive Steps

Case Repetive Steps
    ScellAddtionMethod Revert
    Ue Ho To target gNB Cell1
    Add gNB Cell2 As Scell By A1
    Modify Scell Addition Method
    Ue Ho Back target gNB Cell11
    Add gNB Cell1 As Scell By A1
    Release gNB Cell1 Scell By A2
    Add gNB Cell1 As Scell By A1

Stop Traffic
    Execute Egate Command    trf_data_stop ue=91    pass_regexp=Traffic was stopped

Check RRC Logs
    Check RRC log    ${CURDIR}${/}a2a_CIT031${/}a2a.ini
    Check RRC Loop Log    ${CURDIR}${/}a2a_CIT031${/}a2a_loop.ini   ${${loop_time}}

Check RRC Loop Log
    [Arguments]    ${a2a_path}    ${times}
    ${content}=    Get File    ${a2a_path}
    ${content}=    Replace string using regexp    ${content}    REPEAT_NUM:\\s\\d+    REPEAT_NUM: ${times}
    Create File    ${a2a_path}    ${content}
    Check RRC log    ${a2a_path}

Check Wireshark Log On Loop
    [Arguments]    ${a2a_path}    ${times}
    ${content}=    Get File    ${a2a_path}
    ${content}=    Replace string using regexp    ${content}    REPEAT_NUM:\\s\\d+    REPEAT_NUM: ${times}
    Create File    ${a2a_path}    ${content}
    Check Wireshark log    ${a2a_path}
