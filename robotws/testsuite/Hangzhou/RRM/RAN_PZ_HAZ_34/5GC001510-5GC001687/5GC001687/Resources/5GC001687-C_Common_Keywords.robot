*** Settings ***
Documentation
...    author: lixia.tang
...    contact: lixia.tang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG
...    feature : 5GC001687-C

Library     OperatingSystem
Library     Collections
Library     String
Library     BuiltIn
Library     DateTime
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library     taf.config.scf    WITH NAME    scf
Library     taf.analyzer.pcap   WITH NAME    cap
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Library     taf.sbts.oam.coam.admin    WITH NAME    coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/common/siso_resource.robot
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/libraries/L3Call.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/Attenuation.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/libraries/biplog_capture/biplog_capture.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot


*** Variables ***
##GNB##
##ALIAS##
${att_ipaddr}               ${tl.attenuator[0].ip_addr}
${att_api_port}             ${tl.attenuator[0].port}
${DU_OAM_IP}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${asib_alias}               ASIB Master
${GNB_COAM_ALIAS}           GNB_OAM
${BTS_NAME}                 Classical-TL10040-ASIB-ABIO-AEQN-100M
${asib_addr_0}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asib_username}            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asib_password}            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
##ENB##
${eNB_asik_addr}            ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_instance}             ${tl.enbs[0].instance_id}
${enbx2_dist}               MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-0
${enbx2_para}               administrativeState
${enbcell_dist}             MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${enbcell_para1}            administrativeState
${enbcell_para2}            defaultLnRelGnbCellId
##UE##
${DL_TIME}                  600
${DL_LENGTH}                1024B
${UL_TIME}                  600
${UL_LENGTH}                1024B
##SCF##
@{scf}    5GC001687_20M_1070_C2.xml    5GC001687_80M_1116_B4.xml    5GC001687_20M_1070_C2_24R1.xml
...    5GC001687_80M_1116_B4_24R1.xml    5GC001687_20M_1070_C2_24R2.xml    5GC001687_80M_1116_B4_24R2.xml
${case_scf_dir_path}        ${commissionings_path}/HGZ/7_5_UTE5G402T919/5GC001510-5GC001687/
##tput##
${ul_tput}                  50M
${dl_tput}                  1500M   ##peak 1.4Gbps
${expect_dl_tput}           100

*** Keywords ***
L3_Call_20M_1070_C2
    Log To Console    \n *** run case L3_Call_20M_1070_C2
    5GC001687-C_Common_Keywords.Connect to DU via ssl
    ${release}    coam.get_sw_release_name    connection=${GNB_COAM_ALIAS}
    run keyword if    '${release}' == 'SBTS24R1'
    ...    5GC001687-C_Common_Keywords.Prepare testline to cell onair    localFilePath=${case_scf_dir_path}
    ...    tl_scf_filename=${scf[2]}    type=NSA
    ...    ELSE IF    '${release}' == 'SBTS24R2'
    ...    5GC001687-C_Common_Keywords.Prepare testline to cell onair    localFilePath=${case_scf_dir_path}
    ...    tl_scf_filename=${scf[0]}    type=NSA
    ...    ELSE    5GC001687-C_Common_Keywords.Prepare testline to cell onair    localFilePath=${case_scf_dir_path}
    ...    tl_scf_filename=${scf[0]}    type=NSA
    Power UE Attach and Start traffic      dl_throughput=${dl_tput}    type=NSA
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput}
    Power UE stop dl traffic and detach

L3_Call_80M_1070_B4
    Log To Console    \n *** run case L3_Call_80M_1070_B4
    5GC001687-C_Common_Keywords.Prepare testline to cell onair    localFilePath=${case_scf_dir_path}
    ...      tl_scf_filename=${scf[1]}    type=NSA
    Power UE Attach and Start traffic    dl_throughput=${dl_tput}    type=NSA
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput}
    Power UE stop dl traffic and detach

L3_Call_20M_1116_C2
    Log To Console    \n *** run case L3_Call_20M_1116_C2
    5GC001687-C_Common_Keywords.Prepare testline to cell onair    localFilePath=${case_scf_dir_path}
    ...      tl_scf_filename=${scf[2]}    type=NSA
    Power UE Attach and Start traffic    dl_throughput=${dl_tput}    type=NSA
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput}
    Power UE stop dl traffic and detach

