*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Resource    ../Resources/Setup/setup_and_teardown.robot
Resource  ./common_setup.robot
Resource  ./site_operations.robot
Resource  ./site_verifications.robot
Resource  ./variables.robot


Library  BuiltIn
Library  Collections
Library  String
Library  robot.libraries.DateTime
Library  taf.sbts.oam.coam.admin    WITH NAME    admin
Library  ute_admin_infomodel    WITH NAME    admin_im

*** Variables ***
@{COMPONENTS_TO_INCLUDE_MAIN}  BTSSM_downloadable
@{COMPONENTS_TO_INCLUDE_ALL}
...  BTSSM_downloadable
...  BTSSM_downloadable_testpackage_T1
...  BTSSM_downloadable_testpackage_T2
${SOFTWARE_SOURCE}  WFT
${5G_artifactory}  https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/
${5G_sm_type}  ASIK_ABIL
${CONFIGURATION_STARTUP_TIMEOUT}  1200


*** Keywords ***
#Sw Update To Tested Build
#  create directory  ${OUT_SUITE_LOGS_DIR_PATH}/${OUT_CURRENT_TESTED_CONFIGURATION}_prepare
#  set suite variable
#  ...  ${OUT_TESTCASE_LOGS_DIR_PATH}
#  ...  ${OUT_SUITE_LOGS_DIR_PATH}/${OUT_CURRENT_TESTED_CONFIGURATION}_prepare
#  Logging Test Group Start  logs_dir_path=${OUT_TESTCASE_LOGS_DIR_PATH}  file_name_postfix=Precondition
#  Run Keyword If  ${KEY_PERFORM_HW_SETUP}==True  Run Keywords
#  ...  Prepare SW Update  sw_package=update  AND
#  ...  Perform SW Update  sw_package_file_path=${OUT_SW_UNDER_TEST_PACKAGE_FILE_PATH}  wait_for_reset=False  AND
#  ...  Run Keyword And Continue On Failure  admin.Info Model MRBTS Should Be In Procedural State
#  ...  state=regex"commissioned|configured|integrated|onAir"  timeout=360
#  Logging Test Group Save And Stop  logs_dir_path=${OUT_TESTCASE_LOGS_DIR_PATH}  file_name_postfix=Precondition

Perform SW Update
  [Arguments]  ${sw_package_file_path}  ${wait_for_reset}=True
  Log  Updating SW to ${sw_package_file_path}  console=yes

  ${sw_download_response}=  Run Keyword And Ignore Error
  ...  admin.Update Software
  ...  sw_package=${sw_package_file_path}
  ...  timeout=3600
  Run Keyword If  '${sw_download_response[0]}' == 'FAIL'  Run Keywords
  ...  Sleep  360 sec
  ...  AND  admin.Update Software
  ...  sw_package=${sw_package_file_path}
  ...  timeout=5000
  Run Keyword If  ${wait_for_reset}  BTS Unavailable  240

#Prepare SW Update
#  [Arguments]  ${sw_package}
#  ${out_enb_active_sw}  ${out_enb_passive_sw}=  Get eNB Active And Passive SW Versions  timeout=60
#  Run Keyword If
#  ...  "${CLOUD_STARTUP}" == "False"
#  ...  Prepare SW Update Not In Cloud Environment
#  ...  ${sw_package}
#  ...  ${SW_BUILDS_DIR_PATH}
#  ...  ELSE
#  ...  Prepare SW Update Cloud Environment
#  ...  ${sw_package}
#  ...  ${SW_BUILDS_DIR_PATH}
#  Set To Dictionary  ${out_active_configuration_dict}  sw_active=${out_enb_active_sw}

Check Build On Every Described Node
  [Arguments]  ${cfg}  ${nodes_list}
  FOR  ${node_id}  IN  @{nodes_list}
    ${master_host_ip}=  Get From Dictionary  ${cfg['NODES']['${node_id}']}  vm_ip_LMP_address
    ${active_sw}=  Run Keyword And Ignore Error  radio.Get Active Software Release From ENB
    ...  remote_host=${master_host_ip}
    ...  full_build_name=${True}
    ${node_sw_release}  ${trunk_status}=  Get SW Release From SW Name  ${active_sw}[1]
    Set To Dictionary
    ...  ${cfg.NODES['${node_id}']}
    ...  software_active=${active_sw}[1]
    ...  software_passive=${active_sw}[1]
    ...  active_release=${node_sw_release}
  END


