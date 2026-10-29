*** Settings ***
Documentation    This is for feature CB012544 related common keywords.
...              Please do not modify the file without notification to author
...              Author:jun.8.chen@nokia-sbell.com
...              Squard: HZ SG6
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/TestData.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010767/Resources/CB010767_common.robot
Library     Hashed_UE_ID_Calcu.py


*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}


*** Keywords ***
Update ActEdrx Parameter Value
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    Log To Console    \n***start to Update ActEdrx Parameter Value***
    ${actEdrx1}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1', 'parameter':'actEdrx', 'value':'None'}
    ${actEdrx2}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2', 'parameter':'actEdrx', 'value':'None'}
    ${actEdrx3}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3', 'parameter':'actEdrx', 'value':'None'}
    ${update_param_list}     Catenate    ${actEdrx1},${actEdrx2},${actEdrx3}
    ${update_param_list}     Evaluate    [${update_param_list}]
    Update Params Via RestApi For Case    params_need_to_modify=${update_param_list}    gnb_index=0

Update Params Via RestApi For Case
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${params_need_to_modify}    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=300
    ...    ${skip_parameter_relation_errors}=False
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_need_to_modify}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    ...                                            skip_parameter_relation_errors=${skip_parameter_relation_errors}
    Wait Gnb Ready And Cell On Air    gnb_id=${gnb_index}    connection=${connection}    timeout=2 min
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

Disable All PA Ports
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${attenuator_index}=${0}
    @{channels}    Set Variable    ${tl.attenuator[${attenuator_index}].attenuator_ports}
    ${ip_addr}    set variable     ${tl.attenuator[${attenuator_index}].ip_addr}
    ${port}    set variable     ${tl.attenuator[${attenuator_index}].port}
    ${vendor}    set variable    ${tl.attenuator[${attenuator_index}].vendor}
    ${model}    set variable     ${tl.attenuator[${attenuator_index}].model}
    ${configured_attenuator}    attenuator.setup_attenuator
    ...    ip_addr=${ip_addr}
    ...    port=${port}
    ...    attenuation_port_numbers=${channels}
    ...    vendor=${vendor}
    ...    model=${model}
    FOR    ${index}    IN RANGE    1    17
        ${index}    Convert To Integer    ${index}
        ${value}    Evaluate    float(110)
        Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    5X    5sec   attenuator.set_attenuation
        ...    port=${index}   value=${value}   attenuator_device=${configured_attenuator}    confirm=True
        sleep   5sec
    END

Enable Case Related PA Ports
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${attenuator_index}=${0}    ${pa_port_index}=${${1},${2}}    ${value}=15
    ${pa_port_index_type}    Evaluate    type(${pa_port_index}).__name__
    ${convert_pa_port_index_to_list}    Create List    ${pa_port_index}
    ${pa_port_index}    Set Variable If    'list' in '${pa_port_index_type}' or 'tuple' in '${pa_port_index_type}'
    ...      ${pa_port_index}     ${convert_pa_port_index_to_list}
    @{channels}    Set Variable    ${tl.attenuator[${attenuator_index}].attenuator_ports}
    ${ip_addr}    set variable     ${tl.attenuator[${attenuator_index}].ip_addr}
    ${port}    set variable     ${tl.attenuator[${attenuator_index}].port}
    ${vendor}    set variable    ${tl.attenuator[${attenuator_index}].vendor}
    ${model}    set variable     ${tl.attenuator[${attenuator_index}].model}
    ${configured_attenuator}    attenuator.setup_attenuator
    ...    ip_addr=${ip_addr}
    ...    port=${port}
    ...    attenuation_port_numbers=${channels}
    ...    vendor=${vendor}
    ...    model=${model}
    FOR    ${index}    IN    @{pa_port_index}
        Log to console    start to set pa port for port${index} to ${value}
        ${index}    Convert To Integer    ${index}
        ${value}    Evaluate    float(${value})
        Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    5X    5sec   attenuator.set_attenuation
        ...    port=${index}   value=${value}   attenuator_device=${configured_attenuator}    confirm=True
        Sleep   5sec
    END

Check DCI_1_0 Message On DlData_PdcchSendreq
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${file_path}    ${shortMessage_vlaue}=144    ${dldata_pdcchsendreq}=dldata_pdcchsendreql1sw
    Setup Pcap File   file_path=${file_path}    filter=${dldata_pdcchsendreq}
    ${frame_number}    Get Field Value From PCAP    field_name=frame.number    filter_expression=3gpp.rnti==65534
    ${frame_number_new}    Evaluate   [int(x[0]) for x in ${frame_number}]
    ${frame_number_max}    Evaluate   max(${frame_number_new})
    ${frame_number_max}    Evaluate   str(${frame_number_max})
    ${short_messages}    Get Field Value From PCAP    field_name=dci.dci10.dci10_ShortMessages
    ...                                               filter_expression=3gpp.rnti==65534 && frame.number==${frame_number_max}
    ${epoch_time}    Get Field Value From PCAP    field_name=frame.time_epoch
    ...                                           filter_expression=3gpp.rnti==65534 && frame.number==${frame_number_max}
    Should Be True    ${short_messages[0][0]}==${shortMessage_vlaue}
    ...    msg=shortMessage_vlaue is not ${shortMessage_vlaue}, actual is ${short_messages}.
    [Return]    ${frame_number[-1][0]}    ${epoch_time[0][0]}

