*** Settings ***
Documentation
...   author: Wu Pengliang
...   contact: pengliang.wu@nokia-sbell.com

Library     BuiltIn
Library     String
Library     Collections
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/aasyslog.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Library     taf.transport.ssh      WITH NAME    ssh
Library     taf.hw.mcs    WITH NAME    MCS
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CNI_147150/resources/CNI147150_SSB_checking.py
Variables   ./TLConfigration_TL729.py
Library     ./Beam_keyword.py
Library     Beam_keyword.jsonBeamObject    WITH NAME    beamObj
### spark x65 ###
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/sigspark_yiyuan_multiUE.py
Library     sigspark_yiyuan_multiUE.SigSparkMutiUE    WITH NAME    sparkMultiUE_yiyuan
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/aasyslog.robot


*** Variables ***
${5gmax_path}    ${CURDIR}/AQQJ_SSB_Weight_5G_MAX.csv
${RF_calibration_time}    5min
@{ru_list}    1M231703848

*** Keywords ***
######### case common ###########
CNI_147150 common suite setup
    robot_common_operations.Common Suite Setup
    Setup Commission SCF
    Append to list    ${allowed_alarm_list}    ${7311}
    Append to list    ${allowed_alarm_list}    ${7306}
    Run Keyword And Ignore Error    Check GNB on air And alarm    bts_host=${gNB_ip}
    ...    allowed_list=${allowed_alarm_list}    time=15min    interval=60

CNI_147150 common Suit Teardown
    robot_common_operations.Common Suite Teardown

CNI147150 Common Case Setup
    [Arguments]    ${gnb_index}=0    ${fail_with_alarms}=${True}    ${allowed_faults_ids}=7311,7306
    robot_common_operations.Common Case Setup    gnb_index=${gnb_index}
    ...    fail_with_alarms=${fail_with_alarms}    allowed_faults_ids=${allowed_faults_ids}
    Check GNB on air    bts_host=${gNB_ip}

CNI147150 Common Case Teardown
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Run Keyword And Ignore Error    Remove known_host From All VM For TL
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    SISO_common_operation.Capture LMI Log    gnb_index=${0}
    ...    ru_serial_list=${ru_list}
    SISO_common_operation.Common Case Teardown    bts_host=${gNB_ip}
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Setup Commission SCF    timeout=600
    Append to list    ${allowed_alarm_list}    ${7311}
    Append to list    ${allowed_alarm_list}    ${7306}
    Run Keyword And Ignore Error    Check GNB on air And alarm    bts_host=${gNB_ip}
    ...    allowed_list=${allowed_alarm_list}    time=20min    interval=180

Modify Parameter and check beam weight with 5gMax
    [Arguments]    ${beamConfig}=beamSet_2_L10_R45
    ...    ${actDynSsbBeamGen}=${True}    ${actNrLBmMimoRTXPowerSaving}=${False}    ${other_parameter}=${empty_list}
    ...    ${NRCELL_id}=${0}
    Log to console    \n---------------beamconfig: ${beamConfig}, actDynSsbBeamGen:${actDynSsbBeamGen}---------------
    Modify Beam Paramters    beamConfig=${beamConfig}    other_parameter=${other_parameter}
    ...    actDynSsbBeamGen=${actDynSsbBeamGen}    actNrLBmMimoRTXPowerSaving=${actNrLBmMimoRTXPowerSaving}
    ...    NRCELL_id=${NRCELL_id}
    @{beam_split}    split string    string=${beamConfig}    separator=_
    ${basicBeamSet}    set variable    ${beam_split}[${0}]_${beam_split}[${1}]
    ${jsonPath}    Download Dynamic Beam Set Weight From BTS    basicBeamSet=${basicBeamSet}    NRCELL_id=${NRCELL_id}
    ...    actDynSsbBeamGen=${actDynSsbBeamGen}
    Run Keyword And Continue On Failure    Get BeamWeight value and check with 5gMax    jsonPath=${jsonPath}
    ...    actDynSsbBeamGen=${actDynSsbBeamGen}    actNrLBmMimoRTXPowerSaving=${actNrLBmMimoRTXPowerSaving}

Modify Parameter and check beam weight with 5gMax and ssb index check in UE log
    [Arguments]    ${beamConfig}=beamSet_2_L40_R45
    ...    ${mcs_index}=${0}    ${mcs_ue_port_name}=UE0    ${matrix_id}=${1}    ${Att_value}=15
    ...    ${actDynSsbBeamGen}=${True}    ${actNrLBmMimoRTXPowerSaving}=${False}    ${other_parameter}=${empty_list}
    ...    ${spark_ue_alias}=spark_UE    ${if_dl}=${True}    ${if_ul}=${True}
    ...    ${NRCELL_id}=${0}
    Modify Parameter and check beam weight with 5gMax    beamConfig=${beamConfig}    actDynSsbBeamGen=${actDynSsbBeamGen}
    ...    actNrLBmMimoRTXPowerSaving=${actNrLBmMimoRTXPowerSaving}    other_parameter=${other_parameter}    NRCELL_id=${NRCELL_id}
    ${leftEdgeAngle}    ${rightEdgeAngle}    get_beam_angle_from_beamConfig    beamConfig=${beamConfig}
    Log to console    sleep ${RF_calibration_time}, wait for RF calibration_time
    sleep    ${RF_calibration_time}
    Topyong MCS setup    mcs_index=${mcs_index}
    ### init mcs set ###
    Set Topyong MCS Phases And Att by Matrix
        ...    ue_port_name=${mcs_ue_port_name}    matrix_id=${matrix_id}    H_angle=${rightEdgeAngle}    V_angle=${-1}
        ...    att_value=${Att_value}    mcs_device=MCS_${mcs_index}    att_enable=${true}
    ##################
    Prepare MultiUE And Attach    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}    get_spark_license=${True}
    ...    ue_alias=${spark_ue_alias}
    MultiUE Start Traffic    DL_Enable=${if_dl}    UL_Enable=${if_ul}
    sleep    3s
    ${AnglesDict}    beamObj.genneraterSsbAngle    beamConfig=${beamConfig}
    Log to console    genetared ssb dict: ${AnglesDict}
    ${AnglesList}    set variable    ${AnglesDict['${beamConfig}']}
    FOR    ${angle}    IN    @{AnglesList}
        ${H_angle}    set variable    ${angle['h_angle']}
        ${V_angle}    set variable    ${angle['v_angle']}
        ${expected_ssb}    set variable    ${angle['expected_ssb']}
        Set Topyong MCS Phases And Att by Matrix
        ...    ue_port_name=${mcs_ue_port_name}    matrix_id=${matrix_id}    H_angle=${H_angle}    V_angle=${V_angle}
        ...    att_value=${Att_value}    mcs_device=MCS_${mcs_index}    att_enable=${true}
        sleep    5s
        sparkMultiUE_yiyuan.start_log    ue_alias=${spark_ue_alias}
        sleep    3s
        Run Keyword And Continue On Failure    Capture AaSysLog And Check AoA angle
        ...    beamConfig=${beamConfig}    H_angle=${H_angle}    V_angle=${V_angle}
        sleep    10s
        sparkMultiUE_yiyuan.stop_log    ue_alias=${spark_ue_alias}
        ${output_folder}    Spark Export Log to CSV    log_prefix=${beamConfig}
        ${csv_data}    getDataFromSparkCsvLog    csvPath=${output_folder}UE-1.csv    beamConfig=${beamConfig}
        ...    actDynSsbBeamGen=${actDynSsbBeamGen}    h_angle=${H_angle}    v_angle=${V_angle}
        ueDataSaveToNewCsv    output_filename=${ue_data_csv}    data=${csv_data}
    END
    MultiUE Stop Traffic    DL_Enable=${if_dl}    UL_Enable=${if_ul}
    MultiUE Detach
    ${checkUeDataResult}    checkSparkUeDataSsbIndex    csvPath=${ue_data_csv}    expectedSsbDict=${AnglesDict}
    log to console    ${checkUeDataResult}[${1}]
    Should be true    ${checkUeDataResult}[${0}]
    [Teardown]    Run Keyword And Ignore Error    X65 UE And MCS Teardown

