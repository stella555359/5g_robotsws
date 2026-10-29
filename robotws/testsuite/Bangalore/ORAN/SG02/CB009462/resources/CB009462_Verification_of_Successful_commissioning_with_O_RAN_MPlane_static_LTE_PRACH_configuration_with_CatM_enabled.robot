*** Settings ***

Documentation
...   author: Ravali challa
...   contact: challa.ravali@nokia.com
...   Description: Test case for CB009462

Library    SSHLibrary
Library    Process
Library    taf.transport.ssh
Library    ute_ue
Library    OperatingSystem
Library    String
Library    Collections
Library    taf.nms.netact
Library    DateTime
Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.btslog  WITH NAME   btslog
Library    OperatingSystem     WITH NAME    os
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.sw.scout    WITH NAME    scout
Library     taf.sw.dcap.rd		WITH NAME	  dcap
Library    taf.collectors.simple    WITH NAME    simple

Library     ./testsuite/Bangalore/ORAN/resources/python/netconf_validation.py
Library           testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_ultracaller

#Resource   /home/ute/MN/UTE/robotlte/testsuite/WMP/GVe/Bangalore/SG03/CP-KPI/CATM/LTE_4040/ue_related.robot

*** Variables ***
&{CB009462_Verification of Successful commissioning of O-RAN with O-RAN M-Plane static LTE PRACH configuration with Cat-M enabled}    
...     QC_ID_SBTS00=QC_824383
#QC[1]Test Case-13 CB009462_Verification of Successful commissioning of O-RAN with O-RAN M-Plane static LTE PRACH configuration with Cat-M enabled

${SCF_PATH}         ${CURDIR}
${BTS_ADDRESS}    192.168.255.129
${ADMIN_ALIAS}=    oam
${ADMIN_PORT}       443
${USE_SSL}        True
${scf_file_preconditions}    ${CURDIR}/scf.xml
${param}    actCatM  
${param_value1}    true
${param_value2}    false
${param_dist_name}    MRBTS-9/LNBTS-2328/LNCEL-0/LNCEL_FDD-0
 
*** Variables ***
#########LTE5320 Commissioning Related Variables########################
${uepc_Log_path}            C://Users/inbabtslabuser/
${OUT_LOG_PATH}=     /home/ute/logs/
${RESOURCES}=              ${CURDIR}
${REMOTE_HOST}             127.0.0.1
${REMOTE_USER}             ute
${REMOTE_PASSWORD}         BT5l@bus3rl0g1n
${REMOTE_HOST_PROMPT}      \$
${ENB_IP}                  192.168.255.1
${ENB_USER}                toor4nsn
${ENB_PASSWORD}            oZPS0POrRieRtu
${ENB_SSH_PORT}            22
${BTS_PORT}       443
${ABSTRACT_LIB_CONFIG}=    ${CURDIR}{/}ta_ue_config.yml
${node_type}=    enb
${node_id}=    ${0}

################################Declaring Required UE Variables#######################################
### LEGACY ###
@{UE_alias1}=    LEGACY_1
@{capabilities1}=    LEGACY_1
@{direction_dl}=    dl
@{direction_ul}=    ul
@{deviation}=    9
@{throughput_dl}=    76
@{throughput_dl1}=    22
@{throughput_dl2}=    46     # for 15Mhz Extreme Scenario
@{throughput_ul}=    28      # for 15Mhz UL normal Legacy Thpt expected value
@{throughput_ul1}=    20     # for 10Mhz UL robust Legacy Thpt expected value
@{throughput_ul2}=    26      # for 20Mhz Ul extreme Scenario
@{throughputt_dl1}=    80
@{throughputt_dl11}=    62
@{throughputt_dl12}=    20
@{throughputt_dl13}=    40
@{throughputt_dl14}=    40
@{data_transfer_protocol}=    UDP
@{timeout}=    60

