*** Settings ***
# https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=5GFTPARIS&title=ET+Coding+Rules
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     [SUITE PURPOSE]   Configuration related to common Scenario keywords for feature
...               Prerequisite :
...               Scope : Common keywords for feature
#
...               Test Case Scenario author   : christophe.samson@nokia.com
...               Creation Date               : 2024-10-08
...               Modified Date               : 2024-10-08
...               Last Modified by            : christophe.samson@nokia.com
...               Version   Date          Author                                   Notes
...               0.1       08-10-2024    christophe.samson@nokia.com              Creation
# --------------------------------------------------------------------------------------------------------------------------------------------------

# Libraries
Library                                         BuiltIn
Library                                         DateTime
Library                                         OperatingSystem
Library                                         ute_wtssim
Library                                         taf.wts.runner    WITH NAME    wtsemu
Library                                         taf.config.scf    WITH NAME    scf
Library                                         taf.sbts.oam.coam.admin    WITH NAME    sbts_coam
Library                                         ../../../../../../resources/SWENG/python/CoamParameter.py    WITH NAME    coam_parameter
Library                                         ../../../../../../resources/SWENG/python/ScfVendorOperations.py
Library                                         ../../../../resources/python/luashark_tools.py
Library                                         luashark_tools.analyzer       WITH NAME       analyzer

# Libraries Feature
Library                                         ../python/template_functions.py    WITH NAME       template
Library                                         ../python/tools.py                 WITH NAME       nps_feature_tools
Library                                         ../python/Dev_lib.py
Library                                         ../python/scf_gnb.py               WITH NAME       scf_gnb
Library                                         ../python/Tti-lib.py               WITH NAME       Tti-lib
Library                                         ../../../../resources/DSS/python/robot_extension.py  WITH NAME    robot_extension
Library                                         ../python/pmcounter_throughput_evaluator.py          WITH NAME    pmcounter_throughput
Library                                         ../python/pmcounter_bler_evaluator.py                WITH NAME    pmcounter_bler

# Resources
Resource                                        ../../../../../../resources/SWENG/robot/GenericTest.robot
Resource                                        ../../../../../../resources/SWENG/robot/CallSetup.robot
Resource                                        ../../../../../../resources/SWENG/robot/Capture.robot
Resource                                        ../../../../../../resources/SWENG/robot/Counters.robot
Resource                                        ../../../../../../resources/SWENG/robot/KPIs.robot
Resource                                        ../../../../../../resources/SWENG/robot/PacketSearch.robot
Resource                                        ../../../../../../resources/SWENG/robot/Restart.robot
Resource                                        ../../../../../../resources/SWENG/robot/Scf.robot
Resource                                        ../../../../../../resources/SWENG/robot/SetConfig.robot
Resource                                        ../../../../../../resources/SWENG/robot/Syslogs.robot
Resource                                        ../../../../../../resources/SWENG/robot/Tools.robot
Resource                                        ../../../../../../resources/SWENG/robot/Traffic.robot
Resource                                        ../../../../resources/common/TtiTrace/ttitrace.robot

# Resources Dss
Resource                                        ../../../../resources/DSS/robot/common_Dss_CellSetup.robot

# Resources Feature
Resource                                        GenericSuiteTest.robot
Resource                                        testline-Keywords.robot
Resource                                        btslog.robot
Resource                                        snapshot.robot
Resource                                        bip_trace.robot
Resource                                        bip_trace_ap.robot
Resource                                        resource_ttitrace.robot
Resource                                        ute-wtssim-ue-Keywords.robot
Resource                                        TARF-Keywords.robot
Resource                                        pmcounters.robot
Resource                                        commissioning.robot
Resource                                        dcap.robot
Resource                                        reporting.robot
Resource                                        configuration_id.robot

Variables                                       ./TRF_variables.yaml

*** Variables ***
${TestSharkTool}                                MC_SHARK
@{protocol_exclusion}                           ARP    UDP   ICMP   TCP
${AUTO_SAVE_DEBUG_DATA}                         ${False}

# position of filter for the corresponding message into list_filters_messages
${pos_filter_dldata_csirssendreq}               0
${pos_filter_dldata_pdcchsendreq}               1
${pos_filter_dldata_pdschsendreq}               2
${pos_filter_uldata_prachreceivereq}            3
${pos_filter_uldata_pucchreceivereq}            4
${pos_filter_uldata_puschreceivereq}            5
${pos_filter_uldata_srsreceivereq}              6

${ENABLE_AP_SCTP_CHANGE}    ${False}

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
*** Keywords ***

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
# Common Kw Run Test Case
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Activate Internal Tracing for TTI Trace
    ${distName}=    Run Keyword  Get distNames from Local SCF File    scf_path=${test_scf_file}
    ...                        regex=MRBTS-[0-9]+/MNL-[0-9]+/MNLENT-[0-9]+/TRBLCADM-[0-9]
    Run Keyword  scf.modify scf element    value=true  dist_name=${distName[0]}  p_name=actInternalTrace


Retreive gNB sw version
    ${current_gnb_sw}=  Run Keyword  Get gNB SW version
    Append to file  ${OUTPUT_DIR}/sw_version.txt  ${current_gnb_sw}
    [Return]  ${current_gnb_sw}


Get Cell Dist Parameters
    ${cell_distName_params}=  Run Keyword  Get distNames from Local SCF File    scf_path=${test_scf_file}
    ...                                  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${cell_distName_params}
    Set Suite Variable  ${cell_distName_params}


Suite Setup for Airphone
    [Documentation]    Collect all needed configuration to bring TL back to status
    ...    AirphoneConfig.xml, basic.cfg, ap_swconfig, gnb_swconfig, SCF
    ...    Upload needed config file to TL
    run keyword and ignore error  Set SW Duplex Variable according to cellTechnology
    run keyword and ignore error  Set SW Wavelength Variable according to nrarfcn
    Run Keyword  testline-Keywords.Set Console Output  Output=${True}    # Enable Console output (by default)
    Get config info for cOAM
    Backup SCF From Classical gNB
    BuiltIn.log variables
    Reinitialize gNB if required
    Get Cell Dist Parameters

Backup SCF From Classical gNB
    ${original_gnb_scf}  COAM Get SCF   local_dir_path=${configuration_directory}   file=SCFC_gNB0_DU_orig.xml   alias=coam_gnb
    set suite variable    ${original_gnb_scf}

Bring cell on air
    [Arguments]  ${cell_setup_trace_dir}=${ts_log_dir}/cell_setup_trace_initial
    run keyword and ignore error    Run Keyword    Ue-Wts-Commands-Keywords.Kill WTS Services
    Run Keyword if  "${logs_and_traces_flags["CellSetup_Syslogs"]}"=="True"    Prepare and Start Syslogs
    Run Keyword if  "${logs_and_traces_flags["CellSetup_BH"]}"=="True"    Start BH trace
    ${cell_setup_trace_required}=  Set Variable If  '${logs_and_traces_flags['CellSetupL2_L3Trace']}'=='True'  ${TRUE}  ${FALSE}
    ${status}  Run Keyword and Return Status  Variable should exist  ${scenario_name}
    ${scenario_name}  Set Variable if  not ${status}  initial
    ${status}=  Run keyword and ignore error  Variable should not exist  ${force_reboot}
    Run Keyword if  "${logs_and_traces_flags["CellSetup_AP_Syslogs"]}"=="True"    Run Keywords
    ...               Create Directory  ${ts_log_dir}/${scenario_name}_cell_setup_ap_UDP_trace
    ...     AND       Prepare and Start AP Syslogs    target_dir=${ts_log_dir}/${scenario_name}_cell_setup_ap_UDP_trace
    Start/Stop TTI/BIP/DCAP Traces  call_location=during_cellsetup  collector_name=cell_setup_trace_initial
    ${status}=  Run Keyword if  '${status[${0}]}'=='PASS'  Run Keyword and ignore error  Run Keyword
    ...    Bring Airphone TL to on Air status without reboot
    ...        capture_cell_setup_trace=${cell_setup_trace_required}
    ...        cell_setup_trace_dir=${ts_log_dir}/cell_setup_trace_initial
    Start/Stop TTI/BIP/DCAP Traces  call_location=after_cellsetup  collector_name=cell_setup_trace_initial
    ${status}  Run Keyword if  ${status}==None  Create List  FAIL  ELSE  Create List  ${status[${0}]}
    run keyword if  '${status[${0}]}'=='FAIL' and '${w_cellsetup_w_reboot}'=='True'
    ...                                             BuiltIn.Log to console  Bring cell on air without reboot failed, trying with reboot
    run keyword if  '${status[${0}]}'=='FAIL' and '${w_cellsetup_w_reboot}'=='True'  Run Keyword     Bring Airphone TL to on Air status
    ...  capture_cell_setup_trace=${cell_setup_trace_required}
    ...  cell_setup_trace_dir=${cell_setup_trace_dir}
    Run keyword       Test-Suite-Setup-Resources-Keywords.Kw Check Syslog and Alarms
    Run keyword If   "${logs_and_traces_flags["CellSetup_Syslogs"]}"=="True"  Stop BTSLog Collection  ${scenario_name}_cell_setup_trace
    ...    ELSE                                                               Create Directory  ${ts_log_dir}/${scenario_name}_cell_setup_trace
    robot_extension.Run Keyword And Warn On Failure    TARF-Keywords.Extract l2::ps::cell::CellSetupReq_t and CellSetupResp_t from Syslog
    ...                                                                       testCaseDir=${ts_log_dir}/${scenario_name}_cell_setup_trace
    Run keyword If   "${logs_and_traces_flags["CellSetup_AP_Syslogs"]}"=="True"  Stop APLog Collection  ${scenario_name}_cell_setup_ap_UDP_trace
    ...    ELSE                                                         Create Directory  ${ts_log_dir}/${scenario_name}_cell_setup_ap_UDP_trace
    ${gnb_rebooted}=  Set Variable  ${True}
    Run Keyword if  ${cell_setup_trace_required}  Convert Cell Setup Trace from PCAP to PDML  trace_dir=${ts_log_dir}/cell_setup_trace_initial
    Set Suite Variable    ${gnb_rebooted}
    run keyword if  '${status[${0}]}'=='FAIL' and '${w_cellsetup_w_reboot}'!='True'
    ...        Run Keywords       Set Global Variable     ${setup}    fail
    ...          AND              FAIL    cellsetup FAILED!!
    [teardown]    Run Keyword if  "${logs_and_traces_flags["CellSetup_BH"]}"=="True"    Stop BH Trace    ${scenario_name}_cell_setup_trace

Bring Dss cell on air
    ${status}=    Run Keyword and ignore error   Run Keywords
    ...            GenericSuiteTest.Init Test Sequence    ${TestDSSContext}
    ...    AND     update Dss Specific parameters    ${TestDSSContext}
    ...    AND     common_Dss_CellSetup.DSS_CRM_Cell_Setup_Phase3_complete    alias=ap_egate    wtsObj=${wtsObj}
    BuiltIn.Sleep   5s   reason=waiting for Airphone stabilized
    ${status}  Run Keyword if  ${status}==None  Create List  FAIL  ELSE  Create List  ${status[${0}]}
    run keyword if  '${status[${0}]}'=='FAIL'
    ...        Run Keywords       Set Global Variable     ${setup}    fail
    ...          AND              FAIL    cellsetup FAILED!!
    GenericSuiteTest.Step     Verify Cell Setup

Convert Cell Setup Trace from PCAP to PDML
    [Arguments]  ${trace_dir}
    Run Keyword  TARF-Keywords.Convert local PCAP to PDML  source=${trace_dir}/l2_l3_syscom_tcpdump.pcap    filter="sctp && icom_5g"
    ...  target=${trace_dir}/l2_l3_syscom_tcpdump.pdml


teardown Intialize Test Suite
    BuiltIn.Run Keyword And Warn On Failure     TARF-Keywords.Extract L2-PS/src/sgnl/psCell/CellSetupLogger from Syslogs
    ${dir_syslog}=    testcase-Keywords.Prepare Logs Directory Path     resultDir=${LOG_PATH}    subdir=btslog2_Intialize_Test_Suite
    ${ret}    ${syslogpath}=     BuiltIn.Run Keyword And Warn On Failure   btslog.Stop Btslog    target_dir=${dir_syslog}
    ${fileExists}=     nps_feature_tools.file_exists   ${syslogpath}
    IF    ${fileExists}
        ${is_error_not_in_syslogs}=    syslogs_analysis.check_no_fatality_error_in_syslogs    path_to_syslog_tgz=${syslogpath}
        BuiltIn.run keyword and continue on failure    should be True    ${is_error_not_in_syslogs}
    END

Initialize Test Suite
    GenericSuiteTest.Init Suite Test Sequence
    # ${host_vm_ip}=  configuration_id.Get Host IP Address  host_index=1
    # Run Keyword And Ignore Error  configuration_id.Start Testline Scout Monitor  host_vm_ip=${host_vm_ip}
    # ${deployment_type}=  Run Keyword  Get Node Deployment Type
    GenericSuiteTest.Step    Scenario-Common-Keywords.Read Test Configuration from JSON File
    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog
    ${ueType}=    Get UE type
    Run Keyword If    '${ueType}' == 'airphone'     Suite Setup for Airphone
    ...    ELSE                                     BuiltIn.log    UE type ${ueType} FAILED!    level=ERROR
    ${are_test_scenarios_run}=  set variable  False
    set suite variable   ${are_test_scenarios_run}
    ${SOS_report_collected}=  set variable  False
    set suite variable   ${SOS_report_collected}
    GenericSuiteTest.Display diagnosis Suite Test
    # run keyword and ignore error    reporting.Set SCOUT TC ID for Reporting
    [teardown]    Run Keyword    teardown Intialize Test Suite


Run Test Scenario
    GenericSuiteTest.Init Sequence
    ${tc_log_dir}=  testcase-Keywords.Get testcase log directory
    set suite variable  ${tc_log_dir}
    return from keyword if  '${are_test_scenarios_run}'=='True'
    &{collector_dict}=  template.create_collector_dict  ${TEST TAGS}
    ${run_test_start_time}=  nps_feature_tools.get_current_time
    run keyword and continue on failure    Run planned scenarios required for test  ${collector_dict}
    ${run_test_end_time}=  nps_feature_tools.get_current_time
    ${run_test_time}=  nps_feature_tools.get_elapsed_time  start_time=${run_test_start_time}  end_time=${run_test_end_time}
    ${run_test_time_in_minutes}=    Evaluate     ${run_test_time} / 60
    ${run_test_time_in_minutes}=    Evaluate     round(${run_test_time_in_minutes})
    ${run_test_time_in_minutes}=    Set Variable If    ${run_test_time_in_minutes} < ${10}    10minutes   ${run_test_time_in_minutes}minutes
    ${is_with_pm_counters_sce}=    Is pm counters activated for at least one scenario    ${collector_dict}
    Run Keyword if  ${is_with_pm_counters_sce}     run keyword and continue on failure    GenericSuiteTest.Step
    ...     Scenario-Common-Keywords.Collect PM Counters and process throughput using PM counters  duration=${run_test_time_in_minutes}
    run keyword and continue on failure    GenericSuiteTest.Step     Process TTI Traces for all scenarios
    ${are_test_scenarios_run}=  set variable  True
    set suite variable   ${are_test_scenarios_run}
    run keyword and continue on failure    GenericSuiteTest.Display diagnosis

Read Test Configuration from JSON File
    ${is_classical}=  set variable   ${True}
    set suite variable  ${is_classical}
    template.initialize_test  path_to_basic_cfg=${tl.core.dir_path}/${tl.core.cfg_filename}
    ...                       modified_file_path=${tl.core.dir_path}/${tl.core.cfg_filename}
    ...                       relative_path_to_json=${relative_json_path}
    ...                       is_classical=${is_classical}
    ${json_file_path}=  template.Get Json File Path
    ${json_raw_data}=     OperatingSystem.get file    ${json_file_path}
    ${json_dictionary}=   evaluate    json.loads('''${json_raw_data}''')    json
    ${logs_and_traces_flags}=  template.get_logs_and_traces_flags
    ${extra_options_flags}=  template.get_extra_options_flags
    ${variable_cell_dict}=  template.get_variable_cell_dict
    FOR  ${key}  IN  @{variable_cell_dict}
        set suite variable  ${${key}}  ${variable_cell_dict}[${key}]
    END
    set suite variable    ${scenario_configuration}    ${json_dictionary['scenario_configuration']}
    set suite variable    ${test_description}          ${json_dictionary['test_description']}
    set suite variable    ${logs_and_traces_flags}
    set suite variable    ${extra_options_flags}
    set suite variable    ${ue_profiles}      ${json_dictionary['ue_profiles']}
    set suite variable    ${csi_report_profiles}      ${json_dictionary['csi_report_profile']}
    Run Keyword And Ignore Error    nps_feature_tools.display_dictionnary_parameters_of_the_TestCase    ${scenario_configuration}
    ...                                                                                               title=scenario_configuration
    Run Keyword And Ignore Error    nps_feature_tools.display_dictionnary_parameters_of_the_TestCase    ${test_description}
    ...                                                                                               title=test_description
    Run Keyword And Ignore Error    nps_feature_tools.display_dictionnary_parameters_of_the_TestCase    ${logs_and_traces_flags}
    ...                                                                                               title=logs_and_traces_flags
    Run Keyword And Ignore Error    nps_feature_tools.display_dictionnary_parameters_of_the_TestCase    ${extra_options_flags}
    ...                                                                                               title=extra_options_flags
    Run Keyword And Ignore Error    nps_feature_tools.display_dictionnary_parameters_of_the_TestCase    ${ue_profiles}
    ...                                                                                               title=ue_profiles
    Run Keyword And Ignore Error    nps_feature_tools.display_dictionnary_parameters_of_the_TestCase    ${csi_report_profiles}
    ...                                                                                               title=csi_report_profiles

Save Resource Usage to File
    [Arguments]  ${collection_point}
    taf.ccs.aashell.Create Aashell Cli    name=aashell
    taf.ccs.aashell.Setup    aashell
    ${resources_usage}=    taf.ccs.aashell.Get Resources Usage    aashell
    Create Directory    ${ts_log_dir}/resource_stats
    nps_feature_tools.write_dictionary_to_json  dir_path=${ts_log_dir}/resource_stats
    ...  dictionary=${resources_usage}   filename=${scenario_name}_${collection_point}.json
    [Teardown]  taf.ccs.aashell.Teardown  aashell

