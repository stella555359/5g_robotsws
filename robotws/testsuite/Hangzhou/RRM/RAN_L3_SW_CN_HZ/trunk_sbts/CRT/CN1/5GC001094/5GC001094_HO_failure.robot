*** Settings ***
Suite Setup        Common Suite Setup And Setup Airphone Env
Suite Teardown     Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup         Common Test Setup And Start To Capture Logs
Test Teardown      Common Test Teardown And Stop Capture Logs
Force Tags         QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...                team-DevHZ5_SG2    owner-keyun.ma   release-SBTS00    5GC001094
Resource           ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRCELL:cbraPreamblesPerSsb=n64
...    NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=false
...    @{srb3}
...    @{params_to_enable_nsa_ho}
...    @{nrrel_intra_freq_intra_gnb}
...    @{enable_meas}

${GNB1_CONFIG}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SWCONFIG}
...    ${ERadCcs_AaSysLogOutputMode}=5
...    ${ERadCcs_AaSysLogOutputLevel}=1
...    ${ERadCcs_AaSysLogInputLevel}=1
...    ${BSTAT_PM_debug_prints}=1
...    ${BSTAT_print_pm_detail}=55120

${ERadCcs_AaSysLogOutputMode}    0x10041
${ERadCcs_AaSysLogOutputLevel}    0x10040
${ERadCcs_AaSysLogInputLevel}    0x1003F
${BSTAT_PM_debug_prints}    0x340003
${BSTAT_print_pm_detail}    0x34000E

@{srb3}
...    NRBTS:srb3SupportEnabled=false
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
...    NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL-1:gNbId=1
...    NRBTS-1/NRCELL-1/NRREL-1:gNbIdLength=22
...    NRBTS-1/NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRBTS-1/NRCELL-1/NRREL-1:lcrId=2
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRBTS-1/NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRBTS-1/NRCELL-2/NRREL-1:gNbId=1
...    NRBTS-1/NRCELL-2/NRREL-1:gNbIdLength=22
...    NRBTS-1/NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRBTS-1/NRCELL-2/NRREL-1:lcrId=1
...    NRBTS-1/NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

${nr_capability}    SEPARATOR=
...    ED007000479A4BBF5FFFFEF8001BD409A00CFDBFCB98AD7FFBF900001F53FFFFD1000000E77EF3FFF3FFFEC0001F78017FFE00002C7807E2
...    90401BFFEF0BFFEBC00E54D00158800000000023003CAA08

${ue_eutra4}    SEPARATOR=
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

@{PM_Counters_Check_HO_failed}
...    ${INTRA_DU_HO_FAI_MENB_REF}=1
...    ${INTRA_DU_HO_FAI_TDC_EXP}=2
...    ${INTRA_DU_HO_FAI_T304_EXP_NSA}=1

@{change_a3Meas}
...    NRCELL:a3MeasEnabled=rsrp
...    NRBTS:tDCoverall=1000

@{change_t304_time}
...    NRBTS:t304=ms1000
...    NRBTS:tDCoverall=5000
...    NRBTS:timerX2UeProcGuard=5000

@{change_disablesrb3_NSARAtime}
...    NRBTS:srb3SupportEnabled=false
...    NRBTS:timerNSAGuardRA=5000
...    NRBTS:timerRRCGuard=6000
...    NRBTS:timerHOGuard=6000
...    NRBTS:tDCoverall=10000
...    NRBTS:timerX2UeProcGuard=10000

@{restore_timer}
...    NRBTS:srb3SupportEnabled=false
...    NRBTS:timerNSAGuardRA=5000
...    NRBTS:timerRRCGuard=2500
...    NRBTS:timerHOGuard=2500

${INTRA_DU_HO_FAI_TDC_EXP}             M55120C01003
${INTRA_DU_HO_FAI_MENB_REF}            M55120C01004
${INTRA_DU_HO_FAI_T304_EXP_NSA}        M55120C01006

*** Test Cases ***
5GC001094_E_Classical_NSA_TDD_cmWave_Intrafreq_IntraDU_unsuccessful_PSCell_change_due_to_MeNB_refusal_or_TDCOverall_or_T304expiry
    [Documentation]
    ...    Case: This case will include feature 5GC001094-E three scenarios:
    ...    To verify Classical NSA TDD cmWave - intra-frequency intra-gNB HO with A3 RSRP CBRA
    ...    non SRB3 failed by TDCOverall expiry
    ...    To verify Classical NSA TDD cmWave - intra-frequency intra-gNB HO with A3 RSRP CBRA
    ...    non SRB3 failed by MeNB refusal
    ...    To verify Classical NSA TDD cmWave - intra-frequency intra-gNB HO with A3 RSRP CBRA with SRB3
    ...    failed by T304 expiry
    ...    check counters: M55120C01003 (INTRA_DU_HO_FAI_TDC_EXP)
    ...                    M55120C01004 (INTRA_DU_HO_FAI_MENB_REF)
    ...                    M55120C01006 (INTRA_DU_HO_FAI_T304_EXP_NSA)
    [Tags]    QC_46877
    Clear Counter Files
    Ue Attach To Cell and send traffic
    Handover failed due to TDCoverall expiry based on A3-RSRP
    Ue Attach To Cell and send traffic
    Handover failed due to MeNB refusal based on A3-RSRP
	Change SRB3 to enable
    Ue Attach To Cell and send traffic
    Handover failed due to T304 expiry based on A3-RSRP
    #add test steps after EDA of PR03746926
    Change SRB3 to disable
    Ue Attach To Cell and send traffic    ueid=32
    Handover normal PScell change based on A3-RSRP    ueid=32    pass_info=UE32: Sending SgNB Modification Confirm
    Ue Attach To Cell and send traffic    ueid=33
    Handover failed due to TDCoverall expiry with tDCoverall larger then timerNSAGuardRA
    check wireshark log    ${CURDIR}/a2a_case_HO_Failed/a2a_wireshark.ini    wait_string=SNStatusTransfer::18
    Check Counters    ${PM_Counters_Check_HO_failed}
	[Teardown]    Test teardown for restore

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}

