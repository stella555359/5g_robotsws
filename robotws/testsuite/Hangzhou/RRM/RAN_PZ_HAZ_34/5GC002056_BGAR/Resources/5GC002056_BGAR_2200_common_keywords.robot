*** Settings ***
Documentation
...    author: liujia
...    contact: jia-rebecca.liu@nokia-sbell.com
...    squad group: SG_03
...    feature : 5GC002056_BGAR_2200

Library     OperatingSystem
Library     Collections
Library     String
Library     BuiltIn
Library     DateTime
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.sbts.oam.coam.admin   WITH NAME    wmplte
Library     taf.config.scf    WITH NAME    scf
Library     taf.analyzer.pcap   WITH NAME    cap
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     taf.config.testline    WITH NAME    testline
Library     taf.rfrl.common_resources.python.SWConfig
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002200/Resources/tput_output.py
#Library     taf.hw.mcs    WITH NAME    mcs
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Library     ../../libraries/L3Call.py
Library     ../../libraries/TTI_Trace_Analysis_dl.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/check_csv_log.py
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    ../../libraries/biplog_capture/biplog_capture.robot
Resource    ../../libraries/connection_with_hostname.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Variables    ./Stream_parameter.py
Resource       testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002200/Resources/5GC002200_coam_common_keywords.robot

*** Variables ***
##PATH##
${TS_LOG_PATH_BASE}         /opt/workspace/CRT/Master/Case_Logs
${gnb_path}                 /tmp/
${ttitrace_path}            /ffs/run/config/toor4nsn/eventTrace_log/
${tshark_path}              /usr/bin/tshark
${LUA_SCRIPT_PATH}          /home/nokia/luashark/generated_luashark/luashark.lua
${swconfig}                 /opt/workspace/SCF/swconfig.txt

##GNB##
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${WEBUI_COAM}             https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}             ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}              ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gnb_BTS_host}           ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${gnb_BTS_username}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gnb_BTS_password}       ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asik_addr}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}          ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}          ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${TestPC_addr}            ${tl.test_pc.default_ssh_connection_details.addr}
${TestPC_username}        ${tl.test_pc.default_ssh_connection_details.username}
${TestPC_password}        ${tl.test_pc.default_ssh_connection_details.password}
${gnb_instance}           ${tl.gnbs[0].instance_id}
${enb_instance}                 ${tl.enbs[0].instance_id}
${enb_cell_admin}               administrativeState
${ENB_cell1_dist}               MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${golden_scf_name_Trunk}        MRBTS-10175_TL365_golden_scf.xml
${golden_scf_name_24R2}         MRBTS-11006_TL374_golden_SCF_24R2.xml
${golden_scf_name_22R2}         MRBTS-10318_TL362_golden_scf.xml
${Empty_list}                   'NULL'

##UE##
${dl_throughput}            1600M
${Multi_dl_throughput}      1600Mbits/sec
${DL_TIME}                  9999
${DL_LENGTH}                1024B
${UL_TIME}                  600
${UL_LENGTH}                1024B
${NSA_UE_MODE}          NSA
${SA_UE_MODE}           SA
${NSA_attach_mode}      5G_NSA
${SA_attach_mode}       5G_SA
${NSA_nettype}          NSA
${SA_nettype}           AUTO
${NSA_apn_addr}         dxdata2
${SA_apn_addr}          wap2.nokia.com
${ue_type_1}                ${tl.ues[0].capabilities[1]}
${ue_type_0}                ${tl.ues[0].capabilities[0]}
${SN}                     ${tl.ues[0].serial_number}
${ue_type}                ${tl.ues[0].capabilities[1]}
${UL_PORT}                ${tl.ues[0].iperf_details.ssh_connection_details.port}
${DL_PORT}                ${tl.ues[0].iperf_details.port}
${dl_tput_multiue_365}          850M
${dl_tput_multiue_374}          1350M
# inseego
${CF}                     CONSTRUCTOR_PARAMETERS
${ue_name}                INSEEGO0
${ue_yaml}                ${tl.ues[0]}
${ue_ccc}                 ${ue_yaml['UE_POOLS']['AndroidUePool']['inline_config']['${ue_name}']['${CF}']}
${ue_param}               ${ue_ccc['configuration']}
${askey_SN}               ${ue_ccc['serial_number']}
${askey_hostname}         ${ue_param['ue_pc_ip']}
${askey_username}         ${ue_param['login']}
${askey_password}         ${ue_param['password']}
${iperf_hostname}         ${ue_param['data_transfer']['ssh']['host']}
${iperf_username}         ${ue_param['data_transfer']['ssh']['user']}
${iperf_password}         ${ue_param['data_transfer']['ssh']['password']}
##MCS##
${model}                  ${tl.attenuator[0].model}
${server_port}            ${tl.attenuator[0].port}
${HBTE_ip_370}            ${tl.attenuator[0].ip_addr}
${vendor}                 ${tl.attenuator[0].vendor}

