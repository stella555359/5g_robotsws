*** Settings ***
Documentation
...    author: lixia.tang
...    contact: lixia.tang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG
...    feature : 5GC002056-BGAN_5GC001856-M_5GC001856-P

Library     OperatingSystem
Library     Collections
Library     String
Library     BuiltIn
Library     DateTime
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library     taf.config.scf    WITH NAME    scf
Library    taf.analyzer.pcap   WITH NAME    cap
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     get_pm_counter.py
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/libraries/L3Call.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/Attenuation.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/libraries/biplog_capture/biplog_capture.robot

*** Variables ***
##PATH##
${gnb_path}                 /tmp
${tshark_path}              /usr/bin/tshark
${LUA_SCRIPT_PATH}          /opt/luashark/luashark.lua
##GNB##
${DU_OAM_IP}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${asib_alias}               ASIB Master
${GNB_COAM_ALIAS}           GNB_OAM
${asib_addr_0}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asib_username}            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asib_password}            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
##ENB##
${eNB_asik_addr}            ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_instance}             ${tl.enbs[0].instance_id}
${enbx2_dist}               MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-0
${enbx2_para}               administrativeState
${enbcell_dist}             MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${enbcell_para}             administrativeState
##PA##
${att_ipaddr}               ${tl.attenuator[0].ip_addr}
${att_ports_1}              ${tl.attenuator[0].attenuator_ports[1]}
${att_ports_2}              ${tl.attenuator[0].attenuator_ports[2]}
${att_ports_3}              ${tl.attenuator[0].attenuator_ports[3]}
${att_ports_4}              ${tl.attenuator[0].attenuator_ports[4]}
${att_ports_number}         ${tl.attenuator[0].attenuator_ports[1]}
${att_api_port}             ${tl.attenuator[0].port}
${vendor}                   HBTE
${HBTE_max_value}           ${127}    ##no signal
@{att_value}                45    22    127   ##rank4  no signal
##UE##
${DL_TIME}                  600
${DL_LENGTH}                1024B
${UL_TIME}                  600
${UL_LENGTH}                1024B
##SCF##
@{scf}                      SCF_60M.xml    SCF_80M.xml    SCF_100M.xml
${case_scf_dir_path_1856_21A}        commissionings/HGZ/7_5_UTE5G402T926/5GC002056-BGAN/SCF/21A/
${case_scf_dir_path_605_21A}         commissionings/HGZ/7_5_UTE5G402T926/5GC002056-BHAV/SCF/21A/
##swconfig##
${swconfig_default}         commissionings/HGZ/7_5_UTE5G402T926/5GC002056-BGAN/swconfig/1856_default/swconfig.txt
${swconfig_1856_case1}      commissionings/HGZ/7_5_UTE5G402T926/5GC002056-BGAN/swconfig/1856_default/swconfig.txt
${swconfig_1856_case4}      commissionings/HGZ/7_5_UTE5G402T926/5GC002056-BGAN/swconfig/1856_case4/swconfig.txt
${swconfig_1856_case5}      commissionings/HGZ/7_5_UTE5G402T926/5GC002056-BGAN/swconfig/1856_case5/swconfig.txt
${swconfig_1856_case9}      commissionings/HGZ/7_5_UTE5G402T926/5GC002056-BGAN/swconfig/1856_case9/swconfig.txt
${swconfig_1856_case10}     commissionings/HGZ/7_5_UTE5G402T926/5GC002056-BGAN/swconfig/1856_case10/swconfig.txt
${swconfig_605_case1}       commissionings/HGZ/7_5_UTE5G402T926/5GC002056-BHAV/swconfig.txt
##biplog##
${biplog_rank4}             tcpdumpL2L1_rank4.pcap
${biplog_rank3}             tcpdumpL2L1_rank3.pcap
${biplog_rank2}             tcpdumpL2L1_rank2.pcap
${biplog_rank1}             tcpdumpL2L1_rank1.pcap
##tput##
${ul_tput}                  50M
${dl_tput}                  1500M   ##peak 1.4Gbps
@{expect_dl_tput_rank1}     220     206     140     320     256     190   ##100MHz   80MHz   60MHz
@{expect_dl_tput_rank2}     540     460     330     640     510     380   ##100MHz   80MHz   60MHz
@{expect_dl_tput_rank3}     880     710     520     980     760     570   ##100MHz   80MHz   60MHz
@{expect_dl_tput_rank4}     1200    950     720     1300    1000    770   ##100MHz   80MHz   60MHz