Deal With Pcap File
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${file_path}    ${frame_time}
	${split_bip_log_path}    OperatingSystem.Join Path    ${TS_CASE_LOG_PATH}    Split_bip_log
    OperatingSystem.Create Directory    ${split_bip_log_path}
    Set Test Variable     ${split_bip_log_path}
    OperatingSystem.Run   command=cd ${split_bip_log_path};editcap -c 4096 ${file_path} split.pcap
    ${split_file_name}    OperatingSystem.Run   command=cd ${split_bip_log_path};ls -l | grep -i "split_" |awk '{print $9}'
    ${split_file_name_list}    Split String    ${split_file_name}    \n
    ${init_time}    Set Variable    0
    OperatingSystem.Run   command=cd ${split_bip_log_path};touch test_final.pcap
    ${final_pcap_file}    Set Variable    ${split_bip_log_path}/test_final.pcap
    FOR    ${split_file_name}    IN    @{split_file_name_list}
        ${file_start_time}    Set Variable    ${split_file_name.split('.')[0].split('_')[-1]}
        ${tmp_time}    DateTime.Convert Date    ${file_start_time}    epoch
        ${status}    Run Keyword And Return Status    Should Be True    ${init_time}<=${frame_time}<=${tmp_time}
        ${list_index}    Run Keyword If    ${status}    Get Index From List    ${split_file_name_list}    ${split_file_name}
        ${next_index}    Run Keyword If    ${status}    Evaluate    ${list_index}+1
        ${last_index}    Run Keyword If    ${status}    Evaluate    ${list_index}-1
        ${before_index}    Run Keyword If    ${status}    Evaluate    ${list_index}-2
        ${cmd}    Run Keyword If    ${status}    Catenate    cd ${split_bip_log_path};mergecap -w test_final.pcap
        ...    ${split_file_name_list[${before_index}]} ${split_file_name_list[${last_index}]}
        ...    ${split_file_name_list[${list_index}]} ${split_file_name_list[${next_index}]}
        Run Keyword If    ${status}    Run Keywords    OperatingSystem.Run   command=${cmd}    AND    Exit For Loop
        ${init_time}    Set Variable    ${tmp_time}
    END
    [Return]    ${final_pcap_file}
    [Teardown]    Run Keyword And Ignore Error    OperatingSystem.Run   command=cd ${split_bip_log_path};rm split_*.pcap

Check SIB Message Detail Information
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${file_path}    ${frame_time}    ${dldata_pdschpayloadtbsendreq}=dldata_pdschpayloadtbsendreql1sw
    Setup Pcap File   file_path=${file_path}    filter=${dldata_pdschpayloadtbsendreq} && 3gpp.rnti == 65535
    ${epoch_time}    Get Field Value From PCAP    field_name=frame.time_epoch   filter_expression=nr-rrc.c1 == 1
    ${before_time}    Set Variable    0
    FOR    ${index}    IN    @{epoch_time}
        ${status}    Run Keyword And Return Status    Should Be True    ${before_time}<${frame_time}<${index[0]}
        Run Keyword If    ${status}    Run Keywords    Set Test Variable    ${after_frame_time}    ${index[0]}    AND
        ...                                            Set Test Variable    ${before_frame_time}    ${before_time}    AND
        ...                                            Exit For Loop
        ${before_time}    Set Variable    ${index[0]}
    END
    Setup Pcap File   file_path=${file_path}    filter=frame.time_epoch==${before_frame_time}
    ${eDRX_AllowedInactive_r17_value}    Get Field Value From PCAP    field_name=nr-rrc.eDRX_AllowedInactive_r17    filter_expression=${None}
    ${eDRX_AllowedIdle_r17_value}    Get Field Value From PCAP    field_name=nr-rrc.eDRX_AllowedIdle_r17    filter_expression=${None}
    ${hyperSFN_r17_value}    Get Field Value From PCAP    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedInactive_r17_value}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedIdle_r17_value}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${hyperSFN_r17_value}
    Setup Pcap File   file_path=${file_path}    filter=frame.time_epoch==${after_frame_time}
    ${eDRX_AllowedInactive_r17_value1}    Get Field Value From PCAP    field_name=nr-rrc.eDRX_AllowedInactive_r17    filter_expression=${None}
    ${eDRX_AllowedIdle_r17_value1}    Get Field Value From PCAP    field_name=nr-rrc.eDRX_AllowedIdle_r17    filter_expression=${None}
    ${hyperSFN_r17_value1}    Get Field Value From PCAP    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedInactive_r17_value1}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedIdle_r17_value1}
    Should Be Empty    ${hyperSFN_r17_value1}

CB012544 UE Attach For Paging
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_mode}=SA
    ...            ${ue_index}=${8}
    ...            ${gnb_index}=${0}
    ...            ${du_index}=0
    ...            ${hwcheck_index}=${1}
    ...            ${power_reset}=False
    ...            ${attach_mode}=5G_${ue_mode}
    ...            ${ue_alias}=UE_${ue_index}
    ...            ${timeout}=15
    Log To Console    ${\n}INFO:-- start to attach --
    ${timeout}    Evaluate    int(${timeout})
    power_ue.UE Attach    ue_type=${ue_type}
    ...                   ue_index=${ue_index}
    ...                   gnb_index=${gnb_index}
    ...                   hwcheck_index=${hwcheck_index}
    ...                   du_index=${du_index}
    ...                   power_reset=${power_reset}
    ...                   ue_alias=${ue_alias}
    ...                   attach_mode=${attach_mode}
    ...                   timeout=${timeout}

Update R&D Debug Parameter
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${timeout}=120
    ...            ${gnb_index}=${0}
    ...            ${url}=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...            ${download_dir}=${TS_CASE_LOG_PATH}
    ...            ${connection}=GNB_OAM
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
	${active_version}    coam.get_sw_version    timeout=${timeout}    connection=${connection}
	${version_splitted}    Split String    ${active_version}    _
    ${sw_version}    Strip string    ${version_splitted[0]}
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${username}    password=${password}    download_dir=${download_dir}
    ...                    timeout=${timeout}    version=${sw_version}
    selenium_coam.disable_message_box
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.disable_screen_lock
    selenium_sbts.change_rd_debug_parameters    domain=L2PS    parameter_name=rdFeatureFlagBitmapLevel    current_value=4
    ...                                         persistency=Persistent    timeout=${timeout}    sbts=${sw_version}
    ${Bitmap1_vlaue_list}    Create List    29    30
    selenium_sbts.change_rd_debug_parameters    domain=L2PS    parameter_name=rdFeatureFlagBitmap1    current_value=${Bitmap1_vlaue_list}
    ...                                         persistency=Persistent    timeout=${timeout}    sbts=${sw_version}
    selenium_sbts.apply_rd_debug_parameters_changes    timeout=${timeout}    sbts=${sw_version}
    [Teardown]    Run Keyword And Ignore Error    COAM selenium logout

