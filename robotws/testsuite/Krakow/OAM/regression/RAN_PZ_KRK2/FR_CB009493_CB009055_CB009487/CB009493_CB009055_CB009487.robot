*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    Maintainer: Slawomir Szopinski, slawomir.szopinski@nokia.com
...    CB009493_CB009055_CB009487

Resource    ./resources/keywords.robot
Resource    ./resources/UE_keywords.robot

Suite Setup    Common Suite Setup With OnAir Test Line Preparation
...            swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...            increase_timeout_for_update_sw=1800
...            prefix_tag=TL153
...            list_of_additional_allowed_alarms=Failure detected on assigned antennas

Test Setup     Run Keywords
...            Set Allowed Alarms For ASiR    AND
...            Common Preconditions    AND
...            Verify ASiR Alarms

*** Test Cases ***
# testsuite/Nanjing/OAM/CB009493_CB009055_CB009487/CB009493_CB009055_CB009487_CRT.robot
[1]CB009487-SR-C_TC01_1_supercell_with_3_100M_4T4R_sub-cells_on_Air
    Verify All Cells Are Operating Correctly
    Wait For All Cells To Be Operating Correctly On ASiR WebEM
    Verify ASiR Alarms
    [Teardown]    Common Postconditions

[1]CB009487-SR-C_TC02_1_supercell_with_3_100M_4T4R_sub-cells_DLUL_data_traffic
    Block Selected Cells For TC02
    Prepare Ue
    Run One Way UDP DL TC02 Data Transfer
    Run One Way UDP UL TC02 Data Transfer
    Unblock Selected Cells For TC02
    [Teardown]    Test Teardown For Cell Block TC02

[1]CB009487-SR-F_TC61_2_4T4R_100M_cell_via_TSN_data_traffic
    Should Be Equal As Strings    ${PREV_TEST_STATUS}    PASS
    [Teardown]    Common Postconditions

[1]CB009493-SR-H_TC16_H2_Call_NR_Cell_on_APHG
    Block Selected Cells For TC16
    Prepare Ue
    Run One Way UDP DL TC16 Data Transfer
    Run One Way UDP UL TC16 Data Transfer
    Unblock Selected Cells For TC16
    [Teardown]    Test Teardown For Cell Block TC16

[1]CB009493-SR-H_TC29_H4_BB_Reset_Lock_Unlock
    Log Current Time
    Reset BBMODs And Wait For All Cells To Be OnAir
    Verify Alarms After BBMOD Reset
    Log Current Time
    Lock BBMODs And Verify Locked Status
    Wait For All Cells Dependency Status
    Wait For All BTS Cells To Not Be Operating Correctly On ASiR WebEM
    Verify Alarms And Historic Alarms On BTS And ASiR
    Unlock BBMODs And Verify Online Status
    Verify ASIRMOD Status
    Wait For All Cells To Be Operating Correctly
    Verify Cell Status On ASiR WebEM
    Verify Alarms And Historic Alarms On BTS And ASiR
    [Teardown]    Test Teardown For BBMOD Block

[1]CB009493-SR-H_TC28_H4_NR_Cell_Block_Unblock
    Log Current Time
    Block All NR Cells On All ASiRHubs And Save Blocked Cell Count
    Verify Expected Number Of Faulty BTS Cell Status On ASiR WebEM
    Verify Alarms And Historic Alarms After Cell Block
    Unblock All NR Cells
    Verify Cell Status On ASiR WebEM
    Verify Alarms And Historic Alarms After All NR Cells Unblock
    [Teardown]    Test Teardown For Cell Block

[1]CB009493-SR-H_TC14_H2_ASiR_pRRH_Reset_Block_Unblock
    Log Current Time
    Reset All BTS Antennas
    Wait Until All BTS Antennas Are Available
    Wait For All Cells To Be Operating Correctly
    Verify Cell Status On ASiR WebEM
    Verify Alarms After Antenna Reset
    Log Current Time
    Block All BTS Antennas
    Wait Until All Antennas Are Blocked
    Verify Alarms After Antenna Block
    Unblock All BTS Antennas
    Wait Until All BTS Antennas Are Available
    Wait For All Cells To Be Operating Correctly On ASiR WebEM
    Verify Alarms And Historic Alarms After Antenna Unblock
    [Teardown]    Test Teardown For Antenna Block