get_beam_angle_from_beamConfig
    [Arguments]    ${beamConfig}
    @{beam_split}    split string    string=${beamConfig}    separator=_
    ${leftEdgeAngle_str}    replace string    ${beam_split}[${2}]    L    ${Empty}
    ${rightEdgeAngle_str}    replace string    ${beam_split}[${3}]    R    ${Empty}
    ${leftEdgeAngle}    Evaluate    -int(${leftEdgeAngle_str})
    ${rightEdgeAngle}    Evaluate    int(${rightEdgeAngle_str})
    [Return]    ${leftEdgeAngle}    ${rightEdgeAngle}

Download Dynamic Beam Set Weight From BTS
    [Arguments]    ${NRCELL_id}    ${basicBeamSet}    ${connection}=GNB_SSH    ${actDynSsbBeamGen}=${True}
    ${cellid}    Get nrCellIdentity via NRCELL id    NRCELL_id=${NRCELL_id}
    ${filename}    Set Variable    CP_${basicBeamSet}_${TL_NRBTS_ID}_${cellid}.json
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    ssh.Connect to    hostname=${gNB_ip}    username=${gNB_ssh_username}   password=${gNB_ssh_password}    alias=${connection}
    sleep    1s
    ${log_time}    DateTime.Get Current Date    result_format=%Y_%m_%d_%H_%M_%S
    ${local_path}    set variable    ${OUTPUT_DIR}/${TEST NAME}/[${actDynSsbBeamGen}]_${log_time}_${filename}
    ssh.download_file    remote_path=/ffs/run/config/AQQJ-476383A/${filename}
    ...    local_path=${local_path}    connection=${connection}
    sleep    1s
    Log To Console    Download Beam Weight from /ffs/run/config/AQQJ-476383A/${filename} to ${local_path}
    [Return]    ${local_path}
    [Teardown]    ssh.disconnect    connection=${connection}

Get BeamWeight value and check with 5gMax
    [Arguments]     ${jsonPath}    ${actDynSsbBeamGen}=${True}    ${actNrLBmMimoRTXPowerSaving}=${True}
    Log to console    \nget beamweight from JSON and compare with 5gmax
    ${checkResult}    beamObj.checkJsonFile    jsonPath=${jsonPath}
    ...    actDynSsbBeamGen=${actDynSsbBeamGen}
    ...    actNrLBmMimoRTXPowerSaving=${actNrLBmMimoRTXPowerSaving}
    ...    csv5gMaxPath=${5gmax_path}
    ${result}    Evaluate    pprint.pformat(${checkResult}[${1}])
    Log To Console    ${result}
    Should be true    ${checkResult}[${0}]    msg=check json failed, pls check!!!
    [Return]    ${checkResult}[${2}]

###########  bip ###############
Common Capture BIP log and download
    [Arguments]    ${target_dir}=${OUTPUT_DIR}/${TEST NAME}    ${duration}=1s    ${target_file_name}=l1l2bip_log
    ...    ${interface}=L1-L2    ${destination}=Local    ${nr_phy_cell_ids}=${None}
    Log To Console    \nstart capture bip log
    Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}    nr_phy_cell_ids=${nr_phy_cell_ids}
    ...    gnb_index=${0}    timeout=900    interface=${interface}    destination=${destination}
    ...    host_ip=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    sleep    ${duration}
    ${full_log_path}    Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}
    ...    pattern=*.pcap    target_dir=${target_dir}
    Log to console    \nbip saved:\n${full_log_path}
    [Return]    ${full_log_path}

Covert bip pcap to json
    [Arguments]    ${pcap_log_path}    ${bip_filename}    ${filter}=\"dldata_pdschsendreql1sw && !(3gpp.rnti == 65535)\"
    ${output_filename}    set variable    ${OUTPUT_DIR}/${TEST NAME}/${bip_filename}/${bip_filename}.json
    Set Test Variable    ${command}    tshark -V -r ${pcap_log_path} -Y ${filter} -T json > ${output_filename}
    Run    ${command}
    [Return]    ${output_filename}

#########  common  ##############
X65 UE And MCS Teardown
    [Arguments]    ${mcs_index}=${0}    ${ue_alias}=spark_UE
    MCS.teardown    mcs_device=MCS_${mcs_index}
    X65 UE Teardown    ue_alias=${ue_alias}

X65 UE Teardown
    [Arguments]    ${ue_alias}=spark_UE
    sparkMultiUE_yiyuan.stop_log    ue_alias=${ue_alias}
    MultiUE Stop Traffic
    MultiUE Detach

##########  spark X65  ###########
Prepare MultiUE And Attach
    [Arguments]    ${multiue_config_direction}    ${ue_alias}=spark_UE    ${restart_ue}=${False}    ${restart_network}=${False}
    ...    ${get_spark_license}=${False}    ${max_ue_num}=${1}    ${if_require_ue}=${True}
    Run Keyword if    ${if_require_ue}    Prepare MultiUE    multiue_config_direction=${multiue_config_direction}    ue_alias=${ue_alias}
    ...    restart_ue=${restart_ue}    restart_network=${restart_network}
    ...    get_spark_license=${get_spark_license}    max_ue_num=${max_ue_num}
    log to console      "UE Attach"
    sparkMultiUE_yiyuan.attach_ue    ue_alias=${ue_alias}

