*** Settings ***
Documentation
...               author: Na Li
...               contact: na.li@nokia-sbell.com
...               squad group: MMW_SG_04

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
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${ssh_script_path}          ${CURDIR}/sh_script
${LNApower}                 actGnssOutputLnaPowerSupply
${gnssMode}                 gnssControlMode
${GLONASS_only}             GLONASS only
${GPS_Beidou}               GPS-Beidou
${holdover_time_200000}     200000
${holdover_time_1325}       1325
${filename_B}               tcpdump_ru.pcap
${holdover_threshold}       phaseHoldoverSpecThreshold
${dist_ECPRIMASTER}         MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1
${dist_GNSS}                MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1
${luashark_path}            /opt/luashark/luashark.lua

*** Keywords ***
Modify scf file
    [Timeout]  20 min
    [Arguments]    ${value1}    ${value2}    ${MRBTS_ID}=${tl.gnbs[0].instance_id}    ${timeout}=10 min    ${scf_mame}=SCF_C.xml
    ...    ${value3}=true
    Connect to DU
    coam.get_current_scf_file    local_dir_path=${OUTPUT DIR}    file_name=${scf_mame}    connection=cOAM_admin    timeout=60
    Disconnect from DU
    ${scf_path}     set variable    ${OUTPUT DIR}/${scf_mame}
    cscf.load_scf    ${scf_path}
    cscf.modify_scf_element    value=${value1}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1    p_name=frameStartOffset
    cscf.modify_scf_element    value=${value2}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1    p_name=sfnOffset
    cscf.modify_scf_element    value=${value1}   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2    p_name=frameStartOffset
    cscf.modify_scf_element    value=${value2}   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2    p_name=sfnOffset
    cscf.modify_scf_element    value=${value3}   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    p_name=actCellTimingOffset
    cscf.save_scf    ${OUTPUT DIR}/scf.xml
    ${conn}    Connect to DU
    COAM Commission with scf file ignore error    scf_file_path=${OUTPUT DIR}/scf.xml     connection=${conn}
    RUN KEYWORD AND IGNORE ERROR    Disconnect from DU
    [Teardown]    Remove File    ${scf_path}

Connect to DU
    [Arguments]    ${connection}=cOAM_admin
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}

Disconnect from DU
    [Arguments]    ${connection}=cOAM_admin
    coam.teardown      connection=${connection}

COAM Commission with scf file ignore error
    [Documentation]  Author: Liu Steven
    ...              Description: Do commission and verify commission status
    ...                           2019-11-12, add argument ${is_pdl_checking_needed} to open interface to tester if pdl checking is needed,
    ...                                       Valid values are: ${True} or ${False}, if ${True}, then pdl validation is needed,
    ...                                       otherwise will ignore this validation. Now it's default to ${True}
    [Arguments]  ${scf_file_path}    ${connection}=cOAM_admin    ${timeout}=300    ${is_pdl_checking_needed}=${True}
    coam.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}

Check BTS is in On Air
    Connect to DU
    ADMIN Wait Until BTS OnAir
    [Teardown]    Disconnect from DU

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

read the RU log
    [Arguments]  ${file_name}
    ${versiontitle}    Get Version
    run keyword if    '${versiontitle}'=='5G21B'
    ...    Start RU log for LNApower false    file_name=${file_name}    sh_name=21B_get_RU_log_AEUB.sh
    ...    ELSE    Start RU log for LNApower false    file_name=${file_name}    sh_name=22R1_get_RU_log_AEUB.sh
    Unzip the RU logs

Start RU log for LNApower false
    [Arguments]    ${file_name}    ${sh_name}=get_RU_log_AWEUA.sh
    ssh.connect_to      hostname=${host}
    ...                 username=${username}
    ...                 password=${password}
    ...                 alias=ute
    sleep    10s
    ssh.execute    command=chmod 777 ${ssh_script_path}/CB007597-C/${sh_name}    connection=ute
    sleep    1s
    ssh.execute    command=${ssh_script_path}/CB007597-C/${sh_name}     connection=ute
    sleep    1s
    ssh.disconnect    connection=ute
    Stop and Save Logs    file_name=${file_name}

Stop and Save Logs
    [Arguments]  ${file_name}
    gNB connections
    Stop and download Logs    logname=${file_name}    connection=gnb
    [Teardown]    ssh.Disconnect    connection=gnb

gNB connections
    ssh.Connect To    hostname=${DU_OAM_IP}
    ...               username=${DU_OAM_SSH_USERNAME}
    ...               password=${DU_OAM_SSH_PASSWORD}
    ...               alias=gnb

