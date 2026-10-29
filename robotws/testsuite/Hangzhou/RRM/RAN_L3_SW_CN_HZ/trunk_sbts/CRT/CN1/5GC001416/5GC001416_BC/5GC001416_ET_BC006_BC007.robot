*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_CN2    Owner_shelly.song    release-SBTS22R2
Resource          ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC001416}
...    @{NRADJ}
...    @{NRHOIF}

@{5GC001416}
...    NRBTS:tmpActFeat1=1
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=257
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=257
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraMeNBMobility=true
...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRBTS:cipherPrefL:nea0=7|nea3_128=0
...    NRBTS:cipherPrefL:nea1_128=0|nea3_128=0
...    NRBTS:cipherPrefL:nea2_128=0|nea3_128=0
...    NRBTS:srb3SupportEnabled=true

@{NRADJ}
...    NRBTS/NRADJNRCELL-2:cellDepType=NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=0
...    NRBTS/NRADJNRCELL-2:gNbId=31
...    NRBTS/NRADJNRCELL-2:lcrId=11
...    NRBTS/NRADJNRCELL-2:nrarfcn=636666
...    NRBTS/NRADJNRCELL-2:physCellId=383
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=${EMPTY}
...    NRBTS/NRADJNRCELL-3:cellDepType=NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=0
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=261
...    NRBTS/NRADJNRCELL-3:gNbId=4
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=2
...    NRBTS/NRADJNRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRBTS/NRADJNRCELL-3:nrarfcn=2071591
...    NRBTS/NRADJNRCELL-3:physCellId=384
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:gNbId=31
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:gNbId=4
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
@{NRHOIF}
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:cellDepType=NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=261
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=120 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-1/NRHOIF-1:ssbFrequency=2071387
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=10
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

#counters
${SGNB_NSA_HO_ADMISS_MFBI_REQ}    M55114C00503
${SGNB_NSA_HO_ADMISS_MFBI_SUCC}    M55114C00504

@{BC_007}
...    ${SGNB_NSA_HO_ADMISS_MFBI_REQ}=1
...    ${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=1

#UE CAP
${ue_nr_capabilities}    SEPARATOR=
...    ED007000479A4BBF5FFFFEF8005BD409800CFDBFCB98AD7FFBF900001F53FFFFC000100880000073BF79FFF9FFFF60000FBC00B
...    FFF0000163C03F148200DFFF785FFF5E00F2A6A7000158800000000023007CAA080E0

${ue_eutra_nr_capabilities}    SEPARATOR=
...    BD1BA083058380713000000018062B000060400C1001830030600E260000010300C160801C4C000004060182C000389800000C0
...    C03058100713000002018060B0600E2600000503000100510000C0100282644000389178A038400040201002004A00000000000
...    0000000000000000000000080000010000000040000008000000020000004000000010000002000000008000001000000004000
...    0010000000020000000800000

*** Test Cases ***
5GC001416-ET-BC006_Verify_Succ_Removal_of_A3A5_and_Config_of_A2_during_Handling_A1_Meas_Report_for_UE_using_alter_band_w_SRB3
    [Documentation]
    ...    [purpose]: The purpose of this case is to verify
    ...    Succ_Removal_of_A3A5_and_Config_of_A2_during_Handling_A1_Meas_Report_for_UE_using_alter_band_w_SRB3
    [Tags]    QC_60802    BC006
    Attach UE Check The Result
    Verify A2 Trigger A3_A5 With SRB3
    Verify A1 Trigger A1_A3_A5 Removed Without SRB3
    UE Detach

5GC001416-ET-BC007_Verify_Successful_Intra-MeNB_Inter-SgNB_handover_for_UE_using_alternative_bands_with_SRB3_Inter-Frequency_SN_Initiated
    [Documentation]    The purpose of this test case is to verify successful intra menb inter sgnb HO inter frequency
    ...    for ue using alternative bands with srb3
    [Tags]    QC_60803    BC007
    Clear Counter Files
    Attach UE Check The Result
    Verify A2 Trigger A3_A5 With SRB3
    Send A3 Measurement
    Inter Sgnb Handover From Gnb Sim
    Check Counters    ${BC_007}
    UE Detach

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${GNB4}    catenate
    ...    set_gnb id=4 s1u=10.0.1.128 plmn=311:489 gnb_id=0x4 type=simulated daemon=:22222 x2=10.0.1.128:36422
    ${GNB4_CELL1}    catenate
    ...    set_cell id=1 gnb=4 pci=128:0 tac=3 nrci=0x2 tdd_cell=on proxy=10.0.2.90:22223 nr_arfcn=2071591:2071591
    ...    gscn=22446 mandatory_for_activation=off mapped_MFBI=257
    ${UE31}    catenate
    ...    set_ue simulated id=31 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    eia=null+snow3g+aes eea=null nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc imsi=250:555:21645411
    Update Cfg    ${GNB4}
    Update Cfg    ${GNB4_CELL1}
    Update Cfg    ${UE31}
    Update Cfg    ue_param id=31 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    Update Cfg    gnb_endc_param id=4 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0

Attach UE Check The Result
    Execute Egate Command    enb_x2_link_up enb=1 target=4    ENB-1: X2AP Link with GNB-4    timeout=60    sleep_time=5
    Execute Egate Command    ue_change_location id=31 enb=1 cell=1
    Execute Egate Command    ue_attach id=31    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=31 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    UE31: Proxy \\(eNB 2 cell 1\\) reported successful RA

Verify A2 Trigger A3_A5 With SRB3
    Send A2 Measurement

Verify A1 Trigger A1_A3_A5 Removed Without SRB3
    Start To Capture Wireshark Log    tag=A1
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=2 event=A1 srsrp_nr=8 srsrq_nr=8 ssinr_nr=8
    ...    pass_regexp=rrcReconfigurationComplete

Send A2 Measurement
    Start RRC Log    BC007_Alternativeband_A2
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11 ssinr_nr=11    timeout=60
    ...    pass_regexp=rrcReconfigurationComplete
    Rrc Should Contain    rrcReconfiguration
    Rrc Should Contain    freqBandIndicatorNR 257
    Rrc Should Contain    eventA1
    Rrc Should Contain    eventA3
    Rrc Should Contain    eventA5

Send A3 Measurement
    Start RRC Log    BC007_Alternativeband_A3
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=3 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=384 nrsrp_nr=31 nrsrq_nr=31
    ...    pass_regexp=Bearer-type change from MCG to SCG-split is successful
    Rrc Should Contain    downlinkConfigCommon
    Rrc Should Contain    frequencyBandList
    Rrc Should Contain    257

Inter Sgnb Handover From Gnb Sim
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=1 event=A2 srsrp_nr=7 srsrq_nr=7
    ...    NR RRC Reconfiguration procedure completed successfully
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=9 event=A3 srsrp_nr=19 srsrq_nr=19 phycell_id=50 nrsrp_nr=31 nrsrq_nr=31
    ...    Inter Sgnb Handover is successful

UE Detach
    Execute Egate Command    ue_detach id=31    UE IS OFF