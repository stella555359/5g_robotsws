# *** Settings ***
# Force Tags    PY36
# Suite Setup
# Suite Teardown
# Documentation
# ...   author: xiaofeng.1.zhu@nokia-sbell.com
# ...   contact: xiaofeng.1.zhu@nokia-sbell.com
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Library           taf.transport.ssh    WITH NAME    csn
# Library           taf.hw.rf_attenuator    WITH NAME    att
# Library           taf.ue  WITH NAME   ute_ue
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Library           taf.collectors.core   WITH NAME   core
#
# *** Variables ***
# ${DU_OAM_IP_URL}            https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_WEBUI_IP}         ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_WEBUI_USER}        ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${DU_OAM_IP_TL}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_SSH_USERNAME_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
# ${DU_OAM_SSH_PASSWORD_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
# ${TEST_PC_IP}                 ${tl.test_pc.default_ssh_connection_details.addr}
# ${TEST_PC_USERNAME}           ${tl.test_pc.default_ssh_connection_details.username}
# ${TEST_PC_PASSWORD}           ${tl.test_pc.default_ssh_connection_details.password}
# ${connection}                GNB_OAM
# ${target}                    ${output_dir}/snapshot
# ${target1}                   ${output_dir}/snapshot/snapshot_file_list.txt
# *** Test Cases ***
# [1]CB005750_5G_EBAR_101_5GC000666_01_5G_Snapshot_collection_in_WebEM
#     [Documentation]    Snapshot collection in WebEM
#     [Tags]    CB005750-EBAR    CRT_21A    CRT_TRUNK
#     [Setup]
#     Collect snapshot    BTS_IP=${DU_OAM_IP_TL}
#     Unzip and Check snapshot    BTS_IP=${DU_OAM_IP_TL}
#     [Teardown]    Clean files
#
# *** Keywords ***
# Collect snapshot
#     [Arguments]    ${BTS_IP}
#     log to console    start collect snapshot
#     coam.connect_to    bts_host=${BTS_IP}   name=${connection}
#     coam.collect_snapshot    target_file_name=${output_dir}/snapshot.zip   connection=${connection}
#     log to console    collect snapshot successful
#     [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}
#
# Unzip and Check snapshot
#     [Arguments]    ${BTS_IP}
#     csn.Connect to     hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}	alias=TESTPC
#     csn.Send Command    command=cd ${output_dir};ls |grep 'snapshot.zip'    connection=TESTPC
#     ${data}    csn.Read Output    connection=TESTPC
#     ${data}    strip_string    ${data}
#     should not be empty    ${data}
#
#     csn.execute    command=unzip -o ${output_dir}/snapshot.zip -d ${output_dir}/snapshot    connection=TESTPC
#     Check data    point=pm_1_syslog.zip
#     Check data    point=RMOD_L_1_journal_pm1.zip
#     Check data    point=SWDLreport.txt.xz
#     Check data    point=AlarmHistory.txt.xz
#     Check data    point=blackbox.xz
#     log to console    check snapshot successful
#
# Check data
#     [Arguments]    ${point}
#     csn.Send Command    command=cat ${target1}|grep '${point}'    connection=TESTPC
#     ${check}    csn.Read Output    connection=TESTPC
#     ${check}    strip_string    ${check}
#     should not be empty    ${check}
#
# Clean files
#     csn.Send Command    command=cd ${output_dir};rm -rf ${target}    connection=TESTPC
#     run keyword and ignore error    Csn.Disconnect	connection=TESTPC