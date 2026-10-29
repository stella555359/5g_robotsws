*** Settings ***
Documentation
...  author:  Krzysztof Michalski, Jakub Matuszczyk
...  contact: krzysztof.michalski@nokia.com,  jakub.matuszczyk@nokia.com

Library     SSHLibrary                                                        WITH NAME    ssh
Library     OperatingSystem                                                   WITH NAME    os
Library     DateTime                                                          WITH NAME    dt
Library     String                                                            WITH NAME    str

Library     taf.ue                                                            WITH NAME    ue
Library     taf.sbts.oam.coam.admin                                           WITH NAME    admin_cli
Library     taf.rfrl.ue.ute_ue_config.UteUeConfig                             WITH NAME    uteueconfig
Library     taf.collectors.tcpdump                                            WITH NAME    tcpdump
Library     taf.collectors.core                                               WITH NAME    core
Library     taf.transport.ssh                                                 WITH NAME    csn

Library     taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter                  WITH NAME      gnbcounter
Library     taf.rfrl.utilities.test_config.DefaultFileLocation                WITH NAME      dfl

Library     taf/rfrl/procedures/resources/python/sleeping_cell_detector.py    WITH NAME    scd

Library     testsuite/Krakow/RRM/RAN_PZ/resources/pcap_verification/flow_verifier.py
Library     testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB008140/resources/suite_specific_keywords.py
Library     testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB008140/resources/ping.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Variables    delta.py
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***

@{inter_gnb_ca_message_flow_prime_gnb}=    IgNBCAUeContextModificationRequest
...    IgNBCAUeContextModificationResponse
...    IgNBCAAdditionRequest
...    IgNBCAAdditionRequestAcknowledge
...    IgNBCAUeContextModificationRequest
...    IgNBCAUeContextModificationResponse
...    IgNBCAModificationRequest
...    IgNBCAModificationRequestAcknowledge
...    UEContextModificationRequest
...    UEContextModificationResponse
...    UEContextModificationRequest
...    UEContextModificationResponse

@{bearer_deletion_message_flow_prime_gnb}=    PDUSessionResourceModifyRequest
...    BearerContextModificationRequest
...    BearerContextModificationResponse
...    UEContextModificationRequest
...    UEContextModificationResponse
...    UEContextModificationRequest
...    UEContextModificationResponse
...    IgNBCAModificationRequest
...    IgNBCAModificationRequestAcknowledge

@{pdu_session_release_message_flow_prime_gnb}=     PDUSessionResourceReleaseCommand
...    BearerContextModificationRequest
...    BearerContextModificationResponse
...    UEContextModificationRequest
...    UEContextModificationResponse
...    UEContextModificationRequest
...    UEContextModificationResponse
...    IgNBCAModificationRequest
...    IgNBCAModificationRequestAcknowledge

@{inter_gnb_ca_message_flow_ext_gnb}=    IgNBCAUeContextSetupRequest
...    IgNBCAUeContextSetupResponse
...    IgNBCAUeContextModificationRequest
...    IgNBCAUeContextModificationResponse

@{bearer_deletion_message_flow_ext_gnb}=
...    IgNBCAUeContextModificationRequest
...    IgNBCAUeContextModificationResponse

@{pdu_session_release_message_flow_ext_gnb}=
...    IgNBCAModificationRequest
...    IgNBCAUeContextModificationRequest
...    IgNBCAUeContextModificationResponse
...    IgNBCAModificationRequestAcknowledge

${awaited_message}     IgNBCAAdditionRequestAcknowledge

${host}=          ${None}
${username}=      ${None}
${password}=      ${None}
${release}=       ${None}
${host_delaybox}=        ${None}
${username_delaybox}=     ${None}
${password_delaybox}=     ${None}

${pri_gnb_pcap}    F1AP59.pcap
${ext_gnb_pcap}    F1AP60.pcap
${pri_gnb_pcap_path}    ${LOG_PATH}/F1AP59.pcap
${ext_gnb_pcap_path}    ${LOG_PATH}/F1AP60.pcap
${pcap_capture_filter}  'sctp and (port 38472 or port 38412 or port 38422 or port 38462 or port 3642)'

${wslte5g_url}     https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local
${url_xn_plugin}    ${wslte5g_url}/Nokia_Xn_AP/nokiaxnap-18.3.0-p170/nokiaxnap-4.4-0.0.12-18.3.0-p170+bookworm.so
${url_f1_plugin}    ${wslte5g_url}/Nokia_F1_AP/nokiaf1ap-18.4.0-p272/nokiaf1ap-4.4-0.0.16-18.4.0-p272+bookworm.so

${header_to_repo}    'X-JFrog-Art-Api: AKCp8oiHU5YVmxybvkJef917wNemeaeHb5LMqX8272B2AU1dcGx4fHim1ifQ8JVJcZR6kZYMj'
${directory_plugins}    /usr/lib/x86_64-linux-gnu/wireshark/plugins/4.4/epan/

