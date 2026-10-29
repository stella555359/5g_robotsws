*** Settings ***
Documentation
...   author: Dubey Rahul Kumar
...   contact: rahul.kumar_dubey@nokia.com
...   Description: keywords for CB008796
Library    BuiltIn
Library    Collections
Library    OperatingSystem
Library    String
Library    SSHLibrary
Library    SeleniumLibrary
Library    DateTime
Library    taf.sbts.oam.coam.admin  WITH NAME   CoamAdmin
Library    taf.selenium.gnb.oam.coam.classical    WITH NAME    seleLib
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    Process
Library     taf.ue
Library     ute_ue
Library    ute_tshark
Library    ute_syslog
Library    Telnet
Library	   testsuite/Bangalore/ORAN/T08/resources/python/Tshark_Validation.py
Library    taf.transport.ssh    WITH NAME    ssh
Library    testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Library    hran_bsc    WITH NAME    hran
Library    testsuite/Bangalore/ORAN/T08/resources/python/Emil_log_parsing.py
Library    taf.sw.dcap.rd   WITH NAME   rd
Library    taf.sw.scout    WITH NAME    scout
Resource    testsuite/Bangalore/ORAN/T08/resources/robot/Topyoung_Attenuator_T08.robot

*** Variables ***
@{UE_alias}=  UE1
${pva_ip}    10.45.153.212
${pva_vendor}    TOPYOUNG
${pva_model}	 TAS16T16-51-120-1N-DEJS



*** Keywords ***

CB008796Mobility_TC_001_part1
    Lock_Cell_target_BTS
    Log To Console    Changing Handoveer allowed parameter in Source BTS
    parameter update    ${LNREL_DISTNAME}    ${HO_PAR_NAME}    ${HO_PAR_ABBR}    onlyS1
    PVA_Attenuator_startup_CSFB    ${pva_ip}    ${pva_vendor}    ${pva_model}
	Log to console    ----- Step1: UE Attach -----
    Get TcpdumpLogs from Remote machine    ${BTS1_ip}    ${connection1}
    Sleep    2min
	Prepare UE	   UE_alias=${UE_alias_2}     capabilities=${capabilities_2}    timeout=${timeout}
	Detach and Attach UE    UE_alias=${UE_alias_2}
	stop tcpdumplogs    tcpdump
	Log to console    ----- Step1: Validation -----

	${output}=    Convert pcap file    (nas_eps.emm.EPS_attach_result == 2 || nas_eps.emm.eps_att_type == 2)    ${connection1}
    validate wireshark logs    ${output}    InitialUEMessage
    validate wireshark logs    ${output}    InitialContextSetupRequest

	Log to console    ----- Step1: Validation End -----
	rename file    ${out}tcpdump/    tcpdump.pcap    tcpdump3.pcap
	Log to console    ----- Step1: End -----
	Log to console    ----- Step2: CSFB Emergency Call -----

	Get TcpdumpLogs from Remote machine    ${BTS1_ip}    ${connection1}
    Sleep    2min
    Start_Ip_traffic_capture_gsm
    Start and Stop Voice Call Emergency
    Validate call at BSC server
    Stop_Emergency_Call
    stop tcpdumplogs    tcpdump
    sleep    30
    Stop_Ip_traffic_capture_gsm

    ${output}=    Convert pcap file    gsm_abis_rsl    ${connection2}
	Log to console    ----- Step2: Validation -----
    Run Keyword And Ignore Error    validate wireshark logs    ${output}    (MM) CM Service Request
    Run Keyword And Ignore Error    validate wireshark logs    ${output}    (MM) CM Service Accept
    Run Keyword And Ignore Error    validate wireshark logs    ${output}    (CC) Setup
    Run Keyword And Ignore Error    validate wireshark logs    ${output}    (CC) Call Proceeding
    Run Keyword And Ignore Error    validate wireshark logs    ${output}    (CC) Alerting
    Run Keyword And Ignore Error    validate wireshark logs    ${output}    (CC) Connect
    Run Keyword And Ignore Error    validate wireshark logs    ${output}    (CC) Connect Acknowledge
    Run Keyword And Ignore Error    validate wireshark logs    ${output}    (CC) Disconnect
    Run Keyword And Ignore Error    validate wireshark logs    ${output}    (CC) Release
    Run Keyword And Ignore Error    validate wireshark logs    ${output}    (CC) Release Complete

    rename file    ${out}tcpdump1/    tcpdump1.pcap    tcpdump6.pcap

    ${output}=    Convert pcap file    (nas_eps.emm.service_type == 2)    ${connection1}
    validate wireshark logs    ${output}    UplinkNASTransport/Extended service request

    ${output}=    Convert pcap file    (s1ap || s1ap.radioNetwork == 23)    ${connection1}
    validate wireshark logs    ${output}    UEContextModificationRequest
    validate wireshark logs    ${output}    UEContextModificationRequest
    validate wireshark logs    ${output}    UEContextReleaseRequest [RadioNetwork-cause=cs-fallback-triggered]
    validate wireshark logs    ${output}    UEContextReleaseCommand [RadioNetwork-cause=cs-fallback-triggered]

	Log to console    ----- Step2: Validation End -----
    rename file    ${out}tcpdump/    tcpdump.pcap    tcpdump7.pcap
	Log to console    ----- Step2: End -----

