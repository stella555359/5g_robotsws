*** Settings ***
Documentation    Test Cases for 5GC000776 Multiple DRB profiles per QCI with configurable scheduling weight for NSA
...              author:  merin.varghese@nokia.com

Library           ./UEControl.py   WITH NAME   ue_control
Resource          ./Common_Keywords_776_A_B.robot


Suite Setup      Suite Setup
Suite Teardown   Suite Teardown
Test Teardown    Test Teardown

*** Variables ***
${UE_ID_1}                 1
${UE_ID_2}                 2
${PROFILE_ID}              1
${DEFAULT_BEARER_ID}       9
${NON_DEFAULT_BEARER_ID}   8
${DEFAULT_SCHEDULING_WEIGHT}    1
${NON_DEFAULT_SCHEDULING_WEIGHT}    10
${AP_DL_RATE}              13
${AP_UL_RATE}              5
${BEARER_DELETE_TIMEOUT}    2s
&{NRDRB_LIST_PARAMETERS}        nsa3xBearerAllowed=true    dlDataSplitMode=dlOverF1U    ulDataPath=ulOverNr
    ...    initialDLTrafficRouting=initDLoverF1U    dlFlowControlAlgo=3gppFlowControl

*** Test Cases ***
5GC000776_A_TC03_DL_trafficScheduling_1UE_multiDRB_differentQCI_differentSchedulingWeights
    [Documentation]
    ...    TC is to validate the impact of the QCI relevant configured scheduling weights in the scheduler
    ...    for single UE with 2 bearers during bearer addition, i.e. checking data rates on each bearer of
    ...    UE1 and use ratio of the data rates to check whether its in accordance with the configured scheduling weight.
    ...    Bearer id:8 -> QCI:8 -> NRDRB-5 -> Scheduling Weight:10
    ...    Bearer id:9 -> QCI:9 -> NRDRB-6 -> Scheduling Weight:1
    [Tags]    CRT
    [Setup]    Test Setup    TC_number=SingleUEMultiBearer
    Attach UE with two non-GBR bearers    ue_id=${UE_ID_1}    sgnbaddition=True
    Send DL data for UE    ue_id=${UE_ID_1}
    Get DL data rate for default and non default bearer
    Check data rate ratio of bearers according to scheduling weights

5GC000776_B_TC01_DL_trafficScheduling_2UE_multiDRB_differentQCI_differentSchedulingWeights_BearerAddition
    [Documentation]
    ...    TC01 is to validate the impact of the QCI relevant configured scheduling weights in the scheduler
    ...    for 2 UEs each with 2 bearers during bearer addition, i.e. checking data rates on each bearer of
    ...    UE1 and UE2, all using configured schedulweight, then add a 3. bearer to the UE1.
    ...    Bearer id:8 -> QCI:8 -> NRDRB-5 -> Scheduling Weight:4
    ...    Bearer id:9 -> QCI:9 -> NRDRB-6 -> Scheduling Weight:8
    ...    Bearer id:2 -> QCI:70 -> NRDRB-8 -> Scheduling Weight:5
    ...    Bearer id:3 -> QCI:79 -> NRDRB-9 -> Scheduling Weight:10
    [Tags]    CRT
    [Setup]    Test Setup    TC_number=BearerAddition
    Attach UE with two non-GBR bearers    ue_id=${UE_ID_1}    sgnbaddition=True
    Attach UE with two non-GBR bearers    ue_id=${UE_ID_2}    sgnbaddition=True
    Send DL data for both UEs for all two bearers
    Trigger SgNBModification to Add Bearer    ue_id=${UE_ID_1}    bearer_id=2    qci=70    scheduling_weight=5
    Send DL data for new bearer    ue_id=${UE_ID_1}    bearer_id=2
    Get average throughput for all UE bearers    direction=DL
    Check data rate ratio to scheduling weight ratio
    Delete newly added bearer for UE1    ue_id=${UE_ID_1}    bearer_id=2    direction=DL
    Trigger SgNBModification to Add Bearer    ue_id=${UE_ID_1}    bearer_id=3    qci=79    scheduling_weight=10
    Send DL data for new bearer    ue_id=${UE_ID_1}    bearer_id=3
    Get average throughput for all UE bearers    direction=DL
    Check data rate ratio to scheduling weight ratio

