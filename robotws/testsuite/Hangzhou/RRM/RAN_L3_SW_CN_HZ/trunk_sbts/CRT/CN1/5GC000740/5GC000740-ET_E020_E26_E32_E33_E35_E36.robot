*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Test Teardown And Recover
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-SG2
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
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:amfIPAddress=10.0.1.103
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:defaultAMF=true
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
@{PARAMS_Recover}
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:defaultAMF=true
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=true
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:defaultAMF=true
@{PARAMS_E032E035}
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:defaultAMF=true
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=false
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:defaultAMF=false
@{PARAMS_E033E036}
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:defaultAMF=true
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=true
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:defaultAMF=false
@{Lock_AMF1}
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Locked
@{Lock_AMF2}
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Locked
@{Lock_AMF3}
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:administrativeState=Locked
@{Unlock_AMF1}
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked
@{Unlock_AMF2}
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
@{Unlock_AMF3}
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:administrativeState=Unlocked
@{PM_Counters_ET-E020}
...    NRCELL-1:NGCFB:${AMF_SELECTION_ATT}=2
...    NRCELL-1:NGCFB:${AMF_SELECTION_FAIL}=1
...    NRCELL-1:NGCFB:${AMF_SELECTION_SUCC}=1
@{PM_Counters_ET-E032E033}
...    NRCELL-1:NGCFB:${AMF_RESELECTION_GNB_ATT}=1
...    NRCELL-1:NGCFB:${AMF_RESELECTION_GNB_FAIL}=0
...    NRCELL-1:NGCFB:${AMF_RESELECTION_GNB_SUCC}=1
@{PM_Counters_ET-E036}
...    NRCELL-1:NGCFB:${AMF_RESELECTION_GNB_ATT}=1
...    NRCELL-1:NGCFB:${AMF_RESELECTION_GNB_FAIL}=1
...    NRCELL-1:NGCFB:${AMF_RESELECTION_GNB_SUCC}=0
@{PM_Counters_ET-E026}
...    NRCELL-1:NGCFB:${AMF_SELECTION_ATT}=20
...    NRCELL-1:NGCFB:${AMF_SELECTION_SUCC}=20
${AMF_SELECTION_ATT}    M55155C00001
${AMF_SELECTION_FAIL}    M55155C00002
${AMF_SELECTION_SUCC}    M55155C00003
${AMF_RESELECTION_GNB_ATT}    M55155C00004
${AMF_RESELECTION_GNB_FAIL}    M55155C00005
${AMF_RESELECTION_GNB_SUCC}    M55155C00006

*** Test Cases ***
5GC000740-ET-E020_Verify_no_AMF_selected when no backupAMF_UE_5G-S-TMSI_set_1_Pointer_1
    [Documentation]    This case is to verify no amf will be selected when amf1 inactive, caps of amf2 and amf3 are 0
    [Tags]    5GC000740-E-ET020    QC_60770
    [Timeout]    60 min
    clear counter files
    Update AMF Parameters ET-E020
    Ue Register To AMF1 Without registered_amf Without nwslice And Pdu Setup
    Ue Enter To IDLE
    Inactive AMF1
    Ue Exit IDLE Failed
    check counters    ${PM_Counters_ET-E020}
    release ues    ue_type=all

5GC000740-ET-E032_Verify_AMF_reselection_for_uplink_NGAP_UE-associated_message_to_send_based_on_the_UE_GUAMI
    [Documentation]    This case is to verify amf2 will be reselected when amf1 inactive based on guami
    [Tags]    5GC000740-E-ET032    QC_60772
    [Timeout]    60 min
    clear counter files
    Precondition    ${PARAMS_E032E035}
    Update AMF Parameters ET-E032
    Set ue_retention For AMFs    id=1,2
    Ue Register To AMF1 Without registered_amf Without nwslice And Pdu Setup
    Inactive AMF1
    AMF2 Selected When Setup 2nd PDU Session
    check counters    ${PM_Counters_ET-E032E033}
    release ues    ue_type=all

