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
Library           testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001349-AA/Resources/get_pm_counter.py
Library           taf.analyzer.pcap    WITH NAME    pcap
Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library           taf.transport.ssh    WITH NAME    csn
Library           OperatingSystem
Library           Collections
Library           taf.pdu
Library           String
Library           Process
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010636/Resources/CB010636_CDE.robot

*** Variables ***
##ALIAS##
${att_ipaddr}               ${tl.attenuator[0].ip_addr}
${att_api_port}             ${tl.attenuator[0].port}
${DU_OAM_IP}            ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${GNB_COAM_ALIAS}        GNB_OAM
##ENB##
${eNB_asik_addr}            ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_instance}             ${tl.enbs[0].instance_id}
${enbx2_dist}               MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-0
${enbx2_para}               administrativeState
${enbcell_dist}             MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${enbcell_para1}            administrativeState
${enbcell_para2}            defaultLnRelGnbCellId
##UE##
${DL_TIME}                  600
${DL_LENGTH}                1024B
${UL_TIME}                  600
${UL_LENGTH}                1024B
##SCF##
${scf_name}                 CNI98930_SCF_SBTS00.xml
@{scf}                      1116_0ms.xml    1116_3ms.xml    1070.xml    1116_0ms_24R1.xml
${case_scf_dir_path}      ${commissionings_path}/HGZ/7_5_UTE5G402T919/CNI-98930/
##tput##
${ul_tput}                  50M
${dl_tput}                  1500M   ##peak 1.4Gbps
${expect_dl_tput}           100
##LOGS##
${tmp_log_dir}    /home/ute/log
${filename}     CNI98930_case.pcap
##COUNT##
${full_path1}    BTS/CELLS/NRCELL-1/NRACH
${full_path2}    BTS/MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-1/NRACH


*** Keywords ***
PRACH_format0_1116_0ms_PrachConfig_9_14
    Log To Console    \n *** run case PRACH_format0_1116_0ms_PrachConfig_9_14
    CNI-98930_Common_Keywords.Connect to DU via ssl
    ${release}    coam.get_sw_release_name    connection=${GNB_COAM_ALIAS}
    run keyword if    '${release}' == 'SBTS24R1'
    ...    CNI-98930_Common_Keywords.Prepare testline to cell onair    localFilePath=${case_scf_dir_path}
    ...    tl_scf_filename=${scf[3]}
    ...    ELSE IF    '${release}' == 'SBTS24R2'
    ...    CNI-98930_Common_Keywords.Prepare testline to cell onair    localFilePath=${case_scf_dir_path}
    ...    tl_scf_filename=${scf[0]}
    ...    ELSE    CNI-98930_Common_Keywords.Prepare testline to cell onair    localFilePath=${case_scf_dir_path}
    ...    tl_scf_filename=${scf[0]}
    CNI-98930_Common_Keywords.Connect to DU via ssl
    Configure prachConfigurationIndex to 9
    Start capture the wireshark log on gNB
    Power UE Attach and Start traffic     dl_throughput=${dl_tput}    type=NSA
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput}
    Power UE stop dl traffic and detach
    Check wireshark Message for index 9

PRACH_format0_1116_0ms_PrachConfig_9_14_PMCounter
    Log To Console    \n *** PRACH_format0_1116_0ms_PrachConfig_9_14_PMCounter
    CNI-98930_Common_Keywords.Connect to DU via ssl
    ${release}    coam.get_sw_release_name    connection=${GNB_COAM_ALIAS}
    run keyword if    '${release}' == 'SBTS24R1'
    ...    CNI-98930_Common_Keywords.Prepare testline to cell onair    localFilePath=${case_scf_dir_path}
    ...    tl_scf_filename=${scf[3]}
    ...    ELSE IF    '${release}' == 'SBTS24R2'
    ...    CNI-98930_Common_Keywords.Prepare testline to cell onair    localFilePath=${case_scf_dir_path}
    ...     tl_scf_filename=${scf[0]}
    ...    ELSE    CNI-98930_Common_Keywords.Prepare testline to cell onair    localFilePath=${case_scf_dir_path}
    ...     tl_scf_filename=${scf[0]}
    CNI-98930_Common_Keywords.Connect to DU via ssl
    Configure prachConfigurationIndex to 14
    CNI-98930_Common_Keywords.Enable Counter collect
    Start capture the wireshark log on gNB
    Power UE Attach and Start traffic     dl_throughput=${dl_tput}    type=NSA
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput}
    Power UE stop dl traffic and detach
    Check wireshark Message for index 14
    wait until keyword succeeds    5m    1m    Check PM counter Result for format 0

PRACH_format0_1116_3ms_PrachConfig_3_4_5_6_7_12
    Log To Console    \n *** PRACH_format0_1116_3ms_PrachConfig_3_4_5_6_7_12
    CNI-98930_Common_Keywords.Prepare testline to cell onair    localFilePath=${case_scf_dir_path}
    ...      tl_scf_filename=${scf[1]}
	CNI-98930_Common_Keywords.Connect to DU via ssl
    Configure prachConfigurationIndex to 3
    Start capture the wireshark log on gNB
    Power UE Attach and Start traffic     dl_throughput=${dl_tput}    type=NSA
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput}
    Power UE stop dl traffic and detach
    Check wireshark Message for index 3
    Configure prachConfigurationIndex to 4
    Start capture the wireshark log on gNB
    Power UE Attach and Start traffic      dl_throughput=${dl_tput}    type=NSA
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput}
    Power UE stop dl traffic and detach
    Check wireshark Message for index 4
    Configure prachConfigurationIndex to 5
    Start capture the wireshark log on gNB
    Power UE Attach and Start traffic     dl_throughput=${dl_tput}    type=NSA
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput}
    Power UE stop dl traffic and detach
    Check wireshark Message for index 5
    Configure prachConfigurationIndex to 6
    Start capture the wireshark log on gNB
    Power UE Attach and Start traffic    dl_throughput=${dl_tput}    type=NSA
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput}
    Power UE stop dl traffic and detach
    Check wireshark Message for index 6
    Configure prachConfigurationIndex to 7
    Start capture the wireshark log on gNB
    Power UE Attach and Start traffic    dl_throughput=${dl_tput}    type=NSA
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput}
    Power UE stop dl traffic and detach
    Check wireshark Message for index 7
    Configure prachConfigurationIndex to 12
    Start capture the wireshark log on gNB
    Power UE Attach and Start traffic    dl_throughput=${dl_tput}    type=NSA
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput}
    Power UE stop dl traffic and detach
    Check wireshark Message for index 12
    Configure prachConfigurationIndex to 93
    Start capture the wireshark log on gNB
    Power UE Attach and Start traffic     dl_throughput=${dl_tput}    type=NSA
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput}
    Power UE stop dl traffic and detach
    Check wireshark Message for index 93

PRACH_format0_1070_PrachConfig_0
    Log To Console    \n *** PRACH_format0_1070_PrachConfig_0
    CNI-98930_Common_Keywords.Prepare testline to cell onair    localFilePath=${case_scf_dir_path}
    ...      tl_scf_filename=${scf[2]}
	CNI-98930_Common_Keywords.Connect to DU via ssl
    Configure prachConfigurationIndex to 0
    Start capture the wireshark log on gNB
    Power UE Attach and Start traffic     dl_throughput=${dl_tput}    type=NSA
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput}
    Power UE stop dl traffic and detach
    Check wireshark Message for index 0

CNI98930_Common Suite Setup for COAM
    #CI_interface.Common Suite Setup
    CNI98930_COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}
    Create directory    ${epc_log_path}
    CNI-98930_Common_Keywords.Admin Get MrbtsId And NrbtsId
    Check eNB Anchor Cell OnAir
    Configure correct defaultLnRelGnbCellId for anchor cell
    Run Keyword And Ignore Error    robot_common_operations.Common Suite Setup

