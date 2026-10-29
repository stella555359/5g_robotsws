*** Settings ***
Documentation
...    Author:   tomasz.zadworny@nokia.com
...    Maintainer:    Author

Library  Collections
Library  Process
Library  String
Library  XML  use_lxml=true
Library  OperatingSystem

Library  ute_syslog
Library  taf.config.scf  WITH NAME  scf


*** Keywords ***
RFAlarms Setup
  [Documentation]    Short description.
  ...
  ...  Args:
  ...    ${test_logs_path}: <description>
  [Arguments]  ${test_logs_path}
  Setup variables  alias=${cfg.primary_node_bts_id}
  Log variables
  [Teardown]  Run Keyword If  '${KEYWORD STATUS}' != 'PASS'  FAIL

RFAlarms Teardown
  [Documentation]    Short description.
  ...
  ...  Args:
  ...    ${test_logs_path}: <description>
  [Arguments]  ${test_logs_path}
  Log To Console  RFAlarms Teardown

Setup Variables
  [Documentation]    Short description.
  ...
  ...  Args:
  ...    ${alias}: <description>
  [Arguments]  ${alias}=default
  ${out_matched_rmod}=  Query infomodel  query=get list //EQM_L-1/RMOD_L-* is [serialNumber=${FR_UNDER_TEST_SERIAL_NUMBER}]  alias=${alias}
  ${out_name_fr_under_test}=  Convert to string  ${out_matched_rmod[0]['productName']}
  Set suite variable  ${OUT_NAME_FR_UNDER_TEST}  ${out_name_fr_under_test}
  ${out_ip_fr_under_test}=  Info model get ip for fr serial number  ${FR_UNDER_TEST_SERIAL_NUMBER}  alias=${alias}
  Set suite variable  ${OUT_IP_FR_UNDER_TEST}  ${out_ip_fr_under_test}
  ${is_airscale}=  Query infomodel
  ...  query=/MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*/EQM_R-*/APEQM_R-1/CABINET_R-1/SMOD_R-1 is [productName=regex"ASI[ABLKM].*"]
  ...  alias=${alias}
  ...  allow_negative_result=True
  ...  timeout=3
  Set suite variable  ${IS_AIRSCALE}  ${is_airscale}
  ${is_left}=  Query infomodel
  ...  query=/MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1 is [horizontalPosition=1]
  ...  alias=${alias}
  ...  allow_negative_result=True
  ...  timeout=3
  ${side}=  Set variable if  ${is_left}  1  2
  Set suite variable  ${LXC_COMMAND}  lxc-attach -n 0x${side}018
  ${subrack_side_number}=  Set variable if  ${side}==1  1  4
  Set suite variable  ${OUT_SUBRACK_SIDE_NUMBER}  ${subrack_side_number}

Generate fault on RF with command SendFault
  [Arguments]  ${sendfault command}  ${rf_serial_number}  ${fault_number}  ${time_to_wait_for_fault}=0s  ${syslog}=False  ${alias}=default
  [Documentation]    Keyword logs to RF module with given serial number using telnet and use given sendfault command, then wait given amount of sec.
  radio.Open Connection To Radio Module  ru_serial_number=${rf_serial_number}
  Log To Console  Sending command 'sendFault ${sendfault command}' to RM ${rf_serial_number}
  radio.Send Command  command=sendFault ${sendfault command}
  IF  '${time_to_wait_for_fault}'!='0s'
    Log To Console  Waiting ${time_to_wait_for_fault} for alarm ${fault_number} to appear on RM ${rf_serial_number}
  END
  IF  '${time_to_wait_for_fault}'!='0s' and not ${syslog}
    Assert Alarm Active  faultId=${fault_number}  timeout=${time_to_wait_for_fault}  alias=${alias}
  ELSE IF  '${time_to_wait_for_fault}'!='0s'
    SysLog Fault Check  ${rf_serial_number}  ${fault_number}  alarm_state=active  timeout=${time_to_wait_for_fault}  alias=${alias}
  END
  [Teardown]  radio.Close SSH Connection

Cancel fault on RF with command SendFault
  [Arguments]  ${sendfault command}  ${rf_serial_number}  ${alias}=default
  [Documentation]    Keyword logs to RF module with given serial number using telnet and use given sendfault command.
  radio.Open Connection To Radio Module  ru_serial_number=${rf_serial_number}
  Log To Console  Sending command 'sendFault ${sendfault command}' to RM ${rf_serial_number}
  radio.Send Command  command=sendFault ${sendfault command}
  ${cmd_output}=  radio.Read Output  5
  Log To Console  Response is:\n${cmd_output}
  ${alias}=  Set Variable  ${alias}
  [Teardown]  radio.Close SSH Connection