Update Related Parameters For Paging
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               :param actEdrx                 ----value: Idle or None
    ...               :param InactivityTimer         ----value: 15 or 600
    ...               :param actRrcInactStateRedCap  ----value: false or true
    ...               :param maxBtsTimeError         ----value: 1000
    [Arguments]   ${actEdrx_value}=Idle
    ...           ${InactivityTimer_value}=15
    ...           ${actRrcInactStateRedCap_value}=false
    ...           ${maxBtsTimeError_vlaue}=1000
    ...           ${cell_idex}=311
    ...           ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}
#    ${AMF1}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-1',
#    ...    'parameter':'administrativeState','value':'Locked'}
#    ${AMF2}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-2',
#    ...    'parameter':'administrativeState','value':'Locked'}
#    ${AMF3}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-3',
#    ...    'parameter':'administrativeState','value':'Unlocked'}
    ${actRrcInactStateRedCap}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'actRrcInactStateRedCap','value':'${actRrcInactStateRedCap_value}'}
    ${maxBtsTimeError}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'maxBtsTimeError','value':'${maxBtsTimeError_vlaue}'}
    ${actEdrx}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-${cell_idex}',
    ...    'parameter':'actEdrx','value':'${actEdrx_value}'}
    ${drbInactivityTimerSARedCap}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'drbInactivityTimerSARedCap','value':'${InactivityTimer_value}'}
    ${srbInactivityTimerSARedCap}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'srbInactivityTimerSARedCap','value':'${InactivityTimer_value}'}
    ${drbInactivityTimerSA}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'drbInactivityTimerSA','value':'${InactivityTimer_value}'}
    ${srbInactivityTimerSA}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'srbInactivityTimerSA','value':'${InactivityTimer_value}'}
    ${update_param_list}     Catenate    ${actRrcInactStateRedCap},${maxBtsTimeError},${actEdrx},
    ...                                  ${drbInactivityTimerSARedCap},${srbInactivityTimerSARedCap},
    ...                                  ${drbInactivityTimerSA},${srbInactivityTimerSA}
#    ...                                  ${AMF1},${AMF2},${AMF3},
    ${update_param_list}     Evaluate    [${update_param_list}]
    COAM Update several parameters via rest api    parameters_to_update_via_api=${update_param_list}
    ...                                            timeout=${180}
    ...                                            connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}

12544_D Update Related Parameters For Paging
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]   ${actEdrx_value}=Idle + Inactive
    ...           ${InactivityTimer_value}=15
    ...           ${actRrcInactStateRedCap_value}=true
    ...           ${maxBtsTimeError_value}=1000
    ...           ${cell_idex}=311
    ...           ${actAdditionalSliceSupport_value}=false
    ...           ${actPagingEnh_value}=postponedPaging
    ...           ${tRanPagingGuard_value}=12
    ...           ${tEdrxRanPagingGuard_value}=12
    ...           ${ranEdrxPagingCycle_value}=v1024
    ...           ${actPriorityAccess_value}=false
    ...           ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}
    ${actAdditionalSliceSupport}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'actAdditionalSliceSupport','value':'${actAdditionalSliceSupport_value}'}
    ${actPagingEnh}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'actPagingEnh','value':'${actPagingEnh_value}'}
    ${actRrcInactStateRedCap}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'actRrcInactStateRedCap','value':'${actRrcInactStateRedCap_value}'}
    ${actEdrx}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-${cell_idex}',
    ...    'parameter':'actEdrx','value':'${actEdrx_value}'}
    ${maxBtsTimeError}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'maxBtsTimeError','value':'${maxBtsTimeError_value}'}
    ${tRanPagingGuard}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'tRanPagingGuard','value':'${tRanPagingGuard_value}'}
    ${tEdrxRanPagingGuard}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'tEdrxRanPagingGuard','value':'${tEdrxRanPagingGuard_value}'}
    ${ranEdrxPagingCycle}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'ranEdrxPagingCycle','value':'${ranEdrxPagingCycle_value}'}
    ${drbInactivityTimerSARedCap}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'drbInactivityTimerSARedCap','value':'${InactivityTimer_value}'}
    ${srbInactivityTimerSARedCap}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'srbInactivityTimerSARedCap','value':'${InactivityTimer_value}'}
    ${drbInactivityTimerSA}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'drbInactivityTimerSA','value':'${InactivityTimer_value}'}
    ${srbInactivityTimerSA}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'srbInactivityTimerSA','value':'${InactivityTimer_value}'}
    ${drbRrcInactInactivityTimerSA}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'drbRrcInactInactivityTimerSA','value':'${InactivityTimer_value}'}
    ${drbRrcInactInactivityTimerSARedCap}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'drbRrcInactInactivityTimerSARedCap','value':'${InactivityTimer_value}'}
