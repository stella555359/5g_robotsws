*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Stop Capture Logs And Restore ENV In Test Teardown
Force Tags  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CIT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD
...    team-DevHZ5_SG2    owner-yuhua.zhu    release-5G19B     5GC000733    7_5_CN2_TT_T806    7_5_CN2_TT_T809
Resource  ../../../../resources/DevHZ5_resource.robot


*** Variables ***
${UTE_WIRESHARK_FLAG}  ${False}
@{PARAMS_IN_SCF}    @{feature_flag}    @{paging_para}
@{feature_flag}
...    NRBTS:actPaging=true
...    NRCELL-1:actCDrx=true

@{paging_para}
...    NRBTS:drxDefaultPaging=v256
...    BWP_PROFILE-54/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-5/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRCELL-1:numOfPagingFrames=halfT
...    NRCELL-1:pagingOffset=1
...    NRCELL-1:numPagingOccsnPagingFrame=two
...    NRCELL-1:fPdcchMonOccsnPo=0,2
...    NRCELL-1:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-1:drxProfile1:drxLongCycle=80ms
...    NRCELL-1:drxProfile1:drxOnDurationTimer=20ms
...    NRCELL-1:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-1:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
@{PM_Counters_Check_CIT006}
...    ${NF1CD_F1AP_PAGING_RECD}=1
...    ${NNGCB_NGAP_PAGING_RECD}=1
...    ${NRPAG_PAGING_SUCC_SENT}=2
...    ${NRRCD_RRC_STPREQ_MT_ACCESS}=1
...    ${NRRCC_RRC_STPREQ_MT_ACCESS}=1
...    ${NRRCC_RRC_STPSUCC_TOT}=2 
${NF1CD_F1AP_PAGING_RECD}    M55117C03001    #Number of F1AP Paging message received at gNB-DU
${NNGCB_NGAP_PAGING_RECD}    M55119C01501    #Number of NGAP Paging message received at gNB-CU-CP
${NRPAG_PAGING_SUCC_SENT}    M55331C00001    #Number of RRC Paging message successfully broadcasted
${NRRCD_RRC_STPREQ_MT_ACCESS}    M55127C00003    #Number of RRC CONNECTION Attempts for Mobile Terminated Access,gNB-CU
${NRRCC_RRC_STPREQ_MT_ACCESS}    M55124C01003    #Number of RRC CONNECTION Attempts for Mobile Terminated Access,gNB-DU
${NRRCC_RRC_STPSUCC_TOT}    M55124C01031    #Number of RRC CONNECTION Attempts that were completed successfully
${BTS_STARTUP_RETRY}    4


*** Test Cases ***
5GSW-CP-CIT006_Verify Classical SA FDD cmWave - L3 call setup after paging on idle is successful
    [Documentation]
    ...    This case will include feature 5GC000733.Verify paging occasion for IDLE UE in single beam for 1208 slot pattern
    ...    Configured 1208 slot with 0ms
    ...    After UE registered, make UE to idle
    ...    AMF paging
    ...    Check paging procedure
    [Tags]    QC_61695    Zhu Yuhua
    SA UE Register and PDU Setup
	Send And Verify Throuput
	Trigger paging from AMF
	Traffic Should Be OK    ue_id=1    type=sa
	Check Counters    ${PM_Counters_Check_CIT006}
    Check Wireshark Log    ${CURDIR}${/}a2a_CIT006${/}CIT006.ini
    ...    wait_string=UEContextModificationResponse::8
	Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
	Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells

SA UE Register and PDU Setup
    [Arguments]    ${ue_id}=1    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_register id=${ue_id} nwslice=1    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    ${cmd_pdu_regexp}


Verify Throuput
    [Arguments]    ${Tput_dl}=9.5    ${Tput_ul}=9.5    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=10
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=10
    Verify Throuput


Trigger paging from AMF
    Make UE to idle
    Paging from AMF


Make UE to idle
    ${cmd}    Catenate    amf_paging_param id=1 default_drx=256 max_paging_retries=1
    Execute Egate Command    ${cmd}
    ${cmd1}    Catenate    ue_ng_ctx_release id=1 cause=NAS_normal_release
    Execute Egate Command    ${cmd1}    UE Context Release Complete


Paging from AMF
    BuiltIn.Log    Start to paging
    ${cmd}    Catenate    amf_paging_start id=1 ue=1
    Execute Egate Command    ${cmd}    Initial Context Setup Successful


Stop Traffic
    Execute Egate Command    trf_data_stop ue=31    pass_regexp=Traffic was stopped


UE Detach From GNB
    [Arguments]    ${expect_string}=${EMPTY}
    Execute Egate Command  ue_detach id=31    ${expect_string}

Stop Capture Logs And Restore ENV In Test Teardown
    UE Detach From GNB
    Common Test Teardown And Stop Capture Logs