5GC000776_B_TC04_UL_trafficScheduling_2UE_multiDRB_differentQCI_differentSchedulingWeights_BearerDeletion
    [Documentation]
    ...    TC04 is to validate the impact of the QCI relevant configured scheduling weights in the scheduler for
    ...    UE1 and UE2 each with 2 bearers during bearer deletion, i.e. checking data rates on each bearer of
    ...    UE1 and UE2, all using configured schedulweights, then delete the 1. bearer from UE1, check data rate.
    ...    Bearer id:7 -> QCI:7 -> NRDRB-4 -> Scheduling Weight:2
    ...    Bearer id:8 -> QCI:8 -> NRDRB-5 -> Scheduling Weight:4
    ...    Bearer id:9 -> QCI:9 -> NRDRB-6 -> Scheduling Weight:8
    [Tags]    CRT
    [Setup]    Test Setup    TC_number=BearerDeletion
    Attach UE with three non-GBR bearers    ue_id=${UE_ID_1}    sgnbaddition=False
    Attach UE with three non-GBR bearers    ue_id=${UE_ID_2}    sgnbaddition=False
    Send UL data for both UEs for all three bearers
    Trigger SgNBAddition    ue_id=${UE_ID_1}
    Trigger SgNBAddition    ue_id=${UE_ID_2}
    Delete newly added bearer for UE1    ue_id=${UE_ID_1}    bearer_id=8    direction=UL
    Get average throughput for all UE bearers    direction=UL
    Check data rate ratio to scheduling weight ratio

5GC000776_B_TC07_DL_trafficScheduling_2UE_multiDRB_differentQCI_differentSchedulingWeights_on-lineModification
    [Documentation]
    ...    TC07 is to validate the on-line modifiability of the QCI parameter schedulWeight and the correct behaviour of
    ...    the scheduler when taking the new values into use, i.e.UE1 with 2 Bearer kept with default schedulWeight,
    ...    after on-line modificaiton of schedulWeight, UE2 with 2 bearer shall use the new configured values,
    ...    check data rate of all bearers correspondingly.
    ...    Bearer id:8 -> QCI:8 -> NRDRB-5 -> Scheduling Weight:1 then changed to 4 in between the testcase
    ...    Bearer id:9 -> QCI:9 -> NRDRB-6 -> Scheduling Weight:1 then changed to 8 in between the testcase
    [Tags]    CRT
    [Setup]    Test Setup    TC_number=OnlineModification
    Attach UE with two non-GBR bearers    ue_id=1    sgnbaddition=True
    Send DL data for UE    ue_id=${UE_ID_1}
    Change Scheduling Weight in NRDRB profile
    Attach UE with two non-GBR bearers    ue_id=2    sgnbaddition=True
    Send DL data for UE    ue_id=${UE_ID_2}
    Get average throughput for all UE bearers    direction=DL
    Check data rate ratio to scheduling weight ratio

