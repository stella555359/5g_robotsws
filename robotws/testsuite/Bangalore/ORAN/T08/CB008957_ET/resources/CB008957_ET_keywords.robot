*** Settings ***
Documentation
...   author: Kancham Reddy Madhuri Reddy
...   contact: kancham.reddy_madhuri_reddy@nokia.com
...   Description: Keywords file for Test Suite CB008957_ET

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

${cmd_oran-supervision}    set-failure name=o-ran-supervision timeout-rpc=90 rpc=true

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

Create SSH Session To ORU and trigger fault locally
    [Arguments]    ${cmd}
	${command}=    set variable    ssh oru01@192.168.200.1 ${cmd}
    os.Run    ${command}

Verify ORAN Fault 10
	Check Active Fault		10
	sleep    100s
	Check Cleared Fault		10

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

Get Host IP
    [Documentation]
    ...    Get HOST Ip address of VM
    ${rc}  ${host_ip}=  os.Run And Return Rc And Output  hostname -i
    log to console    host-ip is ${host_ip}
    [Return]   ${host_ip}
