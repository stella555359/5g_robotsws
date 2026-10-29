*** Settings ***
Documentation    This is for feature CB014474 related common keywords.
...              Please do not modify the file without notification to author
...              Author:jia-rebecca.liu@nokia-sbell.com & yayun.zhang@nokia-sbell.com
...              Squard: HZ SG3


Library    OperatingSystem
Library    Collections
Library    String
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/dingli_multiUE.robot
Library            testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB014474/Resources/CB014474_common_keywords.py
Variables          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB014474/Resources/CB014474_Variables.py

*** Variables ***
${allow_fault_list_14474}                    7101    7107    62003
${gnb1_instance}                             ${tl.gnbs[0].instance_id}
${gnb2_instance}                             ${tl.gnbs[1].instance_id}

${SCF_name_38711}                            SCF_GNB1
${SCF_name_38712}                            SCF_GNB2
${SCF_name_36411}                            golden_scf_8898
${scf_path}                                  /opt/workspace/SCF/
@{gnb_list}                                  ${0}    ${1}
${bts_host0}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${bts_host1}    ${tl.gnbs[1].cu.oam_http_connection_details.addr}
#-----------UE-----------#
${ue_type_samsung}                            ${tl.ues[12].capabilities[1]}

#-----------TL387 PA----------#
${att_ipaddr_gnb1_38711}                      ${tl.attenuator[0].ip_addr}
${att_api_gnb1_port}                          ${tl.attenuator[0].port}
${att_port_1_gnb1_cell1_38711}                ${tl.attenuator[0].attenuator_ports[1].port_no}
${att_port_2_gnb1_cell1_38711}                ${tl.attenuator[0].attenuator_ports[2].port_no}
${att_port_3_gnb1_cell1_38711}                ${tl.attenuator[0].attenuator_ports[3].port_no}
${att_port_4_gnb1_cell1_38711}                ${tl.attenuator[0].attenuator_ports[4].port_no}
${att_port_5_gnb1_cell2_38711}                ${tl.attenuator[0].attenuator_ports[5].port_no}
${att_port_6_gnb1_cell2_38711}                ${tl.attenuator[0].attenuator_ports[6].port_no}
${att_port_7_gnb1_cell2_38711}                ${tl.attenuator[0].attenuator_ports[7].port_no}
${att_port_8_gnb1_cell2_38711}                ${tl.attenuator[0].attenuator_ports[8].port_no}
${att_port_9_gnb1_cell3_38711}                ${tl.attenuator[0].attenuator_ports[9].port_no}
${att_port_10_gnb1_cell3_38711}               ${tl.attenuator[0].attenuator_ports[10].port_no}
${att_port_11_gnb1_cell3_38711}               ${tl.attenuator[0].attenuator_ports[11].port_no}
${att_port_12_gnb1_cell3_38711}               ${tl.attenuator[0].attenuator_ports[12].port_no}
${att_port_13_enb_cell1_38721}                ${tl.attenuator[0].attenuator_ports[13].port_no}
${att_port_14_enb_cell1_38721}                ${tl.attenuator[0].attenuator_ports[14].port_no}
${att_ipaddr_gnb2_38712}                      ${tl.attenuator[1].ip_addr}
${att_api_gnb2_port}                          ${tl.attenuator[1].port}
${att_port_1_gnb2_cell1_38712}                ${tl.attenuator[1].attenuator_ports[1].port_no}
${att_port_2_gnb2_cell1_38712}                ${tl.attenuator[1].attenuator_ports[2].port_no}
${att_port_3_gnb2_cell1_38712}                ${tl.attenuator[1].attenuator_ports[3].port_no}
${att_port_4_gnb2_cell1_38712}                ${tl.attenuator[1].attenuator_ports[4].port_no}
${att_port_5_gnb2_cell2_38712}                ${tl.attenuator[1].attenuator_ports[5].port_no}
${att_port_6_gnb2_cell2_38712}                ${tl.attenuator[1].attenuator_ports[6].port_no}
${att_port_7_gnb2_cell2_38712}                ${tl.attenuator[1].attenuator_ports[7].port_no}
${att_port_8_gnb2_cell2_38712}                ${tl.attenuator[1].attenuator_ports[8].port_no}
${att_port_9_gnb2_cell3_38712}                ${tl.attenuator[1].attenuator_ports[9].port_no}
${att_port_10_gnb2_cell3_38712}               ${tl.attenuator[1].attenuator_ports[10].port_no}
${att_port_11_gnb2_cell3_38712}               ${tl.attenuator[1].attenuator_ports[11].port_no}
${att_port_12_gnb2_cell3_38712}               ${tl.attenuator[1].attenuator_ports[12].port_no}