*** Keywords ***
CL_C4_Adaptive_Rank_PDSCH_Adaptive_PMI_Link_Adaptation_256QAM_Ideal_Radio_80MHz
    Log To Console    \n *** run case 5GC002056-BGAN_5GC001856_M-P_001
    Update the swconfig file    localFilePath=${swconfig_1856_case1}
    Prepare testline to cell onair    localFilePath=${case_scf_dir_path_1856_21A}    tl_scf_filename=${scf[1]}    type=NSA
    #RANK1
    Adjust HBTE ATT Value  value_1=${${att_value[0]}}  value_2=${${att_value[2]}}  value_3=${${att_value[2]}}  value_4=${${att_value[2]}}
    Power UE Attach and Start traffic    4g_check=True    dl_throughput=${dl_tput}    type=NSA
    Start Bip Log Capture on Loki and download BIP log to UTE    log_name=${biplog_rank1}
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput_rank1[1]}
    #RANK2
    Adjust HBTE One ATT Value    value=${${att_value[0]}}    att_port=${att_ports_2}
    Start Bip Log Capture on Loki and download BIP log to UTE    log_name=${biplog_rank2}
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput_rank2[1]}
    #RANK3
    Adjust HBTE One ATT Value    value=${${att_value[0]}}    att_port=${att_ports_3}
    Start Bip Log Capture on Loki and download BIP log to UTE    log_name=${biplog_rank3}
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput_rank3[1]}
    #RANK4
    Adjust HBTE One ATT Value    value=${${att_value[1]}}    att_port=${att_ports_4}
    Start Bip Log Capture on Loki and download BIP log to UTE    log_name=${biplog_rank4}
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput_rank4[1]}
    Run keyword and continue on failure    Check BIP Log for Case1
    Power UE stop dl traffic and detach

CL_Rank_4_DL_4x4_MIMO_PDSCH_transmission_256QAM_with_port_selection_with_Wcsirs_is_not_Identity_100MHz
    Log To Console    \n *** run case 5GC002056-BGAN_5GC001856_S-T_004
    Update the swconfig file    localFilePath=${swconfig_1856_case4}
    Prepare testline to cell onair    localFilePath=${case_scf_dir_path_1856_21A}    tl_scf_filename=${scf[2]}    type=NSA
    Adjust HBTE ATT Value  value_1=${${att_value[0]}}  value_2=${${att_value[0]}}  value_3=${${att_value[0]}}  value_4=${${att_value[1]}}
    Power UE Attach and Start traffic    4g_check=True    dl_throughput=${dl_tput}    type=NSA
    Start Bip Log Capture on Loki and download BIP log to UTE    log_name=${biplog_rank4}
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput_rank4[0]}
    Run keyword and continue on failure    Check BIP log for case4
    Power UE stop dl traffic and detach

PM_Counter_M55301C10003_check_PDSCH_transmissions_using_4TX_transmission_with_rank3_100MHz
    Log To Console    \n *** run case 5GC002056-BGAN_5GC001856_L-O_005
    Update the swconfig file    localFilePath=${swconfig_1856_case5}
    Prepare testline to cell onair    localFilePath=${case_scf_dir_path_1856_21A}    tl_scf_filename=${scf[2]}    type=NSA
    Adjust HBTE ATT Value  value_1=${${att_value[0]}}  value_2=${${att_value[0]}}  value_3=${${att_value[0]}}  value_4=${${att_value[1]}}
    Power UE Attach and Start traffic    4g_check=True    dl_throughput=${dl_tput}    type=NSA
    Start Bip Log Capture on Loki and download BIP log to UTE    log_name=${biplog_rank3}
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput_rank3[0]}
    Run keyword and continue on failure    Check BIP log for case5
    Sleep    5min
    ${PM_counter_case_5}    Get PM counter Result    counter_id=M55301C10003
    ...    full_path=BTS/CELLS/NRCELL-1/NDLSQ
    Should be true      ${PM_counter_case_5[-1]} > 0
    Should be true      ${PM_counter_case_5[-1]} < 457551
    Power UE stop dl traffic and detach

