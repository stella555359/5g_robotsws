*** Settings ***
Documentation      Author: jia-rebecca.liu@nokia-sbell.com
...                squad group: SG_03
...                feature : CB009936


Suite Setup       Run Keywords
...               robot_common_operations.Common Suite Setup    AND
...               Common Suite Setup for 9936

Suite Teardown          Run Keywords
...               robot_common_operations.Common Suite Teardown    AND
...               Common Suite Teardown for COAM

Resource         testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009936/Resources/CB009936_Case_Step.robot


*** Variables ***
${dl_tput_5m}                            5M
${dl_tput_dingli_UE0_11006}                    1200M
${dl_tput_dingli_UE0_11006_A2001}              1200M
#${dl_expect_tput_type1_11006}                  1000
#${dl_expect_tput_type2_11006}                  1000
${dl_expect_tput_8830_11006}                   1000
${dl_expect_tput_A2011_11006}                  800
${dl_expect_tput_type1_11006}                  800
${dl_expect_tput_type2_11006}                  800

${dl_tput_dingli_UE0_10175}                    2000M
${dl_tput_dingli_UE0_10175_A2001}              900M
${dl_expect_tput_type1_10175}                  1000
${dl_expect_tput_type2_10175}                  1000
${dl_expect_tput_8830_10175}                   900
${dl_expect_tput_A2011_10175}                  500
${B_12_wireshark_attach}                 B_12_wireshark_attach.pcap
${MTK_DL_traffic}                        250M
${MTK_UL_traffic}                        100M
${dingli_dl_traffic}                        250M
${dingli_ul_traffic}                        100M
${8830_A1001_wireshark_attach_type2}           8830_A1001_wireshark_attach_type2.pcap
${8830_A1001_wireshark_attach_type1}           8830_A1001_wireshark_attach_type1.pcap
${8830_A2011_wireshark_attach_type1}           8830_A2011_wireshark_attach_type1.pcap
${8830_A2011_wireshark_attach_type2}           8830_A2011_wireshark_attach_type2.pcap
${8830_A2011_wireshark_attach_type2_mcs}           8830_A2011_wireshark_attach_type2_mcs.pcap
${8830_C1001_wireshark_attach}                 8830_C1001_wireshark_attach.pcap
${8830_C1001_wireshark_tput_01}                8830_C1001_wireshark_tput_01.pcap
${8830_C1001_wireshark_vonr}                   8830_C1001_wireshark_vonr.pcap
${8830_C1001_wireshark_hangup}                 8830_C1001_wireshark_hangup.pcap
${8830_C1001_wireshark_recovery}               8830_C1001_wireshark_recovery.pcap
#@{9936_workround_alarmlist}                    4681    4282

