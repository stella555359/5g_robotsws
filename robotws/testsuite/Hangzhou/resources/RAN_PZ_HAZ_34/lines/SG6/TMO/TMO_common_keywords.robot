*** Settings ***
Documentation    This is for TMO common keywords.
...              Please do not modify the file without notification to author
...              Author: jun.8.chen@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/syslog_validation.robot
Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource    ./TMO_Common_Setup_And_Teardown.robot
Resource    ./TMO_common_keywords_part_one.robot
Resource    ./TMO_common_keywords_part_two.robot
Resource    ./TMO_common_keywords_part_three.robot
Resource    ./TMO_common_keywords_part_four.robot
Resource    ./TMO_common_keywords_part_five.robot
Resource    ./TMO_Reproduce_Case_Common.robot
Resource    ./TMO_KPI_Report_Case_Common.robot
Variables   ./TMO_Data.py
Library   ./4GL3call.py
Library     taf.rfrl.uuf4all.resources.python.uuf_rfrl_oam_kpi
Library    taf.sw.syslog    WITH NAME    sw_syslog
Variables   ./spark_TL73_multi_UE_config_lowTP_lowRSRP.py
Variables   ./spark_TL284_multi_UE_config_lowTP_lowRSRP.py
Variables   ./spark_TL80_multi_UE_config_lowTP_lowRSRP.py

*** Variables ***
${BASIC_SCF}    tmo_basic.xml
@{customers}             TMO US
${testline}         ${testline_name}
${ca}    VRF_HAZ4
${qc_domain}        MN_RAN
${qc_project}       RAN_VRF
${qc_set_name}    CB007835-5G-A - Key customer scenario testing - TMO TDD AEHC- Hangzhou
${case_name}    [1][1.0] 5603052_AEHC_cell_edge_case005_SA_RSRP_near_mid_far condition KPI_comparison_with RACHindex9_RACHindex206
${BTS_HOST_IP}    192.168.255.129  #  IP used in admin setup
@{wireshark_flag}    0x890073=0
@{SWCONFIG_special_flag}    0x4F0214=0
@{delete_flag}    0x4F0214

*** Keywords ***
Uplaod Default Swconfig File Before Commission
    [Documentation]    Author:lei.jia@nokia-sbell.com
    Connect to Common Unit Master
    ${scf_base_path}    String.Fetch From Left    ${CURDIR}    testsuite
    swconf.delete_parameter_of_swConfig_file    parametersList=${delete_flag}
    ...                                         filePath=${scf_base_path}commissionings/HGZ/${testline_name}/swconfig.txt
    swconf.Upload swConfig file to asik and crasign    localFilePath=${scf_base_path}commissionings/HGZ/${testline_name}/swconfig.txt
    ...    asik_alias=ASIK Master
    [Teardown]    csn.disconnect    connection=ASIK Master

Update_TMO_3CC_Configration
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${whether_get_ca_info}=${True}    ${3CC_support}=${False}
    log    ${ue_index}
    Run Keyword If    ${whether_get_ca_info} and ${3CC_support}==${False}    Get CA Related Infomation    pcell_index=${PCELL_INDEX}
    ...    ELSE IF    ${whether_get_ca_info} and ${3CC_support}    Get 3CC Related Infomation    pcell_index=${PCELL_INDEX}
    Run Keyword If    ${3CC_support}    Run Keyword And Continue On Failure    Update The Flag Whether Support 3CC    3CC_flag=${True}

TMO_Common_Case_Teardown_kpi
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${power_reset}=False    ${apn_address}=${tl.core.pdns[0].apn}
    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown
    Run Keyword If    '${ue_type}'=='huawei_sigspark'    Run Keyword And Ignore Error
    ...    Spark_common_keywords.Spark Stop UE Log    ue_index=${ue_index}
    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index}    ue_type=${ue_type}
    ...                                       apn_address=${apn_address}    power_reset=${power_reset}
    Run Keyword And Ignore Error    Stop Aasyslog And Download To TestPC    log_prefix=aasyslog
    Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=False
    Run Keyword And Ignore Error     Recover Collect Syslog On GNB

#--- Common keywords for tools---#
Clearup UTE Space while keep syslog
    [Documentation]  Author: lei.jia@nokia-sbell.com
    [Arguments]    ${alias}=test_pc
    ...            ${test_pc_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${test_pc_name}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${test_pc_password}=${tl.test_pc.default_ssh_connection_details.password}
    #--- clear gnb release software under /home/ute ---#
    Run Keyword And Ignore Error    Run    sudo rm -rf /home/ute/UUF_SW/
    Log To Console    ${\n}INFO:-- start to check and clear testPC space --
    csn.Connect to     hostname=${test_pc_ip}    username=${test_pc_name}    password=${test_pc_password}    alias=${alias}
    ${sw_build_output}    csn.execute
    ...    command=find /home/ute -name \"*release_BTSSM_downloadable_A54.zip\"
    ...    connection=${alias}
    ${sw_build_output}    Set Variable    ${sw_build_output.split('\r\n')}
    Remove From List    ${sw_build_output}    -1
    FOR    ${i}    IN    @{sw_build_output}
        csn.send command    command=rm -rf ${i}    connection=${alias}
    END
    #--- clear logs under /opt/transformers.dynamic.nsn-net.net/workspace, for 24 hours ago ---#
    csn.execute
    ...    command=cd /opt/transformers.dynamic.nsn-net.net/workspace
    ...    connection=${alias}
    ${workspace_dir}    csn.execute
    ...    command=find /opt/transformers.dynamic.nsn-net.net/workspace/ -name *5G_PZ_HZ_6_SG*
    ...    connection=${alias}
    ${workspace_dirs}   Split String    ${workspace_dir}   \r\n
    Remove From List    ${workspace_dirs}    -1
    @{WebTrigger_folders}    create list
    FOR    ${folder}    IN    @{workspace_dirs}
        ${parent_folder}    csn.execute    command=cd ${folder}/..;pwd     connection=${alias}
        ${parent_folder}     Split String    ${parent_folder}   \r\n
        append to list     ${WebTrigger_folders}    ${parent_folder[0]}
    END
    ${new_WebTrigger_folders}    Remove Duplicates   ${WebTrigger_folders}
    FOR    ${WebTrigger_folder}    IN    @{new_WebTrigger_folders}
         Compare Jenkins log modified time with current time    WebTrigger_folder=${WebTrigger_folder}
    END
    #--- clear "SYSLOG.tgz" under /home/ute ---#
    ${syslog_error_output}    csn.execute
    ...    command=find /home/ute -name "SYSLOG.tgz"
    ...    connection=${alias}
    ${syslog_error_output}    Set Variable    ${syslog_error_output.split('\r\n')}
    Remove From List    ${syslog_error_output}    -1
    FOR    ${folder}    IN    @{syslog_error_output}
         csn.send command    command=rm -rf ${folder}    connection=${alias}
    END
    #--- clear logs under /home/ute/Downloads ---#
    ${check_downloads_exist}    csn.execute
    ...    command=ls /home/ute/Downloads
    ...    connection=${alias}
    ${downloads_exist}    Run Keyword And Return Status    Should Not Contain    ${check_downloads_exist}    No such file or directory
    Run Keyword If    ${downloads_exist}    csn.execute
    ...    command=cd /home/ute/Downloads; rm -rf *
    ...    connection=${alias}

Compare Jenkins log modified time with current time
    [Documentation]    author: lei.jia@nokia-sbell.com
    [Arguments]    ${WebTrigger_folder}    ${alias}=test_pc
    # get current time, clear log before 24 hours
    ${currenttime}    DateTime.Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    ${start_time} = 	DateTime.Get Current Date 	local 	- 24 hours     result_format=timestamp
    ${start_time} = 	DateTime.Convert Date 	${start_time}    epoch

    ${folder_under_WebTrigger} = 	OperatingSystem.List Directories In Directory    ${WebTrigger_folder}
    FOR    ${log_folder}    IN    @{folder_under_WebTrigger}
        ${log_modtime} = 	OperatingSystem.Get Modified Time 	${WebTrigger_folder}/${log_folder}    epoch
        Run Keyword If    ${log_modtime} < ${start_time}    csn.send command
        ...    command=rm -rf ${WebTrigger_folder}/${log_folder}    connection=${alias}
    END


Get Syslog Start Time
    ${currenttime}    robot.libraries.DateTime.Get current date    result_format=%Y-%m-%d%H:%M:%S
    ${syslog_start_time} = 	robot.libraries.DateTime.Get Current Date 	local    result_format=timestamp
    ${syslog_start_time} = 	robot.libraries.DateTime.Convert Date 	${syslog_start_time}    epoch
    Set Test Variable    ${SYSLOG_START_TIME}    ${syslog_start_time}

Get Syslog Formatted Time
    ${currenttime}    robot.libraries.DateTime.Get current date    result_format=%Y-%m-%d%H:%M:%S
    ${syslog_start_time} = 	robot.libraries.DateTime.Get Current Date 	local    result_format=timestamp
    ${syslog_start_time} = 	robot.libraries.DateTime.Convert Date 	${syslog_start_time}    epoch
    [Return]   ${syslog_start_time}

Select ENB Index based on LTE Technology
    [Documentation]    Author: lie.jia@nokia-sbell.com
    ...     dict1 {'TDD':${0}, 'FDD':${1}}, if 'TDD' is used, return ${0}. if 'FDD' is used, return ${1}
    ...     dict2 {'FDD':${1}}, if 'TDD' is used, return ${False}. if 'FDD' is used, return ${1}
    [Arguments]    ${used_enb_technology}=FDD
    ${selected_enb_index}    Set Variable   ${DICT_ENB_TECHNOLOGY_INDEX.get('${used_enb_technology}', ${False})}
    ${enb_index}    Set Variable If
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${selected_enb_index}'!='${False}'    ${selected_enb_index}     ${0}
    [Return]    ${enb_index}

Get LTE Technology Value
    [Documentation]    Author: lie.jia@nokia-sbell.com
    ...                get lte technology value, for example: TDD/FDD/mixed_FDD_TDD
    ...                Return enb Technology and enb index dict {'TDD':${0}, 'FDD':${1}}
    [Arguments]    ${timeout}=300    ${gnb_connection}=GNB_OAM    ${gnb_index}=0    ${cell_type}=lte
    &{enb_Technology_index_dict} = 	Create Dictionary
    ${lte_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_index}    gnb_connection=${gnb_connection}
    Return From Keyword If    ${lte_whether_in_gnb}==${True}    ${enb_Technology_index_dict}
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}
        ...                            connection=enblte_${enb_index}
        ${mrbts_id}    ${lnbts_id}    Get MRbtsID and LNbtsID Value Of Lte Cells
        ...                           enb_index=${enb_index}    timeout=${timeout}    cell_type=${cell_type}
        ${supportedCellTechnology}    coam_parameter.get_single_value_from_scf_file    parameter=supportedCellTechnology
        ...                                                                   dist_name=MRBTS-${mrbts_id}/LNBTS-${lnbts_id}
        ...                                                                   connection=enblte_${enb_index}
        ...                                                                   timeout=${timeout}
        Set To Dictionary 	${enb_Technology_index_dict} 	${supportedCellTechnology}=${enb_index}
    END
    [Return]    ${enb_Technology_index_dict}
    [Teardown]    Teardown GNB and ENB Connections

Teardown GNB and ENB Connections
    [Documentation]    Author: lie.jia@nokia-sbell.com
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
    ${enb_length}    Get Length    ${tl.enbs}
    FOR    ${enb_index}    IN RANGE    ${enb_length}
         Run Keyword And Ignore Error    Enblte close down    connection=enblte_${enb_index}
    END

