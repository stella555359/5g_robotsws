*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS    team-DevHZ5_SG9
...               owner-qiuqi.liu, susana.yan    release-SBTS20B
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=2
...    LNBTS/LNADJ-1/LNADJL-1:phyCellId=31
...    LNCEL-1/LNREL-1:removeAllowed=false
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1450
...    LNBTS:imsEmerPlmnConfig:emerSessLimServ=false|emerSessArpPrioLev=1
...    LNBTS/LNBTS_FDD-0:actIMSEmerSessR9=true
...    @{add_MODRED}
...    @{add_MORED}
...    @{add_moPrMapList_combined}
...    @{add_REDRT}
@{PARAMS_IN_SWCONFIG}
...    0xa0157 = 1
...    0xa01bd = 1
...    0xa01bc = 1
...    0xA0168 = 0xC
...    0xA016B = 0x48017
@{add_REDRT}
...    LNCEL-1/REDRT-0:redirRat=nr
...    LNCEL-1/REDRT-0:redirectPrio=8
...    delete:LNCEL-1/REDRT-0:csFallBPrio
...    delete:LNCEL-1/REDRT-0:emerCallPrio
...    LNCEL-1/REDRT-0:redirNrCarFrq:carrierFreqNrCell=285440|ssbSubcarrierSpacing=15kHz
...    LNCEL-1/REDRT-1:redirRat=nr
...    LNCEL-1/REDRT-1:redirectPrio=7
...    delete:LNCEL-1/REDRT-1:csFallBPrio
...    delete:LNCEL-1/REDRT-1:emerCallPrio
...    LNCEL-1/REDRT-1:redirNrCarFrq:carrierFreqNrCell=285480|ssbSubcarrierSpacing=30kHz
...    LNCEL-1/REDRT-2:redirRat=nr
...    LNCEL-1/REDRT-2:redirectPrio=6
...    delete:LNCEL-1/REDRT-2:csFallBPrio
...    delete:LNCEL-1/REDRT-2:emerCallPrio
...    LNCEL-1/REDRT-2:redirNrCarFrq:carrierFreqNrCell=10000|ssbSubcarrierSpacing=15kHz
...    LNCEL-1/REDRT-3:redirRat=nr
...    LNCEL-1/REDRT-3:redirectPrio=5
...    delete:LNCEL-1/REDRT-3:csFallBPrio
...    delete:LNCEL-1/REDRT-3:emerCallPrio
...    LNCEL-1/REDRT-3:redirNrCarFrq:carrierFreqNrCell=10000|ssbSubcarrierSpacing=30kHz
...    LNCEL-1/REDRT-4:redirRat=nr
...    LNCEL-1/REDRT-4:redirectPrio=4
...    delete:LNCEL-1/REDRT-4:csFallBPrio
...    delete:LNCEL-1/REDRT-4:emerCallPrio
...    LNCEL-1/REDRT-4:redirNrCarFrq:carrierFreqNrCell=10000|ssbSubcarrierSpacing=30kHz
...    LNCEL-1/REDRT-5:redirRat=nr
...    LNCEL-1/REDRT-5:redirectPrio=3
...    delete:LNCEL-1/REDRT-5:csFallBPrio
...    delete:LNCEL-1/REDRT-5:emerCallPrio
...    LNCEL-1/REDRT-5:redirNrCarFrq:carrierFreqNrCell=10000|ssbSubcarrierSpacing=30kHz
...    LNCEL-1/REDRT-6:redirRat=nr
...    LNCEL-1/REDRT-6:redirectPrio=2
...    delete:LNCEL-1/REDRT-6:csFallBPrio
...    delete:LNCEL-1/REDRT-6:emerCallPrio
...    LNCEL-1/REDRT-6:redirNrCarFrq:carrierFreqNrCell=10000|ssbSubcarrierSpacing=30kHz
...    LNCEL-1/REDRT-7:redirRat=nr
...    LNCEL-1/REDRT-7:redirectPrio=1
...    delete:LNCEL-1/REDRT-7:csFallBPrio
...    delete:LNCEL-1/REDRT-7:emerCallPrio
...    LNCEL-1/REDRT-7:redirNrCarFrq:carrierFreqNrCell=10000|ssbSubcarrierSpacing=30kHz
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
...    LNBTS/MODPR-0/MODRED-0:redirRAT=nr
...    LNBTS/MODPR-0/MODRED-0:redirectPrio=4
...    delete:LNBTS/MODPR-0/MODRED-0:csFallBPrio
...    delete:LNBTS/MODPR-0/MODRED-0:emerCallPrio
...    LNBTS/MODPR-0/MODRED-0:redirNrCarFrq:ssbSubcarrierSpacing=30kHz|carrierFreqNrCell=1000
...    LNBTS/MODPR-0/MODRED-1:redirRAT=nr
...    LNBTS/MODPR-0/MODRED-1:redirectPrio=2
...    delete:LNBTS/MODPR-0/MODRED-1:csFallBPrio
...    delete:LNBTS/MODPR-0/MODRED-1:emerCallPrio
...    LNBTS/MODPR-0/MODRED-1:redirNrCarFrq:ssbSubcarrierSpacing=30kHz|carrierFreqNrCell=1000
@{add_MORED}
...    LNBTS/MOPR-1/MORED-0:redirRAT=nr
...    LNBTS/MOPR-1/MORED-0:redirectPrio=4
...    delete:LNBTS/MOPR-1/MORED-0:csFallBPrio
...    delete:LNBTS/MOPR-1/MORED-0:emerCallPrio
...    LNBTS/MOPR-1/MORED-0:redirNrCarFrq:ssbSubcarrierSpacing=30kHz|carrierFreqNrCell=1000
...    LNBTS/MOPR-1/MORED-1:redirRAT=nr
...    LNBTS/MOPR-1/MORED-1:redirectPrio=3
...    delete:LNBTS/MOPR-1/MORED-1:csFallBPrio
...    delete:LNBTS/MOPR-1/MORED-1:emerCallPrio
...    LNBTS/MOPR-1/MORED-1:redirNrCarFrq:ssbSubcarrierSpacing=30kHz|carrierFreqNrCell=1000
...    LNBTS/MOPR-2:targetSelMethod=SIB_based
...    LNBTS/MOPR-2:idleLBPercentageOfUes=0
...    LNBTS/MOPR-2:idleLBPercUeTM9=50
...    LNBTS/MOPR-2:idleLBPercCaUe=50
...    LNBTS/MOPR-2:caBlockingAllowed=forbidden
...    LNBTS/MOPR-2/MORED-0:redirRAT=nr
...    LNBTS/MOPR-2/MORED-0:redirectPrio=4
...    delete:LNBTS/MOPR-2/MORED-0:csFallBPrio
...    delete:LNBTS/MOPR-2/MORED-0:emerCallPrio
...    LNBTS/MOPR-2/MORED-0:redirNrCarFrq:ssbSubcarrierSpacing=30kHz|carrierFreqNrCell=1000
...    LNBTS/MOPR-2/MORED-1:redirRAT=nr
...    LNBTS/MOPR-2/MORED-1:redirectPrio=3
...    delete:LNBTS/MOPR-2/MORED-1:csFallBPrio
...    delete:LNBTS/MOPR-2/MORED-1:emerCallPrio
...    LNBTS/MOPR-2/MORED-1:redirNrCarFrq:ssbSubcarrierSpacing=30kHz|carrierFreqNrCell=1000
@{add_moPrMapList_combined}
...    LNBTS:moProfileSelect=combined
...    LNCEL-1:moPrMappingList:spidLast=199|moPrId=1
...    LNCEL-1:moPrMappingList:mcc=666|moPrId=2
...    LNCEL-1:moPrMappingList:mnc=6|moPrId=2
...    LNCEL-1:moPrMappingList:mncLength=2|moPrId=2
...    LNCEL-1:moPrMappingList:spid=201|moPrId=2
...    LNCEL-1:moPrMappingList:spidLast=256|moPrId=2
@{set_actIdleLB_to_true}
...    LNBTS:actIdleLB=true
...    LNCEL-2:idleLBCapThresh=100
...    LNCEL-3:idleLBCapThresh=100
...    LNCEL-2:loadSettings:cellCapClass=100
...    LNCEL-2:loadSettings:mlbEicicOperMode=allUes
...    LNCEL-2:loadSettings:nomNumPrbNonGbr=0.01
...    LNCEL-2:loadSettings:targetLoadGbrDl=50
...    LNCEL-2:loadSettings:targetLoadNonGbrDl=75
...    LNCEL-2:loadSettings:targetLoadPdcch=90
...    LNCEL-2:loadSettings:ulCacIgnore=false
...    LNCEL-2:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL-2:loadSettings:ulStaticCac=100
...    LNCEL-3:loadSettings:cellCapClass=100
...    LNCEL-3:loadSettings:mlbEicicOperMode=allUes
...    LNCEL-3:loadSettings:nomNumPrbNonGbr=0.01
...    LNCEL-3:loadSettings:targetLoadGbrDl=50
...    LNCEL-3:loadSettings:targetLoadNonGbrDl=75
...    LNCEL-3:loadSettings:targetLoadPdcch=90
...    LNCEL-3:loadSettings:ulCacIgnore=false
...    LNCEL-3:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL-3:loadSettings:ulStaticCac=100
@{set_actIdleLB_to_false}
...    LNBTS:actIdleLB=false
...    delete:LNCEL-1/REDRT-8
...    delete:LNCEL-1/REDRT-9
@{Config_Mobility_Profile_01}
...    @{set_actIdleLB_to_true}
...    LNCEL:actReturnTo5GSA=at end of voice calls
...    LNBTS:actSelMobPrf=true
...    LNBTS/MODPR-0:autoAdapt=true
...    LNBTS:moProfileSelect=spid
...    LNCEL-1/REDRT-8:redirRat=nr
...    LNCEL-1/REDRT-8:redirectPrio=8
...    delete:LNCEL-1/REDRT-8:csFallBPrio
...    delete:LNCEL-1/REDRT-8:emerCallPrio
...    LNCEL-1/REDRT-8:redirNrCarFrq:carrierFreqNrCell=10000|ssbSubcarrierSpacing=30kHz
...    LNCEL-1/REDRT-9:redirRat=nr
...    LNCEL-1/REDRT-9:redirectPrio=1
...    delete:LNCEL-1/REDRT-9:csFallBPrio
...    delete:LNCEL-1/REDRT-9:emerCallPrio
...    LNCEL-1/REDRT-9:redirNrCarFrq:carrierFreqNrCell=422100|ssbSubcarrierSpacing=15kHz
# ue_5GCapability1 with NR band1 and band 13 supported
${ue_5Gcapability}    C59FF030030804081705C177E0D98808C0000480012001008A200424000AA0004008A480001000008240C0000840030080C40400
${UE_CTX_REL_ENB_IRAT_RED}    M8013C104
@{Case01_Counters}
...    LNCEL-1:${UE_CTX_REL_ENB_IRAT_RED}=1