Stop and download Logs
    [Arguments]    ${logname}    ${connection}
    ssh.download_file    remote_path=${gnb_path}${logname}    local_path=${OUTPUT DIR}/${logname}   connection=${connection}
    sleep    3

check the RU log
    [Arguments]    ${search_string}=<alpha>0</alpha><beta>0</beta>
    ${alpha_value}    get_alpha_value    file_path=${OUTPUT DIR}/UnitOAM_SOAP_Log0.xml
    ...    search_string=${search_string}
    should be true    ${alpha_value} > 1

Unzip the RU logs
    unzip_single_file    ${OUTPUT DIR}/${filename}    ${OUTPUT DIR}
    unzip_single_file   ${OUTPUT DIR}/1011_UnitOAM_SOAP_Log.zip    ${OUTPUT DIR}
    unzip_single_file    ${OUTPUT DIR}/1011_UnitOAM_SOAP_Log.zip    ${OUTPUT DIR}
    unzip_single_file    ${OUTPUT DIR}/UnitOAM_SOAP_Startup_LBTS_OM_DH*_Log.zip    ${OUTPUT DIR}
    unzip_single_file    ${OUTPUT DIR}/UnitOAM_SOAP_Startup_LBTS_OM_DH*_Log0.xml.gz

Adjust Enb
    [Arguments]    ${index}  ${alias}=enblte
    ${lncelid}    Get lncelid on enb    alias=${alias}
    ${dist_name}  set variable  MRBTS-${tl.enbs[0].global_bts_id}/LNBTS-${tl.enbs[0].global_bts_id}/LNCEL-${lncelid}
    ${parameter}  set variable  defaultLnRelGnbCellId
    ${value}  set variable  ${index}
    log to console  ${dist_name}
    Connect and Modify the parameter on enblte  ${dist_name}    ${parameter}     ${value}

make the call
    power_ue.Prepare UE    ue_type=askey_sigspark
    power_ue.UE Attach    ue_type=askey_sigspark
    power_ue.Verify attach    ue_type=askey_sigspark
    UE start traffic
    power_ue.Check throughput    ue_type=askey_sigspark    direction=dl    throughput=5
    power_ue.Check throughput    ue_type=askey_sigspark    direction=ul    throughput=5
    Log To Console    UE Detach
    run keyword and ignore error    power_ue.UE Detach    ue_type=askey_sigspark

Get Version
    [Arguments]    ${connection}=cOAM_admin
    Log To Console    Get Version
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${versiontitle}    set variable    ${version_list[0]}
    [Return]    ${versiontitle}
    [Teardown]    coam.teardown      connection=${connection}

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

Case UE detach And Teardown
    Log To Console    UE Detach
    run keyword and ignore error    power_ue.UE Detach    ue_type=askey_sigspark
    CI_interface.Common Case Teardown

UE stop traffic
    [Documentation]    used for UE stop traffic, ul/dl/both.
    [Arguments]    ${ue_index}=${0}    ${tp_direction}=both    ${protocol}=udp
    ...    ${iperf_type}=via_command    ${ue_type}=${tl.ues[0].capabilities[-1]}
    log to console    Stop traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic    direction=ul
    ...    ue_index=${ue_index}    ue_type=${ue_type}    ue_mode=NSA
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'    power_ue.Stop traffic    direction=dl
    ...     ue_index=${ue_index}    ue_type=${ue_type}    ue_mode=NSA

#CB007597-5G-B-AEUB
Check cell on air
    [Arguments]    ${connection}=cOAM_admin
    BuiltIn.Log    \n Start to check Cell On Air \n    console=yes
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    COAM Check GNB cell on air    connection=${connection}
    [Teardown]   coam.teardown      connection=${connection}

Change para Glonass only
    [Arguments]    ${LNAvalue}    ${holdover_time}
    Connect to DU
    perform muti Parameter recommissioning    dist_name=${dist_ECPRIMASTER}    parameter=${holdover_threshold}
    ...    value=${holdover_time}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${LNApower}    value=${LNAvalue}    operation=update
    ${versiontitle}    Get Version
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    run keyword if    '${versiontitle}'=='5G21B'
    ...    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${gnssMode}    value=${GLONASS_only}    operation=update
    ...    ELSE    act Glonass
    Sleep    1min
   [Teardown]    Disconnect from DU

