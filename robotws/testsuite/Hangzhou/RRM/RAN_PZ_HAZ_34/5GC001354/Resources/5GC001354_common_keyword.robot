*** Settings ***
Documentation     author: jack.zeng
...                 contact: jack.zeng@nokia-sbell.com
...                 squad group: SG_03
...                 feature : 5GC001354
Library    taf.pdu       WITH NAME    pdu
Library    taf.analyzer.pcap
Library    taf.rfrl.common_resources.python.SWConfig    WITH NAME    swconf
Library     ../../../../OAM/RAN_PZ_HAZ_34/libraries/get_bts_info.py   WITH NAME    lib
Library     taf.transport.ssh   WITH NAME   csn
Library     taf.ue    WITH NAME    ute_ue
Library     taf.hw.rf_attenuator    WITH NAME    attenuator
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library    taf.analyzer.pcap   WITH NAME    parser
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/check_android_ue_l3_call_process.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Variables     ./variables.py

*** Variables ***
${ASIK_ALIAS}             ASIK Master
${BIP_ALIAS}             ASIK Master BIP
${att_port_0}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${mrbtsId}                   ${tl.gnbs[0].instance_id}
${nrbtsId}                   ${tl.gnbs[0].global_bts_id}
${UL_PORT}                   ${tl.ues[0].iperf_details.ssh_connection_details.port}
${DL_PORT}                   ${tl.ues[0].iperf_details.port}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${max_attenuation_value}     ${110}
${TS_LOG_PATH_BASE}      /opt/workspace/CRT/Master/Case_Logs
${tmp_swconfig_dir}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/5GC002040
${SCF_TEMPLATE_PATH}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/5GC002040/2DL_2UL_SCF.xml
${SCF_TEMPLATE_PATH_029}    /home/ute/MN/UTE/robotws/commissionings/HGZ/7_5_UTE5G402T029/2DL_2UL_SCF.xml
${scripts_path}        ${CURDIR}
${LUA_SCRIPT_PATH}      /home/ute/Downloads/Lua/generated_luashark/luashark.lua
${LENGTH}              1400
${DURATION}               3600
${PROGRAM}              5G19B
${golden_scf_name}    golden_TDD.xml
${golden_scf_name_gnb2}    golden_FDD.xml
${ue_type}    huawei
${ui_version}    S20UI2.5
${ue_index}      0
${dl_direction}    dl
${ul_direction}    ul
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
@{CT_Bvalues}    0    0    570    605     330    355    575    605     830    865
@{CT_1354_B}    M55355C04007     M55355C05007
#${epc_log_path}    /opt/workspace/CIT/Master/Case_Logs/
${atten_ip}                ${tl.attenuator[0].ip_addr}
${att_api_port}              ${tl.attenuator[0].port}
${vendor}                    ${tl.attenuator[0].vendor}
${TL350_att_port_1}                ${tl.attenuator[0].attenuator_ports[1]}
${TL350_att_port_3}                ${tl.attenuator[0].attenuator_ports[3]}
${TL350_att_port_5}                ${tl.attenuator[0].attenuator_ports[5]}
${TL350_att_port_7}                ${tl.attenuator[0].attenuator_ports[7]}
${TL350_att_port_9}                ${tl.attenuator[0].attenuator_ports[9]}
${TL350_att_port_11}                ${tl.attenuator[0].attenuator_ports[11]}
${TL350_att_port_13}                ${tl.attenuator[0].attenuator_ports[13]}
${TL350_att_port_15}                ${tl.attenuator[0].attenuator_ports[15]}
${protocol_TCP}    tcp
${window_size}    2M
${seg_size}    1180
${gnb_path}    /tmp
${enb_path}    /tmp/
${enb_scf}     5GC001354_eNB.xml
${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/
${TL038_att_port_7}                ${tl.attenuator[0].attenuator_ports[7]}
${TL038_att_port_8}                ${tl.attenuator[0].attenuator_ports[8]}
${TL038_att_port_12}                ${tl.attenuator[0].attenuator_ports[12]}
${TL038_att_port_13}                ${tl.attenuator[0].attenuator_ports[13]}
${TL038_att_port_14}                ${tl.attenuator[0].attenuator_ports[14]}
${24211_att_port_1}                ${tl.attenuator[0].attenuator_ports[1]}
${24211_att_port_2}                ${tl.attenuator[0].attenuator_ports[2]}
${24211_att_port_3}                ${tl.attenuator[0].attenuator_ports[3]}
${24211_att_port_4}                ${tl.attenuator[0].attenuator_ports[4]}
${24211_att_port_5}                ${tl.attenuator[0].attenuator_ports[5]}
${24211_att_port_6}                ${tl.attenuator[0].attenuator_ports[6]}
${24211_att_port_7}                ${tl.attenuator[0].attenuator_ports[7]}
${24211_att_port_8}                ${tl.attenuator[0].attenuator_ports[8]}
${24211_att_port_9}                ${tl.attenuator[0].attenuator_ports[9]}
${att_ipaddr}      ${tl.attenuator[0].ip_addr}
${34411_att_port_1}                 ${tl.attenuator[0].attenuator_ports[1]}
${34411_att_port_2}                ${tl.attenuator[0].attenuator_ports[2]}
${34411_att_port_3}                ${tl.attenuator[0].attenuator_ports[3]}
${34411_att_port_4}                ${tl.attenuator[0].attenuator_ports[4]}
${34411_att_port_5}                ${tl.attenuator[0].attenuator_ports[5]}
${34411_att_port_6}                ${tl.attenuator[0].attenuator_ports[6]}
${34411_att_port_7}                ${tl.attenuator[0].attenuator_ports[7]}
${34411_att_port_8}                ${tl.attenuator[0].attenuator_ports[8]}
${34411_att_port_9}                ${tl.attenuator[0].attenuator_ports[9]}
${34411_att_port_10}                ${tl.attenuator[0].attenuator_ports[10]}
${34411_att_port_11}                ${tl.attenuator[0].attenuator_ports[11]}
${34411_att_port_12}                ${tl.attenuator[0].attenuator_ports[12]}
${34411_att_port_13}                ${tl.attenuator[0].attenuator_ports[13]}
${34411_att_port_14}                ${tl.attenuator[0].attenuator_ports[14]}
${34411_att_port_15}                ${tl.attenuator[0].attenuator_ports[15]}

${34111_att_port_1}                 ${tl.attenuator[0].attenuator_ports[1]}
${34111_att_port_2}                ${tl.attenuator[0].attenuator_ports[2]}
${34111_att_port_3}                ${tl.attenuator[0].attenuator_ports[3]}
${34111_att_port_4}                ${tl.attenuator[0].attenuator_ports[4]}
${34111_att_port_5}                ${tl.attenuator[0].attenuator_ports[5]}
${34111_att_port_6}                ${tl.attenuator[0].attenuator_ports[6]}
${34111_att_port_7}                ${tl.attenuator[0].attenuator_ports[7]}
${34111_att_port_8}                ${tl.attenuator[0].attenuator_ports[8]}
${34111_att_port_9}                ${tl.attenuator[0].attenuator_ports[9]}
${34111_att_port_10}                ${tl.attenuator[0].attenuator_ports[10]}
${34111_att_port_11}                ${tl.attenuator[0].attenuator_ports[11]}
${34111_att_port_12}                ${tl.attenuator[0].attenuator_ports[12]}

@{att_connection_port}    ${1}    ${2}     ${3}    ${4}    ${5}    ${6}     ${7}    ${8}    ${9}    ${10}    ${11}
    ...     ${12}     ${13}    ${14}    ${15}    ${16}
@{TL350_PA_port_list}     ${TL350_att_port_1}    ${TL350_att_port_3}    ${TL350_att_port_5}    ${TL350_att_port_7}
    ...    ${TL350_att_port_9}    ${TL350_att_port_11}    ${TL350_att_port_13}    ${TL350_att_port_15}
@{TL341_PA_port_list}     ${34111_att_port_1}    ${34111_att_port_2}    ${34111_att_port_3}    ${34111_att_port_4}
    ...    ${34111_att_port_5}     ${34111_att_port_6}     ${34111_att_port_7}     ${34111_att_port_8}
    ...    ${34111_att_port_9}     ${34111_att_port_10}     ${34111_att_port_11}     ${34111_att_port_12}
#@{TL242_PA_port_list}     ${TL242_att_port_1}    ${TL242_att_port_2}    ${TL242_att_port_3}    ${TL242_att_port_4}
#    ...    ${TL242_att_port_5}     ${TL242_att_port_6}     ${TL242_att_port_7}
@{TL038_PA_port_list}     ${TL038_att_port_7}    ${TL038_att_port_8}    ${TL038_att_port_12}    ${TL038_att_port_13}
    ...    ${TL038_att_port_14}
@{TL350_gNB1_PA_values_list}     ${110}    ${110}    ${110}    ${0}    ${110}    ${110}    ${0}    ${110}
@{TL038_gNB1_PA_values_list}     ${110}    ${0}    ${0}    ${110}    ${110}
#@{TL242_gNB1_PA_values_list}     ${120}    ${120}    ${120}    ${0}    ${120}   ${0}    ${120}
@{TL341_gNB1_PA_values_list}     ${0}    ${0}    ${120}    ${120}    ${120}   ${120}    ${120}    ${120}
    ...        ${5}    ${5}    ${120}    ${120}
@{TL350_gNB2_PA_values_list}     ${110}    ${110}    ${0}    ${110}    ${110}    ${0}    ${110}    ${110}
${gnb_instance}    ${tl.gnbs[0].instance_id}
@{gnb_id}    34411    34111    24211
@{branch}    SBTS23R4_ENB_0000    SBTS23R2_ENB_0000    SBTS24R1_ENB_0000    SBTS23R3_ENB_0000
*** Keywords ***
Common Suite Setup for COAM and Create log directory_gNB
    [Arguments]    ${gnb_index}=${gnb_index}
    COAM Create log directory_gNB    is_set_to_test_case_level=${False}    gnb_index=${gnb_index}
    ${time_stamp}    DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}

