*** Settings ***
Documentation  Setup and teardown actions
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    OperatingSystem
Library    BuiltIn
Library    String
Library    ute_admin_infomodel
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    taf.sw.wtssim    WITH NAME    wtssim
Library    taf.transport.ssh    WITH NAME    tafssh
Library    taf.rfrl.common_resources.python.reset_bts_configuration

#Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ./bts_actions.robot
Resource    ./bts_verification.robot
Resource    ./common_keywords.robot
Resource    ./variables.robot
Resource    ../../resources/reporting.robot
Resource    ../../resources/common_kw.robot
Resource    ../../resources/Robot/pdu.robot
Resource    ../../resources/Robot/tl_init.robot
Resource    ../../resources/Robot/swconfig.robot
Resource    ../../resources/Robot/common_kw.robot
Resource    ../../resources/Robot/logging.robot
Resource    ../../resources/Robot/faults.robot

*** Variables ***
${SAVEPOINT_ENB}
${SAVEPOINT_CUS}
${ENB_SW_RELEASE}
${NUMBER_OF_SMOD_UNIT}
${ACT_CATEGORY_ALARMS}
${SUITE_SETUP_PASSED}
${CA_ACTIVATED}
${TEST_CASE_TEMPLATE_COMMISSIONING}
${SETUP_TEMPLATE_COMMISSIONING}

*** Keywords ***
CUS Setup Test Set
    [Arguments]  ${scfc_default_file_path}  ${swconfig_file_path}=${SWCONFIG_FILE_PATH}  ${remove_radio_dhcpd}=${False}
    ...  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}  ${set_prefix}=${True}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Keyword prepares the test environment and hardware to start test cases.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_default_file_path | Yes  | Path to the default scfc file.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | swconfig_file_path     | Yes  | Path to the default swconfig file.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | remove_radio_dhcpd     | Yes  | Remove radios licenses (MAC)                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | logs_dir_path          | Yes  | Path to directory where logs file should be stored.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | set_prefix             |  No  | Set (or not) log prefix to message.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Message Colors
    Set Log Prefix  set_prefix=${set_prefix}
    Log  \n${start_prefix_blue}Suite Setup: CUS Setup Test Set  console=${log_to_console}
    Set Library Search Order  ute_admin_infomodel  admin
    Set Suite Variable  ${SUITE_SETUP_PASSED}  False
    Run Keyword And Ignore Error  admin.Teardown All Aliases For Admin
    Run Keyword And Ignore Error  tafssh.Reset Cache
    Teardown Egate And Edaemon Services
    Teardown All Aliases For Infomodel
    Kill Egate And Edaemon Processes
    Create Folders
    Set Folder Variables
    ${cfg}=  Create Dictionary
    Set Suite Variable  ${CFG}  ${cfg}
    ${bts_id_list}=  Create List  1
    ${enbs_dict}=  Create Dictionary
    Set To Dictionary  ${enbs_dict}  ${bts_id_list[0]}=&{EMPTY}
    Set To Dictionary  dictionary=${cfg}  NODES=&{enbs_dict}
    Set To Dictionary  dictionary=${cfg}  bts_id_list=@{bts_id_list}
# eNB and CUS Setup Section
    Log  ${dots_prefix_blue}Setup process (enb, cus, admin)  console=${log_to_console}
    ${ctrls_list}=  CUS Get Section Names List  cusini_file_path=${CUSINI_FILE_PATH}  section=ctrl
    ${list_of_cus_ips}=  CUS Create Ctrl Ip Addresses List
    ...  cusini_file_path=${CUSINI_FILE_PATH}  ctrl_list=${ctrls_list}
    Set Suite Variable  ${LIST_OF_IPHY_IPS}  ${list_of_cus_ips}
    Set Suite Variable  ${LIST_OF_CUS_IPS}  ${list_of_cus_ips}
    Set Suite Variable  ${FSM_CONNECTION}  fsm_default
    tafssh.Connect To
    ...  hostname=${ENB_IP_ADDR}
    ...  username=${ENB_SSH_USER}
    ...  password=${ENB_SSH_PASSWD}
    ...  port=${ENB_SSH_PORT}
    ...  alias=${FSM_CONNECTION}
    ...  timeout=30
    Setup CUS Fsm Access  list_of_cus_ips=${list_of_cus_ips}
    admin.Setup Admin  update_interval=1000  admin_api_log_dir=${logs_dir_path}
    ${sw_info}=  admin.Get Software Info  timeout=120
    ${enb_sw_release}=  Set Variable  ${sw_info['Active SW version']}
    Set To Dictionary  dictionary=${cfg}  cus_ip_list=${list_of_cus_ips}  enb_sw_release=${enb_sw_release}
    Log  ${ok_prefix_blue}Setup process (enb, cus, admin)  console=${log_to_console}
