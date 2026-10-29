*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-L3CN1_SG14    owner-jun.3.ye    release-SBTS00    CNI97068
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    fddtdd_sansa_cmwv/6cells_2T4F

@{PARAMS_IN_SCF}
...    NRBTS:srb3SupportEnabled=true
...    NRBTS:cipherPrefL:nea0=1
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRCELL-11:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-11:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-11:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-11:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL-11:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL-11:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL-11:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-11:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-11:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-11:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-11:a3MeasSsbRsrq:a3OffsetSsbRsrq=5
...    NRCELL-11:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms0
...    NRCELL-11:absThreshSsbRsrqConsolidation=10
...    NRCELL-11:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-11:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRCELL-11:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRCELL-11:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-12:a2MeashoEnabled=rsrqCombined
...    NRCELL-12:actCDrx=true
...    NRCELL-12:a1MeashoEnabled=rsrp
...    NRCELL-11:a2MeashoEnabled=rsrqCombined
...    NRCELL-11:actCDrx=true
...    NRCELL-11:a1MeashoEnabled=rsrp
...    NRCELL-11:absThreshSsbRsrpConsolidation=1
...    NRCELL-12:absThreshSsbRsrpConsolidation=1
...    NRCELL-11:sMeasConfigSsbRsrp=1
...    NRCELL-12:sMeasConfigSsbRsrp=1
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-12:measGapSelectionSA=favourUeThroughput
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:lcrId=12
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRHOIF-1:cellDepType=NSA
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrq
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=25
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms0
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=10
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...    NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssbFrequency=126750
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:scs=15 KHz
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:lcrId=11
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRHOIF-1:cellDepType=NSA
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrq
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=25
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms0
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=10
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:ssbFrequency=424090
...    NRCELL-12/NRHOIF-1:scs=15 KHz
...    NRCELL-12:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-12:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRCELL-12:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRCELL-12:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-12:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-12:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-12:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-12:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-12:a3MeasSsbRsrq:a3OffsetSsbRsrq=5
...    NRCELL-12:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms0
...    NRCELL-12:absThreshSsbRsrqConsolidation=10

${X2_SGNB_MEASGP_SETUP_REQST}    M55112C00022
${X2_SGNB_MEASGP_SETUP_ACK}    M55112C00023
${X2_SGNB_MEASGP_REQUIRED}    M55112C00024
${X2_SGNB_MEASGP_SETUP_RQST_MRQD}    M55112C00025
${X2_SGNB_MEASGP_SETUP_CONFIRM}    M55112C00026


@{Measurement_Gap_related_counters_Check}
...    NRCELL-11:NX2CC:${X2_SGNB_MEASGP_SETUP_REQST}=5
...    NRCELL-11:NX2CC:${X2_SGNB_MEASGP_SETUP_ACK}=5
...    NRCELL-11:NX2CC:${X2_SGNB_MEASGP_REQUIRED}=4
...    NRCELL-11:NX2CC:${X2_SGNB_MEASGP_SETUP_RQST_MRQD}=3
...    NRCELL-11:NX2CC:${X2_SGNB_MEASGP_SETUP_CONFIRM}=2
...    NRCELL-12:NX2CC:${X2_SGNB_MEASGP_SETUP_REQST}=0
...    NRCELL-12:NX2CC:${X2_SGNB_MEASGP_SETUP_ACK}=0
...    NRCELL-12:NX2CC:${X2_SGNB_MEASGP_REQUIRED}=0
...    NRCELL-12:NX2CC:${X2_SGNB_MEASGP_SETUP_RQST_MRQD}=0
...    NRCELL-12:NX2CC:${X2_SGNB_MEASGP_SETUP_CONFIRM}=0

@{PScell_change_check}
...    handover-desirable-for-radio-reasons
...    physCellId 61
...    eventId eventA2
...    Successfully reconfigured dual connectivity
...    Sending SgNB Modification Confirm
...    drx-Config setup
...    rrcReconfigurationComplete:::2

