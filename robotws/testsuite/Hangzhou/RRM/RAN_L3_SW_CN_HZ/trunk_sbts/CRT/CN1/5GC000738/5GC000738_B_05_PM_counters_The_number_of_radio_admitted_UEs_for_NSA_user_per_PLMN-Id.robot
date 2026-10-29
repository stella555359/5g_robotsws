*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    CRT    RAN_5G    RAN_5G_TDD
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-DevHZ5_SG2    owner-yuhua.zhu    release-5G19A
Resource     ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1:actRanSharing=true
...    MRBTS-1/NRBTS-1:actMultiDrbNSA=true
...    delete:MRBTS-1/NRBTS-1/NRCELL:configuredEpsTac
...    delete:MRBTS-1/NRBTS-1/NRCELL:trackingAreaDN
...    MRBTS-1/NRBTS-1/NRPLMN-1:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-1:mnc=489
...    MRBTS-1/NRBTS-1/NRPLMN-1:mncLength=3
...    MRBTS-1/NRBTS-1/NRPLMN-2:mcc=460
...    MRBTS-1/NRBTS-1/NRPLMN-2:mnc=002
...    MRBTS-1/NRBTS-1/NRPLMN-2:mncLength=3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_NSA-1:configuredEpsTac=200
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_NSA-1:configuredEpsTac=200
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/NRCELL-3/NRPLMNSET_NSA-1:configuredEpsTac=200
...    MRBTS-1/NRBTS-1/NRCELL-3/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-3/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-3/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200

${RA_UE_NSA_PLMN}    M55145C00005             #The number of radio admitted UEs for NSA user per PLMN-ID
${RA_NGBR_DRB_NSA_PLMN}    M55145C00006       #The number of radio admitted non-GBR DRBs for NSA user per PLMN-ID
@{PM_COUNTERS}
...    NRCELL-1/MCC-311/MNC-489:NRANS:${RA_UE_NSA_PLMN}=1
...    NRCELL-1/MCC-311/MNC-489:NRANS:${RA_NGBR_DRB_NSA_PLMN}=2
...    NRCELL-1/MCC-460/MNC-002:NRANS:${RA_UE_NSA_PLMN}=1
...    NRCELL-1/MCC-460/MNC-002:NRANS:${RA_NGBR_DRB_NSA_PLMN}=2

*** Test Cases ***
5GC000738_B_05_PM_counters_The number of radio admitted UEs for NSA user per PLMN-Id
    [Documentation]
    ...    This case will include feature 5GC000738
    ...    The purpose of this test case is to check Multi PLMN are broadcasted to each connected MeNB
    ...    during EN-DC X2 Setup and SgNB Addition procedure.
    ...    PLMN1 and PLMN2 add to cell1
    ...    PLMN2 add to cell2
    ...    UE attach to different bearers with each PLMN
    ...    Check PLMN is correct in ENDCX2AP and sgNB addition request

    [Tags]    QC_61469
    Clear Counter Files    ${False}
    #NSA UEs L3 Call And ENDC Succeed
    NSA UEs L3 Call And ENDC Succeed for UE31
    NSA UEs L3 Call And ENDC Succeed for UE32
    Check DL And UL Throughput
    Check WireShark Log    ${CURDIR}${/}a2a_5GC000738${/}a2a_endc.ini    wait_string=SNStatusTransfer::4
    Check Counters    ${PM_COUNTERS}
    Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${ue32}    catenate
    ...    set_ue simulated id=32 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    eia=null+snow3g+aes eea=null nia=null+snow3g+zuc+aes nea=null+zuc+snow3g imsi=460:002:21645502
    Update Cfg    mme_pool_area id=2 mmegi=2 plmn=460:002 tac_list=200,777,111,222,444,333,210 eq_plmn=460:002
    Update Cfg    ${ue32}
    Update Cfg    set_bearer id=3 ue=31 qci=8 pdn=1 preprovisioned=on filter=2 precedence=2
    Delete Cfg    set_bearer id=2 ue=32	
    Update Cfg    set_bearer id=4 ue=32 qci=7 pdn=1 ip=4.7.254.210 default=on trf_type=internal		  
    Update Cfg    set_bearer id=5 ue=32 qci=6 pdn=1 preprovisioned=on filter=2 precedence=2
    Update Cfg    enb_param id=1 endc_capable_qci=6,7,8,9

Perform Steps After Onair
    Check WireShark Log    ${CURDIR}${/}a2a_5GC000738${/}a2a_x2.ini    wait_string=ENDCX2SetupResponse::1

NSA UEs L3 Call And ENDC Succeed for UE31
    Execute Egate Command    ue_change_location id=31 enb=1 cell=1
    Execute Egate Command    ue_attach id=31    UE31: === UE IS ACTIVE
    Execute Egate Command    enb_endc_param selected_plmn=311:489 id=1
    Execute Egate Command    ue_dc_enb_start ue=31 target_gnb=2 target_cells=1 bearer=2,3 type=split_scg
    ...    UE31: Proxy \\(eNB 2 cell 1\\) reported successful RA
    
NSA UEs L3 Call And ENDC Succeed for UE32
    Execute Egate Command    ue_change_location id=32 enb=1 cell=1
    Execute Egate Command    ue_attach id=32    UE32: === UE IS ACTIVE
    Execute Egate Command    enb_endc_param selected_plmn=460:002 id=1
    Execute Egate Command    ue_dc_enb_start ue=32 target_gnb=2 target_cells=1 bearer=4,5 type=split_scg
    ...    UE32: Proxy \\(eNB 2 cell 1\\) reported successful RA

Check DL And UL Throughput
    Traffic Should Be Ok    ue_id=31    bearer_id=2    dl_mbps=5    ul_mbps=2    timeout=10    type=NSA
    Traffic Should Be Ok    ue_id=31    bearer_id=3    dl_mbps=5    ul_mbps=2    timeout=10    type=NSA
    Traffic Should Be Ok    ue_id=32    bearer_id=4    dl_mbps=5    ul_mbps=2    timeout=10    type=NSA
    Traffic Should Be Ok    ue_id=32    bearer_id=5    dl_mbps=5    ul_mbps=2    timeout=10    type=NSA
