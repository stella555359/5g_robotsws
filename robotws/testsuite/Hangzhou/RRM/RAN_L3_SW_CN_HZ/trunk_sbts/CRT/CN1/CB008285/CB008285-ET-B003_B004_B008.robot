*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_LO_AP_LO
...            owner-tingjian.mao    team-SGT&A    release-SBTS23R4
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{beamswitch}
...    @{5GC000740_flag}
...    @{paging_para}
...    @{32SSB}
...    @{5GC000732}
...    @{security_algo}

@{5GC000732}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:tWaitingRlRecover=10000ms

@{security_algo}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9

@{32SSB}
...    NRCELL:actBeamforming=true
...    NRCELL:beamSet:basicBeamSet=beamSetAbf_32A
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=32 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1/NRIAFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1:systemInformationTargetRate=251
...    delete:NRCELL:ranAC

@{paging_para}
...    NRBTS:actPaging=true
...    NRBTS:drxDefaultPaging=v256
...    NRCELL-1:numOfPagingFrames=quaterT
...    NRCELL-1:pagingOffset=1
...    NRCELL-1:numPagingOccsnPagingFrame=one
...    NRCELL-1:fPdcchMonOccsnPo=0

@{5GC000740_flag}
...    NRBTS-1:actNgcFlexSaMode=true
...    SERVEDAMF-1:amfIPAddress=10.0.1.1
...    SERVEDAMF-1:administrativeState=Unlocked
...    SERVEDAMF-2:amfIPAddress=10.0.1.102
...    SERVEDAMF-2:administrativeState=Unlocked
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    SNSSAI-1:administrativeState=Unlocked
...    SNSSAI-1:sd=13714341
...    SNSSAI-1:sst=1
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-2:administrativeState=Unlocked
...    SNSSAI-2:sd=13714342
...    SNSSAI-2:sst=1
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-3:administrativeState=Unlocked
...    SNSSAI-3:sd=13714343
...    SNSSAI-3:sst=1
...    SNSSAI-3:nrPlmnDNList=${NRPLMNDNLIST}
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:defaultAMF=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=15min
...    MRBTS-1/NRBTS-1:drbInactivityTimerSA=1500

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1

@{beamswitch}
...    NRCELL:actRrcReconfigAtBeamSwitch=false

${Lock_AMF2}    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Locked
${Unlock_AMF2}    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked

@{AMF1_AMF2_Unlocked}
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:defaultAMF=true
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=true

@{Online_Param}
...    NRCELL-1:numPagingOccsnPagingFrame=two
...    NRCELL-1:fPdcchMonOccsnPo=0,95

@{PM_Counters_B008_1st}
...    NRCELL-1:${AMF_SELECTION_ATT}==1
...    NRCELL-1:${AMF_SELECTION_FAIL}==0
...    NRCELL-1:${AMF_SELECTION_SUCC}==1
@{PM_Counters_B008_2nd}
...    NRCELL-1:${AMF_SELECTION_ATT}==1
...    NRCELL-1:${AMF_SELECTION_FAIL}==0
...    NRCELL-1:${AMF_SELECTION_SUCC}==1
${AMF_SELECTION_ATT}    M55155C00001
${AMF_SELECTION_FAIL}    M55155C00002
${AMF_SELECTION_SUCC}    M55155C00003

@{PM_Counters_Check_B003}
...    NRDU-1:${RRC_REESTAB_RECONF_FAILURE_DU}=1
...    NRCELL-1:${RRC_REESTAB_FALLBACK}=1
...    NRCELL-1:${RRC_REESTAB_RECONF_FAILURE}=1
...    NRCELL-1:${REESTAB_ACC_FALLBACK}=1
...    NRCELL-1:${NRRCC_RRC_STPSUCC_TOT}=1
...    NRDU-1:${REESTAB_ACC_RECONF_FAIL_DU}=0
...    NRCELL-1:${REESTAB_ACC_RECONF_FAIL}=0
${RRC_REESTAB_RECONF_FAILURE_DU}    M55127C00501    #Number of RRC Re-establishment Request caused by reconfiguration failure
${RRC_REESTAB_FALLBACK}             M55124C00502    #Number of fallbacks to RRC Setup procedure during RRC Re-establishment procedure
${RRC_REESTAB_RECONF_FAILURE}       M55124C00503    #Number of RRC Re-establishment Request caused by reconfiguration failure
${REESTAB_ACC_FALLBACK}             M55124C00515    #Number of fallback RRCSetup successful as response to RRCReestablishmentReq
${NRRCC_RRC_STPSUCC_TOT}            M55124C01031    #Number of RRC CONNECTION Attempts that were completed successfully
${REESTAB_ACC_RECONF_FAIL_DU}       M55127C00510    #Number of accepted RRC Re-establishment when reestablishment cause is reconfiguration failure
${REESTAB_ACC_RECONF_FAIL}          M55124C00510    #Number of accepted RRC Re-establishment when reestablishment cause is reconfiguration failure

