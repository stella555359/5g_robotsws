*** Settings ***
Documentation     [PURPOSE] SWM General keywords
...               CA-SWM/infomodel API
Library  Collections
Library  SSHLibrary
Library  String
Library  lib/AlarmAnalysis.py
Library   lib/tool_ping.py


*** Variables ***
${dist_radio}=              //EQM_L-1//RMOD_L-*
${dist_smod}=               //EQM_L-1//SMOD_L-*
${dist_LTE_cell}=           /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/LNBTS_M-*/CELL_M-*
${dist_WCDMA_cell}=         /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/WNBTS_M-*/CELL_M-*
${dist_GSM_cell}=           /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/GNBTS_M-*/CELL_M-*
${dist_cells}=              /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1//CELL_M-*       #old //LNBTS-1/LCELL-*
${dist_bts}=                /MRBTS-1/RAT-1/BTS_L-*/LNBTS-1
${dist_LTE_bts}=            /MRBTS-1/RAT-1//LNBTS-1
${dist_SW_version}=         /MRBTS-1/RAT-1//BTS_CONF-1                          #old //BTS_L-*/BTS_CONF-*
${dist_commissioning}=      /MRBTS-1/RAT-1//BTS_CONF-1/CONFIGURATION_FILE-1     #old //BTS_CONF-*/CONFIGURATION_FILE-*


*** Keywords ***
Infomodel Get Cell State
  [Documentation]
  ...  It returns value or dictionary of given states from given cell.
  ...
  ...  You can find using example in `Infomodel Get Object State`
  ...
  ...  *RETURN VALUE*:
  ...  - Value or Dictionary of all given states
  ...  *Author*: Jaroslaw Piszczala
  [Arguments]  ${distName}  @{states}
  ${output}=  Infomodel Get Object State  ${distName}  @{states}
  [Return]  ${output}

Infomodel Get Module State
  [Documentation]
  ...  It returns value or dictionary of given states from given module.
  ...
  ...  You can find using example in `Infomodel Get Object State`
  ...
  ...  *RETURN VALUE*:
  ...  - Value or Dictionary of all given states
  ...  *Author*: Jaroslaw Piszczala
  [Arguments]  ${distName}  @{states}
  ${output}=  Infomodel Get Object State  ${distName}  @{states}
  [Return]  ${output}

Infomodel Get Object State
  [Documentation]
  ...  It returns value or dictionary of given states from given object.
  ...
  ...  *EXAMPLE*:
  ...  | ${example1}= | Infomodel Get Object State | /MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/LCELL-11 | operationalState |
  ...  | ${example2}= | Infomodel Get Object State | /MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/LCELL-11 | availabilityStatus
  ...  | operationalState | proceduralState |
  ...  =>
  ...
  ...  ${example1}= 'Enabled'
  ...
  ...  ${example2}= {u'availabilityStatus': 'Online', u'operationalState': 'Enabled', u'proceduralState': 'onAirDone'}
  ...
  ...  *RETURN VALUE*:
  ...  - Value or Dictionary of all given states
  ...  *Author*: Jaroslaw Piszczala
  [Arguments]  ${distName}  @{states}
  ${statesSize}=  Get Length  ${states}
  ${stateInfo}=  Infomodel Get StateInfo  ${distName}
  run keyword if  ${statesSize}==1  RETURN from keyword  ${stateInfo.${states[0]}}
  ${statesDict}=  create dictionary
  FOR  ${state}  IN  @{states}
    ${value}=  Get variable value  ${stateInfo.${state}}
    Set to dictionary  ${statesDict}  ${state}  ${value}
  END
  [Return]  ${statesDict}

Infomodel Get Object Connection Status
  [Documentation]
  ...  It returns value of connectionList.connectionStatus from given object.
  ...
  ...  | **Author:** sebastian.burniak@nokia.com
  ...  | **Released with version:** hran_56
  ...  | **Full description:**
  ...  | It returns value of connectionList.connectionStatus from given object.
  ...  **Input Parameters:**
  ...
  ...  +------------------+------+----------------------------------+
  ...  | Parameter name   | Man. | Description                      |
  ...  +==================+======+==================================+
  ...  | distName         | no   | Full dist Name to given object   |
  ...  +------------------+------+----------------------------------+
  ...  **Return Parameters:**
  ...
  ...  +----------------------+------------------------------------+
  ...  | Parameter name       | Description                        |
  ...  +======================+====================================+
  ...  | ${connectionStatus}  | ConnectionStatus parameter value   |
  ...  +----------------------+------------------------------------+
  ...  It returns value of connectionList.connectionStatus from given object.
  ...
  ...  *EXAMPLE*:
  ...  | ${example1}= | Infomodel Get Object State | /MRBTS-1/EQM-1/SMOD-4113/IM_SYNC-1 |
  ...  =>
  ...
  ...  ${example1}= 'Connected'

  [Arguments]  ${distName}
  ${connectionList}=  Infomodel Get ConnectionList  ${distName}
  Run keyword if  ${connectionList}==[]  Return from keyword  Disconnected
  [Return]  ${connectionList[0]['connectionStatus']}

Infomodel Get Cells State
  [Documentation]
  ...  It returns dictionary of values or dictionaries for given cells.
  ...  You can find using example in `Infomodel Get Objects State`
  ...  *RETURN VALUE*:
  ...  - Dictionary of Values or Dictionaries of all given states for all given cells
  ...  *Author*: Jaroslaw Piszczala
  [Arguments]  ${distName}  @{states}
  ${output}=  Infomodel Get Objects State  ${distName}  @{states}
  [Return]  ${output}

Infomodel Get Modules State
  [Documentation]
  ...  It returns dictionary of values or dictionaries for given modules.
  ...
  ...  You can find using example in `Infomodel Get Objects State`
  ...
  ...  *RETURN VALUE*:
  ...  - Dictionary of Values or Dictionaries of all given states for all given cells
  ...  *Author*: Jaroslaw Piszczala
  [Arguments]  ${distName}  @{states}
  ${output}=  Infomodel Get Objects State  ${distName}  @{states}
  [Return]  ${output}

Infomodel Get Objects State
  [Documentation]
  ...  It returns dictionary of values or dictionaries for given objects.
  ...  *EXAMPLE*:
  ...  | ${dists}= | Create List | /MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/LCELL-11 | /MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/LCELL-12 |
  ...  /MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/LCELL-13 |
  ...  | ${example1}= | Infomodel Get Objects State | ${dists} | operationalState |
  ...  | ${example2}= | Infomodel Get Objects State | ${dists} | availabilityStatus | operationalState | proceduralStat
  ...  =>
  ...  ${example1}= {u'/MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/LCELL-11': 'Disabled', u'/MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/LCELL-12:
  ...  'Disabled', u'/MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/LCELL-13': 'Disabled'}
  ...  ${example2}= {u'/MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/LCELL-11': {u'operationalState':'Disabled', u'availabilityStatus'
  ...  : 'Online', u'proceduralState': 'validated'},
  ...               u'/MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/LCELL-12': {u'operationalState': 'Disabled', u'availabilityStatus'
  ...  : 'Online', u'proceduralState': 'validated'},
  ...               u'/MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/LCELL-13': {u'operationalState': 'Disabled', u'availabilityStatus'
  ...  : 'Online', u'proceduralState': 'validated'}}
  ...  *RETURN VALUE*:
  ...  - Dictionary of Values or Dictionaries of all given states for all given cells
  ...  *Author*: Jaroslaw Piszczala
  [Arguments]  ${distsNames}  @{states}
  ${distsDict}=  create dictionary
  FOR  ${dist}  IN  @{distsNames}
    ${value}=  Infomodel Get Object State  ${dist}  @{states}
    Set to dictionary  ${distsDict}  ${dist}  ${value}
  END
  [Return]  ${distsDict}

Infomodel Get Cell Parameter
  [Documentation]
  ...  Return value of given parameter from given Cell.
  ...
  ...  *RETURN VALUE*:
  ...  - Value of parameter
  ...  *Author*: Jaroslaw Piszczala
  [Arguments]  ${distName}  ${parameter}
  ${cellInfo}=  query infomodel  get object ${dist_cells} is [LCELL_DN="${distName}"]
  [Return]  ${cellInfo.${parameter}}

Infomodel Get BTS State
  [Documentation]
  ...  Return state value of BTS.
  ...
  ...  *RETURN VALUE*:
  ...  - BTS State value
  ...
  ...  *Author*: Jaroslaw Piszczala
  ${stateInfo}=  Infomodel Get StateInfo  ${dist_bts}
  [Return]  ${stateInfo.proceduralState}

Infomodel Is BTS Commisioned
  [Documentation]
  ...  Check if BTS is in commisioned state or not and return true/false.
  ...
  ...  *RETURN VALUE*:
  ...  - True if BTS is commisioned, and false if not.
  ...
  ...  *Author*: Jaroslaw Piszczala
  ${proceduralState}=  Infomodel Get BTS State
  @{uncommision}=  create list  initializing  notCommisioned
  ${result}=  run keyword and ignore error  List Should not Contain Value  ${uncommision}  ${proceduralState}  msg=
  return from keyword if  '${result[0]}' == 'PASS'  ${true}
  [Return]  ${false}

_Get SW Version For SMOD
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${module}: <description>
    ...        ${im_param}: <description>
    ...        ${alias}: <description>
    ...
    ...    Returns:
    ...        ${sw_versions[0]}: <description>
    [Arguments]    ${module}=MSM    ${im_param}=activeSoftwareVersion  ${alias}=default
    ${working_modes}=    Create Dictionary    MSM=Active    ESM=Idle    all=Active

    ${mode}=    Get From Dictionary    ${working_modes}    ${module}

    ${swm_objs}=    Query Infomodel    get list //RAT-1/SWM-* is [workingMode=${mode}]
    ...  allow_negative_result=${True}  alias=${alias}
    Return From Keyword If    not ${swm_objs}    ${EMPTY}

    ${sw_versions}=    Create List

    FOR    ${swm_obj}    IN    @{swm_objs}
        ${bts_l_dn}=    Set Variable    ${swm_obj.hardwareViewDNs[0]}
        ${bts_conf_obj}=    Query Infomodel    get object ${bts_l_dn}/BTS_CONF-1  alias=${alias}
        ${sw_version}=    Get From Dictionary    ${bts_conf_obj}    ${im_param}
        Append To List    ${sw_versions}    ${sw_version}
    END
    Return From Keyword If    '${module}'=='all'    ${sw_versions}  # return the whole list
    [Return]    ${sw_versions[0]}

