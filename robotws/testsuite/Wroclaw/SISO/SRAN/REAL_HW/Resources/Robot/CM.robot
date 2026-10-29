*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS
...  Resource file with Configuration management procedures.

Library  OperatingSystem
Library  Collections
Library  String
Library  taf.sbts.oam.coam.admin  WITH NAME  admin
Library  taf.rfrl.common_resources.python.reset_bts_configuration  WITH NAME  rfrl_reset_conf
Library  taf.fdsw.rc  WITH NAME  rc

Resource  ./ASIR.robot
Resource  ./PDU.robot


*** Variables ***
${CUSTOM_FDSW_DEBUG_LOGS}=  ${False}


*** Keywords ***
CM Perform Multinode Reset Configuration
  [Documentation]
  ...  Description:
  ...  This procedure execute reset configuration on every BTS within set of configurations.
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp
  ...  message=Configuration procedure on every BTS will be executed  style=ONGOING
  FOR  ${bts_id}  IN  @{CFG.NODES}
    CM BTS Configuration Reset
    ...  bts_id=${bts_id}
    ...  fdsw_debug_logs=${CUSTOM_FDSW_DEBUG_LOGS}
  END
  Logging With Timestamp
  ...  message=Configuration procedure on every BTS finished  style=DONE

CM Perform Multinode Template File Commissioning
  [Documentation]
  ...  Description:
  ...  This procedure execute recommissioning configuration on every BTS within set of configurations.
  ...  It use scf file available on VM, also force "ignore error" parameter.
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp
  ...  message=Configuration recommissioning on every BTS will be executed  style=ONGOING
  FOR  ${bts_id}  IN  @{CFG.NODES}
    CM Perform Template File Commissioning
    ...  bts_id=${bts_id}
    ...  recommissioning_scf_file_path=${CFG.NODES['${bts_id}']['scf_file_path']}
    ...  ignore_errors=${True}
  END
  Logging With Timestamp
  ...  message=Configuration recommissioning on every BTS will finished  style=DONE

CM Perform Template File Commissioning
  [Arguments]  ${bts_id}  ${recommissioning_scf_file_path}  ${ignore_errors}
  [Documentation]
  ...  Description:
  ...  Perform commissioning using template file and session prepared for specific bts id.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument                      | Man. | Description                                                         |
  ...  +========================+======+============================================================================+
  ...  | bts_id                        | Yes  | BTS ID number                                                       |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | recommissioning_scf_file_path | Yes  | full path to scf file                                               |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | ignore_errors                 | Yes  | True or False, it force procedure to ignore errors                  |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp
  ...  message=BTS template commissioning procedure on bts_id node=${bts_id} started
  ...  style=ONGOING
  Logging With Timestamp
  ...  message=Source File = ${recommissioning_scf_file_path}.\nProcedure Parameters: Ignore Errors = ${ignore_errors}
  ...  style=ONGOING
  ${result}=  Run Keyword And Continue On Failure
  ...  admin.Perform Commissioning  bts_id=${bts_id}
  ...  scf_file=${recommissioning_scf_file_path}
  ...  skip_parameter_relation_errors=${ignore_errors}
  ...  should_activate=True
  ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
  ...  connection=${bts_id}
  ${asirmod_exist}=  Run Keyword And Return Status
  ...  Should Not Be Empty  ${CFG.NODES['${bts_id}']['scf_hw_asir_list']}
  IF  ${asirmod_exist}
    ${asirmod_result}=  CM Perform ASIRMOD Recommissioning  ${bts_id}  ${recommissioning_scf_file_path}
  ELSE
    ${asirmod_result}=  Set Variable  ${None}
  END
  [Teardown]  Logging With Timestamp
  ...  message=BTS template commissioning procedure on bts_id node=${bts_id} finished.
  ...  style=DONE
  [Return]  ${result}  ${asirmod_result}

CM Perform ASIRMOD Recommissioning
  [Arguments]  ${bts_id}  ${recommissioning_scf_file_path}
  [Documentation]
  ...  Description:
  ...  Perform full commissioning of ASIR hub
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument                      | Man. | Description                                                         |
  ...  +========================+======+============================================================================+
  ...  | bts_id                        | Yes  | BTS ID number                                                       |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | recommissioning_scf_file_path | Yes  | full path to scf file -  ${recommissioning_scf_file_path}_ASIR.xml  |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  scf name ${recommissioning_scf_file_path}_ASIR.xml
  ...
  ...  Author: przemyslaw.kempa@nokia.com
  PDU Switch ON Device Lists  ${CFG.NODES['${bts_id}']['scf_hw_asir_list']}
  ${asirmod_status}=  Run Keyword And Return Status
  ...  admin.Assert Every  ASIRMOD  availabilityStatus=regex"(?i)Off\\s?line"  timeout=180  connection=${bts_id}
  IF  not ${asirmod_status}
    admin.Assert Every  ASIRMOD  operationalState=regex"(?i)enabled"  timeout=20  connection=${bts_id}
  END
  Run Keyword And Ignore Error
  ...  Asir Reset Configuration  alias=${bts_id}
  Run Keyword And Ignore Error
  ...  admin.Assert Every  ASIRMOD  availabilityStatus=regex"(?i)Not.?Installed"  timeout=60s  connection=${bts_id}
  Wait Until Keyword Succeeds  4min  1
  ...  admin.Assert No  ASIRMOD  availabilityStatus=regex"(?i)not\\s?installed"  connection=${bts_id}
  ${asir_scf_file_path}=  Split String From Right  ${recommissioning_scf_file_path}  /  max_split=1
  ${asir_scf_file_path}=  Replace String  ${asir_scf_file_path}[1]  .xml  _ASIR.xml
  ${asir_scf_file_path}=  Set Variable
  ...  /home/ute/testline_configuration/${TESTLINE}/${RELEASE}/node${CFG.NODES['${bts_id}']['node_id']}/${asir_scf_file_path}
  ${activation_scf_status}=  Asir Perform Commissioning  asir_scf_path=${asir_scf_file_path}  alias=${bts_id}
  admin.Reset Admin  connection=${bts_id}
  [Return]  ${activation_scf_status}

