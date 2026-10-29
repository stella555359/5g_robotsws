*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS
...  This file contains main setup keywords related to SISO SRAN setup. It allows to execute testcases in multiple BTS environment in
...  any RAT technology with multi configuration in one suite. Setup itself can be run in regular regression way when it use init file
...  and config.yml to gather information related to tested configuration.
...  Type of setup is choose by providing configuration name with proper format in Setup section in testcase constructor, eg:
...
...  [1][0.1] Testcase
...   [Tags]  Siso SRAN Site Reset
...   [Setup]  Run Keywords
...   Configuration Precondition  CN=REF_10_16_UTESRANSISO095_DEFAULT    N=20
...   ...  AND  Set Test Variable  ${EXAMPLE_USER_TC_VARIABLE}     4567
...   ...  AND  Set Test Variable  ${EXAMPLE_USER_TC_VARIABLE_2}     4567
...   Main Testcase Keyword
...   [Teardown]    Run Keywords
...   ...  Configuration Postcondition  status=${TEST_STATUS}
...   ...  AND  Recover Testline
...
...  When CN - Configuration Name variable starts with REF_  it means that setup is running using variant information
...  taken from topology config repository. User do not have to prepare any other information except variant to use.
...  Name of variant is provided after REF word, eg: REF_10_16_UTESRANSISO095_DEFAULT,
...  here 10_16_UTESRANSISO095_DEFAULT is variant name.
...
...  When CN - starts with MANUAL_ it means that setup will use manual provided Configuration scf files by user. It is control by those variables:
...  ${CUSTOM_MANUAL_MODE_SCF_PATH}=   /home/ute/scf_files/  path to directory with scf files
...  &{MANUAL_SCFC_BTS_FILE_NAME}=  ADDITIONAL_NODES_LIST=SECOND_BTS_FILE_NAME,THIRD_BTS_FILE_NAME
...    SCFC_BTS_FILE_NAME is name of scf file of primary configuration, in case of multi BTS configuration.
...    Whole variable name: MANUAL_SCFC_BTS_FILE_NAME  is use as a configuration name and provided in CN key in setup section.
...    ADDITIONAL_NODES_LIST   key with additional nodes list, it contains names of additioanl scf files for each BTS
...  It is used only when working with multiple configurations ( NSA 4G+5G, 8xLTE in Hotel configuration).
...  by &{MANUAL_FIRST} variable, it contains dict items in format    dictionary with additional configs provided
...
...  &{SM_VM_IP_ADDRESS_DICT}=  L883212304=10.44.55.66  L4567456=10.44.55.77  L9876456=10.44.55.88
...  dictionary describes relation SM - IP, also for secondary sm in dualcore, "System module serial number" = "IP of VM with LMP port"
...  use in manual and live mode,
...  When there is no CN provided or CN=live, setup wil run in direct mode when there is no reference file configuration available.
...  In this mode there is no need to prepare init file. ALso there is possibility to use MPLANE address not the LMP.
...  This mode use additional variables which can be provided:
...  ${CUSTOM_LIVE_MODE_PRIMARY_NODE_IP}     eg: ${EMPTY}, 10.44.10.10
...  In case of empty or lack of this argument, live mode over LMP is detected for primary node. In case BTS LMP port
...  with primary node is available via remote VM, IP address as string should be provided for remote VM
...
...  @{CUSTOM_LIVE_MODE_AUXILLARY_NODES_IPS_LIST} eg:  @{EMPTY},   10.44.10.20  10.44.10.22
...  In case multiBTS configuration in live mode with LMP port connection,
...  this list should contain information about additional VM IP with BTS connected
...
...  ${CUSTOM_MPLANE_MODE_PRIMARY_NODE_IP}=  ${EMPTY}  10.85.85.2
...  In case of testing BTS via MPLANE directly, this string variable contains BTS IP address of primary node
...
...  @{CUSTOM_MPLANE_MODE_AUXILLARY_NODES_IPS_LIST}=  @{EMPTY}  10.85.85.2  10.85.85.3
...  In case of testing BTS via MPLANE directly, this list variable contains BTS IP addresses of additional nodes
...   Additioanl variables possible to use by tester:
...   ${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=  Failed  # possible settings : Failed, Always, None. It control when snapshot is gathered from BTS.
...   ${CUSTOM_SWITCH_PERFORM_HW_SETUP}=  True  # to disable or enablehardware reconfiguration ( PDU ,Optical connection matrix and R&D flags)
...   when running in cloud True is mandatory. False value disable any operation on testline before testcase scenario,
...   it will not prepare configuration
...   ${ADDITIONAL_ALLOWED_FAULTS}  -  Variable contains additional allowed faults provided by user.

Library  BuiltIn
Library  Collections
Library  OperatingSystem
Library  Process
Library  DateTime
Library  SSHLibrary
Library  String
Library  XML  use_lxml=true

Library  taf.sbts.oam.coam.admin  WITH NAME  admin
Library  taf.transport.ssh  WITH NAME  ssh
Library  taf.ul.oam_kpi_calculations  WITH NAME  kpi
Library  taf/rfrl/csv4all/CSV4AllTestCases.py

Library  ./../Python/helpers.py
Library  ./../../../resources/siso_logger.py
Library  ./../Python/earfcn_operations.py
Library  ./../Python/time_helpers.py
Library  ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio
Library  ../../../resources/LMI.py  WITH NAME  lmi

Resource  ./../Robot/logging_session.robot
Resource  ./../Robot/PDU.robot
Resource  ./../Robot/scfc.robot
Resource  ./../Robot/STATE.robot
Resource  ./../Robot/SWM.robot
Resource  ./../Robot/KPI.robot
Resource  ./../Robot/SITE.robot
Resource  ./../Robot/FM_Faults.robot
Resource  ./../Robot/optical_switch.robot
Resource  ./../Robot/CM.robot
Resource  ./../Robot/ASIR.robot
Resource  ./../Robot/SSH.robot
Resource  ./../Robot/SWCONFIG.robot
Resource  ./../Robot/UUF.robot
Resource  ./../Robot/PM.robot
Resource  ./../Robot/RM.robot
Resource  ./../Robot/BTS_INFO.robot
Resource  ./scf_parsing.robot
Resource  ./tc_setup_teardown.robot
Resource  ./../../../resources/reporting.robot
Resource  ./loop.robot
Resource  ./../../../resources/operations.robot
Resource  ./../../../resources/bts_scfc.robot
Resource  ./../../../resources/common_kw.robot
Resource  ./../variables_custom.robot

Variables  ./../variables_global.py


*** Variables ***
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=  Failed
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=  True
${CUSTOM_SWITCH_PERFORM_RESET_CONFIGURATION_IN_SETUP}=  ${True}
${CUSTOM_FORCE_RECONFIGURATION}=  False
${CUSTOM_SETUP_FAULT_ID_2400_CHECK_ENABLED}=  ${False}


*** Keywords ***
Configuration Precondition
  [Arguments]  &{setup_kwargs}
  [Documentation]
  ...  Description:
  ...  Main basic setup for testcase, it prepares testline accordnig to configuration name.
  ...  CN  configuration name key, there 3 types of modes - reference, manual, live
  ...  CN=REF_NAME_OF_VARIANT  where NAME_OF_VARIANT is variant name taken from yaml file in topology repository
  ...  in directory provided by this variable: ${GLOBAL_TOPOLOGY_CONFIGS_REPOSITORY}
  ...  CN=MANUAL_NAME_OF_CONFIGURATION  where NAME_OF_CONFIGURATION is part of file name - NAME_OF_CONFIGURATION.xml
  ...  CN=live or lack of CN at all, live mode means direct connection to BTS via LMP or MPLANE address,
  ...  N  number of repetitions, eg  N=10
  ...  BTS_ID - possiblity to provide filtered list of tested BTS ID's
  ...  Teardown section - in case of setup failure configuration name will be set to 'failed' to force setup run in the same way in next testcase.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | setup_kwargs           | Yes  | dictionary with variables provided as keys, CN, N                  |
  ...  +------------------------+------+--------------------------------------------------------------------+
  Cleanup Robot Environment
  Logging With Timestamp
  ...  message=${EMPTY}
  Logging With Timestamp  message=${TEST_NAME}  style=TC  frame=True
  Logging With Timestamp  message=${TEST_NAME}  style=TC  frame=True  console=${FALSE}  output_file=tc_verdicts_report.txt
  Set Test Variable  ${LOGGING_SESSION_ACTIVE}  ${False}
  Prepare Parameters For Specific Configuration  &{setup_kwargs}
  Start Logging In Setup If Needed  ${TEST_LOGS_PATH}
  Check Variant State After Testline Setup
  Prepare Hardware For Tested Set Of Configurations
  Swconfig Operations
  Prepare Commissioning For Tested Configuration
  Software Check And Correct
  [Teardown]  Run Keywords
  ...  Run Keyword If  '${KEYWORD_STATUS}'=='FAIL'  Set To Dictionary  ${CFG}  configuration_name=Failed
  ...  AND
  ...  Check Unexpected And Historical Faults For All Nodes During Setup
  ...  AND
  ...  Stop Logging In Setup If Needed  ${TEST_LOGS_PATH}  status=${KEYWORD_STATUS}
  ...  AND
  ...  UUF Upgrade In Case Of Upgrade Path Type Execution
  ...  AND
  ...  Log Dictionary  ${CFG}

Configuration Postcondition
  [Documentation]
  ...  Description:
  ...  Keywords execute all needed steps after all test iteration
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Run Keyword And Ignore Error  Start Testline Scout Monitor
  Create Report
  Run Keyword And Ignore Error  Stop Testline Scout Monitor
  Cleanup Robot Environment
  Test Case Execution Summary

Prepare Parameters For Specific Configuration
  [Arguments]  &{setup_kwargs}
  [Documentation]
  ...  Description:
  ...  Create CFG abstraction layer, handle setup section parameters, prepares basic CFG description:
  ...  1. This procedure prepares virtual dictionary description ${CFG} using configuration file, VM data provided
  ...  by user by yml file in cloud regression or manually by parameters. It prepares basic description of each node using configuration files,
  ...  2. Prepares logging index for each BTS ID on list,
  ...  3. Creates logging directory for testcase,
  ...  4. Check if hardware reconfiguration is needed, variable ${RECONFIGURATION_NOT_NEEDED} is created as suite level and use in next steps
  ...  5. Check if CFG variable needs to be created for new configuration, variable ${CFG_CREATION_NOT_NEEDED} is created as suite level
  ...     and use in next steps,
  ...  6. Creates logical description of configuration related objects like cell setup, radio units relation and add it to CFG variable in NODES
  ...     subdictionary for each tested BTS_ID
  ...
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | setup_kwargs           | No   | dictionary with variables provided as keys, eg: CN, N              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Logging With Timestamp
  ...  message=::: Configuration Precondition - Started :::
  Logging With Timestamp
  ...  message=Step - Prepare Parameters For Specific Configuration
  ...  logs_dir=${CFG.suite_logs_path}
  Set Test Variable  ${SETUP_KWARGS}  ${setup_kwargs}
  ${RECONFIGURATION_NOT_NEEDED}  ${CFG_CREATION_NOT_NEEDED}=
  ...  Check Type Of Running Mode And If Hardware Reconfiguration Is Needed
  Prepare Testcase Repetition Loop Variables
  Logging With Timestamp
  ...  message=Setup running in ${CFG.configuration_setup_type} mode.
  ...  logs_dir=${CFG.suite_logs_path}
  IF  ${RECONFIGURATION_NOT_NEEDED}
    Logging With Timestamp  message=Testcase Hardware reconfiguration not needed.  logs_dir=${CFG.suite_logs_path}
  ELSE
    Logging With Timestamp
    ...  message=Testcase Hardware reconfiguration for ${CFG.configuration_setup_type} configuration.
    ...  logs_dir=${CFG.suite_logs_path}
  END
  IF  ${CFG_CREATION_NOT_NEEDED}
    Logging With Timestamp  message=Testcase dictionary creation not needed.  logs_dir=${CFG.suite_logs_path}
  ELSE
    Logging With Timestamp
    ...  message=Testcase dictionary creation for ${CFG.configuration_setup_type} configuration in progress.
    ...  style=ONGOING
    ...  logs_dir=${CFG.suite_logs_path}
  END
  Create Initial Directory Path
  Define Each Node Reference Configuration File Path And BTS ID
  Create Setup Directory Path For Each Node
  Prepare Variable For BTS_ID Filter  ${SETUP_KWARGS}
  Create Logging Index Dictionary For Each BTS
  Define Each Node Logical Description Based On Reference Files
  Logging With Timestamp
  ...  message=::: Prepare Parameters For Specific Configuration - Finished :::
  ...  style=DONE

Prepare Variable For BTS_ID Filter
  [Arguments]  ${setup_kwargs}
  [Documentation]
  ...  Description:
  ...  Checks if BTS_ID key was provided in setup dictionary argument, it is used as a filter if user want to test only one BTS from list
  ...  of BTS in one variant. It is done by adding a CFG key - active_bts_list, each loop in procedures should use it.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | setup_kwargs           | No   | dictionary with variables provided as keys, eg: CN, N ,BTS_ID      |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${bts_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${setup_kwargs.BTS_ID}
  IF  ${bts_list_status}
    ${active_bts_list}=  Split String  ${setup_kwargs.BTS_ID}  ,
  ELSE
    ${active_bts_list}=  Set Variable  ${None}
  END
  ${bts_list}=  Get Dictionary Keys  ${CFG.NODES}
  IF  '${bts_list_status}'== 'False'
    Set To Dictionary  ${CFG}  active_bts_list=${bts_list}
  ELSE
    Set To Dictionary  ${CFG}  active_bts_list=${active_bts_list}
  END

Check Type Of Running Mode And If Hardware Reconfiguration Is Needed
  [Documentation]
  ...  Description:
  ...  Using configuration key name from setup - CN, this keyword checks if configuration has changed and what type of setup is used by user.
  ...  In case there is no CN values, keyword assumes it is 'live' mode - direct mode which do not use earlier prepared scf files., no init required,
  ...  In case CN value start with REF - it means reference in topology_configs and variant name,
  ...  In case CN value start with MANUAL - it means that reference scf file is provided manually by user, no init required,
  ...
  ...  Keyword add to CFG variable keys:
  ...  configuration_name - the same value as CN key, in case CN was not provided live value is added
  ...  configuration_setup_type - type of way setup is working, live, reference, manual
  ...
  ...
  ...  Return:
  ...  RECONFIGURATION_NOT_NEEDED - when True it means that hardware and logical reconfiguration is not required,
  ...  in case of False all steps for setup OnAir are executed,
  ...  CFG_CREATION_NOT_NEEDED - when True it means that CFG variable with NODES subdictionary is already available for tested configuration
  ...  and there is no need to create it, the first step checks if configuration provided as reference is in OnAir state
  ...  CUSTOM_SWITCH_PERFORM_HW_SETUP  - Global level argument set by user. It has two values possible - True or False
  ...  True - in case requested configuration wasn't prepared by agent to OnAir state, setup will make all steps needed to reach OnAir:
  ...  reset configuration, recommissioning, check software on all objects. This is default value in case of regression in cloud,
  ...  The first step checks if configuration provided as reference is in OnAir state
  ...  With 'True' value also reference swconfig file with R&D flags will be cheked and corrected
  ...  False - disable hardware and logical reconfiguration, leave testline as it is, do not check R&D flags.
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${cn_status}=  Run Keyword And Return Status  Variable Should Exist  ${setup_kwargs.CN}
  ${first_test}=  Run Keyword And Return Status  Variable Should Not Exist  ${CFG.configuration_setup_type}
  IF  ${cn_status}
    ${ref_cn__configuration_name}=  Remove String  ${setup_kwargs.CN}  REF_
  ELSE
    ${ref_cn__configuration_name}=  Set Variable  ${None}
  END
  IF  ${cn_status}
    ${configuration_is_changed}=  Set Variable If
    ...  ${first_test}
    ...  ${True}
    ...  '${CFG.configuration_name}' == '${ref_cn__configuration_name}'
    ...  ${False}
    ...  ${True}
  ELSE
    ${configuration_is_changed}=  Set Variable  ${None}
  END
  IF  not ${cn_status}
    Set To Dictionary  ${setup_kwargs}  CN=live
  END
  IF  ${first_test}
    Logging With Timestamp  message=First testcase in suite detected.  logs_dir=${CFG.suite_logs_path}
  END

  IF  'REF' in '${setup_kwargs.CN}'
    Set To Dictionary  ${CFG}  configuration_setup_type=reference  configuration_name=${setup_kwargs.CN}
  ELSE IF  '${setup_kwargs.CN}' == 'live' or '${setup_kwargs.CN}' == 'Live'
    Set To Dictionary  ${CFG}  configuration_setup_type=live  configuration_name=live
  ELSE IF  'MANUAL' in '${setup_kwargs.CN}'
    Set To Dictionary  ${CFG}  configuration_name=${setup_kwargs.CN}  configuration_setup_type=manual
  END

  ${hw_reconfiguration}=  Set Variable If
  ...  'REF' in '${setup_kwargs.CN}'  ${True}
  ...  '${setup_kwargs.CN}' == 'live' or '${setup_kwargs.CN}' == 'Live'  ${False}
  ...  'MANUAL' in '${setup_kwargs.CN}'  ${True}
  ...  ${True}
  IF  '${CFG.configuration_setup_type}' == 'reference'
    ${file_configuration_name}=  Remove String  ${setup_kwargs.CN}  REF_
  ELSE
    ${file_configuration_name}=  Set Variable  ${None}
  END
  IF  '${CFG.configuration_setup_type}' == 'reference'
    Set To Dictionary  ${CFG}  configuration_name=${file_configuration_name}
  END
  IF  '${CFG.configuration_setup_type}' == 'manual'
    ${file_configuration_name}=  Remove String  ${setup_kwargs.CN}  MANUAL_
  ELSE
    ${file_configuration_name}=  Set Variable  ${None}
  END
  IF  '${CFG.configuration_setup_type}' == 'manual'
    Set To Dictionary  ${CFG}  configuration_name=${file_configuration_name}
  END
  Log Dictionary  ${CFG}
  ${RECONFIGURATION_NOT_NEEDED}=  Set Variable If
  ...  ${hw_reconfiguration} == ${False}  True
  ...  (${first_test} == ${True} and ${hw_reconfiguration} == ${True} and ${custom_switch_perform_hw_setup} == ${True})  ${False}
  ...  (${first_test} == ${True} and ${hw_reconfiguration} == ${True} and ${custom_switch_perform_hw_setup} == ${False})  ${True}
  ...  (${configuration_is_changed} and ${CUSTOM_SWITCH_PERFORM_HW_SETUP}) == ${True}  ${False}
  ...  (${configuration_is_changed} and ${CUSTOM_SWITCH_PERFORM_HW_SETUP}) == ${False}  ${True}
  ...  ${CUSTOM_SWITCH_PERFORM_HW_SETUP} == ${False}  ${True}
  ${CFG_CREATION_NOT_NEEDED}=  Set Variable If
  ...  ${first_test} == ${True}  ${False}
  ...  ${configuration_is_changed}  ${False}  ${True}
  IF  not ${RECONFIGURATION_NOT_NEEDED}
    Remove From Dictionary  ${CFG}  NODES
  END
  IF  not ${CFG_CREATION_NOT_NEEDED}
    Set To Dictionary  ${CFG}  configuration_setup_type=${CFG.configuration_setup_type}  NODES=&{EMPTY}
  END
  Set Test Variable  ${RECONFIGURATION_NOT_NEEDED}  ${reconfiguration_not_needed}
  Set Test Variable  ${CFG_CREATION_NOT_NEEDED}  ${CFG_CREATION_NOT_NEEDED}
  [Return]  ${RECONFIGURATION_NOT_NEEDED}  ${CFG_CREATION_NOT_NEEDED}

Define Each Node Reference Configuration File Path And BTS ID
  [Documentation]
  ...  Description: This procedure defines working nodes description according to type of setup preparation.
  ...  live - direct mode without scf file, it can work using LMP orMPLANE address of BTS
  ...  reference - variant name will be use as reference
  ...  manual - scf file from user specified path will be use
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Return From Keyword If  ${CFG_CREATION_NOT_NEEDED}
  IF  "${CFG.configuration_setup_type}" == "live"
    Create Description in Live And Mplane Mode Using Collected SCF
  ELSE IF  "${CFG.configuration_setup_type}" == "reference"
    Create Description in Reference Mode Using Reference SCF Files
  ELSE IF  "${CFG.configuration_setup_type}" == "manual"
    Create Description in Manual Provided Files Mode Using Reference SCF Files
  END

Start Logging In Setup If Needed
  [Arguments]  ${test_logs_path}
  [Documentation]
  ...  Description:
  ...  KW start logging session for reference and manual setup type
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | test_logs_path         | Yes  | directory path to logging folder                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Set Test Variable  ${LOGGING_SESSION_ACTIVE}  ${False}
  Return From Keyword If  ${RECONFIGURATION_NOT_NEEDED}
  Set Test Variable  ${LOGGING_SESSION_ACTIVE}  ${True}
  Logging Multinode Start  ${test_logs_path}

Stop Logging In Setup If Needed
  [Arguments]  ${test_logs_path}  ${status}
  [Documentation]
  ...  Description:
  ...  KW start logging session for reference and manual setup type
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | test_logs_path         | Yes  | directory path to logging folder                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | status                 | Yes  | status of setup default is taken from RF variable ${KEYWORD_STATUS}|
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Return From Keyword If  not ${LOGGING_SESSION_ACTIVE}
  Logging Multinode Stop  ${test_logs_path}  status=${status}

# Keywords related to Live/mplane mode ##

Create Description in Live And Mplane Mode Using Collected SCF
  [Documentation]
  ...  Description:
  ...  This procedure creates session and variables for live mode. It creates admin session and gathers
  ...  scf configuration files. It check the tested BTS ID and use it as identifier later in testcases.
  ...  All information for each BTS are stored under CFG variable.
  ...  Arguments:  Global provided arguments only set by user in suite:
  ...  ${CUSTOM_LIVE_MODE_PRIMARY_NODE_IP}     eg: ${EMPTY}, 10.44.10.10
  ...  In case of empty or lack of this argument, live mode over LMP is detected for primary node. In case BTS LMP port
  ...  with primary node is available via remote VM, IP address as string should be provided for remote VM
  ...
  ...  @{CUSTOM_LIVE_MODE_AUXILLARY_NODES_IPS_LIST} eg:  @{EMPTY},   10.44.10.20  10.44.10.22
  ...  In case multiBTS configuration in live mode with LMP port connection,
  ...  this list should contain information about additional VM IP with BTS connected
  ...
  ...  ${CUSTOM_MPLANE_MODE_PRIMARY_NODE_IP}=  ${EMPTY}  10.85.85.2
  ...  In case of testing BTS via MPLANE directly, this string variable contains BTS IP address of primary node
  ...
  ...  @{CUSTOM_MPLANE_MODE_AUXILLARY_NODES_IPS_LIST}=  @{EMPTY}  10.85.85.2  10.85.85.3
  ...  In case of testing BTS via MPLANE directly, this list variable contains BTS IP addresses of additional nodes
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  ${tmp_list}=  Create List  @{EMPTY}
  ${CUSTOM_LIVE_MODE_AUXILLARY_NODES_IPS_LIST_status}=  Run Keyword And Return Status
  ...  Should Not Be Empty  ${CUSTOM_LIVE_MODE_AUXILLARY_NODES_IPS_LIST}
  IF  ${CUSTOM_LIVE_MODE_AUXILLARY_NODES_IPS_LIST_status}
    @{CUSTOM_LIVE_MODE_AUXILLARY_NODES_IPS_LIST}=  Set Variable  ${CUSTOM_LIVE_MODE_AUXILLARY_NODES_IPS_LIST}
  ELSE
    @{CUSTOM_LIVE_MODE_AUXILLARY_NODES_IPS_LIST}=  Set Variable  ${tmp_list}
  END
  ${CUSTOM_MPLANE_MODE_AUXILLARY_NODES_IPS_LIST_status}=  Run Keyword And Return Status
  ...  Should Not Be Empty  ${CUSTOM_MPLANE_MODE_AUXILLARY_NODES_IPS_LIST}
  IF  ${CUSTOM_MPLANE_MODE_AUXILLARY_NODES_IPS_LIST_status}
    @{CUSTOM_MPLANE_MODE_AUXILLARY_NODES_IPS_LIST}=  Set Variable  ${CUSTOM_MPLANE_MODE_AUXILLARY_NODES_IPS_LIST}
  ELSE
    @{CUSTOM_MPLANE_MODE_AUXILLARY_NODES_IPS_LIST}=  Set Variable  ${tmp_list}
  END
  IF  '${CUSTOM_MPLANE_MODE_PRIMARY_NODE_IP}'!='${EMPTY}'
    Set To Dictionary  ${CFG}  configuration_setup_type=mplane
  END
  ${bts_ip_address}=  Set Variable If  '${CUSTOM_MPLANE_MODE_PRIMARY_NODE_IP}'!='${EMPTY}'  ${CUSTOM_MPLANE_MODE_PRIMARY_NODE_IP}  ${EMPTY}
  ${vm_ip_LMP_address}=  Set Variable If  '${CUSTOM_LIVE_MODE_PRIMARY_NODE_IP}'!='${EMPTY}'  ${CUSTOM_LIVE_MODE_PRIMARY_NODE_IP}  ${EMPTY}
  ${bts_id}=  Connect To BTS Directly To Collect SCF File And Create NODES For Specific BTS_ID
  ...  vm_ip_LMP_address=${vm_ip_LMP_address}
  ...  bts_ip_address=${bts_ip_address}
  Set To Dictionary  ${CFG}
  ...  primary_node_bts_id=${bts_id}
  FOR  ${remote_BTS}  IN  @{CUSTOM_LIVE_MODE_AUXILLARY_NODES_IPS_LIST}
    Exit For Loop If  not ${CUSTOM_LIVE_MODE_AUXILLARY_NODES_IPS_LIST_status}
    Connect To BTS Directly To Collect SCF File And Create NODES For Specific BTS_ID
    ...  vm_ip_LMP_address=${remote_BTS}
    ...  bts_ip_address=${EMPTY}
  END
  FOR  ${remote_BTS}  IN  @{CUSTOM_MPLANE_MODE_AUXILLARY_NODES_IPS_LIST}
    Exit For Loop If  not ${CUSTOM_MPLANE_MODE_AUXILLARY_NODES_IPS_LIST_status}
    Connect To BTS Directly To Collect SCF File And Create NODES For Specific BTS_ID
    ...  vm_ip_LMP_address=${EMPTY}
    ...  bts_ip_address=${remote_BTS}
  END

Connect To BTS Directly To Collect SCF File And Create NODES For Specific BTS_ID
  [Arguments]  ${vm_ip_LMP_address}  ${bts_ip_address}
  [Documentation]
  ...  Description:
  ...  Using VM or/and BTS host IP address this procedure check BTS ID number, creates subdictioanry and provide basic information about BTS.
  ...  It also saves scf file in setup folder
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | vm_ip_LMP_address      | Yes  | IP adress used to connect to VM                                    |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | bts_ip_address         | Yes  | IP adress used to connect to BTS host,                             |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${bts_alias_type}=  Set Variable If  '${bts_ip_address}'=='${EMPTY}'  localhost  remote
  IF  '${vm_ip_LMP_address}'=='${EMPTY}' and '${bts_ip_address}'=='${EMPTY}'
    Logging Session Start  logs_dir_path=${CFG.test_logs_path}/Setup/  tools_to_setup=ADMIN  bts_id=live  connection=live
  ELSE IF  '${vm_ip_LMP_address}'=='${EMPTY}' and '${bts_ip_address}'!='${EMPTY}'
    Logging Session Start  logs_dir_path=${CFG.test_logs_path}/Setup/  bts_host=${bts_ip_address}  tools_to_setup=ADMIN  bts_id=live  connection=live
  ELSE
    Logging Session Start
    ...  logs_dir_path=${CFG.test_logs_path}/Setup/
    ...  host_ip=${vm_ip_LMP_address}
    ...  tools_to_setup=ADMIN
    ...  bts_id=live
    ...  connection=live
  END
  &{bts_info}=  admin.Get Bts Info
  ...  connection=live
  ${bts_id}=  Set Variable  ${bts_info.mrbtsID}
  ${bts_active_software}=  Set Variable  ${bts_info.swInfo.swVersion}
  ${bts_id}=  Convert To String  ${bts_id}
  &{tmp_node}=  Create Dictionary
  ${scf_node_file}=  admin.Get Current Scf File
  ...  local_dir_path=${CFG.test_logs_path}/Setup/BTSFiles/${bts_id}/
  ...  file_name=scf_${bts_id}_commissioning.xml
  ...  export_type=configurationAndRuntimeObjects
  ...  connection=live
  ...  timeout=${BASIC_ADMIN_PROCEDURES_TIMEOUT}
  admin.Collect Im Snapshot
  ...  target_file_name=${CFG.test_logs_path}/Setup/BTSFiles/${bts_id}/ims_${bts_id}_snapshot.ims2
  ...  connection=live
  ${dualcore}  ${primary_sm}  ${secondary_sm}=  Current Configuration Check DualCore  ${scf_node_file}
  ${secondary_sm_vm_ip_bts_address_status}=  Run Keyword And Return Status  Dictionary Should Contain Key
  ...  ${SM_VM_IP_ADDRESS_DICT}  ${secondary_sm}
  IF  ${secondary_sm_vm_ip_bts_address_status}
    ${secondary_sm_vm_ip_LMP_address}=  Get From Dictionary  ${SM_VM_IP_ADDRESS_DICT}  ${secondary_sm}
  ELSE
    ${secondary_sm_vm_ip_LMP_address}=  Set Variable  ${None}
  END
  ${secondary_sm_vm_ip_LMP_address}=  Set Variable If  ${secondary_sm_vm_ip_bts_address_status}
  ...  ${secondary_sm_vm_ip_LMP_address}  ${EMPTY}
  ${secondary_bts_alias_type}=  Set Variable If  '${secondary_sm_vm_ip_bts_address_status}'!='${EMPTY}'  remote  ${EMPTY}
  ${active_release}  ${trunk_status}=  Get SW Release From SW Name  ${bts_active_software}
  ${active_release}=  Set Variable If  '${active_release}'=='${EMPTY}'  SBTS00  ${active_release}
  Set Suite Variable  ${RELEASE}  ${active_release}
  Set Suite Variable  ${TRUNK_STATUS}  ${trunk_status}
  Set To Dictionary  ${tmp_node}
  ...  primary_sm=${primary_sm}
  ...  secondary_sm=${secondary_sm}
  ...  dualcore=${dualcore}
  ...  scf_file_path=${scf_node_file}
  ...  software_active=${bts_active_software}
  ...  trunk_status=${trunk_status}
  ...  active_release=${active_release}
  ...  vm_ip_LMP_address=${vm_ip_LMP_address}
  ...  bts_ip_address=${bts_ip_address}
  ...  bts_alias_type=${bts_alias_type}
  ...  secondary_bts_alias_type=${secondary_bts_alias_type}
  ...  secondary_sm_vm_ip_LMP_address=${secondary_sm_vm_ip_LMP_address}
  Set To Dictionary  ${CFG.NODES}  ${bts_id}=&{tmp_node}
  [Return]  ${bts_id}
  [Teardown]  Run Keyword And Ignore Error  admin.Teardown
  ...  connection=live

# Keywords related to Reference mode use in regression and with init and yml file required ##

Create Description in Reference Mode Using Reference SCF Files
  [Documentation]
  ...  Description:
  ...  This procedure creates session and variables for reference mode. It check the tested BTS ID and use it as identifier later in testcases.
  ...  All information for each BTS are stored under CFG variable.
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Gather Description Of Configurations From Topology Configs Repository Using Config YAML File And Provided Variant Name
  Gather BTS_ID From Each Node In Reference Mode
  Expand Node Description For Information Available In Testline Description

Gather Description Of Configurations From Topology Configs Repository Using Config YAML File And Provided Variant Name
  [Documentation]
  ...  Description:
  ...  This procedure finds in topology_configs repository defianed in variable ${GLOBAL_TOPOLOGY_CONFIGS_REPOSITORY} and by testline default label
  ...  ${CM_TOPOLOGY} current used variant configuration. It is exported as suite level variable ${VARIANT}.
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  ${topology_variable_config_file}  ${GLOBAL_TOPOLOGY_CONFIGS_REPOSITORY}=  Get Topology Config Directory Path
  ...  ${GLOBAL_TOPOLOGY_CONFIGS_REPOSITORY}
  ...  CLOUD_${TESTLINE}/${RELEASE}
  ${topology_variable_config_file}=  Run Keyword And Ignore Error
  ...  Import Variables  ${topology_variable_config_file}

  Set Suite Variable  ${TOPOLOGY_VARIABLE_CONFIG_FILE}  ${GLOBAL_TOPOLOGY_CONFIGS_REPOSITORY}/
  Set Suite Variable  ${VARIANTS}  ${variants}
  FOR  ${variant}  IN  @{VARIANTS}
    Set Suite Variable  ${VARIANT}  ${variant}
    Exit For Loop If  '${variant['name']}' == '${CFG.configuration_name}'
    Set Suite Variable  ${VARIANT}  ${None}
  END
  ${variant_status}=  Get Variable Value  ${VARIANT}
  IF  not ${variant_status}
    Fail  msg=Check Variant provided in setup,${\n}there is no "${CFG.configuration_name}" topology_configs in repository !
  END

Check Active Relase
  [Documentation]
  ...  Description:
  ...  This procedure finds active software release using ssh connection to every available sm provided in init file.
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  @{test_pc_release_list}=  Create List  @{EMPTY}
  FOR  ${test_pc}  IN  @{tl.test_pcs}
    ${ip_addr}=  Evaluate  $test_pc.default_ssh_connection_details.addr
    ${active_soft}=  Run Keyword And Ignore Error  radio.Get Active Software Release From ENB
    ...  remote_host=${ip_addr}
    ...  full_build_name=${True}
    IF  '${active_soft}[0]'=='PASS'
      Append To List  ${test_pc_release_list}  ${active_soft}[1]
    END
    radio.Close SSH Connection
  END
  @{directories_list}=  OperatingSystem.List Directories In Directory  ${GLOBAL_TOPOLOGY_CONFIGS_REPOSITORY}${/}
  Sort List  ${directories_list}
  ${active_release}=  Set Variable  ${test_pc_release_list}[0]

  [Return]  ${active_release}

Get SW Release From SW Name
  [Arguments]  ${sw_name}
  [Documentation]
  ...  Description:
  ...  Returns SW release based on give SW name e.g. SBTS00 for SBTS00_ENB_9999_240311_000005
  ...  In case of trunk build status oftrunk is returned
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | sw_name                | Yes  | IP adress used to connect to VM                                    |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${sw_release}=  Should Match Regexp  ${sw_name}  ^(?:SBTS|5G)\\d+[A-Z]*\\d?
  ${trunk_status}=  Run Keyword And Return Status  Should Match Regexp  ${sw_name}  .*_999[0-9].*
  [Return]  ${sw_release}  ${trunk_status}

Gather BTS_ID From Each Node In Reference Mode
  [Documentation]
  ...  Description:
  ...  Using Suite level variable ${VARIANT} procedure creates NODES key input using reference file provided in config.yml file.
  ...  Informations are exported as CFG variable.
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  FOR  ${node}  IN  @{VARIANT['nodes']}
    ${files_node_status}=  Run Keyword And Return Status  Variable Should Exist  ${node['files']}
    Continue For Loop If  not ${files_node_status}
    ${file}=  Find SCF File Object In Nodes Files  ${node['files']}
    Continue For Loop If  not ${file}
    &{tmp_node}=  Create Dictionary
    ${bts_id}=  SCFC Get BtsId  scfc_file_path=${TOPOLOGY_VARIABLE_CONFIG_FILE}${file['file_path']}
    ${dualcore}  ${primary_sm}  ${secondary_sm}=  Current Configuration Check DualCore
    ...  scf_file_path=${TOPOLOGY_VARIABLE_CONFIG_FILE}${file['file_path']}
    Set To Dictionary  ${tmp_node}
    ...  scf_file_path=${TOPOLOGY_VARIABLE_CONFIG_FILE}${file['file_path']}
    ...  node_id=${node['node_id']}
    ...  primary_sm=${primary_sm}
    ...  secondary_sm=${secondary_sm}
    ...  dualcore=${dualcore}
    Set To Dictionary  ${CFG.NODES}  ${bts_id}=&{tmp_node}
    IF  "${node['node_id']}"=="1"
      Set To Dictionary  ${CFG}  primary_node_bts_id=${bts_id}
    END
  END

Find SCF File Object In Nodes Files
  [Arguments]  ${files}
  [Documentation]
  ...  Description:
  ...  Procedure returns required file in yml file if it is scf type file.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | files                  | Yes  | list of files in tested variant from specific node in topology     |
  ...  |                        |      | repositorium                                                       |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  FOR  ${file_object}  IN  @{files}
    ${file}=  Set Variable If  '${file_object['file_type']}'=='scf'  ${file_object}  ${False}
    Exit For Loop If  '${file_object['file_type']}'=='scf'
  END
  [Return]  ${file}

Expand Node Description For Information Available In Testline Description
  [Documentation]
  ...  Description:
  ...  Using init file checks additional information related to each BTS node, such as: Vm ip address in case of remote session, bts alias type.
  ...  Information is added to each CFG.NODES subdictionary.
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${_}  ${output}=  Run And Return RC And Output  ip address show
  ${ip_list}=  Get Regexp Matches  ${output}  (\\d+\\.\\d+\\.\\d+\\.\\d+)
  Remove Values From List  ${ip_list}  127.0.0.1
  FOR  ${test_pc}  IN  @{tl.test_pcs}
    ${ip_addr}=  Evaluate  $test_pc.default_ssh_connection_details.addr
    ${sm_serial_number}=  Evaluate  $test_pc.connections[1].device.serial_number
    ${local_vm_status}=  Run Keyword And Return Status  Should Contain Any  ${ip_list}  ${ip_addr}
    ${bts_alias_type}=  Set Variable If  ${local_vm_status}  localhost  remote
    ${vm_ip_LMP_address}=  Set Variable If  ${local_vm_status}  ${EMPTY}  ${ip_addr}
    ${node}=  Find BTS_ID For SM Serial Number  ${sm_serial_number}  primary_sm
    ${secondary_node}=  Find BTS_ID For SM Serial Number  ${sm_serial_number}  secondary_sm
    ${active_soft}=  Run Keyword And Ignore Error  Wait Until Keyword Succeeds  20  5
    ...  radio.Get Active Software Release From ENB
    ...  remote_host=${ip_addr}
    ...  full_build_name=${True}
    IF  '${node}'!='None' and '${active_soft}[0]'!='FAIL'
      ${active_release}  ${trunk_status}=  Get SW Release From SW Name  ${active_soft}[1]
    ELSE
      ${active_release}  ${trunk_status}=  Set Variable  ${None}  ${None}
    END
    ${active_software}=  Set Variable If  '${node}'!='None' and '${active_soft}[0]'!='FAIL'
    ...  ${active_soft}[1]
    ...  ${None}
    IF  '${node}'!='None'
      ${active_release}=  Set Variable If  '${active_release}'=='${EMPTY}' or '${active_release}'=='${None}'  SBTS00  ${active_release}
    ELSE
      ${active_release}=  Set Variable  ${None}
    END
    IF  '${node}'!='None'
      ${trunk_status}=  Set Variable If  '${trunk_status}'=='${EMPTY}' or '${trunk_status}'=='${None}'  ${TRUE}  ${trunk_status}
    ELSE
      ${trunk_status}=  Set Variable  ${None}
    END
    IF  '${node}'!='None'
      Set Suite Variable  ${RELEASE}  ${active_release}
    END
    IF  '${node}'!='None'
      Set Suite Variable  ${TRUNK_STATUS}  ${trunk_status}
    END
    IF  '${node}'!='None'
      Set To Dictionary
      ...  ${CFG.NODES['${node}']}
      ...  vm_ip_LMP_address=${ip_addr}
      ...  bts_ip_address=${EMPTY}
      ...  bts_alias_type=${bts_alias_type}
      ...  software_active=${active_software}
      ...  trunk_status=${trunk_status}
      ...  active_release=${active_release}
    ELSE IF  '${secondary_node}'!='None'
      Set To Dictionary
      ...  ${CFG.NODES['${secondary_node}']}
      ...  secondary_sm_vm_ip_LMP_address=${vm_ip_LMP_address}
      ...  secondary_bts_alias_type=${bts_alias_type}
    END
    radio.Close SSH Connection
  END

Find BTS_ID For SM Serial Number
  [Arguments]  ${sm_serial_number}  ${sm_role}
  [Documentation]
  ...  Description:
  ...  Returns BTS_ID number using serial number of system module from existing nodes in CFG variable.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | sm_serial_number       | Yes  | serial number of system module                                     |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  FOR  ${node}  IN  @{CFG.NODES}
    Exit For Loop If  '${CFG.NODES['${node}']['${sm_role}']}'=='${sm_serial_number}'
    ${node}=  Set Variable  ${None}
  END
  [Return]  ${node}

## Keywords related to Manual Provided Files mode use in regression and with init and yml file required ##

Create Description in Manual Provided Files Mode Using Reference SCF Files
  [Documentation]
  ...  Description:
  ...  Procedure prepares CFG description using provided manually configuration files and by special dictionary parameter.
  ...
  ...  Arguments:
  ...  Arguments are provided as suite level dictioanry varaible, where main variable name is the same as configration name
  ...  provided in setup section in CN key. In this dictionary user has to provide additioanl parameters because this mode do not use init file.
  ...  In case of multi BTS configuration ADDITIONAL_NODES_LIST key has to be provided as a list of additional configuration file names.
  ...  Also in this varaible ${SM_VM_IP_ADDRESS_DICT} dictionary values of "primary_sm_serial_number=IP of VM" must be provided.
  ...  All configuration files must be provided in one directory by ${CUSTOM_MANUAL_MODE_SCF_PATH} variable.
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${ADDITIONAL_NODES_LIST_status}=  Run Keyword And Return Status
  ...  Get From Dictionary  ${MANUAL_${CFG['configuration_name']}}  ADDITIONAL_NODES_LIST
  IF  ${ADDITIONAL_NODES_LIST_status}
    ${custom_manual_mode_auxillary_nodes_list}=  Get From Dictionary  ${MANUAL_${CFG['configuration_name']}}  ADDITIONAL_NODES_LIST
  ELSE
    ${custom_manual_mode_auxillary_nodes_list}=  Set Variable  ${None}
  END
  IF  ${ADDITIONAL_NODES_LIST_status}
    ${custom_manual_mode_auxillary_nodes_list}=  Split String  ${custom_manual_mode_auxillary_nodes_list}  ,
  ELSE
    ${custom_manual_mode_auxillary_nodes_list}=  Set Variable  ${False}
  END
  ${primary_bts_file_path}=  Set Variable  ${CUSTOM_MANUAL_MODE_SCF_PATH}${/}${CFG['configuration_name']}.xml
  &{tmp_node}=  Create Dictionary
  ${primary_bts_file_path_status}=  Run Keyword And Ignore Error  OperatingSystem.File Should Exist  ${primary_bts_file_path}
  IF  '${primary_bts_file_path_status[0]}'=='FAIL'
    Fail  msg=Check provided file in setup,${\n}there is no "${CFG['configuration_name']}.xml" file in provided path: ${CUSTOM_MANUAL_MODE_SCF_PATH}
  END
  ${bts_id}=  SCFC Get BtsId  scfc_file_path=${primary_bts_file_path}
  ${dualcore}  ${primary_sm}  ${secondary_sm}=  Current Configuration Check DualCore
  ...  scf_file_path=${primary_bts_file_path}
  ${vm_ip_bts_address_status}=  Run Keyword And Return Status  Get From Dictionary  ${SM_VM_IP_ADDRESS_DICT}  ${primary_sm}
  ${secondary_sm_vm_ip_bts_address_status}=  Run Keyword And Return Status  Get From Dictionary  ${SM_VM_IP_ADDRESS_DICT}  ${secondary_sm}
  IF  ${vm_ip_bts_address_status}
    ${vm_ip_LMP_address}=  Get From Dictionary  ${SM_VM_IP_ADDRESS_DICT}  ${primary_sm}
  ELSE
    ${vm_ip_LMP_address}=  Set Variable  ${EMPTY}
  END
  IF  ${secondary_sm_vm_ip_bts_address_status}
    ${secondary_sm_vm_ip_LMP_address}=  Get From Dictionary  ${SM_VM_IP_ADDRESS_DICT}  ${secondary_sm}
  ELSE
    ${secondary_sm_vm_ip_LMP_address}=  Set Variable  ${EMPTY}
  END
  ${_}  ${output}=  Run And Return RC And Output  ip address show
  ${ip_list}=  Get Regexp Matches  ${output}  (\\d+\\.\\d+\\.\\d+\\.\\d+)
  Remove Values From List  ${ip_list}  127.0.0.1
  ${local_vm_status}=  Run Keyword And Return Status  Should Contain Any  ${ip_list}  ${vm_ip_LMP_address}
  ${secondary_sm_vm_status}=  Run Keyword And Return Status  Should Contain Any  ${ip_list}  ${secondary_sm_vm_ip_LMP_address}
  ${bts_alias_type}=  Set Variable If  ${local_vm_status}  localhost  remote
  ${secondary_sm_bts_alias_type}=  Set Variable If  ${secondary_sm_vm_status}  localhost  remote
  ${active_soft}=  Run Keyword And Ignore Error  radio.Get Active Software Release From ENB
  ...  remote_host=${vm_ip_LMP_address}
  ...  full_build_name=${True}
  radio.Close SSH Connection
  ${active_release}  ${trunk_status}=  Get SW Release From SW Name  ${active_soft}[1]
  ${active_release}=  Set Variable If  '${active_release}'=='${EMPTY}'  SBTS00  ${active_release}
  Set Suite Variable  ${RELEASE}  ${active_release}
  Set Suite Variable  ${TRUNK_STATUS}  ${trunk_status}
  Set To Dictionary  ${tmp_node}
  ...  scf_file_path=${primary_bts_file_path}
  ...  primary_sm=${primary_sm}
  ...  secondary_sm=${secondary_sm}
  ...  dualcore=${dualcore}
  ...  vm_ip_LMP_address=${vm_ip_LMP_address}
  ...  bts_ip_address=${EMPTY}
  ...  bts_alias_type=${bts_alias_type}
  ...  software_active=${active_soft}[1]
  ...  trunk_status=${trunk_status}
  ...  active_release=${active_release}
  ...  secondary_sm_vm_ip_LMP_address=${secondary_sm_vm_ip_LMP_address}
  ...  secondary_sm_bts_alias_type=${secondary_sm_bts_alias_type}
  Set To Dictionary  ${CFG.NODES}  ${bts_id}=&{tmp_node}
  Set To Dictionary  ${CFG}  primary_node_bts_id=${bts_id}
  Return From Keyword If  not ${additional_nodes_list_status}
  FOR  ${node}  IN  @{custom_manual_mode_auxillary_nodes_list}
    &{tmp_node}=  Create Dictionary
    ${additional_bts_file_path_status}=  Run Keyword And Ignore Error
    ...  OperatingSystem.File Should Exist  ${CUSTOM_MANUAL_MODE_SCF_PATH}${/}${node}.xml
    IF  '${additional_bts_file_path_status[0]}'=='FAIL'
      Fail  msg=Check provided file in setup,${\n}there is no "${node}.xml" file in provided path: ${CUSTOM_MANUAL_MODE_SCF_PATH}
    END
    ${bts_id}=  SCFC Get BtsId  scfc_file_path=${CUSTOM_MANUAL_MODE_SCF_PATH}${/}${node}.xml
    ${dualcore}  ${primary_sm}  ${secondary_sm}=  Current Configuration Check DualCore
    ...  scf_file_path=${CUSTOM_MANUAL_MODE_SCF_PATH}${/}${node}.xml
    ${vm_ip_bts_address_status}=  Run Keyword And Return Status  Get From Dictionary  ${SM_VM_IP_ADDRESS_DICT}  ${primary_sm}
    IF  ${vm_ip_bts_address_status}
      ${vm_ip_LMP_address}=  Get From Dictionary  ${SM_VM_IP_ADDRESS_DICT}  ${primary_sm}
    ELSE
      ${vm_ip_LMP_address}=  Set Variable  ${None}
    END
    ${local_vm_status}=  Run Keyword And Return Status  Should Contain Any  ${ip_list}  ${vm_ip_LMP_address}
    ${secondary_sm_vm_status}=  Run Keyword And Return Status  Should Contain Any  ${ip_list}  ${secondary_sm_vm_ip_LMP_address}
    ${bts_alias_type}=  Set Variable If  ${local_vm_status}  localhost  remote
    ${secondary_sm_bts_alias_type}=  Set Variable If  ${secondary_sm_vm_status}  localhost  remote
    Set To Dictionary  ${tmp_node}
    ...  scf_file_path=${CUSTOM_MANUAL_MODE_SCF_PATH}${/}${node}.xml
    ...  primary_sm=${primary_sm}
    ...  secondary_sm=${secondary_sm}
    ...  dualcore=${dualcore}
    ...  vm_ip_LMP_address=${vm_ip_LMP_address}
    ...  bts_ip_address=${EMPTY}
    ...  bts_alias_type=${bts_alias_type}
    ...  secondary_sm_vm_ip_LMP_address=${secondary_sm_vm_ip_LMP_address}
    ...  secondary_sm_bts_alias_type=${secondary_sm_bts_alias_type}
    Set To Dictionary  ${CFG.NODES}  ${bts_id}=&{tmp_node}
  END

##  Other Suite Keywords used in setup  ##

Prepare Testcase Repetition Loop Variables
  [Documentation]
  ...  Description:
  ...  Using user provided iteration number N prepares boolean variable if testcase is under repetition ${REPETITION}
  ...  and easy to use variable ${REPETITION_LIST} as a list from 1 to N. both are testcase level variables.
  ...  Arguments:
  ...  Provided as key in setup dictionary in setup section. N=1-X
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${repetition}=  Run Keyword And Return Status  Variable Should Exist  ${SETUP_KWARGS.N}
  ${repetition_count}=  Set Variable If  ${repetition}  ${SETUP_KWARGS.N}  1
  ${repetition_list}=  Create List
  FOR  ${index}  IN RANGE  ${repetition_count}
    Append To List  ${repetition_list}  ${index+1}
  END
  Set Test Variable  ${REPETITION_LIST}  ${repetition_list}
  Set Test Variable  ${REPETITION}  ${repetition}
  Set Test Variable  ${REPETITION_COUNT}  ${repetition_count}
  [Return]  ${repetition}  ${repetition_list}

Suite Precondition
  [Documentation]
  ...  Description: Creates a basic set of parameters related to suite level of execution. Logs variables before and after keyword execution.
  ...  Prepares Report.txt file with used libraries and python version.
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Log Variables
  Set Library Search Order  robot.libraries.DateTime  admin  admin_im  taf.sw.reporting_portal
  Prepare Suite Level Variables For Every Testcase
  Report Python Version And Libraries Used During Testing To Report File
  Log Variables

Suite Postcondition
  [Documentation]
  ...  Description:
  ...  Post suite level procedurews, in this suite only varaibles arelog and robot env is cleared.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | scfc_file_path         | Yes  | Path to scf file                                                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Log Variables
  Cleanup Robot Environment

Prepare Suite Level Variables For Every Testcase
  [Documentation]
  ...  Description:
  ...  Creates suite level variables:
  ...  CFG - empty variable to be used in further procedures, it contains all information needed to perform testcase execution and test scenarios
  ...  EXTENDED_RESERVATION_DICT, BASIC_RESERVATION_DICT, - both variable are taken from reservation files prepared by UTE, contains basic
  ...  information of testline and requested and trigerred software version
  ...  CM_TOPOLOGY, - variant used by user to reserve testline,
  ...  TESTLINE, - name of testline taken from global CONFIGURATION variable
  ...  FULL_CONFIG_HOSTNAME_PATH, - path to directory with testline configuration files
  ...  RELEASE - if not provided by user it is taken form reservation file, in case of lack both SBTS00 is used as reference,
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  &{CFG}=  Create Dictionary
  &{tmp_dict}=  Create Dictionary  &{EMPTY}
  Set To Dictionary  ${CFG}  NODES=${tmp_dict}
  Set Suite Variable  ${CFG}  ${CFG}
  ${basic_reservation_file}=  Run Keyword And Return Status
  ...  operatingsystem.file should exist  path=/opt/ute/reservation.json
  ${extended_reservation_file}=  Run Keyword And Return Status
  ...  operatingsystem.file should exist  path=/opt/ute/reservation.context.json
  IF  ${basic_reservation_file}
    ${basic_reservation_dict}=  Run Keyword And Continue On Failure  Load Json File As Dictionary  /opt/ute/reservation.json
  ELSE
    ${basic_reservation_dict}=  Set Variable  &{EMPTY}
  END
  IF  ${extended_reservation_file}
    ${extended_reservation_dict}=  Run Keyword And Continue On Failure  Load Json File As Dictionary  /opt/ute/reservation.context.json
  ELSE
    ${extended_reservation_dict}=  Set Variable  &{EMPTY}
  END
  Set Suite Variable  ${EXTENDED_RESERVATION_DICT}  ${extended_reservation_dict}
  Set Suite Variable  ${BASIC_RESERVATION_DICT}  ${basic_reservation_dict}
  Set Suite Logs Dir Path
  ${SITE}  ${TESTLINE}=  Split String  string=${CONFIGURATION}  separator=.
  IF  ${basic_reservation_file}
    ${CM_TOPOLOGY}=  Get Variable Value  ${BASIC_RESERVATION_DICT['topology']}  ${CM_TOPOLOGY}
  ELSE
    ${CM_TOPOLOGY}=  Set Variable  ${None}
  END
  IF  ${basic_reservation_file}
    ${CM_VARIANT}=  Get Variable Value  ${BASIC_RESERVATION_DICT['CM_VARIANT']}  ${CM_TOPOLOGY}
  ELSE
    ${CM_VARIANT}=  Set Variable  ${None}
  END
  IF  ${basic_reservation_file}
    ${CM_SOFTWARE}=  Get Variable Value  ${BASIC_RESERVATION_DICT['enb_build']}  SBTS00_0000
  ELSE
    ${CM_SOFTWARE}=  Set Variable  ${None}
  END
  IF  ${extended_reservation_file}
    ${CM_STATE}=  Get Variable Value  ${EXTENDED_RESERVATION_DICT['CM_REQUIRE_STATE']}  not_known
  ELSE
    ${CM_STATE}=  Set Variable  ${None}
  END
  IF  ${basic_reservation_file}
    ${sw_name_split}=  Split String  ${CM_SOFTWARE}  _  1
  ELSE
    ${sw_name_split}=  Set Variable  ${None}
  END
  IF  ${basic_reservation_file}
    ${RELEASE}=  Set Variable  ${sw_name_split[0]}
  ELSE
    ${RELEASE}=  Set Variable  SBTS00
  END
  Set Suite Variable  ${SITE}  ${SITE}
  Set Suite Variable  ${TESTLINE}  ${TESTLINE}
  Set Global Variable  ${CM_TOPOLOGY}  ${CM_TOPOLOGY}
  Set Global Variable  ${CM_VARIANT}  ${CM_VARIANT}
  Set Global Variable  ${CM_STATE}  ${CM_STATE}
  Set Global Variable  ${CM_SOFTWARE}  ${CM_SOFTWARE}
  Set Global Variable  ${RELEASE}  ${RELEASE}
  Logging With Timestamp  testline = ${TESTLINE}
  ${testline_directory_status}=  Run Keyword And Return Status
  ...  OperatingSystem.Directory Should Exist  /home/ute/testline_configuration/${TESTLINE}
  ${full_config_hostname_path}=  Set Variable If  ${testline_directory_status}  /home/ute/testline_configuration/${TESTLINE}
  Set Global Variable  ${FULL_CONFIG_HOSTNAME_PATH}  ${full_config_hostname_path}/

Set Suite Logs Dir Path
  [Documentation]
  ...  Description:
  ...  Creates suite level log path and directory.
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  ${year}  ${month}  ${day}  ${hour}  ${min}  ${sec}=  Get Time  year,month,day,hour,min,sec
  ${logs_dir_path}=  Normalize Path  ${OUTPUT_DIR}/${year}-${month}-${day}-${hour}-${min}-${sec}_${SUITE_NAME}/
  ${logs_dir_path}=  Replace String  ${logs_dir_path}  ${SPACE}  _
  Create Directory  ${logs_dir_path}
  Set Suite Variable  ${SUITE_LOGS_DIR_PATH}  ${logs_dir_path}${/}
  Set To Dictionary  ${CFG}  suite_logs_path=${logs_dir_path}${/}

Create Initial Directory Path
  [Documentation]
  ...  Description:
  ...  Creates testcase level log path: TEST_LOGS_DIR_PATH
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  ${test_logs_dir_path}=  Normalize Path  ${CFG.suite_logs_path}/${TEST_NAME}
  ${test_logs_dir_path}=  Replace String  ${test_logs_dir_path}  ${SPACE}  _
  Create Directory  ${test_logs_dir_path}
  Create Directory  ${test_logs_dir_path}${/}Setup/
  Create Directory  ${test_logs_dir_path}${/}Setup/BTSFiles/
  Create Directory  ${test_logs_dir_path}${/}Setup/UDPlog/
  Create Directory  ${test_logs_dir_path}${/}Setup/TestFiles/
  Run Keyword And Return Status  Wait Until Created  ${test_logs_dir_path}  5 seconds
  Set Test Variable  ${TEST_LOGS_DIR_PATH}  ${test_logs_dir_path}
  Set Test Variable  ${TEST_LOGS_PATH}  ${test_logs_dir_path}${/}Setup/
  Set To Dictionary  ${CFG}  test_logs_path=${test_logs_dir_path}

Create Setup Directory Path For Each Node
  [Documentation]
  ...  Description:
  ...  Creates setup level log paths for every BTS
  ...  Author: daniel.bartkowiak@nokia.com
  ...  Maintainer: daniel.bartkowiak@nokia.com
  FOR  ${bts_id}  IN  @{CFG.NODES}
    Create Directory  ${test_logs_dir_path}${/}Setup/BTSFiles/${bts_id}
    Create Directory  ${test_logs_dir_path}${/}Setup/UDPlog/${bts_id}
    Create Directory  ${test_logs_dir_path}${/}Setup/TestFiles/${bts_id}
  END

Create Logging Index Dictionary For Each BTS
  [Documentation]
  ...  Description:
  ...  creates initial dictionary with logiing index for each BTS:
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  ${bts_list}=  Get Dictionary Keys  ${CFG.NODES}
  FOR  ${bts_id}  IN  @{bts_list}
    Set To Dictionary  ${log_node_index}  ${bts_id}=0
  END
  Set Test Variable  ${LOG_NODE_INDEX}  ${log_node_index}

Create Testcase Directory Path For Each BTS
  [Arguments]  ${logs_dir_path}=${TEST_LOGS_DIR_PATH}
  [Documentation]
  ...  Description:
  ...  Creates testcase level log path: TEST_LOGS_DIR_PATH
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | logs_dir_path          | No   | Path to log directory                                              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  FOR  ${bts_id}  IN  @{CFG.active_bts_list}
    ${bts_test_logs_dir_path}=  Normalize Path  ${logs_dir_path}/BTSFiles/${bts_id}
    ${udp_test_logs_dir_path}=  Normalize Path  ${logs_dir_path}/UDPlog/${bts_id}
    ${testfiles_logs_dir_path}=  Normalize Path  ${logs_dir_path}/TestFiles/${bts_id}
    Create Directory  ${bts_test_logs_dir_path}
    Create Directory  ${udp_test_logs_dir_path}
    Create Directory  ${testfiles_logs_dir_path}
  END

Report Python Version And Libraries Used During Testing To Report File
  [Arguments]  ${log_path}=${SUITE_LOGS_DIR_PATH}
  [Documentation]
  ...  Description:
  ...  Keyword Save list of current libraries and python version installed in robot env.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | dir_path               | No   | directory path for used_library_list.txt file                              |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${output_pip}=  Run  pip freeze
  ${output_python}=  Run  pyenv version
  Create File  ${log_path}/used_library_list.txt  ${output_pip}${\n}${\n}python version=${output_python}

Software Check And Correct
  [Arguments]  ${timeout}=${CONFIGURATION_SWUPDATE_TIMEOUT}
  [Documentation]  KW used for updating SW on BTS hardware if version mismatch detected between hardware (RMOD, ASIRMOD, FHS)
  ...  and actual build on BTS. Software comparision is made based on TargetBD file.
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...  | Argument           | Man.  | Description                                                                                   |
  ...  +====================+=======+===============================================================================================+
  ...  | timeout            | No    | timeout for SW upodate                                                                        |
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  Return From Keyword If  ${RECONFIGURATION_NOT_NEEDED}
  ${bts_id_list}=  Get Dictionary Keys  ${CFG.NODES}
  FOR  ${bts_id}  IN  @{bts_id_list}
    Get File From System Module For Bts
    ...  bts_id=${bts_id}
    ...  source_path=/ffs/run/TargetBD_${CFG['NODES']['${bts_id}']['software_active']}.xml
    ...  destination_path=${CFG.test_logs_path}/Setup/BTSFiles/${bts_id}/TargetBD_${bts_id}_${CFG['NODES']['${bts_id}']['software_active']}.xml
    ${sw_status_fhs}=  SWM Check HW List SW Version Is Compatible With BTS SW
    ...  class=FHS
    ...  serial_number_list=${cfg.NODES['${bts_id}']['scf_hw_fhs_list']}
    ...  targetbd_path=${CFG.test_logs_path}/Setup/BTSFiles/${bts_id}/TargetBD_${bts_id}_${CFG['NODES']['${bts_id}']['software_active']}.xml
    ...  alias=${bts_id}
    ${sw_status_fr}=  SWM Check HW List SW Version Is Compatible With BTS SW
    ...  class=RMOD
    ...  serial_number_list=${CFG.NODES['${bts_id}']['scf_hw_fr_list']}
    ...  targetbd_path=${CFG.test_logs_path}/Setup/BTSFiles/${bts_id}/TargetBD_${bts_id}_${CFG['NODES']['${bts_id}']['software_active']}.xml
    ...  alias=${bts_id}
    ${sw_status_asir}=  SWM Check HW List SW Version Is Compatible With BTS SW
    ...  class=ASIRMOD
    ...  serial_number_list=${CFG.NODES['${bts_id}']['scf_hw_asir_list']}
    ...  targetbd_path=${CFG.test_logs_path}/Setup/BTSFiles/${bts_id}/TargetBD_${bts_id}_${CFG['NODES']['${bts_id}']['software_active']}.xml
    ...  alias=${bts_id}
    IF  "${sw_status_fr}"=="False" or "${sw_status_asir}"=="False" or "${sw_status_fhs}"=="False"
      Perform SW Correction  ${bts_id}  ${timeout}
    ELSE
      STATE Check Node HW Status  ${bts_id}
    END
  END
  Wait Until Keyword Succeeds  ${CONFIGURATION_SWUPDATE_TIMEOUT}  62  STATE Verify Multi Node State
  ...  expected_BTS_status=OnAir
  ...  HW_check=${TRUE}
  ...  cells_check=${TRUE}
  ...  scf_check=${TRUE}
  ...  timeout=${timeout}
  [Teardown]  Run Keyword If  "${KEYWORD_STATUS}"=="FAIL"  Logging With Timestamp
  ...  message=::: Fail while trying to correct SW on BTS-${bts_id} hardware:::  style=FAIL
  ...  ELSE IF  not ${RECONFIGURATION_NOT_NEEDED}  Logging With Timestamp
  ...  message=::: SW on tested hardware is aligned :::  style=DONE

Perform SW Correction
  [Arguments]  ${bts_id}  ${timeout}
  [Documentation]  KW for executing software update and HW state check. KW also performs Fault 4001 check and executes
  ...  power reboot of BTS
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...  | Argument           | Man.  | Description                                                                                   |
  ...  +====================+=======+===============================================================================================+
  ...  | bts_id             | Yes   | id of current BTS                                                                             |
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...  | timeout            | Yes   | timeout for SW upodate                                                                        |
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  Logging With Timestamp
  ...  message=HW Software mismatch - running software update procedure
  ...  style=WARNING
  ${software_active_file}=  SWM Check Main Software Package Availability  ${cfg.NODES['${bts_id}']['software_active']}  ${bts_id}
  Set To Dictionary  ${cfg.NODES['${bts_id}']}  software_active_file=${software_active_file}
  Run Keyword And Ignore Error  admin.Wait Sw Update Possible
  ...  bts_ready=True
  ...  readiness_timeout=750
  ...  timeout=800
  ...  connection=${bts_id}
  admin.Update Software
  ...  sw_package=${cfg.NODES['${bts_id}']['software_active_file']}
  ...  timeout=${timeout}
  ...  connection=${bts_id}
  STATE Check Node HW Status  ${bts_id}
  Wait For 4001 After Update  ${bts_id}

Wait For 4001 After Update
  [Arguments]  ${bts_id}
  [Documentation]  KW for executing power reset when fault 4001 appears.
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...  | Argument           | Man.  | Description                                                                                   |
  ...  +====================+=======+===============================================================================================+
  ...  | bts_id             | Yes   | id of current BTS                                                                             |
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ${bts_reset_needed}=  Run Keyword And Return Status  admin.Assert Alarm Active
  ...  faultId=4001
  ...  timeout=${SETUP_CHECK_4001_ALARM_AFTER_SWUPDATE_TIMEOUT}
  ...  connection=${bts_id}
  IF  ${bts_reset_needed}
    PDU Start Power Reset On Node  ${bts_id}
    STATE Check Node HW Status  ${bts_id}
  END

#KW related to recommisioning and preparation of hardware

Prepare Commissioning For Tested Configuration
  [Documentation]
  ...  Description:
  ...  Setup step to make recommissioning of current set of configurations. It is related to ${RECONFIGURATION_NOT_NEEDED} variable created during
  ...  setup preparation. After recommissioning procedure restart admin api sesion is executed.
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Return From Keyword If  ${RECONFIGURATION_NOT_NEEDED}  Commissioning not needed
  IF  ${CUSTOM_SWITCH_PERFORM_RESET_CONFIGURATION_IN_SETUP}
    CM Perform Multinode Reset Configuration
    Setup Logging Session Multinode Restart  ${CFG.test_logs_path}/Setup/
  END
  CM Perform Multinode Template File Commissioning
  Setup Logging Session Multinode Restart  ${CFG.test_logs_path}/Setup/

Get File From System Module For Bts
  [Arguments]  ${bts_id}  ${source_path}  ${destination_path}
  [Documentation]  KW for getting file from master smod on specific BTS
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...  | Argument           | Man.  | Description                                                                                   |
  ...  +====================+=======+===============================================================================================+
  ...  | bts_id             | Yes   | id of current BTS                                                                             |
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ${conn_type}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  bts_alias_type
  IF  "${conn_type}" == "localhost"
    SSH Get File From System Module  source_path=${source_path}  destination_path=${destination_path}
  ELSE IF  "${CFG['configuration_setup_type']}"=="mplane"
    SSH Get File From System Module
    ...  source_path=${source_path}
    ...  destination_path=${destination_path}
    ...  target_ip=${CFG.NODES['${bts_id}']['bts_ip_address']}
  ELSE
    SSH Get File From System Module
    ...  source_path=${source_path}
    ...  destination_path=${destination_path}
    ...  via_ip=${CFG.NODES['${bts_id}']['bts_ip_address']}
  END

Prepare Hardware For Tested Set Of Configurations
  [Documentation]
  ...  Description:
  ...  This procedure prepares hardware needed by set of configurations. It disable entire hardwware from init file if it is not needed.
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Return From Keyword If  ${RECONFIGURATION_NOT_NEEDED}  Commissioning not needed
  Logging With Timestamp
  ...  message=Hardware enable and disable for tested configuration  style=ONGOING
  ${rms_list}=  Create List Of All Object Type From Topology Class  RU
  ${fhs_list}=  Create List Of All Object Type From Topology Class  FHS
  ${bbmod_list}=  Create List Of All Object Type From Topology Class  CapacityUnit
  ${sm_list1}=  Create List Of All Object Type From Topology Class  CommonUnit
  ${sm_list2}=  Create List Of All Object Type From Topology Class  CoreUnit
  ${manual_provided_pdus}=  Create List  @{EMPTY}
  ${status}=  Run Keyword And Return Status  Should Not Be Empty  ${CUSTOM_PDU_CONFIG}
  IF  ${status}
    ${manual_provided_pdus}=  Get Dictionary Keys  ${CUSTOM_PDU_CONFIG}
  ELSE
    ${manual_provided_pdus}=  Set Variable  ${None}
  END
  IF  ${status}
    ${all_hardware_list}=  Combine Lists  ${rms_list}  ${fhs_list}  ${bbmod_list}  ${sm_list1}  ${sm_list2}  ${manual_provided_pdus}
  ELSE
    ${all_hardware_list}=  Combine Lists  ${rms_list}  ${fhs_list}  ${bbmod_list}  ${sm_list1}  ${sm_list2}
  END
  ${all_hardware_list}=  Remove Duplicates  ${all_hardware_list}
  @{tested_configuration_hw_list}=  Create List
  FOR  ${bts}  IN  @{CFG.NODES}
    ${bts_hw_list}=  Combine Lists
    ...  ${CFG.NODES['${bts}']['scf_hw_fr_list']}
    ...  ${CFG.NODES['${bts}']['scf_hw_asir_list']}
    ...  ${CFG.NODES['${bts}']['scf_hw_sm_list']}
    ...  ${CFG.NODES['${bts}']['scf_hw_fhs_list']}
    ...  ${CFG.NODES['${bts}']['scf_hw_bbmod_list']}
    Append To List  ${tested_configuration_hw_list}  @{bts_hw_list}
  END
  Remove Values From List  ${all_hardware_list}  @{tested_configuration_hw_list}
  IF  ${all_hardware_list}
    Run Keyword And Ignore Error  PDU.PDU Switch OFF Device Lists  ${all_hardware_list}
  END
  Optical Reconfiguration Tested Configuration  ${CFG.configuration_name}
  Enable Needed Hardware
  Logging With Timestamp
  ...  message=Hardware preparation for tested set of configurations finished.  style=DONE

Create List Of All Object Type From Topology Class
  [Arguments]  ${object_type}
  [Documentation]
  ...  Description:
  ...  This procedure prepares list of all objects within init file. It returns list type variable.
  ...
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...  | Argument           | Man.  | Description                                                                                   |
  ...  +====================+=======+===============================================================================================+
  ...  | object_type        | Yes   | type of Testline class object                                                                 |
  ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  @{object_init_list}=  Create List
  ${objects_list}=  Run Keyword And Continue On Failure  Find Objects Of Class  ${TL}  ${object_type}
  FOR  ${object}  IN  @{objects_list}
    ${serial_number}=  Set Variable  ${object.serial_number}
    Append To List  ${object_init_list}  ${serial_number}
  END
  [Return]  ${object_init_list}

Enable Needed Hardware
  [Documentation]
  ...  Description:
  ...  This procedure activates power on PDU devices for requested list of hardware serial numbers. Hardware list is prepare using CFG description.
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  @{tested_configuration_hw_list}=  Create List
  FOR  ${bts}  IN  @{CFG.NODES}
    ${bts_hw_list}=  Combine Lists
    ...  ${CFG.NODES['${bts}']['scf_hw_fr_list']}
    ...  ${CFG.NODES['${bts}']['scf_hw_asir_list']}
    ...  ${CFG.NODES['${bts}']['scf_hw_sm_list']}
    ...  ${CFG.NODES['${bts}']['scf_hw_fhs_list']}
    ...  ${CFG.NODES['${bts}']['scf_hw_bbmod_list']}
    Append To List  ${tested_configuration_hw_list}  @{bts_hw_list}
  END
  Run Keyword And Ignore Error  PDU.PDU Switch ON Device Lists  ${tested_configuration_hw_list}

Check Variant State After Testline Setup
  [Documentation]
  ...  Description:
  ...  This procedure verifies if requested variant configuration was prepared by agent before setup.
  ...  In case of first failure Hardware listed for variant is activated and state is checked again.
  ...  In case of success variable ${RECONFIGURATION_NOT_NEEDED} is set to True to disable refactoring of configuration.
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Return From Keyword If  ${RECONFIGURATION_NOT_NEEDED}
  Logging With Timestamp
  ...  message=Verification of requestred state for Variant Configuration  style=ONGOING
  IF  not ${RECONFIGURATION_NOT_NEEDED} and ${CUSTOM_FORCE_RECONFIGURATION}
    Set Test Variable  ${RECONFIGURATION_NOT_NEEDED}  ${False}
    Logging With Timestamp
    ...  message=Variant Configuration is set to Force, skipping verification  style=DONE
    Return From Keyword
  END
  ${variant_state}=  Run Keyword And Return Status  STATE Verify Multi Node State
  ...  expected_BTS_status=OnAir
  ...  HW_check=${TRUE}
  ...  cells_check=${TRUE}
  ...  scf_check=${TRUE}
  ...  timeout=5
  IF  not ${variant_state}
    Enable Needed Hardware
  END
  ${variant_state}=  Run Keyword And Return Status  Run Keyword If  not ${variant_state}
  ...  STATE Verify Multi Node State
  ...  expected_BTS_status=OnAir
  ...  HW_check=${TRUE}
  ...  cells_check=${TRUE}
  ...  scf_check=${TRUE}
  ...  timeout=${SETUP_CHECK_ONAIR_STATE_TIMEOUT}
  ${reconfiguration_not_needed}=  Set Variable If  ${variant_state}  ${True}  ${False}
  Set Test Variable  ${RECONFIGURATION_NOT_NEEDED}  ${reconfiguration_not_needed}
  ${verification_msg}=  Set Variable If  ${variant_state}  Passed  Failed
  Logging With Timestamp
  ...  message=Verification of requestred state for Variant Configuration finished with state:${verification_msg}  style=DONE

Check Unexpected And Historical Faults For All Nodes During Setup
  [Documentation]
  ...  Description:
  ...  This procedure verifies active and historical faults during setup. Faults are defined in the same way as GLOBAL_ALLOWED_FAULTS
  ...   variable but instead there is separate variable available - GLOBAL_SETUP_FAULT_LIST
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Set Test Variable  ${GLOBAL_SETUP_ALLOWED_FAULTS}  ${GLOBAL_SETUP_ALLOWED_FAULTS}
  Return From Keyword If  not ${LOGGING_SESSION_ACTIVE}
  FM Clear Allowed Alarms For All Nodes
  FM Add Global Faults To Allowed For All Nodes  ${GLOBAL_SETUP_ALLOWED_FAULTS}
  FM Add Custom Global Faults To Allowed For All Nodes
  FM Check Unexpected And Historical Faults For All Nodes
  FM Clear Allowed Alarms For All Nodes
  Check 2400 Fault After Setup And Execute Site Reset If Needed

Optical Reconfiguration Tested Configuration
  [Arguments]  ${scfc_configuration}
  [Documentation]
  ...  Description:
  ...  KW use in Setup to prepare optical reconfiguration of Leoni optical swithes.
  ...  Definition is provided in dictionary variable with name the same as tested configuration.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | scfc_configuration     | yes  | configuration name from CFG dictionary, it is also a name of dictionary    |
  ...  |                        |      | variable                                                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${out_os}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${${scfc_configuration}}  OS
  IF  "${out_os}" == "True"
    ${os_switch_configuration}=  Get From Dictionary  ${${scfc_configuration}}  OS
  ELSE
    ${os_switch_configuration}=  Set Variable  ${None}
  END
  IF  "${out_os}" == "True"
    Optical Switch Set Configuration  ${os_switch_configuration}
  END

Test Case Execution Summary
  [Documentation]
  ...  Description:
  ...  KW generates report: Test Case execution summary and log it into console logs and
  ...  also to tc_verdicts_report.txt located in Suite logs folder.
  ...
  ...  Author: anna.maciejewska@nokia.com
  ...  Maintainer: anna.maciejewska@nokia.com

  Run Keyword And Return If  '${CFG.configuration_name}'=='Failed'  Run Keywords
  ...  Logging With Timestamp  message=Test Case execution summary:  message_2=Configuration Precondition: FAIL \n FAIL REASON: ${TEST_MESSAGE}
  ...  style=FAIL  frame=True  AND
  ...  Logging With Timestamp  message=Test Case execution summary:  message_2=Configuration Precondition: FAIL \n FAIL REASON: ${TEST_MESSAGE}
  ...  frame=True  console=False
  ...  output_file=tc_verdicts_report.txt
  Run Keyword And Return If  ${ITERATION}==0 and '${TEST_STATUS}'=='PASS'  Run Keywords
  ...  Logging With Timestamp  message=Test Case execution summary:  message_2=TC_Name: ${TEST_NAME} \n TC_verdict: PASS  style=PASS  frame=True
  ...  AND
  ...  Logging With Timestamp  message=Test Case execution summary:  message_2=TC_Name: ${TEST_NAME} \n TC_verdict: PASS  frame=True  console=False
  ...  output_file=tc_verdicts_report.txt
  Run Keyword And Return If  ${ITERATION}==0 and '${TEST_STATUS}'=='FAIL'  Run Keywords
  ...  Logging With Timestamp  message=TC verdict: FAIL
  ...  style=FAIL  console=False  output_file=tc_verdicts_report.txt  AND
  ...  Logging With Timestamp  message=FAIL REASON: ${TEST_MESSAGE}  frame=True  console=False  output_file=tc_verdicts_report.txt  AND
  ...  Logging With Timestamp
  ...  message=Test Case execution summary:
  ...  message_2=TC_Name: ${TEST_NAME} \n TC_verdict: FAIL \n FAIL REASON: ${TEST_MESSAGE}
  ...  style=FAIL  frame=True  AND
  ...  Logging With Timestamp  message=Test Case execution summary:  message_2=TC_Name: ${TEST_NAME} \n TC_verdict: FAIL  frame=True  console=False
  ...  output_file=tc_verdicts_report.txt
  Run Keyword And Return If  ${ITERATION}!=0 and '${LOOP_EXECUTION_REPORT_DICT.TC_verdict}'=='PASS'  Run Keywords
  ...  Logging With Timestamp  message=Test Case execution summary:  message_2=${LOOP_EXECUTION_REPORT_DICT}  style=PASS  frame=True  AND
  ...  Logging With Timestamp  message=Test Case execution summary:  message_2=${LOOP_EXECUTION_REPORT_DICT}  frame=True  console=False
  ...  output_file=tc_verdicts_report.txt
  Run Keyword And Return If  ${ITERATION}!=0 and '${LOOP_EXECUTION_REPORT_DICT.TC_verdict}'=='FAIL'  Run Keywords
  ...  Logging With Timestamp  message=Test Case execution summary:  message_2=${LOOP_EXECUTION_REPORT_DICT}  style=FAIL  frame=True  AND
  ...  Logging With Timestamp  message=Test Case execution summary:  message_2=${LOOP_EXECUTION_REPORT_DICT}  frame=True  console=False
  ...  output_file=tc_verdicts_report.txt

Check 2400 Fault After Setup And Execute Site Reset If Needed
  [Documentation]
  ...  Description:
  ...  This procedure checks if fault 2400 is active after setup. In case it is active site reset is performed.
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer:
  IF  not (${CUSTOM_SETUP_FAULT_ID_2400_CHECK_ENABLED} and ${CUSTOM_SWITCH_PERFORM_HW_SETUP})
    Logging With Timestamp
    ...  message=Checking for fault 2400 after setup is not executed.
    RETURN
  END
  Logging With Timestamp
  ...  message=Checking for fault 2400 after setup
  ...  style=ONGOING
  FOR  ${bts_id}  IN  @{CFG.NODES}
    @{fault_history_list}=  admin.Get Historic Alarms  connection=${bts_id}  load_history=True
    FOR  ${fault_dict}  IN  @{fault_history_list}
      IF  '${fault_dict['faultId']}'=='2400'
        Logging With Timestamp
        ...  message=Fault 2400 detected after setup on BTS-${bts_id}, performing site reset
        ...  style=WARNING
        ${reset_response}=  Run Keyword And Continue On Failure    admin.Reset Site
        ...  connection=${bts_id}
        ...  wait_for_reconnection=True
        ...  detailed_output=True
        ...  graceful_cell_shutdown=${FALSE}
        ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
         CM BTS Admin Not Available
        ...  node=${bts_id}
        ...  timeout=120
        Logging With Timestamp  message=Site reset procedure finished on BTS-${bts_id}  style=ONGOING
        STATE Verify BTS states
        ...  node_id=${bts_id}
        ...  expected_BTS_status=OnAir
        ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
        Exit For Loop
      END
    END
  END
  Logging With Timestamp
  ...  message=Checking for fault 2400 after setup finished
  ...  style=DONE
