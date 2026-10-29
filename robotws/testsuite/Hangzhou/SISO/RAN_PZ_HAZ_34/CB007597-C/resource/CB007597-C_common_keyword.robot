*** Settings ***
Documentation
...               author: Na Li
...               contact: na.li@nokia-sbell.com
...               squad group: MMW_SG_04



Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library           taf.transport.ssh         WITH NAME    tssh
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Library           ../resource/check_ru_log.py
Library           taf.config.scf    WITH NAME    cscf
Library           OperatingSystem
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Library      ../resource/unzip_RU_LOG.py

*** Variables ***
${DU_IP}                    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBEM_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_OAM_IP}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${filename}                 full.zip
${gnb_path}                 /ffs/run/config/toor4nsn/
${host}                     ${tl.test_pc.default_ssh_connection_details.addr}
${username}                 ${tl.test_pc.default_ssh_connection_details.username}
${password}                 ${tl.test_pc.default_ssh_connection_details.password}



*** Keywords ***
Connect to DU
    [Arguments]    ${connection}=cOAM_admin
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}

Disconnect from DU
    [Arguments]    ${connection}=cOAM_admin
    coam.teardown      connection=${connection}

Admin Reset BTS
    [Arguments]    ${alias}=cOAM_admin
    coam.Reset Site    connection=${alias}

COAM Commission with scf file ignore error
    [Documentation]  Author: Liu Steven
    ...              Description: Do commission and verify commission status
    ...                           2019-11-12, add argument ${is_pdl_checking_needed} to open interface to tester if pdl checking is needed,
    ...                                       Valid values are: ${True} or ${False}, if ${True}, then pdl validation is needed,
    ...                                       otherwise will ignore this validation. Now it's default to ${True}
    [Arguments]  ${scf_file_path}    ${connection}=cOAM_admin    ${timeout}=300    ${is_pdl_checking_needed}=${True}
    &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}

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
    ${dict_info}=   coam.Get Bts Info    connection=${admin_alias}
    ${state}=    Get From Dictionary    dictionary=${dict_info['status']}    key=proceduralState
    Should be equal    ${state}    OnAir

Get Alarm Info
    [Arguments]   ${timeout}    ${connection}=cOAM_admin
    sleep    10s
    @{alarms}    coam.get_active_alarms    timeout=${timeout}    connection=cOAM_admin
    sleep    1s
    log     ${alarms}
    ${fault_id_list}    create list
    ${fault_name_list}    create list
    FOR    ${item}    IN    @{alarms}
        ${fault_id}    get from dictionary    ${item}    faultId
        ${fault_name}    get from dictionary    ${item}    faultName
        append to list    ${fault_id_list}    ${fault_id}
        append to list    ${fault_name_list}    ${fault_name}
    END
    [Return]    ${fault_name_list}    ${fault_id_list}

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

Start RU log for LNApower false
    [Arguments]    ${sh_name}=get_RU_log_AWEUA.sh
    tssh.connect_to      hostname=${host}
    ...                 username=${username}
    ...                 password=${password}
    ...                 alias=ute
    sleep    10s
    tssh.execute    command=chmod 777 /home/ute/robotws/testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007597-C/${sh_name}  connection=ute
    sleep    1s
    tssh.execute    command=/home/ute/robotws/testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007597-C/${sh_name}     connection=ute
    sleep    1s
    tssh.disconnect    connection=ute
    Stop and Save Logs

Start RU log for LNApower false for 21B 22R1
    tssh.connect_to      hostname=${host}
    ...                 username=${username}
    ...                 password=${password}
    ...                 alias=ute
    sleep    10s
    tssh.execute    command=chmod 777 /home/ute/robotws/testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007597-C/get_RU_log_AWEUA_21B_22R1.sh
    ...    connection=ute
    sleep    1s
    tssh.execute    command=/home/ute/robotws/testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007597-C/get_RU_log_AWEUA_21B_22R1.sh     connection=ute
    sleep    1s
    tssh.disconnect    connection=ute
    Stop and Save Logs