Run planned scenarios required for test
    [Arguments]  ${collector_dict}
    @{collector_names}=    create list
    ${pm_offsets}=  create dictionary
    ${scenario_pm_index}=  set variable  ${0}
    @{scenario_names}=  Get Dictionary Keys    ${collector_dict}
    ${tti_init_required}=  Check if TTI Trace needs to be Reinitialized  re_init=${reinitialize_required}
    Run Keyword if  '${logs_and_traces_flags['DCAP']['collection']}'=='True'  GenericSuiteTest.Step     Start DCAP container
    Run Keyword if  ${tti_init_required}  GenericSuiteTest.Step   Create TTI-Trace Collectors for all Scenarios  scenario_names=${scenario_names}
    FOR    ${scenario_name}    IN   @{scenario_names}
        Set Suite Variable    ${scenario_name}
        ${is_with_pm_counters}=  template.is_with_pm_counters   ${scenario_name}
        ${special_keywords}=  template.get_special_keywords_for_scenario  ${scenario_name}
        ${nbr_special_keywords}=    BuiltIn.Get Length    ${special_keywords}
        Run Keyword if  ${nbr_special_keywords} != 0    BuiltIn.Log    special keywords list to execute : ${special_keywords}    console=yes
        ...    ELSE                                     BuiltIn.Log    no special keywords to execute!!!    console=yes
        # BuiltIn.Log    ${special_keywords}    console=yes
        run keyword if  ${is_with_pm_counters}
        ...     GenericSuiteTest.Step     Scenario-Common-Keywords.Wait for new pm filename
        ${scenario_prep_start_time}=  nps_feature_tools.get_current_time
        ${collector}=  template.get_collector_name     ${scenario_name}
        set to dictionary  ${collector_dict["${scenario_name}"]}  collector_name=${collector}
        Start/Stop TTI/BIP/DCAP Traces  call_location=before_config_change  collector_name=${collector}
        GenericSuiteTest.Step     Execute Scenario specific configuration change    scenario_name=${scenario_name}
        GenericSuiteTest.Step     Run Scenario specific Keywords before Scenario Execution  ${special_keywords}
        Start/Stop TTI/BIP/DCAP Traces  call_location=after_config_change  collector_name=${collector}
        ${scenario_prep_end_time}=  nps_feature_tools.get_current_time
        ${scenario_prep_time}=  nps_feature_tools.get_elapsed_time  start_time=${scenario_prep_start_time}  end_time=${scenario_prep_end_time}
        ${pm_offset}=  nps_feature_tools.identify_pm_counter_index_offset
        ...    defined_pm_interval=${pm_reporting_interval}
        ...    elapsed_time_in_interval=${scenario_prep_time}
        set to dictionary  ${pm_offsets}  ${collector}=${pm_offset}
        set to dictionary  ${collector_dict["${scenario_name}"]}  pm_offset=${pm_offset}
        set to dictionary  ${collector_dict["${scenario_name}"]}  pm_index=${scenario_pm_index}
        ${scenario_pm_index}=  evaluate  ${scenario_pm_index} + ${1}
        ${tti_init_required}=  Check if TTI Trace needs to be Reinitialized
        run keyword if  ${tti_init_required}
        ...                     GenericSuiteTest.Step  Create TTI-Trace Collectors for all Scenarios  scenario_names=${scenario_names}
        GenericSuiteTest.Step    Save Resource Usage to File  collection_point=before_scenario
        ${pm_counter_start_before_L3}=  template.pm_counter_start_before_L3  ${scenario_name}
        run keyword if  ${pm_counter_start_before_L3}
                ...    GenericSuiteTest.Step    Scenario-Common-Keywords.Wait for new pm filename
        ${is_with_pm_counters}  Set Variable If    ${is_with_pm_counters} or ${pm_counter_start_before_L3}  ${True}  ${False}
        ${kw_status}=    run keyword and return status   5G L3 Call with traffic   &{collector_dict["${scenario_name}"]}
        # run keyword and continue on failure    should be True     ${kw_status}
        run keyword if    not ${kw_status}    BuiltIn.log    L3 CALL on ${scenario_name} FAILED!    level=ERROR
        run keyword if    not ${kw_status}    GenericSuiteTest.Step
        ...                                           Stop and collect running traces  collector_name=${collector}  scenario_name=${scenario_name}
        run Keyword if    ${is_classical}     GenericSuiteTest.Step    Save Resource Usage to File  collection_point=after_scenario
        run Keyword if    '${logs_and_traces_flags['DCAP']['collection']}'=='True'
        ...                                   GenericSuiteTest.Step     Collect DCAP Traces  target_dir=${ts_log_dir}/dcap_${collector}
        append to list    ${collector_names}    ${collector}
    END
    Log Dictionary    ${collector_dict}
    GenericSuiteTest.Step    Collect TTI-Traces For all Scenarios  ${scenario_names}  ${collector_dict}
    run keyword if  ${is_with_pm_counters}
    ...    run keywords
    ...        Run Keyword  Scenario-Common-Keywords.Wait for new pm filename  AND
    ...        create directory  ${ts_log_dir}/PMC/gnb_pm_counters       AND
    ...        nps_feature_tools.post_process_pmc_indices
    ...            collector_dict=${collector_dict}
    ...            dir_path=${ts_log_dir}/PMC/gnb_pm_counters
    ...            max_scenario_pm_index=${scenario_pm_index}
    set suite variable  ${collector_names}


Wait for new pm filename
    Run Keywords        robot_extension.Run Keyword And Warn On Failure
    ...                        resources.wait for new pm filename and display message
    ...                                                               raw_file=${False}    timeout=${600}
    ...  AND            dated log    End of Wait for new pm file

Display_wait_counters_message
    ${timestamp_msg}=   DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    BuiltIn.log      [${timestamp_msg}]: wait for new pm file     level=INFO   console=True

Check if TTI Trace needs to be Reinitialized
    [Arguments]  ${re_init}=${True}
    ${tti_init_required}=  Evaluate  ${gnb_rebooted} or not ${re_init}
    ${gnb_rebooted}=  Set Variable if  ${gnb_rebooted}  ${False}
    Set Suite Variable  ${gnb_rebooted}
    [Return]  ${tti_init_required}

Is pm counters activated for at least one scenario
    [Arguments]  ${collector_dict}
    @{scenario_names}=  Get Dictionary Keys    ${collector_dict}
    FOR    ${scenario_name}    IN   @{scenario_names}
        ${is_with_pm_counters_sce}=  template.is_with_pm_counters   ${scenario_name}
        IF    ${is_with_pm_counters_sce}    BREAK
    END
    [return]    ${is_with_pm_counters_sce}

Reinitialize gNB if required
    ${reinitialize_required}=    Get Variable Value    ${REINIT_GNB}
    ${reinitialize_required}=    Set Variable If    '${reinitialize_required}' == 'false'    ${False}    ${True}
    Set Suite Variable  ${reinitialize_required}
    ${gnb_rebooted}=  Set Variable  ${False}
    Set Suite Variable  ${gnb_rebooted}
    run keyword if    not ${reinitialize_required}  BuiltIn.Log  gNB will not be Reinitialized, test will run with existing SCF and basic config
    ...  level=WARN
    Run Keyword If  ${reinitialize_required}  Scenario-Common-Keywords.Initialize gNB
    ...  ELSE    Connect to running EGATE

Connect to running EGATE
    return from Keyword

Execute Scenario specific configuration change
    [Arguments]  ${scenario_name}
    ${config_change_needed}  ${change_params}=  template.is_scenario_modifications_configured  ${scenario_name}
    Run Keyword If  ${config_change_needed}
    ...  Log to console  Following SCF Paramaters will be changed for ${scenario_name}: ${change_params}
    Run Keyword If  ${config_change_needed}  Change Scenario configuration  scenario_name=${scenario_name}
    ...  ELSE  Log to console  Scenario specific SCF changes not configured for: ${scenario_name}
    ${full_file_path}  COAM Get SCF   local_dir_path=${configuration_directory}   file=scf_${scenario_name}.xml   alias=coam_gnb

Get Scenario Name
    [Return]  ${scenario_name}


Get UE Ids configured for scenario
    [Arguments]  ${scenario_name}
    ${ue_ids_configured}=  template.get_ue_ids_configured_for_scenario  ${scenario_name}
    [Return]  ${ue_ids_configured}


Change Scenario configuration
    [Arguments]  ${scenario_name}
    ${current_scf}=
    ...  COAM Get SCF   local_dir_path=${configuration_directory}   file=scf_before_${scenario_name}_changes_revert.xml   alias=coam_gnb
    ${scf_content}=  OperatingSystem.Get File  ${current_scf}
    ${list_of_scf_modifications}  template.get_commissioned_object_list  ${scenario_name}  ${scf_content}
    ${cell_setup_trace_required_on_configuration_change}=
    ...    Set Variable If  '${logs_and_traces_flags['CellSetupL2_L3Trace']}'=='True'  ${TRUE}  ${FALSE}
    Run Keyword If   ${cell_setup_trace_required_on_configuration_change}   Start collection of Syscom L2 L3 trace
    Run Keyword  commissioning.Commission Managed Object List  ${list_of_scf_modifications}
    ${status}=  Run Keyword and Ignore Error  testline-Keywords.Wait until Node to be onair state  timeout=300 sec
    ${collector_name}=  template.get_collector_name  scenario_name=${scenario_name}
    Run Keyword If   ${cell_setup_trace_required_on_configuration_change}
    ...    Run keyword and ignore error  Stop collection of Syscom L2 L3 trace
    ...                                  syscom_trace_collector_name=syscom_l2_l3_change_config_${collector_name}
    Run Keyword if  '${status[${0}]}'=='FAIL'  Bring cell on air
    ...  cell_setup_trace_dir=${ts_log_dir}/cell_setup_trace_${scenario_name}
    return from keyword

Initialize gNB
    testline-Keywords.Backup WTS Config    basic_setup.cfg.orig
    GenericSuiteTest.Step     Make necessary Changes to SCF
    testline-Keywords.Fetch gNB Info From SCF    w_display=${False}
    # we work only with basic_setup.cfg !!!
    ${tl.core.cfg_filename}    set Variable     basic_setup.cfg
    template.configure_basic_cfg_file
    GenericSuiteTest.Step     Update Basic Configuration File
    testline-Keywords.Backup WTS Config
    GenericSuiteTest.Step     Bring cell on air  cell_setup_trace_dir=${ts_log_dir}/cell_setup_trace_initial

Create TTI-Trace Collectors for all Scenarios
    [Arguments]  ${scenario_names}
    ${bts_type}=    set variable if    ${is_classical}    classical    cloud
    Return from keyword if    '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
    ${phy_cell_ids}=  Get Dictionary Values  ${pCell_dict}  sort_keys=True
    ${phy_cell_ids}=    Catenate    SEPARATOR=,    @{phy_cell_ids}
    ${phy_cell_ids}=  Set Variable if  ${logs_and_traces_flags['TTITrace']['phy_cell_ids']}  ${logs_and_traces_flags['TTITrace']['phy_cell_ids']}

    ${source_ip}=   Run Keyword   resource_ttitrace.Get Source IP Address For Classical BTS
    ${dest_ip}=     Run Keyword   resource_ttitrace.Get Target IP Address For Classical Bts   source_ip_address=${source_ip}

    &{tti_collector_dict}=  Create Dictionary
    Set Suite Variable    ${tti_collector_dict}
    FOR    ${scenario_name}    IN   @{scenario_names}
        ${collector}=  Run Keyword   resource_ttitrace.Create TTI Trace Collector
        ...    bts_type=${bts_type}
        ...    nr_phy_cell_ids=${phy_cell_ids}
        ...    dest_ip=${dest_ip}
        ...    tti_trace_filename=ttitrace_streaming_${scenario_name}
        ...    tti_filter=${logs_and_traces_flags['TTITrace']['tti_filter']}
        Set To Dictionary  ${tti_collector_dict}  ${scenario_name}=${collector}
    END

Create TTI-Trace Collectors for all Scenarios version1
    [Arguments]  ${scenario_names}    ${trace_ip}=${EMPTY}
    ${bts_type}=    set variable if    ${is_classical}    classical    cloud
    Return from keyword if    '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
    ${phy_cell_ids}=  Get Dictionary Values  ${pCell_dict}  sort_keys=True
    ${phy_cell_ids}=    Catenate    SEPARATOR=,    @{phy_cell_ids}
    ${phy_cell_ids}=  Set Variable if  ${logs_and_traces_flags['TTITrace']['phy_cell_ids']}  ${logs_and_traces_flags['TTITrace']['phy_cell_ids']}
    ${dest_ip}=    Run Keyword    resource_ttitrace.Identify Destination IP for tti trace capture  ${bts_type}  ${trace_ip}
    &{tti_collector_dict}=  Create Dictionary
    Set Suite Variable    ${tti_collector_dict}
    FOR    ${scenario_name}    IN   @{scenario_names}
        ${collector}=  Run Keyword   resource_ttitrace.Create TTI Trace Collector
        ...    bts_type=${bts_type}
        ...    nr_phy_cell_ids=${phy_cell_ids}
        ...    dest_ip=${dest_ip}
        ...    tti_trace_filename=ttitrace_streaming_${scenario_name}
        ...    tti_filter=${logs_and_traces_flags['TTITrace']['tti_filter']}
        Set To Dictionary  ${tti_collector_dict}  ${scenario_name}=${collector}
    END


Collect TTI-Traces For all Scenarios
    [Arguments]  ${scenario_names}  ${collector_dict}
    return from keyword if    '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
    FOR    ${scenario_name}    IN    @{scenario_names}
        ${kw_status}=    run keyword and return status
        ...    Run Keyword    resource_ttitrace.Collect TTI Trace and teardown collectors
        ...                     desired_file_name=ttitrace_streaming_${scenario_name}
        ...                     desired_storage_directory=${ts_log_dir}/tti_trace_${collector_dict["${scenario_name}"]["collector_name"]}
        run keyword if    not ${kw_status}   BuiltIn.log    Collect TTI Trace and teardown collectors on ${scenario_name} FAILED!    level=ERROR
        run keyword and ignore error
        ...    move file
        ...        ${ts_log_dir}/tti_trace_${collector_dict["${scenario_name}"]["collector_name"]}/ttitrace_streaming_${scenario_name}.pcap
        ...        ${ts_log_dir}/tti_trace_${collector_dict["${scenario_name}"]["collector_name"]}/ttitrace_streaming.pcap
    END


Suite Setup CB012738-A-Common
    [Documentation]
    ...     Conditions:     it is based on the arguments ${keep_all_data_in_file}
    ...     Actions:        it performs the generic suite setup and backup the configurations files
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        suite setup is passed
    [Arguments]             ${keep_all_data_in_file}=${False}

    ${timestamp_suite_setup}=                   DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Suite Variable                          ${timestamp_suite_setup}
    Setup.Suite Setup From Scratch              automaticTeardown=${True}    keepAllUeDataInCfgFile=${keep_all_data_in_file}
    Backup Files                                                                                       #vbo#debug#
    ${scf_suite_setup_backup}=                  OAM Get SCF File    file=SCF_DU0_Backup.xml    #vbo#debug#
    Set Suite Variable                          ${scf_suite_setup_backup}                              #vbo#debug#
    Dated Log                                   ===> backup file is ${scf_suite_setup_backup}          #vbo#debug#
    ${scf_vcu_suite_setup_backup}=    Run Keyword If    ${isAic}    OAM Get Cu SCF File    file=SCF_CU0_Backup.xml    #vbo#debug#
    Run Keyword If    ${isAic}    Run Keywords    Set Suite Variable    ${scf_vcu_suite_setup_backup}    #vbo#debug#
    ...    AND    Dated Log                     ===> vcu backup file is ${scf_vcu_suite_setup_backup}    #vbo#debug#


Get Config Info for cOAM
    ${pCell_dict}=    Run Keyword    Get gNB Physical Cell ID From Classical
    Set Suite Variable    ${pCell_dict}


Get gNB Physical Cell ID From Classical
    [Documentation]
    ...
    ...     *Scope*  Internal
    ...
    ...     This TL specific keyword returns a dictionary with cell name (as in SCF) as the key
    ...     and the respective physical cell id as the value. It is recommended to use the dedicated
    ...     wrapper KW in the test suite `Get gNB Physical Cell ID`.
    ...
    ...     | gnb_id    | Id of gnb |
    ...
    ...     *Returns*   a dictionary with key cell name and the respective physical cell id
    ...
    [Arguments]   ${gnb_id}=0
    BuiltIn.log    gnb_id=${gnb_id}
    ${cell_list}   sbts_coam.get_cell_list   connection=coam_gnb
    ${_cell_phy_cell_id}   nps_feature_tools.get_phy_cell_ids   cell_info=${cell_list}
    [Return]   ${_cell_phy_cell_id}

Get distNames from Local SCF File
    [Documentation]
    ...
    ...     Searches for the given distname pattern in a locally stored SCF file. Together with
    ...     KW `Get SCF from gNB` it is the best choice to search for distnames in a common way from
    ...     classical, AiC DU or AiC CU scf file especially if one need to search different distnames
    ...     multiple times!
    ...
    ...     *Example*
    ...     | ${du_scf}    | COAM Get SCF   local_dir_path=${configuration_directory}   file=SCFC_gNB0_DU_orig.xml   alias=coam_gnb
    ...     | ${distnames} | Get distNames from Local SCF File | regex=MRBTS-[0-9]+ | scf_path=${du_scf} |
    ...     | ${distnames} | Get distNames from Local SCF File | regex=MRBTS-[0-9]+/NRBTS-[0-9]+ | scf_path=${du_scf} |
    ...
    ...     *Returns*   list of matching distnames
    ...
    [Arguments]   ${regex}   ${scf_path}
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${distNames}     nps_feature_tools.get_distNames_from_scf   regex=${regex}   scf_content=${scf_content}
    [Return]   ${distNames}

Get distNames from gNB SCF
    [Documentation]
    [Arguments]    ${regex}    ${gnb_id}=${0}
    BuiltIn.log    gnb_id=${gnb_id}
    ${scf_content}=  sbts_coam.get_scf  parameters_save_variant=actualValues   timeout=${10}    connection=coam_gnb
    ${distNames}=    scf_gnb.get_distNames_from_scf    regex=${regex}    scf_content=${scf_content}
    [Return]    ${distNames}

Verify Cell Setup
    ${total_cells}=     testline-Keywords.Get number of all configured NRCELLs
    ${scf_dss_type}=    testline-Keywords.Get Dss Info
    IF    '${scf_dss_type}'=='None'
        Dev_lib.wait_ng_link_up
    END
    set Suite Variable    ${testCaseDir}      ${LOG_PATH}
    Dev_lib.start_to_capture_infomodel_log
    All Available Cells Should Be Onair
    Dev_lib.stop_to_capture_infomodel_log
    return from Keyword

Bring Airphone TL to on Air status
    [Documentation]
    ...    This keyword is used for testcases, which need gnb on air as pre-condition
    ...    or this keyword can be used as testline recovery once testcase failed
    ...    by default, gNbCuType both will be handled as SA TL
    ...
    ...    | remove_logs              | remove existing wts logs |
    ...    | cfg_file                 | path of wts config file to be used |
    ...    | force_cu_type            | define SA / NSA TL if gNbCuType is configured as SA+NSA |
    ...    | capture_cell_setup_trace | Captures a tcpdump on the interface between L2-PS and CP-RT |
    ...    | cell_setup_trace_dir     | Places the captured L2-PS, CP-RT interface trace in the provided directory |
    ...    | kw_timeout               | overall TO for the whole KW |
    ...
    ...    *Example*
    ...
    ...    | Run Keyword If | '${PREV_TEST_STATUS}'=='FAIL' | Bring Airphone TL to on Air status |
    ...
    [Arguments]    ${remove_logs}=${False}    ${cfg_file}=${tl.core.cfg_filename}    ${force_cu_type}=SA+NSA   ${capture_cell_setup_trace}=${FALSE}
    ...            ${cell_setup_trace_dir}=${EMPTY}   ${kw_timeout}=30min
    [Timeout]      ${kw_timeout}
    GenericSuiteTest.Step     Bring Airphone TL to F1 up status
    Run Keyword If   ${capture_cell_setup_trace}   Start Trace on L2_PS CP_RT interface
    Configure WTS for UTE Cloud Airphone TL    remove_logs=${remove_logs}    cfg_file=${cfg_file}    force_cu_type=${force_cu_type}
    GenericSuiteTest.Step     Verify Cell Setup
    [Teardown]   Run Keyword If   ${capture_cell_setup_trace}
    ...             Run Keyword And Ignore Error    Stop Trace on L2_PS CP_RT interface   target_dir=${cell_setup_trace_dir}

Wait For Minimum Required State For Cell Setup
    [documentation]    use Kw from ../robotws/testsuite/Paris/resources/SWENG/robot/Restart.robot
    ...         improvements : use coam from taf instead AF Kw
    [Arguments]     ${timeout}=10min    ${check_based_AF}=False
    IF    '${check_based_AF}'=='True'
        F1 Wait Link Classical    timeout=${timeout}
        GNSS Check and run
        IRfHead Check Service
    ELSE
        testline-Keywords.Wait For Minimum Required State For Cell Setup For All gNBs    timeout=${timeout}
    END

Bring Airphone TL to on Air status without reboot
    [Documentation]
    ...    This keyword is used for Suite Setup, which need gnb on air as pre-condition without GNB reboot
    ...    by default, gNbCuType both will be handled as SA TL
    ...
    ...    | remove_logs              | remove existing wts logs |
    ...    | cfg_file                 | path of wts config file to be used |
    ...    | force_cu_type            | define SA / NSA TL if gNbCuType is configured as SA+NSA |
    ...    | capture_cell_setup_trace | Captures a tcpdump on the interface between L2-PS and CP-RT (not for AiC) |
    ...    | cell_setup_trace_dir     | Places the captured L2-PS, CP-RT interface trace in the provided directory (not for AiC) |
    ...    | kw_timeout               | overall TO for the whole KW |
    ...
    [Arguments]   ${remove_logs}=${False}   ${cfg_file}=${tl.core.cfg_filename}   ${force_cu_type}=SA+NSA   ${capture_cell_setup_trace}=${FALSE}
    ...           ${cell_setup_trace_dir}=${EMPTY}   ${kw_timeout}=15min
    [Timeout]     ${kw_timeout}
    GenericSuiteTest.Step     Wait For Minimum Required State For Cell Setup    timeout=10min
    Modify SCTP Settings on Test-VM and AP
    Run Keyword If   ${capture_cell_setup_trace}   Start Trace on L2_PS CP_RT interface
    Configure WTS for UTE Cloud Airphone TL    remove_logs=${remove_logs}    cfg_file=${cfg_file}    force_cu_type=${force_cu_type}
    GenericSuiteTest.Step     Verify Cell Setup
    [Teardown]   Run Keyword If   ${capture_cell_setup_trace}
    ...             Run Keyword And Ignore Error   Stop Trace on L2_PS CP_RT interface   target_dir=${cell_setup_trace_dir}

