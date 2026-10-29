*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS    team-SG3
...               owner-yu.1.zhou    release-SRAN19B
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:actMultBearers=true
...    LNBTS:caSchedFairFact=0
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC
...    LNBTS:qciTab8:nrPdcpProfIdx=1001
...    LNBTS:tLteNrDualConnectPrep=10000
...    LNBTS:mcc=262
...    LNBTS:mnc=3
...    LNBTS:mncLength=2
...    LNBTS/CAGENB-0:caClusterEnbList:lnBtsId=100000
...    LNBTS/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNBTS:pdcpProf1001:pdcpProfileId=1001
...    LNBTS:pdcpProf1001:snSizeDl=18bit
...    LNBTS:pdcpProf1001:snSizeUl=18bit
...    LNBTS:pdcpProf1001:statusRepReq=0
...    LNBTS:pdcpProf1001:tDiscard=300ms
...    LNCEL-1:harqMaxTrVoLteDl=4
...    LNCEL-2:harqMaxTrVoLteDl=4
...    LNCEL-3:harqMaxTrVoLteDl=4
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNCEL-1/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-2/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-3/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-1:tac=33
...    LNCEL-2:tac=33
...    LNCEL-3:tac=33
...    @{NRDCDPR}
...    LNBTS:actEvtSecRatRep=true
...    LNBTS:tX2SgNBRelData=10000
...    LNCEL-1:inactivityTimer=60
...    LNBTS:actERabModify=true
...    LNBTS:actEnhAcAndGbrServices=true
...    LNBTS:actMultGbrBearers=true
...    LNBTS:actNonGbrServiceDiff=true
...    LNBTS:act8EpsBearers=true
...    LNBTS:actOperatorQCIGBR=false
...    LNBTS:actOperatorQCI=true
...    LNBTS:maxNumPreEmptions=2
...    LNBTS:timDelACContPreempt=100
...    LNBTS:actContextPreemption=true
...    LNBTS:estCauseArpMapConfig:arpPriority=1|estCause=emergency
...    LNBTS:estCauseArpMapConfig:preemptionCap=true|estCause=emergency
...    LNBTS:estCauseArpMapConfig:arpPriority=2|estCause=highPriorityAccess
...    LNBTS:estCauseArpMapConfig:preemptionCap=true|estCause=highPriorityAccess
...    LNBTS:estCauseArpMapConfig:arpPriority=10|estCause=mt-Access
...    LNBTS:estCauseArpMapConfig:preemptionCap=true|estCause=mt-Access
...    LNBTS:estCauseArpMapConfig:arpPriority=11|estCause=mo-Signalling
...    LNBTS:estCauseArpMapConfig:preemptionCap=true|estCause=mo-Signalling
...    LNBTS:estCauseArpMapConfig:arpPriority=12|estCause=mo-Data
...    LNBTS:estCauseArpMapConfig:preemptionCap=true|estCause=mo-Data
...    LNBTS:estCauseArpMapConfig:arpPriority=13|estCause=delayTolerantAccess-v1020
...    LNBTS:estCauseArpMapConfig:preemptionCap=true|estCause=delayTolerantAccess-v1020
...    LNCEL-1/SIB-0:t300=2000ms
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1/LNCEL_FDD-0:maxNumActUE=10
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrc=10
...    LNCEL-1:actNbrForNonGbrBearers=false
...    LNCEL-1/LNCEL_FDD-0:srsActivation=true
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:addAUeRrHo=0
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:addAUeTcHo=0
...    LNCEL-1/LNCEL_FDD-0:addNumDrbRadioReasHo=0
...    LNCEL-1/LNCEL_FDD-0:addNumDrbTimeCriticalHo=0
...    LNCEL-1/LNCEL_FDD-0:maxNumActDrb=10
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUeDc=0
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe=0
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe3c=0
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:minNumRrc=0
...    LNCEL-1:actUlLnkAdp=fUlLa
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:deltaPucchShift=1
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=10
...    LNBTS:actDynTrigLteNrDualConnectivity=false
...    LNBTS:actCAggrLteNrDualConnectivity=disabled
...    LNCEL-1/LNREL-1:handoverAllowed=onlyS1
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:endcSchedWeightBoostDl=5
...    LNBTS:endcSchedWeightBoostUl=5
...    LNBTS:nrRestrictionOverride=disabled
...    LNBTS:actTransmittedBelowGap=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
@{NRDCDPR}
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:tPeriodicPhr=100sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
${ue_nr_capabilities}    0000000001010000000060100581007018000000
${ue_eutra_nr_capabilities}    0108040160401C06000000000400020101002004
${ue_eutra_capabilities_01}
...    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFB
...    FFEC800801C364000000017BA000000080952A0E2740400000820001080002180004400008A000118000238000480000920001280002580004
...    C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003A7400000003A
...    00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A0000000141000000F3A0000000000000000000000000000000000000000000000000000000000020238
...    8425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C2800033C000001800000080
@{delta_para_case_A-ab_07_01}
...    LNBTS:qciTab6:nrPdcpProfIdx=1001
...    LNBTS:qciTab6:lteNrDualConnectSupport=disabled
...    LNBTS:qciTab8:nrPdcpProfIdx=1001
...    LNBTS:qciTab8:lteNrDualConnectSupport=disabled