COAM Create log directory_gNB
    [Arguments]  ${is_set_to_test_case_level}=${True}    ${timeout}=1min     ${gnb_index}=${gnb_index}
    Generate suite log path_gNB    timeout=${timeout}    gnb_index=${gnb_index}
    Run keyword if  ${is_set_to_test_case_level}
    ...    Run keywords    Generate test case log path    AND
    ...    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
    ...    ELSE    Set suite variable    ${LOG_PATH}    ${SUITE_LOG_PATH}

Generate suite log path_gNB
    [Documentation]    Author: Ding Binmei [PRIVATE]
    ...                Description: Create log directory with test suite level and open a common variable ${SUITE_LOG_PATH}
    [Arguments]    ${timeout}=1min     ${gnb_index}=${gnb_index}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    Run keyword if    ${has_cbts}   wait until keyword succeeds    ${timeout}    2sec    Cloud DU connect to gnb coam via ssl
    ...    ELSE    wait until keyword succeeds   ${timeout}    2sec    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    ${sw_version} =     coam.get_sw_version    connection=GNB_OAM
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Create directory    ${SUITE_LOG_PATH}

Case preparaton for 1354_B01
    Run Keyword if    '${tl.gnbs[0].instance_id}' == '35011'    Set Test suit variables for gnb1
    ...    ELSE IF     '${tl.gnbs[0].instance_id}' == '3811'    Set Test suit variables for gnb1
    ...    ELSE IF     '${tl.gnbs[0].instance_id}' == '24211'    Set Test suit variables for gnb1
    ...    ELSE IF     '${tl.gnbs[0].instance_id}' == '34111'    Set Test suit variables for gnb1
    ...    ELSE      Log    \n *** unknown gNBID do nothing

