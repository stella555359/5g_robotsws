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
...    NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-100
...    NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST}
...    NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_2}

...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST}

@{SNSSAI}
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}

@{TRACKINGAREA}
...    TRACKINGAREA-100:fiveGsTac=100
...    TRACKINGAREA-100:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1

@{NRREL}
#real gnb cell2
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
#real gnb cell1
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
#sim gnb3
...    NRCELL/NRREL-2:gNbId=35
...    NRCELL/NRREL-2:gNbIdLength=22
...    NRCELL/NRREL-2:lcrId=1
...    NRCELL/NRREL-2:gnbPlmn:mcc=311
...    NRCELL/NRREL-2:gnbPlmn:mnc=489
...    NRCELL/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL/NRREL-2:handoverAllowedSA=allowed
#sim gnb5
...    NRCELL/NRREL-3:gNbId=36
...    NRCELL/NRREL-3:gNbIdLength=22
...    NRCELL/NRREL-3:lcrId=1
...    NRCELL/NRREL-3:gnbPlmn:mcc=311
...    NRCELL/NRREL-3:gnbPlmn:mnc=489
...    NRCELL/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL/NRREL-3:handoverAllowedSA=allowed

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
...    NRADJGNB-5:gnbPlmn:mnc=489
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
...    NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRADJNRCELL-2/ADJ_NRPLMNSET_SA-1:fiveGsTac=0
...    NRADJNRCELL-2/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST}

@{XNLINK_3_5}
...    XNLINK-3:cPlaneIpAddr=10.0.1.122
...    XNLINK-5:cPlaneIpAddr=10.0.1.124

@{A3_A5_event}
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

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
${NRPLMNDNLIST_1}    MRBTS-1/NRBTS-1/NRPLMN-1
${NRPLMNDNLIST_2}    MRBTS-1/NRBTS-1/NRPLMN-2

${PLMN1}    311:489
${PLMN2}    311:402

*** Test Cases ***
5GC001630-ET-HA07_Verify_the_inter-gnb_HO_when_ue_use_non-standard_slice_when_MRL_present
    [Documentation]
    ...    1. UE with non-standard slice can trigger inter-gnb HO to same PLMN CELL if MRL present,
    ...    no matter target cell support only one or more PLMN(configed in ADJ_NRPLMNSET_SA-nrPlmnDNList).
    ...    2. UE with non-standard slice cannot trigger inter-gnb/intra-gnb HO to different PLMN CELL if MRL present
    ...    3. AMF1: PLMN1/PLMN2, SNSSAI-1
    ...       SNSSAI-1: PLMN1/PLMN2, non-standard slice
    ...       real gNB2 - CELL1: PLMN1/PLMN2, CELL2: PLMN2
    ...       sim gNB3 - CELL1: PLMN1
    ...       sim gNB5 - CELL1: PLMN1/PLMN2 (PR614520)
    ...       UE1: PLMN1
    ...       UE2: PLMN2
    ...    4. Test Case Steps:
    ...       a. set all XN link setup
    ...       b. Configure MRL of AMF1 for UEs
    ...       c. SA UE1 register (PLMN1)
    ...       d. UE1 tigger Intra-gnb HO from CELL1 to CELL2(PLMN2)
    ...       e. UE1 tigger Inter-gnb HO from real-gNB to sim-gNB3(PLMN1)
    ...       f. SA UE2 register (PLMN2)
    ...       g. UE2 tigger Inter-gnb HO from real-gNB to sim-gNB3(PLMN1)
    ...       h. UE2 tigger Inter-gnb HO from real-gNB to sim-gNB5(PLMN1/PLMN2)
    ...    5. Expected Results:
    ...       a. All XN link is up
    ...       b. Mobility Restriction List for UEs contains PLMN1 as equivalent PLMN
    ...       c. SA UE1 register successful and Contains MRL information
    ...       d. not initiate HO because different PLMN CELL
    ...       e. HO successful because same PLMN CELL
    ...       f. SA UE1 register successful and Contains MRL information
    ...       g. not initiate HO because different PLMN CELL
    ...       h. HO successful because same PLMN CELL
    [Tags]    QC_47202    PR614520
    Check All XN Links is up
    Configure MRL of AMF1 for UEs
    sa ue register and pdu setup    ue_id=1
    UE1 tigger Intra-gnb inter-plmn HO fail from CELL1 to CELL2
    UE1 tigger Inter-gnb intra-plmn HO from real-gNB to sim-gNB3
    sa ue register and pdu setup    ue_id=2
    UE2 tigger Intra-gnb intra-plmn HO From CELL1 to CELL2
    UE2 tigger Inter-gnb inter-plmn HO fail from real-gNB to sim-gNB3
    UE2 tigger Inter-gnb intra-plmn HO from real-gNB to sim-gNB5
    Verify UEs Throughput should be ok
    check wireshark log    ${CURDIR}/a2a_HA07/a2a.ini    wait_string=InitialContextSetupResponse::4

