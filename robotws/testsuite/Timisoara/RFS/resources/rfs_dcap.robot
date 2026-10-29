*** Settings ***
Documentation    Resource file for DCAP
Library    taf.sw.dcap.rd  WITH NAME  dcap
Library    taf.rfrl.utilities.utf_lab.ute_utf_lab.UteUtfLab  WITH NAME  ute_utf_lab

*** Keywords ***
DCAP Setup
    [Documentation]
    ...  Provides connection to DCAP tool
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter     | Man. | Default    | Description                                                              |
    ...  | DCAP_ip       | Yes  |            | DCAP IP address                                                          |
    ...  | DCAP_port     | No   | 443        | DCAP port, default value: 443                                            |
    ...  | DCAP_username | No   | None       | DCAP username, default value: None                                       |
    ...  | DCAP_password | No   | None       | DCAP password, default value: None                                       |
    ...  | rd_version    | No   | dcapv3     | RD version, default value: dcapv3                                        |
    ...  | secure        | No   | True       | Secure connection use: True (https) or False (http), default value: True |
    ...  | alias         | No   | None       | DCAP alias for connection, default value: None                           |
    ...
    ...  *RETURN*
    ...  | Parameter         | Description                                                                             |
    ...  | DCAP_setup_status | DCAP setup status: True (successfull DCAP tool setup) or False (failed DCAP tool setup) |
    ...
    [Arguments]  ${DCAP_ip}  ${DCAP_port}=443  ${DCAP_username}=None  ${DCAP_password}=None  ${rd_version}=dcapv3  ${secure}=True  ${alias}=None

    Log  Setup DCAP tool (ip=${DCAP_ip},port=${DCAP_port}) connection started  console=True

    ${DCAP_setup_status}=  Run Keyword and Return Status  Wait Until Keyword Succeeds  5 min  10 sec
    ...  dcap.Connect To  host=${DCAP_ip}  port=${DCAP_port}  username=${DCAP_username}  password=${DCAP_password}
    ...  rd_version=${rd_version}  secure=${secure}  alias=${alias}

    Run Keyword If  ${DCAP_setup_status}
    ...  Log  Setup DCAP tool (ip=${DCAP_ip},port=${DCAP_port}) connection successfully performed!  console=True
    ...  ELSE
    ...  Log  Setup DCAP tool (ip=${DCAP_ip},port=${DCAP_port}) connection failed!  console=True

    [Return]  ${DCAP_setup_status}

DCAP Check BTS
    [Documentation]
    ...  Check if BTS is created in DCAP tool
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter   | Man. | Default | Description                                       |
    ...  | DCAP_BTS_ip | Yes  |         | DCAP BTS IP address                               |
    ...  | connection  | No   | default | DCAP alias for connection, default value: default |
    ...  | timeout     | No   | 30      | Timeout in seconds for request, default value: 30 |
    ...
    ...  *RETURN*
    ...  | Parameter       | Description                                                                                |
    ...  | DCAP_BTS_status | DCAP BTS status: True (BTS declared in DCAP tool) or False (BTS not declared in DCAP tool) |
    ...
    [Arguments]  ${DCAP_BTS_ip}  ${connection}=default  ${timeout}=30

    Log  Check BTS (Host=${DCAP_BTS_ip}) in DCAP tool  console=True
    ${DCAP_ALL_BTS_ip}=  Create List
    ${DCAP_BTS_info_status}  ${DCAP_BTS_info_response}=  Run Keyword And Ignore Error  dcap.Get All Bts Info  connection=${connection}
    ...  timeout=${timeout}

    Run Keyword If  '${DCAP_BTS_info_status}' == 'FAIL'  Run Keywords
    ...  Log  Check BTS (Host=${DCAP_BTS_ip}) in DCAP tool failed!  console=True
    ...  AND  Return From Keyword  None

    FOR  ${item}  IN  @{DCAP_BTS_info_response}
        ${BTS_host}=  Get From Dictionary  ${item}  host
        Append To List  ${DCAP_ALL_BTS_ip}  ${BTS_host}
    END
    ${DCAP_BTS_check}=  Set Variable If  '${DCAP_BTS_ip}' in ${DCAP_ALL_BTS_ip}  ${TRUE}  ${FALSE}
    Run Keyword If  ${DCAP_BTS_check}
    ...  Log  BTS (Host=${DCAP_BTS_ip}) already exists in DCAP tool, no need to create it!  console=True
    ...  ELSE
    ...  Log  Need to create BTS (Host=${DCAP_BTS_ip}) in DCAP tool!  console=True

    [Return]  ${DCAP_BTS_check}

DCAP Create BTS
    [Documentation]
    ...  Create BTS in DCAP tool
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Default    | Description                                       |
    ...  | DCAP_BTS_ip       | Yes  |            | DCAP BTS IP address                               |
    ...  | DCAP_BTS_port     | No   | 443        | DCAP BTS port, default value: 443                 |
    ...  | DCAP_BTS_username | No   | Nemuadmin  | DCAP BTS username, default value: Nemuadmin       |
    ...  | DCAP_BTS_password | No   | nemuuser   | DCAP BTS password, default value: nemuuser        |
    ...  | DCAP_BTS_alias    | No   | target_bts | DCAP BTS alias, default value: target_bts         |
    ...  | connection        | No   | default    | DCAP alias for connection, default value: default |
    ...  | timeout           | No   | 30         | Timeout in seconds for request, default value: 30 |
    ...
    ...  *RETURN*
    ...  | Parameter   | Description |
    ...  | DCAP_BTS_id | DCAP BTS id |
    ...
    [Arguments]  ${DCAP_BTS_ip}  ${DCAP_BTS_port}=443  ${DCAP_BTS_username}=Nemuadmin  ${DCAP_BTS_password}=nemuuser  ${DCAP_BTS_alias}=target_bts
    ...  ${connection}=default  ${timeout}=30

    Log  Create BTS (Host=${DCAP_BTS_ip}) in DCAP tool  console=True
    ${DCAP_create_BTS_status}  ${DCAP_create_BTS_response}=  Run Keyword And Ignore Error  dcap.Create Bts  host=${DCAP_BTS_ip}
    ...  port=${DCAP_BTS_port}  username=${DCAP_BTS_username}  password=${DCAP_BTS_password}  bts_alias=${DCAP_BTS_alias}  connection=${connection}
    ...  timeout=${timeout}

    Run Keyword If  '${DCAP_create_BTS_status}' == 'FAIL'  Run Keywords
    ...  Log  Create BTS (Host=${DCAP_BTS_ip}) in DCAP tool failed!  console=True
    ...  AND  Return From Keyword  None
    ...  ELSE IF  '${DCAP_create_BTS_status}' == 'PASS'
    ...  Log  Create BTS (Host=${DCAP_BTS_ip}) in DCAP tool successfully performed!  console=True
    ${DCAP_BTS_id}=  Set Variable  ${DCAP_create_BTS_response.id}
    ${DCAP_BTS_id}=  Convert To Integer  ${DCAP_BTS_id}

    [Return]  ${DCAP_BTS_id}

DCAP Delete BTS
    [Documentation]
    ...  Delete BTS from DCAP tool
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter   | Man. | Default | Description                                       |
    ...  | DCAP_BTS_ip | Yes  |         | DCAP BTS IP address                               |
    ...  | DCAP_BTS_id | Yes  |         | DCAP BTS id                                       |
    ...  | connection  | No   | default | DCAP alias for connection, default value: default |
    ...  | timeout     | No   | 30      | Timeout in seconds for request, default value: 30 |
    ...
    [Arguments]  ${DCAP_BTS_ip}  ${DCAP_BTS_id}  ${connection}=default  ${timeout}=30
    Log  Delete BTS (Host=${DCAP_BTS_ip}) from DCAP tool  console=True
    ${DCAP_delete_BTS_status}  ${DCAP_delete_BTS_response}=  Run Keyword And Ignore Error  dcap.Delete Bts  bts_id=${DCAP_BTS_id}
    ...  connection=${connection}  timeout=${timeout}

    Run Keyword If  '${DCAP_delete_BTS_status}' == 'FAIL'
    ...  Log  Delete BTS (Host=${DCAP_BTS_ip}) from DCAP tool failed!  console=True
    ...  ELSE IF  '${DCAP_delete_BTS_status}' == 'PASS'
    ...  Log  Delete BTS (Host=${DCAP_BTS_ip}) from DCAP tool successfully performed!  console=True