Infomodel Get Active SW Version
  [Arguments]    ${module}=MSM  ${im_param}=activeSoftwareVersion  ${alias}=default
  [Documentation]
  ...  Return active software version for selected SMOD.
  ...
  ...  Mind that if there are two SMODs connected to a not commissioned BTS, KW will return:
  ...  - a list of SW versions for both SMODs if `module` is set to `MSM` or `all`
  ...  - an empty list if `module` is set to `ESM`
  ...  This results from both SMODs being marked in Infomodel as Active (i.e. master system module).
  ...
  ...  *PARAMETERS*
  ...   | =Parameter=       | =Man.= | =Description=                                       | =Default=              |
  ...   | `module`          | no     | Determines from which SMOD the SW Version is obtained (MSM, ESM, all).  | MSM  |
  ...   |'im_param'| no | Determines which parameter should be taken to read active sw version | activeSoftwareVersion|
  ...   | `alias`           | no     | Determines alias in connection to infomodel                  | default   |
  ...
  ...  *RETURN VALUE*
  ...  - Active SW version
  ...
  ...    *AUTHOR*
  ...    andrzej.cichon@nokia.com
  ${sw_version}=    _Get SW Version For SMOD    module=${module}    im_param=${im_param}  alias=${alias}
  [Return]    ${sw_version}

Infomodel Get Passive SW Version
  [Arguments]    ${module}=MSM  ${im_param}=passiveSoftwareVersion  ${alias}=default
  [Documentation]
  ...  Return passive software version
  ...  For more details, see documentation for `Infomodel Get Active SW Version`.
  ...
  ...  *PARAMETERS*
  ...   | =Parameter=       | =Man.= | =Description=                            | =Default=               |
  ...   | `module`          | no | Determines from which SMOD the SW Version is obtained (MSM, ESM, all).| MSM|
  ...   | 'im_param'|no| Determines which parameter should be taken to read passive sw version| passiveSoftwareVersio|
  ...   | `alias`           | no     | Determines alias in connection to infomodel| default                 |
  ...
  ...  *RETURN VALUE*
  ...  - Passive SW version
  ...
  ...    *AUTHOR*
  ...    andrzej.cichon@nokia.com
  ${sw_version}=    _Get SW Version For SMOD    module=${module}    im_param=${im_param}  alias=${alias}
  [Return]    ${sw_version}

Infomodel Get Planned SW Version
  [Arguments]    ${module}=MSM  ${im_param}=plannedSoftwareVersion  ${alias}=default
  [Documentation]
  ...  Return passive software version
  ...  For more details, see documentation for `Infomodel Get Active SW Version`.
  ...
  ...  *PARAMETERS*
  ...   | =Parameter=       | =Man.= | =Description=                           | =Default=               |
  ...   | `module`          | no     | Determines from which SMOD the SW Version is obtained (MSM, ESM, all).| MSM|
  ...   | 'im_param'|no|Determines which parameter should be taken to read planned sw version| passiveSoftwareVersion|
  ...   | `alias`           | no     | Determines alias in connection to infomodel       | default  |
  ...
  ...  *RETURN VALUE*
  ...  - Active SW version
  ...
  ...    *AUTHOR*
  ...    andrzej.cichon@nokia.com
  ${sw_version}=    _Get SW Version For SMOD    module=${module}    im_param=${im_param}  alias=${alias}
  [Return]    ${sw_version}

Infomodel Get SW Versions
    [Arguments]    ${log_to_console}=${True}  ${module}=MSM  ${alias}=default
    [Documentation]
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    ...
  ...  *PARAMETERS*
  ...   | =Parameter=       | =Man.= | =Description=                                          | =Default= |
  ...   | `log_to_console`  | no| Determines if log active and passive sw version to console is expected or not| TRUE|
  ...   | `module`          | no     | Determines from which SMOD the SW Version is obtained (MSM, ESM, all). | MSM  |
  ...   | `alias`           | no     | Determines alias in connection to infomodel         | default   |
    ...  *RETURN VALUE*
    ...  :return:           list with active and passive SW
    ...
    ${activeSoftwareVersion}=   Infomodel Get Active SW Version  ${module}  alias=${alias}
    ${passiveSoftwareVersion}=  Infomodel Get Passive SW Version  ${module}  alias=${alias}
    Log  active SW: ${activeSoftwareVersion}  console=${log_to_console}
    Log  passive SW: ${passiveSoftwareVersion}  console=${log_to_console}
    [Return]  ${activeSoftwareVersion}  ${passiveSoftwareVersion}

Infomodel Backup Commissioning
  [Documentation]
  ...  Copy commissioning file to destination on the local machine, for given local path.
  ...  Return commissioning file name.
  ...
  ...  *EXAMPLE*:
  ...  |         | Infomodel Backup Commissioning | . |
  ...  |         | Infomodel Backup Commissioning | . | ip=192.168.255.1 |
  ...  | ${scfc} | Infomodel Backup Commissioning | . | ip=192.168.255.1 |
  ...  ${scfc} => /rom/config/SCFC_9.xml
  ...
  ...  *Author*: Jaroslaw Piszczala
  [Arguments]  ${local_path}  ${ip}=192.168.255.1  ${login}=toor4nsn  ${password}=oZPS0POrRieRtu
  ${config}=  Query Infomodel  get object ${dist_commissioning}
  SSHLibrary.Open Connection  ${ip}
  SSHLibrary.Login  ${login}  ${password}
  SSHLibrary.Get File  ${config.path}  ${local_path}

  ${ignore}    ${filename}=    Split String From Right    ${config.path}    separator=/  max_split=1
  [Return]    ${filename}
  [Teardown]    SSHLibrary.Close Connection

