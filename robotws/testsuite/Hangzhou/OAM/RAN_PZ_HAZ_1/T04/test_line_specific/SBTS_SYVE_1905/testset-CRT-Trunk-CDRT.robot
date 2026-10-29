*** Settings ***
Documentation       Test suite for SBTS1905
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout    4h
Variables     My_Variables.py
Variables     ../Variables/NetActs.py
Resource    ../../test_resources/SyVe/SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1025    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${SCF_ID}    01

*** Test Cases ***
SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262826    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    2h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}
    ...    [2.0] LTE4934-A_ST_05_17_CM provision to trigger CCN upload by modify create and delete parameter
    ...    AND    Set Test Variable    ${qc_instance_id}    262826
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    ...    AND    Set Library Search Order    SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    TC__SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    [Teardown]    Run Keywords    SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_122388   CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
    [Timeout]    2h
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${qc_instance_id}    122388
    ...    AND    Set Test Variable    ${test_run}
    ...    [1]RAN_ST_CB009175_001_CM_Configure new internal antenna MAA NRCELL Channel Groups and Channels using Simplified method from MantaRay
    ...    AND    SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay
    ...    AND    Set Library Search Order    SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay
    SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay
    [Teardown]    Run Keywords    SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay.TC Teardown
    ...    AND    Restore Resource Search Order