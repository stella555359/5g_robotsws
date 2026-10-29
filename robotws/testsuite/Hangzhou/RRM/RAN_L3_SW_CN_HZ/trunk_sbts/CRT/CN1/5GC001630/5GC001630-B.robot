*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CRT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN3_SG2
...    owner-wen.y.xu    release-5G20A    5GC001630
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}    @{RanSharing}    @{MultiAMF}    @{MultiPLMN}    @{NRPLMNSET_SA_NSA}    @{SNSSAI}    @{TRACKINGAREA}    @{733_paging}

@{RanSharing}
...    NRBTS-1:actRanSharing=true
...    NRBTS-1:actRanSharingEnh=max_10_PLMNs
...    NRBTS-1:actNgcFlexSaMode=true
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac

@{MultiAMF}
...    SERVEDAMF-1:amfIPAddress=10.0.1.1
...    SERVEDAMF-2:amfIPAddress=10.0.1.102
...    SERVEDAMF-3:amfIPAddress=10.0.1.103
...    SERVEDAMF-4:amfIPAddress=10.0.1.104
...    SERVEDAMF-5:amfIPAddress=10.0.1.105
...    SERVEDAMF-6:amfIPAddress=10.0.1.106

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
...    NRPLMN-4:mcc=311
...    NRPLMN-4:mnc=404
...    NRPLMN-4:mncLength=3
...    NRPLMN-5:mcc=311
...    NRPLMN-5:mnc=405
...    NRPLMN-5:mncLength=3
...    NRPLMN-6:mcc=311
...    NRPLMN-6:mnc=406
...    NRPLMN-6:mncLength=3

@{NRPLMNSET_SA_NSA}
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-100
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=${PLMN1}
...    NRCELL/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-2:nrPlmnDNList=${PLMN2}
...    NRCELL/NRPLMNSET_SA-3:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-300
...    NRCELL/NRPLMNSET_SA-3:nrPlmnDNList=${PLMN3}
...    NRCELL/NRPLMNSET_SA-4:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-400
...    NRCELL/NRPLMNSET_SA-4:nrPlmnDNList=${PLMN4}
...    NRCELL/NRPLMNSET_SA-5:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-500
...    NRCELL/NRPLMNSET_SA-5:nrPlmnDNList=${PLMN5}
...    NRCELL/NRPLMNSET_SA-6:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-600
...    NRCELL/NRPLMNSET_SA-6:nrPlmnDNList=${PLMN6}

...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST}

@{SNSSAI}
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}

@{TRACKINGAREA}
...    TRACKINGAREA-100:fiveGsTac=100
...    TRACKINGAREA-100:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-300:fiveGsTac=300
...    TRACKINGAREA-300:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-400:fiveGsTac=400
...    TRACKINGAREA-400:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-500:fiveGsTac=500
...    TRACKINGAREA-500:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-600:fiveGsTac=600
...    TRACKINGAREA-600:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1

@{733_paging}
...    NRBTS-1:actPaging=true
...    NRBTS-1:drxDefaultPaging=v32
...    BWP_PROFILE/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRCELL-1:numOfPagingFrames=halfT
...    NRCELL-1:pagingOffset=1
...    NRCELL-1:numPagingOccsnPagingFrame=one
...    NRSYSINFO_PROFILE-1:systemInformationTargetRate=0

${PLMN1}    MRBTS-1/NRBTS-1/NRPLMN-1
${PLMN2}    MRBTS-1/NRBTS-1/NRPLMN-2
${PLMN3}    MRBTS-1/NRBTS-1/NRPLMN-3
${PLMN4}    MRBTS-1/NRBTS-1/NRPLMN-4
${PLMN5}    MRBTS-1/NRBTS-1/NRPLMN-5
${PLMN6}    MRBTS-1/NRBTS-1/NRPLMN-6
${NRPLMNDNLIST}    ${PLMN1},${PLMN2},${PLMN3},${PLMN4},${PLMN5},${PLMN6}