Start RU log for LNApower false for 22R2 Trunk
    tssh.connect_to      hostname=${host}
    ...                 username=${username}
    ...                 password=${password}
    ...                 alias=ute
    sleep    10s
    tssh.execute    command=chmod 777 /home/ute/robotws/testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007597-C/get_RU_log_AWEUA_22R2_trunk.sh
    ...    connection=ute
    sleep    1s
    tssh.execute    command=/home/ute/robotws/testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007597-C/get_RU_log_AWEUA_22R2_trunk.sh     connection=ute
    sleep    1s
    tssh.disconnect    connection=ute
    Stop and Save Logs

Stop and Save Logs
    gNB connections
    Stop and download Logs    logname=${filename}    connection=gnb
    [Teardown]    csn.Disconnect    connection=gnb

gNB connections
    csn.Connect To    hostname=${DU_OAM_IP}
    ...               username=${DU_OAM_SSH_USERNAME}
    ...               password=${DU_OAM_SSH_PASSWORD}
    ...               alias=gnb

Stop and download Logs
    [Arguments]    ${logname}    ${connection}
    csn.download_file    remote_path=${gnb_path}${logname}    local_path=${output_dir}/${logname}   connection=${connection}
    sleep    3

check the RU log
    [Arguments]    ${search_string}=<alpha>0</alpha><beta>0</beta>
    Get SW version and run keyword for check the RU log     search_string=${search_string}

Unzip the RU logs
    Get SW version and run keyword for Unzip the RU logs

check the RU log for 22R2
    [Arguments]    ${search_string}=<alpha>0</alpha><beta>0</beta>
    ${alpha_value}    get_alpha_value    file_path=${output_dir}/UnitOAM_SOAP_Startup_LBTS_OM_DH201860950_Log0.xml
    ...    search_string=${search_string}
    should be true    ${alpha_value} > 1

check the RU log for Trunk
    [Arguments]    ${search_string}=<alpha>0</alpha><beta>0</beta>
#    wait until keyword succeeds    5min   10s    check file
    ${alpha_value}    get_alpha_value    file_path=${output_dir}/UnitOAM_SOAP_Startup_LBTS_OM_DH201860950_Log0.xml
    ...    search_string=${search_string}
    should be true    ${alpha_value} > 1

#check file
#    ${return}        get_a_directory        ${output_dir}
#    list should contain value   ${return}    UnitOAM_SOAP_Startup_LBTS_OM_DH*_Log0.xml


Unzip the RU logs for 22R2
    unzip_single_file    ${output_dir}/${filename}    ${output_dir}
    unzip_single_file     ${output_dir}/1011_UnitOAM_SOAP_Log.zip     ${output_dir}
    unzip_single_file     ${output_dir}/UnitOAM_SOAP_Startup_LBTS_OM_DH201860950_Log.zip     ${output_dir}
    unzip_single_file    ${output_dir}/UnitOAM_SOAP_Startup_LBTS_OM_DH201860950_Log0.xml.gz

Unzip the RU logs for Trunk
#    [Arguments]          ${connection}=cOAM_admin
#    unzip_single_file    ${output_dir}/${filename}    ${output_dir}
#    sleep    2
#    unzip_single_file     ${output_dir}/1011_UnitOAM_SOAP_Log.zip    ${output_dir}
#    sleep    2
#    unzip_single_file    ${output_dir}/UnitOAM_SOAP_Startup_LBTS_OM_DH*_Log.zip    ${output_dir}
#    sleep    2
#    ${connection}    tssh.connect to    hostname=${host}   username=${username}
#    ...    password=${password}    alias=UTE
#    tssh.send_command    command=gunzip ${output_dir}/UnitOAM_SOAP_Startup_LBTS_OM_DH*_Log0.xml.gz     connection=${connection}
#    ${data}    tssh.Read Output    connection=${connection}
#    sleep    5s
#    [Teardown]    ssh.Disconnect     connection=${connection}
    unzip_single_file    ${output_dir}/${filename}    ${output_dir}
    unzip_single_file     ${output_dir}/1011_UnitOAM_SOAP_Log.zip     ${output_dir}
    unzip_single_file     ${output_dir}/UnitOAM_SOAP_Startup_LBTS_OM_DH201860950_Log.zip     ${output_dir}
    unzip_single_file    ${output_dir}/UnitOAM_SOAP_Startup_LBTS_OM_DH201860950_Log0.xml.gz

