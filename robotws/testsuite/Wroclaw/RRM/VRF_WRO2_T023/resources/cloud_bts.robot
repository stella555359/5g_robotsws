*** Settings ***
Documentation
...   contact: Monika Ceglarek

Library     SSHLibrary
Library     String
Library     DateTime
Library     Process
Library     taf.gnb.oam.coam.cu     WITH NAME    vcu
Library     taf.gnb.oam.coam.vdu    WITH NAME    vdu
Library     taf.hw.fhgw.cli
Library     taf.transport.ssh

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Variables   ta5g_global_var
Library     ute_wtssim
Library     ta5g_egate
Library     ta5g_syslog
Library     ta5g_setups_and_teardowns
Library     ta5g_iphy
Library     ta5g_testline_management
Library     cloud_bts_egate.py

Library     testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/Downloader.py


*** Keywords ***
Cloud BTS Test Setup
    [Documentation]
    ...  Test setup for cloud BTS tests. Sets up both vCU and vDU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Test setup for cloud BTS tests, in which vCU and vDU are used.
    ...
    ...  List of actions:
    ...  - creates test variable ${VDU_OAM_CONNECTION} with OAM connection details fro vDU
    ...  - creates test variable ${VCU_OAM_CONNECTION} with OAM connection details fro vCU
    ...  - creates test variable ${VDU_MASTER_SSH_DETAILS} with SSH connection details for vDU master node
    ...  - creates test variable ${VCU_MASTER_SSH_DETAILS} with SSH connection details for vCU master node
    ...  - creates directories for logs and test variable ${LOG_PATH} with absolute path to logs directories
    ...  - starts sylog and tshark collection for Iphy and AIC
    ...  - connects to vCU
    ...  - connects to vDU
    ...  - checks state of BTS
    ...
    ...  It requires __init__.py.
    ...  'Cloud BTS Test Teardown' KW should be run after this KW.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | ignored_alarms_vcu     | No   | List of dictionaries with ignored alarms data for VCU.                |
    ...  |                        |      | Default value: ${None}.                                               |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | ignored_alarms_vdu     | No   | List of dictionaries with ignored alarms data for VDU.                |
    ...  |                        |      | Default value: ${None}.                                               |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Cloud BTS Test Setup
    ...     Cloud BTS Test Teardown

    [Arguments]  ${ignored_alarms_vcu}=${None}  ${ignored_alarms_vdu}=${None}

    Log  \n\n=== Cloud BTS Test Setup ===  console=True
    Log Variables   level=DEBUG

    Set Test Variable  ${VDU_OAM_CONNECTION}  ${tl.gnbs[0].dus[0].oam_http_connection_details}
    Set Test Variable  ${VCU_OAM_CONNECTION}  ${tl.gnbs[0].cu.oam_http_connection_details}

    ${vdu_ssh_details} =  Set Variable  ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details}
    Set Test Variable  ${VDU_MASTER_SSH_DETAILS}  ${vdu_ssh_details}

    ${vcu_ssh_details} =  Set Variable  ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details}
    Set Test Variable  ${VCU_MASTER_SSH_DETAILS}  ${vcu_ssh_details}

    Create Log Directories For Cloud BTS

    Start Default Logging  output_dirpath=${LOG_PATH}  alias=default_F1_E1_RRC

    ${vdu_version} =  Get VDU Software Version
    Set Test Variable  ${VDU_SW_VERSION}  ${vdu_version}
    ${vcu_version} =  Get VCU Software Version
    Set Test Variable  ${VCU_SW_VERSION}  ${vcu_version}
    ${vdu_ocp_version} =  Get vDU OCP Version
    Set Test Variable  ${VDU_OCP_VERSION}  ${vdu_ocp_version}
    ${vcu_ocp_version} =  Get vCU OCP Version
    Set Test Variable  ${VCU_OCP_VERSION}  ${vcu_ocp_version}
    ${ip}  ${username}  ${password} =  Get FHGW Data From Init File For Single DU
    ${fhgw_sw_version} =  IF  '${ip}' != '${None}'  Get FHGW SW Version  ${ip}  ${username}  ${password}
    Set Test Variable  ${FHGW_SW_VERSION}  ${fhgw_sw_version}
    ${ip}  ${username}  ${password} =  Get AP Data From Init File
    ${ap_sw_version} =  Get AP SW Version  ${ip}  ${username}  ${password}
    Set Test Variable  ${AP_SW_VERSION}  ${ap_sw_version}


    Verify BTS States For Cloud BTS  ${ignored_alarms_vcu}  ${ignored_alarms_vdu}


Cloud BTS Test Teardown
    [Documentation]
    ...  Test teardown for cloud BTS tests. Tears down both vCU and vDU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Test teardown for cloud BTS tests, in which vCU and vDU are used.
    ...
    ...  List of actions:
    ...  - stops sylog collection for Iphy and AIC
    ...  - reconnects to vCU and collects snapshot
    ...  - reconnects to vDU and collects snapshot
    ...  - disconnects from vCU and vDU
    ...
    ...  It requires ${LOG_PATH} (absolute path for logs) test variable.
    ...  This KW should be run after 'Cloud BTS Test Setup'.
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Cloud BTS Test Setup
    ...     Cloud BTS Test Teardown

    Log  \n\n=== Cloud BTS Test Teardown ===  console=True

    Stop Default Logging  output_dirpath=${LOG_PATH}
    Log  Collecting snapshot for vCU...  console=True
    Connect To VCU
    vcu.Get Local Snapshot  directory=${LOG_PATH}/snapshot/vCU
    Log  Collecting snapshot for vDU...  console=True
    Connect To VDU
    vdu.Get Local Snapshot  directory=${LOG_PATH}/snapshot/vDU  compressed_or_not=True
    vcu.Disconnect
    vdu.Disconnect


Verify BTS States For Cloud BTS
    [Documentation]
    ...  Verifies state of vCU, vDU, RMODS, NR cells and unexpected alarms on both vCU and vDU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | ignored_alarms_vcu     | No   | List of dictionaries with ignored alarms data for VCU.                |
    ...  |                        |      | Default value: ${None}.                                               |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | ignored_alarms_vdu     | No   | List of dictionaries with ignored alarms data for VDU.                |
    ...  |                        |      | Default value: ${None}.                                               |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...    Verify BTS States For Cloud BTS

    [Arguments]  ${ignored_alarms_vcu}=${None}  ${ignored_alarms_vdu}=${None}

    ${ignored_alarms_vcu_copy} =    Create List    @{ignored_alarms_vcu}
    ${ignored_alarms_vdu_copy} =    Create List    @{ignored_alarms_vdu}

    ${vdu_onair} =  Check VDU State
    ${vcu_enabled} =  Check VCU State
    ${rmods_onair} =  Check RMODs States
    ${nrcells_onair} =  Check NR Cells States
    ${alarms_status_vcu} =  Check Unexpected Alarms VCU  ${ignored_alarms_vcu_copy}
    ${alarms_status_vdu} =  Check Unexpected Alarms VDU  ${ignored_alarms_vdu_copy}

    ${statuses_dictionary}=  Create Dictionary
    ...  vcu_enabled=${vcu_enabled}  vdu_onair=${vdu_onair}
    ...  rmods_onair=${rmods_onair}  nrcells_onair=${nrcells_onair}
    ...  alarms_status_vcu=${alarms_status_vcu}  alarms_status_vdu=${alarms_status_vdu}
    ${pretty_statuses}=  Evaluate  pprint.pformat(${statuses_dictionary}, indent=4)  modules=pprint

    Should Be True
    ...  ${vcu_enabled} and ${vdu_onair} and ${rmods_onair} and ${nrcells_onair} and ${alarms_status_vcu} and ${alarms_status_vdu}
    ...  msg=BTS verification failed. Details:\n${pretty_statuses}


