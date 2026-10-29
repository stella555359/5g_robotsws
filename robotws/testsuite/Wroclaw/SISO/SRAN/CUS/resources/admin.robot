*** Settings ***
Documentation  Admin actions
...    Author: slawomir.jastrzebski@nokia.com
...    Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    String
Library    Collections
Library    taf.sbts.oam.coam.admin    WITH NAME    admin

*** Keywords ***
#Check section
Admin Check Cells State Before BTS OnAir
    [Arguments]  ${timeout}=${BB_CALC_STATE_TIMEOUT}
    [Documentation]
    ...  Description:
    ...  Keyword checks the proceduralState of the cells before BTS is in "OnAir" state.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | timeout                |  No  | Waiting time for each cell expected procedural state.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cell_list}=  admin.Get Cell List  timeout=120
    ${lte_cells_count}=  Get Length  item=${cell_list['cells']['lte']}
    ${nr_cells_count}=  Get Length  item=${cell_list['cells']['nr']}
    Run Keyword If  ${lte_cells_count}>0
    ...  admin.Assert Every  class_name=LNCEL  parameters=proceduralState=regex"(?i)Validated"  timeout=${timeout}
    Run Keyword If  ${nr_cells_count}>0
    ...  admin.Assert Every  class_name=NRCEL  parameters=proceduralStatus=regex"(?i)configured"  timeout=${timeout}

Admin BTS Should Be NotCommissioned
    [Arguments]  ${log_to_console}=True  ${log_prefix}=${EMPTY}
    [Documentation]
    ...  Description:
    ...  Keyword checks if BTS is in "NotCommissioned" state
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Admin LNBTS Object Should Be Available
    Admin BTS Procedural State Should Be  state_value=NotCommissioned  timeout=20
    ${bts_parameters}=  Admin Get BTS Parameters
    ${proceduralState_value}=  Set Variable  ${bts_parameters['proceduralState']}
    Log  ${log_prefix}BTS Procedural State is now ${proceduralState_value}  console=${log_to_console}

Admin BTS Should Be Configured
    [Arguments]  ${log_to_console}=True  ${log_prefix}=${EMPTY}
    [Documentation]
    ...  Description:
    ...  Keyword checks if BTS is in "Configured" or "IntegratedToRan" state.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Admin LNBTS Object Should Be Available
    Admin BTS Procedural State Should Be  state_value=Configured|IntegratedToRan  timeout=${TO_CONFIGURED_TIMEOUT}
    ${bts_parameters}=  Admin Get BTS Parameters
    ${proceduralState_value}=  Set Variable  ${bts_parameters['proceduralState']}
    Log  ${log_prefix}BTS Procedural State is now ${proceduralState_value}  console=${log_to_console}

Admin BTS Should Be OnAir
    [Arguments]  ${cell_timeout}=700  ${bts_timeout}=700  ${log_to_console}=True  ${log_prefix}=${EMPTY}
    [Documentation]
    ...  Description:
    ...  Keyword checks if BTS is in "OnAir" state.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
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

    Admin BTS Procedural State Should Be  state_value=OnAir  timeout=${bts_timeout}
    ${bts_parameters}=  Admin Get BTS Parameters
    ${proceduralState_value}=  Set Variable  ${bts_parameters['proceduralState']}
    Log  ${log_prefix}BTS Procedural State is now ${proceduralState_value}  console=${log_to_console}
    Admin Check Cells State When BTS OnAir  timeout=${cell_timeout}

