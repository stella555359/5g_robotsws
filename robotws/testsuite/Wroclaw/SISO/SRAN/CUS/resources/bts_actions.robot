*** Settings ***
Documentation  BTS Actions
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    taf.transport.ssh    WITH NAME    tafssh

Resource    ./setup_and_teardown.robot
Resource    ./common_keywords.robot
Resource    ./admin.robot
Resource    ./info_model_actions.robot
Resource    ../../resources/Robot/faults.robot
Resource    ../../resources/Robot/common_kw.robot

*** Keywords ***
BTS Power Reset
    [Arguments]  ${scfc_file_path}  ${list_of_cus_ips}  ${reset_index}
    ...  ${single_loop_logs}  ${allowed_alarms}  ${get_kpi}=False  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword performs one power BTS reset (PDU off/on).
    ...  Additionally kpi3 parameter can be calculated.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP.                                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | reset_index            | Yes  | Numer of resets.                                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | single_loop_logs       | Yes  | Collect logs from a single loop or do not collect.                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get kpi3 or not.                                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  |  log_to_console        |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  ${dots_prefix_green}Restart SMODs and wait for availability  console=${log_to_console}
    PDU Restart SMODs  number_of_smod_units=${NUMBER_OF_SMOD_UNIT}
    ${power_start_timestamp}=  Get Current Date  time_zone=UTC
    BTS Is Unavailable
    BTS Is Available  retry_timeout=300
    CUS Is Available  list_of_cus_ips=${list_of_cus_ips}  retry_timeout=300
    Log  ${ok_prefix_green}Restart SMODs and wait for availability  console=${log_to_console}
    ${big_config}=  Run Keyword And Return Status  Variable Should Exist  ${BIG_CONFIG_PATH}
    Run Keyword If  ${big_config}
    ...  Collect Infomodel Log From Current Session
    ...  target_file_name=${SUITE_LOGS_DIR_PATH}/${TEST NAME}/IM_infomodel_kpi_pre.ims2
    ...  timeout=120  leave_disconnect_logs=True
    # Reset Admin
    # Egate Reset Configuration
    Log  ${dots_prefix_green}RMODs Detection after power reset  console=${log_to_console}
    Radio Modules Detection  scfc_file_path=${scfc_file_path}  log_prefix=${info_prefix}
    Log  ${ok_prefix_green}RMODs Detection after power reset  console=${log_to_console}
    Log  ${dots_prefix_green}BTS should be OnAir  console=${log_to_console}
    Admin BTS Should Be OnAir After Power Reset  log_prefix=${info_prefix}
    Log  ${ok_prefix_green}BTS should be OnAir  console=${log_to_console}
    # Admin BTS Should Be Configured
    # Run  ip addr show | grep "11.7.255.254"
    # Egate Should Reach Active State  ${LUA_COMMON_DIR}
    #Admin BTS Should Be OnAir  cell_timeout=20
    Log  ${dots_prefix_green}Get kpi value  console=${log_to_console}
    ${kpi_list}=  Create List  kpi3
    ${kpi3_param}=  Create Dictionary  start_point_timestamp=${power_start_timestamp}
    ${kpi_params}=  Create dictionary  kpi3=${kpi3_param}
    ${kpi_dict}=  Run Keyword If  ${get_kpi}
    ...  Get Kpi Values  logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...  kpi_names=${kpi_list}  kpi_params=${kpi_params}
    Run Keyword If  ${get_kpi}
    ...  Log  ${info_prefix}KPI values: ${kpi_dict}  console=${log_to_console}
    ...  ELSE
    ...  Log  ${info_prefix}Kpi3 value calculation has been disabled  console=${log_to_console}
    Log  ${ok_prefix_green}Get kpi value  console=${log_to_console}
    Admin Check Inactive FaultId Alarms  6202  6150
    Admin Get And Check Active Alarms  allowed_alarms=${allowed_alarms}
    Log  ${ok_prefix_green}Admin check active alarms  console=${log_to_console}
    [Teardown]  Run Keyword If  ${single_loop_logs}
    ...  Run Keyword And Ignore Error
    ...  Teardown BTS Power Reset  list_of_cus_ips=${list_of_cus_ips}  reset_index=${reset_index}

BTS Perform Commissioning
    [Arguments]  ${bts_id}  ${scfc_file_path}  ${timeout}=300  ${relation_errors}=False
    ...  ${log_to_console}=True  ${log_prefix}=${EMPTY}
    [Documentation]
    ...  Description:
    ...  Keyword performs full commissioning.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bts_id                 | Yes  | Bts id number.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                | Yes  | Timeout for the commissioning operation.                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | relation_errors        |  No  | Skip parameter relation errors.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${commissioning_result}=  Perform Commissioning  bts_id=${bts_id}  scf_file=${scfc_file_path}
    ...  skip_parameter_relation_errors=${relation_errors}  should_activate=True  timeout=${timeout}
    Log  ${log_prefix}BTS full commissioning procedure on bts_id=${bts_id} finished  console=${log_to_console}

