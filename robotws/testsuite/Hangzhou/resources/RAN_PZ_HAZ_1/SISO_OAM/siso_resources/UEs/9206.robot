*** Settings ***
Documentation    UE common keyword for normal L3 call, support to control Multi UE also.
...              Please do not modify the file without notification to author
...              author: Zhou Qiang
...              Contact: qiang.1.zhou@nokia-sbell.com
...              Verified equipment: default ue
Library    taf.ue    WITH NAME    ute_ue

*** Variables ***
${IP_EXP_STRING}    ((25[0-5]\\.|2[0-5]\\d\\.|1\\d+\\.|[1-9]\\d?\\.){3}(25[0-5]|2[0-4]\\d|1\\d{2}|[1-9]?\\d))

*** Keywords ***

################################## STEP1: Prepare UE for L3 call ##################################
Prepare UE
    [Arguments]    ${ue_index}=${0}    ${index}=${0}    ${reset_sol}=${True}    &{kwargs}
    [Documentation]    This kw is used to Prepare android UE
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | ue_index=${0}  |
    ...
    Log    ${index}
    #${ue_cap} =    set variable    ${tl.ues[${ue_index}].capabilities[0]}
    ute_ue.require ue    ue_alias=UE_${ue_index}   capabilities=REAL_UE

    Run Keyword If    '${reset_sol}'=='${True}'  ute_ue.software_reset    UE_${ue_index}

    Execute AT    cmd=AT+CREG=2    ue_index=${ue_index}
    Execute AT    cmd=AT+QCFG="iotopmode",1,1    ue_index=${ue_index}

Execute AT
    [Arguments]    ${cmd}    ${ue_index}=${0}    ${timeout}=${4}
    ${ret}    ute_ue.Send At Cmd To Ue    UE_${ue_index}    at_cmd=${cmd}   timeout=${timeout}
    should be equal    ${ret[-1]}    OK
    [Return]   ${ret[1]}

Reboot BG96
    [Arguments]    ${ue_index}=${0}
    Execute AT    cmd=AT+QPOWD    ue_index=${ue_index}
    Sleep    10s

UE Attach
    [Arguments]    ${bts_id}=${EMPTY}    ${require_attach_cell_id}={0}    ${eutra_cel_id}=${0}    ${ue_index}=${0}
    ...   &{kwargs}

    Log    ${bts_id}
    Log    ${require_attach_cell_id}
    #Run Keyword And Ignore Error    ute_ue.detach_ue    UE_${ue_index}
    Run Keyword And Ignore Error    Execute AT    cmd=AT+cfun=0    ue_index=${ue_index}
#    ${ret}    ute_ue.Send At Cmd To Ue    UE_${ue_index}    at_cmd=AT+CREG=2
#    should be equal    ${ret[-1]}    OK
#    Wait Until Keyword Succeeds    2 min    10 sec    ute_ue.attach_ue    UE_${ue_index}
    Wait Until Keyword Succeeds    2 min    10 sec    Execute AT    cmd=AT+cfun=1    ue_index=${ue_index}   timeout=${10}
    ${cell_id}    ute_ue.Get Ue Info     UE_${ue_index}    CELL_ID
    Should Be Equal    ${cell_id}    ${eutra_cel_id}

    #${ue_ip}    ute_ue.Get Ue Info     UE_${ue_index}    IP
    ${ue_ip}    9206.Get Ue IP   ue_index=${ue_index}
    #${cell_id}    Get Cell PCI     ue_index=${ue_index}

    #Log    bts_id: ${enb_id}, Attach cell: ${cell_id}    console=yes
    #should be equal    ${enb_id}    ${bts_id}


9206.Get Ue IP
    [Arguments]    ${ue_index}=${0}
    ${ret}    ute_ue.Send At Cmd To Ue    UE_${ue_index}    at_cmd=AT+CGPADDR=1
    should be equal    ${ret[-1]}    OK
    ${ue_ip}    should match regexp    ${ret[1]}    ${IP_EXP_STRING}
    [Return]    ${ue_ip[0]}

#Get Cell PCI
#    [Arguments]    ${ue_index}=${0}
#    ${ret}    ute_ue.Send At Cmd To Ue    UE_${ue_index}    at_cmd=AT+GTCCINFO?
#    should be equal    ${ret[-1]}    OK
#    ${cell_info}    Split String    ${ret[3]}    ,
#    ${pci}    Convert To Integer    ${cell_info[7]}    base=16
#    ${pci}    Convert To String    ${pci}    ${pci}


