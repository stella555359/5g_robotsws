*** Settings ***
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007834/resources/CB007834_5G_A_common_keyword.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008140/Resources/CB008140_common_keywords_multiUE.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007834/resources/CB007834_5G_A_variables.py
Library    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007834/resources/CB007834_5G_A_AVHA.py

Documentation
...   author: huimin.1.cheng
...   contact: huimin.1.cheng@nokia-sbell.com
...   squad group: SG_03

Suite Setup    Run Keywords
...    Common Case TestLine Setup for Test case    AND
...    Common Suite Setup for COAM

Suite Teardown    Run Keywords
...    Common Case TestLine Setup for Test recovery    AND
...    Adjust gNB_RU Attenuation TL357    AND
...    Run Keyword And Ignore Error    Common Suite Teardown for COAM    AND
...    Run keyword If    '${tl_comission}' == '${False}'    Perform BTS Site Reset

*** Variables ***
${golden_scf_name_357}    Configuration_scf_GNB1_TL357
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
${download_version_file_path}    /opt/workspace/SCF
@{ue_index_MTU_all_357}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}
@{ue_index_MTU_poweron_357}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}
@{ue_index_MTU_poweroffall}    ${-1}
${index_ue_357}    ${0}
${file_path}    /opt/workspace/E2E_KPI//kpi_report_releated_parameters.yml
${file_path_14044}    /opt/workspace/E2E_KPI//kpi_CB014044report_releated_parameters.yml
${report_name}     kpi_report
${excel_kpi_path}    /opt/workspace/E2E_KPI/
${tl_id}    357
${APN_357}    wustatic
@{Multi_APN_UE6_357}    weistatic
@{Multi_APN_UE7_357}    weistatic
@{Multi_APN_all_UE6_357}    wustatic    weistatic
@{Multi_APN_all_UE7_357}    wustatic    weistatic


@{target_throughput_dl_UE1_357}    ${450}    ${600}
@{target_throughput_dl_UE2_357}    ${450}    ${600}
@{target_throughput_dl_UE3_357}    ${0.5}    ${5}
@{target_throughput_dl_UE4_357}    ${0.5}    ${5}
@{target_throughput_dl_UE5_357}    ${0.5}    ${5}
@{target_throughput_dl_UE6_357}    ${450}    ${600}
@{target_throughput_dl_UE7_357}    ${450}    ${600}
@{target_throughput_dl_UE8_357}    ${0.5}    ${5}

@{target_throughput_ul_UE1_357}    ${15}    ${25}
@{target_throughput_ul_UE2_357}    ${3}    ${10}
@{target_throughput_ul_UE3_357}    ${0.5}    ${5}
@{target_throughput_ul_UE4_357}    ${0.5}    ${5}
@{target_throughput_ul_UE5_357}    ${0.5}    ${5}
@{target_throughput_ul_UE6_357}    ${15}    ${25}
@{target_throughput_ul_UE7_357}    ${3}    ${10}
@{target_throughput_ul_UE8_357}    ${0.5}    ${5}

${dl_throughput_UE1_FDD_357}    500M
${dl_throughput_UE2_FDD_357}    500M
${dl_throughput_UE3_FDD_357}    1M
${dl_throughput_UE4_FDD_357}    1M
${dl_throughput_UE5_FDD_357}    1M
${dl_throughput_UE6_FDD_357}    250M
${dl_throughput_UE7_FDD_357}    250M
${dl_throughput_UE8_FDD_357}    1M

${ul_throughput_UE1_FDD_357}    20M
${ul_throughput_UE2_FDD_357}    5M
${ul_throughput_UE3_FDD_357}    1M
${ul_throughput_UE4_FDD_357}    1M
${ul_throughput_UE5_FDD_357}    1M
${ul_throughput_UE6_FDD_357}    20M
${ul_throughput_UE7_FDD_357}    5M
${ul_throughput_UE8_FDD_357}    1M
@{gnb_list}    ${0}

${dl_throughput_UE1_TDD_357}    500M
${dl_throughput_UE2_TDD_357}    500M
${dl_throughput_UE3_TDD_357}    1M
${dl_throughput_UE4_TDD_357}    1M
${dl_throughput_UE5_TDD_357}    1M
${dl_throughput_UE6_TDD_357}    250M
${dl_throughput_UE7_TDD_357}    250M
${dl_throughput_UE8_TDD_357}    1M

${ul_throughput_UE1_TDD_357}    20M
${ul_throughput_UE2_TDD_357}    5M
${ul_throughput_UE3_TDD_357}    1M
${ul_throughput_UE4_TDD_357}    1M
${ul_throughput_UE5_TDD_357}    1M
${ul_throughput_UE6_TDD_357}    20M
${ul_throughput_UE7_TDD_357}    5M
${ul_throughput_UE8_TDD_357}    1M


