*** Settings ***
Documentation  This suite contains KWs used by some TCs and resources.

Library  python_resources/alarms_analysis.py


*** Variables ***
&{SIMPLIFIED_ALARM}  severity=${NONE}  faultId=${NONE}  faultName=${NONE}  notifier=${NONE}  number=${NONE}
${ADMIN_SNAPSHOT_TIMEOUT_MASTER}  1200  # timeout for collect snapshot via Admin from MSM (in sec)
${ADMIN_SNAPSHOT_TIMEOUT_ESM}  1500  # timeout for collect snapshot via Admin from ESM (in sec)


*** Keywords ***
Admin Check Active Alarms TAF
    [Documentation]
    ...  Alarms checking based on Admin. Fails if any expected alarm is missing or any critical alarm occurred.
    ...  If collect_snapshot is set to True, snapshot is collected when active alarms are detected.
    ...  If ${print_alarms} is set to True, KW will print lists of alarms with level:
    ...  - ERROR - missed expected or found unexpected criticals
    ...  - INFO - found expected and ignored
    ...  - WARN - all other
    ...
    ...  | Parameter            | Man.  | Default | Description |
    ...  | alias                | No    | default | alias of coam instance |
    ...  | expected_patterns    | No    | empty   | List of expected alarms regex patterns, one for each expected alarm |
    ...  | ignored_patterns     | No    | empty   | List of ignored alarms regex patterns, will be used multiply  |
    ...  | critical_patterns    | No    | empty   | List of critical alarms regex patterns, will be used multiply  |
    ...  | timeout              | No    | 90      | Timeout in seconds to wait for getting alarms from Admin |
    ...  | print_alarms         | No    | true    | Boolean to decide whether output lists should be printed with proper level |
    ...  | collect_snapshot     | No    | False   | collect snapshot if active alarms exist |
    ...
    ...  Each key from alarm dictionary can be used for comparison, but only the following are printed:
    ...  faultName, faultId, severity, notifier (can be re-defined using &{SIMPLIFIED_ALARM})
    ...
    ...  1.  Example of KW used without any defined list - will always pass and print WARN if any alarm is found:
    ...  Admin Check Active Alarms TAF
    ...
    ...  2. Example of KW used with one expected alarm definition - will fail if this alarm does not occur,
    ...  any other will be printed with WARN level:
    ...  ${EXPECTED_ALARM1}     Create Dictionary  faultId=49  notifier=/MRBTS-1/RAT-1/LTS-1/LNBTS_L-1/LNCEL_L-10660
    ...  ${EXPECTED}            Create List  ${EXPECTED_ALARM1}
    ...  Admin Check Active Alarms TAF  expected_patterns=${EXPECTED}
    ...
    ...  3. Example of KW used with one expected and one critical alarm definition - will fail if expected alarm does not occur,
    ...  or any other alarm with faultID=49 occur, any other will be printed with WARN level:
    ...  ${EXPECTED_ALARM1}     Create Dictionary  faultId=49  notifier=/MRBTS-1/RAT-1/LTS-1/LNBTS_L-1/LNCEL_L-10660
    ...  ${EXPECTED}            Create List  ${EXPECTED_ALARM1}
    ...  ${CRITICAL_ALARM1}     Create Dictionary  faultId=49
    ...  ${CRITICAL}            Create List  ${CRITICAL_ALARM1}
    ...  Admin Check Active Alarms TAF  expected_patterns=${EXPECTED}  critical_patterns=${CRITICAL}
    ...
    [Arguments]
    ...  ${alias}=default
    ...  ${expected_patterns}=@{EMPTY}
    ...  ${ignored_patterns}=@{EMPTY}
    ...  ${critical_patterns}=@{EMPTY}
    ...  ${timeout}=90
    ...  ${print_alarms}=${TRUE}
    ...  ${collect_snapshot}=${FALSE}

    ${globally_ignored_alarms}  Get Variable Value  ${GLOBALLY_IGNORED_ALARMS}  @{EMPTY}
    Append To List  ${ignored_patterns}  @{globally_ignored_alarms}
    ${active_alarms}  coam.Get Active Alarms  timeout=${timeout}  alias=${alias}
    Run Keyword If  not ${active_alarms}
    ...  Log  No active alarms have been found.  console=true
    ${found_expected_alarms}
    ...  ${not_found_expected_alarms_patterns}
    ...  ${found_critical_alarms}
    ...  ${found_ignored_alarms}
    ...  ${found_not_classified_alarms}
    ...  alarms_analysis.Get Filtered Alarms  ${active_alarms}  ${expected_patterns}  ${ignored_patterns}  ${critical_patterns}  ${SIMPLIFIED_ALARM}
    Run Keyword If  ${print_alarms}
    ...  alarms_analysis.Print Alarms  ${found_expected_alarms}
    ...  ${not_found_expected_alarms_patterns}
    ...  ${found_critical_alarms}
    ...  ${found_ignored_alarms}
    ...  ${found_not_classified_alarms}
    ...  simplified_dictionary=${SIMPLIFIED_ALARM}
    Run Keyword If  ${not_found_expected_alarms_patterns} or ${found_critical_alarms}
    ...  Fail  Alarm verification failed
    Run Keyword If  ${collect_snapshot} and (${not_found_expected_alarms_patterns} or ${found_critical_alarms} or ${found_not_classified_alarms})
    ...  Admin Get Snapshot

    [Return]  ${found_not_classified_alarms}


