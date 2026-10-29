*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com

Library    taf.transport.ssh            WITH NAME    ssh
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.analyzer.pdml            WITH NAME    cpdml
Library    taf.sbts.oam.coam.admin      WITH NAME    coam
Library    taf.collectors.btslog        WITH NAME    btslog
Library    taf.hw.rf_attenuator         WITH NAME       att
Library    String
Library    Collections
Library    OperatingSystem
Library    Process
Library    XML
Library    DateTime
Library    Telnet
Library    ../../CB007306_OTA/Resources/CB007306_common.py
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    ./variable_8325A.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007306_OTA/Resources/CB007306_common_keyword.robot
Variables   ./8325A_para.py


*** Keywords ***
SBTS Login
    [Arguments]    ${ip_address}=${DU_OAM_IP}    ${username}=${DU_OAM_WEBUI_USER}
    ...    ${password}=${DU_OAM_WEBUI_PASSWORD}    ${alias}=default
    [Documentation]   SBTS Login
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}    connection=${alias}
    ${connection}    set variable    ${alias}
    [Return]    ${connection}

SBTS Logout
    [Arguments]   ${alias}=default
    [Documentation]   SBTS Logout
    coam.Teardown    connection=${alias}

WEBUI Login
    [Arguments]      ${virtual_enable}=${True}     ${version}=5G21B
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login
    Log To Console  Try to login...
    selenium_coam.Enable_Virtual_Display
    selenium_coam.Login    url=${DU_OAM_WEBUI_URL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
    ...     version=${version}
    Log To Console  Login successfully...
    Run Keyword And Ignore Error      selenium_coam.Disable_Message_Box
    Sleep    15s
    selenium_coam.disable_screen_lock
    Log To Console  END:WEBUI Login!

WEBUI Logout
    [Arguments]     ${virtual_disable}=${True}
    [Documentation]   WEBUI Logout
    Log To Console  Try to logout...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Enable_Virtual_Display
    Run Keyword And Ignore Error  selenium_coam.Logout
    Log To Console  Logout successfully...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Disable_Virtual_Display
    Sleep    3s
    Log To Console  END:WEBUI Logout!

Check BTS Should Be Normal
    [Arguments]    ${DU_OAM_IP}=${DU_OAM_IP}
    Log To Console  Check BTS Should Be Normal
    SBTS Login        ip_address=${DU_OAM_IP}
    Wait Until BTS Should Be Normal
    [Teardown]   Run Keyword And Ignore Error   SBTS Logout

Wait Until BTS Should Be Normal
    [Arguments]    ${alias}=default    ${retry}=1000s    ${retry_interval}=10s
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Gnb Cell Should Be Onair    alias=${alias}

Gnb Cell Should Be Onair
    [Arguments]    ${alias}=default    ${cell_type }=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${operationalState}    Get From Dictionary    ${status}    operationalState
    should be equal as strings    ${operationalState}    Enabled    ignore_case=${True}
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    should be equal as strings    ${blockingState}    Unblocked    ignore_case=${True}
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    should be equal as strings    ${proceduralState}    OnAir    ignore_case=${True}
    #cell info
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}    connection=${alias}
    FOR    ${item}    IN    @{cell_status}
        ${Status}    Get From Dictionary    ${item}    status
        ${tmp}   Get From Dictionary    ${status}    operationalState
        should be equal as strings    ${tmp}    Enabled    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  administrativeState
        should be equal as strings    ${tmp}    Unlocked    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  blockingState
        should be equal as strings    ${tmp}    Unblocked    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  usageState
        should be equal as strings    ${tmp}    Active    ignore_case=${True}
    END

suite setup to prepare default scf
    [Arguments]    ${SBTS_scf_name}    ${bts}    ${DU_OAM_IP}=${DU_OAM_IP}
    Log To Console    Set Default Scf
    ${connection}    SBTS Login    ip_address=${DU_OAM_IP}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_sbts_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${release}    set variable    ${version_list[0]}
    ${Branch_scf_name}    set variable    SCF_${release}_${bts}.xml
    ${default_scf}    set variable if    ${if_sbts_load}    ${default_scf_path}${SBTS_scf_name}
    ...    ${default_scf_path}${Branch_scf_name}
    log to console   ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${default_scf}

