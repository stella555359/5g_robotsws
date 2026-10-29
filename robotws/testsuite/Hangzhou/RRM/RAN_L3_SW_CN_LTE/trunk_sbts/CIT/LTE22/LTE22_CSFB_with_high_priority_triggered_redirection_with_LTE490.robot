*** Setting ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CIT    CLOUD_R4xAPO_CUS    release-TL16
...               team-SG4    owner-zhiguo.li
Resource          ../../../resources/DevHZ5_resource.robot

*** Variable ***
@{PARAMS_IN_SCF}
...  LNBTS-1:actSelMobPrf=true
...  LNBTS-1:actRedirect=enabled
...  LNBTS-1:actCSFBRedir=Enabled
...  LNBTS-1:actEmerCallRedir=Enabled
...  LNBTS-1:actGsmRedirWithSI=true
...  LNBTS-1:moProfileSelect=spid
...  LNCEL-1:moPrMappingList:moPrId=1
...  LNCEL-1:moPrMappingList:mcc=262
...  LNCEL-1:moPrMappingList:mnc=3
...  LNCEL-1:moPrMappingList:mncLength=2
...  LNCEL-1:moPrMappingList:spid=1
...  LNCEL-1:moPrMappingList:spidLast=15
...  LNCEL-1/REDRT-0:redirRat=utraFDD
...  LNCEL-1/REDRT-0:redirFreqUtra=10638
...  LNCEL-1/REDRT-0:redirectPrio=2
...  LNCEL-1/REDRT-0:csFallBPrio=1
...  LNCEL-1/REDRT-0:emerCallPrio=3
...  LNCEL-1/REDRT-1:redirRat=geran
...  LNCEL-1/REDRT-1:addGsmSIToRedirMsg=csfb
...  LNCEL-1/REDRT-1:redirGeranBandIndicator=gsm1800
...  LNCEL-1/REDRT-1:csFallBPrio=2
...  LNCEL-1/REDRT-1:emerCallPrio=1
...  LNCEL-1/REDRT-1:redirectPrio=3
...  LNCEL-1/REDRT-1:redirGeranArfcnStructL:redirGeranArfcnValue=512
...  LNCEL-1/REDRT-1:redirGeranArfcnStructL:redirGeranArfcnPrio=1
...  MOPR-1/MORED-0:redirRAT=utraFDD
...  MOPR-1/MORED-0:redirFreqUtra=10613
...  MOPR-1/MORED-0:csFallBPrio=2
...  MOPR-1/MORED-0:emerCallPrio=1
...  MOPR-1/MORED-0:redirectPrio=3
...  MOPR-1/MORED-1:redirRAT=geran
...  MOPR-1/MORED-1:redirGeranBandIndicator=gsm1900
...  MOPR-1/MORED-1:csFallBPrio=3
...  MOPR-1/MORED-1:emerCallPrio=2
...  MOPR-1/MORED-1:redirectPrio=1
...  MOPR-1/MORED-1:redirGeranArfcnStructL:redirGeranArfcnValue=810
...  MOPR-1/MORED-1:redirGeranArfcnStructL:redirGeranArfcnPrio=1
...  MODPR-0/MODRED-0:redirRAT=utraFDD
...  MODPR-0/MODRED-0:redirFreqUtra=10638
...  MODPR-0/MODRED-0:csFallBPrio=3
...  MODPR-0/MODRED-0:emerCallPrio=1
...  MODPR-0/MODRED-0:redirectPrio=1
...  MODPR-0/MODRED-1:redirRAT=geran
...  MODPR-0/MODRED-1:redirGeranBandIndicator=gsm1800
...  MODPR-0/MODRED-1:csFallBPrio=1
...  MODPR-0/MODRED-1:emerCallPrio=3
...  MODPR-0/MODRED-1:redirectPrio=2
...  MODPR-0/MODRED-1:redirGeranArfcnStructL:redirGeranArfcnValue=612
...  MODPR-0/MODRED-1:redirGeranArfcnStructL:redirGeranArfcnPrio=1
...  MODPR-0:autoAdapt=false
...  delete:MODPR-0/MODRED-0:redirGeranArfcnStructL
${eutra_capabilities}    C59FF42032E80002BC1A3101902004408020A5407000
${utra_capabilities}    123456
${CELL_EARFCN}    38000
${EMERGENCY_S1_FLOW}    SEPARATOR=${SPACE}
...    e-RABlevelQoSParameters contains (qCI eq 1 and priorityLevel eq 'highest' and
...    pre-emptionCapability eq 'may-trigger-pre-emption' and pre-emptionVulnerability eq 'not-pre-emptable')
${CSFB_UTRA_TECH}    utra-FDD
${CSFB_UTRA_ARFCN}    10638

