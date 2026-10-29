*** Settings ***
Documentation    This is for feature CB012544 related common keywords.
...              Please do not modify the file without notification to author
...              Author:jia-rebecca.liu@nokia-sbell.com
...              Squard: HZ SG3



Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/MTK_common_keywords.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Variables        modify_parameter.py
Variables        modify_parameter_cloud_vm.py
#Library          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/capture_logs_via_gnb_logs_tool.py
Library          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB012544_FDD/Resources/start_paging_and_traffic_via_thread.py
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Common_keywords.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot

*** Variables ***
${TS_LOG_PATH_BASE}         ${OUTPUT DIR}/Case_Logs
${TS_CASE_LOG_PATH}         ${OUTPUT DIR}/Case_Logs
${TL_ID}
${branch_ID}
${MRBTS2_ID}                 ${tl.gnbs[1].instance_id}
${MRBTS1_ID}                 ${tl.gnbs[0].instance_id}
${global_bts_ID}                 ${tl.gnbs[0].global_bts_id}

${scf_TL344_TRUNK}           golden_FDD.xml
${scf_TL344_25R1}            golden_FDD.xml
${tl_scf_gnb2}               _GNB2_
${scf_path_12544}            /opt/workspace/CRT/Master/SCF_file/
@{ALLOWED_FAULT_12544}       4655    4654    61652    61524    4592    7311    7300    61649
@{12544_allow_fault_list}     7311    4405    4404    1898

${enb_instance}              ${tl.enbs[0].instance_id}
${enb_dist_LNCEL1}           MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${enb_administrativeState}      administrativeState

${eERX_idle_IE}              nr-rrc.eDRX_AllowedIdle_r17
${eERX_Inactive_IE}          nr-rrc.eDRX_AllowedInactive_r17

${Test_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
${Test_PC_username}       ${tl.test_pc.default_ssh_connection_details.username}
${Test_PC_password}       ${tl.test_pc.default_ssh_connection_details.password}
${GNB2_host}              ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}

${swconfig_file}          /opt/workspace/CRT/Master/SCF_file/swconfig.txt
${ue_type_MTK60}           ${tl.ues[2].capabilities[1]}
${ue_type_huawei}          ${tl.ues[1].capabilities[0]}
@{gnb_id}                  24212

${aa_sys_addr_344_GNB2}              0x0A399604
${tshark_path}              /usr/bin/tshark
####----PA----####
${model}                          ${tl.attenuator[0].model}
${att_ipaddr_34412}               ${tl.attenuator[0].ip_addr}

${att_port_1_cell1_34412}         ${tl.attenuator[0].attenuator_ports[1]}
${att_port_5_cell1_34412}         ${tl.attenuator[0].attenuator_ports[5]}
${att_port_7_cell1_34412}         ${tl.attenuator[0].attenuator_ports[7]}
${att_port_6_cell2_34412}         ${tl.attenuator[0].attenuator_ports[6]}
${att_port_8_cell2_34412}         ${tl.attenuator[0].attenuator_ports[8]}
${att_port_10_cell3_34412}         ${tl.attenuator[0].attenuator_ports[10]}
${att_port_12_cell3_34412}         ${tl.attenuator[0].attenuator_ports[12]}
${att_port_enb_cell0_34412}       ${tl.attenuator[0].attenuator_ports[13]}
${att_port_enb_cell1_34412}       ${tl.attenuator[0].attenuator_ports[14]}
${att_port_enb_cell2_34412}       ${tl.attenuator[0].attenuator_ports[15]}
####----362_PA----####
${vendor_10318}                     HBTE
${att_api_port_10318}               ${tl.attenuator[1].port}
${model_10318}                      ${tl.attenuator[1].model}
${att_ipaddr_10318}                 ${tl.attenuator[1].ip_addr}

${att_port_1_cell1_10318}           ${tl.attenuator[1].attenuator_ports[1]}
${att_port_2_cell1_10318}           ${tl.attenuator[1].attenuator_ports[2]}
${att_port_3_cell1_10318}           ${tl.attenuator[1].attenuator_ports[3]}
${att_port_4_cell1_10318}           ${tl.attenuator[1].attenuator_ports[4]}
${att_port_5_cell3_10318}           ${tl.attenuator[1].attenuator_ports[5]}
${att_port_6_cell3_10318}           ${tl.attenuator[1].attenuator_ports[6]}
${att_port_7_cell3_10318}           ${tl.attenuator[1].attenuator_ports[7]}
${att_port_8_cell3_10318}           ${tl.attenuator[1].attenuator_ports[8]}
${att_port_9_ENBcell1_10318}        ${tl.attenuator[1].attenuator_ports[9]}
${att_port_10_ENBcell1_10318}       ${tl.attenuator[1].attenuator_ports[10]}
${att_port_11_ENBcell2_10318}       ${tl.attenuator[1].attenuator_ports[11]}
${att_port_12_ENBcell2_10318}       ${tl.attenuator[1].attenuator_ports[12]}
${second_retry_after_failed}        M60_and_retry_after_failed.pcap

*** Keywords ***
CB012544_FDD_suite_setup
    Common Suite Setup for COAM
    ${release_info}    Get sagnb release    host=${GNB2_host}
    set suite variable    ${release_info}
    Get_TL_Number
    Get_Branch_Number
    NRCellid Set suit varaible    cellid=${1}    gnb_index=${1}
    ${nrcellid2}    NRCellid Set suit varaible    cellid=${2}    gnb_index=${1}
    set suite variable    ${nrcellid2}

_prepare_argument_for_12544
    [Arguments]     ${golden_scf}=${TL2_ID}_${release_info}.xml
    ...     ${gnb_index}=${1}    ${amf_id}=${2}    ${scf_path}=${scf_path_12544}
    ${AMF_IPaddr}    Get AMF from SCF     golden_scf_name=${golden_scf}
    ...         gnb_index=${gnb_index}    amf_id=${amf_id}    scf_path=${scf_path}
    set suite variable    ${AMF_IPaddr}

#    setup_simulation_core_network


CB012544_FDD_suite_teardown
    [Arguments]     ${M_before}=True
    ...             ${golden_scf}=${TL2_ID}_${release_info}.xml
    ...             ${ParamterToModify}='NULL'
    ...             ${ListParamterToModify}='NULL'
    ...             ${If_swconfig}=True
    ...             ${swconfig_file}=${swconfig_file}
    ...             ${swconfig_modify}=${None}
    BuiltIn.run keyword and ignore error     Adjust the HBTE attenuation value for 12544
    BuiltIn.run keyword and ignore error
    ...     Common Case TestLine Setup     ModifySCF_Beforecommission_GNB2=${M_before}
    ...                                    scf_path=${scf_path_12544}
    ...                                    golden_scf_name_gnb2=${golden_scf}
    ...                                    ParamterToModify_gnb2=${ParamterToModify}
    ...                                    ListParamterToModify_gnb2=${ListParamterToModify}
    ...                                    Is_Swconfig_for_GNB2=${If_swconfig}
    ...                                    swconfig_file_gnb2=${swconfig_file}
    ...                                    swconfig_modify_gnb2=${swconfig_modify}
    Common Suite Teardown for COAM


SG3_12544_case_setup
    [Arguments]     ${M_before}=False
    ...             ${online_ModifySCF}=False
    ...             ${golden_scf}=None
    ...             ${ParamterToModify}='NULL'
    ...             ${ListParamterToModify}='NULL'
    ...             ${Modify_Para_Online}='NULL'
    ...             ${Delete_Mo_Online}='NULL'
    ...             ${Delete_Para_Online}='NULL'
    ...             ${If_swconfig}=False
    ...             ${swconfig_file}=${None}
    ...             ${swconfig_modify}=${None}
    ...             ${cellid}=${1}
    ...             ${gnb2_cell1_value}=${10}
    ...             ${allow_fault_list}=${12544_allow_fault_list}
    robot_common_operations.Common Case Setup    allowed_faults_ids=7107,1898,4405,4404
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    NRCellid Set suit varaible     gnb_index=${1}    cellid=${cellid}
    Common Case TestLine Setup     ModifySCF_Beforecommission_GNB2=${M_before}
    ...                            scf_path=${scf_path_12544}
    ...                            golden_scf_name_gnb2=${golden_scf}
    ...                            ParamterToModify_gnb2=${ParamterToModify}
    ...                            ListParamterToModify_gnb2=${ListParamterToModify}
    ...                            ModifySCF_Aftercommission_for_GNB2=${online_ModifySCF}
    ...                            Modify_Para_Online_GNB2=${Modify_Para_Online}
    ...                            Delete_Para_Online_GNB2=${Delete_Para_Online}
    ...                            Delete_Mo_Online_GNB2=${Delete_Mo_Online}
    ...                            Is_Swconfig_for_GNB2=${If_swconfig}
    ...                            swconfig_file_gnb2=${swconfig_file}
    ...                            swconfig_modify_gnb2=${swconfig_modify}
    Adjust the HBTE attenuation value for 12544    gnb2_cell1_value=${gnb2_cell1_value}




SG3_12544_case_teardown
    [Arguments]     ${gnb_index}=${1}
    robot_common_operations.Common Case Teardown
    run keyword and ignore error    COAM Save snapshot via api     gnb_index=${gnb_index}
    run keyword and ignore error    MTK60 UE Detach     ue_index=${2}
