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
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
...    NRBTS:srb3SupportEnabled=true
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    delete:NRBTS:cipherPrefL:nea0=7|nea3_128=0
...    delete:NRBTS:cipherPrefL:nea1_128=0|nea3_128=0
...    delete:NRBTS:cipherPrefL:nea2_128=0|nea3_128=0

@{NRREL}
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:fiveGsTac=0
...    NRADJNRCELL-1:freqBandIndicatorNR=78
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    NRADJNRCELL-1:nrarfcn=636666
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-2:cellDepType=NSA
...    NRADJNRCELL-2:fiveGsTac=0
...    NRADJNRCELL-2:freqBandIndicatorNR=${EMPTY}
...    NRADJNRCELL-2:gNbId=31
...    NRADJNRCELL-2:gNbIdLength=22
...    NRADJNRCELL-2:lcrId=1
...    NRADJNRCELL-2:nrarfcn=636666
...    NRADJNRCELL-2:physCellId=383
...    NRADJNRCELL-2:gnbPlmn:mnc=489|mncLength=3
...    NRADJNRCELL-2:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=35
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-1:removeNotAllowed=true
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489|mncLength=3
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=31
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=1
...    NRCELL-1/NRREL-2:removeNotAllowed=true
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489|mncLength=3
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311|mncLength=3

@{set_srb3_and_nea}
...    NRBTS:srb3SupportEnabled=true
...    NRBTS:cipherPrefL:nea0=7|nea3_128=0
...    NRBTS:cipherPrefL:nea1_128=0|nea3_128=0
...    NRBTS:cipherPrefL:nea2_128=0|nea3_128=0

@{disable_srb3_and_delte_nea}
...    NRBTS:srb3SupportEnabled=false
...    delete:NRBTS:cipherPrefL:nea0=7|nea3_128=0
...    delete:NRBTS:cipherPrefL:nea1_128=0|nea3_128=0
...    delete:NRBTS:cipherPrefL:nea2_128=0|nea3_128=0

#UE31 CAPE
${ue1_nr_capabilities}    SEPARATOR=
...    ED007000479A4BBF5FFFFEF8005BD409800CFDBFCB98AD7FFBF900001F53FFFFC000100880000073BF79FFF9FFFF60000FBC00BFFF0000163C03F14820
...    0DFFF785FFF5E00F2A6A7000158800000000023007CAA080E0

${ue1_eutra_nr_capabilities}    SEPARATOR=
...    BD1BA083058380713000000018062B000060400C1001830030600E260000010300C160801C4C000004060182C000389800000C0C030581007130000020
...    18060B0600E2600000503000100510000C0100282644000389178A038400040201002004A0002010000804000201000080400020100801002100008040
...    400801080008020200400840004010100200420002008080100210001008040080110000804020040080801002

#UE32 CAPE
${ue2_nr_capabilities}    SEPARATOR=
...    6100000004418004000000C48010000260000134040182641340066FFFFF1BC02400000000000000014000000120122A13822A00280000000000006000
...    00240202A0740A80

${ue2_eutra_nr_capabilities}    SEPARATOR=
...    BD1BA063058100713000000018062B000060400C1001830030600E268000010300C160801C4D000006060182C000389A00000C0C030581007134000010
...    18060B0600E26800002030048BC500C2000201008030065700100402008040100802010040200804010080201004020080401008020100402010040200
...    80401008000000402008040000000000040200000000000000004020080401008020100000008040100800000000000804000000000000000080401008
...    0201004020080400000020100402008040000000000000000804000000000000000000001009C002020080400808010100000004040080800000000000
...    40400000000000000004020100401008020100402008040100802010040200804010080201004020080802010020200000008080101000000040400000
...    00000020200000000000101004020040400808000000202004040000000000020200404000000000002020000000000000000202700100802010040200
...    00001008020100000008040000000000040200000000000201004020080400000020100402000000100800000000000804000000000004010080201004
...    02008040100802010040200804010080201004020080401008040100802010000000804010080000004020000001008000000402000000000002010000
...    00000001009C00202004040080801010020200000008080101002020000000000010100000004040080801010020200404000000101002020040400000
...    00000020200000008080101002020040400808000000202004040080800000000000404000000100802010040200804010080201004020080401008020
...    10040200804010080201004020080401008040170010080101000000040400808000000000000000080800000000000000000000201002020000000808
...    01010000000000000000101000000000000000000000402004040000001010020200000000000000002020000000000000000000008040080800000020
...    20040400808000000000004040000001010020200000000000000002020000000809C40080180100300200600400C0080180100300200600400C008018
...    0100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300
...    200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C00801801003002006004
...    00C0080180100300200600400C008010800040202004008400040101002004

#UE33 CAPE
${ue3_nr_capabilities}    SEPARATOR=
...    6100000004418004000000C48010000260000134040182641340066FFFFF1BC02400000002000000014000000100122A13822A00280000010000006000
...    00200202A0740A80