################################## STEP2.1: VERIFY ATTACH ##################################
Verify attach
    [Arguments]    ${require_attach_cell_id}    ${eutra_cel_id}=${0}    ${ue_index}=${0}    &{kwargs}

    Log    ${require_attach_cell_id}
    ${ue_ip}    9206.Get Ue IP     ue_index=${ue_index}
#    ${cell_id}    Get Cell PCI     ue_index=${ue_index}
#    ${enb_id}    ute_ue.Get Ue Info     UE_${ue_index}    enb_id
    ${cell_id}    ute_ue.Get Ue Info     UE_${ue_index}    CELL_ID
    Log    Attach cell: ${cell_id}    console=yes
    #should be equal    ${enb_id}    ${bts_id}
    Should Be Equal    ${cell_id}    ${eutra_cel_id}

################################## STEP3: START DATA TRANSFER ##################################
Start traffic
    [Arguments]    ${direction}    ${duration}   ${throughput}    ${tag}
	...            ${require_attach_cell_id}    ${iperf_port}=default
    ...            ${ue_index}=${0}    ${interval}=1    ${buffer_size}=1024B
    ...            ${protocol}=udp    ${data_amount}=1M
    ...            &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    Log    ${throughput}
    Log    ${interval}
    Log    ${protocol}
    Log    ${data_amount}
    ${ue_ip}    9206.Get Ue IP     ue_index=${ue_index}
    ${cell_id}    ute_ue.Get Ue Info     UE_${ue_index}    CELL_ID
#    ${cell_id}    Get Cell PCI     ue_index=${ue_index}

    ${out_current_dt_id}=    set variable    DT_${require_attach_cell_id}_${tag}_${direction}
    Run Keyword And Continue On Failure    ute_ue.Start Data Transfer    ${out_current_dt_id}
    ...    UE_${ue_index}    ${direction}    duration=${duration}    protocol=udp
    ...    throughput=0.1Mbits/sec    port=${iperf_port}   packet_size=${buffer_size}


Check Peak Throughput
    [Arguments]    ${theory_dl_peak}    ${theory_ul_peak}    ${tag}    ${require_attach_cell_id}
    ...            ${total_time}=60    ${interval}=10s    ${duration_time_for_once}=200s
    ...            ${acceptable_tput_percentage}=5%    ${is_need_to_capture_log}=${False}
    [Documentation]    Check throughput from started traffic.
    ...  :param  theory_ul_peak: The theory peak value of UL traffic. Unit is Mbits/sec. E.G 11.8
    ...  :param  theory_dl_peak: The theory peak value of DL traffic. Unit is Mbits/sec  E.G 262.0
    ...  :param  total_time: is the duration time in which the throughput need to be checked. The time unit is second.
    ...  :param  interval: refers to the sleep time between tput checking, can be mins, hours, or secs
    ...  :param  duration_time_for_once: is the duration time for calculating average tput in one capturing
    ...  :param  acceptable_tput_percentage: The acceptable tput percentage of throughput.
    ...                                      Will check if Throughput > theory * acceptable_tput_percentage.
    ...  :param  is_need_to_capture_log: will capture event trace log if set to ${True}
    Log    ${theory_dl_peak}
    Log    ${theory_ul_peak}
    Log    ${total_time}
    Log    ${interval}
    Log    ${duration_time_for_once}
    Log    ${acceptable_tput_percentage}
    Log    ${is_need_to_capture_log}
    ${out_current_dl_dt_id}=    set variable    DT_${require_attach_cell_id}_${tag}_dl
    ${out_current_ul_dt_id}=    set variable    DT_${require_attach_cell_id}_${tag}_ul
#    ute_ue.Check Data Transfer Is Alive    ${out_current_dl_dt_id}
#    ute_ue.Check Data Transfer Is Alive    ${out_current_ul_dt_id}
#    ute_ue.Await Data Transfer Finish    ${out_current_dl_dt_id}
    ute_ue.Await Data Transfer Finish    ${out_current_dl_dt_id}
    Run keyword and ignore error     ute_ue.Await Data Transfer Finish    ${out_current_ul_dt_id}
    ${ul_avg_throughput}=    ute_ue.Get Average Throughput    ${out_current_ul_dt_id}
    ${dl_avg_throughput}=    ute_ue.Get Average Throughput    ${out_current_dl_dt_id}


