*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN  QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-SG2
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
@{PARAMS_ET-E016E023}
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:defaultAMF=true
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=true
@{PARAMS_ET-E037}
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:defaultAMF=true
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=false
${Lock_AMF2}    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Locked
${Unlock_AMF2}    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
@{PM_Counters_ET-E023}
...    NRCELL-1:NGCFB:${AMF_SELECTION_ATT}=10
...    NRCELL-1:NGCFB:${AMF_SELECTION_SUCC}=10
@{PM_Counters_ET-E037}
...    NRCELL-1:NGCFB:${AMF_RESELECTION_5GC_RCV}=1
@{PM_Counters_ET-E016}
...    NRCELL-1:NGCFB:${AMF_SELECTION_ATT}=2
...    NRCELL-1:NGCFB:${AMF_SELECTION_SUCC}=2
${AMF_SELECTION_ATT}    M55155C00001
${AMF_SELECTION_SUCC}    M55155C00003
${AMF_RESELECTION_5GC_RCV}    M55155C00007

*** Test Cases ***
5GC000740-ET-E023_Verify_AMF_2_more_likely_selected_with_only_registeredAMF_for_AMF1_and_the_same_guami_and_different_AMF_capacity
    [Documentation]    This case is to verify 
    ...    precondition: amfi(GUAMI) change from 1:1:1 to 2:1:1 for AMF2 due to PR620033
    ...    checking1: the amf which has larger capacity has more chance to be selected.
    ...    checking2 for 02335496:
    ...              Gnb-2 connected with 2 amf: amf-1 (1,1,1) -RC=0 unlock; amf-2 (2,1,1,)-RC=100 unlock
    ...              the selected PLMN is same as PLMN  in registeredAMF (311,489 already set in config)
    ...              Ue-1 attached with registeredAMF[311,489,1,1,1]  
    ...              when UE attach with RegirsterAMF, gnb should select amf using [plmn + regionID + setID + pointer] firstly
    ...              result: AMF-1 is selected even RC=0
    [Tags]    5GC000740-E-ET023    QC_60765    CRT
    [Timeout]    60 min
    Precondition    ${PARAMS_ET-E016E023}
    clear counter files
    Update AMF Parameters ET-E023
    Register UE Repeatly And Compare
    check counters    ${PM_Counters_ET-E023}
    Update AMF Parameters ET-02335496
    Set Registered AMF To Ue    registered_amf=311:489|1:1:1
    Select AMF-1 since firstly using regionID setID pointer even rc is 0 when attach with RegirsterAMF

5GC000740-ET-E037_Verify_AMF_reselection_by_DL_NG_UE-associated_message_receipt-Connected_UE_Reselection_is_accepted
    [Documentation]    This case is to verify gnb accept DL NAS from different AMF for AMF reselection.
    [Tags]    5GC000740-E-ET037    QC_60774
    [Timeout]    60 min
    Precondition    ${PARAMS_ET-E037}
    clear counter files
    Update AMF Parameters ET-E037
    Ue Register To AMF1 With registered_amf With nwslice And Pdu Setup
    Inactive AMF1 And Reselect AMF2 By UEContextModification
    release ues    ue_type=all
    Check WireShark Log    a2a_ini_file=${CURDIR}${/}A2A_ET-E037${/}a2a.ini    wait_string=UEContextReleaseComplete::1
    check counters    ${PM_Counters_ET-E037}

5GC000740-ET-E016_Verify_AMF_1_selected_UE_5G-S-TMSI_set_1_Pointer_1
    [Tags]    5GC000740-E-ET016    QC_60766
    [Timeout]    60 min
    Precondition    ${PARAMS_ET-E016E023}
    clear counter files
    Update AMF Parameters ET-E016
    Lock AMF2
    Ue Register To AMF1 Without registered_amf Without nwslice And Pdu Setup
    Unlock AMF2
    AMF1 Selected When UE Enter To IDLE And Exit
    release ues    ue_type=all
    check counters    ${PM_Counters_ET-E016}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    ${match_string}    Create List    AMF-1: AMF - IP:10.0.1.2 NG link is Up    AMF-2: AMF - IP:10.0.1.2 NG link is Up
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    match_string=${match_string}
#    Debug Enter Into Egate

