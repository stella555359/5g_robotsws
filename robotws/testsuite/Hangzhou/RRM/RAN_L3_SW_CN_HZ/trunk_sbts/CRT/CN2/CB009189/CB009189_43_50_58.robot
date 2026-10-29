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
...    NRBTS-1:actMultiDrbNSA=true
...    NRBTS-1:srb3SupportEnabled=true
...    NRBTS/NRDRB-3:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-6:nsaDrbParam:ulDataPath=ulOverLteNr_PrimaryPathOverNr
...    NRBTS/NRDRB-3:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS/NRDRB-6:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS/NRDRB-3:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS/NRDRB-6:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS/NRDRB-13:discardTimer=100ms
...    NRBTS/NRDRB-13:discardTimerUl=200ms
...    NRBTS-1:actServiceAwarePDCPConfig=true
...    @{intrapscellchange}

@{intrapscellchange}
...    NRBTS:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRCELL:a5MeasEnabled=rsrp
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=50
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

@{PARAMS_To_Change58}
...    NRBTS-1:srb3SupportEnabled=false
...    NRCELL:a5MeasEnabled=none
...    NRCELL:a3MeasEnabled=rsrp
...    NRBTS/NRDRB-6:discardTimer=200ms
...    NRBTS/NRDRB-3:discardTimer=200ms
...    NRBTS/NRDRB_PDCP-1:outOfOrderDeliveryDl=false
...    NRBTS/NRDRB_PDCP-1:outOfOrderDeliveryUl=false

@{PM_Counters_Check_A43_1}
...    NRCELL-1:NUEQN:${MAX_NUM_OOD_CAP_UE}=1
...    NRCELL-1:NUEQN:${AVG_NUM_UE_DENOM}=300
...    NRCELL-2:NUEQN:${MAX_NUM_OOD_CAP_UE}=1
...    NRCELL-2:NUEQN:${AVG_NUM_UE_DENOM}=300
@{PM_Counters_Check_A43_2}
...    NRCELL-1:NUEQN:${MAX_NUM_OOD_CAP_UE}=0
...    NRCELL-1:NUEQN:${AVG_NUM_OOD_CAP_UE_NOM}=0
...    NRCELL-1:NUEQN:${AVG_NUM_UE_DENOM}=300
...    NRCELL-2:NUEQN:${MAX_NUM_OOD_CAP_UE}=1
...    NRCELL-2:NUEQN:${AVG_NUM_OOD_CAP_UE_NOM}=300
...    NRCELL-2:NUEQN:${AVG_NUM_UE_DENOM}=300

@{PM_Counters_Check_A58}
...    NRCELL-1:NUEQN:${MAX_NUM_OOD_CAP_UE}=0
...    NRCELL-1:NUEQN:${AVG_NUM_UE_DENOM}=300
...    NRCELL-1:NUEQN:${AVG_NUM_OOD_CAP_UE_NOM}=0
...    NRCELL-2:NUEQN:${MAX_NUM_OOD_CAP_UE}=0
...    NRCELL-2:NUEQN:${AVG_NUM_UE_DENOM}=300
...    NRCELL-2:NUEQN:${AVG_NUM_OOD_CAP_UE_NOM}=0

${MAX_NUM_OOD_CAP_UE}    M55181C00001    #Maximum number of OutOfOrderDelivery capable UEs
${AVG_NUM_OOD_CAP_UE_NOM}    M55181C00002    #Average number of OutOfOrderDelivery capable Ues Numerator
${AVG_NUM_UE_DENOM}    M55181C00003    #Average number of UEs denominator

*** Test Cases ***

