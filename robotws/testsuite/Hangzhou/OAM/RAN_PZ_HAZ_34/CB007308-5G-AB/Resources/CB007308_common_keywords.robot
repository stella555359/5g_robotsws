*** Settings ***
Documentation     author: Chen Kaijia
...               contact: kaijia.chen@nokia-sbell.com
...               squad group: MMW_SG_04

*** Variables ***
${ROOT_USERNAME}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${ROOT_PASSWORD}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${ROOT_USERNAME1}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${ROOT_PASSWORD1}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${MRBTS_ID}                       MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}                       NRBTS-${tl.gnbs[0].global_bts_id}
${DU_IP}                          ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBEM_USERNAME}                 ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}                 ${tl.gnbs[0].cu.oam_http_connection_details.password}
${test_pc_host}                   ${tl.test_pc.default_ssh_connection_details.addr}
${test_pc_username}               ${tl.test_pc.default_ssh_connection_details.username}
${test_pc_password}               ${tl.test_pc.default_ssh_connection_details.password}
${sfpOperatorMode}                 sfpOperatorMode
${dist_sfpOperatorMode}            ${MRBTS_ID}/EQM-1/APEQM-1
${SFPwhitelist_PATH}               ${OUTPUT DIR}/
${SFPwhitelist_remote_PATH}        /ffs/run/swpool/OAM/
${SFPwhitelist_NAME_REGEX}         sfpWhitelist*.xml
@{all_cell_info}                   ${0}    ${1}
${default_gnb_scf}                 ${CURDIR}/../../../../../../commissionings/HGZ/7_5_UTE5G402T733/SCF_SBTS00.xml


*** Keywords ***
Check BTS is in On Air
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=cOAM_admin
    ADMIN Wait Until BTS OnAir
    [Teardown]    coam.teardown     connection=cOAM_admin

Check BTS startup
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=cOAM_admin
    Admin Reset BTS
    [Teardown]    coam.teardown     connection=cOAM_admin

BTS detects cooled SFP+/SFP28
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=cOAM_admin
    ADMIN Wait Until BTS OnAir
    ${ii}    Get RF1 Runtime number
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=cOAM_admin
    Check if static data SFP for fronthaul    ii=${ii}
    [Teardown]    coam.teardown     connection=cOAM_admin

BTS detects cold SFP+/SFP28 startup and compare the temperature
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=cOAM_admin
    ADMIN Wait Until BTS OnAir
    Compare the temperature for FH and BH SFP
    [Teardown]    coam.teardown     connection=cOAM_admin

Admin Reset BTS
    [Arguments]    ${alias}=cOAM_admin
    coam.Reset Site    connection=${alias}