*** Keywords ***
Suite Setup
    Log Action To Console    Suite setup
    Download Wireshark Plugins
    Run Keyword And Ignore Error    scd.Enable Sleeping Cell Detection Feature    bts_id=0
    Run Keyword And Ignore Error    scd.Enable Sleeping Cell Detection Feature    bts_id=1

Test Setup
    &{abstract_lib_config}=    Get ute UE Configuration Dict
    Set Suite Variable    ${abstract_lib_config}
    ue.Require Ue    UE   REAL_UE
    ${ue_params}=    get_from_ute_ue_config_yaml    ue_alias=UE   top_level_key=CONSTRUCTOR_PARAMETERS
    ${ue_pc_params}=	  Get From Dictionary	  ${ue_params}    configuration
    ${host}=	  Get From Dictionary	  ${ue_pc_params}    ue_pc_address
    Set Suite Variable    ${host}
    ${username}=	  Get From Dictionary	  ${ue_pc_params}    login
    Set Suite Variable    ${username}
    ${password}=	  Get From Dictionary	  ${ue_pc_params}    password
    Set Suite Variable    ${password}
    Set Suite Variable     ${host_delaybox}       ${abstract_lib_config.DELAY_BOX.host}
    Set Suite Variable     ${username_delaybox}       ${abstract_lib_config.DELAY_BOX.login}
    Set Suite Variable     ${password_delaybox}       ${abstract_lib_config.DELAY_BOX.password}
    scd.Start Sleeping Cell Detection Watchdog       log_dir=${LOG_PATH}/SleepingCell    bts_id=0
    scd.Start Sleeping Cell Detection Watchdog       log_dir=${LOG_PATH}/SleepingCell    bts_id=1
    ${release}=    dfl.Get Commissioning Branch
    Set Suite Variable    ${release}

Test Setup for 4CC Tests
    [Documentation]    Test Setup with setting QRX on gNB1 and gNB2 for 4CC Inter gNB CA tests.
    ...                It sets QRX to make UE call cell 1 of gNB1 as Pcell

    Test Setup
    Log Action To Console    Set QRX on gNB1 and gNB2
    Perform QRX Recommissioning on GNB    gnb_id=0    qrx_cell1_value=-45    qrx_cell2_value=-22    qrx_cell3_value=-22
    Perform QRX Recommissioning on GNB    gnb_id=1    qrx_cell1_value=-22    qrx_cell2_value=-22    qrx_cell3_value=-22

Test Setup for 3CC Tests
    [Documentation]    Test Setup with setting QRX on gNB1 and gNB2 for 3CC Inter gNB CA tests.
    ...                It sets QRX to make UE call cell 2 of gNB1 as Pcell

    Test Setup
    Log Action To Console    Set QRX on gNB1 and gNB2
    Perform QRX Recommissioning on GNB    gnb_id=0    qrx_cell1_value=-22    qrx_cell2_value=-45    qrx_cell3_value=-22
    Perform QRX Recommissioning on GNB    gnb_id=1    qrx_cell1_value=-22    qrx_cell2_value=-22    qrx_cell3_value=-22

Test Teardown
    Log Action To Console    Test Teardown
    Run Keyword And Ignore Error    ue.Detach UE    UE
    Collect Logs After Test Finished
    scd.Verify Sleeping Cell Detection
    Common Postconditions

Perform QRX Recommissioning on GNB
    [Arguments]    ${gnb_id}=0    ${qrx_cell1_value}=-45    ${qrx_cell2_value}=-22    ${qrx_cell3_value}=-22
    [Documentation]    Perform QRX recommissioning on gNB.
    ...                :param gnb_id:    gNB id to perform recommissioning
    ...                :param qrx_cell1_value:    qRxLevMin value for cell 1
    ...                :param qrx_cell2_value:    qRxLevMin value for cell 2
    ...                :param qrx_cell3_value:    qRxLevMin value for cell 3

    ${instance_id}=    Convert To String    ${tl.gnbs[${gnb_id}].instance_id}
    Perform Configuration Parameter Recommissioning On gNB    dist_name=MRBTS-${instance_id}/NRBTS-${instance_id}/NRCELL-1
    ...                                                       param_name=qRxLevMin
    ...                                                       param_value=${qrx_cell1_value}
    ...                                                       gnb_id=${gnb_id}
    Sleep    3s
    Perform Configuration Parameter Recommissioning On gNB    dist_name=MRBTS-${instance_id}/NRBTS-${instance_id}/NRCELL-2
    ...                                                       param_name=qRxLevMin
    ...                                                       param_value=${qrx_cell2_value}
    ...                                                       gnb_id=${gnb_id}
    Sleep    3s
    Perform Configuration Parameter Recommissioning On gNB    dist_name=MRBTS-${instance_id}/NRBTS-${instance_id}/NRCELL-3
    ...                                                       param_name=qRxLevMin
    ...                                                       param_value=${qrx_cell3_value}
    ...                                                       gnb_id=${gnb_id}
    Sleep    3s

