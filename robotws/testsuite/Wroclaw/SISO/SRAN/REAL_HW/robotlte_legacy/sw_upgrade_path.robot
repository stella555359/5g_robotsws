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
Library  taf.fdsw.rc  WITH NAME  rc

*** Variables ***
${CONFIGURATION_STARTUP_TIMEOUT}  1500
${CONF_RF_UPDATE_TIMEOUT}  1200
${CONF_DOWNGRADE_TIMEOUT}  5000
${EXECUTE_UUF_UPGRADE_PROCEDURE}  False
${CUSTOMERS}  Generic
${ROLLBACK_STATUS}=   False

*** Keywords ***
Execute SW Upgrade UUF Path On Every Node
  Set Tags     AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynskia@nokia.com
  Common Test Setup
  Logging With Timestamp
  ...  message=Execute SW Upgrade UUF Path With : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  SW Upgrade UUF Path
  [Teardown]    Common Test Teardown


SW Upgrade UUF Path
  Branch Update Setup
  Run Keyword If  not ${REPETITION}  Run Keywords
  ...  Logging Session Multinode Restart  ${cfg.test_logs_path}  check_faults=${False}
  ...  AND  Gather Start Time
  ...  AND  Execute SW Upgrade On Every Node Procedure  ${cfg.test_logs_path}
  ...  AND  Refresh SW active state
  ...  AND  Rollback Software On Every Node  ${cfg.test_logs_path}
  ...  AND  Gather Stop Time
  Run Keyword If  not ${REPETITION}  Return From Keyword
  FOR  ${repetition_index}  IN  @{REPETITION_LIST}
    ${loop_log_path}=    Set Variable If   ${REPETITION}      ${cfg.test_logs_path}/${repetition_index}    ${cfg.test_logs_path}
    Logging Session Multinode Restart  ${cfg.test_logs_path}  check_faults=${False}
    Gather Start Time
    Execute SW Upgrade On Every Node Procedure  ${cfg.test_logs_path}
    Refresh SW active state
    Rollback Software On Every Node  ${cfg.test_logs_path}
    Gather Stop Time
    Log Variables
  END
  [Teardown]    Run Keywords
  ...  Logging Session Multinode Restart  ${cfg.test_logs_path}  check_faults=${False}
  ...  AND  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'
  ...  Execute Recommissioning On Every Node  ${cfg.test_logs_path}
  ...  AND  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL' or '${rollback_status}' == 'True'
  ...  Execute SW Upgrade On Every Node Procedure  ${cfg.test_logs_path}


