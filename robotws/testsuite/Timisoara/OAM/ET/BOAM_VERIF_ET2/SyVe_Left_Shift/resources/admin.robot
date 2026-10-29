*** Settings ***
Documentation
...     Author:
...     Maintainer:

Library    Collections
#Library    taf.sbts.oam.coam.admin
Library    taf.sbts.oam.coam.admin.interface
Library    admin_utils.py
Library    ../CommonKeywords/sw_editors.py
Resource   system.robot
Resource   ../CommonKeywords/sw_package_ops.robot


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
${TEMP_ADMIN_ALIAS}=             tempadmin

${TRUNK_VERSION}        SBTS22R4  #SBTS21B
${jenkins_url}          http://files.ute.nsn-rdnet.net/builds/enb/base/
${DOWNLOAD_HOST}        https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release

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
    ${OUT_ADMIN_CONNECTION}=   taf.sbts.oam.coam.admin.Setup Admin
    ...    bts_host=${bts_host}
    ...    bts_port=${bts_port}
    ...    username=${username}
    ...    password=${password}
    ...    use_ssl=${use_ssl}
    ...    update_interval=${update_interval}
    ...    admin_api_log_dir=${admin_api_log_dir}
    ...    alias=${alias}
    ...    timeout=${timeout}

    set suite variable  ${OUT_ADMIN_CONNECTION}

ADMIN Download And Corrupt Software Package
    #[Arguments]    ${buildname_postfix}=${EMPTY}
    ${sw_package_path}=    ADMIN Download Software Package 2    buildname_postfix=T1
    ${corrupted_sw_package_path}=    ADMIN Corrupt Software Package    sw_package_path=${sw_package_path}
    [Return]    ${corrupted_sw_package_path}

ADMIN Download Software Package
    [Arguments]    ${buildname_postfix}=${EMPTY}
    ${sw_version}=    ADMIN Get Sw Version
    ${package_name}=    get_package_name_from_soft_name    sw_name=${sw_version}
    Set Test Variable    ${build_name}    AirScale-${package_name}${buildname_postfix}.zip
    Set Test Variable    ${sw_dir_path}    /home/ute/valid_sw
    Set Test Variable    ${sw_package_path}    ${sw_dir_path}/${build_name}
    Run  mkdir ${sw_dir_path}
    Download software package    sw_build=${package_name}
    ...                          sw_file_name=${build_name}
    ...                          dir_to_keep_package=${sw_dir_path}
    [Return]    ${sw_package_path}

ADMIN Download Software Package 2
    #[Arguments]    ${buildname_postfix}=${EMPTY}
    ${sw_version}=    ADMIN Get Sw Version
    Set Suite Variable    ${sw_dir_path}    /home/ute/valid_sw
    Run  mkdir ${sw_dir_path}
    Set Suite Variable    ${active_software}    ${OUT_ACTIVE_SW}
    ${active_software_split}=    Split String
    ...                          string=${active_software}
    ...                          separator=_
    ...                          max_split=4
    ${BRANCH}=   Get from list         ${active_software_split}    2

    Run Keyword If  '${BRANCH}'=='9999'   Download SW for SBTS00
    ...   ELSE IF   '${BRANCH}'=='0000'   Download SW for branch 5G SBTS

    Set Test Variable    ${sw_package_path}    ${sw_dir_path}/${T1_package}
    [Return]    ${sw_package_path}

Download SW for SBTS00
    Set Suite Variable    ${active_software}    ${OUT_ACTIVE_SW}
    ${split_build}=    Split string       ${active_software}    separator=\_
    ${trunk_flag}=     Get from list       ${split_build}     2
    ${version_flag}=   Get from list       ${split_build}     0
    ${download_build}=    Run keyword if    '${trunk_flag}'=='0000'    Set Variable   ${active_software}
    ...   ELSE IF   '${version_flag}'=='${TRUNK_VERSION}'    Replace String    ${active_software}    ${TRUNK_VERSION}    SBTS00
	...   ELSE   	Set Variable   ${active_software}
    Set Suite Variable    ${T1_package}    ${download_build}_release_BTSSM_downloadable_testpackage_T1.zip
    Log    \nDownload SW packages    console=yes
    Run    wget ${jenkins_url}${download_build}/${T1_package} -P ${sw_dir_path}
    OperatingSystem.File Should Exist    path=${sw_dir_path}/${T1_package}
    Log    Download completed    console=yes

