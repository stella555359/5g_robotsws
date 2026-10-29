*** Settings ***
Documentation   O-RU O-DU mesages excahges when RU is reset.
Library    OperatingSystem     WITH NAME    os
Library    taf.analyzer.netconf
Library    Collections
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/collect_logs.robot
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/alarm.robot
Library     ./testsuite/Bangalore/ORAN/SG04/resources/sa_cell_id.py
Library    taf.transport.ssh
Library     ./testsuite/Bangalore/ORAN/SG04/resources/deletefiles.py
Library     taf.sbts.oam.coam.admin    WITH NAME    coam
Library     taf.collectors.simple    WITH NAME    simple
Library     taf.collectors.core    WITH NAME    core
Library    taf.sw.scout    WITH NAME    scout
Library     taf.sw.dcap.rd   WITH NAME   rd
Resource    taf/rfrl/common_resources/common_step/interface.robot

Test Setup      Preconditions
Test Teardown   Test teardown
Force Tags       CRT  SBTS23R3	SBTS23R2    FL00    QCD_MN_RAN   QCP_RAN_ST
                    
*** Variables ***
&{[1][1.0] TESTCASE_2-CB008480_A-Reordering and optimization of the start-up procedure for O-RU should remain same when O-DU is restarted alone.}
...    QC_ID_FL00=QC_254690    QC_ID_SBTS24R1=QC_692704    QC_ID_SBTS23R4=QC_625838

${Fault_ID}=
${outputPath}=    /tmp/btslog2
${TIMESTAMP}=   0
${tc}=       sam
${btsid}=    964 
${distName}=    MRBTS-${btsid}/EQM-1/APEQM-1/RMOD-1  
${distName_1}=    MRBTS-${btsid}/EQM_R-4/APEQM_R-1/RMOD_R-1
${distName_2}=    MRBTS-${btsid}/EQM_R-4/APEQM_R-1/RMOD_R-1/SFP_R-1
${distName_3}=    MRBTS-${btsid}/EQM_R-4/APEQM_R-1/RMOD_R-1/FAN_R-1
${bts_id}=    0
${du_id}=    0  
${runs}=    1
${location}=    /home/ute/results
${dst_dir}=    /home/ute/Netconf
${CONFIGURATION}=    10_2_SG4MRBTS964

*** Test Cases ***
[1][1.0] TESTCASE_2-CB008480_A-Reordering and optimization of the start-up procedure for O-RU should remain same when O-DU is restarted alone.
    [Tags]    TRUNK    8480A    QCD_MN_RAN    QCP_RAN_ST
    [Teardown]    run keywords
    ...      Test teardown
    ...      Set QC_Tag
    Link SCOUT SCF to Configuration ID for Reporting
    Step1:RU reset 
    Step2:Netconf log collection 	
    Step3:Netconf Message validation

*** Keywords ***
Preconditions
    Log to console   \n--Test setup started--\n
    coam.setup_admin    bts_host=192.168.255.129
    ${sw_version}=    coam.get_sw_version
    Log to console  \n ${sw_version} \n
    coam.get_active_alarms    
    ${allowed_alarms}=    Expected_alarm
    Log To Console    ${allowed_alarms}
    delete_files_netconf
    DCAP Start   
    Log to console   \n--DCAP Started --\n
    Log to console   \n--Test Setup finished--\n

Step1:RU reset 
    Log to console    \n--Step1:RU Reset--\n 
    ${RMODS}  coam.get_ids_for_all  RMOD
    Log to console  \n--Performing RMODs reset--\n
    FOR    ${RMOD}    IN  @{RMODS}
      coam.unit_Reset_cp    dist_name=${RMOD}    reset_type=Warm    timeout=300s
    END
    Log to console  \n--Wait for O-RUs to come UP --\n
    Wait for BTS OnAir
    Log to console    \n--Step1:Passed--\n 

