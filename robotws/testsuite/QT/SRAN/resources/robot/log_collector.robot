*** Settings ***
Documentation
...    Module containing all log keywords.

Library    taf.transport.ssh              WITH NAME    ssh
Library    taf.collectors.btslog          WITH NAME    btslog
Library    taf.sbts.oam.coam.admin         WITH NAME    coam
Library    taf.hw.rf_diagnostic_card    WITH NAME    RDC
Library    taf.collectors.core
Library    ${CURDIR}/../python/log_collector.py


*** Keywords ***
Start BTSlogs Collection
    [Documentation]   Used to Start BTSlog collection in debug PC.
    [Timeout]           5min
    ${dualcore_or_fsmf_configuration}    Set Variable If
    ...   '${cellConfiguration}'=='ASIB_FSMF_ABIA_4G_3G_2G_FDD' or '${cellConfiguration}'=='ASIM_ASIM_ABIO_5G_NSA_4G_3G_2G_FDD'
    ...                                                     True    False
    ${Logs_eNB_NSA}    Get Variable Value    ${Logs_eNB_NSA}    False
    Set Suite Variable    ${Logs_eNB_NSA}
    ssh.reset_cache
    BuiltIn.Sleep             3s
    IF    ${dualcore_or_fsmf_configuration}
        &{pc_name_map}    Create Dictionary    pcs[0]=_slave    pc=${EMPTY}
    ELSE IF    ${Logs_eNB_NSA}
        &{pc_name_map}    Create Dictionary    pcs[0]=_eNb_NSA    pc=${EMPTY}
    ELSE
        &{pc_name_map}    Create Dictionary    pc=${EMPTY}
    END
    FOR    ${pc}    ${name}    IN    &{pc_name_map}
        TRY
            ${console_name}=    Set Variable If   '${name}'!='${EMPTY}'     ${name[1:]} BTSLOG       BTSLOG
            Log To Console    \t\t - - - Starting ${console_name.strip()} [...] - - -
            ssh.connect_to     hostname=${tl.test_${pc}.default_ssh_connection_details.addr}
            ...                username=${tl.test_${pc}.default_ssh_connection_details.username}
            ...                password=${tl.test_${pc}.default_ssh_connection_details.password}
            ...                alias=debugpc${name}
            ssh.send_command    sudo iptables -I INPUT -p udp -d 192.168.255.126 --dport 51000 -j ACCEPT
            ...    connection=debugpc${name}
            ${ssh_error_out}=    ssh.Read Error    connection=debugpc${name}
            IF   '''${ssh_error_out}'''
                Log To Console    \n\t\t > > > Error occured while trying to unblock port for BTSlog:  ${ssh_error_out}< < < [ !!! ]
            END
            ssh.send_command  sed -i -r 's|(SysLogFileTemplate=/tmp/btslog2/)[^%]*%1\\.txt|\\1SYSLOG_%1.LOG|g' /home/ute/btslog2/btslog.ini
            ...    connection=debugpc${name}
            ${output}  ssh.execute
            ...    if [ ! -d /tmp/btslog2/ ]; then mkdir /tmp/btslog2/; else rm -f /tmp/btslog2/SYSLOG* /tmp/SYSLOG*.tgz /tmp/5Grach*.txt; fi
            ...    connection=debugpc${name}    timeout=60s
            ssh.send_command  pkill btslog    connection=debugpc${name}
            &{executor}       Create Dictionary    host=${tl.test_${pc}.default_ssh_connection_details.addr}
            ...                                    user=${tl.test_${pc}.default_ssh_connection_details.username}
            ...                                    password=${tl.test_${pc}.default_ssh_connection_details.password}
            btslog.create_btslog_collector    name=btslog${name}
            ...                               btslog_path=/opt/btslog/btslog
            ...                               btslog_launcher_path=/opt/btslog/btslog_launcher
            ...                               executor=${executor}
            btslog.set_suite_alias    btslog${name}
            taf.collectors.core.setup_collectors    names=btslog${name}
            taf.collectors.core.start_collectors    names=btslog${name}
            BuiltIn.Sleep             10s
            ${syslog_file}    ssh.execute    command=find /tmp/btslog2 -name \"*.LOG\"
            ...                              connection=debugpc${name}    timeout=60s
            Run Keyword If    '${syslog_file.strip()}' != ''    Log To Console    \t\t - - - ${console_name.strip()} started - - -
            ...        ELSE       Log To Console    \n\t\t > > > Problem occured during ${console_name.strip()} start < < < [ !!! ]
            BuiltIn.Set Suite Variable    ${syslog_file}
        EXCEPT    AS    ${error}
            Log   Start Btslog failed due to ${error}    WARN
        END
    END
    [Teardown]    ssh.disconnect    connection=debugpc${name}

Upload Swconfig To Rotta
    Wait Until Keyword Succeeds     1min  15s    Connect To Common Unit    alias=smod
    Run Keyword And Ignore Error    ssh.download_file    remote_path=/ffs/run/swconfig.txt
    ...                                                  local_path=${OUTPUT_DIR}/Additional_Execution_Logs/swconfig.txt
    ...                                                  connection=smod
    [Teardown]    ssh.disconnect    connection=smod

Upload Readme Logs
    Run    cp ${CURDIR}/../scripts/readme_logs.txt ${OUTPUT_DIR}/readme_logs.txt

Save Snapshot For Classical
    [Arguments]         ${name}=${EMPTY}    ${connection_status}=True    ${bts_lmp_ip}=${FSM_SLAVE_IP}    ${dir}=${OUTPUT_DIR}
    ...                 ${connection}=coam_admin    ${sw_d}=None        ${snapshot_test}=${False}
    ${sw_d}             Run Keyword If    ${connection_status}    coam.get_sw_version    connection=${connection}
    ${console_name}     Set Variable    ${name[1:]} Snapshot
    Run Keyword If        'slave' in '${name}' or 'eNb' in '${name[1:]}'  Setup Admin
    ...                   bts_host=${bts_lmp_ip}
    ...                   admin_api_log_dir=${OUTPUT_DIR}/ADMIN_API_${name[1:]}
    ...                   remote_host=${tl.test_pcs[0].default_ssh_connection_details.addr}
    ...                   alias=${name}
    Log To Console      \n\t\t- - - Collecting ${console_name.strip()} file [...] - - -
    ${timestamp}        robot.libraries.DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    ${snapshot_path}    Set Variable    ${dir}/${tl.tl_cloud_topology}_Snapshot_${sw_d}_${timestamp}${name}.zip
    ${snapshot_path_for_marvin}    Set Variable    ${tl.tl_cloud_topology}_Snapshot_${sw_d}_${timestamp}${name}.zip
    Set Suite Variable             ${snapshot_path_for_marvin}
    Set Suite Variable             ${snapshot_path}
    ${timeout}          Set Variable If  'ASIK' in '${smod_type}'   1800   720
    ${log_status}       Run Keyword if    ${connection_status}    Run Keyword And Return Status
    ...                 Wait Until Keyword Succeeds    5min    30s    coam.Get Snapshot
    ...                 target_file_name=${snapshot_path}
    ...                 connection=${connection}
    ...                 timeout=${timeout}
    IF    ${snapshot_test}
        RETURN    ${log_status}
    END
    Run Keyword If      '${log_status}'=='None' and 'slave' in '${name}' or 'eNb' in '${name}'
    ...                 Run Keyword And Ignore Error    Collect Snapshot With AaShell On BTS
    ...                 host=test_pcs[0]    fsm_ip=${bts_lmp_ip}    name=${name}
    ...                 snapshot_file=${tl.tl_cloud_topology}_Snapshot_FCT_${name[1:]}_${timestamp}.zip
    ...                 script_path=/home/ute/sbts_qt/fdd_scripts/enb/snapshot_from_aashell.sh
    ...    ELSE IF      '${log_status}'=='False' or '${log_status}'=='None'    Run Keyword And Ignore Error
    ...                 Collect Snapshot With AaShell On ${name[1:]} BTS
    ...                 snapshot_file=${tl.tl_cloud_topology}_Snapshot_FCT_${name[1:]}_${timestamp}.zip
    Run Keyword If      ${log_status}    Log To Console    \t\t- - - Collecting ${console_name.strip()} file [DONE] - - -