*** Test Cases ***
[1]CB007834-5G-A_001_DL_Tput_verify_per_release_8UE_IWK_8227
    [Documentation]    This user scenario to verify 8UE attach and peak Tput for UL and DL besed on TMO configuration.
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=4459,49,6261,2412,7311,7319
    AlarmWatchdog.add_allow_alarms    fault_id=4459
    AlarmWatchdog.add_allow_alarms    fault_id=49
    AlarmWatchdog.add_allow_alarms    fault_id=6261
    AlarmWatchdog.add_allow_alarms    fault_id=2412
    AlarmWatchdog.add_allow_alarms    fault_id=7311
    AlarmWatchdog.add_allow_alarms    fault_id=7319
    Get_TL_other_info
    Set Suite Variable    ${pcell_tech}    FDD
#    Cell Lock Prepare after scf comission    Modify_Para_Online=${Modify_Para_Online_Locked_${gnb_instance}}    action_GSM=block
    Cell Lock Prepare after scf comission    Modify_Para_Online=${Modify_Para_Online_Bar_${gnb_instance}}    action_GSM=block
    Adjust gNB_RU Attenuation TL357    cell11_value=${12}    cell3_value=${0}    cell301_value=${6}    cell351_value=${20}
    Prapare Spark UE
    MutlUE attach and check tput via spark   ue_index_MTU_all=${ue_index_MTU_all_${gnb_instance}}
    Log To Console    ***Main Test case finish , will Collect KPI report after waiting enough time***
    COAM Save all gnb snapshot via api    gnb_list=${gnb_list}    log_path=${epc_log_path}
    Arrange all logs move to CPC log server
    Generate and download the KPI report offline
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND    Run keyword and ignore error    CI_interface.Common Case Teardown

[1]CB007834-5G-A_001_DL_Tput_verify_per_release_8UE_IWK_8227_TDD
    [Documentation]    This user scenario to verify 8UE attach and peak Tput for UL and DL besed on TMO configuration.
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=4459,49,6261,2412,7311,7319
    AlarmWatchdog.add_allow_alarms    fault_id=4459
    AlarmWatchdog.add_allow_alarms    fault_id=49
    AlarmWatchdog.add_allow_alarms    fault_id=6261
    AlarmWatchdog.add_allow_alarms    fault_id=2412
    AlarmWatchdog.add_allow_alarms    fault_id=7311
    AlarmWatchdog.add_allow_alarms    fault_id=7319
    Get_TL_other_info
    Set Suite Variable    ${pcell_tech}    TDD
#    Cell Lock Prepare after scf comission    Modify_Para_Online=${Modify_Para_Online_Locked_TDD_${gnb_instance}}    action_GSM=block
    Cell Lock Prepare after scf comission    Modify_Para_Online=${Modify_Para_Online_Bar_TDD_${gnb_instance}}    action_GSM=block
    Adjust gNB_RU Attenuation TL357    cell11_value=${12}    cell3_value=${0}    cell301_value=${6}    cell351_value=${20}
    Prapare Spark UE
    MutlUE attach and check tput via spark    ue_index_MTU_all=${ue_index_MTU_all_${gnb_instance}}
    Log To Console    ***Main Test case finish , will Collect KPI report after waiting enough time***
    COAM Save all gnb snapshot via api    gnb_list=${gnb_list}    log_path=${epc_log_path}
    Arrange all logs move to CPC log server
    Generate and download the KPI report offline
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND    Run keyword and ignore error    CI_interface.Common Case Teardown

*** Keywords ***
Cell Lock Prepare after scf comission
    [Arguments]    ${Modify_Para_Online}=${Modify_Para_Online_Locked_${gnb_instance}}    ${action_GSM}=block
    IF    '${tl_comission}' == '${True}'
        Modify Parameters for Cases    Modify_Para_Online=${Modify_Para_Online}
        block unblock per cell action    action=${action_GSM}
    END

Generate and download the KPI report offline
    [Arguments]    ${names}=kpi_report
    ...            ${uteTTI_ip}=${tti_uteip}
    ...            ${uteTTI_username}=${tti_uteuser}
    ...            ${uteTTI_password}=${tti_utepw}
    Log To Console    ***Try generate KPI report offline***
    Get bts package version
    ${new_time_object}=    DateTime.Subtract Time From Date    ${end_time}    5 minutes
    ${end_time}=    DateTime.Convert Date    ${new_time_object}    result_format=%Y-%m-%d %H:%M
    ${new_start}    Convert Date    ${start_time}    date_format=%Y-%m-%d %H:%M    result_format=%Y%m%d%H%M
    ${new_end}    Convert Date    ${end_time}    date_format=%Y-%m-%d %H:%M    result_format=%Y%m%d%H%M
    Set Suite Variable    ${rep_name}    ${package_version}_${report_name}_${pcell_tech}_${new_end}
    Set Suite Metadata    ${pcell_tech} KPI report name     ${rep_name}
    ${kpi_python} =    Set Variable    /opt/workspace/SCF/tmoKPI.py
    csn.Connect to    hostname=${uteTTI_ip}    username=${uteTTI_username}    password=${uteTTI_password}    alias=${names}
    csn.Send Command
    ...    command=nohup python ${kpi_python} '${tmp_name}' '${rep_name}' '${tl_id}' '${package_version}' '${start_time}' '${end_time}' &
    ...    connection=${names}
    sleep    3s
    csn.Send Command
    ...    command=sed -i '2i${golden_scf_filename} ${rep_name} ${package_version}' /opt/workspace/E2E_KPI/kpi_historyt.txt
    ...    connection=${names}
    sleep    3s
    csn.disconnect    connection=${names}

