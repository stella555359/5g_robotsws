*** Settings ***
Documentation
    ...  PM_Memory_Consumption_Verification_On_FHS
    ...  AUTHOR-izabela.wencel@nokia.com  MAINTAINER-izabela.wencel@nokia.com
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-22128
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  Step 1 Preconditions For Memory Consumption Of FHS
    ...  Step 2 Initial Verification Of Memory Consumption Of FHS
    ...  Step 3 Execute Actions Without BTS Nor FHS Reset
    ...  Step 4 Final Verification Of Memory Consumption Of FHS
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  08.04.2025 - Initial creation

Resource  ./../../Resources/Robot/CM.robot
Resource  ./../../Resources/Robot/STATE.robot
Resource  ./../../Resources/Robot/SWM.robot

*** Variables ***
${CUSTOM_FDSW_DEBUG_LOGS}    False
${CONFIGURATION_STARTUP_TIMEOUT}    600
@{CHOSEN_FHSS}  all                            # default value: all
${MEMORY_CONSUMPTION_THRESHOLD}=    80         # Optional. Provide number without % to show how much % is the max allowed memory consumption.
${PRIMARY_SM_IP}  192.168.255.129
${SECONDARY_SM_IP}  192.168.255.119
${BREAK_AFTER_CELL_BLOCK_UNBLOCK}  300s        # Optional. Tester may add this variable to change this time.
${RU_RESET_ITERATIONS}  3                      # Optional. Tester may add this variable to change the amount of iterations.
${BREAK_AFTER_RU_RESET}  300s                  # Optional. Tester may add this variable to change this time.
${BREAK_IDLE_TIME}  20m                        # Optional. Tester may add this variable to change this time.

@{FAULT_10}  7116 BASE STATION SERVICE PROBLEM
@{FAULT_49}  7102 BASE STATION RESOURCE BLOCKED BY USER

*** Keywords ***
TC__PM_Memory_Consumption_Verification_On_FHS
    [Tags]    AUTHOR-izabela.wencel@nokia.com    MAINTAINER-izabela.wencel@nokia.com
    tc_setup_teardown.Common Test Setup
    Logging With Timestamp
    ...  message=Execute Recommissioning On Every Node on list : @{CFG.active_bts_list} will be executed
    ...  style=ONGOING
    Step 1 Preconditions For Memory Consumption Of FHS
    FOR    ${bts_id}    IN    @{CFG.active_bts_list}
      Step 2 Initial Verification Of Memory Consumption Of FHS
      Step 3 Execute Actions Without BTS Nor FHS Reset  ${bts_id}
      Step 4 Final Verification Of Memory Consumption Of FHS
    END
    [Teardown]  tc_setup_teardown.Common Test Teardown

