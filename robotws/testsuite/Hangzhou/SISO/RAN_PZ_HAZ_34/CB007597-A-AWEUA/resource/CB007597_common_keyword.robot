*** Settings ***
Documentation
...               author: Steven Liu
...               contact: steven.liu@nokia-sbell.com
...               squad group: MMW_SG_04

*** Variables ***
${host}                     ${tl.test_pc.default_ssh_connection_details.addr}
${username}                 ${tl.test_pc.default_ssh_connection_details.username}
${password}                 ${tl.test_pc.default_ssh_connection_details.password}
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${gnb_path}                 /ffs/run/config/toor4nsn/
${filename}                 tcpdump_ru.pcap
${holdover_time_2}          2
${holdover_time_1325}       1325
${holdover_time_200000}     200000
${LNApower}                 actGnssOutputLnaPowerSupply
${gnssMode}                 gnssControlMode
${GLONASS_only}             GLONASS only
${GPS_Beidou}               GPS-Beidou
${holdover_threshold}       phaseHoldoverSpecThreshold
${dist_GNSS}                MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1
${dist_ECPRIMASTER}         MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1
${WEBEM_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_IP}                    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${DU_OAM_IP}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${luashark_path}            /opt/luashark/luashark.lua
#${luashark_path}            /opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
#${luashark_path}            /opt/ute/luashark/luashark_script/generated_luashark
${dist_actEcpriRuPtpOnlySync}        MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
${act_EcpriRuPtpOnlySync}            actEcpriRuPtpOnlySync
${ssh_script_path}          ${CURDIR}/sh_script
${clockclass_6}             ptp.v2.an.grandmasterclockclass == 6
${clockclass_7}             ptp.v2.an.grandmasterclockclass == 7
${clockclass_150}           ptp.v2.an.grandmasterclockclass == 150
${filename_C}               full.zip
${output_log}               ${OUTPUT DIR}



*** Keywords ***
Connect to DU
    [Arguments]    ${alias}=cOAM_admin
    ${conn}=    coam.connect_to
    ...    bts_host=${DU_OAM_IP}
    ...    username=${WEBEM_USERNAME}
    ...    password=${WEBEM_PASSWORD}
    ...    name=${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    coam.teardown     connection=${alias}

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

SSH RU
    [Arguments]      ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...    username=Nemuadmin
    ...    password=nemuuser
    ...    connection=${connection}
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_alias=RU    connection=${connection}

gNB connections
    ssh.Connect To    hostname=${DU_OAM_IP}
    ...               username=${DU_OAM_SSH_USERNAME}
    ...               password=${DU_OAM_SSH_PASSWORD}
    ...               alias=gnb

RU Ping
    [Documentation]    ping ip address from DU to RU
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}
    ...   password=${DU_OAM_SSH_PASSWORD}    alias=VM
    ${response}    ssh.execute    command=lxc-attach -n 0x1018 -- ping ${RU_IP} -c 5    connection=VM
    should contain    ${response}    0% packet loss
    [Teardown]    ssh.disconnect    connection=VM
    [Return]  ${response}

Check clockclass in tcpdump
    [Arguments]    ${local_path}    ${filename}    ${condition_expression}
    cap.read_cap    cap_file=${local_path}/${filename}
    cap.check_expression    condition_expression=${condition_expression}

#CB007597-A
Check cell on air
    [Arguments]    ${connection}=cOAM_admin
    BuiltIn.Log    \n Start to check Cell On Air \n    console=yes
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    COAM Check GNB cell on air    connection=${connection}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