${command_template_Y}       {tshark_path} -r {pcap_file} -Y  \"f1ap\"  -T pdml

*** Keywords ***
##prepare BTS##
Modify NIDD parameter online
    [Arguments]    ${parameters_to_update}
    ...    ${bts_host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections



Prepare testline to cell on air for suite cases
    Case variable set 2056 for 2200_B
    Log to console      load scf and reset bts
    Common Case TestLine Setup    ModifySCF_Beforecommission=True    Is_Swconfig=True     Lock_ENB_Need=True
    ...                                  swconfig_file=${swconfig}    golden_scf_name=${${golden_scf_name}}
    ...                                  swconfig_modify=${swconfig_C007_FLAG}
    ...                                  ParameterToDelete=${${ParameterToDelete}}
    ...                                  ListToAdd=${${ListToAdd}}
    ...                                  ParamterToModify=${${ParamterToModify}}
    ...                                  ListParamterToModify=${${ListParamterToModify}}
    ...                                  enb_dist_name=${ENB_cell1_dist}
    ...                                  enb_parameter=${enb_cell_admin}
    ...                                  enb_value=locked
    run keyword if    '${MRBTS_ID}' == '10318'      Set nrcellid suit varaible    cellid=2
    ...      ELSE                                   Set nrcellid suit varaible    cellid=1


###log capture###
##Wireshark log##
Start To Capture Wireshark Logs
    [Arguments]     ${filename}    ${connection}    ${interface}
    ...    ${asik_addr}=${asik_addr}    ${asik_username}=${asik_username}    ${asik_password}=${asik_password}
    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
    csn.send command    command=tcpdump -i ${interface} -w ${gnb_path}${filename}   connection=${connection}

Stop and download wireshark Logs
    [Arguments]    ${logname}    ${connection}
    ...        ${asik_addr}=${asik_addr}    ${asik_username}=${asik_username}    ${asik_password}=${asik_password}
    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}   connection=${connection}
    sleep    3
    [Teardown]      run keyword and ignore error      Csn.disconnect      connection=${connection}

Check the cell DLUL throughput
    [Arguments]      ${dlexpect}    ${ulexpect}    ${gnb_index}=${0}    ${ue_type}=${ue_type}
    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}
    ...    ue_type=${ue_type}    direction=dl    throughput=${dlexpect}    cellid=${nrcellid}    sleep_time=${20}
    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}
    ...    ue_type=${ue_type}    direction=ul    throughput=${ulexpect}    cellid=${nrcellid}    sleep_time=${20}


MCS SETUP AND SET ATT
    [Arguments]    ${att_value}
    ${mcs_type}=    mcs_common.Get MCS Type
    set suite variable      ${mcs_type}
    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS SETUP AND SET ATT for ONE UE   mcs_type=${mcs_type}
    ...    att_value_1=${att_value}    att_value_2=${att_value}
    ...    P1_out=${13}    P2_out=${14}    vertical_1=${96}    horizontal_1=${20}
    ...    P3_out=${15}    P4_out=${16}    vertical_2=${96}    horizontal_2=${27}
    Run keyword if    '${mcs_type}'=='topyoung'    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
    ...    att_value1=${att_value}    att_value2=${att_value}    vertical_angle=${-6}
    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-6}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${6}
    Run keyword if    '${mcs_type}'=='hbte'    HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
    ...    att_value1=${att_value}    att_value2=${att_value}    vertical_angle=${96}
    ...    first_beam_begin_output_port=${5}     first_beam_end_output_port=${6}     first_beam_horizontal_angle=${-5}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}    second_beam_horizontal_angle=${-15}

