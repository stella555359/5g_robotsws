*** Settings ***
Documentation
...   author: chris.l.cao@nokia-sbell.com
...   contact: chris.l.cao@nokia-sbell.com
...   common wireshark keyword

Resource    trans_comm.robot


*** Variables ***
# debug Purpose
${WIRESHARK_DBG}    0


*** Keyword ***
Begin Wireshark
    [Arguments]    ${interface}=eth0    ${filter}=${EMPTY}    ${pwd}=${EMPTY}   ${alias}=default
    [Documentation]    Begin to capture wireshark log, the return is a temporary file name which exists in target server
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    |  Input Parameters | Man. | Description |
    ...    | interface  |  Yes |  the interface name where wireshark log is captured |
    ...    | filter     | No | capturing filter |
    ...    | pwd        | No | password of compute node if wireshark log is captured on compute node |
    ...    *RETURN VALUE*
    ...    Wireshark temporary file name
    ...    Example
    ...    | ${tmp_file}      | Begin Wireshark  |  cplane0  |                        |
    ...    | ${tmp_file}      | Begin Wireshark  |  cplane0  |    icmp                |
    ...    | ${tmp_file}      | Begin Wireshark  |  cplane0  |    icmp and src host 1.1.1.1 |
    ...    | ${tmp_file}      | Begin Wireshark  |  interface=cplane0  |                |
    ...    | ${tmp_file}      | Begin Wireshark  |  interface=cplane0  | filter=icmp    |
    ...    | ${tmp_file}      | Begin Wireshark  |  interface=cplane0  | filter=icmp and src host 1.1.1.1 |
    ...    | ${tmp_file}      | Begin Wireshark  |  interface=xxxx-xxxxx-xxxxxx-xxxxxx  | pwd=systeM!23 |
    ...    | Sleep 5s         |                 |                |                   |
    ...    | ${local_file}    |   Get A File    |  Wireshark     |  mypcapfile.pcap  |
    ...    | End Wireshark    |  ${local_file}  |  ${tmp_file}     |                  |
    ...    | ${txt_file}               |  Get A File      |  Wireshark  |   mypcapfile.txt |
    ...    | Analyze Pcap2txt  |   ${local_file}  |    ${txt_file} |                |
    ...    | ${xml_file}               |   Get A File     |   Wireshark    |  mypcapfile.xml |
    ...    | Analyze Pcap2xml  |   ${local_file}  |   ${xml_file}  |                 |
    ...    | ${txt_file}               |   Get A File     |   Wireshark    |  mypcapfile_filter.txt |
    ...    | Analyze Pcap2txt  |   ${local_file}  |    ${txt_file} |  icmp          |

    Log    ${filter}
    ${out}   ssh.Execute    command=hostname   connection=${alias}

    ${tmpfilefullpath}    Run Keyword If  "compute-" in """${out}"""   Log   Not Done for _Begin Vtrace Wireshark
    ...    ELSE    _Begin Tcpdump Wireshark    interface=${interface}    filter=${filter}   alias=${alias}
    [Return]     ${tmpfilefullpath}


