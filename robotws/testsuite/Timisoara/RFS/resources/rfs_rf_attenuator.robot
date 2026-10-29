*** Settings ***
Documentation    Maintainer for RFS: gabriel.stanculescu@nokia.com
Library          taf.hw.rf_attenuator  WITH NAME  att
Library          taf.sbts.oam.coam.admin  WITH NAME  coam
Library          hran_bsc
Library          Collections
Library          String
Library          hran_elementmanager2g

*** Keywords ***

RF Setup Attenuator
    [Documentation]  Wrapper KW used to open connection to rf_attenuator
    ...    *AUTHOR* gabriel.stanculescu@nokia.com
    ...    | Input Parameters | Man.      | Description                                              |
    ...    | attenuator_type  |  Yes      | Possible Values: Hytem, JFW, RadioRack, TopYoung         |
    ...    | ip_addr          |  Yes      | IP address of attenuator                                 |
    ...    | att_api_port     |  Yes      | Management port to connect to attenuator                 |
    ...    | atten_ports      |  Yes      | List of attenuation ports separated by space             |
    ...    | alias            |  Yes      | alias used to identify the connection                    |
    ...    |
    ...    *RETURN VALUE*
    ...    connection alias
    ...
    ...    Example
    ...    | RF Setup Attenuator | JFW | 10.255.5.235 | 50000 | 1 2 3 4 | att1 |
    [Arguments]  ${attenuator_type}  ${ip_addr}  ${att_api_port}  ${atten_ports}  ${alias}
    ${max_value_hytem_int}=  Convert To Integer  62
    ${ports_list}=  Split String  ${atten_ports}  separator=
    ${ports_list_int}=  Create List  @{EMPTY}
    FOR  ${port}  IN  @{ports_list}
        ${port_int}=  convert to integer  ${port}
        Append To List  ${ports_list_int}  ${port_int}
    END
    Run Keyword If  '${attenuator_type.upper()}'=='HYTEM'
    ...  att.Setup Attenuator  ip_addr=${ip_addr}  port=${att_api_port}  attenuation_port_numbers=${ports_list_int}  vendor=${attenuator_type}
    ...  max_attenuation=${max_value_hytem_int}  alias=${alias}
    ...  ELSE  att.Setup Attenuator  ip_addr=${ip_addr}  port=${att_api_port}  attenuation_port_numbers=${ports_list_int}  vendor=${attenuator_type}
    ...  alias=${alias}
    [Return]  ${alias}

RF Set Attenuation on lines
    [Documentation]  Wrapper KW used to set attenuation for specific lines of attenuation
    ...    *AUTHOR* gabriel.stanculescu@nokia.com
    ...    | Input Parameters | Man.      | Description                                                                                  |
    ...    | atten_ports      |  Yes      | List of attenuation ports separated by space                                                 |
    ...    | att_values       |  Yes      | List of attenuation values separated by space (in dB) / or percentage of max att (e.g. 20%)  |
    ...    | alias            |  Yes      | alias used to identify the connection                                                        |
    ...    |
    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    | RF Set Attenuation on lines | 1 2 3 4 | 120 120 120 120 | att1 |
    ...    | RF Set Attenuation on lines | 1 2 3 4 | 100% 100% 100% 100% | att1 |
    [Arguments]  ${atten_ports}  ${att_values}  ${alias}
    Log  Setting attenuation on attenuator ${alias} port(s) ${atten_ports} to ${att_values}  console=True
    ${ports_list}=  Split String  ${atten_ports}  separator=
    ${ports_list_int}=  Create List  @{EMPTY}
    FOR  ${port}  IN  @{ports_list}
        ${port_int}=  Convert To Integer  ${port}
        Append To List  ${ports_list_int}  ${port_int}
    END
    ${att_values_list}=  Split String  ${att_values}  separator=
    FOR  ${port}  ${value}  IN ZIP  ${ports_list_int}  ${att_values_list}
        ${is_percentage_value_status}  ${return}=  Run Keyword And Ignore Error  Should Contain  ${value}  %
        ${value_to_send}=  Run Keyword If  '${is_percentage_value_status}'=='PASS'  Set Variable  ${value}
        ...  ELSE  Convert to Integer  ${value}
        att.Set Attenuation   port=${port}  value=${value_to_send}  attenuator_device=${alias}  confirm=True
        Continue For Loop If  '${is_percentage_value_status}'=='PASS'
        ${read_att}=  att.Read Attenuation   port=${port}  attenuator_device=${alias}
        ${read_att_int}=  Convert To Integer  ${read_att}
        Run Keyword If  ${value}!=${read_att_int}  Fail  Failed to set attenuation for line ${port} on connection ${alias}!
    END
    Log  Set Attenuation on lines succeeded.  console=True

