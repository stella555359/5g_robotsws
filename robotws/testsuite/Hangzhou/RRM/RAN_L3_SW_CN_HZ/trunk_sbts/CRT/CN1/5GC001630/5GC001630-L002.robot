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
...    SNSSAI-1:administrativeState=Unlocked
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST_1}
...    SNSSAI-1:sst=1
...    SNSSAI-1:sd=13714341
...    SNSSAI-2:administrativeState=Unlocked
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST_2}
...    SNSSAI-2:sst=1
...    SNSSAI-2:sd=13714342

@{TRACKINGAREA}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
${NRPLMNDNLIST_1}    MRBTS-1/NRBTS-1/NRPLMN-1
${NRPLMNDNLIST_2}    MRBTS-1/NRBTS-1/NRPLMN-2

${PLMN1}    311:489
${PLMN2}    311:402

${active}    Active

*** Test Cases ***
5GC001630-ET-L002_Verify_SA_Call_when_AMF_support_PLMN_change
    [Documentation]
    ...    1. SA call should release immediately if AMF not support the PLMN anymore, and SA call can setup if AMF recover support
    ...    2. AMF Region: PLMN1 SNSSAI-1, PLMN2 SNSSAI-1/SNSSAI-2
    ...       AMF1: PLMN1 SNSSAI-1, PLMN2 SNSSAI-1/SNSSAI-2
    ...       AMF2: PLMN1 SNSSAI-1, PLMN2 SNSSAI-1/SNSSAI-2
    ...       SNSSAI-1: PLMN1, non-standard slice
    ...       SNSSAI-2: PLMN2, non-standard slice
    ...       CELL1: PLMN1 SNSSAI-1, PLMN2 SNSSAI-2
    ...       UE1: PLMN1
    ...       UE2: PLMN2
    ...    3. Test Case Steps:
    ...         a. set all NG link setup
    ...         b. AMF Region Update To Not Support PLMN1
    ...            1) update AMF2 only support PLMN2 SNSSAI-2 (AMF1: PLMN1 SNSSAI-1, PLMN2 SNSSAI-1/SNSSAI-2; AMF2: PLMN2 SNSSAI-2)
    ...            2) SA UE1 register
    ...            3) update AMF Region not Support PLMN1 (Region:PLMN2 SNSSAI-1/SNSSAI-2)
    ...         c. AMF Region Update To Not Supported PLMN1 Nwslice2 (Region:PLMN1 SNSSAI-2)
    ...         d. AMF Region Update To Support PLMN2 Nwslice2 (Region:PLMN2 SNSSAI-2)
    ...         e. Locked AMF1 and SA UE2 register
    ...    4. Expected Results:
    ...         a. All NG link is up
    ...         b. UE1 relase due to AMF Region not support PLMN1
    ...         c. Cells is barred
    ...         d. Cells is unbarred
    ...         e. UE2 register successful on AMF2 due to AMF Region Support PLMN2
    [Tags]    QC_60732
    Check All NG links is up
    UE1 Release If AMF Region Update To Not Support PLMN1
    CELL Barred If AMF Region Update To Not Supported PLMN1 Nwslice2
    CELL Not Barred If AMF Region Update To Support PLMN2 Nwslice2
    UE2 Call Setup If AMF Region Update To Support PLMN2

*** Keywords ***
Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,200 plmn=311:489,311:402
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=1 set_id=1 pointer=2
    ${set_ue1}    catenate    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    ${set_ue2}    catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:402:0000:0:0:021645401 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue1}
    Update Cfg    ${set_ue2}
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 default=on ue=all amf_region_id=1 plmn_list=311:489,311:402
    Update Cfg    set_nwslice id=2 snssai=0x01:0xd143a6 ue=all amf_region_id=1 plmn_list=311:402

Check All NG links is up
    object should exist    SERVEDAMF-1:ngLinkStatus=${active}
    object should exist    SERVEDAMF-2:ngLinkStatus=${active}

UE1 Release If AMF Region Update To Not Support PLMN1
    Execute Egate Command    amf_config_update id=2 plmn=${PLMN2} nwslice=2    Received AMF Configuration Acknowledge
    #Region:PLMN1 SNSSAI-1, PLMN2 SNSSAI-1/SNSSAI-2    AMF1: PLMN1 SNSSAI-1, PLMN2 SNSSAI-1/SNSSAI-2    AMF2: PLMN2 SNSSAI-2
    Execute Egate Command    ue_register id=1    AMF-1:.*UE now in NG RM Registered
    Execute Egate Command    amf_region_update id=1 cmd=delete plmn=${PLMN1}    UE1: IS IDLE
    Execute Egate Command    amf_region_disp id=1    Region    #Region:PLMN2 SNSSAI-1/SNSSAI-2
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    UE1: detached    timeout=65    #WA for Resources Leakage

CELL Barred If AMF Region Update To Not Supported PLMN1 Nwslice2
    Execute Egate Command    amf_region_update id=1 cmd=delete plmn=${PLMN2} cmd=add plmn=${PLMN1} nwslice=2    gNB=2: Cell 1 is barred
    Execute Egate Command    amf_region_disp id=1    Region    #Region:PLMN1 SNSSAI-2
    object should exist    NRCELL:barringStatus=barred

CELL Not Barred If AMF Region Update To Support PLMN2 Nwslice2
    Execute Egate Command    amf_region_update id=1 cmd=delete plmn=${PLMN1} cmd=add plmn=${PLMN2} nwslice=2    cellBarred notBarred
    Execute Egate Command    amf_region_disp id=1    Region    #Region:PLMN2 SNSSAI-2
    object should exist    NRCELL:barringStatus=unbarred

UE2 Call Setup If AMF Region Update To Support PLMN2
    delta commission parameters    SERVEDAMF-1:administrativeState=Locked
    Execute Egate Command    ue_register id=2    AMF-2:.*UE now in NG RM Registered
