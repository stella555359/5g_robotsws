*** Settings ***
Documentation     Test cases for 5GC000795 feature
Suite Setup       ReachOnAir
Suite Teardown    Suite Teardown
Test Setup        Test Setup
Test Teardown     Test Teardown
Library           OperatingSystem
Library           DateTime
Library           ute_wtssim
Resource          ../../../Resources/robot/gnb.robot
Resource          ../../../Resources/robot/ute_setup.robot
Resource          ../../../Resources/robot/wts.robot
Resource          ../../../Resources/Variables/Common_Variables.robot
Resource          ../../../Resources/robot/suite_common_keywords.robot

*** Variables ***
${WTS_CFG_PATH}    ${CURDIR}/cfg
${MULTI_BEARER_ID}    2,8
${NON_DEFAULT_BEARER_ID}    8
${FILTER}   7
${PRECEDENCE}   18
${BEARER_WITH_LOW_THROUGHPUT}   7
${MULTI_BEARER_ID_LOW_THROUGHPUT}   2,7
${UPDATED_SPEED}   10

*** Test Cases ***
1_Add Multiple Bearer in NSA using SGNB Addition
    [Tags]    CIT
    Attach UE To Default Profile
    Add Non Default Bearer
    SGNB Addition With Multiple Bearer
    Start Data Transfer And Verify Throughput on Non Default Bearer
    ENDC Release Non Default Bearer
    Start Data Transfer And Verify Throughput on Default Bearer
    Detach Default UE

2_Add And Release Bearer in NSA using SGNB Modification
    [Tags]    CIT
    Attach UE To Default Profile
    Add Non Default Bearer
    SGNB Addition With Default Bearer
    Start Data Transfer And Verify Throughput on Default Bearer
    ENDC Add Non Default Bearer
    Start Data Transfer And Verify Throughput on Non Default Bearer
    ENDC Release Non Default Bearer
    Detach Default UE

*** Keywords ***
ReachOnAir
    Suite Common Keywords    feature_folder=5GC000795
    Wait for gNB To Be Ready
    Enable MultiDRB Feature
    Wait for gNB To Be Ready
    Prepare Environment Based On Run Type     cfg_type=custom

Enable MultiDRB Feature
    admin.Create Delta    delta_id=multidrb
    admin.Append Parameter Update To Delta    delta_id=multidrb    dist_name=${NRBTS_DISTNAME}    parameter=actMultiDrbNSA    value=true
    ${multidrb_delta}=    admin.Get Delta    delta_id=multidrb
    Recommission GNB With Delta    delta_file=${multidrb_delta}

Disable MultiDRB Feature
    admin.Create Delta    delta_id=disable_multidrb
    admin.Append Parameter Update To Delta    delta_id=disable_multidrb    dist_name=${NRBTS_DISTNAME}    parameter=actMultiDrbNSA    value=false
    ${diable_multidrb_delta}=    admin.Get Delta    delta_id=disable_multidrb
    Recommission GNB With Delta    delta_file=${diable_multidrb_delta}

CleanUp
    Run Keyword And Ignore Error   Detach Default UE
    Stop Sim
    Teardown All Aliases For Wts

Suite Teardown
    Common Suite Teardown Keywords
    Disable MultiDRB Feature
    Wait for gNB To Be Ready

Attach UE To Default Profile
   UE Attach    ue_id=${UE_ID}    profile_id=${PROFILE_ID}

Add Non Default Bearer
   Add Bearer    ue_id=${UE_ID}    bearer_id=${NON_DEFAULT_BEARER_ID}
   ...           filter=${FILTER}    precedence=${PRECEDENCE}

SGNB Addition With Multiple Bearer
   SGNB Addition For Bearer    ue_id=${UE_ID}    target_gnb=${GNB_ID}
   ...    target_cells=${CELL_ID}    bearer=${MULTI_BEARER_ID}

SGNB Addition With Default Bearer
   SGNB Addition For Bearer    ue_id=${UE_ID}    target_gnb=${GNB_ID}
   ...    target_cells=${CELL_ID}    bearer=${BEARER_ID}

Start Data Transfer And Verify Throughput on Non Default Bearer
   Start Data Transfer And Verify Throughput    bearer=${NON_DEFAULT_BEARER_ID}    ue_id=${UE_ID}
   Stop All Data Transfer    ${UE_ID}    bearer=${NON_DEFAULT_BEARER_ID}

Start Data Transfer And Verify Throughput on Default Bearer
   Start Data Transfer And Verify Throughput    bearer=${BEARER_ID}    ue_id=${UE_ID}
   Stop All Data Transfer    ${UE_ID}    bearer=${BEARER_ID}

Detach Default UE
   UE Detach    ${UE_ID}

ENDC Release Non Default Bearer
   Modify ENDC Release Bearer   ${UE_ID}    bearer=${NON_DEFAULT_BEARER_ID}

ENDC Add Non Default Bearer
   Modify ENDC Add Bearer    ${UE_ID}    ${NON_DEFAULT_BEARER_ID}

Test Setup
    Create Test Case Folder
    Start pcap collection in gNB and WTS
    Start WTS And Extablish X2 Link

Test Teardown
    Common Test Teardown
