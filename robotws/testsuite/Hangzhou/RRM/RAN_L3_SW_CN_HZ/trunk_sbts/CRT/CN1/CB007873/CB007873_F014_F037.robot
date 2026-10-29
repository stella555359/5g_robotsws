*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO
...               team-SG2    owner-huibo.miao    release-5G21B    CB007873-F
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NRARFCN126900}    126750
#${NRARFCN424000}    424090
${NRARFCN424000}    125050

@{PARAMS_IN_SCF}
...    @{CA_Common_Config}
...    @{srb3}
...    @{DRX}
...    @{A3_A5}
...    @{F014_precondition}
...    @{F037_precondition}
...    @{CELL11_CELL-1}
...    @{CELL11_CELL-12}
...    @{CELL12_CELL-11}
...    @{CELL12_CELL-3}

@{F014_precondition}
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:scs=15 KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:ssbFrequency=${NRARFCN424000}
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10

...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:scs=15 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:ssbFrequency=${NRARFCN126900}
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10

...    NRCELL-11:a1MeashoEnabled=rsrp
...    NRCELL-11:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-11:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-11:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-11:a2MeashoEnabled=rsrp
...    NRCELL-11:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-11:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-11:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480

...    NRCELL-12:a1MeashoEnabled=rsrp
...    NRCELL-12:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-12:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-12:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-12:a2MeashoEnabled=rsrp
...    NRCELL-12:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-12:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-12:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480

@{F037_precondition}
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-1:prachConfigurationIndex=98
...    delete:NRCELL-1:tddFrameStructure:tdLteUlDlConfig
...    delete:NRCELL-1:tddFrameStructure:lteToNrFrameShift

...    NRCELL-2:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-2:prachConfigurationIndex=98
...    delete:NRCELL-2:tddFrameStructure:tdLteUlDlConfig
...    delete:NRCELL-2:tddFrameStructure:lteToNrFrameShift

...    NRCELL-3:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-3:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-3:tddFrameStructure:ulDlDataSlotRatio=3/7
...    NRCELL-3:prachConfigurationIndex=98
...    delete:NRCELL-3:tddFrameStructure:tdLteUlDlConfig
...    delete:NRCELL-3:tddFrameStructure:lteToNrFrameShift

...    NRCELL-4:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-4:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-4:tddFrameStructure:ulDlDataSlotRatio=3/7
...    NRCELL-4:prachConfigurationIndex=98
...    delete:NRCELL-4:tddFrameStructure:tdLteUlDlConfig
...    delete:NRCELL-4:tddFrameStructure:lteToNrFrameShift

@{CA_Common_Config}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Nsa
...    NRDU-1:actConnectedModeMobilityCA=true

@{srb3}
...    NRBTS:srb3SupportEnabled=true
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=9
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=0
...    NRBTS:integrityProtPrefL:nia3_128=9

@{DRX}
...    NRCELL-11:actCDrx=true
...    NRCELL-12:actCDrx=true

@{A3_A5}
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:rsrpThresholdSSB=11
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:sMeasConfigSsbRsrp=1

@{CELL11_CELL-1}
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed

@{CELL11_CELL-12}
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-12:gNbId=1
...    NRCELL-11/NRREL-12:gNbIdLength=22
...    NRCELL-11/NRREL-12:lcrId=12
...    NRCELL-11/NRREL-12:removeNotAllowed=false
...    NRCELL-11/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-12:handoverAllowedSA=allowed

@{CELL12_CELL-11}
...    NRCELL-12/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-11:gNbId=1
...    NRCELL-12/NRREL-11:gNbIdLength=22
...    NRCELL-12/NRREL-11:lcrId=11
...    NRCELL-12/NRREL-11:removeNotAllowed=false
...    NRCELL-12/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-11:handoverAllowedSA=allowed

@{CELL12_CELL-3}
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:lcrId=3
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:handoverAllowedSA=allowed