${Test_PC_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${Test_PC_username}             ${tl.test_pc.default_ssh_connection_details.username}
${Test_PC_password}             ${tl.test_pc.default_ssh_connection_details.password}

*** Test Cases ***
[1]CB009936_CB008158-B_12_GTP_packet_delay_over_F1-U_for_PMQAP_FR1_TDD_SA
    [Documentation]
    ...    cover CB009936_CB008158-D_22; CB009936_CB008830-SR-A1_001
    ...    dingli_UE
    [Tags]    8158
    [Setup]
    robot_common_operations.Common Case Setup
    Dingli_UE prepare
    MCS SETUP AND SET ATT for dingli_UE    gnb_cell1_PA_value_dingli_UE0=${25}
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
#    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
#    ...      Test_PC_password=${Test_PC_password}
#    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
#    ...      btslog_launcher_path=/opt/btslog/btslog
#    ###### CB009936_CB008830_A1001 ######
    Common Case TestLine Setup      ModifySCF_Aftercommission=True
    ...                             Modify_Para_Online=${Online_Modify_8830_A1001_${gnb_instance}}
#    ${CB008830_A1001_type2_attach}    ${type2_tput_value}    ${8830_A1001_BIP_1}
#    ...    attach_capture_wireshark_bip_and_return_tupt      wiresharklog=${8830_A1001_wireshark_attach_type2}
#    ...                                                      dl_throughput=${dl_tput_dingli_UE0_${gnb_instance}}
#    ...                                                      biplog_file_name=8830_A1001_bip_type2_1
#    ...                                                      dl_expect_tput=${dl_expect_tput_type2_${gnb_instance}}
#    Common Case TestLine Setup      ModifySCF_Aftercommission=True
#    ...                             Modify_Para_Online=${Online_Modify_8830_A1001_type1_${gnb_instance}}
#    Collect Interface Mirroring Bip Collector from WEBUI     target_dir=${epc_log_path}    times=5s
#    ...                                                      target_file_name=8830_A1001_bip_type2_2
#    Check one UE traffic with pioneer client    tput_target=${dl_expect_tput_8830_${gnb_instance}}
#    ${8830_A1001_BIP_2}    Get Bip Log Via Interface Mirroring Collector to UTE    target_dir=${epc_log_path}
#    ...                                                                            target_file_name=8830_A1001_bip_type2_2
#    Stop traffic with appserver     dl_port=${DL_PORT_dingli}
#    Detach dingli_UE0 with poweroff
#    check dmrs_supported from wireshark    file_path=${CB008830_A1001_type2_attach}
#    check dldmrsconfigtype from biplog     file_path=${8830_A1001_BIP_1}
#    check dldmrsconfigtype from biplog     file_path=${8830_A1001_BIP_2}[0]
#    ${CB008830_A1001_type1_attach}    ${type1_tput_value}    ${8830_A1001_BIP_3}
#    ...    attach_capture_wireshark_bip_and_return_tupt      wiresharklog=${8830_A1001_wireshark_attach_type1}
#    ...                                                      dl_throughput=${dl_tput_dingli_UE0_${gnb_instance}}
#    ...                                                      biplog_file_name=8830_A1001_bip_type1
#    ...                                                      dl_expect_tput=${dl_expect_tput_type1_${gnb_instance}}
#    Stop traffic with appserver     dl_port=${DL_PORT_dingli}
#    Detach dingli_UE0 with poweroff
#    should be true     ${type2_tput_value}[0][average] > ${type1_tput_value}[0][average]
#    check dldmrsconfigtype from biplog     file_path=${8830_A1001_BIP_3}    dmrs_config_value=DMRS_CONFIG_1
    ###### CB009936_CB008830_A2011 ######
    Common Case TestLine Setup      ModifySCF_Aftercommission=True
    ...                             Modify_Para_Online=${Online_Modify_8830_A2011_${gnb_instance}}
    MCS set ATT only with MCS_type
    ${CB008830_A2011_type1_attach}    ${type1_tput_value_01}    ${8830_A2011_BIP_1}
    ...    attach_capture_wireshark_bip_and_return_tupt      wiresharklog=${8830_A2011_wireshark_attach_type1}
    ...                                                      dl_throughput=${dl_tput_dingli_UE0_${gnb_instance}_A2001}
    ...                                                      biplog_file_name=8830_A2011_bip_type1_1
    ...                                                      dl_expect_tput=${dl_expect_tput_A2011_${gnb_instance}}
    Stop traffic with appserver     dl_port=${DL_PORT_dingli}
    Detach dingli_UE0 with poweroff
    Common Case TestLine Setup      ModifySCF_Aftercommission=True
    ...                             Modify_Para_Online=${Online_Modify_8830_A2011_type2_${gnb_instance}}
    ${CB008830_A2011_type2_attach}    ${type2_tput_value_02}    ${8830_A2011_BIP_2}
    ...    attach_capture_wireshark_bip_and_return_tupt      wiresharklog=${8830_A2011_wireshark_attach_type2}
    ...                                                      dl_throughput=${dl_tput_dingli_UE0_${gnb_instance}_A2001}
    ...                                                      biplog_file_name=8830_A2011_bip_type2_1
    ...                                                      dl_expect_tput=${dl_expect_tput_A2011_${gnb_instance}}
    Stop traffic with appserver     dl_port=${DL_PORT_dingli}
    Detach dingli_UE0 with poweroff
    Common Case TestLine Setup      ModifySCF_Aftercommission=True
    ...                             Modify_Para_Online=${Online_Modify_8830_A2011_type2_mcs_${gnb_instance}}
    ${CB008830_A2011_type2_mcs_attach}    ${type2_tput_value_03}    ${8830_A2011_BIP_3}
    ...    attach_capture_wireshark_bip_and_return_tupt      wiresharklog=${8830_A2011_wireshark_attach_type2_mcs}
    ...                                                      dl_throughput=${dl_tput_dingli_UE0_${gnb_instance}_A2001}
    ...                                                      biplog_file_name=8830_A2011_bip_type2_2
    ...                                                      dl_expect_tput=${dl_expect_tput_A2011_${gnb_instance}}
    Stop traffic with appserver     dl_port=${DL_PORT_dingli}
    Detach dingli_UE0 with poweroff
    should be true    ${type2_tput_value_02}[0][average] > ${type1_tput_value_01}[0][average]
    should be true    ${type2_tput_value_02}[0][average] > ${type2_tput_value_03}[0][average]
    Compare DL Tput1 and DL Tput3    DL_Tput1=${type2_tput_value_02}[0][average]    DL_Tput3=${type2_tput_value_03}[0][average]

    check dmrs_supported from wireshark    file_path=${CB008830_A2011_type2_attach}
    check dldmrsconfigtype from biplog     file_path=${8830_A2011_BIP_2}
    check dldmrsconfigtype from biplog     file_path=${8830_A2011_BIP_3}
    check dldmrsconfigtype from biplog     file_path=${8830_A2011_BIP_1}    dmrs_config_value=DMRS_CONFIG_1
    #### CB009936_CB008158-B_12 ######
#    MCS set ATT only with MCS_type    att_value_hbte=${25}    att_value_hj=${15}
#    Common Case TestLine Setup      ModifySCF_Aftercommission=True
#    ...                             Modify_Para_Online=${Online_Modify_8158_B12_${gnb_instance}}
#    ${CB009936_B_12_attach}    ${upd_info}    UE attach and capture wiresharklog    wiresharklog=${B_12_wireshark_attach}
#    Start MUE dltraffic with appserver      ue_addr=${upd_info}[Param][IP]     dl_port=${DL_PORT_dingli}    dl_throughput=${dl_tput_5m}
#    start dingli_UE Voice_Call    ue=${uegroup}[0]    call_number=6688    longcall=${True}
#    ${time_start_B12}=    Get current date    result_format=%Y%m%d%H%M%S    time_zone=UTC
#    builtin.sleep    6min
#    ${time_end_B12}=    Get current date    result_format=%Y%m%d%H%M%S    time_zone=UTC
#    run keyword and continue on failure     Check_Counter_For_B12
#    [Teardown]     CB009936_case_teardown
    [Teardown]    Run Keywords
    ...    CB009936_case_teardown
    ...    AND     Common Case TestLine Setup      ModifySCF_Aftercommission=True
    ...                                            Modify_Para_Online=${Online_Recovery_8830_A1001_${gnb_instance}}


[1]CB009936_CB009550-B_32_counter_CBRA_RACH_setup_Time_TDD_SA_1070_4SSB
    [Documentation]
    ...    cover CB009936_CB008158-D_22
    [Tags]    9550
    [Setup]
    robot_common_operations.Common Case Setup
    Common Case TestLine Setup      ModifySCF_Aftercommission=True
    ...                             Modify_Para_Online=${Online_Modify_B32_true}
    run keyword if    '${gnb_instance}' == '11006'    MCS SETUP AND SET ATT for MTK80
    MCS SETUP AND SET ATT for dingli_UE    gnb_cell1_PA_value_dingli_UE0=${5}      gnb_cell1_PA_value_dingli_UE1=${5}
    Prepare pioneer_MultiUE
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
#    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
#    ...      Test_PC_password=${Test_PC_password}
#    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
#    ...      btslog_launcher_path=/opt/btslog/btslog
    Prepare to caculate PM counter     period=start
    attach_detach_multiues_around
    ${counter_true}    check counter for CB009936_CB009550
    Common Case TestLine Setup      ModifySCF_Aftercommission=True
    ...                             Modify_Para_Online=${Online_Modify_B32_false}
    attach_detach_multiues_around
    ${counter_false}    check counter for CB009936_CB009550
    should be true     ${counter_true} < ${counter_false}
    [Teardown]    CB009936_case_teardown

[1]CB009936_CB008830_SR_C1_001_Dynamic_switch_between_type_1_and_type_2_due_to_VONR_SA_64TRX_ET
    [Documentation]
    ...    ET case, MTK80
    [Tags]    CB008830_SR_C1_001
    [Setup]
    robot_common_operations.Common Case Setup
    Common Case TestLine Setup      ModifySCF_Aftercommission=True
    ...                             Modify_Para_Online=${Online_Modify_8830_C1001_type2}
    MCS SETUP AND SET ATT for dingli_UE
    Adjust the HBTE attenuation value for MTK80
    MCS SETUP AND SET ATT for MTK80    gnb_cell1_PA_value_MTK80=${10}
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
#    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
#    ...      Test_PC_password=${Test_PC_password}
#    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
#    ...      btslog_launcher_path=/opt/btslog/btslog
    Prepare UE For MTK80
#    Prepare pioneer_MultiUE
    ${CB008830_C1001_attach}    ${DL_tput_1}    ${UL_tput_1}    ${CB008830_C1001_tput_01}
#    ...    MultiUE0_attach_and_capture_wireshark_start_uldl_traffic    wiresharklog1=${8830_C1001_wireshark_attach}
#    ...                                                                wiresharklog2=${8830_C1001_wireshark_tput_01}
#    ...                                                                dingli_dl_traffic=${dingli_dl_traffic}
#    ...                                                                dingli_ul_traffic=${dingli_ul_traffic}
    ...    MTK_attach_and_capture_wireshark_start_uldl_traffic    wiresharklog1=${8830_C1001_wireshark_attach}
    ...                                                           wiresharklog2=${8830_C1001_wireshark_tput_01}
    ...                                                           MTK_DL_traffic=${MTK_DL_traffic}
    ...                                                           MTK_UL_traffic=${MTK_UL_traffic}
#    ${CB008830_C1001_vonr}    ${DL_tput_2}    ${UL_tput_2}    dingliUE_start_vonr_and_capture_wireshark    wiresharklog3=${8830_C1001_wireshark_vonr}
    ${CB008830_C1001_vonr}    ${DL_tput_2}    ${UL_tput_2}     MTK_start_VC_and_capture_wireshark    wiresharklog3=${8830_C1001_wireshark_vonr}
    ${CB008830_C1001_hangup}     ${DL_tput_3}    ${UL_tput_3}
    ...         MTK_hangup_VC_and_capture_wireshark    wiresharklog4=${8830_C1001_wireshark_hangup}
#    ...        dingliUE_hangup_vonr_and_capture_wireshark    wiresharklog4=${8830_C1001_wireshark_hangup}
    Stop DLUL traffic and detech for MTK80
    run keyword and continue on failure     Should Be True    ${DL_tput_1} > ${DL_tput_2} and ${DL_tput_3} > ${DL_tput_2}
    run keyword and continue on failure     check_point_CB008830_C1001    wiresharklog_01=${CB008830_C1001_attach}
    ...                                                                   wiresharklog_03=${CB008830_C1001_vonr}
    ...                                                                   wiresharklog_04=${CB008830_C1001_hangup}
#    [Teardown]    CB009936_case_teardown
    [Teardown]    CB009936_case_teardown_mtk




*** Keywords ***
Check_Counter_For_B12
    ${KPI_DIC}    Get_KPI_value_by_list
    ${KPI_LIST}    Collections.Get Dictionary Values    ${KPI_DIC}
    ${check_result}=     BuiltIn.evaluate    all(x > 0 for x in ${KPI_LIST})
    should be true    ${check_result}
    [Teardown]    run keywords    stop dingli_UE Voice_Call    ue=${uegroup}[0]
    ...    AND    Stop traffic with appserver     dl_port=${DL_PORT_dingli}
    ...    AND    Detach dingli_UE0 with poweroff

check counter for CB009936_CB009550
    [Arguments]     ${counter_id}=${CB009936_B32_counter_id}     ${dic_path}=${CB009936_B32_counter_path}
    sleep     1min
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${0}
    [Return]    ${counter_value}[0]

Compare DL Tput1 and DL Tput3
    [Arguments]     ${DL_Tput1}   ${DL_Tput3}
    ${difference}=    Evaluate    abs(${DL_Tput1} - ${DL_Tput3})
    ${average}=    Evaluate    (${DL_Tput1} + ${DL_Tput3}) / 2
    ${percentage_difference}=    Evaluate    (${difference} / ${average}) * 100
    Should Be True    ${percentage_difference} <= 5

CB009936_case_teardown
    CI_interface.Common Case Teardown
    run keyword and ignore error    client.stoplog      service=pioneer
    run keyword and ignore error    Stop traffic with appserver     dl_port=${DL_PORT_dingli}
    run keyword and ignore error    Detach dingli_UE0 with poweroff
    run keyword and ignore error    MCS SETUP AND SET ATT for dingli_UE
#    Run Keyword And Ignore error    Stop BTSlogs Collection And Download Logs To Log Server
#    run keyword and continue on failure     Check ERR Or WRN From Syslog    sys_logs_path=${UTE_syslogs_path}
    run keyword and ignore error    Common Case Teardown for COAM

CB009936_case_teardown_mtk
    CI_interface.Common Case Teardown
    run keyword and ignore error    Stop DLUL traffic and detech for MTK80
    run keyword and ignore error    MCS Teardown with mcs_type    mcs_type=${mcs_type}
#    Run Keyword And Ignore error    Stop BTSlogs Collection And Download Logs To Log Server
#    run keyword and continue on failure     Check ERR Or WRN From Syslog    sys_logs_path=${UTE_syslogs_path}
    run keyword and ignore error    Common Case Teardown for COAM