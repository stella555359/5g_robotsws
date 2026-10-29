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
...    @{create_band_NRMULTIBANDINFO_PROFILE}
...    @{nrNsPmaxList}
...    @{NRADJ}
...    @{NRHOIF}

@{5GC001416}
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRBTS:tmpActFeat1=1
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=41
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=90
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRBTS:cipherPrefL:nea0=1|nea3_128=9
...    NRBTS:cipherPrefL:nea1_128=0|nea3_128=9
...    NRBTS:cipherPrefL:nea2_128=0|nea3_128=9

@{NRADJ}
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=0
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=78
...    NRBTS/NRADJNRCELL-1:gNbId=35
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=636666
...    NRBTS/NRADJNRCELL-1:physCellId=381
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=0
...    NRBTS/NRADJNRCELL-2:gNbId=31
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=11
...    NRBTS/NRADJNRCELL-2:nrarfcn=636666
...    NRBTS/NRADJNRCELL-2:physCellId=383
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=${EMPTY}
...    NRBTS/NRADJNRCELL-3:cellDepType=NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=0
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=38
...    NRBTS/NRADJNRCELL-3:gNbId=4
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=2
...    NRBTS/NRADJNRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRBTS/NRADJNRCELL-3:nrarfcn=2071591
...    NRBTS/NRADJNRCELL-3:physCellId=384
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3

@{NRHOIF}
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:cellDepType=NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=38
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=120 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-1/NRHOIF-1:ssbFrequency=2071387
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=10
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

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

#UE CAP
${ue_nr_capabilities}    SEPARATOR=
...    ED007000479A4BBF5FFFFEF8005BD409800CFDBFCB98AD7FFBF900001F53FFFFC000028880000073BF79FFF9FFFF60000FBC00BFFF
...    0000163C03F148200DFFF785FFF5E00F2A6A7000158800000000023007CAA080E0

${ue_eutra_nr_capabilities}    SEPARATOR=
...    BD1BA083058380713000000018062B000060400C1001830030600E260000010300C160801C4C000004060182C000389800000C0C03
...    058100713000002018060B0600E2600000503000100502800C0100282640A00389178A038400040201002004A00020080004040002
...    01000040400020100801002100008040400801080008020200400840004010100200420002008080100210001008040080110000804020040080802002

#counters
${SGNB_DU_NSA_ADMISS_MFBI_REQ}    M55115C01501
${SGNB_DU_NSA_ADMISS_MFBI_SUCC}    M55115C01502

@{BC002}
...    ${SGNB_DU_NSA_ADMISS_MFBI_REQ}=1
...    ${SGNB_DU_NSA_ADMISS_MFBI_SUCC}=1

*** Test Cases ***
5GC001416-ET-BC002_Verify_A2_in_NOT_configured_when_inconsistence_between_NRHOIF_and_UE_capability
    [Documentation]    The purpose of this test case is to
    ...    Verify_A2_in_NOT_configured_when_inconsistence_between_NRHOIF_and_UE_capability
    ...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=78
    ...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
    ...    inconsistence between NRCELL-1/NRHOIF-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
    ...    and NRCELL-1/NRHOIF-1:freqBandIndicatorNR=38
    [Tags]    QC_60798    BC002
    Attach UE Check The Result
    Check Counters    ${BC002}
    Check WireShark Log    ${CURDIR}${/}a2a_BC002${/}a2a.ini    wait_string=BearerContextModificationResponse
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
    ...    gscn=22446 mandatory_for_activation=off mapped_MFBI=41
    ${UE31}    catenate
    ...    set_ue simulated id=31 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    eia=null+snow3g+aes eea=null nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc imsi=250:555:21645411
    Update Cfg    ${GNB4}
    Update Cfg    ${GNB4_CELL1}
    Update Cfg    ${UE31}
    Update Cfg    ue_param id=31 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    Update Cfg    gnb_endc_param id=4 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0



Attach UE Check The Result
    Execute Egate Command    ue_change_location id=31 enb=1 cell=1
    Execute Egate Command    ue_attach id=31    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=31 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    UE31: Proxy \\(eNB 2 cell 1\\) reported successful RA

UE Detach
    Execute Egate Command    ue_detach id=31    UE IS OFF