Get MRbtsID and LNbtsID Value Of Lte Cells
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}    ${cell_type}=lte    ${timeout}=300
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${enb_connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    @{all_cell_ids}    Create List
    FOR    ${cell}    IN    @{cell_list}
        ${cell_idx}    Set Variable    ${cell.split('-')[-1]}
        Append To List    ${all_cell_ids}    ${cell_idx}
    END
    ${mrbts_id}    Set Variable    ${cell_list[0].split('/')[0].split('-')[-1]}
    ${lnbts_id}    Set Variable    ${cell_list[0].split('/')[1].split('-')[-1]}
    [Return]    ${mrbts_id}    ${lnbts_id}

Trun Off All PA Ports
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${value}=${127}
    @{attenuator_num}    Set Variable    ${tl.attenuators}
    ${attenuator_length}    Get Length    ${attenuator_num}
    FOR    ${attenuator_id}    IN RANGE    ${attenuator_length}
        ${vendor}    set variable if  '${attenuator_length}'=='${0}'    ${None}      ${tl.attenuators[${attenuator_id}].vendor}
        ${model}    Set Variable if    '${attenuator_length}'=='${0}'    ${None}    ${tl.attenuators[${attenuator_id}].model}
        Run Keyword If    '${vendor}'=='RADIORACK'    Disable All PA Port For RadioRack    attenuator_index=${attenuator_id}
        ...    ELSE IF    '${model}'=='TAS32B32-0.7G8.4-90-0.5S-DES'
        ...    Disable All Ports For Maritix PA   attenuator_index=${attenuator_id}
        ...    ELSE IF    '${vendor}'=='${None}'     log    no attenuator found in init file
        ...    ELSE    Initial PA Value Setting For Whole PA    attenuator_index=${attenuator_id}    value=${value}
    END

Set Maritix PA Port
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]    ${value}    ${port_list}=A1B1    ${attenuator_index}=2
    ${value}    Convert To Integer    ${value}
    ${port_list_new}     Set Variable   ${port_list.split(',')}
    attenuator.setup_attenuator    attenuator=${tl.attenuators[${attenuator_index}]}    alias=tp
    FOR    ${port_item}    IN    @{port_list_new}
        ${port}    Set Variable    ${port_item.strip()}
        attenuator.set_attenuation    port=${port}      value=${value}    attenuator_device=tp
        ${read_value}     attenuator.read_attenuation    port=${port}    attenuator_device=tp
        Should Be True    '${read_value}'=='${value}'    msg=port ${port} is not set to required value ${value}.
    END
    [Teardown]    attenuator.disconnect   attenuator_device=tp

Disable All Ports For Maritix PA
    [Arguments]    ${attenuator_index}=2
    attenuator.setup_attenuator    attenuator=${tl.attenuators[${attenuator_index}]}    alias=tp
    FOR    ${item}    IN RANGE    1    33
        FOR    ${index}     IN RANGE    1    33
            attenuator.set_attenuation    port=A${index}B${item}      value=${90}    attenuator_device=tp
            ${read_value}    attenuator.read_attenuation   port=A${index}B${item}    attenuator_device=tp
            Should Be True    '${read_value}'=='${90}'    msg=port A${index}B${item} is not trun off.
        END
    END
    [Teardown]    attenuator.disconnect   attenuator_device=tp

Disable All PA Port For RadioRack
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]    ${attenuator_index}=${0}
    @{channels}    Set Variable    ${tl.attenuators[${attenuator_index}].attenuator_ports}
    ${ip_addr}    set variable     ${tl.attenuators[${attenuator_index}].ip_addr}
    ${port}    set variable     ${tl.attenuators[${attenuator_index}].port}
    ${vendor}    set variable    ${tl.attenuators[${attenuator_index}].vendor}
    ${model}    set variable     ${tl.attenuators[${attenuator_index}].model}
    ${configured_attenuator}    attenuator.setup_attenuator
    ...    ip_addr=${ip_addr}
    ...    port=${port}
    ...    attenuation_port_numbers=${channels}
    ...    vendor=${vendor}
    ...    model=${model}
    FOR    ${index}    IN RANGE    1    17
        ${index}    Convert To Integer    ${index}
        ${value}    Evaluate    float(110)
        Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    5X    5sec   attenuator.set_attenuation
        ...    port=${index}   value=${value}   attenuator_device=${configured_attenuator}    confirm=True
        sleep   5sec
    END

Turn off TL283 AEHC0 PA ports
    [Documentation]   lei.jia@nokia-sbell.com
    ...               ue1 is shared between TL073 and TL283, thus it should be turn off while TL073 running
    ...               10.68.88.179 is used by TTL283 UE1
    [Arguments]    ${value}=${63}
    @{attenuation_port_numbers}    create list    1    2    3   4
    @{values}    Create List    ${value}    ${value}    ${value}    ${value}
    ${configured_attenuator}    attenuator.setup_attenuator
    ...    ip_addr=${tl.attenuator[2].ip_addr}
    ...    port=${tl.attenuator[2].port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}
    ...    vendor=${tl.attenuators[2].vendor}
    attenuator.set_ports_attenuation
    ...    ports=${attenuation_port_numbers}   values=${values}   confirm=True
    ...    attenuator_device=${configured_attenuator}
    @{new_values}    attenuator.read_ports_attenuation     ports=${attenuation_port_numbers}
    Lists Should Be Equal    ${new_values}    ${values}    msg=Attenuation set failed.
    Log To Console    \n change attenuation to ${value}

Modify Attenuation Vaule
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${modify_ru_id}=0    ${ue_index}=${0}    ${pa_off_value}=${None}
    ${attenuator_id}    Get Dictionary Keys    ${${tl_prefix}_PA_VALUE_MAPPING[${ue_index}]['${modify_ru_id}']}
    ${channels_dic}    Set Variable    ${${tl_prefix}_PA_VALUE_MAPPING[${ue_index}]['${modify_ru_id}'][${attenuator_id[0]}]}
    attenuator.setup_attenuator    attenuator=${tl.attenuators[${attenuator_id[0]}]}
    @{channels}    Get Dictionary Keys    ${channels_dic}
    @{ports}    Create List
    @{values}    Create List
    FOR    ${channel}    IN    @{channels}
        ${base_up_value}    Set Variable
        ...    ${${tl_prefix}_PA_VALUE_MAPPING[${ue_index}]['${modify_ru_id}'][${attenuator_id[0]}]['${channel}']}
        ${base_down_value}    Set Variable    ${pa_off_value}
        ${base_value}    Set Variable If    ${pa_off_value}==${None}    ${base_up_value}    ${base_down_value}
        ${channel}    Convert To Integer    ${channel}
        ${value}    Evaluate    float(${base_value})
        Append To List    ${ports}    ${channel}
        Append To List    ${values}    ${value}
    END
    Wait Until Keyword Succeeds   5min   5sec   attenuator.set_ports_attenuation   ports=${ports}   values=${values}   confirm=True
    @{new_values}    attenuator.read_ports_attenuation     ports=${ports}
    Lists Should Be Equal    ${new_values}    ${values}    msg=Attenuation set failed.
    Log To Console    \n change attenuation to ${value}

Modify PA Value Setting For Required RU
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${modify_ru_id}=0    ${ue_index}=${0}    ${pa_off_value}=${None}
    ${modify_ru_id_type}    Evaluate    type(${modify_ru_id}).__name__
    ${convert_modify_ru_id_to_list}    Create List    ${modify_ru_id}
    ${modify_ru_id_list}    Set Variable If    'list' in '${modify_ru_id_type}'    ${modify_ru_id}    ${convert_modify_ru_id_to_list}
    FOR    ${ru_index}    IN    @{modify_ru_id_list}
        ${ru_index_list}    Get Dictionary Keys    ${${tl_prefix}_PA_VALUE_MAPPING[${ue_index}]}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${ru_index_list}    ${ru_index}
        Run Keyword If    ${status}    Modify Attenuation Vaule    modify_ru_id=${ru_index}
        ...                                                        ue_index=${ue_index}
        ...                                                        pa_off_value=${pa_off_value}
    END

Set Case Related PA Port Value
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${pa_off_value}=${None}
    ${pcell_ru_index}    Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    ${scell_ru_index_list}    Create List
    FOR  ${scell_index}  IN    @{SCELL_INDEX_LIST}
        ${scell_ru_index}    Set Variable    ${SCELL_MAPPING[${scell_index}]['all_cell_info']['ru_index_mapping']}
        Append To List    ${scell_ru_index_list}    ${scell_ru_index}
    END
    Modify PA Value Setting For Required RU    modify_ru_id=${pcell_ru_index}    ue_index=${ue_index}    pa_off_value=${pa_off_value}
    Modify PA Value Setting For Required RU    modify_ru_id=${scell_ru_index_list}    ue_index=${ue_index}    pa_off_value=${pa_off_value}

Set Case Related MCS Port Value
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${att_value}=0
    ...            ${mcs_index}=${0}
    ...            ${mcs_alias}=MCS_${mcs_index}
    ...            ${ue_index}=${0}
    ...            ${server_ip}=${tl.mcses[${mcs_index}].ip_addr}
    ...            ${server_port}=${tl.mcses[${mcs_index}].port}
    ...            ${vendor}=${tl.mcses[${mcs_index}].vendor}
    ...            ${model}=${tl.mcses[${mcs_index}].model}
    ...            ${frequency}=2600_1_ALL
    ...            ${vertical_distance}=${2.1}
    ...            ${horizontal_distance}=${0.5}
    ...            ${whether_do_Angles}=${True}
    ...            ${whether_do_mcs_setup}=${True}
    ...            ${mcs_pc_index}=${5}
    ...            ${hostname}=${tl.ues[${mcs_pc_index}].ssh_connection_details.addr}
    ...            ${first_beam_begin_output_port}=${9}
    ...            ${first_beam_end_output_port}=${10}
    ...            ${second_beam_begin_output_port}=${11}
    ...            ${second_beam_end_output_port}=${12}
    ...            ${first_beam_horizontal_angle}=${-7}
    ...            ${second_beam_horizontal_angle}=${-22}
    ...            ${vertical_angle}=${-6}
    ...            ${begin_input_port}=${1}
    ...            ${end_input_port}=${32}
    log    ${mcs_alias}
    log    ${ue_index}
    Log To Console     ${\n}INFO: -- Start to set mcs value --
    Kill mcs process    ue_index=${mcs_pc_index}   hostname=${hostname}
    ${vendor}    Convert To Lower Case    ${vendor}
    ${mcs_type}    Run keyword If    '${vendor}' == 'topyoung' and 'MCS' in '${model}'   set variable    topyoung
    ...                   ELSE IF    '${vendor}' == 'topyoung' and 'Radio' in '${model}'    set variable    haojin
    ...                   ELSE       '${vendor}' == 'hbte'    set variable    hbte
    Set Suite Variable    ${mcs_type}
    Run Keyword If    ${whether_do_mcs_setup}    mcs_common.Setup MCS    mcs_type=${mcs_type}
    ...                     server_ip=${server_ip}
    ...                     server_port=${server_port}
    ...                     vendor=${vendor}
    ...                     model=${model}
    ...                     frequency=${frequency}
    Run Keyword If    ${whether_do_Angles}    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...               begin_output_port=${first_beam_begin_output_port}
    ...               end_output_port=${first_beam_end_output_port}
    ...               begin_input_port=${begin_input_port}
    ...               end_input_port=${end_input_port}
    ...               vertical_angle=${vertical_angle}
    ...               horizontal_angle=${first_beam_horizontal_angle}
    ...               vertical_distance=${vertical_distance}
    ...               horizontal_distance=${horizontal_distance}
    Run Keyword If    ${whether_do_Angles}    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...               begin_output_port=${second_beam_begin_output_port}
    ...               end_output_port=${second_beam_end_output_port}
    ...               begin_input_port=${begin_input_port}
    ...               end_input_port=${end_input_port}
    ...               vertical_angle=${vertical_angle}
    ...               horizontal_angle=${second_beam_horizontal_angle}
    ...               vertical_distance=${vertical_distance}
    ...               horizontal_distance=${horizontal_distance}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value}
    ...               begin_output_port=${first_beam_begin_output_port}
    ...               end_output_port=${second_beam_end_output_port}
    ...               begin_input_port=${1}    end_input_port=${64}


#--- Common keywords for gnb/enb ---#
Check TMO Gnb Ready And All Cell On Air
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Check ALL cells on air include: "lte", "wcdma", "gsm", "nr".
    [Arguments]    ${gnb_id}=0    ${connection}=GNB_OAM
    Wait Gnb Ready And Cell On Air    gnb_id=${gnb_id}    timeout=30 min    connection=${connection}
    Wait until keyword succeeds    2 min    20 sec    Verify Gnb Type Cells Should Be Onair    cell_type=lte    connection=${connection}
    Wait until keyword succeeds    2 min    20 sec    Verify Gnb Type Cells Should Be Onair    cell_type=wcdma    connection=${connection}
    Wait until keyword succeeds    12 min    20 sec    Verify Gnb Type Cells Should Be Onair    cell_type=gsm    connection=${connection}

