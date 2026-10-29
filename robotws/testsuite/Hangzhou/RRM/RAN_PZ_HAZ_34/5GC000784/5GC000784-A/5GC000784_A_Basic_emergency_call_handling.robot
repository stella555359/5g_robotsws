*** Settings ***
Force Tags    PY36
Documentation     author: yifan hu
...                 contact: yifan.hu@nokia-sbell.com
...                 squad group: SG_03
...                 feature : 5GC000784-A

Resource    ./Resources/5GC000784_common_keyword.robot
Variables    ./Resources/5GC00784_A_variables.py


Suite Setup    Run Keywords
...    robot_common_operations.Common Suite Setup    AND
...    Common Suite Setup for COAM    AND
...    Common Case TestLine Setup for 784-A    AND
...    Get release info    AND
...    Adjust gNB_RU Attenuation    AND
...    Adjust enb attenuation

Suite Teardown    Run Keywords
...            Common Suite Teardown for COAM    AND
...            Common Case TestLine Setup    Is_Swconfig=True    swconfig_file=${swconfig}    AND
...            Adjust gNB_RU Attenuation    AND
...            Adjust enb attenuation


*** Variables ***
${gnb_path}    /tmp
${enb_path}    /tmp/
${tl_scf_file_name}    7326_784_SCF
${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/
${swconfig}    /opt/workspace/CRT/Master/SCF_file/swconfig.txt
${swconfig_784A11}    /opt/workspace/CRT/Master/SCF_file/swconfig_784A11.txt
${scf_file_enb}    784_AB_eNB.xml
${interface1}    any
${interface_s1ap}    br1
${nglogname1_1st}    784A01_1st.pcap
${nglogname1_2nd}    784A01_2nd.pcap
${nglogname3_fail}    784A03_fail.pcap
${nglogname3_success}    784A03_success.pcap
${nglogname6_1}    784A06_idle.pcap
${nglogname6_2}    784A06_EC_1st.pcap
${nglogname6_3}    784A06_EC_2nd.pcap
${nglogname11_1}    784A11_fail.pcap
${nglogname11_2}    784A11_epsfallback.pcap
${enblogname11}    784A11_enb.pcap
${nglogname19_1}    784A19_fail.pcap
${nglogname19_2}    784A19_success.pcap
${nglogname21_1}    784A21_success.pcap
${nglogname21_2}    784A21_fail.pcap
${nglogname22_1}    784A22_idle.pcap
${nglogname22_2}    784A22_fail.pcap
${nglogname22_3}    784A22_success.pcap
${nglogname26}    784A26.pcap
${nglogname29}    784A29.pcap
${enb_instance}    ${tl.enbs[0].instance_id}
${nomal_call_number}    6688
${EC_number}    911

*** Test Cases ***
[1]5GC000784_A_11_Verify_EC_redirect_to_LTE_due_to_ICS_with_5QI5_CU_RAC_failed_and_Verify_emergencyCallFails
    [Documentation]
    [Tags]    CRT_TRUNK    5GC000784-A    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1
    Modify NIDD parameter for 784_A   parameters_to_update=${PARAMETERS_TO_UPDATE_A11_preparation}
    Check the gnb cell status onair
    Modify NIDD parameter for 784_A   parameters_to_update=${PARAMETERS_TO_UPDATE_COUNTER}
    Check the gnb cell status onair
    Comment    20250604 add PA =20,RSRP -66db，before RSRP -44db
    Adjust gNB_RU Attenuation    gnb1_cell1_value=${20}
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
    Power UE Attach and Verify attach
    Modify NIDD parameter for 784_A    parameters_to_update=${PARAMETERS_TO_UPDATE_A11_1}
    Check the gnb cell status onair
    Make a failed EC and check procedure    nglogname=${nglogname11_1}    check_5QI=1
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${0}
#    Stop capture syslog via btslog on ute
    Modify NIDD parameter for 784_A    parameters_to_update=${PARAMETERS_TO_UPDATE_A11_2}
    Check the gnb cell status onair
    Power UE Attach and Verify attach
    Modify NIDD parameter for 784_A    parameters_to_update=${PARAMETERS_TO_UPDATE_A11_1}
    Check the gnb cell status onair
    Adjust enb attenuation    enb_cell_value=${0}
    Prepare with PM counter time to caculate    period=start
    sleep    60s
    Make a EC and check EPS fallback
    Prepare with PM counter time to caculate    period=end
    sleep    60s
    Check the PM counter shuould not be zero    counter_id=${counter_id_A29_1}    dic_path=${counter_dic_path_A29_1}
    Check the PM counter shuould be specific value    value=${0}
    ...    counter_id=${counter_id_A29_0}    dic_path=${counter_dic_path_A29_0}
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure
    ...    COAM Save all gnb snapshot via api    gnb_list=${gnb_list}    log_path=${log_path}    AND
#    ...    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute    AND
#    ...    get and analysis syslog    AND
    ...    Modify NIDD parameter for 784_A   parameters_to_update=${PARAMETERS_TO_UPDATE_A11_restore}    AND
    ...    Check the gnb cell status onair    AND
    ...    Check Unexpect Alarm whether exist    AND
    ...    Run Keyword And Ignore Error    784-A case teardown

#[1]5GC000784_A_21_Verify_ongoing_EC_should_not_be_impact_after_online_change_actIMSEmergency_to_deactivate_2UE
#    [Documentation]
#    [Tags]    CRT_TRUNK    5GC000784-A    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#    [Setup]    robot_common_operations.Common Case Setup
#    RUN KEYWORD IF    '${gnb_instance}'=='${gnb_id[1]}'
#    ...    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1
#    ...    ELSE    Prepare Xiaomi UE
#    Lock LTE
#    Modify NIDD parameter for 784_A    parameters_to_update=${PARAMETERS_TO_UPDATE_A21_preparation}
#    RUN KEYWORD IF    '${gnb_instance}'=='${gnb_id[1]}'    Attach and check power UE    ue_type=${ue_type}
#    ...    ELSE    Power UE Attach and Verify attach
#    Modify NIDD parameter for 784_A    parameters_to_update=${PARAMETERS_TO_UPDATE_A21_1}
#    Make a EC_Modify param_check EC ongoing    nglogname=${nglogname21_1}
#    ...    parameters_to_update=${PARAMETERS_TO_UPDATE_A21_2}
#    Make a failed EC and check procedure    nglogname=${nglogname21_2}    check_5QI=5
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    784-A case teardown

*** Keywords ***
Common Case TestLine Setup for 784-A
    ${release}=    Get sagnb release title
    set suite variable    ${release}
    Common Case TestLine Setup    is_commission=True    scf_path=${tl_scf_dir_path}
    ...    golden_scf_name=${tl_scf_file_name}_${release}.xml
    ...    Is_Swconfig=True    swconfig_file=${swconfig_784A11}
    Unlocked LTE cell 388

Make a EC and check successful procedure
    [Arguments]    ${nglogname}    ${ue_index}=${0}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface1}    connection=Local gnb1
    Connect to control pc via cygwin    ue_index=${ue_index}
    RUN KEYWORD IF    '${gnb_instance}'!='${gnb_id[0]}'    Make EMC call on samsung UE
    ...    ELSE    Start a emergency call
    Run Keyword If    '${gnb_instance}'!='${gnb_id[0]}'    hang up EMC call on samsung UE
    ...    ELSE    Stop the emergency call
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}    connection=Local gnb1
    Check wireshark log for successful EC procedure    logname=${nglogname}
    csn.disconnect      connection=cygwin

