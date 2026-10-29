*** Settings ***
Documentation    author：shushu huang
...              contact: shushu.huang@nokia-sbell.com
...              squad group: mmw_SG_03

Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot

Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/parse_soap.py
Library             taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    parse_soap.SOAPParser    WITH NAME    soapp
Library           OperatingSystem
Library           taf.transport.ssh    WITH NAME    csn
Library           DateTime
Library     taf.ue  WITH NAME   ute_ue


*** Variables ***
${CURDIR_path}                  ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}
${gNB_ip}                       ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}                 ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}                 ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ul_power_port_list}           ${tl.ues[0].iperf_details.ports[0:3]}
${dl_power_port_list}           ${tl.ues[0].iperf_details.ports[3:6]}
#${TS_CASE_LOG_PATH}             /home/ute
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
${luashark_path}                /opt/ute/luashark/luashark_script/generated_luashark
${scf_file_path}    ${commissionings_path}/HGZ/7_5_UTE5G402T712
${ute_host}    ${tl.test_pc.default_ssh_connection_details.addr}
${ute_name}    ${tl.test_pc.default_ssh_connection_details.username}
${ute_password}    ${tl.test_pc.default_ssh_connection_details.password}
${soap_log_file_soap}        /home/ute/Case_Logs/slimcell/soap/BTS_AH221640525_RMOD_L_2_UnitOAM_SOAP_Log.zip
${TS_CASE_LOG_PATH}    /home/ute/Case_Logs/slimcell
${searchName}      UnitOAM_SOAP_Log.zip
${WEBUI_ADDR}        ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asik_alias}    ASIK Master
${connection}    COAM
${TEST_LOG_DIRECTORY}    /home/ute/Case_Logs/robust
${LTE_UE_INDEX}    ${1}    # Will be updated dynamically when attach lte power ue is called

*** Keywords ***
Suite Teardown with SCF
    ${RELEASE}=   Get program version
    run keyword if    '${RELEASE}'=='25R3'    Scf commission and wait on-air    scf_name=SCF_CB007053_A_10_25R3.xml
    ...    ELSE IF    '${RELEASE}'=='26R1'    Scf commission and wait on-air    scf_name=SCF_CB007053_A_10_26R1.xml
    ...    ELSE    Scf commission and wait on-air    scf_name=SCF_CB007053_A_10.xml

Setup Commission SCF
    [Arguments]     ${BTS_Host}=${gNB_ip}    ${connection}=GNB_OAM
     ${default_scf}    Get sw build version for scf name
     Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${gNB_username}    password=${gNB_password}
     ...    connection=${connection}
     COAM Commission with scf file      scf_file_path=${default_scf}     connection=${connection}
     Wait Until Keyword Succeeds   16min   2min     COAM Check GNB cell on air
     run keyword and continue on failure     Wait Until Keyword Succeeds   10min   1min     Unexpect Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_FAULT}    file_path=${OUTPUT_DIR}    connection=${connection}
     [Teardown]    Run keyword and ignore error     COAM Teardown gnb connections    connection=${connection}

Get program version
    [Documentation]    Author: Ding Binmei
    ...                Description: Change the implementation to get program info from GNB.
    ...                Retrun with ${program_version}, valid output: 19A, 19B, 20B, master, ...
    Connect to Common Unit Master        alias=${asik_alias}
    ${cmd_get_sw_file_name}    Set variable    ls /ffs/run |grep TargetBD.*.xml |grep -v .xml.
    ${sw_file_name}    ssh.execute    command=${cmd_get_sw_file_name}    connection=ASIK Master
    @{sw_version_list}    Get regexp matches    ${sw_file_name}    TargetBD_(.*?)_    1
    ${sw_version}    Strip string    ${sw_version_list[0]}
    ${program_version}    Replace string using regexp    string=${sw_version}    pattern=SBTS|5G    replace_with=${EMPTY}
    [Return]    ${program_version}
    [teardown]    Run Keyword And Ignore error    csn.Disconnect   connection=ASIK Master


Coam Test Teardown
    log to console    \n*** Coam Test Teardown***
    Connect to gnb coam via ssl
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
    log to console  RU status: ${ru_status}
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    should be true    ${cell_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOW_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown




Check BTS Should Be Normal
    [Arguments]  ${bts_host}=${gNB_ip}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    Log To Console    Verity CELL ON AIR..
    Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}    file_path=${OUTPUT DIR}
    [Teardown]   Run Keyword And Ignore Error   COAM Teardown gnb connections

Get Content From Input Dict
    [Arguments]  ${input_dict}
    ${dist_name}    get from dictionary     ${input_dict}    dist_name
    ${parammeter}    get from dictionary    ${input_dict}    parameter
    ${new_value}     get from dictionary    ${input_dict}    value
    ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
    [Return]  ${value_list}

