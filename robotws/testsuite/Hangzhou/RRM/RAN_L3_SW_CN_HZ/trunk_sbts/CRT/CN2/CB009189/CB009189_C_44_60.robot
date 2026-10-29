*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-meredith.ma
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB009189    release-SBTS23R1
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}
...    NRBTS/NRDRB_PDCP-1:outOfOrderDeliveryDl=true
...    NRBTS/NRDRB_PDCP-1:outOfOrderDeliveryUl=true
...    NRBTS/NRDRB-6:discardTimer=20ms
...    NRBTS/NRDRB-6:discardTimerUl=10ms
...    NRBTS/NRDRB-3:discardTimer=20ms
...    NRBTS/NRDRB-3:discardTimerUl=10ms
...    NRBTS-1:actServiceAwarePDCPConfig=true
...    NRBTS-1:actMultiDrbNSA=true
...    NRBTS-1:srb3SupportEnabled=false
...    NRBTS/NRDRB-3:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-6:nsaDrbParam:ulDataPath=ulOverLteNr_PrimaryPathOverNr
...    NRBTS/NRDRB-3:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS/NRDRB-6:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS/NRDRB-3:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS/NRDRB-6:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    @{interpscellchange}

@{interpscellchange}
...    NRBTS:tDCoverall=10000
...    NRBTS:timerX2UeProcGuard=15000
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea3_128=9
...    NRBTS/NRADJNRCELL-4915:cellDepType=NSA
...    NRBTS/NRADJNRCELL-4915:gNbId=3
...    NRBTS/NRADJNRCELL-4915:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4915:lcrId=3
...    NRBTS/NRADJNRCELL-4915:nrarfcn=633372
...    NRBTS/NRADJNRCELL-4915:physCellId=381
...    NRBTS/NRADJNRCELL-4915:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4915:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4915:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4915:freqBandIndicatorNR=78
...    NRBTS/NRADJNRCELL-4915:ssbFrequency=633408
...    NRCELL-1/NRREL-2:gNbId=3
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:lcrId=3
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRCELL:a2MeashoEnabled=rsrp
...    NRCELL:a1MeashoEnabled=rsrp
...    NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=60
...    NRCELL:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRCELL:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=40
...    NRCELL:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1/NRHOIF-1:cellDepType=NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=633408
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
${Update_Cfg_1}    set_cell id=3 gnb=3 tac=3 pci=127:0 proxy=10.0.2.1:12221|10.0.2.1:8891 nrci=0x1 nr_arfcn=633372:633372 gscn=7847
...    tdd_cell=on mandatory_for_activation=off
${Update_Cfg_2}    set_enb id=1 plmn=311:489 s1=10.0.1.121 enb_id_macro=0x12346 daemon=10.0.2.1:22222 x2=10.0.1.12 x2u=10.0.1.136
...    type=simulated x2_peers=none
${Update_Cfg_3}    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 gnb_id=0x2:22 x2=10.0.1.2:36422 x2_peers=none ng=10.0.1.2
...    xn=10.0.1.2 amf=1 nssai=0x1:0xd143a5

@{PM_Counters_Check_A44_1}
...    NRCELL-1:NUEQN:${MAX_NUM_OOD_CAP_UE}=1
...    NRCELL-1:NUEQN:${AVG_NUM_UE_DENOM}=300
...    NRCELL-2:NUEQN:${MAX_NUM_OOD_CAP_UE}=1
...    NRCELL-2:NUEQN:${AVG_NUM_UE_DENOM}=300
@{PM_Counters_Check_A44_2}
...    NRCELL-1:NUEQN:${MAX_NUM_OOD_CAP_UE}=0
...    NRCELL-1:NUEQN:${AVG_NUM_OOD_CAP_UE_NOM}=0
...    NRCELL-1:NUEQN:${AVG_NUM_UE_DENOM}=300
...    NRCELL-2:NUEQN:${MAX_NUM_OOD_CAP_UE}=1
...    NRCELL-2:NUEQN:${AVG_NUM_OOD_CAP_UE_NOM}=300
...    NRCELL-2:NUEQN:${AVG_NUM_UE_DENOM}=300

@{PM_Counters_Check_A60}
...    NRCELL-1:NUEQN:${AVG_NUM_UE_DENOM}=300
...    NRCELL-2:NUEQN:${AVG_NUM_UE_DENOM}=300


${MAX_NUM_OOD_CAP_UE}    M55181C00001    #Maximum number of OutOfOrderDelivery capable UEs
${AVG_NUM_OOD_CAP_UE_NOM}    M55181C00002    #Average number of OutOfOrderDelivery capable Ues Numerator
${AVG_NUM_UE_DENOM}    M55181C00003    #Average number of UEs denominator

