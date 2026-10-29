*** Settings ***

Documentation
...   author: Challa ravali, Sreekumar Narimuri Kumaran
...   contact: challa.ravali@nokia.com
...   Description: Resource file for CB008957


Library    taf.collectors.tshark    WITH NAME    tshark
Library    taf.collectors.simple    WITH NAME    simple
Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.btslog  WITH NAME   btslog
Library    SSHLibrary
Library    Process
Library    taf.transport.ssh
Library    OperatingSystem     WITH NAME    os
Library    String      WITH NAME   str
Library    taf.ue    WITH NAME    ue
Library    ute_ue
Library    String
Library    Collections
Library    DateTime
Library     taf.hw.pdu   WITH NAME    pdu
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.converters.sherpa    WITH NAME    sherpa
Library    taf.analyzer.sherpa    WITH NAME    sherpa_analyzer
Library    taf.collectors.pmcounters    WITH NAME    PM
Library    taf.analyzer.pmcounter    WITH NAME    analyser
Library    taf.selenium.sbts    WITH NAME    soam
Library    taf.ccs.aashell     WITH NAME    cli
Library     taf.sw.scout    WITH NAME    scout
Library    taf.file.pack
Library    testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Library    testsuite/Bangalore/ORAN/resources/python/Macro/Python/bts/common/bbu.py
Library    testsuite/Bangalore/ORAN/resources/python/Macro/Python/bts/common/log.py
Library    testsuite/Bangalore/ORAN/resources/python/deletefiles.py
Library    testsuite/Bangalore/ORAN/resources/python/netconf_validation.py
Resource    testsuite/Bangalore/ORAN/resources/robot/reportingportal_Keywords.robot
Resource    testsuite/Bangalore/ORAN/resources/robot/expected_alarm.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    testsuite/Bangalore/ORAN/resources/python/Macro/bts/gnb.robot
Library     testsuite/Bangalore/ORAN/resources/python/memoryusage.py
Library     testsuite/Bangalore/ORAN/resources/python/Tshark_Validation.py
Library     testsuite/Bangalore/ORAN/resources/python/SysValidation.py


*** Variables ***
${CELL_ID}          1
${mrbts}=    MRBTS-1024/EQM-1/APEQM-1/RMOD-1
${nrcell}=    MRBTS-1024/NRBTS-1024/NRCELL-0
${ip_pdu}=    10.58.242.49
${ip_pdu_port_RMOD}=    8
@{capabilities}    Legacy_2
@{throughput_dl}=   380
@{throughput_ul}=   60
@{deviation_dl}=  100
@{deviation_ul}=  100
${packet_size}=  1400
@{UE_alias}=  UE_2
@{direction_dl}=  dl
@{direction_ul}=  ul
@{duration}=  700s
@{tcpcalltype}=    TCP
@{udpcalltype}=    UDP
@{dt_name_dl}    iperf_dl_test_2
@{dt_name_ul}    iperf-mohan_UL_2
${buffer_server}=   4M
${buffer_client}=   4M
${BTS_ADDRESS}    192.168.255.129
${BTS_USERNAME}=	toor4nsn
${BTS_PASSWORD}=	oZPS0POrRieRtu
${ADMIN_ALIAS}=    admin_1
${ADMIN_PORT}       443
${USE_SSL}        True
@{LOG_NAME_LIST}    btslog    snapshot
@{dt_name}=   iperf_dl_test
@{timeout}=      250
${tput}=   100Mbits/sec
${browser}=     Chrome
${user}=    ute
${password}=     BT5l@bus3rl0g1n
${options}=    -i eth0
${TIMESTAMP}=    0

*** Keywords ***

