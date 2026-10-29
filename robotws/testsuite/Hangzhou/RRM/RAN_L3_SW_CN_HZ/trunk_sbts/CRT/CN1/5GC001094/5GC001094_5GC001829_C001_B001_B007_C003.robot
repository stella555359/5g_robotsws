*** Settings ***
Suite Setup        Common Suite Setup And Setup Airphone Env
Suite Teardown     Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup         Common Test Setup And Start To Capture Logs
Test Teardown      Common Test Teardown And Stop Capture Logs
Force Tags         QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...                team-DevHZ5_SG2    owner-keyun.ma   release-SBTS00    5GC001094
Resource           ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{FAULTS_EXCLUDED_CHECKING}    8150
${DEBUG_LOG_LEVEL}    0

${GNB_BIP_FLAG}    True
${GNB1_CONFIG}    tdd_sansa_cmwv/FS/2cells_ecpri
${NREARFCN636666}    636666
${gscnOrSsPbchArfcn}    7880
${freqBandIndicatorNR}    78
${chBw}    100MHz
${ssbScs}    30 KHz
${scs}    30 KHz
@{PARAMS_IN_SCF}
...    NRCELL:cbraPreamblesPerSsb=n64
...    NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=false
...    @{srb3}
...    @{params_to_enable_nsa_ho}
...    @{nrrel_intra_freq_intra_gnb}
...    @{enable_meas}
...    @{intra_freq_inter_gnb}

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

@{params_to_enable_nsa_ho}

...    NRBTS-1:actIntraFreqIntraGnbMobilityNSA=true

@{enable_meas}
...    NRCELL:a3MeasEnabled=rsrpAndRsrq
...    NRCELL:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    NRCELL:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    NRCELL:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRCELL:a5MeasEnabled=rsrq
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=40
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=60
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms40

@{nrrel_intra_freq_intra_gnb}
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

${nr_capability}    SEPARATOR=
...    ED007000479A4BBF5FFFFEF8001BD409A00CFDBFCB98AD7FFBF900001F53FFFFD1000000E77EF3FFF3FFFEC0001F78017FFE00002C7807E2
...    90401BFFEF0BFFEBC00E54D00158800000000023003CAA08

${ue_eutra4}  SEPARATOR=
...    BD1BA063058380713400000018062B000060400C1001830030600E268000010300C160801C4D000006060182C000389A00000C0C030581007
...    13400001018060B0600E26800002030048BC500C2000201008010025700100402008040100802010040200804010080201004020080401008
...    02010040201004020080401008000000402008040000000000040200000000000000004020080401008020100000008040100800000000000
...    8040000000000000000804010080201004020080400000020100402008040000000000000000804000000000000000000001009C002020080
...    40080801010000000404008080000000000040400000000000000004020100401008020100402008040100802010040200804010080201004
...    02008080201002020000000808010100000004040000000000020200000000000101004020040400808000000202004040000000000020200
...    40400000000000202000000000000000020270010080201004020000001008020100000008040000000000040200000000000201004020080
...    40000002010040200000010080000000000080400000000000401008020100402008040100802010040200804010080201004020080401008
...    04010080201000000080401008000000402000000100800000040200000000000201000000000001009C00202004040080801010020200000
...    00808010100202000000000001010000000404008080101002020040400000010100202004040000000000020200000008080101002020040
...    40080800000020200404008080000000000040400000010080201004020080401008020100402008040100802010040200804010080201004
...    02008040100804017001008010100000004040080800000000000000008080000000000000000000020100202000000080801010000000000
...    00000010100000000000000000000040200404000000101002020000000000000000202000000000000000000000804008080000002020040
...    400808000000000004040000001010020200000000000000002020000000809C40080180100300200600400C0080180100300200600400C00
...    80180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C
...    0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C008018010030020060040
...    0C0080180100300200600400C0080180100300200600400C008010800040202004008400040101002004

*** Test Cases ***
5GC001094_C_001 HRL is introduced
    [Documentation]
    ...    Case: Verify HRL changed not affect UE call
    [Tags]    QC_200382    owner=keyun.ma    CxT
    start to capture wireshark log    HRL
    Change PLMN parameter for HRL
    Ue Attach To Cell and send traffic
    Check WireShark Log     ${CURDIR}${/}a2a_case_HO_pass${/}HRL.ini    name=HRL    wait_string=SNStatusTransfer
	Release Ues    ue_type=nsa    ue_id=31

5GC001094-5GC001829-ET_B001_B007_C003 Verify classical-NSA-TDD-cmWave-intra_DU handover with SRB3 CBRA and Blacklisting
    [Documentation]
    ...    Case: Verify three things: 1. handover successfully, with A5-RSRQ-SRB3-CBRA and A3-RSRP and RSRQ-SRB3-CBRA
    ...    2. L3 call is not impacted with SRB3 if measurment_report is empty based on A5 RSRP
    ...    3. Blacklisting with initial configuration WITH SRB3
    ...    Step: Condition for mobily-->trigger HO with A5-RSRQ-SRB3-CBRA-->HO ok
    ...    -->trigger HO with A3-RSRP and RSRQ-SRB3-CBRA-->HO ok
    ...    -->trigger HO with empty measurment report based on A5-RSRP -->HO failed while call is goning on source cell
    [Tags]    QC_200378    owner=keyun.ma    B001     CRT
    Ue Attach To Cell and send traffic
    Handover succeed with A5-RSRQ-SRB3-CBRA
    Handover succeed with A3-RSRP and RSRQ-SRB3-CBRA
    Handover failed with empty measurment report based on A5-RSRP
    Handover failed with Blacklisting with initial configuration
	Release Ues    ue_type=nsa    ue_id=31

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}