Performance Test around
    [Arguments]    ${ATT}    ${dlexpect}    ${csv_path}    ${begin_θ_h}=-60    ${end_θ_h}=55
    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN TEST with one ATT      att=${ATT}    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}
    ...    dlexpect=${dlexpect}    B1_port=${13}    B2_port=${14}    B3_port=${15}    B4_port=${16}    csv_path=${csv_path}
#    Run keyword if    '${mcs_type}'=='topyoung'    TOPYOUNG TEST with one ATT    att=${ATT}    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}
#    ...    dlexpect=${dlexpect}    B1_port=${1}    B2_port=${2}    B3_port=${3}    B4_port=${4}    csv_path=${csv_path}
    Run keyword if    '${mcs_type}'=='hbte'     HBTE TEST with one ATT    att=${ATT}    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}
    ...    dlexpect=${dlexpect}    B1_port=${1}    B2_port=${2}    B3_port=${3}    B4_port=${4}    csv_path=${csv_path}

HAOJIN TEST with one ATT
    [Arguments]     ${att}    ${begin_θ_h}    ${end_θ_h}
    ...    ${B1_port}    ${B2_port}    ${B3_port}    ${B4_port}    ${csv_path}    ${dlexpect}
    ${list}=    create list
    set test variable    ${i}    ${1}
    set test variable    ${list}
    tput_output.create_new_file_csv    csv_file_path=${csv_path}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att}
    ...    begin_output_port=${B1_port}    end_output_port=${B4_port}
    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=att    value2=is    value3=${att}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att}
    ...    begin_output_port=${B1_port}    end_output_port=${B4_port}
    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=att    value2=is    value3=${att}
    Set HAOJIN θ poll for horizontal and Check tput    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    dlexpect=${dlexpect}
    ...    B1_port=${B1_port}    B2_port=${B2_port}    B3_port=${B3_port}    B4_port=${B4_port}    csv_path=${csv_path}


HBTE TEST with one ATT
    [Arguments]     ${att}    ${begin_θ_h}    ${end_θ_h}    ${dlexpect}
    ...    ${B1_port}    ${B2_port}    ${B3_port}    ${B4_port}    ${csv_path}
    ${list}=    create list
    set test variable    ${i}    ${1}
    set test variable    ${list}
    tput_output.create_new_file_csv    csv_file_path=${csv_path}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att}
    ...    begin_output_port=${B1_port}    end_output_port=${B4_port}
    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=att    value2=is    value3=${att}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att}
    ...    begin_output_port=${B1_port}    end_output_port=${B4_port}
    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=att    value2=is    value3=${att}
    Set HBTE θ poll for horizontal and Check tput    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    dlexpect=${dlexpect}
    ...    B1_port=${B1_port}    B2_port=${B2_port}    B3_port=${B3_port}    B4_port=${B4_port}    csv_path=${csv_path}


TOPYOUNG TEST with one ATT
    [Arguments]     ${att}    ${begin_θ_h}    ${end_θ_h}    ${dlexpect}
    ...    ${B1_port}    ${B2_port}    ${B3_port}    ${B4_port}    ${csv_path}
    ${list}=    create list
    set test variable    ${i}    ${1}
    set test variable    ${list}
    tput_output.create_new_file_csv    csv_file_path=${csv_path}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att}
    ...    begin_output_port=${B1_port}    end_output_port=${B4_port}
    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=att    value2=is    value3=${att}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att}
    ...    begin_output_port=${B1_port}    end_output_port=${B4_port}
    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=att    value2=is    value3=${att}
    Set TOPYOUNG θ poll for horizontal and Check tput    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    dlexpect=${dlexpect}
    ...    B1_port=${B1_port}    B2_port=${B2_port}    B3_port=${B3_port}    B4_port=${B4_port}    csv_path=${csv_path}