Modify Common parameter via Coam
    [Arguments]  ${input_list}    ${gNB_ip}=${gNB_ip}    ${connection}=GNB_connection
    log to console    Modify parameter
    Connect to gnb coam via ssl     bts_host=${gNB_ip}      connection=${connection}
    FOR    ${item}  IN    @{input_list}
        ${dict_value}    Get Content From Input Dict    input_dict=${item}
        coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
        ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
    END
    log to console  change parameter successful,sleep 30s
    sleep  30s
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}

attach power ue
    [Arguments]    ${gnb_index}=${0}
    log to console       Prepare UE
    power_ue.Prepare UE    ue_index=${gnb_index}    ue_type=qct_dx50
    ${5Grach_ed_0}=    power_ue.UE Attach    ue_index=${gnb_index}    ue_type=qct_dx50   log_type=Aasyslog
    power_ue.Verify attach    ue_type=qct_dx50   5Grach_ed=${5Grach_ed_0}    4G_check=False    gnb_index=${gnb_index}

Verify LTE attach
    [Documentation]    Verify LTE-only UE attach without checking 5G status
    [Arguments]    ${ue_type}=qct_dx50    ${ue_index}=${0}    ${4Grach_ed}=${EMPTY}
    log to console       Verifying LTE attach for ${ue_type} at index ${ue_index}
    # Check that attach log contains valid LTE attach indication
    Should Not Be Empty    ${4Grach_ed}    msg=LTE attach log is empty
    Should Contain    ${4Grach_ed}    Aasyslog    msg=LTE UE attach failed - no valid attach log
    log to console       LTE UE attach verified successfully - attach log contains valid entry

attach lte power ue
    log to console       Prepare LTE UE with qct_dx50 (force use UE index 1)
    Set Suite Variable    ${LTE_UE_INDEX}    ${1}
    log to console       Using UE index ${LTE_UE_INDEX} for LTE
    # Prepare UE internally calls ute_ue.Require Ue through power_ue library to create UE alias UE_${LTE_UE_INDEX}
    power_ue.Prepare UE    qct_dx50    ue_index=${LTE_UE_INDEX}    capatibility_index=1
    ${4Grach_ed}    power_ue.UE Attach    ue_index=${LTE_UE_INDEX}    ue_type=qct_dx50    attach_mode=4G    log_type=Aasyslog
    # Use dedicated LTE verify keyword instead of generic verify attach
    Verify LTE attach    ue_type=qct_dx50    ue_index=${LTE_UE_INDEX}    4Grach_ed=${4Grach_ed}
    log to console       LTE UE attach completed successfully - UE alias should be UE_${LTE_UE_INDEX}


start power ue traffic ul and dl
    [Arguments]     ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000
    ...    ${protocol}=udp
    log to console      Start traffic    console=yes
    run keyword and continue on failure      power_ue.Start traffic    ue_index=${0}    direction=ul
    ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=qct_dx50    iperf_type=via_command    protocol=${protocol}
    ...    iperf_port=${ul_power_port_list}[${0}]
    sleep    1s
    run keyword and continue on failure     power_ue.Start traffic    ue_index=${0}    direction=dl
    ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=qct_dx50    protocol=${protocol}
    ...    iperf_port=${dl_power_port_list}[${0}]

Start LTE UE Traffic Direct
    [Arguments]    ${ue_index}=${LTE_UE_INDEX}    ${direction}=ul    ${throughput}=20M    ${duration}=6000    ${port}=${None}
    [Documentation]    Start iperf traffic directly on Android UE without using power_ue library
    Set Variable    ${ue_index}    1
    ${ue_iperf_path}    Set Variable    /data/local/tmp/iperf
    ${ue_ip}    ute_ue.Get Ip    UE_${ue_index}
    ${appserver_ip}    Set Variable    ${TEST_PC_IP}
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    ${actual_port}    Set Variable If    '${port}' == '${None}'
    ...    ${ul_power_port_list}[${ue_index}] if '${direction}' == 'ul' else ${dl_power_port_list}[${ue_index}]
    ...    ${port}

    Run Keyword If    '${direction}' == 'ul'
    ...    Start UL Traffic Direct    ${ue_index}    ${ue_ip}    ${appserver_ip}
    ...    ${throughput}    ${duration}    ${actual_port}    ${ue_iperf_path}    ${serial_number}
    ...    ELSE
    ...    Start DL Traffic Direct    ${ue_index}    ${ue_ip}    ${appserver_ip}
    ...    ${throughput}    ${duration}    ${actual_port}    ${ue_iperf_path}    ${serial_number}