DCAP Get and Check Profile Settings
    [Documentation]
    ...  Get and check profile settings from DCAP tool
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Default | Description                                       |
    ...  | DCAP_entity       | Yes  |         | DCAP entity: BTS, 5G, 4G, vCU or vDU              |
    ...  | connection        | No   | default | DCAP alias for connection, default value: default |
    ...
    [Arguments]  ${DCAP_entity}  ${connection}=default
    Log  Check DCAP tool profile for: ${DCAP_entity}  console=True
    ${DCAP_profile_entity}  ${DCAP_profile_type}=  Get Entity Profile Settings  DCAP_entity=${DCAP_entity}  alias=${connection}

    Run Keyword If  '${DCAP_profile_entity}' == '${EMPTY}'
    ...  Log  - ${DCAP_entity}: No selection  console=True
    ...  ELSE
    ...  Log  - ${DCAP_entity} (${DCAP_profile_type}): ${DCAP_profile_entity}  console=True

DCAP Get Tracers
    [Documentation]
    ...  Get tracers from DCAP tool
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter          | Man. | Default | Description                                       |
    ...  | DCAP_entity_tracer | Yes  |         | DCAP entity tracer: BTS, 5G, 4G, vCU or vDU       |
    ...  | DCAP_tracers_dir   | Yes  |         | Local storage path for DCAP tracer                |
    ...  | connection         | No   | default | DCAP alias for connection, default value: default |
    ...  | timeout            | No   | 30      | Timeout in seconds for request, default value: 30 |
    ...
    [Arguments]  ${DCAP_entity_tracer}  ${DCAP_tracers_dir}  ${connection}=default  ${timeout}=30
    Log  Get DCAP tool tracers for: ${DCAP_entity_tracer}  console=True
    ${DCAP_tracer}=  Set Variable If  '${DCAP_entity_tracer}' == 'BTS'  BTS  '${DCAP_entity_tracer}' == '4G'  ENB
    ...  '${DCAP_entity_tracer}' == '5G'  GNB  '${DCAP_entity_tracer}' == 'vCU'  VCU  '${DCAP_entity_tracer}' == 'vDU'  VDU

    ${DCAP_tracers_info_status}  ${DCAP_tracers_info_response}=  Run Keyword And Ignore Error  dcap.Get Tracers  connection=${connection}
    ...  timeout=${timeout}

    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${DCAP_tracers_dir}
    Run Keyword If  not ${status}  Create Directory  ${DCAP_tracers_dir}

    Run Keyword If  '${DCAP_tracers_info_status}' == 'FAIL'  Run Keywords
    ...  Log  Get DCAP tool tracers failed!  console=True
    ...  AND  Return From Keyword

    ${DCAP_tracer_list}=  Create List
    ${DCAP_tracer_file_name}=  Set Variable  ${DCAP_tracers_dir}/DCAP_${DCAP_entity_tracer}_tracer.txt
    Create File  ${DCAP_tracer_file_name}
    Append To File  ${DCAP_tracer_file_name}  \n ***** CUSTOMIZE & PARAMETERS: ${DCAP_entity_tracer} ***** \n\n
    FOR  ${item}  IN  @{DCAP_tracers_info_response}
        Run Keyword If  '${item['type']}' == '${DCAP_tracer}'  Run Keywords
        ...  Append To List  ${DCAP_tracer_list}  ${item['name']}
        ...  AND  Append To File  ${DCAP_tracer_file_name}  ${item['name']} \n
    END

