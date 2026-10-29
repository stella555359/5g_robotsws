*** Settings ***
Documentation    Keywords for Frame RFS Common
Resource          rfs_general.robot
Resource          rfs_admin.robot
Resource          rfs_rnc.robot
Resource          rfs_optical_switch.robot
Resource          rfs_dcap.robot
Resource          rfs_rf_attenuator.robot
Resource          rfs_ims.robot
Resource          rfs_taf_ue.robot
Resource          rfs_scf.robot
Resource          rfs_cu.robot
Resource          rfs_vdu.robot
Resource          rfs_procedures.robot
Resource          rfs_logging.robot
Resource          rfs_webem_vdu.robot
Resource          rfs_webem_vcu.robot
Resource          rfs_webem_sbts.robot

Library           yaml
Library           taf.sw.reporting_portal  WITH NAME  repo
Library           taf.sw.scout  WITH NAME  scout
Library           python_resources/notification_sender.py
Library           python_resources/BshReplacement.py
Library           taf.rfrl.common_resources.python.reset_bts_configuration
Library           python_resources/ims2analysis.py  WITH NAME  ims2alarms
Library           ../../resources/python_resources/admin_cli.py   WITH NAME  admin_cli
Library           python_resources/memory_consumption.py  WITH NAME  memory_consumption
Library           python_resources/rmod_led_checker/rmod_led_checker_client.py  WITH NAME  rmod_led_checker

*** Variables ***
# QC parameters
@{qc_allowed_parameters}=  qc_tc_swbuild  qc_tc_cubuild

*** Keywords ***

TAF UTE Cloud ENV Config Adapter
    [Documentation]
    ...  TAF UTE Cloud ENV Config Adapter. This KW is used to load Testline configuration variables from a
    ...  __init__.py configuration file. It is used in the case where the test is launched from an
    ...  UTE Cloud enviroment where the configuration files are located in /robotlte/config folder
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com

    @{configuration}=  Split String  ${CONFIGURATION}  .
    @{tl_params}=  Split String  ${configuration}[1]  _
    Set Suite Variable  ${HW_LOCATION_CODE}  ${configuration}[0]
    Set Suite Variable  ${TESTLINE_NAME}  ${tl_params}[0]_${tl_params}[1]_${tl_params}[2]
    Set Test Variable  ${CLOUD_ENV}  ${True}
    Check Execution Type
    TAF Config Adapter

TAF HRAN ENV Config Adapter
    [Documentation]
    ...  TAF HRAN ENV Config Adapter. This KW is used to load Testline configuration variables from a
    ...  __init__.py configuration file. It is used in the case where the test is launched from a
    ...  HRAN Enviroment where the configuration files are located in /btsauto/hran_ta/config
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    [Tags]  robot:no-dry-run

    ${status_hw_location_code_variable}=  Run Keyword And Return Status  Variable Should Exist  ${HW_LOCATION_CODE}
    ${status_testline_name_variable}=  Run Keyword And Return Status  Variable Should Exist  ${TESTLINE_NAME}
    Run Keyword If  not (${status_hw_location_code_variable} and ${status_hw_location_code_variable})  Set Missing Variables

    OperatingSystem.File Should Exist  /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/__init__.py
    ${dir_status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  /home/ute/testline_configuration
    Run Keyword If  not ${dir_Status}  OperatingSystem.Create Directory  /home/ute/testline_configuration

    Process.Run Process  rm  -rf  /home/ute/testline_configuration/${TESTLINE_NAME}

    Process.Run Process  cp  -r  /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}
    ...  /home/ute/testline_configuration/${TESTLINE_NAME}
    Process.Run Process  cp  -r  /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/device/.
    ...  /home/ute/testline_configuration/${TESTLINE_NAME}
    Log  Copy for hran_ta TAF config created in testline_configuration  console=True

    Import Variables  /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/__init__.py
    Set Test Variable  ${CLOUD_ENV}  ${False}
    TAF Config Adapter

    [Teardown]  Process.Run Process  rm  -rf  /home/ute/testline_configuration/${TESTLINE_NAME}

TAF Config Adapter
    [Documentation]
    ...  TAF Config Adapter. This helper KW is used to import TAF Configuration Variables.
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    [Tags]  robot:no-dry-run

    Import Library  hran_testline_configuration  ${HW_LOCATION_CODE}  ${TESTLINE_NAME}
    hran_testline_configuration.Set TAF Config Variables  RFS
    Set tags  testline = ${TESTLINE_NAME}
    Log  Running test using TAF configuration file  console=True
    Additional Variables Loader

HRAN Config Adapter
    [Documentation]
    ...  HRAN Config Adapter. This KW is used to load Testline configuration variables from
    ...  YAML configuration files. It is used in the case where a test is launched from a HRAN
    ...  Enviroment where the configuration files are located in /btsauto/hran_ta/config
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    [Tags]  robot:no-dry-run

    Import Library  hran_testline_configuration  ${HW_LOCATION_CODE}  ${TESTLINE_NAME}
    hran_testline_configuration.Set Config Variables   @{TESTLINE_CONFIG_VARIABLES}
    Set Test Variable  ${CLOUD_ENV}  ${False}
    Log  Running test using HRAN configuration file  console=True

Configuration Loader
    [Documentation]
    ...  Configuration Loader. This KW loads configuration files based on the type of the enviroment
    ...  where the test is started from. It checks if the test is started from an UTE Cloud enviroment using
    ...  TAF Configuration Files or HRAN Enviroment using TAF Configuration Files or HRAN Enviroment using YAML
    ...  Configuration Files
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    [Arguments]  ${project}=soam

    Set Test Variable  ${CLOUD_ENV}  ${False}
    Set Test Variable  ${CM_RUN_ENV}  ${False}
    ${taf_ute_config_model}=  Run Keyword And Return Status  TAF UTE Cloud ENV Config Adapter
    Run Keyword If  ${taf_ute_config_model}  Run Keywords
    ...  Set Test Variable  ${TAF_CONFIG_MODEL}  ${True}
    ...  AND  OperatingSystem.Set Environment Variable  taf_config_format  ${TAF_CONFIG_MODEL}
    ...  AND  Load RFS TL flags
    ...  AND  Initialize feature flags
    ...  AND  Return From Keyword
    ...  ELSE IF  '${CLOUD_ENV}' == 'True'  Fail  There was a problem in init.py. Please check your init.py file.

    ${taf_hran_config_model}=  Run Keyword And Return Status  TAF HRAN ENV Config Adapter
    Run Keyword If  ${taf_hran_config_model}  Run Keywords
    ...  Set Test Variable  ${TAF_CONFIG_MODEL}  ${True}
    ...  AND  OperatingSystem.Set Environment Variable  taf_config_format  ${TAF_CONFIG_MODEL}
    ...  AND  Load RFS TL flags
    ...  AND  Initialize feature flags
    ...  AND  Return From Keyword

    ${hran_config_model}=  Run Keyword And Return Status  HRAN Config Adapter
    Run Keyword If  ${hran_config_model}  Run Keywords
    ...  Set Test Variable  ${TAF_CONFIG_MODEL}  ${False}
    ...  AND  OperatingSystem.Set Environment Variable  taf_config_format  ${TAF_CONFIG_MODEL}
    Run Keyword If  '${project}' == 'soam'  Run Keywords
    ...  Log  Support for YAML configuration files was dropped, please create TAF configuration file!  level=ERROR
    ...  AND  Fail  Support for YAML configuration files was dropped, please create TAF configuration file!
    ...  ELSE  Return From Keyword

    Fail  Testline configuration files are missing.

Additional Variables Loader
    [Tags]  robot:no-dry-run

    ${optical_switch_status}=  Run Keyword And Return Status  Import Variables  ${OPTICAL_SWITCH_CONFIG}
    ${attenuator_status}=  Run Keyword And Return Status  Import Variables  ${ATTENUATOR_CONFIG_PATH}
    ${target_logical_config_status}=  Run Keyword And Return Status  Import Variables  ${TARGET_LOGICAL_CONFIG_PATH}
    ${dcap_profiles_status}=  Run Keyword And Return Status  Import Variables  ${DCAP_PROFILES_CONFIG_PATH}
    ${rsi_status}=  Run Keyword And Return Status  Import Variables  ${RSI_CONFIG_PATH}
    ${cell_target_bw_status}=  Run Keyword And Return Status  Import Variables  ${CELL_TARGET_BW_PATH}

    Set Suite Variable  ${TEMP_LOGS_DIR}  /home/ute/btsauto/logs

    Run Keyword If  ${optical_switch_status}  Run Keyword
    ...  Log  TAF Additional Variables : OPTICAL SWITCH configuration variables successfully loaded  console=True

    Run Keyword If  ${attenuator_status}  Run Keyword
    ...  Log  TAF Additional Variables : PROGRAMABLE ATTENUATOR configuration variables successfully loaded  console=True

    Run Keyword If  ${target_logical_config_status}  Run Keywords
    ...  Log  TAF Additional Variables : TARGET LOGICAL configuration variables successfully loaded  console=True
    ...  AND  Update interfaces dict according to logical config info

    Run Keyword If  ${dcap_profiles_status}  Run Keyword
    ...  Log  TAF Additional Variables : DCAP PROFILES configuration variables successfully loaded  console=True

    Run Keyword If  ${rsi_status}  Run Keyword
    ...  Log  TAF Additional Variables : RSI configuration variables successfully loaded  console=True

    Run Keyword If  ${cell_target_bw_status}  Run Keyword
    ...  Log  TAF Additional Variables : Cell Target Bw variables successfully loaded  console=True

Load RFS TL flags
    [Documentation]
    ...  KW which loads RFS_TL_FLAGS dictionary as a variable from __init__.py configuration file.
    ...  It will set following flags:
    ...  - fail_if_unexpected_alarms:True if no RFS_TL_FLAGS defined. Has effect when running from CLOUD environment
    ...  - fail_if_wrn_threshold:True if no RFS_TL_FLAGS defined. Has effect when running from CLOUD environment
    ...  - fail_if_unexpected_rtwp:True if no RFS_TL_FLAGS defined. Has effect when running from CLOUD environment
    ...
    ...  *AUTHOR*
    ...  adelina.ivan@nokia.com

    ${status_fail_if_unexpected_alarms}=  Run Keyword And Return Status  Variable Should Exist  ${fail_if_unexpected_alarms}
    ${status_fail_if_wrn_threshold}=  Run Keyword And Return Status  Variable Should Exist  ${fail_if_wrn_threshold}
    ${status_fail_if_unexpected_rtwp}=  Run Keyword And Return Status  Variable Should Exist  ${fail_if_unexpected_rtwp}

    Run Keyword If  not ${status_fail_if_unexpected_alarms}  Set Test Variable  ${fail_if_unexpected_alarms}  True
    Run Keyword If  not ${status_fail_if_wrn_threshold}  Set Test Variable  ${fail_if_wrn_threshold}  True
    Run Keyword If  not ${status_fail_if_unexpected_rtwp}  Set Test Variable  ${fail_if_unexpected_rtwp}  True

    ${rfs_tl_flags_status}=  Run Keyword And Return Status  Variable Should Exist  ${RFS_TL_FLAGS}
    Run Keyword If  not ${rfs_tl_flags_status}  Run Keywords
    ...  Log  RFS TL FLAG: fail_if_unexpected_alarms = ${fail_if_unexpected_alarms}  console=True
    ...  AND  Log  RFS TL FLAG: fail_if_wrn_threshold = ${fail_if_wrn_threshold}  console=True
    ...  AND  Log  RFS TL FLAG: fail_if_unexpected_rtwp = ${fail_if_unexpected_rtwp}  console=True
    ...  AND  Return From Keyword
    FOR  ${key}  IN  @{RFS_TL_FLAGS}
        ${status_from_suite}=  Get Variable Value  ${status_${key}}  default
        Run Keyword If  '${status_from_suite}' != 'default' and '${status_from_suite}' == 'True'  Run Keywords
        ...  Log  RFS TL FLAG: ${key} = ${status_from_suite}  console=True
        ...  AND  Continue For Loop
        Set Test Variable  ${${key}}  ${RFS_TL_FLAGS['${key}']}
        Log  RFS TL FLAG: ${key} = ${RFS_TL_FLAGS['${key}']}  console=True
    END

Initialize feature flags
    [Documentation]
    ...  KW contains list of feature flags and default flag values
    ...  If one flag is not declared in suite, it will be created
    ...  as global variable with default value from flag dictionary.
    ...  Flag dictionary is declared in rfs_frame_rfs_soam_taf.robot

    ${flag_keys}=  Get Dictionary Keys  ${Feature_flag_dictionary}
    FOR  ${key}  IN  @{flag_keys}
        ${flag_present}=  Run Keyword And Return Status  Variable Should Exist  ${${key}}
        ${flag_value}=  Set Variable If  ${flag_present}  ${${key}}  ${Feature_flag_dictionary['${key}']}
        Set Test Variable  ${${key}}  ${flag_value}
    END

Load yaml config
    [Arguments]  ${yaml_path}
    ${yaml_content}=  OperatingSystem.Get File  ${yaml_path}
    ${loaded_yaml_file}=  yaml.Safe Load  ${yaml_content}

    [Return]  ${loaded_yaml_file}

Set Missing Variables
    ${scf_path_variable}=  OperatingSystem.Get Environment Variable  SCF_PATH  None
    @{path_elements}=  Split String  ${scf_path_variable}  /

    Set Suite Variable  ${HW_LOCATION_CODE}  ${path_elements}[6]
    Set Suite Variable  ${TESTLINE_NAME}  ${path_elements}[7]

Check Execution Type
    Log  Check if Cloud Manager run  console=True
    ${command}=  Set Variable  ps -ef | grep 'agent_robot run' | grep -v grep
    ${rc}  ${output}=  Run And Return Rc and Output  ${command}
    Run Keyword If  '${rc}' == '0'  Run Keywords
    ...  Log  Execution type is from Cloud Manager, variable CM_RUN_ENV=True  console=True
    ...  AND  Set Test Variable  ${CM_RUN_ENV}  ${True}
    ...  ELSE  Log  Execution type is offline/via Jenkins TAF, variable CM_RUN_ENV=False  console=True

Update interfaces dict according to logical config info
    [Documentation]
    ...  This KW's scope is to check wheter user has used global setted LOGICAL_CONFIG_LABEL containing info about active RMOD configuration
    ...  LOGICAL_CONFIG_LABEL can be set by user in robot test suite and value should be the same as active configuration label from
    ...  logical_config.yaml e.g LABEL_1
    ...  .........
    ...  logical_config.yaml content example:
    ...  my_pdu1: &PDU_logical_config
    ...       IP      :   10.255.2.86
    ...       TYPE    :   EPC
    ...  LOGICAL_CONFIG_OPTIONS:
    ...      LABEL_1:
    ...          RMOD_SN1 :
    ...              << :            *PDU_logical_config
    ...              OUTLET :        1
    ...              CONTACTOR :     NORMALLY_CLOSED
    ...              STATE:         'ON'
    ...          RMOD_SN2 :
    ...              << :            *PDU_logical_config
    ...              OUTLET :        2
    ...              CONTACTOR :     NORMALLY_CLOSED
    ...              STATE:         'OFF'
    ...
    ...  *AUTHOR*
    ...  adelina.branc@nokia.com

    Log  Update interfaces dict according to logical config info  console=True
    ${custom_logical_config}=  Get Variable Value  ${LOGICAL_CONFIG_LABEL}  ${EMPTY}

    Run Keyword If  '${custom_logical_config}' == '${EMPTY}'  Run Keywords
    ...  Log  No LOGICAL_CONFIG_LABEL declared in robot suite, skipping this part  console=True
    ...  AND  Return From Keyword

    ${logical_config_existence}=  Run Keyword and Return Status
    ...  Dictionary Should Contain Key  ${LOGICAL_CONFIG_OPTIONS}  ${custom_logical_config}
    Run Keyword If  '${logical_config_existence}' == '${FALSE}'
    ...  Fail  Given LOGICAL_CONFIG_LABEL is not matching logical_config.yaml configurations

    Merge logical config with current interface configurations  ${custom_logical_config}

Merge logical config with current interface configurations
    [Documentation]
    ...  Doc
    ...  This KW merges INTERFACES and custom logical config dictionaries by the following rules,
    ...  applied to each RMOD found in custom logical config:
    ...  - if one RMOD has state set on ON and is not present in interfaces.yaml, it is added
    ...  - if one RMOD has state set on OFF and is present in interfaces.yaml, it is removed
    ...  - if one RMOD has state set on OFF/ON and is NOT present in interfaces, no actions are taken
    ...  - also, as an extra check, each RMOD from interfaces.yaml that is not declared as active in custom logical configuration is removed
    ...
    ...  *AUTHOR*
    ...  adelina.branc@nokia.com
    ...
    ...  | Parameter                       | Man. | Description                         |
    ...  | custom_logical_config           | Yes  | logical_config label given by user  |

    [Arguments]  ${custom_logical_config}

    Log  Merge logical config with current interface configurations  console=True
    Log  before merge: ${INTERFACES}  level=TRACE

    ${custom_logical_config}=  Set Variable  ${custom_logical_config}
    ${keys_chosen_label}=  Get Dictionary Keys  ${LOGICAL_CONFIG_OPTIONS['${custom_logical_config}']}
    FOR  ${rmod_sn}  IN  @{keys_chosen_label}
        ${present_in_interfaces}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${INTERFACES}  ${rmod_sn}
        ${rmod_state}=  Get From Dictionary  ${LOGICAL_CONFIG_OPTIONS['${custom_logical_config}']['${rmod_sn}']}  STATE

        Run Keyword If  not ${present_in_interfaces}
        ...  Run Keyword If  '${rmod_state}'=='ON'
        ...  Set To Dictionary  ${INTERFACES}  ${rmod_sn}  ${LOGICAL_CONFIG_OPTIONS['${custom_logical_config}']['${rmod_sn}']}

        Run Keyword If  ${present_in_interfaces}
         ...  Run Keyword If  '${rmod_state}'=='OFF'
         ...  Remove From Dictionary  ${INTERFACES}  ${rmod_sn}
    END

    ${keys_from_interface}=  Get Dictionary Keys  ${INTERFACES}
    FOR  ${item_interfaces}  IN  @{keys_from_interface}
        ${key_rmod_matching}=  Run Keyword And Return Status  Should Match Regexp  ${item_interfaces}  RMOD_.*
        Continue For Loop If  '${key_rmod_matching}' == 'False'

        ${key_present_in_logical_config}=  Run Keyword And Return Status
        ...  Dictionary Should Contain Key  ${LOGICAL_CONFIG_OPTIONS['${custom_logical_config}']}  ${item_interfaces}
        Run Keyword If  '${key_present_in_logical_config}' == 'False'
        ...  Remove From Dictionary  ${INTERFACES}  ${item_interfaces}
    END
    Log  after merge: ${INTERFACES}  level=TRACE

Create SSH Connection to VM
    [Documentation]
    ...  Create SSH Connection to VM. Creates an SSH connection to the supplied alias VM
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    ...
    ...  | Parameter       | Man. | Description                 |                                               |
    ...  | alias           | Yes  | Alias, can be Master/Slave  |                                               |

    [Timeout]  15 min

    [Arguments]  ${alias}

    SSHlibrary.Open Connection  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]  alias=${alias}
    _SSHLibrary_Login_multiway  ${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]  ${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]
    Log  SSH Connection to ${alias} VM started successfuly  console=True

Close SSH Connection to VM
    [Documentation]
    ...  Close SSH Connection to VM. Closes the SSH connection with the supplied alias
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    ...
    ...  | Parameter       | Man. | Description                |                                                |
    ...  | alias           | Yes  | Alias, can be Master/Slave |                                              |

    [Timeout]  15 min

    [Arguments]  ${alias}

    SSHLibrary.Switch Connection  ${alias}
    SSHLibrary.Close Connection
    Log  SSH Connection to ${alias} VM closed successfuly  console=True

Create SSH Tunnel
    [Documentation]
    ...  Create SSH Tunnel. Creates an SSH Tunnel with the supplied parameters.
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    ...
    ...  | Parameter               | Man. | Description                  |                                                |
    ...  | alias                   | Yes  | Alias, can be Master/Slave   |
    ...  | REMOTE_ENB_IP_ADDRESS   | Yes  | IP address of the remote ENB |
    ...  | LOCAL_BIND_PORT         | Yes  | Local bind port              |
    ...  | REMOTE_ENB_ADMIN_PORT   | No   | Admin port of the remote ENB |
    ...  | LOCAL_BIND_IP_ADDRESS   | No   | Local bind IP address        |

    [Timeout]  15 min

    [Arguments]  ${REMOTE_ENB_IP_ADDRESS}  ${LOCAL_BIND_PORT}  ${alias}  ${REMOTE_ENB_ADMIN_PORT}=443  ${LOCAL_BIND_IP_ADDRESS}=192.168.255.126
    SSHLibrary.Switch Connection  ${alias}
    SSHLibrary.Create local SSH tunnel
    ...  local_port=${LOCAL_BIND_PORT}
    ...  remote_host=${REMOTE_ENB_IP_ADDRESS}
    ...  remote_port=${REMOTE_ENB_ADMIN_PORT}
    ...  bind_address=${LOCAL_BIND_IP_ADDRESS}
    Log  SSH Tunnel successfully created on ${alias}  console=True

Get Free Random Ephemeral Port
    [Documentation]
    ...  Get Free Randoim Ephemeral Port. Returns a random port from the ephemeral ports interval
    ...  which is not in use
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com

    [Timeout]  5 min
    FOR  ${i}  IN RANGE  0  9999
        ${random_port}=  Evaluate  random.randint(49152,60999)  modules=random
        ${netstat_string}=  Run  sudo netstat -anp | grep ':${random_port} '
        Exit For Loop If  """${netstat_string}""" == """${EMPTY}"""
    END

    [Return]  ${random_port}

Clean VM Disk Space
    # TODO: REMOVE AFTER RFSPLIT COMMON PART FULLY DELIVERED
    Clean Linux VM Disk Space  Master
    Clean Linux VM Disk Space  Slave

Clean Linux VM Disk Space
    [Arguments]  ${alias}
    Run Keyword If  '${alias}' == '${alias_local}'  Run Keywords
    ...  Clean Up Directory  /tmp  720  local
    ...  AND  Clean Up Directory  /home/ute/btsauto/logs  240  local
    ...  AND  Clean Up Directory  /var/lib/collectd/rrd/$(hostname).ute  120  local
    ...  AND  Return From Keyword

    Clean Up Directory  /tmp  720  remote
    ...  host_ip=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]  ssh_port=${${alias.upper()}}[${alias.upper()}_PC_SSH_PORT]
    ...  ssh_username=${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]  ssh_password=${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]
    Clean Up Directory  /home/ute/btsauto/logs  240  remote
    ...  host_ip=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]  ssh_port=${${alias.upper()}}[${alias.upper()}_PC_SSH_PORT]
    ...  ssh_username=${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]  ssh_password=${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]
    Clean Up Directory  /var/lib/collectd/rrd/$(hostname).ute  120  remote
    ...  host_ip=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]  ssh_port=${${alias.upper()}}[${alias.upper()}_PC_SSH_PORT]
    ...  ssh_username=${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]  ssh_password=${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]

Clean Windows VM Disk Space
    [Arguments]  ${alias}
    Clean Up Directory Windows  ~  720  remote
    ...  host_ip=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]  ssh_port=${${alias.upper()}}[${alias.upper()}_PC_SSH_PORT]
    ...  ssh_username=${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]  ssh_password=${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]
    Clean Up Directory Windows  "/cygdrive/c/Program Files (x86)/IronPython 2.7/Lib/site-packages/hran_elementmanager2g/logs"
    ...  720  remote  host_ip=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]  ssh_port=${${alias.upper()}}[${alias.upper()}_PC_SSH_PORT]
    ...  ssh_username=${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]  ssh_password=${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]
    Clean Up Directory Windows  "/cygdrive/c/Program Files/IronPython 2.7/Lib/site-packages/hran_elementmanager2g/logs"  720
    ...  remote  host_ip=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]  ssh_port=${${alias.upper()}}[${alias.upper()}_PC_SSH_PORT]
    ...  ssh_username=${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]  ssh_password=${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]

Check Linux VM Disk Space
    [Arguments]  ${alias}
    Run Keyword If  '${alias}' == '${alias_local}'  Run Keywords
    ...  Log  Check that VM ${alias} ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS] "/home/ute" disk space is at least 1024MB  console=True
    ...  AND  Check local VM required disk space  /home/ute  1024
    ...  AND  Log  Check that VM ${alias} ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS] "/" disk space is at least 1024MB  console=True
    ...  AND  Check local VM required disk space  /  1024
    ...  AND  Log  VM ${alias} disk space checked successfully  console=True
    ...  AND  Return From Keyword

    Log  Check that VM ${alias} ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS] "/home/ute" disk space is at least 1024MB  console=True
    Check remote VM required disk space  /home/ute  1024  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]  ${22}
    ...  ${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]  ${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]
    Log  Check that VM ${alias} ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS] "/" disk space is at least 1024MB  console=True
    Check remote VM required disk space  /  1024  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]  ${22}
    ...  ${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]  ${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]
    Log  VM ${alias} disk space checked successfully  console=True

Set Linux VM Python Path
    [Arguments]  ${alias}
    ${venv}=  Set Variable  /home/ute/test_repo/bin
    ${python_path}=  Create Long String
    ...  if [ "$(echo $PATH \| grep -v '${venv}')" ] && [ -z "$(cat /home/ute/.bashrc \| grep -o 'export PATH=${venv}')" ];
    ...  then echo "export PATH=${venv}:$PATH" >> $HOME/.bashrc; fi
    Run Keyword If  ${CLOUD_ENV}  Execute on Linux VM  command=${python_path}  alias=${alias}

Clear processes
    [Arguments]  ${alias}
    ${kill_node_cmd}=  Create Long String
    ...  if [ "$(ps aux | grep '\\snode.*admin.*bts-host.*\\s' | awk '{print $2}')" ];
    ...  then kill -9 $(ps aux | grep '\\snode.*admin.*bts-host.*\\s' | awk '{print $2}'); fi
    Run Keyword If  not ${CM_RUN_ENV}  Execute on Linux VM  command=${kill_node_cmd}  alias=${alias}

Execute on Linux VM
    [Arguments]  ${command}  ${alias}=local
    ${result_rc}=  Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Execute Local Command  command=${command}  ELSE
    ...  Execute Remote Command  command=${command}  index_or_alias=remote
    ...  host_ip=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]  ssh_port=${${alias.upper()}}[${alias.upper()}_PC_SSH_PORT]
    ...  ssh_username=${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]  ssh_password=${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]
    [Return]  ${result_rc}

Check VM Disk Space
    Check Linux VM Disk Space  Master

Start ADMIN On
    [Documentation]
    ...  Start Admin On. Starts Admin on the local or remote VM based on connection type
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    ...
    ...  | Parameter       | Man. | Description                                                       |
    ...  | alias           | Yes  | Alias of Admin instance                                           |
    ...  | connection_type | No   | Admin connection type. Can be ssh_tunnel, oam_ip, admin_forwarder |
    ...  | bts_ip          | No   | BTS ip used to establish Admin session                            |


    [Arguments]    ${alias}    ${connection_type}=admin_forwarder    ${bts_ip}=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]

    IF    '${connection_type}' not in ['admin_forwarder', 'oam_ip', 'ssh_tunnel']
        Fail    Wrong argument for ADMIN Connection, should be one of admin_forwarder, oam_ip or ssh_tunnel
    END

    ${admin_status}=    Run Keyword And Return Status    Teardown Admin    alias=${alias}
    ${host}=    Set Variable If    '${alias}' == '${alias_local}'    ${None}    ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]

    IF    '${connection_type}' == 'admin_forwarder' or ('${connection_type}' == 'ssh_tunnel' and '${alias}' == '${alias_local}')
        Start ADMIN using ADMIN FORWARDER On    alias=${alias}     host=${host}    bts_ip=${bts_ip}
    ELSE IF    '${connection_type}' == 'oam_ip'
        Start ADMIN using OAM IP On    alias=${alias}
    ELSE
        Start ADMIN using SSH TUNNEL On    alias=${alias}    bts_ip=${bts_ip}
    END

Start ADMIN On External BTS
    [Documentation]
    ...  Start Admin On External BTS. Starts Admin specific OAM IP address of External BTS sent as input argument
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter       | Man. | Description                                                                |
    ...  | bts_mplane_ip   | Yes  | Mplane IP of the External BTS where Admin will be connected                |
    ...  | alias           | No   | Alias of Admin instance; Default value: EXT_BTS                            |

    [Arguments]  ${bts_mplane_ip}  ${alias}=EXT_BTS
    [Timeout]  15 min
    ${status}=  Run Keyword and Return Status  Setup ADMIN  alias=${alias}  bts_host=${bts_mplane_ip}
    ...  bts_port=443  admin_api_log_dir=${BTSFiles}  timeout=120s
    Run Keyword If  ${status}  Run Keywords
    ...  Log  Setup ADMIN ${alias} successfully performed on port 443  console=True
    ...  AND  Return From Keyword
    ...  ELSE  Run Keywords
    ...  Log  ${alias} Setup ADMIN can't be established on port 443!  console=True
    ...  AND  Fail

