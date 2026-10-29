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
...    @{NRCELL1}
...    @{NRCELL2}

@{5GC001416}
...    NRBTS/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=48
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS:srb3SupportEnabled=false
...    NRBTS:cipherPrefL:nea0=7|nea3_128=0
...    NRBTS:cipherPrefL:nea1_128=0|nea3_128=0
...    NRBTS:cipherPrefL:nea2_128=0|nea3_128=0

@{NRCELL1}
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRCELL-1:nrarfcn=650000
...    NRCELL-1:gscnOrSsPbchArfcn=8019
...    NRCELL-1:rlpDetCsiBsiThreshold=75
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-1/NRHOIF-1:scs=30 KHz
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-1/NRHOIF-1:ssbFrequency=641664
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

@{NRCELL2}
...    NRCELL-2:a1MeashoEnabled=rsrp
...    NRCELL-2:a2MeashoEnabled=rsrp
...    NRCELL-2:actPrachMultiplexing=false
...    NRCELL-2:gscnOrSsPbchArfcn=7933
...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    NRCELL-2:nrarfcn=641668
...    NRCELL-2:rlpDetCsiBsiThreshold=75
...    NRCELL-2:dtxOptimizedScheduler:dtxMaxRetentionDelay=10
...    NRCELL-2:dtxOptimizedScheduler:dtxPrbThreshold=80
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    NRCELL-2/NRHOIF-1:scs=30 KHz
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-2/NRHOIF-1:ssbFrequency=649920
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

@{CELL2_nrConnectModeProfileDN_Set1}
...    NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1

@{CELL2_nrConnectModeProfileDN_Set0}
...    NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0

#counters
${SGNB_NSA_HO_ADMISS_MFBI_REQ}    M55114C00503
${SGNB_NSA_HO_ADMISS_MFBI_SUCC}    M55114C00504

