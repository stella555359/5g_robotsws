*** Settings ***
Documentation     This file contains common keywords to collect various logs for Airphone Testcase

Library      taf.collectors.tcpdump         WITH NAME    tcpdump
Library      taf.collectors.core            WITH NAME    core
Library      taf.converters.pcaptopdml      WITH NAME    pcaptopdml
Library      taf.collectors.tshark          WITH NAME    tshark
Library      taf.collectors.l2stream3       WITH NAME    ttistream
Library      taf.collectors.btslog          WITH NAME    btslog
Library      taf.sbts.oam.coam.admin        WITH NAME    CoamAdmin
Library      taf.transport.ssh              WITH NAME    ssh
Library      taf.sw.dcap.rd                 WITH NAME    rd

Library      String
Library      OperatingSystem
Library      DateTime
Library      Telnet
Library      Collections
Library      ../Python/LogStore.py          WITH NAME   log_store
Library      ../Python/BackgroundTask.py    WITH NAME   background_copy
Resource     ../Variables/Common_Variables.robot
Library      ../Python/SaveScreenshot.py    SaveScreenshot    WITH NAME    screenshot
Resource     swconfig_keywords.robot


*** Variables ***
${pcap_path}                        /home/ute/
${log_path}                         /home/ute/
${bip_vm_log_path}                  /tmp/pcapsosReport/
${collector_name}                   oamTcpdump
${gnb_asik_slave_collector_name}    slave_tcpdump
${is_pcap_collected}                False
${scriptPath}                       /ffs/run/config/scripts
${gnbMirroring_abio}                ABIO_mirror.sh
${APMirroring}                      apMirroring.sh
${APMirroring_config}               apMirroringConfig.sh
${gulp}                             gulp
${gnbMirroring_abio_dir}            ${CURDIR}/../../../QT/resources
${APMirroring_dir}                  ${CURDIR}/../../scripts/shell_scripts/AP_Mirror_Scripts
${pcap_collection_script}           ${CURDIR}/../../scripts/shell_scripts/pcap_collection.sh
${sosReportLogDir}                  /tmp/sosreport
${wget_link}    https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/

&{AP_ASIK}           Ip=192.168.200.1    Username=toor4nsn    Password=oZPS0POrRieRtu    Connection=ApAsik
&{GNB_ASIK}          Ip=192.168.255.129    Username=toor4nsn   Password=oZPS0POrRieRtu    Connection=GnbAsik
&{GNB_ASIK_Slave}    Ip=192.168.253.17    Username=toor4nsn   Password=oZPS0POrRieRtu    Connection=GnbAsikSlave

@{gnb_custom_profile}           controlPlane5g    pmFiles5g   SCF5g    L2Ps_Component
...                             L2Lo_Component    L2HiRlc_Component    L2HiPdcp_Component
...                             L1stream    Tracer_5g
@{phy_cell_id}                      50    51
${dcap_logs_started}                False
${btslog_started}                   False
${tti_trace_started}                False
${bip_logs_started}                 False
${wts_tcpdump_started}              False
${top_capture_started}              False
${ap_tti_started}                   False


${Start_sos_ASIL}      sosReport_ASIL/startTest_ASIL.sh
${Stop_sos_ASIL}       sosReport_ASIL/stopTest_ASIL.sh
${stop_asil_script}     stopTest_ASIL.sh
${uteEpcDir}                 /opt/wts/latest
${sosReport_ASIL_path}      /opt/wts/latest/sosReport_ASIL
${sosReportCfg}          sosReport.cfg
${wts_vm_top_results}   wts_vm_top_results.txt

*** Keywords ***
Start pcap collection in gNB CU
    [Arguments]    ${name}=oamTcpdump    ${options}=-f sctp -i any -s0    ${gnb_id}=0
    ${executor_oam_vm}=  Create Dictionary
    ...  host=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...  user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...  password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    tcpdump.create_tcpdump_collector
    ...     name=${name}
    ...     options=${options}
    ...     executor=${executor_oam_vm}
    core.setup_collectors    names=${name}
    core.start_collectors    names=${name}
    tcpdump.set_test_alias    ${name}
    log_store.set_is_gnb_pcap_collected    False

Create Suite Log Collection Folder
    [Arguments]    ${feature_folder}   ${log_path}=${OUTPUT_DIR}
    log_store.Create Suite Log Folder   ${log_path}   ${feature_folder}

Create Test Case Folder
    ${test_case_path}    Replace String    ${TEST_NAME}    ${SPACE}    _
    ${test_case_path}    Remove String    ${test_case_path}    [1]
    log_store.Create Test Case Folder   ${test_case_path}

Collect gNB snapshot via Aashell
    [Arguments]    ${log_dir}=${OUTPUT DIR}
    telnet.Open Connection  host=${GNB_ASIK.Ip}   port=15007
    telnet.Set Prompt       AaShell>
    telnet.Set Timeout      300 seconds
    telnet.Write            log -c full -a -z snapshot_gnb.zip
    telnet.Read Until       AaSysComUserDeregister succeed!
    telnet.Close Connection
    ${snapshot_gnb}=        Catenate
    ...                     sshpass -p ${GNB_ASIK.Password} scp ${GNB_ASIK.Username}@${GNB_ASIK.Ip}:/tmp/snapshot_gnb.zip
    ...                     ${log_dir}/Aashell_snapshot_gnb.zip
    Run                     command=${snapshot_gnb}

Collect AP snapshot via Aashell
    [Arguments]    ${log_dir}=${OUTPUT DIR}
    telnet.Open Connection  host=${AP_ASIK.Ip}   port=15007
    telnet.Set Prompt       AaShell>
    telnet.Set Timeout      300 seconds
    telnet.Write            log -c full -a -z snapshot_ap.zip
    telnet.Read Until       AaSysComUserDeregister succeed!
    telnet.Close Connection
    ${snapshot_ap}=         Catenate
    ...                     sshpass -p ${AP_ASIK.Password} scp ${AP_ASIK.Username}@${AP_ASIK.Ip}:/tmp/snapshot_ap.zip
    ...                     ${log_dir}/Aashell_snapshot_ap.zip
    Run                     command=${snapshot_ap}