Generate fault on RF via ARD0546 Message  # TODO: Not fixed yet
  [Arguments]  ${ard_command}  ${rf_serial_number}  ${fault_number}  ${fault_count}=1  ${time_to_wait_for_fault}=0s
  [Documentation]    Keyword logs to RF module with given serial number using telnet and use given sendfault command, then wait given amount of sec.
  ${rm_model}  ${rm_ip}  ${smod_model}  ${smod_ip}=  radio.Open Connection To Radio Module  ru_serial_number=${rf_serial_number}
  SSHLibrary.Open Connection  host=192.168.255.1  timeout=30
  SSHLibrary.Login  username=toor4nsn  password=oZPS0POrRieRtu
  IF  ${IS_AIRSCALE}
    SSHLibrary.Write  ${LXC_COMMAND}
    Sleep  4s
  END
  SSHLibrary.Write  telnet ${rm_ip} 1307
  Sleep  2s
  SSHLibrary.Write  [
  SSHLibrary.Write  MESSAGE: TYPE=SET
  SSHLibrary.Write  TRANSACTION: ID=50
  SSHLibrary.Write  ${ard_command}
  SSHLibrary.Write  ]
  Run Keyword And Continue On Failure  Assert Alarm Active  faultId=${fault_number}  timeout=${time_to_wait_for_fault}  alias=${alias}
  ${fault_count}=  Set Variable  ${fault_count}
  [Teardown]  Run Keywords  SSHLibrary.Close Connection  AND  radio.Close SSH Connection

Info Model Check Current FR State And Compare
  [Documentation]    Short description.
  ...
  ...  Args:
  ...    ${fr_serial_number}: <description>
  ...    ${blocking_state}: <description>
  ...    ${led_state}: <description>
  ...    ${im_section}: <description>
  ...    ${reasoning_status}: <description>
  ...    ${alias}: <description>
  [Arguments]  ${fr_serial_number}  ${blocking_state}  ${led_state}  ${im_section}=/RU_L-1  ${reasoning_status}=True  ${alias}=default
  ${fr_rmod_node_path}=  Info Model Get Rmod DistName For FR Serial Number  ${fr_serial_number}  alias=${alias}
  ${tmp}=  Run keyword and return status  Should Be Equal As Strings  ${reasoning_status}  True
  Run keyword and continue on failure
  ...  Query infomodel
  ...  query=${fr_rmod_node_path}/RU_L-1 is [stateInfo.blockingState=${blocking_state}]
  ...  alias=${alias}
  Run keyword and continue on failure  Query infomodel  query=${fr_rmod_node_path}/RU_L-1/LED_L-1 is [ledState=${led_state}]  alias=${alias}
  Run keyword and continue on failure
  ...  Run keyword If
  ...  not ${tmp}
  ...  Query infomodel
  ...  query=${fr_rmod_node_path}${im_section} is [stateInfo.reasoningStatus[?]=${reasoning_status}]
  ...  alias=${alias}

Reset of Radio Module with Telnet
  [Arguments]  ${rf_serial_number}
  [Documentation]    Keyword logs to RF module using telnet and reset the radio.
  Log To Console  Reseting RM ${rf_serial_number} via Telnet
  radio.Open Connection To Radio Module  ru_serial_number=${rf_serial_number}
  radio.Send Command  command=Mcu -r 11 6
  Run Keyword And Continue On Failure  radio.Read Until Prompt  prompt=$|#|>  timeout=30
  Sleep  30  # To let RM react with reset command
  [Teardown]  radio.Close SSH Connection

#Reset of Radio Module via ARD0546 Message
#  [Arguments]  ${rf_serial_number}
#  [Documentation]  Keyword logs to RF module using telnet and reset the radio.
#  ${rf_ip_address}=  Get Radio Ip  ${rf_serial_number}
#  SSHLibrary.Open Connection  host=192.168.255.1  timeout=30
#  SSHLibrary.Login  username=toor4nsn  password=oZPS0POrRieRtu
#  Run keyword if  ${IS_AIRSCALE}  Run keywords
#  ...  SSHLibrary.Write  ${LXC_COMMAND}
#  ...  AND
#  ...  Sleep  4s
#  SSHLibrary.Write  telnet ${rf_ip_address} 1307
#  Sleep  2s
#  SSHLibrary.Write  [
#  SSHLibrary.Write  MESSAGE: TYPE=ACTION
#  SSHLibrary.Write  TRANSACTION: ID=439
#  SSHLibrary.Write  RESETREQ:TYPE=FULL IMAGE=ACTIVE
#  SSHLibrary.Write  ]
#  [Teardown]  SSHLibrary.Close Connection

Check If RF Status Is OK
  [Arguments]  ${fr_serial_number}  ${alias}=default
  [Documentation]    Keyword checks if there is no unexpected alarms and if state of pointed RF is correct.
  Log To Console  Checking if there is not unexpected alarms on RM ${fr_serial_number} and its state is correct
  Run Keyword And Continue On Failure  Info Model Alarms Get And Check  allowed=${ALLOWED_ALARMS_WHEN_OK}  alias=${alias}
  Run Keyword And Continue On Failure  Admin Alarms Get And Check  allowed=${ALLOWED_ALARMS_TEST}  alias=${alias}
  Run Keyword And Continue On Failure
  ...  Info Model Check Current FR State And Compare
  ...  fr_serial_number=${fr_serial_number}
  ...  blocking_state=${RF_IM_BLOCKING_STATE_WHEN_OK}
  ...  led_state=${RF_IM_LED_STATE_WHEN_OK}
  ...  alias=${alias}