BTS Perform Commissioning With Hardware Error SCFC
    [Arguments]  ${bts_id}  ${fail_scfc_file_path}  ${timeout}=300  ${errors_number}=0
    ...  ${error_description}=${EMPTY}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword validates given failed SCFC file contains hardware errors and try to perform full commissioning.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bts_id                 | Yes  | Bts id number.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | fail_scfc_file_path    | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                | Yes  | Timeout for the commissioning operation.                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | errors_number          | Yes  | The number of expected hardware errors.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | error_description      | Yes  | Description of the expected error (text).                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${validate_result}=  Validate SCF  ${fail_scfc_file_path}  skip_parameter_relation_errors=True
    ${commissioning_result}=  Run Keyword And Expect Error  *${error_description}*
    ...  BTS Perform Commissioning  bts_id=${bts_id}  scfc_file_path=${fail_scfc_file_path}  timeout=${timeout}
    ${hardware_error_list}=  Set Variable  ${validate_result['pdlValidationResult']['logs']['hardwareErrors']}
    ${errors_number}=  Convert To Integer  item=${errors_number}
    ${hardware_errors_number}=  Get Length  item=${hardware_error_list}
    Should Be Equal  ${errors_number}  ${hardware_errors_number}
    Log  ${log_prefix}Invalid SCFC with ${hardware_errors_number} hardware errors has been detected  console=${log_to_console}
    Log  ${log_prefix}Commissioning with invalid SCFC has not been performed  console=${log_to_console}

BTS Perform Delta Recommissioning
    [Arguments]  ${scfc_file_path}  ${list_of_cus_ips}  ${json_delta_file}
    ...  ${recommissioning_timeout}=300  ${log_steps}=True
    [Documentation]
    ...  Description:
    ...  Keyword performs BTS delta recommissioning.
    ...  Keyword checks whether BTS is OnAir before delta commissioning and after delta commissioning.
    ...  Keyword checks whether all radio modules have been correctly detected before delta commissioning
    ...  and after delta commissioning.
    ...  After performing delta commissioning keyword checks if the parameters have been implemented correctly
    ...  in the current SCF.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP.                                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | json_delta_file        | Yes  | Path to the json delta file.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | recommissioning_timeout|  No  | Delta recommissioning timeout.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_steps              |  No  | Logs the given message to console.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  ${dots_prefix_green}BTS OnAir procedure  console=${log_steps}
    Admin BTS Should Be OnAir  log_prefix=${dots_prefix_green}
    Log  ${ok_prefix_green}BTS OnAir procedure  console=${log_steps}
    Log  ${dots_prefix_green}RMODs detection before delta recommissioning  console=${log_steps}
    Radio Modules Detection  scfc_file_path=${scfc_file_path}  log_prefix=${info_prefix}
    Log  ${ok_prefix_green}RMODs detection before delta recommissioning  console=${log_steps}
    Log  ${dots_prefix_green}Delta SCFC parameters before delta recommissioning  console=${log_steps}
    ${delta_params_dict_list}=  Get Delta Parameters From JSON File  json_delta_file=${json_delta_file}
    SCFC Show Parameters Value Based On JSON File  scfc_file_path=${scfc_file_path}
    ...  delta_params_dict_list=${delta_params_dict_list}  log_prefix=${info_prefix}
    Log  ${ok_prefix_green}Delta SCFC parameters before delta recommissioning  console=${log_steps}
    Log  ${dots_prefix_green}Perform delta recommissioning  console=${log_steps}
    admin.Perform Delta Recommissioning  delta_file=${json_delta_file}  timeout=${recommissioning_timeout}
    Log  ${ok_prefix_green}Perform delta recommissioning  console=${log_steps}
    Log  ${dots_prefix_green}Availability of BTS and IPHYs  console=${log_steps}
    BTS Is Available
    CUS Is Available  list_of_cus_ips=${list_of_cus_ips}
    Log  ${ok_prefix_green}Availability of BTS and CUS  console=${log_steps}
    Log  ${dots_prefix_green}RMODs detection after delta recommissioning  console=${log_steps}
    Radio Modules Detection  scfc_file_path=${scfc_file_path}  log_prefix=${info_prefix}
    Log  ${ok_prefix_green}RMODs detection after delta recommissioning  console=${log_steps}
    Log  ${dots_prefix_green}BTS OnAir procedure  console=${log_steps}
    ${delta_scfc_file_path}=  Set Variable  ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/
    admin.Get Current Scf File  local_dir_path=${delta_scfc_file_path}  file_name=delta_scfc.xml  timeout=60
    BTS SCFC And Admin Cells Count Should Match  scfc_file_path=${delta_scfc_file_path}/delta_scfc.xml
    Admin BTS Should Be OnAir  cell_timeout=60  log_prefix=${info_prefix}
    Log  ${ok_prefix_green}BTS OnAir procedure  console=${log_steps}
    Log  ${dots_prefix_green}Delta SCFC parameters after delta recommissioning  console=${log_steps}
    SCFC Verify Parameters Value Obtained From JSON File  scfc_file_path=${delta_scfc_file_path}/delta_scfc.xml
    ...  delta_params_dict_list=${delta_params_dict_list}  log_prefix=${info_prefix}
    Log  ${ok_prefix_green}Delta SCFC parameters after delta recommissioning  console=${log_steps}

