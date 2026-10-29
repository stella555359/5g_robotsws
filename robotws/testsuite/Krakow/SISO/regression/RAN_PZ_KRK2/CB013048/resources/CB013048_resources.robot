*** Settings ***
Documentation
...   File contains resources for CB013048 suite
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Maciej Russek, maciej.russek@nokia.com

Resource    testsuite/Krakow/SISO/resources/RAN_PZ_KRK2/CB011050/keywords.robot
Library     taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations    WITH NAME    AsirOperations
Library     helpers.py    WITH NAME    CB013048_helpers
Variables   deltas/mcc_404.py
Variables   deltas/mcc_001.py

*** Keywords ***
Prepare testline
    [Arguments]    ${bts_scf}    ${asir_scf}
    Log to console    Performing BTS Commissioning!
    TRY
        Perform full commissioning on gNB    scf_file=${bts_scf}
    EXCEPT    AS    ${error}
        Log to console    ${error}
    END
    Log to console    Performing ASIR Commissioning!
    ASIR commissioning    scf_path=${asir_scf}
    Sleep    45 sec    reason=Time until reset will trigger
    Verify if ASIRMOD is enabled
    Wait until keyword succeeds    360 sec
    ...                            10 sec
    ...                            gnbcell.Verify all cells are onAir
    Log to console    Site is on Air!

Verify if ASIRMOD is enabled
    Log to console    Waiting for ASIRMOD(s) to be enabled
    TRY
        Wait until keyword succeeds    360 sec    30 sec    Verify ASIR status
        Set suite variable    ${IS_ASIR_ONAIR}    ${True}
    EXCEPT    AS    ${error}
        Log to console    ${error}
        Set suite variable    ${IS_ASIR_ONAIR}    ${False}
    END

    TRY
        Log to console    Verifying if Incompatible SW Version alarm is raised
        Wait until keyword succeeds    3 min    30 sec    Verify Incompatible SW alarm is active
        Set suite variable    ${INCOMPATIBLE_SW}    ${True}
    EXCEPT    AS    ${error}
        Log to console    ${error}
        Set suite variable    ${INCOMPATIBLE_SW}    ${False}
    END

    IF    ${INCOMPATIBLE_SW} == ${True}
        Check SW version
        Log to console    Downloading SW: ${CURRENT_SW}
        ${sw_dir}    Download SW package
                     ...    sw_version=${CURRENT_SW}
                     ...    target_dir=${SW_DOWNLOAD_PATH}
        Log to console    Starting update SW!
        Update SW    path=${sw_dir}    expected_sw=${CURRENT_SW}
    ELSE IF    ${IS_ASIR_ONAIR} == ${True}
        Log to console    ASIRMOD(s) enabled!
    ELSE
        Fail    Asirmod(s) not enabled!
    END

Check SW version
    gnbbbu.Connect
    ${sw_version}    Get gNB SW version
    Set suite variable    ${CURRENT_SW}    ${sw_version}

Update SW
    [Arguments]    ${path}    ${expected_sw}
    Log to console    SW is updating!
    Update gNB software    sw_package_dir=${path}
    Log to console    Waiting few minutes to SW apply and reset...
    Sleep    300 sec    reason=Time for SW to apply
    gnbbbu.Disconnect
    Wait until keyword succeeds    10 min    30 sec    gnbcell.Verify all cells are onAir
    Check SW version
    IF    "${CURRENT_SW}" != "${expected_sw}"
        Fail    Unexpected SW is activated!
    END
    Log to console    Update is completed! Site is onAir! Current SW: ${CURRENT_SW}

Custom suite setup
    gnb_alarm.Start watching alarms     allowed_alarms=${ALLOWED_ALARMS_DURING_TL_PREPARATION}
    ...                                 interface=lmp
    ...                                 log_dir=${LOG_PATH}/preparation
    ${sw_release}    Get release name
    Prepare testline    bts_scf=commissionings/Krakow/7_7_T01SK119/${sw_release}/GNB0_SCF.xml
    ...                 asir_scf=commissionings/Krakow/7_7_T01SK119/${sw_release}/GNB0_ASIR_SCF.xml
    gnbbbu.Disconnect
    Common suite setup    enable_sleeping_cell_detection=${False}
    gnbbbu.Disconnect
    [Teardown]    Common suite setup with onAir Test Line preparation teardown    check_truck_roll=${True}

ASIR commissioning
    [Arguments]    ${scf_path}
    Run keyword and ignore error    AsirOperations.Perform ASIR commissioning    scf_path=${scf_path}

Verify ASIR status
    gnbbbu.Disconnect
    gnbru.Verify radio unit is online    radio_type=asirmod

Verify Incompatible SW alarm is active
    gnbbbu.Disconnect
    gnbalarm.Verify alarm is active
    ...    fault_name=Incompatible SW version detected
    ...    fault_id=23

Set MCC parameter by delta commissioning
    [Arguments]    ${delta}
    ${status}    Run keyword and ignore error    Perform delta commissioning on gNB
    ...                                          delta=${delta}
    gnbbbu.Disconnect
    ${delta_status}    CB013048_helpers.Verify delta commissioning status    status=${status}
    [Return]   ${delta_status}

Verify all cells are disabled
    gnbcell.Verify all cells statuses    operational_state=disabled

Verify alarm 'Suspicious unit detection' is active on gNB
    Verify alarm is active on gNB    fault_name=Suspicious unit detection
    ...                              fault_id=4795
    ...                              alarm_id=7116
    ...                              severity=Critical
