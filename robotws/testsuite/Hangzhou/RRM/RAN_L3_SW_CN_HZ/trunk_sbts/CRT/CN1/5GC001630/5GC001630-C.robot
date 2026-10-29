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

@{PARAMS_IN_SCF}    @{RanSharing_HO}    @{MultiAMF}    @{MultiPLMN}    @{NRPLMNSET_SA_NSA}    @{SNSSAI}    @{TRACKINGAREA}    @{NRREL}
...    @{NRADJGNB}    @{NRADJNRCELL}    @{NRHOIF}    @{event_A2A3}

@{RanSharing_HO}
...    NRBTS-1:actRanSharing=true
...    NRBTS-1:actRanSharingEnh=max_10_PLMNs
...    NRBTS-1:actNgcFlexSaMode=true
...    NRBTS-1:ngUeRetentionEnabled=true
...    delete:NRCELL:configuredEpsTac
...    delete:NRCELL:trackingAreaDN
...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS-1:actIntraFreqInterGnbMobilityNSA3x=true

@{MultiAMF}
...    SERVEDAMF-1:amfIPAddress=10.0.1.1
...    SERVEDAMF-2:amfIPAddress=10.0.1.102
...    SERVEDAMF-3:amfIPAddress=10.0.1.103
...    SERVEDAMF-4:amfIPAddress=10.0.1.104

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
...    NRPLMN-7:mcc=460
...    NRPLMN-7:mnc=402
...    NRPLMN-7:mncLength=3

@{NRPLMNSET_SA_NSA}
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-100
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_SA_1_2}
...    NRCELL/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-2:nrPlmnDNList=${NRPLMNDNLIST_SA_3_4}

...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST_NSA_5_6}

@{SNSSAI}
...    SNSSAI-1:administrativeState=Unlocked
...    SNSSAI-1:sst=1
...    SNSSAI-1:sd=13714341
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST_SA_1_2_3}
...    SNSSAI-2:administrativeState=Unlocked
...    SNSSAI-2:sst=1
...    SNSSAI-2:sd=13714341
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST_SA_4}

@{TRACKINGAREA}
...    TRACKINGAREA-100:fiveGsTac=100
...    TRACKINGAREA-100:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-100:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2

@{NRREL}
...    NRCELL-1/NRREL-1:gNbId=3
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=460
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=402
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

@{NRADJGNB}
...    NRADJGNB-3:administrativeState=Unlocked
...    NRADJGNB-3:gNodeBId=3
...    NRADJGNB-3:gNbIdLength=22
...    NRADJGNB-3:gnbPlmn:mcc=460
...    NRADJGNB-3:gnbPlmn:mnc=402
...    NRADJGNB-3:gnbPlmn:mncLength=3
...    delete:NRADJGNB-3:xnLinkRef

@{NRADJNRCELL}
...    NRADJNRCELL-1:cellDepType=NSA
...    NRADJNRCELL-1:freqBandIndicatorNR=261
...    NRADJNRCELL-1:gNbId=3
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=2071591
...    NRADJNRCELL-1:physCellId=384
...    NRADJNRCELL-1:gnbPlmn:mcc=460
...    NRADJNRCELL-1:gnbPlmn:mnc=402
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-1:ssbFrequency=2071387
...    NRADJNRCELL-1/ADJ_NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST_7}

@{NRHOIF}
...    NRHOIF-1:cellDepType=NSA
...    NRHOIF-1:a3MeasEnabled=rsrp
...    NRHOIF-1:freqBandIndicatorNR=261
...    NRHOIF-1:ifhoSsbScs=120 KHz
...    NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRHOIF-1:ssBurstSetPeriod=20
...    NRHOIF-1:ssbFrequency=2071387
...    NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0

@{event_A2A3}
...    NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=0
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:sMeasConfigSsbRsrp=1
...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRCELL-1:a3MeasEnabled=rsrp

