*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT
...                 CLOUD_R4P    team-CN3ET    owner-yu.1.zhou,annie.nie    release-SBTS21A
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS-1/PMRNL-1:mtUEQuantity=15min
...    MNL-1/MNLENT-1/PMCADM-1:reportingIntervalPm=15min
...    LNBTS-1:imsEmerPlmnConfig:emerSessLimServ=false|emerSessArpPrioLev=1
...    LNBTS-1/LNBTS_FDD-0:actIMSEmerSessR9=true
...    @{add_MODRED}
...    @{add_MORED}
...    @{add_moPrMapList}
...    @{add_REDRT}
...    @{FAF_CB007172}
...    LNCEL-1:inactivityTimer=20
@{add_REDRT}
...    LNCEL-1/REDRT-0:redirRat=nr
...    LNCEL-1/REDRT-0:redirectPrio=2
...    delete:LNCEL-1/REDRT-0:csFallBPrio
...    delete:LNCEL-1/REDRT-0:emerCallPrio
...    LNCEL-1/REDRT-0:redirNrCarFrq:carrierFreqNrCell=427970|ssbSubcarrierSpacing=15kHz
...    LNCEL-2/REDRT-0:redirRat=nr
...    LNCEL-2/REDRT-0:redirectPrio=1
...    delete:LNCEL-2/REDRT-0:csFallBPrio
...    delete:LNCEL-2/REDRT-0:emerCallPrio
...    LNCEL-2/REDRT-0:redirNrCarFrq:carrierFreqNrCell=10000|ssbSubcarrierSpacing=15kHz
...    LNCEL-3/REDRT-0:redirRat=nr
...    LNCEL-3/REDRT-0:redirectPrio=1
...    delete:LNCEL-3/REDRT-0:csFallBPrio
...    delete:LNCEL-3/REDRT-0:emerCallPrio
...    LNCEL-3/REDRT-0:redirNrCarFrq:carrierFreqNrCell=10000|ssbSubcarrierSpacing=15kHz
@{add_MODRED}
...    LNBTS-1/MODPR-0/MODRED-0:redirRAT=nr
...    LNBTS-1/MODPR-0/MODRED-0:redirectPrio=4
...    delete:LNBTS-1/MODPR-0/MODRED-0:csFallBPrio
...    delete:LNBTS-1/MODPR-0/MODRED-0:emerCallPrio
...    LNBTS-1/MODPR-0/MODRED-0:redirNrCarFrq:ssbSubcarrierSpacing=30kHz|carrierFreqNrCell=1000
...    LNBTS-1/MODPR-0/MODRED-1:redirRAT=nr
...    LNBTS-1/MODPR-0/MODRED-1:redirectPrio=2
...    delete:LNBTS-1/MODPR-0/MODRED-1:csFallBPrio
...    delete:LNBTS-1/MODPR-0/MODRED-1:emerCallPrio
...    LNBTS-1/MODPR-0/MODRED-1:redirNrCarFrq:ssbSubcarrierSpacing=30kHz|carrierFreqNrCell=1000
@{add_MORED}
...    LNBTS-1/MOPR-1/MORED-0:redirRAT=nr
...    LNBTS-1/MOPR-1/MORED-0:redirectPrio=8
...    delete:LNBTS-1/MOPR-1/MORED-0:csFallBPrio
...    delete:LNBTS-1/MOPR-1/MORED-0:emerCallPrio
...    LNBTS-1/MOPR-1/MORED-0:redirNrCarFrq:ssbSubcarrierSpacing=15kHz|carrierFreqNrCell=428910
...    LNBTS-1/MOPR-1/MORED-1:redirRAT=nr
...    LNBTS-1/MOPR-1/MORED-1:redirectPrio=1
...    delete:LNBTS-1/MOPR-1/MORED-1:csFallBPrio
...    delete:LNBTS-1/MOPR-1/MORED-1:emerCallPrio
...    LNBTS-1/MOPR-1/MORED-1:redirNrCarFrq:ssbSubcarrierSpacing=15kHz|carrierFreqNrCell=426250
@{add_moPrMapList}
...    LNBTS-1:actSelMobPrf=true
...    LNBTS-1/MODPR-0:autoAdapt=true
...    LNBTS-1:moProfileSelect=spid
...    LNCEL-1:moPrMappingList:spid=2|moPrId=1
...    LNCEL-1:moPrMappingList:spidLast=${EMPTY}|moPrId=1
...    LNCEL-1:moPrMappingList:mcc=262|moPrId=1
...    LNCEL-1:moPrMappingList:mnc=3|moPrId=1
...    LNCEL-1:moPrMappingList:mncLength=2|moPrId=1
@{FAF_CB007172}
...    LNCEL-1:actReturnTo5GSA=at end of non-emerg RRC or non-emerg voice
${ue_5GCapability1}    C59FF030030804081705C177E0D98808C0000480012001008A200424000AA0004008A480001000008240C000084003000000
# ue_5GCapability1 with NR band1
${UE_CTX_REL_ENB_IRAT_RED}    M8013C104
@{Case01_Counters}
...    LNCEL-1:${UE_CTX_REL_ENB_IRAT_RED}=1
${normal_qci1}
...    E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 6 and
...    e-RABlevelQoSParameters contains (qCI eq 1))
${qci5}
...    E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 7 and
...    e-RABlevelQoSParameters contains (qCI eq 5))
${emergency_qci1}
...    E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 8 and
...    e-RABlevelQoSParameters contains (qCI eq 1))
${release_redirect}
...    releaseCause eq "other" and redirectedCarrierInfo contains (nr-r15 contains
...    (carrierFreq-r15 eq 427970 and subcarrierSpacingSSB-r15 eq "kHz15"))
${PM_COUNTER_INTERVAL}    1min

