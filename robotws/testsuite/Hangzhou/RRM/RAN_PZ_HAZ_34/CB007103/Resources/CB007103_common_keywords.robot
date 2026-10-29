*** Settings ***
Documentation    This is for feature CB007103 related common keywords.
...              Please do not modify the file without notification to author
...              Author: jia-rebecca.liu@nokia-sbell.com
...              Squard: VRFT03

Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/MTK_common_keywords.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Common_keywords.robot
#Resource         testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/AIC_UE.robot
Variables        ../TestData/CB007103_variables.py
Library          taf.analyzer.pcap   WITH NAME    cap
Library          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007103/Resources/CB007103_counter_caculate.py
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/72e_switch.robot



*** Variables ***
####----PATH----####
${TS_LOG_PATH_BASE}               /opt/workspace/CRT/Master/Case_Logs/
${7103_swconfig_file}             /opt/workspace/SCF/swconfig.txt
####----BTS----####
${CB007103_SCF_11006_SBTS25R2_ENB_9999}      MRBTS-11006_TL374_golden_SCF_trunk_CA.xml
${CB007103_SCF_11006_SBTS24R3_ENB_0000}      MRBTS-11006_TL374_golden_SCF_24R3_CA.xml
${CB007103_SCF_11006_SBTS25R1_ENB_0000}      MRBTS-11006_TL374_golden_SCF_25R1_CA.xml
${gnb_instance}                   ${tl.gnbs[0].instance_id}
####----UE----####
${appserver_addr_mtk80}           ${tl.ues[8].iperf_details.ssh_connection_details.addr}
####----PA----####
${model}                          ${tl.attenuator[1].model}
${att_ipaddr_11006}               ${tl.attenuator[1].ip_addr}

${att_port_1_cell3_11006}         ${tl.attenuator[1].attenuator_ports[1]}
${att_port_2_cell3_11006}         ${tl.attenuator[1].attenuator_ports[2]}
${att_port_3_cell3_11006}         ${tl.attenuator[1].attenuator_ports[3]}
${att_port_4_cell3_11006}         ${tl.attenuator[1].attenuator_ports[4]}
${att_port_1_cell2_11006}         ${tl.attenuator[1].attenuator_ports[5]}
${att_port_2_cell2_11006}         ${tl.attenuator[1].attenuator_ports[6]}
${att_port_enb_cell1_11006}       ${tl.attenuator[1].attenuator_ports[7]}
${tshark_path}                    /usr/bin/tshark

@{alarm_whitelist}     4655    4654    61652    61524    4592    7311    7300    61649

*** Keywords ***
7103 Suite Setup
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]
    ...            ${ModifySCF_Beforecommission}=False
    ...            ${ParamterToModify}='NULL'
    ...            ${ListParamterToModify}='NULL'
    ...            ${ParameterToDelete}='NULL'
    ...            ${ListToAdd}='NULL'
    ...            ${swconfig_modify}=${Enable_RD_Flag}
    ...            ${pooling_switch}=disable
    ...            ${gnb_index}=${0}
    ...            ${swconfig_target_path}=${epc_log_path}/swconfig.txt
    ...            ${Is_Swconfig}=True
    ...            ${swconfig_file}=${7103_swconfig_file}
    Common Suite Setup for COAM
    Get sagnb release
    ${gnb_release}     Get gnb_release title for SCF
    run keyword if    '${gnb_release}' == 'SBTS25R2_ENB_9999'
    ...    disable 72e_pooling for trunk      swconfig_modify=${swconfig_modify}
    ...                                       ParamterToModify=${ParamterToModify}
    ...                                       ListParamterToModify=${ListParamterToModify}
    ...                                       ParameterToDelete=${ParameterToDelete}
    ...                                       ListToAdd=${ListToAdd}
    ...                                       pooling_switch=${pooling_switch}
    ...                                       gnb_index=${gnb_index}
    ...                                       swconfig_target_path=${swconfig_target_path}
    ...    ELSE    Common Case TestLine Setup    ModifySCF_Beforecommission=${ModifySCF_Beforecommission}
    ...                           golden_scf_name=MRBTS-${gnb_instance}_${gnb_release}.xml
    ...                           ParamterToModify=${ParamterToModify}
    ...                           ListParamterToModify=${ListParamterToModify}
    ...                           ParameterToDelete=${ParameterToDelete}
    ...                           Is_Swconfig=${Is_Swconfig}
    ...                           swconfig_file=${swconfig_file}

7103 Suite TearDown
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]
    Common Suite Teardown for COAM

