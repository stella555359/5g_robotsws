*** Settings ***
Documentation
...  KW Regarding Test Setup and teardown

Library    taf.transport.ssh                            WITH NAME    ssh
Library    taf.ul.marvin                                WITH NAME    marvin


Library    ../../../resources/Common/python/alarm_handling.py   WITH NAME    alarm

Library    python/cpu_usage.py
Library    python/perf_keywords.py
Library    python/perf_timer.py
Library    python/perf_log_collection.py
Library    python/perf_resource_usage.py
Library    python/perf_perfshot.py
Library    python/ltepat_manager.py
Library    python/wts_multivm_helper.py
Library    python/taf_sw_wtssim_wrapper.py


Resource    ../../../resources/Common/connect.robot
Resource    ../../../resources/Common/ute_workarounds.robot
Resource    ../../../resources/Common/testline.robot
Resource    ../../../resources/Common/wts_ue.robot
Resource    ../../../resources/Common/gnb.robot
Resource    ../../../resources/Common/alarm_handling.robot

Resource    ../../resources/SQD65/sqd65_keywords.robot

#Resource    performance_keywords.robot
Resource    performance_btslog.robot
Resource    performance_commissioning.robot
Resource    performance_database.robot
Resource    performance_dcap.robot
Resource    performance_egate.robot
Resource    performance_log_collection.robot
Resource    performance_swconfig.robot
Resource    performance_turandot.robot
Resource    performance_reporting.robot


*** Keywords ***
Suite Setup For Performance Test
    [Arguments]    &{args}
    performance_test_setup.Setup Common Strings

    ${ts_start_time}=    perf_timer.Start
    Log To Console           \nSuite Parameters:

    performance_test_setup.Setup SCF Suite Dictionary    ${args}
    performance_test_setup.Setup Suite Dictionary        ${args}
    performance_test_setup.Setup Log Verbosity

    ute_workarounds.UTE Cloud Workaround
    performance_test_setup.Setup OAM Connection Alias

    ute_workarounds.Log TL Info As Metadata For UTE AP TL

    testline.Create Test Suite Log Folders    # ${P_resultSuiteBaseDir} ${P_resultSuiteConfigDir} ${P_resultSuiteLogDir}
    testline.Check TL Infos

    TRY
        performance_test_setup.Store Test Line Data
    EXCEPT    .*TypeError. .NoneType. object is not iterable.*    type=regexp
        Log    It is possible that the radio modules are not okay, robot will now reset the testline    level=WARNING
        ute_workarounds.Bring Airphone TL To F1 Up Status
        performance_test_setup.Store Test Line Data
    EXCEPT    .*AssertionError. No IP could be determined for board .* cpu .*    type=regexp
        Log    Check command: ssh -q toor4nsn@192.168.255.129 'backplane-ip -6 -c 0 FSP1'    level=WARNING
        ute_workarounds.Bring Airphone TL To F1 Up Status
        performance_test_setup.Store Test Line Data
    END

    performance_egate.Create Lua Files
    performance_egate.Copy Egate Scripts To Wts Folder

    IF    "${TP.ENABLE_REPORT_TO_DB}"=="true"          performance_database.Initialize DB
    IF    "${TP.CFG_START_DCAP_CONTAINER}"=="true"     Run Keyword And Warn On Failure
    ...                                                    performance_dcap.Start Container
    IF    "${TP.ENABLE_LTEPAT}"=="true"                ltepat_manager.Install
    IF    "${TP.ENABLE_MARVIN}"=="true"                performance_reporting.Create UUID For Marvin

    perf_timer.Stop    msg=Suite Setup:    start_time=${ts_start_time}