Step 1 Preconditions For Memory Consumption Of FHS
    [Documentation]
    ...  Description:
    ...  This keyword sets up the preconditions for verifying memory consumption of FHS.
    ...  It initializes necessary variables, retrieves FHS-related data, and prepares dictionaries for further steps.
    ...  The keyword ensures that all required FHS and RMOD connections are properly mapped and ready for testing.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    Logging With Timestamp
    ...  message=Step 1 Preconditions For Memory Consumption Of FHS
    ...  style=STEP
    ...  frame=${TRUE}
    &{fhs_sn_ip_dict}=  Create Dictionary
    &{fhs_sn_dn_dict}=  Create Dictionary
    &{fhs_prim_controller_dict}=  Create Dictionary
    &{rmod_affected_sn_dn_dict}=  Create Dictionary
    &{rmod_sn_fhs_sn_dict}=  Create Dictionary
    &{cell_int_conf_dns_dict}=  Create Dictionary
    @{rat_list}=  Create List  gsm  wcdma  lte  nr
    FOR    ${bts_id}    IN    @{CFG.active_bts_list}
      ${fhss_sns}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  scf_hw_fhs_list
      ${chosen_fhs_exist}=  Run Keyword And Return Status  Variable Should Exist  ${CHOSEN_FHSS}
      ${type}=  Evaluate  type($CHOSEN_FHSS)
      ${chosen_fhss_temp}=  Run Keyword If  "${type}"=="<class 'list'>"  Set Variable  ${CHOSEN_FHSS[0]}
      ${all_fhs_chosen}=  Run Keyword And Return Status  Should Be Equal  ${chosen_fhss_temp}  all
      ${tested_fhss}=  Set Variable If  ${chosen_fhs_exist}==${FALSE}  ${fhss_sns}
      ...  ${all_fhs_chosen}==True  ${fhss_sns}
      ...  ${chosen_fhs_exist}==${TRUE}  ${CHOSEN_FHSS}
      ${fhss_dns}=  admin.Get IDs For All  FHS  connection=${bts_id}
      ${bts_info}=  admin.Get Bts Info  connection=${bts_id}
      ${fhs_mos}=  admin.Get Managed Objects  FHS_L  connection=${bts_id}
      FOR  ${fhs_mo}  IN  @{fhs_mos}
        Set To Dictionary  ${fhs_sn_ip_dict}  ${fhs_mo['parameters']['serialNumber']}=${fhs_mo['parameters']['ipAddress']}
        ${fhs_prim_controller}=  Get From Dictionary    ${fhs_mo['parameters']}   primaryControllerDN
        ${bts_number}=  Evaluate  re.search(r'BTS_L-(\\d+)','''${fhs_prim_controller}''').group(1)  re
        Set To Dictionary  ${fhs_prim_controller_dict}  ${fhs_mo['parameters']['serialNumber']}=${bts_number}
      END
      FOR  ${fhs}  IN  @{bts_info['fhs']}
        FOR  ${tested_fhs}  IN  @{tested_fhss}
          Continue For Loop If  '${fhs['serialNumber']}'!='${tested_fhs}'
          Set To Dictionary  ${fhs_sn_dn_dict}  ${fhs['serialNumber']}=${fhs['id']['internal']}
        END
        ${fhs_parameters}=  Get Parameters For  FHS  ${fhs['id']['internal']}  connection=${bts_id}
      END
      FOR  ${rat}  IN  @{rat_list}
        FOR  ${cell}  IN  @{bts_info['cells']['${rat}']}
          Set To Dictionary  ${cell_int_conf_dns_dict}  ${cell['id']['internal']}=${cell['id']['configuration']}
        END
      END
      ${rmod_sn_fhs_sn_dict}  ${rmod_affected_sn_dn_dict}=  Prepare FHS RMOD Connections Dictionary  ${bts_id}  ${tested_fhss}
    END
    ${affected_rmods_dns}=  Get Dictionary Values  ${rmod_affected_sn_dn_dict}
    @{affected_cells}=  Create List
    FOR  ${affected_rmod_dn}  IN  @{affected_rmods_dns}
      ${affected_cell}=  admin.Get Cell Mapping By Module ID  ${affected_rmod_dn}  connection=${bts_id}
      ${affected_cells}=  Combine Lists  ${affected_cells}  ${affected_cell}
    END

    Set Test Variable  ${AFFECTED_CELLS}  ${affected_cells}
    Set Test Variable  ${TESTED_FHSS}  ${tested_fhss}
    Set Test Variable  ${FHS_SN_IP_DICT}  ${fhs_sn_ip_dict}
    Set Test Variable  ${FHS_SN_DN_DICT}  ${fhs_sn_dn_dict}
    Set Test Variable  ${FHS_PRIM_CONTROLLER_DICT}  ${fhs_prim_controller_dict}
    Set Test Variable  ${RMOD_AFFECTED_SN_DN_DICT}  ${rmod_affected_sn_dn_dict}
    Set Test Variable  ${RMOD_SN_FHS_SN_DICT}  ${rmod_sn_fhs_sn_dict}
    Set Test Variable  ${CELL_INT_CONF_DNS_DICT}  ${cell_int_conf_dns_dict}

