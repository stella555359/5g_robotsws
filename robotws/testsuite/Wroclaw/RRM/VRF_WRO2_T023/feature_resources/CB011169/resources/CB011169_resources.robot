*** Settings ***
Documentation
...   contact: Monika Ceglarek

Library     taf.sw.dcap.rd
Library     taf.config.scf
Library     taf.sw.qualcomm.license  WITH NAME  license
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.dcap_manager.DCAPManager  WITH NAME  utf_manager


*** Keywords ***
Verify BTS States For Cloud BTS - Locked Cell
    [Documentation]
    ...  Verifies state of vCU, vDU, RMODS, NR cells and unexpected alarms on both vCU and vDU
    ...  for configuration with locked cell.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | locked_cell_id         | Yes  | ID of locked cell.                                                    |
    ...  +------------------------+------+-----------------------------------------------------------------------+
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
    ...    Verify BTS States For Cloud BTS - Locked Cell  12345

    [Arguments]  ${locked_cell_id}  ${ignored_alarms_vcu}=${None}  ${ignored_alarms_vdu}=${None}

    ${ignored_alarms_vcu_copy} =    Create List    ${ignored_alarms_vcu}
    ${ignored_alarms_vdu_copy} =    Create List    ${ignored_alarms_vdu}
    ${fault_7104} =  Create Dictionary  alarming_object=MRBTS-${VCU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${locked_cell_id}  fault_id=7104
    Append To List  ${ignored_alarms_vcu_copy}  ${fault_7104}
    ${ignored_alarms_vcu_copy} =  Remove Duplicates  ${ignored_alarms_vcu_copy}

    ${vdu_onair} =  Check VDU State
    ${vcu_enabled} =  Check VCU State
    ${rmods_onair} =  Check RMODs States
    ${correct_vdu_nrcells_states} =  Check NR Cells States On VDU For Lock Operation  ${locked_cell_id}
    ${correct_vcu_nrcells_states} =  Check NR Cells States On VCU For Lock Operation  ${locked_cell_id}
    ${alarms_status_vcu} =  Check Unexpected Alarms VCU  ${ignored_alarms_vcu_copy}
    ${alarms_status_vdu} =  Check Unexpected Alarms VDU  ${ignored_alarms_vdu_copy}

    ${statuses_dictionary}=  Create Dictionary
    ...  vcu_enabled=${vcu_enabled}  vdu_onair=${vdu_onair}
    ...  rmods_onair=${rmods_onair}  correct_vdu_nrcells_states=${correct_vdu_nrcells_states}
    ...  correct_vcu_nrcells_states=${correct_vcu_nrcells_states}
    ...  alarms_status_vcu=${alarms_status_vcu}  alarms_status_vdu=${alarms_status_vdu}
    ${pretty_statuses}=  Evaluate  pprint.pformat(${statuses_dictionary}, indent=4)  modules=pprint

    ${correct_nrcells_states} =  Evaluate  ${correct_vdu_nrcells_states} and ${correct_vcu_nrcells_states}
    Should Be True
    ...  ${vcu_enabled} and ${vdu_onair} and ${rmods_onair} and ${correct_nrcells_states} and ${alarms_status_vcu} and ${alarms_status_vdu}
    ...  msg=BTS verification failed. Details:\n${pretty_statuses}


Check NR Cells States On VDU For Lock Operation
    [Documentation]
    ...  Checks state of NR cells from vDU for lock operation.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | locked_cell_id         | Yes  | ID of locked cell.                                                    |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Check NR Cells States On VDU For Lock Operation

    [Arguments]  ${locked_cell_id}

    Connect To VDU
    ${state_summary} =  Set Variable  True
    ${all_cells_data} =  vdu.Get VDU Cells Status
    FOR  ${cell_data}  IN  @{all_cells_data}
        ${cell_info} =  vdu.Get Cell Specific Info  ${cell_data['dist_names']['config']}
        ${energy_saving_state} =  Set Variable  ${cell_info['energySavingState']}
        ${energy_saving_condition} =  Evaluate  '${energy_saving_state}' == 'notEnergySaving' or '${energy_saving_state}' == 'reducedEnergySaving'
        ${energy_saving_condition} =  Evaluate  ${energy_saving_condition} or '${energy_saving_state}' == 'switchingOff'
        ${not_energy_saving_condition} =  Evaluate  '${energy_saving_state}' == 'energySaving' or '${energy_saving_state}' == 'switchingOn'
        ${nr_expected_states} =  IF  '${cell_data['id']}' == '${locked_cell_id}'
        ...  Create Dictionary
        ...  administrativeState=Locked
        ...  availabilityStatus=off line
        ...  blockingState=Unblocked
        ...  operationalState=disabled
        ...  ELSE IF  '${cell_data['id']}' != '${locked_cell_id}' and ${energy_saving_condition}
        ...  Create Dictionary
        ...  administrativeState=Unlocked
        ...  availabilityStatus=on line
        ...  blockingState=Unblocked
        ...  operationalState=enabled
        ...  ELSE IF  '${cell_data['id']}' != '${locked_cell_id}' and ${not_energy_saving_condition}
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


Check NR Cells States On VCU For Lock Operation
    [Documentation]
    ...  Checks state of NR cells from vCU for lock operation.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | locked_cell_id         | Yes  | ID of locked cell.                                                    |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Check NR Cells States On VCU For Lock Operation

    [Arguments]  ${locked_cell_id}

    Connect To VCU
    ${state_summary} =  Set Variable  True
    ${all_cells_data} =  vcu.Get Cells Statuses
    ${cell_ids} =  Get Cell IDs Of All Cells Currently In EnergySaving State
    FOR  ${cell_data}  IN  @{all_cells_data}
        ${cell_id} =  Set Variable  ${cell_data['id']}
        ${nr_expected_states} =  Run Keyword If  '${cell_id}' == '${locked_cell_id}'
        ...  Create Dictionary
        ...  administrative_state=Unlocked
        ...  operational_state=disabled
        ...  ELSE IF  '${cell_id}' != '${locked_cell_id}' and '${cell_id}' not in ${cell_ids}
        ...  Create Dictionary
        ...  administrative_state=Unlocked
        ...  operational_state=enabled
        ...  ELSE IF  '${cell_id}' != '${locked_cell_id}' and '${cell_id}' in ${cell_ids}
        ...  Create Dictionary
        ...  administrative_state=Unlocked
        ...  operational_state=disabled
        ${correct_state} =  _check each state helper  ${cell_data}  ${nr_expected_states}
        ${state_summary} =  Set Variable If  ${correct_state}  ${state_summary}  False
    END

    [Teardown]  vcu.Disconnect
    [Return]  ${state_summary}


Start Collecting Logs With UTF
    [Documentation]
    ...  KW starts collecting logs with UTF.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW starts collecting logs with UTF. Logs are collected with profile vdu_custom_profile=L2Ps_Component.
    ...  It requires following global variables to be set before it is run:
    ...  - ${MAX_UTF_LOGS_DELAY} - Max time in seconds needed for change of UTF logs collecting status to 'running'.
    ...  - ${VDU_OAM_CONNECTION} - Dictionary with vDU OAM connection details. It should contain following keys:
    ...    addr, username, password.
    ...  - ${UTF_HOST} - Dictionary with data for connecting to UTF. It should contain following keys:
    ...    ip, port, login, password.
    ...  This KW creates or sets following test variables:
    ...  -${TRACE_ID} - ID of started traces
    ...  -${UTF_STARTED} - boolean value indicating that UTF logs collection is started. Can be used for conditional
    ...   stopping in teardown.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | nr_cell_id             | Yes  | ID of NR cell.                                                        |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Start Collecting Logs With UTF  12345
    ...     Sleep  3s    reason=Wait for TTI to be collected.
    ...     Stop UTF Traces and Download Logs  ${TRACE_ID}  ue_id=1

    [Arguments]  ${nr_cell_id}

    ${nr_cell_list} =  Create List  ${nr_cell_id}
    ${nr_log_profile} =  Create List  L2Ps_Component
    ${profiles_dictionary} =  Create Dictionary  vdu_custom_profile=${nr_log_profile}
    _start utf helper  ${nr_cell_list}  ${profiles_dictionary}
    Log  Waiting for traces to change status to 'Running'  console=True
    Wait Until Keyword Succeeds  ${MAX_UTF_LOGS_DELAY}  1s  Check If Traces Are Running  ${TRACE_ID}

    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL'  Run Keywords
    ...  Log  Start UTF failed. Please check logs for details.  console=True  level=WARN
    ...  AND  Run Keyword If  ${UTF_STARTED}  Stop UTF Traces and Download Logs  trace_id=${TRACE_ID}  ue_id=${ue_id}


_start utf helper
    [Arguments]  ${nr_cell_list}  ${profiles_dictionary}  ${user}=${VDU_OAM_CONNECTION.username}
    ...  ${password}=${VDU_OAM_CONNECTION.password}

    Log  Connecting to UTF server IP=${UTF_HOST['ip']} on port=${UTF_HOST['port']}  console=True
    utf_manager.Connect To  host=${UTF_HOST['ip']}  port=${UTF_HOST['port']}
    ...  user=${UTF_HOST['login']}  passwd=${UTF_HOST['password']}

    ${vdu_mplane} =  Set Variable  ${VDU_OAM_CONNECTION.addr}
    Log  Using profiles:\n${profiles_dictionary}.\nStarting new trace for IP ${vdu_mplane}...  console=True
    Set Test Variable  ${UTF_STARTED}  True

    ${trace_id} =  utf_manager.Start New Trace  mplane=${vdu_mplane}  user=${user}  passwd=${password}
    ...  port=443  nr_cells=${nr_cell_list}  log_profile=${profiles_dictionary}
    Set Test Variable  ${TRACE_ID}  ${trace_id}

    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL'  Run Keywords
    ...  utf_manager.Stop Trace  trace=${TRACE_ID}
    ...  AND  utf_manager.Teardown
    ...  AND  Set Test Variable  ${UTF_STARTED}  False


Check If Traces Are Running
    [Documentation]
    ...  Checks if traces started with UTF are running for vDU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Checks if traces started with UTF are running for vDU. This KW will pass if traces status
    ...  is 'running' or 'runningWithWarnings'. In case of status 'runningWithWarnings' warning will be printed.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | trace_id               | Yes  | ID of started traces.                                                 |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Start Collecting Logs With UTF  12345
    ...     Sleep  3s    reason=Wait for TTI to be collected.
    ...     Check If Traces Are Running  ${TRACE_ID}
    ...     Stop UTF Traces and Download Logs  ${TRACE_ID}  ue_id=1

    [Arguments]  ${trace_id}

    ${trace_status} =  Get Trace Info By ID  trace_id=${trace_id}  connection=dcap_collector
    ${status} =  Set Variable  ${trace_status['status']}
    ${msg} =  Catenate  Some logs were started with warnings and may not be collected.
    ...                 Please check UTF logs for more information.\n
    ...                 Traces status: ${status}

    Run Keyword If  '${status}' == 'runningWithWarnings'
    ...  Log  ${msg}  console=True  level=WARN
    Should Be True  '${status}' == 'running' or '${status}' == 'runningWithWarnings'
    ...  msg=Trace status is ${status}. Should be: 'running' or 'runningWithWarnings'.
    Log  Trace status ${status}.  console=True


Stop UTF Traces and Download Logs
    [Documentation]
    ...  Stops and downloads logs collected with UTF.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  Stops and downloads logs collected with UTF. Download directory is ${LOG_PATH}/utf_logs/UE${ue_id}.
    ...  Downloaded logs will be in zip archive similarly to when one collects them manually with UTF.
    ...  This KW also checks trace status after stopping and downloadind in case trace status is different
    ...  than 'ready' a warning will be printed.
    ...  This KW requires ${LOG_PATH} (path to log directory) test variable to be created before running it.
    ...  This KW creates or sets following test variables:
    ...  -${UTF_LOGS_PATH} - Path to created .ZIP file with UTF logs,
    ...  -${UTF_STARTED} - boolean value indicating that UTF logs collection is started. Can be used for conditional
    ...   stopping in teardown.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | trace_id               | Yes  | ID of started traces.                                                 |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | ue_id                  | Yes  | ID of currently used UE.                                              |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Start Collecting Logs With UTF  12345
    ...     Sleep  3s    reason=Wait for TTI to be collected.
    ...     Stop UTF Traces and Download Logs  ${TRACE_ID}  ue_id=1

    [Timeout]  30 min
    [Arguments]  ${trace_id}  ${ue_id}

    Log  Stopping UTF traces...  console=True
    utf_manager.Stop Trace  trace=${trace_id}
    Set Test Variable  ${UTF_STARTED}  False
    Log  Downloading logs...  console=True
    ${utf_logs_path} =  utf_manager.Download Logs  trace=${trace_id}  target_dir=${LOG_PATH}/utf_logs/UE${ue_id}
    Log  Logs downloaded to ${utf_logs_path}.  console=True
    Set Test Variable  ${UTF_LOGS_PATH}  ${utf_logs_path}
    _check trace end status helper  ${trace_id}
    utf_manager.Teardown
    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL'
    ...  Log  Stop UTF failed. Please check logs for details.  console=True  level=WARN


_check trace end status helper
    [Arguments]  ${trace_id}
    ${trace_status} =  Get Trace Info By ID  trace_id=${trace_id}  connection=dcap_collector
    Run Keyword If  '${trace_status['status']}' != 'ready'
    ...  Log  Not all logs may be collected. End status for main TL traces: '${trace_status['status']}'   console=True  level=WARN


Prepare VCU For Feature CB011169
    [Documentation]
    ...  KW prepares modified SCF and performs commissioning on vCU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | original_scf_path      | Yes  | Absolute path to original SCF.                                        |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Prepare VCU For Feature CB011169  /home/ute/Downloads/SCF.xml

    [Arguments]  ${original_scf_path}

    ${vcu_scf} =  Load SCF  ${original_scf_path}
    Modify SCF For VCU  ${original_scf_path}
    Save SCF  ${LOG_PATH}/misc_logs/modified_SCF_vcu.xml
    Set Test Variable  ${VCU_SCF_MODIFIED}  True
    Perform Commissioning On VCU  scf_path=${LOG_PATH}/misc_logs/modified_SCF_vcu.xml


Prepare VDU For Feature CB011169
    [Documentation]
    ...  KW prepares modified SCF and performs commissioning on vDU.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | original_scf_path      | Yes  | Absolute path to original SCF.                                        |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Prepare VDU For Feature CB011169  /home/ute/Downloads/SCF.xml

    [Arguments]  ${original_scf_path}

    ${vdu_scf} =  Load SCF  ${original_scf_path}
    Modify SCF For VDU  ${original_scf_path}
    Save SCF  ${LOG_PATH}/misc_logs/modified_SCF_vdu.xml
    Set Test Variable  ${VDU_SCF_MODIFIED}  True
    Perform Commissioning On VDU    scf_path=${LOG_PATH}/misc_logs/modified_SCF_vdu.xml


Modify SCF For VCU
    [Documentation]
    ...  KW preapres modified SCF for vCU for CB011169 feature test.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW preapres modified SCF for vCU for CB011169 feature test.
    ...  KW requires following global variables to be set before it is run:
    ...  - ${NRBTS_ID} - ID of NRBTS,
    ...  - ${NR_CELL_ID} - ID of NR cell,
    ...  - ${BWP_PROFILE_DN_INITIAL} - dist name of new initial BWP PROFILE,
    ...  - ${BWP_PROFILE_DN_100MHz} - dist name of new BWP profile for 100 MHz,
    ...  - ${BWP_PROFILE_DN_80MHz} - dist name of new BWP profile for 80 MHz,
    ...  - ${BWP_PROFILE_DN_40MHz} - dist name of new BWP profile for 40 MHz.
    ...  Following modifications are made to SCF:
    ...  - IDs for initial BWP profile and BWP profile for 100 MHz are changed in cellBwpList,
    ...  - two new BWP profiles are added to cellBwpList (one for 80 MHz and one for 40 MHz),
    ...  KW does not save SCF. It needs to be done separately.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | original_scf_path      | Yes  | Absolute path to original SCF.                                        |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | dist_name              | No   | Dist name for NR cell. Default value:                                 |
    ...  |                        |      | MRBTS-${VCU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}.         |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Modify SCF For VCU  /home/ute/Downloads/SCF.xml

    [Arguments]  ${original_scf_path}  ${dist_name}=MRBTS-${VCU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}

    ${bwp_profile_dn_initial} =  Replace String  ${BWP_PROFILE_DN_INITIAL}  XXX  ${VCU_MRBTS_ID}
    ${bwp_profile_dn_100mhz} =  Replace String  ${BWP_PROFILE_DN_100MHz}  XXX  ${VCU_MRBTS_ID}
    ${bwp_profile_dn_80mhz} =  Replace String  ${BWP_PROFILE_DN_80MHz}  XXX  ${VCU_MRBTS_ID}
    ${bwp_profile_dn_40mhz} =  Replace String  ${BWP_PROFILE_DN_40MHz}  XXX  ${VCU_MRBTS_ID}

    ${parsed_scf} =  Parse XML  ${original_scf_path}  strip_namespaces=True
    ${cell_bwp_list_dict_initial} =  Get Parameter List As Dictionary From SCF
    ...    ${parsed_scf}  NRCELL  NRCELL-${NR_CELL_ID}  cellBwpList
    ${cell_bwp_list_dict100} =  Get Parameter List As Dictionary From SCF
    ...    ${parsed_scf}  NRCELL  NRCELL-${NR_CELL_ID}  cellBwpList  position=2
    Set To Dictionary  ${cell_bwp_list_dict_initial}  bwpDN=${bwp_profile_dn_initial}
    Set To Dictionary  ${cell_bwp_list_dict100}  bwpDN=${bwp_profile_dn_100mhz}
    ${cell_bwp_list_dict80} =  Create Dictionary  &{cell_bwp_list_dict100}  bwpDN=${bwp_profile_dn_80mhz}  cellBwpId=2
    ${cell_bwp_list_dict40} =  Create Dictionary  &{cell_bwp_list_dict100}  bwpDN=${bwp_profile_dn_40mhz}  cellBwpId=3
    Remove List From SCF  dist_name=${dist_name}  list_name=cellBwpList
    Add List To SCF  dist_name=${dist_name}  list_name=cellBwpList
    Add Item ToList  dist_name=${dist_name}
    ...  list_name=cellBwpList  elements=${cell_bwp_list_dict_initial}
    Add Item ToList  dist_name=${dist_name}
    ...  list_name=cellBwpList  elements=${cell_bwp_list_dict100}
    Add Item ToList  dist_name=${dist_name}
    ...  list_name=cellBwpList  elements=${cell_bwp_list_dict80}
    Add Item ToList  dist_name=${dist_name}
    ...  list_name=cellBwpList  elements=${cell_bwp_list_dict40}


Modify SCF For VDU
    [Documentation]
    ...  KW preapres modified SCF for vDU for CB011169 feature test.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW preapres modified SCF for vDU for CB011169 feature test.
    ...  KW requires following global variables to be set before it is run:
    ...  - ${NRBTS_ID} - ID of NRBTS,
    ...  - ${NR_CELL_ID} - ID of NR cell,
    ...  - ${BWP_PROFILE_DN_INITIAL} - dist name of new initial BWP PROFILE,
    ...  - ${BWP_PROFILE_DN_100MHz} - dist name of new BWP profile for 100 MHz,
    ...  - ${BWP_PROFILE_DN_80MHz} - dist name of new BWP profile for 80 MHz,
    ...  - ${BWP_PROFILE_DN_40MHz} - dist name of new BWP profile for 40 MHz,
    ...  - ${MSG1_FREQ_START} -  new value for msg1FrequencyStart,
    ...  Following modifications are made to SCF:
    ...  - bwpChBwDedicated2=80MHz, bwpChBwDedicated3=40MHz and startCRBOfCoreset0=0 are added to pdcchAutoConfig,
    ...  - IDs for initial BWP profile and BWP profile for 100 MHz are changed in cellBwpList,
    ...  - two new BWP profiles are added to cellBwpList (one for 80 MHz and one for 40 MHz),
    ...  - csirsNumberWithinReportPeriod_Set1, csirsPower and maxCsirsNumber are removed from periodicCsiAcquisition,
    ...  - dlMimoMode value is changed to '4x4 or 4x2 Open Loop Spatial Multiplexing',
    ...  - msg1FrequencyStart value is changed to value given in ${MSG1_FREQ_START}.
    ...  KW does not save SCF. It needs to be done separately.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | original_scf_path      | Yes  | Absolute path to original SCF.                                        |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | dist_name              | No   | Dist name for NR cell. Default value:                                 |
    ...  |                        |      | MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}.         |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Modify SCF For VDU  /home/ute/Downloads/SCF.xml

    [Arguments]  ${original_scf_path}  ${dist_name}=MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}

    ${bwp_profile_dn_initial} =  Replace String  ${BWP_PROFILE_DN_INITIAL}  XXX  ${VDU_MRBTS_ID}
    ${bwp_profile_dn_100mhz} =  Replace String  ${BWP_PROFILE_DN_100MHz}  XXX  ${VDU_MRBTS_ID}
    ${bwp_profile_dn_80mhz} =  Replace String  ${BWP_PROFILE_DN_80MHz}  XXX  ${VDU_MRBTS_ID}
    ${bwp_profile_dn_40mhz} =  Replace String  ${BWP_PROFILE_DN_40MHz}  XXX  ${VDU_MRBTS_ID}

    ${parsed_scf} =  Parse XML  ${original_scf_path}  strip_namespaces=True
    ${pdcch_auto_config_dict} =  Get Parameter List As Dictionary From SCF
    ...    ${parsed_scf}  NRCELL  NRCELL-${NR_CELL_ID}  pdcchAutoConfig
    Set To Dictionary  ${pdcch_auto_config_dict}  bwpChBwDedicated2=80MHz  bwpChBwDedicated3=40MHz  startCRBOfCoreset0=0

    ${cell_bwp_list_dict_initial} =  Get Parameter List As Dictionary From SCF
    ...    ${parsed_scf}  NRCELL  NRCELL-${NR_CELL_ID}  cellBwpList
    ${cell_bwp_list_dict100} =  Get Parameter List As Dictionary From SCF
    ...    ${parsed_scf}  NRCELL  NRCELL-${NR_CELL_ID}  cellBwpList  position=2
    Set To Dictionary  ${cell_bwp_list_dict_initial}  bwpDN=${bwp_profile_dn_initial}
    Set To Dictionary  ${cell_bwp_list_dict100}  bwpDN=${bwp_profile_dn_100mhz}
    ${cell_bwp_list_dict80} =  Create Dictionary  &{cell_bwp_list_dict100}  bwpDN=${bwp_profile_dn_80mhz}  cellBwpId=2
    ${cell_bwp_list_dict40} =  Create Dictionary  &{cell_bwp_list_dict100}  bwpDN=${bwp_profile_dn_40mhz}  cellBwpId=3

    ${periodic_csi_acq_dict} =  Get Parameter List As Dictionary From SCF
    ...    ${parsed_scf}  NRCELL  NRCELL-${NR_CELL_ID}  periodicCsiAcquisition
    Remove From Dictionary  ${periodic_csi_acq_dict}  csirsNumberWithinReportPeriod_Set1  csirsPower  maxCsirsNumber

    Remove List From SCF  dist_name=${dist_name}  list_name=pdcchAutoConfig
    Add List To SCF  dist_name=${dist_name}  list_name=pdcchAutoConfig
    Add Item ToList  dist_name=${dist_name}
    ...  list_name=pdcchAutoConfig  elements=${pdcch_auto_config_dict}
    Remove List From SCF  dist_name=${dist_name}  list_name=cellBwpList
    Add List To SCF  dist_name=${dist_name}  list_name=cellBwpList
    Add Item ToList  dist_name=${dist_name}
    ...  list_name=cellBwpList  elements=${cell_bwp_list_dict_initial}
    Add Item ToList  dist_name=${dist_name}
    ...  list_name=cellBwpList  elements=${cell_bwp_list_dict100}
    Add Item ToList  dist_name=${dist_name}
    ...  list_name=cellBwpList  elements=${cell_bwp_list_dict80}
    Add Item ToList  dist_name=${dist_name}
    ...  list_name=cellBwpList  elements=${cell_bwp_list_dict40}
    Modify SCF Element  value=${MSG1_FREQ_START}  dist_name=${dist_name}  p_name=msg1FrequencyStart
    Modify SCF Element  value=4x4 or 4x2 Open Loop Spatial Multiplexing
    ...  dist_name=${dist_name}  p_name=dlMimoMode
    Remove List From SCF  dist_name=${dist_name}  list_name=periodicCsiAcquisition
    Add List To SCF  dist_name=${dist_name}  list_name=periodicCsiAcquisition
    Add Item ToList  dist_name=${dist_name}
    ...  list_name=periodicCsiAcquisition  elements=${periodic_csi_acq_dict}
