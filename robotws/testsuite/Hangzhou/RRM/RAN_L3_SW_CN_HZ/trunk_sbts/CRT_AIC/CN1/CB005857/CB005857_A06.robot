*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 2DU
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    vDUCNF00    RAN_Aic    RAN_5G    CRT    CLOUD_5GC_dRNIC_2vDU_P_AP_LOO_DC
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    team-L3SWCN1_SG14    owner-jun.3.ye    release-5G22R2
Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2du/4cells_du1_2T_du2_2T

@{PARAMS_IN_SCF_CU}    @{5GC005857_HO}    @{AMF}    @{A2_event}    @{MultiPLMN}    @{NRREL}    @{NRHOIF}    @{SNSSAI}
...    @{NRPLMNSET_TRACKINGAREA_Cell1}
...    @{NRPLMNSET_TRACKINGAREA_Cell2}
...    @{NRPLMNSET_TRACKINGAREA_Cell3}
...    @{NRPLMNSET_TRACKINGAREA_Cell4}

@{PARAMS_IN_SCF_DU1}    @{MultiPLMN}    @{SNSSAI}    @{DU_CELL1}    @{NRPLMNSET_TRACKINGAREA_Cell1}    @{NRPLMNSET_TRACKINGAREA_Cell3}

@{PARAMS_IN_SCF_DU2}    @{MultiPLMN}    @{SNSSAI}    @{DU_CELL2}    @{NRPLMNSET_TRACKINGAREA_Cell2}    @{NRPLMNSET_TRACKINGAREA_Cell4}

@{5GC005857_HO}
...    NRBTS:actRanSharing=true
...    NRBTS:actRanSharingEnh=disabled
...    NRBTS:actNgcFlexSaMode=true
...    NRBTS:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    delete:NRCELL:trackingAreaDN

@{AMF}
...    NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked
...    NRBTS-1/SERVEDAMF-1:amfIPAddress=10.0.11.1
...    NRBTS-1/SERVEDAMF-1:defaultAMF=true

@{A2_event}
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0

...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=95
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0

...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=90
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480

...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=40
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=41
...    NRBTS/NRPMRNL-1:miNrCABMCCP=disabled


@{NRREL}
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
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-4/NRREL-1:gNbId=1

@{NRHOIF}
...    NRCELL/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=0
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=0
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=ms480
...    NRCELL/NRHOIF-1:cellDepType=SA+NSA
#...    NRCELL/NRHOIF-1:chBw=50MHz
...    NRCELL/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL/NRHOIF-1:scs=30 KHz
...    NRCELL-1:nrarfcn=636666
...    NRCELL-2:nrarfcn=633372
...    NRCELL-1/NRHOIF-1:ssbFrequency=633312
...    NRCELL-2/NRHOIF-1:ssbFrequency=636576

@{DU_CELL1}
...    NRBTS:actRanSharing=true
...    NRBTS:actRanSharingEnh=disabled
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac
...    NRPMRNL-1:miNrCellUtilPerPLMN=15min
...    NRCELL-1:nrarfcn=636666
...    NRCELL-1/NRREL-1
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=633312
...    NRCELL-3/NRREL-1

@{DU_CELL2}
...    NRBTS:actRanSharing=true
...    NRBTS:actRanSharingEnh=disabled
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac
...    NRPMRNL-1:miNrCellUtilPerPLMN=15min
...    NRCELL-2:nrarfcn=633372
...    NRCELL-2:gscnOrSsPbchArfcn=7846
...    NRCELL-2/NRREL-1
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=636576
...    NRCELL-4/NRREL-1

@{MultiPLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    NRPLMN-2:mcc=311
...    NRPLMN-2:mnc=490
...    NRPLMN-2:mncLength=3
...    NRPLMN-3:mcc=311
...    NRPLMN-3:mnc=491

@{SNSSAI}
...    SNSSAI-1:administrativeState=Unlocked
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-1:sst=1
...    delete:SNSSAI-1:sd
...    SNSSAI-2:administrativeState=Unlocked
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-2:sst=1
...    SNSSAI-2:sd=13714341

@{NRPLMNSET_TRACKINGAREA_Cell1}
...    TRACKINGAREA-1:fiveGsTac=100
...    TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    TRACKINGAREA-1:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1}
...    NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-1
...    NRCELL-1/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST}

@{NRPLMNSET_TRACKINGAREA_Cell2}
...    TRACKINGAREA-2:fiveGsTac=200
...    TRACKINGAREA-2:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    TRACKINGAREA-2:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_2_3}
...    NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-2
...    NRCELL-2/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST}