Save SCF For Classical
    [Arguments]           ${connection_status}=True
    Log To Console        \n\t\t- - - Collecting SCF file [...] - - -
    Run Keyword If      ${connection_status}    Run Keywords
    ...    coam.get_current_scf_file    local_dir_path=${OUTPUT_DIR}/
    ...                          file_name=scf_from_webui_${tl.tl_cloud_topology}.xml
    ...                          timeout=60
    ...                          connection=coam_admin
    ...    AND    Log To Console    \t\t- - - Collecting SCF file [DONE] - - -
    ...    ELSE    Log To Console    \t\t- - - Collecting SCF file [SKIPPED] - - -

Collect Validation Log from Snapshot
    [Arguments]     ${cu_du}
    Run             mkdir ${OUTPUT_DIR}/Snapshot/
    ${snapshot}     Set Variable    ${OUTPUT_DIR}/Snapshot
    Run    unzip ${${cu_du}_snapshot_path} -d ${OUTPUT_DIR}/Snapshot/
    BuiltIn.Sleep           2s
    Run             cat ${snapshot}/snapshot_file_list.txt | grep "part\\|OAM_CM_SNAPSHOT" > ${snapshot}/part.txt
    ${log_path}     Run    cat ${snapshot}/part.txt | grep -B 1 OAM_CM > ${snapshot}/logpath.txt
    ${log_path_status}    should not be empty      ${log_path}
    ${log_path2}    Run keyword if    ${log_path_status}    Run    cat ${snapshot}/logpath.txt | grep part
    ${log_path3}    Run keyword if    ${log_path_status}    Fetch From Left    ${log_path2}    :
    Run keyword if    ${log_path_status}      Run             unzip ${snapshot}/${log_path3} -d ${snapshot}/Logs
    ${zip_file}     Run keyword if    ${log_path_status}    Run      ls ${snapshot}/Logs | grep OAM_CM_SNAPSHOT
    Run keyword if    ${log_path_status}    Run             cd ${snapshot}/Logs && tar -xf ${zip_file}
    Run keyword if    ${log_path_status}    BuiltIn.Sleep           2s
    ${cp_log}       Catenate    cp ${snapshot}/Logs/mnt/services/SS_OAM*/OAMCM/working_dir/validation_plan/last/feedback*.xml
    ...                         ${OUTPUT_DIR}/${cu_du}_SCF_validation_log.xml
    Run keyword if    ${log_path_status}    Run             ${cp_log}
    Run             rm -rf ${OUTPUT_DIR}/Snapshot

Stop BTSlogs Collection And Get Logs
    [Arguments]        ${target_path}=${None}
    ...                ${local_path}=${tl.tl_cloud_topology}_${loadBuild}_SYSLOG_
    ${dualcore_or_fsmf_configuration}    Set Variable If
    ...    '${cellConfiguration}'=='ASIB_FSMF_ABIA_4G_3G_2G_FDD' or '${cellConfiguration}'=='ASIM_ASIM_ABIO_5G_NSA_4G_3G_2G_FDD'
    ...    True    False
    Get test timestamp
    ssh.reset_cache
    BuiltIn.Sleep              3s
    IF    ${dualcore_or_fsmf_configuration}
        &{pc_name_map}    Create Dictionary    pcs[0]=_slave    pc=${EMPTY}
    ELSE IF    ${Logs_eNB_NSA}
        &{pc_name_map}    Create Dictionary    pcs[0]=_eNb_NSA    pc=${EMPTY}
    ELSE
        &{pc_name_map}    Create Dictionary    pc=${EMPTY}
    END
    FOR    ${pc}    ${name}    IN    &{pc_name_map}
        TRY
            ${console_name}=    Set Variable If   '${name}'!='${EMPTY}'     ${name[1:]} BTSLOG       BTSLOG
            ${hostname}    Set Variable    ${tl.test_${pc}.default_ssh_connection_details.addr}
            ${username}    Set Variable    ${tl.test_${pc}.default_ssh_connection_details.username}
            ${password}    Set Variable    ${tl.test_${pc}.default_ssh_connection_details.password}
            ssh.connect_to     hostname=${hostname}
            ...                username=${username}
            ...                password=${password}
            ...                alias=debugpc${name}
            taf.collectors.core.stop_collectors    names=btslog${name}
            ${index}           ssh.execute    command=/opt/btslog/btslog_launcher current_index
            ...                               connection=debugpc${name}    timeout=60s
            Run Keyword If     '${syslog_file.strip()}' != ''
            ...    Log To Console    \n\t\t- - - ${console_name.strip()} stopped = SYSLOG_${index.strip()}.LOG - - -
            ...    ELSE    Log To Console    \n\t\t> > > Problem occured with ${console_name.strip()} < < < [ !!! ]\n
            ${merge_command}   Set Variable    cd /tmp/btslog2 && ls -ltr | grep 'SYSLOG_*' | awk '{print $9}' | xargs cat > SYSLOG_${timestamp}.LOG
            ssh.execute        ${merge_command}    connection=debugpc${name}    timeout=60s
            Run Keyword and continue on failure    Additonal Check in Logs    file_path=/tmp/btslog2/SYSLOG_${timestamp}.LOG
            ${command}         Set Variable    cd /tmp/btslog2 && tar zcvf /tmp/SYSLOG_${timestamp}.tgz SYSLOG_${timestamp}.LOG
            ssh.execute        ${command}      connection=debugpc${name}    timeout=60s
            IF    '${name}'=='${EMPTY}'
                ssh.execute    cp /tmp/SYSLOG_${timestamp}.tgz ${target_path}/${local_path}${timestamp}.tgz
                ...            connection=debugpc${name}    timeout=240s
            ELSE
                ${cmd}    Catenate    sshpass -p ${password}
                ...       scp ${username}@${hostname}:/tmp/SYSLOG_${timestamp}.tgz ${target_path}/${local_path}${timestamp}${name}.tgz
                RUN    ${cmd}
            END
        EXCEPT    AS    ${error}
            Log   Stop Btslog failed due to ${error}    WARN
        END
        ${syslog_path_for_marvin}     Set Variable    ${local_path}${timestamp}${name}.tgz
        Set Suite Variable            ${syslog_path_for_marvin}
        ssh.execute        cd /tmp/btslog2 && sudo rm -f BTSLOG_TRACE_*.bin *.LOG executionlog*.txt    connection=debugpc${name}
        ...                timeout=30s
        taf.collectors.core.teardown_collectors    names=btslog${name}
    END
    [Teardown]         ssh.disconnect    connection=debugpc${name}