Download Wireshark Plugins
    Log Action To Console     Downloading plugins for wireshark...
    OperatingSystem.Run     sudo wget --header=${header_to_repo} -P ${directory_plugins} ${url_xn_plugin}
    OperatingSystem.Run     sudo wget --header=${header_to_repo} -P ${directory_plugins} ${url_f1_plugin}

Test Teardown with changing APN to default
    Attach UE
    Change APN with Ueproxy    apn_name=${abstract_lib_config.UE_APN.DEFAULT}
    Detach UE
    Test Teardown

Check Inter gNB CA
    [Arguments]    ${expected_scells}
    [Documentation]   Collect pcaps from attach and verify number of inter gNB sCells configured.
    ...               Check inter gNB CA message flow.
    ...      :param expected_scells:    Expected configured scells number.
    Attach UE And Collect Logs
    Verify Inter gNB sCells Are Configured   ${pri_gnb_pcap_path}   ${expected_scells}
    Check inter gNB CA message flow   ${pri_gnb_pcap_path}    ${ext_gnb_pcap_path}

Check Inter gNB Bearer Deletion
    [Arguments]    ${expected_scells_num}
    [Documentation]   Collect logs from inter gNB bearer deletion procedure and verify if it is success.
    ...               Check if given scells are configured and inter gNB bearer message flow deletion.
    ...    :param expected_scells_num:  Expected number of inter gNB sCell connections.
    Collect Logs From Bearer Deletion
    Verify Inter gNB sCells Are Configured   ${pri_gnb_pcap_path}   ${expected_scells_num}
    Check inter gNB CA bearer deletion message flow    ${pri_gnb_pcap_path}  ${ext_gnb_pcap_path}

Check Inter gNB PDU Session Removal
    [Documentation]   Collecting logs and performs PDU session removal while inter gNB CA estabilished
    Start Collectors
    Attach UE
    Change APN with Ueproxy    apn_name=${abstract_lib_config.UE_APN.APN_CA_NON_ELIGIBLE}
    Sleep  5
    Send AT Command    14    AT+CGACT=1,6
    Sleep  5
    Change APN with Ueproxy    apn_name=${abstract_lib_config.UE_APN.APN_CA_NON_ELIGIBLE}
    Sleep  5
    Change APN with Ueproxy    apn_name=${abstract_lib_config.UE_APN.APN_CA_ELIGIBLE}
    Sleep  20
    Stop Collectors
    Check inter gNB CA pdu session remove message flow     ${pri_gnb_pcap_path}     ${ext_gnb_pcap_path}

Collect Logs from Bearer Deletion
    [Documentation]   Collecting logs and performs DRB bearer deletion while inter gNB CA estabilished
    Start Collectors
    Attach UE
    Change APN with Ueproxy    apn_name=${abstract_lib_config.UE_APN.APN_CA_ELIGIBLE}
    Log Action To Console    Wait 60 sec for bearer deletion
    Sleep  180s
    Detach UE
    Stop Collectors

Change APN
    [Arguments]   ${apn_name}=${abstract_lib_config.UE_APN.APN_CA_ELIGIBLE}
    [Documentation]    Change or create a new apn with given name.
    ...     :param apn_name:   A name of apn to change/create.
    ${apn_id}=    Get APN Id or Create    ${apn_name}
    Change APN By Id  ${apn_id}  ${apn_name}

Change APN with Ueproxy
    [Arguments]    ${apn_name}
    [Documentation]    Changes already created APN with ussage of taf.ue.proxy service.
    ...                :param apn_name:   A name of apn to change/create.
    Log Action To Console    Change APN to ${apn_name} using ueproxy
    ue.change_apn    UE    ${apn_name}
    ...              SIMs,Access Point Names    android.widget.RadioButton

Get APN Id or Create
    [Arguments]   ${apn_name}=${abstract_lib_config.UE_APN.APN_CA_ELIGIBLE}
    [Documentation]    Get apn id or create new apn if not exists and then return id.
    ...         :param apn_name:    Apn name from which to take id or create a new apn.
    ...         :return:            An id of apn.
    ${apn_id}=  Get APN Id    ${apn_name}
    Run Keyword If    ${apn_id} == None    Log Action To Console     \n==Apn ${apn_name} not exsists. Creating new apn.==\n
    ${result}=  Run Keyword If    ${apn_id} == None    Create APN    ${apn_name}
    ${apn_id}=  Set Variable If   ${result} != None    ${result}    ${apn_id}
    [Return]    ${apn_id}