End Wireshark
   [Arguments]     ${log_dst_path}    ${log_src_path}   ${alias}=default
   [Documentation]    Stop capturing wireshark log and get log to local, you can set where to save the log, else if will return a log path.
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    |  Input Parameters | Man. | Description |
    ...    | log_dst_path  |  Yes | the destination log location in DebianVM |
    ...    | log_src_path | Yes | the source log location of VM, RAP,wireshark server, compute node, or other SERVER |
    ...    *RETURN VALUE*
    ...    Wireshark stored path of destination
    ...    Example
    ...    | ${tmp_file}      | Begin Wireshark  |  cplane0  |                        |
    ...    | ${tmp_file}      | Begin Wireshark  |  cplane0  |    icmp                |
    ...    | ${tmp_file}      | Begin Wireshark  |  cplane0  |    icmp and src host 1.1.1.1 |
    ...    | ${tmp_file}      | Begin Wireshark  |  interface=cplane0  |                |
    ...    | ${tmp_file}      | Begin Wireshark  |  interface=cplane0  | filter=icmp    |
    ...    | ${tmp_file}      | Begin Wireshark  |  interface=cplane0  | filter=icmp and src host 1.1.1.1 |
    ...    | ${tmp_file}      | Begin Wireshark  |  interface=xxxx-xxxxx-xxxxxx-xxxxxx  | pwd=systeM!23 |
    ...    | Sleep 5s         |                 |                |                   |
    ...    | ${local_file}    |   Get A File    |  Wireshark     |  mypcapfile.pcap  |
    ...    | End Wireshark    |  ${local_file}  | ${tmp_file}     |                  |
    ...    | ${txt_file}               |  Get A File      |  Wireshark  |   mypcapfile.txt |
    ...    | Analyze Pcap2txt  |   ${local_file}  |    ${txt_file} |                |
    ...    | ${xml_file}               |   Get A File     |   Wireshark    |  mypcapfile.xml |
    ...    | Analyze Pcap2xml  |   ${local_file}  |   ${xml_file}  |                 |
    ...    | ${txt_file}               |   Get A File     |   Wireshark    |  mypcapfile_filter.txt |
    ...    | Analyze Pcap2txt  |   ${local_file}  |    ${txt_file} |  icmp          |
    Sleep  8s
    Send CTRL_C    alias=${alias}

    ${host_type}     Get Host Type    alias=${alias}
    Run Keyword If  "${host_type}"=="DU"       _Get Wireshark From DU OAM  initial_log_path=${log_src_path}  log_stored_path=${log_dst_path}
           ...     alias=${alias}
    ...    ELSE IF  "${host_type}"=="OTHER"     _Get Wireshark From Server   initial_log_path=${log_src_path}  log_stored_path=${log_dst_path}
           ...     alias=${alias}
    ...    ELSE   log  Unknown host to get wireshark!
    [Return]   ${log_dst_path}


_Get Temp File Name
    #${var_exist}=    Run Keyword And Ignore Error    Variable Should Exist    ${LOCAL_IP}
    #${ip}=    Run Keyword If    "${var_exist[0]}"=="FAIL"    Get Local IP
    #...    ELSE    Set Variable    ${LOCAL_IP}
    #${ts}    Get Time    epoch
    #${rand}   Evaluate   random.randint(1,99999)    modules=random
    #${filename}   Set Variable    ${LOCAL_IP}_${ts}_${rand}

    ${filename}    Evaluate    str(uuid.uuid4())    modules=uuid
    ${filename}    String.Replace String    ${filename}    -    ${EMPTY}
    [Return]    ${filename}


_Begin Tcpdump Wireshark
    [Arguments]   ${interface}    ${filter}   ${alias}=default
    ${out}    ssh.Execute     command=mkdir -p /tmp/tmp_wireshark    connection=${alias}
    ${out}    ssh.Execute     command=ls /tmp/tmp_wireshark   connection=${alias}

    ${tmpfilename}    _Get Temp File Name
    ${tmpfilenamefullpath}    Set Variable    /tmp/tmp_wireshark/ws_${tmpfilename}.pcap

    ${sudo}   Get Sudo   alias=${alias}
    ${cmd}    Set Variable If    '${filter}'==''    ${sudo} tcpdump -i ${interface} -s 0 -w ${tmpfilenamefullpath}
    ...    ${sudo} tcpdump -i ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}
    ssh.Send Command    command=${cmd}   connection=${alias}   get_pty=${True}
    Sleep   1s
    [Return]    ${tmpfilenamefullpath}


