*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CRT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN3_SG2
...    owner-wen.y.xu    release-5G20A    5GC001630
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}    @{RanSharing_HO}    @{MultiPLMN}    @{NRPLMNSET_SA_NSA}    @{SNSSAI}    @{TRACKINGAREA}    @{NRREL}    @{NRADJGNB_3_5}
...    @{NRADJNRCELL}    @{XNLINK_3_5}    @{A3_A5_event}

@{RanSharing_HO}
...    NRBTS-1:actRanSharing=true
...    NRBTS-1:actRanSharingEnh=max_10_PLMNs
...    NRBTS-1:actNgcFlexSaMode=true
...    NRBTS-1:actIncXn=true
...    NRBTS-1:actConflictConfiguration=true
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
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1}

...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST_1}

@{SNSSAI}
...    delete:SNSSAI-1:sd
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST_1}

@{TRACKINGAREA}
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1

@{NRREL}
#sim gnb3
...    NRCELL-1/NRREL-1:gNbId=35
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
#sim gnb5
...    NRCELL-1/NRREL-2:gNbId=36
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:lcrId=1
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=402
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed

@{NRADJGNB_3_5}
...    NRADJGNB-3:administrativeState=Unlocked
...    NRADJGNB-3:gNodeBId=35
...    NRADJGNB-3:gNbIdLength=22
...    NRADJGNB-3:xnLinkRef=3
...    NRADJGNB-3:gnbPlmn:mcc=311
...    NRADJGNB-3:gnbPlmn:mnc=489
...    NRADJGNB-3:gnbPlmn:mncLength=3
...    NRADJGNB-5:administrativeState=Unlocked
...    NRADJGNB-5:gNodeBId=36
...    NRADJGNB-5:gNbIdLength=22
...    NRADJGNB-5:xnLinkRef=5
...    NRADJGNB-5:gnbPlmn:mcc=311
...    NRADJGNB-5:gnbPlmn:mnc=402
...    NRADJGNB-5:gnbPlmn:mncLength=3

@{NRADJNRCELL}
#sim gnb3
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=636666
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:fiveGsTac=0
...    NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1}
#sim gnb5
...    NRADJNRCELL-2:cellDepType=SA
...    NRADJNRCELL-2:gNbId=36
...    NRADJNRCELL-2:lcrId=1
...    NRADJNRCELL-2:nrarfcn=636666
...    NRADJNRCELL-2:physCellId=48
...    NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRADJNRCELL-2:gnbPlmn:mnc=402
...    NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRADJNRCELL-2/ADJ_NRPLMNSET_SA-1:fiveGsTac=0
...    NRADJNRCELL-2/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_2}

@{XNLINK_3_5}
...    XNLINK-3:cPlaneIpAddr=10.0.1.122
...    XNLINK-5:cPlaneIpAddr=10.0.1.124

@{A3_A5_event}
...    NRBTS-1:cipherPrefL:nea0=9
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL:a5MeasEnabled=rsrp
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=50
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=60
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms40
...    NRCELL:absThreshSsbRsrpConsolidation=1

${NRPLMNDNLIST_1}    MRBTS-1/NRBTS-1/NRPLMN-1
${NRPLMNDNLIST_2}    MRBTS-1/NRBTS-1/NRPLMN-2

@{outgoing_incoming_inter-gnb_ho}
...    NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${SUCC_OG_INTER_GNB_HO_SA_PLMN}=2
...    NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${SUCC_IC_INTER_GNB_HOP_SA_PLMN}=1

${SUCC_OG_INTER_GNB_HO_SA_PLMN}    M55145C00342    #The number of successful outgoing intra-frequency inter-gNB HOs for SA per PLMN-ID
${SUCC_IC_INTER_GNB_HOP_SA_PLMN}    M55145C00361    #The number of successful incoming inter-gNB HO preparations for SA per PLMN-ID