Verify Gnb Type Cells Should Be Onair
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    ...                :param str cell_technology: "TDD", "FDD", "ALL". Default: "ALL".
    [Arguments]    ${cell_type}=lte    ${connection}=GNB_OAM    ${gnb_id}=${0}    ${timeout}=30    ${cell_technology}=ALL
    Log to console    ${\n}----Verify all ${cell_type} cells are on air----
    ${result}    Run Keyword And Return Status    Should Contain Any    ${stream_version}    12.400    14.400    22R1    22R2    21B
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        ${technology}    Set Variable    ${item.get('technology')}
        Run Keyword If    '${cell_technology}'!='ALL' and '${technology}'=='${cell_technology}'
        ...                   Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
        ...    ELSE IF    '${cell_technology}'=='ALL'    Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR  ${cell}  IN   @{cell_list}
        Run Keyword If    ${result}    Run Keyword And Continue On Failure
        ...    Should Be Equal As Strings    ${cell_list_info['${cell}']['availabilityStatus']}    Online
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}     ${enabled}
    END
    [Return]    ${cell_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Verify All Enbs Cell On Air
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${timeout}=10 min
    Log to console    ${\n}----Verify all cells of enbs are on air----
    ${enb_length}    Get Length    ${tl.enbs}
    FOR    ${enb_id}    IN RANGE    ${enb_length}
        Wait Until Keyword Succeeds    ${timeout}    20 sec    Verify Enb All Cell On Air    enb_index=${enb_id}
    END

Verify Enb All Cell On Air
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${enb_index}=${0}    ${connection}=enblte_${enb_index}    ${timeout}=300
    Connect to eNB via ssl    enb_index=${enb_index}    connection=${connection}
	${output}    enblte.get_bts_info    connection=${connection}
    @{rat_type_list}    Create List
    ${ratState_list}    Get Dictionary Keys    ${output['ratState']}
    FOR    ${item}    IN    @{ratState_list}
        ${value}    Get From Dictionary    ${output['ratState']}    ${item}
        Run Keyword If    '${value}' != 'NO_CELLS'    Append To List    ${rat_type_list}    ${item}
    END
    FOR    ${rat_type}    IN    @{rat_type_list}
        Verify Enb Type Cells Should Be Onair    cell_type=${rat_type}    connection=${connection}    timeout=${timeout}
    END
	[Teardown]    Run Keyword And Ignore Error    Enblte close down    connection=${connection}

Verify Enb Type Cells Should Be Onair
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm".
    [Arguments]    ${cell_type}    ${connection}    ${timeout}=30
    ${result}    Run Keyword And Return Status    Should Contain Any    ${stream_version}    12.400    14.400    22R1    22R2    21B
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR    ${cell}    IN    @{cell_list}
        Run Keyword If    ${result}    Run Keyword And Continue On Failure
        ...    Should Be Equal As Strings    ${cell_list_info['${cell}']['availabilityStatus']}    Online
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}    ${enabled}
    END

Get Cell Index List
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_type}=nr    ${timeout}=120    ${gnb_id}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}    ${technology}=TDD
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_id}    gnb_connection=${gnb_connection}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_id}
    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${4g_whether_in_gnb}    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    @{cell_list}    Create List
    FOR    ${item}    IN    @{cell_info}
        ${cell_id}    Set Variable    ${item['id']['configuration'].split('-')[-1]}
        ${technology_vlaue}    Set Variable    ${item['technology']}
        Run Keyword If    '${technology_vlaue}'=='${technology}' and '${cell_type}'!='nr'    Append To List    ${cell_list}    ${cell_id}
        ...    ELSE    Append To List    ${cell_list}    ${cell_id}
    END
    [Return]    ${cell_list}
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Reset NR RAT
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM
    ...            ${gnb_index}=${0}
    ...            ${url}=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...            ${download_dir}=${TS_CASE_LOG_PATH}
    log    ${connection}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${username}    password=${password}    download_dir=${download_dir}
    selenium_coam.disable_message_box
    selenium_coam.reset_nr
    Sleep    180s
    Check TMO Gnb Ready And All Cell On Air
    [Teardown]    COAM selenium logout

Reset LTE RAT
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM
    ...            ${gnb_index}=${0}
    ...            ${url}=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    log    ${connection}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${username}    password=${password}    download_dir=${download_dir}
    selenium_coam.disable_message_box
    selenium_coam.reset_lte
    Sleep    180s
    Check TMO Gnb Ready And All Cell On Air
    [Teardown]    COAM selenium logout

Reset RAT
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str rat_type: RAT name - 5G, LTE, WCDMA or GSM
    [Arguments]    ${rat_type}=5G    ${timeout}=300    ${gnb_id}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_id}    gnb_connection=${gnb_connection}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_id}
    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${rat_type}'!='5G'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${4g_whether_in_gnb}    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${rat_type}'=='5G'    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${rat_type}'!='5G'    ${enb_connection}
    coam.rat_reset    rat_type=${rat_type}    timeout=${timeout}    connection=${connection}
    Sleep    180s
    ${cell_type}    Set Variable If    '${rat_type}'=='5G'    nr    lte
    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${rat_type}'!='5G'
    ...            Verify Enb Type Cells Should Be Onair    cell_type=${cell_type}    connection=${connection}    timeout=${timeout}
    ...    ELSE    Wait Gnb Ready And Cell On Air    gnb_id=${gnb_id}    timeout=20 min    connection=${connection}
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${rat_type}'!='5G'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Block RAT
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param string rat_type: RAT to block. ["NR"|"LTE"|"WCDMA"|"GSM"]
    [Arguments]    ${rat_type}=NR    ${timeout}=300    ${gnb_id}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_id}    gnb_connection=${gnb_connection}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_id}
    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${rat_type}'!='NR'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${4g_whether_in_gnb}    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${rat_type}'=='NR'    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${rat_type}'!='NR'    ${enb_connection}
    coam.block_rat    rat=${rat_type}    timeout=${timeout}    connection=${connection}
    Sleep    60s
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${rat_type}'!='NR'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Unblock RAT
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param string rat_type: RAT to unblock. ["NR"|"LTE"|"WCDMA"|"GSM"]
    [Arguments]    ${rat_type}=NR    ${timeout}=300    ${gnb_id}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_id}    gnb_connection=${gnb_connection}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_id}
    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${rat_type}'!='NR'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${4g_whether_in_gnb}    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${rat_type}'=='NR'    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${rat_type}'!='NR'    ${enb_connection}
    coam.unblock_rat    rat=${rat_type}    timeout=${timeout}    connection=${connection}
    Sleep    60s
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${rat_type}'!='NR'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Verify RAT Should Be Blocked
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param string rat_type: RAT to block. ["NR"|"LTE"|"WCDMA"|"GSM"]
    [Arguments]    ${rat_type}=NR    ${timeout}=300    ${gnb_connection}=GNB_OAM    ${gnb_id}=0
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    Log to console    ${\n}----Verify ${rat_type} RAT are blocked----
    ${cell_type}   Convert To Lower Case   ${rat_type}
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_id}    gnb_connection=${gnb_connection}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_id}
    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${4g_whether_in_gnb}    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    Run Keyword And Return Status    Should Contain Any    ${sw_version}    12.400    14.400    22R1    22R2    21B
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${offline}    Set Variable If    ${result}    Offline    off line
    ${blockingState}     Set Variable If    ${result}    Blocked    Blocked
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR  ${cell}  IN   @{cell_list}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['availabilityStatus']}    ${offline}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}    ${disabled}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['blockingState']}    ${blockingState}
    END
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Get Pcell And Scell Mapping Info
    [Documentation]   Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${pcell_index}    ${source_gnb_id}=0
    Get Pcell Mapping Info    pcell_index=${pcell_index}    source_gnb_id=${source_gnb_id}
    Connect To Multi gNb Coam
    ${scell_mapping}    mbca.get_scell_mapping_for_pcell_for_tmo
    ${tdd_scell_mapping}    mbca.get_tdd_scell_mapping    all_scell_info=${scell_mapping}
    ${fdd_scell_mapping}    mbca.get_fdd_scell_mapping    all_scell_info=${scell_mapping}
    Set Test Variable    ${SCELL_MAPPING}    ${scell_mapping}
    Set Test Variable    ${TDD_SCELL_MAPPING}    ${tdd_scell_mapping}
    Set Test Variable    ${FDD_SCELL_MAPPING}    ${fdd_scell_mapping}
    [Teardown]    Teardown Multi gNb Connections

Get Pcell Mapping Info
    [Documentation]   Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${pcell_index}    ${source_gnb_id}=0
    Connect To Multi gNb Coam
    mbca.set_pcell_index    value=${pcell_index}
    mbca.set_gnb_id    value=${source_gnb_id}
    mbca.set_gnb_operation_object
    ${pcell_mapping}    mbca.get_pcell_mapping_for_tmo
    Set Test Variable    ${PCELL_MAPPING}     ${pcell_mapping}
    [Return]    ${pcell_mapping}
    [Teardown]    Teardown Multi gNb Connections

Get Swap Scell Configured Status
    [Documentation]   Author: stella.lin@nokia-sbell.com
    [Arguments]    ${pcell_index}    ${swap_scell_index}    ${source_gnb_id}=0
    Connect To Multi gNb Coam
    mbca.set_pcell_index    value=${pcell_index}
    mbca.set_gnb_id    value=${source_gnb_id}
    mbca.set_gnb_operation_object
    ${swap_scell_configured_status}    mbca.get_swap_scell_config_status    swap_cell_index=${swap_scell_index}
    [Return]    ${swap_scell_configured_status}
    [Teardown]    Teardown Multi gNb Connections

Get CA Related Infomation For Multi-UE
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${pcell_index}=${PCELL_INDEX}
    ...            ${connection}=GNB_OAM0
    ...            ${gnb_id}=${0}
    ...            ${timeout}=${600}
    ...            ${scell_technology}=${scell_technology}
    ...            ${specified_scell_index}=${None}
    log    ${connection}
    log    ${timeout}
    Connect To Multi gNb Coam
    mbca.set_pcell_index    value=${pcell_index}
    mbca.set_gnb_id    value=${gnb_id}
    mbca.set_gnb_operation_object
    ${pcell_mapping_1}    mbca.get_pcell_mapping_for_tmo
    ${scell_mapping_1}    mbca.get_scell_mapping_for_pcell_for_tmo
    ${tdd_scell_mapping_1}    mbca.get_tdd_scell_mapping    all_scell_info=${scell_mapping_1}
    ${fdd_scell_mapping_1}    mbca.get_fdd_scell_mapping    all_scell_info=${scell_mapping_1}
    ${all_scell_list}    Get Dictionary Keys   ${scell_mapping_1}
    ${tdd_scell_list}    Get Dictionary Keys   ${tdd_scell_mapping_1}
    ${fdd_scell_list}    Get Dictionary Keys   ${fdd_scell_mapping_1}
    ${scell_list}    Set Variable If    '${scell_technology}'=='TDD'    ${tdd_scell_list}    ${fdd_scell_list}
    ${chbw_param_name}    Set Variable If    '${scell_technology}'=='TDD'    chBw    chBwDl
    ${scell_chbw_value}    Set Variable    ${0}
    ${scell_index}    Set Variable    ${0}
    FOR    ${scell}    IN    @{scell_list}
        ${scell_chbw}    Set Variable    ${scell_mapping_1[${scell}]['all_cell_info']['detail_cells_info']['${chbw_param_name}']}
        ${scell_chbw}    Set Variable    ${scell_chbw.split('M')[0]}
        ${scell_chbw}    Evaluate    int(${scell_chbw})
        ${scell_index}    Set Variable If     ${scell_chbw}>=${scell_chbw_value}    ${scell}    ${scell_index}
        ${scell_chbw_value}    Set Variable If     ${scell_chbw}>=${scell_chbw_value}    ${scell_chbw}    ${scell_chbw_value}
    END
    ${scell_index}    set variable if    ${specified_scell_index}!=${None}    ${specified_scell_index}    ${scell_index}
    @{scell_index_list}    Create List    ${scell_index}
    &{cell_list_info}    Create Dictionary
    Set To Dictionary      ${cell_list_info}     scell_index_list    ${scell_index_list}
    Set To Dictionary      ${cell_list_info}     all_scell_list    ${all_scell_list}
    ${pcell_ru_index}    Set Variable    ${pcell_mapping_1['ru_index_mapping']}
    ${scell_ru_index_list}    Create List
    FOR  ${scell_index}  IN    @{scell_index_list}
        ${scell_ru_index}    Set Variable    ${scell_mapping_1[${scell_index}]['all_cell_info']['ru_index_mapping']}
        Append To List    ${scell_ru_index_list}    ${scell_ru_index}
    END
    Set To Dictionary      ${cell_list_info}     pcell_ru_index    ${pcell_ru_index}
    Set To Dictionary      ${cell_list_info}     scell_ru_index_list    ${scell_ru_index_list}
    Set To Dictionary      ${cell_list_info}     pcell_mapping    ${pcell_mapping_1}
    Set To Dictionary      ${cell_list_info}     scell_mapping    ${scell_mapping_1}
    [Return]    ${cell_list_info}
    [Teardown]    Teardown Multi gNb Connections

