*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Test Teardown And Recover
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-SG2
...               owner-HuiBo.Miao    release-5G20A
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1:actNgcFlexSaMode=true
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:amfIPAddress=10.0.1.1
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:defaultAMF=true
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:amfIPAddress=10.0.1.102
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=true
...    MRBTS-1/NRBTS-1/SNSSAI-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-1:sd=13714341
...    MRBTS-1/NRBTS-1/SNSSAI-1:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-2:sd=13714342
...    MRBTS-1/NRBTS-1/SNSSAI-2:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/SNSSAI-3:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-3:sd=13714343
...    MRBTS-1/NRBTS-1/SNSSAI-3:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=5min
...    MRBTS-1/NRBTS-1:ngUeRetentionEnabled=false
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=240
...    MRBTS-1/NRBTS-1:srbInactivityTimerSA=600
@{PARAMS_ET_E030}
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:amfIPAddress=10.0.1.103
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:defaultAMF=false
@{PARAMS_Recover}
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:defaultAMF=true
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=true
...    delete:MRBTS-1/NRBTS-1/SERVEDAMF-3
${Lock_AMF1}    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Locked
${Lock_AMF2}    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Locked
${Unlock_AMF2}    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
@{PM_Counters_ET-E017}
...    NRCELL-1:NGCFB:${AMF_SELECTION_ATT}=2
...    NRCELL-1:NGCFB:${AMF_SELECTION_SUCC}=2
@{PM_Counters_ET-E028E029}
...    NRCELL-1:NGCFB:${AMF_RESELECTION_GNB_ATT}=1
...    NRCELL-1:NGCFB:${AMF_RESELECTION_GNB_SUCC}=1
@{PM_Counters_ET-E030}
...    NRCELL-1:NGCFB:${AMF_RESELECTION_GNB_ATT}=1
...    NRCELL-1:NGCFB:${AMF_RESELECTION_GNB_SUCC}=0
${AMF_SELECTION_ATT}    M55155C00001
${AMF_SELECTION_SUCC}    M55155C00003
${AMF_RESELECTION_GNB_ATT}    M55155C00004
${AMF_RESELECTION_GNB_SUCC}    M55155C00006

*** Test Cases ***
5GC000740-ET-E017 Verify_AMF_1_selected_UE_5G-S-TMSI_set_1_Pointer_1
    [Documentation]    Amf1 will be selected as ue with 5G-S-TMSI
    [Tags]    5GC000740-E-ET017    QC_60778
    [Timeout]    60 min
    clear counter files
    Update AMF Parameters ET-E017E029
    Lock AMF2
    Ue Register To AMF1 Without registered_amf Without nwslice And Pdu Setup
    Unlock AMF2
    AMF2 Selected When UE Enter To IDLE And Exit After Inactive AMF1
    check counters    ${PM_Counters_ET-E017}
    release ues    ue_type=all

5GC000740-ET-E028_Verify_AMF_reselection_due_to_NG-C_lock_for_uplink_NGAP_UE-associated_message_with_Backup_AMF
    [Documentation]    This case is to verify reselection by gnb when UL NAS message received and former amf was locked
    [Tags]    5GC000740-E-ET028    QC_60773   
    [Timeout]    60 min
    clear counter files
    Update AMF Parameters ET-E028
    Lock AMF2
    Ue Register To AMF1 Without registered_amf Without nwslice And Pdu Setup
    Unlock AMF2
    Lock AMF1 And Reselect AMF2 By PduSessionModification
    check counters    ${PM_Counters_ET-E028E029}
    release ues    ue_type=all

5GC000740-ET-E029_Verify_AMF_reselection_as_NG-C_sctp_failure_for_UL_NG_UE-associated_message_to_send_when_UE_GUAMI_is_not_served_in_other_AMF
    [Documentation]    This case is to verify reselection by gnb when UL NAS message received and former amf was inactive
    [Tags]    5GC000740-E-ET029    QC_60777
    [Timeout]    60 min
    clear counter files
    Update AMF Parameters ET-E017E029
    Ue Register To AMF1 With registered_amf With nwslice And Pdu Setup
    Inactive AMF1 And Reselect AMF2 By PduSessionModification
    check counters    ${PM_Counters_ET-E028E029}
    release ues    ue_type=all

5GC000740-ET-E030_Verify_AMF_reselection_trigger_by_SCTP_fail_fail_for_uplink_NGAP_UE-associated_message_to_send_when_Backup_AMF_link_locked
    [Documentation]    This case is to verify reselection failure due to backup AMF locked and main amf got down.
    ...    requirement:5G_RAN_USR_13563,3 amf needed.
    [Tags]    5GC000740-E-ET030    QC_60776
    [Timeout]    60 min
    Precondition    ${PARAMS_ET_E030}
    clear counter files
    Update AMF Parameters ET-E030
    Check BackupAMF
    Ue Register To AMF1 With registered_amf With nwslice And Pdu Setup
    Inactive AMF1 And Lock AMF2
    2nd PDU Session Setup Failed
    check counters    ${PM_Counters_ET-E030}
    release ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    ${match_string}    Create List    AMF-1: AMF - IP:10.0.1.2 NG link is Up    AMF-2: AMF - IP:10.0.1.2 NG link is Up
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    match_string=${match_string}
#    Debug Enter Into Egate

Modify Cfg
    update cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=2 name=SimModeAMF1
    update cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=2 set_id=2 pointer=2 name=SimModeAMF2
    update cfg    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.1.103:38412 region=3 set_id=2 pointer=2 name=SimModeAMF3
    update cfg    amf_ng_setup_param id=1 relative_capacity=100 include_backup_amf_name=on
    update cfg    amf_ng_setup_param id=2 relative_capacity=100
    update cfg    set_qosflow id=2 5qi=6 default=off
    update cfg    set_backup_amf main=1 backup_amfs=2