CL_C4_Adaptive_Rank_PDSCH_Adaptive_PMI_Link_Adaptation_256QAM_Ideal_Radio_60MHz
    Log To Console    \n *** run case 5GC002056-BGAN_5GC001856_R_009
    Update the swconfig file    localFilePath=${swconfig_1856_case9}
    Prepare testline to cell onair    localFilePath=${case_scf_dir_path_1856_21A}    tl_scf_filename=${scf[0]}    type=SA
    #RANK1
    Adjust HBTE ATT Value  value_1=${${att_value[0]}}  value_2=${${att_value[2]}}  value_3=${${att_value[2]}}  value_4=${${att_value[2]}}
    Power UE Attach and Start traffic    4g_check=False    dl_throughput=${dl_tput}    type=SA
    Start Bip Log Capture on Loki and download BIP log to UTE    log_name=${biplog_rank1}
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput_rank1[2]}
    #RANK2
    Adjust HBTE One ATT Value    value=${${att_value[0]}}    att_port=${att_ports_2}
    Start Bip Log Capture on Loki and download BIP log to UTE    log_name=${biplog_rank2}
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput_rank2[2]}
    #RANK3
    Adjust HBTE One ATT Value    value=${${att_value[0]}}    att_port=${att_ports_3}
    Start Bip Log Capture on Loki and download BIP log to UTE    log_name=${biplog_rank3}
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput_rank3[2]}
    #RANK4
    Adjust HBTE One ATT Value    value=${${att_value[1]}}    att_port=${att_ports_4}
    Start Bip Log Capture on Loki and download BIP log to UTE    log_name=${biplog_rank4}
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput_rank4[2]}
    Run keyword and continue on failure    Check BIP Log for Case9
    Power UE stop dl traffic and detach

CL_Rank_4_DL_4x4_MIMO_PDSCH_transmission_256QAM_with_no_port_selection_with_Wcsirs_is_not_Identity_100MHz
    Log To Console    \n *** run case 5GC002056-BGAN_5GC001856_R_010
    Update the swconfig file    localFilePath=${swconfig_1856_case10}
    Prepare testline to cell onair    localFilePath=${case_scf_dir_path_1856_21A}    tl_scf_filename=${scf[2]}    type=SA
    Adjust HBTE ATT Value  value_1=${${att_value[0]}}  value_2=${${att_value[0]}}  value_3=${${att_value[0]}}  value_4=${${att_value[1]}}
    Power UE Attach and Start traffic    4g_check=False    dl_throughput=${dl_tput}    type=SA
    Start Bip Log Capture on Loki and download BIP log to UTE    log_name=${biplog_rank4}
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput_rank4[0]}
    Run keyword and continue on failure    Check BIP log for case10
    Power UE stop dl traffic and detach

Message_flow_for_dl_4T4R_SU_MIMO_with_beamforming_open_loop_SA_100MHz
    Log To Console    \n *** run case 5GC002056-BHAV_5GC000605_001
    Update the swconfig file    localFilePath=${swconfig_605_case1}
    Prepare testline to cell onair    localFilePath=${case_scf_dir_path_605_21A}    tl_scf_filename=${scf[2]}    type=SA
#    Prepare testline to cell onair and capture CPRT log    localFilePath=${case_scf_dir_path_605_21A}    tl_scf_filename=${scf[2]}
    Adjust HBTE ATT Value  value_1=${${att_value[0]}}  value_2=${${att_value[0]}}  value_3=${${att_value[0]}}  value_4=${${att_value[1]}}
    Power UE Attach and Start traffic    4g_check=False    dl_throughput=${dl_tput}    type=SA
    Start Bip Log Capture on Loki and download BIP log to UTE    log_name=${biplog_rank4}
    Run keyword and continue on failure    Power UE check throughput    Expect_DOWNLINK=${expect_dl_tput_rank4[0]}
    Run keyword and continue on failure    Check BIP log for 605 case1
    Log To Console    \n *** Check BIP log for 605 case1 complete
    Power UE stop dl traffic and detach
    Capture and check CPRT log

##setup and teardown and recovery##
5GC001856_Common Suite Setup for COAM
    CI_interface.Common Suite Setup
    Set suite variable      ${OUTPUT_PATH}    %{HOME}/workspace/CRT/Master/Case_Logs
    5GC001856_COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}
    Set Suite Variable    ${time_stamp}
    Create directory    ${epc_log_path}
    Reset eNB and Check eNB Anchor Cell OnAir