# SCFC Variables Section
    Check And Get SCFC If Big Config Exist
    Log  ${dots_prefix_blue}Setting up variables  console=${log_to_console}
    ${scfc_file_path}  ${scfc_file_name}=  SCFC Set File Path  scfc_default_file_path=${scfc_default_file_path}
    ...  enb_sw_release=${enb_sw_release}  log_prefix=${info_prefix}
    Set Suite Variable  ${SCFC_REFERENCE_FILE_PATH}  ${scfc_file_path}
    ${act_category_alarms}=  SCFC Get Category Alarms Parameter Value  scfc_file_path=${scfc_file_path}
    Set Suite Variable  ${ACT_CATEGORY_ALARMS}  ${act_category_alarms}
    ${number_of_smod_unit}=  SCFC Get SMOD Count  scfc_file_path=${scfc_file_path}
    Set Suite Variable  ${NUMBER_OF_SMOD_UNIT}  ${number_of_smod_unit}
    ${mrbts_id}=  SCFC Get MRBTS ID  scfc_file_path=${scfc_file_path}
    Set Global Variable  ${mrbts_id}
    ${act_dlcaggr_status}  ${act_ulcaggr_status}=  SCFC Get CA Activation Status  scfc_file_path=${scfc_file_path}
    Run Keyword If  ${act_dlcaggr_status} or ${act_ulcaggr_status}
    ...  Run Keywords  Variable Should Exist  ${CA_SUPPORTED_BANDS}
    ...  AND
    ...  Set Suite Variable  ${CA_ACTIVATED}  True
    ...  AND
    ...  Log  ${info_prefix}Carrier aggregation is activated. Supported bands: ${CA_SUPPORTED_BANDS}
    ...  console=${log_to_console}
    ...  ELSE
    ...  Set Suite Variable  ${CA_ACTIVATED}  False
    Set To Dictionary  dictionary=${cfg}  scf_file_path=${scfc_file_path}  smod_unit_count=${number_of_smod_unit}
    Log  ${ok_prefix_blue}Setting up variables  console=${log_to_console}
# Set CUS Dummy Interface
    Set 5G Dummy Interface  scfc_file_path=${scfc_file_path}
# Swconfig Update Section
    Log  ${dots_prefix_blue}Preparation of swconfig file for BTS  console=${log_to_console}
    Add Flags To Swconfig File  swconfig_file=${swconfig_file_path}  swconfig_flag_list=${SWCONFIG_FLAGS}
    ...  log_prefix=${info_prefix}
    ${active_partition_path}=  tafssh.Execute
    ...  command=readlink -f /ffs/run
    ...  connection=${fsm_connection}
    ${result_list}=  Get Regexp Matches  string=${active_partition_path}  pattern=\/ffs\/fs\\d
    ${active_partition_path}=  Set Variable  ${result_list[0]}
    ${output}=  tafssh.Upload File
    ...  local_path=${swconfig_file_path}
    ...  remote_path=${active_partition_path}/swconfig.txt
    ...  connection=${FSM_CONNECTION}
    Run Keyword If  ${number_of_smod_unit}==2
    ...  Put Swconfig File From Remote Host  swconfig_file_path=${swconfig_file_path}
    tafssh.Download File
    ...  remote_path=${active_partition_path}/swconfig.txt
    ...  local_path=${logs_dir_path}/swconfig.txt
    ...  connection=${FSM_CONNECTION}
    Log  ${ok_prefix_blue}Preparation of swconfig file for BTS  console=${log_to_console}
# SYSLOG Setup Section
    Log  ${dots_prefix_blue}Setup and start syslog (enb, cus)  console=${log_to_console}
    Start Enb Syslog  logs_dir_path=${logs_dir_path}
    ${savepoint_enb}=  Capture Enb Syslog Savepoint
    Set Suite Variable  ${SAVEPOINT_ENB}  ${savepoint_enb}
    Start Syslog For All CUS  list_of_cus_ips=${list_of_cus_ips}  logs_dir_path=${logs_dir_path}
    ${savepoint_cus}=  Capture CUS Syslog Savepoint  list_of_cus_ips=${list_of_cus_ips}
    Set Suite Variable  ${SAVEPOINT_CUS}  ${savepoint_cus}
    Log  ${ok_prefix_blue}Setup and start syslog (enb, cus)  console=${log_to_console}
# InfoModel BTS Reset Configuration Setup Section
    Log  ${dots_prefix_blue}Setup and connect to infomodel before reset configuration  console=${log_to_console}
    Setup Infomodel  address=${ENB_IP_ADDR}  port=443  use_ssl=True
    Connect Infomodel  timeout=180
    Log  ${ok_prefix_blue}Setup and connect to infomodel before reset configuration  console=${log_to_console}
# PDU Prepare Hardware Setup
    PDU Prepare SMOD Setup  number_of_smod_units=${number_of_smod_unit}
    PDU Prepare CUS Setup  list_of_cus_ips=${list_of_cus_ips}
    BTS Is Available
    CUS Is Available  list_of_cus_ips=${list_of_cus_ips}
    Log  ${ok_prefix_blue}Testline preparing  console=${log_to_console}
# BTS FDSW Software Update Section
    Log  ${dots_prefix_blue}FDSW software update  console=${log_to_console}
    ${fdsw_version}=  Create List  FDSW24D  FDSW25A  FDSW25B  FDSW25C  FDSW26A
    ${fdsw_version_status}    ${current_version}=  FDSW Get Software Version Status  fdsw_version=${fdsw_version}
    Run Keyword If  ${fdsw_version_status} or ${number_of_smod_unit}==2
    ...  Log  ${info_prefix}FDSW software version is "${current_version[0]}" - FDSW software update is not needed
    ...  console=${log_to_console}
    ...  ELSE
    ...  FDSW Software Update  yaft_local_dir=/home/ute/yaft_latest  log_prefix=${info_prefix}
    Log  ${ok_prefix_blue}FDSW software update  console=${log_to_console}
# BTS Reset Configuration Setup Section
    Log  ${dots_prefix_blue}Reset configuration  console=${log_to_console}
