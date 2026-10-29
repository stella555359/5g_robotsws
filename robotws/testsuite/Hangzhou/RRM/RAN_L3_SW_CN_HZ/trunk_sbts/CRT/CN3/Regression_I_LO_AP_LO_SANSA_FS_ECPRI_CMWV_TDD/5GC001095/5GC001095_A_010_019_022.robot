*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  RAN_5G_TDD  no_CRT  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  team-SG2
...               owner-shelly.song  release-SBTS00
Resource          ../../../../../resources/DevHZ5_resource.robot
*** Variables ***
@{PARAMS_IN_SCF}
...  NRBTS:actInterFreqIntraGnbMobilityNSA=true
...  NRBTS:actInterFreqInterGnbMobilityNSA=true
...  NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
...  NRBTS:srb3SupportEnabled=true
...  NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...  NRCELL:a2MeashoEnabled=rsrp
...  NRCELL:a5MeasEnabled=rsrp
...  NRCELL:a3MeasEnabled=rsrp
...  NRCELL:a1MeashoEnabled=rsrp
...  NRBTS:actIntraMeNBMobility=true
...  NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...  NRCELL-1:freqBandIndicatorNR=78
...  NRCELL-1:nrarfcn=636666
...  NRCELL-2:measGapSelectionSA=favourUeThroughput
...  @{Mobility}
@{Mobility}
...  NRBTS:tDCoverall=10000
...  NRBTS:timerX2UeProcGuard=15000
...  NRBTS:cipherPrefL:nea0=9
...  NRBTS:cipherPrefL:nea2_128=0
...  NRBTS:cipherPrefL:nea1_128=0
...  NRBTS:cipherPrefL:nea3_128=9
...  NRBTS/NRADJNRCELL-4915:cellDepType=NSA
...  NRBTS/NRADJNRCELL-4915:gNbId=3
...  NRBTS/NRADJNRCELL-4915:gNbIdLength=22
...  NRBTS/NRADJNRCELL-4915:lcrId=3
...  NRBTS/NRADJNRCELL-4915:nrarfcn=2071591
...  NRBTS/NRADJNRCELL-4915:physCellId=381
...  NRBTS/NRADJNRCELL-4915:gnbPlmn:mnc=489
...  NRBTS/NRADJNRCELL-4915:gnbPlmn:mcc=311
...  NRBTS/NRADJNRCELL-4915:gnbPlmn:mncLength=3
...  delete:NRBTS/NRADJNRCELL-4915:freqBandIndicatorNR
...  NRCELL-1/NRREL-1:gNbId=3
...  NRCELL-1/NRREL-1:gNbIdLength=22
...  NRCELL-1/NRREL-1:lcrId=3
...  NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...  NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...  NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...  NRCELL-1:absThreshSsbRsrpConsolidation=1
...  NRCELL-1:sMeasConfigSsbRsrp=1
...  NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms512
...  NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...  NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...  NRBTS:actInterFreqIntraGnbMobilityNSA=true
...  NRBTS:actInterMeNBMobility=true
...  NRBTS:actIntraMeNBMobility=true
...  NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=60
...  NRCELL:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...  NRCELL:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...  NRCELL:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...  NRCELL:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=40
...  NRCELL:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...  NRCELL-1/NRHOIF-1:cellDepType=NSA
...  NRCELL-1/NRHOIF-1:freqBandIndicatorNR=261
...  NRCELL-1/NRHOIF-1:ifhoSsbScs=120 KHz
...  NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...  NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...  NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...  NRCELL-1/NRHOIF-1:ssbFrequency=2071387
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
@{Online_Param_A019}
...  @{Disable_SRB3}
@{Online_Param_A022}
...  @{Disable_SRB3}
...  NRCELL:a5MeasEnabled=none
...  NRCELL:a2MeashoEnabled=rsrp
@{Online_Param_A022_1}
...  delete:NRCELL-1/NRHOIF-1
@{Disable_SRB3}
...  NRBTS:srb3SupportEnabled=false
${Update_Cfg_1}    set_enb id=11 plmn=311:489 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222 x2=10.0.1.127 x2u=10.0.1.137
...    type=simulated x2_peers=none
${Update_Cfg_2}    set_enb id=1 plmn=311:489 s1=10.0.1.121 enb_id_macro=0x12346 daemon=10.0.2.1:22222 x2=10.0.1.12 x2u=10.0.1.136
...    type=simulated x2_peers=none
${Update_Cfg_3}    set_cell id=3 gnb=3 tac=3 pci=127:0 proxy=10.0.2.1:12221|10.0.2.1:8891 nrci=0x1 nr_arfcn=2071591:2071591 tdd_cell=on gscn=22446
...    mandatory_for_activation=off
${Update_Cfg_4}    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 gnb_id=0x2:22 x2=10.0.1.2:36422 x2_peers=none ng=10.0.1.2
...    xn=10.0.1.2 amf=1 nssai=0x1:0xd143a5
${Update_Cfg_5}    set_ue simulated id=31 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
...    eia=null+snow3g+aes eea=null nia=null+snow3g+zuc+aes nea=null+zuc+snow3g imsi=311:489:21645501
${Update_Cfg_6}    set_ue simulated id=32 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
...    eia=null+snow3g+aes eea=null nia=null+snow3g+zuc+aes nea=null+zuc+snow3g imsi=311:489:21645502
${Update_Cfg_7}    set_ue simulated id=33 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
...    eia=null+snow3g+aes eea=null nia=null+snow3g+zuc+aes nea=null+zuc+snow3g imsi=311:489:21645503
${Update_Cfg_8}    set_ue simulated id=34 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
...    eia=null+snow3g+aes eea=null nia=null+snow3g+zuc+aes nea=null+zuc+snow3g imsi=311:489:21645504
${ue_eutra_nr_capabilities_1}    SEPARATOR=
...  A11FD82382C0C0389A00000404440B84C0C030500713400001048881709818070A000309A0003091102E130300E140007134000000488810050
...  13601400330062000080404008020100C01820001008080600C2000080404008000100C01840001008080100402018000
${ue_nr_capabilities}    SEPARATOR=
...  ED007000479A4BBF5FFFFEF8005BD409A00CFDBFCB98AD7FFBF900001F53FFFFC000104880000073BF79FFF9FFFF60000FBC00BFFF0000163C0
...  3F148200DFFF785FFF5E00F2A6A7000158800000000023007CAA080E0
${ue_eutra_nr_capabilities}    SEPARATOR=
...  BD1BA083058380713400000018062B000060400C1001830030600E268000010300C160801C4D000006060182C000389A00000C0C03058100713
...  400001018060B0600E2680000203000100510400801002826C4100289178A028400040201002004AE0020080401008020100402008040100802
...  0100402008040100802010040200804020080401008020100000008040100800000000000804000000000000000080401008020100402000000
...  1008020100000000000100800000000000000010080201004020080401008000000402008040100800000000000000010080000000000000000
...  0000201380040401008010100202000000080801010000000000008080000000000000000804020080201004020080401008020100402008040
...  1008020100402008040101004020040400000010100202000000080800000000000404000000000002020080400808010100000004040080800
...  00000000040400808000000000004040000000000000000404E0020100402008040000002010040200000010080000000000080400000000000
...  4020080401008000000402008040000002010000000000010080000000000080201004020080401008020100402008040100802010040200804
...  0100802010080201004020000001008020100000008040000002010000000804000000000004020000000000020138004040080801010020200
...  4040000001010020200404000000000002020000000808010100202004040080800000020200404008080000000000040400000010100202004
...  0400808010100000004040080801010000000000008080000002010040200804010080201004020080401008020100402008040100802010040
...  20080401008020100802E0020100202000000080801010000000000000000101000000000000000000000402004040000001010020200000000
...  0000000020200000000000000000000080400808000000202004040000000000000000404000000000000000000001008010100000004040080
...  801010000000000008080000002020040400000000000000004040000001013880100300200600400C0080180100300200600400C0080180100
...  300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100
...  300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100
...  300200600400C0080180100300200600400C00801801002100008040400801080008020200400800804018010020040100600400C00801