Test Case Setup For Performance Test
    [Arguments]    &{args}
    Set Test Variable   @TURANDOT_FILES_QUEUE    @{EMPTY}
    ${tc_start_time}=    perf_timer.Start
    testline.Create Testcase Log Directory                                      # ${P_resultTestDir}

    # For Multi VM But also backwards compatible with single VM.
    wts_multivm_helper.Connect To All VMs    ${tl}
    wts_multivm_helper.Restart WTS Binaries On All VMs    ${tl}
    taf_sw_wtssim_wrapper.Setup All Egates And Edaemons Connections    tl=${tl}

    IF    "${TP.ENABLE_CPU_USAGE}"!="false"                 performance_test_setup.Start CPU Usage
    performance_test_setup.Setup Individual Features        ${args}
    performance_test_setup.Setup SW Config for GNB And AP
    performance_commissioning.Modify GNB SCF

    Run Keyword And Warn On Failure                         performance_database.Initialize DB For Testcase
    ...                                                         previous_testname=${TP.previous_tc_testname_for_db}

    IF    "${TP.ENABLE_ROBOT_VARIABLES_LOGGING}"=="true"    perf_log_collection.Save All Var To Json    label=test_setup

    performance_test_setup.Bring Airphone TL To F1 Up Status Wrapper
    performance_log_collection.Start SysLog Collection
    Run Keywords    wts_ue.Start WTS For Airphone    AND    Set Test Variable    $WTS_IS_RUNNING    ${True}

    IF    "${TP.ENABLE_NETCAT}"!="false"                    performance_test_setup.Start Netcat For Tracing Perf

    Log To Console     ${bar_b}${\n}Setup Info:${\n}

    performance_test_setup.Setup Scout ID
    performance_test_setup.Setup Turandot Links

    IF    "${TP.ENABLE_BEARER_STATS_COLLECTION}"=="true"    performance_egate.Setup Bearer Stats Egate Alias
    IF    "${TP.ENABLE_RESOUCE_USAGE}"=="true"              Run Keyword And Continue On Failure
    ...                                                     perf_resource_usage.Get Resources Usage
    ...                                                         label=tc_setup
    ...                                                         subfolder=${RL_PATH.resources_usage}    # resources_usage_tc_setup
    IF    "${TP.ENABLE_PERFSHOT}"=="true"                   perf_perfshot.Prepare Perfshot

    IF    "${TP.ENABLE_GNB_ALARM_CHECK}"=="true"            performance_test_setup.Set GNB Alarm As Test Variable    alarmslist_gnb0_setup
    IF    "${TP.ENABLE_MARVIN}"=="true"                     performance_reporting.Start Marvin
    perf_timer.Stop    msg=Testcase Setup:    start_time=${tc_start_time}


Test Case Teardown For Performance Test
    [Arguments]    ${database}=${TP.GRAFANA_DATABASE}
    ${tctd_start_time}=    perf_timer.Start
    Log To Console    \n${bar_b}\nTest Teardown

    IF    "${TP.ENABLE_ROBOT_VARIABLES_LOGGING}"=="true"          perf_log_collection.Save All Var To Json    label=test_teardown
    IF    "${TP.ENABLE_TC_TEARDOWN}"!="true" or "${TP.HALT_EXECUTION_ON_AIR}"=="true"    RETURN   ${none}

    IF    "${TP.ENABLE_GNB_ALARM_CHECK}"=="true"
        performance_test_setup.Teardown GNB Alarms    exclude_active_alarms=${TP.CFG_EXCLUDE_ACTIVE_ALARMS }
    END
    performance_test_setup. Save DCAP Logs If Exists
    performance_egate.Save Egate Logs To Turandot    subfolder=${RL_PATH.testcase_teardown}
    performance_database.Update Testcase Pass Data
    performance_test_setup.Required TC Teardown Checks
    performance_test_setup.Optional TC Teardown Checks
    performance_log_collection.Stop SysLog Collection             subfolder=${RL_PATH.testcase_teardown}

    Run Keyword And Continue On Failure    Report Tests    database=${database}    grafana_snapshot_dir=${P_resultTestDir}/traffic
    Run Keyword And Continue On Failure    Restore Testline Configuration

    IF    "${TP.ENABLE_CPU_USAGE}"!="false"                 Stop CPU Usage

    Run Keyword And Continue On Failure    performance_turandot.Queue Robot Logs To Turandot
    IF    "${TP.CFG_ENABLE_REMOTE_LOG_UPLOAD}"=="true"
        Run Keyword And Continue On Failure    perf_log_collection.Save Queued Logs to Turandot
    ELSE
        Log To Console    \n\nRemote Log Upload is Disabled, Skipping Uploading Queued Logs to Turandot\n\n
    END
    perf_timer.Stop    msg=Test Teardown:    start_time=${tctd_start_time}