#    Reset Configuration  remove_site_id=True  remove_security_credentials=False  timeout=600
# CB007500:BTS Configuration Reset by D&RSW
    ${local_host_parameters}=  Get Host Parameters From Init File  host_index=1
    ${remote_host_parameters}=  Get Host Parameters From Init File  host_index=2
    Set To Dictionary  dictionary=${cfg}  tl_local_host=${local_host_parameters['ip_addr']}
    ...  tl_remote_host=${remote_host_parameters['ip_addr']}
    Log  ${info_prefix}Local host IP address: ${local_host_parameters['ip_addr']}  console=${log_to_console}
    Log  ${info_prefix}Remote host IP address: ${remote_host_parameters['ip_addr']}  console=${log_to_console}
    Reset Bts Configuration  timeout=600  secondary_remote_host=${remote_host_parameters['ip_addr']}
    Log  ${ok_prefix_blue}Reset configuration  console=${log_to_console}
    Log  ${dots_prefix_blue}Availability of BTS and CUS after reset configuration  console=${log_to_console}
# Power off secondary SMOD
    ${smod_init_number}=  Get System Module Number From Init File
    Run Keyword If  ${number_of_smod_unit}==1 and ${smod_init_number}==2
    ...  PDU Turn Off SMOD  smod_index=2
    BTS Enable Connection
    BTS And CUS Are Accessible  list_of_cus_ips=${list_of_cus_ips}
    Admin BTS Should Be NotCommissioned  log_prefix=${info_prefix}
    Run Keyword If  ${number_of_smod_unit}==2  BTS Start Data Sync With Neighbor Node
    Log  ${ok_prefix_blue}Availability of BTS and CUS after reset configuration  console=${log_to_console}
    Save Infomodel Log  filename=${logs_dir_path}/IM_infomodel_configuration_reset.ims2
    Teardown Infomodel
    Log  ${ok_prefix_blue}Setup and connect to infomodel after reset configuration  console=${log_to_console}
    ${alarm_list}=  Ims2 Get Alarm List  ims2_file_path=${logs_dir_path}/IM_infomodel_configuration_reset.ims2
    ...  act_category_alarms=${act_category_alarms}
    Run Keyword And Ignore Error  Admin Check Active Alarms
    ...  allowed_alarms=${ALLOWED_ALARMS}  active_alarms=${alarm_list}
    Log  ${ok_prefix_blue}Check active alarms after reset configuration  console=${log_to_console}
# Remove radio DHCPD Section
    Run Keyword If  '${remove_radio_dhcpd}'=='True'  BTS Remove Radios Licenses  console=${log_to_console}
# Setup InfoModel Log Session
    Log  ${dots_prefix_blue}Setup and connect to infomodel  console=${log_to_console}
    Setup Infomodel  address=${ENB_IP_ADDR}  port=443  use_ssl=True
    Connect Infomodel  timeout=180
    Log  ${ok_prefix_blue}Setup and connect to infomodel  console=${log_to_console}
# Variable Section
    Set Suite Variable  ${TEST_CASE_TEMPLATE_COMMISSIONING}  False
    Set Suite Variable  ${SETUP_TEMPLATE_COMMISSIONING}  False
    Set Suite Variable  ${SUITE_SETUP_PASSED}  True
    Run Keyword And Ignore Error  Admin Get Gps Status
    Log  ${done_prefix_blue}Suite Setup: CUS Setup Test Set\n  console=${log_to_console}

CUS Setup Test Set Without Reset Configuration
    [Arguments]  ${scfc_default_file_path}  ${swconfig_file_path}=${SWCONFIG_FILE_PATH}
    ...  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}  ${set_prefix}=${True}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Keyword prepares configuration without reset configuration.
    ...  BTS must be commissioned.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_default_file_path | Yes  | Path to the default scfc file.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | swconfig_file_path     | Yes  | Path to the default swconfig file.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_path_dir           | Yes  | Path to the default swconfig file.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | set_prefix             |  No  | Set (or not) log prefix to message.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Message Colors
    Set Log Prefix  set_prefix=${set_prefix}
    Log  \n${start_prefix_blue}Suite Setup: CUS Setup Test Set Without Reset Configuration  console=${log_to_console}
    Set Library Search Order  ute_admin_infomodel  admin
    Set Suite Variable  ${SUITE_SETUP_PASSED}  False
    Run Keyword And Ignore Error  admin.Teardown All Aliases For Admin
    Run Keyword And Ignore Error  tafssh.Reset Cache
    Teardown Egate And Edaemon Services
    Teardown All Aliases For Infomodel
    Kill Egate And Edaemon Processes
    Create Folders
    Set Folder Variables
    ${cfg}=  Create Dictionary
    Set Suite Variable  ${CFG}  ${cfg}
    ${bts_id_list}=  Create List  1
    ${enbs_dict}=  Create Dictionary
    Set To Dictionary  ${enbs_dict}  ${bts_id_list[0]}=&{EMPTY}
    Set To Dictionary  dictionary=${cfg}  NODES=&{enbs_dict}
    Set To Dictionary  dictionary=${cfg}  bts_id_list=@{bts_id_list}
