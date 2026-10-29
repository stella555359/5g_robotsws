*** Settings ***
Documentation       Test suite for SBTS37376
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout      24h
Variables         My_Variables.py
Variables         ../Variables/NetActs.py
Resource          ../../test_resources/SyVe/SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored.robot
Resource          ../../test_resources/SyVe/SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled.robot
Resource          ../../test_resources/SyVe/SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost.robot
Resource          ../../test_resources/SyVe/SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts.robot

*** Variables ***
${SRNCLAB}        SRNCLAB1028    # Netact info defined in NetActs.py under Variables folder
${NETACT}         &{${SRNCLAB}}
${SCF_ID}         01

*** Test Cases ***
SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_110792    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Timeout]    3h
    [Setup]    Run Keywords    Set Test Variable
    ...    ${test_run}    [1.0] RAN_ST_CB012523-B_001_Cell graceful shutdown when M-Plane connection toward NMS is lost.
    ...    AND    Set Test Variable    ${qc_instance_id}    110792
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored
    ...    AND    Set Library Search Order    SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored
    SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored
    [Teardown]    Run Keywords    SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_110784    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Timeout]    3h
    [Setup]    Run Keywords    Set Test Variable
    ...    ${test_run}    [1.0] RAN_ST_CB012523-B_005_Prevent enable cells that has been disabled for another reason
    ...    AND    Set Test Variable    ${qc_instance_id}    110784
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled
    ...    AND    Set Library Search Order    SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled
    SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled
    [Teardown]    Run Keywords    SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_110793    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Timeout]    3h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RAN_ST_CB012523-B_004_Enable feature when NMS connection is already lost
    ...    AND    Set Test Variable    ${qc_instance_id}    110793
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost
    ...    AND    Set Library Search Order    SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost
    SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost
    [Teardown]    Run Keywords    SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_110785    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Timeout]    3h
    [Setup]    Run Keywords    Set Test Variable
    ...    ${test_run}    [1.0] RAN_ST_CB012523-B_006_Prevent enable cells with status unlocked in case gNB restarts
    ...    AND    Set Test Variable    ${qc_instance_id}    110785
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts
    ...    AND    Set Library Search Order    SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts
    SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts
    [Teardown]    Run Keywords    SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts.TC Teardown
    ...    AND    Restore Resource Search Order