Branch Update Setup
  Prepare VM For SW Downgrade
  Downgrade Software
  Prepare BTS For SW Upgrade
  [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'
  ...  Run Keywords
      ...  PDU Switch On Device Lists  ${cfg.NODES['${node}']['scf_hw_fhs_list']}
      ...  PDU Switch On Device Lists  ${cfg.NODES['${node}']['scf_hw_fr_list']}

Prepare VM For SW Downgrade
  FOR  ${node}  IN  @{cfg.active_bts_list}
    Download Proper Software From Source  ${node}
    Reset Site Configuration  ${node}
    Sleep  240 sec
  END

Downgrade Software
  FOR  ${node}  IN  @{cfg.active_bts_list}
    PDU Switch OFF Device Lists  ${cfg.NODES['${node}']['scf_hw_fr_list']}
    PDU Switch OFF Device Lists  ${cfg.NODES['${node}']['scf_hw_fhs_list']}
    Download Software  ${node}
  END

Prepare BTS For SW Upgrade
  FOR  ${node}  IN  @{cfg.active_bts_list}
#  Remove Users Json File On SM  ${node}
    Run Keyword And Ignore Error  CM.CM BTS Admin Not Available  ${node}  120
    Wait Until Keyword Succeeds  2000 sec  20 sec  admin.Reset Admin  connection=${node}
#    Logging Node Admin Restart  ${cfg.test_logs_path}  ${node}  2000
    Perform Template File Commissioning  ${node}  True  previous
    PDU Switch On Device Lists  ${cfg.NODES['${node}']['scf_hw_fhs_list']}
    PDU Switch On Device Lists  ${cfg.NODES['${node}']['scf_hw_fr_list']}
  END
  FOR  ${node}  IN  @{cfg.active_bts_list}
    Verify HW Node state  ${cfg}  ${node}  ${CONFIGURATION_STARTUP_TIMEOUT}
    Update SW If Needed  ${node}
  END
  Run Keyword And Ignore Error  Remove File  ${uuf_sw_folder}/${tested_node_previous_branch}.zip
  FOR  ${node}  IN  @{cfg.active_bts_list}
    Verify BTS State  ${node}  ${CONFIGURATION_STARTUP_TIMEOUT}
  END
  FOR  ${node}  IN  @{cfg.active_bts_list}
    Verify Alarms  alias=${node}
  END

Update SW If Needed
  [Arguments]  ${bts_id}

  ${active_branch}=  Should Match Regexp    ${CFG['NODES']['${BTS_ID}']['software_active']}    ^(?:[FT]L|SBTS|5G)\\d+[A-Z]*\\d?
  ${tested_node_previous_branch}=  Get From Dictionary  ${BRANCH_UPGRADE_BUILD}  ${active_branch}
  Run Keywords
  ...  Log
  ...  \nRF Software mismatch - running software update procedure
  ...  AND
  ...  admin.Wait Sw Update Possible
  ...  bts_ready=True
  ...  readiness_timeout=800
  ...  timeout=900
  ...  connection=${bts_id}
  ...  AND
  ...  Update Software
  ...  sw_package=${uuf_sw_folder}/${tested_node_previous_branch}.zip
  ...  timeout=${CONF_RF_UPDATE_TIMEOUT}
  ...  alias=${bts_id}
  ${bts_reset_needed}=  Run Keyword And Return Status
  ...  admin.Assert Alarm Active
  ...  faultId=4001
  ...  timeout=240 sec
  ...  alias=${bts_id}
  Run Keyword If  ${bts_reset_needed}  Run Keywords
  ...  Check Is BTS Is Ready For API  ${bts_id}  60 sec
  ...  AND  Execute Power Reset On Node  ${cfg.test_logs_path}  ${bts_id}


#Remove Users Json File On SM
#  [Arguments]  ${node_id}
#  ${tested_node_previous_branch}=  Get From Dictionary  ${BRANCH_UPGRADE_BUILD}  ${RELEASE}
#  Return From Keyword If  '${RELEASE}' != 'SBTS21B'
#  ${bts_sm}=  Get From Dictionary  ${cfg.NODES['${node_id}']}  primary_sm
#
#  ${remote_host_ip}=  Set Variable If  '${bts_type}' == 'localhost'  ${EMPTY}  ${cfg.NODES['${node_id}']['host_ip']}
#  Setup Enb Fsm Access  remote_host=${remote_host_ip}
#  Execute Command On Enb  cmd=rm /rom/config/users.json
#  Run Keyword And Ignore Error  Execute Command On Enb  cmd=reboot
#  Run Keyword And Continue On Failure  Run Keyword If  '${remote_host_ip}' != '${EMPTY}'
#  ...  Wait Until Host Is Unavailable
#  ...  hosts=192.168.255.129
#  ...  remote_host=${remote_host_ip}
#  ...  Timeout=120
#  ...  ELSE
#  ...  Wait Until Host Is Unavailable
#  ...  hosts=192.168.255.129
#  ...  Timeout=120
#  [Teardown]  Run Keyword IF  '${RELEASE}' == 'SBTS21B'  Teardown Enb Fsm Access

BTS Address Is Pingable
  [Arguments]  ${host_ip_addr}
  ${rc}=  Run And Return Rc  ping -c 1 ${host_ip_addr}
  should be equal as integers  ${rc}  0

Branch Update Teardown
#  Run Keyword If Test Failed  Check SM Initial State
  Log  Men at work  console=True


Download Proper Software From Source
  [Arguments]  ${bts_id}
  Set Test Variable  ${uuf_sw_folder}  /home/ute/sw_uuf
  ${bts_sm}=  Get From Dictionary  ${cfg.NODES['${bts_id}']}  primary_sm
  ${tested_node_previous_branch}=  Get From Dictionary  ${BRANCH_UPGRADE_BUILD}  ${RELEASE}
  ${sw_elements}=  Split String  ${cfg.NODES['${bts_id}']['software_active']}  _
  ${SW_PLATFORM}=  Set Variable If  '${sw_elements[1]}'=='ENB'  ${EMPTY}  _${sw_elements[1]}
  Set Test Variable  ${SW_PLATFORM}
  ${software_package_path}=  Check Main Software Package Availability
  ...  ${tested_node_previous_branch}
  ...  ${bts_id}
  ...  ${uuf_sw_folder}
  Create Directory  ${uuf_sw_folder}
  Set Test Variable  ${TESTED_NODE_PREVIOUS_BRANCH}  ${tested_node_previous_branch}
  Move File  ${software_package_path}  ${uuf_sw_folder}/${tested_node_previous_branch}.zip


Reset Site Configuration
  [Arguments]  ${bts_id}
  [Timeout]  ${CONFIGURATION_STARTUP_TIMEOUT}
  ${secondary_sm}=  Get Variable Value  ${CFG.NODES['${bts_id}']['secondary_sm']}  ${False}
  ${slave_sm_ip}=  Run Keyword If  '${secondary_sm}'!='None'
  ...  Get From Dictionary  ${CFG.NODES['${bts_id}']}  secondary_sm_vm_ip_LMP_address
  ${slave_sm_ip}=  Set Variable If  '${secondary_sm}'!='None'  ${slave_sm_ip}  ${None}
  ${reset_configuration_status}=  Run Keyword And Continue On Failure  rfrl_reset_conf.Reset Bts Configuration
  ...  connection=${bts_id}
  ...  secondary_remote_host=${slave_sm_ip}
  ...  timeout=${CONFIGURATION_SWUPDATE_TIMEOUT}
  sleep  120 sec
  [Teardown]  Run Keywords
  ...  Run Keyword And Ignore Error  rc.Teardown  connection=FDSW_PRIMARY_CONNECTION
  ...  AND  Run Keyword And Ignore Error  rc.Teardown  connection=FDSW_SECONDARY_CONNECTION

Download Software
  [Arguments]  ${bts_id}
  [Timeout]  ${CONF_DOWNGRADE_TIMEOUT}
  ${tested_node_previous_branch}=  Get From Dictionary  ${BRANCH_UPGRADE_BUILD}  ${RELEASE}
  Run Keyword And Ignore Error  admin.Wait Sw Update Possible
  ...  bts_ready=True
  ...  readiness_timeout=500
  ...  timeout=600
  ...  connection=${bts_id}
  Wait Until Keyword Succeeds  500 sec  20 sec  admin.Reset Admin  connection=${bts_id}
  ${sw_download_response}=  Run Keyword And Ignore Error
  ...  Update Software
  ...  sw_package=${uuf_sw_folder}/${tested_node_previous_branch}.zip
  ...  timeout=3600
  ...  alias=${bts_id}
  Run Keyword If  '${sw_download_response[0]}' == 'FAIL'  Run Keywords
  ...  Sleep  500 sec
  ...  AND  Update Software
  ...  sw_package=${uuf_sw_folder}/${tested_node_previous_branch}.zip
  ...  timeout=8000
  ...  alias=${bts_id}
  ${slave_bts_sm}=  Get From Dictionary  ${cfg.NODES['${bts_id}']}  secondary_sm
  ${bts_slave_ip}=  Run Keyword If  '${slave_bts_sm}' != 'None'
  ...  Get From Dictionary  ${CFG.NODES['${bts_id}']}  secondary_sm_vm_ip_LMP_address
  ${tmp_sm_master_list}=  Create List  ${cfg.NODES['${bts_id}']['primary_sm']}
  ${out_compare_slave_status}=  Run Keyword If  '${slave_bts_sm}' != 'None'  Run Keywords
  ...  PDU Switch OFF Device Lists  ${tmp_sm_master_list}
  ...  AND  Sleep  60 sec
  ...  AND  Setup Admin
  ...  bts_host=192.168.255.129
  ...  bts_port=443
  ...  remote_host=${bts_slave_ip}
  ...  timeout=3600
  ...  alias=slave
  ...  AND  Run Keyword And Ignore Error  admin.Wait Sw Update Possible
  ...  bts_ready=True
  ...  readiness_timeout=500
  ...  timeout=600
  ...  connection=slave
  ...  AND  Update Software
  ...  sw_package=${uuf_sw_folder}/${tested_node_previous_branch}.zip
  ...  timeout=8000
  ...  alias=slave
  ...  AND  PDU Switch On Device Lists  ${tmp_sm_master_list}
  [Teardown]  Run Keyword If  '${slave_bts_sm}' != 'None'  Run Keywords
  ...  PDU Switch On Device Lists  ${tmp_sm_master_list}
  ...  AND  admin.Teardown  connection=slave

Prepare Commissioning For Upgraded Branch
  Return From Keyword If  ${RECONFIGURATION_NOT_NEEDED}  Commissioning not needed
  ${bts_id_list}=  Get Dictionary Keys  ${cfg.NODES}
  FOR  ${bts_id}  IN  @{bts_id_list}
    ${active_file_release}=  Set Variable If  ${TRUNK_STATUS}
    ...  SBTS00  ${RELEASE}
    ${recommissioning_scf_file_path}=  Run Keyword If  "${path}" == "previous"
    ...  Replace String Using Regexp  ${cfg.NODES['${bts_id}']['scf_file_path']}
    ...  ${active_file_release}
    ...  ${BRANCH_NAME_UPGRADE_PATH['${RELEASE}']}
    ...  ELSE  Set Variable  ${cfg.NODES['${bts_id}']['scf_file_path']}
    Log  \nBTS template commissioning procedure on bts_id node=${bts_id} started  console=True
    ${result}=  perform_commissioning  ${bts_id}  ${recommissioning_scf_file_path}
    ...  skip_parameter_relation_errors=${ignore_errors}  should_activate=True  timeout=600  alias=${bts_id}
    ${status}  ${response}=  Run Keyword And Ignore Error
    ...  Set Variable  ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}
    Run Keyword If  '${response}' != 'Success'  Log  Recommissioning failed due to  ${response}
    Should Be True  '${response}' == 'Success'
  END
  Verify Multi BTS State

