*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS
...               team-DevHZ5_SG4    owner-eric.jiang    release-SBTS21A
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS-1/PMRNL-1:mtUEQuantity=15min
...    MNL-1/MNLENT-1/PMCADM-1:reportingIntervalPm=15min
...    LNBTS-1:imsEmerPlmnConfig:emerSessLimServ=false|emerSessArpPrioLev=1
...    LNBTS-1/LNBTS_TDD-0:actIMSEmerSessR9=true
...    @{Active_SIB24_Cell1}
...    @{add_MODRED}
...    @{add_MORED}
...    @{add_moPrMapList}
...    @{add_REDRT}
...    @{FAF_CB007172}
@{Active_SIB24_Cell1}
...    LNBTS-1:actSIB24=true
...    LNBTS-1/LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB24
...    LNBTS-1/LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB24
...    LNBTS-1/LNCEL-1/NRFIM-1:nrCarFrqL:dlCarFrqNr=427970
...    LNBTS-1/LNCEL-1/IRFIM-1:eutCelResPrio=5
@{add_REDRT}
...    LNCEL-1/REDRT-0:redirRat=nr
...    LNCEL-1/REDRT-0:redirectPrio=2
...    delete:LNCEL-1/REDRT-0:csFallBPrio
...    delete:LNCEL-1/REDRT-0:emerCallPrio
...    LNCEL-1/REDRT-0:redirNrCarFrq:carrierFreqNrCell=10000|ssbSubcarrierSpacing=15kHz
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
...    LNBTS-1/MODPR-0/MODRED-0:redirectPrio=8
...    delete:LNBTS-1/MODPR-0/MODRED-0:csFallBPrio
...    delete:LNBTS-1/MODPR-0/MODRED-0:emerCallPrio
...    LNBTS-1/MODPR-0/MODRED-0:redirNrCarFrq:ssbSubcarrierSpacing=30kHz|carrierFreqNrCell=427970|ssbOffset=0
...    LNBTS-1/MODPR-0/MODRED-1:redirRAT=nr
...    LNBTS-1/MODPR-0/MODRED-1:redirectPrio=1
...    delete:LNBTS-1/MODPR-0/MODRED-1:csFallBPrio
...    delete:LNBTS-1/MODPR-0/MODRED-1:emerCallPrio
...    LNBTS-1/MODPR-0/MODRED-1:redirNrCarFrq:ssbSubcarrierSpacing=15kHz|carrierFreqNrCell=518910|ssbOffset=0
@{add_MORED}
...    LNBTS-1/MOPR-1/MORED-0:redirRAT=nr
...    LNBTS-1/MOPR-1/MORED-0:redirectPrio=8
...    delete:LNBTS-1/MOPR-1/MORED-0:csFallBPrio
...    delete:LNBTS-1/MOPR-1/MORED-0:emerCallPrio
...    LNBTS-1/MOPR-1/MORED-0:redirNrCarFrq:ssbSubcarrierSpacing=30kHz|carrierFreqNrCell=426250
...    LNBTS-1/MOPR-1/MORED-1:redirRAT=nr
...    LNBTS-1/MOPR-1/MORED-1:redirectPrio=1
...    delete:LNBTS-1/MOPR-1/MORED-1:csFallBPrio
...    delete:LNBTS-1/MOPR-1/MORED-1:emerCallPrio
...    LNBTS-1/MOPR-1/MORED-1:redirNrCarFrq:ssbSubcarrierSpacing=15kHz|carrierFreqNrCell=428910
@{add_moPrMapList}
...    LNBTS-1:actSelMobPrf=true
...    LNBTS-1/MODPR-0:autoAdapt=false
...    LNBTS-1:moProfileSelect=spid
...    LNCEL-1:moPrMappingList:spid=2|moPrId=1
...    LNCEL-1:moPrMappingList:spidLast=${EMPTY}|moPrId=1
...    LNCEL-1:moPrMappingList:mcc=262|moPrId=1
...    LNCEL-1:moPrMappingList:mnc=3|moPrId=1
...    LNCEL-1:moPrMappingList:mncLength=2|moPrId=1
@{FAF_CB007172}
...    LNCEL:actReturnTo5GSA=at end of non-emerg RRC connection
${ue_5GCapability1}    C59FF030030804081705C177E0D98808C0000480012001008A200424000AA0004008A480001000008240C000084003000000
${UE_CTX_REL_ENB_IRAT_RED}    M8013C104
@{Case01_Counters}    LNCEL-1:${UE_CTX_REL_ENB_IRAT_RED}=0
${time_gap}    2    # make sure time is enough for verify whether has rrc connection release