Admin BTS Should Be OnAir After Power Reset
    [Arguments]  ${bts_timeout}=500  ${log_to_console}=True  ${log_prefix}=${EMPTY}  ${timeout}=${BB_CALC_STATE_TIMEOUT}
    [Documentation]
    ...  Description:
    ...  Keyword checks if BTS is in "OnAir" state after power reset.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bts_timeout            |  Yes | Waiting time for BTS expected procedural state.                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for each cell expected procedural state.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cell_list}=  admin.Get Cell List  timeout=120
    ${lte_cells_count}=  Get Length  item=${cell_list['cells']['lte']}
    ${nr_cells_count}=  Get Length  item=${cell_list['cells']['nr']}
    Run Keyword If  ${lte_cells_count}>0
    ...  admin.Assert Every  class_name=LNCEL  parameters=proceduralState=regex"(?i)OnAir"
    ...  timeout=${timeout}
    ${nr_proceduralStatus}=  Set Variable  proceduralStatus=regex"(?i)configured"
    ${nr_administrativeState}=  Set Variable  administrativeState=regex"(?i)unlocked"
    ${nr_operationalState}=  Set Variable  operationalState=regex"(?i)Enabled"
    Run Keyword If  ${nr_cells_count}>0
    ...  admin.Assert Every  class_name=NRCEL
    ...  parameters=${nr_proceduralStatus},${nr_administrativeState},${nr_operationalState}
    ...  timeout=${timeout}
    Admin BTS Procedural State Should Be  state_value=OnAir  timeout=${bts_timeout}
    ${bts_parameters}=  Admin Get BTS Parameters
    ${proceduralState_value}=  Set Variable  ${bts_parameters['proceduralState']}
    Log  ${log_prefix}BTS Procedural State is now ${proceduralState_value}  console=${log_to_console}

Admin LNBTS Object Should Be Available
    [Arguments]  ${timeout}=120
    [Documentation]
    ...  Description:
    ...  Keyword confirms if LNBTS object is available.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | timeout                | Yes  | Time to wait for positive procedure result.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${lnbts_id}=  admin.Get Id For Current  class_name=LNBTS  timeout=${timeout}
    Log  LNBTS dist name:${lnbts_id}

Admin Check Every LNCEL State
    [Arguments]  ${state}  ${state_value}  ${timeout}=10
    [Documentation]
    ...  Description:
    ...  Keyword confirms that every cell has the given state (${state}) value (${state_value}).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | state                  | Yes  | Name of the state being checked.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | state_value            |  Yes | Value of expected state.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for cells expected states.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    admin.Assert Every  class_name=LNCEL  parameters=${state}=regex"(?i)${state_value}"  timeout=${timeout}

#Admin Assert Specified LNCEL State
#    [Arguments]    ${lncel_conf_id_list}    ${state}    ${state_value}    ${timeout}=10
#    [Documentation]    Keyword confirms that every cell given by lncel configuration id list
#    ...    (${lncel_conf_id_list}) has the given state (${state}) value (${state_value}).
#    ...    List ${lncel_conf_id_list} is lncel configuration id list, e.g.:
#    ...    ['1', '2']
#    ...    Author: slawomir.jastrzebski@nokia.com
#    ...    Maintainer: slawomir.jastrzebski@nokia.com
#    :FOR  ${lncel_id}  IN  @{lncel_conf_id_list}
#    \  ${lncel_node_id}=    Get Cell Id By Configuration Id  rat=LTE  configuration_id=${lncel_id}
#    \  Assert    class_name=LNCEL    id=${lncel_node_id}    parameters=${state}=regex"(?i)${state_value}"
#    ...    timeout=${timeout}

Admin CAREL Should Exist
    [Documentation]
    ...  Description:
    ...  Keyword checks if CAREL objects exist.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${CAREL_object_list}=  admin.Get Managed Objects  class_name=CAREL_A
    Should Not Be Empty  ${CAREL_object_list}

Admin LNCEL CAREL Should Exist
    [Arguments]  ${lncel_id}
    [Documentation]
    ...  Description:
    ...  Keyword checks if there is the CAREL_A object for the given LNCEL cell id.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lncel_id               | Yes  | LNCEL cell id.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    ${carel_list}=  admin.Get Managed Objects  class_name=CAREL_A
    ${carel_status}=  Run Keyword And Return Status  Should Not Be Empty  ${carel_list}
    FOR  ${carel_object}  IN  @{carel_list}
      ${carel_status}=  Run Keyword And Return Status
      ...  Should Contain  ${carel_object['distName']}  LNCEL_A-${lncel_id}/
      Exit For Loop If  ${carel_status}
    END
    [Return]  ${carel_status}

