*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
Library     ../../../../resources/RAN_PZ_HAZ_1/Module/Commercial_UE_Operation.py
Resource    ../../T02/Common_Case/common_resource_new.robot
Resource    ../../../../RRM/RAN_PZ_HAZ_1/Resources/Classical/RRM_MultiBTS_Common_Resource.robot
Library     taf.sw.scout    WITH NAME    scout

*** Variables ***
&{dcap_info}    host=127.0.0.1   port=9443    username=${None}    password=${None}
# &{dcap_info}    host=10.68.80.198    port=443    username=utfuser    password=utfadmin!

*** Keywords ***
Setup_for_Stability
    LOg to Console  \nTesting Starting...
    # ${source_pa_port_list}     Create List    45   45
    # ${source_pa_value_list}    Create List    0   0
    # &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    # ...                               step=${1}         pa_type=16*16
    # PA Operation    source=&{source}    target=none
    start_log_collection

Teardown_for_Stability
    Log to Console  \nTesting Completed!

    Run Keyword And Ignore Error  stop_log_collection

start_log_collection
    # [Arguments]  ${cell_id}  ${log_type}=emil+syslog+snapshot
    [Arguments]  ${log_type}=syslog+emil+snapshot

    Run  DCAP_Basic_controller start
    sleep  5
    ${dict_argument}  Create Dictionary   dcap_server=${dcap_info}
    Run Keyword And Ignore Error
    ...    Log Collection    start  ${log_type}  product_type=gnb  bts_index=${0}  cudu_index=${0}  dict_argument=${dict_argument}
    sleep  30s

stop_log_collection
    [Arguments]  ${log_type}=syslog+emil+snapshot

    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}    cudu_index=${0}
    Log To Console    \nlog of gnb: ${local_file_path}

SW_Upgrade
    [Arguments]  ${sw_version}  ${sw_flag}=All

    BTS Operation  operation=upgrade     product_type=gnb    bts_index=0
        ...   indicated_sw_version=${sw_version}  independent_sw_update_type=${sw_flag}

SW_Rollback
    BTS Operation    operation=rollback    product_type=gnb    bts_index=0

Modify_SCF_Parameters
    [Arguments]    ${product_type}  ${para_list}  ${mo_list}  ${value_list}

    Log To Console  \n Before Online Change
    ${out}    Parameter Operation
    ...    operation=parameter_value_check    product_type=${product_type}
    ...    para_list=@{para_list}    mo_list=@{mo_list}    timeout=${120}
    Log To Console    \nGNB Parameter Check Result: ${out}

    Log To Console  \n After Online Change
    ${out}    Parameter Operation
    ...    operation=parameter_update    product_type=${product_type}
    ...    para_list=@{para_list}    value_list=@{value_list}    mo_list=@{mo_list}    timeout=${180}

    ${out}    Parameter Operation
    ...    operation=parameter_value_check    product_type=${product_type}
    ...    para_list=@{para_list}    mo_list=@{mo_list}    timeout=${120}
    Log To Console    \nGNB Parameter Check Result: ${out}

Wait_for_Next_5min_Period
    log to console  \nWait for Next 5min Period...
    ${current_time}=  Get Current Date  result_format=%H:%M:%S
    log to console  \nCurrent Time: ${current_time}
    ${current_time_in_seconds}=  Convert Time  ${current_time}
    ${wait_time_to_next_5min}=  Evaluate  300 - (${current_time_in_seconds} % 300)
    log to console  \nNeed Wait for ${wait_time_to_next_5min} secnods to next 5min period
    sleep  ${wait_time_to_next_5min}

Wait_for_Next_15min_Period
    log to console  \nWait for Next 15min Period...
    ${current_time}=  Get Current Date  result_format=%H:%M:%S
    log to console  \nCurrent Time: ${current_time}
    ${current_time_in_seconds}=  Convert Time  ${current_time}
    ${wait_time_to_next_5min}=  Evaluate  900 - (${current_time_in_seconds} % 900)
    log to console  \nNeed Wait for ${wait_time_to_next_5min} secnods to next 15min period
    sleep  ${wait_time_to_next_5min}

Get_Current_Time
    ${current_time}=  Get Current Date  result_format=%H:%M:%S
    log to console  \nCurrent Time: ${current_time}
    ${current_time_in_seconds}=  Convert Time  ${current_time}

    [Return]  ${current_time_in_seconds}