Step 2 Initial Verification Of Memory Consumption Of FHS
    [Documentation]
    ...  Description:
    ...  This keyword performs the initial verification of memory consumption for the FHS.
    ...  It retrieves memory usage data for each tested FHS and compares it against the defined threshold.
    ...  The results are stored in a dictionary for further analysis in subsequent steps.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    Logging With Timestamp
    ...  message=Step 2 Initial Verification Of Memory Consumption Of FHS
    ...  style=STEP
    ...  frame=${TRUE}
    OperatingSystem.Create File   ${TEST_LOGS_PATH}TestFiles/${CFG.active_bts_list[0]}/memo_consumption.txt
    &{initial_memory_consumptions_dict}=  Create Dictionary
    FOR  ${fhs_sn}  IN  @{TESTED_FHSS}
      ${fhs_ip}=  Get From Dictionary  ${FHS_SN_IP_DICT}  ${fhs_sn}
      ${bts_number}=  Get From Dictionary  ${FHS_PRIM_CONTROLLER_DICT}  ${fhs_sn}
      ${initial_memory_consumption}  ${datetime_timestamp}=  Verify Memory Consumption Of FHS
      ...  ${fhs_sn}  ${MEMORY_CONSUMPTION_THRESHOLD}
      ${initial_memory_timestamp_list}=  Create List  ${datetime_timestamp}  ${initial_memory_consumption}
      Set To Dictionary  ${initial_memory_consumptions_dict}  ${fhs_sn}=${initial_memory_timestamp_list}
    END
    Set Test Variable  ${INITIAL_MEMORY_CONSUMPTIONS}  ${initial_memory_consumptions_dict}
    OperatingSystem.Append To File
      ...  ${TEST_LOGS_PATH}TestFiles/${CFG.active_bts_list[0]}/memo_consumption.txt
      ...  ${initial_memory_consumptions_dict}${\n}

Step 3 Execute Actions Without BTS Nor FHS Reset
    [Arguments]  ${bts_id}
    [Documentation]
    ...  Description:
    ...  This keyword executes actions on the system without performing a reset on BTS or FHS.
    ...  It includes downloading a software package, blocking and unblocking cells, resetting RMODs, and waiting for idle time.
    ...  The keyword ensures that the system remains stable and operational during these actions.
    ...
    ...  Arguments:
    ...  +========================+======+===============================================================+
    ...  | Argument               | Man. | Description                                                   |
    ...  +========================+======+===============================================================+
    ...  | ${bts_id}              | Yes  | Identifier of the BTS node on which actions are performed.    |
    ...  +------------------------+------+---------------------------------------------------------------+
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    Logging With Timestamp
    ...  message=Step 3 Execute Actions Without BTS Nor FHS Reset
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Step 3 Execute Actions Without BTS Nor FHS Reset - Gathering snapshot
    ...  style=ONGOING
    Logging Session Save Snapshot
    ...  logs_dir_path=${TEST_LOGS_PATH}TestFiles/${bts_id}/Snapshot_Step3_1.zip
    ...  connection=${bts_id}
    Download SW Package Without Activation  ${bts_id}
    ${middle1_memory_consumptions_dict}=  Middle Verification Of Memory Consumption Of FHS
    OperatingSystem.Append To File
      ...  ${TEST_LOGS_PATH}TestFiles/${CFG.active_bts_list[0]}/memo_consumption.txt
      ...  ${middle1_memory_consumptions_dict}${\n}
    Block And Unblock Cells On Tested FHS  ${bts_id}
    ${middle2_memory_consumptions_dict}=  Middle Verification Of Memory Consumption Of FHS
    OperatingSystem.Append To File
      ...  ${TEST_LOGS_PATH}TestFiles/${CFG.active_bts_list[0]}/memo_consumption.txt
      ...  ${middle2_memory_consumptions_dict}${\n}
    Sleep  ${BREAK_AFTER_CELL_BLOCK_UNBLOCK}
    ${middle3_memory_consumptions_dict}=  Middle Verification Of Memory Consumption Of FHS
    OperatingSystem.Append To File
      ...  ${TEST_LOGS_PATH}TestFiles/${CFG.active_bts_list[0]}/memo_consumption.txt
      ...  ${middle3_memory_consumptions_dict}${\n}
    ${middle4_memory_consumptions_dict}=  Reset RMOD Connected To Tested FHS  ${bts_id}
    OperatingSystem.Append To File
      ...  ${TEST_LOGS_PATH}TestFiles/${CFG.active_bts_list[0]}/memo_consumption.txt
      ...  ${middle4_memory_consumptions_dict}${\n}
    Logging With Timestamp
    ...  message=Step 3 Execute Actions Without BTS Nor FHS Reset - Gathering snapshot
    ...  style=ONGOING
    Logging Session Save Snapshot
    ...  logs_dir_path=${TEST_LOGS_PATH}TestFiles/${bts_id}/Snapshot_Step3_2.zip
    ...  connection=${bts_id}
    Logging With Timestamp
    ...  message=Step 3 Idle time - Waiting with sleep KW set to: ${BREAK_IDLE_TIME}
    ...  style=ONGOING
    Sleep  ${BREAK_IDLE_TIME}

