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
Library    taf.sbts.oam.coam.admin    WITH NAME    CoamAdmin
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

*** Variables ***
${pwd}    BT5l@bus3rl0g1n
${VM_IP}    10.58.238.125
${j}    0
${i}    0
@{freq_list}
${k}    0
${adb_vilte_cmd_part1}    adb -s 3f565f74 shell am start -a android.intent.action.CALL -d tel:+911432400515
${adb_vilte_cmd_part2}    --ei android.telecom.extra.START_CALL_WITH_VIDEO_STATE 3
@{adb_cmd_vilte_call}    ${adb_vilte_cmd_part1} ${adb_vilte_cmd_part2}
@{adb_cmd_stop_call}    adb -s HQOZ8T85WOCEIBAY shell input keyevent 6
@{adb_cmd_stop_video_call}    adb -s 3f565f74 shell input keyevent 6
@{adb_cmd_answer_video_call_on_UE2}    adb -s AQKSLVH002N33100483 shell input keyevent KEYCODE_CALL
@{adb_cmd_voice_call}    adb -s e10355c0 shell am start -a android.intent.action.CALL -d tel:+123456
@{CALL_type}    UDP

${info}
${expected_value}
@{allowed_custom_alarms}    4655  61649  61524  4654  61652  6150  8000  4681  7312  7304  7313

${mplane_ip}    10.58.239.191
${DCAP_host_vm}             10.58.238.125
${DCAP_port_vm}             9443
${DCAP_host}                10.41.209.110
${port}                     443
${secure}                   True
${rd_version}               dcapv3
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs
${emil_path}                C:\\Emil
${emil_profile_path}        ${emil_path}\\profiles\\LTE
${Default_DCAP_duration}    12
${dcap_log_timeout}         1200
@{enb_custom_filters}       cp_4g
@{bts_custom_filter}        immediateSnapshot    scf    ipCapture
@{collection_timing}        Immediate       TraceEnd
&{BTS_INFO}                 host=${mplane_ip}   port=443
${MCG_IP}    10.45.150.208
${MCG_usn}    inbabtslabuser
${MCG_pwd}    BT5l@bus3rl0g1n
${MCG_domain}      NOKLAB
${dcapusr}    utfuser
${dcappwd}    utfadmin!


*** Keywords ***