Suite Teardown For Performance Test
    IF    "${TP.ENABLE_TS_TEARDOWN}"!="true" or "${TP.HALT_EXECUTION_ON_AIR}"=="true"    RETURN   ${none}
    Log To Console    Suite Teardown:\n${bar_a}

    IF    "${TP.CFG_START_DCAP_CONTAINER}"=="true"    Run Keyword And Warn On Failure
    ...                                                   performance_dcap.Stop Container

    ${tstd_start_time}=    perf_timer.Start
    IF    "${TP.KILL_WTS_ON_TS_TEARDOWN}"=="true"     wts_ue.Kill WTS Services

    Run Keyword And Warn On Failure    connect.Teardown OAM Http Session

    IF    ${GNB_SCF_IS_MODIFIED} and "${TP.ENABLE_RESTORE_SCF_ON_SUITE_TEARDOWN}"=="true"
    ...                                               Run Keyword And Warn On Failure
    ...                                                   performance_commissioning.Restore SCF

    taf_sw_wtssim_wrapper.Teardown All

    perf_timer.Stop    msg=Suite Teardown:    start_time=${tstd_start_time}


##################################################
#                   PRIVATE
##################################################

Setup Common Strings
    ${bar_a}    Format String    {:\=>78}    ${empty}
    ${bar_b}    Format String    {:\->78}    ${empty}
    Set Suite Variable    ${bar_a}
    Set Suite Variable    ${bar_b}
    Log To Console    \n${bar_a}


Setup Log Verbosity
    ${P_console}          Evaluate    '${TP.ENABLE_CONSOLE_OUTPUT}'.lower() in ['true', '1', 't', 'y', 'yes']
    ${P_scf_console}      Evaluate    '${TP.ENABLE_SCF_CHANGE_CONSOLE_OUTPUT}'.lower() in ['true', '1', 't', 'y', 'yes'] or ${P_console}
    Set Suite Variable    $P_console
    Set Suite Variable    $P_scf_console
    testline.Set Console Output    Output=${P_console}


Setup SCF Suite Dictionary
    [Arguments]    ${args}
    ${suite_variables}     Get Variables    no_decoration=${True}    # Get SCF Variables from robot CLI args
    ${TSGNBP}    perf_keywords.Get SCF Variables From Dictionary    custom_dict=${args}              scf_dict=${TSGNBP}
    ${TSGNBP}    perf_keywords.Get SCF Variables From Dictionary    custom_dict=${suite_variables}   scf_dict=${TSGNBP}
    ${TSGNBP}    performance_keywords.Initialize Dictionary Parameters    ${TSGNBP}    console=${False}
    Set Suite Variable    $TSGNBP


Setup OAM Connection Alias
    ${OAM_ALIAS}           connect.Setup OAM HTTP Session
    Set Suite Variable     $OAM_ALIAS    ${OAM_ALIAS}


Setup Suite Dictionary
    [Arguments]    ${args}
    ${TP}    Create Dictionary    &{TP}    &{TSGNBP}    &{TCP}    &{args}
    ${RL_PATH}    Create Dictionary    &{RL_PATH}
    ${TP}    performance_keywords.Initialize Dictionary Parameters    ${TP}
    Set Suite Variable    $TP         ${TP}
    Set Suite Variable    $RL_PATH    ${RL_PATH}