Collect RU Logs
    Run Keyword If    '${tl.tl_cloud_topology}' in ${testlines_with_LMI}    Run Keywords    Log To Console
    ...    \n\t\t- - - Collecting logs from RU [...] - - -
    ...    AND        Get Logs From RU
    ...    ELSE       Log To Console    \n\t\t- - - LMI not connected to RU - - -

RU varaiables
    [Documentation]       Get RU variables    author: Michal Werstler
    ${ru_type}            Get Variable Value    ${tl.${gnb_or_enb}s[0].dus[0].rus[0].ru_hw_group}
    ${ru_user}            Get Variable Value    ${tl.${gnb_or_enb}s[0].dus[0].rus[0].default_ssh_connection_details.username}
    ${ru_pass}            Get Variable Value    ${tl.${gnb_or_enb}s[0].dus[0].rus[0].default_ssh_connection_details.password}
    ${ru_ip_lmi}          Get Variable Value    ${tl.${gnb_or_enb}s[0].dus[0].rus[0].lmp_connection.addr}
    Set suite variable    ${ru_type}
    Set suite variable    ${ru_user}
    Set suite variable    ${ru_pass}
    Set suite variable    ${ru_ip_lmi}

Route from VM to RU
    [Documentation]        Check/Add route on VM for specific RU    author: Michal Werstler
    ${ru_type_check}       Run Keyword and Return Status    Should Contain    ${ru_type}    AEQE
    ssh.send_command       ip a    connection=vm
    ${check_ip_address}    ssh.read_output    connection=vm
    ${ip_addr_status1}     Run Keyword and Return Status    Should Contain    ${check_ip_address}    192.168.1.100/24 scope global eth1
    ${ip_addr_status2}     Run Keyword and Return Status    Should Contain    ${check_ip_address}    192.168.101.1/24 scope global eth1
    Run Keyword If         '${ip_addr_status1}'=='False' and '${ru_type_check}'=='True'    Run Keyword
    ...                    ssh.send_command    sudo ip addr add 192.168.102.100/24 dev eth1    connection=vm
    ...    ELSE IF         '${ip_addr_status2}'=='False' and '${ru_type_check}'=='False'    Run Keyword
    ...                    ssh.send_command    sudo ip addr add 192.168.101.1/24 dev eth1    connection=vm
    ssh.send_command       ip r    connection=vm
    ${check_route}         ssh.read_output    connection=vm
    ${route_status1}       Run Keyword and Return Status    Should Contain    ${check_route}    192.168.1.0/24 dev eth1
    ${route_status2}       Run Keyword and Return Status    Should Contain    ${check_route}    192.168.100.0/23 dev eth1
    Run Keyword If         '${route_status1}'=='False' and '${ru_type_check}'=='True'     Run Keyword
    ...                    ssh.send_command    sudo ip route add 192.168.102.0/24 dev eth1 src 192.168.102.100    connection=vm
    ...    ELSE IF         '${route_status2}'=='False' and '${ru_type_check}'=='False'    Run Keyword
    ...                    ssh.send_command    sudo ip route add 192.168.100.0/23 dev eth1 src 192.168.101.1      connection=vm

Get Logs From RU
    [Documentation]      Gets full logs from RU (ssh to RU via container and lmi if connected)    author: Michal Werstler
    Run Keyword          RU varaiables
    Connect to host      alias=vm
    ssh.send_command     sudo rm /tmp/ru_logs_lmi.zip    connection=vm
    Run Keywords         Route from VM to RU
    ...    AND           get_logs_from_ru_lmi    alias=vm
    ...                                          ru_type=${ru_type}
    ...                                          rf_ip=${ru_ip_lmi}
    ...                                          user=${ru_user}
    ...                                          password=${ru_pass}
    Run Keyword          ssh.download_file
    ...                  remote_path=/tmp/ru_logs_lmi.zip
    ...                  local_path=${OUTPUT_DIR}/RU_logs/ru_logs_lmi.zip
    ...                  connection=vm
    ssh.send_command     ls /tmp            connection=vm
    ${lmi_logs_check}    ssh.read_output    connection=vm
    ${log_status2}       Run Keyword and Return Status    Should Contain    ${lmi_logs_check}    ru_logs_lmi
    Run Keyword If       '${log_status2}'=='True'    Run Keywords
    ...                  Log To Console      \t\t- - - Collecting logs from RF by LMI [DONE] - - -
    ...    AND           ssh.send_command    sudo rm -f ru_logs_lmi.zip    connection=vm
    ...    ELSE          Log To Console      \t\t- - - Collecting logs from RF by LMI [FAILED] - - -
    [Teardown]           ssh.disconnect    connection=vm

Start RU Tcpdump
    [Documentation]    Collects .pcap files from RU if connected through LMI.    author: Michal Werstler
    Run Keyword                     RU varaiables
    ssh.reset_cache
    Connect to host                 alias=vm
    Run Keyword                     Route from VM to RU
    Connect To Common Unit          alias=smod
    Run Keyword If       '${ru_type}'=='AEQE'    add_tcpdump_for_AEQE
    ...                                          alias=vm
    ...                                          rf_ip=${ru_ip_lmi}
    ...                                          user=${ru_user}
    ...                                          password=${ru_pass}
    Run Keyword And Ignore Error    Start_tcpdump_on_SMOD_FHNET    alias=smod
    Run Keyword And Ignore Error    Start_tcpdump_on_RU            alias=vm
    ...                                                            ru_type=${ru_type}
    ...                                                            rf_ip=${ru_ip_lmi}
    ...                                                            user=${ru_user}
    ...                                                            password=${ru_pass}
    [Teardown]    Run Keyword      ssh.disconnect                  connection=vm

Collect RU Tcpdump
    [Documentation]    Collects .pcap files from RU if connected through LMI.    author: Michal Werstler
    ssh.reset_cache
    Connect to host                 alias=vm
    Connect To Common Unit          alias=smod
    ssh.send_command                sudo rm -f FHNET.pcap                  connection=smod
    ssh.send_command                sudo rm -f /tmp/LMI_${ru_type}.pcap    connection=vm
    Run Keyword And Ignore Error    Stop_tcpdump_on_SMOD_FHNET       alias=smod
    Run Keyword And Ignore Error    Stop_tcpdump_on_RU               alias=vm
    ...                                                              rf_ip=${ru_ip_lmi}
    ...                                                              ru_type=${ru_type}
    ...                                                              user=${ru_user}
    ...                                                              password=${ru_pass}
    Run Keyword And Ignore Error    Collect_tcpdump_on_RU            alias=vm
    ...                                                              ru_type=${ru_type}
    ...                                                              rf_ip=${ru_ip_lmi}
    ...                                                              user=${ru_user}
    ...                                                              password=${ru_pass}
    ssh.download file    remote_path=/user/toor4nsn/FHNET.pcap       local_path=${OUTPUT_DIR}/RU_logs/FHNET.pcap
    ...                  connection=smod
    ssh.download file    remote_path=/tmp/LMI_${ru_type}.pcap    local_path=${OUTPUT_DIR}/RU_logs/LMI_${ru_type}.pcap
    ...                  connection=vm
    [Teardown]    Run Keywords    ssh.disconnect    connection=vm
    ...           AND             ssh.disconnect    connection=smod