*** Test Cases ***
LTE5558-A-a_b_ET_07_01_Fail to establish ENDC when target eNB have x2 link with gNB after Intra LTE successful S1 HO
    [Tags]
    Configure Parameters    ${delta_para_case_A-ab_07_01}
    Set UE parameters before ENDC setup
    UE attach on ENB2    ue_id=2    endc_capable_qci=6
    Trigger UE2 bearer to ENDC
    Trigger UE2 S1 Ho
    [Teardown]    Recover Environment and Stop Capture Logs

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD_ABIO
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    ENB_2    enb_id=2    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
	
Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...      - { qci: 8, default: on, pdn: 1, trf_type: external, priority: 8, vulnerability: off, preemption: off }
    ...      - { qci: 6, preprovisioned: on, default: off, filter: 1, precedence: 1, preemption: off, vulnerability: off }	
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_2	
    ${GNB7_CELL1}    catenate
    ...    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x501', nr_arfcn: '507000:531000',
    ...    meas_timing_carrier_freq: ${NRARFCN531000}, ssb_subcarrier_spacing: kHz15,
    ...    ssb_mtc_periodicity_and_offset: 'sf5:1', ssb_mtc_duration: 'sf1',
    ...    shared_plmn: '262:03'}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...    gnb_id: '0x00007'
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1u: 10.0.1.11
    ...    x2_peers: none
    ...    cells:
    ...       ${GNB7_CELL1}	
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1: 10.0.1.3
    ...    cells:
    ...        - {id: 21, technology: lte, tac: 33, pci: '3:0', earfcn: '1400:19400', bw: 20}
    ...        - {id: 22, technology: lte, tac: 33, pci: '3:1', earfcn: '5920:23920', bw: 20}
    ...        - {id: 23, technology: lte, tac: 33, pci: '3:2', earfcn: '8770:26770', bw: 20}

Set UE parameters before ENDC setup
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    ue_param id=1-2 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Egate Command    ue_param id=1-2 nr_supported_bands=7
    Execute Egate Command    gnb_endc_param enable_dl_data_forwarding=1 enable_ul_data_forwarding=1 use_nr_ran_cont=true id=7
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    trace_sim enb=2 protocol=x2 on
    Execute Egate Command    ue_enb_param id=1-2 ue_config_release_r9=rel15
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    Execute Egate Command    enb_timer T_DC_Overall=5000ms

UE attach on ENB2
    [Arguments]    ${ue_id}=1    ${endc_capable_qci}=8
    Execute Egate Command    enb_param id=2 endc_capable_qci=${endc_capable_qci}
    Execute Egate Command    enb_x2_link_up enb=2 target=7    ENB-2: X2AP Link with GNB-7
    ${V_6}    catenate    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities_01} cell=21
    Execute Uex Command    ${V_6}
    sleep    5s    #wait UE attach eNB2 active

Configure Parameters
    [Arguments]    ${delta_para}
    Delta Commission Parameters    ${delta_para}
    Cells Should Be OnAir

Trigger UE2 bearer to ENDC
    Execute Egate Command    enb_ue_dc_start target_gnb=7 target_cells=71 ue=2 bearer=2 type=split_scg
    ...    pass_regexp=Bearer-type change from MCG to SCG-split is successful

Trigger UE2 S1 Ho
    Execute Egate Command    mme_timer T_S1HoSrcContextRelease=20
    Execute Egate Command    link_lock link=x2 at=enb:2 to=enb:1    ENB-2: X2AP Link with ENB-1 .* is locked
    Execute Egate Command    enb_param id=2 ho_source=s1 specific_pdcp_sn_size_to_support=sn18
    Trigger inter-eNB S1 HO From sim-eNB2 to eNB1 Cell-1
	
Trigger inter-eNB S1 HO From sim-eNB2 to eNB1 Cell-1
    [Arguments]    ${ue_id}=2
    Expect Message Flow
    ...    MME_1:S1AP_HandoverRequest
    ...    MME_1:S1AP_HandoverRequestAcknowledge (E-RABAdmittedList contains ((e-RAB-ID eq 5), (e-RAB-ID eq 6)))
    ...    MME_1:S1AP_HandoverCommand (E-RABSubjecttoDataForwardingList contains ((e-RAB-ID eq 5), (e-RAB-ID eq 6)))
    ...    ENB_2:X2AP_SgNBReleaseRequest (E-RABs-ToBeReleased-SgNBRelReqList contains (e-RAB-ID eq 6))
    ...    GNB_7:X2AP_SgNBReleaseRequestAcknowledge (E-RABs-Admitted-ToBeReleased-SgNBRelReqAckList contains (e-RAB-ID eq 6))
    ...    GNB_7:X2AP_SNStatusTransfer (E-RABs-SubjectToStatusTransfer-List contains (e-RAB-ID eq 6))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    MME_1:S1AP_ENBStatusTransfer
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    MME_1:S1AP_UEContextReleaseCommand (Cause contains (radioNetwork eq 'successful-handover'))
    ...    ENB_2:X2AP_UEContextRelease
    ...    alias=S1_HO    overall_timeout=10
    Execute Uex Command    ue_ho id=${ue_id} cell=1
    Flow Occurred As Expected    alias=S1_HO

Recover Environment and Stop Capture Logs
    Execute Egate Command    link_unlock link=x2 at=enb:2 to=enb:1    ENB-2: X2AP Link with ENB-1 .* is up
    Execute Egate Command    gnb_endc_param id=7 sgnb_failure_scenario=no_sgnb_failure_scenario
    Common Test Teardown And Stop Capture Logs