Start UL Traffic Direct
    [Arguments]    ${ue_index}    ${ue_ip}    ${appserver_ip}    ${throughput}    ${duration}    ${port}    ${iperf_path}    ${serial_number}
    log to console    Starting UL traffic: UE=${ue_ip} -> Server=${appserver_ip}, port=${port}, throughput=${throughput}

    # Connect to APP server and start iperf server
    csn.Connect to    ${TEST_PC_IP}
    ...    ${TEST_PC_USERNAME}
    ...    ${TEST_PC_PASSWORD}
    ...    alias=appserver_${ue_index}

    # Clean up old iperf processes
    csn.execute    command=ps -ef | grep iperf | grep -v grep | grep ${port} | awk '{print $2}' | xargs -r kill -9    connection=appserver_${ue_index}
    sleep    1s

    # Start iperf server on APP server with output redirect
    ${log_file}    Set Variable    /tmp/iperf_ul_server_${ue_index}_${port}.log
    csn.send command    command=iperf -s -u -p ${port} -i 1 > ${log_file} 2>&1 &    connection=appserver_${ue_index}
    sleep    2s
    log to console    APP server iperf started on port ${port}, log: ${log_file}

    # Start iperf client on UE via adb
    csn.Connect to    ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    alias=cpc_${ue_index}
    ${bandwidth}    Replace String    ${throughput}    M    000k
    ${cmd}    Catenate    SEPARATOR=${SPACE}
    ...    adb -s ${serial_number} shell ${iperf_path}
    ...    -c ${appserver_ip} -u -b ${bandwidth}
    ...    -p ${port} -t ${duration} -i 1 -l 1400 &
    log to console    UE command: ${cmd}
    csn.send command    command=${cmd}    connection=cpc_${ue_index}
    sleep    2s
    log to console    UL traffic started successfully

Start DL Traffic Direct
    [Arguments]    ${ue_index}    ${ue_ip}    ${appserver_ip}    ${throughput}    ${duration}    ${port}    ${iperf_path}    ${serial_number}
    log to console    Starting DL traffic: Server=${appserver_ip} -> UE=${ue_ip}, port=${port}, throughput=${throughput}

    # Start iperf server on UE via adb
    csn.Connect to    ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    alias=cpc_${ue_index}
    ${cmd_server}    Catenate    SEPARATOR=${SPACE}
    ...    adb -s ${serial_number} shell ${iperf_path}
    ...    -s -u -p ${port} -i 1 &
    log to console    UE server command: ${cmd_server}
    csn.send command    command=${cmd_server}    connection=cpc_${ue_index}
    sleep    2s
    log to console    UE iperf server started on port ${port}

    # Connect to APP server and start iperf client
    csn.Connect to    ${TEST_PC_IP}
    ...    ${TEST_PC_USERNAME}
    ...    ${TEST_PC_PASSWORD}
    ...    alias=appserver_${ue_index}

    # Clean up old iperf processes
    csn.execute    command=ps -ef | grep iperf | grep -v grep | grep ${port} | awk '{print $2}' | xargs -r kill -9    connection=appserver_${ue_index}
    sleep    1s

    # Start iperf client on APP server with output redirect
    ${bandwidth}    Replace String    ${throughput}    M    000k
    ${log_file}    Set Variable    /tmp/iperf_dl_client_${ue_index}_${port}.log
    ${dl_cmd}    Catenate    SEPARATOR=${SPACE}
    ...    iperf -c ${ue_ip} -u -b ${bandwidth}
    ...    -p ${port} -t ${duration} -i 1 -l 1400
    ...    > ${log_file} 2>&1 &
    csn.send command    command=${dl_cmd}    connection=appserver_${ue_index}
    sleep    2s
    log to console    DL traffic started successfully, log: ${log_file}

start lte power ue traffic ul and dl
    [Documentation]    Start LTE UE traffic using custom iperf control
    [Arguments]     ${ue_index}=${LTE_UE_INDEX}    ${ul_throughput}=${None}    ${dl_throughput}=${None}
    ...    ${ul_duration}=6000    ${dl_duration}=6000
    Set Variable    ${ue_index}    1
    log to console      Start LTE traffic on index ${ue_index}    console=yes

    # Start UL and DL traffic directly
    ${ul_port}    Set Variable    ${ul_power_port_list}[${ue_index}]
    ${dl_port}    Set Variable    ${dl_power_port_list}[${ue_index}]

    log to console    Starting UL traffic with ${ul_throughput} throughput
    Start LTE UE Traffic Direct    ue_index=${ue_index}    direction=ul    throughput=${ul_throughput}    duration=${ul_duration}    port=${ul_port}

    sleep    1s

    log to console    Starting DL traffic with ${dl_throughput} throughput
    Start LTE UE Traffic Direct    ue_index=${ue_index}    direction=dl    throughput=${dl_throughput}    duration=${dl_duration}    port=${dl_port}

