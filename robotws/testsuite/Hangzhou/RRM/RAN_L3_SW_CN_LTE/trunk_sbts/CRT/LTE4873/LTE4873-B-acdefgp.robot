*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CRT    team-SG5
...               CLOUD_R4LAPO_CUS    release-xL19A    owner-guangchong.fan
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
...    LNBTS-1:actEvtSecRatRep=true
...    LNBTS-1:tX2SgNBRelData=10000
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
@{PARAM_B-a_01-01}
...    LNBTS-1:tX2SgNBRelData=1000
...    LNBTS-1:rrcGuardTimer=300
#...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS-1/NRMEASPR-0:cellList=1
@{PARAM_B-a_01-01_recovery}
...    LNBTS-1:tX2SgNBRelData=10000
...    LNBTS-1:rrcGuardTimer=300
@{PARAM_B-c_02_01}
...    @{NRDCDPR}
@{PARAM_B-d_01-01}
...    @{NRDCDPR}
...    LNCEL-1:inactivityTimer=15
@{PARAM_B-e_01-01}
...    @{NRDCDPR}
...    LNBTS-1:tX2SgNBRelData=5000
...    LNCEL:inactivityTimer=60
@{PARAM_B-f_01-01}
...    @{NRDCDPR}
...    LNBTS-1:tX2SgNBRelData=5000
...    LNCEL:inactivityTimer=60
@{PARAM_B-g_04-01}
...    @{NRDCDPR}
...    LNBTS-1:tX2SgNBRelData=5000
...    LNCEL:inactivityTimer=60
...    LNCEL-1/LNCEL_FDD-0:maxNumActDrb=3
...    LNCEL-1/LNCEL_FDD-0:maxNumActUE=3
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=0
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUeDc=2
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe=2
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe3c=2
@{PARAM_B-g_04-01_recovery}
...    LNCEL-1/LNCEL_FDD-0:maxNumActDrb=265
...    LNCEL-1/LNCEL_FDD-0:maxNumActUE=265
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUeDc=20
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe=50
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe3c=20
@{PARAM_B-p}
...    @{NRDCDPR}
...    LNBTS-1:tX2SgNBRelData=5000
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
${ue_nr_capabilities}    0000000001010000000060100581007018000000
${ue_eutra_nr_capabilities}    0108040160401C06000000000400020101002004
@{PARAMS_IN_SWCONFIG}
...    0x00130060 = 1
#temporary workaround for LTE4193-B for supporting MeasTimingConf in X2SetupReponse for gNB
${wait_x2_setup}    60s

*** Test Cases ***
LTE4873-B-c_02_01 VDR send towards mme when en-gNB initiated takeback with release cause User Inactivity-UE active on LTE side
    [Documentation]    This case verifies that Secondary RAT Data Usage Report will send to MME when E-RABModificationIndication
    ...    after SCG split to MCG bearer with user inactivity
    [Tags]    RAN_4G    RAN_4G_FDD    CDRT
    Online parameter change    ${PARAM_B-c_02_01}
    Set UE parameters before ENDC setup    ue_id=2
    Set on simgnb side to send Secondary RAT Data Volume Report to eNodeB during SgNB Release procedure    gnb_id=2
    ICS trigger ENDC    ue_id=2
    Trigger SCG split to MSG bearer with user inactivity    ue_id=2

LTE4873-B-d_01_01 UE becomes active and VDR send to mme when en-gNB initiated takeback with cause other than User Inactivity-UE inactive at LTE side
    [Documentation]    This case verifies that UE becomes active and the Secondary RAT Data Usage Report sent towards to MME via the message
    ...    S1AP: E-RAB MODIFICATION INDICATION after en-gNB initiated SCG split to MCG bearer type change with release cause other than
    ...    "User inactivity" Precondition is Ue is inactive at eNB and traffic throungh SCG leg
    [Tags]
    Online parameter change    ${PARAM_B-d_01-01}
    Set UE parameters before ENDC setup    ue_id=3
    Set on simgnb side to send Secondary RAT Data Volume Report to eNodeB during SgNB Release procedure    gnb_id=2
    ICS trigger ENDC    ue_id=3
    Starting data traffic on SCG split bearer    ue_id=3
    Trigger SCG split to MSG bearer with RLF    ue_id=3