## #CATM ###
${UE_CATM}=              CatM
${UE_CATM2}=              catm2
${UE_CAPABILITIES_CATM}=        CATM
${UE_CAPABILITIES_CATM2}=        catm2
${CATM_UE_CAPABILITIES}=        catm2
${CALL_DL_BANDWIDTH_CATM}=      60Kbits/sec
${CALL_DL1_BANDWIDTH_CATM}=      8Kbits/sec
${CALL_DL3_BANDWIDTH_CATM}=      12Kbits/sec
${CALL_DL_BANDWIDTH_CATMM}=      76Kbits/sec
${CALL_UL_BANDWIDTH_CATM}=      80Kbits/sec
${CALL_UL1_BANDWIDTH_CATM}=      20Kbits/sec
${CALL_UL2_BANDWIDTH_CATM}=      8Kbits/sec


######SanityCatm Test Variables################
# Test variables
${CALL_UL_BANDWIDTH}=    26Kbits/sec
${CALL_DL_BANDWIDTH}=    20Kbits/sec
${CALL_UL_BANDWIDTH_3MHz}=    600Kbits/sec
${CALL_DL_BANDWIDTH_3MHz}=    200Kbits/sec
${Expected_CALL_DL_BANDWIDTH}=    20Kbits/sec
${Expected_CALL_UL_BANDWIDTH}=    26Kbits/sec
${Expected_CALL_DL_BANDWIDTH_3MHz}=    170kbits/sec
${Expected_CALL_UL_BANDWIDTH_3MHz}=    250Kbits/sec
${WAIT_IDLE}=            180s
# UEs usage
${USE_LEGACY}=           1
${USE_NBIOT}=            1
${UE_LEG}=               Legacy
${LOOP_ATTACH}=          10


############LTE Test Variables################
######## UE PC Details########
${YOUR_HOST_IP}			           10.53.188.179
${uepc_default_ip}                 10.53.188.179
${uepc_default_username}           inbabtslabuser
${uepc_default_password}           BT5l@bus3rl0g1n
${uepc_default_domain}             NOKLAB
${OUT_PC_IP_LIST}                  10.41.209.231
${local_file_path}                 /home/ute/logs
${dcap_unzip_file_path}            /home/ute/logs/dcap
${dcap_dirname}                    /home/ute/logs

#####DCAP Server Details################
${DCAP_host}    10.41.209.118
${DCAP_port}    443
${bts_id}   9
${username}   utfuser
${password}    utfadmin!

${BTS_MPLANE}=           10.53.188.246
${bts_username}		Nemuadmin
${bts_password}		nemuuser
${TS_CASE_LOG_PATH}    "/home/ute/results/dcap"


##################
# UE Traffic
##################
${TPUT_REPET_CATM_DL}=  10Kbits/sec
${BW_REPET_CATM_DL}=    10Kbits/sec

#######################LTE5320 CatM BG95 Device Related Variables#######################################
${UE_CATM1}=              catm         ### LTE 5320 RAI Activation Scenario
${UE_CAPABILITIES_CATM1}=        catm


*** Keywords ***

CB009462_Verification of Successful commissioning of O-RAN with O-RAN M-Plane static LTE PRACH configuration with Cat-M enabled
	Perform actcatM parameter recommissioning    ${param_value1}              #step1
	Start DCAP log
	LTE wideband and catM call                                                #step2,3
	Collect netconf logs
	Verify static PRACH config from Netconf logs   ${out}/RMOD_L-1_NetconfRpcMessageTrace.log             #static PRACH validation
	Stop DCAP Log
	Perform actcatM parameter recommissioning    ${param_value2}
    LTE wideband call with legacy UE
	#Verify cell status and unexpected alarms
	