@{BC_Failed}
...    NRCELL-1:${SGNB_NSA_HO_ADMISS_MFBI_REQ}=0
...    NRCELL-1:${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=0
...    NRCELL-2:${SGNB_NSA_HO_ADMISS_MFBI_REQ}=0
...    NRCELL-2:${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=0

@{BC_Passed}
...    NRCELL-1:${SGNB_NSA_HO_ADMISS_MFBI_REQ}=0
...    NRCELL-1:${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=0
...    NRCELL-2:${SGNB_NSA_HO_ADMISS_MFBI_REQ}=1
...    NRCELL-2:${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=1


#UE CAP
${ue_nr_capabilities}    SEPARATOR=
...    ED007000479A4BBF5FFFFEF8005BD405E00CFDBFCB98AD7FFBF900001F53FFFFCDEA04C0067EDFE5CC56BFFDFC80000FA9FFFFE88
...    0000073BF79FFF9FFFF60000FBC00BFFF0000163C03F148200DFFF785FFF5E00F2A6A7000158800000000023007CAA080E0

${ue_eutra_nr_capabilities}    SEPARATOR=
...    BD1BA063058100713000000018062B000060400C1001830030600E178000010300C160801C2F000006060182C000385E00000C0C0
...    305810070BC00001018060B0600E17800002030048BC500C200020100801002570010040200804010080201004020080401008020
...    100402008040100802010040201004020080401008000000402008040000000000040200000000000000004020080401008020100
...    000008040100800000000000804000000000000000080401008020100402008040000002010040200804000000000000000080400
...    0000000000000000001009C0020200804008080101000000040400808000000000004040000000000000000402010040100802010
...    040200804010080201004020080401008020100402008080201002020000000808010100000004040000000000020200000000000
...    101004020040400808000000202004040000000000020200404000000000002020000000000000000202700100802010040200000
...    010080201000000080400000000000402000000000002010040200804000000201004020000001008000000000008040000000000
...    040100802010040200804010080201004020080401008020100402008040100804010080201000000080401008000000402000000
...    100800000040200000000000201000000000001009C00202004040080801010020200000008080101002020000000000010100000
...    004040080801010020200404000000101002020040400000000000202000000080801010020200404008080000002020040400808
...    000000000004040000001008020100402008040100802010040200804010080201004020080401008020100402008040100804017
...    001008010100000004040080800000000000000008080000000000000000000020100202000000080801010000000000000000101
...    000000000000000000000402004040000001010020200000000000000002020000000000000000000008040080800000020200404
...    00808000000000004040000001010020200000000000000002020000000809C40080180100300200600400C008018010030020060
...    0400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C00801801
...    00300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C008018010030020060040
...    0C0080180100300200600400C0080180100300200600400C0080180100300200600400C008010800040202004008400040101002004

*** Test Cases ***
5GC001416-ET-BC012_Verify_failed_IntraMeNB_IntraSgNB_intraDU_PSCellchange_for_UE_using_alternative_bands_onlinemodify_alternative_band_in_Tcell
    [Documentation]    The purpose of this test case is to
    ...    1.Verify alternave band will be send to enb in SgNBAdditionRequest and SgNBAdditionRequestAcknowledge
    ...    2.Verify intra SgNB HO failed using alternative band after alternative band removed
	[Tags]    QC_133758    BC012
    Attach UE Check The Result And Start The Traffic
    Send A2 Measurement With Gap
    Change Cell2 NrConnectModeProfileDN To 0
    Send A5 Measurement Failed
    Check Counters    ${BC_Failed}
    Change Cell2 NrConnectModeProfileDN To 1
    Send A5 Measurement Passed
    Check Counters    ${BC_Passed}
    UE Detach

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${GNB2_CELL1}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=650000:650000 gscn=8019 mandatory_for_activation=off
    ${GNB2_CELL2}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=0 nrci=0x02 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=641668:641668 gscn=7933 mandatory_for_activation=off
    ${ENB1_CELL2}    catenate
    ...    set_cell id=2 enb=1 eci=0x1234602 pci=3:1 tac=222 proxy=10.0.2.1:12220 earfcn=2000:20000 mapped_earfcn=4200:22200
    ${UE31}    catenate
    ...    set_ue simulated id=31 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    eia=null+snow3g+aes eea=null nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc imsi=250:555:21645411
    Update Cfg    ${GNB2_CELL1}
    Update Cfg    ${GNB2_CELL2}
    Update Cfg    ${ENB1_CELL2}
    Update Cfg    ${UE31}
    Update Cfg    ue_param id=31 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}

Change Cell2 NrConnectModeProfileDN To 0
    delta commission parameters    ${CELL2_nrConnectModeProfileDN_Set0}

Change Cell2 NrConnectModeProfileDN To 1
    delta commission parameters    ${CELL2_nrConnectModeProfileDN_Set1}

Attach UE Check The Result
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2    timeout=60    sleep_time=5
    Execute Egate Command    ue_change_location id=31 enb=1 cell=1
    Execute Egate Command    ue_attach id=31    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=31 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    UE31: Proxy \\(eNB 2 cell 1\\) reported successful RA

Attach UE Check The Result And Start The Traffic
    Attach UE Check The Result
    Execute Egate Command    trf_data_start id=2 ue=31 dir=dl mbps=5 trf_id=1    pass_regexp=UDP DL TRF
    Execute Egate Command    trf_data_start id=2 ue=31 dir=ul mbps=2 trf_id=2    pass_regexp=UDP UL TRF    sleep_time=3


Send A2 Measurement With Gap
    Execute Egate Command    ue_enb_param id=31 measurement_gap=gp0:12 gap_trigger=gnb_triggered
    ${reportA2}=    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=1 event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=Sending SgNB Modification Confirm
    Should Contain    ${reportA2}    RRC Connection Reconfiguration
    Should Contain    ${reportA2}    Successfully reconfigured dual connectivity
    Should Contain    ${reportA2}    rrcConnectionReconfigurationComplete
    Execute Egate Command    ue_enb_param id=118 measurement_gap=off


Send A5 Measurement Failed
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=4 event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=60 nrsrq_nr=60
    ...    fail_regexp=Proxy \\(eNB 2 cell 2\\) reported successful RA


Send A5 Measurement Passed
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=4 event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=60 nrsrq_nr=60
    ...    pass_regexp=Proxy \\(eNB 2 cell 2\\) reported successful RA

UE Detach
    Execute Egate Command    ue_detach id=31    UE IS OFF