Start ADMIN_INFOMODEL On External BTS
    [Documentation]
    ...  Start ADMIN_INFOMODEL On External BTS. Starts Admin specific OAM IP address of External BTS sent as input argument
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter       | Man. | Description                                                                |
    ...  | bts_mplane_ip   | Yes  | Mplane IP of the External BTS where Admin_INFOMODEL will be connected      |
    ...  | alias           | No   | Alias of Admin instance; Default value: EXT_BTS                            |

    [Arguments]  ${bts_mplane_ip}  ${alias}=EXT_BTS
    ${status}=  Run Keyword and Return Status  ute_admin_infomodel.Setup Infomodel  address=${bts_mplane_ip}  port=443  update_interval=500
    ...  timeout=120s  alias=${alias}
    Run Keyword If  ${status}  Run Keywords
    ...  Log  Setup Infomodel ${alias} successfully performed on port 443  console=True
    ...  AND  ute_admin_infomodel.Connect Infomodel  alias=${alias}  timeout=60
    ...  AND  Return From Keyword
    ...  ELSE  Run Keywords
    ...  Log  ${alias} Setup ADMIN Infomodel can't be established on port 443!  console=True
    ...  AND  Fail

Start new ADMIN instance
    [Documentation]
    ...  Start new BTS ADMIN instance. Starts new Admin instance on the local or remote VM based on connection type
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter       | Man. | Description                                                       |
    ...  | alias           | Yes  | Alias of Admin instance                                           |
    ...  | new_alias       | Yes  | New alias of Admin instance                                       |
    ...  | connection_type | No   | Admin connection type. Can be ssh_tunnel, oam_ip, admin_forwarder |
    ...  | bts_ip          | No   | BTS ip used to establish Admin session                            |

    [Arguments]    ${alias}    ${new_alias}    ${connection_type}=admin_forwarder    ${bts_ip}=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]

    IF    '${connection_type}' not in ['admin_forwarder', 'oam_ip', 'ssh_tunnel']
        Fail    Wrong argument for ADMIN Connection, should be one of admin_forwarder, oam_ip or ssh_tunnel
    END

    ${admin_status}=    Run Keyword And Return Status    Teardown Admin    alias=${new_alias}
    ${host}=    Set Variable If    '${alias}' == '${alias_local}'    ${None}    ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]

    IF    '${connection_type}' == 'admin_forwarder' or ('${connection_type}' == 'ssh_tunnel' and '${alias}' == '${alias_local}')
        Start new ADMIN instance using ADMIN FORWARDER  alias=${alias}  new_alias=${new_alias}  bts_ip=${bts_ip}
    ELSE IF    '${connection_type}' == 'oam_ip'
        Start new ADMIN instance using OAM IP    alias=${alias}    new_alias=${new_alias}
    ELSE
        Start new ADMIN instance using SSH TUNNEL    alias=${alias}    new_alias=${new_alias}    bts_ip=${bts_ip}
    END

Start ADMIN using SSH TUNNEL On
    [Arguments]  ${alias}  ${bts_ip}  ${address}=${MASTER['MASTER_UDP_IP_ADDRESS']}

    ${bind_port}=  Get Free Random Ephemeral Port

    Create SSH Tunnel
    ...  REMOTE_ENB_IP_ADDRESS=${bts_ip}
    ...  LOCAL_BIND_PORT=${bind_port}
    ...  alias=${alias}
    ...  LOCAL_BIND_IP_ADDRESS=${address}

    ${release_version}=  Get SBTS build release version  ${alias}

    Wait Until Keyword Succeeds  5 min  5 sec  Setup ADMIN  alias=${alias}  bts_host=${address}  bts_port=${bind_port}
    ...  admin_api_log_dir=${BTSFiles}  timeout=60s  release=${release_version}  update_interval=500
    Log  ADMIN on '${alias}' started  level=TRACE  console=True

Start ADMIN using OAM IP On
    [Arguments]    ${alias}

    TRY
        Dictionary Should Contain Key    ${${alias.upper()}}    ${alias.upper()}_OAM_IP_ADDRESS
    EXCEPT
        Fail    Mandatory parameter ${alias.upper()}_OAM_IP_ADDRESS is missing
    END

    Wait Until Keyword Succeeds    10 min    5 sec    Start ADMIN Dynamic Port    alias=${alias}    host=${None}
    ...    bts_address=${${alias.upper()}}[${alias.upper()}_OAM_IP_ADDRESS]
    Log    ADMIN on '${alias}' started    level=TRACE    console=True

Start ADMIN using ADMIN FORWARDER On
    [Arguments]    ${alias}    ${host}    ${bts_ip}

    Wait until keyword succeeds    10 min    5 sec    Start ADMIN Dynamic Port    alias=${alias}    host=${host}    bts_address=${bts_ip}
    Log  ADMIN on '${alias}' started  level=TRACE  console=True

Start new ADMIN instance using SSH TUNNEL
    [Arguments]    ${alias}    ${new_alias}    ${bts_ip}    ${address}=${MASTER['MASTER_UDP_IP_ADDRESS']}

    ${bind_port}=    Get Free Random Ephemeral Port

    Create SSH Tunnel
    ...  REMOTE_ENB_IP_ADDRESS=${bts_ip}
    ...  LOCAL_BIND_PORT=${bind_port}
    ...  alias=${new_alias}
    ...  LOCAL_BIND_IP_ADDRESS=${address}

    ${release_version}=    Get SBTS build release version    ${alias}

    Wait Until Keyword Succeeds    5 min    5 sec    Setup ADMIN    alias=${new_alias}    bts_host=${address}    bts_port=${bind_port}
    ...  admin_api_log_dir=${BTSFiles}    timeout=60s    release=${release_version}    update_interval=500
    Log    ADMIN on '${new_alias}' started    level=TRACE    console=True

Start new ADMIN instance using OAM IP
    [Arguments]    ${alias}    ${new_alias}

    TRY
        Dictionary Should Contain Key    ${${alias.upper()}}    ${alias.upper()}_OAM_IP_ADDRESS
    EXCEPT
        Fail    Mandatory parameter ${alias.upper()}_OAM_IP_ADDRESS is missing
    END

    Wait until keyword succeeds    10 min    5 sec    Start ADMIN Dynamic Port    alias=${new_alias}    host=${None}
    ...  bts_address=${${alias.upper()}}[${alias.upper()}_OAM_IP_ADDRESS]
    Log    ADMIN on '${new_alias}' started    level=TRACE    console=True

Start new ADMIN instance using ADMIN FORWARDER
    [Arguments]    ${alias}     ${new_alias}    ${bts_ip}

    Wait until keyword succeeds    10 min    5 sec    Start ADMIN Dynamic Port    alias=${new_alias}
    ...  host=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]    bts_address=${bts_ip}
    Log    ADMIN on '${new_alias}' started    level=TRACE    console=True

Start ADMIN Dynamic Port
    [Arguments]  ${alias}  ${host}  ${bts_address}

   ${release_version}=  Get SBTS build release version  ${alias}

    ${status_443}=  Run Keyword and Return Status  Setup ADMIN  alias=${alias}
    ...  remote_host=${host}  bts_host=${bts_address}  bts_port=443  admin_api_log_dir=${BTSFiles}  timeout=120s  release=${release_version}
    ...  update_interval=500
    Run Keyword If  ${status_443}  Run Keywords
    ...  Log  Setup ADMIN successfully performed on port 443  console=True
    ...  AND  Return From Keyword
    ${status_3600}=  Run Keyword and Return Status  Setup ADMIN  alias=${alias}
    ...  remote_host=${host}  bts_host=${bts_address}  bts_port=3600  admin_api_log_dir=${BTSFiles}  timeout=120s  release=${release_version}
    ...  update_interval=500
    Run Keyword If  ${status_3600}
    ...  Log  Setup ADMIN successfully performed on port 3600  console=True
    ...  ELSE  Run Keywords
    ...  Log  Setup ADMIN can't be established on either port 443 nor 3600!  console=True
    ...  AND  Fail

Start ADMIN_INFOMODEL On
    [Documentation]
    ...  Start Admin_Infomodel On. Starts Admin_Infomodel on the local or remote VM based on connection type
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    ...
    ...  | Parameter       | Man. | Description                                                                |
    ...  | alias           | Yes  | Alias, can be Master/Slave                                                 |
    ...  | connection_type | No   | Admin connection type. Can be ssh_tunnel, oam_ip, admin_forwarder          |
    ...  | enb_ip          | No   | IP of the ENB where Admin_Infomodel will be connected                      |

    [Arguments]  ${alias}  ${connection_type}=admin_forwarder  ${enb_ip}=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    [Timeout]  15min

    ${admin_infomodel_status}=  Run Keyword And Return Status  ute_admin_infomodel.Teardown Infomodel  alias=${alias}

    Run Keyword If  '${alias}' == '${alias_local}'  Run Keywords
    ...  Start ADMIN_INFOMODEL connection  alias=${alias}  enb_ip=${enb_ip}
    ...  AND  Return From Keyword

    Run Keyword If  '${connection_type}' == 'ssh_tunnel'
    ...  Start ADMIN_INFOMODEL using SSH TUNNEL On  alias=${alias}  enb_ip=${enb_ip}
    ...  ELSE IF  '${connection_type}' == 'oam_ip'
    ...  Start ADMIN_INFOMODEL using OAM IP On  alias=${alias}
    ...  ELSE IF  '${connection_type}' == 'admin_forwarder'
    ...  Start ADMIN_INFOMODEL connection  alias=${alias}  enb_ip=${enb_ip}  remote_host=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    ...  ELSE  Fail  Wrong argument for ADMIN_INFOMODEL Connection [ssh_tunnel, oam_ip, admin_forwarder]

Start ADMIN_INFOMODEL connection
    [Arguments]  ${alias}  ${enb_ip}  ${remote_host}=None

    ${infomodel_setup_status}=  Run Keyword and Return Status
    ...  Wait Until Keyword Succeeds  5 min  5 sec  ute_admin_infomodel.Setup Infomodel  address=${enb_ip}  port=443  update_interval=500
    ...  admin_api_log_dir=${BTSFiles}  remote_host=${remote_host}  alias=${alias}
    Run Keyword If  ${infomodel_setup_status}
    ...  Log  ADMIN_INFOMODEL Setup on '${alias}' successfully performed on port 443  console=True
    ...  ELSE  Run Keywords
    ...  Log  ADMIN_INFOMODEL Setup was not possible on '${alias}' on port 443  console=True
    ...  AND  Fail  ADMIN_INFOMODEL Setup on '${alias}' was not possible on port 443.

    ${infomodel_connection_status}=  Run Keyword and Return Status
    ...  Wait Until Keyword Succeeds  5 min  15 sec  ute_admin_infomodel.Connect Infomodel  alias=${alias}  timeout=60
    Run Keyword If  ${infomodel_connection_status}
    ...  Log  ADMIN_INFOMODEL Connection on '${alias}' started on port 443  level=TRACE  console=True
    ...  ELSE  Run Keywords
    ...  Log  ADMIN_INFOMODEL Connection was not possible on '${alias}' on port 443  console=True
    ...  AND  ute_admin_infomodel.Teardown Infomodel  alias=${alias}
    ...  AND  Fail  ADMIN_INFOMODEL Connection on '${alias}' was not possible on port 443.

Start ADMIN_INFOMODEL using SSH Tunnel On
    [Arguments]  ${alias}  ${enb_ip}  ${address}=${MASTER['MASTER_UDP_IP_ADDRESS']}

    ${bind_port}=  Get Free Random Ephemeral Port

    Create SSH Tunnel
    ...  REMOTE_ENB_IP_ADDRESS=${enb_ip}
    ...  LOCAL_BIND_PORT=${bind_port}
    ...  alias=${alias}
    ...  LOCAL_BIND_IP_ADDRESS=${address}

    Wait Until Keyword Succeeds  5 min  5 sec  ute_admin_infomodel.Setup Infomodel  address=${address}  port=${bind_port}  update_interval=500
    ...  admin_api_log_dir=${BTSFiles}  alias=${alias}
    Wait Until Keyword Succeeds  5 min  15 sec  ute_admin_infomodel.Connect Infomodel  alias=${alias}  timeout=60
    Log  ADMIN_INFOMODEL on '${alias}' started  level=TRACE  console=True

Start ADMIN_INFOMODEL using OAM IP On
    [Arguments]    ${alias}

    TRY
        Dictionary Should Contain Key    ${${alias.upper()}}    ${alias.upper()}_OAM_IP_ADDRESS
    EXCEPT
        Fail    Mandatory parameter ${alias.upper()}_OAM_IP_ADDRESS is missing
    END

    Wait Until Keyword Succeeds    5 min    5 sec    ute_admin_infomodel.Setup Infomodel
    ...    address=${${alias.upper()}}[${alias.upper()}_OAM_IP_ADDRESS]    update_interval=500    admin_api_log_dir=${BTSFiles}    alias=${alias}
    Wait Until Keyword Succeeds    5 min    15 sec    ute_admin_infomodel.Connect Infomodel    alias=${alias}    timeout=60
    Log    ADMIN_INFOMODEL on '${alias}' started    level=TRACE    console=True

Collect ADMIN On '${alias}'
    Teardown Admin  alias=${alias}
    Log  ADMIN on '${alias}' stopped  level=TRACE  console=True

Collect ADMIN_INFOMODEL On '${alias}'
    ute_admin_infomodel.Teardown Infomodel  alias=${alias}
    Log  ADMIN_INFOMODEL on '${alias}' stopped  level=TRACE  console=True

Add second SW to test data
    [Documentation]
    ...  Helper keyword used to add to TC data second SW data, necessary for sending info to Reporting Portal. The SWs will be taken from
    ...  global environment variable qc_tc_swbuild
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com

    ${qc_swbuild}=  Get Environment Variable  qc_tc_swbuild
    ${RP_active_SWs}=  Split String  ${qc_swbuild}  ;${SPACE}
    ${SWs_found}=  Get Length  ${RP_active_SWs}
    Run Keyword If  ${SWs_found}!=2  Run Keywords
    ...  Log  No active SW builds found to extract additional SW build info for Reporting Portal!  console=True
    ...  AND  Return From Keyword

    ${qc_cubuild}=  Run Keyword If  '${MASTER['MASTER_TECH']}' == 'CBTS'  Get Environment Variable  qc_tc_cubuild

    ${RP_Master_SW}=  Get From List  ${RP_active_SWs}  0
    ${RP_Slave_SW}=  Get From List  ${RP_active_SWs}  1
    ${key_1}=  Set Variable  enb_nsa_build
    ${key_2}=  Set Variable  enb_rf_shared_build
    ${key_3}=  Set Variable  gnb_nsa_build
    ${key_4}=  Set Variable  gnb_rf_shared_build
    ${key_5}=  Set Variable  cu_build
    ${data_json}=  Catenate  SEPARATOR=  {"${key_1}":"${RP_Slave_SW}",
    ...  "${key_2}":"${RP_Slave_SW}",
    ...  "${key_3}":"${RP_Master_SW}",
    ...  "${key_4}":"${RP_Master_SW}",
    ...  "${key_5}":"${qc_cubuild}"}

    Run Keyword If  '${MASTER['MASTER_TECH']}' == 'NR' and '${SLAVE['SLAVE_TECH']}' in ['LTE','SBTS']  Run Keywords
    ...  repo.Add To Test Data
    ...  data={"${key_1}":"${RP_Slave_SW}", "${key_2}":"${RP_Slave_SW}", "${key_3}":"${RP_Master_SW}", "${key_4}":"${RP_Master_SW}"}
    ...  AND  Return From Keyword

    Run Keyword If  '${MASTER['MASTER_TECH']}' == 'CBTS' and '${SLAVE['SLAVE_TECH']}' in ['LTE','SBTS']  Run Keywords
    ...  repo.Add To Test Data
    ...  data=${data_json}
    ...  AND  Return From Keyword

    Run Keyword If  '${SLAVE['SLAVE_TECH']}' in ['LTE', 'SBTS']
    ...  Run Keywords  repo.Add To Test Data  data={"enb_nsa_build":"${RP_Slave_SW}", "enb_rf_shared_build":"${RP_Slave_SW}"}
    ...  AND  Return From Keyword
    Run Keyword If  '${SLAVE['SLAVE_TECH']}' == 'NR'
    ...  Run Keywords  repo.Add To Test Data  data={"gnb_nsa_build":"${RP_Slave_SW}", "gnb_rf_shared_build":"${RP_Slave_SW}"}
    ...  AND  Return From Keyword

Get SW Versions On All Sites SOAM
    # TODO: REMOVE AFTER RFSPLIT COMMON PART FULLY DELIVERED
    [Documentation]
    ...  Helper keyword providing NR and LTE SW versions from active and passive partitions:
    ...  NR - SW versions on Master based on ADMIN
    ...  LTE - SW versions on Master or Slave based on ADMIN
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com

    Run Keyword If  '${MASTER['MASTER_TECH']}' in ['NR','LTE','SBTS']  Admin Get BTS SW Version  Master
    ${value}=  Convert To Uppercase  ${Master active SW}
    Set Tags  SW version - Master active = ${value}
    Set Test Variable  ${QC Master Active SW}  ${value}
    ${value}=  Convert To Uppercase  ${Master passive SW}
    Set Tags  SW version - Master passive = ${value}
    Admin Get BTS SW Version  Slave
    ${value}=   Convert To Uppercase  ${Slave active SW}
    Set Test Variable  ${QC Slave Active SW}  ${value}
    Set Tags  SW version - Slave active = ${value}
    ${value}=  Convert To Uppercase  ${Slave passive SW}
    Set Tags  SW version - Slave passive = ${value}
    Set Qc Parameter  qc_tc_swbuild  ${QC Master Active SW}; ${QC Slave Active SW}

Get SW Version
    [Arguments]  ${alias}

    Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'  Run Keywords
    ...  Get CBTS SW Version  ${alias}
    ...  AND  Return From Keyword

    Admin Get BTS SW Version  ${alias}
    Set Test Variable  ${${alias}_active_SW_version_initial}  ${${alias} active SW}

    ${value}=  Convert To Uppercase  ${${alias} active SW}
    Set Tags  SW version - ${alias} active = ${value}
    Set Test Variable  ${QC ${alias} Active SW}  ${value}
    ${value}=  Convert To Uppercase  ${${alias} passive SW}
    Set Tags  SW version - ${alias} passive = ${value}

    ${status_ext}=  Run Keyword And Return Status  Variable Should Exist  ${tag_string}
    ${tag_string}=  Run Keyword If  ${status_ext}
    ...  Catenate  SEPARATOR=;${SPACE}  ${tag_string}  ${QC ${alias} Active SW}
    Run Keyword If  ${status_ext}  Run Keywords
    ...  Set Test Variable  ${tag_string}
    ...  AND  Set Qc Parameter  qc_tc_swbuild  ${tag_string}
    ...  AND  Return From Keyword

    Set Test Variable  ${tag_string}  ${QC ${alias} Active SW}
    Set Qc Parameter  qc_tc_swbuild  ${tag_string}

Get and Check Alarms SOAM
    [Documentation]
    ...  KW used to get and check critical, expected or unexpected alarms. It fails if any of below exception case is present:
    ...  - critical alarms are present
    ...  - not all expected alarms are present
    ...  - unexpected alarms are present
    ...  Report errors/warnings for failed cases or report that alarm status is ok.
    ...  Kw aplicable for SOAM/COAM architecture
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com / emanuel.szijj@nokia.com (SOAM)
    ...
    ...  | Parameter            | Man. | Description                                                                                |
    ...  | alias                | No   | alias of ute_admin_infomodel instance (Master/Slave)                                       |
    ...  | time                 | No   | How much time to wait for alarms to reach stable state                                     |
    ...  | poll_interval        | No   | Poll interval of alarms queries                                                            |
    ...  | wait_for_alarm_clear | No   | How much time to wait for unexpected alarms to be cleared                                  |
    ...  | expected_alarms      | No   | Alarms which need to be present in Webem(admin) .Error raised if any of these is missing   |
    ...  | expected_alarms_ims  | No   | Alarms which need to be present in ims trace.Error raised if any of these is missing       |
    ...  | ignored_alarms       | No   | Alarms which can be ignored if present                                                     |
    ...  | critical_alarms      | No   | Alarms which must not be present.Error raised if any of these is found                     |
    ...  | timeout              | No   | Time to wait for positive query result                                                     |
    ...
    ...  *EXAMPLE*
    ...  Get and Check Alarms SOAM  | Master | 10 min | 10 sec | 2 min | expected_alarms=${LTE_EXPECTED_ALARMS} |
    ...  expected_alarms_ims=${LTE_EXPECTED_ALARMS_IMS} | ignored_alarms=${LTE_IGNORED_ALARMS} |
    ...  critical_alarms=${LTE_CRITICAL_ALARMS}

    [Arguments]  ${alias}=default  ${time}=5 min  ${poll_interval}=30 sec  ${wait_for_alarm_clear}=5 min
    ...  ${expected_alarms}=@{EMPTY}  ${expected_alarms_ims}=@{EMPTY}  ${start_timestamp_ims2}=${None}
    ...  ${ignored_alarms}=@{EMPTY}  ${critical_alarms}=@{EMPTY}  ${timeout}=30 sec

    ${previous_alarms}=  Create List
    Set Test Variable  ${previous_alarms}
    ${start_timestamp_admin_alarm_check}=  Get Current Date  time_zone=UTC
    ${start_timestamp_ims2}=  Set Variable If  '${start_timestamp_ims2}'=='${None}'
    ...  ${start_timestamp_admin_alarm_check}  ${start_timestamp_ims2}

    Set Test Variable  ${detected_critical_alarms}  ${FALSE}

    Run Keyword And Return Status  Wait Until Keyword Succeeds  ${time}  ${poll_interval}
    ...  Eval Current Alarms SOAM  alias=${alias}  expected_alarms=${expected_alarms}  ignored_alarms=${ignored_alarms}
    ...  critical_alarms=${critical_alarms}  timeout=${timeout}  alarms_from_previous_checks=${previous_alarms}

    Run Keyword If  ${found_unexpected_alarms}  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${wait_for_alarm_clear}  ${poll_interval}
    ...  Eval Unexpected Alarms SOAM  alias=${alias}  expected_alarms=${expected_alarms}  ignored_alarms=${ignored_alarms}
    ...  critical_alarms=${critical_alarms}  wait_for_alarm_clear=${wait_for_alarm_clear}  timeout=${timeout}

    ${time_seconds}=  Convert time  ${time}  result_format=number
    ${current_time}=  Get Current Date  time_zone=UTC
    ${elapsed_time}=  Subtract Date From Date  ${current_time}
    ...  ${start_timestamp_admin_alarm_check}
    ${remaining_time}=  Subtract Time From Time  ${time_seconds}  ${elapsed_time}

    Run Keyword And Return Status  Wait Until Keyword Succeeds  ${remaining_time}  ${poll_interval}  Get and check detailed IMS2 Alarms SOAM
    ...  alias=${alias}  start_timestamp=${start_timestamp_ims2}
    ...  expected_alarms=${expected_alarms_ims}  ignored_alarms=${ignored_alarms}  critical_alarms=${critical_alarms}

    Run Keyword If  ${detected_critical_alarms}  Run Keywords
    ...  Log  Critical alarms present:  level=ERROR
    ...  AND  alarms_analysis.Print Alarms  critical_alarms=${detected_critical_alarms}  simplified_dictionary=${SIMPLIFIED_ALARM}
    ...  ELSE IF  ${not_found_expected_alarms}  Run Keywords
    ...  Log  Missing expected alarms:  level=ERROR
    ...  AND  alarms_analysis.Print Alarms  missing_alarms_patterns=${not_found_expected_alarms}  simplified_dictionary=${SIMPLIFIED_ALARM}
    ...  ELSE IF  ${found_unexpected_alarms}  Run Keywords
    ...  Set Alarm Check Level Based on Execution Environment   wait_for_alarm_clear=${wait_for_alarm_clear}
    ...  found_unexpected_alarms=${found_unexpected_alarms}
    ...  AND  Log  Unexpected alarms present AFTER alarm clear interval of ${wait_for_alarm_clear}:  level=${ALARMS_LEVEL}
    ...  AND  alarms_analysis.Print Alarms  warnings=${found_unexpected_alarms}  simplified_dictionary=${SIMPLIFIED_ALARM}
    ...  AND  Log  Snapshot will be triggered at the end of test  console=True
    ...  AND  Set Test Variable  ${SnapshotTriggerEndTest}  YES
    ...  ELSE
    ...  Log  Alarm status is OK.  level=INFO  console=True

    Run Keyword If  ${detected_critical_alarms} or ${not_found_expected_alarms} or ${not_found_expected_ims2_alarms}
    ...  Fail  Critical alarms present and/or missing expected alarms!

Eval Current Alarms SOAM
    [Documentation]
    ...  KW used to get and check critical or expected alarms. It fails if any of below exception case is present:
    ...  - critical alarms are present
    ...  - not all expected alarms are present
    ...  Kw aplicable for SOAM/COAM architecture
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com / emanuel.szijj@nokia.com (SOAM)
    ...
    ...  | Parameter            | Man. | Description                                                             |
    ...  | alias                | No   | alias of ute_admin_infomodel instance (Master/Slave)                          |
    ...  | expected_alarms      | No   | Alarms which need to be present.Error raised if any of these is missing |
    ...  | ignored_alarms       | No   | Alarms which can be ignored if present                                  |
    ...  | critical_alarms      | No   | Alarms which must not be present.Error raised if any of these is found  |
    ...  | timeout              | No   | Time to wait for possitive query result                                 |
    ...
    ...  *EXAMPLE*
    ...  Eval Current Alarms SOAM  | Master | expected_alarms=${LTE_EXPECTED_ALARMS} | ignored_alarms=${LTE_IGNORED_ALARMS} |
    ...  critical_alarms=${LTE_CRITICAL_ALARMS}

    [Arguments]  ${alias}=default  ${expected_alarms}=@{EMPTY}  ${ignored_alarms}=@{EMPTY}  ${critical_alarms}=@{EMPTY}
    ...  ${timeout}=30 sec  ${alarms_from_previous_checks}=@{Empty}

    ${active_alarms}=  coam.Get Alarms  alias=${alias}  timeout=${timeout}
    ${active_alarms}=  Translate alarm dictionary  ${active_alarms}  ${TRANSLATED_ALARM}
    Run Keyword If  ${alarms_from_previous_checks}
    ...  Append To List  ${active_alarms}  @{alarms_from_previous_checks}
    ${active_alarms}=  Run Keyword If  ${alarms_from_previous_checks}
    ...  Remove all alarm duplicates  ${active_alarms}  ${KEYS_FOR_REMOVE_DUPLICATE_ALARM_REAL_TIME}
    ...  ELSE  Set Variable  ${active_alarms}
    ${found_expected_alarms}  ${not_found_expected_alarms}  ${found_critical_alarms}  ${found_ignored_alarms}  ${found_unexpected_alarms}=
    ...  alarms_analysis.Get Filtered Alarms  ${active_alarms}  ${expected_alarms}  ${ignored_alarms}  ${critical_alarms}  ${SIMPLIFIED_ALARM}

    Set Test Variable  ${found_critical_alarms}  ${found_critical_alarms}
    Set Test Variable  ${not_found_expected_alarms}  ${not_found_expected_alarms}
    Set Test Variable  ${found_unexpected_alarms}  ${found_unexpected_alarms}
    ${previous_alarms}=  Create List
    Set Test Variable  ${previous_alarms}  ${active_alarms}

    Run Keyword If  ${found_critical_alarms}  Run Keywords
    ...  Log  Critical alarms present:  level=ERROR
    ...  AND  alarms_analysis.Print Alarms  critical_alarms=${found_critical_alarms}  simplified_dictionary=${SIMPLIFIED_ALARM}
    ...  AND  Set Test Variable  ${detected_critical_alarms}  ${found_critical_alarms}

    Run Keyword If  ${found_critical_alarms}
    ...  Fail  Critical alarms present. Attempting a new check..
    ...  ELSE IF  ${not_found_expected_alarms}
    ...  Fail  Missing expected alarms. Attempting a new check..

Eval Unexpected Alarms SOAM
    [Documentation]
    ...  KW used to get and check LTE critical or unexpected alarms. It fails if any of below exception case is present:
    ...  - critical alarms are present
    ...  - unexpected alarms are present
    ...  Kw aplicable for SOAM/COAM architecture
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com / emanuel.szijj@nokia.com (SOAM)
    ...
    ...  | Parameter            | Man. | Description                                                             |
    ...  | alias                | No   | alias of ute_admin_infomodel instance (Master/Slave)                          |
    ...  | expected_alarms      | No   | Alarms which need to be present.Error raised if any of these is missing |
    ...  | ignored_alarms       | No   | Alarms which can be ignored if present                                  |
    ...  | critical_alarms      | No   | Alarms which must not be present.Error raised if any of these is found  |
    ...  | wait_for_alarm_clear | No   | How much time to wait for unexpected alarms to be cleared               |
    ...  | timeout              | No   | Time to wait for possitive query result                                 |
    ...
    ...  *EXAMPLE*
    ...  Eval Unexpected Alarms SOAM  | Master | expected_alarms=${LTE_EXPECTED_ALARMS} | ignored_alarms=${LTE_IGNORED_ALARMS} |
    ...  critical_alarms=${LTE_CRITICAL_ALARMS}

    [Arguments]  ${alias}=default  ${expected_alarms}=@{EMPTY}  ${ignored_alarms}=@{EMPTY}  ${critical_alarms}=@{EMPTY}
    ...  ${wait_for_alarm_clear}=5 min  ${timeout}=30 sec

    ${active_alarms}=  coam.Get Alarms  alias=${alias}  timeout=${timeout}
    ${active_alarms}=  Translate alarm dictionary  ${active_alarms}  ${TRANSLATED_ALARM}
    ${found_expected_alarms}  ${not_found_expected_alarms}  ${found_critical_alarms}  ${found_ignored_alarms}  ${found_unexpected_alarms}=
    ...  alarms_analysis.Get Filtered Alarms  ${active_alarms}  ${expected_alarms}  ${ignored_alarms}  ${critical_alarms}
    ...  simplified_dictionary=${SIMPLIFIED_ALARM}

    Set Test Variable  ${found_critical_alarms}  ${found_critical_alarms}
    Set Test Variable  ${found_unexpected_alarms}  ${found_unexpected_alarms}

    Run Keyword If  ${found_critical_alarms}  Run Keywords
    ...  Log  Critical alarms present:  level=ERROR
    ...  AND  alarms_analysis.Print Alarms  critical_alarms=${found_critical_alarms}  simplified_dictionary=${SIMPLIFIED_ALARM}
    ...  AND  Set Test Variable  ${detected_critical_alarms}  ${found_critical_alarms}

    Run Keyword If  ${found_unexpected_alarms}  Run Keywords
    ...  Log  Unexpected alarms present DURING alarm clear interval of ${wait_for_alarm_clear}:  level=WARN
    ...  AND  alarms_analysis.Print Alarms  warnings=${found_unexpected_alarms}  simplified_dictionary=${SIMPLIFIED_ALARM}

    Run Keyword If  ${found_critical_alarms}
    ...  Fail  Critical alarms present. Attempting a new check..
    ...  ELSE IF  ${found_unexpected_alarms}
    ...  Fail  Unexpected alarms present. Attempting a new check..