CB008796Mobility_TC_001_part2
	Log to console    ----- Step3: CSFB VOlte -----
    Get TcpdumpLogs from Remote machine    ${BTS1_ip}    ${connection1}
    Sleep    2min
    Start_Ip_traffic_capture_gsm
    Sleep    2min
    Get TcpdumpLogs from Remote machine    ${BTS2_ip}    ${connection2}
    Sleep    2min
    Volte_Call_using_adb_command_CSFB
    Validate call at BSC server
    sleep    60
    Stop_Volte_Call_using_adb_command_CSFB
    stop tcpdumplogs    tcpdump
    Stop_Ip_traffic_capture_gsm
    ${output}=    Convert pcap file    gsm_abis_rsl    ${connection2}
	Log to console    ----- Step3: Validation -----
    Run Keyword And Ignore Error    validate wireshark logs    ${output}    (MM) CM Service Request
    Run Keyword And Ignore Error    validate wireshark logs    ${output}    (MM) CM Service Accept
    Run Keyword And Ignore Error    validate wireshark logs    ${output}    (CC) Setup
    Run Keyword And Ignore Error    validate wireshark logs    ${output}    (CC) Call Proceeding
    Run Keyword And Ignore Error    validate wireshark logs    ${output}    (CC) Alerting
    Run Keyword And Ignore Error    validate wireshark logs    ${output}    (CC) Connect
    Run Keyword And Ignore Error    validate wireshark logs    ${output}    (CC) Connect Acknowledge
    Run Keyword And Ignore Error    validate wireshark logs    ${output}    (CC) Disconnect
    Run Keyword And Ignore Error    validate wireshark logs    ${output}    (CC) Release
    Run Keyword And Ignore Error    validate wireshark logs    ${output}    (CC) Release Complete

    rename file    ${out}tcpdump1/    tcpdump1.pcap    tcpdump4.pcap

    ${output}=    Convert pcap file    (nas_eps.emm.service_type == 0)    ${connection1}
    validate wireshark logs    ${output}    UplinkNASTransport/Extended service request
    ${output}=    Convert pcap file    (s1ap || s1ap.radioNetwork == 23)    ${connection1}
    validate wireshark logs    ${output}    UEContextModificationRequest
    validate wireshark logs    ${output}    UEContextModificationRequest
    validate wireshark logs    ${output}    UEContextReleaseRequest [RadioNetwork-cause=cs-fallback-triggered]
    validate wireshark logs    ${output}    UEContextReleaseCommand [RadioNetwork-cause=cs-fallback-triggered]
	Log to console    ----- Step3: Validation End-----

    rename file    ${out}tcpdump/    tcpdump.pcap    tcpdump5.pcap
	Unlock_Cell_target_BTS
	Log to console    ----- Step3: End-----

