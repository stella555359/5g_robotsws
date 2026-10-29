*** Settings ***
Documentation
...   This is for 2157 TA common keywords
...   squad group: MMW_SG1

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/emil.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource    ./5GC002157_Variables.robot
Variables   ../TestData/5GC002157_scf_modify.py
Library     ./check_tcpdump_msg.py
Library    ./scf_modify.py


*** Keywords ***
Ue attach and detach with traffic
    [Documentation]    author: Wang Yixiang
    Cloud DU connect to gnb coam via ssl
    Call case with power UE and start traffic    duration_time=30    ul_throughput=10M    dl_throughput=50M
    ...    iperf_type=via_command
    Close iperf progress
    Retry commercial ue detach if failed
    sleep    5s

Ue attach and start traffic
    [Documentation]    author: Wang Yixiang
    UE attach and verify
    sleep    2s
    Start data transfer based on direction    dl_tput=50M   ul_tput=50M   duration=120
    ...    data_transfer_direction=both
    sleep    2s

Ue attach and detach
    [Documentation]    author: Wang Yixiang
    UE attach and verify
    sleep    5s
    Retry commercial ue detach if failed
    sleep    2s

UE detach and attach
    [Documentation]    author: Wang Yixiang
    Retry commercial ue detach if failed
    sleep    2s
    UE attach and verify
    sleep    2s

Check msg in tcpdump
    [Documentation]   author: Wang Yixiang
    ...    check msg in tcpdump log, filter can be "ntrstr" or "nsetapx"
    ...    Need to download plugin nsetapx, copy nsetapx-3.2-1.0.0+buster.so to /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.2/epan
    ...    https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=803602448
    [Arguments]    ${tcpdump_log}    ${msg_file}    ${command_template}=${X2AP_COMMAND}
    ${filtered_packets}    Load pcap with filter    pcap_file=${tcpdump_log}    filter_expression=ntrstr
    ...    command_template=${command_template}
    ${pdml_log_path}    Get pdml log    tcpdump_log=${tcpdump_log}
    check_tcpdump_msg    msg_file=${msg_file}   tcpdump_pdml=${pdml_log_path}

Deactive Cell Trace with online update
    [Documentation]   author: Wang Yixiang
    ...    Deactive CU Cell Trace, set actCellTraceReport=false
    CU Delta Commission update    parameters=${CU_CELL_TRACE_FALSE_DELTA}
    DU update several parameters via rest api    parameters=${DU_CELL_TRACE_FALSE}

Active Cell Trace with online update
    [Documentation]   author: Wang Yixiang
    ...    Deactive CU Cell Trace, set actCellTraceReport=false
    CU Delta Commission update    parameters=${CU_CELL_TRACE_TRUE_DELTA}
    DU update several parameters via rest api    parameters=${DU_CELL_TRACE_TRUE}

Start tcpdump and basic L3 call then stop cell trace by set actCellTraceReport false
    [Documentation]   author: Wang Yixiang
    [Arguments]    ${igore_error}=${False}
    Start tcpdump log on CU    tcpdump_collector_name=tcpdump_oam    vm_name=oam-0.local    options=-i oam
    run keyword if    ${igore_error}    run keyword and ignore error  Ue attach and detach
    ...    ELSE    run keyword and continue on failure   Ue attach and detach
    Deactive Cell Trace with online update
    ${tcpdump_oam}    Stop tcpdump log collection    tcpdump_collector_name=tcpdump_oam
    [Return]    ${tcpdump_oam}

Start tcpdump and basic L3 call then stop cell trace by set celltrace pcmd false
    [Documentation]   author: Wang Yixiang
    Start tcpdump log on CU    tcpdump_collector_name=cu_basic_l3_call    vm_name=oam-0.local    options=-i oam
    Start tcpdump log on asik master    tcpdump_collector_name=du_basic_l3_call   options=-i fp0
    Ue attach and detach with traffic
    Deactive PCMD and cell trace
    ${cu_tcpdump_basic_l3_call}    Stop tcpdump log collection    tcpdump_collector_name=cu_basic_l3_call
    ${du_tcpdump_basic_l3_call}    Stop tcpdump log collection    tcpdump_collector_name=du_basic_l3_call
    set test variable    ${cu_tcpdump_basic_l3_call}
    set test variable    ${du_tcpdump_basic_l3_call}
    [Return]    ${cu_tcpdump_basic_l3_call}    ${du_tcpdump_basic_l3_call}

Start tcpdump and basic L3 call then stop cell trace by delete object instance NRMTRACECU
    [Documentation]   author: Wang Yixiang
    Start tcpdump log on CU    tcpdump_collector_name=basic_l3_call    vm_name=oam-0.local    options=-i oam
    Ue attach and start traffic
    Delete object instance NRMTRACECU     scf_path=${SCF_DEFAULT_FILE_PATH_CU}
    ${tcpdump_l3_call}    Stop tcpdump log collection    tcpdump_collector_name=basic_l3_call
    Check msg in tcpdump    tcpdump_log=${tcpdump_l3_call}    msg_file=${CURDIR}/../Resources/attach.txt