Remove all alarm duplicates
    [Arguments]  ${initial_alarm_list}  ${alarm_keys}

    ${simplified_alarm_list}=  Create List
    ${final_alarm_list}=  Create List

    FOR  ${alarm}  IN  @{initial_alarm_list}
        ${alarm_details}=  Get Simplified Alarm Params  ${alarm}  ${alarm_keys}
        Append To List  ${simplified_alarm_list}  ${alarm_details}
    END

    ${simplified_alarm_list}=  Remove Duplicates  ${simplified_alarm_list}

    FOR  ${alarm}  IN  @{initial_alarm_list}
        ${alarm_details}=  Get Simplified Alarm Params  ${alarm}  ${alarm_keys}
        Run Keyword If  ${alarm_details} in ${simplified_alarm_list}  Run Keywords
        ...  Append To List  ${final_alarm_list}  ${alarm}
        ...  AND  Remove Values From List  ${simplified_alarm_list}  ${alarm_details}
    END
    [Return]  ${final_alarm_list}

Get Simplified Alarm Params
    [Arguments]  ${alarm}  ${alarm_keys}

    ${param_list}=  Create List

    FOR  ${key}  IN  @{alarm_keys}
        ${alarm_value}=  Get Variable Value  ${alarm['${key}']}  ${EMPTY}
        Append To List  ${param_list}  ${alarm_value}
    END

    [Return]  ${param_list}

Export ResetTime Results
    [Documentation]
    ...  Keyword is used to export the duration time values computed based on events timestamp and based on Syslog parsing.
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com, dinu.olariu@nokia.com
    ...
    ...  | Parameter       | Man. | Description                                                                                      |
    ...  | alias           | Yes  | BTS alias                                                                                        |
    ...  | reset_log_file  | No   | File where to print the reset duration info. By default, ${BTS Files}/${alias}/ResetTimeInfo.txt |
    ...  | reset_trigger   | Yes  | reset trigger. Can be: 'reset_sm', 'unblock_sm', 'sw_activation'                                 |
    ...  | techno          | Yes  | can be 'nr', 'lte' or 'sbts'                                                                     |
    ...  | cycle           | No   | number of iteration to be printed, in case of iterative tc                                       |
    ...  | event_value     | No   | reset duration in seconds, for case when it is computed based on events timestamps               |
    ...  | syslog_values   | No   | list of reset durations extracted from Syslog parsing                                            |
    ...
    ...  *EXAMPLE*
    ...  Export ResetTime Results | alias=Master | reset_log_file=/home/ute/logs/MasterUDP | reset_trigger=reset_sm | techno=sbts |
    ...  | cycle=1 | event_value=220 |
    ...
    [Arguments]  ${alias}  ${reset_log_file}=${EMPTY}  ${reset_trigger}=${EMPTY}  ${techno}=${EMPTY}  ${cycle}=${EMPTY}  ${event_value}=${EMPTY}
    ...  ${syslog_values}=${EMPTY}
    Run Keyword If  '${reset_log_file}' == '${EMPTY}'  Set Test Variable  ${reset_log_file}  ${BTS Files}/${alias}/ResetTimeInfo.txt
    ...  ELSE  Set Test Variable  ${reset_log_file}
    ${reset_log_file_exists}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${reset_log_file}
    Run Keyword If  not ${reset_log_file_exists}
    ...  Create reset file and append tc info  ${alias}  ${reset_log_file}  ${reset_trigger}  ${syslog_values}
    Run Keyword If  ('${event_value}' != '${EMPTY}') and ('${cycle}' != '${EMPTY}')
    ...  Run Keywords  Append To File  ${reset_log_file}  Reset duration #${cycle}: ${event_value} sec \n
    ...  AND  Log  [ Reset duration ] of: ${techno}, after action: ${reset_trigger}, cycle nbr.${cycle}, based on events: ${event_value} sec
    ...  level=INFO
    Run Keyword If  ('${event_value}' != '${EMPTY}') and ('${cycle}' == '${EMPTY}')
    ...  Run Keywords  Append To File  ${reset_log_file}  ${event_value} sec \n
    ...  AND  Log  [ Reset duration ] of: ${techno}, after action: ${reset_trigger}, based on events: ${event_value} sec  level=INFO  console=True
    Run Keyword If  ('${syslog_values}' != '${EMPTY}')  Run Keywords
    ...  Append To File  ${reset_log_file}  \n Reset duration computed from Syslog: \n
    ...  AND  Append To File  ${reset_log_file}  ========================================== \n
    ...  AND  Print reset duration values from Syslog  ${reset_log_file}  ${syslog_values}

Create reset file and append tc info
    [Documentation]
    ...  Keyword is used to create the reset log file and populate first line with SOAM testline information.
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com, dinu.olariu@nokia.com
    ...
    ...  | Parameter        | Man. | Description                                                                                      |
    ...  | alias            | Yes  | BTS alias                                                                                        |
    ...  | reset_log_file   | No   | File where to print the reset duration info. By default, ${BTS Files}/${alias}/ResetTimeInfo.txt |
    ...  | reset_trigger    | Yes  | reset trigger. Can be: 'reset_sm', 'unblock_sm', 'sw_activation'                                 |
    ...  | syslog_values    | Yes  | list of reset durations extracted from Syslog parsing                                            |
    ...
    ...  *EXAMPLE*
    ...  Create reset file and append tc info | alias=Master | reset_log_file=/home/ute/logs/MasterUDP | reset_trigger=reset_sm |
    ...
    [Arguments]  ${alias}  ${reset_log_file}  ${reset_trigger}  ${syslog_values}
    ${alias_upper}=  String.Convert To Uppercase  ${alias}
    ${current active SW}  ${current passive SW}=  Admin Get BTS SW Version  ${alias}
    Run Keyword If  '${reset_trigger}' == 'sw_activation'  Run Keywords
    ...  Append To File  ${reset_log_file}  Active SW before: ${current passive SW} \n
    ...  AND  Append To File  ${reset_log_file}  Active SW after: ${current active SW} \n
    ...  ELSE
    ...  Append To File  ${reset_log_file}  Active SW: ${current active SW} \n
    Append To File  ${reset_log_file}  Tech: ${${alias_upper}}[${alias_upper}_TECH] \n
    Append To File  ${reset_log_file}  Reset Reason: ${reset_trigger} \n
    Run Keyword If  '${syslog_values}' == '${EMPTY}'  Run Keywords
    ...  Append To File  ${reset_log_file}  \n Reset duration based on events: \n
    ...  AND  Append To File  ${reset_log_file}  ========================================== \n

Add KPI Results in File
    [Documentation]
    ...  Keyword is used to add kpi info to a specified file, by default the ResetInfo.txt file
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter      | Man. | Description                                                                                      |
    ...  | alias          | Yes  | Master/Slave                                                                                     |
    ...  | kpi_reported   | Yes  | Kpi ID. Example: KPI 1a, KPI 3, KPI 51                                                           |
    ...  | kpi_log_file   | Yes  | File where to print the reset duration info. By default, ${BTS Files}/${alias}/ResetTimeInfo.txt |
    ...  | info           | Yes  | Short KPI description                                                                            |
    ...  | cycle          | No   | number of iteration to be printed, in case of iterative tc                                       |
    ...  | event_value    | No   | event duration in seconds                                                                        |
    ...
    ...  *EXAMPLE*
    ...  Add KPI Results in File | alias=Master | kpi_reported=KPI 1a | kpi_log_file=/home/ute/logs/KPIsNR | info=first_cell_down_to_last_cell_up |
    ...  | cycle=1 | event_value=220 |
    [Arguments]  ${alias}  ${kpi_reported}=${EMPTY}  ${kpi_log_file}=${EMPTY}  ${info}=${EMPTY}  ${cycle}=${EMPTY}  ${event_value}=${EMPTY}
    Run Keyword If  '${kpi_log_file}' == '${EMPTY}'  Set Test Variable  ${kpi_log_file}  ${BTS Files}/${alias}/ResetTimeInfo.txt
    ...  ELSE  Set Test Variable  ${kpi_log_file}
    OperatingSystem.File Should Exist  ${kpi_log_file}
    Run Keyword If  ('${event_value}' != '${EMPTY}') and ('${cycle}' != '${EMPTY}')
    ...  Run Keywords  Append To File  ${kpi_log_file}  ${kpi_reported} (${info}) value #${cycle}: ${event_value} sec \n
    ...  AND  Log  [ KPI duration ] of: ${kpi_reported} (${info}), cycle nbr.${cycle}: ${event_value} sec  level=INFO  console=True
    Run Keyword If  ('${event_value}' != '${EMPTY}') and ('${cycle}' == '${EMPTY}')
    ...  Run Keywords  Append To File  ${kpi_log_file}  ${kpi_reported} (${info}) value: ${event_value} sec \n
    ...  AND  Log  [ KPI duration ] of: ${kpi_reported} (${info}): ${event_value} sec  level=INFO  console=True

Export ResetTime Results Global
    [Documentation]
    ...  Keyword is used to create a global file where all reset times from test set execution will be exported
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...

    Set Test Variable  ${reset_log_file_global}  ${OUTPUT DIR}/ResetTimeInfo.txt
    ${testtimestamp}=  OperatingSystem.Run  date +%F_%H-%M-%S
    Set Test Variable  ${TEST}  ${testtimestamp}_TEST-${TEST NAME}
    Run Keywords
    ...  Append To File  ${reset_log_file_global}  ====================================================================
    ...  AND  Append To File  ${reset_log_file_global}  \n ${TEST} \n
    ...  AND  Append To File  ${reset_log_file_global}  ==================================================================== \n
    ${master_reset_file_exists}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${BTS Files}/Master/ResetTimeInfo.txt
    ${master_reset_file_content_status}  ${master_reset_file_content}=  Run Keyword And Ignore Error
    ...  OperatingSystem.Get File  ${BTS Files}/Master/ResetTimeInfo.txt
    ${slave_reset_file_exists}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${BTS Files}/Slave/ResetTimeInfo.txt
    ${slave_reset_file_content_status}  ${slave_reset_file_content}=  Run Keyword And Ignore Error
    ...  OperatingSystem.Get File  ${BTS Files}/Slave/ResetTimeInfo.txt
    Run Keyword If  ${master_reset_file_exists}  Run Keywords
    ...  Append to File  ${reset_log_file_global}  ${master_reset_file_content}
    ...  AND  Append To File  ${reset_log_file_global}  ========================================== \n
    Run Keyword If  ${slave_reset_file_exists}  Run Keywords
    ...  Append to File  ${reset_log_file_global}  ${slave_reset_file_content}
    ...  AND  Append To File  ${reset_log_file_global}  ========================================== \n

Print reset duration values from Syslog
    [Documentation]
    ...  Keyword is used to create the reset log file and populate first line with testline information.
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter      | Man. | Description                                                                                       |
    ...  | file           | Yes  | File where to print values of reset durations obtained from Syslog parsing                        |
    ...  | list           | Yes  | List reset duration values obtained from Syslog parsing to be printed in file                     |
    ...
    ...  *EXAMPLE*
    ...  Print reset duration values from Syslog | /home/ute/logs/MasterUDP | [201, 220, 199]
    ...
    ...
    [Arguments]  ${file}  ${list}
    ${runNb}=  Set Variable  1
    FOR  ${item}  IN  @{list}
        Append To File  ${file}  Reset duration #${runNb}: ${item} sec \n
        Log  Reset duration computed from Syslog #${runNb}: ${item} sec
        ${runNb}=  BuiltIn.Evaluate  ${runNb} + 1
    END

Set Qc Parameter
    [Documentation]  Keyword used to set OS environment variable which will be used by test reporter in order to report QC paramater to test
    ...  instance or tets run
    ...
    ...  *AUTHOR*
    ...  catalin.chiorean@nokia.com
    ...
    ...  *USAGE*
    ...  | Parameter    | Man. | Description                                 |
    ...  | qc_parameter | YES  | qc parameter to be exported as env variable |
    ...  | value        | YES  | qc parameter value                          |
    ...
    ...  *EXAMPLE*
    ...  Set Qc Parameter | qc_tc_swbuild | FL17A_234
    ...
    ...  *ALLOWED QC PARAMETERS*
    ...  Currently the implemeted parameters exported as variable are:
    ...  - "qc_tc_swbuild" coresponding to "SW Build" qc parameter name
    ...  - "qc_tc_cubuild" coresponding to "CU Build" qc parameter name
    ...
    [Arguments]  ${qc_parameter}  ${value}

    Run Keyword If  '${qc_parameter}' in ${qc_allowed_parameters}
    ...  Set Environment Variable  ${qc_parameter}  ${value}
    ...  ELSE
    ...  Log  Parameter not allowed, list of allowed parameters: ${qc_allowed_parameters}  console=True

Check test verdict based on reset time
    [Documentation]
    ...  Author: Serban HAMZA / Emanuel SZIJJ
    ...
    ...  Checks reset time for technologies
    ...  If recovery time exceeds, test will be passed_with_restriction
    ...  and snapshot will be triggered at the end of test
    ...
    [Timeout]  10 min
    [Arguments]  ${techno}  ${time_diff}

    Run Keyword If  ${time_diff} <= 0
    ...  Log  ${techno} recovery time is OK.  console=True  level=INFO
    ...  ELSE  Run Keywords
    ...  Log  ${techno} recovery time exceeded user defined [${techno}]RESET_WRN_THR of ${${techno}_RESET_WRN_THR} sec.  level=WARN
    ...  AND  Log  Snapshot will be triggered at the end of test  console=True
    ...  AND  Set Test Variable  ${SnapshotTriggerEndTest}  YES

Get Cells list
    [Arguments]  ${TECHNO}  ${CELLS_LIST}
    ${cells_list_var}=  Get Cells list SOAM  ${TECHNO}  ${CELLS_LIST}
    [Return]  ${cells_list_var}

Get Cells list SOAM
    [Arguments]  ${TECHNO}  ${CELLS_LIST}
    ${get_bts_cells_list}=  Set Variable If  '${CELLS_LIST}' == 'DEFAULT'  ${True}  ${False}
    ${cells_list_var}=  Run Keyword If  '${CELLS_LIST}' != 'DEFAULT'  Split String  ${CELLS_LIST}
    Run Keyword If  not ${get_bts_cells_list}  Return From Keyword  ${cells_list_var}
    ${cells_list_var}  ${temp_cell_id_internal_id_mapping}=  Run Keyword If  '${TECHNO}' == 'GSM' and '${MASTER['MASTER_TECH']}' == 'SBTS'
    ...  Get GSM cell IDs from BSC and admin  Master  ${MASTER['BCF_ID']}
    ...  ELSE IF  '${TECHNO}' == 'GSM' and '${SLAVE['SLAVE_TECH']}' == 'SBTS'  Get GSM cell IDs from BSC and admin  Slave  ${SLAVE['BCF_ID']}
    ...  ELSE IF  '${TECHNO}' == 'LTE_MASTER'  Get SBTS Cell Ids from admin  Master  LTE
    ...  ELSE IF  '${TECHNO}' == 'LTE_SLAVE'  Get SBTS Cell Ids from admin  Slave  LTE
    ...  ELSE IF  '${TECHNO}' == 'LTE' and '${MASTER['MASTER_TECH']}' == 'LTE'
    ...  Get SBTS Cell Ids from admin  Master  LTE
    ...  ELSE IF  '${TECHNO}' == 'LTE' and '${SLAVE['SLAVE_TECH']}' == 'LTE'
    ...  Get SBTS Cell Ids from admin  Slave  LTE
    ...  ELSE IF  '${TECHNO}' == 'NR' and '${MASTER['MASTER_TECH']}' == 'NR'
    ...  Get NR Cell Ids from admin  Master
    ...  ELSE IF  '${TECHNO}' == 'NR' and '${SLAVE['SLAVE_TECH']}' == 'NR'
    ...  Get NR Cell Ids from admin  Slave
    ...  ELSE IF  ('${TECHNO}'=='SBTS_LTE') and '${MASTER['MASTER_TECH']}' == 'SBTS'
    ...  Get SBTS Cell Ids from admin  Master  LTE
    ...  ELSE IF  ('${TECHNO}'=='SBTS_LTE') and '${SLAVE['SLAVE_TECH']}' == 'SBTS'
    ...  Get SBTS Cell Ids from admin  Slave  LTE
    ...  ELSE IF  ('${TECHNO}'=='WCDMA') and '${MASTER['MASTER_TECH']}' == 'SBTS'
    ...  Get SBTS Cell Ids from admin  Master  WCDMA
    ...  ELSE IF  ('${TECHNO}'=='WCDMA') and '${SLAVE['SLAVE_TECH']}' == 'SBTS'
    ...  Get SBTS Cell Ids from admin  Slave  WCDMA
    ...  ELSE IF  '${TECHNO}' == 'NR'  Get NR Cell Ids from admin  Master
    ...  ELSE IF  '${TECHNO}' == 'NR_MASTER'  Get NR Cell Ids from admin  Master
    ...  ELSE IF  '${TECHNO}' == 'NR_SLAVE'  Get NR Cell Ids from admin  Slave
    ...  ELSE  Fail  Wrong TECHNO=${TECHNO} value has been given
    ${cell_count}=  Get Length  ${cells_list_var}
    Run Keyword If  ${cell_count} == 0  Run Keywords
    ...  Log  No ${TECHNO} cells are found on BTS!  level=ERROR
    ...  AND  Fail  No ${TECHNO} cells are found on BTS!
    Sort list  ${cells_list_var}
    [Return]  ${cells_list_var}

Get LTE Eutran Cell Ids from admin
    [Arguments]  ${alias}
    ${CELL_eutraCelIds}=  Get Cell List  alias=${alias}
    ${LTE_eutraCelIds}=  Create List
    FOR  ${item}  IN  @{CELL_eutraCelIds['cells']['lte']}
        ${eutraCelId}=  Set Variable  ${item['eutranCellId']}
        ${eutraCelId}=  Convert To String  ${eutraCelId}
        Append To List  ${LTE_eutraCelIds}  ${eutraCelId}
    END
    [Return]  ${LTE_eutraCelIds}

Get NR Cell Ids from admin
    [Arguments]  ${alias}
    ${cell_id_internal_id_mapping}=  Create Dictionary
    ${CELL_params}=  Get Parameters For All  class_name=NRCEL  alias=${alias}
    ${NR_CelIds}=  Create List
    FOR  ${item}  IN  @{CELL_params}
        ${internal_id}=  Set Variable  ${item['id']}
        ${NR_CelId}=  Set Variable  ${item['nrCellIdentity']}
        ${NR_CelId}=  Convert To String  ${NR_CelId}
        Append To List  ${NR_CelIds}  ${NR_CelId}
        Set To Dictionary  ${cell_id_internal_id_mapping}  ${NR_CelId}=${internal_id}
    END
    [Return]  ${NR_CelIds}  ${cell_id_internal_id_mapping}

Get SBTS Cell Ids from admin
    [Arguments]  ${alias}  ${techno_from_SBTS}
    ${cell_id_internal_id_mapping}=  Create Dictionary
    ${techno}=  Fetch From Right  ${techno_from_SBTS}  _
    ${CELL_CelIds}=  Get Cell List  alias=${alias}
    ${techno_key}=  Set Variable If
    ...  '${techno.lower()}' == 'lte'  eutranCellId
    ...  '${techno.lower()}' == 'wcdma'  cellId
    ...  N/A
    ${SBTS_CelIds}=  Create List
    FOR  ${item}  IN  @{CELL_CelIds['cells']['${techno.lower()}']}
        ${internal_id}=  Set Variable  ${item['id']['internal']}
        ${CellId}=  Set Variable  ${item['${techno_key}']}
        ${CellId}=  Convert To String  ${CellId}
        Append To List  ${SBTS_CelIds}  ${CellId}
        Set To Dictionary  ${cell_id_internal_id_mapping}  ${CellId}=${internal_id}
    END
    [Return]  ${SBTS_CelIds}  ${cell_id_internal_id_mapping}

SCF backup
    [Documentation]
    ...  Generic Keyword used to perform SCF backup based on requested technology
    [Timeout]  10 min
    [Arguments]  ${TECHNO}  ${OAM_architecture}=${EMPTY}
    Run Keyword  SCF backup ${OAM_architecture}  ${TECHNO}

Set generic alarms lists
    [Arguments]  ${Alarm_dict}
    FOR  ${key}  IN  @{Alarm_dict.keys()}
        Log  ${Alarm_dict['${key}']}  console=True
        ${alarm_list}=  Copy List  ${test_alarms_list['${Alarm_dict['${key}']}']}  deepcopy=True
        Set To Dictionary  ${test_alarms_list}  ${key}  ${alarm_list}
    END

Set Alarms List
    FOR  ${key}  IN  @{test_alarms_list.keys()}
        ${value}=  Get From Dictionary  ${test_alarms_list}  ${key}
        ${is_list}=  Evaluate  isinstance($value, list)
        Run Keyword If  ${is_list}  Set Test Variable  ${${key}}  ${value}
    END

Select generic alarms lists based on flag
    [Arguments]  ${Alarm_flag_name}  ${Container_alarm_list_name1}=${None}  ${Container_alarm_list_name2}=${None}
    ...  ${alias}=default

    ${Container_alarm_list_exists}=  Run Keyword And Return Status
    ...  Run Keywords
    ...  Variable should exist  ${test_alarms_list['${Container_alarm_list_name1}']}
    ...  AND  Variable should exist  ${test_alarms_list['${Container_alarm_list_name2}']}
    ...  AND  Variable should exist  ${${Alarm_flag_name}}

    Run Keyword If  not ${Container_alarm_list_exists}
    ...  Run Keywords
    ...  Log  Missing alarm list containers for at least one of ${Container_alarm_list_name1} ${Container_alarm_list_name2}  console=True
    ...  AND  Log  No action will be performed regarding alarm lists for ${Alarm_flag_name}  console=True
    ...  AND  Return From Keyword

    ${Container_alarm_list1}=  Set Variable  ${test_alarms_list['${Container_alarm_list_name1}']}
    ${Container_alarm_list2}=  Set Variable  ${test_alarms_list['${Container_alarm_list_name2}']}
    ${Alarm_flag_value}=  Set Variable  ${${Alarm_flag_name}}

    Log  Value of ${Alarm_flag_name} on SBTS ${alias}: ${Alarm_flag_value}  console=True
    Run Keyword If  '${Alarm_flag_value}' == 'True'  Run Keywords
    ...  Set generic alarms lists  ${Container_alarm_list1}
    ...  AND  Log  BTS Alarms from list ${Container_alarm_list_name1} will be checked  console=True
    Run Keyword If  '${Alarm_flag_value}' == 'False'  Run Keywords
    ...  Set generic alarms lists  ${Container_alarm_list2}
    ...  AND  Log  BTS Alarms from list ${Container_alarm_list_name2} will be checked  console=True

Inject user alarms into test case alarm lists
    [Arguments]  ${user_alarm_list_name_suffixes}  ${alias_list}=${alias_list}

    ${USER_ALARM_LIST_NAMES}=  Generate user alarm list names  ${user_alarm_list_name_suffixes}  ${alias_list}

    ${type_of_lists}=   Create List  IGNORED  EXPECTED  CRITICAL

    FOR  ${type_of_list}  IN  @{type_of_lists}
        ${test_case_alarm_list_names}=  Get Dictionary Keys  ${test_alarms_list}
        ${test_case_alarm_list_names}=  Evaluate  [item for item in ${test_case_alarm_list_names} if '${type_of_list}' in item.upper()]
        FOR  ${alias}  IN  @{alias_list}
            FOR  ${input_alarm_list_name}  IN  @{USER_ALARM_LIST_NAMES}
                FOR  ${test_case_alarm_list_name}  IN  @{test_case_alarm_list_names}
                    ${condition}=  Create Long String  '${alias.upper()}' in '${test_case_alarm_list_name}'
                    ...    and '${alias.upper()}' in '${input_alarm_list_name}'
                    ...    and '${type_of_list}' in '${test_case_alarm_list_name}'
                    ...    and '${type_of_list}' in '${input_alarm_list_name}'
                    IF  ${condition}
                        Append To List  ${test_alarms_list['${test_case_alarm_list_name}']}  @{${input_alarm_list_name}}
                    END
                END
            END
        END
    END

Generate user alarm list names
    [Arguments]  ${user_alarm_list_name_suffixes}  ${alias_list}=${alias_list}

    ${user_alarm_list_names}=  Create List
    FOR  ${alias}  IN  @{alias_list}
        FOR  ${user_alarm_list_name_suffix}  IN  @{user_alarm_list_name_suffixes}
            Append To List  ${user_alarm_list_names}  ${alias.upper()}_${user_alarm_list_name_suffix}
        END
    END

    FOR  ${user_alarm_list_name}  IN  @{user_alarm_list_names}
        ${USER_ALARM_LIST}=  Create List
        ${USER_ALARM_LIST}=  Get Variable Value  ${${user_alarm_list_name}}  ${USER_ALARM_LIST}
        Set Test Variable  ${${user_alarm_list_name}}  ${USER_ALARM_LIST}
    END

    [Return]  ${user_alarm_list_names}

Check if GSM Sector TRXs are unlocked
    [Arguments]  ${sector_id}  ${trx_status}

    FOR  ${item}  IN  @{trx_status}
        ${trx_id}=  Get Regexp Matches  ${item[0]}  TRX-0*([1-9]+[0-9]*)  1
        Run Keyword If  '${item[1]}' == 'L'  Run Keywords
        ...  Unlock Trx  bts_id=${sector_id}  trx_id=${trx_id[0]}
        ...  AND  Sleep  15s
        ...  AND  Log  ${item[0]} unlock indicated  console=True
    END

Admin Get BTS ID from SCF
    [Documentation]
    ...  KW is returning bts-id from Admin SCF file. It can be used to get the mandatory argument for
    ...  commissioning KW when bts-id is not accessible as BTS being uncommissioned.
    ...
    ...  *AUTHOR*
    ...  serban.hamza@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+--------------------------------------------------+
    ...  | Parameter name | Man. | Description                                      |
    ...  +================+======+==================================================+
    ...  | scf            | yes  | Admin SCF file
    ...  +----------------+------+--------------------------------------------------+
    ...
    ...  *RETURN*
    ...  | Parameter                 | Description           |
    ...  | MRBTS-id                  | MRBTS ID from Admin SCF file |

    [Arguments]  ${scf}

    ${scf_content}=  OperatingSystem.Get File  ${scf}
    ${get_mrbts_id}=  Get Lines Containing String  ${scf_content}  MRBTS-
    ${get_bts_id}=  Get Regexp Matches  ${get_mrbts_id}  \\d+
    [Return]  ${get_bts_id[0]}

Open connection to BSC
    ${bsc_connection_type}=  Get Variable Value  ${BSC_CONNECTION_TYPE}  ssh
    Log  Connecting to BSC via ${bsc_connection_type}  console=True
    Open session to BSC  connection_type=${bsc_connection_type}

Get Current Time
    [Arguments]  ${when}
    ${current_time}=  BuiltIn.Get Time  time_=UTC
    Set Test Variable  ${time_${when}}  ${current_time}

Get Current Date UTC info
    [Arguments]  ${when}
    Sleep  3s  reason=Avoid time desynchronization
    ${current_date}=  Get Current Date  time_zone=UTC
    Set Test Variable  ${date_timestamp_${when}_UTC}  ${current_date}
    Sleep  3s  reason=Avoid time desynchronization

Set ENB technology
    [Arguments]  ${alias}

    ${NR_cell_ids}=  Get Ids For All  NRCEL  alias=${alias}
    ${NR_runtime_cell_number}=  Get Length  ${NR_cell_ids}

    ${WCDMA_cell_ids}=  Get Ids For All  WNCEL  alias=${alias}
    ${WCDMA_runtime_cell_number}=  Get Length  ${WCDMA_cell_ids}

    ${GSM_cell_ids}=  Get Ids For All  GNCEL  alias=${alias}
    ${GSM_runtime_cell_number}=  Get Length  ${GSM_cell_ids}

    ${tech_type}=  Set Variable If  '${WCDMA_runtime_cell_number}' > '0' or '${GSM_runtime_cell_number}' > '0' or '${NR_runtime_cell_number}' > '0'
    ...  SBTS  LTE
    Set To Dictionary    ${${alias.upper()}}    ${alias.upper()}_TECH=${tech_type}

    Log  ENB tech type is ${tech_type}  console=True