Get APN ID
    [Arguments]    ${apn_name}
    [Documentation]   Get apn id from adb using content query.
    ...          :param apn_name:    Apn name from which to take id.
    ...          :return:            Return an apn id.
    Log Action To Console    Get APN ${apn_name} id
    Open Connection And Log In   ${host}    ${username}    ${password}
    Write  adb shell
    Write  su 0 content query --uri content://telephony/carriers --where "name='${apn_name}'"
    ${output}=	Read	delay=0.5s
    ${apn_id}=  Get apn id from query    ${output}
    Close All Connections
    [Return]   ${apn_id}

Create TCP Dump Collector
    [Arguments]  ${host}=192.168.255.129    ${user}=toor4nsn
    ...          ${password}=oZPS0POrRieRtu  ${name}=tcpdump
    [Documentation]    Create TCP Dump collector which collecting pcap.
    ...         :param host:    Ip/domain adress of machine to collect pcap from
    ...         :param user:    Host user name
    ...         :param password:  Host user password
    ...         :param name:    Collector alias to futher use i.e start/stop logs collecting
    ${executor}=   Create Dictionary    host=${host}   user=${user}    password=${password}
    tcpdump.create_tcpdump_collector
    ...     name=${name}
    ...     options=-i any port 38472 or port 38412 or port 38422 or port 38462 or port 3642
    ...     executor=${executor}
    core.set_test_alias   ${name}

Start Collectors
    [Documentation]   Start logs collectors.
    Start Tcpdump on CU  ${pri_gnb_pcap}  protocol=${pcap_capture_filter}  host=10.84.142.59  interface=any -U
    Start Tcpdump on CU  ${ext_gnb_pcap}  protocol=${pcap_capture_filter}  host=10.84.142.60  interface=any -U

Connect to BTS
    [Arguments]   ${hostname}=10.84.142.59     ${alias}=ASIL
    [Documentation]    Connects to BTS via alias given by an argument.
    ...                :param hostname:    hostname of BTS
    ...                :param alias:    alias by which connection should be established.


    csn.connect_to     hostname=${hostname}
    ...                username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...                alias=${alias}
    [Return]           ${alias}

Stop Collectors
    [Documentation]  Stop logs collectors.
    Stop Tcpdump on CU and Download Logs    ${pri_gnb_pcap}   host=10.84.142.59
    Stop Tcpdump on CU and Download Logs    ${ext_gnb_pcap}   host=10.84.142.60

Start Tcpdump on CU
    [Arguments]   ${filename}=${name}.pcap  ${host}=10.84.142.59  ${interface}=any  ${protocol}=sctp  ${sleep_after_start}=3
    [Documentation]    Starts tcpdump on CU
    ...                :param filename:              file where messages will be saved
    ...                :param host:                  hostname of BTS
    ...                :param interface:             interface to logs collection
    ...                :param protocol:              protocol to filter logs
    ...                :param sleep_after_start:     amout of time to sleep after logs collection start

    ${alias}=    Connect to BTS  hostname=${host}
    csn.send_command    command=tcpdump ${protocol} -i ${interface} -w "/tmp/${filename}"   connection=${alias}
    sleep   ${sleep_after_start} s

Stop Tcpdump on CU and Download Logs
    [Arguments]     ${filename}=${name}.pcap   ${host}=None
    [Documentation]    Stops tcpdump on CU and dwonloads logs
    ...                :param filename:              file where messages will be saved
    ...                :param host:                  hostname of BTS

    ${alias}=    Connect to BTS  hostname=${host}
    sleep   3 s
    csn.execute          command=killall tcpdump
    ...                  connection=${alias}
    csn.execute          command=chmod 777 /tmp/${filename}
    ...                  connection=${alias}
    csn.download_file    /tmp/${filename}    ${LOG_PATH}/${filename}
    ...                  connection=${alias}
    csn.execute          command=rm "/tmp/${filename}"
    ...                  connection=${alias}
    sleep   3 s

Attach UE And Collect Logs
    [Documentation]   Keyword collect pcaps logs from atach. Pcaps are collected on primary and secondary gNB
    Start Collectors
    Log Action To Console    Attach UE and collect logs
    ue.Attach UE   UE  120
    Sleep  5s
    Stop Collectors

Attach UE
    [Documentation]   Attach UE
    Log Action To Console    Attach UE
    ue.Attach UE   UE

Detach UE
    [Documentation]   Detach UE
    Log Action To Console    Detach UE
    ue.Detach UE   UE

Check inter gNB CA message flow
    [Arguments]    ${prime_gnb_pcap}    ${ext_gnb_pcap}
    [Documentation]    Keyword to check if inter gNB CA message flow is correct
    ...                :param prime_gnb_pcap:     Path to pcap collected from primary gNB
    ...                :param ext_gnb_pcap:     Path to pcap collected from external gNB
    Log Action To Console    Check if proper CA messages in primary gNB
    Expect Messages In Flow    awaited_messages=${inter_gnb_ca_message_flow_prime_gnb}    pcap_file=${prime_gnb_pcap}
    Log Action To Console    Check if proper CA messages in external gNB
    Expect Messages In Flow    awaited_messages=${inter_gnb_ca_message_flow_ext_gnb}    pcap_file=${ext_gnb_pcap}