LTE wideband call with legacy UE
    log to console  reserving UEs...
    operatingsystem.Set Environment Variable    ABSTRACT_LIB_CONFIG    ${ABSTRACT_LIB_CONFIG}
    log    ${ABSTRACT_LIB_CONFIG}
    ${ue_details1}=    ta_ultracaller.Require_ue    ${UE_alias1}    ${capabilities1}
    ute_ue.require ue  ${UE_CATM2}  capabilities=catm2
    operatingsystem.Set Environment Variable    ABSTRACT_LIB_CONFIG    ${ABSTRACT_LIB_CONFIG}
    log    ${ABSTRACT_LIB_CONFIG}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias1}
	ute_ue.detach ue  ${UE_CATM2}
    sleep    40s
	Set To Dictionary    ${ue_details1['LEGACY_1']['CONSTRUCTOR_PARAMETERS']['configuration']['data_transfer']}
    ...    iperf_udp='-p:5069 -b:82M -l:1024 -t:60 -i:1'
    log    ${ue_details1}
    log to console    Attach Legacy1 UE...
    operatingsystem.Set Environment Variable    ABSTRACT_LIB_CONFIG    ${ABSTRACT_LIB_CONFIG}
    log    ${ABSTRACT_LIB_CONFIG}
    ta_ultracaller.Attach UE      ue_alias=${UE_alias1}
    sleep    20s
    log to console  Calculating Max DL THroughput Achieved on Single Legacy Device....
    ta_ultracaller.start_datatransfer    ue_alias=${UE_alias1}    direction=${direction_dl}    protocoltype=${data_transfer_protocol}
    sleep  50
    ta_ultracaller.await_data_transfer_finish    ${UE_alias1}    ${direction_dl}    ${timeout}
    sleep  100
    ${Result}=    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias1}    direction=${direction_dl}
    ...    thrughtput=${throughputt_dl1}    deviation=${deviation}
    ${Value}=    get from dictionary    ${Result['${UE_alias1[0]}']}    tputvalue
    log to console  Max DL Throughput on Single Legacy Device is ${Result['LEGACY_1']['tputvalue']}
	${status}=    BuiltIn.Evaluate      ${Value}>=76
	Run keyword And Continue On Failure		Should Be True    ${status}
	