Store Test Line Data
    TRY
        ${S_GNB_VERSION}=         testline.Get GNB SW Version    gnb_id=${0}
    EXCEPT    .*FileNotFoundError.*   type=regexp
        FAIL    SW Version gnb - Check if gNB Have SW Load installed properly!
    END
    TRY
        ${S_AP_VERSION}=          testline.Get Airphone SW Version
    EXCEPT    .*FileNotFoundError.*   type=regexp
        FAIL    SW Version AP - Check if Airphone Have SW Load installed properly!
    END
    ${S_GNB_CU_TYPE}=         testline.Get Common Unit Type   gnb_id=${0}   du_id=${0}   common_unit_id=${0}
    IF    "${S_GNB_CU_TYPE}" in ["ASOE", "ASOH"]
        ${S_GNB_CAPU_TYPE}    Set Variable    none
    ELSE
        ${S_GNB_CAPU_TYPE}    testline.Get Capacity Unit Type
    END

    &{TL_DATA}    Create Dictionary    GNB_VERSION=${S_GNB_VERSION}
    ...                                AP_VERSION=${S_AP_VERSION}
    ...                                GNB_CU_TYPE=${S_GNB_CU_TYPE}
    ...                                GNB_CAPU_TYPE=${S_GNB_CAPU_TYPE}
    Set Suite Variable      $TL_DATA

    gnb.Store Current SCF From GNB                                    # Suite Variable Name ${P_ORIG_SCF}
    gnb.Store Current Swconfig From GNB                               # Suite Variable Name ${P_ORIG_GNB_SWCONFIG}
    wts_ue.Store Current Swconfig From Airphone                       # Suite Variable Name ${P_ORIG_AP_SWCONFIG}
    wts_ue.Store Current WTS Config                                   # Suite Variable Name ${P_ORIG_WTS_CONFIG}


Setup Individual Features
    [Arguments]    ${args}
    IF    "${TP.TC_DISABLE_TAGS}"=="false"                        performance_test_setup.Set Testcase Level Variables    &{args}
    IF    "${TP.ENABLE_ACT_BSR}"!="null"                          performance_commissioning.Activate BSR    ${TP.ENABLE_ACT_BSR}
    IF    "${TP.RDCFG_ACT_ADAPTIVE_SCHEDULER_BUDGET}"=="true"     performance_swconfig.Enable GNB SwConfig RdActAdaptiveSchedulerBudget
    IF    "${TP.RDCFG_CsReductionFactorOlc}"!="null"              performance_swconfig.Modify GNB SwConfig RdCsReductionFactorOlc
    ...                                                               ${TP.RDCFG_CsReductionFactorOlc}
    IF    "${TP.RDCFG_debug_level}"!="null"                       performance_swconfig.Modify GNB SwConfig Syslog Output Severity
    ...                                                               ${TP.RDCFG_debug_level}
    IF    "${TP.RDCFG_AP_debug_level}"!="null"                    performance_swconfig.Modify Ap SwConfig Syslog Output Severity
    ...                                                               ${TP.RDCFG_AP_debug_level}
    IF    "${TP.RDCFG_AP_fix_for_peak_capacity}"!="null"          performance_swconfig.Modify AP SwConfig Fix For Peak Capacity
    ...                                                               ${TP.RDCFG_AP_fix_for_peak_capacity}
    IF    "${TP.RDCFG_admin_mode_enable}"!="null"                 performance_swconfig.Enable GNB SwConfig Admin RD Mode Enable
    ...                                                               ${TP.RDCFG_admin_mode_enable}
    IF    "${TP.RDCFG_PM_INTERVAL}"!="null"                       performance_swconfig.Modify PM Interval in Gnb Swconfig
    ...                                                               ${TP.RDCFG_PM_INTERVAL}
    IF    "${TP.RDCFG_EnableUserDeleteInternalBundleMessage}"!="null"
    ...            performance_swconfig.Modify GNB SwConfig RdEnableUserDeleteInternalBundleMessage
    ...            ${TP.RDCFG_EnableUserDeleteInternalBundleMessage}


Update Json File
    [Arguments]    ${key}    ${value}    ${json_path}=${WORKSPACE}/properties.json
    ${json}=       Get File      ${json_path}
    ${json_obj}    Evaluate      json.loads('''${json}''')    modules=json
    Set To Dictionary    ${json_obj}    ${key}    ${value}
    ${json_fmt}    Evaluate    json.dumps($json_obj, indent=4)    modules=json
    Create File    ${json_path}      ${json_fmt}