@{NRPLMNSET_TRACKINGAREA_Cell3}
...    TRACKINGAREA-3:fiveGsTac=300
...    TRACKINGAREA-3:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    TRACKINGAREA-3:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRCELL-3/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1}
...    NRCELL-3/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-3
...    NRCELL-3/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST}

@{NRPLMNSET_TRACKINGAREA_Cell4}
...    TRACKINGAREA-4:fiveGsTac=400
...    TRACKINGAREA-4:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    TRACKINGAREA-4:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRCELL-4/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1}
...    NRCELL-4/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-4
...    NRCELL-4/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST}

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3
${NRPLMNDNLIST_1}    MRBTS-1/NRBTS-1/NRPLMN-1
${NRPLMNDNLIST_2_3}    MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3
${snssaiDNList}    MRBTS-1/NRBTS-1/SNSSAI-1,MRBTS-1/NRBTS-1/SNSSAI-2

@{PM_Counters_CU_Check_A06}
...    NRBTS-1:${ATT_IF_GNB_INTER_DU_HO_SLICE}=2
...    NRBTS-1:${SUCC_IF_GNB_INTER_DU_HO_SLICE}=2
...    NRCELL-1:${ATT_IEF_IE_DU_HO_EX_SA_PLMN}=1
...    NRCELL-2:${ATT_IEF_IE_DU_HO_EX_SA_PLMN}=1
...    NRCELL-1:${SUCC_IEF_IE_DU_HO_EX_SA_PLMN}=1
...    NRCELL-2:${SUCC_IEF_IE_DU_HO_EX_SA_PLMN}=1
...    NRCELL-1:${IF_ATT_INTER_DU_HO}=1
...    NRCELL-2:${IF_ATT_INTER_DU_HO}=1
...    NRCELL-1:${IF_SUCC_INTER_DU_HO}=1
...    NRCELL-2:${IF_SUCC_INTER_DU_HO}=1

@{PM_Counters_DU1_Check_A06}
...    NRCELL-1:${PRB_USED_PDSCH_PLMN}>1000
...    NRCELL-1:${PRB_USED_PUSCH_PLMN}>1000

@{PM_Counters_DU2_Check_A06}
...    NRCELL-2:${PRB_USED_PDSCH_PLMN}>1000
...    NRCELL-2:${PRB_USED_PUSCH_PLMN}>1000

${ATT_IF_GNB_INTER_DU_HO_SLICE}    M55149C00560    #Attempted Inter-Frequency Intra-gNB Inter-DU HO, per PLMN, per slice
${SUCC_IF_GNB_INTER_DU_HO_SLICE}    M55149C00561    #Successful Inter-Frequency Intra-gNB Inter-DU HO, per PLMN, per slice
${ATT_IEF_IE_DU_HO_EX_SA_PLMN}    M55145C03507    #Inter-freq Intra-gNB Inter-DU HO execution attempts for SA per PLMN-ID
${SUCC_IEF_IE_DU_HO_EX_SA_PLMN}    M55145C03508    #Inter-freq Intra-gNB Inter-DU HO execution successes for SA per PLMN-ID
${IF_ATT_INTER_DU_HO}    M55147C00030    #Attempted Inter-Frequency Intra-gNB Inter-DU HO
${IF_SUCC_INTER_DU_HO}    M55147C00031    #Successful Inter-Frequency Intra-gNB Inter-DU HO
${PRB_USED_PDSCH_PLMN}    M55338C00001    #PRBs used for PDSCH per PLMN
${PRB_USED_PUSCH_PLMN}    M55338C00002    #PRBs used for PUSCH per PLMN