Read txt file first line
    [Arguments]    ${file_path}=/opt/workspace/SCF/scf_listfeature.txt
    ${file_content}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${file_content}
    ${length}=    Get Length    ${lines}
    IF    ${length}==0
        ${first_line_variable}=    Set Variable    ${EMPTY}
    ELSE IF    ${length} > 0
        ${first_line_variable}=    Get From List    ${lines}    0
    END
    [Return]    ${first_line_variable}

Delete txt file first line
    [Arguments]    ${file_path}=/opt/workspace/SCF/scf_listfeature.txt
    ${file_content}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${file_content}
    ${length}=    Get Length    ${lines}
    Run Keyword If    ${length} > 0    Remove From List    ${lines}    0
    ${new_content}=    Catenate    SEPARATOR=\n    @{lines}
    Create File    ${file_path}   ${new_content}

Generate and download the KPI report
    ${new_time_object}=    DateTime.Subtract Time From Date    ${end_time}    5 minutes
    ${end_time}=    DateTime.Convert Date    ${new_time_object}    result_format=%Y-%m-%d %H:%M
    generate new report and get report id
    ...    file_path=${file_path}    report_name=${package_version}_${report_name}_${pcell_tech}    tl_id=${tl_id_${gnb_instance}}
    ...    package_version=${package_version}    start_time=${start_time}   end_time=${end_time}
    download_kpi_file    report_id=${report_id}    path=${excel_kpi_path}

Finish tti log collect
    ${tti_path}=    Evaluate    '${tcp_targetpath}' + '/'.join('${epc_log_path}'.split('/')[5:]) + '${pcell_tech}'
    Stop Collect TTitrace and package TTitrace on remote UTE    uteTTI_ip=${tti_uteip}
    ...    uteTTI_username=${tti_uteuser}    uteTTI_password=${tti_utepw}    tti_path=${tti_path}
    Teardown TTitrace mirror on BTS
    Set Suite Variable    ${tti_path}
    Set Suite Metadata    ${pcell_tech} Case TTI UTE Logpath     ${tti_path}

Prepare tti log collect
    Setup BTS TTitrace Mirror to remote UTE    ute_ip=${tti_uteip}    nr_phy_cell_ids=${tti_celllist}    tti_component=${tti_component}
    Start Collect TTitrace on remote UTE    uteTTI_ip=${tti_uteip}    uteTTI_username=${tti_uteuser}
    ...    uteTTI_password=${tti_utepw}    maxnumber=${tti_number}    timeout=${tti_timeout}

Get_TL_other_info
    ${tti_info}=    get_info_from_yaml    file_path=${download_version_file_path}/tti_info.yaml
    Set Suite Variable    ${tti_info}
    Set Suite Variable    ${tti_collect}    ${tti_info}[tti_collect]
    Set Suite Variable    ${tti_uteip}    ${tti_info}[tti_uteip]
    Set Suite Variable    ${tti_uteuser}    ${tti_info}[tti_uteuser]
    Set Suite Variable    ${tti_utepw}    ${tti_info}[tti_utepw]
    Set Suite Variable    ${tti_number}    ${tti_info}[tti_number]
    Set Suite Variable    ${tcp_targetpath}    ${tti_info}[tti_tragetpath]
    Set Suite Variable    ${tti_celllist}    ${tti_info}[tti_celllist]
    Set Suite Variable    ${tti_timeout}    ${tti_info}[tti_timeout]
    Set Suite Variable    ${tti_component}    ${tti_info}[tti_component]
    Set Suite Variable    ${tl_comission}    ${tti_info}[tl_comission]
    Set Suite Variable    ${tl_comission_scflist}    ${tti_info}[tl_comission_scflist]
    Set Suite Variable    ${tmp_name}    ${tti_info}[tl_kpi_tmp]

Reboot the spark Control PC
    [Arguments]    ${ue_index}=${0}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.Send Command    command=shutdown -r -f -t 3     connection=cpc_${ue_index}    timeout=5
    csn.disconnect    connection=cpc_${ue_index}

Arrange all logs move to CPC log server
    [Arguments]    ${ue_index}=${8}
    ...            ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...            ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...            ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}
    run    sudo mv /opt/workspace/SCF/multi_ue_with_* ${epc_log_path}
    ${cpcserver_path}=    Evaluate    '/cygdrive/c/' + '/'.join('${epc_log_path}'.split('/')[5:])
    Create caselog dir on cpc log server      log_path=${cpcserver_path}    ue_index=${ue_index}
    run    sshpass -p ${password} scp ${epc_log_path}* ${username}@${hostname}:${cpcserver_path}
    sleep    3s
    run    rm -rf ${epc_log_path}*
    sleep    3s
    Set Suite Variable    ${cpcserver_path}
    Set Suite Metadata    ${pcell_tech} Case Control PC Logpath     ${cpcserver_path}

