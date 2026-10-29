*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    RAN_5G    RAN_5G_TDD    master_classicalbts_all    STATE_CONFIGURED
...    FR1    IPV4    team-DevHZ5_SG2    PRI-Medium    SBTS00    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    QCD_MN_RAN    QCP_RAN_ET
...    CIT    Classical    5GC001094    5GC001546    5GC000718    5GSW-CP-CIT016    CDRT    owner-keyun.ma    AP_REG
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{FAULTS_EXCLUDED_CHECKING}    4681
${DEBUG_LOG_LEVEL}    0
${AP_UDPLOG_LEVEL}    0

${GNB_BIP_FLAG}    True
${carrierfreq}    636576
@{PARAMS_IN_SCF}
...    @{params_to_enable_nsa_ho}
...    @{enable_meas}
...    @{nrrel_intra_freq_intra_gnb}
...    @{cbra_non_srb3}
...    @{cell1_locked}

@{cell1_locked}
...    NRCELL-1:administrativeState=Locked
@{enable_meas}
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:rsrpThresholdSSB=11
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:filterCoeffSsbRsrp=fc4
...    NRCELL-1:sMeasConfigSsbRsrp=1

@{nrrel_intra_freq_intra_gnb}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

@{cbra_non_srb3}
...    NRCELL:cbraPreamblesPerSsb=n64
...    NRBTS:srb3SupportEnabled=false
...    NRCELL:a3MeasEnabled=rsrp

@{params_to_enable_nsa_ho}

...    NRBTS-1:actIntraFreqIntraGnbMobilityNSA=true

${nr_capability}    SEPARATOR=
...    ED007000479A4BBF5FFFFEF8001BD409A00CFDBFCB98AD7FFBF900001F53FFFFD1000000E77EF3FFF3FFFEC0001F78017FFE00002C7807E2
...    90401BFFEF0BFFEBC00E54D00158800000000023003CAA08

${ue_eutra4}    SEPARATOR=
...    BD1BA063058380713400000018062B000060400C1001830030600E268000010300C160801C4D000006060182C000389A00000C0C030581007
...    13400001018060B0600E26800002030048BC500C2000201008010025700100402008040100802010040200804010080201004020080401008
...    02010040201004020080401008000000402008040000000000040200000000000000004020080401008020100000008040100800000000000
...    8040000000000000000804010080201004020080400000020100402008040000000000000000804000000000000000000001009C002020080
...    40080801010000000404008080000000000040400000000000000004020100401008020100402008040100802010040200804010080201004
...    02008080201002020000000808010100000004040000000000020200000000000101004020040400808000000202004040000000000020200
...    40400000000000202000000000000000020270010080201004020000001008020100000008040000000000040200000000000201004020080
...    40000002010040200000010080000000000080400000000000401008020100402008040100802010040200804010080201004020080401008
...    04010080201000000080401008000000402000000100800000040200000000000201000000000001009C00202004040080801010020200000
...    00808010100202000000000001010000000404008080101002020040400000010100202004040000000000020200000008080101002020040
...    40080800000020200404008080000000000040400000010080201004020080401008020100402008040100802010040200804010080201004
...    02008040100804017001008010100000004040080800000000000000008080000000000000000000020100202000000080801010000000000
...    00000010100000000000000000000040200404000000101002020000000000000000202000000000000000000000804008080000002020040
...    400808000000000004040000001010020200000000000000002020000000809C40080180100300200600400C0080180100300200600400C00
...    80180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C
...    0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C008018010030020060040
...    0C0080180100300200600400C0080180100300200600400C008010800040202004008400040101002004

@{PM_Counters_Check_CIT016}
...    NRCELL-1:${INTRA_DU_HO_ATT_NSA_MNB}=${loop_time}
...    NRCELL-1:${INTRA_FR_PSCEL_CH_MIN_DURAT}>0
...    NRCELL-1:${INTRA_FR_PSCEL_CH_MAX_DURAT}>0
...    NRCELL-1:${INTRA_FR_PSCEL_CH_TOT_DURAT}>0
...    NRCELL-2:${INTRA_FR_PSCEL_CH_MIN_DURAT}>0
...    NRCELL-2:${INTRA_FR_PSCEL_CH_MAX_DURAT}>0
...    NRCELL-2:${INTRA_FR_PSCEL_CH_TOT_DURAT}>0
...    NRCELL-2:${INTRA_DU_HO_ATT_NSA_MNB}=${loop_time}


