*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 2DU
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    vDUCNF00    RAN_5G    RAN_Aic    CRT    CLOUD_5GC_dRNIC_2vDU_P_AP_LO_SWFH
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    team-L3SWCN1_SG14    owner-jun.3.ye    release-5G22R2
Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2du/1cell
@{PARAMS_IN_SCF_CU}    @{5GC005857_HO}    @{MultiPLMN}    @{A3A5_event}    @{AMF}    @{SNSSAI}
...    @{NRREL}    @{XnLink}    @{NRADJGNB}    @{NRADJNRCELL}
...    @{NRPLMNSET_TRACKINGAREA_Cell1}    @{NRPLMNSET_TRACKINGAREA_Cell2}

@{PARAMS_IN_SCF_DU1}    @{MultiPLMN}    @{DU_CELL1}    @{SNSSAI}    @{NRPLMNSET_TRACKINGAREA_Cell1}

@{PARAMS_IN_SCF_DU2}    @{MultiPLMN}    @{DU_CELL2}    @{SNSSAI}    @{NRPLMNSET_TRACKINGAREA_Cell2}

@{5GC005857_HO}
...    NRBTS:actRanSharing=true
...    NRBTS:actNgcFlexSaMode=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true
...    delete:NRCELL:trackingAreaDN
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=239

@{AMF}
...    NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked
...    NRBTS-1/SERVEDAMF-1:amfIPAddress=10.0.11.1

@{NRREL}
#cell1_cll2
...    NRCELL/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=false
#sim gnb3
...    NRCELL/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL/NRREL-2:gNbId=3
...    NRCELL/NRREL-2:gNbIdLength=22
...    NRCELL/NRREL-2:gnbPlmn:mcc=311
...    NRCELL/NRREL-2:gnbPlmn:mnc=489
...    NRCELL/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL/NRREL-2:handoverAllowedSA=allowed
...    NRCELL/NRREL-2:lcrId=1
...    NRCELL/NRREL-2:removeNotAllowed=false
#sim gnb5
...    NRCELL/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL/NRREL-3:gNbId=5
...    NRCELL/NRREL-3:gNbIdLength=22
...    NRCELL/NRREL-3:gnbPlmn:mcc=311
...    NRCELL/NRREL-3:gnbPlmn:mnc=489
...    NRCELL/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL/NRREL-3:handoverAllowedSA=allowed
...    NRCELL/NRREL-3:lcrId=1
...    NRCELL/NRREL-3:removeNotAllowed=false

@{A3A5_event}
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
...    NRCELL:sMeasConfigSsbRsrp=1

@{XnLink}
...    XNLINK-3:cPlaneIpAddr=10.0.12.11
...    XNLINK-5:cPlaneIpAddr=10.0.12.12

@{NRADJGNB}
...    NRADJGNB-3:administrativeState=Unlocked
...    NRADJGNB-3:gNodeBId=3
...    NRADJGNB-3:gNbIdLength=22
...    NRADJGNB-3:xnLinkRef=3
...    NRADJGNB-3:gnbPlmn:mcc=311
...    NRADJGNB-3:gnbPlmn:mnc=489
...    NRADJGNB-3:gnbPlmn:mncLength=3
...    NRADJGNB-5:administrativeState=Unlocked
...    NRADJGNB-5:gNodeBId=5
...    NRADJGNB-5:gNbIdLength=22
...    NRADJGNB-5:xnLinkRef=5
...    NRADJGNB-5:gnbPlmn:mcc=311
...    NRADJGNB-5:gnbPlmn:mnc=489
...    NRADJGNB-5:gnbPlmn:mncLength=3

@{NRADJNRCELL}
#sim gnb3
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:gNbId=3
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=636666
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:fiveGsTac=280
...    NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1}
#sim gnb5
...    NRADJNRCELL-2:cellDepType=SA
...    NRADJNRCELL-2:gNbId=5
...    NRADJNRCELL-2:gNbIdLength=22
...    NRADJNRCELL-2:lcrId=1
...    NRADJNRCELL-2:nrarfcn=636666
...    NRADJNRCELL-2:physCellId=382
...    NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRADJNRCELL-2/ADJ_NRPLMNSET_SA-1:fiveGsTac=280
...    NRADJNRCELL-2/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST}

