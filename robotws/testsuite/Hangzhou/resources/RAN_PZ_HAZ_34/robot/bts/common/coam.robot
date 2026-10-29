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
        Run Keyword If    '${cables['status']['operationalState']}'=='disabled'    Continue For Loop
        @{bbmod_cablink}  string.split string    ${cables['firstEndPointId']['configuration']}    separator=/
        @{ru_cablink}  string.split string    ${cables['secondEndPointId']['configuration']}    separator=/
        @{confobjectname}  string.split string    ${cables['id']['configuration']}    separator=/
        ${item}  create dictionary  bbmod_enable_port=${bbmod_cablink}[-2]/${bbmod_cablink}[-1]
        ...     ru_enable_port=${ru_cablink}[-2]/${ru_cablink}[-1]
        ...     objectname=${confobjectname}[-1]
        ...     linkSpeed=${cables['linkSpeed']}
        ...     synchronization=${cables['linkMode']['synchronization']}
        ...     status=${cables['status']['operationalState']}
        append to list    ${cables_info_list}    ${item}
    END
    [Return]   ${cables_info_list}

Get BBMOD Status List
    [Arguments]    ${connection}=GNB_OAM
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_bbmods}    Set variable    ${hw_info['basebandModules']}
    ${count_bbmods}    Get length    ${list_bbmods}
    Should be true    ${count_bbmods}>=${1}    msg=Check BBMOD status failed as total BBMOD number is less than 1
    ${bbmod_status_list}    create list
    FOR  ${bbmod}  IN  @{list_bbmods}
        ${item}  create dictionary  administrativeState=${bbmod['status']['administrativeState']}
        ...     operationalState=${bbmod['status']['operationalState']}
        ...     proceduralStatus=${bbmod['status']['proceduralStatus']}
        append to list    ${bbmod_status_list}    ${item}
    END
    [Return]   ${bbmod_status_list}

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

get sfp info list
    [Arguments]  ${connection}=GNB_OAM
	${links}    coam.get_sfp_links   timeout=20    connection=${connection}
	${link_ports_list}    set variable    ${links['connected']}
    ${sfp_info_list}    create list
    FOR  ${link}  IN  @{link_ports_list}
        ${sfp_type_dest}    get sfp type by product code
        ...     product_code=${link['details']['hardwareParameters']['productCode']['destination']}
        ${item}  create dictionary  linkPort=${link['data']['linkPorts']['destination']}
        ...     sfp_type=${sfp_type_dest}
        ...     vendor=${link['details']['hardwareParameters']['vendor']['destination']}
        ...     cooled=${link['details']['staticParameters']['cooledTransceiverDeclaration']['destination']}
        append to list    ${sfp_info_list}    ${item}
        ${sfp_type_source}    get sfp type by product code
        ...     product_code=${link['details']['hardwareParameters']['productCode']['source']}
        ${item}  create dictionary  linkPort=${link['data']['linkPorts']['source']}
        ...     sfp_type=${sfp_type_source}
        ...     vendor=${link['details']['hardwareParameters']['vendor']['source']}
        ...     cooled=${link['details']['staticParameters']['cooledTransceiverDeclaration']['source']}
        append to list    ${sfp_info_list}    ${item}
    END
    [Return]   ${sfp_info_list}

get sfp type by product code
    [Arguments]    ${product_code}
    ${sfp_type}    set variable if    '${product_code}'=='475339A'    AOSK
    ...    '${product_code}'=='474902A'    AOSD
    ...    '${product_code}'=='474908A'    AOXC
    ...    '${product_code}'=='474909A'    AOXD
    ...    Undefined
    [Return]   ${sfp_type}

Perform SW Update
    [Arguments]  ${package}  ${connection}=GNB_OAM
    coam.update_software     sw_package=${package}     should_activate=True    timeout=2400   connection=${connection}
    sleep    2min

Check All BBMOD status
    [Arguments]    ${as}=Unlocked  ${connection}=GNB_OAM
    ${bbmod_status_list}    Get BBMOD Status List    connection=${connection}
    FOR  ${bbmod}  IN  @{bbmod_status_list}
        Should Be Equal As Strings   ${bbmod["operationalState"]}    enabled
        Should Be Equal As Strings   ${bbmod["administrativeState"]}    ${as}
        Should Be Equal As Strings   ${bbmod["proceduralStatus"]}    configured
    END

