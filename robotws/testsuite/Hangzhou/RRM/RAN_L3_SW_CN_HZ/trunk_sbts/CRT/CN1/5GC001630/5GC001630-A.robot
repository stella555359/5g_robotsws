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

@{PARAMS_IN_SCF}    @{RanSharing}    @{MultiAMF}    @{MultiPLMN}    @{NRPLMNSET_SA_NSA}    @{SNSSAI}    @{TRACKINGAREA}

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
...    NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-100
...    NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1}
...    NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST}

...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST}

@{SNSSAI}
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}

@{TRACKINGAREA}
...    TRACKINGAREA-100:fiveGsTac=100
...    TRACKINGAREA-100:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1

${NRPLMNDNLIST}    SEPARATOR=,
...    MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/NRPLMN-3
...    MRBTS-1/NRBTS-1/NRPLMN-4
...    MRBTS-1/NRBTS-1/NRPLMN-5
...    MRBTS-1/NRBTS-1/NRPLMN-6
${NRPLMNDNLIST_1}    MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3

*** Test Cases ***
5GC001630-ET-A001-A016_Available_PLMNs_change_and_Cell_barring_status_change_of_two_cells
    [Documentation]
    ...    1. A001: Successful multi-PLMN SA Sharing with single PLMNSET per cell
    ...    2. A016: AMF belonging to one of shared operators becomes unavailable
    ...    3. Test Case Steps:
    ...         a. set all NG link setup
    ...         b. SA UEs register on cell2
    ...         c. Locked AMF2 then Locked and Unlocked Cells
    ...         d. Unlocked AMF2
    ...         e. SA UEs register
    ...         f. Locked AMF1 AMF2 AMF3
    ...    4. Expected Results:
    ...         a: All NG link is up
    ...         b1: SA UEs from different PLMNs are successfully register in the same cell2 with single PLMNSET
    ...         b2: each AMF dedicated to one of PLMN
    ...         c: AMF2 is Inactive and PLMN2 is unsupport; PLMN2 is still unsupported after Cells Locked/Unlocked
    ...         d. AMF2 is Active and PLMN2 is support
    ...         e. Register 6 UEs and UE2 AMF selection succeeded after AMF2 Unlocked
    ...         f. Cell1 Barred
    [Tags]    QC_47197    EDA-PR548714
    SA UEs register on different PLMNs
    Locked AMF2 then Locked and Unlocked Cells
    Unlocked AMF2 and Check PLMN2 is supported
    SA UEs register on different PLMNs
    Locked AMF1 to AMF3 then Cell1 should be Barred
    Release Ues    ue_type=all
    Check WireShark Log    ${CURDIR}/a2a_A001_A016/a2a.ini    wait_string=InitialContextSetupResponse::12
    Unlocked All AMFs

*** Keywords ***
Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,100,200 plmn=311:489
    Update Cfg    set_amf_region id=2 tac_list=0,100,200 plmn=311:402
    Update Cfg    set_amf_region id=3 tac_list=0,100,200 plmn=311:403
    Update Cfg    set_amf_region id=4 tac_list=0,100,200 plmn=311:404
    Update Cfg    set_amf_region id=5 tac_list=0,100,200 plmn=311:405
    Update Cfg    set_amf_region id=6 tac_list=0,100,200 plmn=311:406
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1 name=SimModeAMF1
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=2 set_id=2 pointer=1 name=SimModeAMF2
    Update Cfg    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.1.103:38412 region=3 set_id=3 pointer=1 name=SimModeAMF3
    Update Cfg    set_amf id=4 daemon=10.0.2.1:22222 ng=10.0.1.104:38412 region=4 set_id=4 pointer=1 name=SimModeAMF4
    Update Cfg    set_amf id=5 daemon=10.0.2.1:22222 ng=10.0.1.105:38412 region=5 set_id=5 pointer=1 name=SimModeAMF5
    Update Cfg    set_amf id=6 daemon=10.0.2.1:22222 ng=10.0.1.106:38412 region=6 set_id=6 pointer=1 name=SimModeAMF6
    ${set_ue1}    catenate    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=2
    Update Cfg    ${set_ue1}
    ${set_ue2}    catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:402:0000:0:0:021645401 mode=nr enb=2 cell=2
    Update Cfg    ${set_ue2}
    ${set_ue3}    catenate    set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:403:0000:0:0:021645402 mode=nr enb=2 cell=2
    Update Cfg    ${set_ue3}
    ${set_ue4}    catenate    set_ue simulated id=4 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:404:0000:0:0:021645403 mode=nr enb=2 cell=2
    Update Cfg    ${set_ue4}
    ${set_ue5}    catenate    set_ue simulated id=5 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:405:0000:0:0:021645404 mode=nr enb=2 cell=2
    Update Cfg    ${set_ue5}
    ${set_ue6}    catenate    set_ue simulated id=6 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:406:0000:0:0:021645405 mode=nr enb=2 cell=2
    Update Cfg    ${set_ue6}
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1-6 default=on ue=all