5GC001856_COAM Create log directory
    [Arguments]  ${is_set_to_test_case_level}=${True}    ${timeout}=1min
    5GC001856_Generate suite log path    timeout=${timeout}
    Run keyword if  ${is_set_to_test_case_level}
    ...    Run keywords    Generate test case log path    AND
    ...    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
    ...    ELSE    Set suite variable    ${LOG_PATH}    ${SUITE_LOG_PATH}

5GC001856_Generate suite log path
    [Arguments]    ${timeout}=1min
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    wait until keyword succeeds    ${timeout}    2sec    Connect to DU via ssl
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

5GC001856_Common Suite Teardown for COAM
    [Arguments]    ${localFilePath_default}=${swconfig_default}
    Wait until keyword succeeds    1min    10s    Connect to Classical Common Unit Master gnb
    restore swConfig to default    ${swconfig_default}
    Run Keyword And Ignore Error    AdminCli disconnection and Test teardown
    CI_interface.Common Case Teardown

AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    admin_cli.teardown    connection=${GNB_COAM_ALIAS}

restore swConfig to default
    [Arguments]     ${swconfig_default}
    Update the swconfig file    ${swconfig_default}

Update the swconfig file
    [Arguments]    ${localFilePath}
    Wait until keyword succeeds    1min    10s    Connect to Classical Common Unit Master gnb
    SWConfig.Upload SwConfig File To Asik And Crasign     localFilePath=${localFilePath}    asik_alias=ASIB Master
    [Teardown]      run keyword and ignore error      Csn.disconnect      connection=ASIB Master

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

Tests Recover for SA
    Run keyword    Connect and Modify the parameter on enblte scip errors    dist_name=${enbcell_dist}    parameter=${enbcell_para}
    ...               value=unlocked
    run keyword and ignore error     csn.disconnect    connection=cpc_0
    run keyword and ignore error     coam.teardown    connection=GNB_OAM
    run keyword and ignore error     csn.disconnect    connection=${asib_alias}
    run keyword and ignore error     enblte.teardown    connection=enblte

##prepare BTS##
Reset eNB and Check eNB Anchor Cell OnAir
    #Reset eNB
    Wait until keyword succeeds    10min    30s    Check the enb anchor cell onAir

Check the enb anchor cell onAir
    Connect to eNB via ssl
	${enbcell_status}=    Get the anchor cell status from btsinfo    'cells.lte.1.status.availabilityStatus'
	should be equal    ${enbcell_status}    Online

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

Prepare testline to cell onair
    [Arguments]      ${localFilePath}    ${tl_scf_filename}    ${type}
    Perform full commission for COAM gnb    localFilePath=${localFilePath}    tl_scf_filename=${tl_scf_filename}
    COAM Wait for gnb ready
    Sleep    60s
    Run keyword if    '${type}' == 'SA'
    ...    Connect and Modify the parameter on enblte scip errors    dist_name=${enbcell_dist}    parameter=${enbcell_para}    value=locked
#    Run keyword if    '${type}' == 'NSA'
#    ...    Run keywords    Connect and Modify the parameter on enblte scip errors    dist_name=${enbx2_dist}    parameter=${enbx2_para}
#    ...    value=locked    AND
#    ...    COAM Wait for gnb ready    AND
#    ...    Connect and Modify the parameter on enblte scip errors    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
#    ...    ELSE    Run keywords    COAM Wait for gnb ready    AND
#    ...    Connect and Modify the parameter on enblte scip errors    dist_name=${enbcell_dist}    parameter=${enbcell_para}    value=locked
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

#Prepare testline to cell onair and capture CPRT log
#    [Arguments]      ${localFilePath}    ${tl_scf_filename}
#    Perform full commission for COAM gnb    tl_scf_filename=${tl_scf_filename}    localFilePath=${case_scf_dir_path_605_21A}
#    Sleep    50s
#    Wait until keyword succeeds    10min    10s    Connect to Classical Common Unit Master gnb
#    Log To Console    \n *** Start Capturing CPRT Log From Container
#    Start Capturing CPRT Log From Container
#    Connect to gnb coam via ssl   bts_host=${DU_OAM_IP}
#    Run keyword and continue on failure    Wait until keyword succeeds    10min    5s    COAM Check GNB cell on air
#    Run keyword and continue on failure    Stop Capture CPRT Log From Container
#    Log To Console    \n *** Stop Capture CPRT Log From Container
#    Connect and Modify the parameter on enblte scip errors    dist_name=${enbcell_dist}    parameter=${enbcell_para}    value=locked
#    Download Log From Container To UTE
#    Log To Console    \n *** Download Log From Container To UTE complete and start check CPRT log
#    Run keyword and continue on failure    Check CPRT log
#    [Teardown]    COAM Teardown gnb connections

