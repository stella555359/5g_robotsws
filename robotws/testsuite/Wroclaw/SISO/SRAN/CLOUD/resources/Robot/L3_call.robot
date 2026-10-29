*** Settings ***
Documentation  Call operations keywords.
...  Author: daniel.bartkowik@nokia.com
...  Maintainer: daniel.bartkowik@nokia.com

Library    Collections
Library    String
Library    taf.ue
Library    DateTime
Library    XML    use_lxml=true
Library    taf.collectors.core    WITH NAME    core
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library    taf.vran.vdu.enb.rest.interface.LTEvDU    WITH NAME    ltevdu

Resource   ./vdu_oam_operations.robot
Resource   ./common_resources.robot

*** Variables ***
&{BARR_PARAMS}          cellBarred=barred
&{UNBARR_PARAMS}        cellBarred=notBarred
&{JSON_BARR_PARAMS}     update=${BARR_PARAMS}
&{JSON_UNBARR_PARAMS}   update=${UNBARR_PARAMS}
${LTE_CALL}  ${FALSE}    #temporary Flag for differentiate in resources whether call is on LTE or 5G technology

*** Keywords ***
Cloud L3 Call
    [Arguments]  ${cells_input}  ${cells_yaml_path}  ${scfc_file_path}  ${log_to_console}=True
    [Documentation]  Possible usages: "Cloud L3 Call" can be utilized as separate TC by using it straight forward in TS and defining
    ...  'CELLS_YAML_PATH', 'LOGS_DIR', 'SELECTED_CELLS' variables or as simple KW inside of any TC with provided previously
    ...  mentioned variables. To Use this KW user need to prepare yaml file and init.py with required parameters.
    ...  'remote' variable is utilized only by rfrl TC, not used in other case.
    ...  NOTE. "Cloud L3 Call" uses variable 'SELECTED_CELLS' as a list of "nr_cell_identity" or eutranCellId
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cells_input            | Yes  | list of cells ids for call NR->nr_cell_identity LTE->eutranCellId          |
    ...  |                        |      | If @{EMPTY} set, it means all cells will be called                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cells_yaml_path        | Yes  | path to reference yaml file with cells parameters                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | scfc_file_path         | Yes  | path to actual scf file                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${scf_xml}  Parse xml  ${scfc_file_path}
    Import Variables  ${cells_yaml_path}
    ${initial_cells_dictionary}=  Create Initial Vdu Cells Dictionary
    ${input_id_list}=  Convert Input Cells  cells_input=${cells_input}  all_cells=${initial_cells_dictionary}
    ${cells_id_dict}=  Get All Cells Ids Dict  cells_input=${input_id_list}  all_cells=${initial_cells_dictionary}
##    ${cells_id_dict}=  Get All Cells Ids Dict  cells_input=${cells_input}
    ${index_status}=  Run Keyword And Return Status  Variable Should Exist  ${L3_CALL_INDEX}
    ${L3_CALL_INDEX}=  Run Keyword If  ${index_status}  Evaluate  ${L3_CALL_INDEX}+1
    ...  ELSE  Set Variable  1
    Set Test Variable  ${L3_CALL_INDEX}
    Log  ${dots_prefix_green}Preparing UEs  console=${log_to_console}
    L3_Call.Prepare All Ues  cells_identity_list=${cells_id_dict}
	Log  ${ok_prefix_green}Declared UEs connected  console=${log_to_console}
	Log  ${dots_prefix_green}Rejecting all cells in progress...  console=${log_to_console}
	IF  not ${LTE_CALL}  L3 Call Reject All Cells For Call
	FOR  ${called_cell}  IN  @{cells_id_dict.keys()}
      Log  ${info_prefix}Call started on cell ${called_cell}  console=${log_to_console}
      L3_Call.Set Call Variables  cell_identity=${called_cell}
      Log  ${info_prefix}Cell ${called_cell} waiting to be notBarred  console=${log_to_console}
#	     L3 Call Find Anchor LTE
      IF  not ${LTE_CALL}  Run Keywords
      ...  L3 Call Accept Single Cell
      ...  mo_dn=${cells_id_dict['${called_cell}']['cell']['dist_names']['config']}
#      ...  technology=${cells_id_dict['${called_cell}']['technology']}
      ...  AND
      ...  Log  ${info_prefix}Cell ${called_cell} is not barred  console=${log_to_console}
      Log  ${info_prefix}Waiting for UE attach  console=${log_to_console}
