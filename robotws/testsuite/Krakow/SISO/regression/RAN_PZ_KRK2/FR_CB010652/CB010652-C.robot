*** Settings ***
Documentation
...    author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    maintainer: Slawomir Szopinski, slawomir.szopinski@nokia.com

Force Tags    RF50

Resource    ./resources/keywords.robot

Suite Setup      Common Suite Setup With OnAir Test Line Preparation
...              swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...              increase_timeout_for_update_sw=900
...              increase_time_for_checking_cells=600
...              prefix_tag=CB010652-C
Suite Teardown   Common Suite Teardown

Test Setup       Run Keywords
...              Set Allowed Alarms For ASiR    AND
...              Common Preconditions With Watching Alarms    AND
...              Setup Attenuators    AND
...              Verify ASiR Alarms
Test Teardown    Common Postconditions With Watching Alarms

*** Variables ***
${CONFIG}    C

*** Test Cases ***
[1][1.0] CB010652_ASiR_pRRH_Reset_with_ASiRWebEM
    Log Current Time
    Allow Alarms For ANTMOD Operations
    Reset All ANTMODs On ASiR WebEM
    Wait Until All BTS Antennas Are Available
    Wait For All Cells To Be Operating Correctly
    Verify Cell Status On ASiR WebEM
    Verify Alarms After Antenna Reset
    Run Throughput On All Cells One By One
    [Teardown]    Disallow Alarms For ANTMOD Operations With Common Postconditions

[1][1.0] General_SiSo_Auto_gNB_Site_Reset_From_WebUI
    Allow Alarm For Site Reset
    Reset BTS Via WebEM
    Wait For All Cells To Be Operating Correctly
    Verify Cell Status On ASiR WebEM
    [Teardown]    Disallow Alarms For Site Reset With Common Postconditions And Logout From Gui

[1][3.0] General_SiSo_Cell_block_and_unblock
    Allow Alarm For Cells Block
    Block And Unblock All Cells One By One Via WebEM
    Wait For All Cells To Be Operating Correctly
    Verify Cell Status On ASiR WebEM
    Run Throughput On All Cells One By One
    [Teardown]    Disallow Alarms For Cells Block With Common Postconditions And Logout From Gui

[1][1.0] General_SiSo_Auto_RU_module_reset_from_GUI
    Reset All BTS Antennas Via WebEM
    Wait For All Cells To Be Operating Correctly
    Verify Cell Status On ASiR WebEM
    Allow Alarm For Cells Block
    Run Throughput On All Cells One By One
    [Teardown]    Common Postconditions And Logout From Gui

[1][1.0] CB010652_ASiR_pRRH_Block_Unblock_with_ASiRWebEM
    Log Current Time
    Allow Alarms For ANTMOD Operations
    Block And Unblock All ANTMODs One By One On ASiR WebEM
    Wait Until All BTS Antennas Are Available
    Wait For All Cells To Be Operating Correctly
    Verify Cell Status On ASiR WebEM
    Verify Alarms After Antenna Block
    Run Throughput On All Cells One By One
    [Teardown]    Disallow Alarms For ANTMOD Operations With Common Postconditions