Admin Check RMOD Detection
    [Arguments]  ${rmod_serial}  ${timeout}  ${rmod_count}=0  ${rmod_number}=0
    ...  ${log_to_console}=True  ${log_prefix}=${EMPTY}
    [Documentation]
    ...  Description:
    ...  Keyword checks if RMOD with the serial number ${rmod_serial}
    ...  contains the attribute "operationalState" with the value "enabled".
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_serial            | Yes  | Serial number of detected radio module.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                | Yes  | Waiting time for RMOD expected operational state.                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_count             | Yes  | Number of all radio modules.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_number            | Yes  | Current number of detected radio module.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${count_number_info}=  Set Variable If  ${rmod_count}==0 or ${rmod_number}==0
    ...  ${EMPTY}  (${rmod_number}/${rmod_count})
    ${rmod_detection_status}=  Run Keyword And Return Status
    ...  admin.Assert Any  class_name=RMOD  parameters=operationalState=regex"(?i)enabled",serialNumber=${rmod_serial}
    ...  timeout=${timeout}
    Run Keyword If  ${rmod_detection_status}
    ...  Log  ${log_prefix}${count_number_info} RMOD ${rmod_serial} is detected  console=${log_to_console}
    ...  ELSE  Run Keywords
    ...  Log  ${log_prefix}${count_number_info} [!] RMOD ${rmod_serial} not detected  console=${log_to_console}
    ...  AND  Fail

#Get section
Admin Get BTS Parameters
    [Documentation]
    ...  Description:
    ...  Keyword returns parameters of BTS object.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${bts_id}=  admin.Get Id For Current  class_name=BTS  timeout=120
    ${bts_parameters}=  admin.Get Parameters For  class_name=BTS  id_num=${bts_id}  timeout=120
    [Return]  ${bts_parameters}

Admin Get LNCEL Bandwidth
    [Arguments]  ${lncel_id}
    [Documentation]
    ...  Description:
    ...  Keyword gets cell bandwidth for LNCEL cell id (${lncel_id}).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lncel_id               | Yes  | LNCEL cell id.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${lncel_dist_name}=  admin.Get Cell Id By Configuration Id  rat=LTE  configuration_id=${lncel_id}
    ${lncel_params}=  admin.Get Parameters For  class_name=LNCEL  id_num=${lncel_dist_name}
    ${lncel_bw}=  Set Variable If  '${lncel_params.technology}'=='FDD'  ${lncel_params.downlinkChannelBandwidth}
    ...  '${lncel_params.technology}'=='NB-IoT-FDD'  ${lncel_params.downlinkChannelBandwidth}
    ...  '${lncel_params.technology}'=='TDD'  ${lncel_params.channelBandwidth}
    [Return]  ${lncel_bw}

Admin Get LNBTS Parameter Value
    [Arguments]  ${parameter_name}
    [Documentation]
    ...  Description:
    ...  Keyword returns the parameter value for the given parameter name for LNBTS_A object.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | parameter_name         | Yes  | The name of the attribute whose value is to be retrieved.                  |
    ...  +-------------------------+------+---------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    ${lnbts_list}=  admin.Get Managed Objects  class_name=LNBTS_A
    ${lnbts_param_value}=  Set Variable  ${lnbts_list[0]['parameters']['${parameter_name}']}
    [Return]  ${lnbts_param_value}

Admin Get Cell Parameter Value
    [Arguments]  ${lncel_id}  ${parameter_name}
    [Documentation]
    ...  Description:
    ...  Keyword gets cell parameter value for given parameter name.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lncel_id               | Yes  | LNCEL cell id.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | parameter_name         | Yes  | The name of the parameter whose value is retrieved.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${lncel_dist_name}=  admin.Get Cell Id By Configuration Id  rat=LTE  configuration_id=${lncel_id}
    ${lncel_params}=  admin.Get Parameters For  class_name=LNCEL  id_num=${lncel_dist_name}
    ${parameter_value}=  Set Variable  ${lncel_params.${parameter_name}}
    [Return]  ${parameter_value}

