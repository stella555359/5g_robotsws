*** Settings ***
Documentation
...     Author: krzysztof.gryga@nokia.com, rafal.janik@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com
...     Maintainer: rafal.janik@nokia.com, krzysztof.gryga@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com

Library    taf.sbts.oam.coam.admin
Library    taf.sbts.oam.coam.admin.interface

Resource    ./faults.robot

*** Variables ***
${ADMIN_BTS_HOST}=            192.168.255.1
${ADMIN_BTS_PORT}=            443
${ADMIN_USERNAME}=            Nemuadmin
${ADMIN_PASSWORD}=            nemuuser
${ADMIN_USE_SSL}=             True
${ADMIN_UPDATE_INTERVAL}=     5000
${ADMIN_API_LOG_DIR}=         ${OUTPUT_DIR}
${ADMIN_TIMEOUT}=             30
${ADMIN_ALIAS}=               default
${jenkins_url}                http://files.ute.nsn-rdnet.net/builds/enb/base/
${TRUNK_VERSION}              SBTS23R2

*** Keywords ***
ADMIN Setup Admin
    [Arguments]    ${bts_host}=${ADMIN_BTS_HOST}
    ...            ${bts_port}=${ADMIN_BTS_PORT}
    ...            ${username}=${ADMIN_USERNAME}
    ...            ${password}=${ADMIN_PASSWORD}
    ...            ${use_ssl}=${ADMIN_USE_SSL}
    ...            ${update_interval}=${ADMIN_UPDATE_INTERVAL}
    ...            ${admin_api_log_dir}=${ADMIN_API_LOG_DIR}
    ...            ${timeout}=${ADMIN_TIMEOUT}
    ...            ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Setup Admin
    ...    bts_host=${bts_host}
    ...    bts_port=${bts_port}
    ...    username=${username}
    ...    password=${password}
    ...    use_ssl=${use_ssl}
    ...    update_interval=${update_interval}
    ...    admin_api_log_dir=${admin_api_log_dir}
    ...    alias=${alias}
    ...    timeout=${timeout}

ADMIN Abort Software Update
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Abort Software Update
    ...    connection=${alias}

ADMIN Assert No Unexpected Active Alarms
    [Arguments]    ${alowed_alarms_list}=@{FAULT_ALLOWED_LIST_COR}
    ...            ${connection}=${ADMIN_ALIAS}
    ${alowed_alarms_list}=      convert to string  ${alowed_alarms_list}
    @{out_alarms_objects_list}    ADMIN Get Active Alarms   ${connection}
    FOR    ${alarm}    IN    @{out_alarms_objects_list}
        ${dict_fault_id}    Get From Dictionary    ${alarm}   faultId
        should contain    ${alowed_alarms_list}     '${dict_fault_id}'
    END

ADMIN Check If Alarm Is Active
    [Arguments]    ${fault_id}
    ...            ${connection}=${ADMIN_ALIAS}
    ${is_active}    ADMIN Is alarm active   ${fault_id}    ${connection}
    Should Be True   ${is_active}

ADMIN Check If Alarm Is Active With Timeout
    [Arguments]    ${fault_id}
    ...            ${timeout}
    wait until keyword succeeds  ${timeout}  1  ADMIN Check If Alarm Is Active  ${fault_id}

ADMIN Check If Alarm Is Not Active
    [Arguments]
    ...    ${fault_id}
    ...    ${connection}=${ADMIN_ALIAS}
    ${is_active}    ADMIN Is alarm active   ${fault_id}    ${connection}
    Should Not Be True   ${is_active}

ADMIN Check If Alarm Is Not Active With Timeout
    [Arguments]    ${fault_id}
    ...            ${timeout}
    wait until keyword succeeds  ${timeout}  1  ADMIN Check If Alarm Is Not Active  ${fault_id}

ADMIN Is alarm active
        [Arguments]
        ...    ${fault_id}
        ...    ${connection}=${ADMIN_ALIAS}
    @{out_alarms_objects_list}    ADMIN Get Active Alarms   ${connection}
    FOR    ${alarm}    IN    @{out_alarms_objects_list}
        ${dict_fault_id}    Get From Dictionary    ${alarm}    faultId
        Run Keyword If    '${dict_fault_id}' == '${fault_id}'
    ...    return from keyword    ${TRUE}
    END
    return from keyword    ${FALSE}