Commission Default SCF
    [Arguments]    ${default_scf}    ${DU_OAM_IP}=${DU_OAM_IP}
    Log To Console    Commission Default SCF
    ${connection}    SBTS Login    ip_address=${DU_OAM_IP}
    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}    timeout=500
    Wait Until BTS Should Be Normal
    [Teardown]    coam.Teardown   connection=${connection}

Adjust HBTE Attenuation
    [Arguments]    ${port_value1}    ${port_value2}   ${port_value3}    ${model}=${tl.attenuator.model}
    Log To Console    Adjust HBTE Attenuation
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}    model=${model}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation    port=${att_port_1}    value=${port_value1}
    att.set_attenuation    port=${att_port_2}    value=${port_value1}
    att.set_attenuation    port=${att_port_5}    value=${port_value2}
    att.set_attenuation    port=${att_port_6}    value=${port_value2}
    att.set_attenuation    port=${att_port_9}    value=${port_value3}
    att.set_attenuation    port=${att_port_10}    value=${port_value3}

Modify Parameter CBRA
    [Arguments]    ${ip_address}    ${Actual_value}    ${BTS_ID}    ${NRBTS_ID}    ${cell_idx}=${1}
    ${connection}    SBTS Login    ip_address=${ip_address}
    Log To Console    modify parameter
    ${dict}    create dictionary    parameterName=cbraPreamblesPerSsb    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_idx}    connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Log To Console    wait until bts normal
    Wait Until BTS Should Be Normal    alias=${connection}
    [Teardown]    SBTS Logout    alias=${connection}

_get_bts_counters
    [Arguments]    ${connection}    ${counter_ids}
    Log To Console    get bts counter
    ${result}    coam.get_PM_counters    counter_ids=${counter_ids}    connection=${connection}
    [Return]    ${result}

_get_confirmed_counter_value
    [Arguments]    ${counter_result}    ${counter_parameter}
    Log To Console    get counter value
    ${counter_list}    get dictionary values    ${counter_result${counter_parameter}}
    ${counter_value}    set variable    ${0}
    ${counter_list_len}    get length    ${counter_list}
    FOR    ${index}    IN RANGE    ${counter_list_len}
        ${counter_value}    evaluate    ${counter_value} + ${counter_list}[${index}]
    END
    [Return]    ${counter_value}

Get gNB1 Counter List
    [Arguments]    ${cell_idx}=${1}
    Log To Console    Get gNB1 Counter List
    ${connection}    SBTS Login    ip_address=${DU_OAM_IP}
    ${result}    _get_bts_counters    connection=${connection}    counter_ids=M55143C00001,M55143C00004,M55145C00341,M55145C00342
    ${MR_BTS}    set variable    MRBTS-${tl.gnbs[${0}].instance_id}
    ${NR_BTS}    set variable    NRBTS-${tl.gnbs[${0}].global_bts_id}
    ${is_large_24R1_release}    Check Release Larged Than Given    release=24R1    gnb_index=${0}
    ${counter_value001_parameter}    set variable if    ${is_large_24R1_release}
    ...    ['BTS']['${MR_BTS}']['${NR_BTS}']['NRCELL-${cell_idx}']['NXNCC']['M55143C00001']
    ...    ['BTS']['CELLS']['NRCELL-${cell_idx}']['NXNCC']['M55143C00001']
    ${counter_value001}    _get_confirmed_counter_value    counter_result=${result}    counter_parameter=${counter_value001_parameter}
    ${counter_value004_parameter}    set variable if    ${is_large_24R1_release}
    ...    ['BTS']['${MR_BTS}']['${NR_BTS}']['NRCELL-${cell_idx}']['NXNCC']['M55143C00004']
    ...    ['BTS']['CELLS']['NRCELL-${cell_idx}']['NXNCC']['M55143C00004']
    ${counter_value004}    _get_confirmed_counter_value    counter_result=${result}    counter_parameter=${counter_value004_parameter}
    ${counter_value341_parameter}    set variable if    ${is_large_24R1_release}
    ...    ['BTS']['${MR_BTS}']['${NR_BTS}']['NRCELL-${cell_idx}']['MCC-310']['MNC-260']['NRANS']['M55145C00341']
    ...    ['BTS']['CELLS']['NRCELL-${cell_idx}']['MCC-310_MNC-260']['NRANS']['M55145C00341']
    ${counter_value341}    _get_confirmed_counter_value    counter_result=${result}    counter_parameter=${counter_value341_parameter}
    ${counter_value342_parameter}    set variable if    ${is_large_24R1_release}
    ...    ['BTS']['${MR_BTS}']['${NR_BTS}']['NRCELL-${cell_idx}']['MCC-310']['MNC-260']['NRANS']['M55145C00342']
    ...    ['BTS']['CELLS']['NRCELL-${cell_idx}']['MCC-310_MNC-260']['NRANS']['M55145C00342']
    ${counter_value342}    _get_confirmed_counter_value    counter_result=${result}    counter_parameter=${counter_value342_parameter}
    ${counters_value_list}    create list    ${counter_value001}    ${counter_value004}    ${counter_value341}    ${counter_value342}
    [Return]    ${counters_value_list}
    [Teardown]    SBTS Logout    alias=${connection}

