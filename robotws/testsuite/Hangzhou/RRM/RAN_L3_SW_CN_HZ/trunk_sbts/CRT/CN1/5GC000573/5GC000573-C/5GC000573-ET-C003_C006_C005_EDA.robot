*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Stop Capture Logs And Restore ENV In Test Teardown
Force Tags  QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    team-L3CN3_SG2
...    owner-huibo.miao    release-5G19A     5GC000573    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource  ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${carrierfreq}    636576
@{PARAMS_IN_SCF}    @{feature_flag}    @{non_srb3}    @{CBRA}    @{a3_rsrp}    @{intra_freq_inter_gnb_35}
@{feature_flag}    @{intra_freq_inter_gnb_36}
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
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
@{CBRA}
...    NRCELL-1:cbraPreamblesPerSsb=n64
@{a3_rsrp}
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:rsrpThresholdSSB=11
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:filterCoeffSsbRsrp=fc4
...    NRCELL-1:sMeasConfigSsbRsrp=1
@{intra_freq_inter_gnb_35}
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
@{intra_freq_inter_gnb_36}
...    NRADJNRCELL-2:cellDepType=SA+NSA
...    NRADJNRCELL-2:fiveGsTac=0
...    NRADJNRCELL-2:freqBandIndicatorNR=78
...    NRADJNRCELL-2:gNbId=36
...    NRADJNRCELL-2:gNbIdLength=22
...    NRADJNRCELL-2:lcrId=1
...    NRADJNRCELL-2:nrarfcn=636666
...    NRADJNRCELL-2:physCellId=383
...    NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=36
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=1
...    NRCELL-1/NRREL-2:removeNotAllowed=true
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    @{bandwidth_configuration}

@{bandwidth_configuration}
...    NRCELL-1:chBw=100MHz

${SA_Capa_perUE_Full}  SEPARATOR=
...    ED007000479A4BBF5FFFFEF8001BD409A00CFDBFCB98AD7FFBF900001F53FFFFD1000000E77EF3FFF3FFFEC0001F78017FFE00002C7
...    807E290401BFFEF0BFFEBC00E54D00158800000000023003CAA08

${Capa_LTE}  SEPARATOR=
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

@{PM_Counters_Check_C}
...    ${X2_SGNB_CHG_REQD_SENT}=4
...    ${X2_SGNB_CHG_CONF_RECEIVED}=2
...    ${X2_SGNB_RECONF_SN_CH_T}=0
...    ${X2_SGNB_RECONF_SN_CH_RCVD}=1
...    ${X2_SGNB_RECONF_ACK_SN_CH_RCVD}=1
...    ${X2_SGNB_RECONF_NACK_SN_CH_RCVD}=0
...    ${X2_SGNB_ADD_REQ_SN_CH_RCVD}=1
...    ${X2_SGNB_ADD_REQ_ACK_SN_CH_SENT}=1
...    ${X2_SGNB_CHG_REF_RECEIVED}=2

@{PM_Counters_Check_EDA}
...    ${X2_SGNB_CHG_REQD_SENT}=1
...    ${X2_SGNB_CHG_CONF_RECEIVED}=0
...    ${X2_SGNB_CHG_REF_RECEIVED}=0

${X2_SGNB_CHG_REQD_SENT}             M55112C02501
${X2_SGNB_CHG_CONF_RECEIVED}         M55112C02502
${X2_SGNB_RECONF_SN_CH_T}            M55112C02514
${X2_SGNB_RECONF_SN_CH_RCVD}         M55112C02505
${X2_SGNB_RECONF_ACK_SN_CH_RCVD}     M55112C02506
${X2_SGNB_RECONF_NACK_SN_CH_RCVD}    M55112C02511
${X2_SGNB_CHG_REF_RECEIVED}          M55112C02512
${X2_SGNB_ADD_REQ_SN_CH_RCVD}        M55112C02503
${X2_SGNB_ADD_REQ_ACK_SN_CH_SENT}    M55112C02504

@{case_specific_parameters_1}
...    NRBTS:actUeDeltaConfigOptimize=true
...    NRCELL-1:blockHoTimer=10

@{case_specific_parameters_2}
...    delete:NRCELL-1:blockHoTimer
...    NRBTS:actMobilityRetryToSecondBestCell=true