# ENB and CUS Setup Section
    Log  ${dots_prefix_blue}Setup process (enb, cus, admin)  console=${log_to_console}
    ${ctrls_list}=  CUS Get Section Names List  cusini_file_path=${CUSINI_FILE_PATH}  section=ctrl
    ${list_of_cus_ips}=  CUS Create Ctrl Ip Addresses List
    ...  cusini_file_path=${CUSINI_FILE_PATH}  ctrl_list=${ctrls_list}
    Set Suite Variable  ${LIST_OF_IPHY_IPS}  ${list_of_cus_ips}
    Set Suite Variable  ${LIST_OF_CUS_IPS}  ${list_of_cus_ips}
    Set Suite Variable  ${FSM_CONNECTION}  fsm_default
    tafssh.Connect To
    ...  hostname=${ENB_IP_ADDR}
    ...  username=${ENB_SSH_USER}
    ...  password=${ENB_SSH_PASSWD}
    ...  port=${ENB_SSH_PORT}
    ...  alias=${FSM_CONNECTION}
    ...  timeout=30
    Setup CUS Fsm Access  list_of_cus_ips=${list_of_cus_ips}
    admin.Setup Admin  update_interval=1000  admin_api_log_dir=${logs_dir_path}
    ${sw_info}=  admin.Get Software Info  timeout=120
    ${enb_sw_release}=  Set Variable  ${sw_info['Active SW version']}
    Set To Dictionary  dictionary=${cfg}  cus_ip_list=${list_of_cus_ips}  enb_sw_release=${enb_sw_release}
    Log  ${ok_prefix_blue}Setup process (enb, cus, admin)  console=${log_to_console}
# CUS Get Config File Section
#    CUS Get Wts Config Files  ${list_of_cus_ips}  ${SUITE_LOGS_DIR_PATH}
# SCFC Variables Section
    Check And Get SCFC If Big Config Exist
    Log  ${dots_prefix_blue}Setting up variables  console=${log_to_console}
    ${scfc_file_path}  ${scfc_file_name}=  SCFC Set File Path  scfc_default_file_path=${scfc_default_file_path}
    ...  enb_sw_release=${enb_sw_release}  log_prefix=${info_prefix}
    Set Suite Variable  ${SCFC_REFERENCE_FILE_PATH}  ${scfc_file_path}
    ${act_category_alarms}=  SCFC Get Category Alarms Parameter Value  ${scfc_file_path}
    Set Suite Variable  ${ACT_CATEGORY_ALARMS}  ${act_category_alarms}
    ${number_of_smod_unit}=  SCFC Get SMOD Count  scfc_file_path=${scfc_file_path}
    Set Suite Variable  ${NUMBER_OF_SMOD_UNIT}  ${number_of_smod_unit}
    ${mrbts_id}=  SCFC Get MRBTS ID  scfc_file_path=${scfc_file_path}
    Set Global Variable  ${mrbts_id}
    ${act_dlcaggr_status}  ${act_ulcaggr_status}=  SCFC Get CA Activation Status  scfc_file_path=${scfc_file_path}
    Run Keyword If  ${act_dlcaggr_status} or ${act_ulcaggr_status}
    ...  Run Keywords  Variable Should Exist  ${CA_SUPPORTED_BANDS}
    ...  AND
    ...  Set Suite Variable  ${CA_ACTIVATED}  True
    ...  AND
    ...  Log  ${info_prefix}Carrier aggregation is activated. Supported bands: ${CA_SUPPORTED_BANDS}
    ...  console=${log_to_console}
    ...  ELSE
    ...  Set Suite Variable  ${CA_ACTIVATED}  False
    Set To Dictionary  dictionary=${cfg}  scf_file_path=${scfc_file_path}  smod_unit_count=${number_of_smod_unit}
    Log  ${ok_prefix_blue}Setting up variables  console=${log_to_console}
# Host IP Section
    ${local_host_parameters}=  Get Host Parameters From Init File  host_index=1
    ${remote_host_parameters}=  Get Host Parameters From Init File  host_index=2
    Set To Dictionary  dictionary=${cfg}  tl_local_host=${local_host_parameters['ip_addr']}
    ...  tl_remote_host=${remote_host_parameters['ip_addr']}
    Log  ${info_prefix}Local host IP address: ${local_host_parameters['ip_addr']}  console=${log_to_console}
    Log  ${info_prefix}Remote host IP address: ${remote_host_parameters['ip_addr']}  console=${log_to_console}
# Set CUS Dummy Interface
    Set 5G Dummy Interface  scfc_file_path=${scfc_file_path}
# Swconfig Update Section
    Log  ${dots_prefix_blue}Preparation of swconfig file for CUS and BTS  console=${log_to_console}
    Add Flags To Swconfig File  swconfig_file=${swconfig_file_path}  swconfig_flag_list=${SWCONFIG_FLAGS}
    ...  log_prefix=${info_prefix}
    ${active_partition_path}=  tafssh.Execute
    ...  command=readlink -f /ffs/run
    ...  connection=${fsm_connection}
    ${result_list}=  Get Regexp Matches  string=${active_partition_path}  pattern=\/ffs\/fs\\d
    ${active_partition_path}=  Set Variable  ${result_list[0]}
    ${output}=  tafssh.Upload File
    ...  local_path=${swconfig_file_path}
    ...  remote_path=${active_partition_path}/swconfig.txt
    ...  connection=${FSM_CONNECTION}
    Run Keyword If  ${number_of_smod_unit}==2
    ...  Put Swconfig File From Remote Host  swconfig_file_path=${swconfig_file_path}
    tafssh.Download File
    ...  remote_path=${active_partition_path}/swconfig.txt
    ...  local_path=${logs_dir_path}/swconfig.txt
    ...  connection=${FSM_CONNECTION}
    Log  ${ok_prefix_blue}Preparation of swconfig file for CUS and BTS  console=${log_to_console}
    ${smod_init_number}=  Get System Module Number From Init File
    Run Keyword If  ${number_of_smod_unit}==1 and ${smod_init_number}==2
    ...  PDU Turn Off SMOD  smod_index=2
# SYSLOG Setup Section
    Log  ${dots_prefix_blue}Setup and start syslog (enb, cus)  console=${log_to_console}
    Start Enb Syslog  logs_dir_path=${logs_dir_path}
    ${savepoint_enb}=  Capture Enb Syslog Savepoint
    Set Suite Variable  ${SAVEPOINT_ENB}  ${savepoint_enb}
    Start Syslog For All CUS  list_of_cus_ips=${list_of_cus_ips}  logs_dir_path=${logs_dir_path}
    ${savepoint_cus}=  Capture CUS Syslog Savepoint  list_of_cus_ips=${list_of_cus_ips}
    Set Suite Variable  ${SAVEPOINT_CUS}  ${savepoint_cus}
    Log  ${ok_prefix_blue}Setup and start syslog (enb, cus)  console=${log_to_console}
# Setup InfoModel Log Session
    Log  ${dots_prefix_blue}Setup and connect to infomodel  console=${log_to_console}
    Setup Infomodel  address=${ENB_IP_ADDR}  port=443  use_ssl=True
    Connect Infomodel  timeout=180
    Log  ${ok_prefix_blue}Setup and connect to infomodel  console=${log_to_console}
# Variable Section
    ${uuf}=  Run Keyword And Return Status  Variable Should Exist  ${UPDATE_TEST_ITERATION}
    ${outdoor_smod}=  Run Keyword And Return Status  admin.Assert No  class_name=BBMOD
    ...  parameters=operationalState=regex".*"  timeout=60
    Run Keyword If  ${uuf}
    ...  Set Suite Variable  ${TEST_CASE_TEMPLATE_COMMISSIONING}  False
    ...  ELSE IF  ${outdoor_smod}
    ...  Set Suite Variable  ${TEST_CASE_TEMPLATE_COMMISSIONING}  False
    ...  ELSE
    ...  Set Suite Variable  ${TEST_CASE_TEMPLATE_COMMISSIONING}  True
    Set Suite Variable  ${SETUP_TEMPLATE_COMMISSIONING}  True
    Set Suite Variable  ${SUITE_SETUP_PASSED}  True
    Run Keyword And Ignore Error  Admin Get Gps Status
    Log  ${done_prefix_blue}Suite Setup: CUS Setup Test Set Without Reset Configuration\n  console=${log_to_console}

CUS Setup Test Case
    [Documentation]
    ...  Description:
    ...  Keyword prepares the test environment and hardware to start test case.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${host_parameters}=  Get Host Parameters From Init File  host_index=1
    Run Keyword And Ignore Error  Start Testline Scout Monitor  host_vm_ip=${host_parameters['ip_addr']}

CUS Setup UUF
    [Documentation]
    ...  Description:
    ...  Keyword prepares the test environment to start UUF test cases.
    ...
    ...  Author: jakub.pachana@nokia.com
    ...  Maintainer: jakub.pachana@nokia.com

    CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    Run Keyword And Ignore Error
    ...  Stop Enb Syslog
    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}
    Run Keyword And Ignore Error  admin.Teardown All Aliases For Admin

Setup Egate And Edaemon Services
    [Documentation]
    ...  Description:
    ...  Keyword sets WTSSIM library to work with egate and edaemon.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    wtssim.Setup Egate  egate_port=20000
    wtssim.Setup Edaemon  edaemon_port=10000  alias=edaemon
    wtssim.Link Edaemons To Egate  edaemon

Setup CUS Fsm Access
    [Arguments]  ${list_of_cus_ips}
    [Documentation]
    ...  Description:
    ...  Keyword prepare ssh connection to all WTS FSM.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP addresses.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------++
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${cus_ip}  IN  @{list_of_cus_ips}
      tafssh.Connect To
      ...  hostname=${cus_ip}
      ...  username=${ENB_SSH_USER}
      ...  password=${ENB_SSH_PASSWD}
      ...  port=${ENB_SSH_PORT}
      ...  alias=${cus_ip}
      ...  timeout=30
    END

CUS Teardown Test Case
    [Arguments]  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}  ${teardown_allowed_alarms}=${ALLOWED_ALARMS}
    ...  ${run_index}=1  ${list_of_cus_ips}=${LIST_OF_CUS_IPS}  ${act_category_alarms}=${ACT_CATEGORY_ALARMS}
    ...  ${collect_test_case_syslog}=True  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Teardown section for test case.
    ...
    ...  Arguments:
    ...  +==========================+======+==========================================================================+
    ...  | Argument                 | Man. | Description                                                              |
    ...  +==========================+======+==========================================================================+
    ...  | logs_dir_path            | Yes  | Path to directory where logs files should be stored.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | teardown_allowed_alarms  | Yes  | List of allowed alarms in teardown section.                              |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | run_index                | Yes  | Number of test case executioms.                                          |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | list_of_cus_ips          | Yes  | List of CUS IP addresses.                                                |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | act_category_alarms      | Yes  | Information about type of alarms reported by the BTS.                    |
    ...  |                          |      | "True" means that new category alarms are raised.                        |
    ...  |                          |      | "False" means that legacy alarms are raised.                             |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | collect_test_case_syslog |  No  | Collect syslog file separately for each test or not.                     |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...  | log_to_console           |  No  | Logs the given message to console.                                       |
    ...  +--------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n${start_prefix_blue}Test Case Teardown: CUS Teardown Test Case (run ${run_index})
    ...  console=${log_to_console}
    ${teardown_allowed_alarms}=  Run Keyword If  ${SETUP_TEMPLATE_COMMISSIONING}==True
    ...  Combine Lists  ${ALLOWED_ALARMS}  ${teardown_allowed_alarms}
    ...  ELSE
    ...  Create List  @{teardown_allowed_alarms}
    ${teardown_allowed_alarms}=  Remove Duplicates  ${teardown_allowed_alarms}
    BTS Collect Hardware Information
    Log  ${dots_prefix_blue}QC mapping  console=${log_to_console}
    ${uuf}=  Run Keyword And Return Status  Variable Should Exist  ${UPDATE_TEST_ITERATION}
    IF  ${uuf}
      ${sw_info}=  admin.Get Software Info  timeout=120
      ${enb_sw_release}=  Set Variable  ${sw_info['Active SW version']}
    END