LTE4873-B-e_01-01 E-RAB RELEASE RESPONSE from MeNB to MME with Secondary RAT Usage Report List IE after SgNB addtion successful
    [Documentation]    This case verifies \ E-RAB RELEASE COMMAND from MME for Split SCG bearer after Split SCG bearer already established
    ...    ---timer not timeout
    [Tags]
    Online parameter change    ${PARAM_B-e_01-01}
    Set UE parameters before ENDC setup    ue_id=4
    Set on gnb sim send secondary rat data report    gnb_id=2
    ICS trigger ENDC    ue_id=4
    Delete SCG-Split Bearer    ue_id=4    qci=6

LTE4873-B-f_01-01 S1AP E-RAB MODIFICATION INDICATION from MeNB to MME with Secondary RAT Usage Report List IE after SgNB addtion successful
    [Documentation]    This case verifies S1AP: E-RAB MODIFICATION INDICATION \ from MeNB to MME with Secondary RAT Usage Report List IE
    ...    after SgNB addtion successful
    [Tags]
    Online parameter change    ${PARAM_B-f_01-01}
    Set UE parameters before ENDC setup    ue_id=5
    Set on gnb sim send secondary rat data report    gnb_id=2
    ICS trigger ENDC    ue_id=5
    Starting data traffic on bearer    ue_id=5    bearer_id=5
    Set ERAB Modification failure status
    Gnb initiated SCG split bearer to release    ue_id=5    bearer_id=2
    Set ERAB Modification normal status
    [Teardown]    LTE4873-B-f Teardown

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
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 6, filter: 1, precedence: 8, preprovisioned: on, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_4:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 6, preemption: on, vulnerability: on, priority: 11, pdn: 1}
    ...     - {qci: 7, pdn: 1}
    ...     - {qci: 9, preemption: on, vulnerability: on, priority: 10, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_5:
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 8, filter: 1, precedence: 8, preprovisioned: on, pdn: 1}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/3    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/4    bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/5    bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/6    bearer: bearer_set_4
    Update Yaml    UEs/UE_sets/7    bearer: bearer_set_5
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

Online parameter change
    [Arguments]    ${PARAM}
    Delta Commission Parameters    ${PARAM}
    Cells Should Be OnAir

Restore Env and Capture Logs
    [Arguments]    ${PARAM}
    Online parameter change    ${PARAM}
    Common Test Teardown And Stop Capture Logs

LTE4873-B-f Teardown
    Set ERAB Modification normal status
    Common Test Teardown And Stop Capture Logs

Set UE parameters before ENDC setup
    [Arguments]    ${ue_id}=1    ${gnb_id}=2
    Execute Uex Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=${ue_id} type=nr release=15 nr_supported_bands=7
    Execute Egate Command    gnb_endc_param id=${gnb_id} include_reestablish_pdcp=on
    Execute Egate Command    ue_enb_param id=${ue_id} ue_config_release_r9=rel15
	Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    Execute Egate Command    enb_timer T_DC_Overall=5000ms

Set on simgnb side to send Secondary RAT Data Volume Report to eNodeB during SgNB Release procedure
    [Arguments]    ${gnb_id}=2
    Execute Egate Command    gnb_endc_param id=${gnb_id} send_secondary_rat_data_volume_report=on:0

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

UE attach without ENDC
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Expect Message Will Not Occur
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    alias=attach_wo_ENDC_flow    overall_timeout=20
    ${cmd}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=${cell_id}
    Execute Uex Command    ${cmd}
    Flow Not Occurred For Message    alias=attach_wo_ENDC_flow

Detach UE to trigger sgnb release
    [Arguments]    ${ue_id}=1
    ${release_info}         catenate
    ...    SecondaryRATDataUsageReportList contains (
    ...    SecondaryRATDataUsageReportItem contains (
    ...    (e-RAB-ID eq 5) and
    ...    (secondaryRATType eq "nR")
    ...    ))
    Expect Message Flow
    ...    MME_1:S1AP_UEContextReleaseCommand
    ...    ENB_1:X2AP_SgNBReleaseRequest
    ...    ENB_1:X2AP_SgNBReleaseRequestAcknowledge
    ...    ENB_1:X2AP_SecondaryRATDataUsageReport
    ...    ENB_1:X2AP_UEContextRelease
    ...    MME_1:S1AP_UEContextReleaseComplete (${release_info})
    ...    alias=Detach_sgnb_rel_flow    overall_timeout=20
    Execute Uex Command    ue_detach id=${ue_id}
    Flow Occurred As Expected    alias=Detach_sgnb_rel_flow