5GC000776_B_TC11_DL_trafficScheduling_2UE_multiDRB_differentQCI_differentSchedulingWeights_activation
    [Documentation]
    ...    TC07 is to validate the on-line deactivation and activation of the non GBR differentiation feature flag and the correct behaviour of
    ...    the scheduler after enabling the feature, i.e.UE1 with 3 Bearer kept with default schedulWeight - which is 1
    ...    after activation of the feature, UE2 with 3 bearer shall use the actual configured values,
    ...    check data rate of all bearers correspondingly.
    ...    Bearer id:7 -> QCI:7 -> NRDRB-4 -> Scheduling Weight:2
    ...    Bearer id:8 -> QCI:8 -> NRDRB-5 -> Scheduling Weight:4
    ...    Bearer id:9 -> QCI:9 -> NRDRB-6 -> Scheduling Weight:8
    [Tags]    CRT
    [Setup]    Test Setup    TC_number=FeatureDisable
    Attach UE with three non-GBR bearers    ue_id=${UE_ID_1}    sgnbaddition=True
    Send DL data for UE    ue_id=${UE_ID_1}
    Enable Non-GBR service differentiation and modify NRDRB profile
    Attach UE with three non-GBR bearers    ue_id=${UE_ID_2}    sgnbaddition=True
    Send DL data for UE    ue_id=${UE_ID_2}
    Get average throughput for all UE bearers    direction=DL
    Check data rate ratio to scheduling weight ratio

*** Keywords ***
Execute Delta Commissioning for BearerAddition and Deletion
    [Documentation]    Activate 5GC000795 Multiple DRBs per UE
    ...    Activate 5GC000776 Non-GBR service differentiation
    ...    Create Dedicated NRDRB_QCI NRDRB with schedulWeight which is not 1
    ...    Bearer without pre-configured QCI MOC should use NRDRB-1
    ...    Bearer with pre-confiugred QCI MOC should use dedicated NRDRB
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Update feature flags
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}/NRCELL-1    dllaIniMcs=0
    Update NRDRB profile    dist_name=${NRBTS_DISTNAME}/NRDRB-1    schedulWeight=1    &{NRDRB_LIST_PARAMETERS}
    Update NRDRB profile    dist_name=${NRBTS_DISTNAME}/NRDRB-4    schedulWeight=2    &{NRDRB_LIST_PARAMETERS}
    Update NRDRB profile    dist_name=${NRBTS_DISTNAME}/NRDRB-5    schedulWeight=4    &{NRDRB_LIST_PARAMETERS}
    Update NRDRB profile    dist_name=${NRBTS_DISTNAME}/NRDRB-6    schedulWeight=8    &{NRDRB_LIST_PARAMETERS}
    Update NRDRB profile    dist_name=${NRBTS_DISTNAME}/NRDRB-8    schedulWeight=5    &{NRDRB_LIST_PARAMETERS}
    Update NRDRB profile    dist_name=${NRBTS_DISTNAME}/NRDRB-9    schedulWeight=10    &{NRDRB_LIST_PARAMETERS}
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}

Execute Delta Commissioning for online modification
    [Documentation]    Activate 5GC000795 Multiple DRBs per UE
    ...    Activate 5GC000776 Non-GBR service differentiation
    ...    Create Dedicated NRDRB_QCI NRDRB with schedulWeight which is not 1
    ...    Bearer without pre-configured QCI MOC should use NRDRB-1
    ...    Bearer with pre-confiugred QCI MOC should use dedicated NRDRB
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Update feature flags
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}/NRCELL-1    dllaIniMcs=0
    Update NRDRB profile    dist_name=${NRBTS_DISTNAME}/NRDRB-1    schedulWeight=1    &{NRDRB_LIST_PARAMETERS}
    Update NRDRB profile    dist_name=${NRBTS_DISTNAME}/NRDRB-4    schedulWeight=1    &{NRDRB_LIST_PARAMETERS}
    Update NRDRB profile    dist_name=${NRBTS_DISTNAME}/NRDRB-5    schedulWeight=1    &{NRDRB_LIST_PARAMETERS}
    Update NRDRB profile    dist_name=${NRBTS_DISTNAME}/NRDRB-6    schedulWeight=1    &{NRDRB_LIST_PARAMETERS}
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}

Execute Delta Commissioning for feature disabling
    [Documentation]    Disable 5GC000776 Non-GBR service differentiation feature
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    actNonGbrServiceDiff=false
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}

Update feature flags
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    actNonGbrServiceDiff=true
    ...    actMultiDrbNSA=true