Download SW for branch 5G SBTS
    Set Suite Variable    ${active_software}    ${OUT_ACTIVE_SW}
    ${split_build}=    Split string       ${active_software}    separator=\_
    ${trunk_flag}=     Get from list       ${split_build}     2
    ${version_flag}=   Get from list       ${split_build}     0
    ${download_build}=    Run keyword if    '${trunk_flag}'=='0000'    Set Variable   ${active_software}
    ...   ELSE IF   '${version_flag}'=='${TRUNK_VERSION}'    Replace String    ${active_software}    ${TRUNK_VERSION}    SBTS21B
	...   ELSE   	Set Variable   ${active_software}
    Set Suite Variable    ${T1_package}    ${download_build}_release_BTSSM_downloadable_testpackage_T1.zip
    Log    \nDownload SW packages    console=yes
    Run    wget ${jenkins_url}${download_build}/${T1_package} -P ${sw_dir_path}
    OperatingSystem.File Should Exist    path=${sw_dir_path}/${T1_package}
    Log    Download completed    console=yes

Download SW for branch 5G
    Set Suite Variable    ${active_software}    ${OUT_ACTIVE_SW}
    ${active_software_split}=    Split String
    ...                          string=${active_software}
    ...                          separator=_
    ...                          max_split=4
    ${BRANCH}=   Get from list         ${active_software_split}    2
    ${version}=  Run Keyword If  '${BRANCH}'=='0011'  Convert To String  11.800
    Set Suite Variable    ${active_software_number}    ${active_software_split[4]}
    ${active_software_number}=    Convert To Integer    ${active_software_number[:6]}
    Set Suite Variable    ${T1_package}    AirScale-${version}.${active_software_number}T1.zip
    Log    \nDownload SW packages    console=yes
    Run    wget ${DOWNLOAD_HOST}/${version}.${active_software_number}/${T1_package} -P ${sw_dir_path}
    OperatingSystem.File Should Exist    path=${sw_dir_path}/${T1_package}
    Log    Download completed    console=yes

ADMIN Corrupt Software Package
    [Arguments]    ${sw_package_path}=${EMPTY}
    Set Test Variable    ${sw_invalid_path}    /home/ute/invalid_sw
    Run  rm -rf ${sw_invalid_path}; mkdir ${sw_invalid_path}
    Set Test Variable    ${corrupted_build_name}    Airscale_corrupted.zip
    Run    mv ${sw_package_path} ${sw_invalid_path}/${corrupted_build_name}
    ${unzipped_sw_path}=    Unzip SW package    zip_dir=${sw_invalid_path}/${corrupted_build_name}
    Corrupt software    source=${unzipped_sw_path}
    ${corrupted_sw_package_path}    Zip SW package    dir=${unzipped_sw_path}
    [Return]    ${corrupted_sw_package_path}

#ADMIN Corrupt Software Package     #No space remaining in /home/ute using this keyword
#    [Arguments]    ${sw_package_path}=${EMPTY}
#    Set Test Variable    ${sw_invalid_path}    /home/ute/invalid_sw
#    Run  rm -rf ${sw_invalid_path}; mkdir ${sw_invalid_path}
#    Set Test Variable    ${corrupted_build_name}    Airscale_corrupted.zip
#    Run    cp ${sw_package_path} ${sw_invalid_path}/${corrupted_build_name}
#    ${unzipped_sw_path}=    Unzip SW package    zip_dir=${sw_invalid_path}/${corrupted_build_name}
#    Corrupt software    source=${unzipped_sw_path}
#    ${corrupted_sw_package_path}    Zip SW package    dir=${unzipped_sw_path}
#    [Return]    ${corrupted_sw_package_path}