CB009189_43_NSA_Intrafreq_IntraDU_Pscell_change_with_SRB_with_outoforder_both_link_use_A5
    [Documentation]
    ...    1. This user scenario describes the PDCP behavior for the transmission when DRB set up with out of order.
    ...    2. Configuration
    ...    a.NSA TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to NSA or both
    ...    c.NRBTS/NRDRB_PDCP/outOfOrderDeliveryDl = true , outOfOrderDeliveryUl = true for QCI_6,9
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.QCI_9 is setup with out of order.
    ...    b.Add QCI_6 drb which is setup with out of order
    ...    c.Intrafreq IntraDU Pscell change with SRB3.
    ...    d.UE detach.
    [Tags]    QC_223942
    NSA UE Attach To Target Cell
    NSA UE Add More Drbs
    NSA Intragnb Intrafreq Pscell Change via A5
    A43 counters check
    UE Detach    ue_id=16
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189_43${/}a2a.ini    wait_string=UEContextReleaseComplete::2
    Check RRC Log    ${CURDIR}${/}a2a_CB009189_43${/}a2a.ini

CB009189_50_SA_Intrafreq_IntraDU_HO_NonGBR_DRB_setup_with_PDCP_Discard_Timer_use_A5
    [Documentation]
    ...    1. This user scenario describes the PDCP behavior for the transmission when DRB set up with discardtimer.
    ...    2. Configuration
    ...    a.NSA TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to SA or both
    ...    c.NRBTS/NRDRB-13:discardTimer=100ms, NRBTS/NRDRB-13:discardTimerUl=200ms
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.5QI8 drb is setup with discardtimer.
    ...    b.Intrafreq IntraDU HO.
    ...    c.UE detach.
    [Tags]    QC_223941
    UE Attach To Target Cell    ue_id=1    cell_id=1
    SA Intragnb Intrafreq HO
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189_50${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check RRC Log    ${CURDIR}${/}a2a_CB009189_50${/}a2a.ini


CB009189_58_NSA_Intrafreq_IntraDU_Pscell_change_wo_SRB3_NonGBR_DRB_setup_with_PDCP_Discard_Timer
    [Documentation]
    ...    1. This user scenario describes the PDCP behavior for the transmission when DRB set up with discardtimer.
    ...    2. Configuration
    ...    a.NSA TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
    ...    b.NRF1 cell has NRCELL-cellDepType set to NSA or both
    ...    c.NRBTS/NRDRB:discardTimer=200ms for QCI_6,9
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.QCI_9 is setup with discardtimer.
    ...    b.Add QCI_6 drb which is setup with discardtimer
    ...    c.Intrafreq IntraDU Pscell change without SRB3.
    ...    d.UE detach.
    [Tags]    QC_223938
    OnlineParamChange    ${PARAMS_To_Change58}
    NSA UE Attach To Target Cell
    NSA UE Add More Drbs
    NSA Intragnb Intrafreq Pscell Change via A3
    UE Detach    ue_id=16
    Clear Counter Files
    Check Counters    ${PM_Counters_Check_A58}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189_58${/}a2a.ini    wait_string=UEContextReleaseComplete::2
    Check RRC Log    ${CURDIR}${/}a2a_CB009189_58${/}a2a.ini


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=15

Modify Cfg
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    set_bearer id=3 ue=16 qci=6 pdn=1 default=off

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

NSA Intragnb Intrafreq Pscell Change via A5
    Clear Counter Files
    Execute Egate Command    ue_measurement_send_nr id=16 meas_id=1 event=A5 srsrp_nr=40 srsrq_nr=40 phycell_id=51 nrsrp_nr=60 nrsrq_nr=60
    ...    Sending SgNB Modification Confirm
    Verify All Nsa Throuput

NSA Intragnb Intrafreq Pscell Change via A3
    Execute Egate Command    ue_measurement_send_nr id=16 meas_id=1 event=A3 srsrp_nr=40 srsrq_nr=40 phycell_id=51 nrsrp_nr=60 nrsrq_nr=60
    ...    Sending SgNB Modification Confirm
    Verify All Nsa Throuput

SA Intragnb Intrafreq HO
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=1 event=A5 srsrp_nr=40 srsrq_nr=40 phycell_id=51 nrsrp_nr=60 nrsrq_nr=60
    ...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    Verify Throuput

Verify Throuput
    [Arguments]    ${Tput_dl}=45    ${Tput_ul}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

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


UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 mbps=50 dir=dl
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 mbps=10 dir=ul

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

A43 counters check
    Check Counters    ${PM_Counters_Check_A43_1}
    Clear Counter Files
    Check Counters    ${PM_Counters_Check_A43_2}