Reset Airphone Testline
    [Arguments]    ${timeout}=4min
    # Restart TL
    run Keywords     Dated Log new line       ${consTraceColor}=== Restart TL === ${defColor}
    ...    AND       Restart TL               isOAMRebooted=False     F1waitTime=${timeout}
    ...                                       GNBCallback=TARF-Keywords.Set Reset Loop Counter

Bring Airphone TL to F1 up status
    [Documentation]
    ...    This keyword is used for testcases, which need gnb and ap correctly startup as pre-condition
    ...    or this keyword can be used as testline recovery once testcase failed
    ...
    ...    | timeout    | timeout to wait for a single iteration of the startup sequence |
    ...    | kw_timeout | timeout for the whole KW, so over all iteration, so max. waiting time |
    ...
    ...    *Example:*
    ...    | Run Keyword If | '${PREV_TEST_STATUS}'=='FAIL' | Bring Airphone TL to F1 up status |
    ...
    [Arguments]    ${timeout}=4min     ${kw_timeout}=60min
    [Timeout]      ${kw_timeout}
    Ue-Wts-Commands-Keywords.Kill WTS Services
    Wait Until Keyword Succeeds    3x    30 sec    Run Keyword
    ...         Reset Airphone Testline    ${timeout}
    Modify SCTP Settings on Test-VM and AP


Modify SCTP Settings on Test-VM and AP
    [Documentation]
    ...    Run this KW on AP/WTS VM every time reboot the machine, This should handle the timeout issue
    ...    This is for airphone testline with irfhead, to overcome testline instability.
    ...
    ...    29.04.2024: after discussion with AP team we disable the AP sctp changes here!
    ...    But you can enforce the previous behaviour by setting ${ENABLE_AP_SCTP_CHANGE} to ${True}!
    ...
    ...    The UTE agent airphone hook changes during TL installation the VM sctp values
    ...    by executing /opt/wts/latest/sctp_wts_commands.sh! So our KW values must be aligned with that values!
    ...
    ...    *Scope*   Internal
    ...
    ${cmds}    Catenate    SEPARATOR=;
    ...    sudo sysctl -w net.sctp.rto_min=400
    ...    sudo sysctl -w net.sctp.rto_initial=400
    ...    sudo sysctl -w net.sctp.rto_max=800
    ...    sudo sysctl -w net.sctp.sack_timeout=20
    OperatingSystem.Run    ${cmds}

    Return From Keyword If   not ${ENABLE_AP_SCTP_CHANGE}

    ${cmds}    Catenate    SEPARATOR=;
    ...    sysctl -w net.sctp.rto_min=400
    ...    sysctl -w net.sctp.rto_initial=400
    ...    sysctl -w net.sctp.rto_max=800
    ...    sysctl -w net.sctp.sack_timeout=20
    ${ap_alias}    connect.Connect to Airphone Common Unit
    ssh.execute    command=${cmds}    connection=${ap_alias}    timeout=30s


Configure WTS for UTE Cloud Airphone TL
    [Documentation]
    ...    Used for UTE Cloud Airphone TL, by default, gNbCuType both will be handled as SA TL
    ...
    ...    *Scope* Internal
    ...
    ...    | remove_logs   | flag if existing wts logs shall be removed  |
    ...    | cfg_file      | path of wts config file to be used |
    ...    | force_cu_type | define SA / NSA TL if gNbCuType is configured as SA+NSA |
    ...
    [Arguments]   ${remove_logs}=${False}   ${cfg_file}=${tl.core.cfg_filename}   ${force_cu_type}=SA+NSA
    ${scf_cu_type}              Get gNbCuType Info
    ${scf_dss_type}             Get Dss Info
    ${scf_dss_type_all_cells}   Get Dss Info All cells
    ${scf_CellDepType_Cell1}    Get CellDepType_Cell1 Info
    ${scf_CellDepType}          Get CellDepType Info
    ${NbrCells}=    Evaluate    len(@{scf_dss_type_all_cells})
    IF    ${NbrCells}>${2}
        ${cell1_is_Dss}=    set variable    ${False}
        ${cell3_is_Dss}=    Evaluate    '${scf_dss_type_all_cells[2]}'=='DSS_Phase_3'
    ELSE
        ${cell3_is_Dss}=    set variable    ${False}
        ${cell1_is_Dss}=    Evaluate    '${scf_dss_type_all_cells[0]}'=='DSS_Phase_3'
    END
    ${scf_dss_type}   set variable if   '${scf_dss_type}'=='DSS_Phase_3' and ${cell2_is_Dss}    DSS_Phase_3_2Cells    DSS_Phase_3
    ${gNbCuType}      Set Variable If   '${scf_cu_type}'=='SA+NSA' or '${scf_cu_type}'=='both'   ${force_cu_type}   ${scf_cu_type}
    set suite variable     ${gNbCuType}
    ute-wtssim-ue-Keywords.Start WTS for Airphone   remove_logs=${remove_logs}
    Run keyword and ignore error    ute-wtssim-ue-Keywords.Start RRC Log
    Run Keyword If   '${gNbCuType}'=='NSA' and '${scf_dss_type.lower()}'=='none'   Configure WTS with X2 link   cfg_file=${cfg_file}
    ...   ELSE IF    '${scf_CellDepType_Cell1}'=='NSA' and '${scf_dss_type}'=='DSS_Phase_3'   Run Keywords
    ...              ute-wtssim-ue-Keywords.Config WTS for Airphone
    ...                                      pass_regexp=eNB 1 cell 1: SystemInformationBlockType2 updated
    ...                                        timeout=120   cfg_file=${cfg_file}
    ...        AND   GenericSuiteTest.Init Test Sequence    ${TestDSSContext}
    ...        AND   ute-wtssim-ue-Keywords.Wait Xp link Up    alias=ap_egate
    ...        AND   ute-wtssim-ue-Keywords.Setup X2 Link
    ...        AND   update Dss Specific parameters    ${TestDSSContext}
    ...        AND   common_Dss_CellSetup.DSS_CRM_Cell_Setup_Phase3    alias=ap_egate    wtsObj=${wtsObj}
    ...        AND   Configure_DSS_5g_Periodic_UL_Fast_Allocation    ${TestDSSContext}    alias=ap_egate    wtsObj=${wtsObj}
    ...        AND   Configure_DSS_5g_Periodic_DL_Fast_Allocation    ${TestDSSContext}    alias=ap_egate    wtsObj=${wtsObj}
    ...        AND   Test-Suite-Setup-Resources-Keywords.Log CRM config in result CRM file    ${ts_log_dir}/cell_setup_trace_initial
    ...        AND   common_Dss_CellSetup.get CRM and ENB Status to File  ${TestDSSContext}  ${resultFileCRM}  alias=ap_egate  wtsObj=${wtsObj}
    ...   ELSE IF    '${gNbCuType}'=='SA'    ute-wtssim-ue-Keywords.Config WTS for Airphone
    ...                                                                pass_regexp=NB 2 cell 1.*SystemInformationBlockType1-NR updated
    ...                                                                cfg_file=${cfg_file}    timeout=120
    ...   ELSE IF    '${gNbCuType}'=='SA+NSA' and '${scf_dss_type.lower()}'=='none'   Run Keywords
    ...              ute-wtssim-ue-Keywords.Config WTS for Airphone   pass_regexp=NB 2 cell 1.*SystemInformationBlockType1-NR updated
    ...                                                               timeout=60   cfg_file=${cfg_file}
    ...        AND   Setup X2 Link
    ...   ELSE IF    '${gNbCuType}'=='SA+NSA' and '${scf_CellDepType_Cell1}'=='SA+NSA' and '${scf_dss_type}'=='DSS_Phase_3'   Run Keywords
    ...              ute-wtssim-ue-Keywords.Config WTS for Airphone   pass_regexp=NG link is Up
    # ...                                      pass_regexp=eNB 1 cell 1:*SystemInformationBlockType2 updated
    ...                                        timeout=120   cfg_file=${cfg_file}
    ...        AND   GenericSuiteTest.Init Test Sequence    ${TestDSSContext}
    ...        AND   ute-wtssim-ue-Keywords.Wait Xp link Up    alias=ap_egate
    ...        AND   ute-wtssim-ue-Keywords.Setup X2 Link
    ...        AND   update Dss Specific parameters    ${TestDSSContext}
    ...        AND   common_Dss_CellSetup.DSS_CRM_Cell_Setup_Phase3    alias=ap_egate    wtsObj=${wtsObj}
    ...        AND   Configure_DSS_5g_Periodic_UL_Fast_Allocation    ${TestDSSContext}    alias=ap_egate    wtsObj=${wtsObj}
    ...        AND   Configure_DSS_5g_Periodic_DL_Fast_Allocation    ${TestDSSContext}    alias=ap_egate    wtsObj=${wtsObj}
    ...        AND   Test-Suite-Setup-Resources-Keywords.Log CRM config in result CRM file    ${ts_log_dir}/cell_setup_trace_initial
    ...        AND   common_Dss_CellSetup.get CRM and ENB Status to File  ${TestDSSContext}  ${resultFileCRM}  alias=ap_egate  wtsObj=${wtsObj}
    ...   ELSE IF    '${gNbCuType}'=='SA+NSA' and ${cell3_is_Dss}   Run Keywords
    ...              ute-wtssim-ue-Keywords.Config WTS for Airphone   pass_regexp=NG link is Up
    # ...                                      pass_regexp=eNB 1 cell 1:*SystemInformationBlockType2 updated
    ...                                        timeout=120   cfg_file=${cfg_file}
    ...        AND   GenericSuiteTest.Init Test Sequence    ${TestDSSContext}
    ...        AND   ute-wtssim-ue-Keywords.Wait Xp link Up    alias=ap_egate
    ...        AND   ute-wtssim-ue-Keywords.Setup X2 Link
    ...        AND   update Dss Specific parameters    ${TestDSSContext}
    ...        AND   common_Dss_CellSetup.DSS_CRM_Cell_Setup_Phase3    alias=ap_egate    wtsObj=${wtsObj}
    ...        AND   Configure_DSS_5g_Periodic_UL_Fast_Allocation    ${TestDSSContext}    alias=ap_egate    wtsObj=${wtsObj}
    ...        AND   Configure_DSS_5g_Periodic_DL_Fast_Allocation    ${TestDSSContext}    alias=ap_egate    wtsObj=${wtsObj}
    ...        AND   Test-Suite-Setup-Resources-Keywords.Log CRM config in result CRM file    ${ts_log_dir}/cell_setup_trace_initial
    ...        AND   common_Dss_CellSetup.get CRM and ENB Status to File  ${TestDSSContext}  ${resultFileCRM}  alias=ap_egate  wtsObj=${wtsObj}
    ...   ELSE IF    '${gNbCuType}'=='SA+NSA' and '${scf_dss_type}'=='DSS_Phase_3_2Cells'   Run Keywords
    ...              ute-wtssim-ue-Keywords.Config WTS for Airphone   pass_regexp=NG link is Up
    # ...                                      pass_regexp=eNB 1 cell 1:*SystemInformationBlockType2 updated
    ...                                        timeout=120   cfg_file=${cfg_file}
    ...        AND   robot_extension.Run Keyword And Warn On Failure   DSS_keywords.Check UL and DL l1Subpool Assignment in Syslogs
    ...        AND   GenericSuiteTest.Init Test Sequence    ${TestDSSContext}
    ...        AND   ute-wtssim-ue-Keywords.Wait Xp link Up    alias=ap_egate
    ...        AND   DSS_keywords.Update Blanked PRBs for CellId    ${TestDSSContext}    CellId=1
    ...        AND   GenericSuiteTest.Init Test Sequence    ${TestDSSContext}
    ...        AND   update Dss Specific parameters    ${TestDSSContext}
    ...        AND   common_Dss_CellSetup.DSS CRM enb dss configure partnership    alias=ap_egate    wtsObj=${wtsObj}
    ...        AND   DSS_keywords.Update Blanked PRBs for CellId    ${TestDSSContext_Cell2}     CellId=2
    ...        AND   GenericSuiteTest.Init Test Sequence    ${TestDSSContext_Cell2}
    ...        AND   update Dss Specific parameters    ${TestDSSContext_Cell2}
    ...        AND   common_Dss_CellSetup.DSS CRM enb dss configure partnership    alias=ap_egate    wtsObj=${wtsObj}
    ...        AND   DSS_keywords.Update Blanked PRBs for CellId      ${TestDSSContext}     CellId=1
    ...        AND   GenericSuiteTest.Init Test Sequence    ${TestDSSContext}
    ...        AND   common_Dss_CellSetup.DSS_CRM_Cell_Setup_Phase3_completation    alias=ap_egate    wtsObj=${wtsObj}
    ...        AND   DSS_keywords.Update Blanked PRBs for CellId        ${TestDSSContext_Cell2}    CellId=2
    ...        AND   GenericSuiteTest.Init Test Sequence    ${TestDSSContext_Cell2}
    ...        AND   common_Dss_CellSetup.DSS_CRM_Cell_Setup_Phase3_completation    alias=ap_egate    wtsObj=${wtsObj}
    ...        AND   ute-wtssim-ue-Keywords.Setup X2 Link
    ...        AND   Test-Suite-Setup-Resources-Keywords.Log CRM config in result CRM file    ${ts_log_dir}/cell_setup_trace_initial
    ...        AND   common_Dss_CellSetup.get CRM and ENB Status to File  ${TestDSSContext}  ${resultFileCRM}  alias=ap_egate  wtsObj=${wtsObj}
    ...        AND   common_Dss_CellSetup.get CRM and ENB Status to File  ${TestDSSContext_Cell2}  ${resultFileCRM}  alias=ap_egate  wtsObj=${wtsObj}
    ...        AND   robot_extension.Run Keyword And Warn On Failure     DSS_keywords.update bbpoolInfo Dll1Subpool and Ull1Subpool Assignment
    ...   ELSE IF    '${gNbCuType}'=='NR-DC-SN+SA'   ute-wtssim-ue-Keywords.Config WTS for Airphone
    ...                                                          pass_regexp=NB 2 cell 1.*SystemInformationBlockType1-NR updated
    ...                                                          cfg_file=${cfg_file}    timeout=120
    ...   ELSE       Fail   not supported TL type

    BuiltIn.Sleep   5s   reason=waiting for Airphone stabilized

Start X2 and L2 L3 Syscom Trace and Syslogs
    Run keyword and ignore error  Start X2 Trace Collection
    Run keyword and ignore error  Prepare and Start Syslogs
    Run Keyword and ignore error  Start collection of Syscom L2 L3 trace

Start BH Trace
    Run keyword and ignore error  Start BH Trace Collection

Stop BH Trace
    [Arguments]  ${collector_name}
    ${s1x2_logs_collector_name}=  set variable  backhaul_${collector_name}
    Run keyword and ignore error  Stop BH Trace Collection    s1x2_logs_collector_name=${s1x2_logs_collector_name}


Convert Dictionary to Parameter String
    [Documentation]
    ...
    ...    | kwargs | dictionary of pairs "parameter:value" |
    ...
    ...     *Scope*  Internal
    ...
    [Arguments]   &{kwargs}
    ${command_args}   Set Variable   ${EMPTY}
    FOR   ${key}   IN   @{kwargs}
       ${value}   Collections.Get From Dictionary   ${kwargs}   ${key}
        ${command_args}   Set Variable   ${command_args} ${key}=${value}
    END
    [Return]   ${command_args}

Start Traffic From Traffic List
    [Arguments]  ${scenario_name}
    ${traffic_commands}=  template.get_traffic_commands  scenario_name=${scenario_name}
    FOR  ${command}  IN  @{traffic_commands}
        run keyword and ignore error    Start data traffic in egate  &{command}
    END

Stop Traffic From Traffic List
    [Arguments]  ${scenario_name}  ${start_time}  ${traffic_duration}
    ${traffic_commands}=  template.get_traffic_commands  scenario_name=${scenario_name}
    ${current_time}=  nps_feature_tools.get_current_time
    ${elapsed_time}=  nps_feature_tools.get_elapsed_time  start_time=${start_time}  end_time=${current_time}
    ${traffic_remaining_time}=  Evaluate  ${traffic_duration} - ${elapsed_time}
    Run Keyword if  ${traffic_remaining_time} > ${0}  BuiltIn.Sleep  ${traffic_remaining_time}
    FOR  ${command}  IN  @{traffic_commands}
        Run Keyword  Stop data traffic in egate    ue_id=${command["ue_id"]}    direction=bi
    END

Collect PM Counters and process throughput using PM counters
    [arguments]    ${duration}=10 minutes
    ${pm_counters_dir}=  pmcounters.Collect PM Counter  target_dir=${ts_log_dir}/PMC    duration=${duration}
    ${latest_pm_file_name}=   nps_feature_tools.get_latest_pm_file   ${pm_counters_dir}
    Set suite variable    ${LATEST_FILE}    ${latest_pm_file_name}
    set suite variable  ${pm_counters_dir}
    Dated Log New Line     ***Latest pm counters file : ${LATEST_FILE}
    ${status}=    run keyword and return status    pmcounters.Convert PM files to CSV    file_path=${pm_counters_dir}
    run keyword if    not ${status}    BuiltIn.log    Convert PM files to CSV FAILED!    level=ERROR
    Initialize PM Counter Throughput Validator
    run keyword and ignore error    Calculate Throughput using PM Counters for all Scenarios
    run keyword and ignore error    Calculate BLER using PM Counters for all Scenarios
    run keyword and ignore error    Zip all PMC Report files


Zip all PMC Report files
    nps_feature_tools.ZIP Files  folder_path=${ts_log_dir}/PMC/gnb_pm_counters  zip_file_name=gnb_pm_counters.zip   match_string=*xml


Initialize PM Counter Throughput Validator
    [Arguments]  ${pm_counters_dir}=${ts_log_dir}/PMC/gnb_pm_counters
    ${pmc_obj_present}=  Run Keyword and Ignore Error  Evaluate  '${pmc_throughput_obj}'!='${EMPTY}'
    Return From Keyword If  '${pmc_obj_present[0]}'!='FAIL'
    ${pmc_throughput_obj}=  pmcounter_throughput.initialize_pmc_throughput_calculator  ${pm_counters_dir}
    Set Suite Variable  ${pmc_throughput_obj}
    ${pmc_bler_obj}=  pmcounter_bler.initialize_pmc_bler_calculator  ${pm_counters_dir}
    Set Suite Variable  ${pmc_bler_obj}

Calculate Throughput using PM Counters for all Scenarios
    ${list_of_scenarios}=  template.get_list_of_all_scenarios  ${TEST TAGS}
    ${througput_per_scenario}=  Create Dictionary
    FOR  ${scenario}  IN  @{list_of_scenarios}
        ${is_with_pm_counters}=  template.is_with_pm_counters   ${scenario}
        ${pm_counter_start_before_L3}=  template.pm_counter_start_before_L3  ${scenario}
        ${is_with_pm_counters}  Set Variable If    ${is_with_pm_counters} or ${pm_counter_start_before_L3}  ${True}  ${False}
        Return From Keyword If  not ${is_with_pm_counters}
        Log to console  Computing throughput using PM Counter for scenario: ${scenario}
        ${througput_per_cell}=  Calculate Throughput using PM Counters for scenario  validate_with_scenario=${scenario}
        Set to dictionary  ${througput_per_scenario}  ${scenario}=${througput_per_cell}
    END
    nps_feature_tools.write_dictionary_to_json  dir_path=${ts_log_dir}/PMC/gnb_pm_counters
    ...  dictionary=${througput_per_scenario}    filename=pmc_average_tp_per_scenario_per_cell.json


