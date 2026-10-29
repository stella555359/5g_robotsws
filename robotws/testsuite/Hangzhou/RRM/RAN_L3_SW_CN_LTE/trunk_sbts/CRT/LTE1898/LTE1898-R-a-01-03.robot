*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS    release-L18
...               DevHZ5_SG4    owner-zhiguo.li
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS-1:actERabModify=true
...    LNBTS-1:actEnhAcAndGbrServices=true
...    LNBTS-1:actMultBearers=true
...    LNBTS-1:actMultGbrBearers=true
...    LNBTS-1:actNonGbrServiceDiff=true
...    LNBTS-1:act8EpsBearers=true
...    LNBTS-1:actOperatorQCIGBR=false
...    LNBTS-1:actOperatorQCI=false
...    LNBTS-1:maxNumPreEmptions=20
...    LNBTS-1:timDelACContPreempt=100
...    LNBTS-1:actPartialAcHo=true
...    LNBTS-1/LNBTS_TDD-0:actHighPrioServices=false
...    LNBTS-1/LNBTS_TDD-0:actPubSafetyBearers=false
...    LNBTS-1/LNBTS_TDD-0:actConvVoice=true
...    LNBTS-1/LNBTS_TDD-0:actIMSEmerSessR9=false
...    LNBTS-1:actContextPreemption=true
...    LNBTS-1:estCauseArpMapConfig:arpPriority=1|estCause=emergency
...    LNBTS-1:estCauseArpMapConfig:preemptionCap=true|estCause=emergency
...    LNBTS-1:estCauseArpMapConfig:arpPriority=2|estCause=highPriorityAccess
...    LNBTS-1:estCauseArpMapConfig:preemptionCap=true|estCause=highPriorityAccess
...    LNBTS-1:estCauseArpMapConfig:arpPriority=10|estCause=mt-Access
...    LNBTS-1:estCauseArpMapConfig:preemptionCap=true|estCause=mt-Access
...    LNBTS-1:estCauseArpMapConfig:arpPriority=11|estCause=mo-Signalling
...    LNBTS-1:estCauseArpMapConfig:preemptionCap=true|estCause=mo-Signalling
...    LNBTS-1:estCauseArpMapConfig:arpPriority=12|estCause=mo-Data
...    LNBTS-1:estCauseArpMapConfig:preemptionCap=true|estCause=mo-Data
...    LNBTS-1:estCauseArpMapConfig:arpPriority=13|estCause=delayTolerantAccess-v1020
...    LNBTS-1:estCauseArpMapConfig:preemptionCap=true|estCause=delayTolerantAccess-v1020
...    LNCEL/SIB-0:t300=2000ms
...    LNCEL-1/LNCEL_TDD-0:actAutoPucchAlloc=false
...    LNCEL-1/LNCEL_TDD-0:srsActivation=true
...    LNCEL-1/LNCEL_TDD-0:srsBwConf=0bw
...    LNCEL-1/LNCEL_TDD-0:srsSubfrConf=sc0
...    LNCEL-1/LNCEL_TDD-0:srsOnTwoSymUpPts=false
...    LNCEL-1/LNCEL_TDD-0:srsDlMimoModeDepConf:srsBandwidth=0hbw|beamformingType=nonBeamforming
...    LNCEL/LNCEL_TDD-0:chBw=20 MHz
...    LNCEL:actNbrForNonGbrBearers=false
...    LNBTS-1:qciTab2:maxGbrDl=12000
...    LNBTS-1:qciTab2:maxGbrUl=520
...    LNBTS-1:qciTab3:maxGbrDl=12000
...    LNBTS-1:qciTab3:maxGbrUl=520
...    LNBTS-1:qciTab4:maxGbrDl=12000
...    LNBTS-1:qciTab4:maxGbrUl=520
@{PREEMPT_SUCCESS}
...    LNCEL-1:${PRE_EMPT_UE_CTX_PCELL}>0
...    LNCEL-1:${PRE_EMPT_UE_CTX_CELL_RES}>0
...    LNCEL-1:${PRE_EMPT_UE_CTX_SCELL}=0
${PRE_EMPT_UE_CTX_PCELL}    M8013C100
${PRE_EMPT_UE_CTX_SCELL}    M8013C101
${PRE_EMPT_UE_CTX_CELL_RES}    M8013C102
${total_ueid}     20
${PM_SPEED_UP_FLAG}    ${True}

*** Test Cases ***
LTE1898-R-a_ET_03_UE preemption due to SRS resources shortage during intraCellHandover
    [Tags]
    Set UE ARP Profile For Own Cell Preemption
    Attach UE And Modify Bearers
    Add New UE Context To Trigger Preemption
    Check Counters    ${PREEMPT_SUCCESS}

*** Keyword ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs    ue_count=100
    Create UE Alias for multi UEs
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Create UE Alias for multi UEs
    FOR    ${ue_id}    IN RANGE    1    21
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END


Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, priority: 12, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 6, preprovisioned: on, filter: 1, precedence: 1, remote_port: 7070, proto: 17, priority: 13, vulnerability: on, pdn: 1}
    FOR    ${ue_id}    IN RANGE    2    20
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_2
    END
    Update Yaml    UEs/UE_sets/20    bearer: bearer_set_3


Set UE ARP Profile For Own Cell Preemption
    Execute Egate Command    sim_trace uec=1 protocol=rrc on
    Execute Egate Command    proxy_log GEN=debug
    Execute Uex Command    ue_param id=1-${total_ueid} supported_bands=38,39,40,41

