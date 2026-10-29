*** Settings ***
Documentation
...    author: zhenzhen.guo
...    contact:zhenzhen.guo@nokia-sbell.com
...    squad group: RAN_PZ_HAZ3_SG03
...    feature : CB008392
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#Library     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/compare_alarm_list.py
Library     taf.hw.rf_attenuator    WITH NAME    att
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/RRH_common_keyword.robot

Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007108/Resources/CB007108_variables.py

*** Variables ***
${ue_type}    ${tl.ues[-1].capabilities[-1]}
${ute_host}    ${tl.test_pc.default_ssh_connection_details.addr}
${ute_user}    ${tl.test_pc.default_ssh_connection_details.username}
${ute_password}    ${tl.test_pc.default_ssh_connection_details.password}
${asik_addr}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${att_ipaddr}               ${tl.attenuator.ip_addr}
${att_port_number}         ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_0}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_1}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_2}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_3}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${att_port_4}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[4].port_no}
${att_port_5}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[5].port_no}
${att_port_6}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[6].port_no}
${att_port_7}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[7].port_no}
${att_port_8}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[8].port_no}
${att_port_9}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[9].port_no}
${att_port_10}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[10].port_no}
${att_port_11}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[11].port_no}
${att_api_port}             ${tl.attenuator.port}
${vendor}                   HBTE
${HBTE_max_value}           ${127}    ##no sig
${scf_path}                 ${commissionings_path}/HGZ/${testline_name}
${8T8R_scf_name}       SCF_8T8R_SBTS00.xml
${nonBF_scf_name}           SCF_nonBF_SBTS00.xml


*** Keywords ***
Check If there is new alarm
    Log To Console    Check If there is new alarm
    #Selenium Login And Disable Screen Lock    download_dir=/tmp    version=${version}
    @{alarm_info}=    Wait Until Keyword Succeeds    5min    10s    selenium_coam.get_active_alarm_info    timeout=100
    ${alarm_numbler}=        Get Length    ${alarm_info}
    run keyword and ignore error    should be true    ${alarm_numbler} == 4
    #sleep    5s
    #${alarm_info_history}=    coam.get_historic_alarms    timeout=60    connection=GNB_OAM
    ${is_4282_active}    Check If there is 4282
    #[Teardown]    Selenium Logout And Close Browser

Block dedicated cell
    log to console    block dedicated cell
	[Arguments]    ${cell_id}=1
    coam.block_cell    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}    connection=GNB_OAM

Unblock dedicated cell
    log to console    unbock dedicated cell
    [Arguments]    ${cell_id}=1
    coam.unblock_cell    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}    connection=GNB_OAM

Start traffic and check UE DL and UL TP seperately
    log to console    \nStart traffic and check UE DL and UL TP seperately
    [Arguments]    ${expect_dl_tp}=1300    ${expect_ul_tp}=60    ${dl_traffic}=1500M    ${ul_traffic}=90M
    UE start traffic   tp_direction=dl   ul_tp=0    dl_tp=${dl_traffic}
    sleep    10s
    UE check throughput by syslog    tp_direction=dl    exp_ul_tp=0    exp_dl_tp=${expect_dl_tp}    check_times=60
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    UE start traffic   tp_direction=ul   ul_tp=${ul_traffic}    dl_tp=0
    sleep    10s
    UE check throughput by syslog    tp_direction=ul    exp_ul_tp=${expect_ul_tp}    exp_dl_tp=0    check_times=60s
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}

Check UE TP
    log to console    \nCheck UE TP
    [Arguments]    ${tp_direction}=both    ${expect_dl_tp}=1300    ${expect_ul_tp}=60
    Run keyword and continue on failure    UE check throughput by syslog    tp_direction=${tp_direction}
    ...   exp_ul_tp=${expect_ul_tp}    exp_dl_tp=${expect_dl_tp}

UE check throughput by syslog
    [Arguments]    ${tp_direction}=both    ${exp_ul_tp}=100    ${exp_dl_tp}=100    ${check_times}=60s
    log to console    UE check throughput by syslog
    AAsys log captrue    stop_aasys_flag=${False}
    sleep    ${check_times}
    ${all_tp}    Get ul and dl peak and ave throughput and return result    aasys_start_flag=${False}
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...      should be true    ${all_tp[1]}>${exp_dl_tp}
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...     should be true    ${all_tp[4]}>${exp_ul_tp}
    Set Suite Variable    ${all_tp}

