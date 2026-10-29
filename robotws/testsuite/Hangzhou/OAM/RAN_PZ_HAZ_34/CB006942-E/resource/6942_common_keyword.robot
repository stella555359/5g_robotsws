*** Settings ***
Documentation
...               author: Steven Liu
...               contact: steven.liu@nokia-sbell.com
...               squad group: MMW_SG_04

Library           XML     use_lxml=True
Library           Collections
Library           String
Library           OperatingSystem
Library           taf.transport.ssh         WITH NAME    ssh
#Library           taf.sbts.oam.coam.admin    WITH NAME    coam

Library           taf.hw.optical_switch    WITH NAME    fiberswitch
#Resource          taf/rfrl/common_resources/robot/coam.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library           ./check_tem.py





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
#${SFPwhitelist_PATH}               ${output_dir}/
${SFPwhitelist_PATH}               ${OUTPUT DIR}/
${SFPwhitelist_remote_PATH}        /ffs/run/swpool/OAM/
${SFPwhitelist_NAME_REGEX}         sfpWhitelist*.xml

${ROOT_USERNAME}                   ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${ROOT_PASSWORD}                   ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${LMP_IP}=                         ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${default_scf}                     ${CURDIR}/../../../../../../commissionings/HGZ/7_5_UTE5G402T706/DU_SCF.xml


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
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${alias}
    ${conn}    set variable    ${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    coam.teardown     connection=${alias}

Reset DU
    Connect to DU
    Du Reset
    Wait Until Keyword Succeeds    1000s    10s    Gnb Cell Should Be Onair    alias=cOAM_admin
    [Teardown]    Disconnect from DU

Gnb Cell Should Be Onair
    [Arguments]    ${alias}=default    ${cell_type}=nr
    [Documentation]    Gnb Cell Should Be Onair, check method is via REST
    log to console    waiting for BTS onair
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    ${status1}   run keyword and return status    Should Be Equal as strings    ${proceduralState}    OnAir
    ${status2}   run keyword and return status    Should Be Equal as strings    ${proceduralState}    Commissioned
    should be true      ${status1} or ${status2}
    #cell info
    ${cell_status}    coam.Get_Cells_Info    cell_type=${cell_type}     connection=${alias}
    ${Status}    Get From Dictionary    ${cell_status[0]}    status
    ${tmp}   Get From Dictionary    ${status}  usageState
    Should Be Equal as strings    ${tmp}    Active

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
    ssh.send command    command=mkdir -p ${output_dir}/log/
    ...    connection=test_pc    timeout=15 s
    ssh.send command    command=chmod 777 ${output_dir}/log
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
    ${SFPwhitelist_NAME}    Get file name    connection=GNB_OAM
    Set Suite Variable    ${SFPwhitelist_NAME}
    [Teardown]    ssh.Disconnect    connection=GNB_OAM
    [Return]    ${SFPwhitelist_NAME}

Delete parameter in sfpwhitelist
    [Arguments]    ${sfp_model}
    ${xml_root} =     XML.parse xml     ${SFPwhitelist_PATH}${SFPwhitelist_NAME}
    ${xpath}=    set variable    ./record/ModuleName[.='${sfp_model}']/..
#    ${text} =    XML.get elements    ${xml_root}    xpath=${xpath}
    ${value}=    XML.Get Element Count     ${xml_root}    xpath=${xpath}
    run keyword if    ${value} > 0     run keywords
    ...    XML.Remove Elements    ${xml_root}    xpath=${xpath}    AND
    ...    XML.Save Xml    ${xml_root}    ${output_dir}/${SFPwhitelist_NAME}

Get Alarm Info
    [Arguments]    ${timeout}=50s    ${connection}=cOAM_admin
#    sleep    10s
    @{alarms}    coam.get_active_alarms    timeout=${timeout}    connection=cOAM_admin
    sleep    1s
    log     ${alarms}
    ${hw_path_list}    create list
    ${alarm_list}    create list
    ${fault_id_list}    create list
    ${fault_name_list}    create list
    FOR    ${item}    IN     @{alarms}
        ${fault_id}    get from dictionary    ${item}      faultId
        ${hw_path}    get from dictionary    ${item}      hwPath
        ${alarm_id}    get from dictionary    ${item}      alarmId
        run keyword if    '${fault_id}'=='4657'    append to list    ${hw_path_list}    ${hw_path}
        run keyword if    '${fault_id}'=='4657'    append to list    ${alarm_list}    ${alarm_id}
    END
    FOR    ${item}    IN    @{alarms}
        ${fault_id}    get from dictionary    ${item}    faultId
        ${fault_name}    get from dictionary    ${item}    faultName
        append to list    ${fault_id_list}    ${fault_id}
        append to list    ${fault_name_list}    ${fault_name}
    END
    [Return]    ${hw_path_list}    ${alarm_list}    ${fault_id_list}    ${fault_name_list}

check fault 4657 old
    Connect to DU
    ${hw_path_list}    ${alarm_list}    ${fault_id_list}    ${fault_name_list}    Get Alarm Info
    ${status}     set variable    ${False}
    FOR     ${item}     IN     @{hw_path_list}
        ${status}    run keyword and return status    should contain    ${item}    /SMOD_R-1/eif1/SFP_R-
        exit for loop if    ${status}
    END
    run keyword if  not ${status}     FAIl
    ${status1}    run keyword and return status     list should contain value    ${hw_path_list}    /SMOD_R-1/BBMOD_R-1(Right_Bottom)/s_rf1/SFP_R-1
    ${status2}    run keyword and return status     list should contain value    ${hw_path_list}    /SMOD_R-1/BBMOD_R-1(Right_Bottom)/s_rf1/SFP_R-1
    ${status3}    run keyword and return status     list should contain value    ${hw_path_list}    /SMOD_R-1/BBMOD_R-1(Right_Bottom)/rf1/SFP_R-1
    ${status4}    run keyword and return status     list should contain value    ${hw_path_list}   /SMOD_R-1/BBMOD_R-1(Right_Bottom)/s_rf1/SFP_R-1
    should be true    "${status1}"=="True" or "${status2}"=="True" or "${status3}"=="True" or "${status4}"=="True"
    ${status5}    run keyword and return status     list should contain value
    ...    ${hw_path_list}    /SMOD_R-1/BBMOD_R-1(Right_Bottom)/rf1/RMOD_R-1/opt_if1/SFP_R-1
    ${status6}    run keyword and return status     list should contain value
    ...    ${hw_path_list}    /SMOD_R-1/BBMOD_R-1(Right_Bottom)/s_rf1/RMOD_R-1/opt_if1/SFP_R-1
    ${status7}    run keyword and return status     list should contain value
    ...    ${hw_path_list}     /SMOD_R-1/BBMOD_R-1(Right_Bottom)/rf1/RMOD_R-1/opt_if1/SFP_R-1
    should be true    "${status5}"=="True" or "${status6}"=="True" or "${status7}"=="True"
    FOR    ${item}    IN    @{alarm_list}
        should be equal    '${item}'    '${7100}'
    END
#    list should contain value    ${alarm_list}    ${7100}
    [Teardown]    Disconnect from DU

check fault 4657
    ${i}    Get EIF1 Runtime number
    ${ii}    Get RF1 Runtime number
    Connect to DU
    ${hw_path_list}    ${alarm_list}    ${fault_id_list}    Get Alarm Info
    list should contain value    ${hw_path_list}    /SMOD_R-1/eif1/SFP_R-${i}
    list should contain value    ${hw_path_list}    /SMOD_R-1/rf1/SFP_R-${ii}
    list should contain value    ${hw_path_list}    /SMOD_R-1/rf1/RMOD_R-1/opt_if1/SFP_R-1
    FOR    ${item}    IN    @{alarm_list}
        should be equal    '${item}'    '${7100}'
    END
#    list should contain value    ${alarm_list}    ${7100}
    [Teardown]    Disconnect from DU

Get EIF1 Runtime number
    ${connection}      Connect to DU        alias=cOAM_admin
    FOR     ${i}    IN RANGE    ${1}    ${16}
        ${SFP_status}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${i}
        ...              connection=${connection}
        ${label}    get from dictionary    ${SFP_status}     physicalPort
        ${if_EIF1}     run keyword and return status    should be equal     ${label}   EIF1
        Exit For Loop If    '${if_EIF1}'=='${True}'
    END
    [Return]    ${i}
    [Teardown]     Disconnect from DU    alias=${connection}

Get RF1 Runtime number
    ${connection}     Connect to DU     alias=cOAM_admin
    FOR     ${i}    IN RANGE    ${1}    ${16}
        ${SFP_status}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${i}
        ...              connection=${connection}
        ${label}    get from dictionary    ${SFP_status}     physicalPort
        ${if_RF1}     run keyword and return status    should be equal     ${label}   RF1
        Exit For Loop If    '${if_RF1}'=='${True}'
    END
    [Return]    ${i}
    [Teardown]     Disconnect from DU    alias=${connection}

check none fault 4657
    Connect to DU
    ${hw_path_list}    ${alarm_list}    ${fault_id_list}    ${fault_name_list}    Get Alarm Info
    list should not contain value    ${fault_id_list}    ${4657}
    [Teardown]    Disconnect from DU

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

change sfpOperatorMode to true
    Connect to DU
    perform muti Parameter recommissioning    dist_name=${dist_sfpOperatorMode}    parameter=${sfpOperatorMode}    value=${True}
    [Teardown]    Disconnect from DU

change sfpOperatorMode to false
    Connect to DU
    perform muti Parameter recommissioning    dist_name=${dist_sfpOperatorMode}    parameter=${sfpOperatorMode}    value=${False}
    [Teardown]    Disconnect from DU

Case Teardown
    CI_interface.Common Case Teardown
    change sfpOperatorMode to false
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
    [Teardown]    ssh.Disconnect    connection=test_pc

#CB006942 common keyword
Admin Reset BTS
    [Arguments]    ${alias}=cOAM_admin
    coam.Reset Site    connection=${alias}

Check if static data SFP for fronthaul
    ${Cooled_Transceiver}    Get SCF single Value from current xml file
    ...   parameter=cooledTransceiverDeclaration   list_name=${None}
    ...   dist_name=MRBTS-${MRBTS_ID}/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1/SFP_R-1   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    ${Cooled_Transceiver1}    Get SCF single Value from current xml file
    ...   parameter=cooledTransceiverDeclaration   list_name=${None}
    ...   dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1/SFP_R-1   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    run keyword if    '${Cooled_Transceiver}'=='true' or '${Cooled_Transceiver1}'=='true'    log to console    PASS    ELSE    Fail

ADMIN Wait Until BTS OnAir
    [Arguments]    ${timeout}=15 min
    ...            ${interval}=30 sec
    ...            ${alias}=cOAM_admin
    Wait Until Keyword Succeeds    ${timeout}
    ...                            ${interval}
    ...                            ADMIN Check onair
    ...                            admin_alias=${alias}

ADMIN Check onair
    [Arguments]        ${admin_alias}=${LOGGING_ADMIN_ALIAS}
    ${dict_info}=    coam.Get Bts Info    connection=${admin_alias}
    ${state}=    Get From Dictionary    dictionary=${dict_info['status']}    key=proceduralState
    Should be equal    ${state}    OnAir

Check SFP temperature
    [Arguments]    ${parameter}
    ${TEM1}   Get SCF single Value from current xml file
    ...   parameter=${parameter}   list_name=${None}   dist_name=MRBTS-${MRBTS_ID}/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1/SFP_R-1   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    ${TEM2}    Get SCF single Value from current xml file
    ...   parameter=${parameter}   list_name=${None}   dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1/SFP_R-1   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    [Return]    ${TEM1}    ${TEM2}

Check SFPS Module temperature
    ssh connect to DU
    ssh.send command                    command=awk 'NR==37 {print $3}' /tmp/sfp.csv > temperature.csv
    ...                                 connection=cOAM_toor4nsn
    ssh.download_file                   remote_path=/user/toor4nsn/temperature.csv
    ...                                 local_path=./temperature.csv
    ...                                 connection=cOAM_toor4nsn
    ${temperature_value}=                get_temperature_value
    [Return]    ${temperature_value}
    [Teardown]  ssh.disconnect          connection=cOAM_toor4nsn

compare the temperature for SFP
    ${TEM1}    ${TEM2}    Check SFP temperature   parameter=temperatureHighAlarmThreshold
    ${TEMHIGH}    set variable if    '${TEM1}'=='[]'    ${TEM2}    ${TEM1}
    ${TEM1}    ${TEM2}    Check SFP temperature    parameter=temperatureLowAlarmThreshold
    ${TEMLOW}    set variable if    '${TEM1}'=='[]'    ${TEM2}    ${TEM1}
    ${temperature_value}    Check SFPS Module temperature
    Should Be True    ${TEMLOW}<=${temperature_value}<=${TEMHIGH}

ssh connect to DU
    [Arguments]  ${ip_address}=${LMP_IP}  ${alias}=cOAM_toor4nsn  ${password}=${ROOT_PASSWORD}
    ${connection}=  ssh.Connect to  ${ip_address}
    ...                             ${ROOT_USERNAME}
    ...                             ${password}
    ...                             alias=${alias}
    [Return]  ${connection}

Check BTS is in On Air
    Connect to DU
    ADMIN Wait Until BTS OnAir
    [Teardown]    Disconnect from DU

Check BTS startup
    Connect to DU
    Admin Reset BTS
    [Teardown]    Disconnect from DU

BTS detects cooled SFP+/SFP28
    Connect to DU
    ADMIN Wait Until BTS OnAir
    Check if static data SFP for fronthaul
    [Teardown]    Disconnect from DU

BTS detects cooled2 SFP+/SFP28
    Connect to DU
    ADMIN Wait Until BTS OnAir
    compare the temperature for SFP
    [Teardown]    Disconnect from DU

#5GC0022269 common keyword
check Cell after Locked
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=cOAM_admin
    ...    ${operationalState}=Disabled    ${availabilityStatus}=Offline    ${administrativeState}=Locked
    ${subcell_status}=    Get GNB Cell Status      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Should Be Equal As Strings  ${subcell_status["operationalState"]}   ${operationalState}
    Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}  ${availabilityStatus}
    Should Be Equal As Strings  ${subcell_status["administrativeState"]}  ${administrativeState}