User Set BTS Tech
    [Arguments]  ${alias}

    ${user_tech_type}=  Get Variable Value  ${USER_${alias.upper()}_TECH}  default
    Run Keyword If  '${user_tech_type}'=='default'
    ...  Return From Keyword

    Set To Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH=${user_tech_type}
    Log  User TECH type for ${alias} is ${user_tech_type}.  console=True

Set Services Connection Type
    [Documentation]
    ...  Set VM Connection Type. This KW chooses which connection type to use when connecting to BTS when using ADMIN and ADMIN_INFOMODEL

    [Arguments]    ${bts_connection_type}    ${alias}=Slave

    IF    '${bts_connection_type}' != 'default'
        Log    Using '${bts_connection_type}' connection type for ADMIN and ADMIN_INFOMODEL connections for ${alias}    console=True
        RETURN    ${bts_connection_type}
    END

    ${ADMIN_OAM_info}=    Get Variable Value    ${ADMIN_OAM_${alias.upper()}}    ${FALSE}
    Set Test Variable    ${ADMIN_OAM_${alias.upper()}}    ${ADMIN_OAM_info}

    IF    ${ADMIN_OAM_info}
        Log    Using 'oam_ip' connection type for ADMIN and ADMIN_INFOMODEL connections for ${alias}    console=True
        RETURN    oam_ip
    ELSE
        Log    Using 'admin_forwarder' connection type for ADMIN and ADMIN_INFOMODEL connections for ${alias}    console=True
        RETURN    admin_forwarder
    END

Check if PDU port status is on
    [Documentation]
    ...  Check if PDU output state is on
    [Arguments]  ${if_name}  ${wait_time}=300

    ${PDU_port_status}=  Pdu BTS Interface Get Status  ${if_name}
    Run Keyword If  '${PDU_port_status}' == 'off'  Run Keywords
    ...  Log  Need to set On PDU port for ${if_name}  console=True
    ...  AND  Pdu BTS Interface On  ${if_name}
    ...  AND  Log  Set On PDU port for ${if_name} indicated  console=True
    ...  AND  Log  Wait ${wait_time} seconds for BTS reactivity  console=True
    ...  AND  Sleep  ${wait_time}sec

Set Subrack Position
    [Arguments]  ${alias}
    Run Keyword If  '${${alias.upper()}}[${alias.upper()}_MODULE_TYPE]' in ['ASIA']
    ...  Set Subrack Variable Value  ${alias}

Set Subrack Variable Value
    [Arguments]  ${alias}
    ${SMOD_position}=  coam.Get Smod Position  alias=${alias}
    ${parameter_value}=  Set Variable If  '${SMOD_position}' == 'left'  1  '${SMOD_position}' == 'right'  4
    Set To Dictionary  ${${alias.upper()}}  ${alias.upper()}_SUBRACK  ${parameter_value}

Translate alarm dictionary
    [Documentation]
    ...  KW is translating alarm dictionaries to a specified model
    ...
    ...  This is needed due to using "admin.Get Alarms" instead of "admin.Get Active Alarms" (Different output)
    ...
    ...  *AUTHOR*
    ...  horea.olar@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Mandatory  | Description                                      |
    ...  | active_alarms     | Yes        | List of dictionaries representing active alarms  |
    ...  | translation_model | Yes        | Dictionary in <old_key>=<new_key> format         |
    [Arguments]  ${active_alarms}  ${translation_model}
    ${active_alarms}=  Remove CB010545 header  ${active_alarms}
    FOR  ${alarm_dict}  IN  @{active_alarms}
        ${alarm_dict}=  Change alarm dictionary keys  ${alarm_dict}  ${translation_model}
    END
    [Return]  ${active_alarms}

Remove CB010545 header
    [Arguments]  ${alarm_list}
    ${status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${alarm_list}  btsName
    Run Keyword If  ${status}==False  Return From Keyword  ${alarm_list}
    ${alarm_list}=  Get From Dictionary  ${alarm_list}  alarms
    [Return]  ${alarm_list}

Change alarm dictionary keys
    [Documentation]
    ...  KW is modifying keys from alarm dictionary as specified in translation model
    ...  Kw is skipped if the new_key is already in alarm dictionary
    ...
    ...  | Parameter         | Mandatory  | Description                               |
    ...  | alarm_dict        | Yes        | Alarm dictionary that needs key changing  |
    ...  | translation_model | Yes        | Dictionary in <old_key>=<new_key> format  |
    [Arguments]  ${alarm_dict}  ${translation_model}
    ${old_keys}=  Get Dictionary Keys  ${alarm_dict}
    FOR  ${key}  IN  @{translation_model.keys()}
        Exit For Loop If  '${translation_model['${key}']}' in @{old_keys}
        ${value}=  Pop From Dictionary  ${alarm_dict}  ${key}
        Set To Dictionary  ${alarm_dict}  ${translation_model['${key}']}  ${value}
    END
    [Return]  ${alarm_dict}

Get Historic Alarms
    [Documentation]
    ...  KW used to get a list of Historic Alarms
    ...
    ...  *AUTHOR*
    ...  horea.olar@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter     | Man. | Default | Description               |
    ...  | connection    | Yes  |         | Master or Slave           |
    ...  | load_history  | No   |  False  | Load entire alarm history |
    ...
    [Arguments]  ${connection}  ${load_history}=False
    ${historic_alarms_list}=  coam.Get Historic Alarms  connection=${connection}  load_history=${load_history}  timeout=120
    [Return]  ${historic_alarms_list}

Eval Historic Alarms
    [Documentation]
    ...  KW used to get and check critical or expected historic alarms. It fails if any of below exception case is present:
    ...  - critical alarms are present
    ...  - not all expected alarms are present
    ...  KW applicable for Admin architecture
    ...
    ...  *AUTHOR*
    ...  horea.olar@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter          | Man. | Default | Description                           |
    ...  | connection         | Yes  |         | BTS alias                             |
    ...  | load_history       | No   |  False  | Load entire alarm history (for admin) |
    ...  | expected_alarms    | No   |  False  | expected alarms                       |
    ...  | ignored_alarms     | No   |  False  | ignored alarms                        |
    ...  | critical_alarms    | No   |  False  | critical alarms                       |
    ...  | ignore_unexpected  | No   |  False  | ignore unexpected                     |
    ...  | BTS_architecture   | No   |  SOAM   | critical alarms                       |
    ...
    [Arguments]  ${connection}  ${load_history}=False  ${expected_alarms}=@{EMPTY}  ${ignored_alarms}=@{EMPTY}  ${critical_alarms}=@{EMPTY}
    ...  ${ignore_unexpected}=False  ${BTS_architecture}=SBTS

    ${current_SIMPLIFIED_ALARM}=  Set Variable If  "${BTS_architecture}" == "SBTS"  ${SBTS_HISTORICAL_SIMPLIFIED_ALARM}
    ...  "${BTS_architecture}" == "CBTS" and 'VDU' in '${connection.upper()}'  ${CBTS_VDU_SIMPLIFIED_ALARM}
    ...  "${BTS_architecture}" == "CBTS" and 'CU' in '${connection.upper()}'  ${CBTS_CU_SIMPLIFIED_ALARM}

    ${historic_alarms}=  Run Keyword If  "${BTS_architecture}" == "SBTS"
    ...  Get Historic Alarms  connection=${connection}  load_history=${load_history}
    ...  ELSE IF  "${BTS_architecture}" == "CBTS" and 'VDU' in '${connection.upper()}'
    ...  Vdu Get Historical Alarms  raw=True  vdu_connection=${connection}
    ...  ELSE IF  "${BTS_architecture}" == "CBTS" and 'CU' in '${connection.upper()}'
    ...  cu.Get Historical Alarms  raw=True  connection=${connection}

    ${historic_alarms}=  Run Keyword If  "${BTS_architecture}" == "CBTS"  Get From Dictionary  ${historic_alarms}  alarms
    ...  ELSE IF  "${BTS_architecture}" == "SBTS"  Set Variable  ${historic_alarms}

    ${previous_historic_alarms_status}=  Run Keyword and Return Status  Variable Should Exist  ${previous_historic_alarms_list_${connection}}
    Run Keyword If  ${previous_historic_alarms_status}
    ...  Update Historic Alarms List  ${previous_historic_alarms_list_${connection}}  ${historic_alarms}
    ${found_expected_alarms}  ${not_found_expected_alarms}  ${found_critical_alarms}  ${found_ignored_alarms}  ${found_unexpected_alarms}=
    ...  alarms_analysis.Get Filtered Alarms  ${historic_alarms}  ${expected_alarms}  ${ignored_alarms}  ${critical_alarms}
    ...  ${current_SIMPLIFIED_ALARM}

    Set Test Variable  ${found_critical_alarms}  ${found_critical_alarms}
    Set Test Variable  ${not_found_expected_alarms}  ${not_found_expected_alarms}
    Set Test Variable  ${found_unexpected_alarms}  ${found_unexpected_alarms}

    Run Keyword If  ${found_critical_alarms}  Run Keywords
    ...  Log  Found critical historic alarms :  level=ERROR
    ...  AND  alarms_analysis.Print Alarms  critical_alarms=${found_critical_alarms}  simplified_dictionary=${current_SIMPLIFIED_ALARM}
    ...  AND  Fail  Found critical historic alarms
    ...  ELSE IF  ${not_found_expected_alarms}  Run Keywords
    ...  Log  Missing expected historic alarms:  level=ERROR
    ...  AND  alarms_analysis.Print Alarms  missing_alarms_patterns=${not_found_expected_alarms}  simplified_dictionary=${current_SIMPLIFIED_ALARM}
    ...  AND  Fail  Missing expected historic alarms
    ...  ELSE IF  ${found_unexpected_alarms} and ${ignore_unexpected}==False  Run Keywords
    ...  Log  Found unexpected historic alarms:  level=WARN
    ...  AND  alarms_analysis.Print Alarms  warnings=${found_unexpected_alarms}  simplified_dictionary=${current_SIMPLIFIED_ALARM}
    ...  AND  Log  Snapshot will be triggered at the end of test  console=True
    ...  AND  Set Test Variable  ${SnapshotTriggerEndTest}  YES
    ...  ELSE IF  ${found_unexpected_alarms} and ${ignore_unexpected}==True  Run Keywords
    ...  Log  Found unexpected historic alarms:  level=INFO  console=True
    ...  AND  alarms_analysis.Print Alarms  ignored_alarms=${found_unexpected_alarms}  simplified_dictionary=${current_SIMPLIFIED_ALARM}
    ...  ELSE
    ...  Log  Historic alarm status is OK.  level=INFO  console=True

    Append To List  ${previous_historic_alarms_list_${connection}}  @{historic_alarms}
    Set Test Variable  ${previous_historic_alarms_list_${connection}}

Update Historic Alarms List
    [Arguments]  ${previous_list}  ${newer_list}
    FOR  ${item}  IN  @{previous_list}
        Remove Values from list  ${newer_list}  ${item}
    END
    Set Test Variable  ${historic_alarms}  ${newer_list}

Get Historic Alarms from Admin
    [Documentation]
    ...   KW used during Snapshot procedure to get historic alarms from Admin and add them in specific files.
    ...  *AUTHOR*
    ...  adelina.branc@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter       | Man. | Default | Description                                |
    ...  | alias           | No   |   None  | Master or Slave                            |
    ...  | folder_path     | No   |   None  | Folder path for store historic alarms file |
    [Arguments]   ${alias}=None  ${folder_path}=None

    Log  Getting ${alias} historical alarms  console=True
    ${historic_alarms}=  Get Historic Alarms  connection=${alias}  load_history=True
    ${type_historic_alarms}=  Evaluate  type($historic_alarms).__name__

    ${folder_path}=  Set Variable If  '${folder_path}' == 'None'  ${snapshot_and_alarms_dir}  ${folder_path}
    Create File  ${folder_path}/${alias}_${${alias.upper()}}[${alias.upper()}_TECH]_historic_alarms.txt
    Log  ${alias} historic alarms available at: ${folder_path}/${alias}_${${alias.upper()}}[${alias.upper()}_TECH]_historic_alarms.txt
    ...  console=True

    ${text_type_robot}=  Evaluate  six.text_type.__name__  modules=six
    Run Keyword If  '${type_historic_alarms}'=='${text_type_robot}'
    ...  Append To File  ${folder_path}/${alias}_${${alias.upper()}}[${alias.upper()}_TECH]_historic_alarms.txt
    ...  ${historic_alarms} \n\n
    ...  ELSE IF  '${type_historic_alarms}'=='list'  Write alarms list to file
    ...  ${historic_alarms}  ${folder_path}/${alias}_${${alias.upper()}}[${alias.upper()}_TECH]_historic_alarms.txt

Update TL Variables
    [Arguments]  ${preset_techs}=@{EMPTY}  ${common_sbts}=${FALSE}  ${newAlarmsFormat}=${FALSE}

    ${master_pcsshuser_present}=  Run Keyword And Return Status  Variable Should Exist  ${MASTER['MASTER_PC_SSH_USERNAME']}
    ${master_pcsshpass_present}=  Run Keyword And Return Status  Variable Should Exist  ${MASTER['MASTER_PC_SSH_PASSWORD']}

    Run Keyword If  not ${master_pcsshuser_present}  Set Test Variable  ${MASTER['MASTER_PC_SSH_USERNAME']}  ute
    Run Keyword If  not ${master_pcsshpass_present}  Set Test Variable  ${MASTER['MASTER_PC_SSH_PASSWORD']}  ute

    Run Keyword If  ${preset_techs} != @{EMPTY}  Update Entity Tech Variables  ${preset_techs}
    Set Test Variable  ${common_sbts}
    Set Test Variable  ${newAlarmsFormat}

Update Entity Tech Variables
    [Arguments]  ${preset_techs}

    ${tech_list_length}=  Get Length  ${preset_techs}

    FOR  ${idx}  IN RANGE  ${tech_list_length}
        ${alias_presence}=  Get Variable Value  ${alias_list[${idx}]}  None
        Continue For Loop If  '${alias_presence}' == 'None'
        Set To Dictionary  ${${alias_list[${idx}].upper()}}  ${alias_list[${idx}].upper()}_TECH=${preset_techs[${idx}]}
    END

Load Listener for reporting to RFS Test Reporter
    [Documentation]
    ...  Keyword that loads external listener in order to report each TC to RFS Test Reported even
    ...  from Cloud environment.
    [Tags]  robot:no-dry-run

    ${reporting_from_cloud}=  Get Variable Value  ${CLOUD_ENV_REPORTING}  ${True}
    Return From Keyword If  '${reporting_from_cloud}'=='${False}'

    ${cloud_env_status}=  Get Variable Value  ${CLOUD_ENV}  ${False}
    Return From Keyword If  '${cloud_env_status}'=='${False}'

    Log  Load Listener for reporting to RFS Test Reporter  console=True
    Import Library  ${CURDIR}/python_resources/RfsListenerLib.py

Turn on all Testline HW when running from Cloud Environment
    [Documentation]
    ...  KW that checks every entity's state(SMOD, RMOD, BBMOD) defined in interfaces.yaml and turns it on is needed.
    ...  Behaviour available only when running from Cloud environment. By default, KW waits for 600sec after at least
    ...  one entity change of state. User can configure this time at suite level

    ${power_on_flag_status}=  Get Variable Value  ${POWER_ON_FLAG}  ${False}
    Return From Keyword If  '${power_on_flag_status}'=='${False}'
    ${at_least_one_powered_on}=  Set Variable  ${False}

    Log  Turn on Testline HW found in config file  console=True
    ${interfaces_keys}=  Get Dictionary Keys  ${INTERFACES}
    FOR  ${item}  IN  @{interfaces_keys}

        Continue For Loop If  'FHGW' in '${item}'
        ${status_outlet_before}=  Pdu BTS Interface Get Status  ${item}
        Continue For Loop If  '${status_outlet_before}'=='on'

        ${status}=  Run Keyword And Return Status  Should Match Regexp  ${item}  SMOD_.*|BBMOD_.*|FHS_.*|RMOD_.*
        Run Keyword If  ${status}  Pdu BTS Interface On  ${item}
        ${status_outlet_after}=  Pdu BTS Interface Get Status  ${item}
        Run Keyword If  '${status_outlet_after}'=='on'
        ...  Run Keywords
        ...  Log  ${item} was successfully powered on!  console=True
        ...  AND  Set Test Variable  ${at_least_one_powered_on}  ${True}
        ...  ELSE  Fail  ${item} could not be powered on, not as expected!
    END

    ${time_for_sleep}=  Get Variable Value  ${POWER_ON_SLEEP_SECONDS}  600
    Run Keyword If  '${at_least_one_powered_on}'=='${True}'
    ...  Run Keywords
    ...  Log  Sleep ${time_for_sleep} sec additional time after Testline power on  console=True
    ...  AND  Sleep  ${time_for_sleep}

Export KPI Results to File
    [Documentation]
    ...  Keyword is used to add kpi info to a specified file, by default the KpiTimeInfo.txt file
    ...
    ...  | Parameter      | Man. | Description                                                                                            |
    ...  | alias          | Yes  | Master/Slave                                                                                           |
    ...  | obj_info       | No   | Object info. Relevant info for object: if it is empty, label "${obj} Type" will be displayed, otherwise|
    ...                            its value (this value appears in the table header. see KW:Create KPI File and Append TC Info)          |
    ...  | obj            | No   | Object name. Possible values: RMOD, BBMOD, CELL (this value appears in the table header. see KW:       |
    ...                            Create KPI File and Append TC Info)                                                                    |
    ...  | action_1       | No   | TC action. Example: Reset, Block, Unblock, etc. (this value appears in the table header. see KW:       |
    ...                            Create KPI File and Append TC Info)                                                                    |
    ...  | action_2       | No   | TC action. Example: Reset, Block, Unblock, etc. This parameter is needed when we need to               |
    ...                            measure 2 KPIs. (this value appears in the table header. see KW: Create KPI File and Append TC Info)   |
    ...  | obj_type       | No   | Object type. Possible values: in case of RMOD (AEHC, FRIJ, etc), in case of BBMOD (ABIL, ABIA, etc),   |
    ...                            in case of CELL (NRCEL, LNCEL, etc)                                                                    |
    ...  | obj_id         | No   | Object id. Possible values: in case of RMOD (RMOD_R-1, etc), in case of BBMOD (BBMOD_R-1, etc)         |
    ...                            in case of CELL (NRCEL_R-1, etc)                                                                       |
    ...  | kpi_reported_1 | Yes  | Kpi ID. Example: KPI 1a, KPI 3, KPI 51                                                                 |
    ...  | kpi_reported_2 | Yes  | Kpi ID. Example: KPI 1a, KPI 3, KPI 51. This parameter is needed when we need to measure 2 KPIs        |
    ...  | info_1         | Yes  | Short KPI description                                                                                  |
    ...  | info_2         | Yes  | Short KPI description. This parameter is needed when we need to measure 2 KPIs                         |
    ...  | kpi_log_file   | Yes  | File where to print the reset duration info. By default, ${BTS Files}/${alias}/KpiTimeInfo.txt         |
    ...  | cycle          | No   | number of iteration to be printed, in case of iterative tc                                             |
    ...  | event_value_1  | No   | event duration in seconds                                                                              |
    ...  | event_value_2  | No   | event duration in seconds. This parameter is needed when we need to measure 2 KPIs                     |
    ...  | source_info    | Yes  | Source providing duration info: events or ims                                                          |
    ...  | add_info_label | Yes  | Additional info label                                                                                  |
    ...  | add_info_value | Yes  | Additional info value                                                                                 |
    ...
    ...  *EXAMPLE*
    ...  Export KPI Results to File | alias=Master | obj=BBMOD | obj_type=ABIL | obj_id=BBMOD_R-1 | action_1=Reset | kpi_reported_1=KPI_5 |
    ...  | info_1=first_cell_down_to_last_cell_up | event_value_1=270 | cycle=1

    [Arguments]  ${alias}  ${obj_info}=${EMPTY}  ${obj}=${EMPTY}  ${obj_type}=${EMPTY}  ${obj_id}=${EMPTY}  ${action_1}=${EMPTY}
    ...  ${kpi_reported_1}=${EMPTY}  ${info_1}=${EMPTY}  ${event_value_1}=${EMPTY}  ${action_2}=${EMPTY}  ${kpi_reported_2}=${EMPTY}
    ...  ${info_2}=${EMPTY}  ${event_value_2}=${EMPTY}  ${cycle}=${EMPTY}  ${kpi_log_file}=${EMPTY}  ${kpi_log_file_name}=KpiTimeInfo
    ...  ${source_info}=events  ${add_info_label}=${EMPTY}  ${add_info_value}=${EMPTY}

    ${kpi_skip_enabled}=  Check If KPI Check Skip Enabled
    Return From Keyword If  ${kpi_skip_enabled}

    ${obj_info}=  Set Variable If  '${obj_info}' == '${EMPTY}'  ${obj} Type  ${obj_info}

    ${cbts_alias}=  Split String  ${alias}  ${SPACE}
    Run Keyword If  '${kpi_log_file}' == '${EMPTY}' and '${alias}' in ${alias_list}
    ...  Set Test Variable  ${kpi_log_file}  ${BTS Files}/${alias}/${kpi_log_file_name}.txt
    ...  ELSE IF  '${kpi_log_file}' == '${EMPTY}'
    ...  Set Test Variable  ${kpi_log_file}  ${BTS Files}/${cbts_alias}[0]/${cbts_alias}[1]/${kpi_log_file_name}.txt
    ...  ELSE
    ...  Set Test Variable  ${kpi_log_file}
    ${kpi_log_file_exists}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${kpi_log_file}
    Run Keyword If  not ${kpi_log_file_exists}
    ...  Create KPI File and Append TC Info  ${alias}  ${kpi_log_file}  ${obj_info}  ${obj}  ${kpi_reported_2}  ${action_1}  ${action_2}
    ...  ${source_info}  ${add_info_label}
    ${cycle1}=  Set Variable If  '${cycle}' != '${EMPTY}'  at cycle #${cycle}  ${EMPTY}

    ${info_cond1}=  Create Long String  ${obj_type} | ${obj_id} | ${kpi_reported_1} (${info_1}) value ${cycle1}: ${event_value_1} sec
    ${info_cond2}=  Create Long String  ${obj_type} | ${obj_id} | ${kpi_reported_1} (${info_1}) value ${cycle1}: ${event_value_1} sec |
    ...  ${kpi_reported_2} (${info_2}) value ${cycle1}: ${event_value_2} sec
    ${info_cond3}=  Create Long String  ${obj_type} | ${obj_id} | ${kpi_reported_1} (${info_1}) value ${cycle1}: ${event_value_1} sec |
    ...  ${add_info_value}
    ${info_cond4}=  Create Long String  ${obj_type} | ${obj_id} | ${kpi_reported_1} (${info_1}) value ${cycle1}: ${event_value_1} sec |
    ...  ${kpi_reported_2} (${info_2}) value ${cycle1}: ${event_value_2} sec | ${add_info_value}

    Run Keyword If  '${kpi_reported_2}' == '${EMPTY}' and '${add_info_label}' == '${EMPTY}'  Run Keywords
    ...  Append To File  ${kpi_log_file}  ${info_cond1} \n
    ...  AND  Log  [ KPI duration ] of: ${kpi_reported_1} (${info_1}) ${cycle1} for ${obj_id} is: ${event_value_1} sec  level=INFO  console=True
    ...  ELSE IF  '${kpi_reported_2}' != '${EMPTY}' and '${add_info_label}' == '${EMPTY}'  Run Keywords
    ...  Append To File  ${kpi_log_file}  ${info_cond2} \n
    ...  AND  Log  [ KPI duration ] of: ${kpi_reported_1} (${info_1}) ${cycle1} for ${obj_id} is: ${event_value_1} sec  level=INFO  console=True
    ...  AND  Log  [ KPI duration ] of: ${kpi_reported_2} (${info_2}) ${cycle1} for ${obj_id} is: ${event_value_2} sec  level=INFO  console=True
    ...  ELSE IF  '${kpi_reported_2}' == '${EMPTY}' and '${add_info_label}' != '${EMPTY}'  Run Keywords
    ...  Append To File  ${kpi_log_file}  ${info_cond3} \n
    ...  AND  Log  [ KPI duration ] of: ${kpi_reported_1} (${info_1}) ${cycle1} for ${obj_id} is: ${event_value_1} sec  level=INFO  console=True
    ...  ELSE IF  '${kpi_reported_2}' != '${EMPTY}' and '${add_info_label}' != '${EMPTY}'  Run Keywords
    ...  Append To File  ${kpi_log_file}  ${info_cond4} \n
    ...  AND  Log  [ KPI duration ] of: ${kpi_reported_1} (${info_1}) ${cycle1} for ${obj_id} is: ${event_value_1} sec  level=INFO  console=True
    ...  AND  Log  [ KPI duration ] of: ${kpi_reported_2} (${info_2}) ${cycle1} for ${obj_id} is: ${event_value_2} sec  level=INFO  console=True

Create KPI File and Append TC Info
    [Documentation]
    ...  Keyword is used to create the kpi log file and populate first line with testline information.
    ...
    ...  | Parameter    | Man. | Description                                                                              |
    ...  | alias        | Yes  | Master/Slave                                                                             |
    ...  | kpi_log_file | Yes  | File where to print the kpi info. By default, ${BTS Files}/${alias}/KpiTimeInfo.txt      |
    ...  | obj_info     | Yes  | Object info. Relevant info for object (this value appears in the table header)           |
    ...  | obj          | Yes  | Object name. Possible values: RMOD, BBMOD, CELL (this value appears in the table header) |
    ...  | action_1     | Yes  | TC action. Example: Reset, Block, Unblock, etc. (this value appears in the table header) |
    ...  | action_2     | Yes  | TC action. Example: Reset, Block, Unblock, etc. This parameter is needed when we need to |
    ...  |                       measure 2 KPIs. (this value appears in the table header)                                 |
    ...  | source_info  | Yes  | Source providing duration info: event or ims                                             |
    ...  | add_info_label | Yes  | Additional info label                                                                  |

    [Arguments]  ${alias}  ${kpi_log_file}  ${obj_info}  ${obj}  ${kpi_reported_2}  ${action_1}  ${action_2}  ${source_info}  ${add_info_label}

    ${alias_upper}=  String.Convert To Uppercase  ${alias}
    Append To File  ${kpi_log_file}  ${TEST NAME} \n
    Append To File  ${kpi_log_file}  Active SW: ${${alias}_active_SW_version_initial} \n
    Run Keyword If  '${alias}' in ${alias_list}
    ...  Append To File  ${kpi_log_file}  Tech: SBTS \n
    ...  ELSE
    ...  Append To File  ${kpi_log_file}  Tech: CBTS \n

    Run Keyword If  '${kpi_reported_2}' == '${EMPTY}' and '${add_info_label}' == '${EMPTY}'
    ...  Append To File   ${kpi_log_file}
    ...  \n ${obj_info} | ${obj} | ${action_1} duration based on ${source_info} \n
    ...  ELSE IF  '${kpi_reported_2}' != '${EMPTY}' and '${add_info_label}' == '${EMPTY}'
    ...  Append To File  ${kpi_log_file}
    ...  \n ${obj_info} | ${obj} | ${action_1} duration based on ${source_info} | ${action_2} duration based on ${source_info} \n
    ...  ELSE IF  '${kpi_reported_2}' == '${EMPTY}' and '${add_info_label}' != '${EMPTY}'
    ...  Append To File  ${kpi_log_file}
    ...  \n ${obj_info} | ${obj} | ${action_1} duration based on ${source_info} | ${add_info_label} \n
    ...  ELSE IF  '${kpi_reported_2}' != '${EMPTY}' and '${add_info_label}' != '${EMPTY}'
    ...  Append To File  ${kpi_log_file}
    ...  \n ${obj_info} | ${obj} | ${action_1} duration based on ${source_info} | ${action_2} duration based on ${source_info} | ${add_info_label} \n

    Append To File  ${kpi_log_file}  =========================================================================================== \n

Export KPI Results to File Global
    [Documentation]
    ...  Keyword is used to create a global file where all kpi info from test set execution will be exported

    [Arguments]  ${kpi_log_file_name}=KpiTimeInfo

    ${kpi_skip_enabled}=  Check If KPI Check Skip Enabled
    Return From Keyword If  ${kpi_skip_enabled}

    Set Test Variable  ${kpi_log_file_global}  ${OUTPUT DIR}/${kpi_log_file_name}Global.txt
    ${test_timestamp}=  OperatingSystem.Run  date +%F_%H-%M-%S
    Set Test Variable  ${TEST}  ${test_timestamp}_TEST-${TEST NAME}
    Run Keywords
    ...  Append To File  ${kpi_log_file_global}  ===========================================================================================
    ...  AND  Append To File  ${kpi_log_file_global}  \n ${TEST} \n
    ...  AND  Append To File  ${kpi_log_file_global}  =========================================================================================== \n

    FOR  ${alias}  IN  @{alias_list}

        ${kpi_file_exists}=  Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']
        ...  Export classical BTS KPI Results to File Global  ${kpi_log_file_name}  ${alias}
        ...  ELSE IF  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'  Run Keywords
        ...  Export cloud BTS CU KPI Results to File Global  ${kpi_log_file_name}  ${alias}
        ...  AND  Export cloud BTS VDU KPI Results to File Global  ${kpi_log_file_name}  ${alias}

    END

Export classical BTS KPI Results to File Global
    [Arguments]  ${kpi_log_file_name}  ${alias}

    ${kpi_log_folder_file_name}=  Set Variable  ${BTS Files}/${alias}/${kpi_log_file_name}.txt
    ${kpi_file_exists}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${kpi_log_folder_file_name}
    Return From Keyword If  '${kpi_file_exists}' == 'False'
    ${kpi_file_content}=  OperatingSystem.Get File  ${kpi_log_folder_file_name}
    Append To File  ${kpi_log_file_global}  ${kpi_file_content}
    Append To File  ${kpi_log_file_global}  =========================================================================================== \n

Export cloud BTS CU KPI Results to File Global
    [Arguments]  ${kpi_log_file_name}  ${alias}

    ${kpi_log_folder_file_name}=  Set Variable  ${BTSFiles}/${alias}/CU/${kpi_log_file_name}.txt
    ${kpi_file_exists}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${kpi_log_folder_file_name}
    Return From Keyword If  '${kpi_file_exists}' == 'False'
    ${kpi_file_content}=  OperatingSystem.Get File  ${kpi_log_folder_file_name}
    Append To File  ${kpi_log_file_global}  ${kpi_file_content}
    Append To File  ${kpi_log_file_global}  =========================================================================================== \n

Export cloud BTS VDU KPI Results to File Global
    [Arguments]  ${kpi_log_file_name}  ${alias}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${kpi_log_folder_file_name}=  Set Variable  ${BTSFiles}/${alias}/VDU${index+1}/${kpi_log_file_name}.txt
        ${kpi_file_exists}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${kpi_log_folder_file_name}
        Return From Keyword If  '${kpi_file_exists}' == 'False'
        ${kpi_file_content}=  OperatingSystem.Get File  ${kpi_log_folder_file_name}
        Append To File  ${kpi_log_file_global}  ${kpi_file_content}
        Append To File  ${kpi_log_file_global}  =========================================================================================== \n

    END

Get SBTS build release version
    [Arguments]  ${alias}

    Log  Check SBTS build release version given by user for BTS ${alias}.  console=True
    ${release_version}=  Get Variable Value  ${SBTS_RELEASE_VERSION}  None
    Run Keyword If  '${release_version}' != 'None'  Run Keywords
    ...  Log  SBTS build release version was set to ${release_version} for BTS ${alias}.  console=True
    ...  AND  Return From Keyword  ${release_version}
    ${release_version}=  Get Variable Value  ${SBTS_RELEASE_VERSION_${alias.upper()}}  None
    Run Keyword If  '${release_version}' != 'None'
    ...  Log  SBTS build release version was set to ${release_version} for BTS ${alias}.  console=True

    [Return]  ${release_version}

Get Scout TL name based on TL configuration
    [Documentation]
    ...  Keyword providing Scout TL name based on TL configuration as follows:
    ...  - if TL contains a single admin BTS (SOAM arhitecture) -> ${SCOUT_TL_NAME} = ${TESTLINE_NAME}
    ...  - if TL contains multiple admin BTSs (SOAM arhitecture) -> ${SCOUT_TL_NAME} = ${TESTLINE_NAME}_BTS1
    ...  Always in case of TL with multiple admin BTSs, ${TESTLINE_NAME}_BTS1 label is reported by default, if it is not set by user
    ...  Convention to declare TL with multiple admin BTSs in SCOUT is ${TESTLINE_NAME}_BTS<index>
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ${admin_alias_count}=  Set Variable  0
    FOR  ${alias}  IN  @{alias_list}
        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'
        ...  Continue For Loop
        ${admin_alias_count}=  Evaluate  ${admin_alias_count} + 1
    END
    ${SCOUT_TL_NAME}=  Set Variable If  ${admin_alias_count} == 1  ${TESTLINE_NAME}  ${TESTLINE_NAME}_BTS1
    Set Test Variable  ${SCOUT_TL_NAME}

Get Scout SCF id
    [Documentation]
    ...  Keyword providing SCF id from Scout by TL name.
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter             | Man. | Description                                                                |
    ...  | scout_testline_name   | Yes  | Name of testline registered in Scout                                       |
    ...  | alias                 | No   | Name of execution context                                                  |
    ...  | use_scout_internal_id | No   | Defines whether to report SCF Analysis with Scout SCF id. Possible values:
    ...                                   - False: if you use UTE CM to schedule your tests (or you use single run)
    ...                                   - True: if you run your test manually/from command line on VM              |
    ...
    ...  *RETURN VALUE*
    ...  | Scout_SCF_id | SCF id info from Scout |
    ...
    [Arguments]  ${scout_testline_name}  ${alias}=default  ${use_scout_internal_id}=${False}
    ${Scout_setup_status}  ${Scout_setup_response}=  Run Keyword And Ignore Error
    ...  scout.Setup Scout  scout_testline_name=${scout_testline_name}  alias=${alias}

    Run Keyword If  '${Scout_setup_status}' == 'FAIL' and '_BTS' not in '${scout_testline_name}'  Run Keywords
    ...  Log  Scout setup failed! ${Scout_setup_response}  console=True
    ...  AND  Return From Keyword  ${NONE}

    ${Scout_setup_status}  ${Scout_setup_response}=  Run Keyword If  '${Scout_setup_status}' == 'FAIL' and '_BTS' in '${scout_testline_name}'
    ...  Retry on TL name  ${scout_testline_name}  ${alias}
    ...  ELSE  Set Variable  ${Scout_setup_status}  ${Scout_setup_response}

    Run Keyword If  '${Scout_setup_status}' == 'FAIL'  Run Keywords
    ...  Log  Scout setup failed! ${Scout_setup_response}  console=True
    ...  AND  Return From Keyword  ${NONE}

    ${Scout_request_scf_status}  ${Scout_request_scf_response}=  Run Keyword And Ignore Error
    ...  scout.Request Scf  timeout=120  admin_connect_timeout=120  use_scout_internal_id=${use_scout_internal_id}  alias=${alias}
    Run Keyword If  '${Scout_request_scf_status}' == 'FAIL'  Run Keywords
    ...  Log  Get SCF id from Scout failed! ${Scout_request_scf_response}  console=True
    ...  AND  Return From Keyword  ${NONE}
    ${Scout_SCF_id}=  Set Variable  ${Scout_request_scf_response}

    [Return]  ${Scout_SCF_id}
    [Teardown]  scout.Teardown Scout API  alias=${alias}

Retry on TL name
    [Arguments]  ${scout_testline_name}  ${alias}

    ${scout_testline_name}=  Replace String Using Regexp  ${scout_testline_name}  _BTS  _
    Log  Retry with new Scout TL name: ${scout_testline_name}  console=True

    ${Scout_setup_status}  ${Scout_setup_response}=  Run Keyword And Ignore Error
    ...  scout.Setup Scout  scout_testline_name=${scout_testline_name}  alias=${alias}

    [Return]    ${Scout_setup_status}  ${Scout_setup_response}

Power OFF Hardware
    [Documentation]
    ...  KW that checks power off entities based on the supplied parameter. Created to be used in the teardown of test suites.

    [Arguments]  ${equipment_modules}=ALL

    Log  Turn off Testline HW found in config file  console=True
    ${interfaces_keys}=  Get Dictionary Keys  ${INTERFACES}

    ${modules}=  Set Variable If  "${equipment_modules}" == "RMOD"  RMOD_.*  SMOD_.*|BBMOD_.*|RMOD_.*

    FOR  ${item}  IN  @{interfaces_keys}
        ${status_outlet_before}=  Pdu BTS Interface Get Status  ${item}
         Run Keyword If  '${status_outlet_before}'=='off'  Continue For Loop

        ${status}=  Run Keyword And Return Status  Should Match Regexp  ${item}  ${modules}
        Run Keyword If  ${status}  Pdu BTS Interface Off  ${item}
        ${status_outlet_after}=  Pdu BTS Interface Get Status  ${item}
        Run Keyword If  '${status_outlet_after}'=='off' and ${status}
        ...  Log  ${item} was successfully powered off!  console=True
        ...  ELSE  Run Keyword If  ${status}  Log  ${item} could not be automatically powered off!  console=True
    END

Get elapsed time
    [Arguments]  ${time_initial}  ${HW_MAX_WAIT_TIME}
    Get Current Time  elapsed
    ${time_elapsed_before_check}=  DateTime.Subtract Date From Date  ${time_elapsed}  ${time_initial}  number
    ${remained_MAX_WAIT_TIME}=  BuiltIn.Evaluate  ${HW_MAX_WAIT_TIME}-${time_elapsed_before_check}
    [Return]  ${remained_MAX_WAIT_TIME}

Reset BTS Configuration TAF
    [Arguments]  ${connection}  ${remove_operator_certificates}=False  ${remove_user_account_credentials}=False  ${repair_center_reset}=False
    ...  ${timeout}=700  ${detailed_output}=False  ${reset_type}=Configuration  ${fdsw_ip}=192.168.255.129  ${fdsw_username}=Nemuadmin
    ...  ${fdsw_password}=nemuuser  ${wait_for_admin_connection}=True

    Reset BTS Configuration
    ...  connection=${connection}
    ...  remove_operator_certificates=${remove_operator_certificates}  remove_user_account_credentials=${remove_user_account_credentials}
    ...  repair_center_reset=${repair_center_reset}  timeout=${timeout}  detailed_output=${detailed_output}  reset_type=${reset_type}
    ...  fdsw_ip=${fdsw_ip}  fdsw_username=${fdsw_username}  fdsw_password=${fdsw_password}  wait_for_admin_connection=${wait_for_admin_connection}

Get LTEENB list
    [Arguments]  ${alias}
    ${scf}=  coam.Get Scf  connection=${alias}  export_type=configurationAndRuntimeObjects  with_auto_configured_parameters=${TRUE}
    ${LTEENB_list}=  Get Regexp Matches  ${scf}  MRBTS-[0-9]*\/NRBTS-[0-9]*\/LTEENB-[0-9]*
    ${LTEENB_count}=  Get Length  ${LTEENB_list}

    [Return]  ${LTEENB_list}  ${LTEENB_count}

Common CU Setup
    [Documentation]
    ...  Setup connection on CBTS CU.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter      | Man. | Description                                                                                                |
    ...  | alias          | Yes  | BTS alias                                                                                                  |
    ...  | cu_version     | No   | Specifies version of the CU. Default value: cuoam_24r2                                                     |
    ...  | secure         | No   | If set to True, the connection will be realized with use https prefix, else with http. Default value: True |
    ...  | login_disabled | No   | If set to True, we will not try to login but instead use default token. Default value: False               |
    ...  | timeout        | No   | Timeout for the operation. Default value: 30 secs                                                          |
    ...
    [Arguments]  ${alias}  ${secure}=True  ${login_disabled}=False  ${timeout}=30

    ${secure}=  Convert To Boolean  ${secure}
    ${login_disabled}=  Convert To Boolean  ${login_disabled}

    ${cu_host}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_CU_IP_ADDRESS]
    ${cu_port}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_CU_PORT]
    ${cu_username}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_CU_USERNAME]
    ${cu_password}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_CU_PASSWORD]
    ${cu_alias}=  Set Variable  ${alias} CU
    Set Test Variable  ${${cu_alias.lower()}_cu_host}  ${cu_host}
    Set Test Variable  ${${cu_alias.lower()}_cu_port}  ${cu_port}
    Set Test Variable  ${${cu_alias.lower()}_cu_username}  ${cu_username}
    Set Test Variable  ${${cu_alias.lower()}_cu_password}  ${cu_password}

    Log  Setup ${cu_alias} (ip=${cu_host}, port=${cu_port}) connection started  console=True

    ${cu_setup_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  5 min  10 sec
    ...  cu.Connect To  host=${cu_host}  port=${cu_port}  username=${cu_username}  password=${cu_password}  secure=${secure}
    ...  login_disabled=${login_disabled}  alias=${cu_alias}  timeout=${timeout}

    Run Keyword If  ${cu_setup_status}
    ...  Log  Setup ${cu_alias} (ip=${cu_host}, port=${cu_port}) connection successfully performed!  console=True
    ...  ELSE
    ...  Log  Setup ${cu_alias} (ip=${cu_host}, port=${cu_port}) connection failed!  console=True

Common VDU Setup
    [Documentation]
    ...  Setup connection on CBTS VDUs.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter      | Man. | Description                                                                                  |
    ...  | alias          | Yes  | BTS alias                                                                                    |
    ...  | vdu_version    | No   | Info related to VDU version release, default value: cuoam_24r2                               |
    ...  | secure         | No   | If set to True, the connection uses https prefix, else it uses http. Default value: True     |
    ...  | login_disabled | No   | If set to True, we will not try to login but instead use default token. Default value: False |
    ...  | need_all_info  | No   | Is need all login response. Default value: False                                             |
    ...  | timeout        | No   | Timeout for the operation. Default value: 30 secs                                            |
    ...
    [Arguments]  ${alias}  ${secure}=True  ${login_disabled}=False  ${need_all_info}=False  ${timeout}=30

    ${secure}=  Convert To Boolean  ${secure}
    ${login_disabled}=  Convert To Boolean  ${login_disabled}
    ${need_all_info}=  Convert To Boolean  ${need_all_info}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_host}=  Get From Dictionary  ${vdu_info}  IP_ADDRESS
        ${vdu_port}=  Get From Dictionary  ${vdu_info}  PORT
        ${vdu_username}=  Get From Dictionary  ${vdu_info}  USERNAME
        ${vdu_password}=  Get From Dictionary  ${vdu_info}  PASSWORD
        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}
        Set Test Variable  ${${vdu_alias.lower()}_vdu_host}  ${vdu_host}
        Set Test Variable  ${${vdu_alias.lower()}_vdu_port}  ${vdu_port}
        Set Test Variable  ${${vdu_alias.lower()}_vdu_usernamet}  ${vdu_username}
        Set Test Variable  ${${vdu_alias.lower()}_vdu_password}  ${vdu_password}

        Log  Setup ${vdu_alias} (ip=${vdu_host}, port=${vdu_port}) connection started  console=True

        ${vdu_setup_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  5 min  10 sec
        ...  vdu.Connect To  host=${vdu_host}  port=${vdu_port}  username=${vdu_username}  password=${vdu_password}  secure=${secure}
        ...  login_disabled=${login_disabled}  connection_name=${vdu_alias}  need_all_info=${need_all_info}  timeout=${timeout}

        Run Keyword If  ${vdu_setup_status}
        ...  Log  Setup ${vdu_alias} (ip=${vdu_host}, port=${vdu_port}) connection successfully performed!  console=True
        ...  ELSE
        ...  Log  Setup ${vdu_alias} (ip=${vdu_host}, port=${vdu_port}) connection failed!  console=True

    END

Common CU Teardown
    [Documentation]
    ...  Teardown connection on CBTS CU.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                                       |
    ...  | alias     | Yes  | BTS alias                                         |
    ...  | timeout   | No   | Timeout for the operation. Default value: 10 secs |
    ...
    [Arguments]  ${alias}    ${timeout}=10

    ${cu_alias}=  Set Variable  ${alias} CU

    ${cu_disconnect_status}=  Run Keyword And Return Status  cu.Disconnect  connection=${cu_alias}  timeout=${timeout}

    Run Keyword If  ${cu_disconnect_status}
    ...  Log  Teardown ${cu_alias} successfully performed!  console=True
    ...  ELSE
    ...  Log  Teardown ${cu_alias} failed!  console=True

Common VDU Teardown
    [Documentation]
    ...  Teardown connection on CBTS VDUs.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                                       |
    ...  | alias     | Yes  | BTS alias                                         |
    ...  | timeout   | No   | Timeout for the operation. Default value: 60 secs |
    ...
    [Arguments]  ${alias}  ${timeout}=60

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        ${vdu_disconnect_status}=  Run Keyword And Return Status  vdu.Disconnect  vdu_connection=${vdu_alias}  timeout=${timeout}

        Run Keyword If  ${vdu_disconnect_status}
        ...  Log  Teardown ${vdu_alias} successfully performed!  console=True
        ...  ELSE
        ...  Log  Teardown ${vdu_alias} failed!  console=True

    END

Get CBTS SW Version
    [Arguments]  ${alias}

    Get CU SW Version  ${alias}
    Get VDU SW Version  ${alias}

Get CU SW Version
    [Documentation]
    ...  Get installed software version on CBTS CU.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description |
    ...  | alias     | Yes  | BTS alias   |

    [Arguments]  ${alias}

    ${cu_alias}=  Set Variable  ${alias} CU

    ${CU_SW_version}=  CU Get SW Version  connection=${cu_alias}
    Set Test Variable  ${${alias}_CU_SW_version_initial}  ${CU_SW_version}
    Log  ${cu_alias} active SW: ${CU_SW_version}  console=True

    ${value}=  Convert To Uppercase  ${CU_SW_version}
    Set Tags  SW version - ${cu_alias} active = ${value}
    Set Test Variable  ${QC ${cu_alias} Active SW}  ${value}

    ${status_ext}=  Run Keyword And Return Status  Variable Should Exist  ${tag_cu_string}
    ${tag_cu_string}=  Run Keyword If  ${status_ext}
    ...  Catenate  SEPARATOR=;${SPACE}  ${tag_cu_string}  ${QC ${cu_alias} Active SW}
    Run Keyword If  ${status_ext}  Run Keywords
    ...  Set Test Variable  ${tag_cu_string}
    ...  AND  Set Qc Parameter  qc_tc_cubuild  ${tag_cu_string}
    ...  AND  Return From Keyword

    Set Test Variable  ${tag_cu_string}  ${QC ${cu_alias} Active SW}
    Set Qc Parameter  qc_tc_cubuild  ${tag_cu_string}

Get VDU SW Version
    [Documentation]
    ...  Get installed software version on CBTS VDUs.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description |
    ...  | alias     | Yes  | BTS alias   |
    ...
    [Arguments]  ${alias}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    ${VDU_SW_version_list}=  Create List

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        ${VDU_SW_version}=  VDU Get SW Version  vdu_connection=${vdu_alias}
        Set Test Variable  ${${alias}_VDU${index+1}_SW_version_initial}  ${VDU_SW_version}
        Set Test Variable  ${${alias}_VDU${index+1}_active_SW_version_initial}  ${VDU_SW_version}
        Log  ${vdu_alias} active SW: ${VDU_SW_version}  console=True

        Append To List  ${VDU_SW_version_list}  ${VDU_SW_version}

    END

    ${VDU_SW_version_list}=  Remove Duplicates  ${VDU_SW_version_list}

    ${status_ext}=  Run Keyword And Return Status  Variable Should Exist  ${tag_string}
    ${tag_string}=  Run Keyword If  ${status_ext}
    ...  Catenate  SEPARATOR=;${SPACE}  ${tag_string}  ${VDU_SW_version_list[0]}
    Run Keyword If  ${status_ext}  Run Keywords
    ...  Set Test Variable  ${tag_string}
    ...  AND  Set Qc Parameter  qc_tc_swbuild  ${tag_string}
    ...  AND  Return From Keyword

    Set Test Variable  ${tag_string}  ${VDU_SW_version_list[0]}
    Set Qc Parameter  qc_tc_swbuild  ${tag_string}

Snapshot And Alarms CBTS
    [Arguments]  ${alias}
    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${snapshot_and_alarms_dir}=  Set Variable  ${Test Results Dir}/Snapshot__${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}
    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${snapshot_and_alarms_dir}
    Run Keyword If  not ${status}  Create Directory  ${snapshot_and_alarms_dir}
    Log  Final snapshot and alarms location for ${alias}: ${snapshot_and_alarms_dir}  console=True

    Run Keyword And Continue On Failure  Get CU Active And Historical Alarms  folder_path=${snapshot_and_alarms_dir}  alias=${alias}

    Run Keyword And Continue On Failure  Get VDU Active And Historical Alarms  folder_path=${snapshot_and_alarms_dir}  alias=${alias}

    Run Keyword And Continue On Failure  Collect CU Snapshot  folder_path=${snapshot_and_alarms_dir}  alias=${alias}

    Run Keyword And Continue On Failure  Collect VDU Snapshot  folder_path=${snapshot_and_alarms_dir}  alias=${alias}

Get CU Active And Historical Alarms
    [Documentation]
    ...  Get CBTS CU active and historical alarms
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter   | Man. | Description                                                           |
    ...  | folder_path | Yes  | Folder path where CU active and historical alarms files will be saved |
    ...  | alias       | Yes  | BTS alias                                                             |
    ...
    [Arguments]  ${folder_path}  ${alias}

    ${CU_folder_path}=  Set Variable  ${folder_path}/CU
    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${CU_folder_path}
    Run Keyword If  not ${status}  Create Directory  ${CU_folder_path}

    ${cu_alias}=  Set Variable  ${alias} CU

    ${cu_active_alarm_info}=  cu.Get Active Alarms  connection=${cu_alias}
    ${cu_active_alarm_info_list}=  Get From Dictionary  ${cu_active_alarm_info}  alarms
    Write alarms list to file  ${cu_active_alarm_info_list}  ${CU_folder_path}/CU_active_alarm_file.txt

    ${cu_historical_alarm_info}=  cu.Get Historical Alarms  raw=True  connection=${cu_alias}
    ${cu_historical_alarm_info_list}=  Get From Dictionary  ${cu_historical_alarm_info}  alarms
    Write alarms list to file  ${cu_historical_alarm_info_list}  ${CU_folder_path}/CU_historical_alarm_file.txt

Get VDU Active And Historical Alarms
    [Documentation]
    ...  Get CBTS VDUs active and historical alarms
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter   | Man. | Description                                                             |
    ...  | folder_path | Yes  | Folder path where VDUs active and historical alarms files will be saved |
    ...  | alias       | Yes  | BTS alias                                                               |
    ...
    [Arguments]  ${folder_path}  ${alias}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${VDU_folder_path}=  Set Variable  ${folder_path}/VDU${index+1}
        ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${VDU_folder_path}
        Run Keyword If  not ${status}  Create Directory  ${VDU_folder_path}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        ${vdu_active_alarm_info}=  vdu.Vdu Get Active Alarms  vdu_connection=${vdu_alias}
        ${vdu_active_alarm_info_list}=  Get From Dictionary  ${vdu_active_alarm_info}  alarms
        Write alarms list to file  ${vdu_active_alarm_info_list}  ${VDU_folder_path}/VDU${index+1}_active_alarm_file.txt

        ${vdu_historical_alarm_info}=  vdu.Vdu Get Historical Alarms  raw=True  vdu_connection=${vdu_alias}
        ${vdu_historical_alarm_info_list}=  Get From Dictionary  ${vdu_historical_alarm_info}  alarms
        Write alarms list to file  ${vdu_historical_alarm_info_list}  ${VDU_folder_path}/VDU${index+1}_historical_alarm_file.txt

    END

Get CBTS CU and VDUs Current Plan Info
    [Documentation]
    ...  Get CBTS CU and VDUs current plan info (SCFs).
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter          | Man. | Description |
    ...  | alias              | Yes  | BTS alias   |
    ...
    [Arguments]  ${alias}

    ${cu_alias}=  Set Variable  ${alias} CU
    ${CU_folder_path}=  Set Variable  ${BTSFiles}/${alias}/CU
    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${CU_folder_path}
    Run Keyword If  not ${status}  Create Directory  ${CU_folder_path}

    ${CU_SCF_path_file_info}=  CU Get Current Plan File  path=${CU_folder_path}  connection=${cu_alias}
    Set Test Variable  ${${cu_alias.lower()}_scf_initial}  ${CU_SCF_path_file_info}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}
        ${VDU_folder_path}=  Set Variable  ${BTSFiles}/${alias}/VDU${index+1}
        ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${VDU_folder_path}
        Run Keyword If  not ${status}  Create Directory  ${VDU_folder_path}

        ${VDU_SCF_path_file_info}=  VDU Get Current Plan File  local_dir_path=${VDU_folder_path}  vdu_connection=${vdu_alias}
        Set Test Variable  ${${vdu_alias.lower()}_scf_initial}  ${VDU_SCF_path_file_info}

    END

