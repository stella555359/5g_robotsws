*** Settings ***
Documentation
...   author: Sreekumar Narimuri Kumaran
...   contact: sreekumar.narimuri_kumaran@nokia.com
...   Description: Keywords file for Test Suite CB010792: Introduction of O-RAN fronthaul specification baseline v12

Library     SSHLibrary
Library     Collections
Library     BuiltIn
Library     String
Library     OperatingSystem     WITH NAME    os
Library     taf.sbts.oam.coam.admin    WITH NAME    admin
Library     taf.collectors.simple       WITH NAME    simple
Library     taf.collectors.tcpdump    WITH NAME    tcpdump
Library		taf.collectors.core   WITH NAME   core
Library     ta5g_syslog
Library     taf.collectors.btslog      WITH NAME    btslog
Library     testsuite/Bangalore/ORAN/resources/python/netconf_validation.py
Library     testsuite/Bangalore/ORAN/resources/python/downloadwftpackage.py
Library     taf.file.pack

*** Variables ***
${timeout}=                600
@{active}=    true    false
@{fault_list_Faults}=    4654    61524    4655    4720    4176    61649
...                           1955    1928    1923    1981    2907    2908    4    2
...                           7116    7115    7220    7241    7240    7101    7111
...							  7100    34    35
@{netconf_list_fault}=     28    21    25    30    16    23    2    4    34	 35
${Docker_username}=        inbabtslabuser
${ssh_username}=           toor4nsn
${ssh_password}=           oZPS0POrRieRtu
${password_BTS}=           BT5l@bus3rl0g1n
${oran_alias}=             rusim
${ORU_SIM_IP}=             10.45.150.73
${BTS_path}=               /home/ute/Logs
${value_true}=            true
${value_false}=           false
${connection}=            default
${BTS_ADDRESS} =           192.168.255.129
${BTS_ADDRESS_iphy} =      192.168.200.1
${delete_cmd}=    rm -rf /tmp/node_FHNET80/tmp/RMOD_L-1_NetconfRpcMessageTrace*
${source}=        /tmp/node_FHNET80/tmp/${NetconfFileName}
${NetconfFileName}=        RMOD_L-1_NetconfRpcMessageTrace_0.log
${operation_value}=    update
@{DORA_messages}=    DHCP Offer    DHCP ACK
${count}=	  0
&{default_user}=    defaultNetconfAccountName=xranuser
...                 defaultNetconfAccountPwd=xran-password
&{authentication}=        id=1    defaultNetconfAccount=&{default_user}
@{sudo_list}=        &{authentication}

${host}             127.0.0.1
${username}         ute
${password}         BT5l@bus3rl0g1n
${VM_usn}    ute
${VM_pwd}    BT5l@bus3rl0g1n

${cmd_fault34_trigger}    active-alarm-test-list active-alarms[1]/fault-name=Clock-Source-Failure active-alarms[1]/fault-id=34 \
...		active-alarms[1]/is-cleared=false active-alarms[1]/fault-source=OFEGSA active-alarms[1]/affected-objects[1]/name=object1 \
...		active-alarms[1]/fault-severity=CRITICAL


${cmd_fault34_clear}    active-alarm-test-list active-alarms[1]/fault-name=Clock-Source-Failure active-alarms[1]/fault-id=34 \
...		active-alarms[1]/is-cleared=true

${cmd_fault35_trigger}    active-alarm-test-list active-alarms[1]/fault-name=Lost-ODU-ID-based-supervision active-alarms[1]/fault-id=35 \
...		active-alarms[1]/is-cleared=false active-alarms[1]/fault-source=OFEGSA active-alarms[1]/affected-objects[1]/name=object1 \
...		active-alarms[1]/fault-severity=MAJOR

${cmd_fault35_clear}    active-alarm-test-list active-alarms[1]/fault-name=Lost-ODU-ID-based-supervision active-alarms[1]/fault-id=35 \
...		active-alarms[1]/is-cleared=true

${Auth_token}		cmVmdGtuOjAxOjE3ODk4ODczMDg6SERSdGhabjNtS2dxTXI3cVljY1dqU1NISlFn
${FJT_BUILD_USERNAME}	  ca_fujitsu_nok
${Radio_name}		fujitsu
${file_extension}    zip
${FJT_string}		FJ-RU-ET1
${dhcp_filter}		dhcp.option.type == 125
${tcpdump_path}		${OUTPUT_DIR}/${SUITE NAME}/${TEST_NAME}/tcpdump

