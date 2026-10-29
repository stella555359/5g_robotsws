*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-liupei.fang
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    release-SBTS24R1    STATE_CONFIGURED
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{actCDrx}
...    @{RANsharing}
...    @{CA}
...    @{UEAssistanceInformation_para}
...    @{8225_parameters}


@{8225_parameters}
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:drbRrcInactInactivityTimerSA=20
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRCELL:freqBandIndicatorNR=77
...    NRCELL-1:gscnOrSsPbchArfcn=7811
...    NRCELL-1:nrarfcn=629994
...    NRCELL-1:chBw=80MHz
...    NRBTS:drbInactivityTimerSA=60
...    NRBTS:maxUeRrcInactTime=60
...    NRBTS:outOfConnectedPreference=idle
...    NRBTS:srbInactivityTimerSA=30
...    NRBTS:t380=5min
...    NRBTS/NRSYSINFO_PROFILE-1/NRIRFIM-1:freqBandIndicatorNR=77
...    NRBTS:act3gppBL23R1=true

@{actCDrx}
...    NRCELL:actCDrx=true
...    NRCELL-1:actCDrx=true
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRCELL:drxProfile1:drxInactivityTimer=80ms
...    NRCELL:drxProfile1:drxLongCycle=160ms
...    NRCELL:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL:drxProfile1:drxRetransTimerDl=0slot
...    NRCELL:drxProfile1:drxRetransTimerUl=0slot
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2:actCDrx=true
...    NRCELL-2:pucchModeSelect=longPucch
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:allowUnsuppBcOrBcs=accept unknown band combinations


@{RANsharing}
...    NRBTS:actNgcFlexSaMode=true
...    NRBTS:actRanSharing=true
...    NRBTS:actTrsSepaSARanSharing=true
...    NRBTS:ngCplane:ngTnlId=1
...    NRBTS:ngUplane:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS:xnCplane:xnTnlId=1
...    NRBTS:xnUplane:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL-1:configuredEpsTac=${EMPTY}
...    NRCELL-1:ranAC=${EMPTY}
...    NRCELL-1:trackingAreaDN=${EMPTY}
...    NRCELL-1/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL-1/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL-1/NRPLMNSET_SA-1:ranAC=0
...    NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL-1/NRPLMNSET_SA-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL-1/NRPLMNSET_SA-2:ranAC=1
...    NRCELL-1/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-300
...    NRCELL-2:configuredEpsTac=${EMPTY}
...    NRCELL-2:ranAC=${EMPTY}
...    NRCELL-2:trackingAreaDN=${EMPTY}
...    NRCELL-2/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL-2/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL-2/NRPLMNSET_SA-1:ranAC=0
...    NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL-2/NRPLMNSET_SA-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL-2/NRPLMNSET_SA-2:ranAC=2
...    NRCELL-2/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-300
...    NRBTS/NRPLMN-2:mnc=500
...    NRBTS/SERVEDAMF-1:ngTnlId=1
...    NRBTS/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/SNSSAI-1:sd=${EMPTY}
...    NRBTS/SNSSAI-2:sd=13714341
...    NRBTS/SNSSAI-2:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    NRBTS/TRACKINGAREA-300:fiveGsTac=300
...    NRBTS/TRACKINGAREA-300:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1

@{CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRBTS:ranPagingCycle=v32
...    NRBTS:sCellActivationMethod=blind
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1:dlSCellConfigLevel=10
...    NRCELL-1:dlSCellConfigLevelNum=20
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2:actK1Opt=intra-gNB
...    NRCELL-2:dlSCellConfigLevel=10
...    NRCELL-2:dlSCellConfigLevelNum=20
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa
...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30
...    NRCELL:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=160ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp

@{UEAssistanceInformation_para}
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:tRanPagingGuard=4
...    NRBTS:timerReleasePreferenceProhibit=s5

@{INACTIVE_check}
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    nextHopChainingCount
...    t380
...    NR_RRC_INACTIVE
...    Is INACTIVE

@{Resume_with_scell_regexp}
...    rrcResumeRequest1
...    rrcResumeComplete
...    PhysCellId: 51] SCellIndex 1 activated successfully

@{scell_add_success} 
...    rrcReconfigurationComplete
...    PhysCellId: 51] SCellIndex 1 activated successfully

@{PM_Counters_Check_E006}
...    NRCELL-1:${RRC_REL_WITH_SUSP}=1
...    NRCELL-1:${RRC_RESUME_REQ}=1
...    NRCELL-1:${RRC_RESUME_SUCC}=1
...    NRCELL-1:${SCELL_ADMI_REQ}=2
...    NRCELL-1:${SCELL_ADMI_SUCC}=2
...    NRCELL-2:${DU_SCELL_ADMI_REQ}=2
...    NRCELL-2:${DU_SCELL_ADMI_SUCC}=2
...    NRCELL-1:${DU_SCELL_1_ADMI_REQ}=2
...    NRCELL-1:${DU_SCELL_1_ADMI_SUCC}=2
...    NRCELL-2:${SCELL_ACTIVATIONS}=2


