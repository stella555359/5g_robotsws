*** Settings ***
Suite Setup     Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup      Common Test Setup And Start To Capture Logs
Test Teardown   Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CIT  team-SG2    5GC000733
...    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD    CDRT  release-SBTS19A    owner-dan.liu    5GC002478

Resource        ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1:actNgcFlexSaMode=true
...    MRBTS-1/NRBTS-1:gNbCuType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1:ngUeRetentionEnabled=true
...    MRBTS-1/NRBTS-1:waitForRecovBeforeCellBarringTimer=30
...    MRBTS-1/NRBTS-1:ngInducedCellDeactDelayTimer=60
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=239
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:configuredEpsTac
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:amfIPAddress=10.0.1.9
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=true
...    MRBTS-1/NRBTS-1:ngUeRetentionTmr=300
...    @{modify_relation_error}
@{modify_relation_error}
...    MRBTS-1/NRBTS-1/NRCELL-2:cellDepType=SA
...    delete:MRBTS-1/NRBTS-1/NRCELL-2:configuredEpsTac
@{Delete_Useless_Cell}
...    delete:MRBTS-1/NRBTS-1/NRCELL-2
...    delete:MRBTS-1/NRBTS-1/NRCELLGRP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
...    NRDU-1:refNrCellGroup=0
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs
@{Lock_one_AMF}
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Locked
${Update_Cfg_1}    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.2 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x1:22
...    daemon=10.0.2.1:22222 xn=10.0.1.2 x2_peers=none amf=1-2
${Update_Cfg_2}    set_cell id=1 gnb=2 tac=788 nrci=0x01 eci=0x000021f tdd_cell=off
...    proxy=10.0.2.80:9999|10.0.2.80:8888 nr_arfcn=135760:126380 gscn=1579 mandatory_for_activation=off
${Update_Cfg_3}    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.9:38412 region=2 set_id=2 pointer=2

${NNGCC_PDUSESMODREQ_RECD}    M55125C03501==1
@{PM_Counters_Check_CIT006}
...    ${NF1CD_F1AP_PAGING_RECD}=1
...    ${NNGCB_NGAP_PAGING_RECD}=1
...    ${NRPAG_PAGING_SUCC_SENT}=1
...    ${NRRCD_RRC_STPREQ_MT_ACCESS}=1
...    ${NRRCC_RRC_STPREQ_MT_ACCESS}=1
...    ${NRRCC_RRC_STPSUCC_TOT}=3 
${NF1CD_F1AP_PAGING_RECD}    M55117C03001    #Number of F1AP Paging message received at gNB-DU
${NNGCB_NGAP_PAGING_RECD}    M55119C01501    #Number of NGAP Paging message received at gNB-CU-CP
${NRPAG_PAGING_SUCC_SENT}    M55331C00001    #Number of RRC Paging message successfully broadcasted
${NRRCD_RRC_STPREQ_MT_ACCESS}    M55127C00003    #Number of RRC CONNECTION Attempts for Mobile Terminated Access,gNB-CU
${NRRCC_RRC_STPREQ_MT_ACCESS}    M55124C01003    #Number of RRC CONNECTION Attempts for Mobile Terminated Access,gNB-DU
${NRRCC_RRC_STPSUCC_TOT}    M55124C01031    #Number of RRC CONNECTION Attempts that were completed successfully

*** Test Cases ***
5GSW-CP-CIT009-CIT006_Verify_Classical_SA_FDD_cmWave_L3_call_setup_when_NGLink_be_locked_and_cell_remains_active_is_successful_including_paging_step
    #---------------------------------------------------------------------------------------------------
    [Documentation]
    ...    it will cover case 5GC002478-B001 and 5GC002478-B006
    ...    lock NG link1, the gNB and cell still is onair, Ue should not released
    ...    NG link2 is SCTP failre, gNB is onair and cell is unbarred before ngInducedCellDeactDelayTimer time out, when
    ...    ngInducedCellDeactDelayTimer time out, GNB state is change to Configured, cell state is change to "Offline,Disabled,unbarred"
    ...    and UE is release, in the meantime alarm 7304 NG SCTP endpoint broken is raise; when sctpWaitTimeInitSeqRetry time is out,
    ...    NGLINK2 will be recover, cell and gNB will be onair, make UE to idle and do AMF paging, checking alarm 7304 is clear

    [Tags]    QC_61697
    Precondition for case B001    
    While Lock NG LINK1 then gNB still onair And UE not released
    Set SCTP failure on NGlink2 and check
    Wait and check result for SCTP on link2
    UE L3 call sccessful
	Send And Verify Throuput
	Trigger paging from AMF
	Traffic Should Be OK    ue_id=1    type=sa
	Check Counters    ${PM_Counters_Check_CIT006}
    UE Deregister From GNB
    check wireshark log    ${CURDIR}${/}a2a_CIT009${/}a2a.ini    wait_string=GNBCUConfigurationUpdateAcknowledge::6    

