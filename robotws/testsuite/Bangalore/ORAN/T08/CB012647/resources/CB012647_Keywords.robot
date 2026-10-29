*** Settings ***
Documentation
...   author: Radhika Putchakayala
...   contact: radhika.putchakayala@nokia.com
...   Description: Keywords file for Test Suite CB012647

Library     SSHLibrary
Library     Collections
Library     BuiltIn
Library     String
Library     taf.sbts.oam.coam.admin    WITH NAME    admin
Library     taf.collectors.simple       WITH NAME    simple
Library     taf.collectors.tcpdump    WITH NAME    tcpdump
Library		taf.collectors.core   WITH NAME   core
Library     ta5g_syslog
Library     taf.collectors.btslog      WITH NAME    btslog
Library     taf.ul.alarms_watchdog   WITH NAME    alarm

*** Variables ***
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
${alias}     Admin_1
${UE_ID1}		1
${UE_count}		6
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
${rat}		NR
${ue_id_sample}		1
${OUT_LOG_PATH}    /home/ute/results
${timeout}    700

*** Keywords ***
Collect Snapshot
	admin.collect_snapshot    target_file_name=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Snapshotfile.zip
	...			connection=${alias}

Admin_Connection
    admin.setup_admin    bts_host=${BTS_ADDRESS}	alias=${alias}

Check ActiveFaultandAlarmID
    [Arguments]    @{fault_list}
    ${alr}=     admin.get_active_alarms   connection=${alias}
    BuiltIn.log     ${alr}
    ${alr_num}=     admin.get_active_alarms_number   connection=${alias}
    BuiltIn.Log    ${alr_num}
    FOR    ${i}    IN RANGE   ${alr_num}
        BuiltIn.Log    ${alr}[${i}][faultName]
        ${Alrstring}=    Convert To String    ${alr}[${i}][alarmId]
        ${fltstring}=    Convert To String    ${alr}[${i}][faultId]
        Run keyword and continue on failure    should contain any    ${fltstring}    @{fault_list}
        Run keyword and continue on failure    should contain any    ${Alrstring}    @{fault_list}
    END

Get ActiveAlarms
    ${alr}=     admin.get_active_alarms		timeout=10		connection=${alias}
    BuiltIn.log     ${alr}
    ${alr_num}=     admin.get_active_alarms_number		timeout=10		connection=${alias}
    BuiltIn.Log    ${alr_num}

Test Teardown
    BuiltIn.Log to console  --End test--\n
    Collect Snapshot
    Get ActiveAlarms
   	Alarm monitoring
	admin.teardown_admin	${alias}

Suite_Teardown
        admin.teardown_all_aliases_for_admin
        interface.Common step trigger
		Check resource hanging
        Log to console  /n -- End of Test --/n