Calculate Throughput using PM Counters for scenario
    [Arguments]  ${validate_with_scenario}
    ${pmc_index}=  nps_feature_tools.get_pmc_index    scenario=${validate_with_scenario}
    ...  pm_offset_path=${pm_counters_dir}/pm_counter_offsets.json
    ${max_traffic_duration_for_scenario}=  template.get_max_traffic_length  scenario_name=${validate_with_scenario}
    ${througput_per_cell}=  Create Dictionary
    FOR  ${cell_dist_name}  IN  @{cell_distName_params}
        ${average_cell_throughput}=  TARF-Keywords.Calculate Average throughput per cell using PMC
        ...  validate_with_scenario=${validate_with_scenario}
        ...  cell_dist_name=${cell_dist_name}
        ...  max_traffic_duration_for_scenario=${max_traffic_duration_for_scenario}
        ...  pmc_index=${pmc_index}
        Set to dictionary  ${througput_per_cell}  ${cell_dist_name}=${average_cell_throughput}
    END
    [Return]  ${througput_per_cell}


Calculate BLER using PM Counters for all Scenarios
    ${list_of_scenarios}=  template.get_list_of_all_scenarios  ${TEST TAGS}
    ${bler_per_scenario}=  Create Dictionary
    FOR  ${scenario}  IN  @{list_of_scenarios}
        ${is_with_pm_counters}=  template.is_with_pm_counters   ${scenario}
        ${pm_counter_start_before_L3}=  template.pm_counter_start_before_L3  ${scenario}
        ${is_with_pm_counters}  Set Variable If    ${is_with_pm_counters} or ${pm_counter_start_before_L3}  ${True}  ${False}
        Return From Keyword If  not ${is_with_pm_counters}
        Log to console  Computing BLER using PM Counter for scenario: ${scenario}
        ${bler_per_cell}=  Calculate BLER using PM Counters for scenario  validate_with_scenario=${scenario}
        Set to dictionary  ${bler_per_scenario}  ${scenario}=${bler_per_cell}
    END
    nps_feature_tools.write_dictionary_to_json  dir_path=${ts_log_dir}/PMC/gnb_pm_counters
    ...  dictionary=${bler_per_scenario}    filename=pmc_bler_per_scenario_per_cell.json


Calculate BLER using PM Counters for scenario
    [Arguments]  ${validate_with_scenario}
    ${pmc_index}=  nps_feature_tools.get_pmc_index    scenario=${validate_with_scenario}
    ...  pm_offset_path=${pm_counters_dir}/pm_counter_offsets.json
    ${bler_per_cell}=  Create Dictionary
    FOR  ${cell_dist_name}  IN  @{cell_distName_params}
        ${bler_cell}=  TARF-Keywords.Calculate BLER per cell using PMC
        ...  validate_with_scenario=${validate_with_scenario}
        ...  cell_dist_name=${cell_dist_name}
        ...  pmc_index=${pmc_index}
        Set to dictionary  ${bler_per_cell}  ${cell_dist_name}=${bler_cell}
    END
    [Return]  ${bler_per_cell}


5G L3 Call with traffic
    [Arguments]  ${collector_name}=${EMPTY}
    ...          ${traffic_duration}=30s
    ...          ${pm_index}=${EMPTY}
    ...          ${pm_offset}=${EMPTY}
    BuiltIn.Log  Starting 5G L3 call for ${scenario_name} with pm_index=${pm_index} and pm_offset=${pm_offset}  console=yes
    Start X2 and L2 L3 Syscom Trace and Syslogs
    Start/Stop TTI/BIP/DCAP Traces  call_location=before_attach  collector_name=${collector_name}
    GenericSuiteTest.Step     Run Feature specific keywords before attach
    ${status}=  run keyword and return status   GenericSuiteTest.Step    Attach UEs to specific Cells
    Start/Stop TTI/BIP/DCAP Traces  call_location=after_attach  collector_name=${collector_name}
    run keyword if  '${status}'=='False'  Stop X2 Syscom Traces and Stop Btslog collection  collector_name=${collector_name}
    ...   collector_name=${collector_name}
    run keyword if  '${status}'=='False'  Start/Stop TTI/BIP/DCAP Traces  call_location=failed_attach  collector_name=${collector_name}
    run keyword if	'${status}'=='False'	return from keyword
    GenericSuiteTest.Step    Change CSI Report if Configured
    GenericSuiteTest.Step    Run Feature specific keywords after attach before traffic is started
    Start/Stop TTI/BIP/DCAP Traces  call_location=before_traffic  collector_name=${collector_name}
    GenericSuiteTest.Step    Start Traffic From Traffic List  ${scenario_name}
    ${start_time}=  nps_feature_tools.get_current_time
    Start/Stop TTI/BIP/DCAP Traces  call_location=during_traffic  collector_name=${collector_name}
    ${stop_time}=  nps_feature_tools.get_current_time
    ${time_required_to_start_traces}=  nps_feature_tools.get_elapsed_time  start_time=${start_time}  end_time=${stop_time}
    ${traffic_duration}=  template.get_max_traffic_length  ${scenario_name}
    ${wait_time_for_traffic}=  evaluate  ${traffic_duration} - ${time_required_to_start_traces}
    GenericSuiteTest.Step    Run Feature specific keywords during traffic before detach  traffic_duration=${wait_time_for_traffic}
    GenericSuiteTest.Step    Stop Traffic From Traffic List  ${scenario_name}  ${start_time}  ${traffic_duration}
    Start/Stop TTI/BIP/DCAP Traces  call_location=after_traffic  collector_name=${collector_name}
    GenericSuiteTest.Step    Run Feature specific keywords after traffic before detach
    run keyword and continue on failure   GenericSuiteTest.Step   Detach all airphone UEs
    Deactivate used csi_report_profiles
    GenericSuiteTest.Step    Run Feature specific keywords after detach
    GenericSuiteTest.Step    Stop and collect running traces  collector_name=${collector_name}  scenario_name=${scenario_name}

Start/Stop TTI/BIP/DCAP Traces
    [Arguments]  ${call_location}  ${collector_name}
    ${tti_start_point}=  template.get_ttitrace_start_point
    ${tti_stop_point}  ${stop_delay_tti}  template.get_ttitrace_stop_point_and_delay
    ${bip_start_point}=  template.get_biptrace_start_point
    ${bip_stop_point}  ${stop_delay_bip}  template.get_biptrace_stop_point_and_delay
    ${backaul_start_point}=  template.get_backhaul_start_point
    ${backaul_stop_point}=   template.get_backhaul_stop_point
    ${dcap_start_point}  template.get_dcap_start_point
    ${dcap_stop_point}  template.get_dcap_stop_point
    ${bip_trace_collector_name}=  Set Variable  l1_l2_${collector_name}
    ${bip_trace_stop_points}=  Create List  failed_attach  ${bip_stop_point}
    ${tti_trace_stop_points}=  Create List  failed_attach  ${tti_stop_point}
    ${dcap_stop_points}=  Create List  failed_attach  ${dcap_stop_point}
    ${backaul_stop_point}=  Create List  failed_attach  ${backaul_stop_point}
    ${bh_trace_collector_name}=  Set Variable  backhaul_${collector_name}
    Run Keyword if  "${call_location}"=="${tti_start_point}"
    ...  Run keyword and Continue on Failure  Start Collection of TTI Traces
    Run Keyword if  "${call_location}"=="${backaul_start_point}"
    ...      Scenario-Common-Keywords.Start Backhaul Traces  bh_trace_collector_name=${bh_trace_collector_name}
    Run Keyword if  "${call_location}"=="${bip_start_point}"
    ...      Scenario-Common-Keywords.Start L1_L2 Traces  bip_trace_collector_name=${bip_trace_collector_name}
    Run Keyword if  "${call_location}"=="${dcap_start_point}" and "${logs_and_traces_flags['DCAP']['collection']}"=="True"
    ...      Start DCAP Tracing  custom_profile=${logs_and_traces_flags['DCAP']['custom_profile']}
    ${STOP_BIP_TRACES}=  Run Keyword and return status
    ...  List Should Contain Value  ${bip_trace_stop_points}  ${call_location}
    ${STOP_TTI_TRACES}=  Run Keyword and return status
    ...  List Should Contain Value  ${tti_trace_stop_points}  ${call_location}
    ${STOP_DCAP_TRACES}=  Run Keyword and return status
    ...  List Should Contain Value  ${dcap_stop_points}  ${call_location}
    ${STOP_BH_TRACES}=  Run Keyword and return status
    ...  List Should Contain Value  ${backaul_stop_point}  ${call_location}
    Scenario-Common-Keywords.Stop TTI and BIP Traces  ${STOP_BIP_TRACES}  ${STOP_TTI_TRACES}  ${bip_trace_collector_name}
    ...  ${stop_delay_tti}  ${stop_delay_bip}  ${STOP_DCAP_TRACES}
    Scenario-Common-Keywords.Stop BH Traces  ${STOP_BH_TRACES}  ${bh_trace_collector_name}

Stop and collect running traces
    [Arguments]  ${collector_name}  ${scenario_name}
    log to console  Traces are being collected for ${scenario_name}
    run keyword and continue on failure  Start/Stop TTI/BIP/DCAP Traces  call_location=after_detach
                ...  collector_name=${collector_name}
    Stop X2 Syscom Traces and Stop Btslog collection    ${collector_name}

Start collection of Syscom L2 L3 trace
    Return from keyword if    '${logs_and_traces_flags['Syscom_L2_L3_Trace']}'=='False'
    ${l2_l3_trace_collector_name}=  Set variable  syscom_l2_l3
    run Keyword  Start Trace on L2_PS CP_RT interface  collector=${l2_l3_trace_collector_name}
    Set Test variable  ${l2_l3_trace_collector_name}


Stop collection of Syscom L2 L3 trace
    [Arguments]  ${syscom_trace_collector_name}
    Return from keyword if    '${logs_and_traces_flags['Syscom_L2_L3_Trace']}'=='False'
    run Keyword  Stop Trace on L2_PS CP_RT interface  collector=${l2_l3_trace_collector_name}
    ...  target_dir=${ts_log_dir}/${syscom_trace_collector_name}
    run Keyword  TARF-Keywords.Convert PCAP to PDML  source=${ts_log_dir}/${syscom_trace_collector_name}/l2_l3_syscom_tcpdump.pcap
    ...                                                  filter="sctp && icom_5g"
    ...                                                  target=${ts_log_dir}/${syscom_trace_collector_name}/l2_l3_syscom_tcpdump.pdml

Start Trace on L2_PS CP_RT interface
    [Documentation]
    ...    This Keyword starts a tcpdump on L2-PS CP-RT interface
    ...
    ...    *Scope*   Internal
    ...
    ...    *Returns* collector name
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}   ${capu_id}=${0}
    ...           ${collector}=cell_setup_trace
    ${capu_type}    testline-Keywords.Get Capacity Unit Type    gnb_id=${gnb_id}    du_id=${du_id}
    ...    common_unit_id=${comu_id}    capu_id=${capu_id}

    Run Keyword If   $capu_type not in ['ABIO', 'ABIP', 'ABIN']     Run Keywords
    ...           BuiltIn.log    BEWARE that Capacity Unit Type ['ABIO', 'ABIP', 'ABIN'] only supported!! no dynamic discovery working here!
    ...                          level=WARN
    ...    AND    ${capu_type}=    set variable     ABIO
    ...    AND    return from keyword

    Run Keyword If   $capu_type in ['ABIO', 'ABIP', 'ABIN']
    ...    tcpdump.Start L2_L3 SYSCOM Trace   gnb_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
    ...    capu_id=${capu_id}   options=-i etha01.212   collector=${collector}
    ...     ELSE      BuiltIn.log    Capacity Unit Type [${capu_type}] not supported!!    level=ERROR
    [Return]   ${collector}


Stop Trace on L2_PS CP_RT interface
    [Documentation]
    ...    This Keyword stops the tcpdump on L2-PS CP-RT interface and stores it in the given directory
    ...
    ...    *Scope*   Internal
    ...
    ...    *Returns* Path to pcap file of tcpdump incl. filename
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}   ${capu_id}=${0}
    ...           ${collector}=cell_setup_trace   ${target_dir}=${EMPTY}
    ${target_dir}   Run Keyword If   '${target_dir}'=='${EMPTY}'
    ...                testcase-Keywords.Get test suite log directory
    ...             ELSE
    ...                Set Variable   ${target_dir}

    ${capu_type}    testline-Keywords.Get Capacity Unit Type    gnb_id=${gnb_id}    du_id=${du_id}
    ...    common_unit_id=${comu_id}    capu_id=${capu_id}

    Run Keyword If   $capu_type not in ['ABIO', 'ABIP', 'ABIN']     Run Keywords
    ...           BuiltIn.log    BEWARE that Capacity Unit Type ['ABIO', 'ABIP', 'ABIN'] only supported!! no dynamic discovery working here!
    ...                          level=WARN
    ...    AND    ${capu_type}=    set variable     ABIO
    ...    AND    return from keyword

    ${trace_path}   Run Keyword If   $capu_type in ['ABIO', 'ABIP', 'ABIN']
    ...    tcpdump.Stop L2_L3 SYSCOM Trace
    ...    collector=${collector}   target_dir=${target_dir}   tcpdump_filename=l2_l3_syscom_tcpdump
    ...     ELSE      BuiltIn.log    Capacity Unit Type [${capu_type}] not supported!!    level=ERROR
    [Return]   ${trace_path}


Attach UEs to specific Cells
    Run Scripts to attach UE to LTE and perform Sgnb Addition
    Run Scripts to attach UEs to 5G Cell
    Log To Console    all UE's are registered to 5G in SA Mode!

Run Scripts to attach UE to LTE and perform Sgnb Addition
    ${list_of_nsa_ue_to_be_attached}=    template.get_attach_list  scenario_name=${scenario_name}  ue_type=nsa
    ${num_elems}=  Get Length  ${list_of_nsa_ue_to_be_attached}
    return from keyword if    ${num_elems}==${0}
    log to console  Attaching UEs to LTE
    FOR  ${nsa_attach_params}  IN  ${list_of_nsa_ue_to_be_attached}
        Run NSA Attach Scripts  ${nsa_attach_params}
    END

Run NSA Attach Scripts
    [Arguments]  ${list_of_nsa_ue_to_be_attached}  ${ignore_auto_attach}=${False}
    ${ue_ids}=  Get Dictionary Keys  ${list_of_nsa_ue_to_be_attached}
    FOR  ${ue_id}  IN  @{ue_ids}
        ${ue_parameters}=  Get From Dictionary  ${list_of_nsa_ue_to_be_attached}  ${ue_id}
        Continue For Loop IF  "${ue_parameters['auto_attach']}"=="False" and "${ignore_auto_attach}"=="False"
        ${optional_args}=  Set Variable  ${ue_parameters["optional_dual_connectivity_args"]}
        ${egate_output}=  Run Keyword  ute-wtssim-ue-Keywords.Attach UE to LTE  ue_id=${ue_id}  &{optional_args}
        ${rnti}=    nps_feature_tools.fetch_rnti_from   ${egate_output}
        template.set_rnti_lte_for_ue  scenario_name=${scenario_name}  ue_id=${ue_id}  rnti_lte=${rnti}
    END
    Run Keyword  ute-wtssim-ue-Keywords.Update dual connectivity parameters  id=1  serving_cell_index_range_scg=5:31
    Log to Console  Performing Sgnb Addition
    FOR  ${ue_id}  IN  @{ue_ids}
        ${ue_parameters}=  Get From Dictionary  ${list_of_nsa_ue_to_be_attached}  ${ue_id}
        Continue For Loop IF  "${ue_parameters['auto_attach']}"=="False" and "${ignore_auto_attach}"=="False"
        ${bearer_id}=  Get from dictionary  ${ue_parameters}  bearer
        ${cell}=  Get from dictionary  ${ue_parameters}  cell
        Log to console  Triggering LTE-NR dual connectivity for UE ${ue_id} on cell ${cell} for bearer ${bearer_id}
        ${status}    ${egate_output}=  Run Keyword And Ignore Error
        ...  ute-wtssim-ue-Keywords.Trigger LTE dual connectivity and analyze Output  ue_id=${ue_id}
        ...                                                                           bearer_id=${bearer_id}  target_cells=${cell}
        ...                                                                           target_path=${ts_log_dir}/${scenario_name}_attach.json
        Run Keyword If    '${status}'=='FAIL'    BuiltIn.Log  UE ${ue_id} was not attached successfully  level=WARN  console=yes
        ${rnti}=   Run Keyword If    '${status}'=='PASS'   nps_feature_tools.fetch_rnti_nsa_from   ${egate_output}
        ...                              ELSE              set variable     ${0}
        template.set_rnti_for_ue  scenario_name=${scenario_name}  ue_id=${ue_id}  rnti=${rnti}
    END

Run SA Attach Scripts
    [Arguments]  ${list_of_sa_ue_to_be_attached}  ${ignore_auto_attach}=${False}
    ${ue_ids}=  Get Dictionary Keys  ${list_of_sa_ue_to_be_attached}
    FOR  ${ue_id}  IN  @{ue_ids}
        ${ue_parameters}=  Get From Dictionary  ${list_of_sa_ue_to_be_attached}  ${ue_id}
        Continue For Loop IF  "${ue_parameters['auto_attach']}"=="False" and "${ignore_auto_attach}"=="False"
        ${status}=    run keyword and return status
        ...    Try to Register SA UE and save its RNTI    ${ue_id}    ${ue_parameters}
        run keyword if    not ${status}    BuiltIn.log    Try to Register SA UE and save its RNTI on UE${ue_id} FAILED!    level=ERROR
        BuiltIn.sleep    1s
        ${status}=    run keyword and return status
        ...    Run Keyword
        ...        ute-wtssim-ue-Keywords.Set traffic type    ue_id=${ue_id}    pdu_id=${ue_parameters["pdu"]}    trf_type=internal
        run keyword if    not ${status}    BuiltIn.log    Set traffic type on UE${ue_id} FAILED!    level=ERROR
        ${status}=    run keyword and return status
        ...    Run Keyword
        ...        ute-wtssim-ue-Keywords.UE PDU Session Setup and analyze output    ue_id=${ue_id}    pdu=${ue_parameters["pdu"]}
        ...                                                   gw=${ue_id}  nwslice=1
        ...                                                   target_path=${ts_log_dir}/${scenario_name}_attach.json
        run keyword if    not ${status}    BuiltIn.log    UE PDU Session Setup on UE${ue_id} FAILED!    level=ERROR
        log to console  UE${ue_id} is registered to 5G in SA Mode!
        BuiltIn.sleep    1s
    END

Try to Register SA UE and save its RNTI
    [Arguments]  ${ue_id}  ${ue_parameters}
    ${egate_output}=    Run Keyword    ute-wtssim-ue-Keywords.UE Register    ue_id=${ue_id}    &{ue_parameters["optional_nr_attach_args"]}
    ${rnti}=   nps_feature_tools.fetch_rnti_from    ${egate_output}
    template.set_rnti_for_ue    scenario_name=${scenario_name}    ue_id=${ue_id}    rnti=${rnti}


Run Scripts to attach UEs to 5G Cell
    ${list_of_sa_ue_to_be_attached}=    template.get_attach_list  scenario_name=${scenario_name}  ue_type=sa
    ${num_elems}=  Get Length  ${list_of_sa_ue_to_be_attached}
    Return from keyword if  ${num_elems}==${0}
    Log to Console  Attaching UEs to 5G
    FOR  ${sa_attach_params}  IN  ${list_of_sa_ue_to_be_attached}
        Run SA Attach Scripts  ${sa_attach_params}
    END
    Modify PDU Sessions if defined in JSON

Start Backhaul Traces
    [Arguments]  ${bh_trace_collector_name}
    Return from keyword if    '${logs_and_traces_flags['BackhaulTrace']['BHTrace']}'=='False'
    Run keyword and ignore error  Start Collection of gNB BH Traces  bh_trace_collector_name=${bh_trace_collector_name}

Start L1_L2 Traces
    [Arguments]  ${bip_trace_collector_name}
    Return from keyword if    '${logs_and_traces_flags['BIPTrace']['L1L2BIPTrace']}'=='False'
    Run keyword and ignore error  Start Collection of Airphone L1 L2 Traces  bip_trace_collector_name=ue_${bip_trace_collector_name}
    Run keyword and ignore error  Start Collection of gNB L1 L2 Traces  bip_trace_collector_name=${bip_trace_collector_name}

