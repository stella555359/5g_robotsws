*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CIT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-DevHZ5_SG2    owner-yili.chen    release-5G20A     5GC001416    CDRT
Resource  ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}    @{addnrconnect0}

@{addnrconnect0}
...    NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=true
...    NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0

@{PARAMS_IN_SWCONFIG}
...  0x59004D=1    #disableCallRejectionOnInvalidUeCapaRadParam) to disable CNI-48216 : Call rejection in case of invalid UE Capabilities

@{PM_Counters_Check_UE54}
...    NRCELL-1:${SGNB_NSA_ADMISSION_REQ}=1
...    NRCELL-1:${SGNB_NSA_ADMISSION_SUCC}=1
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_REQ}=1
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_SUCC}=1

@{PM_Counters_Check_UE53}
...    NRCELL-1:${SGNB_NSA_ADMISSION_REQ}=1
...    NRCELL-1:${SGNB_NSA_ADMISSION_SUCC}=1
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_REQ}=0
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_SUCC}=0

${ue53_nr_capabilities}    SEPARATOR=
...    ED007000479A4BBF5FFFFEF8005BD409A00CFDBFCB98AD7FFBF900001F53FFFFC00004C88
...    0000073BF79FFF9FFFF60000FBC00BFFF0000163C03F148200DFFF785FFF5E00F2A6A7000158800000000023007CAA080E0
${ue53_eutra_nr_capabilities}    SEPARATOR=
...    BD1BA083058380713400000018062B000060400C1001830030600E2680000
...    10300C160801C4D000004060182C000389A00000C0C03058100713400002018060B0600E2680000503000100504C00C01002826C1
...    300389178A038400040201002004A0000000000000000000000000000000000800000100008040400801080008020200400800804
...    0180100200201006004008400000001000000400000000800000020000000

${ue54_nr_capabilities}    SEPARATOR=
...    6100000004418004000000C48010000260000410040182644100066FFFFF1BC0100
...    0000000000000040145427000400000000000040102A074

${ue54_eutra_nr_capabilities}    SEPARATOR=
...    BD1BA063058380713000000018062B000060400C1001830030600E260000010300C160801C4C000006060182C000389800000C0C0
...    3058100713000001018060B0600E260000020300C9BCD00C2000201008010025700100402008040100802010040200804010080201004020
...    0804010080201004020100402008040100800000040200804000000000004020000000000000000402008040100802010000000804010080
...    0000000000804000000000000000080401008020100402008040000002010040200804000000000000000080400000000000000000000100
...    9C00202008040080801010000000404008080000000000040400000000000000004020100401008020100402008040100802010040200804
...    0100802010040200808020100202000000080801010000000404000000000002020000000000010100402004040080800000020200404000
...    0000000020200404000000000002020000000000000000202700100802010040200000010080201000000080400000000000402000000000
...    0020100402008040000002010040200000010080000000000080400000000000401008020100402008040100802010040200804010080201
...    00402008040100804010080201000000080401008000000402000000100800000040200000000000201000000000001009C0020200404008
...    0801010020200000008080101002020000000000010100000004040080801010020200404000000101002020040400000000000202000000
...    0808010100202004040080800000020200404008080000000000040400000010080201004020080401008020100402008040100802010040
...    2008040100802010040200804010080401700100801010000000404008080000000000000000808000000000000000000002010020200000
...    0080801010000000000000000101000000000000000000000402004040000001010020200000000000000002020000000000000000000008
...    04008080000002020040400808000000000004040000001010020200000000000000002020000000809C40080180100300200600400C0080
...    180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0
...    080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C008018010030020060040
...    0C0080180100300200600400C0080180100300200600400C0080180100300200600400C008010800040202004008400040101002004



${SGNB_NSA_ADMISSION_REQ}    M55114C00001    #The number of radio admission requests for NSA user
${SGNB_NSA_ADMISSION_SUCC}    M55114C00002    #	The number of radio admitted UEs for NSA user
${SGNB_NSA_ADMISSION_MFBI_REQ}    M55114C00501    #Number of NSA user radio admission requests where request is on the alternative band
${SGNB_NSA_ADMISSION_MFBI_SUCC}    M55114C00502    #Number of NSA user admitted where radio admission is done on the alternative band

*** Test Cases ***
5GSW-CP-CIT012_Verify_Classical_NSA_TDD_cmWave_L3_call_setup_with_MFBI_is_successful
    [Documentation]    The purpose of this test case is to
    ...    1.Verify native band and alternave band will be send to enb in X2SetupResponse
    ...    2.Verify addition successfully when UE supported alternative band on gNB and the alternative band will be selected.
    ...    3.Verify addition successfully when UE supported both native band and alternative band on gNB,the native band will be selected.
    ...    4.Counters during the procedures
    [Tags]    QC_61703
    Attach UE check the result and check the traffic    ue_id=54
    Check Counters    ${PM_Counters_Check_UE54}
    Attach UE check the result and check the traffic    ue_id=53
    Check Counters    ${PM_Counters_Check_UE53}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    ${set_ue53}    catenate    set_ue simulated id=53 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    eia=null+snow3g+aes eea=null nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc imsi=250:555:21645422
    Update Cfg    ${set_ue53}
    ${set_ue54}    catenate    set_ue simulated id=54 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    eia=null+snow3g+aes eea=null nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc imsi=250:555:21645423
    Update Cfg    ${set_ue54}
    ${set_ue53_capability}    catenate
    ...    ue_param id=53 ue_nr_capabilities=${ue53_nr_capabilities}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue53_eutra_nr_capabilities}
    Update Cfg    ${set_ue53_capability}
    ${set_ue54_capability}    catenate
    ...    ue_param id=54 ue_nr_capabilities=${ue54_nr_capabilities}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue54_eutra_nr_capabilities}
    Update Cfg    ${set_ue54_capability}
    Update Cfg    set_bearer id=2 ue=53 qci=9 pdn=1 ip=4.7.254.230 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=54 qci=9 pdn=1 ip=4.7.254.231 default=on trf_type=internal

Attach UE check the result and check the traffic
    [Arguments]   ${ue_id}    ${target_cells}=1
    Clear Counter files
    Start To Capture Wireshark Log     pcap_UE${ue_id}
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    successful RA    timeout=20s
    traffic should be ok    ue_id=${ue_id}    type=NSA
    Check Wireshark Log    ${CURDIR}/a2a_cit012/a2a_${ue_id}.ini    name=pcap_UE${ue_id}    wait_string=SNStatusTransfer::2
