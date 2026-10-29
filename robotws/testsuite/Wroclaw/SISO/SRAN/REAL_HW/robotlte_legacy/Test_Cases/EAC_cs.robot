*** Settings ***
Documentation
...  Author:
...  Maintainer:  piotr.korczynski@nokia.com

Library  Collections
Library  OperatingSystem
Library  Process
Library  robot.libraries.DateTime
Library  SSHLibrary
Library  String


*** Variables ***
${FAULT_EAC_SCHEME}=  {'alarmDetail': 'descr', 'faultId': '1400\\D*', 'alarmSeverity': '(?:Minor|Major|Critical|a1|a2|a3)', 'distName': ''}
*** Keywords ***
Automated_SiSo_Fault_Management_RF_EAC_check
  [Documentation]
  ...  Purpose of this test is checking if RET unit is correctly detected
  ...
  ...  Parameters:
  ...  Name  |  Mandatory  |  Default value  |  Description
  ...  test_logs_path  |  no  |  cfg.test_logs_path  |  Path to test logs
  ...
  Common Test Setup
  EAC Cancel Alarms For All FRs All BTS
  Logging With Timestamp
  ...  message=Execute Recommissioning On Every Node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  Fault_Management_RF_EAC_check
  [Teardown]  Run Keywords
  ...  EAC Cancel Alarms For All FRs All BTS
  ...  AND  Common Test Teardown

EAC Cancel Alarms For All FRs All BTS
  FOR  ${bts_id}  IN  @{cfg.active_bts_list}
    EAC Cancel Alarms For All FRs
    ...  fr_serial_number_list=${CUSTOM_RADIO_UNIT_LIST}
    ...  scfc_with_eac_alarms=${CFG['NODES']['${BTS_ID}']['scf_file_path']}
  END

Fault_Management_RF_EAC_check
#  [Arguments]  ${fr_serial_number}=${FR_UNDER_TEST_SERIAL_NUMBER}  ${scfc_file_path}=${SCFC_REFERENCE_FILE_PATH}  ${alias}=${TC_ALIAS}
  ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${CUSTOM_RADIO_UNIT_LIST}[0]
  Set Test Variable  ${BTS_ID}  ${ru_bts_id}
  Set Test Variable  ${FR_UNDER_TEST_SERIAL_NUMBER}  ${CUSTOM_RADIO_UNIT_LIST}[0]
  Set Test Variable  ${ACT_CATEGORY_ALARMS}  ${CFG['NODES']['${ru_bts_id}']['scf_alarms_category']}
  Verify Unexpected And Historical Alarms
  ...  alias=${ru_bts_id}
  ${scfc_file_path}=  Set Variable  ${CFG['NODES']['${ru_bts_id}']['scf_file_path']}
  ${eac_alarm_list}=  Create EAC Alarm List For Tested FR  ${CUSTOM_RADIO_UNIT_LIST}[0]  ${scfc_file_path}
  ${eac_alarms_commissionig_check}=  Get Length  ${eac_alarm_list}
  Run Keyword If
  ...  ${eac_alarms_commissionig_check} == 0
  ...  Fail
  ...  !!! There are no EAC alarms commissioned. Please set up test environment propertlly. !!!
  ${eac_ip_addr}  ${eac_port}=  Get EAC Parameters For Specified FR  ${CUSTOM_RADIO_UNIT_LIST}[0]
  Info Model Check EAC Alarms Commissioning  ${CUSTOM_RADIO_UNIT_LIST}[0]  ${scfc_file_path}  alias=${ru_bts_id}
  FOR  ${alarm}  IN  @{eac_alarm_list}
    Info Model Check EAC Line State Without Active Alarm
  ...  ${CUSTOM_RADIO_UNIT_LIST}[0]
  ...  ${alarm}
  ...  ${scfc_file_path}
  ...  alias=${ru_bts_id}
    ${fault_id}  ${eac_alarm_startDelay}  ${eac_alarm_cancelDelay}=
  ...  Generate EAC Alarm  ${alarm}
  ...  ${eac_ip_addr}
  ...  ${eac_port}
  ...  ${scfc_file_path}
    EAC Alarm Should Be Generated  ${alarm}
  ...  ${fault_id}
  ...  ${eac_alarm_startDelay}
  ...  ${scfc_file_path}
  ...  alias=${ru_bts_id}
    Clear EAC alarm  ${alarm}
  ...  ${eac_ip_addr}
  ...  ${eac_port}
  ...  ${scfc_file_path}
    EAC Alarm Should Be Cleared  ${eac_alarm_cancelDelay}
  ...  ${fault_id}
  ...  alias=${ru_bts_id}
  END