@{DU_CELL1}
...    NRBTS:actRanSharing=true
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac
...    NRCELL-1/NRREL-1
...    NRCELL-1/NRREL-2
...    NRCELL-1/NRREL-3
...    NRADJNRCELL-1
...    NRADJNRCELL-2

@{DU_CELL2}
...    NRBTS:actRanSharing=true
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac
...    NRCELL-2/NRREL-1
...    NRCELL-2/NRREL-2
...    NRCELL-2/NRREL-3
...    NRADJNRCELL-1
...    NRADJNRCELL-2

@{MultiPLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    NRPLMN-2:mcc=311
...    NRPLMN-2:mnc=490
...    NRPLMN-2:mncLength=3

@{SNSSAI}
...    SNSSAI-1:administrativeState=Unlocked
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-1:sst=1
...    SNSSAI-1:sd=13714341

@{NRPLMNSET_TRACKINGAREA_Cell1}
...    TRACKINGAREA-1:fiveGsTac=100
...    TRACKINGAREA-1:snssaiList:snssaiDN=${snssaiDNList}
...    NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST}
...    NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-1
...    NRCELL-1/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST}

@{NRPLMNSET_TRACKINGAREA_Cell2}
...    TRACKINGAREA-2:fiveGsTac=200
...    TRACKINGAREA-2:snssaiList:snssaiDN=${snssaiDNList}
...    NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_2}
...    NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-2
...    NRCELL-2/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST}

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
${NRPLMNDNLIST_1}    MRBTS-1/NRBTS-1/NRPLMN-1
${NRPLMNDNLIST_2}    MRBTS-1/NRBTS-1/NRPLMN-2
${snssaiDNList}    MRBTS-1/NRBTS-1/SNSSAI-1

*** Test Cases ***
CB005857-ET-A019_5GC001630-ET-HA07_Verify_the_inter-gnb_HO_when_ue_use_non-standard_slice_when_MRL_present
    [Documentation]
    ...    1. UE with non-standard slice can trigger inter-gnb HO to same PLMN CELL if MRL present,
    ...    no matter target cell support only one or more PLMN(configed in ADJ_NRPLMNSET_SA-nrPlmnDNList).
    ...    2. UE with non-standard slice cannot trigger inter-gnb/intra-gnb HO to different PLMN CELL if MRL present
    ...    3. AMF1: PLMN1/PLMN2, SNSSAI-1
    ...       SNSSAI-1: PLMN1/PLMN2, non-standard slice
    ...       real gNB2 - CELL1(pci=50): PLMN1/PLMN2, CELL2(pci=51): PLMN2
    ...       sim gNB3 - CELL1(pci=381): PLMN1
    ...       sim gNB5 - CELL1(pci=382): PLMN1/PLMN2 (PR614520)
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
    [Tags]    QC_167222    PR614520
    Check XN Link is up
    Config MRL For UEs
    SA UE register and PDU setup    ue_id=1
    intra-gnb inter-DU inter-plmn HO Fail From CELL1 to CELL2
    inter-gnb inter-DU intra-plmn HO From real-gNB to sim-gNB3
    SA UE register and PDU setup    ue_id=2
    intra-gnb inter-DU intra-plmn HO From CELL1 to CELL2
    inter-gnb inter-DU inter-plmn HO Fail From real-gNB to sim-gNB3
    inter-gnb inter-DU intra-plmn HO From real-gNB to sim-gNB5
    Verify UEs Throughput should be ok
    Check Wireshark Log Aic    ${CURDIR}${/}a2a_CB005857_A19${/}a2a.ini    wait_string=InitialContextSetupResponse::4