7103 Case SetUp
    [Documentation]   Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${ue_index}=${8}
    ...            ${ModifySCF_Beforecommission}=False
    ...            ${ParamterToModify}='NULL'
    ...            ${ListParamterToModify}='NULL'
    ...            ${ParameterToDelete}='NULL'
    ...            ${ListToAdd}='NULL'
    ...            ${ModifySCF_Aftercommission}=False
    ...            ${Modify_Para_Online}='NULL'
    ...            ${gnb_cell2_value}=${127}
    ...            ${gnb_cell3_value}=${25}
    ...            ${enb_cell1_value}=${127}
    ...            ${ATT_HB}=${90}
    ...            ${cellid}=${3}
    ...            ${Test_PC_IP}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${Test_PC_username}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${Test_PC_password}=${tl.test_pc.default_ssh_connection_details.password}
    robot_common_operations.Common Case Setup
    MCS SETUP AND SET ATT for MTK80    ATT_HB=${ATT_HB}
    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}
    Adjust the HBTE attenuation value for MTK80     gnb_cell2_value=${gnb_cell2_value}
    ...                                             gnb_cell3_value=${gnb_cell3_value}
    ...                                             enb_cell1_value=${enb_cell1_value}
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    Common Case TestLine Setup    ModifySCF_Beforecommission=${ModifySCF_Beforecommission}
    ...                           golden_scf_name=MRBTS-${gnb_instance}_${gnb_release}_CA.xml
    ...                           ParamterToModify=${ParamterToModify}
    ...                           ListParamterToModify=${ListParamterToModify}
    ...                           ParameterToDelete=${ParameterToDelete}
    ...                           ListToAdd=${ListToAdd}
    ...                           ModifySCF_Aftercommission=${ModifySCF_Aftercommission}
    ...                           Modify_Para_Online=${Modify_Para_Online}
    NRCellid Set suit varaible    cellid=${cellid}
    CB007103_common_keywords.Prepare UE For MTK80      ue_index=${ue_index}


7103 Case TearDown
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${gnb_list}=${gnb_list}    ${log_path}=${epc_log_path}
    robot_common_operations.Common Case Teardown
    run keyword and ignore error    Stop DL and UL traffic for MTK80
    run keyword and ignore error    Detach MTK80
    run keyword and ignore error    MCS SETUP AND SET ATT for MTK80    ATT_HB=${90}
    Run Keyword And Ignore Error    Adjust the HBTE attenuation value for MTK80
    Run keyword And Ignore Error    COAM Save all gnb snapshot via api    gnb_list=${gnb_list}    log_path=${log_path}
    Run keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}
    Run Keyword And Ignore error    Stop BTSlogs Collection And Download Logs To Log Server
    run keyword and continue on failure     Check ERR Or WRN From Syslog    sys_logs_path=${UTE_syslogs_path}
    Run keyword and ignore error    Teardown the all connections
    Run keyword and ignore error    CI_interface.Common Case Teardown


Get gnb_release title for SCF
    [Documentation]    the keyword return realse format : SBTS24R3_ENB_9999
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${gnb_release}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    set suite variable    ${gnb_release}
    [Return]    ${gnb_release}
    [Teardown]   csn.Disconnect   connection=release_info


change_parameter_online
    [Arguments]    ${Modify_Para_Online}='NULL'
    ...            ${Delete_Mo_Online}='NULL'
    ...            ${Delete_Para_Online}='NULL'
    ...            ${Add_Para_Online}='NULL'
    ...            ${Add_Mo_Online}='NULL'
    ...            ${alarm_check}=True
    ...            ${ALLOWED_FAULT}=${alarm_whitelist}
    ${online_status}    run keyword and return status
    ...                    Common Case TestLine Setup               ModifySCF_Aftercommission=True
    ...                                                             Modify_Para_Online=${Modify_Para_Online}
    ...                                                             Delete_Mo_Online=${Delete_Mo_Online}
    ...                                                             Delete_Para_Online=${Delete_Para_Online}
    ...                                                             Add_Para_Online=${Add_Para_Online}
    ...                                                             Add_Mo_Online=${Add_Mo_Online}
    ...                                                             alarm_check=${alarm_check}
    ...                                                             ALLOWED_FAULT=${ALLOWED_FAULT}
    [Teardown]     run keyword if    '${online_status}' == 'False'    COAM Save all gnb snapshot via api

disable 72e_pooling for trunk
    [Arguments]
    ...            ${swconfig_modify}='NULL'
    ...            ${ParamterToModify}='NULL'
    ...            ${ListParamterToModify}='NULL'
    ...            ${ParameterToDelete}='NULL'
    ...            ${ListToAdd}='NULL'
    ...            ${pooling_switch}=disable
    ...            ${gnb_index}=${0}
    ...            ${swconfig_target_path}=${epc_log_path}/swconfig.txt
    ${7103_common_SCF}    Only Modify SCF before Perform Commission    golden_scf_name=MRBTS-${gnb_instance}_${gnb_release}_CA.xml
    ...                                                                ParamterToModify=${ParamterToModify}
    ...                                                                ListParamterToModify=${ListParamterToModify}
    ...                                                                ParameterToDelete=${ParameterToDelete}
    ...                                                                ListToAdd=${ListToAdd}
    Act Ecpri_RRU Mode Switch      scf_path=${7103_common_SCF}    swconfig_modify=${swconfig_modify}
    ...                            pooling_switch=${pooling_switch}
    ...                            gnb_index=${gnb_index}    swconfig_target_path=${swconfig_target_path}

