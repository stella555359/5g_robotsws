*** Settings ***
Documentation
...  fen.huang@nokia-sbell.com

Resource    aic_common_resources.robot


*** Keywords ***
############################## CU LOG Start ##############################
====== CU LOG Start ======
     Log To Console  \n*** only used for readable ***

CU Save Snapshot
    [Arguments]     ${gnb_index}=0
    [Documentation]    Gets local snapshot and saves it under given file path.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <19-Nov-2019>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...
    ...    *RETURN VALUE*
    ...    NA
    ...    Example
    ...    |  CU Save Snapshot  |   |
   Log To Console   \n*** Start to save snapshot ***
   CU Login  ${gnb_index}
#   ${snapshot_file_dir}=  Get A Directory   snapshot
   ${snapshot_file_dir}=    OperatingSystem.Join Path    /home/ute/results/
   cu.Get_Local_Snapshot  ${snapshot_file_dir}   use_m2m=False
   ${file_list}=   OperatingSystem.List_Directory   ${snapshot_file_dir}
   ${file_num}=   Get Length   ${file_list}
   Should Be True    ${file_num}>0   No snapshot files found in local after saving snapshot operation!
   [Return]  ${snapshot_file_dir}/${file_list[0]}
   [Teardown]  Run Keyword And Ignore Error   CU Logout

CU Collect Journal Log On All VMs
    [Documentation]    Gets all journal logs and saves them.
        ...  author:   rainie.wu@nokia-sbell.com
        ...    | Input Parameters | Man. | Description |
        ...    None
        ...    *RETURN VALUE*
        ...    None

        ...    Example
        ...    |  CU Collect Journal Log On All VMs  |   |
    ${count_of_gnbs}=  get length  ${tl.gnbs}
    FOR  ${gnb_index}  IN RANGE  ${count_of_gnbs}
        CU Collect Journal Log On All VMs On Specified GNB  ${gnb_index}
    END