Make a EC and check successful procedure_idle status
    [Arguments]    ${nglogname}    ${ue_index}=${0}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface1}    connection=Local gnb1
    Connect to control pc via cygwin    ue_index=${ue_index}
    RUN KEYWORD IF    '${gnb_instance}'!='${gnb_id[0]}'    Make EMC call on samsung UE
    ...    ELSE    Start a emergency call
    Run Keyword If    '${gnb_instance}'!='${gnb_id[0]}'    hang up EMC call on samsung UE
    ...    ELSE    Stop the emergency call
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}    connection=Local gnb1
    Check wireshark log for successful EC procedure_idle    logname=${nglogname}
    csn.disconnect      connection=cygwin

Make another EC and detach and check successful procedure
    [Arguments]    ${nglogname}    ${ue_index}=${0}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface1}    connection=Local gnb1
    Connect to control pc via cygwin    ue_index=${ue_index}
    RUN KEYWORD IF    '${gnb_instance}'!='${gnb_id[0]}'    Make EMC call on samsung UE
    ...    ELSE    Start a emergency call
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}    connection=Local gnb1
    Check wireshark log for successful EC and detached release_idle    logname=${nglogname}
    csn.disconnect      connection=cygwin
    [Teardown]    kill the call procedure

Make a failed VONR call and check procedure
    [Arguments]    ${nglogname}    ${check_5QI}    ${ue_index}=${0}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface1}    connection=Local gnb1
    Connect to control pc via cygwin    ue_index=${ue_index}
    Start a VONR call
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}    connection=Local gnb1
    Run Keyword If    '${check_5QI}'=='1'    Check wireshark log for failed VoNR call_5QI1    logname=${nglogname}
    Run Keyword If    '${check_5QI}'=='5'    Check wireshark log for failed VoNR call_5QI5    logname=${nglogname}
    csn.disconnect      connection=cygwin
    [Teardown]    kill the call procedure

