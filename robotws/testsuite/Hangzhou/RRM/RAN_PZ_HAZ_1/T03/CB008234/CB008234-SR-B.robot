*** Settings ***
Documentation
...   author: Dong tony
...   contact: tony.1.dong@nokia-sbell.com
...   this is a robot case about CB008234-SR-B.

Resource          ../Resources/common_resource.robot
Force Tags        CRT    RAN_5G    CLOUD_5G_CLASSICAL_ANDROID_SA_CA_ASIBL_ABIOB1_AHEH    STATE_SKIP_AGENT
...               SBTS00   CA_RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG07_ST_RRM    TA_LEVEL_22
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM

*** Variables ***
${host}              10.56.218.70
${username}          ute
${password}          Nokia123!
${parameter}         actUlAmbr
${file_path1}         ${CURDIR}/PDU_AMBR.txt
${file_path2}         ${CURDIR}/UE_AMBR.txt
#${DEBUG_MODE}        ${TRUE}
${dist_name}           MRBTS-306/NRBTS-306
&{fault_2002}            faultId=${2002}

*** Test Cases ***
USCB008234-B#B1: UL UE AMBR Enforcement on FDD with one UE
    [Documentation]
    ...    author: tony.1.dong@nokia-sbell.com
    [Tags]    10_5_UTE5GTL306    SCF_10_5_UTE5GTL306_CB008234_case1    CB008234_1
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes

    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path1}
    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path2}

    ADB.Prepare UE
    ADB.UE Attach
    sleep    30s
    Log To Console    senddata

	Start UL Traffic    tport=${5001}    server_ip=10.56.218.68
    sleep    10s


    #${dl_server1}    Connect To IperfServer From Appservers
    #Start DL traffic By Iperf    time=3600    traffic=100.00M    dl_server=${dl_server1}
    #...    DL_port=${5001}

	Sleep    6 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Counter Check    starttime=${start_time}    endtime=${end_time}

USCB008234_B_B1_UL_UE_AMBR_Enforcement_with_disable_feature_and_enable_it_back
    [Documentation]
    ...    author: tony.1.dong@nokia-sbell.com
    [Tags]    10_5_UTE5GTL306    SCF_10_5_UTE5GTL306_CB008234_case1    CB008234_2
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes

    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path1}
    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path2}

    ADB.Prepare UE
    ADB.UE Attach
    Log To Console    senddata

	Start UL Traffic    tport=${5001}    server_ip=10.56.218.68
    sleep    30s

    Change CB008234_actUlAmbr_disabled
    sleep    30s

    Change CB008234_actUlAmbr_SA

	Sleep    5 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Counter Check    starttime=${start_time}    endtime=${end_time}

USCB008234_B_B3_UL_AMBR_limitation_handling_during_ICS_with_PDU_session_setup
    [Documentation]
    ...    author: tony.1.dong@nokia-sbell.com
    [Tags]    10_5_UTE5GTL306    SCF_10_5_UTE5GTL306_CB008234_case1    CB008234_3

    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path1}
    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path2}

	sleep    10s

    Start tcpdump by command For Remote
    Sleep    10s

	ADB.Prepare UE
    ADB.UE Attach
    sleep    30s

	Stop tcpdump And download by command For Remote
    sleep    30s

    ${capture_file_path_source}    Download wireshark log to testvm For Remote
    sleep    30s

    Check BitRate UEContextSetupRequest In Wireshark Log    ${capture_file_path_source}

USCB008234_D_B16_DL_UE_AMBR_interworking_with_CA_FDD_intraband_2CC
    [Documentation]
    ...    author: tony.1.dong@nokia-sbell.com
    [Tags]    10_5_UTE5GTL306    SCF_10_5_UTE5GTL306_CB008234_case1    CB008234_4
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes

    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path1}
    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path2}

    ADB.Prepare UE
    ADB.UE Attach
    sleep    30s
    Log To Console    senddata

	Start UL Traffic    tport=${5001}    server_ip=10.56.218.68
    sleep    10s

    ${dl_server1}    Connect To IperfServer From Appservers
    Start DL traffic By Iperf    time=900    traffic=80.00M    dl_server=${dl_server1}
    ...    DL_port=${5001}

	Sleep    6 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Counter Check    starttime=${start_time}    endtime=${end_time}

*** Keywords ***
Case Setup
    Log To Console    Case Setup

Case Teardown
    Log To Console    Case Teardown
    # Run Keyword And Ignore Error    AT.UE Detach
    Run Keyword And Ignore Error    Disconnect All VM

# Run Cmd Of File In Remote Server
#     [Arguments]  ${host}    ${username}    ${password}    ${file_path}
#     ${context}    Get File    ${file_path}
#     csn.Connect To    hostname=${host}    username=${username}    password=${password}    alias=remote_server_${host}
#     csn.Execute    command=${context}    connection=remote_server_${host}
#    # Should Contain ${ret}, result\="success"
#     ssh .Disconnect    connection=remote_server_${host}

Counter Check
    [Arguments]    ${starttime}    ${endtime}
    PM_counters_collector
    ${pi_list}    Create List    M55319C16007    M55319C12007
    ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
    ...    ${pi_list}
    Log To Console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55319C16007
    ${sum_2_val}    Sum Counter Value Of Pi Value List    ${value1}    M55319C12007
	Should be true    ${sum_1_val}<${300000}
    Should be true    ${sum_2_val}<${2000000}

Start UL Traffic
    [Arguments]    ${tput}=5M    ${tport}=5001    ${server_ip}=${spark_iperf_server}
    Connect All VM
    ADB.Start Traffic
    ...    tput_type=UL
    ...    server_ip=${server_ip}
    ...    server_connection=BTS0_VM
    ...    client_connection=cpc_0
    ...    client_iperf_path=/data/data/com.nokia.android.application/iperf
    ...    tput_port=${tport}
    ...    tput_value=${tput}
    ...    tput_time=3000s

Change CB008234_actUlAmbr_disabled
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${value}    Set Variable    disabled
    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}
    ...    value=${value}    operation=update    connection=commission
    [Teardown]    COAM_Admin.Logout    connection=commission

Change CB008234_actUlAmbr_SA
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${value}    Set Variable    SA
    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}
    ...    value=${value}    operation=update    connection=commission
    [Teardown]    COAM_Admin.Logout    connection=commission

Check BitRate UEContextSetupRequest In Wireshark Log
    [Arguments]  ${capture_file_path}
    ${output}    Parse Pcap by expression    filter_expression=f1ap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    UEContextSetupRequest

    ${output}    Parse Pcap by expressionbackup
    ...    filter='f1ap.BitRate == 5000000'
    ...    filter_expression='f1ap.BitRate == 5000000'
    ...    input_file=${capture_file_path}

Check DL data limit by UE AMBR
    [Arguments]    ${starttime}    ${endtime}
    PM_counters_collector
    ${pi_list}    Create List    M55319C12007
    ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
    ...    ${pi_list}
    Log To Console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55319C16007
	Should be true    ${sum_1_val}<${300000}
