*** Settings ***
Documentation
...    author: Ming Shi
...    contact: ming.shi@nokia-sbell.com
...    squad group: SG_03
...    feature : TDD_FDD

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/TDD_FDD_HO_common_keyword_new.robot

*** Keywords ***
Prepare all online UE with data start test_375
    sleep    1s

Make mutil UE for VoNR Setup TL375_new
    slect specified index of ue on TL375 for VONR_new
    FOR  ${index}  IN   @{ues_index}
        Make VoNR call(+6688)    ue_index=${index}
    END

hang up mutil UE for VoNR Setup TL375_new
    slect specified index of ue on TL375 for VONR_new
    FOR  ${index}  IN   @{ues_index}
    hang up VoNR for SFE    ue_index=${index}
    check voice call disable    ue_index=${index}
    END

slect specified index of ue on TL375 for VONR_new
    ${ues_index}=    Create List    ${28}    ${25}    ${27}
    Set Suite Variable    @{ues_index}

Make mutil UE for EMC Setup TL375_new
    slect specified index of ue on TL375 for EMC_new
    FOR  ${index}  IN   @{ues_index}
        Make EC call(911)    ue_index=${index}
    END

hang up mutil UE for EMC Setup TL375_new
    slect specified index of ue on TL375 for EMC_new
    FOR  ${index}  IN   @{ues_index}
    hang up EC call for SFE_new   ue_index=${index}
    check voice call disable    ue_index=${index}
    END

slect specified index of ue on TL375 for EMC_new
    ${ues_index}=    Create List    ${37}    ${34}    ${35}    ${38}    ${39}
    Set Suite Variable    @{ues_index}

hang up EC call for SFE_new
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}    timeout=60
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
#    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cpc_${ue_index}
#    sleep    12s
    csn.send_command    command=adb -s ${serial_number} shell input tap 260 65    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 556 1915
    ...    connection=cpc_${ue_index}
    sleep    5s
    csn.disconnect      connection=cpc_${ue_index}

make Video call over NR
    [Arguments]
    ...    ${MO_UE_index}
    ...    ${MT_UE_index}
    Get VoNR and ViNR pointer variable
    Make a VoNR and ViNR call    ue_index=${MO_UE_index}    mt_ue_index=${MT_UE_index}
    answer ViNR call    ue_index=${MT_UE_index}
    Sleep    5s     reason=check ViNR status on MO and MT after 5s
    check voice call disable    ue_index=${MO_UE_index}
    check voice call disable    ue_index=${MT_UE_index}
    [Teardown]    Run Keyword IF    '${KEYWORD STATUS}' == 'FAIL'    hang up VoNR or ViNR call    ue_index=${MO_UE_index}

Get VoNR and ViNR pointer variable
    # Samsung S25
    Set Suite Variable    ${Enter_Make_ViNR_button_T}    228 1864
    Set Suite Variable    ${answer_ViNR_button}    232 1766 232 1208

Make a VoNR and ViNR call
    [Arguments]
    ...    ${ue_index}=${0}    ${mt_ue_index}=${0}
    ...    ${phone_number}=${tl.ues[${mt_ue_index}].sec_key}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   3s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin${ue_index}
    sleep   2s
    #####make VoNR and ViNR call together#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.DIAL tel:+86${phone_number}
    ...    connection=cygwin${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${Enter_Make_ViNR_button_T}    connection=cygwin${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${Enter_Make_ViNR_button_T}    connection=cygwin${ue_index}
    sleep    2s
    [Teardown]    csn.disconnect    connection=cygwin${ue_index}

answer ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   3s
    csn.send_command    command=adb -s ${serial_number} shell input swipe ${answer_ViNR_button}    connection=cygwin${ue_index}
    sleep    2s
    [Teardown]    csn.disconnect    connection=cygwin${ue_index}

hang up VoNR or ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

online delete object parameters for 37511 NRREL
    [Arguments]    ${gnb_index}=${0}    #${skip_parameter_relation_errors}=True
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    FOR    ${NRREL}    IN    @{tmp_NRREL_delete_37511}
        online operate object parameters    parameters=${NRREL}    operation=delete    skip_parameter_relation_errors=False
    END
    [Teardown]    COAM Teardown gnb connections

online delete object parameters for 37512 NRREL
    [Arguments]    ${gnb_index}=${1}    #${skip_parameter_relation_errors}=True
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    FOR    ${NRREL}    IN    @{tmp_NRREL_delete_37512}
        online operate object parameters    parameters=${NRREL}    operation=delete    skip_parameter_relation_errors=False
    END
    [Teardown]    COAM Teardown gnb connections

online operate object parameters
    [Documentation]    This keyword is used to operate
    ...    Author: ming.shi@nokia-sbell.com
    [Arguments]
    ...    ${parameters}
    ...    ${operation}=update
    ...    ${skip_parameter_relation_errors}=True
    ...    ${should_activate}=True
    ...    ${timeout}=${300}
    ...    ${connection}=GNB_OAM
    coam.perform_object_recommissioning
    ...    dist_name=${parameters}[dist_name]    parameter=${parameters}[parameter]    operation=${operation}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}
    ...    timeout=${timeout}    connection=${connection}

change cell301 status to Locked
    [Arguments]    ${para}=${Cell_STATUS_Locked}
    Online modify parmeters    parameters_to_update=${para}

change cell301 status to Unlocked
    [Arguments]    ${para}=${Cell_STATUS_Unlocked}
    Online modify parmeters    parameters_to_update=${para}

SFE Multiple data models procedure
    [Arguments]    ${path}    ${file_name}    ${tl_id}    ${execution}    ${yml_name}    ${cpc_ip}=${ute_ip}    ${alias}=alias
    ...    ${cpc_usrname}=${ute_username}   ${cpc_passwd}=${ute_password}
    Connect to cpc   ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}    ${alias}
    csn.send command
    ...    command=source CIENV/7_5_UTE5G402T${tl_id}/bin/activate;python ${path}${file_name} ${execution} ${yml_name}
    ...    connection=${alias}
    [Teardown]    Csn.disconnect    connection=${alias}