Collect AP and gNB snapshot
    [Arguments]    ${log_dir}=${OUTPUT DIR}
    Collect gNB snapshot via Aashell    log_dir=${log_dir}
    Collect AP snapshot via Aashell    log_dir=${log_dir}

Convert PCAP file to PDML
    [Arguments]    ${file_path_pattern}    ${convertname}=converter    ${lua_shark_file}=${None}
    ...            ${command_template}=${None}
    pcaptopdml.create_pcap_to_pdml_converter    name=${convertname}   file_path_pattern=${file_path_pattern}
    ...                                         luashark_path=${lua_shark_file}   command_template=${command_template}
    pcaptopdml.convert    ${convertname}
    ${pdml_file}    Replace String    ${file_path_pattern}    .pcap    .pdml
    log_store.set_gnb_pdml   ${pdml_file}
    [Return]   ${pdml_file}

Stop pcap and convert to pdml
    Stop pcap collection in gNB
    ${gnb_pcap_file}=   log_store.get_gnb_pcap
    ${pdml_file}=   Convert PCAP file to PDML    file_path_pattern=${gnb_pcap_file}
    [Return]   ${pdml_file}

Start pcap collection in gNB
    [Arguments]    ${options}=-i any -s0 not udp
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tcpdump_collector}=   Catenate   SEPARATOR=_   gNB   ${timestamp}
    log_store.Create GNB PCAP File   ${tcpdump_collector}
    Start pcap collection in gNB CU    name=${tcpdump_collector}    options=${options}

Stop pcap collection in gNB
    ${tcpdump_collector}=   log_store.get_gnb_collector
    ${test_log_path}    log_store.get_test_log_folder
    core.stop_collectors    names=${tcpdump_collector}
    core.collect_collectors    names=${tcpdump_collector}    target_dir=${test_log_path}
    log_store.set_is_gnb_pcap_collected    True
    core.teardown_collectors    names=${tcpdump_collector}
    ${gnb_pcap_file}    log_store.get_gnb_pcap
    [Return]    ${gnb_pcap_file}

Start pcap collection in WTS
    [Arguments]    ${name}=wts    ${interface}=${WTS_PCAP_INTERFACE}
    ${wts_pcap_filename}    Catenate   SEPARATOR=_    ${name}    ${interface}
    log_store.set_wts_pcap    ${wts_pcap_filename}
    tcpdump.create_tcpdump_collector    name=${wts_pcap_filename}    options=-i ${interface} not udp
    tcpdump.set_test_alias              ${wts_pcap_filename}
    core.setup_collectors               names=${wts_pcap_filename}
    core.start_collectors               names=${wts_pcap_filename}
    log_store.set_is_wts_pcap_collected    False

Stop pcap collection in WTS
    ${wts_pcap_filename}    log_store.get_wts_pcap
    ${test_log_path}    log_store.get_test_log_folder
    core.stop_collectors    names=${wts_pcap_filename}
    core.collect_collectors    names=${wts_pcap_filename}    target_dir=${test_log_path}
    core.teardown_collectors    names=${wts_pcap_filename}
    log_store.set_is_wts_pcap_collected    True

Start pcap collection in gNB and WTS
    [Arguments]    ${options}=-f sctp -i any -s0
    run keyword if    '${WTS_PCAP_NEEDED}' == 'True'    Start pcap collection in WTS
    run keyword if    '${GNB_PCAP_NEEDED}' == 'True'    Start pcap collection in gNB    ${options}

Stop pcap collection in gNB and WTS
    ${gnb_pcap_collected}    log_store.get_is_gnb_pcap_collected
    ${wts_pcap_collected}    log_store.get_is_wts_pcap_collected
    run keyword if    "${wts_pcap_collected}" == "False" and '${WTS_PCAP_NEEDED}' == 'True'    Stop pcap collection in WTS
    run keyword if    "${gnb_pcap_collected}" == "False" and '${GNB_PCAP_NEEDED}' == 'True'    Stop pcap collection in gNB

Start tcpdump on gnb ASIK slave
    [Arguments]      ${name}=${gnb_asik_slave_collector_name}    ${options}= -i any     ${gnb_id}=0    ${vm_name}=${GNB_ASIK_Slave.Ip}
    [Documentation]    create journal log collection on specified VM's
    ...                gnb_id: gnb_id default value:0
    ...                name: name of the collector. Ex: cpif_tcpdump
    ...                options: (optional) tcpdump options (except for “-w”), default: empty string
    ...                vm_name: vm host name
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tcpdump_collector}=   Catenate   SEPARATOR=_   gNB   ${timestamp}
    &{oam_config}=   create dictionary     host=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...                                    user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...                                    password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    &{vm_config}=    create dictionary     host=${vm_name}
    ...                                    user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...                                    password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    ...                                    proxy=${oam_config}
    tcpdump.create_tcpdump_collector       name=${name}   options=${options}   executor=${vm_config}
    tcpdump.set_test_alias                 ${name}
    core.setup_collectors                  names=${name}
    core.start_collectors                  names=${name}

Stop pcap collection in gNB ASIK slave
    [Arguments]    ${name}=${gnb_asik_slave_collector_name}
    ${pcap_path}    log_store.get_test_log_folder
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}    target_dir=${pcap_path}
    core.teardown_collectors    names=${name}
    ${pcap_file}    Join Path    ${pcap_path}    ${gnb_asik_slave_collector_name}
    ...    ${gnb_asik_slave_collector_name}.pcap
    [Return]    ${pcap_file}

Download Luashark For GNB And Return Path
    [Arguments]    ${path}=${OUTPUT DIR}
    ${gnb_build}    Get GNB Version String
    Download luashark from Artifactory    ${gnb_build}
    ${luashark_path}    Extract Luashark    ${gnb_build}    ${path}
    [Return]    ${luashark_path}

Download luashark from Artifactory
    [Arguments]   ${gnb_build}
    ${wget_command}    Catenate     SEPARATOR=    wget    ${SPACE}    ${wget_link}    ${gnb_build}
    ...     /luashark-    ${gnb_build}    .zip
    Run And Expect Command To Pass    command=${wget_command}   msg=Download of Luashark from Artifactory for ${gnb_build}