*** Keywords ***
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
    ${cmd}    Catenate    amf_paging_param id=2 default_drx=256 max_paging_retries=1
    Execute Egate Command    ${cmd}
    ${cmd1}    Catenate    ue_ng_ctx_release id=1 cause=NAS_normal_release
    Execute Egate Command    ${cmd1}    UE Context Release Complete

Paging from AMF
    BuiltIn.Log    Start to paging
    ${cmd}    Catenate    amf_paging_start id=2 ue=1
    Execute Egate Command    ${cmd}    Initial Context Setup Successful

Stop Traffic
    Execute Egate Command    trf_data_stop ue=31    pass_regexp=Traffic was stopped

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells    ue_count=10
    Comment    Debug Enter Into Egate

Modify Cfg
    Update Cfg    ${Update_Cfg_1}
    Update Cfg    ${Update_Cfg_2}
    Update Cfg    ${Update_Cfg_3}
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1-2
    Update Cfg    amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489
    Update Cfg    set_amf_region id=2 tac_list=7627107,100,788,200,0 plmn=311:489
    Update Cfg    set_backup_amf main=1 backup_amfs=2
    update cfg    amf_ng_setup_param id=1 relative_capacity=100 include_backup_amf_name=off
    update cfg    amf_ng_setup_param id=2 relative_capacity=100

While Lock NG LINK1 then gNB still onair And UE not released
    UE L3 call sccessful
    traffic should be ok   ue_id=1    type=SA
    Lock NG link1 and check
#    check result for lock NG link1 

Precondition for case B001
    delta commission parameters    ${Delete_Useless_Cell}
    Check cell state as expected    operationalState=enabled    barringStatus=unbarred
    
Check cell state as expected
    [Arguments]    ${operationalState}    ${barringStatus}
    Object Should Exist    NRCELL-1:operationalState=${operationalState}
    Object Should Exist    NRCELL-1:barringStatus=${barringStatus}
UE L3 call sccessful
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    Initial Context Setup Successful
Lock NG link1 and check
    Check BTS state
    delta commission parameters    ${Lock_one_AMF}
    Check BTS state
    Object Should Exist    SERVEDAMF-1:ngLinkStatus=Inactive
    Check cell state as expected    operationalState=enabled    barringStatus=unbarred
    Wait to check UE state
    UE should not be released

Check BTS state
    [Arguments]    ${blockingState}=Unblocked    ${operationalState}=onAir
    Object Should Exist    NRBTS:blockingState=${blockingState}
    Object Should Exist    NRBTS:operationalState=${operationalState}
Set SCTP failure on NGlink2 and check
    Execute Egate Command    link_drop link=ng by=amf:2 to=gnb:2 msg_type=abort    pass_regexp=NG Link Drop
    Object Should Exist    NRBTS:operationalState=onAir
    Object Should Exist    SERVEDAMF-2:ngLinkStatus=Inactive
    Wait for CellBarringTimer expires      # needed?
    Check cell state as expected    operationalState=enabled    barringStatus=barred
    Wait for CellDeactDelayTimer expires
    Object Should Exist    NRBTS:operationalState=configured
    UE should be released
    Check cell state as expected    operationalState=disabled    barringStatus=unbarred
    Check Alarm 7304 Raised
Wait and check result for SCTP on link2
    Wait for SCTP recover on link2
    Object Should Exist    SERVEDAMF-2:ngLinkStatus=Active
    Check cell state as expected    operationalState=enabled    barringStatus=unbarred
    Object Should Exist    NRBTS:operationalState=onAir
    Check 7304 Alarm Cleared
    
UE Deregister From GNB
  [Arguments]    ${ue_id}=1
  Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached

Wait for CellBarringTimer expires
    sleep    30

Wait for CellDeactDelayTimer expires
    sleep    60

Wait for SCTP recover on link2
    sleep    120

Wait to check UE state
    sleep    5

Check Alarm 7304 Raised
    ${fault7304}    create list    fault_id=7304
    fm fault should be raised    ${fault7304}

UE should not be released
    execute egate command    ue_disp id=1 state=ACTIVE     pass_regexp=ACTIVE

UE should be released
    execute egate command    ue_disp id=1 state=OFF     pass_regexp=OFF

Check 7304 Alarm Cleared
    ${fault}    Create List
    ...    fault_id=7304    severity=Critical   fault_name=NG SCTP endpoint broken
    ...    alarm_id=7107    alarm_name=BASE STATION CONNECTIVITY PROBLEM
    Fm Fault Should Be Cleared    ${fault}
