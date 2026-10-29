*** Settings ***
Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    DateTime
Library    taf.sbts.oam.coam.admin    WITH NAME    coam

*** Variables ***

*** Keywords ***
Generate SBTS Suite Log Path
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=1min
    ${ts_name}    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Create directory    ${suite_log_path}

Get distname for RMOD_R
    [Arguments]    ${connection}=GNB_OAM
    &{hw_info}       coam.get_detected_hw_info    connection=${connection}
    ${rmod_info}    set variable    ${hw_info.radioModules.rmod}
    ${ru_index_list}    create list
    &{RMOD_Distname_dict}=   create dictionary
    FOR  ${ru}  IN  @{rmod_info}
        ${ru_id_configuration}  set variable  ${ru.id.configuration}
        ${ru_id_runtime}  set variable  ${ru.id.runtime}
        ${ru_index}    get regexp matches    ${ru_id_configuration}    RMOD-(.)    1
        append to list    ${ru_index_list}    ${ru_index[0]}
        set to dictionary       ${RMOD_Distname_dict}    ${ru_index[0]}    ${ru_id_runtime}
    END
    [Return]  ${RMOD_Distname_dict}

Get Cablink Info List
    [Arguments]    ${connection}=GNB_OAM
    &{hw_info}       coam.get_detected_hw_info    connection=${connection}
    ${cables_info}    set variable    ${hw_info.cables}
    ${cables_info_list}    create list
    FOR    ${cables}    IN    @{cables_info}
        ${RF_port}  Get Substring  ${cables['firstEndPointId']['configuration']}  -1
        @{confobjectname}  string.split string    ${cables['id']['configuration']}    separator=/
        ${item}  create dictionary  physical_port=${RF_port}
        ...     objectname=@{confobjectname}[-1]
        ...     linkSpeed=${cables['linkSpeed']}
        ...     synchronization=${cables['linkMode']['synchronization']}
        ...     status=${cables['status']['operationalState']}
        append to list    ${cables_info_list}    ${item}
    END
    [Return]   ${cables_info_list}

Coam Get FSM operationalState and Name
    [Arguments]  ${connection}=GNB_OAM
    ${output}=    coam.get_fsm_info    timeout=30    connection=${connection}
    ${FSM_operationalState_list}    create list
    ${FSM_name_list}    create list
    FOR    ${elem}    IN    @{output}
        append to list  ${FSM_operationalState_list}  ${elem['status']['operationalState']}
        append to list  ${FSM_name_list}  ${elem['productName']}
    END
    [Return]  ${FSM_operationalState_list}  ${FSM_name_list}

Coam Get FBB operationalState and Name
    [Arguments]  ${connection}=GNB_OAM
    ${output}=    coam.get_fbb_info    timeout=30    connection=${connection}
    ${FBB_operationalState_list}    create list
    ${FBB_name_list}    create list
    FOR    ${elem}    IN    @{output}
        append to list  ${FBB_operationalState_list}  ${elem['status']['operationalState']}
        append to list  ${FBB_name_list}  ${elem['productName']}
    END
    [Return]  ${FBB_operationalState_list}  ${FBB_name_list}

Perform SW Update
    [Arguments]  ${package}  ${connection}=GNB_OAM
    coam.update_software     sw_package=${package}     should_activate=True    timeout=2400   connection=${connection}
    sleep    2min

Cell Status Info Should Be Enable
    [Arguments]    ${ru_index}=${None}    ${cell_index}=${None}
    ...            ${cell_type}=lte    ${stream}=SBTS00  ${connection}=GNB_OAM
    ${cell_info_list}    Get All Cells Status Info    cell_type=${cell_type}    connection=${connection}
    ${os}    Set Variable If    '${stream}'=='SBTS00'    enabled    Enabled
    ${as}    Set Variable If    '${cell_type}'=='lte'    unlocked    Unlocked
    FOR  ${cell}  IN  @{cell_info_list}
        Should Be Equal As Strings   ${cell["operationalState"]}    ${os}
        Should Be Equal As Strings   ${cell["administrativeState"]}    ${as}
        Should Be Equal As Strings   ${cell["blockingState"]}    Unblocked
    END

Cell Status Info Should Be Disabled
    [Arguments]    ${ru_index}=${None}    ${cell_index}=${None}
    ...            ${cell_type}=lte    ${stream}=SBTS00  ${connection}=GNB_OAM
    ${cell_info_list}    Get All Cells Status Info    cell_type=${cell_type}    connection=${connection}
    ${os}    Set Variable If    '${stream}'=='SBTS00'    disabled    Disabled
    ${as}    Set Variable If    '${cell_type}'=='lte'    unlocked    Unlocked
    ${bs}    Set Variable If    '${stream}'=='SBTS00'    Blocked    Unblocked
    FOR  ${cell}  IN  @{cell_info_list}
        Should Be Equal As Strings   ${cell["operationalState"]}    ${os}
        Should Be Equal As Strings   ${cell["administrativeState"]}    ${as}
        Should Be Equal As Strings   ${cell["blockingState"]}    ${bs}
    END

Get All Cells Status Info
    [Arguments]    ${cell_type}=lte  ${connection}=GNB_OAM
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    ${cell_info_list}    create list
    FOR    ${cell}    IN    @{cells_info}
        @{ru_id}  string.split string    ${cell['carrierList'][0]['antennaLineId']['configuration']}    separator=/
        ${ru_id}  Get Substring  @{ru_id}[-2]  -1
        ${item}  create dictionary  ru_index=${ru_id}
        ...     cell_index=${cell['globalCellId']}
        ...     operationalState=${cell['status']['operationalState']}
        ...     administrativeState=${cell['status']['administrativeState']}
        ...     blockingState=${cell['status']['blockingState']}
        append to list    ${cell_info_list}    ${item}
    END
    [Return]   ${cell_info_list}

Expect Fault Should Present on WebUI
    [Arguments]    ${faultId}    ${source}=${None}    ${severity}=${None}    ${alarmId}=${None}
    ...            ${configObjectName}=${None}    ${connection}=GNB_OAM
    ${faultId}    Convert To Integer    ${faultId}
    @{alarms}    coam.get_active_alarms    connection=${connection}
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
       Exit For Loop If    ${alarm_num}==${0}
       ${present_status}    Run Keyword And Return Status    Run Keywords
                  ...                      Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
                  ...                      Run Keyword If    '${source}'!='${None}'
                  ...                      Should Contain     ${alarm['notifier']}    ${source}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${severity}'!='${None}'
                  ...                      Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${alarmId}'!='${None}'
                  ...                      Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}    AND
                  ...                      Run Keyword If    '${config_object_name}'!='${None}'
                  ...                      Should Contain    ${alarm['configObjectName']}    ${config_object_name}
      Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.

Expect Fault Should Absent on WebUI
    [Arguments]   ${faultId}   ${source}=${None}   ${connection}=GNB_OAM
    ${status}    Run Keyword And Return Status   Expect Fault Should Present on WebUI   faultId=${faultId}
    ...                                                                        source=${source}
    ...                                                                        connection=${connection}
    Run Keyword If  ${status}==${True}   Fail   faultId ${faultId} reported by source ${source} is still present on gnb.