Infomodel Check If All Objects From Path Are Online
  [Documentation]
    ...  Infomodel Check If All Objects From Path Are Online. Get status and table to log.
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** ---
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------+------+--------------+-----------------------------------------------------+
    ...  | Parameter name    | Man. | Description     | Default                                             |
    ...  +===================+======+============================+===================================================+
    ...  | path              | yes  | Path to checked objects. You can use infomodel query syntax (//,* etc.)  | -  |
    ...  +-------------------+------+--------+-----------------------------------------------------+
    ...  | timeout           | no   | Time of waiting. You can use robot framework time syntax (1s,1m,1h etc.) | 5m  |
    ...  +-------------------+------+-----+-----------------------------------------------------+
    ...  | print_table       | no   | If true, table will be printed inside keyword                            | False |
    ...  +-------------------+------+-----+-----------------------------------------------------+
    ...  | *parameters_list  | no   | Parameters to check. Use name=value form |    operationalState=${_Enabled} |
    ...  +-------------------+------+---------------+-----------------------------------------------------+
    ...
    ...  **Return Parameters:**
    ...
    ...  +----------------+------------------------------------------------------------------------------------------+
    ...  | Parameter name | Description                                                                              |
    ...  +================+==========================================================================================+
    ...  | ${status}      | True if all objects are online, false if not.                                            |
    ...  +----------------+------------------------------------------------------------------------------------------+
    ...  | ${table}       | Alias for info table with timestamp. Use it with 'Log table' keyword from hran_logging.  |
    ...  +----------------+------------------------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${status}   ${table}  Infomodel Check If All Objects From Path Are Online  //BBTOP_M-*//CELL_M-*  3m  True
    ...     Log    Nothing    #Log table   ${table}
    ...
  [Arguments]  ${path}  ${timeout}=5m  ${print_table}=${False}  @{parameters_list}
  ${parameters_list}=  Run keyword if  ${parameters_list}  Set variable  ${parameters_list}
  ...  ELSE  create list     operationalState=${_Enabled}
  ${string}=  catenate  SEPARATOR=,stateInfo.  @{parameters_list}
  ${string}=  catenate  SEPARATOR=  stateInfo.  ${string}
  @{states_names}=  Create list
  FOR  ${state}  IN  @{parameters_list}
      ${state_name}  ${state_value}=  Split String  ${state}  separator==
      Append to list  ${states_names}  ${state_name}
  END
  ${status}=  Run keyword and return status  query infomodel  every ${path} is [${string}]  timeout=${timeout}
  ${timesec}=  Get Time  epoch
  #${table}=  Create table  check_objects_table-${timesec}  distName  @{states_names}
  ${table}=		Create List
  ${all_cels}=  Query infomodel  get list ${path}
  FOR  ${cell}  IN  @{all_cels}
    ${cell_dn}=  Set variable  ${cell.dist_name}
    @{states_values}=  _Get States Values from Cell object  ${states_names}  ${cell}
    #${table}=  Add row  ${table}  ${cell_dn}  @{states_values}
	Append To List		${table}	${cell_dn}
  END
  Run keyword if  ${print_table}  Log    Nothing    #Log table  ${table}
  [Return]  ${status}  ${table}

Infomodel Get Object States Values From Path
  [Documentation]
  ...  Keyword for getting object stateInfo values from Infomodel distName path
  ...
  ...  *AUTHOR*
  ...  patryk.furman@nokia.com
  ...
  ...  | Parameters     | Man.  | Description                  |
  ...  | path           | Yes   | Infomodel object distPath    |
  ...  | parameter_list | Yes   | List of parameters names     |
  ...
  ...  *RETURN*
  ...  |  Parameters |  Description              |
  ...  |  table      |  Table with states values |
  ...
  ...  *EXAMPLE*
  ...  | ${table} =  | Infomodel Get Object States Values From Path
  ...  | /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/WNBTS_M-*/CELL_M-* | administrativeState | usageState |

  [Arguments]  ${path}  @{parameters_list}
  ${table}=  Create List
  #${table}=  Create Table  Infomodel_Get_Object_States_Values_From_Path  distName  @{parameters_list}
  ${objects}=  Query infomodel  get list ${path}
  FOR  ${object}  IN  @{objects}
    ${object_dn}=  Set variable  ${object.dist_name}
    ${states_values}=  _Get States Values from Cell object  ${parameters_list}  ${object}
	Append To List$		{table}		${states_values}
    #${table}=  Add row  ${table}  ${object_dn}  @{states_values}
  END
  [Return]  ${table}

_Get States Values from Cell object
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${states_list}: <description>
    ...        ${cell_object}: <description>
    ...
    ...    Returns:
    ...        @{values_list}: <description>
  [Arguments]  ${states_list}  ${cell_object}
  ${values_list}=  create list
  FOR  ${state}  IN  @{states_list}
    Append to list  ${values_list}  ${cell_object.stateInfo.${state}}
  END
  [Return]  @{values_list}

Infomodel Cell State Should Be
  [Documentation]
  ...  Compare Cell state
  ...
  ...  *RETURN VALUE*:
  ...  - True if state value is equal, false if not.
  ...
  ...  *EXAMPLE*:
  ...  | Infomodel Cell State Should Be | /MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/LCELL-12 | operationalState | Disabled |
  ...  | Infomodel Cell State Slhould Be | /MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/LCELL-13 | availabilityStatus | onAirDone |
  ...
  ...  *Author*: Jaroslaw Piszczala
  [Arguments]  ${distName}  ${stateName}  ${stateValue}
  ${cellState}=  Infomodel Get Cell State  ${distName}  ${stateName}
  Return From Keyword If  '${cellState}'=='${stateValue}'  ${True}
  [Return]  ${False}

Infomodel Cells State Should Be
  [Documentation]
  ...  Compare Cell state for cells list
  ...
  ...  *RETURN VALUE*:
  ...  - True if state value is equal in all cells, false if not.
  ...
  ...  *EXAMPLE*:
  ...  | ${dists}= | Create List | /MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/LCELL-11 |
   ...  /MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/LCELL-12 | /MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/LCELL-13 |
  ...  | Infomodel Cells State Should Be | ${dists} | operationalState | Disabled |
  ...  | Infomodel Cells State Should Be | ${dists} | availabilityStatus | onAirDone |
  ...
  ...  *Author*: Jaroslaw Piszczala
  [Arguments]  ${distsName}  ${stateName}  ${stateValue}
  FOR  ${dist}  IN  @{distsName}
    ${output}=  Infomodel Cell State Should Be  ${dist}  ${stateName}  ${stateValue}
    Run Keyword If  '${output}'=='False'
    ...  Return From Keyword  ${False}
  END
  [Return]  ${True}

Infomodel Get StateInfo
  [Documentation]
  ...  Return StateInfo from given object
  ...
  ...  *RETURN VALUE*:
  ...  - Dictionary of all states
  ...  *Author*: Jaroslaw Piszczala
  [Arguments]  ${distName}
  ${state}=  query infomodel  get object ${distName}
  [Return]  ${state.stateInfo}

Infomodel Get ConnectionList
  [Documentation]
  ...  Return connectionList from given object
  ...
  ...  | **Author:** sebastian.burniak@nokia.com
  ...  | **Released with version:** hran_56
  ...  | **Full description:**
  ...  | Return full connectionList from given object
  ...  **Input Parameters:**
  ...
  ...  +------------------+------+----------------------------------+
  ...  | Parameter name   | Man. | Description                      |
  ...  +==================+======+==================================+
  ...  | distName         | yes  | Full dist Name to given object   |
  ...  +------------------+------+----------------------------------+
  ...  **Return Parameters:**
  ...
  ...  +--------------------+-----------------------------------------------------------------------------------------+
  ...  | Parameter name     | Description                                                                             |
  ...  +====================+=========================================================================================+
  ...  | ${connectionList}  | Dictionary of all states at given connectionList                                        |
  ...  +--------------------+-----------------------------------------------------------------------------------------+

  [Arguments]  ${distName}
  ${object}=  query infomodel  get object ${distName}

  [Return]  ${object.connectionList}

Infomodel Objects State Should Be
  [Documentation]
  ...  *RETURN VALUE*:
  ...  Return True or False if state is like it should for all objects or not if one of them have different state,
  ...  respectively.
  ...
  ...  Compare states all objects
  ...  Input parameters are: list distName_list, stateName, state
  ...
  ...  *EXAMPLE*:
  ...  | Infomodel Objects State Should Be
  ...  | [/MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/LCELL-13, /MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/LCELL-12]|operationalState | Enabled|
  ...
  ...  *Author*: Michal Kwasniewicz
  [Arguments]  ${distName_list}  ${stateName}  ${state}

  FOR  ${distName}  IN  @{distName_list}
    ${output}  Infomodel Object State Should Be  ${distName}  ${stateName}  ${state}
    Run Keyword If  '${output}'=='False'
    ...  Return From Keyword  ${False}
  END
  [Return]  ${True}

Infomodel Object State Should Be
  [Documentation]
  ...  *RETURN VALUE*:
  ...  Return True or False if state is like it should or not, respectively.
  ...
  ...  Compare state of object.
  ...
  ...  *EXAMPLE*:
  ...  | Infomodel Object State Should Be | /MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/LCELL-13 | operationalState | Enabled |
  ...
  ...  *Author*: Michal Kwasniewicz
  [Arguments]  ${distName}  ${stateName}  ${state}

  ${obj_module}=  Query Infomodel  get object ${dist_name}
  Return From Keyword If  '${obj_module['stateInfo']['${stateName}']}'=='${state}'  ${True}
  [Return]  ${False}

Infomodel BTS State Should Be
  [Documentation]
  ...  *RETURN VALUE*:
  ...  Return True or False if state is like it should or not, respectively.
  ...
  ...  Compare state of BTS.
  ...  State Name are: usageState, administrativeState,
  ...  reasoningStatus, operationalState, availabilityStatus.
  ...
  ...  *EXAMPLE*:
  ...  | Infomodel BTS State Should Be | administrativeState | Unlocked |
  ...
  ...  *Author*: Michal Kwasniewicz
  [Arguments]  ${stateName}  ${state}

  ${obj_module}=  Query Infomodel  get object ${dist_bts}
  Return From Keyword If  '${obj_module['stateInfo']['${stateName}']}'=='${state}'  ${True}
  [Return]  ${False}

Infomodel Get Objects Parameter
  [Arguments]  ${objects_dist_name}  ${parameter}  ${allow_negative_result}=False
  [Documentation]
  ...  KW for obtaining list of values of one specified parameter for all InfoModel objects matching 'objects_dist_name'
  ...
  ...  *Author*: Tomasz Filipek
  ...
  ...  | Parameter             | Man. | Description |
  ...  | objects_dist_name     | Yes  | Objects dist_name complies with query_infomodel syntax |
  ...  | parameter             | Yes  | Parameters name |
  ...  | allow_negative_result | No   | Allow False to be returned instead of InfoModelQueryTimeoutException |
  ...
  ...  *RETURN*
  ...  | Parameter        | Description              |
  ...  | parameter_values | List of parameter values |
  ...
  ...  *EXAMPLE*
  ...  | ${parameter_values}= | Infomodel Get Objects Parameter | //EQM_L-1//SMOD_L-* | serialNumber

  ${objects}=  Query Infomodel  get list ${objects_dist_name}  allow_negative_result=${allow_negative_result}
  ${parameter_values}=  Create List
  FOR  ${object}  IN  @{objects}
      Append To List  ${parameter_values}  ${object['${parameter}']}
  END
  [Return]  ${parameter_values}

Infomodel Avoid Objects Parameters With Specific State
  [Arguments]  ${objects}  ${param}  ${state_name}  ${state_value}
  [Documentation]
  ...  *RETURN VALUE*:
  ...  Return list of parameters which don't have specific state
  ...
  ...  *Author*: Michal Kwasniewcz
  ...
  ...  | Parameter     | Man. | Description                    |
  ...  | objects       | Yes  | Object distPath from InfoModel |
  ...  | param         | Yes  | parameter names                |
  ...  | state_name    | Yes  | state name                     |
  ...  | state_value   | Yes  | state value                    |
  ...

  ${list_obj}=  Query Infomodel  get list ${objects}
  ${list_parameters}=  Create List
  FOR  ${var}  IN  @{list_obj}
    Run Keyword If  "${var['stateInfo']['${state_name}']}"!="${state_value}"
    ...  Append To List  ${list_parameters}  ${var['${param}']}
  END
  [Return]  ${list_parameters}

Infomodel Get Object Parameters
  [Documentation]
  ...  KW for obtaining list of InfoModel object parameters values from given object distPath
  ...
  ...  *AUTHOR*
  ...  patryk.furman@nokia.com
  ...
  ...  | Parameter     | Man. | Description                    |
  ...  | obj_dist_name | Yes  | Object distPath from InfoModel |
  ...  | parameters    | Yes  | List of parameters names       |
  ...
  ...  *RETURN*
  ...  | Parameter    | Description               |
  ...  | param_values | List of parameters values |
  ...
  ...  *EXAMPLE*
  ...  | ${param_values}= | Infomodel Get Object Parameters | /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1
  ...  | activeSoftwareVersion | passiveSoftwareVersion |

  [Arguments]  ${obj_dist_name}  @{parameters}
  ${object}=  Query Infomodel  get object ${obj_dist_name}
  ${param_values}=  Create List  @{EMPTY}
  FOR  ${param}  IN  @{parameters}
      Append To List  ${param_values}  ${object['${param}']}
  END
  [Return]  ${param_values}

Infomodel Get All Cells distName
  [Documentation]
  ...  *RETURN VALUE*:
  ...  Return list contain all cell dist name.
  ...
  ...  *Author*: Michal Kwasniewicz

  ${objects}=  Infomodel Get Objects Parameter  ${dist_cells}  dist_name
  [Return]  ${objects}

Infomodel Get LTE Cells distName
  [Documentation]
  ...  *RETURN VALUE*:
  ...  Return list contain all radio modules dist name.
  ...
  ...  *Author*: Michal Kwasniewicz

  ${objects}=  Infomodel Get Objects Parameter  ${dist_LTE_cell}  dist_name
  [Return]  ${objects}

Infomodel Get All Radio Modules distName
  [Documentation]
  ...  *RETURN VALUE*:
  ...  Return list contain all radio modules dist name.
  ...
  ...  *Author*: Michal Kwasniewicz

  ${objects}=  Infomodel Avoid Objects Parameters With Specific State
  ...  ${dist_radio}  dist_name  proceduralState  fromSCF
  [Return]  ${objects}

Infomodel Get All System Modules distName
  [Documentation]
  ...  *RETURN VALUE*:
  ...  Return list contain all system modules dist name.
  ...
  ...  *Author*: Michal Kwasniewicz

  ${objects}=  Infomodel Get Objects Parameter  ${dist_smod}  dist_name
  [Return]  ${objects}

Infomodel Get Modules For Interfaces
  [Documentation]
    ...  *RETURN VALUE*:
  ...  Return list of modules types and serial numbers
  ...
  ...  *Author*: Tomasz Filipek

  ${list_obj}=  Create List
  ${smods}=  Infomodel Get Objects Parameter  ${dist_smod}  serialNumber
  ${rmods}=  Infomodel Get Objects Parameter  ${dist_radio}  serialNumber
  FOR  ${mod}  IN  @{smods}
    Append To List  ${list_obj}  SMOD_${mod}
  END
  FOR  ${mod}  IN  @{rmods}
    Append To List  ${list_obj}  RMOD_${mod}
  END
  [Return]  ${list_obj}

Infomodel Get All Modules distName
  [Documentation]
  ...  *RETURN VALUE*:
  ...  Return list contain all modules dist name.
  ...
  ...  *Author*: Michal Kwasniewicz

  ${list_distName_SM}=  Infomodel_Get_All_System_Modules_distName
  ${list_distName_RM}=  Infomodel_Get_All_Radio_Modules_distName
  ${list_distName}=  Combine Lists  ${list_distName_SM}  ${list_distName_RM}
  [Return]  ${list_distName}

Infomodel Get All Radio Modules Serial Numbers
    [Documentation]
    ...  *RETURN VALUE*:
    ...  List of BTS RMODs serial numbers
    ...
    ...  *Author*: Patryk Furman

    ${rmods}=  Infomodel Get Objects Parameter  ${dist_radio}  serialNumber
    [Return]  ${rmods}

Infomodel Get All Radio Modules IPs
  [Documentation]
  ...  *RETURN VALUE*:
  ...  Return dictionary contain radio modules IPs.
  ...  Key is dist name and value is ip.
  ...
  ...  *Author*: Michal Kwasniewicz

  ${list_obj}=  Query Infomodel  get list ${dist_radio}
  ${dict_RM_IP}=  Create Dictionary
  FOR  ${var}  IN  @{list_obj}
    Set To Dictionary  ${dict_RM_IP}  ${var['dist_name']}  ${var['ipAddress']}
  END
  [Return]  ${dict_RM_IP}

Infomodel Get All Modules IPs
  [Documentation]
  ...  *RETURN VALUE*:
  ...  Return dictionary contain modules IPs.
  ...  Key is dist name and value is ip.
  ...
  ...  *Author*: Michal Kwasniewicz

  ${list_obj}=  Query Infomodel  get list ${dist_smod}
  ${dict_SM_IP}=  Infomodel_Get_All_Radio_Modules_IPs
  FOR  ${var}  IN  @{list_obj}
    Set To Dictionary  ${dict_SM_IP}  ${var['dist_name']}  ${var['ipAddress']}
  END
  [Return]  ${dict_SM_IP}

Infomodel Get Cell distName
  [Documentation]
  ...  *Author*: Jaroslaw Piszczala
  [Arguments]  ${lncell}
  ${cellInfo}=  query infomodel  get object ${lncell}
  [Return]  ${cellInfo.LCELL_DN}

Infomodel Check Connection
    [Documentation]
    ...  Helper function which checks if infomodel is connected.
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com
    ...
    ...  | Parameters | Man. | Description                                    |
    ...  | im_alias   | Yes  | Alias used for IM connection (Master or Slave) |
    ...
    ...  *EXAMPLE*
    ...  | Infomodel Check Connection | Master |

    [Arguments]  ${im_alias}
    ${is_connected}=  is infomodel connected  alias=${im_alias}
    should be true  ${is_connected}  Infomodel connection can't be established

Infomodel Wait For Connection After Reset
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${IM alias}: <description>
    ...        ${reset timeout}: <description>
    ...        ${response timeout}: <description>
  [Arguments]  ${IM alias}  ${reset timeout}  ${response timeout}
  Wait For Infomodel Response After Reset
  ...  alias=${IM alias}  timeout_for_reset=${reset timeout}  timeout_for_response=${response timeout}

Infomodel Check LTE Expected Procedural State
  [Arguments]  ${IM alias}  ${exp pro state}  ${timeout}
  [Documentation]  Author: Agnieszka Malek
  ...
  ...  Verifing whether procedural state is the same as expected one.
  Query infomodel
  ...  alias=${IM alias}  query=${dist_LTE_bts} is [stateInfo.proceduralState=regex"${exp pro state}"]
  ...  timeout=${timeout}

Infomodel Check LTE Operational Procedural and Blocking states
    [Documentation]
    ...  Keyword checking LTE BTS operationalState, proceduralState and blockingState
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter     | Man.  | Description                              |
    ...  | alias         | Yes   | alias of ute_infomodel instance          |
    ...  | exp op state  | Yes   | expected operational state               |
    ...  | exp pro state | Yes   | expected procedural state                |
    ...  | exp blk state | No    | expected blocking state                  |
    ...  | timeout       | No    | time in seconds after which KW will fail |
    ...
    ...  *RETURN*
    ...  KW is passed if expected states are correlated with LTE BTS states, otherwise failed
    ...

    [Arguments]  ${IM alias}  ${exp op state}  ${exp pro state}  ${exp blk state}=[\\s\\S]*  ${timeout}=90
    ${alias_connection}=  Convert to Uppercase  ${IM alias}
    Wait until keyword succeeds  1min  200ms  Infomodel Check Connection  ${IM alias}
    ${exp pro state}=  Set Variable If  '${exp pro state}'=='onAir'  [oO]nAir  ${exp pro state}
    ${MRBTS_object_found}=  Check Infomodel Object  dist_name=//MRBTS_M-1  alias=${IM alias}
    ${MRBTS_states_found}=  Run Keyword If  ${MRBTS_object_found}  Infomodel Check MRBTS object  ${IM alias}
    ${tmp_bool}=      Evaluate     ${MRBTS_object_found} and ${MRBTS_states_found}
    ${query_1}=     Set Variable    //MCTRL-${${alias_connection}\['${alias_connection}_SUBRACK']}
    ${query_2}=   	Catenate	SEPARATOR=,
    ...  //MRBTS_M-1 is [stateInfo.operationalState=regex"${exp op state}"
    ...  stateInfo.proceduralState=regex"${exp pro state}"
    ...  stateInfo.blockingState=regex"${exp blk state}"]
     ${query_tmp}=   	Catenate	SEPARATOR=     ${query_1}    ${query_2}
    ${query_3}=   	Catenate	SEPARATOR=,
    ...  //LNBTS-1 is [stateInfo.operationalState=regex"${exp op state}"
    ...  stateInfo.proceduralState=regex"${exp pro state}"
    ...  stateInfo.blockingState=regex"${exp blk state}"]

    Run Keyword If
    ...  ${tmp_bool} and '${${alias_connection}\['${alias_connection}_MODULE_TYPE']}'=='ASIA'
    ...  Query infomodel  alias=${IM alias}
    ...  query=${query_tmp}
    ...  timeout=${timeout}
    ...  ELSE IF
    ...  ${tmp_bool} and '${${alias_connection}\['${alias_connection}_MODULE_TYPE']}'!='ASIA'
    ...  Query infomodel  alias=${IM alias}
    ...  query=${query_2}
    ...  timeout=${timeout}
    ...  ELSE
    ...  Query infomodel  alias=${IM alias}
    ...  query=${query_3}
    ...  timeout=${timeout}