CNI98930_Common Suite Teardown for COAM
    Run Keyword And Ignore Error    CNI-98930_Common_Keywords.AdminCli disconnection and Test teardown
    Run Keyword And Ignore Error    robot_common_operations.Common Suite teardown

CNI98930_Generate suite log path
    [Arguments]    ${timeout}=1min
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    wait until keyword succeeds    ${timeout}    2sec    CNI-98930_Common_Keywords.Connect to DU via ssl
    ${sw_version} =     coam.get_sw_version    connection=${GNB_COAM_ALIAS}
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Set Suite Variable    ${sw_version}
    Create directory    ${SUITE_LOG_PATH}

CNI98930_COAM Create log directory
    [Arguments]  ${is_set_to_test_case_level}=${True}    ${timeout}=1min
    CNI98930_Generate suite log path    timeout=${timeout}
    Run keyword if  ${is_set_to_test_case_level}
    ...    Run keywords    Generate test case log path    AND
    ...    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
    ...    ELSE    Set suite variable    ${LOG_PATH}    ${SUITE_LOG_PATH}

CNI-98930_Common_Keywords.Connect to DU via ssl
    [Arguments]  ${connection}=${GNB_COAM_ALIAS}    ${bts_host}=${DU_OAM_IP}
    ...    ${username}=${WEBUI_USER}
    ...    ${password}=${WEBUI_PASSWORD}
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}

Precondition: All cells can be on air
    log to console  \n***** Precondition: All cells can be on air *****
    CNI-98930_Common_Keywords.Check If BTS Is OnAir

AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    admin_cli.teardown    connection=${GNB_COAM_ALIAS}

CNI-98930_Common_Keywords.Admin Get MrbtsId And NrbtsId
    run keyword and ignore error    admin_cli.Teardown
    admin_cli.get_current_scf_file    local_dir_path=${epc_log_path}    file_name=${scf_name}
    ...      connection=${GNB_COAM_ALIAS}
    ${commission_file}    set variable    ${epc_log_path}/${scf_name}
    ${mrbtsId}    lib.Get_MRBTSID_cOAM    scf_path=${commission_file}
    ${nrbtsId}    lib.Get_NRBTSID_cOAM    scf_path=${commission_file}
    ${BTS_NAME}   lib.Get_BTS_name    scf_path=${commission_file}
    Set Suite Variable     ${mrbtsId}
    Set Suite Variable     ${nrbtsId}
    Set Suite Variable     ${dist_name}    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    Set Suite Variable     ${commission_file}
    Set Suite Variable     ${BTS_NAME}

CNI-98930_Common_Keywords.Check If BTS Is OnAir
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

##prepare BTS##
Check eNB Anchor Cell OnAir
    Wait until keyword succeeds    10min    30s    Check the enb anchor cell onAir

Check the enb anchor cell onAir
    Connect to eNB via ssl
	${enbcell_status}=    Get the anchor cell status from btsinfo    'cells.lte.1.status.operationalState'
	should be equal    ${enbcell_status}    enabled

Get the anchor cell status from btsinfo
    [Arguments]    ${filter}
	${output} =    enblte.get_bts_info    connection=enblte
	enblte.teardown    connection=enblte
    @{list} =    Evaluate    ${filter}.split('.')
    ${output_VALUE} =     get from dictionary    ${output}            ${list}[0]
    ${output_VALUE_1} =   get from dictionary    ${output_VALUE}      ${list}[1]
    ${output_VALUE_2}     set variable           ${output_VALUE_1}[1]
    ${output_VALUE_3} =   get from dictionary    ${output_VALUE_2}    ${list}[3]
    ${output_VALUE_4} =   get from dictionary    ${output_VALUE_3}    ${list}[4]
	[Return]    ${output_VALUE_4}

Enblte close down
    [Arguments]    ${connection}=enblte
    enblte.teardown    connection=${connection}

Configure correct defaultLnRelGnbCellId for anchor cell
    run keyword and ignore error     Connect and Modify the parameter on enblte scip errors    dist_name=${enbcell_dist}
    ...    parameter=${enbcell_para2}    value=1

Configure prachConfigurationIndex to ${value}
    Log    \nConfigure prachConfigurationIndex to ${value}    console=yes
    CNI-98930_Common_Keywords.Connect to DU via ssl
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
    ssh.send command    command=timeout 500 tcpdump -i any -w /user/toor4nsn/${filename}    connection=${GNB_COAM_ALIAS}

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

CNI-98930_Common_Keywords.Case Teardown
    Log To Console    \n *** Case Teardown
    run keyword and ignore error     csn.disconnect    connection=cpc_0
    run keyword and ignore error     coam.teardown    connection=GNB_OAM
    run keyword and ignore error     csn.disconnect    connection=${asib_alias}
    run keyword and ignore error     enblte.teardown    connection=enblte
    Run Keyword And Ignore Error    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown

CNI-98930_Common_Keywords.Case Setup
    Log To Console    \n *** Case Setup
    Run Keyword And Ignore Error    robot_common_operations.Common case setup

CNI-98930_Common_Keywords.Enable Counter collect
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
    #Check PM counter Result    full_path=${full_path}    counter_id=M55306C00001
    #Check PM counter Result    full_path=${full_path}    counter_id=M55306C03001
    CNI-98930_Common_Keywords.Connect to DU via ssl
    ${release}    coam.get_sw_release_name    connection=${GNB_COAM_ALIAS}
    run keyword if    '${release}' == 'SBTS23R4'
    ...     CNI-98930_Common_Keywords.Check PM counter Result    counter_id=M55306C06001   full_path=${full_path1}
    ...    ELSE    CNI-98930_Common_Keywords.Check PM counter Result    counter_id=M55306C06001
    ...      full_path=${full_path2}
#    Check PM counter Result    full_path=${full_path}    counter_id=M55306C06001

CNI-98930_Common_Keywords.Check PM counter Result
    [Arguments]    ${counter_id}    ${full_path}
    ${counter_result}    CNI-98930_Common_Keywords.Check PM counter    ${counter_id}    ${full_path}
    ${counter_ready}    Set variable    ${0}
    FOR    ${i}    IN    @{counter_result}
        ${res}=    run keyword and return status    should be true    ${i}>0
        continue for loop if    ${res}==${False}
        ${counter_ready}    Evaluate    ${counter_ready}+1
    END
    Should be true    ${counter_ready} >0    msg=all counter value not increase.

CNI-98930_Common_Keywords.Check PM counter
    [Arguments]    ${counter_id}    ${full_path}    ${date}=all
    Connect to gnb coam via ssl
    ${counter_value} =    get_pm_counter.get_pm_counter_values    counter_id=${counter_id}    connection=${GNB_COAM_ALIAS}
    ...    dic_path=${full_path}    date=${date}
    [Return]    ${counter_value}
    [Teardown]    COAM Teardown gnb connections

CNI-98930_Common_Keywords.Prepare testline to cell onair
    [Arguments]      ${localFilePath}    ${tl_scf_filename}
    Perform full commission for COAM gnb    localFilePath=${localFilePath}    tl_scf_filename=${tl_scf_filename}
    COAM Wait for gnb ready
    Sleep    60s
    Wait until keyword succeeds    10min    30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

Perform full commission for COAM gnb
    [Arguments]    ${tl_scf_filename}    ${localFilePath}
    Connect to gnb coam via ssl   bts_host=${DU_OAM_IP}
    COAM Commission with scf file    scf_file_path=${localFilePath}${tl_scf_filename}    timeout=500    is_pdl_checking_needed=${False}
    [Teardown]    COAM Teardown gnb connections

Connect and Modify the parameter on enblte scip errors
    [Arguments]    ${dist_name}    ${parameter}     ${value}
    Connect to eNB via ssl
    Modify the parameter on enblte and scip errors    ${dist_name}     ${parameter}    ${value}
    enblte.teardown    connection=enblte