Cell Status Info Should Be Enable
    [Arguments]    ${ru_index}=${None}    ${cell_index}=${None}
    ...            ${cell_type}=lte    ${boundary}=new_version  ${connection}=GNB_OAM
    ${cell_info_list}    Get All Cells Status Info    cell_type=${cell_type}    connection=${connection}
    ${os}    Set Variable If    '${boundary}'=='new_version'     enabled    Enabled
    ${as}    Set Variable If    '${cell_type}'=='lte'    unlocked    Unlocked
    FOR  ${cell}  IN  @{cell_info_list}
        Should Be Equal As Strings   ${cell["operationalState"]}    ${os}
        Should Be Equal As Strings   ${cell["administrativeState"]}    ${as}
        Should Be Equal As Strings   ${cell["blockingState"]}    Unblocked
    END

Cell Status Info Should Be Disabled
    [Arguments]    ${ru_index}=${None}    ${cell_index}=${None}    ${bs_blocked}=Blocked
    ...            ${cell_type}=lte    ${boundary}=new_version  ${connection}=GNB_OAM
    ${cell_info_list}    Get All Cells Status Info    cell_type=${cell_type}    connection=${connection}
    ${os}    Set Variable If    '${boundary}'=='new_version'    disabled    Disabled
    ${as}    Set Variable If    '${cell_type}'=='lte'    unlocked    Unlocked
    ${bs}    Set Variable If    '${boundary}'=='new_version'    ${bs_blocked}    Unblocked
    FOR  ${cell}  IN  @{cell_info_list}
        Should Be Equal As Strings   ${cell["operationalState"]}    ${os}
        Should Be Equal As Strings   ${cell["administrativeState"]}    ${as}
        Should Be Equal As Strings   ${cell["blockingState"]}    ${bs}
    END

Cell Status Info Should Be locked
    [Arguments]    ${cell_type}=lte    ${boundary}=new_version  ${connection}=GNB_OAM
    ${cell_info_list}    Get All Cells Status Info    cell_type=${cell_type}    connection=${connection}
    ${os}    Set Variable If    '${boundary}'=='new_version'    disabled    Disabled
    ${as}    Set Variable If    '${cell_type}'=='lte'    locked    Locked
    ${bs}    Set Variable If    '${boundary}'=='new_version'    Unblocked    Unblocked
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
        ${ru_id}  Get Substring  ${ru_id}[-2]  -1
        ${status_as}    run keyword and return status     Dictionary Should Contain Key
        ...    ${cell['status']}    availabilityStatus
        ${availabilityStatus}    Run keyword if    ${status_as}==${True}
        ...    set variable    ${cell['status']['availabilityStatus']}    ELSE    set variable    -
        ${status_ps}    run keyword and return status     Dictionary Should Contain Key
        ...    ${cell['status']}    proceduralStatus
        ${proceduralStatus}    Run keyword if    ${status_ps}==${True}
        ...    set variable    ${cell['status']['proceduralStatus']}    ELSE    set variable    -
        ${status_bs}    run keyword and return status     Dictionary Should Contain Key
        ...    ${cell['status']}    barringStatus
        ${barringStatus}    Run keyword if    ${status_bs}==${True}
        ...    set variable    ${cell['status']['barringStatus']}    ELSE    set variable    -
        ${item}  create dictionary  ru_index=${ru_id}
        ...     cell_index=${cell['globalCellId']}
        ...     operationalState=${cell['status']['operationalState']}
        ...     availabilityStatus=${availabilityStatus}
        ...     administrativeState=${cell['status']['administrativeState']}
        ...     usageState=${cell['status']['usageState']}
        ...     blockingState=${cell['status']['blockingState']}
        ...     proceduralStatus=${proceduralStatus}
        ...     barringStatus=${barringStatus}
        ...     energySavingState=${cell['energySavingState']}
        append to list    ${cell_info_list}    ${item}
    END
    [Return]   ${cell_info_list}

Get All RUs Status Info
    [Arguments]    ${connection}=GNB_OAM
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${ru_info_list}    create list
    FOR    ${RU}    IN    @{list_RUs}
        ${config_rmod}    Set variable    ${RU['id']['configuration']}
        ${rmod_index}    Fetch from right    ${config_rmod}    RMOD-
        ${status_as}    run keyword and return status     Dictionary Should Contain Key
        ...    ${RU['status']}    availabilityStatus
        ${availabilityStatus}    Run keyword if    ${status_as}==${True}
        ...    set variable    ${RU['status']['availabilityStatus']}    ELSE    set variable    -
        ${item}  create dictionary  ru_index=${rmod_index}
        ...     productName=${RU['productName']}
        ...     operationalState=${RU['status']['operationalState']}
        ...     availabilityStatus=${availabilityStatus}
        ...     administrativeState=${RU['status']['administrativeState']}
        ...     usageState=${RU['status']['usageState']}
        ...     proceduralStatus=${RU['status']['proceduralStatus']}
        ...     powerState=${RU['status']['powerState']}
        append to list    ${ru_info_list}    ${item}
    END
    [Return]  ${ru_info_list}