CB008957_Verfication of ecpri fragmentation compression section ID FCP section 9 bit mantisaa eAxC mac and vlan ID
    Start eGen logs
    DL Data Transfer TCP    ${UE_alias}    ${capabilities}    ${direction_dl}    ${throughput_dl}    ${deviation_dl}    ${timeout}
    UL Data Transfer TCP    ${UE_alias}    ${capabilities}    ${direction_ul}    ${throughput_ul}    ${deviation_ul}    ${timeout}
	sleep    60
	Clear_FHNET00_in_BTS
	Netconf File Collection
    os.Copy File    ${out}/NetconfRpcMessageTrace/RMOD_L-1_NetconfRpcMessageTrace_0.log
	...    ${out}/NetconfRpcMessageTrace/RMOD_L-1_NetconfRpcMessageTrace_1.log
    Step3: eGen and netconf logs validation    ${out}/NetconfRpcMessageTrace/RMOD_L-1_NetconfRpcMessageTrace_1.log

ORU_lock_unlock_and_Reset_and_TCP_call
    coam.setup_admin    bts_host=192.168.255.129
    sleep    80
    step2:RU lock unlock
    sleep    20
	Wait Until Keyword Succeeds    4min    10s    Check BTS is OnAir
#    DL Data Transfer TCP    ${UE_alias}    ${capabilities}    ${direction_dl}    ${throughput_dl}    ${deviation_dl}    ${timeout}
#    UL Data Transfer TCP    ${UE_alias}    ${capabilities}    ${direction_ul}    ${throughput_ul}    ${deviation_ul}    ${timeout}
    Step4: Initiate the UDP Downlink data transfer and Uplink data transfer
    sleep    20
    Step3:RU Power on/off via IP-PDU
    sleep    20
	Wait Until Keyword Succeeds    4min    10s    Check BTS is OnAir
#    DL Data Transfer TCP    ${UE_alias}    ${capabilities}    ${direction_dl}    ${throughput_dl}    ${deviation_dl}    ${timeout}
#    UL Data Transfer TCP    ${UE_alias}    ${capabilities}    ${direction_ul}    ${throughput_ul}    ${deviation_ul}    ${timeout}
    Step4: Initiate the UDP Downlink data transfer and Uplink data transfer
    step4:cell lock unlock
    sleep    20
	Wait Until Keyword Succeeds    4min    10s    Check BTS is OnAir
#    DL Data Transfer TCP    ${UE_alias}    ${capabilities}    ${direction_dl}    ${throughput_dl}    ${deviation_dl}    ${timeout}
#    UL Data Transfer TCP    ${UE_alias}    ${capabilities}    ${direction_ul}    ${throughput_ul}    ${deviation_ul}    ${timeout}
    Step4: Initiate the UDP Downlink data transfer and Uplink data transfer
    Step5:Site Reset
	Wait Until Keyword Succeeds    4min    10s    Check BTS is OnAir
#    DL Data Transfer TCP    ${UE_alias}    ${capabilities}    ${direction_dl}    ${throughput_dl}    ${deviation_dl}    ${timeout}
#    UL Data Transfer TCP    ${UE_alias}    ${capabilities}    ${direction_ul}    ${throughput_ul}    ${deviation_ul}    ${timeout}
    Step4: Initiate the UDP Downlink data transfer and Uplink data transfer

CB008957_netconf_message_timing_calculaton
    delete_files_netconf
	Clear_FHNET00_in_BTS
    Log to console   --\n RU Power off from IP PDU\n--
    pdu.setup_pdu    model=RRB    host=${ip_pdu}    alias=RRB_connection
    pdu.power_off    port=${ip_pdu_port_RMOD}    pdu_device=RRB_connection
    sleep    80
    Log to console   --\n RU Power on from IP PDU\n--
    pdu.power_on    port=${ip_pdu_port_RMOD}    pdu_device=RRB_connection
    ${power_on}=    get current date
    ${power_on_time}=    Subtract Time From Date    ${power_on}    05:30:00.000
    sleep    110
    Netconf file validation with multple names
    os.Copy File    ${output}
    ...    ${out}/NetconfRpcMessageTrace/RMOD_L-1_NetconfRpcMessageTrace_1.log
    sleep    30
    ${b}=    netconf_get_time    ${out}/NetconfRpcMessageTrace/RMOD_L-1_NetconfRpcMessageTrace_1.log    hellorequest    capability
    ${O_RU_power_on_time}=    time_diff    ${b[-1]}    ${power_on_time}
    evaluate    ${O_RU_power_on_time}<150
    delete_files_netconf
	Clear_FHNET00_in_BTS
    Log to console   --\RU reset from webEM\n--
    Step1: O-RU reset
    Netconf file validation with multple names
    os.Copy File    ${output}
    ...    ${out}/NetconfRpcMessageTrace/RMOD_L-1_NetconfRpcMessageTrace_2.log
    sleep    30
    Step2: Validate netconf message timing    ${out}/NetconfRpcMessageTrace/RMOD_L-1_NetconfRpcMessageTrace_2.log
    Start BTS logs
    Step 2: site reset
    Wait Until Keyword Succeeds    4min    10s    Check BTS is OnAir
    Stop BTS logs and check
    sleep    30


