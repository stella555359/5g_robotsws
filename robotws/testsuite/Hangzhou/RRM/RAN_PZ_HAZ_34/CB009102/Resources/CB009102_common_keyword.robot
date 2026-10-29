*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04

Library     BuiltIn
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/tti_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_Trace_Analysis_MMW4.py
Library     TTI_Trace_Analysis_MMW4.TTI_Trace_analysis    WITH NAME    TTI_Trace
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_stream_Analysis_MMW4.py
Library     TTI_stream_Analysis_MMW4.TTI_Stream_analysis    WITH NAME    TTI_Stream
Library     taf.transport.ssh      WITH NAME    ssh
Library     taf.sbts.oam.coam.admin       WITH NAME    coam
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     ../../CB007306_OTA/Resources/CB007306_common.py
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF_NEW/Resource/UUF_LogCollection.robot
Variables     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF_NEW/Config/UUF_Vars.py




*** Variables ***
${CURDIR_path}            ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}
${gNB_ip}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gnb_ssh_username}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${gnb_ssh_password}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${ul_power_port_list}     ${tl.ues[0].iperf_details.ports[0:3]}
${dl_power_port_list}     ${tl.ues[0].iperf_details.ports[3:6]}
${control_pc}             ${tl.ues[0].ssh_connection_details.addr}
${control_pc_name}        ${tl.ues[0].ssh_connection_details.username}
${control_pc_pass}        ${tl.ues[0].ssh_connection_details.password}
${control_pc1}            ${tl.ues[2].ssh_connection_details.addr}
${control_pc1_name}       ${tl.ues[2].ssh_connection_details.username}
${control_pc1_pass}       ${tl.ues[2].ssh_connection_details.password}
${ue_type}                xiaomi
${iperf_addr}             ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${TS_CASE_LOG_PATH}       ${output_dir}
${att_ipaddr}             ${tl.attenuator.ip_addr}
${att_api_port}           ${tl.attenuator.port}
${UTE_ADDRESS}            ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}           ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}           ${tl.test_pc.default_ssh_connection_details.password}
${luashark_path}          /opt/ute/luashark/generated_luashark
@{ru_serial_list}             EB1944R0610




*** Keywords ***
########### setup KW #################
Case13 Suit Setup
    robot_common_operations.Common Suite Setup
    Set default SCF    bts_host=${gNB_ip}    gnb_index=${0}
    Setup Commission SCF    bts_host=${gNB_ip}    gnb_index=${0}
    CB009102_common_keyword.Check GNB on air    bts_host=${gnb_ip}

Case Teardown
    [Arguments]  ${hostname}=${control_pc}    ${username}=${control_pc_name}    ${password}=${control_pc_pass}
    Run keyword and ignore error    detach samsung ue
    ${xiaomi_ue_index_list}    create list    ${0}
    Run keyword and ignore error    Xiaomi12 UE Detach    ue_index_list=${xiaomi_ue_index_list}    hostname=${hostname}
    ...    username=${username}    password=${password}
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Capture LMI Log    gnb_index=${0}    ru_serial_list=${ru_serial_list}
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Save Snapshot    bts_host=${gNB_ip}
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown

detach samsung ue
    [Arguments]    ${ue_index}=${1}
    log to console      UE Detach    console=yes
    Set Suite Variable    ${brand}    samsung
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${brand}
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${brand}

########### check bts on air #################
Set default SCF
    [Arguments]      ${bts_host}=${gNB_ip}    ${gnb_index}=${0}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    separator=_
    ${version_scf}    run keyword if    '${version_list[2]}'=='9999'    Set Variable    SBTS00
    ...    ELSE   Set Variable    ${version_list[0]}
    ${default_scf_path}    set variable    ${CURDIR_path}/gNB${gnb_index}_SCF_${version_scf}.xml
    set suite variable    ${default_scf_path}
    log to console   ${default_scf_path}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Setup Commission SCF
    [Arguments]  ${bts_host}=${gNB_ip}    ${gnb_index}=${0}    ${connection}=GNB_OAM
    Set default SCF    bts_host=${bts_host}    gnb_index=${gnb_index}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf_path}    connection=${connection}    timeout=400
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check GNB on air
    [Timeout]    20 min
    [Arguments]  ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
#    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air    connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}