Extract Luashark
    [Arguments]   ${gnb_build}    ${path_to_extract}
    ${unzip_luashark_command}    Catenate    SEPARATOR=    unzip luashark-    ${gnb_build}    .zip -d ${path_to_extract}
    Run And Expect Command To Pass    command=${unzip_luashark_command}   msg=Extract of Luashark Zip for ${gnb_build}
    ${luashark_path}    Catenate    SEPARATOR=    ${path_to_extract}    /generated_luashark/luashark.lua
    [Return]    ${luashark_path}

Remove luashark
    [Arguments]    ${lua_shark_path}
    Run    rm -rf ${lua_shark_path}

Convert X2AP Packets in PCAP to PDML
    [Arguments]   ${file_path_pattern}   ${converter}=converter   ${lua_shark_file}=None
    ${pdml_file}=   Convert PCAP File To PDML   ${file_path_pattern}   ${converter}   ${lua_shark_file}
    ...   command_template={tshark_path} -Y "x2ap" -r {input_file} -X lua_script:{luashark_path} -T pdml > {output_file}
    [Return]   ${pdml_file}

Stop pcap and convert X2AP to pdml
    Stop pcap collection in gNB
    ${gnb_pcap_file}=   log_store.get_gnb_pcap
    ${pdml_file}=   Convert X2AP Packets in PCAP to PDML   file_path_pattern=${gnb_pcap_file}
    [Return]   ${pdml_file}

Collect SoSReport Log
    [Documentation]    This keyword is used to capture the SoSReport log which has logs from AP, gNB and WTS
    ...                with AP and gNB snapshots. This is collected in the Suite Log Folder
    ...                 Modified Date: 04-Jul-2022
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    [Arguments]    ${collect_sosreport_at_suite}=True
    Return From Keyword If    '${SOSREPORT_NEEDED}' == 'False'
    Disable Delete of Pcap Folder on Sosreport Script
    ${options}    Set Variable    -asikDIR=${sosReportLogDir}
    ${sosreport_output}    Run And Expect Command To Pass    command=cd ${WTS_INSTALL_PATH} && ./sosReport_ASIK_ASIL.sh -c -s -d -e -split ${options}
    ...    msg=Script sosReport_ASIK_ASIL.sh
    ${sosreport_output_str}    Convert To String    ${sosreport_output}
    ${sosreport_file_name}    Get SoSReport Log Filename    ${sosreport_output_str}
    ${log_path}    Run Keyword If    '${collect_sosreport_at_suite}' == 'True'    log_store.get_suite_log_folder
    ...    ELSE    log_store.get_test_log_folder
    Run Keyword And Continue on Failure    Run And Expect Command To Pass    command=cp ${WTS_INSTALL_PATH}/${sosreport_file_name} ${log_path}
    ...    msg=File copy
    File Should Exist    ${log_path}/${sosreport_file_name}
    Run Keyword And Continue on Failure    Run And Expect Command To Pass    command=rm ${WTS_INSTALL_PATH}/${sosreport_file_name}
    ...    msg=Delete failed

Run And Expect Command To Pass
    [Arguments]    ${command}    ${msg}=
    [Documentation]    This keyword is used to run a command and get its output.
    ...                Keyword will fail if the returncode is other than zero(0)
    ...                 Modified Date: 02-Jun-2020
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    ${rc}    ${output}    Run and return rc and output    ${command}
    Should Be Equal As Integers   ${rc}    0    msg=${msg} failed execution with error code ${rc} ${output}   values=False
    [Return]    ${output}

Get SoSReport Log Filename
    [Arguments]    ${output}
    [Documentation]    This keyword is used to get the SoSReport log filename from the script output
    ...                 Modified Date: 04-Jul-2022
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    ${file_name}    Get Regexp Matches    ${output}    (SosReport.*complete_(UEAPP|iphy1).tgz)   1
    ${file_name}    Get From List    ${file_name}    0
    [Return]    ${file_name}

Check pcap files in gNB
    ssh.Connect To        ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    ssh.Execute           pwd     ${GNB_ASIK}[Connection]
    ssh.Execute           ls -ltr *pcap*     ${GNB_ASIK}[Connection]
    ssh.Execute           ps -aef | grep -i tcpdump     ${GNB_ASIK}[Connection]
    ssh.Execute           ls -ltr *pcap*     ${GNB_ASIK}[Connection]
    [Teardown]    ssh.Disconnect        ${GNB_ASIK.Connection}

Start L1L2bipLogs
    [Arguments]    ${PCAP_PREFIX}
    Start AP L1L2bipLogs     ${PCAP_PREFIX}
    Start gNB L1L2biplogs    ${PCAP_PREFIX}
    Run Keyword And Ignore Error    Check pcap files in gNB
    Run Keyword And Ignore Error    Start Periodic BIP pcap collection from gNB and AP to VM

Stop L1L2bipLogs
    Run Keyword And Ignore Error    Check pcap files in gNB
    Run Keyword And Ignore Error    Stop Periodic BIP pcap collection from gNB and AP to VM

Copy and Trigger Mirroring Script
    [Arguments]    ${topology}
    ssh.Connect To        ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    ssh.Execute           mkdir -p ${scriptPath}    ${GNB_ASIK}[Connection]
    ${command}            Catenate    scp ${gnbMirroring_abio_dir}/${gnbMirroring_abio}
    ...                   ${GNB_ASIK.Username}@${GNB_ASIK.Ip}:${scriptPath}
    Run                   ${command}
    ssh.Execute           ls -lrt ${scriptPath}    ${GNB_ASIK}[Connection]
    ssh.Execute           chmod 777 ${scriptPath}/${gnbMirroring_abio}    ${GNB_ASIK}[Connection]
    ssh.Send Command      sh ${scriptPath}/${gnbMirroring_abio} ${topology}    connection=${GNB_ASIK}[Connection]
    sleep                 10s
    ssh.Disconnect        ${GNB_ASIK.Connection}