*** Keywords ***
#-----------------------------preparation-----------------------#
CB014474_suite_setup
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



CB014474_suite_teardown
    CI_interface.Common Case Teardown
    Run keyword and ignore error    Tear down the all connections
    robot_common_operations.Common Suite Teardown


CB014474_case_setup
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


CB014474_case_teardown
    robot_common_operations.Common Case Teardown
    run keyword and ignore error    COAM Save snapshot via api
    Run keyword and ignore error    stop VONR call and detach UE
    Run keyword and ignore error    Teardown the all connections
    Run keyword and ignore error    CI_interface.Common Case Teardown

get physicalCellId from coam_gnb_classical
    [Documentation]    jia-rebecca.liu additional method get physicalCellId
    [Arguments]    ${lcrid}=1    ${gnb_index}=${0}    #${connection}=GNB_OAM
    Wait Until Keyword Succeeds    5m    10s    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    &{config_info}    Create dictionary
    &{NR_CELL_ID_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids    gnb_index=${gnb_index}
    ${physicalCellId}    set variable    ${NR_CELL_ID_MAPPING[${lcrid}]['physicalCellId']}
    [Return]    ${physicalCellId}
    [Teardown]    COAM Teardown gnb connections

CB014474 Common Case TestLine Setup with gnb1 and gnb2
    @{scf_list}    Create List
#    ${release_info}    Get sagnb release
    Append to List    ${scf_list}
    ...    ${scf_path}${SCF_name_${gnb1_instance}}_${release_info}.xml    ${scf_path}${SCF_name_${gnb2_instance}}_${release_info}.xml
    Log to console    Start to modify scf files and commission, please wait...
    Multi-gNB commission    index_list=${gnb_list}    scf_list=${scf_list}
    CB014474 Check the MultiBTS cells status on air    gnb_list=${gnb_list}

CB014474 Check the MultiBTS cells status on air
    [Documentation]
    ...    Description: check multi gnb cells is on air
    ...    para gnb_list: gnb_index_list(type is list) '@{gnb_list}', Default is 0  1
    [Arguments]        ${gnb_list}=${gnb_list}
    FOR    ${gnb_index}    IN    @{gnb_list}
        Wait until keyword succeeds    20 min    20s
        ...    Check the cells status on air    bts_host=${bts_host${gnb_index}}   connection=gnb${gnb_index}
    END
# --------------------------------PA--------------------------------#

Adjust Attenuation value for GNB1_CELL2
    [Arguments]     ${tl}=${gnb1_instance}    ${gnb1_cell2_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell2}    Create List    ${att_port_5_gnb1_cell2_${tl}}    ${att_port_6_gnb1_cell2_${tl}}
    ...    ${att_port_7_gnb1_cell2_${tl}}    ${att_port_8_gnb1_cell2_${tl}}
    ###create value list####
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value of ports simultaneously    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_5_gnb1_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb1_${tl}}

#------------------------------------UE----------------------------------#
samsung Make Vonr Call With Command
    [Arguments]    ${ue_index}=${12}
    ...            ${phone_number}=+6688
    ...            ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...            ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...            ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...            ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:${phone_number}
    ...    connection=cpc_${ue_index}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