SysLog Fault Check
  [Documentation]    Short description.
  ...
  ...  Args:
  ...    ${rf_serial_number}: <description>
  ...    ${fault_number}: <description>
  ...    ${alarm_state}: <description>
  ...    ${timeout}: <description>
  ...    ${alias}: <description>
  [Arguments]  ${rf_serial_number}  ${fault_number}  ${alarm_state}=active  ${timeout}=60s  ${alias}=default
  # ${rf_data}=  ta_Enb.Get Radio Modules  serial_number=${rf_serial_number}
  # ${rf_rmod_node_path}=  Set variable  ${rf_data[0].dist_name}
  ${rf_rmod_node_path}=  Get From Dictionary  ${CFG["RF_INFO"]["${rf_serial_number}"]}  scf_dist_name_primary
  Log To Console  Checking for alarm ${rf_serial_number} to be ${alarm_state} on Rm ${rf_serial_number} in syslog file
  ${result}=  Wait until keyword succeeds
  ...  ${timeout}
  ...  15s
  ...  Message should exist in syslog file
  ...  \\[Detector ${fault_number} ${rf_rmod_node_path}.*\\] ${alarm_state}.*
  ...  alias=${alias}
  Log To Console  Checking status: ${result}

Generate fault 1923 on RF
  [Arguments]  ${time_to_wait_for_fault}=10s  ${alias}=default
  [Documentation]     Keyword changes serial number of tested RF and checks if RF is ok after the change.
  ...                 In the end resets RF and wait for fault in given amount of time.
  ${fr_under_test_serial_number_fake}=  Prepare fake serial number  ${FR_UNDER_TEST_SERIAL_NUMBER}
  Set suite variable  ${FR_UNDER_TEST_SERIAL_NUMBER_FAKE}  ${fr_under_test_serial_number_fake}
  Set suite variable  ${OUT_CELL_COUNT_FOR_ALL_FRS}  ${cfg["NODES"]["${cfg.primary_node_bts_id}"]["scf_cell_count"]["ALL"]}
  Change serial number of radio module and check  ${FR_UNDER_TEST_SERIAL_NUMBER}  ${FR_UNDER_TEST_SERIAL_NUMBER_FAKE}
  Run keyword and continue on failure  Check If RF Status Is OK  ${FR_UNDER_TEST_SERIAL_NUMBER}  alias=${cfg.primary_node_bts_id}
  Reset Of Radio Module With Telnet  ${FR_UNDER_TEST_SERIAL_NUMBER}
  Run keyword and continue on failure
  ...  Wait for infomodel event
  ...  event=change /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/RMOD_L-* [stateInfo.operationalState: Disabled -> Enabled]
  ...  timeout=150
  ...  alias=${alias}
#  Run keyword and continue on failure
#  ...  Query infomodel
#  ...  query=count //MRBTS_M-1/LNBTS_M-1/CELL_M-* is [stateInfo.proceduralState=OnAirDone] = ${OUT_CELL_COUNT_FOR_ALL_FRS}
#  ...  timeout=${ONAIR_STATUS_TIMEOUT}
#  ...  alias=${alias}
  Run Keyword And Continue On Failure  Assert Alarm Active  faultId=1923  timeout=90  alias=${alias}
  Set suite variable  ${SN_NAME_END}  _FAKE
  ${time_to_wait_for_fault}=  Set Variable  ${time_to_wait_for_fault}

Change Serial Number Of Radio Module And Check
  [Arguments]  ${current_rf_serial_number}  ${new_rf_serial_number}
  [Documentation]    Keyword logs to RF module with given serial number using telnet and changes the serial number to the new one.
  Log To Console  Changing Serial Number of RM ${current_rf_serial_number} with check
  radio.Open Connection To Radio Module  ru_serial_number=${current_rf_serial_number}
  radio.Send Command  command=eeprom -s serialNumber ${new_rf_serial_number}
  radio.Send Command  command=eeprom -g serialNumber
  ${tmp}=  radio.Read Output  1
  Should match regexp  ${tmp}  ${new_rf_serial_number}
  [Teardown]  radio.Close SSH Connection

Prepare Fake Serial Number
  [Documentation]    Short description.
  ...
  ...  Args:
  ...    ${rf_serial_number}: <description>
  ...
  ...  Returns:
  ...    ${fake_rf_serial_number}: <description>
  [Arguments]  ${rf_serial_number}
  ${tmp1}=  Get substring  ${rf_serial_number}  start=0  end=4
  ${tmp2}=  Get substring  ${rf_serial_number}  start=6
  ${fake_rf_serial_number}=  Catenate  SEPARATOR=99  ${tmp1}  ${tmp2}
  [Return]  ${fake_rf_serial_number}

