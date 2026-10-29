*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags      QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    CRT    SBTS00
...    owner-lijun.j.jia    owner-teana.wang    team-SG2    release-SBTS22R1    CB006138-AC
...    CLOUD_5G_I_BLLL_AP_LOO
Resource         ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_2T4F

@{PARAMS_IN_SCF}
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
...    NRDU-1:actInterNumerologyCa=true
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actGrflShdn=true
...    NRBTS-1:actHoOptimizationCa=false
...    NRBTS-1:actLteNrDss=false
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    @{NRCELL}
...    @{NRREL}
...    @{NRHOIF}

@{NRCELL}
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:actBeamforming=false
...    NRCELL:actCDrx=false
...    NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-1:msg1FrequencyStart=16
...    NRCELL-1:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-1:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=60
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=40
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-13:weightForSCellSelection=60
...    NRCELL-11:msg1FrequencyStart=11
...    NRCELL-12:msg1FrequencyStart=12
...    NRCELL-13:msg1FrequencyStart=11
...    NRCELL-14:msg1FrequencyStart=13

@{NRREL}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:lcrId=12
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:lcrId=13
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=1
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:lcrId=2
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:removeNotAllowed=false

@{NRHOIF}
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=9
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=30
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ssbFrequency=424090
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchPriority=9
...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrq=30
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-2:ssbFrequency=126750
...    NRCELL-1/NRHOIF-3:a2BasedPCellSwitchPriority=9
...    NRCELL-1/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-3:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-3:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-3:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-3:thresholdPCellSwitchTargetRsrq=30
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-3:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-3:ssbFrequency=427970

${CA_SUPPORT_LIST}    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa


@{INCREASE_CELL13_SCELL_WEIGHT}
...    NRCELL-13:weightForSCellSelection=100

@{DECREASE_CELL13_MAX_SCELL_NUM}
...    NRCELL-13:maxNumOfSCellAlloc=1

@{CHANGE_PCELL_SWITCH_RSRQ}
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrq
...    NRCELL-1:a2MeasPCellSwitchSsbRsrq:a2HysteresisPCellSwitchSsbRsrq=0
...    NRCELL-1:a2MeasPCellSwitchSsbRsrq:a2ThresholdPCellSwitchSsbRsrq=30
...    NRCELL-1:a2MeasPCellSwitchSsbRsrq:a2TimeToTriggerPCellSwitchSsbRsrq=0ms
...    NRCELL-1:a2MeasPCellSwitchSsbRsrq:pCellSwitchOffsetSsbRsrq=0

@{INCREASE_CELL13_MAX_SCELL_NUM_AND_CELL11_PCELL_SWITCH_PRIORITY}
...    NRCELL-13:maxNumOfSCellAlloc=2
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1

@{PARAMS_RECOVERY}
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-13:weightForSCellSelection=60
...    NRCELL-13:maxNumOfSCellAlloc=250
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=9


${SA_Capa_perUE_Full}    SEPARATOR=
...     E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020E90186D6C98AB1A1CF
...     88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C98AB121CFB027C471
...     E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E
...     7CC31E50B0381C3C17003FF001C00FFC000B000E0541B11B582308682041E2030CAD931562439F11C7B027C62471E439F51CF9863CA16070
...     38784FFF800003FFE0000016001C00F78789A001C4100000216020541E14000711800000858158788C001C41000006160561E14000710400
...     000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E268
...     00711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E1400
...     0711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C0468051013602083A5D83E14489B1CF870A244D
...     8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E
...     7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003C00281C1401C0C01D00E000C048
...     0080C07C120040000000200000401000000008000010040000100200000C0100000800800005004002008020080000600400003802001000
...     0000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08
...     AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA480
...     80004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A81455
...     26AAA0F1414178095028140A05028140A05028140A05028140A0502814001820201803008010021010020080403006100801002020180300
...     80600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406080C0E1416181
...     A2022242628303236383A3E424A4C4E5052545A5E828305A

${SA_Capa_perUE_Full_enable_ROHC_powersaving}    SEPARATOR=
...     E9A09380575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1
...     CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC09F
...     11C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000044000702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC0
...     9F18E7CC31E50B0381C3C17003FF001C00FFC00110001C0A836236B04610D04083C412032B64C55890E7C471EC09F1891C790E7D473E618F
...     28581C0E1E13FFE00000FFF80000088000E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A00
...     038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000E140000040B0
...     2B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B02
...     B170A000388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0200E0234028809B01043505D83E14489B1CF
...     870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C089
...     02040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003C00281C1401C0C02500
...     700060240040603E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C
...     010008000000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606
...     D6025604560ED0341000009652504000065949410000296524040000E594901000049652404000165949010000696524040001E594901000
...     089652404000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA0
...     31540A2A93555078A1202F012A05028140A05028140A05028140A05028140A0502800304040300601002004202004010080600C201002004
...     04030060100C018202018030080600C201002004040300601002004402018030080600C0201803040400802010020086A87C0004080C1018
...     1C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

