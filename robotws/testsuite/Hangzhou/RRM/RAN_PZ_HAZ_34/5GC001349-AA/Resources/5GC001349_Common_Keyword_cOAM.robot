*** Settings ***
Documentation     author: y63li
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: ying.15.li@nokia-sbell.com

Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/siso_resource.robot
Library           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/get_bts_info.py    WITH NAME    lib
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource          taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource          taf/rfrl/common_resources/robot/stream_manager.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Library           taf.converters.pcaptopdml   WITH NAME   pcaptopdml
Library           get_pm_counter.py
Library    taf.analyzer.pcap    WITH NAME    pcap
Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library           taf.transport.ssh    WITH NAME    csn
Library           OperatingSystem
Library           Collections
Library           taf.pdu
Library           String
Library           Process
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${DU_OAM_IP}            ${tl.gnbs[0].dus[0].f1_m_ip_addr}

${WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}

${scf_name}    scf_5GC001349.xml
${tmp_log_dir}    /home/ute/logs
${testline}  7_5_UTE5G402T927
${full_path}    BTS/CELLS/NRCELL-1/NRACH
${tl_scf_dir_path}     commissionings/HGZ/7_5_UTE5G402T927/5GC001349-AA
${tl_scf_filename_1}    1349_1116_0.xml
${tl_scf_filename_2}    1349_1116_3.xml
${tl_scf_filename_3}    1349_1070.xml
${filename}     1349_case.pcap
${GNB_COAM_ALIAS}        GNB_OAM
${dltp}    10
${ultp}    3

*** Keywords ***
PRACH_format0_1116_0ms_PrachConfig_9_14
    Log To Console    \n *** run case 1001
    Enable Counter collect
    Configure prachConfigurationIndex to 9
    Start capture the wireshark log on gNB
    UE attach and start DL data transfer
    Check wireshark Message for index 9
	Connect to DU via ssl
    Check PM counter Result for format 0

PRACH_format0_1116_0ms_PrachConfig_9_14_PMCounter
    Log To Console    \n *** run case 1003
    Connect to DU via ssl
    Enable Counter collect
    Configure prachConfigurationIndex to 14
    Start capture the wireshark log on gNB
    UE attach and start DL data transfer
	Connect to DU via ssl
    Check wireshark Message for index 14
    Check PM counter Result for format 0

PRACH_format0_1116_3ms_PrachConfig_3_4_5_6_7_12
    Log To Console    \n *** run case 1005
	Connect to DU via ssl
    Configure prachConfigurationIndex to 3
    Start capture the wireshark log on gNB
    UE attach and start DL data transfer
    Check wireshark Message for index 3
    Configure prachConfigurationIndex to 4
    Start capture the wireshark log on gNB
    UE attach and start DL data transfer
    Check wireshark Message for index 4
    Configure prachConfigurationIndex to 5
    Start capture the wireshark log on gNB
    UE attach and start DL data transfer
    Check wireshark Message for index 5
    Configure prachConfigurationIndex to 6
    Start capture the wireshark log on gNB
    UE attach and start DL data transfer
    Check wireshark Message for index 6
    Configure prachConfigurationIndex to 7
    Start capture the wireshark log on gNB
    UE attach and start DL data transfer
    Check wireshark Message for index 7
    Configure prachConfigurationIndex to 12
    Start capture the wireshark log on gNB
    UE attach and start DL data transfer
    Check wireshark Message for index 12
    Configure prachConfigurationIndex to 93
    Start capture the wireshark log on gNB
    UE attach and start DL data transfer
    Check wireshark Message for index 93

PRACH_format0_1070_PrachConfig_0
    [Documentation]    This test case is used to test GNB’s supporting of the enable and disable of PRACH format 0 per cell
	Connect to DU via ssl
    Configure prachConfigurationIndex to 0
    Start capture the wireshark log on gNB
    UE attach and start DL data transfer
    Check wireshark Message for index 0

5GC001349_Common Suite Setup for COAM

    CI_interface.Common Suite Setup
    5GC001349_COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}
    Create directory    ${epc_log_path}
    Admin Get MrbtsId And NrbtsId
    Run Keyword And Ignore Error    robot_common_operations.Common Suite Setup

