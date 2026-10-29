*** Settings ***
Documentation     Keywords For Wireshark collection and parsing

Library      DateTime
Library      Collections
Library      taf.collectors.tcpdump    WITH NAME    tcpdump
Library      taf.collectors.core       WITH NAME    core
Library      taf/rfrl/utilities/parsers/check_cap.py
Library      check_cap.CapPacket    WITH NAME    cap
Library      taf.transport.ssh    WITH NAME    ssh_conn
Library      String

Resource     ./DevNJ_oam_resource.robot

*** Variables ***
${ASIK_IP_LMP}				${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_username}			${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_password}			${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

*** Keywords ***
Start Tcpdump On gNB
    [Documentation]  Start tcpdump on gNB
	...
	...  Arguments:
	...
    ...  - _options_: tcpdump options except ``-w``. Default is ``-i fp0``
    ...  - _collector_: name of collector. Default is ``gnb-tcpdump``
    ...
    ...  Example:
	...  | ${file} | Start Tcpdump On gNB | options=-i br1.30 |
    ...
	...  Return value:
	...  - Raw packets file with full path on local UTE VM
    [Arguments]   ${options}=-i fp0   ${collector}=gnb-tcpdump
    ${time}    DateTime.Get Current Date    result_format=timestamp
    ${time_stamp}    DateTime.Convert Date    ${time}    epoch
    ${time_stamp}    evaluate    int(${time_stamp})
    ${executor_oam_vm}=  Create Dictionary
    ...  host=${ASIK_IP_LMP}
    ...  user=${ASIK_username}
    ...  password=${ASIK_password}
    tcpdump.create_tcpdump_collector
    ...     name=${collector}
    ...     options=${options}
    ...     target_file_name=${collector}_${time_stamp}.pcap
    ...     executor=${executor_oam_vm}
    core.setup_collectors    names=${collector}
    core.start_collectors    names=${collector}
    tcpdump.set_suite_alias     ${collector}
    [RETURN]   ${OUTPUT_DIR}/${collector}/${collector}_${time_stamp}.pcap


Start Tcpdump On UTE
    [Documentation]  Start tcpdump on UTE platform
	...
	...  Arguments:
	...
    ...  - _options_: tcpdump options except ``-w``. Default is ``-i any``
    ...  - _collector_: name of collector. Default is ``ute-tcpdump``
    ...
    ...  Example:
    ...  | ${file} | Start Tcpdump On UTE |
	...  | ${file} | Start Tcpdump On UTE | options=-i eth0 |
	...  | ${file} | Start Tcpdump On UTE | options=-i eth0 tcp |
    ...
	...  Return value:
	...  - Raw packets file with full path
    [Arguments]   ${options}=-i any   ${collector}=ute-tcpdump
    ${time}    DateTime.Get Current Date    result_format=timestamp
    ${time_stamp}    DateTime.Convert Date    ${time}    epoch
    ${time_stamp}    evaluate    int(${time_stamp})
    tcpdump.create_tcpdump_collector
    ...     name=${collector}
    ...     options=${options}
    ...     target_file_name=${collector}_${time_stamp}.pcap
    core.setup_collectors    names=${collector}
    core.start_collectors    names=${collector}
    tcpdump.set_suite_alias     ${collector}
    [RETURN]  ${OUTPUT_DIR}/${collector}/${collector}_${time_stamp}.pcap


Stop Tcpdump On gNB
    [Documentation]  Stop tcpdump on gNB and generate raw packets file to local UTE VM
	...
	...  Arguments:
    ...  - _collector_: name of collector. Default is ``gnb-tcpdump``
    ...
    ...  Example:
    ...  | Stop Tcpdump On gNB |
    ...
	...  Return value:
	...  - Raw packets file with full path on local UTE VM
    [Arguments]  ${collector}=gnb-tcpdump
    core.stop_collectors    names=${collector}
    core.collect_collectors    names=${collector}    target_dir=${OUTPUT_DIR}/
    core.teardown_collectors    names=${collector}


Stop Tcpdump On UTE
    [Documentation]  Stop tcpdump on UTE and generate raw packets file
	...
	...  Arguments:
    ...  - _collector_: name of collector. Default is ``ute-tcpdump``
    ...
    ...  Example:
    ...  | Stop Tcpdump On UTE |
    ...
	...  Return value:
	...  - None
    [Arguments]  ${collector}=ute-tcpdump
    core.stop_collectors    names=${collector}
    core.collect_collectors    names=${collector}   target_dir=${OUTPUT_DIR}/
    core.teardown_collectors    names=${collector}


Check Pcap Should Have
    [Documentation]  Expect that the captured pcap file SHOULD contain the packets that match the filter expression
    ...
    ...    Arguments:
    ...    - _pcap_file_: pcap filename with full path
    ...    - _filters_: filter expressions to be checked
    ...
    ...    Examples:
    ...    | Check Pcap Should Have | test.pcap | http |
    ...    | Check Pcap Should Have | test.pcap | ip.dst==192.168.101.8 |
    ...
    [Arguments]    ${pcap_file}  ${filters}
    cap.read_cap    cap_file=${pcap_file}
    ${status}    ${value} =  Run Keyword And Ignore Error   cap.Check Expression    ${filters}
    Should Be Equal    '${status}'    'PASS'


Check Pcap Should Not Have
    [Documentation]  Expect that the captured pcap file SHOULD NOT contain the packets that match the filter expression
    ...
    ...    Arguments:
    ...    - _pcap_file_: pcap filename with full path
    ...    - _filters_: filter expressions to be checked
    ...
    ...    Examples:
	...    | ${filters} | snmp.version == 0 or snmp.version == 1 |
    ...    | Check Pcap Should Not Have | test.pcap | ${filters} |
    ...
    [Arguments]    ${pcap_file}  ${filters}
    cap.read_cap    cap_file=${pcap_file}
    ${status}    ${value} =  Run Keyword And Ignore Error   cap.Check Expression    ${filters}
    Should Not Be Equal    '${status}'    'PASS'


Check Count Of Specific Packet
    [Documentation]    Check count of packet specified by filter in captured pcap
	...
	...     Arguments:
	...
    ...     - _pcap_file_: pcap file name with full path
    ...     - _filters_: filter expressions to be checked
    ...     - _count_: expected count
    ...
    ...     Example:
    ...     | Check Count Of Specific Packet | ${CURDIR}/pcap/attach.pcap | ${filters} | ${count} |
    ...
    [Arguments]   ${pcap_file}   ${filters}   ${count}
    cap.read_cap    cap_file=${pcap_file}
    ${status}   ${value} =  Run Keyword And Ignore Error   cap.Check Expression    ${filters}
    ${length} =     Get Length	  ${value}
    Should Be Equal As Numbers    ${length}   ${count}


_Capturing CPRI Interface Traffic From Hub To Gnb
    [Documentation]    Private keyword. It launches tcpdump on specified interfaces of sHUB.

    [Arguments]  ${hub_vm_login_info}  ${hub_login_info}  ${index}
    ssh_conn.connect to  ${hub_vm_login_info.host}  username=${hub_vm_login_info.username}
    ...                                             password=${hub_vm_login_info.password}
    ...                                             alias=HUB_VM_CONN_${index}

    ssh_conn.connect to  ${hub_login_info.host}     username=${hub_login_info.username}
    ...                                             password=${hub_login_info.password}
    ...                                             proxy=HUB_VM_CONN_${index}
    ...                                             alias=HUB_CONN_${index}

    ssh_conn.send command    command=mkdir /tmp/sHUB  connection=HUB_CONN_${index}

    ssh_conn.send command    command=tcpdump -i sw0 -w /tmp/sHUB/sw0.pcap &>/dev/null &  connection=HUB_CONN_${index}
    ssh_conn.send command    command=tcpdump -i bbu1 -w /tmp/sHUB/bbu1.pcap &>/dev/null &  connection=HUB_CONN_${index}
    ssh_conn.send command    command=ip netns exec bbu1ns tcpdump -i bbu1v -w /tmp/sHUB/bbu1v.pcap &>/dev/null &  connection=HUB_CONN_${index}

    Log To Console    Launched tcpdump on sw0, bbu1 and bbu1v interfaces

    ${bbu3v_itf}    ssh_conn.execute    command=ip netns exec bbu3ns ifconfig bbu3v    connection=HUB_CONN_${index}
    ${status}    ${value}    Run Keyword and Ignore Error    Should Match Regexp   ${bbu3v_itf}    inet addr:(\\d+.\\d+.\\d+.\\d+)
    Return From Keyword If    '${status}'=='FAIL'

    ssh_conn.send command    command=ip netns exec bbu3ns tcpdump -i bbu3v -w /tmp/sHUB/bb3v.pcap &>/dev/null &  connection=HUB_CONN_${index}
    ssh_conn.send command    command=tcpdump -i bbu3 -w /tmp/sHUB/bbu3.pcap &>/dev/null &  connection=HUB_CONN_${index}

    Log To Console    Launched tcpdump on bbu3v and bbu3 interfaces

    [Teardown]  Run Keywords
    ...         Run Keyword And Continue On Failure    ssh_conn.disconnect  connection=HUB_CONN_${index}           AND
    ...         Run Keyword And Continue On Failure    ssh_conn.disconnect  connection=HUB_VM_CONN_${index}


Start Capturing CPRI Interface Traffic From Hub To Gnb
    [Documentation]    Launch tcpdump on each sHUB to capture traffic from sHUB to GNB on interfaces sw0, bbu1, bbu1v and
    ...                bbu3v&bbu3 if possible. Captured pcap files are saved under /tmp/sHUB directory of sHUB. Normally
    ...                this keword is called by [Setup] section of each test.
    ...
    ...     Arguments: None
    ...
    ...     Example:
    ...     | Start Capturing CPRI Interface Traffic From Hub To Gnb |
    ...
    ${num_of_hubs}  Get Length  ${tl.gnbs[0].dus[0].rus}
    Log To Console    Number of sHUB is : ${num_of_hubs}

    FOR  ${index}  IN RANGE  ${num_of_hubs}
        &{hub_vm_login_info}  Create Dictionary
        ...                       host=${tl.gnbs[0].dus[0].rus[${index}].sc_radio_connection_details.ssh.proxy.addr}
        ...                       username=${tl.gnbs[0].dus[0].rus[${index}].sc_radio_connection_details.ssh.proxy.username}
        ...                       password=${tl.gnbs[0].dus[0].rus[${index}].sc_radio_connection_details.ssh.proxy.password}

        &{hub_login_info}  Create Dictionary
        ...                       host=${tl.gnbs[0].dus[0].rus[${index}].sc_radio_connection_details.ssh.addr}
        ...                       username=${tl.gnbs[0].dus[0].rus[${index}].sc_radio_connection_details.ssh.username}
        ...                       password=${tl.gnbs[0].dus[0].rus[${index}].sc_radio_connection_details.ssh.password}

        _Capturing CPRI Interface Traffic From Hub To Gnb  ${hub_vm_login_info}  ${hub_login_info}  ${index}
    END


_Collecting CPRI Interface Traffic From Hub To Gnb
    [Documentation]    Private keyword. It performs tcpdump process cleanup, download pcap files to local UTE and
    ...                remove the pcap files from sHUB.

    [Arguments]  ${hub_vm_login_info}  ${hub_login_info}  ${index}

    ssh_conn.connect to  ${hub_vm_login_info.host}  username=${hub_vm_login_info.username}
    ...                                             password=${hub_vm_login_info.password}
    ...                                             alias=HUB_VM_CONN_${index}

    ssh_conn.connect to  ${hub_login_info.host}     username=${hub_login_info.username}
    ...                                             password=${hub_login_info.password}
    ...                                             proxy=HUB_VM_CONN_${index}
    ...                                             alias=HUB_CONN_${index}

    ${pids}  ssh_conn.execute   command=ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'  connection=HUB_CONN_${index}
    @{pid_list}  String.split string  ${pids}

    FOR  ${PID}  IN  @{pid_list}
        Log To Console    Killing process : ${PID}
        ssh_conn.execute   command=kill -2 ${PID.replace('\r\n','')}   connection=HUB_CONN_${index}
    END

    ${file_list}    ssh_conn.execute    command=ls /tmp/sHUB    connection=HUB_CONN_${index}
    Return From Keyword If    "No such file or directory" in """${file_list}"""

    @{pcap_file}    String.split string    ${file_list}
    Log To Console  Files to be downloaded : ${file_list}

    ${result}    Get Variable Value    ${TEST_LOG_DIR}
    ${PCAP_LOG_DIR}    Set Variable If    "${result}" != 'None'    ${result}/sHUB_${index}
    ...                                                            ${OUTPUT_DIR}/${SUITE NAME}/${TEST NAME}/sHUB_${index}
    OperatingSystem.Create Directory    ${PCAP_LOG_DIR}

    FOR  ${file}  IN  @{pcap_file}
        Log To Console    Start downloading file ${file} to local
        ssh_conn.download_file   local_path=${PCAP_LOG_DIR}/${file}   remote_path=/tmp/sHUB/${file}   connection=HUB_CONN_${index}
        Log To Console    Download file ${file} to local completed
    END

    [Teardown]  Run Keywords
    ...  Run Keyword And Continue On Failure  ssh_conn.execute   command=rm -rf /tmp/sHUB  connection=HUB_CONN_${index}    AND
    ...  Run Keyword And Continue On Failure  ssh_conn.disconnect  connection=HUB_CONN_${index}                            AND
    ...  Run Keyword And Continue On Failure  ssh_conn.disconnect  connection=HUB_VM_CONN_${index}


Stop Capturing CPRI Interface Traffic From Hub To Gnb
    [Documentation]    Stop tcpdump on each sHUB and downloading pcap files to local UTE. Target directory is under
    ...                ${OUTPUTDIR}/${SUITE NAME}/${TEST NAME}/sHUB_${index}. Normally this keyword is called in
    ...                [Teardown] section of each test.
    ...
    ...                ${OUTPUTDIR} is normally specified by --outputdir option
    ...                ${SUITE NAME} is test suite name
    ...                ${TEST NAME} is test case name
    ...                ${index} is sHUB index defined in testline configuration (__init__.py)
    ...
    ...     Arguments: None
    ...
    ...     Example:
    ...     | Stop Capturing CPRI Interface Traffic From Hub To Gnb |
    ...
    ${num_of_hubs}  Get Length  ${tl.gnbs[0].dus[0].rus}
    Log To Console    Number of sHUB is : ${num_of_hubs}

    FOR  ${index}  IN RANGE  ${num_of_hubs}
        &{hub_vm_login_info}  Create Dictionary
        ...                       host=${tl.gnbs[0].dus[0].rus[${index}].sc_radio_connection_details.ssh.proxy.addr}
        ...                       username=${tl.gnbs[0].dus[0].rus[${index}].sc_radio_connection_details.ssh.proxy.username}
        ...                       password=${tl.gnbs[0].dus[0].rus[${index}].sc_radio_connection_details.ssh.proxy.password}

        &{hub_login_info}  Create Dictionary
        ...                       host=${tl.gnbs[0].dus[0].rus[${index}].sc_radio_connection_details.ssh.addr}
        ...                       username=${tl.gnbs[0].dus[0].rus[${index}].sc_radio_connection_details.ssh.username}
        ...                       password=${tl.gnbs[0].dus[0].rus[${index}].sc_radio_connection_details.ssh.password}

        _Collecting CPRI Interface Traffic From Hub To Gnb  ${hub_vm_login_info}  ${hub_login_info}  ${index}
    END


Start Capturing CPRI Interface Traffic From Gnb To HuB
    [Documentation]    Start capturing CPRI link traffic between GNB and HUB. Invoke this keyword in [Setup] section of test case
    ...
    ...     Arguments: None
    ...
    ...     Example:
    ...     | Start Capturing CPRI Interface Traffic From Gnb To HuB |

    ssh_conn.connect to  ${ASIK_IP_LMP}  username=${ASIK_user_name}
    ...                                  password=${ASIK_password}
    ...                                  alias=ASIK_LMP

    ${containers}    ssh_conn.execute    command=lxc-ls    connection=ASIK_LMP
    Should Match Regexp    ${containers}    ((0x\\d{4}\\s*)+)
    ${containerid}    Should Match Regexp    ${containers}    0x[12]018
    Set Suite Variable    ${containerid}

    ssh_conn.send command    command=lxc-attach -n ${containerid} -- tcpdump -i rlan0.cpri -s0 -w /tmp/rlan0.cpri.pcap &>/dev/null &
    ...    connection=ASIK_LMP
    Log To Console    Launched tcpdump on rlan0.cpri interface

    [Teardown]  ssh_conn.disconnect    connection=ASIK_LMP


Stop Capturing CPRI Interface Traffic From Gnb To HuB
    [Documentation]    Stop tcpdump on GNB and download pcap files to local UTE. Target directory is under
    ...                ${OUTPUTDIR}/${SUITE NAME}/${TEST NAME}/GNB. Normally this keyword is called in
    ...                [Teardown] section of each test.
    ...
    ...                ${OUTPUTDIR} is normally specified by --outputdir option
    ...                ${SUITE NAME} is test suite name
    ...                ${TEST NAME} is test case name
    ...
    ...     Arguments: None
    ...
    ...     Example:
    ...     | Stop Capturing CPRI Interface Traffic From Gnb To HuB |

    ssh_conn.connect to  ${ASIK_IP_LMP}  username=${ASIK_user_name}
    ...                                  password=${ASIK_password}
    ...                                  alias=ASIK_LMP

    ${pid}  ssh_conn.execute   command=lxc-attach -n ${containerid} -- ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'
    ...    connection=ASIK_LMP
    ssh_conn.execute   command=lxc-attach -n ${containerid} -- kill -2 ${pid.replace('\r\n','')}   connection=ASIK_LMP

    ${result}    Get Variable Value    ${TEST_LOG_DIR}
    ${PCAP_LOG_DIR}    Set Variable If    "${result}" != 'None'    ${result}/GNB    ${OUTPUT_DIR}/${SUITE NAME}/${TEST NAME}/GNB
    OperatingSystem.Create Directory    ${PCAP_LOG_DIR}

    ssh_conn.download_file   local_path=${PCAP_LOG_DIR}/rlan0.cpri.pcap    remote_path=/tmp/node_${containerid}/tmp/rlan0.cpri.pcap
    ...                      connection=ASIK_LMP

    Log To Console    Download file rlan0.cpri.pcap to local UTE completed

    [Teardown]    Run Keywords    ssh_conn.execute    command=rm -rf /tmp/node_${containerid}/tmp/rlan0.cpri.pcap    connection=ASIK_LMP  AND
    ...                           ssh_conn.disconnect    connection=ASIK_LMP