Prepare MultiUE
    [Arguments]    ${multiue_config_direction}    ${ue_alias}=spark_UE    ${restart_ue}=${False}    ${restart_network}=${False}
    ...    ${get_spark_license}=${False}    ${max_ue_num}=${1}
    ${ue_index_list}    set variable    ${multiue_config_direction['ue_index_for_call']}
    ${max_ue_num}    Get Length    ${ue_index_list}
    log to console      "Prepare UE"
    Run Keyword And Ignore Error    sparkMultiUE_yiyuan.require_ue    ue_alias=${ue_alias}    multiue_traffic_config=${multiue_config_direction}
    ...    restart_ue=${restart_ue}    restart_network=${restart_network}    get_spark_license=${get_spark_license}
    ...    max_ue_num=${max_ue_num}

MultiUE Start Traffic
    [Arguments]    ${UL_Enable}=${True}    ${DL_Enable}=${True}    ${ue_alias}=spark_UE
    run keyword if    ${UL_Enable}    log to console      "UE Start UL Traffic"
    run keyword if    ${UL_Enable}    sparkMultiUE_yiyuan.start_data_transfer    ue_alias=${ue_alias}    direction=ul
    run keyword if    ${DL_Enable}    log to console      "UE Start DL Traffic"
    run keyword if    ${DL_Enable}    sparkMultiUE_yiyuan.start_data_transfer    ue_alias=${ue_alias}    direction=dl

MultiUE Stop Traffic
    [Arguments]    ${UL_Enable}=${True}    ${DL_Enable}=${True}    ${ue_alias}=spark_UE
    run keyword if    ${UL_Enable}    log to console      "UE Stop UL Traffic"
    run keyword if    ${UL_Enable}    sparkMultiUE_yiyuan.stop_data_transfer    ue_alias=${ue_alias}    direction=ul
    run keyword if    ${DL_Enable}    log to console      "UE Stop DL Traffic"
    run keyword if    ${DL_Enable}    sparkMultiUE_yiyuan.stop_data_transfer    ue_alias=${ue_alias}    direction=dl

MultiUE Detach
    [Arguments]  ${ue_alias}=spark_UE
    log to console      "UE Detach"
    sparkMultiUE_yiyuan.detach_ue    ue_alias=${ue_alias}

Spark Export Log to CSV
    [Arguments]    ${ue_alias}=spark_UE    ${log_prefix}=${Empty}    ${filter}=CNI_147150
    ${time_stamp}    DateTime.get current date    result_format=%H_%M_%S
    ${output_folder}    set variable    ${OUTPUT_DIR}/${TEST NAME}/${log_prefix}_${time_stamp}/
    Create Directory    ${output_folder}
    Log to console    start to export log to csv...
    sparkMultiUE_yiyuan.export_log_file    ue_alias=${ue_alias}     logpath=${output_folder}    filter=${filter}
    Log to console    log saved in: ${output_folder}
    [Return]    ${output_folder}


#########  mcs  ##############
Topyong MCS setup
    [Arguments]    ${mcs_index}=${0}    ${set_default_att}=${True}    ${default_att}=${90}
    ${output}    run keyword    MCS.setup    mcs_index=${mcs_index}
    ...                                      alias=MCS_${mcs_index}
    ...                                      server_ip=${tl.attenuator[${mcs_index}].ip_addr}
    ...                                      server_port=${tl.attenuator[${mcs_index}].port}
    ...                                      vendor=${tl.attenuator[${mcs_index}].vendor}
    ...                                      model=${tl.attenuator[${mcs_index}].model}
    ${FREQ}    set variable    ${matrix_mapping_config['FREQ']}
#    MCS.set_frequency    frequency=${FREQ}    mcs_device=MCS_${mcs_index}
    ${matrix_ids}	get dictionary keys    ${matrix_mapping_config['matrix_mapping']}
    ${matrix_num}    get length    ${matrix_ids}
    MCS.set_matrix_number    number=${matrix_num}    mcs_device=MCS_${mcs_index}
    ${matrix_positions}    create dictionary
    FOR    ${matrix_id}    IN    @{matrix_ids}
        ${h_distance}    set variable    ${matrix_mapping_config['matrix_mapping'][${matrix_id}]['Radio_D']['horizontal']}
        ${v_distance}    set variable    ${matrix_mapping_config['matrix_mapping'][${matrix_id}]['Radio_D']['vertical']}
        ${matrix_position}    set variable    ${matrix_mapping_config['matrix_mapping'][${matrix_id}]['position_mapping']}
        set to dictionary    ${matrix_positions}    ${matrix_id}    ${matrix_position}
        MCS.set_aedis     matrix_id=${matrix_id}    horizontal_d_value=${h_distance}    vertical_d_value=${v_distance}
        ...    mcs_device=MCS_${mcs_index}
    END
    MCS.set_position    matrix_positions=${matrix_positions}    mcs_device=MCS_${mcs_index}
    Run keyword if    ${set_default_att}    Set Topyong MCS Phases And Att by Matrix
    ...    ue_port_name=All    matrix_id=${1}    att_value=${default_att}
    Run keyword if    ${set_default_att}    Set Topyong MCS Phases And Att by Matrix
    ...    ue_port_name=All    matrix_id=${2}    att_value=${default_att}
    [Return]    MCS_${mcs_index}

Set Topyong MCS Phases And Att by Matrix
    [Arguments]    ${ue_port_name}    ${matrix_id}    ${mcs_device}=MCS_0    ${H_angle}=${0}    ${V_angle}=${0}
    ...    ${att_enable}=${True}    ${att_value}=${15}
    ${UE_Ports}    set variable    ${matrix_mapping_config['UE_mapping_B_Port']['${ue_port_name}']}
    FOR    ${B_value}    IN    @{UE_Ports}
        ${is_odd}     set variable    ${B_value}%2==1
        ${is_even}    set variable    ${B_value}%2==0
        ${odd_result}    Run keyword if    ${is_odd}    MCS.set_beam    port=B${B_value}    matrix_id=${matrix_id}    mcs_device=${mcs_device}
        ...    horizontal_beam_angle=${H_angle}    vertical_beam_angle=${V_angle}
        ...    even_attenuation_enable=${att_enable}    odd_attenuation_enable=${att_enable}
        ...    event_attenuation_value=${90}       odd_attenuation_value=${att_value}
        Run keyword if    ${is_odd}    Should Be True    ${odd_result}    msg=Pls make sure MCS has been disconnected in local
        ${even_result}    Run keyword if    ${is_even}    MCS.set_beam    port=B${B_value}    matrix_id=${matrix_id}    mcs_device=${mcs_device}
        ...    horizontal_beam_angle=${H_angle}    vertical_beam_angle=${V_angle}
        ...    even_attenuation_enable=${att_enable}              odd_attenuation_enable=${att_enable}
        ...    event_attenuation_value=${att_value}    odd_attenuation_value=${90}
        Run keyword if    ${is_even}    Should Be True    ${even_result}    msg=Pls make sure MCS has been disconnected in local
    END

