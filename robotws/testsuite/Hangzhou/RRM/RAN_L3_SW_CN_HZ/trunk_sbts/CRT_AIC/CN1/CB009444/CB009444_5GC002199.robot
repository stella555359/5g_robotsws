*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    team-L3CN3_SG2    owner-ying.5.Chen    release-5G19A
...    CLOUD_5GC_dRNIC_1vDU_O_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    master_vDU    vDUCNF00    5GC000573
Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/1du/2cell
${NSA_UE_ID}    91
@{PARAMS_IN_SCF_CU}    @{A1A2A5_event}    @{SRB3}    @{CU_NRREL}    @{CU_NRHOIF}
@{PARAMS_IN_SCF_DU1}    @{DU_NRREL}    @{DU_NRHOIF}    @{IntraFreq_DRX}

@{SRB3}
...    NRBTS-1:srb3SupportEnabled=true
...    NRBTS-1:cipherPrefL:nea0=1
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:actConflictConfiguration=true

@{A1A2A5_event}
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRCELL:a1MeashoEnabled=rsrp
...    NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL:a2MeashoEnabled=rsrp
...    NRCELL:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL:actCDrx=true
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a3MeasEnabled=none

@{CU_NRREL}
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:removeNotAllowed=false

@{CU_NRHOIF}
...    NRCELL-1/NRHOIF-1:cellDepType=NSA
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=10
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssbFrequency=633408
...    NRCELL-1/NRHOIF-1:scs=15 KHz
...    NRCELL-2/NRHOIF-1:cellDepType=NSA
...    NRCELL-2/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-2/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=10
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:ssbFrequency=633216
...    NRCELL-2/NRHOIF-1:scs=15 KHz

@{DU_NRREL}
...    NRCELL/NRREL-1

@{DU_NRHOIF}
...    NRCELL/NRHOIF-1
...    NRCELL/NRHOIF-1:ssBurstSetPeriod=10

@{IntraFreq_DRX}
...    NRCELL:chBw=100MHz
...    NRCELL:freqBandIndicatorNR=78
...    NRCELL-1:nrarfcn=633364
...    NRCELL-1:gscnOrSsPbchArfcn=7845
...    NRCELL-2:nrarfcn=633508
...    NRCELL-2:gscnOrSsPbchArfcn=7847
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:actCDrx=true