Get gNB2 Counter List
    [Arguments]    ${cell_idx}=${1}
    Log To Console    Get gNB2 Counter List
    ${connection}    SBTS Login    ip_address=${DU2_OAM_IP}
    ${result}    _get_bts_counters    connection=${connection}    counter_ids=M55143C00005,M55143C00006,M55145C00362,M55125C01501
    ${MR_BTS}    set variable    MRBTS-${tl.gnbs[${1}].instance_id}
    ${NR_BTS}    set variable    NRBTS-${tl.gnbs[${1}].global_bts_id}
    ${is_large_24R1_release}    Check Release Larged Than Given    release=24R1    gnb_index=${1}
    ${counter_value005_parameter}    set variable if    ${is_large_24R1_release}
    ...    ['BTS']['${MR_BTS}']['${NR_BTS}']['NRCELL-${cell_idx}']['NXNCC']['M55143C00005']
    ...    ['BTS']['CELLS']['NRCELL-${cell_idx}']['NXNCC']['M55143C00005']
    ${counter_value005}    _get_confirmed_counter_value    counter_result=${result}    counter_parameter=${counter_value005_parameter}
    ${counter_value006_parameter}    set variable if    ${is_large_24R1_release}
    ...    ['BTS']['${MR_BTS}']['${NR_BTS}']['NRCELL-${cell_idx}']['NXNCC']['M55143C00006']
    ...    ['BTS']['CELLS']['NRCELL-${cell_idx}']['NXNCC']['M55143C00006']
    ${counter_value006}    _get_confirmed_counter_value    counter_result=${result}    counter_parameter=${counter_value006_parameter}
    ${counter_value362_parameter}    set variable if    ${is_large_24R1_release}
    ...    ['BTS']['${MR_BTS}']['${NR_BTS}']['NRCELL-${cell_idx}']['MCC-310']['MNC-260']['NRANS']['M55145C00362']
    ...    ['BTS']['CELLS']['NRCELL-${cell_idx}']['MCC-310_MNC-260']['NRANS']['M55145C00362']
    ${counter_value362}    _get_confirmed_counter_value    counter_result=${result}    counter_parameter=${counter_value362_parameter}
    ${counter_value1501_parameter}    set variable if    ${is_large_24R1_release}
    ...    ['BTS']['${MR_BTS}']['${NR_BTS}']['NRCELL-${cell_idx}']['NNGCC']['M55125C01501']
    ...    ['BTS']['CELLS']['NRCELL-${cell_idx}']['NNGCC']['M55125C01501']
    ${counter_value1501}    _get_confirmed_counter_value    counter_result=${result}    counter_parameter=${counter_value1501_parameter}
    ${counters_value_list}    create list    ${counter_value005}    ${counter_value006}    ${counter_value362}    ${counter_value1501}
    [Return]    ${counters_value_list}
    [Teardown]    SBTS Logout    alias=${connection}

