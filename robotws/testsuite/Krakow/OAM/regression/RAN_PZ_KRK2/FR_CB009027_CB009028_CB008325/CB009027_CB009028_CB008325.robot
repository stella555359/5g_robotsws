*** Settings ***
Documentation
...    author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    maintainer:
...    CB009027_CB009028_CB008325-subcase1

Resource    ./resources/keywords.robot
Resource    ./resources/UE_keywords.robot

Suite Setup      Common Suite Setup With OnAir Test Line Preparation
...              swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...              increase_timeout_for_update_sw=1800
...              prefix_tag=TL172_sub1

Test Setup       Run Keywords
...              Set Allowed Alarms For ASiR    AND
...              Common Preconditions    AND
...              Verify ASiR Alarms

Test Teardown    Run Keywords
...              Verify ASiR Alarms    AND
...              Common Postconditions

*** Test Cases ***
# testsuite/Nanjing/OAM/CB009027_CB009028_CB008325/CB009027_CB009028_CB008325-subcase1_CRT.robot
[1.0] CB009028_5G_J_TC015_5903_Subcase1_LTE_cfg1_ssp_tm3_Ue_attach_peak_udp_tput
    Block Selected Cells For TC15
    Prepare Ue For TC15
    Run One Way UDP DL TC15 Data Transfer
    Run One Way UDP UL TC15 Data Transfer
    Unblock Selected Cells For TC15
    [Teardown]    Test Teardown For Two NR Cells Block

[1.0] CB008325_5G_AJ_TC011_General_SiSo_Cells_block_unblock
    Log Current Time
    Block All NR Cells On All ASiRHubs And Save Blocked Cell Count
    Verify Expected Number Of Faulty BTS Cell Status On ASiR WebEM
    Verify Alarms And Historic Alarms After Cell Block
    Unblock All NR Cells
    Wait For All Cells To Be Operating Correctly On ASiR WebEM
    Verify Alarms And Historic Alarms After All NR Cells Unblock
    [Teardown]    Test Teardown For Cell Block

[1.0] CB008325_5G_AJ_TC017_E2E_system_setup_with_data_transfer_conducted_singleUE_peak_tput_BW_100M_4T4R_ABIP_3hub
    Block Selected Cells For TC17
    Prepare Ue For TC17
    Run One Way UDP DL TC17 Data Transfer
    Run One Way UDP UL TC17 Data Transfer
    Unblock Selected Cells For TC17
    [Teardown]    Test Teardown For Single NR Cell And LTE Cell Block

[1.0] CB008325_5G_AJ_TC024_General_SiSo_ASiR_ANTs_reset_via_ASiRWebEM
    Log Current Time
    Reset All BTS Antennas
    Wait Until All BTS Antennas Are Available
    Wait For All Cells To Be Operating Correctly
    Wait For All Cells To Be Operating Correctly On ASiR WebEM
    Verify Alarms After Antenna Reset

[1.0] CB008325_5G_AJ_TC025_General_SiSo_ASiR_ANTs_block_unblock_via_ASiRWebEM
    Log Current Time
    Block All BTS Antennas
    Wait Until All Antennas Are Blocked
    Verify Alarms After Antenna Block
    Wait For All BTS Cells To Not Be Operating Correctly On ASiR WebEM
    Unblock All BTS Antennas
    Wait Until All BTS Antennas Are Available
    Wait For All Cells To Be Operating Correctly
    Wait For All Cells To Be Operating Correctly On ASiR WebEM
    Verify Alarms And Historic Alarms After Antenna Unblock
    [Teardown]    Test Teardown For Antenna Block