Test Teardown And Recover
    delta commission parameters    ${PARAMS_Recover}
    Common Test Teardown And Stop Capture Logs

Precondition
    [Arguments]    ${delta_params}
    delta commission parameters    ${delta_params}

Make Sure AMF Active
    [Documentation]    sctpWaitTimeInitSeqRetry=240s,sctp reinitialize will start at 4mins after AMF inactive
    wait until keyword succeeds    5 min    5 sec        object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    wait until keyword succeeds    5 min    5 sec        object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active

Update AMF Parameters ET-E017E029
    Make Sure AMF Active
    execute egate command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1,2,3 relative_capacity=50 amfi=1:1:1 backup_amfs=2
    ...    AMF-1.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1,2,3 relative_capacity=100 amfi=1:1:2
    ...    AMF-2.*Received AMF Configuration Acknowledge from GNB-2

Update AMF Parameters ET-E028
    Make Sure AMF Active
    execute egate command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1,2,3 relative_capacity=50 amfi=1:1:1 backup_amfs=2
    ...    AMF-1.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1,2,3 relative_capacity=100 amfi=1:1:1
    ...    AMF-2.*Received AMF Configuration Acknowledge from GNB-2

Update AMF Parameters ET-E030
    Make Sure AMF Active
    execute egate command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1,2,3 relative_capacity=50 amfi=1:1:1 backup_amfs=2
    ...    AMF-1.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1,2,3 relative_capacity=100 amfi=1:2:1
    ...    AMF-2.*Received AMF Configuration Acknowledge from GNB-2

Lock AMF1
    delta commission parameters    ${Lock_AMF1}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Inactive
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active

Lock AMF2
    delta commission parameters    ${Lock_AMF2}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Inactive

Unlock AMF2
    delta commission parameters    ${Unlock_AMF2}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active

Set Registered AMF To Ue
    [Arguments]    ${ue_id}=1    ${registered_amf}=${EMPTY}
    execute egate command    ue_nr_rrc_param_setup id=${ue_id} registered_amf=${registered_amf}

Register Ue With nwslice
    [Arguments]    ${ue_id}=1    ${nwslice}=${EMPTY}    ${pass_regexp}=NG RM Registered
    execute egate command    ue_register id=${ue_id} nwslice=${nwslice}    pass_regexp=${pass_regexp}

Register Ue Without nwslice
    [Arguments]    ${ue_id}=1    ${pass_regexp}=NG RM Registered
    execute egate command    ue_register id=${ue_id}    pass_regexp=${pass_regexp}

Setup PDU Session
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1    ${pass_regexp}=${EMPTY}
    execute egate command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    execute egate command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${gw}    ${pass_regexp}

Ue Register To AMF1 Without registered_amf Without nwslice And Pdu Setup
    Set Registered AMF To Ue    registered_amf=none
    Register Ue Without nwslice
    Setup PDU Session    pass_regexp=AMF-1: Initial Context Setup Successful

Ue Register To AMF1 With registered_amf With nwslice And Pdu Setup
    Set Registered AMF To Ue    registered_amf=311:489|1:1:1
    Register Ue With nwslice    nwslice=1,2,3
    Setup PDU Session    pass_regexp=AMF-1: Initial Context Setup Successful

UE Enter To IDLE
    execute egate command    ue_ng_ctx_release id=1 cause=NAS_normal_release    UE1: IS IDLE

UE Exit IDLE
    [Arguments]    ${pass_regexp}
    execute egate command    ue_im_exit id=1    ${pass_regexp}

Inactive AMF1
    execute egate command    link_drop link=ng by=amf:1 to=gnb:2 msg_type=shutdown    All NG links are down
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Inactive

AMF2 Selected When UE Enter To IDLE And Exit After Inactive AMF1
    UE Enter To IDLE
    Inactive AMF1
    UE Exit IDLE    AMF-2: Initial Context Setup Successful

Lock AMF1 And Reselect AMF2 By PduSessionModification
    stop capture wireshark log
    start to capture wireshark log    reselection
    Lock AMF1
    execute egate command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=ue
    ...    AMF-2: GNB-2:.*Pdu Session Resource Modify Response.*handled successfully
    Check WireShark Log    a2a_ini_file=${CURDIR}${/}A2A_ET-E028029${/}a2a.ini    name=reselection    wait_string=UEContextModificationResponse::3

Inactive AMF1 And Reselect AMF2 By PduSessionModification
    stop capture wireshark log
    start to capture wireshark log    reselection
    Inactive AMF1
    execute egate command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=ue
    ...    AMF-2: GNB-2:.*Pdu Session Resource Modify Response.*handled successfully
    Check WireShark Log    a2a_ini_file=${CURDIR}${/}A2A_ET-E028029${/}a2a.ini    name=reselection    wait_string=UEContextModificationResponse::3

Inactive AMF1 And Lock AMF2
    execute egate command    link_drop link=ng by=amf:1 to=gnb:2 msg_type=shutdown    All NG links are down
    delta commission parameters    ${Lock_AMF2}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Inactive
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Inactive

Check BackupAMF
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:guAMI:backupAmfName=SimModeAMF2

2nd PDU Session Setup Failed
    stop capture wireshark log
    start to capture wireshark log    reselection
    execute egate command    set_pdu_param ue=1 pdu=2 trf_type=internal
    ${return}=    execute egate command    ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=2    UE1: IS IDLE
    should not contain    ${return}    PDU Session Establishment Request
    Check WireShark Log    a2a_ini_file=${CURDIR}${/}A2A_ET-E030${/}a2a.ini    name=reselection    wait_string=UEContextReleaseComplete::1