#    run keyword and ignore error    stop_capture_btslogs
    run keyword and ignore error    Close the iperf process on APPserver    port=${UE_DL_port}
    run keyword and ignore error    Adjust the HBTE attenuation value for 12544
    Run keyword and ignore error    Teardown the all connections
    Run keyword and ignore error    CI_interface.Common Case Teardown



Get AMF from SCF
    [Arguments]       ${golden_scf_name}    ${gnb_index}=${1}    ${amf_id}=${2}    ${scf_path}=${scf_path_12544}
    scf.Load scf    ${scf_path}/${golden_scf_name}
    ${AMF_IPaddr}=    scf.get_value_from_scf
    ...    dist_name=MRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/SERVEDAMF-${amf_id}
    ...    p_name=amfIPAddress
    [Return]     ${AMF_IPaddr}

Get_TL_Number
    run keyword if    '${MRBTS2_ID}' == '34412'    Set Suite Variable    ${TL2_ID}    TL344_GNB2
    run keyword if    '${MRBTS_ID}' == '34411'    Set Suite Variable    ${TL1_ID}    TL344_GNB1
    run keyword if    '${MRBTS_ID}' == '10318'    Set Suite Variable    ${TL_ID}    TL362

Get_Branch_Number
    run keyword if    '${release_info}' == 'SBTS25R2_ENB_9999'    Set Suite Variable     ${branch_ID}    TRUNK
    run keyword if    '${release_info}' == 'SBTS25R1_ENB_0000'    Set Suite Variable     ${branch_ID}    25R1

#### --------------------------------------------------CLOUD VM--------------------------------------------------------------------####
CB012544_FDD_suite_setup_CLOUD_VM
    [Arguments]     ${If_swconfig}=True
    ...             ${swconfig_modify}=${swconfig_12544}
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
    ${nrcellid3}    NRCellid Set suit varaible    cellid=${3}    gnb_index=${0}
    set suite variable    ${nrcellid3}
    ${nrcell3_pci}    get physicalCellId from coam_gnb_classical    lcrid=${3}
    set suite variable    ${nrcell3_pci}
    Common Case TestLine Setup     Is_Swconfig=${If_swconfig}
    ...                            swconfig_target_path=${SUITE_LOG_PATH}/swconfig.txt
    ...                            swconfig_file=${Golden_SCF_Path}/swconfig.txt
    ...                            swconfig_modify=${swconfig_modify}
    ...                            ModifySCF_Beforecommission=True
    ...                            scf_dir_path=${SUITE_LOG_PATH}
    ...                            scf_path=${Golden_SCF_Path}
    ...                            golden_scf_name=SCF_${stream}.xml
    ...                            ParameterToDelete=${delete_for_FDD}
    ...                            ParamterToModify=${modify_for_FDD}
    ...                            ListToAdd=${addlist_for_FDD}

GET_CLOUD_UTE_SCF_PATH
    [Arguments]     ${gnb_index}=0
    ...    ${cur_relative_dir}=testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB012544_FDD/Resources
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

get physicalCellId from coam_gnb_classical
    [Documentation]    jia-rebecca.liu additional method get physicalCellId
    [Arguments]    ${lcrid}=1    ${gnb_index}=${0}    #${connection}=GNB_OAM
    Wait Until Keyword Succeeds    5m    10s    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    &{config_info}    Create dictionary
    &{NR_CELL_ID_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids    gnb_index=${gnb_index}
    ${physicalCellId}    set variable    ${NR_CELL_ID_MAPPING[${lcrid}]['physicalCellId']}
    [Return]    ${physicalCellId}
    [Teardown]    COAM Teardown gnb connections

CB012544_FDD_suite_teardown_CLOUD_VM
    CI_interface.Common Case Teardown
    Run Keyword And Ignore Error    change_sync_output_configuration_VM    Modify_Para_Online=${Recovery_output_sync}
    BuiltIn.run keyword and ignore error    Adjust the HBTE attenuation value for cloud vm
    Common Suite Teardown for COAM    log_path=${OUTPUT_DIR}

SG3_12544_case_setup_cloud_vm
    [Arguments]     ${ModifySCF_Beforecommission}=False
    ...             ${online_ModifySCF}=False
    ...             ${ParamterToModify}='NULL'
    ...             ${ListParamterToModify}='NULL'
    ...             ${Modify_Para_Online}='NULL'
    ...             ${Delete_Mo_Online}='NULL'
    ...             ${Add_Para_Online}='NULL'
    ...             ${Delete_Para_Online}='NULL'
    ...             ${cellid}=${3}
    ...             ${gnb_cell3_value_MTK60}=${30}
    ...             ${allow_fault_list}=${12544_allow_fault_list_VM}
    robot_common_operations.Common Case Setup    allowed_faults_ids=4153
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Generate test case log path
    NRCellid Set suit varaible     gnb_index=${0}    cellid=${cellid}
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
    Adjust the HBTE attenuation value for cloud vm    gnb_cell3_value_MTK60=${gnb_cell3_value_MTK60}

SG3_12544_case_teardown_VM
    robot_common_operations.Common Case Teardown
    run keyword and ignore error    COAM Save snapshot via api    log_path=${TS_CASE_LOG_PATH}
    run keyword and ignore error    MTK60 UE Detach     ue_index=${4}
    run keyword and ignore error    Close the iperf process on APPserver    port=${UE_DL_port}
    run keyword and ignore error    Adjust the HBTE attenuation value for cloud vm
    run keyword and ignore error    COAM eNB Reset site via api
    Run keyword and ignore error    Teardown the all connections
    Run keyword and ignore error    CI_interface.Common Case Teardown

delete_MO_and_return_scf_path
    [Arguments]    ${scf_path}    ${parameters_lists}    ${after_delete_scf_path}
    scf.load_scf    file_path=${scf_path}
    FOR    ${item}    IN    @{parameters_lists}
        ${res_dist_name}=    Run Keyword And Ignore error    set suite variable    ${dist_name_to_delete}   ${item}[dist_name]
        ${res_list_name}=    Run Keyword And Ignore error    set suite variable    ${list_name_to_delete}   ${item}[list_name]
        ${res_p_name}=    Run Keyword And Ignore error    set suite variable    ${p_name_to_delete}   ${item}[p_name]
        Run Keyword If   ${res_p_name}== ('PASS', None)
        ...              Run Keyword And Ignore error    scf.Remove Element From Scf    &{item}
        Run Keyword If   ${res_list_name}== ('PASS', None) and ${res_p_name}!= ('PASS', None)
        ...              Run Keyword And Ignore error    scf.remove_list_from_scf    dist_name=${item}[dist_name]   list_name=${item}[list_name]
        Run Keyword If   ${res_list_name}!= ('PASS', None) and ${res_p_name}!= ('PASS', None)
        ...              Run Keyword And Ignore error    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    scf.save_scf    file_path=${after_delete_scf_path}



#### ------------------------MTK 60----------------------------- ####
MTK60 prepare UE
    [Arguments]    ${ue_index}=${2}    ${ue_type}=${ue_type_MTK60}
    run keyword If    '${MRBTS2_ID}'== '${gnb_id}[0]'    MTK60 UE reboot    ue_index=${ue_index}
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}

MTK60 prepare UE for VM
    [Arguments]    ${ue_index}=${4}    ${ue_type}=${ue_type_MTK60_VM}    ${tcpdump_collector_name}=${attach_WA_log}
    MTK60 UE reboot    ue_index=${ue_index}
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    ute_ue.enable_edrx_setting    UE_${ue_index}    ${True}
    ute_ue.set_nr_edrx    UE_${ue_index}    2048    640
    sleep    10s    reason=waiting for ATcommand send.
    MTK60 before attach do some workaround    tcpdump_collector_name=${tcpdump_collector_name}

MTK60 before attach do some workaround
    [Arguments]    ${tcpdump_collector_name}=${attach_WA_log}    ${gnb_index}=${0}    ${ue_index}=${4}
    ...            ${ue_type}=${ue_type_MTK60_VM}    ${mtk_timeout}=${90}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    ${attach_status}    run keyword and return status    MTK60 attach WA for B66    ue_index=${ue_index}    timeout=${mtk_timeout}
    Log To Console    ${\n}attach_status:${attach_status}
    [Teardown]    run keywords
    ...    Stop and download the wiresharklog from master for VM    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    ...    AND    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

MTK60 attach WA for B66
    [Arguments]    ${ue_index}    ${timeout}=${90}    ${ue_type}=mtk    ${gnb_index}=${0}    ${ue_alias}=UE_${ue_index}
    ${mtk_timeout}    Evaluate    int(${timeout})
    Wait Until Keyword Succeeds    5 min    1min     power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
    ...                                                                    ue_alias=${ue_alias}    timeout=${mtk_timeout}

MTK60 UE reboot
    [Arguments]    ${ue_index}=${2}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep    5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} reboot   connection=cygwin
    sleep    10s
    Wait Until Keyword Succeeds    3 min    10s    Connect ADB devices    alias=cygwin
    ...                                                                   serial_number=${tl.ues[${ue_index}].serial_number}
    [Teardown]    csn.disconnect      connection=cygwin

