*** Settings ***
Force Tags    PY36
Suite Setup        robot_common_operations.Common Suite Setup
Suite Teardown     robot_common_operations.Common Suite Teardown

Documentation
...   author: xiaofeng.1.zhu@nokia-sbell.com
...   contact: xiaofeng.1.zhu@nokia-sbell.com
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.hw.rf_attenuator    WITH NAME    att
Library           taf.ue  WITH NAME   ute_ue
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library           taf/rfrl/utilities/parsers/check_cap.py    WITH NAME    check_cap
Library           taf.collectors.btslog    WITH NAME   btslog
Library           taf.collectors.core   WITH NAME   core
Library           ./Resources/CB005750-5G-EAAG.py
Variables         ./Resources/CB005750-5G-EAAG_modify_para.py
Library           ./Resources/common_keyword.py
Library           ute_syslog
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${DU_OAM_IP_URL}            https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_WEBUI_IP}         ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_WEBUI_USER}        ${tl.gnbs[0].cu.oam_http_connection_details.username}
${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_OAM_IP_TL}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${SHM_IP}                      ${tl.gnbs[0].slave[0].f1_m_ip_addr}
${BTS_ID_M}                    ${tl.gnbs[0].instance_id}
${BTS_ID_S}                    ${tl.gnbs[0].slave[0].instance_id}
${TEST_PC_IP}                 ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}           ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}           ${tl.test_pc.default_ssh_connection_details.password}
${SLAVE_PC_IP}                ${tl.gnbs[0].master[0].f1_m_ip_addr}
${DU_OAM_IP}                  ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${connection}                GNB_OAM
${connection1}               CELL_ONAIR
${luashark_path}             /opt/ute/luashark/luashark_script/generated_luashark
${TS_CASE_LOG_PATH}          ${output_dir}
${epc_log_path}              /tmp
${source1}                   /ffs/run/swconfig.txt
${Test_Case_Name}           5GC005750_BTSLOG

*** Test Cases ***
[1]CB005750-5G-EAAG_TC01_5GC000315_5GC000317_Sync_Hub_Master_and_Slave_Phase_Tuning_and_Phase_accuracy_reports
    [Documentation]    Hub Master and Slave Phase Tuning and Phase accuracy reports
    [Tags]    CRT_TRUNK      CRT_22R2    CRT_22R4
    [Setup]    Prepare GPS and TOPP status
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    Change DUPC IP
    log to console    start get btslog
    Run Keyword And Continue On Failure    Start btslog on ute and Check btslog
    ...    time=2min   ppb_value=20  ns_value_scope=0.5
    check master btslog    PC_IP=${TEST_PC_IP}    BTS_IP=${DU_OAM_IP_TL}
    Check accuracy lpp    PC_IP=${TEST_PC_IP}    limit1=${500}    BTS_IP=${DU_OAM_IP_TL}
    Get sync status    BTS_IP=${DU_OAM_IP_TL}    Type=1pps/ToD from external GNSS receiver
    log to console    start check slave btslog
    check SHS btslog    PC_IP=${TEST_PC_IP}    BTS_IP=${SHM_IP}
    Check accuracy lpp    PC_IP=${TEST_PC_IP}    limit1=${1500}    BTS_IP=${SHM_IP}
    Get sync status    BTS_IP=${SHM_IP}   Type=1pps/ToD from Sync Hub Master
    [Teardown]    End case

*** Keywords ***
start btslog capture on ute
    [Arguments]    ${log_dir}=${OUTPUT_DIR}/${TEST NAME}    ${connection}=ute    ${btslog_name}=btslog.log
    csn.Connect to     hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    log to console    start syslog...
    Start Syslog    log_dir=${log_dir}      log_name=${btslog_name}
    ...      host_ip=${TEST_PC_IP}    ssh_username=${TEST_PC_USERNAME}    ssh_password=${TEST_PC_PASSWORD}    alias=${connection}