Admin Set Test Restriction If Active Alarms Exist TAF
    [Documentation]  If Active alarms exist set test restriction (pass with restriction).
    ...  If collect_snapshot is set to True, snapshot is collected when active alarms are detected.
    ...
    ...  | Parameter            | Man.  | Default | Description                             |
    ...  | collect_snapshot     | No    | False   | collect snapshot if active alarms exist |
    [Arguments]  ${collect_snapshot}=${False}

    Log  Check if active alarms exist  console=true
    ${list_of_active_alarms}  coam.Get Active Alarms  timeout=60
    ${length}  Get Length  ${list_of_active_alarms}

    Run Keyword If  ${length}>0
    ...  Set Test Restriction  Active alarms exist: ${list_of_active_alarms}
    ...  ELSE
    ...  Log  No active alarms  console=true

    Run Keyword If  ${length}>0 and ${collect_snapshot}
    ...  Admin Get Snapshot


Admin Get Snapshot
    [Documentation]
    ...  Try to collect snapshot via ute_admin.Collect Snapshot. If this operation does not succeed, as a workaround
    ...  snapshot is taken using Collect Snapshot Via SSH from ca_SBTS_general.
    ...
    ...  | Parameter              | Man.  | Default                              | Description                             |
    ...  | snapshot_timeout       | No    | ${admin_snapshot_timeout_master}     | timeout for collect snapshot via Admin   |
    [Arguments]  ${snapshot_timeout}=${ADMIN_SNAPSHOT_TIMEOUT_MASTER}

    Log  Collecting snapshot.  console=true
    ${snapshot_collected}  Run Keyword And Return Status
    ...  _Get Snapshot Via Admin API  ${snapshot_timeout}
    Run Keyword If  ${snapshot_collected}
    ...  Run Keywords
    ...  Log  Snapshot collected!  console=true
    ...  AND
    ...  Return From Keyword

    ${snapshot_collected}  Run Keyword And Return Status
    ...  _Get Snapshot Via SSH
    Run Keyword If  ${snapshot_collected}
    ...  Run Keywords
    ...  Log  Snapshot collected!  console=true
    ...  AND
    ...  Return From Keyword

    Log  Snapshot not collected!  console=true


_Get Snapshot Via Admin API
    [Documentation]  This keyword is used to get snapshot via admin api
    [Arguments]  ${timeout}=600  ${alias}=default

    Log  Trying to collect snapshot via Admin API (alias: ${alias})  console=true
    ${year}  ${month}  ${day}  ${hour}  ${min}  Get Time  format=year,month,day,hour,min
    ${timestamp}  Set Variable  ${year}_${month}_${day}_${hour}_${min}

    ${suffix_dict}  Create Dictionary  ${alias}=snapshot_${alias}.zip  default=snapshot.zip
    ${suffix}  Get From Dictionary  ${suffix_dict}  ${alias}
    ${target_file_name}  Set Variable  ${BTS_FILES}/${timestamp}_${suffix}

    Collect Snapshot  target_file_name=${target_file_name}  timeout=${timeout}  alias=${alias}


_Get Snapshot Via SSH
    [Documentation]  This keyword is used to get snapshot via SSH
    Log  Trying to collect snapshot via SSH  console=true
    Collect Snapshot Via SSH  ${BTS_FILES}


Admin Get Snapshot For ESM
    [Documentation]
    ...  Try to collect snapshot for ESM via ute_admin.Collect Snapshot. If this operation does not succeed, as a workaround
    ...  snapshot is taken using Collect Snapshot Via SSH from ca_SBTS_general.
    ...
    ...  | Parameter              | Man.  | Default                              | Description                              |
    ...  | snapshot_timeout       | No    | ${admin_snapshot_timeout_esm}        | timeout for collect snapshot via Admin   |

    Log  Collecting snapshot.  console=true
    ${snapshot_collected}  Run Keyword And Return Status
    ...  _Get ESM Snapshot Via Admin API
    Run Keyword If  ${snapshot_collected}
    ...  Run Keywords
    ...  Log  ESM snapshot collected!  console=true
    ...  AND
    ...  Return From Keyword

    ${snapshot_collected}  Run Keyword And Return Status
    ...  _Get ESM Snapshot Via SSH
    Run Keyword If  ${snapshot_collected}
    ...  Run Keywords
    ...  Log  Snapshot from ESM Via SSH collected!  console=true
    ...  AND
    ...  Return From Keyword

    Log  ESM snapshot not collected!  console=true