*** Test Cases ***
CB005857-ET-A006_706_inter-freq_A3_successfully_and_counter_with_PLMN_change
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    706 inter-freq A3 successfully and counter with PLMN change
    ...    Counters is update correctly
    ...    2. Test Case Steps:
    ...         a. Make UE-1 Register and Pdu Session Setup to cell-1
    ...         b. Send And Verify Throughput
    ...         c. trigger UE send Measurement report A2
    ...         d. trigger UE HO with Measurement report A3
    ...         e. trigger UE send Measurement report A2
    ...         f. trigger UE HO with Measurement report A3
    ...         g. Counters is update correctly
    ...    3. Expected Results:
    ...         Step a: UE registers and PDU session is setup successfully.
    ...         Step b: Send And Verify Throughput is successfully
    ...         Step c: measurement gap configured to UE, and A1 A3 measurement configured to UE
    ...         Step d:
    ...         1.gNB-CU-CP performs Admission Control and selects cell which is assigned to the same PLMN which has been selected for the UE
    ...         during RRC Setup procedure
    ...         2.handover procedure is successful
    ...         3.user is handled in the PLMN2 in the Cell2
    ...         Step e:measurement gap configured to UE, and A1 A3 measurement configured to UE
    ...         Step f:
    ...         1.gNB-CU-CP performs Admission Control and selects cell which is assigned to the same PLMN which has been selected for the UE
    ...         during RRC Setup procedure
    ...         2.handover procedure is successful
    ...         3.user is handled in the PLMN1 in the Cell1
    ...         Step G: relevance counters is update correctly
    [Tags]    QC_46983
    Clear counter file
    SA UE register and PDU setup
    intra-gnb inter-DU inter-plmn HO From Cell1 to Cell2
    intra-gnb inter-DU inter-plmn HO From Cell2 to Cell1
    Verify Throughput
    Config MRL For UE2
    SA UE register and PDU setup    ue_id=2    nwslice=2
    intra-gnb inter-DU inter-plmn HO Fail From CELL1 to CELL2
    Verify Throughput    ue_id=2
    Release Ues    ue_type=all
#    Check Wireshark Log Aic    ${CURDIR}${/}a2a_CB005857_A06${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check Counters

*** Keywords ***
Modify Cfg Aic
    Update Cfg Aic    set_amf_region id=1 tac_list=100,200,280 plmn=311:489,311:490,311:491
    Update Cfg Aic    set_nwslice id=1 snssai=0x01:0xFFFFFF amf=1 default=on ue=all
    Update Cfg Aic    set_nwslice id=2 snssai=0x01:0xd143a5 amf=1 ue=all
    ${set_cell2_arfcn}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=280 nrci=0x02 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888 nr_arfcn=633372:633372
    ...    mandatory_for_activation=off  gscn=7846
    Update Cfg Aic    ${set_cell2_arfcn}

Config MRL For UE2
    Execute Egate Command    amf_mobility_restriction_list_param id=1 equiv_plmn=311:489 sa_plmn=311:490 allowed_tacs=100,200,280
    Execute Egate Command    amf_mobility_restriction_list_param id=1    311:489
    Execute Egate Command    amf_ue_ics_param id=1 ue=2 mobility_restriction_list_id=1

SA UE register and PDU setup
    [Arguments]    ${ue_id}=1    ${nwslice}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1    location
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=${nwslice}    QoS Routing Table
    Send Throughput    ${ue_id}
    Verify Throughput    ${ue_id}

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

intra-gnb inter-DU inter-plmn HO From Cell1 to Cell2
    ${A2_measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=636576    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${A2_measid} event=A2 srsrp_nr=30    eventA3
    ${A3_measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=633312    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${A3_measid} event=A3 srsrp_nr=30 phycell_id=51 nrsrp_nr=50    Intra-eNB handover

intra-gnb inter-DU inter-plmn HO From Cell2 to Cell1
    ${A2_measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=633312    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${A2_measid} event=A2 srsrp_nr=30    eventA3
    ${A3_measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=636576    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${A3_measid} event=A3 srsrp_nr=30 phycell_id=50 nrsrp_nr=50    Intra-eNB handover

intra-gnb inter-DU inter-plmn HO Fail From CELL1 to CELL2
    ${A2_measid}    get nr meas id for specific type and frequency    ue_id=2    carrierfreq=636576    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=2 meas_id=${A2_measid} event=A2 srsrp_nr=30    eventA3
    ${A3_measid}    get nr meas id for specific type and frequency    ue_id=2    carrierfreq=633312    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=2 meas_id=${A3_measid} event=A3 srsrp_nr=30 phycell_id=50 nrsrp_nr=50
    ...    fail_regexp=Intra-eNB handover

Clear counter file
    Clear Counter Files Cu Aic    wait=False
    Clear Counter Files Du Aic    wait=False
    Clear Counter Files Du2 Aic    wait=False

Check Counters
    Check Counters Cu Aic    ${PM_Counters_CU_Check_A06}
#    Check Counters Du Aic    ${PM_Counters_DU1_Check_A06}    wait=False
#    Check Counters Du2 Aic    ${PM_Counters_DU2_Check_A06}    wait=False