Create caselog dir on cpc log server
    [Arguments]    ${ue_index}=${8}    ${log_path}='/cygdrive/c/'
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   1s
    csn.send_command    command=mkdir -p ${log_path}   connection=cygwin
    sleep    1s
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=cygwin

Common Case TestLine Setup for Test case
    Get_TL_other_info
    IF    '${tl_comission_scflist}'=='${True}'
        ${golden_scf_filename}=    Read txt file first line
        Should Not Be Empty    ${golden_scf_filename}
    ELSE
        ${release}=    Get sagnb release 7834
        ${golden_scf_filename}=    Set variable    ${golden_scf_name_${gnb_instance}}_${release}.xml
    END
    Set Suite Variable    ${golden_scf_filename}
    Set Suite Metadata    Case Used SCF    ${golden_scf_filename}
    Common Case TestLine Setup    is_commission=${tl_comission}    golden_scf_name=${golden_scf_filename}
    Run keyword IF    ${tl_comission} == ${True}    Wait until keyword succeeds    20 min    20s    Check the cells status on air

Common Case TestLine Setup for Test recovery
    ${release}=    Get sagnb release 7834
#    IF    '${SUITE STATUS}' == 'FAIL'
#        Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_UnLocked_${gnb_instance}}
#        block unblock per cell action    action=unblock
    IF    '${SUITE STATUS}' == 'PASS' and '${tl_comission_scflist}'=='${True}' and '${tl_comission}'=='${True}'
        Delete txt file first line
    END

Case Teardown KPI
    [Arguments]    ${gnb_list}=${gnb_list}    ${log_path}=${epc_log_path}
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=4459
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    COAM Save all gnb snapshot via api    gnb_list=${gnb_list}    log_path=${log_path}
    Run Keyword And Ignore Error    Tear down the connections
    Run keyword and ignore error    CI_interface.Common Case Teardown

Attach with multi PDU Session OK and check IP OK
    [Arguments]    ${ue_index}=${7}    ${Multi_APN}=${Multi_APN}    ${Multi_APN_all}=${Multi_APN_all}
    MultiUE.Attach    ue_index=${ue_index}
    sleep    1s
    FOR    ${index}    ${APN_index}    IN ENUMERATE    @{Multi_APN}
        ${index1}    Set Variable    ${${index}+${3}}
        Wait until keyword succeeds    4x   10s    Spark.send AT command CPE
        ...    param=at+cgact=1,${index1}    ue_alias=UE_${ue_index}
    END
    Sleep    2s
    FOR    ${apn_index}    IN    @{Multi_APN_all}
        ${IP}    MutiUE.Get PDU IP    ue_index=${ue_index}    APN=${apn_index}
        Should Not Be Empty    ${IP}
        Should Not Start With    ${IP}    192.168.
    END

Multi APN start traffic
    [Arguments]    ${ue_index}=${7}    ${throughput_for_DL}=${dl_throughput}    ${Multi_APN_all}=${Multi_APN_all}    ${duration}=3000
    ...    ${process_num}=1
    FOR    ${APN_index}    IN    @{Multi_APN_all}
        MultiUE.Start DL Traffic    throughput_for_DL=${throughput_for_DL}    ue_index=${ue_index}    duration=${duration}
        ...    APN=${APN_index}    process_num=${process_num}
    END

MutlUE attach and check tput via spark
    [Arguments]    ${ue_index_MTU_all}=${ue_index_MTU_all}    ${APN}=${APN_${gnb_instance}}
    ${Initial_State}=    Set variable    ${False}
    Run keyword IF    ${tti_collect} == ${True}    Run keyword and ignore error    Setup BTS TTitrace Mirror to remote UTE
    ...    ute_ip=${tti_uteip}    nr_phy_cell_ids=${tti_celllist}    tti_component=${tti_component}
    FOR    ${index}    IN RANGE    ${3}
        IF    '${Initial_State}'=='${False}'
            ${Initial_State}=    With ALL UE Attach and Verify Data TP reach the target
            ...    ue_index_MTU_all=${ue_index_MTU_all}   APN=${APN_${gnb_instance}}    type=${pcell_tech}
        END
        Exit For Loop If    ${Initial_State} == ${True}
    END
    log to console    The KPI start time is ${start_time}
    should be true    ${Initial_State}
    Prepare to caculate PM counter    period=start
    Run keyword IF    ${tti_collect} == ${True}    Start Collect TTitrace on remote UTE    uteTTI_ip=${tti_uteip}
    ...    uteTTI_username=${tti_uteuser}    uteTTI_password=${tti_utepw}    maxnumber=${tti_number}    timeout=${tti_timeout}
    Start VONR CALL for mutli times with python    type=${pcell_tech}
    Prepare to caculate PM counter    period=start
    Comment    ***********Check DL UL Traffic after 20min*********************
    ${TP_result_8UE}=    run keyword and return status    Check spark and special UE throughput for Multi Times
    ...    ue_index_MTU_all=${ue_index_MTU_all}    operation=check_dltp    type=${pcell_tech}
    Should Be True    ${TP_result_8UE}
    Wait Until Keyword Succeeds   3X    5s    Special UEs operation and verify    operation=detach_stopdata
    ...    verify_tag="detach to NR success"    type=${pcell_tech}
    Prepare to caculate PM counter    period=start
    Start attach detach loop for mutli times with python
    ...    operation=adttach_loop    verify_tag="click airplane mode switch success"    type=${pcell_tech}
    Prepare to caculate PM counter    period=end
    Get record time    label=end
    log to console    The KPI end time is ${end_time}
    Comment    ***********WIth TearDown to Stop DL AND UL Traffic And detach UE*********************
    [Teardown]    Run Keywords    Run keyword IF    ${tti_collect} == ${True}    Finish tti log collect    AND
    ...    Run keyword and ignore error    Multi UE stop traffic and detach contain special UEs
    ...    ue_index_MTU_all=${ue_index_MTU_all}    APN=${APN}    direction_ul=ul    operation=detach_stopdata    AND
    ...    Run keyword and ignore error    close iperf and spark

