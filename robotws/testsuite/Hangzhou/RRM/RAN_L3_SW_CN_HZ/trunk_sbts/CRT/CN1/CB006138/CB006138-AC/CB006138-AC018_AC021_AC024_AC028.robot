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
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:actBeamforming=false
...    NRCELL:actCDrx=false
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=60
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-1:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=40
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-13:weightForSCellSelection=60
...    NRCELL-1:msg1FrequencyStart=16
...    NRCELL-11:msg1FrequencyStart=11
...    NRCELL-12:msg1FrequencyStart=12
...    NRCELL-13:msg1FrequencyStart=11
...    NRCELL-14:msg1FrequencyStart=13
...    @{CELL_NRREL}
...    @{CELL_NRHOIF}

${CA_SUPPORT_LIST}    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa

@{CELL_NRREL}
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:lcrId=2
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:removeNotAllowed=false
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

@{CELL_NRHOIF}
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

@{AC021_CHANGE_PCELL_SWITCH_AND_SCELL_WEIGHT}
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrq
...    NRCELL-1:a2MeasPCellSwitchSsbRsrq:a2HysteresisPCellSwitchSsbRsrq=0
...    NRCELL-1:a2MeasPCellSwitchSsbRsrq:a2ThresholdPCellSwitchSsbRsrq=30
...    NRCELL-1:a2MeasPCellSwitchSsbRsrq:a2TimeToTriggerPCellSwitchSsbRsrq=0ms
...    NRCELL-1:a2MeasPCellSwitchSsbRsrq:pCellSwitchOffsetSsbRsrq=0
...    NRCELL-2:weightForSCellSelection=1
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchPriority=1
@{AC021_CHANGE_PCELL_SWITCH_AND_SCELL_WEIGHT_BACK}
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchPriority=9

@{AC028_TDD_SCELL_WEIGHT_CHANGE}
...    NRCELL-2:weightForSCellSelection=16
@{AC028_TDD_SCELL_WEIGHT_CHANGE_BACK}
...    NRCELL-2:weightForSCellSelection=50

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

