*** Settings ***
Documentation
    ...    Author: cristinel.sava@nokia.com

#Resource    ./../resources/Common.robot
Variables   ./../resources/formula_tmo.py
Variables   ./../resources/formula_error.py
Variables    ./../resources/common_vars.py
Library     taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Resource    ./../resources/interface.robot
Resource    ./../resources/taf_coam.robot
#/home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/LOGS/LOGS__CB012784_TMO.robot
Library     ute_syslog
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    ./../resources/COAM.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

Library  taf.collectors.pmcounters
Library  ../common_resources/python_resources/PM/PM__RP918_AVERAGE_VALUE_OF_VSWR_counter_M40001.py
#Resource  ../common_resources/ca_PM_general.robot
Library    ./../resources/python/utils.py

*** Variables ***
${SNAPSHOT_TIMEOUT}      600

#*** Test Cases ***
*** Keywords ***
TC__LOGS__CB012784_Classical_KPI_triggering_faults_TMOUS_SMOD
    Log to Console   Start TC_CB012784_Classical_KPI_triggering_faults_TMOUS_SMOD
#    Log to Console   Reset Site Start
#    ${bts_id}  bts_states.Get BTS ID
#    Set Test Variable  ${BTS_ID}  ${bts_id}
#    coam.Reset Site
#    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States
#    Log    Reset site done
#    Log to Console   Reset site done
#    CB012784 Common Suite Setup
    CB012784 Common Case Setup

    FOR   ${trigger_formula_parameter}   IN   @{ALL_TRIGGERINGFORMULA_PARAMETER_LIST_SMOD}
        Log To Console   ${trigger_formula_parameter}

        ${fault_list}   Get Variable Value   ${trigger_formula_parameter["fault_list"]}
        ${counter_ids}   Get Variable Value   ${trigger_formula_parameter["counter_ids"]}
        ${triggering_formula}   Get Variable Value   ${trigger_formula_parameter["triggering_formula"]}

        ${counter_report}   COAM Check Specific PM Counter List   counter_ids=${counter_ids}
        Continue For Loop If   not ${counter_report}

        COAM Update Trigger Formula Parameters   triggering_formula=${triggering_formula}
        COAM Enable KPI Trigger Flag
        Sleep   1m

        Wait Until Keyword Succeeds   5m   1m   COAM Check Fault List   fault_list=${fault_list}

        COAM Remove Trigger Formula Parameters
        Sleep   10s
        COAM Check Fault List Clear   fault_list=${fault_list}

    END

CB012784 Common Suite Setup
    Log To Console   CB012784 Common Suite Setup
    robot_common_operations.Common Suite Setup
    # Perform Golden SCF Commission
    Log to Console    INAINTE DE WAIT COAM commissioning if not onair
    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
    COAM Login
    Log to Console    Update PM Enable Parameters
    Sleep    2s
    COAM Update PM Enable Parameters
    Run Keyword And Ignore Error   COAM Logout
    Log to Console    SLEEP 30min to wait new pm counters
    Sleep   30min
    Log to Console    after 30min next Check PM Counter List

    COAM Login
#    Collect PM Counters
#    Log to Console    STOP SLEEP 50s
#    Sleep   50s
    Wait Until Keyword Succeeds   15m   1min   COAM Check PM Counter List   counter_ids=${CHECK_COUNTER_LIST}

    [Teardown]   Run Keyword And Ignore Error   COAM Logout

CB012784 Common Case Setup
    Log To Console   CB012784 Common Case Setup
    # Run Keyword And Ignore Error   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
    robot_common_operations.Common Case Setup

    FOR   ${fault_id}   IN RANGE   ${4569}   ${4589}
        AlarmWatchdog.add_allow_alarms    fault_id=${fault_id}
    END

    ${fail_log_dir}   Set Variable   ${OUTPUT_DIR}/${TEST_NAME}
    ${fail_log_dir_not_exist}   Run Keyword And Return Status   OperatingSystem.Directory Should Not Exist   ${fail_log_dir}
    Run Keyword If   ${fail_log_dir_not_exist}   OperatingSystem.Create Directory   ${fail_log_dir}
    Set Test Variable   ${FAIL_LOG_DIR}

    Run Keyword And Ignore Error   CB012784 Start Syslog Process

    COAM Login