RF Read Attenuation on lines
    [Documentation]  Wrapper KW used to get current attenuation values for specific lines of attenuation
    ...    *AUTHOR* gabriel.stanculescu@nokia.com
    ...    | Input Parameters | Man.      | Description                                              |
    ...    | atten_ports      |  Yes      | List of attenuation ports separated by space             |
    ...    | alias            |  Yes      | alias used to identify the connection                    |
    ...    |
    ...    *RETURN VALUE*
    ...    current_att_values_dict
    ...
    ...    Example
    ...    | RF Set Attenuation on lines | 1 2 3 4 | att1 |
    [Arguments]  ${atten_ports}  ${alias}
    ${ports_list}=  Split String  ${atten_ports}  separator=
    ${ports_list_int}=  Create List  @{EMPTY}
    ${current_att_values_dict}=  Create Dictionary
    FOR  ${port}  IN  @{ports_list}
        ${port_int}=  Convert To Integer  ${port}
        Append To List  ${ports_list_int}  ${port_int}
    END
    FOR  ${port}  IN  @{ports_list_int}
        ${read_att}=  att.Read Attenuation   port=${port}  attenuator_device=${alias}
        ${port_str}=  Convert to String  ${port}
        Set To Dictionary  ${current_att_values_dict}  ${port_str}=${read_att}
    END
    Log  Get Attenuation on lines succeeded.  console=True
    [Return]  ${current_att_values_dict}

Get RMOD Id SN mapping
    [Arguments]  ${alias}
    ${rmod_ids}=  coam.Get Ids For All  RMOD  alias=${alias}
    ${rmod_SN_rmod_Id}=  Create Dictionary
    ${rmod_Id_rmod_SN}=  Create Dictionary
    FOR  ${rmod_id}  IN  @{rmod_ids}
        ${rmod_params}=  coam.Get Parameters For  RMOD  ${rmod_id}  connection=${alias}
        Set To Dictionary  ${rmod_SN_rmod_Id}  ${rmod_params.serialNumber}=${rmod_id}
        Set To Dictionary  ${rmod_Id_rmod_SN}  ${rmod_id}=${rmod_params.serialNumber}
    END
    Set Test Variable  ${rmod_SN_rmod_Id}
    Set Test Variable  ${rmod_Id_rmod_SN}