CB008796Mobility_TC_002
	Lock_Cell_target_BTS
    PVA_Attenuator_startup    ${pva_ip}    ${pva_vendor}    ${pva_model}
    Log To Console    Attenuator is set to default, cell is latched to LTE
	parameter update    ${LNREL_DISTNAME}    ${HO_PAR_NAME}    ${HO_PAR_ABBR}    onlyS1
    Get TcpdumpLogs from Remote machine    ${BTS1_ip}    ${connection1}
    Sleep    2min
    Start UE detach and attach    ${UE_alias_1}    ${capabilities_1}    ${timeout}
    Sleep    2min
    stop tcpdumplogs    tcpdump
    ${output}=    Convert pcap file    (nas_eps.emm.EPS_attach_result == 2 || nas_eps.emm.eps_att_type == 2)    ${connection1}
    validate wireshark logs    ${output}    InitialUEMessage
    validate wireshark logs    ${output}    InitialContextSetupRequest
    ${output}=    Convert pcap file    (s1ap.id == 124 || s1ap.SRVCCOperationPossible == 0)    ${connection1}
    validate wireshark logs    ${output}    InitialContextSetupRequest
    rename file    ${out}tcpdump/    tcpdump.pcap    tcpdump1.pcap
    Get TcpdumpLogs from Remote machine    ${BTS1_ip}    ${connection1}
    Sleep    2min
    Start_Volte_Call_using_adb_command    ${UE_alias_1}    ${capabilities_1}  ${UE1_start_Voice_call_cmd}
    stop tcpdumplogs    tcpdump
    ${output}=    Convert pcap file    s1ap.qCI == 1    ${connection1}
    validate wireshark logs    ${output}    E-RABSetupRequest/Activate dedicated EPS bearer context request
    rename file    ${out}tcpdump/    tcpdump.pcap    tcpdump2.pcap
    Get TcpdumpLogs from Remote machine    ${BTS1_ip}    ${connection1}
    Sleep    2min
    Get TcpdumpLogs from Remote machine    ${BTS2_ip}    ${connection2}
    Sleep    2min
    PVA_Attenuator_SRVCC    ${pva_ip}    ${pva_vendor}    ${pva_model}
    Log To Console    Attenuation for lte to GSM cell successfull
    Validate call at BSC server
    stop tcpdumplogs    tcpdump
    stop tcpdumplogs    tcpdump1
    Stop_Volte_Call_using_adb_command    ${UE_alias_1}    ${capabilities_1}  ${UE1_stop_Voice_call_cmd}
    ${output}=    Convert pcap file    (s1ap.HandoverType == 2 || s1ap.procedureCode == 0)    ${connection1}
    validate wireshark logs    ${output}    HandoverRequired
    validate wireshark logs    ${output}    HandoverCommand
    ${output}=    Convert pcap file    s1ap.SRVCCHOIndication == 1    ${connection1}
    validate wireshark logs    ${output}    HandoverRequired
    ${output}=    Convert pcap file    (s1ap.procedureCode == 23 && s1ap.radioNetwork == 2)    ${connection1}
    validate wireshark logs    ${output}    UEContextReleaseCommand
    rename file    ${out}tcpdump/    tcpdump.pcap    tcpdump3.pcap
    PVA_Attenuator_startup     ${pva_ip}    ${pva_vendor}    ${pva_model}
    Log To Console    Attenuation for GSM to lte cell successfull
    Counter validation
	Unlock_Cell_target_BTS

CB008796Mobility_TC_003
    Unlock_Cell_target_BTS
    PVA_Attenuator_startup     ${pva_ip}    ${pva_vendor}    ${pva_model}
	parameter update    ${LNREL_DISTNAME}    ${HO_PAR_NAME}    ${HO_PAR_ABBR}    onlyS1
    Log To Console    Attenuator set to default
    Get TcpdumpLogs from Remote machine    ${BTS_IP}    tcpdump
    Sleep    2min
    Prepare UE     UE_alias=${UE_alias_1}     capabilities=${capabilities_1}    timeout=${timeout}
    Detach and Attach UE    UE_alias=${UE_alias_1}
    Start_Volte_Call_using_adb_command    ${UE_alias_1}    ${capabilities_1}  ${UE1_start_Voice_call_cmd}
    PVA_Attenuator_Trigger    ${pva_ip}    ${pva_vendor}    ${pva_model}
    stop tcpdumplogs    tcpdump
    ${output}=    Convert pcap file    ${filter_S1HO}    tcpdump
    validate wireshark logs    ${output}    HandoverRequired
    validate wireshark logs    ${output}    UEContextReleaseCommand
    Stop_Volte_Call_using_adb_command    ${UE_alias_1}    ${capabilities_1}  ${UE1_stop_Voice_call_cmd}

CB008796Mobility_TC_004
	Unlock_Cell_target_BTS
    PVA_Attenuator_startup    ${pva_ip}    ${pva_vendor}    ${pva_model}
    Log To Console    Attenuator set to default
    Get TcpdumpLogs from Remote machine    ${BTS_IP}    tcpdump
    Sleep    2min
    ${initial_counter}=    Counter validation1    M8011C69    0

    Prepare UE     UE_alias=@{New_UE_alias}   capabilities=@{new_capabilities}    timeout=${timeout}
    Multiple Attach ue and run throughput    ${New_UE_alias}    dt_name=${dt_name_dl}    direction=${direction_dl}
	...    throughput=${throughput_dl}  deviation=${deviation_dl}   timeout=${timeout}
    log to console    ------- THROUGHPUT IS ONGOING ---------
    sleep    300

    ${final_counter}=    Counter validation1    M8011C69    100
    ${counter_difference}=    Evaluate    int(${final_counter}) - int(${initial_counter})

    Run Keyword If    ${counter_difference} > 100
    ...    Log    Counter difference is more than 100
    ...    ELSE    Fail    Counter difference is not more than 100


    PVA_Attenuator_Trigger_load    ${pva_ip}    ${pva_vendor}    ${pva_model}
    stop tcpdumplogs    tcpdump
    ${output}=    Convert pcap file    ${filter_S1_for_LB}    tcpdump
    validate wireshark logs    ${output}    HandoverRequired [RadioNetwork-cause=reduce-load-in-serving-cell]
    validate wireshark logs    ${output}    HandoverCommand/RRCConnectionReconfiguration
    validate wireshark logs    ${output}    ENBStatusTransfer
    validate wireshark logs    ${output}    UEContextReleaseCommand [RadioNetwork-cause=successful-handover]
    validate wireshark logs    ${output}    UEContextReleaseComplete

    ${initial_counter}=    Counter validation1    M8011C69    0
    pva2.PVA_Attenuator_Trigger
    ${output}=    Convert pcap file    ${filter_S1HO}    tcpdump
    validate wireshark logs    ${output}    HandoverRequired
    validate wireshark logs    ${output}    UEContextReleaseCommand

    @{datauealias1}    create list    ${New_UE_alias[0]}
    @{datauealias2}    create list    ${New_UE_alias[1]}

    Stop Data Transfer    ${datauealias1}    timeout=${timeout}    direction=${direction_dl}
    Stop Data Transfer    ${datauealias2}    timeout=${timeout}    direction=${direction_dl}

CB008796Mobility_TC_005
	Unlock_Cell_target_BTS
    Log To Console    Changing Handoveer allowed parameter in Source BTS
    parameter update    ${LNREL_DISTNAME}    ${HO_PAR_NAME}    ${HO_PAR_ABBR}    allowed
    PVA_Attenuator_startup    ${pva_ip}    ${pva_vendor}    ${pva_model}
    Log To Console    Attenuator set to default
    Get TcpdumpLogs from Remote machine    ${BTS_IP}    tcpdump
    Sleep    2min
    Prepare UE     UE_alias=${UE_alias_1}     capabilities=${capabilities_1}    timeout=${timeout}
    Detach and Attach UE    UE_alias=${UE_alias_1}
    Start_Volte_Call_using_adb_command    ${UE_alias_1}    ${capabilities_1}  ${UE1_start_Voice_call_cmd}
    PVA_Attenuator_Trigger    ${pva_ip}    ${pva_vendor}    ${pva_model}
    stop tcpdumplogs    tcpdump
    ${output}=    Convert pcap file    ${filter_X2HO}    tcpdump
    validate wireshark logs    ${output}    HandoverRequest
    validate wireshark logs    ${output}    HandoverRequestAcknowledge
    validate wireshark logs    ${output}    SNStatusTransfer
    validate wireshark logs    ${output}    UEContextRelease
    PVA_Attenuator_startup    ${pva_ip}    ${pva_vendor}    ${pva_model}
    Stop_Volte_Call_using_adb_command    ${UE_alias_1}    ${capabilities_1}  ${UE1_stop_Voice_call_cmd}