Set Testcase Level Variables
    [Documentation]    Set Testcase level changes to Suite Dictionary \${TP} and \${TSGNBP}
    [Arguments]    &{args}
    Set To Dictionary    ${TCP}    previous_tc_testname_for_db    ${TEST NAME}

    Print Parameters Arguments    ${args}    label=Test Parameters    exclude=@{EMPTY}    padding=48
    # Get SCF Variables from tc args
    ${TSGNBP}    perf_keywords.Get SCF Variables From Dictionary    custom_dict=${args}    scf_dict=${TSGNBP}
    Set Test Variable    $TSGNBP

    ${TP}    Create Dictionary    &{TP}    &{TCP}    &{args}
    IF    "${TP.TC_DISABLE_TAGS}"=="false"
        ${TP}=    performance_keywords.Initialize Dictionary Parameters   ${TP}    console=${False}
    END
    Set Test Variable    $TP


Setup SW Config for GNB And AP
    performance_swconfig.Update GNB SwConfig From Params    ${TP}
    performance_swconfig.Update AP SwConfig From Params     ${TP}
    performance_swconfig.Enable GNB SwConfig From File If Exists
    performance_swconfig.Get Swconfigs
    IF    "${TP.ENABLE_SWCONFIG_CONSOLE_OUTPUT}"=="true"      performance_swconfig.Print SwConfigs


Start CPU Usage
    Run Keyword And Warn On Failure    cpu_usage.Start Cpu Usage
    ...              hostname=${tl.core.default_ssh_connection_details.addr}
    ...              username=${tl.core.default_ssh_connection_details.username}
    ...              password=${tl.core.default_ssh_connection_details.password}
    ...              alias=ssh-core
    ...              target=${P_resultTestDir}


Stop Cpu Usage
    Run Keyword And Warn On Failure    cpu_usage.Stop Cpu Usage    hostname=${tl.core.default_ssh_connection_details.addr}
    ...              username=${tl.core.default_ssh_connection_details.username}
    ...              password=${tl.core.default_ssh_connection_details.password}
    ...              alias=ssh-core
    ...              target=${P_resultTestDir}
    ${_}     ${df}    Run Keyword And Warn On Failure    cpu_usage.Get Df    ${P_resultTestDir}/cpu_usage.txt
    ${_}     ${res}    Run Keyword And Warn On Failure    cpu_usage.Check Cpu Usage    ${df}    threshold=${TP.ENABLE_CPU_USAGE}
    ${_}     ${cpu_plots}    Run Keyword And Warn On Failure    cpu_usage.To Plot    ${df}   ${P_resultTestDir}
    perf_log_collection.Queue Logs To Turandot    ${P_resultTestDir}/cpu_usage/    archive_name=cpu_usage    tar=${True}    is_dir=${True}
    IF     """${res}"""!="""${True}"""
        Log    CPU Overload!:    level=WARN
    END


Bring Airphone TL To F1 Up Status Wrapper
    performance_log_collection.Start SysLog Collection
    IF     "${TP.ENABLE_F1_STATUS}"=="true"
           Log To Console    ${bar_b}${\n}Bring Airphone TL to F1 up status${\n}
           ute_workarounds.Bring Airphone TL To F1 Up Status
    ELSE
           Log To Console    ${bar_b}${\n}Bring Airphone TL To F1 Up Status (skipped)${\n}
    END
    performance_log_collection.Stop SysLog Collection    subfolder=${RL_PATH.f1_setup}
    performance_btslog.Syslog Check Post F1 Setup


Setup Turandot Links
    Log To Console  ${\n}Turandot Link: ${TP.P_TURANDOT_LINK}/${TP.P_TESTLINE_NAME}/${TEST_NAME}/${TP.BUILD_ID}/
    Append To File     ${WORKSPACE}/properties.txt    turandot_link=${TP.P_TURANDOT_LINK}/${TP.P_TESTLINE_NAME}/${TEST_NAME}/${TP.BUILD_ID}/\n
    Set Environment Variable    turandot_link    ${TP.P_TURANDOT_LINK}/${TP.P_TESTLINE_NAME}/${TEST_NAME}/${TP.BUILD_ID}/
    Update Json File            turandot_link    ${TP.P_TURANDOT_LINK}/${TP.P_TESTLINE_NAME}/${TEST_NAME}/${TP.BUILD_ID}/
    Update Json File            TEST_NAME    ${TEST_NAME}/