@{PM_Counters_Check_F014_F037}
...    NRCELL-11:${RRC_RECONF_1_SCELL_DL_ATT}=2
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-11:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-11:${SGNB_DU_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-11:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-11:${SGNB_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-11:${SGNB_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-11:${SGNB_SCELL_ADMISSION_UNSUCC}=0
...    NRCELL-12:${SGNB_SCELL_ADMISSION_UNSUCC}=0
...    NRCELL-11:${SGNB_DU_NSA_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_REQ}=1
...    NRCELL-11:${SGNB_DU_NSA_ADMISSION_SUCC}=2
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_SUCC}=1
...    NRCELL-1:${SGNB_DU_SCELL_ADMISSION_REQ}=2
...    NRCELL-1:${SGNB_DU_SCELL_ADMISSION_SUCC}=2
...    NRCELL-3:${SGNB_DU_SCELL_ADMISSION_REQ}=1
...    NRCELL-3:${SGNB_DU_SCELL_ADMISSION_SUCC}=1

${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015
${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028
${SGNB_SCELL_ADMISSION_UNSUCC}    M55114C00035
${SGNB_DU_NSA_ADMISSION_REQ}    M55115C00002
${SGNB_DU_NSA_ADMISSION_SUCC}    M55115C00003
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007

${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1CF88E3D033EC09F1891C
...    790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD800
...    0007F600000044000702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC00110001C0AE3E236B04610
...    D04083E50480AAD931561439F11C78C0000000000000000000001E027F0000001FC000000110001C00F78789A001C4100000216020541E1400071180000085815878
...    8C001C41000006160561E14000710400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C280000
...    08160562E26800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E140007118003
...    88C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C0468051013602086A0BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1
...    C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040
...    D8E7C00170F18C6318C6318C6318C61E8260078005038280381804A00E000C0480080C07C120040000000200000401000000008000010040000100200000C0100000
...    8008000050040020080200800006004000038020010000000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC1
...    5ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112
...    CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142405E0
...    2540A05028140A05028140A05028140A05028140A05000608080600C02004008404008020100C018402004008080600C02018030404030060100C018402004008080
...    600C02004008804030060100C018040300608080100402004010D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168

${Capa_LTE}    SEPARATOR=
...    A11FF82B84C0C03850001C46000000122205C160601C46000002022205C160601828000104888170785000184600018488817080071340038820000002444080
...    2808D00A00189A007105893A24ED8E7C3853A76C0000449D1276C000044036000002408100160518C63180C01880002010100200804030060800040202018030
...    40002010100200020200401008060000

*** Test Cases ***
CB007873-5G-ET-F014_F037_Verify_NSA_A3_rsrp_interfreq_intragNB_HO_successful_with_SRB3_from_CA_to_CA_with_Scell_different_framestructure
    [Documentation]    This case will test A3 rsrp inter-Freq, IntragNB HO from CA(F+T) to CA(F+T) with SRB3,
    ...                scell in source/target should be with the different framestructures
    ...    preconditions:
    ...        1. configure different framestructure for source/target scells. source: 1/4 while target: 3/7
    ...        2. Both pcell drx enable
    ...    Case steps:
    ...        1.F+T: pscell is cell-11 (phycellId=60), with blind scell cell-1 (phycellId=50,framestructure:1/4),drx setup
    ...        2.Trigger A2/A3 to handover to cell-12 (phycellId=61) with blind scell of cell-3 (physcellid=52, framestructure:3/7)
    ...        3.Trigger A2/A3 to handoverback to CA(Pscell is cell-11,scell is cell-1)
    ...        4.Traffic is checked after step1/step2/step3

    [Tags]    QC_89203
    Clear Counter files
    Ue Attach To Cell and Initial Endc Blind Ca
    Set MeasurementGap and Initial A2 Event    ${NRARFCN424000}
    Trigger Measurement Report to cell12 and scell addition    A3
    Set MeasurementGap and Initial A2 Event    ${NRARFCN126900}
    Trigger Measurement Report back to cell11 and scell addition    A3
    Check Counters    ${PM_Counters_Check_F014_F037}
    Check Wireshark Log    ${CURDIR}${/}a2a_F014_F037${/}a2a_wireshark.ini    wait_string=SgNBModificationConfirm::6
    UE Detach From GNB

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F

Ue Attach To Cell and Initial Endc Blind Ca
    Execute Egate Command    ue_change_location id=91 cell=1 enb=1
    UE Attach To Enb Cell1    ue_id=91
    Initial Endc And Blind Ca    ue_id=91    target_gnb=2    target_cells=11    bearer_id=2
    Send And Verify Throuput

UE Attach To Enb Cell1
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE

Initial Endc And Blind Ca
    [Arguments]    ${ue_id}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=1
    ${ret1}=    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    SCellIndex 9 activated successfully
    Should Contain    ${ret1}    SCellIndex 9 activated successfully

Send And Verify Throuput
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=100 trf_id=2    UE 91: UDP DL
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
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>82

Trigger Measurement Report to cell12 and scell addition
    [Arguments]    ${event_type}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=${NRARFCN126900}    event_type=${event_type}
    ${V2}    catenate
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=${event_type} srsrp_nr=11 srsrq_nr=11 phycell_id=61 nrsrp_nr=30 nrsrq_nr=30
    ${output2}    Execute Egate Command    ${V2}    SgNBModificationConfirm
    Should Contain    ${output2}    SCellIndex 9 activated successfully
    Verify Throuput

Trigger Measurement Report back to cell11 and scell addition
    [Arguments]    ${event_type}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=${NRARFCN424000}    event_type=${event_type}
    ${V3}    catenate
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=${event_type} srsrp_nr=11 srsrq_nr=11 phycell_id=60 nrsrp_nr=30 nrsrq_nr=30
    ${output3}    Execute Egate Command    ${V3}    SgNBModificationConfirm
    Should Contain    ${output3}    SCellIndex 9 activated successfully
    Verify Throuput

Set MeasurementGap and Initial A2 Event
    [Arguments]    ${carrierfreq}
    Execute Egate Command    ue_enb_param id=91 measurement_gap=gp0:12 gap_trigger=gnb_triggered
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=${carrierfreq}    event_type=A2
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=Sending SgNB Modification Confirm
    Should Contain    ${ret1}    measGapConfig setup
    Should Contain    ${ret1}    drx-Config release : NULL

UE Detach From GNB
  [Arguments]    ${expect_string}=${EMPTY}
  Execute Egate Command    ue_detach id=91    ${expect_string}