L3_Call_80M_1116_B4
    Log To Console    \n *** run case L3_Call_80M_1116_B4
    5GC001687-C_Common_Keywords.Connect to DU via ssl
    ${release}    coam.get_sw_release_name    connection=${GNB_COAM_ALIAS}
    run keyword if    '${release}' == 'SBTS24R1'
    ...    5GC001687-C_Common_Keywords.Prepare testline to cell onair    localFilePath=${case_scf_dir_path}
    ...    tl_scf_filename=${scf[3]}    type=NSA
    ...    ELSE IF    '${release}' == 'SBTS24R2'
    ...    5GC001687-C_Common_Keywords.Prepare testline to cell onair    localFilePath=${case_scf_dir_path}
    ...    tl_scf_filename=${scf[1]}    type=NSA
    ...    ELSE    5GC001687-C_Common_Keywords.Prepare testline to cell onair    localFilePath=${case_scf_dir_path}
    ...    tl_scf_filename=${scf[1]}    type=NSA
    Power UE Attach and Start traffic     dl_throughput=${dl_tput}    type=NSA
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput}
    Power UE stop dl traffic and detach


L3_Call_80M_1116_B4_Rat_reset_prepare_TL
    Log To Console    \n *** run case L3_Call_80M_1116_B4
    5GC001687-C_Common_Keywords.Connect to DU via ssl
    ${release}    coam.get_sw_release_name    connection=${GNB_COAM_ALIAS}
    run keyword if    '${release}' == 'SBTS24R1'
    ...    5GC001687-C_Common_Keywords.Prepare testline to cell onair    localFilePath=${case_scf_dir_path}
    ...    tl_scf_filename=${scf[3]}    type=NSA
    ...    ELSE IF    '${release}' == 'SBTS24R2'
    ...    5GC001687-C_Common_Keywords.Prepare testline to cell onair    localFilePath=${case_scf_dir_path}
    ...    tl_scf_filename=${scf[1]}    type=NSA
    ...    ELSE    5GC001687-C_Common_Keywords.Prepare testline to cell onair    localFilePath=${case_scf_dir_path}
    ...    tl_scf_filename=${scf[1]}    type=NSA

L3_Call_80M_1116_B4_Rat_reset_make_call
    Run keyword and continue on failure      log to console      start L3_Call_80M_1116_B4_Rat_reset_make_call
    Run keyword and continue on failure      Power UE Attach and Start traffic
    ...      dl_throughput=${dl_tput}    type=NSA
    Run keyword and continue on failure      Run keyword and continue on failure
    ...      Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput}
    Run keyword and continue on failure      Power UE stop dl traffic and detach
    Run keyword and continue on failure      log to console      end L3_Call_80M_1116_B4_Rat_reset_make_call


##setup and teardown and recovery##
5GC001687_Common Suite Setup for COAM
    #CI_interface.Common Suite Setup
    Set suite variable      ${OUTPUT_PATH}    %{HOME}/workspace/CRT/Master/Case_Logs
    5GC001687_COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}
    Set Suite Variable    ${time_stamp}
    Create directory    ${epc_log_path}
    Reset eNB and Check eNB Anchor Cell OnAir
    Configure correct defaultLnRelGnbCellId for anchor cell
    Run Keyword And Ignore Error    robot_common_operations.Common Suite Setup


5GC001687_COAM Create log directory
    [Arguments]  ${is_set_to_test_case_level}=${True}    ${timeout}=1min
    5GC001687_Generate suite log path    timeout=${timeout}
    Run keyword if  ${is_set_to_test_case_level}
    ...    Run keywords    Generate test case log path    AND
    ...    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
    ...    ELSE    Set suite variable    ${LOG_PATH}    ${SUITE_LOG_PATH}

5GC001687_Generate suite log path
    [Arguments]    ${timeout}=1min
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    wait until keyword succeeds    ${timeout}    2sec    5GC001687-C_Common_Keywords.Connect to DU via ssl
    ${sw_version} =     coam.get_sw_version    connection=${GNB_COAM_ALIAS}
    ${suite_log_path}    Join path    ${OUTPUT_PATH}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Set Suite Variable    ${sw_version}
    Create directory    ${SUITE_LOG_PATH}

Connect to DU via ssl
    [Arguments]  ${connection}=${GNB_COAM_ALIAS}    ${bts_host}=${DU_OAM_IP}
    ...    ${username}=${WEBUI_USER}
    ...    ${password}=${WEBUI_PASSWORD}
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}