Get Cell Internal Id CellIdentity mapping
    [Arguments]  ${cell_type}  ${alias}
    ${cellIdentity}=  Set Variable If  '${cell_type.upper()}'=='NRCEL'  nrCellIdentity
    ...  '${cell_type.upper()}'=='LNCEL'  eutraCelId
    ...  '${cell_type.upper()}'=='WNCEL'  id
    ...  '${cell_type.upper()}'=='GNCEL'  id

    ${cell_internal_ids}=  coam.Get Ids For All  ${cell_type.upper()}  alias=${alias}
    ${cell_internal_CellIdentity_mapping}=  Create Dictionary
    ${CellIdentity_cell_internal_mapping}=  Create Dictionary
    FOR  ${cell_id}  IN  @{cell_internal_ids}
        ${cell_params}=  coam.Get Parameters For  ${cell_type.upper()}  ${cell_id}  connection=${alias}
        ${cellIdentity_str}=  Convert To String  ${cell_params.${cellIdentity}}
        ${cellIdentity_str}=  Run Keyword If  '${cell_type.upper()}'=='WNCEL'  Get Cell Id for SBTS WNCEL  ${cellIdentity_str}
        ...  ELSE IF  '${cell_type.upper()}'=='GNCEL'  Get Cell Id for SBTS GNCEL  ${cellIdentity_str}  ${alias}
        ...  ELSE  Set Variable  ${cellIdentity_str}
        Set To Dictionary  ${CellIdentity_cell_internal_mapping}  ${cellIdentity_str}=${cell_id}
        Set To Dictionary  ${cell_internal_CellIdentity_mapping}  ${cell_id}=${cellIdentity_str}
    END
    Set Test Variable  ${CellIdentity_cell_internal_mapping}
    Set Test Variable  ${cell_internal_CellIdentity_mapping}

Get Cell ANTLN relation
    [Arguments]  ${cell_type}  ${alias}
    Get Cell Internal Id CellIdentity mapping  ${cell_type}  ${alias}
    ${cell_type_arg}=  Set Variable If  '${cell_type.upper()}' == 'NRCEL'  nr
    ...  '${cell_type.upper()}' == 'LNCEL'  lte
    ...  '${cell_type.upper()}' == 'WNCEL'  wcdma
    ...  '${cell_type.upper()}' == 'GNCEL'  gsm
    ${resp}=  coam.Get Cells Info  cell_type=${cell_type_arg}  connection=${alias}
    ${Cell_ANTL_mapping}=  Create Dictionary
    FOR  ${cell_params}  IN  @{resp}
        ${current_cell_type}=  Fetch From Right  ${cell_params['id']['internal']}  /
        ${status}=  Run Keyword And Return Status  Should Contain  ${current_cell_type}  ${cell_type}
        Continue For Loop If  not ${status}
        ${current_cell_antls}=  Get Cell Carrier List  ${cell_params['carrierList']}  ${alias}
        Sort List  ${current_cell_antls}
        Set To Dictionary  ${Cell_ANTL_mapping}  ${cell_internal_CellIdentity_mapping["${cell_params['id']['internal']}"]}=${current_cell_antls}
    END
    [Return]  ${Cell_ANTL_mapping}

Get Cell Carrier List
    [Arguments]  ${carrier_list}  ${alias}
    Get RMOD Id SN mapping  ${alias}
    ${current_cell_antls}=  Create List  @{EMPTY}
    FOR  ${carrier}  IN  @{carrier_list}
        ${rmod_id}=  Fetch From Left  ${carrier['antennaLineId']['internal']}  /ANTL_R-
        ${rmod_id}=  Run Keyword If  '${rmod_id}'=='${carrier['antennaLineId']['internal']}'
        ...  Fetch From Left  ${carrier['antennaLineId']['internal']}  /PHYANT_R-
        ...  ELSE  Set Variable  ${rmod_id}
        ${antl_number}=  Fetch From Right  ${carrier['antennaLineId']['internal']}  /ANTL_R-
        ${antl_number}=  Run Keyword If  '${antl_number}'=='${carrier['antennaLineId']['internal']}'
        ...  Fetch From Right  ${carrier['antennaLineId']['internal']}  /PHYANT_R-
        ...  ELSE  Set Variable  ${antl_number}
        Append To List  ${current_cell_antls}  ${rmod_Id_rmod_SN["${rmod_id}"]}_${antl_number}
        ${current_cell_antls}=  Remove Duplicates  ${current_cell_antls}
    END
    [Return]  ${current_cell_antls}

Get Cell Id for SBTS WNCEL
    [Arguments]  ${internal_cellIdentity}
    ${wcdma_global_cell_id}=  Fetch From Right  ${internal_cellIdentity}  /WNCEL_R-
    [Return]  ${wcdma_global_cell_id}