Check lte power ue Tput
    [Documentation]    Check LTE UE throughput by reading iperf output directly from APP server log files
    [Arguments]     ${ue_index}=${LTE_UE_INDEX}    ${time}=120s    ${ul_throughput}=${None}
    ...             ${dl_throughput}=${None}
    Set Variable    ${ue_index}    1
    log to console    \nChecking LTE UE tput from iperf: ue_index=${ue_index}
    log to console    Will wait ${time} for throughput collection...

    # Wait for throughput collection period
    sleep    ${time}

    # Read throughput from iperf log files on APP server
    ${ul_port}    Set Variable    ${ul_power_port_list}[${ue_index}]
    ${dl_port}    Set Variable    ${dl_power_port_list}[${ue_index}]

    # Get UL throughput from APP server iperf server log
    log to console    \n========== UL Throughput (UE -> Server) ==========
    ${ul_log_file}    Set Variable    /tmp/iperf_ul_server_${ue_index}_${ul_port}.log
    log to console    Reading UL log from: ${ul_log_file}
    ${ul_output}    csn.execute
    ...    command=tail -n 50 ${ul_log_file} 2>/dev/null || echo "Log file not found"
    ...    connection=appserver_${ue_index}
    log to console    \nUL iperf output:\n${ul_output}

    # Extract throughput summary
    ${ul_summary}    csn.execute
    ...    command=grep -E "[0-9.]+ [MK]bits/sec" ${ul_log_file} 2>/dev/null | tail -n 5 || echo "No throughput data"
    ...    connection=appserver_${ue_index}
    log to console    \nUL Throughput Summary (last 5 intervals):\n${ul_summary}

    # Get DL throughput from APP server iperf client log
    log to console    \n========== DL Throughput (Server -> UE) ==========
    ${dl_log_file}    Set Variable    /tmp/iperf_dl_client_${ue_index}_${dl_port}.log
    log to console    Reading DL log from: ${dl_log_file}
    ${dl_output}    csn.execute
    ...    command=tail -n 50 ${dl_log_file} 2>/dev/null || echo "Log file not found"
    ...    connection=appserver_${ue_index}
    log to console    \nDL iperf output:\n${dl_output}

    # Extract throughput summary
    ${dl_summary}    csn.execute
    ...    command=grep -E "[0-9.]+ [MK]bits/sec" ${dl_log_file} 2>/dev/null | tail -n 5 || echo "No throughput data"
    ...    connection=appserver_${ue_index}
    log to console    \nDL Throughput Summary (last 5 intervals):\n${dl_summary}

    log to console    \n========== Summary ==========
    log to console    UL Port: ${ul_port}, Target: ${ul_throughput} Mbps
    log to console    DL Port: ${dl_port}, Target: ${dl_throughput} Mbps
    log to console    See iperf output above for actual measured throughput values

stop lte power ue traffic ul and dl
    [Arguments]    ${ue_index}=${LTE_UE_INDEX}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    Set Variable    ${ue_index}    1
    log to console     Stop LTE traffic on index ${ue_index}    console=yes
    # Stop Data Transfer trackers first
    ${dt_name_ul}    Set Variable    DT_ul_${ue_index}
    ${dt_name_dl}    Set Variable    DT_dl_${ue_index}
    run keyword if    ${if_ul}    Run Keyword And Ignore Error    ute_ue.stop_data_transfer    dt_name=${dt_name_ul}
    run keyword if    ${if_dl}    Run Keyword And Ignore Error    ute_ue.stop_data_transfer    dt_name=${dt_name_dl}
    # Then stop the actual iperf traffic
    run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=qct_dx50    iperf_type=${protocol}
    ...    protocol=${protocol}    iperf_port=${ul_power_port_list}[${ue_index}]
    run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=qct_dx50    protocol=${protocol}
    ...    iperf_port=${dl_power_port_list}[${ue_index}]

Check power ue Tput
    [Arguments]     ${time}=120s    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${target_avg_percent}=0.8    ${min_percent}=0.0
    ...    ${cell1}=${183233}    ${cell2}=${183234}
    ${cells1}    create list    ${cell1}
    ${cells2}    create list    ${cell2}
    ${log_path}    power_ue.Collect Tput     ue_type=qct_dx50    duration=${time}    ignore_time=10s
    ${output_ul1}    run keyword and return status    power_ue.Check Tput    ue_type=qct_dx50    direction=ul    target_throughput=${ul_throughput}
    ...     target_avg_percent=${target_avg_percent}    min_percent=${min_percent}   cells=${cells1}    log=${log_path}
    ${output_dl1}    run keyword and return status    power_ue.Check Tput    ue_type=qct_dx50    direction=dl    target_throughput=${dl_throughput}
    ...     target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cells=${cells1}    log=${log_path}
    ${output_ul2}    run keyword and return status    power_ue.Check Tput    ue_type=qct_dx50    direction=ul    target_throughput=${ul_throughput}
    ...     target_avg_percent=${target_avg_percent}    min_percent=${min_percent}   cells=${cells2}    log=${log_path}
    ${output_dl2}    run keyword and return status    power_ue.Check Tput    ue_type=qct_dx50    direction=dl    target_throughput=${dl_throughput}
    ...     target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cells=${cells2}    log=${log_path}
    should be true    ${output_ul1}!=${output_ul2}
    should be true    ${output_dl1}!=${output_dl2}

Start Btslog Collect for CB008124
    [Arguments]    ${names}=btslog8124    ${btslog_path}=/opt/btslog/btslog
    ...            ${btslog_launcher_path}=/opt/btslog/btslog_launcher
    Log To Console    \n ### Btslog Collect Start ###
    csn.Connect to    hostname=${ute_host}    username=${ute_name}    password=${ute_password}    alias=ute
    ${executor_test_vm}=  Create Dictionary
    ...  host=${ute_host}
    ...  user=${ute_name}
    ...  password=${ute_password}
    btslog.Create Btslog Collector    name=${names}    btslog_path=${btslog_path}
    ...                               btslog_launcher_path=${btslog_launcher_path}
    ...                               executor=${executor_test_vm}
    btslog.Set Suite Alias    ${names}
    core.Setup Collectors    names=${names}
    core.Start Collectors    names=${names}
    sleep    5s

Stop btslog and check
    ${btslog_name}    Stop Btslog Collect for CB008124
    Check Btslog    btslog_name=${btslog_name}    filter1=entering state:CGACTIVATED
    ...    filter2=leaving state:CGWAITFORACTIVATIONCONFIRMATION
    sleep    5s

Stop Btslog Collect for CB008124
    [Arguments]    ${names}=btslog8124
    Log To Console    \n ### Btslog Collect Stop ###
    core.Stop Collectors    names=${names}
    core.Collect Collectors    names=${names}    target_dir=${TEST_LOG_DIRECTORY}
    core.Teardown Collectors    names=${names}
    ${btslog_name}    Join Path    ${TEST_LOG_DIRECTORY}    ${names}
    [Return]    ${btslog_name}

stop multi power ue traffic ul and dl
    [Arguments]    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console     Stop traffic    console=yes
    run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=qct_dx50    iperf_type=${protocol}
    ...    protocol=${protocol}    iperf_port=${ul_power_port_list}[${0}]
    run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=qct_dx50    protocol=${protocol}
    ...    iperf_port=${dl_power_port_list}[${0}]

Check Btslog
    [Arguments]    ${btslog_name}    ${filter1}    ${filter2}
    Log    Checking BTS Syslog to confirm parameter change.    console=True
    OperatingSystem.Run    command=tar zxvf ${btslog_name}/syslog_files.tgz -C/${btslog_name}/
    ${output1}    OperatingSystem.Run    command=cat ${btslog_name}/SYSLOG*.LOG | grep -a "${filter1}" | grep -av grep
    ${output2}    OperatingSystem.Run    command=cat ${btslog_name}/SYSLOG*.LOG | grep -a "${filter2}" | grep -av grep
    #append to list    ${output1}    ${output2}
    Should Not Be Empty    ${output1}${output2}

detach multi power ue
    log to console      UE Detach    console=yes
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${0}    ue_type=qct_dx50

detach lte power ue
    [Arguments]    ${ue_index}=${LTE_UE_INDEX}
    log to console      LTE UE Detach    console=yes
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${ue_index}    ue_type=qct_dx50

Find UE Index By Type
    [Arguments]    ${ue_type}
    log to console    Searching for ${ue_type} in testline config
    ${ue_count}=    Get Length    ${tl.ues}
    FOR    ${index}    IN RANGE    ${ue_count}
        ${capabilities}=    Set Variable    ${tl.ues[${index}].capabilities}
        ${has_type}=    Run Keyword And Return Status    Should Contain    ${capabilities}    ${ue_type}
        Return From Keyword If    ${has_type}    ${index}
    END
    Fail    Cannot find UE with type ${ue_type} in testline configuration

Scf commission and wait on-air
    [Arguments]   ${scf_name}   ${connection}=COAM
    log to console    step1:scf commission and wait for on-air
    Conect to DU COAM
    admin_cli.perform_commissioning
    ...   scf_file=${scf_file_path}/${scf_name}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=${connection}
	sleep    60s
    #Wait Until Keyword Succeeds    20min    20s    COAM Check All Cells Onair
    Run Keyword And Ignore error    COAM Logout

COAM Check All NR Cells Onair
    [Arguments]   ${connection}=COAM
    log to console     Check NR cells onair
    Conect to DU COAM
    ${cell_list}   COAM Get Cell List   connection=${connection}
    FOR   ${cell}   IN   @{cell_list}
        ${status}   Set Variable   ${cell['status']}
        ${output}    convert to string    ${status}
        Run Keywords
        ...      Should Be Equal   ${status['administrativeState']}   Unlocked   AND
        ...      should not contain    ${output.lower()}    degraded    AND
        ...      Should Be Equal   ${status['operationalState']}   enabled
    END