@{case_specific_parameters_3}
...    NRBTS:tDCoverall=500

*** Test Cases ***
5GC000573-ET-C003_C006_C005_Verify_HO_in_some_conditions
    [Documentation]
    ...    Verify handover with configuration blacklist and Delta Config optimization 
    ...    Verify handover retry to 2nd best cell (cell is avaliable in inter)
    [Tags]    QC_47206    CRT    
    Delta Commission Parameters    ${case_specific_parameters_1}
    Clear Counter Files
    X2 Link for simulated gNB-35
    Ue Attach To LTE and Initial Endc
    Verify handover with configuration blacklist and Delta Config optimization
    Setup new env and attach new UE
    Verify handover retry to 2nd best cell
    Check Counters    ${PM_Counters_Check_C}
    Check Wireshark Log    ${CURDIR}${/}a2a_C${/}a2a_wireshark.ini    wait_string=UEContextRelease::3

5GSW_CP_EDA_5GC000573_PR560492_HO_fails_due_to_concurrency_operation_from_eNB
    [Documentation]
    ...    This case is for one EDA, will set tDCoverall=500ms; 
    ...    link: https://jiradc.ext.net.nokia.com/browse/FIVEGSWCN2ETEDA-113 
    ...    check msg: SgNBChangeRequired but no SgNBChangeConfirm 
    ...    Check msg: SgNBModificationRequest & SgNBModificationRequestReject
    [Tags]    QC_81126    
    Delta Commission Parameters    ${case_specific_parameters_3}
    Clear Counter Files
    wait_before_next_pm_interval_start
    X2 Link for simulated gNB-35
    Ue Attach To LTE and Initial Endc    ue_id=32
    HO fails due to simulated LTE eNB no response
    Concurrency operation from eNB to add DRB    ue_id=32
    Recover the eNB    
    Check Counters    ${PM_Counters_Check_EDA}
    Check Wireshark Log    ${CURDIR}${/}a2a_EDA${/}a2a_wireshark.ini    wait_string=UEContextRelease::8

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

X2 Link for simulated gNB-35
    Execute Egate Command    enb_x2_link_up enb=1 target=3    
    ...    pass_regexp=is UP

X2 Link for simulated gNB-36
    Execute Egate Command    enb_x2_link_up enb=1 target=4    
    ...    pass_regexp=is UP

Setup new env and attach new UE
    UE Detach From GNB
    Delta Commission Parameters    ${case_specific_parameters_2}
    X2 Link for simulated gNB-36
    Ue Attach To LTE and Initial Endc

Verify handover with configuration blacklist and Delta Config optimization
    Make error condition to force UE to enter blacklist and clear the condition
    HO fails during blockHoTimer
    HO and HO back be ok after blockHoTimer

Verify handover retry to 2nd best cell
    Make error condition to force HO failure with first cell
    HO ok with second best cell   

Modify Cfg
    ${V_1}    catenate
    ...    ue_param id=31 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE}
    ${V_5}    catenate
    ...    ue_param id=32 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE}
    ${V_2}    catenate
    ...    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666 
    ...    gscn=7880 mandatory_for_activation=off
    ${V_3}    catenate
    ...    set_cell id=1 gnb=4 pci=127:2 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=636666:636666 
    ...    gscn=7880 mandatory_for_activation=off
    ${V_4}    catenate
    ...    set_ue simulated id=31 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nea=null+zuc nia=null+zuc imsi=311:489:21645400
    ${V_6}    catenate
    ...    set_ue simulated id=32 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nea=null+zuc nia=null+zuc imsi=311:489:21645401
    Update Cfg    ${V_1}
    Update Cfg    ${V_5}
    Update Cfg    gnb_set id=3 s1u=10.0.1.126 plmn=311:489 gnb_id=0x23:22 type=simulated daemon=:22222 x2=10.0.1.126:36422
    Update Cfg    gnb_set id=4 s1u=10.0.1.128 plmn=311:489 gnb_id=0x24:22 type=simulated daemon=:22222 x2=10.0.1.128:36422
    Update Cfg    ${V_2}
    Update Cfg    ${V_3}
    Update Cfg    gnb_endc_param id=3 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0
    Update Cfg    gnb_endc_param id=4 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0
    Update Cfg    ${V_4}
    Update Cfg    ${V_6}
    Update Cfg    set_bearer id=3 ue=32 qci=8 pdn=1 preprovisioned=on filter=2 precedence=2

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