####UE support perFR1 measurement gap configure### 
${SA_Capa_perFR1_Full_supportedGapPattern}    SEPARATOR=
...    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C03EE3614606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F1891C790E7D4
...    73E618F28581C0E1E0B801FF800E000BE000C80000E0541B107582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000C8
...    0000E0551B137582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702A0D88DAC1184341020F10780195B262AC
...    4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC000006400007003DE1E26800710400000858081507850001C46000002160561E230007104000018581587
...    850001C41000002160561E26800711800000858158B88C001C41000E208000050B02B0F0A000389A0000182C0AC5C4D000E2080070A000002058158B89A001C46000E23000002
...    0B02B170A0003882001C46000004160562E1400071040038820000082C0AC5C4D000E20800711800001058158B850001C46000E230000020B02B1713400388C001C2800000816
...    0561E230007118000018581007011A014404D808232800BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1C
...    F811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6318C6318C6318C61FBFFFFF0D800780070382803
...    81804A00E000C0480080C07C120040000000200000401000000008000010040000100200000C01000008008000050040020080200800006004000038020010000000400004002
...    000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA48
...    080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA95
...    45D2A8AA0B154162A83455298AA4D154062A8145526AAA0F14340178095028140A05028140A05028140A05028140A050281400182020180300801002101002008040300610080
...    100202018030080600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406080C0E1416181A202224262830323
...    6383A3E424A4C4E5052545A5E828305A0

####UE support perUE measurement gap configure###
${SA_Capa_perUE_Full_supportedGapPattern}    SEPARATOR=
...    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C03EE3614606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F1891C790E7D4
...    73E618F28581C0E1E0B801FF800E000BE000C80000E0541B107582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000C8
...    0000E0551B137582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702A0D88DAC1184341020F10780195B262AC
...    4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC000006400007003DE1E26800710400000858081507850001C46000002160561E230007104000018581587
...    850001C41000002160561E26800711800000858158B88C001C41000E208000050B02B0F0A000389A0000182C0AC5C4D000E2080070A000002058158B89A001C46000E23000002
...    0B02B170A0003882001C46000004160562E1400071040038820000082C0AC5C4D000E20800711800001058158B850001C46000E230000020B02B1713400388C001C2800000816
...    0561E230007118000018581007011A014404D808232800BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1C
...    F811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6318C6318C6318C61FBFFFFF0D800780050382803
...    81804A00E000C0480080C07C120040000000200000401000000008000010040000100200000C01000008008000050040020080200800006004000038020010000000400004002
...    000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA48
...    080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA95
...    45D2A8AA0B154162A83455298AA4D154062A8145526AAA0F14340178095028140A05028140A05028140A05028140A050281400182020180300801002101002008040300610080
...    100202018030080600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406080C0E1416181A202224262830323
...    6383A3E424A4C4E5052545A5E828305A0

###UE support measurement gap configure####
${Capa_LTE_supportedGapPattern}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A00038820000002C040BC4C0C03882001C460000
...    02160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001C041809A26002E41E24E8913639F0E24E8913639F0E24E8913639F0E24
...    E8913639F0E24E8912639F469D1224498E7D127448931CF830082000080404008020100C01840001008080100202018030C0002010100C01804030060100C0184000100808010
...    04020040100000000

###UE not support measurement gap configure####
${Capa_LTE_not_supportedGapPattern}    SEPARATOR=
...    A11DF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A00038820000002C040BC4C0C03882001C460000
...    02160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001C041809A320005C83C49D1226C73E1C49D1226C73E1C49D1226C73E1C4
...    9D1226C73E1C49D1224C73E8D3A2448931CFA24E8912639F060104000100808010040201803080002010100200404030061800040202018030080600C02018030800020101002
...    0080400802000000000