Suite Setup Local
    BuiltIn.log     Test Started
    ${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M
    ${CurrentDate}=    Convert to String     ${CurrentDate}
    Create Directory    ${BTS_path}/${SUITE NAME}/${CurrentDate}
    Set global variable    ${Date}    ${CurrentDate}

Test Setup
    Run    chmod 777 ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    Get ActiveAlarms

Suite Teardown Local
	BuiltIn.log    Test END

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
    ${status1}    Run    ${cmd1}

load iphyfile
    Run    chmod +x ${INSTALL_OFEGSA}
    Run    sh ${INSTALL_OFEGSA}
    Log to console    \nInstalling OFEGSA  radio

Configure Netconf Credentials
    admin.configure_netconf_accounts    unsecure_ciphering=false
    ...    authentication_method=NoAuthentication
    ...    timeout=60
    ...    connection=${alias}
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
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.99/24 dev eth3
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.3/24 dev eth3
    Run    sudo ip addr add 10.0.1.4/24 dev eth3

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
    ${alr}=     admin.get_active_alarms   connection=${alias}
    BuiltIn.log     ${alr}
    ${alr_num}=     admin.get_active_alarms_number   connection=${alias}
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
    ${file}=    Get File    ${outputfilepath}
    SSH_teardown
    [Return]    ${file}

SSH_connection
    [Arguments]    ${IP}    ${username}    ${pwd}
    SSHLibrary.Open Connection    ${IP}    port=22
    SSHLibrary.Login    ${username}    ${pwd}

SSH_teardown
    sshlibrary.close connection

UE attach and L3 Call on each cell
	Log to console    \n -- UE attach and L3 call -- \n
	@{UE_IDs}=    Create List
    FOR    ${i}    IN RANGE   1    ${UE_count}
		Append To List    ${UE_IDs}		${i}
    END
    FOR    ${i}    IN   @{UE_IDs}
    	Wait Until Keyword Succeeds    10min    10s    Check MIB_SIB status of GNB cell    ${i}
    END
    FOR    ${i}    IN   @{UE_IDs}
	WTS_Runner_Keywords.UE Register should be Successful     ${i}    ${Pdu_session_ID1}    ${nwslice_ID}    ${gw_ID3}
    END
    MultiUE Trigger DL Traffic for SA    1  10    Traffic_rate=kbps     dl_rate=25
    ...    pdu_id=${Pdu_session_ID1}     trf_id=${TRF_ID}    qfi_id=${QFI_ID}

Check BTS is OnAir

      ${bts_status}      admin.get_bts_statuses     connection=${alias}
      Wait Until Keyword Succeeds    6min     3     Should Be Equal As Strings      ${bts_status["proceduralState"]}    OnAir
      Run Keyword If      '${bts_status["proceduralState"]}'=='OnAir'     LOG     BTS procedural state is now: ${bts_status["proceduralState"]}
      ...     ELSE    fail
      Log to console      \nBTS procedural state : ${bts_status["proceduralState"]}

Expected alarm
    [Documentation]     Alarms which are ignored on runtime
    ${allowed_alarm_1}    Create alarm    alarm_id=7220     fault_id=61524    fault_name=SSH enabled
    ${allowed_alarm_2}    Create alarm    alarm_id=7220     fault_id=4654     fault_name=Ethernet port security is disabled
    ${allowed_alarm_3}    Create alarm    alarm_id=7220     fault_id=61649    fault_name=LMP access via port 443
    ${allowed_alarm_4}    Create alarm    alarm_id=7220     fault_id=4655     fault_name=Service account root access is enabled
    ${allowed_alarm_5}    Create alarm    alarm_id=7220     fault_id=61652    fault_name=R&D Service Port enabled
    ${allowed_alarm_6}    Create alarm    alarm_id=61641    fault_id=61641    fault_name=IP Traffic Capturing ongoing
    ${allowed_alarm_7}    Create alarm    alarm_id=7115     fault_id=4592     fault_name=BTS Reset Cause
    ${allowed_alarm_8}    Create alarm    alarm_id=7115     fault_id=8000     fault_name=Failure in connection between BTS and 3rd party tool
    ${allowed_alarm_9}    Create alarm    alarm_id=7102     fault_id=49       fault_name=Cell blocked
	${allowed_alarm_10}    Create alarm    alarm_id=7115     fault_id=4740     fault_name=EFaultId_ClearFaultNotifUnderMoAl
    ${allowed_alarm_11}    Create alarm    alarm_id=7115     fault_id=4681     fault_name=Sanity Check Error
    ${allowed_alarm_12}    Create alarm    alarm_id=7115     fault_id=4720
	...      fault_name=Mismatch of RU reported capabilities with static HW Validation information
	${allowed_alarm_13}    Create alarm    alarm_id=7115     fault_id=4602     fault_name=5G cell configuration mismatch
	${allowed_alarm_14}    Create alarm    alarm_id=7114     fault_id=7509
	...      fault_name=EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM
	${allowed_alarm_15}    Create alarm    alarm_id=7110     fault_id=4293     fault_name=IP Traffic Capacity Limit
	${allowed_alarm_16}    Create alarm    alarm_id=7107     fault_id=7300     fault_name=No X2 link available
    ${allowed_alarms}    Create list    ${allowed_alarm_1}    ${allowed_alarm_2}    ${allowed_alarm_3}    ${allowed_alarm_4}
    ...     ${allowed_alarm_5}  ${allowed_alarm_6}  ${allowed_alarm_7}  ${allowed_alarm_8}  ${allowed_alarm_9}  #${allowed_alarm_10}
    ...     ${allowed_alarm_11}  ${allowed_alarm_12}  ${allowed_alarm_13}  ${allowed_alarm_14}  ${allowed_alarm_15}  ${allowed_alarm_16}
    [Return]    ${allowed_alarms}


Alarm monitoring
    ${Active_alarm}    admin.get_active_alarms    connection=${alias}
    LOG     ${Active_alarm}
    ${allowed_alarms}    Expected alarm
    alarm.Watch alarms    allowed_alarms=${allowed_alarms}    connection_kwargs=${alias}
    ...    reconnect=true    log_dir=/tmp

Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
	...    /home/ute/robotws/testsuite/Bangalore/ORAN/T07/CB009447_CRT/TC1/hanging.py ${OUT_LOG_PATH}
    Run keyword if  '${rc}'=='4'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI
