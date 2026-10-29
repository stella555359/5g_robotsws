*** Settings ***
Documentation    This is for feature CB012810 related common keywords.
...              Please do not modify the file without notification to author
...              Author:jia-rebecca.liu@nokia-sbell.com
...              Squard: HZ SG3


Library    OperatingSystem
Library    Collections
Library    String
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/MTK_common_keywords.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Variables          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB012810/Resources/CB012810_parameter.py
Variables          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB012810/Resources/CB012810_parameter_classical.py
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Common_keywords.robot

*** Variables ***

${TS_LOG_PATH_BASE}         ${OUTPUT DIR}/Case_Logs
${TL_ID}
${branch_ID}
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${MRBTS_ID_enb}                 ${tl.enbs[0].instance_id}
${MRBTS_ID2}                 ${tl.gnbs[1].instance_id}

@{ALLOWED_FAULT_12810}       4655    4654    61652    61524    4592    7311    7300
@{allow_fault_TL233}    7311    7107    7523

${enb_instance}              ${tl.enbs[0].instance_id}
${enb_dist_LNCEL1}           MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${enb_administrativeState}      administrativeState

${Test_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
${Test_PC_username}       ${tl.test_pc.default_ssh_connection_details.username}
${Test_PC_password}       ${tl.test_pc.default_ssh_connection_details.password}

${swconfig_file}          /opt/workspace/CRT/Master/SCF_file/swconfig.txt


####----PA----####
${vendor_10318}                     HBTE
${att_api_port_10318}               ${tl.attenuator[1].port}
${model_10318}                      ${tl.attenuator[1].model}
${att_ipaddr_10318}                 ${tl.attenuator[1].ip_addr}

${att_port_1_cell1_10318}          ${tl.attenuator[1].attenuator_ports[1]}
${att_port_2_cell1_10318}          ${tl.attenuator[1].attenuator_ports[2]}
${att_port_3_cell1_10318}          ${tl.attenuator[1].attenuator_ports[3]}
${att_port_4_cell1_10318}          ${tl.attenuator[1].attenuator_ports[4]}
${att_port_5_cell3_10318}          ${tl.attenuator[1].attenuator_ports[5]}
${att_port_6_cell3_10318}          ${tl.attenuator[1].attenuator_ports[6]}
${att_port_7_cell3_10318}          ${tl.attenuator[1].attenuator_ports[7]}
${att_port_8_cell3_10318}          ${tl.attenuator[1].attenuator_ports[8]}
${att_port_9_ENBcell1_10318}       ${tl.attenuator[1].attenuator_ports[9]}
${att_port_10_ENBcell1_10318}       ${tl.attenuator[1].attenuator_ports[10]}
${att_port_11_ENBcell2_10318}       ${tl.attenuator[1].attenuator_ports[11]}
${att_port_12_ENBcell2_10318}       ${tl.attenuator[1].attenuator_ports[12]}

####----233-PA----####
${vendor_23311}                     HBTE
${att_api_port_23311}               ${tl.attenuator[0].port}
${model_23311}                      ${tl.attenuator[0].model}
${att_ipaddr_23311}                 ${tl.attenuator[0].ip_addr}

${att_port_1_enb_cell1_23311}          ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_enb_cell1_23311}          ${tl.attenuator[0].attenuator_ports[2]}
${att_port_5_cell2_23311}         ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6_cell2_23311}         ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7_cell2_23311}         ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8_cell2_23311}         ${tl.attenuator[0].attenuator_ports[8]}
${att_port_13_cell1_23311}         ${tl.attenuator[0].attenuator_ports[13]}
${att_port_14_cell1_23311}         ${tl.attenuator[0].attenuator_ports[14]}
${att_port_15_cell1_23311}         ${tl.attenuator[0].attenuator_ports[15]}
${att_port_16_cell1_23311}         ${tl.attenuator[0].attenuator_ports[16]}


####----UE----####
${ue_type_MTK60}               ${tl.ues[4].capabilities[1]}
${ue_type_samsung}             ${tl.ues[1].capabilities[1]}
${ue_type_0}                   ${tl.ues[0].capabilities[0]}
${ue_type_MTP}                 ${tl.ues[3].capabilities[0]}
${DL_PORT_UE0}                 ${tl.ues[0].iperf_details.port}
${DL_TIME}                     9999
${DL_LENGTH}                   1024B
${APN_DXDATA2}                 dxdata2
${APN_DXDATA1}                 dxdata1
${APN_WAP1}                    wap1

@{gnb_id}    23311    10318
*** Keywords ***
CB012810_suite_setup
    [Arguments]     ${If_swconfig}=False
    ...             ${reset_site}=${None}
    ...             ${swconfig_modify}=${A2B2015_Swconfig}
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    Generate Suite Log Path
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    Set Suite Variable    ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    Set Suite Variable    ${stream}
    ${Golden_SCF_Path}    GET_CLOUD_UTE_SCF_PATH
    set suite variable      ${Golden_SCF_Path}
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}
    Get_TL_Number
    ${nrcellid1}    NRCellid Set suit varaible    cellid=${1}    gnb_index=${0}
    ${nrcellid2}    NRCellid Set suit varaible    cellid=${2}    gnb_index=${0}
    ${nrcellid3}    NRCellid Set suit varaible    cellid=${3}    gnb_index=${0}
    set suite variable    ${nrcellid1}
    set suite variable    ${nrcellid2}
    set suite variable    ${nrcellid3}
    ${nrcell1_pci}    get physicalCellId from coam_gnb_classical    lcrid=${1}
    ${nrcell2_pci}    get physicalCellId from coam_gnb_classical    lcrid=${2}
    ${nrcell3_pci}    get physicalCellId from coam_gnb_classical    lcrid=${3}
    set suite variable    ${nrcell1_pci}
    set suite variable    ${nrcell2_pci}
    set suite variable    ${nrcell3_pci}
    Common Case TestLine Setup     Is_Swconfig=${If_swconfig}
    ...                            swconfig_target_path=${SUITE_LOG_PATH}/swconfig.txt
    ...                            swconfig_file=${Golden_SCF_Path}/swconfig.txt
    ...                            swconfig_modify=${swconfig_modify}
    ...                            reset_site=${reset_site}

CB012810_suite_teardown
    CI_interface.Common Case Teardown
    BuiltIn.run keyword and ignore error     Adjust the HBTE attenuation value for 12810
    Common Suite Teardown for COAM    log_path=${OUTPUT_DIR}

CB012810_case_setup
    [Arguments]     ${ModifySCF_Beforecommission}=False
    ...             ${online_ModifySCF}=False
    ...             ${ParamterToModify}='NULL'
    ...             ${ListParamterToModify}='NULL'
    ...             ${Modify_Para_Online}='NULL'
    ...             ${Add_Para_Online}='NULL'
    ...             ${Delete_Mo_Online}='NULL'
    ...             ${Delete_Para_Online}='NULL'
#    ...             ${If_swconfig}=False
#    ...             ${swconfig_modify}=${None}
    ...             ${allow_fault_list}=${12810_allow_fault_list}
#    ...             ${reset_site}=${None}
    robot_common_operations.Common Case Setup    allowed_faults_ids=7107
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Generate test case log path
    Common Case TestLine Setup     ModifySCF_Beforecommission=${ModifySCF_Beforecommission}
    ...                            scf_dir_path=${SUITE_LOG_PATH}
    ...                            scf_path=${Golden_SCF_Path}
    ...                            golden_scf_name=SCF_${stream}.xml
    ...                            ParamterToModify=${ParamterToModify}
    ...                            ListParamterToModify=${ListParamterToModify}
    ...                            ModifySCF_Aftercommission=${online_ModifySCF}
    ...                            Modify_Para_Online=${Modify_Para_Online}
    ...                            Add_Para_Online=${Add_Para_Online}
    ...                            Delete_Para_Online=${Delete_Para_Online}
    ...                            Delete_Mo_Online=${Delete_Mo_Online}