*** Keywords ***
Collect Snapshot
	admin.collect_snapshot    target_file_name=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Snapshotfile.zip
	...			connection=nom

Admin_Connection
    admin.setup_admin    bts_host=${BTS_ADDRESS}	alias=nom

Get ActiveAlarms
    ${alr}=     admin.get_active_alarms		timeout=10		connection=nom
    BuiltIn.log     ${alr}
    ${alr_num}=     admin.get_active_alarms_number		timeout=10		connection=nom
    BuiltIn.Log    ${alr_num}

Test Teardown
    BuiltIn.Log to console  --End test--\n
    Collect Snapshot
    Get ActiveAlarms
    admin.teardown_admin	nom

Suite Setup Local
    BuiltIn.log     Test Started
    ${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M
    ${CurrentDate}=    Convert to String     ${CurrentDate}
    os.Create Directory    ${BTS_path}/${SUITE NAME}/${CurrentDate}
    Set global variable    ${Date}    ${CurrentDate}

Test Setup
    os.run    chmod 777 ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    Get ActiveAlarms

Suite Teardown Local
	BuiltIn.log    Test END
	Link SCOUT SCF to Configuration ID for Reporting

Validating M-plane v12 negotiation
    [Arguments]    ${netconf_file}
    ${a}=    netconf_get_value    ${netconf_file}    rpc    get    operational-info
    ${a}=    validate_netconf_reply_message      ${netconf_file}     get    supported-mplane-version
    run keyword and continue on failure   Should not be empty    ${a}
    BuiltIn.Log to console  ${a}
    ${b}=  Get Dictionary Values  ${a[1][2]}
    BuiltIn.Log to console  ${b}
    Should Be True    @{b} < ['5.0.0']

DeleteNetconfLogs
    SSHLibrary.Open Connection    host=${BTS_ADDRESS}
    SSHLibrary.Login    ${ssh_username}    ${ssh_password}    delay=10
    SSHLibrary.Write    ${delete_cmd}
    SSHLibrary.Close All Connections

GetNetconfLogs
    [Arguments]    ${path}
    SSHLibrary.Open Connection    host=${BTS_ADDRESS}
    SSHLibrary.Login    ${ssh_username}    password=${ssh_password}    delay=10
    SSHLibrary.Get File
	...     source=${source}
	...     destination=${path}/${NetconfFileName}    scp=scp
    SSHLibrary.Close All Connections

MessageVerification_alarm
    [Arguments]    ${netconf_file}    @{listoffaults}
    ${al}=    netconf_get_value     ${netconf_file}    notification    alarm-notif    fault-id
    ${len}=    Get Length    ${al}
    FOR    ${i}    IN RANGE    ${len}
		should contain any    ${al}[${i}]    @{listoffaults}
    END
    ${al}=    netconf_get_value     ${netconf_file}    notification    alarm-notif    is-cleared
    FOR    ${i}    IN RANGE    ${len}
		should contain any    ${al}[${i}]    true    false
    END
    ${al}=    netconf_get_value     ${netconf_file}    notification    alarm-notif    fault-severity
    FOR    ${i}    IN RANGE    ${len}
		should contain any    ${al}[${i}]    MINOR    MAJOR    CRITICAL
    END

Verify_Mplane_version_is_12
    [Arguments]    ${netconf_file}
    ${a}=    netconf_get_value     ${netconf_file}
    ...    rpc-reply     data    supported-mplane-version		12.0.0
    BuiltIn.log       ${a}
    ${len}= 	Get length	${a}
    Run keyword Unless	   ${len} > 0     Fail

Verify Netconf Rpc for ORU SW Upgrade
    [Arguments]    ${netconf_file}

    ${a}=    netconf_get_value     ${netconf_file}
    ...    notification     download-event      file-name     FJ-RU-ET1---------0202.FGF.zip
    BuiltIn.log       ${a}
    ${len}= 	Get length	${a}
    Run keyword Unless	${len} > 0     Fail

    ${a}=    netconf_get_value     ${netconf_file}
    ...    notification     download-event      status     COMPLETED
    BuiltIn.log       ${a}
    ${len}= 	Get length	${a}
    Run keyword Unless	${len} > 0     Fail

    ${a}=    netconf_get_value     ${netconf_file}
    ...    rpc    software-install     file-names    FJ-RU-ET1---------0202.FGF
    BuiltIn.log       ${a}
    ${len}= 	Get length	${a}
    Run keyword Unless	${len} > 0     Fail

    ${a}=    netconf_get_value     ${netconf_file}
    ...    notification    install-event    status     COMPLETED
    BuiltIn.log       ${a}
    ${len}= 	Get length	${a}
    Run keyword Unless	${len} > 0     Fail

    ${a}=    netconf_get_value     ${netconf_file}
    ...    rpc     software-activate    slot-name    slot1
    BuiltIn.log       ${a}
    ${len}= 	Get length	${a}
    Run keyword Unless	${len} > 0     Fail

    ${a}=    netconf_get_value     ${netconf_file}
    ...    notification    activation-event    status     COMPLETED
    BuiltIn.log       ${a}
    ${len}= 	Get length	${a}
    Run keyword Unless	${len} > 0     Fail

Netconf call home and dhcp option 125 validation
	Get TcpdumpLogs from container using lxc-attach
    RMOD_Reset
    Wait Until Keyword Succeeds    10min    10s    Check BTS is OnAir   nom
    Stop TcpdumpLogs
#	GetNetconfLogs        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    Netconf file extract
    os.Copy File    ${output}
    ...    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}
	${pcap_output}=    Convert pcap file locally    ${dhcp_filter}		${tcpdump_path}
    validate wireshark logs    ${pcap_output}    DHCP Offer
	validate wireshark logs    ${pcap_output}    DHCP ACK

