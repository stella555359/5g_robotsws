*** Setting ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...                 release-SBTS19A    team-CN3ET    owner-jun.15.zhang,lishuo.geng    owner-annie.nie
Resource          ../../../resources/DevHZ5_resource.robot

*** Variable ***
${Ue_g_Capabilities}    C59FF0200308040B82E0BBF06CC40440000252402066080120801200    # ${01_eRedirectr9_COM_supBdGeran_ALL_w_dtm_Ue_Capabilities}
@{PARAMS_IN_SCF}
...    @{deltaSCFC_setup}
...    @{Delete_Neighbour_Relation}
...    @{PARAMS_FOR_REDRT}
...    @{PARAMS_FOR_RIM}
...    @{PARAMS_FOR_QCI}
...    @{PARAMS_FOR_PMQAP}
...    @{RELATION_ERROR}
...    MRBTS-1/LNBTS-1/LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=false
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
@{RELATION_ERROR}
...    LNCEL-1:inactivityTimerPubSafety=2000
...    delete:LNCEL:defaultLnRelGnbCellId
@{deltaSCFC_setup}
...    LNBTS:actCSFBRedir=Enabled
...    LNBTS:actEmerCallRedir=Enabled
...    LNBTS:actRedirect=enabled
...    LNBTS:actHOtoWcdma=true
...    LNBTS:actCsfbPsHoToUtra=true
...    LNBTS:actSelMobPrf=false
...    LNBTS:actFlexQCIARPPMProfiles=true
...    LNBTS:actRIMforUTRAN=true
...    LNBTS:actERabModify=true
...    LNBTS:actEnhAcAndGbrServices=true
...    LNBTS:actLTES1Ho=true
...    LNBTS:actMultBearers=true
...    LNBTS:actMultGbrBearers=true
...    LNBTS:actNonGbrServiceDiff=true
...    LNBTS:actS1OlHandling=true
...    LNBTS:act8EpsBearers=true
...    LNBTS:actOperatorQCIGBR=true
...    LNBTS:actOperatorQCI=true
...    LNBTS:actS1Flex=enabled
...    LNBTS:actCiphering=true
...    LNBTS:actIfHo=enabled
...    LNBTS:prioTopoHO=all equal
...    LNBTS:geranDtmCap=true
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNBTS:actQCIPLMNIDProfiles=false
...    LNBTS/LNBTS_FDD-0:actIMSEmerSessR9=true
...    LNBTS:tS1RelPrepU=5000
...    LNBTS/GTPU-1:gtpuPathSupint=20
...    LNBTS/GTPU-1:gtpuN3Reqs=1
...    LNCEL-1:furtherPlmnIdL:mcc=555
...    LNCEL-1:furtherPlmnIdL:mnc=10
...    LNCEL-1:furtherPlmnIdL:mncLength=2
...    LNBTS:tS1RelOvDeltU=1000
...    LNBTS:tS1RelOvDeltG=1000
...    LNBTS/LNADJW-0:uTargetScFdd=110
...    LNBTS/LNADJW-0:uTargetCid=1
...    LNBTS/LNADJW-0:uTargetFreq=10592
...    LNBTS/LNADJW-0:uTargetLac=1
...    LNBTS/LNADJW-0:uTargetRncId=1
...    LNBTS/LNBTS_FDD-0:preventPsHOtoWcdma=None
...    LNBTS/LNADJW-0:uTargetRac=1
...    LNBTS/LNADJW-0:srvccHoInd=PSandCS
...    LNBTS/LNADJW-0:primaryPlmnId:mcc=262
...    LNBTS/LNADJW-0:primaryPlmnId:mnc=3
...    LNBTS/LNADJW-0:primaryPlmnId:mncLength=2
...    LNCEL-1:furtherPlmnIdL:autoRemovalAllowed=false
...    LNCEL-1:furtherPlmnIdL:cellReserve=Not Reserved
...    LNCEL-1:actDrx=true
...    LNCEL-1:actDrxDuringMeasGap=true
...    LNCEL-1:t304InterRAT=500ms
...    LNCEL-1:t304InterRATGsm=500ms
...    LNCEL-1:actNbrForNonGbrBearers=false
...    LNCEL-1:inactivityTimer=2000
...    LNCEL-1/LNHOW-0:utraCarrierFreq=10592
...    LNCEL-1/SIB-0:t301=2000ms
...    LNCEL-1/SIB-0:t311=30000ms
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrcEmergency=380
...    LNCEL-1/LNRELW-0:csfbPsHoAllowed=allowed
...    LNCEL-1/LNRELW-0:utranLbAllowed=false
...    LNCEL-1/LNRELW-0:nrControl=automatic
...    LNCEL-1/LNRELW-0:psHoAllowed=allowed
...    LNCEL-1/LNRELW-0:redirWithSysInfoAllowed=allowed
...    LNCEL-1/LNRELW-0:removeAllowed=true
...    LNCEL-1/LNRELW-0:srvccAllowed=allowed
...    LNCEL-1/LNRELW-0:uTargetCid=1
...    LNCEL-1/LNRELW-0:uTargetRncId=1
...    LNCEL-1/LNRELW-0:plmnId:mcc=262
...    LNCEL-1/LNRELW-0:plmnId:mnc=3
...    LNCEL-1/LNRELW-0:plmnId:mncLength=2
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrcEmergency=380
...    LNCEL-3/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrcEmergency=380
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB4
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB5
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB6
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB7
@{PARAMS_FOR_REDRT}
...    LNCEL-1/REDRT-1:redirGeranBandIndicator=gsm1800
...    LNCEL-1/REDRT-1:redirRat=geran
...    LNCEL-1/REDRT-1:addGsmSIToRedirMsg=both
...    LNCEL-1/REDRT-1:addUtranSIToRedirMsg=both
...    LNCEL-1/REDRT-1:csFallBPrio=3
...    LNCEL-1/REDRT-1:emerCallPrio=1
...    LNCEL-1/REDRT-1:redirectPrio=2
...    LNCEL-1/REDRT-1:redirGeranArfcnStructL:redirGeranArfcnPrio=2|redirGeranArfcnValue=688
...    LNCEL-1/REDRT-1:redirGeranArfcnStructL:redirGeranArfcnPrio=1|redirGeranArfcnValue=680
@{PARAMS_FOR_RIM}
...    RIM-0:nRimRirU=1
...    RIM-0:nRimRirG=3
...    RIM-0:tRimPollG=150
...    RIM-0:tRimPollU=14400
...    RIM-0:tRimKaG=150
...    RIM-0:tRimKaU=14400
...    RIM-0:tRimRirG=5
...    RIM-0:tRimRirU=15
...    RIM-0:goodRadioCondForCsfbThres=-100
@{Delete_Neighbour_Relation}
...    delete:LNADJ.*
...    delete:LNREL.*
...    delete:LNHO.*
...    delete:LNCEL-1:moPrMappingList
@{PARAMS_FOR_QCI}
...    LNBTS-1:actFlexQCIARPPMProfiles=true
...    LNBTS-1:actQCIPLMNIDProfiles=false
...    LNBTS:actOperatorQCI=true
...    LNBTS-1:qciTab1:lcgid=1
...    LNBTS-1:qciTab2:lcgid=2
...    LNBTS-1:qciTab3:lcgid=2
...    LNBTS-1:qciTab4:lcgid=2
...    LNBTS-1:qciTab5:lcgid=2
...    LNBTS-1:qciTab6:lcgid=3
...    LNBTS-1:qciTab7:lcgid=3
...    LNBTS-1:qciTab8:lcgid=3
...    LNBTS-1:qciTab9:lcgid=3
...    LNBTS:qciTabOperator:qci=129|counterGroup=2
...    LNBTS:qciTabOperator:resType=nonGBR|counterGroup=2
...    LNBTS:qciTabOperator:qci=130|counterGroup=3
...    LNBTS:qciTabOperator:resType=nonGBR|counterGroup=3
...    LNBTS:qciTabOperator:qci=132|counterGroup=5
...    LNBTS:qciTabOperator:resType=nonGBR|counterGroup=5
...    LNBTS:qciTabOperator:qci=133|counterGroup=6
...    LNBTS:qciTabOperator:resType=nonGBR|counterGroup=6
@{PARAMS_FOR_PMQAP}
...    LNBTS-1/PMRNL-1/PMQAP-1:cfgQCIRange=1-4
...    LNBTS-1/PMRNL-1/PMQAP-1:cfgPRI=20
...    MNL-1/MNLENT-1/PMCADM-1:reportingIntervalPm=15min
...    LNBTS-1/PMRNL-1:mtERABPMQAPProfile=15min
...    LNBTS-1/PMRNL-1:mtDataVolThrPMQAPProfile=15min
...    LNBTS-1/PMRNL-1:mtActUsersLatencyPMQAPProfile=15min
...    LNBTS-1/PMRNL-1:mtRLFPMQAPProfile=15min
...    delete:LNBTS-1/PMRNL-1/PMQAP-1:cfgARPRange
...    delete:LNBTS-1/PMRNL-1/PMQAP-1:cfgUECategory
...    delete:LNBTS-1/PMRNL-1/PMQAP-1:pLMNID
...    LNBTS-1/PMRNL-1/PMQAP-2:cfgQCIRange=5-9
...    LNBTS-1/PMRNL-1/PMQAP-2:cfgPRI=20
...    LNBTS-1/PMRNL-1/PMQAP-2:cfgARPRange=${empty}
...    LNBTS-1/PMRNL-1/PMQAP-2:cfgUECategory=${empty}
...    LNBTS-1/PMRNL-1/PMQAP-2:pLMNID=${empty}
${CSFB_PSHO_UTRAN_SUCC}    M8016C68
${CSFB_REDIR_CR_ATT_GERAN}    M8016C69
${ERAB_REL_ENB_RNL_FRIP}    M8006C346
${ERAB_REL_ENB_RNL_FRIP_QCI1}    M8006C348
${ERAB_REL_ENB_RNL_FRIP_QCI2}    M8006C349
@{pm_counters_Cbem}
...    LNCEL-1:LTE_Inter_Sys_HO:${CSFB_REDIR_CR_ATT_GERAN}=0
@{pm_counters_Cb}
...    LNCEL-1:LTE_Inter_Sys_HO:${CSFB_REDIR_CR_ATT_GERAN}=1
@{pm_counters_Cc}
...    LNCEL-1:LTE_EPS_Bearer:${ERAB_REL_ENB_RNL_FRIP}=6
...    LNCEL-1:LTE_EPS_Bearer:${ERAB_REL_ENB_RNL_FRIP_QCI1}=1
...    LNCEL-1:LTE_EPS_Bearer:${ERAB_REL_ENB_RNL_FRIP_QCI2}=1
${PM_COUNTER_INTERVAL}    1min
${V_1}
...    SEPARATOR=
...    c9b80488001040a208922864448ff85e47fc2f23fe1791ff0bc8ff85e47fc2f23fe1791ff0bc8ff85dfc3f728a0040334400e0b00000000017
...    104008000010800022000045000090000144000290000540000b2001123fe1791ff0bc8ff85e47fc2f23fe1791ff0bc8ff85e47fc2f23fe172
...    82000000

