*** Settings ***
Documentation      Author: jia-rebecca.liu@nokia-sbell.com
...                squad group: SG_03
...                feature : CB009444


Suite Setup    Run keyword And Ignore Error    Common Suite Setup for Cloud



Resource    ../Resources/HO_common_keywords.robot
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009881-CR/Resources/upgrad_with_kuafu.py
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009881-CR/Resources/upgrad_with_kuafu_via_thread.py


*** Variables ***
@{pm_all_list}
${traffic_direction}    DLUL
${atten_ip}    ${tl.attenuator[0].ip_addr}
${att_api_port}    ${tl.attenuator[0].port}
${max_attenuation_value}    ${127}
${vendor}    ${tl.attenuators[0].vendor}
${interval}    12
${pa_settime}    0.6
${paerror_counter}    0
${enb1_def_gnb_dist}    MRBTS-$[tl.enbs[0].instance_id}/LNBTS-$[tl.enbs[0].instance_id}/LNCEL-0
${target_build_file}    /opt/workspace/SCF/new_version.txt
${ue_info_path}    /opt/workspace/SCF/TL239_ue_traffic_info.yml

*** Test Cases ***
case1_upgrade cloud via kuafu
    [Documentation]     upgrade VCU1,VCU2,VDU1,VDU2,VDU3
    [Tags]    upgrade_all
    [Setup]
    upgrade_cloud_via_kuafu    target_build_file=${target_build_file}    match_mode=vdu
    ...                        host_vdu1=${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...                        username_vdu1=${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...                        password_vdu1=${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ...                        host_vdu2=${tl.gnbs[0].dus[1].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...                        username_vdu2=${tl.gnbs[0].dus[1].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...                        password_vdu2=${tl.gnbs[0].dus[1].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ...                        host_vdu3=${tl.gnbs[1].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...                        username_vdu3=${tl.gnbs[1].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...                        password_vdu3=${tl.gnbs[1].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    upgrade_cloud_via_kuafu    target_build_file=${target_build_file}    match_mode=vcu
    ...                        host_vcu1=${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...                        username_vcu1=${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...                        password_vcu1=${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ...                        host_vcu2=${tl.gnbs[1].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...                        username_vcu2=${tl.gnbs[1].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...                        password_vcu2=${tl.gnbs[1].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}


case2_upgrade VCUs via kuafu
    [Documentation]    upgrade all vcus
    [Tags]    upgrade_cu
    [Setup]
    upgrade_cloud_via_kuafu    target_build_file=${target_build_file}    match_mode=vcu
    ...                        host_vcu1=${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...                        username_vcu1=${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...                        password_vcu1=${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ...                        host_vcu2=${tl.gnbs[1].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...                        username_vcu2=${tl.gnbs[1].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...                        password_vcu2=${tl.gnbs[1].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}



case3_upgrade VDUs via kuafu
    [Documentation]     upgrade all vdus
    [Tags]    upgrade_vdus
    [Setup]
    upgrade_cloud_via_kuafu    target_build_file=${target_build_file}    match_mode=vdu
    ...                        host_vdu1=${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...                        username_vdu1=${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...                        password_vdu1=${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ...                        host_vdu2=${tl.gnbs[0].dus[1].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...                        username_vdu2=${tl.gnbs[0].dus[1].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...                        password_vdu2=${tl.gnbs[0].dus[1].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ...                        host_vdu3=${tl.gnbs[1].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...                        username_vdu3=${tl.gnbs[1].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...                        password_vdu3=${tl.gnbs[1].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}



case4_upgrade VDU_1_2 via kuafu
    [Documentation]    upgrade VDU1 and VDU2 only
    [Tags]    upgrade_vdu12
    [Setup]
    ${new_build_vdu}    read_target_version      target_build_file=${target_build_file}    match_mode=vdu
    delete_and_config_vdu    host=${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...                      username=${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...                      password=${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ...                      new_build=${new_build_vdu}
    delete_and_config_vdu    host=${tl.gnbs[0].dus[1].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...                      username=${tl.gnbs[0].dus[1].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...                      password=${tl.gnbs[0].dus[1].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ...                      new_build=${new_build_vdu}