ADMIN Reset Site And Wait For Onair
    [Arguments]        #${timeout}=300 sec
    ...                ${wait_for_reconnection}=${False}
    ...                ${admin_alias}=${admin_alias}
    ADMIN Reset Site    wait_for_reconnection=${wait_for_reconnection}
    ...                 connection=${admin_alias}
#    SYSTEM Check reconnection after reboot
    sleep  60s
    ADMIN Wait Until BTS OnAir

ADMIN Wait Until BTS OnAir
    [Arguments]    ${timeout}=15 min
    ...            ${interval}=30 sec
    ...            ${alias}=${LOGGING_ADMIN_ALIAS}
    Wait Until Keyword Succeeds    ${timeout}
    ...                            ${interval}
    ...                            ADMIN Check onair
    ...                            admin_alias=${alias}

ADMIN Check onair
    [Arguments]        ${admin_alias}=${LOGGING_ADMIN_ALIAS}
    ${dict_info}=    taf.sbts.oam.coam.admin.Get Bts Info    connection=${admin_alias}
    ${state}=    Get From Dictionary    dictionary=${dict_info['status']}    key=proceduralState
    Should be equal    ${state}    OnAir


ADMIN Abort Software Update
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Abort Software Update
    ...    connection=${alias}

ADMIN Assert Alarm Active
    [Arguments]    ${parameters}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    ${alarm_active}    taf.sbts.oam.coam.admin.assert_alarm_active
    ...    parameters=${parameters}
    ...    timeout=${timeout}
    ...    connection=${alias}
    [Return]    ${alarm_active}

ADMIN Assert Alarm Inactive
    [Arguments]    ${parameters}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    ${alarm_inactive}    taf.sbts.oam.coam.admin.assert_alarm_inactive
    ...    parameters=${parameters}
    ...    timeout=${timeout}
    ...    connection=${alias}
    [Return]    ${alarm_inactive}

ADMIN Assert No Unexpected Active Alarms
    [Arguments]    ${alowed_alarms_list}
    ...            ${connection}=${ADMIN_ALIAS}
    ${alowed_alarms_list}=      convert to string  ${alowed_alarms_list}
    @{out_alarms_objects_list}    ADMIN Get Active Alarms   ${connection}
    FOR    ${alarm}    IN    @{out_alarms_objects_list}
        ${dict_fault_id}    Get From Dictionary    ${alarm}   faultId
        should contain    ${alowed_alarms_list}     '${dict_fault_id}'
    END