# 	   L3 Call Find Anchor LTE
      ${attach_status}=  Run Keyword And Continue On Failure
      ...  L3_Call.Ue Attach  cell_identity=${called_cell}  log_prefix=${info_prefix}
      Run Keyword If  ${attach_status}
      ...  L3_Call.Data Transfer And Check  called_cell=${called_cell}  log_prefix=${info_prefix}
      Log  ${info_prefix}Data transfer finished  console=${log_to_console}
      Log  ${info_prefix}Waiting for UE detach  console=${log_to_console}
      Run Keyword And Continue On Failure  Detach Ue  ue_alias=ue_${SN}
      Log  ${info_prefix}UE detached  console=${log_to_console}
      Log  ${info_prefix}Waiting for cell ${called_cell} to be barred  console=${log_to_console}
      IF  not ${LTE_CALL}  Run Keywords
      ...  L3 Call Reject Single Cell
      ...  mo_dn=${cells_id_dict['${called_cell}']['cell']['dist_names']['config']}
#      ...  technology=${cells_id_dict['${called_cell}']['technology']}
      ...  AND
      ...  Log  ${info_prefix}Cell ${called_cell} is barred  console=${log_to_console}
#	     L3 Call Reject Anchor LTE If Needed
      Sleep  25
    END
    [Teardown]  Run Keyword If  not ${LTE_CALL}  L3 Call Accept All Cells For Call

Convert Input Cells
    [Arguments]  ${cells_input}  ${all_cells}
    ${input_id_list}=  Create List
    IF  "${cells_input}"=="@{EMPTY}"
      FOR  ${rat}  IN  @{all_cells.keys()}
        FOR  ${cell}  IN  @{all_cells['${rat}']}
          IF  "${rat}"=="nr"
            IF  "${CELLS_POOL['${cell['nr_cell_identity']}']['ignore']}"=="TRUE"  Run Keywords
            ...  Log  ${info_prefix}${cell} is not going to be tested, 'ignore' is set to TRUE in yaml file.  console=${TRUE}
            ...  AND  Continue For Loop
          ELSE IF  "${rat}"=="lte"
            ${lte_vdu_info}=  ltevdu.Get Vdu State Data  connection=lte_l3_call
            ${eutraCellId}=  Evaluate  int(${lte_vdu_info['mrbtsId']}) * 256 + int(${cell['basicCell']['lnCelId']})
            IF  "${CELLS_POOL['${eutraCellId}']['ignore']}"=="TRUE"  Run Keywords
            ...  Log  ${info_prefix}${cell} is not going to be tested, 'ignore' is set to TRUE in yaml file.  console=${TRUE}
            ...  AND  Continue For Loop
          END
          IF  "${rat}"=="nr"
            Append To List  ${input_id_list}  ${cell['nr_cell_identity']}
          ELSE
            ${str_eutraCellId}=  Convert To String  ${eutraCellId}
            Append To List  ${input_id_list}  ${str_eutraCellId}
          END
        END
      END
      IF  "${input_id_list}"=="@{EMPTY}"  Fail  All user selected cells are ignored in Yaml file.
      Return From Keyword  ${input_id_list}
    ELSE
      FOR  ${cell}  IN  @{cells_input}
        IF  "${CELLS_POOL['${cell}']['ignore']}"=="TRUE"
          Log  ${info_prefix}${cell} is not going to be tested, 'ignore' is set to TRUE in yaml file.  WARN  console=True
          Continue For Loop
        END
        Append To List  ${input_id_list}  ${cell}
      END
    END
    IF  "${input_id_list}"=="@{EMPTY}"  Fail  All user selected cells are ignored in Yaml file.
    Return From Keyword  ${input_id_list}

Create Initial Vdu Cells Dictionary
    ${cells_details}=  IF  ${LTE_CALL}
    ...  ltevdu.Get Cells Info  connection=lte_l3_call
    ...  ELSE
    ...  vdu.Get Vdu Cells Status
    ${initial_dict}=  IF  ${LTE_CALL}
    ...  Create Dictionary  nr=@{EMPTY}  lte=${cells_details['lncel']}
    ...  ELSE
    ...  Create Dictionary  nr=${cells_details}  lte=@{EMPTY}
    [Return]  ${initial_dict}

