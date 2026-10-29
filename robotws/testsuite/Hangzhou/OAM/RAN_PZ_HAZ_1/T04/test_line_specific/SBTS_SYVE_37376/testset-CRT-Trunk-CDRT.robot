*** Settings ***
Documentation       Test suite for SBTS37376
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout      12h
Variables         My_Variables.py
Variables         ../Variables/NetActs.py
Resource          ../../test_resources/CM/CM__CB009939-A_009_010_Do_Controlled_Switchover_And_Disable_Redundancy.robot
Resource          ../../test_resources/CM/CM__CB009939-D_004_CM_Trigger_Automatic_Switchover_When_minCellAvailability_Is_Met.robot

*** Variables ***
${SRNCLAB}        SRNCLAB1028    # Netact info defined in NetActs.py under Variables folder
${NETACT}         &{${SRNCLAB}}
${SCF_ID}         01

*** Test Cases ***
CM__CB009939-A_009_010_Do_Controlled_Switchover_And_Disable_Redundancy
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33052    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
	...    [1.0] RAN_SyVe_CB009939-A-B5_009_CM_Controlled switchover manually when BTS1 is standby and BTS2 is active
    ...    AND    Set Test Variable    ${qc_instance_id}    33052
    ...    AND    Modify Resource Search Order    CM__CB009939-A_009_010_Do_Controlled_Switchover_And_Disable_Redundancy
    ...    AND    Set Library Search Order    CM__CB009939-A_009_010_Do_Controlled_Switchover_And_Disable_Redundancy
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    [Timeout]    2h
    CM__CB009939-A_009_010_Do_Controlled_Switchover_And_Disable_Redundancy
    [Teardown]    Run Keywords    CM__CB009939-A_009_010_Do_Controlled_Switchover_And_Disable_Redundancy.Case Special Teardown
    ...    AND    Restore Resource Search Order

CM__CB009939-D_004_CM_Trigger_Automatic_Switchover_When_minCellAvailability_Is_Met
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_50493    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
	...    [1.0] RAN_SyVe_CB009939-D_004_CM_Trigger successful automatic switchover when minCellAvailability condition is met
    ...    AND    Set Test Variable    ${qc_instance_id}    50493
    ...    AND    Modify Resource Search Order    CM__CB009939-D_004_CM_Trigger_Automatic_Switchover_When_minCellAvailability_Is_Met
    ...    AND    Set Library Search Order    CM__CB009939-D_004_CM_Trigger_Automatic_Switchover_When_minCellAvailability_Is_Met
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    [Timeout]    2h
    CM__CB009939-D_004_CM_Trigger_Automatic_Switchover_When_minCellAvailability_Is_Met
    [Teardown]    Run Keywords    CM__CB009939-D_004_CM_Trigger_Automatic_Switchover_When_minCellAvailability_Is_Met.Case Special Teardown
    ...    AND    Restore Resource Search Order