EAC Alarm Should Be Generated
  [Arguments]
  ...  ${alarm}
  ...  ${fault_id}
  ...  ${eac_alarm_startDelay}
  ...  ${scfc_eac}
  ...  ${fr_under_test_serial_number}=${FR_UNDER_TEST_SERIAL_NUMBER}
  ...  ${alias}=default
  ${show_timeout}=  Evaluate  ${eac_alarm_startDelay}+10
  Run Keyword And Continue On Failure
  ...  Info Model check EAC line state with active alarm
  ...  ${fr_under_test_serial_number}
  ...  ${alarm}
  ...  ${scfc_eac}
  ...  alias=${alias}
  Run Keyword And Continue On Failure
  ...  Info Model Wait For Alarm
  ...  fault_id=${fault_id}
  ...  fault_count=1
  ...  timeout=${show_timeout}
  ...  act_category_alarms=${ACT_CATEGORY_ALARMS}
  ...  alias=${alias}
  ${infomodel_mandatory_alarm}  ${btssm_mandatory_alarm}=  Create Mandatory EAC Alarm  ${alarm}
  ...  ${scfc_eac}  ${FAULT_EAC_SCHEME}  alias=${alias}
  Verify All Cells OnAir
  ...  node=${BTS_ID}
  ...  timeout=20 sec


EAC Alarm Should Be Cleared
  [Arguments]  ${eac_alarm_cancelDelay}  ${fault_id}  ${alias}=default
  ${clear_timeout}=  Evaluate  ${eac_alarm_cancelDelay}+10
  admin.Assert Alarm Inactive  faultId=${fault_id}  timeout=${clear_timeout}  alias=${alias}


Create Mandatory EAC Alarm
  [Arguments]  ${eac_alarm}  ${scfc_with_eac_alarms}  ${fault_scheme}  ${alias}=default
  ${eac_alarm_distname}=  Info Model check EAC alarm parameters  ${eac_alarm}  ${scfc_with_eac_alarms}  alias=${alias}
  ${port_id}  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="portId"]
  ${eac_faultid}=  Evaluate  1399+${port_id}
  ${eac_faultid}=  Convert to String  ${eac_faultid}
  ${eac_alarm_detail}=  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="descr"]
  ${eac_alarm_severity}=  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="severity"]
  @{infomodel_mandatory_alarm}=  create list
  ${infomodel_fault_scheme}=  evaluate  ${fault_scheme}
  set to dictionary  ${infomodel_fault_scheme}  alarmDetail  ${eac_alarm_detail}  faultId  ${eac_faultid}
  ...  alarmSeverity  ${eac_alarm_severity}  # distName  ${eac_alarm_distname}
  append to list  ${infomodel_mandatory_alarm}  ${infomodel_fault_scheme}
  #sm section
  ${eac_sm_alarm_severity}=  Set Variable If  '${eac_alarm_severity}'=='Minor'  a1  BUG
  ${eac_sm_alarm_severity}=  Set Variable If  '${eac_alarm_severity}'=='Major'  a2  ${eac_sm_alarm_severity}
  ${eac_sm_alarm_severity}=  Set Variable If  '${eac_alarm_severity}'=='Critical'  a3  ${eac_sm_alarm_severity}
  @{sm_mandatory_alarm}=  create list
  ${sm_fault_scheme}=  evaluate  ${fault_scheme}
  set to dictionary  ${sm_fault_scheme}  alarmDetail  ${eac_alarm_detail}  faultId  ${eac_faultid}\\D*
  ...  alarmSeverity  ${eac_sm_alarm_severity}  distName  ${eac_alarm_distname}
  append to list  ${sm_mandatory_alarm}  ${sm_fault_scheme}
  [Return]  ${infomodel_mandatory_alarm}  ${sm_mandatory_alarm}

Info Model Wait For EAC Alarm to be cleared
  [Arguments]  ${eac_alarm_distname}  ${eac_alarm_cancelDelay}  ${alias}=default
  Wait For Infomodel Event  remove ${eac_alarm_distname}  timeout=${eac_alarm_cancelDelay}  alias=${alias}

Create EAC alarm list for tested FR
  [Arguments]  ${fr_serial_number}  ${scfc_with_eac_alarms}
  ${configdn_fr_tested}=  Get Element Text
  ...  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqmr:RMOD_R'][p[@name='serialNumber']='${fr_serial_number}']/p[@name="configDN"]
  ${object_1}=  Set Variable  //managedObject[@class='com.nokia.srbts.eqm:EAC_IN'
  ${object_2}=  Set Variable  and contains (@distName, '${configdn_fr_tested}/EAC_IN-')][p[@name='inUse']='true']/@distName
  ${sum_object}=  Set Variable  ${object_1}${object_2}
  ${eac_alarm_list}=  Get Elements
  ...  ${scfc_with_eac_alarms}
  ...  xpath=${sum_object}
  [Return]  ${eac_alarm_list}

Get EAC parameters for specified FR
  [Arguments]  ${fr_serial_number}
  ${eac_ip_addr_for_tested_fr}=  set variable  ${RU_DICT['${fr_serial_number}']['eac']['ip_addr']}
  ${eac_port_for_tested_fr}=  set variable  ${RU_DICT['${fr_serial_number}']['eac']['port']}
  [Return]  ${eac_ip_addr_for_tested_fr}  ${eac_port_for_tested_fr}

EAC tool setup on startup for specified FR
  [Arguments]  ${fr_serial_number}  ${scfc_with_eac_alarms}
  ${eac_alarm_list}=  Create EAC alarm list for tested FR  ${fr_serial_number}  ${scfc_with_eac_alarms}
  ${no_alarms_commissioned}=  Run Keyword And Return Status  Should Be Empty  ${eac_alarm_list}
  Run Keyword If  '${no_alarms_commissioned}'=='True'  Return From Keyword
  ${eac_ip_addr}  ${eac_port}=  Get EAC parameters for specified FR  ${fr_serial_number}
  Setup EAC Tester  ${eac_ip_addr}
  FOR  ${index}  IN  @{eac_alarm_list}
    ${port_id}  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${index}']/p[@name="portId"]
    ${alarm_polarity}  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${index}']/p[@name="polarity"]
    ${port_state}=  Set Variable If  '${alarm_polarity}'=='Normally_closed'  C  O
    EAC change port state  ${eac_port}${port_id}  ${port_state}
  END
  Teardown EAC Tester

EAC Cancel Alarms For All FRs
  [Arguments]  ${fr_serial_number_list}=${COMMISSIONED_FR_LIST}  ${scfc_with_eac_alarms}=${SCFC_REFERENCE_FILE_PATH}
  FOR  ${fr}  IN  @{fr_serial_number_list}
    Power On FR EAC And Wait For Availability  ${fr}
    ${status}=  Run Keyword And Return Status
  ...  EAC tool setup on startup for specified FR
  ...  ${fr}
  ...  ${scfc_with_eac_alarms}
  Run Keyword If  '${status}'=='False'  Log  EAC for radio module ${fr} could not be setup  ERROR
  END

Generate EAC alarm
  [Arguments]
  ...  ${eac_alarm}
  ...  ${eac_ip_addr_for_tested_alarm}
  ...  ${eac_port_for_tested_alarm}
  ...  ${scfc_with_eac_alarms}
  Setup EAC Tester  ${eac_ip_addr_for_tested_alarm}
  ${port_id}  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="portId"]
  ${alarm_polarity}  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="polarity"]
  ${port_state}=  Set Variable If  '${alarm_polarity}'=='Normally_closed'  O  C
  EAC change port state  ${eac_port_for_tested_alarm}${port_id}  ${port_state}
  Teardown EAC Tester
  ${eac_faultid}=  Evaluate  1399+${port_id}
  ${eac_alarm_startDelay}=  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="startDelay"]
  ${eac_alarm_cancelDelay}=  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="cancelDelay"]
  [Return]  ${eac_faultid}  ${eac_alarm_startDelay}  ${eac_alarm_cancelDelay}

Clear EAC alarm
  [Arguments]  ${eac_alarm}  ${eac_ip_addr_for_tested_alarm}  ${eac_port_for_tested_alarm}  ${scfc_with_eac_alarms}
  Setup EAC Tester  ${eac_ip_addr_for_tested_alarm}
  ${port_id}  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="portId"]
  ${alarm_polarity}  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="polarity"]
  ${port_state}=  Set Variable If  '${alarm_polarity}'=='Normally_closed'  C  O
  EAC change port state  ${eac_port_for_tested_alarm}${port_id}  ${port_state}
  Teardown EAC Tester

Info Model check EAC alarm parameters
  [Arguments]  ${eac_alarm}  ${scfc_with_eac_alarms}  ${alias}=default
  ${port_id}  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="portId"]
  ${eac_faultid}=  Evaluate  1399+${port_id}
  ${eac_alarm_number_btssm}=  Evaluate  7400+${port_id}
  ${eac_alarm_number}=  Set Variable If  ${ACT_CATEGORY_ALARMS}  7103  ${eac_alarm_number_btssm}
  ${eac_alarm_detail}=  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="descr"]
  ${eac_alarm_severity}=  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="severity"]
  ${eac_alarm_startDelay}=  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="startDelay"]
  ${eac_alarm_cancelDelay}=  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="cancelDelay"]
  ${first_query_part1}=  Set Variable  alarmActivity=Set, faultId=${eac_faultid}, alarmNumber=${eac_alarm_number},
  ${first_query_part2}=  Set Variable  alarmSeverity=${eac_alarm_severity}, alarmText.alarmDetail=${eac_alarm_detail}
  ${second_query_part1}=  Set Variable  alarmInformation.alarmActivity=Set, alarmInformation.faultId=${eac_faultid},
  ${second_query_part2}=  Set Variable  alarmInformation.alarmNumber=${eac_alarm_number}, alarmInformation.alarmSeverity=${eac_alarm_severity},
  ${second_query_part3}=  Set Variable  alarmInformation.alarmText.alarmDetail=${eac_alarm_detail}
  ${alarm_query}=  Set Variable If
  ...  ${ACT_CATEGORY_ALARMS}
  ...  ${first_query_part1} ${first_query_part2}
  ...  ${second_query_part1} ${second_query_part2} ${second_query_part3}
  ${alarm_info}=  Info Model Get Alarm  alias=${alias}  query=${alarm_query}
  ${alarm_info}=  Set Variable  ${alarm_info[0]}
  ${eac_alarm_distname}=  Set Variable  ${alarm_info.dist_name}
  admin.Add Allowed Alarm  parameters=faultId=${eac_faultid}, severity=${eac_alarm_severity}  connection=${alias}
  [Return]  ${eac_alarm_distname}

Info Model Get Alarm
  [Arguments]  ${alias}=default  ${bts_l_id}=*  ${query}=*
  [Documentation]  Returns list of active alarms that match the query.
  ...  Call example: ${alarm}=  Info Model Get Alarm  ${query}=alarmActivity=Set, faultId=10
  ${query}=  Set Variable If  '${query}'=='*'  ${EMPTY}  is [${query}]
  @{available_alarms}=  Run Keyword If  ${ACT_CATEGORY_ALARMS}
  ...  admin_im.Query Infomodel  query=get list //FRI-${bts_l_id}/ALARM-* ${query}  alias=${alias}
  ...  ELSE
  ...  admin_im.Query Infomodel  query=get list //LTS-${bts_l_id}//ALARM_L-* ${query}  alias=${alias}
  [Return]  ${available_alarms}

Info Model check EAC line state without active alarm
  [Arguments]  ${fr_serial_number}  ${eac_alarm}  ${scfc_with_eac_alarms}  ${timeout}=10  ${alias}=default
  ${rmod_dist_name}=  Info Model Get Rmod DistName For FR Serial Number  ${fr_serial_number}  alias=${alias}
  ${port_id}  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="portId"]
  ${matched_eac_line}=  admin_im.Query Infomodel
  ...  query=get object ${rmod_dist_name}/EAC_L-* is [physicalNodeId=${port_id}, direction=INPUT]
  ...  alias=${alias}
  ${checked_eac_line}=  Set Variable  ${matched_eac_line.dist_name}
  ${checked_eac_line_values}=  Get Infomodel Object  ${checked_eac_line}  alias=${alias}
  ${eac_line_logicalMapping}=  Set Variable  ${checked_eac_line_values.logicalMapping}
  ${eac_line_expexted_state}=  Set Variable If  '${eac_line_logicalMapping}'=='ONE_IS_LOW'  HIGH  BUG
  ${eac_line_expexted_state}=  Set Variable If
  ...  '${eac_line_logicalMapping}'=='ONE_IS_HIGH'
  ...  LOW
  ...  ${eac_line_expexted_state}
  admin_im.Query Infomodel
  ...  query=${checked_eac_line} is [lineState=${eac_line_expexted_state}]
  ...  timeout=${timeout}
  ...  alias=${alias}

Info Model check EAC line state with active alarm
  [Arguments]  ${fr_serial_number}  ${eac_alarm}  ${scfc_with_eac_alarms}  ${timeout}=10  ${alias}=default
  ${rmod_dist_name}=  Info Model Get Rmod DistName For FR Serial Number  ${fr_serial_number}  alias=${alias}
  ${port_id}  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="portId"]
  ${matched_eac_line}=  query infomodel
  ...  query=get object ${rmod_dist_name}/EAC_L-* is [physicalNodeId=${port_id}, direction=INPUT]
  ...  alias=${alias}
  ${checked_eac_line}=  Set Variable  ${matched_eac_line.dist_name}
  ${checked_eac_line_values}=  Get Infomodel Object  ${checked_eac_line}  alias=${alias}
  ${eac_line_logicalMapping}=  Set Variable  ${checked_eac_line_values.logicalMapping}
  ${eac_line_expexted_state}=  Set Variable If  '${eac_line_logicalMapping}'=='ONE_IS_LOW'  LOW  BUG
  ${eac_line_expexted_state}=  Set Variable If
  ...  '${eac_line_logicalMapping}'=='ONE_IS_HIGH'
  ...  HIGH
  ...  ${eac_line_expexted_state}
  admin_im.Query Infomodel
  ...  query=${checked_eac_line} is [lineState=${eac_line_expexted_state}]
  ...  timeout=${timeout}
  ...  alias=${alias}

Info Model check EAC alarms commissioning
  [Arguments]  ${fr_serial_number}  ${scfc_with_eac_alarms}  ${timeout}=10  ${alias}=default
  ${eac_alarm_list}=  Create EAC alarm list for tested FR  ${fr_serial_number}  ${scfc_with_eac_alarms}
  ${rmod_dist_name}=  Info Model Get Rmod Attribute Value For FR Serial Number
  ...  ${fr_serial_number}
  ...  dist_name
  ...  alias=${alias}
  FOR  ${eac_alarm}  IN  @{eac_alarm_list}
    ${port_id}  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="portId"]
    ${eac_alarm_detail}=  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="descr"]
    ${eac_alarm_severity}=  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="severity"]
    ${eac_alarm_startDelay}=  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="startDelay"]
    ${eac_alarm_cancelDelay}=  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="cancelDelay"]
    ${alarm_polarity}  Get Element Text  ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="polarity"]
    ${check_polarity}=  Set Variable If  '${alarm_polarity}'=='Normally_closed'  ONE_IS_HIGH  BUG
    ${check_polarity}=  Set Variable If  '${alarm_polarity}'=='Normally_open'  ONE_IS_LOW  ${check_polarity}
    ${object_1}=  Set Variable
    ...  ${rmod_dist_name}/EAC_L-* is [logicalMapping=${check_polarity}, severity=${eac_alarm_severity}, description=${eac_alarm_detail},
    ${object_2}=  Set Variable  startDelay=${eac_alarm_startDelay}, cancelDelay=${eac_alarm_cancelDelay}, physicalNodeId=${port_id}]
    ${sum_object}=  Set Variable  ${object_1} ${object_2}
    admin_im.Query Infomodel
  ...  query=${sum_object}
  ...  timeout=${timeout}
  ...  alias=${alias}
  END

Unexpected Alarms Should Not Be Avaialble
  [Arguments]  ${allowed}=${EMPTY}  ${mandatory}=${EMPTY}
  Run Keyword And Continue On Failure  Info Model Alarms Get And Check  ${allowed}  ${mandatory}
  Run Keyword If  ${ACT_CATEGORY_ALARMS}
  ...  Run Keyword And Continue On Failure  Admin Alarms Get And Check  ${allowed}  ${mandatory}

Power On FR EAC And Wait For Availability
  [Arguments]  ${fr_serial_number}
  #  pdu.Setup Pdu
  #  ...  model=${RU_DICT['${fr_serial_number}']['eac']['pdu']['type']}
  #  ...  host=${RU_DICT['${fr_serial_number}']['eac']['pdu']['ip_addr']}
  #  ...  alias=pdu
  #  pdu.Power On
  #  ...  port=${RU_DICT['${fr_serial_number}']['eac']['pdu']['port']}
  #  ...  pdu_device=pdu
  #  pdu.Teardown Pdu  pdu_device=pdu
  SSHLibrary.Open Connection  ${RU_DICT['${fr_serial_number}']['eac']['ip_addr']}  timeout=300
  Wait Until Keyword Succeeds  180  10  SSHLibrary.Login  pi  pi
  SSHLibrary.Close Connection

#################EAC TESTER SECTION ########################
Setup EAC Tester
  [Arguments]  ${eac_tester_ip}
  Open Connection  ${eac_tester_ip}
  Login  pi  pi

Teardown EAC Tester
  SSHLibrary.Close Connection

EAC change port state
  [Arguments]  ${eac_port_number}  ${eac_port_state}
  Start Command  eac ${eac_port_number} ${eac_port_state}

EAC open port
  [Arguments]  ${eac_tester_ip}  ${eac_port_number}
  Setup EAC Tester  ${eac_tester_ip}
  Start Command  eac ${eac_port_number} O
  Teardown EAC Tester

EAC close port
  [Arguments]  ${eac_tester_ip}  ${eac_port_number}
  Setup EAC Tester  ${eac_tester_ip}
  Start Command  eac ${eac_port_number} C
  Teardown EAC Tester

EAC Set Startup Setup
  [Arguments]  ${eac_tester_ip}
  Setup EAC Tester  ${eac_tester_ip}
  Start Command  eac_start
  Teardown EAC Tester

EAC Open EAC Tester Group Based On Serial Number
  [Arguments]  ${fr_serial_number}
  Setup EAC Tester  ${RU_DICT['${fr_serial_number}']['eac']['ip_addr']}
  Start Command  eac ${RU_DICT['${fr_serial_number}']['eac']['port']} O
  Teardown EAC Tester

EAC Open EAC Tester Group Based On Serial Number List
  [Arguments]  ${fr_serial_number_list}
  FOR  ${fr_serial_number}  IN  @{fr_serial_number_list}
    EAC Open EAC Tester Group Based On Serial Number  ${fr_serial_number}
  END