#########-----------------MTK80-----------------#########
Prepare UE For MTK80
    [Documentation]   jia-rebecca.liu@nokia-sbell.com
    ...               Description: Precondtion for mtk ue
    [Arguments]    ${ue_index}=${8}    ${cap_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    ${mtk_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    set suite variable    ${mtk_type}
    CB007103_common_keywords.Get UE Airmode status and Turnoff Airplane Mode    ue_index=${ue_index}
    CB007103_common_keywords.Enable Mobile Data    ue_index=${ue_index}
    ${mtk_prepare}      run keyword and return status     Wait Until Keyword Succeeds    3 times    5 sec
    ...                 Precondition for MTK ue attach    ue_index=${ue_index}    cap_index=${cap_index}
    ...                 cpc_alias=${cpc_alias}
    Run Keyword If    ${mtk_prepare}==${False}    UE Reboot with adb command    ue_index=${ue_index}
    sleep    60s
    ${mtk_prepare_1}    Run Keyword If    ${mtk_prepare}==${False}       run keyword and return status
    ...                 Wait Until Keyword Succeeds    3 times    5 sec
    ...                 Precondition for MTK ue attach    ue_index=${ue_index}    cap_index=${cap_index}
    ...                 cpc_alias=${cpc_alias}
    Run Keyword If    ${mtk_prepare_1}==${False}      Reset UE Control PC    ue_index=${ue_index}
    sleep    60s
    Run Keyword If    ${mtk_prepare_1}==${False}    Wait Until Keyword Succeeds    3 times    5 sec
    ...               Precondition for MTK ue attach     ue_index=${ue_index}    cap_index=${cap_index}
    ...               cpc_alias=${cpc_alias}

MTK80 Attach and Verify
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: Attach MTK80 and verify
    [Arguments]        ${ue_index}=${8}
    ...                ${UE_alias}=UE_${ue_index}
    ute_ue.Register    ${UE_alias}
#    power_ue.Verify attach    ue_type=${mtk_type}    ue_index=${ue_index}    4G_check=${4G_check}

Attach UE and Capture wireshark for MTK80
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: Attach UE and capture wireshark for MTK80
    [Arguments]    ${wiresharklog}    ${ue_index}=${8}
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog}
    MTK80 Attach and Verify    ue_index=${ue_index}
    sleep    5s
    [Teardown]    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog}    target_dir=${epc_log_path}
    [Return]      ${cpif_log_path}

Start DL traffic for MTK80
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: Start DL traffic
    [Arguments]    ${get_ip_from_cpif}
    ...            ${dl_data_transfer}=5M
    ...            ${duration}=6000
    ...            ${ue_index}=${8}
    ...            ${buffer_size}=1400B
    ...            ${appserver}=APPserver
    ...            ${protocol}=udp
    ${pdu_ip_dnn_dict}     Common_keywords.Get ALL PDU IP Address From Wireshark     cpif_log_path=${get_ip_from_cpif}
    ${ue_dl_port}    Set Variable    ${tl.ues[${ue_index}].iperf_details.port}
    Set Test Variable    ${DL_PORT}    ${ue_dl_port}
    traffic_via_iperf.Start DL traffic via iperf on Appserver    ue_addr=${pdu_ip_dnn_dict}[data]
    ...                                                          dl_time=${duration}
    ...                                                          dl_port=${DL_PORT}
    ...                                                          dl_throughput=${dl_data_transfer}
    ...                                                          dl_length=${buffer_size}
    ...                                                          appserver=${appserver}
    ...                                                          protocol=${protocol}
    ...                                                          ue_index=${ue_index}

Start DL traffic first and Capture Biplog for MTK80
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: Start DL traffic and capture Biplog for MTK80
    [Arguments]    ${get_ip_from_cpif}
    ...            ${Capture_bip_time}=2S
    ...            ${target_dir}=${epc_log_path}
    ...            ${dl_data_transfer}=5M
    ...            ${duration}=6000
    ...            ${ue_index}=${8}
    ...            ${target_file_name}=l1l2bip
    Start DL traffic for MTK80      get_ip_from_cpif=${get_ip_from_cpif}
    ...                             dl_data_transfer=${dl_data_transfer}
    ...                             duration=${duration}
    ...                             ue_index=${ue_index}
    ${biplog_path}    Collect Biplog on WEBUI for MTK80     target_dir=${target_dir}
    ...                                                     target_file_name=${target_file_name}
    ...                                                     Capture_bip_time=${Capture_bip_time}
    [Return]    ${biplog_path}