*** Test Cases ***
CB007172-SR-A-d_ET_01_01_Redirect_5G_without_emerg_QCI1_triggered_by_S1_Reset_or_E-RAB_release_failure_when_actReturnTo5GSA_equal_5
    [Tags]
    Attach UE With SA NR then Add One Normal QCI1 Bearer    ue_id=1
    Release the Normal QCI1 Bearer for UE then Check RRC Connection Release without redirect    ue_id=1
    Trigger S1 Reset for UE then Check RRC Connection Release with redirect    ue_id=1
    Attach UE With SA NR then Add One Normal QCI1 Bearer    ue_id=2
    Trigger S1 Reset for UE then Check RRC Connection Release with redirect    ue_id=2
    Attach UE With SA NR then Add One Normal QCI1 Bearer    ue_id=3
    Trigger ERAB Release Failure when Release QCI1 Bearer for UE3

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs    ue_count=10
    Create UE Alias    alias=UE_1    ue_id=1    id_type=cus
    Create UE Alias    alias=UE_2    ue_id=2    id_type=cus
    Create UE Alias    alias=UE_3    ue_id=3    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    Add Yaml    EPC/PGW
        ...    - id: 3
        ...    type: 'simulated'
        ...    apn: 'emergency.nsn.com'
        ...    emergency: 'on'
    Add Yaml    UEs/bearer_sets/bearer_set_2
    ...    - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...    - {qci: 1, default: off, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...    - {qci: 2, gbr_ul: 144, gbr_dl: 144, mbr_ul: 144, mbr_dl: 144, pdn: 1}
    ...    - {qci: 3, gbr_ul: 64, gbr_dl: 128, mbr_ul: 64, mbr_dl: 128, pdn: 1}
    ...    - {qci: 4, gbr_ul: 32, gbr_dl: 330, mbr_ul: 32, mbr_dl: 320, pdn: 1}
    ...    - {qci: 5, pdn: 1}
    ...    - {qci: 6, pdn: 1}
    ...    - {qci: 7, pdn: 1}
    ...    - {qci: 9, pdn: 1}
    ...    - {qci: 8, default: on, trf_type: external, pdn: 2}
    ...    - {qci: 1, default: off, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 2}
    ...    - {qci: 7, pdn: 2}
    ...    - {qci: 9, pdn: 2}
    ...    - {qci: 5, default: on, trf_type: external, priority: 1, pdn: 3}
    ...    - {qci: 1, default: off, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, priority: 1, pdn: 3}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/3    bearer: bearer_set_1

Attach UE With SA NR then Add One Normal QCI1 Bearer
    [Arguments]    ${ue_id}
    Run Keyword If    '${ue_id}' == '1'    Start RTPM Counter
    Attach UE With SA NR    ue_id=${ue_id}
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 1))
    ...    alias=UE_Add_QCI1   overall_timeout=30
    Execute Uex Command    bearer_add ue=${ue_id} qci=1 gbr_ul=31 gbr_dl=31 mbr_ul=31 mbr_dl=31
    Flow Occurred As Expected    alias=UE_Add_QCI1

Attach UE With SA NR
    [Arguments]    ${ue_id}
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionRequest (rrcConnectionRequest contains (establishmentCause eq "mo-Signalling"))
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupListCtxtSUReq contains (e-RAB-ID eq 5 and qCI eq 8))
    ...    MME_1:S1AP_UECapabilityInfoIndication
    ...    alias=UE_Attach   overall_timeout=30
    Execute Egate Command    ue_mme_param id=${ue_id} spid=not_assigned
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_5GCapability1} enb=1 cell=1
    Flow Occurred As Expected    alias=UE_Attach

Release the Normal QCI1 Bearer for UE then Check RRC Connection Release without redirect
    [Arguments]    ${ue_id}
    Expect Message Flow
    ...    MME_1:S1AP_E-RABReleaseCommand (E-RABList contains (e-RAB-ID eq 6))
    ...    MME_1:S1AP_E-RABReleaseResponse (E-RABReleaseListBearerRelComp contains (e-RAB-ID eq 6))
    ...    alias=UE_ReleaseQCI1    overall_timeout=30
    Execute Uex Command    bearer_del ue=${ue_id} qci=1
    Flow Occurred As Expected    alias=UE_ReleaseQCI1
    Sleep    ${time_gap}
    Run Keyword If    '${ue_id}' == '1'    Check RTPM Counters    ${Case01_Counters}

Trigger S1 Reset for UE then Check RRC Connection Release with redirect
    [Arguments]    ${ue_id}
    ${rrc_release}=    Catenate
    ...    RRC_RRCConnectionRelease (redirectedCarrierInfo contains (nr-r15 contains (
    ...    carrierFreq-r15 eq 427970 and subcarrierSpacingSSB-r15 eq "kHz15")))
    Expect Message Flow
    ...    UE_${ue_id}:${rrc_release}
    ...    alias=S1_Reset    overall_timeout=30
    Execute Egate Command    ue_s1_reset id=${ue_id} by=mme enb=1 mme=1
    Flow Occurred As Expected    alias=S1_Reset

Trigger ERAB Release Failure when Release QCI1 Bearer for UE3
    ${erab_release_response}=    Catenate
    ...    S1AP_E-RABReleaseResponse (E-RABList contains (e-RAB-ID eq 6 and cause contains (
    ...    radioNetwork eq "failure-in-radio-interface-procedure")))
    ${rrc_release}=    Catenate
    ...    RRC_RRCConnectionRelease (redirectedCarrierInfo contains (nr-r15 contains (
    ...    carrierFreq-r15 eq 427970 and subcarrierSpacingSSB-r15 eq "kHz15")))
    Expect Message Flow
    ...    MME_1:S1AP_E-RABReleaseCommand (E-RABList contains (e-RAB-ID eq 6 and cause contains (nas eq "normal-release")))
    ...    MME_1:${erab_release_response}
    ...    UE_3:${rrc_release}
    ...    alias=UE3_Release    overall_timeout=30
    Execute Uex Command    ue_rrc_reconf_param id=3 if_contains=drb-ToReleaseList action=drop
    Execute Egate Command    bearer_del ue=3 id=2
    Flow Occurred As Expected    alias=UE3_Release