Generate fault on RF with RF files modifications
  [Arguments]  ${fault_number}  ${RF_config_file_name}  ${rf_serial_number}  ${time_to_wait_for_fault}=20s  ${syslog}=False  ${alias}=default
  [Documentation]     Keyword logs to RF module using telnet, then it downloads RF config files and changes them.
  ...                 In the end KW uploads files to RF, overwrights original files with new ones and resets RF.
  ...                 Then KW waits given amount of sec. (in case of transient fault) or KW waits for fault given amount of sec.
  ...                 (in case of nontransient fault)
  ${rm_model}  ${rm_ip}  ${smod_model}  ${smod_ip}=  radio.Open Connection To Radio Module  ru_serial_number=${rf_serial_number}
  ${active_rf_file_version}=  Get Version of Active RF Config File  file_name=${RF_config_file_name}  rf_serial_number=${rf_serial_number}
  Set Test Variable  ${ACTIVE_RF_FILE_VERSION}  ${active_rf_file_version}
  Download Config File From RF
  ...  rf_serial_number=${rf_serial_number}
  ...  host_ip=${rm_ip}
  ...  file_path=${cfg.test_logs_path}
  ...  file_name=${active_rf_file_version}
  IF  "${RF_config_file_name}"=="OMP"
    Change Parameter In RF Config OMP File
    ...  file_location_path=${cfg.test_logs_path}
    ...  file_name=${active_rf_file_version}_modified.xml
    ...  parameter_name=${FAULT${fault_number}_PARAMETER_NAME}
    ...  attribute_name=${FAULT${fault_number}_ATTRIBUTE_NAME}
    ...  new_value=${FAULT${fault_number}_NEW_VALUE}
    ...  attribute_to_find_name=${FAULT${fault_number}_ATTRIBUTE_TO_FIND_NAME}
    ...  attribute_to_find_value=${FAULT${fault_number}_ATTRIBUTE_TO_FIND_VALUE}
  END
  IF  "${RF_config_file_name}"=="FDR"
    Change RF Config FDR File  file_location_path=${cfg.test_logs_path}  file_name=${active_rf_file_version}_modified.xml
  END
  Set Checksum Calculation on RF  rf_serial_number=${rf_serial_number}  parameter_value=Disable
  Upload Config File To RF And Update
  ...  host_ip=${rm_ip}
  ...  rf_serial_number=${rf_serial_number}
  ...  file_path=${cfg.test_logs_path}
  ...  config_file_name=${active_rf_file_version}_modified.xml
  Reset of Radio Module with Telnet  ${rf_serial_number}
  Log  Waiting for RM ${FR_UNDER_TEST_SERIAL_NUMBER} to restart  console=yes
  ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${rf_serial_number}
  Log To Console  Waiting for RM ${rf_serial_number} reach operationalState disabled and availabilityStatus not installed...
  Run keyword and continue on failure
  ...  Wait Until Keyword Succeeds
  ...  40
  ...  10
  ...  Assert
  ...  RMOD
  ...  ${ru_dist_name}
  ...  operationalState=regex"(?i)disabled", availabilityStatus=regex"(?i)not\\s?installed"
  ...  alias=${alias}
  Log To Console  Waiting for RM ${rf_serial_number} reach operationalState disabled and availabilityStatus off line...
  Run keyword and continue on failure
  ...  Wait Until Keyword Succeeds
  ...  180
  ...  10
  ...  Assert
  ...  RMOD
  ...  ${ru_dist_name}
  ...  operationalState=regex"(?i)disabled", availabilityStatus=regex"(?i)off\\s?line"
  ...  alias=${alias}
  Log  Waiting for alarm ${fault_number} to appear  console=yes
  IF  '${time_to_wait_for_fault}'!='0s' and not ${syslog}
    Run Keyword And Continue On Failure  Assert Alarm Active  faultId=${fault_number}  timeout=${time_to_wait_for_fault}  alias=${alias}
  ELSE IF  '${time_to_wait_for_fault}'!='0s'
    SysLog Fault Check  ${rf_serial_number}  ${fault_number}  alarm_state=active  timeout=${time_to_wait_for_fault}  alias=${alias}
  END
  [Teardown]  radio.Close SSH Connection