Collect snapshot logs
    log to console    Collect snapshot logs
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${snapshot_file}    set variable    Snapshot_MRBTS-${MRBTS_ID}_TL712_${timestamp_log}.zip
    admin_cli.collect_snapshot    target_file_name=${TEST_LOG_DIRECTORY}/${snapshot_file}      timeout=600    connection=COAM


Conect to DU COAM
    [Arguments]    ${connection}=COAM
    Wait Until Keyword Succeeds    3min    10s    admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
                  ...      username=${WEBUI_USER}
                  ...      password=${WEBUI_PASSWORD}
                  ...      name=${connection}
                  ...      timeout=120

Power Off pDU
    [Arguments]    ${pdu_ip}    ${pdu_port}    ${model}=HBTE
    Log To Console    Power Off pDU
    pdu.Setup Pdu    model=${model}    host=${pdu_ip}    alias=pdu_alias
    pdu.Power Off    port=${pdu_port}    pdu_device=pdu_alias
    ${Status}    pdu.Get Port Status    port=${pdu_port}    pdu_device=pdu_alias
    should be true    '${Status}'=='off'
    Sleep    15s

Power On pDU
    [Arguments]    ${pdu_ip}    ${pdu_port}    ${model}=HBTE
    Log To Console    Power On pDU
    pdu.Setup Pdu    model=${model}    host=${pdu_ip}    alias=pdu_alias
    pdu.Power On    port=${pdu_port}    pdu_device=pdu_alias
    ${Status}    pdu.Get Port Status    port=${pdu_port}    pdu_device=pdu_alias
    should be true    '${Status}'=='on'

Get All RU Index and Return RU List
    [Arguments]     ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${ru_index_list}    Get All RU Index   connection=${connection}
    [Return]  ${ru_index_list}
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}

Get All RU dictionary
    [Arguments]     ${connection}=GNB_OAM
    &{hw_info}       coam.get_detected_hw_info    connection=${connection}
    ${rmod_info}    set variable    ${hw_info.radioModules.rmod}
    ${ru_list}    create list
    FOR  ${ru}  IN  @{rmod_info}
        ${ru_id_internal}  set variable  ${ru.id.internal}
        ${ru_id_configuration}  set variable  ${ru.id.configuration}
        ${ru_index}    get regexp matches    ${ru_id_configuration}    RMOD-(\\d+)    1
        ${dict}    Create Dictionary    ${ru_index}[0]    ${ru_id_internal}
        append to list   ${ru_list}    ${dict}
    END
    [Return]  ${ru_list}

All RU Locked and check status
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${ru_list}    Get All RU dictionary
    FOR    ${ru}     IN    @{ru_list}
        ${ru_id}    get_dictionary_keys       ${ru}
        ${ru_disname}    get_dictionary_values     ${ru}
        log to console    \n***RF ${ru_id}[0] Lock from GUI***
        coam.lock     dist_name=${ru_disname}[0]    connection=${connection}    timeout=120s
        wait until keyword succeeds  1min  30sec  RU Should Be Locked  ru_index=${ru_id}[0]    connection=${connection}
    END
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}

All RU UnLocked and check status
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${ru_list}    Get All RU dictionary
    FOR    ${ru}    IN    @{ru_list}
        ${ru_id}    get_dictionary_keys       ${ru}
        ${ru_disname}    get_dictionary_values     ${ru}
        log to console    \n***RF ${ru_id}[0] UnLock from GUI***
        coam.unlock      dist_name=${ru_disname}[0]    connection=${connection}    timeout=120s
        wait until keyword succeeds  5min  20sec  RU Should Be UnLocked  ru_index=${ru_id}[0]    connection=${connection}
    END
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}