#    ...                            Is_Swconfig=${If_swconfig}
#    ...                            swconfig_target_path=${TS_CASE_LOG_PATH}/swconfig.txt
#    ...                            swconfig_file=${Golden_SCF_Path}/swconfig.txt
#    ...                            swconfig_modify=${swconfig_modify}
#    ...                            reset_site=${reset_site}

CB012810_case_teardown
    [Arguments]
    robot_common_operations.Common Case Teardown
    run keyword and ignore error    COAM Save snapshot via api    log_path=${TS_CASE_LOG_PATH}
    Run keyword and ignore error    Run Keyword If    '${MRBTS_ID}' == '${gnb_id}[0]'
    ...    Adjust the HBTE attenuation value for TL233    ELSE
    ...    Adjust the HBTE attenuation value for 12810
    Run keyword and ignore error    Teardown the all connections
    Run keyword and ignore error    CI_interface.Common Case Teardown

Get_TL_Number
    run keyword if    '${MRBTS_ID}' == '10318'    Set Suite Variable    ${TL_ID}    TL362

GET_CLOUD_UTE_SCF_PATH
    [Arguments]     ${gnb_index}=0
    ...    ${cur_relative_dir}=testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB012810/Resources
    ${stream}    get stream from version    ${Active_SW_version}
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${testline}   run keyword if    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    set variable     ${testline_name}
    ${gnb_type}    set variable     ${tl.gnbs[${gnb_index}].__class__.__name__}
    ${scf_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${scf_relative_dir}
    ${gnb_ext_index}    evaluate    ${gnb_index}+1
    ${gnb_ext}    set variable if    ${gnb_index}==0    ${EMPTY}    _gnb${gnb_ext_index}
    ${path}    run keyword if   '${gnb_type}'=='ClassicalBts'
    ...    Catenate    SEPARATOR=${/}    ${scf_base_path}    ${testline}
    ...    ELSE IF      '${gnb_type}'=='CloudBts'
    ...    Catenate    SEPARATOR=${/}    ${scf_base_path}    ${testline}
    log to console   ${SPACE*2}scf path: ${path}.
    [Return]    ${path}


CB012810_suite_setup_classical
    Common Suite Setup for COAM
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    Set Suite Variable    ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    Set Suite Variable    ${stream}
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}
    ${release_info_title}    Get sagnb release title
    set suite variable    ${release_info_title}
    Get_TL_Number
    ${nrcellid1}    NRCellid Set suit varaible    cellid=${1}    gnb_index=${0}
    ${nrcellid2}    NRCellid Set suit varaible    cellid=${2}    gnb_index=${0}
    ${nrcellid3}    NRCellid Set suit varaible    cellid=${3}    gnb_index=${0}
    set suite variable    ${nrcellid1}
    set suite variable    ${nrcellid2}
    set suite variable    ${nrcellid3}
    ${nrcell1_pci}    get physicalCellId from coam_gnb_classical    lcrid=${1}
    ${nrcell2_pci}    get physicalCellId from coam_gnb_classical    lcrid=${2}
    ${nrcell3_pci}    get physicalCellId from coam_gnb_classical    lcrid=${3}
    set suite variable    ${nrcell1_pci}
    set suite variable    ${nrcell2_pci}
    set suite variable    ${nrcell3_pci}
    Common Case TestLine Setup
    ...                            is_commission=True
    ...                            golden_scf_name=MRBTS_${MRBTS_ID}_${release_info_title}.xml
    ...                            Is_Swconfig=True
    ...                            swconfig_target_path=${epc_log_path}/swconfig.txt
    ...                            swconfig_file=/opt/workspace/SCF/swconfig.txt
    ...                            swconfig_modify=${A2B2015_Swconfig}


CB012810_case_teardown_classical
    [Arguments]
    robot_common_operations.Common Case Teardown
    run keyword and ignore error    COAM Save snapshot via api
    Run keyword and ignore error    Adjust the HBTE attenuation value for TL233
    Run keyword and ignore error    Teardown the all connections
    Run keyword and ignore error    CI_interface.Common Case Teardown

CB012810_case_setup_classical
    [Arguments]     ${online_ModifySCF}=False
    ...             ${Modify_Para_Online}='NULL'
    ...             ${Add_Para_Online}='NULL'
    ...             ${Delete_Mo_Online}='NULL'
    ...             ${Delete_Para_Online}='NULL'
    ...             ${allow_fault_list}=${12810_allow_fault_list}
    robot_common_operations.Common Case Setup    allowed_faults_ids=7107,7311
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Common Case TestLine Setup     ModifySCF_Aftercommission=${online_ModifySCF}
    ...                            Modify_Para_Online=${Modify_Para_Online}
    ...                            Add_Para_Online=${Add_Para_Online}
    ...                            Delete_Para_Online=${Delete_Para_Online}
    ...                            Delete_Mo_Online=${Delete_Mo_Online}


get physicalCellId from coam_gnb_classical
    [Documentation]    jia-rebecca.liu additional method get physicalCellId
    [Arguments]    ${lcrid}=1    ${gnb_index}=${0}    #${connection}=GNB_OAM
    Wait Until Keyword Succeeds    5m    10s    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    &{config_info}    Create dictionary
    &{NR_CELL_ID_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids    gnb_index=${gnb_index}
    ${physicalCellId}    set variable    ${NR_CELL_ID_MAPPING[${lcrid}]['physicalCellId']}
    [Return]    ${physicalCellId}
    [Teardown]    COAM Teardown gnb connections

#### --------------------------MTK 60----------------------------- ####
MTK60 prepare UE
    [Arguments]    ${ue_index}=${4}    ${ue_type}=${ue_type_MTK60}
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}

MTK60 UE reboot
    [Arguments]    ${ue_index}=${2}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep    5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} reboot   connection=cygwin
    sleep    40s
    [Teardown]    csn.disconnect      connection=cygwin

MTK60 UE Attach
    [Arguments]    ${ue_index}    ${ue_type}=mtk    ${gnb_index}=${0}    ${ue_alias}=UE_${ue_index}
    ...            ${timeout}=15
    ${mtk_timeout}    Evaluate    int(${timeout})
    BuiltIn.Run Keyword And Ignore Error     power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
    ...                                                            ue_alias=${ue_alias}    timeout=${mtk_timeout}

MTK60 UE Detach
    [Arguments]    ${ue_index}    ${ue_type}=mtk
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}


Get IP address from wireshark log and set ue_port for mtk_ue
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: get UE IP and set UE port
    [Arguments]    ${get_ip_from_cpif}    ${ue_index}=${2}
    ${pdu_ip_dnn_dict}     Common_keywords.Get ALL PDU IP Address From Wireshark     cpif_log_path=${get_ip_from_cpif}
    ${ue_dl_port}    Set Variable    ${tl.ues[${ue_index}].iperf_details.port}
    Set Test Variable    ${MTK_DL_PORT}    ${ue_dl_port}
    [Return]     ${MTK_DL_PORT}    ${pdu_ip_dnn_dict}[data]

Start DL traffic for MTK60
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: Start DL traffic and capture Biplog for MTK80
    [Arguments]    ${get_ip_from_cpif}
    ...            ${dl_data_transfer}=1M
    ...            ${duration}=600
    ...            ${ue_index}=${4}
    ...            ${buffer_size}=1400B
    ...            ${appserver}=APPserver
    ...            ${protocol}=udp
    ${pdu_ip_dnn_dict}     Common_keywords.Get ALL PDU IP Address From Wireshark     cpif_log_path=${get_ip_from_cpif}
    ${ue_dl_port}    Set Variable    ${tl.ues[${ue_index}].iperf_details.port}
    Set Test Variable    ${MTK_DL_PORT}    ${ue_dl_port}
    traffic_via_iperf.Start DL traffic via iperf on Appserver    ue_addr=${pdu_ip_dnn_dict}[data]
    ...                                                          dl_time=${duration}
    ...                                                          dl_port=${MTK_DL_PORT}
    ...                                                          dl_throughput=${dl_data_transfer}
    ...                                                          dl_length=${buffer_size}
    ...                                                          appserver=${appserver}
    ...                                                          protocol=${protocol}
    ...                                                          ue_index=${ue_index}