5GC001687_Common Suite Teardown for COAM
    Wait until keyword succeeds    1min    10s    Connect to Classical Common Unit Master gnb
    Run Keyword And Ignore Error    5GC001687-C_Common_Keywords.AdminCli disconnection and Test teardown
    #CI_interface.Common Case Teardown
    robot_common_operations.Common Suite Teardown

AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    admin_cli.teardown    connection=${GNB_COAM_ALIAS}

Connect to Classical Common Unit Master gnb
    [Arguments]
    ${gnbs}    testline_info.get_classicalbts_gnbs    tl=${tl}
    csn.Connect to    hostname=${gnbs[0].dus[0].f1_m_ip_addr}
    ...               username=${gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${asib_alias}

Tests Recover for NSA
    run keyword and ignore error     csn.disconnect    connection=cpc_0
    run keyword and ignore error     coam.teardown    connection=GNB_OAM
    run keyword and ignore error     csn.disconnect    connection=${asib_alias}
    run keyword and ignore error     enblte.teardown    connection=enblte
    Run Keyword And Ignore Error    robot_common_operations.Common case Teardown


Tests Recover for SA
    Run keyword    Connect and Modify the parameter on enblte scip errors    dist_name=${enbcell_dist}    parameter=${enbcell_para1}
    ...               value=unlocked
    run keyword and ignore error     csn.disconnect    connection=cpc_0
    run keyword and ignore error     coam.teardown    connection=GNB_OAM
    run keyword and ignore error     csn.disconnect    connection=${asib_alias}
    run keyword and ignore error     enblte.teardown    connection=enblte
    Run Keyword And Ignore Error    robot_common_operations.Common case Teardown

case set up
    Run Keyword And Ignore Error    robot_common_operations.Common case setup

##prepare BTS##
Reset eNB and Check eNB Anchor Cell OnAir
    #Reset eNB
    Wait until keyword succeeds    10min    30s    Check the enb anchor cell onAir

Check the enb anchor cell onAir
    Connect to eNB via ssl
	${enbcell_status}=    Get the anchor cell status from btsinfo    'cells.lte.1.status.operationalState'
	should be equal    ${enbcell_status}    enabled

Get the anchor cell status from btsinfo
    [Arguments]    ${filter}
	${output} =    enblte.get_bts_info    connection=enblte
	enblte.teardown    connection=enblte
    @{list} =    Evaluate    ${filter}.split('.')
    ${output_VALUE} =     get from dictionary    ${output}            ${list}[0]
    ${output_VALUE_1} =   get from dictionary    ${output_VALUE}      ${list}[1]
    ${output_VALUE_2}     set variable           ${output_VALUE_1}[1]
    ${output_VALUE_3} =   get from dictionary    ${output_VALUE_2}    ${list}[3]
    ${output_VALUE_4} =   get from dictionary    ${output_VALUE_3}    ${list}[4]
	[Return]    ${output_VALUE_4}

Enblte close down
    [Arguments]    ${connection}=enblte
    enblte.teardown    connection=${connection}

Configure correct defaultLnRelGnbCellId for anchor cell
    run keyword and ignore error     Connect and Modify the parameter on enblte scip errors    dist_name=${enbcell_dist}
    ...    parameter=${enbcell_para2}    value=1

Prepare testline to cell onair
    [Arguments]      ${localFilePath}    ${tl_scf_filename}    ${type}
    Perform full commission for COAM gnb    localFilePath=${localFilePath}    tl_scf_filename=${tl_scf_filename}
    COAM Wait for gnb ready
    Sleep    60s
    Run keyword if    '${type}' == 'SA'
    ...    Connect and Modify the parameter on enblte scip errors    dist_name=${enbcell_dist}    parameter=${enbcell_para1}    value=locked
#    Run keyword if    '${type}' == 'NSA'
#    ...    Run keywords    Connect and Modify the parameter on enblte scip errors    dist_name=${enbx2_dist}    parameter=${enbx2_para}
#    ...    value=locked    AND
#    ...    COAM Wait for gnb ready    AND
#    ...    Connect and Modify the parameter on enblte scip errors    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
#    ...    ELSE    Run keywords    COAM Wait for gnb ready    AND
#    ...    Connect and Modify the parameter on enblte scip errors    dist_name=${enbcell_dist}    parameter=${enbcell_para1}    value=locked
    Wait until keyword succeeds    10min    30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

Perform full commission for COAM gnb
    [Arguments]    ${tl_scf_filename}    ${localFilePath}
    Connect to gnb coam via ssl   bts_host=${DU_OAM_IP}
    COAM Commission with scf file    scf_file_path=${localFilePath}${tl_scf_filename}    timeout=500    is_pdl_checking_needed=${False}
    [Teardown]    COAM Teardown gnb connections

Connect and Modify the parameter on enblte scip errors
    [Arguments]    ${dist_name}    ${parameter}     ${value}
    Connect to eNB via ssl
    Modify the parameter on enblte and scip errors    ${dist_name}     ${parameter}    ${value}
    enblte.teardown    connection=enblte

Modify the parameter on enblte and scip errors
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}
    enblte.perform_parameter_recommissioning       dist_name=${dist_name}
    ...                                            parameter=${parameter_name}
    ...                                            operation=update
    ...                                            value=${value}
    ...                                            connection=enblte
    ...                                            skip_parameter_relation_errors=True

