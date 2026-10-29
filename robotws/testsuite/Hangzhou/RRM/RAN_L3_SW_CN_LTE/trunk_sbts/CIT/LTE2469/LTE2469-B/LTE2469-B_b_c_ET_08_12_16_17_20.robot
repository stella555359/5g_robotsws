*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT
...               CLOUD_R4LAPO    owner-huabao.jiang    release-xL19A    team-DevHZ5_SG4
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_SPID_CONFIG}
...    @{PARAMS_FOR_CELL_CONFIG}
...    LNBTS-1:actMultBearers=true
...    LNBTS-1:actMultGbrBearers=true
...    LNBTS-1/LNBTS_FDD-0:actConvVoice=true
...    LNBTS-1:actEnhAcAndGbrServices=true
...    LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnChBw=15 MHz
@{PARAMS_FOR_SPID_CONFIG}
...    LNBTS-1:cellResourceSharingType=spidBased
...    LNBTS-1/CRGPR-0:crgSkipThreshold=0
...    LNBTS-1/CRGPR-0:defaultGroupId=0
...    LNBTS-1/CRGPR-0:spidGroupList:spid=1|groupId=0
...    LNBTS-1/CRGPR-0:spidGroupList:spidLast=5|groupId=0
...    LNBTS-1/CRGPR-0:spidGroupList:spid=6|groupId=1
...    LNBTS-1/CRGPR-0:spidGroupList:spidLast=10|groupId=1
...    LNBTS-1/CRGPR-0:groupShareList:groupShare=25|groupId=0
...    LNBTS-1/CRGPR-0:groupShareList:groupShare=75|groupId=1
...    LNBTS-1/LNCEL-1:cellResourceGroupPrId=0
...    LNBTS-1/LNCEL-1:cellResourceSharingMode=DLandUL
...    LNBTS-1/LNCEL-2:cellResourceSharingMode=none
...    LNBTS-1/LNCEL-3:cellResourceSharingMode=none
...    delete:LNBTS-1/CRGPR-0:plmnGroupList
...    delete:LNBTS-1/CRGPR-1
@{PARAMS_FOR_CELL_CONFIG}
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:dlChBw=15 MHz
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:ulChBw=15 MHz
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:maxNumActUE=8
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:maxNumActDrb=16
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:minNumRrc=5
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:maxNumQci1Drb=8
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:maxNumCaConfUeDc=0
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe=0
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe3c=0
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:addNumQci1DrbRadioReasHo=0
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:addNumDrbRadioReasHo=0
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:addNumDrbTimeCriticalHo=0
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:minNumRrcNoDrb=0
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:addAUeRrHo=0
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:addAUeTcHo=0
${UE_EUTRA_CAPABILITIES}    CD9FF459B2E750081810381FFFFFFFFF2862000608020A5408008A80182CFFFFFFFF8053FFFFFFFF
@{Online_Commission_for_08_01}
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:dlChBw=15 MHz
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:ulChBw=15 MHz
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:maxNumActUE=8
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:maxNumActDrb=16
...    LNBTS-1/CRGPR-0:defaultGroupId=1
...    LNBTS-1/CRGPR-0:spidGroupList:spid=1|groupId=0
...    LNBTS-1/CRGPR-0:spidGroupList:spidLast=5|groupId=0
...    LNBTS-1/CRGPR-0:spidGroupList:spid=6|groupId=1
...    LNBTS-1/CRGPR-0:spidGroupList:spidLast=10|groupId=1
...    LNBTS-1/CRGPR-0:groupShareList:groupShare=25|groupId=0
...    LNBTS-1/CRGPR-0:groupShareList:groupShare=75|groupId=1
...    LNBTS-1/LNCEL-1:cellResourceGroupPrId=0
...    LNBTS-1/LNCEL-1:cellResourceSharingMode=DLandUL
@{Online_Commission_for_12_01}
...    LNCEL-1/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-1/LNCEL_FDD-0:maxNumActUE=8
...    LNCEL-1/LNCEL_FDD-0:maxNumActDrb=8
...    LNBTS-1/CRGPR-0:defaultGroupId=1
...    LNBTS-1/CRGPR-0:spidGroupList:spid=1|groupId=1
...    LNBTS-1/CRGPR-0:spidGroupList:spidLast=5|groupId=1
...    LNBTS-1/CRGPR-0:spidGroupList:spid=6|groupId=0
...    LNBTS-1/CRGPR-0:spidGroupList:spidLast=10|groupId=0
...    LNBTS-1/CRGPR-0:groupShareList:groupShare=25|groupId=1
...    LNBTS-1/CRGPR-0:groupShareList:groupShare=75|groupId=0
...    LNBTS-1/LNCEL-1:cellResourceGroupPrId=0
...    LNBTS-1/LNCEL-1:cellResourceSharingMode=DLandUL
@{Online_Commission_for_16_01}
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:dlChBw=20 MHz
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:ulChBw=20 MHz
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:maxNumActUE=10
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:maxNumActDrb=10
...    LNBTS-1/CRGPR-0:defaultGroupId=1
...    LNBTS-1/CRGPR-0:spidGroupList:spid=1|groupId=0
...    LNBTS-1/CRGPR-0:spidGroupList:spidLast=${EMPTY}|groupId=0
...    LNBTS-1/CRGPR-0:spidGroupList:spid=2|groupId=1
...    LNBTS-1/CRGPR-0:spidGroupList:spidLast=10|groupId=1
...    LNBTS-1/CRGPR-0:spidGroupList:spid=100|groupId=2
...    LNBTS-1/CRGPR-0:spidGroupList:spidLast=110|groupId=2
...    LNBTS-1/CRGPR-0:spidGroupList:spid=130|groupId=3
...    LNBTS-1/CRGPR-0:spidGroupList:spidLast=${EMPTY}|groupId=3
...    LNBTS-1/CRGPR-0:groupShareList:groupShare=20|groupId=0
...    LNBTS-1/CRGPR-0:groupShareList:groupShare=20|groupId=1
...    LNBTS-1/CRGPR-0:groupShareList:groupShare=20|groupId=2
...    LNBTS-1/CRGPR-0:groupShareList:groupShare=40|groupId=3
...    LNBTS-1/LNCEL-1:cellResourceGroupPrId=0
...    LNBTS-1/LNCEL-1:cellResourceSharingMode=DLandUL
@{Online_Commission_for_17_01}
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:dlChBw=10 MHz
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:ulChBw=10 MHz
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:maxNumActUE=8
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:maxNumActDrb=8
...    LNBTS-1/CRGPR-0:defaultGroupId=0
...    LNBTS-1/CRGPR-0:spidGroupList:spid=1|groupId=0
...    LNBTS-1/CRGPR-0:spidGroupList:spid=2|groupId=1
...    LNBTS-1/CRGPR-0:spidGroupList:spidLast=10|groupId=1
...    LNBTS-1/CRGPR-0:groupShareList:groupShare=25|groupId=0
...    LNBTS-1/CRGPR-0:groupShareList:groupShare=75|groupId=1
...    LNBTS-1/LNCEL-1:cellResourceGroupPrId=0
...    LNBTS-1/LNCEL-1:cellResourceSharingMode=DLandUL
...    LNBTS-1/CRGPR-0:spidGroupList:spidLast=${EMPTY}|groupId=0
@{Online_Commission_for_20_01}
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:dlChBw=20 MHz
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:ulChBw=20 MHz
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:maxNumActUE=10
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:maxNumActDrb=10
...    LNBTS-1/CRGPR-0:defaultGroupId=1
...    LNBTS-1/CRGPR-0:spidGroupList:spid=1|groupId=0
...    LNBTS-1/CRGPR-0:spidGroupList:spid=2|groupId=1
...    LNBTS-1/CRGPR-0:spidGroupList:spidLast=10|groupId=1
...    LNBTS-1/CRGPR-0:spidGroupList:spid=100|groupId=2
...    LNBTS-1/CRGPR-0:spidGroupList:spidLast=110|groupId=2
...    LNBTS-1/CRGPR-0:spidGroupList:spid=130|groupId=3
...    LNBTS-1/CRGPR-0:groupShareList:groupShare=20|groupId=0
...    LNBTS-1/CRGPR-0:groupShareList:groupShare=20|groupId=1
...    LNBTS-1/CRGPR-0:groupShareList:groupShare=20|groupId=2
...    LNBTS-1/CRGPR-0:groupShareList:groupShare=40|groupId=3
...    LNBTS-1/LNCEL-1:cellResourceGroupPrId=0
...    LNBTS-1/LNCEL-1:cellResourceSharingMode=DLandUL
...    LNCEL-1/LNREL-0:ecgiLcrId=2
...    LNCEL-1/LNREL-0:ecgiAdjEnbId=10.0.1.2
...    LNCEL-1/LNREL-0:handoverAllowed=allowed
...    LNCEL-2/LNREL-0:ecgiLcrId=1
...    LNCEL-2/LNREL-0:ecgiAdjEnbId=10.0.1.2
...    LNCEL-2/LNREL-0:handoverAllowed=allowed
...    LNBTS-1/CRGPR-0:spidGroupList:spidLast=${EMPTY}|groupId=0
...    LNBTS-1/CRGPR-0:spidGroupList:spidLast=${EMPTY}|groupId=3
@{Online_change_cellResourceSharingMode}
...    LNBTS-1/LNCEL-1:cellResourceSharingMode=none
#${ue4_lua_bearer1}    default=on ip=1.7.111.4 qci=8 trf_type=internal priority=8 preemption=0 vulnerability=0
#${ue4_lua_bearer2}    qci=1 gbr_ul=31 gbr_dl=31 mbr_ul=31 mbr_dl=31 preprovisioned=on filter=1 precedence=1 priority=4 preemption=0 vulnerability=0
#${ue5_lua_bearer1}    default=on ip=1.7.111.5 qci=8 trf_type=internal priority=8 preemption=0 vulnerability=0
#${ue5_lua_bearer8}    qci=7 preprovisioned=on filter=7 precedence=7 priority=7 preemption=0 vulnerability=0
#${ue5_lua_bearer7}    qci=6 preprovisioned=on filter=6 precedence=6 priority=6 preemption=0 vulnerability=0
#${ue9_lua_bearer1}    default=on ip=1.7.111.9 qci=8 trf_type=internal priority=8 preemption=0 vulnerability=0
#${ue9_lua_bearer8}    qci=7 preprovisioned=on filter=7 precedence=7 priority=7 preemption=0 vulnerability=0
#${ue9_lua_bearer7}    qci=6 preprovisioned=on filter=6 precedence=6 priority=6 preemption=0 vulnerability=0
#${lua_ue_simenb_2}    {True}
#${simenb_2_earfcn}    1400:19400
${X2_match_string_with_eNB42}    ENB-42: X2AP Link with ENB-1
@{EXPECTED_STRING_AFTER_UE4_ATTACH}
...  UE4: PGW-initiated Preprovisioned Bearer Creation. Bearer-2 \\(EBI=6, QCI=1\\) created
@{EXPECTED_STRING_AFTER_UE5_ATTACH}
...  id 106
...  value SubscriberProfileIDforRFP : 100
...  UE5: Attach rejected
@{EXPECTED_STRING_AFTER_UE9_ATTACH}
...  UE9: PGW-initiated Preprovisioned Bearer Creation. Bearer-7 \\(EBI=6, QCI=6\\) created
...  UE9: PGW-initiated Preprovisioned Bearer Creation. Bearer-8 \\(EBI=7, QCI=7\\) created