*** Test Cases ***
CNI97068-ET-001_Measurement_Gap_related_counters_increment_during_inter-freq_Measurement_configure_by_SgNB_initiated_Pscell_change
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    this case is to test Measurement Gap-related counters increment during inter-freq Measurement configure by SgNB initiated Pscell change
    ...    equally cover Measurement Gap-related counters increment during SgNB Addition Procedure by MeNB initiated and Measurement Gap failure 
    ...    counters increment during Measurement Gap configre fail with different messages by SgNB modification Request received
    ...    1.Requirement Coverage:
    ...    5G_PM_1172,5G_PM_1173,5G_PM_1174,partially covered
    ...    2.Test Case Steps:
    ...         Step A.Trigger NSA UE91-92 Measurement Gap configure_by SgNB initiated Pscell change
    ...         Step B.Trigger NSA UE93 Measurement Gap configure by MeNB initiated SgNB Addition Procedure
    ...         Step C.Trigger NSA UE94-95 Measurement Gap configure fail with different messages
    ...         Step D.Release UEs
    ...         Step E.Check Measurement Gap-related counters
    ...         Step F.wireshark logs check
    ...    3. Expected Results:
    ...         Step A: 
    ...          1)NSA UE91-92 attach and ENDC establish successfully
    ...          2)NSA UE91-92 MeasurementGap Configure successfull by A2 Event
    ...            a.A2 event is send successfully,A3 or A5 event will be configure successfully 
    ...            b.SgNB-CU-CP sends X2AP: SgNB Modification Required message to MeNB containing the SgNBtoMeNBContainer->measConfigSN IE.
    ...               measConfigSN IE will contain the frequencies to be measured as per Inter-frequency A3 and/or A5 measurements configured
    ...               through O&M parameters.
    ...            c.MeNB sends X2AP: SgNB Modification Request message to SgNB with MeNBtoSgNBContainer->measConfigMN IE which contains the 
    ...               measGapConfig IE.
    ...            d.The SgNB-CU-CP sends F1AP UE Context Modification Request to configure the measurement gap, and DRX will be release 
    ...            e.SgNB-DU receives F1AP UE Context Modification Request message and decodes the configured measurement gap (measGapConfig)
    ...              measGapConfig is contained in "CU to DU RRC Information IE"->CG-ConfigInfo IE->measConfigMN
    ...              measGapConfig is set to "setup"
    ...            f.SgNB-DU applies the measurement gap configuration and schedules the UE based on the measurement gap pattern configured.
    ...            g.SgNB-DU replies F1AP: UE Context Modification Response to SgNB-CU-CP
    ...            h.SgNB-CU-CP then sends the X2AP: SgNB Modification Request Acknowledge to the MeNB with the RRC Reconfiguration with the 
    ...              measConfig IE.
    ...            i.MeNB shall send the X2AP: SgNB Modification Confirm message to SgNB after receiving the RRC Reconfiguration Complete message.
    ...         Step B: 
    ...          1)MeNB triggers SgNB Addition procedure to gNB-CU-CP. MeNB includes measurement gap configuration (by setting measGapConfig to 
    ...            "setup" in MeasConfigMN) inside CG-ConfigInfo in "MeNB to SgNB Container" IE
    ...          2)gNB-CU-CP configures SCG and allocates gNB resources
    ...          3)gNB-DU receives F1AP UE Context Setup Request message, and decode the configured measurement gap (measGapConfig)
    ...          4)gNB-DU replies F1AP UE Context Setup Response to gNB-CU-CP
    ...          5)gNB-CU-CP acknowledges the SgNB Addition procedure to MeNB by sending X2: SgNB Addition Request Acknowledge message including 
    ...            the NR CG-Config message inside "SgNB to MeNB Container IE". The FR-InfoList shall be encoded in RRC CG-Config message, which 
    ...            is encoded as "SgNB to MeNB Container IE"
    ...          6)MeNB reconfigures UE by passing to it the NR CG-Config message
    ...          7)After the successful RA procedure, gNB-DU shall apply the measurement gap configuration, starts scheduling for the UE based on 
    ...            the measurement gap pattern configured
    ...          8)MeNB notifies SgNB about successful UE reconfiguration via SgNB Reconfiguration Completion procedure
    ...          9)NSA UE93 establish ENDC successfully
    ...         Step C: 
    ...          1)NSA UE94 attach and ENDC establish successfully
    ...          2)NSA UE94 MeasurementGap Configure fail by A2 Event with UE drop RRC Reconfiguration Completet
    ...            a.Measurement Gap will not be configure in UE
    ...            b.SgNB-CU-CP sends X2AP: SgNB Modification Required message to MeNB containing the SgNBtoMeNBContainer->measConfigSN IE. 
    ...              measConfigSN IE will contain the frequencies to be measured as per Inter-frequency A3 and or A5 measurements configured 
    ...              through O&M parameters.
    ...            c.MeNB sends X2AP: SgNB Modification Request message to SgNB with MeNBtoSgNBContainer->measConfigMN IE which contains the 
    ...              measGapConfig IE.
    ...            d.The SgNB-CU-CP sends F1AP UE Context Modification Request to configure the measurement gap, and DRX will be release 
    ...            e.SgNB-DU receives F1AP UE Context Modification Request message and decodes the configured measurement gap (measGapConfig)
    ...              measGapConfig is contained in "CU to DU RRC Information IE"->CG-ConfigInfo IE->measConfigMN
    ...              measGapConfig is set to "setup"
    ...            f.SgNB-DU applies the measurement gap configuration and schedules the UE based on the measurement gap pattern configured.
    ...            g.SgNB-DU replies F1AP: UE Context Modification Response to SgNB-CU-CP
    ...            h.SgNB-CU-CP then sends the X2AP: SgNB Modification Request Acknowledge to the MeNB with the RRC Reconfiguration with the 
    ...              measConfig IE
    ...            i.SgNB-CU-CP sends X2AP: SgNBReleaseRequired to MeNB
    ...            k.MeNB shall send the X2AP: SgNBReleaseConfirm to SgNB
    ...          3)NSA UE95 attach and ENDC establish successfully
    ...          4)NSA UE94 MeasurementGap Configure fail by A2 Event with MeNB send X2AP SgNB Modification Refuse
    ...            a.Measurement Gap will not be configure in UE
    ...            b.SgNB-CU-CP sends X2AP: SgNB Modification Required message to MeNB containing the SgNBtoMeNBContainer->measConfigSN IE. 
    ...              measConfigSN IE will contain the frequencies to be measured as per Inter-frequency A3 and/or A5 measurements configured
    ...              through O&M parameters.
    ...            c.MeNB sends X2AP: SgNB Modification Request message to SgNB with MeNBtoSgNBContainer->measConfigMN IE which contains the 
    ...              measGapConfig IE.
    ...            d.The SgNB-CU-CP sends F1AP UE Context Modification Request to configure the measurement gap, and DRX will be release 
    ...            e.SgNB-DU receives F1AP UE Context Modification Request message and decodes the configured measurement gap (measGapConfig)
    ...              measGapConfig is contained in "CU to DU RRC Information IE"->CG-ConfigInfo IE->measConfigMN
    ...              measGapConfig is set to "setup"
    ...            f.SgNB-DU applies the measurement gap configuration and schedules the UE based on the measurement gap pattern configured.
    ...            g.SgNB-DU replies F1AP: UE Context Modification Response to SgNB-CU-CP
    ...            h.SgNB-CU-CP then sends the X2AP: SgNB Modification Request Acknowledge to the MeNB with the RRC Reconfiguration with the 
    ...              measConfig IE
    ...            i.MeNB sends RRC Connected Reconfiguration to UE
    ...            j.UE sends RRC Connected Reconfiguration Completet to MeNB
    ...            k.MeNB shall send the X2AP: SgNB Modification Refuse message to SgNB
    ...         Step D: all ue release is successfully
    ...         Step E: ALL Measurement Gap-related counters is update is correct
    ...         Step F: wireshark logs check passed
    [Tags]    QC_285675    networkmode=NSA
    Clear Counter Files
    Trigger NSA UE91-92 Measurement Gap configure_by SgNB initiated Pscell change
    Trigger NSA UE93 Measurement Gap configure by MeNB initiated SgNB Addition Procedure
    Trigger NSA UE94-95 Measurement Gap configure fail with different messages
    Release UEs    ue_type=all
    Check WireShark Log    ${CURDIR}${/}A2A_CNI97068_001_002_006${/}a2a.ini    wait_string=UEContextReleaseComplete::10
    Check Counters    ${Measurement_Gap_related_counters_Check}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}