Check CBTS Configuration
    [Documentation]
    ...  Check number of configured and runtime cells and radio modules from CBTS CU and VDUs are properly aligned.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter          | Man. | Description                                                                            |
    ...  | alias              | Yes  | BTS alias                                                                              |
    ...  | ${entity_scf_dict} | No   | Dict with BTS entity alias as key and BTS entity scf path as value;
    ...                                - for classical BTS, key refers to BTS entity (ex. 'Master')
    ...                                - for cloud BTS, key refers to BTS CU and VDUs entities (ex 'Master CU', 'Master VDU1' |
    ...
    ...  *RETURN*
    ...  | Parameter                            | Description                                                                                    |
    ...  | CBTS_configuration_and_runtime_check | ${True} if number of configured and runtime cells and RMODs from CBTS CU and VDUs are properly
    ...                                           aligned, otherwise ${False}                                                                    |
    ...
    [Arguments]  ${alias}  ${entity_scf_dict}=&{EMPTY}

    ${CBTS_configuration_and_runtime_check}=  Set Variable  ${True}

    ${cu_alias}=  Set Variable  ${alias} CU

    ${CU_configuration_and_runtime_check}=  CU Check Configuration And Runtime Info  cu_alias=${cu_alias}  entity_scf_dict=${entity_scf_dict}

    ${CBTS_configuration_and_runtime_check}=  Set Variable If  not ${CU_configuration_and_runtime_check}  ${False}
    ...  ${CBTS_configuration_and_runtime_check}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        ${VDU_configuration_and_runtime_check}=  VDU Check Configuration And Runtime Info  vdu_alias=${vdu_alias}  entity_scf_dict=${entity_scf_dict}

        ${CBTS_configuration_and_runtime_check}=  Set Variable If  not ${VDU_configuration_and_runtime_check}  ${False}
        ...  ${CBTS_configuration_and_runtime_check}

    END

    [Return]  ${CBTS_configuration_and_runtime_check}

CU Check Configuration And Runtime Info
    [Documentation]
    ...  Check number of configured and runtime cells from CBTS CU are properly aligned.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description                  |
    ...  | cu_alias  | Yes  | CU connection instance alias |
    ...
    ...  *RETURN*
    ...  | Parameter                          | Description                                                                          |
    ...  | CU_configuration_and_runtime_check | ${True} if number of configured and runtime cells from CBTS CU are properly aligned,
    ...                                         otherwise ${False}                                                                   |
    ...
    [Arguments]  ${cu_alias}  ${entity_scf_dict}=&{EMPTY}

    ${entity_scf_dict_keys}=  Run Keyword If  ${entity_scf_dict} != &{EMPTY}  Get Dictionary Keys  ${entity_scf_dict}
    ...  ELSE  Create List

    ${entity_scf}=  Run Keyword If  '${cu_alias}' in ${entity_scf_dict_keys}  Get From Dictionary  ${entity_scf_dict}  ${cu_alias}
    ...  ELSE  Set Variable  ${${cu_alias.lower()}_scf_initial}

    scf.Load Scf  ${entity_scf}
    ${CU_SCF_NR_cell_list}=  scf.Get All Dist Names By Pattern  pattern=/NRCELL-[\\d]+$
    ${CU_SCF_NR_cell_count}=  Get Length  ${CU_SCF_NR_cell_list}

    ${CU_RUNTIME_NR_cell_list}=  cu.Get Cells Statuses  connection=${cu_alias}
    ${CU_RUNTIME_NR_cell_count}=  Get Length  ${CU_RUNTIME_NR_cell_list}

    ${CU_NR_cell_conf}=  Run Keyword And Return Status   Should be equal  ${CU_SCF_NR_cell_count}  ${CU_RUNTIME_NR_cell_count}
    ${CU_configuration_and_runtime_check}=  Set Variable If  ${CU_NR_cell_conf}  ${True}  ${False}

    Log  ${cu_alias} NR configured/running cells number: ${CU_SCF_NR_cell_count}/${CU_RUNTIME_NR_cell_count}  console=True

    [Return]  ${CU_configuration_and_runtime_check}

VDU Check Configuration And Runtime Info
    [Documentation]
    ...  Check number of configured and runtime cells and radio modules from CBTS VDU are properly aligned.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description                   |
    ...  | vdu_alias | Yes  | VDU connection instance alias |
    ...
    ...  *RETURN*
    ...  | Parameter                           | Description                                                                                    |
    ...  | VDU_configuration_and_runtime_check | ${True} if number of configured and runtime cells and radio modules from CBTS VDU are properly
    ...                                          aligned, otherwise ${False}                                                                    |
    ...
    [Arguments]  ${vdu_alias}  ${entity_scf_dict}=&{EMPTY}

    ${entity_scf_dict_keys}=  Run Keyword If  ${entity_scf_dict} != &{EMPTY}  Get Dictionary Keys  ${entity_scf_dict}
    ...  ELSE  Create List

    ${entity_scf}=  Run Keyword If  '${vdu_alias}' in ${entity_scf_dict_keys}  Get From Dictionary  ${entity_scf_dict}  ${vdu_alias}
    ...  ELSE  Set Variable  ${${vdu_alias.lower()}_scf_initial}

    ${VDU_SCF_NR_cell_list}=  Get All Dist Names By Pattern from SCF  pattern=/NRCELL-[\\d]+$  scf_path=${entity_scf}  alias=${vdu_alias}
    ${VDU_SCF_NR_cell_count}=  Get Length  ${VDU_SCF_NR_cell_list}
    ${VDU_SCF_rmod_list}=  Get All Dist Names By Pattern from SCF  pattern=/RMOD-[\\d]+$  scf_path=${entity_scf}  alias=${vdu_alias}
    ${VDU_SCF_rmod_count}=  Get Length  ${VDU_SCF_rmod_list}

    ${VDU_RUNTIME_NR_cell_list}=  vdu.Get Vdu Cells Status  vdu_connection=${vdu_alias}
    ${VDU_RUNTIME_NR_cell_count}=  Get Length  ${VDU_RUNTIME_NR_cell_list}
    ${VDU_RUNTIME_rmod_list}=  vdu.Get Rmods Status  vdu_connection=${vdu_alias}
    ${VDU_RUNTIME_rmod_count}=  Get Length  ${VDU_RUNTIME_rmod_list}

    ${VDU_NR_cell_conf}=  Run Keyword And Return Status   Should be equal  ${VDU_SCF_NR_cell_count}  ${VDU_RUNTIME_NR_cell_count}
    ${VDU_rmod_conf}=  Run Keyword And Return Status   Should be equal  ${VDU_SCF_rmod_count}  ${VDU_RUNTIME_rmod_count}
    ${VDU_configuration_and_runtime_check}=  Set Variable If  ${VDU_NR_cell_conf} and ${VDU_rmod_conf}  ${True}  ${False}

    Log  ${vdu_alias} configured/running NR cells number: ${VDU_SCF_NR_cell_count}/${VDU_RUNTIME_NR_cell_count}  console=True
    Log  ${vdu_alias} configured/running RMs number: ${VDU_SCF_rmod_count}/${VDU_RUNTIME_rmod_count}  console=True

    [Return]  ${VDU_configuration_and_runtime_check}

Check CBTS Cells State
    [Documentation]
    ...  Check cells status from CBTS CU and VDUs.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter   | Man. | Description |
    ...  | alias       | Yes  | BTS alias   |
    ...
    ...  *RETURN*
    ...  | Parameter         | Description                                                                                          |
    ...  | CBTS_cells_status | ${True} if CBTS CU and VDUs cells status are: operational_state=Enabled, availability_status=Online,
    ...                        administrative_state=Unlocked, otherwise ${False}                                                    |
    ...
    [Arguments]  ${alias}

    ${CBTS_cells_status}=  Set Variable  ${True}

    ${cu_alias}=  Set Variable  ${alias} CU

    ${CU_CELL_status_check}=  CU Check Cells Expected Status  operational_state=${CBTS_Enabled_}  administrative_state=${CBTS_Unlocked_}
    ...  connection=${cu_alias}

    ${CBTS_cells_status}=  Set Variable If  not ${CU_CELL_status_check}  ${False}  ${CBTS_cells_status}

    Run Keyword If  ${CU_CELL_status_check}
        ...  Log  ${cu_alias} NR cells status: operational_state=Enabled, administrative_state=Unlocked  console=True
        ...  ELSE
        ...  Log  At least one ${cu_alias} NR cell status is not operational_state=Enabled, administrative_state=Unlocked!  console=True

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        ${VDU_CELL_status_check}=  VDU Check CELLs Expected Status  operational_state=${CBTS_Enabled_}  availability_status=${CBTS_Online_}
        ...  administrative_state=${CBTS_Unlocked_}  vdu_connection=${vdu_alias}

        ${CBTS_cells_status}=  Set Variable If  not ${VDU_CELL_status_check}  ${False}  ${CBTS_cells_status}

        Run Keyword If  ${VDU_CELL_status_check}
        ...  Log  ${vdu_alias} NR cells status: operational_state=Enabled, availability_status=Online, administrative_state=Unlocked  console=True
        ...  ELSE
        ...  Log Long String  At least one ${vdu_alias} NR cell status is not operational_state=Enabled, availability_status=Online,
        ...  administrative_state=Unlocked!  console=True

    END

    [Return]  ${CBTS_cells_status}

Check CBTS RMODs State
    [Documentation]
    ...  Check radio modules status from CBTS VDUs.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter   | Man. | Description |
    ...  | alias       | Yes  | BTS alias   |
    ...
    ...  *RETURN*
    ...  | Parameter      | Description                                                                                           |
    ...  | CBTS_RM_status | ${True} if CBTS VDUs radio modules status are: operational_state=Enabled, availability_status=Online,
    ...                     administrative_state=Unlocked, otherwise ${False}                                                     |
    ...
    [Arguments]  ${alias}

    ${CBTS_RM_status}=  Set Variable  ${True}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        ${VDU_RMOD_status_check}=  VDU Check RMODs Expected Status  operational_state=${CBTS_Enabled_}  availability_status=${CBTS_Online_}
        ...  administrative_state=${CBTS_Unlocked_}  vdu_connection=${vdu_alias}

        ${CBTS_RM_status}=  Set Variable If  not ${VDU_RMOD_status_check}  ${False}  ${CBTS_RM_status}

        Run Keyword If  ${VDU_RMOD_status_check}
        ...  Log  ${vdu_alias} RMs status: operational_state=Enabled, availability_status=Online, administrative_state=Unlocked  console=True
        ...  ELSE
        ...  Log  At least one ${vdu_alias} RM status is not operational_state=Enabled, availability_status=Online, administrative_state=Unlocked!
        ...  console=True

    END

    [Return]  ${CBTS_RM_status}

Check CBTS CU VDU Operational State
    [Documentation]
    ...  Check CBTS CU and VDUs operational state. KW is passed if CBTS CU operational_state=enabled and VDUs operational_state=onAir during
    ...  timeout period, otherwise it fails
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                                             |
    ...  | alias     | Yes  | BTS alias                                               |
    ...  | timeout   | No   | Timeout for the operation in seconds. Default value: 90 |
    ...
    [Arguments]  ${alias}  ${timeout}=90

     Wait until keyword succeeds  ${timeout}s  5s  Check CBTS Operational State  ${alias}

Check CBTS Operational State
    [Documentation]
    ...  Check CBTS CU and VDUs operational state. KW is passed if CBTS CU operational_state=enabled and VDUs operational_state=onAir, otherwise it
    ...  fails
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter   | Man. | Description |
    ...  | alias       | Yes  | BTS alias   |
    ...
    [Arguments]  ${alias}

    ${CBTS_check_operational_state}=  Set Variable  ${True}

    ${cu_alias}=  Set Variable  ${alias} CU

    ${CU_check_operational_state}=  CU Check Expected Operational State  operational_state=${CBTS_Enabled_}  connection=${cu_alias}

    ${CBTS_check_operational_state}=  Set Variable If  not ${CU_check_operational_state}  ${False}  ${CBTS_check_operational_state}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        ${VDU_check_operational_state}=  VDU Check Expected Operational State  operational_state=${CBTS_OnAir_}  vdu_connection=${vdu_alias}

        ${CBTS_check_operational_state}=  Set Variable If  not ${VDU_check_operational_state}  ${False}  ${CBTS_check_operational_state}

    END

    Should Be True  ${CBTS_check_operational_state}

Check BTS SCF Validation
    [Documentation]
    ...  KW for BTS SCF validation related to following info:
    ...  - NIDD_AND_RELATIONS: definition errors, relation errors and hardware errors
    ...  - DETECTED_HW: detected hardware errors
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter                       | Man. | Description                                                                                      |
    ...  | scf_path_file                   | No   | SCF file path. By default None: running BTS SCF will be get for validation check                 |
    ...  | skip_parameter_relation_errors  | No   | Skip parameter relation errors. By default ${True}                                               |
    ...  | export_type                     | No   | One of configuration, configurationAndRuntimeObjects or runtimeObjects. By default configuration |
    ...  | scf_validation_log_dir          | No   | Folder for stored SCF validation files. By default None: no need to store SCF validation files   |
    ...  | alias                           | No   | Alias of admin instance                                                                          |
    ...  | timeout                         | No   | Time to wait for positive procedure result                                                       |
    ...  | with_auto_configured_parameters | No   | Save also auto-configured parameters (CB013031). Possible values: ${TRUE} or ${FALSE}.           |
    ...  |                                          Default is ${TRUE}. If exportType is runtimeObjects, this parameter will be ignored              |
    ...
     ...  *RETURN*
    ...  | Parameter                 | Description                                                                                        |
    ...  | PreconditionSCFvalidation | ${True} if there are no errors on BTS SCF validation, otherwise ${False}                           |
    ...  | SCF_validation_result     | SCF validation result as:
    ...                                - dict containing structure: {'<error_type>': '<errors info>'} if KW 'Validate Scf Online' is PASS
    ...                                - error output if KW 'Validate Scf Online' is FAIL                                                 |
    ...
    [Arguments]  ${scf_path_file}=None  ${skip_parameter_relation_errors}=${True}  ${export_type}=configuration  ${scf_validation_log_dir}=None
    ...  ${alias}=None  ${timeout}=180  ${with_auto_configured_parameters}=${TRUE}

    ${SCF_validation_result}=  Create Dictionary
    ${scf_path_file_input}=  Set Variable  ${scf_path_file}

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${scf_file_name}=  Set Variable  SCF_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.xml
    ${validate_scf_nidd_rel_err_file}=  Set Variable  Validate_SCF_NIDD_RELATIONS_Errors_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.txt
    ${validate_scf_detect_hw_err_file}=  Set Variable  Validate_SCF_DETECTED_HW_Errors_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.txt
    ${definition_err_file}=  Set Variable  Definition_Errors_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.txt
    ${relation_err_file}=  Set Variable  Relation_Errors_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.txt
    ${hardware_err_file}=  Set Variable  Hardware_Errors_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.txt
    ${detect_hw_err_file}=  Set Variable  Detected_Hardware_Errors_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.txt
    ${USER_SCF_DEFINITION_ERROR_CHECK}=  Get Variable Value  ${USER_SCF_DEFINITION_ERROR_CHECK_${alias}}  ${TRUE}
    ${USER_SCF_RELATION_ERROR_CHECK}=  Get Variable Value  ${USER_SCF_RELATION_ERROR_CHECK_${alias}}  ${TRUE}
    ${USER_SCF_HW_ERROR_CHECK}=  Get Variable Value  ${USER_SCF_HW_ERROR_CHECK_${alias}}  ${TRUE}
    ${USER_SCF_DETECTED_HW_ERROR_CHECK}=  Get Variable Value  ${USER_SCF_DETECTED_HW_ERROR_CHECK_${alias}}  ${TRUE}

    ${scf_path_file}=  Run Keyword If  '${scf_path_file}' == 'None' and '${scf_validation_log_dir}' == 'None'
    ...  Set Variable  /tmp/${scf_file_name}
    ...  ELSE IF  '${scf_path_file}' == 'None' and '${scf_validation_log_dir}' != 'None'
    ...  Set Variable  ${scf_validation_log_dir}/${scf_file_name}
    ...  ELSE
    ...  Set Variable  ${scf_path_file}

    ${scf_path_folder}  ${scf_name}=  Split Path  ${scf_path_file}

    Run Keyword If  '${scf_path_file_input}' == 'None'
    ...  Get Current Scf File  local_dir_path=${scf_path_folder}  file_name=${scf_file_name}  timeout=60  connection=${alias}
    ...  export_type=${export_type}  with_auto_configured_parameters=${with_auto_configured_parameters}

    ${validate_scf_nidd_rel_status}  ${validate_scf_nidd_rel_info}=  Run Keyword And Ignore Error  Validate Scf Online  scf_file=${scf_path_file}
    ...  validation_type=NIDD_AND_RELATIONS  skip_parameter_relation_errors=${skip_parameter_relation_errors}  timeout=${timeout}  connection=${alias}
    Run Keyword If  '${validate_scf_nidd_rel_status}' == 'FAIL' and '${scf_validation_log_dir}' != 'None'
    ...  Append To File  ${scf_validation_log_dir}/${validate_scf_nidd_rel_err_file}  ${validate_scf_nidd_rel_info}
    Run Keyword If  '${validate_scf_nidd_rel_status}' == 'FAIL'  Run Keywords
    ...  Log  ${alias} BTS SCF validate operation failed: NIDD_AND_RELATIONS  console=True
    ...  AND  Return From Keyword  ${False}  ${validate_scf_nidd_rel_info}

    ${definitionErrorsSize}=  Run Keyword If
    ...  '${validate_scf_nidd_rel_info["requestMessage"]["niddValidationResult"]["logs"]["definitionErrors"]}' == 'None'
    ...  Set Variable  0
    ...  ELSE
    ...  Get Length  ${validate_scf_nidd_rel_info["requestMessage"]["niddValidationResult"]["logs"]["definitionErrors"]}
    Log  ${alias} BTS SCF definition errors count: ${definitionErrorsSize}  console=True
    ${def_err_evaluated}=  Evaluate  str(${validate_scf_nidd_rel_info["requestMessage"]["niddValidationResult"]})
    Set To Dictionary  ${SCF_validation_result}  definitionErrors  ${def_err_evaluated}
    Run Keyword If  '${scf_validation_log_dir}' != 'None'
    ...  Append To File  ${scf_validation_log_dir}/${definition_err_file}  ${def_err_evaluated}

    ${relationErrorsSize}=  Get Length  ${validate_scf_nidd_rel_info["requestMessage"]["pdlValidationResult"]["logs"]["relationErrors"]}
    Log  ${alias} BTS SCF relation errors count: ${relationErrorsSize}  console=True
    ${rel_err_evaluated}=  Evaluate  str(${validate_scf_nidd_rel_info["requestMessage"]["pdlValidationResult"]["logs"]["relationErrors"]})
    Set To Dictionary  ${SCF_validation_result}  relationErrors  ${rel_err_evaluated}
    Run Keyword If  '${scf_validation_log_dir}' != 'None'
    ...  Append To File  ${scf_validation_log_dir}/${relation_err_file}  ${rel_err_evaluated}

    ${hardwareErrorsSize}=  Get Length  ${validate_scf_nidd_rel_info["requestMessage"]["pdlValidationResult"]["logs"]["hardwareErrors"]}
    Log  ${alias} BTS SCF hardware errors count: ${hardwareErrorsSize}  console=True
    ${hard_err_evaluated}=  Evaluate  str(${validate_scf_nidd_rel_info["requestMessage"]["pdlValidationResult"]["logs"]["hardwareErrors"]})
    Set To Dictionary  ${SCF_validation_result}  hardwareErrors  ${hard_err_evaluated}
    Run Keyword If  '${scf_validation_log_dir}' != 'None'
    ...  Append To File  ${scf_validation_log_dir}/${hardware_err_file}  ${hard_err_evaluated}

    ${validate_scf_detect_hw_status}  ${validate_scf_detect_hw_info}=  Run Keyword And Ignore Error  Validate Scf Online  scf_file=${scf_path_file}
    ...  validation_type=DETECTED_HW  skip_parameter_relation_errors=${skip_parameter_relation_errors}  timeout=${timeout}  connection=${alias}
    Run Keyword If  '${validate_scf_detect_hw_status}' == 'FAIL' and '${scf_validation_log_dir}' != 'None'
    ...  Append To File  ${scf_validation_log_dir}/${validate_scf_detect_hw_err_file}  ${validate_scf_detect_hw_info}
    Run Keyword If  '${validate_scf_detect_hw_status}' == 'FAIL'  Run Keywords
    ...  Log  ${alias} BTS SCF validate operation failed: DETECTED_HW  console=True
    ...  AND  Return From Keyword  ${False}  ${validate_scf_detect_hw_info}

    ${detectedHwErrorsSize}=  Get Length  ${validate_scf_detect_hw_info["requestMessage"]["detectedHwValidationResult"]["logs"]}
    Log  ${alias} BTS SCF detected hardware errors count: ${detectedHwErrorsSize}  console=True
    ${detectedHw_err_evaluated}=  Evaluate  str(${validate_scf_detect_hw_info["requestMessage"]["detectedHwValidationResult"]})
    Set To Dictionary  ${SCF_validation_result}  detectedHwErrors  ${detectedHw_err_evaluated}
    Run Keyword If  '${scf_validation_log_dir}' != 'None'
    ...  Append To File  ${scf_validation_log_dir}/${detect_hw_err_file}  ${detectedHw_err_evaluated}

    ${definitionErrorsSize}=  Run Keyword If  '${USER_SCF_DEFINITION_ERROR_CHECK}' == '${FALSE}'
    ...  Set Variable  0
    ...  ELSE  Set Variable  ${definitionErrorsSize}
    Run Keyword If  '${USER_SCF_DEFINITION_ERROR_CHECK}' == '${FALSE}'
    ...  Log  ${alias} BTS SCF Definition Errors skipped by user  console=True
    ${relationErrorsSize}=  Run Keyword If  '${USER_SCF_RELATION_ERROR_CHECK}' == '${FALSE}'
    ...  Set Variable  0
    ...  ELSE  Set Variable  ${relationErrorsSize}
    Run Keyword If  '${USER_SCF_RELATION_ERROR_CHECK}' == '${FALSE}'
    ...  Log  ${alias} BTS SCF Relation Errors skipped by user  console=True
    ${hardwareErrorsSize}=  Run Keyword If  '${USER_SCF_HW_ERROR_CHECK}' == '${FALSE}'
    ...  Set Variable  0
    ...  ELSE  Set Variable  ${hardwareErrorsSize}
    Run Keyword If  '${USER_SCF_HW_ERROR_CHECK}' == '${FALSE}'
    ...  Log  ${alias} BTS SCF Hardware Errors skipped by user  console=True
    ${detectedHwErrorsSize}=  Run Keyword If  '${USER_SCF_DETECTED_HW_ERROR_CHECK}' == '${FALSE}'
    ...  Set Variable  0
    ...  ELSE  Set Variable  ${detectedHwErrorsSize}
    Run Keyword If  '${USER_SCF_DETECTED_HW_ERROR_CHECK}' == '${FALSE}'
    ...  Log  ${alias} BTS SCF Detected Hardaware Errors skipped by user  console=True

    ${cond}=  Create Long String  ${definitionErrorsSize} == 0 and ${relationErrorsSize} == 0 and ${hardwareErrorsSize} == 0 and
    ...  ${detectedHwErrorsSize} == 0

    ${PreconditionSCFvalidation}=  Set Variable If  ${cond}  ${True}  ${False}

    [Return]  ${PreconditionSCFvalidation}  ${SCF_validation_result}

Check BTS SCF Validation On Demand
    [Documentation]  KW for BTS SCF validation
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter                    | Man.  | Description                                               |
    ...  | alias                        | Yes   | BTS alias                                                 |
    ...
    [Arguments]  ${alias}

    ${PreconditionSCFvalidation}  ${SCF_validation_result}=  Check BTS SCF Validation  scf_validation_log_dir=${BTSFiles}/${alias}/SCF_Validation
    ...  alias=${alias}
    Run Keyword If  '${PreconditionSCFvalidation}' == '${False}'  Run Keywords
    ...  Log  ${alias} BTS SCF validation operation failed, please check related files from ${BTSFiles}/${alias}/SCF_Validation  level=ERROR
    ...  AND  Fail  ${alias} BTS SCF validation operation failed
    ...  ELSE  Log  ${alias} BTS SCF validation operation passed  console=True

Get and Check Alarms CBTS
    [Documentation]
    ...  KW used to get and check alarms for CBTS CU and VDU based on the supplied alias. It fails if any of below exception case is
    ...  present:
    ...  - critical alarms are present
    ...  - unexpected alarms are present
    ...  Report errors/warnings for failed cases or report that alarm status is ok.
    ...  KW aplicable for CBTS architecture
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter   | Man. | Description |
    ...  | alias       | Yes  | BTS alias   |
    ...
    [Arguments]  ${alias}

    ${cu_alias}=  Set Variable  ${alias} CU

    Get and Check Alarms CBTS CU  cu_alias=${cu_alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${test_alarms_list['${alias.upper()}_CU_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CU_CRITICAL_ALARMS']}

    Log  ${cu_alias} site - expected, ignored and critical alarms checked  console=True

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        Get and Check Alarms CBTS VDU  vdu_alias=${vdu_alias}  expected_alarms=@{EMPTY}
        ...  ignored_alarms=${test_alarms_list['${alias.upper()}_VDU${index+1}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_VDU${index+1}_CRITICAL_ALARMS']}

        Log  ${vdu_alias} site - expected, ignored and critical alarms checked  console=True

    END

Get and Check Alarms CBTS CU
    [Documentation]
    ...  KW used to get and check alarms for CBTS CU based on the supplied alias. It fails if any of below exception case is present:
    ...  - not all expected alarms are present
    ...  - critical alarms are present
    ...  - unexpected alarms are present
    ...  Report errors/warnings for failed cases or report that alarm status is ok.
    ...  KW aplicable for CBTS architecture
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                                 |
    ...  | cu_alias             | Yes  | CU connection instance alias                                |
    ...  | time                 | No   | Time to wait for expected CU alarms                         |
    ...  | poll_interval        | No   | Poll interval of alarms queries                             |
    ...  | wait_for_alarm_clear | No   | Time to wait for unexpected alarms to be cleared on CU      |
    ...  | expected_alarms      | No   | CU expected alarms. Error raised if any of these is missing |
    ...  | ignored_alarms       | No   | CU ignored alarms                                           |
    ...  | critical_alarms      | No   | CU critical alarms. Error raised if any of these is found   |
    ...  | timeout              | No   | Time to wait for possitive query result                     |
    ...
    [Arguments]  ${cu_alias}  ${time}=5 min  ${poll_interval}=30 sec  ${wait_for_alarm_clear}=5 min  ${expected_alarms}=@{EMPTY}
    ...  ${ignored_alarms}=@{EMPTY}  ${critical_alarms}=@{EMPTY}  ${timeout}=30 sec

    Set Test Variable  ${detected_critical_alarms}  ${FALSE}

    Run Keyword And Return Status  Wait Until Keyword Succeeds  ${time}  ${poll_interval}
    ...  Eval Current Alarms CBTS CU  cu_alias=${cu_alias}  expected_alarms=${expected_alarms}  ignored_alarms=${ignored_alarms}
    ...  critical_alarms=${critical_alarms}  timeout=${timeout}

    Run Keyword If  ${found_unexpected_alarms}  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${wait_for_alarm_clear}  ${poll_interval}
    ...  Eval Unexpected Alarms CBTS CU  cu_alias=${cu_alias}  expected_alarms=${expected_alarms}  ignored_alarms=${ignored_alarms}
    ...  critical_alarms=${critical_alarms}  wait_for_alarm_clear=${wait_for_alarm_clear}  timeout=${timeout}

    Run Keyword If  ${detected_critical_alarms}  Run Keywords
    ...  Log  Critical alarms present:  level=ERROR
    ...  AND  alarms_analysis.Print Alarms  critical_alarms=${detected_critical_alarms}  simplified_dictionary=${CBTS_CU_SIMPLIFIED_ALARM}
    ...  ELSE IF  ${not_found_expected_alarms}  Run Keywords
    ...  Log  Missing expected alarms:  level=ERROR
    ...  AND  alarms_analysis.Print Alarms  missing_alarms_patterns=${not_found_expected_alarms}  simplified_dictionary=${CBTS_CU_SIMPLIFIED_ALARM}
    ...  ELSE IF  ${found_unexpected_alarms}  Run Keywords
    ...  Set Alarm Check Level Based on Execution Environment   wait_for_alarm_clear=${wait_for_alarm_clear}
    ...  found_unexpected_alarms=${found_unexpected_alarms}
    ...  AND  Log  Unexpected alarms present AFTER alarm clear interval of ${wait_for_alarm_clear}:  level=${ALARMS_LEVEL}
    ...  AND  alarms_analysis.Print Alarms  warnings=${found_unexpected_alarms}  simplified_dictionary=${CBTS_CU_SIMPLIFIED_ALARM}
    ...  AND  Log  Snapshot will be triggered at the end of test  console=True
    ...  AND  Set Test Variable  ${SnapshotTriggerEndTest}  YES
    ...  ELSE
    ...  Log  Alarm status is OK.  level=INFO  console=True

    Run Keyword If  ${detected_critical_alarms} or ${not_found_expected_alarms}
    ...  Fail  Critical alarms present and/or missing expected alarms!

Eval Current Alarms CBTS CU
    [Documentation]
    ...  KW used to get and check critical or expected alarms for CBTS CU. It fails if any of below exception case is present:
    ...  - critical alarms are present
    ...  - not all expected alarms are present
    ...  KW aplicable for CBTS architecture
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                                 |
    ...  | cu_alias             | Yes  | CU connection instance alias                                |
    ...  | expected_alarms      | No   | CU expected alarms. Error raised if any of these is missing |
    ...  | ignored_alarms       | No   | CU ignored alarms                                           |
    ...  | critical_alarms      | No   | CU critical alarms. Error raised if any of these is found   |
    ...  | timeout              | No   | Time to wait for possitive query result                     |
    ...
    [Arguments]  ${cu_alias}  ${expected_alarms}=@{EMPTY}  ${ignored_alarms}=@{EMPTY}  ${critical_alarms}=@{EMPTY}  ${timeout}=30 sec

    ${active_alarms_dict}=  cu.Get Active Alarms  connection=${cu_alias}  timeout=${timeout}
    ${active_alarms}=  Get From Dictionary  ${active_alarms_dict}  alarms
    ${found_expected_alarms}  ${not_found_expected_alarms}  ${found_critical_alarms}  ${found_ignored_alarms}  ${found_unexpected_alarms}=
    ...  alarms_analysis.Get Filtered Alarms  ${active_alarms}  ${expected_alarms}  ${ignored_alarms}  ${critical_alarms}
    ...  ${CBTS_CU_SIMPLIFIED_ALARM}

    Set Test Variable  ${found_critical_alarms}  ${found_critical_alarms}
    Set Test Variable  ${not_found_expected_alarms}  ${not_found_expected_alarms}
    Set Test Variable  ${found_unexpected_alarms}  ${found_unexpected_alarms}

    Run Keyword If  ${found_critical_alarms}  Run Keywords
    ...  Log  Critical alarms present:  level=ERROR
    ...  AND  alarms_analysis.Print Alarms  critical_alarms=${found_critical_alarms}  simplified_dictionary=${CBTS_CU_SIMPLIFIED_ALARM}
    ...  AND  Set Test Variable  ${detected_critical_alarms}  ${found_critical_alarms}

    Run Keyword If  ${found_critical_alarms}
    ...  Fail  Critical alarms present. Attempting a new check..
    ...  ELSE IF  ${not_found_expected_alarms}
    ...  Fail  Missing expected alarms. Attempting a new check..

Eval Unexpected Alarms CBTS CU
    [Documentation]
    ...  KW used to get and check critical or expected alarms for CBTS CU. It fails if any of below exception case is present:
    ...  - critical alarms are present
    ...  - not all expected alarms are present
    ...  KW aplicable for CBTS architecture
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                                 |
    ...  | cu_alias             | Yes  | CU connection instance alias                                |
    ...  | expected_alarms      | No   | CU expected alarms. Error raised if any of these is missing |
    ...  | ignored_alarms       | No   | CU ignored alarms                                           |
    ...  | critical_alarms      | No   | CU critical alarms. Error raised if any of these is found   |
    ...  | wait_for_alarm_clear | No   | Time to wait for unexpected alarms to be cleared on CU      |
    ...  | timeout              | No   | Time to wait for possitive query result                     |
    ...
    [Arguments]  ${cu_alias}  ${expected_alarms}=@{EMPTY}  ${ignored_alarms}=@{EMPTY}  ${critical_alarms}=@{EMPTY}  ${wait_for_alarm_clear}=5 min
    ...  ${timeout}=30 sec

    ${active_alarms_dict}=  cu.Get Active Alarms  connection=${cu_alias}  timeout=${timeout}
    ${active_alarms}=  Get From Dictionary  ${active_alarms_dict}  alarms
    ${found_expected_alarms}  ${not_found_expected_alarms}  ${found_critical_alarms}  ${found_ignored_alarms}  ${found_unexpected_alarms}=
    ...  alarms_analysis.Get Filtered Alarms  ${active_alarms}  ${expected_alarms}  ${ignored_alarms}  ${critical_alarms}
    ...  simplified_dictionary=${CBTS_CU_SIMPLIFIED_ALARM}

    Set Test Variable  ${found_critical_alarms}  ${found_critical_alarms}
    Set Test Variable  ${found_unexpected_alarms}  ${found_unexpected_alarms}

    Run Keyword If  ${found_critical_alarms}  Run Keywords
    ...  Log  Critical alarms present:  level=ERROR
    ...  AND  alarms_analysis.Print Alarms  critical_alarms=${found_critical_alarms}  simplified_dictionary=${CBTS_CU_SIMPLIFIED_ALARM}
    ...  AND  Set Test Variable  ${detected_critical_alarms}  ${found_critical_alarms}

    Run Keyword If  ${found_unexpected_alarms}  Run Keywords
    ...  Log  Unexpected alarms present DURING alarm clear interval of ${wait_for_alarm_clear}:  level=WARN
    ...  AND  alarms_analysis.Print Alarms  warnings=${found_unexpected_alarms}  simplified_dictionary=${CBTS_CU_SIMPLIFIED_ALARM}

    Run Keyword If  ${found_critical_alarms}
    ...  Fail  Critical alarms present. Attempting a new check..
    ...  ELSE IF  ${found_unexpected_alarms}
    ...  Fail  Unexpected alarms present. Attempting a new check..

Get and Check Alarms CBTS VDU
    [Documentation]
    ...  KW used to get and check alarms for CBTS VDU based on the supplied alias. It fails if any of below exception case is present:
    ...  - not all expected alarms are present
    ...  - critical alarms are present
    ...  - unexpected alarms are present
    ...  Report errors/warnings for failed cases or report that alarm status is ok.
    ...  KW aplicable for CBTS architecture
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                                  |
    ...  | vdu_alias            | Yes  | VDU connection instance alias                                |
    ...  | time                 | No   | Time to wait for expected VDU alarms                         |
    ...  | poll_interval        | No   | Poll interval of alarms queries                              |
    ...  | wait_for_alarm_clear | No   | Time to wait for unexpected alarms to be cleared on VDU      |
    ...  | expected_alarms      | No   | VDU expected alarms. Error raised if any of these is missing |
    ...  | ignored_alarms       | No   | VDU ignored alarms                                           |
    ...  | critical_alarms      | No   | VDU critical alarms. Error raised if any of these is found   |
    ...  | timeout              | No   | Time to wait for possitive query result                      |
    ...
    [Arguments]  ${vdu_alias}  ${time}=5 min  ${poll_interval}=30 sec  ${wait_for_alarm_clear}=5 min  ${expected_alarms}=@{EMPTY}
    ...  ${ignored_alarms}=@{EMPTY}  ${critical_alarms}=@{EMPTY}  ${timeout}=30 sec

    Set Test Variable  ${detected_critical_alarms}  ${FALSE}

    Run Keyword And Return Status  Wait Until Keyword Succeeds  ${time}  ${poll_interval}
    ...  Eval Current Alarms CBTS VDU  vdu_alias=${vdu_alias}  expected_alarms=${expected_alarms}  ignored_alarms=${ignored_alarms}
    ...  critical_alarms=${critical_alarms}  timeout=${timeout}

    Run Keyword If  ${found_unexpected_alarms}  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${wait_for_alarm_clear}  ${poll_interval}
    ...  Eval Unexpected Alarms CBTS VDU  vdu_alias=${vdu_alias}  expected_alarms=${expected_alarms}  ignored_alarms=${ignored_alarms}
    ...  critical_alarms=${critical_alarms}  wait_for_alarm_clear=${wait_for_alarm_clear}  timeout=${timeout}

    Run Keyword If  ${detected_critical_alarms}  Run Keywords
    ...  Log  Critical alarms present:  level=ERROR
    ...  AND  alarms_analysis.Print Alarms  critical_alarms=${detected_critical_alarms}  simplified_dictionary=${CBTS_VDU_SIMPLIFIED_ALARM}
    ...  ELSE IF  ${not_found_expected_alarms}  Run Keywords
    ...  Log  Missing expected alarms:  level=ERROR
    ...  AND  alarms_analysis.Print Alarms  missing_alarms_patterns=${not_found_expected_alarms}  simplified_dictionary=${CBTS_VDU_SIMPLIFIED_ALARM}
    ...  ELSE IF  ${found_unexpected_alarms}  Run Keywords
    ...  Set Alarm Check Level Based on Execution Environment  wait_for_alarm_clear=${wait_for_alarm_clear}
    ...  found_unexpected_alarms=${found_unexpected_alarms}
    ...  AND  Log  Unexpected alarms present AFTER alarm clear interval of ${wait_for_alarm_clear}:  level=${ALARMS_LEVEL}
    ...  AND  alarms_analysis.Print Alarms  warnings=${found_unexpected_alarms}  simplified_dictionary=${CBTS_VDU_SIMPLIFIED_ALARM}
    ...  AND  Log  Snapshot will be triggered at the end of test  console=True
    ...  AND  Set Test Variable  ${SnapshotTriggerEndTest}  YES
    ...  ELSE
    ...  Log  Alarm status is OK.  level=INFO  console=True

    Run Keyword If  ${detected_critical_alarms} or ${not_found_expected_alarms}
    ...  Fail  Critical alarms present and/or missing expected alarms!

Eval Current Alarms CBTS VDU
    [Documentation]
    ...  KW used to get and check critical or expected alarms for CBTS CU. It fails if any of below exception case is present:
    ...  - critical alarms are present
    ...  - not all expected alarms are present
    ...  KW aplicable for CBTS architecture
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                                  |
    ...  | vdu_alias            | Yes  | VDU connection instance alias                                |
    ...  | expected_alarms      | No   | VDU expected alarms. Error raised if any of these is missing |
    ...  | ignored_alarms       | No   | VDU ignored alarms                                           |
    ...  | critical_alarms      | No   | VDU critical alarms. Error raised if any of these is found   |
    ...  | timeout              | No   | Time to wait for possitive query result                      |
    ...
    [Arguments]  ${vdu_alias}  ${expected_alarms}=@{EMPTY}  ${ignored_alarms}=@{EMPTY}  ${critical_alarms}=@{EMPTY}  ${timeout}=30 sec

    ${active_alarms_dict}=  vdu.Vdu Get Active Alarms  vdu_connection=${vdu_alias}  timeout=${timeout}  paging=${False}
    ${active_alarms}=  Get From Dictionary  ${active_alarms_dict}  alarms
    ${found_expected_alarms}  ${not_found_expected_alarms}  ${found_critical_alarms}  ${found_ignored_alarms}  ${found_unexpected_alarms}=
    ...  alarms_analysis.Get Filtered Alarms  ${active_alarms}  ${expected_alarms}  ${ignored_alarms}  ${critical_alarms}
    ...  ${CBTS_VDU_SIMPLIFIED_ALARM}

    Set Test Variable  ${found_critical_alarms}  ${found_critical_alarms}
    Set Test Variable  ${not_found_expected_alarms}  ${not_found_expected_alarms}
    Set Test Variable  ${found_unexpected_alarms}  ${found_unexpected_alarms}

    Run Keyword If  ${found_critical_alarms}  Run Keywords
    ...  Log  Critical alarms present:  level=ERROR
    ...  AND  alarms_analysis.Print Alarms  critical_alarms=${found_critical_alarms}  simplified_dictionary=${CBTS_VDU_SIMPLIFIED_ALARM}
    ...  AND  Set Test Variable  ${detected_critical_alarms}  ${found_critical_alarms}

    Run Keyword If  ${found_critical_alarms}
    ...  Fail  Critical alarms present. Attempting a new check..
    ...  ELSE IF  ${not_found_expected_alarms}
    ...  Fail  Missing expected alarms. Attempting a new check..

Eval Unexpected Alarms CBTS VDU
    [Documentation]
    ...  KW used to get and check critical or unexpected alarms for CBTS VDU. It fails if any of below exception case is present:
    ...  - critical alarms are present
    ...  - not all expected alarms are present
    ...  KW aplicable for CBTS architecture
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                                  |
    ...  | vdu_alias            | Yes  | VDU connection instance alias                                |
    ...  | expected_alarms      | No   | VDU expected alarms. Error raised if any of these is missing |
    ...  | ignored_alarms       | No   | VDU ignored alarms                                           |
    ...  | critical_alarms      | No   | VDU critical alarms. Error raised if any of these is found   |
    ...  | wait_for_alarm_clear | No   | Time to wait for unexpected alarms to be cleared on VDU      |
    ...  | timeout              | No   | Time to wait for possitive query result                      |
    ...
    [Arguments]  ${vdu_alias}  ${expected_alarms}=@{EMPTY}  ${ignored_alarms}=@{EMPTY}  ${critical_alarms}=@{EMPTY}  ${wait_for_alarm_clear}=5 min
    ...  ${timeout}=30 sec

    ${active_alarms_dict}=  vdu.Vdu Get Active Alarms  vdu_connection=${vdu_alias}  timeout=${timeout}
    ${active_alarms}=  Get From Dictionary  ${active_alarms_dict}  alarms
    ${found_expected_alarms}  ${not_found_expected_alarms}  ${found_critical_alarms}  ${found_ignored_alarms}  ${found_unexpected_alarms}=
    ...  alarms_analysis.Get Filtered Alarms  ${active_alarms}  ${expected_alarms}  ${ignored_alarms}  ${critical_alarms}
    ...  simplified_dictionary=${CBTS_VDU_SIMPLIFIED_ALARM}

    Set Test Variable  ${found_critical_alarms}
    Set Test Variable  ${found_unexpected_alarms}

    Run Keyword If  ${found_critical_alarms}  Run Keywords
    ...  Log  Critical alarms present:  level=ERROR
    ...  AND  alarms_analysis.Print Alarms  critical_alarms=${found_critical_alarms}  simplified_dictionary=${CBTS_VDU_SIMPLIFIED_ALARM}
    ...  AND  Set Test Variable  ${detected_critical_alarms}  ${found_critical_alarms}

    Run Keyword If  ${found_unexpected_alarms}  Run Keywords
    ...  Log  Unexpected alarms present DURING alarm clear interval of ${wait_for_alarm_clear}:  level=WARN
    ...  AND  alarms_analysis.Print Alarms  warnings=${found_unexpected_alarms}  simplified_dictionary=${CBTS_VDU_SIMPLIFIED_ALARM}

    Run Keyword If  ${found_critical_alarms}
    ...  Fail  Critical alarms present. Attempting a new check..
    ...  ELSE IF  ${found_unexpected_alarms}
    ...  Fail  Unexpected alarms present. Attempting a new check..

Check if CBTS VDU cells are unblocked
    [Documentation]
    ...  KW used to check CBTS VDU cells are unblocked
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description |
    ...  | alias     | Yes  | BTS alias   |
    ...
    [Arguments]  ${alias}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        ${VDU_CELL_id_config_dn_dict}=  VDU Get Cells id config info  vdu_connection=${vdu_alias}
        ${VDU_CELL_ids_list}=  Get Dictionary Keys  ${VDU_CELL_id_config_dn_dict}
        VDU Recover VDU blocked cells  VDU_cell_ids_list=${VDU_CELL_ids_list}  vdu_connection=${vdu_alias}

    END

Check if CBTS VDU RMODs are unlocked
    [Documentation]
    ...  KW used to check CBTS VDU RMODs are unlocked
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description |
    ...  | alias     | Yes  | BTS alias   |
    ...
    [Arguments]  ${alias}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        ${VDU_RMOD_sn_id_dict}  ${VDU_RMOD_id_sn_dict}  ${VDU_RMOD_sn_pn_dict}  ${VDU_RMOD_sn_interface_dict}=  VDU Get RMOD sn id pn interface info
        ...  vdu_connection=${vdu_alias}
        ${VDU_RMOD_ids_list}=  Get Dictionary Keys  ${VDU_RMOD_id_sn_dict}
        VDU Recover VDU locked RMODs  VDU_rmod_ids_list=${VDU_RMOD_ids_list}  vdu_connection=${vdu_alias}

    END

Get RMOD synchronisation info on all BTS
    [Documentation]
    ...  Get RMOD synchronisation info on all BTS. KW returns RMOD synchronisation info on all BTS as a dictionary:
    ...  - key: BTS alias
    ...  - value: info containing RMOD serial number for each RMOD interface protocol
    ...

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${shared_RMOD_sn_list}
    Set Test Variable  ${dedicated_RMOD_sn_list}

    ${BTS_synchronisation_RMOD_info_dict}=  Create Dictionary

    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_RMOD_sn_dict}

    ${CPRI_shared_RMOD_sn_SYNC_BTS_alias_dict}  ${CPRI_shared_RMOD_sn_NON_SYNC_BTS_alias_dict}  ${ECPRI_shared_RMOD_sn_SYNC_BTS_alias_dict}
    ...  ${ECPRI_shared_RMOD_sn_NON_SYNC_BTS_alias_dict}  ${dedicated_RMOD_sn_SYNC_BTS_alias_dict}=  Get all BTS RMOD synchronisation info
    ...  ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${CPRI_shared_RMOD_sn_SYNC_BTS_alias_dict}
    Set Test Variable  ${CPRI_shared_RMOD_sn_NON_SYNC_BTS_alias_dict}
    Set Test Variable  ${ECPRI_shared_RMOD_sn_SYNC_BTS_alias_dict}
    Set Test Variable  ${ECPRI_shared_RMOD_sn_NON_SYNC_BTS_alias_dict}
    Set Test Variable  ${dedicated_RMOD_sn_SYNC_BTS_alias_dict}

Get all BTS RMOD sharing info
    [Documentation]
    ...  Helper KW providing radio modules info related to sharing status as:
    ...  - dictionary containing structure: {'BTS_alias': '<RMOD_serial_number_list>'}
    ...  - dictionary containing structure: {'RMOD_serial_number': '<BTS_alias_list>'}
    ...  - list of shared RMOD serial number
    ...  - list of dedicated RMOD serial number
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter              | Description                    |
    ...  | BTS_alias_RMOD_sn_dict | Dict of BTS alias RMOD sn info |
    ...  | RMOD_sn_BTS_alias_dict | Dict of RMOD sn BTS alias info |
    ...  | shared_RMOD_sn_list    | List of shared RMOD sn info    |
    ...  | dedicated_RMOD_sn_list | List of dedicated RMOD sn info |

    ${RMOD_all_sn_list}=  Create List
    ${BTS_alias_RMOD_sn_dict}=  Create Dictionary
    ${RMOD_sn_BTS_alias_dict}=  Create Dictionary
    ${shared_RMOD_sn_list}=  Create List
    ${dedicated_RMOD_sn_list}=  Create List

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_list}=  Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'
        ...  Get cloud BTS RMOD serial number list  ${BTS_alias_RMOD_sn_dict}  ${alias}
        ...  ELSE IF  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']
        ...  Get classical BTS RMOD serial number list  ${BTS_alias_RMOD_sn_dict}  ${alias}

        Sort List  ${RMOD_sn_list}
        Append To List  ${RMOD_all_sn_list}  @{RMOD_sn_list}

    END

    ${RMOD_all_sn_list}=  Remove Duplicates  ${RMOD_all_sn_list}
    Sort List  ${RMOD_all_sn_list}

    FOR  ${RMOD_sn}  IN  @{RMOD_all_sn_list}

        ${RMOD_BTS_alias_list}=  Get RMOD BTS alias info list  ${RMOD_sn}  ${BTS_alias_RMOD_sn_dict}
        Sort List  ${RMOD_BTS_alias_list}
        Set To Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}  ${RMOD_BTS_alias_list}

        ${RMOD_BTS_alias_count}=  Get Length  ${RMOD_BTS_alias_list}
        Run Keyword If  ${RMOD_BTS_alias_count} == 1
        ...  Append To List  ${dedicated_RMOD_sn_list}  ${RMOD_sn}
        ...  ELSE IF  ${RMOD_BTS_alias_count} > 1
        ...  Append To List  ${shared_RMOD_sn_list}  ${RMOD_sn}

    END

    [Return]  ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}

