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

@{PARAMS_IN_SCF}    @{RanSharing}    @{MultiPLMN}    @{NRPLMNSET_SA_NSA}    @{SNSSAI}    @{TRACKINGAREA}

@{RanSharing}
...    NRBTS-1:actRanSharing=true

...    NRBTS-1:actNgcFlexSaMode=true
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac

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
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST}

...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST}

@{SNSSAI}
...    SNSSAI-1:sst=1
...    SNSSAI-1:sd=13714341
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-2:administrativeState=Unlocked
...    SNSSAI-2:sst=1
...    SNSSAI-2:sd=13714342
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-3:administrativeState=Unlocked
...    SNSSAI-3:sst=1
...    SNSSAI-3:sd=13714343
...    SNSSAI-3:nrPlmnDNList=${NRPLMNDNLIST}

@{TRACKINGAREA}
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3

*** Test Cases ***
5GC001630-ET-K007-K010_Verify_one_PLMN_and_two_slice_with_slice_change_in_the_gnb
    [Documentation]
    ...    1. K007: In different PLMN ue attach different Specify slices. Then check the specified slice information carried by PLMNs
    ...    2. K010: Specify different slices through ue attach in one PLMN. Then check the specified slice information carried by PLMN
    ...    3. Test Case Steps:
    ...         a. SA UE1 register on nwslice1
    ...         b. SA UE1 register on nwslice2
    ...         c. SA UEs register on different specify slice
    ...    4. Expected Results:
    ...         a. SA UE1 register successful on nwslice1
    ...         b. SA UE1 register successful on nwslice2
    ...         c. SA UEs register successful on different nwslice(UE1 on slice1/UE2 on slice2/UE3 on slice3)
    [Tags]    QC_60735
    sa ue register and pdu setup    ue_id=1    nwslice=1
    release ues    ue_id=1    ue_type=sa
    sa ue register and pdu setup    ue_id=1    nwslice=2
    release ues    ue_id=1    ue_type=sa
    SA register 3 different nwslice UEs
    check wireshark log    ${CURDIR}/a2a_K007_K010/a2a_slice_in_plmn.ini    wait_string=UEContextSetupResponse::10

*** Keywords ***
Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,200 plmn=311:489,311:402,311:403
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1
    ${set_ue1}    catenate    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    ${set_ue2}    catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:402:0000:0:0:021645401 mode=nr enb=2 cell=1
    ${set_ue3}    catenate    set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:403:0000:0:0:021645402 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue1}
    Update Cfg    ${set_ue2}
    Update Cfg    ${set_ue3}
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=all
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 amf=1 ue=all
    Update Cfg    set_nwslice id=3 snssai=0x01:0xD143A7 amf=1 ue=all

Perform Steps After Onair
    check wireshark log    ${CURDIR}/a2a_K007_K010/a2a_plmn_3slice.ini    wait_string=NGSetupResponse

sa ue register and pdu setup
    [Arguments]    ${ue_id}=1    ${nwslice}=1
    Execute Egate Command    ue_register id=${ue_id} nwslice=${nwslice}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${ue_id}    QoS Routing Table

SA register 3 different nwslice UEs
    sa ue register and pdu setup    ue_id=1    nwslice=1
    sa ue register and pdu setup    ue_id=2    nwslice=2
    sa ue register and pdu setup    ue_id=3    nwslice=3