With ALL UE Attach and Verify Data TP reach the target
    [Arguments]    ${ue_index_MTU_all}=${ue_index_MTU_all}    ${APN}=${APN_${gnb_instance}}    ${type}=FDD
    ${TP_result_8UE}=    Set Variable    ${EMPTY}
    Prepare to caculate PM counter    period=start
    Get record time    label=start
    sleep    30s
    Comment    ***********Attach UE And Start Traffic*********************
    ${Attach_result}=    run keyword and return status    Spark and special multi UE Attach and start DLUL traffic
    ...    ue_index_MTU_all=${ue_index_MTU_all}    APN=${APN}    type=${type}
    IF    '${Attach_result}'=='True'
        sleep    30s
        Comment    ***********Check DL UL Traffic*********************
        ${TP_result_8UE}=    run keyword and return status    Check spark and special UE throughput for Multi Times
        ...    ue_index_MTU_all=${ue_index_MTU_all}    operation=check_dltp    type=${type}
    ELSE
        ${TP_result_8UE}=    Set variable    ${False}
    END
    Run keyword If    '${TP_result_8UE}'=='False'    Multi UE stop traffic and detach contain special UEs
    ...    ue_index_MTU_all=${ue_index_MTU_all}    APN=${APN}    direction_ul=ul    operation=detach_stopdata
    ${Initial_status} =    Evaluate    ${Attach_result} and ${TP_result_8UE}
    [Return]    ${Initial_status}

Spark and special multi UE Attach and start DLUL traffic
    [Arguments]    ${ue_index_MTU_all}=${ue_index_MTU_all}    ${APN}=${APN_${gnb_instance}}    ${type}=FDD
    FOR    ${index}    IN    @{ue_index_MTU_all}
        Run keyword If
        ...    '${index}'=='${ue_index_MTU_all[5]}' or '${index}'=='${ue_index_MTU_all[6]}'
        ...    Run keywords    Attach with multi PDU Session OK and check IP OK    ue_index=${${index}-${1}}
        ...    Multi_APN=${Multi_APN_UE${index}_${gnb_instance}}    Multi_APN_all=${Multi_APN_all_UE${index}_${gnb_instance}}
        ...    AND    Multi APN start traffic
        ...    throughput_for_DL=${dl_throughput_UE${index}_${type}_${gnb_instance}}    ue_index=${${index}-${1}}    duration=3000
        ...    Multi_APN_all=${Multi_APN_all_UE${index}_${gnb_instance}}
        ...    AND    MultiUE.Start DL Traffic    throughput_for_DL=${ul_throughput_UE${index}_${type}_${gnb_instance}}
        ...    ue_index=${${index}-${1}}    duration=3000    APN=${APN}    direction=ul
        ...    ELSE    Run keywords    Attach and check IP OK    ue_index=${${index}-${1}}    APN=${APN}
        ...    AND    MultiUE.Start DL Traffic    throughput_for_DL=${dl_throughput_UE${index}_${type}_${gnb_instance}}
        ...    ue_index=${${index}-${1}}    duration=3000    APN=${APN}    process_num=${1}
        ...    AND    MultiUE.Start DL Traffic    throughput_for_DL=${ul_throughput_UE${index}_${type}_${gnb_instance}}
        ...    ue_index=${${index}-${1}}    duration=3000    APN=${APN}    direction=ul
    END
    Special UEs operation and verify    operation=attach_startdata    type=${type}