BTS Perform Parameter Recommissioning
    [Arguments]  ${dist_name}  ${parameter}  ${param_value}  ${operation}  ${connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword performs parameter recommissioning and gets recommissioned parameter value.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | dist_name              | Yes  | Recommissioned object dist name.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | parameter              | Yes  | Parameter for recommissioning.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | param_value            | Yes  | Parameter value for recommissioning.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | operation              | Yes  | Parameter operation - update or delete.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | connection             |  No  | Name of admin connection object.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    admin.Perform Parameter Recommissioning  dist_name=${dist_name}  parameter=${parameter}
    ...  value=${param_value}  operation=${operation}  connection=${connection}
    admin.Get Current Scf File  local_dir_path=${SUITE_LOGS_DIR_PATH}/${TEST NAME}/
    ...  file_name=scf_${param_value}.xml  connection=${connection}
    ${parameter_value}=  Evaluate Xpath  ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/scf_${param_value}.xml
    ...  string(.//managedObject[contains(@distName, "FEATCADM")]/p[@name="actRatResetEnhancement"])
    [Return]  ${parameter_value}

BTS Verify Hardware
    [Arguments]  ${scfc_file_path}  ${bts_rat_list}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword verifies whether BTS hardware and RATs has been detected correctly.
    ...  Keyword verifies the following BTS hardware: SMODs, BBMODs, RMODs.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bts_rat_list           | Yes  | BTS rat list, e.g. [lte, nr].                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com
    ...  Last update: jakub.pachana@nokia.com

    ${smod_state}=  BTS Verify All Hardware Unit State  class_name=SMOD  state=operationalState
    ...  state_value=enabled  timeout=500
    Log  ${log_prefix}All SMODs operational state is ${smod_state} now  console=${log_to_console}
    ${bbmod_exist}=  Run Keyword And Return Status  admin.Assert Every  class_name=BBMOD
    ...  parameters=operationalState=regex".*"  timeout=60
    ${bbmod_state}=  Run Keyword If  "${bbmod_exist}"=="True"
    ...  BTS Verify All Hardware Unit State  class_name=BBMOD  state=operationalState
    ...  state_value=enabled  timeout=500
    Run Keyword If  "${bbmod_exist}"=="True"
    ...  Log  ${log_prefix}All BBMODs operational state is ${bbmod_state} now  console=${log_to_console}
    ...  ELSE
    ...  Log  ${log_prefix}BBMODs not exist in this configurtion  console=${log_to_console}
    Radio Modules Detection  scfc_file_path=${scfc_file_path}  log_prefix=${info_prefix}  log_to_console=False
    Log  ${log_prefix}All RMODs have been detected  console=${log_to_console}
    BTS Wait For Expected Every Rat State  bts_rat_list=${bts_rat_list}
    ...  rat_state_value=ALL_ENABLED  timeout=1000
    Log  ${log_prefix}All BTS RATs state is enabled now  console=${log_to_console}

BTS Perform Rat Reset
    [Arguments]  ${act_rat_reset_enhancement}  ${rat_type}  ${reset_type}  ${ims_log_path}  ${timeout}
    [Documentation]
    ...  Description:
    ...  Keyword performs RAT reset procedure and collects InfoModel log from current session.
    ...
    ...  Arguments:
    ...  +============================+======+========================================================================+
    ...  | Argument                   | Man. | Description                                                            |
    ...  +============================+======+========================================================================+
    ...  | act_rat_reset_enhancement | Yes  | Enhancements to RAT reset operation are enabled or not.                 |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...  | rat_type                  | Yes  | RAT name: 5G, LTE, WCDMA or GSM.                                        |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...  | reset_type                | Yes  | Reset type - Soft or Hard. Default value is Soft.                       |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...  | timeout                   | Yes  | Timeout for the RAT reset operation.                                    |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${impacted_objects}  ${not_impacted_objects}=  Run Keyword If  "${act_rat_reset_enhancement}"=="true" and "${reset_type}"=="Soft"
    ...  Get Objects Affected By Isolated Rat Reset  rat_type=${rat_type}
    ...  ELSE
    ...  Get Objects Affected By CB008880  rat_type=${rat_type}
    admin.Rat Reset  rat_type=${rat_type}  reset_type=${reset_type}  timeout=${timeout}
    Sleep  120s  Wait for BTS stabilize after RAT reset
    admin.Collect Infomodel Log From Current Session  target_file_name=${ims_log_path}
    [Return]  ${impacted_objects}  ${not_impacted_objects}

BTS Cell Block Unblock And Check
    [Arguments]  ${scfc_file_path}  ${lcr_id}  ${lncel_id}  ${get_kpi}=False
    ...  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword blocks and unblocks cell with specified lcrid ${lcr_id} and lncelid ${lncel_id},
    ...  checks in Admin if operation succeded and checks the appropriate alarms.
    ...  If the cell with specified lcrid ${lcr_id} and lncelid ${lncel_id} also has a nbiot cell
    ...  (e.g. inband, guardband), appropriate states (e.g. blockingState) and alarms (e.g. faultId=49) are checked.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lcr_id                 | Yes  | Lcr id of the cell to be blocked.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lncel_id               | Yes  | LNCEL id of the cell to be blocked.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get KPIs (17a,17b) or not.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${lncel_id_list}=  Create List  ${lncel_id}
    ${lcr_id_list}=  Create List  ${lcr_id}
    ${nrcell_id}=  SCFC Get NrcellId For eNB LcrId After Dss Sharing Activation  scfc_file_path=${scfc_file_path}  lcr_id=${lcr_id}
    ${nrcell_distname}=  Run Keyword If  '${nrcell_id}'!='${EMPTY}'
    ...  Get Cell Id By Configuration Id  rat=NR  configuration_id=${nrcell_id}
    ${lncel_distname_list}=  Create List
    ${nbiot_lcr_id_list}=  SCFC Create IoT Linked LcrId List
    ...  scfc_file_path=${scfc_file_path}  lcr_id_list=${lcr_id_list}
    ${nbiot_lncel_id_list}=  SCFC Create LncelId List For LcrdId List
    ...  scfc_file_path=${scfc_file_path}  lcr_id_list=${nbiot_lcr_id_list}
    Append To List  ${lncel_id_list}  @{nbiot_lncel_id_list}
    ${lncel_id_list}=  Convert List to Integer  list_to_convert=${lncel_id_list}
    FOR  ${lncel_r_id}  IN  @{lncel_id_list}
      ${lncel_distname}=  Get Cell Id By Configuration Id  rat=LTE  configuration_id=${lncel_r_id}
      Append To List  ${lncel_distname_list}  ${lncel_distname}
    END
    admin.Block Cell  dist_name=${lncel_distname_list[0]}  timeout=120
    ${faultId}=  Set Variable  regex"7513|7511"
    ${faultName}=  Set Variable  regex"EN DSS De-activated on partner side|EN DSS Keep Alive Procedure Time out"
    Log  ${log_prefix}Cells ${lncel_id_list} state after Block command (blockingState):  console=${log_to_console}
    FOR  ${lncel_distname}  IN  @{lncel_distname_list}
      admin.Assert  class_name=LNCEL  id=${lncel_distname}  parameters=blockingState=regex"(?i)Blocked"
      admin.Assert Alarm Active  faultId=49, severity=Critical, faultName="Cell blocked", alarmingResource=${lncel_distname}
      Run Keyword If  '${nrcell_id}'!='${EMPTY}'
      ...  admin.Assert Alarm Active  faultId=${faultId}, severity=Major, faultName=${faultName}, alarmingResource=${nrcell_distname}
      ${lncel_params}=  admin.Get Parameters For  class_name=LNCEL  id_num=${lncel_distname}
      Log  ${log_prefix}LNCEL (${lncel_params.technology}) ${lncel_params.id} is ${lncel_params.blockingState}
      ...  console=${log_to_console}
    END
    admin.Unblock Cell  dist_name=${lncel_distname_list[0]}  timeout=120
    Log  ${log_prefix}Cells ${lncel_id_list} state after Unblock command (blockingState):  console=${log_to_console}
    FOR  ${lncel_distname}  IN  @{lncel_distname_list}
      admin.Assert  class_name=LNCEL  id=${lncel_distname}  parameters=blockingState=regex"(?i)Unblocked"
      admin.Assert Alarm Inactive  faultId=49, severity=Critical, faultName="Cell blocked", alarmingResource=${lncel_distname}
      Run Keyword If  '${nrcell_id}'!='${EMPTY}'
      ...  Assert Alarm Inactive  faultId=${faultId}, severity=Major, faultName=${faultName}, alarmingResource=${nrcell_distname}
      ${lncel_params}=  admin.Get Parameters For  class_name=LNCEL  id_num=${lncel_distname}
      Log  ${log_prefix}LNCEL (${lncel_params.technology}) ${lncel_params.id} is ${lncel_params.blockingState}
      ...  console=${log_to_console}
    END
    Return From Keyword If  not ${get_kpi}
    Sleep  5
    ${kpi_list}=  Create List  kpi17a  kpi17b
    ${kpi_dict}=  Get Kpi Values  logs_dir_path=${SUITE_LOGS_DIR_PATH}  kpi_names=${kpi_list}
    Log  ${log_prefix}KPI values: ${kpi_dict}  console=${log_to_console}

BTS Cells Block Unblock And Check
    [Arguments]  ${scfc_file_path}  ${lcr_id_block_list}=ALL  ${get_kpi}=False  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword prepares a list of cells to perform block and unblock procedure.
    ...  The cell list is read from the SCFC file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lcr_id_block_list      |  No  | The list of cells to block.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get kpis (kpi17a, kpi17b) or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  not ${get_kpi}
    ...  Log  ${info_prefix}KPIs will not be calculated  console=${log_to_console}
    ${cells_count}=  SCFC Get Cells Count  scfc_file_path=${scfc_file_path}
    ${lcr_id_list}=  SCFC Create LcrId List  scfc_file_path=${scfc_file_path}
    ${all_list_status}=  Run Keyword And Return Status
    ...  List Should Contain Value  ${lcr_id_block_list}  ALL
    ${random_list_status}=  Run Keyword And Return Status
    ...  List Should Contain Value  ${lcr_id_block_list}  RANDOM
    ${lcr_id_list}=  Run Keyword If  ${all_list_status}
    ...  Copy List  ${lcr_id_list}
    ...  ELSE IF  ${random_list_status}
    ...  Get Random List Based On Input List  list=${lcr_id_list}  length=${lcr_id_block_list[1]}
    ...  ELSE
    ...  Create List  @{lcr_id_block_list}
    ${lcr_id_list}=  Convert List to Integer  list_to_convert=${lcr_id_list}
    Sort List  ${lcr_id_list}
    Log  ${dots_prefix_green}The following cells (lcrid) will be blocked/unblocked: ${lcr_id_list}
    ...  console=${log_to_console}
    ${lcr_id_list}=  Convert List to String  list_to_convert=${lcr_id_list}
    ${lncel_id_list}=  SCFC Create LncelId List For LcrdId List
    ...  scfc_file_path=${scfc_file_path}  lcr_id_list=${lcr_id_list}
    ${lcr_id_not_iot_inband_guardband_list}=  SCFC Create Not IoT Inband And Guardband LcrId List
    ...  scfc_file_path=${scfc_file_path}
    FOR  ${lcr_id}  IN RANGE  ${cells_count}
      ${result_not_iot_inband_guardband}=  Run Keyword And Return Status
      ...  List Should Contain Value  ${lcr_id_not_iot_inband_guardband_list}  ${lcr_id_list[${lcr_id}]}
      Run Keyword If  ${result_not_iot_inband_guardband}
      ...  BTS Cell Block Unblock And Check  scfc_file_path=${scfc_file_path}
      ...  lcr_id=${lcr_id_list[${lcr_id}]}  lncel_id=${lncel_id_list[${lcr_id}]}
      ...  get_kpi=${get_kpi}  log_prefix=${info_prefix}
    END

BTS Start Data Sync With Neighbor Node
    [Documentation]
    ...  Description:
    ...  Keyword starts data sync with neighbor node.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${neighbor_node_dist_name}=  Info Model Get Dist Name Of
    ...  object_name=//RUNTIME_VIEW-1/MRBTS_R-1/NEIGHBOR_NODE_R-*  timeout=300
    Start Sync  ${neighbor_node_dist_name}

BTS Enable Connection
    [Documentation]
    ...  Description:
    ...  Keyword enables ssh connection to BTS and disables ethernet port security.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  300  10  Disable Ethernet Port Security
    Wait Until Keyword Succeeds  300  10  Enable Ssh Access

BTS Collect Hardware Information
    [Documentation]
    ...  Description:
    ...  Keyword collects information about installed hardware.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword And Ignore Error  BTS Get System Modules Hardware Information
    Run Keyword And Ignore Error  BTS Get Baseband Modules Hardware Information
    Run Keyword And Ignore Error  BTS Get Radio Modules Hardware Information
    Run Keyword And Ignore Error  BTS Get SFP Hardware Version

BTS Get System Module Serial Number List
    [Documentation]
    ...  Description:
    ...  Keyword returns system module serial number list.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${bts_info}=  Get Bts Info  timeout=240
    ${sm_list}=  Create List
    FOR  ${sm_element}  IN  @{bts_info['systemModules']}
      Append To List  ${sm_list}  ${sm_element['serialNumber']}
    END
    [Return]  ${sm_list}

BTS Get Baseband Serial Number List
    [Documentation]
    ...  Description:
    ...  Keyword returns baseband module serial number list.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${bts_info}=  Get Bts Info  timeout=240
    ${bbmod_list}=  Create List
    FOR  ${bbmod_element}  IN  @{bts_info['basebandModules']}
      Append To List  ${bbmod_list}  ${bbmod_element['serialNumber']}
    END
    [Return]  ${bbmod_list}

BTS Get Baseband Modules Serial Number And Id
    [Documentation]
    ...  Keyword returns a dictionary of serial numbers and ids of baseband modules.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${bbmod_dict}=  Create Dictionary
    ${bbmods_params}=  Get Parameters For All  class_name=BBMOD
    FOR  ${bbmod_params}  IN  @{bbmods_params}
      Set To Dictionary  ${bbmod_dict}  ${bbmod_params['serialNumber']}=${bbmod_params['id']}
    END
    [Return]  ${bbmod_dict}

BTS Get Radio Module Serial Number List
    [Documentation]
    ...  Description:
    ...  Keyword returns radio module serial number list.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${bts_info}=  Get Bts Info  timeout=240
    ${rm_list}=  Create List
    FOR  ${rm_element}  IN  @{bts_info['radioModules']['rmod']}
      Append To List  ${rm_list}  ${rm_element['serialNumber']}
    END
    [Return]  ${rm_list}

BTS Get Radio Modules Serial Number And Id
    [Documentation]
    ...  Keyword returns a dictionary of serial numbers and ids of radio modules.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmod_dict}=  Create Dictionary
    ${rmods_params}=  Get Parameters For All  class_name=RMOD
    FOR  ${rmod_params}  IN  @{rmods_params}
      Set To Dictionary  ${rmod_dict}  ${rmod_params['serialNumber']}=${rmod_params['id']}
    END
    [Return]  ${rmod_dict}

BTS Get Hardware Information
    [Documentation]
    ...  Description:
    ...  Keyword returns dictionary of installed hardware.
    ...  Keyword returns serial numbers of:
    ...  - system modules
    ...  - baseband modules
    ...  - radio modules
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${hw_dict}=  Create Dictionary
    ${bbmod_list}=  BTS Get Baseband Serial Number List
    ${smod_list}=  BTS Get System Module Serial Number List
    ${rmod_list}=  BTS Get Radio Module Serial Number List
    Set To Dictionary  dictionary=${hw_dict}  hw_smod_list=${smod_list}
    ...  hw_bbmod_list=@{bbmod_list}  hw_rmod_list=${rmod_list}
    [Return]  ${hw_dict}

BTS Get System Modules Hardware Information
    [Arguments]  ${log_to_console}=False
    [Documentation]
    ...  Description:
    ...  Keyword returns information (product name, product code, serial number) about installed
    ...  system modules hardware.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${bts_info}=  Get Bts Info  timeout=240
    ${sm_number}=  Get Length  item=${bts_info['systemModules']}
    ${info_string}=  Set Variable  \nThe number of system modules: ${sm_number}\n\n
    FOR  ${sm_element}  IN  @{bts_info['systemModules']}
      ${info_string}=  Catenate  ${info_string}  Product name: ${sm_element['productName']}\n
      ${info_string}=  Catenate  ${info_string}  Product Code: ${sm_element['productCode']}\n
      ${info_string}=  Catenate  ${info_string}  Serial Number: ${sm_element['serialNumber']}\n\n
    END
    Log  ${info_string}  console=${log_to_console}

BTS Get Baseband Modules Hardware Information
    [Arguments]  ${log_to_console}=False
    [Documentation]
    ...  Description:
    ...  Keyword returns information (product name, product code, serial number) about installed
    ...  baseband modules hardware.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | log_to_console         | No   | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${bts_info}=  Get Bts Info  timeout=240
    ${bbmod_number}=  Get Length  item=${bts_info['basebandModules']}
    ${info_string}=  Set Variable  \nThe number of baseband modules: ${bbmod_number}\n\n
    FOR  ${bbmod_element}  IN  @{bts_info['basebandModules']}
      ${info_string}=  Catenate  ${info_string}  Product name: ${bbmod_element['productName']}\n
      ${info_string}=  Catenate  ${info_string}  Product Code: ${bbmod_element['productCode']}\n
      ${info_string}=  Catenate  ${info_string}  Serial Number: ${bbmod_element['serialNumber']}\n\n
    END
    Log  ${info_string}  console=${log_to_console}

BTS Get Radio Modules Hardware Information
    [Arguments]  ${log_to_console}=False
    [Documentation]
    ...  Description:
    ...  Keyword returns information (product name, product code, serial number) about installed
    ...  radio modules hardware.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${bts_info}=  Get Bts Info  timeout=240
    ${rmod_number}=  Get Length  item=${bts_info['radioModules']['rmod']}
    ${info_string}=  Set Variable  \nThe number of radio modules: ${rmod_number}\n\n
    FOR  ${rmod_element}  IN  @{bts_info['radioModules']['rmod']}
      ${info_string}=  Catenate  ${info_string}  Product name: ${rmod_element['productName']}\n
      ${info_string}=  Catenate  ${info_string}  Product Code: ${rmod_element['productCode']}\n
      ${info_string}=  Catenate  ${info_string}  Serial Number: ${rmod_element['serialNumber']}\n\n
    END
    Log  ${info_string}  console=${log_to_console}

BTS Get SFP Hardware Version
    [Arguments]  ${log_to_console}=False
    [Documentation]
    ...  Description:
    ...  Keyword returns information (serial number, vendor part number, compliance code) about installed SFP hardware.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | log_to_console         | No   | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${sfp_links}=  Get Sfp Links
    ${cablink_number}=  Get Length  item=${sfp_links['connected']}
    ${info_string}=  Set Variable    \nThe number of cablinks: ${cablink_number}\n\n
    FOR  ${cablink_element}  IN  @{sfp_links['connected']}
      ${info_string}=  Catenate  ${info_string}
       ...  Link source:${cablink_element['data']['linkPorts']['source']}\n
      ${info_string}=  Catenate  ${info_string}
       ...  Link destination:${cablink_element['data']['linkPorts']['destination']}\n
      ${info_string}=  Catenate  ${info_string}
       ...  Destination:${cablink_element['destination']}\n
      ${info_string}=  Catenate  ${info_string}
       ...  SFP serial number:${cablink_element['details']['hardwareParams']['serialNumber']['destination']}\n
      ${info_string}=  Catenate  ${info_string}
       ...  SFP vendor part number:${cablink_element['details']['hardwareParams']['vendorPartNumber']['destination']}\n
      ${info_string}=  Catenate  ${info_string}
       ...  SFP compliance code:${cablink_element['details']['hardwareParams']['complianceCode']['destination']}\n\n
    END
    Log  ${info_string}  console=${log_to_console}

BTS Radio Module Reset
    [Arguments]  ${scfc_file_path}  ${rmod_serial_number}  ${log_to_console}=True  ${log_prefix}=${EMPTY}
    [Documentation]
    ...  Description:
    ...  Keyword performs radio module reset.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_serial_number     | Yes  | Serial number of radio module to reset.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  |  log_to_console        |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmod_dict}=  BTS Get Radio Modules Serial Number And Id
    ${rmod_distname}=  Get From Dictionary  ${rmod_dict}  ${rmod_serial_number}
    Log  ${log_prefix}Radio module reset is performed. Please wait ...  console=${log_to_console}
    Reset Unit  dist_name=${rmod_distname}  reset_type=Soft  timeout=180
    Radio Modules Detection  scfc_file_path=${scfc_file_path}  log_prefix=${log_prefix}
    Admin BTS Should Be OnAir  log_prefix=${log_prefix}