*** Test Cases ***
5GC001095-ET-A010 interFre_intergNB_Pscell_change_with_SRB3
    [Documentation]
    ...   [purpose]: The purpose of this case is to verify the inter-gNB PSCell change with SRB3
    ...   [Configuration]: 2 classical cmWave gNb, 1 eNb, 1 WNC
    ...   [Cover Feature]: 5GC001095
    [Tags]    SS_61795
    Set UE Parameters Before Attach  ue_id=31
    UE Attach and establish EN-DC    ue_id=31
    Trigger A2 And A3 Measurement with SRB3    ue_id=31
    Check WireShark Log    ${CURDIR}${/}A2A_A_010${/}a2a.ini
    Check RRC log  ${CURDIR}${/}A2A_A_010${/}a2a_rrc.ini

5GC001095-ET-A019 A5_RSRP_RSRQ_Measurement_removal_without_SRB3
    [Documentation]
    ...   [purpose]: The purpose of this case is to verify the A2 and A1 report without SRB3
    ...   [Configuration]: 2 classical cmWave gNb, 1 eNb, 1 WNC
    ...   [Cover Feature]: 5GC001095
    [Tags]    SS_61797
    Onlineparamchange    ${Online_Param_A019}
    Set UE Parameters Before Attach  ue_id=32
    UE Attach and establish EN-DC    ue_id=32
    Trigger A2 And A1 Measurement  ue_id=32
    Check RRC log    ${CURDIR}${/}A2A_A_019${/}a2a.ini