Get cloud BTS RMOD serial number list
    [Arguments]  ${BTS_alias_RMOD_sn_dict}  ${alias}

    ${BTS_RMOD_sn_list}=  Create List

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        ${VDU_RMOD_sn_id_dict}  ${VDU_RMOD_id_sn_dict}  ${VDU_RMOD_sn_pn_dict}  ${VDU_RMOD_sn_interface_dict}=  VDU Get RMOD sn id pn interface info
        ...  vdu_connection=${vdu_alias}
        ${VDU_RMOD_sn_list}=  Get Dictionary Keys  ${VDU_RMOD_sn_id_dict}
        Set To Dictionary  ${BTS_alias_RMOD_sn_dict}  ${vdu_alias}  ${VDU_RMOD_sn_list}
        Append To List  ${BTS_RMOD_sn_list}  @{VDU_RMOD_sn_list}

        Set Test Variable  ${${vdu_alias}_RMOD_sn_list}  ${VDU_RMOD_sn_list}
        Set Test Variable  ${${vdu_alias}_RMOD_sn_id_dict}  ${VDU_RMOD_sn_id_dict}
        Set Test Variable  ${${vdu_alias}_RMOD_id_sn_dict}  ${VDU_RMOD_id_sn_dict}
        Set Test Variable  ${${vdu_alias}_RMOD_sn_pn_dict}  ${VDU_RMOD_sn_pn_dict}
        Set Test Variable  ${${vdu_alias}_RMOD_sn_interface_dict}  ${VDU_RMOD_sn_interface_dict}

    END

    ${BTS_RMOD_sn_list}=  Remove Duplicates  ${BTS_RMOD_sn_list}
    Sort List  ${BTS_RMOD_sn_list}

    [Return]  ${BTS_alias_RMOD_sn_dict}  ${BTS_RMOD_sn_list}