Test Setup
   [Arguments]    ${TC_number}
   Create Test Case Folder
   Start pcap collection in gNB and WTS
   Start WTS And Extablish X2 Link
   Store UE and bearer details    ${TC_number}
   Execute Delta Commissioning    ${TC_number}
   Wait for gNB To Be Ready
   Download current scf file from gnb

Store UE and bearer details
   [Arguments]    ${TC_number}
   run keyword if    '${TC_number}' == 'BearerAddition'    BearerAddition_UE
   run keyword if    '${TC_number}' == 'BearerDeletion'    BearerDeletion_UE
   run keyword if    '${TC_number}' == 'OnlineModification'    OnlineModification_UE
   run keyword if    '${TC_number}' == 'FeatureDisable'    FeatureDisable_UE
   run keyword if    '${TC_number}' == 'SingleUEMultiBearer'    SingleUEMultiBearer_UE

BearerAddition_UE
   ue_control.Create UE   ${UE_ID_1}
   ue_control.Create UE   ${UE_ID_2}
   ue_control.Switch UE   ${UE_ID_1}
   ue_control.Add Bearer To UE   bearer_id=${DEFAULT_BEARER_ID}   qci=${DEFAULT_BEARER_ID}   weight=8
   ue_control.Add Bearer To UE   bearer_id=${NON_DEFAULT_BEARER_ID}   qci=${NON_DEFAULT_BEARER_ID}   weight=4
   ue_control.Switch UE   ${UE_ID_2}
   ue_control.Add Bearer To UE   bearer_id=${DEFAULT_BEARER_ID}   qci=${DEFAULT_BEARER_ID}   weight=8
   ue_control.Add Bearer To UE   bearer_id=${NON_DEFAULT_BEARER_ID}   qci=${NON_DEFAULT_BEARER_ID}   weight=4

BearerDeletion_UE
   ue_control.Create UE   ${UE_ID_1}
   ue_control.Create UE   ${UE_ID_2}
   ue_control.Switch UE   ${UE_ID_1}
   ue_control.Add Bearer To UE   bearer_id=${DEFAULT_BEARER_ID}   qci=${DEFAULT_BEARER_ID}   weight=8
   ue_control.Add Bearer To UE   bearer_id=${NON_DEFAULT_BEARER_ID}   qci=${NON_DEFAULT_BEARER_ID}   weight=4
   ue_control.Add Bearer To UE   bearer_id=7   qci=7   weight=2
   ue_control.Switch UE   ${UE_ID_2}
   ue_control.Add Bearer To UE   bearer_id=${DEFAULT_BEARER_ID}   qci=${DEFAULT_BEARER_ID}   weight=8
   ue_control.Add Bearer To UE   bearer_id=${NON_DEFAULT_BEARER_ID}   qci=${NON_DEFAULT_BEARER_ID}   weight=4
   ue_control.Add Bearer To UE   bearer_id=7   qci=7   weight=2

OnlineModification_UE
   ue_control.Create UE   ${UE_ID_1}
   ue_control.Create UE   ${UE_ID_2}
   ue_control.Switch UE   ${UE_ID_1}
   ue_control.Add Bearer To UE   bearer_id=${DEFAULT_BEARER_ID}   qci=${DEFAULT_BEARER_ID}   weight=1
   ue_control.Add Bearer To UE   bearer_id=${NON_DEFAULT_BEARER_ID}   qci=${NON_DEFAULT_BEARER_ID}   weight=1
   ue_control.Switch UE   ${UE_ID_2}
   ue_control.Add Bearer To UE   bearer_id=${DEFAULT_BEARER_ID}   qci=${DEFAULT_BEARER_ID}   weight=8
   ue_control.Add Bearer To UE   bearer_id=${NON_DEFAULT_BEARER_ID}   qci=${NON_DEFAULT_BEARER_ID}   weight=4

