*** Settings ***
Documentation  TODO
...  Author: szymon.przybylak@nokia.com
...  Maintainer: szymon.przybylak@nokia.com

Library    ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library    taf.ul.vdu.helm.interface.helm   WITH NAME    helm
Library    taf.transport.ssh  WITH NAME  tafssh
Library    ../../../CLOUD/resources/python/cloud_keywords.py
Library    ../../../CLOUD/resources/python/common.py
Library   ../../../resources/artifactory.py  WITH NAME  artifactory
Resource  ../SWM/Cloud_SWM_vDU_Update.robot
Resource  ../LOGS/Cloud_LOGS_Fail_Safe_Mode_resource.resource
Resource    ../../resources/Robot/vdu_oam_operations.robot

*** Variables ***
@{VDU_FAILSAFE_UPDT_ALLOWED_ALARMS}=  faultId=2934, severity=critical
...                               faultId=4590, severity=warning
...                               faultId=10, severity=critical
...                               faultId=23, severity=critical
...                               faultId=4681, severity=minor
@{VCU_FAILSAFE_UPDT_ALLOWED_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_SWM_Radio_Unit_Software_Update_During_Fail_Safe_Mode
  [Arguments]  ${scfc_file_path}  ${rmod_ids}  ${log_to_console}=True  ${build_name}=${EMPTY}
  [Documentation]
  ...  Description:
  ...  Keyword Vdu Software Update During Fail Safe Mode.
  ...  The test updtes vDU to older version at the beginning, to ensure that the target software is the one that checks if
  ...  RU is updated correctly and without fail safe mode.
  ...  Tester has to set ${CCR_LOCATION} to wg/wl in testsuite.
  ...  For this TC/KW to work, tester has to prepare override files. The files (each named values-override.yaml) can be taken from
  ...  kuafu deployment, from corresponding folders for aic-vdu, aic-vdu-prerequisites, aic-vdu-cluster-preparations. Files should be stored in e.g.
  ...  /home/ute/testline_configuration/10_16_UTESRANSISO705/values_override/vDU
  ...  Names of the files should be:
  ...  main.yaml (for aic-vdu), preparation.yaml (for aic-vdu-cluster-preparations), prerequisites.yaml (for aic-vdu-prerequisites).
  ...
  ...  Step 1: Perform vDU software update to older version.
  ...  Step 2: Clear fault history on tested RU (reset).
  ...  Step 3: Enable fail safe mode on tested RU and reset RU.
  ...  Step 4: Disable fail safe mode on tested RU and DO NOT reset it.
  ...  Step 5: Perform vDU software update.
  ...  Step 6: Check onAIR, RU and cells statuses.
  ...
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | rmod_ids               | Yes  | RM serial numbers separated by '|'                                         |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | log_to_console         |  No  | Show or not the information on the console.                                |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | build_name             |  No  | Name of the target build, if necessary                                     |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: szymon.przybylak@nokia.com
  ...  Maintainer: szymon.przybylak@nokia.com
  # Preconditions start
  vDU Rest Login
  Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_FAILSAFE_UPDT_ALLOWED_ALARMS}
  Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_FAILSAFE_UPDT_ALLOWED_ALARMS}
  Set Test Variable  ${IS_PASSED}  False
  Set Test Variable  ${log_to_console}  True
  ${logs_dir_path}=  Set Variable  ${SUITE_LOGS_DIR_PATH}/${TEST_NAME}/test_run
  Set Test Variable  ${SCFC_FILE_PATH}  ${scfc_file_path}
   ${status}  ${restapi_version}=  Run Keyword And Ignore Error
  ...  Get vDU Rest Api Version  gnb_index=0  vdu_index=0
  ${restapi_version}=  Set Variable If  '${status}'=='FAIL'
  ...  ${VDU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}  ${restapi_version}
  ${index}=  Get Index From List  ${VDU_REST_TAF_LIB_SUPPORTED_VERSION}  ${restapi_version}
  ${oam_http_connection}=  Get vDU Oam Http Connection Parameters From Init File
  ...  gnb_index=0  vdu_index=0
  ${http_password}=  Set Variable If  ${index}>=${4}  nemuuser
  ...  ${oam_http_connection["password"]}
  ${ip_addr}=  Set Variable  ${oam_http_connection["ip_addr"]}
  ${port}=  Set Variable  ${oam_http_connection["port"]}
  ${username}=  Set Variable  ${oam_http_connection["username"]}
  ${password}=  Set Variable  ${http_password}
  ${secure}=  Set Variable  True
  ${rmod_id_list}=  vDU SCFC Get RMOD Id List  scfc_file_path=${scfc_file_path}
  ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
  Set Test Variable    ${CELLS_COUNT}    ${cells_count}
  ${RF_status}=   Run Keyword And Return Status    Variable Should Exist    ${rmod_ids}
  ${rf_list}=  Run Keyword If  ${RF_status}  Split String  string=${rmod_ids}  separator=|
  Set Test Variable  ${RF_LIST}  ${rf_list}
  ${vdu_k8s_connection_params}  Get vDU K8s Master Node Connection Parameters From Init File
  Set Test Variable  ${cloud_server_ip}  ${vdu_k8s_connection_params['ip_addr']}
  Software Update Preconditions  ${build_name}
  Wait Until All Cells Are OnAir  cells_count=${cells_count}

