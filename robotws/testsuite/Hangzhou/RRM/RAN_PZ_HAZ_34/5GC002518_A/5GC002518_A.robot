# *** Settings ***
# Force Tags    PY36
# Suite Setup
# Suite Teardown    CI_interface.Common Case Teardown
# Documentation
# ...   author: xiaofeng.1.zhu@nokia-sbell.com
# ...   contact: xiaofeng.1.zhu@nokia-sbell.com
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
# Resource          taf/rfrl/common_resources/robot/libraries_instances.robot
#
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/UEs/inseego.robot
# Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Library    taf.analyzer.pcap    WITH NAME    check_cap
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#
# Library           taf.transport.ssh    WITH NAME    csn
# Library           taf.hw.rf_attenuator    WITH NAME    att
# Library           taf.ue  WITH NAME   ute_ue
# *** Variables ***
# ${CURDIR_path1}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_0_800_DU.xml
# ${DU_OAM_WEBUI_USER}        ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${DU_OAM_IP_TL}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_SSH_USERNAME_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
# ${DU_OAM_SSH_PASSWORD_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
# ${ENB_IP}                      ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# ${test_ute}                   ${tl.test_pc.default_ssh_connection_details.addr}
# ${ute_name}                   ${tl.test_pc.default_ssh_connection_details.username}
# ${test_password}              ${tl.test_pc.default_ssh_connection_details.password}
# ${UE_type}                   ${tl.ues[2].capabilities[-2]}
#
# ${epc_log_path}              /tmp
# ${connection}                GNB_OAM
# ${vendor}                    HBTE
# ${luashark_path}             /opt/ute/luashark/luashark_script/generated_luashark
# ${TS_CASE_LOG_PATH}          ${output_dir}
# ${source}                    ${output_dir}/gnb_tcpdump.pcap
# ${target}                    ${output_dir}/attach.txt
# ${filter}                    x2ap.procedureCode == 27 && x2ap.X2AP_PDU == 1
# ${filter2}                    x2ap.procedureCode == 30&&x2ap.X2AP_PDU == 0
# ${cpif_log_name}            CPIF_log
# ${E500_SCRIPTS_BASE}    ${CURDIR}/E500_scripts
# ${TMA_APP_ALIAS}        e500
# ${Test_Case_Name}           5GC002518_BTSLOG
# *** Test Cases ***
# [1]5GC002518-B-DV-TC001_scellFrequenciesSN-NR change within SgNB Modification Request Acknowledge during SgNB modification with SCG change
#     [Documentation]    scellFrequenciesSN-NR change within SgNB Modification Request Acknowledge during SgNB modification with SCG change
#     [Tags]    CRT_21B    CRT_TRUNK    CRT_22R1    CRT_22R2
#     [Setup]
#     Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
# #    Setup Commission SCF    CURDIR_path=${CURDIR_path1}
#     Attach and get wiresharklog
#     check log data    Line=1    vlaue=2241883
#     check log data    Line=2    vlaue=2243611
#     check log data    Line=3    vlaue=2244763
#     check log data    Line=4    vlaue=2246491
#     check log data    Line=5    vlaue=2248219
#     check log data    Line=6    vlaue=2249947
#     check log data    Line=7    vlaue=2251675
#     [Teardown]
#
# *** Keywords ***
# Attach and get wiresharklog
#     [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}
#     log to console    start attach...
#     start extract log
#     power_ue.Prepare UE    ue_type=${UE_type}    ue_index=${2}
#     log to console    UE Attach
#     ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${UE_type}    ue_index=${2}
#
#     sleep    5s
#     log to console    Verify Attach
#     power_ue.Verify attach    ue_type=${UE_type}    5Grach_ed=${5Grach_ed_0}    ue_index=${2}    4G_check=False
#
#     log to console    ue attach successful
#     sleep    5s
#     [Teardown]    END log and detach ue
#
# END log and detach ue
#     end extract log
# #    run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_type}    ue_index=${2}
#
# start extract log
#     ${connection_1}    csn.connect_to   hostname=${DU_OAM_IP_TL}
#     ...    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}    alias=VM
#     csn.Send Command   command=cd /ffs/run && tcpdump -n -i any -w /tmp/gnb_tcpdump.pcap    connection=${connection_1}
#     log to console  start extract log successful
#     sleep    3s
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection_1}
#
# end extract log
#     ${connection_1}    csn.connect_to   hostname=${DU_OAM_IP_TL}
#     ...    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}    alias=VM
#     csn.Send Command  command=ps -ef | grep tcpdump | grep -v grep | grep gnb_tcpdump.pcap |tail -n 1 |awk '{print $2}'
#     ...    connection=${connection_1}
#     ${PID}  csn.Read Output    connection=${connection_1}
#     ${PID}  strip_string    ${PID}
#     log to console  Extract log successful
#     log to console  PID output: ${PID}
#     csn.Send Command  command=kill ${PID}    connection=${connection_1}
#     Wireshark DownloadLog
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection_1}
#
# Wireshark DownloadLog
#     [Arguments]    ${connection_2}=Download
#     csn.connect_to   hostname=${DU_OAM_IP_TL}    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}
#     ...    alias=${connection_2}
#     csn.download_file   local_path=${LOG_PATH}/gnb_tcpdump.pcap    remote_path=${epc_log_path}/gnb_tcpdump.pcap
#     ...    connection=${connection_2}
#     sleep    5s
#     log to console  Download Log successful
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection_2}
#
# check log data
#     [Arguments]    ${Line}=1    ${vlaue}=2234395
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     Convert pcap to text    source=${source}    target=${target}    connection=${connection}    filter=${filter}
#     csn.Send Command    command=cat ${target}|grep 'scellFrequenciesSN-NR:'    connection=${connection}
#     ${check1}  csn.Read Output    connection=${connection}
#     should not be empty    ${check1}
#     csn.Send Command    command=cat ${target}|grep 'ARFCN-ValueNR'|head -${Line}|tail -n 1|tr -cd "[0-9]"    connection=${connection}
#     ${check2}  csn.Read Output    connection=${connection}
#     ${check2}    Evaluate    int(${check2})
#     should be equal as numbers    ${check2}    ${vlaue}
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
# Setup Commission SCF
#     [Arguments]    ${CURDIR_path}     ${bts_host}=${tl.gnbs[0].dus[0].f1_m_ip_addr}
#     ...    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
#     ...    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
#     coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
#     ...   name=${connection}
#     log to console    connect successful
#     COAM Commission with scf file    is_pdl_checking_needed=False    scf_file_path=${CURDIR_path}
#     log to console    active DU scf successful
#     Run Keyword And Ignore Error    coam.teardown
#     sleep    8min
#     [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}
#
# Convert pcap to text
#     [Arguments]    ${source}    ${target}    ${connection}    ${filter}
#     ssh.send_command
#     ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
#     ssh.await execution end  connection=${connection}  timeout=30min
#     sleep    5s
#
# Modify Value On DU
#     [Arguments]    ${structure_modify_list}    ${gNB_ip}    ${common_modify_list}=None    ${keywords_list}=None    ${connection}=GNB_connection
#     ...    ${class_name}=None   ${is_structure}=${True}    ${is_common}=${True}    ${structure_index}=0
#     coam.connect_to    bts_host=${gNB_ip}   name=${connection}
#     run keyword if  ${is_structure}    Modify Structure parameter via Coam    class_name=${class_name}   connection=${connection}
#     ...    modify_list=${structure_modify_list}    keywords_list=${keywords_list}    index=${structure_index}
#     [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
#
# Modify Structure parameter via Coam
#     [Arguments]   ${class_name}   ${connection}   ${modify_list}   ${keywords_list}    ${index}=0
#     ${get_managed_objects}     coam.get_managed_objects     class_name=${class_name}    connection=${connection}
#     ${output_dict_list}    return_structure_value    input_list=${get_managed_objects}    modify_list=${modify_list}
#     ...    keywords_list=${keywords_list}
#     FOR    ${item}  IN  @{output_dict_list}
#          ${dict_value}    Get Content From Input Dict    input_dict=${item}
#          coam.Perform Parameter Recommissioning    dist_name=@{dict_value}[0]   parameter=@{dict_value}[1]   value=@{dict_value}[2]
#          ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
#          sleep  30s
#     END