Single UE Attach
    [Arguments]    ${ue_type}=${ue_type}    ${ue_index}=${0}    ${attach_mode}=5G_SA
    Log To Console    Single UE Attach
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=${attach_mode}    ue_index=${ue_index}
    #Log To Console    Verify attach
    #power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}    5Grach_ed=${5Grach_ed_0}    4G_check=False

Start Traffic And Check Throughput
    [Arguments]    ${tp_ul}    ${tp_dl}    ${target_tp_ul}    ${target_tp_dl}    ${nrcell_id}    ${duration}=600    ${ue_mode}=SA
    ...    ${ue_index}=${0}    ${gnb_index}=${0}    ${port}=${0}    ${iperf_type_ul}=via_command    ${iperf_type_dl}=via_command
    Log To Console    start traffic
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul   throughput=${tp_ul}   ue_index=${ue_index}
    ...    duration=${duration}    ue_mode=${ue_mode}    iperf_port=${IPERF_portlist}[${port}]    iperf_type=${iperf_type_ul}    process_num=${3}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl   throughput=${tp_dl}    ue_index=${ue_index}
    ...    duration=${duration}    ue_mode=${ue_mode}    iperf_port=${IPERF_portlist}[${port}]    iperf_type=${iperf_type_dl}    process_num=${3}
    sleep    10s
    Log To Console    check throughput
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=${gnb_index}    duration=30s    ignore_time=5s
    ${cell_list}    create list    ${nrcell_id}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    log=${log_path}
    ...    cells=${cell_list}    target_throughput=${target_tp_ul}    min_percent=0
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    log=${log_path}
    ...    cells=${cell_list}    target_throughput=${target_tp_dl}    min_percent=0

Just Check Throughput
    [Arguments]    ${target_tp_ul}    ${target_tp_dl}    ${nrcell_id}    ${gnb_index}=${0}
    Log To Console    check throughput
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=${gnb_index}    duration=60s    ignore_time=5s
    ${cell_list}    create list    ${nrcell_id}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    log=${log_path}
    ...    cells=${cell_list}    target_throughput=${target_tp_ul}    min_percent=0
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    log=${log_path}
    ...    cells=${cell_list}    target_throughput=${target_tp_dl}    min_percent=0

Stop Traffic And UE Detach
    [Arguments]    ${ue_index}=${0}    ${port}=${0}    ${ue_mode}=SA
    Log To Console    stop traffic
    run keyword and continue on failure    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[${port}]    ue_mode=${ue_mode}
    run keyword and continue on failure    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[${port}]    ue_mode=${ue_mode}
    Log To Console    UE Detach
    [Teardown]   run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Start Catch Trace Log
    [Arguments]    ${DU_OAM_IP}    ${connection}    ${filename}   ${time}=3s
    Log To Console    Start Catch Trace Log
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}   password=${DU_OAM_SSH_PASSWORD}    alias=${connection}
    sleep    2s
    ssh.send_command    command=tcpdump sctp -i any -w /tmp/${filename} &   connection=${connection}
    sleep    ${time}

_get_PID
    [Arguments]    ${connection}    ${command}
    Log To Console    Get PID
    ssh.send_command    command=${command}   connection=${connection}
    ${PID}    ssh.read output    connection=${connection}
    ${PID}    strip_string    ${PID}
    should not be empty    ${PID}
    [Return]    ${PID}

Stop And Copy Log To UTE
    [Arguments]    ${DU_OAM_IP}    ${connection}    ${filename}    ${time}=10s
    Log To Console    Stop And Copy Log To UTE
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}   password=${DU_OAM_SSH_PASSWORD}    alias=${connection}
    sleep    2s
    ${PID}    wait until keyword succeeds    1min    2s    _get_PID    connection=${connection}
    ...    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'
    Log To Console    kill PID
    ssh.send_command    command=kill -9 ${PID}    connection=${connection}
    Log To Console    download file to local
    ssh.download_file    remote_path=/tmp/${filename}    local_path=${LOG_PATH}/${filename}    connection=${connection}
    sleep    ${time}
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
    [Arguments]    ${text_name}    ${attached_pci}
    Log To Console    Check Attach PCI
    ${result_dic}    Check_Wireshark_Parameter_From_Txt    txt_file_path=${LOG_PATH}/${text_name}
    ...    parameters=${attached_pci}
    ${result_list}    get from dictionary    ${result_dic}    resultList
    should be equal as strings    ${result_list}[0]    True

