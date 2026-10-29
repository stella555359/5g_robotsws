*** Settings ***
Documentation   CB008480_E: O-RU delay profile Handling with minimum FH latency.
Library    OperatingSystem     WITH NAME    os
Library    taf.analyzer.netconf     WITH NAME    netconf
Library    Collections
Library    taf.pdu    WITH NAME    pdu
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/collect_logs.robot
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/alarm.robot
Library	   ./testsuite/Bangalore/ORAN/SG04/resources/keywords.py
Library    ./testsuite/Bangalore/ORAN/SG04/resources/sa_cell_id.py
Library    ./testsuite/Bangalore/ORAN/SG04/resources/deletefiles.py
Library    taf.transport.ssh
Library    SSHLibrary    WITH NAME    sshlib
Library    taf.selenium.gnb.oam.coam.classical    WITH NAME    classical
Library    taf.gnb.oam.coam.admin    WITH NAME    coam
Library    taf.selenium.sbts    WITH NAME    soam
Library    taf.selenium.mobile.sbts
Library    taf.sbts.oam.coam.admin
Library    taf.collectors.simple    WITH NAME    simple
Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.core   WITH NAME   core
Resource   taf/rfrl/common_resources/common_step/interface.robot

Test Setup      Preconditions
Test Teardown   Test teardown
Force Tags       CRT  SBTS22R3  SBTS22R4  FL00    QCD_MN_RAN   QCP_RAN_ST 

*** Variables ***
&{[1][1.0] TEST CASE_1 - CB008480_E - O-RU Delay profile handling during the start-up with minimum fronthaul latency.}
...   QC_ID_SBTS22R3=QC_299155    QC_ID_FL00=QC_271887
${Fault_ID}=
${outputPath}=    /tmp/btslog2
${TIMESTAMP}=   0
${tc}=       shalu
${btsid}=    578 
${distName}=    MRBTS-${btsid}/EQM-1/APEQM-1/RMOD-1  
${distName_1}=    MRBTS-${btsid}/EQM_R-4/APEQM_R-1/RMOD_R-1
${distName_2}=    MRBTS-${btsid}/EQM_R-4/APEQM_R-1/RMOD_R-1/SFP_R-1
${distName_3}=    MRBTS-${btsid}/EQM_R-4/APEQM_R-1/RMOD_R-1/FAN_R-1
${bts_id}=    0
${du_id}=    0  
${runs}=    1
${location}=    /home/ute/results
     

*** Test Cases ***
[1][1.0] TEST CASE_1 - CB008480_E - O-RU Delay profile handling during the start-up with minimum fronthaul latency.
    #[Tags]    CIT    QCD_MN_RAN    QCP_RAN_ST
    #[Teardown]    run keywords
    #...      Set QC_Tag 
    Step1:Netconf Log Collection 	
    Step2:Netconf Message Validation
    
*** Keywords ***
Preconditions
    Log to console   \n--TEST SETUP STARTED--\n
    coam.setup_admin	bts_host=192.168.255.129
    ${sw_version}=    coam.get_sw_version
    Log to console  \n ${sw_version} \n
    Verify gNB is onAir
    coam.get_active_alarms 
    delete_files_netconf
    ${allowed_alarms}=    Expected_alarm
    Log To Console    ${allowed_alarms}
    Log to console   \n--TEST SETUP COMPLETED--\n
    sleep    5s

Step1:Netconf log collection
    Log to console   \n--STEP_1: NETCONF LOG COLLECTION STARTED--\n
    Netconf File Collection
    sleep    120
    Log to console   --\n STEP_1 PASSED\n--