Check Main Software Package Availability
  [Arguments]  ${active_sw}  ${bts_id}
  ${is_5G}=  Run Keyword And Return Status  Should Match Regexp  ${active_sw}  5G
  ${software_package_path}=  Run Keyword If  ${is_5G}
  ...  Check Main Software Package Availability For 5G  ${active_sw}
  ...  ELSE  Check Main Software Package Availability For SRAN  ${active_sw}  ${bts_id}
  [Return]  ${software_package_path}

Check Main Software Package Availability For SRAN
  [Arguments]  ${active_sw}  ${bts_id}
  ${software_package_name}  ${software_active_component}=  Create Software Package Name  ${active_sw}
  Create Directory  ${SW_BUILDS_DIR_PATH}
  ${components_to_include}=  Create List
  ${software_package_type}=  Set Variable If
  ...  "${software_active_component}" == "T1"  T1
  ...  "${software_active_component}" == "T2"  T2
  ...  T0
  ${sw_elements}=  Split String  ${cfg.NODES['${bts_id}']['software_active']}  _
  ${SW_PLATFORM}=  Set Variable If  '${sw_elements[1]}'=='ENB'  ${EMPTY}  _${sw_elements[1]}
  Set Test Variable  ${SW_PLATFORM}
  ${software_package_path_ute_net}=  SWM.SWM Get Software For Testing
  ...  path=${SW_BUILDS_DIR_PATH}
  ...  sw_ver=${software_package_name}
  ...  sw_index=${software_package_type}
  ${software_package_path}=  Set Variable If
  ...  "${software_package_type}" == "T0"
  ...  ${SW_BUILDS_DIR_PATH}/${software_package_name}_release_BTSSM_downloadable_A54.zip
  ...  ${SW_BUILDS_DIR_PATH}/${software_package_name}_release_BTSSM_downloadable_testpackage_${software_package_type}_A54.zip
  Set Test Variable  ${software_active_file}  ${software_package_path}
  [Return]  ${software_package_path}

Check Main Software Package Availability For 5G
  [Arguments]  ${active_sw}
  ${software_active_package_name}  ${software_active_component}=  Create Software Package Name For 5G  ${active_sw}
  Create Directory  ${SW_BUILDS_DIR_PATH}
  ${software_package_path_artifactory}=  Download Software Package From 5G Artifactory
  ...  ${SW_BUILDS_DIR_PATH}  ${software_active_package_name}  ${software_active_component}
  Set Test Variable  ${software_active_file}  ${software_package_path_artifactory}
  Convert To String  ${software_package_path_artifactory}
  [Return]  ${software_package_path_artifactory}

Check Different Software Package Availability
  [Arguments]  ${active_sw}  ${bts_id}
  ${is_5G}=  Run Keyword And Return Status  Should Match Regexp  ${active_sw}  5G
  ${software_package_path}=  Run Keyword If  ${is_5G}
  ...  Check Different Software Package Availability For 5G  ${active_sw}
  ...  ELSE  Check Different Software Package Availability For SRAN  ${bts_id}
  [Return]  ${software_package_path}