Stop TTI and BIP Traces
    [Arguments]  ${STOP_BIP_TRACES}  ${STOP_TTI_TRACES}  ${bip_trace_collector_name}  ${stop_delay_tti}  ${stop_delay_bip}
    ...  ${STOP_DCAP_TRACES}
    Run Keyword if  ${STOP_TTI_TRACES}  BuiltIn.Sleep    ${stop_delay_tti}  reason=Wait for the delay set by the user in the JSON
    Run Keyword if  ${STOP_TTI_TRACES}  Stop Collection of TTI Traces
    Run Keyword if  ${STOP_BIP_TRACES}  BuiltIn.Sleep    ${stop_delay_bip}  reason=Wait for the delay set by the user in the JSON
    Run Keyword if  ${STOP_BIP_TRACES}  Scenario-Common-Keywords.Stop L1_L2 Traces  bip_trace_collector_name=${bip_trace_collector_name}
    Run Keyword if  ${STOP_DCAP_TRACES} and "${logs_and_traces_flags['DCAP']['collection']}"=="True"  Stop DCAP Tracing

Stop BH Traces
    [Arguments]  ${STOP_BH_TRACES}   ${bh_trace_collector_name}
    # Run Keyword if  ${STOP_BH_TRACES}  BuiltIn.Sleep    ${stop_delay_bip}  reason=Wait for the delay set by the user in the JSON
    Run Keyword if  ${STOP_BH_TRACES}  Scenario-Common-Keywords.Stop gNB BH Trace Collection  bh_trace_collector_name=${bh_trace_collector_name}

Stop L1_L2 Traces
    [Arguments]  ${bip_trace_collector_name}
    Return from keyword if    '${logs_and_traces_flags['BIPTrace']['L1L2BIPTrace']}'=='False'
    Run keyword and ignore error  Stop Collection of gNB L1 L2 Traces
    ...  bip_trace_collector_name=${bip_trace_collector_name}
    Run keyword and ignore error  Stop Collection of Airphone L1 L2 Traces
    ...  bip_trace_collector_name=ue_${bip_trace_collector_name}

Start Collection of Airphone L1 L2 Traces
    [Arguments]  ${bip_trace_collector_name}
    Return from keyword if    '${logs_and_traces_flags['BIPTrace']['AP_L1L2BIPTrace']}'=='False'
    Run keyword and ignore error    Run Keyword  bip_trace_ap.Start Airphone BIP Traces  collector=ue_${bip_trace_collector_name}


Stop Collection of Airphone L1 L2 Traces
    [Arguments]  ${bip_trace_collector_name}
    Return from keyword if    '${logs_and_traces_flags['BIPTrace']['AP_L1L2BIPTrace']}'=='False'
    Run keyword and ignore error  Run Keyword  bip_trace_ap.Stop Airphone BIP Traces
    ...  collector=ue_${bip_trace_collector_name}
    ...  target_dir=${ts_log_dir}


Start Collection of TTI Traces
    Return from keyword if    '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
    Run Keyword  resource_ttitrace.Start TTI Trace generation  tti_trace_collector_name=${tti_collector_dict['${scenario_name}']}


Stop Collection of TTI Traces
    Return from keyword if    '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
    Run Keyword  resource_ttitrace.Stop TTI Trace generation  tti_trace_collector_name=${tti_collector_dict['${scenario_name}']}


Start Collection of gNB L1 L2 Traces
    [Arguments]  ${bip_trace_collector_name}
    Return from keyword if    '${logs_and_traces_flags['BIPTrace']['L1L2BIPTrace']}' == 'False'
    Run keyword and ignore error    Run Keyword  bip_trace.Start BIP Traces           collector=${bip_trace_collector_name}


Stop Collection of gNB L1 L2 Traces
    [Arguments]  ${bip_trace_collector_name}
    Return from keyword if    '${logs_and_traces_flags['BIPTrace']['L1L2BIPTrace']}' == 'False'
    Run keyword and ignore error  Run Keyword  bip_trace.Stop BIP Traces
    ...  collector=${bip_trace_collector_name}
    ...  target_dir=${ts_log_dir}


Start Collection of gNB BH Traces
    [Arguments]  ${bh_trace_collector_name}
    Return from keyword if    '${logs_and_traces_flags['BackhaulTrace']['BHTrace']}' == 'False'
    # by default, bh filter is sctp
    ${bh_filter}=    Set Variable if  '${logs_and_traces_flags['BackhaulTrace']['bh_filter']}'!='${EMPTY}'
    ...                                ${logs_and_traces_flags['BackhaulTrace']['bh_filter']}
    ...                                'sctp'
    ${backhaul_gnb_collector}=  Run Keyword And Continue On Failure  Run Keyword
    ...                            tcpdump.Start Tcpdump on TestPc with options
    # ...                                                          options=-i eth3 -U -s0 'sctp or udp'
    ...                                                          options=-i eth3 -U -s0 ${bh_filter}
    ...                                                          collector=${bh_trace_collector_name}
    set suite variable  ${backhaul_gnb_collector}

Stop gNB BH Trace Collection
    [Arguments]  ${bh_trace_collector_name}
    Return from keyword if    '${logs_and_traces_flags['BackhaulTrace']['BHTrace']}' == 'False'
    Run keyword and ignore error  Stop Backhaul gNB trace capture and convert trace to PDML
    ...  bh_trace_collector_name=${bh_trace_collector_name}
    ...  w_conversion=${logs_and_traces_flags['BackhaulTrace']['conversion']['pdml']}
    ...  filter=${logs_and_traces_flags['BackhaulTrace']['conversion']['filtered_pdml']}

Start X2 Trace Collection
    Return from keyword if    '${logs_and_traces_flags['X2Trace']}' == 'False'
    ${backhaul_collector}=  Run Keyword And Continue On Failure  Run Keyword
    ...                            tcpdump.Start Tcpdump on TestPc with options
    ...                                                          options=-i eth3 -U sctp
    ...                                                          collector=testpc_backhaul_tcpdump
    set test variable  ${backhaul_collector}


Stop X2 Trace Collection
    [Arguments]  ${s1x2_logs_collector_name}
    Return from keyword if    '${logs_and_traces_flags['X2Trace']}' == 'False'
    Run keyword and ignore error  Stop Backhaul trace capture and covert trace to PDML
    ...  s1x2_logs_collector_name=${s1x2_logs_collector_name}


Start BH Trace Collection
    Return from keyword if    '${logs_and_traces_flags['CellSetup_BH']}' == 'False'
    ${backhaul_collector}=  Run Keyword And Continue On Failure  Run Keyword
    ...                            tcpdump.Start Tcpdump on TestPc with options
    ...                                                          options=-i eth3 -U sctp or udp
    ...                                                          collector=testpc_backhaul_tcpdump
    set suite variable  ${backhaul_collector}


Stop BH Trace Collection
    [Arguments]  ${s1x2_logs_collector_name}
    Return from keyword if    '${logs_and_traces_flags['CellSetup_BH']}' == 'False'
    Run keyword and ignore error  Stop Backhaul trace capture and covert trace to PDML
    ...  s1x2_logs_collector_name=${s1x2_logs_collector_name}


Collect WTS Logs
    Return from keyword if    '${logs_and_traces_flags['WtsLogs']}'=='False'
    run Keyword  ute-wtssim-ue-Keywords.Collect egate log files  target_dir=${ts_log_dir}
    run Keyword  ute-wtssim-ue-Keywords.Collect edaemon log files  target_dir=${ts_log_dir}

Stop X2 Syscom Traces and Stop Btslog collection
    [Arguments]  ${collector_name}
    ${s1x2_logs_collector_name}=  set variable  s1x2_${collector_name}
    ${btslog_collector_name}=     set variable  btslog_${collector_name}
    Run keyword and ignore error  Stop X2 Trace Collection  s1x2_logs_collector_name=${s1x2_logs_collector_name}
    Run keyword and ignore error  Stop BTSLog Collection   bts_log_collector_name=${btslog_collector_name}
    Run keyword and ignore error  Stop collection of Syscom L2 L3 trace   syscom_trace_collector_name=syscom_l2_l3_${collector_name}


Stop Backhaul trace capture and covert trace to PDML
    [Arguments]  ${s1x2_logs_collector_name}
    ${path_to_tcpdump}=    run Keyword  tcpdump.Stop Tcpdump on TestPc with options
    ...  collector=${backhaul_collector}
    ...  target_dir=${ts_log_dir}/${s1x2_logs_collector_name}
    run Keyword  TARF-Keywords.Convert PCAP to PDML  source=${path_to_tcpdump}
    ...  filter="x2ap"
    ...  target=${ts_log_dir}/${s1x2_logs_collector_name}/backhaul.pdml

Stop Backhaul gNB trace capture and convert trace to PDML
    [Arguments]  ${bh_trace_collector_name}    ${w_conversion}=True   ${filter}="xp"
    ${path_to_tcpdump}=    run Keyword  tcpdump.Stop Tcpdump on TestPc with options
    ...  collector=${backhaul_gnb_collector}
    ...  target_dir=${ts_log_dir}/${bh_trace_collector_name}
    return from keyword if    '${w_conversion}'=='False'
    run Keyword  TARF-Keywords.Convert PCAP to PDML  source=${path_to_tcpdump}
    ...  filter=${filter}
    ...  target=${ts_log_dir}/${bh_trace_collector_name}/backhaul.pdml

Capture Snapshot and restore config
    [Documentation]
    ...     Conditions:     it needs no conditions / call only in test suite teardown !!!
    ...     Actions:        it Capture Snapshot and restore config
    ...     Checks:         it needs no checks
    ...     Verdict:        the setting is passed
    Run Keyword and Ignore error  Collect WTS Logs
    run keyword and ignore error  testline-Keywords.Restore WTS Config
    Run Keyword if  '${extra_options_flags['restore_scf']}'=='True'  Restore original gnb SCF
    # Capture SOS Report if not already collected
    Run Keyword If  '${logs_and_traces_flags["IMS_Snapshot"]}'=='True'  snapshot.Collect IM Snapshot from gNB  target_dir=${LOG_PATH}
    return from keyword if  '${logs_and_traces_flags['BTS_Snapshot']}'=='False'
    Run Keyword  snapshot.Collect snapshot from gNB  target_dir=${LOG_PATH}


Stop Logs and Collect Traces
    [Timeout]  30 minutes
    run keyword and Ignore error  Report Test Result to Reporting Portal
    run keyword and Ignore error  Capture SOS Report if not already collected


Capture SOS Report if not already collected
    ${collect_SOS_logs}=  Set Variable  ${logs_and_traces_flags['AP_SOSLogs']}
    run Keyword if    '${collect_SOS_logs}'=='True'  BuiltIn.log   AP_SOSLogs is not supported!!!    level=WARN   console=True
    return from keyword
    return from keyword if  '${SOS_report_collected}'=='True' or '${collect_SOS_logs}'=='False'
    run keyword and Ignore error  run Keyword  Collect SOS report logs  target_dir=${ts_log_dir}
    ${SOS_report_collected}=  Set Variable  True
    Set Suite Variable  ${SOS_report_collected}

Prepare and Start Syslogs
    Return from keyword if    '${logs_and_traces_flags['Syslogs']}'=='False'
    Run Keyword  btslog.Create cplane runtime file to gnb
    Run Keyword  btslog.Start Btslog

Prepare and Start AP Syslogs
    [Arguments]    ${target_dir}=None
    Return from keyword if    '${logs_and_traces_flags['CellSetup_AP_Syslogs']}'=='False'
    Run Keyword  apUDPlog.Start To Capture Iphy Udplog  target_dir=${target_dir}

Stop BTSLog Collection
    [Arguments]  ${bts_log_collector_name}
    Return from keyword if    '${logs_and_traces_flags['Syslogs']}'=='False'
    Create Directory  ${ts_log_dir}/${bts_log_collector_name}
    run Keyword  btslog.Stop Btslog  target_dir=${ts_log_dir}/${bts_log_collector_name}

Stop APLog Collection
    [Arguments]  ${bts_log_collector_name}
    Return from keyword if    '${logs_and_traces_flags['CellSetup_AP_Syslogs']}'=='False'
    Create Directory  ${ts_log_dir}/${bts_log_collector_name}
    run Keyword  apUDPlog.Stop Capture Iphy Udplog  target_dir=${ts_log_dir}/${bts_log_collector_name}

Check if PDU Session Modification is required
    [Arguments]  ${qos_flow_list}
    ${pdu_modification_required}=  Set Variable if  ${qos_flow_list}  ${TRUE}  ${FALSE}
    [Return]  ${pdu_modification_required}

Modify PDU Sessions if defined in JSON
    ${ue_id_qos_flow_config}=  template.get_list_of_ues_for_pdu_modification  scenario_name=${scenario_name}  ue_type=sa
    FOR  ${UE_ID}  IN  @{ue_id_qos_flow_config}
        ${qos_flow_list}=  Get from dictionary  ${ue_id_qos_flow_config[${UE_ID}]}  qos_flows
        ${pdu}=  Get from dictionary  ${ue_id_qos_flow_config[${UE_ID}]}  pdu
        ${pdu_modification_required}=  Check if PDU Session Modification is required     qos_flow_list=${qos_flow_list}
        Run Keyword if  ${pdu_modification_required}  Modify PDU Session  UE_ID=${UE_ID}  pdu=${pdu}  qos_flow_list=${qos_flow_list}
    END

Modify PDU Session
    [Arguments]  ${UE_ID}  ${pdu}  ${qos_flow_list}
    ${status}=  Run Keyword And Return Status
        ...          UE PDU Session Modify  ue_id=${UE_ID}  pdu=${pdu}  qos_flow_list=${qos_flow_list}
    run keyword if    not ${status}    BuiltIn.log    Modification of PDU Session (${pdu}) for UE ID: ${UE_ID} FAILED!    level=ERROR

Detach all Airphone UEs
    ${list_of_nsa_ue_to_be_attached}=    template.get_attach_list  scenario_name=${scenario_name}  ue_type=nsa
    ${list_of_sa_ue_to_be_attached}=    template.get_attach_list  scenario_name=${scenario_name}  ue_type=sa
    Log to Console  Detaching NSA UEs
    FOR  ${nsa_attach_params}  IN  ${list_of_nsa_ue_to_be_attached}
        Detach LTE UE  ${nsa_attach_params}
    END
    Log to Console  Detaching SA UEs
    FOR  ${sa_attach_params}  IN  ${list_of_sa_ue_to_be_attached}
        Detach 5G UE  ${sa_attach_params}
    END

Detach LTE UE
    [Arguments]  ${list_of_nsa_ue_to_be_attached}  ${ignore_auto_attach}=${False}
    ${ue_ids}=  Get Dictionary Keys  ${list_of_nsa_ue_to_be_attached}
    FOR  ${ue_id}  IN  @{ue_ids}
        ${ue_parameters}=  Get From Dictionary  ${list_of_nsa_ue_to_be_attached}  ${ue_id}
        Continue For Loop IF  "${ue_parameters['auto_attach']}"=="False" and "${ignore_auto_attach}"=="False"
        Run Keyword  ute-wtssim-ue-Keywords.Detach UE from LTE  ue_id=${ue_id}
        log to console  UE${ue_id} is detached from 5G in NSA Mode!
    END

Detach 5G UE
    [Arguments]  ${list_of_sa_ue_to_be_attached}  ${ignore_auto_attach}=${False}
    ${ue_ids}=  Get Dictionary Keys  ${list_of_sa_ue_to_be_attached}
    FOR  ${ue_id}  IN  @{ue_ids}
        ${ue_parameters}=  Get From Dictionary  ${list_of_sa_ue_to_be_attached}  ${ue_id}
        Continue For Loop IF  "${ue_parameters['auto_attach']}"=="False" and "${ignore_auto_attach}"=="False"
        ${status}=   run keyword and return status  ute-wtssim-ue-Keywords.UE Deregister  ${ue_id}
        run keyword if    not ${status}    BuiltIn.log    Try to Deregister SA UE on UE${ue_id} FAILED!    level=ERROR
        log to console  UE${ue_id} is deregistered from 5G in SA Mode!
    END

Change CSI Report if Configured
    ${commands}  ${auto_activate}=  template.get_csi_report_configured_for_scenario  ${scenario_name}
    Return from keyword if  '${auto_activate}'=='False'
    ${ue_groups}=  Get Dictionary Keys  ${commands}
    FOR  ${ue_group}  IN  @{ue_groups}
        Update UE Channel State Information    profile_id=${commands["${ue_group}"]["profile_id"]}
        ...  &{commands["${ue_group}"]["cqi_params"]}
        run keyword   ute-wtssim-ue-Keywords.Associate UEs to testmode    ue_id=${commands["${ue_group}"]["ue_ids"]}
        ...  testmode=csi_override  profile_id=${commands["${ue_group}"]["profile_id"]}
        ...  scell=${commands["${ue_group}"]["scell"]}  action=activate
    END

Deactivate used csi_report_profiles
    ${commands}  ${auto_activate}=  template.get_csi_report_configured_for_scenario  ${scenario_name}
    ${ue_groups}=  Get Dictionary Keys  ${commands}
    FOR  ${ue_group}  IN  @{ue_groups}
        run Keyword  ute-wtssim-ue-Keywords.Associate UEs to testmode    ue_id=${commands["${ue_group}"]["ue_ids"]}
        ...  testmode=csi_override  profile_id=${commands["${ue_group}"]["profile_id"]}
        ...  scell=${commands["${ue_group}"]["scell"]}  action=deactivate
        BuiltIn.Sleep    1s  Deactivating ${commands["${ue_group}"]["ue_ids"]}
    END


Generate Test Verdict From TtiTraces
    [Arguments]    ${FilePkl}
    dated log      ${consTraceColor}--------> [DL/UL] UL and DL DTX STATS${defColor}
    ${output_dtx_statistics}=   Run keyword and continue on failure     Tti-lib.get_dtx_statistics_physCellId_ul    ${FilePkl}
    dated log      ==output_dtx_statistics_physCellId_ul==
    Tti-lib.Display Df As Html      ${output_dtx_statistics}
    Tti-lib.display_df_as_table     ${output_dtx_statistics}
    ${output_dtx_statistics}=   Run keyword and continue on failure     Tti-lib.get_dtx_statistics_physCellId_dl    ${FilePkl}
    dated log      ==output_dtx_statistics_physCellId_dl==
    Tti-lib.Display Df As Html     ${output_dtx_statistics}
    Tti-lib.display_df_as_table     ${output_dtx_statistics}
    dated log      ${consTraceColor}--------> cells_and_ues_physCellId${defColor}
    ${output}   Run keyword and continue on failure    Tti-lib.get_cells_and_ues_physCellId   ${FilePkl}
    dated log    ==cells_and_ues_physCellId==
    Tti-lib.Display Df As Html     ${output}
    Tti-lib.display_df_as_table     ${output}
    dated log      ${consTraceColor}--------> [DL] get_rank_statistics_rnti_dl${defColor}
    ${combined_rank_stats}  ${rank_stats}   Run keyword and continue on failure    Tti-lib.get_rank_statistics_rnti_dl   ${FilePkl}
    dated log    ==get_rank_statistics_rnti_dl==
    Tti-lib.Display Df As Html     ${combined_rank_stats}
    Tti-lib.display_df_as_table     ${combined_rank_stats}
    dated log      ${consTraceColor}--------> [DL] filter_valid_events_and_check_acknack_retx${defColor}
    ${combined_acknack_stats_physCellId}  ${combined_acknack_stats_rnti}  ${combined_retx_stats_physCellId}  ${combined_retx_stats_rnti}
    ...                                 Run keyword and continue on failure    check_nack.filter_valid_events_and_check_acknack_retx   ${FilePkl}
    dated log    ==combined_acknack_stats_physCellId==
    Tti-lib.Display Df As Html     ${combined_acknack_stats_physCellId}
    Tti-lib.display_df_as_table     ${combined_acknack_stats_physCellId}
    dated log    ==combined_acknack_stats_rnti==
    Tti-lib.Display Df As Html     ${combined_acknack_stats_rnti}
    Tti-lib.display_df_as_table     ${combined_acknack_stats_rnti}
    dated log    ==combined_txnumber_stats_rnti==
    Tti-lib.Display Df As Html     ${combined_retx_stats_rnti}
    Tti-lib.display_df_as_table     ${combined_retx_stats_rnti}
    dated log    ==combined_txnumber_stats_physCellId==
    Tti-lib.Display Df As Html     ${combined_retx_stats_physCellId}
    Tti-lib.display_df_as_table     ${combined_retx_stats_physCellId}
    dated log      ${consTraceColor}--------> [UL] filter_valid_events_and_check_ul_crc_dtx_retx${defColor}
    ${combined_ul_crc_stats_physCellId}  ${combined_ul_crc_stats_rnti}  ${combined_ul_retx_stats_physCellId}  ${combined_ul_retx_stats_rnti}
    ...                                   ${combined_ul_dtx_stats_physCellId}  ${combined_ul_dtx_stats_rnti}
    ...                         Run keyword and continue on failure    check_ul_dtx_crc.filter_valid_events_and_check_ul_crc_dtx_retx   ${FilePkl}
    dated log    ==combined_ul_crc_stats_physCellId==
    Tti-lib.Display Df As Html     ${combined_ul_crc_stats_physCellId}
    Tti-lib.display_df_as_table     ${combined_ul_crc_stats_physCellId}
    dated log    ==combined_ul_crc_stats_rnti==
    Tti-lib.Display Df As Html     ${combined_ul_crc_stats_rnti}
    Tti-lib.display_df_as_table     ${combined_ul_crc_stats_rnti}
    dated log    ==combined_ul_txnumber_stats_physCellId==
    Tti-lib.Display Df As Html     ${combined_ul_retx_stats_physCellId}
    Tti-lib.display_df_as_table     ${combined_ul_retx_stats_physCellId}
    dated log    ==combined_ul_txnumber_stats_rnti==
    Tti-lib.Display Df As Html     ${combined_ul_retx_stats_rnti}
    Tti-lib.display_df_as_table     ${combined_ul_retx_stats_rnti}
    dated log    ==combined_ul_dtx_stats_physCellId==
    Tti-lib.Display Df As Html     ${combined_ul_dtx_stats_physCellId}
    Tti-lib.display_df_as_table     ${combined_ul_dtx_stats_physCellId}
    dated log    ==combined_ul_dtx_stats_rnti==
    Tti-lib.Display Df As Html     ${combined_ul_dtx_stats_rnti}
    Tti-lib.display_df_as_table     ${combined_ul_dtx_stats_rnti}
    dated log      ${consTraceColor}--------> [UL] get_rank_statistics_rnti_ul${defColor}
    ${combined_ul_rank_stats}  ${ul_rank_stats}   Run keyword and continue on failure    Tti-lib.get_rank_statistics_rnti_ul   ${FilePkl}
    dated log    ==get_rank_statistics_rnti_ul==
    Tti-lib.Display Df As Html     ${combined_ul_rank_stats}
    Tti-lib.display_df_as_table     ${combined_ul_rank_stats}