Check inter gNB CA bearer deletion message flow
    [Arguments]    ${prime_gnb_pcap}     ${ext_gnb_pcap}
    [Documentation]    Keyword to check if inter gNB bearer deletion message flow is correct
    ...                :param prime_gnb_pcap:     Path to pcap collected from primary gNB
    ...                :param ext_gnb_pcap:     Path to pcap collected from external gNB
    Log Action To Console    Check if proper bearer deletion messages in primary gNB
    Expect Messages In Flow    awaited_messages=${bearer_deletion_message_flow_prime_gnb}    pcap_file=${prime_gnb_pcap}
    Log Action To Console    Check if proper bearer deletion messages in external gNB
    Expect Messages In Flow    awaited_messages=${bearer_deletion_message_flow_ext_gnb}    pcap_file=${ext_gnb_pcap}

Check inter gNB CA pdu session remove message flow
    [Arguments]    ${prime_gnb_pcap}     ${ext_gnb_pcap}
    [Documentation]    Keyword to check if inter gNB CA message flow is correct
    ...                :param prime_gnb_pcap:     Path to pcap collected from primary gNB
    ...                :param ext_gnb_pcap:     Path to pcap collected from external gNB
    Log Action To Console   Check if proper pdu session release message in primary gNB
    Expect Messages In Flow  awaited_messages=${pdu_session_release_message_flow_prime_gnb}  pcap_file=${prime_gnb_pcap}
    Log Action To Console   Check if proper pdu session release message in external gNB
    Expect Messages In Flow    awaited_messages=${pdu_session_release_message_flow_ext_gnb}    pcap_file=${ext_gnb_pcap}

Start DL and UL data transmission for specified time
    [Arguments]    ${data_transfer_time}    ${ul_throughput}     ${dl_throughput}
    [Documentation]    Keyword starts UDP traffic transmision for specified time.
    ...                Traffic is performed in uplink and downlink directions.
    ...                :param data_transfer_time:    data trasmission's time in seconds
    ...                :param ul_throughput:    level of throughput in uplink direction
    ...                :param dl_throughput:    level of throughput in downlink direction
    Log Action To Console    Start DL and UL data transmission for specified time
    ue.Start Data Transfer    dt_name=DT_1_UL    ue_alias=UE
    ...                  direction=ul    duration=${data_transfer_time}s    protocol=udp    throughput=${ul_throughput}
    ...                       packet=1320    buffer_client=4M
    Sleep    2s
    ue.Start Data Transfer    dt_name=DT_1_DL    ue_alias=UE
    ...                  direction=dl    duration=${data_transfer_time}s    protocol=udp    throughput=${dl_throughput}
    ...                       packet=1320    buffer=4M
    Sleep    2s

Send AT Command
    [Arguments]    ${com_port}    ${command}
    [Documentation]   Send AT command by UE-PC from powershell to UE.
    ...    :param com_port:    Open COM port number which UE can communicate.
    ...    :param command:   Command to send to UE.
    Open Connection And Log In   ${host}    ${username}    ${password}
    Write    powershell
    Write    $port = new-Object System.IO.Ports.SerialPort COM${com_port},9600,None,8,one
    Write    $port.Open()
    Write    $port.WriteLine("${command}`r")
    Write    $port.Close()
    Close All Connections
    Log Action To Console    AT command ${command} executed

Create APN
    [Arguments]    ${name}
    ...            ${mcc}=001
    ...            ${mnc}=01
    ...            ${type}=default
    ...            ${apn}=${name}
    ...            ${protocol}=IPV4
    ...            ${roaming_protocol}=IPV4
    [Documentation]  Create a new apn or overwrite existing.
    ...      :param name:                Name of APN i.e '5gsakrk2'
    ...      :param mcc:                 MCC to set for new APN
    ...      :param mnc:                 MNC to set for new APN
    ...      :param type:                Type of APN
    ...      :param protocol:            Internet protocol to set for new apn. Can be set to IPV4 or IPV6
    ...      :param roaming_protocol:    Roaming protocol for new APN
    ...      :return new_apn_id:         An apn id.
    Log Action To Console    Create APN with name: ${name}
    Open Connection And Log In   ${host}    ${username}    ${password}
    ${ue_command}=  Catenate    adb shell "su 0 content insert --uri content://telephony/carriers --bind name:s:"${name}"
    ...    --bind numeric:s:"${mcc}${mnc}" --bind type:s:"${type}" --bind mcc:i:${mcc} --bind mnc:s:${mnc} --bind apn:s:${apn}
    ...    --bind protocol:s:${protocol} --bind roaming_protocol:s:${roaming_protocol}"
    Write    ${ue_command}
    ${new_apn_id}=  Get Apn Id    ${name}
    [Return]    ${new_apn_id}