Infomodel Check MRBTS object
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${IM alias}: <description>
    ...
    ...    Returns:
    ...        ${MRBTS_states_found}: <description>
    [Arguments]  ${IM alias}
    ${alias_connection}=  Convert to Uppercase  ${IM alias}
    ${MRBTS_state}=  Run Keyword If  '${${alias_connection}\['${alias_connection}_MODULE_TYPE']}'=='ASIA'
    ...  Query infomodel  alias=${IM alias}
    ...  query=get object //MCTRL-${${alias_connection}\['${alias_connection}_SUBRACK']}//MRBTS_M-1
    ...  ELSE
    ...  Query infomodel  alias=${IM alias}  query=get object //MRBTS_M-1
    ${MRBTS_operationalState}=  Run Keyword And Return Status
    ...  Variable Should Exist  ${MRBTS_state['stateInfo']['operationalState']}
    ${MRBTS_proceduralState}=  Run Keyword And Return Status
    ...  Variable Should Exist  ${MRBTS_state['stateInfo']['proceduralState']}
    ${MRBTS_blockingState}=  Run Keyword And Return Status
    ...  Variable Should Exist  ${MRBTS_state['stateInfo']['blockingState']}
    ${MRBTS_states_found}=  Set Variable If
    ...  ${MRBTS_operationalState} and ${MRBTS_proceduralState} and ${MRBTS_blockingState}  ${TRUE}  ${FALSE}
    [Return]  ${MRBTS_states_found}

Infomodel Check Active Alarms
    [Documentation]
    ...  Checking alarms based on Infomodel. Fail if any critical alarm occured or if any from expected missed.
    ...  If ${print_alarms} will be set to True print alarms lists with their severity
    ...
    ...  *AUTHOR*
    ...  Dinu Olariu
    ...
    ...  | Parameter       | Man. | Description                            |
    ...  | IM alias | No | alias of ute_infomodel instance |
    ...  | expected_patterns | No   | List of expected alarms |
    ...  | ignored_patterns | No   | List of ignored alarms  |
    ...  | critical_patterns | No   | List of critical alarms  |
    ...  | timeout | No | Timeout in seconds to wait for Infomodel connection |
    ...  | print_alarms | No   | Boolean to decide whether output lists should be printed with proper severity   |
    ...
    [Arguments]  ${IM alias}=default  ${expected_patterns}=@{EMPTY}  ${ignored_patterns}=@{EMPTY}
    ...  ${critical_patterns}=@{EMPTY}  ${timeout}=90  ${print_alarms}=${TRUE}
    Wait until keyword succeeds  ${timeout}sec  200ms  Infomodel Check Connection  ${IM alias}
    ${active_alarms}=  Infomodel Get All Active Alarms  ${IM alias}  timeout=${timeout}
    ${found expected alarms}  ${not found expected alarms patterns}  ${found critical alarms}
    ...  ${found ignored alarms}  ${found not classified alarms}=
    ...  AlarmAnalysis.Get Filtered Alarms
    ...  ${active_alarms}  ${expected_patterns}  ${ignored_patterns}  ${critical_patterns}
    Run Keyword If  ${print_alarms}  AlarmAnalysis.Print Alarms
    ...  ${found expected alarms}  ${not found expected alarms patterns}
    ...  ${found critical alarms}  ${found ignored alarms}  ${found not classified alarms}
    Run Keyword If  ${not found expected alarms patterns} or ${found critical alarms}  Fail

InfoModel Check LTE Working States and Alarms
    [Arguments]  ${LTE exp operational state}=[\\s\\S]*  ${LTE exp procedural state}=[\\s\\S]*
    ...  ${LTE exp blocking state}=[\\s\\S]*
    ...          ${LTE exp alarms}=@{EMPTY}  ${LTE ign alarms}=@{EMPTY}  ${LTE cri alarms}=@{EMPTY}
    ...          ${LTE alias}=${Empty}
    [Documentation]  *AUTHOR* Dinu Olariu
    Infomodel Check LTE Operational Procedural and Blocking states
    ...  IM alias=${LTE alias}  exp op state=${LTE exp operational state}  exp pro state=${LTE exp procedural state}
    ...  exp blk state=${LTE exp blocking state}
    Infomodel Check Active Alarms  IM alias=${LTE alias}  expected_patterns=${LTE exp alarms}
    ...  ignored_patterns=${LTE ign alarms}  critical_patterns=${LTE cri alarms}

Infomodel Get All Active Alarms
  [Documentation]  *AUTHOR* Dinu Olariu
  ...
  ...  Get list of all active alarms on LTE and returns it.
  [Arguments]  ${IM alias}=default  ${timeout}=90
  ${alias}=  Convert To Uppercase  ${IM alias}
  ${alarms}=  Run Keyword If  '${${alias}\['${alias}_MODULE_TYPE']}'=='ASIA'
  ...  Query infomodel  alias=${IM alias}
  ...  get list //LNBTS_L-${${alias}\['${alias}_SUBRACK']}//ALARM_L-*  timeout=${timeout}  allow_negative_result=True
  ...  ELSE
  ...  Query infomodel  alias=${IM alias}  query=get list //ALARM_L-*  timeout=${timeout}  allow_negative_result=True
  [Return]  ${alarms}

Infomodel Get All Active Alarms Narrow List
  [Documentation]
  ...  Get list of InfoModel active alarms and returns list where each alarm has only three fields (faultId,
  ...  alarmNumber, faultDescription)
  ...
  ...  *AUTHOR*
  ...  patryk.furman@nokia.com
  ...
  ...  | Parameters | Man. | Description                  |
  ...  | IM alias   | No   | Alias used for IM connection |
  ...  | timeout    | No   | Timeout for IM quering       |
  ...
  ...  *RETURN*
  ...  | Parameters         | Description                        |
  ...  | alarm_details_list | List of narrow alarms dictionaries |
  ...
  ...  *EXAMPLE*
  ...  | ${alarm_details_list}= | Infomodel Get All Active Alarms Narrow List |

  [Arguments]  ${IM alias}=default  ${timeout}=90
  ${alarm_details_list}=  Create list  @{EMPTY}
  ${infomodel_alarms}=  Infomodel Get All Active Alarms  ${IM alias}  ${timeout}
  FOR  ${infomodel_alarm}  IN  @{infomodel_alarms}
    ${infomodel_detail}=  Infomodel Create Narrow Alarm Dictionary  ${infomodel_alarm}
    Append To List  ${alarm_details_list}  ${infomodel_detail}
  END
  [Return]  ${alarm_details_list}