Get TcpdumpLogs from container using lxc-attach
    ${executor}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=toor4nsn
    ...  password=oZPS0POrRieRtu
    tcpdump.create_lxc_tcpdump_collector
    ...    name=tcpdump
    ...    options=-i any
    ...    executor=${executor}
    ...    container=0x2018
    core.setup_collectors    names=tcpdump
    core.set_suite_alias	tcpdump
    core.start_collectors    names=tcpdump

Stop TcpdumpLogs
    core.stop_collectors    names=tcpdump
    core.collect_collectors    names=tcpdump
    core.teardown_collectors    names=tcpdump

RMOD_Reset
    BuiltIn.Log To Console    resetting RMOD
    ${dist}    admin.get_ids_for all   RMOD    connection=nom
    FOR    ${dis}    IN    @{dist}
        ${opt}    admin.reset_unit    dist_name=${dis}    reset_type=Warm    timeout=300    connection=nom
        ${optt}    get from list    ${opt}    1
        Run keyword if    '${optt['resultNode']['parameters']['status']}'=='Succeeded'
        ...    BuiltIn.Log to console    RMOD reset is Done
        ...    ELSE    fail
    END

load ncsnapshot
    [Arguments]    ${ncsnap_path}
    ${cmd1}  Set Variable   scp ${ncsnap_path} toor4nsn@192.168.200.1:/rom/simmode/
    ${status1}    run    ${cmd1}

load iphyfile
    os.Run    chmod +x ${INSTALL_OFGESA}
    os.Run    sh ${INSTALL_OFGESA}
    Log to console    \nInstalling OFGESA radio

Configure Netconf Credentials1
    admin.configure_netconf_accounts    unsecure_ciphering=false
    ...    authentication_method=NoAuthentication
    ...    timeout=60
    ...    connection=nom
    ...    accounts=@{sudo_list}


Load CFG Config And Verify cell setup in Capture CPRT Traces
    [Arguments]    ${wts_cfg_file}
    Fetch board type
    Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    ${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    Check gNB Airscale is Ready - ${BBoard_Type}
    Log To console     loading cfg file
    Start WTS Using WTS_Runner      ${wts_cfg_file}

Check gNB Bulid
    ${aliasGNB}                     OAM Connect                             ${AIRSCALE_GNB.oam}
    ${GNB_SW_VERSION}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}
    Set Suite Variable    ${GNB_SW_VERSION}
    ${Branch_22R1}    Run Keyword and Return Status   Should Contain    ${GNB_SW_VERSION}     22R1
    Set Suite variable   ${Branch_22R1}

Configure UTE ETH3 IPs
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    os.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    os.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    os.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    os.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    os.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    os.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    os.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    os.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    os.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    os.Run    sudo ip addr add 10.0.1.3/24 dev eth3
    os.Run    sudo ip addr add 10.0.1.4/24 dev eth3