Make a EC_Modify param_check EC ongoing
    [Arguments]    ${nglogname}    ${parameters_to_update}    ${ue_index}=${0}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface1}    connection=Local gnb1
    Connect to control pc via cygwin    ue_index=${ue_index}
    RUN KEYWORD IF    '${gnb_instance}'!='${gnb_id[0]}'    Make EMC call on samsung UE
    ...    ELSE    Start a emergency call
    Modify NIDD parameter for 784_A    parameters_to_update=${parameters_to_update}
    sleep    10s
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}    connection=Local gnb1
    Check wireshark log for EC ongoing    logname=${nglogname}
    csn.disconnect      connection=cygwin
    [Teardown]    kill the call procedure

Make a failed EC and check procedure
    [Arguments]    ${nglogname}    ${check_5QI}    ${ue_index}=${0}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface1}    connection=Local gnb1
    Connect to control pc via cygwin    ue_index=${ue_index}
    Make EMC call on samsung UE
    sleep    10s
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}    connection=Local gnb1
    Run Keyword If    '${check_5QI}'=='1'    Check wireshark log for failed VoNR call_5QI1    logname=${nglogname}
    Run Keyword If    '${check_5QI}'=='5'    Check wireshark log for failed VoNR call_5QI5    logname=${nglogname}
    csn.disconnect      connection=cygwin
    [Teardown]    kill the call procedure

Make a EC_Modify param_check EC ongoing_idle
    [Arguments]    ${nglogname}    ${parameters_to_update}    ${ue_index}=${0}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface1}    connection=Local gnb1
    Connect to control pc via cygwin    ue_index=${ue_index}
    RUN KEYWORD IF    '${gnb_instance}'!='${gnb_id[0]}'    Make EMC call on samsung UE
    ...    ELSE    Start a emergency call
    Modify NIDD parameter for 784_A    parameters_to_update=${parameters_to_update}
    sleep    10s
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}    connection=Local gnb1
    Check wireshark log for EC ongoing_idle    logname=${nglogname}
    csn.disconnect      connection=cygwin
    [Teardown]    kill the call procedure

Make a EC and check EPS fallback
    [Arguments]    ${ue_index}=${0}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname11_2}    interface=${interface1}    connection=Local gnb1
    eNB start capture wireshark log    filename=${enblogname11}    interface=${interface1}
    Connect to control pc via cygwin    ue_index=${ue_index}
    Make EMC call on samsung UE
    sleep    3s
    hang up EMC call on samsung UE
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname11_2}    connection=Local gnb1
    eNB stop and Save classical Logs    filename=${enblogname11}
    Check wireshark log for EC EPS fallback    gnblogname=${nglogname11_2}    enblogname=${enblogname11}

UE attach and check UE in idle status
    [Arguments]    ${nglogname}
    Modify UE mobile data    action=disable
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface1}    connection=Local gnb1
    run keyword and ignore error    784 UE attach
    sleep    20s
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}    connection=Local gnb1
    Check UE in idle status    logname=${nglogname}

UE attach and make a EC in idle status
    [Arguments]    ${nglogname}
    Modify UE mobile data    action=disable
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface1}    connection=Local gnb1
    run keyword and ignore error    784 UE attach
    sleep    20s
    Make a emergency call    vc_alias=test_voice_call
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}    connection=Local gnb1