*** Test Cases ***
5GC001630-ET-HA04_Verify_Successful_inter-gNB_HO_for_SA_user_in_shared_gNB_with_PLMN_change_when_no_MRL_defined
    [Documentation]
    ...    1. UE with standard slice can trigger inter-gnb HO to same/different PLMN CELL no matter MRL
    ...    2. AMF1: TAC200, PLMN1 SNSSAI-1, PLMN2 SNSSAI-1
    ...       TAC200: SNSSAI-1
    ...       SNSSAI-1: PLMN1/PLMN2, standard slice
    ...       real gNB2 CELL1: PLMN1 SNSSAI-1
    ...       sim gNB3 CELL1: PLMN1 SNSSAI-1
    ...       sim gNB5 CELL1: PLMN2 SNSSAI-1
    ...       UE1/UE2: PLMN1
    ...       UE3: PLMN2
    ...    3. Test Case Steps:
    ...       a. set all XN link setup
    ...       b. UE1/UE2 register on real gnb cell1; UE3 register on sim gnb5 cell1; do traffic
    ...       c. UE1 HO from real gNB to sim gNB3 trigger by A3
    ...       d. UE2 HO from real gNB to sim gNB5 trigger by A5
    ...       e. UE3 HO from sim gNB4 to real gNB trigger by A5
    ...    4. Expected Results:
    ...       a. All XN link is up
    ...       b. UEs register successful and traffic should be ok and not contains MRL information
    ...       c. UE1 HO successful in same PLMN CELL and update the relevant counter
    ...       d. UE2 HO successful in different PLMN CELL and update the relevant counter
    ...       e. UE3 HO successful in different PLMN CELL and update the relevant counter
    [Tags]    QC_47203
    Check All XN Links is up
    Add UE3 History Information List
    UEs Call Setup On AMF1 Which Support PLMN And nwslice
    UE1 HO from real gNB to sim gNB3 trigger by A3
    UE2 HO from real gNB to sim gNB5 trigger by A5
    UE3 HO from sim gNB5 to real gNB trigger by A5
    check counters    ${outgoing_incoming_inter-gnb_ho}

*** Keywords ***
Modify Cfg
    #sim gnb3
    ${set_gnb3}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.122 nssai=0x1:0xFFFFFF amf=1 plmnList=311:489
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb3}
    Update Cfg    ${set_gnb3_cell1}
    Update Cfg    gnb_make_plmnset plmn_set_id=1 dual_conn=off gnb=3 cell=1 tac=0 plmn_id_list=311:489
    Update Cfg    gnb_set_nwslice_per_plmn gnb=3 cell=1 plmn_set_id=1 plmn=311:489 nssai=0x01:0xFFFFFF
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=false
    #sim gnb5
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:402 ng=10.0.1.125 gnb_id=0x24:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.124 nssai=0x1:0xFFFFFF amf=1 plmnList=311:402
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=16:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb5}
    Update Cfg    ${set_gnb5_cell1}
    Update Cfg    gnb_make_plmnset plmn_set_id=2 dual_conn=off gnb=5 cell=1 tac=0 plmn_id_list=311:402
    Update Cfg    gnb_set_nwslice_per_plmn gnb=5 cell=1 plmn_set_id=2 plmn=311:402 nssai=0x01:0xFFFFFF
    Update Cfg    gnb_param id=5 xn_listening_socket=on send_xn_setup=false sib1_period=40
    #other
    ${set_ue3}    catenate    set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:402:0000:0:0:021645402 mode=nr enb=5 cell=1
    Update Cfg    ${set_ue3}
    Update Cfg    set_amf_region id=1 tac_list=0,200 plmn=311:489,311:402
    Update Cfg    set_nwslice id=1 snssai=0x01:0xFFFFFF amf=1 default=on ue=all

Check All XN Links is up
    object should exist    XNLINK-3:xnLinkStatus=available
    object should exist    XNLINK-5:xnLinkStatus=available

UEs Call Setup On AMF1 Which Support PLMN And nwslice
    FOR    ${ue_id}    IN RANGE    1    4
        sa ue register and pdu setup    ue_id=${ue_id}    nwslice=1   cmd_regexp=AMF-1:.*NG RM Registered
        Traffic Should Be OK    ue_id=${ue_id}    type=sa
    END

sa ue register and pdu setup
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Registered
    Execute Egate Command    ue_register id=${ue_id} nwslice=${nwslice}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${ue_id}    QoS Routing Table

UE1 HO from real gNB to sim gNB3 trigger by A3
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=25 srsrq_nr=10 phycell_id=381 nrsrp_nr=85 nrsrq_nr=50
    ...    Inter-eNB handover

UE2 HO from real gNB to sim gNB5 trigger by A5
    Execute Egate Command    ue_measurement_send_nr id=2 meas_id=2 event=A5 srsrp_nr=25 srsrq_nr=10 phycell_id=48 nrsrp_nr=85 nrsrq_nr=50
    ...    Inter-eNB handover

UE3 HO from sim gNB5 to real gNB trigger by A5
    Execute Egate Command    ue_measurement_send_nr id=3 meas_id=5 event=A5 srsrp_nr=10 srsrq_nr=10 phycell_id=50 nrsrp_nr=85 nrsrq_nr=50
    ...    Inter-eNB handover

Add UE3 History Information List
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:402|0x01 gnb_id=5 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=1 action=commit    committed
    Execute Egate Command    ue_enb_param id=3 ue_history_list=1