Start btslog on ute and Check btslog
    [Arguments]    ${time}    ${ppb_value}   ${ns_value_scope}    ${btslog_name}=btslog.log
    start btslog capture on ute     btslog_name=${btslog_name}
    sleep    ${time}
    stop syslog     alias=ute
    Check logfile if message is right    ppb_value=${ppb_value}   ns_value_scope=${ns_value_scope}   btslog_name=${btslog_name}

BTSLOG Start btslog on local machine
    [Arguments]   ${name}=btslog
    ...           ${bts_logs_dir}=/tmp/btslog2
    __Make empty BTS logs dir      ${bts_logs_dir}
    btslog.create_btslog_collector
    ...    name=${name}
    ...    log_dir=${bts_logs_dir}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

__Make empty BTS logs dir
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

BTSLOG Collect btslog
    [Arguments]  ${bts_logs_dir}=/tmp/btslog2
    __Stop and collect btslog on local machine
    __Copy btslog to logs dir and clean BTSlog workspace    ${bts_logs_dir}

__Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}

__Copy btslog to logs dir and clean BTSlog workspace
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
#	Run  mkdir ${output_dir}/${TEST_NAME}
	Run  mkdir ${output_dir}/${Test_Case_Name}
    Run  mv ${bts_logs_dir}/syslog_files.tgz ${output_dir}/${Test_Case_Name}/syslog_files.tgz
    Run  rm ${bts_logs_dir}/*

Check logfile if message is right
    [Arguments]    ${ppb_value}   ${ns_value_scope}    ${btslog_name}=btslog.log    ${connection}=TESTPC
    csn.Connect to     hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}	alias=${connection}
    csn.Send Command  command=cat ${OUTPUT_DIR}/${TEST NAME}/${btslog_name} | grep 'Estimator output'     connection=${connection}
    ${data}    csn.Read Output    connection=${connection}
    Run Keyword And Continue On Failure    should not be empty    ${data}
    [Teardown]    Csn.Disconnect	connection=${connection}

check SHS btslog
    [Arguments]    ${PC_IP}    ${BTS_IP}
    csn.Connect to     hostname=${PC_IP}   username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    csn.Send Command    command=cat ${OUTPUT_DIR}/${TEST NAME}/btslog.log |grep ${BTS_IP} |grep TSIP_0x1C_0x83 |grep Hardware |grep version
    ...    connection=${connection}
    ${Hardware}  csn.Read Output    connection=${connection}
    Run Keyword And Continue On Failure    should not be empty    ${Hardware}

    csn.Send Command    command=cat ${OUTPUT_DIR}/${TEST NAME}/btslog.log |grep ${BTS_IP} |grep TSIP_0x8F_0xAB |grep Primary |grep timing
    ...    connection=${connection}
    ${Primary}  csn.Read Output    connection=${connection}
    Run Keyword And Continue On Failure    should not be empty    ${Primary}

    csn.Send Command    command=cat ${OUTPUT_DIR}/${TEST NAME}/btslog.log |grep ${BTS_IP} |grep TSIP_0x8F-AC |grep MinorAlarms
    ...    connection=${connection}
    ${MinorAlarms}  csn.Read Output    connection=${connection}
    Run Keyword And Continue On Failure    should not be empty    ${MinorAlarms}

    csn.Send Command    command=cat ${OUTPUT_DIR}/${TEST NAME}/btslog.log |grep ${BTS_IP} |grep TSIP_0x8F_0xF2 |grep SyncHub |grep Information
    ...    connection=${connection}
    ${Information}  csn.Read Output    connection=${connection}
    Run Keyword And Continue On Failure    should not be empty    ${Information}

    csn.Send Command    command=cat ${OUTPUT_DIR}/${TEST NAME}/btslog.log |grep ${BTS_IP} |grep TSIP_0x8F_0xF3 |grep SyncHub
    ...    connection=${connection}
    ${SyncHub}  csn.Read Output    connection=${connection}
    Run Keyword And Continue On Failure    should not be empty    ${SyncHub}
    log to console    check btslog successful

    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

check master btslog
    [Arguments]    ${PC_IP}    ${BTS_IP}
    csn.Connect to     hostname=${PC_IP}   username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    csn.Send Command    command=cat ${OUTPUT_DIR}/${TEST NAME}/btslog.log |grep ${BTS_IP} |grep TSIP_0x1C_0x83 |grep Hardware |grep version
    ...    connection=${connection}
    ${Hardware}  csn.Read Output    connection=${connection}
    Run Keyword And Continue On Failure    should not be empty    ${Hardware}

    csn.Send Command    command=cat ${OUTPUT_DIR}/${TEST NAME}/btslog.log |grep ${BTS_IP} |grep TSIP_0x8F_0xAB |grep Primary |grep timing
    ...    connection=${connection}
    ${Primary}  csn.Read Output    connection=${connection}
    Run Keyword And Continue On Failure    should not be empty    ${Primary}

    csn.Send Command    command=cat ${OUTPUT_DIR}/${TEST NAME}/btslog.log |grep ${BTS_IP} |grep TSIP_0x8F-AC |grep MinorAlarms
    ...    connection=${connection}
    ${MinorAlarms}  csn.Read Output    connection=${connection}
    Run Keyword And Continue On Failure    should not be empty    ${MinorAlarms}

    csn.Send Command    command=cat ${OUTPUT_DIR}/${TEST NAME}/btslog.log |grep ${BTS_IP} |grep TSIP_0x6C |grep Receiver |grep position
    ...    connection=${connection}
    ${Receiver}  csn.Read Output    connection=${connection}
    Run Keyword And Continue On Failure    should not be empty    ${Receiver}

    csn.Send Command    command=cat ${OUTPUT_DIR}/${TEST NAME}/btslog.log |grep ${BTS_IP} |grep TSIP_0x47 |grep Satellite |grep Signal
    ...    connection=${connection}
    ${Satellite}  csn.Read Output    connection=${connection}
    Run Keyword And Continue On Failure    should not be empty    ${Satellite}
    log to console    check btslog successful
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Check accuracy lpp
    [Arguments]    ${PC_IP}   ${limit1}    ${BTS_IP}    ${log}=${OUTPUT_DIR}/${TEST NAME}/btslog.log
    csn.Connect to     hostname=${PC_IP}   username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    csn.Send Command
    ...    command=cat ${log} |grep ${BTS_IP} |grep phase_error:|cut -d '[' -f 5|cut -d ':' -f 2|cut -d 'n' -f 1|head -1|tr '\n' ' '
    ...    connection=${connection}
    ${phase}  csn.Read Output    connection=${connection}
    Run Keyword And Continue On Failure    should not be empty    ${phase}
    ${phase}    Evaluate    abs(int(${phase}))
    log to console    ${phase}
    Run Keyword And Continue On Failure    should be true    ${phase} < ${limit1}
    log to console    check lpp successful
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Get sync status
    [Arguments]    ${BTS_IP}    ${Type}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${BTS_IP}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
    ${sync}    coam.get_bts_sync_source_status    connection=${connection}
    log to console    ${sync}
    Check sync status     sync=${sync}    Type=${Type}
    check cell onair    BTS_IP=${BTS_IP}
    [Teardown]    run keyword and ignore error    coam.teardown       connection=${connection}

check cell onair
    [Arguments]    ${BTS_IP}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${BTS_IP}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
    ${cell_info}    coam.get_bts_statuses    connection=${connection}
    log to console    ${cell_info}
    ${status}    get from dictionary    ${cell_info}    proceduralState
    Run Keyword And Continue On Failure    should be equal as strings    ${status}    OnAir
    log to console    check cell onair successful
    [Teardown]    run keyword and ignore error    coam.teardown       connection=${connection}

Check sync status
    [Arguments]  ${sync}    ${Type}
    ${syncMode}    get from dictionary    ${sync}    syncMode
    ${tuningMode}    get from dictionary    ${sync}    tuningMode
    ${syncSourceInfo}    get from dictionary    ${sync}    syncSourceInfo
    ${syncSource}    Get From List    ${syncSourceInfo}    0
    ${isActive}    get from dictionary    ${syncSource}    isActive
    ${status}    get from dictionary    ${syncSource}    status
    ${availability}    get from dictionary    ${status}    availability
    ${usability}    get from dictionary    ${status}    usability
    ${syncInputType}    get from dictionary    ${syncSource}    syncInputType

    log to console    syncMode:${syncMode}
    log to console    tuningMode:${tuningMode}
    log to console    syncSourceInfo:${syncSourceInfo}
    log to console    syncSource:${syncSource}
    log to console    isActive:${isActive}
    log to console    status:${status}
    log to console    availability:${availability}
    log to console    usability:${usability}
    log to console    syncInputType:${syncInputType}

    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${syncMode}   PhaseSync
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${tuningMode}    Normal tuning
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${isActive}    True
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${availability}    Available
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${usability}    Usable
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${syncInputType}    ${Type}
    log to console    check sync status successful

Delete TOPP keep GPS
    [Arguments]    ${synctype}    ${bts_IP}    ${BTS_ID}    ${Num}=${1}     ${connection}=GNB_OAM
    Log To Console    Delete GPS And Change Sync Input Type To TOPP
    Connect to gnb coam via ssl    bts_host=${bts_IP}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
    ${object_list}    coam.get_managed_objects    class_name=CLOCK_A    connection=${connection}
    ${object}     set variable    ${None}
    FOR    ${item}    IN    @{object_list}
         ${parameter_list}    get from dictionary     ${item}    parameters
         ${sync_list}    get from dictionary    ${parameter_list}    syncInputList
         ${object}     set variable if    ${sync_list}!=[]    ${item}
         Exit For loop if    ${sync_list}!=[]
    END
    ${parameter}    get from dictionary     ${object}    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    remove from list    ${syncInputList}    ${Num}
    set to dictionary    ${syncInputList}[0]     syncInputType=${synctype}
    set to dictionary    ${syncInputList}[0]     syncInputPrio=1
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1    connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    sleep    100s
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}

Add GPS and TOPP
    [Arguments]    ${synctype1}    ${synctype2}    ${bts_IP}    ${BTS_ID}    ${connection}=GNB_OAM
    Log To Console    Add And Change Sync Input Type To TOPP
    Connect to gnb coam via ssl    bts_host=${bts_IP}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
    ${object_list}    coam.get_managed_objects    class_name=CLOCK_A    connection=${connection}
    ${object}     set variable    ${None}
    FOR    ${item}    IN    @{object_list}
         ${parameter_list}    get from dictionary     ${item}    parameters
         ${sync_list}    get from dictionary    ${parameter_list}    syncInputList
         ${object}     set variable if    ${sync_list}!=[]    ${item}
         Exit For loop if    ${sync_list}!=[]
    END
    ${parameter}    get from dictionary     ${object}    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    set to dictionary    ${syncInputList}[0]     syncInputType=${synctype1}
    set to dictionary    ${syncInputList}[0]     syncInputPrio=1
    ${structure2}    create dictionary     syncInputPrio=2    syncInputType=${synctype2}
    append to list    ${syncInputList}    ${structure2}
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1    connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}

Modify Value On DU
    [Arguments]    ${structure_modify_list}    ${gNB_ip}    ${common_modify_list}=None    ${keywords_list}=None    ${connection}=GNB_connection
    ...    ${class_name}=None   ${is_structure}=${True}    ${is_common}=${True}    ${structure_index}=0
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    run keyword if  ${is_structure}    Modify Structure parameter via Coam    class_name=${class_name}   connection=${connection}
    ...    modify_list=${structure_modify_list}    keywords_list=${keywords_list}    index=${structure_index}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Modify Common parameter via Coam
    [Arguments]  ${input_list}    ${bts_ip}    ${connection}=GNB_connection
    log to console  Modify parameter
    Connect to gnb coam via ssl    bts_host=${bts_ip}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    sleep    10s
    FOR    ${item}  IN    @{input_list}
         ${dict_value}    Get Content From Input Dict    input_dict=${item}
         coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
    END
    sleep  20s
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}

Modify Structure parameter via Coam
    [Arguments]   ${class_name}   ${connection}   ${modify_list}   ${keywords_list}    ${index}=0
    ${get_managed_objects}     coam.get_managed_objects     class_name=${class_name}    connection=${connection}
    ${output_dict_list}    return_structure_value    input_list=${get_managed_objects}    modify_list=${modify_list}
    ...    keywords_list=${keywords_list}
    FOR    ${item}  IN  @{output_dict_list}
         ${dict_value}    Get Content From Input Dict    input_dict=${item}
         coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
         sleep  30s
    END

Get Content From Input Dict
    [Arguments]  ${input_dict}
    ${dist_name}    get from dictionary     ${input_dict}    dist_name
    ${parammeter}    get from dictionary    ${input_dict}    parameter
    ${new_value}     get from dictionary    ${input_dict}    value
    ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
    [Return]  ${value_list}

Change DUPC IP
    log to console    modify slave ute Ip
    Modify Value On DU     gNB_ip=${SHM_IP}    structure_modify_list=${parameter5}
    ...    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
    Modify Value On DU     gNB_ip=${SHM_IP}    structure_modify_list=${parameter10}
    ...    class_name=TRBLCADM_A    keywords_list=${keywords_list1}

Download swconfig
    [Arguments]    ${BTS_IP}    ${backup_path}    ${connection_2}=Download
    csn.connect_to   hostname=${BTS_IP}    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}
    ...    alias=${connection_2}
    csn.download_file   local_path=${backup_path}    remote_path=/ffs/run/swconfig.txt
    ...    connection=${connection_2}
    log to console  Download swconfig successful
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection_2}

connect and Upload swconfig
    [Arguments]    ${BTS_IP}    ${swconfig_path}
    csn.connect_to   hostname=${BTS_IP}    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}     alias=${connection}
    swconf.Upload swConfig file to asik and crasign    localFilePath=${swconfig_path}    asik_alias=${connection}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Reset site
    [Arguments]    ${BTS_IP}    ${connection}=GNB_OAM
    log to console    reset site IP；${BTS_IP}
    Connect to gnb coam via ssl    bts_host=${bts_ip}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    coam.reset_site    connection=${connection}
    [Teardown]    run keyword and ignore error    coam.teardown     connection=${connection}

Prepare GPS and TOPP status
    log to console    Delete Master topp
    Run Keyword And Ignore Error    Delete TOPP keep GPS    synctype=1pps/ToD from external GNSS receiver
    ...    bts_IP=${DU_OAM_IP_TL}    BTS_ID=${BTS_ID_M}    Num=${0}
    Modify Common parameter via Coam    bts_ip=${DU_OAM_IP_TL}    input_list=${parameter0}
    Modify Common parameter via Coam    bts_ip=${DU_OAM_IP_TL}    input_list=${parameter1}
    log to console    Delete SHM  topp
    Delete TOPP keep GPS    synctype=1pps/ToD from Sync Hub Master    bts_IP=${SHM_IP}    BTS_ID=${BTS_ID_S}    Num=${0}

End case
    Run Keyword And Ignore Error    coam.teardown    connection=${connection}
    log to console    ADD Master topp
    Add GPS and TOPP    synctype1=1pps/ToD from external GNSS receiver    synctype2=TOPP    bts_IP=${DU_OAM_IP_TL}    BTS_ID=${BTS_ID_M}
    log to console    ADD Master topp
    Add GPS and TOPP    synctype1=1pps/ToD from Sync Hub Master    synctype2=TOPP    bts_IP=${SHM_IP}    BTS_ID=${BTS_ID_S}
    Modify Value On DU     gNB_ip=${SHM_IP}    structure_modify_list=${parameter11}
    ...    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
    log to console    modify slave ute Ip
    Modify Value On DU     gNB_ip=${SHM_IP}    structure_modify_list=${parameter4}
    ...    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
    Reset site    BTS_IP=${SHM_IP}
    sleep    180s
    Wait Until Keyword Succeeds    10min    10sec    check cell onair    BTS_IP=${SHM_IP}
    [Teardown]    CI_interface.Common Case Teardown