@{PM_COUNTERS_CHECK}
...     NRCELL-1:${UE_PCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-1:${RRC_RECONF_ADD2DLSCELL_SUCC_SA}==1
...     NRCELL-1:${RRC_RECONF_ADD2DLSCELL_ATT_SA}==1
...     NRCELL-2:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...     NRCELL-13:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
${UE_PCELL_2_CONF_SCELL_DL_SA}    M55118C07001
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002
${RRC_RECONF_ADD2DLSCELL_SUCC_SA}    M55118C07003
${RRC_RECONF_ADD2DLSCELL_ATT_SA}    M55118C07004

&{CELLS_CARRIER_FREQ}
...     1=518910
...     2=633216
...     11=424090
...     12=126750
...     13=427970




*** Test Cases ***
CB006138-ET-AC018_A2_trigger_Pcell_change_RSRP_successful_when_FDD_scell_selected_for_TDD-TDD-FDD
    [Documentation]
    ...    1. The purpose of this test case is to check PCell change to current FDD SCell for SA from TDD cell base on
    ...       RSRP for FR1 TDD-FR1 TDD-FDD 3CC CA config to FDD only
    ...    2. Precondition:
    ...         a. a1ThresholdSCellAddSsbRsrpFDD=75, a1ThresholdSCellAddSsbRsrpTDD=95
    ...         b. weightForSCellSelection: cell_2=50, cell_11=40, cell_12=50, cell_13=60
    ...         c. a2MeasPCellSwitchEnabled: rsrp, a2ThresholdPCellSwitchSsbRsrp: 60
    ...    3. Test Case Steps:
    ...         a. make SA UE-81 attach to cell 1
    ...         b. check A1 meas config in RRC Reconfig
    ...         c. A1 measurement report based SCell addition is triggered with rsrp=100
    ...         d. A2 measurement report based PCell change with PCell RSRP below threashold and SCell RSRP is good enough
    ...         e: check the counter: 'M55118C07001', 'M55118C07002', 'M55118C07003', 'M55118C07004'
    ...    4. Expected Results:
    ...         Step a: UE attach to cell 1 success
    ...         Step c: Cell2 and Cell13 as SCell addition success
    ...         Step d: PCell change to Cell_13 success
    ...         Step e: counters updated accordingly
    [Tags]    QC_133947
    [Timeout]     60 min
    Clear Counter Files
    Start RRC Log    AC018
    UE Attach to GNB2 Cell1
    Scell_2_13 Added Based On High Rsrp
    Start Traffic
    Check Traffic    cell_num=3    min_dl_tput=350
    Switch Pcell From cell1 To cell13 With Low Pcell RSRP and High Scell RSRP
    Check Traffic    cell_num=1    min_dl_tput=130
    Stop Traffic and UE Detach
    Check Counters     ${PM_COUNTERS_CHECK}


CB006138-ET-AC021_A2_trigger_Pcell_change_RSRQ_successful_when_diff_priority_FDD_scell_selected_for_TDD-FDD-FDD
    [Documentation]
    ...    1. The purpose of this test case is to check PCell change to current FDD SCell for SA from TDD cell base on
    ...       RSRQ when different priority FDD cell for FR1 TDD-FR1 FDD-FDD 3CC CA config to FDD only
    ...    2. Precondition:
    ...         a. a1ThresholdSCellAddSsbRsrpFDD=75, a1ThresholdSCellAddSsbRsrpTDD=95, a2ThresholdPCellSwitchSsbRsrq=30
    ...         b. weightForSCellSelection: cell_2=50, cell_11=40, cell_12=50, cell_13=60
    ...         c. 'a2BasedPCellSwitchPriority': '1' for cell_12  (1 is the highest priority and 9 is the lowest priority)
    ...         d. 'weightForSCellSelection': '1' for cell_2 to make the weight as the lowest
    ...    3. Test Case Steps:
    ...         a. make SA UE-81 attach to cell 1 start data transfer
    ...         b. check A1 meas config in RRC Reconfig
    ...         c. A1 measurement report based SCell addition is triggered with rsrp=100
    ...         d. A2 measurement report based PCell change with PCell RSRQ below threashold and SCell RSRQ is good enough
    ...    4. Expected Results:
    ...         Step a: UE attach to cell 1 and data transfer success
    ...         Step c: Cell12 and Cell13 as SCell addition success
    ...         Step d: PCell change to Cell12 success
    [Tags]    QC_133946
    [Timeout]     60 min
    Delta Commission Parameters     ${AC021_CHANGE_PCELL_SWITCH_AND_SCELL_WEIGHT}
    UE Attach to GNB2 Cell1
    Start RRC Log    AC021
    Scell_12_13 Added Based On High Rsrp
    Start Traffic
    Check Traffic    cell_num=3    min_dl_tput=350
    Switch Pcell From cell1 To cell12 With Low Pcell RSRQ and High Scell RSRQ
    Check Traffic    cell_num=1    min_dl_tput=130
    Stop Traffic and UE Detach
    [Teardown]    Recover Param and Common Test Teardown    ${AC021_CHANGE_PCELL_SWITCH_AND_SCELL_WEIGHT_BACK}


CB006138-ET-AC024_SCell_release_triggered_stepwise_then_scell_change_for_TDD-FDD-FDD
    [Documentation]
    ...    1. The purpose of this test case is to check 2CC CA SCell Change Functionality Interworking for SA
    ...       for FR1 TDD-FR1 FDD-FDD 3CC CA config to FDD only
    ...    2. Precondition:
    ...         a. a1ThresholdSCellAddSsbRsrpFDD=75, a1ThresholdSCellAddSsbRsrpTDD=95
    ...         b. weightForSCellSelection: cell_2=50, cell_11=40, cell_12=50, cell_13=60
    ...    3. Test Case Steps:
    ...         a. make SA UE-81 attach to cell 1 start data transfer
    ...         b. check A1 meas config in RRC Reconfig
    ...         c. A1 measurement report based SCell addition is triggered with rsrp=80
    ...         d. A2 measurement report release 1 SCell
    ...         e. A1 measurement report for scell change is triggered with rsrp=100
    ...    4. Expected Results:
    ...         Step a: UE attach to cell 1 and data transfer success
    ...         Step c: Cell_12 and Cell_13 as SCell addition success
    ...         Step d: SCell_12 release success
    ...         Step e: scell changed from cell_13 to cell_2
    [Tags]    QC_133945
    [Timeout]     60 min
    UE Attach to GNB2 Cell1
    Start RRC Log    AC024
    Scell_12_13 Added Based On Rsrp Higher than FDD but Lower than TDD
    Start Traffic
    Check Traffic    cell_num=3    min_dl_tput=350
    Release Scell    12
    Scell Change From cell13 to Cell2 With Rsrp Higher than TDD
    Check Traffic    cell_num=2    min_dl_tput=350
    Release Scell    2
    Stop Traffic and UE Detach

CB006138-ET-AC028_A2_trigger_Pcell_change_RSRP_successful_when_equal_priority_diff_rsrp_FDD_scell_selected_for_TDD-FDD-FDD
    [Documentation]
    ...    1. The purpose of this test case is to check PCell change to current FDD SCell for SA from TDD cell base on
    ...       RSRP when equal priority FDD cell for FR1 TDD-FR1 TDD-FDD 3CC CA config to FDD only
    ...    2. Precondition:
    ...         a. a1ThresholdSCellAddSsbRsrpFDD=75, a1ThresholdSCellAddSsbRsrpTDD=95
    ...         b. weightForSCellSelection: cell_2=50, cell_11=40, cell_12=50, cell_13=60
    ...         c. a2MeasPCellSwitchEnabled: rsrp, a2ThresholdPCellSwitchSsbRsrp: 60
    ...         d. online change weightForSCellSelection to 16 for cell_2 in order to not be selected as scell
    ...    3. Test Case Steps:
    ...         a. make SA UE-81 attach to cell 1 start data transfer
    ...         b. check A1 meas config in RRC Reconfig
    ...         c. A1 measurement report based SCell addition is triggered for rsrp=100
    ...         d. A2 measurement report based PCell change with PCell RSRP below threashold and SCell RSRP is better
    ...    4. Expected Results:
    ...         Step a: UE attach to cell 1 and data transfer success
    ...         Step c: Cell_12 and Cell_13 as SCell addition success
    ...         Step d: PCell change to Cell_13 success
    [Tags]    QC_133944
    [Timeout]     60 min
    UE Attach to GNB2 Cell1
    Start RRC Log    AC028
    Delta Commission Parameters    ${AC028_TDD_SCELL_WEIGHT_CHANGE}
    Scell_12_13 Added Based On High Rsrp
    Start Traffic
    Check Traffic    cell_num=3    min_dl_tput=350
    Swith Pcell to Cell13 With Low Pcell RSRP and Scell13 RSRP Higher than SCell12
    Check Traffic    cell_num=1    min_dl_tput=130
    Stop Traffic and UE Detach
    [Teardown]    Recover Param and Common Test Teardown    ${AC028_TDD_SCELL_WEIGHT_CHANGE_BACK}


*** Keywords ***
Modify Cfg
    Update Cfg    ue_param id=81 ue_nr_capabilities=${SA_Capa_perUE_Full}
    Update Cfg    set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=4 ue_nat_ip=72.23.3.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1

Recover Param and Common Test Teardown
    [Arguments]     ${origin_params}
    Delta Commission Parameters     ${origin_params}
    Common Test Teardown And Stop Capture Logs

UE Attach to GNB2 Cell1
    [Arguments]    ${pdu_id}=1
    ${ret}    Execute Egate Command    ue_change_location id=81 enb=2 cell=1    location
    Should Contain Any    ${ret}    location updated    already there
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=81     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=81 pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=81 nwslice=1 gw=${pdu_id}
    ...                      pass_regexp=QoS Routing Table

Triggered Scell Addition by A1 Event
    [Arguments]    ${rsrp}=100    ${rsrq}=30    ${scell_num}=2
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    1
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=81    carrierfreq=${pcell_carrier_freq}    event_type=A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=81 meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrq}
    ...    pass_regexp=SCellIndex ${scell_num} activated successfully