_Get ESM Snapshot Via Admin API
    [Documentation]  This keyword is used to get ESM snapshot via admin API

    Log  Trying to collect snapshot for ESM via Admin API  console=true
    ${snapshot_collected}  Run Keyword And Return Status
    ...  _Helper For ESM Snapshot Via Admin API  bts_host=${OAM_SC_IP}
    Return From Keyword If  ${snapshot_collected}
    ${snapshot_collected}  Run Keyword And Return Status
    ...  _Helper For ESM Snapshot Via Admin API  bts_host=${OAM_BTS_IP}
    Should Be True  ${snapshot_collected}  Failed to collect snapshot for ESM via Admin API


_Helper For ESM Snapshot Via Admin API
    [Documentation]  This keyword is used to helper for ESM snapshot via admin API
    [Arguments]  ${bts_host}

    Admin Get Snapshot Remotely Via Admin API  bts_host=${bts_host}  remote_host=${PC_IP2}  snapshot_timeout=${ADMIN_SNAPSHOT_TIMEOUT_ESM}  alias=ESM


Admin Get Snapshot Remotely Via Admin API
    [Documentation]  This keyword is used to get snapshot remotely via admin API
    [Arguments]  ${bts_host}  ${remote_host}  ${snapshot_timeout}  ${alias}

    Run Keyword And Ignore Error
    ...  Setup Admin  admin_api_log_dir=${BTS_FILES}  bts_host=${bts_host}  remote_host=${remote_host}  alias=${alias}
    _Get Snapshot Via Admin API  timeout=${snapshot_timeout}  alias=${alias}


_Get ESM Snapshot Via SSH
    [Documentation]  This keyword is used to get ESM snapshot via SSH

    Log  Trying to collect snapshot from ESM via SSH  console=true
    Collect Snapshot Via Ssh  ${BTS_FILES}  ${SMOD2['IP']}


Admin Get BTS ID
    [Documentation]  Gets BTS ID

    ${bts_obj}  Get Parameters For All  BTS
    ${bts_id}  Convert To String  ${bts_obj[0].btsId}
    Set Test Variable  ${BTS_ID}

    [Return]  ${BTS_ID}


Admin Get WNBTS ID
    [Documentation]
    ...  This keyword returns WNBTS id.

    ${wnbts_dn}  coam.Get Id For Current  WNBTS
    ${wnbts_parameters}  coam.Get Parameters  ${wnbts_dn}
    ${wnbts_id}  Convert To String  ${wnbts_parameters}[wbtsId]

    [Return]  ${wnbts_id}


Admin Get LNBTS ID
    [Documentation]
    ...  This keyword returns LNBTS id.

    ${lnbts_info}  coam.Get Managed Objects  LNBTS
    Check If Single Core Or Dual Core
    FOR  ${item}  IN  @{lnbts_info}
        Run Keyword If  '${item}[distName]'=='/MRBTS-1/RAT-1/${VAR_BTS_L}/LNBTS-1'
        ...  Exit For Loop
    END
    ${lnbts_id}  Convert To String  ${item}[parameters][btsId]

    [Return]  ${lnbts_id}


Admin Get NRBTS ID
    [Documentation]
    ...  This keyword returns NRBTS id.

    ${nrbts_dn}  coam.Get Id For Current  NRBTS
    ${nrbts_id}  Fetch From Right  ${nrbts_dn}  -

    [Return]  ${nrbts_id}


Admin Get MPLANE IP
    [Documentation]
    ...  Get MPLANE IP
    ...  The parameter is called `btsMplane` in SBTS17A, and `btsMplaneIp4V` in SBTS18A (TAT-12793)

    ${bts_obj}  Get Parameters For All  BTS
    ${bts_obj}  Get From List  ${bts_obj}  0

    ${expected_keys}  Create List  btsMplane  btsMplaneIp4V
    ${bts_mplane_key}  Evaluate  [key for key in ${bts_obj} if key in ${expected_keys}][0]

    ${mplane_ip}  Get From Dictionary  ${bts_obj}  ${bts_mplane_key}
    ${mplane_ip}  Convert To String  ${mplane_ip}

    [Return]  ${mplane_ip}


