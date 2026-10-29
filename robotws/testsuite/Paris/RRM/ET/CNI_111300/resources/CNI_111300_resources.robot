*** Settings ***

Documentation
...   author: Aleksandra Zbieg
...   maintainer: Aleksandra Zbieg
...   contact: aleksandra.zbieg@nokia.com
...   description: Common resources for CNI_111300

Library    ta5g_enb
Library    ute_wtssim
Library    ta5g_egate
Library    ta5g_pm_counters
Library    OperatingSystem
Library    String
Library    taf.sw.scout                                                          WITH NAME    scout
Library    taf.sw.reporting_portal                                               WITH NAME    reporting_portal

Resource   ../../../../resources/SWENG/robot/Setup.robot

Library    testsuite.Paris.RRM.ET.resources_KRK.python.common_gnb            WITH NAME    common_gnb
Library    testsuite.Paris.RRM.ET.resources_KRK.python.common_wts            WITH NAME    common_wts
Library    testsuite.Paris.RRM.ET.resources_KRK.python.dcap.Dcap             WITH NAME    dcap
Library    testsuite.Paris.RRM.ET.resources_KRK.python.tshark_operations     WITH NAME    tshark
Library    testsuite.Paris.RRM.ET.resources_KRK.python.sw_config_modifier.SwConfigModifier      WITH NAME    sw_mod

Library    testsuite.Paris.RRM.ET.CNI_111300.resources.CNI_111300_resources         WITH NAME    _internal
Library    testsuite.Paris.RRM.ET.CNI_111300.resources.CNI_111300_validation        WITH NAME    _validation
Library    testsuite.Paris.RRM.ET.CNI_111300.resources.CNI_111300_logs_collector.LogsCollector    WITH NAME    _logs

Resource   taf/rfrl/common_resources/robot/libraries_instances.robot

Variables  variables.py


*** Keywords ***

Suite Setup
    Create Directory    ${OUTPUT_DIR}/${SUITE_NAME}
    common_wts.Configure IPs On VM Interfaces
    ...    sim_gnb=${False}
    _internal.Add eNB XP IP Address
    sw_mod.Activate L2 PS Debug Logging
    ...    reboot=${False}
    common_gnb.Collect SCF File
    ...    final_path=${OUTPUT_DIR}/${SUITE_NAME}/basic_scf.xml
    _internal.Modify SCTP Timeout

Test Setup
    [Arguments]    ${reboot}=${True}    ${delta}=None    ${scell_activation_method}=None    ${mib_dict}=None
    Create Directory    ${OUTPUT_DIR}/${TEST_NAME}
    _logs.Set Test Log Path
    _logs.Start Collecting Syslog
    _internal.Modify Iphy
    _internal.Perform SCF Reconfiguration
    ...    delta_path=${delta}
    ...    scell_activation_method=${scell_activation_method}
    _internal.Send SCF To Change Cell Technology
    common_gnb.Wait For Requested BTS State
    ...    bts_state=configured
    ${wts_config_filepath}=    _internal.Prepare WTS Configuration File
    common_wts.Wait For Environment Prepared For WTS Ready State
    ...    validate_mib_sib=False
    ...    allow_first_reboot=${reboot}
    ...    wts_config_filename=${wts_config_filepath}
    _internal.Validate Info Block Messages
    ...    msg_dict=${mib_dict}
    _logs.Start Collecting Sosreport

Test Teardown
    _logs.Terminate All Background Tcpdump Processes
    _logs.Stop Collecting Syslog And Save Cfg Files
    _logs.Stop Collecting Sosreport
    common_wts.Stop WTS And Clear
    _internal.Restore Default Iphy
    _internal.Restore Default SCF