#    ${AMF1}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-1',
#    ...    'parameter':'administrativeState','value':'Locked'}
#    ${AMF2}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-2',
#    ...    'parameter':'administrativeState','value':'Locked'}
#    ${AMF3}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-3',
#    ...    'parameter':'administrativeState','value':'Unlocked'}
    ${actPriorityAccess}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-${cell_idex}',
    ...    'parameter':'actPriorityAccess','value':'${actPriorityAccess_value}'}
    ${update_param_list}     Catenate    ${actAdditionalSliceSupport},${actPagingEnh},${actRrcInactStateRedCap},${actEdrx},
    ...                                  ${maxBtsTimeError},${tRanPagingGuard},${tEdrxRanPagingGuard},${ranEdrxPagingCycle},
    ...                                  ${drbInactivityTimerSARedCap},${srbInactivityTimerSARedCap},
    ...                                  ${drbInactivityTimerSA},${srbInactivityTimerSA},${drbRrcInactInactivityTimerSA},
    ...                                  ${drbRrcInactInactivityTimerSARedCap},${actPriorityAccess}
    ${update_param_list}     Evaluate    [${update_param_list}]
    COAM Update several parameters via rest api    parameters_to_update_via_api=${update_param_list}
    ...                                            timeout=${180}
    ...                                            connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}

Get The TMSI Value
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${file_path}
    Setup Pcap File   file_path=${file_path}    filter=ngap.procedureCode == 15
    ${tmsi_list}    Get Field Value From PCAP    field_name=nas-5gs.5g_tmsi
    ...                                          filter_expression=nas-5gs.5g_tmsi
    ...                                          attribute_name=show
    ${tmsi_value}    Set Variable    ${tmsi_list[0][0]}
    [Return]    ${tmsi_value}

Get The s-TMSI Value For Idle
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${file_path}
    Setup Pcap File   file_path=${file_path}    filter=f1ap.procedureCode == 18
    ${stmsi_list}    Get Field Value From PCAP    field_name=f1ap.fiveG_S_TMSI
    ...                                            filter_expression=f1ap.fiveG_S_TMSI
    ...                                            attribute_name=showname
    ${stmsi_value}    Set Variable    ${stmsi_list[0][0]}
    ${stmsi_value}    Set Variable    ${stmsi_value.split(' ')[-1].split(']')[0]}
    [Return]    ${stmsi_value}

Get The s-TMSI Value For Inactive
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               use ExtendedUEIdentityIndexValue replace
    [Arguments]    ${file_path}
    Setup Pcap File   file_path=${file_path}    filter=f1ap.procedureCode == 18
    ${stmsi_list}    Get Field Value From PCAP    field_name=f1ap.ExtendedUEIdentityIndexValue
    ...                                            filter_expression=f1ap.ExtendedUEIdentityIndexValue
    ...                                            attribute_name=showname
    ${stmsi_value}    Set Variable    ${stmsi_list[0][0]}
    ${stmsi_value}    Set Variable    ${stmsi_value.split(' ')[-1].split(']')[0]}
    [Return]    ${stmsi_value}

Get The HashedUEIdentityIndexValue In Pcap
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${file_path}
    Setup Pcap File   file_path=${file_path}    filter=f1ap.procedureCode == 18
    ${hashed_id_list}    Get Field Value From PCAP    field_name=f1ap.HashedUEIdentityIndexValue
    ...                                               filter_expression=f1ap.HashedUEIdentityIndexValue
    ...                                               attribute_name=showname
    ${hashed_id_value_new}    Set Variable    ${hashed_id_list[0][0]}
    ${HashedId_value}    Set Variable    ${hashed_id_value_new.split(' ')[-1].split(']')[0]}
    [Return]    ${HashedId_value}

Get UE Specific DRX In Pcap
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${file_path}
    Setup Pcap File   file_path=${file_path}    filter=ngap.procedureCode == 24
    ${PagingDRX_list}    Get Field Value From PCAP    field_name=ngap.PagingDRX
    ...                                               filter_expression=ngap.PagingDRX
    ...                                               attribute_name=showname
    ${PagingDRX_list_length}    Get Length    ${PagingDRX_list}
    IF    ${PagingDRX_list_length}==0
        ${PagingDRX_value}    Set Variable    ${0}
    ELSE
        ${PagingDRX_value}    Set Variable    ${PagingDRX_list[0][0]}
        ${PagingDRX_value}    Set Variable    ${PagingDRX_value.split(' ')[1].split('v')[-1]}
        ${PagingDRX_value}    Evaluate    int(${PagingDRX_value})
    END
    [Return]    ${PagingDRX_value}

Save Current SCF And Get value Of Parameters
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${gnb_index}=${0}    ${connection}=GNB_OAM${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${scf_file_path}    coam_gnb_classical.COAM Download scf from cluster    scf_dir_path=${TS_CASE_LOG_PATH}    connection=${connection}
    scf.load_scf    ${scf_file_path}
    ${drxDefaultPaging}    scf.get_value_from_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}    p_name=drxDefaultPaging
    ${drxDefaultPaging_value}    Set Variable    ${drxDefaultPaging.split('v')[-1]}
    ${ranEdrxPagingCycle}    scf.get_value_from_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}    p_name=ranEdrxPagingCycle
    ${ranEdrxPagingCycle_value}    Set Variable    ${ranEdrxPagingCycle.split('v')[-1]}
    ${ranPagingCycle}    scf.get_value_from_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}    p_name=ranPagingCycle
    ${ranPagingCycle_value}    Set Variable    ${ranEdrxPagingCycle.split('v')[-1]}
    [Return]    ${drxDefaultPaging_value}    ${ranEdrxPagingCycle_value}    ${ranPagingCycle_value}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get The extendedDRX_CycleInactive_r17 Capacity
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${file_path}
    Setup Pcap File   file_path=${file_path}    filter=ngap.procedureCode == 44
    ${extendedDRX_CycleInactive_r17_list}    Get Field Value From PCAP    field_name=nr-rrc.extendedDRX_CycleInactive_r17
    ...                                                                   filter_expression=nr-rrc.extendedDRX_CycleInactive_r17
    ...                                                                   attribute_name=showname
    ${extendedDRX_CycleInactive_r17_value}    Set Variable    ${extendedDRX_CycleInactive_r17_list[0][0]}
    ${extendedDRX_CycleInactive_r17_value}    Set Variable    ${extendedDRX_CycleInactive_r17_value.split(' ')[1]}
    [Return]    ${extendedDRX_CycleInactive_r17_value}