# Test case QC mapping
    ${test_case_name}=  Test Case QC Mapping  sw_version=${CFG.enb_sw_release}
    Log  ${info_prefix}Test case will be mapped as "${test_case_name}"  console=${log_to_console}
    Log  ${ok_prefix_blue}QC mapping  console=${log_to_console}
    ${host_parameters}=  Get Host Parameters From Init File  host_index=1
    Run Keyword And Ignore Error  Request Configuration ID from Scout  host_vm_ip=${host_parameters['ip_addr']}
#    Run Keyword And Ignore Error  Stop Testline Scout Monitor  host_vm_ip=${host_parameters['ip_addr']}
# File and directory operations
    Create Directory  path=${logs_dir_path}/${TEST NAME}/test_run_${run_index}
    Run Keyword And Ignore Error  Move Directory
    ...  source=${logs_dir_path}/${TEST_NAME}/attach
    ...  destination=${logs_dir_path}/${TEST NAME}/test_run_${run_index}
    Run Keyword And Ignore Error  Move Directory
    ...  source=${logs_dir_path}/${TEST NAME}/detach
    ...  destination=${logs_dir_path}/${TEST NAME}/test_run_${run_index}
#    Run Keyword And Ignore Error  Move Files
#    ...  ${logs_dir_path}/${TEST NAME}/*.json
#    ...  ${logs_dir_path}/${TEST NAME}/test_run_${run_index}
    Log  ${ok_prefix_blue}Initial settings  console=${log_to_console}
# Radio modules detection
    Log  ${dots_prefix_blue}Quick RMODs detection  console=${log_to_console}
    Run Keyword And Continue On Failure
    ...  Radio Modules Detection  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  timeout=5  log_to_console=False  log_prefix=${info_prefix}
    Log  ${ok_prefix_blue}Quick RMODs detection  console=${log_to_console}
# Collect other logs
    Run Keyword And Ignore Error  wtssim.Execute Egate Command  cmd=${cmd5}
    Run Keyword And Ignore Error  Collect Egate Logs
    ...  logs_dir_path=${logs_dir_path}/${TEST NAME}/test_run_${run_index}
    Run Keyword And Ignore Error  Collect CUS Startup Log
    ...  logs_dir_path=${logs_dir_path}/${TEST NAME}/test_run_${run_index}
    ...  list_of_cus_ips=${list_of_cus_ips}
    Run Keyword And Ignore Error  Collect SOAP Logs
    ...  logs_dir_path=${logs_dir_path}/${TEST NAME}/test_run_${run_index}
    ...  list_of_cus_ips=${list_of_cus_ips}
    Log  ${ok_prefix_blue}Collect logs  console=${log_to_console}
# Collect snapshot
    Log  ${dots_prefix_blue}Collect snapshot  console=${log_to_console}
    Collect Snapshot File  logs_dir_path=${logs_dir_path}/${TEST NAME}/test_run_${run_index}
    Log  ${ok_prefix_blue}Collect snapshot  console=${log_to_console}
# Collect InfoModel logs and alarms check
    Save Infomodel Log  filename=${logs_dir_path}/${TEST NAME}/test_run_${run_index}/IM_infomodel.ims2
    ...  timeout=180
    ${alarm_list}=  Ims2 Get Alarm List
    ...  ims2_file_path=${logs_dir_path}/${TEST NAME}/test_run_${run_index}/IM_infomodel.ims2
    ...  act_category_alarms=${act_category_alarms}
    Admin Check Active Alarms  allowed_alarms=${teardown_allowed_alarms}  active_alarms=${alarm_list}
    Log  ${ok_prefix_blue}Collect infomodel ims file and checking alarms  console=${log_to_console}
# Setup new InfoModel log session
    Perform Reconnect InfoModel
    Log  ${ok_prefix_blue}Reconnect infomodel  console=${log_to_console}
# Collect syslog
    Log  ${dots_prefix_blue}Collect syslog file  console=${log_to_console}
    Collect CUS2 Mplane Log
    ...  logs_dir_path=${logs_dir_path}/${TEST NAME}/test_run_${run_index}
    IF  ${collect_test_case_syslog}
      ${savepoint_enb}=  Collect And Capture Enb Syslog
      ...  savepoint_enb=${SAVEPOINT_ENB}
      ...  logs_dir_path=${logs_dir_path}/${TEST NAME}/test_run_${run_index}
      ${savepoint_cus}=  Collect And Capture CUS Syslog
      ...  savepoint_cus=${SAVEPOINT_CUS}
      ...  logs_dir_path=${logs_dir_path}/${TEST NAME}/test_run_${run_index}
      ...  list_of_cus_ips=${list_of_cus_ips}
    END
    Set Suite Variable  ${SAVEPOINT_ENB}  ${savepoint_enb}
    Set Suite Variable  ${SAVEPOINT_CUS}  ${savepoint_cus}
    Log  ${ok_prefix_blue}Collect syslog file  console=${log_to_console}