Step 4 Final Verification Of Memory Consumption Of FHS
    [Documentation]
    ...  Description:
    ...  This keyword performs the final verification of memory consumption for the FHS.
    ...  It retrieves memory usage data for each tested FHS and compares it against the defined threshold.
    ...  The results are compared with the initial memory consumption to identify any significant changes.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    Logging With Timestamp
    ...  message=Step 4 Final Verification Of Memory Consumption Of FHS
    ...  style=STEP
    ...  frame=${TRUE}
    &{final_memory_consumptions_dict}=  Create Dictionary
    FOR  ${fhs_sn}  IN  @{TESTED_FHSS}
      ${fhs_ip}=  Get From Dictionary  ${FHS_SN_IP_DICT}  ${fhs_sn}
      ${final_memory_consumption}  ${datetime_timestamp}=  Verify Memory Consumption Of FHS
      ...  ${fhs_sn}  ${MEMORY_CONSUMPTION_THRESHOLD}
      ${final_memory_timestamp_list}=  Create List  ${datetime_timestamp}  ${final_memory_consumption}
      Set To Dictionary  ${final_memory_consumptions_dict}  ${fhs_sn}=${final_memory_timestamp_list}
    END
    OperatingSystem.Append To File
    ...  ${TEST_LOGS_PATH}TestFiles/${CFG.active_bts_list[0]}/memo_consumption.txt
    ...  ${final_memory_consumptions_dict}${\n}

    Logging With Timestamp
    ...  message=Initial consumptions of FHS memory were ${INITIAL_MEMORY_CONSUMPTIONS}${\n}
    ...  style=DONE
    Logging With Timestamp
    ...  message=Final consumptions of FHS memory were ${final_memory_consumptions_dict}
    ...  style=DONE
    Run Keywords
    ...  Logging With Timestamp
    ...  message=All memory consumptions of FHSs saved to a file.
    ...  style=DONE
    ...  AND  OperatingSystem.Log File   ${TEST_LOGS_PATH}TestFiles/${CFG.active_bts_list[0]}/memo_consumption.txt

Verify Memory Consumption Of FHS
    [Arguments]  ${fhs_sn}  ${memory_consumption_threshold}=80
    [Documentation]
    ...  Description:
    ...  This keyword verifies the memory consumption of a specific FHS.
    ...  It retrieves the memory usage percentage and compares it against the defined threshold.
    ...  If the memory consumption exceeds the threshold, the keyword logs an error and fails the test.
    ...
    ...  Arguments:
    ...  +==============================+======+===============================================================+
    ...  | Argument                     | Man. | Description                                                   |
    ...  +==============================+======+===============================================================+
    ...  | fhs_sn                       | Yes  | Serial number of the FHS to verify.                           |
    ...  +------------------------------+------+---------------------------------------------------------------+
    ...  | memory_consumption_threshold | No   | Maximum allowed memory consumption percentage. Default is 80%.|
    ...  +------------------------------+------+---------------------------------------------------------------+
    ...
    ...  Outputs:
    ...  +==============================+======================================================================+
    ...  | Output                       | Description                                                          |
    ...  +==============================+======================================================================+
    ...  | memory_consumption           | Memory usage percentage of the specified FHS.                        |
    ...  +------------------------------+----------------------------------------------------------------------+
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${memory_consumption}  ${datetime_timestamp}=  Get Memory Usage For FHS  ${fhs_sn}
    Run Keyword If  ${memory_consumption} > ${MEMORY_CONSUMPTION_THRESHOLD}  Run Keywords
    ...  Logging With Timestamp
    ...  message=Memory usage on ${fhs_sn} is ${memory_consumption}% which is over set limit of ${MEMORY_CONSUMPTION_THRESHOLD}%
    ...  style=ERROR
    ...  AND  Fail  msg=Memory usage ${memory_consumption}% above set threshold ${MEMORY_CONSUMPTION_THRESHOLD}% on ${fhs_sn}.
    ...  ELSE
    ...  Logging With Timestamp
    ...  message=Memory usage on ${fhs_sn} is ${memory_consumption}%
    [Return]  ${memory_consumption}  ${datetime_timestamp}