Check Different Software Package Availability For SRAN
  [Arguments]  ${bts_id}
  ${software_active_package_name}  ${software_active_component}=  Create Software Package Name
  ...  ${cfg.NODES['${bts_id}']['software_active']}
  ${software_passive_package_name}  ${software_passive_component}=  Create Software Package Name
  ...  ${cfg.NODES['${bts_id}']['software_active']}
  ${components_to_include}=  Create List
  ${software_package_type}=  Set Variable If
  ...  "${software_passive_component}" != "T1" and "${software_active_component}" != "T1"  T1
  ...  "${software_passive_component}" != "T2" and "${software_active_component}" != "T2"  T2
  ...  T0
  Run Keyword If
  ...  "T1" == "${software_package_type}"
  ...  Append To List
  ...  ${components_to_include}
  ...  BTSSM_downloadable_testpackage_T1
  ...  ELSE IF
  ...  "T2" == "${software_package_type}"
  ...  Append To List
  ...  ${components_to_include}
  ...  BTSSM_downloadable_testpackage_T2
  ...  ELSE
  ...  Append To List
  ...  ${components_to_include}
  ...  BTSSM_downloadable
  Create Directory  ${SW_BUILDS_DIR_PATH}
    ${sw_elements}=  Split String  ${cfg.NODES['${bts_id}']['software_active']}  _
    ${SW_PLATFORM}=  Set Variable If  '${sw_elements[1]}'=='ENB'  ${EMPTY}  _${sw_elements[1]}
    Set Test Variable  ${SW_PLATFORM}
  ${software_package_path_ute_net}=  SWM.SWM Get Software For Testing
  ...  path=${SW_BUILDS_DIR_PATH}
  ...  sw_ver=${software_active_package_name}
  ...  sw_index=${software_package_type}
  ${software_package_path}=  Set Variable If
  ...  "${software_package_type}" == "T0"
  ...  ${SW_BUILDS_DIR_PATH}/${software_active_package_name}_release_BTSSM_downloadable_A54.zip
  ...  ${SW_BUILDS_DIR_PATH}/${software_active_package_name}_release_BTSSM_downloadable_testpackage_${software_package_type}_A54.zip
  [Return]  ${software_package_path}

Check Different Software Package Availability For 5G
  [Arguments]  ${active_sw}
  ${software_active_package_name}  ${software_active_component}=  Create Software Package Name For 5G  ${active_sw}
  ${software_passive_package_name}  ${software_passive_component}=  Create Software Package Name For 5G  ${active_sw}
  ${components_to_include}=  Create List
  ${software_package_type}=  Set Variable If
  ...  "${software_passive_component}" != "T1" and "${software_active_component}" != "T1"  T1
  ...  "${software_passive_component}" != "T2" and "${software_active_component}" != "T2"  T2
  ...  ${EMPTY}
  Run Keyword If  "T1" == "${software_package_type}"  Append To List  ${components_to_include}  T1
  ...  ELSE IF  "T2" == "${software_package_type}"  Append To List  ${components_to_include}  T2
  ...  ELSE  Append To List  ${components_to_include}  ${EMPTY}
  Create Directory  ${SW_BUILDS_DIR_PATH}
  ${software_package_path_artifactory}=  Download Software Package From 5G Artifactory
  ...  ${SW_BUILDS_DIR_PATH}  ${software_active_package_name}  ${components_to_include[0]}
  Convert To String  ${software_package_path_artifactory}
  [Return]  ${software_package_path_artifactory}

Download Software Package From 5G Artifactory
  [Arguments]  ${sw_builds_dir_path}  ${software_active_package_name}  ${components_to_include}=${EMPTY}
  ${package_name}=  Split String From Right  ${software_active_package_name}  _  1
  ${software_path}=  Normalize path  ${sw_builds_dir_path}/AirScale-${package_name[1]}${components_to_include}.zip
  ${file_status}=  Run Keyword And Return Status  OperatingSystem.File Should Not Exist  ${software_path}
  Run Keyword If
  ...  ${file_status}
  ...  Run And Return Rc
  ...  wget -P ${sw_builds_dir_path} ${5G_artifactory}${package_name[1]}/AirScale-${package_name[1]}${components_to_include}.zip
  [Return]  ${software_path}

Create Software Package Name
  [Arguments]  ${active_sw}
  ${trunk_status}    Run Keyword And Return Status    Should Match Regexp    ${active_sw}    .*_999[0-9].*
  ${software_package_name}=    Run Keyword If    ${trunk_status}
  ...  Replace String Using Regexp     ${active_sw}    ^([A-Z]+)\\d+[A-Z]\\d?     SBTS00
  ${software_package_name}=  Set Variable If  ${trunk_status}  ${software_package_name}  ${active_sw}
  ${software_component}=  Set Variable If
  ...  "T1" in "${software_package_name}"  T1
  ...  "T2" in "${software_package_name}"  T2
  ...  MAIN
  ${software_package_name}=  Remove String  ${software_package_name}  ${software_component}
  [Return]  ${software_package_name}  ${software_component}