Verify The NRPagingeDRXInformation Message
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${file_path}
    Setup Pcap File   file_path=${file_path}    filter=f1ap.procedureCode == 18
    ${nrpaging_Time_Window_list}    Get Field Value From PCAP    field_name=f1ap.nrpaging_Time_Window
    ...                                                          filter_expression=f1ap.nrpaging_Time_Window
    ...                                                          attribute_name=show
    ${nrpaging_Time_Window_length}    Get Length    ${nrpaging_Time_Window_list}
    Should Be True    ${nrpaging_Time_Window_length}!=${0}    msg=nrpaging_Time_Window is empty.
    ${nrpaging_Time_Window_value}    Set Variable    ${nrpaging_Time_Window_list[0][0]}
    [Return]    ${nrpaging_Time_Window_value}

Verify The NRPagingeDRXInformationforRRCINACTIVE Message
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${file_path}    ${nR_paging_eDRX_Cycle_value}    ${ranEdrxPagingCycle_value}    ${extendedDRX_CycleInactive_r17_value}
    Setup Pcap File   file_path=${file_path}    filter=f1ap.procedureCode == 18
    ${nrpaging_eDRX_Cycle_Inactive_list}    Get Field Value From PCAP    field_name=f1ap.nrpaging_eDRX_Cycle_Inactive
    ...                                                                  filter_expression=f1ap.nrpaging_eDRX_Cycle_Inactive
    ...                                                                  attribute_name=show
    ${nrpaging_eDRX_Cycle_Inactive_length}    Get Length    ${nrpaging_eDRX_Cycle_Inactive_list}
    ${nrpaging_eDRX_Cycle_Inactive_value}    Set Variable    ${nrpaging_eDRX_Cycle_Inactive_list[0][0]}
    ${eDRX_Cycle_number_mapping}    Create Dictionary    0=256    1=512    2=1024    3=2048    4=4096    5=8192    6=16384    7=32768
    ...                                                  8=65536    9=131072    10=262144    11=524288    12=1048576
    ${value_eDRX_Cycle_Inactive_mapping}    Create Dictionary    256=0    512=1    1024=2    2048=3    4096=4    8192=5    16384=6
    ...                                                          32768=7    65536=8    131072=9    262144=10    524288=11    1048576=12
    IF    '${extendedDRX_CycleInactive_r17_value}'=='supported'
        ${eDRX_Cycle_number}    Set Variable    ${eDRX_Cycle_number_mapping['${nR_paging_eDRX_Cycle_value}']}
        ${eDrx_RAN}    Evaluate    min(${eDRX_Cycle_number}, ${ranEdrxPagingCycle_value})
        ${eDRX_Cycle_Inactive_value}    Set Variable    ${value_eDRX_Cycle_Inactive_mapping['${eDrx_RAN}']}
        Should Be True    ${nrpaging_eDRX_Cycle_Inactive_value}==${eDRX_Cycle_Inactive_value}
    ELSE
        Should Be True    ${nrpaging_eDRX_Cycle_Inactive_length}==${0}
    END
    [Return]    ${eDrx_RAN}    ${eDRX_Cycle_number}

Verify The Hashed ID Value
    [Documentation]    jun.8.chen@nokia-sbell.com
    [Arguments]    ${file_path}
    ${HashedId_value}    Get The HashedUEIdentityIndexValue In Pcap    file_path=${file_path}
    ${tmsi_value}    Get The TMSI Value    file_path=${file_path}
    ${HashedId}    calcu_value_of_hashed_id    tmsi=${tmsi_value}
    Should Be True    ${HashedId_value}==${HashedId}    msg=HashedId is not mismatch.
    [Return]    ${HashedId}    ${tmsi_value}

Verify The SFN In Syslog
    [Documentation]    jun.8.chen@nokia-sbell.com
    [Arguments]    ${syslog_file_path}    ${HashedId}    ${nR_paging_eDRX_Cycle_value}
    ...            ${nrpaging_Time_Window_value}    ${log_path}=${TS_CASE_LOG_PATH}
    ${TeDRX_CN}    ${sfn}    ${length}    ${end}    get_sfn_num    Hashed_ID=${HashedId}
    ...                                                            eDRX_Cycle=${nR_paging_eDRX_Cycle_value}
    ...                                                            Time_Window=${nrpaging_Time_Window_value}
    Run Keyword And Ignore Error    OperatingSystem.Run
    ...    tar -zxvf ${log_path}/${syslog_file_path}/syslog_files.tgz -C ${log_path}/${syslog_file_path}
#    ${file_name}    OperatingSystem.Run    cd ${log_path}/${syslog_file_path}; ls *.LOG
    ${pattern_string}    Set Variable    ueId13MSB=${HashedId}, teDrxCn=${TeDRX_CN}
    ${sfn_output}    OperatingSystem.Run    zgrep -a "${pattern_string}" ${log_path}/${syslog_file_path}/syslog_files.tgz
    ${sfn_output_count}    OperatingSystem.Run    zgrep -c -a "${pattern_string}" ${log_path}/${syslog_file_path}/syslog_files.tgz
    ${patternIdInfoList_exp}    Set Variable
    ...    ${pattern_string}.*current PTW.*start=${sfn} len=${length} end=${end}..next PTW*
    ${patternIdInfoList_log}    Get Regexp Matches    ${sfn_output}   ${patternIdInfoList_exp}
    ${patternIdInfoList_length}    Get Length    ${patternIdInfoList_log}
    Should Be True    ${patternIdInfoList_length}==${sfn_output_count}

