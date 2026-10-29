*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CIT    CLOUD_5G_I_BOO_AP_LOO
...    team-DevHZ5_SG2    owner-song.xiuli    release-SBTS00    5GC002199
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    fddtdd_sansa_cmwv/6cells_2T4F
@{PARAMS_IN_SCF}
...  NRBTS:srb3SupportEnabled=true
...  NRBTS:cipherPrefL:nea0=1
...  NRBTS:cipherPrefL:nea1_128=0
...  NRBTS:cipherPrefL:nea2_128=0
...  NRBTS:cipherPrefL:nea3_128=0
...  NRBTS:actConflictConfiguration=true
...  NRBTS:actInterFreqIntraGnbMobilityNSA=true
...  NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...  NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=1
...  NRCELL-11:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...  NRCELL-11:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...  NRCELL-11:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...  NRCELL-11:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...  NRCELL-11:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...  NRCELL-11:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...  NRCELL-11:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...  NRCELL-11:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...  NRCELL-11:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...  NRCELL-11:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...  NRCELL-11:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...  NRCELL-11:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...  NRCELL-11:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...  NRCELL-12:a2MeashoEnabled=rsrp
...  NRCELL-12:actCDrx=true
...  NRCELL-12:a1MeashoEnabled=rsrp
...  NRCELL-11:a2MeashoEnabled=rsrp
...  NRCELL-11:actCDrx=true
...  NRCELL-11:a1MeashoEnabled=rsrp
...  NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...  NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...  NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...  NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...  NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...  NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...  NRCELL-11/NRREL-1:gNbId=1
...  NRCELL-11/NRREL-1:lcrId=12
...  NRCELL-11/NRREL-1:gNbIdLength=22
...  NRCELL-11/NRREL-1:removeNotAllowed=false
...  NRCELL-11/NRHOIF-1:cellDepType=NSA
...  NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...  NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...  NRCELL-11/NRHOIF-1:a3MeasEnabled=none
...  NRCELL-11/NRHOIF-1:a5MeasEnabled=rsrp
...  NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...  NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=10
...  NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...  NRCELL-11/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...  NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...  NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...  NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...  NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...  NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...  NRCELL-11/NRHOIF-1:ssbFrequency=126750
...  NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...  NRCELL-11/NRHOIF-1:scs=15 KHz
...  NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...  NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...  NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...  NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...  NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...  NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...  NRCELL-12/NRREL-1:gNbId=1
...  NRCELL-12/NRREL-1:lcrId=11
...  NRCELL-12/NRREL-1:gNbIdLength=22
...  NRCELL-12/NRREL-1:removeNotAllowed=false
...  NRCELL-12/NRHOIF-1:cellDepType=NSA
...  NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...  NRCELL-12/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...  NRCELL-12/NRHOIF-1:a3MeasEnabled=none
...  NRCELL-12/NRHOIF-1:a5MeasEnabled=rsrp
...  NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...  NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=10
...  NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...  NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...  NRCELL-12/NRHOIF-1:freqBandIndicatorNR=66
...  NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...  NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...  NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...  NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...  NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...  NRCELL-12/NRHOIF-1:ssbFrequency=424090
...  NRCELL-12/NRHOIF-1:scs=15 KHz
...  NRCELL-12:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...  NRCELL-12:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...  NRCELL-12:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...  NRCELL-12:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

${BTS_STARTUP_RETRY}    2

${SA_Capa_perUE_Full}  SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC11
...    84341020E90186D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00
...    05800702A0D883AC1184341020F1018656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6
...    000001FD8000000B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC31E50
...    B0381C3C17003FF001C00FFC000B000E0541B11B582308682041E2030CAD931562439F11C7B027C62471E4
...    39F51CF9863CA1607038784FFF800003FFE0000016001C00F78789A001C4100000216020541E1400071180
...    0000858158788C001C41000006160561E14000710400000858158789A001C46000002160562E2300071040
...    038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26800711800388C0000
...    082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C460000041
...    60562E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C046
...    8051013602083A5D83E14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF
...    870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D
...    8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003C00281C1401C0C01D00E000C0
...    480080C07C120040000000200000401000000008000010040000100200000C010000080080000500400200
...    80200800006004000038020010000000400004002000024010000060080000A00400005802001024090040
...    0006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282
...    000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004C
...    B29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A8345
...    5298AA4D154062A8145526AAA0F1414178095028140A05028140A05028140A05028140A050281400182020
...    180300801002101002008040300610080100202018030080600C10100C0180403006100801002020180300
...    80100220100C01804030060100C01820200401008010043543E00020406080C0E1416181A2022242628303
...    236383A3E424A4C4E5052545A5E828305A
${Capa_LTE}  SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A00038820
...    000002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00
...    A001C041809A26002E41E24E8913639F0E24E8913639F0E24E8913639F0E24E8913639F0E24E8912639F469D1224498E7D127448931CF8
...    30082000080404008020100C01840001008080100202018030C0002010100C01804030060100C018400010080801004020040100000000

*** Test Cases ***
5GSW_CP_CIT018_Verify_Classical_NSA_FDD_cmWave_inter_frequency_intra_gNB_HO_with_A5_RSRP_SRB3_is_successful
    [Tags]    QC_126030    networkmode=NSA
    Ue Attach To Cell-11 and Initial ENDC
    Ue Ho To target gNB Cell-12
    Ue Ho Back target gNB Cell-11
    Check Wireshark Log    ${CURDIR}${/}a2a_CIT018${/}a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env    tl_type=${GNB1_CONFIG}

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

Ue Attach To Cell-11 and Initial ENDC
    UE Attach To Enb Cell1    ue_id=91
    Start RRC Log    UE_initial_ENDC
    Initial ENDC    ue_id=91    target_gnb=2    target_cells=11    bearer_id=2
    Send And Verify Throuput
    Verify Throuput
    Get RRC Log

UE Attach To Enb Cell1
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE

Initial ENDC
    [Arguments]    ${ue_id}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=1
    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    Successfully reconfigured dual connectivity

Ue Ho To target gNB Cell-12
    Start RRC Log    Ue_Ho_To_target_gNB_Cell_12
    Set MeasurementGap and Initial A2 Event
    Initial InterFreA5 Ho
    Verify Throuput
    Get RRC Log

Ue Ho Back target gNB Cell-11
    Start RRC Log    Ue_Ho_Back_target_gNB_Cell_11
    Set MeasurementGap and Initial A2 Event    meas_id=1
    Initial InterFreA5 Ho    meas_id=3    phycell_id=60
    Verify Throuput
    Get RRC Log

Send And Verify Throuput
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=5    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=ul mbps=5    UE 91: UDP UL
    Verify Throuput

Verify Throuput
    [Arguments]    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.6
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.6

Set MeasurementGap and Initial A2 Event
    [Arguments]    ${meas_id}=1
    Execute Egate Command    ue_enb_param id=91 measurement_gap=gp0:12 gap_trigger=gnb_triggered
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=Sending SgNB Modification Confirm
    Should Contain    ${ret1}    measGapConfig setup
    Should Contain    ${ret1}    drx-Config release : NULL

Initial InterFreA5 Ho
    [Arguments]    ${meas_id}=3    ${phycell_id}=61
    Execute Egate Command    ue_enb_param id=91 measurement_gap=off
    Execute Egate Command
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    ...    pass_regexp=Sending SgNB Modification Confirm