5GC001095-ET-A022 HO_fail_when_delete_NRHOIF_without_SRB3
    [Documentation]
    ...   [purpose]: The purpose of this case is to verify the inter-gNB PSCell change without SRB3 fail when
    ...              delete NRHOIF
    ...   [Configuration]: 2 classical cmWave gNb, 1 eNb, 1 WNC
    ...   [Cover Feature]: 5GC001095
    [Tags]    SS_61799
    Onlineparamchange    ${Online_Param_A022}
    Set UE Parameters Before Attach  ue_id=33,34
    start rrc log    1st_UE_with_NRHOIF
    UE Attach and establish EN-DC    ue_id=33
    Trigger A2 And A3 Measurement without SRB3    ue_id=33
    Get rrc log
    Onlineparamchange    ${Online_Param_A022_1}
    UE Attach and establish EN-DC no A2    ue_id=34
    Check RRC log     ${CURDIR}${/}A2A_A_022${/}a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri
    Comment    Debug Enter Into Egate

Modify Cfg
    Update Cfg    ${Update_Cfg_1}
    Update Cfg    ${Update_Cfg_2}
    Update Cfg    ${Update_Cfg_3}
    Update Cfg    ${Update_Cfg_4}
    Update Cfg    ${Update_Cfg_5}
    Update Cfg    ${Update_Cfg_6}
    Update Cfg    ${Update_Cfg_7}
    Update Cfg    ${Update_Cfg_8}
    Update Cfg    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Update Cfg    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=9
    Update Cfg    set_cell id=1 enb=11 eci=0x1234701 pci=7:2 tac=222 proxy=10.0.2.1:8887 earfcn=2000:20000 mandatory_for_activation=off
    Update Cfg    set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy=10.0.2.1:12219 earfcn=2000:20000 mapped_earfcn=4200:22200
    Update Cfg    gnb_set id=3 s1u=10.0.1.122 plmn=311:489 gnb_id=0x3 type=simulated daemon=10.0.2.1:22222 x2=10.0.1.122:36422 x2_peers=none
    Update Cfg    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Update Cfg    gnb_endc_param id=3 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0
    Update Cfg    gnb_param id=3 x2_listening_socket=1 measEvent=A3

Set UE Parameters Before Attach
    [Arguments]  ${ue_id}
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2
    Execute Egate Command    enb_x2_link_up enb=1 target=3    ENB-1: X2AP Link with GNB-3
    Execute Egate Command    enb_x2_link_up enb=11 target=2    ENB-11: X2AP Link with GNB-2
    Execute Egate Command    enb_x2_link_up enb=11 target=3    ENB-11: X2AP Link with GNB-3
    Execute Egate Command    enb_timer T_RRC_TRANSACTION=4s
	Execute Egate Command    trace enb=11 protocol=all on
	Execute Egate Command    enb_endc_param id=1 serving_cell_index_range_scg=8:14

OnlineParamChange
    [Arguments]  ${Online_Param}
    Delta Commission Parameters  ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

UE Attach and establish EN-DC
  [Arguments]  ${ue_id}
  Execute Egate Command  ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
  ...    UE IS ACTIVE
  Execute Egate Command  ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg
  ...    UE${ue_id}: Proxy \\(eNB 2 cell 1\\) reported successful RA

Trigger A2 And A3 Measurement with SRB3
  [Arguments]  ${ue_id}
   Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=3 event=A2 srsrp_nr=30 srsrq_nr=30    pass_regexp=rrcReconfigurationComplete
   ${a3_cmd}    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=381 nrsrp_nr=20 nrsrq_nr=20
   Execute Egate Command    ${a3_cmd}    pass_regexp=Bearer-type change from MCG to SCG-split is successful

Trigger A2 And A1 Measurement
  [Arguments]  ${ue_id}
   ${a2_cmd}    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=3 event=A2 srsrp_nr=9 srsrq_nr=9 ssinr_nr=9
   Execute Egate Command    ${a2_cmd}    pass_regexp=rrcConnectionReconfigurationComplete
   ${a1_cmd}    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=4 event=A1 srsrp_nr=8 srsrq_nr=8 ssinr_nr=8
   Execute Egate Command    ${a1_cmd}    pass_regexp=rrcConnectionReconfigurationComplete

Trigger A2 And A3 Measurement without SRB3
  [Arguments]  ${ue_id}
   Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A2 srsrp_nr=30 srsrq_nr=30    rrcConnectionReconfigurationComplete
   ${a3_cmd}    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=4 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=381 nrsrp_nr=20 nrsrq_nr=20
   Execute Egate Command    ${a3_cmd}    pass_regexp=Bearer-type change from MCG to SCG-split is successful


UE Attach and establish EN-DC no A2
  [Arguments]  ${ue_id}
  Start RRC Log  establish_EN-DC_${ue_id}
  Execute Egate Command  ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
  ...    UE IS ACTIVE
  Execute Egate Command  ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg
  ...    UE${ue_id}: Proxy \\(eNB 2 cell 1\\) reported successful RA
  Get RRC Log