*** Keywords ***
Modify Cfg Aic
    #sim gnb3
    ${set_gnb3}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.11.11 gnb_id=0x3:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.12.11 nssai=0x1:0xd143a5 amf=1 plmnList=311:489
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg Aic    ${set_gnb3}
    Update Cfg Aic    ${set_gnb3_cell1}
    Update Cfg Aic    gnb_make_plmnset plmn_set_id=1 dual_conn=off gnb=3 cell=1 tac=280 plmn_id_list=311:489
    Update Cfg Aic    gnb_set_nwslice_per_plmn gnb=3 cell=1 plmn_set_id=1 plmn=311:489 nssai=0x01:0xd143a5
    Update Cfg Aic    gnb_param id=3 xn_listening_socket=on send_xn_setup=false
    #sim gnb5
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.11.12 gnb_id=0x5:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.12.12 nssai=0x1:0xd143a5 amf=1 plmnList=311:489,311:490
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=127:1 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg Aic    ${set_gnb5}
    Update Cfg Aic    ${set_gnb5_cell1}
    Update Cfg Aic    gnb_make_plmnset plmn_set_id=2 dual_conn=off gnb=5 cell=1 tac=280 plmn_id_list=311:489,311:490
    Update Cfg Aic    gnb_set_nwslice_per_plmn gnb=5 cell=1 plmn_set_id=2 plmn=311:489 nssai=0x01:0xd143a5
    Update Cfg Aic    gnb_set_nwslice_per_plmn gnb=5 cell=1 plmn_set_id=2 plmn=311:490 nssai=0x01:0xd143a5
    Update Cfg Aic    gnb_param id=5 xn_listening_socket=on send_xn_setup=false
    #other
    ${set_ue2}    catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:490:0000:0:0:021645401 mode=nr enb=2 cell=1
    Update Cfg Aic    ${set_ue2}
    Update Cfg Aic    set_amf_region id=1 tac_list=100,200,280 plmn=311:489,311:490
    Update Cfg Aic    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=all

Check XN Link is up
    object should exist in cu    XNLINK-3:xnLinkStatus=available
    object should exist in cu    XNLINK-5:xnLinkStatus=available

Config MRL For UEs
    Execute Egate Command    amf_mobility_restriction_list_param id=1 equiv_plmn=311:489 sa_plmn=311:490 allowed_tacs=100,200,280
    Execute Egate Command    amf_mobility_restriction_list_param id=1    311:489
    Execute Egate Command    amf_ue_ics_param id=1 ue=all mobility_restriction_list_id=1

SA UE register and PDU setup
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1    QoS Routing Table
    Send Throughput    ${ue_id}
    Verify Throughput    ${ue_id}

intra-gnb inter-DU inter-plmn HO Fail From CELL1 to CELL2
    ${measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=636576    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${measid} event=A3 srsrp_nr=25 phycell_id=51 nrsrp_nr=85
    ...    fail_regexp=Intra-eNB handover

inter-gnb inter-DU intra-plmn HO From real-gNB to sim-gNB3
    ${measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=636576    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${measid} event=A3 srsrp_nr=25 phycell_id=381 nrsrp_nr=85    Inter-eNB handover

intra-gnb inter-DU intra-plmn HO From CELL1 to CELL2
    ${measid}    get nr meas id for specific type and frequency    ue_id=2    carrierfreq=636576    event_type=A5
    Execute Egate Command    ue_measurement_send_nr id=2 meas_id=${measid} event=A5 srsrp_nr=25 phycell_id=51 nrsrp_nr=85    Intra-eNB handover

inter-gnb inter-DU inter-plmn HO Fail From real-gNB to sim-gNB3
    ${measid}    get nr meas id for specific type and frequency    ue_id=2    carrierfreq=636576    event_type=A5
    Execute Egate Command    ue_measurement_send_nr id=2 meas_id=${measid} event=A5 srsrp_nr=25 phycell_id=381 nrsrp_nr=85
    ...    fail_regexp=Inter-eNB handover

inter-gnb inter-DU intra-plmn HO From real-gNB to sim-gNB5
    ${measid}    get nr meas id for specific type and frequency    ue_id=2    carrierfreq=636576    event_type=A5
    Execute Egate Command    ue_measurement_send_nr id=2 meas_id=${measid} event=A5 srsrp_nr=25 phycell_id=382 nrsrp_nr=85    Inter-eNB handover

Send Throughput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10    UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=10    UDP DL

Verify Throughput
    [Arguments]    ${ue_id}=1    ${sleep_time}=15s
    sleep    ${sleep_time}
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9.5
    Should Be True    ${dl_throuput}/1000>9.5

Verify UEs Throughput should be ok
    Verify Throughput    ue_id=1
    Verify Throughput    ue_id=2
