*** Settings ***
Documentation    Author:jia-rebecca.liu@nokia-sbell.com

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/viavi_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Variables         testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/None_Feature_SG3/QoS_Latency/TestData/Qos_parameter_counter.py
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/get_counters_from_pm_file.py
Library           taf.stc.config      WITH NAME    stcl





*** Variables ***
${DT_SCF}                 MRBTS-38111_TL38111_SCF.xml
${swconfig}               /opt/workspace/SCF/swconfig.txt
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_BTS_ID}             ${tl.gnbs[0].global_bts_id}
${gNB_oam_username}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_oam_password}       ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gNB_ssh_username}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${gNB_ssh_password}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${eNB_ip}                 ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${eNB_username}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${eNB_password}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${UTE_hostname}           ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_username}           ${tl.test_pc.default_ssh_connection_details.username}
${UTE_password}           ${tl.test_pc.default_ssh_connection_details.password}
${Server_ip}              ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${ul_ports}               ${tl.ues[0].iperf_details.ports[0]}
${dl_ports}               ${tl.ues[0].iperf_details.ports[1]}


${TS_LOG_PATH_BASE}         /opt/workspace/CRT/Master/Case_Logs/

*** Keywords ***
#--------------------TL prepare------------------#
DT TL suite setup
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    robot_common_operations.Common Suite Setup
    Common Suite Setup for COAM
    ${release_info}=     Get sagnb release
    set suite variable     ${release_info}
    ${full_release_info}=    Get gnb full_release
    set suite variable     ${full_release_info}
    Common Case TestLine Setup    is_commission=True
    ...                           golden_scf_name=${DT_SCF}
#    ...                           Is_Swconfig=True
#    ...                           swconfig_file=${swconfig}

DT TL suite teardown
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    robot_common_operations.Common Suite Teardown
    Common Suite Teardown for COAM

Get gnb full_release
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${full_release_info}     set variable
    ...    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}_${info.split('_')[4]}_${info.split('_')[5]}
    [Return]    ${full_release_info}
    [Teardown]   csn.Disconnect   connection=release_info





