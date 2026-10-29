*** Settings ***
Documentation    This is for feature CB012810 related common keywords.
...              Please do not modify the file without notification to author
...              Author:jia-rebecca.liu@nokia-sbell.com
...              Squard: HZ SG3

Resource       testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB014474/Resources/CB014474_Common_Keywords.robot


*** Keywords ***
samsung UE attach and make a VONR call
    [Arguments]     ${ue_index}=${12}
    ...             ${gnb_index}=${0}
    ...             ${ue_type}=${ue_type_samsung}
    ...             ${tcpdump_collector_name}=${attach_vonr_wiresharklog}
    ...             ${sleep_time}=2s
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    Run Keyword And Continue On Failure    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    ${sleep_time}    reason=wait for ue attach success and capture wiresharklog
    samsung Make Vonr Call With Command    ue_index=${ue_index}
    sleep    6s    reason=wait for vonrcall success and capture wiresharklog
    [Teardown]     Run Keyword
    ...    Stop and download the wiresharklog from master    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    [Return]     ${cpif_log_path}

Stop TTI and detach UE
    [Arguments]    ${tti_names}    ${target_dir}=${epc_log_path}    ${ue_index}=${12}
    Stop Ttitrace With Admin Mode    names=${tti_names}    target_dir=${target_dir}
    Andriod UE adb enable data services for s21    ue_index=${ue_index}
    [Teardown]    stop VONR call and detach UE

BB1002_TTI_analyze
    ${numOfPrb_range_disable_pre}    get_value_from_csv_file_dlFdSchedData    file_path=${epc_log_path}/${BB1002_TTI_disable}_dl.csv
    ...                                                                       filter_name_1=dlFdSchedData.priorityIndex
    ...                                                                       queried_filed=dlFdSchedData.numOfPrb
    ${numOfPrb_range_enable_pre}    get_value_from_csv_file_dlFdSchedData     file_path=${epc_log_path}/${BB1002_TTI_enable}_dl.csv
    ...                                                                       filter_name_1=dlFdSchedData.priorityIndex
    ...                                                                       queried_filed=dlFdSchedData.numOfPrb
    ${numOfPrb_range_disable}    Remove Duplicates    ${numOfPrb_range_disable_pre}
    sort list    ${numOfPrb_range_disable}
    Log To Console    ${numOfPrb_range_disable}
    ${numOfPrb_range_enable}    Remove Duplicates    ${numOfPrb_range_enable_pre}
    sort list    ${numOfPrb_range_enable}
    Log To Console    ${numOfPrb_range_enable}
    should be true    ${numOfPrb_range_enable}[-1] <= ${numOfPrb_range_disable}[-1]

Set the attenuation value step by step for GNB1_CELL2
    [Arguments]    ${origin_value}=${0}    ${target_value}=${28}    ${step}=3
    ...    ${tl}=${gnb1_instance}
    ...    ${att_connection_port}=${att_port_5_gnb1_cell2_${tl}}    ${att_ipaddr}=${att_ipaddr_gnb1_${tl}}
    ...    ${max_attenuation_value}=${127}    ${model}=${model}    ${att_api_port}=${att_api_gnb1_port}    ${vendor}=${vendor}
    [Documentation]
    ...    This keyword is to set the test environment PA values, HBTE and topyoung.
    ...    ${att_ports}:List all the attenuator ports as int list (list[int])
    ...    ${value}:List the value of attenuator ports  int list  (list[Union[str,int,float]])
    ...    ${att_connection_port}:if PA is HBTE, the port is any one port.
    ...                           if PA is topyoung, the port is a List all the attenuator ports as int list
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    ####create cell list#####
    @{att_ports_gnb1_cell2}    Create List    ${att_port_5_gnb1_cell2_${tl}}    ${att_port_6_gnb1_cell2_${tl}}
    ...    ${att_port_7_gnb1_cell2_${tl}}    ${att_port_8_gnb1_cell2_${tl}}
    FOR    ${step_value}    IN RANGE    ${origin_value}    ${target_value}    ${step}
        ${target_value}=    evaluate     [${step_value}]*4
        att.set_ports_attenuation    ports=${att_ports_gnb1_cell2}    values=${target_value}
        ${ports_values}=    att.read_ports_attenuation    ports=${att_ports_gnb1_cell2}
        Lists Should Be Equal    list1=${target_value}    list2=${ports_values}    msg=Inconsistencies before and after modification
        sleep    10s
    END