Case preparaton for 1354_B02
    Run Keyword if    '${tl.gnbs[0].instance_id}' == '35011'    Set Test suit variables for gnb2
    ...    ELSE IF     '${tl.gnbs[0].instance_id}' == '3811'    Set Test suit variables for gnb1
    ...    ELSE IF     '${tl.gnbs[0].instance_id}' == '24211'    Set Test suit variables for gnb1
    ...    ELSE IF     '${tl.gnbs[0].instance_id}' == '34111'    Set Test suit variables for gnb1
    ...    ELSE      Log    \n *** unknown gNBID do nothing

Set Test suit variables for gnb1
     Set Suite Variable    ${gnb_index}    ${0}
     Set Suite Variable    ${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
     Set Suite Variable    ${tl_scf_file_name}    1354_gNB1.xml

Set Test suit variables for gnb2
     Set Suite Variable    ${gnb_index}    ${1}
     Set Suite Variable    ${WEBUI_COAM}    https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
     Set Suite Variable    ${tl_scf_file_name}    1354_gNB2.xml

Set HBTE PA
    [Arguments]    ${att_ports}=${PA_port_list}    ${values}=${PA_values}    ${att_connection_port}=${att_connection_port}
    Set the attenuation value    ${att_ports}    ${values}    ${att_connection_port}

Set TOPYoung PA
    [Arguments]    ${att_ports}=${PA_port_list}    ${values}=${PA_values}
    Set the attenuation value topyoung    ${att_ports}    ${values}

Precondition for attn
    [Arguments]    ${gnb_index}=${gnb_index}
    ${BTS_ID}    set variable      ${tl.gnbs[${gnb_index}].instance_id}
    Run Keyword if    '${tl.gnbs[${gnb_index}].instance_id}' == '35011'    adjust attenuation for gNB_35011_Cell1
    ...    ELSE IF     '${tl.gnbs[${gnb_index}].instance_id}' == '3811'    adjust attenuation for gNB_3811_Cell1
    ...    ELSE IF     '${tl.gnbs[${gnb_index}].instance_id}' == '35012'    adjust attenuation for gNB_35012_Cell1
    ...    ELSE IF     '${tl.gnbs[${gnb_index}].instance_id}' == '24211'    adjust attenuation for gNB_24211_Cell1
    ...    ELSE IF     '${tl.gnbs[${gnb_index}].instance_id}' == '34111'    adjust attenuation for gNB_34111_Cell1
    ...    ELSE      Log    \n *** unknown gNBID do nothing

adjust attenuation for gNB_3811_Cell1
    ${att_ipaddr} =    set suite variable     ${tl.attenuator[0].ip_addr}
    Set HBTE PA    att_ports=${TL038_PA_port_list}    values=${TL038_gNB1_PA_values_list}
    set suite variable    ${expect_dl_tput_Peak}              550
    Prepare the gNB cells onair status    gnb_index=${gnb_index}    tl_scf_file_name=${tl_scf_file_name}



adjust attenuation for gNB_24211_Cell1
    ${att_ipaddr} =    set suite variable     ${tl.attenuator[0].ip_addr}
    Set HBTE PA    att_ports=${TL242_PA_port_list}    values=${TL242_gNB1_PA_values_list}
    set suite variable    ${DATA_TP}            2M    #send TP
    set suite variable    ${DATA_TP_Peak}       1200M    #send TP
    set suite variable    ${window_size}    10k
    set suite variable    ${expect_dl_tput}               5
    set suite variable    ${expect_dl_tput_Peak}              100
    set suite variable    ${ui_version}       default
    set suite variable    ${ue_index}    1
    Common Case TestLine Setup    ModifySCF_Beforecommission=True    ModifySCF_Beforecommission_GNB2=False
    ...    golden_scf_name=${golden_scf_name}    MOsToAdd=${MOS_ADD_GNB1_B1}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_B1_TL242}
    ...    ListToAdd=${LIST_TO_ADD_GNB1_B1}    scf_path=${tl_scf_dir_path}    Enb_commission=True    enb_scf=${enb_scf}
    ...    enb_scf_dir_path=${tl_scf_dir_path}    ListParamterToModify=${LIST_PARAMETERS_TO_MODIFY_GNB1_TL242}

adjust attenuation for gNB_34111_Cell1
    ${att_ipaddr} =    set suite variable     ${tl.attenuator[0].ip_addr}
    Set HBTE PA    att_ports=${TL341_PA_port_list}    values=${TL341_gNB1_PA_values_list}
    set suite variable    ${DATA_TP}            2M    #send TP
    set suite variable    ${DATA_TP_Peak}       1200M    #send TP
    set suite variable    ${window_size}    10k
    set suite variable    ${expect_dl_tput}               5
    set suite variable    ${expect_dl_tput_Peak}              100
    set suite variable    ${ui_version}       default
    set suite variable    ${ue_index}    1
    Common Case TestLine Setup    ModifySCF_Beforecommission=True    ModifySCF_Beforecommission_GNB2=False
    ...    golden_scf_name=${golden_scf_name}     MOsToAdd=${MOS_ADD_GNB1_B1_NSA}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_B1_Common}     ListToAdd=${LIST_TO_ADD_GNB1_B1}
    ...    scf_path=${tl_scf_dir_path}    Enb_commission=False

adjust attenuation for gNB_35011_Cell1
    ${att_ipaddr} =    set suite variable     ${tl.attenuator[0].ip_addr}
    Set HBTE PA    att_ports=${TL350_PA_port_list}    values=${TL350_gNB1_PA_values_list}
    Prepare the gNB cells onair status    gnb_index=${gnb_index}    tl_scf_file_name=${tl_scf_file_name}

adjust attenuation for gNB_35012_Cell1
    ${att_ipaddr} =    set suite variable     ${tl.attenuator[0].ip_addr}
    Set HBTE PA    att_ports=${TL350_PA_port_list}    values=${TL350_gNB2_PA_values_list}
    Prepare the gNB cells onair status    gnb_index=${gnb_index}    tl_scf_file_name=${tl_scf_file_name}