Modify the parameter on enblte and scip errors
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}
    enblte.perform_parameter_recommissioning       dist_name=${dist_name}
    ...                                            parameter=${parameter_name}
    ...                                            operation=update
    ...                                            value=${value}
    ...                                            connection=enblte
    ...                                            skip_parameter_relation_errors=True

COAM Wait for gnb ready
    [Documentation]  Author: Ding Binmei
    ...              Description: Wait until GNB status ready.
    [Timeout]  30 min
    [Arguments]  ${timeout}=10 min    ${connection}=GNB_OAM
    Wait until keyword succeeds    ${timeout}    20 sec    Connect to gnb coam via ssl    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB ABIL status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB ASIK status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB RU status    connection=${connection}

##UE##
Power UE Attach and Start traffic
    [Arguments]     ${dl_throughput}    ${type}
    Power UE Precondition
    #Run keyword and continue on failure    _Reboot UE    connection=cpc_0
    #Run keyword if    '${type}' == 'SA'    _Reboot UE    connection=cpc_0
    Sleep    60s
    Run keyword if    '${type}' == 'NSA'
    ...    Run keyword and continue on failure    Power UE Attach and Verify attach    4g_check=True
    ...    ELSE    Run keyword and continue on failure    Power UE Attach and Verify attach    4g_check=False
    Power UE Start traffic     dl_throughput=${dl_throughput}

Power UE Precondition
    [Arguments]    ${ue_type}=qct_dx50
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    capatibility_index=${0}    reset_sol=ue_reboot     detach_request=${true}

Power UE Attach and Verify attach
    [Arguments]    ${4g_check}    ${gnb_index}=${0}    ${ue_type}=qct_dx50
    Log To Console    \n *** UE Attach started
     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${0}    gnb_index=${gnb_index}
    ...                       4G_check=${4g_check}    5Gstatus=PASS

Power UE Start traffic
    [Arguments]    ${dl_throughput}     ${duration}=${DL_TIME}    ${dl_length}=${DL_LENGTH}    ${dl_port}=default
    ...     ${ue_type}=qct_dx50
    Log To Console    \n *** Start DL traffic
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}
    ...                       iperf_port=${dl_port}    ue_index=${0}    cap_index=${0}    buffer_size=${dl_length}

Power UE check throughput
    [Arguments]    ${Expect_DOWNLINK}    ${ue_type}=qct_dx50
    Log To Console    \n *** Start to check DL throughput
    #wait until keyword succeeds    2min    10s    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${Expect_DOWNLINK}
    #...    ue_index=${ue_index}    hw_slot=1    sample=${10}    start_offset=${3}    sleep_time=${5}    cellid=${EMPTY}    gnb_index=${gnb_index}
    ${DLtput_log}    Run keyword and continue on failure    power_ue.Collect Tput
    ...    ue_type=${ue_type}    duration=60s    ignore_time=5s    filter=L2Lo
    Run keyword and ignore error    power_ue.Check Tput
    ...    ue_type=${ue_type}    direction=DL    log=${DLtput_log}    cells=${EMPTY}
    ...    target_throughput=${Expect_DOWNLINK}    target_avg_percent=0.95    min_percent=0.75

Power UE stop dl traffic
    [Arguments]    ${dl_port}=default    ${ue_type}=qct_dx50
    Log To Console    \n *** Stop DL traffic
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}

Power UE stop ul traffic
    [Arguments]    ${ul_port}=default    ${ue_type}=qct_dx50
    Log To Console    \n *** Stop UL traffic
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${ul_port}

Power UE Detach
    [Arguments]    ${ue_type}=qct_dx50
    Log To Console    \n *** UE Detach started
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

Power UE stop dl traffic and detach
    [Arguments]    ${dl_port}=default    ${ue_type}=qct_dx50
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}
    sleep    3s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
