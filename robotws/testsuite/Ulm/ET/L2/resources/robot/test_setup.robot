*** Settings ***
Documentation  This is a collection of keywords used to prepare the Testline for the Testcase.

Library    ./../../libraries/ulm_common_library.py                         WITH NAME   ucl
Library    ./../../libraries/template_functions.py                         WITH NAME   template
Resource   ../../../../resources/Common/reporting.robot
Resource   ../../../../resources/Common/wts_ue.robot
Resource   ../../../../resources/Common/ute_workarounds.robot
Resource   ../../../../resources/Common/git_handling.robot
Resource   ../../../../resources/Common/scout_kpi.robot
Resource   ./tracing.robot

*** Keywords ***

Initialize Test Suite
    Get Path To Current Testsuite Folder
    ${deployment_type}=  ucl.kwrun  Get Node Deployment Type
    test_setup.Read Test Configuration from JSON File
    Suite Setup for Airphone
    IF    '${LOGS_AND_TRACES_FLAGS["KPI"]["calculation"]}'=='True'
        scout_kpi.Enable KPI Collection
    END
    Set Suite Variable   ${ARE_TEST_SCENARIOS_RUN}    False


Get Path To Current Testsuite Folder
    ${robot_suite_dir}=  String.Split String  ${SUITE SOURCE}  /
    ${robot_suite_dir}=  Evaluate   '/'.join(${robot_suite_dir[:-2]})
    Set Suite Variable    ${ROBOT_SUITE_DIR}    ${robot_suite_dir}
    Log To Console    ROBOT_SUITE_DIR is: ${ROBOT_SUITE_DIR}


Read Test Configuration from JSON File
    ucl.kwrun  Patch testline configuration for UTE Cloud
    IF    '${relative_json_path}' == ''
        template.initialize_test  data=${teal_config}
    ELSE
        template.initialize_test  path_to_basic_cfg=${tl.core.dir_path}/${tl.core.cfg_filename}
        ...                       modified_file_path=${tl.core.dir_path}/${tl.core.cfg_filename}
        ...                       relative_path_to_json=${relative_json_path}
    END
    ${logs_and_traces_flags}=  template.get_logs_and_traces_flags
    ${extra_options_flags}=  template.get_extra_options_flags
    ${variable_cell_dict}=  template.get_variable_cell_dict
    FOR  ${key}  IN  @{variable_cell_dict}
        set suite variable  ${${key}}  ${variable_cell_dict}[${key}]
    END
    set suite variable    ${logs_and_traces_flags}
    set suite variable    ${extra_options_flags}


Suite Setup for Airphone
    [Documentation]    Collect all needed configuration to bring TL back to status
    ...    AirphoneConfig.xml, basic.cfg, ap_swconfig, gnb_swconfig, SCF
    ...    Upload needed config file to TL
    Run Keyword And Warn On Failure  ucl.kwrun  ute_workarounds.Log TL Info As Metadata For UTE AP TL
    Run Keyword And Warn On Failure  Set SW Duplex Variable According To cellTechnology
    Run Keyword And Warn On Failure  Set SW Wavelength Variable According To nrarfcn
    ucl.kwrun  testline.Set Console Output
    ucl.kwrun  testline.Create Test Suite Log Folders
    Set Suite Log Directory
    Store TL Configuration Files before Test begins
    Get config info for cOAM
    log variables
    ucl.kwrun  git_handling.Save Current Workspace Info
    ucl.kwrun  ute_workarounds.UTE Cloud Workaround
    ucl.kwrun  testline.Check TL Infos
    Get Cell Dist Parameters
    Reinitialize gNB if required
    Run Keyword And Warn On Failure    ucl.kwrun  gnb.Get Swconfig From GNB    target_dir=${configuration_directory}


Set SW Duplex Variable according to cellTechnology
    ${SW_DUPLEX}=         ucl.kwrun  wts_ue.Get cellTechnology Info
    Set Suite Variable    ${SW_DUPLEX}


Set SW Wavelength Variable according to nrarfcn
    ${nrarfcn_Str}=      ucl.kwrun  wts_ue.Get nrarfcn Info
    @{nrarfcn_List}=     Split string    ${nrarfcn_Str}    :
    ${nrarfcn}=          Convert to integer    ${nrarfcn_List}[0]
    ${SW_WAVELENGTH}=    Set variable if  ${nrarfcn} > 2000000    MMWV    CMWV
    Set Suite Variable   ${SW_WAVELENGTH}


Set Suite Log Directory
    ${ts_log_dir}=  ucl.kwrun  Get test suite log directory
    set suite variable  ${ts_log_dir}


Store TL Configuration files before Test begins
    ${configuration_directory}=    ucl.kwrun  testline.Get Test Suite Config Directory
    set suite variable     ${configuration_directory}
    Backup SCF From Classical GNB
    Run Keyword And Warn On Failure    ucl.kwrun  gnb.Store Current Swconfig From GNB    gnb_id=${0}    target_dir=${configuration_directory}
    Run Keyword And Warn On Failure    ucl.kwrun  wts_ue.Store Current Swconfig From Airphone
    ...                                           ue_id=${0}    target_dir=${configuration_directory}
    Run Keyword And Warn On Failure    ucl.kwrun  wts_ue.Store Current WTS Config    target_dir=${configuration_directory}