Switch fiber channels and verify fiber channels status
    [Arguments]  ${cross_connection_setting}
    ...    ${vendor}=${tl.optical_switches[0].__class__.__name__}
    ...    ${model}=${tl.optical_switches[0].model}
    ...    ${addr}=${tl.optical_switches[0].addr}
    ...    ${port}=4001
    fiberswitch.setup_optical_switch    optical_switch=${vendor}    alias=switch1    model=${model}    addr=${addr}   port=${port}
    fiberswitch.get_optical_switch_channels    optical_switch_device=switch1
    fiberswitch.set_optical_switch_channels    settings=${cross_connection_setting}    optical_switch_device=switch1
    sleep      2s
    fiberswitch.get_optical_switch_channels    optical_switch_device=switch1
    [Teardown]    fiberswitch.teardown     optical_switch_device=switch1

Get GNB Cell Status
    [Arguments]  ${cell_idx}   ${cell_group_idx}   ${timeout}=10   ${connection}=cOAM_admin
    ${subcells_status}    coam.get_subcells_status   timeout=${timeout}    connection=${connection}
    ${status_dict}   Catenate   'operationalState':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["operationalState"]}',
    ...                         'availabilityStatus':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["availabilityStatus"]}',
    ...                         'administrativeState':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["administrativeState"]}'
    ${subcell_status}    Evaluate   {${status_dict}}
    [Return]   ${subcell_status}