Send And Verify Throuput
    [Arguments]    ${ue_id}=31
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=10 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10    UE ${ue_id}: UDP UL
    Verify Throuput    sleep_time=30s    ue_id=${ue_id}

Verify Throuput
    [Arguments]    ${sleep_time}=10s    ${ue_id}=31
    sleep    ${sleep_time}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>9

Make error condition to force UE to enter blacklist and clear the condition
    [Arguments]    ${phycell_id}=381    ${ue_id}=31
    ${cmd}    Catenate    link_x2_management_abnormal_cases
    ...    id=3 partner=1 sgnb_addition_rsp=reject sgnb_addition_failure_cause=RN_no_radio_resources
    Execute Egate Command    ${cmd}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=SgNBChangeRefuse
    Clear the condition

Clear the condition
    ${cmd1}    Catenate    link_x2_management_abnormal_cases
    ...    id=3 partner=1 sgnb_addition_rsp=normal_rsp
    Execute Egate Command    ${cmd1}

HO fails during blockHoTimer
    Try To Initial IntraFreA3 Ho    phycell_id=381

HO fails due to simulated LTE eNB no response
    ${cmd}    Catenate    link_x2_management_abnormal_cases
    ...    id=1 partner=2 sgnb_change_rsp=no_rsp
    Execute Egate Command    ${cmd}
    Try To Initial IntraFreA3 Ho    phycell_id=381    ue_id=32

Try To Initial IntraFreA3 Ho
    [Arguments]    ${phycell_id}    ${ue_id}=31
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${ret}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    ...    fail_regexp=Bearer-type change from MCG to SCG-split is successful    timeout=0.1

Concurrency operation from eNB to add DRB
    [Arguments]    ${ue_id}=31
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} bearer_to_add=3 by=enb cause=MISC_CauseMisc_unspecified type=split_scg
    ...    pass_regexp=Sending SgNB Modification Request    timeout=0.1

Recover the eNB
    ${cmd}    Catenate    link_x2_management_abnormal_cases id=1 partner=2 sgnb_change_rsp=normal_rsp
    Execute Egate Command    ${cmd}

HO and HO back be ok after blockHoTimer
    [Arguments]    ${blockHoTimer}=10s
    sleep    ${blockHoTimer}
    Ue Ho To simulated gNB
    Ue Ho Back real gNB

Ue Ho To simulated gNB 
    Initial IntraFreA3 Ho    phycell_id=381

Ue Ho Back real gNB 
    Initial IntraFreA3 Ho    phycell_id=50
    Verify Throuput

Make error condition to force HO failure with first cell
    ${cmd}    Catenate    link_x2_management_abnormal_cases
    ...    id=3 partner=1 sgnb_addition_rsp=reject sgnb_addition_failure_cause=RN_cell_not_available
    Execute Egate Command    ${cmd}

HO ok with second best cell
    [Arguments]    ${2ND_gNB.pci}=381    ${3RD_gNB.pci}=383    ${ue_id}=31
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr
    ...    id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 
    ...    phycell_id=${2ND_gNB.pci} nrsrp_nr=30 nrsrq_nr=30 
    ...    phycell_id=${3RD_gNB.pci} nrsrp_nr=26 nrsrq_nr=26
    Execute Egate Command    ${cmd}    pass_regexp=Bearer-type change from MCG to SCG-split is successful

Initial IntraFreA3 Ho
    [Arguments]    ${phycell_id}    ${ue_id}=31
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=Sending SgNB Change Confirm

Delete X2 link for simulated gnb
    Execute Egate Command    link_x2_reset from=1 to=3
    ...    pass_regexp=closed by peer

UE Detach From GNB
  [Arguments]    ${expect_string}=${EMPTY}
  Execute Egate Command  ue_detach id=31    ${expect_string}

Stop Capture Logs And Restore ENV In Test Teardown
    Delete X2 link for simulated gnb
    UE Detach From GNB
    Common Test Teardown And Stop Capture Logs