Connect to gNB and start collecting logs on ABIP
    ${connection}     Run Keyword And Return Status    ssh.connect_to
    ...               hostname=192.168.255.129
    ...               username=toor4nsn
    ...               password=oZPS0POrRieRtu
    ...               alias=gnb
    ${command}        Catenate    echo 1 > /proc/sys/kernel/ftrace_enabled; cd /sys/kernel/debug/tracing;
    ...                           echo rvu:* > set_event; echo 1 > tracing_on
    ssh.send_command  ${command}    connection=gnb
    ssh.execute       cat /proc/sys/kernel/ftrace_enabled         connection=gnb    timeout=60s
    ssh.execute       cat /sys/kernel/debug/tracing/set_event     connection=gnb    timeout=60s
    ssh.execute       cat /sys/kernel/debug/tracing/tracing_on    connection=gnb    timeout=60s
    [Teardown]        ssh.disconnect                              connection=gnb

Collect Snapshot With AaShell On BTS
    [Arguments]                          ${host}=test_pc    ${timeout}=90    ${dir}=/tmp
    ...                                  ${fsm_ip}=${LMP_IP}    ${name}=master
    ...                                  ${snapshot_file}=${tl.tl_cloud_topology}_Snapshot_FCT_${name}.zip
    ...                                  ${script_path}=${CURDIR}/../scripts/snapshot_from_aashell.sh
    Log To Console                       \t - - - Start gNB snapshots collecting via aashell - - -
    ssh.connect_to                       hostname=${tl.${host}.default_ssh_connection_details.addr}
    ...                                  username=${tl.${host}.default_ssh_connection_details.username}
    ...                                  password=${tl.${host}.default_ssh_connection_details.password}
    ...                                  alias=snapshot_aashell
    ssh.execute                          command=expect ${script_path} ${fsm_ip} 15007 ${snapshot_file} ${dir} ${timeout}
    ...                                  connection=snapshot_aashell    timeout=60s
    ssh.download_file                    remote_path=${dir}/${snapshot_file}
    ...                                  local_path=${OUTPUT_DIR}/${snapshot_file}
    ...                                  connection=snapshot_aashell
    ssh.execute                          rm ${dir}/${snapshot_file} -v
    ...                                  connection=snapshot_aashell    timeout=60s
    File Should Exist                    ${OUTPUT_DIR}/${snapshot_file}
    Log To Console                       \t - - - Snapshot collected from gNB via aashell - - -
    [Teardown]                           ssh.disconnect      connection=snapshot_aashell

Setup RDC
    [Documentation]    Keyword is preparing log directory, try to create Com connections to the RUs that have correctly defined lmi structure
    ...                in __init__.py and added it to the RU structure and get RU password required for gathering Snapshot via LMI ssh connection.
    ...                Example init for AVQL RU and LMI board:
    ...
    ...                _lmi_card1 = LMI(product_code="093193A.X03",
    ...                uart_mapping=[Local(port="COM4"), Local(port="COM3")],
    ...                host=TestPc(default_ssh_connection_details=SshServiceDetails(addr="10.44.72.172",
    ...                                                                             username="wro5gqt",
    ...                                                                             password="5Gqtmoth")))
    ...
    ...                _lmi_card1.lmi_ssh_ru = { "addr": "192.168.101.1", "fh_interface": "eCPRI", "username": "serviceuser"}
    ...
    ...               _lmi_card1.rsi_port = "9093"
    ...
    ...                _ru = RU(
    ...                ru_hw_group="cMAAr7.1_64T64R_4M",
    ...                default_ssh_connection_details=SshServiceDetails(
    ...                addr="172.22.0.154", username="rfsw", password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0="
    ...                ),
    ...                lmp_connection=SshServiceDetails(
    ...                addr="5.5.5.5", username="rfsw", password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0="
    ...                ),
	...                serial_number="L1233203407",
	...                radio_type="AVQL",
	...                lmi=_lmi_card1,
    ...                pdu_port=_5g_ru_pdu.pdu_ports[1],
    ...                )
    ...                PRE: Keyword requires list of RUs defined in __init__.py: ${tl.gnbs[0].dus[0].rus} with correctly filled LMI section and added
    ...                     to the RU section.
    ...                POST: Keyword check if list of RUs is not empty and if it is empty returns None. If list is not empty keyword iterates over RU
    ...                      objects and tries to setup RDC connection (lmi section has to be defined in object and additional lmi parameters have
    ...                      to be defined if LMI board is used and ssh snapshot download is required).
    ${skip_log_collection}    Get Variable Value    ${skip_log_collection}    ${False}
    IF    ${skip_log_collection}    RETURN    None
    ${rus}=    Get Variable Value    ${tl.gnbs[0].dus[0].rus}    None
    IF    not $rus
        Log    \t> > > Setup RDC: rus structure in __init__.py is empty. RDC will be not setup (normal for cloud setups). < < <    WARN
        RETURN    None
    END
    ${prepare_rdc}=    Set Variable    ${FALSE}
    FOR    ${ru_num}    IN RANGE    ${{len($rus)}}
        ${lmi}=    Get Variable Value    ${tl.gnbs[0].dus[0].rus[${ru_num}].lmi}    None
        IF    ${lmi}
            ${prepare_rdc}=    Set Variable    ${TRUE}
        END
        Exit For Loop If     ${prepare_rdc}
    END
    IF    not ${prepare_rdc}    RETURN    None
    Log To Console     \t\t- - - Connection to host and creating log directory for RDC [...]. - - -
    TRY
        RDC.Prepare Log Directory And Connection Setup    main_log_directory=${RDC_LOGS}
    EXCEPT    AS    ${error}
        Log    \t> > > RDC main log directory preparation on VM failed due to ${error} < < <    WARN
        RETURN    None
    ELSE
        Log To Console     \t\t- - - Connection to host and creating log directory for RDC [DONE]. - - -
    END
    ${rus_dict}=    Fill RDC Data    rus=${rus}
    RETURN    ${rus_dict}