Admin Get Bts_id And Perform Commissioning
    [Documentation]
    ...  Helper keyword for commissioning via ADMIN. KW gets btsId from ADMIN and passes
    ...  it into original ute-admin.Perform Commissioning KW.
    ...  *INPUT*
    ...  | Parameter                      | Man. | Default | Description
    ...  | commissioning_path             | Yes  | empty   | Path to commissioning .xml file
    ...  | skip_parameter_relation_errors | No   | true    | Boolean value: should parameter relation errors be skipped
    ...  | timeout                        | No   | 600     | Timeout for commissioning procedure (scf load, reset trigger, wait for reconnection)
    [Arguments]  ${commissioning_path}  ${skip_parameter_relation_errors}=${TRUE}  ${timeout}=600

    ${bts_id}  Admin Get BTS ID
    Log  Parameter bts_id: ${bts_id}  console=True
    Log  Commissioning via ADMIN will be performed  console=True
    Perform Commissioning  ${bts_id}  ${commissioning_path}  skip_parameter_relation_errors=${skip_parameter_relation_errors}  timeout=${timeout}


Admin Get Wncel Ids
    [Documentation]  This keyword is used to get wncel ids

    ${wcell_ids}  Create List  @{EMPTY}
    ${cells_dn}  Get Ids For All  WNCEL
    FOR  ${cell_dn}  IN  @{cells_dn}
        ${wcell_id}  Fetch From Right  ${cell_dn}  -
        Append To List  ${wcell_ids}  ${wcell_id}
    END
    Sort List  ${wcell_ids}

    [Return]  ${wcell_ids}


Admin Get Modules For Interfaces TAF
    [Documentation]
    ...  Return list of modules types and serial numbers

    ${smod_param}  coam.Get Parameters For All  SMOD
    ${rmod_param}  coam.Get Parameters For All  RMOD

    @{serial_number_list}  Create List

    FOR  ${mod}  IN  @{smod_param}
        Append To List  ${serial_number_list}  SMOD_${mod.serialNumber}
    END
    FOR  ${mod}  IN  @{rmod_param}
        Append To List  ${serial_number_list}  RMOD_${mod.serialNumber}
    END

    [Return]  ${serial_number_list}


Verify Modules States
    [Documentation]  This keyword is used to verify modules states
    [Arguments]  ${alias}=default  ${scf_check}=${TRUE}

    ${sm_state}  Verify Modules  SMOD  alias=${alias}  scf_check=${scf_check}
    ${rf_state}  Verify Modules  RMOD  alias=${alias}  scf_check=${scf_check}
    ${are_states_as_expected}  Evaluate  ${sm_state} and ${rf_state}

    [Return]  ${are_states_as_expected}


Verify Modules
    [Documentation]
    ...  Verify modules states
    ...  Default expected states are defined in the Variables section in hran_frame_sbts.
    ...  If `scf_check` is set to True, the number of modules will be compared with the number of respective objects in SCF.
    ...  | Parameter       | Mandatory | Description                                                                            |
    ...  | class_name       | Yes       | Class name for which states should be checked [SMOD, RMOD]                              |
    ...  | expected_states | No        | Expected states as string, e.g., "administrativeState=Unlocked, operationalState=Enabled" |
    [Arguments]  ${class_name}  ${expected_states}=${${class_name}_expected_states}  ${alias}=default  ${scf_check}=${TRUE}

    ${check_status}  ${runtime_mods}  ${all_mods}  Get Objects With Expected States  ${expected_states}  ${class_name}  alias=${alias}
    Run Keyword If  '${check_status}'=='FAIL'
    ...  Run Keywords
    ...  Log  At least one ${class_name} module has state other than expected.  console=true
    ...  AND
    ...  Return From Keyword  ${FALSE}
    ${count_status}  Run Keyword If  ${scf_check}
    ...  Check SCF Count  ${class_name}  ${runtime_mods}
    ...  ELSE
    ...  Set Variable  ${TRUE}
    Run Keyword If  ${count_status}
    ...  Log  All states of ${class_name} modules are as expected.  console=true
    ...  ELSE
    ...  Log  At least one ${class_name} module has state other than expected.  console=true

    [Return]  ${count_status}