ADMIN Collect Scf
    [Arguments]    ${local_dir_path}
    ...            ${file_name}
    ...            ${timeout}=120
    ...            ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.get_current_scf_file    local_dir_path=${local_dir_path}
    ...                      file_name=${file_name}
    ...                      timeout=${timeout}
    ...                      connection=${alias}

ADMIN Collect Snapshot
    [Arguments]    ${snapshot_name}=${ADMIN_API_LOG_DIR}/Snapshot.zip
    ...            ${coverage}=Full
    ...            ${force}=${TRUE}
    ...            ${timeout}=1200
    #...            ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Collect Snapshot    target_file_name=${snapshot_name}
    ...                           coverage=${coverage}
    ...                           force=${force}
    ...                           timeout=${timeout}
    #...                           alias=${alias}

ADMIN Get Active Alarms
    [Arguments]    #${severity}=None
    ...            ${timeout}=120
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_alarms objects_list}=    taf.sbts.oam.coam.admin.Get Active Alarms
    ...                                                           timeout=${timeout}
    ...                                                           connection=${alias}
    [Return]    ${out_alarms objects_list}

ADMIN Get Cell Mapping By Module Id
    [Arguments]    ${module_id}
    ...            ${connector_label}=None
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_cell_id}=    taf.sbts.oam.coam.admin.Get Cell Mapping By Module Id
    ...    module_id=${module_id}
    ...    connector_label=${connector_label}
    ...    timeout=${timeout}
    ...    alias=${alias}
    [Return]    ${out_cell_id}

ADMIN Get Historic Alarms
    [Arguments]
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_alarms_objects_list}=    taf.sbts.oam.coam.admin.Get Historic Alarms
    ...    connection=${alias}
    ...    timeout=${timeout}
    [Return]    ${out_alarms_objects_list}

ADMIN Check If Alarm Is In Historical Alarms
    [Arguments]    ${fault_id}
    ...            ${connection}=${ADMIN_ALIAS}
    ${is_in_historical_alarms}    ADMIN Is Alarm in Historical Alarms
    ...    fault_id=${fault_id}
    ...    connection=${connection}
    Should Be True  ${is_in_historical_alarms}

ADMIN Check If Alarm Is Not In Historical Alarms
    [Arguments]    ${fault_id}
    ...            ${connection}=${ADMIN_ALIAS}
    ${is_in_historical_alarms}    ADMIN Is Alarm in Historical Alarms
    ...    fault_id=${fault_id}
    ...    connection=${connection}
    Should Not Be True  ${is_in_historical_alarms}

ADMIN Is Alarm in Historical Alarms
    [Arguments]    ${fault_id}
    ...            ${connection}=${ADMIN_ALIAS}
    @{out_alarms_objects_list}    ADMIN Get Historic Alarms
    ...    alias=${connection}
    FOR    ${alarm}    IN    @{out_alarms_objects_list}
        ${dict_fault_id}    Get From Dictionary    ${alarm}    faultId
        Run Keyword If    '${dict_fault_id}' == '${fault_id}'
    ...    return from keyword    ${TRUE}
    END
    return from keyword    ${False}

ADMIN Get Id For Current
    [Arguments]    ${class_name}
    ...            ${timeout}=10
    ...            ${connection}=${ADMIN_ALIAS}
    ${out_current_id}=    taf.sbts.oam.coam.admin.Get Id For Current
    ...    class_name=${class_name}
    ...    timeout=${timeout}
    ...    alias=${connection}
    [Return]    ${out_current_id}

ADMIN Get Id For Current BTS
    [Arguments]    ${connection}=${ADMIN_ALIAS}
    ${out_current_bts_id}=    ADMIN Get Id For Current
    ...    class_name=BTS
    ...    connection=${connection}
    [Return]    ${out_current_bts_id}

ADMIN Get Sw Version
    [Arguments]    ${connection}=${ADMIN_ALIAS}
    ${sw_version}=    taf.sbts.oam.coam.admin.Get Sw Version
    ...    connection=${connection}
    [Return]    ${sw_version}

