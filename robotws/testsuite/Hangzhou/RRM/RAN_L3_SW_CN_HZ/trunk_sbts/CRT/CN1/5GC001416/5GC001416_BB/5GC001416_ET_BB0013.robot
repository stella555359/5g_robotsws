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
...    @{NRREL}

@{5GC001416}
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRBTS:tmpActFeat1=1
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
...    NRBTS:actInterMeNBMobility=true
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasEnabled=rsrp
...    NRBTS:srb3SupportEnabled=false

@{NRREL}
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489|mncLength=3
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489|mncLength=3
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311|mncLength=3

#swconfig ENABLE_DEBUG_FLAGS
${check_counter_interval1}    0x590072
${check_counter_interval2}    0x41001b
${check_counter_interval3}    0x590097
${develop_request}    0x70005

@{PARAMS_IN_SWCONFIG}    ${check_counter_interval1}=1    ${check_counter_interval2}=1    ${check_counter_interval3}=1
@{PARAMS_IN_SWCONFIG_AP}     ${develop_request}=70

#conunters
${SGNB_NSA_HO_ADMISS_MFBI_REQ}    M55114C00503
${SGNB_NSA_HO_ADMISS_MFBI_SUCC}    M55114C00504

@{BB0013}
...    NRCELL-1:${SGNB_NSA_HO_ADMISS_MFBI_REQ} =1
...    NRCELL-1:${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=1
...    NRCELL-2:${SGNB_NSA_HO_ADMISS_MFBI_REQ} =1
...    NRCELL-2:${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=1

${ue_nr_capabilities}    SEPARATOR=
...    ED007000479A4BBF5FFFFEF8005BD409800CFDBFCB98AD7FFBF900001F53FFFFC000100880000073BF79FFF9
...    FFFF60000FBC00BFFF0000163C03F148200DFFF785FFF5E00F2A6A7000158800000000023007CAA080E0

${ue_eutra_nr_capabilities}    SEPARATOR=
...    BD1BA083058380713000000018062B000060400C1001830030600E260000010300C160801C4C000004060182C
...    000389800000C0C03058100713000002018060B0600E2600000503000100510000C0100282644000389178A03
...    8400040201002004A000201000080400020100008040002010080100210000804040080108000802020040084
...    0004010100200420002008080100210001008040080110000804020040080801002

*** Test Cases ***
5GC001416-ET-BB0013_Verify_Successful_Inter-MeNB_Cell_HO_Intra-SgNB_Intra-Frequency_handover_for_UE_using_alternative_bands_without_SRB3
    [Documentation]    The purpose of this test case is to
    ...    1.Verify alternave band will be send to enb in SgNBAdditionRequest and SgNBAdditionRequestAcknowledge
    ...    2.Verify inter MeNB intra SgNB HO using alternative band without SRB3
    [Tags]    QC_60814    BB013
    Check Egate Console freqBandIndicatorNr
    Set eNB Allow ENDC On And X2 Link To ENB11
    Attach UE Check The Result And Check The Traffic
    Perform UE Inter MeNB Handover to ENB2
    Perform UE Inter MeNB Handover to ENB1
    Check Counters    ${BB0013}
    UE Detach

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${eNB11}    catenate
    ...    set_enb id=11 plmn=311:489 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222 x2=10.0.1.127 x2u=10.0.1.137
    ...    type=simulated x2_peers=1
    ${eNB11_cell11}    catenate
    ...    set_cell id=11 enb=11 eci=0x1234701 pci=7:2 tac=222 proxy=10.0.2.1:12218 earfcn=1400:19400 tdd_cell=on mandatory_for_activation=off
    ${UE31}    catenate
    ...    set_ue simulated id=31 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    eia=null+snow3g+aes eea=null nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc imsi=250:555:21645411
    Update Cfg    ue_param id=31 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    Update Cfg    ${eNB11}
    Update Cfg    ${eNB11_cell11}
    Update Cfg    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7
    Update Cfg    set_bearer id=2 ue=31 qci=9 pdn=1 ip=4.7.254.209 default=on trf_type=internal


Check Egate Console freqBandIndicatorNr
    ${Trigger_ENDC_X2}    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2    timeout=60    sleep_time=5
    Should Contain    ${Trigger_ENDC_X2}    freqBandIndicatorNr 78
    Should Contain    ${Trigger_ENDC_X2}    freqBandIndicatorNr 77

Set eNB Allow ENDC On And X2 Link To ENB11
    Execute Egate Command    enb_x2_link_up enb=11 target=2    ENB-11: X2AP Link with GNB-2    timeout=60    sleep_time=5
    Execute Egate Command    enb_cell_param enb=1 id=1 allow_endc=on
    Execute Egate Command    enb_cell_param enb=11 id=1 allow_endc=on
    Execute Egate Command    ue_enb_endc_param id=1 candidate_cells_mn_hex_for_menb_ho=0B26DA810C804330

Attach UE Check The Result And Check The Traffic
    Execute Egate Command    ue_change_location id=31 enb=1 cell=1
    Execute Egate Command    ue_attach id=31    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=31 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    UE31: Proxy \\(eNB 2 cell 1\\) reported successful RA
    Check WireShark Log    ${CURDIR}${/}a2a_BB0013${/}a2a.ini    wait_string=BearerContextModificationResponse

Perform UE Inter MeNB Handover to ENB2
    Execute Egate Command    ue_enb_endc_param id=31 candidate_cells_mn_hex_for_menb_ho=0926DA802198
    ${ret1}=    Execute Egate Command    ue_ho id=31 ho_mode=INTRA_LTE enb=11 cell=11 rsrp=60:67
    ...    Intra-SGW X2 Handover \\(eNB 1 -> eNB 11\\) completed
    Should Contain    ${ret1}    Inter-eNB handover from ENB-1.1 to ENB-11.11 performed
    Should Contain    ${ret1}    UE31: Proxy (eNB 2 cell 2) reported successful RA

Perform UE Inter MeNB Handover to ENB1
    Execute Egate Command    ue_enb_endc_param id=31 candidate_cells_mn_hex_for_menb_ho=0926DA802190
    ${ret1}=    Execute Egate Command    ue_ho id=31 ho_mode=INTRA_LTE enb=1 cell=1 rsrp=60:67
    ...    Intra-SGW X2 Handover \\(eNB 11 -> eNB 1\\) completed
    Should Contain    ${ret1}    Inter-eNB handover from ENB-11.11 to ENB-1.1 performed
    Should Contain    ${ret1}    UE31: Proxy (eNB 2 cell 1) reported successful RA
    cells should be onair

UE Detach
    Execute Egate Command    ue_detach id=31    UE IS OFF