${V_2}
...    SEPARATOR=
...    0026407d000001007a0076007470548e0262f23000210062f2300000001054890062f23000c80200c858d64b81014c84000000004f81144ec8
...    62f23000c80200c8061b0102030405060708090a0b0c0d0e0f1011121314000102030405060708090a0b0c0d0e0f1011121314190102030405
...    060708090a0b0c0d0e0f1011121314
${csfb_to_geran}
...    releaseCause eq 'other' and redirectedCarrierInfo contains (geran contains (
...    startingARFCN eq 680 and bandIndicator eq 'dcs1800' and explicitListOfARFCNs contains (688)))

*** Test Case ***
LTE3717-C_b_01-Counter Updated After CS Fallback attempts to GERAN with redirection via the RRC Connection Release
    [Tags]    owner-jun.15.zhang
    Counter Not Update For active UE MO emergency CS Fallback to GERAN
    Counter Update For idle UE MT CSFB to GERAN

LTE3717-C_c_01-ERAB release Counters Updated After Received Specified Reason
    [Tags]    owner-lishuo.geng
    Start Rtpm Counter
    Attach UE to CELL1
    Add Multi Bearers For UE1
    Trigger Send Invalid Tid When Add Bearer
    Check Rtpm Counters    ${pm_counters_Cc}

