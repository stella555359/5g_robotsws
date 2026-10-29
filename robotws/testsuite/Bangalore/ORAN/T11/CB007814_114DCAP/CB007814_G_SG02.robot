*** Settings ***
Documentation
...               Feature    : eCPRI RRM porting for FR1-FDD on ABIO
...               Feature Id : CB007814
...               Author     : debanjali.misra@nokia.com
...               Email Id   :

Library           Process
#Library      /home/ute/robotws/testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Library           taf.sbts.oam.coam.admin    WITH NAME    COAM
Library           ta5g_scfc_analysis
#Library			  ta_xml
Library           OperatingSystem
Library           String
Library           taf.sw.dcap.rd     WITH NAME   dcap
#Library     	  dcap_extract_file.py
Library           DateTime
Library           Collections
Library           taf.sw.dcap.rd   WITH NAME   rd
Library           taf.config.scf   WITH NAME    scf
#Library           taf.transport.ssh    WITH NAME    ssh
#Library           taf.collectors.core    WITH NAME    core
Library           taf.ul.alarms_watchdog   WITH NAME    alarm
Library           taf.collectors.btslog    WITH NAME    btslog
Library           taf.hw.rf_attenuator  WITH NAME  at
Library           ../../resources/python/ta_ultracaller/
Resource          ../../resources/robot/common_setup_teardown.robot
Force Tags        CRT    SBTS24R3    FL00    QCD_MN_RAN    QCP_RAN_VRF

*** Variables ***
&{Call_Test_lock_unlock_multi_AMF}
...     QC_ID_FL00=QC_31502    QC_ID_SBTS24R2=QC_773795

@{UE_alias}=  UE_1																				# UE ID in configuration file
@{capabilities}    Legacy_1																			# UE capability
@{data_transfer_protocol}       UDP																	# Default data transfer type
${M_plane_ip}    10.63.48.81																		# BTS M PLane IP
${DCAP_host}                10.41.209.115                                                          # DCAP server IP
${uepc_default_username}    inbabtslabuser                                                          # Windows UE PC username
${uepc_default_password}    BT5l@bus3rl0g1n                                                         # Windows UE PC password
${Default_DCAP_duration}    10                                                                      # DCAP log duration
${connection}               Active_connection               										# Alias for COAM connection
${CONFIG_PATH}              /home/ute/testline_configuration_5G/Bangalore/debian10/${UE_file}    # UE file configuration path
${UE_file}                  ta_ue_config.yaml                                                       # UE Configuration file name
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs                   # Path for Emil logs are copied in UE PC
${DCAP_port}        443
${AMF1}=	MRBTS-1236/NRBTS-1236/SERVEDAMF-1
${AMF2}=	MRBTS-1236/NRBTS-1236/SERVEDAMF-2
${timeout}=      100
${actngcflexsadist}=	MRBTS-1236/NRBTS-1236
${actngcflexsa}=	actNgcFlexSaMode
${operation}=	update
${valuengcflexsa}=	false
${skip_parameter_relation_errors}=	true
${should_activate}=	true
&{BTS_INFO}                 host=${M_plane_ip}  port=22  username='Nemuadmin' password='nemuuser'  credential_region_Id='DEFAULT_CREDENTIALS'
@{gnb_custom_filters}       condor5gSyslog     cp_5g     # gnb custom filters for DCAP
@{bts_custom_filter}        immediateSnapshot    scf     # BTS custom filters for DCAP
${collection_timing}        Immediate,TraceEnd                                # Snapshot collet option for DCAP
@{direction}                dl
*** Test Cases ***