Get Cell Id for SBTS GNCEL
    [Arguments]  ${internal_cellIdentity}  ${alias}
    Open connection to BSC
    ${cells_id_list}=  Run Keyword If  '${MASTER['MASTER_TECH']}' == 'SBTS'   hran_bsc.get gsm cells ids  ${MASTER['BCF_ID']}
    ...  ELSE IF  '${SLAVE['SLAVE_TECH']}' == 'SBTS'   hran_bsc.get gsm cells ids  ${SLAVE['BCF_ID']}
    ${sector_id_list}=  Run Keyword If  '${MASTER['MASTER_TECH']}' == 'SBTS'   hran_bsc.get sectors ids  ${MASTER['BCF_ID']}
    ...  ELSE IF  '${SLAVE['SLAVE_TECH']}' == 'SBTS'   hran_bsc.get sectors ids  ${SLAVE['BCF_ID']}
    ${gsm_sector_cell_mapping}=  Create Dictionary
    FOR  ${cell}  ${sector}  IN ZIP  ${cells_id_list}  ${sector_id_list}
        ${sector_nb}=  Fetch From Right  ${sector}  BTS-
        ${sector_int}=  Convert to Integer  ${sector_nb}
        ${sector_str}=  Convert to String  ${sector_int}
        Set To Dictionary  ${gsm_sector_cell_mapping}  ${sector_str}=${cell}
    END
    Set Test Variable  ${gsm_sector_cell_mapping}
    ${resp}=  coam.Get Cells Info  cell_type=gsm  connection=${alias}
    FOR  ${cell_params}  IN  @{resp}
        ${current_cell}=  Set Variable  ${cell_params['id']['internal']}
        Continue For Loop If  '${cell_params['id']['internal']}' != '${internal_cellIdentity}'
        ${current_sector}=  Set Variable  ${cell_params['gsmSectorID']}
        Return From Keyword  ${gsm_sector_cell_mapping["${current_sector}"]}
    END
    [Teardown]  hran_bsc.Close Connection

Set Cell Attenuation
    [Documentation]
    ...    Set specific cell attenuation value
    ...    *AUTHOR* gabriel.stanculescu@nokia.com
    ...    | Input Parameters                   | Man.  | Description                                                                     |
    ...    | cell_id                            | Yes   | NR - nrCellIdentity; LTE - eutraCelId; WCDMA - Global Cell Id; GSM - Cell CI    |
    ...    | atten_value                        | Yes   | programmable attenuator value you want to set - percent of max attenuation      |
    ...    | tech                               | Yes   | Techno of cell to be attenuated                                                 |
    ...    | alias                              | Yes   | Alias for admin connection                                                      |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Set Cell Attenuation  | 13154 | 30 | LTE | Slave |
    [Arguments]    ${cell_id}    ${atten_value}    ${tech}    ${alias}
    Run Keyword If  '${atten_value}'=='0'  Log  Setting optimal signal level attenuation for cell ${cell_id}   console=True
    ...  ELSE  Log  Setting cell ${cell_id} attenuation to ${atten_value}   console=True
    ${tech}=  Set Variable If  'NR' in '${tech}'  NR  'LTE' in '${tech}'  LTE  'WCDMA' in '${tech}'  WCDMA  'GSM' in '${tech}'  GSM
    ${cell_type}=  Set Variable If  '${tech}' == 'NR'  NRCEL
    ...  '${tech}' == 'LTE'  LNCEL
    ...  '${tech}' == 'WCDMA'  WNCEL
    ...  '${tech}' == 'GSM'  GNCEL
    Get Cell Internal Id CellIdentity mapping  ${cell_type}  ${alias}
    ${Cell_ANTL_mapping}=  Get Cell ANTLN relation  ${cell_type}  ${alias}
    ${atnls}=  Get From Dictionary  ${Cell_ANTL_mapping}  ${cell_id}
    FOR    ${antln}    IN    @{atnls}
	    ${RMOD_SN}=  Fetch From Left  ${antln}  _
	    ${antena_line}=  Fetch From Right  ${antln}  _
        Set Att on Specific Antln  ${RMOD_SN}  ${antena_line}  ${atten_value}  ${PA_${tech.upper()}}
    END