Get CA Related Infomation
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${pcell_index}=${PCELL_INDEX}
    ...            ${connection}=GNB_OAM0
    ...            ${gnb_id}=${0}
    ...            ${timeout}=${600}
    log    ${connection}
    log    ${timeout}
    Get Pcell And Scell Mapping Info    pcell_index=${pcell_index}    source_gnb_id=${gnb_id}
    ${all_scell_list}    Get Dictionary Keys   ${SCELL_MAPPING}
    ${tdd_scell_list}    Get Dictionary Keys   ${TDD_SCELL_MAPPING}
    ${fdd_scell_list}    Get Dictionary Keys   ${FDD_SCELL_MAPPING}
    ${scell_list}    Set Variable If    '${scell_technology}'=='TDD'    ${tdd_scell_list}    ${fdd_scell_list}
    ${chbw_param_name}    Set Variable If    '${scell_technology}'=='TDD'    chBw    chBwDl
    ${scell_chbw_value}    Set Variable    ${0}
    ${scell_index}    Set Variable    ${0}
    FOR    ${scell}    IN    @{scell_list}
        ${scell_chbw}    Set Variable    ${scell_mapping[${scell}]['all_cell_info']['detail_cells_info']['${chbw_param_name}']}
        ${scell_chbw}    Set Variable    ${scell_chbw.split('M')[0]}
        ${scell_chbw}    Evaluate    int(${scell_chbw})
        ${scell_index}    Set Variable If     ${scell_chbw}>=${scell_chbw_value}    ${scell}    ${scell_index}
        ${scell_chbw_value}    Set Variable If     ${scell_chbw}>=${scell_chbw_value}    ${scell_chbw}    ${scell_chbw_value}
    END
    @{scell_index_list}    Create List    ${scell_index}
    ${specified_scell_exist}    Run Keyword And Return Status
    ...    Set Variable    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['scell_idx_list']}
    ${new_scell_index_list}    Set Variable If    ${specified_scell_exist}
    ...                    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['scell_idx_list']}
    ...                    ${scell_index_list}
#    Modify WeightForSCellSelection Parameter Value On Gnb    scell_list_used_in_fact=${scell_index_list}
#    ...                                                      scell_list_supported=${all_scell_list}
#    ...                                                      connection=${connection}
#    ...                                                      gnb_id=${gnb_id}
#    ...                                                      timeout=${timeout}
    @{scell_pci_list}    Create List
    FOR    ${item}    IN    @{new_scell_index_list}
        ${scell_pci}    Set Variable    ${SCELL_MAPPING[${item}]['all_cell_info']['physicalCellId']}
        ${scell_pci}    Convert To String    ${scell_pci}
        Append to List    ${scell_pci_list}    ${scell_pci}
    END
    Set Test Variable    ${SCELL_INDEX_LIST}    ${new_scell_index_list}
    Set Test Variable    ${SCELL_PCI_LIST}    ${scell_pci_list}

Get DL and UL tput for pcell and scell lists
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${cell_list}=${None}
    ...            ${tput_columns}=${None}
    ...            ${tput_report_before_upgrade}=${None}
    ...            ${tput_report_after_upgrade}=${None}
    ...            ${tput_report_after_upgrade_load_scf}=${None}
    ...            ${scell_pcell_mapping_dict}=${None}
    ...            ${tput_before_upgrade}=${None}
    ...            ${tput_after_upgrade}=${None}
    ...            ${tput_after_upgrade_with_new_scf}=${None}
    Get tput for pcell and scell lists for only one direction
    ...            cell_list=${cell_list}
    ...            tput_columns=${tput_columns}
    ...            tput_report_before_upgrade=${tput_report_before_upgrade}
    ...            tput_report_after_upgrade=${tput_report_after_upgrade}
    ...            tput_report_after_upgrade_load_scf=${tput_report_after_upgrade_load_scf}
    ...            scell_pcell_mapping_dict=${scell_pcell_mapping_dict}
    ...            tput_before_upgrade=${tput_before_upgrade}
    ...            tput_after_upgrade=${tput_after_upgrade}
    ...            tput_after_upgrade_with_new_scf=${tput_after_upgrade_with_new_scf}
    ...            direction=DL
    Get tput for pcell and scell lists for only one direction
    ...            cell_list=${cell_list}
    ...            tput_columns=${tput_columns}
    ...            tput_report_before_upgrade=${tput_report_before_upgrade}
    ...            tput_report_after_upgrade=${tput_report_after_upgrade}
    ...            tput_report_after_upgrade_load_scf=${tput_report_after_upgrade_load_scf}
    ...            scell_pcell_mapping_dict=${scell_pcell_mapping_dict}
    ...            tput_before_upgrade=${tput_before_upgrade}
    ...            tput_after_upgrade=${tput_after_upgrade}
    ...            tput_after_upgrade_with_new_scf=${tput_after_upgrade_with_new_scf}
    ...            direction=UL


Get tput for pcell and scell lists for only one direction
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${cell_list}=${None}
    ...            ${tput_columns}=${None}
    ...            ${tput_report_before_upgrade}=${None}
    ...            ${tput_report_after_upgrade}=${None}
    ...            ${tput_report_after_upgrade_load_scf}=${None}
    ...            ${scell_pcell_mapping_dict}=${None}
    ...            ${tput_before_upgrade}=${None}
    ...            ${tput_after_upgrade}=${None}
    ...            ${tput_after_upgrade_with_new_scf}=${None}
    ...            ${direction}=DL
    FOR    ${cell_index}    IN    @{cell_list}
        Log To Console    ${\n}Get ${direction} tput from aasyslog for cell-${cell_index}
        ${TPUT_result_before_upgrade}    Run Keyword And Continue On Failure    Check Tput from aasyslog file
        ...    cellid=${cell_index}
        ...    tput_log=${tput_before_upgrade['${scell_pcell_mapping_dict['${cell_index}']}']}
        ...    direction=${direction}
        ${TPUT_result_after_upgrade}    Run Keyword And Continue On Failure    Check Tput from aasyslog file
        ...    cellid=${cell_index}
        ...    tput_log=${tput_after_upgrade['${scell_pcell_mapping_dict['${cell_index}']}']}
        ...    direction=${direction}
        ${TPUT_result_with_newscf}    Run Keyword And Continue On Failure    Check Tput from aasyslog file
        ...    cellid=${cell_index}
        ...    tput_log=${tput_after_upgrade_with_new_scf['${scell_pcell_mapping_dict['${cell_index}']}']}
        ...    direction=${direction}
        ${before_upgrade_tput_exp}    evaluate    ${TPUT_result_before_upgrade} * 0.9
        Run Keyword And Continue On Failure    Should Be True    ${TPUT_result_after_upgrade} >= ${before_upgrade_tput_exp}
        ${after_upgrade_tput_exp}    evaluate    ${TPUT_result_after_upgrade} * 0.9
        Run Keyword And Continue On Failure    Should Be True    ${TPUT_result_with_newscf} >= ${after_upgrade_tput_exp}
        # generate tput in excel
        Append To List 	 ${tput_columns} 	Cell${cell_index}_${direction}
        Append To List    ${tput_report_before_upgrade}    ${TPUT_result_before_upgrade}
        Append To List    ${tput_report_after_upgrade}    ${TPUT_result_after_upgrade}
        Append To List    ${tput_report_after_upgrade_load_scf}    ${TPUT_result_with_newscf}
    END

Get scell and pcell mapping dict
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${pcell_index}=${PCELL_INDEX}
    ...            ${gnb_id}=${0}
    ...            ${ue_index}=${0}
    ...            ${scell_pcell_mapping_dict}=${None}
    log    ${ue_index}
    Get Pcell And Scell Mapping Info    pcell_index=${pcell_index}    source_gnb_id=${gnb_id}
    ${SCELL_INDEX_LIST}    Get Dictionary Keys    ${SCELL_MAPPING}
    ${pcell_ru_index}    Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    ${scell_ru_index_list}    Create List
    FOR  ${scell_index}  IN    @{SCELL_INDEX_LIST}
        ${scell_ru_index}    Set Variable    ${SCELL_MAPPING[${scell_index}]['all_cell_info']['ru_index_mapping']}
        Append To List    ${scell_ru_index_list}    ${scell_ru_index}
        ${scell_index}    convert to string    ${scell_index}
        Set To Dictionary 	${scell_pcell_mapping_dict} 	${scell_index}=${pcell_index}
    END
    Set To Dictionary 	${scell_pcell_mapping_dict} 	${pcell_index}=${pcell_index}
    [Return]   ${SCELL_INDEX_LIST}

Set PA value based on pcell index
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${pcell_index}=${PCELL_INDEX}
    ...            ${gnb_id}=${0}
    ...            ${ue_index}=${0}
    ...            ${pa_off_value}=${None}
    Get Pcell And Scell Mapping Info    pcell_index=${pcell_index}    source_gnb_id=${gnb_id}
    ${SCELL_INDEX_LIST}    Get Dictionary Keys    ${SCELL_MAPPING}
    ${pcell_ru_index}    Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    ${scell_ru_index_list}    Create List
    FOR  ${scell_index}  IN    @{SCELL_INDEX_LIST}
        ${scell_ru_index}    Set Variable    ${SCELL_MAPPING[${scell_index}]['all_cell_info']['ru_index_mapping']}
        Append To List    ${scell_ru_index_list}    ${scell_ru_index}
    END
    Modify PA Value Setting For Required RU    modify_ru_id=${pcell_ru_index}    ue_index=${ue_index}    pa_off_value=${pa_off_value}
    Modify PA Value Setting For Required RU    modify_ru_id=${scell_ru_index_list}    ue_index=${ue_index}    pa_off_value=${pa_off_value}


Get 3CC Related Infomation
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${pcell_index}=${PCELL_INDEX}
    ...            ${connection}=GNB_OAM0
    ...            ${gnb_id}=${0}
    ...            ${timeout}=${600}
    log    ${connection}
    log    ${timeout}
    Get Pcell And Scell Mapping Info    pcell_index=${pcell_index}    source_gnb_id=${gnb_id}
    ${all_scell_list}    Get Dictionary Keys   ${SCELL_MAPPING}
    @{scell_index_list}    Set Variable    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['scell_idx_list']}
#    Modify WeightForSCellSelection Parameter Value On Gnb    scell_list_used_in_fact=${scell_index_list}
#    ...                                                      scell_list_supported=${all_scell_list}
#    ...                                                      connection=${connection}
#    ...                                                      gnb_id=${gnb_id}
#    ...                                                      timeout=${timeout}
    Set Test Variable    ${SCELL_INDEX_LIST}    ${scell_index_list}

Generate coam cells update Parameter Values
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${cell_list}
    ...            ${params_for_update}
    ...            ${gnb_id}=${0}
    ...            ${parameter}=weightForSCellSelection
    ...            ${value}=100
    FOR    ${cell_index}    IN    @{cell_list}
        ${dist_name}    Set Variable    NRBTS-${tl.gnbs[${gnb_id}].global_bts_id}/NRCELL-${cell_index}
        ${param}    Create Dictionary    dist_name=${dist_name}    parameter=${parameter}    value=${value}
        Append To List    ${params_for_update}    ${param}
    END
    [Return]    ${params_for_update}

COAM Create Updated parameters Delta File
    [Documentation]  Author: lei.jia@nokia-sbell.com
    [Arguments]    ${cell_list}    ${timeout}=${600}    ${connection}=GNB_OAM
    # generate update parameters
    @{params_for_update}    Create List
    Generate coam cells update Parameter Values    cell_list=${cell_list}
    ...    parameter=weightForSCellSelection
    ...    value=1
    ...    params_for_update=${params_for_update}
    ${params_for_scellweight}    Generate coam cells update Parameter Values    cell_list=${cell_list}
    ...    parameter=actMacBSRIndexAlign
    ...    value=false
    ...    params_for_update=${params_for_update}
    @{params_for_lockcell}    Create List
    ${cell_locked_param}     Generate coam cells update Parameter Values        cell_list=${cell_list}
    ...            parameter=administrativeState
    ...            value=Locked
    ...            params_for_update=${params_for_lockcell}
    @{params_for_unlockcell}    Create List
    ${cell_unlocked_param}     Generate coam cells update Parameter Values       cell_list=${cell_list}
    ...            parameter=administrativeState
    ...            value=Unlocked
    ...            params_for_update=${params_for_unlockcell}
    @{params_for_update2}    Create List
    Generate coam cells update Parameter Values    cell_list=${cell_list}
    ...    params_for_update=${params_for_update2}
    ...    parameter=weightForSCellSelection
    ...    value=100
    ${params_for_scellweight2}    Generate coam cells update Parameter Values    cell_list=${cell_list}
    ...    parameter=actMacBSRIndexAlign
    ...    value=true
    ...    params_for_update=${params_for_update2}
    # create delta file for parameters
    ${para_file_scellweight}    coam_parameter.create_update_parameters_delta
    ...    parameters=${params_for_scellweight}
    ...    connection=${connection}
    ...    timeout=${timeout}
    ${para_file_cell_locked}    coam_parameter.create_update_parameters_delta
    ...    parameters=${cell_locked_param}
    ...    connection=${connection}
    ...    timeout=${timeout}
    ${para_file_cell_unlocked}    coam_parameter.create_update_parameters_delta
    ...    parameters=${cell_unlocked_param}
    ...    connection=${connection}
    ...    timeout=${timeout}
    ${para_file_scellweight100}    coam_parameter.create_update_parameters_delta
    ...    parameters=${params_for_scellweight2}
    ...    connection=${connection}
    ...    timeout=${timeout}
    [Return]    ${para_file_scellweight}    ${para_file_cell_locked}    ${para_file_cell_unlocked}    ${para_file_scellweight100}