#    Ue Review Iperf Reports    ${out_current_dl_dt_id}
#    Ue Review Iperf Reports    ${out_current_ul_dt_id}
    Run Keyword And Continue On Failure    ute_ue.Verify Average Throughput With Deviation
    ...    ${out_current_ul_dt_id}    0.012Mbits/sec    20%

    Run Keyword And Continue On Failure    ute_ue.Verify Average Throughput With Deviation
    ...    ${out_current_dl_dt_id}    0.006Mbits/sec    20%



    Log    Avarage throughput(${require_attach_cell_id}): UL:${ul_avg_throughput} Kbits/sec,DL:${dl_avg_throughput} Kbits/sec
    ...    console=yes

    [Return]    ${ul_avg_throughput}    ${dl_avg_throughput}
    [Teardown]   Run Keywords   ute_ue.Stop Data Transfer    ${out_current_dl_dt_id}   AND
    ...     ute_ue.Stop Data Transfer    ${out_current_ul_dt_id}


Check DL Peak Throughput
    [Arguments]    ${theory_dl_peak}    ${theory_ul_peak}    ${tag}    ${require_attach_cell_id}
    ...            ${total_time}=60    ${interval}=10s    ${duration_time_for_once}=200s
    ...            ${acceptable_tput_percentage}=5%    ${is_need_to_capture_log}=${False}
    [Documentation]    Check throughput from started traffic.
    ...  :param  theory_ul_peak: The theory peak value of UL traffic. Unit is Mbits/sec. E.G 11.8
    ...  :param  theory_dl_peak: The theory peak value of DL traffic. Unit is Mbits/sec  E.G 262.0
    ...  :param  total_time: is the duration time in which the throughput need to be checked. The time unit is second.
    ...  :param  interval: refers to the sleep time between tput checking, can be mins, hours, or secs
    ...  :param  duration_time_for_once: is the duration time for calculating average tput in one capturing
    ...  :param  acceptable_tput_percentage: The acceptable tput percentage of throughput.
    ...                                      Will check if Throughput > theory * acceptable_tput_percentage.
    ...  :param  is_need_to_capture_log: will capture event trace log if set to ${True}
    Log    ${theory_ul_peak}
    Log    ${total_time}
    Log    ${interval}
    Log    ${duration_time_for_once}
    Log    ${is_need_to_capture_log}
    ${out_current_dl_dt_id}=    set variable    DT_${require_attach_cell_id}_${tag}_dl
    ${out_current_ul_dt_id}=    set variable    DT_${require_attach_cell_id}_${tag}_ul
#    ute_ue.Check Data Transfer Is Alive    ${out_current_dl_dt_id}
#    ute_ue.Check Data Transfer Is Alive    ${out_current_ul_dt_id}
#    ute_ue.Await Data Transfer Finish    ${out_current_dl_dt_id}
    ute_ue.Await Data Transfer Finish    ${out_current_dl_dt_id}
    #Run keyword and ignore error     ute_ue.Await Data Transfer Finish    ${out_current_ul_dt_id}
    #${ul_avg_throughput}=    ute_ue.Get Average Throughput    ${out_current_ul_dt_id}
    ${dl_avg_throughput}=    ute_ue.Get Average Throughput    ${out_current_dl_dt_id}


#    Ue Review Iperf Reports    ${out_current_dl_dt_id}
#    Ue Review Iperf Reports    ${out_current_ul_dt_id}
#    Run Keyword And Continue On Failure    ute_ue.Verify Average Throughput With Deviation
#    ...    ${out_current_ul_dt_id}    0.012Mbits/sec    20%

#    Run Keyword And Continue On Failure    ute_ue.Verify Average Throughput With Deviation
#    ...    ${out_current_dl_dt_id}    0.012Mbits/sec    50%

#    Run Keyword And Continue On Failure    ute_ue.Verify Average Throughput With Deviation
#    ...    ${out_current_dl_dt_id}    ${theory_dl_peak}Mbits/sec    50%

    ${acceptable_tput_percentage}    Strip String    ${acceptable_tput_percentage}    characters=%

    ${check_dl}    Evaluate    ${theory_dl_peak} * 1024 * (1-${acceptable_tput_percentage}/100)

    Run Keyword And Continue On Failure    Should Be True    ${dl_avg_throughput} >= ${check_dl}


    Log    Avarage throughput(${require_attach_cell_id}): DL:${dl_avg_throughput} Kbits/sec
    ...    console=yes

    [Return]    ${dl_avg_throughput}
    [Teardown]  ute_ue.Stop Data Transfer    ${out_current_dl_dt_id}