*** Test Cases ***
5GC001630-ET-B005_Verify_SA_Calls_in_cell_with_6_PLMNSET
    [Documentation]
    ...    1. 6 PLMNs configure and 1 PLMNSET_SA have 1 PLMN. Different tac for each PLMNSET_SA.
    ...    6 UE with different selected PLMN setup SA calls. When NGsetup, it will carry all tac information.
    ...    After ue attach, you can view plmn info corresponding to ue from InitialContextSetupRequest. And Calls is successful.
    ...    2. Test Case Steps:
    ...       a. set all NG link setup
    ...       b. UE1 register and tigger paging from AMF1
    ...       c. UE2 register and tigger paging from AMF2
    ...       d. SA UEs register and do traffic
    ...    3. Expected Results:
    ...       a1. all NG link is up
    ...       a2. all tac in SupportedTAList
    ...       b. UE1 register and paging successful
    ...       c. UE2 register and paging successful
    ...       d1. SA UEs from different PLMNs register successful in the same cell with different for each PLMNSET
    ...       d2. each AMF dedicated to one of PLMN
    ...       d3. traffic should be ok
    [Tags]    QC_47198    EDA-01805000
    Check All NG links is up
    start to capture wireshark log    UEs_paging
    Trigger paging from AMF    ue_id=1    amf=1
    Trigger paging from AMF    ue_id=2    amf=2
    check wireshark log    ${CURDIR}/a2a_B005/a2a_UEs_paging.ini    name=UEs_paging    wait_string=InitialContextSetupResponse::8
    Release UEs    ue_type=all
    SA UEs register and traffic should be ok
    check wireshark log    ${CURDIR}/a2a_B005/a2a_register_all_ue_plmn.ini    name=register_all_ue_plmn    wait_string=InitialContextSetupResponse::6

*** Keywords ***
Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,100 plmn=311:489
    Update Cfg    set_amf_region id=2 tac_list=0,200 plmn=311:402
    Update Cfg    set_amf_region id=3 tac_list=0,300 plmn=311:403
    Update Cfg    set_amf_region id=4 tac_list=0,400 plmn=311:404
    Update Cfg    set_amf_region id=5 tac_list=0,500 plmn=311:405
    Update Cfg    set_amf_region id=6 tac_list=0,600 plmn=311:406
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1 name=SimModeAMF1
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=2 set_id=2 pointer=1 name=SimModeAMF2
    Update Cfg    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.1.103:38412 region=3 set_id=3 pointer=1 name=SimModeAMF3
    Update Cfg    set_amf id=4 daemon=10.0.2.1:22222 ng=10.0.1.104:38412 region=4 set_id=4 pointer=1 name=SimModeAMF4
    Update Cfg    set_amf id=5 daemon=10.0.2.1:22222 ng=10.0.1.105:38412 region=5 set_id=5 pointer=1 name=SimModeAMF5
    Update Cfg    set_amf id=6 daemon=10.0.2.1:22222 ng=10.0.1.106:38412 region=6 set_id=6 pointer=1 name=SimModeAMF6
    ${set_ue1}    catenate    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue1}
    ${set_ue2}    catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:402:0000:0:0:021645401 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue2}
    ${set_ue3}    catenate    set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:403:0000:0:0:021645402 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue3}
    ${set_ue4}    catenate    set_ue simulated id=4 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:404:0000:0:0:021645403 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue4}
    ${set_ue5}    catenate    set_ue simulated id=5 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:405:0000:0:0:021645404 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue5}
    ${set_ue6}    catenate    set_ue simulated id=6 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:406:0000:0:0:021645405 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue6}
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1-6 default=on ue=all

Perform Steps After Onair
    check wireshark log    ${CURDIR}/a2a_B005/a2a_tac_for_each_PLMNSET.ini    wait_string=NGSetupResponse::6

Check All NG links is up
    FOR    ${amf_id}    IN RANGE    1    7
        object should exist    SERVEDAMF-${amf_id}:ngLinkStatus=Active
    END

Trigger paging from AMF
    [Arguments]    ${ue_id}=1    ${amf}=1
    sa ue register and pdu setup    ue_id=${ue_id}
    Make UE to idle    ${ue_id}    ${amf}
    Execute Egate Command    amf_paging_start id=${amf} ue=${ue_id}    AMF-${amf}: Initial Context Setup Successful for UE

Make ue to idle
    [Arguments]    ${ue_id}=1    ${amf}=1
    Execute Egate Command    amf_paging_param id=${amf} default_drx=32 max_paging_retries=1
    Execute Egate Command    ue_ng_ctx_release id=${ue_id} cause=NAS_normal_release    Received UE Context Release Complete

SA UEs register and traffic should be ok
    start to capture wireshark log    register_all_ue_plmn
    FOR    ${ue_id}    IN RANGE    1    7
        sa ue register and pdu setup    ue_id=${ue_id}
        traffic should be ok    ue_id=${ue_id}    type=SA
    END

sa ue register and pdu setup
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}    AMF-${ue_id}:.*NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}    QoS Routing Table