Stop DL traffic only
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: only stop DL traffic for MTK80, keep attach status
    [Arguments]      ${ue_index}=${8}
    ${ue_dl_port}    Set Variable    ${tl.ues[${ue_index}].iperf_details.port}
    Set Test Variable    ${DL_PORT}    ${ue_dl_port}
    Close the iperf process on APPserver    port=${DL_PORT}

Start UL traffic via iperf for MTK80
    [Arguments]    ${ue_index}=${8}
    ...    ${ul_time}=6000
    ...    ${ul_throughput}=2M
    ...    ${ul_length}=1400B
    ...    ${appserver}=APPserver
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${protocol}=udp     ${process_num}=${5}    ${iperf_index}=${2}
    ...    ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    ${window}=2M
    ...    ${iperf_path}=/data/local/tmp/iperf
    ...    ${appserver_addr}=${appserver_addr_mtk80}
    ${ue_ul_port}    Set Variable    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    Set Test Variable    ${UL_PORT}    ${ue_ul_port}
    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${UL_PORT}    serial_number=${serial_number}
    ...                                      iperf_index=${iperf_index}
    ...                                      cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    ${cmd_ul_traffic}=    run keyword if    '${appserver}'=='APPserver'       catenate    adb -s ${serial_number} shell
    ...     ${iperf_path} -c ${appserver_addr} -u -t ${ul_time} -i 1 -p ${UL_PORT} -P 1 -f m -b ${ul_throughput} -l ${ul_length} -T 64 &
    ...    ELSE IF    '${appserver}'=='APPserversim'     catenate    adb -s ${serial_number} shell
    ...  ${iperf_path} -c ${appserversim_addr} -u -t ${ul_time} -i 1 -p ${UL_PORT} -P ${process_num} -f m -b ${ul_throughput} -l ${ul_length} -T 64 &
    run keyword if    '${protocol}'=='udp'    csn.send_command    command=${cmd_ul_traffic}    connection=cpc_${ue_index}
    ...    ELSE IF    '${protocol}'=='tcp'    Start the tcp UL data via iperf    appserver=${appserver}
    ...    serial_number=${serial_number}    ul_time=${ul_time}    ul_port=${UL_PORT}    ue_index=${ue_index}
    ...    process_num=${process_num}    window=${window}
    sleep    3s
    Check the iperf progress exist    connection=cpc_${ue_index}    port=${UL_PORT}    ue_sn=${serial_number}   iperf_index=${iperf_index}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Check tput for MTK80
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: Check dl traffic for MTK80
    [Arguments]
    ...             ${cellid}=${nrcellid}
    ...             ${duration}=180
    ...             ${direction}=UL
    ...             ${target_throughput}=0.05

    ${list_of_cell_ids}    Create list    ${cellid}
    ${tput_file}    power_ue.Collect Tput    ue_type=${mtk_type}     duration=${duration}
    ${output}    power_ue.Check Tput    ue_type=${mtk_type}    direction=${direction}    cells=${list_of_cell_ids}
    ...                                 target_throughput=${target_throughput}    log=${tput_file}
    Set Test Variable     ${tput_avrage}     ${output}[0][average]
    [Return]    ${tput_avrage}

Start DL and UL traffic for MTK80
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: Start DL and UL traffic for MTK80
    [Arguments]        ${get_ip_from_cpif}
    ...                ${dl_data_transfer}=5M
    ...                ${duration}=6000
    ...                ${ue_index}=${8}
    ...                ${ul_throughput}=2M
    ...                ${iperf_path}=/data/local/tmp/iperf
    ...                ${appserver_addr}=${appserver_addr_mtk80}
    Start DL traffic for MTK80       get_ip_from_cpif=${get_ip_from_cpif}
    ...                              dl_data_transfer=${dl_data_transfer}
    ...                              duration=${duration}
    ...                              ue_index=${ue_index}
    Start UL traffic via iperf for MTK80    ue_index=${ue_index}
    ...                                     ul_time=${duration}
    ...                                     ul_throughput=${ul_throughput}
    ...                                     iperf_path=${iperf_path}
    ...                                     appserver_addr=${appserver_addr}

Check 3CC tput for MTK80 with CA mode
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: Check dl traffic for MTK80
    [Arguments]
    ...             ${pcellid}=${3}
    ...             ${scellid_1}=${1}
    ...             ${scellid_2}=${2}
    ...             ${duration}=30
    ...             ${direction}=DL
    ...             ${target_throughput}=1
    ${nrcellid_pcell}      COAM Get nrcellid with lcrid    lcrid=${pcellid}
    ${nrcellid_scell_1}    COAM Get nrcellid with lcrid    lcrid=${scellid_1}
    ${nrcellid_scell_2}    COAM Get nrcellid with lcrid    lcrid=${scellid_2}
    ${list_of_cell_ids}    Create list    ${nrcellid_pcell}     ${nrcellid_scell_1}     ${nrcellid_scell_2}
    ${tput_file}    power_ue.Collect Tput    ue_type=${mtk_type}     duration=${duration}
    ${output}    power_ue.Check Tput    ue_type=${mtk_type}    direction=${direction}    cells=${list_of_cell_ids}
    ...                                 target_throughput=${target_throughput}    log=${tput_file}

    [Return]    ${output}