##PA##
Adjust HBTE ATT Value
    [Arguments]      ${value_1}    ${value_2}    ${value_3}    ${value_4}    ${att_port_1}=${att_ports_1}    ${att_port_2}=${att_ports_2}
    ...    ${att_port_3}=${att_ports_3}    ${att_port_4}=${att_ports_4}    ${att_connection_port}=${att_ports_number}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}    attenuation_port_numbers=${att_connection_port}
    ...    max_attenuation=${HBTE_max_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port_1}    value=${value_1}
    att.set_attenuation     port=${att_port_2}    value=${value_2}
    att.set_attenuation     port=${att_port_3}    value=${value_3}
    att.set_attenuation     port=${att_port_4}    value=${value_4}
    ${value_port1}    att.read_attenuation    port=${att_port_1}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${att_port_2}
    should be equal    ${value_port2}    ${value_2}
    ${value_port3}    att.read_attenuation    port=${att_port_3}
    should be equal    ${value_port3}    ${value_3}
    ${value_port4}    att.read_attenuation    port=${att_port_4}
    should be equal    ${value_port4}    ${value_4}

Adjust HBTE One ATT Value
     [Arguments]      ${value}    ${att_port}=${att_ports_1}    ${att_connection_port}=${att_ports_number}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}    attenuation_port_numbers=${att_connection_port}
    ...    max_attenuation=${HBTE_max_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port}    value=${value}
    ${value_port}    att.read_attenuation    port=${att_port}
    should be equal    ${value_port}    ${value}

##PM counter##
Get PM counter Result
    [Arguments]    ${counter_id}    ${full_path}
    ${PM_counter}    Check PM counter with sort list    counter_id=${counter_id}
    ...    full_path=${full_path}
    [Return]      ${PM_counter}

Check PM counter with sort list
    [Arguments]    ${counter_id}    ${full_path}    ${date}=all
    Connect to gnb coam via ssl
    ${result} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${full_path}    date=${date}
    Sort list    ${result}
    [Return]    ${result}
    [Teardown]    COAM Teardown gnb connections


###log capture###
##BIPlog##
Enable mirror port on Loki
    [Arguments]     ${mirror_port}=eths2    ${asib_alias}=ASIB Master
    csn.Execute     command=/usr/bin/lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei00 -f L1_L2_UL -b "C1B1(2)" -s 1 -l ${mirror_port} -v 303
    ...             connection=${asib_alias}
    csn.Execute     command=/usr/bin/lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei00 -f L1_L2_DL -b "C1B1(2)" -s 1 -l ${mirror_port} -v 303
    ...             connection=${asib_alias}
    csn.Execute     command=ncp_portmirror -p xgmac97 -r    connection=${asib_alias}
    csn.Execute     command=ncp_portmirror -d netdriver -p xgmac97    connection=${asib_alias}

Start Bip Log Capture on Loki
    [Arguments]     ${mirror_port}=eths2    ${asib_alias}=ASIB Master
    Enable mirror port on Loki    mirror_port=${mirror_port}
    csn.Send command     command=tcpdump -i ${mirror_port} -w ${gnb_path}/tcpdumpL2L1.pcap -vv
    ...                  connection=${asib_alias}

#Enable mirror port on Loki
#    [Arguments]     ${mirror_port}=eths3    ${asib_alias}=ASIB Master
#    csn.Execute     command=/usr/bin/lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei02 -f L1_L2_UL -b "C1B1(2)" -s 1 -l ${mirror_port} -v 304
#    ...             connection=${asib_alias}
#    csn.Execute     command=/usr/bin/lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei02 -f L1_L2_DL -b "C1B1(2)" -s 1 -l ${mirror_port} -v 305
#    ...             connection=${asib_alias}
#    csn.Execute     command=ncp_portmirror -p xgmac96 -r    connection=${asib_alias}
#    csn.Execute     command=ncp_portmirror -d netdriver -p xgmac96    connection=${asib_alias}