Verify The UEID And TConfigToUse In Syslog For Idle
    [Documentation]    jun.8.chen@nokia-sbell.com
    [Arguments]    ${file_path}    ${syslog_file_path}    ${nR_paging_eDRX_Cycle_value}    ${log_path}=${TS_CASE_LOG_PATH}
    ${drxDefaultPaging_value}    ${ranEdrxPagingCycle_value}    ${ranPagingCycle_value}    Save Current SCF And Get value Of Parameters
    ${stmsi_value}    Get The s-TMSI Value For Idle    file_path=${file_path}
    ${PagingDRX_value}    Get UE Specific DRX In Pcap    file_path=${file_path}
    ${ueid}    ${tConfigToUse}    get_ueid_tConfigToUse_for_idle    sTMSI=${stmsi_value}
    ...                                                             nR_paging_eDRX_Cycle_value=${nR_paging_eDRX_Cycle_value}
    ...                                                             PagingDRX_value=${PagingDRX_value}
    ...                                                             drxDefaultPaging_value=${drxDefaultPaging_value}
    Run Keyword And Ignore Error    OperatingSystem.Run
    ...    tar -zxvf ${log_path}/${syslog_file_path}/syslog_files.tgz -C ${log_path}/${syslog_file_path}
    ${pattern_string}    Set Variable    \\[EDRX\\] ueId:${ueid}, tConfigToUse:${tConfigToUse}, sfnAndSlotComputed
    ${tConfigToUse_output}    OperatingSystem.Run    zgrep -a "sfnAndSlotComputed" ${log_path}/${syslog_file_path}/syslog_files.tgz
    ${patternIdInfoList_log}    Get Regexp Matches    ${tConfigToUse_output}   ${pattern_string}
    ${patternIdInfoList_length}    Get Length    ${patternIdInfoList_log}
    Run Keyword And Ignore Error    Should Be True    ${patternIdInfoList_length}>=1

Verify The UEID And TConfigToUse In Syslog For Inactive
    [Documentation]    jun.8.chen@nokia-sbell.com
    [Arguments]    ${file_path}    ${syslog_file_path}    ${nR_paging_eDRX_Cycle_value}
    ...            ${eDrx_RAN}    ${eDRX_Cycle_number}    ${drxDefaultPaging_value}    ${log_path}=${TS_CASE_LOG_PATH}
    ${stmsi_value}    Get The s-TMSI Value For Inactive    file_path=${file_path}
    ${ueid}    ${tConfigToUse}    ${OutPTW_tConfigToUse}    get_ueid_tConfigToUse_for_inactive
    ...                                                         sTMSI=${stmsi_value}
    ...                                                         nR_paging_eDRX_Cycle_value=${nR_paging_eDRX_Cycle_value}
    ...                                                         eDrx_RAN=${eDrx_RAN}
    ...                                                         eDRX_Cycle_number=${eDRX_Cycle_number}
    ...                                                         drxDefaultPaging_value=${drxDefaultPaging_value}
    Run Keyword And Ignore Error    OperatingSystem.Run
    ...    tar -zxvf ${log_path}/${syslog_file_path}/syslog_files.tgz -C ${log_path}/${syslog_file_path}
    ${file_name}    OperatingSystem.Run    cd ${log_path}/${syslog_file_path}/btslog; ls *.LOG
    IF    ${nR_paging_eDRX_Cycle_value}>=3
         ${pattern_string}    Set Variable    ranPagingInPTW ueId=${ueid}, tConfigToUse=${tConfigToUse}
         ${pattern_string1}    Set Variable    ranPagingOutPTW ueId=${ueid}, tConfigToUse=${OutPTW_tConfigToUse}
#         ${tConfigToUse_output}   OperatingSystem.Run   cd ${log_path}/${syslog_file_path}/btslog; cat ${file_name} | grep -i "ranPagingInPTW"
#         ${tConfigToUse_output1}   OperatingSystem.Run   cd ${log_path}/${syslog_file_path}/btslog; cat ${file_name} | grep -i "ranPagingOutPTW"
         ${tConfigToUse_output}    OperatingSystem.Run    zgrep -a "ranPagingInPTW" ${log_path}/${syslog_file_path}/syslog_files.tgz
         ${tConfigToUse_output1}    OperatingSystem.Run    zgrep -a "ranPagingOutPTW" ${log_path}/${syslog_file_path}/syslog_files.tgz
         ${tConfigToUse}    Get Regexp Matches    ${tConfigToUse_output}   ${pattern_string}
         ${tConfigToUse1}    Get Regexp Matches    ${tConfigToUse_output1}   ${pattern_string1}
         ${patternIdInfoList_length}    Get Length    ${tConfigToUse}
         ${patternIdInfoList_length1}    Get Length    ${tConfigToUse1}
         Run Keyword And Ignore Error    Should Be True    ${patternIdInfoList_length}>=1
         Run Keyword And Ignore Error    Should Be True    ${patternIdInfoList_length1}>=1
    ELSE
         ${pattern_string}    Set Variable    ueId=${ueid}, tConfigToUse=${tConfigToUse}, sfnAndSlotComputed
#         ${tConfigToUse_output}   OperatingSystem.Run   cd ${log_path}/${syslog_file_path}/btslog; cat ${file_name} | grep -i "sfnAndSlotComputed"
         ${tConfigToUse_output}    OperatingSystem.Run    zgrep -a "sfnAndSlotComputed" ${log_path}/${syslog_file_path}/syslog_files.tgz
         ${tConfigToUse}    Get Regexp Matches    ${tConfigToUse_output}   ${pattern_string}
         ${patternIdInfoList_length}    Get Length    ${tConfigToUse}
         Run Keyword And Ignore Error    Should Be True    ${patternIdInfoList_length}>=1
    END

