*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_CN2    Owner_shelly.song    release-SBTS22R2
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC001416}
...    @{create_band_NRMULTIBANDINFO_PROFILE}
...    @{nrNsPmaxList}
...    @{NRADJ}
...    @{NRHOIF}

@{5GC001416}
...    NRBTS:tmpActFeat1=1
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=257
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=257
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraMeNBMobility=true
...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRBTS:cipherPrefL:nea0=1|nea3_128=9
...    NRBTS:cipherPrefL:nea1_128=0|nea3_128=9
...    NRBTS:cipherPrefL:nea2_128=0|nea3_128=9
...    NRBTS:nsaInactivityTimer=0

@{create_band_NRMULTIBANDINFO_PROFILE}
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=0|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=78|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=1|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-2
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=77|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-2
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:userLabel=${EMPTY}

@{nrNsPmaxList}
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=5
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalPmax=4
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=6
...    NRBTS/NRNSPMAX_PROFILE-1:userLabel=${EMPTY}
...    NRBTS/NRNSPMAX_PROFILE-2:nrNsPmaxList:additionalSpectrumEmission=2
...    NRBTS/NRNSPMAX_PROFILE-2:nrNsPmaxList:additionalPmax=1
...    NRBTS/NRNSPMAX_PROFILE-2:nrNsPmaxList:nrNsPmaxPriority=3
...    NRBTS/NRNSPMAX_PROFILE-2:userLabel=${EMPTY}

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

@{delta_commission_BC09}
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN

#swconfig ENABLE_DEBUG_FLAGS
${check_counter_interval1}    0x590072
${check_counter_interval2}    0x41001b
${check_counter_interval3}    0x590097
${develop_request}    0x70005

@{PARAMS_IN_SWCONFIG}
...    ${check_counter_interval1}=1
...    ${check_counter_interval2}=1
...    ${check_counter_interval3}=1
@{PARAMS_IN_SWCONFIG_AP}
...    ${develop_request}=70

#counters
${SGNB_NSA_HO_ADMISS_MFBI_REQ}    M55114C00503
${SGNB_NSA_HO_ADMISS_MFBI_SUCC}    M55114C00504