Modify Cfg
    update cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=1 name=SimModeAMF1
    update cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=2 set_id=2 pointer=1 name=SimModeAMF2
    update cfg    amf_ng_setup_param id=1 relative_capacity=50 include_backup_amf_name=off
    update cfg    amf_ng_setup_param id=2 relative_capacity=100

Precondition
    [Arguments]    ${params}
    delta commission parameters    ${params}

Make Sure AMF Active
    [Documentation]    sctpWaitTimeInitSeqRetry=240s,sctp reinitialize will start at 4mins after AMF inactive
    wait until keyword succeeds    5 min    5 sec        object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    wait until keyword succeeds    5 min    5 sec        object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active

Update AMF Parameters ET-02335496
    Make Sure AMF Active
    execute egate command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1,2,3 relative_capacity=0 amfi=1:1:1
    ...    AMF-1.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1,2,3 relative_capacity=100 amfi=2:1:1
    ...    AMF-2.*Received AMF Configuration Acknowledge from GNB-2

Update AMF Parameters ET-E023
    Make Sure AMF Active
    execute egate command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1,2,3 relative_capacity=10 amfi=1:1:1
    ...    AMF-1.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1,2,3 relative_capacity=100 amfi=2:1:1
    ...    AMF-2.*Received AMF Configuration Acknowledge from GNB-2

Update AMF Parameters ET-E037
    Make Sure AMF Active
    execute egate command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1,2,3 relative_capacity=50 amfi=1:1:1
    ...    AMF-1.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1,2,3 relative_capacity=100 amfi=1:2:1
    ...    AMF-2.*Received AMF Configuration Acknowledge from GNB-2

Update AMF Parameters ET-E016
    Make Sure AMF Active
    execute egate command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1,2,3 relative_capacity=50 amfi=1:1:1
    ...    AMF-1.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1,2,3 relative_capacity=100 amfi=1:1:2
    ...    AMF-2.*Received AMF Configuration Acknowledge from GNB-2

Select AMF-1 since firstly using regionID setID pointer even rc is 0 when attach with RegirsterAMF
    execute egate command    ue_register id=1    AMF-1: INITIAL UE MESSAGE

Register UE Repeatly And Compare
    [Arguments]    ${ue_id}=1    ${register_times}=10
    set test variable    ${AMF1_count}    0
    set test variable    ${AMF2_count}    0
    FOR    ${index}    IN RANGE    ${register_times}
        ${return}=    execute egate command    ue_register id=${ue_id}    NG RM Registered
        ${return}=    Remove String    ${return}    \n    \r
        ${AMF1_count}=    evaluate    ${AMF1_count} + "${return}".count('AMF-1: INITIAL UE MESSAGE')
        ${AMF2_count}=    evaluate    ${AMF2_count} + "${return}".count('AMF-2: INITIAL UE MESSAGE')
        execute egate command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE Context Release Complete
    END
    should be true    ${AMF1_count} < ${AMF2_count}
    should be true    ${${AMF1_count}+${AMF2_count}} == 10

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

Ue Register To AMF1 With registered_amf With nwslice And Pdu Setup
    Set Registered AMF To Ue    registered_amf=311:489|1:1:1
    Register Ue With nwslice    nwslice=1,2,3
    Setup PDU Session    pass_regexp=AMF-1: Initial Context Setup Successful

Ue Register To AMF1 Without registered_amf Without nwslice And Pdu Setup
    Set Registered AMF To Ue    registered_amf=none
    Register Ue Without nwslice
    Setup PDU Session    pass_regexp=AMF-1: Initial Context Setup Successful

Inactive AMF1 And Reselect AMF2 By UEContextModification
    traffic should be ok    type=sa
    execute egate command    link_drop link=ng by=amf:1 to=gnb:2 msg_type=shutdown    All NG links are down
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Inactive
    traffic should be ok    type=sa
    execute egate command    ue_ctx_ng_mod id=1 guami_index=0 new_amf_ue_id=off    AMF-2.*Received UE Context Modification Response

Lock AMF2
    delta commission parameters    ${Lock_AMF2}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Inactive

Unlock AMF2
    delta commission parameters    ${Unlock_AMF2}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active

AMF1 Selected When UE Enter To IDLE And Exit
    execute egate command    ue_ng_ctx_release id=1 cause=NAS_normal_release    UE1: IS IDLE
    execute egate command    ue_im_exit id=1    AMF-1: Initial Context Setup Successful