Get ul and dl peak and ave throughput and return result
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}
    ...    du_index=${du_index}
    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log for TRUNK
    ...    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb
    ...    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb
    ...    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}
    ...    ${ul_average_tp}    ${ul_minimum_tp}
    [teardown]    Run Keyword and Ignore Error    admin_cli.teardown    connection=COAM

UE stop traffic
    [Arguments]    ${tp_direction}=both
    log to console    UE stop traffic
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Stop traffic
	...    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic
	...    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}

UE Prepare
    Log To Console    \n ### Prepare UE ###
    #power_ue.Prepare UE    ue_index=${0}    ue_type=${UE_TYPE}    reset_sol=ue_reboot
	power_ue.Prepare UE    ue_type=${UE_TYPE}

Attach UE
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

UE Prepare and UE attach
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_index=${0}    ue_type=${UE_TYPE}        reset_sol=ue_reboot
	sleep    40s
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

UE start traffic
    [Arguments]    ${tp_direction}=both    ${ul_tp}=100M    ${dl_tp}=100M
    log to console    UE start traffic
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${dl_tp}   duration=900000    ue_type=${ue_type}    buffer_size=1400B
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${ul_tp}    duration=900000    ue_type=${ue_type}    iperf_type=via_command


Suite Teardown
    [Arguments]    ${gnb_index}=0
    log to console    \n***SISO Coam Suite Teardown***
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
	Check If there is new alarm
	Selenium Logout And Close Browser
	run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True
    csn.Connect to    hostname=${ute_host}    username=${ute_user}    password=${ute_password}    alias=ute
	csn.execute    command=rm -rf /tmp/*.log    connection=ute
	csn.execute    command=rm -rf /tmp/*.html    connection=ute
	#csn.execute    command=rm -rf /tmp/*    connection=ute
    csn.Disconnect     connection=ute



Detach UE for case finished
    Log To Console    \n ### UE Detach ###
    Run Keyword And Ignore Error    UE stop traffic
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

Modify parameter administrativeState
    log to console    Modify parameter administrativeState
	[Arguments]    ${cell_id}=1    ${value}=Shutting Down
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    parameter=actGrflShdn
    ...    value=true
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    parameter=administrativeState
    ...    value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM

Adjust HBTE ATT Values seperate
    [Arguments]      ${attenuation_values_of_all_ports}
    log to console    Adjust HBTE ATT Value
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}   max_attenuation=${HBTE_max_value}    vendor=${vendor}
    FOR  ${port_num}    IN RANGE    0    4
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END
    FOR  ${port_num}    IN RANGE    8    12
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END


Adjust HBTE ATT Values
    [Arguments]      ${attenuation_values_of_all_ports}
    log to console    Adjust HBTE ATT Value
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}   max_attenuation=${HBTE_max_value}    vendor=${vendor}
    FOR  ${port_num}    IN RANGE    0    8
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END


Make one cell fail or recovery cell
    [Arguments]    ${cell_id}=1    ${gscn_value}=1
    log to console    \nMake one cell fail or recovery cell
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    parameter=gscnOrSsPbchArfcn
    ...    value=${gscn_value}
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM

Scf xml modify
    [Arguments]      ${scf_file_path}    ${parameters_to_update_xml}
    log to console    Scf xml modify
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${scf_dir_path}    String.Replace string    ${scf_file_path}    /${scf_file_name}    ${EMPTY}
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${scf_file_name_after_modify}    catenate  SEPARATOR=${EMPTY}    ${file_name_without_extention}
    ...    _${timestamp}_updated.xml
    ${modified_scf_file_path}    set variable    ${scf_dir_path}/${scf_file_name_after_modify}
    scf.Load Scf    ${scf_file_path}
    FOR  ${modify_para}  IN  @{parameters_to_update_xml}
      run keyword if    '${modify_para['operate']}'=='update'    scf.modify_scf_element
      ...    value=${modify_para['new_value']}    dist_name=${modify_para['dist_name']}
      ...    p_name=${modify_para['p_name']}
      run keyword if    '${modify_para['operate']}'=='delete'    scf.remove_mo_with_descendant_mos
      ...    dist_name=${modify_para['dist_name']}
      run keyword if    '${modify_para['operate']}'=='add_mo'    scf.add_object_to_scf
      ...    class_name=${modify_para['class_name']}    dist_name=${modify_para['dist_name']}
      ...    version=${modify_para['version']}
    END
    scf.save_scf    ${modified_scf_file_path}
    [Return]  ${modified_scf_file_path}

Scf commition and wair for on-air
    [Arguments]    ${scf_name}    ${is_pdl_checking_needed}=${True}    ${timeout}=600
    log to console    Scf commition and wair for on-air
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_name}    timeout=${timeout}
	...    is_pdl_checking_needed=${is_pdl_checking_needed}    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master

Delete ALD Infomation If Exist
    [Arguments]    ${scf_file_path}
    log to console    Delete ALD Infomation If Exist
    ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${SAVE LOG DIRECTORY}/ALD_delete/
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${scf_name_for_update}    catenate    SEPARATOR=${EMPTY}    ${file_name_without_extention}
    ...    _ALD_delete.xml
    ${scf_file_update_path}    set variable    ${SAVE LOG DIRECTORY}/ALD_delete/${scf_name_for_update}
    scf.Load scf    ${default_scf_file_path}
    FOR    ${item}    IN    @{ALD_MOS_PARAMS_TO_ADD}
        ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
        run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    scf.Save scf    ${scf_file_update_path}
    [Return]    ${scf_file_update_path}

Wait until ALD AND RETU status normal
    [Arguments]    ${timeout}=${5} min   ${download_dir}=/tmp    ${retu_index}=1    ${ald_index}=1    ${ald_type}=RETU
    log to console    Wait until ALD AND RETU status normal
    Wait Until Keyword Succeeds   ${timeout}  30 sec    CB007108_common_keywords.Check RETU Status
	...    type=ALD    retu_index=${retu_index}    ald_index=${ald_index}
    Wait Until Keyword Succeeds   ${timeout}  30 sec    CB007108_common_keywords.Check RETU Status
    ...    type=${ald_type}    retu_index=${retu_index}    ald_index=${ald_index}

Set dcVoltageEnabled value for RSL
    [Arguments]    ${dcVoltageEnabled}
    log to console    \nSet dcVoltageEnabled value to ${dcVoltageEnabled} for RSL
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/RSL-1
    ...    parameter=dcVoltageEnabled
    ...    value=${dcVoltageEnabled}
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM

Set hdlcCommunicationAllowed value for RSL
    [Arguments]    ${hdlcCommunicationAllowed}
    log to console    \nSet hdlcCommunicationAllowed value to ${hdlcCommunicationAllowed} for RSL
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/RSL-1
    ...    parameter=hdlcCommunicationAllowed
    ...    value=${hdlcCommunicationAllowed}
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM

Set dcVoltage value for ANTL1
    [Arguments]    ${dcVoltage}
    log to console    \nSet dcVoltage value to ${dcVoltage}  for ANTL1
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/ANTL-1
    ...    parameter=dcVoltage
    ...    value=${dcVoltage}
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM

Set hdlcCommunicationAllowed value for ANTL1
    [Arguments]    ${hdlcCommunicationAllowed}
    log to console    \nSet hdlcCommunicationAllowed value to ${hdlcCommunicationAllowed} for ANTL1
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/ANTL-1
    ...    parameter=hdlcCommunicationAllowed
    ...    value=${hdlcCommunicationAllowed}
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM

recovery 4141 and 4142 for RSL
    log to console    \nrecovery 4141 and 4142 for RSL
    Set dcVoltageEnabled value for RSL    dcVoltageEnabled=true
    Set hdlcCommunicationAllowed value for RSL    hdlcCommunicationAllowed=true

recovery 4141 and 4142 for ANT1
    log to console    \nrecovery 4141 and 4142 for ANT1
    Set dcVoltage value for ANTL1    dcVoltage=AUTO
    Set hdlcCommunicationAllowed value for ANTL1    hdlcCommunicationAllowed=true

Expect Fault Should Present
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=COAM    ${severity}=${None}    ${alarmId}=${None}
    log to console    \nExpect Fault ${faultId} Should Present
    ${faultId}    Convert To Integer    ${faultId}
    @{alarms}    coam.get_active_alarms    connection=${connection}
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR    ${alarm}    IN    @{alarms}
        Exit For Loop If    ${alarm_num}==${0}
        ${present_status}    Run Keyword And Return Status    Run Keywords
        ...                  Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
        ...                  Run Keyword If    '${source}'!='${None}'
        ...                  Should Contain    ${alarm['notifier']}    ${source}    case_insensitive=True    AND
        ...                  Run Keyword If    '${severity}'!='${None}'
        ...                  Should Contain    ${alarm['severity']}    ${severity}    case_insensitive=True    AND
        ...                  Run Keyword If    '${alarmId}'!='${None}'
        ...                  Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}
        Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.


Calibrate RETU via WebEM
    [Arguments]    ${retu_index}=1    ${ald_index}=1    ${download_dir}=/tmp
    Log to console    Info: ready to Calibrate RETU
    #Selenium Login And Disable Screen Lock    download_dir=/tmp    version=${version}
    selenium_coam.calibrate_retu    retu_index=${retu_index}    ald_index=${ald_index}
    #Wait until keyword succeeds    10s    1s    Check RETU Status    administrative_state=Unlocked    availability_status=-
    #...    operational_state=enabled    procedural_status=initializing    Usage state=Busy
    #[Teardown]    Selenium Logout And Close Browser

Check RETU Status
    [Arguments]    ${administrative_state}=Unlocked
    ...    ${availability_status}=-
    ...    ${operational_state}=enabled
    ...    ${procedural_status}=-
    ...    ${Usage state}=Idle
    ...    ${retu_index}=1
	...    ${ald_index}=1
    ...    ${download_dir}=/tmp
    Log To Console    Info: Check RETU Status...
    ${retu_info} =    Get RETU Information via WebEM    retu_index=${retu_index}    ald_index=${ald_index}    download_dir=${download_dir}
    Should Be Equal As Strings    ${retu_info["Status"]["Administrative state"]}    ${administrative_state}
    ...    msg=Current RETU administrative_state is not in ${administrative_state} status    ignore_case=${True}
    Should Be Equal As Strings    ${retu_info["Status"]["Availability status"]}    ${availability_status}
    ...    msg=Current RETU availability_status is not in ${availability_status} status    ignore_case=${True}
    Should Be Equal As Strings    ${retu_info["Status"]["Availability status"]}    ${availability_status}
    ...    msg=Current RETU availability_status is not in ${availability_status} status    ignore_case=${True}
    Should Be Equal As Strings    ${retu_info["Status"]["Operational state"]}    ${operational_state}
    ...    msg=Current RETU operational_state is not in ${operational_state} status    ignore_case=${True}
    Should contain    ${retu_info["Status"]["Procedural status"]}    ${procedural_status}
    ...    msg=Current RETU procedural_status is not in ${procedural_status} status    ignore_case=${True}
    Should Be Equal As Strings    ${retu_info["Status"]["Usage state"]}    ${Usage state}
    ...    msg=Current RETU operational_state is not in ${Usage state} status    ignore_case=${True}



Get RETU Information via WebEM
    [Arguments]    ${retu_index}=1    ${ald_index}=1    ${download_dir}=/tmp
    Log to console    Info: ready to Get RETU Information
    #Selenium Login And Disable Screen Lock    download_dir=${download_dir}    version=${version}
    ${retu_info} =    selenium_coam.get_retu_info    retu_index=${retu_index}    ald_index=${ald_index}
    [Return]    ${retu_info}
    #[Teardown]    Selenium Logout And Close Browser

RETU status should be normal
    [Arguments]    ${retu_index}=1    ${ald_index}=1
    Wait until keyword succeeds    3min    5s    Check RETU Status    retu_index=${retu_index}    ald_index=${ald_index}

WA for ALD cases due to dip adjustment lever hw miss
    [Arguments]    ${download_dir}=/tmp    ${retu_index}=1    ${ald_index}=1
    CB007108_common_keywords.Reset ALD Via WebEM    reset_type=software    ald_index=${ald_index}    download_dir=${download_dir}
    sleep    30s
    ${retu_status}    run keyword and return status    Check RETU Status    retu_index=${retu_index}    ald_index=${ald_index}
    Run keyword if    '${retu_status}'=='False'    Reset ALD via WebEM    reset_type=software
    ...    ald_index=${ald_index}    download_dir=${download_dir}

Reset ALD via WebEM
    [Documentation]    Description: Resrt ALD from webem
    ...    ${reset_type}: value can be software, hardware, defult to use hardware
    ...    ${ald_index}: index of ALD
    [Arguments]    ${reset_type}=hardware    ${ald_index}=1    ${download_dir}=/tmp
    Log to console    Info: ready to Reset ALD
    #Selenium Login And Disable Screen Lock    download_dir=/tmp    version=${version}
    selenium_coam.reset_ald    reset_type=${reset_type}    ald_index=${ald_index}
	sleep     15s
    #[Teardown]    Selenium Logout And Close Browser


Set RETU Angles via WebEM
    [Arguments]    ${angle_value}    ${retu_index}=1    ${ald_index}=1    ${download_dir}=/tmp
    Log to console    Info: ready to Set RETU Angles
    &{angle_configuration}    Create Dictionary    angle=${angle_value}
    #Selenium Login And Disable Screen Lock    download_dir=${download_dir}    version=${version}
    selenium_coam.set_retu_angles    configuration=${angle_configuration}    retu_index=${retu_index}    ald_index=${ald_index}
    #[Teardown]    Selenium Logout And Close Browser


Get ALD Information via WebEM
    [Arguments]    ${ald_index}=1    ${download_dir}=/tmp
    Log to console    Info: ready to Get ALD Information
    #Selenium Login And Disable Screen Lock    download_dir=${download_dir}    version=${version}
    ${ald_info} =    selenium_coam.get_ald_info    ald_index=${ald_index}
	#sleep    20s
	set test variable    ${ald_info}
    [Return]    ${ald_info}
    #[Teardown]    Selenium Logout And Close Browser

Add ALD information to scf
    [Documentation]    author: Liu Zheng
    ...                this keyword is mainly for add ALD related objects and elements.
    ...                return the updated scf file path.
    [Arguments]    ${scf_file_path}=${backup_scf_path}    ${ald_index}=1
    ${local_log_file_folder}    set variable    ${SUITE_LOG_PATH}
    ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${local_log_file_folder}
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${scf_name_for_update}    catenate    SEPARATOR=${EMPTY}    ${file_name_without_extention}
    ...    _ALD_add.xml
    ${scf_file_update_path}    set variable    ${local_log_file_folder}/${scf_name_for_update}
    scf.Load scf    ${default_scf_file_path}
    FOR    ${item}    IN    @{ALD_MOS_PARAMS_TO_ADD_${ald_index}}
        scf.add object to scf  class_name=${item}[class_name]    dist_name=${item}[dist_name]   version=${item}[version]
    END
    FOR    ${item}    IN    @{ALD_LIST_NAME_PARAMS_TO_ADD_${ald_index}}
        scf.add list to scf  dist_name=${item}[dist_name]   list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{ALD_LIST_ELEMENTS_PARAMS_TO_ADD_${ald_index}}
        scf.add elements to list  dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{ALD_ELEMENTS_PARAMS_TO_ADD_${ald_index}}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    scf.Save scf    ${scf_file_update_path}
    #${program}    gnb_classical_hangzhou.Get program version based on stream version
    #${ret_serial_number}    set variable if    '${program}'=='master'    00000020111200363    I0M0802905-XX
    #${ret_product_code}     set variable if    '${program}'=='master'    TY-RCUB20    86010148V01
    #Run    sed -i 's/replace_productCode/${ret_product_code}/g' ${scf_file_update_path}
    #Run    sed -i 's/replace_serialNumber/${ret_serial_number}/g' ${scf_file_update_path}
    [Return]    ${scf_file_update_path}


1Preparation with swconfig modification and comissioning
    [Documentation]  Author: Ding Binmei
    ...              Description: Do modification for swconfig file and scf file.
    ...              ${swconfig_modify}: Can be a list for the modified R&D parameters, example input with python format:
    ...                                 ['0x580002=0', '0x580121=0']
    ...              ${scf_modify}: Default to modify the IP info defined in TL config file in variable ${PARAMS_TO_MODIFY_SCF}
    ...              ${is_called_in_test_case_level}: available values: ${True} ${False},
    ...                                               default to ${False} which means keyword is called in test suite setup phase
    ...              ${SWCONFIG_DEFAULT_FILE_PATH}: refers to the template swconfig file path in test pc,
    ...                                             should be defined before calling this keyword
    ...              ${SCF_DEFAULT_FILE_PATH}: refers to the template scf file path in test pc
    ...                                        should be defined before calling this keyword
    ...              ${is_pdl_checking_needed}: Valid values are ${True} or ${False}, if ${True} then PDL validation is needed,
    ...                              otherwise will not do PDL validation. Now it's default to ${True}
    [Arguments]    ${swconfig_modify}=${None}    ${scf_modify}=${PARAMS_TO_MODIFY_SCF}    ${is_called_in_test_case_level}=${False}
    ...    ${commission_timeout}=600    ${swconfig_template_path}=${SWCONFIG_DEFAULT_FILE_PATH}    ${scf_template_path}=${SCF_DEFAULT_FILE_PATH}
    ...    ${is_pdl_checking_needed}=${True}
    ...    ${gnb_index}=${0}    ${du_index}=${0}    ${connection}=GNB_OAM    ${alias}=ASIK Master
    COAM Create log directory    is_set_to_test_case_level=${is_called_in_test_case_level}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run keyword if    ${has_cbts}   Cloud DU connect to gnb coam via ssl   gnb_index=${gnb_index}    du_index=${du_index}    connection=${connection}
    ...    ELSE    Connect to gnb coam via ssl   gnb_index=${gnb_index}    connection=${connection}
    Connect to Common Unit Master    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}
    ${local_log_file_folder}    set variable if  ${is_called_in_test_case_level}==${True}    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}
    #${default_swconfig_file_path}    Copy file    source=${swconfig_template_path}    destination=${local_log_file_folder}/swconfig.txt
    #Run keyword if    ${swconfig_modify}!=${None}
    #...    Run keywords    Log to console    Swconfig file modification is needed.    AND
    #...    swconf.Modify swConfig file    parametersList=${swconfig_modify}    filePath=${default_swconfig_file_path}
    #swconf.Upload swConfig file to asik and crasign    localFilePath=${default_swconfig_file_path}    asik_alias=${alias}
    csn.disconnect    connection=${alias}
    Log to console    Start to modify scf files and commission, please wait...
    ${default_scf_file_path}    Copy file    source=${scf_template_path}    destination=${local_log_file_folder}
    ${output_scf_file_path}    coam_gnb_classical.COAM Modify scf file    scf_file_path=${default_scf_file_path}
    ...    scf_parameters_list=${scf_modify}
    ${result}    COAM Commission with scf file    scf_file_path=${output_scf_file_path}    timeout=${commission_timeout}
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}    connection=${connection}
    ${pdl_validation_result}    set variable if
    ...    ${is_pdl_checking_needed}==${True} and '${result['validationResult']['pdlValidationResult']['status']}'!='OK'    ${False}
    ...    ${is_pdl_checking_needed}==${True} and '${result['validationResult']['pdlValidationResult']['status']}'=='OK'    ${True}
    ...    ${is_pdl_checking_needed}==${False}    ${None}
    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=${alias}
	#...    AND    COAM Teardown gnb connections    connection=${connection}
    [Return]    ${pdl_validation_result}


Suite Setup
    Connect to gnb coam via ssl
    ${version}=    coam.get_sw_version    connection=GNB_OAM
	Set Suite Variable    ${version}
    Selenium Login And Disable Screen Lock
    ${stream}    get stream from version    ${version}
    Set Suite Variable    ${stream}
    @{SBTS_release}    string.split string    ${stream}    separator=SBTS
    ${release_id}    set variable    ${SBTS_release}[1]
    Set Suite Variable    ${release_id}
    ${8T8R_scf_name}    Run keyword if   '${stream}'=='SBTS00'     set variable   SCF_8T8R_SBTS00.xml
    ...   ELSE    set variable    SCF_8T8R_SBTS${release_id}.xml
    Set Suite Variable    ${8T8R_scf_name}

Add ALD precondition
    [Arguments]  ${ald_index}=1    ${retu_index}=1    ${port_type}=CAL
    Log to console    \nAdd ALD precondition
	set test variable    ${ald_index}
    COAM Create log directory    is_set_to_test_case_level=${False}
    ${scf_file_path}    Add ALD information to scf    ald_index=${ald_index}
    run keyword if    '${port_type}' == 'CAL'    Set parameters for ALD via CAL port   ELSE    Set parameters for ALD via RET port
    1Preparation with swconfig modification and comissioning    scf_modify=${scf_params_update}        is_pdl_checking_needed=False
    ...    scf_template_path=${scf_file_path}
    Run Keyword And Ignore Error    run process    taskkill /f /im firefoxdriver.exe    shell=True
    Run Keyword And Ignore Error    run process    ps -ef|grep firefox | awk '{print $2}' |xargs kill -9    shell=True
    Run Keyword And Ignore Error    run process    pkill -9 firefox    shell=True
	Wait until keyword succeeds    10min    30s    Verify all cells should be onair    connection=GNB_OAM
	run keyword and ignore error    Selenium Logout And Close Browser
	Selenium Login And Disable Screen Lock    download_dir=/tmp    version=${version}
    ${ald_info}=    run keyword and ignore error    Get ALD Information via WebEM    ald_index=${ald_index}
	${status}    run keyword and return status    RETU status should be normal    retu_index=${retu_index}    ald_index=${ald_index}
    #${status}    run keyword and return status    CB007108_common_keywords.Wait Until ALD AND RETU Status Normal
    #...    retu_index=${retu_index}    timeout=1 min
    run keyword if    '${status}' == 'False'    WA for ALD cases due to dip adjustment lever hw miss    ald_index=${ald_index}
    run keyword if    '${status}' == 'False'    Wait Until Keyword Succeeds   1 min  5 sec    Check RETU Status
    ...    retu_index=${retu_index}    ald_index=${ald_index}

UE preparation
    run keyword and ignore error    UE Reboot with adb command    ue_index=${-1}

Check RU Calibration Status And Compare
    [Documentation]  Author: Jia Lei
    [Arguments]  ${connection}=GNB_OAM    ${ru_dfe_ip}=192.168.100.3    ${asik_connection}=ASIK Master    ${retry_time}=3
    run keyword and ignore error    csn.disconnect    connection=${asik_connection}
    #run keyword and ignore error    COAM Teardown gnb connections
    #Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    connection_alias_store.Connect to Common Unit Master    alias=${asik_connection}
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${connection}
    @{ru_list}    Create List
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_list}
            Connect to RU With Allocated IP    ru_index=${ru_index}   ru_alias=RU${ru_index}
            ...    asik_alias=${asik_connection}   connection=${connection}
           Run Keyword And Continue On Failure    Wait until keyword succeeds    ${retry_time}X    30 s
           ...    Check RU Calibration Status    ru_alias=RU${ru_index}
           #run keyword if    "AZQ" in "${tl.gnbs[0].dus[0].rus[0].radio_type}"    Check AZGX RU Power on DFE   ru_alias=RU${ru_index}
           #...    ELSE
           #...             Check AEHC RU Power on DFE    ru_alias=RU${ru_index}    ru_dfe_ip=${ru_dfe_ip}
           csn.Disconnect  connection=RU${ru_index}
    END
   #[Teardown]  COAM Teardown gnb connections

Check AZGX RU Power on DFE
    [Documentation]  Author: haoxiaoxia
    [Arguments]    ${ru_alias}    ${ru_dfe_ip}=192.168.100.3    ${all_attenna_ports}=8
    ${connection}    csn.get connection by alias    alias=${ru_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send     ssh ${ru_dfe_ip}\n
    FOR    ${index}    IN RANGE    ${all_attenna_ports}
        Call Method    ${channel}    send     dapd -stat ${index}\n
        sleep  2s
        ${dfe_power_output}    Call Method    ${channel}    recv    ${65535}
        Log    ${dfe_power_output}
        ${tx_power_regexp}    set variable    TX.=.(\\d+\.?\\d*)
        ${tx_power_value}    Get Regexp Matches    ${dfe_power_output}    ${tx_power_regexp}    1
        ${status}     Run Keyword And Return Status     Should Be True    ${0}<=${tx_power_value}[0]<=${45}
        ...           msg=${tx_power_value}[0] is out of range.
    END
    [Teardown]  Call Method    ${channel}    close

Check RU Calibration Status
    [Documentation]  Author: Jia Lei
    [Arguments]    ${ru_alias}    ${carrier_name}=NR
    ${calibration_output}    csn.execute    command=sudo bfcali -stat    connection=${ru_alias}
    ${nr_calibration}    Split String From RU Calibration Output    calibration_output=${calibration_output}
    Get RU Calibration Value And Compare    nr_calibration=${nr_calibration}

Split String From RU Calibration Output
    [Documentation]  Author: Jia Lei
    [Arguments]    ${calibration_output}    ${carrier_name}=NR    ${sperator}=\r\n\r\n
    @{nr_calibration}    create list
    @{calibrations}    split string    ${calibration_output}    \r\n\r\n
    FOR    ${latest_cali}    IN    @{calibrations}
           ${status}    run keyword and return status    should contain    ${latest_cali}    ${carrier_name}
           run keyword if    '${status}'=='${True}'    append to list      ${nr_calibration}    ${latest_cali}
    END
    [Return]    ${nr_calibration}

Get RU Calibration Value And Compare
    [Documentation]  Author: Jia Lei
    [Arguments]    ${nr_calibration}
    FOR    ${each_cali}    IN    @{nr_calibration}
           ${attempt_regexp}    set variable    Calibration attempts: (\\d+)
           ${success_regexp}    set variable    Successful calibrations: (\\d+)
           ${attempt_count}    Get Regexp Matches    ${each_cali}    ${attempt_regexp}    1
           ${success_count}    Get Regexp Matches    ${each_cali}    ${success_regexp}    1
           should be equal   ${attempt_count}    ${success_count}
    END

Set angle for RET
    [Arguments]    ${retu_index}=1    ${ald_index}=1    ${download_dir}=/tmp
	#Selenium Login And Disable Screen Lock    download_dir=${download_dir}    version=${version}
    #${retu_index}    Convert To String    ${retu_index}
    ${retu_info}    selenium_coam.get_retu_info    retu_index=${retu_index}    ald_index=${ald_index}
	log to console    ${retu_info}
    ${angle}    get regexp matches    ${retu_info['Angle']}    [0-9]+
    ${angle}    get regexp matches    ${angle[0]}    [0-9]+
    FOR  ${i}    IN RANGE    ${10}
        ${min}    get regexp matches    ${retu_info['Angle range']}    from [0-9]+
        ${min}    get regexp matches    ${min[0]}    [0-9]+
        ${max}    get regexp matches    ${retu_info['Angle range']}    to [0-9]+
        ${max}    get regexp matches    ${max[0]}    [0-9]+
        ${angle_value}    evaluate   random.randint(${min[0]},${max[0]})   modules=random
        Exit For Loop If    ${angle[0]}!=${angle_value}
    END
    &{angle_configuration}    Create Dictionary    angle=${angle_value}
    selenium_coam.set_retu_angles    configuration=${angle_configuration}    retu_index=${retu_index}    ald_index=${ald_index}
    FOR  ${i}    IN RANGE    ${8}
        Sleep    20
        ${retu_info}    selenium_coam.get_retu_info    retu_index=${retu_index}    ald_index=${ald_index}
        ${angle}    get regexp matches    ${retu_info['Angle']}    [0-9]+
        ${angle}    get regexp matches    ${angle[0]}    [0-9]+
        Exit For Loop If    ${angle[0]}==${angle_value}
    END
    #[Teardown]    Selenium Logout And Close Browser

Set parameters for ALD via RET port
    Log to console    \nSet for ALD via	RET port
    ${scf_params_update}    Combine lists    ${PARAMS_TO_MODIFY_SCF}    ${SCF_MODIFY_VALUE_ALD}
    Set Suite Variable    ${scf_params_update}
	[Return]    ${scf_params_update}

Set parameters for ALD via CAL port
    Log to console    \nSet for ALD via	CAL port
    ${scf_params_update}    Combine lists    ${PARAMS_TO_MODIFY_SCF}    ${SCF_MODIFY_VALUE_ANTL1}
    Set Suite Variable    ${scf_params_update}
    [Return]    ${scf_params_update}

Backup SCF and return
    Log to console    \nBackup SCF and return
	${backup_scf_path}    Download SCF Download Via Rest Api
	set test variable    ${backup_scf_path}
	[Return]    ${backup_scf_path}


Check If there is 4282
    Log To Console    Check If there is 4282
    Connect to gnb coam via ssl
    ${alarm_list_actual}=    Check active alarms
    ${is_4282_active}=    run keyword and return status    Check if alarm exist    ${alarm_list_actual}    4282
    Set Suite Variable    ${is_alarm_visible}
	Log To Console    \n does fault 4282 report:${is_alarm_visible}
    ${alarm_list_history}=    Check history alarms
	${is_4282_history}=    run keyword and return status    Check if alarm exist    ${alarm_list_history}    4282
	#coam.teardown    connection=GNB_OAM
    run keyword if     '${is_alarm_visible}'=='True'     FAIL
    [return]    ${is_alarm_visible}

Check active alarms
    [Tags]      WIP
    ${active_alarms}    coam.get_active_alarms    connection=GNB_OAM    timeout=60
    ${alarm_id_list}    Create List
    ${len}    get length    ${active_alarms}
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    log    ${alarm_id_list}
    [Return]     ${alarm_id_list}

Check history alarms
    [Tags]      WIP
    ${history_alarms}=    coam.get_historic_alarms    timeout=60    connection=GNB_OAM
    ${alarm_id_list}    Create List
    ${len}    get length    ${history_alarms}
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${history_alarms[${i}]}    faultId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    log    ${alarm_id_list}
    [Return]     ${alarm_id_list}

Check if alarm exist
    [Arguments]    ${alarm_list}    ${alarm_id}
    set suite variable    ${is_alarm_visible}    False
    FOR    ${element}    IN    @{alarm_list}
        run keyword if    '${element}'=='${alarm_id}'    set suite variable   ${is_alarm_visible}     True
    END
    run keyword if     '${is_alarm_visible}'=='True'    FAIL