Multi UE stop traffic and detach contain special UEs
    [Arguments]    ${ue_index_MTU_all}=${ue_index_MTU_all}    ${APN}=${APN_${gnb_instance}}    ${direction_ul}=NULL
    ...    ${operation}=detach_stopdata    ${verify_tag}="detach to NR success"    ${index_ue}=0
    Log To Console    ***With all ues Prepare to stop data and detach***
    ${specialue_status}=    run keyword and return status    Wait Until Keyword Succeeds   3X    60s    Special UEs operation and verify
    ...    operation=${operation}    verify_tag=${verify_tag}
    # add spark status check and return status
    Spark UE Stop all Dl traffic
    ${TCP_status}=    Check spark port LISTENING    ue_index=${index_ue}
    IF    '${TCP_status}'=='${True}'
        ${sparkue_status}=    run keyword and return status    Multi UE stop ul traffic and detach
    ...    ue_index_MTU_all=${ue_index_MTU_all}    APN=${APN}    direction_ul=${direction_ul}
    ELSE
        ${sparkue_status}=    Set variable    ${False}
    END
    should be true    ${specialue_status}
    should be true    ${sparkue_status}

Spark UE Stop all Dl traffic
    [Arguments]    ${alias}=APPserver    ${ue_index}=0    ${port}=${tl.ues[${ue_index}].iperf_details.port}
    csn.Connect to    hostname=${tl.appserver.iperf_details.ssh_connection_details.addr}
    ...               username=${tl.appserver.iperf_details.ssh_connection_details.username}
    ...               password=${tl.appserver.iperf_details.ssh_connection_details.password}
    ...               alias=${alias}
     csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${port}| awk '{print $2}' |xargs -r kill -9    connection=${alias}
     sleep    2s
     csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${port}| awk '{print $2}'    connection=${alias}
    [Teardown]    Csn.disconnect      connection=${alias}

Check spark and special UE throughput for Multi Times
    [Arguments]    ${ue_index_MTU_all}=${ue_index_MTU_all}    ${operation}=check_dltp
    ...    ${verify_tag}="dldata TP reach the DL target"    ${type}=FDD
    Check the Spark UE throughput for Multi Times    ue_index_MTU_all=${ue_index_MTU_all}
    Special UEs operation and verify    operation=${operation}   verify_tag=${verify_tag}    type=${type}

Check the Spark UE throughput for Multi Times
    [Arguments]    ${ue_index_MTU_all}=${ue_index_MTU_all}
    FOR    ${index}    IN    @{ue_index_MTU_all}
        Log To Console    ***Check ${index} UE tput***
        Repeat keyword    3 times    Wait Until Keyword Succeeds   3X    3s    Check target tput via spark
        ...    target_throughput_dl=${target_throughput_dl_UE${index}_${gnb_instance}}    ue_index=${${index}-${1}}
        ...    direction_UL=UL    target_throughput_UL=${target_throughput_ul_UE${index}_${gnb_instance}}
    END

Check target tput via spark
    [Arguments]    ${target_throughput_dl}    ${ue_index}=${7}    ${direction}=DL
    ...    ${direction_UL}=NULL    ${target_throughput_UL}=NULL
    ${log}    power_ue.Collect Tput    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    duration=1s    ue_index=${ue_index}
    IF    '${direction}' !='NULL'
        ${real_dltp}    Evaluate    ${log[1]}/1000000
        ${dl_min_threshold}    Evaluate    ${real_dltp} > ${target_throughput_dl[0]}
        ${dl_max_threshold}    Evaluate    ${real_dltp} < ${target_throughput_dl[1]}
        IF    ${dl_min_threshold} == ${False} or ${dl_max_threshold} == ${False}
            Log To Console    DL target_throughput is not reach, please check!!!
            Fail    msg=DL target_throughput is not reach, please check!!!
        END
    END
    IF    '${direction_UL}' !='NULL'
        ${real_ultp}    Evaluate    ${log[0]}/1000000
        ${ul_min_threshold}    Evaluate    ${real_ultp} > ${target_throughput_UL[0]}
        ${ul_max_threshold}    Evaluate    ${real_ultp} < ${target_throughput_UL[1]}
        IF    ${ul_min_threshold} == ${False} or ${ul_max_threshold} == ${False}
            Log To Console    UL target_throughput is not reach, please check!!!
            Fail    msg=UL target_throughput is not reach, please check!!!
        END
    END
    sleep    5s

Start attach detach loop for mutli times with python
    [Arguments]    ${operation}=adttach_loop    ${verify_tag}="attach and detach loop finish"    ${type}=FDD
    IF    '${type}'=='FDD'
        ${adloop_ue} =    Run    python -c "exec(open('/opt/workspace/SCF/config.py').read()); print(UES_INFO[0]['adloopue_Num'])"
        IF    '${adloop_ue}' !='0'
            Log To Console    ***${adloop_ue} special UE with attach and detach loop start***
            ${operation_log} =    Run    python /opt/workspace/SCF/all_ues_operation.py ${operation}
            ${operation_log} =    Replace String    ${operation_log}    \n    ${EMPTY}
            ${count}=    Evaluate    "${operation_log}".count(${verify_tag})
            Log To Console    ***${adloop_ue} special UE with ${count} time attach and detach loop finished***
        ELSE
            Log To Console    ***No attach and detach loop will start and just sleep enough time***
            sleep    8m
        END
    ELSE IF    '${type}'=='TDD'
        Log To Console    ***For TDD as Pcell,No attach and detach loop will start***
    END