The Count Of CNPagingCNT
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${file_path}    ${send_dl_data_times}
    Setup Pcap File   file_path=${file_path}    filter=f1ap.procedureCode == 18
    ${nR_paging_eDRX_Cycle_list}    Get Field Value From PCAP    field_name=f1ap.nrpaging_eDRX_Cycle_Idle
    ...                                                          filter_expression=f1ap.nrpaging_eDRX_Cycle_Idle
    ...                                                          attribute_name=show
    ${count_of_CNPagingCNT}    Get Length    ${nR_paging_eDRX_Cycle_list}
    ${nR_paging_eDRX_Cycle_value}    Set Variable    ${nR_paging_eDRX_Cycle_list[0][0]}
    ${count_of_CNRePagingCNT}    Evaluate    int(${count_of_CNPagingCNT})-int(${send_dl_data_times})
    [Return]    ${count_of_CNPagingCNT}    ${nR_paging_eDRX_Cycle_value}    ${count_of_CNRePagingCNT}

The Count Of CNPagingCNT For Inactive
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${file_path}    ${send_dl_data_times}
    Setup Pcap File   file_path=${file_path}    filter=f1ap.procedureCode == 18
    ${nR_paging_eDRX_Cycle_list}    Get Field Value From PCAP    field_name=f1ap.nrpaging_eDRX_Cycle_Inactive
    ...                                                          filter_expression=f1ap.nrpaging_eDRX_Cycle_Inactive
    ...                                                          attribute_name=show
    ${nR_paging_eDRX_Cycle_idle_list}    Get Field Value From PCAP    field_name=f1ap.nrpaging_eDRX_Cycle_Idle
    ...                                                               filter_expression=f1ap.nrpaging_eDRX_Cycle_Idle
    ...                                                               attribute_name=show
    ${count_of_CNPagingCNT}    Get Length    ${nR_paging_eDRX_Cycle_list}
    ${nR_paging_eDRX_Cycle_value}    Set Variable    ${nR_paging_eDRX_Cycle_idle_list[0][0]}
    Should Be True    ${count_of_CNPagingCNT}==${send_dl_data_times}    msg=Paging times is not 5 times.
    [Return]    ${count_of_CNPagingCNT}    ${nR_paging_eDRX_Cycle_value}

The Count Of PagingOutOfPTWCNT
    [Documentation]    jun.8.chen@nokia-sbell.com
    [Arguments]    ${syslog_file_path}    ${log_path}=${TS_CASE_LOG_PATH}
    Run Keyword And Ignore Error    OperatingSystem.Run
    ...    tar -zxvf ${log_path}/${syslog_file_path}/syslog_files.tgz -C ${log_path}/${syslog_file_path}
    ${count_of_PagingOutOfPTWCNT}    OperatingSystem.Run
    ...     zgrep -c -a "edrx Cn Paging is dropped" ${log_path}/${syslog_file_path}/syslog_files.tgz
    [Return]    ${count_of_PagingOutOfPTWCNT}

The Count Of RRC Resume Request In Syslog
    [Documentation]    jun.8.chen@nokia-sbell.com
    [Arguments]    ${syslog_file_path}    ${log_path}=${TS_CASE_LOG_PATH}
    Run Keyword And Ignore Error    OperatingSystem.Run
    ...    tar -zxvf ${log_path}/${syslog_file_path}/syslog_files.tgz -C ${log_path}/${syslog_file_path}
    ${file_name}    OperatingSystem.Run    cd ${log_path}/${syslog_file_path}/btslog; ls *.LOG
    IF    '${STREAM_VERSION}'=='master' or '${STREAM_VERSION}'=='25R3'
        ${pattern_string}    Set Variable    with cause: mtAccess
    ELSE
        ${pattern_string}    Set Variable    with cause:mtAccess
    END
    ${count_of_RrcResumeRequest}    OperatingSystem.Run    zgrep -c -a "${pattern_string}" ${log_path}/${syslog_file_path}/syslog_files.tgz
    [Return]    ${count_of_RrcResumeRequest}

The Count Of CNRePagingCNT
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${file_path}
    Setup Pcap File   file_path=${file_path}    filter=ngap.procedureCode == 24
    ${interval_time}    Get Field Value From PCAP    field_name=frame.time_delta_displayed    filter_expression=ngap.nR_paging_eDRX_Cycle
    ${count_of_CNRePagingCNT}    Set Variable    ${0}
    FOR    ${i}    IN    @{interval_time}
        ${value}    Evaluate    float(${i[0]})
        ${time_compare}    Evaluate    float(${8})
        ${status}    Run Keyword And Return Status    Should Be True    ${value}<${time_compare}
        ${count_of_CNRePagingCNT}    Run Keyword If    ${status}    Evaluate    ${count_of_CNRePagingCNT}+1
    END
    [Return]    ${count_of_CNRePagingCNT}

The Count Of CNRePagingCNT Via Syslog
    [Documentation]    jun.8.chen@nokia-sbell.com
    [Arguments]    ${syslog_file_path}
    ${count_of_PagingOutOfPTWCNT}    OperatingSystem.Run
    ...    cat ${syslog_file_path}/btslog | grep -c -i "F1APPaging: sending paging request in cells"
    ${PagingOutOfPTWCNT_output}    OperatingSystem.Run
    ...    cat ${syslog_file_path}/btslog | grep -i "F1APPaging: sending paging request in cells" | awk '{print $3}'
    Log    ${PagingOutOfPTWCNT_output}
    [Return]    ${PagingOutOfPTWCNT_output}

Get Counter Value For Paging
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=300
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    Log To Console    Gathering value of counter: "M55127C00003"
    ${counters_info}    coam.get_counters_info    connection=${connection}    timeout=${timeout}
    [Return]    ${counters_info}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

