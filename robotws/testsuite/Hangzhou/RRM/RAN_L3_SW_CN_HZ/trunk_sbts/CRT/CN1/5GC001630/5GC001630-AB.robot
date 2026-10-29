*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN3_SG2
...    owner-wen.y.xu    release-5G20A    5GC001630
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}    @{RanSharing}    @{MultiAMF}    @{MultiPLMN}    @{NRPLMNSET_SA_NSA}    @{SNSSAI}    @{TRACKINGAREA}

@{RanSharing}
...    NRBTS-1:actRanSharing=true
...    NRBTS-1:actRanSharingEnh=max_10_PLMNs
...    NRBTS-1:ngUeRetentionEnabled=true
...    NRBTS-1:actNgcFlexSaMode=true
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac

@{MultiAMF}
...    SERVEDAMF-1:amfIPAddress=10.0.1.1
...    SERVEDAMF-2:amfIPAddress=10.0.1.102
...    SERVEDAMF-3:amfIPAddress=10.0.1.103

@{MultiPLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    NRPLMN-2:mcc=311
...    NRPLMN-2:mnc=402
...    NRPLMN-2:mncLength=3
...    NRPLMN-3:mcc=311
...    NRPLMN-3:mnc=403
...    NRPLMN-3:mncLength=3

@{NRPLMNSET_SA_NSA}
...    NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-100
...    NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1_2}
...    NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_3}

...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST}

@{SNSSAI}
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}

@{TRACKINGAREA}
...    TRACKINGAREA-100:fiveGsTac=100
...    TRACKINGAREA-100:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1

${NRPLMNDNLIST_1_2}    MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
${NRPLMNDNLIST_3}    MRBTS-1/NRBTS-1/NRPLMN-3
${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3

@{UE1_UE2}    1    2
@{UE1_UE3}    1    3

*** Test Cases ***
5GC001630-ET-AB01_Verify_the_AMF_reselection_successful_based_on_same_PLMN_successfully_when_original_AMF_inactive
    [Documentation]
    ...    1. AMF reselection successful based on same PLMN successfully when original AMF inactive
    ...    2. Test Case Steps:
    ...         a. setup all NGlink
    ...         b. update AMFs configuration to support different PLMNs
    ...         c. multiUE register and verify traffic (traffic goes on)
    ...         d. update AMF2 configuration to support PLMN1 and PLMN2
    ...         e. Locked AMF1
    ...         f. UE1 and UE2 deregister
    ...    3. Expected Results:
    ...         a: All NGlink is up
    ...         b: amf config update [AMF1-311:489 / AMF2-311:402 / AMF3-311:403]
    ...         c: UE1 and UE2 register successful(UE1 on AMF1 / UE2 on AMF2) and traffic should be ok
    ...         d: amf config update [AMF1-311:489 / AMF2-311:489,311:402 / AMF3-311:403]
    ...         e. AMF1 Locked. UE1 AMF reselection successful(AMF1 to AMF2)
    ...         f. UE1 AMF reselection successful(AMF1 to AMF2); both UE1 and UE2 deregister on AMF2
    [Tags]    ab01    QC_60729
    Check All NG links is up
    update AMFs configuration to support different PLMNs
    UEs register and verify traffic    ${UE1_UE2}
    update AMF2 configuration to support PLMN1 and PLMN2
    delta commission parameters    SERVEDAMF-1:administrativeState=Locked
    AMF reselection from AMF1 to AMF2
    Unlocked All AMFs

5GC001630-ET-AB02_Verify_the_AMF_reselection_fail_based_on_different_selected_PLMN_when_original_AMF_inactive
    [Documentation]
    ...    1. AMF reselection failed based on same PLMN successfully when original AMF inactive
    ...    2. Test Case Steps:
    ...         a. setup all NGlink
    ...         b. update AMFs configuration to support different PLMNs
    ...         c. multiUE register and verify traffic (traffic goes on)
    ...         d. Locked AMF1 and AMF2
    ...         e. UE1 and UE3 deregister
    ...    3. Expected Results:
    ...         a: All NGlink is up
    ...         b: amf config update [AMF1-311:489 / AMF2-311:402 / AMF3-311:403]
    ...         c: UE1 and UE3 register successful(UE1 on AMF1 / UE3 on AMF3) and traffic should be ok
    ...         d. AMF1 and AMF2 is Locked. CELL1 is barred.
    ...         e. SA UE1 release due to AMF reselection failure. UE3 deregister normally on AMF3.
    [Tags]    ab02    QC_60730
    Check All NG links is up
    update AMFs configuration to support different PLMNs
    UEs register and verify traffic    ${UE1_UE3}
    Locked AMF1 and AMF2
    SA UE1 Release due to AMF reselection failure
    PDU release and SA UE deregister    ue_id=3    cmd_regexp=AMF-3: UE.*is now Deregistered
    Unlocked All AMFs

*** Keywords ***
Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,100,200 plmn=311:489,311:402,311:403
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1 name=SimModeAMF1
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=1 set_id=1 pointer=2 name=SimModeAMF2
    Update Cfg    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.1.103:38412 region=1 set_id=1 pointer=3 name=SimModeAMF3
    Update Cfg    amf_ng_setup_param id=1 relative_capacity=100 include_backup_amf_name=on ue_retention=on retention_time=indefinite
    Update Cfg    amf_ng_setup_param id=2 relative_capacity=10
    Update Cfg    amf_ng_setup_param id=3 relative_capacity=10
    ${set_ue1}    catenate    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue1}
    ${set_ue2}    catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:402:0000:0:0:021645401 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue2}
    ${set_ue3}    catenate    set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:403:0000:0:0:021645402 mode=nr enb=2 cell=2
    Update Cfg    ${set_ue3}
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1-3 default=on ue=all