Admin Get LNCEL_M Parameter Value
    [Arguments]  ${lncel_id}  ${parameter_name}
    [Documentation]
    ...  Description:
    ...  Keyword returns the parameter value for the given parameter name for LNCEL_M object.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lncel_id               | Yes  | LNCEL cell id.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | parameter_name         | Yes  | The name of the attribute whose value is to be retrieved.                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    ${lncel_list}=  admin.Get Managed Objects  class_name=LNCEL_M
    FOR  ${lncel_object}  IN  @{lncel_list}
      ${lncel_name}=  Fetch From Right  string=${lncel_object['distName']}  marker=/
      ${lncel_status}=  Run Keyword And Return Status
      ...  Should Match  ${lncel_name}  LNCEL_M-${lncel_id}
      ${lncel_param_value}=  Set Variable If  ${lncel_status}  ${lncel_object['parameters']['${parameter_name}']}
      Exit For Loop If  ${lncel_status}
    END
    [Return]  ${lncel_param_value}

Admin Get LNCEL CAREL Parameter Value List
    [Arguments]  ${lncel_id}  ${parameter_name}
    [Documentation]
    ...  Description:
    ...  Keyword returns the list of parameter value for the given parameter name
    ...  for all CAREL_A objects for the given LNCEL cell id.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lncel_id               | Yes  | LNCEL cell id.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | parameter_name         | Yes  | The name of the parameter whose value is to be retrieved.                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  slawomir.jastrzebski@nokia.com
    ...  Maintainer:  slawomir.jastrzebski@nokia.com

    ${carel_param_value_list}=  Create List
    ${carel_list}=  admin.Get Managed Objects  class_name=CAREL_A
    FOR  ${carel_object}  IN  @{carel_list}
      ${carel_status}=  Run Keyword And Return Status
      ...  Should Contain  ${carel_object['distName']}  LNCEL_A-${lncel_id}/
      Run Keyword If  ${carel_status}
      ...  Append To List  ${carel_param_value_list}  ${carel_object['parameters']['${parameter_name}']}
    END
    [Return]  ${carel_param_value_list}