Get All Cells Ids Dict
    [Arguments]  ${cells_input}  ${all_cells}
    [Documentation]  KW creates called cells dictionary where key is cell identity and value is parameters dictionary
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cells_input            | Yes  | list of cells ids for call NR->nr_cell_identity LTE->eutranCellId          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | all_cells              | Yes  | dictionary of all technology cells from VDU. Each Key contains dedicated   |
    ...  |                        |      | dict with specific RAT cells.
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${ids_dict}=  Create Dictionary
    FOR  ${selected_cell}  IN  @{cells_input}
      FOR  ${rat}  IN  @{all_cells.keys()}
        FOR  ${cell}  IN  @{all_cells['${rat}']}
          IF  "${rat}"=="nr"
            ${comp_stat}=  Run Keyword And Return Status  Should Be Equal As Strings  ${selected_cell}  ${cell['nr_cell_identity']}
            IF  not ${comp_stat}  Continue For Loop
          ELSE
            ${lte_vdu_info}=  ltevdu.Get Vdu State Data  connection=lte_l3_call
            ${eutraCellId}=  Evaluate  int(${lte_vdu_info['mrbtsId']}) * 256 + int(${cell['basicCell']['lnCelId']})
            ${comp_stat}=  Run Keyword And Return Status  Should Be Equal As Strings  ${selected_cell}  ${eutraCellId}
            IF  not ${comp_stat}  Continue For Loop
          END
          ${tmp_dict}=  Create Dictionary  cell=${cell}  technology=${rat}
          IF  "${rat}"=="nr"
            Set To Dictionary  ${ids_dict}  ${cell['nr_cell_identity']}=${tmp_dict}
          ELSE
            ${str_eutraCellId}=  Convert To String  ${eutraCellId}
            Set To Dictionary  ${ids_dict}  ${str_eutraCellId}=${tmp_dict}
          END
        END
      END
      ${str_selected_cell}=  Convert To String  ${selected_cell}
      ${is_missing}=  Run Keyword And Return Status  Dictionary Should Not Contain Key  ${ids_dict}  ${str_selected_cell}
      IF  ${is_missing}
        Log  ${info_prefix}Declared cell ${selected_cell} not found on tested configuration
        Fail  Declared cell ${selected_cell} not found on tested configuration
      END
    END
    [Return]  ${ids_dict}

Set Call Variables
    [Arguments]  ${cell_identity}
    [Documentation]
    ...  Keyword sets global variables for call from cells.yaml file.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_identity          | Yes  | Cell identity that is called NR->nr_cell_identity LTE->eutranCellId        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Set Test Variable  ${SN}  ${CELLS_POOL['${cell_identity}']['ue_serial']}
    Set Test Variable  ${TPUT_DURATION}  ${CELLS_POOL['${cell_identity}']['tput_duration']}
    Set Test Variable  ${DL_TPUT_MAX}  ${CELLS_POOL['${cell_identity}']['dl_tput_max']}
    Set Test Variable  ${UL_TPUT_MAX}  ${CELLS_POOL['${cell_identity}']['ul_tput_max']}
    Set Test Variable  ${DL_TPUT_MIN}  ${CELLS_POOL['${cell_identity}']['dl_tput_min']}
    Set Test Variable  ${UL_TPUT_MIN}  ${CELLS_POOL['${cell_identity}']['ul_tput_min']}

Prepare All Ues
    [Arguments]  ${cells_identity_list}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword finds all ues that fulfils given requirements and store the ues under given alias.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cells_identity_list    | Yes  | List of cells ids for call NR->nr_cell_identity LTE->eutranCellId          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${ue_list}=  Create List
    ${ue_statuses}=  Create List
    FOR  ${cell}  IN  @{cells_identity_list}
      Append To List  ${ue_list}   ${CELLS_POOL['${cell}']['ue_serial']}
    END
    ${unique_ues}=  Remove Duplicates  ${ue_list}
    Should Not Be Empty  item=${unique_ues}  msg=Please set UE serial numbers to yaml file !!!
    FOR  ${ue_serial}  IN  @{unique_ues}
      ${status}=  Run Keyword And Return Status  Require Ue  ue_alias=ue_${ue_serial}  capabilities=${ue_serial}
      Append To List  ${ue_statuses}  ${status}
      Log  ${log_prefix}Ue connected: ${ue_serial} -> ${status}  console=${log_to_console}
    END
    Run Keyword If  False in ${ue_statuses}
    ...  Fail  msg=Not all declared Ues connected !!!