Verify Cells
    [Documentation]
    ...  Verify cells states
    ...  Expected states in default are setted from variables section in hran_frame_sbts
    ...  If scf_check==True, cells count will be verified with scf
    ...  | Parameter       | Mandatory | Description                                                                            |
    ...  | technology      | Yes       | Cell ID for which states should be checked [SMOD, RMOD]                              |
    ...  | expected_states | No        | Expected states as string ex. "administrativeState=Unlocked, operationalState=Enabled" |
    ...
    ...  Return
    ...  False if at least one cell has state other than expected, or cells count in scf is not equal runtime cells
    ...
    [Arguments]  ${technology}  ${expected_states}=${cells_${technology}_expected_states}  ${alias}=default  ${scf_check}=${TRUE}

    ${technology_sign}  Run Keyword If  '${technology}'=='NR'
    ...  Set Variable  NR
    ...  ELSE
    ...  Set Variable  ${technology[0]}N
    ${check_status}  ${runtime_cells}  ${all_cells}  Get Objects With Expected States  ${expected_states}  ${technology_sign}CEL  alias=${alias}
    Run Keyword If  '${check_status}'=='FAIL'
    ...  Run Keywords
    ...  Log  At least one ${technology} cell has state other than expected.  console=true
    ...  AND
    ...  Return From Keyword  ${FALSE}
    ${count_status}  Run Keyword If  ${scf_check}
    ...  Check SCF Count  ${technology}  ${all_cells}
    ...  ELSE
    ...  Set Variable  ${TRUE}
    Run Keyword If  ${count_status}
    ...  Log  All ${technology} cells are in expected state.  console=true
    ...  ELSE
    ...  Log  All ${technology} cells are in expected state but the number of cells defined in SCF differs from reported by Admin API  console=true

    [Return]  ${count_status}


Get Objects With Expected States
    [Documentation]
    ...  Get objects from ADMIN and ensure their states
    ...  | **Full description**
    ...  | All objects from given class (BTS, SMOD, BBU, RMOD, ALD, LNCEL, GNCEL or WNCEL) are fetched from BTS via
    ...  | ADMIN interface and their runtime states are compared to states passed in ${expected_states} variable.
    ...  | KW returns three variables - ${status} of whole KW (PASS, FAIL), ${matching_objects} - list of objects which
    ...  | matches expected states and ${class_ids} - a list of all dist names for given class fetched via ADMIN
    ...
    ...  **Input parameters**
    ...
    ...  +-----------------+------+--------------------------------------------------------------------------------------------------------+
    ...  | Parameter name  | Man. | Description                                                                                            |
    ...  +=================+======+========================================================================================================+
    ...  | expected states | yes  | Comma separated states with their valies (i.e administrativeState=Unlocked, operationalState=Enabled)  |
    ...  +-----------------+------+--------------------------------------------------------------------------------------------------------+
    ...  | class_name      | yes  | ADMIN object class name (BTS, SMOD, BBU, RMOD, ALD, LNCEL, GNCEL or WNCEL)                             |
    ...  +-----------------+------+--------------------------------------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...   ${check_status}  ${RUNTIME_MODS}  ${ALL_MODS}  Get objects with expected states  operationalState=Enabled, availabilityStatus=Online
    [Arguments]  ${expected_states}  ${class_name}  ${alias}=default

    ${class_ids}  Get Ids For All  ${class_name}  alias=${alias}
    ${matching_objects}  Create List
    ${matching_statuses}  Create List
    FOR  ${item_id}  IN  @{class_ids}
        ${status}  ${item_parameters}  Run Keyword And Ignore Error
        ...  Assert  ${class_name}  ${item_id}  ${expected_states}  timeout=20  alias=${alias}
        Run Keyword If  '${status}'=='PASS'
        ...  Run Keywords
        ...  Append To List  ${matching_objects}  ${item_parameters}
        ...  AND
        ...  Append To List  ${matching_statuses}  PASS
        ${iot_cell}  Run Keyword And Return Status
        ...  Should Match Regexp  ${item_id}  .*BTS_CONF.*SCF.*LNCEL
        Run Keyword If  "${status}"=="FAIL" and ${iot_cell}
        ...  Append To List  ${matching_statuses}  PASS
        ${status}  ${item_parameters}  Run Keyword If  "${status}"=="FAIL" and not ${iot_cell}
        ...  Run Keyword And Ignore Error
        ...  Assert  ${class_name}  ${item_id}  availabilityStatus=NotInstalled  timeout=20
        ...  ELSE
        ...  Create List  PASS  NONE
        Run Keyword If  "${status}"=="FAIL" and not ${iot_cell}
        ...  Append To List  ${matching_statuses}  FAIL
    END
    ${status}  Evaluate  "FAIL" if len(${class_ids})!=0 and "FAIL" in "${matching_statuses}" else "PASS"

    [Return]  ${status}  ${matching_objects}  ${class_ids}


Admin Check Cells Number
    [Documentation]  Check if number cells detected by admin is as expected
    ...  | Parameter              | Mandatory     | Description                           |
    ...  | technology             | Yes           | Cell ID e.g: LNCEL, GNCEL or WNCEL    |
    ...  | expectted_cells_number | Yes           | Expected cells number                 |
    [Arguments]  ${technology}  ${expected_cells_number}

    Run Keyword If  ${expected_cells_number}==-1
    ...  Run Keywords
    ...  Log  ${technology} will be ignored for active software  console=true
    ...  AND
    ...  Return From Keyword  ${True}
    ${id_list}  Get Ids For All  ${technology}
    ${admin_cells_num}  Evaluate  len(${id_list})
    Should Be Equal As Integers  ${expected_cells_number}  ${admin_cells_num}
    ...  Admin see different cells number than expected! Expected: ${expected_cells_number} is not equal admin cells num: ${admin_cells_num}.