Set Topyong MCS Att Only by Matrix
    [Arguments]    ${ue_port_name}=UE0    ${matrix_id}=${1}    ${mcs_device}=MCS_0
    ...    ${even_attenuation_enable}=${True}    ${event_attenuation_value}=${90}
    ...    ${odd_attenuation_enable}=${True}    ${odd_attenuation_value}=${90}
    ${UE_Ports}    set variable    ${matrix_mapping_config['UE_mapping_B_Port']['${ue_port_name}']}
    ${begin_input_port_str}    set variable    ${matrix_mapping_config['matrix_mapping'][${matrix_id}]['position_mapping'][${0}][${0}]}
    ${end_input_port_str}    set variable    ${matrix_mapping_config['matrix_mapping'][${matrix_id}]['position_mapping'][${-1}][${0}]}
    ${begin_input_port}    String.Replace String    ${begin_input_port_str}    A    ${Empty}
    ${end_input_port}    String.Replace String    ${end_input_port_str}    A    ${Empty}
    FOR    ${B_value}    IN    @{UE_Ports}
        ${is_odd}     set variable    ${B_value}%2==1
        ${is_even}    set variable    ${B_value}%2==0
        Run keyword if    ${odd_attenuation_enable} and ${is_odd}    MCS.set_odd_attenuations    attenuation=${odd_attenuation_value}
        ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
        ...    output_port=${B_value}    mcs_device=${mcs_device}
        Run keyword if    ${odd_attenuation_enable} and ${is_odd}    MCS.set_even_attenuations    attenuation=${90}
        ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
        ...    output_port=${B_value}    mcs_device=${mcs_device}
        Run keyword if    ${even_attenuation_enable} and ${is_even}    MCS.set_even_attenuations    attenuation=${event_attenuation_value}
        ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
        ...    output_port=${B_value}    mcs_device=${mcs_device}
        Run keyword if    ${even_attenuation_enable} and ${is_even}    MCS.set_odd_attenuations    attenuation=${90}
        ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
        ...    output_port=${B_value}    mcs_device=${mcs_device}
    END

#########  coam  ###########
Modify Beam Paramters
    [Arguments]    ${actDynSsbBeamGen}=${True}    ${actNrLBmMimoRTXPowerSaving}=${True}    ${other_parameter}=${empty_list}
    ...    ${NRCELL_id}=${0}    ${beamConfig}=beamSet_2_L10_R10    ${nrBtsBeamRefinementP2}=false    ${beamsMuted}=0
    ${NRCELL_DN}    set variable    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
    ${NRCELLGRP_id}    Get NRCELLGRP id via NRCELL id    NRCELL_id=${NRCELL_id}
    ${NRCELLGRP_DN}    set variable    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELLGRP-${NRCELLGRP_id}
    ${NRBTS_DN}    set variable    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}
    ${release}    Get BTS Release Name
    ${input_list}    updateParemeterList    other_parameter=${other_parameter}    beamConfig=${beamConfig}
    ...    NRCELL_DN=${NRCELL_DN}    NRCELLGRP_DN=${NRCELLGRP_DN}    NRBTS_DN=${NRBTS_DN}    release=${release}
    ...    actDynSsbBeamGen=${actDynSsbBeamGen}    actNrLBmMimoRTXPowerSaving=${actNrLBmMimoRTXPowerSaving}
    ...    nrBtsBeamRefinementP2=${nrBtsBeamRefinementP2}    beamsMuted=${beamsMuted}
    Log To Console    "\n recomission with ${input_list} \n"
    Modify Parameters With Json    input_list=${input_list}    connection=beam_para_change
    Check GNB on air    time=5min

Get BTS Release Name
    [Arguments]    ${bts_host}=${gnb_ip}    ${connection}=GNB_build
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    separator=_
    [Return]    ${version_list[0]}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

Get NRBEAM_EMF infomation
    [Arguments]    ${bts_host}=${gnb_ip}    ${NRCELL_id}=${0}    ${connection}=GNB_EMF
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${NRCELL_DN}    set variable    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
    ${parameter_info}    coam.get_parameter_by_parent_distname    parent_dn=${NRCELL_DN}    child_class_name=NRBEAM_EMF
    ...    connection=${connection}
    ${result}    Evaluate    pprint.pformat(${parameter_info})
    Log To Console    "\n NRBEAM_EMF infor: ${result} \n"
    [Return]    ${parameter_info}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

Modify parameters and Get NRBEAM_EMF information
    [Arguments]    ${beamConfig}=beamSet_4_L60_R60    ${actDynSsbBeamGen}=${True}    ${NRCELL_id}=${0}
    ...    ${other_parameter}=${empty_list}
    Modify Beam Paramters    beamConfig=${beamConfig}    other_parameter=${other_parameter}
    ...    actDynSsbBeamGen=${actDynSsbBeamGen}    actNrLBmMimoRTXPowerSaving=${False}
    ...    NRCELL_id=${NRCELL_id}
    @{beam_split}    split string    string=${beamConfig}    separator=_
    ${basicBeamSet}    set variable    ${beam_split}[${0}]_${beam_split}[${1}]
    ${jsonPath}    Run keyword if    ${actDynSsbBeamGen}    Download Dynamic Beam Set Weight From BTS
    ...    basicBeamSet=${basicBeamSet}    NRCELL_id=${NRCELL_id}    actDynSsbBeamGen=${actDynSsbBeamGen}
    ${patternIdAndSsbMapDict}    Run keyword if    ${actDynSsbBeamGen}    Get BeamWeight value and check with 5gMax    jsonPath=${jsonPath}
    ...    actDynSsbBeamGen=${actDynSsbBeamGen}    actNrLBmMimoRTXPowerSaving=${False}
    Run keyword if    ${actDynSsbBeamGen}    Log to console    ${patternIdAndSsbMapDict}
    ${emf_info}     Get NRBEAM_EMF infomation    NRCELL_id=${NRCELL_id}
    emfInfoToCsv    output_filename=${emf_data_csv}
    ...    beamEmf=${emf_info}     note=${beamConfig}_actDynSsbBeamGen:${actDynSsbBeamGen}
    ...    patternIdAndSsbMapDict=${patternIdAndSsbMapDict}

