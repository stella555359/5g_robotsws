*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN     QCP_RAN_ET     SBTS00     RAN_5G   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  team-L3CN3_SG2
...  owner-Song.xiuli  release-SBTS00    CIT
Resource  ../../../../resources/DevHZ5_resource.robot

*** Variables ***

@{PARAMS_IN_SCF}
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRCELL-1:freqBandIndicatorNR=78
...    NRCELL-1:gscnOrSsPbchArfcn=7880
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1:nrarfcn=636666
...    NRCELL-1:physCellId=50
...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRCELL-1:absThreshSsbRsrpConsolidation=0
...    NRCELL-1:sMeasConfigSsbRsrp=10
...    NRCELL-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRCELL-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=36
...    NRCELL-1:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRCELL-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480

...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=4
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=10
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=261
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=2071387
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=120 KHz

...    NRBTS-1/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS-1/NRADJNRCELL-1:fiveGsTac=0
...    NRBTS-1/NRADJNRCELL-1:gNbId=4
...    NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS-1/NRADJNRCELL-1:lcrId=2
...    NRBTS-1/NRADJNRCELL-1:nrarfcn=2071591
...    NRBTS-1/NRADJNRCELL-1:ssbFrequency=2071387
...    NRBTS-1/NRADJNRCELL-1:physCellId=384
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3

${RECREATE_WIRESHARK_FLAG}  ${False}

${SA_Capa_perUE_Full}  SEPARATOR=
...    ED007000479A4BBF5FFFFEF8005BD409A00CFDBFCB98AD7FFBF900001F53FFFFC000104880000073BF79FF
...    F9FFFF60000FBC00BFFF0000163C03F148200DFFF785FFF5E00F2A6A7000158800000000023007CAA080E0

${Capa_LTE}  SEPARATOR=
...    BD1BA083058380713400000018062B000060400C1001830030600E268000010300C160801C4D0000060601
...    82C000389A00000C0C03058100713400001018060B0600E2680000203000100510400801002826C4100289
...    178A028400040201002004AE00200804010080201004020080401008020100402008040100802010040200
...    80402008040100802010000000804010080000000000080400000000000000008040100802010040200000
...    01008020100000000000100800000000000000010080201004020080401008000000402008040100800000
...    00000000001008000000000000000000002013800404010080101002020000000808010100000000000080
...    80000000000000000804020080201004020080401008020100402008040100802010040200804010100402
...    00404000000101002020000000808000000000004040000000000020200804008080101000000040400808
...    0000000000040400808000000000004040000000000000000404E002010040200804000000201004020000
...    00100800000000000804000000000004020080401008000000402008040000002010000000000010080000
...    00000008020100402008040100802010040200804010080201004020080401008020100802010040200000
...    01008020100000008040000002010000000804000000000004020000000000020138004040080801010020
...    20040400000010100202004040000000000020200000008080101002020040400808000000202004040080
...    80000000000040400000010100202004040080801010000000404008080101000000000000808000000201
...    004020080401008020100402008040100802010040200804010080201004020080401008020100802E0020
...    10020200000008080101000000000000000010100000000000000000000040200404000000101002020000
...    00000000000020200000000000000000000080400808000000202004040000000000000000404000000000
...    00000000000100801010000000404008080101000000000000808000000202004040000000000000000404
...    0000001013880100300200600400C0080180100300200600400C0080180100300200600400C00801801003
...    00200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C00801
...    80100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400
...    C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100210000
...    8040400801080008020200400800804018010020040100600400C00801


*** Test Cases ***
5GSW_CP_CIT019_Verify_Classical_NSA_TDD_cmWave_inter_frequency_inter_gNB_HO_with_A5_RSRP_CFRA_non_SRB3_is_successful
	[Tags]  QC_61714
    Ue Attach and Initial ENDC
    Trigger A2 measurement report    ue_id=11
    Trigger A5 measurement report HO to simulate gNB cell-1    ue_id=11    meas_id=3
    Trigger A2 measurement report from simulate gNB   ue_id=11    srsrp_nr=7    srsrq_nr=7
    Trigger A5 measurement report back to real gNB    ue_id=11    meas_id=11    phycel_id=50
    Check RRC log    ${CURDIR}${/}a2a_CIT019${/}a2a.ini


*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri  ue_count=5

Modify Cfg
    ${V2}    catenate
    ...    ue_param id=11 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE}
    ${V3}    catenate
    ...    set_ue simulated id=11 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    eia=null+snow3g+aes eea=null nea=null+zuc nia=null+zuc imsi=311:489:21645400
    ${V4}    catenate
    ...    set_cell id=4 gnb=4 tac=3 pci=128:0 proxy=10.0.2.1:22223 nrci=0x2 nr_arfcn=2071591:2071591 tdd_cell=on
    ...    gscn=22446 mandatory_for_activation=off
    Update Cfg    ${V2}
    Update Cfg    ${V3}
    Update Cfg    ${V4}
    Update Cfg    set_gnb id=4 s1u=10.0.1.129 plmn=311:489 gnb_id=0x4 type=simulated daemon=10.0.2.1:22222 x2=10.0.1.129:36422


Ue Attach and Initial ENDC
    Setup X2 link for gNB4
    UE attach    ue_id=11
    Initial ENDC    ue_id=11    target_gnb=2    target_cells=1    bearer_id=2
    Send And Verify Throuput    ue_id=11


Setup X2 link for gNB4
    Execute Egate Command    enb_x2_link_up enb=1 target=4    pass_regexp=is up
UE attach
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE

Initial ENDC
    [Arguments]    ${ue_id}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=1
    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    Successfully reconfigured dual connectivity

Send And Verify Throuput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=5    UE 11: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=5    UE 11: UDP UL
    Verify Throuput    ue_id=11

Verify Throuput
    [Arguments]    ${ue_id}=1    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.6
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.6

Trigger A2 measurement report
    [Arguments]    ${ue_id}=1    ${meas_id}=1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    pass_regexp=SgNBModificationConfirm

Trigger A5 measurement report HO to simulate gNB cell-1
    [Arguments]    ${ue_id}=1    ${meas_id}=1    ${phycel_id}=384
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycel_id} nrsrp_nr=80 nrsrq_nr=80
    ...    pass_regexp=SgNBChangeConfirm

Trigger A2 measurement report from simulate gNB
    [Arguments]    ${ue_id}=1    ${meas_id}=1    ${srsrp_nr}=11    ${srsrq_nr}=11
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ...    pass_regexp=rrcReconfigurationComplete

Trigger A5 measurement report back to real gNB
     [Arguments]    ${ue_id}=1    ${meas_id}=1    ${phycel_id}=384
     ${Trigger_A5_HO_back}        catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycel_id}
    ...    nrsrp_nr=60 nrsrq_nr=60 rs_type=ssb index=0 nrs_result=30:30:30
    ${ret1}=    Execute Egate Command    ${Trigger_A5_HO_back}    pass_regexp=SgNBChangeConfirm