CM BTS Configuration Reset
  [Arguments]  ${bts_id}  ${fdsw_debug_logs}=${False}
  [Documentation]
  ...  Description:
  ...  Reset configuration procedure on specific bts id.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | bts_id                 | Yes  | BTS ID number                                                              |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  ${fdsw_debug_logs_level}=  Set Variable If  ${fdsw_debug_logs}
  ...  DEBUG
  ...  INFO
  Logging With Timestamp
  ...  message=BTS Configuration Reset procedure on bts_id node=${bts_id} started.
  ...  style=ONGOING
  ${secondary_sm}=  Get Variable Value  ${CFG.NODES['${bts_id}']['secondary_sm']}  ${False}
  IF  '${secondary_sm}'!='None'
    ${secondary_sm_vm_ip_LMP_address}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  secondary_sm_vm_ip_LMP_address
  ELSE
    ${secondary_sm_vm_ip_LMP_address}=  Set Variable  ${None}
  END
  ${secondary_sm_vm_ip_LMP_address}=  Set Variable If  '${secondary_sm}'!='None'  ${secondary_sm_vm_ip_LMP_address}  ${None}
  ${reset_configuration_status}=  Run Keyword And Continue On Failure
  ...  rfrl_reset_conf.Reset Bts Configuration  connection=${bts_id}
  ...  secondary_remote_host=${secondary_sm_vm_ip_LMP_address}
  ...  fdsw_log_level=${fdsw_debug_logs_level}
  ...  fdsw_log_dir_path=${TEST_LOGS_PATH}BTSFiles/${bts_id}/
  ...  timeout=${RESET_CONFIGURATION_STARTUP_TIMEOUT}
  ...  reset_admin_connection=True
  ...  wait_for_admin_connection=True
  ...  wait_for_admin_connection_timeout=${RESET_CONFIGURATION_STARTUP_TIMEOUT}
  Logging With Timestamp
  ...  message=BTS Configuration Reset procedure on bts_id node=${bts_id} finished.
  ...  style=DONE
  Run Keyword And Ignore Error    Wait Until Keyword Succeeds  ${RESET_CONFIGURATION_STARTUP_TIMEOUT} sec  25 sec
    ...  admin.Reset Admin  connection=${bts_id}
  Logging With Timestamp
  ...  message=Wait for BTS reset
  ...  style=ONGOING
  ${reset_state}=  Run Keyword And Ignore Error
  ...  CM BTS Admin Not Available  node=${bts_id}  timeout=${RESET_CONFIGURATION_STARTUP_TIMEOUT}
  Logging With Timestamp
  ...  message=BTS reset finished
  ...  style=DONE
  [Teardown]  Run Keywords
  ...  Run Keyword And Ignore Error
  ...  rc.Teardown  connection=FDSW_PRIMARY_CONNECTION
  ...  AND
  ...  Run Keyword And Ignore Error
  ...  rc.Teardown  connection=FDSW_SECONDARY_CONNECTION
  [Return]  ${reset_configuration_status}  ${reset_state}

CM BTS Admin Not Available
  [Arguments]  ${node}  ${timeout}=120
  [Documentation]
  ...  Description:
  ...  Check if admin session is available.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | node                   | Yes  | BTS ID number                                                              |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | timeout                | No   | timeout for procedure                                                      |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Run Keyword And Continue On Failure
  ...  admin.Assert No  BTS  proceduralState=Initializing  connection=${node}  timeout=${timeout}
  Wait Until Keyword Succeeds  ${timeout}  5
  ...  Run Keyword And Return Status
  ...  admin.Assert No  class_name=BTS  connection=${node}

CM Perform Delta File Commissioning
  [Arguments]  ${bts_id}  ${delta_scf_file}  ${ignore_errors}=False
  [Documentation]
  ...  Description:
  ...  Performs delta scf recommissioning with user defined delta.json file.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | node                   | Yes  | BTS ID number                                                              |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | timeout                | No   | timeout for procedure                                                      |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Run Keyword And Ignore Error  admin.Wait Sw Update Possible
  ...  bts_ready=True
  ...  readiness_timeout=900
  ...  timeout=1000
  ...  connection=${bts_id}
  Logging With Timestamp
  ...  message=BTS Admin Perform Delta Recommissioning for BTS ID - ${bts_id} started.
  ...  style=ONGOING
  ${result}=  admin.Perform Delta Recommissioning
  ...  delta_file=${delta_scf_file}
  ...  skip_parameter_relation_errors=${ignore_errors}
  ...  should_activate=True
  ...  timeout=1200
  ...  connection=${bts_id}
  Logging With Timestamp
  ...  message=BTS Admin Perform Delta Recommissioning for BTS ID - ${bts_id} finished.
  ...  style=DONE
  [Return]  ${result}
