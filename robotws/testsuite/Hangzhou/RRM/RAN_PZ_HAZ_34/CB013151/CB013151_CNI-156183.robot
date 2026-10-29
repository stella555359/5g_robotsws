*** Settings ***
Documentation      Author: yayun.zhang@nokia.com
...                squad group: SG_03
...                feature : CB013151_CNI-156183

Library    OperatingSystem
Library    Collections
Library    String
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/l1l2bip_collect.robot
Variables          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB013151/Resources/CB013351_Variables.py



Suite Setup         BuiltIn.Run Keywords     CB013151_suite_setup
...                 AND                      CB013351 Common Case TestLine Setup with gnb1 and gnb2

Suite Teardown      CB013351_suite_teardown

*** Variables ***
${allow_fault_list_13351}                    7101    7107    62003
${gnb1_instance}                             ${tl.gnbs[0].instance_id}
${gnb2_instance}                             ${tl.gnbs[2].instance_id}
${SCF_name_38711}                            SCF_GNB1
${SCF_name_38712}                            SCF_GNB2
${scf_path}                                  /opt/workspace/SCF/
@{gnb_list}                                  ${0}    ${1}
${bts_host0}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${bts_host1}    ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${ue_type_qcom}    ${tl.ues[13].capabilities[0]}
${log_name_156183_1}      log_name_attach_156183_1.pcap
${Send_Tput_UL}    200M
${expected_tput_UL}    190
${traffic_ul_port}    ${tl.ues[13].iperf_details.ssh_connection_details.port}
*** Test Cases ***
CB013151_test
    [Documentation]    CNI-156183
    CB013351_case_setup    online_ModifySCF_GNB1=True
    ...                    Modify_Para_Online_GNB1=${parameters_to_update_CB013151_CNI156183}    skip_parameter_relation_errors=False

#    Online modify parmeters    parameters_to_update=${parameters_to_update_CB013151_CNI156183}    skip_parameter_relation_errors=False
    Adjust gNB_RU Attenuation for 2gnb   gnb1_cell1_value=${0}
    qcom attach for step    logname=${log_name_156183_1}
    sleep    5s
    qcom UE make UL traffic
    ${13151_C_bip}    Collect bip log for 13151    target_file_name=13151_bip_273Prb    gnb_index=${0}
    check 13151 bip log    filepath=${13151_C_bip}    subcellid=${0}
    [Teardown]    Run Keyword    CB013351_case_teardown

*** Keywords ***
qcom attach for step
    [Arguments]    ${logname}
    Start capture gNB log on master    filename=${logname}
    Power_ue.Prepare UE    ue_type=${ue_type_qcom}    ue_index=${13}
    Attach and check power UE    ue_type=${ue_type_qcom}    ue_index=${13}    gnb_index=${0}
    Sleep    5s
    [Teardown]    run keyword    Stop and download Logs on gNB on master    filename=${logname}

qcom UE make UL traffic
    comment    X75 make traffic with UL
    Start only UL traffic and check tput    ue_index=${13}    cellid=${3}    ue_type=${ue_type_qcom}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_UL}    ul_throughput=${Send_Tput_UL}    duration=${7200}
    ...                                ul_port=${traffic_ul_port}

Start only UL traffic and check tput
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${ul_throughput}=${Send_Tput_UL}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${direction}=UL    ${tput_ul_cell}=${expected_tput_UL}    ${ul_port}=${ul_port}    ${duration}=${600}
    ...    ${iperf_type}=via_app
    Power UE Start UL traffic    ue_index=${ue_index}    ue_type=${ue_type}    ul_throughput=${ul_throughput}    duration=${duration}
    ...    ul_port=${ul_port}    iperf_type=${iperf_type}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${tput_ul_cell}    gnb_index=${gnb_index}

Collect bip log for 13151
    [Arguments]    ${target_file_name}    ${gnb_index}=${0}
    Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}    interface=L1-L2    nr_phy_cell_ids=713
    ...                                          host_ip=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...                                          username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...                                          password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    sleep    1s    reason=wait for a while after start traffic.
    ${13151_bip}     Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}    target_dir=${epc_log_path}
    [Return]     ${13151_bip}[0]

check 13151 bip log
    [Arguments]    ${filepath}    ${subcellid}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${filepath}    alias=test6
#    ${filter_expression}=     Catenate    ((3gpp.subcellid == ${subcellid}) && (UlData_puschReceiveReqGrant_t.startPrb == 0)) &&
#    ...                                     (UlData_puschReceiveReqGrant_t.numOfPrb == 273)
    ${filter_expression}=     Catenate    (((3gpp.subcellid == ${subcellid}) && (UlData_puschReceiveReqGrant_t.startPrb == 0)) &&
    ...                                   (UlData_puschReceiveReqGrant_t.numOfPrb == 273)) && (UlData_puschReceiveReqGrant_t.mcs == 27)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
