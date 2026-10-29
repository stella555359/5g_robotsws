*** Settings ***
Documentation
...    author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    maintainer:
...    CB009027_CB009028-subcase2

Resource    ./resources/keywords.robot
Resource    ./resources/UE_keywords.robot

Suite Setup      Common Suite Setup With OnAir Test Line Preparation
...              swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...              increase_timeout_for_update_sw=1800
...              prefix_tag=TL172_sub2

Test Setup       Run Keywords
...              Set Allowed Alarms For ASiR    AND
...              Common Preconditions    AND
...              Verify ASiR Alarms

*** Test Cases ***
# testsuite/Nanjing/OAM/CB009027_CB009028_CB008325/CB009027_CB009028-subcase2_CRT.robot
[1.0] CB009027_5G_J_TC017_ASiR_pRRH_reset_Block_UnBlock_NR
    Log Current Time
    Reset All BTS Antennas
    Wait Until All BTS Antennas Are Available
    Wait For All Cells To Be Operating Correctly
    Wait For All Cells To Be Operating Correctly On ASiR WebEM
    Verify Historic Alarms After Antenna Reset
    Block Selected Cells For TC17 Subcase2
    Prepare Ue For TC 17
    Run One Way UDP DL TC17 Subcase2 Data Transfer
    Run One Way UDP UL TC17 Subcase2 Data Transfer
    Unblock Selected Cells For TC17 Subcase2
    Log Current Time
    Block All BTS Antennas
    Wait Until All Antennas Are Blocked
    Verify Alarms After Antenna Block
    Unblock All BTS Antennas
    Wait Until All BTS Antennas Are Available
    Wait For All Cells To Be Operating Correctly
    Wait For All Cells To Be Operating Correctly On ASiR WebEM
    Verify Alarms And Historic Alarms After Cell And NBIoT Cell Unlock
    Block Selected Cells For TC17 Subcase2
    Run One Way UDP DL TC17 Subcase2 Data Transfer
    Run One Way UDP UL TC17 Subcase2 Data Transfer
    Unblock Selected Cells For TC17 Subcase2
    [Teardown]    Test Teardown For Single NR Cell And LTE Cell Block