Ue Attach
    [Timeout]  10 minutes
    [Arguments]  ${cell_identity}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Keyword performs attach to ue and checks if ue with the given id is attached to the appropriate cell.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_identity          |  No  | Cell identity NR->nr_cell_identity LTE->eutranCellId                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Run Keyword And Ignore Error  Detach Ue  ue_alias=ue_${SN}
    Run Keyword And Ignore Error  Attach Ue  ue_alias=ue_${SN}  validation=False
    L3 Call Modify Network Mode  cell_identity=${cell_identity}
    ${is_attach}=  L3_Call.Verify Ue Attach  cell_identity=${cell_identity}
    Run Keyword If  ${is_attach}  Log  ${info_prefix}UE attached  console=${log_to_console}
    Return From Keyword If  ${is_attach}  ${is_attach}
    Run Keyword And Ignore Error  Detach Ue  ue_alias=ue_${SN}
    Sleep  5    Stabilize UE after Detach
    Run Keyword And Ignore Error  Attach Ue  ue_alias=ue_${SN}  validation=False
    ${is_attach}=  L3_Call.Verify Ue Attach  cell_identity=${cell_identity}
    Run Keyword If  ${is_attach}  Log  ${info_prefix}UE attached  console=${log_to_console}
    Return From Keyword If  ${is_attach}  ${is_attach}
    ${cell_inf}=  Get Ue Info  ue_${SN}  infos_list=ALL
    Log  UE Status:  console=True
    FOR  ${param}  IN  @{cell_inf.keys()}
      Log  ${log_prefix}${param} -> ${cell_inf['${param}']}  console=${log_to_console}
    END
    Fail  msg=Attach failed. Ue ${SN} has wrong cell_id/ip. Try manually.
    [Return]  ${is_attach}

Verify Ue Attach
    [Arguments]  ${cell_identity}
    [Timeout]  3 minutes
    [Documentation]  Keyword is verifying if attached cell is as expected.
    ...  Keyword check IP address. Those two conditions decide of returned status.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_identity          |  No  | Cell identity NR->nr_cell_identity LTE->eutranCellId                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Sleep  30s  Wait for stable attach
    ${cell_inf}=  Get Ue Info  ue_${SN}  infos_list=ALL
    Return From Keyword If  '${cell_inf['cell_id']}'!='${cell_identity}'  ${FALSE}
    FOR  ${key}  IN  @{cell_inf['ips'].keys()}
      ${ip_if}=  Get Regexp Matches  string=${key}  pattern=.*rmnet_data.*
      ${is_key}=  Run Keyword And Return Status  Should Be Empty  item=${ip_if}
      Continue For Loop If  ${is_key}
      ${ip_addr}=  Get Matches  list=${cell_inf['ips']['${ip_if[0]}']}  pattern=regexp=\\d+.\\d+.\\d+.\\d+
      Exit For Loop
    END
    ${is_ip}=  Run Keyword And Return Status  Should Not Be Empty  item=${ip_addr}
    Return From Keyword  ${is_ip}

Data Transfer And Check
    [Arguments]  ${called_cell}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Keyword performs downlink and uplink transfer and verify if running throughput is in desired range.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | called_cell            | Yes  | Cell identity NR->nr_cell_identity LTE->eutranCellId                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Log  ${info_prefix}Waiting for data transfer  console=${log_to_console}
    L3_Call.Perform DL Data Transfer And Check  called_cell=${called_cell}
    ...  log_prefix=${log_prefix}  log_to_console=${log_to_console}
    L3_Call.Perform UL Data Transfer And Check  called_cell=${called_cell}
    ...  log_prefix=${log_prefix}  log_to_console=${log_to_console}

Perform DL Data Transfer And Check
    [Arguments]  ${called_cell}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Keyword performs downlink transfer and verify if running throughput is in desired range.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | called_cell            | Yes  | Cell identity NR->nr_cell_identity LTE->eutranCellId                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Run Keyword And Continue On Failure
    ...  Start Data Transfer  dt_name=DT${L3_CALL_INDEX}_${called_cell}_dl  ue_alias=ue_${SN}  direction=dl  packet=1200
    ...  duration=${TPUT_DURATION}  protocol=udp  throughput=${DL_TPUT_MAX}
    Run Keyword And Continue On Failure
    ...  Await Data Transfer Finish  dt_name=DT${L3_CALL_INDEX}_${called_cell}_dl
    ${dl_status}  ${tput_msg}=  Run Keyword And Ignore Error  Verify Average Throughput
    ...  dt_name=DT${L3_CALL_INDEX}_${called_cell}_dl  tput_min=${DL_TPUT_MIN}  tput_max=${DL_TPUT_MAX}
    Run Keyword If  "${dl_status}"=="PASS"
    ...  Log  ${log_prefix}Downlink throughput is in desired range: ${DL_TPUT_MIN} <-> ${DL_TPUT_MAX}  console=${log_to_console}
    ...  ELSE  Run Keywords
    ...  Log  ${log_prefix}Downlink throughput error: ${tput_msg}  console=${log_to_console}
    ...  AND  Run Keyword And Continue On Failure  Fail  msg=${tput_msg}