Generate fault on RF with RF files modifications For CNI-127210
  [Arguments]  ${fault_number}  ${RF_config_file_name}  ${rf_serial_number}  ${time_to_wait_for_fault}=20s  ${syslog}=False  ${alias}=default
  [Documentation]     Keyword logs to RF module using telnet, then it downloads RF config files and changes them.
  ...                 In the end KW uploads files to RF, overwrights original files with new ones and resets RF.
  ...                 Then KW waits given amount of sec. (in case of transient fault) or KW waits for fault given amount of sec.
  ...                 (in case of nontransient fault)
  ${rm_model}  ${rm_ip}  ${smod_model}  ${smod_ip}=  radio.Open Connection To Radio Module  ru_serial_number=${rf_serial_number}
  ${active_rf_file_version}=  Get Version of Active RF Config File  file_name=${RF_config_file_name}  rf_serial_number=${rf_serial_number}
  Set Test Variable  ${ACTIVE_RF_FILE_VERSION}  ${active_rf_file_version}
  Download Config File From RF
  ...  rf_serial_number=${rf_serial_number}
  ...  host_ip=${rm_ip}
  ...  file_path=${cfg.test_logs_path}
  ...  file_name=${active_rf_file_version}
  IF  "${RF_config_file_name}"=="OMP"
    Change Parameter In RF Config OMP File
    ...  file_location_path=${cfg.test_logs_path}
    ...  file_name=${active_rf_file_version}_modified.xml
    ...  parameter_name=${FAULT${fault_number}_PARAMETER_NAME}
    ...  attribute_name=${FAULT${fault_number}_ATTRIBUTE_NAME}
    ...  new_value=${FAULT${fault_number}_NEW_VALUE}
    ...  attribute_to_find_name=${FAULT${fault_number}_ATTRIBUTE_TO_FIND_NAME}
    ...  attribute_to_find_value=${FAULT${fault_number}_ATTRIBUTE_TO_FIND_VALUE}
  END
  IF  "${RF_config_file_name}"=="FDR"
    Change RF Config FDR File  file_location_path=${cfg.test_logs_path}  file_name=${active_rf_file_version}_modified.xml
  END
  Set Checksum Calculation on RF  rf_serial_number=${rf_serial_number}  parameter_value=Disable
  Upload Config File To RF And Update
  ...  host_ip=${rm_ip}
  ...  rf_serial_number=${rf_serial_number}
  ...  file_path=${cfg.test_logs_path}
  ...  config_file_name=${active_rf_file_version}_modified.xml
  Reset of Radio Module with Telnet  ${rf_serial_number}
  Log  Waiting for RM ${FR_UNDER_TEST_SERIAL_NUMBER} to restart  console=yes
  ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${rf_serial_number}
  Log To Console  Waiting for RM ${rf_serial_number} reach operationalState disabled and availabilityStatus not installed...
  Run keyword and continue on failure
  ...  Wait Until Keyword Succeeds
  ...  40
  ...  10
  ...  Assert
  ...  RMOD
  ...  ${ru_dist_name}
  ...  operationalState=regex"(?i)disabled", availabilityStatus=regex"(?i)not\\s?installed"
  ...  alias=${alias}
  Log To Console  Waiting for RM ${rf_serial_number} reach operationalState disabled and availabilityStatus off line...
  Run keyword and continue on failure
  ...  Wait Until Keyword Succeeds
  ...  180
  ...  10
  ...  Assert
  ...  RMOD
  ...  ${ru_dist_name}
  ...  operationalState=regex"(?i)disabled", availabilityStatus=regex"(?i)off\\s?line"
  ...  alias=${alias}
  Log  Waiting for alarm ${fault_number} to appear  console=yes
  IF  '${time_to_wait_for_fault}'!='0s' and not ${syslog} and not ${PRECOND_FOR_CNI}
    Run Keyword And Continue On Failure  Assert Alarm Active  faultId=${fault_number}  timeout=${time_to_wait_for_fault}  alias=${alias}
  ELSE IF  '${time_to_wait_for_fault}'!='0s' and not ${PRECOND_FOR_CNI}
    SysLog Fault Check  ${rf_serial_number}  ${fault_number}  alarm_state=active  timeout=${time_to_wait_for_fault}  alias=${alias}
  END
  [Teardown]  radio.Close SSH Connection

Get Version of Active RF Config File
  [Arguments]  ${file_name}  ${rf_serial_number}
  [Documentation]    Keyword logs to RF module using telnet and check and return name and version of active RF file.
  Log To Console  Sending command 'flash -a' to receive version of active config file
  radio.Open Connection To Radio Module  ru_serial_number=${rf_serial_number}
  radio.Send Command  command=flash -a
  ${cmd_output}=  radio.Read Output  5
  Log To Console  Response is:\n${cmd_output}
  ${rf_file_name}=  Should match regexp  ${cmd_output}  ${file_name}\\d{1}
  [Teardown]  radio.Close SSH Connection
  [Return]  ${rf_file_name}

