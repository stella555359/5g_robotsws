*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    Maintainer: Slawomir Szopinski, slawomir.szopinski@nokia.com
...    CB010731-SR


Resource          ./resources/keywords.robot

Test Setup       Run Keywords
...              Set Allowed Alarms    AND
...              Set Allowed Alarms For ASiR    AND
...              Common Preconditions    AND
...              Verify ASiR Alarms

Test Teardown    CB010731 Test Teardown

*** Test Cases ***
[1]CB010731-A_ET_01_ASiR_HUB_application_service_privileges_check_HUB_reset_cell_block
    Check New User Accounts And Groups Exist On All Hubs
    Reset All sHUBs In WebEM
    Block And Unblock All Cells
    Perform RF Diagnostic Test On BTS WebEM
    Verify Active BTS Alarms After RF Diagnostic Test

[1]CB010731-A_ET_01_ASiR_HUB_application_service_privileges_check_ASiR_HUB_reset
    Check New User Accounts And Groups Exist On All Hubs
    Reset All HUBMODs On ASiR WebEM
    Wait Until All HUBs Are Operating Correctly
    Wait For All Cells To Be Operating Correctly
    Verify Active And Historic Alarms After HUBMOD Reset

[1]CB010731-A_ET_01_ASiR_HUB_application_service_privileges_check_ASiR_ANT_reset
    Check New User Accounts And Groups Exist On All Hubs
    Reset All ANTMODs On ASiR WebEM
    Wait Until All BTS Antennas Are Available
    Verify Active And Historic Alarms After Antenna Reset

[1]CB010731-A_ET_01_ASiR_HUB_application_service_privileges_check_ASiR_ANT_block
    Check New User Accounts And Groups Exist On All Hubs
    Block All Antennas In ASiR WebEM
    Wait Until All Antennas Are Blocked
    Verify Active Alarms After Antenna Block
    Unblock All Antennas In ASiR WebEM
    Verify Alarms And Historic Alarms After Antenna Unblock

[1]CB010731-A_ET_01_ASiR_HUB_application_service_privileges_check_ASiR_cell_deletion_addition
    Check New User Accounts And Groups Exist On All Hubs
    Get HUB And Cell Info
    Change HUB Load Balancing Energy Saving Mode
    Delete All Cells In ASiR WebEM
    Verify Active BTS Alarms After Cell Deletion

    Add All Cells In ASiR WebEM
    Verify Active BTS Alarms After Cell Addition
    Wait For All Cells To Be Operating Correctly