Check tput for MTK60
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: Check dl traffic for MTK80
    [Arguments]     ${ue_index}=${4}
    ...             ${gnb_index}=${0}
    ...             ${cellid}=${nrcellid}
    ...             ${duration}=30
    ...             ${direction}=DL
    ...             ${target_throughput}=1
    ${list_of_cell_ids}    Create list    ${cellid}
    ${tput_file}    power_ue.Collect Tput    ue_type=${ue_type_MTK60}     duration=${duration}    gnb_index=${gnb_index}    ue_index=${ue_index}
    ${output}    power_ue.Check Tput    ue_type=${ue_type_MTK60}    direction=${direction}    cells=${list_of_cell_ids}
    ...                                 target_throughput=${target_throughput}    log=${tput_file}    ue_index=${ue_index}


_MTKUE_attach_and_capture_wiresharklog
    [Arguments]     ${ue_index}=${2}
    ...             ${gnb_index}=${0}
    ...             ${tcpdump_collector_name}=${C_001_wireshark_attach}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    MTK60 UE Attach    ue_index=${ue_index}
    [Teardown]    Stop and download the wiresharklog from master    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    [Return]      ${cpif_log_path}

#### --------------------------samsung UE----------------------------- ####
samsung_UE_prepare
    [Arguments]    ${ue_index}    ${ue_type}    ${ui_version}
    power_ue.Prepare UE    ue_type=${ue_type}    ui_version=${ui_version}    ue_index=${ue_index}

samsung_UE_attach_and_verify
    [Arguments]    ${ue_index}    ${ue_type}    ${4G_check}=False    ${gnb_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=${4G_check}
    ...    gnb_index=${gnb_index}

samsung_UE_detach
    [Arguments]    ${ue_index}    ${ue_type}=${ue_type}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Check DLUL for Samsung
    [Arguments]    ${tput_dl}=${expected_tput_dl}    ${tput_ul}=${expected_tput_ul}
    ...    ${duration}=30s    ${cellid}=1   ${gnb_index}=${0}    ${ue_type}=${ue_type_samsung}
    ${nrcellid}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid}    Create list  ${nrcellid}
    ${tput_log}    power_ue.Collect Tput    duration=${duration}     ue_type=${ue_type}    gnb_index=${gnb_index}
    power_ue.Check Tput    direction=DL    cells=${nrcellid}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl}
    run keyword If    '${tput_ul}'!='NULL'
    ...    Get average UL through and check    log=${tput_log}    list_of_cell_ids=${nrcellid}
    ...    tput_ul=${tput_ul}

Get average UL through and check
    [Arguments]    ${log}    ${list_of_cell_ids}    ${tput_ul}
    ${tput_result}    ${record}    aastp.get_aasyslog_throughput
    ...                            direction=ul    log=${log}    cells=${list_of_cell_ids}
    ${real_ul_tput}    set variable    ${tput_result[0]['average']}
    Should Be True    0 < ${real_ul_tput} < ${tput_ul}

Samsung stop DLUL and detech
    [Arguments]    ${ue_index}=${1}    ${ue_type}=${ue_type_samsung}
    Stop UL DL data transfer    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Make a call dial 911 on UE
    [Arguments]    ${ue_index}=${1}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:911    connection=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 66    connection=cygwin${ue_index}
    sleep   30s
    [Teardown]    csn.disconnect    connection=cygwin${ue_index}

End a call on UE with adb
    [Arguments]    ${ue_index}=${1}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    Log To Console    \n***END A call***
    csn.send_command    command=adb -s ${serial_number} shell input tap 584 2000    connection=cygwin${ue_index}
    sleep   2s
    csn.disconnect      connection=cygwin${ue_index}

samsung Make Vonr Call With Command
    [Arguments]    ${ue_index}=${0}
    ...            ${phone_number}=+6688
    ...            ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...            ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...            ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...            ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:${phone_number}
    ...    connection=cpc_${ue_index}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

samsung answer VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${1}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 5    connection=cpc_${1}
    sleep    5s

samsung hangup VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cpc_${ue_index}
    sleep    5s

stop all traffic
    run keyword and ignore error    Close the iperf process on APPserver    port=${MTK_DL_PORT}

Detach all ues
    power_ue.UE Detach    ue_type=${ue_type_0}    ue_index=${0}
    power_ue.UE Detach    ue_type=${ue_type_samsung}    ue_index=${1}
    power_ue.UE Detach    ue_type=${ue_type_samsung}    ue_index=${2}
    run keyword and ignore error    make WA with Samsung S21    ue_index=${3}
    power_ue.UE Detach    ue_type=${ue_type_samsung}    ue_index=${3}


Detach all ues classical
    power_ue.UE Detach    ue_type=${ue_type_samsung}    ue_index=${0}
    power_ue.UE Detach    ue_type=${ue_type_samsung}    ue_index=${1}
    power_ue.UE Detach    ue_type=${ue_type_samsung}    ue_index=${2}

make WA with Samsung S21
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   4s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin
    sleep    2s
    [Teardown]    csn.disconnect    connection=cygwin

UE Attach for failure scenario
    [Arguments]    ${ue_index}=${0}    ${gnb_index}=${0}    ${hwcheck_index}=${1}    ${du_index}=0    ${UE_type}=${ue_type_samsung}
    ...    ${log_type}=Aasyslog    ${timeout}=30
    [Documentation]    Attach UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for attach
    ...  :param  gnb_index: The list index from tl.gnbs[], it will use the index gnb for attach check
    ...  :param  hwcheck_index: The list index with mapping as 0->ASIK 1->ABIL1 2->ABIL2 3ABIL3, it will use the
    ...          mapping HW to check the ue attach status
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt
	...                                                                          timeout=${timeout}
    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
    ...                                                                          hwcheck_index=${hwcheck_index}
    ...                                                                          log_type=${log_type}
    ...                                                                          log_loca=l2lo
    ${5Gra_l2hidu_counter}    ${5Gra_l2hidu_timed}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
   ...                                                                          hwcheck_index=${hwcheck_index}
   ...                                                                          log_type=${log_type}
    ...                                                                          log_loca=l2hidu
    Preparation and execution for failure scenario    ue_index=${ue_index}    timeout=${timeout}    UE_type=${UE_type}
    Log    click Airplane mode switch to disable its function so that make UE attach
    [Return]    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    ${hwcheck_index}    ${log_type}
    ...    ${5Gra_l2hidu_counter}    ${5Gra_l2hidu_timed}

Preparation and execution for failure scenario
    [Documentation]    UE attach, make Commercial is on Airplane mode in default before, then Determine if UE has
    ...    attached to confirm whether the button was clicked once or twice
    ...    :param  UE_IP_net: check UP IP if eaqul this IP_net.
    ...    :param  UE_type: UE type
    ...    :param  ue_index: The list index from tl.ues[]
    [Arguments]    ${ue_index}=${0}    ${retry}=${0}    ${UE_type}=${UE_type}
    ...    ${home}=${home}    ${airplane}=${airplane}    ${close_task}=${close_task}    ${interval}=5    ${timeout}=30
    FOR   ${index}    IN RANGE    ${retry+1}
#        run keyword if    ${index}==${retry}    Andriod UE adb reboot    ue_index=${ue_index}
        ${passed} =    Check airplane mode status on    ue_index=${ue_index}
        Connect to control pc via cygwin    ue_index=${ue_index}
        run keyword if    '${passed}'=='${True}'
        ...    Run Keywords
        ...    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}    AND
        ...    Log to console    INFO:click AIRPLANE once for ${UE_type} UE attach.
        ...    ELSE
        ...    Run Keywords
        ...    Commercial UE click AIRPLANE twice    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}    AND
        ...    Log to console    INFO:click AIRPLANE twice for ${UE_type} UE attach.
        Andriod UE adb enable data services    ue_index=${ue_index}
        sleep    ${interval}
        run keyword and ignore error    Wait Until Keyword Succeeds    ${timeout}    ${interval}
        ...    Verify UE IP already Assigned    ue_index=${ue_index}
        Exit For Loop If    '${compare}'=='${True}'
    END
    should be true    ${compare}    msg=UE attach failed with no IP success assigned!!!