*** Test Cases ***
CB007172-SR-A-c_ET_01_01_Redirect 5G when last non-emerg QCI1 release or RRCConnectionRelease without QCI1 triggered by inactivityTimer with REDRT
    [Tags]
    Attach UE1 With SA NR and spid 111 then Add One Normal QCI1 Bearer
    Release the Normal QCI1 Bearer then Check RRC Connection Release with redirect
    Attach UE With SA NR and spid 111 then Add One Normal QCI1 and One emergency QCI1 Bearer    ue_id=2
    Release the emergency QCI1 for UE2 without redirect
    Release the Last Normal QCI1 Bearer for UE2 without redirect
    Attach UE With SA NR and spid 111    ue_id=3    ue_capa=${ue_5GCapability1}
    Wait UE inactivityTimer expire then Check RRC Connection Release with redirect    ue_id=3
    Attach UE With SA NR and spid 111    ue_id=4    ue_capa=${ue_5GCapability1}
    Trigger UE4 context release by GTP-U Error then Check RRC Connection Release with redirect

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env
    Create Alias
    execute egate command    trace_sim on mme=1 protocol=s1
    execute egate command    trace uec=1 protocol=rrc on
    execute egate command    mme_param id=1 parallel_erab_release_cmd_and_nas=on

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create UE Alias    UE_4    ue_id=4    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    Add Yaml      EPC/PGW
    ...    - id: 3
    ...    type: 'simulated'
    ...    apn: 'emergency.nsn.com'
    ...    emergency: 'on'
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 1, pdn: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31}
    ...     - {qci: 8, default: on, pdn: 2}
    ...     - {qci: 1, pdn: 2, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31}
    ...     - {qci: 5, default: on, pdn: 3, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, priority: 1}
    ...     - {qci: 1, pdn: 3, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, priority: 1}
    FOR    ${ue_id}     IN RANGE    1    5
        Update Yaml    UEs/UE_sets/${ue_id}    bearer: bearer_set_2
    END

Attach UE With SA NR and spid 111
    [Arguments]    ${ue_id}    ${ue_capa}
    execute egate command    ue_mme_param id=${ue_id} spid=111
    expect message flow
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    alias=attach_ok    overall_timeout=20
    execute uex command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_capa} cell=1
    flow occurred as expected    alias=attach_ok

