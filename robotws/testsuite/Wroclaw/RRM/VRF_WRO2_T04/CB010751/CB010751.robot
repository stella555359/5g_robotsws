*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com

Resource     ./resources/keywords_10751.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/regression/regression_keywords.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      ute_wtssim
Library      ute_fsmaccess
Library      ta5g_iphy
Library      taf.wts.runner
Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T04/regression/global_variables.py


# Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${KEEP_ALIVE}                 ${True}           # if 'True' simulator session will be alive after tests execution


*** Test Cases ***
CB010751_Successful_transition_of_RedCap_UE_being_in_RRC_CONNECTED_state_to_RRC_INACTIVE_state
    [Documentation]   This TC verifies basic functionality of transition from/to RRC_INACTIVE state together with related PM counters
    [Setup]         Run Keywords    Update And Put Iphy Xml   input_filepath=${CURDIR}/config/iphy.xml
    ...             AND             Find Scfc And Fix And Send Full Commissioning    scfc_filename=scf.xml
    ...             AND             Check Radios Availability
    ...             AND             Wait Until Keyword Succeeds    5min   30s   are_cells_configured
    ...             AND             Reach Onair    lua_cfg=${CURDIR}/config/config.lua

    Start Collecting Syslog

    configure_inactivity_timers   set_redcap_timers=${False}

    Precondition to Test
    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request

    sync_to_next_reporting_interval   offset=0
    ${pm_start_time}   Get Time  epoch
    logs.Start Tracing On SMOD   smod slave=False

    Attach UEs
    Wait UEs move to INACTIVE state
    Verify UEs moved to INACTIVE state
    Resume to CONNECTED state
    Stop Tput and Verify All UEs moved to INACTIVE state
    Wait RNA Update
    Run Keyword And Continue On Failure   Wait UEs RRC Inactive Timer Reached
    Calculate Inactive Time for All Redcap UEs

    sync_to_next_reporting_interval   offset=0
    ${log_path}   logs.Stop Tracing And Download Logs From SMOD
    sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch
    Collect Counters And Verify Them    ${pm_start_time}  ${pm_stop_time}  ${log_path}  ${serving_cell}

    [Teardown]   Run Keywords   logs.Stop Tracing On SMOD
    ...          AND            Detach UEs
    ...          AND            Collect and Verify Syslog
    ...          AND            Add Scout Data Info To Testcase
    # ...          AND            Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
