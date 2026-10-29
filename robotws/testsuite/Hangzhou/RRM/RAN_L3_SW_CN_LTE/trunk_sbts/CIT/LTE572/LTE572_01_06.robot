*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CIT    CLOUD_R4LAPO_CUS
...               team-SG4    release-SBTS19A    owner-menghuan.fang
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS-1/LNBTS_TDD-0:actIMSEmerSessR9=true
...    LNBTS-1:imsEmerPlmnConfig:emerSessArpPreemCap=true
...    LNBTS-1:imsEmerPlmnConfig:emerSessArpPreemVul=false
...    LNBTS-1:imsEmerPlmnConfig:emerSessArpPrioLev=1
...    LNBTS-1:imsEmerPlmnConfig:emerSessLimServ=true
...    LNBTS-1:imsEmerPlmnConfig:emerSessMcc=262
...    LNBTS-1:imsEmerPlmnConfig:emerSessMnc=3
...    LNBTS-1:imsEmerPlmnConfig:emerSessMncLen=2
...    LNCEL-1/LNCEL_TDD-0:actAutoPucchAlloc=false
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:maxNumRrcEmergency=2
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:maxNumRrc=1
...    LNCEL-1/LNCEL_TDD-0:maxNumActUE=1
...    LNCEL-1/LNCEL_TDD-0:maxNumQci1Drb=0
...    LNCEL-1/LNCEL_TDD-0:maxNumActDrb=2
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUeDc=1
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUe3c=1
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUe=1
...    LNCEL-1/LNCEL_TDD-0:addNumDrbRadioReasHo=1
...    LNCEL-1/LNCEL_TDD-0:addNumDrbTimeCriticalHo=1
...    LNCEL-1/LNCEL_TDD-0:addNumQci1DrbTimeCriticalHo=1
...    LNCEL-1/LNCEL_TDD-0:addNumQci1DrbRadioReasHo=1
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:addEmergencySessions=1
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:addAUeRrHo=1
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:addAUeTcHo=1
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:minNumEmergencySessions=0
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:minNumRrc=0
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:minNumRrcNoDrb=0
...    LNCEL-1:t302=10000
...    LNCEL-1:inactivityTimer=2000

@{Set_Ue_Limit}
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:maxNumRrcEmergency=2
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:maxNumRrc=1
...    LNCEL-1/LNCEL_TDD-0:maxNumActUE=1
...    LNCEL-1/LNCEL_TDD-0:maxNumQci1Drb=0
...    LNCEL-1/LNCEL_TDD-0:maxNumActDrb=2
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:addEmergencySessions=1

@{PM_COUNTERS_FOR_01_06}
...    LNBTS-1:M8000C32=3
...    LNBTS-1:M8000C33=2
...    LNBTS-1:M8000C34=1
...    LNBTS-1:M8013C21=2    # 4, in CUS when attach fail not retry 3 times
...    LNBTS-1:M8013C26=1
...    LNBTS-1:M8013C27=1    # 3, in CUS when attach fail not retry 3 times

${ue_eutra_capabilities}    91BFF043033E8CB0007FFFFFFFC000
${ue_nr_capabilities}    0000000001010000000060100581007018000000
${ue_eutra_nr_capabilities}    0108040160401C06000000000400020101002004
${UE_UTRA_Capabilities}
...    SEPARATOR=
...    40000AC0CAAB541A955AA22920C102000600054184031EFA8063DC073CA1C410143AE86400E80DC152980000B492DE91346CD42C0448F872E6
...    CFAD80891F0E5CD9E8580891F0E5CD9FE0

*** Test Cases ***
LTE572_01_06_IMS Emergency Session check with RAC of maxNumRrcEmergency
    [Tags]
    Limit 3 DRB by Online parameter change maxNumActDrb to 2 and addEmergencySessions to 1 
    Start Rtpm Counter
    non-Emergency UE1 attach Successful with QCI8 PDN1
    non-Emergency UE2 attach fail that RRC Rejected
    Emergency UE3 attach successful with QCI5 PDN3
    UE1 and UE3 loop add bearer only allow one more DBR to be connected
    Emergency UE4 attach fail that RRC Rejected 
    Comment    Counter value of E-RAB Setup update correctly
    Check Rtpm Counters    ${PM_COUNTERS_FOR_01_06}

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs
    Create Alias

Create Alias
    FOR    ${ue_id}    IN RANGE    1    5
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=5    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Modify Yaml
    Add Yaml      EPC/PGW
    ...    - id: 3
    ...    type: 'simulated'
    ...    apn: 'emergency.nsn.com'
    ...    emergency: 'on'
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1, trf_type: internal}
    ...     - {qci: 5, default: on, pdn: 3, trf_type: internal}
    ...     - {qci: 1, mbr_ul: 25, gbr_dl: 25, gbr_ul: 25, mbr_dl: 25, pdn: 1, priority: 1}
    ...     - {qci: 1, mbr_ul: 25, gbr_dl: 25, gbr_ul: 25, mbr_dl: 25, pdn: 3, priority: 1}
    FOR    ${ue_id}     IN RANGE    1    5
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_2
    END

Limit 3 DRB by Online parameter change maxNumActDrb to 2 and addEmergencySessions to 1 
    Delta Commission Parameters    ${Set_Ue_Limit}
    Cells Should Be OnAir

Display UE Status
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_disp id=${ue_id} at=mme
    Execute Egate Command    ue_disp id=${ue_id} at=sgw
    Execute Egate Command    bearer_disp ue=${ue_id}
    Execute Egate Command    bearer_disp ue=${ue_id} at=mme
    Execute Egate Command    bearer_disp ue=${ue_id} at=sgw
    Execute Uex Command    get_bearer_info ue=${ue_id}

non-Emergency UE1 attach Successful with QCI8 PDN1
    [Arguments]    ${ue_id}=1    ${enb_id}=1    ${cell_id}=1
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionRequest ( spare contains ('0') )
    ...    UE_1:RRC_RRCConnectionSetup ( uplinkPowerControlDedicated contains (p0-UE-PUCCH eq 0 and p0-UE-PUSCH eq 0) )
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupListCtxtSUReq contains (qCI eq 8))
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_1:RRC_RRCConnectionReconfiguration ( carrierFreq eq 38000 )
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE1_attach_successful    overall_timeout=30
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} ue_utra_capabilities=${UE_UTRA_Capabilities} enb=${enb_id} cell=${cell_id}
    Execute Uex Command    ${V_1}
    Flow Occurred As Expected    alias=UE1_attach_successful

non-Emergency UE2 attach fail that RRC Rejected
    [Arguments]    ${ue_id}=2    ${enb_id}=1    ${cell_id}=1
    Expect Message Flow
    ...    UE_2:RRC_RRCConnectionRequest ( spare contains ('0') )
    ...    UE_2:RRC_RRCConnectionReject ( waitTime eq 10 )
    ...    alias=UE2_RRC_connection_rejected    overall_timeout=30
    ${V_2}    catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} ue_utra_capabilities=${UE_UTRA_Capabilities} enb=${enb_id} cell=${cell_id}
    Run Keyword And Ignore Error    Execute Uex Command    ${V_2}
    Flow Occurred As Expected    alias=UE2_RRC_connection_rejected

UE1 and UE3 loop add bearer only allow one more DBR to be connected
    UE1 Setup normal QCI1 priority1 successful
    UE3 Setup emergency QCI1 fail
    UE1 Release normal QCI1 successful
    UE3 Setup emergency QCI1 successful

Emergency UE3 attach successful with QCI5 PDN3
    [Arguments]    ${ue_id}=3    ${enb_id}=1    ${cell_id}=1
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionRequest ( spare contains ('0') )
    ...    UE_${ue_id}:RRC_RRCConnectionSetup ( uplinkPowerControlDedicated contains (p0-UE-PUCCH eq 0 and p0-UE-PUSCH eq 0) )
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupListCtxtSUReq contains (qCI eq 5))
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( carrierFreq eq 38000 )
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE${ue_id}_attach_successful    overall_timeout=30
    ${V_3}    catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} ue_utra_capabilities=${UE_UTRA_Capabilities} enb=${enb_id} cell=${cell_id}
    ...    emergency=on establishment_cause=emergency
    Execute Uex Command    ${V_3}
    Flow Occurred As Expected    alias=UE${ue_id}_attach_successful

UE1 Setup normal QCI1 priority1 successful
    [Arguments]    ${ue_id}=1    ${qci}=1    ${apn}=nokia_1.net
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 1))
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq 6))
    ...    alias=UE${ue_id}_setup_QCI1_bearer_successful    overall_timeout=30	
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci} mbr_ul=25 mbr_dl=25 gbr_ul=25 gbr_dl=25 apn=${apn}
    Flow Occurred As Expected    alias=UE${ue_id}_setup_QCI1_bearer_successful