Perform UL Data Transfer And Check
    [Arguments]  ${called_cell}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Keyword that performs uplink transfer and verify if running throughput is in desired range.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | called_cell            | Yes  | Cell identity NR->nr_cell_identity LTE->eutranCellId                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Run Keyword And Continue On Failure
    ...  Start Data Transfer  dt_name=DT${L3_CALL_INDEX}_${called_cell}_ul  ue_alias=ue_${SN}  direction=ul  packet=1200
    ...  duration=${TPUT_DURATION}  protocol=udp  throughput=${UL_TPUT_MAX}
    Run Keyword And Continue On Failure
    ...  Await Data Transfer Finish  dt_name=DT${L3_CALL_INDEX}_${called_cell}_ul
    ${ul_status}  ${tput_msg}=  Run Keyword And Ignore Error  Verify Average Throughput
    ...  dt_name=DT${L3_CALL_INDEX}_${called_cell}_ul  tput_min=${UL_TPUT_MIN}  tput_max=${UL_TPUT_MAX}
    Run Keyword If  "${ul_status}"=="PASS"
    ...  Log  ${log_prefix}Uplink throughput is in desired range: ${UL_TPUT_MIN} <-> ${UL_TPUT_MAX}  console=${log_to_console}
    ...  ELSE  Run Keywords
    ...  Log  ${log_prefix}Uplink throughput error: ${tput_msg}  console=${log_to_console}
    ...  AND  Run Keyword And Continue On Failure  Fail  msg=${tput_msg}

L3 Call Reject All Cells For Call
	[Documentation]
    ...  Description:
    ...  Keyword rejects all cells on VDU (sets 'barred' to all cells)
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    L3 Call Reject/Accept All 5G Cells For Call  action=reject
#    L3 Call Reject/Accept All LTE Cells For Call  action=reject

L3 Call Accept All Cells For Call
	[Documentation]
    ...  Description:
    ...  Keyword accepts all cells on VDU (sets 'unbarred' to all cells)
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    L3 Call Reject/Accept All 5G Cells For Call  action=accept
#    L3 Call Reject/Accept All LTE Cells For Call  action=accept

L3 Call Reject/Accept All 5G Cells For Call
    [Arguments]  ${action}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
	[Documentation]
    ...  Description:
    ...  Keyword rejects all 5G cells on VDU (sets 'barred'/'unbarred' to all cells)
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | action                 |  Yes | possible values: accept or reject                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${barring_jsons_list}=  Create List
    ${5g_status}  ${5g_cells_details}=  Run Keyword And Ignore Error  vdu.Get Vdu Cells Status
    ${5g_cells_info}=  Set Variable If  "${5g_status}"=="PASS"  ${5g_cells_details}  @{EMPTY}
    FOR  ${cell}  IN  @{5g_cells_info}
      ${barring_jsons}=  IF  "${action}"=="reject"
      ...  Create Single Dist Name Json String
      ...  mo_dn=${cell['dist_names']['config']}
      ...  updated_params_dict=${JSON_BARR_PARAMS}
      ...  distname_operation=update
      ...  ELSE
      ...  Create Single Dist Name Json String
      ...  mo_dn=${cell['dist_names']['config']}
      ...  updated_params_dict=${JSON_UNBARR_PARAMS}
      ...  distname_operation=update
	  Append To List  ${barring_jsons_list}  ${barring_jsons[1]}
    END
    ${full_barring_json}=  Create Json String  distnames_json_elements=${barring_jsons_list}
    vdu.Perform Delta recommissioning  delta_file=${full_barring_json}
    Log  ${log_prefix}All 5g cells barred successfuly  console=${log_to_console}
    [Teardown]  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"  Run Keywords
    ...  Log  ${log_prefix}Not all 5g cells were rejected  console=${log_to_console}
    ...  AND  Fail  Not all 5g cells rejected

#L3 Call Reject/Accept All LTE Cells For Call
#    [Arguments]  ${action}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
#	[Documentation]
#    ...  Description:
#    ...  Keyword rejects all lte cells on VDU (sets 'barred'/'unbarred' to all cells)
#    ...
#    ...  Arguments:
#    ...  +========================+======+============================================================================+
#    ...  | Argument               | Man. | Description                                                                |
#    ...  +========================+======+============================================================================+
#    ...  | action                 |  Yes | possible values: accept or reject                                          |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | log_prefix             |  No  | Set log prefix to message or not.                                          |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...
#    ...  Author: daniel.bartkowiak@nokia.com
#    ...  Maintainer: daniel.bartkowiak@nokia.com
#
#    ${barring_jsons_list}=  Create List
#    ${lte_status}  ${lte_cells_details}=  Run Keyword And Ignore Error  ltevdu.Get Cells Info  connection=lte_l3_call
#    ${lte_cells_info}=  Set Variable If  ${5g_status}  ${lte_cells_details['lncel']}  @{EMPTY}
#    FOR  ${cell}  IN  @{lte_cells_info}
#      ${barring_jsons}=  IF  "${action}"=="reject"
#      ...  Create Single Dist Name Json String
#      ...  mo_dn=${cell['dist_names']['config']}
#      ...  updated_params_dict=${JSON_BARR_PARAMS}
#      ...  distname_operation=update
#      ...  ELSE
#      ...  Create Single Dist Name Json String
#      ...  mo_dn=${cell['dist_names']['config']}
#      ...  updated_params_dict=${JSON_UNBARR_PARAMS}
#      ...  distname_operation=update
#	  Append To List  ${barring_jsons_list}  ${barring_jsons[1]}
#    END
#    ${full_barring_json}=  Create Json String  distnames_json_elements=${barring_jsons_list}
#    ltevdu.Perform Delta recommissioning  delta_file=${full_barring_json}
#    Log  ${log_prefix}All lte cells barred successfuly  console=${log_to_console}
#    [Teardown]  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"  Run Keywords
#    ...  Log  ${log_prefix}Not all lte cells were rejected  console=${log_to_console}
#    ...  AND  Fail  Not all lte cells rejected

L3 Call Reject Single Cell
    [Arguments]  ${mo_dn}  ${technology}=nr  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword accepts single cell on VDU (sets 'notbarred' to single cell)
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | mo_dn                  |  No  | Managed object distname for recommissioning                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | technology             |  No  | possible values nr/lte                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${barring_jsons}=  Run Keyword If  '${technology}'=='nr'
    ...  Create Single Dist Name Json String
    ...  mo_dn=${mo_dn}
    ...  updated_params_dict=${JSON_BARR_PARAMS}
    ...  distname_operation=update
    ...  ELSE
    ...  Create Single Dist Name Json String
    ...  mo_dn=${mo_dn}/SIB-0
    ...  updated_params_dict=${JSON_BARR_PARAMS}
    ...  distname_operation=update
    IF  '${technology}'=='nr'  vdu.Perform Delta Recommissioning  delta_file=${barring_jsons[0]}
#    ...  ELSE  ltevdu.Perform Delta Recommissioning  delta_file=${unbarring_jsons[0]}
    Log  ${log_prefix}Cell ${mo_dn} barred successfuly  console=${log_to_console}
    [Teardown]  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"  Run Keywords
    ...  Log  ${log_prefix}Cell ${mo_dn} wasn't barred  console=${log_to_console}
    ...  AND  Fail  Not all cells accepted

L3 Call Accept Single Cell
    [Arguments]  ${mo_dn}  ${technology}=nr  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword accepts single cell on VDU (sets 'notbarred' to single cell)
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | mo_dn                  |  No  | Managed object distname for recommissioning                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | technology             |  No  | possible values nr/lte                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${unbarring_jsons}=  Run Keyword If  '${technology}'=='nr'
    ...  Create Single Dist Name Json String
    ...  mo_dn=${mo_dn}
    ...  updated_params_dict=${JSON_UNBARR_PARAMS}
    ...  distname_operation=update
    ...  ELSE  Create Single Dist Name Json String
    ...  mo_dn=${mo_dn}/SIB-0
    ...  updated_params_dict=${JSON_UNBARR_PARAMS}
    ...  distname_operation=update
    IF  '${technology}'=='nr'  vdu.Perform Delta Recommissioning  delta_file=${unbarring_jsons[0]}
#    ...  ELSE  ltevdu.Perform Delta Recommissioning  delta_file=${unbarring_jsons[0]}
    Log  ${log_prefix}cell ${mo_dn} unbarred successfuly  console=${log_to_console}
    [Teardown]  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"  Run Keywords
    ...  Log  ${log_prefix}${mo_dn} wasn't unbarred  console=${log_to_console}
    ...  AND  Fail  Not all cells accepted

L3 Call Modify Network Mode
    [Arguments]  ${cell_identity}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword changes network mode for specific cell technology
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_identity          | Yes  | Cell identity Cell identity NR->nr_cell_identity LTE->eutranCellId         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             | No   | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         | No   | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+

    IF  '${CELLS_POOL['${cell_identity}']['technology']}'=='NR'
      L3 Call Modify Network Mode 5G  nr_cell_identity=${cell_identity}
    ELSE
      taf.ue.Change Network Mode  ue_${SN}  ${CELLS_POOL['${cell_identity}']['technology']} only  network_mode_switch_method=secretcode
    END
    [Teardown]  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"  Run Keywords
    ...  Log  ${log_prefix}Ue failed to switch network mode for ${CELLS_POOL['${cell_identity}']['technology']}  console=${log_to_console}
    ...  AND  Fail  Ue failed to switch network mode for ${CELLS_POOL['${cell_identity}']['technology']}

L3 Call Modify Network Mode 5G
    [Arguments]  ${nr_cell_identity}
    [Documentation]
    ...  Description:
    ...  Keyword changes network mode for 5G technology
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | nr_cell_identity       | Yes  | Cell identity NR->nr_cell_identity                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+

    IF  '${CELLS_POOL['${nr_cell_identity}']['type']}'=='SA'
      Run Keyword And Continue On Failure  taf.ue.Change Network Mode  ue_${SN}  NR only  network_mode_switch_method=secretcode
    ELSE IF  '${CELLS_POOL['${nr_cell_identity}']['type']}'=='NSA'
      Run Keyword And Continue On Failure  taf.ue.Change Network Mode  ue_${SN}  NR/LTE  network_mode_switch_method=secretcode
    END

#L3 Call Find Anchor LTE
#    [Arguments]  ${nr_cell_identity}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
#    [Documentation]
#    ...  Description:
#    ...  Keyword accepts all cells on VDU (sets 'notbarred' to all cells)
#    ...
#    ...  Arguments:
#    ...  +========================+======+============================================================================+
#    ...  | Argument               | Man. | Description                                                                |
#    ...  +========================+======+============================================================================+
#    ...  | nr_cell_identity       | Yes  | Cell identity NR->nr_cell_identity                                         |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | log_prefix             | No   | Set log prefix to message or not.                                          |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | log_to_console         | No   | Show or not the information on the console.                                |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...
#    ...  Author: daniel.bartkowiak@nokia.com
#    ...  Maintainer: daniel.bartkowiak@nokia.com
#
#    Return From Keyword If  '${CELLS_POOL['${cell_identity}']['technology']}'!='NR' and '${CELLS_POOL['${nr_cell_identity}']['type']}'!='NSA'
#    ${anchor_config_dn}  ${anchor_bts}=  L3 Call Get Anchor LNCEL for NRCEL  ${nr_cell_identity}
#    Set Test Variable  ${ANCHOR_CONFIG_DN}  ${anchor_config_dn}
#    [Teardown]  Run Keywords  Set Test Variable  ${ANCHOR_STAT}  ${KEYWORD STATUS}
#    ...  AND  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"  Log  ${log_prefix}LTE Anchor not found on tested BTSes  console=${log_to_console}

#L3 Call Get Anchor LNCEL for NRCEL
#    [Arguments]  ${nr_cell_identity}  ${scf}
#    [Documentation]
#    ...  Description:
#    ...  Keyword gets LTE anchor for NR cells as distname
#    ...
#    ...  Arguments:
#    ...  +========================+======+============================================================================+
#    ...  | Argument               | Man. | Description                                                                |
#    ...  +========================+======+============================================================================+
#    ...  | nr_cell_identity       | Yes  | Cell identity NR->nr_cell_identity                                         |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | scf                    | Yes  | vdu scf                                                                    |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...
#    ...  Author: daniel.bartkowiak@nokia.com
#    ...  Maintainer: daniel.bartkowiak@nokia.com
#
#    ${scf_xml}  Parse xml  ${scf}
#    ${anchor_cell_dist}=  Evaluate Xpath  ${scf_xml}
#    ...  string(.//managedObject[(@class='NOKLTE:LNRELGNBCELL') and p[@name="nrCellId"]='${nr_cell_identity}']/@distName)
#    ${anchor_found}=  Run Keyword And Return Status  Should Not Be Empty  ${anchor_cell_dist}
#    Exit For Loop If  ${anchor_found}
#    Run Keyword If  not ${anchor_found}  Fail  Anchor LTE cell not found for NR cell ${nr_cell_identity}! Check Configuration.
#    ${anchor_config_dn}  ${anchor_lnrel}=  Split String From Right  ${anchor_cell_dist}  /  1
#    [Return]  ${anchor_config_dn}

#L3 Call Accept Anchor LTE If Needed
#    [Arguments]  ${nr_cell_identity}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
#    [Documentation]
#    ...  Description:
#    ...  Keyword accepts anchor LTE for call
#    ...
#    ...  Arguments:
#    ...  +========================+======+============================================================================+
#    ...  | Argument               | Man. | Description                                                                |
#    ...  +========================+======+============================================================================+
#    ...  | nr_cell_identity       | Yes  | Cell identity NR->nr_cell_identity                                         |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | log_prefix             | No   | Set log prefix to message or not.                                          |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | log_to_console         | No   | Show or not the information on the console.                                |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...
#    ...  Author: daniel.bartkowiak@nokia.com
#    ...  Maintainer: daniel.bartkowiak@nokia.com
#
#    Return From Keyword If  '${CELLS_POOL['${nr_cell_identity}']['type']}'!='NSA'
#    ${anchor_unbarr_dict}=  Create Dictionary  cellBarred=notBarred
#    ${anchor_unbarr_jsons}=  Create Single Dist Name Json String
#    ...  mo_dn=${ANCHOR_CONFIG_DN}
#    ...  updated_params_dict=${anchor_unbarr_dict}
#    ...  distname_operation=update
#    vdu.Perform Delta Recommissioning  delta_file=${${anchor_unbarr_jsons}[0]}
#    Log  ${log_prefix}Anchor cell ${mo_dn} unbarred successfuly  console=${log_to_console}
#
#L3 Call Reject Anchor LTE If Needed
#    [Arguments]  ${nr_cell_identity}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
#    [Documentation]
#    ...  Description:
#    ...  Keyword accepts anchor LTE for call
#    ...
#    ...  Arguments:
#    ...  +========================+======+============================================================================+
#    ...  | Argument               | Man. | Description                                                                |
#    ...  +========================+======+============================================================================+
#    ...  | nr_cell_identity       | Yes  | Cell identity NR->nr_cell_identity                                         |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | log_prefix             | No   | Set log prefix to message or not.                                          |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | log_to_console         | No   | Show or not the information on the console.                                |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...
#    ...  Author: daniel.bartkowiak@nokia.com
#    ...  Maintainer: daniel.bartkowiak@nokia.com
#
#    Return From Keyword If  '${CELLS_POOL['${nr_cell_identity}']['type']}'!='NSA'
#    ${anchor_barr_dict}=  Create Dictionary  cellBarred=barred
#    ${anchor_barr_jsons}=  Create Single Dist Name Json String
#    ...  mo_dn=${ANCHOR_CONFIG_DN}
#    ...  updated_params_dict=${anchor_barr_dict}
#    ...  distname_operation=update
#    vdu.Perform Delta Recommissioning  delta_file=${${anchor_barr_jsons}[0]}
#    Log  ${log_prefix}Anchor cell ${mo_dn} barred successfuly  console=${log_to_console}

#L3 Verify Input Cells By Technology
#    [Arguments]  ${rat}  ${cells_ids}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
#    [Documentation]
#    ...  Description:
#    ...  Keyword checks if provided cells belong to desired RAT.
#    ...
#    ...  Arguments:
#    ...  +========================+======+============================================================================+
#    ...  | Argument               | Man. | Description                                                                |
#    ...  +========================+======+============================================================================+
#    ...  | rat                    | Yes  | rat technology: lte/nr                                       |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | cells_ids              | Yes  | Cell identity NR->nr_cell_identity LTE->eutranCellId                                        |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | log_prefix             | No   | Set log prefix to message or not.                                          |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | log_to_console         | No   | Show or not the information on the console.                                |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...
#    ...  Author: daniel.bartkowiak@nokia.com
#    ...  Maintainer: daniel.bartkowiak@nokia.com
#    ${cells_status}=  IF  "${rat}"=="nr"  vdu.Get Vdu Cells Status  ELSE  ltevdu.Get Cells Info  connection=lte_l3_call
#    ${parameter_name}=  Set Variable If  "${rat}"=="nr"  nrCellIdentity  eutraCellId
#    FOR  ${user_cell}  IN  @{cells_ids}
#      FOR  ${bts_cell}  IN  @{cells_status}
#        IF  "${user_cell}"=="${bts_cell['${parameter_name}']}"  Exit For Loop
#      END
#      IF  "${bts_cell}"!="${user_cell}"
#        Log  ${log_prefix}Cell ${user_cell} doesn't belong to ${rat} technology  console=${log_to_console}
#        Fail  Cell ${user_cell} doesn't belong to ${rat} technology
#      END
#    END
