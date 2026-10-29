*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env And Start TCE
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT_no_cloud    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_CN2    Owner_shelly.song    release-SBTS22R2
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC001416}
...    @{NRREL}
...    @{TCE}
...    @{CellTrace_PCMD_Enable}

@{TCE}
...    MRBTS/MNL-1/TCEADM-1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIpAddress=${TCE_IP}
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tcePortNumber=${TCE_PORT}
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tlsEnabled=false
...    NRBTS/NRCTRLTS-1

@{CellTrace_PCMD_Enable}
...    @{NRMTRACECU}
...    @{CellTrace_Enable}
...    @{traceAll}
...    @{PCMD_Enable}
...    @{1UE_infinityreport}

@{NRMTRACECU}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:cellMaxActiveUEsTraced=100
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrTceIdentifier=1
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:scope=allResources
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mcc=311
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mnc=489
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mncLength=3
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:traceId=1

@{CellTrace_Enable}
...    NRBTS:actCellTraceReport=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=true
...    NRBTS:actMDTTraceReport=true
@{PCMD_Enable}
...    NRBTS:actPCMDReport=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actPCMDReporting=true
@{traceAll}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNRRRCSetting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceX2Setting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceXNSetting=all
@{1UE_infinityreport}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:jobType=ImmediateMDTAndTrace
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:mdtMeasType=periodic
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:reportAmount=infinity
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:reportInterval=ms5120
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTControl:cellMaxActiveMDTUEsTraced=1

@{5GC001416}
#Alternative band=77
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRBTS:tmpActFeat1=1
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
...    NRBTS:actIntraMeNBMobility=true
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasEnabled=rsrp
...    NRBTS:srb3SupportEnabled=false
...    NRBTS:cipherPrefL:nea0=3|nea3_128=0
...    NRBTS:cipherPrefL:nea1_128=0|nea3_128=0
...    NRBTS:cipherPrefL:nea2_128=0|nea3_128=0

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

...    NRBTS/NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrRelReportCu=disabled
...    NRBTS/NRPMRNL-1:miNrNgcFlexInterface=disabled

@{Enable_srb3}
...    NRBTS:srb3SupportEnabled=true

@{DELETE_PROFILE}
...    delete:MRBTS-1/NRBTS-1/NRCELL-2:nrConnectModeProfileDN

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