Get SW version and run keyword for Unzip the RU logs
    [Arguments]       ${connection}=cOAM_admin
    Connect to gnb coam via ssl    bts_host=${DU_IP}     username=${WEBEM_USERNAME}     password=${WEBEM_PASSWORD}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    Run keyword if    ${if_common_load}    Unzip the RU logs for Trunk
    ...     ELSE     Unzip the RU logs for 22R2

Get SW version and run keyword for check the RU log
    [Arguments]       ${search_string}    ${connection}=cOAM_admin
    Connect to gnb coam via ssl    bts_host=${DU_IP}     username=${WEBEM_USERNAME}     password=${WEBEM_PASSWORD}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    Run keyword if   ${if_common_load}    check the RU log for Trunk    search_string=${search_string}
    ...     ELSE     check the RU log for 22R2    search_string=${search_string}

Case UE detach And Teardown
    Log To Console    UE Detach
    run keyword and ignore error    power_ue.UE Detach    ue_type=askey_sigspark
    CI_interface.Common Case Teardown

Modify scf file
    [Timeout]  20 min
    [Arguments]    ${value1}    ${value2}    ${MRBTS_ID}=${tl.gnbs[0].instance_id}    ${timeout}=10 min    ${scf_mame}=SCF_C.xml
    ...    ${value3}=true
    Connect to DU
    coam.get_current_scf_file    local_dir_path=${output_dir}    file_name=${scf_mame}    connection=cOAM_admin    timeout=60
    Disconnect from DU
    ${scf_path}     set vari able    ${output_dir}/${scf_mame}
    cscf.load_scf    ${scf_path}
    cscf.modify_scf_element    value=${value1}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1    p_name=frameStartOffset
    cscf.modify_scf_element    value=${value2}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1    p_name=sfnOffset
    cscf.modify_scf_element    value=${value1}   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2    p_name=frameStartOffset
    cscf.modify_scf_element    value=${value2}   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2    p_name=sfnOffset
    cscf.modify_scf_element    value=${value3}   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    p_name=actCellTimingOffset
    cscf.save_scf    ${output_dir}/scf.xml
    Connect to DU
    COAM Commission with scf file ignore error    scf_file_path=${output_dir}/scf.xml     connection=cOAM_admin
    RUN KEYWORD AND IGNORE ERROR    Disconnect from DU
    [Teardown]    Remove File    ${scf_path}

UE start traffic
    [Documentation]    used for UE start traffic, ul/dl/both.
    [Arguments]    ${ue_index}=${0}    ${protocol}=udp    ${tp_direction}=both    ${duration}=600    ${iperf_type}=via_app
    ...    ${ul_throughput}=100MKbits/sec    ${dl_throughput}=100MKbits/sec    ${time}=20s    ${ue_type}=${tl.ues[0].capabilities[-1]}
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${ue_index}
    ...    direction=ul    throughput=${ul_throughput}    duration=${duration}    iperf_type=${iperf_type}    ue_type=${ue_type}
    ...    protocol=${protocol}    ue_mode=NSA
    sleep    1s
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${ue_index}
    ...    direction=dl    throughput=${dl_throughput}    duration=${duration}    ue_type=${ue_type}    iperf_type=${iperf_type}
    ...    protocol=${protocol}    ue_mode=NSA
    sleep    ${time}

UE stop traffic
    [Documentation]    used for UE stop traffic, ul/dl/both.
    [Arguments]    ${ue_index}=${0}    ${tp_direction}=both    ${protocol}=udp
    ...    ${iperf_type}=via_command    ${ue_type}=${tl.ues[0].capabilities[-1]}
    log to console    Stop traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic    direction=ul
    ...    ue_index=${ue_index}    ue_type=${ue_type}    ue_mode=NSA
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'    power_ue.Stop traffic    direction=dl
    ...     ue_index=${ue_index}    ue_type=${ue_type}    ue_mode=NSA

Adjust Enb
    [Arguments]    ${index}  ${alias}=enblte
    ${lncelid}    Get lncelid on enb    alias=${alias}
    ${dist_name}  set variable  MRBTS-${tl.enbs[0].global_bts_id}/LNBTS-${tl.enbs[0].global_bts_id}/LNCEL-${lncelid}
    ${parameter}  set variable  defaultLnRelGnbCellId
    ${value}  set variable  ${index}
    log to console  ${dist_name}
    Connect and Modify the parameter on enblte  ${dist_name}    ${parameter}     ${value}



