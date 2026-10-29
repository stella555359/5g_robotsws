*** Settings ***
Documentation
...               author: Chen Kaijia
...               contact: kaijia.chen@nokia-sbell.com
...               squad group: MMW_SG_04

Library           XML     use_lxml=True    WITH NAME    Myxml
Library           Collections
Library           String
Library           OperatingSystem
Library           taf.transport.ssh         WITH NAME    ssh
#Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
${test_pc_host}                    ${tl.test_pc.default_ssh_connection_details.addr}
${test_pc_username}                ${tl.test_pc.default_ssh_connection_details.username}
${test_pc_password}                ${tl.test_pc.default_ssh_connection_details.password}
${DU_IP}                           ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBEM_USERNAME}                  ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}                  ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_OAM_IP}                       ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${sfpOperatorMode}                 sfpOperatorMode
${dist_sfpOperatorMode}            MRBTS-${MRBTS_ID}/EQM-1/APEQM-1
${MRBTS_ID}                        ${tl.gnbs[0].instance_id}
${SFPwhitelist_PATH}               ${OUTPUT DIR}/
${SFPwhitelist_remote_PATH}        /ffs/run/swpool/OAM/
${SFPwhitelist_NAME_REGEX}         sfpWhitelist*.xml

*** Keywords ***
Download whitelist file
    [Arguments]    ${remote_path}=${SFPwhitelist_remote_PATH}
    ...    ${local_path}=${SFPwhitelist_PATH}
    ...    ${logname}=${SFPwhitelist_NAME_REGEX}
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}
    ...   password=${DU_OAM_SSH_PASSWORD}    alias=GNB_OAM
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

Connect to DU
    [Arguments]    ${alias}=cOAM_admin
    Connect to gnb coam via ssl
    ...    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${alias}
    ${conn}    set variable    ${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    coam.teardown     connection=${alias}

Reset DU
    CB007308-5G-AB_FID4657_keywords_AEQE.Connect to DU
    CB007308-5G-AB_FID4657_keywords_AEQE.Du Reset
    run keyword and ignore error    CB007308-5G-AB_FID4657_keywords_AEQE.Disconnect from DU
    CB007308-5G-AB_FID4657_keywords_AEQE.Connect to DU
    Wait Until Keyword Succeeds    1000s    10s
    ...    CB007308-5G-AB_FID4657_keywords_AEQE.Gnb Cell Should Be Onair    alias=cOAM_admin
    [Teardown]    CB007308-5G-AB_FID4657_keywords_AEQE.Disconnect from DU

Gnb Cell Should Be Onair
    [Arguments]    ${alias}=default    ${cell_type}=nr
    [Documentation]    Gnb Cell Should Be Onair, check method is via REST
    log to console    waiting for BTS onair
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal as strings    ${proceduralState}    OnAir

Du Reset
    [Arguments]    ${timeout}=300
    ...            ${wait_for_reconnection}=${True}
    ...            ${connection}=cOAM_admin
    log to console    BTS resetting...
    coam.Reset Site
    ...    timeout=${timeout}
    ...    wait_for_reconnection=${wait_for_reconnection}
    ...    connection=${connection}

Upload whitelist file
    [Arguments]    ${upload_whitelist_path}
    ...    ${remote_path}=${SFPwhitelist_remote_PATH}${SFPwhitelist_NAME}
    ...    ${logname}=${SFPwhitelist_NAME_REGEX}
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}
    ...   password=${DU_OAM_SSH_PASSWORD}    alias=GNB_OAM
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

Create dir
    ssh.Connect to    hostname=${test_pc_host}    username=${test_pc_username}
    ...   password=${test_pc_password}    alias=test_pc
    ssh.send command    command=mkdir -p ${OUTPUT DIR}/log/
    ...    connection=test_pc    timeout=15 s
    ssh.send command    command=chmod 777 ${OUTPUT DIR}/log
    ...    connection=test_pc    timeout=15 s
    [Teardown]    ssh.Disconnect    connection=test_pc

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

Set SFPWhiteList File Name
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}
    ...   password=${DU_OAM_SSH_PASSWORD}    alias=GNB_OAM
    ${SFPwhitelist_NAME}    CB007308-5G-AB_FID4657_keywords_AEQE.Get file name
    ...    connection=GNB_OAM
    Set Suite Variable    ${SFPwhitelist_NAME}
    [Teardown]    ssh.Disconnect    connection=GNB_OAM
    [Return]    ${SFPwhitelist_NAME}

Delete parameter in sfpwhitelist
    [Arguments]    ${sfp_model}
    ${xml_root} =     Myxml.parse xml     ${SFPwhitelist_PATH}${SFPwhitelist_NAME}
    ${xpath}=    set variable    ./record/ModuleName[.='${sfp_model}']/..
    ${value}=    Myxml.Get Element Count     ${xml_root}    xpath=${xpath}
    run keyword if    ${value} > 0     run keywords
    ...    Myxml.Remove Elements    ${xml_root}    xpath=${xpath}    AND
    ...    Myxml.Save Xml    ${xml_root}    ${OUTPUT DIR}/${SFPwhitelist_NAME}

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

