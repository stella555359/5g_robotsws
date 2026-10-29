*** Settings ***
Documentation    Generic keywords for test suite case preparation
...              and some useful keywords


Library     taf.ul.energy_efficiency_monitoring                             WITH NAME   monitoring


*** Variables ***
${monitoring_interval}    15min    #Interval value for monitoring


*** Keywords ***
Activating Energy Effecency Monitoring
    monitoring.configure_bts_connection
    log to console    Enabling energy efficiency monitoring.     console=True
    monitoring.enable_energy_efficiency_monitoring
    ...    mtBtsEnergyMonitoring=${monitoring_interval}
    ...    mtSBTSRfmEnergyMonitoring=${monitoring_interval}
    ...    mtSBTSSmEnergyMonitoring=${monitoring_interval}

Backup SBTS Configuration
  [Documentation]    This keyword assumes that the SBTS is already running and accessible.
  ...    backup the scf and swconfig of the BTS
  [Arguments]    ${local_dir}=${PATH_Storage}    ${filename_prefix}=initial
  # Backup SCF and swconfig.txt under test
  gnbbbu.get_bts_configuration_file   local_dir=${local_dir}    filename=${filename_prefix}_scf.xml
  # useful_keywords.download_swconfig_file  local_dir=${local_dir}    filename=${filename_prefix}_swconfig.txt
  useful_keywords.download_swconfig_file  local_dir=${local_dir}    hostname=${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
  ...    filename=${filename_prefix}_swconfig.txt

Collect Active Alarms
    [Documentation]    This keyword assumes that the SBTS is already running and accessible.
    ...    This keyword will collect all active alarms
    [Arguments]    ${local_dir}=${PATH_Storage}    ${alarms_prefix}=${Empty}
    ${active_alarms_list}=   useful_keywords.Get Active Alarms  allowed_alarms=${ALLOWED_ALARMS}
    useful_keywords.Save Alarms  ${active_alarms_list}  ${local_dir}    alarms_prefix=${alarms_prefix}
    Return From Keyword If  ${active_alarms_list} != @{EMPTY}   ${True}
    Return From Keyword    ${False}


Collect IMS File
   [Documentation]    This keyword assumes that the SBTS is already running and accessible.
   ...    This keyword will collect ths IMS BTS file
   [Arguments]    ${log_dir}=${OUTPUT DIR}    ${gnb_id}=${0}    ${timeout}=${120}    ${du_id}=${0}

   ${ims_file_path}=    gnblog.collect_ims_log    bts_id=${gnb_id}    log_dir=${log_dir}    timeout=${timeout}    du_id=${du_id}
   Set Suite Variable    ${ims_file_path}

Collect IMS File From eNB
   [Documentation]    This keyword assumes that the SBTS is already running and accessible.
   ...    This keyword will collect ths IMS eNB BTS file
   [Arguments]   ${log_dir}
   ${ims_file_path}  useful_keywords.collect_IMS_file_from_eNB        log_dir=${log_dir}
   # @{ims_files}=  List Files In Directory  ${log_dir}  pattern=*.bin
   @{ims_files}=  List Files In Directory  ${log_dir}  pattern=Log_IMS*.bin
   Set Suite Variable  ${ims_file}  ${log_dir}${ims_files[-1]}
   # OperatingSystem.run  find ${log_dir} -name \"*.ims2\" -exec rm {} \\;

Test Suite Preparation
  [Documentation]    Generic keyword for all test suite.
  ...    This keyword will set up some check and variable preparation for classical BTS tests.
  Update TL Test PC Variable
  Suite Dir Preparation
  Backup SBTS Configuration    filename_prefix=initial_conf
  Test Suite Variables Initialisation

Suite Dir Preparation
  [Documentation]    Generic keyword for all test suite.
  ...    This keyword prepares the directory structure for a Robot Framework test suite. It creates necessary
  ...    subdirectories and files based on the provided test.
  ${date}             DateTime.Get Current Date    result_format=%Y%m%d_%H_%M
  ${suite_dir}        replace string      ${SUITE NAME}_${date}    ${SPACE}    _
  ${suite_dir}        joinpath            ${OUTPUTDIR}/robot_temporary/${ENB_BRANCH}     ${suite_dir}
  create directory    ${suite_dir}
  Set Suite variable   ${PATH_Storage}     ${suite_dir}

Test Case Dir Preparation
  [Documentation]    This keyword prepares the directory structure for a specific Robot Framework test case
  ...    within a test suite. It creates necessary subdirectories and files based on the provided test case.
  ${directory}        replace string      ${TEST NAME}    ${SPACE}    _
  ${res_path}         joinpath        ${PATH_Storage}     ${directory}
  create directory    ${res_path}
  Set Suite Variable   ${res_path}
  # ue_proxy.Stop Ue Proxy On Ue PC
  # ue_proxy.Start Ue Proxy On Ue PC


Test Suite Teardown
  [Documentation]    Generic keyword for all test suite.
  ...    This teardown keyword will if requested restore the initial SCF and copy the rbot output
  ...    files log.html, output.xml and report.html to suite test directory.
  ${CUT_POWER_OFF}=  Get Variable Value  ${POWER_OFF_Testline}  ${False}
  # Run Keyword If  '${CUT_POWER_OFF}' in ${YES_ANSWER}  Turn all DUs RUs TestLine PDU Power Position To   off
  Run Keyword If     "${RESTORE_BTS_CONFIGURATION}" in ['yes', 'Yes', 'YES']
  ...  Run Keyword And Ignore Error
  ...  Perform Full Commissioning and OnAir Check  ${PATH_Storage}/initial_conf_scf.xml
  ...                                              ${PATH_Storage}/initial_conf_swconfig.txt
  Cache Cleanup
  Start Process       sleep 120 && cp ${OUTPUT_FILE} ${PATH_Storage}           shell=True
  Start Process       sleep 120 && cp ${LOG_FILE} ${PATH_Storage}              shell=True
  Start Process       sleep 120 && cp ${REPORT_FILE} ${PATH_Storage}           shell=True

Update TL Test PC Variable
    [Documentation]    This keyword will set automaticaly Test PC for BTSLog
    ...                Crated on 2022-02-14 by Abderrahmane NEZROUK
    ...                .
    ${cmd}  Set Variable  hostname -I | awk '{print $1}'
    ${IP_VM}      Run       ${cmd}
    # Return From Keyword If  '${tl.test_pc.default_ssh_connection_details.addr}' == '${IP_VM}'     ${None}
    ${length}   Get Length  ${tl.test_pcs}
    ${index}    Set Variable  ${0}
    FOR  ${index}  IN RANGE  ${length}
        Run Keyword If  '${tl.test_pcs[${index}].default_ssh_connection_details.addr}' == '${IP_VM}'  Run Keywords
        ...             Set Suite Variable  ${tl.test_pc.default_ssh_connection_details.addr}
        ...                                 ${tl.test_pcs[${index}].default_ssh_connection_details.addr}
        ...             AND
        ...             Set Suite Variable  ${tl.test_pc.default_ssh_connection_details.username}
        ...                                 ${tl.test_pcs[${index}].default_ssh_connection_details.username}
        ...             AND
        ...             Set Suite Variable  ${tl.test_pc.default_ssh_connection_details.password}
        ...                                 ${tl.test_pcs[${index}].default_ssh_connection_details.password}
        ...             AND
        ...             Exit For Loop
    END
    Run Keyword If  ${index} > ${length} - 1      Fail  Error on Test PC declaration Please fix it before to run the test

Wait for Site Unavailability
  [Documentation]    This keyword will wait untill the BTS will not be reacheable using ping
  ...    to check if realy the BTS reset or switched off within 120s.
  Wait until Keyword Succeeds  120s  1s  Site Unavailability

Wait for Site Availability
  [Documentation]    This keyword will wait untill the BTS will be reacheable using ping within 120s
  Wait until Keyword Succeeds  120s  1s  Site Availability

Site Unavailability
  [Documentation]    This keyword will ponctually check if the BTS is not reacheable using ping
  ${ping_output}  Run  ping -c 4 -W 10 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
  Should Not Contain  ${ping_output}  4 packets transmitted, 4 received

Site Availability
  [Documentation]    This keyword will ponctually check if the BTS is reacheable using ping
  ${ping_output}  Run  ping -c 4 -W 10 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
  Should Contain  ${ping_output}  4 packets transmitted, 4 received

Cache Cleanup
  [Documentation]    This keyword will erase the ssh cache
  ssh.Reset cache

Validate SCF Plan
    [Documentation]    This keyword assumes that the BTS is Up and running and that the validation rules are defined.
    ...    The keyword should handle potential errors during validation, such as invalid SCF data or access issues.
    [Arguments]    ${scf_path}=${PATH_Storage}/initial.xml
    ${Validation_Error}=    useful_keywords.Validation Scf Online    ${scf_path}
    Run Keyword If  not ${Validation_Error}
    ...        Fail  current scf contains errors please fix them before to continuing \n ${Validation_Error}

Set BTSLog Rad Parameters on Classical gNB
    [Documentation]    This keyword will set BTSLog IP and Port rad params on gNB
    ...    using AaShell commandes
    ...    This keyword assumes that the gNB device is accessible and that the provided parameters are valid.
    ...    The specific RAD parameters and their values may vary depending on the gNB model and firmware version.
    ${resp}=  OperatingSystem.RUN   ip addr show eth1 | grep 192.168.255 | awk '{ print $2 }' | cut -d/ -f1
    ${0x10042}=  Set Variable If
    ...          '192.168.255.126' == '${resp}'  0xC0A8FF7E        # AaSysLogUdpAddress  192.168.255.126
    ...          '192.168.255.130' == '${resp}'  0xC0A8FF82        # AaSysLogUdpAddress  192.168.255.130
    ...           0
    ${0x10043}=  Set Variable               0xC738            # AaSysLogUdpPort     51000
    ${0x10041}=  Set Variable               0x5               # Debug
    ${parametersList}= 	Catenate  SEPARATOR=${SPACE} 	0x10041=${0x10041}  0x10042=${0x10042}  0x10043=${0x10043}
    Run Keyword If   ${0x10042} != 0
    ...   radParams.set_rad_flags    ${parametersList}   persistently=${False}

Set BTSLog Rad Parameters value
    [Documentation]    This keyword will set Rad parameters value using AaShell commandes
    ...    This keyword assumes that the gNB device is accessible and that the provided parameters are valid.
    ...    The specific RAD parameters and their values may vary depending on the gNB model and firmware version.
    [Arguments]    ${radParamId}    ${radParamValue}    ${persistently}=${False}

    ${parametersList}= 	Catenate  SEPARATOR=${SPACE} 	${radParamId}=${radParamValue}
    radParams.set_rad_flags    ${parametersList}   persistently=${persistently}

Perform Full Commissioning and OnAir Check
    [Documentation]    This keyword will perform full commissiong of the classical BTS (eNB/gNB).
    [Arguments]    ${scf_path}    ${swconfig_path}
    Log    ${scf_path}
    Log    ${swconfig_path}
    useful_keywords.Validation Scf Online  ${scf_path}
    useful_keywords.upload_swconfig    sw_config_path=${swconfig_path}
    useful_keywords.perform_commissioning  ${scf_path}
    Wait For Site To Be Onair  timeout=1800

Update Allowed Alarms List
  [Documentation]    This keyword will update the list of the allowed allarm for the test.
  FOR  ${alarm}  IN  @{ALARMS_LIST_TO_SKIP.split(',')}
    Run Keyword If  '${alarm}' not in @{ALLOWED_ALARMS}
    ...  Append To List  ${ALLOWED_ALARMS}  ${alarm}
  END
  set suite variable    ${ALLOWED_ALARMS}
  Log   ${ALLOWED_ALARMS}

Wait for onAir
    # 'verify_all_radio_module_status' is deprecated
    # Wait Until Keyword Succeeds  12 min sec  5 sec  gnb_ru.Verify All Radio Module Status
    Wait Until Keyword Succeeds  12 min sec  5 sec  gnbru.Verify All Radio Units Statuses
    ...  availability_status=online
    ...  operational_state=enabled
    ...  administrative_state=unlocked
    ...  procedural_status=configured

    # 'verify_setup_of_all_cells' is deprecated
    # Wait Until Keyword Succeeds  12 min sec  5 sec  gnb_cell.Verify Setup Of All Cells
    Wait Until Keyword Succeeds  12 min sec  5 sec  gnbcell.Verify All Cells Are Onair
    gnb_bbu.Verify gNB is onAir