5GC001349_Common Suite Teardown for COAM
    Run Keyword And Ignore Error    AdminCli disconnection and Test teardown
    Run Keyword And Ignore Error    robot_common_operations.Common Suite teardown

5GC001349_Generate suite log path
    [Arguments]    ${timeout}=1min
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    wait until keyword succeeds    ${timeout}    2sec    Connect to DU via ssl
    ${sw_version} =     coam.get_sw_version    connection=${GNB_COAM_ALIAS}
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Set Suite Variable    ${sw_version}
    Create directory    ${SUITE_LOG_PATH}

5GC001349_COAM Create log directory
    [Arguments]  ${is_set_to_test_case_level}=${True}    ${timeout}=1min
    5GC001349_Generate suite log path    timeout=${timeout}
    Run keyword if  ${is_set_to_test_case_level}
    ...    Run keywords    Generate test case log path    AND
    ...    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
    ...    ELSE    Set suite variable    ${LOG_PATH}    ${SUITE_LOG_PATH}

Connect to DU via ssl
    [Arguments]  ${connection}=${GNB_COAM_ALIAS}    ${bts_host}=${DU_OAM_IP}
    ...    ${username}=${WEBUI_USER}
    ...    ${password}=${WEBUI_PASSWORD}
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}

Precondition: All cells can be on air
    log to console  \n***** Precondition: All cells can be on air *****
    Check If BTS Is OnAir

AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    admin_cli.teardown    connection=${GNB_COAM_ALIAS}

Admin Get MrbtsId And NrbtsId
    run keyword and ignore error    admin_cli.Teardown
    admin_cli.get_current_scf_file    local_dir_path=${epc_log_path}    file_name=${scf_name}    connection=${GNB_COAM_ALIAS}
    ${commission_file}    set variable    ${epc_log_path}/${scf_name}
    ${mrbtsId}    lib.Get_MRBTSID_cOAM    scf_path=${commission_file}
    ${nrbtsId}    lib.Get_NRBTSID_cOAM    scf_path=${commission_file}
    ${BTS_NAME}   lib.Get_BTS_name    scf_path=${commission_file}
    Set Suite Variable     ${mrbtsId}
    Set Suite Variable     ${nrbtsId}
    Set Suite Variable     ${dist_name}    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    Set Suite Variable     ${commission_file}
    Set Suite Variable     ${BTS_NAME}

Check If BTS Is OnAir
    ${bts_statuses_response}=    admin_cli.Get Bts Info    connection=${GNB_COAM_ALIAS}
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=OnAir

Connect to cOAM as toor4nsn
    [Arguments]    ${alias}=${GNB_COAM_ALIAS}
    Run Keyword And Ignore Error    csn.Disconnect    connection=${alias}
    csn.Connect To    hostname=${DU_OAM_IP}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${alias}

Disconnect from cOAM
    [Arguments]  ${connection}=cOAM_serviceuser
    ssh.disconnect  connection=${connection}

Configure prachConfigurationIndex to ${value}
    Log    \nConfigure prachConfigurationIndex to ${value}    console=yes
    admin_cli.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    parameter=prachConfigurationIndex
    ...    value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    ...    connection=${GNB_COAM_ALIAS}

UE attach and start DL data transfer
    log to console      Prepare UE
    power_ue.Prepare UE    ue_index=${0}    ue_type=huawei
    log to console      UE Attach
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei
    power_ue.Verify attach    ue_type=huawei    5Grach_ed=${5Grach_ed}    4G_check=False
    log to console      Start traffic
    power_ue.Start traffic    ue_index=${0}    direction=ul    throughput=50M    duration=1100    ue_type=huawei     iperf_type=via_command
    sleep    1s
    power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=800M    duration=1100    ue_type=huawei
    sleep  30
    log to console      Stop traffic
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=huawei    iperf_type=via_command
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=huawei
    log to console      UE Detach
    power_ue.UE Detach    ue_index=${0}    ue_type=huawei