Get gnb Cells ID
    ${cell1_physCellId}    get physCellId    cellid=${1}    nrbtsid=${tl.gnbs[${gnb_index}].instance_id}    gnb_index=${gnb_index}
    ${cell2_physCellId}    get physCellId    cellid=${2}    nrbtsid=${tl.gnbs[${gnb_index}].instance_id}    gnb_index=${gnb_index}
    set suite variable     ${cell1_physCellId}
    set suite variable     ${cell2_physCellId}

adjust attenuation to trigger Intra_gNB_HO
    [Arguments]    ${gnb_index}=${gnb_index}
    Run Keyword if    '${tl.gnbs[${gnb_index}].instance_id}' == '35012'    adjust attenuation for gNB_35012 Intra_gNB_HO
    ...    ELSE IF     '${tl.gnbs[${gnb_index}].instance_id}' == '3811'    adjust attenuation for gNB_3811 Intra_gNB_HO
    ...    ELSE IF     '${tl.gnbs[${gnb_index}].instance_id}' == '24211'    adjust attenuation for gNB_24211 Intra_gNB_HO
    ...    ELSE IF     '${tl.gnbs[${gnb_index}].instance_id}' == '34111'    adjust attenuation for gNB_34111 Intra_gNB_HO
    ...    ELSE      Log    \n *** unknown gNBID do nothing

adjust attenuation for gNB_34111 Intra_gNB_HO
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${34111_att_port_1}      att_port_2=${34111_att_port_2}
    ...     att_port_3=${34111_att_port_3}     att_port_4=${34111_att_port_4}    atten_ip=${atten_ip}
    ...     value_1=${10}    value_2=${10}
    ...     value_3=${10}    value_4=${10}
    sleep    3s
    adjust the HBTE attenuation value    att_port_1=${34111_att_port_1}      att_port_2=${34111_att_port_2}
    ...     att_port_3=${34111_att_port_3}     att_port_4=${34111_att_port_4}    atten_ip=${atten_ip}
    ...     value_1=${15}    value_2=${15}
    ...     value_3=${5}    value_4=${5}
    sleep    2s
    adjust the HBTE attenuation value    att_port_1=${34111_att_port_1}      att_port_2=${34111_att_port_2}
    ...     att_port_3=${34111_att_port_3}     att_port_4=${34111_att_port_4}    atten_ip=${atten_ip}
    ...     value_1=${23}    value_2=${23}
    ...     value_3=${0}    value_4=${0}
    sleep    3s
    adjust the HBTE attenuation value    att_port_1=${34111_att_port_1}      att_port_2=${34111_att_port_2}
    ...     att_port_3=${34111_att_port_3}     att_port_4=${34111_att_port_4}    atten_ip=${atten_ip}
    ...     value_1=${30}    value_2=${30}
    ...     value_3=${0}    value_4=${0}
    sleep    2s
    adjust the HBTE attenuation value    att_port_1=${34111_att_port_1}      att_port_2=${34111_att_port_2}
    ...     att_port_3=${34111_att_port_3}     att_port_4=${34111_att_port_4}    atten_ip=${atten_ip}
    ...     value_1=${35}    value_2=${35}
    ...     value_3=${0}    value_4=${0}
    sleep    10s

adjust attenuation for gNB_24211 Intra_gNB_HO
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${TL341_att_port_3}      att_port_2=${TL341_att_port_4}
    ...     att_port_3=${TL242_att_port_3}     att_port_4=${TL242_att_port_4}    atten_ip=${atten_ip}
    ...     value_1=${10}    value_2=${10}
    ...     value_3=${10}    value_4=${10}
    sleep    3s
    adjust the HBTE attenuation value    att_port_1=${TL242_att_port_3}      att_port_2=${TL242_att_port_4}
    ...     att_port_3=${TL242_att_port_3}     att_port_4=${TL242_att_port_4}    atten_ip=${atten_ip}
    ...     value_1=${0}    value_2=${15}
    ...     value_3=${0}    value_4=${15}
    sleep    2s
    adjust the HBTE attenuation value    att_port_1=${TL242_att_port_3}      att_port_2=${TL242_att_port_4}
    ...     att_port_3=${TL242_att_port_3}     att_port_4=${TL242_att_port_4}    atten_ip=${atten_ip}
    ...     value_1=${0}    value_2=${23}
    ...     value_3=${0}    value_4=${23}
    sleep    3s
    adjust the HBTE attenuation value    att_port_1=${TL242_att_port_3}      att_port_2=${TL242_att_port_4}
    ...     att_port_3=${TL242_att_port_3}     att_port_4=${TL242_att_port_4}    atten_ip=${atten_ip}
    ...     value_1=${0}    value_2=${30}
    ...     value_3=${0}    value_4=${30}
    sleep    2s
    adjust the HBTE attenuation value    att_port_1=${TL242_att_port_3}      att_port_2=${TL242_att_port_4}
    ...     att_port_3=${TL242_att_port_3}     att_port_4=${TL242_att_port_4}    atten_ip=${atten_ip}
    ...     value_1=${0}    value_2=${33}
    ...     value_3=${0}    value_4=${33}
    sleep    10s