Check Scell Number
    [Arguments]    ${expected_scell_num}=0
    ${meas_obj}     Execute Egate Command    ue_meas_cfg_disp id=81 meas_obj_type=nr
    ...     fail_regexp=no NR MEASUREMENT IDENTITIES
    ${meas_data}    Parse Nr Ue Meas Cfg    ${meas_obj}
    ${meas_obj_num}    Get Length      ${meas_data['nr_measurment_objects']}
    ${real_scell_num}    Evaluate    ${meas_obj_num}-1
    Should Be Equal As Integers     ${expected_scell_num}    ${real_scell_num}

Scell Change From cell13 to Cell2 With Rsrp Higher than TDD
    Triggered Scell Addition by A1 Event    rsrp=100    scell_num=1
    Check Scell Number    expected_scell_num=1
    Rrc Should Contain    sCellToAddModList    physCellId 51    sCellToReleaseList

Release Scell
    [Arguments]     ${scell}
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     ${scell}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=81    carrierfreq=${carrier_freq}    event_type=A2
    ${release_cmd}    Catenate    ue_measurement_send_nr id=81 meas_id=${meas_id} event=A2
    ...    scell=1 scell_rsrp=20 scell_rsrq=20
    Execute Egate Command    ${release_cmd}    pass_regexp=sCellToReleaseList