Attach_1UE
    [Arguments]  ${ue}  ${forced}=${True}
    Log to Console  \nWaiting for UE attach
    Commercial UE Operation    attach    serialno=${ue}  forced=${forced}
    log to console  \nue_${ue} attached

Detach_1UE
    [Arguments]  ${ue}
    Commercial UE Operation    detach    serialno=${ue}
    log to console  \nue_${ue_1} detached

Attach_Multiple_UE
    [Arguments]  @{ue_list}  ${forced}=${True}
    Log to Console  \nWaiting for UE attach
    FOR  ${ue}  IN  @{ue_list}
        Commercial UE Operation    attach    serialno=${ue}  forced=${forced}
        log to console  \nue_${ue} attached
    END

Detach_Multiple_UE
    [Arguments]  @{ue_list}
    Log to Console  \nWaiting for UE Dettach
    FOR  ${ue}  IN  @{ue_list}
        Commercial UE Operation    detach    serialno=${ue}
        log to console  \nue_${ue} detached
    END

Start_IPerf_UDP_Data_Call_DL
    [Arguments]  ${ue}  ${dl_port}  ${dl_rate}=100M  ${duration}=30
    Log to Console  \nStart Data Call: DL_Rate=${dl_rate} for ${duration}s on UE ${ue}
    Run Keyword And Ignore Error
    ...  Commercial UE Operation    start traffic    serialno=${ue}
    ...  IperfOptions=-u -i 1 -t ${duration} -b ${dl_rate} -p ${dl_port} -l 1024B  direction=dl
    ...  remote_hostname=${server_ip}    remote_username=ute    remote_password=ute

Start_IPerf_UDP_Data_Call_UL
    [Arguments]  ${ue}  ${ul_port}  ${ul_rate}=20M  ${duration}=30
    Log to Console  \nStart Data Call: UL_Rate=${ul_rate} for ${duration}s on UE ${ue}
    Run Keyword And Ignore Error
    ...  Commercial UE Operation    start traffic    serialno=${ue}
    ...  IperfOptions=-u -i 1 -t ${duration} -b ${ul_rate} -p ${ul_port} -l 1024B   direction=ul
    ...  remote_hostname=${server_ip}    remote_username=ute    remote_password=ute

Stop_IPerf_UDP_Data_Call_DL
    [Arguments]  ${ue}  ${dl_port}  ${dl_rate}=100M  ${duration}=30
    Log to Console  \nStop Data Call: DL_Rate=${dl_rate} for ${duration}s on UE ${ue}
    Run Keyword And Ignore Error
    ...  Commercial UE Operation    stop traffic    serialno=${ue}
    ...  IperfOptions=-u -i 1 -t ${duration} -b ${dl_rate} -p ${dl_port} -l 1024B  direction=dl
    ...  remote_hostname=${server_ip}   remote_username=ute    remote_password=ute

Stop_IPerf_UDP_Data_Call_UL
    [Arguments]  ${ue}  ${ul_port}  ${ul_rate}=20M  ${duration}=30
    Log to Console  \nStop Data Call UL_Rate=${ul_rate} for ${duration}s on UE ${ue}
    Run Keyword And Ignore Error
    ...  Commercial UE Operation    stop traffic    serialno=${ue}
    ...  IperfOptions=-u -i 1 -t ${duration} -b ${ul_rate} -p ${ul_port} -l 1024B   direction=ul
    ...  remote_hostname=${server_ip}    remote_username=ute    remote_password=ute

Start_ICMP_Ping
    [Arguments]  ${ue}  ${count}=10  ${interval}=1
    log to console  \n${ue} start ping to ${server_ip} for ${count} times with interval ${interval}s
    Run Keyword And Ignore Error
    ...  Commercial UE Operation    exec adb shell command    serialno=${ue}
    ...  command=ping -c ${count} -i ${interval} ${server_ip}

Start_VoNR_Call_6688
    [Arguments]  ${ue}
        log to console  \n${ue} vonr call to "6688"
        Commercial UE Operation    start call    serialno=${ue}    dial_number=+6688

Stop_VONR_Call_6688
    [Arguments]  ${ue}
    Commercial UE Operation    stop call    serialno=${ue}
    log to console  \n${ue} vonr call stopped