${ue_id}    1
${pdu_id}    1
${gw_id}    1
${ReconfigurationFailure}     reconfigurationFailure
@{fallback_action}    invalid_short_mac_i    invalid_crnti

@{AMF_Redirect}
...    Initial UE Message Success for AMF Redirect
...    Reauthentication procedure is starting
...    AMF-2: Reauthentication procedure is complete
...    AMF-1.+AMF Redirect successfully
#...    AMF-1: GNB-2: \[NgLink::OnReceiveNamfCommunicationN1MessageNotifyRsp\]::AMF Redirect successfully

*** Test Cases ***
CB008285-ET-B003_5GC000732_ET_D002_RRC_reestablish_with_unknown_C-RNTI_fallback
    [Documentation]
    ...    1. This user scenario describes how to configure a gNB with FR2 SA Cells.
    ...       This user scenario describes the 5GNB behavior.
    ...       if the shortMAC-I is invalid or crnti is unknown during UE re-establish within the same gNB-DU,
    ...       the gNB will response with an RRCSetup in case of RRC reestablishment failure.
    ...    2. Configuration:
    ...       cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...       configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...       rrcReestabTypeSA=sameGNB
    ...    3. Test Case Steps:
    ...       a. UE attached to cell1
    ...       b. Start traffic
    ...       c. Trigger reestablishment(fallback) with invalid shortMAC-I(same old c-RNTI) or unknown C-RNTI (different c-RNTI)
    ...       d. Check traffic is OK(some traffic will drop during fallback, it should be OK if recovered in 5s.)
    ...       e. UE Deregister,check counters
    ...    4. Expected Results:
    ...       a. UE attached to cell1 success
    ...       b. Start traffic is normal
    ...       c. UE reestablishment in the same cell success
    ...       d. Check traffic is OK
    ...       e. UE Deregister,check counters success
    [Tags]    QC_302801    B003
    Clear Counter Files    wait=${False}
    UE Attach To Cell1    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Send and check the Throughput
    Get Random Fallback Action
    Trigger RRC Reestablish with invalid shortMAC-I or invalid crnti    cause=${ReconfigurationFailure}    action=${random_fallback_action}
    Send and check the Throughput
    Check Counters    ${PM_Counters_Check_B003}
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_B003${/}a2a.ini    wait_string=UEContextReleaseComplete::8


CB008285-ET-B004_5GC000733_004_Verify_Frame_slot_pattern_paging_is_successful
    [Documentation]
    ...    1. This user scenario describes how to configure a gNB with FR2 SA Cells.
    ...       This case will include feature 5GC000733.Verify paging occasion for IDLE UE in slot pattern
    ...    2. Configuration:
    ...       cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...       configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...       Configuration need difference in paging_para
    ...    3. Test Case Steps:
    ...      a. After lock AMF2,UE registered, start traffic,make UE to idle
    ...      b. AMF paging
    ...      c. Check paging procedure
    ...      d. Online change numPagingOccsnPagingFrame and fPdcchMonOccsnPo
    ...      e. After UE registered, make UE to idle
    ...      f. AMF paging,Check paging procedure
    ...    4. Expected Results:
    ...      a. lock AMF2 success,then UE registered success and ,normal enter idle state
    ...      b. AMF paging execute success
    ...      c. Check paging procedure success and traffic is also normal
    ...      d. UE Normal deregistration and Online modifying parameters succeeded
    ...      e. AMF paging execute success
    ...      f. Check paging procedure success and traffic is also normal
    [Tags]    QC_302799    B004
    Lock AMF2
    Trigger paging from AMF    paging_before_mo_drx
    Modify DRX value    ${Online_Param}
    Trigger paging from AMF    paging_after_mo_drx
    Unlock AMF2

CB008285-ET-B008_5GC000740_G001_Verify_Successful_AMF_re-allocation_after_old_AMF_be_selected_with_UE_provides_the_5G-S-TMSI
    [Documentation]
    ...    1. This user scenario describes how to configure a gNB with FR2 SA Cells.
    ...       This case is to verify reselection by gnb when UL NAS message received and former amf was locked
    ...    2. Configuration:
    ...       cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...       configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...       Configuration need difference in 5GC000740_flag
    ...    3. Test Case Steps:
    ...       a. Lock AMF2,Ue register to amf1
    ...       b .Unlock AMF2 check counters
    ...       c. UE Exit Idle after redirect
    ...       d. check counters
    ...    4. Expected Results:
    ...       a. Lock AMF2 success,Ue register and ues amf1
    ...       b .Unlock AMF2 success and check counters success
    ...       c. UE Exit Idle after redirect normal process
    ...       d. check counters success
    [Tags]    QC_302796    B008
    clear counter files
    Update AMF Parameters
    Lock AMF2
    SA UE Register and PDU Setup    ue_id=${ue_id}    nwslice=1    cmd_pdu_regexp=AMF-1: Initial Context Setup Successful
    Unlock AMF2
    Check Counters    ${PM_Counters_B008_1st}
    clear counter files
    UE Exit Idle after redirect    ue_id=${ue_id}
    Check Counters    ${PM_Counters_B008_2nd}
    UE Deregister From gNB    ue_id=${ue_id}
    [Teardown]    Test Teardown with AMF Reset

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sa_mmwv/FS/8cells_ecpri

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_n257_FR2}
    Update Cfg    set_amf_region id=1 tac_list=200 plmn=311:489
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=1 set_id=2 pointer=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 ue=all amf=1-2 default=on
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1-2
    Update Cfg    set_nwslice id=3 snssai=0x01:0xd143a7 ue=all amf=1-2
    Update Cfg    amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc
    update cfg    amf_ng_setup_param id=1 relative_capacity=100 include_backup_amf_name=on
    update cfg    amf_ng_setup_param id=2 relative_capacity=100