ADMIN Block
    [Arguments]    ${dist_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.block
    ...    dist_name=${dist_name}
    ...    timeout=${timeout}
    ...    connection=${alias}

ADMIN Unblock
    [Arguments]    ${dist_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.unblock
    ...    dist_name=${dist_name}
    ...    timeout=${timeout}
    ...    connection=${alias}

ADMIN Check If Alarm Is Active
    [Arguments]    ${fault_id}
    ...            ${connection}=${ADMIN_ALIAS}
    ${is_active}    ADMIN Is alarm active   ${fault_id}    ${connection}
    Should Be True   ${is_active}

ADMIN Check If Alarm Is Not Active
    [Arguments]
    ...    ${fault_id}
    ...    ${connection}=${ADMIN_ALIAS}
    ${is_active}    ADMIN Is alarm active   ${fault_id}    ${connection}
    Should Not Be True   ${is_active}

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
    ...            ${timeout}=360
    ...            ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Collect Snapshot    target_file_name=${snapshot_name}
    ...                           coverage=${coverage}
    ...                           force=${force}
    ...                           timeout=${timeout}
    ...                           alias=${alias}

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

ADMIN Get Ids For All
    [Arguments]    ${class_name}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_current_id}=    taf.sbts.oam.coam.admin.get_ids_for_all
    ...    class_name=${class_name}
    ...    timeout=${timeout}
    ...    connection=${alias}
    [Return]    ${out_current_id}

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

ADMIN Get All Parameters
    [Arguments]    ${dist_name}
    ...            ${timeout}=10
    ...            ${connection}=${ADMIN_ALIAS}
    ${out_parameters}    taf.sbts.oam.coam.admin.get_parameters
    ...    dist_name=${dist_name}
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
    [Arguments]    ${timeout}=300
    ...            ${wait_for_reconnection}=${True}
    ...            ${connection}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Reset Site
    ...    timeout=${timeout}
    ...    wait_for_reconnection=${wait_for_reconnection}
    ...    connection=${connection}

Admin Reset Site With Verification
    [Arguments]   ${password}=oZPS0POrRieRtu
    ...           ${host}= toor4nsn@192.168.255.1
    ...           ${connection}=${ADMIN_ALIAS}

    ${connecttobts}=  set variable  sshpass -p ${password} ssh ${host}
    ${lastreset}=  set variable  'sed -n -e "/Time/ , /SW VERSION/ p" ../lifedata/blackbox | tail -2| head -1'
    ${blackboxinit}=  run  ${connecttobts} ${lastreset}
    ${getresetnum}=  set variable
    ...  ${connecttobts} 'grep -n "${blackboxinit}" ../lifedata/blackbox | cut -d : -f 1' | grep -Eo '[0-9]*'
    ${getnumlineinit}=  run  ${getresetnum}
    ADMIN Reset Site  connection=${connection}
    ${blackboxafter}=  run  ${connecttobts} ${lastreset}
    ${getnumlinesafter}  run  ${getresetnum}
    ${result}=  evaluate
    ...  "User (Execute reset.)" in """${blackboxafter}""" and """${blackboxafter}""" is not """${blackboxinit}"""
    ${linenumdiff}=  evaluate  int("""${getnumlineinit}""") - int("""${getnumlinesafter}""")
    should be true  ${result} == True
    should be equal as integers  ${result}  1

ADMIN Get Smod Position
    [Arguments]    ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_smod_position}=    taf.sbts.oam.coam.admin.Get Smod Position
    ...    timeout=${timeout}
    ...    connection=${alias}
    [Return]    ${out_smod_position}

ADMIN Get Module Type
    [Arguments]    ${module_type}

    ${cOAM_BTS_statuses_response}=    taf.sbts.oam.coam.admin.Get Bts Info
    ${type}    get_variant    ${cOAM_BTS_statuses_response}  ${module_type}
    log to console   ${type}

    [Return]   ${type}

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
    ...            ${skip_relation_errors}=${TRUE}
    ...            ${timeout}=300
    ...            ${connection}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}
    ...    operation=${operation}
    ...    skip_parameter_relation_errors=${skip_relation_errors}
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
    ...            ${operation}=create
    ...            ${skip_parameter_relation_errors}=${TRUE}
    ...            ${timeout}=300
    ...            ${connection}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    operation=${operation}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    timeout=${timeout}
    ...    connection=${connection}

ADMIN Run Keyword In Background
    [Arguments]    ${background_process}
    #...            ${interface}=${ADMIN_ALIAS}Reset
    #...            ${connection}=${ADMIN_ALIAS}
    ${out_background_process}=    taf.sbts.oam.coam.admin.Run Keyword In Background
    ...    name=${background_process}
    [Return]    ${out_background_process}

ADMIN Teardown Admin
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Teardown Admin
    ...    alias=${alias}

ADMIN Download And Update Current Software

    ${downloaded_sw_file}    ADMIN Download Current Software    /tmp

    ADMIN Update Software    sw_package=${downloaded_sw_file}    should_activate=True