########## modify parameter ###################
Modify Value On DU
    [Arguments]    ${structure_modify_list}=None    ${common_modify_list}=None    ${keywords_list}=None    ${connection}=coam_admin
    ...    ${class_name}=None   ${is_structure}=${True}    ${is_common}=${True}    ${structure_index}=0
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    run keyword if  ${is_structure}    Modify Structure parameter via Coam    class_name=${class_name}   connection=${connection}
    ...    modify_list=${structure_modify_list}    keywords_list=${keywords_list}    index=${structure_index}
    run keyword if  ${is_common}    CB009102_common_keyword.Modify Common parameter via Coam    input_list=${common_modify_list}
    ...    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Modify Structure parameter via Coam
    [Arguments]   ${class_name}   ${modify_list}   ${keywords_list}    ${index}=0    ${connection}=GNB_OAM
    ${get_managed_objects}     coam.get_managed_objects     class_name=${class_name}    connection=${connection}
    ${output_dict_list}    Return_Structure_Mofify_Value    input_list=${get_managed_objects}    modify_list=${modify_list}
    ...    keywords_list=${keywords_list}    index=${index}
    FOR    ${item}  IN  @{output_dict_list}
        ${dict_value}    Get Content From Input Dict    input_dict=${item}
        coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
        ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
        sleep  2min
    END

Modify Common parameter via Coam
    [Arguments]  ${input_list}    ${connection}
    FOR    ${item}  IN    @{input_list}
        ${dict_value}    Get Content From Input Dict    input_dict=${item}
        coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
        ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
        sleep  2min
    END

Get Content From Input Dict
    [Arguments]  ${input_dict}
    ${dist_name}    get from dictionary     ${input_dict}    dist_name
    ${parammeter}    get from dictionary    ${input_dict}    parameter
    ${new_value}     get from dictionary    ${input_dict}    value
    ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
    [Return]  ${value_list}

############# UE attach relevant ###################
Xiaomi12 click airplane tiwce
    [Arguments]  ${ue_index}    ${serial_number}    ${connection}=cygwin
    FOR    ${item}   IN RANGE   ${2}
        unlock the screen and click airplane    ue_index=${ue_index}   serial_number=${serial_number}   connection=${connection}
    END

Xiaomi12 Verify Airplane Status
    [Arguments]    ${serial_number}    ${connection}=cygwin
    ssh.send_command    command=adb -s ${serial_number} shell settings get global airplane_mode_on   connection=${connection}
    sleep   2s
    ${airplane_status}    ssh.Read Output    connection=${connection}
    @{airmode_status}    Split String    ${airplane_status}    \r\n
    ${status}    Set Variable If    '${airmode_status[0]}'=='0'    ${False}    ${True}
    [Return]  ${status}

Xiaomi12 Attach UE
    [Arguments]  ${ue_index}     ${serial_number}    ${connection}=cygwin
    ${status}    Xiaomi12 Verify Airplane Status    serial_number=${serial_number}    connection=${connection}
    Run Keyword If    ${status}    unlock the screen and click airplane    ue_index=${ue_index}   serial_number=${serial_number}
    ...    connection=${connection}
    ${status}    Xiaomi12 Verify Airplane Status    serial_number=${serial_number}    connection=${connection}
    Run Keyword If    ${status}    unlock the screen and click airplane    ue_index=${ue_index}   serial_number=${serial_number}
    ...    connection=${connection}
    ${status}    Xiaomi12 Verify Airplane Status    serial_number=${serial_number}    connection=${connection}
    log to console    Airmode:${status}

Xiaomi12 Attach And Verify attach
    [Arguments]  ${ue_index_list}     ${hostname}=${control_pc}    ${username}=${control_pc_name}    ${password}=${control_pc_pass}
    ...    ${connection}=cygwin
    ssh.Connect to    hostname=${hostname}    username=${username}    password=${password}    alias=${connection}
    ...    look_for_keys=${False}
    FOR    ${ue_index}    IN    @{ue_index_list}
        ${serial_number}    set variable    ${tl.ues[${ue_index}].serial_number}
        ${status}    Xiaomi12 Verify Airplane Status    serial_number=${serial_number}    connection=${connection}
        run keyword if    ${status}    wait until keyword succeeds    4X    2min    Xiaomi12 Airplane Status Should Be
        ...    ue_index=${ue_index}    serial_number=${serial_number}    airmode_status=${False}    connection=${connection}
    END
    [Teardown]  Run Keyword And Ignore Error    ssh.Disconnect    connection=${connection}