Infomodel Create Narrow Alarm Dictionary
  [Documentation]
  ...  KW which extract only three fields (faultId, alarmNumber, faultDescription)
  ...  from whole InfoModel alarm dictionary
  ...  *AUTHOR*
  ...  patryk.furman@nokia.com
  ...
  ...  | Parameters       | Man. | Description                        |
  ...  | infomodel_alarm  | Yes  | LTE alarm dictionary from IM query |
  ...
  ...  *RETURN*
  ...  | Parameters     | Description                                       |
  ...  | alarms_details | Dictionary with extracted three main alarm fields |
  ...
  ...  *EXAMPLE*
  ...  | ${alarm_details}= | Infomodel Create Narrow Alarm Dictionary | ${infomodel_alarm} |

  [Arguments]  ${infomodel_alarm}
  ${alarm_details}=  Create Dictionary  faultId=${infomodel_alarm["alarmInformation"]["faultId"]}
  ...                                   alarmNumber=${infomodel_alarm["alarmInformation"]["alarmNumber"]}
  ...                                   alarmDetail=${infomodel_alarm["alarmInformation"]["alarmText"]["alarmDetail"]}
  ...                                   alarmSeverity=${infomodel_alarm["alarmInformation"]["alarmSeverity"]}
  [Return]  ${alarm_details}

Infomodel Get RMOD By Serial Number
    [Tags]  Helper
    [Documentation]
    ...  Returns RMOD InfomodelObject with specified serial number.
    ...
    ...  *AUTHOR*
    ...  milosz.nowak@nokia.com
    ...
    ...  |  Parameters     | Man. |  Description         |
    ...  |  serial_number  | Yes  |  RMOD serial number  |
    ...
    ...  *RETURN*
    ...  |  Parameters  |  Description           |
    ...  |  rmod        |  RMOD InfomodelObject  |
    ...
    ...  *EXAMPLE*
    ...  | ${rmod} =  | Infomodel Get RMOD By Serial Number  |  FGYU12345  |
	[Arguments]  ${serial_number}
    ${rmod_r} =  Get Infomodel Object  //RMOD_R-* is [serialNumber=${serial_number}]
    ${rmod_ref}=  Query Infomodel  get object ${rmod_r.dist_name}/REF-*
    ${rmod}=  Query Infomodel  get object ${rmod_ref.distName}
    [Return]  ${rmod}

Infomodel Get Cells Deployed On Bts
    [Tags]  Helper
    [Documentation]
    ...  Returns list of cells' InfomodelObjects deployed on BTS.
    ...
    ...  *AUTHOR*
    ...  milosz.nowak@nokia.com
    ...
    ...  *RETURN*
    ...  |  Parameters  |  Description               |
    ...  |  cells       |  List of InfomodelObjects  |
    ...
    ...  *EXAMPLE*
    ...  | ${cells} =  |  Infomodel Get Cells Deployed On Bts  |
    ${cells} =  Query Infomodel  get list //CELL_M-*
    [Return]  ${cells}

Infomodel Get Cells Deployed On Module
    [Tags]  Helper
    [Documentation]
    ...  Returns list of cells' InfomodelObjects deployed on specific module.
    ...
    ...  This keyword selects all cells which match the module's dist_name pattern in their devicesDNInPath.
    ...
    ...
    ...  *AUTHOR*
    ...  milosz.nowak@nokia.com
    ...
    ...  |  Parameters  | Man. |  Description             |
    ...  |  module      | Yes  |  module infomodelObject  |
    ...
    ...  *RETURN*
    ...  |  Parameters  |  Description               |
    ...  |  cells       |  List of InfomodelObjects  |
    ...
    ...  *EXAMPLE*
    ...  |  ${rmod} =            |  Infomodel Get RMOD By Serial Number     |  ABCD123456  |
    ...  |  ${cells_on_rmod} =   |  Infomodel Get Cells Deployed On Module  |  ${rmod}  |
    ...  |  ${bbmod} =           |  Query Infmodel  |  get object //BBMOD_L-1  |
    ...  |  ${cells_on_bbmod} =  |  Infomodel Get Cells Deployed On Module  |  ${bbmod}  |
    [Arguments]  ${module}
    ${cells_on_mod} =  Create List  @{EMPTY}
    ${cells} =  Query Infomodel  get list //CELL_M-*
    ${re} =  Set Variable  regex"${module.dist_name}/.*"
    FOR  ${cell}  IN  @{cells}
        ${contains} =  Query Infomodel
        ...  ${cell.dist_name}//PATH-* is [devicesDNInPath[?]=${re}]  allow_negative_result=True  timeout=0.1s
        ${contains} =  Convert To Boolean  ${contains}
        Run Keyword If  ${contains}  Append To List  ${cells_on_mod}  ${cell}
    END
    [Return]  ${cells_on_mod}

Infomodel Get Cells Deployed On RMOD
    [Tags]  Helper
    [Documentation]
    ...  Returns list of cells' InfomodelObjects deployed on specific RMOD.
    ...
    ...  This keyword selects all cells which have desired RMOD DN in their devicesDNInPath.
    ...
    ...  *AUTHOR*
    ...  milosz.nowak@nokia.com
    ...
    ...  |  Parameters  | Man. |  Description           |
    ...  |  rmod        | Yes  |  RMOD InfomodelObject  |
    ...
    ...  *RETURN*
    ...  |  Parameters  |  Description               |
    ...  |  cells       |  List of InfomodelObjects  |
    ...
    ...  *EXAMPLE*
    ...  | ${rmod} =   |  Infomodel Get RMOD By Serial Number   |  ABCD123456  |
    ...  | ${cells} =  |  Infomodel Get Cells Deployed On RMOD  |  ${rmod}     |
    [Arguments]  ${rmod}
    Run Keyword And Return  Infomodel Get Cells Deployed On Module  ${rmod}

Infomodel Cell Has At Least One Operational RXTX Pair
    [Tags]  Checker
    [Documentation]
    ...  Returns True if cell has at least one pair of RX and TX with operationalState Enabled,
    ...  False otherwise.
    ...
    ...  *AUTHOR*
    ...  milosz.nowak@nokia.com
    ...
    ...  |  Parameters  | Man. |  Description           |
    ...  |  cell        | Yes  |  cell InfomodelObject  |
    ...
    ...  *RETURN*
    ...  |  Parameters     |  Description                             |
    ...  |  has_rxtx_pair  |  True if cell has operational RXTX pair  |
    ...
    ...  *EXAMPLE*
    ...  | ${cell} =           | Query Infomodel  get object //CELL_M-1 |
    ...  | ${has_rxtx_pair} =  | Infomodel Cell Has At Least One Operational RXTX Pair  |  ${cell}
    [Arguments]  ${cell}
    ${has_rx} =  Set Variable  ${cell.dist_name}//CHANNEL_M-* is [stateInfo.operationalState=${_Enabled}, direction=RX]
    ${has_tx} =  Set Variable  ${cell.dist_name}//CHANNEL_M-* is [stateInfo.operationalState=${_Enabled}, direction=TX]
    ${queries} =  Create Dictionary  has_rx=${has_rx}   has_tx=${has_tx}
    ${status} =  Run Keyword And Return Status  Query Infomodel Sequence  &{queries}
    ${has_rxtx_pair} =  Convert To Boolean  ${status}
    [Return]  ${has_rxtx_pair}

Infomodel Cell Carriers Should Be Restored
    [Tags]  Assert
    [Documentation]
    ...  Verifies that carriers of given cell were restored.
    ...
    ...  Keyword fails if carriers could not be restored.
    ...
    ...  *AUTHOR*
    ...  milosz.nowak@nokia.com
    ...
    ...  |  Parameters  | Man. |  Description           |
    ...  |  cell        | Yes  |  cell InfomodelObject  |
    ...
    ...  *EXAMPLE*
    ...  | ${cell} =  |  Query Infomodel  |  get object //CELL_M-1  |
    ...  | Infomodel Cell Carriers Should Be Restored  |  ${cell}   |
    [Arguments]  ${cell}
    ${is_restored} =  Query Infomodel  ${cell.dist_name} is [carriersState=Activated]  allow_negative_result=True
    ${is_restored} =  Convert To Boolean  ${is_restored}
    Run Keyword If  ${is_restored}   Log  Carriers on ${cell.dist_name} successfully restored  console=yes
    ...       ELSE  Fail  Carriers on ${cell.dist_name} not restored.

Infomodel Cell Should Be Disabled
    [Tags]  Assert
    [Documentation]
    ...  Verifies that status of given cell is disabled.
    ...
    ...  In case of failure logs message with specified level. Default WARN.
    ...
    ...  *AUTHOR*
    ...  milosz.nowak@nokia.com
    ...
    ...  |  Parameters  | Man. |  Description           |
    ...  |  cell        | Yes  |  cell InfomodelObject  |
    ...  |  level       | No   |  failure log level     |
    ...
    ...  *EXAMPLE*
    ...  | ${cell} =  |  Query Infomodel  |  get object //CELL_M-1  |
    ...  | Infomodel Cell Should Be Disabled  |  ${cell}            |
    [Arguments]  ${cell}  ${level}=WARN
    ${expected} =  Create Dictionary  availabilityStatus=Offline|Failed  operationalState=Disabled
    _Infomodel Cell Should Be  ${cell.dist_name}  ${expected}  ${level}

Infomodel Cell Should Be Degraded
    [Tags]  Assert
    [Documentation]
    ...  Verifies that status of given cell is degraded.
    ...
    ...  In case of failure logs message with specified level. Default WARN.
    ...
    ...  *AUTHOR*
    ...  milosz.nowak@nokia.com
    ...
    ...  |  Parameters  | Man. |  Description           |
    ...  |  cell        | Yes  |  cell InfomodelObject  |
    ...  |  level       | No   |  failure log level     |
    ...
    ...  *EXAMPLE*
    ...  | ${cell} =  |  Query Infomodel  |  get object //CELL_M-1  |
    ...  | Infomodel Cell Should Be Degraded  |  ${cell}            |
    [Arguments]  ${cell}  ${level}=WARN
    ${state} =  Create Dictionary  availabilityStatus=Degraded  operationalState=${_Enabled}
    _Infomodel Cell Should Be  ${cell.dist_name}  ${state}  ${level}

Infomodel Cell Should Be Online
    [Tags]  Assert
    [Documentation]
    ...  Verifies that status of given cell is online.
    ...
    ...  In case of failure logs message with specified level. Default WARN.
    ...
    ...  *AUTHOR*
    ...  milosz.nowak@nokia.com
    ...
    ...  |  Parameters  | Man. |  Description           |
    ...  |  cell        | Yes  |  cell InfomodelObject  |
    ...  |  level       | No   |  failure log level     |
    ...
    ...  *EXAMPLE*
    ...  | ${cell} =  |  Query Infomodel  |  get object //CELL_M-1  |
    ...  | Infomodel Cell Should Be Online  |  ${cell}              |
    [Arguments]  ${cell}  ${level}=WARN
    ${state} =  Create Dictionary     operationalState=${_Enabled}
    _Infomodel Cell Should Be  ${cell.dist_name}  ${state}  ${level}