set actEcpriRuPtpOnlysync value
    [Arguments]    ${actEcpriRuPtpOnlysync_value}    ${connection}=cOAM_admin
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    perform muti Parameter recommissioning    dist_name=${dist_actEcpriRuPtpOnlySync}    parameter=${act_EcpriRuPtpOnlySync}
    ...    value=${actEcpriRuPtpOnlysync_value}    operation=update
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Start RU tcpdump
    log to console    \n\tstart RU tcpdump
    ssh.connect_to      hostname=${host}
    ...                 username=${username}
    ...                 password=${password}
    ...                 alias=ute
    sleep    10s
    ssh.execute    command=chmod 777 ${ssh_script_path}/CB007597-A/start_tcp.sh    connection=ute
    sleep    1s
    ssh.execute    command=${ssh_script_path}/CB007597-A/start_tcp.sh    connection=ute
    sleep    1s
    Save Logs
    [Teardown]    ssh.disconnect    connection=ute

download Logs
    [Arguments]    ${logname}    ${connection}
    ssh.download_file    remote_path=${gnb_path}${logname}    local_path=${output_log}/${logname}   connection=${connection}
    sleep    3

Save Logs
    [Arguments]  ${log_file}=${filename}
    gNB connections
    download Logs    logname=${log_file}    connection=gnb
    [Teardown]    ssh.disconnect    connection=gnb

Check sync mode
    [Arguments]     ${check_sync_mode}    ${sync_mode}
    log to console    \n\tcheck sync mode
    ssh.connect_to      hostname=${host}
    ...                 username=${username}
    ...                 password=${password}
    ...                 alias=ute
    sleep    10s
    ssh.execute    command=chmod 777 ${ssh_script_path}/CB007597-A/${check_sync_mode}.sh    connection=ute
    sleep    1s
    ${out}    ssh.execute    command=${ssh_script_path}/CB007597-A/${check_sync_mode}.sh    connection=ute
    sleep    1s
    should contain any    ${out}    ${sync_mode}
    [Teardown]    ssh.disconnect    connection=ute

check lockState and syncStatus on WebEM
    [Arguments]     ${lock_State}    ${sync_Status}    ${connection}=cOAM_admin
    log to console    \n\tcheck lockState and syncStatus on WebEM
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    ${lockState}    Get SCF single Value from current xml file
    ...   parameter=lockState   list_name=${None}   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1
    ...   p_index=${0}    alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    should be true    '${lockState}'=='${lock_State}'
    ${syncStatus}    Get SCF single Value from current xml file
    ...   parameter=syncStatus   list_name=${None}   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/CLOCK_R-1
    ...   p_index=${0}    alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    should be true    '${syncStatus}'=='${sync_Status}'
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Read Log and check
    [Arguments]      ${tcpdump_log}    ${connection}=TestPc
    log to console    \n\tRead Log and check
    ssh.Connect to    hostname=${host}    username=${username}    password=${password}    alias=${connection}
    Convert pcap to text    source=${output_log}/${tcpdump_log}    target=${output_log}/Req.txt   filter='ptp.v2.messageid == 0x1'
    ...    connection=${connection}
    Convert pcap to text    source=${output_log}/${tcpdump_log}    target=${output_log}/Resp.txt   filter='ptp.v2.messageid == 0x9'
    ...    connection=${connection}
    [Teardown]    Run keyword and ignore error    ssh.Disconnect	  connection=${connection}

Convert pcap to text
    [Arguments]  ${source}   ${target}   ${filter}   ${connection}
    ssh.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y ${filter}
    ...  connection=${connection}
    ssh.await execution end    connection=${connection}    timeout=30min

Get and check Tuning mode
    [Arguments]    ${tuning_mode}    ${connection}=cOAM_admin
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    ${bts_sync_status}    coam.get_bts_sync_source_status    connection=cOAM_admin
    should be equal as strings    ${bts_sync_status['tuningMode']}    ${tuning_mode}    ignore_case=true
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Change para Glonass only
    [Arguments]    ${LNAvalue}    ${holdover_time}    ${connection}=cOAM_admin
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    perform muti Parameter recommissioning    dist_name=${dist_ECPRIMASTER}    parameter=${holdover_threshold}
    ...    value=${holdover_time}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${LNApower}    value=${LNAvalue}    operation=update
    ${versiontitle}    Get Version
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    run keyword if    '${versiontitle}'=='SBTS21B'
    ...    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${gnssMode}    value=${GLONASS_only}    operation=update
    ...    ELSE    act Glonass
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

