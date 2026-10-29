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

@{PARAMS_IN_SCF}    @{RanSharing_HO}    @{MultiPLMN}    @{NRPLMNSET_SA_NSA}    @{SNSSAI}    @{TRACKINGAREA}    @{NRREL}    @{NRADJGNB}
...    @{NRADJNRCELL}    @{NRHOIF}    @{event_A2A3}    @{golden_error}

@{RanSharing_HO}
...    NRBTS-1:actRanSharing=true
...    NRBTS-1:actRanSharingEnh=max_10_PLMNs
...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS-1:actIntraFreqInterGnbMobilityNSA3x=true
...    NRBTS-1:actConflictConfiguration=false
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac

@{MultiPLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    NRPLMN-2:mcc=460
...    NRPLMN-2:mnc=402
...    NRPLMN-2:mncLength=3

@{NRPLMNSET_SA_NSA}
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST_1}

...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1}

@{SNSSAI}
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST_1}

@{TRACKINGAREA}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1

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
...    NRADJNRCELL-1/ADJ_NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST_2}

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

@{golden_error}
...    NRCELL-1:measGapSelectionSA=favourUeThroughput    #fix error
#...    NRCELL-1:gscnOrSsPbchArfcn=7880    #Associated with cfg

${NRPLMNDNLIST_1}    MRBTS-1/NRBTS-1/NRPLMN-1
${NRPLMNDNLIST_2}    MRBTS-1/NRBTS-1/NRPLMN-2

@{HO_Counter}
...    NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${ATT_OG_INTER_GNB_HO_NSA_PLMN}=1
...    NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${SUCC_OG_INTER_GNB_HO_NSA_PLMN}=1
...    NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${SUCC_IC_INTER_GNB_HOP_NSA_PLMN}=1
...    NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${SUCC_IC_INTER_GNB_HO_NSA_PLMN}=1
${ATT_OG_INTER_GNB_HO_NSA_PLMN}    M55145C00151    #The number of outgoing inter-gNB PS-Cell change attempts for NSA 3x per PLMN
${SUCC_OG_INTER_GNB_HO_NSA_PLMN}    M55145C00152    #The number of successful outgoing inter-gNB PS-Cell changes for NSA 3x per PLMN
${SUCC_IC_INTER_GNB_HOP_NSA_PLMN}    M55145C00162    #The number of successful incoming inter-gNB PS-Cell change preparations for NSA 3x per PLMN
${SUCC_IC_INTER_GNB_HO_NSA_PLMN}    M55145C00163    #The number of successful incoming inter-gNB PS-Cell change for NSA 3x per PLMN

*** Test Cases ***
5GC001630-ET-J007_Verify_successful_NSA_user_inter-frequency_inter-gNB_inter-PLMN_PS-Cell_change
    [Documentation]
    ...    1. NSA user inter-freq inter-gNB inter-PLMN handover successfully and counters are updated
    ...    2. Test Case Steps:
    ...         a. x2link setup
    ...         b. set HRL(460:402) for UE31(311:489)
    ...         c. NSA UE31 attach and do traffic
    ...         d. UE31 HO from real gNB2 to sim gNB3
    ...         e. UE31 HO from sim gNB3 to real gNB2
    ...    3. Expected Results:
    ...         a: x2link setup successful
    ...         b: set HRL successful
    ...         c: UE31 attach successful and traffic should be ok
    ...         d: UE31 HO from real-gNB2 to sim-gNB3 successful and update relation Outgoing HO counter
    ...         e: UE31 HO from sim-gNB3 to real-gNB2 successful and update relation Incoming HO counter
    [Tags]    QC_60733
    setup X2 link to gNBs
    set HRL for UE
    NSA UE attach    ue_id=31
    Traffic Should Be OK    ue_id=31    type=NSA
    HO from real gNB2 to sim gNB3
    HO from sim gNB3 to real gNB2
    Check Counters    ${HO_Counter}

*** Keywords ***
Modify Cfg
    #sim gnb3
    Update Cfg    set_gnb id=3 s1u=10.0.1.122 plmn=460:402 gnb_id=0x3 type=simulated daemon=10.0.2.1:22222 x2=10.0.1.122:36422
    ${sim_gnb3_cell1}    catenate    set_cell id=1 gnb=3 tac=0 pci=128:0 proxy=10.0.2.1:22223 nrci=0x01 nr_arfcn=2071591:2071591 tdd_cell=on
    ...    gscn=22446 mandatory_for_activation=off
    Update Cfg    ${sim_gnb3_cell1}
    Update Cfg    gnb_endc_param id=3 use_nr_ran_cont=on scg_dl_dist_percent=0 enable_dud_poll_bit=0
    #ue
    Update Cfg Param    ue_param id=31 ue_nr_capabilities=${Capa_NON_CA_NSA_NR_N78_N261} ue_eutra_nr_capabilities=${Capa_NON_CA_NSA_EUTRA_N78_N261}

setup X2 link to gNBs
    Execute Egate Command    enb_x2_link_up enb=1 target=2    is up
    Execute Egate Command    enb_x2_link_up enb=1 target=3    is up
    object should exist    LTEENB:x2LinkStatus=available

set HRL for UE
    Execute Egate Command    mme_ho_restriction_list equiv_plmn=460:402 id=1
    Execute Egate Command    ue_mme_param id=31 ho_restriction_list_id=1 ho_restrictions=lte,la hrl_dl_nas=on

NSA UE attach
    [Arguments]  ${ue_id}=31    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    enb_ue_dc_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    UE${ue_id}: Proxy \\(eNB 2 cell ${target_cells}\\) reported successful RA

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