COAM perform scf delta commission
    [Documentation]  Author: lei.jia
    [Arguments]    ${para_file}    ${timeout}=${600}    ${connection}=GNB_OAM    ${should_activate}=${True}
    ...    ${skip_parameter_relation_errors}=True
    ${update_via_api_status}    coam_parameter.perform_scf_delta_commission
    ...    delta_file=${para_file['updated']}
    ...    timeout=${timeout}
    ...    connection=${connection}
    ...    should_activate=${should_activate}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}



Modify WeightForSCellSelection Parameter Value On Gnb
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${scell_list_used_in_fact}
    ...            ${scell_list_supported}
    ...            ${connection}=GNB_OAM0
    ...            ${gnb_id}=${0}
    ...            ${timeout}=${600}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    ...                                                                             gnb_index=${gnb_id}
    ${rest_scell_list}    Evaluate    list(set(${scell_list_supported})-set(${scell_list_used_in_fact}))
    @{params_for_update}    Create List
    Log To Console    ${\n}Modify weight value to 100 of ${scell_list_used_in_fact} on GNB: ${gnb_id}
    Generate coam cells update Parameter Values    cell_list=${scell_list_used_in_fact}    value=100
    ...    params_for_update=${params_for_update}    parameter=weightForSCellSelection
    Log To Console    ${\n}Modify weight value to 1 of ${rest_scell_list} on GNB: ${gnb_id}
    Generate coam cells update Parameter Values    cell_list=${rest_scell_list}    value=1
    ...    params_for_update=${params_for_update}    parameter=weightForSCellSelection
    Log To Console    ${\n}Update weight value on GNB: ${gnb_id}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}    timeout=${timeout}
    ...    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get RU Index In Init Via Cell Index
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${pell_index}=1    ${sell_index_list}=1
    log many     ${pell_index}     ${sell_index_list}
    Source COAM Login Page Via WebUI
    ${pcell_rmod_index}    Set Variable    ${PCELL_MAPPING['rmod_index']}
    ${serial_number}    Get Serial Number Via Rmod Index On Gnb    rmod_index=${pcell_rmod_index}
    ${pcell_ru_index}    Get RU Index In Init Via Serial Number Of RU On Gnb    serial_number=${serial_number}
    ${scell_ru_index_list}    Create List
    FOR  ${scell_index}  IN    @{SCELL_INDEX_LIST}
        ${scell_rmod_index}    Set Variable    ${SCELL_MAPPING[${scell_index}]['all_cell_info']['rmod_index']}
        ${serial_number}    Get Serial Number Via Rmod Index On Gnb    rmod_index=${scell_rmod_index}
        ${scell_ru_index}    Get RU Index In Init Via Serial Number Of RU On Gnb    serial_number=${serial_number}
        Append To List    ${scell_ru_index_list}    ${scell_ru_index}
    END
    [Return]    ${pcell_ru_index}    ${scell_ru_index_list}
    [Teardown]    Run Keyword And Ignore Error    COAM selenium logout

Get Serial Number Via Rmod Index On Gnb
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${rmod_index}
    ${output_ru}      selenium_coam.get_ru_info    ru_index=${rmod_index}
    ${serial_number}    Set Variable    ${output_ru['Serial number']}
    [Return]    ${serial_number}

Get RU Index In Init Via Serial Number Of RU On Gnb
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${serial_number}
    ${all_ru_list_in_init}    Set Variable    ${tl.gnbs[0].dus[0].rus}
    FOR    ${ru_in_init}    IN    @{all_ru_list_in_init}
        ${ru_index}    Get Index From List    ${all_ru_list_in_init}    ${ru_in_init}
        ${sn_of_ru}    Set Variable    ${tl.gnbs[0].dus[0].rus[${ru_index}].serial_number}
        ${status}    Evaluate    "${serial_number}"=="${sn_of_ru}"
        Exit For Loop If    "${status}"=="True"
    END
    [Return]    ${ru_index}

Check RU Whether Connect Mcs
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_index}    ${ue_index}=${0}
    ${ru_index_list}    Get Dictionary Keys    ${${tl_prefix}_PA_VALUE_MAPPING[${ue_index}]}
    ${ru_whether_connect_mcs}    Run Keyword And Return Status    List Should Not Contain Value    ${ru_index_list}    ${ru_index}
    [Return]    ${ru_whether_connect_mcs}

Set Case PA Or MCS Port Value
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${attenuator_list}    ${ue_index}=${0}   ${whether_do_mcs_setup}=${True}    ${pa_off_value}=${None}
    FOR    ${attenuator}    IN    @{attenuator_list}
        Run Keyword If    '${attenuator}'=='pa'    Set Case Related PA Port Value    ue_index=${ue_index}    pa_off_value=${pa_off_value}
        ...    ELSE IF    '${attenuator}'=='mcs'    Set Case Related MCS Port Value    ue_index=${ue_index}
        ...                                            whether_do_mcs_setup=${whether_do_mcs_setup}
        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
    END

Update The Prach Index
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                This keyword just for 5G cell.
    [Arguments]    ${cell_index}    ${prach_index}=158    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=300
    ${dist_name}    Set Variable    MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${cell_index}
#    ${dist_name2}    Set Variable
#    ...     MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${401}
    ${dist_name2}     Set Variable If   '${tl_prefix}'=='T813'
    ...     MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${311}
    ${param}    Create Dictionary    dist_name=${dist_name}    parameter=prachConfigurationIndex    value=${prach_index}
    ${param2}    Create Dictionary    dist_name=${dist_name2}    parameter=prachConfigurationIndex    value=${prach_index}
    @{param_list}    Run Keyword If     '${tl_prefix}'=='T813'     Create List    ${param}    ${param2}
    ...                   ELSE     Create List    ${param}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}
    ...                                            timeout=${timeout}
    Wait Gnb Ready And Cell On Air    gnb_id=${gnb_index}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Update AMF Status
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                ${administrativeState}: Value can be "Unlocked" or "Locked"
    [Arguments]    ${administrativeState}=Locked    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=300
    ${dist_name}    Set Variable    MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/SERVEDAMF-1
    ${param}    Create Dictionary    dist_name=${dist_name}    parameter=administrativeState    value=${administrativeState}
    @{param_list}    Create List    ${param}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Verify SERVEDAMF Status On GNB
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                When AMF is lock, gnb and enb is no expect alarm, so need to check point is check unexpect alarm
    ...                ${administrativeState}: Value can be "Unlocked" or "Locked"
    ...                ${ngLinkStatus}: Value can be "Active" or "Inactive"
    [Arguments]    ${connection}=GNB_OAM
    ...            ${enb_connection}=enblte
    ...            ${gnb_index}=${0}
    ...            ${enb_index}=${0}
    ...            ${administrativeState}=Unlocked
    ...            ${ngLinkStatus}=Active
    ...            ${target_amf_number}=${1}
    ...            ${ru_type}=AHFIG
    ...            ${cell_type}=nr
    ...            ${expected_value}=Unlocked
    ...            ${allowed_faults}=${GNB_ALLOWED_FAULT}
    Log To Console    ${\n}Check SERVEDAMF status from GNB
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
    ...                 Connect to eNB via ssl    connection=${enb_connection}    enb_index=${enb_index}
    @{SERVEDAMF_A}    coam.get_managed_objects    class_name=SERVEDAMF_A    connection=${connection}
    @{SERVEDAMF_L}    coam.get_managed_objects    class_name=SERVEDAMF_L    connection=${connection}
    @{direction_serverAMF_A}    Create List
    @{direction_serverAMF_L}    Create List
    FOR   ${SERVERAMF}   IN   @{SERVEDAMF_A}
         ${amf_number}  Set Variable    ${SERVERAMF['distName'].split('-')[-1]}
         Run Keyword If   '${amf_number}'=='${target_amf_number}'
         ...                    Append To List    ${direction_serverAMF_A}    ${SERVERAMF}
    END
    FOR   ${SERVERAMF}   IN   @{SERVEDAMF_L}
         ${amf_number}  Set Variable    ${SERVERAMF['distName'].split('-')[-1]}
         Run Keyword If   '${amf_number}'=='${target_amf_number}'
         ...                    Append To List    ${direction_serverAMF_L}    ${SERVERAMF}
    END
    &{dict_amfStatus}    coam.get_parameters    dist_name=${direction_serverAMF_A[0]['distName']}    pattern=administrativeState
    ...                                                                                    connection=${connection}
    &{dict_ngLinkStatus}    coam.get_parameters    dist_name=${direction_serverAMF_L[0]['distName']}    pattern=ngLinkStatus
    ...                                                                                       connection=${connection}
    Should Be Equal As Strings    ${dict_amfStatus['administrativeState']}    ${administrativeState}    msg=AMF is not ${administrativeState}
    ...                                                                                                 ignore_case=${True}
    Should Be Equal As Strings    ${dict_ngLinkStatus['ngLinkStatus']}    ${ngLinkStatus}    msg=AMF is not ${ngLinkStatus}
    ...                                                                                      ignore_case=${True}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}    connection=${connection}
    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'       Run Keyword And Continue On Failure
    ...                 Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}    connection=${enb_connection}
    Run Keyword If    '${expected_value}'=='Locked'    Wait Until Keyword Succeeds    10 min    20 sec
    ...    Check All Cells Should Be On Air Except Special RU Related Cells
    ...  connection=${connection}    ru_type=${ru_type}    cell_type=${cell_type}
    Run Keyword If    '${expected_value}'=='Unlocked'    Wait Until Keyword Succeeds    10 min    20 sec
    ...    Check TMO Gnb Ready And All Cell On Air    connection=${connection}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}    AND
    ...           Run Keyword If    '${LTE_WHETHER_IN_GNB}'=='${False}'   Run Keyword And Ignore Error
    ...                                                   Enblte close down    connection=${enb_connection}

Get Pcell And Scell Mapping Info After Handover
    [Documentation]   Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ho_pcell_index}    ${source_gnb_id}=0    ${connection}=GNB_OAM0
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${source_gnb_id}
    mbca.set_pcell_index    value=${ho_pcell_index}
    mbca.set_gnb_id    value=${source_gnb_id}
    mbca.set_gnb_operation_object
    ${ho_pcell_mapping}    mbca.get_pcell_mapping_for_tmo
    ${ho_scell_mapping}    mbca.get_scell_mapping_for_pcell_for_tmo
    ${ho_tdd_scell_mapping}    mbca.get_tdd_scell_mapping    all_scell_info=${ho_scell_mapping}
    ${ho_fdd_scell_mapping}    mbca.get_fdd_scell_mapping    all_scell_info=${ho_scell_mapping}
    Set Test Variable    ${HO_PCELL_MAPPING}     ${ho_pcell_mapping}
    Set Test Variable    ${HO_SCELL_MAPPING}    ${ho_scell_mapping}
    Set Test Variable    ${HO_TDD_SCELL_MAPPING}    ${ho_tdd_scell_mapping}
    Set Test Variable    ${HO_FDD_SCELL_MAPPING}    ${ho_fdd_scell_mapping}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get Pcell And Scell Mapping Info For Pcell Change
    [Documentation]   Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ho_pcell_index}    ${gnb_id}=0    ${connection}=GNB_OAM0    ${timeout}=${600}
    log    ${timeout}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
    mbca.set_pcell_index    value=${ho_pcell_index}
    mbca.set_gnb_id    value=${gnb_id}
    mbca.set_gnb_operation_object
    ${ho_pcell_mapping}    mbca.get_pcell_mapping_for_tmo
    ${ho_scell_mapping}    mbca.get_scell_mapping_for_pcell_for_tmo
    ${ho_tdd_scell_mapping}    mbca.get_tdd_scell_mapping    all_scell_info=${ho_scell_mapping}
    ${ho_fdd_scell_mapping}    mbca.get_fdd_scell_mapping    all_scell_info=${ho_scell_mapping}
    Set Test Variable    ${HO_PCELL_MAPPING}     ${ho_pcell_mapping}
    Set Test Variable    ${HO_SCELL_MAPPING}    ${ho_scell_mapping}
    Set Test Variable    ${HANDOVER_PCELL_MAPPING}     ${ho_pcell_mapping}
    Set Test Variable    ${HO_TDD_SCELL_MAPPING}    ${ho_tdd_scell_mapping}
    Set Test Variable    ${HO_FDD_SCELL_MAPPING}    ${ho_fdd_scell_mapping}
    ${ho_all_scell_list}    Get Dictionary Keys   ${HO_SCELL_MAPPING}
    ${ho_tdd_scell_list}    Get Dictionary Keys   ${HO_TDD_SCELL_MAPPING}
    ${ho_fdd_scell_list}    Get Dictionary Keys   ${HO_FDD_SCELL_MAPPING}
    ${ho_scell_list}    Set Variable If    '${HO_SCELL_TECHNOLOGY}'=='TDD'    ${ho_tdd_scell_list}    ${ho_fdd_scell_list}
    ${ho_chbw_param_name}    Set Variable If    '${HO_SCELL_TECHNOLOGY}'=='TDD'    chBw    chBwDl
    ${ho_scell_chbw_value}    Set Variable    ${0}
    ${scell_index}    Set Variable    ${0}
    FOR    ${scell}    IN    @{ho_scell_list}
        ${scell_chbw}    Set Variable    ${HO_SCELL_MAPPING[${scell}]['all_cell_info']['detail_cells_info']['${ho_chbw_param_name}']}
        ${scell_chbw}    Set Variable    ${scell_chbw.split('M')[0]}
        ${scell_chbw}    Evaluate    int(${scell_chbw})
        ${scell_index}    Set Variable If     ${scell_chbw}>=${ho_scell_chbw_value}    ${scell}    ${scell_index}
        ${ho_scell_chbw_value}    Set Variable If     ${scell_chbw}>=${ho_scell_chbw_value}    ${scell_chbw}    ${ho_scell_chbw_value}
    END
    @{ho_scell_index_list}    Create List    ${scell_index}
