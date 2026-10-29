*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT
...               CLOUD_R4LAPO_CUS    team-CN3ET    owner-jiangping.cao    owner-yin.zhang    release-SBTS19B
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:actMultiSCGSplit=true
...    LNBTS:actMultBearers=true
...    LNBTS:actEvtSecRatRep=true
...    LNBTS:tX2SgNBRelData=10000
...    LNBTS:caSchedFairFact=0
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-2/LNRELGNBCELL-0:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-0:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-0:nrCellId=115969
...    LNCEL-2/LNRELGNBCELL-0:nrCgiPlmnId:mcc=262
...    LNCEL-2/LNRELGNBCELL-0:nrCgiPlmnId:mnc=3
...    LNCEL-2/LNRELGNBCELL-0:nrCgiPlmnId:mncLength=2
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC
...    LNBTS:qciTab6:nrPdcpProfIdx=1001
...    LNBTS:qciTab6:arpEnDcMask=65534
...    LNBTS:qciTab7:lteNrDualConnectSupport=EN-DC
...    LNBTS:qciTab7:nrPdcpProfIdx=1001
...    LNBTS:qciTab7:arpEnDcMask=65534
...    LNBTS:qciTab8:lteNrDualConnectSupport=disabled
...    LNBTS:qciTab8:nrPdcpProfIdx=1001
...    LNBTS:qciTab8:arpEnDcMask=65534
...    LNBTS:qciTab9:lteNrDualConnectSupport=EN-DC
...    LNBTS:qciTab9:nrPdcpProfIdx=1001
...    LNBTS:qciTab9:arpEnDcMask=65534
...    LNBTS:pdcpProf1001:pdcpProfileId=1001
...    LNBTS:pdcpProf1001:snSizeDl=18bit
...    LNBTS:pdcpProf1001:snSizeUl=18bit
...    LNBTS:pdcpProf1001:statusRepReq=0
...    LNBTS:pdcpProf1001:tDiscard=300ms
...    LNBTS:tLteNrDualConnectPrep=10000
...    LNBTS:mcc=262
...    LNBTS:mnc=3
...    LNBTS:mncLength=2
...    LNBTS/CAGENB-0:caClusterEnbList:lnBtsId=100000
...    LNBTS/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL:harqMaxTrVoLteDl=4
...    LNCEL/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL:tac=33
...    LNBTS:actPartialAcHo=true
...    @{NRDCDPR}
...    @{PARAMS_FOR_FIX_RELATION_ERROR}

@{NRDCDPR}
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:tPeriodicPhr=100sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0

@{PARAMS_FOR_FIX_RELATION_ERROR}
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:actTransmittedBelowGap=false
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNBTS:nrRestrictionOverride=disabled
...    LNBTS:tS1eRABModInd=2000
...    LNCEL:eTputFilterConfig=51
...    LNCEL:eTputInitMcs=20

${MeasTimingConf}    0x00130060
#temporary workaround for LTE4193-B for supporting MeasTimingConf in X2SetupReponse for gNB
@{PARAMS_IN_SWCONFIG}
...    ${MeasTimingConf} = 1

${ue_eutra_capabilities}
...    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFB
...    FFEC800801C364000000017BA000000080952A0E2740400000820001080002180004400008A000118000238000480000920001280002580004
...    C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003A7400000003A
...    00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A0000000141000000F3A0000000000000000000000000000000000000000000000000000000000020238
...    8425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C6800033C000001800000090800004
${ue_nr_capabilities}    0000000001010000000060100581007018000000
${ue_eutra_nr_capabilities}    0108040160401C06000000000400020101002004

${QCI6_EBI}    6
${QCI7_EBI}    7
${QCI9_EBI}    8

*** Test Cases ***
LTE5510-A-i_01_01 MeNB initiated SgNB Modification with release subset of SCG split bearers due to receiving S1AP ERAB RELEASE COMMAND from MME
    [Documentation]    This case verifies Secondary RAT Usage Report List IE with already released SCG split bearers
    ...    in the E-RAB Release List IE are forwarding to MME via S1AP: E-RAB RELEASE RESPONSE to MME during release
    ...    subset of multiple SCG split bearers
    [Tags]
    Set GNB To Send Secondary RAT Data Report By Event Triggered
    ICS trigger ENDC With 3 Split Bearers    ue_id=1
    MME Initiate 2 Split Bearers Release And Their DataUsageReport Forwarded To MME    ue_id=1
    Detach UE And DataUsageReport Of Last Split Bearer Forwarded To MME    ue_id=1

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD_ABIO
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Set UE parameters before ENDC setup