*** Test Cases ***
LTE4896-A-b_ET_01_01 RRC Releases to Redirect to 5G When UE Releases Last QCI1 Bearer Emergency and selects REDRT mobility profile
    [Documentation]    Purpose: This test case is designed If actReturnTo5GSA is set to 'at end of voice calls' the last released QCI1 bearer is for
    ...    emergency call.ENB should send RRCConnectionRelease message to the UE. The message contains RedirectedCarrierInfo equals to NR-r15, 
    ...    and nrCarFrqL REDRT mobility profile. The counter M8013C104 should be correct.
    ...    Preconditions: moProfileSelect=spid. MODPR-0:autoAdapt=true. Set ten REDRT moility profiles.UE can map REDRT moility profile.
    ...    Step1: UE Attach with SA NR
    ...    Step2: Create one emergency QCI1 bearer and one normal QCI1 bearer
    ...    Step3: release normal QCI1 bearer
    ...    Step4: Check RRC release message
    ...    Step5: release emergency QCI1 bearer
    ...    Step6: Check RRC release message
    ...    Step7: Start Rtpm counter and verify UE category counters
    [Tags]
    Config Mobility Profiles    ${Config_Mobility_Profile_01}
    UE Attach to ENB1 With SA NR    ue_id=1    spid=200
    Add Normal QCI1 Bearer    ue_id=1
    Add Emergency QCI1 Bearer    ue_id=1
    Release Normal QCI1 Bearer    ue_id=1
    Release Emergency QCI1 Bearer    ue_id=1
    Check Counters    ${Case01_Counters}
    [Teardown]    Case01 Test Teardown And Stop Capture Logs

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD_ABIO
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    create enb alias    ENB_1    enb_id=1    id_type=wts
    create mme alias    MME_1    mme_id=1    id_type=wts
    execute egate command    mme_param id=1 parallel_erab_release_cmd_and_nas=on