CB008796QOS_TC_001
    Wait Until Keyword Succeeds    5min    1s    Site_reset
    Wait Until Keyword Succeeds    5min    1s    Check BTS is OnAir    oam
    Get TcpdumpLogs from Remote machine    ${BTS_IP}    tcpdump
    Sleep    2min
    Prepare UE     UE_alias=${UE_alias_1}     capabilities=${capabilities_1}    timeout=${timeout}
    Detach and Attach UE    UE_alias=${UE_alias_1}
    Start_And_Stop_Volte_Call_using_adb_command    ${UE_alias_1}    ${capabilities_1}  ${UE1_start_Voice_call_cmd}    ${UE1_stop_Voice_call_cmd}
    sleep    30s
    stop tcpdumplogs    tcpdump
    ${output}=    Convert pcap file    s1ap.qCI == 1    tcpdump
    log to console    ${output}
    validate wireshark logs    ${output}    E-RABSetupRequest/Activate dedicated EPS bearer context request
    Sleep    600

    Counter_validation_PMQAP1    M8046C0    0
    Counter_validation_PMQAP1    M8046C1    0
    Counter_validation_PMQAP1    M8046C2    0
    Counter_validation_PMQAP1    M8046C3    0
    Counter_validation_PMQAP1    M8046C4    0
    Counter validation4    M8047C0    0
    Counter validation4    M8047C1    0
    Counter validation4    M8047C2    0
    Counter validation4    M8047C3    0
    Counter validation4    M8047C4    0
    Counter validation4    M8047C5    0
    Counter validation4    M8047C6    0
    Counter validation5    M8048C0    0
    Counter validation5    M8048C1    0
    Counter validation5    M8048C2    0
    Counter validation5    M8048C3    0
    Counter validation5    M8048C4    0
    Counter validation5    M8048C5    0
    Counter validation5    M8048C6    0
    Counter validation5    M8048C7    0
    Counter validation15    M8046C0    0
    Counter validation15    M8046C1    0
    Counter validation15    M8046C2    0
    Counter validation15    M8046C3    0
    Counter validation15    M8046C4    0

    Counter validation45    M8047C0    0
    Counter validation45    M8047C1    0
    Counter validation45    M8047C2    0
    Counter validation45    M8047C3    0
    Counter validation45    M8047C4    0

    Counter validation45    M8047C5    0
    Counter validation45    M8047C6    0

    Counter validation55    M8048C0    0
    Counter validation55    M8048C1    0
    Counter validation55    M8048C2    0
    Counter validation55    M8048C3    0
    Counter validation55    M8048C4    0
    Counter validation55    M8048C5    0
    Counter validation55    M8048C6    0
    Counter validation55    M8048C7    0

    Counter validation12    M8046C0    0
    Counter validation12    M8046C1    0
    Counter validation12    M8046C2    0
    Counter validation12    M8046C3    0
    Counter validation12    M8046C4    0

    Counter validation42    M8047C0    0
    Counter validation42    M8047C1    0
    Counter validation42    M8047C2    0
    Counter validation42    M8047C3    0
    Counter validation42    M8047C4    0
    Counter validation42    M8047C5    0
    Counter validation42    M8047C6    0

    Counter validation52    M8048C0    0
    Counter validation52    M8048C1    0
    Counter validation52    M8048C2    0
    Counter validation52    M8048C3    0
    Counter validation52    M8048C4    0
    Counter validation52    M8048C5    0
    Counter validation52    M8048C6    0
    Counter validation52    M8048C7    0



CB008796QOS_TC_002
    [Tags]    QC_680112    CRT    SBTS00
    Get TcpdumpLogs from Remote machine    ${BTS_IP}    tcpdump
    Sleep    2min
	Prepare UE     UE_alias=${UE_alias_1}     capabilities=${capabilities_1}    timeout=${timeout}
    Attach ue and run throughput    ${UE_alias_1}    dt_name=${dt_name_dl}    direction=${direction_dl}
    ...    throughput=${throughput_dl}  deviation=${deviation_dl}   timeout=${timeout}
    Start_And_Stop_Volte_Call_using_adb_command    ${UE_alias_1}    ${capabilities_1}  ${UE1_start_Voice_call_cmd}    ${UE1_stop_Voice_call_cmd}
    sleep    10
    stop tcpdumplogs    tcpdump
    ${output}=    Convert pcap file    s1ap    tcpdump
    sleep    30
    validate wireshark logs    ${output}    InitialContextSetupRequest/Attach
    validate wireshark logs    ${output}    InitialUEMessage/Attach
	validate wireshark logs    ${output}    E-RABSetupRequest/Activate dedicated EPS bearer context request
    sleep    200
    Counter validation_rrc_Signalling

CB008796QOS_TC_003
    Get TcpdumpLogs from Remote machine    ${BTS_IP}    tcpdump
    Sleep    2min
    Start UE Attach & Vilte Call
    sleep    30s
    stop tcpdumplogs    tcpdump
    ${output}=    Convert pcap file    (s1ap.e_RAB_ID == 8 && s1ap.e_RAB_ID == 7)    tcpdump
    validate wireshark logs    ${output}    E-RABSetupResponse
    sleep    200
    Vilte Counter validation