Report Test case status to reporting portal
    [Arguments]  ${pmcounters_to_be_reported}  ${swPostFix}
    run keyword  reporting.Online Reporting to ReP  tcName=${TEST_NAME}  tsResult=${TEST STATUS}
    ...                                             pmCounters=${pmcounters_to_be_reported}  swPostFix=${swPostFix}


Report Passed Test case status to reporting portal
    [Arguments]  ${pmcounters_to_be_reported}  ${swPostFix}
    IF    '${TEST STATUS}'=='PASS'
        run keyword  reporting.Online Reporting to ReP  tcName=${TEST_NAME}  tsResult=Passed
        ...                                             pmCounters=${pmcounters_to_be_reported}
        ...                                             swPostFix=${swPostFix}
    END

Report Test Result to Reporting Portal
    ${ALWAYS_REPORT_FLAG}=    run keyword and return status  list should contain value  ${TEST TAGS}  ALWAYS_REPORT
    ${NO_REPORT_FLAG}=    run keyword and return status  list should contain value  ${TEST TAGS}  MY_SKIP_REPORT
    ${PM_COUNTERS_TO_REPORT}=    run keyword and return status  Variable Should Exist  ${tc_pm_counters_validated}
    ${rep_pm_counters}=  Set Variable If  ${PM_COUNTERS_TO_REPORT}  ${tc_pm_counters_validated}  ${EMPTY}
    ${SW_POST_FIX_PRESENT}=    run keyword and return status  Variable Should Exist  ${SW_POSTFIX}
    ${swPostFix}=    Set Variable If  ${SW_POST_FIX_PRESENT}  ${SW_POSTFIX}  ${EMPTY}
    IF    ${ALWAYS_REPORT_FLAG}
        Scenario-Common-Keywords.Report Test case status to reporting portal  pmcounters_to_be_reported=${rep_pm_counters}  swPostFix=${swPostFix}
    ELSE IF   not ${NO_REPORT_FLAG}
        Scenario-Common-Keywords.Report Passed Test case status to reporting portal  pmcounters_to_be_reported=${rep_pm_counters}
        ...                                                                          swPostFix=${swPostFix}
    END


# --------------------------------------------------------------------------------------------------------------------------------------------------
# End Of Scenario Common Kw
# --------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
# RAD Parameters #
Set RAD Parameters for Feature
    [Documentation]
    ...     Conditions:     it needs no conditions
    ...     Actions:        it adds or modifies the RAD parameters to activate functions. It will be replaced later by NIDD
    ...     Checks:         it needs no checks
    ...     Verdict:        the setting is passed
    [Arguments]             ${rad_0x58057a_val}=3    #L2PS.INF#
    ...                     ${rad_0x58057c_val}=0x0    #L2PS.rdFeatureFlagBitmap1#

    Run Keyword If          ${isAic}    Dated Log New Line    ===> RAD parameters are not set for this topology
    ...         ELSE                    Dated Log New Line    ===> set RAD parameters
    #
    ${rad_0x58057a}=        Create Dictionary    field=0x58057a    value=${rad_0x58057a_val}    #L2PS trace activation ERR=1 WRN=2 INF=3 DBG=4#
    # L2PS.rdFeatureFlagBitmap1=0x12800 <=> 0001 0010 1000 0000 0000 (bit0 to 19 from right to left) => 11=PRB_POOLING_BASIC 13=PRB_POOLING_UL
    # L2PS.rdFeatureFlagBitmap1=0x10000 <=> 0001 0000 0000 0000 0000 (bit0 to 19 from right to left) => 16=BWP
    # L2PS.rdFeatureFlagBitmap1=0x80000 <=> 1000 0000 0000 0000 0000 (bit0 to 19 from right to left) => 19=DL.DCI
    ${rad_0x58057c}=        Create Dictionary    field=0x58057c    value=${rad_0x58057c_val}

    #
    ${list_rad_param}=                          Create List    ${rad_0x58057a}    ${rad_0x58057c}
    Run Keyword If          not ${isAic}    Run Keywords    Dated Log    ===> RAD params list is ${list_rad_param}
    ...    AND              SetConfig.Set Fields in swconfig DU    param_list=${list_rad_param}


Set RAD Parameters on Airphone
    [Documentation]
    ...     Conditions:     it needs no conditions
    ...     Actions:        it adds or modifies the RAD parameters to activate functions. It will be replaced later by NIDD
    ...     Checks:         it needs no checks
    ...     Verdict:        the setting is passed
    [Arguments]             ${rad_0x10040_val}=4

    Dated Log New Line                          ===> set RAD parameters on Airphone with rad_0x10040_val= ${rad_0x10040_val}
    Dated Log                                   ===> SYSLOG output severity prints (0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable)
    #
    ${rad_0x10040}=         Create Dictionary    field=0x10040    value=${rad_0x10040_val}

    #
    ${list_rad_param}=      Create List    ${rad_0x10040}
    Dated Log                                   ===> RAD params list is ${list_rad_param}
    SetConfig.Set Fields in swconfig DU         param_list=${list_rad_param}    host=${AP_DU.entryCard[0]}

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

# Capture #
Captures Init
    [Documentation]
    ...     Conditions:     it needs no conditions
    ...     Actions:        it configures the parameters to initialize the captures for L1L2, CORE and CPRT
    ...     Checks:         it needs no checks
    ...     Verdict:        the parameters for the captures are initialized

    ${capture_l1l2}=                            Capture L1L2 Set Upon Config    airscale=${GNB_DU}
    ${capture_l1l2.filter}=                     Get Filter To Exclude protocols    capture=${capture_l1l2}    protocolList=${protocol_exclusion}
    ${capture_core}=    Run Keyword If    ${isAic}
    ...                                         Capture CORE Set Upon Config    airscale=${GNB_CU}
    ...                             ELSE        Capture CORE Set Upon Config    airscale=${GNB_DU}
    ${capture_cprt}=                            Capture CPRT Set Upon Config    airscale=${GNB_DU}
    Capture Init                                ${capture_l1l2}    #withTN=True
    Capture Init                                ${capture_core}    #withTN=True
    Capture Init                                ${capture_cprt}    #withTN=True
    Set Suite Variable                          ${capture_l1l2}
    Set Suite Variable                          ${capture_core}
    Set Suite Variable                          ${capture_cprt}


Captures Start
    [Documentation]
    ...     Conditions:     it is based on the arguments ${action_core} ${action_cprt} ${action_l1l2}
    ...     Actions:        it starts the captures for L1L2 and/or CORE and/or CPRT depends on an argument
    ...     Checks:         it needs no checks
    ...     Verdict:        the captures are started
    [Arguments]             ${action_core}=${False}    # Capture CORE is not started by default
    ...                     ${action_cprt}=${False}    # Capture CPRT is not started by default
    ...                     ${action_l1l2}=${False}    # Capture L1L2 is not started by default

    Run Keyword If    ${action_core}            Capture Start    capture=${capture_core}
    Run Keyword If    ${action_cprt}            Capture Start    capture=${capture_cprt}
    Run Keyword If    ${action_l1l2}            Capture Start    capture=${capture_l1l2}


Captures Stop
    [Documentation]
    ...     Conditions:     it is based on the arguments ${action_core} ${action_cprt} ${action_l1l2}
    ...     Actions:        it stops the captures for L1L2 and/or CORE and/or CPRT depending on an argument
    ...     Checks:         it needs no checks
    ...     Verdict:        the captures are stopped
    [Arguments]             ${action_core}=${True}     # Capture CORE is stopped by default
    ...                     ${action_cprt}=${True}     # Capture CPRT is stopped by default
    ...                     ${action_l1l2}=${True}     # Capture L1L2 is stopped by default

    Run Keyword If    ${action_l1l2}    Run Keywords    Capture Stop    capture=${capture_l1l2}
    ...    AND                                  Dated Log           capture_l1l2= ${capture_l1l2}
    Run Keyword If    ${action_core}            Capture Stop    capture=${capture_core}
    Run Keyword If    ${action_cprt}            Capture Stop    capture=${capture_cprt}
# --------------------------------------------------------------------------------------------------------------------------------------------------
# L1L2 pcap and pdml data analysis functions #
CB012738 Create Filter Message List
    [Documentation]
    ...     Conditions:
    ...     Actions:
    ...     Checks:
    ...     Verdict:

    # dictionaries for message definition
    ${dict_filter_1}=                           Create Dictionary    message_filter=dldata_csirssendreq    filter_name=_dldata_csirssendreq
    ${dict_filter_2}=                           Create Dictionary    message_filter=dldata_pdcchsendreq    filter_name=_dldata_pdcchsendreq
    ${dict_filter_3}=                           Create Dictionary    message_filter=dldata_pdschsendreq    filter_name=_dldata_pdschsendreq
    ${dict_filter_4}=                           Create Dictionary    message_filter=uldata_prachreceivereq    filter_name=_uldata_prachreceivereq
    ${dict_filter_5}=                           Create Dictionary    message_filter=uldata_pucchreceivereq    filter_name=_uldata_pucchreceivereq
    ${dict_filter_6}=                           Create Dictionary    message_filter=uldata_puschreceivereq    filter_name=_uldata_puschreceivereq
    ${dict_filter_7}=                           Create Dictionary    message_filter=uldata_srsreceivereq    filter_name=_uldata_srsreceivereq
    ${dict_filter_8}=                           Create Dictionary    message_filter=uldata_pucchreceivereq or uldata_puschreceivereq
    ...                                                             filter_name=_uldata_puXchreceivereq
    ${dict_no_filter}=                          Create Dictionary    message_filter=${EMPTY}    filter_name=_no_filter
    # list of messages for filtering
    ${list_filters_messages}=                   Create List
    ...                                                             ${dict_filter_1}
    ...                                                             ${dict_filter_2}
    ...                                                             ${dict_filter_3}
    ...                                                             ${dict_filter_4}
    ...                                                             ${dict_filter_5}
    ...                                                             ${dict_filter_6}
    ...                                                             ${dict_filter_7}
    [Return]    ${list_filters_messages}


CB012738 Analyze pcap and pdml
    [Documentation]
    ...     Conditions:
    ...     Actions:
    ...     Checks:
    ...     Verdict:
    [Arguments]             ${pcap_file}        # input filename for analyzing
    ...                     ${list_message_filter}

    Dated Log New Line                          ===> Analyze pcap and pdml of ${pcap_file}
    FOR    ${current_elem}    IN    @{list_message_filter}
        # current_elem.message_filter
        Dated Log                               ===> filtering and pdml generation for ${current_elem.message_filter}
        ${pcap_file_filtered}=                  analyzer.filter_pcap    pcapInFile=${pcap_file}
        ...			                                                filterName=${current_elem.filter_name}
        ...			                                                filterExp=${current_elem.message_filter}
        Set To Dictionary                       ${current_elem}    pcap_file_filtered    ${pcap_file_filtered}
        ${pdml_file_result}                     analyzer.pcap_to_pdml    ${pcap_file_filtered}
        Set To Dictionary                       ${current_elem}    pdml_file_result    ${pdml_file_result}
    END
    Dated Log New Line                          ===> list of messages AFTER filtering: ${list_message_filter}


Create Packet Dictionary
    [Documentation]
    ...     Conditions:
    ...     Actions:
    ...     Checks:
    ...     Verdict:
    [Arguments]             ${packet_str}

    ${packet_str_splitted}=                     Split String    ${packet_str}    separator=${SPACE}
    ${packet_nb_elem}=                          Get Length    ${packet_str_splitted}
    ${packet_dict}=                             Create Dictionary
    FOR    ${iteration}    IN RANGE    0    ${packet_nb_elem}
        ${packet_param}=                        Get From List    ${packet_str_splitted}    ${iteration}
        ${packet_param_splitted}=               Split String    ${packet_param}    separator==
        Set To Dictionary    ${packet_dict}    ${packet_param_splitted[0]}    ${packet_param_splitted[1]}
    END
    [Return]    ${packet_dict}


Check dlData pdcchSendReq coresetFreqDomain
    [Documentation]
    ...     Conditions:
    ...     Actions:
    ...     Checks:
    ...     Verdict:
    [Arguments]             ${pdml_file}        # input filename for analyzing
    ...                     ${field_values}     # input keys and values to filter before checking
    ...                     ${subcellid}
    ...                     ${coresetFreqDomain}
    ...                     ${packet_end}=-1    # -1 is the default value for parsing all packets
    ...                     ${coresetFreqDomain_0xFFFF}=${coresetFreqDomain_9915_B1_2_0xFFFF}
    ...                     ${packet_name}=dldata_pdcchsendreq

    ${msg_field}=                               Set Variable    @{field_values.keys()}
    Dated Log New Line                          ===> check dlData pdcchSendReq if coresetFreqDomain=${coresetFreqDomain}
    Dated Log                                   ===> from ${pdml_file} for keys ${msg_field} and subcellid=${subcellid}
    @{listPacketMatch}                          Get Packet Match List    pdmlFile=${pdml_file}
        ...                                                         packetName=${packet_name}
        ...                                                         pathList=@{msg_field}
        ...                                                         startPacket=${1}
        ...                                                         endPacket=${${packet_end}}    #vbo#check done among the first packet_end packets
        ...                                                         filter='subcellid$'==${subcellid}
    ${nbOfPacketFound}=                         get length    ${listPacketMatch}
    Dated Log                                   ===> number of packet ${packet_name} with subcellid=${subcellid} is ${nbOfPacketFound}
    Should Be True                              ${nbOfPacketFound} != 0

    ${nb_match}                                 Set Variable    0
    ${nb_match2}                                Set Variable    0
    FOR    ${current_packet}    IN    @{listPacketMatch}
        ${packet_str}=                          Packet Match to Str    packetMatch=${current_packet}    fields=${msg_field}
        ${packet_dict}=                         Create Packet Dictionary    packet_str=${packet_str}
        ${sfn_found}=                           Get From Dictionary    ${packet_dict}    sfn
        ${slot_found}=                          Get From Dictionary    ${packet_dict}    slot
        ${rnti_found}=                          Get From Dictionary    ${packet_dict}    rnti
        ${coresetFreqDomain_found}=             Get From Dictionary    ${packet_dict}    coresetFreqDomain
        ${nb_match}=    Run Keyword If    ${rnti_found} != 65535 and ${coresetFreqDomain_found} == ${coresetFreqDomain}
        ...                                     Evaluate    ${nb_match} + 1
        ...                         ELSE        Evaluate    ${nb_match} + 0
        ${nb_match2}=    Run Keyword If    ${rnti_found} == 65535 and ${coresetFreqDomain_found} == ${coresetFreqDomain_0xFFFF}
        ...                                     Evaluate    ${nb_match2} + 1
        ...                         ELSE        Evaluate    ${nb_match2} + 0
    END
    Dated Log    ===> ${nb_match} packets are matched the coresetFreqDomain among the ${nbOfPacketFound} packets
    Should Be True                              ${nb_match} != 0
    ${nb_match_total}=                          Evaluate    ${nb_match} + ${nb_match2}
    Should Be True                              ${nb_match_total} == ${nbOfPacketFound}