@{PM_COUNTER_CHECK}
...     NRCELL-1:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-2:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-11:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-12:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-13:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-2:${UE_SCELL_1_CONF_SCELL_DL_SA}>0
...     NRCELL-11:${UE_SCELL_1_CONF_SCELL_DL_SA}>0
...     NRCELL-12:${UE_SCELL_1_CONF_SCELL_DL_SA}=0
...     NRCELL-13:${UE_SCELL_1_CONF_SCELL_DL_SA}>0
...     NRCELL-1:${RRC_RECONF_ADD2DLSCELL_SUCC_SA}==5
...     NRCELL-1:${RRC_RECONF_ADD2DLSCELL_ATT_SA}==5
...     NRCELL-1:${RRC_RECONF_ADD1DLSCELL_SUCC_SA}==1
...     NRCELL-1:${RRC_RECONF_ADD1DLSCELL_ATT_SA}==1

# Sum of CA UEs in the current cell configured as PCell with 2 configured SCells in DL
${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001
# Sum of CA UEs in the current cell configured as an SCell with 2 configured SCells in DL
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002
# When an RRC reconfiguration complete message following RRC reconfiguration with the addition of exactly 2 SCells in DL is received in SA mode,
# this counter is updated at PCell
${RRC_RECONF_ADD2DLSCELL_SUCC_SA}    M55118C07003
# When an RRC reconfiguration message with the addition of exactly 2 SCells in DL is triggered in SA mode,
# this counter is updated at PCell.
${RRC_RECONF_ADD2DLSCELL_ATT_SA}    M55118C07004
# Sum of CA UEs in the current cell configured as an SCell with 1 configured SCell in DL
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508
# When an RRC reconfiguration complete message following RRC reconfiguration with the addition of exactly 1 SCells in DL is received in SA mode,
# this counter is updated at PCell
${RRC_RECONF_ADD1DLSCELL_SUCC_SA}    M55118C05506
# When an RRC reconfiguration message with the addition of exactly 1 SCells in DL is triggered in SA mode,
# this counter is updated at PCell.
${RRC_RECONF_ADD1DLSCELL_ATT_SA}    M55118C05505

&{CELLS_CARRIER_FREQ}
...     1=518910
...     2=633216
...     11=424090
...     12=126750
...     13=427970


*** Test Cases ***
CB006138-ET-AC002_AC008_AC009_AC021_AC028_scell_add_and_scell_change_and_pcell_change
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...       CB006138-ET-AC002_SCell_add_based_on_diff_weight_when_pcell_report_diff_rsrp_of_a1RsrpFDD_and_a1RsrpTDD
    ...       CB006138-ET-AC008_Scell_add_based_on_MR_by_online_change_weight_when_select_rsrp
    ...       CB006138-ET-AC009_SCell_add_based_on_cell_load_when_select_rsrp
    ...       CB006138-ET-AC021_A2_trigger_Pcell_change_RSRQ_successful_when_diff_priority_FDD_scell_selected_for_TDD-FDD-FDD
    ...       CB006138-ET-AC028_A2_trigger_Pcell_change_RSRP_successful_when_equal_priority_diff_rsrp_FDD_scell_selected_for_TDD-FDD-FDD
    ...    2. Precondition:
    ...         a. a1ThresholdSCellAddSsbRsrpFDD=75, a1ThresholdSCellAddSsbRsrpTDD=95, a2ThresholdSCellRelSsbRsrp=35
    ...         b. weightForSCellSelection: (TDD) cell_2=50, (FDD) cell_11=40, (FDD) cell_12=50, (FDD) cell_13=60,
    ...         c.  cell_1 TDD 60MHz, cell_2 TDD 50MHz, cell_11/12/13 FDD 20MHz
    ...                   Weight    chBW    cellLoad    value=weight*chbw/(load+1)
    ...         cell-2     50         50        0         2500
    ...         cell-11    40         20        0         800
    ...         cell-12    50         20        0         1000
    ...         cell-13    60         20        0         1200
    ...    3. Test Case Steps:
    ...         a. make SA UE-81/82 attach to cell 1, and start data transfer
    ...         b. UE-81: No Scell Added with Low RSRP=60
    ...         c. UE-81: Scell_2_13 Added Based On High Rsrp=100
    ...         d. UE-82: Lock Cell12, and Scell_2_11 Added Based On High Rsrp=100 Then Release Scells
    ...         e. online modify param: NRCELL-13:weightForSCellSelection=100
    ...         f. UE-82: Scell_2_13 Added Based On High Rsrp=100, then release scell-2
    ...         g. UE-82: Scell Change from Cell_13 to Cell_2 Then Release Scells
    ...         h. online modify param: NRCELL-13:maxNumOfSCellAlloc=1
    ...         i. UE-82: Lock Cell12 and Scell_11 Added with RSRP=80 Then Release Scells
    ...         j. UE-81: Switch Pcell From cell1 To cell13 based on TTF
    ...         k. UE-82: Scell_12_13 Added with RSRP=80
    ...         l. online modify params: NRCELL-13:maxNumOfSCellAlloc=2, NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
    ...         m. UE-81: detach and reattach to cell-1
    ...         n. UE-81: Scell_11_13 Added with RSRP=80
    ...         o. UE-81: Switch Pcell From cell1 To cell11 With High Priority
    ...         p. online modify param: NRCELL-1:a2MeasPCellSwitchEnabled=rsrq
    ...         q. UE-82: Swith Pcell to Cell12 With Scell12 RSRQ Higher than SCell13
    ...         r. release UEs, and check counter
    [Tags]    QC_133948    AC002    AC008    AC009    AC021    AC028
    [Timeout]     60 min
    Clear Counter Files    wait=${False}
    UE Attach and Start Traffic    ue_id=81    pdu_id=1
    UE Attach and Start Traffic    ue_id=82    pdu_id=2
    Scell Addition and Scell Change with Diff Weight and MaxScellNum
    Pcell Switch with Diff Priority
    Release Ues    ue_type=sa    ue_id=81-82
    Check Counters     ${PM_COUNTER_CHECK}
    [Teardown]    Recover Param and Common Test Teardown    ${PARAMS_RECOVERY}


*** Keywords ***
Scell Addition and Scell Change with Diff Weight and MaxScellNum
    No Scell Added with Low RSRP    ue_id=81    pdu_id=1    rsrp=60    dl_tput=150
    Scell_2_13 Added Based On High Rsrp    ue_id=81    pdu_id=1    rsrp=100    dl_tput=450
    Lock Cell12 and Scell_2_11 Added Based On High Rsrp Then Release Scells    ue_id=82    pdu_id=2    rsrp=100    dl_tput=250
    Online Params Modification     ${INCREASE_CELL13_SCELL_WEIGHT}
    Scell_2_13 Added Based On High Rsrp    ue_id=82    pdu_id=2    rsrp=100    dl_tput=250
    Release SCell     ue_id=82    scell=2    index=1
    Scell Change from Cell_13 to Cell_2 Then Release Scells    ue_id=82    pdu_id=2    rsrp=100    dl_tput=250
    Online Params Modification     ${DECREASE_CELL13_MAX_SCELL_NUM}
    Lock Cell12 and Scell_11 Added Then Release Scells    ue_id=82    pdu_id=2    rsrp=80    dl_tput=250

Pcell Switch with Diff Priority
    Switch Pcell From cell1 To cell13 based on TTF     ue_id=81    pdu_id=1    dl_tput=100
    Scell_12_13 Added    ue_id=82    pdu_id=2    rsrp=80    dl_tput=450
    Online Params Modification     ${INCREASE_CELL13_MAX_SCELL_NUM_AND_CELL11_PCELL_SWITCH_PRIORITY}
    Stop Traffic and UE Detach      ue_id=81
    UE Attach and Start Traffic      ue_id=81    pdu_id=3
    Scell_11_13 Added    ue_id=81    pdu_id=3    rsrp=80    dl_tput=250
    Switch Pcell From cell1 To cell11 With High Priority    ue_id=81    pdu_id=3    dl_tput=100
    Online Params Modification     ${CHANGE_PCELL_SWITCH_RSRQ}
    Swith Pcell to Cell12 With Scell12 RSRQ Higher than SCell13    ue_id=82    pdu_id=2    dl_tput=100

Recover Param and Common Test Teardown
    [Arguments]     ${origin_params}
    Delta Commission Parameters     ${origin_params}
    Common Test Teardown And Stop Capture Logs

Online Params Modification
    [Arguments]     ${params}
    Delta Commission Parameters     ${params}
    cells should be onair

UE Attach to GNB2 Cell1
    [Arguments]    ${ue_id}    ${pdu_id}
    ${ret}    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1    location
    Should Contain Any    ${ret}    location updated    already there
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${pdu_id}
    ...                      pass_regexp=QoS Routing Table

Triggered Scell Addition by A1 Event
    [Arguments]    ${ue_id}=81    ${rsrp}=100    ${rsrq}=30    ${pass_regexp}=None    ${fail_regexp}=None
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    1
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${pcell_carrier_freq}    A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrq}
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}