Perform Steps After Onair
    Check All NG links is up
    check wireshark log    ${CURDIR}/a2a_A001_A016/a2a_tac_for_one_PLMNSET.ini

Check All NG links is up
    FOR    ${amf_id}    IN RANGE    1    7
        object should exist    SERVEDAMF-${amf_id}:ngLinkStatus=Active
    END

Locked AMF2 then Locked and Unlocked Cells
    delta commission parameters    SERVEDAMF-2:administrativeState=Locked
    object should exist    SERVEDAMF-2:ngLinkStatus=Inactive
    delta commission parameters    NRCELL-1:administrativeState=Locked
    delta commission parameters    NRCELL-2:administrativeState=Locked
    delta commission parameters    NRCELL-1:administrativeState=Unlocked
    delta commission parameters    NRCELL-2:administrativeState=Unlocked
    Cells Should Be Onair

Unlocked AMF2 and Check PLMN2 is supported
    delta commission parameters    SERVEDAMF-2:administrativeState=Unlocked
    object should exist    SERVEDAMF-2:ngLinkStatus=Active

Locked AMF1 to AMF3 then Cell1 should be Barred
    ${Locked_amf1_am2_amf3}    create list    SERVEDAMF-1:administrativeState=Locked    SERVEDAMF-2:administrativeState=Locked
    ...    SERVEDAMF-3:administrativeState=Locked
    delta commission parameters    ${Locked_amf1_am2_amf3}
    object should exist    SERVEDAMF-1:ngLinkStatus=Inactive
    object should exist    SERVEDAMF-2:ngLinkStatus=Inactive
    object should exist    SERVEDAMF-3:ngLinkStatus=Inactive
    object should exist    NRCELL-1:barringStatus=barred
    object should exist    NRCELL-2:barringStatus=unbarred

SA UEs register on different PLMNs
    FOR    ${ue_id}    IN RANGE    1    7
        sa ue register and pdu setup    ue_id=${ue_id}
        traffic should be ok    ue_id=${ue_id}    type=SA
    END
    ${register_in_cell2}    Execute Egate Command    ue_disp state=ACTIVE    ACTIVE
    Should Contain X Times    ${register_in_cell2}    2.2    6

sa ue register and pdu setup
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}    AMF-${ue_id}:.*NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}    QoS Routing Table

Unlocked All AMFs
    ${unlock_amfs}    create list    SERVEDAMF-1:administrativeState=Unlocked    SERVEDAMF-2:administrativeState=Unlocked
    ...    SERVEDAMF-3:administrativeState=Unlocked    SERVEDAMF-4:administrativeState=Unlocked
    ...    SERVEDAMF-5:administrativeState=Unlocked    SERVEDAMF-6:administrativeState=Unlocked
    delta commission parameters    ${unlock_amfs}
    cells should be onair