Check if static data SFP for fronthaul
    [Arguments]    ${ii}
    ${Cooled_Transceiver}    Get SCF single Value from current xml file
    ...   parameter=cooledTransceiverDeclaration   list_name=${None}
    ...   dist_name=${MRBTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${ii}   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    ${Cooled_Transceiver1}    Get SCF single Value from current xml file
    ...   parameter=cooledTransceiverDeclaration   list_name=${None}
    ...   dist_name=${MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-1/SFP_R-1   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    run keyword if    '${Cooled_Transceiver}'=='true' and '${Cooled_Transceiver1}'=='true'    log to console    PASS    ELSE    Fail

ADMIN Wait Until BTS OnAir
    [Arguments]    ${timeout}=15 min
    ...            ${interval}=30 sec
    ...            ${alias}=cOAM_admin
    Wait Until Keyword Succeeds    ${timeout}
    ...                            ${interval}
    ...                            ADMIN Check onair
    ...                            admin_alias=${alias}

ADMIN Check onair
    [Arguments]        ${admin_alias}
    ${dict_info}=    coam.Get Bts Info    connection=${admin_alias}
    ${state}=    Get From Dictionary    dictionary=${dict_info['status']}    key=proceduralState
    Should be equal    ${state}    OnAir

#CB006942-D
Check SFP temperature
    [Arguments]    ${parameter}    ${i}    ${ii}
    ${TEM1}   Get SCF single Value from current xml file
    ...   parameter=${parameter}   list_name=${None}   dist_name=${MRBTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${ii}   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    ${TEM2}   Get SCF single Value from current xml file
    ...   parameter=${parameter}   list_name=${None}   dist_name=${MRBTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${i}   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    ${TEM3}   Get SCF single Value from current xml file
    ...   parameter=${parameter}   list_name=${None}   dist_name=${MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-1/SFP_R-1   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    [Return]    ${TEM1}    ${TEM2}    ${TEM3}


Check RF1 SFP Module temperature
    ssh connect to DU
    ssh.send command                    command=awk 'NR==37 {print $3}' /tmp/sfp.csv > temperature.csv
    ...                                 connection=cOAM_toor4nsn
    ssh.download_file                   remote_path=/user/toor4nsn/temperature.csv
    ...                                 local_path=./temperature.csv
    ...                                 connection=cOAM_toor4nsn
    ${temperature_value_RF1}=                get_temperature_value
    [Return]    ${temperature_value_RF1}
    [Teardown]  ssh.disconnect          connection=cOAM_toor4nsn

Check EIF1 SFP Module temperature
    ssh connect to DU
    ssh.send command                    command=awk 'NR==99 {print $3}' /tmp/sfp.csv > temperature.csv
    ...                                 connection=cOAM_toor4nsn
    ssh.download_file                   remote_path=/user/toor4nsn/temperature.csv
    ...                                 local_path=./temperature.csv
    ...                                 connection=cOAM_toor4nsn
    ${temperature_value_EIF1}=                get_temperature_value
    [Return]    ${temperature_value_EIF1}
    [Teardown]  ssh.disconnect          connection=cOAM_toor4nsn

Compare the temperature for FH and BH SFP
    ${i}    Get EIF1 Runtime number
    ${ii}    Get RF1 Runtime number
    CB007308-5G-AB_common_keywords.Connect to DU
    ${TEMHIGH_RF1}    ${TEMHIGH_EIF1}    ${TEMHIGH_RMOD_opt1}    Check SFP temperature
    ...    parameter=temperatureHighAlarmThreshold    i=${i}    ii=${ii}
    ${TEMLOW_RF1}    ${TEMLOW_EIF1}    ${TEMLOW_RMOD_opt1}    Check SFP temperature
    ...    parameter=temperatureLowAlarmThreshold    i=${i}    ii=${ii}
    ${temperature_value_RF1}    Check RF1 SFP Module temperature
    ${temperature_value_EIF1}    Check EIF1 SFP Module temperature
    ${RMOD_SFP_TEMP_value}    Get temperature for RMOD SFP
    Should Be True    ${TEMLOW_RF1}<=${temperature_value_RF1}<=${TEMHIGH_RF1}
    ...               ${TEMLOW_EIF1}<=${temperature_value_EIF1}<=${TEMHIGH_EIF1}
    Should Be True    ${TEMLOW_RMOD_opt1}<=${RMOD_SFP_TEMP_value}<=${TEMHIGH_RMOD_opt1}

Get temperature for RMOD SFP
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=cOAM_admin
    ${RMOD_SFP_TEMP}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/CONNECTOR_L-1/SFP_L-1/SFP_PARAMS_L-1
    ...                 pattern=modTemp    connection=cOAM_admin
    ${RMOD_SFP_TEMP_value}    get from dictionary    ${RMOD_SFP_TEMP}    modTemp
    [Return]    ${RMOD_SFP_TEMP_value}
    [Teardown]    coam.teardown     connection=cOAM_admin

ssh connect to DU
    [Arguments]  ${ip_address}=${DU_IP}  ${alias}=cOAM_toor4nsn  ${password}=${ROOT_PASSWORD1}
    ${connection}=  ssh.Connect to  ${ip_address}
    ...                             ${ROOT_USERNAME1}
    ...                             ${password}
    ...                             alias=${alias}
    [Return]  ${connection}

Get EIF1 Runtime number
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=cOAM_admin
    FOR     ${i}    IN RANGE    ${1}    ${50}
        ${SFP_status}    run keyword and return status    coam.get_parameters
       ...   dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${i}
        ...              connection=cOAM_admin
        ${SFP_status}    run keyword if     ${SFP_status}
        ...   coam.get_parameters
       ...   dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${i}
        ...     connection=cOAM_admin     ELSE    Continue For Loop
        ${label}    get from dictionary    ${SFP_status}     physicalPort
        ${if_EIF1}     run keyword and return status    should be equal     ${label}   EIF1
        Exit For Loop If    '${if_EIF1}'=='${True}'
    END
    [Return]    ${i}
    [Teardown]    coam.teardown     connection=cOAM_admin

Get RF1 Runtime number
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=cOAM_admin
    FOR     ${i}    IN RANGE    ${1}    ${50}
        ${SFP_status}    run keyword and return status    coam.get_parameters
       ...   dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${i}
       ...       connection=cOAM_admin
       ${SFP_status}    run keyword if      ${SFP_status}
       ...   coam.get_parameters
       ...   dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${i}
       ...       connection=cOAM_admin      ELSE      Continue For Loop
        ${label}    get from dictionary    ${SFP_status}     physicalPort
        ${if_RF1}     run keyword and return status    should be equal     ${label}   RF1
        Exit For Loop If    '${if_RF1}'=='${True}'
    END
    [Return]    ${i}
    [Teardown]    coam.teardown     connection=cOAM_admin

#CB7308-5G-AB_FID4657_keywords
Set SFPWhiteList File Name
    ssh.Connect to    hostname=${DU_IP}    username=${ROOT_USERNAME}
    ...   password=${ROOT_PASSWORD}    alias=GNB_OAM
    ${SFPwhitelist_NAME}    Get file name    connection=GNB_OAM
    Set Suite Variable    ${SFPwhitelist_NAME}
    [Teardown]    ssh.Disconnect    connection=GNB_OAM
    [Return]    ${SFPwhitelist_NAME}

Get file name
    [Arguments]     ${connection}
    ssh.send command    command=find /ffs/run/swpool/OAM/ -type f -name sfpWhitelist*.xml
    ...    connection=${connection}    timeout=15 s
    ${output} =    ssh.Read output    connection=${connection}
    ${path_elements} =    Split String From Right    ${output}    /
    ${path_elements_length} =    Get Length    ${path_elements}
    ${path_elements_length} =    Evaluate    ${path_elements_length}-1
    ${file_name} =     Get From List    ${path_elements}    ${path_elements_length}
    ${file_name} =     Set Variable    ${file_name.replace("\n", "").replace("\r", "")}
    [Return]    ${file_name}

Create dir
    ssh.Connect to    hostname=${test_pc_host}    username=${test_pc_username}
    ...   password=${test_pc_password}    alias=test_pc
    ssh.send command    command=mkdir -p ${OUTPUT DIR}/log/
    ...    connection=test_pc    timeout=15 s
    ssh.send command    command=chmod 777 ${OUTPUT DIR}/log
    ...    connection=test_pc    timeout=15 s
    [Teardown]    ssh.Disconnect    connection=test_pc

Upload whitelist file
    [Arguments]    ${upload_whitelist_path}
    ...    ${remote_path}=${SFPwhitelist_remote_PATH}${SFPwhitelist_NAME}
    ...    ${logname}=${SFPwhitelist_NAME_REGEX}
    ssh.Connect to    hostname=${DU_IP}    username=${ROOT_USERNAME}
    ...   password=${ROOT_PASSWORD}    alias=GNB_OAM
    ssh.send command
    ...    command=rm -rf ${SFPwhitelist_remote_PATH}${SFPwhitelist_NAME}
    ...    command=rm -rf ${SFPwhitelist_remote_PATH}${SFPwhitelist_NAME}.p7
    ...    connection=GNB_OAM
    ssh.upload_file
    ...    remote_path=${SFPwhitelist_remote_PATH}${SFPwhitelist_NAME}
    ...    local_path=${upload_whitelist_path}
    ...    connection=GNB_OAM
    ssh.send command
    ...    command=crasign ${SFPwhitelist_remote_PATH}${SFPwhitelist_NAME}
    ...    connection=GNB_OAM
    sleep    5
    [Teardown]    ssh.Disconnect    connection=GNB_OAM

Download whitelist file
    [Arguments]    ${remote_path}=${SFPwhitelist_remote_PATH}
    ...    ${local_path}=${SFPwhitelist_PATH}
    ...    ${logname}=${SFPwhitelist_NAME_REGEX}
    ssh.Connect to    hostname=${DU_IP}    username=${ROOT_USERNAME}
    ...   password=${ROOT_PASSWORD}    alias=GNB_OAM
    ssh.download_file
    ...    remote_path=${remote_path}${SFPwhitelist_NAME}
    ...    local_path=${local_path}${SFPwhitelist_NAME}
    ...    connection=GNB_OAM
    ssh.download_file
    ...    remote_path=${remote_path}${SFPwhitelist_NAME}
    ...    local_path=${local_path}SFPwhitelist.xml
    ...    connection=GNB_OAM
    sleep    5
    [Teardown]    ssh.Disconnect    connection=GNB_OAM

Delete parameter in sfpwhitelist
    [Arguments]    ${sfp_model}
    ${xml_root} =     XML.parse xml     ${SFPwhitelist_PATH}${SFPwhitelist_NAME}
    ${xpath}=    set variable    ./record/ModuleName[.='${sfp_model}']/..
#    ${text} =    XML.get elements    ${xml_root}    xpath=${xpath}
    ${value}=    XML.Get Element Count     ${xml_root}    xpath=${xpath}
    run keyword if    ${value} > 0     run keywords
    ...    XML.Remove Elements    ${xml_root}    xpath=${xpath}    AND
    ...    XML.Save Xml    ${xml_root}    ${OUTPUT DIR}/${SFPwhitelist_NAME}

Reset DU
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=cOAM_admin
    Du Reset
    run keyword and ignore error    coam.teardown     connection=cOAM_admin
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=cOAM_admin
    Wait Until Keyword Succeeds    1000s    10s    Gnb Cell Should Be Onair    alias=cOAM_admin
    [Teardown]    coam.teardown     connection=cOAM_admin

Du Reset
    [Arguments]    ${timeout}=300
    ...            ${wait_for_reconnection}=${True}
    ...            ${connection}=cOAM_admin
    log to console    BTS resetting...
    coam.Reset Site
    ...    timeout=${timeout}
    ...    wait_for_reconnection=${wait_for_reconnection}
    ...    connection=${connection}

Gnb Cell Should Be Onair
    [Arguments]    ${alias}=default    ${cell_type}=nr
    [Documentation]    Gnb Cell Should Be Onair, check method is via REST
    log to console    waiting for BTS onair
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal as strings    ${proceduralState}    OnAir

check fault 4657
    ${i}    Get EIF1 Runtime number
    ${ii}    Get RF1 Runtime number
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=cOAM_admin
    ${hw_path_list}    ${alarm_list}    ${fault_id_list}    Get Alarm Info
    list should contain value    ${hw_path_list}    /SMOD_R-1/eif1/SFP_R-${i}
    list should contain value    ${hw_path_list}    /SMOD_R-1/rf1/SFP_R-${ii}
    list should contain value    ${hw_path_list}    /SMOD_R-1/rf1/RMOD_R-1/opt_if1/SFP_R-1
    FOR    ${item}    IN    @{alarm_list}
        should be equal    '${item}'    '${7100}'
    END
#    list should contain value    ${alarm_list}    ${7100}
    [Teardown]    coam.teardown     connection=cOAM_admin

Get Alarm Info
    [Arguments]    ${timeout}=50s    ${connection}=cOAM_admin
#    sleep    10s
    @{alarms}    coam.get_active_alarms    timeout=${timeout}    connection=cOAM_admin
    sleep    1s
    log     ${alarms}
    ${hw_path_list}    create list
    ${alarm_list}    create list
    FOR    ${item}    IN     @{alarms}
        ${fault_id}    get from dictionary    ${item}      faultId
        ${hw_path}    get from dictionary    ${item}      hwPath
        ${alarm_id}    get from dictionary    ${item}      alarmId
        run keyword if    '${fault_id}'=='4657'    append to list    ${hw_path_list}    ${hw_path}
        run keyword if    '${fault_id}'=='4657'    append to list    ${alarm_list}    ${alarm_id}
    END
    ${fault_id_list}    create list
    FOR    ${item}    IN    @{alarms}
        ${fault_id}    get from dictionary    ${item}    faultId
        ${fault_name}    get from dictionary    ${item}    faultName
        append to list    ${fault_id_list}    ${fault_id}
    END
    [Return]    ${hw_path_list}    ${alarm_list}    ${fault_id_list}

Get EIF1 distname
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=cOAM_admin

    FOR     ${i}    IN RANGE    ${1}    ${17}
        ${Connector_status}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/CONNECTOR_L-${i}
        ...              connection=cOAM_admin
        ${label}    get from dictionary    ${Connector_status}     connectorLabel
        ${if_EIF1}     run keyword and return status    should be equal     ${label}   EIF1
        Exit For Loop If    '${if_EIF1}'=='${True}'
    END
    [Return]    ${i}
    [Teardown]    coam.teardown     connection=cOAM_admin

Get RF1 distname
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=cOAM_admin
    FOR     ${i}    IN RANGE    ${1}    ${17}
        ${Connector_status}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/CONNECTOR_L-${i}
        ...              connection=cOAM_admin
        ${label}    get from dictionary    ${Connector_status}     connectorLabel
        ${if_RF1}     run keyword and return status    should be equal     ${label}    RF1
        Exit For Loop If    '${if_RF1}'=='${True}'
    END
    [Return]    ${i}
    [Teardown]     coam.teardown     connection=cOAM_admin

Get Availability status for SFP
    [Arguments]    ${i}    ${ii}
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=cOAM_admin
    ${RF1_status}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/CONNECTOR_L-${ii}/SFP_L-1
    ...                 pattern=availabilityStatus    connection=cOAM_admin
    ${EIF1_status}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/CONNECTOR_L-${i}/SFP_L-1
    ...                 pattern=availabilityStatus    connection=cOAM_admin
    ${RMOD_status}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/CONNECTOR_L-1/SFP_L-1
    ...                 pattern=availabilityStatus    connection=cOAM_admin
    ${EIF1_status_dic}        get from dictionary    ${EIF1_status}    stateInfo
    ${EIF1_SFP_status}        get from dictionary    ${EIF1_status_dic}    availabilityStatus
    ${RF1_SFP_status_dic}     get from dictionary    ${RF1_status}    stateInfo
    ${RF1_SFP_status}         get from dictionary    ${RF1_SFP_status_dic}     availabilityStatus
    ${RMOD_SFP_status_dic}    get from dictionary    ${RMOD_status}    stateInfo
    ${RMOD_SFP_status}        get from dictionary    ${RMOD_SFP_status_dic}    availabilityStatus
    [Return]    ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}
    [Teardown]    coam.teardown     connection=cOAM_admin

Check SFP availability status
    [Arguments]   ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}    ${expected_status}
    Run keyword and continue on failure    should be equal    ${EIF1_SFP_status}    ${expected_status}
    Run keyword and continue on failure    should be equal    ${RMOD_SFP_status}    ${expected_status}
    should be equal    ${RF1_SFP_status}    ${expected_status}

change sfpOperatorMode to true
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=cOAM_admin
    perform muti Parameter recommissioning    dist_name=${dist_sfpOperatorMode}    parameter=${sfpOperatorMode}    value=${True}
    [Teardown]    coam.teardown     connection=cOAM_admin

check none fault 4657
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=cOAM_admin
    ${hw_path_list}    ${alarm_list}    ${fault_id_list}    Get Alarm Info
    list should not contain value    ${fault_id_list}    ${4657}
    [Teardown]    coam.teardown     connection=cOAM_admin

perform muti Parameter recommissioning
    [Arguments]   ${dist_name}    ${parameter}   ${value}     ${operation}=update    ${connection}=cOAM_admin
    ...    ${skip_parameter_relation_errors}=${True}     ${should_activate}=${True}
    coam.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}
    ...    operation=${operation}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}
    ...    connection=${connection}

change sfpOperatorMode to false
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=cOAM_admin
    perform muti Parameter recommissioning    dist_name=${dist_sfpOperatorMode}    parameter=${sfpOperatorMode}    value=${False}
    [Teardown]    coam.teardown     connection=cOAM_admin

Case Teardown
    sleep    15s
    Upload whitelist file    upload_whitelist_path=${SFPwhitelist_PATH}SFPwhitelist.xml
    Reset DU
    run keyword and continue on failure    check none fault 4657
    sleep    3s
    ssh.Connect to    hostname=${test_pc_host}    username=${test_pc_username}
    ...   password=${test_pc_password}    alias=test_pc
    ssh.send command    command=rm -rf ${SFPwhitelist_PATH}${SFPwhitelist_NAME}
    ...    connection=test_pc    timeout=15 s
    ssh.send command    command=rm -rf ${SFPwhitelist_PATH}log
    ...    connection=test_pc    timeout=15 s
    CI_interface.Common Case Teardown
    robot_common_operations.Common case Teardown
    [Teardown]    ssh.Disconnect    connection=test_pc

Case Setup
    robot_common_operations.Common case Setup

Case_Teardown_common
    CI_interface.Common Case Teardown
    robot_common_operations.Common case Teardown
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save Snapshot

Save Snapshot
    [Arguments]    ${connection}=cOAM    ${timeout}=5min
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}     connection=${connection}
    ${snapshot_path}    Get Snapshot From BTS    alias=${connection}    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}
    