Step2:Netconf log collection
    Log to console   \n--Step2:Netconf log collection Started--\n
    Netconf File Collection
    sleep    120
    Log to console   --\n Netconf log collection DONE\n--

Step3:Netconf Message validation

    Log to console   --\n Step3: NETCONF LOG VERIFICATION STARTED\n--  
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
        #Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//fan-speed")}' == '50'
        #...    Append To List    ${rpcreply_fanspeed}    ${entry.message.xml.findtext(".//fan-speed")}

        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//name")}' =='N75N3N1-G-RU'
        ...    Append To List    ${rpcreply_hw}    ${entry.message.xml.findtext(".//name")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//serial-num")}' =='90008'
        ...    Append To List    ${rpcreply_hw}    ${entry.message.xml.findtext(".//serial-num")}

        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//interface-name")}' =='fheth0'
        ...    Append To List    ${rpcreply_sfp}    ${entry.message.xml.findtext(".//interface-name")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//present")}' =='true'
        ...    Append To List    ${rpcreply_sfp}    ${entry.message.xml.findtext(".//present")}

        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//build-id")}' =='7021'
        ...    Append To List    ${rpcreply_sw}    ${entry.message.xml.findtext(".//build-id")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply'
        ...     and '${entry.message.xml.findtext(".//build-name")}' == 'FJ-RU-ET1---------0087.FGF_0087'
        ...    Append To List    ${rpcreply_sw}    ${entry.message.xml.findtext(".//build-name")}
        #Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//build-name")}' =='oru-sw-r2'
        #...    Append To List    ${rpcreply_sw}    ${entry.message.xml.findtext(".//build-name")}
        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//product-code")}' =='FJRU-N75N3N1-G'
        ...    Append To List    ${rpcreply_sw}    ${entry.message.xml.findtext(".//product-code")}

        Run Keyword If    '${entry.message.type}' == 'RpcReply' and '${entry.message.xml.findtext(".//sync-state")}' =='LOCKED'
        ...    Append To List    ${rpcreply_sync}    ${entry.message.xml.findtext(".//sync-state")}

        Run Keyword If    '${entry.message.type}' == 'RpcRequest'
        ...    Append To List    ${rpc}    ${entry.message.xml.findtext(".//active-alarm-list")}
	
#       Run Keyword If    '${entry.message.type}' == 'RpcRequest' and '${entry.message.xml.findtext(".//transceiver-measurement-interval")}' =='60' 
        ...    Append To List    ${rpc_measurement}    ${entry.message.xml.findtext(".//transceiver-measurement-interval")}

        Run Keyword If    '${entry.message.type}' == 'Notification' and '${entry.message.xml.findtext(".//state")}' =='READY'
        ...    Append To List    ${notification}    ${entry.message.xml.findtext(".//state")}	
  

    END

    #Should Contain    ${rpcreply_fanspeed}    50
    Should Contain    ${rpcreply_hw}    N75N3N1-G-RU
    Should Contain    ${rpcreply_hw}    90008
    Should Contain    ${rpcreply_sfp}    fheth0
    Should Contain    ${rpcreply_sfp}   true
    Should Contain    ${rpcreply_sw}    7021
#    Should Contain    ${rpcreply_sw}    oru-sw-r1
    Should Contain    ${rpcreply_sw}    FJRU-N75N3N1-G
    Should Contain    ${rpcreply_sync}    LOCKED
#    Should Contain    ${rpc_measurement}    60
    Should Contain    ${notification}    READY       
    os.Move File    ${location}/RMOD_L-1_NetconfRpcMessageTrace.log   ${dst_dir}
    RP Settings
    Log to console   \n--STEP3: PASSED--\n
    ${dcap_log_status}=    Set Variable    1.0
    Set suite variable    ${dcap_log_status}
    Log to console	DCAP_LOG_STATUS: ${dcap_log_status}

Test teardown
    Log to console   \n--Test teardown Started--\n 
    Check BTS is OnAir
    Run Keyword If		"${sw_release}" == "None"
    ...   Log   -- RP Settings step is for reporting portal purpose only, if this step alone fails, you can update QC manually-- 	html=true
    ...   console=true
    sleep    10
    interface.Common step trigger
    Log to console   \n--Test teardown completed--\n
    Run Keyword If      "${dcap_log_status}" == "1.0"   DCAP Stop
    ...    ELSE    DCAP Stop with log Transfer


Netconf File Collection
    ${proxy}       Create Dictionary    host=10.58.238.65    user=ute    password=BT5l@bus3rl0g1n
    ${executor}    Create Dictionary    host=192.168.255.129    user=toor4nsn    password=oZPS0POrRieRtu
    ...     proxy=${proxy}
    simple.create_simple_collector
    ...    name=coredump
    ...    dir_path=/tmp/node_FHNET80/tmp
    ...    file_pattern=.*
    ...    executor=${executor}
    ...    target_file_name=coredump1.log
    core.setup_collectors    names=coredump
    sleep    30s
    core.collect_collectors    names=coredump    target_dir=/home/ute/results
    core.teardown_collectors    names=coredump
    os.Run    tar -zxvf /home/ute/results/coredump/coredump1.log.tgz -C /home/ute/results/coredump
    os.Copy File    /home/ute/results/coredump/RMOD_L-1_NetconfRpcMessageTrace.log    
                    ...    /home/ute/results/RMOD_L-1_NetconfRpcMessageTrace.log

Check BTS is OnAir
    [Documentation]    Check the BTS current status
    ${bts_status}    coam.get_bts_statuses
    Should Be Equal As Strings    ${bts_status["proceduralState"]}    OnAir
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}
    
Wait for BTS OnAir
    Log to console      \nWaiting for BTS to be OnAir
    FOR    ${a}    IN RANGE    1    10
        ${bts_status}=    coam.get_bts_statuses
        Exit For Loop IF    '${bts_status["proceduralState"]}'=='OnAir'
        Sleep    1m    reason=Wait for BTS status OnAir
    END
    ${bts_status}    coam.get_bts_statuses
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'    LOG    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail
    Log to console    \nBTS procedural state : ${bts_status["proceduralState"]}

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}


Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=${CONFIGURATION}


    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb


    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Wait Until Keyword Succeeds    2min    10s    Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}		