Check VDU State
    [Documentation]
    ...  Checks state of vDU and F1 link status.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Check VDU State

    Connect To VDU
    ${vdu_expected_states} =  Create Dictionary
    ...  f1_c_link_status_du=available
    ...  operational_state=onAir
    ${vdu_data} =  vdu.Get VDU State Data
    ${correct_state} =  _check each state helper  ${vdu_data}  ${vdu_expected_states}

    [Teardown]  vdu.Disconnect
    [Return]  ${correct_state}


Check VCU State
    [Documentation]
    ...  Checks state of vCU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Check VCU State

    Connect To VCU
    ${vcu_expected_states} =  Create Dictionary
    ...  operational_state=enabled
    ${vcu_data} =  vcu.Get CU State
    ${correct_state} =  _check each state helper  ${vcu_data}  ${vcu_expected_states}

    [Teardown]  vcu.Disconnect
    [Return]  ${correct_state}


Check Unexpected Alarms VDU
    [Documentation]
    ...  Checks if any unexpected alarms appeared on vDU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | ignored_alarms         | No   | List of dictionaries with ignored alarms data.                        |
    ...  |                        |      | Default value: ${None}.                                               |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...    Check Unexpected Alarms VDU

    [Arguments]  ${ignored_alarms}=${None}

    Connect To VDU
    ${active_alarms} =  vdu.VDU Get Active Alarms
    ${active_alarms} =  Set Variable  ${active_alarms['alarms']}
    FOR  ${alarm}  IN  @{active_alarms}
        Exit For Loop If  not ${ignored_alarms}
        ${remove_alarm} =  _alarm check helper  ${alarm}  ${ignored_alarms}
        IF  ${remove_alarm}
            Remove Values From List  ${active_alarms}  ${alarm}
        END
    END
    ${alarm_status} =  Run Keyword And Return Status  Should Be Empty  ${active_alarms}  msg=Alarm list is not empty.

    [Teardown]  vdu.Disconnect
    [Return]  ${alarm_status}


Check Unexpected Alarms VCU
    [Documentation]
    ...  Checks if any unexpected alarms appeared on vCU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | ignored_alarms         | No   | List of dictionaries with ignored alarms data.                        |
    ...  |                        |      | Default value: ${None}.                                               |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...    Check Unexpected Alarms VCU

    [Arguments]  ${ignored_alarms}=${None}

    ${ignored_alarms} =  _add energy saving ignored alarms helper  ${ignored_alarms}
    Connect To VCU
    ${active_alarms} =  vcu.Get Active Alarms
    ${active_alarms} =  Set Variable  ${active_alarms['alarms']}
    FOR  ${alarm}  IN  @{active_alarms}
        Exit For Loop If  not ${ignored_alarms}
        ${remove_alarm} =  _alarm check helper  ${alarm}  ${ignored_alarms}
        IF  ${remove_alarm}
            Remove Values From List  ${active_alarms}  ${alarm}  msg=Alarm list is not empty.
        END
    END
    ${alarm_status} =  Run Keyword And Return Status  Should Be Empty  ${active_alarms}

    [Teardown]  vcu.Disconnect
    [Return]  ${alarm_status}