CB008796QOS_TC_004
    Get TcpdumpLogs from Remote machine    ${BTS_IP}    tcpdump
    Sleep    2min
    Dcap Start Trace SA
    Prepare UE     UE_alias=${UE_alias_1}     capabilities=${capabilities_1}    timeout=${timeout}
    Detach and Attach UE    UE_alias=${UE_alias_1}
    Start_And_Stop_Volte_Call_using_adb_command    ${UE_alias_1}    ${capabilities_1}  ${UE1_start_Voice_call_cmd}    ${UE1_stop_Voice_call_cmd}
    sleep    30
    Dcap Stop Trace and Get results SA    DCAPlog1
    stop tcpdumplogs    tcpdump
    sleep    30
	# EMIl log validation    rrcConnectionReconfiguration    DCAPlog1
    sleep    30

Attach ue and run throughput
    [Arguments]     ${UE_alias}    ${dt_name}    ${direction}    ${throughput}    ${deviation}    ${timeout}
    log	    ${dt_name}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    Sleep    60
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    Sleep    60
    Log To Console    UE Attach Successful
    Sleep    30
    ta_ultracaller.start_datatransfer  ${UE_alias}    ${CALL_type}    direction=${direction}
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction}    ${timeout}
    Log To Console    UE Data Transfer Successful
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    sleep    20
    Run Keyword And Continue On Failure  ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}
    ...		direction=${direction}   thrughtput=${throughput}    deviation=${deviation}

