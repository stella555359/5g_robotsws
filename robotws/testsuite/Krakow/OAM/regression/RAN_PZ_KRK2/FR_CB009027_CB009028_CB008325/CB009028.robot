*** Settings ***
Documentation
...    author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    maintainer:
...    CB009028-subcase3

Resource    ./resources/keywords.robot

Suite Setup      Common Suite Setup With OnAir Test Line Preparation
...              swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...              increase_timeout_for_update_sw=1800
...              prefix_tag=TL172_sub3

Test Setup       Run Keywords
...              Set Allowed Alarms For ASiR    AND
...              Common Preconditions    AND
...              Verify ASiR Alarms

Test Teardown    Run Keywords
...              Change PrachIndex And Frame Shift on Teardown    AND
...              Wait For All Cells To Be Operating Correctly after PRACH Modification    AND
...              Wait For All Cells To Be Operating Correctly On ASiR WebEM    AND
...              Verify ASiR Alarms    AND
...              Common Postconditions

*** Variables ***
${CELL_ID_FOR_PRACH_CHANGE}    ${0}

*** Test Cases ***
# testsuite/Nanjing/OAM/CB009027_CB009028_CB008325/CB009028-subcase3_CRT.robot
[1.0] CB009028_5G_J_TC014_5903_Subcase3_NR_tdLte_3ms_0ms_2Ues_attach_peak_udp_tput
    Log Current Time
    Change PrachIndex For TDLTE 0 Ms
    Wait For All Cells To Be Operating Correctly after PRACH Modification
    Wait For All Cells To Be Operating Correctly On ASiR WebEM
    Verify Alarms And Historic Alarms After PRACH Change Without RAT Reset
    Change PrachIndex For TDLTE 3 Ms
    Wait For All Cells To Be Operating Correctly after PRACH Modification
    Wait For All Cells To Be Operating Correctly On ASiR WebEM
    Verify Alarms And Historic Alarms After PRACH Change With RAT Reset
