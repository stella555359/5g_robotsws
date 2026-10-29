*** Settings ***
Documentation
...   author: Sreekumar Narimuri Kumaran
...   contact: sreekumar.narimuri_kumaran@nokia.com
...   Description: Keywords file for Test Suite CB010449

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
${NR_ABIP_RU_count}=    6
${NR_ABIQ_RU_count}=    4
${mrbts}=    MRBTS-1/EQM-1/APEQM-1/RMOD-
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

${UE_ID1}		1
${UE_count_NR_ABIP}		2
${UE_count_NR_ABIQ}		2
${nwslice_ID}   1
${gw_ID3}     1
${gw_ID2}     2
${gw_ID1}     3
${gw_ID4}     4
${Pdu_session_ID3}       3
${Pdu_session_ID2}       2
${Pdu_session_ID1}       1
${Pdu_session_ID4}       4
${QFI_ID}    1
${TRF_ID}    1

${ue_id_sample}		1

*** Keywords ***
Collect Snapshot
	admin.collect_snapshot    target_file_name=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Snapshotfile.zip
	...			connection=nom

Admin_Connection
    admin.setup_admin    bts_host=${BTS_ADDRESS}	alias=nom

Check ActiveFaultandAlarmID
    [Arguments]    @{fault_list}
    ${alr}=     admin.get_active_alarms   connection=nom
    BuiltIn.log     ${alr}
    ${alr_num}=     admin.get_active_alarms_number   connection=nom
    BuiltIn.Log    ${alr_num}
    FOR    ${i}    IN RANGE   ${alr_num}
        BuiltIn.Log    ${alr}[${i}][faultName]
        ${Alrstring}=    Convert To String    ${alr}[${i}][alarmId]
        ${fltstring}=    Convert To String    ${alr}[${i}][faultId]
        run keyword and continue on failure    should contain any    ${fltstring}    @{fault_list}
        run keyword and continue on failure    should contain any    ${Alrstring}    @{fault_list}
    END

Get ActiveAlarms
    ${alr}=     admin.get_active_alarms		timeout=10		connection=nom
    BuiltIn.log     ${alr}
    ${alr_num}=     admin.get_active_alarms_number		timeout=10		connection=nom
    BuiltIn.Log    ${alr_num}

Test Teardown
    BuiltIn.Log to console  --End test--\n
    #Collect Snapshot
    Get ActiveAlarms
    admin.teardown_admin	nom

Suite Teardown Local
	BuiltIn.log    Test END
	Link SCOUT SCF to Configuration ID for Reporting

Suite Setup Local
    BuiltIn.log     Test Started
    ${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M
    ${CurrentDate}=    Convert to String     ${CurrentDate}
    os.Create Directory    ${BTS_path}/${SUITE NAME}/${CurrentDate}
    Set global variable    ${Date}    ${CurrentDate}

Test Setup
    os.run    chmod 777 ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    Get ActiveAlarms

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

load ncsnapshot
    [Arguments]    ${ncsnap_path}
    ${cmd1}  Set Variable   scp ${ncsnap_path} toor4nsn@192.168.200.1:/rom/simmode/
    ${status1}    run    ${cmd1}

load iphyfile
    os.Run    chmod +x ${INSTALL_OFGESA}
    os.Run    sh ${INSTALL_OFGESA}
    Log to console    \nInstalling OFGESA radio

Configure Netconf Credentials Simulator
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

Check Active Fault
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

Convert pcap file
    [Arguments]    ${filepath}		${filter1}
	SSH_connection    ${host}    ${username}    ${password}
    SSHLibrary.write    cd /home/ute
    ${command}=    set variable    tshark -r ${filepath}tcpdump.pcap -Y "${filter1}" > ${filepath}tcpdump.txt
    SSHLibrary.write    ${command}
    sleep    60s
    ${outputfilepath}    set variable    ${filepath}tcpdump.txt
    ${file}=    os.Get File    ${outputfilepath}
    SSH_teardown
    [Return]    ${file}

SSH_connection
    [Arguments]    ${IP}    ${username}    ${pwd}
    SSHLibrary.Open Connection    ${IP}    port=22
    SSHLibrary.Login    ${username}    ${pwd}

SSH_teardown
    sshlibrary.close connection

Attach Multi Ue and Start Data
	[Arguments]    ${UE_count}
	${st_ue_id}    Set Variable    1
	${en_ue_id}    Set Variable    ${UE_count}
    log to console   UE attach trigerring now...
    Wait Until Keyword Succeeds    10min    10s	  Check MIB_SIB status of GNB cell     1
    ${crnti_list}=     WTS_Runner_Keywords.MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}
    ...    ${Pdu_session_ID1}     ${nwslice_ID}
    set test variable      ${crnti_list}
    WTS_Runner_Keywords.MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     dl_rate=8
    ...    pdu_id=${Pdu_session_ID1}    trf_id=1       qfi_id=${QFI_ID}
    WTS_Runner_Keywords.MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     ul_rate=15
    ...    pdu_id=${Pdu_session_ID1}    trf_id=1       qfi_id=${qfi_id}
	Sleep    30s
	WTS_Runner_Keywords.Stop MultiUE Data Traffic for SA    ${st_ue_id}    ${en_ue_id}

O-RU reset
    Log to console   --\n RU startup\n--
    BuiltIn.Log To Console    resetting RMOD
    ${dist}    admin.get_ids_for all   RMOD    connection=nom
    FOR    ${dis}    IN    @{dist}
        ${opt}    admin.reset_unit    dist_name=${dis}    reset_type=Warm    timeout=300    connection=nom
		Log to console    RMOD reset is Done
    END

O-RU lock unlock
    Log to console  \n-- RU lock --\n
	Log to console  \n-- RU lock unlock step is completed --\n
	${dist}    admin.get_ids_for all   RMOD    connection=nom
    FOR    ${dis}    IN    @{dist}
        ${opt}    admin.lock    dist_name=${dis}    timeout=60    connection=nom
		Log to console    RMOD lock is Done for ${dis}
    END
	Log to console  \n-- RU unlock--\n
    FOR    ${dis}    IN    @{dist}
        ${opt}    admin.unlock    dist_name=${dis}    timeout=60    connection=nom
        Log to console    RMOD unlock is Done for ${dis}
    END