Change APN By Id
    [Arguments]    ${apn_id}   ${apn_name}=other
    [Documentation]    Change UE apn by it id.
    ...     :apn_id:    An apn id which can be get from content query command.
    ...     :apn_name:    Apn name. Not necessary to change apn. Only for log purpose.
    Open Connection And Log In   ${host}    ${username}    ${password}
    Write  adb shell "su 0 content insert --uri content://telephony/carriers/preferapn --bind apn_id:i:${apn_id}"
    Close All Connections
    Log Action To Console     APN changed to ${apn_name}

Open Connection And Log In
    [Arguments]    ${host}    ${username}    ${password}
    [Documentation]   Open a ssh connection to given host.
    ...    :param host:  Host to connect with.
    ...    :param username:  Host user login
    ...    :param password:   Host user password
    Open Connection     host=${host}
    ssh.Login               username=${username}        password=${password}

Verify Inter gNB sCells Are Configured
    [Arguments]    ${pcap_filename}    ${expected_scells}
    [Documentation]     This keyword verifies if number of configured sCells in downlink, uplink
    ...                                       or both direction is proper
    ...                 :param pcap_filename: name of the pcap file created during the test, used for
    ...                                       verification of attach
    ...                 :param expected_scells: number of sCells configured in downlink, uplink
    ...                                       or both direction during EN-DC attach
    ${expected_scells_number}=    Get Length   ${expected_scells}
    Log Action To Console    Verify ${expected_scells_number} sCells configured
    ${message}=    Get Messages From The Flow     ${awaited_message}    ${pcap_filename}
    Should Not Be Empty    ${message}    msg=No expected message. Check if UE was detached or attach procedure.
    ${scells_find_messages_info}=    Find All Scells    ${expected_scells}    ${message[0]}
    ${fail_msg}=    Catenate    Number of configured sCells is different than expected. \n Please check pcap file:
    ...   ${pcap_filename}, \n find message: "IgNBCAAdditionRequestAcknowledge with SCell-For-IgNB-CA-Establishment-Setup-List" and compare it \n
    ...   with expected value( ${expected_scells} items).
    Run Keyword If    ${scells_find_messages_info} != ${True}    Fail   msg=${fail_msg}

Prepare PCell to attach
    [Arguments]     ${cell_id_to_attach}    ${apn_name}=${abstract_lib_config.UE_APN.DEFAULT}
    [Documentation]       From 8140-JE in 23R3 Xp link will be restored. Not needed reset both gNB.
    ...                  :param cell_id_to_attach: Distinguished name of cell to be attached
    ...                  :apn_name:     default APN name, but can be changed to dedicated APN
    Log Action To Console    Block all cells on prime-gNB and ext-gNB
    gnbcell.Block All Cells    bts_id=0
    gnbcell.Block All Cells    bts_id=1
    Sleep   60s
    Log Action To Console    UnBlock PCell
    gnbcell.Unblock Cell    cell_id=${cell_id_to_attach}
    gnbcell.Wait For Cell To Be Onair    bts_id=0    cell_id=${cell_id_to_attach}
    Log Action To Console    Attach and detach UE
    ue.Attach UE   UE   120
    Change APN with Ueproxy    apn_name=${apn_name}
    ue.Detach UE   UE
    Log Action To Console    Unblock all cells and wait to onAir state
    gnbcell.Block Cell    cell_id=${cell_id_to_attach}
    Sleep   60s
    gnbcell.Unblock All Cells    bts_id=0
    gnbcell.Unblock All Cells    bts_id=1
    gnbcell.Wait For Setup Of All Cells    bts_id=1     timeout=300
    gnbcell.Wait For Setup Of All Cells    bts_id=0     timeout=300

Prepare PCell to attach and set dedicated APN
    [Arguments]     ${cell_id_to_attach}     ${apn_name}
    [Documentation]       From 8140-JE in 23R3 Xp link will be restored. Not needed reset both gNB.
    ...                   :param cell_id_to_attach:    Distinguished name of cell to be attached
    ...                   :param apn_name:             Dedicated APN
    Log Action To Console    Prepare PCell to attach and set dedicated APN
    Prepare PCell to attach    cell_id_to_attach=${cell_id_to_attach}    apn_name=${apn_name}


Change Scell Activation To CovBasedA1
    [Documentation]       Upload delta and perform commissioning
    Log Action To Console    Set parameter on gNB1
    Perform Delta Commissioning On gNB     delta=${delta_cov_based_a1_prim}     gnb_id=0
    Wait Until Keyword Succeeds     300 sec     15 sec   Verify gNB is onAir
    Log Action To Console    Set parameter on gNB2
    Run Keyword If   '${release}'=='SBTS23R3' or '${release}'=='SBTS23R4' or '${release}'=='SBTS24R1'
    ...    Perform Delta Commissioning On gNB     delta=${delta_cov_based_a1_ext_legacy}     gnb_id=1
    ...    ELSE
    ...    Perform Delta Commissioning On gNB     delta=${delta_cov_based_a1_ext}     gnb_id=1
    Wait Until Keyword Succeeds     300 sec     15 sec   Verify gNB is onAir