Xiaomi12 UE Detach
    [Arguments]  ${ue_index_list}     ${hostname}=${control_pc}    ${username}=${control_pc_name}    ${password}=${control_pc_pass}
    ...    ${connection}=cygwin
    ssh.Connect to    hostname=${hostname}    username=${username}    password=${password}    alias=${connection}
    ...    look_for_keys=${False}
    FOR    ${ue_index}    IN    @{ue_index_list}
        ${serial_number}    set variable    ${tl.ues[${ue_index}].serial_number}
        ${status}    Xiaomi12 Verify Airplane Status    serial_number=${serial_number}    connection=${connection}
        run keyword if    ${status}==${False}    wait until keyword succeeds    4X    2min    Xiaomi12 Airplane Status Should Be
        ...    ue_index=${ue_index}    serial_number=${serial_number}    airmode_status=${True}    connection=${connection}
    END
    [Teardown]  Run Keyword And Ignore Error    ssh.Disconnect    connection=${connection}

Xiaomi12 Airplane Status Should Be
    [Arguments]    ${ue_index}    ${serial_number}    ${airmode_status}    ${connection}=cygwin
    unlock the screen and click airplane    ue_index=${ue_index}   serial_number=${serial_number}  connection=${connection}
    sleep   2s
    ssh.send_command    command=adb -s ${serial_number} shell settings get global airplane_mode_on   connection=${connection}
    sleep   2s
    ${airplane_status}    ssh.Read Output    connection=${connection}
    @{airmode_status_tmp}    Split String    ${airplane_status}    \r\n
    ${status}    Set Variable If    '${airmode_status_tmp[0]}'=='0'    ${False}    ${True}
    Should Be True    '${airmode_status}'=='${status}'

unlock the screen and click airplane
    [Documentation]   Check UE if need awake
    [Arguments]   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}   ${connection}=cygwin
    Get all xiaomi12 pointer variable
    ssh.send_command   connection=${connection}
    ...   command=adb -s ${serial_number} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"
    sleep   2s
    ${output}   ssh.read_output   connection=${connection}
    Run Keyword If   ${output.lower().count('mawake=false')}>0
    ...   ssh.send_command   command=adb -s ${serial_number} shell input keyevent 26   connection=${connection}
    ssh.send_command   command=adb -s ${serial_number} shell input swipe 347 2514 715 400    connection=${connection}
    sleep    2s
    ssh.send_command   command=adb -s ${serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS    connection=${connection}
    sleep    2s
    ssh.send_command   command=adb -s ${serial_number} shell dumpsys window | grep FocusedWindow    connection=${connection}
    sleep    2s
    ssh.send_command   command=adb -s ${serial_number} shell input tap ${airplane}    connection=${connection}
    sleep    2s
    ssh.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=${connection}
    sleep   2s
    ssh.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=${connection}
    sleep   4s
    ssh.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=${connection}

Get all xiaomi12 pointer variable
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${airplane}    932 1633
    Set Suite Variable    ${close_task}   717 2920
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960
    Set Suite Variable    ${ue_type}    xiaomi
    Set Suite Variable    ${brand}    Xiaomi

start power ue traffic ul and dl
    [Arguments]     ${ue_index_list}    ${hostname}=${control_pc}    ${username}=${control_pc_name}    ${password}=${control_pc_pass}
    ...    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000    ${protocol}=udp
    ssh.Connect to    hostname=${hostname}    username=${username}    password=${password}    alias=cygwin
    ...    look_for_keys=${False}
    Log To Console   \n
    FOR    ${item}    IN   @{ue_index_list}
        log to console      .....UE_${item} udp ul iperf start....
        ${serial_number}    Set Variable    ${tl.ues[${item}].serial_number}
        ${ul_command}=    Catenate
        ...    adb -s ${serial_number} shell /data/local/tmp/iperf -c ${iperf_addr} -u -p ${ul_power_port_list}[${item}]
        ...    -t ${ul_duration} -P 1 -i 1 -f m -b ${ul_throughput} -l 1024B -T 64 -w 2M
        run keyword and continue on failure    ssh.send_command    command=${ul_command}    connection=cygwin
    END
    ssh.Disconnect    connection=cygwin
    sleep    1s
    FOR    ${item}    IN   @{ue_index_list}
        run keyword and continue on failure     power_ue.Start traffic    ue_index=${item}    direction=dl    throughput=${dl_throughput}
        ...    duration=${dl_duration}    ue_type=${ue_type}    protocol=${protocol}    iperf_port=${dl_power_port_list}[${item}]
    END

Check xiaomi UE throughput
    [Arguments]     ${if_ul}=${True}    ${if_dl}=${True}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=60
    ...    ${dl_duration}=60    ${protocol}=udp    ${gnb_index}=${0}    ${cells}=${185473}
    log to console      Check UL / DL  throughput
    log to console    ul:${ul_duration},dl:${dl_duration},protocol:${protocol}
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check throughput    gnb_index=${gnb_index}
    ...    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}     cellid=${cells}
    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check throughput    gnb_index=${gnb_index}
    ...    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}     cellid=${cells}


