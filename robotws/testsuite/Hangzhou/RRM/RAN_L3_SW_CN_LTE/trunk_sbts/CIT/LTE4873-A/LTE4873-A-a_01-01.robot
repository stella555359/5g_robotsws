*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT    team-SG5
...               CLOUD_R4LAPO_CUS    release-xL19A    owner-jiangping.cao
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS-1:actLteNrDualConnectivity=true
...    LNBTS-1:actMultBearers=true
...    LNBTS-1:caSchedFairFact=0
...    LNBTS-1:qciTab6:lteNrDualConnectSupport=EN-DC
...    LNBTS-1:qciTab6:nrPdcpProfIdx=1001
...    LNBTS-1:tLteNrDualConnectPrep=2000
...    LNBTS-1:mcc=262
...    LNBTS-1:mnc=3
...    LNBTS-1:mncLength=2
...    LNBTS-1/CAGENB-0:caClusterEnbList:lnBtsId=100000
...    LNBTS-1/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS-1/LNBTS_FDD-0:actConvVoice=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNBTS-1:pdcpProf1001:pdcpProfileId=1001
...    LNBTS-1:pdcpProf1001:snSizeDl=18bit
...    LNBTS-1:pdcpProf1001:snSizeUl=18bit
...    LNBTS-1:pdcpProf1001:statusRepReq=0
...    LNBTS-1:pdcpProf1001:tDiscard=300ms
...    LNCEL:harqMaxTrVoLteDl=4
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNCEL/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL:tac=33
...    @{NRDCDPR}
...    @{x2link}
...    @{relation_error_fixed}
...    LNBTS-1:actSecRatRep=true
@{relation_error_fixed}
...    LNBTS-1:actAmbrModCaTrigger=false
...    LNBTS-1:actEndcSpidFwd=false
...    LNBTS-1:tS1eRABModInd=2000
...    LNBTS-1:endcSchedWeightBoostDl=2
...    LNBTS-1:endcSchedWeightBoostUl=2
...    LNBTS-1:nrRestrictionOverride=disabled
...    LNBTS-1:actTransmittedBelowGap=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
@{x2link}
...    LNBTS-1/LNADJGNB-1:administrativeState=unlocked
...    LNBTS-1/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=33301
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
@{NRDCDPR}
...    LNBTS-1/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS-1/NRDCDPR-0:tPeriodicPhr=100sf
...    LNBTS-1/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS-1/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS-1/NRDCDPR-0:enDCpMaxNRpowerOffset=0
${ue_nr_capabilities}    0000000001010000000060100581007018000000
${ue_eutra_nr_capabilities}    0108040160401C06000000000400020101002004
@{SharedPlmnList}
...    262:03
@{PARAMS_IN_SWCONFIG}
...    0x00130060 = 1
#temporary workaround for LTE4193-B for supporting MeasTimingConf in X2SetupReponse for gNB
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
...    8425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C2800033C000001800000080
${wait_report}    12s
${wait_x2_setup}    60s

*** Test Cases ***
LTE4873-A-a_01-01 Secondary RAT Usage Report periodically after ENDC setup during LTE4873 is active
    [Documentation]    This case verifies that eNB will forward secondary rat data report to MME when LTE4873 is active
    [Tags]
    Set UE parameters before ENDC setup    ue_id=1    gnb_id=2
    Set on simgnb side to send Secondary RAT Data Volume Report periodically to eNodeB    gnb_id=2
    ICS trigger ENDC    ue_id=1    cell_id=1
    Wait for receiving message Secondary RAT Data Volume Report from SgNB

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD_ABIO    ue_count=100
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=20    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Perform Steps After Onair
    sleep    ${wait_x2_setup}
    @{LNADJGNB}    Create List    LNADJGNB:cPlaneIpAddr=10.0.1.11    LNADJGNB:x2ToGnbLinkStatus=available
    Object Should Exist    ${LNADJGNB}

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    ${GNB2_CELL1}    catenate    - {id: 21, technology: nr, tac: 33, pci: '0:1', nrci: '0x0000215', nr_arfcn: '507000:531000'}
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...    gnb_id: '0x00002'
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1u: 10.0.1.11
    ...    x2_peers: none
    ...    cells:
    ...       ${GNB2_CELL1}

Set UE parameters before ENDC setup
    [Arguments]    ${ue_id}=1    ${gnb_id}=2
    Execute Uex Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=${ue_id} type=nr release=15 nr_supported_bands=7
    Execute Egate Command    gnb_endc_param id=${gnb_id} include_reestablish_pdcp=on
    Execute Egate Command    ue_enb_param id=${ue_id} ue_config_release_r9=rel15
	Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    Execute Egate Command    enb_timer T_DC_Overall=5000ms

Set on simgnb side to send Secondary RAT Data Volume Report periodically to eNodeB
    [Arguments]    ${gnb_id}=2
    Execute Egate Command    gnb_endc_param send_secondary_rat_data_volume_report=on:5000 id=${gnb_id}

ICS trigger ENDC
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    alias=attach_ENDC_flow    overall_timeout=20
    ${cmd}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=${cell_id}
    Execute Uex Command    ${cmd}
    Flow Occurred As Expected    alias=attach_ENDC_flow

Wait for receiving message Secondary RAT Data Volume Report from SgNB
    Expect Message Flow
    ...    ENB_1:X2AP_SecondaryRATDataUsageReport
    ...    MME_1:S1AP_SecondaryRATDataUsageReport
    ...    ENB_1:X2AP_SecondaryRATDataUsageReport
    ...    MME_1:S1AP_SecondaryRATDataUsageReport
    ...    alias=wait_report_flow    overall_timeout=20
    sleep    ${wait_report}
    Flow Occurred As Expected    alias=wait_report_flow