Attach UE1 With SA NR and spid 111 then Add One Normal QCI1 Bearer
    Start RTPM Counter
    Attach UE With SA NR and spid 111    ue_id=1    ue_capa=${ue_5GCapability1}
    expect message flow
    ...    MME_1:S1AP_E-RABSetupRequest (${normal_qci1})
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupItemBearerSURes contains (e-RAB-ID eq 6))
    ...    alias=normal_qci1    overall_timeout=20
    execute uex command    bearer_add ue=1 qci=1 mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    flow occurred as expected    alias=normal_qci1

Release the Normal QCI1 Bearer then Check RRC Connection Release with redirect
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionRelease (${release_redirect})
    ...    MME_1:S1AP_UEContextReleaseRequest (radioNetwork eq "interrat-redirection")
    ...    alias=release_redirect    overall_timeout=30
    execute uex command    bearer_del ue=1 qci=1
    flow occurred as expected    alias=release_redirect
    check rtpm counters    ${Case01_Counters}

Attach UE With SA NR and spid 111 then Add One Normal QCI1 and One emergency QCI1 Bearer
    [Arguments]    ${ue_id}
    Attach UE With SA NR and spid 111    ue_id=${ue_id}    ue_capa=${ue_5GCapability1}
    Add One Normal QCI1 and One emergency QCI1 Bearer for UE    ue_id=${ue_id}

Add One Normal QCI1 and One emergency QCI1 Bearer for UE
    [Arguments]    ${ue_id}
    expect message flow
    ...    MME_1:S1AP_E-RABSetupRequest (${normal_qci1})
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupItemBearerSURes contains (e-RAB-ID eq 6))
    ...    alias=ue2_normal_qci1    overall_timeout=20
    execute uex command    bearer_add ue=${ue_id} qci=1 mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31 apn=nokia_1.net
    flow occurred as expected    alias=ue2_normal_qci1
    expect message flow
    ...    MME_1:S1AP_E-RABSetupRequest (${qci5})
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupItemBearerSURes contains (e-RAB-ID eq 7))
    ...    MME_1:S1AP_E-RABSetupRequest (${emergency_qci1})
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupItemBearerSURes contains (e-RAB-ID eq 8))
    ...    alias=emergency_qci1    overall_timeout=20
    execute uex command    ue_pdn_connect id=${ue_id} apn=emergency.nsn.com request_type=emergency
    execute egate command    bearer_add ue=${ue_id} id=6 filter=1 precedence=1    Bearer-6 \\(EBI=8, QCI=1\\) created
    flow occurred as expected    alias=emergency_qci1

Release the emergency QCI1 for UE2 without redirect
    expect message will not occur
    ...    UE_2:RRC_RRCConnectionRelease (redirectedCarrierInfo contains ("nr-r15"))
    ...    alias=no_redirect_em    overall_timeout=20
    execute uex command    bearer_del ue=2 qci=1 apn=emergency.nsn.com
    flow not occurred for message    alias=no_redirect_em

Release the Last Normal QCI1 Bearer for UE2 without redirect
    expect message will not occur
    ...    UE_2:RRC_RRCConnectionRelease (redirectedCarrierInfo contains ("nr-r15"))
    ...    alias=no_redirect_normal    overall_timeout=20
    execute uex command    bearer_del ue=2 qci=1 apn=nokia_1.net
    flow not occurred for message    alias=no_redirect_normal

Wait UE inactivityTimer expire then Check RRC Connection Release with redirect
    [Arguments]    ${ue_id}    @{Release_Message}
    expect message flow
    ...    MME_1:S1AP_UEContextReleaseRequest (radioNetwork eq "user-inactivity")
    ...    UE_${ue_id}:RRC_RRCConnectionRelease (${release_redirect})
    ...    alias=ue3_redirect    overall_timeout=25
    flow occurred as expected    alias=ue3_redirect

Trigger UE4 context release by GTP-U Error then Check RRC Connection Release with redirect
    expect message flow
    ...    MME_1:S1AP_UEContextReleaseRequest (transport eq "transport-resource-unavailable")
    ...    UE_4:RRC_RRCConnectionRelease (${release_redirect})
    ...    alias=ue4_redirect    overall_timeout=20
    execute egate command    bearer_inject_gtpu_error_ind by=sgw device_id=1 ue=4 bearer=1    transport resource unavailable
    flow occurred as expected    alias=ue4_redirect