ADMIN Get Parameter
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${timeout}=10
    ...            ${connection}=${ADMIN_ALIAS}
    ${out_parameters}    taf.sbts.oam.coam.admin.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=${parameter}
    ...    timeout=${timeout}
    ...    connection=${connection}
    [Return]    ${out_parameters}

ADMIN Get Parameters For All
    [Arguments]    ${class_name}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_parameters_dict}=    taf.sbts.oam.coam.admin.Get Parameters For All
    ...    class_name=${class_name}
    ...    timeout=${timeout}
    ...    alias=${alias}
    [Return]    ${out_list_of_parameters_dict}

ADMIN Get Parameters For All SMOD
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_smod_parameters_dict}=    ADMIN Get Parameters For All
    ...    class_name=SMOD
    ...    timeout=${timeout}
    ...    alias=${alias}
    [Return]    ${out_list_of_smod_parameters_dict}

ADMIN Get Parameters For All BBMODs
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_bbmods_parameters_dict}=    ADMIN Get Parameters For All
    ...    class_name=BBMOD
    ...    timeout=${timeout}
    ...    alias=${alias}
    [Return]    ${out_list_of_bbmods_parameters_dict}

ADMIN Get Parameters For All BTS
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_bts_parameters_dict}=    ADMIN Get Parameters For All
    ...    class_name=BTS
    ...    timeout=${timeout}
    ...    alias=${alias}
    [Return]    ${out_list_of_bts_parameters_dict}

ADMIN Get Parameters For All RMODs
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_rmod_parameters_dict}=    ADMIN Get Parameters For All
    ...    class_name=RMOD
    ...    timeout=${timeout}
    ...    alias=${alias}
    [Return]    ${out_list_of_rmod_parameters_dict}

ADMIN Get Parameters For All ALDs
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_ald_parameters_dict}=    ADMIN Get Parameters For All
    ...    class_name=ALD
    ...    timeout=${timeout}
    ...    alias=${alias}
    [Return]    ${out_list_of_ald_parameters_dict}

ADMIN Get Parameters For All LNCELs
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_lncel_parameters_dict}=    ADMIN Get Parameters For All
    ...    class_name=NRCEL
    ...    timeout=${timeout}
    ...    alias=${alias}
    [Return]    ${out_list_of_lncel_parameters_dict}

ADMIN Get SMOD Statuses
    [Arguments]  ${component_index}
    ${SMOD_statuses_response}=    taf.sbts.oam.coam.admin.Get Fsm Info
    [Return]    ${SMOD_statuses_response[${component_index}]['status']}

ADMIN Get BBMOD Statuses
    [Arguments]  ${component_index}
    ${BBMOD_statuses_response}=    taf.sbts.oam.coam.admin.Get Fbb Info
    [Return]    ${BBMOD_statuses_response[${component_index}]['status']}

ADMIN Get GNSS Statuses
    ${GNSS_statuses_response}=    taf.sbts.oam.coam.admin.Get Gnsses Statuses
    [Return]    ${GNSS_statuses_response['GNSSE_R-1']}

ADMIN Get RU Statuses
    [Arguments]  ${component_index}
    ${RU_statuses_response}=    taf.sbts.oam.coam.admin.Get Frm
    [Return]    ${RU_statuses_response[${component_index}]['status']}

ADMIN Get RU Configuration Id
    [Arguments]  ${component_index}
    ${RU_statuses_response}=    taf.sbts.oam.coam.admin.Get Frm
    [Return]    ${RU_statuses_response[${component_index}]['id']['configuration']}

ADMIN Get Cell Statuses
    [Arguments]  ${component_index}
    ${Cell_statuses_response}=    taf.sbts.oam.coam.admin.Get Cells Info
    [Return]    ${Cell_statuses_response[${component_index}]['status']}

ADMIN Get Cablink Statueses
    [Arguments]  ${component_index}
    ${Cablink_statuses_response}=    taf.sbts.oam.coam.admin.Get Managed Objects    CABLINK_R
    [Return]  ${Cablink_statuses_response[${component_index}]['parameters']['stateInfo']}