Fill RDC Data
    [Documentation]    Keyword try to setup RDC serial connwctions and fill rus_dict dictionary.
    ...                If operation was correct filled  rus_dict structure is returned, in other case None is returned.
    ...                PRE: Keyword takes rus argument containing list of RU object defined in __init__.py. For more informations regarding LMI object
    ...                     please check:
    ...                     https://wrgitlab.ext.net.nokia.com/TAF/taf.config.testline/-/blob/main/taf/config/testline/lmi.py
    ...                POST: Keyword returns rus_dict. If informations provided in __init__.py were enought to setup RDC connection and trigger RDC
    ...                      snapshot rus_dict will be filled with data and snapshot_capable attribute will be set to the True and rus_dict will be
    ...                      returned. If serial connection suceeds but provided data will be not enought to perform RDC snapshot snapshot_capable
    ...                      attribute will be set to the False and rus_dict will be returned. If setup for all RDC connections fail or required
    ...                      data in __init__.py will be not provided at all None value will be returned.
    [Arguments]    ${rus}
    ${rus_dict}=    Create Dictionary
    FOR    ${ru_num}    IN RANGE    ${{len($rus)}}
        ${ru_serial}=       Get Variable Value    ${rus[${ru_num}].serial_number}    unknown
        ${rsi_port}=        Get Variable Value    ${rus[${ru_num}].lmi.rsi_port}    None
        ${has_rsi_port}=    Evaluate    '${rsi_port}' != 'None'
        IF    not ${has_rsi_port}
            Log    \t> > > Fill RDC Data: rsi_port not defined in __init__.py. RDC will be not started for RU S/N: ${ru_serial} < < <    WARN
            CONTINUE
        END
        TRY
            ${alias_list}=    RDC.Setup Connections    ru_config=${rus[${ru_num}]}    port=${rsi_port}
        EXCEPT    AS    ${error}
            Log    \t> > > Fill RDC Data: Com port connection preparation for RU S/N: ${ru_serial} on host failed due to ${error} < < <    WARN
            CONTINUE
        END
        IF    ${alias_list}
            ${internal_id}=    Associate Ruobject To Serial    serial_number=${alias_list[0]}
            IF    '${internal_id}' != 'None'
                ${entry}=    Create Dictionary    com_aliases    ${alias_list}
                Set To Dictionary    ${rus_dict}    ${internal_id}   ${entry}
            ELSE
                CONTINUE
            END
            ${radio_type} =           Get Variable Value    ${rus[${ru_num}].radio_type}    None
            ${lmi_host_ip} =          Get Variable Value    ${rus[${ru_num}].lmi.host.default_ssh_connection_details.addr}    None
            ${lmi_host_username} =    Get Variable Value    ${rus[${ru_num}].lmi.host.default_ssh_connection_details.username}    None
            ${lmi_host_password} =    Get Variable Value    ${rus[${ru_num}].lmi.host.default_ssh_connection_details.password}    None
            ${has_lmi_ssh_ip}=        Run Keyword And Return Status    Dictionary Should Contain Key    ${rus[${ru_num}].lmi.lmi_ssh_ru}    addr
            ${has_fh_interface}=      Run Keyword And Return Status
            ...                       Dictionary Should Contain Key    ${rus[${ru_num}].lmi.lmi_ssh_ru}    fh_interface
            ${has_username}=          Run Keyword And Return Status    Dictionary Should Contain Key    ${rus[${ru_num}].lmi.lmi_ssh_ru}    username
            ${condition1}=            Evaluate    ${has_lmi_ssh_ip} and ${has_fh_interface} and ${has_username} and '${radio_type}' != 'None'
            ${condition2}=            Evaluate    '${lmi_host_ip}' != 'None' and '${lmi_host_username}' != 'None' and '${lmi_host_password}' != 'None'
            IF    ${condition1} and ${condition2}
                ${lmi_ssh_ip}=          Get From Dictionary    ${rus[${ru_num}].lmi.lmi_ssh_ru}    addr
                ${fh_interface}=        Get From Dictionary    ${rus[${ru_num}].lmi.lmi_ssh_ru}    fh_interface
                ${lmi_ssh_username}=    Get From Dictionary    ${rus[${ru_num}].lmi.lmi_ssh_ru}    username
                ${lmi_ssh_pass}=        Get RU Password
                ...    radio_type=${radio_type}
                ...    fh_interface=${fh_interface}
                ...    username=${lmi_ssh_username}
                IF    '${lmi_ssh_pass}' != 'None'
                Set To Dictionary    ${rus_dict['${internal_id}']}    lmi_ssh_username    ${lmi_ssh_username}    lmi_ssh_pass    ${lmi_ssh_pass}
                ...                      lmi_ssh_ip    ${lmi_ssh_ip}    lmi_host_ip    ${lmi_host_ip}
                ...                      lmi_host_ip    ${lmi_host_ip}    lmi_host_username    ${lmi_host_username}
                ...                      lmi_host_password    ${lmi_host_password}    snapshot_capable    ${TRUE}
                ELSE
                    Set To Dictionary    ${rus_dict['${internal_id}']}    snapshot_capable    ${FALSE}
                    Log    \t> > > Fill RDC Data: For RU S/N:${alias_list[0]} couldn't get LMI ssh password for user: ${lmi_ssh_username} < < <
                END
            ELSE
                Log    \t> > > Fill RDC Data: RU S/N:${alias_list[0]} doesn't have required ssh connection details for RDC Snap in __init__.py. < < <
                ...    WARN
                Set To Dictionary    ${rus_dict['${internal_id}']}    snapshot_capable    ${FALSE}
            END
        END
    END
    IF    ${rus_dict}
        RETURN    ${rus_dict}
    ELSE
        RETURN    None
    END

Get RU Password
    [Documentation]    Keyword try obtain RU password based on passed arguments on which the password depends.
    ...                PRE:  Keyword requires as arguments: radio_type, fh_interface (eg. ecpri, cpri, obsai), username.
    ...                      For more details please check:
    ...                      https://wrgitlab.ext.net.nokia.com/TAF/taf.config.testline/-/blob/main/taf/config/testline/info/testline_info.py
    ...                POST: If provided data is correct, keyword tries to get user password. If operation suceeds keyword will
    ...                      return password. In other cases keyword will return None.
    [Arguments]    ${radio_type}    ${fh_interface}    ${username}
    TRY
        ${ru_password}=    testline_info.Get Ru Password    by_radio_type=${radio_type}    fh_interface=${fh_interface}    username=${username}
    EXCEPT    AS    ${error}
        Log    \t> > > Get RU Password: Error while trying to get RU password: ${error}. < < <    WARN
        RETURN    None
    ELSE
        RETURN    ${ru_password}
    END

Associate Ruobject To Serial
    [Documentation]    Keyword try to associate alias string (which contain serial number) to the internal ru object RMOD_R-\\d+.
    ...                Created pair will be used to determine for which rmod lib has to take snapshot when FID:10
    ...                will be discovered on active alarm list.
    ...                PRE: Keyword requires alias string containing RU serial number and name of the active coam BTS connection.
    ...                POST: If keyword will be able to create association they will return RU internal_id string, eg: RMOD_R-1.
    ...                In other case it will return None.
    [Arguments]    ${serial_number}    ${connection}=coam_admin
    TRY
        ${bts_info}    coam.get_bts_info    timeout=20    connection=${connection}
    EXCEPT    AS    ${error}
        Log    \t> > > Associate Ruobject To Serial: Getting BTS info failed: ${error} < < <    WARN
        RETURN    None
    ELSE
        ${bts_info_no_empty}=    Run Keyword And Return Status    Should Not Be Empty    ${bts_info}
        IF    ${bts_info_no_empty}
            ${internal_id}=    Check Internal Id By Serial    data=${bts_info}    serial_number=${serial_number}
            IF    '${internal_id}' != 'None'
                RETURN    ${internal_id}
            ELSE
                RETURN    None
            END
        ELSE
            Log    \t> > > Associate Ruobject To Serial: coam.get_bts_info returned empty structure. < < <    WARN
            RETURN    None
        END
    END