Step2:Netconf Message validation
    Log to console   --\n STEP_3: NETCONF LOG VERIFICATION STARTED\n--  
    @{entries}=    Get NETCONF Log Entries
    ...    file_path=/home/ute/results/RMOD_L-1_NetconfRpcMessageTrace.log
	@{rpc}=    create List
        @{rpc_measurement}=    create List
        @{notification}=    create List
	@{rpcreply_fanspeed}=    create List	
        @{rpcreply_hw}=    create List	
        @{rpcreply_sfp}=    create List
        @{rpcreply_sw}=    create List
        @{rpcreply_sync}=    create List
        @{rpcreply_sfp}=    create List
        @{rpcreply_sfp}=    create List
        @{rpcreply_delay}=    create List
    FOR    ${entry}    IN    @{entries}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//fan-speed")}' == '50'
        ...    Append To List    ${rpcreply_fanspeed}    ${entry.message.xml.findtext(".//fan-speed")}

        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//name")}' =='AZQI'
        ...    Append To List    ${rpcreply_hw}    ${entry.message.xml.findtext(".//name")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//serial-num")}' =='S01234567'
        ...    Append To List    ${rpcreply_hw}    ${entry.message.xml.findtext(".//serial-num")}

        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//interface-name")}' =='GigabitEthernet1'
        ...    Append To List    ${rpcreply_sfp}    ${entry.message.xml.findtext(".//interface-name")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//present")}' =='true'
        ...    Append To List    ${rpcreply_sfp}    ${entry.message.xml.findtext(".//present")}

        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//build-id")}' =='1'
        ...    Append To List    ${rpcreply_sw}    ${entry.message.xml.findtext(".//build-id")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//build-name")}' =='oru-sw-r1'
        ...    Append To List    ${rpcreply_sw}    ${entry.message.xml.findtext(".//build-name")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//product-code")}' =='475243A'
        ...    Append To List    ${rpcreply_sw}    ${entry.message.xml.findtext(".//product-code")}

        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//sync-state")}' =='LOCKED'
        ...    Append To List    ${rpcreply_sync}    ${entry.message.xml.findtext(".//sync-state")}

        Run Keyword If    '${entry.message.type}' == 'RpcRequest'
        ...    Append To List    ${rpc}    ${entry.message.xml.findtext(".//active-alarm-list")}
	
        Run Keyword If    '${entry.message.type}' == 'RpcRequest' and '${entry.message.xml.findtext(".//transceiver-measurement-interval")}' =='300' 
        ...    Append To List    ${rpc_measurement}    ${entry.message.xml.findtext(".//transceiver-measurement-interval")}

        Run Keyword If    '${entry.message.type}' == 'Notification' and '${entry.message.xml.findtext(".//state")}' =='READY'
        ...    Append To List    ${notification}    ${entry.message.xml.findtext(".//state")}	

        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//bandwidth")}' =='50000'
        ...    Append To List    ${rpcreply_delay}    ${entry.message.xml.findtext(".//bandwidth")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//t2a-min-up")}' =='134000'
        ...    Append To List    ${rpcreply_delay}    ${entry.message.xml.findtext(".//t2a-min-up")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//t2a-max-up")}' =='345000'
        ...    Append To List    ${rpcreply_delay}    ${entry.message.xml.findtext(".//t2a-max-up")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//t2a-min-cp-dl")}' =='259000'
        ...    Append To List    ${rpcreply_delay}    ${entry.message.xml.findtext(".//t2a-min-cp-dl")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//t2a-max-cp-dl")}' =='470000'
        ...    Append To List    ${rpcreply_delay}    ${entry.message.xml.findtext(".//t2a-max-cp-dl")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//tcp-adv-dl")}' =='125000'
        ...    Append To List    ${rpcreply_delay}    ${entry.message.xml.findtext(".//tcp-adv-dl")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//ta3-min")}' =='50000'
        ...    Append To List    ${rpcreply_delay}    ${entry.message.xml.findtext(".//ta3-min")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//ta3-max")}' =='171000'
        ...    Append To List    ${rpcreply_delay}    ${entry.message.xml.findtext(".//ta3-max")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//t2a-min-cp-ul")}' =='125000'
        ...    Append To List    ${rpcreply_delay}    ${entry.message.xml.findtext(".//t2a-min-cp-ul")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//t2a-max-cp-ul")}' =='336000'
        ...    Append To List    ${rpcreply_delay}    ${entry.message.xml.findtext(".//t2a-max-cp-ul")}  

    END

    Should Contain    ${rpcreply_fanspeed}    50
    Should Contain    ${rpcreply_hw}    AZQI
    Should Contain    ${rpcreply_hw}    S01234567 
    Should Contain    ${rpcreply_sfp}    GigabitEthernet1
    Should Contain    ${rpcreply_sfp}   true
    Should Contain    ${rpcreply_sw}    1
    Should Contain    ${rpcreply_sw}    oru-sw-r1
    Should Contain    ${rpcreply_sw}    475243A
    Should Contain    ${rpcreply_sync}    LOCKED
    Should Contain    ${notification}    READY
    Should Contain    ${rpcreply_delay}    50000
    Should Contain    ${rpcreply_delay}    134000
    Should Contain    ${rpcreply_delay}    345000 
    Should Contain    ${rpcreply_delay}    259000 
    Should Contain    ${rpcreply_delay}    470000 
    Should Contain    ${rpcreply_delay}    125000 
    Should Contain    ${rpcreply_delay}    50000
    Should Contain    ${rpcreply_delay}    171000 
    Should Contain    ${rpcreply_delay}    125000 
    Should Contain    ${rpcreply_delay}    336000       
    os.Move File    ${location}/RMOD_L-1_NetconfRpcMessageTrace.log   ${dst_dir}
    #RP Settings
    Log to console   --\nSTEP_2 PASSED\n--

Netconf File Collection
    ${proxy}       Create Dictionary    host=10.45.151.29    user=ute    password=BT5l@bus3rl0g1n
    ${executor}    Create Dictionary    host=192.168.255.129    user=toor4nsn    password=oZPS0POrRieRtu
    ...     proxy=${proxy}
    simple.create_simple_collector
    ...    name=coredump
    ...    dir_path=/tmp/node_FHNET00/tmp
    ...    file_pattern=.*
    ...    executor=${executor}
    ...    target_file_name=coredump1.log
    core.setup_collectors    names=coredump
    #core.start_collectors    names=coredump
    sleep    30s
    #core.stop_collectors    names=coredump
    core.collect_collectors    names=coredump    target_dir=/home/ute/results
    core.teardown_collectors    names=coredump
    os.Run    tar -zxvf /home/ute/results/coredump/coredump1.log.tgz -C /home/ute/results/coredump
    os.Copy File    /home/ute/results/coredump/RMOD_L-1_NetconfRpcMessageTrace.log    /home/ute/results/RMOD_L-1_NetconfRpcMessageTrace.log


Test teardown
    #[Arguments]    ${outputPath}=/tmp/btslog2 
    Log to console   --\n TEST TEARDOWN STARTED\n-- 
    Verify gNB is onAir
    sleep    60
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    interface.Common step trigger
    Log to console   --\n TEST TEARDOWN COMPLETED \n--
        