Validate Packets From Interface
    [Arguments]     ${interface}   ${filter}   ${expected_exist_or_not}   ${capture_time}=25
    [Documentation]   Capture Wireshark Packages And Check Packets exists or not according to filter
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | interface      | Yes | interface |
    ...    | filter         | Yes | filter, type is list, e.g, sctp && ip.addr == 1.1.1.1 |
    ...    | should_exist   | Yes | yes or no , type is list, please see example |
    ...    | capture_time   | No | capture_time, default is 25 secnds |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Connect To CPIF | | | |
    ...    | ${filter} | create list | sctp && ip.src == 1.1.1.1 | sctp && ip.dst == 1.1.1.2 |
    ...    | ${should_exist} | create list | yes | yes |
    ...    | Validate Packets From Interface |  cplane0 |  ${filter} | ${should_exist} |
    ...    | | | | |
    ...    | ${filter} | create list | sctp && ip.src == 1.1.1.1 | sctp && ip.dst == 1.1.1.2 |
    ...    | ${should_exist} | create list | no | yes |
    ...    | Validate Packets From Interface |  cplane0 |  ${filter} | ${should_exist} |

    ${curdate}  Get Current Date
    ${str_curdate}  Replace String Using Regexp   ${curdate}   [:\\s\\.-]    _
    ${file_prefix}   Set Variable   ${interface}_${str_curdate}

    ${temp_file}   Begin Wireshark   interface=${interface}
    ${sctp_backhaul_pcap}   Get A File   Wireshark  ${file_prefix}_pks_from_if.pcap
    Sleep   ${capture_time}
    ENd Wireshark   log_dst_path=${sctp_backhaul_pcap}    log_src_path=${temp_file}

    ${len}   Get Length   ${filter}
    Should Be True    ${len}>0

    FOR   ${i}    IN RANGE    ${len}
         ${decoded_sctp_backhaul_txt}=    Get A File   Wireshark  ${file_prefix}_pks_from_if_${i}.txt
         Analyze Pcap2txt   src=${sctp_backhaul_pcap}    dest=${decoded_sctp_backhaul_txt}  filter=${filter[${i}]}
         ${expected_result}    Set Variable   ${expected_exist_or_not[${i}]}
         Run Keyword If   '${expected_result.upper()}'=='YES'   File Should Not Be Empty   ${decoded_sctp_backhaul_txt}
         ...   ELSE IF   '${expected_result.upper()}'=='NO'   File should be empty   ${decoded_sctp_backhaul_txt}
         ...   ELSE      Fail   'expected_result' should be yes or not, but currently it's ${expected_result}
    END


Validate Protocol Bi-direction From Interface
    [Arguments]   ${interface}   ${local_ip}   ${peer_ip}   ${protocol}   ${expected_exist_or_not}   ${capture_time}=40s
    [Documentation]  Validate Protocol Bi-direction From Interface
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | interface      | Yes | interface name, e.g, cplane0 |
    ...    | local_ip      | Yes | local_ip |
    ...    | peer_ip      | Yes | peer_ip |
    ...    | protocol     | Yes | protocol, e.g, sctp, tcp, udp |
    ...    | expected_exist_or_not   | Yes | yes or no , please see example |
    ...    | capture_time   | No | capture_time, default is 40 secnds |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Connect To CPIF | | | |
    ...    | Validate Protocol Bi-direction From Interface |  cplane0 |  1.1.1.1 | 2.2.2.2 | sctp | yes |
    ...    | Validate Protocol Bi-direction From Interface |  cplane0 |  1.1.1.1 | 2.2.2.2 | sctp | yes | 60s |

    ${ip}    Set Variable If    ":" in """${local_ip}"""    ipv6      ip
    ${filter}    Create List
    ...    ${protocol} && ${ip}.src == ${local_ip} && ${ip}.dst == ${peer_ip}
    ...    ${protocol} && ${ip}.src == ${peer_ip} && ${ip}.dst == ${local_ip}
    ${should_exist}    Create List   ${expected_exist_or_not}   ${expected_exist_or_not}
    Validate Packets From Interface    interface=${interface}   filter=${filter}
     ...   expected_exist_or_not=${should_exist}    capture_time=${capture_time}