ADB Reboot samsung_UE
    [Documentation]  Use adb command to reboot the android ue device
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    wait until keyword succeeds    30s    5s    Connect to control pc enhanced    ${ue_index}
    csn.execute    command=adb -s ${serial_number} reboot   connection=cpc_${ue_index}
#    sleep    60s
    wait until keyword succeeds    1min   10s
    ...    check UE Exist with adb_command    serial_number=${serial_number}    connection=cpc_${ue_index}
    [Teardown]    csn.disconnect   connection=cpc_${ue_index}

check UE Exist with adb_command
    [Arguments]    ${serial_number}    ${connection}=cpc_0    ${timeout}=${10}
    ${ue_info}=    _Excute ADB Command On UE PC    command=adb devices    connection=${connection}    timeout=${timeout}
    Should Contain    ${ue_info}    ${serial_number}

SamsungS21 make 911 call with input tap
    [Arguments]    ${Home_button}=${Home_button}    ${ue_index}=${0}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
#    UE Reboot with adb command    ue_index=${ue_index}
    ADB Reboot samsung_UE    ue_index=${ue_index}   serial_number=${serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin
    #####tap phone#####
    csn.send_command    command=adb -s ${serial_number} shell input tap 136 2009     connection=cygwin
    sleep   2s
    #####tap keyboard#####
    csn.send_command    command=adb -s ${serial_number} shell input tap 209 2102     connection=cygwin
    sleep   2s
    #####tap number 9#####
    csn.send_command    command=adb -s ${serial_number} shell input tap 963 1441     connection=cygwin
    sleep   2s
    #####tap number 1#####
    csn.send_command    command=adb -s ${serial_number} shell input tap 246 1002     connection=cygwin
    sleep   2s
    #####tap number 1#####
    csn.send_command    command=adb -s ${serial_number} shell input tap 246 1002     connection=cygwin
    sleep   2s
    #####Click the call button#####
    csn.send_command    command=adb -s ${serial_number} shell input tap 535 1906    connection=cygwin
    sleep   5s
    [Teardown]    csn.disconnect      connection=cygwin

Switch APN to Test_need_APN
    [Arguments]     ${target_APN}    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${gnb_index}=${0}    ${4G_check}=False
    ...             ${APN_ui_version}=one ui 3.1
    Run Keyword And Ignore Error    UE Attach With Power UE Index
    ...                             ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}    gnb_index=${gnb_index}
    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${target_APN}    ui_version=${APN_ui_version}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

UE Attach With Power UE Index
    [Arguments]    ${ue_index}    ${ue_type}=${ue_type}    ${4G_check}=False    ${gnb_index}=${0}    ${Attach_status}=True
    ${Attach_value}=    Run Keyword And Return Status
    ...    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}    gnb_index=${gnb_index}
    Should Be True    '${Attach_value}' == '${Attach_status}'

Switch APN to Test_need_APN for S21
    [Arguments]     ${target_APN}    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${gnb_index}=${0}    ${4G_check}=False
    ...             ${APN_ui_version}=one ui 3.1
    Run Keyword And Ignore Error    UE Attach With Power UE Index
    ...                             ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}    gnb_index=${gnb_index}
    run keyword and ignore error    make WA with Samsung S21    ue_index=${ue_index}
    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${target_APN}    ui_version=${APN_ui_version}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}


#### -----------------------------------PA------------------------------------------------####
Adjust the HBTE attenuation value for 12810
    [Arguments]     ${tl}=${MRBTS_ID}    ${gnb_cell1_value}=${127}    ${gnb_cell3_value}=${127}    ${gnb_cell3_value_MTK60}=${127}
    ...             ${enb_cell1_value}=${127}    ${enb_cell2_value}=${127}

    ####create cell list#####
    @{att_ports_gnb_cell1}    Create List    ${att_port_1_cell1_${tl}}        ${att_port_2_cell1_${tl}}
    ...                                      ${att_port_3_cell1_${tl}}        ${att_port_4_cell1_${tl}}
    @{att_ports_gnb_cell3_MTK60}    Create List    ${att_port_5_cell3_${tl}}        ${att_port_6_cell3_${tl}}
    @{att_ports_gnb_cell3}    Create List    ${att_port_7_cell3_${tl}}        ${att_port_8_cell3_${tl}}
    @{att_ports_enb_cell1}    Create List    ${att_port_9_ENBcell1_${tl}}     ${att_port_10_ENBcell1_${tl}}
    @{att_ports_enb_cell2}    Create List    ${att_port_11_ENBcell2_${tl}}    ${att_port_12_ENBcell2_${tl}}
    ###create value list####
    @{values_gnb_cell1}    Create List    ${gnb_cell1_value}    ${gnb_cell1_value}    ${gnb_cell1_value}    ${gnb_cell1_value}
    @{values_gnb_cell3_MTK60}    Create List    ${gnb_cell3_value_MTK60}    ${gnb_cell3_value_MTK60}
    @{values_gnb_cell3}    Create List    ${gnb_cell3_value}    ${gnb_cell3_value}
    @{values_enb_cell1}    Create List    ${enb_cell1_value}    ${enb_cell1_value}
    @{values_enb_cell2}    Create List    ${enb_cell2_value}    ${enb_cell2_value}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
    ...    att_ports=${att_ports_gnb_cell1}    values=${values_gnb_cell1}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}
    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
    ...    att_ports=${att_ports_gnb_cell3}    values=${values_gnb_cell3}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}
    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
    ...    att_ports=${att_ports_gnb_cell3_MTK60}    values=${values_gnb_cell3_MTK60}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}
    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
    ...    att_ports=${att_ports_enb_cell1}    values=${values_enb_cell1}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}
    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
    ...    att_ports=${att_ports_enb_cell2}    values=${values_enb_cell2}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}

