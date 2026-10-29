*** Settings ***
Documentation
...    author: Damian Zak, Beata Kapusta
...    maintainer: Damian Zak, Beata Kapusta
...    contact: damian.zak@nokia.com, beata.kapusta@nokia.com
...    description: CB008709 common keywords

Library    OperatingSystem
Library    ute_syslog
Library    ute_wtssim
Library    ute_fsmaccess
Library    ta5g_egate
Library    ta5g_tshark
Library    ta5g_syslog
Library    ta5g_pm_counters
Library    ta_egate_cmd_parser
Library    ta5g_testline_management

Library    ET_common_keywords.py
Library    testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_airphone   WITH NAME    common_airphone
Library    testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.pm_counters                         WITH NAME  pm_counters
Library    testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb                          WITH NAME  common_gnb
Library    testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_wts                          WITH NAME  common_wts
Library    testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.slice_scheduling.dynamic_sas_delta  WITH NAME  dyn_sas_dlta

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Robot/TtiTrace/tti_trace_collector.robot

Variables    variables.py
Variables    deltas/delta_variables.py

*** Keywords ***
Suite Environment Preparation
    Create Directory    ${OUTPUT_DIR}/${SUITE_NAME}
    common_airphone.Log Airphone Build
    common_gnb.Log Gnb Build
    common_wts.Configure IPs On Vm Interfaces
    ...    cfg_filepath=/opt/wts/latest/basic_setup.cfg
    common_gnb.Collect SCF File
    ...    final_path=${OUTPUT_DIR}/${SUITE_NAME}/default_scf.xml

Common Test Environment Preparation
    [Arguments]    ${sib_reception_dict}=${ALL_CELLS_SIB_RECEPTION_DICT}   ${sas_configuration_data}=${None}
    ...            ${test_delta}=${None}    ${wts_config}=/opt/wts/latest/basic_setup.cfg
    Create Directory    ${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}
    Log To Console  Sending delta commissioning
    dyn_sas_dlta.Perform Delta Recomissioning
    ...    test_dir_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}
    ...    sas_configuration_data=${sas_configuration_data}
    ...    test_delta=${test_delta}
    common_gnb.Wait For All Radio Modules To Be Online
    Wait Until Keyword Succeeds    5min    30s    common_gnb.Assert BTS In State
    ...    bts_state=configured
    common_wts.Wait For Environment Prepared For Wts Ready State
    ...    wts_config_filename=${wts_config}
    ...    allow_first_reboot=False
    ...    timeout=${60}
    ...    sib_reception_dict=${sib_reception_dict}
    ute_syslog.Start Syslog
    ...   log_dir=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}
    ...   log_name=syslog.log
    ...   ip=192.168.255.126
    ...   ports=51000
    ...   add_line_number=True
    common_wts.Start Collecting Ueapp Sosreport

Test Environment Teardown
    Log To Console  \nStart Teardown
    ute_syslog.Stop Syslog
    common_gnb.Collect SCF File
    ...    final_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/modified_scf.xml
    Run Keyword If Test Passed    common_wts.Stop Collecting Ueapp Sosreport
    ...    destination_path_for_sosreport=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}
    ...    ue_app_options=-o
    Run Keyword If Test Failed    common_wts.Stop Collecting Ueapp Sosreport
    ...    destination_path_for_sosreport=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}
    common_wts.Stop WTS And Clear
    Wait Until Keyword Succeeds    5min    30s    common_gnb.Perform gNB Commissioning
    ...    scf_file=${OUTPUT_DIR}/${SUITE_NAME}/default_scf.xml


Wait For SAS PM Counters And Collect TTI
    ${timestamp} =    Get Time
    Log To Console    Wait for full PM interval with traffic to start
    ta5g_pm_counters.Wait For Next Full Pm Interval
    Log To Console    Collect TTI Traces
    Start TTI Trace Collection    yaml_config_path=${CURDIR}/tti_config.yaml
    Stop TTI Trace Collection    target_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/tti_trace_${timestamp}
    Log To Console    Wait for full PM interval with traffic to end
    ta5g_pm_counters.Wait For Next Full Pm Interval