DCAP Start
    Log to console    \n-- Connecting to DCAP Server--\n
    rd.connect_to     host=${dcaphost}      port=${dcapport}     rd_version=${dcap_version}    username=${dcap_uname}
    ...     password=${dcap_pwd}    secure=True
    ${bts_info}=    create dictionary    host=${btshost}    port=${btsport}    username=${bts_uname}     password=${bts_pwd}
    #${gnb_custom_profile}=    Create List    condor5gSyslog
    ${output}=     rd.start_trace    tag=start_trace      duration=-1     bts=${bts_info}    tag=newtrace
    ...    gnb_trace_profile=dcap-lite-default    bts_trace_profile=dcap-lite-default
    Log to console    \n-- Started GNB Custom Traces --\n
    ${trace_d}=    Get Dictionary Values   ${output}
    ${trace_id}=    Set Variable    ${trace_d}[0]
    Log to console    \n DCAP Trace ID: ${trace_id} \n
    Set suite variable    ${trace_id}

DCAP Stop
    Log to console    \n-- Stopped DCAP Traces & Skipping log Transfer --\n
    rd.stop_trace      trace_id=${trace_id}


DCAP Stop with log Transfer
    rd.stop_trace      trace_id=${trace_id}
    Log to console    \n-- Stopped DCAP Traces & Moving files to Logs Repo --\n
    rd.get_results    result_id=${trace_id}       target_dir=/home/ute/results/${TEST_NAME}    timeout=200
    os.Run    sudo mv '/home/ute/results/${TEST_NAME}' /sharedvolume/Execution_CRT_Logs/
			