#CB007308-5G-AC_5GC002268_AEQE
Check 2 cell both onair
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=cOAM_admin
    Log To Console  Checking 2 cell both onair without BTS reset...
    Gnb Cell Should Be Onair    alias=cOAM_admin
    [Teardown]    coam.teardown     connection=cOAM_admin
    
Rest Login DU
    [Arguments]    ${ip_address}=${DU_IP}   ${username}=${WEBEM_USERNAME}
    ...    ${password}=${WEBEM_PASSWORD}    ${alias}=default
    [Documentation]   Rest Login DU
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}    connection=${alias}
    ${conn}     set variable    ${alias}
    [Return]    ${conn}


Get BTS release
    ${conn}    Rest Login DU
    ${version}    coam.get_sw_version    connection=${conn}
    ${version_list}    split string    ${version}    separator=_
    ${bts_release}    set variable    ${version_list[0]}
    [Return]    ${bts_release}
    [Teardown]    coam.teardown     connection=${conn}


WEBUI Login
    [Arguments]      ${virtual_enable}=${True}
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login
    Log To Console  Try to login...
    ${version}    Get BTS release
    selenium_coam.Enable Virtual Display
    selenium_coam.Login    url=https://${DU_IP}    username=${WEBEM_USERNAME}   password=${WEBEM_PASSWORD}
    ...    version=${version}
    Log To Console  Login successfully...
    Run Keyword And Ignore Error      selenium_coam.Disable_Message_Box
    Sleep    15s
    Log To Console  END:WEBUI Login!
    ${start_exits}    selenium_coam.start_up_view_window_exists
    Run Keyword If     ${start_exits} == ${TRUE}     selenium_coam.close_start_up_view_window