Change Scell Activation To Blind
    [Documentation]       Upload delta and perform recommissioning
    Log Action To Console    Set parameter on gNB1
    Perform Delta Commissioning On gNB   ${delta_blind_prim}    gnb_id=0
    Wait Until Keyword Succeeds     300 sec     15 sec   Verify gNB is onAir
    Log Action To Console    Set parameter on gNB2
    Run Keyword If   '${release}'=='SBTS23R3' or '${release}'=='SBTS23R4' or '${release}'=='SBTS24R1'
    ...    Perform Delta Commissioning On gNB     delta=${delta_blind_ext_legacy}     gnb_id=1
    ...    ELSE
    ...    Perform Delta Commissioning On gNB     delta=${delta_blind_ext}     gnb_id=1
    Wait Until Keyword Succeeds     300 sec     15 sec   Verify gNB is onAir

Change 5QI9 to RLC UM
    [Documentation]       Changing QCI for noneligible CA bearer
    Log Action To Console    Set parameter on gNB1 for 5QI-9
    Perform Delta Commissioning On gNB   ${delta_bearer_9_as_rlc_um}    gnb_id=0

Change 5QI9 to RLC AM
    [Documentation]       Changing QCI for eligible CA bearer
    Log Action To Console    Set parameter on gNB1 for 5QI-9
    Perform Delta Commissioning On gNB   delta=${delta_bearer_9_as_rlc_am}    gnb_id=0

Verify UL and DL data transmission
    [Arguments]      ${duration}    ${tput_dl_min}    ${tput_ul_min}    ${port}=${None}
    [Documentation]       Start UL and DL with veryfing given minimal TPUT value.
    ...                 :param duration:       Throughput duration
    ...                 :param tput_dl_min:    Minimum average value of dl tput during whole test
    ...                 :param tput_ul_min:    Minimum average value of ul tput during whole test
    ...                 :param port:           Port on which data transfer should be started
    Log Action To Console    Start DL and UL data transmission for specified time
    ${DT_1_UL_CONFIGURATION}=    Create Dictionary
    ...    dt_name=DT_1_UL
    ...    ue_alias=UE
    ...    direction=ul
    ...    protocol=tcp
    ...    parallel=4
    ...    max_segment_size=1350B
    ...    linux_congestion=reno
    Run Keyword If    ${port} != ${None}    Set To Dictionary    ${DT_1_UL_CONFIGURATION}    port=${port}
    ue.Start Data Transfer    &{DT_1_UL_CONFIGURATION}
    Sleep    1s
    ${DT_1_DL_CONFIGURATION}=    Create Dictionary
    ...    dt_name=DT_1_DL
    ...    ue_alias=UE
    ...    direction=dl
    ...    protocol=tcp
    ...    parallel=4
    ...    max_segment_size=1350B
    ...    linux_congestion=reno
    Run Keyword If    ${port} != ${None}    Set To Dictionary    ${DT_1_DL_CONFIGURATION}    port=${port}
    ue.Start Data Transfer    &{DT_1_DL_CONFIGURATION}
    Sleep    ${duration}
    Log Action To Console    Stop DL and UL data transmission
    ue.Stop Data Transfer    dt_name=DT_1_UL
    ue.Stop Data Transfer    dt_name=DT_1_DL
    Log Action To Console    Verify DL and UL avg tput
    Sleep    10s
    ue.Verify Average Throughput      DT_1_DL     tput_min=${tput_dl_min}    tput_max=2500 Mbits/sec  omit=20
    ue.Verify Average Throughput      DT_1_UL     tput_min=${tput_ul_min}    tput_max=200 Mbits/sec   omit=3

Change delay
    [Arguments]    ${delay}
    [Documentation]    Change delay in delay tool
    ...     :delay:   delay which will be added to delay tool
    Log Action To Console    Add delay
    Open Connection And Log In     host=${host_delaybox}     username=${username_delaybox}
    ...                            password=${password_delaybox}
    Write    sshpass -p ${password_delaybox} sudo tc qdisc change dev ens1f0np0 root netem delay ${delay}
    Write    sshpass -p ${password_delaybox} sudo tc qdisc change dev ens1f1np1 root netem delay ${delay}
    Sleep    10s
    Close All Connections