Modify Cfg
    ${set_ue simulated_91}    catenate
    ...    set_ue simulated id=91 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc
    ...    imsi=311:489:21645491
    Update Cfg    ${set_ue simulated_91}
    ${set_ue simulated_92}    catenate
    ...    set_ue simulated id=92 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc
    ...    imsi=311:489:21645492
    Update Cfg    ${set_ue simulated_92}
    ${set_ue simulated_93}    catenate
    ...    set_ue simulated id=93 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc
    ...    imsi=311:489:21645493
    Update Cfg    ${set_ue simulated_93}
    ${set_ue simulated_94}    catenate
    ...    set_ue simulated id=94 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc
    ...    imsi=311:489:21645494
    Update Cfg    ${set_ue simulated_94}
    ${set_ue simulated_95}    catenate
    ...    set_ue simulated id=95 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc
    ...    imsi=311:489:21645495
    Update Cfg    ${set_ue simulated_95}
    ${set_ue simulated_96}    catenate
    ...    set_ue simulated id=96 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc
    ...    imsi=311:489:21645496
    Update Cfg    ${set_ue simulated_96}
    ${ue_param_91}    catenate
    ...    ue_param id=91 ue_nr_capabilities=${SA_Capa_perUE_Full_supportedGapPattern} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE_supportedGapPattern}
    Update Cfg    ${ue_param_91}
    ${ue_param_92}    catenate
    ...    ue_param id=92 ue_nr_capabilities=${SA_Capa_perFR1_Full_supportedGapPattern} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE_supportedGapPattern}
    Update Cfg    ${ue_param_92}
    ${ue_param_93}    catenate
    ...    ue_param id=93 ue_nr_capabilities=${SA_Capa_perUE_Full_supportedGapPattern} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE_supportedGapPattern}
    Update Cfg    ${ue_param_93}
    ${ue_param_94}    catenate
    ...    ue_param id=94 ue_nr_capabilities=${SA_Capa_perUE_Full_supportedGapPattern} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE_supportedGapPattern}
    Update Cfg    ${ue_param_94}
    ${ue_param_95}    catenate
    ...    ue_param id=95 ue_nr_capabilities=${SA_Capa_perUE_Full_supportedGapPattern} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE_not_supportedGapPattern}
    Update Cfg    ${ue_param_95}
    ${set_bearer_91}    catenate
    ...    set_bearer id=2 ue=91 qci=9 pdn=1 ip=4.7.254.191 default=on trf_type=internal
    Update Cfg    ${set_bearer_91}
    ${set_bearer_92}    catenate
    ...    set_bearer id=2 ue=92 qci=9 pdn=1 ip=4.7.254.192 default=on trf_type=internal
    Update Cfg    ${set_bearer_92}
    ${set_bearer_93}    catenate
    ...    set_bearer id=2 ue=93 qci=9 pdn=1 ip=4.7.254.193 default=on trf_type=internal
    Update Cfg    ${set_bearer_93}
    ${set_bearer_94}    catenate
    ...    set_bearer id=2 ue=94 qci=9 pdn=1 ip=4.7.254.194 default=on trf_type=internal
    Update Cfg    ${set_bearer_94}
    ${set_bearer_95}    catenate
    ...    set_bearer id=2 ue=95 qci=9 pdn=1 ip=4.7.254.195 default=on trf_type=internal
    Update Cfg    ${set_bearer_95}

Perform Steps After Onair
    Execute Egate Command    enb_cell_param enb=1 id=1 allow_endc=on
    Execute Egate Command    enb_cell_param enb=1 id=2 allow_endc=on

Trigger NSA UE91-92 Measurement Gap configure_by SgNB initiated Pscell change
    NSA UE91-92 Attach And Initial Endc
    NSA UE91-92 MeasurementGap Configure by A2 Event
    Trigger sgnb Initial UE91-92 PScell change to cell_12 with InterFreA3

NSA UE Attach And Initial Endc
    [Arguments]    ${ue_id}=91    ${target_gnb}=2    ${target_cells}=11    ${bearer_id}=2
    Execute Egate Command    ue_attach id=${ue_id} profile=1    pass_regexp=UE IS ACTIVE
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=Successfully reconfigured dual connectivity    timeout=20s
    Traffic Should Be Ok    ue_id=${ue_id}    type=NSA

NSA UE91-92 Attach And Initial Endc
    FOR    ${ue}    IN RANGE    91    93
        NSA UE Attach And Initial Endc    ue_id=${ue}
    END

Set Measurement Gap with different gap purpose and Initial A2 Event
    [Arguments]    ${ue_id}=91    ${cellfreq}=424090    ${gap_purpose}=perUE
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:0 mgta=ms0 gap_purpose=${gap_purpose} gap_trigger=gnb_triggered
    ${Measurement_A2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    ...    threshold=RSRQ\ 31
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${Measurement_A2} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=Sending SgNB Modification Confirm

NSA UE91-92 MeasurementGap Configure by A2 Event
    Set Measurement Gap with different gap purpose and Initial A2 Event    ue_id=91    gap_purpose=perUE
    Set Measurement Gap with different gap purpose and Initial A2 Event    ue_id=92    gap_purpose=perFR1

Trigger sgnb Initial UE91-92 PScell change to cell_12 with InterFreA3
    FOR    ${ue}    IN RANGE    91    93
        Initial UE91-92 PScell change by SGNB    ue_id=${ue}
    END

Initial UE91-92 PScell change by SGNB 
    [Arguments]    ${ue_id}=91    ${cellfreq}=126750    
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=off
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=3 event=A3 srsrp_nr=40 srsrq_nr=40 phycell_id=61 nrsrp_nr=60 nrsrq_nr=60
    ...    pass_regexp=${PScell_change_check}

Trigger NSA UE93 Measurement Gap configure by MeNB initiated SgNB Addition Procedure
    Execute Egate Command    ue_enb_param id=93 measurement_gap=gp0:0 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    NSA UE Attach And Initial Endc    ue_id=93

Trigger NSA UE94-95 Measurement Gap configure fail with different messages
    NSA UE Attach And Initial Endc    ue_id=94
    Trigger Measurement Gap config fail with drop RRC Reconfiguration Completet message    ue_id=94
    NSA UE Attach And Initial Endc    ue_id=95
    Trigger Measurement Gap config fail with X2AP SgNB Modification Refuse    ue_id=95

Trigger Measurement Gap config fail with drop RRC Reconfiguration Completet message
    [Arguments]    ${ue_id}=91    ${cellfreq}=424090
    Execute Egate Command    ue_rrc_reconf_param id=${ue_id} if_contains=any action=drop
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:0 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    ${Measurement_A2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    ...    threshold=RSRQ\ 31
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${Measurement_A2} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=SNStatusTransfer

Trigger Measurement Gap config fail with X2AP SgNB Modification Refuse
    [Arguments]    ${ue_id}=91    ${cellfreq}=424090
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:0 mgta=ms0 gap_purpose=perUE gap_trigger=enb_and_gnb_triggered
    ${cmd}    catenate    link_x2_management_abnormal_cases id=1 partner=2 sgnb_modification_reqd_rsp=modification_conflict
    ...    sgnb_modification_reqd_cause=RN_rRM_purpose
    Execute Egate Command    ${cmd}
    ${Measurement_A2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    ...    threshold=RSRQ\ 31
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${Measurement_A2} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=SgNBModificationRefuse

