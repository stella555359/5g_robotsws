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

@{PARAMS_IN_SCF}    @{RanSharing_HO}    @{MultiPLMN}    @{NRPLMNSET_SA_NSA}    @{SNSSAI}    @{TRACKINGAREA}    @{NRREL}    @{A3_event}

@{RanSharing_HO}
...    NRBTS-1:actRanSharing=true
...    NRBTS-1:actRanSharingEnh=max_10_PLMNs
...    NRBTS-1:actNgcFlexSaMode=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac

@{MultiPLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    NRPLMN-2:mcc=311
...    NRPLMN-2:mnc=402
...    NRPLMN-2:mncLength=3

@{NRPLMNSET_SA_NSA}
...    NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-100
...    NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1}
...    NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_2}

...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST}

@{SNSSAI}
...    delete:SNSSAI-1:sd
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}

@{TRACKINGAREA}
...    TRACKINGAREA-100:fiveGsTac=100
...    TRACKINGAREA-100:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1

@{NRREL}
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:lcrId=1

@{A3_event}
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-2:a3MeasEnabled=rsrp

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
${NRPLMNDNLIST_1}    MRBTS-1/NRBTS-1/NRPLMN-1
${NRPLMNDNLIST_2}    MRBTS-1/NRBTS-1/NRPLMN-2

*** Test Cases ***
5GC001630-ET-HA01_Verify_Forbid_intra-du_HO_for_SA_user_in_shared_gNB_with_PLMN_change_when_MRL_present
    [Documentation]
    ...    1. PR650358: 5G-CP-CU shall forbid the intra-DU inter-PLMN handover (as per 5G_CP_MM_760) as UE CONTEXT MODIFICATION REQUEST
    ...       (5G_CP_IF_NTW_1187) message doesn't contain information about ServingPLMN thus CU is not able to inform DU about newly selected
    ...       PLMN for a target cell
    ...    2. NRCELL-1: PLMN1, NRCELL-2: PLMN2
    ...    3. Test Case Steps:
    ...       a. Configure MRL of AMF1 for UEs
    ...       b. SA UE2 register (PLMN2) on CELL2
    ...       c. UE2 tigger Intra-gnb inter-plmn HO from CELL2 to CELL1
    ...    4. Expected Results:
    ...       a. Mobility Restriction List for UEs contains PLMN1 as equivalent PLMN
    ...       b. SA UE2 register successful on Cell2 and Contains MRL information
    ...       c. HO fails due to intra-du inter-plmn
    [Tags]    QC_60727    PR650358
    Configure MRL of AMF1 for UEs
    sa ue register and pdu setup    ue_id=2
    Traffic Should Be OK    ue_id=2    type=sa
    UE2 Tirgger Intra-Freq Intra-DU inter-plmn HO Fails from Cell2 To Cell1
    file should contain strings    ${SAVE LOG DIRECTORY}/btslog.LOG    Prevent intra DU inter PLMN handover

*** Keywords ***
Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,100,200 plmn=311:489,311:402
    ${set_gnb2_cell1}    catenate    set_cell id=1 gnb=2 pci=16:2 tac=100 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    ${set_gnb2_cell2}    catenate    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb2_cell1}
    Update Cfg    ${set_gnb2_cell2}
    ${set_ue2}    catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:402:0000:0:0:021645401 mode=nr enb=2 cell=2
    Update Cfg    ${set_ue2}
    Update Cfg    set_nwslice id=1 snssai=0x01:0xFFFFFF default=on ue=all amf_region_id=1 plmn_list=311:489,311:402

Configure MRL of AMF1 for UEs
    Execute Egate Command    amf_mobility_restriction_list_param id=1 equiv_plmn=311:489 sa_plmn=311:402
    Execute Egate Command    amf_mobility_restriction_list_param id=1    311:489
    Execute Egate Command    amf_ue_ics_param id=1 ue=all mobility_restriction_list_id=1

sa ue register and pdu setup
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}    QoS Routing Table

UE2 Tirgger Intra-Freq Intra-DU inter-plmn HO Fails from Cell2 To Cell1
    ${measid}    get nr meas id for specific type and frequency    ue_id=2    carrierfreq=636576    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=2 meas_id=${measid} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=80 nrsrq_nr=20
    ...    fail_regexp=Intra-eNB handover