Modify Yaml
    Add Yaml      EPC/PGW
    ...    - id: 3
    ...    type: 'simulated'
    ...    apn: 'ulm_pgw3.net'
    ...    devtype: 'tun'
    ...    devname: 'tunPGW3'
    ...    emergency: 'on'
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...      - {qci: 8, default: on, pdn: 1}
    ...      - {qci: 8, default: on, pdn: 2}
    ...      - {qci: 1, pdn: 2, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31}
    ...      - {qci: 5, default: on, pdn: 3, priority: 1}
    ...      - {qci: 1, pdn: 3, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, preprovisioned: on, filter: 1, precedence: 1, priority: 1}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/1    capability: ${ue_5Gcapability}


Case01 Test Teardown And Stop Capture Logs
    Delta Commission Parameters    ${set_actIdleLB_to_false}
    Common Test Teardown And Stop Capture Logs

UE Attach to ENB1 With SA NR
    [Arguments]    ${ue_id}    ${spid}=1
    execute egate command    ue_mme_param id=${ue_id} spid=${spid}
    execute uex command    ue_attach id=${ue_id} cell=1 ue_eutra_capabilities=${ue_5Gcapability}

Add Normal QCI1 Bearer
    [Arguments]    ${ue_id}
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 7 and qCI eq 1 and priorityLevel eq 'no-priority'))
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq 7))
    ...    alias=normal_qci1     overall_timeout=10
    execute uex command    ue_pdn_connect id=${ue_id} apn=nokia_2.net
    execute uex command    bearer_add ue=${ue_id} qci=1 apn=nokia_2.net mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    flow occurred as expected    alias=normal_qci1