# Truck Roll checking
#    Log  ${dots_prefix_blue}Truck Roll Checking  console=${log_to_console}
#    ${bts_id}=  Set Variable  ${CFG.bts_id_list[0]}
#    Truck Roll Checking  host_ip_addr=${CFG.tl_local_host}
#    ...  bts_id_list=${CFG.bts_id_list}
#    ...  smod_list=${CFG.NODES['${bts_id}']['hw_smod_list']}
#    ...  bbmod_list=${CFG.NODES['${bts_id}']['hw_bbmod_list']}
#    ...  rmod_list=${CFG.NODES['${bts_id}']['hw_rmod_list']}
#    Log  ${ok_prefix_blue}Truck Roll Checking  console=${log_to_console}
#    Run Keyword And Ignore Error  Common Step Trigger
    Log  ${done_prefix_blue}Test Case Teardown: CUS Teardown Test Case (run ${run_index})\n
    ...  console=${log_to_console}

CUS Teardown Test Set
    [Arguments]  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}  ${list_of_cus_ips}=${LIST_OF_CUS_IPS}
    ...  ${collect_test_suite_syslog}=${True}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Teardown section for test suite.
    ...
    ...  Arguments:
    ...  +============================+======+=======================================================================+
    ...  | Argument                  | Man. | Description                                                            |
    ...  +===========================+======+=========================================================================+
    ...  | logs_dir_path             | Yes  | Path to directory where logs files should be stored.                    |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...  | list_of_cus_ips           | Yes  | List of CUS IP addresses.                                               |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...  | collect_test_suite_syslog |  No  | Collect syslog file from all test cases (test suite scope) or not.      |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...  | log_to_console            |  No  | Logs the given message to console.                                      |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n${start_prefix_blue}Test Suite Teardown: CUS Teardown Test Set  console=${log_to_console}
    IF  not ${SUITE_SETUP_PASSED}
      Log  ${dots_prefix_blue}Collect snapshot  console=${log_to_console}
      Collect Snapshot File  logs_dir_path=${logs_dir_path}  file_name=suite_setup_snapshot.zip
      Log  ${ok_prefix_blue}Collect snapshot  console=${log_to_console}
    END
    Teardown Syslog And Infomodel
    ...  logs_dir_path=${logs_dir_path}
    ...  list_of_cus_ips=${list_of_cus_ips}
    ...  collect_test_suite_syslog=${collect_test_suite_syslog}
    Run Keyword And Ignore Error  admin.Teardown All Aliases For Admin
    Run Keyword And Ignore Error  tafssh.Disconnect  connection=${FSM_CONNECTION}
    Teardown Wts Services  list_of_cus_ips=${list_of_cus_ips}
    Teardown Egate And Edaemon Services
    Log  ${ok_prefix_blue}Teardown all services  console=${log_to_console}
    Collect Tgr Logs  logs_dir_path=${logs_dir_path}
    Teardown Copy And Move Files  logs_dir_path=${logs_dir_path}
    Log  ${ok_prefix_blue}Coping and moving files  console=${log_to_console}
    Log  ${CFG}
    Log  ${done_prefix_blue}Test Suite Teardown: CUS Teardown Test Set\n  console=${log_to_console}

Teardown BTS Power Reset
    [Arguments]  ${list_of_cus_ips}  ${reset_index}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword collects single reset loop logs.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP addresses.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | reset_index            | Yes  | Numer of reset.                                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  ${dots_prefix_green}Collect single loop logs  console=${log_to_console}
    Create Directory  path=${SUITE_LOGS_DIR_PATH}/${TEST NAME}/power_reset_loop_${reset_index}
    Collect CUS Startup Log
    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}/${TEST NAME}/power_reset_loop_${reset_index}
    ...  list_of_cus_ips=${list_of_cus_ips}
    Run Keyword And Ignore Error  Collect SOAP Logs
    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}/${TEST NAME}/power_reset_loop_${reset_index}
    ...  list_of_cus_ips=${list_of_cus_ips}
#Collect Infomodel Logs
    Save Infomodel Log
    ...  filename=${SUITE_LOGS_DIR_PATH}/${TEST NAME}/power_reset_loop_${reset_index}/IM_infomodel.ims2
    Perform Reconnect InfoModel
#Collect Snapshot
    Collect Snapshot File  logs_dir_path=${SUITE_LOGS_DIR_PATH}/${TEST NAME}/power_reset_loop_${reset_index}
#Collect Syslog
    Collect Enb Syslog From Savepoint  savepoint_enb=${SAVEPOINT_ENB_RESET}
    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}/${TEST NAME}/power_reset_loop_${reset_index}
    ${savepoint_enb_reset}=  Capture Enb Syslog Savepoint
    Set Suite Variable  ${SAVEPOINT_ENB_RESET}  ${savepoint_enb_reset}
    Collect CUS Syslog From Savepoint  savepoint_dict=${SAVEPOINT_CUS_RESET}
    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}/${TEST NAME}/power_reset_loop_${reset_index}
    ...  list_of_cus_ips=${list_of_cus_ips}
    ${savepoint_cus_reset}=  Capture CUS Syslog Savepoint  list_of_cus_ips=${list_of_cus_ips}
    Set Suite Variable  ${SAVEPOINT_CUS_RESET}  ${savepoint_cus_reset}
    Log  ${ok_prefix_green}Collect single loop logs  console=${log_to_console}