Create SSH Session To ORU and trigger fault
    [Arguments]    ${cmd}
    SSHLibrary.Open Connection    ${host}        alias=APoabio
    SSHLibrary.Login    ${username}    ${password}    delay=1
	SSHLibrary.write    touch /home/ute/sample.txt
	SSHLibrary.Read     delay=2s
    SSHLibrary.write    ssh oru01@192.168.200.1 ${cmd}
	SSHLibrary.Read     delay=10s
    SSHLibrary.Close All Connections

Create SSH Session To ORU and trigger fault locally
    [Arguments]    ${cmd}
	${command}=    set variable    ssh oru01@192.168.200.1 ${cmd}
    os.Run    ${command}

Verify ORAN Faults 34 and 35
	DeleteNetconfLogs
	Create SSH Session To ORU and trigger fault locally     ${cmd_fault34_trigger}
	sleep    30s
	BuiltIn.log to console		oran fault 34 is triggered from ap.
	Check Active Fault		34

	Create SSH Session To ORU and trigger fault locally    ${cmd_fault34_clear}
    sleep    30s
	BuiltIn.log to console		oran fault 34 is cleared from ap.
	Check Cleared Fault		34

    Create SSH Session To ORU and trigger fault locally    ${cmd_fault35_trigger}
    sleep    30s
	BuiltIn.log to console		oran fault 35 is triggered from ap.
	Check Active Fault		35

    Create SSH Session To ORU and trigger fault locally    ${cmd_fault35_clear}
    sleep    30s
	BuiltIn.log to console		oran fault 35 is cleared from ap.
	Check Cleared Fault		35

    Netconf file extract
	os.Copy File    ${output}
    ...    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Faults/${NetconfFileName}
#    GetNetconfLogs        ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Faults
    MessageVerification_alarm    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Faults/${NetconfFileName}    @{netconf_list_fault}

Iterate and Check file exist
	[Arguments]    ${folder_path}		${file_extension}        ${FJT_string}
	${files}=    OperatingSystem.List Files In Directory    ${folder_path}		[!.]*.zip
	${status}=    Set Variable     False
	FOR    ${file}    IN    @{files}
		${rest}    ${last}=    Split String From Right    ${file}    .    1
		${zip_status}=    Run Keyword And Return Status    Should Contain    ${last}     ${file_extension}
		${fjt_status}=    Run Keyword And Return Status    Should Contain    ${rest}     ${FJT_string}
		Exit For Loop IF    "${last}" == "${file_extension}"
	END
	[Return]    ${status}     ${file}

Upgrade ORU SW
    BuiltIn.Log To Console    BTS is Connected
	BuiltIn.Log to console	  deleting netconf logs
	DeleteNetconfLogs
	Sleep    10
	BuiltIn.Log to console   \n--Downloading latest OFEGSA build from artificatory--\n
	download_latest_RU		${FJT_BUILD_USERNAME}    ${Auth_token}     ${Radio_name}
	${exists}    ${FJT_file_name}=     CB010792_keywords.Iterate and Check file exist
    ...         ${EXECDIR}		${file_extension}    ${FJT_string}
	${FJT_sw_path}=   Set Variable     ${EXECDIR}/${FJT_file_name}
	log to console     ${FJT_sw_path}
    BuiltIn.Log to console   \n--Starting oru sw upgrade procedure--\n
    admin.update_software      sw_package=${FJT_sw_path}
	...			should_activate=True
	...			timeout=600
	...			connection=nom
	...			should_reset_radios=True
	...			override_ru_software=True
	...			independent_sw_update_type=None
    BuiltIn.Log To Console    sw upgarde procedure is completed
    sleep    30s

Check Active Fault
    [Arguments]    ${FaultToCheck}
	@{ActiveFaultIds}=    Create List
    ${alr}=     admin.get_active_alarms   connection=nom
    BuiltIn.log     ${alr}
    ${alr_num}=     admin.get_active_alarms_number   connection=nom
    BuiltIn.Log    ${alr_num}
    FOR    ${i}    IN RANGE   ${alr_num}
        ${Alrstring}=    Convert To String    ${alr}[${i}][alarmId]
        ${fltstring}=    Convert To String    ${alr}[${i}][faultId]
		BuiltIn.Log    ${fltstring}
		Append To List    ${ActiveFaultIds}	${fltstring}
    END
	${count}=	Count Values In List    ${ActiveFaultIds}		${FaultToCheck}
    Run Keyword if    '${count}'=='${1}'
    ...    log to console    Fault=${FaultToCheck} is triggerd.
    ...    ELSE    fail