Check UL Peak Throughput
    [Arguments]    ${theory_dl_peak}    ${theory_ul_peak}    ${tag}    ${require_attach_cell_id}
    ...            ${total_time}=60    ${interval}=10s    ${duration_time_for_once}=200s
    ...            ${acceptable_tput_percentage}=5%    ${is_need_to_capture_log}=${False}
    [Documentation]    Check throughput from started traffic.
    ...  :param  theory_ul_peak: The theory peak value of UL traffic. Unit is Mbits/sec. E.G 11.8
    ...  :param  theory_dl_peak: The theory peak value of DL traffic. Unit is Mbits/sec  E.G 262.0
    ...  :param  total_time: is the duration time in which the throughput need to be checked. The time unit is second.
    ...  :param  interval: refers to the sleep time between tput checking, can be mins, hours, or secs
    ...  :param  duration_time_for_once: is the duration time for calculating average tput in one capturing
    ...  :param  acceptable_tput_percentage: The acceptable tput percentage of throughput.
    ...                                      Will check if Throughput > theory * acceptable_tput_percentage.
    ...  :param  is_need_to_capture_log: will capture event trace log if set to ${True}
    Log    ${theory_dl_peak}
    Log    ${total_time}
    Log    ${interval}
    Log    ${duration_time_for_once}
    Log    ${is_need_to_capture_log}
    ${out_current_dl_dt_id}=    set variable    DT_${require_attach_cell_id}_${tag}_dl
    ${out_current_ul_dt_id}=    set variable    DT_${require_attach_cell_id}_${tag}_ul
#    ute_ue.Check Data Transfer Is Alive    ${out_current_dl_dt_id}
#    ute_ue.Check Data Transfer Is Alive    ${out_current_ul_dt_id}
#    ute_ue.Await Data Transfer Finish    ${out_current_dl_dt_id}
#    ute_ue.Await Data Transfer Finish    ${out_current_dl_dt_id}
    Run keyword and ignore error     ute_ue.Await Data Transfer Finish    ${out_current_ul_dt_id}
    ${ul_avg_throughput}=    ute_ue.Get Average Throughput    ${out_current_ul_dt_id}
    #${dl_avg_throughput}=    ute_ue.Get Average Throughput    ${out_current_dl_dt_id}


#    Ue Review Iperf Reports    ${out_current_dl_dt_id}
#    Ue Review Iperf Reports    ${out_current_ul_dt_id}
#    Run Keyword And Continue On Failure    ute_ue.Verify Average Throughput With Deviation
#    ...    ${out_current_ul_dt_id}    0.012Mbits/sec    50%

    #Run Keyword And Continue On Failure    ute_ue.Verify Average Throughput With Deviation
    #...    ${out_current_ul_dt_id}    ${theory_ul_peak}Mbits/sec    50%

    ${acceptable_tput_percentage}    Strip String    ${acceptable_tput_percentage}    characters=%

    ${check_ul}    Evaluate    ${theory_ul_peak} * 1024 * (1-${acceptable_tput_percentage}/100)

    Run Keyword And Continue On Failure    Should Be True    ${ul_avg_throughput} >= ${check_ul}


#    Run Keyword And Continue On Failure    ute_ue.Verify Average Throughput With Deviation
#    ...    ${out_current_dl_dt_id}    0.006Mbits/sec    20%



#    Log    Avarage throughput(${require_attach_cell_id}): UL:${ul_avg_throughput} Kbits/sec,DL:${dl_avg_throughput} Kbits/sec
#    ...    console=yes

    Log    Avarage throughput(${require_attach_cell_id}): UL:${ul_avg_throughput} Kbits/sec
    ...    console=yes

    [Return]    ${ul_avg_throughput}
    [Teardown]  ute_ue.Stop Data Transfer    ${out_current_ul_dt_id}

UE Detach
    [Arguments]    ${ue_index}    &{kwargs}
    [Documentation]    Detach UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for detach
    ute_ue.detach_ue    UE_${ue_index}
    #Run Keyword And Ignore Error    Execute AT    cmd=AT+cfun=0    ue_index=${ue_index}
