*** Settings ***
Documentation
...    :copyright: Nokia
...    :contact: I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Resource    ${CURDIR}${/}..${/}..${/}resources_btc/suite_setup.robot
Resource    ${CURDIR}${/}..${/}..${/}resources_btc/suite_teardown.robot
Resource    ${CURDIR}${/}..${/}..${/}resources_btc/suite_run.robot

Suite Setup     Suite Setup
Suite Teardown  Suite Teardown

*** Test Cases ***

LTE2202_MAC_UE_Throughput_MR_activation_and_deactivation_ct
    [Tags]  SKIP_REPORT
    Run Suite 'LTE2202_MAC_UE_Throughput_MR/test_LTE2202_MAC_UE_Throughput_MR_activation_and_deactivation_ct.py'
LTE2202_MAC_UE_Throughput_MR_activation_and_deactivation_mdt
    [Tags]  SKIP_REPORT
    Run Suite 'LTE2202_MAC_UE_Throughput_MR/test_LTE2202_MAC_UE_Throughput_MR_activation_and_deactivation_mdt.py'
LTE2202_MAC_UE_Throughput_MR_UE_HO_Fail
    [Tags]  SKIP_REPORT
    Run Suite 'LTE2202_MAC_UE_Throughput_MR/test_LTE2202_MAC_UE_Throughput_MR_UE_HO_Fail.py'
LTE2202_MAC_UE_Throughput_MR_UE_Inter_Cell_HO
    [Tags]  SKIP_REPORT
    Run Suite 'LTE2202_MAC_UE_Throughput_MR/test_LTE2202_MAC_UE_Throughput_MR_UE_Inter_Cell_HO.py'
LTE2202_MAC_UE_Throughput_MR_UE_IntraCell_HO
    [Tags]  SKIP_REPORT
    Run Suite 'LTE2202_MAC_UE_Throughput_MR/test_LTE2202_MAC_UE_Throughput_MR_UE_IntraCell_HO.py'
LTE2202_MAC_UE_Throughput_MR_UE_Reestablishment
    [Tags]  SKIP_REPORT
    Run Suite 'LTE2202_MAC_UE_Throughput_MR/test_LTE2202_MAC_UE_Throughput_MR_UE_Reestablishment.py'
LTE2202_MAC_UE_Throughput_MR_UE_RLF_Triggered_HO
    [Tags]  SKIP_REPORT
    Run Suite 'LTE2202_MAC_UE_Throughput_MR/test_LTE2202_MAC_UE_Throughput_MR_UE_RLF_Triggered_HO.py'
LTE2202_MAC_UE_Throughput_MR_UE_S1_HO
    [Tags]  SKIP_REPORT
    Run Suite 'LTE2202_MAC_UE_Throughput_MR/test_LTE2202_MAC_UE_Throughput_MR_UE_S1_HO.py'
LTE2202_MAC_UE_Throughput_MR_UE_X2_HO
    [Tags]  SKIP_REPORT
    Run Suite 'LTE2202_MAC_UE_Throughput_MR/test_LTE2202_MAC_UE_Throughput_MR_UE_X2_HO.py'