Start Traffic
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=dl mbps=175 trf_id=1
    ...                      pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=dl mbps=175 trf_id=2
    ...                      pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=dl mbps=150 trf_id=3
    ...                      pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=ul mbps=30 trf_id=7
    ...                      pass_regexp=UE${ue_id}: Started Uplink Internal traffic

Check Traffic
    [Arguments]     ${ue_id}=81    ${cell_num}=3    ${pdu_id}=1    ${min_dl_tput}=70    ${min_ul_tput}=9
    Sleep    15s    sleep for Tput stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    FOR    ${index}    IN RANGE    0    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 0
    END
    Should Be True    ${dl_throuput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}

UE Attach and Start Traffic
    [Arguments]    ${ue_id}    ${pdu_id}
    UE Attach to GNB2 Cell1    ue_id=${ue_id}    pdu_id=${pdu_id}
    Start Traffic    ${ue_id}    ${pdu_id}

Stop Traffic and UE Detach
    [Arguments]    ${ue_id}
    Execute Egate Command    trf_data_stop ue=${ue_id}    pass_regexp=Traffic was stopped
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached

Release Scell
    [Arguments]      ${ue_id}    ${scell}    ${index}
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     ${scell}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${carrier_freq}    A2
    ${release_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2
    ...    scell=${index} scell_rsrp=20 scell_rsrq=20
    Execute Egate Command    ${release_cmd}    pass_regexp=sCellToReleaseList

#Release SCell In Order and Check Meas Ids
#    [Arguments]    ${ue_id}    @{cell_id_list}
#    ${meas_ids}     Get A2 Meas Ids For Cells    ${ue_id}    ${cell_id_list}
#    ${release_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_ids[1]} event=A2
#    ...    scell=1 scell_rsrp=20 scell_rsrq=20
#    Execute Egate Command    ${release_cmd}    pass_regexp=sCellToReleaseList
#    Check If Meas Ids Still Exist    ${ue_id}    ${meas_ids[1]}
#    ${release_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_ids[2]} event=A2
#    ...    scell=2 scell_rsrp=20 scell_rsrq=20
#    Execute Egate Command    ${release_cmd}    pass_regexp=sCellToReleaseList
#    Check If Meas Ids Still Exist    ${ue_id}    ${meas_ids[0]}    ${meas_ids[2]}

Release FDD Scell First for TTF CA and Check Meas Ids
    [Arguments]    ${ue_id}    @{cell_id_list}
    ${meas_ids}     Get A2 Meas Ids For Cells    ${ue_id}    ${cell_id_list}
    ${release_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_ids[2]} event=A2
    ...    scell=2 scell_rsrp=20 scell_rsrq=20
    Execute Egate Command    ${release_cmd}    pass_regexp=sCellToReleaseList
    Check If Meas Ids Still Exist    ${ue_id}    ${meas_ids[0]}    ${meas_ids[2]}
    ${release_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_ids[1]} event=A2
    ...    scell=1 scell_rsrp=20 scell_rsrq=20
    Execute Egate Command    ${release_cmd}    pass_regexp=sCellToReleaseList
    Check If Meas Ids Still Exist    ${ue_id}    ${meas_ids[1]}

Check If Meas Ids Still Exist
    [Arguments]    ${ue_id}    @{meas_id_list}
    ${meas_cfg}     Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ...     fail_regexp=no NR MEASUREMENT IDENTITIES
    ${meas_data}    Parse Nr Ue Meas Cfg    ${meas_cfg}
    ${meas_id_dict_list}    Get Dictionary Values    ${meas_data['nr_measurement_identities']}
    FOR    ${item}    IN     @{meas_id_dict_list}
         List Should Not Contain Value     ${meas_id_list}    ${item['MeasId']}
    END

Get A2 Meas Ids For Cells
    [Arguments]    ${ue_id}    ${cell_id_list}
    ${total_query}    Create List
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${query}    Create Dictionary    ue_id=${ue_id}    carrierfreq=${CELLS_CARRIER_FREQ[str(${cell_id})]}
        ...     event_type=A2
        Append To List      ${total_query}    ${query}
    END
    ${meas_ids}     Get Nr Meas Ids For Specific Type And Frequency     ${total_query}
    [Return]     ${meas_ids}

Check Scell Number
    [Arguments]    ${ue_id}    ${expected_scell_num}
    ${meas_obj}     Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ...     fail_regexp=no NR MEASUREMENT IDENTITIES
    ${meas_data}    Parse Nr Ue Meas Cfg    ${meas_obj}
    ${meas_obj_num}    Get Length      ${meas_data['nr_measurment_objects']}
    ${real_scell_num}    Evaluate    ${meas_obj_num}-1
    Should Be Equal As Integers     ${expected_scell_num}    ${real_scell_num}

No Scell Added with Low RSRP
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${rsrp}=60    ${dl_tput}=100
    log to console      ----------------UE${ue_id} no scell add with rsrp=${rsrp}----------------
    Triggered Scell Addition by A1 Event    ue_id=${ue_id}    rsrp=${rsrp}    fail_regexp=rrcReconfiguration
    Check Scell Number    ue_id=${ue_id}    expected_scell_num=0
    Check Traffic    ue_id=${ue_id}   cell_num=1    pdu_id=${pdu_id}    min_dl_tput=${dl_tput}

Lock Cell12 and Scell_2_11 Added Based On High Rsrp Then Release Scells
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${rsrp}=100    ${dl_tput}=250
    log to console      ----------------Lock Cell12 and Scell_2_11 Added Based On High---------------
    Lock Cell12
    ${scells_add_success}     Create List
    ...    sCellToAddModList
    ...    physCellId 51
    ...    physCellId 60
    ...    eventId eventA2
    ...    SCellIndex 1 activated successfully
    ...    SCellIndex 2 activated successfully
    Triggered Scell Addition by A1 Event    ue_id=${ue_id}    rsrp=${rsrp}    pass_regexp=${scells_add_success}
    Check Scell Number     ue_id=${ue_id}    expected_scell_num=2
    Check Traffic    ue_id=${ue_id}    cell_num=3    pdu_id=${pdu_id}    min_dl_tput=${dl_tput}
    Unlock Cell12
    Release FDD Scell First for TTF CA and Check Meas Ids    ${ue_id}    1    2    11

Scell Change from Cell_13 to Cell_2 Then Release Scells
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${rsrp}=100    ${dl_tput}=100
    log to console      ----------------scell change from cell-13 to scell_2----------------
    ${scells_add_success}     Create List
    ...    sCellToAddModList
    ...    physCellId 51
    ...    sCellToReleaseList
    ...    SCellIndex 1 activated successfully
    Triggered Scell Addition by A1 Event    ue_id=${ue_id}    rsrp=100    pass_regexp=${scells_add_success}
    Check Scell Number      ue_id=${ue_id}    expected_scell_num=1
    Check Traffic    ue_id=${ue_id}    cell_num=2   pdu_id=${pdu_id}    min_dl_tput=100
    Release Scell    ue_id=${ue_id}    scell=2    index=1

Lock Cell12 and Scell_11 Added Then Release Scells
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${rsrp}=100    ${dl_tput}=100
    log to console       ----------------cell13:maxscellnum=1 -> Scell_11 added ----------------
    Lock Cell12
    ${scells_add_success}     Create List
    ...    sCellToAddModList
    ...    physCellId 60
    ...    SCellIndex 1 activated successfully
    Triggered Scell Addition by A1 Event    ue_id=${ue_id}    rsrp=80    pass_regexp=${scells_add_success}
    Check Scell Number     ue_id=${ue_id}    expected_scell_num=1
    Check Traffic    ue_id=${ue_id}    cell_num=2    pdu_id=${pdu_id}    min_dl_tput=${dl_tput}
    Release Scell    ue_id=${ue_id}    scell=11    index=1
    Unlock Cell12

Switch Pcell From cell1 To cell11 With High Priority
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${dl_tput}=100
    log to console      ----------------UE${ue_id}: pcell swith from cell-1 TDD to scell-11 FDD with high priority----------------
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     1
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A2
    ${egate_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} event=A2 meas_id=${meas_id} srsrp_nr=11 srsrq_nr=11
    ...    scell=1 scell_rsrp=100 scell_rsrq=45 scell=2 scell_rsrp=100 scell_rsrq=45
    ${pcell_change_success}     Create List
    ...    rrcReconfigurationComplete
    ...    sCellToReleaseList
    ...    UE${ue_id}: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.11 performed
    Execute Egate Command     ${egate_cmd}    pass_regexp=${pcell_change_success}
    Check Traffic    ue_id=${ue_id}    cell_num=1    pdu_id=${pdu_id}    min_dl_tput=${dl_tput}

Switch Pcell From cell1 To cell13 based on TTF
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${dl_tput}=100
    log to console      ----------------UE${ue_id}: pcell swith from cell-1 TDD to cell-13 FDD----------------
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     1
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A2
    ${egate_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} event=A2 meas_id=${meas_id} srsrp_nr=11 srsrq_nr=11
    ...    scell=1 scell_rsrp=100 scell_rsrq=45 scell=2 scell_rsrp=80 scell_rsrq=35
    ${pcell_change_success}     Create List
    ...    rrcReconfigurationComplete
    ...    sCellToReleaseList
    ...    UE${ue_id}: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.13 performed
    Execute Egate Command     ${egate_cmd}    pass_regexp=${pcell_change_success}
    Check Traffic    ue_id=${ue_id}    cell_num=1    pdu_id=${pdu_id}    min_dl_tput=${dl_tput}

Swith Pcell to Cell12 With Scell12 RSRQ Higher than SCell13
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${dl_tput}=100
    log to console      ----------------UE81: pcell switch to scell_12 with high rsrq----------------
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     1
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A2
    ${egate_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} event=A2 meas_id=${meas_id} srsrp_nr=11 srsrq_nr=11
    ...    scell=1 scell_rsrp=80 scell_rsrq=45 scell=2 scell_rsrp=100 scell_rsrq=35
    ${pcell_change_success}     Create List
    ...    rrcReconfigurationComplete
    ...    sCellToReleaseList
    ...    UE${ue_id}: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.12 performed
    Execute Egate Command     ${egate_cmd}    pass_regexp=${pcell_change_success}
    Check Traffic    ue_id=${ue_id}    cell_num=1    pdu_id=${pdu_id}    min_dl_tput=${dl_tput}

Scell_2_13 Added Based On High Rsrp
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${rsrp}=100    ${dl_tput}=250
    ${scells_add_success}     Create List
    ...    sCellToAddModList
    ...    physCellId 51
    ...    physCellId 62
    ...    eventId eventA2
    ...    SCellIndex 1 activated successfully
    ...    SCellIndex 2 activated successfully
    Triggered Scell Addition by A1 Event    ue_id=${ue_id}    rsrp=${rsrp}    pass_regexp=${scells_add_success}
    Check Scell Number     ue_id=${ue_id}    expected_scell_num=2
    Check Traffic    ue_id=${ue_id}    cell_num=3    pdu_id=${pdu_id}    min_dl_tput=${dl_tput}

Scell_12_13 Added
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${rsrp}=80    ${dl_tput}=100
    log to console      ----------------UE${ue_id}: cell13:maxscellnum=1, A1 add scell_12_13----------------
    ${scells_add_success}     Create List
    ...    sCellToAddModList
    ...    physCellId 61
    ...    physCellId 62
    ...    SCellIndex 2 activated successfully
    Triggered Scell Addition by A1 Event    ue_id=${ue_id}    rsrp=80    pass_regexp=${scells_add_success}
    Check Scell Number     ue_id=${ue_id}    expected_scell_num=2
    Check Traffic    ue_id=${ue_id}    cell_num=3    pdu_id=${pdu_id}    min_dl_tput=${dl_tput}

Scell_11_13 Added
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${rsrp}=80    ${dl_tput}=100
    log to console      ----------------UE${ue_id}: cell-13:maxNumOfSCellAlloc=2, A1 add scell_11_13----------------
    ${scells_add_success}     Create List
    ...    sCellToAddModList
    ...    physCellId 60
    ...    physCellId 62
    ...    SCellIndex 1 activated successfully
    ...    SCellIndex 2 activated successfully
    Triggered Scell Addition by A1 Event    ue_id=${ue_id}    rsrp=${rsrp}    pass_regexp=${scells_add_success}
    Check Scell Number     ue_id=${ue_id}    expected_scell_num=2
    Check Traffic    ue_id=${ue_id}    cell_num=3    pdu_id=${pdu_id}    min_dl_tput=${dl_tput}