ADMIN Get cOAM BTS Statuses
    ${cOAM_BTS_statuses_response}=    taf.sbts.oam.coam.admin.Get Bts Info
    [Return]    ${cOAM_BTS_statuses_response['status']}

ADMIN Reset Site
    [Arguments]    ${timeout}=360
    ...            ${wait_for_reconnection}=${True}
    ...            ${connection}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Reset Site
    ...    timeout=${timeout}
    ...    wait_for_reconnection=${wait_for_reconnection}
    ...    connection=${connection}

ADMIN Get Smod Position
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_smod_position}=    taf.sbts.oam.coam.admin.Get Smod Position
    ...    timeout=${timeout}
    ...    alias=${alias}
    [Return]    ${out_smod_position}

ADMIN Wait Until BTS OnAir
    [Arguments]    ${timeout}=20 min
    ...            ${interval}=30 sec
    ...            ${alias}=${LOGGING_ADMIN_ALIAS}
    Wait Until Keyword Succeeds    ${timeout}
    ...                            ${interval}
    ...                            ADMIN Check BTS onair
    ...                            admin_alias=${alias}

ADMIN Check BTS onair
    [Arguments]        ${admin_alias}=${LOGGING_ADMIN_ALIAS}
    ${dict_info}=    taf.sbts.oam.coam.admin.Get Bts Info    connection=${admin_alias}
    ${state}=    Get From Dictionary    dictionary=${dict_info['status']}    key=proceduralState
    Should be equal    ${state}    OnAir

ADMIN Check BTS Not Commisioned
    [Arguments]        ${admin_alias}=${LOGGING_ADMIN_ALIAS}
    ${dict_info}=    taf.sbts.oam.coam.admin.Get Bts Info    connection=${admin_alias}
    ${state}=    Get From Dictionary    dictionary=${dict_info['status']}    key=proceduralState
    Should be equal    ${state}    NotCommissioned

ADMIN Check BTS Configured
    [Arguments]        ${admin_alias}=${LOGGING_ADMIN_ALIAS}
    ${dict_info}=    taf.sbts.oam.coam.admin.Get Bts Info    connection=${admin_alias}
    ${state}=    Get From Dictionary    dictionary=${dict_info['status']}    key=proceduralState
    Should be equal    ${state}    Configured