Validate Protocol Single-direction From Interface
    [Arguments]   ${interface}   ${local_ip}   ${peer_ip}   ${protocol}   ${expected_exist_or_not}   ${capture_time}=40s
    [Documentation]  Validate Protocol Single-direction From Interface
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | interface      | Yes | interface name, e.g, cplane0 |
    ...    | local_ip      | Yes | local_ip |
    ...    | peer_ip      | Yes | peer_ip |
    ...    | protocol     | Yes | protocol, e.g, sctp, tcp, udp |
    ...    | expected_exist_or_not   | Yes | yes or no , please see example |
    ...    | capture_time   | No | capture_time, default is 40 secnds |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Connect To CPIF | | | |
    ...    | Validate Protocol Single-direction From Interface |  cplane0 |  1.1.1.1 | 2.2.2.2 | sctp | yes |
    ...    | Validate Protocol Single-direction From Interface |  cplane0 |  1.1.1.1 | 2.2.2.2 | sctp | yes | 60s |
    ${ip}    Set Variable If    ":" in """${local_ip}"""    ipv6      ip
    ${filter}    Create List
    ...    ${protocol} && ${ip}.src == ${local_ip} && ${ip}.dst == ${peer_ip}
    ${should_exist}    Create List   ${expected_exist_or_not}
    Validate Packets From Interface    interface=${interface}   filter=${filter}
      ...   expected_exist_or_not=${should_exist}    capture_time=${capture_time}


Validate Packets From File
    [Arguments]    ${wireshark_full_file_name}   ${filter}   ${expected_exist_or_not}
    [Documentation]   Validate Wireshark Packets exists or not according to filter from Wireshark file
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | wireshark_full_file_name | Yes | wireshark_full_file_name which locates in UTE server |
    ...    | filter         | Yes | filter, type is list, e.g, sctp && ip.addr == 1.1.1.1 |
    ...    | expected_result   | Yes | yes or no , type is list, please see example |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Connect To CPIF | |
    ...    | ${log_file_tmp} | Begin Wireshark | cplane0 |
    ...    | sleep           | 5s |
    ...    | ${sctp_backhaul_pcap} |  Get A File  | Wireshark | sctp_backhaul.pcap |
    ...    | End Wireshark         |  ${sctp_backhaul_pcap}   |  ${log_file_tmp} |
    ...    | ${filter} | create list | sctp && ip.src == 1.1.1.1 | sctp && ip.dst == 1.1.1.2 |
    ...    | ${should_exist} | create list | yes | yes |
    ...    | Validate Packets From File |  ${sctp_backhaul_pcap} | ${filter} | ${should_exist} |

    ${curdate}  Get Current Date
    ${str_curdate}  Replace String Using Regexp   ${curdate}   [:\\s\\.-]    _
    ${file_prefix}   Set Variable   ${str_curdate}

    ${len}   Get Length   ${filter}
    Should Be True    ${len}>0

    FOR   ${i}    IN RANGE    ${len}
         ${decoded_sctp_backhaul_txt}=    Get A File   Wireshark  ${file_prefix}_Validate_Wireshark_Packets_${i}.txt
         Analyze Pcap2txt   src=${wireshark_full_file_name}    dest=${decoded_sctp_backhaul_txt}  filter=${filter[${i}]}
         ${expected_result}    Set Variable   ${expected_exist_or_not[${i}]}
         Run Keyword If   '${expected_result.upper()}'=='YES'   File Should Not Be Empty   ${decoded_sctp_backhaul_txt}
         ...   ELSE IF   '${expected_result.upper()}'=='NO'   File should be empty   ${decoded_sctp_backhaul_txt}
         ...   ELSE      Fail   'expected_result' should be yes or not, but currently it's ${expected_result}
    END