BTS Baseband Module Reset
    [Arguments]  ${bbmod_serial_number}  ${timeout}=500
    [Documentation]
    ...  Description:
    ...  Keyword performs baseband module reset given by serial number.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bbmod_serial_number    | Yes  | Serial number of baseband module to reset.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                | No   | Timeout for the reset operation.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${bbmod_dict}=  BTS Get Baseband Modules Serial Number And Id
    ${bbmod_distname}=  Get From Dictionary  ${bbmod_dict}  ${bbmod_serial_number}
    ${reset_status}=  Reset Unit  dist_name=${bbmod_distname}  reset_type=Warm
    ...  timeout=${timeout}  detailed_output=True
    [Return]  ${reset_status}

BTS Detect Site Hardware And Get OnAir
    [Arguments]  ${scfc_file_path}  ${list_of_cus_ips}  ${bts_retry_timeout}=120  ${cus_retry_timeout}=240
    ...  ${rmod_timeout}=${FR_DETECTION_TIMEOUT_AFTER_BTS_RESET}  ${cell_timeout}=700  ${bts_timeout}=1300
    ...  ${log_to_console}=True  ${log_prefix}=${EMPTY}
    [Documentation]
    ...  Description:
    ...  Keyword detect all site hardware (SMODs, RMODs, CUS) and wait for OnAir.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP.                                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bts_retry_timeout      | Yes  | Time to detect (ping) all BTS units.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cus_retry_timeout      | Yes  | Time to detect (ping) all CUS units.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_timeout           | Yes  | Waiting time for RMOD detection.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cell_timeout           | Yes  | Waiting time for cells expected states.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bts_timeout            | Yes  | Waiting time for BTS expected procedural state.                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    BTS Is Available  retry_timeout=${bts_retry_timeout}
    Log  ${log_prefix}BTS is available (pingable)  console=${log_to_console}
    CUS Is Available  list_of_cus_ips=${list_of_cus_ips}  retry_timeout=${cus_retry_timeout}
    Log  ${log_prefix}All CUS are available (pingable)  console=${log_to_console}
    Radio Modules Detection  scfc_file_path=${scfc_file_path}  timeout=${rmod_timeout}
    ...  log_prefix=${log_prefix}
    BTS SCFC And Admin Cells Count Should Match  scfc_file_path=${scfc_file_path}
    Admin BTS Should Be OnAir  cell_timeout=${cell_timeout}  bts_timeout=${bts_timeout}
    ...  log_prefix=${log_prefix}