COAM Wait for gnb ready
    [Documentation]  Author: Ding Binmei
    ...              Description: Wait until GNB status ready.
    [Timeout]  30 min
    [Arguments]  ${timeout}=10 min    ${connection}=GNB_OAM
    Wait until keyword succeeds    ${timeout}    20 sec    Connect to gnb coam via ssl    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB ABIL status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB ASIK status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB RU status    connection=${connection}

##UE##
Power UE Attach and Start traffic
    [Arguments]     ${dl_throughput}    ${type}
    Power UE Precondition
    #Run keyword and continue on failure    _Reboot UE    connection=cpc_0
    #Run keyword if    '${type}' == 'SA'    _Reboot UE    connection=cpc_0
    Sleep    10s
    Run keyword if    '${type}' == 'NSA'
    ...    Run keyword and continue on failure    Power UE Attach and Verify attach    4g_check=True
    ...    ELSE    Run keyword and continue on failure    Power UE Attach and Verify attach    4g_check=False
    Power UE Start traffic     dl_throughput=${dl_throughput}

Power UE Precondition
    [Arguments]    ${ue_type}=qct_dx50
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    capatibility_index=${0}    reset_sol=ue_reboot     detach_request=${true}

Power UE Attach and Verify attach
    [Arguments]    ${4g_check}    ${gnb_index}=${0}    ${ue_type}=qct_dx50
    Log To Console    \n *** UE Attach started
     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${0}    gnb_index=${gnb_index}
    ...                       4G_check=${4g_check}    5Gstatus=PASS

Power UE Start traffic
    [Arguments]    ${dl_throughput}     ${duration}=${DL_TIME}    ${dl_length}=${DL_LENGTH}    ${dl_port}=default
    ...    ${ue_index}=${0}    ${ue_type}=qct_dx50
    Log To Console    \n *** Start DL traffic
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}
    ...                       iperf_port=${dl_port}    ue_index=${ue_index}    cap_index=${0}    buffer_size=${dl_length}

Power UE check throughput
    [Arguments]    ${Expect_DOWNLINK}     ${ue_type}=qct_dx50
    Log To Console    \n *** Start to check DL throughput
    #wait until keyword succeeds    2min    10s    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${Expect_DOWNLINK}
    #...    ue_index=${ue_index}    hw_slot=1    sample=${10}    start_offset=${3}    sleep_time=${5}    cellid=${EMPTY}    gnb_index=${gnb_index}
    ${DLtput_log}    Run keyword and continue on failure    power_ue.Collect Tput
    ...    ue_type=${ue_type}    duration=60s    ignore_time=5s    filter=L2Lo
    Run keyword and ignore error    power_ue.Check Tput
    ...    ue_type=${ue_type}    direction=DL    log=${DLtput_log}    cells=${EMPTY}
    ...    target_throughput=${Expect_DOWNLINK}    target_avg_percent=0.95    min_percent=0.75

Power UE stop dl traffic
    [Arguments]    ${dl_port}=default    ${ue_type}=qct_dx50
    Log To Console    \n *** Stop DL traffic
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}

Power UE stop ul traffic
    [Arguments]    ${ul_port}=default    ${ue_type}=qct_dx50
    Log To Console    \n *** Stop UL traffic
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${ul_port}

Power UE Detach
    [Arguments]    ${ue_type}=qct_dx50
    Log To Console    \n *** UE Detach started
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

Power UE stop dl traffic and detach
    [Arguments]    ${dl_port}=default    ${ue_type}=qct_dx50
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}
    sleep    3s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