Set HAOJIN θ poll for horizontal and Check tput
    [Arguments]             ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_θ_h}=${None}    ${end_θ_h}=${None}
    ...    ${B1_port}=${None}    ${B2_port}=${None}    ${B3_port}=${None}    ${B4_port}=${None}
    ...    ${csv_path}=${csv_path}    ${dlexpect}=${Expect_dl_enable}    ${vertical_angle}=${96}
    ...    ${input_group_id}=${0}    ${horizontal_distance}=${0.5}     ${vertical_distance}=${2.1}
    FOR    ${θ_horizontal}    IN RANGE    ${${begin_θ_h}}    ${${end_θ_h}}    5
        haojin.Set Phases According To Angles For Input And Output Groups    begin_output_port=${B1_port}    end_output_port=${B2_port}
        ...    input_group_id=${input_group_id}    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
        ...    vertical_angle=${vertical_angle}    horizontal_angle=${θ_horizontal}    mcs_alias=${mcs_alias}
        ${θ_horizontal_x}    BuiltIn.Evaluate    ${θ_horizontal}+10
        haojin.Set Phases According To Angles For Input And Output Groups    begin_output_port=${B3_port}    end_output_port=${B4_port}
        ...    input_group_id=${input_group_id}    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
        ...    vertical_angle=${vertical_angle}    horizontal_angle=${θ_horizontal_x}    mcs_alias=${mcs_alias}
        sleep    10s
        ${tput}        Check one UE traffic with pioneer client     tput_target=${dlexpect}
        Append To List    ${list}    ${tput}
        tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=${vertical_angle}    value2=${θ_horizontal}    value3=${tput}
        log    ${list}
        ${i}=    BuiltIn.Evaluate    ${i}+1
    END

Set HBTE θ poll for horizontal and Check tput
    [Arguments]             ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_θ_h}=${None}    ${end_θ_h}=${None}
    ...    ${B1_port}=${None}    ${B2_port}=${None}    ${B3_port}=${None}    ${B4_port}=${None}
    ...    ${csv_path}=${csv_path}    ${dlexpect}=${Expect_dl_enable}    ${vertical_angle}=${96}
    ...    ${horizontal_distance}=${0.42}     ${vertical_distance}=${3.36}
    FOR    ${θ_horizontal}    IN RANGE    ${${begin_θ_h}}    ${${end_θ_h}}    5
        hbte.Set Phases According To Angles For Input And Output Groups    mcs_index=${mcs_index}    mcs_alias=${mcs_alias}
        ...    begin_output_port=${B1_port}    end_output_port=${B2_port}
        ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
        ...    vertical_angle=${vertical_angle}    horizontal_angle=${θ_horizontal}
        ${θ_horizontal_x}    BuiltIn.Evaluate    ${θ_horizontal}+10
        hbte.Set Phases According To Angles For Input And Output Groups    mcs_index=${mcs_index}    mcs_alias=${mcs_alias}
        ...    begin_output_port=${B3_port}    end_output_port=${B4_port}
        ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
        ...    vertical_angle=${vertical_angle}    horizontal_angle=${θ_horizontal_x}
        sleep    10s
        ${tput}    Check one UE traffic with pioneer client     tput_target=${dlexpect}
        Append To List    ${list}    ${tput}
        tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=${vertical_angle}    value2=${θ_horizontal}    value3=${tput}
        log    ${list}
        ${i}=    BuiltIn.Evaluate    ${i}+1
    END

Set TOPYOUNG θ poll for horizontal and Check tput
    [Arguments]             ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_θ_h}=${None}    ${end_θ_h}=${None}
    ...    ${B1_port}=${None}    ${B2_port}=${None}    ${B3_port}=${None}    ${B4_port}=${None}
    ...    ${csv_path}=${csv_path}    ${dlexpect}=${Expect_dl_enable}    ${vertical_angle}=${96}
    ...    ${begin_input_port}=${1}    ${end_input_port}=${16}    ${horizontal_distance}=${0.5}     ${vertical_distance}=${3.2}    ${cellid}=${1}
    FOR    ${θ_horizontal}    IN RANGE    ${${begin_θ_h}}    ${${end_θ_h}}    5
        topyoung.Set Phases According To Angles For Input And Output Groups    begin_output_port=${B1_port}    end_output_port=${B2_port}
        ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
        ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
        ...    vertical_angle=${vertical_angle}    horizontal_angle=${θ_horizontal}    mcs_alias=${mcs_alias}
        ${θ_horizontal_x}    BuiltIn.Evaluate    ${θ_horizontal}+10
        topyoung.Set Phases According To Angles For Input And Output Groups    begin_output_port=${B3_port}    end_output_port=${B4_port}
        ...    begin_input_port=${begin_input_port}     end_input_port=${end_input_port}
        ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
        ...    vertical_angle=${vertical_angle}    horizontal_angle=${θ_horizontal_x}    mcs_alias=${mcs_alias}
        sleep    10s
        ${tput}    Power UE check throughput with nrcellid     cellid=${nrcellid}     throughput=${dlexpect}    ue_type=${ue_type_0}
        Append To List    ${list}    ${tput}
        tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=${vertical_angle}    value2=${θ_horizontal}    value3=${tput}
        log    ${list}
        ${i}=    BuiltIn.Evaluate    ${i}+1
    END