${INTRA_DU_HO_ATT_NSA_MNB}    M55120C01001
${INTRA_FR_PSCEL_CH_MIN_DURAT}    M55120C00005
${INTRA_FR_PSCEL_CH_MAX_DURAT}    M55120C00006
${INTRA_FR_PSCEL_CH_TOT_DURAT}    M55120C00007


${loop_time}    3


*** Test Cases ***
5GSW-CP-CIT016_Verify_Classical_NSA_TDD_cmWave_intra_frequency_intra_gNB_HO_with_A3_RSRP_CBRA_non_SRB3_is_successful
    [Documentation]
    ...    This case will include feature 5GC001094, feature 5GC000718, feature 5GC001546.
    ...    After adding more 1 cell, to verify Classical NSA TDD cmWave - intra-frequency intra-gNB HO with A3 RSRP CBRA
    ...    non SRB3 is successful
    ...    pre-condition: Prepare scf.xml with parameter "administrativeState" locked in cell1
    ...    check counters: M55120C01001 (INTRA_DU_HO_ATT_NSA_MNB),M55120C00005(INTRA_FR_PSCEL_CH_MIN_DURAT),
    ...    M55120C00006(INTRA_FR_PSCEL_CH_MAX_DURAT),M55120C00007(INTRA_FR_PSCEL_CH_TOT_DURAT)
    [Tags]    QC_61701
    Clear Counter Files
    Ue Attach To Cell and send traffic
    start to capture wireshark log    HO_A3_RSRP_none_SRB3_CBRA
    Trigger cell1 handover to cell2
    Trigger cell2 handover to cell1
    Repeat Above Steps If Need
    Check Wireshark Log    ${CURDIR}${/}a2a_CIT016${/}HO_A3_RSRP_none_SRB3_CBRA.ini    name=HO_A3_RSRP_none_SRB3_CBRA
    ...    wait_string=SgNBModificationConfirm::6
    Check Counters    ${PM_Counters_Check_CIT016}
    Release Ues    ue_type=nsa    ue_id=31

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri


Ue Attach To Cell and send traffic
    Set x2 gnb link up
    Cell Should Be Locked    1
    start to capture wireshark log    UEs_L3_Call
    delta commission parameters    NRCELL-1:administrativeState=Unlocked
    Cells Should Be Onair
    UE Attach and establish EN-DC
    Send And Verify Throughput
    Check WireShark Log     ${CURDIR}${/}a2a_CIT016${/}UEs_L3_Call.ini    name=UEs_L3_Call    wait_string=SNStatusTransfer

Set x2 gnb link up
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2

UE Attach and establish EN-DC
    [Arguments]    ${ue_id}=31    ${target_cell}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cell} bearer=2 type=split_scg
    ...    Successfully reconfigured dual connectivity    timeout=20s

Modify Cfg
    ${V1}    catenate
    ...    ue_param    id=31    ue_nr_capabilities=${nr_capability}    dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra4}
    Update Cfg    ${V1}

Send And Verify Throughput
    [Arguments]    ${ue_id}=31
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=5 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=5 trf_id=2    UE ${ue_id}: UDP UL
    Verify Throughput    sleep_time=30s

Verify Throughput
    [Arguments]    ${sleep_time}=10s    ${ue_id}=31
    sleep    ${sleep_time}
    ${ul_Throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_Throughput}/1000>4.6
    ${dl_Throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_Throughput}/1000>4.6

Trigger cell1 handover to cell2
    Initial IntraFreA3 Ho    phycell_id=51

Initial IntraFreA3 Ho
    [Arguments]    ${phycell_id}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=31    carrierfreq=${carrierfreq}    event_type=A3
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=31 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=reported successful RA

Trigger cell2 handover to cell1
    Initial IntraFreA3 Ho    phycell_id=50
    Verify Throughput

Repeat Above Steps If Need
    Repeat Keyword    ${${loop_time}-1}    Case Repetive Steps

Case Repetive Steps
    Trigger cell1 handover to cell2
    Trigger cell2 handover to cell1