Create Software Package Name For 5G
  [Arguments]  ${active_sw}
  ${software_component}=  Set Variable If
  ...  "T1" in "${active_sw}"  T1
  ...  "T2" in "${active_sw}"  T2
  ...  ${EMPTY}
  ${active_sw}=  Remove String Using Regexp  ${active_sw}  T[1-2]  count=1
  ${branch}  ${gnb}  @{software_package_name}=  Split String  ${active_sw}  _
  ${first_part}=  Strip String  ${software_package_name[0]}  mode=left  characters=0
  ${first_part}=  Set Variable If  "${first_part}" == "${EMPTY}"  0  ${first_part}
  ${second_part}=  Strip String  ${software_package_name[1]}  mode=left  characters=0
  ${third_part}=  Strip String  ${software_package_name[2]}  mode=left  characters=0
  ${sw_package_name}=  Set Variable If
  ...  "${software_component}" == "T1"
  ...  ${branch}_${first_part}.${second_part}.${third_part}
  ...  "${software_component}" == "T1"
  ...  ${branch}_${first_part}.${second_part}.${third_part}
  ...  ${branch}_${first_part}.${second_part}.${third_part}
  [Return]  ${sw_package_name}  ${software_component}

Return Path To Matched File
  [Documentation]  Returns path to the first found file with name matching given pattern
  [Arguments]  ${file_dir_path}  ${pattern}
  ${out_file_list}=  OperatingSystem.List Files In Directory  ${file_dir_path}  ${pattern}
  ${out_file_path}=  OperatingSystem.Join Path  ${file_dir_path}  ${out_file_list[0]}
  [Return]  ${out_file_path}

Execute SW Upgrade On Every Node
  [Documentation]  KW is extended for Carrier Aggregation verification.
  Set Tags     AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynskia@nokia.com
  Common Test Setup
  Logging With Timestamp
  ...  message=Execute SW Upgrade On Every Node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  FOR  ${bts}  IN  @{cfg.active_bts_list}
    ${ca_status}=  Carrier Aggregation Precheck  ${bts}
    ${fan_info_before}=  admin.Get Cabinets Fan Info  connection=${bts}
    Perform SW Upgrade  ${bts}
    Verify BTS State  ${bts}  ${${CONFIGURATION_SWUPDATE_TIMEOUT}}
    Verify RU Product Code
    Verify SW Activation  ${bts}  ${test_logs_path}
    ${fan_info_after}=  admin.Get Cabinets Fan Info  connection=${bts}
    Check FAN Before And After Update  ${fan_info_before}  ${fan_info_after}
    Run Keyword If  ${ca_status}  Carrier Aggregation Postcheck  ${bts}
  END
  FOR  ${bts}  IN  @{cfg.active_bts_list}
    Verify Alarms  ${bts}
  END
  [Teardown]    Common Test Teardown



Execute SW Upgrade On Every Node Procedure
  [Arguments]      ${test_logs_path}
  FOR  ${bts}  IN  @{cfg.active_bts_list}
    Perform SW Upgrade  ${bts}
    Verify BTS State  ${bts}  ${CONFIGURATION_STARTUP_TIMEOUT}
    Verify SW Activation  ${bts}  ${test_logs_path}
  END


Carrier Aggregation Postcheck
  [Arguments]  ${node}
  Carrier Aggregation Multienb Connectivity Check  ${node}
  ${value}=  Carrier Aggregation Multienb Parameter Check  ${node}
  Run Keyword If  "${value}".lower()=="false"  Run Keywords
  ...  Log To Console  Parameter actInterEnbDLCAggr is set to false. Test Failed.
  ...  AND  Fail  Parameter actInterEnbDLCAggr is set to false. Test Failed.