BTS Counters List
    [Documentation]    author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${gnb_id}=0
    ${bts_Name}    Get Bts Name For Gnb    gnb_id=${gnb_id}
    ${counters}    Catenate
    ...    {'M55119C01501': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NNGCB/NNGCB_NGAP_PAGING_RECD'},
    ...    {'M55119C02502': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NNGCB/NGAP_PAGING_RECD_PAG_EDRX'},
    ...    {'M55117C03001': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1/NF1CD/NF1CD_F1AP_PAGING_RECD'},
    ...    {'M55117C04502': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1/NF1CD/F1AP_PAGING_RECD_PAG_EDRX'},
    ...    {'M55331C00001': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/[QA3C0025A11] NRCELL-351/NRPAG/NRPAG_PAGING_SUCC_SENT'},
    ...    {'M55331C00002': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/[QA3C0025A11] NRCELL-351/NRPAG/NRPAG_PAG_DROP_MAX_PGRCD_EXCD'},
    ...    {'M55331C00005': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/[QA3C0025A11] NRCELL-351/NRPAG/NRPAG_EDRX_PAGING_SUCC_SENT'},
    ...    {'M55331C00006': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/[QA3C0025A11] NRCELL-351/NRPAG/EDRX_PAG_DROP_PGRCD_EXCD'},
    ...    {'M55127C00003': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1/NRRCD/NRRCD_RRC_STPREQ_MT_ACCESS'}
    ${counter_info_dict_list}    Evaluate    [${counters}]
    [Return]    ${counter_info_dict_list}

BTS Counters List For Inactive
    [Documentation]    author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${gnb_id}=0
    ${bts_Name}    Get Bts Name For Gnb    gnb_id=${gnb_id}
    ${counters}    Catenate
    ...    {'M55117C00004': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1/NF1CD/NF1CD_RAN_PAGING_SUCC_SENT'},
    ...    {'M55117C03001': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1/NF1CD/NF1CD_F1AP_PAGING_RECD'},
    ...    {'M55117C04502': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1/NF1CD/F1AP_PAGING_RECD_PAG_EDRX'},
    ...    {'M55117C04503': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1/NF1CD/F1AP_RAN_PAGING_RECD_PAG_EDRX'},
    ...    {'M55331C00001': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/[QA3C0025A11] NRCELL-351/NRPAG/NRPAG_PAGING_SUCC_SENT'},
    ...    {'M55331C00002': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/[QA3C0025A11] NRCELL-351/NRPAG/NRPAG_PAG_DROP_MAX_PGRCD_EXCD'},
    ...    {'M55331C00004': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/[QA3C0025A11] NRCELL-351/NRPAG/NRPAG_RAN_PAGING_SUCC_SENT'},
    ...    {'M55331C00005': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/[QA3C0025A11] NRCELL-351/NRPAG/NRPAG_EDRX_PAGING_SUCC_SENT'},
    ...    {'M55331C00006': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/[QA3C0025A11] NRCELL-351/NRPAG/EDRX_PAG_DROP_PGRCD_EXCD'},
    ...    {'M55331C00007': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/[QA3C0025A11] NRCELL-351/NRPAG/NRPAG_RAN_EDRX_PAGING_SUC_SENT'},
    ...    {'M55331C00008': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/[QA3C0025A11] NRCELL-351/NRPAG/RAN_EDRX_PAG_DROP_PGRCD_EXCD'}
    ${counter_info_dict_list}    Evaluate    [${counters}]
    [Return]    ${counter_info_dict_list}

Verify PM Counter Values
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${count_of_CNPagingCNT}    ${count_of_PagingOutOfPTWCNT}    ${count_of_CNRePagingCNT}    ${counter_id_mapping_values}
    ${count_of_CNPagingCNT}    Evaluate    int(${count_of_CNPagingCNT})
    ${count_of_PagingOutOfPTWCNT}    Evaluate    int(${count_of_PagingOutOfPTWCNT})
    ${count_of_CNRePagingCNT}    Evaluate    int(${count_of_CNRePagingCNT})
    ${pm_value_calculate_after}    Evaluate    ${count_of_CNPagingCNT} - ${count_of_PagingOutOfPTWCNT} - ${count_of_CNRePagingCNT}
    ${counter1_list}    Create List    M55119C01501    M55119C02502    M55117C03001    M55117C04502
    ${counter2_list}    Create List    M55331C00001    M55331C00005
    ${counter3_list}    Create List    M55331C00002    M55331C00006
    FOR    ${counter1}    IN    @{counter1_list}
        ${value}     Set Variable    ${counter_id_mapping_values['${counter1}']}
        Run Keyword And Continue On Failure    Should Be True    int(${value})>=${count_of_CNPagingCNT}
    END
    FOR    ${counter2}    IN    @{counter2_list}
        ${value}     Set Variable    ${counter_id_mapping_values['${counter2}']}
        Run Keyword And Continue On Failure    Should Be True    int(${value})>=${pm_value_calculate_after}
    END
    FOR    ${counter3}    IN    @{counter3_list}
        ${value}     Set Variable    ${counter_id_mapping_values['${counter3}']}
        Run Keyword And Continue On Failure    Should Be True    int(${value})==int(${0})
    END
    Should Be True    int(${counter_id_mapping_values['M55127C00003']})>=${pm_value_calculate_after}

Verify PM Counter Values For Inactive
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${count_of_CNPagingCNT}    ${counter_id_mapping_values}
    ${count_of_CNPagingCNT}    Evaluate    int(${count_of_CNPagingCNT})
    ${counter1_list}  Create List  M55117C00004  M55117C03001  M55117C04502  M55117C04503  M55331C00001  M55331C00004  M55331C00005  M55331C00007
    ${counter2_list}  Create List  M55331C00002    M55331C00006    M55331C00008
    FOR    ${counter1}    IN    @{counter1_list}
        ${value}     Set Variable    ${counter_id_mapping_values['${counter1}']}
        Run Keyword And Continue On Failure    Should Be True    int(${value})>=${count_of_CNPagingCNT}
    END
    FOR    ${counter2}    IN    @{counter2_list}
        ${value}     Set Variable    ${counter_id_mapping_values['${counter2}']}
        Run Keyword And Continue On Failure    Should Be True    int(${value})==int(${0})
    END