*** Test Case ***
LTE22_CSFB_with_high_priority_triggered_redirection_with_LTE490
    [Tags]
    Set Ue Capabilities Before Attach
    UE Attach With Emergency Call
    UE CSFB to UTRAN
    Detach UE

*** Keyword ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=30    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=10.0.1.2    id_type=real
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,s1,x2 on
    Execute Egate Command    proxy_log GEN=debug

Modify Yaml
    Add Yaml      EPC/PGW
    ...    - id: 3
    ...    type: 'simulated'
    ...    apn: 'emergency.nsn.com'
    ...    emergency: 'on'
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 8, default: on, pdn: 2}
    ...     - {qci: 1, mbr_ul: 31, gbr_dl: 31, gbr_ul: 31, mbr_dl: 31, pdn: 2}
    ...     - {qci: 5, default: on, pdn: 3}
    ...     - {qci: 1, mbr_ul: 31, gbr_dl: 31, gbr_ul: 31, mbr_dl: 31, preprovisioned: on, filter: 1, precedence: 1, priority: 1, pdn: 3}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2

Set Ue Capabilities Before Attach
    [Arguments]    ${ueid}=1    ${ue_eutra_capabilities}=${eutra_capabilities}    ${ue_utra_capabilities}=${utra_capabilities}    ${spid}=20
    Execute Uex Command    ue_param id=${ueid} ue_eutra_capabilities=${ue_eutra_capabilities} ue_utra_capabilities=${ue_utra_capabilities}
    Execute Egate Command    ue_mme_param id=${ueid} spid=${spid}

UE Attach With Emergency Call
    [Arguments]    ${ueid}=1    ${cellid}=1    ${cell_freq}=${CELL_EARFCN}    ${emer_msg}=${EMERGENCY_S1_FLOW}
    Expect Message Flow
    ...    MME_1:S1AP_InitialUEMessage (RRC-Establishment-Cause eq 'emergency')
    ...    MME_1:S1AP_InitialContextSetupRequest (${emer_msg})
    ...    UE_GROUP_${ueid}:RRC_RRCConnectionReconfiguration (measObjectToAddModList contains (carrierFreq eq ${cell_freq}))
    ...    alias=emer_flow    overall_timeout=15
    Execute Uex Command    ue_attach id=${ueid} cell=${cellid} emergency=on establishment_cause=emergency
    Flow Occurred As Expected    alias=emer_flow

UE CSFB to UTRAN
    [Arguments]    ${ueid}=1    ${red_rat}=${CSFB_UTRA_TECH}    ${red_arfcn}=${CSFB_UTRA_ARFCN}
    Expect Message Flow
    ...    MME_1:S1AP_UEContextModificationRequest (CSFallbackIndicator eq 'cs-fallback-high-priority')
    ...    UE_GROUP_${ueid}:RRC_RRCConnectionRelease (redirectedCarrierInfo contains (${red_rat} eq ${red_arfcn}))
    ...    alias=csfb_flow    overall_timeout=20
    Execute Uex Command    ue_csfb id=${ueid} ran=utra emergency=true cause=mt_Access
    Flow Occurred As Expected    alias=csfb_flow

Detach UE
    [Arguments]    ${ueid}=1
    Expect Message Flow    UE_GROUP_${ueid}:RRC_RRCConnectionRelease    alias=release_flow    overall_timeout=5
    Execute Uex Command    ue_detach id=${ueid}
    Flow Occurred As Expected    alias=release_flow