Start VONR CALL for mutli times with python
    [Arguments]    ${operation}=vonr_loop    ${verify_tag}="vonr call success"    ${type}=FDD
    IF    '${type}'=='FDD'
        ${vonr_ue} =    Run    python -c "exec(open('/opt/workspace/SCF/config.py').read()); print(UES_INFO[0]['vonrue_Num'])"
        IF    '${vonr_ue}' !='0'
            Log To Console    ***${vonr_ue} special UE with VONR call loop start***
            ${operation_log} =    Run    python /opt/workspace/SCF/all_ues_operation.py ${operation}
            ${operation_log} =    Replace String    ${operation_log}    \n    ${EMPTY}
            ${count}=    Evaluate    "${operation_log}".count(${verify_tag})
            Log To Console    ***${vonr_ue} special UE with ${count} time VONR call success finished***
        ELSE
            Log To Console    ***No VONR call loop will start and just sleep enough time***
            sleep    17m
        END
    ELSE IF    '${type}'=='TDD'
        Log To Console    ***For TDD as Pcell,No VONR call loop will start and just sleep enough time***
        sleep    2m
    END

Start VONR CALL for mutli times and Collect TTItrace
    [Arguments]    ${operation_times}=50    ${vonr_ue}=2
    ${count_status}    Set Variable    0
    ${count_succ}    Set Variable    0
    FOR    ${index}    IN RANGE    ${operation_times}
        ${start_status}=    run keyword and return status    Special UEs operation and verify
        ...    operation=start_vonr    verify_tag="start vonr call success"
        sleep    8s
        ${end_status}=    run keyword and return status    Special UEs operation and verify
        ...    operation=end_vonr    verify_tag="END VONR call success"
        sleep    4s
        IF    '${start_status}'=='False' or '${end_status}'=='False'
            ${count_status}=    Evaluate    ${count_status} + 1
            Log To Console    ***${vonr_ue} special UE with ${count_status} time VONR call failure finally***
        ELSE IF    '${start_status}'=='True' and '${end_status}'=='True'
            ${count_status}=    Evaluate    ${count_status} + 1
            ${count_succ}=    Evaluate    ${count_succ} + 1
            Log To Console    ***${vonr_ue} special UE with ${count_status} time VONR call success finished***
        END
    END
    ${min_succ}    Evaluate    ${operation_times}*0.9
#    should be true    ${count_succ} > ${min_succ}

Check special ue online status
    [Arguments]    ${operation}=check_uestatus    ${verify_tag}="UE online number is correct"    ${type}=FDD    ${ignore}=True
    IF    '${type}'=='FDD'
        ${specialue_num} =    Run    python -c "exec(open('/opt/workspace/SCF/config.py').read()); print(UES_INFO[0]['spue_Num'])"
        ${operation_log} =    Run    python /opt/workspace/SCF/all_ues_operation.py ${operation}
        ${operation_log} =    Replace String    ${operation_log}    \n    ${EMPTY}
        ${count}=    Evaluate    "${operation_log}".count(${verify_tag})
        IF    ${count}==1
            Log To Console    ***Check ${specialue_num} special UE all online !!!***
        ELSE
            Log To Console    ***Check ${specialue_num} special UE NOT ALL corrcet online !!!***
        END
        IF    ${ignore}!=${True}
            Should Be Equal As Numbers    ${count}    1
        END
    ELSE IF    '${type}'=='TDD'
        Log To Console    ***WIth TDD as Pcell will not trigger the special UE added and check their behavior***
    END

Special UEs operation and verify
    [Arguments]    ${operation}=attach_startdata    ${verify_tag}="attach to NR success"    ${type}=FDD
    IF    '${type}'=='FDD'
        ${specialue_num} =    Run    python -c "exec(open('/opt/workspace/SCF/config.py').read()); print(UES_INFO[0]['spue_Num'])"
        ${vonr_ue} =    Run    python -c "exec(open('/opt/workspace/SCF/config.py').read()); print(UES_INFO[0]['vonrue_Num'])"
        ${reset_ue} =    Run    python -c "exec(open('/opt/workspace/SCF/config.py').read()); print(UES_INFO[0]['resetue_Num'])"
        ${operation_log} =    Run    python /opt/workspace/SCF/all_ues_operation.py ${operation}
        ${operation_log} =    Replace String    ${operation_log}    \n    ${EMPTY}
        ${count}=    Evaluate    "${operation_log}".count(${verify_tag})
        Log To Console    ***Check ${specialue_num} special UE with ${count} UEs ${verify_tag}***
        IF    '${operation}'=='attach_startdata' or '${operation}'=='detach_stopdata'
            Should Be Equal As Numbers    ${count}    ${specialue_num}
        ELSE IF    '${operation}'=='check_dltp'
            Should Be Equal As Numbers    ${count}    ${specialue_num}
        ELSE IF    '${operation}'=='reset_allue'
            Should Be Equal As Numbers    ${count}    ${reset_ue}
        END
        IF    '${operation}'=='start_vonr' or '${operation}'=='end_vonr'
            Should Be Equal As Numbers    ${count}    ${vonr_ue}
        END
    ELSE IF    '${type}'=='TDD'
        Log To Console    ***WIth TDD as Pcell will not trigger the special UE added and check their behavior***
    END

