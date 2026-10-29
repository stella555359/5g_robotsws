*** Settings ***
Documentation
...   Description: Test Suite for RJIO CNI
Test Setup      Common_Test_Setup
Test Teardown   Common_Test_Teardown
Resource    resources/keywords_HO_RJIO.robot
#Resource    resources/expected_alarm.robot
#Library    resources/RJIO.py
Library    resources/pva_target_to_source.py
Library    resources/pva_source_to_target.py

*** Variables ***
${IS_EMIL_START_REQUIRED}    FALSE
${IS_WIRESHARK_START_REQUIRED}    TRUE
${IS_LOG_VALIDATION_REQUIRED}    FALSE
${NO_OF_ITTERATIONS_IRAT}    1
${NO_OF_ITTERATIONS_XNAP}    1
${NO_OF_ITTERATIONS_NGAP}    1
${NO_OF_ITTERATIONS_EPSFB}    1
${DURATION}    800s
${BTS_Login_IP}    192.168.255.129
${VM_IP}    10.58.238.158
${VM_IP_2}    10.58.238.130
${VM_usn}   ute
${VM_pwd}   BT5l@bus3rl0g1n
${source_BTS_IP_Mplane}    10.58.239.157
${target_BTS_IP_Mplane}    10.58.239.155
${SCF_XNAP_NGAP_HO_CONFIGURATION_SOurce}    resources/Configuration_scf_MRBTS-1057_XNAP_NGAP_scf.xml
${SCF_IRAT_HO_CONFIGURATION_SOurce}    resources/Configuration_scf_MRBTS-1057_IRAT_scf.xml
${MCG_IP}    10.45.150.198
${MCG_usn}    inbabtslabuser
${MCG_pwd}    BT5l@bus3rl0g1n
${MCG_domain}      NOKLAB
@{capabilities}    Legacy_1   #s1ho activate
@{throughput_dl}    450000
@{throughput_ul}    37000
${dt_name_v}   test_voice_call
@{UE_alias}=  UE2    #s1ho ue
@{direction_dl}=      dl
@{direction_ul}=      ul
${timeout}    60
@{deviation_dl}=      30
@{deviation_ul}=      10
@{call_type}=    UDP
${status}    None
${k}
${connection}
${output1}    None

@{list}

${filter_4G}    s1ap.UEContextReleaseCommand_element && s1ap.radioNetwork==successful-handover
${filter_5G}    ngap.UEContextReleaseCommand_element && ngap.radioNetwork==successful-handover
${filter_XNAP}    xnap.HandoverRequestAcknowledge_element && xnap.PathSwitchRequestAcknowledge_element
${filter_NGAP}    ngap.UEContextReleaseCommand_element && ngap.radioNetwork==successful-handover

${file_path}   /home/ute/pcap_log/

*** Test Cases ***

IRAT
    ${out}    set variable
    ...    ${OUTPUT_DIR}/
    set test variable    ${out}
    create directory     ${out}
    Create_Folder_Structure    ${out}
    CoamAdmin.unlock     dist_name=MRBTS-1056/LNBTS-1/LNCEL-1    timeout=60    connection=oam1
    CoamAdmin.lock      dist_name=MRBTS-1056/NRBTS-1056/NRCELL-4     timeout=60    connection=oam1
	Fetch_Counters_Before_Execution
    PVA_STARTUP_SOURCE_TO_TARGET
    Log To Console    Attenuator set to default
    Run Keyword If    "${IS_WIRESHARK_START_REQUIRED}"=='TRUE'    Get TcpdumpLogs from Remote machine
    Run Keyword If    "${IS_WIRESHARK_START_REQUIRED}"=='TRUE'    Get_target TcpdumpLogs from Remote machine
    Start Prepare UE & Attach UE
    Run throughput   UE_alias=${UE_alias}   call_type=${call_type}   direction=${direction_dl}   timeout=${timeout}    throughput=${throughput_dl}
    FOR    ${i}    IN RANGE    ${NO_OF_ITTERATIONS_XNAP}
        PVA_TRIGGER_SOURCE_TO_TARGET_IRAT
        Log to console    Source to target attenuation successful
        sleep    10s
        ${output}=    Convert_pcap_file_IRAT_HO    ngap    IRAT
        log to console    ${output}
        validate wireshark logs    ${output}   HandoverRequired
        validate wireshark logs    ${output}   HandoverCommand
        validate wireshark logs    ${output}   UEContextReleaseCommand
        log to console    validation sucessful at source GNB
        ${output1}=    Convert1_pcap_file_IRAT_HO    s1ap    IRAT
        log to console    ${output1}
        validate wireshark logs    ${output1}   HandoverRequest
        validate wireshark logs    ${output1}   HandoverRequestAcknowledge
        validate wireshark logs    ${output1}   HandoverNotify
        log to console    validation sucessful at target GNB
        Log to console    This is loop number:-
        Log to console    ${i}
        Run Keyword if    ${i}%20 == 0    Run Keywords   Check latest BTS Faults
        #...               AND   ${j}     set variable    0
    END
	Check_Counter_validation
    CoamAdmin.unlock      dist_name=MRBTS-1056/NRBTS-1056/NRCELL-4     timeout=60  connection=oam1
    CoamAdmin.lock      dist_name=MRBTS-1056/LNBTS-1/LNCEL-1     timeout=60  connection=oam1