Validate Protocol Bi-direction From File
    [Arguments]   ${wireshark_full_file_name}  ${local_ip}   ${peer_ip}   ${protocol}   ${expected_exist_or_not}
    [Documentation]  Validate Protocol Bi-direction From File
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | wireshark_full_file_name | Yes | wireshark_full_file_name which locates in UTE server |
    ...    | local_ip      | Yes | local_ip |
    ...    | peer_ip      | Yes | peer_ip |
    ...    | protocol     | Yes | protocol, e.g, sctp, tcp, udp |
    ...    | expected_exist_or_not   | Yes | yes or no , please see example |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Connect To CPIF | |
    ...    | ${log_file_tmp} | Begin Wireshark | cplane0 |
    ...    | do your action/test steps |
    ...    | ${real_log_file} |  Get A File  | Wireshark | sctp_backhaul.pcap |
    ...    | End Wireshark         |  ${real_log_file}   |  ${log_file_tmp} |
    ...    | Validate Protocol Bi-direction From File | ${sctp_backhaul_pcap}  | 1.1.1.1 | 2.2.2.2 | sctp | yes |
    ${ip}    Set Variable If    ":" in """${local_ip}"""    ipv6      ip
    ${filter}    Create List
    ...    ${protocol} && ${ip}.src == ${local_ip} && ${ip}.dst == ${peer_ip}
    ...    ${protocol} && ${ip}.src == ${peer_ip} && ${ip}.dst == ${local_ip}
    ${should_exist_or_not}    Create List   ${expected_exist_or_not}   ${expected_exist_or_not}
    Validate Packets From File  wireshark_full_file_name=${wireshark_full_file_name}   filter=${filter}
    ...   expected_exist_or_not=${should_exist_or_not}


Validate Protocol Single-direction From File
    [Arguments]   ${wireshark_full_file_name}  ${local_ip}   ${peer_ip}   ${protocol}   ${expected_exist_or_not}
    [Documentation]  Validate Protocol Single-direction From File
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | wireshark_full_file_name | Yes | wireshark_full_file_name which locates in UTE server |
    ...    | local_ip      | Yes | local_ip |
    ...    | peer_ip      | Yes | peer_ip |
    ...    | protocol     | Yes | protocol, e.g, sctp, tcp, udp |
    ...    | expected_exist_or_not   | Yes | yes or no , please see example |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Connect To CPIF | |
    ...    | ${log_file_tmp} | Begin Wireshark | cplane0 |
    ...    | sleep           | 5s |
    ...    | ${sctp_backhaul_pcap} |  Get A File  | Wireshark | sctp_backhaul.pcap |
    ...    | End Wireshark         |  ${sctp_backhaul_pcap}   |  ${log_file_tmp} |
    ...    | Validate Protocol Single-direction From File | ${sctp_backhaul_pcap}  | 1.1.1.1 | 2.2.2.2 | sctp | yes |
    ${ip}    Set Variable If    ":" in """${local_ip}"""    ipv6      ip
    ${filter}    Create List
    ...    ${protocol} && ${ip}.src == ${local_ip} && ${ip}.dst == ${peer_ip}
    ${should_exist_or_not}    Create List   ${expected_exist_or_not}
    Validate Packets From File   wireshark_full_file_name=${wireshark_full_file_name}   filter=${filter}
      ...   expected_exist_or_not=${should_exist_or_not}


_Get Wireshark From Server
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}=default
    [Documentation]    Get log to local from wireshark server
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  log_stored_path | Yes | Where to save log on local PC  |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _Get Wireshark From Server   |   /tmp/tmp_wireshark/ws_10.70.38.195_1514196349_69532.pcap   |  /home/ute/oam.pcap  |
    ssh.Download File   remote_path=${initial_log_path}    local_path=${log_stored_path}   connection=${alias}
    _Delete Old Wireshark File   initial_log_path=${initial_log_path}   alias=${alias}


Get Current Host Time By Linux Cmd
    [Arguments]  ${alias}=default
    [Documentation]    Get Current Host Time By Linux Cmd
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    No input parameter.
    ...    *RETURN VALUE*
    ...    host time with unit of second.
    ...    Example
    ...    | ${sec} | Get Current Host Time By Linux Cmd |
    ${out}    ssh.Execute    command=date +%s    connection=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{5,20}
    [Return]   ${lines}