FeatureDisable_UE
   ue_control.Create UE   ${UE_ID_1}
   ue_control.Create UE   ${UE_ID_2}
   ue_control.Switch UE   ${UE_ID_1}
   ue_control.Add Bearer To UE   bearer_id=${DEFAULT_BEARER_ID}   qci=${DEFAULT_BEARER_ID}   weight=1
   ue_control.Add Bearer To UE   bearer_id=${NON_DEFAULT_BEARER_ID}   qci=${NON_DEFAULT_BEARER_ID}   weight=1
   ue_control.Add Bearer To UE   bearer_id=7   qci=7   weight=1
   ue_control.Switch UE   ${UE_ID_2}
   ue_control.Add Bearer To UE   bearer_id=${DEFAULT_BEARER_ID}   qci=${DEFAULT_BEARER_ID}   weight=8
   ue_control.Add Bearer To UE   bearer_id=${NON_DEFAULT_BEARER_ID}   qci=${NON_DEFAULT_BEARER_ID}   weight=4
   ue_control.Add Bearer To UE   bearer_id=7   qci=7   weight=2

Execute Delta Commissioning
   [Arguments]    ${TC_number}
   run keyword if    '${TC_number}' == 'BearerAddition'    Execute Delta Commissioning for BearerAddition and Deletion
   run keyword if    '${TC_number}' == 'BearerDeletion'   Execute Delta Commissioning for BearerAddition and Deletion
   run keyword if    '${TC_number}' == 'OnlineModification'      Execute Delta Commissioning for online modification
   run keyword if    '${TC_number}' == 'FeatureDisable'      Execute Delta Commissioning for feature disabling
   run keyword if    '${TC_number}' == 'SingleUEMultiBearer'    Execute Delta Commissioning for Single UE MultiBearer

Attach UE with two non-GBR bearers
    [Documentation]    Attach on LTE, add two additional non-GBR bearers and trigger SgNBAddition
    ...    Should be used for both UEs
    [Arguments]    ${ue_id}    ${sgnbaddition}
    UE Attach   ue_id=${ue_id}   profile_id=${PROFILE_ID}
    wts.Add Bearer   ue_id=${ue_id}   bearer_id=${NON_DEFAULT_BEARER_ID}   filter=0   precedence=${NON_DEFAULT_BEARER_ID}
    Run Keyword If    ${sgnbaddition}    Trigger SgNBAddition    ${ue_id}

Attach UE with three non-GBR bearers
    [Documentation]    Attach on LTE, add two additional non-GBR bearers and trigger SgNBAddition
    ...    Should be used for both UEs
    [Arguments]    ${ue_id}    ${sgnbaddition}
    UE Attach   ue_id=${ue_id}   profile_id=${PROFILE_ID}
    Sleep    1s
    wts.Add Bearer   ue_id=${ue_id}   bearer_id=7   filter=0   precedence=7
    wts.Add Bearer   ue_id=${ue_id}   bearer_id=8   filter=0   precedence=8
    Run Keyword If    ${sgnbaddition}    Trigger SgNBAddition    ${ue_id}

Trigger SgNBAddition
    [Arguments]    ${ue_id}
    ${UE_Bearers}    Get all bearer IDs for UE    ${ue_id}
    SGNB Addition For Bearer   ue_id=${ue_id}   target_gnb=${GNB_ID}
    ...                        target_cells=${CELL_ID}   bearer=${UE_Bearers}

Get all bearer IDs for UE
    [Arguments]    ${ue_id}
    ue_control.Switch UE    ${ue_id}
    ${UE_Bearers}    ue_control.Get all Bearer Ids
    [Return]    ${UE_Bearers}

Send DL data for both UEs for all two bearers
    Send DL data for UE    ue_id=${UE_ID_1}
    Send DL data for UE    ue_id=${UE_ID_2}

Send DL data for UE
    [Arguments]    ${ue_id}    ${bearers}=all
    ${bearer_id}    Get bearer ids for starting data transfer    ${ue_id}    ${bearers}
    Start DL Data Transfer   bearer=${bearer_id}   ue_id=${ue_id}
    ...    speed=${AP_DL_RATE}