Set GNB Alarm as Test Variable
    [Arguments]    ${label}    ${time_sort}=${True}    ${node_id}=${0}  ${node_type}=gnb
    ${json_target}    Set Variable    ${P_resultTestDir}/alarms_${node_type}${node_id}_${label}.json
    ${alarms_gnb0}    alarm_handling.Get All Alarms From Node    node_id=${node_id}    node_type=${node_type}
    ...                                                          targetfile=${json_target}
    ...                                                          time_sort=${time_sort}
    perf_log_collection.Queue Logs To Turandot    ${json_target}    subfolder=${RL_PATH.gnb_alarms}
    Set Test Variable    ${${label}}    ${alarms_gnb0}


Teardown GNB Alarms
    [Arguments]    ${exclude_active_alarms}=${EMPTY}
    Set GNB Alarm as Test Variable    alarmslist_gnb0_teardown
    ${_}  ${active_alarms_gnb0}  alarm.Check For New Alarms  ${alarmslist_gnb0_setup}  ${alarmslist_gnb0_teardown}
    ...                          exclude_active_alarms=${exclude_active_alarms}
    alarm_handling.Log Alarm List  ${active_alarms_gnb0}    WARN


Start Netcat For Tracing Perf
    IF    ${NETCAT_IS_RUNNING}
        sqd65_keywords.Start Netcat For Tracing
        Set Test Variable    $NETCAT_IS_RUNNING    ${True}
    ELSE
        Log    Stop Netcat For Tracing Perf: Netcat is Already Running!    level=ERROR
    END


Stop Netcat For Tracing Perf
    IF    ${NETCAT_IS_RUNNING}
        sqd65_keywords.Stop Netcat For Tracing
        Set Test Variable    $NETCAT_IS_RUNNING    ${False}
    ELSE
        Log    Stop Netcat For Tracing Perf: Netcat is Not Running!    level=ERROR
    END


Setup Scout ID
    testline.Get Testline Name
    TRY
        ${external_scf_id}=  reporting.Request Scout SCF ID  ${P_TL_NAME}
    EXCEPT    .*GetRequestException.*performing some maintenance at the moment.*    type=regexp
        Log    Scout Maintenance!    level=WARN
        RETURN    ${None}
    EXCEPT    .*AssertionError: Keyword .Check SCOUT Process Is Running. failed after retrying.*    type=regexp
        Log    Scout Failed to Run: AssertionError    level=WARN
        RETURN    ${None}
    EXCEPT    .*ProxyError.*    type=regexp
        Log    Scout Failed to Run: ProxyError    level=WARN
        RETURN    ${None}
    EXCEPT
        Log    Scout Failed to Run: General Error    level=WARN
        RETURN    ${None}
    END
    Set Test Variable    ${SCOUT_EXT_SCF_ID}    ${external_scf_id}
    Set Tags  ${SCOUT_EXT_SCF_ID}

    ${rep_ln}          Set Variable    https://rep-portal.ext.net.nokia.com/reports/scf-analysis
    ${scout_rep}       Catenate    Scout ID: ${SCOUT_EXT_SCF_ID}\n
    ...                - ReP: ${rep_ln}/?external_execution_id=${external_scf_id}&limit=5&scout_testline_name=${P_TL_NAME}
    Log To Console     ${scout_rep}
    Append To File     ${WORKSPACE}/properties.txt    external_scf_id=${external_scf_id}\n
    Append To File     ${WORKSPACE}/properties.txt    P_TL_NAME=${P_TL_NAME}\n
    Set Environment Variable    external_scf_id     ${external_scf_id}
    Update Json File    external_scf_id     ${external_scf_id}
    Set Environment Variable    P_TL_NAME           ${P_TL_NAME}
    IF    "${SCOUT_EXT_SCF_ID}"!="${None}"    performance_database.Insert Testcase Parameter2     scout_id    ${external_scf_id}