check fault 4657
    ${i}    CB007308-5G-AB_common_keywords_AEQE.Get EIF1 Runtime number
    ${ii}    CB007308-5G-AB_common_keywords_AEQE.Get RF1 Runtime number
    CB007308-5G-AB_FID4657_keywords_AEQE.Connect to DU
    ${hw_path_list}    ${alarm_list}    ${fault_id_list}
    ...    CB007308-5G-AB_FID4657_keywords_AEQE.Get Alarm Info
    list should contain value    ${hw_path_list}    /SMOD_R-1/eif1/SFP_R-${i}
    list should contain value    ${hw_path_list}    /SMOD_R-1/rf1/SFP_R-${ii}
    list should contain value    ${hw_path_list}    /SMOD_R-1/rf1/RMOD_R-1/opt_if1/SFP_R-1
    FOR    ${item}    IN    @{alarm_list}
        should be equal    '${item}'    '${7100}'
    END
#    list should contain value    ${alarm_list}    ${7100}
    [Teardown]    CB007308-5G-AB_FID4657_keywords_AEQE.Disconnect from DU

check none fault 4657
    CB007308-5G-AB_FID4657_keywords_AEQE.Connect to DU
    ${hw_path_list}    ${alarm_list}    ${fault_id_list}
    ...    CB007308-5G-AB_FID4657_keywords_AEQE.Get Alarm Info
    list should not contain value    ${fault_id_list}    ${4657}
    [Teardown]    CB007308-5G-AB_FID4657_keywords_AEQE.Disconnect from DU

perform muti Parameter recommissioning
    [Arguments]   ${dist_name}    ${parameter}   ${value}     ${operation}=update
    ...    ${connection}=cOAM_admin    ${skip_parameter_relation_errors}=${True}
    ...    ${should_activate}=${True}
    coam.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}
    ...    operation=${operation}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}
    ...    connection=${connection}

change sfpOperatorMode to true
    CB007308-5G-AB_FID4657_keywords_AEQE.Connect to DU
    CB007308-5G-AB_FID4657_keywords_AEQE.perform muti Parameter recommissioning
    ...    dist_name=${dist_sfpOperatorMode}    parameter=${sfpOperatorMode}    value=${True}
    [Teardown]    CB007308-5G-AB_FID4657_keywords_AEQE.Disconnect from DU

change sfpOperatorMode to false
    CB007308-5G-AB_FID4657_keywords_AEQE.Connect to DU
    CB007308-5G-AB_FID4657_keywords_AEQE.perform muti Parameter recommissioning
    ...    dist_name=${dist_sfpOperatorMode}    parameter=${sfpOperatorMode}    value=${False}
    [Teardown]    CB007308-5G-AB_FID4657_keywords_AEQE.Disconnect from DU

Get EIF1 distname
    ${connection}    CB007308-5G-AB_FID4657_keywords_AEQE.Connect to DU    alias=gnb
    FOR     ${i}    IN RANGE    ${1}    ${17}
        ${Connector_status}    coam.get_parameters
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/CONNECTOR_L-${i}
        ...              connection=${connection}
        ${label}    get from dictionary    ${Connector_status}     connectorLabel
        ${if_EIF1}     run keyword and return status    should be equal     ${label}   EIF1
        Exit For Loop If    '${if_EIF1}'=='${True}'
    END
    [Return]    ${i}
    [Teardown]    CB007308-5G-AB_FID4657_keywords_AEQE.Disconnect from DU    alias=${connection}

Get RF1 distname
    ${connection}    CB007308-5G-AB_FID4657_keywords_AEQE.Connect to DU    alias=gnb
    FOR     ${i}    IN RANGE    ${1}    ${17}
        ${Connector_status}    coam.get_parameters
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/CONNECTOR_L-${i}
        ...              connection=${connection}
        ${label}    get from dictionary    ${Connector_status}     connectorLabel
        ${if_RF1}     run keyword and return status    should be equal     ${label}    RF1
        Exit For Loop If    '${if_RF1}'=='${True}'
    END
    [Return]    ${i}
    [Teardown]    CB007308-5G-AB_FID4657_keywords_AEQE.Disconnect from DU    alias=${connection}

Get Availability status for SFP
    [Arguments]    ${i}    ${ii}
    ${connection}    CB007308-5G-AB_FID4657_keywords_AEQE.Connect to DU    alias=gnb
    ${RF1_status}    coam.get_parameters
    ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/CONNECTOR_L-${ii}/SFP_L-1
    ...                 pattern=availabilityStatus    connection=${connection}
    ${EIF1_status}    coam.get_parameters
    ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/CONNECTOR_L-${i}/SFP_L-1
    ...                 pattern=availabilityStatus    connection=${connection}
    ${RMOD_status}    coam.get_parameters
    ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/CONNECTOR_L-1/SFP_L-1
    ...                 pattern=availabilityStatus    connection=${connection}
    ${EIF1_status_dic}        get from dictionary    ${EIF1_status}    stateInfo
    ${EIF1_SFP_status}        get from dictionary    ${EIF1_status_dic}    availabilityStatus
    ${RF1_SFP_status_dic}     get from dictionary    ${RF1_status}    stateInfo
    ${RF1_SFP_status}         get from dictionary    ${RF1_SFP_status_dic}     availabilityStatus
    ${RMOD_SFP_status_dic}    get from dictionary    ${RMOD_status}    stateInfo
    ${RMOD_SFP_status}        get from dictionary    ${RMOD_SFP_status_dic}    availabilityStatus
    [Return]    ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}
    [Teardown]    CB007308-5G-AB_FID4657_keywords_AEQE.Disconnect from DU    alias=${connection}

Check SFP availability status
    [Arguments]   ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}    ${expected_status}
    Run keyword and continue on failure    should be equal    ${EIF1_SFP_status}    ${expected_status}
    Run keyword and continue on failure    should be equal    ${RMOD_SFP_status}    ${expected_status}
    should be equal    ${RF1_SFP_status}    ${expected_status}






