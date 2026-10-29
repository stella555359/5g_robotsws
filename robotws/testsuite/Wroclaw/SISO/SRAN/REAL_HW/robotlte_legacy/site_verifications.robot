*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Resource    ../Resources/Setup/setup_and_teardown.robot
#Resource  ./common_setup.robot
Resource  ./site_operations.robot

#Resource  ./variables.robot


Library  BuiltIn
Library  Collections
Library  String
Library  robot.libraries.DateTime
Library  taf.sbts.oam.coam.admin  WITH NAME  admin
Library  ute_admin_infomodel    WITH NAME    admin_im

*** Keywords ***
Check FHS List Status
  [Arguments]  ${fhs_list}  ${timeout}  ${bts_id}
  ${detected_list}=  Create List
  ${not_detected_list}=  Create List
  FOR  ${fhs}  IN  @{fhs_list}
    ${fhs_status}=  Run Keyword And Continue On Failure  Check FHS Unit Status  ${fhs}  ${timeout}  ${bts_id}
    Run Keyword If  ${fhs_status}  Append To List  ${detected_list}  ${fhs}
    ...  ELSE  Append To List  ${not_detected_list}  ${fhs}
    Run Keyword And Continue On Failure  Should Be True  ${fhs_status}
  END
  Run Keyword If  ${not_detected_list}  Log  Not Detected FHS list: ${not_detected_list}.  console=True
  Run Keyword If  ${detected_list}  Log  Detected FHS list: ${detected_list}.  console=True