#Start Bip Log Capture on Loki
#    [Arguments]     ${mirror_port}=eths3    ${asib_alias}=ASIB Master
#    Enable mirror port on Loki    mirror_port=${mirror_port}
#    csn.Send command     command=tcpdump -i ${mirror_port} -w ${gnb_path}/tcpdumpL2L1.pcap
#    ...                  connection=${asib_alias}

Start Bip Log Capture on Loki and download BIP log to UTE
    [Arguments]     ${log_name}    ${duration}=1s
    Connect to Classical Common Unit Master gnb
    Sleep    3s
    Start Bip Log Capture on Loki
    Sleep    ${duration}
    Stop and download bip log to UTE    bip_log_name=${epc_log_path}${log_name}

Stop and download bip log to UTE
    [Arguments]    ${bip_log_name}     ${connection}=ASIB Master    ${gnb_index}=${0}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3s
    csn.download_file   remote_path=${gnb_path}/tcpdumpL2L1.pcap   local_path=${bip_log_name}   connection=${connection}
    sleep    3s
    csn.execute      command=rm -rf ${gnb_path}/tcpdumpL2L1.pcap    connection=${connection}

Check BIP Log for Case1
    Check BIP log    log_name=${biplog_rank1}    message_filter=dldata_pdschsendreq
    ...              xpath_filter=.//DlData_PdschSendReq.grants_item_15.numOfLayers    value=0x00000001
    Sleep    10s
    Check BIP log    log_name=${biplog_rank2}    message_filter=dldata_pdschsendreq
    ...              xpath_filter=.//DlData_PdschSendReq.grants_item_15.numOfLayers    value=0x00000002
    Sleep    10s
    Check BIP log    log_name=${biplog_rank3}    message_filter=dldata_pdschsendreq
    ...              xpath_filter=.//DlData_PdschSendReq.grants_item_15.numOfLayers    value=0x00000003
    Sleep    10s
    Check BIP log    log_name=${biplog_rank4}    message_filter=dldata_pdschsendreq
    ...              xpath_filter=.//DlData_PdschSendReq.grants_item_15.numOfLayers    value=0x00000004
    Sleep    10s
    Check BIP log    log_name=${biplog_rank4}    message_filter=dldata_pdschsendreq
    ...              xpath_filter=.//DlData_PdschSendReq.grants_item_15.modulationOrder    value=8

Check BIP log for case4
    Check BIP log    log_name=${biplog_rank4}    message_filter=dldata_pdschsendreq
    ...              xpath_filter=.//DlData_PdschSendReq.grants_item_15.numOfLayers    value=0x00000004
    Sleep    10s
    Check BIP log    log_name=${biplog_rank4}    message_filter=dldata_pdschsendreq
    ...              xpath_filter=.//DlData_PdschSendReq.grants_item_15.modulationOrder    value=8
    Sleep    10s
    Check BIP log    log_name=${biplog_rank4}    message_filter=dldata_pdschsendreq
    ...              xpath_filter=.//DlData_PdschSendReq.grants_item_15.pdschPrecodingOption4x4    value=6

Check BIP log for case5
    Check BIP log    log_name=${biplog_rank3}    message_filter=dldata_pdschsendreq
    ...              xpath_filter=.//DlData_PdschSendReq.grants_item_15.numOfLayers    value=0x00000003
    Sleep    10s
    Check BIP log    log_name=${biplog_rank3}    message_filter=dldata_pdcchsendreq
    ...              xpath_filter=.//DlData_PdcchSendReq.dciInfo_item_15.pdcchPrecodingOption4x4    value=0

Check BIP Log for Case9
    Check BIP log    log_name=${biplog_rank1}    message_filter=dldata_pdschsendreq
    ...              xpath_filter=.//DlData_PdschSendReq.grants_item_15.numOfLayers    value=0x00000001
    Sleep    10s
    Check BIP log    log_name=${biplog_rank2}    message_filter=dldata_pdschsendreq
    ...              xpath_filter=.//DlData_PdschSendReq.grants_item_15.numOfLayers    value=0x00000002
    Sleep    10s
    Check BIP log    log_name=${biplog_rank3}    message_filter=dldata_pdschsendreq
    ...              xpath_filter=.//DlData_PdschSendReq.grants_item_15.numOfLayers    value=0x00000003
    Sleep    10s
    Check BIP log    log_name=${biplog_rank4}    message_filter=dldata_pdschsendreq
    ...              xpath_filter=.//DlData_PdschSendReq.grants_item_15.numOfLayers    value=0x00000004
    Sleep    10s
    Check BIP log    log_name=${biplog_rank4}    message_filter=dldata_pdschsendreq
    ...              xpath_filter=.//DlData_PdschSendReq.grants_item_15.modulationOrder    value=8
    Sleep    10s
    Check BIP log    log_name=${biplog_rank4}    message_filter=dldata_pdcchsendreq
    ...              xpath_filter=.//DlData_PdcchSendReq.dciInfo_item_15.pdcchPrecodingOption4x4    value=1

