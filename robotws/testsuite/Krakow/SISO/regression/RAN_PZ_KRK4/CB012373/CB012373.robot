*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: CB010925 test case

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK4/CB010925/Keywords.robot
Library     ../../../features/CB005833/resources/CB005833_keywords.py
Library     on_air_tl_preparation/testline_preparation_resources.py
Library     ./resources/keywords.py
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Test Timeout  24 hours

Suite Setup         Run Keywords
...    testline_preparation_resources.power_on_all_pdu_ports
...    AND    Prepare Neighbours
...    AND    Common Suite Setup With Commissioning  asir_hub=${True}
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions With Watching Alarms
Test Teardown       Common Postconditions With Watching Alarms

*** Variables ***
${BTS150_addr}     ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${BTS129_addr}     ${tl.gnbs[2].cu.oam_http_connection_details.addr}

@{additional_allowed_alarms}
...    No connection to unit
...    Fault signature for crash or failure

@{allowed_alarms_bts1}
...    PPS reference missing
...    TD-LTE radio disabled
...    Unit synchronization failed
...    ToP reference missing
...    No usable time reference available
...    Antennas assignment not available

@{allowed_alarms_bts2}
...    PPS reference missing
...    Antennas assignment not available
...    No usable time reference available
...    Phase error exceeds 5 us limit

*** Test Cases ***
CB012373_040_MPlane_Link_recover_limit_over_fronthaul_port
    ${hub0_uptime_1}=    get_ru_uptime    ru_id=0
    ${hub1_uptime_1}=    get_ru_uptime    ru_id=1
    gnbbbu.lock_all_sfp_links_for_radio_unit    radio_unit_id=1  radio_type=asirmod    bts_id=0
    gnbbbu.lock_all_sfp_links_for_radio_unit    radio_unit_id=1  radio_type=asirmod    bts_id=1
    gnbbbu.lock_all_sfp_links_for_radio_unit    radio_unit_id=1  radio_type=asirmod    bts_id=2
    sleep    10800
    gnbbbu.unlock_all_sfp_links_for_radio_unit    radio_unit_id=1  radio_type=asirmod    bts_id=0
    gnbbbu.unlock_all_sfp_links_for_radio_unit    radio_unit_id=1  radio_type=asirmod    bts_id=1
    gnbbbu.unlock_all_sfp_links_for_radio_unit    radio_unit_id=1  radio_type=asirmod    bts_id=2
    wait until keyword succeeds    10x     1min
        ...    Verify All Cells Are OnAir On all Bts
    ${hub0_uptime_2}=    get_ru_uptime        ru_id=0
    ${hub1_uptime_2}=    get_ru_uptime        ru_id=1
    Should Be True    ${hub0_uptime_2} < 90*60
    Should Be True    ${hub0_uptime_2} > 50*60

CB012373_049_MPlane_Link_recover_failure_during_normal_operation_power_off_SBTS1_for_30_min
    [Setup]    Test Setup
    gnbbbu.bts_power_off    bts_id=0
    sleep    1800
    gnbbbu.bts_power_on    bts_id=0
    wait until keyword succeeds    20x     1min
    ...    Verify All Cells Are OnAir On all Bts
    ${hub_uptime}=    get_ru_uptime        ru_id=1
    Should Be True    ${hub_uptime} < 25*60
    [Teardown]   Test Teardown

*** Keywords ***
Collect Logs
    [Arguments]    ${gnb_id}
    Collect IM Snapshot From gNB    log_dir=${LOG_PATH}    gnb_id=${gnb_id}
    Collect IMS Log From gNB        log_dir=${LOG_PATH}    gnb_id=${gnb_id}
    Collect Snapshot From gNB       log_dir=${LOG_PATH}    gnb_id=${gnb_id}

Test Setup
    gnbru.Reset Radio Unit  radio_unit_id=${1}  radio_type=asirmod
    wait until keyword succeeds    10x     1min
    ...    gnbcell.verify_all_cells_are_onair
    Common Preconditions With Watching Alarms
    Run Keyword If  ${allowed_alarms_bts1}    Append To List  ${allowed_alarms_bts1}  @{allowed_alarms}
    Run Keyword If  ${allowed_alarms_bts2}    Append To List  ${allowed_alarms_bts2}  @{allowed_alarms}
    wait until keyword succeeds    3x     30sec
    ...    gnb_alarm.Start watching alarms
    ...    allowed_alarms=${allowed_alarms_bts1}  interface=${BTS150_addr}    gnb_id=${1}
    wait until keyword succeeds    3x     30sec
    ...    gnb_alarm.Start watching alarms
    ...    allowed_alarms=${allowed_alarms_bts2}  interface=${BTS129_addr}    gnb_id=${2}

Test Teardown
    gnb_alarm.Stop watching alarms    gnb_id=${1}
    gnb_alarm.Stop watching alarms    gnb_id=${2}
    Collect Logs    gnb_id=${1}
    Collect Logs    gnb_id=${2}
    Common Postconditions With Watching Alarms