#    Modify WeightForSCellSelection Parameter Value On Gnb    scell_list_used_in_fact=${ho_scell_index_list}
#    ...                                                      scell_list_supported=${ho_all_scell_list}
#    ...                                                      connection=${connection}
#    ...                                                      gnb_id=${gnb_id}
#    ...                                                      timeout=${timeout}
    @{ho_scell_pci_list}    Create List
    FOR    ${item}    IN    @{ho_scell_index_list}
        ${scell_pci}    Set Variable    ${HO_SCELL_MAPPING[${item}]['all_cell_info']['physicalCellId']}
        ${scell_pci}    Convert To String    ${scell_pci}
        Append to List    ${ho_scell_pci_list}    ${scell_pci}
    END
    Set Test Variable    ${HO_SCELL_INDEX_LIST}    ${ho_scell_index_list}
    Set Test Variable    ${HO_SCELL_PCI_LIST}    ${ho_scell_pci_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Do All Type Cells Action And Verify Status
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    ...                ${cell_action}:value can be "locked"  or "unlocked"
    ...                ${cell_id}: value can be "None" means for all cells, if not "None" means for special cell
    [Arguments]    ${cell_action}=locked    ${cell_type}=nr    ${timeout}=300
    ...            ${gnb_id}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    ...            ${is_connect_coam_needed}=${True}    ${cell_id}=None
    Do All Type Cells Lock Or Unlock    cell_action=${cell_action}
    ...                                 cell_type=${cell_type}
    ...                                 timeout=${timeout}
    ...                                 gnb_id=${gnb_id}
    ...                                 gnb_connection=${gnb_connection}
    ...                                 enb_index=${enb_index}
    ...                                 enb_connection=${enb_connection}
    ...                                 is_connect_coam_needed=${is_connect_coam_needed}
    ...                                 cell_id=${cell_id}
    Run Keyword If    '${cell_action}'=='locked'    Wait Until Keyword Succeeds    ${timeout} sec    10 sec
    ...                                             Verify All Type Cells Should Be locked    cell_type=${cell_type}
    ...                                                                                       timeout=${timeout}
    ...                                                                                       gnb_id=${gnb_id}
    ...                                                                                       gnb_connection=${gnb_connection}
    ...                                                                                       enb_index=${enb_index}
    ...                                                                                       enb_connection=${enb_connection}
    ...                                                                                       is_connect_coam_needed=${is_connect_coam_needed}
    ...                                                                                       cell_id=${cell_id}
    ...    ELSE IF    '${cell_action}'=='unlocked'    Wait Until Keyword Succeeds    ${timeout} sec    10 sec
    ...                                               Verify All Type Cells Should Be unlocked    cell_type=${cell_type}
    ...                                                                                           timeout=${timeout}
    ...                                                                                           gnb_id=${gnb_id}
    ...                                                                                           gnb_connection=${gnb_connection}
    ...                                                                                           enb_index=${enb_index}
    ...                                                                                           enb_connection=${enb_connection}
    ...                                                                                           is_connect_coam_needed=${is_connect_coam_needed}
    ...                                                                                           cell_id=${cell_id}
    ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong cell action(${cell_action}), need to check--

Do All Type Cells Lock Or Unlock
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    ...                ${cell_action}:value can be "locked"  or "unlocked"
    [Arguments]    ${cell_action}=locked    ${cell_type}=nr    ${timeout}=300
    ...            ${gnb_id}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    ...            ${is_connect_coam_needed}=${True}    ${cell_id}=None
    Log to console    ${\n}----Do all ${cell_type} cells ${cell_action}----
    Run Keyword If    ${is_connect_coam_needed}    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl
    ...                                                                                                connection=${gnb_connection}
    ...                                                                                                gnb_index=${gnb_id}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and ${is_connect_coam_needed} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    @{params_for_update}    Create List
    ${action}    Run Keyword If    '${cell_type}'=='nr' and '${cell_action}'=='locked'    Set Variable    Locked
    ...                 ELSE IF    '${cell_type}'=='nr' and '${cell_action}'=='unlocked'    Set Variable    Unlocked
    ...                 ELSE IF    '${cell_type}'=='lte' and '${cell_action}'=='locked'    Set Variable    locked
    ...                 ELSE IF    '${cell_type}'=='lte' and '${cell_action}'=='unlocked'    Set Variable    unlocked
    FOR   ${cell_dist_name}    IN     @{cell_list}
         ${cell_index}    Set Variable    ${cell_dist_name.split('-')[-1]}
         ${param}    Create Dictionary    dist_name=${cell_dist_name}    parameter=administrativeState    value=${action}
         Run Keyword If    '${cell_id}'=='None'    Append To List    ${params_for_update}    ${param}
         ...    ELSE IF    '${cell_id}'!='None' and '${cell_index}'=='${cell_id}'    Append To List    ${params_for_update}    ${param}
    END
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    Run Keywords
    ...    Run Keyword If    ${is_connect_coam_needed}
    ...                          Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and ${is_connect_coam_needed} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Verify All Type Cells Should Be locked
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    [Arguments]    ${cell_type}=nr    ${timeout}=300    ${gnb_connection}=GNB_OAM    ${gnb_id}=0
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    ...            ${is_connect_coam_needed}=${True}    ${cell_id}=None
    Log to console    ${\n}----Verify all ${cell_type} cells are locked----
    Run Keyword If    ${is_connect_coam_needed}    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl
    ...                                                                                                connection=${gnb_connection}
    ...                                                                                                gnb_index=${gnb_id}
    ${result}    Run Keyword And Return Status    Should Contain Any    ${stream_version}    12.400    14.400    22R1    22R2    21B
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${offline}    Set Variable If    ${result}    Offline    off line
    ${locked}     Set Variable If    ${result}    Locked    locked
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and ${is_connect_coam_needed} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR  ${cell}  IN   @{cell_list}
        ${cell_index}    Set Variable    ${cell.split('-')[-1]}
        Run Keyword If    '${cell_id}'!='None' and '${cell_index}'!='${cell_id}'    Continue For Loop
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['availabilityStatus']}    ${offline}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}    ${disabled}
        Run Keyword If   '${cell_type}'=='nr'   Run Keyword And Continue On Failure
        ...                 Should Be Equal As Strings    ${cell_list_info['${cell}']['administrativeState']}    Locked
        Run Keyword If   '${cell_type}'=='lte'   Run Keyword And Continue On Failure
        ...                 Should Be Equal As Strings    ${cell_list_info['${cell}']['administrativeState']}    ${locked}
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    ${is_connect_coam_needed}
    ...                          Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and ${is_connect_coam_needed} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Verify All Type Cells Should Be unlocked
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    [Arguments]    ${cell_type}=nr    ${timeout}=300    ${gnb_connection}=GNB_OAM    ${gnb_id}=0
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    ...            ${is_connect_coam_needed}=${True}    ${cell_id}=None
    Log to console    ${\n}----Verify all ${cell_type} cells are unlocked----
    Run Keyword If    ${is_connect_coam_needed}    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl
    ...                                                                                                connection=${gnb_connection}
    ...                                                                                                gnb_index=${gnb_id}
    ${result}    Run Keyword And Return Status    Should Contain Any    ${stream_version}    12.400    14.400    22R1    22R2    21B
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${unlocked}     Set Variable If    ${result}    Unlocked    unlocked
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and ${is_connect_coam_needed} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR  ${cell}  IN   @{cell_list}
        ${cell_index}    Set Variable    ${cell.split('-')[-1]}
        Run Keyword If    '${cell_id}'!='None' and '${cell_index}'!='${cell_id}'    Continue For Loop
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}    ${enabled}
        Run Keyword If   '${cell_type}'=='nr'   Run Keyword And Continue On Failure
        ...                Should Be Equal As Strings    ${cell_list_info['${cell}']['administrativeState']}    Unlocked
        Run Keyword If   '${cell_type}'=='lte'   Run Keyword And Continue On Failure
        ...                 Should Be Equal As Strings    ${cell_list_info['${cell}']['administrativeState']}    ${unlocked}
        run keyword if    ${result}    Run Keyword And Continue On Failure
        ...    Should Be Equal As Strings    ${cell_list_info['${cell}']['availabilityStatus']}    Online
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    ${is_connect_coam_needed}
    ...                          Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and ${is_connect_coam_needed} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Do All TDD-LTE Cells Action
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
        ...            ${cell_action}:value can be "locked" or "unlocked"
    [Arguments]    ${cell_action}=locked    ${timeout}=300
    ...            ${gnb_index}=${0}    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    Log to console    ${\n}----Get all TDD-LTE cells and do ${cell_action} action----
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False}
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}    ${enb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=lte    timeout=${timeout}    connection=${connection}
    @{tdd_lte_cell_list}    Create List
    FOR    ${item}    IN    @{cell_info}
        ${cell_technology}    Set variable    ${item['technology']}
        Run Keyword If    '${cell_technology}'=='TDD'    Append To List    ${tdd_lte_cell_list}    ${item['id']['configuration']}
    END
    @{params_for_update}    Create List
    FOR   ${tdd_lte_cell}    IN     @{tdd_lte_cell_list}
         ${param}    Create Dictionary    dist_name=${tdd_lte_cell}    parameter=administrativeState    value=${cell_action}
         Append To List    ${params_for_update}    ${param}
    END
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}    AND
    ...    Run Keyword If   ${LTE_WHETHER_IN_GNB}==${False}   Run Keyword And Ignore Error   Enblte close down   connection=${enb_connection}

Verify All TDD-LTE Cells Should Be Locked
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${timeout}=300    ${gnb_index}=${0}    ${gnb_connection}=GNB_OAM    ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    Log to console    ${\n}----Verify all TDD-LTE Cells are locked----
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False}
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}    ${enb_connection}
    ${result}    Run Keyword And Return Status    Should Contain Any    ${stream_version}    12.400    14.400    22R1    22R2    21B
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${offline}    Set Variable If    ${result}    Offline    off line
    ${cell_info}   coam.get_cells_info    cell_type=lte    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        ${cell_technology}    Set variable    ${item['technology']}
        Run Keyword If    '${cell_technology}'=='TDD'    Set To Dictionary    ${cell_list_info}
        ...                                                                   ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR  ${cell}  IN   @{cell_list}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}    ${disabled}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['administrativeState']}    locked
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['availabilityStatus']}    ${offline}
    END
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}    AND
    ...    Run Keyword If   ${LTE_WHETHER_IN_GNB}==${False}   Run Keyword And Ignore Error   Enblte close down   connection=${enb_connection}

Verify All TDD-LTE Cells Should Be Unlocked
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${timeout}=300    ${gnb_index}=${0}    ${gnb_connection}=GNB_OAM    ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    Log to console    ${\n}----Verify all TDD-LTE Cells are unlocked----
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False}
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}    ${enb_connection}
    ${result}    Run Keyword And Return Status    Should Contain Any    ${stream_version}    12.400    14.400    22R1    22R2    21B
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${cell_info}   coam.get_cells_info    cell_type=lte    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        ${cell_technology}    Set variable    ${item['technology']}
        Run Keyword If    '${cell_technology}'=='TDD'    Set To Dictionary    ${cell_list_info}
        ...                                                                   ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR  ${cell}  IN   @{cell_list}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}    ${enabled}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['administrativeState']}    unlocked
        Run Keyword If    ${result}    Should Be Equal As Strings    ${cell_list_info['${cell}']['availabilityStatus']}    Online
    END
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}    AND
    ...    Run Keyword If   ${LTE_WHETHER_IN_GNB}==${False}   Run Keyword And Ignore Error   Enblte close down   connection=${enb_connection}