*** Test Cases ***
LTE2469-B-b_ET_08_01_ICS with SPID matching config scope but exceed maxnumActUe threshold
    [Tags]
    Online Commission for 08 01
    Attach normal UE1 with spid_2 in cell1 CRG0
    Attach normal UE2 with spid_4 in cell1 CRG0
    Attach normal UE3 fail with spid_5 in cell1 CRG0 due to reach maxnumActUe multiply CRG0_share
    Detach UE2
    Attach normal UE3 with spid_5 in cell1 CRG0
    Online commission change cellResourceSharingMode to none
    Detach all UEs and attach UE1-UE3 to cell1 CRG0 again
    detach ues

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Comment    Debug Enter Into Egate
    execute egate command    sim_trace mme=1 protocol=s1 on
    execute egate command    sim_trace enb=42 protocol=x2 on
    Create Alias

Create Alias
    FOR    ${ue_id}    IN RANGE    1    3
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Online Commission for 08 01
    Delta Commission Parameters    ${Online_Commission_for_08_01}
    Wait Until Keyword Succeeds    3min    5s    Cells Should Be OnAir

Attach normal UE1 with spid_2 in cell1 CRG0
    expect message flow
    ...    MME_1:S1AP_InitialContextSetupRequest(SubscriberProfileIDforRFP eq 2)
    ...    alias=ue1_flow    overall_timeout=30
    execute egate command    ue_mme_param id=1 spid=2
    execute uex command    ue_attach id=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES} enb=1 cell=1
    flow occurred as expected    alias=ue1_flow