adjust attenuation for gNB_3811 Intra_gNB_HO
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${TL038_att_port_8}      att_port_2=${TL038_att_port_12}
    ...     att_port_3=${TL038_att_port_13}     att_port_4=${TL038_att_port_14}    atten_ip=${atten_ip}
    ...     value_1=${5}    value_2=${5}
    ...     value_3=${15}    value_4=${15}
    sleep    3s
    adjust the HBTE attenuation value    att_port_1=${TL038_att_port_8}      att_port_2=${TL038_att_port_12}
    ...     att_port_3=${TL038_att_port_13}     att_port_4=${TL038_att_port_14}    atten_ip=${atten_ip}
    ...     value_1=${7}    value_2=${7}
    ...     value_3=${4}    value_4=${4}
    sleep    2s
    adjust the HBTE attenuation value    att_port_1=${TL038_att_port_8}      att_port_2=${TL038_att_port_12}
    ...     att_port_3=${TL038_att_port_13}     att_port_4=${TL038_att_port_14}    atten_ip=${atten_ip}
    ...     value_1=${12}    value_2=${12}
    ...     value_3=${2}    value_4=${2}
    sleep    2s
    adjust the HBTE attenuation value    att_port_1=${TL038_att_port_8}      att_port_2=${TL038_att_port_12}
    ...     att_port_3=${TL038_att_port_13}     att_port_4=${TL038_att_port_14}    atten_ip=${atten_ip}
    ...     value_1=${15}    value_2=${15}
    ...     value_3=${0}    value_4=${0}
    sleep    10s

adjust attenuation for gNB_35012 Intra_gNB_HO
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${TL350_att_port_11}      att_port_2=${TL350_att_port_5}
    ...     att_port_3=${TL350_att_port_9}     att_port_4=${TL350_att_port_3}    atten_ip=${atten_ip}
    ...     value_1=${1}    value_2=${1}
    ...     value_3=${20}    value_4=${20}
    sleep    3s
    adjust the HBTE attenuation value    att_port_1=${TL350_att_port_11}      att_port_2=${TL350_att_port_5}
    ...     att_port_3=${TL350_att_port_9}     att_port_4=${TL350_att_port_3}    atten_ip=${atten_ip}
    ...     value_1=${1}    value_2=${1}
    ...     value_3=${10}    value_4=${10}
    sleep    2s
    adjust the HBTE attenuation value    att_port_1=${TL350_att_port_11}      att_port_2=${TL350_att_port_5}
    ...     att_port_3=${TL350_att_port_9}     att_port_4=${TL350_att_port_3}    atten_ip=${atten_ip}
    ...     value_1=${5}    value_2=${5}
    ...     value_3=${2}    value_4=${2}
    sleep    2s
    adjust the HBTE attenuation value    att_port_1=${TL350_att_port_11}      att_port_2=${TL350_att_port_5}
    ...     att_port_3=${TL350_att_port_9}     att_port_4=${TL350_att_port_3}    atten_ip=${atten_ip}
    ...     value_1=${10}    value_2=${10}
    ...     value_3=${0}    value_4=${0}
    sleep    10s


Adjust gNB_RU Attenuation
    [Arguments]    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
    ...    ${gnb2_cell2_value}=${127}    ${enb_cell1_value}=${127}    ${enb_cell2_value}=${127}
    Run Keyword IF    '${gnb_instance}' == '${gnb_id[0]}'    Adjust the tl HBTE attenuation value    tl=${gnb_id[0]}
    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}    gnb2_cell1_value=${gnb2_cell1_value}
    ...    gnb2_cell2_value=${gnb2_cell2_value}    enb_cell1_value=${enb_cell1_value}    enb_cell2_value=${enb_cell2_value}
    ...    ELSE IF    '${gnb_instance}' == '${gnb_id[1]}'    Adjust the tl HBTE attenuation value 341    tl=${gnb_id[1]}
    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}    gnb2_cell1_value=${gnb2_cell1_value}
    ...    gnb2_cell2_value=${gnb2_cell2_value}    enb_cell1_value=${enb_cell1_value}    enb_cell2_value=${enb_cell2_value}
    ...    ELSE    Adjust the tl HBTE attenuation value 242   tl=${gnb_id[2]}
    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}    gnb2_cell1_value=${gnb2_cell1_value}
    ...    gnb2_cell2_value=${gnb2_cell2_value}    enb_cell1_value=${enb_cell1_value}

Adjust the tl HBTE attenuation value
    [Arguments]     ${tl}=34411    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
    ...    ${gnb2_cell2_value}=${127}    ${enb_cell1_value}=${127}    ${enb_cell2_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${${tl}_att_port_1}    ${${tl}_att_port_2}
    @{att_ports_gnb1_cell2}    Create List    ${${tl}_att_port_3}    ${${tl}_att_port_4}
    @{att_ports_gnb2_cell1}    Create List    ${${tl}_att_port_5}    ${${tl}_att_port_6}
    ...    ${${tl}_att_port_7}    ${${tl}_att_port_8}
    @{att_ports_gnb2_cell2}    Create List    ${${tl}_att_port_9}    ${${tl}_att_port_10}
    ...    ${${tl}_att_port_11}    ${${tl}_att_port_12}
    @{att_ports_enb_cell1}    Create List    ${${tl}_att_port_13}
    @{att_ports_enb_cell2}    Create List    ${${tl}_att_port_14}     ${${tl}_att_port_15}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_gnb2_cell2}    Create List    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}
    @{values_enb_cell1}    Create List    ${enb_cell1_value}
    @{values_enb_cell2}    Create List    ${enb_cell2_value}    ${enb_cell2_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell2}    values=${values_gnb2_cell2}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_enb_cell1}    values=${values_enb_cell1}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_enb_cell2}    values=${values_enb_cell2}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}

Adjust the tl HBTE attenuation value 341
    [Arguments]     ${tl}=34111    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
    ...    ${gnb2_cell2_value}=${127}    ${enb_cell1_value}=${127}    ${enb_cell2_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${${tl}_att_port_1}    ${${tl}_att_port_2}
    @{att_ports_gnb1_cell2}    Create List    ${${tl}_att_port_3}    ${${tl}_att_port_4}
    @{att_ports_gnb2_cell1}    Create List    ${${tl}_att_port_5}    ${${tl}_att_port_6}
    @{att_ports_gnb2_cell2}    Create List    ${${tl}_att_port_7}    ${${tl}_att_port_8}
    @{att_ports_enb_cell1}    Create List    ${${tl}_att_port_9}    ${${tl}_att_port_10}
    @{att_ports_enb_cell2}    Create List    ${${tl}_att_port_11}    ${${tl}_att_port_12}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_gnb2_cell2}    Create List    ${gnb2_cell2_value}    ${gnb2_cell2_value}
    @{values_enb_cell1}    Create List    ${enb_cell1_value}    ${enb_cell1_value}
    @{values_enb_cell2}    Create List    ${enb_cell2_value}    ${enb_cell2_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell2}    values=${values_gnb2_cell2}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_enb_cell1}    values=${values_enb_cell1}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_enb_cell2}    values=${values_enb_cell2}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}