Call_Test_lock_unlock_multi_AMF

    Run Keyword     Start DCAP log collection
	COAM.connect_to
	Sleep	60s
	AMFLock		${AMF1}
	Sleep	20s
	Sleep	20s
	AMFUnlock	${AMF1}
	Sleep	20s
	Log to console    \CALLS STARTED
	ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    ta_ultracaller.start_data_transfer   ${UE_alias}     ${data_transfer_protocol}     direction=${direction}
    Sleep   40s
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
	AMFLock		${AMF2}
	Sleep	20s
	Log to console    \CALLS STARTED
	ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    ta_ultracaller.start_data_transfer   ${UE_alias}     ${data_transfer_protocol}     direction=${direction}
    Sleep   40s
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
	AMFUnlock	${AMF2}
	Sleep	20s
	ActNgcFlexSaMode_False
	Log to console    \CALLS STARTED
	ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    ta_ultracaller.start_data_transfer   ${UE_alias}     ${data_transfer_protocol}     direction=${direction}
    Sleep   40s
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
	Stop DCAP log collection


*** Keywords ***
Start DCAP log collection
    [Documentation]     Start DCAP logs with custom filter
    Log to console      \nStarting DCAP trace
	dcap.connect_to  host=${DCAP_host}   port=443    username=utfuser   password=utfadmin!
    ...              rd_version=dcapv3  secure=True
    &{bts1_info}   create dictionary  host=${M_plane_ip}    port=443    username=Nemuadmin    password=nemuuser
    ${output}       rd.start_trace  duration=30     bts=${bts1_info}    gnb_custom_profile=@{gnb_custom_filters}
    ...     bts_custom_profile=@{bts_custom_filter}		collection_timing=${collection_timing}
    Sleep       150      reason=Wait for DCAP start
    ${START_TRACE_ID}      Get from Dictionary    ${output}    tracer_id
    Set Suite Variable  ${START_TRACE_ID}
    LOG      DCAP log collection has been started in the gNB

Stop DCAP log collection
    [Documentation]     Stops DCAP and collect logs
    Log to console      \nStopping DCAP trace ID ${START_TRACE_ID} and collecting logs
    rd.stop_trace    ${START_TRACE_ID}
	Sleep   600s
    LOG     DCAP logging stopped
    rd.get_results    result_id=${START_TRACE_ID}    target_dir=${OUTPUT_DIR}/DCAP_Logs    timeout=600

Counter value NRCELL2
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter ${counter_name}
    ${result}     COAM.get_pm_counters    couter_ids=${counter_name}    timeout=60    connection=${connection}
    log    ${result}
	${values}    Get Dictionary Values    ${result['BTS']['CELLS']['NRCELL-2']['NRCI-20250627']['MCC-404_MNC-99']['NRREL']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    [Return]    ${Total_Count}

Counter value NRCELL3
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter ${counter_name}
    ${result}     COAM.get_pm_counters    couter_ids=${counter_name}    timeout=60    connection=${connection}
    log    ${result}
    ${values}    Get Dictionary Values    ${result['BTS']['CELLS']['NRCELL-3']['NRCI-20250626']['MCC-404_MNC-99']['NRREL']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    [Return]    ${Total_Count}


Get value of Counter
    [Arguments]    ${Counter_value}
    [Documentation]     Get total value from list
    FOR    ${a}    IN    @{Counter_value}
        ${i}    Evaluate    ${i} + ${a}
    END
    [Return]    ${i}

Create dcap session
    [Documentation]    Establish DCAP session
    rd.connect_to     host=${DCAP_host}     port=${DCAP_port}    rd_version=${rd_version}        secure=${secure}

AMFLock
	[Arguments]    ${amf_name}
	Log to console    \AMF LOCK STARTED
	lock_ng_link	dist_name=${amf_name}	timeout=${timeout}

AMFUnlock
	[Arguments]    ${amf_name}
	Log to console    \AMF UNLOCK STARTED
	unlock_ng_link	dist_name=${amf_name}	timeout=${timeout}


ActNgcFlexSaMode_False
	   COAM.perform_parameter_recommissioning
    ...    dist_name=${actngcflexsadist}
    ...    parameter=${actngcflexsa}
    ...    operation=${operation}
    ...    value=${valuengcflexsa}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}
    ...    timeout=${timeout}
