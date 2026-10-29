*** Settings ***
Documentation    UE common keyword for samsung LTE call
...              Author: Lin jiangjing
...              Contact: jiangjing.lin@nokia-sbell.com, civen.chen@nokia-sbell.com
...              Already verified equipment: Samsung S10

Library     taf.ue  WITH NAME   ute_ue
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/at_ue_common_keyword.robot

*** Variables ***

*** Keywords ***
Prepare UE
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    [Documentation]    Prepare UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for reserve
    ${ue_capabilities}    get_ue_capabilities    ues_info=${tl.ues}    index=${ue_index}
    ${status}    ${info}    run keyword and ignore error    ute_ue.get_ue_info    UE_${ue_index}    DEVICE_MODEL
    ${require_flag}    run keyword if    '${status}'=='FAIL'    run keyword and return status
    ...    should contain    ${info}    UnknownAlias
    ...    ELSE    set variable    ${False}
    ${status}    ${info}    run keyword and ignore error    run keyword if    ${require_flag}
    ...    ute_ue.require_ue    ue_alias=UE_${ue_index}    capabilities=${ue_capabilities}

UE Attach
    [Arguments]   ${ue_index}=${0}    ${pci}=${0}    &{kwargs}
    [Documentation]    Attach UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for attach
    ute_ue.attach_ue    ue_alias=UE_${ue_index}
    sleep    10
    ${attach_pci}    ute_ue.get_ue_info    UE_${ue_index}    PCI
    log to console    \n attach pci is ${attach_pci}
    run keyword if    '${pci}'!='${0}'    should be equal as strings    ${attach_pci}    ${pci}

Verify attach
    [Arguments]    &{kwargs}
    [Documentation]    Verify attach result when plugin self verify not suffient
    Log    Already verified inside UE Attach.

Start traffic
    [Arguments]    ${direction}    ${duration}   ${throughput}   ${protocol}=udp    ${ue_index}=${0}
    ...            ${iperf_port}=default   ${buffer_size}=1400  &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic. E.G 120
    ...  :param  throughput: Throughput(M) of new data transfer, Unit in Mbps
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ${dt_name}    set variable    DT_${direction}_${ue_index}
    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...                                                           ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    ute_ue.start_data_transfer    dt_name=${dt_name}    ue_alias=UE_${ue_index}    direction=${direction}    duration=${duration}s
    ...    throughput=${throughput}Mbits/sec    protocol=${protocol}    port=${port}   packet_size=${buffer_size}

Collect Tput
    [Arguments]    ${ue_index}=${0}    ${duration}=10m    ${ignore_time}=1min    &{kwargs}
    sleep    ${ignore_time}
    sleep    ${duration}
    ${omit_time}    robot.libraries.DateTime.Convert Time    ${ignore_time}
    ${omit_time}    convert to integer    ${omit_time}
    Set Test Variable    ${omit_time}
#    ${dt_name_dl}    set variable    DT_dl_${ue_index}
#    ${dt_name_ul}    set variable    DT_ul_${ue_index}
#    Run keyword and ignore error    ute_ue.await_data_transfer_finish    dt_name=${dt_name_dl}
#    Run keyword and ignore error    ute_ue.await_data_transfer_finish    dt_name=${dt_name_ul}

Check Tput
    [Arguments]    ${direction}    ${target_throughput}    ${ue_index}=${0}    ${target_avg_percent}=0.95    &{kwargs}
    [Documentation]    Check throughput from started traffic.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  target_throughput (M): theory target throughput. Unit in Mbps
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for check throughput.
    ...  :param    target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ${dt_name}    set variable    DT_${direction}_${ue_index}
    ${deviation}    Evaluate    (1 - ${target_avg_percent})*100
    ${deviation}    Convert To Integer    ${deviation}
    ute_ue.get_average_throughput    dt_name=${dt_name}    omit=${omit_time}
    ${status}    Run keyword and return status    ute_ue.verify_average_throughput_with_deviation    dt_name=${dt_name}
    ...    omit=${omit_time}    tput=${target_throughput}Mbits/sec    deviation=${deviation}%
    Run Keyword If    ${status} == False    log to console    check ${direction} tput failed    ELSE
    ...    log to console    check ${direction} tput success
    [Return]    ${status}


Check Bi Tput
    [Arguments]    ${ultarget_throughput}    ${dltarget_throughput}    ${ue_index}=${0}    ${target_avg_percent}=0.95    &{kwargs}
    [Documentation]    Check throughput from started traffic.
    ...  :param  ultarget_throughput (M): theory ul traffic target throughput. Unit in Mbps.
    ...  :param  ultarget_throughput (M): theory dl traffic target throughput. Unit in Mbps.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for check throughput.
    ...  :param    target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ${dt_name_dl}    set variable    DT_dl_${ue_index}
    ${dt_name_ul}    set variable    DT_ul_${ue_index}
    ${deviation}    Evaluate    (1 - ${target_avg_percent})*100
    ${deviation}    Convert To Integer    ${deviation}
    ute_ue.get_average_throughput    dt_name=${dt_name_dl}    omit=${omit_time}
    ute_ue.get_average_throughput    dt_name=${dt_name_ul}    omit=${omit_time}
    ${status_dl}    Run keyword and return status    ute_ue.verify_average_throughput_with_deviation    dt_name=${dt_name_dl}
    ...    omit=${omit_time}    tput=${dltarget_throughput}Mbits/sec    deviation=${deviation}%
    Run Keyword If    ${status_dl} == False    log to console    check dl tput failed    ELSE
    ...    log to console    check dl tput success
    ${status_ul}    Run keyword and return status    ute_ue.verify_average_throughput_with_deviation    dt_name=${dt_name_ul}
    ...    omit=${omit_time}    tput=${ultarget_throughput}Mbits/sec    deviation=${deviation}%
    Run Keyword If    ${status_ul} == False    log to console    check ul tput failed    ELSE
    ...    log to console    check ul tput success
    ${status}    Run Keyword If    ${status_dl}==True and ${status_ul}==True    set variable    True    ELSE
    ...    set variable    False
    [Return]    ${status}

Stop traffic
    [Arguments]    ${direction}    ${ue_index}=${0}    &{kwargs}
    ${dt_name}    set variable    DT_${direction}_${ue_index}
    ute_ue.stop_data_transfer   dt_name=${dt_name}

UE Detach
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    ute_ue.detach_ue    ue_alias=UE_${ue_index}