UE3 Setup emergency QCI1 fail
    [Arguments]    ${ue_id}=3    ${qci}=1    ${apn}=emergency.nsn.com
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 1))
    ...    MME_1:S1AP_E-RABSetupResponse (e-RAB-ID eq 6 and cause contains (radioNetwork eq "radio-resources-not-available"))
    ...    alias=UE3_Setup_emergency_QCI1_fail    overall_timeout=30
    log to console    \nYaml parameter: set_bearer id=4 ue=1 qci=1 mbr_ul=25 gbr_dl=25 gbr_ul=25 mbr_dl=25 pdn=3 priority=1
    Execute Egate Command    bearer_add ue=${ue_id} id=4 filter=11 precedence=11
    ...    pass_regexp=UE3: PGW-initiated Bearer Creation. SGW failed to create Bearer-4 with cause=6-CV_ERR_IND_FROM_RNC
    Flow Occurred As Expected    alias=UE3_Setup_emergency_QCI1_fail

UE1 Release normal QCI1 successful
    [Arguments]    ${ue_id}=1    ${qci}=1    ${apn}=nokia_1.net
    Expect Message Flow
    ...    MME_1:S1AP_E-RABReleaseCommand (E-RABList contains (e-RAB-ID eq 6 and cause contains (nas eq 'normal-release')))
    ...    MME_1:S1AP_E-RABReleaseResponse (e-RAB-ID eq 6)
    ...    alias=UE1_release_QCI1_bearer    overall_timeout=30
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci} apn=${apn}
    Flow Occurred As Expected    alias=UE1_release_QCI1_bearer

UE3 Setup emergency QCI1 successful
    [Arguments]    ${ue_id}=3    ${qci}=1    ${apn}=emergency.nsn.com
    Display UE Status    ue_id=3
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 1))
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq 6))
    ...    alias=UE${ue_id}_setup_QCI1_bearer_successful    overall_timeout=30
    log to console    \nYaml parameter: set_bearer id=4 ue=1 qci=1 mbr_ul=25 gbr_dl=25 gbr_ul=25 mbr_dl=25 pdn=3 priority=1
    Execute Egate Command    bearer_add ue=${ue_id} id=4 filter=11 precedence=11
    ...    pass_regexp=UE3: PGW-initiated Bearer Creation. Bearer-4 \\(EBI=6, QCI=1\\) created
    Flow Occurred As Expected    alias=UE${ue_id}_setup_QCI1_bearer_successful

Emergency UE4 attach fail that RRC Rejected
    [Arguments]    ${ue_id}=4    ${enb_id}=1    ${cell_id}=1
    Expect Message Flow
    ...    UE_4:RRC_RRCConnectionRequest ( spare contains ('0') )
    ...    UE_4:RRC_RRCConnectionReject ( waitTime eq 10 )
    ...    alias=UE4_RRC_connection_rejected    overall_timeout=30
    ${V_4}    catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} ue_utra_capabilities=${UE_UTRA_Capabilities} enb=${enb_id} cell=${cell_id}
    ...    emergency=on establishment_cause=emergency
    Run Keyword And Ignore Error    Execute Uex Command    ${V_4}
    Flow Occurred As Expected    alias=UE4_RRC_connection_rejected

Counter value of E-RAB Setup update correctly
    ${pm_counters}=    Create List    LNBTS-1:M8000C32=3    LNBTS-1:M8000C33=2    LNBTS-1:M8000C34=1    LNBTS-1:M8013C21=4    LNBTS-1:M8013C26=1
    ...    LNBTS-1:M8013C27=3
    ${V_2}    catenate
    ...    should +1 for every rejection due to missing RB resources, PR for UEC or SPEC according to LTE_CP_51383 "Counter shall be updated at
    ...    transmission of RRC Connection Reject if the EstablishmentCause IE in RRC: RRCConnectionRequest was "emergency" AND O&M
    ...    parametactIMSEmerSessR9 is set to true AND procedure is failed due to received CELLC_RacResp with NotOk cause", maybe EStatusLte_NotOk not
    ...    ECauseLte
    Comment    ${V_2}
    Check Counters    ${pm_counters}