Get classical BTS RMOD serial number list
    [Arguments]  ${BTS_alias_RMOD_sn_dict}  ${alias}

    ${BTS_RMOD_sn_id_dict}  ${BTS_RMOD_id_sn_dict}  ${BTS_RMOD_sn_pn_dict}  ${BTS_RMOD_sn_interface_dict}=  Admin Get RMOD sn id pn interface info
    ...  alias=${alias}
    ${BTS_RMOD_sn_list}=  Get Dictionary Keys  ${BTS_RMOD_sn_id_dict}
    Set To Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}  ${BTS_RMOD_sn_list}

    Set Test Variable  ${${alias}_RMOD_sn_list}  ${BTS_RMOD_sn_list}
    Set Test Variable  ${${alias}_RMOD_sn_id_dict}  ${BTS_RMOD_sn_id_dict}
    Set Test Variable  ${${alias}_RMOD_id_sn_dict}  ${BTS_RMOD_id_sn_dict}
    Set Test Variable  ${${alias}_RMOD_sn_pn_dict}  ${BTS_RMOD_sn_pn_dict}
    Set Test Variable  ${${alias}_RMOD_sn_interface_dict}  ${BTS_RMOD_sn_interface_dict}

    [Return]  ${BTS_alias_RMOD_sn_dict}  ${BTS_RMOD_sn_list}

Get RMOD BTS alias info list
    [Arguments]  ${RMOD_sn}  ${BTS_alias_RMOD_sn_dict}

    ${RMOD_BTS_alias_list}=  Create List
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_RMOD_sn_dict}  False

    FOR  ${alias}  IN  @{BTS_alias_list}

        ${RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}
        Run Keyword If  '${RMOD_sn}' in ${RMOD_sn_list}
        ...  Append To List  ${RMOD_BTS_alias_list}  ${alias}

    END

    [Return]  ${RMOD_BTS_alias_list}

Get all BTS shared RMOD synchronisation impact due to reset operation
    [Arguments]  ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${alias}

    ${shared_RMOD_sn_SYNC_BTS_alias_dict}=  Get all BTS shared RMOD synchronisation info  ${RMOD_sn_BTS_alias_dict}

    ${all_BTS_peer_alias_shared_RMOD_sn_SYNC_loss_dict}=  Create Dictionary
    ${BTS_all_alias_list}=  Get Dictionary Keys  ${BTS_alias_RMOD_sn_dict}

    FOR  ${peer_alias}  IN  @{BTS_all_alias_list}

        Continue For Loop If  '${peer_alias}' == '${alias}'

        ${BTS_peer_alias_shared_RMOD_sn_SYNC_loss_dict}=  Create Dictionary

        ${CPRI_SYNC_loss_shared_RMOD_sn_list}  ${ECPRI_SYNC_loss_shared_RMOD_sn_list}=  Get SYNC loss info for shared RMOD
        ...  ${shared_RMOD_sn_SYNC_BTS_alias_dict}  ${RMOD_sn_BTS_alias_dict}  ${alias}  ${peer_alias}

        ${shared_RMOD_sn_SYNC_loss_dict}=  Create Dictionary
        ...  CPRI_shared_RMOD_sn_SYNC_loss=${CPRI_SYNC_loss_shared_RMOD_sn_list}
        ...  ECPRI_shared_RMOD_sn_SYNC_loss=${ECPRI_SYNC_loss_shared_RMOD_sn_list}

        Set To Dictionary  ${BTS_peer_alias_shared_RMOD_sn_SYNC_loss_dict}  ${peer_alias}  ${shared_RMOD_sn_SYNC_loss_dict}

    END

    Set To Dictionary  ${all_BTS_peer_alias_shared_RMOD_sn_SYNC_loss_dict}  ${alias}  ${BTS_peer_alias_shared_RMOD_sn_SYNC_loss_dict}

    [Return]  ${all_BTS_peer_alias_shared_RMOD_sn_SYNC_loss_dict}

Get all BTS shared RMOD synchronisation info
    [Documentation]
    ...  Helper KW providing radio modules syncronisation info on specific interface as:
    ...  - dictionary containing structure: {'RMOD_serial_number': 'BTS_alias'} (key: RMOD serial number, value: BTS alias providing syncronisation
    ...  info to RMOD
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter                             | Description                                                                              |
    ...  | shared_RMOD_sn_SYNC_BTS_alias_dict    | Dictionary containing structure: {'shared_RMOD_sn': {'<CPRI/ECPRI key>:'SYNC_BTS_alias'} |
    ...
    [Arguments]  ${RMOD_sn_BTS_alias_dict}

    ${shared_RMOD_sn_SYNC_BTS_alias_dict}=  Create Dictionary

    ${RMOD_all_sn_list}=  Get Dictionary Keys  ${RMOD_sn_BTS_alias_dict}

    FOR  ${RMOD_sn}  IN  @{RMOD_all_sn_list}

        ${RMOD_BTS_alias_list}=  Get From Dictionary   ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}

        ${RMOD_BTS_alias_count}=  Get Length  ${RMOD_BTS_alias_list}

        Continue For Loop If  ${RMOD_BTS_alias_count} == 1

        ${SYNC_BTS_alias}  ${NON_SYNC_BTS_alias}  ${RMOD_interface}=  Get BTS shared RMOD synchronisation info from SCF  ${RMOD_sn}
        ...  ${RMOD_BTS_alias_list}

        ${SYNC_BTS_alias_CPRI_shared_RMOD}=  Set Variable If  '${RMOD_interface}' == 'CPRI_RP1'  ${SYNC_BTS_alias}  None
        ${NON_SYNC_BTS_alias_CPRI_shared_RMOD}=  Set Variable If  '${RMOD_interface}' == 'CPRI_RP1'  ${NON_SYNC_BTS_alias}  None
        ${SYNC_BTS_alias_ECPRI_shared_RMOD}=  Set Variable If  '${RMOD_interface}' == 'ECPRI_MPLANE'  ${SYNC_BTS_alias}  None
        ${NON_SYNC_BTS_alias_ECPRI_shared_RMOD}=  Set Variable If  '${RMOD_interface}' == 'ECPRI_MPLANE'  ${NON_SYNC_BTS_alias}  None

        ${SYNC_BTS_alias_shared_RMOD_sn_dict}=  Create Dictionary
        ...  CPRI_shared_RMOD_sn_SYNC_BTS_alias=${SYNC_BTS_alias_CPRI_shared_RMOD}
        ...  CPRI_shared_RMOD_sn_NON_SYNC_BTS_alias=${NON_SYNC_BTS_alias_CPRI_shared_RMOD}
        ...  ECPRI_shared_RMOD_sn_SYNC_BTS_alias=${SYNC_BTS_alias_ECPRI_shared_RMOD}
        ...  ECPRI_shared_RMOD_sn_NON_SYNC_BTS_alias=${NON_SYNC_BTS_alias_ECPRI_shared_RMOD}

         Set To Dictionary  ${shared_RMOD_sn_SYNC_BTS_alias_dict}  ${RMOD_sn}=${SYNC_BTS_alias_shared_RMOD_sn_dict}

    END

    [Return]  ${shared_RMOD_sn_SYNC_BTS_alias_dict}

Get SYNC loss info for shared RMOD
    [Arguments]  ${shared_RMOD_sn_SYNC_BTS_alias_dict}  ${RMOD_sn_BTS_alias_dict}  ${alias}  ${peer_alias}

    ${BTS_RMOD_sn_list}=  Get Dictionary Keys  ${RMOD_sn_BTS_alias_dict}

    ${CPRI_SYNC_loss_shared_RMOD_sn_list}=  Create List
    ${ECPRI_SYNC_loss_shared_RMOD_sn_list}=  Create List
    ${shared_RMOD_BTS_alias_list}=  Create List  ${alias}  ${peer_alias}
    Sort List  ${shared_RMOD_BTS_alias_list}

    FOR  ${item}  IN  @{BTS_RMOD_sn_list}

        ${BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${item}
        Sort List  ${BTS_alias_list}

        ${shared_RMOD_status}=  Run Keyword And Return Status  Lists Should Be Equal  ${BTS_alias_list}  ${shared_RMOD_BTS_alias_list}

        Continue For Loop If  not ${shared_RMOD_status}

        ${SYNC_BTS_alias_dict}=  Get From Dictionary  ${shared_RMOD_sn_SYNC_BTS_alias_dict}  ${item}
        ${SYNC_BTS_alias_shared_RMOD_sn_dict}=  Get From Dictionary  ${shared_RMOD_sn_SYNC_BTS_alias_dict}  ${item}

        ${CPRI_SYNC_BTS_alias}=  Get From Dictionary  ${SYNC_BTS_alias_dict }  CPRI_shared_RMOD_sn_SYNC_BTS_alias
        ${ECPRI_SYNC_BTS_alias}=  Get From Dictionary  ${SYNC_BTS_alias_dict}  ECPRI_shared_RMOD_sn_SYNC_BTS_alias

        Run Keyword If  '${CPRI_SYNC_BTS_alias}' == '${alias}'
        ...  Append To List  ${CPRI_SYNC_loss_shared_RMOD_sn_list}  ${item}
        ...  ELSE IF  '${ECPRI_SYNC_BTS_alias}' == '${alias}'
        ...  Append To List  ${ECPRI_SYNC_loss_shared_RMOD_sn_list}  ${item}

    END

    [Return]  ${CPRI_SYNC_loss_shared_RMOD_sn_list}  ${ECPRI_SYNC_loss_shared_RMOD_sn_list}

Get BTS shared RMOD synchronisation info from SCF
    [Arguments]  ${RMOD_sn}  ${RMOD_BTS_alias_list}

    ${SYNC_BTS_info_dict}=  Create Dictionary

    FOR  ${index}  ${alias}  IN ENUMERATE  @{RMOD_BTS_alias_list}

        ${RMOD_linkModeSynchronization}  ${RMOD_interface}=  Run Keyword If  '${alias}' not in ${alias_list}
        ...  Get cloud BTS RMOD synchronisation info from SCF  ${RMOD_sn}  ${alias}
        ...  ELSE IF  '${alias}' in ${alias_list}
        ...  Get classical BTS RMOD synchronisation info from SCF  ${RMOD_sn}  ${alias}

        Set Test Variable  ${RMOD_linkModeSynchronization_${index}}  ${RMOD_linkModeSynchronization}
        Run Keyword If  ${index} == 1  Run Keyword If  '${RMOD_linkModeSynchronization_0}' == '${RMOD_linkModeSynchronization_1}'  Run Keywords
        ...  Log  Inconsistent linkModeSynchronization info for shared RMOD with SN ${RMOD_sn} on ${RMOD_BTS_alias_list}  level=ERROR
        ...  AND  Fail  Inconsistent linkModeSynchronization info for shared RMOD on ${RMOD_BTS_alias_list}

        Set To Dictionary  ${SYNC_BTS_info_dict}  ${RMOD_linkModeSynchronization}  ${alias}

    END

    ${RMOD_linkModeSynchronization_True}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${SYNC_BTS_info_dict}  True
    ${RMOD_linkModeSynchronization_False}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${SYNC_BTS_info_dict}  False
    ${RMOD_linkModeSynchronization_None}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${SYNC_BTS_info_dict}  None

    ${SYNC_BTS_alias}=  Run Keyword If  ${RMOD_linkModeSynchronization_True}  Get From Dictionary  ${SYNC_BTS_info_dict}  True
    ...  ELSE IF  ${RMOD_linkModeSynchronization_None}  Get From Dictionary  ${SYNC_BTS_info_dict}  None
    ${NON_SYNC_BTS_alias}=  Run Keyword If  ${RMOD_linkModeSynchronization_False}  Get From Dictionary  ${SYNC_BTS_info_dict}  False
    ...  ELSE IF  ${RMOD_linkModeSynchronization_None}  Get From Dictionary  ${SYNC_BTS_info_dict}  None

    [Return]  ${SYNC_BTS_alias}  ${NON_SYNC_BTS_alias}  ${RMOD_interface}

Get cloud BTS RMOD synchronisation info from SCF
    [Arguments]  ${RMOD_sn}  ${vdu_alias}

    ${RMOD_linkModeSynchronization_list}=  Create List

    ${VDU_SCF_path_file_info}=  VDU Get Current Plan File  vdu_connection=${vdu_alias}

    ${BTS_SCF_RMOD_R_list}=  Get All Dist Names By Pattern from SCF  pattern=/RMOD_R-[\\d]+$  scf_path=${VDU_SCF_path_file_info}  alias=${vdu_alias}

    FOR  ${item}  IN  @{BTS_SCF_RMOD_R_list}

       ${l3Protocol_info}=  Check Parameter Value from SCF  item_dist_name=${item}  parameter_to_check=l3Protocol
       ...  scf_path=${VDU_SCF_path_file_info}
       ${RMOD_interface}=  Set Variable  ${l3Protocol_info}

       ${serialNumber_info}=  Check Parameter Value from SCF  item_dist_name=${item}  parameter_to_check=serialNumber
       ...  scf_path=${VDU_SCF_path_file_info}
       ${RMOD_R_dn}=  Set Variable  ${item}

       Exit For Loop If  '${serialNumber_info}' == '${RMOD_sn}'

    END

    ${BTS_SCF_RNICMOD_R_list}=  Get All Dist Names By Pattern from SCF  pattern=/RNICMOD_R-[\\d]+$  scf_path=${VDU_SCF_path_file_info}
    ...  alias=${vdu_alias}

    ${BTS_SCF_CABLINK_R_list}=  Get All Dist Names By Pattern from SCF  pattern=/CABLINK_R-[\\d]+$  scf_path=${VDU_SCF_path_file_info}
    ...  alias=${vdu_alias}

    FOR  ${item}  IN  @{BTS_SCF_CABLINK_R_list}

       ${firstEndpointDN_info}=  Check Parameter Value from SCF  item_dist_name=${item}  parameter_to_check=firstEndpointDN
       ...  scf_path=${VDU_SCF_path_file_info}
       Continue For Loop If  '${firstEndpointDN_info}' not in ${BTS_SCF_RNICMOD_R_list}

       ${secondEndpointDN_info}=  Check Parameter Value from SCF  item_dist_name=${item}  parameter_to_check=secondEndpointDN
       ...  scf_path=${VDU_SCF_path_file_info}
       Continue For Loop If  '${secondEndpointDN_info}' != '${RMOD_R_dn}'

       ${linkModeSynchronization_info}=  Check Parameter Value from SCF  item_dist_name=${item}  parameter_to_check=linkModeSynchronization
       ...  scf_path=${VDU_SCF_path_file_info}

       Append To List  ${RMOD_linkModeSynchronization_list}  ${linkModeSynchronization_info}

    END

    ${RMOD_linkModeSynchronization_count}=  Get Length  ${RMOD_linkModeSynchronization_list}
    ${RMOD_linkModeSynchronization}=  Set Variable If  ${RMOD_linkModeSynchronization_count} == 0  None
    ...  ${RMOD_linkModeSynchronization_count} > 0 and 'true' in ${RMOD_linkModeSynchronization_list}  True  False

    [Return]  ${RMOD_linkModeSynchronization}  ${RMOD_interface}

Get classical BTS RMOD synchronisation info from SCF
    [Arguments]  ${RMOD_sn}  ${alias}

    ${RMOD_linkModeSynchronization_list}=  Create List

    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}  folder_path=/tmp
    ...  export_type=configurationAndRuntimeObjects

    ${BTS_SCF_RMOD_R_list}=  Get All Dist Names By Pattern from SCF  pattern=/RMOD_R-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}

    FOR  ${item}  IN  @{BTS_SCF_RMOD_R_list}

       ${l3Protocol_info}=  Check Parameter Value from SCF  item_dist_name=${item}  parameter_to_check=l3Protocol
       ...  scf_path=${BTS_SCF_path_file_info}
       ${RMOD_interface}=  Set Variable  ${l3Protocol_info}

       ${serialNumber_info}=  Check Parameter Value from SCF  item_dist_name=${item}  parameter_to_check=serialNumber
       ...  scf_path=${BTS_SCF_path_file_info}
       ${RMOD_R_dn}=  Set Variable  ${item}

       Exit For Loop If  '${serialNumber_info}' == '${RMOD_sn}'

    END

    ${BTS_SCF_SMOD_R_list}=  Get All Dist Names By Pattern from SCF  pattern=/SMOD_R-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_BBMOD_R_list}=  Get All Dist Names By Pattern from SCF  pattern=/BBMOD_R-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${firstEndpointDN_list}=  Combine Lists  ${BTS_SCF_SMOD_R_list}  ${BTS_SCF_BBMOD_R_list}

    ${BTS_SCF_CABLINK_R_list}=  Get All Dist Names By Pattern from SCF  pattern=/CABLINK_R-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}

    FOR  ${item}  IN  @{BTS_SCF_CABLINK_R_list}

       ${firstEndpointDN_info}=  Check Parameter Value from SCF  item_dist_name=${item}  parameter_to_check=firstEndpointDN
       ...  scf_path=${BTS_SCF_path_file_info}
       Continue For Loop If  '${firstEndpointDN_info}' not in ${firstEndpointDN_list}

       ${secondEndpointDN_info}=  Check Parameter Value from SCF  item_dist_name=${item}  parameter_to_check=secondEndpointDN
       ...  scf_path=${BTS_SCF_path_file_info}
       Continue For Loop If  '${secondEndpointDN_info}' != '${RMOD_R_dn}'

       ${linkModeSynchronization_info}=  Check Parameter Value from SCF  item_dist_name=${item}  parameter_to_check=linkModeSynchronization
       ...  scf_path=${BTS_SCF_path_file_info}

       Append To List  ${RMOD_linkModeSynchronization_list}  ${linkModeSynchronization_info}

    END

    ${RMOD_linkModeSynchronization_count}=  Get Length  ${RMOD_linkModeSynchronization_list}
    ${RMOD_linkModeSynchronization}=  Set Variable If  ${RMOD_linkModeSynchronization_count} == 0  None
    ...  ${RMOD_linkModeSynchronization_count} > 0 and 'true' in ${RMOD_linkModeSynchronization_list}  True  False

    [Return]  ${RMOD_linkModeSynchronization}  ${RMOD_interface}