Update The DmrsTypeAPosition Value Of Cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=${0}    ${timeout}=600
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${MOs}    coam.get_managed_objects    class_name=NRCELL_A    connection=${connection}    timeout=${timeout}
    &{cell_dmrsTypeAPosition_mapping_list}    Create Dictionary
    FOR    ${mo}    IN    @{MOs}
        Set To Dictionary    ${cell_dmrsTypeAPosition_mapping_list}    ${mo['distName'].split('-')[-1]}=${mo['parameters']['dmrsTypeAPosition']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_dmrsTypeAPosition_mapping_list}
    @{params_for_update}    Create List
    FOR   ${cell}    IN     @{cell_list}
         ${dist_name}    Set Variable
         ...    MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${cell}
         ${value}    Set Variable If    '${cell_dmrsTypeAPosition_mapping_list['${cell}']}'=='pos2'    pos3    pos2
         ${param}    Create Dictionary    dist_name=${dist_name}    parameter=dmrsTypeAPosition    value=${value}
         Append To List    ${params_for_update}    ${param}
    END
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    Wait Gnb Ready And Cell On Air    gnb_id=${gnb_index}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Verify Specific RU Should Be Power Action
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param ${cell_type}: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    [Arguments]    ${cell_type}=nr    ${action}=power_off    ${timeout}=300    ${gnb_index}=0
    ...            ${gnb_connection}=GNB_OAM    ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    log     ${timeout}
    Log to console    ${\n}----Verify all ${cell_type} cells For All RUs Should Be Power Action----
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    @{aehc_ru_list}    Create List
    FOR    ${ru}    IN    @{list_RUs}
        ${rmod_info}   Set variable   ${ru['id']['configuration']}
        ${rmod_index}   Set variable    ${rmod_info.split('RMOD-')[-1]}
        Append To List    ${aehc_ru_list}    ${rmod_index}
    END
    ${new_aehc_ru_list}    Remove Duplicates    ${aehc_ru_list}
    FOR    ${aehc_ru}    IN    @{new_aehc_ru_list}
        Run Keyword If    '${action}'=='power_off'
        ...        Wait Until Keyword Succeeds    15 min    10 sec    RU Should Be Power Off    ru_index=${aehc_ru}    connection=${connection}
        ...    ELSE IF    '${action}'=='power_on'
        ...        Wait Until Keyword Succeeds    15 min    10 sec    RU Should Be Online    ru_index=${aehc_ru}    connection=${connection}
    END
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}    AND
    ...    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Perform Special RU Reset
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${ru_type}=AEHC    ${cell_type}=nr    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${False}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${sn_of_first_ru}    Set Variable    ${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}].serial_number}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    @{aehc_ru_list}    Create List
    FOR    ${ru}    IN    @{list_RUs}
        ${rmod_info}   Set variable   ${ru['id']['internal']}
        ${serialNumber}   Set variable    ${ru['serialNumber']}
        Run Keyword If    ${whether_get_first_ru_only}==${False} and '${ru['productName']}'=='${ru_type}'
        ...                             Append To List    ${aehc_ru_list}    ${rmod_info}
        ...    ELSE IF    ${whether_get_first_ru_only} and '${ru['productName']}'=='${ru_type}' and '${serialNumber}'=='${sn_of_first_ru}'
        ...                             Append To List    ${aehc_ru_list}    ${rmod_info}
        ...    ELSE IF    ${whether_get_first_ru_only}==${False} and '${ru_type}'=='all'
        ...                             Append To List    ${aehc_ru_list}    ${rmod_info}
    END
    FOR    ${ru_index}    IN    @{aehc_ru_list}
        Run Keyword And Ignore Error    coam.reset_unit    dist_name=${ru_index}     reset_type=Warm
        ...         force_radio_reset=${True}   connection=${connection}   timeout=${timeout}
    END
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}    AND
    ...    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Get Cell List For Special RU
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param ${cell_type}: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    ...                :param ${ru_type}:value like: "AEHC"
    ...                :param ${ru_index}: 0 means first AEHC, 1 means second AEHC, etc...
    [Arguments]    ${ru_type}=AEHC    ${cell_type}=nr    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${False}
    Log to console    ${\n}----Get all ${cell_type} cells For Special RU ${ru_type}----
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${LTE_WHETHER_IN_GNB}    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${sn_of_first_ru}    Set Variable    ${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}].serial_number}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    @{aehc_ru_list}    Create List
    FOR    ${ru}    IN    @{list_RUs}
        ${rmod_info}   Set variable   ${ru['id']['configuration']}
        ${rmod_index}   Set variable    ${rmod_info.split('RMOD-')[-1]}
        ${serialNumber}   Set variable    ${ru['serialNumber']}
        ${productName}   Set variable    ${ru['productName']}
        ${actual_ru_type}    Set Variable If    '${ru_type}'=='AEHC' and '${productName}'=='AVHA'    AVHA    ${ru_type}
        Run Keyword If    ${whether_get_first_ru_only}==${False} and '${productName}'=='${actual_ru_type}'
        ...                             Append To List    ${aehc_ru_list}    ${rmod_index}
        ...    ELSE IF    ${whether_get_first_ru_only} and '${productName}'=='${actual_ru_type}' and '${serialNumber}'=='${sn_of_first_ru}'
        ...                             Append To List    ${aehc_ru_list}    ${rmod_index}
    END
    ${aehc_ru_list_new}    Remove Duplicates    ${aehc_ru_list}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    @{aehc_cell_list}    Create List
    FOR    ${item}    IN    @{cell_info}
        ${rmod_info}    Get From List    ${item['carrierList']}    0
        ${rmod_id}    Get Regexp Matches    ${rmod_info['antennaLineId']['configuration']}    RMOD-(\\d+)    1
        ${cell_id}    Set variable    ${item['id']['configuration'].split('-')[-1]}
        ${cell_technology}    Set variable    ${item['technology']}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${aehc_ru_list_new}    ${rmod_id}[0]
        Run Keyword If    '${cell_technology}' != 'NB-IoT-FDD' and ${status}     Append To List    ${aehc_cell_list}    ${cell_id}
    END
    [Return]    ${aehc_cell_list}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}    AND
    ...    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}' and '${cell_type}'!='nr'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Get The CA Support List Value
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                get the value of carrierAggregationSupportList on GNB
    [Arguments]    ${timeout}=300    ${connection}=GNB_OAM    ${gnb_index}=0
    log    ${timeout}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${CA_support_list}    coam_parameter.get_single_value_from_scf_file    parameter=carrierAggregationSupportList
    ...                                                                    dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRDU-1
    ...                                                                    connection=${connection}
    ...                                                                    timeout=300
	[Return]    ${CA_support_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get The Flexible CA Mode Value
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                get the value of flexibleCAMode on GNB
    [Arguments]    ${timeout}=300    ${connection}=GNB_OAM    ${gnb_index}=0
    log    ${timeout}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${flexibleCAMode}    coam_parameter.get_single_value_from_scf_file    parameter=flexibleCAMode
    ...                                                                   dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRDU-1
    ...                                                                   connection=${connection}
    ...                                                                   timeout=300
	[Return]    ${flexibleCAMode}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Update The CA Support List Value
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Update the value of carrierAggregationSupportList and flexibleCAMode on GNB
    [Arguments]    ${carrierAggregationSupportList}=none
    ...            ${flexibleCAMode}=BasicCAMode
    ...            ${timeout}=300
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    ${status}    Run Keyword And Return Status    Evaluate    type(${carrierAggregationSupportList}).__name__
    ${carrierAggregationSupportList_to_list}    Run Keyword If    ${status}==${False}    Create List    ${carrierAggregationSupportList}
    ${ca_support_list}    Set Variable If    ${status}==${False}    ${carrierAggregationSupportList_to_list}
    ...                                                             ${carrierAggregationSupportList}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${flexibleCAMode}    Create Dictionary    dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRDU-1
    ...                                       parameter=flexibleCAMode
    ...                                       value=${flexibleCAMode}
    ${carrierAggregationSupportList}    Create Dictionary    dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRDU-1
    ...                                                      parameter=carrierAggregationSupportList
    ...                                                      value=${ca_support_list}
    @{param_list}    Create List    ${flexibleCAMode}    ${carrierAggregationSupportList}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}    timeout=${timeout}
    Check TMO Gnb Ready And All Cell On Air
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check RU Calibration Status And Power on Specifc RU
    [Documentation]  Author: tingting.1.liu@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM    ${asik_connection}=ASIK Master
    ...    ${retry_time}=3    ${ru_index}=1    ${dual_alias}=MultiRAT GNB Master
    ...    ${dualcore_hostname}=fct4s0icom.local    ${is_right_bbmod}=${True}   ${connection_right}=ASIK Right
    log    ${ru_index}
    log    ${dualcore_hostname}
    run keyword and ignore error    csn.disconnect    connection=${asik_connection}
    run keyword and ignore error    COAM Teardown gnb connections
    connection_alias_store.Connect to Common Unit Master    alias=${asik_connection}
    ${multiRAT}    Check if multiRAT BTS
    ${mutiRAT_amia_right}    If GNB In Right Side Of AMIA    connection=${asik_connection}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    run keyword if    ${multiRAT} and ${mutiRAT_amia_right}    Connect To MultiRAT GNB Common Unit Master
    run keyword if   '${multiRAT}'=='${False}' and ${is_right_bbmod}    csn.connect to
    ...               hostname=fct-4a
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${connection_right}
    ...               proxy=${asik_connection}
    ${asik_connection}    set variable if    ${multiRAT}    ${dual_alias}    ${connection_right}
    ${container_id}    set variable if    ${multiRAT}    ${0x1018}    ${0x2018}
    ${rmod_index}    Set Variable    ${PCELL_MAPPING['rmod_index']}
    ${pcell_ru_index}   Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    Connect to RU With Allocated IP    ru_index=${rmod_index}   ru_alias=RU${rmod_index}
    ...    ru_username=${tl.gnbs[0].dus[0].rus[${pcell_ru_index}].default_ssh_connection_details.username}
    ...    ru_password=${tl.gnbs[0].dus[0].rus[${pcell_ru_index}].default_ssh_connection_details.password}
    ...    asik_alias=${asik_connection}   connection=${connection}    container_id=${container_id}
    Run Keyword And Continue On Failure    Wait until keyword succeeds    ${retry_time}X    30 s
    ...    Check RU Calibration Status For TMO    ru_alias=RU${rmod_index}
    csn.Disconnect  connection=RU${rmod_index}
   [Teardown]  COAM Teardown gnb connections

Check RU Calibration Status For TMO
    [Documentation]  Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${ru_alias}    ${carrier_name}=NR
    ${calibration_output}    csn.execute    command=bfcali -stat    connection=${ru_alias}
    @{nr_calibration}    create list
    @{calibrations}    split string    ${calibration_output}    \r\n\r\n
    FOR    ${latest_cali}    IN    @{calibrations}
           ${status}    run keyword and return status    should contain    ${latest_cali}    ${carrier_name}
           run keyword if    '${status}'=='${True}'    append to list      ${nr_calibration}    ${latest_cali}
    END
    FOR    ${each_cali}    IN    @{nr_calibration}
           ${attempt_regexp}    set variable    Calibration attempts: (\\d+)
           ${success_regexp}    set variable    Successful calibrations: (\\d+)
           ${attempt_count}    Get Regexp Matches    ${each_cali}    ${attempt_regexp}    1
           ${success_count}    Get Regexp Matches    ${each_cali}    ${success_regexp}    1
           ${couter_value}    Evaluate    ${attempt_count[0]}-${success_count[0]}
           should be true    (${couter_value}==0) | (${couter_value}==1)
    END

Set Fiber Switch Into Link Failure Or Link Up
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    ...       para:${link_status} can be "down" or "up"
    ...       Connects to optical switch and sets switch into link failure position for given radio.
    [Arguments]    ${channel_numbers}   ${link_status}
    ...             ${ru_id}=0
    ...             ${gnb_id}=0
    ...             ${du_id}=0
    ...             ${dummy_output_channel}=00
    &{linkup_setting}       create dictionary
    &{link_failure_settings}    create dictionary
    FOR    ${n}    IN    @{channel_numbers}
         ${module_no}    set variable     ${tl.gnbs[${gnb_id}].dus[${du_id}].rus[${ru_id}].optical_switch_channels[${n}].switch_module.module_no}
         ${channel_no}    set variable     ${tl.gnbs[${gnb_id}].dus[${du_id}].rus[${ru_id}].optical_switch_channels[${n}].channel_no}
         ${in_port}    Convert To String    ${module_no}
         ${out_port}    Convert To String    ${channel_no}
         Run Keyword If    '${link_status}'=='down'   Set To Dictionary
         ...                                             ${link_failure_settings}    ${in_port}=${dummy_output_channel}
         ...    ELSE IF   '${link_status}'=='up'      Set To Dictionary    ${linkup_setting}    ${in_port}=${out_port}
    END
    ${connection}    Set Variable If    '${link_status}'=='down'     ${link_failure_settings}    ${linkup_setting}
    Switch RU And Verify Connection State    connection=${connection}