CB008796Mobility_TC_006
	Unlock_Cell_target_BTS
    Log To Console    Changing Handoveer allowed parameter in Source BTS
    parameter update    ${LNREL_DISTNAME}    ${HO_PAR_NAME}    ${HO_PAR_ABBR}    allowed
    PVA_Attenuator_startup    ${pva_ip}    ${pva_vendor}    ${pva_model}
    Log To Console    Attenuator set to default
    Get TcpdumpLogs from Remote machine    ${BTS_IP}    tcpdump
    Sleep    2min
    Prepare UE     UE_alias=${UE_alias_1}     capabilities=${capabilities_1}    timeout=${timeout}
    Detach and Attach UE    UE_alias=${UE_alias_1}
    Start_Volte_Call_using_adb_command    ${UE_alias_1}    ${capabilities_1}  ${UE1_start_Voice_call_cmd}
    PVA_Attenuator_Trigger    ${pva_ip}    ${pva_vendor}    ${pva_model}
    stop tcpdumplogs    tcpdump
    ${output}=    Convert pcap file    ${filter_X2HO}    tcpdump
    validate wireshark logs    ${output}    HandoverRequest
    validate wireshark logs    ${output}    HandoverRequestAcknowledge
    validate wireshark logs    ${output}    SNStatusTransfer
    validate wireshark logs    ${output}    UEContextRelease
    PVA_Attenuator_startup    ${pva_ip}    ${pva_vendor}    ${pva_model}
    Stop_Volte_Call_using_adb_command    ${UE_alias_1}    ${capabilities_1}  ${UE1_stop_Voice_call_cmd}


Start UE detach and attach
    [Arguments]    ${UE_alias}    ${capabilities}    ${timeout}
    Prepare UE	   UE_alias=${UE_alias}     capabilities=${capabilities}    timeout=${timeout}
    Detach and Attach UE    UE_alias=${UE_alias}


Stopping Voice Call
    [Arguments]     ${UE_alias}   ${dt_name_v}
	  ta_ultracaller.stop voice call    ue_alias=${UE_alias}   testcasename=${dt_name_v}
    Log To Console    UE voice call Successfully stopped


Start UE detach and attach_CSFB
    Prepare UE	   UE_alias=${UE_alias_2}     capabilities=${capabilities}    timeout=${timeout}
    Detach and Attach UE    UE_alias=${UE_alias_2}

Counter Collection and Validation
    [Arguments]    ${bts_ip}    ${counter}    ${cell_id}    ${dict_variablle}    ${node_name}    ${string}    ${Init_total_count}
	log    ${bts_ip}
    ${result}    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=100    connection=oam
    ${counter_values}    Get Dictionary Values    ${result['BTS']['CELLS']['LNCEL-${cell_id}']['MCC-001_MNC-01']['${dict_variablle}']['${counter}']}
    ${final_total_count}    Get_Sum_of_Counter    ${counter_values}
    log to console    Final count after S1HO for counter id ${counter} is ${final_total_count}
    Run Keyword if    '${final_total_count}'>'${Init_total_count}'
    ...    log to console    Counter value for ${string} successfully incrimented at ${node_name}
    ...    ELSE    fail    msg=Counter not incremented for ${string} test failed

Counter Collection and Validation for DRX
    [Arguments]    ${bts_ip}    ${counter}    ${cell_id}    ${dict_variablle}    ${string}
	log    ${bts_ip}
    ${result}    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=100    connection=oam
    ${counter_values}    Get Dictionary Values    ${result['BTS']['CELLS']['LNCEL-${cell_id}']['MCC-001_MNC-01']['${dict_variablle}']['${counter}']}
    ${total_count}    Get_Sum_of_Counter    ${counter_values}
    log to console    Final Subframe count of ${string}_${counter} is ${total_count}
    Run Keyword if    '${total_count}'>'0'
    ...    log to console    Counter value for ${string} successfully incrimented
    ...    ELSE    fail    msg=Counter not incremented for ${string} test failed