Start gNB L1L2biplogs
    [Arguments]    ${PCAP_PREFIX}
    SSH.Connect To        127.0.0.1    ute    ute    alias=sosReportConnection
    ${result}             SSH.Execute    sh ${pcap_collection_script} ${PCAP_PREFIX}    sosReportConnection
    Log to Console        ${result}
    ssh.Disconnect        sosReportConnection
    ssh.Connect To        ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    sleep                 5s
    ssh.Execute           pwd     ${GNB_ASIK}[Connection]
    ssh.Execute           ls -lrt *pcap*     ${GNB_ASIK}[Connection]
    [Teardown]     Run Keyword And Ignore Error    Run Keywords    ssh.Disconnect        ${GNB_ASIK.Connection}    AND
    ...    ssh.Disconnect        sosReportConnection

Move gNB L1l2bipLogs
    ssh.Connect To        ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    ssh.Execute           ps -eaf|grep tcpdump    ${GNB_ASIK}[Connection]
    ssh.Execute           pkill -2 tcpdump    ${GNB_ASIK}[Connection]
    ssh.Execute           mkdir -p ${sosReportLogDir}    ${GNB_ASIK}[Connection]
    ssh.Execute           mv -v /tmp/*.pcap*.* ${sosReportLogDir}    ${GNB_ASIK}[Connection]
    ssh.Execute           ls -lh ${sosReportLogDir}    ${GNB_ASIK}[Connection]
    ssh.Disconnect        ${GNB_ASIK.Connection}

Start AP L1L2bipLogs
    [Arguments]    ${PCAP_PREFIX}
    ssh.Connect To        ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    ssh.Execute           mkdir -p ${scriptPath}    ${AP_ASIK}[Connection]
    ${command}            Catenate    scp ${APMirroring_dir}/${APMirroring} ${APMirroring_dir}/${APMirroring_config}
    ...                   ${AP_ASIK.Username}@${AP_ASIK.Ip}:${scriptPath}
    Run                   ${command}
    ssh.Execute           ls -lrt ${scriptPath}    ${AP_ASIK}[Connection]
    ssh.Execute           chmod 777 ${scriptPath}/${APMirroring} ${scriptPath}/${APMirroring_config}     ${AP_ASIK}[Connection]
    sleep                 2s
    ${command}            Set Variable    sh ${scriptPath}/${APMirroring} --pcap_prefix=${PCAP_PREFIX} & \n
    ssh.Send Command      ${command}   connection=${AP_ASIK}[Connection]
    sleep                 10s
    ssh.Read Output       150    connection=${AP_ASIK}[Connection]
    ssh.Disconnect        ${AP_ASIK.Connection}

Move AP L1l2bipLogs
    ssh.Connect To        ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    ssh.Execute           ps -eaf|grep tcpdump    ${AP_ASIK}[Connection]
    ssh.Execute           pkill -2 tcpdump    ${AP_ASIK}[Connection]
    ssh.Execute           mkdir -p ${sosReportLogDir}    ${AP_ASIK}[Connection]
    ssh.Execute           mv -v /tmp/*.pcap*.* ${sosReportLogDir}    ${AP_ASIK}[Connection]
    ssh.Execute           ls -lh ${sosReportLogDir}    ${AP_ASIK}[Connection]
    ssh.Disconnect        ${AP_ASIK.Connection}

Disable Delete of Pcap Folder on Sosreport Script
    [Documentation]    This will allow control for copying the files to the VM during execution.
    ...                 Modified Date: 04-Jul-2022
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    ${command}   Catenate    sed -i -z 's/logAndRun rm -rf \$reportPcapDir/#logAndRun rm -rf \$reportPcapDir/1'
    ...                      ${WTS_INSTALL_PATH}/sosReport.sh
    ${rc}    ${output}    Run and return rc and output    ${command}
    Run Keyword If   ${rc}>0    Log    Modification of Sosreport script failed   level=WARN

Start Periodic BIP pcap collection from gNB and AP to VM
    [Arguments]    ${vm_log_path}=${bip_vm_log_path}
    [Documentation]    This will do a periodic copy of BIP pcap to the given log path on the VM
    ...                 Modified Date: 04-Jul-2022
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    ${periodic_copy_thread_obj}    background_copy.Start Background Copy Of Logs   ${vm_log_path}
    [Return]    ${periodic_copy_thread_obj}

Stop Periodic BIP pcap collection from gNB and AP to VM
    [Documentation]    This will stop the periodic copy of BIP pcap to the given log path on the VM
    ...                 Modified Date: 04-Jul-2022
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    background_copy.Terminate Background Copy Of Logs

Start btslog
    [Arguments]    ${host_ip}=127.0.0.1    ${user}=ute    ${password}=ute
    Modify RAD params in AP and GNB for SYSLOG
    ${parameters}=    Create Dictionary    MaxTraceFileSize=20    MaxSysLogFileSize=100
    ${btslog_configuration}=    Create Dictionary    LOG_CONFIGURATION=${parameters}
    ${executor_test_vm}=  Create Dictionary
    ...  host=${host_ip}
    ...  user=${user}
    ...  password=${password}
    btslog.create_btslog_collector
    ...     name=btslog
    ...     executor=${executor_test_vm}
    ...    btslog_configuration=${btslog_configuration}
    btslog.setup_collectors    names=btslog
    btslog.start_collectors    names=btslog
    btslog.set_suite_alias     btslog
    set Test Variable       ${btslog_started}    ${True}

Stop btslog
    [Arguments]    ${target_dir}=${OUTPUT_DIR}
    return from keyword if    '${btslog_started}' == 'False'
    btslog.stop_collectors         names=btslog
    ${command_status}    ${count}    run keyword and ignore error    Run    grep "ERR/" /tmp/btslog2/SYSLOG_* | wc -l;
    ${status}=    Run Keyword If    '${TOPOLOGY}' == 'CLOUD_5G_I_MP_AP_LO'
    ...    Run Keyword And Return Status    Variable Should Exist    ${syslog_err_count}
    run keyword if    ${status}     Check if the syslog error prints is in expected range    ${count}
    btslog.collect_collectors      names=btslog   target_dir=${target_dir}
    set Test Variable       ${btslog_started}    ${False}
    run keyword and ignore error    Run    cd /tmp/btslog2 && rm -rf syslog*.tgz
    [Teardown]    Run Keyword And Ignore Error    btslog.teardown_collectors     names=btslog

Get Physical Cell IDs
    [Documentation]    Extract physical cell IDs from cell data and return as a comma-separated string
    CoamAdmin.Setup admin    name=phy
    ${cell_data}=             CoamAdmin.get_cells_info     connection=phy
    ${current_date}=            Get Current Date

    @{physical_cell_ids}=    Create List
    FOR    ${cell}    IN    @{cell_data}
        ${physical_cell_id}=    Get From Dictionary    ${cell}    physicalCellId
        Append To List    ${physical_cell_ids}    ${physical_cell_id}
    END
    ${physical_cell_ids_string}=    Evaluate    ','.join(map(str, $physical_cell_ids))
    Log    Physical Cell IDs: ${physical_cell_ids_string}
    [Return]    ${physical_cell_ids_string}
    [Teardown]    Run Keyword And Ignore Error    CoamAdmin.teardown_admin    connection=phy

Stop TTI Trace Collection
    [Arguments]    ${collector_name}=l2stream3    ${target_dir}=${OUTPUT_DIR}     ${TEST_STATUS}=${EMPTY}
    return from keyword if    '${tti_trace_started}' == 'False'
    Log To console    Stopping TTI traces collecting
    ttistream.Stop Collectors    names=${collector_name}
    IF    '${TEST_STATUS}' == 'FAIL' or '${COPY_PASS_LOGS}' == 'True'
        ttistream.Collect Collectors    names=${collector_name}    target_dir=${target_dir}
        RUN    sudo tar -czvf l2stream3.tgz -C ${target_dir} l2stream3
        RUN    mv ${EXECDIR}/l2stream3.tgz ${target_dir}/
    END
    RUN    sudo rm -rf ${target_dir}/l2stream3
    set Test Variable       ${tti_trace_started}    ${False}
    [Teardown]    Run Keyword And Ignore Error    ttistream.Teardown Collectors    names=${collector_name}

Start TTI Trace Log
    [Documentation]    This keyword will collect gNB TTI trace.
    ...                tti_trace_capture options: L2Ps / L2Lo / L2HiPdcp / L2HiRlc . Default value is “L2Ps”.
    ...                trace_type options: Component, System default: Component
    [Arguments]    ${collector_name}=l2stream3
    ${phy_cell_ids}=    Get Physical Cell IDs
    ${release}      Set Variable    SBTS00
    &{l2_stream_config}    Create Dictionary    nr_phy_cell_ids=${phy_cell_ids}      up_sw=${tti_trace_capture}      trace_type=Component
    &{webservice}    Create Dictionary      host=192.168.255.129      user=Nemuadmin    password=nemuuser
    ...     port=443      release=${release}
    @{l2_stream_config_list}      Create List      ${l2_stream_config}
    tcpdump.create tcpdump collector
    ...  name=tcpdump
    ...  options=-i eth3 -n udp and port 5678 -s0 -v
    ...  sudo_password=ute
    ttistream.create_sbts_l2stream_collector
    ...  name=${collector_name}
    ...  webservice=${webservice}
    ...  destination_ip_addr=10.0.1.1
    ...  collector=tcpdump
    ...  l2_stream_configuration=${l2_stream_config_list}
    ttistream.setup_collectors    names=${collector_name}
    ttistream.Set Test Alias    alias=${collector_name}
    ttistream.start_collectors    names=${collector_name}
    set Test Variable       ${tti_trace_started}    ${True}

ADMIN Set RAD debug parameters
    [Documentation]    This keyword will modify debug flags in the gNB GUI in BTS RAD Debug Parameters page
    ...                Need to Setup_admin before using this keyword and teardown admin after the changes are done.
    ...                Modified Date: 11-Jul-2024
    ...                Last Modified by: merin.varghese@nokia.com
    ...    Usage:
    ...         CoamAdmin.Setup admin
    ...         ADMIN Set RAD debug parameters    Domain=L2PS     Name=rdFeatureFlagBitmapLevel     Value=4    Persistency=NotPersistent
    ...         ${respsone1}    Get RAD debug parameter    Domain=L2PS
    ...         [Teardown]    CoamAdmin.Teardown admin
    [Arguments]    ${Domain}    ${Name}    ${Value}    ${Persistency}   ${timeOut}=30    ${connecTion}=default
    ${bts_state}=       CoamAdmin.Set Rad Debug Parameters
    ...    domain=${Domain}
    ...    persistency=${Persistency}
    ...    name=${Name}
    ...    value=${Value}
    ...    timeout=${timeOut}
    ...    connection=${connecTion}

Get RAD debug parameter
    [Arguments]    ${Domain}    ${timeOut}=30    ${Detailed_Output}=true    ${connecTion}=default
    ${rad_debug_parameters_results}    CoamAdmin.Get Rad Debug Parameters
    ...    domain=${Domain}
    ...    timeout=${timeOut}
    ...    detailed_output=${Detailed_Output}
    ...    connection=${connecTion}
    [Return]    ${rad_debug_parameters_results}

Start collect log by gnb tool
    [Documentation]    It's a tool for gNB logs collection.Based on the input to the script, different logs can be collected.
    ...                The script gnb_logs.exe must be present on the respective TL under the path /home/ute//EMIL_Logs/gnb_logs/
    ...                Modified Date: 11-Jul-2024
    ...                Last Modified by: merin.varghese@nokia.com
    [Arguments]    ${command}=./gnb_logs 192.168.255.129 -E -w
    set Test Variable     ${gnb_logs_started}    ${True}
    set Test Variable    ${emil_script_dir}   /home/ute/EMIL_Logs
    @{items}    List Directory   ${emil_script_dir}
    ${status}    run keyword and return status    Directory Should Exist    ${emil_script_dir}
    Run keyword if    '${status}' == 'False'   Log to console    message=Did not find the gnb logs script
    OperatingSystem.Run    rm ${emil_script_dir}/gnb_logs/*.zip
    ssh.Connect To    127.0.0.1    ute    ute    alias=bsh
    ssh.Execute    chmod 777 ${emil_script_dir}/gnb_logs    connection=bsh
    ssh.Send Command    cd ${emil_script_dir}/gnb_logs;${command}    connection=bsh
    ssh.Read Output Until    (Q)uit    connection=bsh

Stop collect log by gnb tool
#    Wait 30s for stability
    return from keyword if    '${gnb_logs_started}' == 'False'
    set Test Variable     ${gnb_logs_started}    ${False}
    OperatingSystem.Run    touch ${emil_script_dir}/gnb_logs/stop_mon.log
    sleep    30s
    Wait Until Keyword Succeeds    300    10    file should contain
    ...    ${emil_script_dir}/gnb_logs/tool.log    Tool finished running
    @{items}    List Directory   ${emil_script_dir}/gnb_logs
    OperatingSystem.Run    ls -ltrh ${emil_script_dir}/gnb_logs
    OperatingSystem.Run    mkdir ${testlog_path}/gnblogs_tool
    ${rc}    ${output}    OperatingSystem.Run and Return RC and Output
    ...    mv ${emil_script_dir}/gnb_logs/*.zip ${testlog_path}/gnblogs_tool

Start DCAP service on the testline
    Run Keyword And Continue on Failure    Run And Expect Command To Pass    command=DCAP_Basic_controller start
    ...    msg=Start DCAP services on testline
    sleep    30s     msg=wait for DCAP service to start
    Run And Return Rc And Output    DCAP_Basic_controller status

DCAP_Start_Trace_with_gnb_custom_profile
    [Documentation]    DCAP tool is used to collect logs at gNB.
    ...                The gNB (5G) custom profile name list of the start trace to be started. e.g : [cp_5g, controlPlane5g,
    ...                pmFiles5g, condor5gSyslog, SCF5g, L2Ps_Component, L2Lo_Component, L2HiRlc_Component, L2HiPdcp_Component,
    ...                L2Ps_Sherpa, L2Lo_Sherpa, L2HiRlc_Sherpa, L2HiPdcp_Sherpa, bip_interface_mirroring, L1stream, Tracer_5g, l1IqTracer]
    ...                Modified Date: 11-Jul-2024
    ...                Last Modified by: merin.varghese@nokia.com
    [Arguments]    ${custom_profile_gnb}=${gnb_custom_profile}
    Start DCAP service on the testline
    rd.connect_to     host=${tl.test_pc.default_ssh_connection_details.addr}      port=9443     rd_version=dcapv3    secure=${True}
    &{bts_info}      create dictionary    host=10.0.1.2    port=443    username=Nemuadmin     password=nemuuser
    ${output}     rd.start_trace     tag=start_trace      duration=-1     bts=${bts_info}
    ...           gnb_custom_profile=${custom_profile_gnb}    wait_for_activation=${True}
    set Test Variable       ${dcap_logs_started}    ${True}
    ${trace_id}   Get From Dictionary   ${output}   tracer_id
    set Test Variable       ${trace_id}
    sleep   60s    msg=stablising dcap trace collection
    [Return]    ${trace_id}

Stop DCAP Trace
    [Arguments]    ${target_dir}=${OUTPUT_DIR}
    return from keyword if    '${dcap_logs_started}' == 'False'
    rd.stop_trace     trace_id=${trace_id}    timeout=180
    IF    '${TEST_STATUS}' == 'FAIL' or '${COPY_PASS_LOGS}' == 'True'
        rd.get_results    result_id=${trace_id}       target_dir=${target_dir}    timeout=600
    END
    set Test Variable       ${dcap_logs_started}    ${False}

Collect logs for debug
    [Documentation]     This is the higher level keyword which is to be used in the TC for collecting all logs for a TC.
    Run Keyword And Continue on Failure    run keyword if     ${DCAP_LOGS_NEEDED}        DCAP_Start_Trace_with_gnb_custom_profile
    Run Keyword And Continue on Failure    run keyword if     ${BTS_LOG_NEEDED}          Start btslog
    Run Keyword And Continue on Failure    run keyword if     ${BIP_LOG_NEEDED}          Start BIP logs for APoverABIO
    Start WTS Top Output Capture
    Start WTS tcpdump for capturing sctp packets

Stop logs collected for debug
    [Arguments]    ${collect_sosreport_at_suite}=False
    ${target_log_path}    Run Keyword If    '${collect_sosreport_at_suite}' == 'True'    log_store.get_suite_log_folder
    ...    ELSE    log_store.get_test_log_folder
    Set Test Variable     ${target_log_path}
    Run Keyword And Continue on Failure    Stop and Copy AP TTI Traces    prefix=AP     target_dir=${target_log_path}
    Run Keyword And Continue on Failure    Stop btslog    target_dir=${target_log_path}
    Run Keyword And Continue on Failure    Stop TTI Trace Collection    target_dir=${target_log_path}     TEST_STATUS=${TEST_STATUS}
    Run Keyword And Continue on Failure    Stop DCAP Trace    target_dir=${target_log_path}
    Run Keyword And Continue on Failure    Collect gnb snapshot    target_dir=${target_log_path}
    Run Keyword And Continue on Failure    Stop BIP and collect SOS for APoverABIO    target_dir=${target_log_path}
    Run Keyword And Continue on Failure    Stop WTS Top Output Capture    target_dir=${target_log_path}
    Run Keyword And Continue on Failure    Stop WTS pcap    target_dir=${target_log_path}
    Run Keyword And Continue on Failure    Collect Iperf Files

Set RND Parameter
    CoamAdmin.connect_to
    CoamAdmin.change_bts_rad_parameters    0x58    1405:4,1402:4
    [Teardown]    Run Keyword And Ignore Error    CoamAdmin.teardown_admin

Start BIP logs for APoverABIO
    Enable BIP Logs
    run keyword and ignore error    Run    cd ${sosReport_ASIL_path} && rm SosReport*.tgz
    Run    sudo chmod 777 ${uteEpcDir}/${Start_sos_ASIL}
    SSH.Connect To        127.0.0.1    ute    ute    alias=sosReportConnection
    ${result}             SSH.Execute    ${uteEpcDir}/${Start_sos_ASIL}    sosReportConnection
    set Test Variable       ${bip_logs_started}    ${True}

Stop BIP and collect SOS for APoverABIO
    [Timeout]    15 minute
    [Arguments]    ${target_dir}=${OUTPUT_DIR}
    return from keyword if    '${bip_logs_started}' == 'False'
    Run    sudo chmod 777 ${uteEpcDir}/${Stop_sos_ASIL}
    ${command}    Catenate    cd ${sosReport_ASIL_path} && ./${stop_asil_script}
    IF    '${TEST_STATUS}' == 'FAIL' or '${COPY_PASS_LOGS}' == 'True'
        ${sosreport_output}    Run And Expect Command To Pass    command=${command}    msg=stop script and collect sosreport
        Copy sosreport to log folder    ${sosreport_output}    target_dir=${target_dir}
        Set test variable    ${SOSREPORT_NEEDED}    ${False}
    ELSE
        Run    sh ${CURDIR}/sosreport_in_background.sh stop
    END
    run keyword and ignore error    Run    cd ${sosReport_ASIL_path} && rm SosReport*.tgz

Copy sosreport to log folder
    [Arguments]    ${sosreport_output_str}=${EMPTY}     ${target_dir}=${OUTPUT_DIR}
    ${file_name}    Get Regexp Matches    ${sosreport_output_str}    (SosReport.*complete_(UEAPP|iphy1).tgz)   1
    ${sosreport_file_name}    Get From List    ${file_name}    0
    Run Keyword And Continue on Failure    Run And Expect Command To Pass    command=mv ${sosReport_ASIL_path}/${sosreport_file_name} ${target_dir}
    ...    msg=File copy
    File Should Exist    ${target_dir}/${sosreport_file_name}
    Run And Expect Command To Pass    command=ls -ltrh ${target_dir}

Enable BIP Logs
    Log    Enabling ENABLE_BIP_LOG=1 in {sosReportCfg}
    Run    sed -i "s/ENABLE_BIP_LOG=0/ENABLE_BIP_LOG=1/" /opt/wts/latest/${sosReportCfg}

Start WTS Top Output Capture
    Run    sudo rm -f /tmp/${wts_vm_top_results}
    Run    top -b -d 5 > /tmp/${wts_vm_top_results} &
    ${pid}             Run    sudo pgrep top
    Log                Top output collection started with PID: ${pid}
    set Test Variable       ${top_capture_started}    ${True}
    [Return]           ${pid}

Stop WTS Top Output Capture
    [Arguments]    ${target_dir}=${OUTPUT_DIR}
    return from keyword if    '${top_capture_started}' == 'False'
    Run    pkill -f top
    IF    '${TEST_STATUS}' == 'FAIL' or '${COPY_PASS_LOGS}' == 'True'
        Run    mkdir -p ${target_dir}/WTS_TOP_OUTPUT
        Run Keyword And Continue on Failure    Run And Expect Command To Pass
        ...    command=cp /tmp/${wts_vm_top_results} ${target_dir}/WTS_TOP_OUTPUT    msg=File copy
        File Should Exist    ${target_dir}/WTS_TOP_OUTPUT/${wts_vm_top_results}
    END
    run keyword and ignore error    Run    sudo rm -f /tmp/${wts_vm_top_results}

Modify RAD params in AP and GNB for SYSLOG
    [Documentation]    This keyword modifies the RAD parameters in the AP and gNB swconfig files.
    ...    0x10040=2   # SYSLOG output severity prints (0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable)
    ...    0x10041=5   # Output mode which devices prints are forwarded (0=none 1=all 2=udp 3=sic 4=standard output 5=local 6=remote 7=not valid)
    ...    0x10042=0xc0a8c87e   #IP_Adress in hex used for log forwarding
    Modify rad params in AP swconfig file    0x10040=2     0x10041=5     0x1003F=1    0x10042=0xc0a8c87e
    Modify rad params in gNB swconfig file    0x10040=1     0x10041=5      0x1003F=2

Start UDP TCPDump on WTS
    [Documentation]    This keyword starts tcpdump on WTS to capture UDP traffic with specific options.
    [Arguments]        ${interface}=eth3    ${protocol}=udp    ${output_file}=/tmp/wts_eth3_udp.gz
    ${command}         Catenate    sudo tcpdump -i ${interface} ${protocol} -w ${output_file}
    ...                            -C 100 -W 10 -s 100 -z gzip > /dev/null 2>&1 &
    Run                ${command}
    ${pid}             Run    sudo pgrep tcpdump
    Log                TCPDump on {interface} started with PID: ${pid}
    [Return]           ${pid}

Start SCTP TCPDump on WTS
    [Documentation]    This keyword starts tcpdump on WTS to capture SCTP packets
    [Arguments]        ${interface}=eth3    ${protocol}=sctp    ${output_file}=/tmp/wts_eth3_sctp.gz
    ${command}         Catenate    SEPARATOR=    sudo tcpdump -i ${interface} ${protocol} -w ${output_file} > /dev/null 2>&1 &
    Run                ${command}
    ${pid}             Run    sudo pgrep tcpdump
    Log                TCPDump started with PID: ${pid}
    [Return]           ${pid}

Stop TCPDump
    [Documentation]    This keyword stops the tcpdump process using the given PID.
    [Arguments]        ${pid}
    Run                sudo kill -9 ${pid}
    Log                TCPDump process with PID ${pid} has been stopped

Start WTS tcpdump for UDP traffic
    ${udp_eth3_wts_pid}    Start UDP TCPDump on WTS    interface=eth3     protocol=udp    output_file=/tmp/wts_eth3_udp.gz
    ${udp_eth4_wts_pid}    Start UDP TCPDump on WTS    interface=eth4    protocol=udp    output_file=/tmp/wts_eth4_udp.gz

Start WTS tcpdump for capturing sctp packets
    run keyword and ignore error    Run    sudo rm -rf /tmp/wts_eth*
    ${sctp_eth3_wts_pid}   Start SCTP TCPDump on WTS    interface=eth3    protocol=sctp    output_file=/tmp/wts_eth3_sctp.gz
    ${sctp_eth4_wts_pid}   Start SCTP TCPDump on WTS    interface=eth4    protocol=sctp    output_file=/tmp/wts_eth4_sctp.gz
    set Test Variable       ${wts_tcpdump_started}    ${True}

Stop WTS pcap
    [Arguments]    ${target_dir}=${OUTPUT_DIR}
    return from keyword if    '${wts_tcpdump_started}' == 'False'
    Run    sudo pkill -f tcpdump
    IF    '${TEST_STATUS}' == 'FAIL' or '${COPY_PASS_LOGS}' == 'True'
        Run And Expect Command To Pass    command=ls -ltrh /tmp/
        Run And Expect Command To Pass    command=mkdir -p ${target_dir}/WTS_PCAP_eth3
        Run And Expect Command To Pass    command=mkdir -p ${target_dir}/WTS_PCAP_eth4
        Run Keyword And Continue on Failure    Run And Expect Command To Pass    command=cp /tmp/wts_eth3* ${target_dir}/WTS_PCAP_eth3
        ...    msg=File copy
        Run Keyword And Continue on Failure    Run And Expect Command To Pass    command=cp /tmp/wts_eth4* ${target_dir}/WTS_PCAP_eth4
        ...    msg=File copy
        Run And Expect Command To Pass    command=ls -ltrh ${target_dir}/WTS_PCAP_eth3
        Run And Expect Command To Pass    command=ls -ltrh ${target_dir}/WTS_PCAP_eth4
    END
        run keyword and ignore error    run keyword and ignore error    Run    sudo rm -rf /tmp/wts_eth*
    set Test Variable       ${wts_tcpdump_started}    ${False}

Collect Iperf Files
    [Arguments]    ${target_dir}=${OUTPUT_DIR}
	IF    '${log_iperf_files}' == 'True'
        Run And Expect Command To Pass    command=ls -ltrh /tmp/
        Run And Expect Command To Pass    command=mkdir -p ${target_dir}/IPERF_FILES
        Run Keyword And Continue on Failure    Run And Expect Command To Pass    command=cp /tmp/iperf_* ${target_dir}/IPERF_FILES
        ...    msg=File copy
        Run And Expect Command To Pass    command=ls -ltrh ${target_dir}/IPERF_FILES
        Comment    run keyword and ignore error    Run    sudo rm -rf /tmp/iperf_*
	END

Activate TTI Trace Streaming
    ${out}    Execute Egate Command and wait for data   cmd=sim_tti_trace on_mask=0xff enb=2 cell=1-6
    ...    pass_regexp=.*Activated Tti Streaming at L2RT in node.*

Trigger TTI traces
    [Arguments]    ${prefix}
    RUN    mkdir -p ${EXECDIR}/logs/TTI_TRACES_${prefix}/
    RUN    chmod 777 ${EXECDIR}/logs/TTI_TRACES_${prefix}/
    RUN    sudo tcpdump -v -ni eth4 port 5678 -C 100 -W 20 -w ${EXECDIR}/logs/TTI_TRACES_${prefix}/${prefix}_tti.pcap.gz > /dev/null 2>&1 &

Deactivate TTI Streaming
    ${out}    Execute Egate Command and wait for data   cmd=sim_tti_trace on_mask=0 enb=2 cell=1-6    timeout=60s
    ...    pass_regexp=.*Deactivated Tti Streaming at*

Kill Deleted Process
    Run And Return Rc And Output    sudo pkill tcpdump
    Run And Return Rc And Output    sudo ps -aef | grep -i tcpdump
    Run And Return Rc And Output    lsof +L1

Stop and Copy AP TTI Traces
    [Arguments]    ${prefix}    ${target_dir}=${OUTPUT_DIR}
    return from keyword if    '${ap_tti_started}' == 'False'
    RUN    sudo pkill tcpdump
    Kill Deleted Process
    Deactivate TTI Streaming
    IF    '${TEST_STATUS}' == 'FAIL' or '${COPY_PASS_LOGS}' == 'True'
        RUN    sudo tar -czvf TTI_TRACES_${prefix}.tgz -C ${EXECDIR}/logs TTI_TRACES_${prefix}
        RUN    mv ${EXECDIR}/TTI_TRACES_${prefix}.tgz ${target_dir}/
    END
    RUN    sudo rm -rf ${EXECDIR}/logs/TTI_TRACES_${prefix}

Start AP TTI Traces
    [Arguments]    ${prefix}
    Run Keyword And Continue on Failure    Conditional AP TTI Trace    ${prefix}

Start gNB TTI Traces
    Run Keyword And Continue on Failure    run keyword if     ${GNB_TTI_TRACE_NEEDED}    Start TTI Trace Log

Conditional AP TTI Trace
    [Arguments]    ${prefix}
    Run Keyword If    ${AP_TTI_TRACE_NEEDED}    Run Keywords
    ...    Activate TTI Trace Streaming
    ...    AND    Trigger TTI traces    ${prefix}
    ...    AND    set Test Variable       ${ap_tti_started}    ${True}

Enable rrc traces in WTS
    Execute Egate Command    cmd=sim_trace uec=1 protocol=nr_rrc on    timeout=1s
    Execute Egate Command    cmd=sim_trace uec=1 protocol=rrc on       timeout=1s

Collect Screenshot
    [Arguments]    ${target_dir}=${OUTPUT_DIR}
    screenshot.collect_screenshot
    IF    '${TEST_STATUS}' == 'FAIL' or '${COPY_PASS_LOGS}' == 'True'
        Run    mkdir -p ${target_dir}/SCREENSHOTS
        Run Keyword And Continue on Failure    Run And Expect Command To Pass
        ...    command=cp -r /tmp/SCREENSHOTS ${target_dir}/    msg=File copy
        Directory Should Exist    ${target_dir}/SCREENSHOTS
    END
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/SCREENSHOTS

Check if the syslog error prints is in expected range
    [Arguments]    ${current_syslog_err_count}
    ${status}    Evaluate    ${current_syslog_err_count} < (${syslog_err_count} + 300)
    Run Keyword and continue on failure    Run Keyword If    not ${status}    FAIL    Syslog Error prints are more than expected

Collect gnb snapshot
    [Arguments]    ${target_dir}=${OUTPUT_DIR}
    CoamAdmin.connect_to
    ${timestamp}         DateTime.Get Current Date   result_format=%Y%m%d-%H%M%S
    ${snapshot_path}     Set Variable   ${target_dir}/BTS_Snapshot_${timestamp}.zip
    IF    '${TEST_STATUS}' == 'FAIL' or '${COPY_PASS_LOGS}' == 'True'
        CoamAdmin.Get Snapshot   target_file_name=${snapshot_path}
    END
    [Teardown]    Run Keyword And Ignore Error    CoamAdmin.teardown_admin