Cell Status Info Should Be Energy Saving State
    [Arguments]    ${cell_index}=${None}  ${connection}=GNB_OAM
    log to console  \nCell Status Should Be Energy Saving State
    ${cell_info_list}    Get All Cells Status Info    cell_type=${cell_type}    connection=${connection}
    FOR  ${cell}  IN  @{cell_info_list}
        Run Keyword If    ${cell["cell_index"]}!=${cell_index} and ${cell_index}!=${None}     Continue For Loop
        Should Be Equal As Strings   ${cell["energySavingState"]}    energySaving
        Should Be Equal As Strings   ${cell["operationalState"]}    disabled
        Should Be Equal As Strings   ${cell["availabilityStatus"]}    off line
        Should Be Equal As Strings   ${cell["usageState"]}    Idle
    END

Cell Status Info Should Be Not Energy Saving State
    [Arguments]    ${cell_index}=${None}  ${connection}=GNB_OAM
    log to console  \nCell Status Should Be Not Energy Saving State
    ${cell_info_list}    Get All Cells Status Info    cell_type=${cell_type}    connection=${connection}
    FOR  ${cell}  IN  @{cell_info_list}
        Run Keyword If    ${cell["cell_index"]}!=${cell_index} and ${cell_index}!=${None}     Continue For Loop
        Should Be Equal As Strings   ${cell["energySavingState"]}    notEnergySaving
        Should Be Equal As Strings   ${cell["operationalState"]}    enabled
        Should Be Equal As Strings   ${cell["availabilityStatus"]}    -
        Should Be Equal As Strings   ${cell["usageState"]}    Active
    END

RU Status Info Should Be Normal
    [Arguments]    ${ru_index}=${None}  ${connection}=GNB_OAM
    log to console  \nRU Status Should Be Normal
    ${ru_info_list}    Get All RUs Status Info    connection=${connection}
    FOR  ${ru}  IN  @{ru_info_list}
        Run Keyword If    ${ru["ru_index"]}!=${ru_index} and ${ru_index}!=${None}     Continue For Loop
        Should Be Equal As Strings   ${ru["operationalState"]}    enabled
        Should Be Equal As Strings   ${ru["availabilityStatus"]}    -
        Should Be Equal As Strings   ${ru["usageState"]}    Active
        Should Be Equal As Strings   ${ru["proceduralStatus"]}    configured
        Should Be Equal As Strings   ${ru["powerState"]}    AWAKE
    END

RU Status Info Should Be Sleep
    [Arguments]    ${ru_index}=${None}  ${connection}=GNB_OAM
    log to console  \nRU Status Should Be Sleep
    ${ru_info_list}    Get All RUs Status Info    connection=${connection}
    FOR  ${ru}  IN  @{ru_info_list}
        Run Keyword If    ${ru["ru_index"]}!=${ru_index} and ${ru_index}!=${None}     Continue For Loop
        #Should Be Equal As Strings   ${ru["operationalState"]}    disabled
        #Should Be Equal As Strings   ${ru["availabilityStatus"]}    off line
        Should Be Equal As Strings   ${ru["usageState"]}    Idle
        #Should Be Equal As Strings   ${ru["proceduralStatus"]}    initializing
        Should Be Equal As Strings   ${ru["powerState"]}    SLEEP
    END

RU Status Info Should Be as Expect
    [Arguments]  ${ru_index}=${None}    ${connection}=GNB_OAM
    ...    ${operationalState}=${None}    ${availabilityStatus}=${None}    ${usageState}=${None}
    ...    ${proceduralStatus}=${None}    ${powerState}=${None}
    ${ru_info_list}    Get All RUs Status Info    connection=${connection}
    FOR  ${ru}  IN  @{ru_info_list}
        Run Keyword If    ${ru["ru_index"]}!=${ru_index} and ${ru_index}!=${None}     Continue For Loop
        RU Status Check    type=operationalState    status=${operationalState}    ru_status_info=${ru}
        RU Status Check    type=availabilityStatus    status=${availabilityStatus}    ru_status_info=${ru}
        RU Status Check    type=usageState    status=${usageState}    ru_status_info=${ru}
        RU Status Check    type=proceduralStatus    status=${proceduralStatus}    ru_status_info=${ru}
        RU Status Check    type=powerState    status=${powerState}    ru_status_info=${ru}
    END