Infomodel Cell Should Be Failed
    [Tags]  Assert
    [Documentation]
    ...  Verifies that status of given cell is failed.
    ...
    ...  In case of failure logs message with specified level. Default WARN.
    ...
    ...  *AUTHOR*
    ...  milosz.nowak@nokia.com
    ...
    ...  |  Parameters  | Man. |  Description           |
    ...  |  cell        | Yes  |  cell InfomodelObject  |
    ...  |  level       | No   |  failure log level     |
    ...
    ...  *EXAMPLE*
    ...  | ${cell} =  |  Query Infomodel    |  get object //CELL_M-1  |
    ...  | Infomodel Cell Should Be Failed  |  ${cell}                |
    [Arguments]  ${cell}  ${level}=WARN
    ${state} =  Create Dictionary  availabilityStatus=Failed  operationalState=Disabled
    _Infomodel Cell Should Be  ${cell.dist_name}  ${state}  ${level}

_Infomodel Cell Should Be
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${cell_dn}: <description>
    ...        ${expected}: <description>
    ...        ${level}: <description>
    [Arguments]  ${cell_dn}  ${expected}  ${level}
    ${cell} =  Query Infomodel  get object ${cell_dn}
    ${current} =    Create Dictionary  availabilityStatus=${cell.stateInfo.availabilityStatus}
                                  ...  operationalState=${cell.stateInfo.operationalState}
    ${availability_status}=  Run keyword and return status
    ...  Should match regexp  ${current['availabilityStatus']}  ^${expected['availabilityStatus']}$
    ${operational_state}=  Run keyword and return status
    ...  Should match regexp  ${current['operationalState']}  ^${expected['operationalState']}$
    ${as_expected} =  Evaluate  ${availability_status} and ${operational_state}
    ${err_msg} =  Set Variable  Cell Status Wrong. ${cell.dist_name}. Current: ${current}
    Run Keyword If  ${as_expected}
    ...  Log  [${SPACE * 2}OK${SPACE * 2}] Cell Status Correct. ${cell.dist_name}. Current: ${current}  console=yes
    ...  ELSE  _Set Verdict Based On Log Level  ${level}  ${err_msg}

_Set Verdict Based On Log Level
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${level}: <description>
    ...        ${msg}: <description>
    [Arguments]  ${level}  ${msg}
    Run Keyword If  '${level}'=='WARN'  Set Test Restriction  ${msg}
         ...   ELSE IF  '${level}'=='ERROR'  Set Test Failed  ${msg}
         ...   ELSE  Log  ${msg}  console=yes

Infomodel Get Scf Cells Deployed On RMOD
    [Documentation]
    ...  Takes RMOD distName and returns list of scf cells objects
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    ...
    ...  | Parameters       | Man. | Description   |
    ...  | rmod_dn          | Yes  | RMOD distName |
    ...
    ...  *RETURN*
    ...  | Parameters  | Description                                |
    ...  | cells       | List of all cells objects deployed on RMOD |
    ...
    ...  *EXAMPLE*
    ...  | ${cells}= | Infomodel Get Scf Cells Deployed On RMOD | ${rmod_dn} |
    [Arguments]  ${rmod_dn}
    ${lte_cells}=  Query Infomodel
    ...  get list /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-1/SCF-1//CELLMAPPING_A-1/LCELL_A-*  allow_negative_result=${TRUE}
    ${wcdma_cells}=  Query Infomodel
    ...  get list /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-1/SCF-1//CELLMAPPING_A-1/LCELW_A-*  allow_negative_result=${TRUE}
    ${gsm_cells}=  Query Infomodel
    ...  get list /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-1/SCF-1//CELLMAPPING_A-1/LCELC_A-*  allow_negative_result=${TRUE}
    ${cells}=  Combine Lists  ${lte_cells}  ${wcdma_cells}  ${gsm_cells}
    [Return]  ${cells}

Infomodel Get All WCELL IDs
    [Tags]  Helper
    [Documentation]
    ...  Returns sorted list of WCELL IDs fetched from IM objects names
    ...  /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/WNBTS_M-*/CELL_M-*
    ...  /WNCEL_M-*.
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com
    ...
    ...  *RETURN*
    ...  |  Parameters |  Description           |
    ...  |  wcell_ids  |  List of WCELL IDs     |
    ...
    ...  *EXAMPLE*
    ...  | ${wcell_ids} =  | Infomodel Get All WCELL IDs  |

    ${wcell_ids}=  Create list  @{EMPTY}
    ${cells_dn}=   Infomodel Get Objects Parameter  ${dist_WCDMA_cell}/WNCEL_M-*  dist_name
    FOR  ${cell_dn}  IN  @{cells_dn}
        ${wcell_id}=  Fetch from right  ${cell_dn}  -
        Append to list  ${wcell_ids}  ${wcell_id}
    END
    Sort list  ${wcell_ids}
    [Return]  ${wcell_ids}

Infomodel Get bcfId
    [Tags]  Helper
    [Documentation]
    ...  Returns bcfId value
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    ...
    ...  *RETURN*
    ...  |  Parameters  |  Description  |
    ...  |  bcf         |  bcfID        |
    ...
    ...  *EXAMPLE*
    ...  | ${bcfid} =  | Infomodel Get bcfId  |
    ${bcf}=  Query infomodel  get object //GTS-*/BCF_L-*
    [Return]  ${bcf.bcfId}

Infomodel Get Cells Deployed On FSP
    [Documentation]
    ...  Takes infomodel object representing FSP(BBU object) and returns list of cells
    ...  (infomodel objects)deployed on it.
    ...
    ...  *AUTHOR*
    ...  michal.grabas@nokia.com
    ...
    ...  | Parameters       | Man. | Description          |
    ...  | FSP              | Yes  | BBU infomodel object |
    ...
    ...  *RETURN*
    ...  | Parameters  | Description                                     |
    ...  | cells       | List of cells infomodel objects deployed on FSP |
    ...
    ...  *EXAMPLE*
    ...  | ${cells}=    | Infomodel Get Cells Deployed On FSP | ${bbu_obj} |

    [Arguments]  ${bbu}
    ${routing_tables} =  _Get FSP Routing Tables  ${bbu.dist_name}
    ${routing_entities} =  _Get Entities From Routing Tables  ${routing_tables}
    ${channel_distnames} =  _Get Channel Distnames From Routing Entities  ${routing_entities}
    ${cells} =  _Get Cells From Channel  ${channel_distnames}
    [Return]  ${cells}

_Get FSP Routing Tables
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${bbu_node}: <description>
    ...
    ...    Returns:
    ...        ${routing_tables}: <description>
    [Arguments]  ${bbu_node}
    ${query} =  Set Variable  get list ${bbu_node}//ROUTINGTABLE_L-*
    ${routing_tables} =  Query Infomodel  ${query}  allow_negative_result=True
    [Return]  ${routing_tables}

_Get Entities From Routing Tables
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${tables}: <description>
    ...
    ...    Returns:
    ...        ${entities}: <description>
    [Arguments]  ${tables}
    ${entities} =  Create List  @{EMPTY}
    FOR  ${table}  IN  @{tables}
        ${dn} =  Set Variable  ${table['dist_name']}
        ${query} =  Set Variable  get list ${dn}/ROUTINGENTITY_L-*
        ${table_entities} =  Query Infomodel  ${query}  allow_negative_result=True
        ${entities} =  Combine Lists  ${entities}  ${table_entities}
    END
    [Return]  ${entities}

_Get Channel Distnames From Routing Entities
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${entities}: <description>
    ...
    ...    Returns:
    ...        ${channel_distnames}: <description>
    [Arguments]  ${entities}
    ${channel_distnames} =  Create List  @{EMPTY}
    FOR  ${entity}  IN  @{entities}
        Append To List  ${channel_distnames}  ${entity['channelDN']}
    END
    [Return]  ${channel_distnames}

_Get Cells From Channel
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${channels}: <description>
    ...
    ...    Returns:
    ...        ${cells}: <description>
    [Arguments]  ${channels}
    @{cells} =  Create List  @{EMPTY}
    FOR  ${channel}  IN  @{channels}
        @{nodes} =  Split String  ${channel}  separator=/
        ${bts_id} =  Get From List  ${nodes}  -4
        ${cell_id} =  Get From List  ${nodes}  -3
        ${is_cell} =  Run Keyword And Return Status  Should Contain  ${cell_id}  CELL
        ${cell} =  Run Keyword If  ${is_cell}
        ...  Get Infomodel Object  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/${bts_id}/${cell_id}
        Run Keyword If  ${is_cell}  Append To List  ${cells}  ${cell}
    END
    ${cells} =  Remove Duplicates  ${cells}
    [Return]  ${cells}

Infomodel Check Objects Parameter Value
    [Documentation]
    ...  Takes list of infomodel objects and check if parameter has expected value.
    ...
    ...  *AUTHOR*
    ...  michal.grabas@nokia.com
    ...
    ...  | Parameters       | Man. | Description                       |
    ...  | objects_list     | Yes  | List of Infomodel Objects         |
    ...  | state_check      | Yes  | Parameter and it's expected value |
    ...  | loglevel         | No   | Log level                         |
    ...
    ...  *RETURN VALUE*:
    ...   Return True if state of all given objects parameters are correct.
    ...
    ...  *EXAMPLE*
    ...  | ${cells_check} =  | Infomodel Check Objects Parameter Value | ${cells} | routingState=Routable |

    [Arguments]  ${objects_list}  ${state_check}  ${loglevel}=WARN
    ${result} =  Set Variable  ${TRUE}
    FOR  ${obj}  IN  @{objects_list}
        ${check_status} =  Query Infomodel  check ${obj} is [${state_check}]  allow_negative_result=True
        Run keyword if    not ${check_status}
        ...  Log  Parameter check (${state_check}) failed under object ${obj}  level=${loglevel}  console=true
        ${result} =  Evaluate  ${result} and ${check_status}
    END
    [Return]  ${result}

Check if cells are on air according to InfoModel
    [Documentation]
    ...  Wrapper for 'Infomodel Check If All Objects From Path Are Online' which logs the table and has fixed
    ...  cell states.
    ...  KW for checking if all cells from IM distPath administrativeState == Unlocked, blockingState == Unblocked,
    ...  operationalState == Enabled and proceduralState == OnAirDone.
    ...
    ...  | Parameters       | Man. | Description                  |
    ...  | cells_dist_path  | Yes  | IM cells dist path           |
    ...  | timeout          | Yes  | timeout for querying the IM  |
    ...
    ...  *RETURN*
    ...
    ...  | Parameters  | Description                                       |
    ...  | are_onair   | True if all cells are on air. False in other case |
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com

    [Arguments]  ${cells_dist_path}  ${timeout}
    Log  Check if cells are on air according to InfoModel  console=True
    ${are_onair}  ${status_table}=  Infomodel Check If All Objects From Path Are Online
    ...  ${cells_dist_path}  ${timeout}  ${False}
    ...  administrativeState=${_Unlocked}  blockingState=Unblocked  operationalState=${_Enabled}
    ...  proceduralState=OnAirDone
    Log    Nothing    #Log table  ${status_table}
    [Return]   ${are_onair}