update default scf
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${default_scf}    is_pdl_checking_needed=${False}
    [Teardown]    COAM Teardown gnb connections

5GC0022269 Case Teardown
    FOR   ${n}    IN RANGE    ${2}
        ${enableport}    set variable    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[${n}].switch_module.module_no}
        ${cross_port_setting}    Create Dictionary    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[${n}].switch_module.module_no}=${enableport}
        Switch fiber channels and verify fiber channels status      cross_connection_setting=${cross_port_setting}
    END
    sleep    10min
    Connect to DU    alias=cOAM_admin
    Wait Until Keyword Succeeds   3 min  30 sec    RU Should Be Locked    connection=cOAM_admin
    Perform RU unlock via rest api    connection=cOAM_admin
    Wait Until Keyword Succeeds   3 min  5 sec    ADMIN Wait Until BTS OnAir
    Disconnect from DU    alias=cOAM_admin
    CI_interface.Common Case Teardown

Lock Ru and check Status
    [Arguments]      ${connection}=cOAM_admin
    Connect to DU
    Perform RU lock via rest api     connection=${connection}
    RU Should Be Locked     connection=${connection}
    Wait Until Keyword Succeeds   1 min  5 sec   check Cell after Locked
    ...    cell_idx=0   cell_group_idx=0    operationalState=disabled
    ...    availabilityStatus=dependency   administrativeState=Unlocked   connection=${connection}
    [Teardown]    Disconnect from DU

get fault10
    Connect to DU
    ${hw_path_list}    ${alarm_list}    ${faultlist1}    ${fault_name_list}    Get Alarm Info    timeout=1
    Run Keyword And Continue On Failure    list should contain value    ${faultlist1}    ${10}
    [Teardown]    Disconnect from DU