Modify Cfg
    ${V1}    catenate
    ...    ue_param id=31 ue_nr_capabilities=${nr_capability}  dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra4}
    Update Cfg    ${V1}
    ${set_gnb3}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1 plmnList=311:489
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb3}
    Update Cfg    ${set_gnb3_cell1}

Ue Attach To Cell and send traffic
    Set x2 gnb link up
    start to capture wireshark log    UEs_L3_Call
    UE Attach and establish EN-DC    31    1
    Send And Verify Throuput
    Check WireShark Log     ${CURDIR}${/}a2a_case_HO_pass${/}UEs_L3_Call.ini    name=UEs_L3_Call    wait_string=SNStatusTransfer

Change PLMN parameter for HRL
    ${params}     create list    NRCELL-1/NRREL-1:gnbPlmn:mcc=262
    ...    NRCELL-1/NRREL-1:gnbPlmn:mnc=3
    ...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=2
    ...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=262
    ...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=3
    ...    NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=2
    Delta Commission Parameters    ${params}

Handover succeed with A5-RSRQ-SRB3-CBRA
    start to capture wireshark log    HO_A5_RSRQ_SRB3_CBRA
    report intra A3 A5 and trigger cell1 handover to cell2    31    636576    A5
    report intra A3 A5 and trigger cell2 handover to cell1    31    636576    A5
    check wireshark log    ${CURDIR}/a2a_case_HO_pass/HO_A5_RSRQ_SRB3_CBRA.ini    name=HO_A5_RSRQ_SRB3_CBRA    wait_string=SgNBModificationConfirm::2

Handover succeed with A3-RSRP and RSRQ-SRB3-CBRA
    start to capture wireshark log    HO_A3_SRB3_CBRA
    report intra A3 A5 and trigger cell1 handover to cell2    31    636576    A3
    report intra A3 A5 and trigger cell2 handover to cell1    31    636576    A3
    check wireshark log    ${CURDIR}/a2a_case_HO_pass/HO_A3_SRB3_CBRA.ini    name=HO_A3_SRB3_CBRA    wait_string=SgNBModificationConfirm::4

Handover failed with empty measurment report based on A5-RSRP
    [Arguments]    ${ueid}=31    ${cafreq}=636576    ${phyid}=382
    start to capture wireshark log    HO_A5_without_MR_CBRA
    Delta Commission Parameters    NRCELL:a5MeasEnabled=rsrq
    ${mid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ueid}    carrierfreq=${cafreq}    event_type=A5
    ${V2}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${mid} event=A5
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${phyid} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${V2}    physCellId 382
    check wireshark log    ${CURDIR}/a2a_case_HO_pass/HO_A5_without_MR_CBRA.ini    name=HO_A5_without_MR_CBRA    wait_string=ULRRCMessageTransfer

Handover failed with Blacklisting with initial configuration
    [Arguments]    ${ueid}=31    ${cafreq}=636576    ${phyid}=51
    start to capture wireshark log    HO_with_Blacklisting
    ${params}     create list    NRCELL-1:pciExcludeList:pciRangeValidity=NSA
    ...    NRCELL-1:pciExcludeList:physCellId=51
    ...    NRCELL-1:pciExcludeList:range=n8
    Delta Commission Parameters    ${params}
    ${mid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ueid}    carrierfreq=${cafreq}    event_type=A5
    ${V2}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${mid} event=A5
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${phyid} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${V2}    physCellId 51
    check wireshark log    ${CURDIR}/a2a_case_HO_pass/HO_with_Blacklisting.ini    name=HO_with_Blacklisting    wait_string=ULRRCMessageTransfer

Set x2 gnb link up
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2

report intra A3 A5 and trigger cell1 handover to cell2
    [Arguments]    ${ue_id}=31    ${cafreq}=633216    ${event}=A3
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ueid}    carrierfreq=${cafreq}
    ...    event_type=${event}
    ${V2}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event}
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${V2}    UE31: Sending SgNB Modification Confirm
    Verify Throuput

report intra A3 A5 and trigger cell2 handover to cell1
    [Arguments]    ${ue_id}=31    ${cafreq}=633216    ${event}=A3
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ueid}    carrierfreq=${cafreq}
    ...    event_type=${event}
    ${V1}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event}
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${V1}    UE31: Sending SgNB Modification Confirm
    Verify Throuput

UE Attach and establish EN-DC
    [Arguments]    ${ue_id}=31    ${target_cell}=1   ${ue_nr_capabilities}=${nr_capability}
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cell} bearer=2 type=split_scg
    ...    Proxy \\(eNB 2 cell 1\\) reported successful RA
Send And Verify Throuput
    [Arguments]    ${ue_id}=31
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=5    UE ${ue_id}: UDP UL
    Verify Throuput

Verify Throuput
    [Arguments]    ${sleep_time}=10s    ${ue_id}=31
    sleep    ${sleep_time}
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.6
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.6