Get Memory Usage For FHS
    [Arguments]  ${fhs_sn}
    [Documentation]
    ...  Description:
    ...  This keyword retrieves the memory usage percentage for a specific ardware Subsystem (FHS.
    ...  It establishes an SSH connection to the FHS, executes a command to calculate memory usage, and returns the result.
    ...
    ...  Arguments:
    ...  +========================+======+===============================================================+
    ...  | Argument               | Man. | Description                                                   |
    ...  +========================+======+===============================================================+
    ...  | fhs_sn                 | Yes  | Serial number of the FHS to retrieve memory usage for.        |
    ...  +------------------------+------+---------------------------------------------------------------+
    ...
    ...  Outputs:
    ...  +========================+======================================================================+
    ...  | Output                 | Description                                                          |
    ...  +========================+======================================================================+
    ...  | usage_result           | Memory usage percentage of the specified FHS.                        |
    ...  +------------------------+----------------------------------------------------------------------+
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    radio.Open Connection To Radio Module  ru_serial_number=${fhs_sn}
    ${get_mem_usage_cmd}=  Set Variable  date && free | grep Mem | awk '{ print int($3/$2 * 100) "%"}'
    radio.Send Command  ${get_mem_usage_cmd}
    ${cmd_output}=  radio.Read Output  delay=1
    ${cmd_output_splitted}=  Split String  ${cmd_output}  \n
    ${usage_result}=  Fetch From Left  ${cmd_output_splitted[-2]}  %
    ${datetime_line}=  Set Variable  ${cmd_output_splitted[1]}
    ${datetime_line_parts}=  Split String  ${cmd_output_splitted[1]}  ${SPACE}
    ${year}=  Fetch From Left  ${datetime_line_parts[5]}  \r\r
    ${month}=  Set Variable  ${datetime_line_parts[1]}
    ${day}=  Set Variable  ${datetime_line_parts[2]}
    ${time}=  Set Variable  ${datetime_line_parts[3]}
    ${datetime_timestamp}=  Set Variable    ${year}-${month}-${day} ${time}
    radio.Close SSH Connection
    [Return]   ${usage_result}  ${datetime_timestamp}

Prepare FHS RMOD Connections Dictionary
    [Arguments]  ${bts_id}  ${tested_fhss}
    [Documentation]
    ...  Description:
    ...  This keyword prepares dictionaries mapping RMODs to FHS connections for a given BTS.
    ...  It retrieves SFP link information and identifies RMODs connected to the tested FHSs.
    ...  The resulting dictionaries are used to track RMOD-FHS relationships and affected RMODs.
    ...
    ...  Arguments:
    ...  +========================+======+===============================================================+
    ...  | Argument               | Man. | Description                                                   |
    ...  +========================+======+===============================================================+
    ...  | bts_id                 | Yes  | Identifier of the BTS node for which connections are prepared.|
    ...  +------------------------+------+---------------------------------------------------------------+
    ...  | tested_fhss            | Yes  | List of tested FHS serial numbers.                            |
    ...  +------------------------+------+---------------------------------------------------------------+
    ...
    ...  Outputs:
    ...  +==========================+======================================================================+
    ...  | Output                   | Description                                                          |
    ...  +==========================+======================================================================+
    ...  | rmod_sn_fhs_sn_dict      | Dictionary mapping RMOD serial numbers to FHS serial numbers.        |
    ...  +--------------------------+----------------------------------------------------------------------+
    ...  | rmod_affected_sn_dn_dict | Dictionary mapping RMOD serial numbers to their distinguished names.|
    ...  +--------------------------+----------------------------------------------------------------------+
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.co

    ${sfp_links}=  admin.Get Sfp Links  connection=${bts_id}
    &{rmod_sn_fhs_sn_dict}=  Create Dictionary
    &{rmod_affected_sn_dn_dict}=  Create Dictionary
    FOR  ${fhs_sn}  IN  @{tested_fhss}
      FOR  ${link}  IN  @{sfp_links['connected']}
        Continue For Loop If  "${fhs_sn}"!="${link['parent']['destination']['parameters']['serialNumber']}"
        Set To Dictionary  ${rmod_sn_fhs_sn_dict}  ${link['parent']['source']['parameters']['serialNumber']}=${fhs_sn}
        Set To Dictionary  ${rmod_affected_sn_dn_dict}
        ...  ${link['parent']['source']['parameters']['serialNumber']}=${link['parent']['source']['distName']}
      END
    END
    [Return]  ${rmod_sn_fhs_sn_dict}  ${rmod_affected_sn_dn_dict}

Download SW Package Without Activation
    [Arguments]  ${bts_id}
    [Documentation]
    ...  Description:
    ...  This keyword downloads a software package for a specified BTS without activating it.
    ...  It checks the availability of the main software package, waits for the system to be ready for the update,
    ...  and performs the software download. The process ensures that the software is prepared for activation at a later stage.
    ...
    ...  Arguments:
    ...  +========================+======+==================================================================+
    ...  | Argument               | Man. | Description                                                      |
    ...  +========================+======+==================================================================+
    ...  | bts_id                 | Yes  | Identifier of the BTS node for which the software is downloaded. |
    ...  +------------------------+------+------------------------------------------------------------------+
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    Logging With Timestamp
    ...  message=Step 3 Execute Actions Without BTS Nor FHS Reset - Downloading SW Package
    ...  style=ONGOING
    ${software_package_path}=  SWM Check Main Software Package Availability  ${CFG.NODES['${bts_id}']['software_active']}  ${bts_id}
    Run Keyword And Ignore Error  admin.Wait Sw Update Possible
    ...  bts_ready=True
    ...  readiness_timeout=780
    ...  timeout=800
    ...  connection=${bts_id}
    Logging With Timestamp
    ...  message=Software update to ${software_package_path} is being made. Please wait...
    admin.Update Software  sw_package=${software_package_path}  should_activate=False  timeout=8000  alias=${bts_id}

Block And Unblock Cells On Tested FHS
    [Arguments]  ${bts_id}
    [Documentation]
    ...  Description:
    ...  This keyword blocks and unblocks cells associated with the tested FHS.
    ...  It ensures that the cells are properly blocked and unblocked, verifying the appearance of Fault 49 during the process.
    ...  If no cells are affected, the step is skipped with a warning.
    ...
    ...  Arguments:
    ...  +========================+======+===============================================================+
    ...  | Argument               | Man. | Description                                                   |
    ...  +========================+======+===============================================================+
    ...  | bts_id                 | Yes  | Identifier of the BTS node on which actions are performed.    |
    ...  +------------------------+------+---------------------------------------------------------------+
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    Logging With Timestamp
    ...  message=Step 3 Execute Actions Without BTS Nor FHS Reset - Blocking and Unblocking Cells
    ...  style=ONGOING
    ${empty}=  Run Keyword And Return Status  Should Not Be Empty  ${AFFECTED_CELLS}
    Run Keyword If  ${empty}==False
    ...  Logging With Timestamp
    ...  message=No cells to block and unblock, this step is skipped.
    ...  style=WARNING
    FOR  ${cell}  IN  @{AFFECTED_CELLS}
      ${block_status}=  Run Keyword And Return Status  admin.Block Cell
      ...  dist_name=${cell}
      ...  timeout=300
      ...  connection=${bts_id}
      ${cell_config_dn}=  Get From Dictionary  ${CELL_INT_CONF_DNS_DICT}  ${cell}
      ${fault49_status}=  Run Keyword And Return Status  FM Await For Fault
      ...  fault_attr=faultId=49, alarmingObjectIds[0].configuration=${cell_config_dn}, severity=Critical, alarmId=7102
      ...  node_id=${bts_id}
      ...  alarm_resource=${FAULT_49}
      Run Keyword If  ${fault49_status}==False
      ...  Logging With Timestamp
      ...  message=Fault 49 has not appeared. Cells are NOT blocked. Please investigate.
      ...  style=WARNING
      ...  ELSE
      ...  Logging With Timestamp
      ...  message=Fault 49 has appeared.
    END
    Sleep  120s
    FOR  ${cell}  IN  @{AFFECTED_CELLS}
      ${unblock_status}=  Run Keyword And Return Status  admin.Unblock Cell
      ...  dist_name=${cell}
      ...  timeout=300
      ...  connection=${bts_id}
    END
    Logging With Timestamp
    ...  message=Step 3 Idle time - Waiting after cell block and unblock for: ${BREAK_AFTER_CELL_BLOCK_UNBLOCK}
    ...  style=ONGOING

Reset RMOD Connected To Tested FHS
    [Arguments]  ${bts_id}
    [Documentation]
    ...  Description:
    ...  This keyword resets RMODs connected to the tested FHS.
    ...  It performs multiple reset iterations, verifies the appearance of Fault 10, and ensures the BTS is operational after each reset.
    ...  The keyword also includes idle time between resets to allow the system to stabilize.
    ...
    ...  Arguments:
    ...  +========================+======+===============================================================+
    ...  | Argument               | Man. | Description                                                   |
    ...  +========================+======+===============================================================+
    ...  | bts_id                 | Yes  | Identifier of the BTS node on which actions are performed.    |
    ...  +------------------------+------+---------------------------------------------------------------+
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    Logging With Timestamp
    ...  message=Step 3 Execute Actions Without BTS Nor FHS Reset - Resetting RU
    ...  style=ONGOING
    FOR  ${fhs_sn}  IN  @{TESTED_FHSS}
      FOR  ${rmod_sn}  IN  @{RMOD_SN_FHS_SN_DICT}
        Continue For Loop If  '${fhs_sn}'!='${RMOD_SN_FHS_SN_DICT['${rmod_sn}']}'
        ${rmod_dn}=  Get From Dictionary  ${RMOD_AFFECTED_SN_DN_DICT}  ${rmod_sn}
          FOR  ${i}  IN RANGE  1  ${RU_RESET_ITERATIONS}+1
            ${bts_timestamp}  SSH Get BTS timestamp  ${bts_id}
            ${reset_status}=  Run Keyword And Return Status  admin.Reset Unit
            ...  dist_name=${rmod_dn}
            ...  timeout=300
            ...  connection=${bts_id}
            Run Keyword If  ${reset_status}==False
            ...  Logging With Timestamp
            ...  message=Reset of ${rmod_dn} failed. Please investigate.
            ...  style=WARNING
            ...  ELSE
            ...  Logging With Timestamp
            ...  message=Reset of ${rmod_dn} was successful.
            ...  style=DONE
            STATE Verify BTS states
            ...  node_id=${bts_id}
            ...  expected_BTS_status=OnAir
            ...  HW_check=${TRUE}
            ...  cells_check=${TRUE}
            ...  scf_check=${TRUE}
            ...  timeout=300
          Logging With Timestamp
          ...  message=Step 3 Idle time - Waiting after ru ${rmod_dn} reset for: ${BREAK_AFTER_RU_RESET}
          ...  style=ONGOING
          Sleep  ${BREAK_AFTER_RU_RESET}
          ${middle_memory_consumptions_dict}=  Middle Verification Of Memory Consumption Of FHS
          END
      END
    END
    [Return]  ${middle_memory_consumptions_dict}

Middle Verification Of Memory Consumption Of FHS
    [Documentation]
    ...  Description:
    ...  This keyword performs the middle verification of memory consumption for the FHS.
    ...  It retrieves memory usage data for each tested FHS and compares it against the defined threshold.
    ...  The results are compared with the initial memory consumption to identify any significant changes.
    ...  This keyword prints out the current usage for the tester.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    Logging With Timestamp
    ...  message=Middle Verification Of Memory Consumption Of FHS
    ...  style=INFO
    &{middle_memory_consumptions_dict}=  Create Dictionary
    FOR  ${fhs_sn}  IN  @{TESTED_FHSS}
      ${fhs_ip}=  Get From Dictionary  ${FHS_SN_IP_DICT}  ${fhs_sn}
      ${middle_memory_consumption}  ${datetime_timestamp}=  Verify Memory Consumption Of FHS
      ...  ${fhs_sn}  ${MEMORY_CONSUMPTION_THRESHOLD}
      ${middle_memory_timestamp_list}=  Create List  ${datetime_timestamp}  ${middle_memory_consumption}
      Set To Dictionary  ${middle_memory_consumptions_dict}  ${fhs_sn}=${middle_memory_timestamp_list}
    END
    Logging With Timestamp
    ...  message=Initial consumptions of FHS memory were ${INITIAL_MEMORY_CONSUMPTIONS}
    Logging With Timestamp
    ...  message=Middle consumptions of FHS memory were ${middle_memory_consumptions_dict}
    [Return]  ${middle_memory_consumptions_dict}
