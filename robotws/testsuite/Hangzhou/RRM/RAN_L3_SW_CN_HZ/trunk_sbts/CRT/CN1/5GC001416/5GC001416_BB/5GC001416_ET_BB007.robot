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
...    @{NRREL}

@{5GC001416}
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRBTS:tmpActFeat1=1
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasEnabled=rsrp
...    NRBTS:srb3SupportEnabled=true
...    NRBTS:cipherPrefL:nea0=3|nea3_128=0
...    NRBTS:cipherPrefL:nea1_128=0|nea3_128=0
...    NRBTS:cipherPrefL:nea2_128=0|nea3_128=0
...    NRBTS:nsaInactivityTimer=0

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

@{DELETE_PROFILE}
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN

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

@{BB007}
...    NRCELL-1:${SGNB_NSA_HO_ADMISS_MFBI_REQ} =0
...    NRCELL-1:${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=0
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
5GC001416-ET-BB007_Verify_IntraSgNB_IntraFreq_HO_Failed_To_SourceSgNBcell_for_UE_using_alternative_bands
    [Documentation]    The purpose of this test case is to
    ...    1.Verify alternave band will be send to enb in SgNBAdditionRequest and SgNBAdditionRequestAcknowledge
    ...    2.Verify intra SgNB HO is failed to source SgNB cell due to remove nrConnectModeProfileDN
    [Tags]    QC_47214    BB007
    Check Egate Console freqBandIndicatorNr
    Attach UE Check The Result And Check The Traffic
    Perform UE Intra SgNB Handover to Cell2
    Check MeasId In Measurement Reort Is 1
    Delete Cell1 NrConnectModeProfileDN
    Perform UE Intra SgNB Handover to Cell1 Failed
    Check Counters    ${BB007}
    UE Detach

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${UE31}    catenate
    ...    set_ue simulated id=31 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    eia=null+snow3g+aes eea=null nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc imsi=311:489:21645400
    Update Cfg    ue_param id=31 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    Update Cfg    set_bearer id=2 ue=31 qci=9 pdn=1 ip=4.7.254.209 default=on trf_type=internal

Check Egate Console freqBandIndicatorNr
    ${Trigger_ENDC_X2}    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2    timeout=60    sleep_time=5
    Should Contain    ${Trigger_ENDC_X2}    freqBandIndicatorNr 78
    Should Contain    ${Trigger_ENDC_X2}    freqBandIndicatorNr 77

Attach UE Check The Result And Check The Traffic
    Execute Egate Command    ue_change_location id=31 enb=1 cell=1
    Execute Egate Command    ue_attach id=31    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=31 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    UE31: Proxy \\(eNB 2 cell 1\\) reported successful RA
    Check WireShark Log    ${CURDIR}${/}a2a_BB007${/}a2a1.ini    wait_string=BearerContextModificationResponse
    Start To Capture Wireshark Log    tag=HO

Perform UE Intra SgNB Handover to Cell2
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=Proxy \\(eNB 2 cell 2\\) reported successful RA

Check MeasId In Measurement Reort Is 1
    Check WireShark Log    ${CURDIR}${/}a2a_BB007${/}a2a2.ini    name=HO    wait_string=BearerContextInactivityNotification

Perform UE Intra SgNB Handover to Cell1 Failed
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=30 nrsrq_nr=30
    ...    fail_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA

Delete Cell1 NrConnectModeProfileDN
    Delta Commission Parameters    ${DELETE_PROFILE}

UE Detach
    Execute Egate Command    ue_detach id=31    UE IS OFF