Check Internal Id By Serial
    [Documentation]    Keyword iterate over bts info radioModules dict and try to match RU serial number (passed as alias)
    ...                to the serial and internal id stored in bts info structure.
    ...                PRE: Keyword requires as argument not empty bts info data structure
    ...                     and the serial_number, whose internal id is being searched for in data bts info structure.
    ...                POST: If keyword find in data structure serial that match serial given as argument and
    ...                      its internal is compilant with the format RMOD_R-\\d+ internal id is returned in other case None is returned.
    [Arguments]    ${data}    ${serial_number}
    &{rmods}=    Create Dictionary
    ${has_ru_data}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${data}    radioModules
    IF    ${has_ru_data}
        ${ru_modules_properties}=    Get From Dictionary    ${data}    radioModules
    ELSE
        Log    \t> > > Check Internal Id By Serial: No radioModules info in data structure returned by coam.get_bts_info. < < <    WARN
        RETURN    None
    END
    FOR    ${radio_section}    ${radio_section_elem}    IN    &{ru_modules_properties}
        ${radio_section_elem_not_empty}=    Run Keyword And Return Status    Should Not Be Empty    ${radio_section_elem}
        IF    ${radio_section_elem_not_empty}
            FOR    ${radio}    IN    @{radio_section_elem}
                ${has_serial_number}=    Run Keyword And Return Status    Dictionary Should Contain Key   ${radio}    serialNumber
                IF    ${has_serial_number}
                    ${serial_from_data}=    Get From Dictionary    ${radio}    serialNumber
                ELSE
                    Log    \t> > > Check Internal Id By Serial: No RU serialNumber info in data structure returned by coam.get_bts_info. < < <    WARN
                    CONTINUE
                END
                ${has_internal_id}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${radio['id']}    internal
                IF    ${has_internal_id}
                    ${internal_id}=        Get From Dictionary    ${radio['id']}    internal
                    ${match}=              Get Regexp Matches    ${internal_id}    RMOD_R-\\d+
                    ${match_not_empty}=    Run Keyword And Return Status    Should Not Be Empty    ${match[0]}
                    IF    '${serial_number}' == '${serial_from_data}'
                        RETURN    ${match[0]}
                    END
                ELSE
                    Log    \t> > > Check Internal Id By Serial: No internal id info in data structure returned by coam.get_bts_info. < < <    WARN
                    CONTINUE
                END
            END
        ELSE
            Log    \t> > > Check Internal Id By Serial: Failed to get RU properties for ${radio_section}. < < <    WARN
            CONTINUE
        END
    END
    RETURN    None

RDC Snapshot
    [Documentation]    Keyword check if RDC snapshot is triggered because of fid occurence and only for specific RMOD/s or for all
    ...                RDC Snapshot capable RMODS.
    ...                PRE:  Keyword has two optional arguments that are required if RDC snapshot has to be performed in consequence of fid occurence.
    ...                      In this case keyword is called from Log To Console Not Allowed Alarms keyword defined in allowed_alarms.robot and
    ...                      has to have fid_trig_snapshot set to True and passed rmod_with_fid_list list being a return value of
    ...                      get_rsi_snapshot_rmods Python function defined in alarms_keywords.py
    ...                POST: Depending on the default or not default input, keyword iterate over rmods and perform RDC snapshot for all RDC snapshot
    ...                      capable rmods (default) or only on rmods on which fid defined in {RDC_FID_LIST} variable defined in
    ...                      common_variables.robot is visible (not default, require calling keyword with arguments).
    [Arguments]    ${fid_trig_snapshot}=${FALSE}    ${rmod_with_fid_list}=${EMPTY}
    IF    ${fid_trig_snapshot}
        ${rmod_with_fid_dict}=    Create Dictionary
        FOR    ${rmod}    IN    @{RDC_RMODS.keys()}
            IF    '${rmod}' in @{rmod_with_fid_list}
                Set To Dictionary    ${rmod_with_fid_dict}    ${rmod}    ${RDC_RMODS}[${rmod}]
            END
        END
        RDC Trigger Snapshot If Possible    rmod_dict=${rmod_with_fid_dict}
    ELSE
        RDC Trigger Snapshot If Possible    rmod_dict=${RDC_RMODS}
    END

RDC Trigger Snapshot If Possible
    [Documentation]    Keyword iterate over RDC Snapshot capable RUs and if requirements for RDC snapshot are meet
    ...                call RDC Enable Ssh Trigger Snapshot keyword to enable eth ssh connection and collect RU snapshot via LMI ssh.
    ...                PRE: Keyword requires correctly filled rmod_dict dictionary (if all required fields are filled, key snapshot_capable will
    ...                     have value ${TRUE}).
    ...                POST: Keyword will call RDC Enable Ssh Trigger Snapshot keyword or print warning if requirements for snapshot were not meet.
    [Arguments]    ${rmod_dict}
    FOR    ${rmod}    ${properties}    IN    &{rmod_dict}
        Log To Console     \n
        IF    'com_aliases' not in @{properties.keys()}
            Log    \t> > > RDC Trigger Snapshot If Possible: com_aliases don't exist in ${rmod} RDC data structure. < < <    WARN
        ELSE
            IF    'snapshot_capable' not in @{properties.keys()}
                Log    \t> > > RDC Trigger Snapshot If Possible: Couldn't determine if RDC snapshot for ${rmod} is possible. < < <    WARN
            ELSE
                ${snapshot_capable}=    Get From Dictionary     ${properties}    snapshot_capable
                IF    ${snapshot_capable}
                    ${com_aliases_list}=    Get From Dictionary     ${properties}    com_aliases
                    TRY
                        Wait Until Keyword Succeeds    1min  20s    RDC Enable Ssh Trigger Snapshot
                        ...    rmod_master_alias=${com_aliases_list[0]}    properties=${properties}
                    EXCEPT    AS    ${error}
                        Log    \t> > > RDC Enable Ssh Trigger Snapshot: Unable to get Snapshot for ${rmod} because of error: ${error}. < < <
                        ...    WARN
                    END
                ELSE
                    Log    \t> > > RDC Trigger Snapshot If Possible:Setup of RU: ${rmod} do not allow to get RDC RU snapshot. < < <    WARN
                END
            END
        END
    END

RDC Enable Ssh Trigger Snapshot
    [Documentation]    Keyword send command to enable LMI ssh connection, trigger snapshot on RU and call Collect Latest RDC Snapshot keyword that
    ...                copy snapshot from RU to VM via ssh.
    ...                PRE: Keyword as argument requires alias from COM connected to the RU master node (in __init__.py COM connection connected
    ...                     to the master node serial interface has to be defined as first) and correctly filled RU properties dictionary.
    ...                POST: Keyword will call Collect Latest RDC Snapshot keyword that will copy RDC snapshot from RU to VM via LMI ssh interface or
    ...                      print warning message in case of error.
    [Arguments]    ${rmod_master_alias}    ${properties}
    Log To Console     \t\t- - - RDC snapshot triggering on ${rmod_master_alias} [...]. - - -
    RDC.Send Command     cmd=sudo lmi-eth on    alias=${rmod_master_alias}
    ${snapshot_taken}     RDC.Take Snapshot     alias=${rmod_master_alias}    skip_downloading=${TRUE}
    IF    ${snapshot_taken}
        ${path_on_rmod}=    RDC.Get Rmod Snapshot Path    alias=${rmod_master_alias}
        IF    '${path_on_rmod}' !='None'
            Collect Latest RDC Snapshot    path_on_rmod=${path_on_rmod}    ru_param=${properties}
        ELSE
            Log    \t> > > RDC Enable Ssh Trigger Snapshot: Snapshot for ${rmod} was not correctly stored on RU.  < < <    WARN
        END
    ELSE
        Log    \t> > > RDC Enable Ssh Trigger Snapshot:Snapshot for ${rmod} was not correctly created on RU. < < <    WARN
    END