MTK60 UE Attach
    [Arguments]    ${ue_index}     ${tcpdump_collector_name}    ${ue_type}=mtk    ${gnb_index}=${1}    ${ue_alias}=UE_${ue_index}
    ...      ${timeout}=15
    ${mtk_timeout}    Evaluate    int(${timeout})
    ${attach_status}    run keyword and return status    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
    ...                 ue_alias=${ue_alias}    timeout=${mtk_timeout}
    run keyword if     '${attach_status}' == 'False'    MTK60 reattach after failed    ue_type=${ue_type}    ue_index=${ue_index}
    ...                                                 gnb_index=${gnb_index}    ue_alias=${ue_alias}    timeout=${mtk_timeout}
    ...                                                 tcpdump_collector_name=${tcpdump_collector_name}


MTK60 reattach after failed
    [Arguments]    ${ue_index}    ${ue_type}    ${gnb_index}    ${ue_alias}    ${timeout}
    ...    ${tcpdump_collector_name}    ${second_retry_after_failed}=${second_retry_after_failed}
    Stop and download the wiresharklog from master for VM    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
#    MTK60 UE reboot    ue_index=${ue_index}
#    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    MTK60 before attach do some workaround    tcpdump_collector_name=${second_retry_after_failed}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
#    ute_ue.enable_edrx_setting    UE_${ue_index}    ${True}
#    ute_ue.set_nr_edrx    UE_${ue_index}    2048    640
#    sleep    30s    reason=waiting for ATcommand send.
    ${mtk_timeout}    Evaluate    int(${timeout})
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
    ...                   ue_alias=${ue_alias}    timeout=${mtk_timeout}


MTK60 UE Detach
    [Arguments]    ${ue_index}    ${ue_type}=mtk
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    5s

Get IP address from wireshark log and set ue_port
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: get UE IP and set UE port
    [Arguments]    ${get_ip_from_cpif}    ${ue_index}=${2}
    ${pdu_ip_dnn_dict}     Common_keywords.Get ALL PDU IP Address From Wireshark     cpif_log_path=${get_ip_from_cpif}
    ${ue_dl_port}    Set Variable    ${tl.ues[${ue_index}].iperf_details.port}
    Set Test Variable    ${DL_PORT}    ${ue_dl_port}
    [Return]     ${DL_PORT}    ${pdu_ip_dnn_dict}[data]


Start DL traffic for MTK60
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: Start DL traffic and capture Biplog for MTK80
    [Arguments]    ${get_ip_from_cpif}
    ...            ${dl_data_transfer}=1M
    ...            ${duration}=600
    ...            ${ue_index}=${2}
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

Check tput for MTK60
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                Description: Check dl traffic for MTK80
    [Arguments]     ${ue_index}=${2}
    ...             ${gnb_index}=${1}
    ...             ${cellid}=${nrcellid}
    ...             ${duration}=30
    ...             ${direction}=DL
    ...             ${target_throughput}=1
    ${list_of_cell_ids}    Create list    ${cellid}
    ${tput_file}    power_ue.Collect Tput    ue_type=${ue_type_MTK60}     duration=${duration}    gnb_index=${gnb_index}    ue_index=${ue_index}
    ${output}    power_ue.Check Tput    ue_type=${ue_type_MTK60}    direction=${direction}    cells=${list_of_cell_ids}
    ...                                 target_throughput=${target_throughput}    log=${tput_file}    ue_index=${ue_index}

_start_traffic_trigger_paging
    [Arguments]     ${target_file_name}
    ...             ${tcpdump_collector_name}=${C_001_wireshark_paging}
    ...             ${get_ip_from_cpif}=${C_001_wireshark_attach}
    ...             ${gnb_index}=${1}
    ...             ${dl_traffic}=1M
    ...             ${ue_index}=${2}
    ...             ${target_throughput}=1
    ...             ${cellid}=${nrcellid}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gNB_index}
    Prepare to caculate PM counter     period=start
#    Start Interface Mirroring Bip Collector     target_file_name=${target_file_name}    gnb_index=${gnb_index}
    Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}    interface=L1-L2
    ...                                          host_ip=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...                                          username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...                                          password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    Start DL traffic for MTK60      get_ip_from_cpif=${get_ip_from_cpif}    dl_data_transfer=${dl_traffic}
    sleep    10s    reason=wait for a while after start traffic.
#    ${C_001_bip_paging}    Stop and collect Bip Log Via Interface Mirroring Collector from WEBUI      target_file_name=${target_file_name}
    ${C_001_bip_paging}     Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}    target_dir=${epc_log_path}
    Check tput for MTK60     ue_index=${ue_index}     target_throughput=${target_throughput}    cellid=${cellid}
    Prepare to caculate PM counter       period=end
    [Teardown]     Run Keywords
    ...    Stop and download the wiresharklog from master    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
#    ...    AND    Run keyword and ignore error     Stop Bip Log Via Interface Mirroring Collector from WEBUI     target_file_name=${target_file_name}
    ...    AND    Close the iperf process on APPserver    port=${DL_PORT}
    ...    AND    MTK60 UE Detach     ue_index=${2}
    [Return]     ${cpif_log_path}     ${C_001_bip_paging}[0]

_start_simulator_and_traffic
    [Arguments]     ${target_file_name}    ${paging_command}    ${dl_port}    ${ue_addr}
    ...             ${tcpdump_collector_name}=${C_001_wireshark_paging}
    ...             ${gnb_index}=${1}
    ...             ${action_mode}=tput_paging
    ...             ${Simulation_IP}=${AMF_IPaddr}
    ...             ${dl_time}=300
    ...             ${dl_traffic}=1M
    ...             ${dl_length}=1024B
    ...             ${ue_index}=${1}
    ...             ${target_throughput}=1
    ...             ${cellid}=${nrcellid}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gNB_index}
    Prepare to caculate PM counter     period=start
    Start Interface Mirroring Bip Collector     target_file_name=${target_file_name}    gnb_index=${gnb_index}
    start_traffic_and_paging     action_mode=${action_mode}    Simulation_IP=${Simulation_IP}
    ...                          paging_command=${paging_command}    dl_port=${dl_port}
    ...                          ue_addr=${ue_addr}     dl_time=${dl_time}
    ...                          dl_throughput=${dl_traffic}    dl_length=${dl_length}
    ${C_001_bip_paging}    Stop and collect Bip Log Via Interface Mirroring Collector from WEBUI      target_file_name=${target_file_name}
    Check tput for MTK60     ue_index=${ue_index}     target_throughput=${target_throughput}     cellid=${cellid}
    Prepare to caculate PM counter       period=end
    [Teardown]     Run Keywords
    ...    Stop and download the wiresharklog from master    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
#    ...    AND    Run keyword and ignore error     Stop Bip Log Via Interface Mirroring Collector from WEBUI     target_file_name=${target_file_name}
    ...    AND    Close the iperf process on APPserver    port=${DL_PORT}
    ...    AND    MTK60 UE Detach     ue_index=${2}
    [Return]     ${cpif_log_path}     ${C_001_bip_paging}[0]

_UE_attach_and_enter_idle
    [Arguments]     ${ue_index}=${2}
    ...             ${gnb_index}=${1}
    ...             ${tcpdump_collector_name}=${C_001_wireshark_attach}
    ...             ${sleep_time}=25s
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    MTK60 UE Attach    ue_index=${ue_index}    gnb_index=${gnb_index}    tcpdump_collector_name=${tcpdump_collector_name}
    sleep    ${sleep_time}        reason=wait for ue into idle status.
    [Teardown]    Stop and download the wiresharklog from master    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    [Return]      ${cpif_log_path}

_UE_attach_and_enter_RRC_inactive
    [Arguments]     ${ue_index}=${2}
    ...             ${gnb_index}=${1}
    ...             ${tcpdump_collector_name}=${C_001_wireshark_attach}
#    ...             ${second_attach}=False
    Start capture cpif_wireshark log on node     filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    run keyword and ignore error     MTK60 UE Attach    ue_index=${ue_index}    gnb_index=${gnb_index}
    ...                                                 tcpdump_collector_name=${tcpdump_collector_name}
    sleep    20s        reason=wait for ue into rrc_inactive status.
    [Teardown]    Stop and download the wiresharklog from master    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    [Return]      ${cpif_log_path}

_UE_attach_and_enter_RRC_inactive_VM
    [Arguments]     ${ue_index}=${4}
    ...             ${gnb_index}=${0}
    ...             ${tcpdump_collector_name}=${C_001_wireshark_attach}
#    ...             ${second_attach}=False
    ...             ${sleep_time}=30s
    MTK60 before attach do some workaround    tcpdump_collector_name=${enter_rrcinactive_WA}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    MTK60 UE Attach    ue_index=${ue_index}    gnb_index=${gnb_index}    tcpdump_collector_name=${tcpdump_collector_name}
    sleep    ${sleep_time}        reason=wait for ue into rrc_inactive status.
    [Teardown]    Stop and download the wiresharklog from master for VM    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    [Return]      ${cpif_log_path}

_UE_attach_and_enter_idle_VM
    [Arguments]     ${ue_index}=${4}
    ...             ${gnb_index}=${0}
    ...             ${tcpdump_collector_name}=${C_001_wireshark_attach}
    ...             ${sleep_time}=30s
#    ...             ${adddition_pdn}=dxdata1
#    ...             ${second_attach}=True
    ...             ${timeout}=15
    ...             ${mtk_timeout}=90
    MTK60 before attach do some workaround    tcpdump_collector_name=${enter_idle_WA}    mtk_timeout=${mtk_timeout}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    Log To Console    ${\n}INFO:-- start to attach --
    ${timeout}    Evaluate    int(${timeout})
    MTK60 UE Attach    ue_index=${ue_index}    gnb_index=${gnb_index}    tcpdump_collector_name=${tcpdump_collector_name}
    sleep     ${sleep_time}        reason=wait for ue into idle status.
    [Teardown]    Stop and download the wiresharklog from master for VM    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    [Return]      ${cpif_log_path}

_start_traffic_trigger_paging_VM
    [Arguments]     ${target_file_name}
    ...             ${tcpdump_collector_name}=${C_001_wireshark_paging}
    ...             ${get_ip_from_cpif}=${C_001_wireshark_attach}
    ...             ${gnb_index}=${0}
    ...             ${dl_traffic}=1M
    ...             ${ue_index}=${4}
    ...             ${target_throughput}=1
    ...             ${cellid}=${nrcellid3}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gNB_index}
    Prepare to caculate PM counter     period=start
    Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}    interface=L1-L2
    ...                                          host_ip=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...                                          username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...                                          password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    sleep    3s    reason=wait for a while after start biplog capture.
    Start DL traffic for MTK60      get_ip_from_cpif=${get_ip_from_cpif}    dl_data_transfer=${dl_traffic}    ue_index=${ue_index}
    sleep    10s    reason=wait for a while after start traffic.
    ${C_001_bip_paging}     Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}    target_dir=${TS_CASE_LOG_PATH}
    Check tput for MTK60     ue_index=${ue_index}     target_throughput=${target_throughput}    cellid=${cellid}    gnb_index=${gnb_index}
    Prepare to caculate PM counter       period=end
    [Teardown]     Run Keywords
    ...    Stop and download the wiresharklog from master for VM    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    ...    AND    Close the iperf process on APPserver    port=${DL_PORT}
    ...    AND    MTK60 UE Detach     ue_index=${ue_index}
    [Return]     ${cpif_log_path}     ${C_001_bip_paging}[0]

### -----------------------------------PA------------------------------------------------##
Adjust the HBTE attenuation value for 12544
    [Arguments]     ${tl}=${MRBTS2_ID}
    ...     ${gnb2_cell1_value}=${127}     ${gnb2_cell2_value}=${127}
    ...     ${gnb1_cell3_value}=${127}
    ...     ${enb_cell0_value}=${127}      ${enb_cell1_value}=${127}

    ####create cell list#####
    @{att_ports_gnb2_cell1}    Create List    ${att_port_5_cell1_${tl}}      ${att_port_7_cell1_${tl}}
    @{att_ports_gnb2_cell2}    Create List    ${att_port_6_cell2_${tl}}      ${att_port_8_cell2_${tl}}
    @{att_ports_gnb1_cell3}    Create List    ${att_port_10_cell3_${tl}}      ${att_port_12_cell3_${tl}}

    ####create cell list#####
    @{att_ports_enb_cell0}    Create List    ${att_port_enb_cell0_${tl}}
    @{att_ports_enb_cell1}    Create List    ${att_port_enb_cell1_${tl}}     ${att_port_enb_cell2_${tl}}

    ###create value list####
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_gnb2_cell2}    Create List    ${gnb2_cell2_value}    ${gnb2_cell2_value}
    @{values_gnb1_cell3}    Create List    ${gnb1_cell3_value}    ${gnb1_cell3_value}

    ###create value list####
    @{values_enb_cell0}    Create List    ${enb_cell0_value}
    @{values_enb_cell1}    Create List    ${enb_cell1_value}     ${enb_cell1_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell2}    values=${values_gnb2_cell2}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell3}    values=${values_gnb1_cell3}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
    Set the attenuation value    att_ports=${att_ports_enb_cell0}    values=${values_enb_cell0}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
    Set the attenuation value    att_ports=${att_ports_enb_cell1}    values=${values_enb_cell1}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}


Adjust the HBTE attenuation value for cloud vm
    [Arguments]     ${tl}=${MRBTS_ID}    ${gnb_cell1_value}=${127}     ${gnb_cell3_value}=${127}    ${gnb_cell3_value_MTK60}=${127}
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
    @{values_gnb_cell3}    Create List    ${gnb_cell3_value}    ${gnb_cell3_value}
    @{values_gnb_cell3_MTK60}    Create List    ${gnb_cell3_value_MTK60}    ${gnb_cell3_value_MTK60}
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

# =============================LOG Capture============================= #
Start capture wireshark log on master
    [Arguments]    ${filename}    ${gNB_index}=${0}    ${interface}=any
    wait until keyword succeeds    1min   10s    Connect gNB    gNB_index=${gNB_index}
    sleep    3s
    csn.send command    command=tcpdump -i ${interface} -p sctp -w ${gnb_path}${filename}    connection=gNB${gNB_index}
	sleep    3s
    [Teardown]    csn.disconnect    connection=gNB${gNB_index}

Stop and download the wiresharklog from master
    [Arguments]    ${filename}    ${gNB_index}=${0}
    wait until keyword succeeds    1min   10s    Connect gNB    gNB_index=${gNB_index}
    csn.send command    command=killall tcpdump     connection=gNB${gNB_index}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${filename}   local_path=${epc_log_path}${filename}   connection=gNB${gNB_index}
    sleep    3
    set suite variable     ${cpif_log_path}      ${epc_log_path}${filename}
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

Stop and download the wiresharklog from master for VM
    [Arguments]    ${filename}    ${gNB_index}=${0}
    wait until keyword succeeds    1min   10s    Connect gNB    gNB_index=${gNB_index}
    csn.send command    command=killall tcpdump     connection=gNB${gNB_index}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${filename}   local_path=${TS_CASE_LOG_PATH}/${filename}   connection=gNB${gNB_index}
    sleep    3
    set suite variable     ${cpif_log_path}      ${TS_CASE_LOG_PATH}/${filename}
    [Teardown]    csn.disconnect    connection=gNB${gNB_index}
    [Return]     ${cpif_log_path}


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
    [Arguments]     ${UTE_syslogs_path}=${epc_log_path}
    ...             ${btslog_path}=/tmp/btslog2
    ...             ${btslog_launcher}=/opt/btslog/btslog_launcher
    ...             ${btslog_launcher_path}=/opt/btslog/btslog
    Stop BTSlogs Collection And Download Logs To Log Server
    ...        UTE_syslogs_path=${UTE_syslogs_path}
    ...        btslog_path=${btslog_path}
    ...        btslog_launcher=${btslog_launcher}
    ...        btslog_launcher_path=${btslog_launcher_path}

send_paging_command_during_bip_collect
    [Arguments]     ${target_file_name}    ${paging_command}
    ...     ${gnb_index}=${1}     ${simulation_IP}=${AMF_IPaddr}
    Start Interface Mirroring Bip Collector     target_file_name=${target_file_name}    gnb_index=${gnb_index}
    send_CMD_simulation_core_network    SIMUL_send_command=${paging_command}    simulation_IP=${simulation_IP}
    sleep    3s
    ${bip_paging}    Stop and collect Bip Log Via Interface Mirroring Collector from WEBUI      target_file_name=${target_file_name}
    [Return]     ${bip_paging}[0]
    [Teardown]     MTK60 UE Detach     ue_index=${2}

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
#    ...            ${command_template}={tshark_path} -r {file_path} -Y \"${filter}\" -T pdml
    ...            ${alias}=parser
#    ${command_template}    Catenate    ${tshark_path} -r ${file_path} -Y \"${filter}\" -T pdml
    ${command_template}    Catenate    tshark -o nas-5gs.null_decipher:TRUE -r ${file_path} -Y \"${filter}\" -T pdml

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

Get Captured BIP File from UTE for 12544
    [Documentation]    Auther: liujia
    [Arguments]    ${gnb_logs_script_path}=/opt/workspace/gnb_logs
    ...            ${target_dir}=${epc_log_path}
    ...            ${gnb_index}=${1}
    ...            ${du_index}=0
    ...            ${log_type}=BIP
    ...            ${target_file_name}=L2L1_Bip
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${all_bip_file_list}   Create List
    log to console    --- start to Download bip result to specific folder ---
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    @{bip_files}    List Files In Directory	    ${gnb_logs_script_path}	   BTS-*_${gnb_ip}_*_${log_type}.zip
    Copy Files    ${gnb_logs_script_path}/BTS-*_${gnb_ip}_*.zip    ${target_dir}
    FOR    ${bip_file}    IN    @{bip_files}
        ${file_name}    Set Variable    ${bip_file.split('.zip')[0]}
        Run    unzip ${target_dir}/${bip_file} -d ${target_dir}
        @{internal_dir} =    OperatingSystem.List Directories In Directory    ${target_dir}/${file_name}
        ${isEmpty}    Run Keyword And Return Status       should be empty       ${internal_dir}
        ${bip_dir}    set variable if    ${isEmpty}      ${target_dir}/${file_name}   ${target_dir}/${file_name}/${internal_dir}[0]
        ${specific_bip_file}    List Files In Directory    ${bip_dir}
        ...                                                *Bip*.pcap*
        ...                                                absolute=${True}
        ${all_bip_file_list}     Combine Lists     ${specific_bip_file}    ${all_bip_file_list}
    END
    log to console    all captured bip file list : ${all_bip_file_list}
    ${bipfile_num}=    get length    ${all_bip_file_list}
    FOR    ${index}    IN RANGE    ${bipfile_num}
        ${next_index}    Evaluate    ${index}+1
        Run Keyword If    '${index}'=='0'    OperatingSystem.Run   command=cd ${target_dir}/${file_name};touch test_${index}.pcap
        OperatingSystem.Run
        ...    command=cd ${target_dir}/${file_name};mergecap -w test_${next_index}.pcap test_${index}.pcap ${all_bip_file_list[${index}]}
    END
    ${status}    Run Keyword And Return Status
    ...    OperatingSystem.Run   command=cd ${target_dir}${file_name};cp test_${next_index}.pcap ${target_file_name}.pcap
    Run Keyword If    ${status}    OperatingSystem.Run   command=cd ${target_dir}${file_name};rm test_*.pcap
    ${full_log_path}    Set Variable    ${target_dir}${/}${file_name}${/}${target_file_name}.pcap
    [Return]     ${full_log_path}
    [Teardown]    Run Keyword And Ignore Error    Run    rm ${gnb_logs_script_path}/BTS-*_${gnb_ip}_*_${log_type}.zip