ADMIN Lock Cell
    [Arguments]    ${dist_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.lock_cell
    ...    dist_name=${dist_name}
    ...    timeout=${timeout}
    ...    connection=${alias}

ADMIN Unlock Cell
    [Arguments]    ${dist_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.unlock_cell
    ...    dist_name=${dist_name}
    ...    timeout=${timeout}
    ...    connection=${alias}
ADMIN Perform Commissioning
    [Arguments]    ${scf_file}
    ...            ${skip_parameter_relation_errors}=${False}
    ...            ${should_activate}=${True}
    ...            ${timeout}=600
    ...            ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Perform Commissioning
    ...                                scf_file=${scf_file}
    ...                                skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                should_activate=${should_activate}
    ...                                timeout=${timeout}
    ...                                connection=${alias}

ADMIN Perform Delta Recommissioning
    [Arguments]    ${delta_file}
    ...            ${skip_parameter_relation_errors}=${False}
    ...            ${should_activate}=${True}
    ...            ${timeout}=300
    ...            ${connection}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Perform Delta Recommissioning
    ...                                        delta_file=${delta_file}
    ...                                        skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                        should_activate=${should_activate}
    ...                                        timeout=${timeout}
    ...                                        connection=${connection}

ADMIN Perform Parameter Recommissioning
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${operation}
    ...            ${timeout}=300
    ...            ${connection}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}
    ...    operation=${operation}
    ...    skip_parameter_relation_errors=${TRUE}
    ...    timeout=${timeout}
    ...    connection=${connection}

ADMIN Perform Parameter Update
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${timeout}=300
    ...            ${connection}=${ADMIN_ALIAS}
    ADMIN Perform Parameter Recommissioning    dist_name=${dist_name}
    ...                                        parameter=${parameter}
    ...                                        operation=update
    ...                                        value=${value}
    ...                                        timeout=${timeout}
    ...                                        connection=${connection}

ADMIN Perform Parameter Create
    [Arguments]    ${target_dist_name}
    ...            ${parameterValue}
    ...            ${parameterName}
    ${parameter_dict}=    create dictionary
    ...    parameterName=${parameterName}
    ...    operation=update
    ...    value=${parameterValue}
    @{parameter_list}=    create list    ${parameter_dict}
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    dist_name=${target_dist_name}
    ...    parameter=@{parameter_list}
    ...    operation=create
    ...    skip_parameter_relation_errors=${True}

ADMIN Perform Parameter Delete
    [Arguments]    ${target_dist_name}
    ...            ${parameterValue}
    ...            ${parameterName}
    ${parameter_dict}=    create dictionary
    ...    parameterName=${parameterName}
    ...    operation=update
    ...    value=${parameterValue}
    @{parameter_list}=    create list    ${parameter_dict}
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    dist_name=${target_dist_name}
    ...    parameter=@{parameter_list}
    ...    operation=delete
    ...    skip_parameter_relation_errors=${True}

ADMIN Perform Object Recommissioning
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${timeout}=300
    ...            ${connection}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    operation=create
    ...    timeout=${timeout}
    ...    connection=${connection}

ADMIN Run Keyword In Background
    [Arguments]    ${background_process}
#    ...            ${interface}=${ADMIN_ALIAS}
#    ...            ${connection}=${ADMIN_ALIAS}
    ${out_background_process}=    taf.sbts.oam.coam.admin.Run Keyword In Background
    ...    name=${background_process}
    [Return]    ${out_background_process}

ADMIN Teardown Admin
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Teardown Admin
    ...    connection=${alias}

ADMIN Update Software
    [Arguments]    ${sw_package}
    ...            ${should_activate}
    ...            ${timeout}=1800
    ...            ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.update_software
    ...    sw_package=${sw_package}
    ...    should_activate=${should_activate}
    ...    timeout=${timeout}
    ...    connection=${alias}

ADMIN Update Software With Activation
    [Arguments]    ${sw_package}
    ...            ${timeout}=240
    ...            ${alias}=${ADMIN_ALIAS}
    ADMIN Update Software
    ...    sw_package=${sw_package}
    ...    should_activate=${True}
    ...    timeout=${timeout}
    ...    alias=${alias}

ADMIN Update Software Without Activation
    [Arguments]    ${sw_package}
    ...            ${timeout}=240
    ...            ${alias}=${ADMIN_ALIAS}
    ADMIN Update Software
    ...    sw_package=${sw_package}
    ...    should_activate=${False}
    ...    timeout=${timeout}
    ...    alias=${alias}

ADMIN Rollback Software
    [Arguments]    ${timeout}=900
    ...            ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.rollback_software
    ...    timeout=${timeout}
    ...    alias=${alias}

Admin Configuration Reset
    [Arguments]
    ...            ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.reset_configuration
    ...    connection=${alias}
    ...    remove_security_credentials=true

ADMIN Change R&D Port Status
    [Arguments]  ${status}
    taf.sbts.oam.coam.admin.change_rnd_port_security
    ...    enable=${status}

ADMIN Download And Update Current Software
    ${downloaded_sw_file}    ADMIN Download Current Software
    ADMIN Update Software    sw_package=/home/ute/${downloaded_sw_file}    should_activate=True

ADMIN Download Current Software
    ${sw_version}=    ADMIN Get Sw Version
    ${split_build}=    Split string       ${sw_version}    separator=\_
    ${trunk_flag}=     Get from list       ${split_build}     2
    ${version_flag}=   Get from list       ${split_build}     0
    ${download_build}=    Run keyword if    '${trunk_flag}'=='0000'    Set Variable   ${sw_version}
    ...   ELSE IF   '${version_flag}'=='${TRUNK_VERSION}'    Replace String    ${sw_version}    ${TRUNK_VERSION}    SBTS00
	...   ELSE   	Set Variable   ${active_software}
    Set Suite Variable    ${main_package}    ${download_build}_release_BTSSM_downloadable.zip
    Log    \nDownload SW Package ${main_package}    console=yes
    Run    wget ${jenkins_url}${download_build}/${main_package} -P ${SW_DESTINATION}
    OperatingSystem.File Should Exist    path=/home/ute/${main_package}

    [Return]    ${main_package}