Get_Sum_of_Counter
    [Arguments]    ${PM_counter_values}
    FOR    ${a}    IN    @{PM_counter_values}
        ${k}    Evaluate    ${k} + ${a}
    END
    [Return]    ${k}


Counter validation_S1HO
    [Arguments]    ${counter}    ${occurence}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=100    connection=oam
    log to console    ${result}
    ${values}=    Get Dictionary Values    ${result['BTS']['CELLS']['LNCEL-0']['MCC-001_MNC-01']['LTE_Inter_eNB_HO']['${counter}']}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'>='${occurence}'
    ...    log to console    ${counter} counter is pegging properlly
    ...    ELSE    fail

Counter validationion_2
    [Arguments]    ${counter}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=100    connection=oam
    log to console    ${result}
    ${values}=    Get Dictionary Values    ${result['BTS']['CELLS']['LNCEL-0']['LTE_Inter_eNB_HO']['${counter}']}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times

Lock_Cell_source_BTS
    [Documentation]  ... Locking_and_unlocking_cells
    CoamAdmin.lock    dist_name=MRBTS-1024/NRBTS-1024/NRCELL-0    timeout=60    connection=oam
    sleep    30s
	CoamAdmin.lock    dist_name=MRBTS-1024/NRBTS-1024/NRCELL-1    timeout=60    connection=oam
	sleep    30s
	CoamAdmin.lock    dist_name=MRBTS-1024/LNBTS-1024/LNCEL-1    timeout=60    connection=oam
	sleep    30s
	CoamAdmin.lock    dist_name=MRBTS-1024/LNBTS-1024/LNCEL-2    timeout=60    connection=oam
	sleep    30s

Lock_Cell_target_BTS
    [Documentation]  ... Locking_and_unlocking_cells
    CoamAdmin.lock    dist_name=MRBTS-1026/LNBTS-1026/LNCEL-1038    timeout=60    connection=login
    sleep    30s

Unlock_Cell_target_BTS
    [Documentation]  ... Locking_and_unlocking_cells
    CoamAdmin.unlock    dist_name=MRBTS-1026/LNBTS-1026/LNCEL-1038    timeout=60    connection=login
    sleep    30s

Volte_Call_using_adb_command_mobility
    Log To Console    \n--adb execution--\n
    ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ${a}=     ta_ultracaller.require_ue  ue_alias=${UE_alias}   capabilities=${capabilities}
    log   ${a}
    ${out}=    ta_ultracaller._run_adbcommand    ${UE_alias}    ${adb_cmd_voice_call}
    sleep   30

Volte_Call_using_adb_command_CSFB
    Log To Console    \n--adb execution--\n
    ta_ultracaller.Require UE   ue_alias=${UE_alias_2}   capabilities=${capabilities_2}
    ${a}=     ta_ultracaller.require_ue  ue_alias=${UE_alias_2}   capabilities=${capabilities_2}
    log   ${a}
    ${out}=    ta_ultracaller._run_adbcommand    ${UE_alias_2}    ${adb_cmd_voice_call_CSFB}
    sleep   30

Stop_Volte_Call_using_adb_command_CSFB
    Log To Console    \n--adb execution--\n
    ta_ultracaller.Require UE   ue_alias=${UE_alias_2}   capabilities=${capabilities_2}
    ${a}=     ta_ultracaller.require_ue  ue_alias=${UE_alias_2}   capabilities=${capabilities_2}
    log   ${a}
    ${out}=    ta_ultracaller._run_adbcommand    ${UE_alias_2}    ${adb_cmd_stop_call_CSFB}
    sleep   30

Stop_Volte_Call_using_adb_command_new
    Log To Console    \n--adb execution--\n
    ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ${a}=     ta_ultracaller.require_ue  ue_alias=${UE_alias}   capabilities=${capabilities}
    log   ${a}
    ${out}=    ta_ultracaller._run_adbcommand    ${UE_alias}    ${adb_cmd_stop_call}
    sleep   30