Perform Steps After Onair
    @{lnadjgnb7}    Create List    LNADJGNB:cPlaneIpAddr=10.0.1.11    LNADJGNB:x2ToGnbLinkStatus=available
    Object Should Exist    ${lnadjgnb7}

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...      - { qci: 8, default: on, pdn: 1, trf_type: external, priority: 8, vulnerability: on, preemption: on }
    ...      - { qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1 }
    ...      - { qci: 2, gbr_ul: 144, gbr_dl: 144, mbr_ul: 144, mbr_dl: 144, pdn: 1 }
    ...      - { qci: 3, gbr_ul: 64, gbr_dl: 128, mbr_ul: 64, mbr_dl: 128, pdn: 1 }
    ...      - { qci: 4, gbr_ul: 32, gbr_dl: 330, mbr_ul: 32, mbr_dl: 320, pdn: 1 }
    ...      - { qci: 5, pdn: 1 }
    ...      - { qci: 6, pdn: 1, preprovisioned: on, filter: 1, precedence: 1, priority: 14, vulnerability: on, preemption: on }
    ...      - { qci: 7, pdn: 1, preprovisioned: on, filter: 2, precedence: 2, priority: 14, vulnerability: on, preemption: on }
    ...      - { qci: 9, pdn: 1, preprovisioned: on, filter: 3, precedence: 3, priority: 8, vulnerability: on, preemption: on }
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/3    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/4    bearer: bearer_set_2

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

Set UE parameters before ENDC setup
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=7 enable_dl_data_forwarding=off
    Execute Egate Command    gnb_endc_param sgnb_failure_scenario=no_sgnb_failure_scenario id=7
    Execute Egate Command    enb_timer T_DC_Overall=5000ms
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms

Set GNB To Send Secondary RAT Data Report By Event Triggered
    Execute Egate Command    gnb_endc_param send_secondary_rat_data_volume_report=on:0 id=7

ICS trigger ENDC With 3 Split Bearers
    [Documentation]    total 4 bearers, 3 splitted
    [Arguments]    ${ue_id}
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupListCtxtSUReq contains (qCI eq 8, qCI eq 6, qCI eq 7, qCI eq 9))
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    ENB_1:X2AP_SgNBAdditionRequest (E-RABs-ToBeAdded-SgNBAddReqList contains (qCI eq 6, qCI eq 7, qCI eq 9))
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    alias=endc_flow    overall_timeout=20
    ${attach_cmd}    catenate
    ...    ue_attach id=${ue_id} cell=1
    ...    ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    Execute Uex Command    ${attach_cmd}
    Flow Occurred As Expected    alias=endc_flow

MME Initiate 2 Split Bearers Release And Their DataUsageReport Forwarded To MME
    [Arguments]    ${ue_id}
    ${QCI6_and_QCI7_EBI}    Set Variable    e-RAB-ID eq ${QCI6_EBI}, e-RAB-ID eq ${QCI7_EBI}
    ${two_data_usage_report}    Catenate    SecondaryRATDataUsageReportList contains (${QCI6_and_QCI7_EBI})
    ...    and length(SecondaryRATDataUsageReportList) eq 2
    Expect Message Flow
    ...    MME_1:S1AP_E-RABReleaseCommand (E-RABList contains (${QCI6_and_QCI7_EBI}))
    ...    ENB_1:X2AP_SgNBModificationRequest (E-RABs-ToBeReleased-SgNBModReq-Item contains (${QCI6_and_QCI7_EBI}))
    ...    GNB_7:X2AP_SgNBModificationRequestAcknowledge (E-RABs-Admitted-ToBeReleased-SgNBModAckList contains (${QCI6_and_QCI7_EBI}))
    ...    GNB_7:X2AP_SecondaryRATDataUsageReport (SecondaryRATUsageReportList contains (${QCI6_and_QCI7_EBI}))
    ...    MME_1:S1AP_E-RABReleaseResponse (${two_data_usage_report})
    ...    alias=release_2_bearers_flow    overall_timeout=20
    @{qci6_and_qci7_released}    Create List
    ...    Bearer-7 \\(EBI=${QCI6_EBI}\\) deleted in result of PGW-initiated Bearer Deletion procedure
    ...    Bearer-8 \\(EBI=${QCI7_EBI}\\) deleted in result of PGW-initiated Bearer Deletion procedure
    Execute Egate Command    bearer_del ue=${ue_id} id=7-8    ${qci6_and_qci7_released}
    Flow Occurred As Expected    alias=release_2_bearers_flow

Detach UE And DataUsageReport Of Last Split Bearer Forwarded To MME
    [Arguments]    ${ue_id}
    ${one_data_usage_report}    Catenate    SecondaryRATDataUsageReportList contains (e-RAB-ID eq ${QCI9_EBI})
    ...    and length(SecondaryRATDataUsageReportList) eq 1
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBReleaseRequest
    ...    GNB_7:X2AP_SgNBReleaseRequestAcknowledge (E-RABs-Admitted-ToBeReleased-SgNBRelReqAckList contains (e-RAB-ID eq ${QCI9_EBI}))
    ...    GNB_7:X2AP_SecondaryRATDataUsageReport (SecondaryRATUsageReportList contains (e-RAB-ID eq ${QCI9_EBI}))
    ...    MME_1:S1AP_UEContextReleaseComplete (${one_data_usage_report})
    ...    alias=detach_flow    overall_timeout=20
    Execute Uex Command    ue_detach id=${ue_id}
    Flow Occurred As Expected    alias=detach_flow