Get all BTS Cells mapped on RMOD info
    [Documentation]
    ...  Helper KW providing info about all BTS cells mapped on radio modules by specific RAT
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter                     | Description                                                                                               |
    ...  | all_BTS_RMOD_id_CELL_ids_info | Dictionary containing structure: {'BTS_alias':{'RMOD_id_<RAT>_CELL_ids_dict': {'RMOD_id': ['CELL_ids']}}} |
    ...

    ${all_BTS_RMOD_id_CELL_ids_info}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${all_BTS_RMOD_id_CELL_ids_info}=  Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'
        ...  Get cloud BTS Cells Mapped On RMOD info  ${all_BTS_RMOD_id_CELL_ids_info}  ${alias}
        ...  ELSE IF  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']
        ...  Get classical BTS Cells mapped on RMOD info  ${all_BTS_RMOD_id_CELL_ids_info}  ${alias}

    END

    [Return]  ${all_BTS_RMOD_id_CELL_ids_info}

Get cloud BTS Cells Mapped On RMOD info
    [Arguments]  ${all_BTS_RMOD_id_CELL_ids_info}  ${alias}

    ${vdu_list_length}=  Get Length  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  IN RANGE  ${vdu_list_length}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        ${VDU_RMOD_id_NR_CELL_ids_dict}  ${VDU_RMOD_id_LTE_CELL_ids_dict}  ${VDU_RMOD_id_WCDMA_CELL_ids_dict}  ${VDU_RMOD_id_GSM_CELL_ids_dict}=
        ...  VDU Get Cells Mapped On RMOD  vdu_connection=${vdu_alias}

        ${VDU_RMOD_id_CELL_ids_info}=  Create Dictionary
        ...  RMOD_id_NR_CELL_ids_dict=${VDU_RMOD_id_NR_CELL_ids_dict}
        ...  RMOD_id_LTE_CELL_ids_dict=${VDU_RMOD_id_LTE_CELL_ids_dict}
        ...  RMOD_id_LTE_IOT_CELL_ids_dict=${VDU_RMOD_id_LTE_CELL_ids_dict}
        ...  RMOD_id_LTE_IOT_SA_CELL_ids_dict=${VDU_RMOD_id_LTE_CELL_ids_dict}
        ...  RMOD_id_WCDMA_CELL_ids_dict=${VDU_RMOD_id_WCDMA_CELL_ids_dict}
        ...  RMOD_id_GSM_CELL_ids_dict=${VDU_RMOD_id_GSM_CELL_ids_dict}

        Set To Dictionary  ${all_BTS_RMOD_id_CELL_ids_info}  ${vdu_alias}=${VDU_RMOD_id_CELL_ids_info}

    END

    [Return]  ${all_BTS_RMOD_id_CELL_ids_info}

Get classical BTS Cells mapped on RMOD info
    [Arguments]  ${all_BTS_RMOD_id_CELL_ids_info}  ${alias}

    ${BTS_RMOD_id_NR_CELL_ids_dict}=  Create Dictionary
    ${BTS_RMOD_id_LTE_CELL_ids_dict}=  Create Dictionary
    ${BTS_RMOD_id_LTE_IOT_CELL_ids_dict}=  Create Dictionary
    ${BTS_RMOD_id_LTE_IOT_SA_CELL_ids_dict}=  Create Dictionary
    ${BTS_RMOD_id_WCDMA_CELL_ids_dict}=  Create Dictionary
    ${BTS_RMOD_id_GSM_CELL_ids_dict}=  Create Dictionary

    ${BTS_RMOD_id_list}=  Get Ids For All  class_name=RMOD  connection=${alias}
    ${BTS_NR_CELL_id_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${BTS_LTE_CELL_id_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${BTS_LTE_HOST_CELL_id_list}  ${BTS_LTE_IOT_CELL_id_list}  ${BTS_LTE_IOT_SA_CELL_id_list}=
    ...  Admin Get LTE HOST and IOT Cell(s) Id list  ${BTS_LTE_CELL_id_list}  alias=${alias}
    ${BTS_WCDMA_CELL_id_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${BTS_GSM_CELL_id_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}

    ${RMOD_id_CELL_id_dict}=  Get RMOD CELL mapping based on Carrier info  ${alias}

    FOR  ${item}  IN  @{BTS_RMOD_id_list}

        ${RMOD_NR_CELL_id_list}  ${RMOD_LTE_HOST_CELL_id_list}  ${RMOD_LTE_IOT_CELL_id_list}  ${RMOD_LTE_IOT_SA_CELL_id_list}
        ...  ${RMOD_WCDMA_CELL_id_list}  ${RMOD_GSM_CELL_id_list}=  Get classical BTS Cells mapped on RMOD by specific RAT  ${item}
        ...  ${BTS_NR_CELL_id_list}  ${BTS_LTE_HOST_CELL_id_list}  ${BTS_LTE_IOT_CELL_id_list}  ${BTS_LTE_IOT_SA_CELL_id_list}
        ...  ${BTS_WCDMA_CELL_id_list}  ${BTS_GSM_CELL_id_list}  ${RMOD_id_CELL_id_dict}

        Set To Dictionary  ${BTS_RMOD_id_NR_CELL_ids_dict}  ${item}  ${RMOD_NR_CELL_id_list}
        Set To Dictionary  ${BTS_RMOD_id_LTE_CELL_ids_dict}  ${item}  ${RMOD_LTE_HOST_CELL_id_list}
        Set To Dictionary  ${BTS_RMOD_id_LTE_IOT_CELL_ids_dict}  ${item}  ${RMOD_LTE_IOT_CELL_id_list}
        Set To Dictionary  ${BTS_RMOD_id_LTE_IOT_SA_CELL_ids_dict}  ${item}  ${RMOD_LTE_IOT_SA_CELL_id_list}
        Set To Dictionary  ${BTS_RMOD_id_WCDMA_CELL_ids_dict}  ${item}  ${RMOD_WCDMA_CELL_id_list}
        Set To Dictionary  ${BTS_RMOD_id_GSM_CELL_ids_dict}  ${item}  ${RMOD_GSM_CELL_id_list}

    END

    ${BTS_RMOD_id_CELL_ids_info}=  Create Dictionary
    ...  RMOD_id_NR_CELL_ids_dict=${BTS_RMOD_id_NR_CELL_ids_dict}
    ...  RMOD_id_LTE_CELL_ids_dict=${BTS_RMOD_id_LTE_CELL_ids_dict}
    ...  RMOD_id_LTE_IOT_CELL_ids_dict=${BTS_RMOD_id_LTE_IOT_CELL_ids_dict}
    ...  RMOD_id_LTE_IOT_SA_CELL_ids_dict=${BTS_RMOD_id_LTE_IOT_SA_CELL_ids_dict}
    ...  RMOD_id_WCDMA_CELL_ids_dict=${BTS_RMOD_id_WCDMA_CELL_ids_dict}
    ...  RMOD_id_GSM_CELL_ids_dict=${BTS_RMOD_id_GSM_CELL_ids_dict}

    Set To Dictionary  ${all_BTS_RMOD_id_CELL_ids_info}  ${alias}=${BTS_RMOD_id_CELL_ids_info}

    [Return]  ${all_BTS_RMOD_id_CELL_ids_info}

Get classical BTS Cells mapped on RMOD by specific RAT
    [Arguments]  ${RMOD_id}  ${BTS_NR_CELL_id_list}  ${BTS_LTE_HOST_CELL_id_list}  ${BTS_LTE_IOT_CELL_id_list}  ${BTS_LTE_IOT_SA_CELL_id_list}
    ...  ${BTS_WCDMA_CELL_id_list}  ${BTS_GSM_CELL_id_list}  ${RMOD_id_CELL_id_dict}

    ${RMOD_NR_CELL_id_list}=  Create List
    ${RMOD_LTE_HOST_CELL_id_list}=  Create List
    ${RMOD_LTE_IOT_CELL_id_list}=  Create List
    ${RMOD_LTE_IOT_SA_CELL_id_list}=  Create List
    ${RMOD_WCDMA_CELL_id_list}=  Create List
    ${RMOD_GSM_CELL_id_list}=  Create List

    ${RMOD_CELL_id_list}=  Get From Dictionary  ${RMOD_id_CELL_id_dict}  ${RMOD_id}

    FOR  ${item}  IN  @{RMOD_CELL_id_list}

        Run Keyword If  '${item}' in ${BTS_NR_CELL_id_list}  Append To List  ${RMOD_NR_CELL_id_list}  ${item}
        ...  ELSE IF  '${item}' in ${BTS_LTE_HOST_CELL_id_list}   Append To List  ${RMOD_LTE_HOST_CELL_id_list}  ${item}
        ...  ELSE IF  '${item}' in ${BTS_LTE_IOT_CELL_id_list}   Append To List  ${RMOD_LTE_IOT_CELL_id_list}  ${item}
        ...  ELSE IF  '${item}' in ${BTS_LTE_IOT_SA_CELL_id_list}   Append To List  ${RMOD_LTE_IOT_SA_CELL_id_list}  ${item}
        ...  ELSE IF  '${item}' in ${BTS_WCDMA_CELL_id_list}   Append To List  ${RMOD_WCDMA_CELL_id_list}  ${item}
        ...  ELSE IF  '${item}' in ${BTS_GSM_CELL_id_list}   Append To List  ${RMOD_GSM_CELL_id_list}  ${item}

    END

    Sort List  ${RMOD_NR_CELL_id_list}
    Sort List  ${RMOD_LTE_HOST_CELL_id_list}
    Sort List  ${RMOD_LTE_IOT_CELL_id_list}
    Sort List  ${RMOD_LTE_IOT_SA_CELL_id_list}
    Sort List  ${RMOD_WCDMA_CELL_id_list}
    Sort List  ${RMOD_GSM_CELL_id_list}

    [Return]  ${RMOD_NR_CELL_id_list}  ${RMOD_LTE_HOST_CELL_id_list}  ${RMOD_LTE_IOT_CELL_id_list}  ${RMOD_LTE_IOT_SA_CELL_id_list}
    ...  ${RMOD_WCDMA_CELL_id_list}  ${RMOD_GSM_CELL_id_list}

Get configured FHGW id list from init file
    [Documentation]
    ...  Get configured FHGW id list from init file.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter    | Description                             |
    ...  | FHGW_id_list | Configured FHGW id list in init.py file |
    ...

    ${FHGW_id_list}=  Create List

    ${INTERFACES_keys}=  Get Dictionary Keys  ${INTERFACES}

    FOR  ${key}  IN  @{INTERFACES_keys}

        ${FHGW_id_found}=  Run Keyword And Return Status  Should Match Regexp  ${key}  FHGW_.*
        Continue For Loop If  not ${FHGW_id_found}

        ${FHGW_id}=  Fetch From Right  ${key}  _

        Append To List  ${FHGW_id_list}  ${FHGW_id}

    END

    [Return]  ${FHGW_id_list}

Unlock potentially locked elements
    [Arguments]  ${aliases}  ${needed_state}=Unlocked

    Log  ****************************************************************************************************************  console=True
    Log  Setting state of ${needed_state} NRDU, BBMOD, RMOD, NRCEL, LNCEL, LANE if they have different administrativeState  console=True
    Log  ****************************************************************************************************************  console=True

    ${needed_state_title}=  Convert To Title Case  ${needed_state}
    ${needed_state_lower}=  Convert To Lower Case  ${needed_state}

    FOR  ${alias}  IN  @{aliases}
        Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_TECH]'=='CBTS'
        ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
        ${bbmod_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/BBMOD-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
        ${rmod_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/RMOD-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
        ${rmod_dn_list}=  Filter Out RMOD That Have Different Primary Controller  ${rmod_dn_list}  scf_path=${BTS_scf}
        ${nrcell_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/NRCELL-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
        ${lncell_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/LNCEL-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
        ${nrbts_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/NRDU-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
        ${nrbts_dn_list}=  Run Keyword If  ${nrbts_dn_list}
        ...  Create List  ${nrbts_dn_list[${0}]}
        ...  ELSE  Create List
        ${lane_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/LANE-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
        Run Keyword And Return Status  Check and lock or unlock element  alias=${alias}  element_dn_list=${lane_dn_list}
        ...  needed_state=${needed_state_title}  timeout=300
        Run Keyword And Return Status  Check and lock or unlock element  alias=${alias}  element_dn_list=${nrbts_dn_list}
        ...  needed_state=${needed_state_title}  timeout=300
        Run Keyword And Return Status  Check and lock or unlock element  alias=${alias}  element_dn_list=${bbmod_dn_list}
        ...  needed_state=${needed_state_title}  timeout=300
        Run Keyword And Return Status  Check and lock or unlock element  alias=${alias}  element_dn_list=${rmod_dn_list}
        ...  needed_state=${needed_state_title}  timeout=300
        Run Keyword And Return Status  Check and lock or unlock element  alias=${alias}  element_dn_list=${nrcell_dn_list}
        ...  needed_state=${needed_state_title}  timeout=300
        Run Keyword And Return Status  Check and lock or unlock element  alias=${alias}  element_dn_list=${lncell_dn_list}
        ...  needed_state=${needed_state_lower}  timeout=300

    END

    Log  *****************************************  console=True
    Log  Setting state of ${needed_state} finished  console=True
    Log  *****************************************  console=True

Check and lock or unlock element
    [Arguments]  ${alias}  ${element_dn_list}  ${needed_state}=Unlocked
    ...  ${timeout}=300  ${scf}=${Empty}

    ${collective_result}=  Set Variable  ${True}
    ${check_status}=  Set Variable  ${False}
    Return From Keyword If  not ${element_dn_list}   ${collective_result}

    FOR  ${element}  IN  @{element_dn_list}

        ${BTS_scf}=  Run Keyword If  '${scf} '==' '  Admin Collect scf.xml with timestamp TAF  alias=${alias}
        ...  ELSE  Set Variable  ${scf}
        ${administrativeState_from_bts}  ${dummy_dict}=  Get Object Attributes Values From Scf  dist_name=${element}  p_name=administrativeState
        ...  scf_path=${BTS_scf}
        Continue For Loop If  not ${administrativeState_from_bts}

        ${check_status}=  Run Keyword And Return Status  Should Match Regexp  pattern=^${needed_state}$
        ...  string=${administrativeState_from_bts['administrativeState']}
        Log  ${element} administrativeState is ${administrativeState_from_bts['administrativeState']}  console=True
        Continue For Loop If  ${check_status}

        Log  Setting ${needed_state}  console=True
        ${action_flag}=  Run Keyword And Return Status  Should Match Regexp  pattern=^[Uu]nlock  string=${needed_state}
        Run Keyword If  ${action_flag}
        ...  coam.Unlock  dist_name=${element}  timeout=${timeout}
        ...  connection=${alias}  detailed_output=True
        ...  ELSE
        ...  coam.Lock  dist_name=${element}  timeout=${timeout}
        ...  connection=${alias}  detailed_output=True

        ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
        ${administrativeState_from_bts}  ${dummy_dict}=  Get Object Attributes Values From Scf  dist_name=${element}  p_name=administrativeState
        ...  scf_path=${BTS_scf}
        ${check_status2}=  Run Keyword And Return Status  Should match regexp  pattern=^${needed_state}$
        ...  string=${administrativeState_from_bts['administrativeState']}
        Run Keyword If  not ${check_status} and ${check_status2}  Run Keywords
        ...  Log  Commissioning succeeded  console=True
        ...  AND  Log  ${element} administrativeState is ${administrativeState_from_bts['administrativeState']}\n  console=True
        ...  ELSE  Log  Commissioning didn't succeed  console=True
        ${collective_result}=  Evaluate  ${collective_result} and ${check_status2}

    END
    [Return]  ${collective_result}

Filter out RMOD that have different primary Controller
    [Arguments]    ${rmod_dn_list}  ${scf_path}

    ${result_list}=  Create List
    FOR  ${rmod_dn}  IN  @{rmod_dn_list}
        ${p_name_info_dict}  ${dummy_dict}=  Get Object Attributes Values From Scf
        ...  scf_path=${scf_path}  dist_name=${rmod_dn}  p_name=radioMasterDN
        ${dummy_dict}  ${list_info_dict}=  Get Object Attributes Values From Scf
        ...  scf_path=${scf_path}  dist_name=${rmod_dn}  list_name=sharingConfig  index=1

        ${controllerRole_info}=  Run Keyword If  ${list_info_dict}
        ...  Get From Dictionary  ${list_info_dict}  sharingConfig
        ...  ELSE  Set Variable  ${Empty}
        ${radioMasterDN_info}=  Run Keyword If  ${p_name_info_dict}  Get From Dictionary  ${p_name_info_dict}  radioMasterDN
        ...  ELSE  Set Variable  ${Empty}
        ${current_bts_is_radio_master_p_name}=  Run Keyword And Return Status  Should Not Match Regexp  ${radioMasterDN_info}  .*_EXT-.*
        ${current_bts_is_radio_master_list}=  Run Keyword And Return Status  Should Match Regexp  ${controllerRole_info}  ^Primary$

        ${primary_controller_condition}=  Create Long String
        ...  (${current_bts_is_radio_master_p_name} and '${radioMasterDN_info}') or
        ...  (${current_bts_is_radio_master_list} and '${controllerRole_info}') or
        ...  (not '${controllerRole_info}' and not '${radioMasterDN_info}')
        Run Keyword If  ${primary_controller_condition}
        ...  Append To List  ${result_list}  ${rmod_dn}
    END

    [Return]    ${result_list}

Get all BTS FHS sharing info
    [Documentation]
    ...  Helper KW providing radio modules info related to sharing status as:
    ...  - dictionary containing structure: {'BTS_alias': '<FHS_serial_number_list>'}
    ...  - dictionary containing structure: {'FHS_serial_number': '<BTS_alias_list>'}
    ...  - list of shared FHS serial number
    ...  - list of dedicated FHS serial number
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter             | Description                    |
    ...  | BTS_alias_FHS_sn_dict | Dict of BTS alias FHS sn info |
    ...  | FHS_sn_BTS_alias_dict | Dict of FHS sn BTS alias info |
    ...  | shared_FHS_sn_list    | List of shared FHS sn info    |
    ...  | dedicated_FHS_sn_list | List of dedicated FHS sn info |

    ${FHS_all_sn_list}=  Create List
    ${BTS_alias_FHS_sn_dict}=  Create Dictionary
    ${FHS_sn_BTS_alias_dict}=  Create Dictionary
    ${shared_FHS_sn_list}=  Create List
    ${dedicated_FHS_sn_list}=  Create List

    FOR  ${alias}  IN  @{alias_list}

        Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_MODULE_TYPE]' == 'FSMF'

        ${BTS_alias_FHS_sn_dict}  ${FHS_sn_list}=  Get BTS FHS serial number list  ${BTS_alias_FHS_sn_dict}  ${alias}
        Sort List  ${FHS_sn_list}
        Append To List  ${FHS_all_sn_list}  @{FHS_sn_list}

    END

    ${FHS_all_sn_list}=  Remove Duplicates  ${FHS_all_sn_list}
    Sort List  ${FHS_all_sn_list}

    FOR  ${FHS_sn}  IN  @{FHS_all_sn_list}

        ${FHS_BTS_alias_list}=  Get FHS BTS alias info list  ${FHS_sn}  ${BTS_alias_FHS_sn_dict}
        Sort List  ${FHS_BTS_alias_list}
        Set To Dictionary  ${FHS_sn_BTS_alias_dict}  ${FHS_sn}  ${FHS_BTS_alias_list}

        ${FHS_BTS_alias_count}=  Get Length  ${FHS_BTS_alias_list}
        Run Keyword If  ${FHS_BTS_alias_count} == 1
        ...  Append To List  ${dedicated_FHS_sn_list}  ${FHS_sn}
        ...  ELSE IF  ${FHS_BTS_alias_count} > 1
        ...  Append To List  ${shared_FHS_sn_list}  ${FHS_sn}

    END

    [Return]  ${BTS_alias_FHS_sn_dict}  ${FHS_sn_BTS_alias_dict}  ${shared_FHS_sn_list}  ${dedicated_FHS_sn_list}

Get BTS FHS serial number list
    [Arguments]  ${BTS_alias_FHS_sn_dict}  ${alias}

    ${BTS_FHS_sn_id_dict}  ${BTS_FHS_id_sn_dict}  ${BTS_FHS_sn_pn_dict}=  Admin Get FHS sn id pn info  alias=${alias}
    ${BTS_FHS_sn_list}=  Get Dictionary Keys  ${BTS_FHS_sn_id_dict}
    Set To Dictionary  ${BTS_alias_FHS_sn_dict}  ${alias}  ${BTS_FHS_sn_list}

    Set Test Variable  ${${alias}_FHS_sn_list}  ${BTS_FHS_sn_list}
    Set Test Variable  ${${alias}_FHS_sn_id_dict}  ${BTS_FHS_sn_id_dict}
    Set Test Variable  ${${alias}_FHS_id_sn_dict}  ${BTS_FHS_id_sn_dict}
    Set Test Variable  ${${alias}_FHS_sn_pn_dict}  ${BTS_FHS_sn_pn_dict}

    [Return]  ${BTS_alias_FHS_sn_dict}  ${BTS_FHS_sn_list}

Get FHS BTS alias info list
    [Arguments]  ${FHS_sn}  ${BTS_alias_FHS_sn_dict}

    ${FHS_BTS_alias_list}=  Create List
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_FHS_sn_dict}  False

    FOR  ${alias}  IN  @{BTS_alias_list}

        ${FHS_sn_list}=  Get From Dictionary  ${BTS_alias_FHS_sn_dict}  ${alias}
        Run Keyword If  '${FHS_sn}' in ${FHS_sn_list}
        ...  Append To List  ${FHS_BTS_alias_list}  ${alias}

    END

    [Return]  ${FHS_BTS_alias_list}

Get BTS MPlane info
    [Documentation]
    ...  Get BTS MPlane info:
    ...  - BTS MPlane IPv4, Fixed MPlane IPv4 for left core, Fixed MPlane IPv4 for right core
    ...  - BTS MPlane IPv6, Fixed MPlane IPv6 for left core, Fixed MPlane IPv6 for right core
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description          |
    ...  | alias     | Yes  | admin instance alias |
    ...
    ...  *RETURN VALUE*
    ...  | BTS_MPlane_dict | BTS MPlane dict containing structure: {'mPlaneIpv4Address': '<value>', 'mPlaneIpv4AddrFixedLeftCore': '<value>',
    ...                      'mPlaneIpv4AddrFixedRightCore': '<value>', 'mPlaneIpv6Address': '<value>','mPlaneIpv6AddrFixedLeftCore':
    ...                      '<value>', 'mPlaneIpv6AddrFixedRightCore': '<value>'}                                                             |
    ...
    [Arguments]    ${alias}

    ${BTS_MPlane_dict}=    Create Dictionary    mPlaneIpv4Address=NA    mPlaneIpv4AddrFixedLeftCore=NA    mPlaneIpv4AddrFixedRightCore=NA
    ...    mPlaneIpv6Address=NA    mPlaneIpv6AddrFixedLeftCore=NA    mPlaneIpv6AddrFixedRightCore=NA
    ${BTS_MPlane_info_list}=    Get Dictionary Keys    ${BTS_MPlane_dict}    False

    ${BTS_scf}=    Admin Collect scf.xml with timestamp TAF    alias=${alias}
    ${MPLANENW_dn_list}=    Get All Dist Names By Pattern from SCF    pattern=/MPLANENW-[\\d]+$    scf_path=${BTS_scf}    alias=${alias}
    ${MPLANENW_dn}=    Get From List    ${MPLANENW_dn_list}    0

    FOR    ${item}    IN    @{BTS_MPlane_info_list}
        ${item_info_dict}    ${EMPTY}=    Get Object Attributes Values From Scf    scf_path=${BTS_scf}    dist_name=${MPLANENW_dn}
        ...    p_name=${item}DN
        TRY
            ${item_info}=    Get From Dictionary    ${item_info_dict}    ${item}DN
        EXCEPT
            ${item_info}=    Set Variable    NA
        END

        IF    '${item_info}' == 'NA'    CONTINUE

        ${localIpAddr_info_dict}    ${EMPTY}=    Get Object Attributes Values From Scf    scf_path=${BTS_scf}    dist_name=${item_info}
        ...    p_name=localIpAddr
        TRY
            ${localIpAddr_info}=    Get From Dictionary    ${localIpAddr_info_dict}    localIpAddr
        EXCEPT
            ${localIpAddr_info}=    Set Variable    NA
        END

        IF    '${item_info}' == 'NA'    CONTINUE

        Set To Dictionary    ${BTS_MPlane_dict}    ${item}    ${localIpAddr_info}
    END

    RETURN    ${BTS_MPlane_dict}