RDC Server Off
    [Documentation]    Keyword is closing Com connections and downloading logs to the VM. Finally RDC server running on host is shutdown.
    ...                PRE:    Keyword requires filled RDC_RMODS dictionary that contains com_aliases used to close com connections.
    ...                POST:    Keyword is downloading Com logs for each alias and close its Com connection.
    Log To Console    \n\t\t- - - RDC server connections teardown [...]. - - -
    [Arguments]      ${rmods}
    IF    isinstance(${rmods},dict)
        FOR    ${rmod}    ${parameters}    IN    &{rmods}
            IF    'com_aliases' not in @{parameters.keys()}
                Log    \t> > > RDC aliases not defined in RDC_RMODS dictionary for: ${rmod}. < < <    WARN
                CONTINUE
            ELSE
                @{com_aliases}=    Get From Dictionary    ${parameters}    com_aliases
                FOR    ${alias}    IN    @{com_aliases}
                    TRY
                        RDC.Disconnect    alias=${alias}
                    EXCEPT    AS    ${error}
                        Log    \t> > > RDC Server Off: Problem with releasing com port connected to the RU S/N:${alias}/${rmod} error: ${error} < < <
                        ...    WARN
                    END
                END
            END
        END
        TRY
            RDC.Disconnect All Rmods And Shutdown
        EXCEPT    AS    ${error}
            Log    \t> > > RDC Server Off: Problem with shutdown of RDC server on host because of error: ${error} < < <
            ...    WARN
        END
        Log To Console    \t\t- - - RDC server connections teardown [DONE]. - - -
    ELSE
        Log    \t> > >   RDC Server Off: Passed argument has to be a dict. < < <    WARN
    END

Collect Latest RDC Snapshot
    [Documentation]    Keyword is downloading RU snapshot to the VM via LMI ssh connection.
    ...                PRE: Keyword requires snapshot path on RMOD and ru_param structure containing informations required to download RU Snapshot.
    ...                POST: Keyword download RU Snapshot from RU to the VM. If not possible warning message will be displayed.
    [Arguments]    ${path_on_rmod}    ${ru_param}
    ${lmi_host_ip}          Get From Dictionary    ${ru_param}    lmi_host_ip
    ${lmi_host_username}    Get From Dictionary    ${ru_param}    lmi_host_username
    ${lmi_host_password}    Get From Dictionary    ${ru_param}    lmi_host_password
    ${lmi_ssh_ip}           Get From Dictionary    ${ru_param}    lmi_ssh_ip
    ${lmi_ssh_username}     Get From Dictionary    ${ru_param}    lmi_ssh_username
    ${lmi_ssh_pass}         Get From Dictionary    ${ru_param}    lmi_ssh_pass
    ${com_aliases_list}=    Get From Dictionary    ${ru_param}    com_aliases
    TRY
        Wait Until Keyword Succeeds    6x  1 sec
        ...    ssh.Connect To
        ...    hostname=${lmi_host_ip}
        ...    username=${lmi_host_username}
        ...    password=${lmi_host_password}
        ...    alias=test_pc
        ...    allow_agent=False
        ...    look_for_keys=False
        ...    timeout=30 sec
        Wait Until Keyword Succeeds    6x  1 sec
        ...    ssh.Connect To
        ...    hostname=${lmi_ssh_ip}
        ...    username=${lmi_ssh_username}
        ...    password=${lmi_ssh_pass}
        ...    proxy=test_pc
        ...    alias=ru_logs
        ...    allow_agent=False
        ...    look_for_keys=False
        ...    timeout=30 sec
        Log To Console    \t\t- - - Snapshot Download [...] - - -
        ${rdc_snap_filename}    Replace String Using Regexp    ${path_on_rmod}    .*/    ${EMPTY}
        ${remote_path}     Set Variable    ${path_on_rmod}
        ${local_path}=     Set Variable    ${RDC_LOGS}/${tl.tl_cloud_topology}_${rdc_snap_filename}
        ${download_result}    ssh.Download File
        ...    remote_path=${remote_path}
        ...    local_path=${local_path}
        ...    connection=ru_logs
    EXCEPT    AS    ${error}
        Log    \t> > > Collect Latest RDC Snapshot: Failed to collect RU Snapshot because of error: ${error} < < <    WARN
    ELSE
            Log To Console    \t\t- - - Snapshot Download [DONE] - - -
    END
    [Teardown]    Run Keyword And Ignore Error    Run Keywords    ssh.disconnect      connection=ru_logs
    ...                                                    AND    ssh.disconnect      connection=test_pc

Start Collecting Logs From Moxa
    ${set_log_flag}    Catenate    uboot_env set console_uart=1 ; uboot_env set loglevel=9
    ${connection}     Run Keyword And Return Status    ssh.Connect To
    ...               hostname=192.168.255.129
    ...               username=toor4nsn
    ...               password=oZPS0POrRieRtu
    ...               alias=gnb
    Run Keyword If    ${connection}   Run Keywords
    ...               ssh.Execute    ${set_log_flag}    connection=gnb    timeout=60s
    ...               AND    ssh.Execute    uboot_env get    connection=gnb    timeout=60s
    ...               ELSE    PASS EXECUTION
    ...               msg=${\n}Connection failed, needed flags on board has not been set for collecting logs from MOXA!${\n}    WARN
    ${process}        Catenate    telnet ${moxa_ip_addr} ${moxa_port} | ts "%Y-%m-%d %H:%M:%S"
    process.Start Process    ${process}    shell=True    cwd=${OUTPUT_DIR}/Additional_Execution_Logs/    stdout=moxa.log    alias=moxa
    [Teardown]        Run Keyword if    ${connection}    ssh.disconnect    connection=gnb

Stop Collecting Logs From Moxa
    ${set_log_flag}    Catenate    uboot_env set console_uart=-1 ; uboot_env set loglevel=4
    ${connection}     Run Keyword And Return Status    ssh.Connect To
    ...               hostname=192.168.255.129
    ...               username=toor4nsn
    ...               password=oZPS0POrRieRtu
    ...               alias=gnb
    Run Keyword If    ${connection}   Run Keywords
    ...               ssh.Execute    ${set_log_flag}    connection=gnb    timeout=60s
    ...               AND    ssh.Execute    uboot_env get    connection=gnb    timeout=60s
    ...               ELSE    PASS EXECUTION
    ...               msg=${\n}Connection failed. console_uart and loglevel uboot_env variables have not been restored!${\n}   WARN
    process.Terminate Process    moxa
    [Teardown]        Run Keyword if    ${connection}    ssh.disconnect    connection=gnb

Collect enb log via OAM IP
    ${enb_oam}    Get Variable Value    ${tl.enbs[0].oam_ip}
    ${enb_lmp}    Get Variable Value    ${tl.enbs[0].system_module.common_units[0].lmp_connection.addr}
    ${enb_host}    Set Variable If    '${enb_oam}'=='None'    ${enb_lmp}    ${enb_oam}
    ${connection_status}    Run Keyword If    '192.168.255.' not in '${enb_host}'
    ...    Run Keyword and return status      Wait Until Keyword Succeeds    3x   30s   coam.connect_to
    ...    bts_host=${enb_host}
    ...    update_interval=1000
    ...    name=enb_admin
    Run Keyword If    '192.168.255.' not in '${enb_host}'
    ...    Save Snapshot For Classical   connection_status=${connection_status}    connection=enb_admin   sw_d=enb

############################ For Cloud Logging collection ################################
Cleanup coredump log in vDU
    [Documentation]  cleanup all postinstall and preinstall job once deployment failure
    ssh.Connect to   hostname=${DU_k8s_addr}   username=${DU_k8s_user}    password=${DU_k8s_pwd}  alias=RM_alias
    ssh.execute    command=sudo rm -rf /var/lib/systemd/coredump/core.* /tmp/coredump-logs.txt /tmp/cdump.tgz
    ...            connection=RM_alias    timeout=60s