Attach normal UE2 with spid_4 in cell1 CRG0
    expect message flow
    ...    MME_1:S1AP_InitialContextSetupRequest(SubscriberProfileIDforRFP eq 4)
    ...    alias=ue2_flow    overall_timeout=30
    execute egate command    ue_mme_param id=2 spid=4
    execute uex command   ue_attach id=2 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES} enb=1 cell=1
    flow occurred as expected    alias=ue2_flow

Attach normal UE3 fail with spid_5 in cell1 CRG0 due to reach maxnumActUe multiply CRG0_share
    expect message flow
    ...    MME_1:S1AP_InitialContextSetupRequest(SubscriberProfileIDforRFP eq 5)
    ...    alias=ue3_flow    overall_timeout=30
    execute egate command    ue_mme_param id=3 spid=5
    execute uex command and expect error    ue_attach id=3 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES} enb=1 cell=1    ElixirException
    flow occurred as expected    alias=ue3_flow

Detach UE2
    execute uex command    ue_detach id=2

Detach UEs
    execute uex command    ue_detach all

Attach normal UE3 with spid_5 in cell1 CRG0
    expect message flow
    ...    MME_1:S1AP_InitialContextSetupRequest(SubscriberProfileIDforRFP eq 5)
    ...    alias=ue3_sec_flow    overall_timeout=30
    execute egate command    ue_mme_param id=3 spid=5
    execute uex command    ue_attach id=3 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES} enb=1 cell=1
    flow occurred as expected    alias=ue3_sec_flow

Online commission change cellResourceSharingMode to none
    Delta Commission Parameters    ${Online_change_cellResourceSharingMode}
    Wait Until Keyword Succeeds    3min    5s    Cells Should Be OnAir

Detach all UEs and attach UE1-UE3 to cell1 CRG0 again
    detach ues
    execute uex command    ue_attach id=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES} cell=1
    execute uex command    ue_attach id=2 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES} cell=1
    execute uex command    ue_attach id=3 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES} cell=1