Adjust the tl HBTE attenuation value 242
    [Arguments]     ${tl}=24211    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
    ...    ${gnb2_cell2_value}=${127}    ${enb_cell1_value}=${127}    ${enb_cell2_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${${tl}_att_port_4}    ${${tl}_att_port_8}
    @{att_ports_gnb1_cell2}    Create List    ${${tl}_att_port_3}    ${${tl}_att_port_9}
    @{att_ports_gnb2_cell1}    Create List    ${${tl}_att_port_5}    ${${tl}_att_port_7}
    @{att_ports_gnb2_cell2}    Create List    ${${tl}_att_port_1}    ${${tl}_att_port_2}
    @{att_ports_enb_cell1}    Create List    ${${tl}_att_port_6}    ${${tl}_att_port_6}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_gnb2_cell2}    Create List    ${gnb2_cell2_value}    ${gnb2_cell2_value}
    @{values_enb_cell1}    Create List    ${enb_cell1_value}    ${enb_cell1_value}
    @{values_enb_cell2}    Create List    ${enb_cell2_value}    ${enb_cell2_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell2}    values=${values_gnb2_cell2}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_enb_cell1}    values=${values_enb_cell1}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}

UE attach and make calls successful
    Log    \UE attach and make calls successful    console=yes
    Precondition for Sansumg UE    ue_type=huawei    ui_version=${ui_version}    ue_index=${ue_index}
    Attach and check power UE for Sansumg    ue_type=huawei

#Precondition for power UE for Sansumg
#    [Arguments]    ${ue_type}    ${ui_version}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    capatibility_index=${0}    reset_sol=none    detach_request=${true}
#    ...                    ui_version=${ui_version}
#
Attach and check power UE for Sansumg
    [Arguments]    ${ue_type}    ${5Gstatus}=PASS
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    gnb_index=${gnb_index}    ue_index=${ue_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    5Gstatus=${5Gstatus}    gnb_index=${gnb_index}
    ...             ue_index=${ue_index}


Start DL transmission
    log to console    \n *** Start DL transmission
    [Arguments]     ${dl_data_transfer}=${dl_data_transfer}    ${protocol}=udp    ${seg_size}=${seg_size}
    ...     ${window}=${window_size}
    power_ue.Start traffic    ue_type=${ue_type}    direction=${dl_direction}    duration=${DURATION}
    ...    throughput=${dl_data_transfer}     protocol=${protocol}   seg_size=${seg_size}
    ...    window=${window_size}    ue_index=${ue_index}
    sleep    10s

Check counters ${counter_id1} in ${value1} and ${value2} and ${counter_id2} in ${value3} and ${value4}
    Log To Console     Check counters
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}
    ...    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id1}
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${value1}
    should be true   ${values[-1]}<=${value2}
    ${counters2}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id2}
    ${values2}    get dictionary values   ${counters2}
    log  The latest one is: ${values2[-1]}
    should be true   ${values2[-1]}>=${value3}
    should be true   ${values2[-1]}<=${value4}
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    Kill firefox process

adjust the HBTE attenuation value
    [Arguments]     ${value_1}     ${value_2}     ${value_3}     ${value_4}
    ...             ${att_port_1}=${att_port_1}    ${att_port_2}=${att_port_2}     ${att_port_3}=${att_port_3}
    ...             ${att_port_4}=${att_port_4}     ${atten_ip}=${atten_ip}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA value default value[0-63db] if not set the max_attenuation value below
    ...                for value plz set in your case level
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${att_port_1}    value=${value_1}
    attenuator.set_attenuation     port=${att_port_2}    value=${value_2}
    attenuator.set_attenuation     port=${att_port_3}    value=${value_3}
    attenuator.set_attenuation     port=${att_port_4}    value=${value_4}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value_1}
    ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
    should be equal    ${value_port_2}    ${value_2}
    ${value_port_3}    attenuator.read_attenuation    port=${att_port_3}
    should be equal    ${value_port_3}    ${value_3}
    ${value_port_4}    attenuator.read_attenuation    port=${att_port_4}
    should be equal    ${value_port_4}    ${value_4}
    sleep    1s

adjust the HBTE attenuation single port value
    [Arguments]     ${value_1}     ${att_port_1}=${att_port_1}    ${atten_ip}=${tl.attenuator[0].ip_addr}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA value default value[0-63db] if not set the max_attenuation value below
    ...                for value plz set in your case level
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${att_port_1}    value=${value_1}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value_1}
    sleep    1s

Kill firefox process
    ssh.Connect to    ${tl.test_pc.default_ssh_connection_details.addr}
    ...               ${tl.test_pc.default_ssh_connection_details.username}
    ...               ${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    csn.send_command    command=ps -ef | grep firefox | awk '{print $2}' | xargs kill -9    connection=ute
    sleep   2s
    csn.disconnect      connection=ute

Get parameter value
    [Arguments]    ${dis_name}    ${filter_name}
    ${sw_version}    Get sagnb version for selenium
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}    version=${sw_version}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    ${value}=    selenium_coam.get_parameter_value    dist_name=${dis_name}
    ...    filter_param=${filter_name}
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    [return]    ${value}

get nrCellid
    [Arguments]    ${cellid}     ${nrbtsid}=1     ${gnb_index}=${gnb_index}
    ${value}=    Get parameter value    dis_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${nrbtsid}/NRCELL-${cellid}
    ...    filter_name=NR Cell Identity
    [Return]    ${value}