Check All NG links is up
    FOR    ${amf_id}    IN RANGE    1    4
        object should exist    SERVEDAMF-${amf_id}:ngLinkStatus=Active
    END

SA UE register and PDU setup
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}    AMF-${ue_id}:.*NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}    QoS Routing Table

update AMFs configuration to support different PLMNs
    [Arguments]    ${pass_regexp}=Received AMF Configuration Acknowledge
    Execute Egate Command    amf_config_update id=1 plmn=311:489    ${pass_regexp}
    Execute Egate Command    amf_config_update id=2 plmn=311:402    ${pass_regexp}
    Execute Egate Command    amf_config_update id=3 plmn=311:403    ${pass_regexp}

AMF reselection from AMF1 to AMF2
    Verify Throughput    ue_id=1
    Verify Throughput    ue_id=2
    PDU release and SA UE deregister    ue_id=1    cmd_regexp=AMF-2: UE.*is now Deregistered
    Verify Throughput    ue_id=2
    PDU release and SA UE deregister    ue_id=2    cmd_regexp=AMF-2: UE.*is now Deregistered

UEs register and verify traffic
    [Arguments]    ${ue_list}
    FOR    ${ue_id}    IN    @{ue_list}
        SA UE register and PDU setup    ue_id=${ue_id}
        Send Throughput    ue_id=${ue_id}
        Verify Throughput    ue_id=${ue_id}
    END

update AMF2 configuration to support PLMN1 and PLMN2
    Execute Egate Command    amf_config_update id=2 plmn=311:489,311:402    Received AMF Configuration Acknowledge

PDU release and SA UE deregister
    [Arguments]    ${ue_id}=1    ${cmd_regexp}=UE${ue_id}: detached
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1 by=ue    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    ${cmd_regexp}

SA UE1 Release due to AMF reselection failure
    check specific ue state    ue_id=1    state=off
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    UE1 .* is already turned off

Locked AMF1 and AMF2
    ${params}    create list    SERVEDAMF-1:administrativeState=Locked    SERVEDAMF-2:administrativeState=Locked
    delta commission parameters    ${params}
    ${status}    create list    SERVEDAMF-1:ngLinkStatus=Inactive    SERVEDAMF-2:ngLinkStatus=Inactive    NRCELL-1:barringStatus=barred
    object should exist    ${status}

Send Throughput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10    UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=10    UDP DL

Verify Throughput
    [Arguments]    ${ue_id}=1    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9.5
    Should Be True    ${dl_throuput}/1000>9.5

Unlocked All AMFs
    ${unlock_amfs}    create list    SERVEDAMF-1:administrativeState=Unlocked    SERVEDAMF-2:administrativeState=Unlocked
    ...    SERVEDAMF-3:administrativeState=Unlocked
    delta commission parameters    ${unlock_amfs}
    cells should be onair
