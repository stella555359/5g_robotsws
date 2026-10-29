*** Settings ***
Documentation
...    = Author = Karol Palamarz
...    _karol.palamarz@nokia.com_
...    = Maintainer =
...    _karol.palamarz@nokia.com_
...    = Reviewer =
...    _marek.kot@nokia.com_
...    _artur.czainski@nokia.com_
...    _lukasz.lechowicz@nokia.com_
...    = Summary =
...    This test checks if CBSD could register to SAS TS 2.0 successfully SAS Simulator.
...    This is done by triggering CBRS feature.
...    = Pre - Requirements =
...    _actCBRS flag is set to false_
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_
...    = Additional Info =

*** Keywords ***
CBRS_LTE5703_FeVe_01_Registration_Procedure_is_successfully_modified
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.281

    Log    ${\n}Step 1: Test preparation, setup environment    console=true
    ${enb_id}                 Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}                  Set Variable    RAT_1ST
    ${sas_new_config}         Set Variable    ${CURDIR}/Data/feve01/SAS_Sim_registration_request.conf

    Disable CBRS Feature On eNB
    Add ICG And CCG Group ID
    Kill All SAS Processes
    ${time_start}   Get Time
    ${sas_pid}    ${sas_log}   Start SAS Process    port=4433    config=${sas_new_config}

    Log    ${\n}Step 2: Enable CBRS feature flag, expecting CBSD registration    console=True
    Enable CBRS Feature On eNB
    Wait Until Keyword Succeeds    10x    10s    Required CBSD Status Should Be Reached    expected_status=Registered    enb_id=${enb_id}
    Start Watchdog Alarm Detection
    ${time_stop}   Get Time

    Check If Registration is TS2.0 Compliant    alias=${alias}
    ...                                         time_start=${time_start}
    ...                                         time_stop=${time_stop}
    ...                                         sas_log_path=${sas_log}
    ...                                         enb_id=${enb_id}

    Log    ${\n}Step 3: Checking TS version    console=True
    Wait Until Keyword Succeeds    5x    1min    Check If TS Version Is As Expected    ${enb_id}    ${alias}    2.0

    Log    ${\n}Step 4: Waiting for OnAir and no alarms    console=True
    Wait For All Cells To Be OnAir

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Delete ICG And CCG Group ID