act Glonass
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actBeidou    value=${False}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actGlonass    value=${True}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actGps    value=${False}    operation=update

act GPS-Beidou
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actBeidou    value=${True}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actGlonass    value=${False}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=actGps    value=${True}    operation=update

Get Version
    [Arguments]    ${connection}=cOAM_admin
    Log To Console    Get Version
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${versiontitle}    set variable    ${version_list[0]}
    [Return]    ${versiontitle}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Check Clockclass on WEBEM
    [Arguments]    ${value}    ${connection}=cOAM_admin
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    ${Clockclass}   coam.Get SCF single Value from current xml file
    ...   parameter=eCpriMasterClockClass   list_name=${None}
    ...   dist_name=MRBTS-${MRBTS_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    should be equal    ${Clockclass}    ${value}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Check fault
    [Arguments]    ${connection}=cOAM_admin
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    ${fault_name_list}     ${fault_id_list}     Get Alarm Info     timeout=1
    list should contain value    ${fault_id_list}    ${4298}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Change para GPS Beidou
    [Arguments]    ${LNAvalue}    ${holdover_time}    ${connection}=cOAM_admin
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    perform muti Parameter recommissioning    dist_name=${dist_ECPRIMASTER}    parameter=${holdover_threshold}
    ...    value=${holdover_time}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${LNApower}    value=${LNAvalue}    operation=update
    ${versiontitle}    Get Version
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    run keyword if    '${versiontitle}'=='SBTS21B'
    ...    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${gnssMode}    value=${GPS_Beidou}    operation=update
    ...    ELSE    act GPS-Beidou
   [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Case Teardown
    [Arguments]    ${connection}=cOAM_admin
    CI_interface.Common Case Teardown
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    perform muti Parameter recommissioning    dist_name=${dist_ECPRIMASTER}    parameter=${holdover_threshold}
    ...    value=${holdover_time_1325}    operation=update
    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${LNApower}    value=${True}    operation=update
    ${versiontitle}    Get Version
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    run keyword if    '${versiontitle}'=='SBTS21B'
    ...    perform muti Parameter recommissioning    dist_name=${dist_GNSS}    parameter=${gnssMode}    value=${GPS_Beidou}    operation=update
    ...    ELSE    act GPS-Beidou
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

#CB007597-B
Start RU tcpdump for LNApower
    [Arguments]  ${script_name}    ${dir_name}    ${logname}=${filename}
    ssh.connect_to      hostname=${host}
    ...                 username=${username}
    ...                 password=${password}
    ...                 alias=ute
    sleep    10s
    ssh.execute    command=chmod 777 ${ssh_script_path}/${dir_name}/${script_name}    connection=ute
    sleep    1s
    ssh.execute    command=${ssh_script_path}/${dir_name}/${script_name}    connection=ute
    sleep    1s
    ssh.disconnect    connection=ute
    Save Logs    log_file=${logname}

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
    log to console    ${output_log}
    log to console    ${pacp_filename}
    Convert pcap to text   source=${output_log}/${pacp_filename}
    ...  target=${output_log}/${txt_filename}   connection=${connection}    filter=${filter}
    ssh.Send Command  command=cat ${output_log}/${txt_filename} |${command}    connection=${connection}
    ${data}    ssh.Read Output    connection=${connection}
    ${data}    strip_string    ${data}
    [Return]   ${data}
    [Teardown]    run keyword and ignore error    ssh.Disconnect  	connection=${connection}

#CB007597-C
Modify scf file
    [Timeout]  20 min
    [Arguments]    ${value1}    ${value2}    ${MRBTS_ID}=${MRBTS_ID}    ${timeout}=10 min    ${scf_mame}=SCF_C.xml
    ...    ${value3}=true    ${connection}=cOAM_admin
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    coam.get_current_scf_file    local_dir_path=${output_log}    file_name=${scf_mame}    connection=cOAM_admin    timeout=60
    Run keyword and ignore error    coam.teardown      connection=${connection}
    ${scf_path}     set vari able    ${output_log}/${scf_mame}
    cscf.load_scf    ${scf_path}
    cscf.modify_scf_element    value=${value1}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1    p_name=frameStartOffset
    cscf.modify_scf_element    value=${value2}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1    p_name=sfnOffset
    cscf.modify_scf_element    value=${value1}   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2    p_name=frameStartOffset
    cscf.modify_scf_element    value=${value2}   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2    p_name=sfnOffset
    cscf.modify_scf_element    value=${value3}   dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    p_name=actCellTimingOffset
    cscf.save_scf    ${output_log}/scf.xml
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    COAM Commission with scf file ignore error    scf_file_path=${output_log}/scf.xml     connection=${conn}
    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Teardown]    Remove File    ${scf_path}

COAM Commission with scf file ignore error
    [Documentation]  Author: Liu Steven
    ...              Description: Do commission and verify commission status
    ...                           2019-11-12, add argument ${is_pdl_checking_needed} to open interface to tester if pdl checking is needed,
    ...                                       Valid values are: ${True} or ${False}, if ${True}, then pdl validation is needed,
    ...                                       otherwise will ignore this validation. Now it's default to ${True}
    [Arguments]  ${scf_file_path}    ${connection}=GNB_OAM    ${timeout}=300    ${is_pdl_checking_needed}=${True}
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

Check BTS is in On Air
    [Arguments]    ${connection}=cOAM_admin
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
    ADMIN Wait Until BTS OnAir
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

read the RU log
    Start RU tcpdump for LNApower    script_name=get_RU_log_AWEUA.sh    dir_name=CB007597-C    logname=${filename_C}
    Unzip the RU logs

Unzip the RU logs
    unzip_single_file    ${output_log}/${filename_C}    ${output_log}
    unzip_single_file   ${output_log}/1011_UnitOAM_SOAP_Log.zip    ${output_log}
    unzip_single_file    ${output_log}/1011_UnitOAM_SOAP_Log.zip    ${output_log}
    unzip_single_file    ${output_log}/UnitOAM_SOAP_Log0.xml.gz

check the RU log
    [Arguments]    ${search_string}=<alpha>0</alpha><beta>0</beta>
    ${alpha_value}    get_alpha_value    file_path=${output_log}/UnitOAM_SOAP_Log0.xml
    ...    search_string=${search_string}
    should be true    ${alpha_value} > 1

Adjust Enb
    [Arguments]    ${index}  ${alias}=enblte
    ${lncelid}    Get lncelid on enb    alias=${alias}
    ${dist_name}  set variable  MRBTS-${tl.enbs[0].global_bts_id}/LNBTS-${tl.enbs[0].global_bts_id}/LNCEL-${lncelid}
    ${parameter}  set variable  defaultLnRelGnbCellId
    ${value}  set variable  ${index}
    log to console  ${dist_name}
    Connect and Modify the parameter on enblte  ${dist_name}    ${parameter}     ${value}

make the call
    power_ue.Prepare UE    ue_type=samsung
    ${5Grach_ed_0}    power_ue.UE Attach    ue_type=samsung    attach_mode=5G_NSA
    power_ue.Verify attach    ue_type=samsung
    ...    5Grach_ed=${5Grach_ed_0}    4G_check=False
    UE start traffic    iperf_type=via_command
    power_ue.Check throughput    ue_type=samsung    direction=dl    throughput=5
    power_ue.Check throughput    ue_type=samsung    direction=ul    throughput=5
    UE stop traffic
    Log To Console    UE Detach
    run keyword and ignore error    power_ue.UE Detach    ue_type=samsung

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

Case samsung detach And Teardown
    Log To Console    UE Detach
    run keyword and ignore error    power_ue.UE Detach    ue_type=samsung
    CI_interface.Common Case Teardown