Check F+T_2CC tput for MTK80 with CA mode
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: Check dl traffic for MTK80
    [Arguments]
    ...             ${pcellid}=${2}
    ...             ${scellid_1}=${1}
    ...             ${duration}=30
    ...             ${direction}=UL
    ...             ${target_throughput}=1
    ${nrcellid_pcell}      COAM Get nrcellid with lcrid    lcrid=${pcellid}
    ${nrcellid_scell_1}    COAM Get nrcellid with lcrid    lcrid=${scellid_1}
    ${list_of_cell_ids}    Create list    ${nrcellid_pcell}     ${nrcellid_scell_1}
    ${tput_file}    power_ue.Collect Tput    ue_type=${mtk_type}     duration=${duration}
    ${output}    power_ue.Check Tput    ue_type=${mtk_type}    direction=${direction}    cells=${list_of_cell_ids}
    ...                                 target_throughput=${target_throughput}    log=${tput_file}
    [Return]    ${output}

Stop UL traffic only
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: only stop UL traffic for MTK80, keep attach status
    [Arguments]    ${ue_index}=${8}
    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${UL_PORT}

Stop DL and UL traffic for MTK80
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: stop DL and UL traffic for MTK80, keep attach status
    [Arguments]    ${ue_index}=${8}
    Stop DL traffic only     ue_index=${ue_index}
    Stop UL traffic only     ue_index=${ue_index}

Get UE Airmode status and Turnoff Airplane Mode
    [Documentation]  jia-rebecca.liu@nokia-sbell.com
    ...              Description: get ue airplane mode and turn off airplane mode for MTK UE
    [Arguments]    ${ue_index}=${8}
    Check UE device exist    ${ue_index}
    ${airplane_mode}    Get UE Airmode status    ue_index=${ue_index}
    run keyword if    '${airplane_mode}'=='1'    CB007103_common_keywords.Turn Off Airplane Mode    ue_index=${ue_index}
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Turn Off Airplane Mode
    [Documentation]  jia-rebecca.liu@nokia-sbell.com
    ...              Description: turn off airplane mode for MTK UE
    [Arguments]    ${ue_index}=${8}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.Send Command    adb -s ${serial_number} shell "su 0 settings put global airplane_mode_on 0"
    ...                 connection=cpc_${ue_index}
    ...                 timeout=5
    sleep    3s
    csn.send command    adb -s ${serial_number} shell "su 0 am broadcast -a android.intent.action.AIRPLANE_MODE"
    ...                 connection=cpc_${ue_index}
    ...                 timeout=5
    sleep    5s
    ${result} =    csn.read_output    connection=cpc_${ue_index}
    Should contain    ${result}    result=0
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Enable Mobile Data
    [Documentation]  jia-rebecca.liu@nokia-sbell.com
    ...              Description: enable mobile data for MTK UE
    [Arguments]    ${ue_index}=${8}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send_command   command=adb -s ${serial_number} shell svc data enable    connection=cpc_${ue_index}
    Sleep    1s
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Detach MTK80
    [Documentation]   jia-rebecca.liu@nokia-sbell.com
    ...               Description: detach MTK80
    [Arguments]    ${ue_index}=${8}    ${UE_alias}=UE_${ue_index}
    MTK_common_keywords.Ue detach    UE_alias=${UE_alias}

########-------------------MCS&&PA-----------------#########
MCS SETUP AND SET ATT for MTK80
    [Arguments]    ${ATT_HJ}=${90}    ${ATT_HB}=${90}
    ...     ${vertical}=${96}    ${horizontal_1}=${25}    ${horizontal_2}=${35}
    ${mcs_type}=    mcs_common.Get MCS Type
    set suite variable      ${mcs_type}
    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS SETUP AND SET ATT for ONE UE    mcs_type=${mcs_type}
    ...    att_value_1=${ATT_HJ}     att_value_2=${ATT_HJ}
    ...    P1_out=${13}    P2_out=${14}    vertical_1=${vertical}    horizontal_1=${horizontal_1}
    ...    P3_out=${15}    P4_out=${16}    vertical_2=${vertical}    horizontal_2=${horizontal_2}
    Run keyword if    '${mcs_type}'=='hbte'      HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
    ...    vertical_distance=${2.0}   horizontal_distance=${0.5}
    ...    att_value1=${ATT_HB}    att_value2=${ATT_HB}    vertical_angle=${vertical}
    ...    first_beam_begin_output_port=${9}     first_beam_end_output_port=${10}     first_beam_horizontal_angle=${horizontal_1}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}    second_beam_horizontal_angle=${horizontal_2}