Check dlData pdschSendReq
    [Documentation]
    ...     Conditions:
    ...     Actions:
    ...     Checks:
    ...     Verdict:
    [Arguments]             ${pdml_file}        # input filename for analyzing
    ...                     ${field_values}     # input keys and values to filter before checking
    ...                     ${subcellid}
    ...                     ${packet_end}=-1    # -1 is the default value for parsing all packets
    ...                     ${packet_name}=dldata_pdschsendreq
    ...                     ${nb_prb_blanking_low}=0
    ...                     ${nb_prb_blanking_high}=0
    ...                     ${total_prb}=${NUM_MAX_PRB_DEFAULT}
    ...                     ${rbgsize}=16
    ...                     ${is_large_bwp}=${True}
    ...                     ${total_prb_bwp2}=${NUM_MAX_PRB_BWP_60MHZ}

    ${msg_field}=                               Set Variable    @{field_values.keys()}
    Dated Log New Line                          ===> check dlData pdschSendReq if prb allocated are in non-blanking
    Dated Log                                   ===> from ${pdml_file} for keys ${msg_field} and subcellid=${subcellid}
    @{listPacketMatch}                          Get Packet Match List    pdmlFile=${pdml_file}
        ...                                                         packetName=${packet_name}
        ...                                                         pathList=@{msg_field}
        ...                                                         startPacket=${1}
        ...                                                         endPacket=${${packet_end}}    #vbo#check done among the first packet_end packets
        ...                                                         filter='subcellid$'==${subcellid}
    ${nbOfPacketFound}=                         get length    ${listPacketMatch}
    Dated Log                                   ===> number of packet ${packet_name} with subcellid=${subcellid} is ${nbOfPacketFound}
    Should Be True                              ${nbOfPacketFound} != 0

    # use of RBG must be applied in case of downlink
    FOR    ${nb_rbg}    IN RANGE    0    10
        ${first_prb_non_blanking}=              Evaluate    ${nb_rbg} * ${rbgsize}
        Exit For Loop If    ${nb_prb_blanking_low} <= ${first_prb_non_blanking}
    END
    ${first_prb_non_blanking}=    Run Keyword If    ${is_large_bwp}    Evaluate    ${first_prb_non_blanking} + 0
    ...                                       ELSE    Evaluate    ${nb_prb_blanking_low} + 0    # applicable for small and PS bandwidth
    ${rbgsize_val}=                             Evaluate    ${total_prb} % ${rbgsize}
    ${rbgsize_last}=    Run Keyword If    ${rbgsize_val} == 0    Set Variable    ${rbgsize}
    ...                             ELSE    Set Variable    ${rbgsize_val}
    ${nb_rbgprb}=    Run Keyword If    ${nb_prb_blanking_high} == 0    Set Variable    0
    ...                          ELSE           Set Variable    ${rbgsize_last}
    FOR    ${nb_rbg}    IN RANGE    1    10
        Exit For Loop If    ${nb_rbgprb} >= ${nb_prb_blanking_high}
        ${nb_rbgprb}=                           Evaluate    ${rbgsize_last} + (${nb_rbg} * ${rbgsize})
    END
    ${last_prb_non_blanking}=    Run Keyword If    ${is_large_bwp}    Evaluate    ${total_prb} - ${nb_rbgprb} - 1
    ...                                      ELSE    Evaluate    ${first_prb_non_blanking} + ${total_prb_bwp2} - 1    # applicable for small and PS_
    ${nb_prb_max}=    Run Keyword If    ${is_large_bwp}    Evaluate    ${total_prb} - ${first_prb_non_blanking} - ${nb_rbgprb}
    ...                           ELSE    Evaluate    ${total_prb_bwp2} + 0    # applicable for small and PS bandwidth

    Dated Log    ===> blanking configuration is low edge=${nb_prb_blanking_low} and high edge=${nb_prb_blanking_high} with subcellid=${subcellid}
    Dated Log    ===> max. nbOfPrb=${nb_prb_max} and ${first_prb_non_blanking} <= possible non-blanking prb <= ${last_prb_non_blanking}

    FOR    ${current_packet}    IN    @{listPacketMatch}
        ${packet_str}=                          Packet Match to Str    packetMatch=${current_packet}    fields=${msg_field}
        ${packet_dict}=                         Create Packet Dictionary    packet_str=${packet_str}
        ${sfn_found}=                           Get From Dictionary    ${packet_dict}    sfn
        ${slot_found}=                          Get From Dictionary    ${packet_dict}    slot
        ${rnti_found}=                          Get From Dictionary    ${packet_dict}    rnti
        ${start_prb_found}=                     Get From Dictionary    ${packet_dict}    startPrb
        ${nb_prb_found}=                        Get From Dictionary    ${packet_dict}    numOfPrb
        ${rbgsize_found}=                       Get From Dictionary    ${packet_dict}    rbgSize
        ${rbgsize_first_found}=                 Get From Dictionary    ${packet_dict}    rbgSizeFirst
        ${num_layers_found}=                    Get From Dictionary    ${packet_dict}    numOfLayers

        # first_prb should not be into blanking low area
        ${check_result}=    Run Keyword If    ${start_prb_found} < ${first_prb_non_blanking}    Run Keywords    Set Variable    ${False}
        ...    AND    Dated Log    ===> failure is detected because startPrb=${start_prb_found} should not be < ${first_prb_non_blanking}
        ...    AND    Dated Log    ===> for packet: ${packet_str}
        ...                             ELSE    Set Variable    ${True}
        Should Be True                          ${check_result}

        ${start_prb_found_int}=                 Convert To Integer    ${start_prb_found}
        ${nb_prb_found_int}=                    Convert To Integer    ${nb_prb_found}
        ${last_prb_found}=                      Evaluate    ${start_prb_found_int} + ${nb_prb_found_int} - 1
        # last_prb should not be into blanking high area
        ${check_result}=    Run Keyword If    ${last_prb_found} > ${last_prb_non_blanking}    Run Keywords    Set Variable    ${False}
        ...    AND    Dated Log    ===> failure is detected because startPrb+numOfPrb-1 should not be > ${last_prb_non_blanking}
        ...    AND    Dated Log    ===> for packet: ${packet_str}
        ...                             ELSE    Set Variable    ${True}
        Should Be True                          ${check_result}
    END


Check ulData pucchReceiveReq
    [Documentation]
    ...     Conditions:
    ...     Actions:
    ...     Checks:
    ...     Verdict:
    [Arguments]             ${pdml_file}        # input filename for analyzing
    ...                     ${field_values}     # input keys and values to filter before checking
    ...                     ${subcellid}
    ...                     ${packet_end}=-1    # -1 is the default value for parsing all packets
    ...                     ${packet_name}=uldata_pucchreceivereq
    ...                     ${nb_prb_blanking_low}=0
    ...                     ${nb_prb_blanking_high}=0
    ...                     ${total_prb}=${NUM_MAX_PRB_DEFAULT}
    ...                     ${is_large_bwp}=${True}
    ...                     ${total_prb_bwp2}=${NUM_MAX_PRB_BWP_60MHZ}

    ${msg_field}=                               Set Variable    @{field_values.keys()}
    Dated Log New Line                          ===> check ulData pucchReceiveReq if prb allocated are in non-blanking
    Dated Log                                   ===> from ${pdml_file} for keys ${msg_field} and subcellid=${subcellid}
    @{listPacketMatch}                          Get Packet Match List    pdmlFile=${pdml_file}
        ...                                                         packetName=${packet_name}
        ...                                                         pathList=@{msg_field}
        ...                                                         startPacket=${1}
        ...                                                         endPacket=${${packet_end}}    #vbo#check done among the first packet_end packets
        ...                                                         filter='subcellid$'==${subcellid}
    ${nbOfPacketFound}=                         get length    ${listPacketMatch}
    Dated Log                                   ===> number of packet ${packet_name} with subcellid=${subcellid} is ${nbOfPacketFound}
    Should Be True                              ${nbOfPacketFound} != 0

    ${first_prb_non_blanking}=                  Set Variable    ${nb_prb_blanking_low}
    ${last_prb_non_blanking}=    Run Keyword If    ${is_large_bwp}    Evaluate    ${total_prb} - ${nb_prb_blanking_high} - 1
    ...                                      ELSE    Evaluate    ${first_prb_non_blanking} + ${total_prb_bwp2} - 1    # applicable for small and PS_

    Dated Log    ===> blanking configuration is low edge=${nb_prb_blanking_low} and high edge=${nb_prb_blanking_high} with subcellid=${subcellid}
    Dated Log    ===> ${first_prb_non_blanking} <= possible non-blanking prb <= ${last_prb_non_blanking}

    FOR    ${current_packet}    IN    @{listPacketMatch}
        ${packet_str}=                          Packet Match to Str    packetMatch=${current_packet}    fields=${msg_field}
        ${packet_dict}=                         Create Packet Dictionary    packet_str=${packet_str}
        ${sfn_found}=                           Get From Dictionary    ${packet_dict}    sfn
        ${slot_found}=                          Get From Dictionary    ${packet_dict}    slot
        ${rnti_found}=                          Get From Dictionary    ${packet_dict}    rnti
        ${rnti_found}=                          Get From Dictionary    ${packet_dict}    pucchFormat
        ${num_layers_found}=                    Get From Dictionary    ${packet_dict}    numOfLayers
        ${start_prb_found}=                     Get From Dictionary    ${packet_dict}    startPrb
        ${nb_prb_found}=                        Get From Dictionary    ${packet_dict}    numOfPrb

        # first_prb should not be into blanking low area
        ${check_result}=    Run Keyword If    ${start_prb_found} < ${first_prb_non_blanking}    Run Keywords    Set Variable    ${False}
        ...    AND    Dated Log    ===> failure is detected because startPrb=${start_prb_found} should not be < ${first_prb_non_blanking}
        ...    AND    Dated Log    ===> for packet: ${packet_str}
        ...                             ELSE    Set Variable    ${True}
        Should Be True                          ${check_result}

        ${start_prb_found_int}=                 Convert To Integer    ${start_prb_found}
        ${nb_prb_found_int}=                    Convert To Integer    ${nb_prb_found}
        ${last_prb_found}=                      Evaluate    ${start_prb_found_int} + ${nb_prb_found_int} - 1
        # last_prb should not be into blanking high area
        ${check_result}=    Run Keyword If    ${last_prb_found} > ${last_prb_non_blanking}    Run Keywords    Set Variable    ${False}
        ...    AND    Dated Log    ===> failure is detected because startPrb+numOfPrb-1 should not be > ${last_prb_non_blanking}
        ...    AND    Dated Log    ===> for packet: ${packet_str}
        ...                             ELSE    Set Variable    ${True}
        Should Be True                          ${check_result}
    END


Check ulData puschReceiveReq
    [Documentation]
    ...     Conditions:
    ...     Actions:
    ...     Checks:
    ...     Verdict:
    [Arguments]             ${pdml_file}        # input filename for analyzing
    ...                     ${field_values}     # input keys and values to filter before checking
    ...                     ${subcellid}
    ...                     ${prb_reserved}     # information from PUCCH configuration tool
    ...                     ${packet_end}=-1    # -1 is the default value for parsing all packets
    ...                     ${packet_name}=uldata_puschreceivereq
    ...                     ${nb_prb_blanking_low}=0
    ...                     ${nb_prb_blanking_high}=0
    ...                     ${total_prb}=${NUM_MAX_PRB_DEFAULT}
    ...                     ${is_nb_prb_max_triggered}=${True}
    ...                     ${is_large_bwp}=${True}
    ...                     ${total_prb_bwp2}=${NUM_MAX_PRB_BWP_60MHZ}

    ${msg_field}=                               Set Variable    @{field_values.keys()}
    Dated Log New Line                          ===> check ulData puschReceiveReq if numOfPrbMax is reached and prb allocated are in non-blanking
    Dated Log                                   ===> from ${pdml_file} for keys ${msg_field} and subcellid=${subcellid}
    @{listPacketMatch}                          Get Packet Match List    pdmlFile=${pdml_file}
        ...                                                         packetName=${packet_name}
        ...                                                         pathList=@{msg_field}
        ...                                                         startPacket=${1}
        ...                                                         endPacket=${${packet_end}}    #vbo#check done among the first packet_end packets
        ...                                                         filter='subcellid$'==${subcellid}
    ${nbOfPacketFound}=                         get length    ${listPacketMatch}
    Dated Log                                   ===> number of packet ${packet_name} with subcellid=${subcellid} is ${nbOfPacketFound}
    Should Be True                              ${nbOfPacketFound} != 0

    ${nb_match}                                 Set Variable    0
    ${first_prb_non_blanking}=                  Set Variable    ${nb_prb_blanking_low}
    ${last_prb_non_blanking}=    Run Keyword If    ${is_large_bwp}    Evaluate    ${total_prb} - ${nb_prb_blanking_high} - 1
    ...                                      ELSE    Evaluate    ${first_prb_non_blanking} + ${total_prb_bwp2} - 1    # applicable for small and PS_
    ${nb_prb_max}=    Run Keyword If    ${is_large_bwp}    Evaluate    ${last_prb_non_blanking} - ${first_prb_non_blanking} - ${prb_reserved} + 1
    ...                           ELSE    Evaluate    ${total_prb_bwp2} + 0    # applicable for small and PS bandwidth

    Dated Log    ===> blanking configuration is low edge=${nb_prb_blanking_low} and high edge=${nb_prb_blanking_high} with subcellid=${subcellid}
    Dated Log    ===> max. nbOfPrb=${nb_prb_max} and ${first_prb_non_blanking} <= possible non-blanking prb <= ${last_prb_non_blanking}

    FOR    ${current_packet}    IN    @{listPacketMatch}
        ${packet_str}=                          Packet Match to Str    packetMatch=${current_packet}    fields=${msg_field}
        ${packet_dict}=                         Create Packet Dictionary    packet_str=${packet_str}
        ${sfn_found}=                           Get From Dictionary    ${packet_dict}    sfn
        ${slot_found}=                          Get From Dictionary    ${packet_dict}    slot
        ${rnti_found}=                          Get From Dictionary    ${packet_dict}    rnti
        ${start_prb_found}=                     Get From Dictionary    ${packet_dict}    startPrb
        ${nb_prb_found}=                        Get From Dictionary    ${packet_dict}    numOfPrb
        ${num_layers_found}=                    Get From Dictionary    ${packet_dict}    numOfLayers
        ${nb_match}=    Run Keyword If    ${rnti_found} != 65535 and ${nb_prb_found} == ${nb_prb_max}
        ...                                     Evaluate    ${nb_match} + 1
        ...                         ELSE        Evaluate    ${nb_match} + 0

        # nb_prb should not be greater than nb_prb_max
        ${check_result}=    Run Keyword If    ${nb_prb_found} > ${nb_prb_max}    Run Keywords    Set Variable    ${False}
        ...    AND    Dated Log    ===> failure is detected because numOfPrb=${nb_prb_found} should not be > ${nb_prb_max}
        ...    AND    Dated Log    ===> for packet: ${packet_str}
        ...                             ELSE    Set Variable    ${True}
        Should Be True                          ${check_result}

        # first_prb should not be into blanking low area
        ${check_result}=    Run Keyword If    ${start_prb_found} < ${first_prb_non_blanking}    Run Keywords    Set Variable    ${False}
        ...    AND    Dated Log    ===> failure is detected because startPrb=${start_prb_found} should not be < ${first_prb_non_blanking}
        ...    AND    Dated Log    ===> for packet: ${packet_str}
        ...                             ELSE    Set Variable    ${True}
        Should Be True                          ${check_result}

        ${start_prb_found_int}=                 Convert To Integer    ${start_prb_found}
        ${nb_prb_found_int}=                    Convert To Integer    ${nb_prb_found}
        ${last_prb_found}=                      Evaluate    ${start_prb_found_int} + ${nb_prb_found_int} - 1
        # last_prb should not be into blanking high area
        ${check_result}=    Run Keyword If    ${last_prb_found} > ${last_prb_non_blanking}    Run Keywords    Set Variable    ${False}
        ...    AND    Dated Log    ===> failure is detected because startPrb+numOfPrb-1 should not be > ${last_prb_non_blanking}
        ...    AND    Dated Log    ===> for packet: ${packet_str}
        ...                             ELSE    Set Variable    ${True}
        Should Be True                          ${check_result}
    END

    # at least 1 packet should be found to verify that nb_prb_max is reached
    Dated Log    ===> ${nb_match} packets are matched the numOfPrbMax=${nb_prb_max} among the ${nbOfPacketFound} packets
    ${check_result}=    Run Keyword If    ${is_nb_prb_max_triggered} and ${nb_match} == 0    Run Keywords    Set Variable    ${False}
    ...    AND    Dated Log    ===> failure is detected because numOfPrb is not reached numOfPrbMax=${nb_prb_max} among all the analyzed packets
    ...                             ELSE    Set Variable    ${True}
    Should Be True                          ${check_result}


Check ulData srsReceiveReq
    [Documentation]
    ...     Conditions:
    ...     Actions:
    ...     Checks:
    ...     Verdict:
    [Arguments]             ${pdml_file}        # input filename for analyzing
    ...                     ${field_values}     # input keys and values to filter before checking
    ...                     ${subcellid}
    ...                     ${packet_end}=-1    # -1 is the default value for parsing all packets
    ...                     ${packet_name}=uldata_srsreceivereq
    ...                     ${nb_prb_blanking_low}=0
    ...                     ${nb_prb_blanking_high}=0
    ...                     ${total_prb}=${NUM_MAX_PRB_DEFAULT}

    ${msg_field}=                               Set Variable    @{field_values.keys()}
    Dated Log New Line                          ===> check ulData srsReceiveReq if prb allocated are in non-blanking
    Dated Log                                   ===> from ${pdml_file} for keys ${msg_field} and subcellid=${subcellid}
    @{listPacketMatch}                          Get Packet Match List    pdmlFile=${pdml_file}
        ...                                                         packetName=${packet_name}
        ...                                                         pathList=@{msg_field}
        ...                                                         startPacket=${1}
        ...                                                         endPacket=${${packet_end}}    #vbo#check done among the first packet_end packets
        ...                                                         filter='subcellid$'==${subcellid}
    ${nbOfPacketFound}=                         get length    ${listPacketMatch}
    Dated Log                                   ===> number of packet ${packet_name} with subcellid=${subcellid} is ${nbOfPacketFound}
    Should Be True                              ${nbOfPacketFound} != 0


    ${first_prb_non_blanking}=                  Set Variable    ${nb_prb_blanking_low}
    ${last_prb_non_blanking}=                   Evaluate    ${total_prb} - ${nb_prb_blanking_high} - 1

    Dated Log    ===> blanking configuration is low edge=${nb_prb_blanking_low} and high edge=${nb_prb_blanking_high} with subcellid=${subcellid}
    Dated Log    ===> ${first_prb_non_blanking} <= possible non-blanking prb <= ${last_prb_non_blanking}

    FOR    ${current_packet}    IN    @{listPacketMatch}
        ${packet_str}=                          Packet Match to Str    packetMatch=${current_packet}    fields=${msg_field}
        ${packet_dict}=                         Create Packet Dictionary    packet_str=${packet_str}
        ${sfn_found}=                           Get From Dictionary    ${packet_dict}    sfn
        ${slot_found}=                          Get From Dictionary    ${packet_dict}    slot
        ${rnti_found}=                          Get From Dictionary    ${packet_dict}    rnti
        ${start_prb_found}=                     Get From Dictionary    ${packet_dict}    startPrb

        # first_prb should not be into blanking low area
        ${check_result}=    Run Keyword If    ${start_prb_found} < ${first_prb_non_blanking}    Run Keywords    Set Variable    ${False}
        ...    AND    Dated Log    ===> failure is detected because startPrb=${start_prb_found} should not be < ${first_prb_non_blanking}
        ...    AND    Dated Log    ===> for packet: ${packet_str}
        ...                             ELSE    Set Variable    ${True}
        Should Be True                          ${check_result}
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Traffic #
DL Traffic GBR SA Not Stopped
    [Documentation]
    ...     Conditions:     it is based on the arguments ${param} ${current_ue_setting} ${current_trf_id}
    ...     Actions:        it manages the DL traffic GBR on the UE
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        DL traffic is passed
    [Arguments]             ${param}
    ...                     ${current_ue_setting}=${BASIC_UE_SA}
    ...                     ${current_trf_id}=20

    # Step 1 on qfi=2 with protocol tcp
    Set To Dictionary                           ${current_ue_setting}    trf_id    ${current_trf_id}
    Set To Dictionary                           ${current_ue_setting}    qfi    2
    Traffic UE DL                               ueSetting=${current_ue_setting}
    ...                                         throughput=${current_ue_setting.throughput_gbr}
    ...                                         captureCallback=None
    ...                                         capture=None
    ...                                         captureDuration=0
    ...                                         duration=${param.duration}
    ...                                         shouldBeStop=False
    ...                                         deviation=${param.deviation}
    ...                                         protocol=tcp
    # Step 2 on qfi=3 with protocol udp
    ${current_trf_id}=                          Evaluate    ${current_trf_id} + 1
    Set To Dictionary                           ${current_ue_setting}    trf_id    ${current_trf_id}
    Set To Dictionary                           ${current_ue_setting}    qfi    3
    Traffic UE DL                               ueSetting=${current_ue_setting}
    ...                                         throughput=${current_ue_setting.throughput_gbr}
    ...                                         captureCallback=None
    ...                                         capture=None
    ...                                         captureDuration=0
    ...                                         duration=${param.duration}
    ...                                         shouldBeStop=False
    ...                                         deviation=${param.deviation}
    ...                                         protocol=udp


UL Traffic GBR SA Not Stopped
    [Documentation]
    ...     Conditions:     it is based on the arguments ${param} ${current_ue_setting} ${current_trf_id}
    ...     Actions:        it manages the UL traffic GBR on the UE
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        UL traffic is passed
    [Arguments]             ${param}
    ...                     ${current_ue_setting}=${BASIC_UE_SA}
    ...                     ${current_trf_id}=22

    # Step 1 on qfi=2 with protocol tcp
    Set To Dictionary                           ${current_ue_setting}    trf_id    ${current_trf_id}
    Set To Dictionary                           ${current_ue_setting}    qfi    2
    Traffic UE UL                               ueSetting=${current_ue_setting}
    ...                                         throughput=${current_ue_setting.throughput_gbr}
    ...                                         captureCallback=None
    ...                                         capture=None
    ...                                         captureDuration=0
    ...                                         duration=${param.duration}
    ...                                         shouldBeStop=False
    ...                                         deviation=${param.deviation}
    ...                                         protocol=tcp
    # Step 2 on qfi=3 with protocol udp
    ${current_trf_id}=                          Evaluate    ${current_trf_id} + 1
    Set To Dictionary                           ${current_ue_setting}    trf_id    ${current_trf_id}
    Set To Dictionary                           ${current_ue_setting}    qfi    3
    Traffic UE UL                               ueSetting=${current_ue_setting}
    ...                                         throughput=${current_ue_setting.throughput_gbr}
    ...                                         captureCallback=None
    ...                                         capture=None
    ...                                         captureDuration=0
    ...                                         duration=${param.duration}
    ...                                         shouldBeStop=False
    ...                                         deviation=${param.deviation}
    ...                                         protocol=udp