Caculate average tput
    [Arguments]    ${csv_path}
    ${count}    BuiltIn.Get Length    ${list}
    ${sum}     set variable    ${0}
    FOR    ${j}    IN RANGE    ${count}
      ${sum}=    BuiltIn.Evaluate    ${sum}+${list[${j}]}
    END
    ${ave}    BuiltIn.Evaluate    round(${sum}/${count},2)
    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=ave_tput    value2=is    value3=${ave}
    Log    average_tput is ${ave}
    Set test variable    ${ave_tput}    ${ave}
    [Return]    ${ave}


##QUALCOMM##
Case variable set 2056 for ${case_key}
    set suite variable     ${TestLine_ID}     BTS_${MRBTS_ID}
    Run Keyword And Ignore Error    set suite variable    ${golden_scf_name}    ${param_store['${case_key}']['${TestLine_ID}']['golden_scf_name']}
    Run Keyword And Ignore Error    set suite variable    ${att_value}          ${param_store['${case_key}']['${TestLine_ID}']['att_value']}
    Run Keyword And Ignore Error    set suite variable    ${typeUE}          ${param_store['${case_key}']['${TestLine_ID}']['typeUE']}
    Run Keyword And Ignore Error    set suite variable    ${Expect_target}      ${param_store['${case_key}']['${TestLine_ID}']['Expect_target']}
    Run Keyword And Ignore Error    set suite variable    ${throughput}      ${param_store['${case_key}']['${TestLine_ID}']['throughput']}
    Run Keyword And Ignore Error    set suite variable    ${Gnb_cell_dist}      ${param_store['${case_key}']['${TestLine_ID}']['Gnb_cell_dist']}
    Run Keyword And Ignore Error    set suite variable    ${ParameterToDelete}
    ...                                                   ${param_store['${case_key}']['${TestLine_ID}']['ParameterToDelete']}
    Run Keyword And Ignore Error    set suite variable    ${ListToAdd}           ${param_store['${case_key}']['${TestLine_ID}']['ListToAdd']}
    Run Keyword And Ignore Error    set suite variable    ${ParamterToModify}    ${param_store['${case_key}']['${TestLine_ID}']['ParamterToModify']}
    Run Keyword And Ignore Error    set suite variable    ${ListParamterToModify}
    ...                                                   ${param_store['${case_key}']['${TestLine_ID}']['ListParamterToModify']}
    Run Keyword And Ignore Error    set suite variable    ${Modify_Para_Online}
    ...                                                   ${param_store['${case_key}']['${TestLine_ID}']['Modify_Para_Online']}
    Run Keyword And Ignore Error    set suite variable    ${counter_dic_path}
    ...                                                   ${param_store['${case_key}']['${TestLine_ID}']['counter_dic_path']}
    Run Keyword And Ignore Error    set suite variable    ${CMlenth}          ${param_store['${case_key}']['${TestLine_ID}']['CMlenth']}
    Run Keyword And Ignore Error    set suite variable    ${dl_tput_multiue}      ${param_store['${case_key}']['${TestLine_ID}']['dl_tput_multiue']}