*** Keyword ***
Start RIM Function in WTS
    execute egate command    send_hex source=mme:1 target=enb:1 hex=${V_1}
    execute egate command    send_hex source=mme:1 target=enb:1 hex=${V_2}

Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_5    ue_id=5    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    execute egate command    trace_sim on mme=1 protocol=s1
    Start RIM Function in WTS

Modify Yaml
    ${rnc1_enb4_CELL1}    catenate    - {id: 41, technology: utran, rnc: 1, uarfcn: '10592:9642',  type: FDD,
    ...      shared_plmn_utran: '262:03', cell_identity_utran: 1, rac: 1, pci: '36:2'}
    ${rnc1_enb4_CELL1_LTE}    catenate    - {id: 1, technology: 'lte', tac: 33, pci: '4:1', earfcn: '1400:19400', eci: '0x0000401'}
    Add Yaml    UEs/bearer_sets
    ...      bearer_set_2:
    ...       - {qci: 6, default: on, pdn: 1, trf_type: external}
    ...       - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...       - {qci: 2, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...       - {qci: 5, pdn: 1}
    ...       - {qci: 8, pdn: 1}
    ...       - {qci: 130, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, priority: 3, delay: 100, pdn: 1}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/3    bearer: bearer_set_2
    Add Yaml      EPC/RNC
    ...      - id: 1
    ...      host_enb: 4
    ...      rnc_id: 1
    ...      lac: 1
    ...      plmn: '262:03'
    Add Yaml    BASE_STATIONS
    ...      - id: 4
    ...      type: 'simulated'
    ...      plmn: '262:03'
    ...      s1: '10.0.1.31'
    ...      enb_id: '0x00004'
    ...      x2_peers: none
    ...      cells:
    ...        ${rnc1_enb4_CELL1}
    ...        ${rnc1_enb4_CELL1_LTE}
    Update Yaml    EPC/MME_POOL_AREA/1    tac_list: 33,1,2,3

Counter Not Update For active UE MO emergency CS Fallback to GERAN
    Start Rtpm Counter    1st
    G UE Attach With Default Bearer QCI_6    ue_id=2
    Steup Dedicated Bearer QCI_1_5    ue_id=2
    Triger CSFB With Emergency    ue_id=2
    Check Rtpm Counters    ${pm_counters_Cbem}    tag=1st

Counter Update For idle UE MT CSFB to GERAN
    Start Rtpm Counter    2th
    G UE Attach With Default Bearer QCI_6    ue_id=5
    Trriger MME S1 Release With Normal    ue_id_for_release=5
    Trriger CSFB    ue_id=5    cause=mt-Access    ran=geran
    Check Rtpm Counters    ${pm_counters_Cb}    tag=2th

Attach UE to CELL1
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    alias=ue1_attach    overall_timeout=20
    execute uex command    ue_attach id=1 cell=1
    flow occurred as expected    alias=ue1_attach

G UE Attach With Default Bearer QCI_6
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    alias=ue${ue_id}_attach    overall_timeout=20
    execute uex command    ue_attach id=${ue_id} ue_eutra_capabilities=${Ue_g_Capabilities} cell=1
    flow occurred as expected    alias=ue${ue_id}_attach

Steup Dedicated Bearer QCI_1_5
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    MME_1:S1AP_E-RABSetupRequest (e-RAB-ID eq 6 and qCI eq 1)
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    MME_1:S1AP_E-RABSetupRequest (e-RAB-ID eq 7 and qCI eq 5)
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    alias=ue${ue_id}_add_bearer    overall_timeout=20
    execute uex command    bearer_add ue=${ue_id} qci=1 mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    execute uex command    bearer_add ue=${ue_id} qci=5
    flow occurred as expected    alias=ue${ue_id}_add_bearer

Trriger MME S1 Release With Normal
    [Arguments]    ${ue_id_for_release}    ${cause_nas}=normal_release
    expect message flow
    ...    UE_${ue_id_for_release}:RRC_RRCConnectionRelease (releaseCause eq "other")
    ...    MME_1:S1AP_UEContextReleaseCommand (Cause contains ("normal-release"))
    ...    MME_1:S1AP_UEContextReleaseComplete
    ...    alias=s1_release    overall_timeout=20
    execute egate command    ue_s1_ctx_release id=${ue_id_for_release} cause_nas=${cause_nas}
    flow occurred as expected    alias=s1_release

Trriger CSFB
    [Arguments]    ${ue_id}    ${cause}    ${ran}
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionRelease (${csfb_to_geran})
    ...    MME_1:S1AP_UEContextReleaseRequest (radioNetwork eq "cs-fallback-triggered")
    ...    MME_1:S1AP_UEContextReleaseComplete
    ...    alias=csfb_normal    overall_timeout=20
    execute uex command    ue_csfb id=${ue_id} cause=${cause} ran=${ran}
    flow occurred as expected    alias=csfb_normal

Triger CSFB With Emergency
    [Arguments]    ${ue_id}
    expect message flow
    ...    MME_1:S1AP_UEContextModificationRequest (CSFallbackIndicator eq "cs-fallback-high-priority")
    ...    MME_1:S1AP_UEContextModificationResponse
    ...    UE_${ue_id}:RRC_RRCConnectionRelease (${csfb_to_geran})
    ...    MME_1:S1AP_UEContextReleaseRequest (radioNetwork eq "cs-fallback-triggered")
    ...    MME_1:S1AP_UEContextReleaseComplete
    ...    alias=csfb_emergency    overall_timeout=20
    execute uex command    ue_csfb id=${ue_id} cause=mo-Signalling ran=geran emergency=true
    execute uex command    ue_param id=${ue_id} reset
    flow occurred as expected    alias=csfb_emergency

Trigger Send Invalid Tid When Add Bearer
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    expect message flow
    ...    MME_1:S1AP_E-RABSetupRequest (e-RAB-ID eq 10 and qCI eq 8)
    ...    MME_1:S1AP_E-RABSetupResponse (radioNetwork eq 'failure-in-radio-interface-procedure')
    ...    MME_1:S1AP_UEContextReleaseRequest (radioNetwork eq 'failure-in-radio-interface-procedure')
    ...    MME_1:S1AP_UEContextReleaseComplete
    ...    alias=invalid_tid_bearer    overall_timeout=20
    execute uex command    ue_rrc_reconf_param id=1 if_contains=drb-ToAddModList action=invalid_tid
    execute uex command    bearer_add ue=1 qci=8
    flow occurred as expected    alias=invalid_tid_bearer


Add Multi Bearers For UE1
    expect message flow
    ...    MME_1:S1AP_E-RABSetupRequest (e-RAB-ID eq 6 and qCI eq 1)
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    MME_1:S1AP_E-RABSetupRequest (e-RAB-ID eq 7 and qCI eq 2)
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    MME_1:S1AP_E-RABSetupRequest (e-RAB-ID eq 8 and qCI eq 5)
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    MME_1:S1AP_E-RABSetupRequest (e-RAB-ID eq 9 and qCI eq 130)
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    alias=multi_bearers    overall_timeout=20
    execute uex command    bearer_add ue=1 qci=1 mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    execute uex command    bearer_add ue=1 qci=2 mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    execute uex command    bearer_add ue=1 qci=5
    execute uex command    bearer_add ue=1 qci=130 mbr_ul=31 mbr_dl=31 gbr_ul=30 gbr_dl=30
    flow occurred as expected    alias=multi_bearers