ADMIN Download Current Software
    [Arguments]    ${directory}    ${is_package_with_suffix}=${FALSE}

    ${sw_version}=    ADMIN Get Sw Version
    log to console  Software download. Version ${sw_version}

    ${package_name}=   get_package_name_from_soft_name    ${sw_version}
    ${smod_type}=      ADMIN Get Module Type  SMOD
    ${bbmod_type}=      ADMIN Get Module Type  BBMOD

    ${sw_file_name}=   get_sw_file_name    ${package_name}    ${smod_type}   ${bbmod_type}   ${is_package_with_suffix}
    ${file_in_dir}=    Run Keyword And Return Status
    ...    SYSTEM Check If File Is In Directory
    ...    fileName=${sw_file_name}
    ...    fileDirectory=${directory}
    ${output}    OperatingSystem.Run    df
    Log To Console    \\n OperatingSystem.Run df \${output}=\n${output}
    ${sw_file}=        Run Keyword If    ${file_in_dir} == ${FALSE}
    ...    Download software package   ${package_name}    ${sw_file_name}    ${directory}
    ...    ELSE    Convert To String    ${directory}/${sw_file_name}
    ${output}    OperatingSystem.Run    df
    Log To Console    \\n OperatingSystem.Run df \${output}=\n${output}
    SYSTEM Check If File Is In Directory
    ...    fileName=${sw_file_name}
    ...    fileDirectory=${directory}

    [Return]  ${sw_file}

ADMIN Download Predecessor Software
    [Arguments]    ${directory}    ${is_package_with_suffix}=${FALSE}    ${timeout}=30 min
    [Timeout]    ${timeout}

    Log To Console    ADMIN Download Predecessor Software
    ${sw_version}=    ADMIN Get Sw Version
    log to console  Current SW is ${sw_version}

    ${package_name}=   get_package_name_from_soft_name    ${sw_version}
    ${left}    ${mid}    ${right}    Split String    ${package_name}    .
    ${int}    convert to integer    ${right}
    ${int}    Get Variable Value    ${int-1}
    ${package_name}=    Convert To String    ${left}.${mid}.${int}
    ${smod_type}=      ADMIN Get Module Type  SMOD
    ${bbmod_type}=      ADMIN Get Module Type  BBMOD


    ${sw_file_name}=   new get_sw_file_name    ${package_name}    ${is_package_with_suffix}
    ${file_in_dir}=    Run Keyword And Return Status
    ...    SYSTEM Check If File Is In Directory
    ...    fileName=${sw_file_name}
    ...    fileDirectory=${directory}
    ${df_root}    OperatingSystem.Run    df | grep /$
    Log To Console    \${df_root}=${df_root}
    ${df_home}    OperatingSystem.Run    df | grep /home$
    Log To Console    \${df_home}=${df_home}
    ${df_tmp}     OperatingSystem.Run    df | grep /tmp$
    Log To Console    \${df_tmp}=${df_tmp}
    ${sw_file}=        Run Keyword If    ${file_in_dir} == ${FALSE}
    ...    Download software package   ${package_name}    ${sw_file_name}    ${directory}
    ...    ELSE    Convert To String    ${directory}/${sw_file_name}
    ${df_root}    OperatingSystem.Run    df | grep /$
    Log To Console    \${df_root}=${df_root}
    ${df_home}    OperatingSystem.Run    df | grep /home$
    Log To Console    \${df_home}=${df_home}
    ${df_tmp}     OperatingSystem.Run    df | grep /tmp$
    Log To Console    \${df_tmp}=${df_tmp}
    SYSTEM Check If File Is In Directory
    ...    fileName=${sw_file_name}
    ...    fileDirectory=${directory}

    [Return]  ${sw_file}