DCAP Start Trace
    [Documentation]
    ...  Start trace in DCAP tool
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter               | Man. | Default                    | Description                                                         |
    ...  | DCAP_BTS_ip             | Yes  |                            | DCAP BTS IP address                                                 |
    ...  | DCAP_BTS_port           | No   | 443                        | DCAP BTS port, default value: 443                                   |
    ...  | DCAP_BTS_username       | No   | Nemuadmin                  | DCAP BTS username, default value: Nemuadmin                         |
    ...  | DCAP_BTS_password       | No   | nemuuser                   | DCAP BTS password, default value: nemuuser                          |
    ...  | DCAP_BTS_NR_cells       | No   | ${EMPTY}                   | DCAP BTS NR cells, default value: ${EMPTY} (all NR cells traced)    |
    ...  | DCAP_BTS_LTE_cells      | No   | ${EMPTY}                   | DCAP BTS LTE cells, default value: ${EMPTY} (all LTE cells traced)  |
    ...  | tag                     | No   | start_trace                | Tag of start trace session, default value: start_trace              |
    ...  | duration                | No   | -1                         | Collect trace duration (minutes), default value: -1 (infinite)      |
    ...  | connection              | No   | default                    | DCAP alias for connection, default value: default                   |
    ...  | timeout                 | No   | 400                        | Timeout to wait for running state, default=400s                     |
    ...  | force                   | No   | true                       | Force stop of any previously traces, default value: true            |
    ...  | gnb_trace_profile       | No   | ${gnb_trace_profile}       | Id or name of the gNB (5G) start trace                              |
    ...  | enb_trace_profile       | No   | ${enb_trace_profile}       | Id or name of the LTE (ENB) start trace                             |
    ...  | bts_trace_profile       | No   | ${bts_trace_profile}       | Id or name of the BTS start trace                                   |
    ...  | vcu_trace_profile       | No   | ${vcu_trace_profile}       | Id or name of the vCU start trace                                   |
    ...  | vdu_trace_profile       | No   | ${vdu_trace_profile}       | Id or name of the vDU start trace                                   |
    ...  | custom_filter_file      | No   | ${EMPTY}                   | Custom filter file to start the trace                               |
    ...  | gnb_custom_profile      | No   | ${gnb_custom_profile}      | gNB (5G) custom profile name list of the start trace to be started  |
    ...  | control_plane_interface | No   | ${control_plane_interface} | option associated with gnb_custom_profile for cp_5g                 |
    ...  | bip_mirroring_interface | No   | ${bip_mirroring_interface} | option associated with gnb_custom_profile                           |
    ...  | bip_mirroring_time      | No   | ${bip_mirroring_time}      | option associated with gnb_custom_profile                           |
    ...  | l1_trace                | No   | ${l1_trace}                | option associated with gnb_custom_profile                           |
    ...  | enb_custom_profile      | No   | ${enb_custom_profile}      | LTE (ENB) custom profile name list of the start trace to be started |
    ...  | bts_custom_profile      | No   | ${bts_custom_profile}      | BTS custom profile name list of the start trace to be started       |
    ...  | uplane_interface        | No   | ${uplane_interface}        | option associated with bts_custom_profile for ipCapture             |
    ...  | measurement_point       | No   | ${measurement_point}       | option associated with bts_custom_profile for ipCapture             |
    ...  | collection_timing       | No   | ${collection_timing}       | option associated with bts_custom_profile for immediateSnapshot     |
    ...  | vcu_custom_profile      | No   | ${vcu_custom_profile}      | vCU custom profile name list of the start trace to be started       |
    ...  | vdu_custom_profile      | No   | ${vdu_custom_profile}      | vDU custom profile name list of the start trace to be started       |
    ...  | wait_for_activation     | No   | ${EMPTY}                   | Wait for running state for started traces, default value: ${EMPTY}  |
    ...  | resource_group          | No   | on-demand                  | Possible values: on-demand or inspector, default value: on-demand   |
    ...  | allow_start_failures    | No   | true                       | If set to true trace will continue even on tracer errors, as long as
    ...                                                                  one trace target is running. If set to false whole trace will fail if
    ...                                                                  even single tracer fails, default value: true                       |
    ...
    ...  *RETURN*
    ...  | Parameter               | Description                                                                   |
    ...  | DCAP_start_trace_status | Status of DCAP start trace procedure, possible values: True or False          |
    ...  | DCAP_trace_id           | DCAP trace id, possible values: None if failed start, otherwise id            |
    ...
    [Arguments]  ${DCAP_BTS_ip}  ${DCAP_BTS_port}=443  ${DCAP_BTS_username}=Nemuadmin  ${DCAP_BTS_password}=nemuuser  ${DCAP_BTS_NR_cells}=${EMPTY}
    ...  ${DCAP_BTS_LTE_cells}=${EMPTY}  ${tag}=start_trace  ${duration}=-1  ${connection}=default  ${timeout}=400  ${force}=true
    ...  ${gnb_trace_profile}=${gnb_trace_profile}  ${enb_trace_profile}=${enb_trace_profile}  ${bts_trace_profile}=${bts_trace_profile}
    ...  ${vcu_trace_profile}=${vcu_trace_profile}  ${vdu_trace_profile}=${vdu_trace_profile}  ${custom_filter_file}=${EMPTY}
    ...  ${gnb_custom_profile}=${gnb_custom_profile}  ${control_plane_interface}=${control_plane_interface}
    ...  ${bip_mirroring_interface}=${bip_mirroring_interface}  ${bip_mirroring_time}=${bip_mirroring_time}  ${l1_trace}=${l1_trace}
    ...  ${enb_custom_profile}=${enb_custom_profile}  ${bts_custom_profile}=${bts_custom_profile}  ${uplane_interface}=${uplane_interface}
    ...  ${measurement_point}=${measurement_point}  ${collection_timing}=${collection_timing}  ${vcu_custom_profile}=${vcu_custom_profile}
    ...  ${vdu_custom_profile}=${vdu_custom_profile}  ${wait_for_activation}=${EMPTY}  ${resource_group}=on-demand  ${allow_start_failures}=true

    Log  DCAP tool start traces for BTS (Host=${DCAP_BTS_ip})  console=True

    ${BTS_info_dict}=  Create Dictionary
    Set To Dictionary  ${BTS_info_dict}  host  ${DCAP_BTS_ip}
    Set To Dictionary  ${BTS_info_dict}  port  ${DCAP_BTS_port}
    Set To Dictionary  ${BTS_info_dict}  username  ${DCAP_BTS_username}
    Set To Dictionary  ${BTS_info_dict}  password  ${DCAP_BTS_password}
    ${DCAP_BTS_NR_cells_list}=  Run Keyword If  '${DCAP_BTS_NR_cells}' != '${EMPTY}'  Prepare user list info  ${DCAP_BTS_NR_cells}
    Run Keyword If  '${DCAP_BTS_NR_cells}' != '${EMPTY}'  Set To Dictionary  ${BTS_info_dict}  nrCells  ${DCAP_BTS_NR_cells_list}
    ${DCAP_BTS_LTE_cells_list}=  Run Keyword If  '${DCAP_BTS_LTE_cells}' != '${EMPTY}'  Prepare user list info  ${DCAP_BTS_LTE_cells}
    Run Keyword If  '${DCAP_BTS_LTE_cells}' != '${EMPTY}'  Set To Dictionary  ${BTS_info_dict}  lteCells  ${DCAP_BTS_LTE_cells_list}

    ${BTS_info_list}=  Create List
    Append To List  ${BTS_info_list}  ${BTS_info_dict}

    ${gnb_custom_profile_list}=  Run Keyword If  '${gnb_custom_profile}' != '${EMPTY}'  Prepare user list info  ${gnb_custom_profile}
    ${gnb_custom_profile_list}=  Set Variable If  '${gnb_custom_profile}' != '${EMPTY}'  ${gnb_custom_profile_list}  ${EMPTY}
    ${enb_custom_profile_list}=  Run Keyword If  '${enb_custom_profile}' != '${EMPTY}'  Prepare user list info  ${enb_custom_profile}
    ${enb_custom_profile_list}=  Set Variable If  '${enb_custom_profile}' != '${EMPTY}'  ${enb_custom_profile_list}  ${EMPTY}
    ${bts_custom_profile_list}=  Run Keyword If  '${bts_custom_profile}' != '${EMPTY}'  Prepare user list info  ${bts_custom_profile}
    ${bts_custom_profile_list}=  Set Variable If  '${bts_custom_profile}' != '${EMPTY}'  ${bts_custom_profile_list}  ${EMPTY}

    ${DCAP_start_trace_status}  ${DCAP_start_trace_response}=  Run Keyword And Ignore Error  dcap.Start Trace  bts=${BTS_info_list}  tag=${tag}
    ...  duration=${duration}  connection=${connection}  timeout=${timeout}  force=${force}  gnb_trace_profile=${gnb_trace_profile}
    ...  enb_trace_profile=${enb_trace_profile}  bts_trace_profile=${bts_trace_profile}  vcu_trace_profile=${vcu_trace_profile}
    ...  vdu_trace_profile=${vdu_trace_profile}  custom_filter_file=${custom_filter_file}  gnb_custom_profile=${gnb_custom_profile_list}
    ...  control_plane_interface=${control_plane_interface}  bip_mirroring_interface=${bip_mirroring_interface}
    ...  bip_mirroring_time=${bip_mirroring_time}  l1_trace=${l1_trace}  enb_custom_profile=${enb_custom_profile_list}
    ...  bts_custom_profile=${bts_custom_profile_list}  uplane_interface=${uplane_interface}  measurement_point=${measurement_point}
    ...  collection_timing=${collection_timing}  vcu_custom_profile=${vcu_custom_profile}  vdu_custom_profile=${vdu_custom_profile}
    ...  wait_for_activation=${wait_for_activation}  resource_group=${resource_group}  allow_start_failures=${allow_start_failures}

    Run Keyword If  '${DCAP_start_trace_status}' == 'FAIL'  Run Keywords
    ...  Log  DCAP tool trace starting procedure failed!  console=True
    ...  AND  Return From Keyword  ${FALSE}  None

    ${DCAP_trace_id}=  Get From Dictionary  ${DCAP_start_trace_response}  tracer_id
    ${DCAP_trace_id}=  Convert To Integer  ${DCAP_trace_id}
    ${DCAP_start_trace_status}=  Set Variable  ${TRUE}

    Log  DCAP tool trace starting procedure initiated!  console=True

    [Return]  ${DCAP_start_trace_status}  ${DCAP_trace_id}

DCAP Stop Trace
    [Documentation]
    ...  Stop trace in DCAP tool
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter     | Man. | Default | Description                                       |
    ...  | DCAP_BTS_ip   | Yes  |         | DCAP BTS IP address                               |
    ...  | DCAP_trace_id | Yes  |         | DCAP trace id                                     |
    ...  | connection    | No   | default | DCAP alias for connection, default value: default |
    ...  | timeout       | No   | 30      | Timeout in seconds for request, default value: 30 |
    ...
    ...  *RETURN*
    ...  | Parameter              | Description                                                         |
    ...  | DCAP_stop_trace_status | Status of DCAP stop trace procedure, possible values: True or False |
    ...
    [Arguments]  ${DCAP_BTS_ip}  ${DCAP_trace_id}  ${connection}=default  ${timeout}=30

    Log  DCAP tool stop traces for BTS (Host=${DCAP_BTS_ip})  console=True
    ${DCAP_stop_trace_status}  ${DCAP_stop_trace_response}=  Run Keyword And Ignore Error  dcap.Stop Trace  trace_id=${DCAP_trace_id}
    ...  connection=${connection}  timeout=${timeout}

    Run Keyword If  '${DCAP_stop_trace_status}' == 'FAIL'  Run Keywords
    ...  Log  DCAP tool trace stopping procedure failed!  console=True
    ...  AND  Return From Keyword  ${FALSE}

    Log  DCAP tool trace stopping procedure initiated!  console=True
    ${DCAP_stop_trace_status}=  Set Variable  ${TRUE}

    [Return]  ${DCAP_stop_trace_status}

DCAP Abort Trace
    [Documentation]
    ...  Abort trace in DCAP tool
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter     | Man. | Default | Description                                       |
    ...  | DCAP_BTS_ip   | Yes  |         | DCAP BTS IP address                               |
    ...  | DCAP_trace_id | Yes  |         | DCAP trace id                                     |
    ...  | connection    | No   | default | DCAP alias for connection, default value: default |
    ...  | timeout       | No   | 30      | Timeout in seconds for request, default value: 30 |
    ...
    ...  *RETURN*
    ...  | Parameter               | Description                                                          |
    ...  | DCAP_abort_trace_status | Status of DCAP abort trace procedure, possible values: True or False |
    ...
    [Arguments]  ${DCAP_BTS_ip}  ${DCAP_trace_id}  ${connection}=default  ${timeout}=30

    Log  DCAP tool abort traces for BTS (Host=${DCAP_BTS_ip})  console=True
    ${DCAP_abort_trace_status}  ${DCAP_abort_trace_response}=  Run Keyword And Ignore Error  dcap.Abort Trace  trace_id=${DCAP_trace_id}
    ...  connection=${connection}  timeout=${timeout}

    Run Keyword If  '${DCAP_abort_trace_status}' == 'FAIL'  Run Keywords
    ...  Log  DCAP tool abort trace failed!  console=True
    ...  AND  Return From Keyword  ${FALSE}

    Log  DCAP tool trace abort procedure initiated!  console=True
    ${DCAP_abort_trace_status}=  Set Variable  ${TRUE}

    [Return]  ${DCAP_abort_trace_status}