Check BIP log for case10
    Check BIP log    log_name=${biplog_rank4}    message_filter=dldata_pdschsendreq
    ...              xpath_filter=.//DlData_PdschSendReq.grants_item_15.numOfLayers    value=0x00000004
    Sleep    10s
    Check BIP log    log_name=${biplog_rank4}    message_filter=dldata_pdschsendreq
    ...              xpath_filter=.//DlData_PdschSendReq.grants_item_15.modulationOrder    value=8
    Sleep    10s
    Check BIP log    log_name=${biplog_rank4}    message_filter=dldata_pdschsendreq
    ...              xpath_filter=.//DlData_PdschSendReq.grants_item_15.pdschPrecodingOption4x4    value=4

Check BIP log for 605 case1
    Check BIP log    log_name=${biplog_rank4}    message_filter=dldata_pdschsendreq
    ...              xpath_filter=.//DlData_PdschSendReq.grants_item_15.numOfLayers    value=0x00000004
    #Sleep    30s
    #Check BIP log    log_name=${biplog_rank4}    message_filter=dldata_pdschsendreq
    #...              xpath_filter=.//DlData_PdschSendReq.grants_item_15.modulationOrder    value=8
    #Sleep    30s
    #Check BIP log    log_name=${biplog_rank4}    message_filter=dldata_pdschsendreq
    #...              xpath_filter=.//DlData_PdschSendReq.grants_item_15.pdschPrecodingOption4x4    value=2

Check BIP log
    [Arguments]    ${log_name}    ${message_filter}    ${xpath_filter}    ${value}
    Log To Console    \n *** Start to check BIP log
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${log_name}    tshark_path=${tshark_path}
    ...    luashark_path=${LUA_SCRIPT_PATH}    command_template=${None}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${message_filter}
    ${check_parameter}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=${xpath_filter}
    should contain    ${check_parameter}    ${value}

Capture and check CPRT log
    Connect to gnb coam via ssl   bts_host=${DU_OAM_IP}
    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-10040/NRBTS-10040/NRCELL-1    parameter=administrativeState
    ...    operation=update    value=Locked    skip_parameter_relation_errors=true    connection=GNB_OAM
    Sleep   20s
    Wait until keyword succeeds    10min    10s    Connect to Classical Common Unit Master gnb
    Log To Console    \n *** Start Capturing CPRT Log From Container
    Start Capturing CPRT Log From Container
    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-10040/NRBTS-10040/NRCELL-1    parameter=administrativeState
    ...    operation=update    value=Unlocked    skip_parameter_relation_errors=true    connection=GNB_OAM
    Run keyword and continue on failure    Wait until keyword succeeds    10min    5s    COAM Check GNB cell on air
    Run keyword and continue on failure    Stop Capture CPRT Log From Container
    Log To Console    \n *** Stop Capture CPRT Log From Container
    Download Log From Container To UTE
    Log To Console    \n *** Download Log From Container To UTE complete and start check CPRT log
    Run keyword and continue on failure    Check CPRT log

Start Capturing CPRT Log From Container
    [Arguments]   ${filename}=cprt01_eths0.pcap    ${containerid}=0x1519    ${listen_port}=eths0     ${log_dir}=/tmp   ${connection}=${asib_alias}
    ssh.send command    command=lxc-attach -n ${containerid} -- tcpdump -i ${listen_port} -w ${log_dir}/${filename} &>/dev/null &
    ...    connection=${connection}

Stop Capture CPRT Log From Container
    [Arguments]    ${containerid}=0x1519    ${connection}=${asib_alias}
    ssh.send command    command=ps -ef|grep tcpdump|grep -v grep|grep any|awk '{print $2}'|xargs kill -2    connection=${connection}
#    ${pid}  ssh.execute    command=lxc-attach -n ${containerid} -- ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'  connection=${connection}
#    sleep   2s
#    ssh.execute    command=lxc-attach -n ${containerid} -- kill -2 ${pid.replace('\r\n','')}   connection=${connection}