Check tput via spark
    [Arguments]    ${target_throughput}    ${ue_index}=${7}    ${direction}=DL
    ...    ${direction_UL}=NULL    ${target_throughput_UL}=NULL
    ${log}    power_ue.Collect Tput    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    duration=1s    ue_index=${ue_index}
    ${DL_throughput_check_result}=    Run Keyword And Return Status
    ...    power_ue.Check Tput    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    direction=${direction}    log=${log}
    ...        cells=UE_${ue_index}    target_throughput=${target_throughput}
    IF    ${DL_throughput_check_result} == ${False}
        Log To Console    DL target_throughput is not reach, please check!!!
        Fail    msg=DL target_throughput is not reach, please check!!!
    END
    IF    '${direction_UL}' !='NULL'
        ${UL_throughput_check_result}=    Run Keyword And Return Status
        ...    power_ue.Check Tput
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    direction=${direction_UL}    log=${log}    cells=UE_${ue_index}
        ...    target_throughput=${target_throughput_UL}
        IF    ${UL_throughput_check_result} == ${False}
            Log To Console    UL target_throughput is not reach, please check!!!
            Fail    msg=UL target_throughput is not reach, please check!!!
        END
    END

Multi UE stop ul traffic and detach
    [Arguments]    ${ue_index_MTU_all}=${ue_index_MTU_all}    ${APN}=${APN_${gnb_instance}}    ${direction_ul}=NULL
    FOR    ${index}    IN    @{ue_index_MTU_all}
#        Run keyword If    '${index}'=='${ue_index_MTU_all[5]}' or '${index}'=='${ue_index_MTU_all[6]}'
#        ...    Run Keyword and Ignore Error    Multi APN Stop traffic
#        ...    ue_index=${${index}-${1}}    Multi_APN_all=${Multi_APN_all_UE${index}_${gnb_instance}}    ue_mode=MultiUE_SACA
#        ...    ELSE    Run Keyword and Ignore Error    MultiUE.Stop DL Traffic
#        ...    ue_index=${${index}-${1}}    APN=${APN}    ue_mode=MultiUE_SACA
        Run keyword If    '${direction_ul}'!='NULL'
        ...    Run Keyword and Ignore Error    MultiUE.Stop DL Traffic
        ...    ue_index=${${index}-${1}}    APN=${APN}    direction=${direction_ul}
        MultiUE.Detach    ue_index=${${index}-${1}}
    END

Multi APN Stop traffic
    [Arguments]    ${ue_index}=${7}    ${Multi_APN_all}=${Multi_APN_all}    ${ue_mode}=MultiUE_SACA
    FOR    ${APN_index}    IN    @{Multi_APN_all}
        MultiUE.Stop DL Traffic    ue_index=${ue_index}    APN=${APN_index}    ue_mode=${ue_mode}
    END

Multi UE stop traffic and detach one apn
    [Arguments]    ${ue_index_MTU_all}=${ue_index_MTU_all}    ${APN}=${APN_${gnb_instance}}
    FOR    ${index}    IN    @{ue_index_MTU_all}
        MultiUE.Stop DL Traffic    ue_index=${${index}-${1}}    APN=${APN}
        MultiUE.Detach    ue_index=${${index}-${1}}
    END

Prapare Spark UE
    [Arguments]    ${ue_index_MTU_all}=${ue_index_MTU_all_${gnb_instance}}
    ...    ${ue_index_MTU_poweron_all}=${ue_index_MTU_poweroff_all}
    Check special ue online status    operation=check_uestatus    type=${pcell_tech}
    Multi MTU power and prepare ue     ue_index_MTU_all=${ue_index_MTU_all}
    ...    ue_index_MTU_poweron_all=${ue_index_MTU_poweron_all}
    ...    ue_index_MTU_poweroff_all=${ue_index_MTU_poweroffall}
    ...    MTU=Multi-UE Power Management.exe    detach_request=${false}    index_ue=${index_ue_${gnb_instance}}
    Log To Console    ***********Detach UE*********************
    FOR    ${index}    IN    @{ue_index_MTU_all}
        MultiUE.Detach    ue_index=${${index}-${1}}
    END
    Check special ue online status    operation=check_uestatus    ignore=False    type=${pcell_tech}
    Wait Until Keyword Succeeds   3X    5s    Special UEs operation and verify    operation=detach_stopdata
    ...    verify_tag="detach to NR success"
    Special UEs operation and verify    operation=reset_allue    verify_tag="this ue Reset Success"    type=${pcell_tech}