Check FHS Unit Status
  [Arguments]  ${serial_number}  ${timeout}  ${bts_id}
  ${fhs_object}=  Run Keyword And Continue On Failure
  ...  admin_im.Query Infomodel
  ...  query=get object //FHS_L-* is [stateInfo.proceduralState=ethernetEnabled,serialNumber=${serial_number}]
  ...  timeout=${timeout}
  ...  alias=${bts_id}

  ${object_1}=  Set Variable  check ${fhs_object['dist_name']} is [stateInfo.operationalState=regex"(?i)enabled
  ${object_2}=  Set Variable  |disabled",stateInfo.availabilityStatus!=regex"(?i)not\\s?installed"]
  ${sum_object}=  Set Variable  ${object_1}${object_2}
  ${fhs_status}=  Run Keyword And Continue On Failure
  ...  admin_im.Query Infomodel
  ...  query=${sum_object}
  ...  timeout=${timeout}
  ...  alias=${bts_id}
  ${fhs_object}=  Run Keyword And Ignore Error
  ...  admin_im.Query Infomodel
  ...  query=get object //FHS_L-* is [stateInfo.proceduralState=ethernetEnabled,serialNumber=${serial_number}]
  ...  timeout=${timeout}
  ...  alias=${bts_id}
  [Return]  ${fhs_status}

#Info Model FHS SW Version Is Compatible With BTS SW
#  [Documentation]  Keyword returns 'True', if given ${serial_number_list} has compatible SW with BTS SW,
#  ...  'False' if it's not compatible, and fails, if verification could not be performed.
#  ...  ${timeout} defines time to retrieve given serial number SW version.
#  ...  Author:
#  ...  Maintainer:  Author
#  [Arguments]  ${serial_number_list}  ${targetbd_path}=/home/ute/Downloads/  ${timeout}=10  ${alias}=default
#  ...  ${bts_ip}=192.168.255.1  ${bts_login_timeout}=20  ${bts_access_alias}=default  ${remote_host}=None
#  ${serial_number_list}=  Convert Item To Single Element List  ${serial_number_list}
#  ${status}=  Set Variable If  "${serial_number_list}"=="@{EMPTY}"  True  False
#  FOR  ${serial_number}  IN  @{serial_number_list}
#    ${fhs_object}=  Run Keyword And Continue On Failure
#    ...  admin_im.Query Infomodel
#    ...  query=get object //FHS_L-* is [stateInfo.proceduralState=ethernetEnabled,ipAddress!=empty,serialNumber=${serial_number}]
#    ...  timeout=${timeout}
#    ...  alias=${alias}
#    ${fhs_fhu_object}=  Run Keyword And Continue On Failure
#    ...  admin_im.Query Infomodel  query=get object /${fhs_object['dist_name']}//STORAGE_L-*/FILE_SYSTEM_L-*/BUILD_DATA_L-1
#    ...  timeout=${timeout}
#    ...  alias=${alias}
#    ${compatible_sw}=  Get Radio Compatible SW From TargetBD  ${fhs_object['productName']}
#    ...  download_path=${targetbd_path}
#    ...  ip_addr=${bts_ip}
#    ...  timeout=${bts_login_timeout}
#    ...  alias=${bts_access_alias}
#    ...  remote_host=${remote_host}
#    ${status}=  Run Keyword And Return Status  Should Be True  "${fhs_fhu_object['bldVersion']}" in ${compatible_sw}
#    Exit For Loop If  '${status}'!='True'
#  END
#  [Return]  ${status}

#Check RMOD List SW Version Is Compatible With BTS SW
#  [Documentation]  Keyword returns 'True', if given ${serial_number_list} has compatible SW with BTS SW,
#  ...  'False' if it's not compatible, and fails, if verification could not be performed.
#  ...  ${timeout} defines time to retrieve given serial number SW version.
#  ...  Author:  piotr.korczynski@nokia.com
#  ...  Maintainer:  Author
#  [Arguments]  ${serial_number_list}  ${targetbd_path}=/home/ute/Downloads/  ${timeout}=10  ${alias}=default
#  ...  ${bts_ip}=192.168.255.129  ${bts_login_timeout}=20  ${bts_access_alias}=default  ${remote_host}=None
##  ${hw_admin_list}=  Get Parameters For All  RMOD  alias=${alias}
#  Run Keyword If  "${remote_host}"=="None"  Run Keywords
#  ...  Setup Enb Fsm Access  ip_addr=${bts_ip}  timeout=${timeout}  alias=${alias}
#  ...  AND  wait_for_host_ssh  host=${bts_ip}  timeout=${timeout}
#  ...  ELSE  Run Keywords
#  ...  Setup Enb Fsm Access  ip_addr=${bts_ip}  timeout=${timeout}  alias=${alias}  remote_host=${remote_host}
#  ...  AND  wait_for_host_ssh  host=${bts_ip}  remote_host=${remote_host}  timeout=${timeout}
#  ${targetbd_path}=  Get Enb Targetbd File  ${targetbd_path}  alias=${alias}
#  FOR  ${hw_key}  IN  @{serial_number_list}
#    ${asirmod_status}=  Run Keyword And Return Status  admin.Assert Any
#    ...  class_name=ASIRMOD
#    ...  parameters=buildVersion!=empty, serialNumber=${hw_key}
#    ...  timeout=60
#    ...  alias=${alias}
#    Run Keyword If  not ${asirmod_status}  admin.Assert Any
#    ...  class_name=RMOD
#    ...  parameters=buildVersion!=empty, serialNumber=${hw_key}
#    ...  timeout=${timeout}
#    ...  alias=${alias}
#    ${class}=  Set Variable If  ${asirmod_status}  ASIRMOD  RMOD
#    ${fr_distname}=  Admin Get Rmod Distname For Rmod Serial Number  ${hw_key}  alias=${alias}
#    ${hw_admin_list}=  Get Parameters For  ${class}  ${fr_distname}  alias=${alias}
##  ${hw_key_sn}=  Get From Dictionary  ${hw_key}  serialNumber
#    ${hw_key_build}=  Get From Dictionary  ${hw_admin_list}  buildVersion
#    ${hw_key_product_code}=  Get From Dictionary  ${hw_admin_list}  productName
#    ${hw_compatible_sw_list}=  Get Elements
#    ...  ${targetbd_path}  //hwResource[contains(@resourceBuildKey, '${hw_key_product_code}')]/@resourceSWVersion
#    ${status}=  Run Keyword And Return Status  Should Be True  "${hw_compatible_sw_list[0]}"=="${hw_key_build}"
#    Exit For Loop If  "${status}"=="False"
#  END
#  [Teardown]  Teardown Enb Fsm Access  alias=${alias}
#  [Return]  ${status}

Verify Power Reset Startup Parameters
  [Arguments]  ${test_logs_path}  ${node}
#  Run Keyword If  ${REPETITION_COUNT}==1  Set Test Variable    ${ITERATION}  1
  ${index}=  Set Variable If  ${REPETITION}  ${ITERATION}  1
  admin.collect_infomodel_log_from_current_session
  ...  target_file_name=${test_logs_path}/infomodel_power_reset_${node}.ims2
  ...  timeout=120  connection=${node}  leave_disconnect_logs=True
  kpi.clear_results
  ${kpi3}=  Run Keyword And Continue On Failure  kpi.calculate_kpi3
  ...  ims_file_path=${test_logs_path}/infomodel_power_reset_${node}.ims2
  ...  start_point_timestamp=${power_start_timestamp}
  ${kpi3}=  kpi.get_all_deltas  kpi_name=kpi3
  ${kpi3}=  Set Variable  ${kpi3[0]}
  ${test_verdict}=  Set Variable If  ${${kpi3}} > ${CONFIGURATION_STARTUP_TIMEOUT}  Failed  Passed
  Run Keyword If  "${test_verdict}" == "Failed"  Log
  ...  Specified startup time (${CONFIGURATION_STARTUP_TIMEOUT} second) was exceeded.  console=yes
  ${test_verdict_log_level}=  Set Variable If  '${test_verdict}' == 'Failed'  WARN  INFO
  Run Keyword And Continue On Failure  Run Keyword If  "${test_verdict}" != "Passed" and ${ACTIVE_STARTUP_VERDICT}
  ...  Fail  Fail reason - Measured time: ${${kpi3}} > ${CONFIGURATION_STARTUP_TIMEOUT}
  Log  message=\nPower Reset on bts_id node=${node} executed with startup time (KPI3) = ${kpi3}  console=True
  Run Keyword If  ${ACTIVE_STARTUP_VERDICT}  Log
  ...  Expected time = ${CONFIGURATION_STARTUP_TIMEOUT}
  ...  console=True
  ...  level=${test_verdict_log_level}

  ${tmp_it_dict}=  Create Dictionary  &{EMPTY}
  ${kpi_verdict}=  Set Variable If  "${test_verdict}" == "Failed"  0  1
  Append To File
  ...  path=${cfg.test_logs_path}/${node}_verdict_kpi.txt
  ...  content=iteration; ${index}; verdict;${kpi_verdict}; kpi_3; ${kpi3}\n
  Run Keyword And Ignore Error  Remove File  ${test_logs_path}infomodel_${node}.ims2


Prepare Hanging Resource For BTS
  [Arguments]  ${bts_id}
  ${bts_sm}=  Get From Dictionary  ${cfg.NODES['${bts_id}']}  primary_sm
  ${bts_alias_type}=  Get From Dictionary  ${cfg.NODES['${bts_id}']}  bts_alias_type
  ${hop_ip}=  Set Variable If  '${bts_alias_type}' == 'localhost'  ${cfg.NODES['${bts_id}']['host_ip']}  ${EMPTY}
  ${hop_dict_remote}=  Create Dictionary  host=${hop_ip}
  ${hop_dict}=  Create Dictionary  proxy=${hop_dict_remote}
  Run Keyword And Continue On Failure  aashell.Create Aashell Cli  name=aashell  hops=${hop_dict}
  Run Keyword And Continue On Failure  aashell.Setup  alias=aashell
  ${resources_usage}=  Run Keyword And Ignore Error  Get Resources Usage  name=aashell
  [Teardown]  Run Keyword And Ignore Error  aashell.Teardown  alias=aashell  force=True
  [Return]  ${resources_usage}

Compare Resource Usage
  [Arguments]  ${resources_usage_before}  ${resources_usage_after}
  Return From Keyword If  '${HANGING_RESOURCES_CHECK}'=='False'
  Run Keyword And Continue On Failure  Compare Resources Data Deepdiff
  ...  resources_usage1=${resources_usage_before}
  ...  resources_usage2=${resources_usage_after}
  Run Keyword And Continue On Failure  Should Be Equal As Resources
  ...  resources_usage1=${resources_usage_before}
  ...  resources_usage2=${resources_usage_after}
  ...  exclude=//bufferPoolFreeCount

Check Is BTS Is Ready For API
  [Arguments]  ${bts_id}  ${timeout}
  Run Keyword And Return Status
  ...  admin_im.Query Infomodel
  ...  query=none /MRBTS-1/RAT-1/URI-1/SESSION-*/PLAN_ACTIVATE_IND-*
  ...  timeout=${timeout}
  ...  alias=${bts_id}
  Run Keyword And Return Status
  ...  admin_im.Query Infomodel
  ...  query=none /MRBTS-1/RAT-1/URI-1/SESSION-*/PLAN_VALIDATE_IND-*
  ...  timeout=${timeout}
  ...  alias=${bts_id}


Refresh SW active state
    ${bts_id_list}=    Get Dictionary Keys   ${cfg.NODES}
    Check Build On Every Described Node      ${cfg}    ${bts_id_list}
