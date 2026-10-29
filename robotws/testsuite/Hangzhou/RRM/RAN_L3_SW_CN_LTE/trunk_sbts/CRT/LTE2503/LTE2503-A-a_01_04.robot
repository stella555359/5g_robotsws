*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_TDD    RAN_4G    RAN_4G_TDD    CIT
...               CLOUD_R4LAPO_CUS    owner-jing.pan    team-DevHZ5_SG2    release-legacy
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS/LNBTS_TDD-0:actIMSEmerSessR9=true
...    LNBTS:imsEmerPlmnConfig:emerSessArpPreemCap=true
...    LNBTS:imsEmerPlmnConfig:emerSessArpPreemVul=false
...    LNBTS:imsEmerPlmnConfig:emerSessArpPrioLev=1
...    LNBTS:imsEmerPlmnConfig:emerSessLimServ=true
...    LNBTS:imsEmerPlmnConfig:emerSessMcc=262
...    LNBTS:imsEmerPlmnConfig:emerSessMnc=3
...    LNBTS:imsEmerPlmnConfig:emerSessMncLen=2
...    LNBTS/LNBTS_TDD-0:actInterFreqServiceBasedHo=true
...    LNBTS:actMultBearers=true
...    LNBTS/LNBTS_TDD-0:actConvVoice=true
...    LNBTS:actIfHo=enabled
...    LNCEL-1:sbHoMode=ec
...    LNCEL-1:iFServiceBasedHoRetryTimer=60
...    LNCEL-1/LNCEL_TDD-0:earfcn=40742
...    LNCEL-1:threshold2InterFreq=45
...    LNCEL-1:inactivityTimer=6000
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=40940
...    MODPR-0:autoAdapt=false
...    MODPR-0:freqLayListServiceBasedHo=40940
${first_A4_event}
...    eventId contains ("eventA4") and a4-Threshold contains (threshold-RSRP eq 0)
...    and
...    measIdToAddModList contains (measId eq 31 and measObjectId eq 2 and reportConfigId eq 5 )
...    and
...    s-Measure eq 0
${A4_event}
...    measIdToAddModList contains (measId eq 31 and measObjectId eq 2 and reportConfigId eq 5 )
...    and
...    s-Measure eq 0
${UE_eutra_capabilities}    91BFF043033E8CB0007FFFFFFFC000

*** Test Case ***
LTE2503-A-a_01_04_Measurement_Setup-QCI1E_Release_SB_HO_with_mode_EC
    [Tags]    owner-xu.wang
    UE_attach
    1st Emergency QCI1
    2nd Emergency QCI1
    Release 1st Emergency QCI1
    Release 2nd Emergency QCI1

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs
    Execute Egate Command    trace_sim on mme=1 enb=1 uec=1 protocol=x2,s1,rrc on
    Create UE Alias    alias=UE_1    ue_id=1    id_type=cus

Modify Yaml
    Add Yaml      EPC/PGW
    ...    - id: 3
    ...    type: 'simulated'
    ...    apn: 'emergency.nsn.com'
    ...    emergency: 'on'

    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...      - {qci: 5, default: on, pdn: 1, trf_type: external}
    ...      - {qci: 1, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25, pdn: 1, priority: 1}
     ...     - {qci: 5, default: on, pdn: 3, priority: 1, trf_type: external}
    ...      - {qci: 1, preprovisioned: on, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25, pdn: 3, priority: 1, filter: 1, precedence: 1 }

    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2

UE_attach
    Execute Uex Command    ue_attach id=1 ue_eutra_capabilities=${ue_eutra_capabilities} enb=1 cell=1

1st Emergency QCI1
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${first_A4_event})
    ...    alias=A4_event    overall_timeout=20
    execute uex command    bearer_add ue=1 qci=1 mbr_ul=25 mbr_dl=25 gbr_ul=25 gbr_dl=25
    Flow Occurred As Expected    alias=A4_event

2nd Emergency QCI1
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${A4_event})
    ...    alias=A4_event    overall_timeout=60
    execute uex command    ue_pdn_connect id=1 apn=emergency.nsn.com request_type=emergency
    Flow Occurred As Expected    alias=A4_event

Release 1st Emergency QCI1
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${A4_event})
    ...    alias=A4_event    overall_timeout=70
    execute uex command    bearer_del ue=1 qci=1 apn=nokia_1.net
    Flow Occurred As Expected    alias=A4_event

Release 2nd Emergency QCI1
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (31) and s-Measure eq 90)
    ...    alias=A4_remove    overall_timeout=70
    execute uex command    bearer_del ue=1 qci=1 apn=emergency.nsn.com
    Flow Occurred As Expected    alias=A4_remove