UE Check Throughput
    [Arguments]   ${exp_ul_tp}    ${exp_dl_tp}    ${ul_list}    ${dl_list}    ${if_ul}=${True}    ${if_dl}=${True}    ${log_time}=1m
    ${log_path}    power_ue.Collect Tput   ue_type=${ue_type}    duration=${log_time}    ignore_time=10s
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${exp_ul_tp}    target_avg_percent=0.95
    ...    actCarrierAggregation=${True}
    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${exp_dl_tp}    target_avg_percent=0.95
    ...    actCarrierAggregation=${True}

stop multi power ue traffic ul and dl
    [Arguments]    ${ue_index_list}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console     Stop traffic    console=yes
    FOR    ${item}    IN    @{ue_index_list}
        run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=${ue_type}    iperf_type=via_command
        ...    protocol=${protocol}    iperf_port=${ul_power_port_list}[${item}]
        run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=${ue_type}   protocol=${protocol}
        ...    iperf_port=${dl_power_port_list}[${item}]
    END

############# TTI log ###################
Capture TTI log
    [Arguments]    ${log_time}=3    ${bts_ip}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${csv_path}    Capture And Decode TTitrace    duration=${log_time}
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    ${UL_DL_csv_file_path_dict}=  Create Dictionary
    ...    DL=${csv_path}/tcpdump_ttitrace_dl.csv
    ...    UL=${csv_path}/tcpdump_ttitrace_ul.csv
    [Return]  ${UL_DL_csv_file_path_dict}

Check TTI Log For Case04
    [Arguments]    ${UL_DL_csv_file_path_dict}    ${direction}
    ${csv_path}    Get From Dictionary    ${UL_DL_csv_file_path_dict}    ${direction}
    ${csv_path}    replace_csv_content    file_path=${csv_path}
    ${sfn_list}    ${slot_list}    TTI_Trace.get_sfn_slot_according_fdSchedData    file_path=${csv_path}    direction=${direction}
    ${result1}    Check_sfn_even_numbers_slot    sfn_list=${sfn_list}    slot_list=${slot_list}
    ${result2}    Check_sfn_Dividing_eight_slot    sfn_list=${sfn_list}    slot_list=${slot_list}
    Run Keyword And Continue On Failure    Should Be Equal    ${result1}     ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${result2}    ${True}

Check TTI Log For Case13
    [Arguments]    ${UL_DL_csv_file_path_dict}    ${direction}    ${msc_expect_value}    ${prb_sum_expect_value}
    ${csv_path}    Get From Dictionary    ${UL_DL_csv_file_path_dict}    ${direction}
    ${sfn_list}    ${slot_list}    ${rnti_list}    ${msc_list}    ${prb_list}     TTI_Stream.get_sfn_slot_rnti_mscTable_prb
    ...    file_path=${csv_path}    direction=${direction}
    ${msc_value}    Check_msc_list    msc_list=${msc_list}    expect_value=${msc_expect_value}
    ${prb_sum_value}    Check_Two_Rnti_Prb_Sum    sfn_list=${sfn_list}    slot_list=${slot_list}    rnti_list=${rnti_list}
    ...    prb_list=${prb_list}    expect_vaule=${prb_sum_expect_value}
    Run Keyword And Continue On Failure    Should Be Equal    ${msc_value}     ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${prb_sum_value}    ${True}

Check Release Larged Than Given
    [Arguments]    ${release}=24R1    ${gnb_index}=${0}    ${connection}=GNB_OAM2
    ${Y_given_string}=    Get SubString    ${release}    0    2
    ${R_given_string}=    Get SubString    ${release}    3    4
    ${Y_given}    Evaluate    int(${Y_given_string})
    ${R_given}    Evaluate    int(${R_given_string})
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${software}    coam.get_software_info    connection=${connection}
    ${activate_version}    Set Variable    ${software}[Active SW version]
    ${Y_active_string}=    Get SubString    ${activate_version}    4    6
    ${R_active_string}=    Get SubString    ${activate_version}    7    8
    ${Y_active}    Evaluate    int(${Y_active_string})
    ${R_active}    Evaluate    int(${R_active_string})
    ${Is_large}    Set variable if    ${Y_active}>${Y_given}    ${True}
    ...    ${Y_active}==${Y_given} and ${R_active}>${R_given}    ${True}    ${False}
    [Return]    ${Is_large}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections  connection=${connection}