Connect to gnb coam via ssl
    [Arguments]  ${connection}=GNB_OAM    ${gnb_index}=0
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    ${ignore_get_release_error}=${True}
    Log    message=\nArgument ignore_get_release_error=${ignore_get_release_error} is not used and will be removed in the future.
    # No more pass release after TAF-2785 Support Auto release detect in admin library.
    # Skip the 'connect_to' operation if the connection can be used normally.
    ${existing_connection}    Run Keyword And Return Status    coam.get_sw_release_name    connection=${connection}
    Run Keyword If	${existing_connection}    Log to console    Connection ${connection} already exists, skip the connection setup
    ...    ELSE    Run Keywords    Log to console    Connection ${connection} does not exist
    ...    AND    coam.connect_to    bts_host=${bts_host}    bts_port=${443}
    ...    username=${username}    password=${password}   name=${connection}

Suite Teardown      CB012784 Common Suite Teardown

TC Setup
    Common Test Setup    syslog_launch=${False}

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown

TC__LOGS__CB012784_Classical_KPI_triggering_faults_TMOUS_RMOD
    Log to Console   Start TC_CB012784_Classical_KPI_triggering_faults_TMOUS_RMOD
#    Log to Console   Reset Site Start
#    ${bts_id}  bts_states.Get BTS ID
#    Set Test Variable  ${BTS_ID}  ${bts_id}
#    coam.Reset Site
#    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States
#    Log    Reset site done
#    Log to Console   Reset site done
#    CB012784 Common Suite Setup
    CB012784 Common Case Setup


    FOR   ${trigger_formula_parameter}   IN   @{ALL_TRIGGERINGFORMULA_PARAMETER_LIST_RMOD}
        Log To Console   ${trigger_formula_parameter}

        ${fault_list}   Get Variable Value   ${trigger_formula_parameter["fault_list"]}
        ${counter_ids}   Get Variable Value   ${trigger_formula_parameter["counter_ids"]}
        ${triggering_formula}   Get Variable Value   ${trigger_formula_parameter["triggering_formula"]}

        ${counter_report}   COAM Check Specific PM Counter List   counter_ids=${counter_ids}
        Continue For Loop If   not ${counter_report}

        COAM Update Trigger Formula Parameters   triggering_formula=${triggering_formula}
        COAM Enable KPI Trigger Flag
        Sleep   1m

        Wait Until Keyword Succeeds   5m   1m   COAM Check Fault List   fault_list=${fault_list}

        COAM Remove Trigger Formula Parameters
        Sleep   10s
        COAM Check Fault List Clear   fault_list=${fault_list}

    END
#
#    [Teardown]   CB012784 Common Case Teardown

TC__LOGS__CB012784_Classical_KPI_triggering_faults_TMOUS_Formula_Evaluation_Error
    Log to Console   CB012784_Classical_KPI_triggering_faults_TMOUS_Formula_Evaluation_Error
#    Log to Console   Reset Site Start
#    ${bts_id}  bts_states.Get BTS ID
#    Set Test Variable  ${BTS_ID}  ${bts_id}
#    coam.Reset Site
#    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States
#    Log    Reset site done
#    Log to Console   Reset site done
#    CB012784 Common Suite Setup
    CB012784 Common Case Setup
    COAM Enable KPI Trigger Flag

    ${status}   ${info}   Run Keyword And Ignore Error
    ...   COAM Update Trigger Formula Parameters   triggering_formula=${ALL_ERROR_TRIGGERING_FORMULA_PARAMETER}
    Log To Console   ${status}
    Log To Console   ${info}

    ${obsolete}   ${result}   Split String   ${info}   Status reached:
    FOR   ${trigger_formula}   IN   @{ALL_ERROR_TRIGGERINGFORMULA_LIST}
        Should Contain   ${result}   ${trigger_formula}
    END

#    [Teardown]   CB012784 Common Case Teardown