CU Collect Journal Log On All VMs On Specified GNB
    [Arguments]  ${gnb_index}=${0}
    [Documentation]    Gets all journal logs on specified gnb and saves them.
        ...  author:   rainie.wu@nokia-sbell.com
        ...    | Input Parameters | Man. | Description |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
        ...    *RETURN VALUE*
        ...    None

        ...    Example
        ...    |  CU Collect Journal Log On All VMs On Specified GNB  |   |
    ${username}=  Set Variable  ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ${user}=  run keyword if  '${username}'=='robot'  set variable  robot
    ...       ELSE     set variable  root
    log to console  ${\n}cu get ALL journal logs start
    ${vm_hostname_list}=  CU Get All VMs Hostame  gnb_index=${gnb_index}
    ${active_oam}=  CU Get Active OAM  gnb_index=${gnb_index}
    ${alias}   get unique id
    CU SSH To OAM     gnb_index=${gnb_index}  alias=${alias}
    issh.Execute  command=sudo mkdir /home/${username}/journal_log  check_result=${False}  alias=${alias}
    issh.Execute  command=sudo chmod 777 /home/${username}/journal_log  check_result=${False}  alias=${alias}
    issh.set_timeout  timeout=120  alias=${alias}
    FOR    ${vm_hostname}    IN    @{vm_hostname_list}
       ${hostname} =    Set Variable    ${vm_hostname}.local
       issh.Execute  command=ssh ${hostname}  check_result=${False}  alias=${alias}
       ${output}=  issh.Execute  command=hostname  check_result=${False}  alias=${alias}
       ${output}=   convert to lowercase   ${output}
       should contain   ${output}   ${vm_hostname}   ssh to vm ${vm_hostname} failed!
       issh.Execute  command=sudo journalctl -b > /tmp/${vm_hostname}.log
    ...               check_result=${False}  alias=${alias}
       issh.Execute  command=sudo chmod 777 /tmp/${vm_hostname}.log  check_result=${False}  alias=${alias}
       issh.Execute
    ...    command=scp -r /tmp/${vm_hostname}.log ${user}@${active_oam}.local:/home/${username}/journal_log
    ...    check_result=${False}  alias=${alias}
       issh.Execute  command=sudo rm -rf /tmp/${vm_hostname}.log  check_result=${False}    alias=${alias}
    END
    ${oam_alias}  get unique id
    CU SSH To OAM  gnb_index=${gnb_index}  alias=${oam_alias}
    issh.set_timeout  timeout=120  alias=${oam_alias}
    ${journal_dir}=  Get A Directory  journal_log/gnb${gnb_index}_${username}
    issh.download_file  remote_path=/home/${username}/journal_log/*.log  local_path=${journal_dir}/
    ...                 alias=${oam_alias}
    issh.Execute  command=sudo rm -rf /home/${username}/journal_log  check_result=${False}  alias=${oam_alias}
    log to console    ${\n}cu get ALL journal logs end
    [Teardown]  run keywords  Disconnect Interactive Connection  alias=${oam_alias}
    ...             AND       Disconnect Interactive Connection  alias=${alias}

CU Collect Journal Log On Specified VM
    [Arguments]  ${vm_type}  ${gnb_index}=${0}
    [Documentation]    Gets journal log on specified VM except OAM and saves it.
        ...  author:   rainie.wu@nokia-sbell.com
        ...    | Input Parameters | Man. | Description |
        ...    |  vm_type   | Yes |  specified VM type to get journal log |
        ...    |  vm_index   | No |  Indicate which vm will be used, 0 in default |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
        ...    *RETURN VALUE*
        ...    None

        ...    Example
        ...    |  CU Collect Journal Log On Specified VM  |  UPUE  |

    ${username}=  Set Variable  ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ${user}=  run keyword if  '${username}'=='robot'  set variable  robot
    ...       ELSE     set variable  root
    ${vm}=   convert to lowercase   ${vm_type}
    log to console    ${\n}cu get ${vm_type} journal log start
    ${active_oam}=  CU Get Active OAM  gnb_index=${gnb_index}
    ${oam_alias}  get unique id
    CU SSH To OAM  gnb_index=${gnb_index}  alias=${oam_alias}
    issh.Execute  command=sudo mkdir /home/${username}/journal_log  check_result=${False}  alias=${oam_alias}
    issh.Execute  command=sudo chmod 777 /home/${username}/journal_log  check_result=${False}  alias=${oam_alias}
    issh.set_timeout  timeout=120  alias=${oam_alias}
    ${alias}=  get unique id
    run keyword  CU SSH To ${vm_type}  gnb_index=${gnb_index}  alias=${alias}

    issh.set_timeout  timeout=120  alias=${alias}
    issh.Execute  command=sudo journalctl -b > /tmp/${vm_type}.log  check_result=${False}    alias=${alias}
    issh.Execute  command=sudo chmod 777 /tmp/${vm_type}.log  check_result=${False}  alias=${alias}
    issh.Execute  command=scp -r /tmp/${vm_type}.log ${user}@${active_oam}.local:/home/${username}/journal_log
    ...    check_result=${False}  alias=${alias}
    issh.Execute  command=sudo rm /tmp/${vm_type}.log  check_result=${False}    alias=${alias}
    ${journal_dir}=  Get A Directory  journal_log/gnb${gnb_index}_${username}
    issh.download_file  remote_path=/home/${username}/journal_log/*.log  local_path=${journal_dir}/
    ...                 alias=${oam_alias}
    issh.Execute  command=sudo rm -rf /home/${username}/journal_log  check_result=${False}    alias=${oam_alias}
    log to console    ${\n}cu get ${vm_type} journal log end
    [Teardown]  run keywords  Disconnect Interactive Connection  alias=${oam_alias}
    ...             AND       Disconnect Interactive Connection  alias=${alias}

CU Collect Startup Logs On All VMs
    [Documentation]    Gets all journal logs and saves them.
        ...  author:   rainie.wu@nokia-sbell.com
        ...    | Input Parameters | Man. | Description |
        ...    None
        ...    *RETURN VALUE*
        ...    None

        ...    Example
        ...    |  CU Collect Startup Logs On All VMs  |   |
    ${count_of_gnbs}=  get length  ${tl.gnbs}
    FOR  ${gnb_index}  IN RANGE  ${count_of_gnbs}
        CU Collect Startup Logs On All VMs On Specified GNB    ${gnb_index}
    END

CU Collect Startup Logs On All VMs On Specified GNB
    [Arguments]  ${gnb_index}=${0}
    [Documentation]    Gets all startup logs and saves them.
        ...  author:   rainie.wu@nokia-sbell.com
        ...    | Input Parameters | Man. | Description |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
        ...    *RETURN VALUE*
        ...    None

        ...    Example
        ...    |  CU Collect Startup Logs On All VMs On Specified GNB  |   |
    ${username}=  Set Variable  ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ${user}=  run keyword if  '${username}'=='robot'  set variable  robot
    ...       ELSE     set variable  root
    log to console    ${\n}cu get ALL startup logs start
    ${vm_hostname_list}=  CU Get All VMs Hostame  gnb_index=${gnb_index}
    ${active_oam}=  CU Get Active OAM  gnb_index=${gnb_index}

    ${oam_alias}  get unique id
    CU SSH To OAM  gnb_index=${gnb_index}  alias=${oam_alias}
#    issh.set_timeout  timeout=120  alias=${oam_alias}
    ${startup_dir}=  Get A Directory  startup_logs/gnb${gnb_index}_${username}

    FOR    ${vm_hostname}    IN    @{vm_hostname_list}
       issh.Execute  command=sudo mkdir -p /home/${username}/startup_logs/${vm_hostname}
    ...               check_result=${False}  alias=${oam_alias}
       issh.Execute  command=sudo chmod 777 /home/${username}/startup_logs/${vm_hostname}
    ...               check_result=${False}  alias=${oam_alias}
    END

    ${alias}   get unique id
    CU SSH To OAM  gnb_index=${gnb_index}  alias=${alias}
#    issh.set_timeout  timeout=120  alias=${alias}

    FOR    ${vm_hostname}    IN    @{vm_hostname_list}
       ${hostname} =    Set Variable    ${vm_hostname}.local
       issh.Execute  command=ssh ${hostname}   check_result=${False}  alias=${alias}
       ${output}=  issh.Execute  hostname  check_result=${False}  alias=${alias}
       ${output}=   convert to lowercase   ${output}
       should contain   ${output}   ${vm_hostname}   ssh to vm ${vm_hostname} failed!
       ${number}=  issh.Execute  ls /tmp | grep ^startup* | wc -l  check_result=${False}  alias=${alias}
       ${number}=  get line  ${number}   1
       run keyword if    '${number}'!='0'   run keywords
    ...    issh.Execute  command=sudo chmod -R 777 /tmp/startup*  check_result=${False}  alias=${alias}  AND
    ...    issh.Execute
    ...      command=scp -r /tmp/startup* ${user}@${active_oam}.local:/home/${username}/startup_logs/${vm_hostname}
    ...      check_result=${False}  alias=${alias}  AND
    ...    issh.Execute  command=sudo chmod -R 777 /home/${username}/startup_logs
    ...                  check_result=${False}  alias=${oam_alias}   AND
    ...    issh.download_file  remote_path=/home/${username}/startup_logs/${vm_hostname}/*
    ...                        local_path=${startup_dir}/${vm_hostname}/  alias=${oam_alias}
    END

    issh.Execute  command=sudo rm -rf //home/${username}/startup_logs  check_result=${False}  alias=${oam_alias}

    log to console    ${\n}cu get ALL startup logs end
    [Teardown]  run keywords  Disconnect Interactive Connection  alias=${oam_alias}
    ...             AND       Disconnect Interactive Connection  alias=${alias}


############################## CU LOG End ##############################
====== CU LOG End ======
     Log To Console  \n*** only used for readable ***


############################## vDU LOG Start ##############################
====== VDU LOG Start ======
     Log To Console  \n*** only used for readable ***

Analyze Pcap2txt
    [Arguments]  ${src}   ${dest}    ${filter}=${EMPTY}
    [Documentation]    Convert wireshark pcap file to TXT file according to filter
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | src  |  Yes | the pcap file to be converted in UTE server |
    ...    | dest | Yes | the target TXT file to be generated in UTE server |
    ...    | filter | No | filter used to generate targe TXT file |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | ${local_file}     |  set variable        |  /home/ute/mypcap.pcap |                    |
    ...    | ${txt_file}       |   Get A File         |   Wireshark         |  mypcapfile_filter.txt |
    ...    | Analyze Pcap2txt  |   src=${local_file}  |    dest=${txt_file} |                        |

    OperatingSystem.File Should Exist    ${src}
    ${cmd}   Set Variable If   '${filter}'==''   tshark -r ${src} -V -Q 2>/dev/null >${dest}
    ...    tshark -r ${src} -V -Q -Y "${filter}" 2>/dev/null >${dest}
    ${rc}   ${out}   OperatingSystem.Run And Return Rc And Output    ${cmd}


Analyze Pcap2xml
    [Arguments]  ${src}   ${dest}    ${filter}=${EMPTY}  ${max_count}=100000
    [Documentation]    Convert wireshark pcap file to XML file according to filter
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | src  |  Yes | the pcap file to be converted in UTE server |
    ...    | dest | Yes | the target XML file to be generated in UTE server |
    ...    | filter | No | filter used to generate targe XML file |
    ...    | max_count | No | expected number |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | ${local_file}     |  set variable        |  /home/ute/mypcap.pcap |              |
    ...    | ${xml_file}       |  Get A File          |  Wireshark          |   mypcapfile.xml |
    ...    | Analyze pcap2xml  |   src=${local_file}  |   dest=${xml_file}  |   filter=icmp    |

    OperatingSystem.File Should Exist    ${src}
    ${cmd}    Set Variable If    '${filter}'==''    tshark -r "${src}" -c ${max_count} -T pdml -V -Q 2>/dev/null > "${dest}"
    ...    tshark -r "${src}" -c ${max_count} -T pdml -V -Q -Y "${filter}" 2>/dev/null >${dest}
    ${rc}    Process.Run Process    ${cmd}   shell=True

Download And Extract Luashark Package
    [Arguments]  ${luashark_path}  ${vdu_version}
     [Documentation]    Download And Extract Luashark Package from website, return luashark path
    ...    *AUTHOR* rainie.wu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | luashark_path  |  Yes |  the interface name where wireshark log is captured |
    ...    | vdu_version     | Yes | capturing filter |
    ...
    ...    *RETURN VALUE*
    ...    Path of Luashark
    ...
    ...    Example
    ...    | ${luashark_path}   |   Get A Directory    |  Luashark  |
    ...    | Download And Extract Luashark Package | luashark_path=${luashark_path} |  vdu_version=0.390.2090  |

    ${Luashark_Link}=  SET VARIABLE  https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release
    OperatingSystem.Run   command=wget -P ${luashark_path} ${Luashark_Link}/${vdu_version}/luashark-${vdu_version}.zip
    OperatingSystem.Run
    ...  command=cd ${luashark_path};unzip luashark-${vdu_version}.zip -d luashark
    [Return]  ${luashark_path}

Begin Wireshark
     [Arguments]    ${interface}=eth0    ${filter}=${EMPTY}    ${alias}=default
     ...   ${host_type}=${EMPTY}   ${index}=0    ${ru_index}=1   ${pod_abbr}=${EMPTY}   ${container}=${EMPTY}
     [Documentation]    Begin to capture wireshark log, the return value is a temporary file name which exists in target server
    ...    Target server includes VCU VM/VDU container/FHGW/FHGW ruproxy container/wireshark server/UTE server/CMP server/Classical OAM/NOM.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | interface  |  Yes |  the interface name where wireshark log is captured |
    ...    | filter     | No | capturing filter |
    ...    | host_type   | No | Valid value is FHGW, VDUC, RUPROXY, VCU or ${EMPTY}. |
    ...    |            |    | when host_type is FHGW, it means to capture log in FHGW server |
    ...    |            |    | when host_type is RUPROXY, it means to capture log in FHGW RUPROXY container |
    ...    |            |    | when host_type is VDUC, it means to capture log in vDU Container, and pod_abbr/container/index are used |
    ...    |            |    | when host_type is ${EMPTY}, it means to capture wireshark log linux server except FHGW/VDUC |
    ...    |            |    | Default value is ${EMPTY}. Please see example as below |
    ...    | index     | No | when host_type is VDUC, it means vdu_index, default value is 0. Note: it's not used when host_type is FHGW |
    ...    | ru_index  | No | Radio Unit index, when host_type is RUPROXY, it is meanfull, default value is 1 |
    ...    | alias      | No | alias name  |
    ...    | pod_abbr  | No | when host_type is VDUC, it is used |
    ...    | container | No | when host_type is VDUC, it is used |
    ...
    ...    *RETURN VALUE*
    ...    Wireshark temporary file name in target server. It will be automatically deleted after calling 'End Wireshark'.
    ...
    ...    Example
    ...    For general linux server, including wireshark server/UTE server/CMP server/Classical OAM/NOM/OE server
    ...    | issh.Connect_To | ip=x.x.x.x |  username=myusername | password=mypassword |
    ...    | ${tmpfile_pcap} | Begin Wireshark  |  eth0  |                        |
    ...    | ${tmpfile_pcap} | Begin Wireshark  |  eth0  |    icmp                |
    ...    | ${tmpfile_pcap} | Begin Wireshark  |  eth0  |    icmp and src host 1.1.1.1 |
    ...    | ${tmpfile_pcap} | Begin Wireshark  |  interface=eth0  |                |
    ...    | ${tmpfile_pcap} | Begin Wireshark  |  interface=eth0  | filter=icmp    |
    ...    | ${tmpfile_pcap} | Begin Wireshark  |  interface=eth0  | filter=icmp and src host 1.1.1.1 |
    ...    | Sleep           |   3          |                 |                |
    ...    | ${local_file}   |   Get A File    |  Wireshark     |  mypcapfile.pcap  |
    ...    | End Wireshark   |  log_dst_path=${local_file}  |  log_src_path=${tmpfile_pcap} |
    ...    | ${xml_file}     |   Get A File     |   Wireshark    |  mypcapfile.xml |
    ...    | Analyze Pcap2xml |   ${local_file}  |   ${xml_file}  |                 |
    ...    | ${entries}       | cpdml.Get_Pdml_Entries |  ${xml_file}    | icmp.type   | show     | 8        |
    ...    | ${showname}      | cpdml.Get_Attrib_Value_From_Pdml_Entries |  ${entries} | icmp.type |   showname |
    ...    |  # Note: cpdml.Get_Attrib_Value_From_Pdml_Entries does not support XPATH! But pcap.get_field_value_by_xpath supports it |
    ...    | disconnect interactive connection |
    ...
    ...    For FHGW host
    ...    | Connect To FHGW |
    ...    | ${tmpfile_pcap} | Begin Wireshark | interface=eth0 | host_type=FHGW  | |
    ...    | ${tmpfile_pcap} | Begin Wireshark | interface=eth0 | filter=icmp | host_type=FHGW  | |
    ...    | Sleep           | 3 |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} |  |
    ...    | disconnect interactive connection |
    ...
    ...    For FHGW host with alias
    ...    | Connect To FHGW | alias=myalias |
    ...    | ${tmpfile_pcap} | Begin Wireshark | interface=eth0 | host_type=FHGW  | alias=myalias |
    ...    | ${tmpfile_pcap} | Begin Wireshark | interface=eth0 | filter=icmp | host_type=FHGW | alias=myalias |
    ...    | Sleep           | 3 |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} | alias=myalias |
    ...    | disconnect interactive connection | alias=myalias |
    ...
    ...    For RUPROXY container in FHGW
    ...    | Connect To FHGW |
    ...    | ${tmpfile_pcap}  | Begin Wireshark | interface=eth0 | host_type=RUPROXY | ru_index=1 |
    ...    | Sleep            | 3 |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} |  |
    ...    | Disconnect From FHGW |
    ...
    ...    For RUPROXY container in FHGW with alias
    ...    | Connect To FHGW | alias=myalias |
    ...    | ${tmpfile_pcap}  | Begin Wireshark | interface=eth0 | host_type=RUPROXY | alias=myalias |
    ...    | Sleep            | 3 |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} | alias=myalias |
    ...    | issh.Disconnect | alias=myalias |
    ...
    ...    For VDUC(VDU Container)
    ...    | Connect to vDU Node | pod_abbr=oamcp | vdu_index=0 | master_alias=alias1 | node_alias=alias2 |
    ...    | ${tmpfile_pcap}  | Begin Wireshark | interface=oamfh | host_type=VDUC | pod_abbr=oamcp | container=oamfh | alias=alias2 |
    ...    | Sleep            | 3 |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} | alias=alias2 |
    ...    | tafssh.disconnect | connection=alias2 |
    ...    | tafssh.disconnect | connection=alias1 |
    ...
    ...    For VCUC(VCU CNF Container)
    ...    | ${alias} | Connect To CU K8S Master With Admin | vdu_index=0  |
    ...    | ${tmpfile_pcap}  | Begin Wireshark | interface=f1cvlan | host_type=VCUC | pod_abbr=cpif | container=cpif | alias=${alias} |
    ...    | Sleep            | 3 |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} | alias=${alias} |
    ...    | disconnct interactively connection | alias=${alias} |
    ...
    ...    For VCU VM
    ...    | CU SSH To OAM |
    ...    | ${tmpfile_pcap} |  Begin Wireshark | interface=oam | host_type=VCU | filter=icmp |
    ...    | sleep           |  10   |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} |
    ...    | ${all_packets}   | pcap.load_pcap_file | pcap_file=${local_file} |
    ...    | ${pkts_after_filter} | pcap.filter_packets_by_expression | pdml_list=${all_packets} | filter_expression=ip.src==10.69.66.199 |
    ...    | ${pkts_after_filter} | pcap.filter_packets_by_expression | pdml_list=${all_packets} | filter_expression=x2ap |
    ...    | ${out} | pcap.get_field_value_by_xpath     | pdml_list=${pkts_after_filter} | xpath=.//icmp.type |
    ...    | ${out} | pcap.get_field_value_by_xpath     | pdml_list=${pkts_after_filter} | xpath=.//x2ap.X2AP_PDU//x2ap.pLMN_Identity/e212.mcc |
    ...    | ${out} | pcap.get_field_value_by_xpath     | pdml_list=${pkts_after_filter} |
    ...    |  ...   | xpath=.//x2ap.X2AP_PDU//x2ap.value_element/x2ap.SgNBAdditionRequest_element/x2ap.protocolIEs |
    ...    | ${out} | pcap.get_field_value_by_xpath     | pdml_list=${pkts_after_filter} | xpath=.//e212.mcc                            |
    ...    | disconnect interactive connection |
    ...
    ...    For VCU CPIF
    ...    | CU SSH To CPIF |
    ...    | ${tmpfile_pcap} |  Begin Wireshark | interface=x2 | host_type=VCU |
    ...    | sleep           |  10   |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} |
    ...    | disconnect interactive connection|
    ...
    ...    For VCU CPIF with alias
    ...    | CU SSH To CPIF | alias=myalias |
    ...    | ${tmpfile_pcap} |  Begin Wireshark | interface=x2 | host_type=VCU | alias=myalias |
    ...    | sleep           |  10   |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} | alias=myalias |
    ...    | disconnect interactive connection | alias=myalias |
    ...
    ...    For LTE classical OAM
    ...    | Connect To LTE |
    ...    | ${tmpfile_pcap} |  Begin Wireshark | interface=br1 | filter=sctp |
    ...    | sleep           |  30   |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} |
    ...    | ${all_packets}   | pcap.load_pcap_file | pcap_file=${local_file} |
    ...    | ${pkts_after_filter} | pcap.filter_packets_by_expression | pdml_list=${all_packets} | filter_expression=ip.src==10.69.66.199 |
    ...    | ${out} | pcap.get_field_value_by_xpath     | pdml_list=${pkts_after_filter} | xpath=.//x2ap.X2AP_PDU//x2ap.pLMN_Identity/e212.mcc |
    ...    | ${out} | pcap.get_field_value_by_xpath     | pdml_list=${pkts_after_filter} | xpath=.//e212.mcc                            |
    ...    | disconnect interactive connection  |
    ...
    ...    For UTE
    ...    | Connect To UTE |
    ...    | ${tmpfile_pcap} |  Begin Wireshark | interface=eth0 | filter=icmp |
    ...    | sleep           |  10   |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} |
    ...    | issh.Disconnect |
    ...
    ...    For OE server
    ...    |  Connect To K8s Master Interactively |
    ...    | ${tmpfile_pcap} |  Begin Wireshark | interface=ens11f0 |
    ...    | sleep           |  10   |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} |
    ...    | disconnect interactive connection  |
    ...
    ...    For NOM
    ...    | SSH To NOM |
    ...    | ${tmpfile_pcap} |  Begin Wireshark | interface=eth0 | filter=icmp |
    ...    | sleep           |  10   |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} |
    ...    | disconnect interactive connection  |
    ...
    ...    For NOM with alias
    ...    | SSH To NOM | alias=myalias |
    ...    | ${tmpfile_pcap} |  Begin Wireshark | interface=eth0 | filter=icmp | alias=myalias |
    ...    | sleep           |  10   |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} | alias=myalias |
    ...    | disconnect interactive connection | alias=myalias |
    ...
    ${host_type}   Set Variable If    "${host_type}"!="${EMPTY}"     ${host_type.upper()}   ${EMPTY}
    Run Keyword If    "${host_type}"!="${EMPTY}"   Log To Console  Begin Wireshark, host_type:${host_type}

    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="FHGW"    _Begin Tcpdump Wireshark FHGW   index=${index}
      ...   interface=${interface}    filter=${filter}   alias=${alias}
    Return From Keyword If   "${host_type}"=="FHGW"   ${tmpfilefullpath}

    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="RUPROXY"    _Begin Tcpdump Wireshark RUPROXY     index=${index}
      ...   interface=${interface}    filter=${filter}   alias=${alias}   ru_index=${ru_index}
    Return From Keyword If   "${host_type}"=="RUPROXY"   ${tmpfilefullpath}

    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="VDUC"    _Begin Tcpdump Wireshark VDUC    interface=${interface}    filter=${filter}
      ...   pod_abbr=${pod_abbr}   container=${container}   index=${index}   alias=${alias}
    Return From Keyword If   "${host_type}"=="VDUC"   ${tmpfilefullpath}

    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="VDUCI"    _Begin Tcpdump Wireshark VDUCi    interface=${interface}    filter=${filter}
      ...   pod_abbr=${pod_abbr}   container=${container}   index=${index}   alias=${alias}
    Return From Keyword If   "${host_type}"=="VDUCi"   ${tmpfilefullpath}

    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="VCUC"    _Begin Tcpdump Wireshark VCUC    interface=${interface}    filter=${filter}
      ...   pod_abbr=${pod_abbr}   container=${container}  index=${index}   alias=${alias}
    Return From Keyword If   "${host_type}"=="VCUC"   ${tmpfilefullpath}

    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="VCU"    _Begin Tcpdump Wireshark VCU    interface=${interface}    filter=${filter}
      ...    index=${index}   alias=${alias}
    Return From Keyword If   "${host_type}"=="VCU"   ${tmpfilefullpath}

    ${host_type}    _Wireshark Get Host Type   alias=${alias}
    Log To Console  Begin Wireshark, hostname:${host_type}

    ${tmpfilefullpath}   Run Keyword If  "OTHER"=="${host_type}"   _Begin Tcpdump Wireshark In General Server  interface=${interface}
      ...   filter=${filter}  alias=${alias}
    ...    ELSE   Log   Unknow linux server!

    [Return]     ${tmpfilefullpath}


End Wireshark
    [Arguments]     ${log_dst_path}    ${log_src_path}   ${alias}=default
    [Documentation]    Stop capturing wireshark log and get log to local.
    ...    Target server includes VDU container/FHGW/wireshark server/UTE server/CMP server/Classical OAM.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | log_dst_path  |  Yes | the destination log location in DebianVM |
    ...    | log_src_path | Yes | the source log location of VM, RAP,wireshark server, compute node, or other SERVER |
    ...    | alias       | No | alias name, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    Please refer to examples of 'Begin Wireshark'
    ...
    Sleep  2
    ${path}  ${pcap_file}  OperatingSystem.Split Path   ${log_src_path}
    ${tmp}   Split String  ${pcap_file}  _
    ${host_type}  Set Variable  ${tmp[1]}

    ${host_type}   Run Keyword If    "${host_type}"!="${EMPTY}"   Set Variable  ${host_type.upper()}
    Log To Console  End Wireshark, host_type:${host_type}

    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="FHGW"   _Get Wireshark From FHGW
      ...   initial_log_path=${log_src_path}  log_stored_path=${log_dst_path}
      ...   alias=${alias}
    Return From Keyword If   "${host_type}"=="FHGW"

    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="RUPROXY"   _Get Wireshark From RUPROXY
      ...   initial_log_path=${log_src_path}  log_stored_path=${log_dst_path}
      ...   alias=${alias}
    Return From Keyword If   "${host_type}"=="RUPROXY"

    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="VDUC"   _Get Wireshark From VDUC
      ...   initial_log_path=${log_src_path}  log_stored_path=${log_dst_path}
      ...   alias=${alias}
    Return From Keyword If   "${host_type}"=="VDUC"

    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="VCUC"   _Get Wireshark From VCUC
      ...   initial_log_path=${log_src_path}  log_stored_path=${log_dst_path}
      ...   alias=${alias}
    Return From Keyword If   "${host_type}"=="VCUC"

    ${host_type}  Set Variable If   ${host_type.__len__()}>=3   ${host_type[0:3]}   ${host_type}
    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="VCU"   _Get Wireshark From VCU
      ...   initial_log_path=${log_src_path}  log_stored_path=${log_dst_path}
      ...   alias=${alias}
    Return From Keyword If   "${host_type}"=="VCU"

    Send CTRL_C Interactively   alias=${alias}
    Sleep  1

    ${host_type}    _Wireshark Get Host Type   alias=${alias}
    Run Keyword If  "${host_type}"=="OTHER"   _Get Wireshark From General Linux Server
             ...  initial_log_path=${log_src_path}  log_stored_path=${log_dst_path}   alias=${alias}
       ...   ELSE   log  Unknown host to get wireshark!
    [Return]   ${log_dst_path}


Begin Wireshark F1 On VDU
    [Arguments]     ${filter}=${EMPTY}
    [Documentation]    Begin Wireshark F1 On VDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...
    ...    *RETURN VALUE*
    ...    handle
    ...
    ...    Example
    ...   | ${handle} | Begin Wireshark F1 On VDU |  filter=tcp and port 8080 |
    ...   | sleep      |  350 |
    ...   | ${local_pcap} | Get A File  Wireshark |   step2.pcap  |
    ...   |  End Wireshark F1 On VDU | log_dst_path=${local_pcap}  |  handle=${handle} |
    ...
    ${master_alias}  get unique id  prefix=master
    ${node_alias}    get unique id  prefix=node

    Connect to vDU Node   container_abbr=cprt    master_alias=${master_alias}    node_alias=${node_alias}
    ${f1_c_interface}   Get VDU Container Interface Name   container=cprt  network=f1   connection=${master_alias}

    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=cprt
    ${tmp_file}   Begin Wireshark  interface=${f1_c_interface}  host_type=VDUC  pod_abbr=${pod_abbr}  container=cprt
       ...   alias=${node_alias}  filter=${filter}
    ${handle}   set variable   ${node_alias}_${tmp_file}
    [Return]   ${handle}


End Wireshark F1 On VDU
    [Arguments]     ${log_dst_path}    ${handle}
    [Documentation]    End Wireshark F1 On VDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | ${handle} | Begin Wireshark F1 On VDU |  filter=tcp and port 8080 |
    ...   | sleep      |  350 |
    ...   | ${local_pcap} | Get A File  Wireshark |   step2.pcap  |
    ...   |  End Wireshark F1 On VDU | log_dst_path=${local_pcap}  |  handle=${handle} |
    ...
    ${node_alias}   set variable    ${handle.split('_')[0]}
    ${log_src_path}   set variable    ${handle.replace("${node_alias}_","")}
    End Wireshark     log_dst_path=${log_dst_path}   log_src_path=${log_src_path}   alias=${node_alias}


Begin Wireshark Mplane On VDU
    [Arguments]     ${filter}=${EMPTY}
    [Documentation]    Begin Wireshark Mplane On VDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...
    ...    *RETURN VALUE*
    ...    handle
    ...
    ...    Example
    ...   | ${handle} | Begin Wireshark Mplane On VDU |  filter=tcp and port 8080 |
    ...   | sleep      |  350 |
    ...   | ${local_pcap} | Get A File  Wireshark |   step2.pcap  |
    ...   |  End Wireshark Mplane On VDU | log_dst_path=${local_pcap}  |  handle=${handle} |
    ...
    ${master_alias}  get unique id  prefix=master
    ${node_alias}    get unique id  prefix=node

    ${container_abbr}   set variable   oam
    ${network}    set variable   oam
    Connect to vDU Node   container_abbr=${container_abbr}    master_alias=${master_alias}    node_alias=${node_alias}
    ${oam_interface}   Get VDU Container Interface Name   container=${container_abbr}  network=${network}   connection=${master_alias}

    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=${container_abbr}
    ${tmp_file}   Begin Wireshark  interface=${oam_interface}  host_type=VDUC  pod_abbr=${pod_abbr}  container=${container_abbr}
       ...   alias=${node_alias}  filter=${filter}
    ${handle}   set variable   ${node_alias}_${tmp_file}
    [Return]   ${handle}


End Wireshark Mplane On VDU
    [Arguments]     ${log_dst_path}    ${handle}
    [Documentation]    End Wireshark Mplane On VDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | ${handle} | Begin Wireshark Mplane On VDU |  filter=tcp |
    ...   | sleep      |  350 |
    ...   | ${local_pcap} | Get A File  Wireshark |   step2.pcap  |
    ...   |  End Wireshark Mplane On VDU | log_dst_path=${local_pcap}  |  handle=${handle} |
    ...
    ${node_alias}   set variable    ${handle.split('_')[0]}
    ${log_src_path}   set variable    ${handle.replace("${node_alias}_","")}
    End Wireshark     log_dst_path=${log_dst_path}   log_src_path=${log_src_path}   alias=${node_alias}


Begin Wireshark FHM On VDU
    [Arguments]     ${filter}=${EMPTY}
    [Documentation]    Begin Wireshark FHM On VDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...
    ...    *RETURN VALUE*
    ...    handle
    ...
    ...    Example
    ...   | ${handle} | Begin Wireshark FHM On VDU |  filter=tcp and port 8080 |
    ...   | sleep      |  350 |
    ...   | ${local_pcap} | Get A File  Wireshark |   step2.pcap  |
    ...   |  End Wireshark FHM On VDU | log_dst_path=${local_pcap}  |  handle=${handle} |
    ...
    ${master_alias}  get unique id  prefix=master
    ${node_alias}    get unique id  prefix=node

    ${container_abbr}   set variable   oamfh
    ${network}    set variable   fhm
    Connect to vDU Node   container_abbr=${container_abbr}    master_alias=${master_alias}    node_alias=${node_alias}
    ${oam_interface}   Get VDU Container Interface Name   container=${container_abbr}  network=${network}   connection=${master_alias}

    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=${container_abbr}
    ${tmp_file}   Begin Wireshark  interface=${oam_interface}  host_type=VDUC  pod_abbr=${pod_abbr}  container=${container_abbr}
       ...   alias=${node_alias}  filter=${filter}
    ${handle}   set variable   ${node_alias}_${tmp_file}
    [Return]   ${handle}


_Begin Wireshark FHM On VDU Interactively
    [Arguments]     ${filter}=${EMPTY}
    [Documentation]    Begin Wireshark FHM On VDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...
    ...    *RETURN VALUE*
    ...    handle
    ...
    ...    Example
    ...   | ${handle} | Begin Wireshark FHM On VDU |  filter=tcp and port 8080 |
    ...   | sleep      |  350 |
    ...   | ${local_pcap} | Get A File  Wireshark |   step2.pcap  |
    ...   |  End Wireshark FHM On VDU | log_dst_path=${local_pcap}  |  handle=${handle} |
    ...
    ${alias}  get unique id  prefix=master

    ${container_abbr}   set variable   oamfh
    ${network}    set variable   fhm
    Connect To vDU Node Interactively   container_abbr=${container_abbr}    alias=${alias}

    #connection is not used
    ${oam_interface}   Get VDU Container Interface Name   container=${container_abbr}  network=${network}   connection=${alias}

    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=${container_abbr}
    ${tmp_file}   Begin Wireshark  interface=${oam_interface}  host_type=VDUCi  pod_abbr=${pod_abbr}  container=${container_abbr}
       ...   alias=${alias}  filter=${filter}
    ${handle}   set variable   ${alias}_${tmp_file}
    [Return]   ${handle}


End Wireshark FHM On VDU
    [Arguments]     ${log_dst_path}    ${handle}
    [Documentation]    End Wireshark FHM On VDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | ${handle} | Begin Wireshark FHM On VDU |  filter=tcp |
    ...   | sleep      |  350 |
    ...   | ${local_pcap} | Get A File  Wireshark |   step2.pcap  |
    ...   |  End Wireshark FHM On VDU | log_dst_path=${local_pcap}  |  handle=${handle} |
    ...
    ${node_alias}   set variable    ${handle.split('_')[0]}
    ${log_src_path}   set variable    ${handle.replace("${node_alias}_","")}
    End Wireshark     log_dst_path=${log_dst_path}   log_src_path=${log_src_path}   alias=${node_alias}


Begin K8s Log
    [Arguments]     ${gnb_index}=0  ${vdu_index}=0
    [Documentation]    Begin K8s Log
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    Handle of 'Begin K8s Log', it will be used in 'End K8s Log'
    ...
    ...    Example
    ...    Capture in one POD and one container
    ...    | ${handle} | Begin K8s Log |
    ...    | sleep  | 30 |
    ...    | ${log_file} | End K8s Log | handle=${handle}  |  pod_name=up | container_name=l2rt |
    ...
    ...    Capture in two POD and two containers
    ...    | ${handle} | Begin K8s Log |
    ...    | sleep  | 30 |
    ...    | ${log_file} | End K8s Log | handle=${handle}  |  pod_name=up | container_name=l2rt |
    ...    | ${log_file2} | End K8s Log | handle=${handle}  |  pod_name=oamcp | container_name=cprt |
    ...
    ${alias}=  get unique id
    Connect To K8s Master Interactively   alias=${alias}  vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ${date_info}=   issh.execute   command=date --rfc-3339=ns  check_result=${False}   alias=${alias}
    ${datetime}=    get regexp matches    ${date_info}      (\\d+-\\d+-\\d+ \\d+:\\d+:\\d+.\\d+\\+08:00)    1
    ${k8s_master_datetime}=    set variable   ${datetime[0]}
    ${k8s_master_datetime}=    replace string  ${k8s_master_datetime}  ${SPACE}  T
    [Return]  ${k8s_master_datetime}
    [Teardown]   disconnect interactive connection   alias=${alias}


End K8s Log
    [Arguments]   ${handle}  ${pod_abbr}  ${container}   ${gnb_index}=0  ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection   alias=${alias}
    [Documentation]    End K8s Log
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | since_time |  Yes | it's returned from 'Begin K8s Log' |
    ...    | pod_abbr   |  Yes | pod abbreviation name, eg, oamcp, uprt |
    ...    | container  | Yes | container name, e.g. oam, oamfh, nwmgmt, cprt, rcpsdl, l2rt, l2hi, l1hi |
    ...	   | gnb_index  | no | gnb_index, default is 0 |
    ...	   | vdu_index  | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Handle of 'Begin K8s Log', it will be used in 'End K8s Log'
    ...
    ...    Example
    ...    Capture in one POD and one container
    ...    | ${handle} | Begin K8s Log |
    ...    | sleep  | 30 |
    ...    | ${log_file} | End K8s Log | handle=${handle}  |  pod_name=up | container_name=l2rt |
    ...
    ...    Capture in two POD and two containers
    ...    | ${handle} | Begin K8s Log |
    ...    | sleep  | 30 |
    ...    | ${log_file} | End K8s Log | handle=${handle}  |  pod_name=up | container_name=l2rt |
    ...    | ${log_file2} | End K8s Log | handle=${handle}  |  pod_name=oamcp | container_name=cprt |
    ...
    ${alias}   get unique id
    Connect To K8s Master With Tenant Interactively    vdu_index=${vdu_index}   alias=${alias}   gnb_index=${gnb_index}
    ${full_pod_name}   Get Full Pod Name By Pod Abbreviation Interactively    pod_abbr=${pod_abbr}   alias=${alias}
        ...  gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${full_ctr_name}    Run Keyword If  '${container}'!='all'
        ...   Get Full Container Name By Container Abbreviation   ctr_abbr=${container}   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${remote_file}   get a remote file  ${pod_abbr}_${container}.log     alias=${alias}
    ${unique_id}     get unique id   precise=LOW
    ${local_ute_file}   get a file  ${pod_abbr}_${container}_${unique_id}.log
    ${function_cmd}=   Run Keyword If  '${container}'=='all'
    ...  set variable  kubectl logs ${full_pod_name} --all-containers=true --since-time=${handle}
    ...  ELSE  set variable  kubectl logs ${full_pod_name} -c ${full_ctr_name} --since-time=${handle}

    ${cmd}  set variable   nohup ${function_cmd} > ${remote_file} 2>&1 &

    ${out}  issh.Execute  command=${cmd}   alias=${alias}
    ${out}  issh.Execute  command=echo $!   alias=${alias}
    ${out}  strip prompt  ${out}
    ${pid}  parse number only from content  ${out}
    Wait Until Process Disappear   pid=${pid}   alias=${alias}
    ${out}  issh.Execute  command=ps -ef|grep kubectl   alias=${alias}

    ${out}  issh.Execute  command=sync  alias=${alias}
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_ute_file}   alias=${alias}
    [Return]  ${local_ute_file}


Begin BIP Log Capture
    [Arguments]  ${pod_abbr}=up   ${container}=l1hi  ${port_name}=l1bipl1  ${vdu_index}=0  ${alias}=default
    [Documentation]    Begin BIP Log Capture in vDU
    ...    *AUTHOR* rainie.wu@nokia-sbell.com
    ...    how to use:
    ...    | Connect to vDU Node | pod_abbr=up | vdu_index=0 | master_alias=alias1 | node_alias=alias2 |
    ...    | {tmpfile_pcap}=  | Begin BIP Log Capture | pod_abbr=up | container=l1hi | port_name=l1bipl1 | vdu_index=0| alias=alias2 |
    ...    | Sleep            | 3min |
    ...    | Stop BIP Capture And Download | initial_log_path={tempfile_path} | alias=alias2 |
    ...    | tafssh.disconnect | connection=alias2 |
    ...    | tafssh.disconnect | connection=alias1 |

    Log To Console  Begin BIP Log Capture
    ${container_id}  Get VDU Container ID   container_name=${container}   connection=${alias}   vdu_index=${vdu_index}
    Log To Console   ${vdu_index}/${pod_abbr}/${container}:${container_id}

    ${out}    tafssh.Execute     command=docker exec -it ${container_id} mkdir -p /tmp/dpdk    connection=${alias}
    ${out}    tafssh.Execute     command=docker exec -it ${container_id} ls /tmp/dpdk   connection=${alias}

    #${tmpfilename}=
    #...  _Get Temp File Name  host_type=${container}  fhgw_or_vdu_index=${vdu_index}  pod_abbr=${pod_abbr}  container_id=${container_id}
    #${tmpfilename}=  Get Substring  ${tmpfilename}  0  30
    #${tmpfilenamefullpath}    Set Variable    /tmp/dpdk/${tmpfilename}
    ${tmpfilenamefullpath}    Set Variable    /tmp/dpdk/${port_name}
    #${cpu_out}    tafssh.Execute     command=docker exec -it ${container_id} env | grep -i SHARED_CPUS   connection=${alias}
    #${cpu_out}=  strip string  ${cpu_out}  characters=\r\n
    #${SHARED_CPUS}=    evaluate  re.split('=','${cpu_out}')  re
    #${cpu}=  set variable  ${SHARED_CPUS[1]}
    #${DPDK_out}    tafssh.Execute     command=docker exec -it ${container_id} env | grep EM_DPDK_FILEPREFIX   connection=${alias}
    #${DPDK_out}=  strip string  ${DPDK_out}  characters=\r\n
    #${EM_DPDK_FILEPREFIX}=    evaluate  re.split('=','${DPDK_out}')  re
    #${file-prefix}=  set variable  ${EM_DPDK_FILEPREFIX[1]}
    #log to console  ${cpu} ${file-prefix}
    ${bip_port_id}    tafssh.Execute    docker exec -it ${container_id} dpdk-cli show port table | grep ${port_name} | awk '{print $1}'
    ...    connection=${alias}
    #${cmd}=  set variable  dpdk-pdump -l${cpu} -n4 --proc-type=secondary --file-prefix=${file-prefix} --
    #${cmd}=  set variable  ${cmd} --pdump port=${port},queue=*,rx-dev=${tmpfilenamefullpath}_rx.pcap,tx-dev=${tmpfilenamefullpath}_tx.pcap
    #${cmd}=  set variable if  '${mbuf}'=='True'  ${cmd},mbuf-size=${mbuf-size},total-num-mbufs=${total-num-mbufs}    ${cmd}
    ${sudo}    Get Sudo VDUC    container_id=${container_id}   alias=${alias}
    ${cmd}=  set variable    dpdk-cli pdump port ${bip_port_id}
    ${cmd}    Set Variable     ${sudo} ${cmd}
    log to console  ${cmd}

    #prepare dpdk_guard script
    ${tcpdump_guard}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   ${TOOLS_INFO["tcpdump_guard"]}
    ${version_file}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   version.repo

    ${target}   Create List   ${pod_abbr}
    ${out}  tafssh.Execute  command=ls ${tcpdump_guard}   connection=${alias}
    Run Keyword If     """No such file or directory""" in """${out}"""
    ...  tafssh.Execute  command=rm -f ${version_file}   connection=${alias}
    Run Keyword If     """No such file or directory""" in """${out}"""     Upload Tools To Vdu Nodes   target=${target}
    ${out}  tafssh.Execute  command=ls ${tcpdump_guard}   connection=${alias}
    Should Be True   """No such file or directory""" not in """${out}"""

    ${alias_process_guard}   Get Unique Id
    Connect To VDU Node Interactively   pod_abbr=${pod_abbr}     alias=${alias_process_guard}
    ${out}   issh.Execute     command=cd ${TOOLS_INFO["work_folder_tool"]}   alias=${alias_process_guard}

    #start capture
    tafssh.Send Command    command=docker exec -it ${container_id} bash -c "cd /tmp/dpdk && ${cmd}"   connection=${alias}   get_pty=${True}
    Sleep   6s

    #process guard
    ${out}   issh.Execute     command=(./${TOOLS_INFO["tcpdump_guard"]} -a ${port_name}.pcap &)   alias=${alias_process_guard}
    ${out}   issh.Execute      command=ps -ef|grep ${TOOLS_INFO["tcpdump_guard"]}   alias=${alias_process_guard}
    Log To Console  ${out}

    [Return]    ${tmpfilenamefullpath}


Stop BIP Capture And Download
    [Arguments]  ${alias}   ${initial_log_path}   ${container}=l1hi   ${vdu_index}=0
    [Documentation]   _Get BIP Log Capture From VDU
    ...    *AUTHOR* rainie.wu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  alias | Yes | alias  |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Stop BIP Capture And Download | /tmp/tmp_wireshark/ws_VDUC_0_oamcp_bd257c6e491.pcap | alias |
    ...
    Send CTRL_C    alias=${alias}
    Sleep  1

    #parse vdu_index, pod_appr, docker_id
    #${path}  ${pcap_file}  OperatingSystem.Split Path   ${initial_log_path}
    #${tmp}   Split String  ${pcap_file}  _
    #${container}  Set Variable  ${tmp[0]}
    #${vdu_index}  Set Variable  ${tmp[1]}
    #${pod_abbr}  Set Variable  ${tmp[2]}
    #${container_id}   Set Variable  ${tmp[3]}
    ${container_id}  Get VDU Container ID   container_name=${container}   connection=${alias}   vdu_index=${vdu_index}

    Log To Console   ${container_id}
    ${out}    tafssh.Execute     command=docker exec -it ${container_id} sync    connection=${alias}
    ${out}    tafssh.Execute     command=docker exec -it ${container_id} chmod 777 ${initial_log_path}.pcap    connection=${alias}
    ${out}    tafssh.Execute     command=mkdir -p /tmp/dpdk   connection=${alias}
    ${out}    tafssh.Execute     command=ls -l /tmp/dpdk   connection=${alias}
    ${docker_cp}   Set Variable   sudo docker cp ${container_id}:${initial_log_path}.pcap /tmp/dpdk/
    ${out}    tafssh.Execute     command=${docker_cp}    connection=${alias}
    ${out}    tafssh.Execute     command=sync    connection=${alias}

    ${local_file_path}=  Get A File    BIP  ${container}_${vdu_index}.pcap

    tafssh.Download File   remote_path=${initial_log_path}.pcap    local_path=${local_file_path}   connection=${alias}
    _Delete Old Wireshark File In VDUC   initial_log_path=${initial_log_path}.pcap   container_id=${container_id}
    ...    alias=${alias}    FolderName=/tmp/dpdk
    _Delete Old Wireshark File   initial_log_path=${initial_log_path}.pcap   alias=${alias}    FolderName=/tmp/dpdk
    ${sudo}   Get Sudo   alias=${alias}
    tafssh.Execute   command=${sudo} rm -f ${initial_log_path}.pcap     connection=${alias}
    [Return]  ${local_file_path}


_Get Temp File Name
    [Arguments]  ${host_type}=${EMPTY}   ${fhgw_or_vdu_index}=0   ${pod_abbr}=${EMPTY}  ${container_id}=${EMPTY}
    #way I:
    #${var_exist}=    Run Keyword And Ignore Error    Variable Should Exist    ${LOCAL_IP}
    #${ip}=    Run Keyword If    "${var_exist[0]}"=="FAIL"    Get Local IP
    #...    ELSE    Set Variable    ${LOCAL_IP}
    #${ts}    Get Time    epoch
    #${rand}   Evaluate   random.randint(1,99999)    modules=random
    #${filename}   Set Variable    ${LOCAL_IP}_${ts}_${rand}

    #way II:
    #${filename}    Evaluate    str(uuid.uuid4())    modules=uuid
    #${filename}    String.Replace String    ${filename}    -    ${EMPTY}

    #way III:
    ${unique_id}  Get Unique ID
    ${host_type}   Set Variable If   "${host_type}"=="${EMPTY}"   z   ${host_type}
    ${pod_abbr}   Set Variable If   "${pod_abbr}"=="${EMPTY}"   z   ${pod_abbr}
    ${container_id}   Set Variable If   "${container_id}"=="${EMPTY}"   z   ${container_id}
    ${file_name}   Set Variable   ${host_type}_${fhgw_or_vdu_index}_${pod_abbr}_${container_id}_${unique_id}
    [Return]  ${file_name}


Get Timestamp
    [Arguments]  ${format}=epoch
    ${ts}    Get Time     ${format}
    [Return]  ${ts}


_Begin Tcpdump Wireshark
    [Arguments]   ${interface}    ${filter}   ${alias}=default
    ${out}    tafssh.Execute     command=mkdir -p /tmp/tmp_wireshark    connection=${alias}
    ${out}    tafssh.Execute     command=ls /tmp/tmp_wireshark   connection=${alias}

    ${tmpfilename}    _Get Temp File Name
    ${tmpfilenamefullpath}    Set Variable    /tmp/tmp_wireshark/ws_${tmpfilename}.pcap

    ${sudo}   Get Sudo   alias=${alias}
    ${cmd}    Set Variable If    '${filter}'==''    ${sudo} tcpdump -ni ${interface} -s 0 -w ${tmpfilenamefullpath}
    ...    ${sudo} tcpdump -ni ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}

    tafssh.Send Command    command=${cmd}   connection=${alias}   get_pty=${True}
    Sleep   1s
    [Return]    ${tmpfilenamefullpath}


_Begin Tcpdump Wireshark In General Server
    [Arguments]   ${interface}    ${filter}   ${alias}=default
    ${out}    issh.Execute     command=mkdir -p /tmp/tmp_wireshark    alias=${alias}
    ${out}    issh.Execute     command=ls /tmp/tmp_wireshark   alias=${alias}

    ${tmpfilename}    _Get Temp File Name
    ${tmpfilenamefullpath}    Set Variable    /tmp/tmp_wireshark/ws_${tmpfilename}.pcap

    ${sudo}  Get Sudo Via Interactive SSH   alias=${alias}
    ${cmd}    Set Variable If    '${filter}'==''    ${sudo} tcpdump -ni ${interface} -s 0 -w ${tmpfilenamefullpath}
    ...    ${sudo} tcpdump -ni ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}

    issh.Execute_Bare   command=${cmd}   alias=${alias}
    Send ENTER Interactively   alias=${alias}
    [Return]    ${tmpfilenamefullpath}


_Begin Tcpdump Wireshark FHGW
    [Arguments]    ${interface}    ${filter}   ${alias}   ${index}=0
    ${host_type}   Set Variable  FHGW
    ${out}    issh.Execute     command=mkdir -p /tmp/tmp_wireshark    alias=${alias}
    ${out}    issh.Execute     command=ls /tmp/tmp_wireshark   alias=${alias}

    ${tmpfilename}    _Get Temp File Name   host_type=${host_type}   fhgw_or_vdu_index=${index}
    ${tmpfilenamefullpath}    Set Variable    /tmp/tmp_wireshark/ws_${tmpfilename}.pcap


    ${cmd}    Set Variable If    '${filter}'==''    tcpdump -ni ${interface} -s 0 -w ${tmpfilenamefullpath}
    ...    tcpdump -ni ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}
    issh.Execute_Bare   command=${cmd}   alias=${alias}
    Send ENTER Interactively   alias=${alias}
    [Return]    ${tmpfilenamefullpath}


_Begin Tcpdump Wireshark RUPROXY
    [Arguments]    ${interface}    ${filter}   ${alias}   ${index}=0    ${ru_index}=1
    ${host_type}   Set Variable  RUPROXY
    ${container_id}  Get Ruproxy Container ID   alias=${alias}   ru_index=${ru_index}
    Log To Console   RU container id(ru_index=${ru_index}):${container_id}

    ${out}    issh.Execute     command=docker exec -it ${container_id} mkdir -p /tmp/tmp_wireshark    alias=${alias}
    ${out}    issh.Execute     command=docker exec -it ${container_id} ls /tmp/tmp_wireshark   alias=${alias}

    #pod_abbr is ru_index for RUPROXY case
    ${tmpfilename}    _Get Temp File Name
    ...   host_type=${host_type}   fhgw_or_vdu_index=${index}   pod_abbr=${ru_index}  container_id=${container_id}
    ${tmpfilenamefullpath}    Set Variable    /tmp/tmp_wireshark/ws_${tmpfilename}.pcap

    #prepare tcpdump_guard script
    ${tcpdump_guard}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   ${TOOLS_INFO["tcpdump_guard"]}

    Upload Tools To FHGW   vdu_index=${index}

    ${out}  issh.Execute  command=ls ${tcpdump_guard}   alias=${alias}
    Should Be True     """No such file or directory""" not in """${out}"""

    ${alias_process_guard}   Get Unique Id
    Connect To FHGW   vdu_index=${index}    alias=${alias_process_guard}
    ${out}   issh.Execute     command=cd ${TOOLS_INFO["work_folder_tool"]}   alias=${alias_process_guard}

    #start capture
    ${cmd}    Set Variable If    '${filter}'==''   setcapability tcpdump -ni ${interface} -s 0 -w ${tmpfilenamefullpath}
    ...     setcapability tcpdump -ni ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}

    issh.Execute_Bare   command=docker exec -it ${container_id} ${cmd}    alias=${alias}
    Send ENTER Interactively

    #process guard
    ${out}   issh.Execute     command=(./${TOOLS_INFO["tcpdump_guard"]} -a ${tmpfilename} &)   alias=${alias_process_guard}
    ${out}   issh.Execute      command=ps -ef|grep ${TOOLS_INFO["tcpdump_guard"]}   alias=${alias_process_guard}
    Log To Console  ${out}

    [Return]    ${tmpfilenamefullpath}


_Begin Tcpdump Wireshark VDUC
    [Arguments]   ${interface}    ${filter}   ${pod_abbr}   ${container}   ${index}  ${alias}
    [Documentation]    Begin wireshark in vDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...    25.08.2020, gang.ni@nokia-sbell.com, add more delay time after start capture to improve robust

    ${host_type}  Set Variable  VDUC
    ${container_id}  Get VDU Container ID   container_name=${container}   connection=${alias}   vdu_index=${index}
    Log To Console   ${index}/${pod_abbr}/${container}:${container_id}

    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} mkdir -p /tmp/tmp_wireshark    connection=${alias}
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} ls /tmp/tmp_wireshark   connection=${alias}

    ${tmpfilename}    _Get Temp File Name
      ...    host_type=${host_type}   fhgw_or_vdu_index=${index}   pod_abbr=${pod_abbr}  container_id=${container_id}
    ${tmpfilenamefullpath}    Set Variable    /tmp/tmp_wireshark/ws_${tmpfilename}.pcap

    ${sudo}    Get Sudo VDUC    container_id=${container_id}   alias=${alias}
    ${cmd}    Set Variable If    '${filter}'==''    ${sudo} tcpdump -ni ${interface} -s 0 -w ${tmpfilenamefullpath}
    ...    ${sudo} tcpdump -ni ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}

    #prepare tcpdump_guard script
    ${tcpdump_guard}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   ${TOOLS_INFO["tcpdump_guard"]}
    ${version_file}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   version.repo

    ${target}   Create List   ${pod_abbr}
    ${out}  tafssh.Execute  command=ls ${tcpdump_guard}   connection=${alias}
    Run Keyword If     """No such file or directory""" in """${out}"""
    ...  tafssh.Execute  command=rm -f ${version_file}   connection=${alias}
    Run Keyword If     """No such file or directory""" in """${out}"""     Upload Tools To Vdu Nodes   target=${target}
    ${out}  tafssh.Execute  command=ls ${tcpdump_guard}   connection=${alias}
    Should Be True   """No such file or directory""" not in """${out}"""

    ${alias_process_guard}   Get Unique Id
    Connect To VDU Node Interactively   pod_abbr=${pod_abbr}     alias=${alias_process_guard}
    ${out}   issh.Execute     command=cd ${TOOLS_INFO["work_folder_tool"]}   alias=${alias_process_guard}

    #start capture
    tafssh.Send Command    command=sudo docker exec -it ${container_id} ${cmd}   connection=${alias}   get_pty=${True}
    Sleep   6s

    #process guard
    ${out}   issh.Execute     command=(./${TOOLS_INFO["tcpdump_guard"]} -a ${tmpfilename} &)   alias=${alias_process_guard}
    ${out}   issh.Execute      command=ps -ef|grep ${TOOLS_INFO["tcpdump_guard"]}   alias=${alias_process_guard}
    Log To Console  ${out}

    [Return]    ${tmpfilenamefullpath}


_Begin Tcpdump Wireshark VDUCi
    [Arguments]   ${interface}    ${filter}   ${pod_abbr}   ${container}   ${index}  ${alias}
    [Documentation]    Begin wireshark in vDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...    25.08.2020, gang.ni@nokia-sbell.com, add more delay time after start capture to improve robust

    ${host_type}  Set Variable  VDUCi
    ${container_id}  Get vDU Container ID Interactively  container_name=${container}   alias=${alias}   vdu_index=${index}
    Log To Console   ${index}/${pod_abbr}/${container}:${container_id}

    ${out}    issh.Execute     command=sudo docker exec -it ${container_id} mkdir -p /tmp/tmp_wireshark    alias=${alias}
    ${out}    issh.Execute     command=sudo docker exec -it ${container_id} ls -l /tmp/tmp_wireshark   alias=${alias}

    ${tmpfilename}    _Get Temp File Name
      ...    host_type=${host_type}   fhgw_or_vdu_index=${index}   pod_abbr=${pod_abbr}  container_id=${container_id}
    ${tmpfilenamefullpath}    Set Variable    /tmp/tmp_wireshark/ws_${tmpfilename}.pcap

    ${sudo}    Get Sudo VDUCi    container_id=${container_id}   alias=${alias}
    log to console   ${sudo}


    ${cmd}    Set Variable If    '${filter}'==''    ${sudo} tcpdump -ni ${interface} -s 0 -w ${tmpfilenamefullpath}
    ...    ${sudo} tcpdump -ni ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}

    #prepare tcpdump_guard script
    ${tcpdump_guard}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   ${TOOLS_INFO["tcpdump_guard"]}
    ${version_file}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   version.repo

    ${target}   Create List   ${pod_abbr}
    ${out}  issh.Execute  command=ls ${tcpdump_guard}   alias=${alias}
    Run Keyword If     """No such file or directory""" in """${out}"""
    ...  issh.Execute  command=rm -f ${version_file}   alias=${alias}
    Run Keyword If     """No such file or directory""" in """${out}"""     Upload Tools To Vdu Nodes   target=${target}
    ${out}  issh.Execute  command=ls ${tcpdump_guard}   alias=${alias}
    Should Be True   """No such file or directory""" not in """${out}"""

    ${alias_process_guard}   Get Unique Id
    Connect To VDU Node Interactively   pod_abbr=${pod_abbr}     alias=${alias_process_guard}
    ${out}   issh.Execute     command=cd ${TOOLS_INFO["work_folder_tool"]}   alias=${alias_process_guard}

    #start capture
    issh.Execute   command=sudo docker exec -it ${container_id} ${cmd}   alias=${alias}
    Sleep   6s

    #process guard
    ${out}   issh.Execute     command=(./${TOOLS_INFO["tcpdump_guard"]} -a ${tmpfilename} &)   alias=${alias_process_guard}
    ${out}   issh.Execute      command=ps -ef|grep ${TOOLS_INFO["tcpdump_guard"]}   alias=${alias_process_guard}
    Log To Console  ${out}

    [Return]    ${tmpfilenamefullpath}


_Begin Tcpdump Wireshark VCU
    [Arguments]    ${interface}    ${filter}   ${alias}   ${index}=0
    ${host_type}   _Wireshark Get Host Type Interactively   alias=${alias}   gnb_index=${index}
    Log To Console  Begin Wireshark, hostname:${host_type}

    ${tmpfilefullpath}   Run Keyword If  "VCUOAMMASTER"=="${host_type}"
         ...   _Begin Tcpdump Wireshark VCU OAM  interface=${interface}  filter=${filter}  alias=${alias}   index=${index}
    ...    ELSE IF   "VCUOTHER"=="${host_type}"
         ...   _Begin Tcpdump Wireshark VCU Other  interface=${interface}  filter=${filter}  alias=${alias}    index=${index}

    [Return]    ${tmpfilefullpath}


_Begin Tcpdump Wireshark VCU OAM
    [Arguments]    ${interface}    ${filter}   ${alias}   ${index}=0
    ${host_type}   Set Variable  VCUOAMMASTER
    ${out}    issh.Execute     command=mkdir -p /tmp/tmp_wireshark    alias=${alias}
    ${out}    issh.Execute     command=ls /tmp/tmp_wireshark   alias=${alias}

    ${tmpfilename}    _Get Temp File Name   host_type=${host_type}   fhgw_or_vdu_index=${index}
    ${tmpfilenamefullpath}    Set Variable    /tmp/tmp_wireshark/ws_${tmpfilename}.pcap

    ${cmd}    Set Variable If    '${filter}'==''    tcpdump -ni ${interface} -s 0 -w ${tmpfilenamefullpath}
    ...    tcpdump -ni ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}
    issh.Execute_Bare   command=${cmd}   alias=${alias}
    Send ENTER Interactively   alias=${alias}
    [Return]    ${tmpfilenamefullpath}


_Begin Tcpdump Wireshark VCU Other
    [Arguments]    ${interface}    ${filter}   ${alias}   ${index}=0
    ${host_type}   Set Variable  VCUOTHER
    ${out}    issh.Execute     command=mkdir -p /tmp/tmp_wireshark    alias=${alias}
    ${out}    issh.Execute     command=ls /tmp/tmp_wireshark   alias=${alias}

    ${tmpfilename}    _Get Temp File Name   host_type=${host_type}   fhgw_or_vdu_index=${index}
    ${tmpfilenamefullpath}    Set Variable    /tmp/tmp_wireshark/ws_${tmpfilename}.pcap

    ${cmd}    Set Variable If    '${filter}'==''    tcpdump -ni ${interface} -s 0 -w ${tmpfilenamefullpath}
    ...    tcpdump -ni ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}
    issh.Execute_Bare   command=${cmd}   alias=${alias}
    Send ENTER Interactively   alias=${alias}
    [Return]    ${tmpfilenamefullpath}


_Begin Tcpdump Wireshark VCUC
    [Arguments]    ${interface}    ${filter}   ${alias}  ${pod_abbr}   ${container}  ${index}=0
    ${host_type}  Set Variable  VCUC
    Log To Console   VCU CNF index:${index}/${pod_abbr}/${container}
    ${pcap_folder}   set variable    /tmp/tmp_wireshark
    ${sudo_outer}  Get Sudo For VCU K8s Admin Command  gnb_index=${index}

    ${ns}    Get CU Namespace From Testline   gnb_index=${index}
    ${full_pod_name}   Get CU Full Pod Name By Pod Abbreviation  pod_abbr=${pod_abbr}   gnb_index=${index}  alias=${alias}
    ${full_container_name}   Get CU Full Container Name By Container Abbreviation  ctr_abbr=${container}

    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- mkdir -p ${pcap_folder}
            ...  alias=${alias}
    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- ls -l ${pcap_folder}
            ...  alias=${alias}

    ${tmpfilename}    _Get Temp File Name
      ...    host_type=${host_type}   fhgw_or_vdu_index=${index}   pod_abbr=${pod_abbr}  container_id=${container}
    ${tmpfilenamefullpath}    Set Variable    ${pcap_folder}/ws_${tmpfilename}.pcap

    #${sudo}    Get Sudo VCUC   pod_abbr=${pod_abbr}  container=${container}   gnb_index=${index}  alias=${alias}
    ${sudo}  set variable   ${EMPTY}

    ${cmd}    Set Variable If    '${filter}'==''    tcpdump -ni ${interface} -s 0 -w ${tmpfilenamefullpath}
    ...    tcpdump -ni ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}
    ${cmd}   set variable if  "${sudo}"!="${EMPTY}"   sudo ${cmd}    ${cmd}

    #prepare tcpdump_guard script
    ${tcpdump_guard}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   ${TOOLS_INFO["tcpdump_guard_cnf"]}
    ${version_file}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   version.repo

   # ${out}  issh.Execute   command=ls ${tcpdump_guard}   check_result=False   alias=${alias}
   # ${out2}   Run Keyword If     """No such file or directory""" in """${out}"""
    #...  issh.Execute  command=rm -f ${version_file}  check_result=False   alias=${alias}
    #Run Keyword If     """No such file or directory""" in """${out}"""     Upload Tools To VCU Master Nodes
    Upload Tools To VCU Master Nodes
    ${out}  issh.Execute   command=ls ${tcpdump_guard}   alias=${alias}
    Should Be True   """No such file or directory""" not in """${out}"""

    #start capture
    ${full_cmd}   set variable  ${sudo_outer} kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- ${cmd}
    log to console   ${full_cmd}
    issh.Execute_Bare   command=${full_cmd}   alias=${alias}
    ${out}   Send ENTER Interactively VCU CNF  alias=${alias}
    Sleep   6s

    #process guard
    ${alias_process_guard}   Connect To CU K8S Master With Admin   gnb_index=${index}
    ${out}   issh.Execute    command=cd ${TOOLS_INFO["work_folder_tool"]}   alias=${alias_process_guard}
    ${out}   issh.Execute    command=${sudo_outer} kubectl get pod ${full_pod_name} -o wide -n ${ns}|grep -v NAME|awk '{print $7}'
      ...  alias=${alias_process_guard}
    ${target_node}  strip prompt   ${out}
    should be true  ${target_node.__len__()>0}

    ${out}   issh.Execute     command=ps -ef|grep tcpdump   alias=${alias_process_guard}
    Log To Console  ${out}

    ${out}   issh.Execute     command=(./${TOOLS_INFO["tcpdump_guard_cnf"]} -a ${tmpfilename} -t ${target_node} &)   alias=${alias_process_guard}
    Log To Console  ${out}

    ${out}   issh.Execute     command=ps -ef|grep ${TOOLS_INFO["tcpdump_guard_cnf"]}   alias=${alias_process_guard}
    Log To Console  ${out}

    [Return]    ${tmpfilenamefullpath}



_Get Wireshark From Server
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}=default
    [Documentation]    Get log to local from wireshark server
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  log_stored_path | Yes | Where to save log on local PC  |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  _Get Wireshark From Server   |   /tmp/tmp_wireshark/ws_10.70.38.195_1514196349_69532.pcap   |  /home/ute/oam.pcap |
    tafssh.Execute  command=sync   connection=${alias}
    tafssh.Download File   remote_path=${initial_log_path}    local_path=${log_stored_path}   connection=${alias}
    _Delete Old Wireshark File   initial_log_path=${initial_log_path}   alias=${alias}


_Get Wireshark From General Linux Server
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}=default
    [Documentation]    Get log to local from wireshark server
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  log_stored_path | Yes | Where to save log on local PC  |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  _Get Wireshark From Server   |   /tmp/tmp_wireshark/ws_10.70.38.195_1514196349_69532.pcap   |  /home/ute/oam.pcap |
    issh.Execute  command=sync    check_result=${False}   alias=${alias}
    Sleep    1

    ${sudo}  Get Sudo Via Interactive SSH   alias=${alias}
    issh.Execute  command=${sudo} chmod 777 ${initial_log_path}   check_result=${False}   alias=${alias}

    issh.Download File   remote_path=${initial_log_path}    local_path=${log_stored_path}   alias=${alias}
    ${out}  issh.Execute  command=${sudo} rm -f ${initial_log_path}     alias=${alias}
    _Remove All Temp File If Needed From General Linux Server   FolderName=/tmp/tmp_wireshark/    alias=${alias}


_Get Wireshark From FHGW
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}
    [Documentation]    _Get Wireshark From FHGW
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  log_stored_path | Yes | Where to save log on local PC  |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  _Get Wireshark From FHGW   |   /tmp/tmp_wireshark/ws_10.70.38.195_1514196349_69532.pcap   |  /home/ute/oam.pcap  |
    Send CTRL_C Interactively    alias=${alias}
    ${out}   issh.Execute  command=sync     alias=${alias}
    ${ip}   _Get FHGW Ip   alias=${alias}

    ${tmp_alias}  Get Unique Id
    tafssh.Connect_To   hostname=${ip}   username=root    password=root   alias=${tmp_alias}
    tafssh.Download File   remote_path=${initial_log_path}    local_path=${log_stored_path}   connection=${tmp_alias}

    _Delete Old Wireshark File In FHGW   initial_log_path=${initial_log_path}    alias=${alias}


_Get Wireshark From RUPROXY
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}
    [Documentation]   _Get Wireshark From RUPROXY
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  log_stored_path | Yes | Where to save log on local PC  |
    ...    ws_RUPROXY_1_z_9e3bf32d8fc3_edd182ca76574df59232717fad979dfe.pcap  format:
    ...    ws_RUPROXY_<vdu_index>_<pod_abbr>_<docker_id>_<uuid>.pcap
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | _Get Wireshark From RUPROXY | ws_RUPROXY_1_z_9e3bf32d8fc3_edd182ca76574df59232717fad979dfe.pcap | /home/ute/oam.pcap |
    Send CTRL_C Interactively    alias=${alias}

    #parse vdu_index, ru_index, docker_id
    #pod_abbr is ru_index for RUPROXY case
    ${path}  ${pcap_file}  OperatingSystem.Split Path   ${initial_log_path}
    ${tmp}   Split String  ${pcap_file}  _
    ${vdu_index}  Set Variable  ${tmp[2]}
    ${ru_index}  Set Variable  ${tmp[3]}
    ${container_id}   Set Variable  ${tmp[4]}

    ${fhgw_ip}   _Get FHGW Ip   alias=${alias}
    String Should Be An Ip Address  ${fhgw_ip}

    ${fhgw_account_info}  Get FHGW Account Info
    ${fhgw_root_username}   Set Variable    ${fhgw_account_info["root_username"]}
    ${fhgw_root_password}   Set Variable    ${fhgw_account_info["root_password_plain"]}

    Should Not Be Empty  ${fhgw_root_username}
    Should Not Be Empty  ${fhgw_root_password}

    Log To Console   ${container_id}
    ${out}    issh.Execute     command=docker exec -it ${container_id} sync    alias=${alias}
    ${out}    issh.Execute     command=docker exec -it ${container_id} chmod 777 ${initial_log_path}    alias=${alias}
    ${out}    issh.Execute     command=mkdir -p /tmp/tmp_wireshark    alias=${alias}
    ${out}    issh.Execute     command=ls -l /tmp/tmp_wireshark   alias=${alias}
    ${docker_cp}   Set Variable   sudo docker cp ${container_id}:${initial_log_path} /tmp/tmp_wireshark
    ${out}    issh.Execute     command=${docker_cp}    alias=${alias}
    ${out}    issh.Execute     command=sync    alias=${alias}

    ${tmp_alias}  Get Unique Id
    tafssh.Connect_To   hostname=${fhgw_ip}   username=${fhgw_root_username}    password=${fhgw_root_password}   alias=${tmp_alias}
    tafssh.Download File   remote_path=${initial_log_path}    local_path=${log_stored_path}   connection=${tmp_alias}

    _Delete Old Wireshark File In RUPROXY   initial_log_path=${initial_log_path}   container_id=${container_id}   alias=${alias}
    _Delete Old Wireshark File In FHGW   initial_log_path=${initial_log_path}    alias=${alias}


_Get Wireshark From VDUC
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}
    [Documentation]   _Get Wireshark From VDUC
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  log_stored_path | Yes | Where to save log on local PC  |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | _Get Wireshark From FHGW | /tmp/tmp_wireshark/ws_VDUC_0_oamcp_bd257c6e4911_ec22b41be53342c7a9a3f20d0d8a1e8d.pcap | /home/ute/oam.pcap |
    ...
    Send CTRL_C    alias=${alias}
    Sleep  1

    #parse vdu_index, pod_appr, docker_id
    ${path}  ${pcap_file}  OperatingSystem.Split Path   ${initial_log_path}
    ${tmp}   Split String  ${pcap_file}  _
    ${vdu_index}  Set Variable  ${tmp[2]}
    ${pod_abbr}  Set Variable  ${tmp[3]}
    ${container_id}   Set Variable  ${tmp[4]}

    Log To Console   ${container_id}
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} sync    connection=${alias}
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} chmod 777 ${initial_log_path}    connection=${alias}
    ${out}    tafssh.Execute     command=mkdir -p /tmp/tmp_wireshark    connection=${alias}
    ${out}    tafssh.Execute     command=ls -l /tmp/tmp_wireshark   connection=${alias}
    ${docker_cp}   Set Variable   sudo docker cp ${container_id}:${initial_log_path} /tmp/tmp_wireshark
    ${out}    tafssh.Execute     command=${docker_cp}    connection=${alias}
    ${out}    tafssh.Execute     command=sync    connection=${alias}

    tafssh.Download File   remote_path=${initial_log_path}    local_path=${log_stored_path}   connection=${alias}
    _Delete Old Wireshark File In VDUC   initial_log_path=${initial_log_path}   container_id=${container_id}   alias=${alias}
    _Delete Old Wireshark File In VDU Master Node   initial_log_path=${initial_log_path}   alias=${alias}
    #${sudo}   Get Sudo   alias=${alias}
    #tafssh.Execute   command=${sudo} rm -f ${initial_log_path}     connection=${alias}


_Get Wireshark From VCUC
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}
    [Documentation]   _Get Wireshark From VCUC
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  log_stored_path | Yes | Where to save log on local PC  |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | _Get Wireshark From VCUC | /tmp/tmp_wireshark/ws_VDUC_0_oamcp_bd257c6e4911_ec22b41be53342c7a9a3f20d0d8a1e8d.pcap | /home/ute/oam.pcap |
    ...
    ${out}   Send CTRL_C Interactively    alias=${alias}
    sleep  2
    ${out}   issh.Execute  command=sync     alias=${alias}

    ${pcap_folder}   set variable    /tmp/tmp_wireshark
    ${sudo_outer}  Get Sudo For VCU K8s Admin Command

    #parse vcu_index, pod_abbr, container_abbr
    ${path}  ${pcap_file}  OperatingSystem.Split Path   ${initial_log_path}
    ${tmp}   Split String  ${pcap_file}  _
    ${vcu_index}  Set Variable  ${tmp[2]}
    ${pod_abbr}  Set Variable  ${tmp[3]}
    ${container}   Set Variable  ${tmp[4]}

    ${ns}     Get CU Namespace From Testline  gnb_index=${vcu_index}
    ${pod_full_name}   Get CU Full Pod Name By Pod Abbreviation  pod_abbr=${pod_abbr}   gnb_index=${vcu_index}  alias=${alias}
    ${container_full_name}   Get CU Full Container Name By Container Abbreviation  ctr_abbr=${container}

    Log To Console   ${container}
    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- sync
            ...  check_result=False   alias=${alias}

    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- chmod 777 ${initial_log_path}
            ...  check_result=False   alias=${alias}
    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- ls -l ${pcap_folder}
            ...  check_result=False   alias=${alias}

    ${out}    issh.Execute     command=mkdir -p ${pcap_folder}    alias=${alias}
    ${out}    issh.Execute     command=ls -l ${pcap_folder}   alias=${alias}

    #${remote_log_path}   set variable   /tmp/tmp_wireshark/${initial_log_path}
    ${remote_log_path}   set variable   ${initial_log_path}
    ${cp_cmd}   set variable
      ...  ${sudo_outer} kubectl cp ${pod_full_name}:${initial_log_path} ${remote_log_path} -c ${container_full_name} -n ${ns}
    ${out}    issh.Execute     command=${cp_cmd}    alias=${alias}

    ${out}    issh.Execute     command=sync    alias=${alias}

    issh.Download File   remote_path=${remote_log_path}    local_path=${log_stored_path}   alias=${alias}
    ${out}  issh.Execute  command=rm -f ${remote_log_path}     alias=${alias}

    _Delete Old Wireshark File In VCUC   initial_log_path=${initial_log_path}
     ...   pod_full_name=${pod_full_name}  container_full_name=${container_full_name}  ns=${ns}   alias=${alias}
    _Delete Old Wireshark File In VCUC Master Node   initial_log_path=${initial_log_path}   alias=${alias}


_Get Wireshark From VCU
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}=default
    [Documentation]   _Get Wireshark From VCU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  log_stored_path | Yes | Where to save log on local PC  |
    ...    |  alias           | no | default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  _Get Wireshark From VCU  |   /tmp/tmp_wireshark/ws_10.70.38.195_1514196349_69532.pcap   |  /home/ute/oam.pcap  |
    ...
    Send CTRL_C Interactively    alias=${alias}
    ${out}   issh.Execute  command=sync     alias=${alias}

    ${path}  ${pcap_file}  OperatingSystem.Split Path   ${initial_log_path}
    ${tmp}   Split String  ${pcap_file}  _
    ${hosttype}  Set Variable  ${tmp[1]}
    ${gnb_index}  Set Variable  ${tmp[2]}

    Run Keyword If  "${host_type}"=="VCUOAMMASTER"
         ...   _Get Wireshark From VCU OAM Master  initial_log_path=${initial_log_path}  log_stored_path=${log_stored_path}
         ...   alias=${alias}  gnb_index=${gnb_index}  capture_on_master_oam=${True}
       ...   ELSE   _Get Wireshark From VCU Other  initial_log_path=${initial_log_path}  log_stored_path=${log_stored_path}
         ...   alias=${alias}  gnb_index=${gnb_index}


_Get Wireshark From VCU OAM Master
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}=default  ${gnb_index}=0   ${capture_on_master_oam}=${True}
    [Teardown]  run keyword and ignore error  Disconnect Interactive Connection  alias=${tmp_alias}
    [Documentation]   _Get Wireshark From VCU OAM Master
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  log_stored_path | Yes | Where to save log on local PC  |
    ...    |  alias           | no | default value is default |
    ...    |  gnb_index       | no |  default is 0 |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  _Get Wireshark From VCU OAM Master | /tmp/tmp_wireshark/ws_10.70.38.195_1514196349_69532.pcap | /home/ute/oam.pcap |
    ...
    ${path}  ${pcap_file}  OperatingSystem.Split Path   ${initial_log_path}
    ${serviceuser_home_folder}  Set Variable  /home/serviceuser
    ${pcap_file_under_serviceuser_home_folder}   OperatingSystem.Join Path  ${serviceuser_home_folder}   ${pcap_file}
    Run Keyword If   "${capture_on_master_oam}"=="${True}"  issh.Execute   command=mkdir -p ${serviceuser_home_folder}    alias=${alias}
    Run Keyword If   "${capture_on_master_oam}"=="${True}"  issh.Execute
                     ...   command=chown serviceuser:serviceuser ${serviceuser_home_folder}  alias=${alias}
    Run Keyword If   "${capture_on_master_oam}"=="${True}"
                     ...   issh.Execute   command=chmod 777 ${serviceuser_home_folder}  alias=${alias}
    Run Keyword If   "${capture_on_master_oam}"=="${True}"  issh.Execute
                     ...  command=cp ${initial_log_path} ${pcap_file_under_serviceuser_home_folder}  alias=${alias}

    issh.Execute   command=chown serviceuser:serviceuser ${pcap_file_under_serviceuser_home_folder}  alias=${alias}
    issh.Execute  command=chmod 777 ${pcap_file_under_serviceuser_home_folder}   alias=${alias}

    ${tmp_alias}  Get Unique Id
    # connect to ute   hostname=127.0.0.1    alias=${tmp_alias}
    Connect To UTE Locally    alias=${tmp_alias}
    Download File From VCU OAM Via SCP     remote_file=${pcap_file_under_serviceuser_home_folder}  local_file=${log_stored_path}
      ...   gnb_index=${gnb_index}   alias=${tmp_alias}
    #issh.Download File  remote_path=${pcap_file_under_serviceuser_home_folder}  local_path=${log_stored_path}

    Run Keyword If   "${capture_on_master_oam}"=="${True}"  issh.Execute  command=rm -f ${initial_log_path}     alias=${alias}
    issh.Execute  command=rm -f ${pcap_file_under_serviceuser_home_folder}     alias=${alias}

    Run Keyword If   "${capture_on_master_oam}"=="${True}"   _Remove All Temp File If Needed From General Linux Server
        ...   FolderName=/tmp/tmp_wireshark/   alias=${alias}
    _Remove All Temp File If Needed From General Linux Server   FolderName=${serviceuser_home_folder}   alias=${alias}


Download File From VCU OAM Via SCP
    [Arguments]  ${remote_file}   ${local_file}   ${alias}=default  ${gnb_index}=0
    [Documentation]   Download File From VCU OAM Via SCP
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  remote_file  |  Yes |  Where is log stored on wireshark server |
    ...    |  local_file | Yes | Where to save log on local PC  |
    ...    |  alias           | no | default value is default |
    ...    |  gnb_index       | no |  default is 0 |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | ${alias} | Get Unique ID |
    ...    |  Connect To UTE Locally  |  alias=${alias} |
    ...    |  _Get Wireshark From VCU OAM Master | /tmp/tmp_wireshark/ws_10.70.38.195_1514196349_69532.pcap | /home/ute/oam.pcap | alias=${alias} |
    ...
    ${gnbs}    tl_info.Get_Cloudbts_Gnbs    ${tl}
    ${addr}   Set Variable  ${gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${username}   Set Variable  ${gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ${password}   Set Variable  ${gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}

    ${bIpV6Address}    Set Variable If    ":" in """${addr}"""    1      0

    ${option}   Set Variable  -o BatchMode=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
    ${old_prompt}   issh.Set Prompt   prompt_str=assword:    alias=${alias}

   ${cmd}   Set Variable If   ${bIpV6Address}==0    sudo scp -r ${option} ${username}@${addr}:${remote_file} ${local_file}
   ...    sudo scp -6 -r ${option} ${username}@[${addr}]:${remote_file} ${local_file}

    ${out}  issh.Execute   command=${cmd}    check_result=${False}   alias=${alias}
    issh.Set Prompt   prompt_str=${old_prompt}    alias=${alias}
    ${out}  issh.Execute   command=${password}  check_result=${False}  alias=${alias}


_Get Wireshark From VCU Other
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}=default  ${gnb_index}=0
    [Documentation]   _Get Wireshark From VCU OAM Master
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  log_stored_path | Yes | Where to save log on local PC  |
    ...    |  alias           | no | default value is default |
    ...    |  gnb_index       | no |  default is 0 |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  _Get Wireshark From VCU OAM Master | /tmp/tmp_wireshark/ws_10.70.38.195_1514196349_69532.pcap | /home/ute/oam.pcap |
    ...

    ${tmp_alias}  Get Unique Id
    CU SSH To OAM   gnb_index=${gnb_index}   alias=${tmp_alias}
    ${path}  ${pcap_file}  OperatingSystem.Split Path   ${initial_log_path}
    ${serviceuser_home_folder}  Set Variable  /home/serviceuser
    ${pcap_file_under_serviceuser_home_folder}   OperatingSystem.Join Path  ${serviceuser_home_folder}   ${pcap_file}
    issh.Execute   command=mkdir -p ${serviceuser_home_folder}    alias=${tmp_alias}
    issh.Execute   command=chown serviceuser:serviceuser ${serviceuser_home_folder}  alias=${tmp_alias}
    issh.Execute   command=chmod 777 ${serviceuser_home_folder}   alias=${tmp_alias}

    ${master_oam_index}   CU Get Master VM Index   gnb_index=${gnb_index}   vm_type=OAM
    issh.Execute   command=scp ${initial_log_path} oam-${master_oam_index}.local:${pcap_file_under_serviceuser_home_folder}   alias=${alias}

    _Get Wireshark From VCU OAM Master    initial_log_path=${initial_log_path}  log_stored_path=${log_stored_path}
         ...   alias=${tmp_alias}  gnb_index=${gnb_index}  capture_on_master_oam=${False}


    issh.Execute  command=rm -f ${initial_log_path}     alias=${alias}
    _Remove All Temp File If Needed From General Linux Server   FolderName=/tmp/tmp_wireshark/    alias=${alias}
    Disconnect Interactive Connection  alias=${tmp_alias}


_Get FHGW Ip
    [Arguments]  ${alias}
    ${out}    issh.Execute    command=ip add show dev eth0    alias=${alias}
    ${matches}  Get Regexp Matches     ${out}     inet (.+)/\\d{1,2} scope global.+   1
    ${ip}     Set Variable If    ${matches}    ${matches[0]}    ${EMPTY}
    [Return]   ${ip}


Get Current Host Time By Linux Cmd
    [Arguments]  ${alias}=default
    [Documentation]    Get Current Host Time By Linux Cmd
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    No input parameter.
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Current Host Time By Linux Cmd |
    ${out}    tafssh.Execute    command=date +%s    connection=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{5,20}
    [Return]   ${lines}


Get Current Host Time By Linux Cmd Interactively
    [Arguments]  ${alias}=default
    [Documentation]    Get Current Host Time By Linux Cmd
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | no | alias, default value is default |
    ...    No input parameter.
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Current Host Time By Linux Cmd Interactively |
    ${out}    issh.Execute    command=date +%s    alias=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{5,20}
    [Return]   ${lines}


Get Current Host Time By Linux Cmd VDUC
    [Arguments]  ${container_id}  ${alias}=default
    [Documentation]    Get Current Host Time By Linux Cmd
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    No input parameter.
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Current Host Time By Linux Cmd |
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} date +%s    connection=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{5,20}
    [Return]   ${lines}


Get Current Host Time By Linux Cmd VCUC
    [Arguments]  ${pod_full_name}  ${container_full_name}  ${alias}=default
    [Documentation]    Get Current Host Time By Linux Cmd
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    No input parameter.
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Current Host Time By Linux Cmd |
    ${ns}  get cu namespace from testline
    ${out}  issh.Execute  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- date +%s
            ...  check_result=False   alias=${alias}

    ${lines}  Get Lines Matching Regexp   ${out}   \\d{5,20}
    [Return]   ${lines}


Get Current Host Time By Linux Cmd FHGW Container
    [Arguments]  ${container_id}  ${alias}=default
    [Documentation]    Get Current Host Time By Linux Cmd FHGW Container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | container_id | yes | container_id |
    ...    | alias        | no | alias |
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Current Host Time By Linux Cmd FHGW Container |
    ${out}    issh.Execute     command=docker exec -it ${container_id} date +%s    alias=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{5,20}
    [Return]   ${lines}


Get Modified Time By Linux Cmd
    [Arguments]    ${filename}   ${alias}=default
    [Documentation]    Get Modified Time By Linux Cmd inside general linux server with taf.transport.ssh library
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    | alias    | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Modified Time By Linux Cmd | /root/a.txt |
    ${out}    tafssh.Execute   command=stat --format=%Y ${filename}   connection=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{8,20}
    [Return]   ${lines}


Get Modified Time By Linux Cmd Interactively
    [Arguments]    ${filename}   ${alias}=default
    [Documentation]     Get Modified Time By Linux Cmd Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    | alias    | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Modified Time By Linux Cmd Interactively | filename=/root/a.txt |
    ${out}    issh.Execute  command=stat --format=%Y ${filename}   alias=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{8,20}
    [Return]   ${lines}


Get Modified Time By Linux Cmd VDUC
    [Arguments]    ${filename}   ${container_id}  ${alias}=default
    [Documentation]     Get Modified Time By Linux Cmd inside VDU Container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    | container_id  | yes | container_id |
    ...    | alias    | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Modified Time By Linux Cmd VDUC | filename=/root/a.txt | container_id=${conainer_id} |
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} stat --format=%Y ${filename}    connection=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{8,20}
    [Return]   ${lines}


Get Modified Time By Linux Cmd VCUC
    [Arguments]    ${filename}   ${pod_full_name}   ${container_full_name}  ${alias}=default
    [Documentation]     Get Modified Time By Linux Cmd inside VCU Container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    | container_id  | yes | container_id |
    ...    | alias    | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Modified Time By Linux Cmd VCUC | filename=/root/a.txt | container_id=${conainer_id} |
    ${ns}  get cu namespace from testline
    ${sudo_outer}  Get Sudo For VCU K8s Admin Command
    ${out}  issh.Execute
            ...  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- stat --format=%Y ${filename}
            ...  check_result=False   alias=${alias}

    ${lines}  Get Lines Matching Regexp   ${out}   \\d{8,20}
    [Return]   ${lines}


Get Modified Time By Linux Cmd FHGW Container
    [Arguments]    ${filename}   ${container_id}  ${alias}=default
    [Documentation]    Get Modified Time By Linux Cmd inside FHGW Container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    | container_id  | yes | container_id |
    ...    | alias    | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Modified Time By Linux Cmd FHGW Container | filename=/root/a.txt | container_id=${conainer_id} |
    ${out}    issh.Execute     command=docker exec -it ${container_id} stat --format=%Y ${filename}    alias=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{8,20}
    [Return]   ${lines}


Check File Existed
    [Arguments]  ${filename}    ${alias}=default
    [Documentation]    Check File Existed or not in general linux server with taf.transport.ssh library
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    | alias    | no | alias name |
    ...
    ...    *RETURN VALUE*
    ...    return 1 if file exists, otherwise return 0
    ...
    ...    Example
    ...    | ${bExit} | Check File Existed |  /root/a.txt |
    ${out}    tafssh.Execute     command=ls ${filename}   connection=${alias}
    ${bExist}   Set Variable If     """No such file or directory""" in """${out}"""     0     1
    [Return]   ${bExist}


Check File Existed In Linux Server Via Interactive SSH
    [Arguments]  ${filename}    ${alias}=default
    [Documentation]     Check File Existed In Linux Server Via Interactive SSH
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    | alias    | no | alias name |
    ...    No input parameter.
    ...
    ...    *RETURN VALUE*
    ...    return 1 if file exists, otherwise return 0
    ...
    ...    Example
    ...    | ${bExit} | Check File Existed In Linux Server Via Interactive SSH |  filename=/root/a.txt | alias=default |
    ...
    ${out}    issh.Execute  command=ls ${filename}   alias=${alias}   check_result=${False}
    ${bExist}   Set Variable If     """No such file or directory""" in """${out}"""     0     1
    Return From Keyword If  ${bExist}==0   0
    ${bExist}   Set Variable If     """syntax error near unexpected token""" in """${out}"""     0     1
    [Return]   ${bExist}


Check File Existed In VDUC
    [Arguments]  ${filename}   ${container_id}   ${alias}=default
    [Documentation]   Check File Exist or not inside VDU container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename      | yes | file name |
    ...    | container_id | yes | container_id |
    ...    | alias        | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    return 1 if file exists, otherwise return 0
    ...
    ...    Example
    ...    | ${bExit} | Check File Existed In VDUC |  filename=/root/a.txt | container_id=123adadf23 | alias=default |
    ...
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} ls ${filename}    connection=${alias}
    ${bExist}   Set Variable If     """No such file or directory""" in """${out}"""     0     1
    Return From Keyword If  ${bExist}==0   0
    ${bExist}   Set Variable If     """syntax error near unexpected token""" in """${out}"""     0     1
    [Return]   ${bExist}


Check File Existed In VCUC
    [Arguments]  ${filename}  ${pod_full_name}  ${container_full_name}   ${alias}=default
    [Documentation]   Check File Exist or not inside VCU container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename      | yes | file name |
    ...    | container_id | yes | container_id |
    ...    | alias        | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    return 1 if file exists, otherwise return 0
    ...
    ...    Example
    ...    | ${bExit} | Check File Existed In VDUC |  filename=/root/a.txt | container_id=123adadf23 | alias=default |
    ...
    ${sudo_outer}  Get Sudo For VCU K8s Admin Command
    ${ns}   get cu namespace from testline
    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- ls ${filename}
            ...  check_result=False   alias=${alias}

    ${bExist}   Set Variable If     """No such file or directory""" in """${out}"""     0     1
    Return From Keyword If  ${bExist}==0   0
    ${bExist}   Set Variable If     """syntax error near unexpected token""" in """${out}"""     0     1
    [Return]   ${bExist}


Check File Existed In FHGW Container
    [Arguments]  ${filename}   ${container_id}   ${alias}=default
    [Documentation]    Check File Exist or not inside FHGW container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename      | yes | file name |
    ...    | container_id | yes | container_id |
    ...    | alias        | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    return 1 if file exists, otherwise return 0
    ...
    ...    Example
    ...    | ${bExit} | Check File Existed In FHGW Container |  filename=/root/a.txt | container_id=123adadf23 | alias=default |
    ${out}    issh.Execute     command=docker exec -it ${container_id} ls ${filename}    alias=${alias}   check_result=${False}
    ${bExist}   Set Variable If     """No such file or directory""" in """${out}"""     0     1
    Return From Keyword If  ${bExist}==0   0
    ${bExist}   Set Variable If     """syntax error near unexpected token""" in """${out}"""     0     1
    [Return]   ${bExist}


_Remove All Temp File If Needed
    [Arguments]  ${FolderName}    ${alias}=default
    ${out}    tafssh.Execute       command=ls -F -1 ${FolderName}   connection=${alias}
    ${curr_time}    Get Current Host Time By Linux Cmd   alias=${alias}
    ${lines}   Strip Prompt    content=${out}    return_list=True

    #delete Files 2 Hours Ago
    ${threshold}   Set Variable   7200

    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        ${bExist}   Check File Existed    ${fullname}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed    foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}   alias=${alias}
    END


_Remove All Temp File If Needed In VDU Master Node
    [Arguments]  ${FolderName}    ${alias}=default
    ${out}    tafssh.Execute       command=ls -F -1 ${FolderName}   connection=${alias}
    ${curr_time}    Get Current Host Time By Linux Cmd   alias=${alias}
    #${lines}   Strip Prompt    content=${out}    return_list=True
    ${lines}   split to lines   ${out}

    #delete Files 2 Hours Ago
    ${threshold}   Set Variable   7200

    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        ${bExist}   Check File Existed    ${fullname}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed    foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}   alias=${alias}
    END


_Remove All Temp File If Needed In VCUC Master Node
    [Arguments]  ${FolderName}    ${alias}=default
    ${out}   issh.Execute  command=ls -F -1 ${FolderName}   alias=${alias}
    ${out}   strip prompt  ${out}
    ${curr_time}    Get Current Host Time By Linux Cmd Interactively  alias=${alias}
    ${lines}   split to lines   ${out}

    #delete Files 2 Hours Ago
    ${threshold}   Set Variable   20

    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        #${bExist}   Check File Existed    ${fullname}   alias=${alias}
        ${bExist}     Check File Existed In Linux Server Via Interactive SSH   ${fullname}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed VCUC Master Node    foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}   alias=${alias}
    END


_Remove All Temp File If Needed From FHGW
    [Arguments]  ${FolderName}    ${alias}
    ${out}     issh.Execute    command=ls -F -1 ${FolderName}   alias=${alias}
    ${curr_time}    Get Current Host Time By Linux Cmd Interactively  alias=${alias}
    ${lines}   Strip Prompt    content=${out}    return_list=True

    #delete Files 960 seconds Ago
    ${threshold}   Set Variable   960

    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        ${bExist}   Check File Existed In Linux Server Via Interactive SSH  filename=${fullname}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed Interactively   foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}   alias=${alias}
    END


_Remove All Temp File If Needed From VDUC
    [Arguments]  ${FolderName}    ${container_id}  ${alias}
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} ls -F -1 ${FolderName}    connection=${alias}
    ${curr_time}    Get Current Host Time By Linux Cmd VDUC  container_id=${container_id}  alias=${alias}
    ${lines}   split to lines   ${out}

    #delete Files 16 min ago
    ${threshold}   Set Variable   960

    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        ${bExist}   Check File Existed In VDUC   ${fullname}   container_id=${container_id}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed VDUC   foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}   container_id=${container_id}  alias=${alias}
    END


_Remove All Temp File If Needed From VCUC
    [Arguments]  ${FolderName}   ${pod_full_name}   ${container_full_name}  ${ns}  ${alias}
    #${out}  issh.Execute  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- ls -F -1 ${FolderName}
     #       ...  check_result=False   alias=${alias}
    ${sudo_outer}  Get Sudo For VCU K8s Admin Command

    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- ls ${FolderName}
            ...  check_result=False   alias=${alias}
    ${out}  strip prompt   ${out}
    ${curr_time}    Get Current Host Time By Linux Cmd VCUC   pod_full_name=${pod_full_name}   container_full_name=${container_full_name}
      ...   alias=${alias}
    ${lines}   split to lines   ${out}

    #delete Files 16 min ago
    ${threshold}   Set Variable   160

    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        ${bExist}   Check File Existed In VCUC   ${fullname}
            ...  pod_full_name=${pod_full_name}   container_full_name=${container_full_name}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed VCUC   foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}
        ...   pod_full_name=${pod_full_name}   container_full_name=${container_full_name}    alias=${alias}
    END


_Remove All Temp File If Needed From RUPROXY
    [Arguments]  ${FolderName}    ${container_id}  ${alias}
    ${out}    issh.Execute     command=docker exec -it ${container_id} ls -F -1 ${FolderName}    alias=${alias}
    ${curr_time}    Get Current Host Time By Linux Cmd FHGW Container   container_id=${container_id}  alias=${alias}
    ${lines}   Strip Prompt    content=${out}   return_list=True

    #delete Files 16 min ago
    ${threshold}   Set Variable   960

    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        ${bExist}   Check File Existed In FHGW Container    ${fullname}   container_id=${container_id}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed FHGW Container   foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}   container_id=${container_id}  alias=${alias}
    END


_Remove All Temp File If Needed From General Linux Server
    [Arguments]  ${FolderName}    ${alias}
    ${res}   issh.Execute  command=ls -l ${FolderName}   alias=${alias}
    Log To Console  ${res}

    ${out}     issh.Execute    command=ls -F -1 ${FolderName}   alias=${alias}
    ${curr_time}    Get Current Host Time By Linux Cmd Interactively  alias=${alias}
    ${lines}   Strip Prompt    content=${out}    return_list=True

    #delete Files 960 seconds Ago
    ${threshold}   Set Variable   960

    FOR   ${file}    IN    @{lines}
        #${file}  evaluate  ''.join(i for i in """${file}""" if ord(i)<128)
        ${matches}  Get Regexp Matches   ${file}   .*(ws_[a-zA-Z0-9_]+\.pcap).*   1
        ${file}  Set Variable If  ${matches}   ${matches[0]}   ${EMPTY}
        Log To Console  ${file}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        ${bExist}   Check File Existed In Linux Server Via Interactive SSH   filename=${fullname}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed Interactively   foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}   alias=${alias}
    END


_Remove One Temp File If Needed
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}   ${alias}=default
    # ${foldername}:  /tmp/tmp_wireshark
    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}    Get Modified Time By Linux Cmd   filename=${fullname}   alias=${alias}
    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    ${sudo}   Get Sudo   alias=${alias}
    Run Keyword If   ${bDeleteIt}==1   tafssh.Execute   command=${sudo} rm -rf ${fullname}    connection=${alias}


_Remove One Temp File If Needed VCUC Master Node
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}   ${alias}=default
    # ${foldername}:  /tmp/tmp_wireshark
    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}    Get Modified Time By Linux Cmd Interactively  filename=${fullname}   alias=${alias}
    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    #${sudo}   Get Sudo   alias=${alias}
    Run Keyword If   ${bDeleteIt}==1   issh.Execute   command=rm -rf ${fullname}    alias=${alias}


_Remove One Temp File If Needed Interactively
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}   ${alias}
    # ${foldername}:  /tmp/tmp_wireshark
    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}    Get Modified Time By Linux Cmd Interactively   filename=${fullname}   alias=${alias}
    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    ${sudo}  Run Keyword If   ${bDeleteIt}==1   Get Sudo Via Interactive SSH   alias=${alias}
    Run Keyword If   ${bDeleteIt}==1   issh.Execute  command=${sudo} rm -rf ${fullname}   check_result=${False}  alias=${alias}


_Remove One Temp File If Needed VDUC
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}   ${container_id}  ${alias}
    # ${foldername}:  /tmp/tmp_wireshark
    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}    Get Modified Time By Linux Cmd VDUC   filename=${fullname}  container_id=${container_id}  alias=${alias}
    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    Run Keyword If   ${bDeleteIt}==1
      ...  tafssh.Execute     command=sudo docker exec -it ${container_id} rm -rf ${fullname}    connection=${alias}


_Remove One Temp File If Needed VCUC
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}  ${pod_full_name}   ${container_full_name}  ${alias}
    # ${foldername}:  /tmp/tmp_wireshark
    ${sudo_outer}  Get Sudo For VCU K8s Admin Command
    ${ns}  get cu namespace from testline

    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}    Get Modified Time By Linux Cmd VCUC   filename=${fullname}  pod_full_name=${pod_full_name}
     ...   container_full_name=${container_full_name}  alias=${alias}
    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    ${out}  Run Keyword If   ${bDeleteIt}==1
      ...   issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- rm -rf ${fullname}
      ...  check_result=False   alias=${alias}


_Remove One Temp File If Needed FHGW Container
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}   ${container_id}  ${alias}
    # ${foldername}:  /tmp/tmp_wireshark
    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}   Get Modified Time By Linux Cmd FHGW Container   filename=${fullname}  container_id=${container_id}  alias=${alias}
    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    Run Keyword If   ${bDeleteIt}==1
      ...  issh.Execute     command=docker exec -it ${container_id} rm -rf ${fullname}    alias=${alias}


_Delete Old Wireshark File
    [Arguments]  ${initial_log_path}   ${alias}=default    ${FolderName}=/tmp/tmp_wireshark
    ${res}   tafssh.Execute   command=ls -l ${FolderName}   connection=${alias}
    Log   ${res}
    tafssh.Execute   command=rm -f ${initial_log_path}     connection=${alias}
    _Remove All Temp File If Needed    FolderName=${FolderName}   alias=${alias}


_Delete Old Wireshark File In VDU Master Node
    [Arguments]  ${initial_log_path}   ${alias}=default
    ${res}   tafssh.Execute   command=ls -l /tmp/tmp_wireshark   connection=${alias}
    Log   ${res}
    tafssh.Execute   command=sudo rm -f ${initial_log_path}     connection=${alias}
    _Remove All Temp File If Needed In VDU Master Node   FolderName=/tmp/tmp_wireshark   alias=${alias}


_Delete Old Wireshark File In VCUC Master Node
    [Arguments]  ${initial_log_path}   ${alias}=default
    ${res}   issh.Execute   command=ls -l /tmp/tmp_wireshark   alias=${alias}
    Log   ${res}
    issh.Execute   command=rm -f ${initial_log_path}     alias=${alias}
    _Remove All Temp File If Needed In VCUC Master Node   FolderName=/tmp/tmp_wireshark   alias=${alias}


_Delete Old Wireshark File In FHGW
    [Arguments]  ${initial_log_path}   ${alias}
    ${res}   issh.Execute  command=ls -l /tmp/tmp_wireshark   alias=${alias}
    Log   ${res}
    issh.Execute  command=rm -f ${initial_log_path}     alias=${alias}
    _Remove All Temp File If Needed From FHGW   FolderName=/tmp/tmp_wireshark   alias=${alias}


_Delete Old Wireshark File In VDUC
    [Arguments]  ${initial_log_path}   ${container_id}  ${alias}    ${FolderName}=/tmp/tmp_wireshark
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} rm -f ${initial_log_path}    connection=${alias}
    _Remove All Temp File If Needed From VDUC   FolderName=${FolderName}   container_id=${container_id}  alias=${alias}


_Delete Old Wireshark File In VCUC
    [Arguments]  ${initial_log_path}   ${pod_full_name}  ${container_full_name}  ${ns}   ${alias}
    ${pcap_folder}   set variable    /tmp/tmp_wireshark
    ${sudo_outer}  Get Sudo For VCU K8s Admin Command
    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- rm -f ${initial_log_path}
            ...  check_result=False   alias=${alias}
    _Remove All Temp File If Needed From VCUC   FolderName=${pcap_folder}
      ...   pod_full_name=${pod_full_name}   container_full_name=${container_full_name}   ns=${ns}  alias=${alias}


_Delete Old Wireshark File In RUPROXY
    [Arguments]  ${initial_log_path}   ${container_id}  ${alias}
    ${out}    issh.Execute     command=docker exec -it ${container_id} rm -f ${initial_log_path}    alias=${alias}
    _Remove All Temp File If Needed From RUPROXY   FolderName=/tmp/tmp_wireshark   container_id=${container_id}  alias=${alias}


Get Sudo
    [Arguments]  ${alias}=default
    [Documentation]   if sudo is supported, return sudo, otherwise return ${EMPTY}
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via tafssh library.
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | no | alias name, default value is 'default' |
    ...
    ...    *RETURN VALUE*
    ...    sudo or ${EMPTY}
    ...
    ...    Example
    ...    | ${sudo} | Get Sudo |
    ...
    tafssh.Send Command    command=which sudo ; echo $?    get_pty=${TRUE}   connection=${alias}
    Sleep  0.5
    ${out}   tafssh.Read Output    connection=${alias}
    ${lines}   Split To Lines   ${out}
    ${exit_code}   Set Variable  ${lines[-1]}
    ${exit_code}   Set Variable  ${exit_code.strip()}
    ${rtn}   Set Variable If  "${exit_code}"=="1"  ${EMPTY}   sudo
    [Return]  ${rtn}


Get Sudo Via Interactive SSH
    [Arguments]  ${alias}=default
    [Documentation]   if sudo is supported, return sudo, otherwise return ${EMPTY}
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via tafssh library.
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | no | alias name, default value is 'default' |
    ...
    ...    *RETURN VALUE*
    ...    sudo or ${EMPTY}
    ...
    ...    Example
    ...    | ${sudo} | Get Sudo Via Interactive SSH |
    ...
    ${out}  issh.Execute    command=which sudo ; echo $?     alias=${alias}

    #${out}   tafssh.Read Output    connection=${alias}
    ${out}   Strip Prompt  ${out}
    ${lines}   Split To Lines   ${out}
    ${exit_code}   Set Variable  ${lines[-1]}
    ${exit_code}   Set Variable  ${exit_code.strip()}
    ${rtn}   Set Variable If  "${exit_code}"=="0"   sudo   ${EMPTY}
    [Return]  ${rtn}


Get Sudo VDUC
    [Arguments]  ${container_id}   ${alias}=default
    [Documentation]   if sudo is supported, return sudo, otherwise return ${EMPTY}
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via tafssh library.
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | container_id | yes | container id |
    ...    | alias        | no | alias name, default value is 'default' |
    ...
    ...    *RETURN VALUE*
    ...    sudo or ${EMPTY}
    ...
    ...    Example
    ...    | ${sudo} | Get Sudo VDUC | container_id=243445ab |
    ...
    tafssh.Send Command    command=sudo docker exec -it ${container_id} bash -c "sudo --help && echo CMD_SUCCESS"
       ...   connection=${alias}   get_pty=${True}
    Sleep  0.5
    ${out}   tafssh.Read Output    connection=${alias}

    ${lines}   Split To Lines   ${out}
    ${result}   Set Variable  ${lines[-1]}
    ${result}   Set Variable  ${result.strip()}
    ${rtn}   Set Variable If  "${result}"=="CMD_SUCCESS"   sudo  ${EMPTY}
    [Return]  ${rtn}


Get Sudo VDUCi
    [Arguments]  ${container_id}   ${alias}=default
    [Documentation]   if sudo is supported, return sudo, otherwise return ${EMPTY}
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via tafssh library.
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | container_id | yes | container id |
    ...    | alias        | no | alias name, default value is 'default' |
    ...
    ...    *RETURN VALUE*
    ...    sudo or ${EMPTY}
    ...
    ...    Example
    ...    | ${sudo} | Get Sudo VDUCi | container_id=243445ab |
    ...
    ${out}   issh.Execute   command=sudo docker exec -it ${container_id} bash -c "sudo --help && echo CMD_SUCCESS"
    ...   check_result=False  alias=${alias}
    ${out}   issh.Execute   command=echo $?   check_result=False  alias=${alias}

    ${lines}   Split To Lines   ${out}
    ${result}   Set Variable  ${lines[-1]}
    ${result}   Set Variable  ${result.strip()}
    ${rtn}   Set Variable If  "${result}"=="CMD_SUCCESS"   sudo  ${EMPTY}
    [Return]  ${rtn}


Get Sudo VCUC
    [Arguments]  ${pod_abbr}  ${container}   ${alias}=default  ${gnb_index}=0
    [Documentation]   if sudo is supported, return sudo, otherwise return ${EMPTY}
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via tafssh library.
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | container_id | yes | container id |
    ...    | alias        | no | alias name, default value is 'default' |
    ...
    ...    *RETURN VALUE*
    ...    sudo or ${EMPTY}
    ...
    ...    Example
    ...    | ${sudo} | Get Sudo VDUCi | container_id=243445ab |
    ...
    ${ns}     Get CU Namespace From Testline  gnb_index=${gnb_index}
    ${full_pod_name}   Get CU Full Pod Name By Pod Abbreviation  pod_abbr=${pod_abbr}   gnb_index=${gnb_index}  alias=${alias}
    ${full_container_name}   Get CU Full Container Name By Container Abbreviation  ctr_abbr=${container}

    ${out}  issh.Execute  command=kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- sudo --help && echo CMD_SUCCESS
       ...   check_result=False  alias=${alias}

    ${out}   issh.Execute   command=echo $?   check_result=False  alias=${alias}

    ${lines}   Split To Lines   ${out}
    ${result}   Set Variable  ${lines[-1]}
    ${result}   Set Variable  ${result.strip()}
    ${rtn}   Set Variable If  "${result}"=="CMD_SUCCESS"   sudo  ${EMPTY}
    [Return]  ${rtn}


Send CTRL_C
    [Arguments]  ${alias}=default
    [Documentation]    it sends CTRL+C key message and interrupt current running command
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via hran_network library.
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | no | alias name, default value is 'default' |
    ...
    ...    *RETURN VALUE*
    ...    No return value.
    ...
    ...    Example
    ...    | Send CTRL_C |
    ${crtl_c}    Evaluate    chr(int(3))
    ${out}   tafssh.Write Input    data=${crtl_c}     connection=${alias}
    ${out}   tafssh.Write Input    data=sync   flush=${True}   connection=${alias}
    Sleep    1.3s
    [Return]  ${out}


Send CTRL_C Interactively
    [Arguments]  ${alias}=default
    [Documentation]    it sends CTRL+C key to interrupt current running command
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via issh library.
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | yes | alias name |
    ...
    ...    *RETURN VALUE*
    ...    No return value.
    ...
    ...    Example
    ...    | Send CTRL_C Interactively | alias=default |
    ${crtl_c}    Evaluate    chr(int(3))
    ${out}   issh.Execute_Bare   command=${crtl_c}     alias=${alias}
    Sleep    2.3s
    [Return]  ${out}


Send ENTER Interactively
    [Arguments]  ${alias}=default
    [Documentation]    it sends ENTER key
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via issh library.
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | yes | alias name |
    ...
    ...    *RETURN VALUE*
    ...    No return value.
    ...
    ...    Example
    ...    | Send ENTER Interactively | alias=default |
    ${enter}    Evaluate    chr(int(13))
    ${out}   issh.Execute_Bare   command=${enter}     alias=${alias}
    Sleep    1.3s
    [Return]  ${out}


Send ENTER Interactively VCU CNF
    [Arguments]  ${alias}=default
    [Documentation]    it sends ENTER key
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via issh library.
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | yes | alias name |
    ...
    ...    *RETURN VALUE*
    ...    No return value.
    ...
    ...    Example
    ...    | Send ENTER Interactively VCU CNF | alias=default |
    ${enter}    Evaluate    chr(int(13))
    ${out}   issh.Execute_Bare   command=${enter}     alias=${alias}
    Sleep    2s
    [Return]  ${out}


_Wireshark Get Host Type
    [Documentation]   _Wireshark Get Host Type from host.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | alias | no | alias name, default value is 'default' |
    ...    *RETURN VALUE*
    ...    host type, e.g, LTE, OTHER
    ...    Example
    ...    | _Wireshark Get Host Type |
    ...
    ${host_type}  Set Variable  OTHER
    #${res}   issh.Execute     command=hostname   alias=${alias}
    #${res}   strip prompt  ${res}
    #${res}   Set Variable    ${res.upper()}
    #${host_type}    Run Keyword If    "FCTJ" in """${res}"""    Set Variable    LTE
    #...    ELSE IF    "FCT-" in """${res}"""    set variable    LTE
    #...    ELSE    set variable    OTHER
    [Return]    ${host_type}


_Wireshark Get Host Type Interactively
    [Arguments]  ${alias}=default     ${gnb_index}=0
    [Documentation]   _Wireshark Get Host Type from host. Please use it after keyword connect to ssh host using taf.hw.fhgw.cli.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | alias | no | alias name, default value is 'default' |
    ...    *RETURN VALUE*
    ...    host type, e.g, OAM, CPIF, CPUE, etc.
    ...    Example
    ...    | _Wireshark Get Host Type |
    ${res}     issh.Execute     command=hostname   alias=${alias}
    ${res}    Set Variable    ${res.upper()}
    ${host_type}    Run Keyword If    "OAM" in """${res}"""    Set Variable    VCUOAM
    ...    ELSE    set variable    VCUOTHER

    Return From Keyword If   "${host_type}"!="VCUOAM"    ${host_type}
    ${bIsMasterOAM}    current VM Is Master OAM   alias=${alias}  gnb_index=${gnb_index}
    ${host_type}   Set Variable If  ${bIsMasterOAM}==1   VCUOAMMASTER   VCUOAMSLAVE
    [Return]    ${host_type}


Current VM Is Master OAM
    [Arguments]   ${alias}=default     ${gnb_index}=0
    ${res}     issh.Execute     command=hostname   alias=${alias}
    ${current_host_name}   Strip Prompt  ${res}
    ${current_host_name}    Set Variable    ${current_host_name.upper()}

    ${alias_oam_master}  Get Unique Id
    CU SSH To OAM  alias=${alias_oam_master}  gnb_index=${gnb_index}
    ${res}     issh.Execute     command=hostname   alias=${alias_oam_master}
    ${master_host_name}   Strip Prompt  ${res}
    ${master_host_name}    Set Variable    ${master_host_name.upper()}

    Disconnect Interactive Connection  alias=${alias_oam_master}
    ${bRtn}   Set Variable If  "${current_host_name}"=="${master_host_name}"   1   0
    [Return]  ${bRtn}


Start Wireshark F1 Log On CU
    [Arguments]    ${alias}=default
    [Documentation]    Begin to capture wireshark log on F1 interface for CPIF,
    ...    the return value is a temporary file name which exists in target server
    ...    *AUTHOR* alisha.wu@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias      | No | alias name  |
    ...    *RETURN VALUE*
    ...    Wireshark temporary file name in target server. It will be deleted after calling 'End Wireshark'.
    ...    Example
    ...    | Start Wireshark F1 Log On CU |
    Log To Console    Start Wireshark on F1 interface
    ${tmpfile_pcap}    Begin Wireshark   interface=fronthaul   host_type=VCU    filter=sctp    alias=${alias}
    [Return]    ${tmpfile_pcap}

Stop Wireshark F1 Log On CU
    [Arguments]    ${tmpfile_pcap}    ${pcap_name}    ${alias}=default
    [Documentation]    Stop wireshark log for F1 interface, and get log to local
    ...    *AUTHOR* alisha.wu@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | tmpfile_pcap | yes | a handler returned by 'Begin Wireshark' which stands for the source log location of wireshark server |
    ...    | pcap_name | yes | for this variable, keyword user named the captured pcap log  |
    ...    | alias      | No | alias name  |
    ...    *RETURN VALUE*
    ...    the captured pcap log, to be analyzed further by keyword user.
    ...    Example
    ...    | Stop Wireshark F1 Log On CU |  /tmp/ws_cf8df.pcap  |  myf1pcapfile.pcap  |
    Log To Console    Stop wireshark log for specified interface and host type
    ${local_file}   Get A File   Wireshark   ${pcap_name}
    End Wireshark     log_dst_path=${local_file}   log_src_path=${tmpfile_pcap}    alias=${alias}
    [Return]   ${local_file}

Start Wireshark X2 Uplane Log On CU
    [Arguments]  ${alias}=default
    [Documentation]    Begin to capture x2-U wireshark log, the return value is a temporary file name which exists in target server
    ...    *AUTHOR* alisha.wu@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | yes | alias |
    ...    *RETURN VALUE*
    ...    No return value.
    ${tmpfile_pcap}    Begin Wireshark   interface=x2   host_type=VCU    filter=gtp   alias=${alias}
    [Return]  ${tmpfile_pcap}

Stop Wireshark X2 Uplane Log On CU
    [Arguments]    ${tmpfile_pcap}    ${pcap_name}    ${alias}=default
    [Documentation]    Stop wireshark log for F1 interface, and get log to local
    ...    *AUTHOR* alisha.wu@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | tmpfile_pcap | yes | a handler returned by 'Begin Wireshark' which stands for the source log location of wireshark server |
    ...    | pcap_name | yes | for this variable, keyword user named the captured pcap log  |
    ...    | alias      | No | alias name  |
    ...    *RETURN VALUE*
    ...    the captured pcap log, to be analyzed further by keyword user.
    ...    Example
    ...    | Stop Wireshark F1 Log On CU |  /tmp/ws_cf8df.pcap  |  myf1pcapfile.pcap  |
    Log To Console    Stop wireshark log for specified interface and host type
    ${local_file}   Get A File   Wireshark   ${pcap_name}
    End Wireshark     log_dst_path=${local_file}   log_src_path=${tmpfile_pcap}    alias=${alias}
    [Return]   ${local_file}

Start Wireshark X2 Log On CU
    [Arguments]  ${alias}=default
    [Documentation]    Begin to capture wireshark log, the return value is a temporary file name which exists in target server
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | yes | alias |
    ...    *RETURN VALUE*
    ...    No return value.
    ${tmpfile_pcap}    Begin Wireshark   interface=x2   host_type=VCU    filter=sctp   alias=${alias}
    [Return]  ${tmpfile_pcap}

Stop Wireshark X2 Log On CU
    [Arguments]   ${tmpfile_pcap}   ${alias}=default
    [Documentation]    Stop capturing wireshark log and get log to local
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | yes | alias |
    ...    *RETURN VALUE*
    ...    No return value.
    ${local_file}   Get A File   Wireshark   mypcapfile.pcap
    End Wireshark     log_dst_path=${local_file}   log_src_path=${tmpfile_pcap}   alias=${alias}
    [Return]  ${local_file}


Check L2 Specific Log All In Snapshot
    [Arguments]  ${snapshot_path}
    [Documentation]    check Specific L2 Log All in Snapshot, log file should exist and it should not be empty
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L2 Specific Log All In Snapshot | snapshot_path=${snapshot} |
    ...
    Check L2 Ps Log Should Be In Snapshot  ${snapshot_path}
    Check L2 Lo Log Should Be In Snapshot  ${snapshot_path}
    Check L2 Hi Log Should Be In Snapshot  ${snapshot_path}


Check L2 Specific Log In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}
    [Documentation]    check Specific L2 Log in Snapshot, log file should exist and it should not be empty
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | yes | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L2 Specific Log In Snapshot | snapshot_path=${snapshot} | L2TtiTrace_EventsSnapshot |
    ...   | Check L2 Specific Log In Snapshot | snapshot_path=${snapshot} | L2TraceHi_DU |
    ...
    ${file_list}  Get Specific Log File Name From Snapshot  snapshot_path=${snapshot_path}
    ...  log_file_name_keyword=${log_file_name_regex_string}  retrieve_type=FILE
    Should Be True  ${file_list.__len__()}>=1   log file not found in snapshot with regex string: ${log_file_name_regex_string}
    FOR  ${file}   IN   @{file_list}
       File Should Not Be Empty   ${file}    file is empty: ${file}
    END

Check L2 Ps Log Should Be In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}=L2TtiTrace_EventsSnapshot
    [Documentation]    check l2 ps log should be in snapshot,and log file should not be empty
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | No | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L2 Ps Log Should Be In Snapshot | snapshot_path=${snapshot} |
    ...   | Check L2 Ps Log Should Be In Snapshot | snapshot_path=${snapshot} | log_type=L2TtiTrace_EventsSnapshot |
    ...
    Check L2 Specific Log In Snapshot   ${snapshot_path}  ${log_file_name_regex_string}


Check L2 Hi Log Should Be In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}=L2TraceHi_DU
    [Documentation]    Check l2 hi log should be in snapshot,and log file should not be empty
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | No | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L2 Hi Log Should Be In Snapshot | snapshot_path=${snapshot} |
    ...   | Check L2 Hi Log Should Be In Snapshot | snapshot_path=${snapshot} | log_type=L2TraceHi_DU |
    ...
    Check L2 Specific Log In Snapshot   ${snapshot_path}  ${log_file_name_regex_string}

Check L2 Lo Log Should Be In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}=L2TraceLo
    [Documentation]    Check l2 lo log should be in snapshot,and log file should not be empty
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | No | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L2 Lo Log Should Be In Snapshot | snapshot_path=${snapshot} |
    ...   | Check L2 Lo Log Should Be In Snapshot | snapshot_path=${snapshot} | log_type=L2TraceLo |
    ...
    Check L2 Specific Log In Snapshot   ${snapshot_path}  ${log_file_name_regex_string}


Get Specific Log File Name From Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_keyword}
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]    Get Specific Log File Name From Snapshot
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | snapshot_path       | yes | snapshot file path |
    ...    | log_file_name_keyword | yes | log_file_name_keyword, e.g, L2hi, l2lo or l2ps, it's a regex string |
    ...    | retrieve_type | no | retrieve_type, e.g, FILE, DIR, FILE_AND_DIR, default is FILE |
    ...
    ...    *RETURN VALUE*
    ...    Return value is a list, list content is absoluate path of log file.
    ...    Return empty list if find nothing.
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | ${log_value}  | Get Specific Log File Name From Snapshot | snapshot_path=${snapshot} | log_file_name_keyword=pm_1_syslog |
    ...   | VDU Rest Logout|
    ...
    Should Not Be Empty  ${log_file_name_keyword}
    OperatingSystem.Directory Should Exist   ${snapshot_path}
    ${alias}  Get Unique Id
    Connect To UTE Locally   alias=${alias}
    ${snapshot_zip_file_path_list}   List_Files_In_Directory    ${snapshot_path}  Snapshot*.zip
    ${snapshot_zip_file_path}  OperatingSystem.Join Path   ${snapshot_path}   ${snapshot_zip_file_path_list[0]}
    ${extract_path}  ${dummy_ext}   Split Extension     ${snapshot_zip_file_path}
    Run Keyword And Ignore Error    Remove Directory   ${extract_path}   recursive=True
    _Extract Zip File  file=${snapshot_zip_file_path}  alias=${alias}   check_file_exist=${True}   remove_zip_file=${False}
    ${dummy}   ${zip_file_fullpath_list}  List File With Extension   path=${extract_path}   extension=.zip
    _Extract Zip File List   zip_file_list=${zip_file_fullpath_list}   alias=${alias}
    ...   check_file_exist=${TRUE}    remove_zip_file=${False}
    ${file_list}   ${file_fullpath_list}    List File    path=${extract_path}   retrieve_type=FILE_AND_DIR
    ${index}  Set Variable  0
    ${rtn_file_list}  Create List
    FOR  ${filename}   IN   @{file_list}
       ${matches}  Get Regexp Matches  ${filename}   ${log_file_name_keyword}
       Run Keyword If    ${matches}   Append To List    ${rtn_file_list}  ${file_fullpath_list[${index}]}
       ${index}   Evaluate  str(int('${index}')+1)
    END
    [Return]  ${rtn_file_list}


Get Specific Log File Name From Snapshot old
    [Arguments]  ${snapshot_path}  ${log_file_name_keyword}  ${retrieve_type}=FILE
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]    Get Specific Log File Name From Snapshot
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | snapshot_path       | yes | snapshot file path |
    ...    | log_file_name_keyword | yes | log_file_name_keyword, e.g, L2hi, l2lo or l2ps, it's a regex string |
    ...    | retrieve_type | no | retrieve_type, e.g, FILE, DIR, FILE_AND_DIR, default is FILE |
    ...
    ...    *RETURN VALUE*
    ...    Return value is a list, list content is absoluate path of log file.
    ...    Return empty list if find nothing.
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | ${log_value}  | Get Specific Log File Name From Snapshot | snapshot_path=${snapshot} | log_file_name_keyword=pm_1_syslog |
    ...   | VDU Rest Logout|
    ...
    Should Not Be Empty  ${log_file_name_keyword}
    OperatingSystem.Directory Should Exist   ${snapshot_path}
    ${alias}  Get Unique Id
    Connect To UTE Locally   alias=${alias}
    ${extract_path}   set variable  ${snapshot_path}

    ${dummy}   ${zip_file_fullpath_list}  List File With Extension   path=${extract_path}   extension=.zip
    _Extract Zip File List   zip_file_list=${zip_file_fullpath_list}   alias=${alias}
    ...   check_file_exist=${TRUE}    remove_zip_file=${False}
    #${file_list}   ${file_fullpath_list}    List File    path=${extract_path}   retrieve_type=FILE_AND_DIR
    ${file_list}   ${file_fullpath_list}    List File    path=${extract_path}   retrieve_type=${retrieve_type}
    ${index}  Set Variable  0
    ${rtn_file_list}  Create List
    FOR  ${filename}   IN   @{file_list}
       ${matches}  Get Regexp Matches  ${filename}   ${log_file_name_keyword}
       Run Keyword If    ${matches}   Append To List    ${rtn_file_list}  ${file_fullpath_list[${index}]}
       ${index}   Evaluate  str(int('${index}')+1)
    END
    [Return]  ${rtn_file_list}


_Extract Zip File List
    [Arguments]  ${zip_file_list}  ${remove_zip_file}  ${alias}=default   ${check_file_exist}=${True}
    FOR   ${file}  IN  @{zip_file_list}
       _Extract Zip File  file=${file}  alias=${alias}   check_file_exist=${check_file_exist}
      ...   remove_zip_file=${remove_zip_file}
    END

_Extract Zip File
    [Arguments]  ${file}  ${remove_zip_file}   ${alias}=default   ${check_file_exist}=${True}
    Run Keyword If  ${check_file_exist}  File Should Exist  ${file}
    ${size}   Get_File_Size   ${file}
    Return From Keyword If  ${size}==0
    ${extract_path}  ${dummy_ext}   Split Extension     ${file}
    Run Keyword And Ignore Error   issh.Execute   command=rm -rf ${extract_path}   alias=${alias}
    Return From Keyword If  "${dummy_ext}"!='zip'
    ${out}   issh.Execute   command=unzip -n ${file} -d ${extract_path}    alias=${alias}
    ${out}  Run Keyword If  "${remove_zip_file}"=="${True}"   issh.Execute   command=rm -f ${file}   alias=${alias}

_Get Snapshot File List
    [Arguments]  ${snapshot_path}   ${snapshot_file_list_file_name}=snapshot_file_list.txt
    ${snapshot_file_list_file_name_full}   OperatingSystem.Join Path   ${snapshot_path}   ${snapshot_file_list_file_name}
    ${content}   OperatingSystem.Get File   ${snapshot_file_list_file_name_full}
    ${lines}     Split To Lines   ${content}
    ${rtn}   Create List
    ${new_section}  Set Variable  0
    ${current_folder_name}   Set Variable  ${EMPTY}
    FOR   ${line}   IN   @{lines}
       Log To Console   ${line}
       ${striped_line}   Set Variable  ${line.strip()}
       Continue For Loop If  ${striped_line.__len__()}==0
       ${current_folder_name}  Set Variable If  ${line.endswith(":")}    ${line.split(".zip:")[0]}    ${current_folder_name}
       Continue For Loop If   ${line.endswith(":")}
       ${current_file}   Run Keyword If  ${line.startswith(" ")}
                    ...   OperatingSystem.Join Path   ${snapshot_path}   ${current_folder_name}  ${striped_line}
       ...   ELSE    OperatingSystem.Join Path   ${snapshot_path}    ${striped_line}
       Append To List  ${rtn}    ${current_file}
    END
    [Return]   ${rtn}


Start To Collect TTI Trace
    [Arguments]     ${vdu_index}=${0}
    [Documentation]  Start to collect L2RT TTI trace
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <21-Aug-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  vdu_index        | No   |  the index of vdu,  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Start To Collect TTI Trace |  ${0}  |
    vDU Cluster Login With Tenant     vdu_index=${vdu_index}
    log to console    start to collect the tti trace
    ${up_pod_name} =    Get Full Pod Name By Pod Abbreviation      pod_abbr=up    vdu_index=${vdu_index}
    set test variable    ${up_pod_name}
    FOR  ${container}  IN  @{AIC_VDU_PODS['up']}
       run keyword if    'l2rt' in '${container}'   set test variable   ${l2_rt_container}   ${container}
    END
    ${l2_rt_container}   Get Full Container Name By Container Abbreviation   ctr_abbr=${l2_rt_container}
    set test variable    ${l2_rt_container}
    Collect TTI Trace in L2RT    pod_name=${up_pod_name}    container_name=${l2_rt_container}    vdu_index=${vdu_index}


Collect TTI Trace in L2RT
    [Arguments]    ${pod_name}    ${container_name}    ${vdu_index}=${0}
    [Documentation]  Login to L2RT and run eventsCollect.sh
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <21-Aug-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  pod_name         | Yes   |  the full name of up |
    ...    |  container_name   | Yes   |  the full name of l2rt |
    ...    |  vdu_index        | No    |  the index of vdu,  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Collect TTI Trace in L2RT |  aic-vdu-aic-vdu-mvp-up-0  |  ${0}  |
    log to console    connect to l2rt container
    Connect To vDU Container    ${pod_name}    ${container_name}    vdu_index=${vdu_index}
    #log to console    modify eventsCollect.sh
    #execute command in container     sed -i 's/WAIT_TIME=0.2s/WAIT_TIME=0.1s/g' /opt/nokia/tools/ttiTrace/eventsCollect.sh
    log to console    empty /var/eventsTrace
    Execute Command In Container     rm -rf /var/eventsTrace, \#
    log to console    run eventsCollect.sh
    ${output} =    Execute Command In Container     nohup bash /opt/nokia/tools/ttiTrace/eventsCollect.sh > /tmp/tti_logs 2>&1 &    bash
    ${process_id_temp} =     Get Regexp Matches     ${output}     \\s\\d+
    ${process_id_temp} =     Get Regexp Matches     ${process_id_temp[0]}    \\d+
    Set Test Variable     ${process_id}     ${process_id_temp[0]}
    [teardown]    Exit From Container


Stop And Download TTI Trace
    [Arguments]    ${pod_name}=${up_pod_name}    ${container_name}=${l2_rt_container}    ${vdu_index}=${0}
    [Documentation]  Stop and downlaod all the tti trace files
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <21-Aug-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  pod_name         | No   |  the full name of up |
    ...    |  container_name   | No   |  the full name of l2rt |
    ...    |  vdu_index        | No   |  the index of vdu,  ${0} in default |
    ...    *RETURN VALUE*
    ...    trace_path_list in ute
    ...    Example
    ...    |  Stop And Download TTI Trace |  aic-vdu-aic-vdu-mvp-up-0  |  ${0}  |
    Log To Console     connect to l2rt container
    Connect To vDU Container    ${pod_name}    ${container_name}   vdu_index=${vdu_index}
    Log To Console     stop the tti trace collection
    Execute Command In Container    kill -9 ${process_id}   bash
    Execute Command In Container    cd /var/eventsTrace/
    ${output} =    Execute Command In Container    ls   bash
    ${tti_files} =     Get Regexp Matches     ${output}     \\w+EventsSnapshot\.bin\.\\d+\.tar\.gz
    ${tti_files_number} =     Get Length     ${tti_files}
    ${trace_path_list}=    Download Directory From VDU     pod_name=up     container_name=l2rt
    ...    file_path=/var/eventsTrace    file_name_list=${tti_files}     vdu_index=${vdu_index}
    log    ${trace_path_list}
    [return]    ${trace_path_list}
    [teardown]    Exit From Container



Stop And Download Recent 3 TTI Trace
    [Arguments]    ${pod_name}=${up_pod_name}    ${container_name}=${l2_rt_container}    ${vdu_index}=${0}
    [Documentation]  Stop and downlaod recent 3 tti trace files
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <21-Apr-2020>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  pod_name         | No   |  the full name of up |
    ...    |  container_name   | No   |  the full name of l2rt |
    ...    |  vdu_index        | No   |  the index of vdu,  ${0} in default |
    ...    *RETURN VALUE*
    ...    trace_path_list in ute
    ...    Example
    ...    | ${Trace_log}    Stop And Download Recent 3 TTI Trace|
    Log To Console     connect to l2rt container
    Connect To vDU Container    ${pod_name}    ${container_name}   vdu_index=${vdu_index}
    Log To Console     stop the tti trace collection
    Execute Command In Container    kill -9 ${process_id}   bash
    Execute Command In Container    cd /var/eventsTrace/
    ${output} =    Execute Command In Container    ls   bash
    ${tti_files_number} =     Get Regexp Matches     ${output}     \\w+EventsSnapshot\.bin\.(\\d+)\.tar\.gz     1
	${max_tti_files_number}    Evaluate    max([int(i) for i in ${tti_files_number}])
    log to console    ${max_tti_files_number}
    ${second_tti_files_number}    Evaluate    ${max_tti_files_number}-1
	${third_tti_files_number}    Evaluate    ${max_tti_files_number}-2
	${tti_files}   Create List   _L2TtiTrace_EventsSnapshot.bin.${max_tti_files_number}.tar.gz
	...  _L2TtiTrace_EventsSnapshot.bin.${second_tti_files_number}.tar.gz
    ...  _L2TtiTrace_EventsSnapshot.bin.${third_tti_files_number}.tar.gz
	${trace_path_list}=    Download Directory From VDU     pod_name=up     container_name=l2rt
    ...    file_path=/var/eventsTrace    file_name_list=${tti_files}     vdu_index=${vdu_index}
    log    ${trace_path_list}
    [return]    ${trace_path_list}
    [teardown]    Exit From Container


Download Directory From VDU
    [Arguments]    ${pod_name}    ${container_name}    ${file_path}
    ...            ${file_name_list}
    [Documentation]  Download all the files in specific dir to ute
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <21-Aug-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  pod_name         | No   |  the abbr name of pod, such as up |
    ...    |  container_name   | No   |  the container name, such as l2rt |
    ...    |  file_path        | No   |  file_path in OE |
    ...    |  file_name_list   | No   |  tti trace file name list |
    ...    |  vdu_index        | No   |  the index of vdu,  ${0} in default |
    ...    *RETURN VALUE*
    ...    trace_path_list in ute
    ...    Example
    ...    |  Stop And Download TTI Trace |  aic-vdu-aic-vdu-mvp-up-0  |  ${0}  |
    tafssh.Reset Cache
    ${alias} =    Connect To vDU Node     pod_abbr=${pod_name}     master_alias=MASTER     node_alias=NODE
    ${container_id} =     Get vDU Container ID     ${container_name}     ${alias}
    log to console    empty /home/cloudadmin/eventsTrace
    tafssh.Execute    command=rm -rf /home/cloudadmin/eventsTrace   connection=NODE
    tafssh.Execute    command=sudo docker cp ${container_id}:${file_path} /home/cloudadmin   connection=NODE   timeout=20
    @{file_path_list}=    create list
    FOR    ${file_name}  IN  @{file_name_list}
        ${local_log_file_path} =     Get A File     eventsTrace     ${file_name}
        append to list    ${file_path_list}     ${local_log_file_path}
        tafssh.File Exists     /home/cloudadmin/eventsTrace/${file_name}     connection=NODE
        tafssh.Download File     remote_path=/home/cloudadmin/eventsTrace/${file_name}
        ...        local_path=${local_log_file_path}    connection=NODE
    END
    [return]     ${file_path_list}
    tafssh.Reset Cache


Check RT Log Should Be In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}=E300_rtlog
    [Documentation]    Check RT log should be in snapshot,and log file should not be empty
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | No | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check RT Log Should Be In Snapshot | ${snapshot} |
    ...   | Check RT Lo Log Should Be In Snapshot | ${snapshot} | E300_rtlog |
    ...
    Check L1 Specific Log In Snapshot   ${snapshot_path}  ${log_file_name_regex_string}


Check L1 EMtraceHb0 Log Should Be In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}=E300_EmTraceHb0
    [Documentation]    Check L1 EMtraceHb0 should be in snapshot,and log file should not be empty
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | No | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L1 EMtrace Log Should Be In Snapshot | ${snapshot} |
    ...   | Check l1 EMtrace Log Should Be In Snapshot | ${snapshot} | E300_EmTraceHb0 |
    ...
    Check L1 Specific Log In Snapshot   ${snapshot_path}  ${log_file_name_regex_string}


Check L1 EMtraceHb1 Log Should Be In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}=E300_EmTraceHb1
    [Documentation]    Check L1 EMtraceHb1 should be in snapshot,and log file should not be empty
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | No | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L1 EMtrace Log Should Be In Snapshot | ${snapshot} |
    ...   | Check l1 EMtrace Log Should Be In Snapshot | ${snapshot} | E300_EmTraceHb1 |
    ...
    Check L1 Specific Log In Snapshot   ${snapshot_path}  ${log_file_name_regex_string}


Check L1 EMtraceHb2 Log Should Be In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}=E300_EmTraceHb2
    [Documentation]    Check L1 EMtraceHb2 should be in snapshot,and log file should not be empty
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | No | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L1 EMtrace Log Should Be In Snapshot | ${snapshot} |
    ...   | Check l1 EMtrace Log Should Be In Snapshot | ${snapshot} | E300_EmTraceHb2 |
    ...
    Check L1 Specific Log In Snapshot   ${snapshot_path}  ${log_file_name_regex_string}


Check L1 Specific Log In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}
    [Documentation]    check Specific L1 Log in Snapshot, log file should exist and it should not be empty
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | yes | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L1 Specific Log In Snapshot | ${snapshot} | E300_rtlog.bin |
    ...   | Check L1 Specific Log In Snapshot | ${snapshot} | E300_EmTraceHb0 |
    ...
    ${file_list}  Get Specific Log File Name From Snapshot  snapshot_path=${snapshot_path}
    ...  log_file_name_keyword=${log_file_name_regex_string}  retrieve_type=FILE
    Should Be True  ${file_list.__len__()}>=1   log file not found in snapshot with regex string: ${log_file_name_regex_string}
    FOR  ${file}   IN   @{file_list}
       File Should Not Be Empty   ${file}    file is empty: ${file}
    END


Check L1 Specific Log All In Snapshot
    [Arguments]  ${snapshot_path}
    [Documentation]    check Specific L1 Log All in Snapshot, log file should exist and it should not be empty
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L1 Specific Log All In Snapshot | ${snapshot} |
    ...
    Check RT Log Should Be In Snapshot  ${snapshot_path}
    Check L1 EMtraceHb0 Log Should Be In Snapshot  ${snapshot_path}
    Check L1 EMtraceHb1 Log Should Be In Snapshot  ${snapshot_path}
    Check L1 EMtraceHb2 Log Should Be In Snapshot  ${snapshot_path}


Check L1 snapshot nrt Log Should Be In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}=E300_l1_snapshot_nrt
    [Documentation]    Check L1 snapshot nrt should be in snapshot,and log file should not be empty
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | No | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L1 snapshot nrt Log Should Be In Snapshot | ${snapshot} |
    ...   | Check L1 snapshot nrt Log Should Be In Snapshot | ${snapshot} | E300_l1_snapshot_nrt |
    ...
    Check IQ Specific Log In Snapshot   ${snapshot_path}  ${log_file_name_regex_string}


Check L1 snapshot rt Log Should Be In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}=E300_l1_snapshot_rt
    [Documentation]    Check l1 snapshot rt should be in snapshot,and log file should not be empty
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | No | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check L1 snapshot rt Log Should Be In Snapshot | ${snapshot} |
    ...   | Check L1 snapshot rt Log Should Be In Snapshot | ${snapshot} | E300_l1_snapshot_rt |
    ...
    Check IQ Specific Log In Snapshot   ${snapshot_path}  ${log_file_name_regex_string}


Check IQ Specific Log In Snapshot
    [Arguments]  ${snapshot_path}  ${log_file_name_regex_string}
    [Documentation]    check Specific IQ Log in Snapshot, log file should exist and it should not be empty
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | yes | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check IQ Specific Log In Snapshot | ${snapshot} | E300_l1_snapshot_nrt |
    ...   | Check IQ Specific Log In Snapshot | ${snapshot} | E300_l1_snapshot_rt |
    ...
    ${file_list}  Get Specific Log File Name From Snapshot  snapshot_path=${snapshot_path}
    ...  log_file_name_keyword=${log_file_name_regex_string}  retrieve_type=FILE
    Should Be True  ${file_list.__len__()}>=1   log file not found in snapshot with regex string: ${log_file_name_regex_string}
    FOR  ${file}   IN   @{file_list}
       File Should Not Be Empty   ${file}    file is empty: ${file}
    END


Check IQ Specific Log All In Snapshot
    [Arguments]  ${snapshot_path}
    [Documentation]    check Specific IQ Log All in Snapshot, log file should exist and it should not be empty
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...
    ...    *RETURN VALUE*
    ...    NONE
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check IQ Specific Log All In Snapshot | ${snapshot} |
    ...
    Check L1 snapshot nrt Log Should Be In Snapshot  ${snapshot_path}
    Check L1 snapshot rt Log Should Be In Snapshot  ${snapshot_path}

Check FlowCtrl Value In Snapshot
    [Arguments]    ${snapshot_path}    ${log_file_name_regex_string}=E100_LINUX_runtime    ${key}=dlFCAlgo =
    [Documentation]    check Specific FlowCtrl value in Snapshot
    ...    *AUTHOR* eahsuan.xuan@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | yes | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check Specific FlowCtrl value In Snapshot | snapshot_path=${snapshot} |
    ...   | Check Specific FlowCtrl value In Snapshot | snapshot_path=${snapshot} | dlFCAlgo |
    ${file_list}    Get Specific Log File Name From Snapshot    snapshot_path=${snapshot_path}
    ...  log_file_name_keyword=${log_file_name_regex_string}    retrieve_type=FILE
    Should Be True  ${file_list.__len__()}>=1   log file not found in snapshot with regex string: ${log_file_name_regex_string}
    ${alias}  Get Unique Id
    Connect To UTE Locally   alias=${alias}
    FOR  ${file}   IN   @{file_list}
       File Should Not Be Empty    ${file}    file is empty: ${file}
       ${extract_path}  ${dummy_ext}   Split Extension     ${file}
    END
    _Extract Zip File    file=${file}  alias=${alias}   check_file_exist=${True}   remove_zip_file=${False}
    ${dummy}   ${zip_file_fullpath_list}  List File With Extension   path=${extract_path}   extension=.log
    ${out}    issh.Execute    awk -F '${key}' '{print $2}' ${zip_file_fullpath_list[0]} | cut -c1-1    alias=${alias}
    ${out1}    Strip String    ${out}    characters='\r\n'
    ${dlFlowControlAlgo}    Set Variable    ${out1[0]}
    [Return]  ${dlFlowControlAlgo}


Check auditlog In Snapshot
    [Arguments]    ${snapshot_path}    ${log_file_name_regex_string}=auditlogs
    [Documentation]    check auditlog in Snapshot
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...    | Input Parameters            | Man. | Description |
    ...    | snapshot_path               | yes | snapshot abosolute file path, not including file name |
    ...    | log_file_name_regex_string  | yes | it's a regex string for log file name to check |
    ...
    ...    *RETURN VALUE*
    ...
    ...
    ...    Example
    ...   | VDU Rest Login |
    ...   | ${snapshot}    | Get A Directory | snapshot |
    ...   | vdu.Get_Local_Snapshot | ${snapshot} |
    ...   | Check auditlog In Snapshot | snapshot_path=${snapshot} |
    ...   | Check auditlog In Snapshot | snapshot_path=${snapshot} | STOP_UPLANE_TRACE |
    ${file_list}    Get Specific Log File Name From Snapshot    snapshot_path=${snapshot_path}
    ...  log_file_name_keyword=${log_file_name_regex_string}    retrieve_type=FILE
    Should Be True  ${file_list.__len__()}>=1   log file not found in snapshot with regex string: ${log_file_name_regex_string}
    ${alias}  Get Unique Id
    Connect To UTE Locally   alias=${alias}
    FOR  ${file}   IN   @{file_list}
       File Should Not Be Empty    ${file}    file is empty: ${file}
       ${extract_path}  ${dummy_ext}   Split Extension     ${file}
    END
    _Extract Zip File    file=${file}  alias=${alias}   check_file_exist=${True}   remove_zip_file=${False}
    ${dummy}    ${zip_file_fullpath_list}  List File   path=${extract_path}   retrieve_type=FILE
	[Return]  ${zip_file_fullpath_list[0]}

Decoder TTITrace With Linux Server
    [Arguments]  ${ttitrace_server_ip}  ${username}  ${password}  ${vdu_version}  ${ttiTrace_files_list}=${EMPTY}
    ...  ${alias}=ttiTrace_linux_server
    ...  ${tool_base_repo}=https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/
    [Documentation]  decode the tti trace bin.tar.gz files, the ttitrace file name is like 'L2TtiTrace_EventsSnapshot.bin.4.tar.gz'
    ...    author: calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ttitrace_server_ip | Yes |  the ttitrace decoded server ip |
    ...    | username | Yes |  the server username |
    ...    | password | Yes |  the server password |
    ...    | vdu_version | Yes |  vdu build version |
    ...    | ttiTrace_files_list | Yes | ttitrace bin gz files list, returned from kw-Stop And Download TTI Trace|
    ...    | alias | NO | the server connection alias, default is ttiTrace_linux_server |
    ...    | tool_base_repo | NO | the repo of download the ttitrace tool |
    ...    *RETURN VALUE*
    ...    the ul csv files folder, the dl csv fils folder
    ...    Example
    ...    | Decoder TTITrace With Linux Server | 10.108.229.50 |ute | ute | 0.390.1222 | ${tti_files_list}
    tafssh.connect_to
    ...  hostname=${ttitrace_server_ip}
    ...  username=${username}
    ...  password=${password}
    ...  alias=${alias}
    _Create Related Folders  ${alias}
    _Get Decode Tool And Untar  ${tool_base_repo}  ${vdu_version}  ${alias}
    ${local_dl_csv}  ${local_ul_csv}  _Decode TTITRACE Bin Files And Download csv To Local  ${ttiTrace_files_list}  ${alias}
    [Return]  ${local_dl_csv}  ${local_ul_csv}
    [Teardown]  tafssh.disconnect  connection=${alias}

_Create Related Folders
    [Arguments]  ${conn_alias}
    ${home_dir}=  tafssh.execute  command=pwd   connection=${conn_alias}
    ${timestamp}=    Get Time    epoch
    ${home_dir}=  Strip String  ${home_dir}
    Set test Variable   ${ttiTrace_Dir}   ${home_dir}/ttiTrace_${timestamp}
    set test variable  ${tti_bins_dir}   ${ttiTrace_Dir}/tti-dec-bin/ttitrace_bins
    set test variable   ${decoded_csv}   ${ttiTrace_Dir}/tti-dec-bin/decoded_csv
    tafssh.Execute  command=mkdir ${ttiTrace_Dir} && mkdir -p ${tti_bins_dir} && mkdir -p ${decoded_csv}
    ...  connection=${conn_alias}

_Get Decode Tool And Untar
    [Arguments]   ${tool_base_repo}  ${vdu_version}  ${conn_alias}
    ${ret}  ${version}=  Split String From Right  ${vdu_version}  separator=300.  max_split=1
    ${decoder_tool_name}=  set variable  5G22R1_GNB_0000_000300_00${version}_tti-dec_qemux86-64-static.txz
    ${tool_url}=  set variable  ${tool_base_repo}/${vdu_version}/${decoder_tool_name}
    tafssh.Execute  command=wget --no-check-certificate ${tool_url} -P ${ttiTrace_Dir}  connection=${conn_alias}
    tafssh.Execute  command=cd ${ttiTrace_Dir} && tar -xJvf ${ttiTrace_Dir}/${decoder_tool_name} && rm -f ${decoder_tool_name}
    ...  connection=${conn_alias}

_Decode TTITRACE Bin Files And Download csv To Local
    [Arguments]   ${ttiTrace_files_list}   ${conn_alias}
    ${local_dl_csv}=  Get A Directory  ttiTrace_DL_CSV
    ${local_ul_csv}=  Get A Directory  ttiTrace_UP_CSV
    FOR  ${ttitrace_file}  IN  @{ttiTrace_files_list}
      ${path}  ${gz_file_name}=  OperatingSystem.Split Path  ${ttitrace_file}
      ${bin_file_name}=  Fetch From Left  ${gz_file_name}  marker=.tar.gz
      ${rest}  ${bin_file_index}=  Split String From Right  ${bin_file_name}  separator=.  max_split=1
      tafssh.upload_file  local_path=${ttitrace_file}
    ...  remote_path=${tti_bins_dir}/${gz_file_name}  connection=${conn_alias}
      tafssh.Execute  command=cd ${tti_bins_dir} && tar -zxvf ${gz_file_name} && rm -f ${gz_file_name}
    ...  connection=${conn_alias}
      ${decode_cmd}  Catenate  cd ${ttiTrace_Dir}/tti-dec-bin;
    ...  python3 TtiTraceDecoder.py ${tti_bins_dir}/${bin_file_name} excelCsv -o ${decoded_csv}/tti_${bin_file_index}
      tafssh.execute  command=${decode_cmd}   connection=${conn_alias}
      ${dl_file_exists}=  tafssh.file exists   ${decoded_csv}/tti_${bin_file_index}_dl.csv   connection=${conn_alias}
      ${ul_file_exists}=  tafssh.file exists   ${decoded_csv}/tti_${bin_file_index}_ul.csv   connection=${conn_alias}
      run keyword if    "${dl_file_exists}"=="True"  tafssh.download file  remote_path=${decoded_csv}/tti_${bin_file_index}_dl.csv
    ...  local_path=${local_dl_csv}/tti_${bin_file_index}_dl.csv  connection=${conn_alias}
      run keyword if    "${ul_file_exists}"=="True"  tafssh.download_file  remote_path=${decoded_csv}/tti_${bin_file_index}_ul.csv
    ...  local_path=${local_ul_csv}/tti_${bin_file_index}_ul.csv  connection=${conn_alias}
    END
    [Return]  ${local_dl_csv}  ${local_ul_csv}


Get Dptrace Flag
    [Arguments]  ${container}  ${flag}  ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Get Dptrace Flag
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | container       | yes | container: l1hi, l2hi, l2rt |
    ...    | flag            | yes | flag: trace, dump-payload.  trace: 'Dptrace flag',  dump-payload:'Dptrace dump_palyload flag' |
    ...    | vdu_index       | no | vdu_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    disable or enable
    ...
    ...    Example
    ...   | ${value}    | Get Dptrace Flag | container=l1hi | flag=trace |
    ...   | ${value}    | Get Dptrace Flag | container=l2hi | flag=dump-payload |
    ...
    ${flag}  set variable  ${flag.lower()}
    ${actual_flag_name}  run keyword if  "${flag}"=="trace"   set variable  Dptrace flag
    ...   ELSE IF    "${flag}"=="dump-payload"     set variable  Dptrace dump_palyload flag
    ...   ELSE   Fail   Unknown flag name, it should be trace or dump-payload

    ${alias}  get unique id
    connect to k8s master with tenant interactively   vdu_index=${vdu_index}  alias=${alias}
    ${full_pod_name}   Get Full Pod Name By Pod Abbreviation Interactively  pod_abbr=up   vdu_index=${vdu_index}   alias=${alias}

    ${container}   Get Full Container Name By Container Abbreviation   ctr_abbr=${container}   vdu_index=${vdu_index}
    ${ns}  Get vDU Namespace From TestLine   vdu_index=${vdu_index}
    ${command}  set variable   bash -c "dptrace-cli show|grep -i '${actual_flag_name}'"

    ${out}  issh.Execute  command=kubectl exec -it ${full_pod_name} -c ${container} -n ${ns} -- ${command}|awk -F ":" '{print $2}'  alias=${alias}
    ${out}  strip prompt  ${out}

    [Return]  ${out}


Set Dptrace Flag
    [Arguments]  ${container}  ${flag}  ${value}   ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]    Set Dptrace Flag
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | container | yes | container: l1hi, l2hi, l2rt |
    ...    | flag   | yes | flag: trace, dump-payload.  trace: 'dptrace-cli trace ${value}',  dump-payload:'dptrace-cli dump-payload ${value}' |
    ...    | vdu_index | no | vdu_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    disable or enable
    ...
    ...    Example
    ...   | ${value}    | Set Dptrace Flag | container=l1hi | flag=trace        | value=disable |
    ...   | ${value}    | Set Dptrace Flag | container=l2hi | flag=dump-payload | value=enable |
    ...
    ${flag}  set variable  ${flag.lower()}
    run keyword if  "${flag}"!="trace" and "${flag}"!="dump-payload"
     ...   Fail   Unknown flag name, it should be trace or dump-payload

    ${alias}  get unique id
    connect to k8s master with tenant interactively   vdu_index=${vdu_index}  alias=${alias}

    ${command}  set variable  dptrace-cli ${flag} ${value}
    ${out}   Kubectl Exec Interactively   pod_abbr=up   container=${container}   command=${command}   alias=${alias}  vdu_index=${vdu_index}

    [Return]  ${out}


Enable Timing Tracing Via CLI
    [Arguments]  ${container}
    [Documentation]    Enable Timing Tracing Via CLI
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | container | yes | container: l1hi, l2hi, l2rt |
    ...    | vdu_index | no | vdu_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Enabled or KW fails
    ...
    ...    Example
    ...   | ${value}    | Enable Timing Tracing Via CLI | container=l1hi |
    ...
    ${flag_trace_value}  Get Dptrace Flag   container=${container}   flag=trace
    ${flag_dump-payload_value}  Get Dptrace Flag   container=${container}   flag=dump-payload

    return from keyword if   "${flag_trace_value}"=="enable" and "${flag_dump-payload_value}"=="enable"    Enabled

    ${out}  run keyword if  "${flag_trace_value}"=="disable"   Set Dptrace Flag   container=${container}   flag=trace   value=enable
    ${out}  run keyword if  "${flag_dump-payload_value}"=="disable"   Set Dptrace Flag   container=${container}   flag=dump-payload   value=enable

    ${flag_trace_value}  Get Dptrace Flag   container=${container}   flag=trace
    ${flag_dump-payload_value}  Get Dptrace Flag   container=${container}   flag=dump-payload

    should be true  "${flag_trace_value}"=="enable" and "${flag_dump-payload_value}"=="enable"

    [Return]  Enabled


Disable Timing Tracing Via CLI
    [Arguments]  ${container}
    [Documentation]    Disable Timing Tracing Via CLI
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | container | yes | container: l1hi, l2hi, l2rt |
    ...    | vdu_index | no | vdu_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Enabled or KW fails
    ...
    ...    Example
    ...   | ${value}    | Disable Timing Tracing Via CLI | container=l1hi |
    ...
    ${flag_trace_value}  Get Dptrace Flag   container=${container}   flag=trace
    ${flag_dump-payload_value}  Get Dptrace Flag   container=${container}   flag=dump-payload

    return from keyword if   "${flag_trace_value}"=="disable" and "${flag_dump-payload_value}"=="disable"    Disabled

    ${out}  run keyword if  "${flag_trace_value}"=="enable"   Set Dptrace Flag   container=${container}   flag=trace   value=disable
    ${out}  run keyword if  "${flag_dump-payload_value}"=="enable"   Set Dptrace Flag   container=${container}   flag=dump-payload   value=disable

    ${flag_trace_value}  Get Dptrace Flag   container=${container}   flag=trace
    ${flag_dump-payload_value}  Get Dptrace Flag   container=${container}   flag=dump-payload

    should be true  "${flag_trace_value}"=="disable" and "${flag_dump-payload_value}"=="disable"

    [Return]  Disabled


Get Current Timing Trace Log Size
    [Arguments]  ${container}    ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Get Current Timing Trace Log Size
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | container | yes | container: l1hi, l2hi, l2rt |
    ...    | vdu_index | no | vdu_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Enabled or KW fails
    ...
    ...    Example
    ...   | ${size}    | Get Current Timing Trace Log Size | container=l1hi |
    ...
    ${alias}  get unique id
    connect to k8s master with tenant interactively   vdu_index=${vdu_index}  alias=${alias}
    ${out}   Kubectl Exec Interactively  pod_abbr=up  container=${container}   check_result=${False}
     ...   command=ls -l /var/run/dptrace/dptrace-data     alias=${alias}
    return from keyword if  "No such file or directory" in """${out}"""    0
    ${size}  set variable  ${out.split()[4]}
    [Return]  ${size}


_Delete Core Dump Files
    [Teardown]    run keywords    run keyword and ignore error  disconnect interactive connection  alias=${alias}
    ...    AND    run keyword and ignore error  disconnect interactive connection  alias=${alias_root}
    [Documentation]   _Delete Core Dump Files
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | _Delete Core Dump Files |
    ...
    ${alias}  get unique id
    connect to k8s master interactively  alias=${alias}
    ${out}   issh.Execute   command=sudo find /tmp/cdump/ -name core.* -exec chmod 777 {} \\;   alias=${alias}  check_result=False
    ${out}   issh.Execute   command=sudo find /tmp/cdump/ -name core.* -exec rm -f {} \\;   alias=${alias}  check_result=False

    ${platform_name}   Get Platform Name
    return from keyword if   "${platform_name}"=="NCIR"

    ${alias_root}  get unique id
    Connect To K8s Master With root Interactively   alias=${alias_root}
    ${out}   issh.Execute  command=cat /proc/sys/kernel/core_pattern   alias=${alias_root}
    ${out}   issh.Execute  command=sudo echo "/var/core/core.%e.%p.%h.%t" > /proc/sys/kernel/core_pattern   alias=${alias_root}
    ${out}   issh.Execute  command=cat /proc/sys/kernel/core_pattern   alias=${alias_root}


_Check Core Dump Files And Download it And Fail The Case If It Has
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Teardown]   run keywords   run keyword and ignore error   issh.Set_Timeout   timeout=120   alias=${alias}
      ...   AND  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]    _Check Core Dump Files And Download it And Fail The Case If It Has
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no |  gnb_index  |
    ...    | vdu_index | no | vdu_index  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | _Check Core Dump Files And Download it And Fail The Case If It Has |
    ...
    log to console  _Check Core Dump Files And Download it And Fail The Case If It Has...
    ${alias}  get unique id
    connect to k8s master interactively  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${out}   issh.Execute   command=sudo find /tmp/cdump/ -name core.* -exec ls -l {} \\;|wc -l   alias=${alias}
    ${out}   strip prompt  ${out}
    ${number}   Parse Number Only From Content   ${out}
    return from keyword if  ${number}==0

    ${out}   issh.Execute   command=sudo find /tmp/cdump/ -name core.* -exec ls -l {} \\;   alias=${alias}
    log to console  ${out}

    ${out}   issh.Execute   command=sudo find /tmp/cdump/ -name core.* -exec chmod 777 {} \\;   alias=${alias}

    ${ns}   get vdu namespace from testline    gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${coredump_folder_name}   set variable   tmp_files_coredump_${ns}

    ${old}   issh.Set_Timeout  timeout=300   alias=${alias}

    ${out}   issh.Execute   command=sudo rm -rf /tmp/${coredump_folder_name}*    alias=${alias}
    ${out}   issh.Execute   command=sudo mkdir /tmp/${coredump_folder_name}      alias=${alias}
    ${out}   issh.Execute   command=cd /tmp/cdump    alias=${alias}
    ${out}   issh.Execute   command=sudo find . -regex .*core.* -exec cp -a --parents {} /tmp/${coredump_folder_name} \\;    alias=${alias}
    ${out}   issh.Execute   command=cd /tmp/${coredump_folder_name}    alias=${alias}
    #${out}   issh.Execute   command=nohup sudo tar -czf /tmp/${coredump_folder_name}.tgz . 2>&1 &   alias=${alias}
    ${tmp_id}   get unique id  prefix=${coredump_folder_name}   precise=LOW
    ${coredump_file_name}    set variable  ${tmp_id}.tgz
    ${out}   issh.Execute   command=nohup sudo tar -czf /tmp/${coredump_file_name} . 2>&1 &   alias=${alias}

    sleep  5
    wait until keyword succeeds  10800   30   Desired process should be stopped   process_keyword=${coredump_file_name}    alias=${alias}

    ${out}   issh.Execute   command=sudo chmod 777 /tmp/${coredump_file_name}    alias=${alias}
    ${local_file}   get a file     coredump   files_coredump_${gnb_index}_${vdu_index}_${coredump_file_name}
    ${out}   issh.download_file   remote_path=/tmp/${coredump_file_name}    local_path=${local_file}     alias=${alias}

    Fail  There is core dump files!


Desired process should be stopped
    [Arguments]  ${process_keyword}   ${alias}
    [Documentation]    Desired process should be stopped
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | process_keyword | yes |  process_keyword  |
    ...    | alias    | yes | alias  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Desired process should be stopped |
    ...
    ${out}  issh.execute  command=ps -ef|grep "${process_keyword}"|grep -v grep   check_result=${False}   alias=${alias}
    should not contain  ${out}   ${process_keyword}


Get Capture Log Flag
    [Documentation]   Get Capture Log Flag
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    1 or 0
    ...
    ...    Example
    ...    | ${flag} | Get Capture Log Flag |
    ...
    ${r}  ${out}  run keyword and ignore error   variable should exist  ${AIC_COMMON_TEST_SETUP_EXECUTED_FLAG}
    ${AIC_COMMON_TEST_SETUP_EXECUTED_FLAG}  set variable if  "${r}"=="PASS"   ${AIC_COMMON_TEST_SETUP_EXECUTED_FLAG}  0
    run keyword if   "${r}"!="PASS"  set test variable   ${AIC_COMMON_TEST_SETUP_EXECUTED_FLAG}
    return from keyword if   ${AICLOG}==1 and ${AIC_COMMON_TEST_SETUP_EXECUTED_FLAG}==1  1
    [Return]  0


Save Local Snapshot
    [Arguments]  ${local_snapshot_location}=snapshot
    [Documentation]    Save Local Snapshot
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | local_snapshot_location | No | local_snapshot_location  |
    ...
    ...    *RETURN VALUE*
    ...   path of local snapshot
    ...
    ...    Example
    ...    | Save Local Snapshot |
    ...
    log to console  Save Local Snapshot...
    VDU Rest Login
    ${mypath}   Get A Directory  ${local_snapshot_location}
    ${a}  vdu.Get_Local_Snapshot   ${mypath}
    [Return]  ${mypath}


Collect VDU Describe PODs Log
    [Arguments]  ${vdu_index}=0   ${gnb_index}=0
    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]   Collect VDU Describe PODs Log
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | vdu_index | no | vdu_index, default value is 0 |
    ...    | gnb_index | no | gnb_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Collect VDU Describe PODs Log |
    ...
    ${root_folder}   set variable   describe_vdu_pod
    ${alias}  get unique id
    Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}  alias=${alias}
    ${remote_file}  get a remote file   describe_vdu_pod.txt   alias=${alias}
    ${out}  issh.Execute   command=kubectl describe pods> ${remote_file}    alias=${alias}
    ${out}  issh.Execute   command=sync  alias=${alias}

    ${tmp_id}   get unique id  precise=FORMAT_DATETIME
    ${local_ute_file}  get a file   ${root_folder}   describe_vdu_pod_${gnb_index}_${vdu_index}_${tmp_id}.txt
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_ute_file}   alias=${alias}

    #get pod state -o wide
    ${remote_file}  get a remote file   vdu_get_pod_state_wide.txt   alias=${alias}
    ${out}  issh.Execute   command=kubectl get pod -o wide > ${remote_file}    alias=${alias}
    ${out}  issh.Execute   command=sync  alias=${alias}

    ${tmp_id}   get unique id  precise=FORMAT_DATETIME
    ${local_ute_file}  get a file   ${root_folder}   vdu_get_pod_state_wide_${gnb_index}_${vdu_index}_${tmp_id}.txt
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_ute_file}   alias=${alias}

    #get pod state -o yaml
    ${remote_file}  get a remote file   vdu_get_pod_state_yaml.txt   alias=${alias}
    ${out}  issh.Execute   command=kubectl get pod -o yaml > ${remote_file}    alias=${alias}
    ${out}  issh.Execute   command=sync  alias=${alias}

    ${tmp_id}   get unique id  precise=FORMAT_DATETIME
    ${local_ute_file}  get a file   ${root_folder}   vdu_get_pod_state_yaml_${gnb_index}_${vdu_index}_${tmp_id}.txt
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_ute_file}   alias=${alias}

    #get pod state -n kube-system -o wide
    ${remote_file}  get a remote file   vdu_get_pod_state_kube_system_wide.txt   alias=${alias}
    ${out}  issh.Execute   command=kubectl get pod -n kube-system -o wide > ${remote_file}    alias=${alias}
    ${out}  issh.Execute   command=sync  alias=${alias}

    ${tmp_id}   get unique id  precise=FORMAT_DATETIME
    ${local_ute_file}  get a file   ${root_folder}   vdu_get_pod_state_kube_system_wide_${gnb_index}_${vdu_index}_${tmp_id}.txt
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_ute_file}   alias=${alias}

    #get pod state -n kube-system -o yaml
    ${remote_file}  get a remote file   vdu_get_pod_state_kube_system_yaml.txt   alias=${alias}
    ${out}  issh.Execute   command=kubectl get pod -n kube-system -o yaml > ${remote_file}    alias=${alias}
    ${out}  issh.Execute   command=sync  alias=${alias}

    ${tmp_id}   get unique id  precise=FORMAT_DATETIME
    ${local_ute_file}  get a file   ${root_folder}   vdu_get_pod_state_kube_system_yaml_${gnb_index}_${vdu_index}_${tmp_id}.txt
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_ute_file}   alias=${alias}

    #get ep -o wide
    ${remote_file}  get a remote file   vdu_get_ep_wide.txt   alias=${alias}
    ${out}  issh.Execute   command= kubectl get ep -o wide > ${remote_file}    alias=${alias}
    ${out}  issh.Execute   command=sync  alias=${alias}

    ${tmp_id}   get unique id  precise=FORMAT_DATETIME
    ${local_ute_file}  get a file   ${root_folder}   vdu_get_ep_wide_${gnb_index}_${vdu_index}_${tmp_id}.txt
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_ute_file}   alias=${alias}

    #get ep -o yaml
    ${remote_file}  get a remote file   vdu_get_ep_yaml.txt   alias=${alias}
    ${out}  issh.Execute   command= kubectl get ep -o yaml > ${remote_file}    alias=${alias}
    ${out}  issh.Execute   command=sync  alias=${alias}

    ${tmp_id}   get unique id  precise=FORMAT_DATETIME
    ${local_ute_file}  get a file   ${root_folder}   vdu_get_ep_yaml_${gnb_index}_${vdu_index}_${tmp_id}.txt
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_ute_file}   alias=${alias}


Collect VDU Start Up Log
    [Documentation]   Collect VDU Start Up Log
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Collect VDU Start Up Log |
    ...
    log to console  Collect VDU Start Up Log
    ${count_of_gnbs}   get length  ${tl.gnbs}
    FOR  ${gnb_index}  IN RANGE  ${count_of_gnbs}
        Collect VDU Start Up Log For Specified GNB    ${gnb_index}
    END


Collect VDU Start Up Log For Specified GNB
    [Arguments]  ${gnb_index}=0
    [Documentation]   Collect VDU Start Up Log For Specified GNB
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Collect VDU Start Up Log For Specified GNB |
    ...
    ${count_of_vdu}  get length  ${tl.gnbs[${gnb_index}].dus}
    FOR  ${vdu_index}  IN RANGE  ${count_of_vdu}
        Collect VDU Start Up Log For Specified GNB For Specified VDU     gnb_index=${gnb_index}   vdu_index=${vdu_index}
    END


Collect VDU Start Up Log For Specified GNB For Specified VDU
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  run keywords   run keyword and ignore error  disconnect interactive connection   alias=${alias}
    ...   AND   run keyword and ignore error  disconnect interactive connection   alias=${alias_up}
    [Documentation]   Collect VDU Start Up Log For Specified GNB
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Collect VDU Start Up Log For Specified GNB |
    ...
    log to console  Collect VDU Start Up Log For Specified GNB For Specified VDU(gnb_index:${gnb_index},vdu_index:${vdu_index})
    ${ns}  get vdu namespace from testline

    ########################## oam pod #############
    ${pod_abbr}   set variable  oam
    ${container_list}   create list   oam   oamfh
    ${startup_log_path}  set variable  tmp
    #${startup_log_file}    set variable  startup_DEFAULT.log.xz
    #${startup_log_file}  Get Container File Name   container=oam  folder=/tmp  partial_file_name=startup_DEFAULT.
    ${startup_log_file}  Get Container File Name   container=${container_list[0]}  folder=/tmp  partial_file_name=startup_DEFAULT.

    ${alias}   Get Unique Id
    Connect To vDU Node Interactively   pod_abbr=${pod_abbr}   alias=${alias}
    ${tmp_folder_level_0}   get a remote directory   startup_log_${pod_abbr}   alias=${alias}
    ${full_pod_name}   get full pod name by pod abbreviation interactively   pod_abbr=${pod_abbr}   vdu_index=${vdu_index}   alias=${alias}
    FOR   ${container_abbr}   IN  @{container_list}
       ${tmp_log_file}   get a remote file   ${tmp_folder_level_0}  ${pod_abbr}   ${container_abbr}   ${startup_log_file}   alias=${alias}
       ${full_container_name}  get full container name by container abbreviation   ctr_abbr=${container_abbr}  vdu_index=${vdu_index}
       ${out}   issh.Execute
       ...   command=kubectl cp -n ${ns} ${full_pod_name}:${startup_log_path}/${startup_log_file} ${tmp_log_file} -c ${full_container_name}
       ...   alias=${alias}
    END

    ${out}  issh.Execute   command=cd ${tmp_folder_level_0}   alias=${alias}
    ${remote_file}   set variable  startup_log_${pod_abbr}.tgz

    ${out}  issh.Execute   command=ls -l   alias=${alias}
    ${out}  issh.Execute   command=tar -czf ${remote_file} *   alias=${alias}
    ${out}  issh.Execute   command=chmod 777 ${remote_file}   alias=${alias}
    ${remote_path}  OperatingSystem.Join Path  ${tmp_folder_level_0}   ${remote_file}
    ${local_file}   get a file     starup_log_${pod_abbr}   startup_log_${pod_abbr}_${gnb_index}_${vdu_index}.tgz
    ${out}   issh.download_file   remote_path=${remote_path}    local_path=${local_file}     alias=${alias}
    run keyword and ignore error  disconnect interactive connection   alias=${alias}

    ########################## cprt pod #############
    ${pod_abbr}   set variable  cprt
    ${container_list}   create list   cprt
    ${startup_log_path}  set variable  tmp
    #${startup_log_file}    set variable  startup_DEFAULT.log.xz
    #${startup_log_file}  Get Container File Name   container=oam  folder=/tmp  partial_file_name=startup_DEFAULT.
    ${startup_log_file}  Get Container File Name   container=${container_list[0]}  folder=/tmp  partial_file_name=startup_DEFAULT.

    ${alias}   Get Unique Id
    Connect To vDU Node Interactively   pod_abbr=${pod_abbr}   alias=${alias}
    ${tmp_folder_level_0}   get a remote directory   startup_log_${pod_abbr}   alias=${alias}
    ${full_pod_name}   get full pod name by pod abbreviation interactively   pod_abbr=${pod_abbr}   vdu_index=${vdu_index}   alias=${alias}
    FOR   ${container_abbr}   IN  @{container_list}
       ${tmp_log_file}   get a remote file   ${tmp_folder_level_0}  ${pod_abbr}   ${container_abbr}   ${startup_log_file}   alias=${alias}
       ${full_container_name}  get full container name by container abbreviation   ctr_abbr=${container_abbr}  vdu_index=${vdu_index}
       ${out}   issh.Execute
       ...   command=kubectl cp -n ${ns} ${full_pod_name}:${startup_log_path}/${startup_log_file} ${tmp_log_file} -c ${full_container_name}
       ...   alias=${alias}
    END

    ${out}  issh.Execute   command=cd ${tmp_folder_level_0}   alias=${alias}
    ${remote_file}   set variable  startup_log_${pod_abbr}.tgz

    ${out}  issh.Execute   command=ls -l   alias=${alias}
    ${out}  issh.Execute   command=tar -czf ${remote_file} *   alias=${alias}
    ${out}  issh.Execute   command=chmod 777 ${remote_file}   alias=${alias}
    ${remote_path}  OperatingSystem.Join Path  ${tmp_folder_level_0}   ${remote_file}
    ${local_file}   get a file     starup_log_${pod_abbr}   startup_log_${pod_abbr}_${gnb_index}_${vdu_index}.tgz
    ${out}   issh.download_file   remote_path=${remote_path}    local_path=${local_file}     alias=${alias}
    run keyword and ignore error  disconnect interactive connection   alias=${alias}

    ########################## up #############
    ${pod_abbr}   set variable  up
    ${container_list}   create list   l2hi   l1hi   l2rt
    ${startup_log_path}  set variable  tmp
    #${startup_log_file}    set variable  LINUX_startup.zip
    #${startup_log_file}  Get Container File Name   container=l1hi  folder=/tmp  partial_file_name=LINUX_startup.
    ${startup_log_file}  Get Container File Name   container=${container_list[0]}  folder=/tmp  partial_file_name=LINUX_startup.

    ${alias}   Get Unique Id
    Connect To vDU Node Interactively   pod_abbr=${pod_abbr}   alias=${alias}
    ${tmp_folder_level_0}   get a remote directory   startup_log_${pod_abbr}   alias=${alias}
    ${full_pod_name}   get full pod name by pod abbreviation interactively   pod_abbr=${pod_abbr}   vdu_index=${vdu_index}   alias=${alias}
    FOR   ${container_abbr}   IN  @{container_list}
       ${tmp_log_file}   get a remote file   ${tmp_folder_level_0}  ${pod_abbr}   ${container_abbr}   ${startup_log_file}   alias=${alias}
       ${full_container_name}  get full container name by container abbreviation   ctr_abbr=${container_abbr}  vdu_index=${vdu_index}
       ${out}   issh.Execute
       ...   command=kubectl cp -n ${ns} ${full_pod_name}:${startup_log_path}/${startup_log_file} ${tmp_log_file} -c ${full_container_name}
       ...   alias=${alias}
    END

    ${out}  issh.Execute   command=cd ${tmp_folder_level_0}   alias=${alias}
    ${remote_file}   set variable  startup_log_${pod_abbr}.tgz

    ${out}  issh.Execute   command=ls -l   alias=${alias}
    ${out}  issh.Execute   command=tar -czf ${remote_file} *   alias=${alias}
    ${out}  issh.Execute   command=chmod 777 ${remote_file}   alias=${alias}
    ${remote_path}  OperatingSystem.Join Path  ${tmp_folder_level_0}   ${remote_file}
    ${local_file}   get a file     starup_log_${pod_abbr}   startup_log_${pod_abbr}_${gnb_index}_${vdu_index}.tgz
    ${out}   issh.download_file   remote_path=${remote_path}    local_path=${local_file}     alias=${alias}
    run keyword and ignore error  disconnect interactive connection   alias=${alias}


Collect VDU Infrastructure Log
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection   alias=${alias}
    [Documentation]   Collect VDU Infrastructure Log
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Collect VDU Start Up Log For Specified GNB |
    ...
    log to console   Collect VDU Infrastructure Log(gnb_index:${gnb_index},vdu_index:${vdu_index})
    ${ns}  set variable  kube-system
    ${log_root_folder}   set variable   vdu_infrastructure_log

    ${alias}   Get Unique Id
    connect to k8s master interactively   alias=${alias}

    #kube dns
    ${remote_file}   get a remote file  ${log_root_folder}   kube_dns.log    alias=${alias}
    ${out}   issh.Execute   command=kubectl get pod -n ${ns}|egrep "kube-dns"|awk '{print $1}'  check_result=${False}  alias=${alias}
    ${dns_pod}   strip prompt  ${out}
    ${out}  issh.Execute  command=kubectl logs ${dns_pod} -c kubedns -n ${ns}>${remote_file}   alias=${alias}

    ${out}  strip prompt  ${out}
    ${pid}  parse number only from content  ${out}
    Wait Until Process Disappear   pid=${pid}   alias=${alias}

    ${out}  issh.Execute  command=sync  alias=${alias}
    ${tmp_id}   get unique id   precise=FORMAT_DATETIME
    ${local_file}   get a file   ${log_root_folder}   kube_dns_container_log_${gnb_index}_${vdu_index}_${tmp_id}.log
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_file}   alias=${alias}

    #desribe kube-dns pod
    ${remote_file}  get a remote file   ${log_root_folder}   kubesystem_kubedns.txt   alias=${alias}
    ${out}  issh.Execute   command=kubectl describe pod ${dns_pod} -n ${ns} > ${remote_file}    alias=${alias}
    ${out}  issh.Execute   command=sync  alias=${alias}

    ${tmp_id}   get unique id  precise=FORMAT_DATETIME
    ${local_file}  get a file   ${log_root_folder}   kube_dns_describe_pod_${gnb_index}_${vdu_index}_${tmp_id}.txt
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_file}   alias=${alias}

    #check dns in container
    ${out}  Kubectl Exec Interactively  container=oam  command=ping oam-asm -c 3   check_result=False  alias=${alias}
    ${out}  Kubectl Exec Interactively  container=oam  command=cat /etc/resolv.conf  check_result=False   alias=${alias}


Get Logservice POD Ip
    [Arguments]  ${vdu_index}=0   ${gnb_index}=0
    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]   Get Logservice POD Ip
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | vdu_index | no | vdu_index, default value is 0 |
    ...    | gnb_index | no | gnb_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    logservice_pod_ip
    ...
    ...    Example
    ...   | Get Logservice POD Ip |
    ...
    ${alias}  get unique id
    Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}   gnb_index=${gnb_index}  alias=${alias}

    ${out}  issh.Execute   command=kubectl get pod -o wide |grep logservice |awk '{print $6}'   alias=${alias}
    ${logservice_pod_ip}  strip prompt  ${out}

    [Return]  ${logservice_pod_ip}


Get VDU POD Syslog
    [Arguments]  ${vdu_index}=0   ${gnb_index}=0
    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]   Get VDU POD Syslog
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | vdu_index | no | vdu_index, default value is 0 |
    ...    | gnb_index | no | gnb_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    file path of syslog
    ...
    ...    Example
    ...   | Get VDU POD Syslog |
    ...
    ${logservice_pod_ip}   Get Logservice POD Ip  vdu_index=${vdu_index}   gnb_index=${gnb_index}

    ${alias}  get unique id
    Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}   gnb_index=${gnb_index}  alias=${alias}

    ${remote_file}   get a remote file  pod_syslog   syslog.zip    alias=${alias}
    ${cmd}  set variable  nohup curl -iX GET http://${logservice_pod_ip}:8081/log_data -o ${remote_file} &
    ${out}  issh.Execute  command=${cmd}   alias=${alias}
    ${out}  issh.Execute  command=echo $!   alias=${alias}
    ${out}  strip prompt  ${out}
    ${pid}  parse number only from content  ${out}
    Wait Until Process Disappear   pid=${pid}   alias=${alias}

    ${out}  issh.Execute  command=sync  alias=${alias}
    ${tmp_id}   get unique id   precise=FORMAT_DATETIME
    ${local_ute_file}   get a file   pod_syslog   syslog_${gnb_index}_${vdu_index}_${tmp_id}.zip
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_ute_file}   alias=${alias}
    [Return]  ${local_ute_file}

Start To Storage New Syslog
    [Arguments]    ${vdu_index}=${0}
    [Documentation]  Login to logstorageserver, backup the syslog, and new a syslog
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <18-Mar-2021>, <lingtsun>, <Initial creation>
    ...    modified by:  14.04.2021, sophie.jiang@nokia-sbell.com, debug pass
    ...    | Input Parameters | Man. | Description |
    ...    |  vdu_index        | No    |  the index of vdu,  ${0} in default   |
    ...    |  backup_file      | No    |  backup file name, default is syslog  |
    ...    RETURN VALUE
    ...    None
    ...    Example
    ...    | Start To Storage New Syslog |  ${0}  |  syslog  |
    vDU Cluster Login With Tenant     vdu_index=${vdu_index}
    ${log_pod_name} =    Get Full Pod Name By Pod Abbreviation      pod_abbr=logservice    vdu_index=${vdu_index}
    set test variable    ${log_pod_name}
    FOR  ${container}  IN  @{AIC_VDU_PODS['logservice']}
       run keyword if    'logstorageserver' in '${container}'   set test variable   ${log_container}   ${container}
    END
    set test variable    ${log_container}
    ${status}=  run keyword and return status  Get Container Name Prefix
    run keyword if  ${status}==True  set test variable  ${log_container}  ctr-cran1-logstorageserver
    run keyword if  ${status}==False  set test variable  ${log_container}  logstorageserver
    Connect To vDU Container    ${log_pod_name}    ${log_container}   vdu_index=${vdu_index}
    Execute Command In Container    cd /var/log/syslog
    ${output} =    Execute Command In Container    ls -al
    Execute Command In Container    rm -rf syslog.*
    Execute Command In Container    > syslog
    ${output} =    Execute Command In Container    ls -al
    [teardown]    Exit From Container

Download Syslog From LogStorageServer
    [Arguments]    ${container_name}=logstorageserver
    ...            ${file_path}=/var/log/syslog/    ${vdu_index}=${0}
    [Documentation]  Downloas syslog from logstorage server to local
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <18-Mar-2021>, <lingtsun>, <Initial creation>
    ...    modified by:  14.04.2021, sophie.jiang@nokia-sbell.com, debug pass
    ...    | Input Parameters | Man. | Description |
    ...    |  pod_name         | No   |  the full name of up |
    ...    |  container_name   | No   |  the full name of l2rt |
     ...   |  file_path        | No   |  the full name of up |
    ...    |  file_name   | No   |  the full name of l2rt |
    ...    |  vdu_index        | No   |  the index of vdu,  ${0} in default |
    ...    RETURN VALUE
    ...    syslog path in ute
    ...    Example
    ...    |  Download Syslog From LogStorageServer |  logservice  |  ${0}  |

    Log To Console     connect to logstorageserver
    tafssh.Reset Cache
    Connect To K8s Master  ${vdu_index}  alias=Master
    ${container_id} =     Get vDU Container ID     ${container_name}     Master
    tafssh.Execute    command=rm -rf /home/cloudadmin/syslog_CIT    connection=Master
    tafssh.Execute    command=sudo docker cp ${container_id}:${file_path} /home/cloudadmin/syslog_CIT   connection=Master   timeout=100
    tafssh.Execute    command=sudo chmod 777 -R /home/cloudadmin/syslog_CIT   connection=Master
    ${syslog_file_info}=  tafssh.Execute  command=ls /home/cloudadmin/syslog_CIT/*    connection=Master
    ${syslog_file_info}=  replace string  ${syslog_file_info}  \r\n  ${EMPTY}
    Log To Console    ${syslog_file_info}
    ${local_log_file_dir} =    Get A Directory    storage_syslog
    Log To Console    ${local_log_file_dir}
    @{syslog_list}    split string    ${syslog_file_info}  ${EMPTY}
    Log To Console  @{syslog_list}
    tafssh.Download File     remote_path=@{syslog_list}
        ...        local_path=${local_log_file_dir}    connection=Master
    tafssh.Reset Cache
    [return]     ${local_log_file_dir}


Download Luashark For VDU And Return Path
    [Arguments]    ${path}=${LUA_SCRIPT_PATH}
    [Documentation]  Download luashark script form artifactory and extract to /home/ute/lua_script/
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <22-Jun-2021>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  path       | No   |  extract dir of lua script, default is the global param ${LUA_SCRIPT_PATH} |
    ...    RETURN VALUE
    ...    the path of luashark.lua
    ...    Example
    ...    |  Download Luashark For VDU And Return Path |
    _Renew luashark
    ${vdu_release}=   Get Running Build Number
    _Download luashark from Artifactory    ${vdu_release}
    ${luashark_path}    _Extract Luashark    ${vdu_release}   ${path}
    ${cmd}    Catenate     SEPARATOR=    rm -rf luashark-    ${vdu_release}   .zip
    Run And Expect Command To Pass    command=${cmd}  msg=remove
    [Return]    ${luashark_path}

_Download luashark from Artifactory
    [Arguments]   ${vdu_release}
    ${wget_command}    Catenate     SEPARATOR=    wget    ${SPACE}    ${LUA_SCRIPT_LINK}   ${vdu_release}
    ...     /luashark-    ${vdu_release}   .zip
    Run And Expect Command To Pass    command=${wget_command}   msg=Download of Luashark from Artifactory for ${vdu_release}

_Extract Luashark
    [Arguments]   ${vdu_release}    ${path_to_extract}
    ${unzip_luashark_command}    Catenate    SEPARATOR=    unzip luashark-    ${vdu_release}    .zip -d ${path_to_extract}
    Run And Expect Command To Pass    command=${unzip_luashark_command}   msg=Extract of Luashark Zip for ${vdu_release}
    ${luashark_path}    Catenate    SEPARATOR=    ${path_to_extract}    /generated_luashark/luashark.lua
    [Return]    ${luashark_path}

_Renew luashark
    log   ${LUA_SCRIPT_PATH}
    RUN   rm -rf ${LUA_SCRIPT_PATH}
    Run   mkdir ${LUA_SCRIPT_PATH}


Run And Expect Command To Pass
    [Arguments]    ${command}    ${msg}=
    [Documentation]    This keyword is used to run a command and get its output.
    ...                Keyword will fail if the returncode is other than zero(0)
    ${rc}    ${output}    Run and return rc and output    ${command}
    Should Be Equal As Integers   ${rc}    0    msg=${msg} failed execution with error code ${rc} ${output}   values=False
    [Return]    ${output}


Convert DCAP log to txt
    [Arguments]   ${log_file_path}    ${lua_shark_script_path}     ${convert_file_path}    ${decode_as}=${None}
    ...    ${protocol}=${None}
    [Documentation]  DConvert pcap to txt with cmd tshark -X -d -O
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <22-Jun-2021>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  log_file_path           | Yes   | pcap log path                                    |
    ...    |  lua_shark_script_path   | Yes   | luashark.lua path in ute                         |
    ...    |  convert_file_path       | Yes   | the converted file path                          |
    ...    |  decode_as               | No    | default is ${None}, example: udp.port==55900,swe |
    ...    |  protocol                | No    | default is ${None}, example: swe                 |
    ...    RETURN VALUE
    ...    the path of converted path
    ...    Example
    ...    ${lua_shark_path}    set variable    /home/ute/lua_script/generated_luashark/luashark.lua
    ...    ${log_file_path}    set variable    /home/ute/SLT/test.pcap
    ...    ${decode_as}    set variable    udp.port==55900,swe
    ...    ${convert_file_path}    set variable    /home/ute/SLT/test_slt.txt
    ...    ${convert_file_path_2}    set variable    /home/ute/SLT/test_slt_2.txt
    ...    ${protocol}     set variable    swe
    ...    Convert DCAP log to txt    log_file_path=${log_file_path}    lua_shark_script_path=${lua_shark_path}
    ...    decode_as=${decode_as}    convert_file_path=${convert_file_path}    protocol=${protocol}
    ${convert_cmd}=   Run Keyword If    '${decode_as}'=='${None}' and '${protocol}'=='${None}'
    ...    Catenate    SEPARATOR=    ${TSHARK_PATH} -X lua_script:${lua_shark_script_path} -r
    ...    ${log_file_path} >${convert_file_path}
    ...    ELSE IF    '${decode_as}'!='${None}' and '${protocol}'=='${None}'
    ...    Catenate    SEPARATOR=    ${TSHARK_PATH} -X lua_script:${lua_shark_script_path} -r
    ...    ${log_file_path} -d ${decode_as} >${convert_file_path}
    ...    ELSE IF    '${decode_as}'!='${None}' and '${protocol}'!='${None}'
    ...    Catenate    SEPARATOR=    ${TSHARK_PATH} -X lua_script:${lua_shark_script_path} -r
    ...    ${log_file_path} -d ${decode_as} -O ${protocol} >${convert_file_path}
    #log    ${convert_cmd}
    Run And Expect Command To Pass    command=${convert_cmd}    msg=convert pcap to txt
    [Return]    ${convert_file_path}
############################## vDU LOG End ##############################
====== VDU LOG End ======
     Log To Console  \n*** only used for readable **

############################## FHGW LOG Start ##############################
====== FHGW LOG Start ======
     Log To Console  \n*** only used for readable ***

############################## FHGW LOG End ##############################
====== FHGW LOG End ======
     Log To Console  \n*** only used for readable **