Get Healingctl Log
    [Documentation]  this keyword is used to get healing-controller log
    ...   author: tong weichao
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=heal_alias
    ${heal}    ssh.execute
    ...    command=kubectl get pods -n ${${par_prefix}_tenant} | grep 'healing' |awk '{printf $1}'    connection=heal_alias    timeout=10s
    Log    healing-controller name is: ${heal}
    ssh.execute
    ...    command=kubectl logs ${heal} -n ${${par_prefix}_tenant} > healing_${timestamp}.log    connection=heal_alias    timeout=10s
    ssh.download file
    ...  remote_path=/var/home/core/healing_${timestamp}.log
    ...  local_path=${LOG_PATH}/${par_prefix}_healing_${timestamp}.log
    ...  connection=heal_alias
    ssh.execute
    ...    command=rm -rf healing_${timestamp}.log    connection=heal_alias    timeout=10s
    ssh.Disconnect    connection=heal_alias

Get postinstall Log
    [Documentation]  this keyword is used to get post-install log
    ...   author: tong weichao
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=post_alias
    ${postinstall}    ssh.execute
    ...    command=kubectl get pods -n ${${par_prefix}_tenant} | grep 'postinstall' |awk '{printf $1}'    connection=post_alias    timeout=10s
    ${length}    Get Length    ${postinstall}
    Run Keyword If   ${length} != 0
    ...  Run keywords    Log    post-install pod name is: ${postinstall}    AND
    ...  ssh.execute
    ...  command=kubectl logs ${postinstall} -n ${${par_prefix}_tenant} > post-install_${timestamp}.log    connection=post_alias    timeout=10s    AND
    ...  ssh.download file
    ...  remote_path=/var/home/core/post-install_${timestamp}.log
    ...  local_path=${LOG_PATH}/${par_prefix}_post-install_${timestamp}.log
    ...  connection=post_alias    AND
    ...  ssh.execute
    ...  command=rm -rf post-install_${timestamp}.log    connection=post_alias    timeout=10s
    ssh.Disconnect    connection=post_alias

Start l2rt dptrace
    [Documentation]  this keyword is used to l2rt dptrace
    ...   author: Wan Yan
    ssh.Connect to    hostname=${DU_k8s_addr}   username=${DU_k8s_user}
    ...    password=${DU_k8s_pwd}  alias=dpt_alias
    Log    --> start to l2rt dptrace
    ssh.send_command
    ...    command=kubectl exec -it po-cran1-up-0 -c ctr-cran1-l2rt dptrace-cli trace enable -n cran1
    ...    connection=dpt_alias
    Set Suite variable    ${dptrace_started}    True

Stop l2rt dptrace
    [Documentation]  this keyword is used to l2rt dptrace
    ...   author: Wan Yan
    ssh.Connect to    hostname=${DU_k8s_addr}   username=${DU_k8s_user}
    ...    password=${DU_k8s_pwd}  alias=dpt_alias
    @{cmd_list}  Create List  sudo rm /tmp/dptrace-data
    ...  kubectl exec -it po-cran1-up-0 -c ctr-cran1-l2rt dptrace-cli trace disable -n cran1
    ...  kubectl cp -n cran1 po-cran1-up-0:var/run/dptrace/dptrace-data -c ctr-cran1-l2rt /tmp/dptrace-data
    ...  kubectl exec -it po-cran1-up-0 -c ctr-cran1-l2rt rm var/run/dptrace/dptrace-data -n cran1
    ...  kubectl exec -it po-cran1-up-0 -c ctr-cran1-l2rt rm var/run/dptrace/dptrace-data-raw-1 -n cran1
    ...  kubectl exec -it po-cran1-up-0 -c ctr-cran1-l2rt rm var/run/dptrace/dptrace-data-raw-2 -n cran1
    Log    --> stop to l2rt dptrace
    FOR  ${cmd}  IN   @{cmd_list}
        ssh.send_command  command=${cmd}  connection=dpt_alias
        BuiltIn.Sleep   2s
    END
    ssh.download file
    ...  remote_path=/tmp/dptrace-data
    ...  local_path=${LOG_PATH}/l2rtdptrace-data_${timestamp}
    ...  connection=dpt_alias
    Log    --> get l2rt dptrace done
    ssh.Disconnect    connection=dpt_alias

Get ocp logservice
    [Documentation]  this keyword is used to capture ocp logservice log then download to LOG_PATH
    ...   author: tong weichao
    [Arguments]    ${cloud_syslog_path}
    IF    $cloud_syslog_path is not None
        Log to console    --> Collecting ${par_prefix} syslog [SKIPPED]
        RETURN
    END
    Log to console    --> Collecting ${par_prefix} syslog [...]
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=RM_alias
    ssh.upload file    local_path=${CURDIR}/../scripts/logservice_InOCP.sh
    ...    remote_path=/tmp/${tl.tl_cloud_topology}/logservice_InOCP.sh
    ...    connection=RM_alias
    ssh.execute  command=chmod +x /tmp/${tl.tl_cloud_topology}/logservice_InOCP.sh  connection=RM_alias    timeout=60s
    ${res}=    ssh.execute
    ...  command=. /tmp/${tl.tl_cloud_topology}/logservice_InOCP.sh ${${par_prefix}_tenant}
    ...  connection=RM_alias
    ...  timeout=180s
    @{res_list}=    Split To Lines    ${res}
    Run Keyword if     'successfully' in '${res_list}[-1]'    Run Keywords
    ...    ssh.download file    remote_path=/var/home/core/logservice/${${par_prefix}_tenant}/syslog.zip
    ...    local_path=${LOG_PATH}/${sw_version}_${tl.tl_cloud_topology}_${par_prefix}_syslog_${timestamp}.zip
    ...    connection=RM_alias
    ...    AND    Log to console    --> Collecting ${par_prefix} syslog [DONE]
    ...    ELSE   Log to console    --> Collecting ${par_prefix} syslog [FAILED]


Start vDU Tcpdump Collection
    ${timestamp}    robot.libraries.DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    ssh.Connect to    hostname=${DU_k8s_addr}    username=${DU_k8s_user}
    ...    password=${DU_k8s_pwd}    alias=tcpdump_alias
    ${tcpdump_interfaces} =    Evaluate    '${tcp_dump_interfaces}'.split(',')
    ${tcpdump_started} =    Start vDU Tcpdumps    alias=tcpdump_alias    file_name=tcpdumps_${timestamp}.pcap    interface=${tcpdump_interfaces}
        Run Keyword If    ${tcpdump_started} == False    Run Keywords
        ...    Log to console     \t [ FAILED ] ----> Tcpdump start issue or wrong interface name for tcpdump collection!
        ...    AND    ssh.Disconnect    connection=tcpdump_alias
        ...    AND    Fail


Stop vDU Tcpdump Collection
    ssh.Connect to    hostname=${DU_k8s_addr}    username=${DU_k8s_user}
    ...    password=${DU_k8s_pwd}    alias=tcpdump_alias
    Stop vDU Tcpdumps    alias=tcpdump_alias
    ssh.Download File
    ...  remote_path=/tmp/tcpdumps.tgz
    ...  local_path=${LOG_PATH}/tcpdumps_${timestamp}.tgz
    ...  connection=tcpdump_alias
    ssh.Execute    command=sudo rm -rf /tmp/tcpdumps.tgz /tmp/tcpdumps    connection=tcpdump_alias
    Log to console    --> Collecting tcpdumps [DONE]
    [Teardown]    ssh.Disconnect    connection=tcpdump_alias