Infomodel get active alarms table
    [Documentation]
    ...  Wrapper for 'Infomodel Get All Active Alarms Narrow List' which will output table of narrow alarms list from
    ...  InfoModel
    ...
    ...  *RETURN*
    ...
    ...  | Parameters    | Description                                                                               |
    ...  | alarms_table  | Table of alarms with columns named 'faultId', 'alarmNumber', 'alarmDetail' and alarmSeverit|
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com

    [Arguments]  ${active_alarms}
    #${alarms_table}=   Create table  infomodel_get_active_alarms_table  faultId  alarmNumber
    #alarmDetail  alarmSeverity
	${alarms_table}=   Create List
    FOR  ${alarm}  IN  @{active_alarms}
        #${alarms_table}=  Add row from dict  ${alarms_table}  ${alarm}
		Append To List		${alarms_table}		${alarm}
    END
    [Return]  ${alarms_table}

Get SM variant
 	[Documentation]
    ...  Return list of System Module variants in use. First is master second (if exist) slave
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jacek.mnich@nokia.com
    ...  | **Released with version:** -
    ...
	${sm_variant}=  Create list
	${sm_variant_list}=  Get SM variant with full name
	FOR  ${sm}  IN  @{sm_variant_list}
	    ${match}  ${group}=  Should match regexp  ${sm}  (FSMF|FSIH|ASIA|ASIB|ASIAB|ASIL|ASIM|ASIK|ASOE|ASOF)
	    Append To List  ${sm_variant}  ${match}
	END
	[Return]  ${sm_variant}

Get SM variant with full name
 	[Documentation]
    ...  Return list of System Module variants in use with full name. First is master second (if exist) slave
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** -
    ...
	${sm_variant}=  Create list
	${status}  ${sm_primary}=  Run keyword and ignore error
	...  Query Infomodel  get object //EQM_R-*//SMOD_R-* is [activeRole=empty]
    Run keyword if  '${status}'=='PASS'  Run keywords
    ...  Append To List  ${sm_variant}  ${sm_primary}[productName]
    ...  AND             Return from keyword  ${sm_variant}

 	${sm_primary}=      Query Infomodel  get object //EQM_R-*//SMOD_R-* is [activeRole=Primary]
    ${sm_secondary}=    Query Infomodel  get object //EQM_R-*//SMOD_R-* is [activeRole=Secondary]
 	Append To List  ${sm_variant}  ${sm_primary}[productName]  ${sm_secondary}[productName]
 	Log  SM variant: ${sm_variant}  console=${True}
	[Return]  ${sm_variant}

Log all Tx Power
  [Documentation]
  ...  Log TX Power for all radio modules
  ...
  ...  *Author*: Jaroslaw Piszczala
  [Arguments]  ${print_to_report}=${True}
    ${radio_distname_list}=  Query Infomodel  get list //RUNTIME_VIEW-*//RMOD_R-*
    FOR  ${radio_distname}  IN  @{radio_distname_list}
        ${ref_radio_object}=  Query Infomodel  get object ${radio_distname.dist_name}/REF-*
        ${im_radio_object}=    Query Infomodel  get object ${ref_radio_object.distName}
        Log  ${\n}TX-Power for ${im_radio_object.serialNumber}  console=${True}
        ${im_module_object}=  Query Infomodel  get object ${im_radio_object.masterAgentDN}
        ${tx_power_dict}=
        ...  Get Tx Power  ${im_radio_object.ipAddress}  ${im_module_object.ipAddress}  ${im_radio_object.productName}
        ...  print_to_report=${print_to_report}
    END

Get Radio Modules Serial Numbers
 	[Documentation]
 	...  Return a dictionary with 'dist_name':'serial_number' pairs for a given list of radio modules dist_names.
    ...
    ...  | Parameters      | Man. | Description                 |
    ...  | rmods_distnames | Yes  | Radio modules distnames list |
    ...
    ...  *RETURN*
    ...
    ...  | Parameters           | Description                                       |
    ...  | rmods_serial_numbers | Dictionary with serial_number=dist_name structure |
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    [Arguments]  ${rmods_distnames}
    ${rmods_serial_numbers}=  Create Dictionary
    FOR  ${rmod_single_distname}  IN  @{rmods_distnames}
        ${rmod_obj}=  Query Infomodel  get object ${rmod_single_distname}
        Set To Dictionary  ${rmods_serial_numbers}  ${rmod_single_distname}=${rmod_obj['serialNumber']}
    END
    [Return]  ${rmods_serial_numbers}

Infomodel check if cells in RAT were operational according to IM log
    [Documentation]
    ...  Helper KW for checking if cells of given RAT remain operational according to IM log
    ...  AvailabilityStatus and operationalState from objects //CELL_M-* are checked.
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com

    [Arguments]  ${rat}  ${im_log_path}
    ${cells_objects}=  Query infomodel  get list ${dist_${rat}_cell}  allow_negative_result=True
    Log  Check ${rat} cells  console=True
    FOR  ${cell_object}  IN  @{cells_objects}
        Initialize ims2 validator  ${im_log_path}
        Add expected ims2 event  change ${cell_object.dist_name} [stateInfo.availabilityStatus]
        Add expected ims2 event  change ${cell_object.dist_name} [stateInfo.operationalState]
        Run keyword and expect error  InfoModelIms2ValidationException:*  Validate ims2
        Log  ${cell_object.dist_name} availabilityStatus and operationalState remained unchanged  console=True
    END
    Log  All ${rat} cells were operational according to IM log  console=True

Infomodel get all DSPs dist names for given RAT
    [Documentation]
    ...  KW for obtaining sorted list of DSPs distNames from IM
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com

    [Arguments]  ${rat}
    ${dsps_dist_names}=  Create list
    ${sw_entities_objects}=  Query Infomodel  get list //DSP_L-*/SOFTWARE_ENTITY-* is [rat="${rat}"]
    FOR  ${sw_entity}  IN  @{sw_entities_objects}
        Append to list  ${dsps_dist_names}  ${sw_entity['deviceDN']}
    END
    Sort list  ${dsps_dist_names}
    [Return]  ${dsps_dist_names}

Infomodel check if DSPs were restarted according to ims file
    [Documentation]
    ...  KW checks given ims2 file (first argument) looking for DSPs restart event. All DSPs from given list (second
    ...  argument) are checked. User can use 'Save Infomodel Log' KW to obtain ims2 file and 'Infomodel get all DSPs
    ...  dist names for given RAT'
    ...  to get DSPs list
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com
    ...
    ...  | Parameter      | Man. | Description                             |
    ...  | im_log_path    | Yes  | Path for Infomodel ims2 file            |
    ...  | dsp_dist_names | Yes  | List of DSPs dist names fetched from IM |

    [Arguments]  ${im_log_path}  ${dsp_dist_names}
    FOR  ${dsp_dist_name}  IN  @{dsp_dist_names}
        Initialize ims2 validator  ${im_log_path}
        Add expected ims2 event  change ${dsp_dist_name} [stateInfo.proceduralState: RoutingLoaded -> Resetting]
        Validate ims2
        Log  ${dsp_dist_name} was restarted  console=True
    END

Infomodel Get Shared RM IpAddress list
    [Documentation]
    ...  Keyword providing Shared RM IpAddress information from IM.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                     |
    ...  | alias     | No   | alias of ute_infomodel instance |
    ...
    ...  *RETURN*
    ...  | Parameter           | Description                      |
    ...  | Shared_RM_IpAddress | List of all shared RM IP address |
    ...
    [Arguments]  ${alias}=default
    ${Shared_RM_IpAddress}=  Create list  @{EMPTY}
    @{RM_list}=  Query infomodel  alias=${alias}  query=get list //EQM_L-1/RMOD_L-*  timeout=90
    FOR  ${item}  IN  @{RM_list}
        Run Keyword If
        ...  '${item.stateInfo.workingState}' == 'sharedMaster'
        ...  Append To List  ${Shared_RM_IpAddress}  ${item.ipAddress}
    END
    Sort List  ${Shared_RM_IpAddress}
    [Return]  ${Shared_RM_IpAddress}

Infomodel Check Presence Of IoT Cells
    [Documentation]
    ...  Keyword which interogates Infomodel and checks if IoT cells are present in the configuration
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter | Man. | Description                     |
    ...  | alias     | No   | alias of ute_infomodel instance |
    ...
    ...  *RETURN*
    ...  | Parameter           | Description                |
    ...  | True/False | True if at least one IoT Cell found |
    ...
    [Arguments]  ${alias}=default
    ${IoT_Cells_present}=  Set Variable  False
    ${lncel_objects}=  Query Infomodel  alias=${alias}
    ...  query=get list /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-1/SCF-1//LNBTS_A-*/LNCEL_A-*
    ${first_obj} =	Get From List  ${lncel_objects}  0
    ${param_cellTechnologyFound}=  Run Keyword And Return Status  Variable Should Exist  ${first_obj.cellTechnology}
    ${param_technologyFound}=  Run Keyword if
    ...  not ${param_cellTechnologyFound}  Variable Should Exist  ${first_obj.technology}
    ${param_name}=  Set Variable If  ${param_cellTechnologyFound}  cellTechnology  technology
    Log  Check if IoT Cells present using Infomodel query  console=True
    FOR  ${object}  IN  @{lncel_objects}
        Log  ${object.${param_name}} Cell detected  level=DEBUG
        ${IoT_Cells_present}=  Set Variable If  '${object.${param_name}}' == 'NB-IoT-FDD'  True  ${IoT_Cells_present}
    END
    [Return]  ${IoT_Cells_present}

Infomodel Check IM log if BTS reset was triggered
    [Documentation]
    ...  KW for checking IM log for reset event occurence. It saves IM log for further processing under given path and
    ...  then validates it in context of reset. Returns true or false.
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com
    ...
    ...  | Parameter        | Man. | Description                                    |
    ...  | path_for_im_log  | Yes  | Absolute path under which IM log will be saved |
    ...
    ...  *RETURN*
    ...  | ${was_reset_present} | Infomodel Check IM log if BTS reset was triggered
    ...  | ${BTS Files}/IM/InfoModel_log_for_reset_check.ims2 |

    [Arguments]  ${path_for_im_log}
    Save infomodel log  ${path_for_im_log}  timeout=120
    Initialize ims2 validator  ${path_for_im_log}
    Add expected ims2 event  reset
    ${was_triggered}=  Run keyword and return status  Validate ims2
    [Return]  ${was_triggered}

