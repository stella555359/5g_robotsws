*** Settings ***
Documentation
...   Test suite for regression testing of feature CNI-89997 on ABIP.
...   author: Szymon Skorupski
...   contact: szymon.skorupski@nokia.com


Library     ute_ue
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/bts/robot/common/enb_cell.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../../../procedures/Power_Saving/resources/Power_Saving_cmW.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               prefix_tag=${prefix_tag}
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms

*** Variables ***
${dist_name_power_group}=       MRBTS-{}/NRBTS-{}/NRPGRP-1
${prefix_tag}                   CNI89997

*** Test Cases ***
5GC002481_ABCV_22_Reset_site_with_power_saving_on
    Turn on lbps for specific time via GUI     how_many_mins_lbps_should_work=120     delay=0    node_index=0
    Activate feature 5GC000431
    Wait until cell will be in state energy saving      cell_id=2
    Reset gNB via GUI
    Sleep   30s
    Verify gNB Responds     timeout=180
    Wait For Site To Be Onair
    Wait for cell to be OnAir   cell_id=1    timeout=600
    Wait for cell to be OnAir   cell_id=2    timeout=600
    Wait until cell will be in state energy saving      cell_id=2
    [Teardown]    Run keywords    Deactivate feature 5GC000431                            AND
    ...                           Wait for cell to be OnAir   cell_id=2    timeout=600    AND
    ...                           Wait for cell to be OnAir   cell_id=1    timeout=600    AND
    ...                           Common Postconditions With Watching Alarms