Check Cleared Fault
    [Arguments]    ${FaultToCheck}
	@{ClearedFaultIds}=    Create List
    ${alr}=     admin.get_historic_alarms   connection=nom
    BuiltIn.log     ${alr}
    ${alr_num}=     admin.get_historic_alarms_number   connection=nom
    BuiltIn.Log    ${alr_num}
    FOR    ${i}    IN RANGE   ${alr_num}
        ${Alrstring}=    Convert To String    ${alr}[${i}][alarmId]
        ${fltstring}=    Convert To String    ${alr}[${i}][faultId]
		BuiltIn.Log    ${fltstring}
		Append To List    ${ClearedFaultIds}	${fltstring}
    END
	${count}=	Count Values In List    ${ClearedFaultIds}		${FaultToCheck}
    Run Keyword if    '${count}'=='${1}'
    ...    log to console    Fault=${FaultToCheck} is cleared.
    ...    ELSE    fail

SSH_connection
    [Arguments]    ${IP}    ${username}
    SSHLibrary.Open Connection    ${IP}    port=22
    SSHLibrary.Login    ${username}

SSH_teardown
    sshlibrary.close connection

Convert pcap file
    [Arguments]    ${filter1}	${pcap_filepath}
    ${host_ip}=     Get Host IP
    SSH_connection    ${host_ip}	${username}
    SSHLibrary.write    cd /home/ute
    ${command}=    set variable    tshark -r ${pcap_filepath}/tcpdump.pcap -Y "${filter1}" > ${pcap_filepath}/tcpdump.txt
    SSHLibrary.write    ${command}
    sleep    60s
    ${filepath}    set variable    ${pcap_filepath}/tcpdump.txt
    ${file}=    os.Get file    ${filepath}
    SSH_teardown
    [Return]    ${file}

Convert pcap file locally
    [Arguments]    ${filter1}	${pcap_filepath}
    ${command}=    set variable    tshark -r ${pcap_filepath}/tcpdump.pcap -Y "${filter1}" > ${pcap_filepath}/tcpdump.txt
    os.Run    ${command}
    sleep    60s
    ${filepath}    set variable    ${pcap_filepath}/tcpdump.txt
    ${file}=    os.Get file    ${filepath}
    [Return]    ${file}

validate wireshark logs
    [Documentation]    this keyword is used to validate wireshark logs
    [Arguments]    ${logfile}    ${message}
    @{log}    Split to lines    ${logfile}
    FOR    ${a}    IN    @{log}
        ${status}    run keyword and return status    should contain    ${a}    ${message}
        run keyword if    '''${status}'''=='''True'''    exit for loop
    END
    Run Keyword if    '''${status}'''=='''True'''    Log to console    ${message} message is found in wireshark log
    ...    ELSE    Log to console     ${message} message is not found in wireshark log
    Run Keyword if    '''${status}'''!='''True'''    fail

Get Host IP
    [Documentation]
    ...    Get HOST Ip address of VM
    ${rc}  ${host_ip}=  os.Run And Return Rc And Output  hostname -i
    log to console    host-ip is ${host_ip}
    [Return]   ${host_ip}

Netconf file extract
	Collect Snapshot
	taf.file.pack.Extract    path=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Snapshotfile.zip
	...     output_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Snapshotfile_unzip
	${status}    ${result}=    Run Keyword And Ignore Error
	...    os.Run And Return Rc And Output
	...    find ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Snapshotfile_unzip -name "*RPC.log"
	${rc}=    Set Variable    ${result}[0]
	${output}=    Set Variable    ${result}[1]
	IF    '${output}' == ''
		${rc2}    ${output}=    os.Run And Return Rc And Output
		...    find ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Snapshotfile_unzip -name "*NetconfRpcMessageTrace.log"
	END
	Run Keyword If    '${output}' == ''    Log To Console    No matching log files found!    WARN
	BuiltIn.Log    Found log files:\n${output}
	Set Global Variable    ${output}