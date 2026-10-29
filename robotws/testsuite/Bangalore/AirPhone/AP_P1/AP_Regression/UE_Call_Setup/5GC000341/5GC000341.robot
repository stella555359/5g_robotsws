*** Settings ***
Documentation       This suite contains 5GC000341 test cases

Suite Setup       ReachOnAir
Suite Teardown    Suite Teardown
Test Setup        TestSetup
Test Teardown     TestTeardown
Library           ute_wtssim
Resource          ../../../Resources/robot/gnb.robot
Resource          ../../../Resources/robot/ute_setup.robot
Resource          ../../../Resources/robot/wts.robot
Resource          ../../../Resources/Variables/Common_Variables.robot
Resource          ../../../Resources/robot/suite_common_keywords.robot
Library           ../../../Resources/Python/DeltaStore.py    WITH NAME    delta_store

*** Test Cases ***
TC07_Verify_dllaIniMcs_linkAdapation_Online_Modification
    [Documentation]    Verify that "dllaIniMcs" downlink link adaptation parameters are online modifiable
    ...    from the Elements manager web GUI with out 5G GNB restart.
    [Tags]    CRT
    Modify dllaIniMcs parameter
    Check if gNB is reachable    ${GNB_IP}
    Wait for gNB To Be Ready
    Ensure Egate state
    Establish X2 link And Wait For Cell Setup
    [Teardown]    Run Keywords    Revert dllaIniMcs parameter
    ...    AND    TestTeardown

TC10_Verify_ullaDeltaSinrStepDown_linkAdaptation_NIDD_Parameter_Online_Modification
    [Documentation]    Verify that "ullaDeltaSinrStepDown"  uplink link adaptation NIDD parameters are online modifiable
    ...    from the Elements manager web GUI with out 5G GNB restart.
    [Tags]    CRT
    Modify ullaDeltaSinrStepDown parameter
    Check if gNB is reachable    ${GNB_IP}
    Wait for gNB To Be Ready
    Ensure Egate state
    Establish X2 link And Wait For Cell Setup
    [Teardown]    Run Keywords    Revert ullaDeltaSinrStepDown parameter
    ...    AND    TestTeardown

*** Keywords ***
ReachOnAir
    Suite Common Keywords    feature_folder=5GC000341
    Wait for gNB To Be Ready
    Prepare Environment Based On Run Type

Modify dllaIniMcs parameter
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}    dllaIniMcs=25
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}

Revert dllaIniMcs parameter
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}    dllaIniMcs=3
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}

Modify ullaDeltaSinrStepDown parameter
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}    ullaDeltaSinrStepdown=750
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}

Revert ullaDeltaSinrStepDown parameter
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}    ullaDeltaSinrStepdown=250
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}

TestSetup
    Create Test Case Folder
    Start and configure WTS
    Ensure Egate state
    Establish X2 link And Wait For Cell Setup

TestTeardown
    Wait for gNB To Be Ready
    Common Test Teardown

Suite Teardown
    Common Suite Teardown Keywords