get physCellId
    [Arguments]    ${cellid}     ${nrbtsid}=1     ${gnb_index}=${gnb_index}
    ${value}=    Get parameter value    dis_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${nrbtsid}/NRCELL-${cellid}
    ...    filter_name=Physical cell identifier
    [Return]    ${value}

Check DL TP
    [Arguments]    ${dl_expect_throughput}=${expect_dl_tput}    ${cellid}=${1}    ${gnb_index}=${gnb_index}
    ...    ${duration}=180s
    ${nrcell_id}    get nrCellid    cellid=${cellid}    nrbtsid=${tl.gnbs[${gnb_index}].instance_id}    gnb_index=${gnb_index}
    ${list_of_cell_ids}    Create list    ${nrcell_id}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=${gnb_index}    duration=${duration}
    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${dl_expect_throughput}

Check HO process for intragNB
    [Arguments]    ${log_name}    ${RadioNetwork}=0
    Get gnb Cells ID
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${measurement_filter}    Catenate      x2ap.procedureCode == 35 and nr-rrc.physCellId == ${cell1_physCellId}
    ...               and nr-rrc.physCellId == ${cell2_physCellId}
    ${measurement_packets}    parser.filter_packets_by_expression    filter_expression=${measurement_filter}
    ${target_cell}=     parser.get_field_value_by_xpath    pdml_list=${measurement_packets}
    ...                                                xpath=.//nr-rrc.physCellId
    should not be empty    ${target_cell}
    ${UeModify_req_filter}    Catenate    x2ap.procedureCode == 30 and  nr-rrc.physCellId == ${cell2_physCellId}
    ${UeModify_req_packets}    parser.filter_packets_by_expression    filter_expression=${UeModify_req_filter}
    ${radioNetwork}=    parser.get_field_value_by_xpath    pdml_list=${UeModify_req_packets}
    ...                                                xpath=.// x2ap.radioNetwork
    should be equal    ${radioNetwork}    ${RadioNetwork}
    ${UeModify_res_filter}    Catenate    x2ap.protocolIEs == 3 and x2ap.procedureCode == 30
    ${UeModify_res_packets}    parser.filter_packets_by_expression    filter_expression=${UeModify_res_filter}
    ${UeModify_res}    parser.get_field_value_by_xpath    pdml_list=${UeModify_res_packets}
    ...                                                xpath=.//x2ap.procedureCode
    should be equal    ${UeModify_res[0]}    30

Modify parameters online for cases
    [Arguments]    ${parameters_to_update}    ${download_dir}=${epc_log_path}    ${WEBUI_COAM}=${WEBUI_COAM}
    Log To Console    Modify parameters online for cases
    COAM modify several parameters via webUI   parameters_to_update_via_webui=${parameters_to_update}
    ...    download_dir=${download_dir}    WEBUI_COAM=${WEBUI_COAM}

COAM modify several parameters via webUI
    [Arguments]      ${parameters_to_update_via_webui}    ${download_dir}
    ...       ${WEBUI_COAM}=${WEBUI_COAM}
    ...       ${is_need_to_check_validation_errors}=${False}
    ...       ${is_gnb_restrat_after_online_modify}=${False}
    COAM login page via webUI    download_dir=${download_dir}    WEBUI_COAM=${WEBUI_COAM}
    @{diff_para} =    create list
    FOR    ${cur_para_to_update}    IN    @{parameters_to_update_via_webui}
        ${cur_para_value}    selenium_coam.get_parameter_value
        ...    dist_name=${cur_para_to_update['dist_name']}
        ...    abbr=${cur_para_to_update['abbr']}
        ...    filter_param=${cur_para_to_update['filter_param']}
        Run keyword if    '${cur_para_value}'=='${cur_para_to_update['new_value']}'
        ...    Log to console    current value is ${cur_para_value}, no need to update
        ...    ELSE    run keywords
        ...    selenium_coam.set_parameter_value
        ...    dist_name=${cur_para_to_update['dist_name']}
        ...    abbr=${cur_para_to_update['abbr']}
        ...    filter_param=${cur_para_to_update['filter_param']}
        ...    new_value=${cur_para_to_update['new_value']}    AND
        ...    Append to list    ${diff_para}    ${cur_para_to_update}
    END
    Run keyword if    ${diff_para}    run keywords
    ...    selenium_coam.validate_plan    AND
    ...    COAM check validation errors from webui
    ...    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}    AND
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    AND
    ...    COAM Verify gnb on air after activate plan via webUI    download_dir=${download_dir}
    ...    is_gnb_restrat_after_online_modify=${is_gnb_restrat_after_online_modify}
    [Teardown]    selenium_coam.logout

COAM login page via webUI
    [Arguments]  ${download_dir}=${TS_CASE_LOG_PATH}    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}
    ...                    username=${WEBUI_NAME}
    ...                    password=${WEBUI_PWD}
    ...                    download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.disable_message_box

Start Capture Wireshark Logs on gNB
    [Arguments]     ${nglogname}    ${interface}    ${gnb_index}=${gnb_index}
    gNB connections to ssh    connection=gnb${gnb_index}    gnb_index=${gnb_index}
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}/${nglogname}   connection=gnb${gnb_index}
    sleep    3s
    [Teardown]    csn.disconnect    connection=gnb${gnb_index}

Stop Capture Wireshark Logs on gNB
    [Arguments]    ${nglogname}    ${gnb_index}=${gnb_index}
    gNB connections to ssh    connection=gnb${gnb_index}    gnb_index=${gnb_index}
    sleep    5
    csn.send command    command=killall tcpdump     connection=gnb${gnb_index}
    sleep    3
    csn.download_file   remote_path=${gnb_path}/${nglogname}   local_path=${epc_log_path}${nglogname}   connection=gnb${gnb_index}
    sleep    3
    [Teardown]    csn.disconnect    connection=gnb${gnb_index}

gNB connections to ssh
    [Arguments]    ${connection}    ${gnb_index}=${gnb_index}
    csn.Connect To    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...               username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...               password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...               alias=${connection}