Check cell trace report and PCMD trace report
    [Documentation]   author: Wang Yixiang
    Check msg in tcpdump    tcpdump_log=${cu_tcpdump_basic_l3_call}    msg_file=${CURDIR}/../Resources/celltrace_pcmd_l3_call.txt
    Check msg in tcpdump    tcpdump_log=${du_tcpdump_basic_l3_call}    msg_file=${CURDIR}/../Resources/du_pcmd.txt

Start tcpdump and basic L3 call then stop cell trace by set pcmd false
    [Documentation]   author: Wang Yixiang
    Start tcpdump log on CU    tcpdump_collector_name=cu_basic_l3_call    vm_name=oam-0.local    options=-i oam
    Start tcpdump log on asik master    tcpdump_collector_name=du_basic_l3_call   options=-i fp0
    Ue attach and detach with traffic
    Deactive PCMD to stop cell trace
    ${cu_tcpdump_basic_l3_call}    Stop tcpdump log collection    tcpdump_collector_name=cu_basic_l3_call
    ${du_tcpdump_basic_l3_call}    Stop tcpdump log collection    tcpdump_collector_name=du_basic_l3_call
    set test variable    ${cu_tcpdump_basic_l3_call}
    set test variable    ${du_tcpdump_basic_l3_call}
    [Return]    ${cu_tcpdump_basic_l3_call}    ${du_tcpdump_basic_l3_call}

Start tcpdump and basic L3 call
    [Documentation]   author: Wang Yixiang
    Start tcpdump log on CU    tcpdump_collector_name=basic_l3_call    vm_name=oam-0.local    options=-i oam
    Ue attach and start traffic
    ${tcpdump_basic_l3_call}    Stop tcpdump log collection    tcpdump_collector_name=basic_l3_call
    [Return]    ${tcpdump_basic_l3_call}

UE detach and UE attach and check no more cell report generate
    [Documentation]   author: Wang Yixiang
    Start tcpdump log on CU    tcpdump_collector_name=detach_attach    vm_name=oam-0.local    options=-i oam
    UE detach and attach
    ${tcpdump_detach_attach}    Stop tcpdump log collection    tcpdump_collector_name=detach_attach
    ${status}    run keyword and return status     Check msg in tcpdump    tcpdump_log=${tcpdump_detach_attach}
    ...    msg_file=${CURDIR}/../Resources/detach_attach.txt
    should be equal   ${status}   ${False}    while actCellTraceReport=false, no cell trace should generated.

Restart DU and CU
    [Documentation]   author: Wang Yixiang
    [Arguments]    ${timeout}=10 min
    Perform Cloud CU reboot
    Perform Cloud DU reboot
    COAM GNB Wait CU and DU cells are on air status    timeout=${timeout}
    sleep    30s

Lock and unlock cell in DU
    [Documentation]   author: Wang Yixiang
    ...    The operator locks the traced cell during the L3 call for 1 minute and unlocks the cell.
    Cloud DU connect to gnb coam via ssl
    Perform cell lock via rest api
    sleep    60s
    Perform cell unlock via rest api
    COAM GNB Wait CU and DU cells are on air status

Delete object instance NRMTRACECU
    [Documentation]    author: Wang Yixiang
    ...    The operator deletes the object instance NRMTRACECU for the running cell trace on WebUI during the L3 call.
    [Arguments]     ${scf_path}    ${log_path}=${TS_CASE_LOG_PATH}
    CU Delta Commission Delete MO    parameters=${CU_DELETE_NRMTRACECU_DELTA}
    COAM GNB Wait CU and DU cells are on air status

DU update several parameters via rest api
    [Documentation]    Author: Wang Yixiang
    ...    Use this keyword to update DU parameter via rest api
    [Arguments]    ${parameters}
    coam_gnb_classical.Cloud DU connect to gnb coam via ssl    connection=GNB_OAM
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${parameters}
    ...    connection=GNB_OAM
    [Teardown]    coam_gnb_classical.COAM Teardown gnb connections

Active PCMD and cell trace
    [Documentation]    author: Wang Yixiang
    CU Delta Commission update    parameters=${CU_SCF_CELLTRACE_PCMD_TRUE}
    DU update several parameters via rest api    parameters=${DU_SCF_CELLTRACE_PCMD_TRUE}

Deactive PCMD and cell trace
    [Documentation]    author: Wang Yixiang
    [Arguments]    ${log_dir}=${TS_CASE_LOG_PATH}
    CU Delta Commission update    parameters=${CU_SCF_CELLTRACE_PCMD_FALSE}    log_dir=${log_dir}
    DU update several parameters via rest api    parameters=${DU_SCF_CELLTRACE_PCMD_FALSE}

Deactive PCMD to stop cell trace
    [Documentation]    author: Wang Yixiang
    CU Delta Commission update    parameters=${CU_SCF_PCMD_FALSE}
    DU update several parameters via rest api    parameters=${DU_SCF_PCMD_FALSE}