Scell_2_13 Added Based On High Rsrp
    Triggered Scell Addition by A1 Event    rsrp=100    scell_num=2
    Check Scell Number    expected_scell_num=2
    Rrc Should Contain    sCellToAddModList    physCellId 51    physCellId 62

Scell_12_13 Added Based On High Rsrp
    Triggered Scell Addition by A1 Event    rsrp=100    scell_num=2
    Check Scell Number    expected_scell_num=2
    Rrc Should Contain    sCellToAddModList    physCellId 61    physCellId 62

Scell_12_13 Added Based On Rsrp Higher than FDD but Lower than TDD
    Triggered Scell Addition by A1 Event    rsrp=80    scell_num=2
    Check Scell Number    expected_scell_num=2
    Rrc Should Contain    sCellToAddModList    physCellId 61    physCellId 62

Switch Pcell From cell1 To cell13 With Low Pcell RSRP and High Scell RSRP
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     1
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=81    carrierfreq=${carrier_freq}    event_type=A2
    ${egate_cmd}    Catenate    ue_measurement_send_nr id=81 event=A2 meas_id=${meas_id} srsrp_nr=11 srsrq_nr=11
    ...    scell=1 scell_rsrp=100 scell_rsrq=45 scell=2 scell_rsrp=100 scell_rsrq=45
    ${ret}    Execute Egate Command     ${egate_cmd}
    ...    pass_regexp=UE81: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.13 performed
    Should Contain    ${ret}    sCellToReleaseList
    Should Contain    ${ret}    rrcReconfigurationComplete

Switch Pcell From cell1 To cell12 With Low Pcell RSRQ and High Scell RSRQ
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     1
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=81    carrierfreq=${carrier_freq}    event_type=A2
    ${egate_cmd}    Catenate    ue_measurement_send_nr id=81 event=A2 meas_id=${meas_id} srsrp_nr=11 srsrq_nr=11
    ...    scell=1 scell_rsrp=100 scell_rsrq=45 scell=2 scell_rsrp=100 scell_rsrq=45
    ${ret}    Execute Egate Command     ${egate_cmd}
    ...    pass_regexp=UE81: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.12 performed
    Should Contain    ${ret}    sCellToReleaseList
    Should Contain    ${ret}    rrcReconfigurationComplete

Swith Pcell to Cell13 With Low Pcell RSRP and Scell13 RSRP Higher than SCell12
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     1
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=81    carrierfreq=${carrier_freq}    event_type=A2
    ${egate_cmd}    Catenate    ue_measurement_send_nr id=81 event=A2 meas_id=${meas_id} srsrp_nr=11 srsrq_nr=11
    ...    scell=1 scell_rsrp=80 scell_rsrq=45 scell=2 scell_rsrp=100 scell_rsrq=45
    ${ret}    Execute Egate Command     ${egate_cmd}
    ...    pass_regexp=UE81: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.13 performed
    Should Contain    ${ret}    sCellToReleaseList
    Should Contain    ${ret}    rrcReconfigurationComplete

Start Traffic
    [Arguments]    ${ue_id}=81    ${pdu_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=dl mbps=150 trf_id=1
    ...                      pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=dl mbps=150 trf_id=2
    ...                      pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=dl mbps=100 trf_id=3
    ...                      pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} dir=ul mbps=10 trf_id=7
    ...                      pass_regexp=UE${ue_id}: Started Uplink Internal traffic

Stop Traffic and UE Detach
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_stop ue=${ue_id}    pass_regexp=Traffic was stopped
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached

Check Traffic
    [Arguments]     ${ue_id}=81   ${cell_num}=3    ${pdu_id}=1    ${min_dl_tput}=70    ${min_ul_tput}=9
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