Reset Admin And Infomodel Connection If Broken TAF
    [Documentation]  Check if Admin operations are possible. If not, reset admin and infomodel connections.
    ...  If allowed, and reset cause is other than soamif version change, will set TC restriction.
    [Arguments]  ${allowed_to_set_restriction}=${True}

    ${soamif_exception}  Set Variable  Invalid soamIf version
    ${bts_statecheck_status}  ${bts_state}  Run Keyword And Ignore Error
    ...  Get Mrbts State
    Run Keyword If  '${bts_statecheck_status}'=='PASS'
    ...  Return From Keyword  ${True}

    ${soamif_change_check}  Run Keyword And Return Status
    ...  Should Contain  ${bts_state}  ${soamif_exception}
    Run Keyword If  ${soamif_change_check}
    ...  Log  Soamif change detected. Will reset admin and infomodel connection.  console=True
    ${should_set_restriction}  Evaluate  (${allowed_to_set_restriction}==${True}) and (${soamif_change_check}==${False})
    Run Keyword If  ${should_set_restriction}
    ...  Set Test Restriction  Admin reset required, no soamif change detected

    ${admin_reset_status}  Run Keyword And Return Status
    ...  coam.Reset Admin
    Log  Admin reset status: ${admin_reset_status}  console=True
    ${infomodel_reset_status}  Run Keyword And Return Status
    ...  ute_admin_infomodel.Reset Infomodel  filename=${BTS_FILES}/IM/InfoModel_untilReset.ims2
    Log  Infomodel reset status: ${infomodel_reset_status}  console=True
    ${bts_statecheck_status_after_reset}  ${bts_state_after_reset}  Run Keyword And Ignore Error
    ...  Get Mrbts State
    ${resets_status}  Evaluate
    ...  (${admin_reset_status}==${True}) and (${infomodel_reset_status}==${True}) and ('${bts_statecheck_status_after_reset}'=='PASS')

    [Return]  ${resets_status}


Admin Check Mplane Connection
    [Documentation]
    ...  Check mplane connection on admin
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+------------------+------------------------------------------------------------------+
    ...  | Parameter name | Man. | Default          | Description                                                      |
    ...  +================+======+==================+==================================================================+
    ...  | bts_host       | no   | ${MPLANE_IP}     | BTS ip to connect, in default MPLANE_IP from node configuration  |
    ...  +----------------+------+------------------+------------------------------------------------------------------+
    ...  | bts_port       | no   | 443              | BTS port to connect                                              |
    ...  +----------------+------+------------------+------------------------------------------------------------------+
    ...  | use_ssl        | no   | TRUE             | SSL flag                                                         |
    ...  +----------------+------+------------------+------------------------------------------------------------------+
    ...  | timeout        | no   | 1 min            | Timeout for connection to admin                                  |
    ...  +----------------+------+------------------+------------------------------------------------------------------+
    ...  | alias          | no   | mplane           | Connection alias                                                 |
    ...  +----------------+------+------------------+------------------------------------------------------------------+
    [Arguments]  ${bts_host}=${MPLANE_IP}  ${bts_port}=443  ${use_ssl}=TRUE  ${timeout}=1 min  ${alias}=mplane

    Log  Check mplane connection on Admin  console=true
    Log  Trying to connect to admin (max ${timeout})  level=INFO  console=true
    ${admin_started}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${timeout}  15 sec
    ...  Setup Admin  admin_api_log_dir=${BTS_FILES}  bts_host=${bts_host}  bts_port=${bts_port}  use_ssl=${use_ssl}  alias=${alias}
    Return From Keyword If  '${admin_started}'=='False'  ${False}
    Log  Connection to admin with mplane (${bts_host}) successfully established!  level=INFO  console=true

    ${bts_statecheck_status}  ${bts_state}  Run Keyword And Ignore Error
    ...  Get Mrbts State  alias=${alias}
    Return From Keyword If  '${bts_statecheck_status}'=='PASS'  ${True}

    [Teardown]  Teardown Admin  alias=${alias}
    [Return]  ${False}


Admin Get Ids For All Cells TAF
    [Documentation]
    ...  Get IDs for all items of GNCEL, WNCEL, LNCEL and NRCEL class.

    ${gncel_ids}  coam.Get Ids For All  GNCEL
    ${wncel_ids}  coam.Get Ids For All  WNCEL
    ${lncel_ids}  coam.Get Ids For All  LNCEL
    ${nrcel_ids}  coam.Get Ids For All  NRCEL
    ${cells_ids}  Evaluate  ${gncel_ids}+${wncel_ids}+${lncel_ids}+${nrcel_ids}

    [Return]  ${cells_ids}