BTS Get Enabled Rat List
    [Documentation]
    ...  Description:
    ...  Keyword gets the list of enabled BTS rats.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${bts_enabled_rat_list}=  Create List
    ${bts_info}=  Get Bts Info  timeout=240
    ${bts_rat_list}=  Get Dictionary Keys  dictionary=${bts_info['ratState']}
    FOR  ${bts_rat}  IN  @{bts_rat_list}
      ${rat_state}=  Get From Dictionary  dictionary=${bts_info['ratState']}  key=${bts_rat}
      Run Keyword If  '${rat_state}'=='ALL_ENABLED'
      ...  Append To List  ${bts_enabled_rat_list}  ${bts_rat}
    END
    [Return]  ${bts_enabled_rat_list}

BTS Get Every Rat State
    [Arguments]  ${bts_rat_list}
    [Documentation]
    ...  Description:
    ...  Keyword returns the BTS rat and state dictionary (e.g. 'lte': 'ALL_ENABLED').
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bts_rat_list           | Yes  | BTS rat list, e.g. [lte, nr].                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rat_state_dict}=  Create Dictionary
    ${bts_info}=  Get Bts Info  timeout=240
    FOR  ${bts_rat}  IN  @{bts_rat_list}
      ${rat_state}=  Get From Dictionary  dictionary=${bts_info['ratState']}  key=${bts_rat}
      Set To Dictionary  ${rat_state_dict}  ${bts_rat}=${rat_state}
    END
    [Return]  ${rat_state_dict}

