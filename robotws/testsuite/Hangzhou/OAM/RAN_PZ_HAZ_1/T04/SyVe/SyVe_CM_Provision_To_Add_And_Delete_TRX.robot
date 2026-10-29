*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    3h
Variables      ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_Provision_To_Add_And_Delete_TRX.robot

*** Test Cases ***
SyVe_CM_Provision_To_Add_And_Delete_TRX
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_583923    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_LWG_1ASIL_2ABIA_1ASIL_2ABIA_1ABIN_1AHFIG_1AHDB_1910
    [Timeout]    2h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}
    ...    [1][1.0] RmtOAM_CM_Provision_SBTS_Delta_Plan_To_Add_And_Delete_TRX_Automated
    ...    AND    Set Test Variable    ${qc_instance_id}    583923
    ...    AND    Set Library Search Order    XML
    ...    AND    Set Test Variable    @{CHANNELGROUP_TO_REMOVE}    LCELC-1/CHANNELGROUP-2    LCELC-1/CHANNELGROUP-3    LCELC-2/CHANNELGROUP-3
    ...    LCELC-2/CHANNELGROUP-2    LCELC-3/CHANNELGROUP-2    LCELC-3/CHANNELGROUP-3
    ...    AND    Set Test Variable    ${CHANGED_TRX_NUM}    2
    ...    AND    Modify Resource Search Order    SyVe_CM_Provision_To_Add_And_Delete_TRX
    ...    AND    Set Library Search Order    SyVe_CM_Provision_To_Add_And_Delete_TRX
    ...    AND    SyVe_CM_Provision_To_Add_And_Delete_TRX.TC Setup
    TC__SyVe_CM_Provision_To_Add_And_Delete_TRX
    [Teardown]    Run Keywords    SyVe_CM_Provision_To_Add_And_Delete_TRX.TC Teardown
    ...    AND    Restore Resource Search Order