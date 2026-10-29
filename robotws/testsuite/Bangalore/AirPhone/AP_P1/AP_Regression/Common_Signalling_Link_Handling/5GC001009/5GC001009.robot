*** Settings ***
Documentation     author: Chandana
...               contact: chandana.m_s@nokia.com
Suite Setup       ReachOnAir
Suite Teardown    Suite Teardown
Test Setup        TestSetup
Test Teardown     TestTeardown
Library           Collections
Library           ute_wtssim
Library           ../../../Resources/Python/ScfHelper.py    WITH NAME    scf_helper
Resource          ../../../Resources/robot/gnb.robot
Resource          ../../../Resources/robot/ute_setup.robot
Resource          ../../../Resources/robot/wts.robot
Resource          ../../../Resources/Variables/Common_Variables.robot
Resource          ../../../Resources/robot/suite_common_keywords.robot

*** Variables ***
&{param_dict}         gtpuManagementDscp=50

*** Test Cases ***
Verify MRBTSNRBTSgtpuManagementDscp is modified without gNB reboot
    [Tags]    CIT
    Enable gtpuManagementDscp parameter
    Check if gNB is reachable    ${GNB_IP}
    Wait for gNB To Be Ready
    Ensure Egate state
    Establish X2 link And Wait For Cell Setup
    [Teardown]    Run Keywords    Disable gtpuManagementDscp parameter
    ...           AND             TestTeardown

Verify gtpuManagementDscp is modified without gNB reboot
    [Tags]    CIT
    Enable actDlDataForwardingX2 parameter
    Check if gNB is reachable    ${GNB_IP}
    Wait for gNB To Be Ready
    Ensure Egate state
    Establish X2 link And Wait For Cell Setup
    [Teardown]    Run Keywords    Disable actDlDataForwardingX2 parameter
    ...           AND             TestTeardown

*** Keywords ***
ReachOnAir
    Suite Common Keywords    feature_folder=5GC001009
    Wait for gNB To Be Ready
    Prepare Environment Based On Run Type

Enable gtpuManagementDscp parameter
    ${scf_path}    admin_helper.download current scf file
    ${gtp_value}    scf_helper.get_feature_paramters_from_scf    ${scf_path}    ${param_dict}      ${NRBTS_DISTNAME}
    admin.Create Delta    delta_id=E1link
    admin.Append Parameter Update To Delta    delta_id=E1link    dist_name=${NRBTS_DISTNAME}
    ...    parameter=gtpuManagementDscp    value=50
    ${e1link_delta}=    admin.Get Delta    delta_id=E1link
    Recommission GNB With Delta    ${e1link_delta}
    Set Test Variable    ${gtp_value}

Disable gtpuManagementDscp parameter
    admin.Create Delta    delta_id=disable_E1link
    ${val}    Get From Dictionary    ${gtp_value}    gtpuManagementDscp
    admin.Append Parameter Update To Delta    delta_id=disable_E1link    dist_name=${NRBTS_DISTNAME}
    ...    parameter=gtpuManagementDscp    value=${val}
    ${e1link_delta}=    admin.Get Delta    delta_id=disable_E1link
    Recommission GNB With Delta    ${e1link_delta}

Enable actDlDataForwardingX2 parameter
    admin.Create Delta    delta_id=E1link_delta
    admin.Append Parameter Update To Delta    delta_id=E1link_delta    dist_name=${NRBTS_DISTNAME}
    ...    parameter=actDlDataForwardingX2    value=false
    ${e1_delta}=    admin.Get Delta    delta_id=E1link_delta
    Recommission GNB With Delta    ${e1_delta}

Disable actDlDataForwardingX2 parameter
    admin.Create Delta    delta_id=disable_E1link_delta
    admin.Append Parameter Update To Delta    delta_id=disable_E1link_delta    dist_name=${NRBTS_DISTNAME}
    ...    parameter=actDlDataForwardingX2    value=true
    ${e1_delta}=    admin.Get Delta    delta_id=disable_E1link_delta
    Recommission GNB With Delta    ${e1_delta}

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