Download Config File From RF
  [Arguments]  ${host_ip}  ${rf_serial_number}  ${file_path}=${cfg.test_logs_path}  ${file_name}=${active_rf_file_version}
  [Documentation]    Keyword downloads given config file to given location. Keyword also prepares copy of this file.
  ...             :param rmod_alias: alias to open rmod connection
  ...             :param file_path: location where file will be stored
  ...             :param file_name: name of needed config file (e.g. OMP1, OMP2, FDR1, FDR2)
  Log To Console  Sending command 'eeprom -g serialNumber' to RM ${rf_serial_number}
  radio.Open Connection To Radio Module  ru_serial_number=${rf_serial_number}
  radio.Send Command  command=eeprom -g serialNumber
  ${out_1}=  radio.Read Output  5
  Log To Console  Response is:\n${out_1}
  Create File  ${file_path}/RF_download_file_cmd_output_logs.txt  ${out_1}
  Log To Console  Sending command 'flash -f ${file_name} ${file_name}.xml' to RM ${rf_serial_number}
  radio.Send Command  command=flash -f ${file_name} ${file_name}.xml
  ${out_2}=  radio.Read Output  5
  Log To Console  Response is:\n${out_2}
  Append To File  ${file_path}/RF_download_file_cmd_output_logs.txt  ${out_2}
  ${object_1}=  Set Variable
  ...  sshpass -p oZPS0POrRieRtu scp "/home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/RF_Alarms/rf_ftp.py"
  ${object_2}=  Set Variable  toor4nsn@192.168.255.1:/user/toor4nsn/rf_ftp.py
  ${sum_object}=  Set Variable  ${object_1} ${object_2}
  ${command_status}  ${msg}=  Run Keyword And Ignore Error  OperatingSystem.Run And Return Rc And Output  ${sum_object}
  IF  '${msg[0]}'!='0'
    FAIL  Executed command failed with message: ${msg}
  END
  SSHLibrary.Open Connection  host=192.168.255.1  timeout=30
  SSHLibrary.Login  username=toor4nsn  password=oZPS0POrRieRtu
  IF  ${IS_AIRSCALE}
    SSHLibrary.Write  ${LXC_COMMAND}
    Sleep  4s
  END
  SSHLibrary.Write  /usr/bin/python3 /user/toor4nsn/rf_ftp.py -d ${host_ip} /ram/${file_name}.xml /user/toor4nsn/${file_name}.xml
  Sleep  10s
  SSHLibrary.Write  rm /user/toor4nsn/rf_ftp.py
  ${command_status}  ${msg}=  Run Keyword And Ignore Error
  ...  OperatingSystem.Run And Return Rc And Output
  ...  sshpass -p oZPS0POrRieRtu scp "toor4nsn@192.168.255.1:/user/toor4nsn/${file_name}.xml" "${file_path}/${file_name}.xml"
  IF  '${msg[0]}'!='0'
    FAIL  Executed command failed with message: ${msg}
  END
  ${command_status}  ${msg}=  Run Keyword And Ignore Error
  ...  OperatingSystem.Run And Return Rc And Output
  ...  sshpass -p oZPS0POrRieRtu scp "toor4nsn@192.168.255.1:/user/toor4nsn/${file_name}.xml" "${file_path}/${file_name}_modified.xml"
  IF  '${msg[0]}'!='0'
    FAIL  Executed command failed with message: ${msg}
  END
  [Teardown]  radio.Close SSH Connection