${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020E90186D6C98AB1A1CF8
...    8E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C98AB121CFB027C471E3
...    1238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC
...    31E50B0381C3C17003FF001C00FFC000B000E0541B11B582308682041E2030CAD931562439F11C7B027C62471E439F51CF9863CA160703878
...    4FFF800003FFE0000016001C00F78789A001C4100000216020541E14000711800000858158788C001C41000006160561E1400071040000085
...    8158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E268007118
...    00388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E14000711800
...    388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C0468051013602083A5D83E14489B1CF870A244D8E7C3851
...    226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0890204
...    0D8E7C08902040D8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003C00281C1401C0C01D00E000C0480080C07C12
...    0040000000200000401000000008000010040000100200000C010000080080000500400200802008000060040000380200100000004000040
...    02000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000
...    012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB292020
...    00152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F1414178
...    095028140A05028140A05028140A05028140A050281400182020180300801002101002008040300610080100202018030080600C10100C018
...    040300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406080C0E1416181A202224262830323
...    6383A3E424A4C4E5052545A5E828305A

${Capa_LTE}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A00038820000
...    002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001C0
...    41809A26002E41E24E8913639F0E24E8913639F0E24E8913639F0E24E8913639F0E24E8912639F469D1224498E7D127448931CF8300820000
...    80404008020100C01840001008080100202018030C0002010100C01804030060100C018400010080801004020040100000000
*** Test Cases ***
CB009444-ET_5GC002199_Verify_Cloud_NSA_FDD_cmWave_inter_frequency_intra_gNB_HO_with_A5_RSRP_SRB3_is_successful
    [Tags]    QC_281179    networkmode=NSA
    UE attach Cell1 and traffic
    Ue from Cell1 HO Cell2
    Ue from Cell2 HO Cell1
    Release UEs    ue_type=all

*** Keywords ***
Modify Cfg Aic
    ${V_1}    catenate
    ...    set_ue simulated id=${NSA_UE_ID} uec=1 release=15 enb=1 cell=1 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 eia=null+snow3g+aes+zuc nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g
    ...    imsi=311:489:216454${NSA_UE_ID}
    Update Cfg Aic    ${V_1}
    ${V_2}    catenate
    ...    ue_param id=${NSA_UE_ID} ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg Aic    ${V_2}
    Update Cfg Aic    set_bearer id=2 ue=${NSA_UE_ID} qci=9 pdn=1 ip=4.7.254.1${NSA_UE_ID} default=on trf_type=internal
    ${set_gnb2_cell1}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=633364:633364 gscn=7845 mandatory_for_activation=off
    Update Cfg Aic    ${set_gnb2_cell1}
    ${set_gnb2_cell2}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=633508:633508 gscn=7847 mandatory_for_activation=off
    Update Cfg Aic    ${set_gnb2_cell2}

UE attach Cell1 and traffic
    Execute Egate Command    ue_attach id=${NSA_UE_ID}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${NSA_UE_ID} target_gnb=2 target_cells=1 bearer=2 type=split_scg    reported successful RA
    Send Throughput
    Verify Throuput Should Be OK

Ue from Cell1 HO Cell2
    Set MeasurementGap and Trigger UE from Cell1 to Cell2 by A5
    Verify Throuput Should Be OK

Ue from Cell2 HO Cell1
    Set MeasurementGap and Trigger UE from Cell2 to Cell1 by A5
    Verify Throuput Should Be OK

Send Throughput
    Execute Egate Command    data_trf_start ue=${NSA_UE_ID} id=2 dir=dl mbps=5    UE ${NSA_UE_ID}: UDP DL
    Execute Egate Command    data_trf_start ue=${NSA_UE_ID} id=2 dir=ul mbps=5    UE ${NSA_UE_ID}: UDP UL

Verify Throuput Should Be OK
    [Arguments]    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${NSA_UE_ID}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.6
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${NSA_UE_ID}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.6

Set MeasurementGap and Trigger UE from Cell1 to Cell2 by A5
    [Arguments]    ${ue_id}=${NSA_UE_ID}    ${phycell_id}=51
    Execute Egate Command    ue_enb_param id=${NSA_UE_ID} measurement_gap=gp0:2 gap_trigger=gnb_triggered
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${NSA_UE_ID}    carrierfreq=633216    event_type=A2
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${NSA_UE_ID} meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=Sending SgNB Modification Confirm
    Should Contain    ${ret1}    measGapConfig setup
    Should Contain    ${ret1}    drx-Config release : NULL
    Execute Egate Command    ue_enb_param id=${NSA_UE_ID} measurement_gap=off
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633408    event_type=A5
    Execute Egate Command
    ...    ue_measurement_send_nr id=${NSA_UE_ID} meas_id=${meas_id} event=A5 srsrp_nr=1 srsrq_nr=1 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    ...    pass_regexp=Sending SgNB Modification Confirm

Set MeasurementGap and Trigger UE from Cell2 to Cell1 by A5
    [Arguments]    ${phycell_id}=50    ${ue_id}=${NSA_UE_ID}
    Execute Egate Command    ue_enb_param id=${NSA_UE_ID} measurement_gap=gp0:2 gap_trigger=gnb_triggered
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${NSA_UE_ID}    carrierfreq=633408    event_type=A2
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${NSA_UE_ID} meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=Sending SgNB Modification Confirm
    Should Contain    ${ret1}    measGapConfig setup
    Should Contain    ${ret1}    drx-Config release : NULL
    Execute Egate Command    ue_enb_param id=${NSA_UE_ID} measurement_gap=off
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633216    event_type=A5
    Execute Egate Command
    ...    ue_measurement_send_nr id=${NSA_UE_ID} meas_id=${meas_id} event=A5 srsrp_nr=1 srsrq_nr=1 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    ...    pass_regexp=Sending SgNB Modification Confirm