5GC000740-ET-E033_Verify_AMF_reselection_for_uplink_NGAP_UE-associated_message_to_send_based_on_the_UE_GUAMI_NSSAI
    [Documentation]    This case is to verify amf3 will be reselected when amf1 inactive, amf2 locked based on slice
    [Tags]    5GC000740-E-ET033    QC_60769    
    [Timeout]    60 min
    clear counter files
    Precondition    ${PARAMS_E033E036}
    Update AMF Parameters ET-E033
    Set ue_retention For AMFs    id=1,2,3
    Lock AMF2 AMF3
    Ue Register To AMF1 With registered_amf With nwslice And Pdu Setup
    Unlock AMF2 AMF3
    traffic should be ok    type=sa
    Inactive AMF1 Lock AMF2 And Reselect AMF3 By PduSessionModification
    check counters    ${PM_Counters_ET-E032E033}
    release ues    ue_type=all

5GC000740-ET-E035_Verify_AMF_reselection_fails_due_to_candidate_AMF_NG-C_link_locked
    [Documentation]    Precondition:There are 3 AMF unlock with gNB
    ...    step
    ...    1.    lock amf-2 amf-3 (make sure amf1 selected in step3)
    ...    2.    amf_ng_setup_param id=1,2,3 ue_retention=on
    ...    3.    UE=1 register into AMF-1 is ok , unlock amf3
    ...    4.    lock amf-1
    ...        a.    check ue is not release
    ...    5.    unlock amf-1
    ...        a.    ngsetuprequest shall include ue retention information
    ...    6.    lock amf-1/3
    ...        a.    ue bulk release
    ...    7.    unlock amf-1
    ...        a.    ngsetuprequest shall not include ue retention information
    ...    note:case change from original design due to customer pr 01922793.
    [Tags]    5GC000740-E-EDA-01922793    5GC000740-E-ET035    QC_47207    CRT
    Precondition    ${PARAMS_E032E035}
    Update AMF Parameters ET-E035
    Lock AMF2 AMF3
    Set ue_retention For AMFs    id=1,2,3
    Ue Register To AMF1 With registered_amf Without nwslice And Pdu Setup
    Unlock AMF3
    Check Ue Is Not Released After Lock AMF1
    Check UERetentionInformation In NGSetup After Unlock AMF1
    Check No UERetentionInformation In NGSetup After Ue Bulk Release
    release ues    ue_type=all
    [Teardown]    Test Teardown For E035

5GC000740-ET-E036_Verify_AMF_reselection_based_candidate_AMF_capacity_0_in_same_set
    [Documentation]    This case is to verify no amf will be reselected when cap of amf2 and amf3 are 0
    [Tags]    5GC000740-E-ET036    QC_60768
    [Timeout]    60 min
    clear counter files
    Precondition    ${PARAMS_E033E036}
    Update AMF Parameters ET-E036
    Set ue_retention For AMFs    id=1,2,3
    Ue Register To AMF1 With registered_amf With nwslice And Pdu Setup
    traffic should be ok    type=sa
    Inactive AMF1
    traffic should be ok    type=sa
    AMF Reselection Failed Due To No Capacity When Setup 2nd PDU Session
    check counters    ${PM_Counters_ET-E036}
    release ues    ue_type=all

5GC000740-ET-E026_Verify_AMF_2_more_likely_selected_with_the_different_amf_pointer_and_AMF2_capacity_higher_than_AMF3
    [Documentation]    This case is to verify AMF2 has more chance to be selected when there's no backup AMF and AMF2 capacity is higher than AMF3
    ...    amfi of AMF2 change from 1:1:2 to 2:1:2 (different region),can be selected as candicate in this scenario
    ...    set registered_amf=262:03|1:1:1 to trigger PLMN identity presented in rrcsetupcomplete,which lead to search amf based on S-NSSAI
    ...    repeat register time set to 20,lower cap amfs get possibility to be selected
    [Tags]    5GC000740-E-ET026    QC_60767
    [Timeout]    60 min
    clear counter files
    Precondition    ${PARAMS_Recover}
    Update AMF Parameters ET-E026
    Inactive AMF1
    Register UE With registered_amf With nwslice Repeatly And Compare
    check counters    ${PM_Counters_ET-E026}
    release ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    ${match_string}    Create List    AMF-1: AMF - IP:10.0.1.2 NG link is Up    AMF-2: AMF - IP:10.0.1.2 NG link is Up
    ...    AMF-3: AMF - IP:10.0.1.2 NG link is Up
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    match_string=${match_string}
    execute egate command    sim_trace amf=1,2,3 protocol=ng on