Adjust the HBTE attenuation value for TL233
    [Arguments]     ${tl}=${MRBTS_ID}    ${gnb_cell1_value}=${127}     ${gnb_cell2_value}=${127}
    ...    ${enb_cell1_value}=${127}
    ####create cell list#####
    @{att_ports_enb_cell1}    Create List    ${att_port_1_enb_cell1_${tl}}      ${att_port_2_enb_cell1_${tl}}
    @{att_ports_gnb_cell1}    Create List    ${att_port_13_cell1_${tl}}      ${att_port_14_cell1_${tl}}
    ...     ${att_port_15_cell1_${tl}}      ${att_port_16_cell1_${tl}}
    @{att_ports_gnb_cell2}    Create List    ${att_port_5_cell2_${tl}}      ${att_port_6_cell2_${tl}}
    ...     ${att_port_7_cell2_${tl}}      ${att_port_8_cell2_${tl}}
    ###create value list####
    @{values_enb_cell1}    Create List    ${enb_cell1_value}    ${enb_cell1_value}
    @{values_gnb_cell1}    Create List    ${gnb_cell1_value}    ${gnb_cell1_value}    ${gnb_cell1_value}    ${gnb_cell1_value}
    @{values_gnb_cell2}    Create List    ${gnb_cell2_value}    ${gnb_cell2_value}    ${gnb_cell2_value}    ${gnb_cell2_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
    ...    att_ports=${att_ports_enb_cell1}    values=${values_enb_cell1}
    ...    att_connection_port=${att_port_13_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}
    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
    ...    att_ports=${att_ports_gnb_cell1}    values=${values_gnb_cell1}
    ...    att_connection_port=${att_port_13_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}
    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
    ...    att_ports=${att_ports_gnb_cell2}    values=${values_gnb_cell2}
    ...    att_connection_port=${att_port_13_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}


# =============================LOG Capture============================= #
Start capture wireshark log on master
    [Arguments]    ${filename}    ${gNB_index}=${0}    ${interface}=any
    wait until keyword succeeds    1min   10s    Connect gNB    gNB_index=${gNB_index}
    sleep    3s
    csn.send command    command=tcpdump -i ${interface} -p sctp -w ${gnb_path}${filename}    connection=gNB${gNB_index}
	sleep    13s
    [Teardown]    csn.disconnect    connection=gNB${gNB_index}

Stop and download the wiresharklog from master
    [Arguments]    ${filename}    ${gNB_index}=${0}    ${target_dir}=${TS_CASE_LOG_PATH}
    wait until keyword succeeds    1min   10s    Connect gNB    gNB_index=${gNB_index}
    csn.send command    command=killall tcpdump     connection=gNB${gNB_index}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${filename}   local_path=${target_dir}/${filename}   connection=gNB${gNB_index}
    sleep    3
    set suite variable     ${cpif_log_path}      ${target_dir}/${filename}
    [Teardown]    csn.disconnect    connection=gNB${gNB_index}
    [Return]     ${cpif_log_path}

Start capture cpif_wireshark log on node
    [Arguments]       ${filename}      ${gNB_index}=${1}    ${node_name}=CP-RT     ${interface}=any
    wait until keyword succeeds    1min   10s    Connect gNB    gNB_index=${gNB_index}
    sleep    3s
    ${nodeid_pr}    csn.Execute     command=cat /ram/NrCellMappingInfo.txt|grep ${node_name}     connection=gNB${gNB_index}
    ${nodeid}      Get Regexp Matches    ${nodeid_pr}    0x[0-9A-Fa-f]+
    csn.send command    command=lxc-attach -n ${nodeid}[0]    connection=gNB${gNB_index}
    csn.send command    command=tcpdump -i ${interface} -p sctp -w ${gnb_path}${filename}    connection=gNB${gNB_index}
	sleep    3s
    [Teardown]    csn.disconnect    connection=gNB${gNB_index}


start_capture_btslogs
    [Documentation]    start capture btslog
    [Arguments]     ${btslog_path}=/tmp/btslog2
    ...     ${btslog_launcher}=/opt/btslog/btslog_launcher
    ...     ${btslog_launcher_path}=/opt/btslog/btslog
    Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=${btslog_path}      btslog_launcher=${btslog_launcher}
    ...      btslog_launcher_path=${btslog_launcher_path}


stop_capture_btslogs
    [Documentation]    stop capture btslog
    [Arguments]     ${UTE_syslogs_path}=${TS_CASE_LOG_PATH}
    ...             ${btslog_path}=/tmp/btslog2
    ...             ${btslog_launcher}=/opt/btslog/btslog_launcher
    ...             ${btslog_launcher_path}=/opt/btslog/btslog
    Stop BTSlogs Collection And Download Logs To Log Server
    ...        UTE_syslogs_path=${UTE_syslogs_path}
    ...        btslog_path=${btslog_path}
    ...        btslog_launcher=${btslog_launcher}
    ...        btslog_launcher_path=${btslog_launcher_path}



# ------------------------LOG analysis------------------------------ #
Setup the Pcap File
    [Arguments]   ${file_path}   ${filter}=dldata_pdschsendreq||dldata_pdcchsendreq     ${alias}=parser
    ...            ${extension}=${None}   ${override_preference_setting}=${None}
    ...           ${disable_all_name_resolutions}=${None}   ${flush_standard_output}=${None}
    ...           ${tshark_path}=/usr/bin/tshark
    [Documentation]  Setup pcap_parser with tshark command options
    cap.setup
    ...              infile=${file_path}
    ...              display_filter=${filter}
    ...              extension=${extension}
    ...              override_preference_setting=${override_preference_setting}
    ...              disable_all_name_resolutions=${disable_all_name_resolutions}
    ...              flush_standard_output=${flush_standard_output}
    ...              tshark_path=${tshark_path}
    ...              alias=${alias}

Convert cpif_pcap log To Pdml
    [Documentation]    Description: convert to cpif pcap to pdml format, pdml can be used for value check.
    [Arguments]    ${file_path}
    ...            ${filter}=nr-rrc
    ...            ${alias}=parser
    ${command_template}    Catenate    tshark -o nas-5gs.null_decipher:TRUE -r ${file_path} -Y \"${filter}\" -T pdml
#    ${command_template}    Catenate    ${tshark_path} -r ${file_path} -Y \"${filter}\" -T pdml
    cap.load_pcap_file    pcap_file=${file_path}    command_template=${command_template}    alias=${alias}

Get Field Value From Pdml_file
    [Documentation]    Description: get field value from pdml file.
    [Arguments]    ${filter_expression}    ${xpath}    ${attribute_name}=show    ${alias}=parser
    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=${alias}
    ${field_value}=    cap.get_field_value_by_xpath    xpath=${xpath}    attribute_name=${attribute_name}    pcap_parser=${alias}
    [Return]    ${field_value}

Get Field Value From PCAP_file
    [Arguments]   ${field_name}   ${filter_expression}    ${attribute_name}=show    ${alias}=parser
    [Documentation]  Get specified field’s values from filtered packets
    ${field_value_list}   cap.get_field_value
    ...   field_name=${field_name}   fmt=${attribute_name}   filter=${filter_expression}   pcap_parser=${alias}
    [return]   ${field_value_list}

Check Target Item Value on cpif_Tcpdump log
    [Documentation]       Description:check target item value on CPIF tcpdump log.
    [Arguments]    ${file_path}
    ...            ${filter_expression}
    ...            ${xpath}
    ...            ${filter}=f1ap||nr-rrc||ngap
#    ...            ${command_template}={tshark_path} -r {file_path} -Y \"${filter}\" -T pdml
    ...            ${attribute_name}=show
    Convert cpif_pcap log To Pdml    file_path=${file_path}
    ...                              filter=${filter}
#    ...                              command_template=${command_template}
    ${filter_output}    Get Field Value From Pdml_file    filter_expression=${filter_expression}
    ...                                              xpath=${xpath}
    ...                                              attribute_name=${attribute_name}
    [Return]    ${filter_output}

Check VONR setup from wireshark log
    [Arguments]    ${file_path}
    ####VONR setup
    Log To Console    check VONR setup
    ${vonr_setup}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=ngap
    ...            filter_expression=ngap.procedureCode == 26 and ngap.fiveQI == 1
    ...            xpath=.//ngap.fiveQI
    should be equal    ${vonr_setup[0]}    1

Check VONR hangup from wireshark log
    [Arguments]    ${file_path}
    Log To Console    check VONR hangup
    ${vonr_hangup}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=ngap
    ...            filter_expression=ngap.procedureCode == 26
    ...            xpath=.//ngap.nas
    should be equal    ${vonr_hangup[0]}    0

Check intra-F intra-gNB HO procedure
    [Arguments]    ${file_path}    ${target_cell}
    ${filtered_value}=    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=f1ap
    ...            filter_expression=f1ap.procedureCode == 13 and nr-rrc.measResultListNR == 1
    ...            xpath=.//nr-rrc.MeasResultNR_element/nr-rrc.physCellId
    should be equal As Integers    ${filtered_value[0]}    ${target_cell}

check emc call if setup success
    [Arguments]    ${file_path}
    Setup the Pcap File   file_path=${file_path}    filter=ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    ${Code26_0_status} =    run_keyword_and_return_status
    ...    Get Field Value From PCAP_file     field_name=${Code26_0}    filter_expression=${None}    attribute_name=show
    should be equal    ${Code26_0_status}    ${True}
    ${ngap_fiveQI}=    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...                filter=ngap
    ...                filter_expression=${Code26_0}
    ...                xpath=.//ngap.fiveQI
    Should Be Equal    ${ngap_fiveQI[0]}    1

Get and Check EstablishmentCase in wireshark after attach
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}    ${establishment_cause_target}=establishmentCause: mo-Signalling (3)
#    Setup the Pcap File   file_path=${file_path}    filter=nr-rrc.rrcSetupRequest_element
#    ${establishment_cause_pre}    Get Field Value From PCAP_file
#    ...                       field_name=nr-rrc.establishmentCause    filter_expression=${None}    attribute_name=showname
#    ${establishment_cause}    Remove Duplicates    ${establishment_cause_pre}[0]
#    ${establishment_cause}     String.Split String     ${establishment_cause_pre}[0]    ${SPACE}
#    run keyword and continue on failure     should be true     '${establishment_cause}[1]' == '${establishment_cause_target}'
#    run keyword and continue on failure     should contain     '${establishment_cause}'     '${establishment_cause_target}'
    ${establishment_cause_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc
    ...     filter_expression=nr-rrc.establishmentCause
    ...     xpath=.//nr-rrc.establishmentCause
    ...     attribute_name=showname
#    ${establishment_cause}    Remove Duplicates    ${establishment_cause_pre}
    run keyword and continue on failure     should contain     '${establishment_cause_pre}'     '${establishment_cause_target}'
    [Return]     ${establishment_cause_pre}

Get and Check EstablishmentCase_emc in wireshark after attach
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    Setup the Pcap File   file_path=${file_path}    filter=nr-rrc.rrcSetupRequest_element
    ${establishment_cause_pre}    Get Field Value From PCAP_file
    ...                       field_name=nr-rrc.establishmentCause    filter_expression=${None}    attribute_name=showname
    ${establishment_cause_pre}    Remove Duplicates    ${establishment_cause_pre}
    should contain     ‘${establishment_cause_pre}'    'establishmentCause: emergency (0)'


Get and Check InitialContextSetup in wireshark after attach
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    Setup the Pcap File   file_path=${file_path}    filter=ngap.InitialContextSetupFailure_element
    ${InitialContextSetup_pre}    Get Field Value From PCAP_file
    ...                       field_name=ngap.radioNetwork    filter_expression=${None}    attribute_name=showname
    ${InitialContextSetupFailure_exist}    run keyword and return status    should not be empty    ${InitialContextSetup_pre}
    ${InitialContextSetup_pre}    run keyword if    ${InitialContextSetupFailure_exist} == True
    ...                           Remove Duplicates    ${InitialContextSetup_pre}[0]
    ${InitialContextSetup}     run keyword if    ${InitialContextSetupFailure_exist} == True
    ...                     String.Split String     ${InitialContextSetup_pre}[0]    ${SPACE}
    should be true     '${InitialContextSetup}[1]' == 'radio-resources-not-available'
    [Return]     ${InitialContextSetup}[1]

Check timer differ
    [Arguments]    ${logname}    ${message_filter}    ${message_filter1}    ${index00}    ${index01}    ${value}
    ${time1} =    Get message time    logname=${logname}    message_filter=${message_filter}    index=${index00}
    ${time2} =    Get message time    logname=${logname}    message_filter=${message_filter1}    index=${index01}
    ${time_dif1} =    evaluate  float(${time2})-float(${time1})
    ${time_differ1} =    convert_to_number    ${time_dif1}	0
    should be true    ${time_differ1}>=${value}
    [Return]    ${time_differ1}

Get message time
    [Arguments]    ${logname}    ${message_filter}    ${index}=${index0}
    ${frame_time}    Check Target Item Value on cpif_Tcpdump log    file_path=${logname}
    ...            filter=ngap
    ...            filter_expression=${message_filter}
    ...            xpath=.//frame.time_epoch
    ${timestamp}=    convert_to_number    ${frame_time}[${index}]
    [Return]    ${timestamp}

Get and Check UEContextRelease in wireshark
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}    ${release_reason}=release-due-to-pre-emption
    Setup the Pcap File   file_path=${file_path}    filter=ngap.UEContextReleaseCommand_element
    ${UEContextRelease_pre}    Get Field Value From PCAP_file
    ...                       field_name=ngap.radioNetwork    filter_expression=${None}    attribute_name=showname
    ${UEContextRelease_exist}    run keyword and return status    should not be empty    ${InitialContextSetup_pre}
    ${UEContextRelease_pre}    Remove Duplicates    ${UEContextRelease_pre}[0]
    ${UEContextRelease}     String.Split String     ${UEContextRelease_pre}[0]    ${SPACE}
    should be true     '${UEContextRelease}[1]' == '${release_reason}'
    [Return]     ${UEContextRelease}[1]