Get short_message from PdcchSendReq
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ...            ${bip_filter}=dldata_pdcchsendreq
    ${xpath}      Catenate     .//dci.dci10.dci10_ShortMessages
    ${filter_expression}    Catenate     nr-phy.dci
    ${short_Message}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=${bip_filter}
    ...            filter_expression=${filter_expression}
    ...            xpath=${xpath}
    ...            attribute_name=show
    ${short_Message}    Remove Duplicates     ${short_Message}
    [Return]    ${short_Message}

Get eDRX_idle from PdcchSendReq
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ...            ${bip_filter}=dldata_pdschpayloadtbsendreq
    ${xpath}      Catenate     .//nr-rrc.eDRX_AllowedIdle_r17
    ${filter_expression}    Catenate     nr-rrc.c1
    ${eDRX_idle}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=${bip_filter}
    ...            filter_expression=${filter_expression}
    ...            xpath=${xpath}
    ...            attribute_name=showname
    ${eDRX_idle}    Remove Duplicates     ${eDRX_idle}
    [Return]    ${eDRX_idle}

Get eDRX_inactive from PdcchSendReq
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ...            ${bip_filter}=dldata_pdschpayloadtbsendreq
    ${xpath}      Catenate     .//nr-rrc.eDRX_AllowedInactive_r17
    ${filter_expression}    Catenate     nr-rrc.c1
    ${eDRX_inactive}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=${bip_filter}
    ...            filter_expression=${filter_expression}
    ...            xpath=${xpath}
    ...            attribute_name=showname
    ${eDRX_inactive}    Remove Duplicates     ${eDRX_inactive}
    [Return]    ${eDRX_inactive}

Check DCI_1_0 Message On DlData_PdcchSendreq
    [Arguments]    ${file_path}    ${shortMessage_vlaue}=144    ${subcellid}=${0}
    [Documentation]     subcellid=0---CELL1
    run keyword if    '${release_info}' == 'SBTS25R1_ENB_0000'
    ...    Setup the Pcap File   file_path=${file_path}    filter=dldata_pdcchsendreq
    ...    ELSE    Setup the Pcap File   file_path=${file_path}    filter=dldata_pdcchsendreql1sw
    ${frame_number}    Get Field Value From PCAP_file    field_name=frame.number
    ...                                                  filter_expression=3gpp.rnti==65534 && 3gpp.subcellid == ${subcellid}
    ${frame_number_new}    Evaluate   [int(x[0]) for x in ${frame_number}]
    ${frame_number_max}    Evaluate   max(${frame_number_new})
    ${frame_number_max}    Evaluate   str(${frame_number_max})
    ${short_messages}    Get Field Value From PCAP_file    field_name=dci.dci10.dci10_ShortMessages
    ...                                    filter_expression=3gpp.rnti==65534 && frame.number==${frame_number_max} && 3gpp.subcellid == ${subcellid}
    ${epoch_time}    Get Field Value From PCAP_file    field_name=frame.time_epoch
    ...                                    filter_expression=3gpp.rnti==65534 && frame.number==${frame_number_max} && 3gpp.subcellid == ${subcellid}
    Should Be True    ${short_messages[0][0]}==${shortMessage_vlaue}
    ...    msg=shortMessage_vlaue is not ${shortMessage_vlaue}, actual is ${short_messages}.
    [Return]    ${frame_number[-1][0]}    ${epoch_time[0][0]}

Deal With Pcap File for frame_max
    [Arguments]    ${file_path}    ${frame_time}
	${split_bip_log_path}    OperatingSystem.Join Path    ${TS_CASE_LOG_PATH}    Split_bip_log
#	${split_bip_log_path}    OperatingSystem.Join Path    ${epc_log_path}    Split_bip_log
    OperatingSystem.Create Directory    ${split_bip_log_path}
    Set Test Variable     ${split_bip_log_path}
    OperatingSystem.Run   command=cd ${split_bip_log_path};editcap -c 10240 ${file_path} split.pcap
    ${split_file_name}    OperatingSystem.Run   command=cd ${split_bip_log_path};ls -l | grep -i "split_" |awk '{print $9}'
    ${split_file_name_list}    Split String    ${split_file_name}    \n
    ${init_time}    Set Variable    0
    OperatingSystem.Run   command=cd ${split_bip_log_path};touch test_final.pcap
    ${final_pcap_file}    Set Variable    ${split_bip_log_path}/test_final.pcap
    FOR    ${split_file_name}    IN    @{split_file_name_list}
        ${file_start_time}    Set Variable    ${split_file_name.split('.')[0].split('_')[-1]}
        ${tmp_time}    DateTime.Convert Date    ${file_start_time}    epoch
        ${status}    Run Keyword And Return Status    Should Be True    ${init_time}<=${frame_time}<=${tmp_time}
        ${list_index}    Run Keyword If    ${status}    Get Index From List    ${split_file_name_list}    ${split_file_name}
        ${next_index}    Run Keyword If    ${status}    Evaluate    ${list_index}+1
        ${last_index}    Run Keyword If    ${status}    Evaluate    ${list_index}-1
        ${before_index}    Run Keyword If    ${status}    Evaluate    ${list_index}-2
        ${cmd}    Run Keyword If    ${status}    Catenate    cd ${split_bip_log_path};mergecap -w test_final.pcap
        ...    ${split_file_name_list[${before_index}]} ${split_file_name_list[${last_index}]}
        ...    ${split_file_name_list[${list_index}]} ${split_file_name_list[${next_index}]}
        Run Keyword If    ${status}    Run Keywords    OperatingSystem.Run   command=${cmd}    AND    Exit For Loop
        ${init_time}    Set Variable    ${tmp_time}
    END
    [Return]    ${final_pcap_file}
    [Teardown]    Run Keyword And Ignore Error    OperatingSystem.Run   command=cd ${split_bip_log_path};rm split_*.pcap