Log Action To Console
    [Arguments]   ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${False}
    [Documentation]    Log given message to console with extra magic :)
    ...                :param msg:     message logged
    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'   Get Current Date
    Run keyword if    '${datatime}'=='${True}'   Log To Console    [*][${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'   Log To Console    [*] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}

Wait For Next PM measurements
    [Arguments]   ${interval}=5min    ${delay}=30
    [Documentation]  Wait for the next counter cycle, indicated by the interval
    ...              :param interval:    Interval of the counter
    ...              :param delay:    delay for checking PM counters after specified period
    Log Action To Console   Wait For Next PM measurements period
    gnbcounter.Wait For Next Pm Period    ${interval}    ${delay}

Check Inter CA PM Counters Pegged
    [Arguments]    ${counters_dict}    ${pri_gnb_cell_id}    ${ext_gnb_cells_ids}    ${release}
    [Documentation]   Check if inter gnb carrier aggregation pm counters increased
    ...               :param counters_dict:    Dictionary of pm counters to check for primary and external gnbs.
    ...               :param pri_gnb_cell_id:  cells ids to PM counter check for prime gNB
    ...               :param ext_gnb_cell_id:  cells ids to PM counter check  for extensional gNB
    Log Action To Console     Check inter gnb carrier aggregation counters
    ${pri_counters_increased}=    Check PM Counters For Cells Pegged    ${counters_dict}    key=pri_gnb
    ...                                                                 bts_id=0    cells_ids=${pri_gnb_cell_id}
    ...                                                                 release=${release}
    ${ext_counters_increased}=    Check PM Counters For Cells Pegged    ${counters_dict}     key=ext_gnb
    ...                                                                 bts_id=1    cells_ids=${ext_gnb_cells_ids}
    ...                                                                 release=${release}
    Run Keyword If    ${pri_counters_increased} == False or ${ext_counters_increased} == False
    ...                   Fail    At least one of pm counters for cells not incremented.

Check Inter CA PM Counters not Pegged
    [Arguments]    ${counters_dict}    ${pri_gnb_cell_id}    ${ext_gnb_cells_ids}  ${release}
    [Documentation]   Check if inter gnb carrier aggregation pm counters increased
    ...               :param counters_dict:    Dictionary of pm counters to check for primary and external gnbs.
    ...               :param pri_gnb_cell_id:  cells ids to PM counter check for prime gNB
    ...               :param ext_gnb_cell_id:  cells ids to PM counter check  for extensional gNB
    Log Action To Console     Check inter gnb carrier aggregation counters not Pegged
    ${pri_counters_increased}=    Check PM Counters For Cells Pegged    ${counters_dict}    key=pri_gnb_not_pegged
    ...                                                                 bts_id=0    cells_ids=${pri_gnb_cell_id}
    ...                                                                 release=${release}
    ${ext_counters_increased}=    Check PM Counters For Cells Pegged    ${counters_dict}     key=ext_gnb_not_pegged
    ...                                                                 bts_id=1    cells_ids=${ext_gnb_cells_ids}
    ...                                                                 release=${release}
    Run Keyword If    ${pri_counters_increased} == True or ${ext_counters_increased} == True
    ...                   Fail    At least one of pm counters which should be equal 0 is incremented.

Check PM Counters For Cells Pegged
    [Arguments]    ${counters_dict}    ${key}    ${bts_id}    ${cells_ids}    ${release}
    [Documentation]   Check if pm counters for NRCELL objects are incremented.
    ...               Ids of counters are stored in dictionary.
    ...    :param counters_dict:   Dictionary which contains counters ids.
    ...    :param key:             Dictionary key under which the counters ids are stored.
    ...    :param bts_id:          Id of bts to check counters on.
    ...    :cells_ids:             List of ids of cells to check counters on.
    Log Action To Console    Check cell counters for ${key}
    ${counters_ids}=    Get From Dictionary    ${counters_dict}   ${key}
    ${counters}=    gnbcounter.Get Counter    ${counters_ids}    bts_id=${bts_id}
    ${is_incremented}=    Check If Cells Counters Were Incremented    ${counters}  ${cells_ids}  ${bts_id}  ${release}
    [Return]    ${is_incremented}

Check IGNB_CA_ADD_REQ_SA_NRADJ counter incremented
    [Arguments]        ${release}
    [Documentation]    Check if IGNB_CA_ADD_REQ_SA_NRADJ counter is pegged.
    ...                M55175C00001 for legacy branch
    ...                M55199C00001 since 24R2
    Log Action To Console    Check IGNB_CA_ADD_REQ_SA_NRADJ counter
    ${counter_name}=  set variable if  '${release}'=='SBTS23R3' or '${release}'=='SBTS23R4' or '${release}'=='SBTS24R1'  M55175C00001  M55199C00001
    ${counter}=    gnbcounter.Get Counter    ${counter_name}    bts_id=1
    ${is_incremented}=    Is counter incremented    ${counter}
    Run Keyword If    not ${is_incremented}
    ...    Fail    IGNB_CA_ADD_REQ_SA_NRADJ is not incremented