Admin Check SBTS Cells, Modules And Alarms TAF
    [Documentation]
    ...  Wrapper for methods used for system modules, radio modules, cells and alarms checking.
    ...  | **Full description:**
    ...  | Verification is done via ADMIN interface. Additionally modules SNs and amount of cells and HW is compared
    ...  | with SCF. User can pass alarm patterns which should be treat as critical or ignored. For patterns
    ...  | documentation, please refer to Admin Check Active Alarms TAF KW
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------------+------+------------+----------------------------------------------------------------------------+
    ...  | Parameter name     | Man. | Default    | Description                                                                |
    ...  +====================+======+============+============================================================================+
    ...  | critical_patterns  | No   | @{EMPTY}   | Patterns of critical alarms which, if found, should fail the KW            |
    ...  +--------------------+------+------------+----------------------------------------------------------------------------+
    ...  | ignored_patterns   | No   | @{EMPTY}   | Patterns of ignored alarms which, if found, should not be taken into count |
    ...  +--------------------+------+------------+----------------------------------------------------------------------------+
    ...   ${IGNORED_ALARM}     Create Dictionary  faultId=49  notifier=/MRBTS-1/RAT-1/LTS-1/LNBTS_L-1/LNCEL_L-10660
    ...   ${IGNORED}           Create List  ${IGNORED_ALARM}
    ...   ${CRITICAL_ALARM}    Create Dictionary  faultId=21
    ...   ${CRITICAL}          Create List  ${CRITICAL_ALARM}
    ...   Admin Check SBTS cells, modules and alarms  critical_patterns=${CRITICAL}  ignored_patterns=${IGNORED}
    [Arguments]  ${critical_patterns}=@{EMPTY}  ${ignored_patterns}=@{EMPTY}

    ${system_modules_working}  Verify System Modules States
    ${radio_modules_working}  Verify Radio Modules States
    ${cells_gsm_onair}  Verify GSM Cells States
    ${cells_wcdma_onair}  Verify WCDMA Cells States
    ${cells_lte_onair}  Verify LTE Cells States
    ${cells_nr_onair}  Verify NR Cells States
    ${alarms_status}  ${alarms_msg}  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms TAF  critical_patterns=${critical_patterns}  ignored_patterns=${ignored_patterns}
    ${request}  Catenate  ${system_modules_working} and ${radio_modules_working} and ${cells_gsm_onair}
    ...  and ${cells_wcdma_onair} and ${cells_lte_onair} and ${cells_nr_onair} and '${alarms_status}'=='PASS'

    [Teardown]  Run Keyword If  not (${request})
    ...  Fail  At least one module or cell indicates a faulty state or some critical alarms detected!


Admin Get IDs For All LTE Cells
    [Documentation]  Get ids for all lte cell

    ${lncel}  Get Parameters For All  LNCEL
    ${cell_ids}  Evaluate  [cell['id'] for cell in ${lncel} if 'IoT' not in cell['technology'] ]

    [Return]  ${cell_ids}


Admin Get IDs For Standalone IoT Cells
    [Documentation]  Get ids for all standalone iot cells

    ${lncel}  Get Parameters For All  LNCEL
    ${iot_standalone}  Evaluate  [cell['id'] for cell in ${lncel} if 'IoT' in cell['technology'] ]

    [Return]  ${iot_standalone}


Synchronize SMODs TAF
    [Documentation]
    ...  Synchronize two System Modules if NotCommissioned state
    ...  *INPUT*
    ...  | Parameter             | Man.  | Default                      | Description                               |
    ...  | alias                 | No    | default                      | alias of ute_admin instance               |
    ...
    ...  *RETURN*
    [Arguments]  ${alias}=default

    Log  Synchronize SMODs  level=DEBUG
    ${im_object}  ute_admin_infomodel.Get Infomodel Object  //RUNTIME_VIEW-*//NEIGHBOR_NODE_R-*
    ${sync_status}  Run Keyword And Return Status
    ...  coam.Start Sync  ${im_object['dist_name']}  alias=${alias}
    Run Keyword If  ${sync_status}
    ...  Log  Synchronization succeeded  console=true
    ...  ELSE
    ...  Fail  Synchronization failed