#conunters
${SGNB_NSA_HO_ADMISS_MFBI_REQ}    M55114C00503
${SGNB_NSA_HO_ADMISS_MFBI_SUCC}    M55114C00504
${SGNB_NSA_ADMISSION_MFBI_REQ}    M55114C00501
${SGNB_NSA_ADMISSION_MFBI_SUCC}    M55114C00502
${SGNB_NSA_ADMISSION_REQ}    M55114C00001
${SGNB_NSA_ADMISSION_SUCC}    M55114C00002

@{BB0010}
...    ${SGNB_NSA_HO_ADMISS_MFBI_REQ}=1
...    ${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=1

@{BB0012_1}
...    ${SGNB_NSA_HO_ADMISS_MFBI_REQ}=1
...    ${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=1
...    ${SGNB_NSA_ADMISSION_MFBI_REQ}=1
...    ${SGNB_NSA_ADMISSION_MFBI_SUCC}=1
...    ${SGNB_NSA_ADMISSION_REQ}=1
...    ${SGNB_NSA_ADMISSION_SUCC}=1

@{BB0012_2}
...    ${SGNB_NSA_HO_ADMISS_MFBI_REQ}=1
...    ${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=1
...    ${SGNB_NSA_ADMISSION_MFBI_REQ}=1
...    ${SGNB_NSA_ADMISSION_MFBI_SUCC}=1
...    ${SGNB_NSA_ADMISSION_REQ}=2
...    ${SGNB_NSA_ADMISSION_SUCC}=2

*** Test Cases ***
5GC001416-ET-BB010_Verify_Successful_Intra-MeNB_Inter-SgNB_handover_for_UE_using_alternative_bands_with_SRB3
    [Tags]    QC_47215    BB010
    Set SRB3 And Nea
    Start X2 Link And Check Egate Console freqBandIndicatorNr
    Attach UE Check The Result
    Trigger HO From GNB2 With Two Sim GNBs And Select GNB3 HO succeeds
    Check WireShark Part1 And Start Next Wireshark Capture
    Trigger HO From GNB3 to GNB2
    Check WireShark Log    ${CURDIR}${/}a2a_BB0010${/}a2a2.ini    name=HO    wait_string=UEContextRelease::2
    Check Counters    ${BB0010}
    UE Detach And Disable SRB3 And Delte Nea

5GC001416-ET-BB012_Verify_successful_IntraMeNB_InterSgNB_HO_UE_using_alternative_bands_without_SRB3_when_1_of_2_target_gNBs_NOT_support_MFBI
    [Tags]    QC_47216    BB012
    Start X2 Link And Check Egate Console freqBandIndicatorNr
    Attach UE Check The Result And Check The Traffic    UEID=32
    Trigger HO From GNB2 With Two Sim GNBs And Select GNB3 HO succeeds And Check Wireshark    UEID=32
    Start Next Wireshark Capture And Trigger HO From GNB3 to GNB2    tag_id=32HO    ue_id=32
    Check Counters And Check Wireshark And Detach UE    counter_tag=${BB0012_1}    tag=32HO    UEID=32
    Start Next Wireshark
    Attach UE Check The Result And Check The Traffic    UEID=33
    Trigger HO From GNB2 With Two Sim GNBs And Select GNB3 HO succeeds And Check Wireshark    UEID=33    tag=33Attach
    Start Next Wireshark Capture And Trigger HO From GNB3 to GNB2    tag_id=33HO    ue_id=33
    Check Counters And Check Wireshark And Detach UE    counter_tag=${BB0012_2}    tag=33HO    UEID=33


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${GNB4}    catenate
    ...    set_gnb id=4 s1u=10.0.1.128 plmn=311:489 gnb_id=0x1F type=simulated daemon=:22222 x2=10.0.1.128:36422
    ${GNB4_CELL1}    catenate
    ...    set_cell id=1 gnb=4 pci=127:2 tac=3 nrci=0xB tdd_cell=on proxy=10.0.2.90:22224 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    ${GNB3}    catenate
    ...    set_gnb id=3 s1u=10.0.1.126 plmn=311:489 gnb_id=0x23:22 type=simulated daemon=:22222 x2=10.0.1.126:36422
    ${GNB3_CELL1}    catenate
    ...    set_cell id=1 gnb=3 pci=127:0 tac=3 nrci=0x01 tdd_cell=on proxy=10.0.2.91:22224 nr_arfcn=636666:636666
    ...    gscn=7880 mapped_MFBI=77 mandatory_for_activation=off
    ${UE31}    catenate
    ...    set_ue simulated id=31 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    eia=null+snow3g+aes eea=null nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc imsi=250:555:21645411
    ${UE32}    catenate
    ...    set_ue simulated id=32 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    eia=null+snow3g+aes eea=null nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc imsi=250:555:21645412
    ${UE33}    catenate
    ...    set_ue simulated id=33 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    eia=null+snow3g+aes eea=null nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc imsi=250:555:21645413
    Update Cfg    ${GNB4}
    Update Cfg    ${GNB4_CELL1}
    Update Cfg    ${GNB3}
    Update Cfg    ${GNB3_CELL1}
    Update Cfg    ${UE31}
    Update Cfg    ${UE32}
    Update Cfg    ${UE33}
    Update Cfg    gnb_endc_param id=3 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0
    Update Cfg    gnb_endc_param id=4 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0
    Update Cfg    ue_param id=31 ue_nr_capabilities=${ue1_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue1_eutra_nr_capabilities}
    Update Cfg    ue_param id=32 ue_nr_capabilities=${ue2_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue2_eutra_nr_capabilities}
    Update Cfg    ue_param id=33 ue_nr_capabilities=${ue3_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue2_eutra_nr_capabilities}
    Update Cfg    set_bearer id=2 ue=31 qci=9 pdn=1 ip=4.7.254.221 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=32 qci=9 pdn=1 ip=4.7.254.236 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=33 qci=9 pdn=1 ip=4.7.254.237 default=on trf_type=internal

Set SRB3 And Nea
    delta commission parameters    ${set_srb3_and_nea}

Start X2 Link And Check Egate Console freqBandIndicatorNr
    ${Trigger_ENDC_X2}    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2    timeout=60    sleep_time=5
    Execute Egate Command    enb_x2_link_up enb=1 target=3    ENB-1: X2AP Link with GNB-3    timeout=60    sleep_time=5
    Execute Egate Command    enb_x2_link_up enb=1 target=4    ENB-1: X2AP Link with GNB-4    timeout=60    sleep_time=5
    Should Contain    ${Trigger_ENDC_X2}    freqBandIndicatorNr 78
    clear counter files

Attach UE Check The Result
    Execute Egate Command    ue_change_location id=31 enb=1 cell=1
    Execute Egate Command    ue_attach id=31    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=31 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    UE31: Proxy \\(eNB 2 cell 1\\) reported successful RA

Attach UE Check The Result And Check The Traffic
    [Arguments]    ${UEID}=32
    Execute Egate Command    ue_change_location id=31 enb=1 cell=1
    Execute Egate Command    ue_attach id=${UEID}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${UEID} target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    UE${UEID}: Proxy \\(eNB 2 cell 1\\) reported successful RA

Trigger HO From GNB2 With Two Sim GNBs And Select GNB3 HO succeeds
    [Arguments]    ${UEID}=31
    ${MR_INFO}    catenate
    ...    phycell_id=381 nrsrp_nr=31 nrsrq_nr=31 phycell_id=382 nrsrp_nr=31 nrsrq_nr=31
    Execute Egate Command    ue_measurement_send_nr id=${UEID} meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 ${MR_INFO}
    ...    pass_regexp=Bearer-type change from MCG to SCG-split is successful

Trigger HO From GNB2 With Two Sim GNBs And Select GNB3 HO succeeds And Check Wireshark
    [Arguments]    ${UEID}=31    ${tag}=${empty}
    ${MR_INFO}    catenate
    ...    phycell_id=381 nrsrp_nr=31 nrsrq_nr=31 phycell_id=382 nrsrp_nr=31 nrsrq_nr=31
    Execute Egate Command    ue_measurement_send_nr id=${UEID} meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 ${MR_INFO}
    ...    pass_regexp=reported successful RA
    Check WireShark Log    ${CURDIR}${/}a2a_BB0012${/}a2a${tag}.ini    name=${tag}    wait_string=UEContextRelease::2

Check WireShark Part1 And Start Next Wireshark Capture
    Check WireShark Log    ${CURDIR}${/}a2a_BB0010${/}a2a1.ini    wait_string=UEContextRelease::2
    Start To Capture Wireshark Log    tag=HO

Trigger HO From GNB3 to GNB2
    [Arguments]    ${UEID}=31
    Execute Egate Command    dc_gnb_ue_change ue=${UEID} gnb=2 target_sgnb_cells=1 cause=RN_sCG_Mobility
    ...    pass_regexp=Inter Sgnb Handover is successful

Start Next Wireshark Capture And Trigger HO From GNB3 to GNB2
    [Arguments]    ${tag_id}=32HO    ${ue_id}=32
    Start To Capture Wireshark Log    tag=${tag_id}
    Trigger HO From GNB3 to GNB2    UEID=${ue_id}

UE Detach
    [Arguments]    ${UEID}=31-33
    Execute Egate Command    ue_detach id=${UEID}    UE IS OFF

Disable SRB3 And Delte Nea
    delta commission parameters    ${disable_srb3_and_delte_nea}

UE Detach And Disable SRB3 And Delte Nea
    UE Detach    UEID=31
    Disable SRB3 And Delte Nea

Start Next Wireshark
    Start To Capture Wireshark Log    tag=33Attach

Check Counters And Check Wireshark And Detach UE
    [Arguments]    ${counter_tag}=${BB0012_1}    ${tag}=32HO    ${UEID}=32
    check counters    ${counter_tag}
    check wireshark log    ${CURDIR}${/}a2a_BB0012${/}a2a${tag}.ini    name=${tag}    wait_string=UEContextRelease::2
    UE Detach    UEID=${UEID}