LTE wideband and catM call
    log to console  reserving UEs...
    operatingsystem.Set Environment Variable    ABSTRACT_LIB_CONFIG    ${ABSTRACT_LIB_CONFIG}
    log    ${ABSTRACT_LIB_CONFIG}
    ${ue_details1}=    ta_ultracaller.Require_ue    ${UE_alias1}    ${capabilities1}
    ute_ue.require ue  ${UE_CATM2}  capabilities=catm2
    operatingsystem.Set Environment Variable    ABSTRACT_LIB_CONFIG    ${ABSTRACT_LIB_CONFIG}
    log    ${ABSTRACT_LIB_CONFIG}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias1}
	ute_ue.detach ue  ${UE_CATM2}
    sleep    40s
	Set To Dictionary    ${ue_details1['LEGACY_1']['CONSTRUCTOR_PARAMETERS']['configuration']['data_transfer']}
    ...    iperf_udp='-p:5069 -b:82M -l:1024 -t:60 -i:1'
    log    ${ue_details1}
    log to console    Attach Legacy1 UE...
    operatingsystem.Set Environment Variable    ABSTRACT_LIB_CONFIG    ${ABSTRACT_LIB_CONFIG}
    log    ${ABSTRACT_LIB_CONFIG}
    ta_ultracaller.Attach UE      ue_alias=${UE_alias1}
    sleep    20s
    log to console  Calculating Max DL THroughput Achieved on Single Legacy Device....
    ta_ultracaller.start_datatransfer    ue_alias=${UE_alias1}    direction=${direction_dl}    protocoltype=${data_transfer_protocol}
    sleep  50
    ta_ultracaller.await_data_transfer_finish    ${UE_alias1}    ${direction_dl}    ${timeout}
    sleep  100
    ${Result}=    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias1}    direction=${direction_dl}
    ...    thrughtput=${throughputt_dl1}    deviation=${deviation}
    ${Value}=    get from dictionary    ${Result['${UE_alias1[0]}']}    tputvalue
    log to console  Max DL Throughput on Single Legacy Device is ${Result['LEGACY_1']['tputvalue']}
	${status}=    BuiltIn.Evaluate      ${Value}>=76
	Run keyword And Continue On Failure		Should Be True    ${status}
	sleep    60s
	ta_ultracaller.Detach UE      ue_alias=${UE_alias1}
	Set To Dictionary    ${ue_details1['LEGACY_1']['CONSTRUCTOR_PARAMETERS']['configuration']['data_transfer']}
    ...    iperf_udp='-p:5059 -b:62M -l:1024 -t:60 -i:1'
    log    ${ue_details1}
    operatingsystem.Set Environment Variable    ABSTRACT_LIB_CONFIG    ${ABSTRACT_LIB_CONFIG}
    log    ${ABSTRACT_LIB_CONFIG}
    ta_ultracaller.Attach UE      ue_alias=${UE_alias1}
    sleep    20s
    log to console    Attach CaTM UE...
    log to console  Start DL Traffic On Legacy1 UE...
    ta_ultracaller.start_datatransfer    ue_alias=${UE_alias1}    direction=${direction_dl}    protocoltype=${data_transfer_protocol}.
    #Starting 'DL' throughput on '${UE_CATM2}' with bw='${CALL_DL_BANDWIDTH_CATMM}' during '60s'
    sleep  50
    log to console  Wait Data Transfer Finish On Legacy1 UE...
    ta_ultracaller.await_data_transfer_finish    ${UE_alias1}    ${direction_dl}    ${timeout}
    log to console  Wait Data Transfer Finish On ${UE_CATM2} UE..
    #Wait 'DL' throughput finish on '${UE_CATM2}'
    sleep    100s
    ${Result1}=    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias1}    direction=${direction_dl}
    ...    thrughtput=${throughputt_dl11}    deviation=${deviation}
    ${Value_1}=    get from dictionary    ${Result1['${UE_alias1[0]}']}    tputvalue
    log to console    Avg Throughput on Legacy1 camped on PLMN40499 Cell is ${Result1['LEGACY_1']['tputvalue']}
	${status_1}=    BuiltIn.Evaluate      ${Value_1}>=55
	Run keyword And Continue On Failure		Should Be True    ${status_1}
    #Verify 'DL' throughput on '${UE_CATM2}' bw is '${CALL_DL_BANDWIDTH_CATMM}' with deviation '10%'

Test Setup
    Log to console   --Test setup--
    coam.setup_admin    bts_host=${BTS_ADDRESS}    bts_port=443    username=Nemuadmin    password=nemuuser
    Log To Console    BTS is Connected
    ${sw_version}=    coam.get_sw_version
    Log to console  \n ${sw_version} \n
    ${out}    set variable    
    ...    ${OUTPUT_DIR}/CB009462_Verification_of_Successful_commissioning
    set test variable    ${out}
    os.create directory     ${out}
    ${opt}    set variable    
    ...    ${tcp_dump_path}dcap
    ...    ${tcp_dump_path}
    set test variable    ${opt}
    os.create directory     ${opt}
    #${scf_path}    Download SCF
    #set global variable    ${scf_path}
    Check BTS is OnAir
    Log to console   --Starting Syslogs Logs--
    os.Run     killall btslog
    btslog.create_btslog_collector
    ...    name=btslog
    ...    log_dir=/tmp/btslog2
    core.setup_collectors      names=btslog
    core.set_suite_alias      btslog
    core.start_collectors      names=btslog
    Log to console   --Test Setup finished--
	Commission the site with preconditions    ${scf_file_preconditions}

    

Test Teardown
    Log to console   --Test teardown--
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog      target_dir=${out}
    core.teardown_collectors      names=btslog
    coam.collect_snapshot    target_file_name=${out}/Snapshotfile.zip
	