Get bearer ids for starting data transfer
    [Arguments]    ${ue_id}    ${bearers}=all
    ${bearer_id}=    Run Keyword If
    ...    '${bearers}'=='all'    Get all bearer IDs for UE    ${ue_id}
    ...    ELSE    Set Variable    ${bearers}
    [Return]    ${bearer_id}

Send UL data for both UEs for all three bearers
    Send UL data for UE    ue_id=${UE_ID_1}
    Send UL data for UE    ue_id=${UE_ID_2}

Send UL data for UE
    [Arguments]    ${ue_id}    ${bearers}=all
    ${bearer_id}    Get bearer ids for starting data transfer    ${ue_id}    ${bearers}
    Start UL Data Transfer   bearer=${bearer_id}   ue_id=${ue_id}
    ...    speed=${AP_UL_RATE}

Trigger SgNBModification to Add Bearer
    [Arguments]    ${ue_id}    ${bearer_id}    ${qci}    ${scheduling_weight}
    wts.Add Bearer   ue_id=${ue_id}   bearer_id=${bearer_id}   filter=0   precedence=${bearer_id}
    Modify ENDC Add Bearer    ue_id=${ue_id}   bearer=${bearer_id}
    ue_control.Switch UE   ${ue_id}
    ue_control.Add Bearer To UE   bearer_id=${bearer_id}   qci=${qci}   weight=${scheduling_weight}

Send DL data for new bearer
    [Arguments]    ${ue_id}    ${bearer_id}
    Send DL data for UE    ue_id=${ue_id}    bearers=${bearer_id}

Get average throughput for all UE bearers
    [Arguments]    ${direction}
    Get average throughput for bearers    ${UE_ID_1}    ${direction}
    Get average throughput for bearers    ${UE_ID_2}    ${direction}

Get average throughput for bearers
    [Arguments]    ${ue_id}    ${direction}
    ${UE_Bearers}    Get all bearer IDs for UE    ${ue_id}
    @{bearer_list}    Split String    ${UE_Bearers}    ,
    FOR    ${bearer_id}    IN    @{bearer_list}
        ${bearer_data_rate}    run keyword if    '${direction}' == 'DL'
        ...    Get DL data transfer rate   bearer=${bearer_id}    ue_id=${ue_id}
        ...    ELSE    Get UL data transfer rate   bearer=${bearer_id}    ue_id=${ue_id}
        ue_control.Add Throughput To Bearer   bearer_id=${bearer_id}   throughput=${bearer_data_rate}
    END

Delete newly added bearer for UE1
    [Arguments]    ${ue_id}    ${bearer_id}    ${direction}
    Stop All Data Transfer    ue_id=${ue_id}    bearer=${bearer_id}
    run keyword and continue on failure    Wait Until Keyword Succeeds    300sec    30sec
    ...    Check if average data rate has become 0   ${ue_id}    ${bearer_id}    ${direction}
    Modify ENDC Release Bearer    ue_id=${ue_id}    bearer=${bearer_id}
    ue_control.Switch UE   ${ue_id}
    ue_control.Delete Bearer From Ue    bearer_id=${bearer_id}
    Sleep    ${BEARER_DELETE_TIMEOUT}

Check data rate ratio to scheduling weight ratio
    Get scheduling weight and data rate dictionary    ${UE_ID_1}
    Get scheduling weight and data rate dictionary    ${UE_ID_2}
    Check scheduling weight to datarate ratio for UEs

Get scheduling weight and data rate dictionary
    [Arguments]    ${ue_id}
    ue_control.Switch UE    ${ue_id}
    ${scheduling_weight_datarate_dict}    ue_control.get scheduling weight throughput dict
    set test variable  ${scheduling_weight_datarate_dict_${ue_id}}    ${scheduling_weight_datarate_dict}