Change Parameter In RF Config OMP File
  [Arguments]
  ...  ${file_location_path}
  ...  ${file_name}
  ...  ${parameter_name}
  ...  ${new_value}
  ...  ${attribute_name}=${EMPTY}
  ...  ${attribute_to_find_name}=${EMPTY}
  ...  ${attribute_to_find_value}=${EMPTY}
  [Documentation]    Keyword changes given parameter/attribute in given RF OMP config file (at the deepest available level).
  ${new_xml}=  Parse XML  ${file_location_path}/${file_name}
  ${test_of_1927}=  Run keyword and return status  Should contain  ${TEST NAME}  1927
  ${test_of_1934}=  Run keyword and return status  Should contain  ${TEST NAME}  1934
  ${test_of_1935}=  Run keyword and return status  Should contain  ${TEST NAME}  1935
  ${test_of_1937}=  Run keyword and return status  Should contain  ${TEST NAME}  1937
  ${test_of_1938}=  Run keyword and return status  Should contain  ${TEST NAME}  1938
  ${parameter_name}=  Set variable if
  ...  '${attribute_to_find_name}'=='${EMPTY}'
  ...  ${parameter_name}
  ...  ${parameter_name}\[@${attribute_to_find_name}="${attribute_to_find_value}"\]
  ${level1_search}=  Run keyword and return status
  ...  Element should exist
  ...  source=${new_xml}
  ...  xpath=//module[@name="${OUT_NAME_FR_UNDER_TEST}"]//${parameter_name}
  Run keyword and return status
  ...  Run keyword if
  ...  ${test_of_1927}
  ...  Set element text
  ...  source=${new_xml}
  ...  text=1
  ...  xpath=//module[@name="${OUT_NAME_FR_UNDER_TEST}"]//T3C
  ${level_substatus1}=  Run Keyword And Return Status  Run Keyword If  ${level1_search}  Run Keyword If
  ...  not ${test_of_1934} and not ${test_of_1935} and not ${test_of_1937} and not ${test_of_1938}
  ...  Set element text  source=${new_xml}  text=${new_value}  xpath=//module[@name="${OUT_NAME_FR_UNDER_TEST}"]//${parameter_name}
  ${level_substatus2}=  Run Keyword And Return Status  Run Keyword If  ${level1_search}  Run Keyword If
  ...  ${test_of_1934} or ${test_of_1935} or ${test_of_1937} or ${test_of_1938}
  ...  Set elements attribute
  ...  source=${new_xml}
  ...  name=${attribute_name}
  ...  value=${new_value}
  ...  xpath=//module[@name="${OUT_NAME_FR_UNDER_TEST}"]//${parameter_name}
  #${test_of_1934}!=${test_of_1935}
  ${level_substatus3}=  Run Keyword And Return Status  Run Keyword If  ${level1_search}  Run Keyword If
  ...  ${test_of_1934} or ${test_of_1935}
  ...  Set element text  source=${new_xml}  text=7  xpath=//module[@name="${OUT_NAME_FR_UNDER_TEST}"]//Tblock
  ${level1_search}=  IF  ${level_substatus1} and ${level_substatus2} and ${level_substatus3}
  ...  Set Variable  ${level1_search}
  ...  ELSE
  ...  Set Variable  ${FALSE}
  ${rf_type}=  Get element attribute  source=${new_xml}  name=baseName  xpath=//module[@name="${OUT_NAME_FR_UNDER_TEST}"]
  ${level2_search}=  Run keyword and return status
  ...  Element should exist
  ...  source=${new_xml}
  ...  xpath=//generation[@baseName="${rf_type}"]//${parameter_name}
  Run keyword and return status
  ...  Run keyword if
  ...  ${test_of_1927}
  ...  Set element text
  ...  source=${new_xml}
  ...  text=1
  ...  xpath=//generation[@baseName="${rf_type}"]//T3C
  IF  ${level2_search}
    IF  not ${test_of_1934} and not ${test_of_1935} and not ${test_of_1937} and not ${test_of_1938}
      Set element text  source=${new_xml}  text=${new_value}  xpath=//generation[@baseName="${rf_type}"]//${parameter_name}
    END
  END
  IF  ${level2_search}
    IF  ${test_of_1934} or ${test_of_1935} or ${test_of_1937} or ${test_of_1938}
      Set elements attribute
      ...  source=${new_xml}
      ...  name=${attribute_name}
      ...  value=${new_value}
      ...  xpath=//generation[@baseName="${rf_type}"]//${parameter_name}
    END
  END
  #${test_of_1934}!=${test_of_1935}
  IF  ${level2_search}
    IF  ${test_of_1934} or ${test_of_1935}
      Set element text  source=${new_xml}  text=7  xpath=//generation[@baseName="${rf_type}"]//Tblock
    END
  END
  Run keyword and return status  Run keyword if  ${test_of_1927}  Set element text  source=${new_xml}  text=1  xpath=//common//T3C
  IF  ${level1_search}==${level2_search}
    IF  not ${test_of_1934} and not ${test_of_1935} and not ${test_of_1937} and not ${test_of_1938}
      Set element text  source=${new_xml}  text=${new_value}  xpath=//common//${parameter_name}
    END
  END
  IF  ${level1_search}==${level2_search}
    IF  ${test_of_1934} or ${test_of_1935} or ${test_of_1937} or ${test_of_1938}
      Set elements attribute  source=${new_xml}  name=${attribute_name}  value=${new_value}  xpath=//common//${parameter_name}
    END
  END
  #${test_of_1934}!=${test_of_1935}
  IF  ${level1_search}==${level2_search}
    IF  ${test_of_1934} or ${test_of_1935}
      Set element text  source=${new_xml}  text=7  xpath=//commonFor//Tblock
    END
  END
  Save xml  source=${new_xml}  path=${file_location_path}/${file_name}
  ${command_status}  ${msg}=  Run Keyword And Ignore Error
  ...  OperatingSystem.Run And Return Rc And Output
  ...  sed -i '1d' "${file_location_path}/${file_name}"
  IF  '${msg[0]}'!='0'
    FAIL  Executed command failed with message: ${msg}
  END
  Sleep  3s  #<- to let the above process to finish saving and closing xml

Change RF Config FDR File
  [Arguments]  ${file_location_path}  ${file_name}
  [Documentation]    Keyword removes FS_SECTION with Owner=fdpp in given RF FDR config file.
  ${new_xml}=  Parse XML  ${file_location_path}/${file_name}
  Remove element  source=${new_xml}  xpath=//FD_SECTION[@OWNER="fdpp"]
  Save xml  source=${new_xml}  path=${file_location_path}/${file_name}  encoding=ISO-8859-1
  Sleep  1s  #<- to let the above process to finish saving and closing xml

Set Checksum Calculation on RF
  [Arguments]  ${rf_serial_number}  ${parameter_value}
  [Documentation]    Keyword logs to RF module with given serial number using telnet and sets parameter related to file checksum calculation.
  ...                Possible values of "parameter_value": Enable, Disable.
  ...                After setting of parameter, reset of RF is needed to activate setting.
  Log To Console  Sending checksum calculation on RF ${rf_serial_number}
  radio.Open Connection To Radio Module  ru_serial_number=${rf_serial_number}
  IF  "${parameter_value}"=="Disable"
    radio.Send Command  command=rad -pw 0x122 0x1
  END
  IF  "${parameter_value}"=="Enable"
    radio.Send Command  command=rad -f
  END
  [Teardown]  radio.Close SSH Connection

