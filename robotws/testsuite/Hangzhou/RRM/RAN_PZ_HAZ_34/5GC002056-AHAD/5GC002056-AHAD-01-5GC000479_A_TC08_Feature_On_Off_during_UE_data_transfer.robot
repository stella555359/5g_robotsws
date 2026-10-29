# *** Settings ***
# Force Tags    PY36
# Documentation    Suite description
# ...   author: jiao.1.yang@nokia-sbell.com
# ...   contact: jiao.1.yang@nokia-sbell.com
#
#
# Library         taf.transport.ssh            WITH NAME    ssh
# Library         taf.ue                       WITH NAME    ute_ue
# Library         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
# Library         taf.hw.rf_attenuator           WITH NAME    att
# Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/UEs/inseego.robot
# Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#
#
# *** Variables ***
# ${DU_OAM_IP}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
# ${DU_OAM_WEBUI_USER}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${BTS_ID}    ${tl.gnbs[0].global_bts_id}
# ${att_ipaddr}    ${tl.attenuator.ip_addr}
# ${att_api_port}    ${tl.attenuator.port}
# ${att_port_5}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
# ${att_port_6}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
# ${att_port_7}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
# ${att_port_8}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
# ${server_ip}         ${tl.appserver.iperf_details.network_interface_address}
# ${appserver_addr}    ${tl.ues[1].iperf_details.ssh_connection_details.addr}
#
# *** Test Cases ***
# [1]5GC002056-AHAD-01-5GC000479_A_TC08_Feature_On_Off_during_UE_data_transfer
#     [Tags]      CRT_TRUNK        CRT_22R2
#     [Setup]
#     Log To Console    Prepare Askey
#     Adjust HBTE Attenuation
#     Askey Attach and start traffic and check throughput
#     FOR    ${item}    IN RANGE    ${10}
#         Modify Parameters     Actual_value=false
#         Modify Parameters     Actual_value=true
#     END
#     [Teardown]    recovery case ENV
#
# *** Keywords ***
# Askey Attach and start traffic and check throughput
#     Log To Console    Askey Attach
#     power_ue.Prepare UE    ue_type=askey_sigspark    ue_index=${0}
#     ${5Grach_ed_0}    power_ue.UE Attach   ue_type=askey_sigspark    ue_index=${0}
#     power_ue.Verify attach    ue_type=askey_sigspark    5Grach_ed=${5Grach_ed_0}    4G_check=False    ue_index=${0}
#     power_ue.Start traffic    ue_type=askey_sigspark    direction=ul    throughput=100M    duration=1000
#     ...    ue_index=${0}    ue_mode=NSA
# #    power_ue.Check throughput    ue_type=askey_sigspark    direction=ul    throughput=2    ue_index=${0}
#
# recovery case ENV
#     power_ue.Stop traffic    ue_type=askey_sigspark    direction=ul    ue_index=${0}
#     run keyword and ignore error    power_ue.UE Detach    ue_type=askey_sigspark    ue_index=${0}
#     CI_interface.Common Case Teardown
#
# Modify Parameters
#     [Arguments]    ${Actual_value}     ${connection}=GNB_OAM
#     Connect to gnb coam via ssl     bts_host=${DU_OAM_IP}
#     ${dict}    create dictionary    parameterName=actInactDetNSAUe    operation=update    value=${Actual_value}
#     ${list}    create list    ${dict}
#     coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}     connection=${connection}
#     ...    parameter=${list}    operation=update    skip_parameter_relation_errors=${true}    should_activate=${True}
#     Wait Until BTS Should Be Normal
#     [Teardown]    COAM Teardown gnb connections
#
# Wait Until BTS Should Be Normal
#     [Arguments]   ${retry}=400s    ${retry_interval}=10s
#     [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
#     Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Gnb Cell Should Be Onair
#
# Gnb Cell Should Be Onair
#     [Arguments]  ${alias}=GNB_OAM
#     ${status}      coam.Get_Bts_Statuses   connection=${alias}
#     ${proceduralState}   Get From Dictionary    ${status}   proceduralState
#     Should Be Equal    ${proceduralState}    OnAir
#
# Adjust HBTE Attenuation
#     Log To Console    Adjust HBTE Attenuation
#     att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
#     ...    attenuation_port_numbers=${att_port_5}    max_attenuation=${127}    vendor=HBTE
#     att.set_attenuation    port=${att_port_5}    value=${20}
#     att.set_attenuation    port=${att_port_6}    value=${20}
#     att.set_attenuation    port=${att_port_7}    value=${20}
#     att.set_attenuation    port=${att_port_8}    value=${20}