Vilte Counter validation
    sleep    5min
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=M8006C216    timeout=600    connection=oam
    ${a}=    Set Variable    ['BTS']['MRBTS-1024']['LNBTS-1024']['LNCEL-0']
    ${b}=    Set Variable    ['MCC-001']['MNC-01']['LTE_EPS_Bearer']['M8006C216']
    ${c}=    Set Variable    ${result${a}${b}}
    Log To Console    ${c}
    ${values}=    Get Dictionary Values    ${c}
	${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    'M8006C216' counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'>= '1'
    ...    log to console    'M8006C216' counter is getting pegged ${Total_Count} times.
    Run Keyword if    '${Total_Count}'< '1'    fail

Counter validation_rrc_Signalling
    sleep    5min
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=M8001C301    timeout=300    connection=oam
    ${a}=    Set Variable    ['BTS']['MRBTS-1024']['LNBTS-1024']['LNCEL-0']
    ${b}=    Set Variable    ['MCC-001']['MNC-01']['LTE_Cell_Load']['M8001C301']
    ${c}=    Set Variable    ${result${a}${b}}
    Log To Console    ${c}
    ${values}=    Get Dictionary Values    ${c}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    'M8001C301' counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'>= '1'
    ...    log to console    'M8001C301' counter is getting pegged ${Total_Count} times.
    Run Keyword if    '${Total_Count}'< '1'    fail


Counter validation_start
     [Arguments]    ${counter}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=300    connection=oam
    ${values}=    Get Dictionary Values    ${result['BTS']['MRBTS-1024']['LNBTS-1024']['LNCEL-0']['MCC-001']['MNC-01']
    ...		['LTE_Cell_Load']['${counter}']}
    ${sum_begin} =    Evaluate    sum(map(int, ${values}))
    Log To Console    ${sum_begin}
    Set test variable    ${sum_begin}

Counter_validation_PMQAP1
    [Arguments]    ${counter}    ${occurence}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=300    connection=oam
    ${a}=    Set Variable    ['BTS']['MRBTS-1024']['LNBTS-1024']['LNCEL-0']
    ${b}=    Set Variable    ['MCC-001']['MNC-01']['PMQAP-1']['LTE_Active_Users_and_Latency_Statistics_per_PMQAP_Profile']['${counter}']
    ${c}=    Set Variable    ${result${a}${b}}
    Log To Console    ${c}
    ${values}=    Get Dictionary Values    ${c}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'>='${occurence}'
    ...   log to console    ${counter} counter is pegging properlly
    ...   ELSE    fail

Counter validation4
    [Arguments]    ${counter}    ${occurence}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=300    connection=oam
    ${a}=    Set Variable    ['BTS']['MRBTS-1024']['LNBTS-1024']['LNCEL-0']
    ${b}=    Set Variable    ['MCC-001']['MNC-01']['PMQAP-1']['LTE_Data_Volume_and_Throughput_Statistics_per_PMQAP_Profile']['${counter}']
    ${c}=    Set Variable    ${result${a}${b}}
    Log To Console    ${c}
    ${values}=    Get Dictionary Values    ${c}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'>='${occurence}'
    ...    log to console    ${counter} counter is pegging properlly
    ...    ELSE    fail

Counter validation5
    [Arguments]    ${counter}    ${occurence}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=300    connection=oam
    ${a}=    Set Variable    ['BTS']['MRBTS-1024']['LNBTS-1024']['LNCEL-0']
    ${b}=    Set Variable    ['MCC-001']['MNC-01']['PMQAP-1']['LTE_ERAB_Statistics_per_PMQAP_Profile']['${counter}']
    ${c}=    Set Variable    ${result${a}${b}}
    Log To Console    ${c}
    ${values}=    Get Dictionary Values    ${c}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'>='${occurence}'
    ...    log to console    ${counter} counter is pegging properlly
    ...    ELSE    fail

Counter validation15
    [Arguments]    ${counter}    ${occurence}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=300    connection=oam
    ${a}=    Set Variable    ['BTS']['MRBTS-1024']['LNBTS-1024']['LNCEL-0']
    ${b}=    Set Variable    ['MCC-001']['MNC-01']['PMQAP-5']['LTE_Active_Users_and_Latency_Statistics_per_PMQAP_Profile']['${counter}']
    ${c}=    Set Variable    ${result${a}${b}}
    Log To Console    ${c}
    ${values}=    Get Dictionary Values    ${c}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'>='${occurence}'
    ...    log to console    ${counter} counter is pegging properlly
    ...    ELSE    fail

Counter validation45
    [Arguments]    ${counter}    ${occurence}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=300    connection=oam
    ${a}=    Set Variable    ['BTS']['MRBTS-1024']['LNBTS-1024']['LNCEL-0']
    ${b}=    Set Variable    ['MCC-001']['MNC-01']['PMQAP-5']['LTE_Data_Volume_and_Throughput_Statistics_per_PMQAP_Profile']['${counter}']
    ${c}=    Set Variable    ${result${a}${b}}
    Log To Console    ${c}
    ${values}=    Get Dictionary Values    ${c}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'>='${occurence}'
    ...    log to console    ${counter} counter is pegging properlly
    ...    ELSE    fail

Counter validation55
    [Arguments]    ${counter}    ${occurence}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=300    connection=oam
    ${a}=    Set Variable    ['BTS']['MRBTS-1024']['LNBTS-1024']['LNCEL-0']
    ${b}=    Set Variable    ['MCC-001']['MNC-01']['PMQAP-5']['LTE_ERAB_Statistics_per_PMQAP_Profile']['${counter}']
    ${c}=    Set Variable    ${result${a}${b}}
    Log To Console    ${c}
    ${values}=    Get Dictionary Values    ${c}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'>='${occurence}'
    ...    log to console    ${counter} counter is pegging properlly
    ...    ELSE    fail

Counter validation19
    [Arguments]    ${counter}    ${occurence}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=300    connection=oam
    ${a}=    Set Variable    ['BTS']['MRBTS-1024']['LNBTS-1024']['LNCEL-0']
    ${b}=    Set Variable    ['MCC-001']['MNC-01']['PMQAP-9']['LTE_Active_Users_and_Latency_Statistics_per_PMQAP_Profile']['${counter}']
    ${c}=    Set Variable    ${result${a}${b}}
    Log To Console    ${c}
    ${values}=    Get Dictionary Values    ${c}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'>='${occurence}'
    ...    log to console    ${counter} counter is pegging properlly
    ...    ELSE    fail

Counter validation49
    [Arguments]    ${counter}    ${occurence}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=300    connection=oam
    ${a}=    Set Variable    ['BTS']['MRBTS-1024']['LNBTS-1024']['LNCEL-0']
    ${b}=    Set Variable    ['MCC-001']['MNC-01']['PMQAP-9']['LTE_Data_Volume_and_Throughput_Statistics_per_PMQAP_Profile']['${counter}']
    ${c}=    Set Variable    ${result${a}${b}}
    Log To Console    ${c}
    ${values}=    Get Dictionary Values    ${c}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'>='${occurence}'
    ...    log to console    ${counter} counter is pegging properlly
    ...    ELSE    fail

Counter validation59
    [Arguments]    ${counter}    ${occurence}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=300    connection=oam
    ${a}=    Set Variable    ['BTS']['MRBTS-1024']['LNBTS-1024']['LNCEL-0']
    ${b}=    Set Variable    ['MCC-001']['MNC-01']['PMQAP-9']['LTE_ERAB_Statistics_per_PMQAP_Profile']['${counter}']
    ${c}=    Set Variable    ${result${a}${b}}
    Log To Console    ${c}
    ${values}=    Get Dictionary Values    ${c}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'>='${occurence}'
    ...    log to console    ${counter} counter is pegging properlly
    ...    ELSE    fail

Counter validation12
    [Arguments]    ${counter}    ${occurence}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=300    connection=oam
    ${a}=    Set Variable    ['BTS']['MRBTS-1024']['LNBTS-1024']['LNCEL-0']
    ${b}=    Set Variable    ['MCC-001']['MNC-01']['PMQAP-2']['LTE_Active_Users_and_Latency_Statistics_per_PMQAP_Profile']['${counter}']
    ${c}=    Set Variable    ${result${a}${b}}
    Log To Console    ${c}
    ${values}=    Get Dictionary Values    ${c}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'>='${occurence}'
    ...    log to console    ${counter} counter is pegging properlly
    ...    ELSE    fail

Counter validation42
    [Arguments]    ${counter}    ${occurence}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=300    connection=oam
    ${a}=    Set Variable    ['BTS']['MRBTS-1024']['LNBTS-1024']['LNCEL-0']
    ${b}=    Set Variable    ['MCC-001']['MNC-01']['PMQAP-2']['LTE_Data_Volume_and_Throughput_Statistics_per_PMQAP_Profile']['${counter}']
    ${c}=    Set Variable    ${result${a}${b}}
    Log To Console    ${c}
    ${values}=    Get Dictionary Values    ${c}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'>='${occurence}'
    ...    log to console    ${counter} counter is pegging properlly
    ...    ELSE    fail

Counter validation52
    [Arguments]    ${counter}    ${occurence}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=300    connection=oam
    ${a}=    Set Variable    ['BTS']['MRBTS-1024']['LNBTS-1024']['LNCEL-0']
    ${b}=    Set Variable    ['MCC-001']['MNC-01']['PMQAP-2']['LTE_ERAB_Statistics_per_PMQAP_Profile']['${counter}']
    ${c}=    Set Variable    ${result${a}${b}}
    Log To Console    ${c}
    ${values}=    Get Dictionary Values    ${c}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'>='${occurence}'
    ...    log to console    ${counter} counter is pegging properlly
    ...    ELSE    fail

Counter validation1111
    [Arguments]    ${counter}    ${occurence}
    ${result} =    CoamAdmin.get_pm_counters    counter_ids=${counter}    timeout=300    connection=oam
    ${a}=    Set Variable    ['BTS']['MRBTS-1024']['LNBTS-1024']['LNCEL-0']
    ${b}=    Set Variable    ['MCC-001']['MNC-01']['PMQAP-1']['LTE_Active_Users_and_Latency_Statistics_per_PMQAP_Profile']['${counter}']
    ${c}=    Set Variable    ${result${a}${b}}
    Log To Console    ${c}
    ${values}=    Get Dictionary Values    ${c}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    Log to Console    ${counter} counter is pegging : ${Total_Count} times
    Run Keyword if    '${Total_Count}'>'${occurence}'    pass

Volte_Call_using_adb_command_qos
    Log To Console    \n--adb execution--\n
    ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ${a}=     ta_ultracaller.require_ue  ue_alias=${UE_alias}   capabilities=${capabilities}
    log   ${a}
    ${out}=    ta_ultracaller._run_adbcommand    ${UE_alias}    ${adb_cmd_voice_call}
    sleep   30
    ${out}=    ta_ultracaller._run_adbcommand    ${UE_alias}    ${adb_cmd_stop_call}

Start UE Attach & Vilte Call
    [Tags]    FULL_RUN
    log to console     UE_1 to be prepared as vilte caller
    Prepare UE     UE_alias=${UE_alias_1}     capabilities=${capabilities_1}    timeout=${timeout}
    Detach and Attach UE    UE_alias=${UE_alias_1}
    sleep    50
    log to console     UE_2 to be prepared as vilte callee
    Prepare UE     UE_alias=${UE_alias_2}     capabilities=${capabilities_2}    timeout=${timeout}
    Detach and Attach UE    UE_alias=${UE_alias_2}
    sleep    50
    adb_command_execution_vilte_call

adb_command_execution_vilte_call
    Log To Console    \n--adb command execution for vilte call start and end--\n
    ta_ultracaller.Require UE   ue_alias=${UE_alias_1}   capabilities=${capabilities_1}
    ${out}=    ta_ultracaller._run_adbcommand    ${UE_alias_2}    ${adb_cmd_vilte_call}
    Log To Console    \n--adb command ${adb_cmd_vilte_call} is issued to UE2--\n
    sleep   5
    ${out}=    ta_ultracaller._run_adbcommand    ${UE_alias_1}    ${adb_cmd_answer_video_call_on_UE2}
    Log To Console    \n--adb command ${adb_cmd_answer_video_call_on_UE2} is issued to UE1--\n
    sleep   30
    ${out}=    ta_ultracaller._run_adbcommand    ${UE_alias_2}    ${adb_cmd_stop_video_call}
    Log To Console    \n--adb command ${adb_cmd_stop_video_call} is issued to UE2--\n

Starting Voice Call
    ta_ultracaller.start voice call    ue_alias=${UE_alias_1}    testcasename=${dt_name_v}
    Log To Console    UE voice call Successfully started

Stopping Voice Call
    ta_ultracaller.stop voice call    ue_alias=${UE_alias_1}
    Log To Console    UE voice call Successfully stopped

Convert pcap file_new
    core.stop_collectors    names=tcpdump
    core.collect_collectors    names=tcpdump
    core.teardown_collectors    names=tcpdump
    ${log}=    Validate_tshark    ${out}    filter=s1ap
    [Return]    ${log}

Start data traffic
    [Arguments]     ${UE_alias}    ${dt_name}    ${direction}    ${throughput}    ${deviation}    ${timeout}    ${capabilities}
    ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ${a}=     ta_ultracaller.require_ue  ue_alias=${UE_alias}   capabilities=${capabilities}
    ta_ultracaller.start_datatransfer  ${UE_alias}  ${dt_name}  direction=${direction}
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction}    ${timeout}
    Log To Console    UE Data Transfer Successful
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    sleep    20
    ${tput}    Run Keyword And Continue On Failure  ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}
    ...    direction=${direction}   thrughtput=${throughput}    deviation=${deviation}
    log to console    Throughput is ${tput}


CB008796_CB012646_TC_ASOG_cover_LTE
    [Tags]    QC_680112    CRT    SBTS00
	Prepare UE     UE_alias=${UE_alias_1}     capabilities=${capabilities_1}    timeout=${timeout}
    Attach ue and run throughput    ${UE_alias_1}    dt_name=${dt_name_dl}    direction=${direction_dl}
    ...    throughput=${throughput_dl}  deviation=${deviation_dl}   timeout=${timeout}
    Sleep    30