Perform actcatM parameter recommissioning
    [Arguments]    ${value}
    coam.perform_parameter_recommissioning    dist_name=${param_dist_name}
      ...                                        parameter=${param}
      ...                                        value=${value}
      ...                                        operation=update
      ...                                        skip_parameter_relation_errors=${True}
	  ...                                        should_activate=${True}
	  Wait Until Keyword Succeeds   6min    10s     Check BTS is OnAir

Check BTS is OnAir
    [Documentation]  ... checking BTS status
    ${bts_status}=  coam.get_bts_statuses
    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'
    ...    Log To Console    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail

Check M-Plane link status
    ${response}    coam.get_frm
    Run Keyword If  '${response[0]['status']['mPlaneLinkStatus']}'=='Connected'
    ...    Log To Console    RU M-Plane link status is: ${response[0]['status']['mPlaneLinkStatus']}
    ...    ELSE    fail

m-plane status
    ${ru_info}=    soam.get ru info    RMOD    1
    ${mplane_status}    Set Variable    ${ru_info['Status']['M-Plane link status']}
    Run Keyword Unless    '${mplane_status}'== 'Connected'    Fail
	
Commission the site with preconditions 
    [Arguments]    ${scfc_file}
    COAM.setup_admin   bts_host=${host1}
    COAM.Perform Commissioning
    ...    bts_id=${bts_id}
    ...    scf_file=${scfc_file}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    Wait Until Keyword Succeeds   6min    10s     Check BTS is OnAir

Start DCAP log
    dcap.connect_to    host=${DCAP_host}     port=${DCAP_port}    username=${username}    password=${password}     secure=${True}
    &{bts1_info}   create dictionary     host=${BTS_MPLANE}    port=443    username=Nemuadmin    password=nemuuser
    @{enb_custom_profile}=    Create List    condor4gAa
    @{bts}      Create List     ${bts1_info}
    ${output}    dcap.Start_trace     duration=-1    bts=@{bts}    enb_custom_profile=@{enb_custom_profile}    wait_for_activation=True
    LogToConsole    ${output}
    ${trace_id} =   Get From Dictionary   ${output}   tracer_id
    set global variable    ${trace_id}
    LogToConsole    Dcap started
    sleep    4m

Stop DCAP Log
    dcap.stop_trace    trace_id=${trace_id}
    LogToConsole    ${trace_id}
    sleep    2m
    ${result1}     dcap.get_results    result_id=${trace_id}    target_dir=/home/ute/logs   timeout=300


Verify static PRACH config from Netconf logs
    [Arguments]    ${netconf_file}
    ${static_PRACH}=    netconf_get_value     ${netconf_file}     rpc    edit-config    static-config-supported
    Should Be Equal    ${static_PRACH[0][1]}    'PRACH'
    #${fault_time}=    netconf_get_time    ${netconf_file}    notification    <fault-id>24</fault-id>
    #[Return]    ${fault_time[0][0]}   
	
Collect netconf logs
    ${proxy}       Create Dictionary    host=10.53.188.132   user=ute    password=BT5l@bus3rl0g1n
    ${executor}    Create Dictionary    host=${BTS_ADDRESS}   user=toor4nsn    password=oZPS0POrRieRtu
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
    os.Copy File    ${out}/coredump/*_NetconfRpcMessageTrace.log    ${out}/RMOD_L-1_NetconfRpcMessageTrace.log
	
Link SCOUT SCF to Configuration ID for Reporting
    ${scout_testline_name}=    OperatingSystem.Run    hostname
    [Documentation]    :Author: Mallikarjuna 
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    ${list}=    String.Split String    ${scout_testline_name}    -
    ${scout_testline_name}=    Evaluate    "_".join(${list})
    log    ${scout_testline_name}
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${TC_ID}=   scout.request_scf   use_scout_internal_id=${True}
    scout.teardown_scout_api
    ${TC_ID}    set variable    ute:id:${TC_ID}
    Set Tags  ${TC_ID}
    Sleep    120s