BTS Check Every Rat State
    [Arguments]  ${bts_rat_list}  ${rat_state_value}
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the state of BTS rat from list has the expected state.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bts_rat_list           | Yes  | BTS rat list, e.g. [lte, nr].                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rat_state_value        | Yes  | Expected BTS rat state value.                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rat_state_dict}=  BTS Get Every Rat State  bts_rat_list=${bts_rat_list}
    ${bts_rat_list}=  Get Dictionary Keys  dictionary=${rat_state_dict}
    FOR  ${bts_rat}  IN  @{bts_rat_list}
      ${rat_state}=  Get From Dictionary  dictionary=${rat_state_dict}  key=${bts_rat}
      Should Be True  condition='${rat_state}' == '${rat_state_value}'   msg=[!] BTS RAT '${bts_rat}' state is not enabled !!!
    END

BTS Wait For Expected Every Rat State
    [Arguments]  ${bts_rat_list}  ${rat_state_value}  ${timeout}=900
    [Documentation]
    ...  Description:
    ...  Keyword confirms if BTS rat state has the expected state.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bts_rat_list           | Yes  | BTS rat list, e.g. [lte, nr].                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rat_state_value        | Yes  | Expected BTS rat state value.                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                | No  | Time to wait for expected BTS rat state.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword And Continue On Failure
    ...  Wait Until Keyword Succeeds  ${timeout}  5
    ...  BTS Check Every Rat State  bts_rat_list=${bts_rat_list}  rat_state_value=${rat_state_value}