#Check whether 4592 is active
    ${alarm_result}=  Run Keyword And Return Status  Assert Alarm Active  faultId=4592  timeout=60
    Run Keyword If  ${alarm_result}==True  Sleep  35

CUS Teardown UUF
    [Documentation]
    ...  Description:
    ...  Teardown section for UUF test cases.
    ...
    ...  Author: jakub.pachana@nokia.com
    ...  Maintainer: jakub.pachana@nokia.com

    admin.Setup Admin  update_interval=1000  admin_api_log_dir=${SUITE_LOGS_DIR_PATH}
    Admin Get BTS Software Version
    Test Case QC Mapping  sw_version=${enb_sw_release}

Teardown GSM/WCDMA Rat Reset
    [Arguments]  ${rat_type}  ${log_to_console}=True
    Admin Check Inactive FaultId Alarms  6202  6150
    Admin Get And Check Active Alarms  allowed_alarms=${allowed_alarms}
    Log  ${ok_prefix_green}Checking active alarms  console=${log_to_console}
    Log  ${info_prefix}${rat_type} has no hard reset scenario, stopping here.  console=${log_to_console}
    Log  ${done_prefix_green}Test Case: CUS ${rat_type} Rat Reset\n  console=${log_to_console}

Teardown Syslog And Infomodel
    [Arguments]  ${logs_dir_path}  ${list_of_cus_ips}  ${collect_test_suite_syslog}=${True}
    [Documentation]
    ...  Description:
    ...  Keyword waits 30 seconds if test failed to collect syslog and Infomodel logs.
    ...
    ...  Arguments:
    ...  +===========================+======+=========================================================================+
    ...  | Argument                  | Man. | Description                                                             |
    ...  +===========================+======+=========================================================================+
    ...  | logs_dir_path             | Yes  | Path to directory where logs files should be stored.                    |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...  | list_of_cus_ips           | Yes  | List of CUS IP addresses.                                               |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...  | collect_test_suite_syslog |  No  | Collect syslog file from all test cases (test suite scope) or not.      |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    IF  '${PREV TEST STATUS}'=='FAIL'  Sleep  30
    Info Model Save Logs And Teardown  logs_dir_path=${logs_dir_path}
    ${uuf}=  Run Keyword And Return Status  Variable Should Exist  ${UPDATE_TEST_ITERATION}
    IF  ${collect_test_suite_syslog} and ${uuf}
      Stop CUS Syslog  list_of_cus_ips=${list_of_cus_ips}  logs_dir_path=${logs_dir_path}
    ELSE IF  ${collect_test_suite_syslog}
      Stop Enb Syslog  logs_dir_path=${logs_dir_path}
      Stop CUS Syslog  list_of_cus_ips=${list_of_cus_ips}  logs_dir_path=${logs_dir_path}
    END

Teardown Wts Services
    [Arguments]  ${list_of_cus_ips}
    [Documentation]
    ...  Description:
    ...  Keyword closes and removes all SSH session connections.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP addresses.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------++
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${cus_ip}  IN  @{list_of_cus_ips}
      Run Keyword And Ignore Error  tafssh.Disconnect  connection=${cus_ip}
    END

Teardown Egate And Edaemon Services
    [Documentation]
    ...  Description:
    ...  Keyword stops and removes connection of egate and edaemon.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword And Ignore Error  wtssim.Teardown Egate
    Run Keyword And Ignore Error  wtssim.Teardown Edaemon  alias=edaemon

Kill Egate And Edaemon Processes
    [Documentation]
    ...  Description:
    ...  Keyword kills egate and daemon processes.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword And Ignore Error  Run  sudo killall edaemon egate

Teardown Copy And Move Files
    [Arguments]  ${logs_dir_path}
    [Documentation]
    ...  Description:
    ...  Keyword copies and moves log and backup files.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | logs_dir_path          | Yes  | Path to directory where files are stored.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword And Ignore Error  Remove Directory  path=${TEMP_PATH}  recursive=True
    Run Keyword And Ignore Error  Copy Files  ${CONFIG_DIR}/*lua                 ${BACKUP_PATH}/
    Run Keyword And Ignore Error  Copy Files  ${CUSINI_FILE_PATH}                ${BACKUP_PATH}/
    Run Keyword And Ignore Error  Move Files  ${logs_dir_path}/*swconfig*        ${BACKUP_PATH}/
    Run Keyword And Ignore Error  Move Files  ${logs_dir_path}/*SCFC*            ${BACKUP_PATH}/
    Run Keyword And Ignore Error  Move Files  ${logs_dir_path}/*syslog*.tar.gz   ${GENERAL_PATH}/
    Run Keyword And Ignore Error  Move Files  ${logs_dir_path}/*snapshot.zip     ${GENERAL_PATH}/
    Run Keyword And Ignore Error  Move Files  ${logs_dir_path}/*infomodel*       ${GENERAL_PATH}/
    Run Keyword And Ignore Error  Move Files  ${logs_dir_path}/*tshark*          ${REMAINING_PATH}/
    Run Keyword And Ignore Error  Move Files  ${logs_dir_path}/*admin_api*       ${REMAINING_PATH}/
    Run Keyword And Ignore Error  Move Files  ${logs_dir_path}/etgr_logs.tar.gz  ${REMAINING_PATH}/
    Run Keyword And Ignore Error  Move Files  ${logs_dir_path}/erl_logs.tar.gz   ${REMAINING_PATH}/