Trigger SCG split to MSG bearer with user inactivity
    [Arguments]    ${ue_id}=1
    ${release_info}         catenate
    ...    SecondaryRATDataUsageReportList contains (
    ...    SecondaryRATDataUsageReportItem contains (
    ...    (e-RAB-ID eq 5) and
    ...    (secondaryRATType eq "nR") and
    ...    e-RABUsageReportList contains (id eq 267)
    ...    )
    ...    )
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBReleaseRequired (Cause contains (radioNetwork eq "user-inactivity"))
    ...    ENB_1:X2AP_SgNBReleaseConfirm
    ...    ENB_1:X2AP_SecondaryRATDataUsageReport
    ...    ENB_1:X2AP_UEContextRelease
    ...    MME_1:S1AP_E-RABModificationIndication (${release_info})
    ...    MME_1:S1AP_UEContextReleaseCommand
    ...    MME_1:S1AP_UEContextReleaseComplete
    ...    alias=inactive_sgnb_rel_flow    overall_timeout=20
    Execute Egate Command    enb_dc_ue_release by=gnb cause=RN_user_inactivity ue=${ue_id} bearer=1
    ...    UEContextRelease
    Execute Uex Command    ue_detach id=${ue_id}
    Flow Occurred As Expected    alias=inactive_sgnb_rel_flow

Starting data traffic on SCG split bearer
    [Arguments]    ${ue_id}=1    ${bearer_id}=5
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl protocol=udp bearer=${bearer_id} Mbps=1 trf_id=1

Starting data traffic on bearer
    [Arguments]    ${ue_id}=1    ${bearer_id}=5
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl protocol=udp bearer=${bearer_id} Mbps=1 trf_id=1

Trigger SCG split to MSG bearer with RLF
    [Arguments]    ${ue_id}=1
    ${release_info}         catenate
    ...    SecondaryRATDataUsageReportList contains (
    ...    SecondaryRATDataUsageReportItem contains (
    ...    (e-RAB-ID eq 5) and
    ...    (secondaryRATType eq "nR") and
    ...    e-RABUsageReportList contains (id eq 267)
    ...    )
    ...    )
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBReleaseRequired (Cause contains (radioNetwork eq "failure-in-the-radio-interface-procedure"))
    ...    ENB_1:X2AP_SgNBReleaseConfirm
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (drb-ToAddModList contains (drb-Identity eq 4))
    ...    ENB_1:X2AP_SecondaryRATDataUsageReport
    ...    MME_1:S1AP_E-RABModificationIndication (${release_info})
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    ENB_1:X2AP_UEContextRelease
    ...    MME_1:S1AP_UEContextReleaseCommand
    ...    MME_1:S1AP_UEContextReleaseComplete
    ...    alias=RLF_sgnb_rel_flow    overall_timeout=20
    Execute Egate Command    enb_dc_ue_release by=gnb cause=RN_failure_in_the_radio_interface_procedure ue=${ue_id} bearer=1
    ...    UEContextRelease    timeout=20s
    Execute Uex Command    ue_detach id=${ue_id}
    Flow Occurred As Expected    alias=RLF_sgnb_rel_flow

Set on gnb sim send secondary rat data report
    [Arguments]    ${gnb_id}=2    ${time}=0
    Execute Egate Command    gnb_endc_param send_secondary_rat_data_volume_report=on:${time} id=${gnb_id}

Delete SCG-Split Bearer
    [Arguments]    ${ue_id}=1    ${qci}=6
    ${release_info}         catenate
    ...    SecondaryRATDataUsageReportList contains (
    ...    SecondaryRATDataUsageReportItem contains (
    ...    (secondaryRATType eq "nR")
    ...    ))
    Expect Message Flow
    ...    MME_1:S1AP_E-RABReleaseCommand
    ...    ENB_1:X2AP_SgNBReleaseRequest (Cause contains (radioNetwork eq "unspecified"))
    ...    ENB_1:X2AP_SgNBReleaseRequestAcknowledge
    ...    ENB_1:X2AP_SecondaryRATDataUsageReport
    ...    ENB_1:X2AP_UEContextRelease
    ...    MME_1:S1AP_E-RABReleaseResponse (${release_info})
    ...    alias=del_bearer_sgnb_rel_flow    overall_timeout=20
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=del_bearer_sgnb_rel_flow

Set ERAB Modification failure status
    Execute Egate Command    link_s1_management_abnormal_cases mme_erab_modification_rsp=failure_rsp id=1

Set ERAB Modification normal status
    Execute Egate Command    link_s1_management_abnormal_cases mme_erab_modification_rsp=normal_rsp id=1