#  Step 1: Perform vDU software update to older version.
  Set Test Variable  ${OLD_VDU_UPDATE}  True
  Perform vDU Update  build_name=${DOWNGRADE_BUILD}  downgrade=True
  Wait Until All Cells Are OnAir  cells_count=${cells_count}

  Log  ${ok_prefix_green}All cells are OnAir. Old Software updated. Precondition finished.  console=${log_to_console}
  vdu.Connect To  host=${ip_addr}  port=${port}  username=${username}  password=${password}
  ...  vdu_version=${restapi_version}  secure=${secure}
  FOR  ${rmod_id}  IN  @{rmod_id_list}
    Create Directory  ${logs_dir_path}/${rmod_id}
    ${rmod_name}=  Set Variable  RMOD-${rmod_id}
    ${rmods_sn_id}=  vDU RMODs Get Serial Number And Id
    ${rmod_sn}=  Set Variable  ${rmods_sn_id['${rmod_id}']}
    Continue For Loop If  '${rmod_sn}' not in ${RF_LIST}
    ${false_fault}    Run Keyword And Return Status  radio.Assert Active Fault In Fault History Log File  ru_serial_number=${rmod_sn}
    ...  fault_id=1462
    ...  severity=Warning
    ...  cloud_server_ip=${cloud_server_ip}
    Should Not Be True    ${false_fault}    True
#    Step 2: Clear fault history on tested RU (reset).
    Log  ${info_prefix}Rebooting RMOD ${rmod_sn} to clean fault_history  console=${log_to_console}
    radio.Reboot Radio Module And Wait For Ping  ru_serial_number=${rmod_sn}
    ...  reconnect_timeout=240
    ...  ping_down_timeout=60
    ...  cloud_server_ip=${cloud_server_ip}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}Enable safe mode with RM reset on ${rmod_sn}  console=${log_to_console}
#    Step 3: Enable fail safe mode on tested RU and reset RU.
    Enable Fail Safe Mode On RM  ru_serial_number=${rmod_sn}
    ...  cloud_server_ip=${cloud_server_ip}
    ...  cells_count=${cells_count}
    Log  ${info_prefix}Waiting for FID2934  console=${log_to_console}
    ${alarm_severity_list}=  Create List  Critical
    vDU Assert Alarm Active  fault_id=2934
    ...  vdu_login=False
    ...  timeout=10min
    ...  alarm_severity_list=${alarm_severity_list}
    Log  ${info_prefix}Waiting for fault 1462 with severity Warning in fault history log file on RM  console=${log_to_console}
    radio.Assert Active Fault In Fault History Log File  ru_serial_number=${rmod_sn}
    ...  fault_id=1462
    ...  severity=Warning
    ...  cloud_server_ip=${cloud_server_ip}
#    Step 4: Disable fail safe mode on tested RU and DO NOT reset it.
    Enable Disable Fail Safe Mode On RM  value=disable
    ...  ru_serial_number=${rmod_sn}
    ...  cloud_server_ip=${cloud_server_ip}
    ...  should_reset=False
    Exit For Loop
  END
#  Step 5: Perform vDU software update.
    Set Test Variable  ${OLD_VDU_UPDATE}  False
    Perform vDU Update  build_name=${BASE_BUILD}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
#    Step 6: Check onAIR, RU and cells statuses.
    vDU Assert Alarm Inactive  fault_id=2934  vdu_login=False  timeout=10min
    Log  ${info_prefix}Fault 2934 cleared  console=${log_to_console}
  [Teardown]  Software Update Teardown

Enable Disable Fail Safe Mode On RM
    [Arguments]  ${value}  ${ru_serial_number}  ${cloud_server_ip}  ${should_reset}=True
    [Documentation]
    ...  Keyword for enabling or disabling fail safe mode on RM on cloudran
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | value                  | Yes  | Should insert "enable" or "disable" in order to choose option              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ru_serial_number       | Yes  | RM serial number                                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cloud_server_ip        | Yes  | IP of the cloud server                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | should_reset           | No   | Default value - True. If reset is not needed, send "False" into KW         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${info_prefix}Ongoing ${value} failsafe mode on RM  console=${log_to_console}
    radio.Open Connection To Radio Module  ru_serial_number=${ru_serial_number}
    ...  cloud_server_ip=${cloud_server_ip}
    radio.Send Command  command=frmonShellClient  delay=1
    radio.Send Command  / action create ResetControl /CI/ResetControl/module /module
    ${output}  radio.Read Output  delay=2
    Should Contain  ${output}   done ok
    radio.Send Command  command=/CI/ResetControl/module action ${value}_fail_safe_mode
    ${output}  radio.Read Output  delay=2
    Should Contain  ${output}   done ok
    Run Keyword If  ${should_reset}  radio.Reboot Radio Module And Wait For Ping  ru_serial_number=${ru_serial_number}
    ...  reconnect_timeout=240
    ...  ping_down_timeout=60
    ...  cloud_server_ip=${cloud_server_ip}