Cut Cells Signal
    [Documentation]
    ...    Set max attenuation for all cells from specific technology
    ...    *AUTHOR* gabriel.stanculescu@nokia.com
    ...    | Input Parameters                   | Man.  | Description                                                                         |
    ...    | tech                               | Yes   | Techno of cells to be attenuated                                                    |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    [Arguments]    ${tech}
    Log  Setting cell max attenuation for ${tech}   console=True
    ${tech}=  Set Variable If  'NR' in '${tech}'  NR  'LTE' in '${tech}'  LTE  'WCDMA' in '${tech}'  WCDMA  'GSM' in '${tech}'  GSM
    FOR  ${Attenuator}  IN  @{PA_${tech.upper()}}
        ${Attenuator}=  Set Variable  ${PA_${tech.upper()}}[${Attenuator}]
        ${alias_conn}=  RF Setup Attenuator  ${Attenuator["type"]}  ${Attenuator["ip"]}  ${Attenuator["port"]}  ${Attenuator["atten_ports"]}
        ...  ATT_${Attenuator["ip"]}
        ${atten_ports_list}=  Split String   ${Attenuator["atten_ports"]}  separator=
        ${max_att_str}=  Prepare max att  ${atten_ports_list}
    RF Set Attenuation on lines   ${Attenuator["atten_ports"]}  ${max_att_str}  ${alias_conn}
    END

Prepare max att
    [Arguments]  ${atten_ports_list}
    ${max_att_str}=  Set Variable
    FOR  ${line}  IN  @{atten_ports_list}
        ${max_att_str}=  Catenate  ${max_att_str}  100%  ${SPACE}
    END
    [Return]  ${max_att_str}

Open Specific Cell Signal and Cut Others
    [Documentation]
    ...    Close other ANTL signal, just open attached cell ANTL Signal
    ...    *AUTHOR* gabriel.stanculescu@nokia.com
    ...    | Input Parameters | Man. | Description                                             |
    ...    | cell_ID          | Yes  | cell id whose signal will be opened                     |
    ...    | tech             | Yes  | Techno of cells to be attenuated                        |
    ...    | alias            | Yes  | Alias for admin connection                              |
    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    | Open Specific Cell Signal and Cut Others | 13154 | LTE | Slave |
    [Arguments]    ${cell_ID}  ${tech}  ${alias}
    ${tech}=  Set Variable If  'NR' in '${tech}'  NR  'LTE' in '${tech}'  LTE  'WCDMA' in '${tech}'  WCDMA  'GSM' in '${tech}'  GSM
    ${cell_type}=  Set Variable If  '${tech}' == 'NR'  NRCEL
    ...  '${tech}' == 'LTE'  LNCEL
    ...  '${tech}' == 'WCDMA'  WNCEL
    ...  '${tech}' == 'GSM'  GNCEL
    Get Cell Internal Id CellIdentity mapping  ${cell_type}  ${alias}
    ${cell_ids_list}=  Set Variable  ${CellIdentity_cell_internal_mapping.keys()}
    Remove Values From List  ${cell_ids_list}  ${cell_ID}
    ${cell_ids}=  Set Variable
    FOR  ${cell}  IN  @{cell_ids_list}
        ${cell_ids}=  Catenate  ${cell_ids}  ${cell}  ${SPACE}
    END
    Cut Cells Signal  ${tech}
    Set Cell Attenuation  ${cell_id}  0  ${tech}  ${alias}

