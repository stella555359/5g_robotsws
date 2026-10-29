*** Settings ***

Documentation
...   author: Anna Bien
...   maintainer: Anna Bien
...   contact: anna.bien@nokia.com
...   description: Setups and Teardowns for CB010636

Library    BuiltIn
Library    ute_wtssim
Library    ta5g_enb
Library    ta5g_pm_counters
Library    testsuite.Krakow.RRM.Airphone.resources.Python.common_wts    WITH NAME    common_wts
Library    testsuite.Krakow.RRM.Airphone.resources.Python.common_gnb    WITH NAME    common_gnb
Library    testsuite.Krakow.RRM.Airphone.CB010636.resources.logs_collection.LogsCollectorWrapper    WITH NAME    _logs
Library    testsuite.Krakow.RRM.Airphone.CB010636.resources.validation.Validation         WITH NAME    _validation
Library    testsuite.Krakow.RRM.Airphone.CB010636.resources.wts_resources.WtsSetup        WITH NAME    _wts_cfg
Library    testsuite.Krakow.RRM.Airphone.CB010636.resources.wts_resources.WtsResources    WITH NAME    _wts
Library    testsuite.Krakow.RRM.Airphone.CB010636.resources.env_resources.EnvResources    WITH NAME    _env
Library    testsuite.Krakow.RRM.Airphone.CB010636.resources.utilities    WITH NAME    _util
Library    taf.converters.eventdecoder    WITH NAME    ctti
Library    taf.sw.scout                   WITH NAME    scout
Library    taf.sw.reporting_portal        WITH NAME    reporting_portal

Resource   taf/rfrl/common_resources/robot/libraries_instances.robot
Resource   testsuite/Krakow/RRM/Airphone/CB010636/resources/L3_files/CB010636_common.robot
Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables  variables.py
Variables  test_scenario_variables.py

*** Keywords ***
Suite Setup
    Create Directory    ${OUTPUT_DIR}/${SUITE_NAME}
    _util.Disable Cprt Debug Logs
    _logs.Collect Default SCFs
    _logs.Collect Default Iphy
    _logs.Enable Dcap
    _logs.Add Swconfig Flags For Tti Traces
    _logs.Add Swconfig Flags For Locall2lobursts
    _logs.Update UTF Lab
    _logs.Activate Scout Cli
    _env.Set Release Variable

Test Setup
    [Arguments]    ${delta_gnb1}=${None}    ${delta_gnb2}=${None}    ${reboot}=${False}    ${delta_reboot}=${True}    ${config_param_req}=${False}
    ...    ${scf_gnb1}=${None}
    _logs.Create Test Log Directory
    _logs.Start Collecting Syslog
    Wait Until Keyword Succeeds     300 sec     10 sec    _env.Perform Iphy Reconfiguration
    _env.Update Vlan ID In SCF
    Run keyword if    "${scf_gnb1}" != "${None}"   _env.Perform SCF Commissioning    ${scf_gnb1}
    _env.Perform Delta Recommissioning
    ...    delta_path_gnb1=${delta_gnb1}
    ...    delta_path_gnb2=${delta_gnb2}
    Run keyword if    ${delta_reboot} and ${config_param_req} == ${False}    common_gnb.Reset Units And Wait For Radio Head Online
    Run keyword if    ${delta_reboot} and ${config_param_req}    common_gnb.Reset Units
    Run keyword if    ${delta_reboot} and ${config_param_req}    BuiltIn.Sleep    120
    _logs.Start Syscom Collection For Selected TCs
    Run keyword if    ${delta_reboot} and ${config_param_req}    common_gnb.Wait For All Radio Modules To Be Online
    _wts_cfg.Setup WTS Environment
    ...    allow_first_reboot=${reboot}

Test Teardown
    [Arguments]    ${syslog_stopped_before}=${False}
    Run Keyword And Ignore Error    Add Main Bts Metadata To Report
    Produce Scout Data
    _logs.Collect Logs After Test
    common_wts.Stop WTS And Clear
    Run Keyword If    not ${syslog_stopped_before}    _logs.Stop Collecting Syslog And Download Files
    Wait Until Keyword Succeeds     300 sec     10 sec    _env.Restore Default Iphy
    _env.Restore Default SCFs

Call Scout Services
    [Documentation]                 Launch Scout services to produce data for RP.
    [Arguments]                     ${wait_for_success}    ${timeout}   ${use_scout_internal_id}    ${alias}
    ${scout_monitor_status}=        Run Keyword And Return Status
    ...                             scout.get_testline_monitor_status   alias=${alias}
    ${scout_scf_id}=                scout.request_scf                   wait_for_success=${wait_for_success}
    ...                                                                 timeout=${timeout}
    ...                                                                 use_scout_internal_id=${use_scout_internal_id}
    ...                                                                 alias=${alias}

Produce Scout Data
    [Documentation]                 Prepare Scout environment then call Scout service to produce data for Reporting Portal.
    [Arguments]                     ${wait_for_success}=True
    ...                             ${timeout}=60
    ...                             ${alias}=conn_alias
    ${status}    ${tl_name}=        Run Keyword and Ignore Error    _logs.get_testline_name
    Run Keyword and Ignore Error    scout.setup_scout               scout_testline_name=${tl_name}      alias=conn_alias
    ${use_scout_internal_id}=       Set Variable                    ${False}

    Run Keyword and Ignore Error    Call Scout Services             wait_for_success=${wait_for_success}
    ...                                                             timeout=${timeout}
    ...                                                             use_scout_internal_id=${use_scout_internal_id}
    ...                                                             alias=${alias}
    Run Keyword and Ignore Error    scout.teardown_scout_api        alias=${alias}