*** Keywords ***

Fetch_Counters_Before_Execution
    ${C1}  NRRCC_MEAS_B2_REC    M55124C02001
    set test variable    ${C1}
    log to console    counter value of M55124C02001 before execution: ${C1}
    ${C3}  NNGCC_IRATHO_ATT    M55125C02001
    set test variable    ${C3}
    log to console    counter value of M55125C02001 before execution: ${C3}
	${C5}  NNGCC_IRATHO_SUC    M55125C02002
    set test variable    ${C5}
    log to console    counter value of M55125C02002 before execution: ${C5}
    ${C7}  NNGCC_IRATHO_EXE_SUC    M55125C02006
    set test variable    ${C7}
    log to console    counter value of M55125C02006 before execution: ${C7}

Check_Counter_validation
    log to console    wait timer of 6min started for counter pegging
    sleep    6min
    ${C2}    NRRCC_MEAS_B2_REC    M55124C02001
    log to console    counter value of M55124C02001 after execution: ${C2}
    Counter value validation    ${C1}    ${C2}
    ${C4}    NNGCC_IRATHO_ATT    M55125C02001
    log to console    counter value after of M55125C02001 execution: ${C4}
    Counter value validation    ${C3}    ${C4}
	${C6}    NNGCC_IRATHO_SUC    M55125C02002
    log to console    counter value of M55125C02002 after execution: ${C6}
    Counter value validation    ${C5}    ${C6}
    ${C8}    NNGCC_IRATHO_EXE_SUC    M55125C02006
    log to console    counter value after of M55125C02006 execution: ${C8}
    Counter value validation    ${C7}    ${C8}


NRRCC_MEAS_B2_REC
    [Arguments]    ${counter}
    ${result} =    CoamAdmin.get_pm_counters    couter_ids=${counter}    timeout=100    connection=oam
    #log to console    ${result}
    ${values}=    Get Dictionary Values    ${result['BTS']['MRBTS-1057']['NRBTS-1057']['NRCELL-2']['NRRCC']['${counter}']}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    [Return]    ${Total_Count}

NNGCC_IRATHO_ATT
    [Arguments]    ${counter}
    ${result} =    CoamAdmin.get_pm_counters    couter_ids=${counter}    timeout=100    connection=oam
    #log to console    ${result}
    ${values}=    Get Dictionary Values    ${result['BTS']['MRBTS-1057']['NRBTS-1057']['NRCELL-2']['NNGCC']['${counter}']}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    [Return]    ${Total_Count}

NNGCC_IRATHO_SUC
    [Arguments]    ${counter}
    ${result} =    CoamAdmin.get_pm_counters    couter_ids=${counter}    timeout=100    connection=oam
    #log to console    ${result}
    ${values}=    Get Dictionary Values    ${result['BTS']['MRBTS-1057']['NRBTS-1057']['NRCELL-2']['NNGCC']['${counter}']}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    [Return]    ${Total_Count}

NNGCC_IRATHO_EXE_SUC
    [Arguments]    ${counter}
    ${result} =    CoamAdmin.get_pm_counters    couter_ids=${counter}    timeout=100    connection=oam
    #log to console    ${result}
    ${values}=    Get Dictionary Values    ${result['BTS']['MRBTS-1057']['NRBTS-1057']['NRCELL-2']['NNGCC']['${counter}']}
    ${Total_Count}=    Get_value_of_Counter    ${values}
    [Return]    ${Total_Count}

Get_value_of_Counter
    [Arguments]    ${Counter_value}
    ${k}    set variable    0
    FOR    ${a}    IN    @{Counter_value}
        ${k}    Evaluate    ${k} + ${a}
    END
    [Return]    ${k}

Counter value validation
    [Arguments]    ${counter1}    ${counter2}
    ${counter_value}    Evaluate    int(${counter2})-int(${counter1})
    Run Keyword If    "${counter_value}" == "0"
    ...    log to console    Value of the counter is "${counter_value}", and its not pegging correctly
    ...    ELSE    log to console    Value of the counter is "${counter_value}", and its pegging correctly
    Run Keyword If    "${counter_value}" == "0"    fail