SFE Multiple UEs network operation action
    [Arguments]    ${tl_id}    ${pc_ip}    ${file_name}    ${path}
    ...    ${pc_usr}=${control_pc_username}    ${pc_pwd}=${control_pc_password}
    ...    ${cpc_ip}=${ute_ip}    ${alias}=alias    ${cpc_usrname}=${ute_username}   ${cpc_passwd}=${ute_password}
    Connect to cpc   ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}    ${alias}
    csn.send command
    ...    command=source CIENV/7_5_UTE5G402T${tl_id}/bin/activate;python ${path}${file_name} ${pc_ip} ${pc_usr} ${pc_pwd}
    ...    connection=${alias}
    [Teardown]    Csn.disconnect    connection=${alias}

delete required mo
    [Arguments]    ${gnb_index}=${0}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${scf_content}=    coam.get_scf    export_type=configurationAndRuntimeObjects    connection=${connection}
    ${NRADJNRCELL_distName_path_list}=    get_required_distname_path    search_str=${scf_content}    required_distname=NRADJNRCELL
    ${NRADJGNB_distName_path_list}=    get_required_distname_path    search_str=${scf_content}    required_distname=NRADJGNB
    ${XNLINK_distName_path_list}=    get_required_distname_path    search_str=${scf_content}    required_distname=XNLINK
    ${NRADJNRCELL_mo_para_list}=    get_mo_parameters_to_delete    mo_name_list=${NRADJNRCELL_distName_path_list}
    ${NRADJGNB_mo_para_list}=    get_mo_parameters_to_delete    mo_name_list=${NRADJGNB_distName_path_list}
    ${XNLINK_mo_para_list}=    get_mo_parameters_to_delete    mo_name_list=${XNLINK_distName_path_list}
    ${NRADJNRCELL_num}=    Get Length    ${NRADJNRCELL_mo_para_list}
    ${NRADJGNB_num}=    Get Length    ${NRADJGNB_mo_para_list}
    ${XNLINK_num}=    Get Length    ${XNLINK_mo_para_list}
    FOR    ${index}    ${para}    IN ENUMERATE    @{NRADJNRCELL_mo_para_list}
        online operate object parameters
        ...    parameters=${para}
        ...    operation=delete
        ...    skip_parameter_relation_errors=False
        ...    should_activate=True
        ...    connection=${connection}
    END
    FOR    ${index}    ${para}    IN ENUMERATE    @{NRADJGNB_mo_para_list}
        online operate object parameters
        ...    parameters=${para}
        ...    operation=delete
        ...    skip_parameter_relation_errors=False
        ...    should_activate=True
        ...    connection=${connection}
    END
    FOR    ${index}    ${para}    IN ENUMERATE    @{XNLINK_mo_para_list}
        online operate object parameters
        ...    parameters=${para}
        ...    operation=delete
        ...    skip_parameter_relation_errors=False
        ...    should_activate=True
        ...    connection=${connection}
    END
    [Teardown]    COAM Teardown gnb connections

Adjust_HBTE_PA with loop for 375
    [Arguments]    ${pa_name}    ${s_value}    ${e_value}    ${step}    ${ho_times}
    ${length_s_value}=    get length    ${s_value}
#    Set Test Variable    ${initial_s_value}    ${s_value}
#    Set Suite Variable    ${initial_s_value}    ${s_value}
    ${initial_s_value}=    Copy List    ${s_value}
	Set Test Variable    ${initial_s_value}
    ${unequal_port}    Create List
    FOR    ${port}    IN RANGE    ${length_s_value}
        Run Keyword If    ${s_value}[${port}] != ${e_value}[${port}]    Append To List    ${unequal_port}    ${port}
    END
    Set Test Variable    ${need_change_port_index}    ${unequal_port}[0]
    ${step}    Evaluate    float(${step})
    ${ho_times}    Evaluate    float(${ho_times}/2)
    ${step_value}    Evaluate    float((${e_value}[${need_change_port_index}]-${s_value}[${need_change_port_index}])/${step})
    ${s_value}    Evaluate    float(${s_value}[${need_change_port_index}])
    ${e_value}    Evaluate    float(${e_value}[${need_change_port_index}])
    ${sleep}    Evaluate    round((${interval}-${step}*${pa_settime})/${step},1)
    FOR  ${times}    IN RANGE    ${ho_times}
       Log to console    Adjust_HBTE_${pa_name} with loop: ho_times=${ho_times} NO.${times}
       loop for PA set value    pa_name=${pa_name}    s_value=${s_value}    step=${step}
       ...    step_value=${step_value}    sleep=${sleep}    port_num=${length_s_value}    initial_s_value=${initial_s_value}
       ...    unequal_port=${unequal_port}
    END

PA achieve one way path
    [Arguments]    ${loop_times}    ${start_value}    ${end_value}    ${att_ports}    ${att_ipaddr}
    FOR    ${t}    IN RANGE    ${loop_times}
        FOR    ${value}    IN    ${start_value}    ${end_value}    ${0.5}
            ${port_num}=    Evaluate    len(${att_ports})
            ${att_values}=    Evalaute    [${value}] * ${port_num}
            Set the attenuation value of ports simultaneously
            ...    att_ports=${att_ports}
            ...    values=${att_values}
            ...    att_ipaddr=${att_ipaddr}
            Sleep    0.5s
        END
    END