Backup SCF From Classical gNB
    ${original_gnb_scf}=    ucl.kwrun  gnb.Get SCF from gNB    gnb_id=${0}    target_dir=${configuration_directory}
    ...                                scf_name=SCFC_gNB0_DU_orig.xml
    set suite variable    ${original_gnb_scf}


Get Config Info for cOAM
    ${sw_build}=  Retreive gNB sw version
    set suite variable  ${sw_build}
    ${pCell_dict}=  ucl.kwrun  Get gNB Physical Cell ID
    Set Suite Variable    ${pCell_dict}
    set environment variable  SW_BUILD  ${sw_build}
    log to console  SW VERSION UNDER TEST: ${sw_build}


Retreive gNB sw version
    ${current_gnb_sw}=  ucl.kwrun  Get gNB SW version
    Append to file  ${OUTPUT_DIR}/sw_version.txt  ${current_gnb_sw}
    RETURN  ${current_gnb_sw}


Get Cell Dist Parameters
    ${cell_distName_params}=  ucl.kwrun  Get distNames from Local SCF File    scf_path=${original_gnb_scf}
    ...                                  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${cell_distName_params}
    Set Suite Variable  ${cell_distName_params}


Reinitialize gNB if required
    ${reinitialize_required}=    Get Variable Value    ${REINIT_GNB}
    ${reinitialize_required}=    Set Variable If    '${reinitialize_required}' == 'false'    ${False}    ${True}
    Set Suite Variable  ${reinitialize_required}
    ${gnb_rebooted}=  Set Variable  ${False}
    Set Suite Variable  ${gnb_rebooted}
    IF    not ${reinitialize_required}  Log  gNB will not be Reinitialized, test will run with existing SCF and basic config
    ...  level=WARN
    IF  ${reinitialize_required}  Initialize gNB    ELSE  ucl.kwrun  Connect to running EGATE


Initialize gNB
    Set Suite Variable  ${SYSLOG_PREPERATION_NEEDED}    ${True}
    IF  "${logs_and_traces_flags["Syslog_Initial_Commissioning"]}"=="True"  tracing.Prepare And Start Syslogs
    Make necessary Changes to SCF
    IF  "${logs_and_traces_flags["Syslog_Initial_Commissioning"]}"=="True"  tracing.Stop BTSLog Collection  btslog_initial_commissioning
    Backup WTS Config    basic_setup.cfg.orig
    Update Basic Configuration File
    template.configure_basic_cfg_file
    Backup WTS Config
    Bring cell on air  cell_setup_trace_dir=${ts_log_dir}/cell_setup_trace_initial


Backup WTS Config
    [Arguments]    ${basic_setup_file_name}=basic_setup.cfg
    Copy File   ${tl.core.dir_path}/${tl.core.cfg_filename}  ${configuration_directory}/${basic_setup_file_name}


Bring cell on air
    [Arguments]  ${cell_setup_trace_dir}=${ts_log_dir}/cell_setup_trace_initial
    Run Keyword And Warn On Failure  ucl.kwrun  wts_ue.Kill WTS Services
    IF  "${logs_and_traces_flags["CellSetup_Syslogs"]}"=="True"  tracing.Prepare And Start Syslogs
    ${cell_setup_trace_required}=  Set Variable If  '${logs_and_traces_flags['CellSetupL2_L3Trace']}'=='True'  ${TRUE}  ${FALSE}
    ${status}=  Run keyword and ignore error  Variable should not exist  ${force_reboot}
    ${status}=  IF  '${status[${0}]}'=='PASS'  Run Keyword and ignore error  ucl.kwrun
    ...  ute_workarounds.Bring Airphone TL to on Air status without reboot
    ...  capture_cell_setup_trace=${cell_setup_trace_required}
    ...  cell_setup_trace_dir=${ts_log_dir}/cell_setup_trace_initial
    ${status}  IF  ${status}==None  Create List  FAIL  ELSE  Create List  ${status[${0}]}
    IF  '${status[${0}]}'=='FAIL'  Log to console  Bring cell on air without reboot failed, trying with reboot
    IF  '${status[${0}]}'=='FAIL'  ucl.kwrun  ute_workarounds.Bring Airphone TL to on Air status
    ...  capture_cell_setup_trace=${cell_setup_trace_required}
    ...  cell_setup_trace_dir=${cell_setup_trace_dir}
    ${status}=  Run Keyword And Return Status  Should Be Empty  ${scenario_name}
    ${scenario_name}  Set Variable If  ${status}  initial    ${scenario_name}
    IF  "${logs_and_traces_flags["CellSetup_Syslogs"]}"=="True"  tracing.Stop BTSLog Collection  btslog_${scenario_name}_cell_setup_trace
    ${gnb_rebooted}=  Set Variable  ${True}
    IF  ${cell_setup_trace_required}  Convert Cell Setup Trace from PCAP to PDML  trace_dir=${ts_log_dir}/cell_setup_trace_initial
    Set Suite Variable    ${gnb_rebooted}


Convert Cell Setup Trace from PCAP to PDML
    [Arguments]  ${trace_dir}
    ucl.kwrun  util.Convert PCAP to PDML  source=${trace_dir}/l2_l3_tcpdump.pcap    filter="sctp"
    ...  target=${trace_dir}/l2_l3_tcpdump.pdml