Add Emergency QCI1 Bearer
    [Arguments]    ${ue_id}
    expect message flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 9 and qCI eq 1 and priorityLevel eq 'highest'))
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq 9))
    ...    alias=emer_qci1    overall_timeout=10
    execute uex command    ue_pdn_connect id=${ue_id} apn=ulm_pgw3.net request_type=emergency
    flow occurred as expected    alias=emer_qci1

Release Normal QCI1 Bearer
    [Arguments]    ${ue_id}    ${by}=pgw
    expect message flow
    ...    MME_1:S1AP_E-RABReleaseCommand (E-RABList contains (e-RAB-ID eq 7 and cause contains (nas eq 'normal-release')))
    ...    MME_1:S1AP_E-RABReleaseResponse (e-RAB-ID eq 7)
    ...    alias=nor_rel    overall_timeout=10
    expect message will not occur
    ...    UE_1:RRC_RRCConnectionRelease
    ...    alias=nor_no_cause    overall_timeout=10
    execute uex command    bearer_del ue=${ue_id} qci=1 apn=nokia_2.net
    Flow Occurred as expected    alias=nor_rel
    Flow Not Occurred For Message    alias=nor_no_cause

Release Emergency QCI1 Bearer
    [Arguments]    ${ue_id}
    ${rrcredirect}    catenate
    ...    releaseCause eq 'other' and redirectedCarrierInfo contains
    ...    (nr-r15 contains (carrierFreq-r15 eq 422100 and subcarrierSpacingSSB-r15 eq 'kHz15'))
    expect message flow
    ...    UE_1:RRC_RRCConnectionRelease (${rrcredirect})
    ...    alias=eme_rel    overall_timeout=10
    execute uex command    bearer_del ue=${ue_id} qci=1 apn=ulm_pgw3.net
    flow occurred as expected    alias=eme_rel

Config Mobility Profiles
    [Arguments]    ${config}
    Delta Commission Parameters    ${config}

