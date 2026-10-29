*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Stop Capture Logs And Restore ENV In Test Teardown
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CDRT    CIT    team-L3CN3_SG2
...    owner-huibo.miao    release-5G19A     5GC000573    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    AP_P1
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${carrierfreq}    636576
@{PARAMS_IN_SCF}    @{feature_flag}    @{srb3}    @{CFRA}    @{a3_rsrp}    @{intra_freq_inter_gnb}    @{intra_freq_intra_gnb}    @{DRX}
@{feature_flag}    
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
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
@{CFRA}
...    NRCELL:cbraPreamblesPerSsb=n60
@{a3_rsrp}
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:rsrpThresholdSSB=11
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:sMeasConfigSsbRsrp=1
@{DRX}
...    NRCELL:actCDrx=true
...    NRCELL:drxProfile1:drxLongCycle=80ms
...    NRCELL:drxProfile1:drxOnDurationTimer=20ms
...    NRCELL:drxProfile1:drxInactivityTimer=20ms
...    NRCELL:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL:drxProfile1:drxRetransTimerUl=16slot
@{intra_freq_intra_gnb}
...    NRBTS-1/NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL-2:gNbId=1
...    NRBTS-1/NRCELL-1/NRREL-2:gNbIdLength=22
...    NRBTS-1/NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRBTS-1/NRCELL-1/NRREL-2:lcrId=2
...    NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRBTS-1/NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRBTS-1/NRCELL-2/NRREL-1:gNbId=1
...    NRBTS-1/NRCELL-2/NRREL-1:gNbIdLength=22
...    NRBTS-1/NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRBTS-1/NRCELL-2/NRREL-1:lcrId=1
...    NRBTS-1/NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRBTS-1/NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRBTS-1/NRCELL-2/NRREL-2:gNbId=35
...    NRBTS-1/NRCELL-2/NRREL-2:gNbIdLength=22
...    NRBTS-1/NRCELL-2/NRREL-2:handoverAllowedSA=allowed
...    NRBTS-1/NRCELL-2/NRREL-2:lcrId=1
...    NRBTS-1/NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
@{intra_freq_inter_gnb}
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:fiveGsTac=0
...    NRADJNRCELL-1:freqBandIndicatorNR=78
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=636666
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=35
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-1:removeNotAllowed=true
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    @{bandwidth_configuration}

@{bandwidth_configuration}
...    NRCELL:chBw=100MHz

${SA_Capa_perUE_Full}    SEPARATOR=
...    ED007000479A4BBF5FFFFEF8001BD409A00CFDBFCB98AD7FFBF900001F53FFFFD1000000E77EF3FFF3FFFEC0001F78017FFE00002C7
...    807E290401BFFEF0BFFEBC00E54D00158800000000023003CAA08

${Capa_LTE}    SEPARATOR=
...    BD1BA063058380713400000018062B000060400C1001830030600E268000010300C160801C4D000006060182C000389A00000C0C030581
...    00713400001018060B0600E26800002030048BC500C2000201008010025700100402008040100802010040200804010080201004020080
...    40100802010040201004020080401008000000402008040000000000040200000000000000004020080401008020100000008040100800
...    00000000080400000000000000008040100802010040200804000000201004020080400000000000000008040000000000000000000010
...    09C00202008040080801010000000404008080000000000040400000000000000004020100401008020100402008040100802010040200
...    80401008020100402008080201002020000000808010100000004040000000000020200000000000101004020040400808000000202004
...    04000000000002020040400000000000202000000000000000020270010080201004020000001008020100000008040000000000040200
...    00000000020100402008040000002010040200000010080000000000080400000000000401008020100402008040100802010040200804
...    01008020100402008040100804010080201000000080401008000000402000000100800000040200000000000201000000000001009C00
...    20200404008080101002020000000808010100202000000000001010000000404008080101002020040400000010100202004040000000
...    00002020000000808010100202004040080800000020200404008080000000000040400000010080201004020080401008020100402008
...    04010080201004020080401008020100402008040100804017001008010100000004040080800000000000000008080000000000000000
...    00002010020200000008080101000000000000000010100000000000000000000040200404000000101002020000000000000000202000
...    000000000000000000804008080000002020040400808000000000004040000001010020200000000000000002020000000809C4008018
...    0100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0
...    080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600
...    400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C00801080004020
...    2004008400040101002004

@{non_srb3}
...    NRBTS:srb3SupportEnabled=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=9
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=0
...    NRBTS:integrityProtPrefL:nia3_128=9

@{PM_Counters_Check_C}
...    ${X2_SGNB_CHG_REQD_SENT}=${4*${loop_time}}
...    ${X2_SGNB_CHG_CONF_RECEIVED}=${4*${loop_time}}
...    ${X2_SGNB_CHG_REF_RECEIVED}=0
...    ${X2_SGNB_RECONF_SN_CH_RCVD}=${4*${loop_time}}
...    ${X2_SGNB_RECONF_ACK_SN_CH_RCVD}=${4*${loop_time}}
...    ${INTRA_DU_HO_ATT_NSA_MNB}=${2*${loop_time}}
...    ${INTRA_DU_HO_ATT_NSA_SRB3}=${2*${loop_time}}