${RRC_REL_WITH_SUSP}    M55124C00006    #NRRCC_RRC_REL_WITH_SUSP_NRNAU increment for Cell1
${RRC_RESUME_REQ}    M55124C00007    #NRRCC_RRC_RESUME_REQUEST1 increment for Cell1
${RRC_RESUME_SUCC}    M55124C00010    #NRRCC_RRC_RESUME_SUCC increment for Cell1
${SCELL_ADMI_REQ}    M55138C01501    #GNB_SCELL_1_ADMI_REQ_SA increment 2 for Cell1
${SCELL_ADMI_SUCC}    M55138C01502    #GNB_SCELL_1_ADMI_SUCC_SA increment 2 for Cell1
${DU_SCELL_ADMI_REQ}    M55139C01001    #GNB_DU_SCELL_ADMI_REQ_SA increment 2 for Cell2
${DU_SCELL_ADMI_SUCC}    M55139C01002     #GNB_DU_SCELL_ADMI_SUCC_SA increment 2 for Cell2
${DU_SCELL_1_ADMI_REQ}     M55139C01003     #GNB_DU_SCELL_1_ADMI_REQ_SA increment 2 for Cell1
${DU_SCELL_1_ADMI_SUCC}    M55139C01004    #GNB_DU_SCELL_1_ADMI_SUCC_SA increment 2 for Cell1
${SCELL_ACTIVATIONS}    M55316C09000    #SCELL_ACTIVATIONS increment 2 for Cell2
${RRC_RESUME_FALLBACK_ATT}    M55124C00013    #NRRCC_RRC_RESUME_FALLBACK_ATT increment for Cell2
${RRC_RESUME_FALLBACK_SUCC}    M55124C00014    #NRRCC_RRC_RESUME_FALLBACK_SUCC increment for Cell2


*** Test Cases ***
CB008225-ET-E006_Successful_transition_of_Suspended_UE_in_RRC_INACTIVE_to_RRC_CONNECTED_resume_to_Cell_with_intra_gNB_Blind_CA_config
    [Documentation]
    ...    This user scenario describes the gNB behaviour for UE in RRC_INACTIVE state that is successfully transitioned to 
    ...    RRC_CONNECTED state. Successful Resume procedure with blind CA Scell addition.
    ...    2. Configuration
    ...       a.SA+NSA,TDD+TDD
    ...    3. Test Case Steps:
    ...       a.Set UE1 Core Network Assistance Information for RRC INACTIVE state in the Initial Context Setup Request. 
    ...       And trigger UE1 register to Cell1.
    ...       b.start and stop traffic to trigger inactive(wait drbRrcInactInactivityTimerSA and srbInactivityTimerSA timeout)
    ...       c.check resources leakage 
    ...       d.start traffic to trigger resume and stop traffic again
    ...       e.Ue deregister and check counter 
    ...     4. Expected result:
    ...       a.UE register successfully
    ...       b.start and stop traffic to trigger UE paging successfully
    ...       c.no resources lealage 
    ...       d.resume successfully
    ...       e.Ue deregister successfully    
    [Tags]    QC_326358    owner-liufang    E006    CA_LABEL-TT(80MHz_TDD_n77+100MHz_TDD_n77)
    clear counter files    wait=${False}
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${CB008140_N_Capa_Support_2CC_3CC_n3_n28_n41_n77}
    UE Attach To Target Cell    ue_id=1
    Start traffic and Check Throughput    ue_id=1    cc_num=2    dl=360    ul=18
    Stop traffic to Inactive
    Check Resources Leakage    cpcl cprt
    Start traffic to trigger resume
    Stop traffic   
    UE Deregister From gNB
    check counters    pm_counters_expression=${PM_Counters_Check_E006}


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=20
    
Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,100,200,300 plmn=311:489,311:500
    Update Cfg    set_amf_region id=2 tac_list=0,100,200 plmn=311:489
    Update Cfg    set_nwslice id=1 snssai=0x01:0xFFFFFF default=on ue=all amf_region_id=1 plmn_list=311:489,311:500
    Update Cfg    set_nwslice id=2 snssai=0x01:0xd143a5 default=off ue=all amf_region_id=2 plmn_list=311:489
    ${set_ue1}    catenate    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:500:0000:0:0:021645401 
    ...    mode=nr enb=2 cell=1
    Update Cfg    ${set_ue1}

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}
	
UE Attach To Target Cell
    [Arguments]    ${ue_id}=1     
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
    ${set_ics_param}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${set_ics_param}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${scell_add_success}    timeout=10s
	
Verify Throuput on Pscell and Scell 
    [Arguments]    ${ue_id}=1    ${CC_num}=2    ${dl}=400    ${ul}=16
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-1 type=pdsch    pass_regexp=Average
    ${all_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${sid}    convert to string    ${id}
        ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${sid}    type=pdsch    rate_type=ave
        Should Be True    ${scell_tput}/1000 > 0
        ${all_tput}    Evaluate    ${all_tput}+${scell_tput}
    END
    Should Be True    ${all_tput}/1000 > ${dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
    
Start traffic to trigger resume
   [Arguments]    ${ue_id}=1     
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=8 mbps=150    pass_regexp=${Resume_with_scell_regexp}
    Start traffic and Check Throughput    ue_id=${ue_id}
    
Start traffic and Check Throughput
    [Arguments]    ${ue_id}=1    ${cc_num}=2    ${dl}=360    ${ul}=18
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=4 mbps=10    UE ${ue_id}: UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=5 mbps=10    UE ${ue_id}: UDP UL
    Wait Until Keyword Succeeds    30s    3s    Verify Throuput on Pscell and Scell    ue_id=${ue_id}    CC_num=${cc_num}    dl=${dl}    ul=${ul}
    
Stop traffic to Inactive
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl    pass_regexp=${INACTIVE_check}    timeout=21s

Stop traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu}    pass_regexp=Traffic was stopped
