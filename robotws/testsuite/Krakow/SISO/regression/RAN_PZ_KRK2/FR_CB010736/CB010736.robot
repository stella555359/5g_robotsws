*** Settings ***
Documentation
...    author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    maintainer: Piotr Wajda, piotr.wajda@nokia.com

Resource    resources/keywords.robot

Suite Setup       Run keywords
...               Common suite setup with onAir Test Line preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               increase_time_for_checking_cells=600
...               prefix_tag=CB010736
...               AND    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms


*** Test Cases ***
[1][1.0] CB010736_Cell_setup_25MHz_NR
    Verify gNB is onAir

[1][4.0] General_SiSo_Online_Cell_Addition_Deletion
    Cell Addition And Deletion

[1][3.0] General_SiSo_Cell_block_and_unblock
    General SiSo Cell Block And Unblock

[1][2.0] Manual_SiSo_SM_RF_Module_lock_unlock
    General SiSo Auto RF Lock Unlock

[1][1.0] E2E_TL_RU_Reset_with_OAM_KPI
    [Setup]    RU Reset Test Setup
    RF Module Power Reset