${NRPLMNDNLIST_SA_1_2_3}    MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3
${NRPLMNDNLIST_SA_4}    MRBTS-1/NRBTS-1/NRPLMN-4
${NRPLMNDNLIST_SA_1_2}    MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
${NRPLMNDNLIST_SA_2_1}    MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-1
${NRPLMNDNLIST_SA_3_4}    MRBTS-1/NRBTS-1/NRPLMN-3,MRBTS-1/NRBTS-1/NRPLMN-4
${NRPLMNDNLIST_NSA_5_6}    MRBTS-1/NRBTS-1/NRPLMN-5,MRBTS-1/NRBTS-1/NRPLMN-6
${NRPLMNDNLIST_NSA_6_5}    MRBTS-1/NRBTS-1/NRPLMN-6,MRBTS-1/NRBTS-1/NRPLMN-5
${NRPLMNDNLIST_7}    MRBTS-1/NRBTS-1/NRPLMN-7

@{SA_UE_list}    1    2    3    4

@{fault_7317}    fault_id=7317    fault_name=NG Setup retry stopped

@{HO_Counter}
...    NRCELL-1/PLMN-PLMN/MCC-311/MNC-405:${ATT_OG_INTER_GNB_HO_NSA_PLMN}=1
...    NRCELL-1/PLMN-PLMN/MCC-311/MNC-405:${SUCC_OG_INTER_GNB_HO_NSA_PLMN}=1
...    NRCELL-1/PLMN-PLMN/MCC-311/MNC-405:${SUCC_IC_INTER_GNB_HOP_NSA_PLMN}=1
...    NRCELL-1/PLMN-PLMN/MCC-311/MNC-405:${SUCC_IC_INTER_GNB_HO_NSA_PLMN}=1
${ATT_OG_INTER_GNB_HO_NSA_PLMN}    M55145C00151    #The number of outgoing inter-gNB PS-Cell change attempts for NSA 3x per PLMN
${SUCC_OG_INTER_GNB_HO_NSA_PLMN}    M55145C00152    #The number of successful outgoing inter-gNB PS-Cell changes for NSA 3x per PLMN
${SUCC_IC_INTER_GNB_HOP_NSA_PLMN}    M55145C00162    #The number of successful incoming inter-gNB PS-Cell change preparations for NSA 3x per PLMN
${SUCC_IC_INTER_GNB_HO_NSA_PLMN}    M55145C00163    #The number of successful incoming inter-gNB PS-Cell change for NSA 3x per PLMN

*** Test Cases ***
5GC001630-ET-C001_Verify_cell_is_both_type_with_6_PLMNs
    [Documentation]
    ...    1. The purpose of this test case is to support multi SA plmnsets and one NSA plmnset
    ...       SNSSAI-1:PLMN1/PLMN2/PLMN3
    ...       SNSSAI-2:PLMN4
    ...       2 slices have the same sd/sst, but the supported nrPlmnDNList is not the same
    ...       AMF1 - PLMN1
    ...       AMF2 - PLMN2
    ...       AMF3 - PLMN3
    ...       AMF4 - PLMN4
    ...    2. Test Case Steps:
    ...       a. Lock Unlock SNSSAI
    ...          1) lock SNSSAI-1
    ...          2) unlock SNSSAI-1 and lock SNSSAI-2 at the same time
    ...          3) unlock all SNSSAIs
    ...       b. Lock Unlock AMF4 and SNSSAI-2 (EDA-03051211)
    ...          1) lock AMF4 -> lock SNSSAI-2 -> unlock AMF4
    ...          2) lock AMF4 -> unlock SNSSAI-2 -> unlock AMF4
    ...       c. online change the PLMN order of NRPLMNSET_SA:nrPlmnDNList (EDA-PR703579 belongs to 5GC001630-F)
    ...       d. multi SA UEs register and do traffic
    ...       e. multi NSA UEs attach and do traffic
    ...    3. Expected Results:
    ...       a. 1) CP-RT should send F1 GNB-DU CONFIGURATION UPDATE
    ...             Served_Cells_To_Modify_Item should contain served_Cell_Information->servedPLMNs->
    ...             pLMN_Identity = NRPLMN-4
    ...             SliceSupportList = {sST : 01, sD : d143a5}
    ...          2) CP-RT should send F1 GNB-DU CONFIGURATION UPDATE
    ...             Served_Cells_To_Modify_Item should contain served_Cell_Information->servedPLMNs->
    ...             pLMN_Identity = NRPLMN-1/NRPLMN-2/NRPLMN-3
    ...             SliceSupportList = {sST : 01, sD : d143a5}
    ...          3) CP-RT should send F1 GNB-DU CONFIGURATION UPDATE contains all pLMN_Identity and SliceSupportList
    ...       b. 1) AMF4 respond NGSetupFailure due to slice parameter was not match(Since SNSSAI-2 is now Locked) -> fault_7317 raised
    ...          2) gNB setup NgLink between the AMF. Nglink is up -> fault_7317 cleared
    ...       c. cell can normal onair and not has any alarm
    ...       d. SA UEs register successful and traffic should be ok
    ...       e. NSA UEs attach successful and traffic should be ok
    [Tags]    QC_47199    EDA-03051211    EDA-PR703579    EDA-PR724834    5GC001630-J007
    Lock Unlock SNSSAI    #PR724834
    Lock Unlock AMF4 and SNSSAI-2    #EDA-03051211
    Online change the PLMN order of nrPlmnDNList    #EDA-PR703579
    multi SA UEs register and do traffic
    multi NSA UEs attach and do traffic
    Release Ues    ue_type=all
    NSA UE inter-freq inter-gNB inter-PLMN PS-Cell change
    Check Counters    ${HO_Counter}
    Check WireShark Log    ${CURDIR}/a2a_C001/a2a.ini    wait_string=GNBDUConfigurationUpdateAcknowledge::10