Admin And Infomodel Connections Reset
    [Documentation]
    ...  Helper KW for Admin and Infomodel connections reset based on following triggers:
    ...  - SOAMIF change
    ...  - Admin issues
    ...  - on demand
    ...  *INPUT*
    ...  | Parameter | Man.  | Default | Description                                                         |
    ...  | reset_req | No    | False   | reset request for Admin and Infomodel connections, by default False |
    ...  | alias     | No    | default | alias of admin instance                                             |
    [Arguments]  ${reset_req}=${False}  ${alias}=default

    ${soamif_exception}  Set Variable  Invalid soamIf version
    ${verdict}  ${result}  Run Keyword And Ignore Error
    ...  Get Mrbts State  timeout=60  alias=${alias}
    Run Keyword If  '${verdict}' == 'PASS' and '${reset_req}' == '${False}'
    ...  Run Keywords
    ...  Log  No need for Admin and Infomodel connections reset.  console=True
    ...  AND
    ...  Return From Keyword

    ${filepath}  Set Variable If  '${alias}' == 'default'  ${BTS_FILES}  ${BTS_FILES}/${alias}
    ${soamif_change_check}  Run Keyword And Return Status
    ...  Should Contain  ${result}  ${soamif_exception}
    Run Keyword If  ${reset_req}
    ...  Run Keywords
    ...  Log  Admin and Infomodel connections are being reset on demand  console=True
    ...  AND
    ...  Reset Admin  alias=${alias}
    ...  AND
    ...  Sleep  3s
    ...  AND
    ...  Reset Infomodel  filename=${filepath}/InfoModel_untilReset.ims2  alias=${alias}
    ...  ELSE IF  ${soamif_change_check}
    ...  Run Keywords
    ...  Log  Admin and Infomodel connections are being reset due to Admin soamif change detected: ${result}  console=True
    ...  AND
    ...  Reset Admin  alias=${alias}
    ...  AND
    ...  Sleep  3s
    ...  AND
    ...  Reset Infomodel  filename=${filepath}/InfoModel_untilReset.ims2  alias=${alias}
    ...  ELSE IF  '${verdict}' != 'PASS'
    ...  Run Keywords
    ...  Log  Admin and Infomodel connections are being reset due to Admin error: ${result}  console=True
    ...  AND
    ...  Reset Admin  alias=${alias}
    ...  AND
    ...  Sleep  3s
    ...  AND
    ...  Reset Infomodel  filename=${filepath}/InfoModel_untilReset.ims2  alias=${alias}

    ${status}  Run Keyword And Return Status
    ...  Get Mrbts State  timeout=60  alias=${alias}
    Run Keyword If  ${status}
    ...  Log  Admin and Infomodel connections are up after reset  console=True
    ...  ELSE
    ...  Fail  Admin and Infomodel connections are failed after reset


Admin Print Active Alarms TAF
    [Documentation]  This keyword is used to print active alarms TAF
    [Arguments]  ${alias}=default  ${timeout}=90  ${output_file}=${EMPTY}

    ${active_alarms}  coam.Get Alarms  timeout=${timeout}  alias=${alias}
    ${pretty_active_alarms}  Evaluate  pprint.pformat(${active_alarms}, indent=4)  modules=pprint
    Run Keyword If  '${output_file}'!=''
    ...  Create File  ${output_file}  ${pretty_active_alarms}
    Log  Active alarms: ${pretty_active_alarms}  console=true


Check If Single Core Or Dual Core
    [Documentation]  This keyword is used to check if single core or dual core

    ${bts_l_obj}  coam.Get Managed Objects  BTS_L
    ${bts_cores}  Set Variable  ${FALSE}
    FOR  ${bts_l}  IN  @{bts_l_obj}
        IF  '${bts_l}[parameters][storedRole]'=='Single'
            ${bts_cores}  Set Variable  ${TRUE}
            BREAK
        END
    END
    IF  ${bts_cores}
        Get Single Core Domain Id
    ELSE
        Get Dual Core Domain Id
    END


Get Single Core Domain Id
    [Documentation]  This KW gets single core domain id

    ${bts_l}  coam.Get Managed Objects  BTS_L
    ${id}  Fetch From Right  ${bts_l}[0][distName]  /BTS_L-
    ${var_bts_l}  Set Variable  BTS_L-${id}
    Set Test Variable  ${VAR_BTS_L}


Get Dual Core Domain Id
    [Documentation]  This KW gets dual core domain id

    ${bts_l_obj}  coam.Get Managed Objects  BTS_L
    ${bts_l}  Set Variable  ${None}
    FOR  ${bts_l}  IN  @{bts_l_obj}
        IF  '${bts_l}[parameters][storedRole]'=='Active'
            ${bts_l}  Set Variable  ${bts_l}
            BREAK
        END
    END
    ${id}  Fetch From Right  ${bts_l}[distName]  /BTS_L-
    ${var_bts_l}  Set Variable  BTS_L-${id}
    Set Test Variable  ${VAR_BTS_L}