#Check RD Paramaters For UUF Testcase
#  FOR  ${node_id}  IN  @{cfg.active_bts_list}
#    ${bts_sm}=  Get From Dictionary  ${cfg.NODES['${node_id}']}  primary_sm
#    ${bts_type}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  bts_alias_type
##    Run Keyword And Ignore Error  BTS Prepare Mandatory Flags  ${node_id}  ${bts_type}
#  END

### UUF solution
#
#Execute Site SW upgrade Path On Every Node
#  [Arguments]  ${test_logs_path}
#  FOR  ${node}  IN  @{cfg.active_bts_list}
#    Perform CIT  ${CUSTOM_INITIAL_CIT_SW[0]}
#    Verify BTS State  ${node}
#    Verify Alarms  alias=${node}
#  END
#
#Precondition SW Upgrade Path TC
#  [Arguments]  ${test_logs_path}
#  Log  \n|-------------------------------------  console=True
#  Log  \nPrecondition for ${TEST NAME} started  console=True
##  UUF Specific Precondition
#
#  Logging Multinode Start  ${test_logs_path}
#  Log  \nPrecondition for ${TEST NAME} finished  console=True
#  Log  \n|_____________________________________  console=True
#  Log Variables
#  [Teardown]  Run Keyword If  '${KEYWORD STATUS}' != 'PASS'  FAIL
#
#Prepare Siso Configuration For UUF Testcase
#  ${UUF_NODES}  ${UUF_CLOUD_EXECUTION}=  Create Dictionary Description For UUF Type Testcases  ${cfg.active_bts_list}
#  Run Keyword If  not ${UUF_CLOUD_EXECUTION}  Branch Update Setup
#  FOR  ${node}  IN  @{cfg.active_bts_list}
#    ${bts_sm}=  Get From Dictionary  ${cfg.NODES['${node}']}  primary_sm
#    ${bts_type}=  Get From Dictionary  ${cfg.NODES['${node}']}  bts_alias_type
#    Run Keyword And Ignore Error  Compare And Upload Swconfig
#    Execute Reset On Node  ${node}
#    Verify Multi BTS State
#  END
#  [Return]  ${UUF_NODES}  ${UUF_CLOUD_EXECUTION}
#
#Create Dictionary Description For UUF Type Testcases
#  [Arguments]  ${nodes_list}
#  ${fault_ids}=  Extract Fault Ids  ${GLO_ADMIN_ALLOWED_ALARMS}
#  ${uuf_nodes}=  Create List  @{EMPTY}
#  FOR  ${node}  IN  @{nodes_list}
#    ${active_branch}=  Get From Dictionary  ${cfg.NODES['${node}']}  active_release
#    ${active_software}=  Get From Dictionary  ${cfg.NODES['${node}']}  software_active
#    ${tested_node_previous_branch}=  Get From Dictionary  ${BRANCH_UPGRADE_BUILD}  ${active_branch}
#    ${initial_sw}=  Run Keyword And Ignore Error  Get Source SW
#    ${uuf_cloud_execution}=  Set Variable If  '${initial_sw}[0]'!='FAIL'  ${True}  ${False}
#    ${initial_sw}=  Set Variable If  '${initial_sw}[0]'!='FAIL'  ${initial_sw}  ${tested_node_previous_branch}
#    Set Suite Variable  ${UUF_CLOUD_EXECUTION}  ${uuf_cloud_execution}
#    ${candidate_sw}=  Run Keyword And Ignore Error  Get Target SW
#    ${candidate_sw}=  Set Variable If  '${candidate_sw}[0]'!='FAIL'  ${candidate_sw}  ${active_software}
#    ${candidate_sw}=  Run Keyword If  ${TRUNK_STATUS}
#    ...  Replace String Using Regexp  ${candidate_sw}  ^([A-Z]+)\\d+[A-Z]\\d?  SBTS00
#    ${tmp_dict}=  Create Dictionary  &{EMPTY}
#    ${primary_sm}=  Get From Dictionary  ${cfg['NODES']['${node}']}  primary_sm
#    ${secondary_sm}=  Get From Dictionary  ${cfg['NODES']['${node}']}  secondary_sm
#    ${master_host_ip}=  Get From Dictionary  ${cfg['NODES']['${node}']}  vm_ip_LMP_address
#    ${slave_host_ip}=  Get From Dictionary  ${cfg['NODES']['${node}']}  secondary_sm_vm_ip_LMP_address
#    ${candidate_sw}  ${_}=  Create Software Package Name  ${candidate_sw}
#    Set To Dictionary  ${tmp_dict}
#    ...  node_vm=${master_host_ip}
#    ...  secondary_vm=${slave_host_ip}
#    ...  source_sw=${initial_sw}
#    ...  target_sw=${candidate_sw}
#    ...  custom_allowed_alarms=${fault_ids}
#    ...  node_alias=${node}
#    Append To List  ${uuf_nodes}  ${tmp_dict}
#    Set Suite Variable  ${UUF_NODES}
#  END
#  ${ITERATIONS}=  Get Length  ${REPETITION_LIST}
#  Set Test Variable  ${ITERATIONS}  ${ITERATIONS}
#  ${TESTLINE_NAME}=  Set Variable  ${CONFIG_NAME}
#  [Return]  ${UUF_NODES}  ${UUF_CLOUD_EXECUTION}
#
#Extract Fault Ids
#  [Arguments]  ${fault_list}
#  @{fault_ids}=  Create List
#  FOR  ${alarm}  IN  @{fault_list}
#    @{alarm_parts}=  Split String  ${alarm}  ,
#    ${fault_id_part}=  Set Variable  @{alarm_parts}[0]
#    @{id_pair}=  Split String  ${fault_id_part}  =
#    ${id}=  Set Variable  @{id_pair}[1]
#    Append To List  ${fault_ids}  ${id}
#  END
#  [Return]  ${fault_ids}
#
#UUF Upgrade In Case Of Upgrade Path Type Execution
#  Return From Keyword If  ${RECONFIGURATION_NOT_NEEDED}
#  Return From Keyword If  not ${EXECUTE_UUF_UPGRADE_PROCEDURE}
#  ${UUF_NODES}  ${UUF_CLOUD_EXECUTION}=  Create Dictionary Description For UUF Type Testcases  ${cfg.active_bts_list}
#  Return From Keyword If  not ${UUF_CLOUD_EXECUTION}
#  Verify Multi BTS State
#  Run Keyword And Ignore Error
#  ...  e2e_tl_upgrade_test
#  ...  ${UUF_NODES}
#  ...  ${UUF_NODES}
#  ...  ${ITERATIONS}
#  ...  customers_list=${CUSTOMERS}
#  ...  report=${UUF_REPORT}
#
#Verify SW Version between BTS And CM Execution
#  ${siso_initial_build}=  Set Variable If  not ${UUF_CLOUD_EXECUTION}
#
#  ${extended_reservation_file}=  Run Keyword And Return Status
#  ...  operatingsystem.file should exist  path=/opt/ute/reservation.context.json
#  ${extended_reservation_dict}=  Run Keyword If  ${extended_reservation_file}
#  ...  Run Keyword And Continue On Failure  Load Json File As Dictionary  /opt/ute/reservation.context.json
#  ...  ELSE  Set Variable  &{EMPTY}
#  ${uuf_manual_initial_sw}=  Run Keyword If
#  ...  ${extended_reservation_file}
#  ...  Get Variable Value
#  ...  ${uuf_manual_initial_sw}
#  ...  default=${EMPTY}
#  ${uuf_manual_candidate_sw}=  Run Keyword If
#  ...  ${extended_reservation_file}
#  ...  Get Variable Value
#  ...  ${uuf_manual_candidate_sw}
#  ...  default=${EMPTY}
#
#  Set Suite Variable  ${EXTENDED_RESERVATION_DICT}  ${extended_reservation_dict}
#
#  ${CM_VARIANT}=  Get Variable Value  ${EXTENDED_RESERVATION_DICT['CM_ARTIFACTS']}  default=${CM_TOPOLOGY}