Test teardown for restore
    Delta Commission Parameters    ${restore_timer}
    Common Test Teardown And Stop Capture Logs

Handover normal PScell change based on A3-RSRP
    [Arguments]    ${ueid}=31    ${cafreq}=636576    ${phyid}=51
    ...    ${pass_info}=Bearer-type change from SCG-split to MCG is successful
    ${mid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ueid}    carrierfreq=${cafreq}    event_type=A3
    ${V2}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${mid} event=A3
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${phyid} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${V2}    pass_regexp=${pass_info}
    sleep    10s

Change SRB3 to disable
    Delta Commission Parameters    ${change_disablesrb3_NSARAtime}

Handover failed due to TDCoverall expiry with tDCoverall larger then timerNSAGuardRA
    Execute Egate Command    ue_rrc_reconf_param id=33 reset
    sleep    2s
    Execute Egate Command    ue_rrc_reconf_param id=33 if_contains=reconfiguration_with_sync delay=11000 action=none
    Handover normal PScell change based on A3-RSRP    ueid=33

Modify Cfg
    ${V1}    catenate
    ...    ue_param id=31 ue_nr_capabilities=${nr_capability}  dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra4}
    Update Cfg    ${V1}

Ue Attach To Cell and send traffic
    [Arguments]    ${ueid}=31    ${gnb_cell}=1
    Set x2 gnb link up
    Execute Egate Command    link_x2_management_abnormal_cases id=1 partner=2 reset
    UE Attach and establish EN-DC    ue_id=${ueid}    target_cell=${gnb_cell}
    Send And Verify Throuput    ue_id=${ueid}

Handover failed due to MeNB refusal based on A3-RSRP
    [Arguments]    ${ueid}=31    ${cafreq}=636576    ${phyid}=51
    Delta Commission Parameters    NRBTS:tDCoverall=5000
    ${V1}    catenate
    ...    link_x2_management_abnormal_cases id=1 partner=2 sgnb_modification_reqd_rsp=refuse
    ...    sgnb_modification_reqd_cause=TRANSPORT_transport_resource_unavailable
    Execute Egate Command    ${V1}
    ${mid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ueid}    carrierfreq=${cafreq}    event_type=A3
    ${V2}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${mid} event=A3
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${phyid} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${V2}    pass_regexp=Bearer-type change from SCG-split to MCG is successful
    Release Ues    ue_type=nsa    ue_id=31

Handover failed due to TDCoverall expiry based on A3-RSRP
    [Arguments]    ${ueid}=31    ${cafreq}=636576    ${phyid}=51
    Delta Commission Parameters    ${change_a3Meas}
    ${V1}    catenate
    ...    link_x2_management_abnormal_cases id=1 partner=2 sgnb_modification_reqd_rsp=no_rsp
    Execute Egate Command    ${V1}
    ${mid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ueid}    carrierfreq=${cafreq}    event_type=A3
    ${V2}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${mid} event=A3
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${phyid} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${V2}    pass_regexp=Bearer-type change from SCG-split to MCG is successful
    Release Ues    ue_type=nsa    ue_id=31

Change SRB3 to enable
    Delta Commission Parameters    NRBTS:srb3SupportEnabled=true

Handover failed due to T304 expiry based on A3-RSRP
    [Arguments]    ${ueid}=31    ${cafreq}=636576    ${phyid}=51
	Delta Commission Parameters    ${change_t304_time}
    Execute Egate Command    enb_timer T_DC_Prep=5s
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ueid} if_contains=any action=scg_failure
    ${mid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ueid}    carrierfreq=${cafreq}    event_type=A3
    ${V2}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${mid} event=A3
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${phyid} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${V2}    pass_regexp=Bearer-type change from SCG-split to MCG is successful
	Release Ues    ue_type=nsa    ue_id=31

Set x2 gnb link up
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2

UE Attach and establish EN-DC
    [Arguments]    ${ue_id}=31    ${target_cell}=1   ${ue_nr_capabilities}=${nr_capability}
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cell} bearer=2 type=split_scg
    ...    Proxy \\(eNB 2 cell 1\\) reported successful RA
Send And Verify Throuput
    [Arguments]    ${ue_id}=31
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=5    UE ${ue_id}: UDP UL
    Verify Throuput    ue_id=${ue_id}

Verify Throuput
    [Arguments]    ${sleep_time}=10s    ${ue_id}=31
    sleep    ${sleep_time}
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.6
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.6