samsung hangup VoNR call
    [Arguments]    ${ue_index}=${12}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cpc_${ue_index}
    sleep    5s
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

stop VONR call and detach UE
    [Arguments]    ${ue_index}=${12}    ${ue_type}=${ue_type_samsung}
    samsung hangup VoNR call    ue_index=${ue_index}
    sleep    5s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Andriod UE adb disable data services
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command     command=adb -s ${serial_number} shell svc data disable    connection=cygwin
    sleep    3s
    [Teardown]   csn.Disconnect   connection=cygwin

Andriod UE adb enable data services for s21
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command     command=adb -s ${serial_number} shell svc data enable    connection=cygwin
    sleep    3s
    [Teardown]   csn.Disconnect   connection=cygwin
#-------------------------------------logs----------------------------------------#
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

add or delete 5QI via npc dynamic rule
    [Arguments]    ${imsi}    ${rule}
    ${return_code}    ${return_result}    dynamic rule submit    imsi=${imsi}    rule=${rule}
    run keyword if    '${return_result}' == 'Success'    run keywords
    ...    log    ${rule} operate Success!
    ...    AND    log to console    ${rule} operate Success!
    ...    ELSE    run keywords
    ...    log    ${rule} operate Failed!
    ...    AND    log to console    ${rule} operate Failed!
    ...    AND    fail    msg=need to check on SRN CHINA web page

HAOJIN MCS SETUP AND SET ATT for MultiUE
    [Arguments]    ${mcs_type}    ${att_value_UE0}    ${att_value_UE1}
    ...    ${P1_out}    ${P2_out}    ${P3_out}    ${P4_out}    ${vertical_1}    ${horizontal_1}    ${horizontal_2}    ${vertical_2}
    ...    ${P5_out}    ${P6_out}    ${P7_out}    ${P8_out}    ${vertical_3}    ${horizontal_3}    ${horizontal_4}    ${vertical_4}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    vendor=HAOJIN
    HAOJIN MCS change UE Position    mcs_type=${mcs_type}
    ...    begin_output_port_1=${P1_out}    end_output_port_2=${P2_out}    vertical_angle_1=${vertical_1}    horizontal_angle_1=${horizontal_1}
    ...    begin_output_port_3=${P3_out}    end_output_port_4=${P4_out}    vertical_angle_2=${vertical_2}    horizontal_angle_2=${horizontal_2}
    HAOJIN MCS change UE Position    mcs_type=${mcs_type}
    ...    begin_output_port_1=${P5_out}    end_output_port_2=${P6_out}    vertical_angle_1=${vertical_3}    horizontal_angle_1=${horizontal_3}
    ...    begin_output_port_3=${P7_out}    end_output_port_4=${P8_out}    vertical_angle_2=${vertical_4}    horizontal_angle_2=${horizontal_4}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_UE0}
    ...    begin_output_port=${13}    end_output_port=${16}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_UE1}
    ...    begin_output_port=${9}    end_output_port=${12}

#####-------------------MCS---------------------#######
HAOJIN MCS change UE Position
    [Arguments]     ${mcs_type}    ${begin_output_port_1}    ${end_output_port_2}    ${vertical_angle_1}    ${horizontal_angle_1}
    ...    ${begin_output_port_3}    ${end_output_port_4}
    ...    ${vertical_angle_2}     ${horizontal_angle_2}
    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...    begin_output_port=${begin_output_port_1}    end_output_port=${end_output_port_2}     input_group_id=${0}
    ...    vertical_angle=${vertical_angle_1}
    ...    horizontal_angle=${horizontal_angle_1}    vertical_distance=${2.0}    horizontal_distance=${0.5}
    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...    begin_output_port=${begin_output_port_3}    end_output_port=${end_output_port_4}     input_group_id=${0}
    ...    vertical_angle=${vertical_angle_2}
    ...    horizontal_angle=${horizontal_angle_2}    vertical_distance=${2.0}    horizontal_distance=${0.5}