ADMIN Download Predecessor Software And Corrupt
    [Arguments]    ${directory}    ${is_package_with_suffix}=${FALSE}    ${timeout}=26 min    # TL 021: 26
    [Timeout]    ${timeout}

    Log To Console    ADMIN Download Predecessor Software And Corrupt
    ${sw_version}=    ADMIN Get Sw Version
    log to console  Current SW is ${sw_version}

    ${package_name}=   get_package_name_from_soft_name    ${sw_version}
    ${left}    ${mid}    ${right}    Split String    ${package_name}    .
    ${int}    convert to integer    ${right}
    ${int}    Get Variable Value    ${int-1}
    ${package_name}=    Convert To String    ${left}.${mid}.${int}
    ${smod_type}=      ADMIN Get Module Type  SMOD
    ${bbmod_type}=      ADMIN Get Module Type  BBMOD


    ${sw_file_name_corruped}=    new get_sw_file_name_corrupted    ${package_name}     ${is_package_with_suffix}
    ${file_corrupted_in_dir}=    Run Keyword And Return Status
    ...    SYSTEM Check If File Is In Directory
    ...    fileName=${sw_file_name_corruped}
    ...    fileDirectory=${directory}
    ${sw_file_corrupted}=    Run Keyword If    ${file_corrupted_in_dir} == ${FALSE}
    ...    ADMIN Download Predecessor Software And Corrupt - slave    directory=${directory}    is_package_with_suffix=${is_package_with_suffix}
    ...    ELSE    Convert To String    ${directory}/${sw_file_name_corruped}

    [Return]  ${sw_file_corrupted}

ADMIN Download Predecessor Software And Corrupt - slave
    [Arguments]    ${directory}    ${is_package_with_suffix}=${FALSE}    ${timeout}=26 min    # TL 021: 26
    [Timeout]    ${timeout}
    Log To Console    ADMIN Download Predecessor Software And Corrupt - slave
    ${sw_version}=    ADMIN Get Sw Version
    ${package_name}=   get_package_name_from_soft_name    ${sw_version}
    ${left}    ${mid}    ${right}    Split String    ${package_name}    .
    ${int}    convert to integer    ${right}
    ${int}    Get Variable Value    ${int-1}
    ${package_name}=    Convert To String    ${left}.${mid}.${int}
    ${smod_type}=      ADMIN Get Module Type  SMOD
    ${bbmod_type}=      ADMIN Get Module Type  BBMOD

    ${sw_file_name_corruped}=    get_sw_file_name_corrupted    ${package_name}    ${smod_type}  ${bbmod_type}  ${is_package_with_suffix}
    ${sw_file_name_valid}=    get_sw_file_name    ${package_name}    ${smod_type}  ${bbmod_type}   ${is_package_with_suffix}
    ${sw_file_valid}=    ADMIN Download Predecessor Software    directory=${directory}    is_package_with_suffix=${is_package_with_suffix}

    Log To Console    mv ${sw_file_valid} ${directory}/${sw_file_name_corruped}
    Run    mv ${sw_file_valid} ${directory}/${sw_file_name_corruped}   # TL 021: 3 sec

    Log To Console    Predecessor SW package corruption
    Log To Console    Unzip
    ${sw}    Unzip SW package    ${directory}/${sw_file_name_corruped}    # TL 021: 30 sec
    ${output}    OperatingSystem.Run    ls ${directory}
    ${df_root}    OperatingSystem.Run    df | grep /$
    Log To Console    \${df_root}=${df_root}
    ${df_home}    OperatingSystem.Run    df | grep /home$
    Log To Console    \${df_home}=${df_home}
    ${df_tmp}     OperatingSystem.Run    df | grep /tmp$
    Log To Console    \${df_tmp}=${df_tmp}
    Log To Console    Delete SW package
    Delete SW package    ${directory}/${sw_file_name_corruped}
    ${output}    OperatingSystem.Run    ls ${directory}
    Log To Console    Corrupt
    corrupt software  ${sw}
    Log To Console    Zip
    ${sw_file_corrupted}  Zip SW package  ${sw}    # TL 021: 2 min 30 sec
    ${df_root}    OperatingSystem.Run    df | grep /$
    Log To Console    \${df_root}=${df_root}
    ${df_home}    OperatingSystem.Run    df | grep /home$
    Log To Console    \${df_home}=${df_home}
    ${df_tmp}     OperatingSystem.Run    df | grep /tmp$
    Log To Console    \${df_tmp}=${df_tmp}
    Log To Console    Delete unzipped SW package
    Delete unzipped SW package    ${sw}

    [Return]    ${sw_file_corrupted}