@{BC008}
...    ${SGNB_NSA_HO_ADMISS_MFBI_REQ}=1
...    ${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=1

@{BC009}
...    ${SGNB_NSA_HO_ADMISS_MFBI_REQ}=0
...    ${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=0
#UE CAP
${ue_nr_capabilities}    SEPARATOR=
...    ED007000479A4BBF5FFFFEF8005BD409800CFDBFCB98AD7FFBF900001F53FFFFC000100880000073BF79FFF9FFFF60000FBC00B
...    FFF0000163C03F148200DFFF785FFF5E00F2A6A7000158800000000023007CAA080E0

${ue_eutra_nr_capabilities}    SEPARATOR=
...    BD1BA083058380713000000018062B000060400C1001830030600E260000010300C160801C4C000004060182C000389800000C0
...    C03058100713000002018060B0600E26000005030001005D0000000C01002E2600074000000389178A038400040201002004A00
...    0000000000000000000000000000000080000010000000040000008000000020000004000000010000002000000008000001000
...    00000400000100000000200000008000000

*** Test Cases ***
5GC001416-ET-BC005_Verify_Succ_Rem_of_A3A5_and_Config_of_A2_during_A1_Measurement_Report_for_UE_using_alte_band_wo_SRB3
    [Documentation]    The purpose of this test case is to verify successful
    ...    sgnb additon with multi-frequency band cells for ue using alternative band
    ...    and verify A2 trigger A1 A3 A5  with multi-frequency band cells for ue using alternative band
    ...    and verify A1 trigger A1 A3 A5  removed with multi-frequency band cells for ue using alternative band
    [Tags]    QC_47218    BC005
    Attach UE Check The Result And Check The Traffic
    Verify A2 Trigger A3_A5 Without SRB3
    Verify A1 Trigger A1_A3_A5 Removed Without SRB3
    UE Detach

5GC001416-ET-BC008_Verify_Succ_Intra-MeNB_Inter-SgNB_HO_for_UE_using_alter_bands_wo_SRB3_Inter-Fre_SN_Initiated
    [Documentation]    The purpose of this test case is to verify successful intra menb inter sgnb HO inter frequency
    ...    for ue using alternative bands without srb3
    [Tags]    QC_60800    BC008
    Clear Counter Files
    Attach UE Check The Result
    Send A2 Measurement
    Send A3 Measurement
    Inter Sgnb Handover From Gnb Sim
    Check Counters    ${BC008}
    Check WireShark Log    ${CURDIR}${/}a2a_BC008${/}a2a.ini    wait_string=BearerContextModificationResponse
    UE Detach

5GC001416-ET-BC009_Verify_IntraMeNB_InterSgNB_HO_for_UE_using_alter_bands_wo_SRB3_InterFre_online_mod_NRHOIF_in_sGnb
    [Documentation]    The purpose of this test case is to verify successful intra menb inter sgnb HO inter frequency
    ...    for ue using alternative bands without srb3 (delete cell alternative band after A2 should be no impact)
    ...    verify HO from gnb real to gnb sim successful and handover back failed from gnb sim to real gnb
    ...    (due alternative band was delete from cell)
    [Tags]    QC_47217    BC009
    Clear Counter Files
    Attach UE Check The Result
    Send A2 Measurement
    Modify Scf For BC_09
    Send A3 Measurement
    Inter Sgnb Handover Failed From Gnb Sim
    Check Counters    ${BC009}
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

Attach UE Check The Result And Check The Traffic
    Attach UE Check The Result
    Check WireShark Log    ${CURDIR}${/}a2a_BC005${/}a2a1.ini    wait_string=BearerContextModificationResponse

Send A2 Measurement
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11 ssinr_nr=11
    ...    Sending SgNB Modification Confirm

Send A3 Measurement
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=3 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=384 nrsrp_nr=31 nrsrq_nr=31
    ...    Bearer-type change from MCG to SCG-split is successful

Verify A2 Trigger A3_A5 Without SRB3
    Start To Capture Wireshark Log    tag=A2
    Send A2 Measurement
    Check WireShark Log    ${CURDIR}${/}a2a_BC005${/}a2a2.ini    name=A2    wait_string=rrcReconfigurationComplete

Verify A1 Trigger A1_A3_A5 Removed Without SRB3
    Start To Capture Wireshark Log    tag=A1
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=2 event=A1 srsrp_nr=8 srsrq_nr=8 ssinr_nr=8
    ...    Successfully reconfigured dual connectivity
    Check WireShark Log    ${CURDIR}${/}a2a_BC005${/}a2a3.ini    name=A1    wait_string=rrcReconfigurationComplete

Inter Sgnb Handover From Gnb Sim
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=1 event=A2 srsrp_nr=7 srsrq_nr=7
    ...    NR RRC Reconfiguration procedure completed successfully
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=9 event=A3 srsrp_nr=19 srsrq_nr=19 phycell_id=50 nrsrp_nr=31 nrsrq_nr=31
    ...    Inter Sgnb Handover is successful

Modify Scf For BC_09
    delta commission parameters    ${delta_commission_BC09}


Inter Sgnb Handover Failed From Gnb Sim
    ${measid1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=31    carrierfreq=2071387    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=${measid1} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    NR RRC Reconfiguration procedure completed successfully
    ${measid2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=31    carrierfreq=636576    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=${measid2} event=A3 srsrp_nr=19 srsrq_nr=19 phycell_id=50 nrsrp_nr=31 nrsrq_nr=31
    ...    Inter Sgnb Handover failed


UE Detach
    Execute Egate Command    ue_detach id=31    UE IS OFF