WEBUI_Logout
    [Arguments]     ${virtual_disable}=${True}
    [Documentation]   WEBUI Logout
    Log To Console  Try to logout...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Enable_Virtual_Display
    Run Keyword And Ignore Error  selenium_coam.Logout
    Log To Console  Logout successfully...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Disable_Virtual_Display
    Sleep    1s
    Log To Console  END:WEBUI Logout!

WebEM ValidateAndActiveParameters
    [Documentation]  WebEM ValidateAndActiveParameters
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${300}

Add Object in SCF
    [Arguments]  ${default_scf}    ${object_list}    ${new_scf_name}
    scf.load_scf       file_path=${default_scf}
    FOR    ${item}    IN    @{object_list}
        ${source_dist_name}    Get From Dictionary    ${item}    source_dist_name
        ${target_dist_name}    Get From Dictionary    ${item}    target_dist_name
        scf.clone_mo_with_descendant_mos    source_mo_dist_name=${source_dist_name}    target_mo_dist_name=${target_dist_name}
    END
    ${new_scf}    set variable    ${OUTPUT DIR}/${new_scf_name}
    scf.save_scf        file_path=${new_scf}
    [Return]  ${new_scf}

Modify Parameter in SCF
    [Arguments]  ${input_scf}    ${para_list}    ${modify_scf}
    scf.load_scf       file_path=${input_scf}
    FOR     ${item}    IN    @{para_list}
        ${dist_name}    Get From Dictionary    ${item}    dist_name
        ${list_name}    Get From Dictionary    ${item}    list_name
        ${p_name}    Get From Dictionary    ${item}    p_name
        ${value}    Get From Dictionary    ${item}    value
        scf.modify_scf_element     dist_name=${dist_name}    p_name=${p_name}     value=${value}    list_name=${list_name}
    END
    ${new_scf}    set variable    ${OUTPUT DIR}/${modify_scf}
    scf.save_scf        file_path=${new_scf}
    [Return]  ${new_scf}

Add Element in SCF
    [Arguments]  ${input_scf}    ${element_list}    ${modify_scf}
    scf.load_scf       file_path=${input_scf}
    FOR    ${item}    IN    @{element_list}
        ${dist_name}    Get From Dictionary    ${item}    dist_name
        ${list_name}    Get From Dictionary    ${item}    list_name
        ${elements}    Get From Dictionary    ${item}    elements
        scf.add_elements_to_list    dist_name=${dist_name}    list_name=${list_name}     elements=${elements}
    END
    ${new_scf}    set variable    ${OUTPUT DIR}/${modify_scf}
    scf.save_scf        file_path=${new_scf}
    [Return]  ${new_scf}

Setup Commission SCF
    [Arguments]  ${host_ip}    ${scf_path}    ${connection}
    Connect to gnb coam via ssl    bts_host=${host_ip}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${scf_path}    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Case Suite Setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup

Case Suite Teardown
    CI_interface.Common Case Teardown
    robot_common_operations.Common Suite Teardown