ADMIN Update Software
    [Arguments]    ${sw_package}
    ...            ${should_activate}
    ...            ${timeout}=900
    ...            ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.update_software
    ...    sw_package=${sw_package}
    ...    should_activate=${should_activate}
    ...    timeout=${timeout}
    ...    connection=${alias}

ADMIN Update Software With Activation
    [Arguments]    ${sw_package}
    ...            ${timeout}=2500
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

ADMIN Change R&D Port Status
    [Arguments]  ${status}
    taf.sbts.oam.coam.admin.change_rnd_port_security
    ...    enable=${status}

ADMIN Reset Configuration
    [Arguments]     ${timeout}=900
    ...             ${connection}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.reset_configuration
    ...    timeout=${timeout}
    ...    connection=${connection}

ADMIN Lock Cell
    [Arguments]    ${dist_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.block_cell
    ...    dist_name=${dist_name}
    ...    timeout=${timeout}
    ...    connection=${alias}

ADMIN Unlock Cell
    [Arguments]    ${dist_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.unblock_cell
    ...    dist_name=${dist_name}
    ...    timeout=${timeout}
    ...    connection=${alias}

ADMIN Get Managed Objects With Parameters
    [Documentation]    Get managed objects with parameters
    ...    class_name example: SMOD, RMOD_R, GNSS_L, NRCELL_A, NRCELL_L, NRCELL_R ...
    [Arguments]    ${class_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_objects_parameters_dict}    taf.sbts.oam.coam.admin.get_managed_objects
    ...    class_name=${class_name}
    ...    timeout=${timeout}
    ...    connection=${alias}
    [Return]    ${out_list_of_objects_parameters_dict}

ADMIN Get Managed Object Parameter
    [Documentation]    Get managed objects with parameters
    ...    class_name example: SMOD, RMOD_R, GNSS_L, NRCELL_A, NRCELL_L, NRCELL_R ...
    [Arguments]    ${class_name}
    ...            ${parameter}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_all_object_values_dict}    ADMIN Get Managed Objects With Parameters
    ...    class_name=${class_name}
    ...    timeout=${timeout}
    ...    alias=${alias}
    ${parameters_dict}    Get From Dictionary    ${out_list_of_all_object_values_dict[0]}    key=parameters
    ${out_parameter}    Get From Dictionary    ${parameters_dict}    key=${parameter}
    [Return]    ${out_parameter}

ADMIN Get MRBTS Id
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    ${out_mrbts_id}=    taf.sbts.oam.coam.admin.Get Bts Info
    ...    connection=${alias}
    [Return]    ${out_mrbts_id['mrbtsID']}

ADMIN Get State Info Parameters Dict For Distname
    [Arguments]    ${dist_name}
    ...            ${alias}=${ADMIN_ALIAS}
    ${parameters_dict}    ADMIN Get Parameters Dict For Distname
    ...    dist_name=${dist_name}
    ...    alias=${alias}
    ${state_info_dict}    Get From Dictionary    dictionary=${parameters_dict}
    ...                                     key=stateInfo
    [Return]    ${state_info_dict}

ADMIN Get Parameters Dict For Distname
    [Arguments]    ${dist_name}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    ${parameter_dict}    ADMIN Get All Parameters
    ...    dist_name=${dist_name}
    ...    timeout=${timeout}
    ...    connection=${alias}
    [Return]    ${parameter_dict}

ADMIN Check If Object Is Enabled And Online
    [Arguments]      ${dist_name}
    ...              ${alias}=${ADMIN_ALIAS}
    ${state_info_dict}    ADMIN Get State Info Parameters Dict For Distname
    ...    dist_name=${dist_name}
    ...    alias=${alias}
    ${availabilityStatus}    Get From Dictionary    ${state_info_dict}    availabilityStatus
    ${operationalState}    Get From Dictionary    ${state_info_dict}    operationalState
    Should Be Equal    ${availabilityStatus}    Online
    Should Be Equal    ${operationalState}    Enabled