UE Attach To Cell1
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id}    pass_regexp=QoS Routing Table

Get Random Fallback Action
    ${random_fallback_action}    Evaluate    random.choice(${fallback_action})    random
    Set Test Variable    \${random_fallback_action}

Trigger RRC Reestablish with invalid shortMAC-I or invalid crnti
    [Arguments]    ${cause}    ${action}
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=1 cause=${cause} action=${action}
    ...    pass_regexp=QoS Routing Table    timeout=20s
    Check Specific UE State    ue_id=${ue_id}    state=Active

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached

Send Throughput
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=170 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=170 trf_id=2    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=100 trf_id=1    pass_regexp=Started Uplink
    sleep    10s    sleep for Tput stable

Verify Throughput
    [Arguments]    ${ue_id}    ${pdu_id}    ${Tput_dl}=100    ${Tput_ul}=30    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send and check the Throughput
    Send Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}
    Verify Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}

Check ngLinkStatus Active
    ${params}    create list    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active
    Wait Until Keyword Succeeds    2min    10sec    Object Should Exist    ${params}

Update AMF Parameters
    Delta Commission Parameters    ${AMF1_AMF2_Unlocked}
    Cells Should Be Onair    check_sib=${False}
    Check ngLinkStatus Active
    Execute Egate Command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1,2,3 relative_capacity=50 amfi=1:1:1
    ...    pass_regexp=Received AMF Configuration Acknowledge from GNB-2
    Execute Egate Command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1,2,3 relative_capacity=100 amfi=1:1:2
    ...    pass_regexp=Received AMF Configuration Acknowledge from GNB-2

Lock AMF2
    delta commission parameters    ${Lock_AMF2}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Inactive

Unlock AMF2
    delta commission parameters    ${Unlock_AMF2}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active

SA UE Register and PDU Setup
    [Arguments]    ${ue_id}=1    ${nwslice}=none    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_register id=${ue_id} nwslice=${nwslice}    pass_regexp=NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=${nwslice}    pass_regexp=${cmd_pdu_regexp}

UE Exit Idle after redirect
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_ng_ctx_release id=${ue_id} cause=NAS_normal_release    pass_regexp=IS IDLE
    Execute Egate Command    amf_param id=1 if=rcvd_initial_ue_msg action=redirect:2
    ${ret}    Execute Egate Command    ue_im_exit id=${ue_id}    pass_regexp=${AMF_Redirect}
    sleep    5s    #wait idle mode exit procedure finish

Test Teardown with AMF Reset
    Execute Egate Command    amf_param id=1 reset
    Execute Egate Command    amf_param id=2 reset
    Common Test Teardown And Stop Capture Logs

Trigger paging from AMF
    [Arguments]    ${pcap_name}=paging_before_mo_drx
    start to capture wireshark log    ${pcap_name}
    SA UE Register and PDU Setup    ue_id=${ue_id}    nwslice=1
    Send And Verify Throuput
    Make UE to idle
    Paging from AMF
    Traffic Should Be OK    ue_id=${ue_id}    type=sa
    Check Wireshark Log    ${CURDIR}${/}a2a_B004${/}${pcap_name}.ini    name=${pcap_name}
    ...    wait_string=UEContextModificationResponse::8
    UE Deregister From gNB    ue_id=${ue_id}

Send And Verify Throuput
    Send Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}
    Verify Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}

Make UE to idle
    ${cmd}    Catenate    amf_paging_param id=1 default_drx=256 max_paging_retries=1
    Execute Egate Command    ${cmd}
    ${cmd1}    Catenate    ue_ng_ctx_release id=1 cause=NAS_normal_release
    Execute Egate Command    ${cmd1}    pass_regexp=UE Context Release Complete

Paging from AMF
    BuiltIn.Log    Start to paging
    ${cmd}    Catenate    amf_paging_start id=1 ue=${ue_id}
    Execute Egate Command    ${cmd}    pass_regexp=Initial Context Setup Successful

Modify DRX value
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    cell_id=1
