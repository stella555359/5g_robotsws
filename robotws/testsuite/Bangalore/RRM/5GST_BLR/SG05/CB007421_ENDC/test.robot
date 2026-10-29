*** Settings ***
Library     taf.sw.dcap.rd		WITH NAME	DCAP

*** Variables ***

${DCAP_host}    10.41.209.121
${DCAP_port}    443
${bts_id}   252
${username}   dcapuser
${password}    dcapadmin!

${gnb_ip}           10.41.211.251
${bts_username}		Nemuadmin
${bts_password}		nemuuser
${TS_CASE_LOG_PATH}    testsuite/Bangalore/RRM/5GST_BLR/SG05/CB007421_ENDC/Logs


${YOUR_HOST_IP}			   		   10.41.209.202
${uepc_default_ip}                 10.41.209.202
${uepc_default_username}           inbabtslabuser
${uepc_default_password}           BT5l@bus3rl0g1n
${uepc_default_domain}             NOKLAB
${OUT_PC_IP_LIST}                  10.41.209.202


*** Keywords ***
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\start_stop DCAP\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Start DCAP log

    DCAP.connect_to    host=${DCAP_host}     port=${DCAP_port}    username=${username}    password=${password}     secure=${True}
    &{hostinfo}   create dictionary  host=${gnb_ip}    port=443    username=${bts_username}    password=${bts_password}
    @{gnb_custom_profile}=    Create List    cp_5g
    @{enb_custom_profile}=    Create List    condor4gAa    condor4gSyslog
    @{bts_custom_profile}=    Create List    SCF    Immediate Snapshot
    ${output}    DCAP.start_trace    duration=-1    bts=${hostinfo}    
	...    enb_custom_profile=@{enb_custom_profile}    gnb_custom_profile=@{gnb_custom_profile}    
	...    bts_custom_profile=@{bts_custom_profile}
    ${output}    DCAP.start_trace    duration=-1    bts=${hostinfo}    gnb_custom_profile=@{gnb_custom_profile}    
	...    bts_custom_profile=@{bts_custom_profile}
    log to console    ${\n}DCAP Started......${output}
    BuiltIn.Sleep    5m
    ${trace_id} =   Get From Dictionary   ${output}   id
    set Global variable    ${trace_id}

Stop DCAP Log
    dcap.stop_trace    trace_id=${trace_id}
    BuiltIn.Sleep    5m
    LogToConsole    ${trace_id}
    dcap.get_results    result_id=${trace_id}    target_dir=/home/ute/robotws/testsuite/Bangalore/RRM/5GST_BLR/SG05/CB007421_ENDC/Logs   
	...    timeout=200