Get NRCELLGRP id via NRCELL id
    [Arguments]    ${bts_host}=${gnb_ip}    ${NRCELL_id}=${0}    ${connection}=GNB_GRP
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${bts_parameter_info}    coam.get_bts_info    connection=${connection}
    FOR    ${GRP}    IN    @{bts_parameter_info['cellsGroup']}
        ${grp_name}    set variable    ${GRP['name']}
        ${nrcellList}    set variable    ${GRP['nrCellList']}
        ${ifCellInGrp}    Evaluate    'NRCELL-${NRCELL_id}' in ${nrcellList}
        Exit For Loop If    ${ifCellInGrp}
    END
    ${grp_id}    Fetch from right    ${grp_name}    marker=-
    log to console    Find NRCELL-${NRCELL_id}'s cell group id is: ${grp_id}
    [Return]    ${grp_id}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

Get nrCellIdentity via NRCELL id
    [Arguments]    ${bts_host}=${gnb_ip}    ${NRCELL_id}=${0}    ${connection}=GNB_CELL
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${parameter_list}    Create List    nrCellIdentity
    ${NRCELL_DN}    set variable    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
    ${cell_parameter_info}    coam.get_parameter_by_class    class_name=NRCELL    parameter_list=${parameter_list}    connection=${connection}
    FOR    ${cell}    IN    @{cell_parameter_info}
        ${dist_name}    set variable    ${cell['distName']}
        ${cell_id}    set variable    ${cell['parameters']['nrCellIdentity']}
        Exit For Loop If    '${NRCELL_DN}'=='${dist_name}'
    END
    log to console    Find ${NRCELL_DN}'s cellid is: ${cell_id}
    [Return]    ${cell_id}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

Update NRPGRP
    [Arguments]    ${PARA_PGRP}=${PARA_PowerSving}    ${lbpsDuration}=60
    ${hour}    ${minute}    ${weekday}    getFiveMinuteAgoTimeInfo
    Log to console    Time: (${hour}:${minute}, weekday:${weekday})
    ${PARA_PowerSving0}    set variable    ${PARA_PGRP}[${0}]
    ${lbpsPeriodParaList}    set variable    ${PARA_PowerSving0['value']}
    ${lbpsPeriodParaDict}    set variable    ${lbpsPeriodParaList}[${0}]
    set to dictionary    ${lbpsPeriodParaDict}
    ...    lbpsDayOfWeek=${weekday}
    ...    lbpsStartTimeHour=${hour}
    ...    lbpsStartTimeMinute=${minute}
    ...    lbpsDuration=${lbpsDuration}
    Set list value    ${lbpsPeriodParaList}    0    ${lbpsPeriodParaDict}
    Set to dictionary    ${PARA_PowerSving0}    value=${lbpsPeriodParaList}
    Set List value    ${PARA_PGRP}    0    ${PARA_PowerSving0}
    [Return]    ${PARA_PGRP}

Get BTS Counter For EMF And EIRP
    [Arguments]    ${NRCELL_ID}=NRCELL-0   ${connection}=GNB_OAM
    @{counter_name_list}    Create List    NCELA    NCELA    NREIRP    NREIRP
    ${counter_ids}    Set Variable    M55308C00044,M55308C00045,M55324C00301,M55324C00302
    ${counter_id_list}    Split String    ${counter_ids}    separator=,
    @{counter_value_list}    Create list
    ${counter_len}    Get Length    ${counter_id_list}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${counter_value}    coam.get_PM_counters    counter_ids=${counter_ids}    connection=${connection}
    FOR  ${item}  IN RANGE    0    ${counter_len}
        ${counter_id}    Set Variable    ${counter_id_list[${item}]}
        ${counter_name}    Set Variable    ${counter_name_list[${item}]}
        ${result}    Set Variable
        ...    ${counter_value['BTS']['MRBTS-${TL_BTS_ID}']['NRBTS-${TL_NRBTS_ID}']['${NRCELL_ID}']['${counter_name}']['${counter_id}']}
        Append To List    ${counter_value_list}    ${result}
    END
    [Return]    ${counter_value_list}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

EMF Counter Should Updated And EIRP Not Updated
    [Arguments]    ${counter_value_list}
    ${counter_key}    Get Dictionary Keys    ${counter_value_list[0]}
    ${latest_key}    Set Variable    ${counter_key[-1]}
    Run Keyword If    ${counter_value_list[0]['${latest_key}']} == 0  Log To Console    EMF counter not updated, contionue to check...
    Should Be True    ${counter_value_list[0]['${latest_key}']} > 0
    Should Be True    ${counter_value_list[1]['${latest_key}']} > 0
    Should Be True    ${counter_value_list[2]['${latest_key}']} == 0
    Should Be True    ${counter_value_list[3]['${latest_key}']} == 0
    Log To Console    EMF counter >0 and EIRP counter ==0 check pass !

NRBEAM EMF Infor Should Be As Expected
    [Arguments]    ${emf_info_list}    ${expected_emf_num}    ${dynSSB}=true
    ${emf_num}    Get Length    ${emf_info_list}
    Should Be Equal As Numbers    ${emf_num}    ${expected_emf_num}
    Log To Console    NRBEAM EMF number is ${emf_num} check pass !
    FOR  ${emf_info}  IN  @{emf_info_list}
        Exit For Loop If    '${dynSSB}' == 'false'
        ${distName}    Set Variable    ${emf_info['distName']}
        ${beamType}    Set Variable    ${emf_info['parameters']['beamType']}
        ${beamId}    Set Variable    ${emf_info['parameters']['beamPatternId']}
        ${gainConfDirection}    Set Variable    ${emf_info['parameters']['gainConfDirection']}
        #gain:[8.33 dBi], direction:{azimuth[1 Deg], elevation[1 Deg]}
        Should Be Equal As Strings     ${beamType}   Dynamic SSB/refined beam    ignore_case=${True}
        Should Be True    ${beamId} > 1024
        Should Contain    ${gainConfDirection}    azimuth[1 Deg]
        Should Contain    ${gainConfDirection}    elevation[1 Deg]
        Log To Console     ${distName} beamType is Dynamic SSB/refined beam check pass !
        Log To Console     ${beamId} > 1024 check pass !
        Log To Console    ${gainConfDirection} with 1 Deg check pass !
    END