Set Att on Specific Antln
    [Arguments]  ${RMOD_SN}  ${antena_line}  ${atten_value}  ${Attenuators}
    ${att_lines_found}=  Set Variable  ${FALSE}
    FOR  ${Att}  IN  @{Attenuators}
        ${Attenuator}=  Set Variable  ${Attenuators["${Att}"]}
        ${status}=  Run Keyword And Return Status    Variable Should Exist    ${Attenuator["ants"]["${RMOD_SN}"]["ANT${antena_line}"]}
        Continue For Loop If   not ${status}
        ${att_lines_found}=  Set Variable  ${TRUE}
        ${alias_conn}=  RF Setup Attenuator  ${Attenuator["type"]}  ${Attenuator["ip"]}  ${Attenuator["port"]}  ${Attenuator["atten_ports"]}
        ...  ATT_${Attenuator["ip"]}
        ${atten_lines}=  Convert To String  ${Attenuator["ants"]["${RMOD_SN}"]["ANT${antena_line}"]}
        ${atten_lines_lst}=  Split String  ${atten_lines}  separator=
        ${atten_lines_lst_len}=  Get Length  ${atten_lines_lst}
        ${atten_values}=  Multiply Value in String  ${atten_value}  ${atten_lines_lst_len}
        ${atten_values}=  Evaluate Start Att Values  ${Attenuator}  ${atten_lines}  ${atten_values}
        RF Set Attenuation on lines  ${atten_lines}  ${atten_values}  ${alias_conn}
    END
    Run Keyword If  not ${att_lines_found}  Fail  No attenuator defined for antena line: ${antena_line}!

Trigger Handover Between Two Cells
    [Documentation]
    ...    KW used to trigger handover between two cells by attenuating source cell
    ...    and deattenuating target cell with a specific step
    ...    *AUTHOR* gabriel.stanculescu@nokia.com
    ...    | Input Parameters | Man. | Description                                             |
    ...    | cell_ID_Source   | Yes  | cell id of source cell                                  |
    ...    | cell_ID_Target   | Yes  | cell id of target cell                                  |
    ...    | source_min_att   | Yes  | Source cell min attenuation to start from               |
    ...    | source_max_att   | Yes  | Source cell max attenuation to reach                    |
    ...    | target_min_att   | Yes  | Target cell min attenuation to reach                    |
    ...    | target_max_att   | Yes  | Target cell min attenuation to start from               |
    ...    | tech             | Yes  | Techno of cells to be attenuated                        |
    ...    | alias            | Yes  | Alias for admin connection                              |
    ...    | step             | No   | Attenuation step. Default value: 1                      |
    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    | Trigger Handover Between Two Cells | 13154 | 13155 | 10 | 100 | 10 | 100 | LTE | Slave | 5 |
    [Arguments]  ${cell_ID_Source}  ${cell_ID_Target}  ${source_min_att}  ${source_max_att}  ${target_min_att}  ${target_max_att}
    ...  ${tech}  ${alias}  ${step}=1
    Log  Starting handover from cell ${cell_ID_Source} to cell ${cell_ID_Target}  console=True
    ${tech}=  Set Variable If  'NR' in '${tech}'  NR  'LTE' in '${tech}'  LTE  'WCDMA' in '${tech}'  WCDMA  'GSM' in '${tech}'  GSM
    ${src_interval}=  Evaluate  (${source_max_att}-${source_min_att})/${step}
    ${tgt_interval}=  Evaluate  (${target_max_att}-${target_min_att})/${step}
    ${max_att_interval}=  Set Variable If  ${src_interval}>${tgt_interval}  ${src_interval}  ${tgt_interval}
    ${current_att_src}=  Set Variable  ${source_min_att}
    ${current_att_tgt}=  Set Variable  ${target_max_att}
    FOR  ${index}  IN RANGE  ${max_att_interval}+2
        ${current_att_src_str}=  Convert To String  ${current_att_src}
        ${current_att_tgt_str}=  Convert To String  ${current_att_tgt}
        Run Keyword If  ${current_att_src}<${source_max_att}
        ...  Set Cell Attenuation  ${cell_ID_Source}  ${current_att_src_str}  ${tech}  ${alias}
        Run Keyword If  ${current_att_tgt}>${target_min_att}
        ...  Set Cell Attenuation  ${cell_ID_Target}  ${current_att_tgt_str}  ${tech}  ${alias}
        ${current_att_src}=  Evaluate  ${current_att_src}+${step}
        ${current_att_tgt}=  Evaluate  ${current_att_tgt}-${step}
        Sleep  1s
    END
    Log  Handover from cell ${cell_ID_Source} to cell ${cell_ID_Target} finished!  console=True