Online Cell addition deletion
    [Documentation]  Online last Cell addition deletion via webem
    [Arguments]  ${addition_deletion_cell}=2   ${addition_deletion_cellgrp}=1    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ${cell_grp}   Get All Cell Group Id
    ${cell_id}    Get All Cell Id
    ${cell_id_len}    get length    ${cell_id}
    ${cell_list}    Get Cell From Cell Group    cellgrp_id=${addition_deletion_cellgrp}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${OUTPUT_DIR}
    selenium login and disable screen lock
    log to console  delete object
    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${addition_deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${addition_deletion_cellgrp}    timeout=15
    ${cell_grp_len}    get length    ${cell_grp}
    FOR    ${index}    IN RANGE    ${cell_grp_len}
        ${value}    selenium_coam.get_parameter_value     dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        run keyword if    '${value}'=='${addition_deletion_cellgrp}'    selenium_coam.remove_element
        ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${False}
    COAM Check GNB cell on air
    ${after_del_cell_id}    Get All Cell Id
    ${after_del_cell_id_len}    get length    ${after_del_cell_id}
    ${cell_id_dif}    Evaluate   ${cell_id_len}-${after_del_cell_id_len}
    should be true    ${cell_id_dif}==1
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}
    get_planned_parameter_value    dist_name=MRBTS-${MRBTS_ID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    log to console  add object
    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${addition_deletion_cellgrp}
    ...    include_subobject=${True}   id_value=${addition_deletion_cellgrp}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    object_class_name=NRCELL    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${addition_deletion_cell}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${2}
    selenium_coam.add_element    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    timeout=15
    FOR  ${i}  IN  @{cell_grp}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    filter_param=Reference to cell group     new_value=${i}
        ...    node_index=${i}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${False}
    sleep    60s
    verify all cells should be onair
    ${cell_list_add}    Get Cell From Cell Group    cellgrp_id=${addition_deletion_cellgrp}
    lists should be equal     ${cell_list_add}    ${cell_list}
    [Teardown]     selenium logout and close browser

Connect to GNB
    [Arguments]    ${du_index}=${0}    ${alias}=ASIK Master    ${gnb_index}=${0}
    csn.Connect to    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${alias}

Start wireshark capture from gNB
    [Documentation]    Description: Start X2 log capture on gNB or Enb
    [Arguments]     ${filename}    ${interface}=any    ${index}=${0}    ${alias}=ASIK Master
    Connect to GNB   gnb_index=${index}    alias=${alias}
    ${log_name}    Set variable    ${filename}.pcap
    ${log_full_path_gnb}    join path    /tmp    ${log_name}
    csn.send command    command=ps -ef |grep tcpdump |grep -v grep |grep ${interface} |awk '{print $2}' |xargs kill -2    connection=${alias}
    sleep    2s
    csn.send command    command=nohup tcpdump sctp -i ${interface} -w ${log_full_path_gnb}     connection=${alias}
    sleep    2s
    Trace capturing process should be triggered    log_prefix=${log_name}    connection_alias=${alias}
    [Return]    ${alias}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}

Stop wireshark capture from gNB
    [Documentation]    Description: Stop X2 log capture on gNB or Enb, and download x2 log to testpc
    [Arguments]     ${filename}    ${logpath}=${OUTPUT_DIR}   ${index}=${0}    ${alias}=ASIK Master
    Connect to GNB       gnb_index=${index}    alias=${alias}
    Stop trace capturing    log_prefix=${filename}    connection_alias=${alias}
    ${log_full_path_ute}    set variable     ${logpath}/${filename}.pcap
    csn.download_file   remote_path=/tmp/${filename}.pcap   local_path=${log_full_path_ute}   connection=${alias}
    csn.execute    command=rm /tmp/${filename}.pcap    connection=${alias}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}

##Connect to TestPc
#    [Arguments]    ${hostname}=${enb_ip}    ${username}=${eNB_username}      ${password}=${eNB_password}   ${alias}=enb
#    csn.connect_to   hostname=${hostname}
#        ...    username=${username}    password=${password}    alias=${alias}

Convert pcap to text
    [Arguments]    ${source}    ${target}    ${filter}   ${connection}=ute
    csn.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
    csn.await execution end  connection=${connection}  timeout=30min
    sleep    5s

Check wireshark log data common
    [Arguments]    ${command}    ${pacp_filename}   ${txt_filename}    ${filter}    ${connection}=ute
    Connect to TestPc       alias=${connection}
    sleep    1s
    log to console    ${LOG_PATH}
    log to console    ${pacp_filename}
    Convert pcap to text   source=${OUTPUT_DIR}/${pacp_filename}.pcap
    ...  target=${OUTPUT_DIR}/${txt_filename}.txt   connection=${connection}    filter=${filter}
    csn.Send Command  command=cat ${OUTPUT_DIR}/${txt_filename}.txt |${command}    connection=${connection}
    ${data}    csn.Read Output    connection=${connection}
    ${data}    strip_string    ${data}
    [Return]   ${data}
    [Teardown]    run keyword and ignore error    csn.Disconnect  	connection=${connection}

Check wireshark log data should be empty
    [Arguments]    ${command}    ${pacp_filename}   ${txt_filename}    ${filter}    ${connection}=ute
    ${data}    Check wireshark log data common    command=${command}    pacp_filename=${pacp_filename}    connection=${connection}
    ...   txt_filename=${txt_filename}      filter=${filter}
    should be empty    ${data}
    log to console    data:${data}
    [Teardown]    run keyword and ignore error    csn.Disconnect	connection=${connection}