Carrier Aggregation Precheck
  [Arguments]  ${node}
  ${value}=  Carrier Aggregation Multienb Parameter Check  ${node}
  Return From Keyword If  "${value}".lower()=="false"  ${FALSE}
  Carrier Aggregation Multienb Connectivity Check  ${node}
  [Return]  ${TRUE}

Carrier Aggregation Multienb Connectivity Check
  [Arguments]  ${node}
  ${ca_data_list}=  admin.Get Managed Objects  class_name=CA_DATA  connection=${node}
  Run Keyword If  "${ca_data_list}"=="@{EMPTY}"  Run Keywords
  ...  Log To Console  No CA_DATA connection found within Carrier Aggregation. Test Failed
  ...  AND  Fail  No CA_DATA connection found within Carrier Aggregation. Test Failed

Carrier Aggregation Multienb Parameter Check
  [Arguments]  ${node}
  ${param_value}=  Evaluate Xpath
  ...  ${CFG['NODES']['${node}']['scf_file_path']}
  ...  string(.//managedObject[contains(@class, ":LNBTS") and contains(@distName, "MRBTS-${node}/LNBTS-${node}")]/p[@name="actInterEnbDLCAggr"])
  ${ca_param}=  Set Variable If  "${param_value}"=="${EMPTY}"  false  ${param_value}
  [Return]  ${ca_param}

Execute SW Upgrade On Every Node With Rollback
  [Documentation]  KW is extended for Carrier Aggregation verification.
  Set Tags     AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynskia@nokia.com
  Common Test Setup
  Logging With Timestamp
  ...  message=Execute SW Upgrade On Every Node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  FOR  ${bts}  IN  @{cfg.active_bts_list}
    Perform SW Upgrade  ${bts}
    Verify BTS state  ${bts}  ${CONFIGURATION_SWUPDATE_TIMEOUT}
    Verify Alarms  alias=${bts}
    Verify RU Product Code
    ${bts_kpi_first_to_last}  ${verdict}=  Verify SW Activation  ${bts}  ${test_logs_path}
    Set Test Variable  ${DOWNGRADE_TIME}  ${bts_kpi_first_to_last}
    Set Test Variable  ${TC_RESULT}  ${verdict}
    Perform SW Rollback  ${bts}
    Verify BTS state  ${bts}  ${CONFIGURATION_SWUPDATE_TIMEOUT}
  END
  FOR  ${bts}  IN  @{cfg.active_bts_list}
    Verify Alarms  ${bts}
  END
  Refresh SW active state
  [Teardown]    Common Test Teardown

Rollback Software On Every Node
#  ${rollback_status}=  Get Variable Value  ${cfg.ROLLBACK}  False
#  Set Test Variable  ${rollback_status}  ${rollback_status}
  Return From Keyword If  '${rollback_status}'=='False'
  FOR  ${node}  IN  @{cfg.active_bts_list}
    Perform SW Rollback  ${node}
    Run Keyword And Ignore Error  CM.CM BTS Admin Not Available  ${node}  120
    Wait Until Keyword Succeeds  ${CONFIGURATION_STARTUP_TIMEOUT} sec  20 sec  admin.Reset Admin  connection=${node}
    Verify BTS state  ${node}  ${CONFIGURATION_SWUPDATE_TIMEOUT}
    Verify Alarms  alias=${node}
#  Verify SW Activation  ${BTS_state}  ${node}
  END

Perform SW Upgrade
  [Arguments]  ${bts_id}
  Log  ${\n}Check Software package availability and Download If Needed.  console=True
  ${software_package_path}=  Check Different Software Package Availability
  ...  ${cfg.NODES['${bts_id}']['software_active']}
  ...  ${bts_id}
  log  ${\n}Wait for software update accept. Please wait...  console=True
  Run Keyword And Ignore Error  admin.Wait Sw Update Possible
  ...  bts_ready=True
  ...  readiness_timeout=780
  ...  timeout=800
  ...  connection=${bts_id}
  log  ${\n}Software update to package: ${software_package_path} is being made. Please wait...  console=True
  admin.Update Software  sw_package=${software_package_path}  should_activate=True  timeout=8000  alias=${bts_id}
  log  ${\n}Software update to package: ${software_package_path} finished. Please wait for Node Reset  console=True
  ${reset_state}=  Run Keyword And Ignore Error  BTS Is Resetting  ${bts_id}  timeout=240 sec
  Run Keyword If  ${reset_state}  log  ${\n}Node Reset in Progress. Please wait ...  console=True
  Run Keyword And Ignore Error  Remove File  ${software_package_path}
  Run Keyword And Ignore Error  CM.CM BTS Admin Not Available  ${bts_id}  120
#  Logging Node Admin Restart  ${test_logs_path}  ${bts_id}  ${CONFIGURATION_STARTUP_TIMEOUT}

Perform SW Rollback
  [Arguments]  ${bts_id}
#  Gather SW Info  ${bts_id}
  log  ${\n}Software rollback is being made. Please wait...  console=True
  Run Keyword And Continue On Failure  admin.Rollback Software
  ...  timeout=300
  ...  detailed_output=False
  ...  connection=${bts_id}
  log  ${\n}Software rollback finished. Please wait for Node Reset  console=True
  ${reset_state}=  Run Keyword And Continue On Failure  BTS Is Resetting  ${bts_id}  timeout=240 sec


Perform SW Upgrade For Specific Package
  [Arguments]  ${bts_id}  ${software_package_path}
  log  ${\n}Wait for software update accept. Please wait...  console=True
  Run Keyword And Ignore Error  admin.Wait Sw Update Possible
  ...  bts_ready=True
  ...  readiness_timeout=2000
  ...  timeout=2500
  ...  connection=${bts_id}
  log  ${\n}Software update to package: ${software_package_path} is being made. Please wait...  console=True
  admin.Update Software  sw_package=${software_package_path}  should_activate=True  timeout=8000  alias=${bts_id}
  log  ${\n}Software update to package: ${software_package_path} finished. Please wait for Node Reset  console=True
  ${reset_state}=  Run Keyword And Continue On Failure  BTS Is Resetting  ${bts_id}  timeout=240 sec
  Run Keyword If  ${reset_state}  log  ${\n}Node Reset in Progress. Please wait ...  console=True
  Run Keyword And Ignore Error  Remove File  ${software_package_path}
  Wait Until Keyword Succeeds  ${CONFIGURATION_STARTUP_TIMEOUT}  20 sec  admin.Reset Admin  connection=${node_id}

Verify SW Activation
  [Arguments]  ${node}  ${test_logs_path}=${cfg.test_logs_path}
  kpi.clear_results
  admin.collect_infomodel_log_from_current_session
  ...  target_file_name=${test_logs_path}/infomodel_${node}.ims2
  ...  timeout=120
  ...  connection=${node}
  ...  leave_disconnect_logs=True
  Run Keyword And Return Status
  ...  operatingsystem.wait until created
  ...  path=${test_logs_path}/infomodel_${node}.ims2
  ...  timeout=120 seconds
#  sleep  60 seconds
  ${tmp_list}=  Create List
  ...  ${test_logs_path}/infomodel_${node}.ims2
  Run Keyword And Ignore Error  kpi.calculate_kpi4  ${tmp_list}
  Run Keyword And Ignore Error  kpi.calculate_kpi2a  ${tmp_list}
  Run Keyword And Ignore Error  kpi.calculate_kpi2b  ${tmp_list}
  Run Keyword And Ignore Error  kpi.calculate_kpi2c  ${tmp_list}
  Run Keyword And Ignore Error  kpi.calculate_kpi2d  ${tmp_list}
  ${kpi4}=  Run Keyword And Ignore Error  kpi.get_all_deltas  kpi_name=kpi4
  ${kpi2a}=  Run Keyword And Ignore Error  kpi.get_all_deltas  kpi_name=kpi2a
  ${kpi2b}=  Run Keyword And Ignore Error  kpi.get_all_deltas  kpi_name=kpi2b
  ${kpi2c}=  Run Keyword And Ignore Error  kpi.get_all_deltas  kpi_name=kpi2c
  ${kpi2d}=  Run Keyword And Ignore Error  kpi.get_all_deltas  kpi_name=kpi2d
  [Return]  ${kpi2a}[1][0]

Verify UUF SW Activation
  [Arguments]  ${node}  ${test_logs_path}=${cfg.test_logs_path}
  kpi.clear_results
  sleep  40 sec
  admin.collect_infomodel_log_from_current_session
  ...  target_file_name=${test_logs_path}/infomodel_${node}.ims2
  ...  timeout=120
  ...  connection=${node}
  ...  leave_disconnect_logs=True
  ${tmp_list}=  Create List
  ...  ${test_logs_path}/infomodel_${node}.ims2
  Run Keyword And Ignore Error  kpi.calculate_kpi4  ${tmp_list}
  Run Keyword And Ignore Error  kpi.calculate_kpi2a  ${tmp_list}
  Run Keyword And Ignore Error  kpi.calculate_kpi2b  ${tmp_list}
  Run Keyword And Ignore Error  kpi.calculate_kpi2c  ${tmp_list}
  Run Keyword And Ignore Error  kpi.calculate_kpi2d  ${tmp_list}
  ${kpi4}=  Run Keyword And Ignore Error  kpi.get_all_deltas  kpi_name=kpi4
  ${kpi2a}=  Run Keyword And Ignore Error  kpi.get_all_deltas  kpi_name=kpi2a
  ${kpi2b}=  Run Keyword And Ignore Error  kpi.get_all_deltas  kpi_name=kpi2b
  ${kpi2c}=  Run Keyword And Ignore Error  kpi.get_all_deltas  kpi_name=kpi2c
  ${kpi2d}=  Run Keyword And Ignore Error  kpi.get_all_deltas  kpi_name=kpi2d
  [Return]  ${kpi2a}[1][0]  ${verdict}

Check FAN Before And After Update
  [Arguments]  ${fan_info_before}  ${fan_info_after}
  ${fan_value_after}=  Get Dictionary Values  ${fan_info_after}
  FOR  ${value}  IN  @{fan_value_after}
    ${fan_value}=  Get Dictionary Values  ${value}
    ${disabled_status_after}=  Check Disabled State In FANs  ${fan_value}
  END
  ${fan_value_before}=  Get Dictionary Values  ${fan_info_before}
  FOR  ${value}  IN  @{fan_value_before}
    ${fan_value}=  Get Dictionary Values  ${value}
    ${disabled_status_before}=  Check Disabled State In FANs  ${fan_value}
  END
  Run Keyword If  ${disabled_status_before} and ${disabled_status_after}
  ...  Log  FAN Operational State before and after SW_update has disabled value.  level=WARN
  ...  ELSE IF  ${disabled_status_before} and ${disabled_status_after}==${FALSE}
  ...  Log  FAN Operational State before SW_update has disabled value.  level=WARN
  ...  ELSE IF  ${disabled_status_before}==${FALSE} and ${disabled_status_after}
  ...  Run Keyword And Continue On Failure
  ...  Fail  FAN Operational State after SW_update has disabled value.

Check Disabled State In FANs
  [Arguments]  ${fan_value}
  ${fan_status}=  Set Variable  ${FALSE}
  FOR  ${value}  IN  @{fan_value}
    Continue For Loop If  '${value['operationalState']}'!='disabled'
    ${fan_status}=  Set Variable  ${TRUE}
  END
  [Return]  ${fan_status}

Check Release Edition Relation
  [Arguments]  ${active_release}  ${feature_activation_release}
  ${active_release}=  Remove String  ${active_release}  SBTS  R
  ${feature_activation_release}=  Remove String  ${feature_activation_release}  SBTS  R
  ${active_release}=  Convert To Integer  ${active_release}
  ${feature_activation_release}=  Convert To Integer  ${feature_activation_release}
  ${release_version_status}=  Evaluate  ${active_release}>=${feature_activation_release}
  [Return]  ${release_version_status}