${X2_SGNB_CHG_REQD_SENT}             M55112C02501
${X2_SGNB_CHG_CONF_RECEIVED}         M55112C02502
${X2_SGNB_RECONF_SN_CH_RCVD}         M55112C02505
${X2_SGNB_RECONF_ACK_SN_CH_RCVD}     M55112C02506
${X2_SGNB_CHG_REF_RECEIVED}          M55112C02512
${INTRA_DU_HO_ATT_NSA_MNB}           M55120C01001
${INTRA_DU_HO_ATT_NSA_SRB3}          M55120C01002

${loop_time}    2

*** Test Cases ***
5GSW-CP-CIT017_Verify_Classical_NSA_TDD_cmWave_intra-frequency_inter-gNB_HO_with_A3_RSRP_CFRA_SRB3_is_successful
    [Documentation]
    ...    Combine intra-freq inter-gnb and intra-freq intra-gnb HO together
    ...    Using DRX, CFRA, A3, RSRP; combining with and without SRB3
    ...    Combination HO sequence: real_gnb(cell:50)--> simulate_gnb --> real_gnb(cell:51) -->real_gnb(cell:50)
    ...                             -->real_gnb(cell:51) -->simulate_gnb --> real_gnb(cell:50)
    [Tags]    QC_61713    
    Clear Counter Files
    X2 Link for simulated gNB-35
    Ue Attach To LTE and Initial Endc
    Combination HO
    Delta Commission Parameters    ${non_srb3}
    Combination HO
    Delta Commission Parameters    ${srb3}
    Repeat Above Steps If Need
    Check throuput counters wireshark-log

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

X2 Link for simulated gNB-35
    Execute Egate Command    enb_x2_link_up enb=1 target=3    
    ...    pass_regexp=is UP

Modify Cfg
    ${V_1}    catenate
    ...    ue_param id=31 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE}
    ${V_2}    catenate
    ...    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666 
    ...    gscn=7880 mandatory_for_activation=off
    ${V_4}    catenate
    ...    set_ue simulated id=31 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nea=null+zuc nia=null+zuc imsi=311:489:21645400
    Update Cfg    ${V_1}
    Update Cfg    gnb_set id=3 s1u=10.0.1.126 plmn=311:489 gnb_id=0x23:22 type=simulated daemon=:22222 x2=10.0.1.126:36422
    Update Cfg    ${V_2}
    Update Cfg    gnb_endc_param id=3 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0
    Update Cfg    ${V_4}

Ue Attach To LTE and Initial Endc
    [Arguments]    ${ue_id}=31
    Execute Egate Command    ue_change_location id=${ue_id} cell=1 enb=1
    UE Attach To Enb Cell1    ue_id=${ue_id}
    Initial Endc    ue_id=${ue_id}    target_gnb=2    target_cells=1    bearer_id=2
    Send And Verify Throuput    ue_id=${ue_id}

UE Attach To Enb Cell1
    [Arguments]    ${ue_id}=31
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE

Initial Endc
    [Arguments]    ${ue_id}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=1
    ${ret1}=    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    Successfully reconfigured dual connectivity    timeout=20s

Check throuput counters wireshark-log
    Verify Throuput
    Check Counters    ${PM_Counters_Check_C}
    Check Wireshark Log On Loop    ${CURDIR}${/}a2a_CIT017${/}a2a_wireshark_config.ini
    Check Wireshark Log On Loop    ${CURDIR}${/}a2a_CIT017${/}a2a_wireshark.ini    ${loop_time}

Combination HO
    Initial IntraFreA3 Ho    phycell_id=381
    Initial IntraFreA3 Ho CFRA    phycell_id=51
    Initial IntraFreA3 Ho    phycell_id=50
    Initial IntraFreA3 Ho    phycell_id=51
    Initial IntraFreA3 Ho    phycell_id=381
    Initial IntraFreA3 Ho CFRA    phycell_id=50

Repeat Above Steps If Need
    Repeat Keyword    ${${loop_time}-1}    Case Repetive Steps

Case Repetive Steps
    Combination HO
    Delta Commission Parameters    ${non_srb3}
    Combination HO
    Delta Commission Parameters    ${srb3}

Check Wireshark Log On Loop
    [Arguments]    ${a2a_path}    ${times}=1
    ${content}=    Get File    ${a2a_path}
    ${content}=    Replace string using regexp    ${content}    REPEAT_NUM:\\s\\d+    REPEAT_NUM: ${times}
    Create File    ${a2a_path}    ${content}
    Check Wireshark log    ${a2a_path}
    
Send And Verify Throuput
    [Arguments]    ${ue_id}=31
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=10 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10    UE ${ue_id}: UDP UL
    Verify Throuput    sleep_time=30s    ue_id=${ue_id}

Verify Throuput
    [Arguments]    ${sleep_time}=15s    ${ue_id}=31
    sleep    ${sleep_time}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>9

Initial IntraFreA3 Ho
    [Arguments]    ${phycell_id}    ${ue_id}=31
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=Confirm

Initial IntraFreA3 Ho CFRA
    [Arguments]    ${phycell_id}    ${ue_id}=31
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${V_4}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    ${ret1}=     Execute Egate Command
    ...    ${V_4} 
    ...    pass_regexp=Sending SgNB Change Confirm

UE Detach From GNB
  [Arguments]    ${expect_string}=${EMPTY}
  Execute Egate Command    ue_detach id=31    ${expect_string}

Stop Capture Logs And Restore ENV In Test Teardown
    UE Detach From GNB
    Common Test Teardown And Stop Capture Logs