*** Test Cases ***
#CB009189_44_NSA_IntergNB_PSCell_change_wo_SRB3_with_outoforder_both_link_use_A3
#    [Documentation]
#    ...    1. This user scenario describes the PDCP behavior for the transmission when DRB set up with out of order.
#    ...    2. Configuration
#    ...    a.NSA TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
#    ...    b.NRF1 cell has NRCELL-cellDepType set to NSA or both
#    ...    c.NRBTS/NRDRB_PDCP/outOfOrderDeliveryDl = true , outOfOrderDeliveryUl = true for QCI_6,9
#    ...    3. Test Case Steps:
#    ...    a.UE attach and set up PDU session.QCI_9 is setup with out of order.
#    ...    b.Add QCI_6 drb which is setup with out of order
#    ...    c.Interfreq IntergNB Pscell change with SRB3.
#    ...    d.UE detach.
#    [Tags]    QC_224566
#    Clear Counter Files
#    Set UE Parameters Before Attach
#    NSA UE Attach To Target Cell
#    NSA UE Add More Drbs
#    NSA Intergnb Interfreq Pscell Change for ooo
#    A44 counters check
#    UE Detach    ue_id=16
#    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189_44${/}a2a.ini    wait_string=UEContextReleaseComplete::4
#    Check RRC Log    ${CURDIR}${/}a2a_CB009189_44${/}a2a.ini

CB009189_60_NSA_IntergNB_PSCell_change_wo_SRB3_NonGBR_DRB_setup_with_PDCP_Discard_Timer
    [Documentation]
    ...    1. This user scenario describes the PDCP behavior for the transmission when DRB set up with discardtimer.
    ...    2. Configuration
    ...    a.NSA TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to NSA or both
    ...    c.discardTimer=20ms , discardTimerUL=10ms for QCI_6,9
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.QCI_9 is setup with discardtimer.
    ...    b.Add QCI_6 drb which is setup with discardtimer
    ...    c.Intrafreq IntergNB Pscell change with SRB3.
    ...    d.UE detach.
    [Tags]    QC_224565
    Clear Counter Files
    Set UE Parameters Before Attach
    NSA UE Attach To Target Cell
    NSA UE Add More Drbs
    NSA Intergnb Interfreq Pscell Change for ooo
    A60 counters check
    UE Detach    ue_id=16
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189_60${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check RRC Log    ${CURDIR}${/}a2a_CB009189_60${/}a2a.ini


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15

Modify Cfg
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    set_bearer id=3 ue=16 qci=6 pdn=1 default=off
    Update Cfg    gnb_set id=3 s1u=10.0.1.122 plmn=311:489 gnb_id=0x3 type=simulated daemon=10.0.2.1:22222 x2=10.0.1.122:36422 x2_peers=none
    Update Cfg    gnb_param id=3 x2_listening_socket=1 measEvent=A3
    Update Cfg    ${Update_Cfg_1}
    Update Cfg    ${Update_Cfg_2}
    Update Cfg    ${Update_Cfg_3}

Set UE Parameters Before Attach
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2
    Execute Egate Command    enb_x2_link_up enb=1 target=3    ENB-1: X2AP Link with GNB-3

NSA UE Attach To Target Cell
    Execute Egate Command    ue_attach id=16 profile=1    UE IS ACTIVE
    Execute Egate Command
    ...    ue_dc_enb_start ue=16 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    reported successful RA

NSA UE Add More Drbs
    Execute Egate Command    bearer_add ue=16 id=3 filter=0 precedence=0    PGW-initiated Bearer Creation
    Execute Egate Command    enb_ue_dc_modify ue=16 bearer_to_add=3 by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
    ...    Successfully reconfigured dual connectivity
    Send All Nsa Throuput

Send All Nsa Throuput
    [Arguments]    ${ue_id}=16
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=10    UDP DL TRF
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10    UDP UL TRF
    Execute Egate Command    data_trf_start ue=${ue_id} id=3 dir=dl mbps=10    UDP DL TRF
    Execute Egate Command    data_trf_start ue=${ue_id} id=3 dir=ul mbps=10    UDP UL TRF

NSA Intergnb Interfreq Pscell Change for ooo
    Execute Egate Command    ue_enb_param id=16 measurement_gap=gp0:12 gap_trigger=gnb_triggered
    Execute Egate Command    ue_measurement_send_nr id=16 meas_id=1 event=A2 srsrp_nr=30 srsrq_nr=30
    ...    Sending SgNB Modification Confirm
    Execute Egate Command    ue_enb_param id=16 measurement_gap=off
    Execute Egate Command    ue_measurement_send_nr id=16 meas_id=3 event=A3 srsrp_nr=40 srsrq_nr=40 phycell_id=381 nrsrp_nr=60 nrsrq_nr=60
    ...    SCG-split is successful
    Execute Egate Command    ue_measurement_send_nr id=16 meas_id=1 event=A3 srsrp_nr=40 srsrq_nr=40 phycell_id=51 nrsrp_nr=60 nrsrq_nr=60
    ...    Inter Sgnb Handover is successful
    Verify All Nsa Throuput

Verify All Nsa Throuput
    [Arguments]    ${ue_id}=16    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput1}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throughput1}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    ${dl_throughput2}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=3    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throughput2}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=3    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throughput1}/1000>9
    Should Be True    ${ul_throughput1}/1000>9
    Should Be True    ${dl_throughput2}/1000>9
    Should Be True    ${ul_throughput2}/1000>9

UE Detach
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_detach id=${ue_id}    UE${ue_id}: detached    timeout=10s

A44 counters check
    Check Counters    ${PM_Counters_Check_A44_1}
    Clear Counter Files
    Check Counters    ${PM_Counters_Check_A44_2}

A60 counters check
    Check Counters    ${PM_Counters_Check_A60}