perform muti Parameter recommissioning
    [Arguments]   ${dist_name}    ${parameter}   ${value}     ${operation}=create    ${connection}=cOAM_admin
    ...    ${skip_parameter_relation_errors}=${True}     ${should_activate}=${True}
    coam.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}
    ...    operation=${operation}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}
    ...    connection=${connection}

Start RU tcpdump for LNApower
    [Arguments]  ${sh_name}    ${file_name}=${filename_B}
    ssh.connect_to      hostname=${host}
    ...                 username=${username}
    ...                 password=${password}
    ...                 alias=ute
    sleep    10s
    ssh.execute    command=chmod 777 ${ssh_script_path}/CB007597-B/${sh_name}    connection=ute
    sleep    1s
    ssh.execute    command=${ssh_script_path}/CB007597-B/${sh_name}    connection=ute
    sleep    1s
    ssh.disconnect    connection=ute
    Stop and Save Logs    file_name=${file_name}

Check Tuning mode
    Connect to DU
    ${bts_sync_status}    coam.get_bts_sync_source_status    connection=cOAM_admin
    should be equal as strings    ${bts_sync_status['tuningMode']}    Adaptive holdover    ignore_case=true
    [Teardown]    Disconnect from DU

Check wireshark log data equal value
    [Arguments]    ${command}    ${pacp_filename}   ${txt_filename}    ${filter}   ${check}    ${connection}=ute
    ${data}    Check wireshark log data common    command=${command}    pacp_filename=${pacp_filename}    connection=${connection}
    ...   txt_filename=${txt_filename}      filter=${filter}
    should be equal as strings    ${data}    ${check}
    log to console    data:${data}
    [Teardown]    run keyword and ignore error    ssh.Disconnect	connection=${connection}

Check wireshark log data common
    [Arguments]    ${command}    ${pacp_filename}   ${txt_filename}    ${filter}    ${connection}=ute
    ssh.connect_to    hostname=${host}    username=${username}     password=${password}    alias=${connection}
    sleep    1s
    log to console    ${OUTPUT DIR}
    log to console    ${pacp_filename}
    Convert pcap to text   source=${OUTPUT DIR}/${pacp_filename}
    ...  target=${OUTPUT DIR}/${txt_filename}   connection=${connection}    filter=${filter}
    ssh.Send Command  command=cat ${OUTPUT DIR}/${txt_filename} |${command}    connection=${connection}
    ${data}    ssh.Read Output    connection=${connection}
    ${data}    strip_string    ${data}
    [Return]   ${data}
    [Teardown]    run keyword and ignore error    ssh.Disconnect  	connection=${connection}

Convert pcap to text
    [Arguments]    ${source}    ${target}    ${filter}   ${connection}=ute
    ssh.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
    ssh.await execution end  connection=${connection}  timeout=30min
    sleep    20s

Check Clockclass on WEBEM
    [Arguments]    ${value}
    Connect to DU
    ${Clockclass}   coam.Get SCF single Value from current xml file
    ...   parameter=eCpriMasterClockClass   list_name=${None}
    ...   dist_name=MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    should be equal    ${Clockclass}    ${value}
    [Teardown]    Disconnect from DU

Change para GPS Beidou
    [Arguments]    ${LNAvalue}    ${holdover_time}
    Connect to DU
    perform muti Parameter recommissioning    dist_name=${dist_ECPRIMASTER}    parameter=${holdover_threshold}
    ...    value=${holdover_time}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${LNApower}    value=${LNAvalue}    operation=update
    ${versiontitle}    Get Version
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    run keyword if    '${versiontitle}'=='5G21B'
    ...    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${gnssMode}    value=${GPS_Beidou}    operation=update
    ...    ELSE    act GPS-Beidou
    sleep    1min
   [Teardown]    Disconnect from DU

act Glonass
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actBeidou    value=${False}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actGlonass    value=${True}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actGps    value=${False}    operation=update

act GPS-Beidou
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actBeidou    value=${True}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actGlonass    value=${False}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actGps    value=${True}    operation=update

Case Teardown
    CI_interface.Common Case Teardown
    Connect to DU
    perform muti Parameter recommissioning    dist_name=${dist_ECPRIMASTER}    parameter=${holdover_threshold}
    ...    value=${holdover_time_1325}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${LNApower}    value=${True}    operation=update
    ${versiontitle}    Get Version
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    run keyword if    '${versiontitle}'=='5G21B'
    ...    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${gnssMode}    value=${GPS_Beidou}    operation=update
    ...    ELSE    act GPS-Beidou
    [Teardown]    Disconnect from DU