Upload Config File To RF And Update
  [Arguments]  ${host_ip}  ${rf_serial_number}  ${file_path}=${cfg.test_logs_path}  ${config_file_name}=${active_rf_file_version}_modified.xml
  [Documentation]    Keyword uploads given config file to RF.
  ...             :param rmod_alias: alias to open rmod connection
  ...             :param file_path: location of file which need to be uploaded
  ...             :param file_name: name of the source file which be uploaded for OMP/FDR file on RF (name must be started with OMP1/2 or FDR1/2)
  ${object_1}=  Set Variable
  ...  sshpass -p oZPS0POrRieRtu scp "/home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/RF_Alarms/rf_ftp.py"
  ${object_2}=  Set Variable  toor4nsn@192.168.255.1:/user/toor4nsn/rf_ftp.py
  ${sum_object}=  Set Variable  ${object_1} ${object_2}
  ${command_status}  ${msg}=  Run Keyword And Ignore Error  OperatingSystem.Run And Return Rc And Output  ${sum_object}
  IF  '${msg[0]}'!='0'
    FAIL  Executed command failed with message: ${msg}
  END
  ${command_status}  ${msg}=  Run Keyword And Ignore Error
  ...  OperatingSystem.Run And Return Rc And Output
  ...  sshpass -p oZPS0POrRieRtu scp "${file_path}/${config_file_name}" "toor4nsn@192.168.255.1:/user/toor4nsn/${config_file_name}"
  IF  '${msg[0]}'!='0'
    FAIL  Executed command failed with message: ${msg}
  END
  SSHLibrary.Open Connection  host=192.168.255.1  timeout=30
  SSHLibrary.Login  username=toor4nsn  password=oZPS0POrRieRtu
  IF  ${IS_AIRSCALE}
    SSHLibrary.Write  ${LXC_COMMAND}
    Sleep  4s
  END
  SSHLibrary.Write  /usr/bin/python3 /user/toor4nsn/rf_ftp.py -u ${host_ip} /user/toor4nsn/${config_file_name} /ram/${config_file_name}
  Sleep  10s
  SSHLibrary.Write  rm /user/toor4nsn/rf_ftp.py
  radio.Open Connection To Radio Module  ru_serial_number=${rf_serial_number}
  radio.Send Command  command=eeprom -g serialNumber
  ${out_1}=  radio.Read Output  5
  Create File  ${file_path}/RF_upload_file_cmd_output_logs.txt  ${out_1}
  ${rf_config_file_name}=  Get Substring  ${config_file_name}  0  4
  radio.Send Command  command=flash -u ${rf_config_file_name} ${config_file_name}
  ${out_2}=  Run Keyword And Continue On Failure  radio.Read Until Prompt  prompt=$|#|>  timeout=30
  Append To File  ${file_path}/RF_upload_file_cmd_output_logs.txt  ${out_2}
  [Teardown]  Run Keywords  SSHLibrary.Close Connection  AND  radio.Close SSH Connection

Restore RF config files
  [Arguments]  ${rf_serial_number}
  [Documentation]    Keyword uploads original config files to RF and update it. It is resistant for problem with the first connection to RF.
  ${rm_model}  ${rm_ip}  ${smod_model}  ${smod_ip}=  radio.Open Connection To Radio Module  ru_serial_number=${rf_serial_number}
  ${tmp}=  Run keyword and return status
  ...  Upload Config File To RF And Update
  ...  rf_serial_number=${rf_serial_number}
  ...  host_ip=${rm_ip}
  ...  file_path=${OUT_TEST_LOGS_DIR_PATH}
  ...  config_file_name=${ACTIVE_RF_FILE_VERSION}.xml
  IF  not ${tmp}
    Upload Config File To RF And Update
    ...  rf_serial_number=${rf_serial_number}
    ...  host_ip=${rm_ip}
    ...  file_path=${cfg.test_logs_path}
    ...  config_file_name=${ACTIVE_RF_FILE_VERSION}.xml
  END
  Set Checksum Calculation on RF  rf_serial_number=${rf_serial_number}  parameter_value=Enable
  [Teardown]  radio.Close SSH Connection

Prepare FR Alarm Id
  [Documentation]    Short description.
  ...
  ...  Args:
  ...    ${alias}: <description>
  ...
  ...  Returns:
  ...    ${alarm_id}: <description>
  [Arguments]  ${alias}
  Get Current SCF File  ${cfg.test_logs_path}  current_scf.xml  connection=${alias}
  scf.Load Scf  file_path=${cfg.test_logs_path}/current_scf.xml
  ${actCategoryAlarms}=  scf.Get All Values From Scf By Pattern  p_name=actCategoryAlarms
  IF  '${actCategoryAlarms[0]}'=='True' or '${actCategoryAlarms[0]}'=='true'
    ${alarm_id}=  Create List  7115
  ELSE
    ${alarm_id}=  Create List  7652  7655
  END
  [Return]  ${alarm_id}