Save DCAP Logs if Exists
    FOR    ${dcap_path}    IN    @{DCAP_PATHS}
        Log to console    - Save DCAP: ${dcap_path}
        perf_log_collection.Queue Logs To Turandot    ${dcap_path[0]}/*    archive_name=${dcap_path[1]}    subfolder=${dcap_path[2]}
        ...                                                  tar=${True}
    END

Process SOS Report
    IF    ('${TEST_STATUS}'=='FAIL' and '${TP.ENABLE_SOS_REPORT}'=='onfail') or '${TP.ENABLE_SOS_REPORT}'=='true'
        Log To Console    Collect Sos Report logs
        ${status}    Run Keyword And Return Status    wts_ue.Collect Sos Report Logs    target_dir=${P_resultTestDir}
        IF    "${status}"=="${True}"
            perf_log_collection.Queue Logs To Turandot    ${P_resultTestDir}/SosReport*.tgz    archive_name=SosReport    compress=${False}
            Run Keyword And Warn On Failure    performance_snapshot.Extract Crash From SosReport
        ELSE
            Log    SosReport Collection Failed    level=WARN
        END
    END

Test Case Teardown Resource Usage
    [Arguments]    ${subfolder}=${RL_PATH.resources_usage}
    perf_resource_usage.Get Resources Usage    label=tc_teardown     subfolder=${subfolder}    # resources_usage_tc_teardown.json
    perf_resource_usage.Add Exclude Resources    ${TP.CFG_RESOUCE_USAGE_EXCLUDE}

    # CNI120470
    Run Keyword And Continue On Failure    perf_resource_usage.Check NbOfActiveUEs    label=tc_teardown    subfolder=${subfolder}

    performance_log_collection.Verify Resource Usage With Suppress Log    on_air    tc_teardown    subfolder=${subfolder}    label=tc_teardown


Restore Testline Configuration
    IF    "${TP.SCF_ENABLE_CB008246}"=="true"    performance_egate.Restore UE Capabilities
    IF    ${GNB_SCF_IS_MODIFIED} and "${TP.ENABLE_RESTORE_SCF_ON_TC_TEARDOWN}"=="true"
    ...     Run Keyword And Warn On Failure    performance_commissioning.Restore SCF
    IF    "${TP.ENABLE_SWCONFIG_REVERT}"=="true"
        Log To Console    ${SPACE} - Reload stored swconfig
        gnb.Reload Stored Swconfig To GNB
        wts_ue.Reload Stored Swconfig To Airphone
    END


Required TC Teardown Checks
    IF    "${TP.ENABLE_NETCAT}"!="false"                          Stop Netcat For Tracing Perf
    # For Multi VM But also backwards compatible with single VM.
    ${is_pass}    wts_multivm_helper.Deregister All Ues    ${tl}
    IF   ${is_pass}
        Log To Console    Successfully triggered deregister all UEs on all VMs
        Sleep    10s   reason=Wait for Deregister All UEs, [improvement] use performance_multivm.Wait Until Expected UE Count Reached
    END
    IF    "${TP.ENABLE_RESOUCE_USAGE}"=="true"                    Run Keyword And Continue On Failure
    ...                                                               Test Case Teardown Resource Usage
    IF    "${TP.ENABLE_SRS_INFO}"=="true" and ${TC_SIB_STATUS} and ${TC_AP_CELL_STATUS}
    ...                                                           performance_btslog.Print SRS Info From BTS Log
    IF    "${TP.ENABLE_EGATE_ERROR_CHECK}"=="true"                performance_egate.Check For Egate Errors


Optional TC Teardown Checks
    performance_test_setup.Process SOS Report
    IF    "${TP.ENABLE_BEARER_STATS_COLLECTION}"=="true"    performance_egate.Setup Bearer Stats Egate Alias
    IF    "${TP.ENABLE_RESOUCE_USAGE}"=="true"              Run Keyword And Continue On Failure
    ...                                                     perf_resource_usage.Get Resources Usage
    ...                                                         label=tc_setup
    ...                                                         subfolder=${RL_PATH.resources_usage}    # resources_usage_tc_setup
    IF    "${TP.ENABLE_PERFSHOT}"=="true"                   perf_perfshot.Prepare Perfshot
    IF    "${TP.ENABLE_MARVIN}"=="true"                     performance_reporting.Stop Marvin    # fallback Stop, if the TC failed to stop marvin