Admin Get All Cells Ids
    [Arguments]  ${connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns list of all cells ids existing in configuration.
     ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | connection             |  No  | Name of admin connection object.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author:  jakub.pachana@nokia.com
    ...  Maintainer:  jakub.pachana@nokia.com
    ...
    ${nr_cells}=  admin.Get Ids For All  class_name=NRCEL  connection=${connection}
    ${lte_cells}=  admin.Get Ids For All  class_name=LNCEL  connection=${connection}
    ${wcdma_cells}=  admin.Get Ids For All  class_name=WNCEL  connection=${connection}
    ${gsm_cells}=  admin.Get Ids For All  class_name=GNCEL  connection=${connection}
    ${cells_ids}=  Combine Lists  ${nr_cells}  ${lte_cells}  ${wcdma_cells}  ${gsm_cells}
    [Return]  ${cells_ids}

Admin Get Gps Status
    [Arguments]  ${log_to_console}=no
    [Documentation]
    ...  Description:
    ...  Keyword gets information about detected GPS satellites.
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

    ${bts_gps_status}=  admin.Get Gps Status
    ${satellite_list}=  Create List  @{bts_gps_status['gnsse'][0]['satelliteInformation']}
    ${info_string}=  Set Variable  \nGPS satellites status:\n
    FOR  ${satellite_id}  IN  @{satellite_list}
      ${info_string}=  Catenate  ${info_string}  ${satellite_id}\n
    END
    Log  ${info_string}  console=${log_to_console}
    [Return]  ${info_string}

Admin Get BTS Software Version
    [Documentation]
    ...  Description:
    ...  Keyword gets BTS active software version.
    ...
    ...  Author: jakub.pachana@nokia.com
    ...  Maintainer: jakub.pachana@nokia.com

    ${sw_info}=  admin.Get Software Info  timeout=120
    ${enb_sw_release}=  Set Variable  ${sw_info['Active SW version']}
    Set Suite Variable  ${enb_sw_release}

Admin Get Cells To Radio Mapping
    [Documentation]
    ...  Description:
    ...  Keyword creates dictionary of informations about cells mapping to RF.
    ...
    ...  Author: jakub.pachana@nokia.com
    ...  Maintainer: jakub.pachana@nokia.com

    ${cell_list}=  admin.Get Cell List  timeout=120
    ${cells_to_rmod}=  Create Dictionary
    ${cells_dict}=  Get From Dictionary  ${cell_list}  cells
    FOR  ${tech}  ${cells}  IN  &{cells_dict}
        FOR  ${cell}  IN  @{cells}
            ${cell_name}=  Get From Dictionary  ${cell['id']}  configuration
            ${has_carrier_list}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${cell}  carrierList
            Run Keyword If  not ${has_carrier_list}  Continue For Loop
            ${carrier_list}=  Get From Dictionary  ${cell}  carrierList
            ${rmods}=  Create List
            FOR  ${carrier}  IN  @{carrier_list}
                ${has_ant}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${carrier}  antennaLineId
                Run Keyword If  not ${has_ant}  Continue For Loop
                ${ant_cfg}=  Get From Dictionary  ${carrier['antennaLineId']}  configuration
                ${contains}=  Run Keyword And Return Status    Should Contain  ${ant_cfg}  RMOD-
                Run Keyword If  not ${contains}  Continue For Loop
                ${split}=  Split String  ${ant_cfg}    RMOD-
                ${right}=  Set Variable  ${split}[1]
                ${rmod}=  Set Variable  RMOD-${right[0]}
                IF  '${rmod}' not in ${rmods}
                    Append To List  ${rmods}  ${rmod}
                END
            END
            Run Keyword If  ${rmods}  Set To Dictionary  ${cells_to_rmod}  ${cell_name}=${rmods}
        END
    END
    [Return]  ${cells_to_rmod}

Admin Get Rmods To RF Ports Mapping
    [Documentation]
    ...  Description:
    ...  Keyword creates dictionary of informations about Rmods mapping to RF.
    ...
    ...  Author: jakub.pachana@nokia.com
    ...  Maintainer: jakub.pachana@nokia.com

    ${data}=  admin.Get Sfp Links  timeout=120
    ${rmod_to_rf}=  Create Dictionary
    ${connected_list}=  Get From Dictionary  ${data}  connected
    FOR  ${conn}  IN  @{connected_list}
        ${parent}=  Get From Dictionary  ${conn}  parent
        ${destination}=  Get From Dictionary  ${parent}  destination
        ${rf_port}=  Get From Dictionary  ${destination}  physicalPort
        ${data}=  Get From Dictionary  ${conn}  data
        ${link_ports}=  Get From Dictionary  ${data}  linkPorts
        ${source}=  Get From Dictionary  ${link_ports}  source
        ${split}=  Split String  ${source}  /
        ${rmod_part}=  Set Variable  ${split}[0]
        ${rmod}=  Split String  ${rmod_part}  (
        ${rmod}=  Set Variable  ${rmod}[0]
        Run Keyword If  '${rmod}' and '${rf_port}'  Set To Dictionary  ${rmod_to_rf}  ${rmod}=${rf_port}
    END
    [Return]  ${rmod_to_rf}

Admin Get Cells To RF Ports Mapping
    [Arguments]  ${cells_to_rmods}  ${rmod_to_rf}
    [Documentation]
    ...  Description:
    ...  Keyword creates dictionary of information about cells mapping to RF.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cells_to_rmods         | Yes  | Dictionary contains cells to rmod mapping                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_to_rf             | Yes  | Dictionary contains rmods to rf mapping                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: jakub.pachana@nokia.com
    ...  Maintainer: jakub.pachana@nokia.com

    ${cells_to_rf}=  Create Dictionary
    FOR  ${cell}  IN  @{cells_to_rmods}
        ${rmods}=  Get From Dictionary  ${cells_to_rmods}  ${cell}
        ${rf_ports}=  Create List
        FOR  ${rmod}  IN  @{rmods}
            ${rf}=  Get From Dictionary  ${rmod_to_rf}  ${rmod}
            Run Keyword If  '${rf}' != 'None'  Append To List  ${rf_ports}  ${rf}
        END
        Run Keyword If  ${rf_ports}  Set To Dictionary  ${cells_to_rf}  ${cell}=${rf_ports}
    END
    [Return]  ${cells_to_rf}

Get Cells With Fault 1868
    [Arguments]  @{faults}
    [Documentation]
    ...  Description:
    ...  Keyword creates dictionary of information about cells mapping to RF.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | faults                 | Yes  | List of objects affected by any fault                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: jakub.pachana@nokia.com
    ...  Maintainer: jakub.pachana@nokia.com

    ${faulty_cells}=  Create List
    FOR  ${fault}  IN  @{faults}
        ${fault_id}=  Get From Dictionary  ${fault}  faultId
        Run Keyword If  '${fault_id}' != '1868'  Continue For Loop
        ${object_list}=  Get From Dictionary  ${fault}  alarmingObjectIds
        FOR  ${obj}  IN  @{object_list}
            ${cell}=  Get From Dictionary  ${obj}  configuration
            IF  '${cell}' not in ${faulty_cells}  Append To List  ${faulty_cells}  ${cell}
        END
    END
    [Return]  ${faulty_cells}

Get Enabled Cells List
    [Arguments]  ${cell_list}
    [Documentation]
    ...  Description:
    ...  Keyword creates dictionary of information about cells mapping to RF.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_list              | Yes  | Cells list with informations                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: jakub.pachana@nokia.com
    ...  Maintainer: jakub.pachana@nokia.com

    ${enabled_cells}=  Create List
    ${cells_dict}=  Get From Dictionary  ${cell_list}  cells
    FOR  ${tech}  ${cells}  IN  &{cells_dict}
        FOR  ${cell}  IN  @{cells}
            ${status}=  Get From Dictionary  ${cell}  status
            ${op_state}=  Get From Dictionary  ${status}  operationalState
            Run Keyword If  '${op_state}' == 'enabled'  Append To List  ${enabled_cells}  ${cell['id']['configuration']}
        END
    END
    [Return]  ${enabled_cells}

#RAT Reset keywords (BEGIN)
Get Dist Names For Item Class
    [Arguments]  ${class_name}  ${connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword get dist names for all items of given class.
    ...  Keyword returns an error if the searched objects are not found.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | class_name             |  Yes  | Name of the class.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | connection             |  No  | Name of admin connection object.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${all_dist_names}=  admin.Get Ids For All  class_name=${class_name}  connection=${connection}
    Should Not Be Empty  item=${all_dist_names}
    ...  msg=No ${class_name} items have been found on BTS !!!
    [Return]  ${all_dist_names}

Get Dist Names For Item Class List
    [Arguments]   ${class_names}  ${connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword get dist names for all items of given class list.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | class_names            |  Yes  | List of the class names.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | connection             |  No  | Name of Admin connection object.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${all_dist_names}=  Create List
    FOR  ${class_name}  IN  @{class_names}
      ${class_dist_names}=  admin.Get Ids For All  class_name=${class_name}  connection=${connection}
      ${all_dist_names}=  Combine Lists  ${all_dist_names}  ${class_dist_names}
    END
    [Return]  ${all_dist_names}

Remove Selected Dist Names
    [Arguments]  ${class_names}  ${dist_names}  ${connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword removes selected items (given as a dist names list) from the list of all items defined by the class list.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | class_names            |  Yes  | List of the class names.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | dist_names             |  Yes  | List of the dist names to be removed.                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | connection             |  No  | Name of admin connection object.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${all_dist_names}=  Get Dist Names For Item Class List  class_names=${class_names}  connection=${connection}
    FOR  ${dist_name}  IN  @{dist_names}
      Remove Values From List    ${all_dist_names}    ${dist_name}
    END
    ${target_dist_names}=  Set Variable  ${all_dist_names}
    [Return]  ${target_dist_names}

Get Selected Cells Dist Names
    [Arguments]  ${cell_ids}  ${connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns the dist names of the cells (LTE or NR) given by ids.
    ...  Cell ids are separated by commas.
    ...  Example:
    ...  cell_ids  1,2,3
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_ids               |  Yes  | Cell ids.                                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | connection             |  No  | Name of admin connection object.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cell_dist_names}=  Create List
    ${ids}=  Split String From Right  string=${cell_ids}  separator=,
    ${nr_dist_names}=  admin.Get Ids For All  class_name=NRCEL  connection=${connection}
    ${lte_dist_names}=  admin.Get Ids For All  class_name=LNCEL  connection=${connection}
    ${wcdma_dist_names}=  admin.Get Ids For All  class_name=WNCEL  connection=${connection}
    ${gsm_dist_names}=  admin.Get Ids For All  class_name=GNCEL  connection=${connection}
    ${all_dist_names}=  Combine Lists  ${nr_dist_names}  ${lte_dist_names}  ${wcdma_dist_names}  ${gsm_dist_names}
    FOR  ${id}  IN  @{ids}
      ${matches_list}=  Get Matches  list=${all_dist_names}  pattern=regexp=.*-${id}$
      ${match_status}=  Run Keyword And Return Status  Should Not Be Empty  item=${matches_list}
      ${gncel_match_list}=  Get Matches  list=${all_dist_names}  pattern=regexp=.*GNCEL_CONF_M-${id}
      ${gncel_match_status}=  Run Keyword And Return Status  Should Not Be Empty  item=${gncel_match_list}
      Run Keyword If  ${match_status}  Append To List  ${cell_dist_names}  ${matches_list[0]}
      Run Keyword If  ${gncel_match_status}  Append To List  ${cell_dist_names}  ${gncel_match_list[0]}
    END
    [Return]  ${cell_dist_names}

Get NR NSA Cells Dist Names
    [Arguments]  ${connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns dist names of NSA cells anchored by any LTE cell.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | connection             |  No  | Name of admin connection object.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com
    ...  Last update: jakub.pachana@nokia.com

    ${nsa_dist_names}=  Create List
    ${cells_info}=  admin.Get Cells Info  timeout=360  connection=${connection}
    FOR  ${cell}  IN  @{cells_info}
      Run Keyword If  "${cell['cellDepType']}"=="NSA"
      ...  Append To List  ${nsa_dist_names}  ${cell['id']['internal']}
    END
    [Return]  ${nsa_dist_names}

Get Baseband Dist Names With Excluded Items
    [Arguments]  ${pattern}  ${connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns the dist names of baseband modules excluding items matching the given product name pattern.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | pattern                |  Yes  | Pattern of baseband module product name that will be excluded.            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | connection             |  No  | Name of admin connection object.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${bbmods_param}=  admin.Get Parameters For All  class_name=BBMOD  connection=${connection}
    ${bbmod_dist_names}=  Create List
    FOR  ${bbmod_param}  IN  @{bbmods_param}
      ${status}=  Run Keyword And Return Status
      ...  Should Not Match Regexp  string=${bbmod_param['productName']}  pattern=${pattern}
      Run Keyword If  ${status}  Append To List  ${bbmod_dist_names}  ${bbmod_param['id']}
    END
    [Return]  ${bbmod_dist_names}

Get Objects Affected By CB008880
    [Arguments]  ${rat_type}  ${connection}=default
    [Documentation]
    ...  Keyword prepares list of affected objects by feature CB008880. User needs to declare global
    ...  variable RAT_IMPACT where cell ids or rat is provided.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rat_type               |  Yes  | RAT name: 5G, LTE, WCDMA or GSM.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | connection             |  No  | Name of admin connection object.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com
    ...  Last update: jakub.pachana@nokia.com

    ${affected_cells}=  Run Keyword If  '${RAT_IMPACT}'=='NONE'  Create List
    ...  ELSE IF  '${RAT_IMPACT}'=='NR'  Get Dist Names For Item Class  class_name=NRCEL  connection=${connection}
    ...  ELSE IF  "${RAT_IMPACT}"=="LTE"  Get Dist Names For Item Class  class_name=LNCEL  connection=${connection}
    ...  ELSE IF  "${RAT_IMPACT}"=="ALL"  Admin Get All Cells Ids  connection=${connection}
    ...  ELSE IF  '${RAT_IMPACT}' not in 'NRNONE'  Get Selected Cells Dist Names  cell_ids=${RAT_IMPACT}
    ${nr_cells}=  admin.Get Ids For All  class_name=NRCEL  timeout=60  connection=${connection}
    ${lte_cells}=  admin.Get Ids For All  class_name=LNCEL  timeout=60  connection=${connection}
    ${impacted_objects}=  Run Keyword If  '${rat_type}'=='NR'
    ...  Combine Lists  ${affected_cells}  ${nr_cells}
    ...  ELSE IF  '${rat_type}'=='LTE'
    ...  Combine Lists  ${affected_cells}  ${lte_cells}
    ${impacted_objects}=  Remove Duplicates  ${impacted_objects}
    ${class_names}=  Create List  NRCEL  LNCEL  WNCEL  GNCEL
    ${not_impacted_objects}=  Remove Selected Dist Names
    ...  class_names=${class_names}  dist_names=${impacted_objects}  connection=${connection}
    [Return]  ${impacted_objects}  ${not_impacted_objects}

Get Objects Affected By Isolated Rat Reset
    [Arguments]  ${rat_type}  ${connection}=default
    [Documentation]
    ...  Keyword prepares list of impacted and not impacted objects by soft rat reset.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rat_type               |  Yes  | RAT name: 5G, LTE, WCDMA or GSM.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | connection             |  No  | Name of admin connection object.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com
    ...  Last update: jakub.pachana@nokia.com

    ${nr_cells}=  admin.Get Ids For All  class_name=NRCEL  timeout=30  connection=${connection}
    ${lte_cells}=  admin.Get Ids For All  class_name=LNCEL  timeout=30  connection=${connection}
    ${wcdma_cells}=  admin.Get Ids For All  class_name=WNCEL  connection=${connection}
    ${gsm_cells}=  admin.Get Ids For All  class_name=GNCEL  connection=${connection}
    ${impacted_objects}=  Set Variable If
    ...  '${rat_type}'=='GSM'  ${gsm_cells}
    ...  '${rat_type}'=='WCDMA'  ${wcdma_cells}
    ...  '${rat_type}'=='LTE'  ${lte_cells}
    ...  '${rat_type}'=='NR'  ${nr_cells}
    ...  None
    ${impacted_objects}=  Remove Duplicates  ${impacted_objects}
    ${class_names}=  Create List  NRCEL  LNCEL  WNCEL  GNCEL  SMOD
    ${not_impacted_objects}=  Remove Selected Dist Names
    ...  class_names=${class_names}  dist_names=${impacted_objects}  connection=${connection}
    ${status}  ${assert_message}=  Run Keyword And Ignore Error
    ...  admin.Assert Any  class_name=BBMOD  parameters=productName=regex"(?i)ABI[CL]"  connection=${connection}
    ${class_names}=  Create List  RMOD  BBMOD
    ${hw_dist_names}=  Run Keyword If  "${status}"=="FAIL"
    ...  Get Dist Names For Item Class List  class_names=${class_names}  connection=${connection}
    ...  ELSE
    ...  Get Baseband Dist Names With Excluded Items  pattern=^ABI[CL]  connection=${connection}
    ${sm_dist_names}=  admin.Get Ids For All  class_name=SMOD  connection=${connection}
    ${not_impacted_objects}=  Combine Lists
    ...  ${not_impacted_objects}  ${hw_dist_names}  ${sm_dist_names}
    [Return]  ${impacted_objects}  ${not_impacted_objects}

#RAT Reset keywords (END)

Admin Configure Netconf Accounts
    [Arguments]  ${netconf_name}=xranuser  ${netconf_password}=xran-password  ${timeout}=60  ${connection}=default
    ...  ${log_to_console}=True  ${log_prefix}=${info_prefix}
    [Documentation]
    ...  Description:
    ...  Keyword configure given netconf accounts.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | netconf_name           |  No  | Name of a netconf account                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | netconf_password       |  No  | Password of a netconf account                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Timeout for operation to be completed                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | connection             |  No  | Name of admin connection object.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: jakub.pachana@nokia.com
    ...  Maintainer: jakub.pachana@nokia.com

    ${actNcYgMPlane}=  SCFC Get Object Parameter Value
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  dist_name=${mrbts_id}/MNL-1
    ...  parameter_name=actNcYgMPlane
    Return From Keyword If  '${actNcYgMPlane}'=='false'
    ${default_account}=  Create Dictionary
    ...  defaultNetconfAccountName=${netconf_name}
    ...  defaultNetconfAccountPwd=${netconf_password}
    ${account}=  Create Dictionary
    ...  id=1
    ...  defaultNetconfAccount=${default_account}
    ${accounts}=  Create List  ${account}
    Configure Netconf Accounts
    ...  unsecure_ciphering=${True}
    ...  authentication_method=NoAuthentication
    ...  accounts=${accounts}
    ...  timeout=${timeout}
    ...  connection=${connection}
    Log  ${log_prefix}Netconf Account has been configured  console=${log_to_console}