Get Modified Time By Linux Cmd
    [Arguments]    ${filename}   ${alias}=default
    [Documentation]    Get Modified Time By Linux Cmd for specific file for VNF and R4 RAP
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    No input parameter.
    ...    *RETURN VALUE*
    ...    host time with unit of second.
    ...    Example
    ...    | ${sec} | Get Modified Time By Linux Cmd | /root/a.txt |
    ${out}    ssh.Execute   command=stat --format=%Y ${filename}   connection=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{8,20}
    [Return]   ${lines}


Check File Exist
    [Arguments]  ${filename}    ${alias}=default
    [Documentation]    Check File Exist or not, for VNF, R3 and R4 RAP
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    No input parameter.
    ...    *RETURN VALUE*
    ...    host time with unit of second.
    ...    Example
    ...    | ${bExit} | Check File Exist |  /root/a.txt |
    ${out}    ssh.Execute     command=command=ls ${filename}   connection=${alias}
    ${bExist}   Set Variable If     """No such file or directory""" in """${out}"""     0     1
    [Return]   ${bExist}


_Remove All Temp File If Needed
    [Arguments]  ${FolderName}    ${alias}=default
    ${out}    ssh.Execute       command=ls -F -1 ${FolderName}   connection=${alias}
    ${curr_time}    Get Current Host Time By Linux Cmd   alias=${alias}
    ${lines}    Split To Lines    ${out}     0

    #delete Files 2 Hours Ago
    ${threshold}   Set Variable   7200

    FOR   ${file}    IN    @{lines}
         Continue For Loop If   '${file}'==''
         ${fullname}   Join Path   ${FolderName}   ${file}
         ${bExist}   Check File Exist    ${fullname}   alias=${alias}
         Continue For Loop If   ${bExist}==0
         _Remove One Temp File If Needed    foldername=${FolderName}   filename=${file}
         ...   curr_time=${curr_time}     thrashold=${threshold}   alias=${alias}
    END


_Remove One Temp File If Needed
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}   ${alias}=default
    # ${foldername}:  /tmp/tmp_wireshark
    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}    Get Modified Time By Linux Cmd   filename=${fullname}   alias=${alias}
    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    Run Keyword If   ${bDeleteIt}==1   ssh.Execute   command=rm -rf ${fullname}    connection=${alias}



_Get Wireshark From DU OAM
   [Arguments]   ${initial_log_path}    ${log_stored_path}   ${alias}=default
   [Documentation]    Get log to local from RAP, it will get log from RAP to OAM VM first and then download to local PC
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on compute |
    ...    |  log_stored_path | Yes | Where to save log on local PC  |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | _Get Wireshark From DU OAM  | /tmp/tmp_wireshark/ws_10.70.38.195_1514196349_69532.pcap  | /home/ute/btsauto/hran_ta/oam.pcap |

    _Get Wireshark From Server   initial_log_path=${initial_log_path}    log_stored_path=${log_stored_path}
    ...   alias=${alias}


_Delete Old Wireshark File
    [Arguments]  ${initial_log_path}   ${alias}=default
    ${res}   ssh.Execute   command=ls -l /tmp/tmp_wireshark   connection=${alias}
    Log   ${res}
    Run Keyword If   ${WIRESHARK_DBG}==0     ssh.Execute   command=rm -f ${initial_log_path}     connection=${alias}

    #for debug
    ${res}   Run Keyword If   ${WIRESHARK_DBG}==1    ssh.Execute   command=ls -l /tmp/tmp_wireshark   connection=${alias}
    Run Keyword If   ${WIRESHARK_DBG}==1   Log   ${res}

    Run Keyword If   ${WIRESHARK_DBG}==0   _Remove All Temp File If Needed    FolderName=/tmp/tmp_wireshark   alias=${alias}