Start capture the wireshark log on gNB
    Log    \nStart capture the wireshark log on gNB    console=yes
    Connect to cOAM as toor4nsn
    ssh.send command    command=timeout 500 tcpdump -i fp0 -w /user/toor4nsn/${filename}    connection=${GNB_COAM_ALIAS}

Download pcap file
    Log    \nDownload pcap file    console=yes
	sleep    15s
    Connect to cOAM as toor4nsn
    ssh.send command    command=pkill tcpdump    connection=${GNB_COAM_ALIAS}
    ssh.download_file   /user/toor4nsn/${filename}    ${tmp_log_dir}/${filename}
    ...                 connection=${GNB_COAM_ALIAS}
    ssh.send_command    command=rm ${filename}
    ...                 connection=${GNB_COAM_ALIAS}

Check wireshark Message for index ${index}
    Log    \nCheck wireshark Message for index ${index}    console=yes
	Download pcap file
    ${all_packets}=    pcap.load_pcap_file    pcap_file=${tmp_log_dir}/${filename}
    ${MR_Fliter} =    Catenate    x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27
    ${MR} =    pcap.filter_packets_by_expression    filter_expression=${MR_Fliter}
    ${MR_Value} =    pcap.get_field_value_by_xpath    pdml_list=${MR}    xpath=.//nr-rrc.prach_ConfigurationIndex
    should be equal    ${MR_Value[0]}    ${index}

Get ul and dl peak and ave throughput and return result
    [Documentation]    Get ul and dl peak and ave throughput and return result.
    ...    :param aasys_start_flag: for short time captrue use default, for long time call use ${False}, EG:${true}/${False}
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}    du_index=${du_index}
    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}

Case Teardown
    Log To Console    \n *** Case Teardown
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${0}    ue_type=huawei
    Run Keyword And Ignore Error    ssh.send command    command=pkill tcpdump    connection=${GNB_COAM_ALIAS}
    Run Keyword And Ignore Error    robot_common_operations.Common case Teardown

Case Setup for 1116-3
    Log To Console    \n *** Case Setup for 1116-3
	Connect to DU via ssl
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}/${tl_scf_filename_2}    timeout=500    is_pdl_checking_needed=${False}
    wait until keyword succeeds    30min    5min     Precondition: All cells can be on air
    Run Keyword And Ignore Error    robot_common_operations.Common case setup

Case Setup for 1070
    Log To Console    \n *** Case Setup for 1070
	Connect to DU via ssl
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}/${tl_scf_filename3}    timeout=500    is_pdl_checking_needed=${False}
    wait until keyword succeeds    30min    5min     Precondition: All cells can be on air
    Run Keyword And Ignore Error    robot_common_operations.Common case setup

Enable Counter collect
    Log    \nEnable Counter collect    console=yes
    admin_cli.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMCADM-1
    ...    parameter=reportingIntervalPm
    ...    value=5min
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    ...    connection=${GNB_COAM_ALIAS}

Check PM counter Result for format 0
    Log    \nCheck PM counter Result for format 0    console=yes
    sleep    10min
    Check PM counter Result    full_path=${full_path}    counter_id=M55306C00001
    Check PM counter Result    full_path=${full_path}    counter_id=M55306C03001
    Check PM counter Result    full_path=${full_path}    counter_id=M55306C06001

Check PM counter Result
    [Arguments]    ${counter_id}    ${full_path}
    ${counter_result}    Check PM counter    ${counter_id}    ${full_path}
    ${counter_ready}    Set variable    ${0}
    FOR    ${i}    IN    @{counter_result}
        ${res}=    run keyword and return status    should be true    ${i}>0
        continue for loop if    ${res}==${False}
        ${counter_ready}    Evaluate    ${counter_ready}+1
    END
    Should be true    ${counter_ready} >0    msg=all counter value not increase.

Check PM counter
    [Arguments]    ${counter_id}    ${full_path}    ${date}=all
    Connect to gnb coam via ssl
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=${GNB_COAM_ALIAS}
    ...    dic_path=${full_path}    date=${date}
    [Return]    ${counter_value}
    [Teardown]    COAM Teardown gnb connections
