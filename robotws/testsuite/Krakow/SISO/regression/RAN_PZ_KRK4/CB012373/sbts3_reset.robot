*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: CB010925 sbts reset in loop with logs collection test case

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library      testsuite/Krakow/SISO/regression/RAN_PZ_KRK4/CB012373/resources/snapshot_keywords.py
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup         Common Suite Setup
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions
Test Teardown       reset teardown


*** Test Cases ***
sbts3_reset
    FOR    ${iteration}    IN RANGE    100
        log to console  Iteration ${iteration+1}
        log to console  Start BTS reset
        gnbbbu.reset_bts
        log to console  Wait for on air
        gnbcell.wait_for_all_cells_statuses
        ...    bts_id=0
        ...    availability_status=online
        ...    operational_state=enabled
        ...    administrative_state=unlocked
        ...    blocking_state=unblocked
        ...    procedural_status=configured
        ...    barring_status=unbarred
        ...    timeout=300
        gnbcell.wait_for_all_cells_statuses
        ...    bts_id=1
        ...    availability_status=online
        ...    operational_state=enabled
        ...    administrative_state=unlocked
        ...    blocking_state=unblocked
        ...    procedural_status=configured
        ...    barring_status=unbarred
        ...    timeout=60
        log to console  Get RU logs
        get_rus_snapshot    ${iteration}
    END

*** Keywords ***
reset teardown
    get_rus_snapshot    end
    Collect IM Snapshot From gNB    log_dir=${LOG_PATH}    gnb_id=${1}
    Collect IMS Log From gNB        log_dir=${LOG_PATH}    gnb_id=${1}
    Collect Snapshot From gNB       log_dir=${LOG_PATH}    gnb_id=${1}
    Common Postconditions
