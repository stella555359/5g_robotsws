*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: CB010925 test case

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library     ../../../features/CB005833/resources/CB005833_keywords.py
Variables   ./resources/sharing_config.py
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Test Timeout  24 hours

Suite Teardown      Common Suite Teardown
Test Setup          Test Setup
Test Teardown       Test Teardown

*** Variables ***
@{additional_allowed_alarms}
...    No connection to unit
...    Fault signature for crash or failure
...    Failure in connection between BTS and 3rd party tool
...    User Account has Default Password
...    No X2 link available
@{allowed_alarms_bts1}
...    Setup of X2 connectivity to gNB failed
${SW_DIR}    /home/ute/.ute-ca/cache/bts
${SEND_TRUCK_ROLL_EMAIL}         ${False}

*** Test Cases ***
CB009828_05_Simplified_RF_sharing_configuration__site_reconfiguration_disabling_sharing
    run keyword and ignore error    gnbbbu.lock_all_sfp_links_for_radio_unit    radio_unit_id=2  radio_type=asirmod    bts_id=1    timeout=180
    Perform Delta Commissioning On gNB    delta=${delta}
    wait until keyword succeeds    15x     30sec    gnbcell.verify_all_cells_are_onair    bts_id=0
    Perform Delta Commissioning On gNB    delta=${delta_2}
    run keyword and ignore error    gnbbbu.unlock_all_sfp_links_for_radio_unit    radio_unit_id=2  radio_type=asirmod    bts_id=1    timeout=180
    gnbru.wait_for_radio_unit_statuses    ru_id=${2}    radio_type=asirmod    operational_state=disabled
    wait until keyword succeeds    15x     30sec    gnbcell.verify_all_cells_are_onair    bts_id=0
    wait until keyword succeeds    10x     30sec    gnbcell.verify_all_cells_are_onair    bts_id=1

*** Keywords ***
Collect Logs
    [Arguments]    ${gnb_id}
    Collect IM Snapshot From gNB    log_dir=${LOG_PATH}    gnb_id=${gnb_id}
    Collect IMS Log From gNB        log_dir=${LOG_PATH}    gnb_id=${gnb_id}
    Collect Snapshot From gNB       log_dir=${LOG_PATH}    gnb_id=${gnb_id}

Test Setup
    gnbscf.reset_configuration                   bts_id=${1}    timeout=1200
    ${SW_VERSION}    Get gNB Sw Version
    ${SW_PATH}       download_sw_package         sw_version=${SW_VERSION}    target_dir=${SW_DIR}
    gnbbbu.wait_until_smod_is_online             bts_id=${1}
    gnbbbu.verify_bts_is_not_commissioned        bts_id=${1}
    gnbswupdate.wait_sw_update_possible          readiness_timeout=${600}    bts_id=${1}
    gnbswupdate.update_software                  sw_package_dir=${SW_PATH}    bts_id=${1}    timeout=${1200}
    sleep    180
    Perform Full Commissioning on Classical gNB  bts_id=${1}        force_reconnect=${True}    verify_another_sw_upload=${False}
    Common Suite Setup With Commissioning  asir_hub=${True}
    wait until keyword succeeds    10x     1min
    ...    gnbcell.verify_all_cells_are_onair    bts_id=${1}
    Common Preconditions With Watching Alarms
    Append To List  ${allowed_alarms_bts1}  @{allowed_alarms}
    gnb_alarm.Start watching alarms              allowed_alarms=${allowed_alarms_bts1}   gnb_id=${1}

Test Teardown
    gnb_alarm.Stop watching alarms    gnb_id=${1}
    Collect Logs    gnb_id=${1}
    Common Postconditions With Watching Alarms