Check SIB Message Detail Information C007
    [Documentation]     from idle to idle+inactive    for cell1
    [Arguments]    ${file_path}    ${frame_time}    ${subcellid}=${0}
    Setup the Pcap File   file_path=${file_path}    filter=dldata_pdschpayloadtbsendreql1sw && 3gpp.rnti == 65535 && 3gpp.subcellid == ${subcellid}
    ${epoch_time}    Get Field Value From PCAP_file    field_name=frame.time_epoch   filter_expression=nr-rrc.c1 == 1
    ${before_time}    Set Variable    0
    FOR    ${index}    IN    @{epoch_time}
        ${status}    Run Keyword And Return Status    Should Be True    ${before_time}<${frame_time}<${index[0]}
        Run Keyword If    ${status}    Run Keywords    Set Test Variable    ${after_frame_time}    ${index[0]}    AND
        ...                                            Set Test Variable    ${before_frame_time}    ${before_time}    AND
        ...                                            Exit For Loop
        ${before_time}    Set Variable    ${index[0]}
    END
    Setup the Pcap File   file_path=${file_path}    filter=frame.time_epoch==${before_frame_time}
    ${eDRX_AllowedInactive_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17    filter_expression=${None}
    ${eDRX_AllowedIdle_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17    filter_expression=${None}
    ${hyperSFN_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedIdle_r17_value}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${hyperSFN_r17_value}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedInactive_r17_value}
    Setup the Pcap File   file_path=${file_path}    filter=frame.time_epoch==${after_frame_time}
    ${eDRX_AllowedInactive_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17    filter_expression=${None}
    ${eDRX_AllowedIdle_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17    filter_expression=${None}
    ${hyperSFN_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedInactive_r17_value1}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedIdle_r17_value1}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${hyperSFN_r17_value1}

Check SIB Message Detail Information C001
    [Documentation]     only check from none to idle
    [Arguments]    ${file_path}    ${frame_time}    ${subcellid}=${0}
    Setup the Pcap File    file_path=${file_path}
    ...    filter=dldata_pdschpayloadtbsendreql1sw && 3gpp.rnti == 65535 && 3gpp.subcellid == ${subcellid}
    ${epoch_time}    Get Field Value From PCAP_file    field_name=frame.time_epoch   filter_expression=nr-rrc.c1 == 1
    ${before_time}    Set Variable    0
    FOR    ${index}    IN    @{epoch_time}
        ${status}    Run Keyword And Return Status    Should Be True    ${before_time}<${frame_time}<${index[0]}
        Run Keyword If    ${status}    Run Keywords    Set Test Variable    ${after_frame_time}    ${index[0]}    AND
        ...                                            Set Test Variable    ${before_frame_time}    ${before_time}    AND
        ...                                            Exit For Loop
        ${before_time}    Set Variable    ${index[0]}
    END
    Setup the Pcap File   file_path=${file_path}    filter=frame.time_epoch==${before_frame_time}
    ${eDRX_AllowedInactive_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17    filter_expression=${None}
    ${eDRX_AllowedIdle_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17    filter_expression=${None}
    ${hyperSFN_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedInactive_r17_value}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedIdle_r17_value}
    Should Be Empty    ${hyperSFN_r17_value}
    Setup the Pcap File   file_path=${file_path}    filter=frame.time_epoch==${after_frame_time}
    ${eDRX_AllowedInactive_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17    filter_expression=${None}
    ${eDRX_AllowedIdle_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17    filter_expression=${None}
    ${hyperSFN_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedIdle_r17_value1}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${hyperSFN_r17_value1}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedInactive_r17_value1}

Check SIB Message Detail Information C003
    [Documentation]     from idle+inactive to idle
    [Arguments]    ${file_path}    ${frame_time}    ${subcellid}=${0}
    Setup the Pcap File   file_path=${file_path}    filter=dldata_pdschpayloadtbsendreql1sw && 3gpp.rnti == 65535 && 3gpp.subcellid == ${subcellid}
    ${epoch_time}    Get Field Value From PCAP_file    field_name=frame.time_epoch   filter_expression=nr-rrc.c1 == 1
    ${before_time}    Set Variable    0
    FOR    ${index}    IN    @{epoch_time}
        ${status}    Run Keyword And Return Status    Should Be True    ${before_time}<${frame_time}<${index[0]}
        Run Keyword If    ${status}    Run Keywords    Set Test Variable    ${after_frame_time}    ${index[0]}    AND
        ...                                            Set Test Variable    ${before_frame_time}    ${before_time}    AND
        ...                                            Exit For Loop
        ${before_time}    Set Variable    ${index[0]}
    END
    Setup the Pcap File   file_path=${file_path}    filter=frame.time_epoch==${before_frame_time}
    ${eDRX_AllowedInactive_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17    filter_expression=${None}
    ${eDRX_AllowedIdle_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17    filter_expression=${None}
    ${hyperSFN_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedInactive_r17_value}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedIdle_r17_value}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${hyperSFN_r17_value}
    Setup the Pcap File   file_path=${file_path}    filter=frame.time_epoch==${after_frame_time}
    ${eDRX_AllowedInactive_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17    filter_expression=${None}
    ${eDRX_AllowedIdle_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17    filter_expression=${None}
    ${hyperSFN_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedInactive_r17_value1}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedIdle_r17_value1}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${hyperSFN_r17_value1}

Check SIB Message Detail Information D002
    [Documentation]     only check from idle to none
    [Arguments]    ${file_path}    ${frame_time}    ${subcellid}=${0}
    Setup the Pcap File    file_path=${file_path}
    ...    filter=dldata_pdschpayloadtbsendreql1sw && 3gpp.rnti == 65535 && 3gpp.subcellid == ${subcellid}
    ${epoch_time}    Get Field Value From PCAP_file    field_name=frame.time_epoch   filter_expression=nr-rrc.c1 == 1
    ${before_time}    Set Variable    0
    FOR    ${index}    IN    @{epoch_time}
        ${status}    Run Keyword And Return Status    Should Be True    ${before_time}<${frame_time}<${index[0]}
        Run Keyword If    ${status}    Run Keywords    Set Test Variable    ${after_frame_time}    ${index[0]}    AND
        ...                                            Set Test Variable    ${before_frame_time}    ${before_time}    AND
        ...                                            Exit For Loop
        ${before_time}    Set Variable    ${index[0]}
    END
    Setup the Pcap File   file_path=${file_path}    filter=frame.time_epoch==${before_frame_time}
    ${eDRX_AllowedInactive_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17    filter_expression=${None}
    ${eDRX_AllowedIdle_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17    filter_expression=${None}
    ${hyperSFN_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedIdle_r17_value1}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${hyperSFN_r17_value1}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedInactive_r17_value1}
    Should Be Empty    ${hyperSFN_r17_value}
    Setup the Pcap File   file_path=${file_path}    filter=frame.time_epoch==${after_frame_time}
    ${eDRX_AllowedInactive_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17    filter_expression=${None}
    ${eDRX_AllowedIdle_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17    filter_expression=${None}
    ${hyperSFN_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedIdle_r17_value1}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedInactive_r17_value1}
    Run Keyword And Continue On Failure    Should Be Empty    ${hyperSFN_r17_value}

Check SIB Message Detail Information C010
    [Documentation]     from idle+inactive to none
    [Arguments]    ${file_path}    ${frame_time}    ${subcellid}=${0}
    Setup the Pcap File   file_path=${file_path}    filter=dldata_pdschpayloadtbsendreql1sw && 3gpp.rnti == 65535 && 3gpp.subcellid == ${subcellid}
    ${epoch_time}    Get Field Value From PCAP_file    field_name=frame.time_epoch   filter_expression=nr-rrc.c1 == 1
    ${before_time}    Set Variable    0
    FOR    ${index}    IN    @{epoch_time}
        ${status}    Run Keyword And Return Status    Should Be True    ${before_time}<${frame_time}<${index[0]}
        Run Keyword If    ${status}    Run Keywords    Set Test Variable    ${after_frame_time}    ${index[0]}    AND
        ...                                            Set Test Variable    ${before_frame_time}    ${before_time}    AND
        ...                                            Exit For Loop
        ${before_time}    Set Variable    ${index[0]}
    END
    Setup the Pcap File   file_path=${file_path}    filter=frame.time_epoch==${before_frame_time}
    ${eDRX_AllowedInactive_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17    filter_expression=${None}
    ${eDRX_AllowedIdle_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17    filter_expression=${None}
    ${hyperSFN_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedInactive_r17_value}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedIdle_r17_value}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${hyperSFN_r17_value}
    Setup the Pcap File   file_path=${file_path}    filter=frame.time_epoch==${after_frame_time}
    ${eDRX_AllowedInactive_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17    filter_expression=${None}
    ${eDRX_AllowedIdle_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17    filter_expression=${None}
    ${hyperSFN_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedInactive_r17_value1}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedIdle_r17_value1}
    Run Keyword And Continue On Failure    Should Be Empty    ${hyperSFN_r17_value1}

Check SIB Message Detail Information C011
    [Documentation]     from none to idle+inactive only for cell1
    [Arguments]    ${file_path}    ${frame_time}    ${subcellid}=${0}
    Setup the Pcap File   file_path=${file_path}    filter=dldata_pdschpayloadtbsendreql1sw && 3gpp.rnti == 65535 && 3gpp.subcellid == ${subcellid}
    ${epoch_time}    Get Field Value From PCAP_file    field_name=frame.time_epoch   filter_expression=nr-rrc.c1 == 1
    ${before_time}    Set Variable    0
    FOR    ${index}    IN    @{epoch_time}
        ${status}    Run Keyword And Return Status    Should Be True    ${before_time}<${frame_time}<${index[0]}
        Run Keyword If    ${status}    Run Keywords    Set Test Variable    ${after_frame_time}    ${index[0]}    AND
        ...                                            Set Test Variable    ${before_frame_time}    ${before_time}    AND
        ...                                            Exit For Loop
        ${before_time}    Set Variable    ${index[0]}
    END
    Setup the Pcap File   file_path=${file_path}    filter=frame.time_epoch==${before_frame_time}
    ${eDRX_AllowedInactive_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17    filter_expression=${None}
    ${eDRX_AllowedIdle_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17    filter_expression=${None}
    ${hyperSFN_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedInactive_r17_value}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedIdle_r17_value}
    Run Keyword And Continue On Failure    Should Be Empty    ${hyperSFN_r17_value}
    Setup the Pcap File   file_path=${file_path}    filter=frame.time_epoch==${after_frame_time}
    ${eDRX_AllowedInactive_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17    filter_expression=${None}
    ${eDRX_AllowedIdle_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17    filter_expression=${None}
    ${hyperSFN_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedInactive_r17_value1}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedIdle_r17_value1}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${hyperSFN_r17_value1}

#Check SIB Message Detail Information D001
#    [Documentation]     only check from none to idle+inactive
#    [Arguments]    ${file_path}    ${frame_time}    ${subcellid}=${0}
#    Setup the Pcap File    file_path=${file_path}
#    ...    filter=dldata_pdschpayloadtbsendreql1sw && 3gpp.rnti == 65535 && 3gpp.subcellid == ${subcellid}
#    ${epoch_time}    Get Field Value From PCAP_file    field_name=frame.time_epoch   filter_expression=nr-rrc.c1 == 1
#    ${before_time}    Set Variable    0
#    FOR    ${index}    IN    @{epoch_time}
#        ${status}    Run Keyword And Return Status    Should Be True    ${before_time}<${frame_time}<${index[0]}
#        Run Keyword If    ${status}    Run Keywords    Set Test Variable    ${after_frame_time}    ${index[0]}    AND
#        ...                                            Set Test Variable    ${before_frame_time}    ${before_time}    AND
#        ...                                            Exit For Loop
#        ${before_time}    Set Variable    ${index[0]}
#    END
#    Setup the Pcap File   file_path=${file_path}    filter=frame.time_epoch==${before_frame_time}
#    ${eDRX_AllowedInactive_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17    filter_expression=${None}
#    ${eDRX_AllowedIdle_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17    filter_expression=${None}
#    ${hyperSFN_r17_value}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
#    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedInactive_r17_value}
#    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedIdle_r17_value}
#    Run Keyword And Continue On Failure    Should Be Empty    ${hyperSFN_r17_value}
#    Setup the Pcap File   file_path=${file_path}    filter=frame.time_epoch==${after_frame_time}
#    ${eDRX_AllowedInactive_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17    filter_expression=${None}
#    ${eDRX_AllowedIdle_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17    filter_expression=${None}
#    ${hyperSFN_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
#    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedIdle_r17_value1}
#    Run Keyword And Continue On Failure    Should Not Be Empty    ${hyperSFN_r17_value1}
#    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedInactive_r17_value1}

Check user-inactivity in UEContextRR
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${inactivity_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=ngap
    ...            filter_expression=ngap.UEContextReleaseRequest_element
    ...            xpath=.//ngap.radioNetwork
    ...            attribute_name=showname
    [Return]    ${inactivity_pre}

Check rrc_release in initiatingMessage
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}    ${suspend_IE}=nr-rrc.ran_ExtendedPagingCycle_r17
    ${extendpagingcycle_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=nr-rrc.rrcRelease_element
    ...            filter_expression=nr-rrc.suspendConfig_element
    ...            xpath=.//${suspend_IE}
    ...            attribute_name=showname
    ${extendpagingcycle}     String.Split String     ${extendpagingcycle_pre}[0]    ${SPACE}
    [Return]    ${extendpagingcycle}[1]

Check EDRX_Parameters in Registration
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${element_ID}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=ngap
    ...            filter_expression=ngap.initiatingMessage_element
    ...            xpath=.//gsm_a.gm.elem_id
    ...            attribute_name=show
    ${paging_window}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=ngap
    ...            filter_expression=ngap.initiatingMessage_element
    ...            xpath=.//gsm_a.gm.gmm.paging_time_window
    ...            attribute_name=show
    ${edrx_value}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=ngap
    ...            filter_expression=ngap.initiatingMessage_element
    ...            xpath=.//gsm_a.gm.gmm.edrx_value
    ...            attribute_name=show
    should not be empty     ${element_ID}
    should not be empty     ${paging_window}
    should not be empty     ${edrx_value}
    [Return]    ${element_ID}    ${paging_window}    ${edrx_value}

Check RedCapIndication in Registration
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${RedCapIndication_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=ngap
    ...            filter_expression=ngap.initiatingMessage_element
    ...            xpath=.//ngap.RedCapIndication
    ...            attribute_name=showname
    ${RedCapIndication}     String.Split String     ${RedCapIndication_pre}[0]    ${SPACE}
    should contain    ${RedCapIndication}[1]     redcap
    [Return]     ${RedCapIndication}

Check paging_info in paging_wireshark
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${Paging_eDrx_cycle_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=f1ap
    ...            filter_expression=f1ap.Paging_element
    ...            xpath=.//f1ap.nrpaging_eDRX_Cycle_Idle
    ...            attribute_name=showname
    ${Paging_eDrx_cycle}     String.Split String     ${Paging_eDrx_cycle_pre}[0]    ${SPACE}
    ${Paging_eDrx_window_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=f1ap
    ...            filter_expression=f1ap.Paging_element
    ...            xpath=.//f1ap.nrpaging_Time_Window
    ...            attribute_name=showname
    ${Paging_eDrx_window}     String.Split String     ${Paging_eDrx_window_pre}[0]    ${SPACE}
    [Return]      ${Paging_eDrx_cycle}[1]     ${Paging_eDrx_window}[1]

Check HashID in paging_wireshark
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}    ${filter_expression}=f1ap.Paging_element
    ${Hashed_UE_ID}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=f1ap
    ...            filter_expression=${filter_expression}
    ...            xpath=.//f1ap.HashedUEIdentityIndexValue
    ...            attribute_name=value
    [Return]      ${Hashed_UE_ID}[0]

Check GNB_IP in InitialcontexSetupResponse
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]     ${file_path}     ${GNB_Address}
    ${GNB_IP_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=ngap
    ...            filter_expression=ngap.InitialContextSetupResponse_element
    ...            xpath=.//ngap.TransportLayerAddressIPv4
    ...            attribute_name=showname
    ${GNB_IP}     String.Split String     ${GNB_IP_pre}[0]    ${SPACE}
    should contain    ${GNB_IP}[2]     ${GNB_Address}
    [Return]     ${GNB_IP}

Check paging_tmsi in bip
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}    ${subcellid}
    ${xpath}      Catenate     .//nr-rrc.ng_5G_S_TMSI
    ${filter_expression}    Catenate     (dldata_pdschpayloadtbsendreql1sw and 3gpp.rnti == 65534)
    ${Paging_TMSI}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=dldata_pdschpayloadtbsendreql1sw and 3gpp.subcellid == ${subcellid}
    ...            filter_expression=${filter_expression}
    ...            xpath=${xpath}
    ...            attribute_name=value
    ${Paging_TMSI}    Remove Duplicates     ${Paging_TMSI}
    [Return]    ${Paging_TMSI}

Check short_message in bip
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${short_message_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=dldata_pdcchsendreql1sw and 3gpp.rnti == 65534
    ...            filter_expression=dci.dci_payload
    ...            xpath=.//dci.dci10.dci10_ShortMessagesIndicator
    ...            attribute_name=showname
    ${short_message_pre}    Remove Duplicates     ${short_message_pre}
    should contain     ${short_message_pre}[0]    Short Messages Indicator
    [Return]    ${short_message_pre}

Check warning_request in wireshark
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${warning_message_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=ngap
    ...            filter_expression=ngap.WriteReplaceWarningRequest_element
    ...            xpath=.//ngap.WarningMessageContents.decoded_page
    ...            attribute_name=showname
    ${warning_message}     String.Split String     ${warning_message_pre}[0]    ${SPACE}
    [Return]     ${warning_message}[-1]

Check paging_priority in wireshark
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}    ${fiveG_S_TMSI}
    ${Paging_priority_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=f1ap
    ...            filter_expression=f1ap.Paging_element and f1ap.fiveG_S_TMSI == ${fiveG_S_TMSI}
    ...            xpath=.//f1ap.PagingPriority
    ...            attribute_name=showname
    ${Paging_priority}     String.Split String     ${Paging_priority_pre}[0]    ${SPACE}
    [Return]     ${Paging_priority}[1]

Check rrc_resume in wireshark after paging
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}    ${cellid_hex}
    Setup the Pcap File   file_path=${file_path}    filter=nr-rrc.rrcResumeRequest1_element
    ${nRCellIdentity}    Get Field Value From PCAP_file    field_name=f1ap.nRCellIdentity    filter_expression=${None}    attribute_name=value
    ${nRCellIdentity}    Remove Duplicates     ${nRCellIdentity}
    Should Be Equal     ${nRCellIdentity}[0][0]     ${cellid_hex}
    ${mt_access_pre}    Get Field Value From PCAP_file    field_name=nr-rrc.resumeCause    filter_expression=${None}    attribute_name=showname
    run keyword and continue on failure     should contain x times     ${mt_access_pre}[0]     resumeCause: mt-Access (2)     1
    ${mt_access}     String.Split String     ${mt_access_pre}[0][0]    ${SPACE}
    run keyword and continue on failure     should be true     '${mt_access}[1]' == 'mt-Access'
    [Return]     ${mt_access}[1]


Check paging_priolevel in paging
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}
    ${Paging_eDrx_cycle_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=f1ap
    ...            filter_expression=f1ap.Paging_element
    ...            xpath=.//f1ap.nrpaging_eDRX_Cycle_Idle
    ...            attribute_name=showname
    ${Paging_eDrx_cycle}     String.Split String     ${Paging_eDrx_cycle_pre}[0]    ${SPACE}
    ${Paging_eDrx_window_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=f1ap
    ...            filter_expression=f1ap.Paging_element
    ...            xpath=.//f1ap.nrpaging_Time_Window
    ...            attribute_name=showname
    ${Paging_eDrx_window}     String.Split String     ${Paging_eDrx_window_pre}[0]    ${SPACE}
    ${Paging_cell_info}     Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=f1ap
    ...            filter_expression=f1ap.Paging_element
    ...            xpath=.//f1ap.nRCellIdentity
    ...            attribute_name=value


_check_user_inactivity_in_wireshark
    [Arguments]      ${file_path}
    ${user_inactivity}     Check user-inactivity in UEContextRR     file_path=${file_path}
    run keyword and continue on failure
    ...     should contain x times     ${user_inactivity}     radioNetwork: user-inactivity (20)    1
    run keyword and continue on failure
    ...     should not contain    ${user_inactivity}     radioNetwork: radio-connection-with-ue-lost (21)

_check_rrc_inactivity_in_wireshark
    [Arguments]     ${file_path}     ${parameter_list}    ${suspend_IE}=nr-rrc.ran_ExtendedPagingCycle_r17
    ...    ${dist_name}=MRBTS-${MRBTS2_ID}/NRBTS-${MRBTS2_ID}    ${gnb_index}=${1}
    ${extendedpagingcycle_1}     Check rrc_release in initiatingMessage    file_path=${file_path}    suspend_IE=${suspend_IE}
    ${ranEdrxPagingCycle_1}     Get_ranEdrxPagingCycle_from_WEBUI    parameter_list=${parameter_list}    dist_name=${dist_name}
    ...                                                              gnb_index=${gnb_index}
    ${extendedpagingcycle}      String.Get Regexp Matches     ${extendedpagingcycle_1}      \\d+
    ${ranEdrxPagingCycle}       String.Get Regexp Matches     ${ranEdrxPagingCycle_1}       \\d+
    should be equal     ${extendedpagingcycle[0]}     ${ranEdrxPagingCycle[0]}

Get_ranEdrxPagingCycle_from_WEBUI
    [Arguments]    ${parameter_list}    ${dist_name}=MRBTS-${global_bts_ID}/NRBTS-${MRBTS2_ID}     ${gnb_index}=${1}
    ${ranEdrxPagingCycle_list}    Get parameter by distname on Webui    dist_name=${dist_name}    parameter_list=${parameter_list}
    ...                                                                gnb_index=${gnb_index}
    ${ranEdrxPagingCycle}     set variable    ${ranEdrxPagingCycle_list}[0][parameters][${parameter_list[0]}]
    log to console    ${ranEdrxPagingCycle}
    [Return]    ${ranEdrxPagingCycle}

Get parameter by distname on Webui
    [Arguments]     ${dist_name}    ${parameter_list}='NULL'    ${gnb_index}=${0}    ${timeout}=300
    ...             ${detailed_output}=False    ${connection}=GNB_OAM
    wait until keyword succeeds    1min   10s    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    ${parameters}    coam.get_parameter_by_distname    dist_name=${dist_name}    parameter_list=${parameter_list}     timeout=${timeout}
    ...                               detailed_output=${detailed_output}    connection=${connection}
    [Return]     ${parameters}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections

translate cellid to hex
     [Arguments]     ${nrcellid_value}
     ${cellid_hex}    set variable
     run keyword If     ${nrcellid_value} == 563806210    BuiltIn.Set Test Variable     ${cellid_hex}     0219b00020
     ...    ELSE IF     ${nrcellid_value} == 563806209    BuiltIn.Set Test Variable     ${cellid_hex}     0219b00010
     run keyword If     ${nrcellid_value} == 169050115    BuiltIn.Set Test Variable     ${cellid_hex}     00a1380030
     log    ${cellid_hex}
     [Return]    ${cellid_hex}

Check UE_capability in wireshark
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}    ${ue_check_IE}=nr-rrc.extendedDRX_CycleInactive_r17
    ${capability_element_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=nr-rrc.UE_NR_Capability_element
    ...            xpath=.//${ue_check_IE}
    ...            attribute_name=showname
    ${capability_element}     String.Split String     ${capability_element_pre}[0]    ${SPACE}
    [Return]     ${capability_element}[1]

#### ----------------------------simulator---------------------------------#####
send_CMD_simulation_core_network
    [Documentation]     This keyword send command on simulator
    [Arguments]       ${SIMUL_send_command}     ${simulation_IP}=${AMF_IPaddr}
    csn.connect to    hostname=${simulation_IP}    username=${Test_PC_username}    password=${Test_PC_password}   alias=simulation_pc
    ${connection}    csn.get_connection_by_alias     alias=simulation_pc
    ${channel}    Call Method    ${connection}    invoke_shell
    sleep    2
    Call Method    ${channel}    send    telnet 0 20000\n
    Sleep    2
    ${enter_egate_cm}    Call Method    ${channel}    recv    ${65535}
    ${enter_egate}    Convert To String    ${enter_egate_cm}
    Should Match Regexp     ${enter_egate}    EGATE
    Sleep  2
    Call Method    ${channel}    send     ${SIMUL_send_command}\n
    Sleep  10
    Call Method    ${channel}    recv    ${65535}
    Sleep    2
    [Teardown]   csn.disconnect    connection=simulation_pc

config_simulation_core_network
    [Documentation]     This keyword config simulation core network on UTE with EGATE
    [Arguments]      ${config_command}
    ...              ${simulation_IP}=${AMF_IPaddr}
    ...               ${cfg_sim}=cfg_sim file=cnsimulator.cfg
    csn.connect to    hostname=${simulation_IP}    username=${Test_PC_username}    password=${Test_PC_password}   alias=simulation_pc
    ${connection}    csn.get_connection_by_alias     alias=simulation_pc
    ${channel}    Call Method    ${connection}    invoke_shell
    sleep    2
    Call Method    ${channel}    send    telnet 0 20000\n
    Sleep    2
    ${enter_egate_cm}    Call Method    ${channel}    recv    ${65535}
    ${enter_egate}    Convert To String    ${enter_egate_cm}
    Should Match Regexp     ${enter_egate}    EGATE
    Sleep  2
    Call Method    ${channel}    send    reset\n
    Sleep  2
    ${init_state_cm}     Call Method    ${channel}    recv    ${65535}
    Sleep  2
    ${init_state}    Convert To String    ${init_state_cm}
    Should Match Regexp     ${init_state}    INIT
    Call Method    ${channel}    send     ${cfg_sim}\n
    Sleep  30
    ${active_sm_cm}    Call Method    ${channel}    recv    ${65535}
    ${active_sm}    Convert To String    ${active_sm_cm}
    Should Match Regexp     ${active_sm}    AMF-1 is active
    Sleep    2
    Call Method    ${channel}    send    ${config_command}\n
    Sleep    5
    Call Method    ${channel}    recv    ${65535}
    Sleep    2
    [Teardown]   csn.disconnect    connection=simulation_pc

reset_simulation_core_network
    [Documentation]     This keyword config simulation core network on UTE with EGATE
    [Arguments]       ${simulation_IP}=${AMF_IPaddr}
    ...               ${cfg_sim}=cfg_sim file=cnsimulator.cfg
    csn.disconnect    connection=simulation_pc
    csn.connect to    hostname=${simulation_IP}    username=${Test_PC_username}    password=${Test_PC_password}   alias=simulation_pc
    ${connection}    csn.get_connection_by_alias     alias=simulation_pc
    ${channel}    Call Method    ${connection}    invoke_shell
    sleep    2
    Call Method    ${channel}    send    telnet 0 20000\n
    Sleep    2
    ${enter_egate_cm}    Call Method    ${channel}    recv    ${65535}
    ${enter_egate}    Convert To String    ${enter_egate_cm}
    Should Match Regexp     ${enter_egate}    EGATE
    Sleep  2
    Call Method    ${channel}    send    reset\n
    Sleep  2
    ${init_state_cm}     Call Method    ${channel}    recv    ${65535}
    Sleep  2
    ${init_state}    Convert To String    ${init_state_cm}
    Should Match Regexp     ${init_state}    INIT
    Call Method    ${channel}    send     ${cfg_sim}\n
    Sleep  30
    ${active_sm_cm}    Call Method    ${channel}    recv    ${65535}
    ${active_sm}    Convert To String    ${active_sm_cm}
    Should Match Regexp     ${active_sm}    AMF-1 is active
    Sleep    2
    Call Method    ${channel}    send    ${config_command}\n
    Sleep    5
    Call Method    ${channel}    recv    ${65535}
    Sleep    2
        Sleep  2
    ${recive_err_str}    Convert To String    ${recive_err}
    ${recive_err_check}    run keyword and return status    Should Match Regexp     ${recive_err_str}    Failed to request
    run keyword if     '${recive_err_check}' == 'True'
    ...    run keywords     MTK60 UE Detach     ue_index=${2}
    ...    AND    reset_simulation_core_network
    [Teardown]   csn.disconnect    connection=simulation_pc

stop_btoadcast_action
    [Arguments]      ${stop_command}
    ...              ${simulation_IP}=${AMF_IPaddr}
    csn.connect to    hostname=${simulation_IP}    username=${Test_PC_username}    password=${Test_PC_password}   alias=simulation_pc
    ${connection}    csn.get_connection_by_alias     alias=simulation_pc
    ${channel}    Call Method    ${connection}    invoke_shell
    sleep    2
    Call Method    ${channel}    send    telnet 0 20000\n
    Sleep    2
    ${enter_egate_cm}    Call Method    ${channel}    recv    ${65535}
    ${enter_egate}    Convert To String    ${enter_egate_cm}
    Should Match Regexp     ${enter_egate}    EGATE
    Sleep  2
    Call Method    ${channel}    send    ${stop_command}\n
    sleep   2
    [Teardown]   csn.disconnect    connection=simulation_pc

check_inactivity_status_with_simulation
    [Documentation]     This keyword config simulation core network on UTE with EGATE
    [Arguments]      ${ue_configured_status}
    ...              ${simulation_IP}=${AMF_IPaddr}
    csn.connect to    hostname=${simulation_IP}    username=${Test_PC_username}    password=${Test_PC_password}   alias=simulation_pc
    ${connection}    csn.get_connection_by_alias     alias=simulation_pc
    ${channel}    Call Method    ${connection}    invoke_shell
    sleep    2
    Call Method    ${channel}    send    telnet 0 20000\n
    Sleep    2
    ${enter_egate_cm}    Call Method    ${channel}    recv    ${65535}
    ${enter_egate}    Convert To String    ${enter_egate_cm}
    Should Match Regexp     ${enter_egate}    ${ue_configured_status}
    [Teardown]   csn.disconnect    connection=simulation_pc