@{BB002}
...    NRCELL-1:${SGNB_NSA_HO_ADMISS_MFBI_REQ} =1
...    NRCELL-1:${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=1
...    NRCELL-2:${SGNB_NSA_HO_ADMISS_MFBI_REQ} =1
...    NRCELL-2:${SGNB_NSA_HO_ADMISS_MFBI_SUCC}=1

${PCI_CELL1}    0926DA802190
${PCI_CELL2}    0926DA802198
${SOS_REPORT_FLAG}     pass:False,fail:False

@{BB004}
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
5GC001416-ET-BB002_Verify_Successful_Intra-MeNB_Cell_HO_Intra-SgNB_Intra-Frequency_handover_for_UE_using_alternative_bands_without_SRB3
    [Documentation]    The purpose of this test case is to
    ...    1.Verify alternave band will be send to enb in SgNBAdditionRequest and SgNBAdditionRequestAcknowledge
    ...    2.Verify intra MeNB intra SgNB HO using alternative band without SRB3
    ...    3.Native band cell-1 and cell-2:freqBandIndicatorNR=78
    [Tags]    QC_234146    BB002
    Check Egate Console freqBandIndicatorNr
    Set eNB Allow ENDC On
    Attach UE Check The Result And Check The Traffic_BB02
    Perform UE Intra MeNB Handover to Cell2
    Perform UE Intra MeNB Handover to Cell1
    Check Counters    ${BB002}
    UE Detach

5GC001416-ET-BB004_Verify_Successful_Intra-SgNB_Intra-Frequency_handover_for_UE_using_alternative_bands_with_SRB3
    [Documentation]    The purpose of this test case is to
    ...    1.Verify alternave band will be send to enb in SgNBAdditionRequest and SgNBAdditionRequestAcknowledge
    ...    2.Verify intra SgNB HO using alternative band with SRB3
    [Tags]    QC_234148    BB004
    Delta Commision Enable SRB3
    Clear Counter files    True
    Check Egate Console freqBandIndicatorNr
    Attach UE Check The Result And Check The Traffic
    NSA UE Attach And Initial Endc Without PeriodicUeMeas
    Perform UE Intra SgNB Handover to Cell2
    Perform UE Intra SgNB Handover to Cell1
    Check WireShark Log    ${CURDIR}${/}a2a_BB004${/}a2a2.ini    name=HO
    Check Counters    ${BB004}
    UE Detach

5GC001416-ET-BB006_Verify_IntraSgNB_IntraFreq_HO_Failed_To_TargetSgNBcell_for_UE_using_alternative_bands
    [Documentation]    The purpose of this test case is to
    ...    1.Verify alternave band will be send to enb in SgNBAdditionRequest and SgNBAdditionRequestAcknowledge
    ...    2.Verify intra SgNB HO is failed to target SgNB cell due to remove nrConnectModeProfileDN
    [Tags]    QC_234147    BB006
    Delete NrConnectModeProfileDN
    Check Egate Console freqBandIndicatorNr
    Attach UE Check The Result And Check The Traffic_BB06
    Perform UE Intra SgNB Handover to Cell2 Failed And Check Cell Status
    UE Detach

*** Keywords ***
Common Suite Setup And Setup Airphone Env And Start TCE
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri
    Perform Steps After Onair

Perform Steps After Onair
    Start TCE    ${TCE_PORT}
    Set eNB X2 link And Allow Endc On

Set eNB X2 link And Allow Endc On
    Execute Egate Command    enb_x2_link_up enb=1 target=3    is up
    Execute Egate Command    enb_cell_param enb=1 id=1 allow_endc=on
    Execute Egate Command    enb_cell_param enb=1 id=2 allow_endc=on


Modify Cfg
    ${eNB1_cell_2}    catenate
    ...    set_cell id=2 enb=1 eci=0x1234602 pci=4:0 tac=222 proxy=$CONTAINER_IP:12218 earfcn=1400:19400
    ...    tdd_cell=on mandatory_for_activation=off
    Update Cfg    ${eNB1_cell_2}

    ${UE31}    catenate
    ...    set_ue simulated id=31 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    eia=null+snow3g+aes eea=null nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc imsi=311:489:21645400
    Update Cfg    ue_param id=31 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ${UE32}    catenate
    ...    set_ue simulated id=32 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    eia=null+snow3g+aes eea=null nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc imsi=311:489:21645401
    Update Cfg    ${UE32}
    Update Cfg    ue_param id=32 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    Update Cfg    set_bearer id=2 ue=31 qci=9 pdn=1 ip=4.7.254.209 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=32 qci=9 pdn=1 ip=4.7.254.208 default=on trf_type=internal
    ${GNB3_sim_configuration}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 s1u=10.0.1.122 ng=10.0.1.123 gnb_id=0x3:22 daemon=10.0.2.1:22222 xn=10.0.1.124 x2_peers=none
    ...    nssai=0x1:0xd143a5 amf=none
    Update Cfg    ${GNB3_sim_configuration}
    ${GNB3_Cell1_sim_configuration}    catenate
    ...    set_cell id=1 gnb=3 pci=17:1 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666 gscn=7880
    ...    mandatory_for_activation=off
    Update Cfg    ${GNB3_Cell1_sim_configuration}
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3


Check Egate Console freqBandIndicatorNr
    ${Trigger_ENDC_X2}    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2    timeout=60    sleep_time=5
    Should Contain    ${Trigger_ENDC_X2}    freqBandIndicatorNr 78
    Should Contain    ${Trigger_ENDC_X2}    freqBandIndicatorNr 77

Attach UE Check The Result And Check The Traffic
    [Arguments]    ${cellfreq}=636576
    Execute Egate Command    ue_change_location id=31 enb=1 cell=1
    Execute Egate Command    ue_attach id=31    UE IS ACTIVE
    ${cmd}     Catenate    ue_dc_enb_start ue=31 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=Successfully reconfigured dual connectivity    timeout=20s
    Should Contain    ${ret1}    reportType periodical
    ${Periodical_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=31    carrierfreq=${cellfreq}
    ...    event_type=Periodical
    Should Not Be Empty    ${Periodical_meas_id}
    ${cmd}     Catenate    ue_measurement_send_nr id=31 meas_id=${Periodical_meas_id} report_type=periodical
    ...    srsrp_nr=31 srsrq_nr=30 ssinr_nr=30 srs_result=0:50:50:50
    Execute Egate Command    ${cmd}    pass_regexp=For Periodic MeasId = .* MeasReportQuantity from RRC-reconfiguration
    Check WireShark Log    ${CURDIR}${/}a2a_BB004${/}a2a1.ini    wait_string=BearerContextModificationResponse
    Start To Capture Wireshark Log    tag=HO

NSA UE Attach And Initial Endc Without PeriodicUeMeas
    Execute Egate Command    ue_change_location id=32 enb=1 cell=1
    Execute Egate Command    ue_attach id=32    UE IS ACTIVE
    ${cmd}     Catenate    ue_dc_enb_start ue=32 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=Successfully reconfigured dual connectivity    timeout=20s
    Should Not Contain    ${ret1}    reportType periodical
    Traffic Should Be Ok    ue_id=32    type=NSA


Perform UE Intra SgNB Handover to Cell2
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=Proxy \\(eNB 2 cell 2\\) reported successful RA

Perform UE Intra SgNB Handover to Cell1
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    cells should be onair

Delete NrConnectModeProfileDN
    Delta Commission Parameters    ${DELETE_PROFILE}

Perform UE Intra SgNB Handover to Cell2 Failed And Check Cell Status
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=30 nrsrq_nr=30
    ...    fail_regexp=Proxy \\(eNB 2 cell 2\\) reported successful RA
    cells should be onair

UE Detach
    Execute Egate Command    ue_detach id=31    UE IS OFF

Set eNB Allow ENDC On
    Execute Egate Command    enb_cell_param enb=1 id=1 allow_endc=on
    Execute Egate Command    enb_cell_param enb=1 id=2 allow_endc=on


Attach UE Check The Result And Check The Traffic_BB02
    Execute Egate Command    ue_change_location id=31 enb=1 cell=1
    Execute Egate Command    ue_attach id=31    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=31 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    UE31: Proxy \\(eNB 2 cell 1\\) reported successful RA
    Check WireShark Log    ${CURDIR}${/}a2a_BB002${/}a2a.ini    wait_string=BearerContextModificationResponse

Perform UE Intra MeNB Handover to Cell2
    Execute Egate Command    ue_enb_endc_param id=31 candidate_cells_mn_hex_for_menb_ho=${PCI_CELL2}
    ${UE_HO_TO_CELL2}    Execute Egate Command    ue_ho id=31 enb=1 cell=2    Intra-eNB handover from ENB-1.1 to ENB-1.2 performed
    Should Contain    ${UE_HO_TO_CELL2}    Proxy (eNB 2 cell 2) reported successful RA

Perform UE Intra MeNB Handover to Cell1
    Execute Egate Command    ue_enb_endc_param id=31 candidate_cells_mn_hex_for_menb_ho=${PCI_CELL1}
    ${UE_HO_TO_CELL1}    Execute Egate Command    ue_ho id=31 enb=1 cell=1    Intra-eNB handover from ENB-1.2 to ENB-1.1 performed
    Should Contain    ${UE_HO_TO_CELL1}    Proxy (eNB 2 cell 1) reported successful RA
    cells should be onair

Delta Commision Enable SRB3
    Delta Commission Parameters    ${Enable_srb3}

Attach UE Check The Result And Check The Traffic_BB06
    Execute Egate Command    ue_change_location id=31 enb=1 cell=1
    Execute Egate Command    ue_attach id=31    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=31 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    UE31: Proxy \\(eNB 2 cell 1\\) reported successful RA
    Check WireShark Log    ${CURDIR}${/}a2a_BB004${/}a2a1.ini    wait_string=BearerContextModificationResponse
    Start To Capture Wireshark Log    tag=HO