Get SR_periodicity and pucch_info in RRC_setup
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${periodicityAndOffset_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcSetup_element
    ...     filter_expression=nr-rrc.schedulingRequestResourceToAddModList == 1
    ...     xpath=.//nr-rrc.schedulingRequestResourceToAddModList/_/nr-rrc.SchedulingRequestResourceConfig_element/nr-rrc.periodicityAndOffset
    ...     attribute_name=showname
    ${periodicityAndOffset_pre}    Remove Duplicates    ${periodicityAndOffset_pre}
    ${SR_periodicity}     String.Split String     ${periodicityAndOffset_pre}[0]    ${SPACE}
    ${SR_Offset_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcSetup_element
    ...     filter_expression=nr-rrc.schedulingRequestResourceToAddModList == 1
    ...     xpath=.//nr-rrc.SchedulingRequestResourceConfig_element/nr-rrc.periodicityAndOffset/nr-rrc.${SR_periodicity}[1]
    ...     attribute_name=showname
    ${SR_Offset}     String.Split String     ${SR_Offset_pre}[0]    ${SPACE}
    ${pucch_resource_id}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcSetup_element
    ...     filter_expression=nr-rrc.schedulingRequestResourceToAddModList == 1
    ...     xpath=.//nr-rrc.schedulingRequestResourceToAddModList/_/nr-rrc.SchedulingRequestResourceConfig_element/nr-rrc.resource
    ...     attribute_name=show
    ${pucch_resource_index}=    evaluate    ${pucch_resource_id}[0] + 1
    ${pucch_startPRB}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcSetup_element
    ...     filter_expression=nr-rrc.schedulingRequestResourceToAddModList == 1
    ...     xpath=.//nr-rrc.resourceToAddModList/_[${pucch_resource_index}]/nr-rrc.PUCCH_Resource_element/nr-rrc.startingPRB
    ...     attribute_name=show
    ${pucch_startPRB}    Remove Duplicates    ${pucch_startPRB}
    ${initialCyclicShift}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcSetup_element
    ...     filter_expression=nr-rrc.schedulingRequestResourceToAddModList == 1
    ...     xpath=.//_[${pucch_resource_index}]/nr-rrc.PUCCH_Resource_element/nr-rrc.format/nr-rrc.format1_element/nr-rrc.initialCyclicShift
    ...     attribute_name=show
    ${initialCyclicShift}    Remove Duplicates    ${initialCyclicShift}
    ${timeDomainOCC}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcSetup_element
    ...     filter_expression=nr-rrc.schedulingRequestResourceToAddModList == 1
    ...     xpath=.//_[${pucch_resource_index}]/nr-rrc.PUCCH_Resource_element/nr-rrc.format/nr-rrc.format1_element/nr-rrc.timeDomainOCC
    ...     attribute_name=show
    [Return]     ${SR_periodicity}[1]    ${SR_offset}[-1]    ${pucch_startPRB}[0]    ${initialCyclicShift}[0]    ${timeDomainOCC}[0]

Get SR_periodicity in DRB_level for 5QI
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${DNN_PRE}        Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcReconfiguration_element
    ...     filter_expression=nr-rrc.schedulingRequestResourceToAddModList == 1
    ...     xpath=.//nas-5gs.cmn.dnn
    ...     attribute_name=showname
    ${DNN_value}     String.Split String     ${DNN_PRE}[-1]    ${SPACE}
    log to console    dnn_value is : ${DNN_value}[1]
    ${periodicityAndOffset_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcReconfiguration_element
    ...     filter_expression=nr-rrc.schedulingRequestResourceToAddModList == 1 and nas-5gs.cmn.dnn == ${DNN_value}[1]
    ...     xpath=.//nr-rrc.schedulingRequestResourceToAddModList/_/nr-rrc.SchedulingRequestResourceConfig_element/nr-rrc.periodicityAndOffset
    ...     attribute_name=showname
    log to console    ${periodicityAndOffset_pre}[0]
    ${SR_periodicity}     String.Split String     ${periodicityAndOffset_pre}[0]    ${SPACE}
    ${SR_Offset_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcReconfiguration_element
    ...     filter_expression=nr-rrc.schedulingRequestResourceToAddModList == 1
    ...     xpath=.//nr-rrc.SchedulingRequestResourceConfig_element/nr-rrc.periodicityAndOffset/nr-rrc.${SR_periodicity}[1]
    ...     attribute_name=showname
    ${SR_Offset}     String.Split String     ${SR_Offset_pre}[0]    ${SPACE}
    ${pucch_resource_id}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcReconfiguration_element
    ...     filter_expression=nr-rrc.schedulingRequestResourceToAddModList == 1 and nas-5gs.cmn.dnn == ${DNN_value}[1]
    ...     xpath=.//nr-rrc.SchedulingRequestResourceConfig_element/nr-rrc.resource
    ...     attribute_name=show
    ${pucch_resource_index}=    evaluate    ${pucch_resource_id}[0] + 1
    log to console    ${pucch_resource_id}[0]
    ${pucch_startPRB}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcReconfiguration_element
    ...     filter_expression=nr-rrc.schedulingRequestResourceToAddModList == 1 and nas-5gs.cmn.dnn == ${DNN_value}[1]
    ...     xpath=.//_[${pucch_resource_index}]/nr-rrc.PUCCH_Resource_element/nr-rrc.startingPRB
    ...     attribute_name=show
    log to console    ${pucch_startPRB}[0]
    ${initialCyclicShift}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcReconfiguration_element
    ...     filter_expression=nr-rrc.schedulingRequestResourceToAddModList == 1 and nas-5gs.cmn.dnn == ${DNN_value}[1]
    ...     xpath=.//_[${pucch_resource_index}]/nr-rrc.PUCCH_Resource_element/nr-rrc.format/nr-rrc.format1_element/nr-rrc.initialCyclicShift
    ...     attribute_name=show
    log to console    ${initialCyclicShift}[0]
    ${timeDomainOCC}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcReconfiguration_element
    ...     filter_expression=nr-rrc.schedulingRequestResourceToAddModList == 1 and nas-5gs.cmn.dnn == ${DNN_value}[1]
    ...     xpath=.//_[${pucch_resource_index}]/nr-rrc.PUCCH_Resource_element/nr-rrc.format/nr-rrc.format1_element/nr-rrc.timeDomainOCC
    ...     attribute_name=show
    log to console    ${timeDomainOCC}[0]
    [Return]     ${SR_periodicity}[1]    ${SR_offset}[-1]    ${pucch_startPRB}[0]    ${initialCyclicShift}[0]    ${timeDomainOCC}[0]

Get SR_periodicity in DRB_level for 5QI by DUUEID
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    ...    only used A3IKW3001 UE3 log check
    [Arguments]    ${file_path}    ${ueid_index}=${0}
    ${DUUEID_PRE}        Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcSetup_element
    ...     filter_expression=nr-rrc.schedulingRequestResourceId == 1
    ...     xpath=.//f1ap.GNB_DU_UE_F1AP_ID
    ...     attribute_name=show
    ${DUUEID}    Remove Duplicates    ${DUUEID_PRE}
    log to console    ${DUUEID}[${ueid_index}]
    ${periodicityAndOffset_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcReconfiguration_element
    ...     filter_expression=nr-rrc.schedulingRequestResourceToAddModList == 1 and f1ap.GNB_DU_UE_F1AP_ID == ${DUUEID_PRE}[${ueid_index}]
    ...     xpath=.//nr-rrc.schedulingRequestResourceToAddModList/_/nr-rrc.SchedulingRequestResourceConfig_element/nr-rrc.periodicityAndOffset
    ...     attribute_name=showname
    log to console    ${periodicityAndOffset_pre}[-1]
    ${SR_periodicity}     String.Split String     ${periodicityAndOffset_pre}[-1]    ${SPACE}
    ${SR_Offset_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcReconfiguration_element
    ...     filter_expression=nr-rrc.schedulingRequestResourceToAddModList == 1
    ...     xpath=.//nr-rrc.SchedulingRequestResourceConfig_element/nr-rrc.periodicityAndOffset/nr-rrc.${SR_periodicity}[1]
    ...     attribute_name=showname
    ${SR_Offset}     String.Split String     ${SR_Offset_pre}[0]    ${SPACE}
    ${pucch_resource_id}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcReconfiguration_element
    ...     filter_expression=nr-rrc.schedulingRequestResourceToAddModList == 1 and f1ap.GNB_DU_UE_F1AP_ID == ${DUUEID_PRE}[${ueid_index}]
    ...     xpath=.//nr-rrc.SchedulingRequestResourceConfig_element/nr-rrc.resource
    ...     attribute_name=show
    ${pucch_resource_index}=    evaluate    ${pucch_resource_id}[-1] + 1
    log to console    ${pucch_resource_id}[-1]
    ${pucch_startPRB}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcReconfiguration_element
    ...     filter_expression=nr-rrc.schedulingRequestResourceToAddModList == 1 and f1ap.GNB_DU_UE_F1AP_ID == ${DUUEID_PRE}[${ueid_index}]
    ...     xpath=.//nr-rrc.PUCCH_Resource_element/nr-rrc.startingPRB
    ...     attribute_name=show
    log to console    ${pucch_startPRB}[-1]
    ${pucch_startPRB}    Remove Duplicates    ${pucch_startPRB}
    ${initialCyclicShift}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcReconfiguration_element
    ...     filter_expression=nr-rrc.schedulingRequestResourceToAddModList == 1 and f1ap.GNB_DU_UE_F1AP_ID == ${DUUEID_PRE}[${ueid_index}]
    ...     xpath=.//_[${pucch_resource_index}]/nr-rrc.PUCCH_Resource_element/nr-rrc.format/nr-rrc.format1_element/nr-rrc.initialCyclicShift
    ...     attribute_name=show
    log to console    ${initialCyclicShift}[-1]
##    ${initialCyclicShift}    Remove Duplicates    ${initialCyclicShift}
    ${timeDomainOCC}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcReconfiguration_element
    ...     filter_expression=nr-rrc.schedulingRequestResourceToAddModList == 1 and f1ap.GNB_DU_UE_F1AP_ID == ${DUUEID_PRE}[${ueid_index}]
    ...     xpath=.//_[${pucch_resource_index}]/nr-rrc.PUCCH_Resource_element/nr-rrc.format/nr-rrc.format1_element/nr-rrc.timeDomainOCC
    ...     attribute_name=show
    log to console    ${timeDomainOCC}[-1]
    [Return]     ${SR_periodicity}[1]    ${SR_offset}[-1]    ${pucch_startPRB}[0]    ${initialCyclicShift}[0]    ${timeDomainOCC}[0]

Get and check physicalcellid from scelltoaddmodlist
    [Arguments]    ${file_path}    ${target_cell}
    ${physical_cellid}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcReconfiguration_element
    ...     filter_expression=nr-rrc.sCellToAddModList == 1
    ...     xpath=.//nr-rrc.physCellId
    ...     attribute_name=show
    should be equal As Integers    ${physical_cellid[0]}    ${target_cell}

Get finally used SR_periodicity
    [Arguments]    ${file_path}
    ${SR_periodicity_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=f1ap
    ...     filter_expression=nr-rrc.schedulingRequestResourceId == 1
    ...     xpath=.//nr-rrc.schedulingRequestResourceToAddModList/_/nr-rrc.SchedulingRequestResourceConfig_element/nr-rrc.periodicityAndOffset
    ...     attribute_name=showname
    ${periodicityAndOffset}     String.Split String     ${SR_periodicity_pre}[-1]    ${SPACE}
    [Return]    ${periodicityAndOffset}[1]

Get drx-config
    [Arguments]    ${file_path}
    ${drx_ondurationtimer_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcReconfiguration_element
    ...     filter_expression=nr-rrc.drx_Config == 1
    ...     xpath=.//nr-rrc.milliSeconds
    ...     attribute_name=showname
    ${drx_ondurationtimer_ex}     String.Split String     ${drx_ondurationtimer_pre}[-1]    ${SPACE}
    ${drx_ondurationtimer}    String.Get Regexp Matches    ${drx_ondurationtimer_ex}[1]     ms(..)    1
    ${drx_LongCycleStartOffset_ms_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcReconfiguration_element
    ...     filter_expression=nr-rrc.drx_Config == 1
    ...     xpath=.//nr-rrc.drx_LongCycleStartOffset
    ...     attribute_name=showname
    ${drx_LongCycleStartOffset_ms}     String.Split String     ${drx_LongCycleStartOffset_ms_pre}[-1]    ${SPACE}
    ${drx_LongCycleStartOffset_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=nr-rrc.rrcReconfiguration_element
    ...     filter_expression=nr-rrc.drx_Config == 1
    ...     xpath=.//nr-rrc.${drx_LongCycleStartOffset_ms}[1]
    ...     attribute_name=showname
    ${drx_LongCycleStartOffset}     String.Split String     ${drx_LongCycleStartOffset_pre}[-1]    ${SPACE}
    ${drx_Longcycle}    String.Get Regexp Matches    ${drx_LongCycleStartOffset}[0]     ms(..)    1
    [Return]    ${drx_ondurationtimer}[0]    ${drx_LongCycleStartOffset}[1]    ${drx_Longcycle}[0]

Get SR_periodicity and offset
    [Arguments]    ${file_path}
    ${SR_periodicity_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=f1ap
    ...     filter_expression=nr-rrc.schedulingRequestResourceId == 1
    ...     xpath=.//nr-rrc.schedulingRequestResourceToAddModList/_/nr-rrc.SchedulingRequestResourceConfig_element/nr-rrc.periodicityAndOffset
    ...     attribute_name=showname
    ${periodicity}     String.Split String     ${SR_periodicity_pre}[-1]    ${SPACE}
    ${SR_offset_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...     filter=f1ap
    ...     filter_expression=nr-rrc.schedulingRequestResourceId == 1
    ...     xpath=.//nr-rrc.${periodicity}[1]
    ...     attribute_name=showname
    ${SR_offset}     String.Split String     ${SR_offset_pre}[-1]    ${SPACE}
    [Return]    ${SR_offset}[-1]

 #### ----------------------------TTI--------------------------------#####
Analysis tti for ulFdSchedData.ulProGrantType
     [Arguments]    ${names}    ${VONR_called}=True    ${target_dir}=${TS_CASE_LOG_PATH}
     log to console    analysis tti file for ulFdSchedData.ulProGrantType
     ${GrantType}    get_GrantType_value    csv_file=${target_dir}/${names}_ul.csv     filter_name=ulFdSchedData.ulProGrantType
     ${GrantType}    Remove Duplicates    ${GrantType}
     Run Keyword If    ${VONR_called}    Should not Contain    ${GrantType}    DRBPRIOPUGNONSKIPPABLE
     ...    ELSE    Should Contain    ${GrantType}    DRBPRIOPUGNONSKIPPABLE

Analysis tti for ulFdSchedData.rrmBufferedDataUlTotal
    [Arguments]    ${names}    ${target_dir}=${TS_CASE_LOG_PATH}
    log to console    analysis tti file for ulFdSchedData.rrmBufferedDataUlTotal_bytes=drbPriorityPugPayloadSize
    ${PugPayloadSize}    get_rrmBufferedDataUl_value    csv_file=${target_dir}/${names}_ul.csv
    ...    key_filter=ulFdSchedData.ulProGrantType    target_filter=ulFdSchedData.rrmBufferedDataUlTotal_bytes
    ...    grant_type=DRBPRIOPUGNONSKIPPABLE
    ${PugPayloadSize}    Remove Duplicates    ${PugPayloadSize}
    Should Contain    ${PugPayloadSize}    100.0

Analysis tti for ulProGrantType
     [Arguments]    ${names}    ${drb_pug}=True    ${DrbGrantType}=DRBPRIOPUGNONSKIPPABLE
     ...    ${target_dir}=${TS_CASE_LOG_PATH}
     log to console    analysis tti file for ulFdSchedData.ulProGrantType
     ${GrantType}    get_GrantType_value    csv_file=${target_dir}/${names}_ul.csv     filter_name=ulFdSchedData.ulProGrantType
     ${GrantType}    Remove Duplicates    ${GrantType}
     Run Keyword If    ${drb_pug}
     ...    Should Contain    ${GrantType}    ${DrbGrantType}
     ...    ELSE    Run keywords
     ...    Should not Contain    ${GrantType}    ${DrbGrantType}
     ...    AND    Should Contain    ${GrantType}    NONSKIPPABLE

Analysis tti for ulProGrantType no drbpug and lowpug
     [Arguments]    ${names}    ${target_dir}=${TS_CASE_LOG_PATH}
     log to console    analysis tti file for ulFdSchedData.ulProGrantType
     ${GrantType}    get_GrantType_value    csv_file=${target_dir}/${names}_ul.csv     filter_name=ulFdSchedData.ulProGrantType
     ${GrantType}    Remove Duplicates    ${GrantType}
     Should not Contain    ${GrantType}    NONSKIPPABLE
     Should not Contain    ${GrantType}    DRBPRIOPUGNONSKIPPABLE

Analysis tti for ulFdSchedData.rrmBufferedDataUlLcg_bytes
    [Arguments]    ${names}    ${bufferSize}=[0, 1500, 0, 0, 0, 0, 0, 0]    ${grant}=DRBPRIOPUGNONSKIPPABLE
    ...    ${target_dir}=${TS_CASE_LOG_PATH}
    log to console    analysis tti file for drbpug's ulFdSchedData.rrmBufferedDataUlLcg_bytes=drbPriorityPugPayloadSize
    ...    lowpug's ulFdSchedData.rrmBufferedDataUlLcg_bytes=ulFdSchedData.rrmBufferedDataUlLcg_bytes
    ${target_filter}    set variable if    '${release_info}' == 'SBTS26R3_ENB_9999' or '${release_info}' == 'SBTS26R3_ENB_9'
    ...                                                     ulFdSchedAdditionalData.rrmBufferedDataUlLcg_bytes
    ...                                                     ulFdSchedData.rrmBufferedDataUlLcg_bytes
    ${PugPayloadSize}    get_rrmBufferedDataUl_value    csv_file=${target_dir}/${names}_ul.csv
    ...    key_filter=ulFdSchedData.ulProGrantType    target_filter=${target_filter}
    ...    grant_type=${grant}
    ${PugPayloadSize}    Remove Duplicates    ${PugPayloadSize}
    Should Contain    ${PugPayloadSize}    ${bufferSize}

Analysis tti for SFN same
    [Arguments]    ${names}    ${grant}=DRBPRIOPUGNONSKIPPABLE    ${target_dir}=${TS_CASE_LOG_PATH}
    log to console    analysis tti file for slot8 and slot18‘s frame same
    ${slot8}    get_SFN_value    csv_file=${target_dir}/${names}_ul.csv    grant_type=${grant}
    ...    key_filter=ulFdSchedData.ulProGrantType    target_filter=sfn    slot_num=8
    ${slot18}    get_SFN_value    csv_file=${target_dir}/${names}_ul.csv    grant_type=${grant}
    ...    key_filter=ulFdSchedData.ulProGrantType    target_filter=sfn    slot_num=18
    FOR    ${index}    IN RANGE    1    10
         Should Be Equal    ${slot8}[${index}]    ${slot18}[${index}]
    END




 #### ----------------------------counter--------------------------------#####
Get the all PM counter value
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    ${counter_value_list}    create list
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
        ...    dic_path=${dic_path[${index}]}    timeout=300
        append to list    ${counter_value_list}    ${counter_value[0]}
    END
    [Return]    ${counter_value_list}

Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}