Test Teardown And Recover
    delta commission parameters    ${PARAMS_Recover}
    Common Test Teardown And Stop Capture Logs

Test Teardown For E035
    Stop Capture BTS UdpLogs    rest
    Test Teardown And Recover

Modify Cfg
    update cfg    set_qosflow id=2 5qi=6 default=off
    update cfg    set_backup_amf main=1 backup_amfs=2,3

Precondition
    [Arguments]    ${delta_params}
    delta commission parameters    ${delta_params}

Lock AMF1
    delta commission parameters    ${Lock_AMF1}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Inactive

Lock AMF2
    delta commission parameters    ${Lock_AMF2}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Inactive

Lock AMF3
    delta commission parameters    ${Lock_AMF3}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-3:ngLinkStatus=Inactive

Lock AMF2 AMF3
    Lock AMF2
    Lock AMF3

Unlock AMF1
    delta commission parameters    ${Unlock_AMF1}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active

Unlock AMF2
    delta commission parameters    ${Unlock_AMF2}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active

Unlock AMF3
    delta commission parameters    ${Unlock_AMF3}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-3:ngLinkStatus=Active

Unlock AMF2 AMF3
    Unlock AMF2
    Unlock AMF3

Make Sure AMF Active
    [Documentation]    sctpWaitTimeInitSeqRetry=240s,sctp reinitialize will start at 4mins after AMF inactive
    wait until keyword succeeds    5 min    5 sec        object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    wait until keyword succeeds    5 min    5 sec        object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active
    wait until keyword succeeds    5 min    5 sec        object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-3:ngLinkStatus=Active

Update AMF Parameters ET-E020
    Make Sure AMF Active
    execute egate command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1,2,3 relative_capacity=50 amfi=1:1:1
    ...    AMF-1.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1,2,3 relative_capacity=0 amfi=1:1:2
    ...    AMF-2.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=3 name=SimModeAMF3 plmn=311:489 nwslice=1,2,3 relative_capacity=0 amfi=1:1:3
    ...    AMF-3.*Received AMF Configuration Acknowledge from GNB-2

Update AMF Parameters ET-E032
    Make Sure AMF Active
    execute egate command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1,2 relative_capacity=100 amfi=1:1:1
    ...    AMF-1.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1,2 relative_capacity=50 amfi=1:1:1
    ...    AMF-2.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=3 name=SimModeAMF3 plmn=311:489 nwslice=1 relative_capacity=100 amfi=1:2:1
    ...    AMF-3.*Received AMF Configuration Acknowledge from GNB-2

Update AMF Parameters ET-E033
    Make Sure AMF Active
    execute egate command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1,2,3 relative_capacity=50 amfi=1:1:1
    ...    AMF-1.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1,2,3 relative_capacity=100 amfi=1:1:1,1:1:2
    ...    AMF-2.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=3 name=SimModeAMF3 plmn=311:489 nwslice=1,2,3 relative_capacity=100 amfi=1:1:3
    ...    AMF-3.*Received AMF Configuration Acknowledge from GNB-2

Update AMF Parameters ET-E035
    Make Sure AMF Active
    execute egate command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1,2,3 relative_capacity=50 amfi=1:1:1
    ...    AMF-1.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1 relative_capacity=100 amfi=1:1:1,1:1:2
    ...    AMF-2.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=3 name=SimModeAMF3 plmn=311:489 nwslice=1 relative_capacity=10 amfi=1:1:1,1:1:3
    ...    AMF-3.*Received AMF Configuration Acknowledge from GNB-2

Update AMF Parameters ET-E036
    Make Sure AMF Active
    execute egate command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1,2,3 relative_capacity=50 amfi=1:1:1
    ...    AMF-1.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1,2,3 relative_capacity=0 amfi=1:1:2
    ...    AMF-2.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=3 name=SimModeAMF3 plmn=311:489 nwslice=1,2,3 relative_capacity=0 amfi=1:1:3
    ...    AMF-3.*Received AMF Configuration Acknowledge from GNB-2

Update AMF Parameters ET-E026
    Make Sure AMF Active
    execute egate command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1,2,3 relative_capacity=50 amfi=1:1:1
    ...    AMF-1.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1,2,3 relative_capacity=100 amfi=2:1:2
    ...    AMF-2.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=3 name=SimModeAMF3 plmn=311:489 nwslice=1,2,3 relative_capacity=10 amfi=1:1:3
    ...    AMF-3.*Received AMF Configuration Acknowledge from GNB-2

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

