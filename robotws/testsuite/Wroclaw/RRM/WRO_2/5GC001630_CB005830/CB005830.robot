*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1    CLOUD_5G_I_LO_AP_LO
Documentation    Suite description
Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     ../keywords/logging.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/scout_reporting/reporting_portal.robot

Library     ta5g_iphy
Library     ta5g_enb
Library     ta5g_syslog
Library     ta5g_testline_management

Library    feature_keywords.py
Variables    ta5g_global_var


Suite Setup    Run Keywords    Log To Console    Setup started
    ...        AND             Add 5 Additional Interfaces For Handling 6 Simulated Amfs
 #   ...        AND             Find Scfc and Send Delta Commissioning    scfc_filename=${DELTA_ACTIVATE_PRECONDITIONS}
    ...        AND             Start Default Logging
    ...        AND             Start Uu Dedicated Tshark
    ...        AND             Reach Onair    lua_cfg=${LUA_CFG}

Test Setup    Check Barring Absence In Sib1 Only In First Test
Test Teardown    Run keywords
...                         Deactivate Barring
...            AND          Add Scout External Execution ID To Reporting Portal


Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${ADDITIONAL_GNB_SYSLOG_ALIAS}=    gnb_sys_setup
${ADDITIONAL_AP_SYSLOG_ALIAS}=    ap_sys_setup

${LUA_CFG}=                           ${CURDIR}/config/egate_1c_1g.cfg
${DELTA_ACTIVATE_PRECONDITIONS}=      delta_activate_preconditions.json


*** Test Cases ***
CB005830_I_1_UAC_in_SA_mode_broadcast_in_SIB1_sunny_day_scenario_for_enabling_and_explicit_barring_list_config_in_one_step
    Activate Barring And Check It On F1 And Uu Interfaces    explicit

CB005830_I_1_UAC_in_SA_mode_broadcast_in_SIB1_sunny_day_scenario_for_enabling_and_implicit_barring_list_config_in_one_step
    Activate Barring And Check It On F1 And Uu Interfaces    implicit
    Deactivate Barring By FAF Only And Check It On F1 And Uu Interfaces
    Activate Barring By Faf Only And Check It On F1 And Uu Interfaces