Infomodel Check SBTS cells, modules and alarms
    [Documentation]
    ...  KW for wrapping functions for checking SBTS SMODs, RMODs, cell states and presence of active alarms.
    ...  As an arguments you can pass
    ...  IM dist path for each of checked component (SMODs, RMODs, cells) under which states can be found
    ...  (default paths are also present).
    ...  For SMODs and RMODs KW is checking states    operationalState=${_Enabled}. For cells KW is checking
    ...  administrativeState=${_Unlocked}  blockingState=Unblocked  operationalState=${_Enabled}
    ...  proceduralState=OnAirDone   .
    ...  For alarms KW will fail if any critical is present. In default all tables with statuses will be printed.
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com
    ...
    ...  | Parameter           | Man. | Description                            |
    ...  | smods_im_path       | No   | SMODs IM dist path                     |
    ...  | rmods_im_path       | No   | RMODs IM dist path                     |
    ...  | cells_im_path       | No   | Cells IM dist path                     |
    ...  | should_print_tables | No   | Should tables with statuses be printed |

    [Arguments]  ${smods_im_path}=//SMOD_L-*  ${rmods_im_path}=//EQM_L-1//RMOD_L-*/RU_L-*
    ...  ${cells_im_path}=/MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1//CELL_M-*  ${should_print_tables}=${TRUE}
    ${are_smods_online}  ${smods_statuses}=  Infomodel Check If All Objects From Path Are Online
    ...  ${smods_im_path}  10 sec  ${should_print_tables}
    ${are_rmods_online}  ${rmods_statuses}=  Infomodel Check If All Objects From Path Are Online
    ...  ${rmods_im_path}  10 sec  ${should_print_tables}
    ${are_cells_online}  ${cells_statuses}=  Infomodel Check If All Objects From Path Are Online
    ...  ${cells_im_path}  10 sec  ${should_print_tables}  administrativeState=${_Unlocked}  blockingState=Unblocked
    ...  operationalState=${_Enabled}  proceduralState=OnAirDone
    ${no_critical_alarms}=  Run keyword and return status  Admin Check Active Alarms
    Should be true  ${are_smods_online} and ${are_rmods_online} and ${are_cells_online} and ${no_critical_alarms}
    ...  Not all conditions were satisfied!

Infomodel Get LTE RM sharing info
    [Documentation]
    ...  Keyword providing LTE RM sharing info dictionary from IM.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                     |
    ...  | alias     | No   | alias of ute_infomodel instance |
    ...
    ...  *RETURN*
    ...  | Parameter         | Description                                                         |
    ...  | RM_sharing_info   | Dictionary of RM sharing info: key=serialNumber, value=workingState |
    ...
    [Arguments]  ${alias}=default
    ${RM_sharing_info_dict}=  Create Dictionary
    @{RM_list}=  Query infomodel  alias=${alias}  query=get list //EQM_L-1/RMOD_L-*  timeout=90
    FOR  ${item}  IN  @{RM_list}
        Set To Dictionary  ${RM_sharing_info_dict}  ${item.serialNumber}  ${item.stateInfo.workingState}
    END
    [Return]  ${RM_sharing_info_dict}

Check SW version
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${step_number}: <description>
    ...        ${Pass If SW exists}: <description>
    ...        ${module}: <description>
    ...        ${im_param_active}: <description>
    ...        ${im_param_passive}: <description>
    ...        ${alias}: <description>
    [Arguments]    ${step_number}  ${Pass If SW exists}=${False}  ${module}=MSM
    ...            ${im_param_active}=activeBuildDescriptorId  ${im_param_passive}=passiveBuildDescriptorId
    ...  ${alias}=default
    ${Active SW}   Infomodel Get Active SW Version    module=${module}  im_param=${im_param_active}  alias=${alias}
    ${Passive SW}  Infomodel Get Passive SW Version    module=${module}  im_param=${im_param_passive}  alias=${alias}
    Log  Active software package is: ${Active SW}  console=True
    Log  Passive software package is: ${Passive SW}  console=True
    ${SW Release Name}  Get TargetBD Node Attribute Value  softwareReleaseVersion  ${Target SW path}
    Run Keyword If  '${Passive SW}'==''  Set Test Restriction  Passive sw version was not readable
    Run Keyword If  '${step_number}'=='2'  Run keywords
    ...  Set tags  SW_BEFORE_UPDATE_active-${Active SW}  SW_BEFORE_UPDATE_passive-${Passive SW}
    ...  AND  set test variable  ${SW_BEFORE_UPDATE_active}  ${Active SW}
    ...  AND  hran_general.Check if SW already exists on BTS  ${SW Release Name}  ${Active SW}
    ...  ${Passive SW}  ${Pass If SW exists}
    Run Keyword If  '${step_number}'!='2'  Run keywords
    ...  Set tags  SW_AFTER_UPDATE_active-${Active SW}
    ...  AND  Set tags  SW_AFTER_UPDATE_passive-${Passive SW}
    ...  AND  Set test variable  ${TARGET_SW}  ${Active SW}
    ...  AND  Should Match Regexp  ${SW Release Name}  (?i).*${Active SW}(?!T[12]).*
    Run keyword if  '${Active SW}'=='?'  Set Test Failed  Active sw version fetched from infomodel equals "?"

Check System Modules Configuration In InfoModel
    [Documentation]
    ...  This KW returns what kind of configuration of system modules (4, 3, 3+3, 4+4 or 4+3) is currently in use.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block: robotframework
    ...     ${configuration} =  Check System Modules Configuration In InfoModel

    ${smod_objects} =  Query Infomodel  get list //SMOD_BP_L-*
    FOR  ${index}  ${smod_object}  IN ENUMERATE  @{smod_objects}
      ${hw_release} =  Set Variable If  ${index} == 0  ${smod_object['hwRelease']}
      ...                                              ${hw_release}+${smod_object['hwRelease']}
    END
    [Return]  ${hw_release}

Fail if ims2 object change
    [Documentation]
    ...  Validate if object parameter in IMS2 was not changed
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** 61.0
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+---------------------------+
    ...  | Parameter name   | Man. | Description               |
    ...  +==================+======+===========================+
    ...  | object           | yes  | object distname           |
    ...  +------------------+------+---------------------------+
    ...  | parameter        | yes  | object parameter          |
    ...  +------------------+------+---------------------------+
    ...  | value            | yes  | parameter value           |
    ...  +------------------+------+---------------------------+
    ...  | alias            | no   | ute_admin_infomodel alias |
    ...  +------------------+------+---------------------------+
    ...
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Initialize ims2 validator   ${BTS Files}/IM/${alias}.ims2  alias=${alias}
    ...     Fail if ims2 object change  ${SMOD_DISTNAME}  administrativeState   Unlocked  ${alias}
    ...
    [Arguments]  ${object}  ${parameter}  ${value}  ${alias}=DSC
    Add expected ims2 event     change ${object} [stateInfo.${parameter}: ${value}->!${value}]  alias=${alias}
    ${status}  Run keyword and return status  Validate ims2  alias=${alias}
    Run keyword if  ${status}  Set test failed  DSC: ${object} state was changed (${parameter}!=${value})

Infomodel Get LTE txPathFailureMode
    [Documentation]
    ...  Keyword providing LTE txPathFailureMode value from IM.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                     |
    ...  | alias     | No   | alias of ute_infomodel instance |
    ...
    ...  *RETURN*
    ...  | Parameter         | Description                                                         |
    ...  | txPathFailureMode | parameter value |
    ...
    [Arguments]  ${alias}=default
    ${LNBTS_A_object_found}=  Query Infomodel  query=get list //LNBTS_A-*  alias=${alias}
    Set Test Variable  ${txPathFailureMode}  ${LNBTS_A_object_found[0].txPathFailureMode}

Infomodel Get NR CELL Ids
    [Documentation]
    ...  Keyword providing NR Cell Ids from IM.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                           |
    ...  | alias     | No   | alias of ute_admin_infomodel instance |
    ...
    ...  *RETURN*
    ...  | Parameter   | Description      |
    ...  | NR_CELL_Ids | NR Cell Ids list |
    ...
    [Arguments]  ${alias}=default
    ${NRCELl_R_info}=  Query Infomodel  query=get list //NRCELL_R-*  alias=${alias}
    ${NR_CELL_IDS_LIST}=  Create List
    ${IOT_NR_CELL_IDS_LIST}=  Create List
    FOR  ${item}  IN  @{NRCELl_R_info}
        Append To List  ${NR_CELL_IDS_LIST}  ${item['dist_name']}
    END
    [Return]  ${NR_CELL_IDS_LIST}  ${IOT_NR_CELL_IDS_LIST}

Infomodel Get NR CELL state info
    [Documentation]
    ...  Helper keyword providing NR cells states info.
    ...  KW is returning a list of lists with CELL states info as below:
    ...  - name, distName, operationalState, administrativeState, availabilityStatus, blockingState, proceduralState.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                           |
    ...  | alias                | No    | default | alias of ute_admin_infomodel instance |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description                    |
    ...  | NR_CELL_STATE_LIST  | List of lists with CELL states |

    [Arguments]  ${alias}=default
    ${NR_CELL_ID_LIST}  ${EMPTY}=  Infomodel Get NR CELL Ids  alias=${alias}
    ${NR_CELL_STATE_LIST}=  Create List
    FOR  ${item}  IN  @{NR_CELL_ID_LIST}
        ${CELL_PARAM_LIST}=  Query Infomodel  query=get object ${item}  alias=${alias}
        ${CELL_label}=  Fetch From Right  ${CELL_PARAM_LIST['dist_name']}  /
        @{temp}=  Create List
        ...  ${CELL_label}
        ...  ${CELL_PARAM_LIST['dist_name']}
        ...  ${CELL_PARAM_LIST['operationalState']}
        ...  ${CELL_PARAM_LIST['stateInfo']['administrativeState']}
        ...  ${CELL_PARAM_LIST['stateInfo']['availabilityStatus']}
        ...  ${CELL_PARAM_LIST['stateInfo']['blockingState']}
        ...  ${CELL_PARAM_LIST['proceduralStatus']}
        ...  ${CELL_PARAM_LIST['stateInfo']['usageState']}
        Append To List  ${NR_CELL_STATE_LIST}  ${temp}
    END
    Sort List  ${NR_CELL_STATE_LIST}
    [Return]  ${NR_CELL_STATE_LIST}

Fail if ims2 event occur
    [Documentation]
    ...  Validate and fail if event occured
    ...
    ...  | **Author:** sebastian.burniak@nokia.com
    ...  | **Maintainer:** sebastian.burniak@nokia.com
    ...  | **Released with version:** 73.0
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+----------------------------+
    ...  | Parameter name   | Man. | Description                |
    ...  +==================+======+============================+
    ...  | event            | yes  | ims2 event to be validated |
    ...  +------------------+------+----------------------------+
    ...  | alias            | no   | ute_admin_infomodel alias  |
    ...  +------------------+------+----------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Initialize ims2 validator    ${BTS Files}/IM/InfoModel_log.ims2  alias=${alias}
    ...     Fail if ims2 occur  ${alias}
    ...
    [Arguments]  ${event}  ${alias}=DSC
    Add expected ims2 event  ${event}  alias=${alias}
    ${event_triggered}=  Run keyword and return status  Validate ims2  alias=${alias}
    Run keyword if  ${event_triggered}   Set test failed  DSC: ${event} event has been found
