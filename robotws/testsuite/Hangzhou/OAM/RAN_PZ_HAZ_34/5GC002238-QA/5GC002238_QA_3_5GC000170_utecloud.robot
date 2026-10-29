# # #*** Settings ***
# # #Documentation
# # #...   author: xiaofeng.1.zhu@nokia-sbell.com
# # #...   contact: xiaofeng.1.zhu@nokia-sbell.com
# # #
# # #Suite Setup       CI_interface.Common Suite Setup
# # #
# # #Force Tags              5G_RAN_TDD    STATE_GNB_NOT_COMMISSIONED    CLOUD_5G_ANDROID_ASOD_AEWE_ENB    master_pDU    CRT_UTE   5G_RAN
# # #...    PY36
# # #...    RAN_5G_TDD    RAN_5G
# # #
# # #Resource          Resources/5GC002238_common_keyword.robot
# # #Library           Resources/5GC002238_common_keyword.py
# # #Variables         Resources/5GC002238_modify_para.py
# # #Library    taf.analyzer.pcap    WITH NAME    cap
# # #Library           ute_syslog
# # #Library           taf.sbts.oam.coam.admin       WITH NAME    coam
# # ##Library           taf.selenium.sbts    WITH NAME    selenium_coam
# # #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# # #
# # #
# # #
# # #*** Variables ***
# # #${DU_OAM_IP_TL}                  ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# # #${DU_OAM_WEBUI_USER}             ${tl.gnbs[0].cu.oam_http_connection_details.username}
# # #${DU_OAM_WEBUI_PASSWORD}         ${tl.gnbs[0].cu.oam_http_connection_details.password}
# # #${DU_OAM_SSH_USERNAME_TL}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
# # #${DU_OAM_SSH_PASSWORD_TL}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
# # #${asik_alias}                    ASIK Master
# # #${ue_power_port}                 ${tl.ues[0].iperf_details.port}
# # #${log_dir}                       /tmp
# # #${ul_throughput}                 20M
# # #${TS_CASE_LOG_PATH}              ${OUTPUT DIR}
# # #${test_ute}                      ${tl.test_pc.default_ssh_connection_details.addr}
# # #${ute_name}                      ${tl.test_pc.default_ssh_connection_details.username}
# # #${test_password}                 ${tl.test_pc.default_ssh_connection_details.password}
# # #${list}                          51000
# # #${if_pdl_check}                  True
# # #${BTS_ID}                        ${tl.gnbs[0].instance_id}
# # #${band260_thresholds}            260    100    3
# # #${remote_ip}                     10.57.157.237
# # #${Test_Case_Name}                5GC002238_QA_3
# # #
# # #
# # #*** Test Cases ***
# # #[1]5GC002238_QA_3_5GC000170_ASOD_recovery_scenarios_for_SMOD_failure_with_L3_call
# # #    [Documentation]    this case is to verify asod recovery function after smod failure with l3 call
# # #    [Tags]     5GC002238-QA    CRT_20B    CRT_TRUNK
# # #    [Setup]    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
# # #    Modify Structure parameter via Coam    class_name=TRBLCADM_A    modify_list=${parameter_remote}    keywords_list=${keywords_list1}
# # #    ...     index=${list_index}
# # #    BTSLOG Start btslog on remote machine
# # #    Connection to Du making alarm
# # #    Connection to web and check cell onAir
# # #    attach multi power ue    ue_num=${1}
# # #    start multi power ue traffic ul    ue_num=${1}    ul_throughput=${ul_throughput}
# # #    stop multi power ue traffic     ue_num=${1}
# # #    [Teardown]    CI_interface.Common Case Teardown
# # #
# # #[1]CB007304-5G-E_5GC000956_004_trigger_RF_Diagnostic_test_by_WebEM_normal_mode_for_AEUB
# # #    [Documentation]
# # #    ...    The purpose of this case is to verify that RF diagnostic test for selected NR cells or for all NR cells can be run by WebEM.
# # #    ...    -04.06.2021,steven.liu@nokia-sbell.com,case draft
# # #    [Tags]    CRT_21B   CRT_TRUNK    CB007304-5GC000956
# # #    [Setup]
# # ##    Create Default RFTHLD
# # #    WEBUI Login    version=5G21A
# # #    ${bts_thresholds}    create dictionary    Low RSSI threshold=${-160}
# # #    ${bands_thresholds}    create list    ${band260_thresholds}
# # #    Check RF Diagnostic Result
# # #    ...    cell=NRCELL-1    bts_thresholds=${bts_thresholds}    bands_thresholds=${bands_thresholds}    cell_id=1
# # ##    Set Illegal Value
# # ##    [Teardown]    case_teardown
# # #
# # #
# # #
# # #
# # #