Combine scheduling weight data rate dictionary for both UEs
    ${scheduling_weight_datarate_dict}    ue_control.store_scheduling_weight_throughput_dict_for_both_ues
    ...    ${scheduling_weight_datarate_dict_1}    ${scheduling_weight_datarate_dict_2}
    [Return]    ${scheduling_weight_datarate_dict}

Check scheduling weight to datarate ratio for UEs
    ${scheduling_weight_datarate_dict}    Combine scheduling weight data rate dictionary for both UEs
    Check data rate ratio of bearers according to scheduling weights    ${scheduling_weight_datarate_dict}

Change Scheduling Weight in NRDRB profile
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Update NRDRB profile    dist_name=${NRBTS_DISTNAME}/NRDRB-5    schedulWeight=4    &{NRDRB_LIST_PARAMETERS}
    Update NRDRB profile    dist_name=${NRBTS_DISTNAME}/NRDRB-6    schedulWeight=8    &{NRDRB_LIST_PARAMETERS}
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Wait for gNB To Be Ready

Enable Non-GBR service differentiation and modify NRDRB profile
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    actNonGbrServiceDiff=true
    Update NRDRB profile    dist_name=${NRBTS_DISTNAME}/NRDRB-4    schedulWeight=2    &{NRDRB_LIST_PARAMETERS}
    Update NRDRB profile    dist_name=${NRBTS_DISTNAME}/NRDRB-5    schedulWeight=4    &{NRDRB_LIST_PARAMETERS}
    Update NRDRB profile    dist_name=${NRBTS_DISTNAME}/NRDRB-6    schedulWeight=8    &{NRDRB_LIST_PARAMETERS}
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Wait for gNB To Be Ready

Test Teardown
    run keyword and ignore error    UE Detach   ${UE_ID_1}
    run keyword and ignore error    UE Detach   ${UE_ID_2}
    Common Test Teardown

Execute Delta Commissioning for Single UE MultiBearer
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Update feature flags
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}/NRCELL-1    dllaIniMcs=0
    Update NRDRB profile    dist_name=${NRBTS_DISTNAME}/NRDRB-5    schedulWeight=10    &{NRDRB_LIST_PARAMETERS}
    Update NRDRB profile    dist_name=${NRBTS_DISTNAME}/NRDRB-6    schedulWeight=1    &{NRDRB_LIST_PARAMETERS}
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Initialise Scheduling Weight to Data Rate Dictionary

SingleUEMultiBearer_UE
    ue_control.Create UE   ${UE_ID_1}
    ue_control.Add Bearer To UE   bearer_id=${DEFAULT_BEARER_ID}   qci=${DEFAULT_BEARER_ID}   weight=1
    ue_control.Add Bearer To UE   bearer_id=${NON_DEFAULT_BEARER_ID}   qci=${NON_DEFAULT_BEARER_ID}   weight=10

Get DL data rate for default and non default bearer
    ${default_bearer_data_rate}    Get DL data transfer rate   bearer=${DEFAULT_BEARER_ID}   ue_id=${UE_ID_1}
    Store scheduling weight and data rate    ${DEFAULT_SCHEDULING_WEIGHT}    ${default_bearer_data_rate}
    ${nondefault_bearer_data_rate}    Get DL data transfer rate   bearer=${NON_DEFAULT_BEARER_ID}   ue_id=${UE_ID_1}
    Store scheduling weight and data rate    ${NON_DEFAULT_SCHEDULING_WEIGHT}    ${nondefault_bearer_data_rate}

Check if average data rate has become 0
    [Arguments]    ${ue_id}    ${bearer_id}    ${direction}
    ${bearer_data_rate}    run keyword if    '${direction}' == 'DL'
    ...    Get DL data transfer rate   bearer=${bearer_id}    ue_id=${ue_id}
    ...    ELSE    Get UL data transfer rate   bearer=${bearer_id}    ue_id=${ue_id}
    Should Be Equal As Integers    ${bearer_data_rate}    0