Both EMF and EIRP Counter Should Be Updated
    [Arguments]    ${counter_value_list}
    ${counter_key}    Get Dictionary Keys    ${counter_value_list[0]}
    ${latest_key}    Set Variable    ${counter_key[-1]}

    # Check EMF counters both updated
    Should Be True    ${counter_value_list[0]['${latest_key}']} > 0
    Should Be True    ${counter_value_list[1]['${latest_key}']} > 0

    # Check EIRP counters and fail if both are not updated
    ${eirp1}    Set Variable    ${counter_value_list[2]['${latest_key}']}
    ${eirp2}    Set Variable    ${counter_value_list[3]['${latest_key}']}
    Run Keyword If    ${eirp1} <= 0 and ${eirp2} <= 0    Fail    Both EIRP counters are not updated!

    Log To Console    EMF counter ${counter_value_list[0]['${latest_key}']} ${counter_value_list[1]['${latest_key}']} >0 check pass !
    Log To Console    EIRP counter ${eirp1} ${eirp2} >0 check pass !

Both EMF and EIRP Counter Should Be 0
    [Arguments]    ${counter_value_list}
    ${counter_key}    Get Dictionary Keys    ${counter_value_list[0]}
    ${latest_key}    Set Variable    ${counter_key[-1]}
    Run Keyword If    ${counter_value_list[0]['${latest_key}']} > 0    Log To Console    wait 30s and contioune to check if counter update !
    Should Be True    ${counter_value_list[0]['${latest_key}']} == 0
    Should Be True    ${counter_value_list[1]['${latest_key}']} == 0
    Should Be True    ${counter_value_list[2]['${latest_key}']} == 0
    Should Be True    ${counter_value_list[3]['${latest_key}']} == 0
    Log To Console    EMF counter ${counter_value_list[0]['${latest_key}']} ${counter_value_list[1]['${latest_key}']} ==0 check pass !
    Log To Console    EIRP counter ${counter_value_list[2]['${latest_key}']} ${counter_value_list[3]['${latest_key}']} ==0 check pass !

Legacy and DynSSB EMF Beam Num And Gain Should Be Same
    [Arguments]    ${legacy_emf_lst}    ${dynssb_emf_lst}
    ${emf_num}    Get Length    ${legacy_emf_lst}
    @{beam_id_dynssb_lst}    Create List
    @{beam_id_legacy_lst}    Create List
    FOR  ${idx}   IN RANGE  ${emf_num}
        ${distName_legacy}    Set Variable    ${legacy_emf_lst[${idx}]['distName']}
        ${beamType_legacy}    Set Variable    ${legacy_emf_lst[${idx}]['parameters']['beamType']}
        ${beamId_legacy}    Set Variable    ${legacy_emf_lst[${idx}]['parameters']['beamPatternId']}
        ${gainConfDirection_legacy}    Set Variable    ${legacy_emf_lst[${idx}]['parameters']['gainConfDirection']}
        ${maxGainAndDirection_legacy}    Set Variable    ${legacy_emf_lst[${idx}]['parameters']['maxGainAndDirection']}
        ${minGainAndDirection_legacy}    Set Variable    ${legacy_emf_lst[${idx}]['parameters']['minGainAndDirection']}
        Append To List    ${beam_id_legacy_lst}    ${beamId_legacy}

        ${distName_dynssb}    Set Variable    ${dynssb_emf_lst[${idx}]['distName']}
        ${beamType_dynssb}    Set Variable    ${dynssb_emf_lst[${idx}]['parameters']['beamType']}
        ${beamId_dynssb}    Set Variable    ${dynssb_emf_lst[${idx}]['parameters']['beamPatternId']}
        ${gainConfDirection_dynssb}    Set Variable    ${dynssb_emf_lst[${idx}]['parameters']['gainConfDirection']}
        ${maxGainAndDirection_dynssb}    Set Variable    ${dynssb_emf_lst[${idx}]['parameters']['maxGainAndDirection']}
        ${minGainAndDirection_dynssb}    Set Variable    ${dynssb_emf_lst[${idx}]['parameters']['minGainAndDirection']}
        Append To List    ${beam_id_dynssb_lst}    ${beamId_dynssb}

        Should Be Equal As Strings     ${beamType_dynssb}   Dynamic SSB/refined beam    ignore_case=${True}
        Should Be Equal As Strings     ${beamType_legacy}   Predefined beam    ignore_case=${True}
        Should Be True    ${beamId_dynssb} > 1024
        Should Be True    ${beamId_legacy} < 1024

        ${legacy_num_lst}    Extract Numbers From Brackets    text=${gainConfDirection_legacy}
        ${dyn_num_lst}    Extract Numbers From Brackets    text=${gainConfDirection_dynssb}
        ${gain_gap}    Evaluate    ${legacy_num_lst[0]} - ${dyn_num_lst[0]}
        Should Be True    ${gain_gap} < 1
        Should Be Equal As Strings    ${legacy_num_lst[1]}    ${dyn_num_lst[1]}
        Should Be Equal As Strings    ${legacy_num_lst[2]}    ${dyn_num_lst[2]}

        ${legacy_num_lst}    Extract Numbers From Brackets    text=${maxGainAndDirection_legacy}
        ${dyn_num_lst}    Extract Numbers From Brackets    text=${maxGainAndDirection_dynssb}
        ${gain_gap}    Evaluate    ${legacy_num_lst[0]} - ${dyn_num_lst[0]}
        Should Be True    ${gain_gap} < 1
        Should Be Equal As Strings    ${legacy_num_lst[1]}    ${dyn_num_lst[1]}
        Should Be Equal As Strings    ${legacy_num_lst[2]}    ${dyn_num_lst[2]}

        ${legacy_num_lst}    Extract Numbers From Brackets    text=${minGainAndDirection_legacy}
        ${dyn_num_lst}    Extract Numbers From Brackets    text=${minGainAndDirection_dynssb}
        ${gain_gap}    Evaluate    ${legacy_num_lst[0]} - ${dyn_num_lst[0]}
        Should Be Equal As Strings    ${legacy_num_lst[1]}    ${dyn_num_lst[1]}
        Should Be Equal As Strings    ${legacy_num_lst[2]}    ${dyn_num_lst[2]}
    END
    # check SSB beam index should be increase by 5
    ${dynssb_idx_interval}    Evaluate    ${beam_id_dynssb_lst[1]} - ${beam_id_dynssb_lst[0]}
    ${legacy_idx_interval}    Evaluate    ${beam_id_legacy_lst[1]} - ${beam_id_legacy_lst[0]}
    Should Be Equal As Integers    ${dynssb_idx_interval}    ${legacy_idx_interval}
#    Run Keyword If    ${dynssb_idx_interval} != 5 and ${dynssb_idx_interval} != -5    Fail    Pattern ID check failed !

Extract Numbers From Brackets
    [Arguments]    ${text}
    #r'\[\s*(-?\d+(?:\.\d+)?)'
    ${matches}=    Get Regexp Matches    ${text}    (-?\\d+(?:\\.\\d+)?)
    [Return]    ${matches}