COAM Get nrcellid with lcrid
    [Arguments]   ${lcrid}    ${gnb_index}=${0}    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    Connect to gnb coam via ssl   bts_host=${bts_host}
    ${cell_info}   coam.get_subcells_info   timeout=20    connection=GNB_OAM
    ${number_of_cell_group_info}    get length    ${cell_info}
    FOR    ${index}    IN RANGE    ${number_of_cell_group_info}
      ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    NRCELLGRP-${index}
      ${nrCellId}    Get nrcellid in all cellgroup with lcrid    cell_from_cellgrp=${cell_from_cellgrp}    lcrid=${lcrid}
      exit for loop if    '${nrCellId}'!='None'
    END
    [Return]    ${nrCellId}
    [Teardown]    COAM Teardown gnb connections

Get nrcellid in all cellgroup with lcrid
    [Arguments]   ${cell_from_cellgrp}    ${lcrid}
    ${cell_list}    Get Dictionary Keys    ${cell_from_cellgrp}
    FOR    ${cell}    IN    @{cell_list}
      ${eachcell}    Get from Dictionary    ${cell_from_cellgrp}    ${cell}
      ${lcrid_get} =    set variable    ${eachcell['NRCELL_L']['parameters']['lcrId']}
      ${nrCellIdentity}     run keyword if     '${lcrid_get}'=='${lcrid}'
      ...    set variable    ${eachcell['NRCELL_L']['parameters']['nrCellIdentity']}
    END
    [Return]    ${nrCellIdentity}

################################
Analysis 2200-C07 log
    [Arguments]    ${file_path}
    ${nrofPorts}=    Get CSIRS_nrofPorts from CPIF    file_path=${file_path}
    should contain x times    ${nrofPorts}    p8    4
    ${cdm_Type}=     Get CSIRS_cdm_Type from CPIF     file_path=${file_path}
    should contain    ${cdm_Type}    2
    ${n1-n2}=        Get CSIRS_n1_n2 from CPIF        file_path=${file_path}
    should contain    ${n1-n2}       1


Check the PM counter shuould not be 0
    [Arguments]    ${counter_id}    ${dic_path}    ${counter_lenth}
    Connect to gnb coam via ssl
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_coam_pmcounter.get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[0]}    timeout=600
        Should be true    ${counter_value[0]} > ${0}
    END
    [Teardown]    COAM Teardown gnb connections

Check the PM counter shuould be 0
    [Arguments]    ${counter_id}    ${dic_path}    ${out_of_beamid}
    Connect to gnb coam via ssl
    FOR    ${index}    IN RANGE    ${out_of_beamid}    64
        ${index_tmp}=    set variable if    ${index}<10    ${0}${index}    ${index}
        ${counter_value} =    get_coam_pmcounter.get_pm_counter_values    counter_id=${counter_id[0]}${index_tmp}    connection=GNB_OAM
         ...    dic_path=${dic_path[0]}    timeout=600
        Should be equal    ${counter_value[0]}    ${0}
    END
    [Teardown]    COAM Teardown gnb connections

Record the counter action timer
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%5
    Run Keyword If    ${utc_min}>3    Record time again
    ${utc_left} =    Evaluate    5-${utc_min}+1
    set test variable    ${utc_left}

Record time again
    sleep    1min
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%5
    Set Suite Variable    ${utc_min}

Tests Recover for 2056
    Run Keyword And Ignore Error     Common Case TestLine Setup     Lock_ENB_Need=True     enb_dist_name=${ENB_cell1_dist}
    ...                                                             enb_parameter=${enb_cell_admin}
    ...                                                             enb_value=unlocked
    Run Keyword And Ignore Error    Run keyword if    '${MRBTS_ID}' == '10318'    Common Case TestLine Setup    ModifySCF_Aftercommission=True
    ...                                                                                                     Modify_Para_Online=${UNLOCK_GNB1_CELL1}
    Run Keyword And Ignore Error    Connect to TestPc    alias=ute
    Run Keyword And Ignore Error    csn.send command
    ...                   command=ps -ef | grep cli |grep ute_common_admin | grep -v grep |awk '{print $2}' |xargs kill -9    connection=ute
    Run Keyword And Ignore Error    UE stop traffic and detach with uetype
    Run Keyword And Ignore Error    MCS Teardown with mcs_type    mcs_type=${mcs_type}
    Run Keyword And Ignore Error    clear cli process
    Run Keyword And Ignore Error    disconect all connections