BTS Remove Radios Licenses
    [Arguments]  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword removes radios licenses (MAC) from BTS.
    ...
    ...  Author: jakub.pachana@nokia.com
    ...  Maintainer: jakub.pachana@nokia.com

    Log  ${dots_prefix_blue}Remove Radios Licenses from BTS  console=${log_to_console}
    Run Keyword And Ignore Error
    ...  tafssh.Execute
    ...  command=rm /ffs/run/config/radio-dhcpd/*
    ...  connection=${FSM_CONNECTION}
    PDU Restart SMODs  number_of_smod_units=${NUMBER_OF_SMOD_UNIT}
    BTS Is Unavailable
    BTS And CUS Are Accessible  list_of_cus_ips=${list_of_cus_ips}
    Log  ${ok_prefix_blue}Remove Radios Licenses from BTS  console=${log_to_console}

FDSW Software Update
    [Arguments]  ${yaft_local_dir}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    ${yaft_status}=  Yaft Get Existence Status  yaft_local_dir=${yaft_local_dir}
    Run Keyword If  '${yaft_status}'=='False'  Run Keywords
    ...  Yaft Svn Download  yaft_local_dir=${yaft_local_dir}
    ...  AND  Log  ${log_prefix}Yaft software has been downloaded  console=${log_to_console}
    ...  ELSE  Log  ${log_prefix}Yaft software download is not needed  console=${log_to_console}
    ${fdsw_version}=  Set Variable  LN_WN_FDSW25B_0000_000063_000000
    ${fdsw_file}=  Set Variable  ${fdsw_version}_release_BTSSM_downloadable.zip
    Run Keyword And Ignore Error  Run  command=python -m pip install paramiko
    FDSW Download Software  fdsw_version=${fdsw_version}  fdsw_file=${fdsw_file}  yaft_local_dir=${yaft_local_dir}  log_prefix=${info_prefix}
    ${check_update}=  Run Keyword And Return Status
    ...  FDSW Perform Software Update  fdsw_file=${fdsw_file}  yaft_local_dir=${yaft_local_dir}  log_prefix=${info_prefix}
    Run Keyword If  ${check_update}
    ...  Log  ${log_prefix}FDSW software version is "${fdsw_version}"  console=${log_to_console}

FDSW Perform Software Update
    [Arguments]  ${fdsw_file}  ${yaft_local_dir}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    Log  ${log_prefix}FDSW software update is preforming now ...  console=${log_to_console}
    Run Keyword And Ignore Error
    ...  Run  command=sshpass -p oZPS0POrRieRtu scp /home/ute/.ssh/toor4nsn/id_rsa.pub toor4nsn@192.168.255.129:.ssh/authorized_keys
    ${yaft_result}=  Run  command=python ${yaft_local_dir}/yaft.py -v -i 192.168.255.129 -z ${yaft_local_dir}/${fdsw_file} --flash_failsafe_partition
    ${yaft_status}=  Run Keyword And Return Status  Should Match Regexp  string=${yaft_result}  pattern=Flashing done\nYAFT exit code: 0
    Run Keyword If  ${yaft_status}
    ...  Log  ${log_prefix}FDSW software update has finished successfully  console=${log_to_console}
    ...  ELSE
    ...  Log  ${log_prefix}FDSW software update has failed  console=${log_to_console}

FDSW Download Software
    [Arguments]  ${fdsw_version}  ${fdsw_file}  ${yaft_local_dir}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    Log  ${log_prefix}FDSW software is downloading now ...  console=${log_to_console}
    ${download_link}=  Set Variable
    ...  https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-fdsw-central-public-local/build/FDSW25B/${fdsw_version}/${fdsw_file}
    ${wget_status}=  Run  wget -P ${yaft_local_dir} ${download_link}
    ${wget_status}=  Run Keyword And Return Status  Should Match Regexp  string=${wget_status}  pattern=100%
    Run Keyword If  ${wget_status}
    ...  Log  ${log_prefix}Yaft software download has finished successfully  console=${log_to_console}
    ...  ELSE
    ...  Log  ${log_prefix}Yaft software download has failed  console=${log_to_console}

FDSW Get Software Version Status
    [Arguments]  ${fdsw_version}
    tafssh.Execute
    ...  command=systemctl start ffs-fs3.mount
    ...  connection=${FSM_CONNECTION}
    ${fs3_result}=  tafssh.Execute
    ...  command=ls /ffs/fs3
    ...  connection=${FSM_CONNECTION}
    tafssh.Execute
    ...  command=systemctl stop ffs-fs3.mount
    ...  connection=${FSM_CONNECTION}
    ${fdsw_output}=  Get Lines Containing String  ${fs3_result}  FDSW
    Log  ${fdsw_output}
    ${current_version}  Create List
    FOR  ${version}  IN  @{fdsw_version}
      Run Keyword If  '${version}' in """${fdsw_output}"""
      ...  Append To List  ${current_version}  ${version}
    END
    Log  ${current_version}
    ${fdsw_version_status}=  Run Keyword And Return Status
    ...  Length Should Be  ${current_version}  1
#    ${fdsw_version_status}=  Run Keyword And Return Status
#    ...  Should Contain  container=${fs3_result}  item=${fdsw_version}
    [Return]  ${fdsw_version_status}  ${current_version}

#NOT USED
#PDU Restart SMOD And CUS And Wait For Availability
#    [Arguments]  ${list_of_cus_ips}  ${number_of_smod_units}
#    [Documentation]
#    ...  Description:
#    ...  Keyword restart all SMOD units and all CUS units and wait for availability.
#    ...
#    ...  Arguments:
#    ...  +========================+======+============================================================================+
#    ...  | Argument               | Man. | Description                                                                |
#    ...  +========================+======+============================================================================+
#    ...  | list_of_cus_ips        | Yes  | List of CUS IP addresses.                                                  |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | number_of_smod_units   | Yes  | Number of SMOD units.                                                      |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...
#    ...  Author: slawomir.jastrzebski@nokia.com
#    ...  Maintainer: slawomir.jastrzebski@nokia.com
#
#    FOR  ${smod_unit}  IN RANGE  ${number_of_smod_units}
#      PDU Restart SMOD  smod_index=${smod_unit+1}
#    END
#    BTS Is Unavailable
#    FOR  ${cus_ip}  IN  @{list_of_cus_ips}
#      ${cus_index}=  Fetch From Right  string=${cus_ip}  marker=.
#      ${cus_index}=  Convert To Integer  item=${cus_index}
#      PDU Restart CUS  cus_index=${cus_index}
#    END
#    BTS Is Available  retry_timeout=300
#    CUS Is Available  list_of_cus_ips=${list_of_cus_ips}  retry_timeout=300