Attach UE And Modify Bearers
    ${eRAB12}    catenate
    ...    E-RABToBeModifiedItemBearerModReq contains (
    ...      e-RAB-ID eq 5
    ...      and
    ...      qCI eq 8
    ...      and
    ...      priorityLevel eq 12)
    ${eRAB13}    catenate
    ...    E-RABToBeModifiedItemBearerModReq contains (
    ...      e-RAB-ID eq 5
    ...      and
    ...      qCI eq 8
    ...      and
    ...      priorityLevel eq 13)
    Expect Message Flow
    ...    MME_1:S1AP_InitialUEMessage (RRC-Establishment-Cause eq 'mo-Signalling')
    ...    MME_1:S1AP_InitialUEMessage (RRC-Establishment-Cause eq 'delay-TolerantAccess')
    ...    MME_1:S1AP_E-RABModifyRequest (${eRAB12})
    ...    MME_1:S1AP_E-RABModifyResponse
    ...    MME_1:S1AP_E-RABModifyRequest (${eRAB13})
    ...    MME_1:S1AP_E-RABModifyResponse
    ...    alias=AttachAndModifyBearers    overall_timeout=60
    Execute UEx Command    ue_attach id=1 cell=1 establishment_cause=mo-Signalling
    FOR    ${ue_id}    IN RANGE    2    ${total_ueid}
        Execute UEx Command    ue_attach id=${ue_id} cell=1 establishment_cause=mo_Data
    END
    Execute UEx Command    ue_attach id=${total_ueid} cell=1 establishment_cause=delayTolerantAccess_v1020
    Execute Egate Command    bearer_mod ue=${${total_ueid}-1} id=1 priority=12 preemption=1 vulnerability=1
    ...    Bearer 1 \\(EBI=5\\) has been modified
    Execute Egate Command    bearer_mod ue=${total_ueid} id=1 priority=13 preemption=1 vulnerability=1
    ...    Bearer 1 \\(EBI=5\\) has been modified
    Flow Occurred As Expected    alias=AttachAndModifyBearers

Add New UE Context To Trigger Preemption
    Modify IntraCellHo UE Bearer


Modify IntraCellHo UE Bearer
    ${eRAB11}    catenate
    ...    E-RABToBeModifiedItemBearerModReq contains (
    ...      e-RAB-ID eq 5
    ...      and
    ...      qCI eq 8
    ...      and
    ...      priorityLevel eq 11)
    Expect Message Flow
    ...    MME_1:S1AP_E-RABModifyRequest (${eRAB11})
    ...    MME_1:S1AP_E-RABModifyResponse
    ...    MME_1:S1AP_UEContextReleaseRequest (Cause contains (radioNetwork eq "release-due-to-pre-emption"))
    ...    UE_1:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 1))
    ...    alias=ModifyBearersAndHO    overall_timeout=60
    Execute Egate Command    bearer_mod ue=1 id=1 priority=11 preemption=1 vulnerability=1    Bearer 1 \\(EBI=5\\) has been modified
    FOR    ${round}    IN RANGE    0    5
        Establish 6 Bearers
        Delete 6 Bearers
    END
    Flow Occurred As Expected    alias=ModifyBearersAndHO

Establish 6 Bearers
    [Documentation]    looks like 3 GBR could exist at most or reach pdn limit of bit rate that cause 'radioNetwork: invalid-qos-combination'
    Execute Egate Command    bearer_add ue=1 id=3 filter=2 precedence=2    Bearer-3 \\(EBI=6, QCI=2\\) created
    Execute Egate Command    bearer_add ue=1 id=4 filter=3 precedence=3    Bearer-4 \\(EBI=7, QCI=3\\) created
    Execute Egate Command    bearer_add ue=1 id=5 filter=4 precedence=4    Bearer-5 \\(EBI=8, QCI=4\\) created
    Execute Egate Command    bearer_add ue=1 id=7 filter=6 precedence=6    Bearer-7 \\(EBI=9, QCI=6\\) created
    Execute Egate Command    bearer_add ue=1 id=8 filter=7 precedence=7    Bearer-8 \\(EBI=10, QCI=7\\) created
    Execute Egate Command    bearer_add ue=1 id=9 filter=8 precedence=8    Bearer-9 \\(EBI=11, QCI=9\\) created

Delete 6 Bearers
    Execute Egate Command    bearer_del ue=1 id=3
    ...    Bearer-3 \\(EBI=6\\) deleted in result of PGW-initiated Bearer Deletion procedure
    Execute Egate Command    bearer_del ue=1 id=4
    ...    Bearer-4 \\(EBI=7\\) deleted in result of PGW-initiated Bearer Deletion procedure
    Execute Egate Command    bearer_del ue=1 id=5
    ...    Bearer-5 \\(EBI=8\\) deleted in result of PGW-initiated Bearer Deletion procedure
    Execute Egate Command    bearer_del ue=1 id=7
    ...    Bearer-7 \\(EBI=9\\) deleted in result of PGW-initiated Bearer Deletion procedure
    Execute Egate Command    bearer_del ue=1 id=8
    ...    Bearer-8 \\(EBI=10\\) deleted in result of PGW-initiated Bearer Deletion procedure
    Execute Egate Command    bearer_del ue=1 id=9
    ...    Bearer-9 \\(EBI=11\\) deleted in result of PGW-initiated Bearer Deletion procedure