Download Log From Container To UTE
    [Arguments]    ${filename}=cprt01_eths0.pcap    ${log_dir}=/tmp/node_CPRT00/tmp    ${node_name}=CPRT00    ${connection}=${asib_alias}
    [Timeout]    10min
    ssh.download_file   local_path=${epc_log_path}/${filename}    remote_path=${log_dir}/${filename}   connection=${connection}
    sleep    20s
    [Teardown]    #ssh.execute    command=rm -rf /tmp/node_CPRT00/tmp/${filename}    connection=${connection}

Check CPRT Log
    Load CPRT Log
    Check SCTP log    message_filter=dlcell_setupreq
    ...               xpath_filter=.//DlCell_SetupReq.SetupReq.dlMimoMode    value=3
    Sleep    10s
    Check SCTP log    message_filter=dlcell_setupreq
    ...               xpath_filter=.//DlCell_SetupReq.SetupReq.actBeamforming    value=0x00000001
    Sleep    10s
    Check SCTP log    message_filter=dlcell_setupreq
    ...               xpath_filter=.//DlCell_SetupReq.SetupReq.dlSubcellType    value=1

Load CPRT Log
    [Arguments]    ${log_name}=cprt01_eths0.pcap
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}/${log_name}    tshark_path=${tshark_path}
    ...    luashark_path=${LUA_SCRIPT_PATH}    command_template=${None}
    Set test variable    ${all_packets}

Check SCTP log
    [Arguments]    ${message_filter}    ${xpath_filter}    ${value}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${message_filter}
    ${check_parameter}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=${xpath_filter}
    should contain    ${check_parameter}    ${value}

##UE##
Power UE Attach and Start traffic
    [Arguments]    ${4g_check}   ${dl_throughput}    ${type}
    Power UE Precondition
    Run keyword and continue on failure    _Reboot UE    connection=cpc_0
    Run keyword if    '${type}' == 'SA'    _Reboot UE    connection=cpc_0
    Sleep    60s
    Run keyword if    '${type}' == 'NSA'
    ...    Run keyword and continue on failure    Power UE Attach and Verify attach    4g_check=True
    ...    ELSE    Run keyword and continue on failure    Power UE Attach and Verify attach    4g_check=False
    Power UE Start traffic     dl_throughput=${dl_throughput}

Power UE Precondition
    [Arguments]    ${ue_type}=askey
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    capatibility_index=${0}    reset_sol=pc_reset    detach_request=${true}

Power UE Attach and Verify attach
    [Arguments]    ${4g_check}    ${gnb_index}=${0}    ${ue_type}=askey
    Log To Console    \n *** UE Attach started
     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${0}    gnb_index=${gnb_index}
    ...                       4G_check=${4g_check}    5Gstatus=PASS

Power UE Start traffic
    [Arguments]    ${dl_throughput}     ${duration}=${DL_TIME}    ${dl_length}=${DL_LENGTH}    ${dl_port}=default
    ...    ${ue_index}=${0}    ${ue_type}=askey
    Log To Console    \n *** Start DL traffic
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}
    ...                       iperf_port=${dl_port}    ue_index=${0}    cap_index=${0}    buffer_size=${dl_length}

Power UE check throughput
    [Arguments]    ${Expect_DOWNLINK}    ${ue_index}=${0}    ${gnb_index}=${0}    ${ue_type}=askey
    Log To Console    \n *** Start to check DL throughput
    wait until keyword succeeds    2min    10s    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${Expect_DOWNLINK}
    ...    ue_index=${ue_index}    hw_slot=1    sample=${10}    start_offset=${3}    sleep_time=${5}    cellid=${EMPTY}    gnb_index=${gnb_index}

Power UE stop dl traffic
    [Arguments]    ${dl_port}=default    ${ue_type}=askey
    Log To Console    \n *** Stop DL traffic
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}

Power UE stop ul traffic
    [Arguments]    ${ul_port}=default    ${ue_type}=askey
    Log To Console    \n *** Stop UL traffic
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${ul_port}

Power UE Detach
    [Arguments]    ${ue_type}=askey
    Log To Console    \n *** UE Detach started
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

Power UE stop dl traffic and detach
    [Arguments]    ${dl_port}=default    ${ue_type}=askey
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}
    sleep    3s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
