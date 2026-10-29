*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Stop Capture Logs And Restore ENV In Test Teardown
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-DevHZ5_SG2    owner-yuhua.zhu    release-5G19B     5GC000733
Resource  ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${UTE_WIRESHARK_FLAG}  ${False}
@{PARAMS_IN_SCF}    @{feature_flag}    @{paging_para}
@{feature_flag}
...    NRBTS:actPaging=true

@{paging_para}
...    NRBTS:drxDefaultPaging=v256
...    BWP_PROFILE-5/PDCCH-1:dciPagingAggregationLevel=AL4
...    BWP_PROFILE-54/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRCELL-1:numOfPagingFrames=halfT
...    NRCELL-1:pagingOffset=1
...    NRCELL-1:numPagingOccsnPagingFrame=two
...    NRCELL-1:prachConfigurationIndex=98
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-1:fPdcchMonOccsnPo=0,2
${BTS_STARTUP_RETRY}    4
@{OnlineParam}
...    NRBTS:drxDefaultPaging=v32
...    NRCELL-1:numOfPagingFrames=quaterT
...    NRCELL-1:numPagingOccsnPagingFrame=one
...    NRCELL-1:fPdcchMonOccsnPo=0


*** Test Cases ***
5GC000733_001 Verify Frame slot pattern 1208 paging is successful
    [Documentation]
    ...    This case will include feature 5GC000733.Verify paging occasion for IDLE UE in single beam for 1208 slot pattern
    ...    Configured 1208 slot with 0ms
    ...    After UE registered, make UE to idle
    ...    AMF paging
    ...    Check paging procedure
    ...    Online change DRX,numOfPagingFrames,numPagingOccsnPagingFrame and fPdcchMonOccsnPo 
    ...    After UE registered, make UE to idle
    ...    AMF paging
    [Tags]    QC_132610    Zhu Yuhua
    Trigger paging from AMF    paging_before_mo_drx
	Modify DRX value from v256 to v32    ${Online_Param}
	Trigger paging from AMF    paging_after_mo_drx


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
	Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri
	
Trigger paging from AMF
    [Arguments]    ${pcap_name}=paging_before_mo_drx
    start to capture wireshark log    ${pcap_name}
    SA UE Register and PDU Setup
	Send And Verify Throuput
	Make UE to idle
    Paging from AMF
	Traffic Should Be OK    ue_id=1    type=sa
    Check Wireshark Log    ${CURDIR}${/}a2a_733_001${/}${pcap_name}.ini    name=${pcap_name}
    ...    wait_string=UEContextModificationResponse::8
    Release Ues    ue_type=all

SA UE Register and PDU Setup
    [Arguments]    ${ue_id}=1    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_register id=${ue_id} nwslice=1    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    ${cmd_pdu_regexp}


Verify Throuput
    [Arguments]    ${Tput_dl}=9.5    ${Tput_ul}=9.5    ${sleep_time}=10s
    sleep    ${sleep_time}    #sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=10
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=10
    Verify Throuput


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

Modify DRX value from v256 to v32
    [Arguments]  ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
	Cells Should Be Onair