*** Keywords ***
Modify Cfg
    #sim gnb3
    ${set_gnb3}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1 plmnList=311:489
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb3}
    Update Cfg    ${set_gnb3_cell1}
    Update Cfg    gnb_make_plmnset plmn_set_id=1 dual_conn=off gnb=3 cell=1 tac=0 plmn_id_list=311:489
    Update Cfg    gnb_set_nwslice_per_plmn gnb=3 cell=1 plmn_set_id=1 plmn=311:489 nssai=0x01:0xd143a5
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=false
    #sim gnb5
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x24:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.124 nssai=0x1:0xd143a5 amf=1 plmnList=311:489,311:402
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=16:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb5}
    Update Cfg    ${set_gnb5_cell1}
    Update Cfg    gnb_make_plmnset plmn_set_id=2 dual_conn=off gnb=5 cell=1 tac=0 plmn_id_list=311:489,311:402
    Update Cfg    gnb_set_nwslice_per_plmn gnb=5 cell=1 plmn_set_id=2 plmn=311:489 nssai=0x01:0xd143a5
    Update Cfg    gnb_set_nwslice_per_plmn gnb=5 cell=1 plmn_set_id=2 plmn=311:402 nssai=0x01:0xd143a5
    Update Cfg    gnb_param id=5 xn_listening_socket=on send_xn_setup=false
    #other
    Update Cfg    set_amf_region id=1 tac_list=0,100,200 plmn=311:489,311:402
    ${set_ue2}    catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:402:0000:0:0:021645401 mode=nr enb=2 cell=1
    Update Cfg    ${set_ue2}
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=all

Check All XN Links is up
    object should exist    XNLINK-3:xnLinkStatus=available
    object should exist    XNLINK-5:xnLinkStatus=available

Configure MRL of AMF1 for UEs
    Execute Egate Command    amf_mobility_restriction_list_param id=1 equiv_plmn=${PLMN1} sa_plmn=${PLMN2}
    Execute Egate Command    amf_mobility_restriction_list_param id=1    ${PLMN1}
    Execute Egate Command    amf_ue_ics_param id=1 ue=all mobility_restriction_list_id=1

sa ue register and pdu setup
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1    QoS Routing Table
    Send Throughput    ${ue_id}
    Verify Throughput    ${ue_id}

UE1 tigger Intra-gnb inter-plmn HO fail from CELL1 to CELL2
    ${measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=636576    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${measid} event=A3 srsrp_nr=25 phycell_id=51 nrsrp_nr=85
    ...    fail_regexp=Intra-eNB handover

UE1 tigger Inter-gnb intra-plmn HO from real-gNB to sim-gNB3
    ${measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=636576    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${measid} event=A3 srsrp_nr=25 phycell_id=381 nrsrp_nr=85    Inter-eNB handover

UE2 tigger Intra-gnb intra-plmn HO From CELL1 to CELL2
    ${measid}    get nr meas id for specific type and frequency    ue_id=2    carrierfreq=636576    event_type=A5
    Execute Egate Command    ue_measurement_send_nr id=2 meas_id=${measid} event=A5 srsrp_nr=25 phycell_id=51 nrsrp_nr=85    Intra-eNB handover

UE2 tigger Inter-gnb inter-plmn HO fail from real-gNB to sim-gNB3
    ${measid}    get nr meas id for specific type and frequency    ue_id=2    carrierfreq=636576    event_type=A5
    Execute Egate Command    ue_measurement_send_nr id=2 meas_id=${measid} event=A5 srsrp_nr=25 phycell_id=381 nrsrp_nr=85
    ...    fail_regexp=Inter-eNB handover

UE2 tigger Inter-gnb intra-plmn HO from real-gNB to sim-gNB5
    ${measid}    get nr meas id for specific type and frequency    ue_id=2    carrierfreq=636576    event_type=A5
    Execute Egate Command    ue_measurement_send_nr id=2 meas_id=${measid} event=A5 srsrp_nr=25 phycell_id=48 nrsrp_nr=85    Inter-eNB handover

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

Verify UEs Throughput should be ok
    Verify Throughput    ue_id=1
    Verify Throughput    ue_id=2