Check Flow Message
    [Arguments]    ${text_name}    ${message_dict}
    Log To Console    Check Flow Message
    ${result}    Check Wireshark Message Flow From Txt    txt_file_path=${LOG_PATH}/${text_name}    message_dict=${message_dict}
    should be equal as strings    ${result}    True

Make a VoNR call(+6688)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${during}=90s
    log to console    \n *** Make a VoNR call(+6688)
    ssh.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    ssh.send_command   connection=cygwin${ue_index}
    ...   command=adb -s ${serial_number} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"
    sleep   2s
    ${output}   ssh.read_output   connection=cygwin${ue_index}
    Run Keyword If   ${output.lower().count('mawake=false')}>0
    ...    ssh.send_command    command=adb -s ${serial_number} shell input keyevent 82    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    ssh.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin${ue_index}
    sleep   2s
    #####make VoNR call#####
    ssh.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688
    ...    connection=cygwin${ue_index}
    sleep    ${during}

hang up VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    log to console    \n *** hang up VoNR call
    ssh.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    ssh.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}

Wait for counter to be gathered after guard peroid
   [Arguments]  ${interval}=5
   ${list1}=    Create List         00  15  30  45
   ${list2}=    Create List         00  05  10  15  20  25  30  35  40  45  50  55
   ${list}=    Set Variable IF     '${interval}' == '5'    ${list2}    ${list1}
   ${actualTime}=     DateTime.Get Current Date    result_format=%M
   ...                                    time_zone=UTC
   ${time_check}    run keyword and return status   List Should Contain Value    ${list}    ${actualTime}
   run keyword if    ${time_check}   Sleep   ${interval} minutes
   comm_8325A.PM Wait To Nearest Measurement Period    interval=${interval}

PM Wait To Nearest Measurement Period
   Log    PM Wait To Nearest Measurement Period    console=yes
   [Arguments]  ${interval}
   Wait Until Keyword Succeeds                     16 min
   ...                                            1 min
   ...                                             comm_8325A.Wait For Right Period    interval=${interval}
   Sleep                                           60

Wait For Right Period
   [Arguments]  ${interval}
   ${list1}=           Create List         00  15  30  45
   ${list2}=           Create List         00  05  10  15  20  25  30  35  40  45  50  55
   ${list}=            Set Variable IF     '${interval}' == '5'    ${list2}    ${list1}
   ${actualTime}=     DateTime.Get Current Date    result_format=%M
   ...                                    time_zone=UTC
   ...                                    increment=8 hours
   ${actualHour}=     DateTime.Get Current Date    result_format=%H
   ...                                    time_zone=UTC
    ...                                    increment=8 hours
   ${date}=     DateTime.Get Current Date    result_format=%Y-%m-%d
   ...                                    time_zone=UTC
   ...                                    increment=8 hours
    ${date_nodash}=    DateTime.Get Current Date    result_format=%Y%m%d
   ...                                    time_zone=UTC
   ${actualEpoch}=    DateTime.Convert Date	       ${date} ${actualHour}:${actualTime}:00.000	epoch
   List Should Contain Value	           ${list}  ${actualTime}
   Log                                    ${actualTime}
   ${string_epoch}=   Convert To String   ${actualEpoch}
   ${nopoint_epoch}=   fetch from left   ${string_epoch}   .
   ${integer_epoch}=   convert to integer  ${nopoint_epoch}
   ${epoch_minus_interval}=   Evaluate   ${integer_epoch}-15*60
   ${epoch_minus_interval_string}=   Convert To String   ${epoch_minus_interval}
   set test variable    ${epoch_minus_interval_string}
