*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS    team-CN3ET    owner-zhijian.tong
...               owner-xu.wang    release-xL19
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CATM}
...    @{Enabled_ActCatMSpecMeas_And_Disable_ActInterFreqHoCatM}
@{PARAMS_FOR_CATM}
...    LNCEL/LNCEL_FDD-0:actCatM=true
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0:catMProfId=1
...    LNCEL/SIB-0:siWindowLen=40ms
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
@{Enabled_ActCatMSpecMeas_And_Disable_ActInterFreqHoCatM}
...    LNCEL/CATMCEL-0:actCatMSpecMeas=true
...    LNCEL/CATMCEL-0:actIntraFreqHoCatM=true
...    LNCEL/CATMCEL-0:actInterFreqHoCatM=disabled
...    LNCEL/CATMCEL-0:a1TimeToTriggerCatM=40ms
...    LNCEL/CATMCEL-0:a2TimeToTriggerCatM=${a2TimeToTriggerCatM}
...    LNCEL/CATMCEL-0:a3OffsetCatM=${a3OffsetCatM}
...    LNCEL/CATMCEL-0:a3TimeToTriggerCatM=${a3TimeToTriggerCatM}
...    LNCEL/CATMCEL-0:hysA3OffsetCatM=${hysA3OffsetCatM}
...    LNCEL/CATMCEL-0:hysThreshold2aCatM=4
...    LNCEL/CATMCEL-0:threshold2aCatM=${threshold2aCatM}
...    LNCEL/CATMCEL-0:threshold2CatM=${threshold2CatM}
...    LNCEL/CATMCEL-0:hysThreshold2CatM=${hysThreshold2CatM}
...    LNBTS/CATMPR-1:inactivityTimerCatM=179
...    LNBTS/CATMPR-1:catMVoLTETab:qci1ProtectionTimerCatM=180
${threshold2CatM}    42
${hysThreshold2CatM}    2
${a2TimeToTriggerCatM}    40ms
${a2TimeToTriggerCatM_rrc}    ms40
${a3OffsetCatM}    -6
${a3TimeToTriggerCatM}    80ms
${a3TimeToTriggerCatM_rrc}    ms80
${hysA3OffsetCatM}    6
${threshold2aCatM}    44
${UE_EUTRA_CAPABILITIES_CATM_NEED_MG}
...    D628030300082100C1F83F07E0FFFC3062FF282008800886400C08216A7008047480003184000AEC04390A6A03AA14908000000100
${UE_EUTRA_CAPABILITIES_CATM_NO_NEED_MG}
...    D62803042C001049C2130000026000004C000009800001300000FFFFFFFFCA0802200221900302085A9C02011D20000C610002BB010E428A00

*** Test Cases ***
LTE5109-A-b_ET_01_01_ICS while eNB_only_enabled_intra-frequency_HO
    [Tags]    CDRT
    [Template]
    Cat-m UE1 with intra-frequency HO capability and need MG attach to the cell1
    UE report intra-frequency A2 and will reconfigured intra-A3 and A1
    Cat-m UE2 with intra-frequency HO capability and no need MG attach to the cell1

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Execute Egate Command    trace_sim on mme=1 enb=1 uec=1 protocol=x2,s1,rrc on
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Cat-m UE1 with intra-frequency HO capability and need MG attach to the cell1
    ${eventA2}    catenate
    ...    eventA2 contains (
    ...    a2-Threshold contains (threshold-RSRP eq ${threshold2CatM})
    ...    )
    ...    and
    ...    hysteresis eq ${hysThreshold2CatM}
    ...    and
    ...    timeToTrigger eq '${a2TimeToTriggerCatM_rrc}'
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${eventA2})
    ...    alias=eventA2    overall_timeout=20
    Execute Uex Command    ue_attach id=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM_NEED_MG} cell=1
    Flow Occurred As Expected    alias=eventA2

UE report intra-frequency A2 and will reconfigured intra-A3 and A1
    ${eventA1A3}    catenate
    ...    event contains (
    ...    eventA1 contains (a1-Threshold contains (threshold-RSRP eq 44))
    ...    )
    ...    and
    ...    event contains (
    ...    eventA3 contains (a3-Offset eq ${a3OffsetCatM})
    ...    and
    ...    hysteresis eq ${hysA3OffsetCatM}
    ...    and
    ...    timeToTrigger eq '${a3TimeToTriggerCatM_rrc}'
    ...    )
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${eventA1A3})
    ...    alias=eventA1A3    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=1 event=A2 srsrp=41 srsrq=15
    Flow Occurred As Expected    alias=eventA1A3

Cat-m UE2 with intra-frequency HO capability and no need MG attach to the cell1
    ${eventA3}    catenate
    ...    eventA3 contains (
    ...    a3-Offset eq ${a3OffsetCatM}
    ...    )
    ...    and
    ...    hysteresis eq ${hysA3OffsetCatM}
    ...    and
    ...    timeToTrigger eq '${a3TimeToTriggerCatM_rrc}'
    Expect Message Flow
    ...    UE_2:RRC_RRCConnectionReconfiguration (${eventA3})
    ...    alias=eventA3    overall_timeout=20
    ${eventA2}    catenate
    ...    eventA2 contains (
    ...    a2-Threshold contains (threshold-RSRP eq ${threshold2CatM})
    ...    )
    Expect Message Flow
    ...    UE_2:RRC_RRCConnectionReconfiguration (${eventA2})
    ...    alias=noeventA2    overall_timeout=20
    Execute Uex Command    ue_attach id=2 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM_NO_NEED_MG} cell=1
    Flow Occurred As Expected    alias=eventA3
    Flow Not Occurred For Message    alias=noeventA2