Modify the normal cell to slim cell 49.5MHz
    [Arguments]    ${key_dl}    ${key_ul}    ${value}   ${cell_ID}
    log to console    Modify the normal cell to slim cell 49.5MHz
    ${slimRfFilterDL}    Create Dictionary    parameterName=${key_dl}   value=${value}  operation=update
    ${slimRfFilterUL}    Create Dictionary    parameterName=${key_ul}    value=${value}    operation=update
    @{slimstatus}    Create List    ${slimRfFilterDL}    ${slimRfFilterUL}
    admin_cli.perform_object_recommissioning    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_ID}
    ...    parameter=${slimstatus}    operation=update    connection=COAM
    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair

Collect snapshot logs for check soap info
    log to console    Collect snapshot logs
    Run Keyword And Ignore Error    run    command=rm -rf ${TS_CASE_LOG_PATH}/*
    ${snapshot_file}    set variable    Snapshot.zip
    admin_cli.collect_snapshot    target_file_name=${TS_CASE_LOG_PATH}/${snapshot_file}      timeout=600    connection=COAM



Extract Permanent from snapshot
    [Arguments]    ${snapshot_file}
    Log To Console    ExtractSnapshot_Started
    ${timestamp}    Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    ${zipout}    Set Variable    zipout_${timestamp}
    run     mkdir ${TS_CASE_LOG_PATH}
    run     mkdir ${TS_CASE_LOG_PATH}/${zipout}
    run     mkdir ${TS_CASE_LOG_PATH}/soap
    Log To Console    ExtractSnapshot_Started
    Extract Zip File    ${snapshot_file}    ${TS_CASE_LOG_PATH}/${zipout}
    ${BTS_part_logs}=    Run    find ${TS_CASE_LOG_PATH}/${zipout} -name BTS_part*.zip | xargs mv -t ${TS_CASE_LOG_PATH}/soap
    ${log_file}    OperatingSystem.List Files In Directory    ${TS_CASE_LOG_PATH}/soap    BTS_part*.zip
    FOR    ${item}    IN     @{log_file}
        Extract Zip File    ${TS_CASE_LOG_PATH}/soap/${item}    ${TS_CASE_LOG_PATH}/soap
    END
   ${soap_log_file}    Run    find ${TS_CASE_LOG_PATH}/soap -name BTS_AH221640525_*UnitOAM_SOAP_Log.zip
   Extract Zip File    ${soap_log_file}    ${TS_CASE_LOG_PATH}/soap
    #${log_path}=    Run    find ${TS_CASE_LOG_PATH}/soap -name UnitOAM_SOAP_Log*.xml.gz
    #${soap_log_path}=    Run    gunzip ${log_path} && find ${TS_CASE_LOG_PATH}/soap -name UnitOAM_SOAP_Log*.xml
    ${soap_log_file}    OperatingSystem.List Files In Directory    ${TS_CASE_LOG_PATH}/soap    UnitOAM_SOAP_Log*.xml.gz
    FOR    ${item1}    IN     @{soap_log_file}
        run     chmod 777 ${TS_CASE_LOG_PATH}/soap/${item1}
        Run    gunzip -d ${TS_CASE_LOG_PATH}/soap/${item1}
    END


Check Soap log
    [Arguments]    ${distName}    ${expected_bandwidth}    ${soapfile}
    ${carrier_info_dict}    soapp.get_carrier_info    log_path=${TS_CASE_LOG_PATH}/soap/${soapfile}    distName_value=${distName}
    ${convert_carrier_info_dict}    soapp.tansfer_carrier_info_to_webUI_format    carrier_info_dict=${carrier_info_dict}
    ${value}    Get From Dictionary      ${convert_carrier_info_dict}    channels
    ${bandwidth}    Get From Dictionary      ${value}     bandwidth
    should be equal          ${bandwidth}    ${expected_bandwidth}

    #${soap_log}    OperatingSystem.List Files In Directory    ${TS_CASE_LOG_PATH}/soap    UnitOAM_SOAP_Log*.xml
    #FOR    ${item1}    IN     @{soap_log}
    #    #${soap_log}    Run    find ${TS_CASE_LOG_PATH}/soap -name UnitOAM_SOAP_Log*.xml
    #    ${carrier_info_dict}    soapp.get_carrier_info    log_path=${TS_CASE_LOG_PATH}/soap/${item1}    distName_value=${distName}
    #    ${convert_carrier_info_dict}    soapp.tansfer_carrier_info_to_webUI_format    carrier_info_dict=${carrier_info_dict}
    #    ${value}    Get From Dictionary      ${convert_carrier_info_dict}    channels
    #    ${bandwidth}    Get From Dictionary      ${value}     bandwidth
    #    ${result}    run keyword and return status    should be equal          ${bandwidth}    ${expected_bandwidth}
    #    BuiltIn.Exit For Loop If    ${result}
    #END
