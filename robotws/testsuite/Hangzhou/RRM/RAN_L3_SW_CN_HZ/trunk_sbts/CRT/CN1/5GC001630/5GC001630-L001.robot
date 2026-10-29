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

...    NRBTS-1:actNgcFlexSaMode=true
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac

@{MultiAMF}
...    SERVEDAMF-1:amfIPAddress=10.0.1.1
...    SERVEDAMF-2:amfIPAddress=10.0.1.102

@{MultiPLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    NRPLMN-2:mcc=311
...    NRPLMN-2:mnc=402
...    NRPLMN-2:mncLength=3

@{NRPLMNSET_SA_NSA}
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST}

...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST}

@{SNSSAI}
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}

@{TRACKINGAREA}
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2

${PLMN1}    311:489
${PLMN2}    311:402

${active}    Active

*** Test Cases ***
5GC001630-ET-L001_Verify_SA_Call_setup_in_different_PLMN_supported_by_one_AMF
    [Documentation]
    ...    1. SA call can setup in different PLMN in one AMF, SA call can also setup in same PLMN in different AMF
    ...    2. AMF1/AMF2: PLMN1 SNSSAI-1, PLMN2 SNSSAI-1
    ...       CELL1: PLMN1/PLMN2, SNSSAI-1
    ...       SNSSAI-1: PLMN1/PLMN2, non-standard slice
    ...       UE1/UE3: PLMN1
    ...       UE2: PLMN2
    ...    3. Test Case Steps:
    ...         a. set all NG link setup
    ...         b. Change AMF2 only support PLMN2
    ...         c. SA UE1(PLMN1) register and do traffic
    ...         d. Change AMF2 only support PLMN1
    ...         e. SA UE2(PLMN2) register and do traffic
    ...         f. set amf1 capacity=0 and SA UE3(PLMN1) register and do traffic
    ...    4. Expected Results:
    ...         a. All NG link is up
    ...         b. AMF1 support PLMN1/PLMN2; AMF2 support PLMN2
    ...         c. UE1(PLMN1) register on AMF1 and traffic should be ok
    ...         d. AMF1 support PLMN1/PLMN2; AMF2 support PLMN1
    ...         e. UE2(PLMN2) register on AMF1 and traffic should be ok
    ...         f. UE3(PLMN1) register on AMF2 due to LoadBalance and traffic should be ok
    [Tags]    QC_60726
    Check All NG links is up
    Change AMF Simulator PLMN    amf2_plmn=${PLMN2}
    UE1 Establish On AMF1 Which Support PLMN1
    Change AMF Simulator PLMN    amf2_plmn=${PLMN1}
    UE2 Establish On AMF1 Which Support PLMN2
    UE3 Establish On AMF2 Due To LoadBalance

*** Keywords ***
Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,200 plmn=311:489,311:402
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=1 set_id=1 pointer=2
    ${set_ue1}    catenate    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    ${set_ue2}    catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:402:0000:0:0:021645401 mode=nr enb=2 cell=1
    ${set_ue3}    catenate    set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645402 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue1}
    Update Cfg    ${set_ue2}
    Update Cfg    ${set_ue3}
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1-2 default=on ue=all

Check All NG links is up
    object should exist    SERVEDAMF-1:ngLinkStatus=${active}
    object should exist    SERVEDAMF-2:ngLinkStatus=${active}

sa ue register and pdu setup
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_register id=${ue_id} nwslice=${nwslice}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${ue_id}    ${cmd_pdu_regexp}

Change AMF Simulator PLMN
    [Arguments]    ${amf1_plmn}=311:489,311:402    ${amf2_plmn}=311:489,311:402
    Execute Egate Command    amf_config_update id=1 plmn=${amf1_plmn} nwslice=1    Received AMF Configuration Acknowledge
    Execute Egate Command    amf_config_update id=2 plmn=${amf2_plmn} nwslice=1    Received AMF Configuration Acknowledge

UE1 Establish On AMF1 Which Support PLMN1
    sa ue register and pdu setup    ue_id=1    cmd_pdu_regexp=AMF-1: Initial Context Setup Successful
    Traffic Should Be OK    ue_id=1    type=sa

UE2 Establish On AMF1 Which Support PLMN2
    sa ue register and pdu setup    ue_id=2    cmd_pdu_regexp=AMF-1: Initial Context Setup Successful
    Traffic Should Be OK    ue_id=2    type=sa

UE3 Establish On AMF2 Due To LoadBalance
    Execute Egate Command    amf_config_update id=1 relative_capacity=0 plmn=311:489,311:402    Received AMF Configuration Acknowledge
    sa ue register and pdu setup    ue_id=3    cmd_pdu_regexp=AMF-2: Initial Context Setup Successful
    Traffic Should Be OK    ue_id=3    type=sa