RU Status Check
    [Arguments]  ${type}    ${status}    ${ru_status_info}
    Run Keyword If    '${status}'!='${None}'    run keywords
    ...    log to console    status ${type} should be ${status} real is ${ru_status_info}[${type}]   AND
    ...    Should Be Equal As Strings   ${ru_status_info}[${type}]     ${status}
    ...    msg=status of ${type} is ${ru_status_info}[${type}] not same as ${status}
    ...    ELSE    log    no need to check ${type}

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

Get All SBTS Cells Status Info classified by cellidx
    [Arguments]    ${cell_type}=lte  ${connection}=GNB_OAM
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    ${cell_info_dict}    Create Dictionary
    FOR    ${cell}    IN    @{cells_info}
        @{ru_id}  string.split string    ${cell['carrierList'][0]['antennaLineId']['configuration']}    separator=/
        ${ru_id}  Get Substring  ${ru_id}[-2]  -1
        ${item}  Create Dictionary  ru_index=${ru_id}
        ...     operationalState=${cell['status']['operationalState']}
        ...     administrativeState=${cell['status']['administrativeState']}
        ...     blockingState=${cell['status']['blockingState']}
        Set to Dictionary    ${cell_info_dict}    ${cell['globalCellId']}    ${item}
    END
    [Return]   ${cell_info_dict}

SBTS Cell Should Be Blocked
    [Arguments]    ${cell_type}=lte    ${stream}=SBTS00    ${cell_index}=${None}    ${connection}=GNB_OAM
    ${cell_info_dict}    Get All SBTS Cells Status Info classified by cellidx    cell_type=${cell_type}    connection=${connection}
    ${os}    Set Variable If    '${stream}'=='SBTS00' or '${stream}'=='SBTS22R3'    disabled    Disabled
    ${as}    Set Variable If    '${cell_type}'=='lte'    unlocked    Unlocked
    ${bs}    Set Variable If    '${stream}'=='SBTS00' or '${stream}'=='SBTS22R3'    Blocked    Blocked
    Should Be Equal As Strings   ${cell_info_dict[${cell_index}]["operationalState"]}    ${os}
    Should Be Equal As Strings   ${cell_info_dict[${cell_index}]["administrativeState"]}    ${as}
    Should Be Equal As Strings   ${cell_info_dict[${cell_index}]["blockingState"]}    ${bs}

SBTS Cell Should Be UnBlocked
    [Arguments]    ${cell_type}=lte    ${stream}=SBTS00    ${cell_index}=${None}    ${connection}=GNB_OAM
    ${cell_info_dict}    Get All SBTS Cells Status Info classified by cellidx    cell_type=${cell_type}    connection=${connection}
    ${os}    Set Variable If    '${stream}'=='SBTS00' or '${stream}'=='SBTS22R3'    enabled    Enabled
    ${as}    Set Variable If    '${cell_type}'=='lte'    unlocked    Unlocked
    ${bs}    Set Variable If    '${stream}'=='SBTS00' or '${stream}'=='SBTS22R3'    Unblocked    Unblocked
    Should Be Equal As Strings   ${cell_info_dict[${cell_index}]["operationalState"]}    ${os}
    Should Be Equal As Strings   ${cell_info_dict[${cell_index}]["administrativeState"]}    ${as}
    Should Be Equal As Strings   ${cell_info_dict[${cell_index}]["blockingState"]}    ${bs}

SBTS Block cells and check status
    [Arguments]  ${block_list}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${sbts_addr}    username=${http_username}
    ...    password=${http_password}
    log to console  \n***Block cells and check status***
    FOR    ${idx}  IN  @{block_list}
        selenium_coam.block_cell    cell_idx=${idx}    technology=${cell_type.upper()}
        Wait Until Keyword Succeeds   3 min  10 sec   coam.SBTS Cell Should Be Blocked   cell_index=${idx}
        Wait Until Keyword Succeeds   1 min  10 sec   Expect Fault Should Present on WebUI    faultId=49
    END

SBTS UnBlock Cells and check status
    [Arguments]  ${block_list}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${sbts_addr}    username=${http_username}
    ...    password=${http_password}
    log to console  \n***unLock cells and check status***
    FOR    ${idx}  IN  @{block_list}
        selenium_coam.unblock_cell    cell_idx=${idx}    technology=${cell_type.upper()}
        Wait Until Keyword Succeeds   5 min  10 sec   coam.SBTS cell should be unblocked   cell_index=${idx}
    END
    Wait For Expect Fault To Disappear  faultId=49    timeout=60
    Wait Until Keyword Succeeds   1 min  10 sec   Expect Fault Should Absent on WebUI    faultId=49
    Wait Until Keyword Succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}

SBTS Block and UnBlock Cells
    [Arguments]  ${block_list}
    SBTS Block cells and check status    block_list=${block_list}
    SBTS UnBlock Cells and check status    block_list=${block_list}