Gnb initiated SCG split bearer to release
    [Arguments]    ${ue_id}=1    ${bearer_id}=5
    ${release_info}         catenate
    ...    SecondaryRATDataUsageReportList contains (
    ...    SecondaryRATDataUsageReportItem contains (
    ...    (e-RAB-ID eq 6) and
    ...    (secondaryRATType eq "nR") and
    ...    e-RABUsageReportList contains (id eq 267)
    ...    ))
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBReleaseRequired (Cause contains (radioNetwork eq "failure-in-the-radio-interface-procedure"))
    ...    ENB_1:X2AP_SgNBReleaseConfirm
    ...    ENB_1:X2AP_SecondaryRATDataUsageReport
    ...    ENB_1:X2AP_UEContextRelease
    ...    MME_1:S1AP_E-RABModificationIndication (${release_info})
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    MME_1:S1AP_E-RABReleaseIndication (cause contains (radioNetwork eq "release-due-to-eutran-generated-reason"))
    ...    alias=gnb_ini_sgnb_rel_flow     overall_timeout=20
     Expect Message Will Not Occur
    ...    MME_1:S1AP_E-RABReleaseIndication (SecondaryRATDataUsageReportList contains (SecondaryRATDataUsageReportItem is present))
    ...    alias=gnb_ini_sgnb_rel_unexpect_flow    overall_timeout=20
    Execute Egate Command    enb_dc_ue_release by=gnb cause=RN_failure_in_the_radio_interface_procedure ue=${ue_id} bearer=${bearer_id}
    ...    UEContextRelease
    Flow Occurred As Expected    alias=gnb_ini_sgnb_rel_flow
    Flow Not Occurred For Message    alias=gnb_ini_sgnb_rel_unexpect_flow

Add LOW priority SCG Bearer
    [Arguments]    ${ue_id}=1    ${qci}=5
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    alias=add_bearer_ENDC_flow    overall_timeout=20
    Execute Uex Command        bearer_add ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=add_bearer_ENDC_flow

Add normal Bearer
    [Arguments]    ${ue_id}=1    ${qci}=5
    Execute Uex Command        bearer_add ue=${ue_id} qci=${qci}

Add HIGH priority Bearer to trigger preemption the SCG bearer
    [Arguments]    ${ue_id}=1    ${qci}=5
    ${release_info}         catenate
    ...    E-RABList contains (
    ...    E-RABItem contains (
    ...    cause contains (radioNetwork eq "release-due-to-pre-emption")
    ...    )) and
    ...    SecondaryRATDataUsageReportList contains (
    ...    SecondaryRATDataUsageReportItem contains (
    ...    (secondaryRATType eq "nR")
    ...    ))
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBReleaseRequest (Cause contains (radioNetwork eq "unspecified"))
    ...    ENB_1:X2AP_SgNBReleaseRequestAcknowledge
    ...    ENB_1:X2AP_SecondaryRATDataUsageReport
    ...    ENB_1:X2AP_UEContextRelease
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    MME_1:S1AP_E-RABReleaseIndication (${release_info})
    ...    alias=preemption_sgnb_rel_flow    overall_timeout=20
    Execute Uex Command        bearer_add ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=preemption_sgnb_rel_flow

Send MME Param Incloude SRDUR
    [Arguments]    ${ue_id}=1
    Execute Egate Command      ue_mme_param include_secondary_rat_data_usage_request=on id=${ue_id}

Modify Bearer
    [Arguments]    ${ue_id}=1    ${bearer_id}=1
    ${release_info}         catenate
    ...    SecondaryRATDataUsageReportList contains (
    ...    SecondaryRATDataUsageReportItem contains (
    ...    (e-RAB-ID eq 5) and
    ...    (secondaryRATType eq "nR") and
    ...    e-RABUsageReportList contains (id eq 267)
    ...    )
    ...    )
    Expect Message Flow
    ...    MME_1:S1AP_E-RABModifyRequest (value contains (SecondaryRATDataUsageRequest eq "requested"))
    ...    MME_1:S1AP_E-RABModifyResponse
    ...    ENB_1:X2AP_SgNBReleaseRequest (Cause contains (misc eq "unspecified"))
    ...    alias=modify_bearer_flow    overall_timeout=20
    Expect Message Will Not Occur
    ...    MME_1:S1AP_E-RABModifyResponse (${release_info})
    ...    alias=modify_bearer_wo_flow    overall_timeout=20
    Execute Egate Command    bearer_mod ue=${ue_id} id=${bearer_id} priority=3 vulnerability=off preemption=off    E-RABModifyResponse
    Execute Uex Command    ue_detach id=${ue_id}
    Flow Occurred As Expected    alias=modify_bearer_flow
    Flow Not Occurred For Message    alias=modify_bearer_wo_flow

