*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS
...               release-xL18    DEVHZ5_FT2    owner-shelly.song
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_NormalUE}
...    @{PARAMS_FOR_CATM_RRC_DRB}
...    @{PARAMS_FOR_TIMER}

@{PARAMS_FOR_NormalUE}
...    LNBTS-1:qciTab5:schedulType=SIGNALLING
...    LNBTS-1:qciTab5:lcgid=0
...    LNBTS-1:actMultBearers=true
...    LNBTS-1/LNBTS_FDD-0:actConvVoice=true
...    LNBTS-1:actRrcConnNoActivity=true

${UE_EUTRA_CAPABILITIES_CATM}    D61FF000800055555D55001000804510021200055C041900    # CATM FGI3,7,20 set as 1,enable ROHC
${UE_EUTRA_CAPABILITIES}    CA1FF43A33E6CB0007FFFFFFFC008006217FFFFFFF80

${lua_bearer2}    qci=1 default=off gbr_ul=25 gbr_dl=25 mbr_ul=25 mbr_dl=25 priority=1
${lua_bearer10}    qci=5 trf_type=internal default=on priority=1 pdn=2
${lua_bearer11}    qci=1 gbr_ul=25 gbr_dl=25 mbr_ul=25 mbr_dl=25 priority=1 pdn=2
${lua_bearer12}    ""
${lua_bearer13}    ""
${lua_pgw2_emergency}    emergency=on
${CAUSE=EMERGENCY ON}    emergency=on

@{PARAMS_FOR_CATM_RRC_DRB}
...    LNCEL-1/LNCEL_FDD-0:actCatM=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1/LNCEL_FDD-0:catMProfId=1
...    LNCEL-1/SIB-0:siWindowLen=40ms
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=0
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=0
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=0
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=0
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=0
...    LNBTS-1/LNBTS_FDD-0:actIMSEmerSessR9=true
...    LNCEL-1/LNCEL_FDD-0:addNumQci1DrbTimeCriticalHo=0
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe=0
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe3c=0
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUeDc=0
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:addEmergencySessions=0
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrcEmergency=335
...    LNCEL-3/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrcEmergency=335
...    LNBTS-1/CATMPR-1:maxNumRrcCatM=9
...    LNBTS-1/CATMPR-1:minNumRrcCatM=2
...    LNCEL-1/CATMCEL-0:actConvVoiceCatM=true
...    LNBTS-1/CATMPR-1:qciForVoLTECatM=255
...    LNBTS-1/CATMPR-1:catMVoLTETab:dlMaxHarqTxQci1CatM=4
...    LNBTS-1/CATMPR-1:catMVoLTETab:maxGbrDlQci1CatM=80
...    LNBTS-1/CATMPR-1:catMVoLTETab:maxGbrUlQci1CatM=80
...    LNBTS-1/CATMPR-1:catMVoLTETab:tDiscardPdcpQci1CatM=infinity
...    LNBTS-1/CATMPR-1:catMVoLTETab:ulMaxHarqTxQci1CatM=1
...    LNCEL-1/LNCEL_FDD-0:maxNumActDrb=21
...    LNCEL-1/LNCEL_FDD-0:maxNumQci1Drb=3
...    LNCEL-1/LNCEL_FDD-0:maxNumActUE=7
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrc=14
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrcEmergency=20
...    LNBTS-1/CATMPR-1:maxNumQci1DrbCatM=2
...    LNCEL-1/LNCEL_FDD-0:addNumQci1DrbRadioReasHo=0
...    LNCEL-1/LNCEL_FDD-0:addNumDrbTimeCriticalHo=0
...    LNCEL-1/LNCEL_FDD-0:addNumDrbRadioReasHo=0
...    LNBTS-1/CATMPR-1:maxNumRrcEmergencyCatM=9
...    LNBTS-1/CATMPR-1:maxNumQci1DrbEmergCatM=3
...    LNBTS-1/CATMPR-1:maxNumActDrbCatM=9
...    LNBTS-1/CATMPR-1:raPreGrCSizeCatM=1
...    LNCEL-1/CATMCEL-0:actIMSEmerSessCatM=true
...    LNBTS-1:actEnhAcAndGbrServices=true
@{PARAMS_FOR_TIMER}
...    LNCEL:inactivityTimer=170
...    LNCEL-1:inactivityTimerQci5Sign=100
...    LNCEL:qci1ProtectionTimer=180
...    LNBTS-1/CATMPR-1:cpInactivityTimerCatM=60
...    LNBTS-1/CATMPR-1:inactivityTimerCatM=150
...    LNBTS-1/CATMPR-1:srbInactivityTimerCatM=60
...    LNBTS-1/CATMPR-1:catMVoLTETab:qci1ProtectionTimerCatM=180
...    LNBTS-1/CATMPR-1:catMVoLTETab:tDiscardPdcpQci5CatM=300ms
@{emerSessArpPrioLev_2}
...    LNBTS-1:imsEmerPlmnConfig:emerSessArpPrioLev=2
@{emerSessArpPrioLev_1}
...    LNBTS-1:imsEmerPlmnConfig:emerSessArpPrioLev=1