#    ${numOfPrb}=     cap.Get Field Value By Xpath    xpath=.//UlData_puschReceiveReqGrant_t.numOfPrb    pcap_parser=test6
#    should contain    ${numOfPrb}    273
    ${mcs}=     cap.Get Field Value By Xpath    xpath=.//UlData_puschReceiveReqGrant_t.mcs    pcap_parser=test6
    should contain    ${mcs}    27

stop traffic and detach ue
    Comment     stop traffic and detach ue
    Stop DL or UL traffic    ue_index=${13}    ue_type=${ue_type_qcom}    direction=UL
    QCM UE Recover Detach    ue_index=${13}    status=${0}    ue_type=${ue_type_qcom}

Stop DL or UL traffic
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${direction}=DL     ${protocol}=udp    ${iperf_port}=default
    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    protocol=${protocol}    iperf_port=${iperf_port}

QCM UE Recover Detach
    [Arguments]     ${ue_index}=${0}    ${status}=${0}    ${ue_type}=${ue_type}
    check voice call status    ue_index=${ue_index}    status=${status}
    UE.UE Detach     ue_type=${ue_type}     ue_index=${ue_index}

check voice call status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=${2}
    Wait Until Keyword Succeeds    3x    30sec
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    ##### check voice call enable  #####
    ##### 0: the phone is in standby state. 1: the call is not answered. 2: the phone is busy  #####
    csn.send_command    command=adb -s ${serial_number} shell dumpsys telephony.registry |grep mCallState
    ...    connection=cpc_${ue_index}
    sleep   2s
    ${result} =    csn.read output    connection=cpc_${ue_index}
    sleep    1s
    csn.disconnect      connection=cpc_${ue_index}
    should contain    ${result}    mCallState=${status}

#common suite keyword
#-----------------------------preparation-----------------------#
CB013151_suite_setup
#    [Arguments]    ${GNB1_SCF}=${None}    ${GNB2_SCF}=${None}
#    ...            ${is_commission}=False
#    ...            ${is_commission_for_second_gnb}=False
#    ...            ${Is_Swconfig}=False
#    ...            ${Is_Swconfig_for_GNB2}=False
#    ...            ${swconfig_target_path_GNB1}=${None}
#    ...            ${swconfig_file_GNB1}=${None}
#    ...            ${swconfig_modify_GNB1}=${None}
#    ...            ${swconfig_target_path_GNB2}=${None}
#    ...            ${swconfig_file_GNB2}=${None}
#    ...            ${swconfig_modify_GNB2}=${None}
    Common Suite Setup for COAM
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}
#    Common Case TestLine Setup
#    ...                            is_commission=${is_commission}
#    ...                            golden_scf_name=${GNB1_SCF}
#    ...                            is_commission_for_second_gnb=${is_commission_for_second_gnb}
#    ...                            golden_scf_name_gnb2=${GNB2_SCF}
#    ...                            Is_Swconfig=${Is_Swconfig}
#    ...                            swconfig_target_path=${swconfig_target_path_GNB1}
#    ...                            swconfig_file=${swconfig_file_GNB1}
#    ...                            swconfig_modify=${swconfig_modify_GNB1}
#    ...                            Is_Swconfig_for_GNB2=${Is_Swconfig_for_GNB2}
#    ...                            swconfig_target_path_gnb2=${swconfig_target_path_GNB2}
#    ...                            swconfig_file_gnb2=${swconfig_file_GNB2}
#    ...                            swconfig_modify_gnb2=${swconfig_modify_GNB2}


CB013351 Common Case TestLine Setup with gnb1 and gnb2
    @{scf_list}    Create List
#    ${release_info}    Get sagnb release
    Append to List    ${scf_list}
    ...    ${scf_path}${SCF_name_${gnb1_instance}}_${release_info}.xml    ${scf_path}${SCF_name_${gnb2_instance}}_${release_info}.xml
    Log to console    Start to modify scf files and commission, please wait...
    Multi-gNB commission    index_list=${gnb_list}    scf_list=${scf_list}
    CB013351 Check the MultiBTS cells status on air    gnb_list=${gnb_list}

CB013351 Check the MultiBTS cells status on air
    [Documentation]
    ...    Description: check multi gnb cells is on air
    ...    para gnb_list: gnb_index_list(type is list) '@{gnb_list}', Default is 0  1
    [Arguments]        ${gnb_list}=${gnb_list}
    FOR    ${gnb_index}    IN    @{gnb_list}
        Wait until keyword succeeds    20 min    20s
        ...    Check the cells status on air    bts_host=${bts_host${gnb_index}}   connection=gnb${gnb_index}
    END

CB013351_suite_teardown
    CI_interface.Common Case Teardown
    Run keyword and ignore error    Tear down the all connections
    robot_common_operations.Common Suite Teardown

