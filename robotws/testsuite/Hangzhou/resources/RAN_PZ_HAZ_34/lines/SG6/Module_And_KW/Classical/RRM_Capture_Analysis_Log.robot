*** Settings ***
Documentation
...    Author: Yang Mengli
...    Contact: mengli.yang@nokia-sbell.com
...    Common KWs related to collect and analysis log.

Resource    RRM_Common_Resource.robot



*** Keywords ***
#-------------------Btslog---------------------------------------------------------------------------------

Start Btslog Collect
    [Arguments]    ${names}=btslog    ${btslog_path}=/opt/btslog/btslog
    ...            ${btslog_launcher_path}=/opt/btslog/btslog_launcher    ${log_dir}=/tmp/btslog2
    [Documentation]    This KW is used to start collect btslog
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | names | No | the name of the folder which store the collected log |
    ...    | btslog_path | No | the path of btslog script |
    ...    | btslog_launcher_path | No | the path of btslog launcher script |
    ...    | log_dir | No | log collection path |

    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start Btslog Collect     ${names} |
    ...
    Log To Console    ${log_dir}
    btslog.Create Btslog Collector    name=${names}    btslog_path=${btslog_path}
    ...                               btslog_launcher_path=${btslog_launcher_path}
    btslog.Set Suite Alias    ${names}
    core.Setup Collectors    names=${names}
    core.Start Collectors    names=${names}

Stop Btslog Collect
    [Arguments]    ${names}=btslog
    [Documentation]    This KW is used to stop collect btslog
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | names | Yes | the name of the folder which store the collected log |
    ...
    ...    | Return Value | Description |
    ...    | btslog_name | the path of test collect btslog |
    ...
    ...    Example
    ...    | Stop Btslog Collect | ${names}=btslog |
    ...
    core.Stop Collectors    names=${names}
    core.Collect Collectors    names=${names}    target_dir=${TEST_LOG_DIRECTORY}
    core.Teardown Collectors    names=${names}
    ${btslog_name}    Join Path    ${TEST_LOG_DIRECTORY}    ${names}
    [Return]    ${btslog_name}

Check Btslog
    [Arguments]  ${btslog_prints}    ${btslog_name}    ${filter}
    [Documentation]    this kw is used to analysis btslog log
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | Aasyslog_prints | Yes | list some message which you need to check |
    ...    | btslog_name | Yes | set bts log name |
    ...    | filter | Yes | What is used to filter messages |
    ...
    ...    | Return Value | Description |
    ...    | ${output} | some context you filtered out |
    ...
    ...    Example
    ...    | Check Btslog | btslog_prints=${btslog_prints} | btslog_name=${btslog_name1} |
    ...     filter=ps::cell::CellSetupReq_t |
    ...
    Log    Checking BTS Syslog to confirm parameter change.    console=True
    OperatingSystem.Run    command=tar zxvf ${btslog_name}/syslog_files.tgz -C/${btslog_name}/
    ${output}    OperatingSystem.Run    command=cat ${btslog_name}/SYSLOG*.LOG | grep -a "${filter}" | grep -av grep
    Should Not Be Empty    ${output}
    FOR    ${print}    IN    @{btslog_prints}
         should contain    ${output}    ${print}
    END
    [Return]    ${output}
#-------------------Snapshot---------------------------------------------------------------------------------
Collect Coam Snapshot
    [Arguments]    ${gnb_id}=0    ${name}=gnb_coam_snapshot    ${coverage}=Full    ${force}=${True}
    ...            ${timeout}=900    ${port}=443
    [Documentation]    this kw is used to collect the snapshot files to the default path.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_id | Yes | gnb_id default value:0 |
    ...    | name | Yes | name of the collector. Ex: gnb_coam_snapshot |
    ...    | coverage | Yes | the output can add filter to aviod too large |
    ...    | force | Yes | force |
    ...    | timeout | No | timeout default:900 |
    ...    |  port | Yes | port default value:443 |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Collect Coam Snapshot    ${name} |
    ...
    Log    ${timeout} is not used
    COAM_Admin.Login    bts_host=${ASIB_IP}
    ...    username=${http_USERNAME}
    ...    password=${http_PASSWORD}
    ...    bts_port=${port}
    ...    alias=snapshot_bts${gnb_id}
    coam.Get Snapshot    target_file_name=${TEST_LOG_DIRECTORY}/${name}.zip
    ...    coverage=${coverage}
    ...    force=${force}
    ...    connection=snapshot_bts${gnb_id}
    [Teardown]    COAM_Admin.Logout    connection=snapshot_bts${gnb_id}

Save Coam Snapshot
    [Documentation]    this kw is used to save the snapshot files to the default path
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Save Coam Snapshot |
    ...
    coam.Get Snapshot    target_file_name=${TEST_LOG_DIRECTORY}/snapshot.zip    coverage=Full    force=True    connection=${coam_connection}

#-------------------wireshark---------------------------------------------------------------------------------
Start tcpdump collection in SBTS
    [Arguments]    ${gnb_id}=0    ${du_id}=0    ${name}=ASIB_tcpdump    ${options}=-i any
    [Documentation]    this kw is used to create tcpdump log collection on ASIB VM
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_id | Yes | gnb_id default value:0 |
    ...    | du_id | Yes | du_id default value:0 |
    ...    | name | Yes | name of the collector. Ex: ASIB_tcpdump |
    ...    | options | Yes | (optional) tcpdump options (except for “-w”), default: empty string |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start tcpdump collection in SBTS | gnb_id=0 | du_id=0 | name=ASIB_tcpdump | options=-i any |
    ...
    Log To Console    ${gnb_id}
    Log To Console    ${du_id}
    &{ASIB}=    create dictionary    host=${ASIB_IP}
    ...                              user=${ASIB_USERNAME}
    ...                              password=${ASIB_PASSWORD}
    tcpdump.create_tcpdump_collector    name=${name}    options=${options}    executor=${ASIB}
    tcpdump.Set Suite Alias    ${name}
    core.setup_collectors    names=${name}
    core.start_collectors    names=${name}

Start tcpdump in SBTS
   [Documentation]    this kw is used to start tcpdump in gnb
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | tcpdump_log_name | the name of tcpdump log |
    ...
    ...    Example
    ...    | ${tcpdump_log_name} | Start tcpdump collection in SBTS |
    ...
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${pcap_path}    Join Path    ${RESULT_DIR}    Wireshark_${timestamp}
    ${pcap_file_name}    Join Path    ${RESULT_DIR}    Wireshark_${timestamp}    Wireshark_${timestamp}.pcap
    set suite variable    ${pcap_path}
    set suite variable    ${pcap_file_name}
    set suite variable    ${tcpdump_log_name}    Wireshark_${timestamp}
    Start tcpdump collection in SBTS    name=Wireshark_${timestamp}    options=-i any
    [Return]    ${tcpdump_log_name}

Stop Tcpdump in SBTS
   [Documentation]    this kw is used to stop tcpdump in gnb
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | capture_file_path | the path of captured log |
    ...    | input_file | the file of captured log |
    ...
    ...    Example
    ...    | ${capture_file_path}    ${input_file}    Start tcpdump collection in SBTS |
    ...
    core.stop_collectors    names=${tcpdump_log_name}
    core.Collect Collectors    names=${tcpdump_log_name}    target_dir=${TEST_LOG_DIRECTORY}
    core.Teardown Collectors    names=${tcpdump_log_name}
    ${capture_file_path} =    Set Variable    ${TEST_LOG_DIRECTORY}/${tcpdump_log_name}/${tcpdump_log_name}.pcap
    ${input_file} =    Set Variable    ${tcpdump_log_name}.pcap
    set suite variable    ${capture_file_path}
    set suite variable    ${input_file}
    [Return]    ${capture_file_path}    ${input_file}

Stop Tcpdump without collect
   [Documentation]    this kw is used to stop tcpdump in gnb
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop Tcpdump without collect |
    core.stop_collectors    names=${tcpdump_log_name}

Start tcpdump in SBTS by command
   [Arguments]    ${connection}=First_ASIB
   [Documentation]    this kw is used to collect wiresahrk log in sbts by command
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | connection | Yes | the name of connective unit |
    ...
    ...    | Return Value | Description |
    ...    | tcpdump_log_name | the name of tcpdump log  |
    ...
    ...    Example
    ...    | ${tcpdump_log_name} | Start tcpdump in SBTS by command | connection=First_ASIB |
    ...
    Connect to First_ASIB    alias=${connection}
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    set suite variable    ${tcpdump_log_name}    Wireshark_${timestamp}.pcap
    ssh.send command    command=tcpdump -i any -w /tmp/${tcpdump_log_name} &>/dev/null &
    ...    connection=${connection}
    [Return]    ${tcpdump_log_name}

Stop tcpdump in SBTS by command
   [Arguments]    ${connection}=First_ASIB
   [Documentation]    this kw is used to stop wiresahrk log in sbts by command
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | connection | Yes | the name of connective unit |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop tcpdump in SBTS by command | connection=First_ASIB |
    ${pid}    ssh.execute    command=ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'
    ...                      connection=${connection}
    ssh.execute    command=pkill -f tcpdump    connection=${connection}
    sleep    2s
    ssh.execute    command=ps -ef|grep -i tcpdump|grep -v grep    connection=${connection}

