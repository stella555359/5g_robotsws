*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-SG2
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
@{Lock_AMF2}
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Locked
@{Unlock_AMF2}
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
@{PM_Counters_ET-G006}
...    NRCELL-1:NNGCC:${NNGCC_REROUTE_NAS_REQ_RECD}=1
${NNGCC_REROUTE_NAS_REQ_RECD}    M55125C04501

*** Test Cases ***
5GC000740-ET-G006_Verify_Unsuccessful_AMF_re-allocation_via_RAN_due_to_reroute_AMF_NG-LINK_down
    [Tags]    5GC000740-ET-G006    QC_60781
    [Timeout]    60 min
    clear counter files
    Update AMF Parameters ET-G006
    Lock AMF2
    Ue Register To AMF1 Without registered_amf With nwslice And Pdu Setup
    traffic should be ok    type=sa
    Unlock AMF2
    AMF1 Re-allocation To AMF2 Unsuccessful
    check counters    ${PM_Counters_ET-G006}
    release ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    ${match_string}    Create List    AMF-1: AMF - IP:10.0.1.2 NG link is Up    AMF-2: AMF - IP:10.0.1.2 NG link is Up
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    match_string=${match_string}
    execute egate command    sim_trace amf=1,2 protocol=ng on

Make Sure AMF Active
    [Documentation]    sctpWaitTimeInitSeqRetry=240s,sctp reinitialize will start at 4mins after AMF inactive
    wait until keyword succeeds    5 min    5 sec        object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    wait until keyword succeeds    5 min    5 sec        object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active

Update AMF Parameters ET-G006
    Make Sure AMF Active
    execute egate command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1,2,3 relative_capacity=50 amfi=1:1:1
    ...    AMF-1.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1,2,3 relative_capacity=100 amfi=1:2:2
    ...    AMF-2.*Received AMF Configuration Acknowledge from GNB-2
    Make Sure AMF Active

Lock AMF2
    delta commission parameters    ${Lock_AMF2}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Inactive

Unlock AMF2
    delta commission parameters    ${Unlock_AMF2}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active

Set Registered AMF To Ue
    [Arguments]    ${ue_id}=1    ${registered_amf}=${EMPTY}
    execute egate command    ue_nr_rrc_param_setup id=${ue_id} registered_amf=${registered_amf}

Register Ue With nwslice
    [Arguments]    ${ue_id}=1    ${nwslice}=${EMPTY}    ${pass_regexp}=NG RM Registered
    execute egate command    ue_register id=${ue_id} nwslice=${nwslice}    pass_regexp=${pass_regexp}

Setup PDU Session
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1    ${pass_regexp}=${EMPTY}
    execute egate command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    execute egate command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${gw}    ${pass_regexp}

Ue Register To AMF1 Without registered_amf With nwslice And Pdu Setup
    Set Registered AMF To Ue    registered_amf=none
    Register Ue With nwslice    nwslice=1,2,3
    Setup PDU Session    pass_regexp=AMF-1: Initial Context Setup Successful

Ue Enter To IDLE
    execute egate command    ue_ng_ctx_release id=1 cause=NAS_normal_release    UE1: IS IDLE

Inactive AMF2
    execute egate command    link_drop link=ng by=amf:2 to=gnb:2 msg_type=shutdown    All NG links are down
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Inactive

AMF1 Re-allocation To AMF2 Unsuccessful
    Ue Enter To IDLE
    execute egate command    amf_param id=1 if=rcvd_initial_ue_msg action=reroute:2
    Inactive AMF2
    ${return}=    execute egate command    ue_im_exit id=1    RrcRelease is received
    should contain    ${return}    AMF-1: INITIAL UE MESSAGE
    should contain    ${return}    AMF-1: Start AMF reroute to AMF 2