##############  Log #########################
_get_PID
    [Arguments]    ${connection}    ${command}
    Log To Console    Get PID
    ssh.send_command    command=${command}   connection=${connection}
    ${PID}    ssh.read output    connection=${connection}
    ${PID}    strip_string    ${PID}
    should not be empty    ${PID}
    [Return]    ${PID}

Start Catch Trace Log
    [Arguments]    ${bts_host}    ${filename}   ${time}=3s    ${connection}=GNB_SSH
    Log To Console    Start Catch Trace Log
    ssh.Connect to    hostname=${bts_host}    username=${gnb_ssh_username}   password=${gnb_ssh_password}    alias=${connection}
    sleep    2s
    ssh.send_command    command=tcpdump sctp -i any -w /tmp/${filename} &   connection=${connection}
    sleep    ${time}
    [Teardown]  ssh.disconnect    connection=${connection}

Stop And Copy Log To UTE
    [Arguments]    ${bts_host}    ${filename}    ${connection}=GNB_SSH
    Log To Console    Stop And Copy Log To UTE
    ssh.Connect to    hostname=${bts_host}    username=${gnb_ssh_username}   password=${gnb_ssh_password}    alias=${connection}
    sleep    2s
    ${PID}    wait until keyword succeeds    1min    2s    _get_PID    connection=${connection}
    ...    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'
    Log To Console    kill PID
    ssh.send_command    command=kill -9 ${PID}    connection=${connection}
    Log To Console    download file to local
    ssh.download_file    remote_path=/tmp/${filename}    local_path=${TS_CASE_LOG_PATH}/${filename}    connection=${connection}
    sleep    10s
    [Teardown]    ssh.disconnect    connection=${connection}

Convert pcap to text
    [Arguments]    ${source}    ${target}    ${filter}
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=UTE
    Log To Console    Convert pcap to text
    ssh.send_command
    ...    command=tshark -X lua_script:${luashark_path} -V -r ${source} -T text -Y ${filter} > ${target}
    ...    connection=UTE
    ssh.await execution end    connection=UTE    timeout=10min
    [Teardown]    ssh.disconnect    connection=UTE

Check Attach PCI
    [Arguments]  ${text_name}    ${attached_pci}    ${pci_id}
    Log To Console    Check Attach PCI
    ${result}    Check_Wireshark_Attach_PCI_From_Txt    txt_path=${TS_CASE_LOG_PATH}/${text_name}    expect_value=${pci_id}
    ...    parameters=${attached_pci}
    should be equal as strings    ${result}    True

Check Target PCI And Flow Message
    [Arguments]    ${pcap_name}    ${text_name}    ${attached_pci}    ${message_dict}    ${pci_id}
    ${filter}=    CATENATE    f1ap || ngap
    Convert pcap to text    source=${TS_CASE_LOG_PATH}/${pcap_name}    target=${TS_CASE_LOG_PATH}/${text_name}   filter="${filter}"
    Check Attach PCI    text_name=${text_name}    attached_pci=${attached_pci}    pci_id=${pci_id}
    Check Flow Message    text_name=${text_name}    message_dict=${message_dict}

Check Flow Message
    [Arguments]    ${text_name}    ${message_dict}
    Log To Console    Check Flow Message
    ${result}    Check Wireshark Message Flow From Txt    txt_file_path=${TS_CASE_LOG_PATH}/${text_name}    message_dict=${message_dict}
    should be equal as strings    ${result}    True

############### Case Step ########################
Capture LMI Log
    [Arguments]    ${gnb_index}    ${ru_serial_list}    ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}
    Log To Console   //TODO: UUF Catch RU Log
    Log To Console   ${RU_LOG_FLAG}
    ${log_dir_not_exist}   Run Keyword And Return Status   OperatingSystem.Directory Should Not Exist   ${log_dir}
    Run Keyword If   ${log_dir_not_exist}   OperatingSystem.Create Directory   ${log_dir}
    ${RU_serial_pc_info}    UUF Get RU PC Info Accordind To Serial    ru_serial_list=${ru_serial_list}
    UUF Catch RU Log From LMI    testline=gnb_${gnb_index}    ru_list=${RU_serial_pc_info}