Validate call at BSC server
	hran.bsc_ssh_connection    host=10.43.109.100    alias=bsc    port=22    timeout=None    username=SINRAN    password=SINRAN123
	sleep    30
    FOR    ${index}    IN RANGE    100
        ${data}    hran.get_transceiver_data    bts_id=2028    trx_id=1
        @{values}=    get from dictionary    ${data}    CH.STATUS
        log to console    ${values}
        ${status}    Run Keyword And Return Status    should contain    ${values}    FR
        ${status1}    Run Keyword And Return Status    should contain    ${values}    GP
        Run keyword if    '${status}' == 'True' and '${status1}' == 'True'    exit for loop
    END
    Run keyword if    '${status}' != 'True' or '${status1}' != 'True'
    ...    log to console    CS call did not trigger at GSM side
    hran.close_connection
	sleep    30

Counter validation
    @{Counter_list}=    create list    'M8016C33'    'M8016C34'
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=M8016C33,M8016C34    timeout=100    connection=oam
    log to console    ${result}
    FOR    ${a}    IN    @{Counter_list}
        ${values}=    Get Dictionary Values    ${result['BTS']['MRBTS-1024']['LNBTS-1024']['LNCEL-0']['MCC-001']['MNC-01']['LTE_Inter_Sys_HO'][${a}]}
        ${Total_Count}=    Get_value_of_Counter    ${values}
        Log to Console    ${a} counter is pegging : ${Total_Count} times
        Append to list    ${counter_values}    ${Total_Count}
    END
    Run keyword And Continue On Failure		Should Be equal		${counter_values[0]}    ${counter_values[1]}

Start and Stop Voice Call Emergency
    Log To Console    \n--adb execution--\n
    ta_ultracaller.Require UE   ue_alias=${UE_alias_3}   capabilities=${capabilities}
    ${a}=     ta_ultracaller.require_ue  ue_alias=${UE_alias_3}   capabilities=${capabilities_3}
    log   ${a}
    ${out}=    ta_ultracaller._run_adbcommand    ${UE_alias_3}    ${adb_cmd1_emergency}
    sleep   5
	${out}=    ta_ultracaller._run_adbcommand    ${UE_alias_3}    ${adb_cmd2_emergency}
	log    ${out}
	Log To Console    Emergency call Successfully started_
	sleep    10
	Validate call at BSC server
	${out}=    ta_ultracaller._run_adbcommand    ${UE_alias_3}    ${adb_cmd3_emergency}
	log    ${out}
    Log To Console    Emergency call Successfully ended
	sleep    10

Stop_Emergency_Call
	${a}=     ta_ultracaller.require_ue  ue_alias=${UE_alias_3}   capabilities=${capabilities_3}
    log   ${a}
	sleep    5
	${out}=    ta_ultracaller._run_adbcommand    ${UE_alias_3}    ${adb_cmd3_emergency}
	log    ${out}
    Log To Console    Emergency call Successfully ended

Start_Ip_traffic_capture_gsm
    [Documentation]    This keyword is to capture ip traffic for gsm verification temporarily
    ...                Because the weireshark pc does not cpature gsm msgs.
    CoamAdmin.start_ip_capture_file    measurement_point=Transport_Interface
    ...    uplane_capturing=True
    ...    timeout=10
    ...    connection=login
    ...    detailed_output=False
    Log to console    Started gsm ip_traffic capture

Stop_Ip_traffic_capture_gsm
    [Documentation]    This keyword will stop, generate and download ip traffic from webem.
    ${local_file}    set variable    ${out}/tcpdump1/tcpdump1.pcap
    Log to console    Stopping wireshark

    CoamAdmin.stop_ip_capture_file    timeout=10
    ...    connection=login
    ...    detailed_output=False
    CoamAdmin.generate_ip_capture_file
    ...    timeout=10
    ...    connection=login
    ...    detailed_output=False
    CoamAdmin.download_ip_capture_file    target_file_name=${local_file}
    ...    timeout=100
    ...    connection=login
    ...    detailed_output=False