Suite Teardown for COAM
    [Arguments]    ${gnb_index}=${gnb_index}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    username=${WEBUI_NAME}
    ...    password=${WEBUI_PWD}
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

Snapshot Save
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    username=${WEBUI_NAME}
    ...    password=${WEBUI_PWD}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

Start traffic to ENB
    [Arguments]    ${ue_index}=${0}   ${time}=${time}   ${interval}=1    ${traffic}=${ENB_traffic_${gnb_instance}}   ${buffer_size}=1024B
    ...            ${process_num}=${1}    ${traffic_port}=${ENB_traffic_port_${gnb_instance}}
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep   2s
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${traffic_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    csn.send_command
    ...    command=iperf -c ${enb_addr} -u -t ${time} -i ${interval} -p ${traffic_port} -P ${process_num} -f m -b ${traffic} -l ${buffer_size} -T 64&
    ...    connection=EPCAPP
    log to console    .....ENB udp dl iperf start....

Stop traffic to ENB
    [Arguments]    ${ue_index}=${0}    ${DL_port}=${ENB_traffic_port_${gnb_instance}}   ${protocol}=udp
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    [Teardown]    csn.disconnect      connection=EPCAPP

Get the all PM counter value
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    ${counter_value_list}    create list
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
        ...    dic_path=${dic_path[${index}]}    timeout=300
        append to list    ${counter_value_list}    ${counter_value[0]}
    END
    [Return]    ${counter_value_list}

Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

Get average DL through
    [Arguments]    ${gnb_index}=${0}    ${dl_expect_throughput_true}=800    ${duration}=180s
    ${cellid}    Run Keyword IF    '${gnb_instance}' == '${gnb_id[1]}'    Set Variable    ${2}
    ...    ELSE     Set Variable    ${1}
    ${nrcell_id}    get nrCellid    cellid=${cellid}    nrbtsid=${tl.gnbs[${gnb_index}].instance_id}    gnb_index=${gnb_index}
    ${list_of_cell_ids}    Create list    ${nrcell_id}
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=${gnb_index}     duration=${duration}
    ${real_dl_tput}    Run Keyword And Continue On Failure    power_ue_throughput.__Standard Check Aasyslog Throughput
    ...    direction=dl    cells=${list_of_cell_ids}    log=${log}
    ...    target_throughput=${dl_expect_throughput_true}
    ${real_dl_tput}    set variable    ${real_dl_tput[0]['average']}
    Log To Console    \nreal_dl_tput=${real_dl_tput}\n
    [Return]    ${real_dl_tput}


UE attach and check
    Wait until keyword succeeds    3X    10s    Run Keyword IF    '${gnb_instance}' == '${gnb_id[0]}'    Run keywords
    ...    Adjust gNB_RU Attenuation    gnb1_cell1_value=${15}    enb_cell1_value=${0}     AND
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}    AND
    ...    Attach and check power UE    ue_type=${ue_type}    4G_check=true    ue_index=${1}    ELSE IF
    ...    '${gnb_instance}' == '${gnb_id[1]}'    Run keywords
    ...    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}    enb_cell1_value=${5}    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}    AND
    ...    Attach and check power UE    ue_type=${ue_type}    4G_check=true    ue_index=${1}    ELSE    Run keywords
    ...    Adjust gNB_RU Attenuation    gnb1_cell1_value=${16}    enb_cell1_value=${5}    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}    AND
    ...    Attach and check power UE    ue_type=${ue_type}    4G_check=true    ue_index=${1}

Start UDP traffic
    [Arguments]    ${dl_throughput}=${DL_TPUT_Send_A005}    ${time}=${time}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=${time}
    ...    protocol=${protocol_UDP}    ue_index=${1}

Start TCP traffic
    [Arguments]    ${dl_throughput}=${DL_TPUT_Send_A004}    ${time}=${time}    ${ue_index}=${1}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=${time}    protocol=${protocol_TCP}
    ...    process_num=${process_num}    seg_size=${seg_size}    window=${window}    ue_index=${ue_index}

Send traffic to ENB for congest
    [Arguments]    ${ENB_traffic}=${ENB_traffic}    ${ENB_traffic_341}=${ENB_traffic_341}    ${time}=${time}
    Run Keyword IF    '${gnb_instance}' == '${gnb_id[0]}'
    ...    Start traffic to ENB    traffic=${ENB_traffic}    time=${time}    traffic_port=${ENB_traffic_port}
    ...    ELSE    Start traffic to ENB    traffic=${ENB_traffic_341}    time=${time}    traffic_port=${ENB_traffic_port}

Get Active Alarm List
    [Arguments]    ${connection}=default
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    Log To Console    Get Active Alarm List
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}
    ${alarm_info}    coam.get_active_alarms    timeout=60    connection=${connection}
    ${faultid_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${faultid_list}    ${fault_id_dic}
    END
    sort list    ${faultid_list}
    [Return]    ${faultid_list}
    [Teardown]    coam.teardown     connection=${connection}

Get history Alarm List
    [Arguments]    ${connection}=default
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    Log To Console    Get history Alarm List
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}
    ${alarm_info}    coam.get_historic_alarms    timeout=60    connection=${connection}
    ${faultid_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${faultid_list}    ${fault_id_dic}
    END
    sort list    ${faultid_list}
    [Return]    ${faultid_list}
    [Teardown]    coam.teardown     connection=${connection}

UE detach and stop traffic
    Run Keyword IF    '${gnb_instance}' == '${gnb_id[1]}'
    ...    Power UE stop dl traffic and detach    ue_index=${1}
    ...    ELSE    Power UE stop dl traffic and detach    ue_index=${1}

#Get gnb release
#    [Arguments]   ${host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
#    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
#    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
#    gNB connections to ssh    gnb_index=${0}    connection=release_info
#    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
#    ${release_info}    set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
#    [Return]    ${release_info}
#    [Teardown]   csn.Disconnect   connection=release_info

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}