MCS SET ATT for MTK80
    [Arguments]    ${att_value}
    ${mcs_type}=    mcs_common.Get MCS Type
    Run keyword if    '${mcs_type}'=='haojin'
    ...    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value}
    ...    begin_output_port=${13}    end_output_port=${16}
    Run keyword if    '${mcs_type}'=='hbte'
    ...    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value}
    ...    begin_output_port=${9}    end_output_port=${12}

HBTE MCS SET AND ATT for MTK80
    [Arguments]    ${att_value}
    ...    ${horizontal_angle_1}    ${horizontal_angle_2}
    ${mcs_type}=    mcs_common.Get MCS Type
    HBTE MCS change UE Phases     mcs_type=${mcs_type}
    ...    vertical_angle=${96}
    ...    first_beam_begin_output_port=${9}     first_beam_end_output_port=${10}     first_beam_horizontal_angle=${horizontal_angle_1}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}    second_beam_horizontal_angle=${horizontal_angle_2}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value}
    ...    begin_output_port=${9}    end_output_port=${12}

Adjust the HBTE attenuation value for MTK80
    [Arguments]     ${tl}=${gnb_instance}     ${gnb_cell2_value}=${127}    ${gnb_cell3_value}=${127}     ${enb_cell1_value}=${127}

    ####create cell list#####
    @{att_ports_gnb_cell2}    Create List    ${att_port_1_cell2_${tl}}     ${att_port_2_cell2_${tl}}
    @{att_ports_gnb_cell3}    Create List    ${att_port_1_cell3_${tl}}     ${att_port_2_cell3_${tl}}
    ...                                      ${att_port_3_cell3_${tl}}     ${att_port_4_cell3_${tl}}

    ####create cell list#####
    @{att_ports_enb_cell1}    Create List    ${att_port_enb_cell1_${tl}}

    ###create value list####
    @{values_gnb_cell2}    Create List    ${gnb_cell2_value}    ${gnb_cell2_value}
    @{values_gnb_cell3}    Create List    ${gnb_cell3_value}    ${gnb_cell3_value}    ${gnb_cell3_value}    ${gnb_cell3_value}

    ###create value list####
    @{values_enb_cell1}    Create List    ${enb_cell1_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb_cell2}    values=${values_gnb_cell2}
    ...    att_connection_port=${att_port_1_cell3_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb_cell3}    values=${values_gnb_cell3}
    ...    att_connection_port=${att_port_1_cell3_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
    Set the attenuation value    att_ports=${att_ports_enb_cell1}    values=${values_enb_cell1}
    ...    att_connection_port=${att_port_1_cell3_${tl}}    att_ipaddr=${att_ipaddr_${tl}}



########--------------------log collect----------------#########
Prepare counter time caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

Collect Biplog on WEBUI for MTK80
    [Documentation]  jia-rebecca.liu@nokia-sbell.com
    ...              Description: Collect biplog on webui for MTK UE
    [Arguments]     ${target_dir}    ${target_file_name}=l1l2bip_log     ${Capture_bip_time}=2s
    Collect Interface Mirroring Bip Collector from WEBUI     target_dir=${target_dir}    times=${Capture_bip_time}
    ...                                                      target_file_name=${target_file_name}
    sleep     15s
    ${biplog_path}    Get Bip Log Via Interface Mirroring Collector to UTE    target_dir=${target_dir}
    ...                                                                       target_file_name=${target_file_name}
    [Return]    ${biplog_path}[0]

###-----------------------counter----------------------------###
Get_KPI_value_from_pm_file
    [Arguments]    ${test_start}    ${test_end}
    ...            ${ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...            ${gnb_index}=${0}
    ...            ${cellindex}=${2}
    ...            ${kpi_file}=${CURDIR}/CB007103_KPI.txt
    ...            ${folder_name}=7103
    ${xml_folder_file_list}    get_pm_file_from_classical_by_time    ip=${ip}
    ...                                                              username=${username}
    ...                                                              password=${password}
    ...                                                              connection=gNB_${gnb_index}
    ...                                                              local_path=${epc_log_path}
    ...                                                              folder_name=${folder_name}
    ...                                                              test_start=${test_start}
    ...                                                              test_end=${test_end}
    ${counter_value_dict}    getsum_counter_by_pm_file
    ...     kpi_file=${kpi_file}    xml_folder_file_list=${xml_folder_file_list}    para_index=${cellindex}
    ${kpi_value_dict}    calculate_kpi_by_counter    counter_dic_by_name=${counter_value_dict}    kpi_file=${kpi_file}
    [Return]    ${kpi_value_dict}




#########---------------log check----------------#########
Convert cpif_pcap log To Pdml
    [Documentation]    Description: convert to cpif pcap to pdml format, pdml can be used for value check.
    [Arguments]    ${file_path}
    ...            ${filter}=nr-rrc
    ...            ${command_template}={tshark_path} -r {file_path} -Y \"${filter}\" -T pdml
    ...            ${alias}=parser
    cap.load_pcap_file    pcap_file=${file_path}    command_template=${command_template}    alias=${alias}

Get Field Value From Pdml_file
    [Documentation]    Description: get field value from pdml file.
    [Arguments]    ${filter_expression}    ${xpath}    ${attribute_name}=show    ${alias}=parser
    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=${alias}
    ${field_value}=    cap.get_field_value_by_xpath    xpath=${xpath}    attribute_name=${attribute_name}    pcap_parser=${alias}
    [Return]    ${field_value}

Check Target Item Value on cpif_Tcpdump log
    [Documentation]       Description:check target item value on CPIF tcpdump log.
    [Arguments]    ${file_path}
    ...            ${filter_expression}
    ...            ${xpath}
    ...            ${filter}=f1ap||nr-rrc||ngap
    ...            ${command_template}={tshark_path} -r {pcap_file} -Y \"${filter}\" -T pdml
    ...            ${attribute_name}=show
    Convert cpif_pcap log To Pdml    file_path=${file_path}
    ...                          filter=${filter}
    ...                          command_template=${command_template}
    ${filter_output}    Get Field Value From Pdml_file    filter_expression=${filter_expression}
    ...                                              xpath=${xpath}
    ...                                              attribute_name=${attribute_name}
    [Return]    ${filter_output}


Get PucchF3_maxcoderate From rrc_setup
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${xpath}    Set Variable
    ...     .//nr-rrc.format3/nr-rrc.setup_element/nr-rrc.maxCodeRate
    ${maxCodeRate_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter_expression=nr-rrc.rrcSetup_element
    ...            xpath=${xpath}
    ...            attribute_name=showname
    ${maxCodeRate}     String.Split String     ${maxCodeRate_pre}[0]    ${SPACE}
    [Return]    ${maxCodeRate}[1]

Get PucchF3_maxcoderate From rrc_reg
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${xpath}    Set Variable
    ...     .//nr-rrc.setup_element/nr-rrc.format3/nr-rrc.setup_element/nr-rrc.maxCodeRate
    ${maxCodeRate_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter_expression=nr-rrc.rrcReconfiguration_element
    ...            xpath=${xpath}
    ...            attribute_name=showname
    ${maxCodeRate}     String.Split String     ${maxCodeRate_pre}[0]    ${SPACE}
    [Return]    ${maxCodeRate}[1]

Get dmrs_Pucch_r16_IE From rrc_reg
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${xpath}    Set Variable
    ...     .//nr-rrc.pucch_Config/nr-rrc.setup_element/nr-rrc.dmrs_UplinkTransformPrecodingPUCCH_r16
    ${dmrs_Pucch_r16_IE}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter_expression=nr-rrc.rrcReconfiguration_element
    ...            xpath=${xpath}
    ...            attribute_name=show
    [Return]    ${dmrs_Pucch_r16_IE}[0]

Get pi2BPSK_pucchF3 From rrc_reg
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${xpath}    Set Variable
    ...     .//nr-rrc.setup_element/nr-rrc.format3/nr-rrc.setup_element/nr-rrc.pi2BPSK
    ${pi2BPSK_pucchF3}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter_expression=nr-rrc.rrcReconfiguration_element
    ...            xpath=${xpath}
    ...            attribute_name=show
    [Return]    ${pi2BPSK_pucchF3}[0]

Get powerBoostPi2BPSK from rrc_reg
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${xpath}    Set Variable
    ...     .//nr-rrc.uplinkConfig_element/nr-rrc.powerBoostPi2BPSK
    ${powerBoostPi2BPSK}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter_expression=nr-rrc.rrcReconfiguration_element
    ...            xpath=${xpath}
    ...            attribute_name=show
    [Return]    ${powerBoostPi2BPSK}[0]

Get tp_pi2BPSK_pusch From rrc_reg
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${xpath}    Set Variable
    ...     .//nr-rrc.pusch_Config/nr-rrc.setup_element/nr-rrc.tp_pi2BPSK
    ${tp_pi2BPSK_pusch}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter_expression=nr-rrc.rrcReconfiguration_element
    ...            xpath=${xpath}
    ...            attribute_name=show
    [Return]    ${tp_pi2BPSK_pusch}[0]

Get transformPrecoder From rrc_reg
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}     ${ie_index}=0
    ${xpath}    Set Variable
    ...     .//nr-rrc.pusch_Config/nr-rrc.setup_element/nr-rrc.transformPrecoder
    ${transformPrecoder}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter_expression=nr-rrc.rrcReconfiguration_element
    ...            xpath=${xpath}
    ...            attribute_name=show
#    ${transformPrecoder}    Remove Duplicates     ${transformPrecoder}
    [Return]    ${transformPrecoder}[${ie_index}]

Get transformPrecoder From rrc_setup
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${xpath}    Set Variable
    ...     .//nr-rrc.pusch_Config/nr-rrc.setup_element/nr-rrc.transformPrecoder
    ${transformPrecoder}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter_expression=nr-rrc.rrcSetup_element
    ...            xpath=${xpath}
    ...            attribute_name=show
    [Return]    ${transformPrecoder}[0]

Get dmrsSequenceType From BIP when mcs_low
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ...            ${bip_filter}=uldata_puschreceivereq
    ${xpath}    BuiltIn.set variable if    '${bip_filter}' == 'uldata_puschreceivereq'
    ...     .//UlData_puschReceiveReqGrant_t.dmrsSequenceType
    ...     .//UlData_pucchReceiveReqPucchResource_t.dmrsSequenceType
    ${filter_expression}    BuiltIn.set variable if     '${bip_filter}' == 'uldata_puschreceivereq'
    ...     UlData_puschReceiveReqGrant_t.mcs == 0 and 3gpp.rnti != 65521
    ...     3gpp.rnti != 65521 and UlData_pucchReceiveReqPucchResource_t.pucchFormat == 3
    ${dmrsSequenceType}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=${bip_filter}
    ...            filter_expression=${filter_expression}
    ...            xpath=${xpath}
    ...            attribute_name=show
    ${dmrsSequenceType}    Remove Duplicates     ${dmrsSequenceType}
    [Return]    ${dmrsSequenceType}[0]

Get dmrsSequenceType From BIP when mcs_low for trunk
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ...            ${bip_filter}=uldata_puschreceivereq
    ${xpath}    BuiltIn.set variable if    '${bip_filter}' == 'uldata_puschreceivereq'
    ...     .//UlData_puschReceiveReqGrant_t.dmrsSequenceType
    ...     .//UlData_pucchReceiveReqPucchResourceL1sw_t.dmrsSequenceType
    ${filter_expression}    BuiltIn.set variable if     '${bip_filter}' == 'uldata_puschreceivereq'
    ...     UlData_puschReceiveReqGrant_t.mcs == 0 and 3gpp.rnti != 65535
    ...     3gpp.rnti != 65535 and UlData_pucchReceiveReqPucchResourceL1sw_t.pucchFormat == 3
    ${dmrsSequenceType}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=${bip_filter}
    ...            filter_expression=${filter_expression}
    ...            xpath=${xpath}
    ...            attribute_name=show
    ${dmrsSequenceType}    Remove Duplicates     ${dmrsSequenceType}
    [Return]    ${dmrsSequenceType}[0]

Get and check pusch_dmrsSequenceType num From BIP
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${filter_expression}     Set Variable
    ...      (UlData_puschReceiveReqGrant_t.mcs == 0) and (3gpp.rnti != 65535) and (3gpp.rnti != 65521)
    ${dmrsSequenceType}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=uldata_puschreceivereq
    ...            filter_expression=${filter_expression}
    ...            xpath=.//UlData_puschReceiveReqGrant_t.dmrsSequenceType
    ...            attribute_name=show
    ${TYPE1_num}=     Count Values In List    ${dmrsSequenceType}     0
    ${TYPE2_num}=     Count Values In List    ${dmrsSequenceType}     1
    ${TYPE1_num}      Convert To Number     ${TYPE1_num}
    ${TYPE2_num}      Convert To Number     ${TYPE2_num}
    should be true     ${TYPE1_num} <= ${TYPE2_num}

Get dmrs_Pusch_r16_IE From rrc_reg
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${xpath}    Set Variable
    ...     .//nr-rrc.dmrs_UplinkTransformPrecoding_r16
    ${dmrs_Pusch_r16_IE}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter_expression=nr-rrc.rrcReconfiguration_element
    ...            xpath=${xpath}
    ...            attribute_name=show
    [Return]    ${dmrs_Pusch_r16_IE}[0]

Get and check Pcmax_value From BIP
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${filter_expression}     Set Variable      uldata_puschreceiveresplo
    ${pcmax_value}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=uldata_puschreceiveresplo
    ...            filter_expression=${filter_expression}
    ...            xpath=.//mac-nr.control.se-phr.pcmax_f_c
    ...            attribute_name=show
    ${pcmax_value}    Remove Duplicates     ${pcmax_value}
    FOR    ${i}    IN    ${pcmax_value}
      ${check_status}     Run Keyword And Return Status     should be true    '${i}' > '23'
      Exit For Loop If    '${check_status}' == 'TRUE'
    END

Get and check pusch_dmrsSequenceType From BIP for CA
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}     ${cell_pci}
    ${filter_expression}     Set Variable     (3gpp.dmrsScramblingSequenceInt == ${cell_pci}) and (3gpp.rnti != 65535)
    ${dmrsSequenceType}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=uldata_puschreceivereq
    ...            filter_expression=${filter_expression}
    ...            xpath=.//UlData_puschReceiveReqGrant_t.dmrsSequenceType
    ...            attribute_name=show
    ${type_value}    Remove Duplicates     ${dmrsSequenceType}
    should contain any        ${type_value}    0    1
