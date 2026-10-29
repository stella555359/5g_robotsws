#*** Settings ***
#Force Tags    PY36
#Suite Setup
#Suite Teardown
#Documentation
#...   author: xiaofeng.1.zhu@nokia-sbell.com
#...   contact: xiaofeng.1.zhu@nokia-sbell.com
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
#Library           taf.transport.ssh    WITH NAME    csn
#Library           taf.hw.rf_attenuator    WITH NAME    att
#Library           taf.ue  WITH NAME   ute_ue
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#Library    taf.analyzer.pcap    WITH NAME    check_cap
#Library           taf.collectors.btslog    WITH NAME   btslog
#Library           taf.collectors.core   WITH NAME   core
#Library           ./Resources/CB005750-5G-EAAI.py
#Variables         ./Resources/CB005750-5G-EAAI_modify_para.py
#Library           ./Resources/common_keyword.py
#
#*** Variables ***
#${DU_OAM_IP_URL}            https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
#${DU_OAM_WEBUI_IP}         ${tl.gnbs[0].dus[0].f1_m_ip_addr}
#${DU_OAM_WEBUI_USER}        ${tl.gnbs[0].cu.oam_http_connection_details.username}
#${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
#${DU_OAM_IP_TL}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
#${DU_OAM_SSH_USERNAME_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
#${DU_OAM_SSH_PASSWORD_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
#${SHM_IP}                      ${tl.gnbs[0].slave[0].f1_m_ip_addr}
#${BTS_ID_M}                    ${tl.gnbs[0].instance_id}
#${BTS_ID_S}                    ${tl.gnbs[0].slave[0].instance_id}
#${TEST_PC_IP}                 ${tl.test_pc.default_ssh_connection_details.addr}
#${TEST_PC_USERNAME}           ${tl.test_pc.default_ssh_connection_details.username}
#${TEST_PC_PASSWORD}           ${tl.test_pc.default_ssh_connection_details.password}
#${SLAVE_PC_IP}                ${tl.gnbs[0].master[0].f1_m_ip_addr}
#${DU_OAM_IP}                  ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
#${connection}                GNB_OAM
#${connection1}               CELL_ONAIR
#${luashark_path}             /opt/ute/luashark/luashark_script/generated_luashark
#${TS_CASE_LOG_PATH}          ${output_dir}
#${epc_log_path}              /tmp
#${source}                    ${output_dir}/bts_log.log
#${source1}                   /ffs/run/swconfig.txt
#${Test_Case_Name}           5GC005750_BTSLOG
#
#*** Test Cases ***
#[1]CB005750-5G-EAAI_TC05_5GC000315_5GC000317_Verify_alarms_and_faults_at_5gNB_when_signal_failure_of_external_GNSS_or_1PPS_ToD_input
#    [Documentation]    Hub Master and Slave Phase Tuning and Phase accuracy reports
#    [Tags]    CB005750-EAAI    CRT_21A    CRT_TRUNK    CRT_21B     CRT_22R1
#    [Setup]    Prepare GPS and TOPP status
#    GNSS Check and Trigger alarm
#    switch TOPP and Trigger alarm
#    [Teardown]    CI_interface.Common Case Teardown
#
#*** Keywords ***
#GNSS Check and Trigger alarm
#    Change DUPC IP
#    log to console    start get btslog
#    Start btslog on ute and Check btslog    time=2min   ppb_value=20  ns_value_scope=0.5    BTS_IP=${DU_OAM_IP_TL}
#    check master btslog    PC_IP=${TEST_PC_IP}    BTS_IP=${DU_OAM_IP_TL}
#    Check accuracy lpp    PC_IP=${TEST_PC_IP}    limit1=${500}    BTS_IP=${DU_OAM_IP_TL}
#    Get sync status    BTS_IP=${DU_OAM_IP_TL}    Type=1pps/ToD from external GNSS receiver
#    log to console    start check slave btslog
#    check SHS btslog    PC_IP=${TEST_PC_IP}    BTS_IP=${SHM_IP}
#    Check accuracy lpp    PC_IP=${TEST_PC_IP}    limit1=${1500}    BTS_IP=${SHM_IP}
#    Get sync status    BTS_IP=${SHM_IP}   Type=1pps/ToD from Sync Hub Master
#    log to console    start get slave btslog
#    Trigger alarm and recovery
#    [Teardown]    End case
#
#Start btslog on ute and Check btslog
#    [Arguments]    ${time}    ${ppb_value}   ${ns_value_scope}    ${BTS_IP}
#    Connect to gnb coam via ssl    bts_host=${BTS_IP}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
#    BTSLOG Start btslog on local machine
#    sleep    ${time}
#    BTSLOG Collect btslog
#    Teardown gNB cOAM SSL Connection
#    Check logfile if message is right    ppb_value=${ppb_value}   ns_value_scope=${ns_value_scope}
#
#BTSLOG Start btslog on local machine
#    [Arguments]   ${name}=btslog
#    ...           ${bts_logs_dir}=/tmp/btslog2
#    __Make empty BTS logs dir      ${bts_logs_dir}
#    btslog.create_btslog_collector
#    ...    name=${name}
#    ...    log_dir=${bts_logs_dir}
#    core.setup_collectors        names=${name}
#    core.start_collectors        names=${name}
#    btslog.set_suite_alias       ${name}
#
#__Make empty BTS logs dir
#    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
#    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi
#
#BTSLOG Collect btslog
#    [Arguments]  ${bts_logs_dir}=/tmp/btslog2
#    __Stop and collect btslog on local machine
#    __Copy btslog to logs dir and clean BTSlog workspace    ${bts_logs_dir}
#
#__Stop and collect btslog on local machine
#    [Arguments]   ${name}=btslog
#    core.stop_collectors         names=${name}
#    core.collect_collectors      names=${name}
#    core.teardown_collectors     names=${name}
#
#__Copy btslog to logs dir and clean BTSlog workspace
#    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
##	Run  mkdir ${output_dir}/${TEST_NAME}
#	Run  mkdir ${output_dir}/${Test_Case_Name}
#    Run  mv ${bts_logs_dir}/syslog_files.tgz ${output_dir}/${Test_Case_Name}/syslog_files.tgz
#    Run  rm ${bts_logs_dir}/*
#
#Teardown gNB cOAM SSL Connection
#    [Arguments]    ${connection}=GNB_OAM
#    coam.teardown    connection=GNB_OAM
#
#Check logfile if message is right
#    [Arguments]    ${ppb_value}   ${ns_value_scope}
#    csn.Connect to     hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}	alias=TESTPC
#    csn.execute    command=tar zxvf ${output_dir}/${Test_Case_Name}/syslog_files.tgz -C ${output_dir}/${Test_Case_Name}/    connection=TESTPC
#	csn.execute    command=mv ${output_dir}/${Test_Case_Name}/*.LOG ${output_dir}/bts_log.log    connection=TESTPC
#    ${message} =    OperatingSystem.Grep File    ${output_dir}/bts_log.log    Estimator output
#    [Teardown]    Csn.Disconnect	connection=TESTPC
#
#check SHS btslog
#    [Arguments]    ${PC_IP}    ${BTS_IP}
#    csn.Connect to     hostname=${PC_IP}   username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
#    csn.Send Command    command=cat ${source} |grep ${BTS_IP} |grep TSIP_0x1C_0x83 |grep Hardware |grep version
#    ...    connection=${connection}
#    ${Hardware}  csn.Read Output    connection=${connection}
#    should not be empty    ${Hardware}
#
#    csn.Send Command    command=cat ${source} |grep ${BTS_IP} |grep TSIP_0x8F_0xAB |grep Primary |grep timing
#    ...    connection=${connection}
#    ${Primary}  csn.Read Output    connection=${connection}
#    should not be empty    ${Primary}
#
#    csn.Send Command    command=cat ${source} |grep ${BTS_IP} |grep TSIP_0x8F-AC |grep MinorAlarms
#    ...    connection=${connection}
#    ${MinorAlarms}  csn.Read Output    connection=${connection}
#    should not be empty    ${MinorAlarms}
#
#    csn.Send Command    command=cat ${source} |grep ${BTS_IP} |grep TSIP_0x8F_0xF2 |grep SyncHub |grep Information
#    ...    connection=${connection}
#    ${Information}  csn.Read Output    connection=${connection}
#    should not be empty    ${Information}
#
#    csn.Send Command    command=cat ${source} |grep ${BTS_IP} |grep TSIP_0x8F_0xF3 |grep SyncHub
#    ...    connection=${connection}
#    ${SyncHub}  csn.Read Output    connection=${connection}
#    should not be empty    ${SyncHub}
#    log to console    check btslog successful
#
#    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
#check master btslog
#    [Arguments]    ${PC_IP}    ${BTS_IP}
#    csn.Connect to     hostname=${PC_IP}   username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
#    csn.Send Command    command=cat ${source} |grep ${BTS_IP} |grep TSIP_0x1C_0x83 |grep Hardware |grep version
#    ...    connection=${connection}
#    ${Hardware}  csn.Read Output    connection=${connection}
#    should not be empty    ${Hardware}
#
#    csn.Send Command    command=cat ${source} |grep ${BTS_IP} |grep TSIP_0x8F_0xAB |grep Primary |grep timing
#    ...    connection=${connection}
#    ${Primary}  csn.Read Output    connection=${connection}
#    should not be empty    ${Primary}
#
#    csn.Send Command    command=cat ${source} |grep ${BTS_IP} |grep TSIP_0x8F-AC |grep MinorAlarms
#    ...    connection=${connection}
#    ${MinorAlarms}  csn.Read Output    connection=${connection}
#    should not be empty    ${MinorAlarms}
#
#    csn.Send Command    command=cat ${source} |grep ${BTS_IP} |grep TSIP_0x6C |grep Receiver |grep position
#    ...    connection=${connection}
#    ${Receiver}  csn.Read Output    connection=${connection}
#    should not be empty    ${Receiver}
#
#    csn.Send Command    command=cat ${source} |grep ${BTS_IP} |grep TSIP_0x47 |grep Satellite |grep Signal
#    ...    connection=${connection}
#    ${Satellite}  csn.Read Output    connection=${connection}
#    should not be empty    ${Satellite}
#    log to console    check btslog successful
#
##    csn.Send Command    command=cat ${source} |grep ${BTS_IP}    connection=${connection}
##    ${IP}  csn.Read Output    connection=${connection}
##    should not be empty    ${IP}
#    log to console    check btslog successful
#
#    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
#Check accuracy lpp
#    [Arguments]    ${PC_IP}   ${limit1}    ${BTS_IP}
#    csn.Connect to     hostname=${PC_IP}   username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
#    csn.Send Command    command=cat ${source} |grep ${BTS_IP} |grep phase_error:|cut -d '[' -f 5|cut -d ':' -f 2|cut -d 'n' -f 1|head -1|tr '\n' ' '
#    ...    connection=${connection}
#    ${phase}  csn.Read Output    connection=${connection}
#    should not be empty    ${phase}
#    ${phase}    Evaluate    abs(int(${phase}))
#    log to console    ${phase}
#    should be true    ${phase} < ${limit1}
#    log to console    check lpp successful
#    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
#Get sync status
#    [Arguments]    ${BTS_IP}    ${Type}
#    coam.connect_to    bts_host=${BTS_IP}   name=${connection}
#    ${sync}    coam.get_bts_sync_source_status    connection=${connection}
#    log to console    ${sync}
#    Check sync status     sync=${sync}    Type=${Type}
#    check cell onair    BTS_IP=${BTS_IP}
#    [Teardown]    run keyword and ignore error    coam.teardown       connection=${connection}
#
#check cell onair
#    [Arguments]    ${BTS_IP}
#    coam.connect_to    bts_host=${BTS_IP}   name=${connection1}
#    ${cell_info}    coam.get_bts_statuses    connection=${connection1}
#    log to console    ${cell_info}
#    ${status}    get from dictionary    ${cell_info}    proceduralState
#    should be equal as strings    ${status}    OnAir
#    log to console    check cell onair...
#    [Teardown]    run keyword and ignore error    coam.teardown       connection=${connection1}
#
#Check sync status
#    [Arguments]  ${sync}    ${Type}
#    ${syncMode}    get from dictionary    ${sync}    syncMode
#    ${tuningMode}    get from dictionary    ${sync}    tuningMode
#    ${syncSourceInfo}    get from dictionary    ${sync}    syncSourceInfo
#    ${syncSource}    Get From List    ${syncSourceInfo}    0
#    ${isActive}    get from dictionary    ${syncSource}    isActive
#    ${status}    get from dictionary    ${syncSource}    status
#    ${availability}    get from dictionary    ${status}    availability
#    ${usability}    get from dictionary    ${status}    usability
#    ${syncInputType}    get from dictionary    ${syncSource}    syncInputType
#
#    log to console    syncMode:${syncMode}
#    log to console    tuningMode:${tuningMode}
#    log to console    syncSourceInfo:${syncSourceInfo}
#    log to console    syncSource:${syncSource}
#    log to console    isActive:${isActive}
#    log to console    status:${status}
#    log to console    availability:${availability}
#    log to console    usability:${usability}
#    log to console    syncInputType:${syncInputType}
#
#    Should Be Equal As Strings    '${syncMode}'    'PhaseSync'
#    Should Be Equal As Strings    '${tuningMode}'    'Normal tuning'
#    Should Be Equal As Strings    '${isActive}'    'True'
#    Should Be Equal As Strings    '${availability}'    'Available'
#    Should Be Equal As Strings    '${usability}'    'Usable'
#    Should Be Equal As Strings    '${syncInputType}'    '${Type}'
#    log to console    check sync status successful
#
#Delete TOPP keep GPS
#    [Arguments]    ${synctype}    ${bts_IP}    ${BTS_ID}    ${Num}=${1}
#    Log To Console    Delete GPS And Change Sync Input Type To TOPP
#    coam.connect_to    bts_host=${bts_IP}
#    ${object_list}    coam.get_managed_objects    class_name=CLOCK_A
#    ${object}     set variable    ${None}
#    FOR    ${item}    IN    @{object_list}
#         ${parameter_list}    get from dictionary     ${item}    parameters
#         ${sync_list}    get from dictionary    ${parameter_list}    syncInputList
#         ${object}     set variable if    ${sync_list}!=[]    ${item}
#         Exit For loop if    ${sync_list}!=[]
#    END
#    ${parameter}    get from dictionary     ${object}    parameters
#    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
#    remove from list    ${syncInputList}    ${Num}
#    set to dictionary    @{syncInputList}[0]     syncInputType=${synctype}
#    set to dictionary    @{syncInputList}[0]     syncInputPrio=1
#    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
#    ${list}    create list    ${dict}
#    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
#    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
#    sleep    100s
#    [Teardown]    run keyword and ignore error    coam.teardown
#
#Add GPS and TOPP
#    [Arguments]    ${synctype1}    ${synctype2}    ${bts_IP}    ${BTS_ID}
#    Log To Console    Add And Change Sync Input Type To TOPP
#    coam.connect_to    bts_host=${bts_IP}
#    ${object_list}    coam.get_managed_objects    class_name=CLOCK_A
#    ${object}     set variable    ${None}
#    FOR    ${item}    IN    @{object_list}
#         ${parameter_list}    get from dictionary     ${item}    parameters
#         ${sync_list}    get from dictionary    ${parameter_list}    syncInputList
#         ${object}     set variable if    ${sync_list}!=[]    ${item}
#         Exit For loop if    ${sync_list}!=[]
#    END
#    ${parameter}    get from dictionary     ${object}    parameters
#    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
#    set to dictionary    @{syncInputList}[0]     syncInputType=${synctype1}
#    set to dictionary    @{syncInputList}[0]     syncInputPrio=1
#    ${structure2}    create dictionary     syncInputPrio=2    syncInputType=${synctype2}
#    append to list    ${syncInputList}    ${structure2}
#    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
#    ${list}    create list    ${dict}
#    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
#    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
#    [Teardown]    run keyword and ignore error    coam.teardown
#
#Modify Value On DU
#    [Arguments]    ${structure_modify_list}    ${gNB_ip}    ${common_modify_list}=None    ${keywords_list}=None    ${connection}=GNB_connection
#    ...    ${class_name}=None   ${is_structure}=${True}    ${is_common}=${True}    ${structure_index}=0
#    coam.connect_to    bts_host=${gNB_ip}   name=${connection}
#    run keyword if  ${is_structure}    Modify Structure parameter via Coam    class_name=${class_name}   connection=${connection}
#    ...    modify_list=${structure_modify_list}    keywords_list=${keywords_list}    index=${structure_index}
#    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
#
#Modify Common parameter via Coam
#    [Arguments]  ${input_list}    ${bts_ip}    ${connection}=GNB_connection
#    log to console  Modify parameter
#    coam.connect_to    bts_host=${DU_OAM_IP_TL}   name=${connection}
#    sleep    10s
#    FOR    ${item}  IN    @{input_list}
#         ${dict_value}    Get Content From Input Dict    input_dict=${item}
#         coam.Perform Parameter Recommissioning    dist_name=@{dict_value}[0]   parameter=@{dict_value}[1]   value=@{dict_value}[2]
#         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
#    END
#    sleep  20s
#    [Teardown]    run keyword and ignore error    coam.teardown
#
#Modify Structure parameter via Coam
#    [Arguments]   ${class_name}   ${connection}   ${modify_list}   ${keywords_list}    ${index}=0
#    ${get_managed_objects}     coam.get_managed_objects     class_name=${class_name}    connection=${connection}
#    ${output_dict_list}    return_structure_value    input_list=${get_managed_objects}    modify_list=${modify_list}
#    ...    keywords_list=${keywords_list}
#    FOR    ${item}  IN  @{output_dict_list}
#         ${dict_value}    Get Content From Input Dict    input_dict=${item}
#         coam.Perform Parameter Recommissioning    dist_name=@{dict_value}[0]   parameter=@{dict_value}[1]   value=@{dict_value}[2]
#         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
#         sleep  30s
#    END
#
#Get Content From Input Dict
#    [Arguments]  ${input_dict}
#    ${dist_name}    get from dictionary     ${input_dict}    dist_name
#    ${parammeter}    get from dictionary    ${input_dict}    parameter
#    ${new_value}     get from dictionary    ${input_dict}    value
#    ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
#    [Return]  ${value_list}
#
#Change DUPC IP
##    Modify Value On DU     gNB_ip=${DU_OAM_IP_TL}    structure_modify_list=${parameter2}
##    ...    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
#    log to console    modify slave ute Ip
#    Modify Value On DU     gNB_ip=${SHM_IP}    structure_modify_list=${parameter5}
#    ...    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
#    Modify Value On DU     gNB_ip=${SHM_IP}    structure_modify_list=${parameter10}
#    ...    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
#
#
#Download swconfig
#    [Arguments]    ${BTS_IP}    ${backup_path}    ${connection_2}=Download
#    csn.connect_to   hostname=${BTS_IP}    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}
#    ...    alias=${connection_2}
#    csn.download_file   local_path=${backup_path}    remote_path=/ffs/run/swconfig.txt
#    ...    connection=${connection_2}
#    log to console  Download swconfig successful
#    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection_2}
#
#connect and Upload swconfig
#    [Arguments]    ${BTS_IP}    ${swconfig_path}
#    csn.connect_to   hostname=${BTS_IP}    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}     alias=${connection}
#    swconf.Upload swConfig file to asik and crasign    localFilePath=${swconfig_path}    asik_alias=${connection}
#    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
#Reset site
#    [Arguments]    ${BTS_IP}
#    log to console    reset site IP；${BTS_IP}
#    coam.connect_to    bts_host=${BTS_IP}   name=${connection}
#    coam.reset_site    connection=${connection}
#    [Teardown]    run keyword and ignore error    coam.teardown
#
#Trigger alarm and recovery
#    Modify Common parameter via Coam    bts_ip=${DU_OAM_IP_TL}    input_list=${parameter6}
#    Wait Until Keyword Succeeds    10min    10sec
#    ...    check DU alarm    BTS_IP=${DU_OAM_IP_TL}    fault_id=${7108}    fault_name=PPS reference missing
#    log to console    Check alarm successful
#    log to console    sleep 10min
#    sleep    10min
#    check DU alarm    BTS_IP=${DU_OAM_IP_TL}    fault_id=${7108}    fault_name=PPS reference missing
#    log to console    Check alarm successful
#    [Teardown]    Recover GPS alarm
#
#Recover GPS alarm
#    Modify Common parameter via Coam    bts_ip=${DU_OAM_IP_TL}    input_list=${parameter7}
#    sleep    2min
#    Wait Until Keyword Succeeds    10min    10sec
#    ...    recover alarm    BTS_IP=${DU_OAM_IP_TL}    fault_id=${7108}    fault_name=PPS reference missing
#    log to console    Recover alarm successful
#
#check DU alarm
#    [Arguments]    ${BTS_IP}    ${fault_id}    ${fault_name}
#    log to console    check alarm...
#    ${fault_id_list}    ${fault_name_list}    check alarm active    BTS_IP=${DU_OAM_IP_TL}
#    ${fault_id_list}    list should contain value     ${fault_id_list}    ${fault_id}
#    ${fault_name_list}    list should contain value     ${fault_name_list}    ${fault_name}
#
#recover alarm
#    [Arguments]    ${BTS_IP}    ${fault_id}    ${fault_name}
#    log to console    check alarm ...
#    ${fault_id_list}    ${fault_name_list}    check alarm active    BTS_IP=${DU_OAM_IP_TL}
#    list should not contain value     ${fault_id_list}    ${fault_id}
#    list should not contain value     ${fault_name_list}    ${fault_name}
#
#check alarm active
#    [Arguments]    ${BTS_IP}
#    log to console    start check alarm
#    coam.connect_to    bts_host=${BTS_IP}   name=${connection}
#    ${alarms}    coam.get_active_alarms    connection=${connection}
#    sleep    1s
#    log     ${alarms}
#    ${fault_id_list}    create list
#    ${fault_name_list}    create list
#    FOR    ${item}    IN    @{alarms}
#         ${fault_id}    get from dictionary    ${item}    alarmId
#         ${fault_name}    get from dictionary    ${item}    faultName
#         append to list    ${fault_id_list}    ${fault_id}
#         append to list    ${fault_name_list}    ${fault_name}
#    END
#    [Return]    ${fault_id_list}    ${fault_name_list}
#    [Teardown]    run keyword and ignore error    coam.teardown
#
#switch TOPP and Trigger alarm
#    log to console    ADD Master topp
#    sleep    1min
#    Delete TOPP keep GPS    synctype=TOPP    bts_IP=${DU_OAM_IP_TL}    BTS_ID=${BTS_ID_M}    Num=${0}
#    Modify Common parameter via Coam    bts_ip=${DU_OAM_IP_TL}    input_list=${parameter8}
#    sleep    1min
#    Wait Until Keyword Succeeds    10min    10sec
#    ...    check DU alarm    BTS_IP=${DU_OAM_IP_TL}    fault_id=${7108}    fault_name=ToP reference missing
#    log to console    Check alarm successful
#    log to console    sleep 10min
#    sleep    10min
#    check DU alarm    BTS_IP=${DU_OAM_IP_TL}    fault_id=${7108}    fault_name=ToP reference missing
#    [Teardown]    Recover TOPP alarm
#
#Recover TOPP alarm
#    log to console    Recover TOPP alarm
#    Modify Common parameter via Coam    bts_ip=${DU_OAM_IP_TL}    input_list=${parameter9}
#    sleep    1min
#    Wait Until Keyword Succeeds    10min    10sec
#    ...    recover alarm    BTS_IP=${DU_OAM_IP_TL}    fault_id=${7108}    fault_name=ToP reference missing
#    log to console    Recover alarm successful
#    [Teardown]    End topp check
#
#End topp check
#    Add GPS and TOPP    synctype1=TOPP    synctype2=1pps/ToD from external GNSS receiver    bts_IP=${DU_OAM_IP_TL}    BTS_ID=${BTS_ID_M}
#    [Teardown]    run keyword and ignore error    coam.teardown
#
#Prepare GPS and TOPP status
#    log to console    Delete Master topp
#    Run Keyword And Ignore Error    Delete TOPP keep GPS    synctype=1pps/ToD from external GNSS receiver
#    ...    bts_IP=${DU_OAM_IP_TL}    BTS_ID=${BTS_ID_M}    Num=${0}
#    Modify Common parameter via Coam    bts_ip=${DU_OAM_IP_TL}    input_list=${parameter0}
#    Modify Common parameter via Coam    bts_ip=${SHM_IP}    input_list=${parameter0}
#    Modify Common parameter via Coam    bts_ip=${DU_OAM_IP_TL}    input_list=${parameter1}
#    log to console    Delete SHM  topp
#    Delete TOPP keep GPS    synctype=1pps/ToD from Sync Hub Master    bts_IP=${SHM_IP}    BTS_ID=${BTS_ID_S}    Num=${0}
#
#End case
#    Run Keyword And Ignore Error    coam.teardown    connection=${connection}
#    log to console    ADD Master topp
#    Add GPS and TOPP    synctype1=1pps/ToD from external GNSS receiver    synctype2=TOPP    bts_IP=${DU_OAM_IP_TL}    BTS_ID=${BTS_ID_M}
#    log to console    ADD Master topp
#    Add GPS and TOPP    synctype1=1pps/ToD from Sync Hub Master    synctype2=TOPP    bts_IP=${SHM_IP}    BTS_ID=${BTS_ID_S}
#    Modify Value On DU     gNB_ip=${SHM_IP}    structure_modify_list=${parameter11}
#    ...    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
#    log to console    modify slave ute Ip
#    Modify Value On DU     gNB_ip=${SHM_IP}    structure_modify_list=${parameter4}
#    ...    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
#    Reset site    BTS_IP=${SHM_IP}
#    sleep    180s
#    Wait Until Keyword Succeeds    10min    10sec    check cell onair    BTS_IP=${SHM_IP}
