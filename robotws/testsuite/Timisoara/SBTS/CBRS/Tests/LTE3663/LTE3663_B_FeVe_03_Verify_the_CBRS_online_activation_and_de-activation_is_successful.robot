*** Settings ***
Documentation
...    = Author = Aleksandra Dagiel
...    _aleksandra.dagiel@nokia.com_
...    = Maintainer =
...    _aleksandra.dagiel@nokia.com_
...    = Reviewer =
...    _bartosz.rutkowski@nokia.com_
...    = Summary =
...    N/A
...    = Pre - Requirements =
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_
...    = Additional Info =
...    Test in progress

*** Keywords ***
LTE3663_B_FeVe_03_Verify_the_CBRS_online_activation_and_de-activation_is_successful
    [Documentation]     Testcase will contain test from manual regression:
    ...    The purpose of this test case is to check whether the CBSR online activation and deactivation is successful
    ...    in half rack CBSD maximum configuration. Each CBSD activation/deactivation would not impact other CBSDs status.
    ...    1) Every json file used in keywords Load JSON From File serves as a pattern of message searched in SAS logs
    ...    (passed as a variable ${parsed_log_file}).
    ...    2) SFS/CFAMrequirement: OM_GEN_SFS_CBRS.360, OM_GEN_SFS_CBRS.353

    Log To Console    Setting environment and variables for test...
    ${BTS_L_object_list}   ute_admin_infomodel.Get Infomodel Object    dist_name=/MRBTS-*/RAT-*/BTS_L-*    timeout=30    alias=RAT_1ST
    ${enb_id}   Set Variable    ${BTS_L_object_list['btsId']}
    ${enb_id}   Convert To String    ${enb_id}
    ${fccid}    ${userid}   Get FCC And User Ids From Infomodel
    ${sas_sim_version}   Set Variable    1.2

    Kill All SAS Processes
    Disable CBRS Feature On eNB
    ${sas_pid}    ${sas_log}   Start SAS Process    version=${sas_sim_version}
    Log To Console    SAS Simulator with TS v${sas_sim_version} started

    ${time_start}   Get Time
    Wait Until BTS Is Not Busy
    Enable CBRS Feature On eNB
    Log To Console    CBRS enabled on eNB
    Required CBSD Status Should Be Reached    expected_status=Registered    enb_id=${enb_id}
    ${cbsdId}   Wait Until Keyword Succeeds    20x    30s    Get CBSD Id From Infomodel
    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection
    Log To Console    onAir state reached
    Disable CBRS Feature On eNB
    Log To Console    CBRS disabled, waiting for disabling cell(s) and CBSD status update...
    Check If Cells Are Disabled    enb_id=${enb_id}
    Required CBSD Status Should Be Reached    expected_status=Unregistered    enb_id=${enb_id}

    ${time_stop}   Get Time
    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_log}    date_start=${time_start}    date_stop=${time_stop}

    Log To Console    Checking registration request message...
    Query Sas Log    log_name=${parsed_log_file}    data_type=registrationRequest    parameter=fccId    value=${fccid}
    Query Sas Log    log_name=${parsed_log_file}    data_type=registrationRequest    parameter=userId    value=${userid}

    Log To Console    Checking deregistration request message...
    Query Sas Log    log_name=${parsed_log_file}    data_type=deregistrationRequest    parameter=cbsdId    value=${cbsdId}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures
