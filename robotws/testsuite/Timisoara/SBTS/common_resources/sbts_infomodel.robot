*** Settings ***
Documentation  This suite contains KWs used by some TCs and resources.


*** Variables ***
${DIST_RADIO}  //EQM_L-1//RMOD_L-*
${DIST_WCDMA_CELL}  /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/WNBTS_M-*/CELL_M-*
${DIST_GSM_CELL}  /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/GNBTS_M-*/CELL_M-*
${DIST_NR_CELL}  /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/NRBTS_M-*/CELL_M-*
${DIST_CELLS}  /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1//CELL_M-*
${DIST_LTE_CELL}  /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/LNBTS_M-*/CELL_M-*


*** Keywords ***
Infomodel Get Object Connection Status
    [Documentation]
    ...  It returns value of connectionList.connectionStatus from given object.
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
    ...  | ${example1} | Infomodel Get Object State | /MRBTS-1/EQM-1/SMOD-4113/IM_SYNC-1 |
    ...  =>
    ...
    ...  ${example1} 'Connected'
    [Arguments]  ${dist_name}

    ${connection_list}  Infomodel Get ConnectionList  ${dist_name}
    Run Keyword If  ${connection_list}==[]
    ...  Return From Keyword  Disconnected

    [Return]  ${connection_list[0]['connectionStatus']}


_Get SW Version For SMOD
    [Documentation]  This keyword is used to get SW Version For SMOD
    [Arguments]  ${module}=MSM  ${im_param}=activeSoftwareVersion  ${alias}=default

    ${working_modes}  Create Dictionary  MSM=Active  ESM=Idle  all=Active
    ${mode}  Get From Dictionary  ${working_modes}  ${module}
    ${swm_objects}  coam.Get Managed Objects  SWM  connection=${alias}
    ${swm_objs}  Create List
    FOR  ${swm}  IN  @{swm_objects}
       IF    '${swm}[parameters][workingMode]'=='${mode}'
           Append To List  ${swm_objs}  ${swm}
           BREAK
       ELSE
           CONTINUE
       END
    END
    IF  not ${swm_objs}  RETURN  ${EMPTY}
    ${sw_versions}  Create List
    FOR  ${swm_obj}  IN  @{swm_objs}
        ${bts_l_dn}  Set Variable  ${swm_obj}[parameters][hardwareViewDNs][0]
        ${bts_conf_obj}  coam.Get Managed Objects  BTS_CONF  connection=${alias}
        FOR  ${bts_obj}  IN  @{bts_conf_obj}
            IF  '${bts_obj}[distName]'=='${bts_l_dn}/BTS_CONF-1'
                ${sw_version}  Get From Dictionary  ${bts_obj}[parameters]  ${im_param}
                Append To List  ${sw_versions}  ${sw_version}
            END
        END
    END
    IF  '${module}'=='all'  RETURN  ${sw_versions}  # return the whole list

    RETURN  ${sw_versions}[0]


Infomodel Get Active SW Version
    [Documentation]
    ...  Return active software version for selected SMOD.
    ...
    ...  Mind that if there are two SMODs connected to a not commissioned BTS, KW will return:
    ...  - a list of SW versions for both SMODs if `module` is set to `MSM` or `all`
    ...  - an empty list if `module` is set to `ESM`
    ...  This results from both SMODs being marked in Infomodel as Active (i.e. master system module).
    ...
    ...  *PARAMETERS*
    ...   | =Parameter=       | =Man.= | =Description=                                                           | =Default=              |
    ...   | `module`          | no     | Determines from which SMOD the SW Version is obtained (MSM, ESM, all).  | MSM                    |
    ...   | 'im_param'        | no     | Determines which parameter should be taken to read active sw version    | activeSoftwareVersion  |
    ...   | `alias`           | no     | Determines alias in connection to infomodel                             | default                |
    ...
    ...  *RETURN VALUE*
    ...  - Active SW version
    [Arguments]  ${module}=MSM  ${im_param}=activeSoftwareVersion  ${alias}=default

    ${sw_version}  _Get SW Version For SMOD  module=${module}  im_param=${im_param}  alias=${alias}

    [Return]  ${sw_version}


Infomodel Get Passive SW Version
    [Documentation]
    ...  Return passive software version
    ...  For more details, see documentation for `Infomodel Get Active SW Version`.
    ...
    ...  *PARAMETERS*
    ...   | =Parameter=       | =Man.= | =Description=                                                            | =Default=               |
    ...   | `module`          | no     | Determines from which SMOD the SW Version is obtained (MSM, ESM, all).   | MSM                     |
    ...   | 'im_param'        | no     | Determines which parameter should be taken to read passive sw version    | passiveSoftwareVersion  |
    ...   | `alias`           | no     | Determines alias in connection to infomodel                              | default                 |
    ...
    ...  *RETURN VALUE*
    ...  - Passive SW version
    [Arguments]  ${module}=MSM  ${im_param}=passiveSoftwareVersion  ${alias}=default

    ${sw_version}  _Get SW Version For SMOD  module=${module}  im_param=${im_param}  alias=${alias}

    [Return]  ${sw_version}


Infomodel Get Planned SW Version
    [Documentation]
    ...  Return passive software version
    ...  For more details, see documentation for `Infomodel Get Active SW Version`.
    ...
    ...  *PARAMETERS*
    ...   | =Parameter=       | =Man.= | =Description=                                                           | =Default=               |
    ...   | `module`          | no     | Determines from which SMOD the SW Version is obtained (MSM, ESM, all).  | MSM                     |
    ...   | 'im_param'        | no     | Determines which parameter should be taken to read planned sw version   | passiveSoftwareVersion  |
    ...   | `alias`           | no     | Determines alias in connection to infomodel                             | default                 |
    ...
    ...  *RETURN VALUE*
    ...  - Active SW version
    [Arguments]  ${module}=MSM  ${im_param}=plannedSoftwareVersion  ${alias}=default

    ${sw_version}  _Get SW Version For SMOD  module=${module}  im_param=${im_param}  alias=${alias}

    [Return]  ${sw_version}


Infomodel Get SW Versions
    [Documentation]
    ...  *PARAMETERS*
    ...   | =Parameter=       | =Man.= | =Description=                                                                  | =Default= |
    ...   | `log_to_console`  | no     | Determines if log active and passive sw version to console is expected or not  | TRUE       |
    ...   | `module`          | no     | Determines from which SMOD the SW Version is obtained (MSM, ESM, all).         | MSM       |
    ...   | `alias`           | no     | Determines alias in connection to infomodel                                    | default   |
    ...  *RETURN VALUE*
    ...  :return:           list with active and passive SW
    [Arguments]  ${log_to_console}=${True}  ${module}=MSM  ${alias}=default

    ${active_software_version}  Infomodel Get Active SW Version  ${module}  alias=${alias}
    ${passive_software_version}  Infomodel Get Passive SW Version  ${module}  alias=${alias}
    Log  active SW: ${active_software_version}  console=${log_to_console}
    Log  passive SW: ${passive_software_version}  console=${log_to_console}

    [Return]  ${active_software_version}  ${passive_software_version}


Infomodel Check If All Objects From Path Are Online
    [Documentation]
    ...  Infomodel Check If All Objects From Path Are Online. Get status.
    [Arguments]  ${path}  @{parameters_list}

    IF  ${parameters_list}
        ${parameters_list_infomodel}  Set Variable  ${parameters_list}
    ELSE
        ${parameters_list_infomodel}  Create List  availabilityStatus=Online  operationalState=Enabled
    END
    ${parameter_obj}  Fetch From Right  ${path}  /
    ${parameter_obj}  Fetch From Left  ${parameter_obj}  -
    ${parameters_object}  coam.Get Managed Objects  ${parameter_obj}
    FOR  ${object}  IN  @{parameters_object}
       FOR  ${parameter}  IN  @{parameters_list_infomodel}
           ${parameter_name}  Fetch From Left  ${parameter}  =
           ${parameter_value}  Fetch From Right  ${parameter}  =
           ${check}   Run Keyword And Return Status  Should Contain  ${parameter_value}  regex
           IF  ${check}
               ${last_part}  Fetch From Right  ${parameter_value}  regex"
               ${last_part}  Fetch From Left  ${last_part}  "
               ${matches}   Split String  ${last_part}  |
               ${condition}  Catenate  SEPARATOR=${SPACE}and${SPACE}  '${object}[parameters][stateInfo][${parameter_name}]'!='${matches}[0]'
               ...  '${object}[parameters][stateInfo][${parameter_name}]'!='${matches}[1]'
               IF  ${condition}  RETURN  ${FALSE}
           ELSE IF  '${object}[parameters][stateInfo][${parameter_name}]'!='${parameter_value}'
               RETURN  ${FALSE}
           END
       END
    END

    RETURN  ${TRUE}


Infomodel Get ConnectionList
    [Documentation]
    ...  Return connectionList from given object
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
    ...  +--------------------+------------------------------------------------------------------------------------------+
    ...  | Parameter name     | Description                                                                              |
    ...  +====================+==========================================================================================+
    ...  | ${connectionList}  | Dictionary of all states at given connectionList                                         |
    ...  +--------------------+------------------------------------------------------------------------------------------+
    [Arguments]  ${dist_name}

    ${object}  Query Infomodel  get object ${dist_name}

    [Return]  ${object.connectionList}


Infomodel Get Objects Parameter
    [Documentation]
    ...  KW for obtaining list of values of one specified parameter for all InfoModel objects matching 'objects_dist_name'
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
    ...  | ${parameter_values} | Infomodel Get Objects Parameter | //EQM_L-1//SMOD_L-* | serialNumber
    [Arguments]  ${objects_dist_name}  ${parameter}  ${allow_negative_result}=False

    ${objects}  Query Infomodel  get list ${objects_dist_name}  allow_negative_result=${allow_negative_result}
    ${parameter_values}  Create List
    FOR  ${object}  IN  @{objects}
        Append To List  ${parameter_values}  ${object['${parameter}']}
    END

    [Return]  ${parameter_values}


Infomodel Avoid Objects Parameters With Specific State
    [Documentation]
    ...  *RETURN VALUE*:
    ...  Return list of parameters which don't have specific state
    ...  | Parameter     | Man. | Description                    |
    ...  | objects       | Yes  | Object distPath from InfoModel |
    ...  | param         | Yes  | parameter names                |
    ...  | state_name    | Yes  | state name                     |
    ...  | state_value   | Yes  | state value                    |
    [Arguments]  ${objects}  ${param}  ${state_name}  ${state_value}

    ${list_obj}  Query Infomodel  get list ${objects}
    ${list_parameters}  Create List
    FOR  ${var}  IN  @{list_obj}
        Run Keyword If  "${var['stateInfo']['${state_name}']}"!="${state_value}"
        ...  Append To List  ${list_parameters}  ${var['${param}']}
    END

    [Return]  ${list_parameters}


Infomodel Get All Radio Modules DistName
    [Documentation]
    ...  *RETURN VALUE*:
    ...  Return list contain all radio modules dist name.

    ${objects}  Infomodel Avoid Objects Parameters With Specific State  ${DIST_RADIO}  dist_name  proceduralState  fromSCF

    [Return]  ${objects}


Infomodel Get All Radio Modules Serial Numbers
    [Documentation]
    ...  *RETURN VALUE*:
    ...  List of BTS RMODs serial numbers

    ${rmods}  Infomodel Get Objects Parameter  ${DIST_RADIO}  serialNumber

    [Return]  ${rmods}


Infomodel Get RMOD By Serial Number
    [Documentation]
    ...  Returns RMOD InfomodelObject with specified serial number.
    ...
    ...  |  Parameters     | Man. |  Description         |
    ...  |  serial_number  | Yes  |  RMOD serial number  |
    ...
    ...  *RETURN*
    ...  |  Parameters  |  Description           |
    ...  |  rmod        |  RMOD InfomodelObject  |
    ...
    ...  *EXAMPLE*
    ...  | ${rmod}  | Infomodel Get RMOD By Serial Number  |  FGYU12345  |
    [Tags]  Helper
    [Arguments]  ${serial_number}

    ${rmod_r}  Get Infomodel Object  //RMOD_R-* is [serialNumber=${serial_number}]
    ${rmod_ref}  Query Infomodel  get object ${rmod_r.dist_name}/REF-*
    ${rmod}  Query Infomodel  get object ${rmod_ref.distName}

    [Return]  ${rmod}


Infomodel Get Cells Deployed On Bts
    [Documentation]
    ...  Returns list of cells' InfomodelObjects deployed on BTS.
    ...  *RETURN*
    ...  |  Parameters  |  Description               |
    ...  |  cells       |  List of InfomodelObjects  |
    ...
    ...  *EXAMPLE*
    ...  | ${cells}   |  Infomodel Get Cells Deployed On Bts  |
    [Tags]  Helper

    ${cells}  Query Infomodel  get list //CELL_M-*

    [Return]  ${cells}


Infomodel Get Cells Deployed On Module
    [Documentation]
    ...  Returns list of cells' InfomodelObjects deployed on specific module.
    ...
    ...  This keyword selects all cells which match the module's dist_name pattern in their devicesDNInPath.
    ...  |  Parameters  | Man. |  Description             |
    ...  |  module      | Yes  |  module infomodelObject  |
    ...
    ...  *RETURN*
    ...  |  Parameters  |  Description               |
    ...  |  cells       |  List of InfomodelObjects  |
    ...
    ...  *EXAMPLE*
    ...  |  ${rmod}            |  Infomodel Get RMOD By Serial Number     |  ABCD123456  |
    ...  |  ${cells_on_rmod}   |  Infomodel Get Cells Deployed On Module  |  ${rmod}  |
    ...  |  ${bbmod}           |  Query Infmodel  |  get object //BBMOD_L-1  |
    ...  |  ${cells_on_bbmod}  |  Infomodel Get Cells Deployed On Module  |  ${bbmod}  |
    [Tags]  Helper
    [Arguments]  ${module}

    ${cells_on_mod}  Create List  @{EMPTY}
    ${cells}  Query Infomodel  get list //CELL_M-*
    ${re}  Set Variable  regex"${module.dist_name}/.*"
    FOR  ${cell}  IN  @{cells}
        ${contains}  Query Infomodel  ${cell.dist_name}//PATH-* is [devicesDNInPath[?]=${re}]  allow_negative_result=True  timeout=0.1s
        ${contains}  Convert To Boolean  ${contains}
        Run Keyword If  ${contains}
        ...  Append To List  ${cells_on_mod}  ${cell}
    END

    [Return]  ${cells_on_mod}


Infomodel Get Cells Deployed On RMOD
    [Documentation]
    ...  Returns list of cells' InfomodelObjects deployed on specific RMOD.
    ...
    ...  This keyword selects all cells which have desired RMOD DN in their devicesDNInPath.
    ...  |  Parameters  | Man. |  Description           |
    ...  |  rmod        | Yes  |  RMOD InfomodelObject  |
    ...
    ...  *RETURN*
    ...  |  Parameters  |  Description               |
    ...  |  cells       |  List of InfomodelObjects  |
    ...
    ...  *EXAMPLE*
    ...  | ${rmod}   |  Infomodel Get RMOD By Serial Number   |  ABCD123456  |
    ...  | ${cells}  |  Infomodel Get Cells Deployed On RMOD  |  ${rmod}     |
    [Tags]  Helper
    [Arguments]  ${rmod}

    Run Keyword And Return
    ...  Infomodel Get Cells Deployed On Module  ${rmod}


Infomodel Cell Has At Least One Operational RXTX Pair
    [Documentation]
    ...  Returns True if cell has at least one pair of RX and TX with operationalState Enabled,
    ...  False otherwise.
    ...  |  Parameters  | Man. |  Description           |
    ...  |  cell        | Yes  |  cell InfomodelObject  |
    ...
    ...  *RETURN*
    ...  |  Parameters     |  Description                             |
    ...  |  has_rxtx_pair  |  True if cell has operational RXTX pair  |
    ...
    ...  *EXAMPLE*
    ...  | ${cell}            | Query Infomodel  get object //CELL_M-1 |
    ...  | ${has_rxtx_pair}   | Infomodel Cell Has At Least One Operational RXTX Pair  |  ${cell}
    [Tags]  Checker
    [Arguments]  ${cell}

    ${has_rx}  Set Variable  ${cell.dist_name}//CHANNEL_M-* is [stateInfo.operationalState=Enabled, direction=RX]
    ${has_tx}  Set Variable  ${cell.dist_name}//CHANNEL_M-* is [stateInfo.operationalState=Enabled, direction=TX]
    ${queries}  Create Dictionary  has_rx=${has_rx}  has_tx=${has_tx}
    ${status}  Run Keyword And Return Status
    ...  Query Infomodel Sequence  &{queries}
    ${has_rxtx_pair}  Convert To Boolean  ${status}

    [Return]  ${has_rxtx_pair}


Infomodel Cell Should Be Disabled
    [Documentation]
    ...  Verifies that status of given cell is disabled.
    ...
    ...  In case of failure logs message with specified level. Default WARN.
    ...  |  Parameters  | Man. |  Description           |
    ...  |  cell        | Yes  |  cell InfomodelObject  |
    ...  |  level       | No   |  failure log level     |
    ...
    ...  *EXAMPLE*
    ...  | ${cell}   |  Query Infomodel  |  get object //CELL_M-1  |
    ...  | Infomodel Cell Should Be Disabled  |  ${cell}            |
    [Tags]  Assert
    [Arguments]  ${cell}  ${level}=WARN

    ${expected}  Create Dictionary  availabilityStatus=Offline|Failed  operationalState=Disabled
    _Infomodel Cell Should Be  ${cell.dist_name}  ${expected}  ${level}


Infomodel Cell Should Be Degraded
    [Documentation]
    ...  Verifies that status of given cell is degraded.
    ...
    ...  In case of failure logs message with specified level. Default WARN.
    ...  |  Parameters  | Man. |  Description           |
    ...  |  cell        | Yes  |  cell InfomodelObject  |
    ...  |  level       | No   |  failure log level     |
    ...
    ...  *EXAMPLE*
    ...  | ${cell} =  |  Query Infomodel  |  get object //CELL_M-1  |
    ...  | Infomodel Cell Should Be Degraded  |  ${cell}            |
    [Tags]  Assert
    [Arguments]  ${cell}  ${level}=WARN

    ${state}  Create Dictionary  availabilityStatus=Degraded  operationalState=Enabled
    _Infomodel Cell Should Be  ${cell.dist_name}  ${state}  ${level}


Infomodel Cell Should Be Online
    [Documentation]
    ...  Verifies that status of given cell is online.
    ...
    ...  In case of failure logs message with specified level. Default WARN.
    ...  |  Parameters  | Man. |  Description           |
    ...  |  cell        | Yes  |  cell InfomodelObject  |
    ...  |  level       | No   |  failure log level     |
    ...
    ...  *EXAMPLE*
    ...  | ${cell} =  |  Query Infomodel  |  get object //CELL_M-1  |
    ...  | Infomodel Cell Should Be Online  |  ${cell}              |
    [Tags]  Assert
    [Arguments]  ${cell}  ${level}=WARN

    ${state}  Create Dictionary  availabilityStatus=Online  operationalState=Enabled
    _Infomodel Cell Should Be  ${cell.dist_name}  ${state}  ${level}


Infomodel Cell Should Be Failed
    [Documentation]
    ...  Verifies that status of given cell is failed.
    ...
    ...  In case of failure logs message with specified level. Default WARN.
    ...  |  Parameters  | Man. |  Description           |
    ...  |  cell        | Yes  |  cell InfomodelObject  |
    ...  |  level       | No   |  failure log level     |
    ...
    ...  *EXAMPLE*
    ...  | ${cell} =  |  Query Infomodel    |  get object //CELL_M-1  |
    ...  | Infomodel Cell Should Be Failed  |  ${cell}                |
    [Tags]  Assert
    [Arguments]  ${cell}  ${level}=WARN

    ${state}  Create Dictionary  availabilityStatus=Failed  operationalState=Disabled
    _Infomodel Cell Should Be  ${cell.dist_name}  ${state}  ${level}


_Infomodel Cell Should Be
    [Documentation]  This keyword is used to verify cell.
    [Arguments]  ${cell_dn}  ${expected}  ${level}

    ${cell}  Query Infomodel  get object ${cell_dn}
    ${current}  Create Dictionary  availabilityStatus=${cell.stateInfo.availabilityStatus}  operationalState=${cell.stateInfo.operationalState}
    ${availability_status}  Run Keyword And Return Status
    ...  Should Match Regexp  ${current['availabilityStatus']}  ^${expected['availabilityStatus']}$
    ${operational_state}  Run Keyword And Return Status
    ...  Should Match Regexp  ${current['operationalState']}  ^${expected['operationalState']}$
    ${as_expected}  Evaluate  ${availability_status} and ${operational_state}
    ${err_msg}  Set Variable  Cell Status Wrong. ${cell.dist_name}. Current: ${current}
    Run Keyword If  ${as_expected}
    ...  Log  [${SPACE * 2}OK${SPACE * 2}] Cell Status Correct. ${cell.dist_name}. Current: ${current}  console=true
    ...  ELSE
    ...  _Set Verdict Based On Log Level  ${level}  ${err_msg}


_Set Verdict Based On Log Level
    [Documentation]  This keyword is used to set verdict based on log level
    [Arguments]  ${level}  ${msg}

    Run Keyword If  '${level}'=='WARN'
    ...  Set Test Restriction  ${msg}
    ...  ELSE IF  '${level}'=='ERROR'
    ...  Set Test Failed  ${msg}
    ...  ELSE
    ...  Log  ${msg}  console=true


Infomodel Get Scf Cells Deployed On RMOD
    [Documentation]
    ...  Takes RMOD distName and returns list of scf cells objects
    ...  | Parameters       | Man. | Description   |
    ...  | rmod_dn          | Yes  | RMOD distName |
    ...
    ...  *RETURN*
    ...  | Parameters  | Description                                |
    ...  | cells       | List of all cells objects deployed on RMOD |
    ...
    ...  *EXAMPLE*
    ...  | ${cells} | Infomodel Get Scf Cells Deployed On RMOD | ${rmod_dn} |
    [Arguments]  ${rmod_dn}

    ${lte_cells}  Query Infomodel  get list /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-*/SCF-1//CELLMAPPING_A-1/LCELL_A-*  allow_negative_result=${TRUE}
    ${wcdma_cells}  Query Infomodel  get list /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-*/SCF-1//CELLMAPPING_A-1/LCELW_A-*  allow_negative_result=${TRUE}
    ${gsm_cells}  Query Infomodel  get list /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-*/SCF-1//CELLMAPPING_A-1/LCELC_A-*  allow_negative_result=${TRUE}
    ${cells}  Combine Lists  ${lte_cells}  ${wcdma_cells}  ${gsm_cells}

    [Return]  ${cells}


Infomodel Get All WCELL IDs
    [Documentation]
    ...  Returns sorted list of WCELL IDs fetched from IM objects names /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/WNBTS_M-*/CELL_M-*/WNCEL_M-*.
    ...  *RETURN*
    ...  |  Parameters |  Description           |
    ...  |  wcell_ids  |  List of WCELL IDs     |
    ...
    ...  *EXAMPLE*
    ...  | ${wcell_ids} =  | Infomodel Get All WCELL IDs  |
    [Tags]  Helper

    ${wcell_ids}  Create List  @{EMPTY}
    ${cells_dn}  Infomodel Get Objects Parameter  ${DIST_WCDMA_CELL}/WNCEL_M-*  dist_name
    FOR  ${cell_dn}  IN  @{cells_dn}
        ${wcell_id}  Fetch From Right  ${cell_dn}  -
        Append To List  ${wcell_ids}  ${wcell_id}
    END
    Sort List  ${wcell_ids}

    [Return]  ${wcell_ids}


Infomodel Get BcfId
    [Documentation]
    ...  Returns bcfId value
    ...  *RETURN*
    ...  |  Parameters  |  Description  |
    ...  |  bcf         |  bcfID        |
    ...
    ...  *EXAMPLE*
    ...  | ${bcfid} =  | Infomodel Get bcfId  |
    [Tags]  Helper

    ${bcf}  coam.Get Managed Objects  BCF_L

    RETURN  ${bcf}[0][parameters][bcfId]


Infomodel Get Cells Deployed On FSP
    [Documentation]
    ...  Takes infomodel object representing FSP (BBU object) and returns list of cells (infomodel objects) deployed on it.
    ...  | Parameters       | Man. | Description          |
    ...  | FSP              | Yes  | BBU infomodel object |
    ...
    ...  *RETURN*
    ...  | Parameters  | Description                                     |
    ...  | cells       | List of cells infomodel objects deployed on FSP |
    ...
    ...  *EXAMPLE*
    ...  | ${cells}    | Infomodel Get Cells Deployed On FSP | ${bbu_obj} |
    [Arguments]  ${bbu}

    ${routing_tables}  _Get FSP Routing Tables  ${bbu.dist_name}
    ${routing_entities}  _Get Entities From Routing Tables  ${routing_tables}
    ${channel_distnames}  _Get Channel Distnames From Routing Entities  ${routing_entities}
    ${cells}  _Get Cells From Channel  ${channel_distnames}

    [Return]  ${cells}


_Get FSP Routing Tables
    [Documentation]  This keyword is used to get FSP routing tables
    [Arguments]  ${bbu_node}

    ${query}  Set Variable  get list ${bbu_node}//ROUTINGTABLE_L-*
    ${routing_tables}  Query Infomodel  ${query}  allow_negative_result=True

    [Return]  ${routing_tables}


_Get Entities From Routing Tables
    [Documentation]  This keyword is used to get entities from routing tables.
    [Arguments]  ${tables}

    ${entities}  Create List  @{EMPTY}
    FOR  ${table}  IN  @{tables}
        ${dn}  Set Variable  ${table['dist_name']}
        ${query}  Set Variable  get list ${dn}/ROUTINGENTITY_L-*
        ${table_entities}  Query Infomodel  ${query}  allow_negative_result=True
        ${entities}  Combine Lists  ${entities}  ${table_entities}
    END

    [Return]  ${entities}


_Get Channel Distnames From Routing Entities
    [Documentation]  This keyword is used to get channel distnames from routing entities.
    [Arguments]  ${entities}

    ${channel_distnames}  Create List  @{EMPTY}
    FOR  ${entity}  IN  @{entities}
        Append To List  ${channel_distnames}  ${entity['channelDN']}
    END

    [Return]  ${channel_distnames}


_Get Cells From Channel
    [Documentation]  This keyword is used to get cells from channel
    [Arguments]  ${channels}

    @{cells}  Create List  @{EMPTY}
    FOR  ${channel}  IN  @{channels}
        @{nodes}  Split String  ${channel}  separator=/
        ${bts_id}  Get From List  ${nodes}  -4
        ${cell_id}  Get From List  ${nodes}  -3
        ${is_cell}  Run Keyword And Return Status
        ...  Should Contain  ${cell_id}  CELL
        ${cell}  Run Keyword If  ${is_cell}
        ...  Get Infomodel Object  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/${bts_id}/${cell_id}
        Run Keyword If  ${is_cell}
        ...  Append To List  ${cells}  ${cell}
    END
    ${final_cells}  Remove Duplicates  ${cells}

    [Return]  ${final_cells}


Get SM Variant
    [Documentation]
    ...  Return list of System Module variants in use. First is master second (if exist) slave

    ${sm_variant}  Create List
    ${sm_variant_list}  Get SM Variant With Full Name
    FOR  ${sm}  IN  @{sm_variant_list}
        ${match}  ${group}  Should Match Regexp  ${sm}  (FSMF|FSIH|ASIA|ASIB|ASIAB|ASIL)
        Append To List  ${sm_variant}  ${match}
    END

    [Return]  ${sm_variant}


Get SM Variant With Full Name
    [Documentation]
    ...  Return list of System Module variants in use with full name. First is master second (if exist) slave

    ${sm_variant}  Create List
    ${status}  ${sm_primary}  Run Keyword And Ignore Error
    ...  Query Infomodel  get object //EQM_R-*//SMOD_R-* is [activeRole=empty]
    Run Keyword If  '${status}'=='PASS'
    ...  Run Keywords
    ...  Append To List  ${sm_variant}  ${sm_primary}[productName]
    ...  AND
    ...  Return From Keyword  ${sm_variant}

    ${sm_primary}  Query Infomodel  get object //EQM_R-*//SMOD_R-* is [activeRole=Primary]
    ${sm_secondary}  Query Infomodel  get object //EQM_R-*//SMOD_R-* is [activeRole=Secondary]
    Append To List  ${sm_variant}  ${sm_primary}[productName]  ${sm_secondary}[productName]
    Log  SM variant: ${sm_variant}  console=true

    [Return]  ${sm_variant}


Log All Tx Power
    [Documentation]
    ...  Log TX Power for all radio modules
    [Arguments]  ${print_to_report}=${True}

    ${radio_distname_list}  Query Infomodel  get list //RUNTIME_VIEW-*//RMOD_R-*
    FOR  ${radio_distname}  IN  @{radio_distname_list}
        ${ref_radio_object}  Query Infomodel  get object ${radio_distname.dist_name}/REF-*
        ${im_radio_object}  Query Infomodel  get object ${ref_radio_object.distName}
        Log  ${\n}TX-Power for ${im_radio_object.serialNumber}  console=true
        ${im_module_object}  Query Infomodel  get object ${im_radio_object.masterAgentDN}
        ${module_address}  Set Variable If  '${im_module_object.ipAddress}'=='${OAM_SC_IP}' and '474767A' in '${im_module_object.productCode}'
        ...  fct-4a  ${im_module_object.ipAddress}
        ${tx_power_dict}  Get Tx Power  ${im_radio_object.ipAddress}  ${module_address}  ${im_radio_object.productName}
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
    [Arguments]  ${rmods_distnames}

    ${rmods_serial_numbers}  Create Dictionary
    FOR  ${rmod_single_distname}  IN  @{rmods_distnames}
        ${rmod_obj}  Query Infomodel  get object ${rmod_single_distname}
        Set To Dictionary  ${rmods_serial_numbers}  ${rmod_single_distname}=${rmod_obj['serialNumber']}
    END

    [Return]  ${rmods_serial_numbers}


Infomodel Check If Cells In RAT Were Operational According To IM Log
    [Documentation]
    ...  Helper KW for checking if cells of given RAT remain operational according to IM log
    ...  AvailabilityStatus and operationalState from objects //CELL_M-* are checked.
    [Arguments]  ${rat}  ${im_log_path}

    ${cells_objects}  Query Infomodel  get list ${DIST_${rat}_CELL}  allow_negative_result=True
    Log  Check ${rat} cells  console=True
    FOR  ${cell_object}  IN  @{cells_objects}
        Initialize Ims2 Validator  ${im_log_path}
        Add Expected Ims2 Event  change ${cell_object.dist_name} [stateInfo.availabilityStatus]
        Add Expected Ims2 Event  change ${cell_object.dist_name} [stateInfo.operationalState]
        Run Keyword And Expect Error  InfoModelIms2ValidationException:*
        ...  Validate Ims2
        Log  ${cell_object.dist_name} availabilityStatus and operationalState remained unchanged  console=True
    END
    Log  All ${rat} cells were operational according to IM log  console=True


Infomodel Get All DSPs Dist Names For Given RAT
    [Documentation]
    ...  KW for obtaining sorted list of DSPs distNames from IM
    [Arguments]  ${rat}

    ${dsps_dist_names}  Create List
    ${sw_entities_objects}  Query Infomodel  get list //DSP_L-*/SOFTWARE_ENTITY-* is [rat="${rat}"]
    FOR  ${sw_entity}  IN  @{sw_entities_objects}
        Append To List  ${dsps_dist_names}  ${sw_entity['deviceDN']}
    END
    Sort List  ${dsps_dist_names}

    [Return]  ${dsps_dist_names}


Infomodel Check If DSPs Were Restarted According To Ims File
    [Documentation]
    ...  KW checks given ims2 file (first argument) looking for DSPs restart event. All DSPs from given list (second
    ...  argument) are checked. User can use 'Save Infomodel Log' KW to obtain ims2 file and 'Infomodel get all DSPs dist names for given RAT'
    ...  to get DSPs list
    ...  | Parameter      | Man. | Description                             |
    ...  | im_log_path    | Yes  | Path for Infomodel ims2 file            |
    ...  | dsp_dist_names | Yes  | List of DSPs dist names fetched from IM |
    [Arguments]  ${im_log_path}  ${dsp_dist_names}

    FOR  ${dsp_dist_name}  IN  @{dsp_dist_names}
        Initialize Ims2 Validator  ${im_log_path}
        Add Expected Ims2 Event  change ${dsp_dist_name} [stateInfo.proceduralState: * -> Resetting]
        Validate Ims2
        Log  ${dsp_dist_name} was restarted  console=True
    END