_add energy saving ignored alarms helper
    [Arguments]  ${ignored_alarms}=${None}

    ${vcu_mrbts_id} =  Get MRBTS ID From VCU  set_for_test=False
    ${nrbts_id} =  Get NRBTS ID From VDU  set_for_test=False
    ${energy_saving_cell_ids} =  Get Cell IDs Of All Cells Currently In EnergySaving State
    FOR  ${energy_saving_cell_id}  IN  @{energy_saving_cell_ids}
        ${fault_7104} =  Create Dictionary  alarming_object=MRBTS-${vcu_mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${energy_saving_cell_id}
        ...  fault_id=7104
        Append To List  ${ignored_alarms}  ${fault_7104}
    END
    ${ignored_alarms} =  Remove Duplicates  ${ignored_alarms}

    [Return]  ${ignored_alarms}


_alarm check helper
    [Arguments]  ${alarm}  ${ignored_alarms}=${None}
    Return From Keyword If  not ${ignored_alarms}
    ${alarm_summary} =  Set Variable  False
    FOR  ${ignored_alarm}  IN  @{ignored_alarms}
        ${ignored_alarm_matches} =  _ignored alarm check helper  ${alarm}  ${ignored_alarm}
        ${alarm_summary} =  Set Variable If  ${ignored_alarm_matches}  True  False
        Exit For Loop If  ${ignored_alarm_matches}
    END
    [Return]  ${alarm_summary}


_ignored alarm check helper
    [Arguments]  ${alarm}  ${ignored_alarm}=${None}
    Return From Keyword If  not ${ignored_alarm}
    ${alarm_summary} =  Set Variable  False
    FOR  ${parameter}  IN  @{ignored_alarm}
        ${correct_value} =  Run Keyword And Return Status  Should Be True
        ...  '${alarm['${parameter}']}' == '${ignored_alarm['${parameter}']}'
        ...  msg=Element does not exist.
        ${alarm_summary} =  Set Variable If  ${correct_value}  True  False
        Exit For Loop If  not ${correct_value}
    END
    [Return]  ${alarm_summary}


Check RMODs States
    [Documentation]
    ...  Checks state of RMODs from vDU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Check RMODs States

    Connect To VDU
    ${rmod_expected_states} =  Create Dictionary
    ...  administrative_state=Unlocked
    ...  availability_status=on line
    ...  procedural_status=configured
    ...  operational_state=enabled
    ${state_summary} =  Set Variable  True
    ${all_rmods_data} =  vdu.Get RMODs Status
    FOR  ${rmod_data}  IN  @{all_rmods_data}
        ${correct_state} =  _check each state helper  ${rmod_data}  ${rmod_expected_states}
        ${state_summary} =  Set Variable If  ${correct_state}  ${state_summary}  False
    END

    [Teardown]  vdu.Disconnect
    [Return]  ${state_summary}


Check NR Cells States
    [Documentation]
    ...  Checks state of NR cells from vDU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Check NR Cells States

    Connect To VDU
    ${state_summary} =  Set Variable  True
    ${all_cells_data} =  vdu.Get VDU Cells Status
    FOR  ${cell_data}  IN  @{all_cells_data}
        ${cell_info} =  vdu.Get Cell Specific Info  ${cell_data['dist_names']['config']}
        ${energy_saving_state} =  Set Variable  ${cell_info['energySavingState']}
        ${energy_saving_condition} =  Evaluate  '${energy_saving_state}' == 'notEnergySaving' or '${energy_saving_state}' == 'reducedEnergySaving'
        ${energy_saving_condition} =  Evaluate  ${energy_saving_condition} or '${energy_saving_state}' == 'switchingOff'
        ${nr_expected_states} =  Run Keyword If  ${energy_saving_condition}
        ...  Create Dictionary
        ...  administrativeState=Unlocked
        ...  availabilityStatus=on line
        ...  blockingState=Unblocked
        ...  operationalState=enabled
        ...  ELSE IF  '${energy_saving_state}' == 'energySaving' or '${energy_saving_state}' == 'switchingOn'
        ...  Create Dictionary
        ...  administrativeState=Unlocked
        ...  availabilityStatus=off line
        ...  blockingState=Unblocked
        ...  operationalState=disabled
        ...  ELSE  Fail  msg=Unidentified energy saving state: '${energy_saving_state}'.

        ${correct_state} =  _check each cell state helper  ${cell_info}  ${nr_expected_states}
        ${state_summary} =  Set Variable If  ${correct_state}  ${state_summary}  False
    END

    [Teardown]  vdu.Disconnect
    [Return]  ${state_summary}


_check each cell state helper
    [Arguments]  ${object_data}  ${expected_states}
    ${state_summary} =  Set Variable  True
    FOR  ${expected_state}  IN  @{expected_states}
        ${current_cell_state} =  Set Variable If  '${expected_state}' == 'availabilityStatus'
        ...  ${object_data['${expected_state}']}
        ...  ${object_data['basicCell']['${expected_state}']}
        ${correct_state} =  Run Keyword And Return Status  Should Be True
        ...  '${current_cell_state}' == '${expected_states['${expected_state}']}'
        ...  msg=Incorrect cell state.
        ${state_summary} =  Set Variable If  ${correct_state}  ${state_summary}  False
    END
    [Return]  ${state_summary}


_check each state helper
    [Arguments]  ${object_data}  ${expected_states}
    ${state_summary} =  Set Variable  True
    FOR  ${expected_state}  IN  @{expected_states}
        ${correct_state} =  Run Keyword And Return Status  Should Be True
        ...  '${object_data['${expected_state}']}' == '${expected_states['${expected_state}']}'
        ...  msg=Incorrect cell state.
        ${state_summary} =  Set Variable If  ${correct_state}  ${state_summary}  False
    END
    [Return]  ${state_summary}


Create Log Directories For Cloud BTS
    [Documentation]
    ...  This KW creates log directories for cloud BTS tests.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW creates log directories for cloud BTS tests.
    ...  Main directory name begins with timestamp and follows with test name.
    ...  Created directory is inside ${OUTPUT DIR}. This KW also creates path
    ...  to this directory and sets it as test variable ${LOG_PATH}.
    ...
    ...  List of sub-directories:
    ...  - snapshot
    ...  - snapshot/vCU
    ...  - snapshot/vDU
    ...  - misc_logs
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Create Log Directories For Cloud BTS

    ${timestamp}  OperatingSystem.Run  date +%F_%H-%M-%S
    ${LOG_PATH}   OperatingSystem.Join Path  ${OUTPUT DIR}  ${timestamp}_${TEST NAME}
    Create Directory  ${LOG_PATH}
    Set Test Variable  ${LOG_PATH}
    Create Directory  ${LOG_PATH}/misc_logs
    Create Directory  ${LOG_PATH}/snapshot
    Create Directory  ${LOG_PATH}/snapshot/vCU
    Create Directory  ${LOG_PATH}/snapshot/vDU


Connect To VDU
    [Documentation]
    ...  KW used to connect to vDU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to connect to vDU. It is a wrapper for KW 'Connect To' from taf.gnb.oam.coam.vdu library.
    ...  It requires test variable ${VDU_OAM_CONNECTION} containing dictionary containing vDU data.
    ...  It should have following keys:
    ...  addr (IP address), port (port), username (username), password (password).
    ...  This variable is also created in 'Cloud BTS Test Setup' KW.
    ...  It also requires variable ${CU_OAM_VERSION_VDU} which contains vCU version, e.g. cuoam_24r3.
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Set Test Variable  ${CU_OAM_VERSION_VDU}  cuoam_24r3
    ...     Cloud BTS Test Setup
    ...     Connect To VDU
    ...     Cloud BTS Test Teardown

    vdu.Connect To  host=${VDU_OAM_CONNECTION.addr}  port=${VDU_OAM_CONNECTION.port}
    ...  username=${VDU_OAM_CONNECTION.username}  password=${VDU_OAM_CONNECTION.password}
    ...  vdu_version=${CU_OAM_VERSION_VDU}  secure=True


Connect To VCU
    [Documentation]
    ...  KW used to connect to vCU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to connect to vCU. It is a wrapper for KW 'Connect To' from taf.gnb.oam.coam.cu library.
    ...  It requires test variable ${VCU_OAM_CONNECTION} containing dictionary containing vCU data.
    ...  It should have following keys:
    ...  addr (IP address), port (port), username (username), password (password).
    ...  This variable is also created in 'Cloud BTS Test Setup' KW.
    ...  It also requires variable ${CU_OAM_VERSION_VCU} which contains vCU version, e.g. cuoam_24r2.
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Set Test Variable  ${CU_OAM_VERSION_VCU}  cuoam_24r2
    ...     Cloud BTS Test Setup
    ...     Connect To VCU
    ...     Cloud BTS Test Teardown

    vcu.Connect To  host=${VCU_OAM_CONNECTION.addr}  port=${VCU_OAM_CONNECTION.port}
    ...  username=${VCU_OAM_CONNECTION.username}  password=${VCU_OAM_CONNECTION.password}
    ...  cu_version=${CU_OAM_VERSION_VCU}  secure=True


Check Status For Perform VCU Delta Plan Recommissioning
    [Documentation]
    ...  KW used to check status of plan activation for KW 'Get Status Of Perform Delta Recommissioning' from taf.gnb.oam.coam.cu library.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | operation_id           | Yes  | Id of plan that needs its status to be checked.                       |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Connect To VCU
    ...     ${plan_data} =  vcu.Perform Delta Recommissioning  delta_file=${CURDIR}${/}delta.json
    ...     Wait Until Keyword Succeeds  120s  10s  Check Status For Perform VCU Delta Plan Recommissioning  ${plan_data['id']}

    [Arguments]  ${operation_id}
    ${status} =  vcu.Get Status Of Perform Delta Recommissioning  ${operation_id}

    Should Be True  '${status['status']}' == 'success'
    ...  msg=Status of recommissioning vCU delta plan (${status}) was different than 'success'.


Check Status For Fast Activation For Delta Plan On VDU
    [Documentation]
    ...  KW used to check status of plan activation for KW 'Fast Activations For Delta Plan' from taf.gnb.oam.coam.vdu library.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | plan_id                | Yes  | Id of plan that needs its status to be checked.                       |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${payload} =  Set Variable  {"actPdcchSharingWithPdsch": false}
    ...     Connect To VDU
    ...     ${plan_data} =  vdu.Fast Activations For Delta Plan  class_name=NRCELL
    ...     ...  dist_name=MRBTS-1234/NRBTS-1234/NRCELL-1111
    ...     ...  operation=update  payload=${payload}
    ...     Wait Until Keyword Succeeds  120s  10s
    ...     ...  Check Status For Fast Activation For Delta Plan On VDU  ${plan_data['id']}

    [Arguments]  ${plan_id}
    ${status} =  vdu.Get Fast Activation Operation Of Delta Plan  operation_id=${plan_id}

    Should Be True  '${status['status']}' == 'success'
    ...  msg=Status of fast activation for delta plan on vDU (${status}) was different than 'success'.


Get Counter List For VDU
    [Documentation]
    ...  KW used to get list of counter values from vDU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to get list of counter values from vDU.
    ...  It checks if time for first counter from the returned list is greater than time passed in ${start_time}.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | counter_id             | Yes  | Counter ID. E.g. M55335C02019                                         |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | dimension_dn           | Yes  | Dist name for dimension to which counter belongs.                     |
    ...  |                        |      | E.g. MRBTS-1234/NRBTS-1234/NRCELL-1111.                               |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | counter_amount         | Yes  | How many of the last counter values should be returned in list.       |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | start_time             | Yes  | Time that needs to be lower than the time for first collected counter |
    ...  |                        |      | in format %Y-%m-%dT%H:%M:%S.                                          |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${start_time} =  Get Time From BTS  host_ip=12.34.56.78  user=abc  password=qbc123
    ...     ...  date_time_format=%Y-%m-%dT%H:%M:%S
    ...     Sleep  6 min  reason=Wait for counters.
    ...     Get Counter List For VDU  counter_id=M55335C02020
    ...     ...  dimension_dn=MRBTS-1234/NRBTS-1234/NRCELL-1111
    ...     ...  counter_amount=3  start_time=${start_time}

    [Arguments]  ${counter_id}  ${dimension_dn}  ${counter_amount}  ${start_time}

    ${counter_data} =  vdu.Get Counter Values  counter_id=${counter_id}  dimension_dn=${dimension_dn}
    ${counter_dictionaries} =  Set Variable  ${counter_data[-${counter_amount}:]}
    _counter time check helper  ${counter_dictionaries[0]['start_time']}  ${start_time}
    ${counter_list} =  Evaluate  [x['value'] for x in ${counter_dictionaries}]

    [Return]  ${counter_list}


Get Counter List For VCU
    [Documentation]
    ...  KW used to get list of counter values from vCU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to get list of counter values from vCU.
    ...  It checks if time for first counter from the returned list is greater than time passed in ${start_time}.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | counter_id             | Yes  | Counter ID. E.g. M55162C00012                                         |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | dimension_dn           | Yes  | Dist name for dimension to which counter belongs.                     |
    ...  |                        |      | E.g. MRBTS-1234/NRBTS-1234/NRCELL-1111.                               |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | counter_amount         | Yes  | How many of the last counter values should be returned in list.       |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | start_time             | Yes  | Time that needs to be lower than the time for first collected counter |
    ...  |                        |      | in format %Y-%m-%dT%H:%M:%S.                                          |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${start_time} =  Get Time From BTS  host_ip=12.34.56.78  user=abc  password=qbc123
    ...     ...  date_time_format=%Y-%m-%dT%H:%M:%S
    ...     Sleep  6 min  reason=Wait for counters.
    ...     Get Counter List For VCU  counter_id=M55162C00012
    ...     ...  dimension_dn=MRBTS-1234/NRBTS-1234/NRCELL-1111
    ...     ...  counter_amount=3  start_time=${start_time}

    [Arguments]  ${counter_id}  ${dimension_dn}  ${counter_amount}  ${start_time}  ${connection}=default

    ${counter_data} =  vcu.Get Counter  counter_id=${counter_id}  dimension_dist_name=${dimension_dn}
    ...  connection=${connection}  measurement_id=${None}
    ${counter_dictionaries} =  Set Variable  ${counter_data['values'][-${counter_amount}:]}
    _counter time check helper  ${counter_dictionaries[0]['start_time']}  ${start_time}
    ${counter_list} =  Evaluate  [x['value'] for x in ${counter_dictionaries}]

    [Return]  ${counter_list}


_counter time check helper
    [Arguments]  ${counter_time}  ${start_time}

    ${counter_time}  ${_} =  Split String From Right  ${counter_time}  separator=+
    ${difference} =  Subtract Date From Date  ${counter_time}  ${start_time}
    ...  date1_format=%Y-%m-%dT%H:%M:%S  date2_format=%Y-%m-%dT%H:%M:%S
    Should Be True  ${difference} > 0
    ...  msg=Time for first value is incorrect. Time of first value: ${counter_time}\nStart time:${start_time}


Wait For New Counter Period
    [Documentation]
    ...  KW waits for new counter period.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW waits for new counter period. It requires ${VDU_MASTER_SSH_DETAILS} dictionary with keys
    ...  'addr', 'username' and 'password' to work. This KW gets time from vDU and calculates
    ...  waitnig time for new counter period. If calculated time is greater than ${waiting_time1}
    ...  the wait is skipped (since it would mean that we test is already in a new period - this can be used
    ...  to skip potentially not needed wait.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter                   | Man. | Description                                                           |
    ...  +=============================+======+=======================================================================+
    ...  | waiting_time1               | No   | Waiting time in seconds. If current waiting time for new counter      |
    ...  |                             |      | period is greater than this value KW will not wait and just end.      |
    ...  |                             |      | Default value:9999999.                                                |
    ...  +-----------------------------+------+-----------------------------------------------------------------------+
    ...  | additional_waiting_time     | No   | Additional waiting time in seconds needed for counters files          |
    ...  |                             |      | to appear after the measurement ends. New period starting               |
    ...  |                             |      | a little later after previous.                                        |
    ...  +-----------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Wait For New Counter Period
    ...     ${waiting_time1} =  Count Measurement Period  ${VDU_MASTER_SSH_DETAILS.addr}  ${COUNTER_PERIOD}
    ...     user=${VDU_MASTER_SSH_DETAILS.username}  password=${VDU_MASTER_SSH_DETAILS.password}
    ...     Start Collecting Logs With UTF  12345
    ...     Sleep  3s    reason=Wait for TTI to be collected.
    ...     Wait For New Counter Period  ${waiting_time1}

    [Arguments]  ${waiting_time1}=9999999    ${additional_waiting_time}=0

    ${current_waiting_time} =  Count Measurement Period  ${VDU_MASTER_SSH_DETAILS.addr}  ${COUNTER_PERIOD}
    ...  user=${VDU_MASTER_SSH_DETAILS.username}  password=${VDU_MASTER_SSH_DETAILS.password}
    Return From Keyword If  ${waiting_time1} < ${current_waiting_time}
    ${full_waiting_time}=  Evaluate  ${current_waiting_time} + ${additional_waiting_time}
    Log  Wait ${current_waiting_time}s till new period of counter is started plus ${additional_waiting_time}s,  console=True
    Log  needed for counters files to appear after the measurement ends.  console=True
    Sleep  ${full_waiting_time}s  reason=Wait till new period of counter is started.
    [Return]  ${full_waiting_time}


Prepare UE For Data Transfer
    [Arguments]  ${ue_alias}  ${cell_id}  ${ip_check}=True  ${retry}=1x  ${retry_interval}=2min  ${connection}=default
    Wait Until Keyword Succeeds  ${retry}  ${retry_interval}
    ...  _prepare ue for data transfer helper for cloud bts  ${ue_alias}  ${cell_id}  ${ip_check}  ${connection}


_prepare ue for data transfer helper for cloud bts
    [Arguments]  ${ue_alias}  ${cell_id}  ${ip_check}  ${connection}=default
    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Run Keywords
    ...         Log  ${ue_alias} was not in given cell or was not granted an IP address. Trying again...  console=True  AND  Detach UE  ${ue_alias}

    Attach UE   ${ue_alias}  timeout=60

    ${cell_id} =  _get cell id for cloud bts data transfer helper  ${cell_id}  ${connection}

    ${cell_id_string}=  Convert To String  ${cell_id}
    ${cell_id}=  Set Variable If  type(${cell_id}) is not bytes  ${cell_id_string}  ${cell_id}

    Wait Until Keyword Succeeds  5x  10s  Validate UE Info  ${ue_alias}  CELL_ID  ${cell_id}
    ${ue_ip}=  Run Keyword If  ${ip_check}  Wait Until Keyword Succeeds  5x  10s  Get UE Info  ${ue_alias}  IP
    ...  ELSE  Set Variable  ${None}
    Run Keyword If  ${ip_check}  Should Match Regexp  ${ue_ip}  \\d+\\.\\d+\\.\\d+\\.\\d+


_get cell id for cloud bts data transfer helper
    [Arguments]  ${cell_id}  ${connection}=default
    Connect To VDU
    ${cell_dict_list} =  vdu.Get VDU Cell ID  vdu_connection=${connection}
    ${nr_cell_id} =  Evaluate  [x for x in ${cell_dict_list} if 'NRCELL-${cell_id}' in x]
    ${cell_id} =  Set Variable If  ${nr_cell_id}  ${nr_cell_id}  ${cell_id}
    [Teardown]  vdu.Disconnect
    [Return]  ${cell_id}


Start Wireshark Log Collection For VCU
    [Documentation]
    ...  KW used to start collection of wireshark logs using tcpdump for vCU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to start collection of wireshark logs using tcpdump on remote host. It requires
    ...  dictionary ${VCU_MASTER_SSH_DETAILS} with keys addr, username and password to run correctly.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------------+------+------------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                                                            |
    ...  +=======================+======+========================================================================+
    ...  | namespace             | Yes  | Namespace of vDU.                                                      |
    ...  +-----------------------+------+------------------------------------------------------------------------+
    ...  | tcpdump_options       | No   | Options string for TCPDump collectors. Default value: '-i any -n'.     |
    ...  +-----------------------+------+------------------------------------------------------------------------+
    ...  | kubectl_exec_options  | No   | Options string for kubectl exec command. Default value: ${None}.       |
    ...  +-----------------------+------+------------------------------------------------------------------------+
    ...  | host_ip               | No   | IP of host (vDU) on which tcpdump should to be collected.              |
    ...  |                       |      | Default is: ${VCU_MASTER_SSH_DETAILS.addr}.                            |
    ...  +-----------------------+------+------------------------------------------------------------------------+
    ...  | user                  | No   | Username of host (vDU) on which tcpdump should to be collected.        |
    ...  |                       |      | Default is: ${VCU_MASTER_SSH_DETAILS.username}.                        |
    ...  +-----------------------+------+------------------------------------------------------------------------+
    ...  | password              | No   | Password of host (vDU) on which tcpdump should to be collected.        |
    ...  |                       |      | Default is: ${VCU_MASTER_SSH_DETAILS.password}.                        |
    ...  +-----------------------+------+------------------------------------------------------------------------+
    ...  | alias                 | No   | Alias used for tcpdump. Default: tcpdump.                              |
    ...  +-----------------------+------+------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Start Wireshark Log Collection For VDU  namespace=cran8680

    [Arguments]  ${namespace}  ${tcpdump_options}=-i any -n  ${kubectl_exec_options}=${None}
    ...  ${host_ip}=${VCU_MASTER_SSH_DETAILS.addr}  ${user}=${VCU_MASTER_SSH_DETAILS.username}
    ...  ${password}=${VCU_MASTER_SSH_DETAILS.password}  ${alias}=tcpdump

    ${vcu_sw_version}=  Get VCU Software Version
    IF  '${kubectl_exec_options}' == '${None}' and '25R3' not in '${vcu_sw_version}'
        ${kubectl_exec_options} =  Set Variable  -n ${namespace} po-cpif-0 -c ctr-nwmgmt
    ELSE IF  '${kubectl_exec_options}' == '${None}'
        ${kubectl_exec_options} =  Set Variable  -n ${namespace} po-${namespace}-cpif-0 -c ctr-${namespace}-nwmgmt
    END

    &{vdu}=  Create Dictionary
    ...  host=${host_ip}
    ...  user=${user}
    ...  password=${password}
    tcpdump.Create K8s Kubectl Tcpdump Collector
    ...  name=${alias}
    ...  options=${tcpdump_options}
    ...  kubectl_exec_options=${kubectl_exec_options}
    ...  executor=${vdu}

    core.Setup Collectors  names=${alias}
    core.Start Collectors  names=${alias}
    core.Set Test Alias  ${alias}
    Sleep  10s  reason=Let the log start before proceeding with test

    Log  Wireshark log collection started.  console=True


Setup TTI Decoder For VDU
    [Documentation]
    ...  KW used to setup tti decoder for vDU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...  | **Maintainer:** monika.ceglarek@nokia.com
    ...
    ...  **Full description:**
    ...
    ...  KW used to download and install *_tti-dec.deb package for current vDU build.
    ...  **Input parameters:**
    ...
    ...  +------------------------+------+------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                |
    ...  +========================+======+============================================================+
    ...  | download_dir           | No   | Absolute path to download directory. Default value: /tmp.  |
    ...  +------------------------+------+------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...     Setup TTI Decoder For VDU

    [Arguments]  ${download_dir}=/tmp

    Log  \nSetting up TTI decoder  console=True
    ${vdu_sw_version} =  Get VDU Software Version
    ${download_path} =  Download TTI Dec  ${vdu_sw_version}  ${download_dir}
    ${result} =  Process.Run Process  sudo dpkg -i ${download_path}  shell=True

    IF  int(${result.rc}) != int(0)
        Run Keyword If  "${result.stderr}" != ""
        ...  Log  level=WARN  console=True
        ...       message=Errors appeared while executing command: sudo dpkg -i ${download_dir}/tti_dec.deb.\nError message: ${result.stderr}
        Should Be Equal As Integers  ${result.rc}  0
        ...  msg=RC is not equal to 0. There were some errors during execution of dpkg command.\nError message: ${result.stderr}.
    END
    Log  \nNew version of TTI decoder was successfully installed  console=True


Convert 5G TTI With Eventdecoder Options
    [Documentation]
    ...  Converts 5G TTI .PCAP file to CSV with event decoder options.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Converts 5G TTI .PCAP file to CSV with event decoder options.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | input_file_path        | Yes  | Absolute path to TTI .PCAP file.                                      |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | output_file_path       | No   | Absolute path to dictionary where converted files will be saved.      |
    ...  |                        |      | Default value: ${LOG_PATH}/misc_logs.                                 |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | file_name              | No   | Name of converted file. Event decoder may add numbers in case         |
    ...  |                        |      | more files are created. Default value: NR_TTI.                        |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | eventdecoder_options   | No   | Event decoder options same as in 'create_eventdecoder_converter'      |
    ...  |                        |      | from taf.converters.eventdecoder. Default value: --split 2000000.     |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...    Verify BTS States For Cloud BTS - Locked Cell  12345

    [Arguments]  ${input_file_path}  ${output_file_path}=${LOG_PATH}/misc_logs  ${file_name}=NR_TTI
    ...  ${eventdecoder_options}=--split 2000000

    Log  Converting file ${input_file_path} to CSV...  console=True
    eventdecoder.Create eventDecoder Converter
    ...  name=converter
    ...  input_file_path=${input_file_path}
    ...  output_file_path=${output_file_path}/${file_name}
    ...  output_file_format=excelCsv
    ...  eventdecoder_options=${eventdecoder_options}
    eventdecoder.Convert
    ...  name=converter
    Log  Conversion finished files should be available in ${output_file_path}.  console=True


Get VDU Software Version
    [Documentation]
    ...  KW used to get vDU software version. In case of trunk SW the release number is replaced with '00'.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...  | **Maintainer:** monika.ceglarek@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...     Get VDU Software Version

    Connect To VDU
    ${vdu_data} =  vdu.Get VDU State Data
    ${vdu_sw_version} =  Downloader.Check And Modify SW Version  ${vdu_data['software_version']}
    Log  Current vDU SW version: ${vdu_sw_version}  console=True
    [Return]  ${vdu_sw_version}
    [Teardown]  vdu.Disconnect


Get VCU Software Version
    [Documentation]
    ...  KW used to get vCU software version. In case of trunk SW the release number is replaced with '00'.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...  | **Maintainer:** monika.ceglarek@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...     Get VCU Software Version

    Connect To VCU
    ${vcu_sw_version} =  vcu.Get Active Software Version
    ${vcu_sw_version} =  Downloader.Check And Modify SW Version  ${vcu_sw_version}
    Log  Current vCU SW version: ${vcu_sw_version}  console=True
    [Return]  ${vcu_sw_version}
    [Teardown]  vcu.Disconnect


Get FHGW Data From Init File For Single DU
    [Documentation]
    ...  Gets connection details for FHGW from __init__.py file.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Gets connection details for FHGW from __init__.py file. For this KW to work ${tl.gnbs[0].dus[0].fhgws[0]}
    ...  needs to exist. Otherwise this KW will return three ${None} values.
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...    Get FHGW Data From Init File For Single DU

    ${fhgw_exists} =  Run Keyword And Return Status  Variable Should Exist  ${tl.gnbs[0].dus[0].fhgws[0]}
    Return From Keyword If  not ${fhgw_exists}  ${None}  ${None}  ${None}
    ${fhgw_connection_data} =  Set Variable  ${tl.gnbs[0].dus[0].fhgws[0].default_ssh_connection_details}

    [Return]  ${fhgw_connection_data.addr}  ${fhgw_connection_data.username}  ${fhgw_connection_data.password}


Get FHGW SW Version
    [Documentation]
    ...  Gets FHGW software version.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW gets FHGW software version. It uses keyword 'FHGW Get SW Release' from taf.hw.fhgw.cli library.
    ...  Keyword 'FHGW Get SW Build' also exists in that library, however the former one was chosen,
    ...  due to the returned value being used during reporting of FHGW SW in reporting portal.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | ip                     | Yes  | IP used for connecting to FHGW through SSH.                           |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | username               | Yes  | Username used for connecting to FHGW through SSH.                     |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | password               | Yes  | Password used for connecting to FHGW through SSH.                     |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...    ${ip}  ${username}  ${password} =  Get FHGW Data From Init File For Single DU
    ...    IF  '${ip}' != '${None}'  Get FHGW SW Version  ${ip}  ${username}  ${password}

    [Arguments]  ${ip}  ${username}  ${password}

    taf.hw.fhgw.cli.Connect To  ${ip}  ${username}  ${password}
    ${fhgw_sw_version} =  taf.hw.fhgw.cli.FHGW Get SW Release
    Log  FHGW SW version: ${fhgw_sw_version}  console=True
    [Teardown]  taf.hw.fhgw.cli.Disconnect
    RETURN  ${fhgw_sw_version}


Get OCP Version
    [Documentation]
    ...  Gets OCP software version.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | ip                     | Yes  | IP used for connecting to OCP through SSH.                            |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | username               | Yes  | Username used for connecting to OCP through SSH.                      |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | password               | Yes  | Password used for connecting to OCP through SSH.                      |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...    Cloud BTS Test Setup
    ...    Get OCP Version  ${VDU_MASTER_SSH_DETAILS.addr}  ${VDU_MASTER_SSH_DETAILS.username}  ${VDU_MASTER_SSH_DETAILS.password}
    ...    Cloud BTS Test Teardown

    [Arguments]  ${ip}  ${username}  ${password}

    taf.transport.ssh.Connect To  ${ip}  ${username}  ${password}  alias=ocp
    ${result} =  taf.transport.ssh.Execute  oc version  connection=ocp
    ${version} =  Get Regexp Matches  ${result}  Server Version:\\s*(.+\\d)  1
    [Teardown]  taf.transport.ssh.Disconnect  connection=ocp
    [Return]  OCP ${version[0]}


Get vDU OCP Version
    [Documentation]
    ...  Gets OCP software version for vDU based on __init__.py data.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Gets OCP software version for vDU based on __init__.py data. It requires dictionary
    ...  ${VDU_MASTER_SSH_DETAILS} with keys addr, username and password to work correctly.
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...    Get vDU OCP Version

    ${vdu_ocp_version} =  Get OCP Version  ${VDU_MASTER_SSH_DETAILS.addr}  ${VDU_MASTER_SSH_DETAILS.username}  ${VDU_MASTER_SSH_DETAILS.password}
    Log  vDU OCP version: ${vdu_ocp_version}  console=True
    RETURN  ${vdu_ocp_version}


Get vCU OCP Version
    [Documentation]
    ...  Gets OCP software version for vCU based on __init__.py data.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Gets OCP software version for vCU based on __init__.py data. It requires dictionary
    ...  ${VDU_MASTER_SSH_DETAILS} with keys addr, username and password to work correctly.
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...    Get vCU OCP Version

    ${vcu_ocp_version} =  Get OCP Version  ${VDU_MASTER_SSH_DETAILS.addr}  ${VDU_MASTER_SSH_DETAILS.username}  ${VDU_MASTER_SSH_DETAILS.password}
    Log  vCU OCP version: ${vcu_ocp_version}  console=True
    RETURN  ${vcu_ocp_version}


Get AP Data From Init File
    [Documentation]
    ...  Gets connection details for AP from __init__.py file.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Gets connection details for Airphone from __init__.py file. For this KW to work ${tl.ues[0].l1.common_units[0]}
    ...  needs to exist. Otherwise this KW will return three ${None} values.
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...    Get AP Data From Init File


    ${ap_exists} =  Run Keyword And Return Status  Variable Should Exist  ${tl.ues[0].l1.common_units[0]}
    IF  not ${ap_exists}  RETURN  ${None}  ${None}  ${None}
    ${ap_connection_data} =  Set Variable  ${tl.ues[0].l1.common_units[0].lmp_connection}
    RETURN  ${ap_connection_data.addr}  ${ap_connection_data.username}  ${ap_connection_data.password}


Get AP SW Version
    [Documentation]
    ...  Gets AP software version.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | ip                     | Yes  | IP used for connecting to AP through SSH.                             |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | username               | Yes  | Username used for connecting to AP through SSH.                       |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | password               | Yes  | Password used for connecting to AP through SSH.                       |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...    ${ip}  ${username}  ${password} =  Get AP Data From Init File
    ...    Get AP SW Version  ${ip}  ${username}  ${password

    [Arguments]  ${ip}  ${username}  ${password}

    taf.transport.ssh.Connect To  ${ip}  ${username}  ${password}  alias=ap
    ${result} =  taf.transport.ssh.Execute  ls /ffs/run/ | grep TargetBD  connection=ap
    ${version} =  Get Regexp Matches  ${result}  TargetBD_(.+).xml  1
    [Teardown]  taf.transport.ssh.Disconnect  connection=ap
    RETURN  ${version[0]}


Perform Commissioning On VCU
    [Documentation]
    ...  KW performs commissioning on vCU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | scf_path               | Yes  | Absolute path to SCF.                                                 |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Perform Commissioning On VCU  /home/ute/Downloads/SCF.xml

    [Arguments]  ${scf_path}

    Connect To VCU
    Log  Performing commissioning on vCU...  console=True
    vcu.Perform Commissioning  scf_file=${scf_path}
    [Teardown]  vcu.Disconnect


Perform Commissioning On VDU
    [Documentation]
    ...  KW performs commissioning on vDU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | scf_path               | Yes  | Absolute path to SCF.                                                 |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Perform Commissioning On VDU  /home/ute/Downloads/SCF.xml

    [Arguments]  ${scf_path}

    Connect To VDU
    Log  Performing commissioning on vDU...  console=True
    vdu.Perform Commissioning  scf_file=${scf_path}
    [Teardown]  vdu.Disconnect


Check If Cell Lock Operation Ended
    [Documentation]
    ...  KW checks if cell lock operation ended.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | operation_id           | Yes  | ID of cell lock operation.                                            |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${cell_list} =  Create List  12345
    ...     Connect To VDU
    ...     ${operation_info} =  vdu.Lock Cells  ${cell_list}
    ...     Wait Until Keyword Succeeds  1min  5s  Check If Cell Lock Operation Ended  ${operation_info['id']}

    [Arguments]  ${operation_id}
    ${operation_data} =  vdu.Get Operation State Of Locking Cells  ${operation_id}
    Should Be True  '${operation_data['status']}' == 'success'  msg=Operation did not end with success or is ongoing.


Check If Cell Unlock Operation Ended
    [Documentation]
    ...  KW checks if cell unlock operation ended.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | operation_id           | Yes  | ID of cell unlock operation.                                          |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${cell_list} =  Create List  12345
    ...     Connect To VDU
    ...     ${operation_info} =  vdu.Unlock Cells  ${cell_list}
    ...     Wait Until Keyword Succeeds  1min  5s  Check If Cell Unlock Operation Ended  ${operation_info['id']}

    [Arguments]  ${operation_id}
    ${operation_data} =  vdu.Get Operation State Of Unlocking Cells  ${operation_id}
    Should Be True  '${operation_data['status']}' == 'success'  msg=Operation did not end with success or is ongoing.


Get QXDM Licence
    [Documentation]
    ...  KW setups Licence Keeper, logins to it and gets licences for 5G QXDM and QCAT.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Get QXDM Licence

    Wait Until Keyword Succeeds  3x  60s  _setup and login to licence keeper helper
    license.Get Licence QXDM 5G
    license.Get Licence QCAT 5G


_setup and login to licence keeper helper
    ${launcher} =  Create Dictionary
    ...  host=${QXDM_CONNECTION.pc_ip}
    ...  path=/cygdrive/c/QPM_LK
    ...  user=${QXDM_CONNECTION.pc_login}
    ...  password=${QXDM_CONNECTION.pc_password}
    license.Setup  launcher=${launcher}
    license.Login  username=${QXDM_CONNECTION.lk_login}
    ...  password=${QXDM_CONNECTION.lk_password}


Release QXDM Licence
    [Documentation]
    ...  KW releases 5G QXDM and QCAT licences and logs out of Licence Keeper.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Release QXDM Licence

    license.Release Licence QXDM 5G
    license.Release Licence QCAT 5G
    license.Logout
    license.Teardown


Check Energy Saving State For NR Cell On VDU
    [Documentation]
    ...  KW used to check energy saving state for NR cell on vDU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to check energy saving state for NR cell on vDU. This KW connects and disconnects from vDU.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                          |
    ...  +========================+======+======================================================================+
    ...  | mrbts_id               | Yes  | ID of MRBTS for cell which is checked.                               |
    ...  +------------------------+------+----------------------------------------------------------------------+
    ...  | nrbts_id               | Yes  | ID of NRBTS for cell which is checked.                               |
    ...  +------------------------+------+----------------------------------------------------------------------+
    ...  | nr_cell_id             | Yes  | NR cell ID for cell which is checked.                                |
    ...  +------------------------+------+----------------------------------------------------------------------+
    ...  | expected_saving_state  | Yes  | Expected energy saving state for cell. Possible values:              |
    ...  |                        |      | reducedEnergySaving and notEnergySaving.                             |
    ...  +------------------------+------+----------------------------------------------------------------------+
    ...  | log_messages           | No   | Boolean value for determining if log information regarding current   |
    ...  |                        |      | energy saving state should be printed. Default value: True.          |
    ...  +------------------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Check Energy Saving State For NR Cell On VDU Using SCF  123451  12345  1  reducedEnergySaving

    [Arguments]  ${mrbts_id}  ${nrbts_id}  ${nr_cell_id}  ${expected_saving_state}  ${log_messages}=True

    Connect To VDU
    ${energy_saving_state} =  vdu.Search Parameter Of Current Plan  MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nr_cell_id}
    ...  energySavingState
    Run Keyword If  ${log_messages}  Run Keywords
    ...  Log  \nFor cell ${nr_cell_id}: \nCurrent energy saving state: ${energy_saving_state}.  console=True
    ...  AND  Log  \nExpected energy saving state: ${expected_saving_state}  console=True
    Should Be Equal As Strings  ${energy_saving_state}  ${expected_saving_state}
    ...  msg=Current energy saving state: ${energy_saving_state} is different than expected: ${expected_saving_state}

    [Teardown]  vdu.Disconnect


Save SCF VDU
    [Documentation]
    ...  Saves SCF from vDU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Saves SCF from vDU. Opens and closes connection to vDU. Requires ${LOG_PATH} global
    ...  variable with path to logs directory to be set before it is run.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                          |
    ...  +========================+======+======================================================================+
    ...  | scf_name               | No   | Name of SCF file, e.g. SCF.xml. Default value: vDU_SCF.xml.          |
    ...  +------------------------+------+----------------------------------------------------------------------+
    ...  | scf_path               | No   | Absolute path where SCF should be saved.                             |
    ...  |                        |      | Default value: ${LOG_PATH}/misc_logs                                 |
    ...  +------------------------+------+----------------------------------------------------------------------+
    ...  | include_runtime_data   | No   | Argument 'include_runtime_data' for 'Get Current Plan File' KW.      |
    ...  |                        |      | Default value: True.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Save SCF VDU  vDU_SCF1.xml  /tmp  include_runtime_data=False

    [Arguments]  ${scf_name}=vDU_SCF.xml  ${scf_path}=${LOG_PATH}/misc_logs  ${include_runtime_data}=True

    Connect To VDU
    vdu.Get Current Plan File  local_dir_path=${scf_path}  filename=${scf_name}  include_runtime_data=${include_runtime_data}

    [Teardown]  vdu.Disconnect


Save SCF VCU
    [Documentation]
    ...  Saves SCF from vCU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Saves SCF from vCU. Opens and closes connection to vCU. Requires ${LOG_PATH} global
    ...  variable with path to logs directory to be set before it is run.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                          |
    ...  +========================+======+======================================================================+
    ...  | scf_name               | No   | Name of SCF file, e.g. SCF.xml. Default value: vCU_SCF.xml.          |
    ...  +------------------------+------+----------------------------------------------------------------------+
    ...  | scf_path               | No   | Absolute path where SCF should be saved.                             |
    ...  |                        |      | Default value: ${LOG_PATH}/misc_logs                                 |
    ...  +------------------------+------+----------------------------------------------------------------------+
    ...  | include_runtime_data   | No   | Argument 'include_runtime_data' for 'Get Current Plan File' KW.      |
    ...  |                        |      | Default value: True.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Save SCF VCU  vCU_SCF1.xml  /tmp  include_runtime_data=False

    [Arguments]  ${scf_name}=vCU_SCF.xml  ${scf_path}=${LOG_PATH}/misc_logs  ${include_runtime_data}=True

    Connect To VCU
    vcu.Get Current Plan File  path=${scf_path}/${scf_name}  include_runtime_data=${include_runtime_data}

    [Teardown]  vcu.Disconnect


Get Energy Saving State Of NR Cell
    [Documentation]
    ...  Gets energy saving state of NR cell.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+--------------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                              |
    ...  +========================+======+==========================================================================+
    ...  | cell_id                | Yes  | Either cell ID or distname. E.g. MRBTS-1234/NRBTS-1234/NRCELL-5 or 5.    |
    ...  +------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${energy_saving_state} =  Get Energy Saving State Of NR Cell  1234

    [Arguments]  ${cell_id}

    Connect To VDU
    ${cell_info} =  vdu.Get Cell Specific Info  ${cell_id}

    [Teardown]  vdu.Disconnect
    [Return]  ${cell_info['energySavingState']}


Get NRBTS ID From VDU
    [Documentation]
    ...  Gets NRBTS ID from vDU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+--------------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                              |
    ...  +========================+======+==========================================================================+
    ...  | set_for_test           | No   | Boolean variable. If set to true sets test variable ${NRBTS_ID}.         |
    ...  |                        |      | Default value: True.                                                     |
    ...  +------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${nrbts_id} =  Get NRBTS ID From VDU

    [Arguments]  ${set_for_test}=True

    ${class_list} =  Create List  NRBTS
    Connect To VDU
    ${nrbts_dist_name} =  vdu.Get Current Plan Objects  class_name=${class_list}
    ${nrbts_id} =  Convert Dist Name To ID  ${nrbts_dist_name['objects'][0]['distName']}
    IF  ${set_for_test}  Set Test Variable  ${NRBTS_ID}  ${nrbts_id}

    [Teardown]  vdu.Disconnect
    [Return]  ${nrbts_id}


Get MRBTS ID From VDU
    [Documentation]
    ...  Gets MRBTS ID from vDU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+--------------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                              |
    ...  +========================+======+==========================================================================+
    ...  | set_for_test           | No   | Boolean variable. If set to true sets test variable ${VDU_MRBTS_ID}.     |
    ...  |                        |      | Default value: True.                                                     |
    ...  +------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${mrbts_id} =  Get MRBTS ID From VDU

    [Arguments]  ${set_for_test}=True

    ${class_list} =  Create List  MRBTS
    Connect To VDU
    ${mrbts_dist_name} =  vdu.Get Current Plan Objects  class_name=${class_list}
    ${mrbts_id} =  Convert Dist Name To ID  ${mrbts_dist_name['objects'][0]['distName']}
    IF  ${set_for_test}  Set Test Variable  ${VDU_MRBTS_ID}  ${mrbts_id}

    [Teardown]  vdu.Disconnect
    [Return]  ${mrbts_id}


Get MRBTS ID From VCU
    [Documentation]
    ...  Gets MRBTS ID from vCU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+--------------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                              |
    ...  +========================+======+==========================================================================+
    ...  | set_for_test           | No   | Boolean variable. If set to true sets test variable ${VCU_MRBTS_ID}.     |
    ...  |                        |      | Default value: True.                                                     |
    ...  +------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${mrbts_id} =  Get MRBTS ID From VCU

    [Arguments]  ${set_for_test}=True

    Connect To VCU
    ${mrbts_data} =  vcu.Search Parameters Of Current Plan  parameter_name=mrbtsId
    IF  ${set_for_test}  Set Test Variable  ${VCU_MRBTS_ID}  ${mrbts_data['items'][0]['parameter']['simple_parameter']['value']}

    [Teardown]  vcu.Disconnect
    [Return]  ${mrbts_data['items'][0]['parameter']['simple_parameter']['value']}


Get NR Cell Identity From VDU
    [Documentation]
    ...  Gets NR cell identity from vDU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+--------------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                              |
    ...  +========================+======+==========================================================================+
    ...  | nr_cell_id             | Yes  | ID of NR cell ID (New Radio Cell instance identifier).                   |
    ...  +------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${nr_cell_identity} =  Get NR Cell Identity From VDU  1234

    [Arguments]  ${nr_cell_id}

    ${vdu_mrbts_id} =  Get MRBTS ID From VDU  set_for_test=False
    ${nrbts_id} =  Get NRBTS ID From VDU  set_for_test=False
    Connect To VDU
    ${nr_cell_identity} =  vdu.Search Parameter Of Current Plan  mo_dn=MRBTS-${vdu_mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nr_cell_id}
    ...  para_name=nrCellIdentity

    [Teardown]  vdu.Disconnect
    [Return]  ${nr_cell_identity}


Get Cell IDs Of All Cells Currently In EnergySaving State
    [Documentation]
    ...  Gets cell IDs of all cells currently in energySaving state.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${energy_saving_cells} =  Get Cell IDs Of All Cells Currently In EnergySaving State

    Connect To VDU
    ${cells_data} =  vdu.Get VDU Cell ID
    vdu.Disconnect
    ${energy_saving_cells} =  Create List
    FOR  ${cell_data}  IN  @{cells_data}
        ${cell_name} =  Get Dictionary Keys  ${cell_data}
        ${cell_id} =  Fetch From Right  ${cell_name[0]}  -
        ${energy_saving_state} =  Get Energy Saving State Of NR Cell  ${cell_id}
        IF  '${energy_saving_state}' == 'energySaving'  Append To List  ${energy_saving_cells}  ${cell_id}
    END

    [Teardown]  Run Keyword And Ignore Error  vdu.Disconnect
    [Return]  ${energy_saving_cells}


Check If Message Appeared
    [Documentation]
    ...  Checks if specified number of given packet appeared in log.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Checks if specified number of given packet appeared in log with use of command:
    ...  'tshark -r ${tcpdump_path} -Y "${display_filter}" |wc -l'. This KW will fail if:
    ...  - RC is different than 0,
    ...  - stderr file is not empty,
    ...  - stdout is not equal to number of packets specified by user.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+--------------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                              |
    ...  +========================+======+==========================================================================+
    ...  | display_filter         | Yes  | Display filter used to filter messages in pcap log in tshark.            |
    ...  +------------------------+------+--------------------------------------------------------------------------+
    ...  | number_of_messages     | Yes  | Expected number of packets that should exist in pcap log.                |
    ...  +------------------------+------+--------------------------------------------------------------------------+
    ...  | tcpdump_path           | Yes  | Absolute path to pcap log.                                               |
    ...  +------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Check If Message Appeared  x2ap.radioNetwork == 11  1  /home/ute/Downloads/tcpdump.pcap

    [Arguments]  ${display_filter}  ${number_of_messages}  ${tcpdump_path}
    ${result} =  Run Process
    ...  command=tshark -r ${tcpdump_path} -Y "${display_filter}" |wc -l  shell=True
    Should Be Equal As Integers  ${result.rc}  0
    ...  msg=RC is not equal to 0. There were some errors during execution of tshark command.\nError message: ${result.stderr}.
    Should Be Equal As Strings  '${result.stderr}'  ''
    ...  msg=Errors appeared while executing command: tshark -r ${tcpdump_path} -Y "${display_filter}" |wc -l.\nError message: ${result.stderr}
    Should Be True  ${result.stdout} == ${number_of_messages}
    ...  msg=Number of packets for display filter: ${display_filter} is !=${number_of_messages}. Please verify tcpdump logs.
    Log  Messages found in pcap logs with display filter: ${display_filter}.  console=True

Get Start Time
    [Documentation]
    ...  KW used to get time from vDU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to get time from vDU. It requires ${VDU_MASTER_SSH_DETAILS} dictionary with SSH
    ...  data fro vDU with keys 'addr', 'username' and 'password' to work. It also sets test
    ...  variable ${START_TIME}.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+--------------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                              |
    ...  +========================+======+==========================================================================+
    ...  | time_difference         | No  | Sets time difference in minutes.                                         |
    ...  +------------------------+------+--------------------------------------------------------------------------+
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Get Start Time
    [Arguments]  ${time_difference}=0
    ${start_time} =  Get Time From BTS  host_ip=${VDU_MASTER_SSH_DETAILS.addr}  user=${VDU_MASTER_SSH_DETAILS.username}
    ...  password=${VDU_MASTER_SSH_DETAILS.password}  date_time_format=%Y-%m-%dT%H:%M:%S
    ${difference} =  Subtract Time From Date  ${start_time}  ${time_difference} min
    ...  date_format=%Y-%m-%dT%H:%M:%S  result_format=%Y-%m-%dT%H:%M:%S
    Set Test Variable  ${START_TIME}  ${difference}

Get VCU Simple Parameter Value
    [Documentation]
    ...  KW used to get simple parameter value from Cloud WebEM current SCF.
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | dist_name              | Yes  | Distname of managed object to which parameter belongs,                |
    ...  |                        |      | e.g. MRBTS-1/NRBTS-1/NRCELL-1                                         |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | param_name             | Yes  | Name of the parameter to search                                       |
    ...  |                        |      | ("Abbreviation" column in Parameter Editor)                           |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Get VCU Simple Parameter Value
    ...         dist_name=MRBTS-1/NRBTS-1/NRRFSP_PROFILE-1
    ...         param_name=rfsp
    [Arguments]  ${dist_name}  ${param_name}
    Connect To VCU
    ${obj_parameters} =  vcu.Get Parameters  dist_name=${dist_name}
    ${filter_exp} =  Set Variable  lambda item: (item["simple_parameter"] and item["simple_parameter"]["name"] == "${param_name}")
    ${param_dic} =  Evaluate  next(filter(${filter_exp}, @{obj_parameters['parameters']}))
    [Return]  ${param_dic['simple_parameter']['value']}
    [Teardown]  vcu.Disconnect