CB013351_case_setup
    [Arguments]     ${online_ModifySCF_GNB1}=False
    ...             ${Modify_Para_Online_GNB1}='NULL'
    ...             ${Add_Para_Online_GNB1}='NULL'
    ...             ${Delete_Mo_Online_GNB1}='NULL'
    ...             ${Delete_Para_Online_GNB1}='NULL'
    ...             ${online_ModifySCF_GNB2}=False
    ...             ${Modify_Para_Online_GNB2}='NULL'
    ...             ${Add_Para_Online_GNB2}='NULL'
    ...             ${Delete_Mo_Online_GNB2}='NULL'
    ...             ${Delete_Para_Online_GNB2}='NULL'
    ...             ${allow_fault_list}=${allow_fault_list_14474}
    ...             ${skip_parameter_relation_errors}=False
    robot_common_operations.Common Case Setup        allowed_faults_ids=62003
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Common Case TestLine Setup        ModifySCF_Aftercommission=${online_ModifySCF_GNB1}
    ...                               Modify_Para_Online=${Modify_Para_Online_GNB1}
    ...                               Add_Para_Online=${Add_Para_Online_GNB1}
    ...                               Delete_Para_Online=${Delete_Para_Online_GNB1}
    ...                               Delete_Mo_Online=${Delete_Mo_Online_GNB1}
    ...                               ModifySCF_Aftercommission_for_GNB2=${online_ModifySCF_GNB2}
    ...                               Modify_Para_Online_GNB2=${Modify_Para_Online_GNB2}
    ...                               Add_Para_Online_GNB2=${Add_Para_Online_GNB2}
    ...                               Delete_Para_Online_GNB2=${Delete_Para_Online_GNB2}
    ...                               Delete_Mo_Online_GNB2=${Delete_Mo_Online_GNB2}
    ...                               skip_parameter_relation_errors=${skip_parameter_relation_errors}


CB013351_case_teardown
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    Stop and download the Logs    filename=${log_name_156183_1}   gNB_index=${0}
    stop traffic and detach ue
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot via api
    CB013351_case_setup    online_ModifySCF_GNB1=True
    ...                    Modify_Para_Online_GNB1=${parameters_to_recovery_CB013151_CNI156183}    skip_parameter_relation_errors=False
#    Online modify parmeters         parameters_to_update=${parameters_to_recovery_CB013151_CNI156183}    skip_parameter_relation_errors=False
    Adjust gNB_RU Attenuation for 2gnb
    Run keyword and ignore error    Teardown the all connections
    Run keyword and ignore error    CI_interface.Common Case Teardown

Adjust gNB_RU Attenuation for 2gnb
    [Arguments]     ${tl}=${gnb1_instance}
    ...    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}
    ...    ${gnb1_cell3_value}=${127}
    ...    ${gnb2_cell1_value}=${127}    ${gnb2_cell2_value}=${127}
    ...    ${gnb2_cell3_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_gnb1_cell1_${tl}}    ${att_port_2_gnb1_cell1_${tl}}
    ...    ${att_port_3_gnb1_cell1_${tl}}    ${att_port_4_gnb1_cell1_${tl}}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_1_gnb1_cell2_${tl}}    ${att_port_2_gnb1_cell2_${tl}}
    ...    ${att_port_3_gnb1_cell2_${tl}}    ${att_port_4_gnb1_cell2_${tl}}
    @{att_ports_gnb1_cell3}    Create List    ${att_port_1_gnb1_cell3_${tl}}    ${att_port_2_gnb1_cell3_${tl}}
    ...    ${att_port_3_gnb1_cell3_${tl}}    ${att_port_4_gnb1_cell3_${tl}}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_1_gnb2_cell1_${tl}}    ${att_port_2_gnb2_cell1_${tl}}
    ...    ${att_port_3_gnb2_cell1_${tl}}    ${att_port_4_gnb2_cell1_${tl}}
    @{att_ports_gnb2_cell2}    Create List    ${att_port_1_gnb2_cell2_${tl}}    ${att_port_2_gnb2_cell2_${tl}}
    ...    ${att_port_3_gnb2_cell2_${tl}}    ${att_port_4_gnb2_cell2_${tl}}
    @{att_ports_gnb2_cell3}    Create List    ${att_port_1_gnb2_cell3_${tl}}    ${att_port_2_gnb2_cell3_${tl}}
    ...    ${att_port_3_gnb2_cell3_${tl}}    ${att_port_4_gnb2_cell3_${tl}}
    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb1_cell3}    Create List    ${gnb1_cell3_value}    ${gnb1_cell3_value}    ${gnb1_cell3_value}    ${gnb1_cell3_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_gnb2_cell2}    Create List    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}
    @{values_gnb2_cell3}    Create List    ${gnb2_cell3_value}    ${gnb2_cell3_value}    ${gnb2_cell3_value}    ${gnb2_cell3_value}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_gnb1_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell1_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_gnb1_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell2_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell3}    values=${values_gnb1_cell3}
    ...    att_connection_port=${att_port_1_gnb1_cell3_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell3_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_gnb2_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell1_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell2}    values=${values_gnb2_cell2}
    ...    att_connection_port=${att_port_1_gnb2_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell2_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell3}    values=${values_gnb2_cell3}
    ...    att_connection_port=${att_port_1_gnb2_cell3_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell3_${tl}}