DCAP Delete Trace
    [Documentation]
    ...  Delete trace in DCAP tool
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter     | Man. | Default | Description                                       |
    ...  | DCAP_BTS_ip   | Yes  |         | DCAP BTS IP address                               |
    ...  | DCAP_trace_id | Yes  |         | DCAP trace id                                     |
    ...  | connection    | No   | default | DCAP alias for connection, default value: default |
    ...  | timeout       | No   | 30      | Timeout in seconds for request, default value: 30 |
    ...
    [Arguments]  ${DCAP_BTS_ip}  ${DCAP_trace_id}  ${connection}=default  ${timeout}=30

    Log  DCAP tool delete traces for BTS (Host=${DCAP_BTS_ip})  console=True
    ${DCAP_delete_trace_status}  ${DCAP_delete_trace_response}=  Run Keyword And Ignore Error  dcap.Delete Trace  trace_id=${DCAP_trace_id}
    ...  connection=${connection}  timeout=${timeout}

    Run Keyword If  '${DCAP_delete_trace_status}' == 'FAIL'
    ...  Log  DCAP tool delete trace failed!  console=True
    ...  ELSE IF  '${DCAP_delete_trace_status}' == 'PASS'
    ...  Log  Trace Status: \n Trace ID: ${DCAP_trace_id} - deleted  console=True

DCAP Get Trace Status By Id
    [Documentation]
    ...  Get trace status in DCAP tool
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter     | Man. | Default | Description                                       |
    ...  | DCAP_trace_id | Yes  |         | DCAP trace id                                     |
    ...  | connection    | No   | default | DCAP alias for connection, default value: default |
    ...  | timeout       | No   | 30      | Timeout in seconds for request, default value: 30 |
    ...
    ...  *RETURN*
    ...  | Parameter         | Description       |
    ...  | DCAP_trace_status | DCAP trace status |
    ...
    [Arguments]  ${DCAP_trace_id}  ${connection}=default  ${timeout}=30
    ${DCAP_trace_info_status}  ${DCAP_trace_info_response}=  Run Keyword And Ignore Error  dcap.Get Trace Info By Id  trace_id=${DCAP_trace_id}
    ...  connection=${connection}  timeout=${timeout}

    Run Keyword If  '${DCAP_trace_info_status}' == 'FAIL'  Run Keywords
    ...  Log  Get DCAP trace status info failed!  console=True
    ...  AND  Return From Keyword  None

    ${DCAP_trace_status}=  Get From Dictionary  ${DCAP_trace_info_response}  status

    [Return]  ${DCAP_trace_status}

DCAP Check Trace Status
    [Documentation]
    ...  Check trace status in DCAP tool
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                  | Man. | Default | Description                                       |
    ...  | DCAP_trace_id              | Yes  |         | DCAP trace id                                     |
    ...  | DCAP_trace_status_expected | Yes  |         | DCAP trace status expected                        |
    ...  | connection                 | No   | default | DCAP alias for connection, default value: default |
    ...  | timeout                    | No   | 30      | Timeout in seconds for request, default value: 30 |
    ...
    [Arguments]  ${DCAP_trace_id}  ${DCAP_trace_status_expected}  ${connection}=default  ${timeout}=30
    ${DCAP_trace_status}=  DCAP Get Trace Status By Id  DCAP_trace_id=${DCAP_trace_id}  connection=${connection}  timeout=${timeout}
    Should Be True  '${DCAP_trace_status}' == '${DCAP_trace_status_expected}'

DCAP Wait For Expected Trace Status
    [Documentation]
    ...  Wait for expected trace status in DCAP tool
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                  | Man. | Default | Description                                             |
    ...  | DCAP_trace_id              | Yes  |         | DCAP trace id                                           |
    ...  | DCAP_trace_status_expected | Yes  |         | DCAP trace status expected                              |
    ...  | connection                 | No   | default | DCAP alias for connection, default value: default       |
    ...  | timeout                    | No   | 30      | Timeout in seconds for request, default value: 30       |
    ...  | time                       | No   | 900     | Duration for DCAP trace status expected                 |
    ...  | poll_interval              | No   | 30      | Poll interval of DCAP status queries, default value: 30 |
    ...
    ...  *RETURN*
    ...  | Parameter                  | Description                                                                  |
    ...  | DCAP_expected_trace_status | Status of DCAP expected trace procedure, possible values: True or False      |
    ...  | DCAP_trace_status          | Status of DCAP trace, possible values: None if failed stop, otherwise status |
    ...
    [Arguments]  ${DCAP_trace_id}  ${DCAP_trace_status_expected}  ${connection}=default  ${timeout}=30  ${time}=900
    ...  ${poll_interval}=30

    Log  Waiting for trace status: ${DCAP_trace_status_expected}  console=True

    ${DCAP_expected_trace_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${time}  ${poll_interval}
    ...  DCAP Check Trace Status  DCAP_trace_id=${DCAP_trace_id}  DCAP_trace_status_expected=${DCAP_trace_status_expected}  connection=${connection}
    ...  timeout=${timeout}
    ${DCAP_trace_status}=  DCAP Get Trace Status By Id  DCAP_trace_id=${DCAP_trace_id}  connection=${connection}  timeout=${timeout}

    Log  Trace Status: \n Trace ID: ${DCAP_trace_id} - ${DCAP_trace_status}  console=True
    Run Keyword If  ${DCAP_expected_trace_status}
    ...  Log  DCAP tool traces status as expected!  console=True
    ...  ELSE
    ...  Log  DCAP tool operation trace could have failed, please check!  console=True

    [Return]  ${DCAP_expected_trace_status}  ${DCAP_trace_status}

DCAP Get Results
    [Documentation]
    ...  Get trace results from DCAP tool
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter             | Man. | Default  | Description                                                                   |
    ...  | DCAP_BTS_ip           | Yes  |          | DCAP BTS IP address                                                           |
    ...  | DCAP_trace_id         | Yes  |          | DCAP trace id                                                                 |
    ...  | DCAP_trace_target_dir | No   | /tmp     | Local storage path for collected files, default value: /tmp                   |
    ...  | timeout               | No   | 100      | Timeout to wait for ready or failed or failedToStop state, default value: 100 |
    ...  | connection            | No   | default  | DCAP alias for connection, default value: default                             |
    ...
    ...  *RETURN*
    ...  | Parameter             | Description       |
    ...  | DCAP_results_response | DCAP results info |
    ...
    [Arguments]  ${DCAP_BTS_ip}  ${DCAP_trace_id}  ${DCAP_trace_target_dir}=/tmp  ${timeout}=100  ${connection}=default
    Log  DCAP tool get results for BTS (Host=${DCAP_BTS_ip})  console=True

    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${DCAP_trace_target_dir}
    Run Keyword If  not ${status}  Create Directory  ${DCAP_trace_target_dir}
    ${DCAP_target_dir}=  Set Variable If  '${DCAP_trace_target_dir}' == '/tmp'  ${EMPTY}  ${DCAP_trace_target_dir}

    ${DCAP_results_status}  ${DCAP_results_response}=  Run Keyword And Ignore Error  dcap.Get Results  result_id=${DCAP_trace_id}
    ...  target_dir=${DCAP_target_dir}  connection=${connection}  timeout=${timeout}

    Run Keyword If  '${DCAP_results_status}' == 'FAIL'  Run Keywords
    ...  Log  Collect DCAP results failed!  console=True
    ...  AND  Return From Keyword  None
    ...  ELSE IF  '${DCAP_results_status}' == 'PASS'
    ...  Log  DCAP results successfully collected and available on ${DCAP_results_response}  console=True

    [Return]  ${DCAP_results_response}

DCAP Get Result File Contents
    [Documentation]
    ...  Get result file contents from DCAP tool
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter             | Man. | Default  | Description                                                                   |
    ...  | DCAP_BTS_ip           | Yes  |          | DCAP BTS IP address                                                           |
    ...  | DCAP_trace_id         | Yes  |          | DCAP trace id                                                                 |
    ...  | timeout               | No   | 100      | Timeout to wait for ready or failed or failedToStop state, default value: 100 |
    ...  | connection            | No   | default  | DCAP alias for connection, default value: default                             |
    ...
    ...  *RETURN*
    ...  | Parameter                       | Description                               |
    ...  | DCAP_trace_result_file_contents | DCAP trace result file contents full path |
    ...
    [Arguments]  ${DCAP_BTS_ip}  ${DCAP_trace_id}  ${timeout}=100  ${connection}=default
    Log  DCAP tool get result file contents for BTS (Host=${DCAP_BTS_ip})  console=True

    ${DCAP_result_file_contents_status}  ${DCAP_result_file_contents_response}=  Run Keyword And Ignore Error  dcap.Get Result File Contents
    ...  result_id=${DCAP_trace_id}  connection=${connection}  timeout=${timeout}

    Run Keyword If  '${DCAP_result_file_contents_status}' == 'FAIL'  Run Keywords
    ...  Log  Collect DCAP result file contents failed!  console=True
    ...  AND  Return From Keyword  None
    ...  ELSE IF  '${DCAP_result_file_contents_status}' == 'PASS'
    ...  Log  DCAP result file contents successfully collected and available on ${DCAP_result_file_contents_response}  console=True

    [Return]  ${DCAP_result_file_contents_response}

Start Trace by DCAP tool

    FOR  ${alias}  IN  @{alias_list}

        Log  ***** Start Trace by DCAP tool for BTS ${alias} *****  console=True

        ${USER_DCAP_TRACE_COLLECT_BTS}=  Get Variable Value  ${USER_DCAP_TRACE_COLLECT_${alias}}  ${FALSE}
        Set Test Variable  ${USER_DCAP_TRACE_COLLECT_${alias}}  ${USER_DCAP_TRACE_COLLECT_BTS}
        Run Keyword If  not ${USER_DCAP_TRACE_COLLECT_${alias}}  Run Keywords
        ...  Log  DCAP tool trace collect skipped by user: USER_DCAP_TRACE_COLLECT_${alias} = False  console=True
        ...  AND  Continue For Loop

        Set Test Variable  ${DCAP_info_check_${alias}}  ${FALSE}
        Set Test Variable  ${DCAP_setup_status_${alias}}  ${FALSE}
        Set Test Variable  ${DCAP_start_trace_status_${alias}}  ${FALSE}

        ${DCAP_info_check}=  Check DCAP tool info  alias=${alias}
        Set Test Variable  ${DCAP_info_check_${alias}}  ${DCAP_info_check}
        Run Keyword If  not ${DCAP_info_check_${alias}}  Run Keywords
        ...  Log  DCAP tool trace collect skipped due to improper config: missing init.py DCAP tool info for BTS ${alias}!   console=True
        ...  AND  Stop DCAP tool on UTE VM
        ...  AND  Continue For Loop

        Run Keyword And Return Status  Get DCAP profiles info  alias=${alias}

        ${DCAP_setup_status}=  Setup DCAP tool connection  alias=${alias}
        Set Test Variable  ${DCAP_setup_status_${alias}}  ${DCAP_setup_status}
        Run Keyword If  not ${DCAP_setup_status_${alias}}  Run Keywords
        ...  Log  DCAP tool trace collect skipped due to failed setup DCAP tool connection!  console=True
        ...  AND  Stop DCAP tool on UTE VM
        ...  AND  Continue For Loop

        Get And Set OAM IP Address  alias=${alias}
        Set Test Variable  ${BTS_Mplane_ip_${alias}}  ${${alias.upper()}}[${alias.upper()}_OAM_IP_ADDRESS]

        Run Keyword And Continue On Failure  Check DCAP tool BTS info
        ...  BTS_ip=${BTS_Mplane_ip_${alias}}  alias=${alias}
        Run Keyword If  not ${DCAP_BTS_check_${alias}}  Run Keyword If  '${DCAP_BTS_id_${alias}}' == 'None'  Run Keywords
        ...  Log  DCAP tool trace collect skipped due to failed BTS create in DCAP tool!  console=True
        ...  AND  Stop DCAP tool on UTE VM
        ...  AND  Continue For Loop

        Run Keyword And Continue On Failure  Check DCAP tool entity profile settings
        ...  alias=${alias}

        Run Keyword And Continue On Failure  Perform Start Trace by DCAP tool
        ...  BTS_ip=${BTS_Mplane_ip_${alias}}  alias=${alias}

    END

    FOR  ${alias}  IN  @{alias_list}

        Run Keyword If  not ${USER_DCAP_TRACE_COLLECT_${alias}}  Continue For Loop

        Run Keyword If  not ${DCAP_info_check_${alias}}  Continue For Loop

        Run Keyword If  not ${DCAP_setup_status_${alias}}  Continue For Loop

        Run Keyword If  not ${DCAP_start_trace_status_${alias}}  Continue For Loop

        Log  ***** Waiting for expected Start Trace status in DCAP tool for BTS ${alias} *****  console=True

        Run Keyword And Continue On Failure  DCAP Wait For Expected Trace Status
        ...  DCAP_trace_id=${DCAP_trace_id_${alias}}  DCAP_trace_status_expected=running  connection=${alias}  time=300  poll_interval=30

    END

Stop Trace by DCAP tool

    FOR  ${alias}  IN  @{alias_list}

        Log  ***** Stop Trace by DCAP tool for BTS ${alias} *****  console=True

        Run Keyword If  not ${USER_DCAP_TRACE_COLLECT_${alias}}  Run Keywords
        ...  Log  DCAP tool trace collect skipped by user: USER_DCAP_TRACE_COLLECT_${alias} = False  console=True
        ...  AND  Continue For Loop

        Run Keyword If  not ${DCAP_info_check_${alias}}  Run Keywords
        ...  Log  DCAP tool trace collect skipped by improper config: missing init.py DCAP tool info for BTS ${alias}!  console=True
        ...  AND  Continue For Loop

        Run Keyword If  not ${DCAP_setup_status_${alias}}  Run Keywords
        ...  Log  DCAP tool trace collect skipped due to failed setup DCAP tool connection!   console=True
        ...  AND  Continue For Loop

        Run Keyword If  not ${DCAP_start_trace_status_${alias}}  Run Keywords
        ...  Log  DCAP tool trace stop skipped due to failed DCAP tool trace start procedure for BTS ${alias}!  console=True
        ...  AND  Continue For Loop

        Set Test Variable  ${DCAP_stop_trace_status_${alias}}  ${FALSE}

        Run Keyword And Continue On Failure  Perform Stop Trace by DCAP tool  BTS_ip=${BTS_Mplane_ip_${alias}}
        ...  DCAP_trace_id=${DCAP_trace_id_${alias}}  alias=${alias}

    END

    FOR  ${alias}  IN  @{alias_list}

        Run Keyword If  not ${USER_DCAP_TRACE_COLLECT_${alias}}  Continue For Loop

        Run Keyword If  not ${DCAP_info_check_${alias}}  Continue For Loop

        Run Keyword If  not ${DCAP_setup_status_${alias}}  Continue For Loop

        Run Keyword If  not ${DCAP_start_trace_status_${alias}}  Continue For Loop

        Log  ***** Waiting for expected Stop Trace status in DCAP tool for BTS ${alias} *****  console=True

        Run Keyword And Continue On Failure  DCAP Wait For Expected Trace Status
        ...  DCAP_trace_id=${DCAP_trace_id_${alias}}  DCAP_trace_status_expected=ready  connection=${alias}  time=600  poll_interval=30

    END

Collect Trace by DCAP tool

    FOR  ${alias}  IN  @{alias_list}

        Log  ***** Collect Trace by DCAP tool for BTS ${alias} *****  console=True

        Run Keyword If  not ${USER_DCAP_TRACE_COLLECT_${alias}}  Run Keywords
        ...  Log  DCAP tool trace collect skipped by user: USER_DCAP_TRACE_COLLECT_${alias} = False  console=True
        ...  AND  Continue For Loop

        Run Keyword If  not ${DCAP_info_check_${alias}}  Run Keywords
        ...  Log  DCAP tool trace collect skipped by improper config: missing init.py DCAP tool info for BTS ${alias}!  console=True
        ...  AND  Continue For Loop

        Run Keyword If  not ${DCAP_setup_status_${alias}}  Run Keywords
        ...  Log  DCAP tool trace collect skipped due to failed setup DCAP tool connection!   console=True
        ...  AND  Continue For Loop

        Run Keyword If  not ${DCAP_start_trace_status_${alias}}  Run Keywords
        ...  Log  DCAP tool trace stop skipped due to failed DCAP tool trace start procedure for BTS ${alias}!  console=True
        ...  AND  Continue For Loop

        Run Keyword If  not ${DCAP_stop_trace_status_${alias}}  Run Keywords
        ...  Log  DCAP tool trace collect skipped due to failed DCAP tool trace stop procedure for BTS ${alias}!  console=True
        ...  AND  Continue For Loop

        Set Test Variable  ${DCAP_collect_trace_status_${alias}}  ${FALSE}

        Run Keyword And Continue On Failure  Perform Collect Trace by DCAP tool  BTS_ip=${BTS_Mplane_ip_${alias}}
        ...  DCAP_trace_id=${DCAP_trace_id_${alias}}  DCAP_trace_target_dir=${Test Results Dir}/DCAPTraces/${alias}  alias=${alias}

    END

Check DCAP tool hanging resources

    FOR  ${alias}  IN  @{alias_list}

        Log  ***** Check DCAP tool hanging resources for BTS ${alias} *****  console=True

        Run Keyword If  not ${USER_DCAP_TRACE_COLLECT_${alias}}  Run Keywords
        ...  Log  No DCAP tool hanging resources for BTS ${alias}  console=True
        ...  AND  Continue For Loop

        Run Keyword If  not ${DCAP_info_check_${alias}}  Run Keywords
        ...  Log  No DCAP tool hanging resources for BTS ${alias}  console=True
        ...  AND  Continue For Loop

        Run Keyword If  not ${DCAP_setup_status_${alias}}  Run Keywords
        ...  Log  No DCAP tool hanging resources for BTS ${alias}  console=True
        ...  AND  Continue For Loop

        Run Keyword If  not ${DCAP_BTS_check_${alias}}  Run Keyword If  '${DCAP_BTS_id_${alias}}' == 'None'  Run Keywords
        ...  Log  No DCAP tool hanging resources for BTS ${alias}  console=True
        ...  AND  Continue For Loop

        Run Keyword If  '${DCAP_trace_id_${alias}}' == 'None' and '${DCAP_BTS_check_${alias}}' == '${FALSE}'  Run Keywords
        ...  DCAP Delete BTS  BTS_ip=${BTS_Mplane_ip_${alias}}  DCAP_BTS_id=${DCAP_BTS_id_${alias}}  connection=${alias}
        ...  AND  Log  No DCAP tool hanging resources for BTS ${alias}  console=True
        ...  AND  Continue For Loop
        ...  ELSE IF  '${DCAP_trace_id_${alias}}' == 'None' and '${DCAP_BTS_check_${alias}}' == '${TRUE}'  Run Keywords
        ...  Log  No DCAP tool hanging resources for BTS ${alias}  console=True
        ...  AND  Continue For Loop

        ${DCAP_trace_status}=  DCAP Get Trace Status By Id  DCAP_trace_id=${DCAP_trace_id_${alias}}  connection=${alias}
        ${condition1}=  Create Long String  '${DCAP_trace_status}' in ['ready','readyWithWarnings','notRunning','failed','failedToStop','aborted']
        ...  and '${DCAP_BTS_check_${alias}}' == '${FALSE}'
        ${condition2}=  Create Long String  '${DCAP_trace_status}' in ['ready','readyWithWarnings','notRunning','failed','failedToStop','aborted']
        ...  and '${DCAP_BTS_check_${alias}}' == '${TRUE}'
        Run Keyword If  ${condition1}  Run Keywords
        ...  DCAP Delete Trace  DCAP_BTS_ip=${BTS_Mplane_ip_${alias}}  DCAP_trace_id=${DCAP_trace_id_${alias}}  connection=${alias}
        ...  AND  DCAP Delete BTS  BTS_ip=${BTS_Mplane_ip_${alias}}  DCAP_BTS_id=${DCAP_BTS_id_${alias}}  connection=${alias}
        ...  AND  Log  No DCAP tool hanging resources for BTS ${alias}  console=True
        ...  AND  Continue For Loop
        ...  ELSE IF  ${condition2}  Run Keywords
        ...  DCAP Delete Trace  DCAP_BTS_ip=${BTS_Mplane_ip_${alias}}  DCAP_trace_id=${DCAP_trace_id_${alias}}  connection=${alias}
        ...  AND  Log  No DCAP tool hanging resources for BTS ${alias}  console=True
        ...  AND  Continue For Loop

        ${DCAP_abort_trace_status}=  DCAP Abort Trace  DCAP_BTS_ip=${BTS_Mplane_ip_${alias}}  DCAP_trace_id=${DCAP_trace_id_${alias}}
        ...  connection=${alias}

        ${DCAP_trace_aborted}=  Run Keyword And Return Status
        ...  DCAP Check Trace Status  DCAP_trace_id=${DCAP_trace_id_${alias}}  DCAP_trace_status_expected=aborted  connection=${alias}
        Run Keyword If  '${DCAP_trace_aborted}' == '${TRUE}' and '${DCAP_BTS_check_${alias}}' == '${FALSE}'  Run Keywords
        ...  DCAP Delete Trace  DCAP_BTS_ip=${BTS_Mplane_ip_${alias}}  DCAP_trace_id=${DCAP_trace_id_${alias}}  connection=${alias}
        ...  AND  DCAP Delete BTS  BTS_ip=${BTS_Mplane_ip_${alias}}  DCAP_BTS_id=${CAP_BTS_id_${alias}}  connection=${alias}
        ...  AND  Log  No DCAP tool hanging resources for BTS ${alias}  console=True
        ...  ELSE IF  '${DCAP_trace_aborted}' == '${TRUE}' and '${DCAP_BTS_check_${alias}}' == '${TRUE}'  Run Keywords
        ...  DCAP Delete Trace  DCAP_BTS_ip=${BTS_Mplane_ip_${alias}}  DCAP_trace_id=${DCAP_trace_id_${alias}}  connection=${alias}
        ...  AND  Log  No DCAP tool hanging resources for BTS ${alias}  console=True
        ...  ELSE IF  '${DCAP_trace_aborted}' == '${FALSE}'
        ...  Log  DCAP tool trace status not aborted for BTS ${alias}. Hanged DCAP tool trace for BTS ${alias}!  console=True

    END

Check DCAP tool info
    [Arguments]  ${alias}
    ${DCAP_IP_ADDRESS_exist}=  Get Variable Value  ${${alias.upper()}}[${alias.upper()}_DCAP_IP_ADDRESS]
    ${DCAP_PORT_exist}=  Get Variable Value  ${${alias.upper()}}[${alias.upper()}_DCAP_PORT]
    ${DCAP_username}=  Get Variable Value  ${${${alias.upper()}}[${alias.upper()}_DCAP_USERNAME]}  None
    Set To Dictionary  ${${alias.upper()}}  ${alias.upper()}_DCAP_USERNAME  ${DCAP_username}
    ${DCAP_password}=  Get Variable Value  ${${${alias.upper()}}[${alias.upper()}_DCAP_PASSWORD]}  None
    Set To Dictionary  ${${alias.upper()}}  ${alias.upper()}_DCAP_PASSWORD  ${DCAP_password}

    ${DCAP_info_check}=  Set Variable If  '${DCAP_IP_ADDRESS_exist}' != 'None' and '${DCAP_PORT_exist}' != 'None'  ${TRUE}  ${FALSE}

    [Return]  ${DCAP_info_check}

Get DCAP profiles info
    [Arguments]  ${alias}

    ${profile_dict}=  Create Dictionary
    ...  gnb_trace_profile=TRACE_PROFILE
    ...  enb_trace_profile=TRACE_PROFILE
    ...  bts_trace_profile=TRACE_PROFILE
    ...  vcu_trace_profile=TRACE_PROFILE
    ...  vdu_trace_profile=TRACE_PROFILE
    ...  gnb_custom_profile=CUSTOM_PROFILE
    ...  control_plane_interface=CUSTOM_PROFILE
    ...  bip_mirroring_interface=CUSTOM_PROFILE
    ...  bip_mirroring_time=CUSTOM_PROFILE
    ...  l1_trace=CUSTOM_PROFILE
    ...  enb_custom_profile=CUSTOM_PROFILE
    ...  bts_custom_profile=CUSTOM_PROFILE
    ...  uplane_interface=CUSTOM_PROFILE
    ...  measurement_point=CUSTOM_PROFILE
    ...  collection_timing=CUSTOM_PROFILE
    ...  vcu_custom_profile=CUSTOM_PROFILE
    ...  vdu_custom_profile=CUSTOM_PROFILE

    ${profile_dict_keys}=  Get Dictionary Keys  ${profile_dict}  False
    FOR  ${profile_name}  IN  @{profile_dict_keys}
        ${profile_check_result}=  Check DCAP profiles info  ${profile_dict['${profile_name}']}  ${profile_name}  ${alias}
        Set Test Variable  ${${profile_name}_${alias}}  ${profile_check_result}
    END

Check DCAP profiles info
    [Arguments]  ${DCAP_profile_type}  ${DCAP_profile_info}  ${alias}
    Return From Keyword If  '${DCAP_PROFILES_INFO['${alias.upper()}']['${DCAP_profile_type}']['${DCAP_profile_info}']}' != 'None'
    ...  ${DCAP_PROFILES_INFO['${alias.upper()}']['${DCAP_profile_type}']['${DCAP_profile_info}']}

    ${DCAP_profile_info_exist}=  Run Keyword And Return Status  Variable Should Exist  ${${DCAP_profile_info}_${alias}}
    Run Keyword If  ${DCAP_profile_info_exist}
    ...  Return From Keyword If  '${${DCAP_profile_info}_${alias}}' != '${EMPTY}'
    ...  ${${DCAP_profile_info}_${alias}}

    [Return]   ${EMPTY}

Setup DCAP tool connection
    [Arguments]  ${alias}

    ${DCAP_setup_status}=  DCAP Setup  DCAP_ip=${${alias.upper()}}[${alias.upper()}_DCAP_IP_ADDRESS]
    ...  DCAP_port=${${alias.upper()}}[${alias.upper()}_DCAP_PORT]  DCAP_username=${${alias.upper()}}[${alias.upper()}_DCAP_USERNAME]
    ...  DCAP_password=${${alias.upper()}}[${alias.upper()}_DCAP_PASSWORD]  alias=${alias}

    [Return]  ${DCAP_setup_status}

Check DCAP tool BTS info
    [Arguments]  ${BTS_ip}  ${alias}

    ${DCAP_BTS_check}=  DCAP Check BTS  DCAP_BTS_ip=${BTS_ip}  connection=${alias}
    Set Test Variable  ${DCAP_BTS_check_${alias}}  ${DCAP_BTS_check}

    ${DCAP_BTS_id}=  Run Keyword If  not ${DCAP_BTS_check_${alias}}  DCAP Create BTS  DCAP_BTS_ip=${BTS_ip}  DCAP_BTS_alias=${alias}
    ...  connection=${alias}
    Set Test Variable  ${DCAP_BTS_id_${alias}}  ${DCAP_BTS_id}

Check DCAP tool entity profile settings
    [Arguments]  ${alias}

    DCAP Get and Check Profile Settings  DCAP_entity=BTS  connection=${alias}
    DCAP Get and Check Profile Settings  DCAP_entity=5G  connection=${alias}
    DCAP Get and Check Profile Settings  DCAP_entity=4G  connection=${alias}
    DCAP Get and Check Profile Settings  DCAP_entity=vCU  connection=${alias}
    DCAP Get and Check Profile Settings  DCAP_entity=vDU  connection=${alias}

Get DCAP tool entity tracer
    [Arguments]  ${DCAP_tracers_dir}  ${alias}

    DCAP Get Tracers  DCAP_entity_tracer=BTS  DCAP_tracers_dir=${DCAP_tracers_dir}  connection=${alias}
    DCAP Get Tracers  DCAP_entity_tracer=5G  DCAP_tracers_dir=${DCAP_tracers_dir}  connection=${alias}
    DCAP Get Tracers  DCAP_entity_tracer=4G  DCAP_tracers_dir=${DCAP_tracers_dir}  connection=${alias}
    DCAP Get Tracers  DCAP_entity_tracer=vCU  DCAP_tracers_dir=${DCAP_tracers_dir}  connection=${alias}
    DCAP Get Tracers  DCAP_entity_tracer=vDU  DCAP_tracers_dir=${DCAP_tracers_dir}  connection=${alias}

Prepare user list info
    [Arguments]  ${user_list}
    ${user_list_strip}=  Strip String  ${user_list}
    ${user_list_strip}=  Evaluate  '${user_list_strip}'.replace(', ',',')
    ${user_list}=  Split String  ${user_list_strip}  ,

    [Return]  ${user_list}

Get Entity Profile Settings
    [Arguments]  ${DCAP_entity}  ${alias}
    ${trace_profile_entity}=  Set Variable If
    ...  '${DCAP_entity}' == 'BTS'  ${bts_trace_profile_${alias}}
    ...  '${DCAP_entity}' == '4G'  ${enb_trace_profile_${alias}}
    ...  '${DCAP_entity}' == '5G'  ${gnb_trace_profile_${alias}}
    ...  '${DCAP_entity}' == 'vCU'  ${vcu_trace_profile_${alias}}
    ...  '${DCAP_entity}' == 'vDU'  ${vdu_trace_profile_${alias}}
    ${custom_profile_entity}=  Set Variable If
    ...  '${DCAP_entity}' == 'BTS'  ${bts_custom_profile_${alias}}
    ...  '${DCAP_entity}' == '4G'  ${enb_custom_profile_${alias}}
    ...  '${DCAP_entity}' == '5G'  ${gnb_custom_profile_${alias}}
    ...  '${DCAP_entity}' == 'vCU'  ${vcu_custom_profile_${alias}}
    ...  '${DCAP_entity}' == 'vDU'  ${vdu_custom_profile_${alias}}
    ${DCAP_profile_entity}=  Set Variable If
    ...  '${trace_profile_entity}' != '${EMPTY}'  ${trace_profile_entity}
    ...  '${custom_profile_entity}' != '${EMPTY}'  ${custom_profile_entity}
    ...  ${EMPTY}
    ${DCAP_profile_type}=  Set Variable If
    ...  '${trace_profile_entity}' != '${EMPTY}'  COLLECTION PROFILE
    ...  '${custom_profile_entity}' != '${EMPTY}'  CUSTOM PROFILE
    ...  ${EMPTY}

    [Return]  ${DCAP_profile_entity}  ${DCAP_profile_type}

Perform Start Trace by DCAP tool
    [Arguments]  ${BTS_ip}  ${alias}

    ${DCAP_BTS_NR_cells}=  Get Variable Value  ${USER_DCAP_BTS_NR_CELLS_${alias}}  ${EMPTY}
    ${DCAP_BTS_LTE_cells}=  Get Variable Value  ${USER_DCAP_BTS_LTE_CELLS_${alias}}  ${EMPTY}

    ${DCAP_start_trace_status}  ${DCAP_trace_id}=  DCAP Start Trace  DCAP_BTS_ip=${BTS_ip}  DCAP_BTS_NR_cells=${DCAP_BTS_NR_cells}
    ...  DCAP_BTS_LTE_cells=${DCAP_BTS_LTE_cells}  connection=${alias}
    ...  gnb_trace_profile=${gnb_trace_profile_${alias}}
    ...  enb_trace_profile=${enb_trace_profile_${alias}}
    ...  bts_trace_profile=${bts_trace_profile_${alias}}
    ...  vcu_trace_profile=${vcu_trace_profile_${alias}}
    ...  vdu_trace_profile=${vdu_trace_profile_${alias}}
    ...  gnb_custom_profile=${gnb_custom_profile_${alias}}
    ...  control_plane_interface=${control_plane_interface_${alias}}
    ...  bip_mirroring_interface=${bip_mirroring_interface_${alias}}
    ...  bip_mirroring_time=${bip_mirroring_time_${alias}}
    ...  l1_trace=${l1_trace_${alias}}
    ...  enb_custom_profile=${enb_custom_profile_${alias}}
    ...  bts_custom_profile=${bts_custom_profile_${alias}}
    ...  uplane_interface=${uplane_interface_${alias}}
    ...  measurement_point=${measurement_point_${alias}}
    ...  collection_timing=${collection_timing_${alias}}
    ...  vcu_custom_profile=${vcu_custom_profile_${alias}}
    ...  vdu_custom_profile=${vdu_custom_profile_${alias}}

    Set Test Variable  ${DCAP_start_trace_status_${alias}}  ${DCAP_start_trace_status}
    Set Test Variable  ${DCAP_trace_id_${alias}}  ${DCAP_trace_id}

Perform Stop Trace by DCAP tool
    [Arguments]  ${BTS_ip}  ${DCAP_trace_id}  ${alias}

    ${DCAP_stop_trace_status}=  DCAP Stop Trace  DCAP_BTS_ip=${BTS_ip}  DCAP_trace_id=${DCAP_trace_id}  connection=${alias}

    Set Test Variable  ${DCAP_stop_trace_status_${alias}}  ${DCAP_stop_trace_status}

Perform Collect Trace by DCAP tool
    [Arguments]  ${BTS_ip}  ${DCAP_trace_id}  ${DCAP_trace_target_dir}  ${alias}

    ${DCAP_results}=  DCAP Get Results  DCAP_BTS_ip=${BTS_ip}  DCAP_trace_id=${DCAP_trace_id}  DCAP_trace_target_dir=${DCAP_trace_target_dir}
    ...  connection=${alias}

    ${DCAP_result_file_contents}=  DCAP Get Result File Contents   DCAP_BTS_ip=${BTS_ip}  DCAP_trace_id=${DCAP_trace_id}  connection=${alias}

Get DCAP tool usage info
    [Documentation]
    ...  Get DCAP tool usage info based on DCAP info from init.py; following info will be considered:
    ...  - internal DCAP tool usage (DCAP IP address same as _test_pc_master IP address in init.py for all requested BTS)
    ...  - external DCAP tool usage (DCAP IP address diffrent than _test_pc_master IP address in init.py for all requested BTS)
    ...  - mixed DCAP tool (other cases for DCAP IP address than described above)
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter            | Description                                       |
    ...  | DCAP_usage_tool_info | DCAP usage tool info: internal, external or mixed |
    ...

    Log  Check DCAP tool usage  console=True

    ${internal_DCAP_usage_tool_count}=  Set Variable  0
    ${external_DCAP_usage_tool_count}=  Set Variable  0

    FOR  ${alias}  IN  @{alias_list}

        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['WCDMA','GSM']  Continue For Loop

        ${USER_DCAP_TRACE_COLLECT_BTS}=  Get Variable Value  ${USER_DCAP_TRACE_COLLECT_${alias}}  ${FALSE}
        Set Test Variable  ${USER_DCAP_TRACE_COLLECT_${alias}}  ${USER_DCAP_TRACE_COLLECT_BTS}
        Run Keyword If  not ${USER_DCAP_TRACE_COLLECT_${alias}}  Continue For Loop

        ${cond}=  Create Long String  '${${alias.upper()}}[${alias.upper()}_DCAP_IP_ADDRESS]' == '${MASTER['MASTER_PC_IP_ADDRESS']}'

        ${internal_DCAP_usage_tool_count}=  Run Keyword If  ${cond}
        ...  Evaluate  ${internal_DCAP_usage_tool_count} + 1
        ...  ELSE
        ...  Evaluate  ${internal_DCAP_usage_tool_count} + 0

        ${external_DCAP_usage_tool_count}=  Run Keyword If  ${cond}
        ...  Evaluate  ${external_DCAP_usage_tool_count} + 0
        ...  ELSE
        ...  Evaluate  ${external_DCAP_usage_tool_count} + 1

    END

    ${DCAP_usage_tool_info}=  Set Variable If
    ...  ${internal_DCAP_usage_tool_count} != 0 and ${external_DCAP_usage_tool_count} == 0  internal
    ...  ${internal_DCAP_usage_tool_count} == 0 and ${external_DCAP_usage_tool_count} != 0  external
    ...  mixed

    [Return]  ${DCAP_usage_tool_info}

Prepare DCAP tool on UTE VM
    [Documentation]
    ...  Prepare DCAP tool on UTE VM
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Man. | Default  | Description           |
    ...  | DCAP_tool_start  | Yes  |          | Start DCAP containers |
    ...  | DCAP_tool_stop   | Yes  |          | Stop DCAP containers  |
    ...  | DCAP_tool_update | Yes  |          | Update DCAP tool      |
    ...
    [Arguments]  ${DCAP_tool_start}  ${DCAP_tool_stop}  ${DCAP_tool_update}

    Log  Prepare DCAP tool on UTE VM  console=True

    Run Keyword If  '${DCAP_usage_tool_info}' == 'external'  Run Keywords
    ...  Log  External DCAP tool usage requested, this step will be skipped!  console=True
    ...  AND  Log  External DCAP IP not supported and might impact your test execution, please use VM internal DCAP which is fully supported!
    ...  level=WARN  AND  Return From Keyword

    ${USER_UPDATE_DCAP}=  Get Variable Value  ${USER_UPDATE_DCAP}  ${FALSE}

    Run Keyword If  ${DCAP_tool_update} and ${USER_UPDATE_DCAP}  Run Keywords
    ...  Log  Update for Internal DCAP tool requested:  console=True
    ...  AND  Update DCAP tool on UTE VM

    Run Keyword If  ${DCAP_tool_start}  Start DCAP tool on UTE VM
    Run Keyword If  ${DCAP_tool_stop}  Stop DCAP tool on UTE VM

Start DCAP tool on UTE VM
    [Documentation]
    ...  Start DCAP tool on UTE VM
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter              | Description                                                                                  |
    ...  | DCAP_start_tool_status | DCAP tool start status: True (successfull DCAP tool start) or False (failed DCAP tool start) |
    ...
    Log  Start DCAP tool on UTE VM  console=True
    ${DCAP_start_tool_status}=  Run Keyword and Return Status  ute_utf_lab.Start Utf Lab
    Set Test Variable  ${DCAP_start_tool_status}
    Run Keyword If  ${DCAP_start_tool_status}
    ...  Log  All DCAP Basic containers started successfully  console=True
    ...  ELSE
    ...  Log  Start DCAP tool on UTE VM failed  console=True

    [Return]  ${DCAP_start_tool_status}

Stop DCAP tool on UTE VM
    [Documentation]
    ...  Stop DCAP tool on UTE VM
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter             | Description                                                                          |
    ...  | DCAP_stop_tool_status | DCAP tool status: True (successfull DCAP tool stop) or False (failed DCAP tool stop) |
    ...
    Log  Stop DCAP tool on UTE VM  console=True
    ${DCAP_stop_tool_status}=  Run Keyword and Return Status  ute_utf_lab.Stop Utf Lab
    Run Keyword If  ${DCAP_stop_tool_status}
    ...  Log  All DCAP Basic containers stopped successfully  console=True
    ...  ELSE
    ...  Log  Stop DCAP tool on UTE VM failed  console=True

    [Return]  ${DCAP_stop_tool_status}

Update DCAP tool on UTE VM
    [Documentation]
    ...  Update DCAP tool on UTE VM to latest release
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter               | Description                                                                          |
    ...  | DCAP_update_tool_status | DCAP update tool status: True (successfull DCAP tool update) or False (failed DCAP tool update) |
    ...
    Log  Update DCAP tool on UTE VM  console=True
    ${DCAP_update_tool_status}=  Run Keyword and Return Status  ute_utf_lab.Update Utf Lab
    Run Keyword If  ${DCAP_update_tool_status}
    ...  Log  Latest released DCAP version installed on UTE VM  console=True
    ...  ELSE
    ...  Log  Latest released DCAP version install failed on UTE VM  console=True

    [Return]  ${DCAP_update_tool_status}

Check request for specific BTS DCAP trace collection
    [Documentation]
    ...  Check request for specific BTS DCAP trace collection
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter              | Description                                                                      |
    ...  | BTS_DCAP_TRACE_COLLECT | BTS DCAP TRACE COLLECT: True (at least one flag ${USER_DCAP_TRACE_COLLECT_${alias}} is True) or False
    ...
    ${BTS_DCAP_TRACE_COLLECT}=  Set Variable  ${FALSE}

    FOR  ${alias}  IN  @{alias_list}

        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['WCDMA','GSM']
        ...  Continue For Loop

        ${USER_DCAP_TRACE_COLLECT_BTS}=  Get Variable Value  ${USER_DCAP_TRACE_COLLECT_${alias}}  ${FALSE}

        ${BTS_DCAP_TRACE_COLLECT}=  Set Variable If  ${USER_DCAP_TRACE_COLLECT_BTS}  ${TRUE}  ${BTS_DCAP_TRACE_COLLECT}

        Exit For Loop If  ${BTS_DCAP_TRACE_COLLECT}

    END

    [Return]  ${BTS_DCAP_TRACE_COLLECT}