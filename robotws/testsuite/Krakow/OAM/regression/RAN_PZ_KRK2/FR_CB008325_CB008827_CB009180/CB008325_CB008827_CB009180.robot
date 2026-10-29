*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    Maintainer: Slawomir Szopinski, slawomir.szopinski@nokia.com
...    Description: CB008325/CB008827 LTE FDD Max Cell/Hub with ABIP automation cases

Resource    ./resources/keywords.robot
Resource    ./resources/UE_keywords.robot

Suite Setup      Common Suite Setup With OnAir Test Line Preparation
...              swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...              increase_timeout_for_update_sw=1800
...              prefix_tag=TL342
...              list_of_additional_allowed_alarms=Failure detected on assigned antennas

Test Setup       Run Keywords
...              Set Allowed Alarms For ASiR    AND
...              Common Preconditions    AND
...              Verify ASiR Alarms

Test Teardown    Run Keywords
...              Verify ASiR Alarms    AND
...              Common Postconditions

*** Test Cases ***
# testsuite/Nanjing/OAM/CB008325_8827/CB008325_8827_LTE_ABIP_CRT.robot
[1]CB008325_4G_A_TC01_up_to_24cell_2T2R_perABIP_with_IQC_CB006151_A
    Reset BTS And Wait For All Cells To Be Operational
    Wait For All Cells To Be Operating Correctly On ASiR WebEM

[1]CB008325_4G_A_TC02_HUB_reset_up_to_4cell_2T2R_perHub_with_IQC_CB006151_A
    Log Current Time
    Reset All BTS ASIRMODs
    Wait For All BTS ASIRMOD Modules To Be Operational
    Wait For All Cells To Be Operating Correctly
    Verify Cell Status On ASiR WebEM
    Verify Alarms After ASIRMOD Reset

[1]CB008325_4G_A_TC03_BB_lock_unlock_up_to_24cell_2T2R_perABIP_with_IQC_CB006151_A
    Log Current Time
    Lock BBMODs And Verify Locked Status
    Verify ASIRMOD Status
    Wait For All Cells To Be In Expected Status During BBMOD Lock
    Verify Faulty BTS Cell Status On ASiR WebEM
    Verify Alarms After All BBMOD Lock
    Unlock BBMODs And Verify Online Status
    Verify ASIRMOD Status
    Wait For All Cells To Be Operating Correctly
    Verify Cell Status On ASiR WebEM
    Verify Alarms And Historic Alarms On BTS And ASiR
    [Teardown]    Test Teardown For BBMOD Block

[1]CB008325_4G_A_TC04_BB_Reset_up_to_24cell_2T2R_perABIP_with_IQC_CB006151_A
    Log Current Time
    Reset BBMODs And Wait For All Cells To Be OnAir
    Wait For All Cells To Be Operating Correctly On ASiR WebEM
    Verify Alarms And Historic Alarms After All BBMOD Reset

[1]CB008325_4G_A_TC07_UE_Attach_to_single_SFN_AsiR-pRRH_on_20MHz_run_DL_tput_CB006151_D
    Block Selected Cells For TC07
    Prepare Ue For TC07
    Run One Way UDP DL TC07 Data Transfer
    Run One Way UDP UL TC07 Data Transfer
    Unblock Selected Cells For TC07

[1]CB008827_5G_J_TC03_Cell_lock_unlock_with_call_for_LTE_FDD_2supercells_with_6subcells_for_Band1_2T2R_20M_CB006151_B
    Block Selected Cells For TC03
    Block Super Cell
    Unblock Super Cell
    Prepare Ue For TC03
    Run One Way UDP DL TC03 Data Transfer
    Run One Way UDP UL TC03 Data Transfer
    Unblock Selected Cells For TC03
    [Teardown]    Test Teardown For Super Cell Block

[1]CB009180-SR-C_TC05_ANTMOD_Block_unblock
    Log Current Time
    Block All BTS Antennas
    Wait Until All Antennas Are Blocked
    Wait For And Verify Alarms After All Antenna Block
    Wait For All Cells To Be In Failed Status
    Verify Faulty BTS Cell Status On ASiR WebEM
    Unblock All BTS Antennas
    Wait Until All BTS Antennas Are Available
    Wait For All Cells To Be Operating Correctly
    Verify Cell Status On ASiR WebEM
    Verify Alarms And Historic Alarms After Antenna Unblock