DL Traffic Not Stopped
    [Documentation]
    ...     Conditions:     it is based on the arguments ${param} ${current_ue_setting} ${current_trf_id}
    ...     Actions:        it manages the DL traffic on the UE
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        DL traffic is passed
    [Arguments]             ${param}
    ...                     ${current_ue_setting}
    ...                     ${current_trf_id}=1

    Set To Dictionary                           ${current_ue_setting}    trf_id    ${current_trf_id}
    Traffic UE DL                               ueSetting=${current_ue_setting}
    ...                                         throughput=${current_ue_setting.throughput}
    ...                                         captureCallback=None
    ...                                         capture=None
    ...                                         captureDuration=0
    ...                                         duration=${param.duration}
    ...                                         shouldBeStop=False
    ...                                         deviation=${param.deviation}


UL Traffic Not Stopped
    [Documentation]
    ...     Conditions:     it is based on the arguments ${param} ${current_ue_setting} ${current_trf_id}
    ...     Actions:        it manages the UL traffic on the UE fixed to 5 Mbps
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        UL traffic is passed
    [Arguments]             ${param}
    ...                     ${current_ue_setting}
    ...                     ${current_trf_id}=10

    Set To Dictionary                           ${current_ue_setting}    trf_id    ${current_trf_id}
    ${deviation_ul}=                            Evaluate    ${param.deviation} * 2
    Traffic UE UL                               ueSetting=${current_ue_setting}
    ...                                         throughput=${current_ue_setting.throughput_ul}
    ...                                         captureCallback=None
    ...                                         capture=None
    ...                                         captureDuration=0
    ...                                         duration=${param.duration}
    ...                                         shouldBeStop=False
    ...                                         deviation=${deviation_ul}


UL+DL Traffic Not Stopped
    [Documentation]
    ...     Conditions:     it is based on the arguments ${param} ${current_ue_setting} ${current_trf_id}
    ...     Actions:        it manages the DL traffic on the UE
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        DL traffic is passed
    [Arguments]             ${param}
    ...                     ${current_ue_setting}
    ...                     ${current_trf_id}=1

    Set To Dictionary                           ${current_ue_setting}    trf_id    ${current_trf_id}
    Traffic UE DL                               ueSetting=${current_ue_setting}
    ...                                         throughput=${current_ue_setting.throughput}
    ...                                         captureCallback=None
    ...                                         capture=None
    ...                                         captureDuration=0
    ...                                         duration=${param.duration}
    ...                                         shouldBeStop=False
    ...                                         deviation=${param.deviation}

    ${current_trf_id}=                          Evaluate    ${current_trf_id} + 9
    Set To Dictionary                           ${current_ue_setting}    trf_id    ${current_trf_id}
    Traffic UE UL                               ueSetting=${current_ue_setting}
    ...                                         throughput=${current_ue_setting.throughput_ul}
    ...                                         captureCallback=None
    ...                                         capture=None
    ...                                         captureDuration=0
    ...                                         duration=${param.duration}
    ...                                         shouldBeStop=False
    ...                                         deviation=${param.deviation}


DL Traffic Low Not Stopped
    [Documentation]
    ...     Conditions:     it is based on the arguments ${param} ${current_ue_setting} ${current_trf_id} ${throughput_low} ${throughput_ul_low}
    ...                     ${unit} ${bwp_transition}
    ...     Actions:        it manages the DL traffic low on the UE (unit is kbps by default)
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        traffics are passed
    [Arguments]             ${param}
    ...                     ${current_ue_setting}
    ...                     ${current_trf_id}=1
    ...                     ${throughput_low}=100
    ...                     ${throughput_ul_low}=100
    ...                     ${unit}=kbps
    ...                     ${bwp_transition}=from bwpId 1 to 2

    # downlink
    ${current_trf_id}=                          Evaluate    ${current_trf_id}
    Set To Dictionary                           ${current_ue_setting}    trf_id    ${current_trf_id}
    ${expected_bwp_transition}=                 Set Variable    Bwp Switched ${bwp_transition}
    Dated Log                                   ===> trf_data_start ue=${current_ue_setting.ue} dir=dl ${unit}=${throughput_low}
    Dated Log                                   ===> the expected transition should be ${expected_bwp_transition}
    wtsemu.trf_data_start    ue=${current_ue_setting.ue}    pdu=${current_ue_setting.pdu}    qfi=${current_ue_setting.qfi}    dir=dl
    ...                                                             ${unit}=${throughput_low}
    ${status}    ${output}    Run Keyword And Ignore Error    wtsemu.read_wtsemu_output_until    expected=${expected_bwp_transition}    timeout=10
    Run Keyword If                              '${status}'=='FAIL'    Dated log    ===> No entry found for ${expected_bwp_transition}
    ...         ELSE                            Dated log    ===> ${expected_bwp_transition} is found
    Run Keyword If                              '${status}'=='FAIL'    Fail    No entry found for ${expected_bwp_transition}
    Return From Keyword If                      '${status}'=='FAIL'
    wtsemu.bearer_stats_clear    ue=${current_ue_setting.ue}    pdu=${current_ue_setting.pdu}    qfi=${current_ue_setting.qfi}    dir=dl
    BuiltIn.Sleep    3s
    wtsemu.Bearer Stats    ue=${current_ue_setting.ue}    pdu=${current_ue_setting.pdu}    qfi=${current_ue_setting.qfi}    dir=dl
    ...                                                             trf_id=${current_trf_id}
    ${status}    ${output}    Run Keyword And Ignore Error    wtsemu.read_wtsemu_output_until    expected=Average packet interval    timeout=10
    Run Keyword If    '${status}'=='FAIL'       Fail    No entry found for Average data rate in case dir=dl ${unit}=${throughput_low}
    Return From Keyword If    '${status}'=='FAIL'
    ${output_1}                                 Get Lines Matching Regexp    ${output}    Average data rate .*    partial_match=${TRUE}
    Log to Console    ${output_1}

# --------------------------------------------------------------------------------------------------------------------------------------------------
# UE settings #
Get Number Of Ue Configured With GBR Traffic
    [Documentation]
    ...     Conditions:     it is based on the argument ${dict_ues}
    ...     Actions:        it returns the number of ue's configured with GBR traffic
    ...     Checks:         it checks that the requested GBR throughput for the ue's is different from 0
    ...     Verdict:        the number of ue's configured with GBR traffic is returned
    [Arguments]             ${dict_ues}

    ${current_value}=                           Set Variable    0
    FOR    ${current_ue}    IN    @{dict_ues}
        ${current_value}=    Run Keyword If    ${current_ue.DL_throughput_GBR} > ${NO_THROUGHPUT}
        ...                                     Evaluate    ${current_value} + 1
        ...                              ELSE    Evaluate    ${current_value} + 0
    END
    Dated Log                                   ===> number of ue's configured with GBR traffic is ${current_value}
    [Return]    ${current_value}


Configure New Ues
    [Documentation]
    ...     Conditions:     it is based on the arguments ${dict_ues} ${initial_nb_ue} ${total_nb_ue} ${dict_new_ue}
    ...     Actions:        it automatically configures new ue's to increase the number of ue's
    ...     Checks:         it needs no checks
    ...     Verdict:        the ue's list is increased
    [Arguments]             ${dict_ues}
    ...                     ${initial_nb_ue}
    ...                     ${total_nb_ue}
    ...                     ${dict_new_ue}

    ${diff_nb_ue}=                              Evaluate    ${total_nb_ue} - ${initial_nb_ue}
    FOR    ${current_ue}    IN RANGE    0    ${diff_nb_ue}
        Append To List                          ${dict_ues}    ${dict_new_ue}
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Counter #
Sleep Until PM Availability
    [Arguments]             ${pm_granularity_period}=300
    ...                     ${pm_availability_delay}=60

    Dated Log                                   ===> sleep until PM availability is started
    ${time_of_start}=                           Evaluate    int(time.time())    time
    ${time_of_next_pm_period}=                  Evaluate    (int(${time_of_start} / ${pm_granularity_period}) + 1) * ${pm_granularity_period}
    ${time_of_pm_availability}=                 Evaluate    ${time_of_next_pm_period} + ${pm_availability_delay}
    ${duration_until_pm_availability}=          Evaluate    ${time_of_pm_availability} - ${time_of_start}
    ${timeout_string}=                          Catenate    ${duration_until_pm_availability}  sec
    ${date_of_pm_availability}=                 Convert date    ${time_of_pm_availability}
    Dated Log                                   ===> PM should be available in ${timeout_string}, at ${date_of_pm_availability}
    BuiltIn.Sleep                               ${timeout_string}
    Dated Log                                   ===> sleep until PM availability is ended


Check Counter And KPI Constraints
    [Arguments]             ${pm_path}
    ...                     ${test_name}
    ...                     ${localKpiFileName}=${None}

    Dated Log                                   ===> check counter and KPI constraints is started
    ${localKpiFile}=    Run Keyword If    '${localKpiFileName}' == '${None}'    Set Variable   ${None}
    ...                             ELSE        Set Variable   ${CURDIR}/../../config/counter/KPI/${localKpiFileName}
    KPI Evaluate                                pmFile=${pm_path}
    ...                                         constraintsFile=${CURDIR}/../../config/counter/constraint/${test_name}.csv
    ...                                         failOnError=${True}
    ...                                         localKpiFile=${localKpiFile}
    Dated Log                                   ===> check counter and KPI constraints is ended

# --------------------------------------------------------------------------------------------------------------------------------------------------
# TTI data analysis functions #

Start TTI Logs
    Dated Log                                   ===> configuration and get TTI is started
    # TTI capture configuration
    ${TTIdir}=                                  Get TTI Trace Path
    Run Keyword If    not ${isAic}              Start TTI Traces in Streaming mode          src_ip=10.0.1.2
    ...         ELSE                            Start To Collect TTI Trace On AIC
    Set Suite Variable                          ${TTIdir}


Stop and Get TTI Logs
    [Arguments]             ${trace_name}=TTI

    Dated Log                                   ===> stop and get TTI Logs is started
    ${TTIpcap}=                                 Stop TTI Traces in Streaming mode    tti_trace_path=${TTIdir}    tti_trace_filename=${trace_name}
    Dated Log                                   ===> convert TTI to json and csv is started
    ${TTIjson}=                                 Convert TTI trace from pcap to others    input_file_path=${TTIpcap}
    ${TTIcsv}=                                  decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=50000
    Set Suite Variable                          ${TTIjson}
    [Return]    ${TTIjson}


Check cell bandwidth identify within TTI trace
    [Documentation]
    ...     Conditions:     it is based on the arguments ${json_file} ${phys_cell_id} ${search_space_type} ${search_space_id} ${cell_bwp_id}
    ...                     ${packet_name}
    ...     Actions:        it verifies the cell bandwidth information within TTI trace
    ...     Checks:         it checks the search_space_type, search_space_id and cell_bwp_id
    ...     Verdict:        the checks are passed
    [Arguments]             ${json_file}        # input filename for analyzing
    ...                     ${phys_cell_id}
    ...                     ${search_space_type}
    ...                     ${search_space_id}
    ...                     ${cell_bwp_id}
    ...                     ${packet_name}=dlFdSchedData

    Dated Log New Line    ===> check if cell bandwidth identity is ${cell_bwp_id} in packet=${packet_name} when physCellId=${phys_cell_id}
    Dated Log                                   ===> from ${json_file}
    ${check_result}=                            check_searchSpace_cellBwpId    _modeDbg=${False}    _jsonPath=${json_file}
    ...                                                         _eventType=${packet_name}
    ...                                                         _physCellId=${phys_cell_id}
    ...                                                         _spaceType=${search_space_type}
    ...                                                         _spaceId=${search_space_id}
    ...                                                         _cellBwpId=${cell_bwp_id}
    Run Keyword If    not ${check_result}
    ...    Dated Log    ===> failure is detected because constraints on cellBwpId and searchSpaceType and searchSpaceId are not verified
    Should Be True                              ${check_result}
    Dated Log                                   ===> Check cell bandwidth identify within TTI trace is passed


Check l1SubPoolStreamPrb Consistency within TTI trace
    [Documentation]
    ...     Conditions:     it is based on the arguments ${json_file} ${pool_id} ${pool_max_num_stream_prb} ${packet_name} ${number_packet_to_check}
    ...                     ${mode_debug}
    ...     Actions:        it verifies the consistency of the streams into TTI trace
    ...     Checks:         it compares the current_stream sum, calculated_stream sum to the maximum
    ...     Verdict:        the checks are passed
    [Arguments]             ${json_file}        # input filename for analyzing
    ...                     ${pool_id}
    ...                     ${pool_max_num_stream_prb}=2400
    ...                     ${packet_name}=dlInterL1SubpoolReconfData
    ...                     ${number_packet_to_check}=25000
    ...                     ${mode_debug}=${False}

    Dated Log New Line    ===> Check l1SubPoolStreamPrb Consistency in packet=${packet_name} for pool_id=${pool_id}
    Dated Log                                   ===> from ${json_file}

    ${check_result}=                            check_l1SubPoolStreamPrb_consistency    _json_path=${json_file}
    ...                                                         _event_type=${packet_name}
    ...                                                         _pool_id=${pool_id}
    ...                                                         _pool_max_num_stream_prb=${pool_max_num_stream_prb}
    ...                                                         _number_packet_to_check=${number_packet_to_check}
    ...                                                         _mode_debug=${mode_debug}
    Run Keyword If    not ${check_result}
    ...    Dated Log    ===> failure is detected because constraints on Check l1SubPoolStreamPrb Consistency are not verified
    Should Be True                              ${check_result}
    Dated Log    ===> Check l1SubPoolStreamPrb Consistency within TTI trace is passed on the first ${number_packet_to_check} packets analyzed
    Dated Log    ===> pool_id=${pool_id} and pool_max_num_stream_prb=${pool_max_num_stream_prb}


Check l1SubPoolStreamPrbCapacity within TTI trace
    [Documentation]
    ...     Conditions:     it is based on the arguments ${json_file} ${pool_id} ${sub_pool_id} ${pool_max_num_stream_prb} ${check_operator}
    ...                     ${default_stream} ${current_stream} ${calculated_stream} ${packet_name} ${number_packet_to_check} ${mode_debug}
    ...     Actions:        it verifies the stream information of a sub_pool_id into TTI trace
    ...     Checks:         it checks default_stream, current_stream, calculated_stream if not None
    ...     Verdict:        the checks are passed
    [Arguments]             ${json_file}        # input filename for analyzing
    ...                     ${pool_id}
    ...                     ${sub_pool_id}
    ...                     ${pool_max_num_stream_prb}=2400
    ...                     ${check_operator}===    # ==:0, >:1 and <:2
    ...                     ${default_stream}=${None}
    ...                     ${current_stream}=${None}
    ...                     ${calculated_stream}=${None}
    ...                     ${packet_name}=dlInterL1SubpoolReconfData
    ...                     ${number_packet_to_check}=25000
    ...                     ${mode_debug}=${False}

    Dated Log New Line    ===> Check l1SubPoolStreamPrbCapacity in packet=${packet_name} for pool_id=${pool_id} and sub_pool_id=${sub_pool_id}
    Dated Log                                   ===> from ${json_file}

    ${operator_value}=                          Run Keyword If    '${check_operator}' == '=='    Set Variable    0
    ...                                                     ELSE IF    '${check_operator}' == '>'    Set Variable    1
    ...                                                     ELSE IF    '${check_operator}' == '<'    Set Variable    2
    ...                                                     ELSE       Set Variable    3
    ${check_result}=                            check_l1SubPoolStreamPrbCapacity    _json_path=${json_file}
    ...                                                         _event_type=${packet_name}
    ...                                                         _pool_id=${pool_id}
    ...                                                         _pool_max_num_stream_prb=${pool_max_num_stream_prb}
    ...                                                         _sub_pool_id=${sub_pool_id}
    ...                                                         _operator_value=${operator_value}
    ...                                                         _default_stream=${default_stream}
    ...                                                         _current_stream=${current_stream}
    ...                                                         _calculated_stream=${calculated_stream}
    ...                                                         _number_packet_to_check=${number_packet_to_check}
    ...                                                         _mode_debug=${mode_debug}
    Run Keyword If    not ${check_result}
    ...    Dated Log    ===> failure is detected because constraints on Check l1SubPoolStreamPrbCapacity are not verified
    Should Be True                              ${check_result}
    Dated Log    ===> Check l1SubPoolStreamPrbCapacity within TTI trace is passed on the first ${number_packet_to_check} packets analyzed
    Dated Log    ===> pool_id=${pool_id} and for sub_pool_id=${sub_pool_id} and operation is ${check_operator}
    Dated Log    ===> default_stream=${default_stream}, current_stream=${current_stream} or default_stream, calculated_stream=${calculated_stream}


Check Number Of PRB Allocated within TTI trace
    [Documentation]
    ...     Conditions:     it is based on the arguments ${json_file} ${phys_cell_id} ${check_operator} ${stream_prb_gbr_alloc}
    ...                     ${stream_prb_non_gbr_alloc} ${num_alloc_prb} ${bbrm_usable_cell_prb} ${zab_privilege} ${packet_name}
    ...                     ${number_packet_to_check} ${mode_debug}
    ...     Actions:        it verifies the information of a cell into TTI trace
    ...     Checks:         it checks stream_prb_gbr_alloc, stream_prb_non_gbr_alloc, num_alloc_prb, bbrm_usable_cell_prb, zab_privilege if not None
    ...     Verdict:        the checks are passed
    [Arguments]             ${json_file}        # input filename for analyzing
    ...                     ${phys_cell_id}
    ...                     ${check_operator}===    # ==:0, >:1 and <:2
    ...                     ${stream_prb_gbr_alloc}=${None}
    ...                     ${stream_prb_non_gbr_alloc}=${None}
    ...                     ${num_alloc_prb}=${None}
    ...                     ${bbrm_usable_cell_prb}=${None}
    ...                     ${zab_privilege}=${None}
    ...                     ${packet_name}=dlAllocatedPooledResourcesData
    ...                     ${number_packet_to_check}=25000
    ...                     ${mode_debug}=${False}

    Dated Log New Line    ===> Check Number Of PRB Allocated in packet=${packet_name} for phys_cell_id=${phys_cell_id}
    Dated Log                                   ===> from ${json_file}

    ${operator_value}=                          Run Keyword If    '${check_operator}' == '=='    Set Variable    0
    ...                                                     ELSE IF    '${check_operator}' == '>'    Set Variable    1
    ...                                                     ELSE IF    '${check_operator}' == '<'    Set Variable    2
    ...                                                     ELSE       Set Variable    3
    ${check_result}=                            check_number_prb_allocated    _json_path=${json_file}
    ...                                                         _event_type=${packet_name}
    ...                                                         _phys_cell_id=${phys_cell_id}
    ...                                                         _operator_value=${operator_value}
    ...                                                         _stream_prb_gbr_alloc=${stream_prb_gbr_alloc}
    ...                                                         _stream_prb_non_gbr_alloc=${stream_prb_non_gbr_alloc}
    ...                                                         _num_alloc_prb=${num_alloc_prb}
    ...                                                         _bbrm_usable_cell_prb=${bbrm_usable_cell_prb}
    ...                                                         _zab_privilege=${zab_privilege}
    ...                                                         _number_packet_to_check=${number_packet_to_check}
    ...                                                         _mode_debug=${mode_debug}
    Run Keyword If    not ${check_result}
    ...    Dated Log    ===> failure is detected because constraints on Check Number Of PRB Allocated are not verified
    Should Be True                              ${check_result}
    Dated Log    ===> Check Number Of PRB Allocated within TTI trace is passed on the first ${number_packet_to_check} packets analyzed
    Dated Log    ===> phys_cell_id=${phys_cell_id} and operation is ${check_operator}
    Dated Log    ===> stream_prb_gbr_alloc=${stream_prb_gbr_alloc}, stream_prb_non_gbr_alloc=${stream_prb_non_gbr_alloc}
    Dated Log    ===> num_alloc_prb=${num_alloc_prb}, bbrm_usable_cell_prb=${bbrm_usable_cell_prb}, zab_privilege=${zab_privilege}
# --------------------------------------------------------------------------------------------------------------------------------------------------