*** Keywords ***
Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,100 plmn=311:489
    Update Cfg    set_amf_region id=2 tac_list=0,100 plmn=311:402
    Update Cfg    set_amf_region id=3 tac_list=0,200 plmn=311:403
    Update Cfg    set_amf_region id=4 tac_list=0,200 plmn=311:404
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1 name=SimModeAMF1
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=2 set_id=2 pointer=1 name=SimModeAMF2
    Update Cfg    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.1.103:38412 region=3 set_id=3 pointer=1 name=SimModeAMF3
    Update Cfg    set_amf id=4 daemon=10.0.2.1:22222 ng=10.0.1.104:38412 region=4 set_id=4 pointer=1 name=SimModeAMF4
    Update Cfg Param    set_ue simulated id=1 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    Update Cfg Param    set_ue simulated id=2 suci=0:311:402:0000:0:0:021645401 mode=nr enb=2 cell=1
    Update Cfg Param    set_ue simulated id=3 suci=0:311:403:0000:0:0:021645402 mode=nr enb=2 cell=1
    Update Cfg Param    set_ue simulated id=4 suci=0:311:404:0000:0:0:021645403 mode=nr enb=2 cell=1
    Update Cfg Param    set_ue simulated id=31 imsi=311:405:21645404
    Update Cfg Param    set_ue simulated id=32 imsi=311:406:21645405
    Update Cfg Param    ue_param id=31 ue_nr_capabilities=${Capa_NON_CA_NSA_NR_N78_N261} ue_eutra_nr_capabilities=${Capa_NON_CA_NSA_EUTRA_N78_N261}
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1-4 default=on ue=all
    #sim gnb3
    Update Cfg    set_gnb id=3 s1u=10.0.1.122 plmn=460:402 gnb_id=0x3 type=simulated daemon=10.0.2.1:22222 x2=10.0.1.122:36422
    ${sim_gnb3_cell1}    catenate    set_cell id=1 gnb=3 tac=0 pci=128:0 proxy=10.0.2.1:22223 nrci=0x01 nr_arfcn=2071591:2071591 tdd_cell=on
    ...    gscn=22446 mandatory_for_activation=off
    Update Cfg    ${sim_gnb3_cell1}
    Update Cfg    gnb_endc_param id=3 use_nr_ran_cont=on scg_dl_dist_percent=0 enable_dud_poll_bit=0

multi SA UEs register and do traffic
    FOR    ${ue_id}    IN    @{SA_UE_list}
         sa ue register and pdu setup    ue_id=${ue_id}
         Traffic Should Be OK    ue_id=${ue_id}    type=sa
    END

multi NSA UEs attach and do traffic
     nsa ue register    ue_id=31    selected_plmn=311:405
     Traffic Should Be OK    ue_id=31    type=nsa
     nsa ue register    ue_id=32    selected_plmn=311:406
     Traffic Should Be OK    ue_id=32    type=nsa