*** Test Cases ***
LTE4057-A-d_ET_01_08
    [Tags]
    Normal UE1 Attach With EstablishmentCause = Emergency Then Setup QCI1 And Start DL traffic
    CAT-M UE2 Attach With EstablishmentCause = mo-Signalling Then Setup non-emergency QCI1 And Start DL traffic
    CAT-M UE3 Attach With EstablishmentCause = Emergency Then Setup QCI1 And Start DL traffic
    CAT-M UE4 Attach With EstablishmentCause = Emergency Do Reestablish Then Setup QCI1 And Start DL traffic
    CAT-M UE5 Attach With EstablishmentCause = Emergency Then Setup QCI1 Fail
    Detach All UEs

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Alias for mulipule UEs
    Create Enb alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Create UE Alias for mulipule UEs
    FOR    ${ue_id}    IN RANGE    1    5
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END

Modify Yaml
    Add Yaml      EPC/PGW
    ...    - id: 3
    ...    type: 'simulated'
    ...    apn: 'emergency.nsn.com'
    ...    emergency: 'on'

    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...      - {qci: 6, default: on, pdn: 1, trf_type: internal}
    ...      - {qci: 7, preprovisioned: off, default: off, pdn: 1}
    ...      - {qci: 8, preprovisioned: off, default: off, pdn: 1}
    ...      - {qci: 65, preprovisioned: off, default: off, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...      - {qci: 66, preprovisioned: off, default: off, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
     ...     - {qci: 6, default: on, pdn: 2}
    ...      - {qci: 1, mbr_ul: 31, gbr_dl: 31, gbr_ul: 31, mbr_dl: 31, pdn: 2}
    ...      - {qci: 5, default: on, pdn: 3, priority: 1}
    ...      - {qci: 1, pdn: 3, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31,
    ...         preemption: 1, vulnerability: 1, preprovisioned: on, filter: 1, precedence: 1, priority: 1}

    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/3    bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/4    bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/5    bearer: bearer_set_3

Online Change parameters emerSessArpPrioLev
    [Arguments]    ${parameters}=${emerSessArpPrioLev_2}
    Delta Commission Parameters    ${parameters}
    Cells Should Be OnAir

Normal UE1 Attach With EstablishmentCause = Emergency Then Setup QCI1 And Start DL traffic
    [Arguments]    ${ue_id}=1
    ${UE1_ATTACH_CMD}  catenate
    ...    ue_attach id=${ue_id} cell=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES}
    ...    establishment_cause=emergency
    ${emer_qci1}    catenate
    ...    E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 7 and qCI eq 1 and priorityLevel eq 'highest')
    Expect Message Flow
    ...    MME_1:S1AP_InitialUEMessage (RRC-Establishment-Cause eq 'emergency')
    ...    MME_1:S1AP_E-RABSetupRequest (${emer_qci1})
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq 7))
    ...    alias=UE1_emer_qci1    overall_timeout=20
    Execute Uex Command    ${UE1_ATTACH_CMD}
    Execute Uex Command    ue_pdn_connect id=${ue_id} apn=emergency.nsn.com request_type=emergency
    Flow Occurred as expected    alias=UE1_emer_qci1
    Execute UEx Command    trf_data_start ue=${ue_id} qci=1 kbps=30 dir=dl protocol=udp duration=600 duration_unit=seconds

CAT-M UE2 Attach With EstablishmentCause = mo-Signalling Then Setup non-emergency QCI1 And Start DL traffic
    [Arguments]    ${ue_id}=2
    Online Change parameters emerSessArpPrioLev
    ${UE2_ATTACH_CMD}  catenate
    ...    ue_attach id=${ue_id} cell=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM}
    ...    establishment_cause=mo_Signalling
    ${qci1}    catenate
    ...    E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 7 and qCI eq 1 and priorityLevel eq 'no-priority')
    Expect Message Flow
    ...    MME_1:S1AP_InitialUEMessage (RRC-Establishment-Cause eq 'mo-Signalling')
    ...    MME_1:S1AP_E-RABSetupRequest (${qci1})
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq 7))
    ...    alias=UE2_qci1    overall_timeout=20
    Execute Uex Command    ${UE2_ATTACH_CMD}
    Execute Uex Command    ue_pdn_connect id=${ue_id} apn=nokia_2.net
    Execute Uex Command    bearer_add ue=${ue_id} qci=1 apn=nokia_2.net mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    Flow Occurred as expected    alias=UE2_qci1
    Execute UEx Command    trf_data_start ue=${ue_id} qci=1 kbps=30 dir=dl protocol=udp duration=600 duration_unit=seconds

CAT-M UE3 Attach With EstablishmentCause = Emergency Then Setup QCI1 And Start DL traffic
    [Arguments]    ${ue_id}=3
    Online Change parameters emerSessArpPrioLev    parameters=${emerSessArpPrioLev_1}
    ${UE3_ATTACH_CMD}  catenate
    ...    ue_attach id=${ue_id} cell=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM}
    ...    establishment_cause=emergency
    ${emer_qci1}    catenate
    ...    E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 7 and qCI eq 1 and priorityLevel eq 'highest')
    Expect Message Flow
    ...    MME_1:S1AP_InitialUEMessage (RRC-Establishment-Cause eq 'emergency')
    ...    MME_1:S1AP_E-RABSetupRequest (${emer_qci1})
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq 7))
    ...    alias=UE3_emer_qci1    overall_timeout=20
    Execute Uex Command    ${UE3_ATTACH_CMD}
    Execute Uex Command    ue_pdn_connect id=${ue_id} apn=emergency.nsn.com request_type=emergency
    Flow Occurred as expected    alias=UE3_emer_qci1
    Execute UEx Command    trf_data_start ue=${ue_id} qci=1 kbps=30 dir=dl protocol=udp duration=600 duration_unit=seconds

CAT-M UE4 Attach With EstablishmentCause = Emergency Do Reestablish Then Setup QCI1 And Start DL traffic
    [Arguments]    ${ue_id}=4
    ${UE4_ATTACH_CMD}  catenate
    ...    ue_attach id=${ue_id} cell=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM}
    ...    establishment_cause=emergency
    ${emer_qci1}    catenate
    ...    E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 7 and qCI eq 1 and priorityLevel eq 'highest')
    Expect Message Flow
    ...    MME_1:S1AP_InitialUEMessage (RRC-Establishment-Cause eq 'emergency')
    ...    UE_${ue_id}:RRC_RRCConnectionReestablishmentRequest (reestablishmentCause eq "otherFailure")
    ...    UE_${ue_id}:RRC_RRCConnectionReestablishmentComplete
    ...    MME_1:S1AP_E-RABSetupRequest (${emer_qci1})
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq 7))
    ...    alias=UE4_emer_qci1    overall_timeout=20
    Execute Uex Command    ${UE4_ATTACH_CMD}
	sleep    5
    Execute Uex Command    ue_rrc_reestablish id=${ue_id} enb=1 cell=1
    Execute Uex Command    ue_pdn_connect id=${ue_id} apn=emergency.nsn.com request_type=emergency
    Flow Occurred as expected    alias=UE4_emer_qci1
    Execute UEx Command    trf_data_start ue=${ue_id} qci=1 kbps=30 dir=dl protocol=udp duration=600 duration_unit=seconds

CAT-M UE5 Attach With EstablishmentCause = Emergency Then Setup QCI1 Fail
    [Arguments]    ${ue_id}=5
    ${UE5_ATTACH_CMD}  catenate
    ...    ue_attach id=${ue_id} cell=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM}
    ...    establishment_cause=emergency
    ${emer_qci1}    catenate
    ...    E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 7 and qCI eq 1 and priorityLevel eq 'highest')
    Expect Message Flow
    ...    MME_1:S1AP_InitialUEMessage (RRC-Establishment-Cause eq 'emergency')
    ...    MME_1:S1AP_E-RABSetupRequest (${emer_qci1})
    ...    MME_1:S1AP_E-RABSetupResponse (cause contains (radioNetwork eq "radio-resources-not-available"))
    ...    alias=UE5_emer_qci1    overall_timeout=20
    Execute Uex Command    ${UE5_ATTACH_CMD}
    Execute UEx Command    ue_pdn_connect id=${ue_id} apn=emergency.nsn.com request_type=emergency
    Flow Occurred as expected    alias=UE5_emer_qci1

Detach All UEs
    Execute Uex Command    ue_detach id=1..5