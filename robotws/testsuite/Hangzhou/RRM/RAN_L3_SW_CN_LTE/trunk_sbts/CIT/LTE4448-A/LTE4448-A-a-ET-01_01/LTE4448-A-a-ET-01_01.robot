*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT
...               CLOUD_R4LAPO_CUS    release-L18    DEVHZ5_FT1    owner-haibao-abel.wang    owner-yin.zhang
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  @{PARAMS_FOR_CATM}
...  @{PARAMS_FOR_CRG}
@{PARAMS_FOR_CATM}
...  LNCEL-1/LNCEL_FDD-0:actCatM=false
...  LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...  LNCEL-1/LNCEL_FDD-0:catMProfId=1
...  LNCEL-1/SIB-0:siWindowLen=40ms
...  LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...  LNCEL-2/LNCEL_FDD-0:actCatM=true
...  LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...  LNCEL-2/LNCEL_FDD-0:catMProfId=1
...  LNCEL-2/SIB-0:siWindowLen=40ms
...  LNCEL-2/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...  LNCEL-2/CATMCEL-0:cellReSelPrioCatM=7
...  LNCEL-3/LNCEL_FDD-0:actCatM=true
...  LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...  LNCEL-3/LNCEL_FDD-0:catMProfId=1
...  LNCEL-3/SIB-0:siWindowLen=40ms
...  LNCEL-3/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...  LNCEL-3/CATMCEL-0:cellReSelPrioCatM=7
...  LNBTS/CATMPR-1:catMCELevel1:raPreGrCSizeCatM=10
...  LNBTS/CATMPR-1:catMCELevel1:raPreGrCSizeCatM=10
...  LNBTS/CATMPR-1:raPreGrCSizeCatM=8
...  LNCEL-1/CATMCEL-0:actConvVoiceCatM=true
...  LNCEL-2/CATMCEL-0:actConvVoiceCatM=true
...  LNCEL-3/CATMCEL-0:actConvVoiceCatM=true
...  LNBTS/CATMPR-1:inactivityTimerCatM=120
...  LNBTS/CATMPR-1:maxNumActDrbCatM=10
...  LNBTS/CATMPR-1:catMVoLTETab:qci1ProtectionTimerCatM=63
...  LNBTS/CATMPR-1:maxNumRrcCatM=10
${UE_EUTRA_CAPABILITIES_CATM}    D6000000800055555D55001000804510021200055C041900    # CATM UE
@{PARAMS_FOR_CRG}
...  LNBTS/CRGPR-1:crgSkipThreshold=0
...  LNBTS/CRGPR-1:defaultGroupId=0
...  LNBTS/CRGPR-1:plmnGroupList:groupId=0|mnc=2
...  LNBTS/CRGPR-1:plmnGroupList:groupId=1|mnc=3
...  LNCEL:cellResourceSharingMode=none
...  LNCEL:cellResourceGroupPrId=1
...  LNCEL/LNCEL_FDD-0:maxNumActUE=10
...  LNCEL:furtherPlmnIdL:mcc=262|mnc=2
...  LNBTS:actIfHo=enabled
...  LNCEL:threshold2aQci1=67
...  LNCEL:hysThreshold2InterFreq=0
...  LNCEL/SIB-0:threshServingLowQR9=0
...  LNBTS/CRGPR-1:groupShareList:groupId=0|groupShare=30
...  LNBTS/CRGPR-1:groupShareList:groupId=1|groupShare=70
...  LNCEL/SIB-0:cellSelectionInfoV920:qQualMinOffsetR9=1
...  LNCEL/SIB-0:cellSelectionInfoV920:qQualMinR9=-30
...  LNCEL/LNCEL_FDD-0:maxNumCaConfUe=8
...  LNCEL/LNCEL_FDD-0:maxNumCaConfUeDc=8
...  LNCEL/LNCEL_FDD-0:maxNumCaConfUe3c=8
...  LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=5
${lua_cell1}      shared_plmn=262:02
${lua_cell2}      shared_plmn=262:02
${lua_cell3}      shared_plmn=262:02
@{OnlineChangeList}
...  LNCEL-1/LNCEL_FDD-0:actCatM=true
...  LNCEL:cellResourceSharingMode=DLonly

*** Test Cases ***
LTE4448-A-a_ET_01_01_activation and configuration of the feature LTE4448 Cat-M1 coexistence LTE1382
    [Tags]
    OnlineParamChange    Online_Param=${OnlineChangeList}
    Attach a legacy UE at cell1 CRG0    ue_id=1
    Attach a legacy UE at cell1 CRG0    ue_id=2
    Attach a CAT-M UE at cell1 CRG0    ue_id=3
    Attach a CAT-M UE at cell1 CRG0 And Expected UE Idle    ue_id=4

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    create mme alias    MME_1    mme_id=1    id_type=wts

Attach a legacy UE at cell1 CRG0
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest
    ...    MME_1:S1AP_UECapabilityInfoIndication
    ...    alias=ue_attach_legacy  overall_timeout=30
    Execute UEx Command    ue_attach id=${ue_id} selected_plmn=262:02 cell=1
    Flow Occurred As Expected    alias=ue_attach_legacy

Attach a CAT-M UE at cell1 CRG0
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest
    ...    MME_1:S1AP_UECapabilityInfoIndication (UE-EUTRA-Capability contains (ue-CategoryDL-v1310 eq "m1"))
    ...    alias=ue_attach_catm  overall_timeout=30
    Execute UEx Command  ue_attach id=${ue_id} ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} selected_plmn=262:02 cell=1
    Flow Occurred As Expected    alias=ue_attach_catm

Attach a CAT-M UE at cell1 CRG0 And Expected UE Idle
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest
    ...    MME_1:S1AP_InitialContextSetupFailure (Cause contains (radioNetwork eq "radio-resources-not-available"))
    ...    alias=ue_attach_catm  overall_timeout=30
    Execute UEx Command And Expect Error
    ...    ue_attach id=${ue_id} ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} selected_plmn=262:02 cell=1
    ...    sErrAttachInterruptedByIdle
    Flow Occurred As Expected    alias=ue_attach_catm

OnlineParamChange
    [Arguments]    ${Online_Param}=${EMPTY}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir
