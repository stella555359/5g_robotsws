*** Settings ***
Documentation     author: Bijiajian
...               contact: Jiajian.bi@nokia-sbell.com
...               squad group: SG_02
Suite Setup       Common Suite Setup for COAM
Suite Teardown    Common Suite Teardown
Force Tags        5G_RRM
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Resources/Resource_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          Resources/1347_common_keyword.robot
Resource          Resources/common_keyword_RRM_SG2.robot

*** Variables ***
${scf_path}    /home/ute/Downloads/SCF

@{counter}    M40002C0    M40002C1    M40002C2    M40003C0    M40003C1    M40003C2    M40003C3    M40003C4    M40003C5
...    M40004C0    M40004C1    M40004C2    M40004C3    M40004C4    M40004C5
@{counter_m}    M40002C0    M40003C0    M40004C0

@{check_print}    ERR/

*** Test Cases ***
CB007777-5G-C_02_01_General_SiSo_Power_Meter_counter_update_for_energy_consumption_on_AEHC
    [Tags]    CRT    CB007777
    [Setup]    Case Setup
    Reload Case SCF and Commission    scf_file=${scf_path}/${version}/CB007777.xml
    Modify parameter online    dist_name=MRBTS-1031/MNL-1/MNLENT-1/PMMNL-1    parameter=mtBtsEnergyMonitoring    value=30min
    Modify parameter online    dist_name=MRBTS-1031/MNL-1/MNLENT-1/PMMNL-1    parameter=mtSBTSRfmEnergyMonitoring    value=30min
    Modify parameter online    dist_name=MRBTS-1031/MNL-1/MNLENT-1/PMMNL-1    parameter=mtSBTSSmEnergyMonitoring    value=30min
    sleep    90min
    Check Counter modify
    Connect to gnb coam via ssl
    Lock RU and Check Status
    sleep    2min
    Unlock RU and Check Status
    sleep    30min
    Check Counter lock ru
    [Teardown]    Case Teardown

*** Keywords ***
Common Suite Setup for COAM
    robot_common_operations.Common Suite Setup
    check pdl after sw update    download_dir=/home/ute/Downloads

Common Suite Teardown
    robot_common_operations.Common Suite Teardown

Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    robot_common_operations.Common Case Setup
    Set Test Variable     ${version}     ${result}[0]

Case Teardown
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Run keyword and ignore error    COAM Teardown gnb connections
    Run keyword and ignore error    CI_interface.Common Case Teardown

Check Counter
    [Arguments]    ${val}=${100}
    FOR  ${coun}  IN  @{counter}
        ${value}    Check BTS Counters via webUI    counter_id=${coun}
        should be true    ${value}[-1]>=${val}
	    ${length}    get length    ${value}
        Set Test Variable    ${length1}    ${length}
    END

Check Counter disable
    ${value}    Check BTS Counters via webUI    counter_id=${counter_m}[0]
	${length1}    get length    ${value}
    ${value}    Check BTS Counters via webUI    counter_id=${counter_m}[1]
	${length2}    get length    ${value}
    ${value}    Check BTS Counters via webUI    counter_id=${counter_m}[2]
	${length3}    get length    ${value}
    sleep    15min
    ${value}    Check BTS Counters via webUI    counter_id=${counter_m}[0]
	${length}    get length    ${value}
    should be true    ${length1}==${length}
    ${value}    Check BTS Counters via webUI    counter_id=${counter_m}[1]
	${length}    get length    ${value}
    should be true    ${length2}==${length}
    ${value}    Check BTS Counters via webUI    counter_id=${counter_m}[2]
	${length}    get length    ${value}
    should be true    ${length3}==${length}

Check Counter modify
    [Arguments]    ${val}=${100}
    FOR  ${coun}  IN  @{counter_m}
        ${keys}    ${values}    Check BTS Counters with time    counter_id=${coun}
	    should be true    ${values}[-1]>=${val}
	    ${time_d}    subtract date from date    ${keys}[-1]    ${keys}[-2]
        should be true    ${time_d}==1800.0
    END

Check Counter lock ru
    ${value}    Check BTS Counters via webUI    counter_id=M40002C2
    should be true    ${value}[-1]<${value}[-3]-500

Modify parameter online
    [Arguments]    ${dist_name}    ${parameter}    ${value}
    &{param}    Create Dictionary    dist_name=${dist_name}    parameter=${parameter}    value=${value}
    @{modify_param}    Create List    ${param}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    timeout=600

Check M4003C value
    Connect to Common Unit Master
    ${connection}    csn.get_connection_by_alias    alias=ASIK Master
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n 0x1018\n
    wait until keyword succeeds    10x    1sec    Output contain match    ${channel}    FHNET00
    Call Method    ${channel}    send    ssh -o StrictHostKeyChecking\=no rfsw@172.22.0.2\n
    wait until keyword succeeds    10x    1sec    Output contain match    ${channel}    password:
    Call Method    ${channel}    send    bdS%ztWG3v7%SjreCVA79wTPb\n
    wait until keyword succeeds    10x    1sec    Output contain match    ${channel}    stratix10-aehb
    Call Method    ${channel}    send    frmonShellClient localhost 2000\n
    sleep    3s
    ${action}    set variable    / action create PsuMeasurements /CI/PsuMeasurements /module/psu1
    Call Method    ${channel}    send    ${action}\n
    sleep    3s
    ${output}    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    /CI/PsuMeasurements action measure\n
    sleep    15s
    #wait until keyword succeeds    10x    2sec    Output contain match    ${channel}    done
    ${output}    Call Method    ${channel}    recv    ${65535}

Reload Case SCF and Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'

Lock RU and Check Status
    Perform RU lock via rest api      ru_idx=${4}      timeout=90
    Wait until keyword succeeds    3min    20 sec    RU Should Be Locked    ru_index=${4}

Unlock RU and Check Status
    Perform RU unlock via rest api    ru_idx=${4}
    COAM Wait for gnb ready and cell setup
    RU Should Be Unlocked    ru_index=${4}

Check BTS Counters with time
    [Arguments]    ${counter_id}    ${count_path}=${None}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${counters}    selenium_coam.get_bts_counters_info    counter_id=${counter_id}    full_path=${count_path}
    COAM selenium logout
    ${keys}    Get Dictionary Keys    ${counters}
    ${values}    Get Dictionary Values    ${counters}
    [Return]    ${keys}    ${values}