sa ue register and pdu setup
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}    QoS Routing Table

nsa ue register
    [Arguments]    ${ue_id}=1    ${selected_plmn}=311:489
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    enb_endc_param id=1 selected_plmn=${selected_plmn} include_hrl_in_sgnb_mod_req=on
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    reported successful RA

Lock Unlock SNSSAI
    ${slice1_lock_slice2_unlock}    create list    SNSSAI-1:administrativeState=Locked    SNSSAI-2:administrativeState=Unlocked
    delta commission parameters    ${slice1_lock_slice2_unlock}
    ${slice1_unlock_slice2_lock}    create list    SNSSAI-1:administrativeState=Unlocked    SNSSAI-2:administrativeState=Locked
    delta commission parameters    ${slice1_unlock_slice2_lock}
    ${all_slice_unlock}    create list    SNSSAI-1:administrativeState=Unlocked    SNSSAI-2:administrativeState=Unlocked
    delta commission parameters    ${all_slice_unlock}
    cells should be onair

Lock Unlock AMF4 and SNSSAI-2
    delta commission parameters    SERVEDAMF-4:administrativeState=Locked
    object should exist    SERVEDAMF-4:ngLinkStatus=Inactive
    delta commission parameters    SNSSAI-2:administrativeState=Locked
    delta commission parameters    SERVEDAMF-4:administrativeState=Unlocked
    object should exist    SERVEDAMF-4:ngLinkStatus=Inactive
    fm fault should be raised    ${fault_7317}
    delta commission parameters    SERVEDAMF-4:administrativeState=Locked
    delta commission parameters    SNSSAI-2:administrativeState=Unlocked
    delta commission parameters    SERVEDAMF-4:administrativeState=Unlocked
    object should exist    SERVEDAMF-4:ngLinkStatus=Active
    fm fault should be cleared    ${fault_7317}

Online change the PLMN order of nrPlmnDNList
    ${params}    create list    NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_SA_2_1}
    ...    NRCELL-1/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST_NSA_6_5}
    delta commission parameters    ${params}
    Check No New Active Faults

NSA UE inter-freq inter-gNB inter-PLMN PS-Cell change
    setup X2 link to gNBs
    set HRL for UE31
    nsa ue register    ue_id=31    selected_plmn=311:405
    Traffic Should Be OK    ue_id=31    type=NSA
    HO from real gNB2 to sim gNB3
    HO from sim gNB3 to real gNB2
    Traffic Should Be OK    ue_id=31    type=NSA

setup X2 link to gNBs
    Execute Egate Command    enb_x2_link_up enb=1 target=2    is up
    Execute Egate Command    enb_x2_link_up enb=1 target=3    is up
    object should exist    LTEENB:x2LinkStatus=available

set HRL for UE31
    Execute Egate Command    mme_ho_restriction_list equiv_plmn=460:402 id=1
    Execute Egate Command    ue_mme_param id=31 ho_restriction_list_id=1 ho_restrictions=lte,la hrl_dl_nas=on

HO from real gNB2 to sim gNB3
    ${A2_measid}    get nr meas id for specific type and frequency    ue_id=31    carrierfreq=636576    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=${A2_measid} event=A2 srsrp_nr=30 srsrq_nr=30    eventA3
    ${A3_measid}    get nr meas id for specific type and frequency    ue_id=31    carrierfreq=2071387    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=${A3_measid} event=A3 srsrp_nr=19 srsrq_nr=19 phycell_id=384 nrsrp_nr=31 nrsrq_nr=31
    ...    Bearer-type change from MCG to SCG-split is successful

HO from sim gNB3 to real gNB2
    ${A2_measid}    get nr meas id for specific type and frequency    ue_id=31    carrierfreq=2071387    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=${A2_measid} event=A2 srsrp_nr=7 srsrq_nr=7    eventA3
    ${A3_measid}    get nr meas id for specific type and frequency    ue_id=31    carrierfreq=636576    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=${A3_measid} event=A3 srsrp_nr=19 srsrq_nr=19 phycell_id=50 nrsrp_nr=31 nrsrq_nr=31
    ...    Inter Sgnb Handover is successful