Stop Data Transfer
    [Arguments]     ${UE_alias}=${UE_alias}    ${timeout}=${timeout}    ${direction}=${direction_dl}
    ...    ${throughput}=${throughput_dl}    ${deviation}=${deviation_dl}    ${dt_name}=${dt_name_dl}
    log to console    \nStop data transfer
    log    	${dt_name}
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction}    ${timeout}
    Log To Console    \nUE Data Transfer Successful
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    sleep    20
    ${tput}    Run Keyword And Continue On Failure  ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}
    ...    direction=${direction}   thrughtput=${throughput}    deviation=${deviation} 

Counter validation1
    [Arguments]    ${counter}    ${occurence}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=100    connection=oam
    ${a}=    Set Variable    ['BTS']['MRBTS-1024']['LNBTS-1024']['LNCEL-0']
    ${b}=    Set Variable    ['MCC-001']['MNC-01']['LTE_Cell_Resource']['${counter}']
    ${c}=    Set Variable    ${result${a}${b}}
    Log To Console    ${c}
    log to console    ${result}
    ${values}=    Get Dictionary Values    ${c}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'>='${occurence}'
    ...    log to console    ${counter} counter is pegging properlly
    ...    ELSE    fail
    [Return]    ${Total_Count}

Admin_setup_target_BTS
    Log To Console    connecting to BTS
    CoamAdmin.Setup_Admin    bts_host=10.58.239.192    alias=login
    Log To Console    BTS is Connected
    Check BTS is OnAir    login

Admin_teardown_target_BTS
    CoamAdmin.teardown    login
    Log To Console    BTS IS Disconnected

Starting Voice Call
    [Arguments]     ${UE_alias}    ${dt_name_v}
    ta_ultracaller.start voice call    ue_alias=${UE_alias}    testcasename=${dt_name_v}
    Log To Console    UE voice call Successfully started
    PVA_Attenuator_Trigger    ${pva_ip}    ${pva_vendor}    ${pva_model}
    Log To Console    Attenuation for source & target cell successfull
    Sleep    5

Verify_uplink_Counters_with_SDLC_in_carrier_agrregation_EDA
	[Documentation]
	...
    ...	This kw is added as EDA for LTE2149
	...	This feature for LTE Supplemental DL carrier is quite old and not sure if enabling it again by doing configuration
	...	changes in Regression will make much sense when the past testcase owners have already optimized these testcases.
	...	Corrective action: M8001C217 MEAN_PRB_AVAIL_PUSCH to be added for Counters update.
	...	Preventive action: Observe other UL KPIs for non-zero values. Since no UL is available, no UL KPIs/Counters should be incremented.
	...
    [Arguments]    ${counter}    ${counter_type}		${occurence}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=300    connection=oam
    log to console    ${result}
	log    ${counter_type}
    ${a}=    Set Variable    ['BTS']['MRBTS-1024']['LNBTS-1024']['LNCEL-2']
    ${b}=    Set Variable    ['MCC-001']['MNC-01']['${counter_type}']['${counter}']
    ${c}=    Set Variable    ${result${a}${b}}
    Log To Console    ${c}
    ${values}=    Get Dictionary Values    ${c}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'=='${occurence}'
    ...    log to console    ${counter} counter is pegging properly
    ...    ELSE    fail

Verify_MicroDTX_Counters_CB012255
	[Documentation]
	...
    ...	This kw is added for counter validation for CB012255
	...
    [Arguments]    ${counter}    ${counter_type}	${occurence}
	log    ${counter_type}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=300    connection=oam
    log to console    ${result}
    ${a}=    Set Variable    ['BTS']['MRBTS-1024']['LNBTS-1024']['LNCEL-0']
    ${b}=    Set Variable    ['MCC-001']['MNC-01']['${counter_type}']['${counter}']
    ${c}=    Set Variable    ${result${a}${b}}
    Log To Console    ${c}
    ${values}=    Get Dictionary Values    ${c}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'>'${occurence}'
    ...    log to console    ${counter} counter is pegging properly
    ...    ELSE    fail