Verify CB008957_Commissioning of LTE+NR concurrent mode configuration with Band-1 and Band3 along with udp and tcp calls
    Step3: Get TsharkLogs from Remote machine
    Step4: Initiate the UDP Downlink data transfer and Uplink data transfer
    Step5: Convert pcap file from local machine     ${out}
    Step8: Get TsharkLogs from Remote machine
#    DL Data Transfer TCP    ${UE_alias}    ${capabilities}    ${direction_dl}    ${throughput_dl}    ${deviation_dl}    ${timeout}
#    UL Data Transfer TCP    ${UE_alias}    ${capabilities}    ${direction_ul}    ${throughput_ul}    ${deviation_ul}    ${timeout}
    Step10: Convert pcap file from local machine     ${out}

Test Setup
    Log to console   --Test setup--
    coam.setup_admin    bts_host=192.168.255.129
    ${sw_version}=    coam.get_sw_version
    Log to console  \n ${sw_version} \n
    btslog.create_btslog_collector
    ...    name=btslog
    ...    log_dir=/tmp/btslog2
    core.setup_collectors      names=btslog
    core.set_suite_alias      btslog
    core.start_collectors      names=btslog
    Sleep  10
    Log to console   --Setup finished--

Test Teardown
    Log to console   --Test teardown--
    interface.Common step trigger
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog      target_dir=${out}
    core.teardown_collectors      names=btslog
	Collect Snapshot

Collect Snapshot
    coam.collect_snapshot    target_file_name=${out}/Snapshotfile.zip
    ...      connection=oam

Start eGen logs
    ${proxy}       Create Dictionary    host=10.58.238.125    user=ute    password=BT5l@bus3rl0g1n
    ${executor}    Create Dictionary    host=192.168.255.129    user=toor4nsn    password=oZPS0POrRieRtu    proxy=${proxy}
    simple.create_simple_collector
    ...    name=coredump
    ...    dir_path=/tmp/node_FHNET00/tmp
    ...    file_pattern=.*
    ...    executor=${executor}
    ...    target_file_name=coredump1.log
    core.setup_collectors    names=coredump
    sleep    10s
    core.collect_collectors    names=coredump    target_dir=${out}
    core.teardown_collectors    names=coredump
    os.Run    tar -zxvf ${out}/coredump/coredump1.log.tgz -C ${out}/coredump
    Netconf File Collection
    os.Copy File    ${out}/NetconfRpcMessageTrace/RMOD_L-1_NetconfRpcMessageTrace_0.log
	...    ${out}/NetconfRpcMessageTrace/RMOD_L-1_NetconfRpcMessageTrace_1.log

	Log to console   --\n RU startup and EgenCollection \n--
    taf.transport.ssh.Connect To    10.45.150.63    ute    BT5l@bus3rl0g1n    alias=egen
    taf.transport.ssh.Send Command    sudo su    connection=egen
    taf.transport.ssh.Execute      cd /root/eGen/release    connection=egen
    ${contents}=    taf.transport.ssh.Execute      /root/egen/release/ethtool ens12f1    connection=egen
    log    ${contents}
    ${contents}=    taf.transport.ssh.Execute      /root/egen/release/ethtool ens12f0    connection=egen
    log    ${contents}
    Log to console   --\n ru START EGEN LOGS\n--
    taf.transport.ssh.Execute     sudo egen/release/egen --cores 1-4 --port 81:00.0 --capture FJTTest_2.pcap --save-n-and-quit 50000
	...		connection=egen
    sleep    100