Check BTS PowerSaving Status
    [Arguments]    ${bts_host}=${gnb_ip}    ${NRCELL_id}=${0}    ${connection}=GNB_PWS_CELL    ${expected_status}=reducedEnergySaving
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${parameter_list}    Create List    energySavingState
    ${NRCELL_DN}    set variable    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
    ${cell_parameter_info}    coam.get_parameter_by_class    class_name=NRCELL    parameter_list=${parameter_list}    connection=${connection}
    FOR    ${cell}    IN    @{cell_parameter_info}
        ${dist_name}    set variable    ${cell['distName']}
        ${energySavingState}    set variable    ${cell['parameters']['energySavingState']}
        Exit For Loop If    '${NRCELL_DN}'=='${dist_name}'
    END
    log to console    Find ${NRCELL_DN}'s energySavingState is: ${energySavingState}
    Should be true    '${energySavingState}'=='${expected_status}'
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

Set MCS by value and UE L3 call
    [Arguments]    ${mcs_set_list}    ${beamConfig}=beamSet_2_L40_R45
    ...    ${mcs_index}=${0}    ${matrix_id}=${1}    ${Att_value}=15    ${log_time}=30s
    ...    ${spark_ue_alias}=spark_UE    ${if_dl}=${False}    ${if_ul}=${False}    ${ue_config}=${TLCommonConfig["MultiUECFG"]}
    @{beam_split}    split string    string=${beamConfig}    separator=_
    ${basicBeamSet}    set variable    ${beam_split}[${0}]_${beam_split}[${1}]
    ${leftEdgeAngle}    ${rightEdgeAngle}    get_beam_angle_from_beamConfig    beamConfig=${beamConfig}
    Topyong MCS setup    mcs_index=${mcs_index}
    FOR    ${angle}    IN    @{mcs_set_list}
        ${mcs_port}    set variable    ${angle['mcs_port']}
        ${H_angle}    set variable    ${angle['H_angle']}
        ${V_angle}    set variable    ${angle['V_angle']}
        Set Topyong MCS Phases And Att by Matrix
        ...    ue_port_name=${mcs_port}    matrix_id=${matrix_id}    H_angle=${H_angle}    V_angle=${V_angle}
        ...    att_value=${att_value}
    END
    ${log_list}    X65 L3 call and traffic    if_dl=${if_dl}    if_ul=${if_ul}    spark_ue_alias=${spark_ue_alias}
    ...    ue_config=${ue_config}    beamConfig=${beamConfig}    log_time=${log_time}
    [Return]    ${log_list}
    [Teardown]    Run Keyword And Ignore Error    MCS.teardown    mcs_device=MCS_${mcs_index}

X65 L3 call and traffic
    [Arguments]    ${beamConfig}    ${ue_config}=${TLCommonConfig["MultiUECFG"]}    ${log_time}=30s
    ...    ${spark_ue_alias}=spark_UE    ${if_dl}=${False}    ${if_ul}=${False}    ${if_require_ue}=${True}
    Prepare MultiUE And Attach    multiue_config_direction=${ue_config}    get_spark_license=${True}
    ...    ue_alias=${spark_ue_alias}    if_require_ue=${if_require_ue}
    MultiUE Start Traffic    DL_Enable=${if_dl}    UL_Enable=${if_ul}
    sleep    3s
    sparkMultiUE_yiyuan.start_log    ue_alias=${spark_ue_alias}
    sleep    ${log_time}
    sparkMultiUE_yiyuan.stop_log    ue_alias=${spark_ue_alias}
    MultiUE Stop Traffic    DL_Enable=${if_dl}    UL_Enable=${if_ul}
    MultiUE Detach
    ${output_folder}    Spark Export Log to CSV    log_prefix=${beamConfig}
    ${ue_index_list}    set variable    ${ue_config['ue_index_for_call']}
    ${max_ue_num}    Get Length    ${ue_index_list}
    ${log_list}    Create List
    FOR    ${ue_index}    IN RANGE    ${max_ue_num}
        ${ue_num}    Evaluate    ${ue_index}+${1}
        log to console    UE data saved in: ${output_folder}UE-${ue_num}.csv
        Append To List    ${log_list}    ${output_folder}UE-${ue_num}.csv
    END
    [Return]    ${log_list}
    [Teardown]    Run Keyword And Ignore Error    X65 UE Teardown    ue_alias=${spark_ue_alias}

Check UE RANK impacted by PowerSaving
    [Arguments]    ${ue_log_list}
    FOR    ${log}    IN    @{ue_log_list}
        ${result}    checkUeDlRank    csvPath=${log}
        log to console    check: ${log}, rank result: ${result}
        Run Keyword And Continue On Failure    Should be True    ${result}
    END

Check UE Tput with MUMIMO
    [Arguments]    ${ue_log_list}    ${if_dl}=${False}    ${if_ul}=${False}
    ...    ${expected_dl_tput}=1400    ${expected_ul_tput}=150
    FOR    ${log}    IN    @{ue_log_list}
        ${result}    checkUeTputData    csvPath=${log}    if_dl=${if_dl}    if_ul=${if_ul}
        ...    expected_dl_tput=${expected_dl_tput}    expected_ul_tput=${expected_ul_tput}
        log to console    check: ${log}, tput result: ${result}
        Run Keyword And Continue On Failure    Should be True    ${result}    msg=tput check failed
    END

Change The parameter of UE
    [Arguments]    ${new_ue_dict}    ${org_UE_dict}=${TLCommonConfig['MultiUECFG']}
    ${ue_index_list}    get dictionary keys    ${new_ue_dict}
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${new_value_dict}    get from dictionary    ${new_ue_dict}    ${ue_index}
        ${org_dict}    Change Dictionary Value    new_value_dict=${new_value_dict}    org_dict=${org_UE_dict['${ue_index}']}
        set to dictionary    ${org_UE_dict}    ${ue_index}=${org_dict}
    END
    set to dictionary    ${org_UE_dict}    ue_index_for_call=${ue_index_list}
    [Return]    ${org_UE_dict}

Change Dictionary Value
    [Arguments]    ${new_value_dict}    ${org_dict}
    ${new_keys}    get dictionary keys    ${new_value_dict}
    FOR  ${key}  IN  @{new_keys}
        ${value}    get from dictionary    ${new_value_dict}    ${key}
        set to dictionary    ${org_dict}    ${key}=${value}
    END
    [Return]    ${org_dict}

