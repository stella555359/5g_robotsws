*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: CB010925 test case

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library     ../../../features/CB005833/resources/CB005833_keywords.py
Library     ./resources/keywords.py
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Test Timeout  24 hours

Suite Setup         Common Suite Setup With OnAir Test Line Preparation
...  prefix_tag=CB010925
...  swconfig_from_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions With Watching Alarms
Test Teardown       Common Postconditions With Watching Alarms

*** Variables ***
@{sfp_lanes}
...  MRBTS-${tl.gnbs[0].global_bts_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-1
...  MRBTS-${tl.gnbs[0].global_bts_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-2/LANE-1
@{additional_allowed_alarms}
...    No connection to unit

*** Test Cases ***
CB010925_23_T_MplaneCommon_timer_expires_APHA
    ${ru_uptime_1}=    get_ru_uptime    ru_id=1
    Lock Multiple SFP LANES    ${sfp_lanes}
    sleep    1200
    Unlock Multiple SFP LANES   ${sfp_lanes}
    gnbcell.Wait for setup of all cells
    ${ru_uptime_2}=    get_ru_uptime    ru_id=1
    Should Be True    ${ru_uptime_2} < ${ru_uptime_1+1200}