Collect netconf logs
    ${proxy}       Create Dictionary    host=10.58.238.125    user=ute    password=BT5l@bus3rl0g1n
    ${executor}    Create Dictionary    host=192.168.255.129    user=toor4nsn    password=oZPS0POrRieRtu
    ...     proxy=${proxy}
    simple.create_simple_collector
    ...    name=coredump
    ...    dir_path=/tmp/node_FHNET00/tmp
    ...    file_pattern=.*
    ...    executor=${executor}
    ...    target_file_name=coredump1.log
    core.setup_collectors    names=coredump
    sleep    10s
    core.collect_collectors    names=coredump    target_dir=${out}
    core.teardown_collectors    names=coredump
    os.Run    tar -zxvf ${out}/coredump/coredump1.log.tgz -C ${out}/coredump
    os.Copy File    ${out}/coredump/*_NetconfRpcMessageTrace.log    ${out}/netconf/RMOD_L-1_NetconfRpcMessageTrace.log

Step3: eGen and netconf logs validation
    [Arguments]    ${netconf_file}
    os.Create Directory    ${out}/egen
    sleep    100
    taf.transport.ssh.Download File    /home/ute/FJTTest_2.pcap    /${out}/egen/FJTTest_2.pcap
    ...    connection=egen
    sleep    300
    ${a}=     Validate_Tshark    ${out}/egen    filter=oran_fh_cus.sectionId
    log    ${a}
    ${len}=    Get length  ${a}
    ${a}=     Validate_Tshark    ${out}/egen    filter=oran_fh_cus.c_eaxc_id
    log    ${a}
    ${a}=     Validate_Tshark    ${out}/egen    filter=oran_fh_cus.iq_user_data
    log    ${a}
    ${a}=     Validate_Tshark    ${out}/egen    filter=vlan.id == 1
    log    ${a}
    Log to console   \n--Validate Netconf logs--\n
    ${eaxc_id}=    netconf_get_value     ${netconf_file}     rpc    edit-config    eaxc-id
    Log to console   --\n Verifying eaxc IDs ${eaxc_id} \n--
    ${eaxc_id}=    netconf_get_value     ${netconf_file}     rpc    edit-config    eaxc-id
    ${eaxc_id}=    Convert To Dictionary    ${eaxc_id}
    ${eaxc_id}=    Get Dictionary Values    ${eaxc_id}    0
    Get From List    ${eaxc_id}    0
    Get From List    ${eaxc_id}    1
    validate_netconf_reply_message      ${netconf_file}    get    user-plane-configuration    section-type
    run keyword and continue on failure   Should not be empty    ${a}
    ${vlan_id}=    netconf_get_value     ${netconf_file}    rpc    edit-config    vlan-id
    ${vlan_id_occurance}=    Get Length    ${vlan_id}
    FOR    ${index}    IN RANGE   ${vlan_id_occurance}
        run keyword and continue on failure  Should Contain    ${vlan_id}[${index}][1]    1
    END
    ${a}=    validate_netconf_reply_message      ${netconf_file}     vlan-id    ok

step2:RU lock unlock
    Log to console  \n-- RU lock --\n
    coam.lock    dist_name=${mrbts}    timeout=60
    sleep    60
	Log to console  \n-- RU unlock--\n
    coam.unlock    dist_name=${mrbts}    timeout=120
    sleep    60
    ${mrbts_state}=    coam.Get Mrbts State
    Log to console    \MRBTS state: ${mrbts_state}
	Log to console  \n-- RU lock unlock step is completed --\n

Step3:RU Power on/off via IP-PDU
    Log to console  \n--RU powering off --\n
    pdu.setup_pdu    model=RRB    host=${ip_pdu}    alias=RRB_connection
    pdu.power_off    port=8   pdu_device=RRB_connection
    Sleep   60
	Log to console  \n--RU powering on --\n
    pdu.setup_pdu    model=RRB    host=${ip_pdu}   alias=RRB_connection
    pdu.power_on    port=8    pdu_device=RRB_connection
    sleep    100
    ${mrbts_state}=    coam.Get Mrbts State
    Log to console    \MRBTS state: ${mrbts_state}
	Log to console  \n-- RU powering off-on step is completed --\n

step4:cell lock unlock
    Log to console  \n--cell lock --\n
    coam.lock    dist_name=${nrcell}    timeout=60
    sleep    60
    Log to console  \n--cell unlock --\n
    coam.unlock    dist_name=${nrcell}    timeout=120
    sleep    60
    ${mrbts_state}=    coam.Get Mrbts State
    Log to console    \MRBTS state: ${mrbts_state}
	Log to console  \n-- cell lock unlock step is completed --\n

Step5:Site Reset
    Log to console  \n--Site_reset--\n
    coam.reset    timeout=400    connection=default
    sleep    120
    ${mrbts_state}=    coam.Get Mrbts State
    Log to console    \MRBTS state: ${mrbts_state}
	Log to console  \n-- Site_reset step is completed --\n

DL Data Transfer TCP
    [Arguments]    ${UE_alias}    ${capabilities}    ${direction}    ${throughput}    ${deviation}    ${timeout}
    ...     ${check_tpt}=True    ${check_cell}=True   ${wait_for_transfer}=True
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}
	log 	${throughput}
	log		${deviation}
	log 	${check_cell}
    Log to console    \nStarting DL data transfer
    ta_ultracaller.start_data_transfer  ${UE_alias}   ${tcpcalltype}    direction=${direction}
    sleep    60
    Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction}
    ...    ${timeout}
    ...    AND    Sleep    150
    ...    AND    Log to console    \nData transfer completed
    Run Keyword If    '${check_tpt}'=='True'    Run keyword and continue on failure    ta_ultracaller.Calculate Thrughtput    ue_alias=${UE_alias}
    ...     direction=${direction_dl}    thrughtput=${throughput_dl}    deviation=${deviation_dl}

UL Data Transfer TCP
    [Arguments]    ${UE_alias}    ${capabilities}    ${direction}    ${throughput}    ${deviation}    ${timeout}
    ...     ${check_tpt}=True    ${check_cell}=True   ${wait_for_transfer}=True
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}
	log 	${throughput}
	log		${deviation}
	log 	${check_cell}
    Log to console    \nStarting UL data transfer
    ta_ultracaller.start_data_transfer  ${UE_alias}   ${tcpcalltype}    direction=${direction}
    sleep    60
    Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction}
    ...    ${timeout}
    ...    AND    Sleep    150
    ...    AND    Log to console    \nData transfer completed
    Run Keyword If    '${check_tpt}'=='True'    Run keyword and continue on failure    ta_ultracaller.Calculate Thrughtput    ue_alias=${UE_alias}
    ...     direction=${direction_ul}    thrughtput=${throughput_ul}    deviation=${deviation_ul}

Step2: Validate netconf message timing
    [Arguments]    ${netconf_file}
    ${a}=    netconf_get_time    ${netconf_file}    rpc    reset
    ${b}=    netconf_get_time    ${netconf_file}    hellorequest    capability
    ${O_RU_reset_time}=    time_diff    ${b[-1]}    ${a[-1]}
    evaluate   ${O_RU_reset_time}<=150
    ${a}=    netconf_time_diff    ${netconf_file}    rpc    create-subscription
    FOR    ${i}    IN   ${a[0]}
		Log    ${i}
		evaluate    ${i[-1]}<=4
	END
    ${a}=    netconf_time_diff    ${netconf_file}    rpc    supervision-watchdog-reset
    FOR    ${i}    IN   ${a[0]}
        Log    ${i}
        evaluate    ${i[-1]}<=2
	END
    ${a}=    netconf_time_diff    ${netconf_file}    rpc    get
    FOR    ${i}    IN   ${a[0]}
        Log    ${i}
        evaluate    ${i[-1]}<=2
	END
    ${a}=    netconf_time_diff    ${netconf_file}    rpc    edit-config
    FOR    ${i}    IN   ${a[0]}
        Log    ${i}
        evaluate    ${i[-1]}<=10
	END

Netconf File Collection
    ${proxy}       Create Dictionary    host=10.58.238.125    user=ute    password=BT5l@bus3rl0g1n
    ${executor}    Create Dictionary    host=192.168.255.129    user=toor4nsn    password=oZPS0POrRieRtu
    ...     proxy=${proxy}
    simple.create_simple_collector
    ...    name=coredump
    ...    dir_path=/tmp/node_FHNET00/tmp
    ...    file_pattern=.*
    ...    executor=${executor}
    ...    target_file_name=coredump1.log
    core.setup_collectors    names=coredump
    sleep    30
    core.collect_collectors    names=coredump    target_dir=${out}
    core.teardown_collectors    names=coredump
    os.Run    tar -zxvf ${out}/coredump/coredump1.log.tgz -C ${out}/coredump
    os.Copy Files    ${out}/coredump/*_NetconfRpcMessageTrace_0.log
	...    ${out}/NetconfRpcMessageTrace
    sleep    100

Start BTS logs
    [Documentation]     Starts BTS log in testpc
    os.Run     killall btslog
    btslog.create_btslog_collector    name=btslog
    core.setup_collectors    names=btslog
    core.set_suite_alias    btslog
    core.start_collectors    names=btslog

Stop BTS logs and check
    [Documentation]     Stops BTS log and check for crash
    core.stop_collectors    names=btslog
    core.collect_collectors    names=btslog     target_dir=${out}
    core.teardown_collectors    names=btslog
    ${result}=    validate_syslog_file_contents        search_string=TL1TotalNumCellSlots = 96
	...     dir_path=${out}/btslog
    ${cellslot_len}=    Get Length    ${result}
    Run Keyword And Continue On Failure    evaluate    ${cellslot_len}>0
    ${result}=    validate_syslog_file_contents    search_string=subpools:4
	...     dir_path=${out}/btslog
    ${subpool_len}=    Get Length    ${result}
    Run Keyword And Continue On Failure    evaluate    ${subpool_len}>0
    ${result}=    validate_syslog_file_contents    search_string=TMaxNumberOfNrCellGroup
	...     dir_path=${out}/btslog
    ${max_cellgroup_len}=    Get Length    ${result}
    Run Keyword And Continue On Failure    evaluate    ${max_cellgroup_len}>0
	${result}=    validate_syslog_file_contents    search_string="dlSubcellType":"SUBCELLTYPE_A4"
	...     dir_path=${out}/btslog
    ${subcell_type}=    Get Length    ${result}
    Run Keyword And Continue On Failure    evaluate    ${subcell_type}>0

Step2: Start sherpa logs
    soam.enable_virtual_display
    soam.login     https://192.168.255.129     Nemuadmin     nemuuser    browser=Chrome
    Run keyword and Ignore Error     soam.deactivate_internal_trace   timeout=60
    soam.configure_logging_agent     source_ip=10.58.239.191    dscp=15    uplane_destination=10.58.238.125:5678     timeout=20
    sleep    30
    soam.activate_internal_trace     timeout=60
    soam.start_l2_hi_pdcp_sherpa_trace_and_return_result       timeout=30
    soam.start_l2_hi_rlc_sherpa_trace_and_return_result       gnb_type=Classical    timeout=50
    soam.start_l2_lo_sherpa_trace_and_return_result      timeout=30
    soam.start_l2_ps_sherpa_trace_and_return_result     timeout=30
    soam.logout
    soam.disable_virtual_display
    soam.close_browser

Step3: Get TsharkLogs from Remote machine
    ${executor_oam_vm}=  Create Dictionary
    ...  host=10.58.238.125
    ...  user=ute
    ...  password=BT5l@bus3rl0g1n
    tshark.Create Tshark Collector
    ...     name=tshark1
    ...     options=-i eth0
    ...     executor=${executor_oam_vm}
    core.setup_collectors    names=tshark1
    core.set_suite_alias	tshark1
    core.start_collectors    names=tshark1

Step4: Initiate the UDP Downlink data transfer and Uplink data transfer
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}
    Log to console    \nattach is success
    Log to console    \nStarting data transfer
    Run Keyword And Continue On Failure    ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=${direction_dl}
    sleep    300
    Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_dl}
    ...     thrughtput=${throughput_dl}    deviation=${deviation_dl}
    Run Keyword And Continue On Failure    ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=${direction_ul}
    sleep    300
    Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_ul}
    ...     thrughtput=${throughput_ul}    deviation=${deviation_ul}
    Log to console    \nWaiting for data transfer
    Log to console    \nData transfer completed

Step5: Convert pcap file from local machine
	[Arguments]    ${out}
    core.stop_collectors	tshark1
    core.collect_collectors    names=tshark1	target_dir=${out}
    core.teardown_collectors    names=tshark1

Step8: Get TsharkLogs from Remote machine
    ${executor_oam_vm}=  Create Dictionary
    ...  host=10.58.238.125
    ...  user=ute
    ...  password=BT5l@bus3rl0g1n
    tshark.Create Tshark Collector
    ...     name=tshark3
    ...     options=-i eth0
    ...     executor=${executor_oam_vm}
    core.setup_collectors    names=tshark3
    core.set_suite_alias	tshark3
    core.start_collectors    names=tshark3

Step10: Convert pcap file from local machine
	[Arguments]    ${out}
    core.stop_collectors	tshark3
    core.collect_collectors    names=tshark3	target_dir=${out}
    core.teardown_collectors    names=tshark3

Check BTS is OnAir
    [Documentation]  ... checking BTS status
    coam.Setup_Admin    bts_host=192.168.255.129    alias=oam
    Log To Console   \n BTS is Connected
    ${bts_status}=  coam.get_bts_statuses  connection=${connection}
    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'
    ...    Log To Console    \nBTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
	coam.teardown    oam
    Log To Console    \nBTS IS Disconnected

SSH_connection
    [Arguments]    ${IP}    ${username}    ${pwd}
    SSHLibrary.Open Connection    ${IP}    port=22
    SSHLibrary.Login    ${username}    ${pwd}

SSH_teardown
    SSHLibrary.close connection

Clear_FHNET00_in_BTS
    log to console    \nClear_FHNET00_in_BTS
    SSH_connection    ${BTS_ADDRESS}    ${BTS_USERNAME}    ${BTS_PASSWORD}
    SSHLibrary.write    cd /tmp/node_FHNET00/tmp
    ${command}=    set variable    rm -rf  RMOD_L*
    SSHLibrary.write    ${command}
    sleep    20s
    SSH_teardown

Step1: O-RU reset
    Log to console   --\n RU startup\n--
    BuiltIn.Log To Console    resetting RMOD
    ${dist}    coam.get_ids_for all   RMOD    connection=oam
    FOR    ${dis}    IN    @{dist}
        ${opt}    coam.reset_unit    dist_name=${dis}    reset_type=Warm    timeout=300    connection=oam
        ${optt}    get from list    ${opt}    1
        Run keyword if    '${optt['resultNode']['parameters']['status']}'=='Succeeded'
        ...    BuiltIn.Log to console    RMOD reset is Done
        ...    ELSE    fail
    END

Step 2: site reset
    Log to console   --\n site reset \n--
    BuiltIn.Log To Console    resetting site
    coam.reset_site	timeout=300
    ...		connection=oam    wait_for_reconnection=True   detailed_output=False
    ...         graceful_cell_shutdown=True    reset_without_ru=True

Netconf file validation with multple names
	Collect Snapshot
	taf.file.pack.Extract    path=${out}/Snapshotfile.zip    output_dir=${out}/Snapshotfile_unzip
	${status}    ${result}=    Run Keyword And Ignore Error
	...    os.Run And Return Rc And Output
	...    find ${out}/Snapshotfile_unzip -name "*RPC.log"
	# result[0] = rc
	# result[1] = stdout
	${rc}=    Set Variable    ${result}[0]
	${output}=    Set Variable    ${result}[1]
	IF    '${output}' == ''
		${rc2}    ${output}=    os.Run And Return Rc And Output
		...    find ${out}/${snapshotfilename_unzip} -name "*NetconfRpcMessageTrace.log"
	END
	Run Keyword If    '${output}' == ''    Log To Console    No matching log files found!    WARN
	Log    Found log files:\n${output}
	Set Global Variable    ${output}