Recovery Non Beamset1 Configuration
    [Arguments]    ${NRCELL_id}=${0}
    ${dlmimoMode}    Get DlMimoMode value
    ${is_8x4}    Evaluate    '8x4 Closed' in '${dlmimoMode}'
    ${other_parameter1}    Combine Lists    ${PARA_SRS_True}    ${PARA_Not_Beamset1}
    ${other_parameter2}    Combine Lists    ${PARA_SRS_True}    ${PARA_Not_Beamset1}    ${PARA_PMI_True}
    ${other_parameter}    Set variable if    ${is_8x4}    ${other_parameter1}    ${other_parameter2}
    Modify Beam Paramters    actDynSsbBeamGen=${True}   actNrLBmMimoRTXPowerSaving=${True}
    ...    NRCELL_id=${NRCELL_id}    beamConfig=beamSet_4_L20_R50    other_parameter=${other_parameter}

Get DlMimoMode value
    [Arguments]    ${bts_host}=${gnb_ip}    ${NRCELL_id}=${0}    ${connection}=GNB_GRP
    ${parameter_list}    Create List    dlMimoMode
    ${NRCELL_DN}    set variable    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${NRCELL_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${cell_parameter_info}    coam.get_parameter_by_class    class_name=NRCELL    parameter_list=${parameter_list}    connection=${connection}
    FOR    ${cell}    IN    @{cell_parameter_info}
        ${dist_name}    set variable    ${cell['distName']}
        ${dlMimoMode}    set variable    ${cell['parameters']['dlMimoMode']}
        Exit For Loop If    '${NRCELL_DN}'=='${dist_name}'
    END
    log to console    Find NRCELL-${NRCELL_id}'s cell dlMimoMode is: ${dlMimoMode}
    [Return]    ${dlMimoMode}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

Enable PMI AND SRS Beam
    [Arguments]    ${NRCELL_id}=${0}    ${bts_host}=${gnb_ip}
    ${dlmimoMode}    Get DlMimoMode value    NRCELL_id=${NRCELL_id}    bts_host=${bts_host}
    ${is_8x4}    Evaluate    '8x4 Closed' in '${dlmimoMode}'
    Run keyword if    not ${is_8x4}    Modify Parameters With Json    input_list=${PARA_PMI_AND_SRS_True}    connection=pmi_change
    ...    ELSE    Log to console    PMI already enabled
    Check GNB on air    time=5min

Remove known_host From All VM For TL
    ${vm_list}    Create List
    FOR    ${ru}    IN    @{ALL_RU_LIST}
        ${ru_sn}    set variable    ${ru['ru_serial']}
        ${vm_host}    set variable    ${ru['test_pc_addr']}
        ${username}    set variable    ${ru['test_pc_username']}
        ${password}    set variable    ${ru['test_pc_password']}
        ${if_vm_exists}    Evaluate    '${vm_host}' in ${vm_list}
        Run keyword if     not ${if_vm_exists}    Append to list    ${vm_list}    ${vm_host}
        Run keyword if     not ${if_vm_exists}    Remove known_host From VM    vm_host=${vm_host}
        ...    username=${username}    password=${password}
    END

Remove known_host From VM
    [Arguments]    ${vm_host}    ${username}    ${password}    ${connection}=ssh_vm
    Log to console    remove known_host in VM: ${vm_host}
    Run Keyword And Ignore Error    csn.Connect to    hostname=${vm_host}
    ...    username=${username}    password=${password}    alias=${connection}
    Run Keyword And Ignore Error    csn.send_command    command=rm /home/ute/.ssh/known_hosts    connection=${connection}
    Run Keyword And Ignore Error    csn.send_command    command=rm /home/ute/.ssh/authorized_keys    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=${connection}

Trigger AoA From LMF
    [Arguments]    ${ue_index}=${0}    ${lmf_ip}=10.68.81.137
    Log to console    Trigger LCS from LMF
    ${ue_sn}    set variable    ${tl.ues[${ue_index}].imsi}
    ${lcs_trigger_file}    Set Variable    ${CURDIR}/AoA_trigger.xml
    update_imsi_in_xml    file_path=${lcs_trigger_file}     new_imsi=${ue_sn}
    ${cmd}    Set Variable    curl -v http://${lmf_ip}:9210 -d @${lcs_trigger_file}
    ${result}    run    ${cmd}
    Log To Console    ${result}

Capture AaSysLog And Check AoA angle
    [Arguments]    ${beamConfig}=beamSet_6_L45_R50    ${H_angle}=${20}    ${V_angle}=${-7}    ${gap}=${2}
    ${log_name}    set variable    ${beamConfig}_${H_angle}_${V_angle}.txt
    Start aasyslog capture    log_name=${log_name}    filter=lcsAzimuthAoa
    Trigger AoA From LMF
    sleep    3s
    Teardown aasyslog with log downloaded to ute    gnb_log_path=/tmp/${log_name}    ute_log_folder=${OUTPUT_DIR}/${TEST NAME}/
    ${lcsAzimuthAoa}    ${lcsZentithAoa}    Get AoA angle from AaSyslog    log_name=${log_name}
    ${Azimuth_diff}    Evaluate    ${lcsAzimuthAoa}-${H_angle}
    ${Zentith_diff}    Evaluate    (${90}-${lcsZentithAoa})-${V_angle}
    Run Keyword And Continue On Failure    Should be true    ${Azimuth_diff}<${gap}
    ...    msg=Check lcsAzimuthAoa failed, MCS_H_angle is ${H_angle}, syslog:${lcsAzimuthAoa}
    Run Keyword And Continue On Failure    Should be true    ${Zentith_diff}<${gap}
    ...    msg=Check lcsZentithAoa failed, MCS_H_angle is ${V_angle}, syslog:${lcsZentithAoa}
    [Teardown]    Run keyword and ignore error    Teardown the Aasyslog save progress

Get AoA angle from AaSyslog
    [Arguments]    ${ute_log_folder}=${OUTPUT_DIR}/${TEST NAME}/    ${log_name}=beamSet_6_L45_R50_20_-7.txt
    ${log_content}    Get File    ${ute_log_folder}/${log_name}
    ${aoa_pattern}    Set Variable    lcsAzimuthAoa:\\s*([-+]?\\d*\\.?\\d+), lcsZentithAoa:\\s*([-+]?\\d*\\.?\\d+)
    ${aoa_matches}    Get Regexp Matches    ${log_content}    ${aoa_pattern}
    ${angle_str}    split string    string=${aoa_matches}[0]    separator=,
    ${lcsAzimuthAoa}    String.Fetch From Right    ${angle_str}[0]    marker=:
    ${lcsZentithAoa}    String.Fetch From Right    ${angle_str}[1]    marker=:
    Log to console    Got LCS value: (${lcsAzimuthAoa}, ${lcsZentithAoa})
    [Return]    ${lcsAzimuthAoa}    ${lcsZentithAoa}