Ue Register To AMF1 With registered_amf Without nwslice And Pdu Setup
    Set Registered AMF To Ue    registered_amf=311:489|1:1:1
    Register Ue Without nwslice
    Setup PDU Session    pass_regexp=AMF-1: Initial Context Setup Successful

Ue Enter To IDLE
    execute egate command    ue_ng_ctx_release id=1 cause=NAS_normal_release    UE1: IS IDLE

Inactive AMF1
    execute egate command    link_drop link=ng by=amf:1 to=gnb:2 msg_type=shutdown    All NG links are down
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Inactive

Ue Exit IDLE Failed
    execute egate command    ue_im_exit id=1    UE1: RrcRelease is received for UE_NAS_5GS_MM_SERVICE_REQUEST_INITIATED

Set ue_retention For AMFs
    [Arguments]    ${id}=1,2,3
    execute egate command    amf_ng_setup_param id=${id} ue_retention=on

AMF2 Selected When Setup 2nd PDU Session
    execute egate command    set_pdu_param ue=1 pdu=2 trf_type=internal
    execute egate command    ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=2
    ...    AMF-2: GNB-2:.*Pdu Session Resource Setup Response.*handled successfully

AMF Reselection Failed Due To No Capacity When Setup 2nd PDU Session
    execute egate command    set_pdu_param ue=1 pdu=2 trf_type=internal
    execute egate command    ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=2    UEC-1: UE1: IS IDLE

Inactive AMF1 Lock AMF2 And Reselect AMF3 By PduSessionModification
    Inactive AMF1
    Lock AMF2
    ${return}=    execute egate command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=ue
    ...    AMF-3: GNB-2:.*Pdu Session Resource Modify Response.*handled successfully
    should contain    ${return}    Received Uplink NAS Transport

Check Ue Is Not Released
    execute egate command    ue_disp id=1    state.*ACTIVE

Check Ue Is Not Released After Lock AMF1
    Lock AMF1
    Check Ue Is Not Released

Check UERetentionInformation In NGSetup After Unlock AMF1
    stop capture wireshark log
    start to capture wireshark log    with_retention
    Unlock AMF1
    Check WireShark Log    a2a_ini_file=${CURDIR}${/}A2A_ET-E035${/}a2a_with_retention.ini    name=with_retention
    ...    wait_string=NGSetupResponse::1

Check No UERetentionInformation In NGSetup After Ue Bulk Release
    start to capture wireshark log    without_retention
    Lock AMF1
    Lock AMF3
    object should exist    MRBTS-1/NRBTS-1/NRCELL-1:barringStatus=barred
    object should exist    MRBTS-1/NRBTS-1/NRCELL-2:barringStatus=barred
    execute egate command    ue_disp id=1    state.*OFF
    Check bulk release In BTS Log
    Unlock AMF1
    Check WireShark Log    a2a_ini_file=${CURDIR}${/}A2A_ET-E035${/}a2a_without_retention.ini    name=without_retention
    ...    wait_string=NGSetupResponse::1

Check bulk release In BTS Log
    Stop Capture BTS UdpLogs
    Start To Capture BTS UdpLogs    rest
    file should contain strings    ${SAVE LOG DIRECTORY}${/}btslog.LOG    Finished bulk release

Register UE With registered_amf With nwslice Repeatly And Compare
    [Arguments]    ${ue_id}=1    ${register_times}=20
    set test variable    ${AMF2_count}    0
    set test variable    ${AMF3_count}    0
    Set Registered AMF To Ue    registered_amf=262:03|1:1:1
    FOR    ${index}    IN RANGE    ${register_times}
        ${return}=    execute egate command    ue_register id=${ue_id} nwslice=1,2,3    NG RM Registered
        ${return}=    Remove String    ${return}    \n    \r
        ${AMF2_count}=    evaluate    ${AMF2_count} + "${return}".count('AMF-2: INITIAL UE MESSAGE')
        ${AMF3_count}=    evaluate    ${AMF3_count} + "${return}".count('AMF-3: INITIAL UE MESSAGE')
        execute egate command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE Context Release Complete
    END
    should be true    ${AMF3_count} < ${AMF2_count}
    should be true    ${${AMF3_count}+${AMF2_count}} == 20