Multiply Value in String
    [Arguments]  ${value}  ${times}
    ${output_str}=  Set Variable  ${value}
    FOR  ${index}  IN RANGE  ${times}-1
        ${output_str}=  Catenate  ${output_str}  ${value}  ${SPACE}
    END
    [Return]  ${output_str}

Close All Cell ANTL Signal
    [Arguments]  ${BACKUP_SCF_PATH}  ${TECHNO}  ${cells_list}
    Log  Not implemented ${BACKUP_SCF_PATH} ${TECHNO} ${cells_list}  console=True

Set Cell PA
    [Arguments]  ${CELL_LIST}  ${VALUE}  ${BACKUP_SCF_PATH}  ${TECHNO}
    Log  Not implemented ${CELL_LIST} ${VALUE} ${BACKUP_SCF_PATH} ${TECHNO}  console=True

Evaluate Start Att Values
    [Documentation]
    ...    Based on start_att values defined in pa.yaml, change the zero values to start att values
    ...    *AUTHOR*  gabriel.stanculescu@nokia.com
    ...    | Input Parameters | Man. | Description                                             |
    ...    | Attenuator       | Yes  | Attenuator object from pa.yaml                          |
    ...    | atten_lines      | Yes  | Attenuation lines on which change is applied            |
    ...    | atten_values     | Yes  | Attenuation values added on lines defined above         |

    ...    *RETURN VALUE*
    ...    atten_values_modif
    ...
    [Arguments]  ${Attenuator}  ${atten_lines}  ${atten_values}
    ${start_att_exists}=  Run Keyword And Return Status    Variable Should Exist    ${Attenuator["start_att"]}
    Run Keyword If  not ${start_att_exists}  Return From Keyword  ${atten_values}
    ${start_att}=  Convert To String  ${Attenuator["start_att"]}
    ${atten_ports}=  Convert To String  ${Attenuator["atten_ports"]}
    ${atten_lines}=  Convert To String  ${atten_lines}
    ${atten_ports_lst}=  Split String  ${atten_ports}  separator=
    ${start_att_lst}=  Split String  ${start_att}  separator=
    ${atten_lines_lst}=  Split String  ${atten_lines}  separator=
    ${atten_values_lst}=  Split String  ${atten_values}  separator=
    ${atten_values_modif}=  Set Variable  ${EMPTY}
    FOR  ${atten_line}  ${atten_value}  IN ZIP  ${atten_lines_lst}  ${atten_values_lst}
        ${atten_values_modif}=  Run Keyword If  '${atten_value}'!='0'  Catenate  SEPARATOR=${SPACE}  ${atten_values_modif}  ${atten_value}
        ...  ELSE  Set Variable  ${atten_values_modif}
        Run Keyword If  '${atten_value}'!='0'  Continue For Loop
        ${idx}=  Get Index From List  ${atten_ports_lst}  ${atten_line}
        ${start_att}=  Get From List  ${start_att_lst}  ${idx}
        ${atten_value_int}=  Convert To Integer  ${atten_value}
        ${atten_value_int}=  Evaluate  ${atten_value_int}+${start_att}
        ${atten_value_str}=  Convert To String  ${atten_value_int}
        ${atten_values_modif}=  Catenate  SEPARATOR=${SPACE}  ${atten_values_modif}  ${atten_value_str}
    END
    [Return]  ${atten_values_modif}