Update The Flag Whether Support 3CC
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                update the flag Of 3CC------'ca_Fdd_Any_Sa for CB002640' and 'ca_Fr1Tdd_Any_Sa for CB006138'
    [Arguments]    ${3CC_flag}=${False}    ${connection}=GNB_OAM    ${gnb_index}=0
    ...            ${timeout_for_commission}=1200    ${wait_gnb_up_timeout}=20 min
    ...            ${timeout}=300    ${is_pdl_checking_needed}=${True}
    ${flexibleCAMode}    Get The Flexible CA Mode Value
    ${ca_list}    Get The CA Support List Value
    ${tmp_list}    Create List    ca_Fdd_Any_Sa    ca_Fr1Tdd_Any_Sa
    ${status}    Run Keyword And Return Status    List Should Contain Sub List    ${ca_list}    ${tmp_list}
    ${operation}    Set Variable If    ${3CC_flag}    add    delete
    ${maxNumScellsDlFr1_param}    Set Variable If    ${3CC_flag}    maxNumScellsDlFr1=3    maxNumScellsDlFr1
#    ${result}    Run Keyword And Return Status    Should Contain Any    ${stream_version}    23R2    23R3    23R4    master
    ${result}    Set Variable If    '${stream_version}'=='23R1'    ${False}    ${True}
    ${ca_support_list1}    Catenate    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Fdd_Sa,
    ...                                ca_Fr1Tdd_Fdd_Nsa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Fdd_Sa_WithUl
    ${ca_support_list2}    Set Variable
    ...  ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Nsa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa
    ${ca_support_3cc}    Set Variable If    ${result}    ${ca_support_list1}    ${ca_support_list2}
    ${ca_support_list3}    Catenate
    ...  ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,
    ...  ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Nsa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Fdd_Sa_WithUl
    ${ca_support_list4}    Set Variable
    ...  ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Nsa
    ${ca_support_2cc}    Set Variable If    ${result}    ${ca_support_list3}    ${ca_support_list4}
    ${support_list}    Set Variable If    ${3CC_flag}    ${ca_support_3cc}    ${ca_support_2cc}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${cell_info}   coam.get_cells_info    cell_type=nr    timeout=${timeout}    connection=${connection}
    @{param_list}    Create List
    FOR    ${item}    IN    @{cell_info}
        ${maxNumScellsDlFr1_value}    coam_parameter.get_single_value_from_scf_file    parameter=maxNumScellsDlFr1
        ...                                                                            dist_name=${item['id']['configuration']}
        ...                                                                            connection=${connection}
        ...                                                                            timeout=300
        ${list_length}    Get Length    ${maxNumScellsDlFr1_value}
        Run Keyword If    ${list_length}!=${0} and '${operation}'=='delete'    Append To List
        ...    ${param_list}    ${operation}:${item['id']['configuration']}:${maxNumScellsDlFr1_param}
        Run Keyword If    ${list_length}==${0} and '${operation}'=='add'    Append To List
        ...    ${param_list}    ${operation}:${item['id']['configuration']}:${maxNumScellsDlFr1_param}
    END
#    Run Keyword If    '${flexibleCAMode}'!='ConfigurationIndependent'    Append To List
#    ...    ${param_list}    modify:NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRDU-1:flexibleCAMode=ConfigurationIndependent
    Run Keyword If    ${3CC_flag} and ${status}==${False}    Append To List
    ...    ${param_list}    modify:NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRDU-1:carrierAggregationSupportList=${support_list}
    Run Keyword If    ${3CC_flag}==${False} and ${status}    Append To List
    ...    ${param_list}    modify:NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRDU-1:carrierAggregationSupportList=${support_list}
    ${param_list_length}    Get Length    ${param_list}
    ${update_scf_with_case_params}    Run Keyword If    ${param_list_length}!=${0}
    ...    perform_update_scf_params_for_current_scf    update_params=${param_list}    connection=${connection}
    Run Keyword If    ${param_list_length}!=${0}    Perform Commission    scf_file_path=${update_scf_with_case_params}
    ...                                                                   gnb_index=${gnb_index}
    ...                                                                   timeout_for_commission=${timeout_for_commission}
    ...                                                                   wait_gnb_up_timeout=${wait_gnb_up_timeout}
    ...                                                                   is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If    ${param_list_length}!=${0}    Check TMO Gnb Ready And All Cell On Air
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Add Or Delete Scell Of All NR Cells
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                add or delete the parameter "sCellAdditionMethod" for all cell
    [Arguments]    ${param_list}    ${connection}=GNB_OAM0    ${gnb_index}=0
    ...            ${timeout_for_commission}=900    ${wait_gnb_up_timeout}=20 min
    ...            ${timeout}=300    ${is_pdl_checking_needed}=${True}
    log    ${timeout}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${update_scf_with_case_params}    perform_update_scf_params_for_current_scf
    ...                               update_params=${param_list}
    ...                               connection=${connection}
    Perform Commission    scf_file_path=${update_scf_with_case_params}
    ...                   gnb_index=${gnb_index}
    ...                   timeout_for_commission=${timeout_for_commission}
    ...                   wait_gnb_up_timeout=${wait_gnb_up_timeout}
    ...                   is_pdl_checking_needed=${is_pdl_checking_needed}
    Check TMO Gnb Ready And All Cell On Air
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get The Parameter List Of NRREL Config
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM0    ${gnb_index}=0
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${nrrel_mos}    gnbaction.get_nrrel_config
    @{delete_param_list}    Create List
    @{add_param_list}    Create List
    FOR    ${mo}    IN    @{nrrel_mos}
        ${nrcell_id}    Set Variable    ${mo['distName'].split('/')[-2].split('-')[-1]}
        ${nrrel_id}    Set Variable    ${mo['distName'].split('/')[-1].split('-')[-1]}
        ${dist_name}    Set Variable    NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${nrcell_id}/NRREL-${nrrel_id}
        ${sCellAdditionMethod_status}    Run Keyword And Return Status
        ...    Should Contain Any    ${mo['parameters']['sCellAdditionMethod']}    covBasedA1    blind
        Run Keyword If    ${sCellAdditionMethod_status}    Run Keywords
        ...    Append To List    ${delete_param_list}    delete:${dist_name}:sCellAdditionMethod    AND
        ...    Append To List    ${add_param_list}    add:${dist_name}:sCellAdditionMethod=${mo['parameters']['sCellAdditionMethod']}
        ${sCellOperationalMode_status}    Run Keyword And Return Status
        ...    Should Contain Any    ${mo['parameters']['sCellOperationalMode']}    dlOnly    dlandUl
        Run Keyword If    ${sCellOperationalMode_status}    Run Keywords
        ...    Append To List    ${delete_param_list}    delete:${dist_name}:sCellOperationalMode    AND
        ...    Append To List    ${add_param_list}    add:${dist_name}:sCellOperationalMode=${mo['parameters']['sCellOperationalMode']}
    END
    [Return]    ${delete_param_list}    ${add_param_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Do All RU Locked Or Unlocked On Gnb
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    ...    para:${ru_status}  value can be "Locked or Unlocked"
    [Arguments]     ${ru_status}   ${connection}=GNB_OAM    ${timeout}=600   ${enb_connection}=enblte   ${enb_index}=${1}
    ...             ${gnb_id}=${0}
    ${lte_whether_in_gnb}    Check LTE Whether In Gnb
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    &{fault_1931}     Create Dictionary     faultId=${1931}
    ${ENB_ALLOWED_FAULT}    Create List    @{GNB_ALLOWED_FAULT}    ${fault_1931}
    @{ru_list}    Create List
    ${hw_info}    coam.get_detected_hw_info    connection=GNB_OAM
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    @{ru_list}    Create List
    FOR  ${ru}  IN  @{list_RUs}
        log to console   ${ru}
        ${rmod_index}   Set variable   ${ru['id']['configuration']}
        ${ru_index}   Set variable    ${rmod_index.split('RMOD-')[-1]}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_init_index}    IN    @{ru_list}
        ${ru_index}    Evaluate    int(${ru_init_index})
        Run Keyword If   '${ru_status}'=='Locked'    coam.lock    connection=${connection}
        ...    dist_name=MRBTS-${tl.gnbs[${gnb_id}].global_bts_id}/EQM-1/APEQM-1/RMOD-${ru_index}   timeout=${timeout}
        Run Keyword If   '${ru_status}'=='Unlocked'  coam.unlock   connection=${connection}
        ...    dist_name=MRBTS-${tl.gnbs[${gnb_id}].global_bts_id}/EQM-1/APEQM-1/RMOD-${ru_index}   timeout=${timeout}
        &{status}    Run Keyword If   '${LTE_WHETHER_IN_GNB}'=='${False}'   COAM get ru detial info by ru index
        ...                         ru_index=${ru_index}   connection=${connection}
        Run Keyword If   '${LTE_WHETHER_IN_GNB}'=='${False}' and '${ru_status}'=='Locked'
        ...              Should be equal as strings    ${status['status']['administrativeState']}    Locked
        Run Keyword If   '${LTE_WHETHER_IN_GNB}'=='${False}' and '${ru_status}'=='Unlocked'
        ...              Should be equal as strings    ${status['status']['administrativeState']}    Unlocked
        Run Keyword If   '${ru_status}'=='Locked'    run keyword and continue on failure    Wait Until Keyword Succeeds
        ...    180 sec    3 sec    RU Should Be Locked    ru_index=${ru_index}    connection=${connection}
        Run Keyword If   '${ru_status}'=='Unlocked'   run keyword and continue on failure    Wait Until Keyword Succeeds
        ...    400 sec    3 sec    RU Should Be Unlocked    ru_index=${ru_index}    connection=${connection}
        Run Keyword And Continue On Failure      Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
    END
    Run Keyword If    '${LTE_WHETHER_IN_GNB}'=='${False}'    Connect to eNB via ssl    connection=${enb_connection}
    ...                                                         enb_index=${enb_index}
    Run Keyword If   '${LTE_WHETHER_IN_GNB}'=='${False}' and '${ru_status}'=='Locked'    Run Keyword And Continue On Failure
        ...    Unexpect Alarm Should Not Exist    allowed_faults=${ENB_ALLOWED_FAULT}    connection=${enb_connection}
    Run Keyword If   '${LTE_WHETHER_IN_GNB}'=='${False}' and '${ru_status}'=='Unlocked'    Run Keyword And Continue On Failure
    ...    Unexpect Alarm Should Not Exist    allowed_faults=${ENB_ALLOWED_FAULT}    connection=${enb_connection}
#    Run Keyword If    '${LTE_WHETHER_IN_GNB}'=='${False}'    Connect to eNB via ssl    connection=${enb_connection}
#    ...                                                         enb_index=${enb_index}
    Run Keyword If    '${LTE_WHETHER_IN_GNB}'=='${False}' and '${ru_status}'=='Locked'    Run Keyword And Continue On Failure
    ...    Wait For Expect Fault Present  faultId=${1931}  timeout=${timeout}  connection=${enb_connection}
    ...                                   is_need_to_setup_gnb_connection=${False}
    Run Keyword If   '${LTE_WHETHER_IN_GNB}'=='${False}' and '${ru_status}'=='Unlocked'    Run Keyword And Continue On Failure
    ...    Wait For Expect Fault To Disappear   faultId=${1931}  timeout=${timeout}    connection=${enb_connection}
    ...                                         is_need_to_setup_gnb_connection=${False}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}   AND
    ...           Run Keyword If    '${LTE_WHETHER_IN_GNB}'=='${False}'   Run Keyword And Ignore Error
    ...                                                   Enblte close down    connection=${enb_connection}

Set cellBarred information for cell
    [Documentation]    author:andy
    [Arguments]    ${dist_name}    ${value}    ${bts_index}=0
    @{para_list}   Create List   cellBarred
    @{value_list}   Create List   ${value}
    @{mo_list}   Create List   ${dist_name}
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}    bts_index=${bts_index}
    Log To Console    paramter update result: ${out}

Check Syslog During Timestamps
    [Arguments]     ${input_syslog_list}
    ${cur_timestamp}    Get current date    result_format=%Y%m%dT%H%M%S
    ${syslog_file}    merge_syslog_tgz_files    input_files=${input_syslog_list}
    ...    output_file=/home/ute/test_syslog/${TEST NAME}/SYSLOG_${cur_timestamp}/SYSLOG.tgz
    ${syslog_file_path}    Run Keyword And Continue On Failure    Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=90 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
#    ${local_file_path}    Set Variable    /home/ute/test_syslog/${TEST NAME}/SYSLOG_${cur_timestamp}/
#    ${remote_path}    Set Variable    /home/hz4sg6/shared/03_Test_Syslog/${TEST NAME}/SYSLOG_${cur_timestamp}/
#    Run Keyword And Ignore Error    copy_local_to_remote
#    ...    local_path=${local_file_path}
#    ...    remote_path=${remote_path}
#    ...    hostname=${samba_server_ip}
#    ...    username=${samba_server_username}
#    ...    password=${samba_server_password}