Infomodel Check IM Log If BTS Reset Was Triggered
    [Documentation]
    ...  KW for checking IM log for reset event occurence. It saves IM log for further processing under given path and
    ...  then validates it in context of reset. Returns true or false.
    ...  | Parameter        | Man. | Description                                    |
    ...  | path_for_im_log  | Yes  | Absolute path under which IM log will be saved |
    ...
    ...  *RETURN*
    ...  | ${was_reset_present} | Infomodel Check IM log if BTS reset was triggered | ${BTS_FILES}/IM/InfoModel_log_for_reset_check.ims2 |
    [Arguments]  ${path_for_im_log}

    Save Infomodel Log  ${path_for_im_log}  timeout=120
    Initialize Ims2 Validator  ${path_for_im_log}
    Add Expected Ims2 Event  reset
    ${was_triggered}  Run Keyword And Return Status
    ...  Validate Ims2

    [Return]  ${was_triggered}


Check SW Version
    [Documentation]  This keyword is used to check SW version
    [Arguments]
    ...  ${step_number}
    ...  ${pass_if_sw_exists}=${False}
    ...  ${module}=MSM
    ...  ${im_param_active}=activeBuildDescriptorId
    ...  ${im_param_passive}=passiveBuildDescriptorId
    ...  ${alias}=default

    ${active_sw}  Infomodel Get Active SW Version  module=${module}  im_param=${im_param_active}  alias=${alias}
    ${passive_sw}  Infomodel Get Passive SW Version  module=${module}  im_param=${im_param_passive}  alias=${alias}
    Log  Active software package is: ${active_sw}  console=True
    Log  Passive software package is: ${passive_sw}  console=True
    ${sw_release_name}  hran_file_operations.Get TargetBD Node Attribute Value  softwareReleaseVersion  ${TARGET_SW_PATH}
    Run Keyword If  '${passive_sw}'==''
    ...  Set Test Restriction  Passive sw version was not readable
    Run Keyword If  '${step_number}'=='2'
    ...  Run Keywords
    ...  Set Tags  SW_BEFORE_UPDATE_active-${active_sw}  SW_BEFORE_UPDATE_passive-${passive_sw}
    ...  AND
    ...  Check If SW Already Exists On BTS  ${sw_release_name}  ${active_sw}  ${passive_sw}  ${pass_if_sw_exists}
    Run Keyword If  '${step_number}'!='2'
    ...  Run Keywords
    ...  Set Tags  SW_AFTER_UPDATE_active-${active_sw}
    ...  AND
    ...  Set Tags  SW_AFTER_UPDATE_passive-${passive_sw}
    ...  AND
    ...  Set Test Variable  ${TARGET_SW}  ${active_sw}
    ...  AND
    ...  Should Match Regexp  ${sw_release_name}  (?i).*${active_sw}(?!T[12]).*
    Run Keyword If  '${active_sw}'=='?'
    ...  Set Test Failed  Active sw version fetched from infomodel equals "?"


Check System Modules Configuration In InfoModel
    [Documentation]
    ...  This KW returns what kind of configuration of system modules (4, 3, 3+3, 4+4 or 4+3) is currently in use.
    ...  **Example of simple usage:**
    ...
    ...  .. code-block: robotframework
    ...   ${configuration}  Check System Modules Configuration In InfoModel

    ${smod_objects}  Query Infomodel  get list //SMOD_BP_L-*
    FOR  ${index}  ${smod_object}  IN ENUMERATE  @{smod_objects}
        ${hw_release}  Set Variable If  ${index} == 0  ${smod_object['hwRelease']}  ${HW_RELEASE}+${smod_object['hwRelease']}
    END

    [Return]  ${hw_release}


Fail If Ims2 Object Change
    [Documentation]
    ...  Validate if object parameter in IMS2 was not changed
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
    ...   Initialize ims2 validator   ${BTS_FILES}/IM/${alias}.ims2  alias=${alias}
    ...   Fail if ims2 object change  ${SMOD_DISTNAME}  administrativeState   Unlocked  ${alias}
    ...
    [Arguments]  ${object}  ${parameter}  ${value}  ${alias}=DSC

    Add Expected Ims2 Event  change ${object} [stateInfo.${parameter}: ${value}->!${value}]  alias=${alias}
    ${status}  Run Keyword And Return Status
    ...  Validate Ims2  alias=${alias}
    Run Keyword If  ${status}
    ...  Set Test Failed  DSC: ${object} state was changed (${parameter}!=${value})


Fail If Ims2 Event Occur
    [Documentation]
    ...  Validate and fail if event occured
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
    ...   Initialize ims2 validator    ${BTS_FILES}/IM/InfoModel_log.ims2  alias=${alias}
    ...   Fail if ims2 occur  ${alias}
    ...
    [Arguments]  ${event}  ${alias}=DSC

    Add Expected Ims2 Event  ${event}  alias=${alias}
    ${event_triggered}  Run Keyword And Return Status
    ...  Validate Ims2  alias=${alias}
    Run Keyword If  ${event_triggered}
    ...  Set Test Failed  DSC: ${event} event has been found