Download wireshark log to testvm
    [Arguments]    ${connection}=First_ASIB    ${tcpdump_log_name}=${tcpdump_log_name}    ${remote_log_dir}=tmp
    [Documentation]    this kw is used to download wireshark log to testvm
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | connection | Yes | the name of connective unit |
    ...    | tcpdump_log_name | Yes | the name of tcpdump log |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Download wireshark log to testvm | connection=First_ASIB | tcpdump_log_name=${tcpdump_log_name} |
    ...
    ssh.download_file    local_path=${TEST_LOG_DIRECTORY}${/}${tcpdump_log_name}    remote_path=${/}${remote_log_dir}${/}${tcpdump_log_name}
    ...                  connection=${connection}
    Sleep    10
    ${capture_file_path}=    Set Variable    ${TEST_LOG_DIRECTORY}/${tcpdump_log_name}
    set suite variable    ${capture_file_path}
    [Return]    ${capture_file_path}
    [Teardown]    Run Keyword And Ignore Error    Run keywords    ssh.execute    command=rm -rf /${remote_log_dir}/*.pcap
    ...    connection=${connection}
    ...    AND    csn.disconnect    connection=${connection}

Start Capture Container log
    [Arguments]    ${local_node_id}=0x1011    ${node_name}=CPIF00    ${filename}=CPIF.pcap
    [Documentation]    this kw is used to capture Capture container log
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | local_node_id | Yes | node id |
    ...    | node_name | Yes | node name |
    ...    | filename | Yes | the name of the container log |
    ...
    ...    | Return Value | Description |
    ...    | containerid | return container id |
    ...
    ...    Example
    ...    | ${containerid} | Start Capture Container log |
    ...
    ${containerid}    Get the container id    local_node_id=${local_node_id}    node_name=${node_name}
    set suite variable    ${containerid}
    Start Capture log From Container    filename=${filename}    containerid=${containerid}    connection=ASIB Master
    [Return]    ${containerid}

Stop Capture Container log
    [Arguments]    ${containerid}=${containerid}    ${filename}=CPIF.pcap    ${node_name}=CPIF00
    [Documentation]    this kw is used to stop capture container log
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  containerid | Yes | container id |
    ...    |  filename | Yes | the name of the container log |
    ...    |  node_name | Yes | node name |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |Stop Capture Container log | ${containerid} |
    ...
    Stop Capture log From Container    containerid=${containerid}    connection=ASIB Master
    Download Container Log To UTE    filename=${filename}    node_name=${node_name}    connection=ASIB Master

Start Capture log From Container
    [Arguments]    ${filename}    ${containerid}=${containerid}    ${listen_port}=any
    ...            ${log_dir}=/tmp    ${connection}=${connection}
    [Documentation]    this kw is used to start capture log from container
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | filename | Yes | file name |
    ...    | containerid | No | container id |
    ...    | listen_port | No | listen port , default any |
    ...    | log_dir | No | the path of log collected |
    ...    | connection | No | the name of connective unit |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |Start Capture log From Container | ${filename} |
    ...
    ssh.send command    command=lxc-attach -n ${containerid} -- tcpdump -i ${listen_port} -s0 -w ${log_dir}/${filename} &>/dev/null &
    ...    connection=${connection}

Start Capture cpif log
   [Arguments]    ${filename}    ${node_name}=CPIF00    ${listen_port}=any    ${log_dir}=/tmp    ${connection}=ASIB Master
   [Documentation]    this kw is used to start capture cpif log
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  filename | Yes | file name |
    ...    |  node_name | No | node name |
    ...    |  listen_port | No | listen port , default any |
    ...    |  log_dir | No | the path of log collected |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start Capture cpif log | ${filename} |
    ...
    Log To Console    ${node_name}
    Connect to Common Unit Master
    ssh.send command    cd /tmp/node_CPIF00    connection=${connection}
    ssh.send command    command=tcpdump -i ${listen_port} -s0 -w ${log_dir}/${filename} &>/dev/null &
    ...                 connection=${connection}

Download Container Log To UTE
    [Arguments]    ${filename}=${filename}    ${log_dir}=/tmp    ${node_name}=CPIF00    ${connection}=ASIB Master
    [Documentation]    this kw is used to download container log To UTE
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | filename | Yes | file name |
    ...    | log_dir | No |the path of log collected |
    ...    | node_name | No | node name |
    ...    | connection | No | the name of connective unit |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Download Container Log To UTE | ${filename} |
    ...
    [Timeout]    5min
    Log To Console    ${node_name}
    ssh.download_file    local_path=${TEST_LOG_DIRECTORY}${/}${filename}    remote_path=${log_dir}${/}${filename}    connection=${connection}
    Sleep    10
    [Teardown]    ssh.execute    command=rm -rf /tmp/${filename}    connection=${connection}

Stop Capture log From Container
    [Arguments]    ${containerid}=${containerid}    ${connection}=${connection}
    [Documentation]    this kw is used to stop capture log from container
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  containerid | Yes | container id |
    ...    |  connection | Yes | the name of connective unit |
    ...    | connection | Yes | Common Unit Master |
    ...    | timeout | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop Capture log From Container    ${containerid}=${containerid} |
    ...
    Connect to Common Unit Master
    ${pid}    ssh.execute    command=lxc-attach -n ${containerid} -- ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'
    ...                     connection=${connection}
    ssh.execute    command=lxc-attach -n ${containerid} -- kill -2 ${pid.replace('\r\n','')}    connection=${connection}
    sleep    2s
    ssh.execute    command=lxc-attach -n ${containerid} -- ps -ef|grep -i tcpdump|grep -v grep    connection=${connection}

Stop Capture cpif log
    [Arguments]    ${node_name}=CPIF00    ${connection}=ASIB Master
    [Documentation]    this kw is used to stop capture cpif log
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  node_name | Yes | node name |
    ...    |  connection | Yes | the name of connective unit |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop Capture cpif log |
    ...
    Log To Console    ${node_name}
    Connect to Common Unit Master
    ${pid}    ssh.execute    command=ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'
    ...                   connection=${connection}
    ssh.execute    command=kill -2 ${pid}    connection=${connection}
    sleep    2s
    ssh.execute    command=ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'    connection=${connection}

Parse Pcap by name
    [Arguments]    ${input_file}=${capture_file_path}    ${filter}=x2ap    ${filter_expression}=esp.sequence == 115
    ...            ${field_name}=esp.spi
   [Documentation]    this kw is used to analysis pcap with name
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  input_file | Yes | the path of capurtured log |
    ...    |  filter | Yes | the output can add filter to aviod too large |
    ...    |  filter_expression | Yes | filter expression  |
    ...    |  field_name | Yes | field name |
    ...
    ...    | Return Value | Description |
    ...    | filtered_packets | return filtered packets |
    ...    | Return Value | values| return value parse by name |
    ...
    ...    Example
    ...    | ${filtered_packets} | ${values} | Parse Pcap by name |
    ...
    ${command_template}    set variable    {tshark_path} -r {input_file} -Y ${filter} -T pdml > {output_file}
    ${all_packets}=    wireshark.load_pcap_file    pcap_file=${input_file}    tshark_path=${tshark_path}
    ...                                            command_template=${command_template}
    ${filtered_packets}=    wireshark.filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${filter_expression}
    ${values}=    wireshark.get_field_value_by_name    pdml_list=${filtered_packets}    field_name=${field_name}
    [Return]    ${filtered_packets}    ${values}

Parse Pcap by expressionbackup
    [Arguments]    ${input_file}=${capture_file_path}    ${filter}=x2ap    ${filter_expression}=esp.sequence == 115
    [Documentation]    this kw is used to analysis pcap with expressionbackup
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  input_file| the path of capurtured log |
    ...    |  filter | the output can add filter to aviod too large |
    ...    |  filter_expression | filter expression  |

    ...
    ...    | Return Value | filtered_packets| return filtered packets |
    ...
    ...    Example
    ...    | ${filtered_packets}    Parse Pcap by expressionbackup |
    ${command_template}    set variable    {tshark_path} -r {input_file} -Y ${filter} -T pdml > {output_file}
    ${all_packets}=    wireshark.load_pcap_file    pcap_file=${input_file}    tshark_path=${tshark_path}
    ...                                            command_template=${command_template}
    ${filtered_packets}=    wireshark.filter_packets_by_expression    pdml_list=${all_packets}
    ...   filter_expression=${filter_expression}
    Should Not Be Empty    ${filtered_packets}
    ${expression}    Replace String    ${filter_expression}    ${SPACE}    ${EMPTY}
    ${expression_list}    Get Regexp Matches    ${expression}    (([a-zA-Z]+\.)+(\s)*==(\s)*[^&|'"]+)
    ${xpath}    Set Variable    ${EMPTY}
    FOR    ${e}    IN    @{expression_list}
        ${field_name}    ${field_name_value}    Split String    ${e}     ==
        ${xpath}    Catenate    SEPARATOR=    ${xpath}
        ...    //${field_name}\[@show='${field_name_value}'\]
    END
    ${values}    wireshark.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=${xpath}
    Should Not Be Empty    ${values}
    [Return]    ${filtered_packets}

Parse Pcap by expression
    [Arguments]    ${input_file}=${capture_file_path}    ${filter_expression}=esp.sequence == 115
    [Documentation]    this kw is used to analysis pcap with expression
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  input_file| the path of capurtured log |
    ...    |  filter_expression | filter expression  |

    ...
    ...    | Return Value | filtered_packets| return filtered packets |
    ...
    ...    Example
    ...    | ${filtered_packets}    Parse Pcap by expression |
    ${filtered_packets}    Run    tshark -r ${input_file} -Y "${filter_expression}"
    Should Not Be Empty    ${filtered_packets}
    [Return]    ${filtered_packets}

Parse Pcap by xpath
    [Arguments]    ${input_file}=${capture_file_path}    ${filter}=x2ap    ${filter_expression}=x2ap.pLMN_Identity == 12:34:56
    ...            ${xpath}=.//x2ap.GlobalGNB_ID_element/x2ap.pLMN_Identity
    [Documentation]    this kw is used to  analysis pcap with xpath
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  input_file| the path of capurtured log |
    ...    |  filter | the output can add filter to aviod too large |
    ...    |  filter_expression | filter expression  |
    ...    |  xpath | the path of x2ap |

    ...
    ...    | Return Value | value_list| return value list |
    ...
    ...    Example
    ...    | ${value_list}   Parse Pcap by xpath |
    ...
    Log To Console    ${filter_expression}
    ${command_template}    set variable    {tshark_path} -r {input_file} -Y ${filter} -T pdml > {output_file}
    ${all_packets}=    wireshark.load_pcap_file    pcap_file=${input_file}    tshark_path=${tshark_path}
    ...                                            command_template=${command_template}
    ${values}=    wireshark.get_field_value_by_xpath    pdml_list=${all_packets}    xpath=${xpath}
    Should Not Be Empty    ${values}
    ${value_list}    Create List
    FOR    ${value}    IN    @{values}
        ${tmp}    Convert To Integer    ${value}    16
        Append to list    ${value_list}    ${tmp}
    END
    [Return]    ${value_list}

Parse Pcap by xpath with confirm
    [Arguments]    ${expected_value}    ${input_file}=${capture_file_path}    ${filter}=x2ap
    ...            ${xpath}=.//x2ap.GlobalGNB_ID_element/x2ap.pLMN_Identity
    [Documentation]    this kw is used to  analysis pcap with xpath
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  expected_value | expected value  |
    ...    |  input_file| the path of capurtured log |
    ...    |  filter | the output can add filter to aviod too large |
    ...    |  xpath | the path of x2ap |

    ...
    ...    | Return Value | values| return values |
    ...
    ...    Example
    ...    | ${values}  Parse Pcap by xpath with confirm |
    ...
    ${command_template}    set variable    {tshark_path} -r {input_file} -Y ${filter} -T pdml > {output_file}
    ${all_packets}=    wireshark.load_pcap_file    pcap_file=${input_file}    tshark_path=${tshark_path}
    ...                                            command_template=${command_template}
    ${values}=    wireshark.get_field_value_by_xpath    pdml_list=${all_packets}    xpath=${xpath}
    Should Not Be Empty    ${values}
    ${index}    set variable    ${0}
    ${length}    get length    ${values}
    FOR    ${value}    IN    @{values}
        Exit For Loop If    ${value} == ${expected_value}
        Continue For Loop If    ${value} != ${expected_value}
        ${index}    Evaluate    ${index} + ${1}
        run keyword if    ${index} == ${length}    fail    check result is failed
    END
    [Return]    ${values}

Prepare luashark files
    [Documentation]    This kw is used to Prepare luashark files for decode bip log
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Prepare luashark files |
    ...
    ${new_sw_version}    ${branch}    Get SW VER From SBTS and Convert Trunk or Branch
    ${cmd}=    Catenate    wget http://files.ute.nsn-rdnet.net/builds/enb/base/${new_sw_version}/${new_sw_version}_luashark.zip
    OperatingSystem.Run    command=sudo mkdir /opt/luashark
    OperatingSystem.Run    command=sudo chmod 777 /opt/luashark
    OperatingSystem.Run    command=${cmd}
    OperatingSystem.Run    command=unzip -q ${new_sw_version}_luashark.zip -d /opt/luashark/
    OperatingSystem.Run    command=mv /opt/luashark/generated_luashark/* /opt/luashark/

Cleanup MCShark Files
    ${output}    OperatingSystem.Run    command=tshark -v |grep TShark
    ${lst}    Get Regexp Matches    ${output}    v(\\d{1,3}\.\\d{1,3})\.\\d{1,3}   1
    ${tshark_version}    set variable    ${lst}[0]
    ${new_sw_version}    ${branch}    Get SW VER From SBTS and Convert Trunk or Branch    ${ASIB_IP_local}
    ${mcshark_path}    Create List    /home/ute/.local/lib/wireshark/plugins/${tshark_version}/epan/mcshark-*.so
    ...    /home/ute/artifactory/wslte5g_plugins-local/MCShark/${new_sw_version}/mcshark-${tshark_version}*bookworm.so
    FOR    ${mc}    IN    @{mcshark_path}
        ${is_exist}    Run Keyword And Return Status    File Should Exist    ${mc}
        Run Keyword If    ${is_exist}    OperatingSystem.Run    command=sudo rm -rf ${mc}
    END

Prepare MCShark Files
    [Documentation]    This kw is used to Prepare MCShark Files for decode bip log
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Prepare MCShark Files |
    ...
    Cleanup MCShark Files
    ${new_sw_version}    ${branch}    Get SW VER From SBTS and Convert Trunk or Branch    ${ASIB_IP_local}
    ${cmd}=  Catenate  wget -r -np -nH ${MCSHARK_TOOL_LINK}/${new_sw_version}/ -P /home/ute/
    OperatingSystem.Run    command=cd /home/ute/
    OperatingSystem.Run    command=${cmd}
    ${output}    OperatingSystem.Run    command=tshark -v |grep TShark
    ${lst}    Get Regexp Matches    ${output}    v(\\d{1,3}\.\\d{1,3})\.\\d{1,3}   1
    ${tshark_version}=    set variable    ${lst}[0]
    ${ute_plugin_path}=    set variable    /home/ute/.local/lib/wireshark/plugins/${tshark_version}/epan/mcshark-*.so
    ${is_exist}    Run Keyword And Return Status    File Should Exist    ${ute_plugin_path}
    Return From Keyword If   ${is_exist}
    ${mcshark_path}=  Catenate  /home/ute/artifactory/wslte5g_plugins-local/MCShark/${new_sw_version}/mcshark-${tshark_version}*bookworm.so
    ${path}=    set variable    /usr/lib/x86_64-linux-gnu/wireshark/plugins/${tshark_version}/epan
    ${is_exist}=    Run Keyword And Return Status    Directory Should Exist    ${path}
    Run Keyword If    not ${is_exist}
    ...         OperatingSystem.Run    command=sudo mkdir -p ${path}
    OperatingSystem.Run    command=sudo rm -rf ${path}/mcshark-*buster.so
    OperatingSystem.Run    command=sudo cp ${mcshark_path} ${path}



Convert BIP To CSV By MCShark
    [Arguments]    ${bip_file}    ${output_file}    ${filter}    ${csv_title_list}
    [Documentation]    This kw is used to Convert BIP To CSV By MCShark
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | bip_file | Yes | bip file name which is colleted |
    ...    | output_file | Yes | the path of csv file is stored |
    ...    | filter | Yes | What is used to filter messages |
    ...    | csv_title_list | Yes | csv file list |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Convert BIP To CSV By MCShark | ${name}.pcap | ${TEST_LOG_DIRECTORY}/csv_${name}.csv | ${filter} | ${csv_title_list} |
    ...
    Prepare MCShark Files
    ${csv_title}=    Set Variable
    FOR    ${column}    IN    @{csv_title_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}=    Catenate    tshark -r ${TEST_LOG_DIRECTORY}/${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Info
    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}

Check Process Will Be Killed
    [Arguments]    ${interface}=tcpdump_L2L1    ${connection}=ASIB_Master
    [Documentation]    this kw is used to Check Process Will Been Killed
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | interface | No | capture port on asib or ASIB |
    ...    | connection | No | master connection alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...     | Check Process Will Been Killed | interface=eths2 | connection=ASIB_Master |
    ...
    ${check_process_command}    Set Variable    ps -ef | grep tcpdump | grep -v grep | grep ${interface}
    ${is_process_killed}=    csn.Execute    command=${check_process_command}    connection=${connection}
    Should Be Empty    ${is_process_killed}

Parse Pcap by name with luashark
    [Arguments]    ${input_file}    ${expected_value}    ${filter}=uldata_puschreceiveresplo
    ...    ${filter_expression}=DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot
    ...    ${field_name}=DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot
   [Documentation]    this kw is used to analysis BIP log with luashark
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | input_file| Yes | the path of capurtured log |
    ...    | expected_value | Yes | expected value  |
    ...    | filter | Yes | the output can add filter to aviod too large |
    ...    | filter_expression | Yes | filter expression |
    ...    | field_name | Yes | field name |
    ...
    ...    | Return Value | Description |
    ...    | all_packets | return wireshark log file |
    ...    | values | return value |
    ...
    ...    Example
    ...    | ${all_packets} | ${values} | Parse Pcap by name with luashark | ${input_file} | ${expected_value} |
    ...    | ...                        | filter=uldata_puschreceiveresplo |
    ...    | ...                        | filter_expression=DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot |
    ...    | ...                        | ${field_name}=DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot |
    ...
    Log To Console    ${filter}
    Log To Console    ${filter_expression}
    ${all_packets}=    Wait until keyword succeeds    1min    5s    wireshark.load_pcap_file    pcap_file=${input_file}
    ...    tshark_path=${tshark_path}    luashark_path=${luashark_path}
    ${values}=    wireshark.get_field_value_by_name    pdml_list=${all_packets}    field_name=${field_name}
    Should Not Be Empty    ${values}
    ${index}    set variable    ${0}
    ${length}    get length    ${values}
    FOR    ${value}    IN    @{values}
        Exit For Loop If    ${value} == ${expected_value}
        ${index}    Evaluate    ${index} + ${1}
        run keyword if    ${index} == ${length}    fail    check result is failed
    END
    [Return]    ${all_packets}    ${values}

Parse Pcap by name with luashark without confirm
    [Arguments]    ${input_file}    ${filter}=uldata_puschreceiveresplo
    ...    ${filter_expression}=DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot
    ...    ${field_name}=DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot
    [Documentation]    this kw is used to analysis BIP log with luashark without confirm
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  input_file | Yes | the path of capurtured log |
    ...    |  filter | Yes | the output can add filter to aviod too large |
    ...    |  filter_expression | Yes | filter expression |
    ...    |  field_name | Yes | field name |
    ...
    ...    | Return Value |  Description |
    ...    | all_packets | return wireshark log file |
    ...    | Return Value | values | return wireshark log by filed name|
    ...
    ...    Example
    ...    | ${all_packets} | ${values} | Parse Pcap by name with luashark without confirm | ${input_file} |
    ...    | ...                        | filter=uldata_puschreceiveresplo |
    ...    | ...                        | filter_expression=DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot |
    ...    | ...                        | ${field_name}=DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot |
    ...
    Log To Console    ${filter}
    Log To Console    ${filter_expression}
    ${all_packets}=    Wait until keyword succeeds    1min    5s    wireshark.load_pcap_file    pcap_file=${input_file}
    ...    tshark_path=${tshark_path}    luashark_path=${luashark_path}
    ${values}=    wireshark.get_field_value_by_name    pdml_list=${all_packets}    field_name=${field_name}
    Should Not Be Empty    ${values}
    [Return]    ${all_packets}    ${values}

Parse Pcap by expression with luashark
    [Arguments]    ${input_file}    ${display_filter}=${display_filter}    ${luashark_path}=${luashark_path}
    [Documentation]    this kw is used to verify the c-plane msgs meet the expectations of RLF procedure
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  input_file | Yes | should include dir name and file name, eg: /home/ute/CPRT_trace.pcap |
    ...    |  display_filter | Yes | the output can add filter to aviod too large |
    ...    |  luashark_path | Yes | the path of luashark |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Parse Pcap by expression with luashark | ${input_file} | display_filter=${display_filter} |
    ...    | ...                                    | luashark_path=${luashark_path} |
    ...
    ${all_packets}=    load_pcap_file    pcap_file=${input_file}    tshark_path=${tshark_path}
    ...    luashark_path=${luashark_path}
    ${filtered_packets}    filter_packets_by_expression    pdml_list=${all_packets}
    ...                                                    filter_expression=${display_filter}
    ${packet_length}    get length    ${filtered_packets}
    should be true    ${packet_length}>0

Parse Pcap by expression with luashark1
    [Arguments]    ${input_file}=${capture_file_path}    ${filter_expression}=esp.sequence
    [Documentation]    this kw is used to verify the c-plane msgs meet the expectations of RLF procedure
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  input_file | Yes | should include dir name and file name, eg: /home/ute/CPRT_trace.pcap |
    ...    |  filter_expression | Yes | find some message by the filter expression |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Parse Pcap by expression with luashark1 | ${input_file} | filter_expression=esp.sequence |
    ...
    ${filtered_packets}    Run    tshark -r ${input_file} -X lua_script:${luashark_path} -Y "${filter_expression}"
    Should Not Be Empty    ${filtered_packets}
    [Return]    ${filtered_packets}

Parse Pcap by xpath with luashark
    [Arguments]    ${input_file}    ${expected_value}    ${display_filter}=${display_filter}
    ...                ${xpath}=.//DlData_SlotTypeReq.SlotTypeReq.sfn    ${luashark_path}=${luashark_path}
    [Documentation]    this kw is used to analysis pcap with luashark
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  input_file | Yes | should include dir name and file name, eg: /home/ute/CPRT_trace.pcap |
    ...    |  expected_value | Yes | expected value |
    ...    |  display_filter | Yes | the output can add filter to aviod too large |
    ...    |  xpath | Yes | xpath |
    ...    |  luashark_path | Yes | luashark path |
    ...
    ...    | Return Value |  Description |
    ...    | values | return analyzed vlaues by xpath |
    ...
    ...    Example
    ...    | ${values} | Parse Pcap by xpath with luashark | ${input_file} | expected_value= ${expected_value} |
    ...
    Log To Console    ${display_filter}
    ${all_packets}=    load_pcap_file    pcap_file=${input_file}    tshark_path=${tshark_path}
    ...    luashark_path=${luashark_path}
    ${values}=    wireshark.get_field_value_by_xpath    pdml_list=${all_packets}    xpath=${xpath}
    Should Not Be Empty    ${values}
    ${index}    set variable    ${0}
    ${length}    get length    ${values}
    FOR    ${value}    IN    @{values}
        Exit For Loop If    ${value} == ${expected_value}
        ${index}    Evaluate    ${index} + ${1}
        run keyword if    ${index} == ${length}    fail    check result is failed
    END
    [Return]    ${values}

Parse Pcap by xpath with luashark without confirm
    [Arguments]    ${input_file}    ${display_filter}=${display_filter}
    ...            ${xpath}=.//DlData_SlotTypeReq.SlotTypeReq.sfn    ${luashark_path}=${luashark_path}
    [Documentation]    this kw is used to analysis pcap with luashark
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  input_file | Yes | should include dir name and file name, eg: /home/ute/CPRT_trace.pcap |
    ...    |  expected_value |  Yes | expected value |
    ...    |  display_filter | Yes |  the output can add filter to aviod too large |
    ...    |  xpath | Yes |  xpath |
    ...    |  luashark_path | Yes |  luashark path |
    ...
    ...    | Return Value |
    ...    | values | return analyzed vlaues by xpath |
    ...
    ...    Example
    ...    | ${values} | Parse Pcap by xpath with luashark without confirm | expected_value=${expected_value} |
    ...
    Log To Console    ${display_filter}
    ${all_packets}=    load_pcap_file    pcap_file=${input_file}    tshark_path=${tshark_path}
    ...    luashark_path=${luashark_path}
    ${values}=    wireshark.get_field_value_by_xpath    pdml_list=${all_packets}    xpath=${xpath}
    Should Not Be Empty    ${values}
    [Return]    ${values}

Check BIP trace with luashark
    [Arguments]    ${input_file}=${TEST_LOG_DIRECTORY}/CPIF.pcap    ${filter}=f1ap    ${field_name}=frame.time_relative
    [Documentation]    this kw is used to check BIP trace with luashark
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  input_file | Yes | define input file |
    ...    |  filter | Yes | the output can add filter to aviod too large |
    ...    |  field_name | Yes | define field name |
    ...
    ...    | Return Value | Description |
    ...    | duration_list | return duration list |
    ...
    ...    Example
    ...    | ${duration_list} | Check BIP trace with luashark | ${input_file} | filter= ${filter} |
    ...    | ...              | field_name=frame.time_relative |
    ...
    ${command_template_with_Y}    set variable
    ...    {tshark_path} -r {input_file} -X lua_script:${luashark_path} -Y ${filter} -T pdml > {output_file}
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${input_file}
    ...    tshark_path=${tshark_path}    command_template=${command_template_with_Y}
    ${time_list}    wireshark.get_field_value_by_name    pdml_list=${all_packets}    field_name=${field_name}
    ${time_list}    Get Slice From List    ${time_list}    0    10
    ${time_2_list}    Copy List    ${time_list}
    ${length}    get length    ${time_list}
    Remove From List    ${time_list}    ${${length}-${1}}
    Remove From List    ${time_2_list}    0
    ${duration_list}    create list
    FOR    ${time}    IN    @{time_list}
        ${index}    Get Index From List    ${time_list}    ${time}
        ${d-value}    evaluate    float(${time_2_list[${index}]})-float(${time})
        Append To List    ${duration_list}    ${d-value}
    END
    [Return]    ${duration_list}
    [Teardown]    wireshark.teardown

Get the beamid from biplog
    [Arguments]    ${pcap_file_path}=${TEST_LOG_DIRECTORY}/CPIF.pcap
    [Documentation]    this kw is used to get the beamid from biplog
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pcap_file_path | Yes | define pacp file path |
    ...
    ...    | Return Value | Description |
    ...    | beamid | return beam id |
    ...
    ...    Example
    ...     | ${beamid} | Get the beamid from biplog |
    ...
    ${all_packets}=    wireshark.load_pcap_file    pcap_file=${pcap_file_path}
    ...                                            tshark_path=${tshark_path}
    ...                                            luashark_path=${luashark_path}
    ${filtered_packets}=    wireshark.filter_packets_by_expression    pdml_list=${all_packets}
    ...    filter_expression=DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot
    ${values_slot} =    wireshark.get_field_value_by_name    pdml_list=${filtered_packets}
    ...    field_name=DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot
    ${length}    Get Length    ${values_slot}
    FOR    ${i}    IN RANGE    ${length}
        ${field_name1} =    catenate    DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot==${values_slot[${i}]}
        ${filtered_packets1}=    wireshark.filter_packets_by_expression    pdml_list=${all_packets}
        ...    filter_expression=${field_name1}
        ${values_sfn} =    wireshark.get_field_value_by_name    pdml_list=${filtered_packets1}
        ...    field_name=DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.sfn
        ${field_name2} =    catenate    DlData_PatternConfigReq.PatternConfigReq.slot==${values_slot[${i}]} and
        ...    DlData_PatternConfigReq.PatternConfigReq.sfn==${values_sfn[0]}
        ${filtered_packets2}=    wireshark.filter_packets_by_expression    pdml_list=${all_packets}
        ...    filter_expression=${field_name2}
        ${values_beam} =    wireshark.get_field_value_by_xpath
        ...                 pdml_list=${filtered_packets2}
        ...                 xpath=.//dldata_patternconfigreq[3]/dldata_patternconfigreq/${beamsymbol}
        exit for loop if    ${values_beam}!=[]
    END
    @{output}=    Split String    ${values_beam[0]}    :
    ${beamid}=    convert to integer    0x${output[0]}
    [Return]    ${beamid}
    [Teardown]    wireshark.teardown

#-------------------tti---------------------------------------------------------------------------------
Start TTI trace log capturing
    [Arguments]    ${connection_ABIL}=ABIL_slave
    [Documentation]    this kw is used to start TTI trace process,It will capturing on ABIL master by default
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | connection_ABIL | Yes | connection alias |
    ...
    ...    | Return Value | Description |
    ...    | connection_ABIL | return  connection ABIL |
    ...
    ...    Example
    ...    | ${connection_ABIL} | Start TTI trace log capturing | connection_ABIL=ABIL_slave |
    ...
    ${testline_type}    Get Regexp Matches    ${TL_Type}    .*?ABIO
    Run keyword if    ${testline_type}    run keywords    Connect to ABIO Master
    ...    AND    Set Test Variable    ${connection_ABIL}    ${connection_ABIO}
    ...    ELSE    run keywords    Connect to ABIL Slave
    ...    AND    Set Test Variable    ${connection_ABIL}    ${connection_ABIL}
    #${connection_ABIL}    Connect to ABIL Slave
    ${BB_slotL1}    Get Regexp Matches    ${TL_Type}    .*?ASIBL.*?ABIOB1.*?
    ${BB_slotL2}    Get Regexp Matches    ${TL_Type}    .*?ASIBL.*?ABIOB2.*?
    ${BB_slotR1}    Get Regexp Matches    ${TL_Type}    .*?ASIBR.*?ABIOB1.*?
    ${BB_slotR2}    Get Regexp Matches    ${TL_Type}    .*?ASIBR.*?ABIOB2.*?
    Run keyword if    ${BB_slotL1}    Set Test Variable    ${tti_script_path}    /tmp/node_L2RT20
    Run keyword if    ${BB_slotL2}    Set Test Variable    ${tti_script_path}    /tmp/node_L2RT30
    Run keyword if    ${BB_slotR1}    Set Test Variable    ${tti_script_path}    /tmp/node_L2RTa0
    Run keyword if    ${BB_slotR2}    Set Test Variable    ${tti_script_path}    /tmp/node_L2RTb0
    tti.prepare_for_tti_trace_log_capturing    connection=${connection_ABIL}
    ...                                        tti_script_path=${tti_script_path}
    tti.start_tti_trace    connection=${connection_ABIL}
    [Return]    ${connection_ABIL}

Stop TTI trace log capturing
    [Arguments]    ${connection_ABIL}=ABIL_slave
    [Documentation]    this kw is used to kill TTI trace process
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | connection_ABIL | Yes | connection alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop TTI trace log capturing | connection_ABIL=ABIL_slave |
    ...
    tti.stop_tti_trace    connection=${connection_ABIL}

Convert TTI trace to CVS and download csv logs to test pc
    [Arguments]    ${local_path}=${TEST_LOG_DIRECTORY}    ${connection_ABIL}=ABIL Slave
    [Documentation]    this kw is used to convert TTI trace to CVS
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | local_path | Yes | local path |
    ...    | connection_ABIL | Yes | connection alias |
    ...
    ...    | Return Value | Description |
    ...    | local_csv_file_path | rturn local csv file path |
    ...
    ...    Example
    ...    | ${local_csv_file_path} | Convert TTI trace to CVS and download csv logs to test pc |
    ...    | ...                    | local_path=${TEST_LOG_DIRECTORY} | ${connection_ABIL}=ABIL Slave |
    ...
    ${csv_path}    tti.convert_tti_trace_to_csv    connection=${connection_ABIL}
    ${csv_file_path_ul}    tti.combine_csv_files_to_one    csv_log_path=${csv_path}    direction=ul
    ...                                                    connection=${connection_ABIL}
    ${csv_file_path_dl}    tti.combine_csv_files_to_one    csv_log_path=${csv_path}    direction=dl
    ...                                                    connection=${connection_ABIL}
    ${remote_files}    Create list    ${csv_file_path_ul}    ${csv_file_path_dl}
    csn.download file    remote_path=${remote_files}    local_path=${local_path}    connection=${connection_ABIL}
    @{csv_file_name_ul}    Split string    ${csv_file_path_ul}    /
    @{csv_file_name_dl}    Split string    ${csv_file_path_dl}    /
    &{local_csv_file_path}    create dictionary
    Set to dictionary    ${local_csv_file_path}    UL    ${local_path}/@{csv_file_name_ul}[-1]
    Set to dictionary    ${local_csv_file_path}    DL    ${local_path}/@{csv_file_name_dl}[-1]
    [Return]    ${local_csv_file_path}
    [teardown]    csn.disconnect    connection=${connection_ABIL}

Get index of parameters for dl
    [Arguments]    ${local_csv_file_path}=${local_csv_file_path['DL']}
    [Documentation]    this kw is used to get index of parameters from event trace log
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | local_csv_file_path | Yes | log file path with csv format:/XXX/XXX/TA_Combine_dl_Full_20210108094424.csv |
    ...
    ...    | Return Value | Description |
    ...    | list_index_dl | return dl index with list format |
    ...
    ...    Example
    ...    | ${list_index_dl} | Get index of parameters for dl | ${local_csv_file_path} |
    ...
    ${list_index_dl}    tti_analysis.get_dl_params_col_index
    ...                 file_path=${local_csv_file_path}
    set test variable    ${list_index_dl}
    [Return]    ${list_index_dl}

Get index of parameters for ul
    [Arguments]    ${local_csv_file_path}=${local_csv_file_path['UL']}
    [Documentation]    this kw is used to get index of parameters from event trace log
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | local_csv_file_path | Yes | log file path with csv format:/XXX/XXX/TA_Combine_dl_Full_20210108094424.csv |
    ...
    ...    | Return Value | Description |
    ...    | list_index_ul | return ul index with list format |
    ...
    ...    Example
    ...    | ${list_index_ul} | Get index of parameters for ul | ${local_csv_file_path} |
    ...
    ${list_index_ul}    tti_analysis.get_ul_params_col_index
    ...                 file_path=${local_csv_file_path}
    set test variable    ${list_index_ul}
    [Return]    ${list_index_ul}

Get rnti
    [Arguments]    ${local_csv_file_path}=${local_csv_file_path['DL']}
    [Documentation]    this kw is used to get rnti from event trace log
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | local_csv_file_path | Yes | log file path with csv format:/XXX/XXX/TA_Combine_dl_Full_20210108094424.csv |
    ...
    ...    | Return Value | Description |
    ...    | rnti | return irnti with list format |
    ...
    ...    Example
    ...    | ${rnti}    Get rnti |
    ...
    ${rnti}    tti_analysis.get_rntis    file_path=${local_csv_file_path}
    Set test variable    ${rnti}
    [Return]    ${rnti}

Get numOfPrb
    [Arguments]    ${local_csv_file_path}=${local_csv_file_path['DL']}
    ...            ${list_index}=${list_index_dl}
    ...            ${rnti}=${rnti[0]}
    ...            ${event_name}=dlFdSchedData
    [Documentation]    this kw is used to get numOfPrb from event trace log
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | local_csv_file_path | Yes | log file path with csv format:/XXX/XXX/TA_Combine_dl_Full_20210108094424.csv |
    ...    | list_index | Yes | index numble in csv, eg:INDEX_dlFdSchedData_rnti |
    ...    | rnti | Yes | Each UE will have one unique rnti, so rnti can stand for a ue |
    ...    | event_name | Yes | here is event name, eg:dlFdSchedData |
    ...
    ...    | Return Value | Description |
    ...    | numOfPrb_list | numOfPrb with list format |
    ...
    ...    Example
    ...    | ${numOfPrb_list} | Get numOfPrb | ${local_csv_file_path} | list_index=${list_index_dl} |
    ...    | ...              | rnti=${rnti[0]} | event_name=dlFdSchedData |
    ...
    ${numOfPrb_list}    tti_analysis.getnumOfPrb    file_path=${local_csv_file_path}
    ...                                             rnti=${rnti}
    ...                                             event_name=${event_name}
    ...                                             rnti_index_in_target_event=${list_index[0]}
    ...                                             index_numberofprb=${list_index[3]}
    Set test variable    ${numOfPrb_list}
    [Return]    ${numOfPrb_list}

Get physCellId
    [Arguments]    ${local_csv_file_path}=${local_csv_file_path['DL']}
    ...            ${list_index}=${list_index_dl}
    ...            ${rnti}=${rnti[0]}
    ...            ${event_name}=dlFdSchedData
    [Documentation]    this kw is used to get physCellId from event trace log
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | local_csv_file_path | Yes | log file path with csv format:/XXX/XXX/TA_Combine_dl_Full_20210108094424.csv |
    ...    | list_index | Yes | index numble in csv, eg:INDEX_dlFdSchedData_rnti |
    ...    | rnti | Yes | Each UE will have one unique rnti, so rnti can stand for a ue |
    ...    | event_name | Yes | here is event name, eg:dlFdSchedData |
    ...
    ...    | Return Value | Description |
    ...    | numOfPrb_list | return physCell id with list format |
    ...
    ...    Example
    ...    | ${physCellId_list} | Get physCellId | ${local_csv_file_path} | list_index=${list_index_dl} |
    ...    | ...                | rnti=${rnti[0]} | event_name=dlFdSchedData |
    ...
    ${physCellId_list}    tti_analysis.getphysCellId    file_path=${local_csv_file_path}
    ...                                                 rnti=${rnti}
    ...                                                 event_name=${event_name}
    ...                                                 rnti_index_in_target_event=${list_index[0]}
    ...                                                 index_physCellId=${list_index[4]}
    Set test variable    ${physCellId_list}
    [Return]    ${physCellId_list}

Get sfn
    [Arguments]    ${local_csv_file_path}=${local_csv_file_path['DL']}
    ...            ${list_index}=${list_index_dl}
    ...            ${rnti}=${rnti[0]}
    ...            ${event_name}=dlFdSchedData
    [Documentation]    this kw is used to get sfn from event trace log
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | local_csv_file_path | Yes | log file path with csv format:/XXX/XXX/TA_Combine_dl_Full_20210108094424.csv |
    ...    | list_index | Yes | index numble in csv, eg:INDEX_dlFdSchedData_rnti |
    ...    | rnti | Yes | Each UE will have one unique rnti, so rnti can stand for a ue |
    ...    | event_name | Yes | here is event name, eg:dlFdSchedData |
    ...
    ...    | Return Value | Description |
    ...    | sfn_list | return sfn with list format |
    ...
    ...    Example
    ...    | ${sfn_list} | Get sfn | ${local_csv_file_path} | list_index=${list_index_dl} |
    ...    | ...         | rnti=${rnti[0]} | event_name=dlFdSchedData |
    ...
    ${sfn_list}    tti_analysis.get_sfn    file_path=${local_csv_file_path}
    ...                                    rnti=${rnti}
    ...                                    event_name=${event_name}
    ...                                    rnti_index_in_target_event=${list_index[0]}
    ...                                    index_sfn=${list_index[5]}
    Set test variable    ${sfn_list}
    [Return]    ${sfn_list}

Get slot
    [Arguments]    ${local_csv_file_path}=${local_csv_file_path['DL']}
    ...            ${list_index}=${list_index_dl}
    ...            ${rnti}=${rnti[0]}
    ...            ${event_name}=dlFdSchedData
    [Documentation]    this kw is used to get slot from event trace log
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | local_csv_file_path | Yes | log file path with csv format:/XXX/XXX/TA_Combine_dl_Full_20210108094424.csv |
    ...    | list_index | Yes | index numble in csv, eg:INDEX_dlFdSchedData_rnti |
    ...    | rnti | Yes | Each UE will have one unique rnti, so rnti can stand for a ue |
    ...    | event_name | Yes | here is event name, eg:dlFdSchedData |
    ...
    ...    | Return Value | Description |
    ...    | slot_list | return slot with list format |
    ...
    ...    Example
    ...    | ${slot_list} | Get slot | ${local_csv_file_path} | list_index=${list_index_dl} |
    ...    | ...          | rnti=${rnti[0]} | event_name=dlFdSchedData |
    ...
    ${slot_list}    tti_analysis.getslot    file_path=${local_csv_file_path}
    ...                                     rnti=${rnti}
    ...                                     event_name=${event_name}
    ...                                     rnti_index_in_target_event=${list_index[0]}
    ...                                     index_slot=${list_index[6]}
    Set test variable    ${slot_list}
    [Return]    ${slot_list}

Get tbSize
    [Arguments]    ${local_csv_file_path}=${local_csv_file_path['DL']}
    ...            ${list_index}=${list_index_dl}
    ...            ${rnti}=${rnti[0]}
    ...            ${event_name}=dlFdSchedData
    [Documentation]    this kw is used to get tbSize from event trace log
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | local_csv_file_path | Yes | log file path with csv format:/XXX/XXX/TA_Combine_dl_Full_20210108094424.csv |
    ...    | list_index | Yes | index numble in csv, eg:INDEX_dlFdSchedData_rnti |
    ...    | rnti | Yes | Each UE will have one unique rnti, so rnti can stand for a ue |
    ...    | event_name | Yes | here is event name, eg:dlFdSchedData |
    ...
    ...    | Return Value | Description |
    ...    | tbSize_list | return tbSize with list format |
    ...
    ...    Example
    ...    | ${tbSize_list} | Get tbSize| ${local_csv_file_path} | list_index=${list_index_dl} |
    ...    | ...            | rnti=${rnti[0]} | event_name=dlFdSchedData |
    ...
    ${tbSize_list}    tti_analysis.gettbSize    file_path=${local_csv_file_path}
    ...                              rnti=${rnti}
    ...                              event_name=${event_name}
    ...                              rnti_index_in_target_event=${list_index[0]}
    ...                              index_tbSize=${list_index[7]}
    Set test variable    ${tbSize_list}
    [Return]    ${tbSize_list}

Get min tbsize from rnti
    [Arguments]    ${local_csv_file_path}=${local_csv_file_path['DL']}
    ...            ${list_index}=${list_index_dl}
    ...            ${rnti}=${rnti[0]}
    ...            ${event_name}=dlFdSchedData
    ...            ${direction}=dl
    [Documentation]    this kw is used to get min tbsize from event trace log
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | local_csv_file_path | Yes | log file path with csv format:/XXX/XXX/TA_Combine_dl_Full_20210108094424.csv |
    ...    | list_index | Yes | index numble in csv, eg:INDEX_dlFdSchedData_rnti |
    ...    | rnti | Yes | Each UE will have one unique rnti, so rnti can stand for a ue |
    ...    | event_name | Yes | here is event name, eg:dlFdSchedData |
    ...    | direction | Yes | dl/ul |
    ...
    ...    | Return Value | Description |
    ...    | min_tbsize | return min tbSize |
    ...
    ...    Example
    ...    | ${min_tbsize} | Get min tbsize from rnti | ${local_csv_file_path} | list_index=${list_index_dl} |
    ...    | ...           | rnti=${rnti[0]} | event_name=dlFdSchedData | direction=dl |
    ...
    Log To Console    ${event_name}
    ${min_tbsize}    tti_analysis.get_min_tbsize_from_rnti
    ...              file_path=${local_csv_file_path}
    ...              rnti_list=${rnti}
    ...              rnti_index_in_target_event=${list_index[0]}
    ...              index_tbsize=${list_index[7]}
    ...              direction=${direction}
    Set test variable    ${min_tbsize}
    [Return]    ${min_tbsize}

Get diff tbsize from rnti
    [Arguments]    ${sfn_list}    ${tbSize_list}
    [Documentation]    this kw is used to get diff tbsize from rnti
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | sfn_list | Yes | sfn list |
    ...    | tbSize_list | Yes | tbSize list |
    ...
    ...    | Return Value | Description |
    ...    | diff_tbsize | return diff tbsize |
    ...
    ...    Example
    ...    | ${diff_tbsize} | Get diff tbsize from rnti | ${sfn_list} | ${tbSize_list} |
    ...
    ${diff_tbsize}    tti_analysis.get_20_sfn_diff_tbsize
    ...               sfn_list=${sfn_list}
    ...               tbsize_list=${tbSize_list}
    Set test variable    ${diff_tbsize}
    [Return]    ${diff_tbsize}

Get same value for two list
    [Arguments]    ${list1}=${sfn_list_ue1}    ${list2}=${sfn_list_ue2}
    [Documentation]    this kw is used to get same value from two list
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  list1 | Yes | list1 |
    ...    |  list2 | Yes | list2 |
    ...
    ...    | Return Value | Description |
    ...    | same_value_list | return same value list |
    ...
    ...    Example
    ...    | ${same_value_list} | Get same value for two list | list1=${sfn_list_ue1} | list2=${sfn_list_ue2} |
    ...
    ${same_value_list}    tti_analysis.get_same_value_from_two_list    list1=${list1}    list2=${list2}
    Should Not Be Empty    ${same_value_list}
    [Return]    ${same_value_list}

Get index of value from list
    [Arguments]    ${list}=${slot_list}    ${expect_value}=0
    [Documentation]    this kw is used to get index of value from list
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | list | Yes | list |
    ...    | expect_value | Yes | expect value |
    ...
    ...    | Return Value | Description |
    ...    | index_list | return index list |
    ...
    ...    Example
    ...    | ${index_list} | Get index of value from list | list=${slot_list} | expect_value=0 |
    ...
    ${index_list}    tti_analysis.get_index_according_to_value    list=${list}    expect_value=${expect_value}
    Should Not Be Empty    ${index_list}
    [Return]    ${index_list}

Get all index of value from list
    [Arguments]    ${list}=${slot_list}    ${expect_value}=0
   [Documentation]    this kw is used to get all index of value from list
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | list | Yes | list |
    ...    | expect_value | Yes | expect value |
    ...
    ...    | Return Value | Description |
    ...    | index_list | return index list |
    ...
    ...    Example
    ...    | ${index_list} | Get all index of value from list | list=${slot_list} | expect_value=0 |
    ...
    ${index_list}    tti_analysis.get_all_index_according_to_value    list=${list}    expect_value=${expect_value}
    Should Not Be Empty    ${index_list}
    [Return]    ${index_list}

Get value of index from list
    [Arguments]    ${list}=${sfn_list}    ${expect_index}=0
   [Documentation]    this kw is used to get value of index from list
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com|
    ...    | Input Parameters | Man. | Description |
    ...    | list | Yes | list |
    ...    | expect_value | Yes | expect value |
    ...
    ...    | Return Value | Description |
    ...    | index_list | return index list |
    ...
    ...    Example
    ...    | ${index_list} | Get value of index from list | list=${slot_list} | expect_value=0 |
    ...
    ${index_list}    tti_analysis.get_value_according_to_index    list=${list}    expect_index=${expect_index}
    Should Not Be Empty    ${index_list}
    [Return]    ${index_list}

Check value of sfn for one cycle
    [Documentation]    this kw is used to check value of sfn for one cycle, and one cycle is 1024
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com|
    ...    | Input Parameters | Man. | Description |
    ...    |  None | NA |
    ...
    ...    | Return Value | Description |
    ...    | ${sfn_value_list}  | return sfn value list |
    ...
    ...    Example
    ...     | ${sfn_value_list} | Check value of sfn for one cycle |
    ...
    ${local_csv_file_path}    Convert TTI trace to CVS and download csv logs to test pc    connection_ABIL=${connection_ABIL}
    set test variable    ${local_csv_file_path}
    ${list_index_dl}    Get index of parameters for dl
    set test variable    ${list_index_dl}
    ${rnti}    Get rnti    local_csv_file_path=${local_csv_file_path['DL']}
    ${sfn_list}    Get sfn    local_csv_file_path=${local_csv_file_path['DL']}
    ...                       list_index=${list_index_dl}
    ...                       rnti=${rnti[0]}
    ...                       event_name=dlFdSchedData
    set test variable    ${sfn_list}
    ${sfn_length}    get length    ${sfn_list}
    ${index}    set variable    ${0}
    ${sfn_first_value}    set variable    ${sfn_list[0]}
    ${sfn_value_list}    Create List
    FOR    ${index}    IN RANGE    ${sfn_length}
        Run Keyword If    ${sfn_list[${index}]}!=${sfn_first_value}    Append to list    ${sfn_value_list}
        ...                                                                              ${sfn_list[${index}]}
        ${index}    Evaluate    ${index} + ${1}
    END
    [Return]    ${sfn_value_list}

Check TPUT according to tbsize
    [Documentation]    this kw is used to calculation max min and ave tput
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com|
     ...   | Input Parameters | Man. | Description |
    ...    |  None | NA |
    ...
    ...    | Return Value | Description |
    ...    | ${Tput_max} | return max tput |
    ...    | ${Tput_min} | return min tput |
    ...    | ${Tput_ave} | return ave tput |
    ...
    ...    Example
    ...     | ${Tput_max} | ${Tput_min} | ${Tput_ave} | Check TPUT according to tbsize |
    ...
    Log to console    find sfn in one cycle
    ${sfn_value_list}    Check value of sfn for one cycle
    ${sfn_value_list_final}    Create List    ${sfn_value_list[0]}    ${sfn_value_list[1]}    ${sfn_value_list[2]}
    ...                                       ${sfn_value_list[3]}    ${sfn_value_list[4]}    ${sfn_value_list[5]}
    ...                                       ${sfn_value_list[6]}    ${sfn_value_list[7]}    ${sfn_value_list[8]}
    ...                                       ${sfn_value_list[9]}
    ${sfn_value_length}    get length    ${sfn_value_list}
    FOR    ${index}    IN RANGE    ${sfn_value_length}
        ${index1}    Evaluate    ${index} + ${10}
        Run Keyword If    ${sfn_value_list[${index1}]}!=${sfn_value_list[0]}    Append to list    ${sfn_value_list_final}
        ...                                                                                 ${sfn_value_list[${index1}]}
    END
    Log to console    find tbsize
    ${sfn_value_final_length}    get length    ${sfn_value_list_final}
    ${tbSize_list}    Create List
    FOR    ${index}    IN RANGE    ${sfn_value_final_length}
        ...    Run Keyword If    ${index}==${sfn_value_final_length}    Exit For Loop
        set test variable    ${sfn_value_final_length}
        set test variable    ${sfn_value}    ${${sfn_value_list_final[${index}]}}
        ${sfn_value}    Convert To String    ${sfn_value}
         ${tbSize_value}    gettbSizebysfn    file_path=${local_csv_file_path['DL']}
        ...                sfn=${sfn_value}
        ...                event_name=dlFdSchedData
        ...                sfn_index_in_target_event=${list_index_dl[5]}
        ...                index_tbSize=${list_index_dl[7]}
        Append to list    ${tbSize_list}    ${tbSize_value}
    END
    Log to console    Calculation tput
    ${tbSize_max_min_ave_value}    get_max_min_sum_ave_tbsize    tbSize_list=${tbSize_list}
    set test variable    ${Tput_max}    ${tbSize_max_min_ave_value[0]}
    set test variable    ${Tput_min}    ${tbSize_max_min_ave_value[0]}
    set test variable    ${Tput_ave}    ${tbSize_max_min_ave_value[0]}
    [Return]    ${Tput_max}    ${Tput_min}    ${Tput_ave}

Check tput for one cycle
  [Documentation]    this kw is used to check tput for one cycle
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com|
    ...    | Input Parameters | Man. | Description |
    ...    |  None | NA |
    ...
    ...    | Return Value | Description |
    ...    | ${Tput_max} | return max tput |
    ...    | ${Tput_min} | return min tput |
    ...    | ${Tput_ave} | return ave tput |
    ...    | ${Tput_sum} | return sum tput |
    ...
    ...    Example
    ...     | ${Tput_max} | ${Tput_min} | ${Tput_ave} | ${Tput_sum} | Check tput for one cycle |
    ...
    ${local_csv_file_path}    Convert TTI trace to CVS and download csv logs to test pc    connection_ABIL=${connection_ABIL}
    set test variable    ${local_csv_file_path}
    ${list_index_dl}    Get index of parameters for dl
    set test variable    ${list_index_dl}
    ${rnti}    Get rnti    local_csv_file_path=${local_csv_file_path['DL']}
    ${sfn_list}    Get sfn    local_csv_file_path=${local_csv_file_path['DL']}
    ...                       list_index=${list_index_dl}
    ...                       rnti=${rnti[0]}
    ...                       event_name=dlFdSchedData
    set test variable    ${sfn_list}
    ${tbSize_list}    Get tbSize    local_csv_file_path=${local_csv_file_path['DL']}
    ...                             list_index=${list_index_dl}
    ...                             rnti=${rnti[0]}
    ...                             event_name=dlFdSchedData
    set test variable    ${tbSize_list}
    ${sfn_length}    get length    ${sfn_list}
    ${sfn_first_value}    set variable    ${sfn_list[0]}
    ${sfn_first_value_list}    Create List
    FOR    ${index}    IN RANGE    ${sfn_length}
        Run Keyword If    ${sfn_list[${index}]}==${sfn_first_value}    Append to list    ${sfn_first_value_list}
        ...                                                                              ${sfn_list[${index}]}
        ${index}    Evaluate    ${index} + ${1}
        set test variable    ${sfn_first_value_list}
    END
    ${sfn_value_list}    Create List
    FOR    ${index}    IN RANGE    ${sfn_length}
        Run Keyword If    ${sfn_list[${index}]}!=${sfn_first_value}    Append to list    ${sfn_value_list}
        ...                                                                              ${sfn_list[${index}]}
        ${index}    Evaluate    ${index} + ${1}
        set test variable    ${sfn_value_list}
    END
    ${sfn_first_value_list_length}    get length    ${sfn_first_value_list}
    ${sfn_value_list_length}    get length    ${sfn_value_list}
    Log to console    find final tbsize list
    set test variable    ${sfn_first_value_list}
    set test variable    ${sfn_value_list}
    ${tbSize_length}    get length    ${tbSize_list}
    ${tbSize_value_list}    Create List
    FOR    ${index}    IN RANGE    ${tbSize_length}
        ${index1}    Evaluate    ${index} + ${${sfn_first_value_list_length}}
        Append to list    ${tbSize_value_list}    ${tbSize_list[${index1}]}
        ${index}    Evaluate    ${index} + ${1}
        Exit For Loop If    ${index} == 10240
        set test variable    ${tbSize_value_list}
    END
    Log to console    Calculation tput
    ${tbSize_max_min_ave_value}    get_max_min_sum_ave_tbsize    ${tbSize_value_list}
    set test variable    ${Tput_min}    ${tbSize_max_min_ave_value[0]}
    set test variable    ${Tput_max}    ${tbSize_max_min_ave_value[1]}
    set test variable    ${Tput_sum}    ${tbSize_max_min_ave_value[2]}
    set test variable    ${Tput_ave}    ${tbSize_max_min_ave_value[3]}
    set test variable    ${Tput_ave}
    [Return]    ${Tput_min}    ${Tput_max}    ${Tput_ave}    ${Tput_sum}
##################start collect bip log by taf###################
Get L1l2bipLogs BTS_INFO
    [Arguments]    ${bts_index}=${EMPTY}
    ...    ${host}=${BTS${bts_index}_INFO.IP}
    ...    ${user}=${BTS${bts_index}_INFO.http_USERNAME}
    ...    ${password}=${BTS${bts_index}_INFO.http_PASSWORD}
    ...    ${port}=${BTS${bts_index}_INFO.PORT}
    &{executor}=  Create Dictionary
    ...    host=${host}
    ...    user=${user}
    ...    password=${password}
    ...    port=${port}
    [Return]    &{executor}
Start L1l2bipLogs Internal Collect
    [Arguments]    ${bts_info}    ${target_file_name}=l1l2bip
    ...    ${interface}=L1-L2
    ...    ${destination}=Local
    ...    ${nr_phy_cell_ids}=None
    ...    ${timeout}=1000
    l1l2bip.create_interface_mirroring_l1l2bip_collector
    ...    name=${target_file_name}
    ...    webservice=${bts_info}
    ...    interface=${interface}
    ...    destination=${destination}
    ...    nr_phy_cell_ids=${nr_phy_cell_ids}
    ...    timeout=${timeout}
    core.setup_collectors    names=${target_file_name}
    core.start_collectors    names=${target_file_name}
    core.Set Suite Alias     ${target_file_name}

Stop L1l2bipLogs Internal Collect
    [Arguments]    ${target_file_name}=l1l2bip
    core.stop_collectors    names=${target_file_name}
    ${log_path}    core.collect_collectors    names=${target_file_name}
    [Teardown]    core.teardown_collectors    names=${target_file_name}
    [Return]    ${log_path}
Prepare TtiTraceHelper
    [Documentation]    This kw is used to Prepare TtiTraceHelper tool
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Prepare TtiTraceHelper |
    ...
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${helper_dir}=    Join path    /home/ute    TtiTraceHelper-${timestamp}
    OperatingSystem.Run    command=mkdir -p ${helper_dir}
    ${cmd}=  Catenate  wget -r -np -nH ${TTITRACEHELPER_TOOL_LINK} -P ${helper_dir}
    ${output}    OperatingSystem.Run    command=${cmd}
    ${helper_file_dir}=    Join path    ${helper_dir}    mMIMO-debug-tool
    [Return]    ${helper_file_dir}

Decode TTI
    [Arguments]    ${dcap_local_file_path}    ${postfix}=.dat
    [Documentation]    This kw is used to decode tti log with TtiTraceHelper
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | dcap_local_file_path | yes | local file path for dcap log
    ...    | postfix | no | specify the files to decode by using postfix
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Decode TTI |
    ...
    ${helper_file_dir}=    Prepare TtiTraceHelper
    @{files}    OperatingSystem.List Files In Directory    ${dcap_local_file_path}    *.zip
    ${tti_archive}    set variable    ${dcap_local_file_path}/${files}[0]
    ${tti_file_paths}=    Extract log from trace file    ${tti_archive}    ${dcap_local_file_path}    ${postfix}
    @{csv_file_paths}=    Create List
    OperatingSystem.Run    command=cd ${helper_file_dir} && chmod 777 TtiTraceHelper
    ${pattern}=    set variable    ${postfix}$
    ${target_file_format}=    set variable    .csv
    FOR    ${file_path}    IN    @{tti_file_paths}
        ${output}=    OperatingSystem.Run    command=cd ${helper_file_dir} && ./TtiTraceHelper ${file_path} --no-del
        ${csv_file_path}=    Replace String Using Regexp    string=${file_path}    pattern=${pattern}
        ...    replace_with=${target_file_format}
        Should End With    ${csv_file_path}    ${target_file_format}
        ${is_exist}=    Run Keyword And Return Status    File Should Exist    ${csv_file_path}
        Run Keyword If    ${is_exist}
        ...         Append To List    ${csv_file_paths}    ${csv_file_path}
    END
    [Return]    ${csv_file_paths}

Start tcpdump log in common server
   [Arguments]    ${connection}=common_server_tcpdump
   ...            ${interface}=any
   ...            ${protocol}=${None}
   ...            ${sudo_password}=${None}
   [Documentation]    this kw is used to collect tcpdump log in a common linux server
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | connection | Yes | the name of connective unit |
    ...
    ...    | Return Value | Description |
    ...    | tcpdump_log_name | the name of tcpdump log  |
    ...
    ...    Example
    ...    | ${tcpdump_log_name} | Start tcpdump log in common server |
    ...
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    set suite variable    ${tcpdump_log_name}    Wireshark_${timestamp}.pcap
    ${cmd_middle}    Set Variable If    '${protocol}' == '${None}'
    ...    -i ${interface}    -i ${interface} ${protocol}
    ${cmd}=    catenate    echo '${sudo_password}' |sudo -S tcpdump ${cmd_middle}
    ...    -s 0 -w /tmp/${tcpdump_log_name} &>/dev/null &
    ssh.send command    command=${cmd}    connection=${connection}
    sleep    2s
    ssh.send command    command=ls -alh /tmp/${tcpdump_log_name}    connection=${connection}
    [Return]    ${tcpdump_log_name}

Stop and download tcpdump log in common server
   [Arguments]    ${connection}=common_server_tcpdump
   ...            ${tcpdump_log_name}=${tcpdump_log_name}
   ...            ${sudo_username}=${None}
   ...            ${sudo_password}=${None}
   [Documentation]    this kw is used to stop and download tcpdump log in a common linux server
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | connection | Yes | the name of connective unit |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop and download tcpdump log in common server |
    ssh.execute    command=echo '${sudo_password}' |sudo -S sudo pkill -f tcpdump    connection=${connection}
    sleep    2s
    ssh.execute    command=ps -ef|grep tcpdump|grep -v grep    connection=${connection}

    ${local_path}=    Set Variable    ${TEST_LOG_DIRECTORY}/${tcpdump_log_name}
    ssh.execute    command=echo '${sudo_password}' |sudo -S sudo chown ${sudo_username}:${sudo_username} /tmp/*.pcap
    ...    connection=${connection}
    ssh.download_file    local_path=${local_path}    remote_path=/tmp/${tcpdump_log_name}
    ...                  connection=${connection}
    [Return]    ${local_path}
    [Teardown]    Run Keyword And Ignore Error    ssh.execute
    ...    command=echo '${sudo_password}' |sudo -S rm -rf /tmp/*.pcap    connection=${connection}

Start Ip Traffic Capture
    [Arguments]    ${measurement_point}=Transport_Interface    ${uplane_capturing}=${True}
    ...    ${timeout}=10    ${detailed_output}=${False}
    [Documentation]    Author: Xiang Liang
    ...                Contact: liang.xiang@nokia-sbell.com
    ...                This kw is used to This keyword is to capture ip traffic.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${measurement_point} | No | measurement_point or Transport_Interface |
    ...    | ${timeout} | No | The timeout  |
    ...    | ${uplane_capturing} | No | default is True |
    ...    | ${detailed_output} | No | default is False |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Start Ip Traffic Capture |

    COAM_Admin.Login    alias=ip_traffic_capture
    coam.start_ip_capture_file    measurement_point=${measurement_point}
    ...    uplane_capturing=${uplane_capturing}
    ...    timeout=${timeout}
    ...    connection=ip_traffic_capture
    ...    detailed_output=${detailed_output}
    Log to console    Started ip traffic capture

Stop Ip Traffic Capture
    [Arguments]    ${timeout}=10    ${detailed_output}=${False}
    [Documentation]    Author: Xiang Liang
    ...                Contact: liang.xiang@nokia-sbell.com
    ...                This keyword will stop, generate and download ip traffic from webem.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${timeout} | no | the timeout |
    ...    | ${detailed_output} | No | The default value is False |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Stop Ip Traffic Capture |

    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${target_file_name}=    Set Variable    ${TEST_LOG_DIRECTORY}${/}IP_Traffic_MRBTS-${MRBTS_ID}_${timestamp}.pcap.gz

    coam.stop_ip_capture_file    timeout=${timeout}
    ...    connection=ip_traffic_capture
    ...    detailed_output=${detailed_output}
    coam.generate_ip_capture_file
    ...    timeout=${timeout}
    ...    connection=ip_traffic_capture
    ...    detailed_output=${detailed_output}
    coam.download_ip_capture_file    target_file_name=${target_file_name}
    ...    timeout=100
    ...    connection=ip_traffic_capture
    ...    detailed_output=${detailed_output}
    Log to console    Stopped ip traffic capture and downloaded the file to ${target_file_name}
    [Return]    ${target_file_name}
    [Teardown]    COAM_Admin.Logout    connection=ip_traffic_capture
