*** Settings ***
Documentation    This is for TMO common keywords.
...              Please do not modify the file without notification to author
...              Author: stella.lin@nokia-sbell.com

Resource    ./TMO_common_keywords.robot


*** Keywords ***
Verify RU Log Include In Snapshot
    [Documentation]   Auther: jun.8.chen@nokia-sbell.com
    ...    is_get_snapshot_via_selenium: if set to ${True} use selenium for collect, if ${False} use rest api
    [Arguments]   ${snapshot_path}    ${ru_index}=${1}    ${ru_alias}=RU    ${connection}=GNB_OAM    ${timeout}=900
    ...           ${unzip_path}=${TS_CASE_LOG_PATH}    ${rmod_bbmod_mapping}=${1}    ${rmod_index}=${1}    ${alais}=ASIK Master
    ...           ${serial_number}=None
#    ${log_on_ru}    Get RFSW Log File List On RU   connection=${ru_alias}    download_dir=${unzip_path}    timeout=${timeout}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${rfsw_log_path}    Set Variable    /ram/rfsw_log_${timestamp}.zip
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
#    Execute RU Command Via FHNET Container     command=cd /usr/bin;ccsShell.sh log -a -z ${rfsw_log_path}
#    Sleep   10 sec
    ${rfsw_log_path}    Get RF LOG Form RF    rmod_bbmod_mapping=${rmod_bbmod_mapping}
    ...    rmod_index=${rmod_index}    ru_index=${ru_index}
    ...    asik_alias=${alais}    connection=${connection}
    ...    ru_username=${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.username}
    ...    ru_password=${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.password}
    ...    serial_number=${serial_number}
    Connect to RU Via Allocated IP    rmod_bbmod_mapping=${rmod_bbmod_mapping}
     ...    rmod_index=${rmod_index}    ru_index=${ru_index}
     ...    ru_alias=RU_${ru_index}    asik_alias=${alais}    connection=${connection}
     ...    ru_username=${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.username}
     ...    ru_password=${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.password}
    ...     serial_number=${serial_number}
    ${rfsw_log_path_on_testPC}    Download RU File To TestPC    ru_file_path=${rfsw_log_path}    connection=${ru_alias}
    Set Task Variable      ${rfsw_log_path_on_testPC}
    ${unzip_result}    Run     unzip -l ${rfsw_log_path_on_testPC} |tail -n +2
    ${vaild_lines}      Get Lines Matching Regexp    ${unzip_result}     \\d+11_.*    partial_match=true
    ${log_on_ru}    Get Regexp Matches      ${vaild_lines}    ([2-9]011)?_.*
    ${log_on_snapshot}    Get RU Log File List On Snapshot    snapshot_path=${snapshot_path}    ru_index=${ru_index}
    ...                                                       unzip_path=${unzip_path}    connection=${connection}
    ...                                                       timeout=${timeout}
    ...                                                       serial_number=${serial_number}
    ${not_include_list}    Create List
    FOR  ${item}  IN  @{log_on_ru}
       ${status}  Run Keyword And Return Status  Should Contain Match   ${log_on_snapshot}   regexp=.*${item}.*
       Run Keyword If  ${status}==${False}     Append to List    ${not_include_list}     ${item}
    END
    ${white_list}    Set Variable    ${RU_LOGS_NOT_IN_SNAPSHOT_WHITE_LIST}
    ${flilter_lists}    Create List
    FOR  ${item}  IN   @{white_list}
        ${flilter_list}    Evaluate   [y for y in ${not_include_list} if '${item}' in y]
        ${flilter_lists}    combine lists    ${flilter_lists}    ${flilter_list}
    END
    ${not_include_list}    Evaluate    list(set(${not_include_list})-set(${flilter_lists}))
    ${length}    Get Length    ${not_include_list}
    Run   rm -rf ${snapshot_unzip_file_path}
    Should Be Equal As Integers   ${length}   ${0}   msg=Item ${not_include_list} not include in snapshot logs

Get RU Log File List On Snapshot
    [Documentation]   Auther: jun.8.chen@nokia-sbell.com
    [Arguments]   ${snapshot_path}    ${ru_index}=${1}    ${unzip_path}=${TS_CASE_LOG_PATH}    ${connection}=GNB_OAM    ${timeout}=600
    ...           ${serial_number}=None
    log    ${timeout}
    log    ${ru_index}
    &{ru_info}    run keyword if    '${serial_number}'=='None'
    ...                             COAM get ru detial info by ru index     ru_index=${rmod_index}   connection=${connection}
    ${serial_number}    Set Variable If    '${serial_number}'=='None'    ${ru_info['serialNumber']}    ${serial_number}
#    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
#    ${serial_number}  Set Variable    ${ru_info['serialNumber']}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_unzip_file_path}    Join Path    ${unzip_path}    snapshot_${timestamp}
    Set Test Variable    ${snapshot_unzip_file_path}
    Run   rm -rf ${snapshot_unzip_file_path}
    extract zip file    ${snapshot_path}    ${snapshot_unzip_file_path}
    ${output}   OperatingSystem.get file    ${snapshot_unzip_file_path}/snapshot_file_list.txt
    ${prefix_name}    Set Variable If    '${stream_version}'=='25R1'    BTS    BTS(\\d+)
    ${rfsw_log_names}   Get Regexp Matches   ${output}   ${prefix_name}\\_${serial_number}\\_.*
    [Return]    ${rfsw_log_names}

Update Special Apn
    [Documentation]   Auther: jun.8.chen@nokia-sbell.com
    [Arguments]    ${apn_address}=${tl.core.pdns[0].apn}    ${except_apn}=mdrb.nokia.com    ${ue_index}=${0}    ${ue_type}=${ue_type}
    ...            ${plmn}=${tl.core.mcc}${tl.core.mnc}    ${mcc}=${tl.core.mcc}     ${mnc}=${tl.core.mnc}
    ...            ${except_name}=drb    ${apn_type}=default
    Run Keyword If    '${ue_type}'=='huawei_sigspark'
    ...                       Modify APN    apn_address=${apn_address}    except_apn=${except_apn}    ue_index=${ue_index}
    ...    ELSE IF    '${ue_type}'=='qct_dx50'
    ...                       Change_netword_mode.Switch Apn   apn_address=${except_apn}    ue_index=${ue_index}
    ...    ELSE IF    '${ue_type}'=='mtk'
    ...                       Change MTK APN    apn_address=${apn_address}    plmn=${plmn}    mcc=${mcc}    mnc=${mnc}    apn_type=${apn_type}
    ...                       except_name=${except_name}    except_apn=${except_apn}    ue_index=${ue_index}

Change MTK APN
    [Documentation]   Auther:xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    ...            ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...            ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...            ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...            ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...            ${apn_address}=${tl.core.pdns[0].apn}
    ...            ${plmn}=${tl.core.mcc}${tl.core.mnc}    ${mcc}=${tl.core.mcc}     ${mnc}=${tl.core.mnc}
    ...            ${except_name}=drb    ${except_apn}=mdrb.nokia.com
    ...            ${apn_type}=default,mms,supl,hipri,fota,cbs,xcap
    log    ${apn_address}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    ${delete_apn}    Catenate    adb -s ${serial_number} shell content delete --uri
    ...                          content://telephony/carriers --where "numeric=${plmn}"
    csn.send_command    command=${delete_apn}    connection=cpc_${ue_index}
    Sleep    3sec
    ${add_apn}    Catenate	adb -s ${serial_number} shell content insert --uri content://telephony/carriers --bind name:s:"${except_name}"
    ...						--bind numeric:s:"${plmn}" --bind type:s:"${apn_type}" --bind mcc:i:${mcc}
    ...						--bind mnc:s:"${mnc}" --bind apn:s:"${except_apn}"  --bind user:s:"" --bind password:s:""
    csn.send_command    command=${add_apn}     connection=cpc_${ue_index}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Get NRRELE And NRADJECELL Config For Inter-RAT_NR-LTE_ANR HO
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${source_cell_idx}    ${target_cell_idx}    ${target_cell_pci}    ${connection}=GNB_OAM0
    ...            ${gnb_index}=0    ${timeout}=${60}    ${should_activate}=${True}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${nrrele_mos}    gnbaction.get_nrrele_config
    @{delete_param_list}    Create List
    FOR    ${mo}    IN    @{nrrele_mos}
        ${nrcell_id}    Set Variable    ${mo['distName'].split('/')[-2].split('-')[-1]}
        ${nrrele_id}    Set Variable    ${mo['distName'].split('/')[-1].split('-')[-1]}
        ${lcrId}    Set Variable    ${mo['parameters']['lcrId']}
        ${dist_name}    Set Variable    NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${source_cell_idx}/NRRELE-${nrrele_id}
        ${cellid_status}    Evaluate    "${nrcell_id}"=="${source_cell_idx}"
        ${lcrId_status}    Evaluate    "${lcrId}"=="${target_cell_idx}"
        ${param}    Evaluate    {'dist_name': '${dist_name}'}
        Run Keyword If    ${cellid_status} and ${lcrId_status}    Append To List    ${delete_param_list}    ${param}
        Exit For Loop If    ${cellid_status} and ${lcrId_status}
    END
    ${nradjecell_mos}    gnbaction.get_nradjecell_config
    FOR    ${mo}    IN    @{nradjecell_mos}
        ${nradjecell_id}    Set Variable    ${mo['distName'].split('-')[-1]}
        ${lcrId}    Set Variable    ${mo['parameters']['lcrId']}
        ${pci}    Set Variable    ${mo['parameters']['physCellId']}
        ${dist_name}    Set Variable    NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRADJECELL-${nradjecell_id}
        ${pci_status}    Evaluate    "${pci}"=="${target_cell_pci}"
        ${lcrId_status}    Evaluate    "${lcrId}"=="${target_cell_idx}"
        ${param}    Evaluate    {'dist_name': '${dist_name}'}
        Run Keyword If    ${pci_status} and ${lcrId_status}    Append To List    ${delete_param_list}    ${param}
        Exit For Loop If    ${pci_status} and ${lcrId_status}
    END
    COAM Delete Several Object Via Rest Api    parameters_to_update_via_api=${delete_param_list}
    ...                                        timeout=${timeout}
    ...                                        connection=${connection}
    ...                                        should_activate=${should_activate}
    [Return]    ${delete_param_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check The Lcrid For Special NRRELE And NRADJECELL
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${source_cell_idx}    ${target_cell_idx}    ${target_cell_pci}    ${nrrele_index}=256
    ...            ${nradjecell_index}=5000    ${timeout}=300    ${connection}=GNB_OAM    ${gnb_index}=0
    log    ${timeout}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${lcrId_value}    coam_parameter.get_single_value_from_scf_file
    ...                      parameter=lcrId
    ...                      dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${source_cell_idx}/NRRELE-${nrrele_index}
    ...                      connection=${connection}
    ...                      timeout=300
    ${target_cell_idx}    Evaluate    str(${target_cell_idx})
    Should Be Equal    ${lcrId_value}    ${target_cell_idx}
    ${lcrId_value1}    coam_parameter.get_single_value_from_scf_file
    ...                      parameter=lcrId
    ...                      dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRADJECELL-${nradjecell_index}
    ...                      connection=${connection}
    ...                      timeout=300
    ${pci_value1}    coam_parameter.get_single_value_from_scf_file
    ...                      parameter=physCellId
    ...                      dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRADJECELL-${nradjecell_index}
    ...                      connection=${connection}
    ...                      timeout=300
    ${target_cell_pci}    Evaluate    str(${target_cell_pci})
    Should Be Equal    ${lcrId_value1}    ${target_cell_idx}
    Should Be Equal    ${pci_value1}    ${target_cell_pci}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get NRREL Config For Intra Frequency
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${source_cell_idx}    ${target_cell_idx}    ${connection}=GNB_OAM0
    ...            ${gnb_index}=0    ${timeout}=${600}    ${should_activate}=${True}
    log    ${timeout}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${nrrel_mos}    gnbaction.get_nrrel_config
    @{delete_param_list}    Create List
    FOR    ${mo}    IN    @{nrrel_mos}
        ${nrcell_id}    Set Variable    ${mo['distName'].split('/')[-2].split('-')[-1]}
        ${nrrel_id}    Set Variable    ${mo['distName'].split('/')[-1].split('-')[-1]}
        ${lcrId}    Set Variable    ${mo['parameters']['lcrId']}
        ${dist_name}    Set Variable    NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${source_cell_idx}/NRREL-${nrrel_id}
        ${cellid_status}    Evaluate    "${nrcell_id}"=="${source_cell_idx}"
        ${lcrId_status}    Evaluate    "${lcrId}"=="${target_cell_idx}"
        ${param}    Evaluate    {'dist_name': '${dist_name}'}
        Run Keyword If    ${cellid_status} and ${lcrId_status}    Run Keywords
        ...    Append To List    ${delete_param_list}    ${param}    AND
        ...    COAM Delete Several Object Via Rest Api    parameters_to_update_via_api=${delete_param_list}
        ...                                               timeout=${timeout}
        ...                                               connection=${connection}
        ...                                               should_activate=${should_activate}
        Exit For Loop If    ${cellid_status} and ${lcrId_status}
    END
    [Return]    ${delete_param_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check The Lcrid For Special NRREL
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${source_cell_idx}    ${target_cell_idx}    ${nrrel_index}=256
    ...            ${timeout}=300    ${connection}=GNB_OAM    ${gnb_index}=0
    log    ${timeout}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${lcrId_value}    coam_parameter.get_single_value_from_scf_file
    ...                      parameter=lcrId
    ...                      dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${source_cell_idx}/NRREL-${nrrel_index}
    ...                      connection=${connection}
    ...                      timeout=300
    ${target_cell_idx}    Evaluate    str(${target_cell_idx})
    Should Be Equal    ${lcrId_value}    ${target_cell_idx}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Update Nrarfcn And Gscn Of All AEHC
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Source config: nrarfcn--527202//gscn: 6588, target config: nrarfcn--530700//gscn: 6633
    [Arguments]    ${nrarfcn}=530700    ${gscn}=6633    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=600
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${cell_info}   coam.get_cells_info    cell_type=nr    timeout=${timeout}    connection=${connection}
    @{param_list}    Create List
    FOR    ${cell}    IN    @{cell_info}
        ${dist_name}    Set Variable    ${cell['id']['configuration']}
        ${cell_nrarfcn}    Set Variable    ${cell.get('nrarfcn')}
        ${gscnOrSsPbchArfcn}     coam_parameter.get_single_value_from_scf_file    parameter=gscnOrSsPbchArfcn
        ...                                                                       dist_name=${dist_name}
        ...                                                                       connection=${connection}
        ...                                                                       timeout=300
        ${nrarfcn_param}    Evaluate    {'dist_name': '${dist_name}', 'parameter': 'nrarfcn','value': '${nrarfcn}'}
        ${gscn_param}    Evaluate    {'dist_name': '${dist_name}', 'parameter': 'gscnOrSsPbchArfcn','value': '${gscn}'}
        Run Keyword If    '${cell_nrarfcn}'!='None' and '${cell_nrarfcn}'=='527202'
        ...    Run Keywords    Append To List    ${param_list}    ${nrarfcn_param}    AND
        ...                    Append To List    ${param_list}    ${gscn_param}
    END
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    timeout=${timeout}
    Wait Gnb Ready And Cell On Air    gnb_id=${gnb_index}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Update DrxLongCycle Of All 5G Cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${drxLongCycle}=160ms    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=300
    ${nr_cell_list}    Get Cell Index List    cell_type=nr    gnb_id=${gnb_index}    gnb_connection=${connection}
    @{param_list}    Create List
    &{drxLongCycle_value}    Create Dictionary    drxLongCycle=${drxLongCycle}
    FOR    ${nr_cell}    IN    @{nr_cell_list}
        ${dist_name}    Set Variable    NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${nr_cell}
        ${param}    Evaluate    {'dist_name': '${dist_name}', 'parameter': 'drxProfileAnrNrIntraFreq','value':[&{drxLongCycle_value}]}
        Append To List    ${param_list}    ${param}
    END
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    timeout=${timeout}
    Wait Gnb Ready And Cell On Air    gnb_id=${gnb_index}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Verify Non-CA Basic L3 Call One By One
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_list}    ${ue_type}    ${ue_mode}=SA    ${ue_index}=${0}    ${enb_index}=${1}
    ...            ${dl_throughput}=2500MKbits/sec    ${ul_throughput}=100M
    ...            ${start_keep_on_duration}=300    ${ignore_time}=10sec    ${tput_collect_duration}=60
    ...            ${expect_addition_scell_indexs}=${None}    ${scell_mapping}=${None}
    ...            ${whether_do_barred_action}=${False}    ${exp_status}=notBarred    ${whether_do_Angles}=${True}
    ...            ${whether_do_lte_barred_action}=${False}    ${whether_do_close_all_ports}=${True}
    ...            ${whether_do_stop_call}=${True}    ${whether_do_case_prepare}=${True}    ${whether_do_mcs_setup}=${False}
    Log To Console    ${\n}INFO:-- start to do Non-CA Basic L3 Call One By One --
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    FOR    ${cell}    IN    @{cell_list}
        Run Keyword If    ${whether_do_case_prepare}    Non-CA Case Prepare For Multi-UE    cell_index=${cell}    cell_type=nr
        ...                                                 ue_index=${ue_index}    whether_do_close_all_ports=${whether_do_close_all_ports}
        ...                                                 whether_do_mcs_setup=${whether_do_mcs_setup}
        ...                                                 whether_do_Angles=${whether_do_Angles}
        Change cellBarred Parameter Value On Gnb    pcell_index=${cell}    gnb_id=${0}
        Procedures.Verify CA Basic L3 Call    ue_index=${ue_index}
        ...                                   ue_type=${ue_type}
        ...                                   ue_mode=${ue_mode}
        ...                                   ul_throughput=${ul_throughput}
        ...                                   dl_throughput=${dl_throughput}
        ...                                   whether_need_ue_log=${False}
        ...                                   whether_check_scell_addition=${False}
        ...                                   whether_do_barred_action=${whether_do_barred_action}
        ...                                   expect_addition_scell_indexs=${expect_addition_scell_indexs}
        ...                                   pcell_mapping=${PCELL_MAPPING}
        ...                                   scell_mapping=${scell_mapping}
        ...                                   whether_check_on_air=${False}
        ...                                   check_scell_tput=${False}
        ...                                   target_DL_avg_percent=0.1
        ...                                   target_UL_avg_percent=0.1
        ...                                   min_DL_percent=0.0
        ...                                   min_UL_percent=0.0
        ...                                   notbarred_cell_index=${PCELL_INDEX}
        ...                                   exp_status=${exp_status}
        ...                                   start_keep_on_duration=${start_keep_on_duration}
        ...                                   ignore_time=${ignore_time}
        ...                                   tput_collect_duration=${tput_collect_duration}
        ...                                   whether_do_lte_barred_action=${whether_do_lte_barred_action}
        ...                                   enb_index=${enb_index}
        Run Keyword If    ${whether_do_stop_call}    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index}    ue_type=${ue_type}
    END

Verify 4G Non-CA Basic L3 Call One By One
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_list}    ${ue_type}    ${ue_index}=${0}    ${enb_index}=${0}
    ...            ${dl_throughput}=300MKbits/sec    ${ul_throughput}=100M
    ...            ${start_keep_on_duration}=300    ${ignore_time}=10sec
    ...            ${tput_collect_duration}=60    ${expect_dl_tput}=5
    ...            ${whether_do_stop_call}=${True}     ${expect_ul_tput}=1
    ...            ${whether_do_close_all_ports}=${True}
    ...            ${whether_do_barred_action}=${False}
    ...            ${whether_do_ue_prepare}=${False}    ${process_num}=${2}
    log    ${process_num}
    Log To Console    ${\n}INFO:-- start to do 4G Non-CA Basic L3 Call One By One --
    FOR    ${cell}    IN    @{cell_list}
        Verify 4G Non-CA Basic L3 Call    cell_index=${cell}
        ...                               ue_type=${ue_type}
        ...                               ue_index=${ue_index}
        ...                               enb_index=${enb_index}
        ...                               dl_throughput=${dl_throughput}
        ...                               ul_throughput=${ul_throughput}
        ...                               start_keep_on_duration=${start_keep_on_duration}
        ...                               ignore_time=${ignore_time}
        ...                               tput_collect_duration=${tput_collect_duration}
        ...                               expect_dl_tput=${expect_dl_tput}
        ...                               expect_ul_tput=${expect_ul_tput}
        ...                               whether_do_stop_call=${whether_do_stop_call}
        ...                               whether_do_close_all_ports=${whether_do_close_all_ports}
        ...                               whether_do_barred_action=${whether_do_barred_action}
        ...                               whether_do_ue_prepare=${whether_do_ue_prepare}
    END

Verify 4G Non-CA Basic L3 Call
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_index}    ${ue_type}    ${ue_index}=${0}    ${enb_index}=${0}
    ...            ${dl_throughput}=300MKbits/sec    ${ul_throughput}=100M
    ...            ${start_keep_on_duration}=300    ${ignore_time}=10sec
    ...            ${tput_collect_duration}=60    ${expect_dl_tput}=5
    ...            ${whether_do_stop_call}=${True}     ${expect_ul_tput}=1
    ...            ${whether_do_close_all_ports}=${True}
    ...            ${whether_do_case_prepare}=${True}
    ...            ${whether_do_barred_action}=${False}
    ...            ${whether_do_ue_prepare}=${False}
    log    ${ul_throughput}
   Log To Console    ${\n}INFO:-- start to do 4G Non-CA Basic L3 Call--
    Run Keyword If    ${whether_do_case_prepare}    Non-CA Case Prepare For Multi-UE    cell_index=${cell_index}    cell_type=lte
    ...                   ue_index=${ue_index}    enb_index=${enb_index}    whether_do_close_all_ports=${whether_do_close_all_ports}
    Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=${cell_index}    enb_index=${enb_index}
    Procedures.Verify 4G L3 Call    whether_do_lte_barred_action=${False}
    ...                             whether_do_barred_action=${whether_do_barred_action}
    ...                             whether_check_on_air=${False}
    ...                             notbarred_cell_index=${cell_index}
    ...                             ue_index=${ue_index}
    ...                             ue_type=${ue_type}
    ...                             dl_throughput=${dl_throughput}
    ...                             start_keep_on_duration=${start_keep_on_duration}
    ...                             ignore_time=${ignore_time}
    ...                             tput_collect_duration=${tput_collect_duration}
    ...                             enb_index=${enb_index}
    ...                             expect_dl_tput=${expect_dl_tput}
    ...                             expect_ul_tput=${expect_ul_tput}
    ...                             whether_do_ue_prepare=${whether_do_ue_prepare}
    Run Keyword If    ${whether_do_stop_call}    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index}    ue_type=${ue_type}

Non-CA Case Prepare For Multi-UE
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :Param: ${cell_type}, "nr" or "lte"
    [Arguments]    ${cell_index}    ${cell_type}=nr    ${ue_index}=${0}
    ...            ${gnb_index}=${0}    ${enb_index}=${0}
    ...            ${connection}=GNB_OAM0    ${timeout}=120    ${whether_do_Angles}=${True}
    ...            ${whether_do_close_all_ports}=${True}    ${whether_do_mcs_setup}=${False}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'!='nr'
    ...            Wait Until Keyword Succeeds   1 min   5 sec   Connect to eNB via ssl   enb_index=${enb_index}   connection=${connection}
    ...    ELSE    Wait Until Keyword Succeeds   1 min   5 sec   Connect to gnb coam via ssl   connection=${connection}   gnb_index=${gnb_index}
    Run Keyword If    ${whether_do_close_all_ports}    Trun Off All PA Ports
    ${attenuator_list}    Set Variable If    '${ue_index}'!='${0}'
    ...    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['UEs_info'][${ue_index}]['attenuator']}
    ...    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['attenuator']}
    ${pcell_ru_index}   Run Keyword If    '${cell_type}'=='nr'    Get 5G Related Info Of Cell   cell_index=${cell_index}
    ...                                                                                         gnb_index=${gnb_index}
    ...    ELSE    Get 4G Related Info Of Cell   cell_index=${cell_index}    connection=${connection}    timeout=${timeout}
    FOR    ${attenuator}    IN    @{attenuator_list}
        Run Keyword If    '${attenuator}'=='pa'
        ...        Modify PA Value Setting For Required RU    modify_ru_id=${pcell_ru_index}    ue_index=${ue_index}
        ...    ELSE IF    '${attenuator}'=='mcs'    Set Case Related MCS Port Value
        ...                                         ue_index=${ue_index}   whether_do_mcs_setup=${whether_do_mcs_setup}
        ...                                         whether_do_Angles=${whether_do_Angles}
        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
    END
    [Teardown]    Teardown GNB and ENB Connections

Get 5G Related Info Of Cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Just for non-ca
    [Arguments]    ${cell_index}    ${gnb_index}=${0}
    mbca.set_pcell_index    value=${cell_index}
    mbca.set_gnb_id    value=${gnb_index}
    mbca.set_gnb_operation_object
    ${pcell_mapping}    mbca.get_pcell_mapping_for_tmo
    Set Test Variable    ${PCELL_MAPPING}     ${pcell_mapping}
    Set Test Variable    ${PCELL_INDEX}    ${cell_index}
    ${pcell_ru_index}    Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    [Return]    ${pcell_ru_index}

Get 4G Related Info Of Cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Just for non-ca
    [Arguments]    ${cell_index}    ${connection}=GNB_OAM0    ${timeout}=120
    ${cell_info}   coam.get_cells_info    cell_type=lte    timeout=${timeout}    connection=${connection}
    FOR    ${item}    IN    @{cell_info}
        ${rmod_info}    Get From List    ${item['carrierList']}    0
        ${rmod_id}    Get Regexp Matches    ${rmod_info['antennaLineId']['configuration']}    RMOD-(\\d+)    1
        ${cell_id}    Set Variable    ${item['id']['configuration'].split('-')[-1]}
		${status}    Evaluate    "${cell_id}"=="${cell_index}"
        ${rmod_index}    Run Keyword If    ${status}    Set Variable    ${rmod_id}
		Exit For Loop If    "${status}"=="True"
    END
    ${rmod_sn_mapping}    gnbaction.get_rmod_sn_mapping
    ${sn_ru_index_in_int_mapping}    gnbaction.get_sn_ru_index_in_int_mapping
	${serial_number}    Set Variable    ${rmod_sn_mapping['${rmod_index}[0]']}
    ${pcell_ru_index}    Set Variable    ${sn_ru_index_in_int_mapping['${serial_number}']}
    ${pcell_ru_index}    Evaluate    str(${pcell_ru_index})
    [Return]    ${pcell_ru_index}

Get RU Index Of LTE Cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_index}    ${timeout}=120    ${gnb_id}=0   ${gnb_index}=${0}    ${enb_index}=${1}    ${connection}=GNB_OAM0
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_id}    gnb_connection=${connection}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False}
    ...            Wait Until Keyword Succeeds   1 min   5 sec   Connect to eNB via ssl   enb_index=${enb_index}   connection=${connection}
    ...    ELSE    Wait Until Keyword Succeeds   1 min   5 sec   Connect to gnb coam via ssl   gnb_index=${gnb_index}   connection=${connection}
    ${cell_info}   coam.get_cells_info    cell_type=lte    timeout=${timeout}    connection=${connection}
    FOR    ${item}    IN    @{cell_info}
        ${rmod_info}    Get From List    ${item['carrierList']}    0
        ${rmod_id}    Get Regexp Matches    ${rmod_info['antennaLineId']['configuration']}    RMOD-(\\d+)    1
        ${cell_id}    Set Variable    ${item['id']['configuration'].split('-')[-1]}
		${status}    Evaluate    "${cell_id}"=="${cell_index}"
        ${rmod_index}    Run Keyword If    ${status}    Set Variable    ${rmod_id}
		Exit For Loop If    "${status}"=="True"
    END
    ${rmod_sn_mapping}    gnbaction.get_rmod_sn_mapping
    ${sn_ru_index_in_int_mapping}    gnbaction.get_sn_ru_index_in_int_mapping
	${serial_number}    Set Variable    ${rmod_sn_mapping['${rmod_index}[0]']}
    ${ru_index}    Set Variable    ${sn_ru_index_in_int_mapping['${serial_number}']}
    ${ru_index}    Evaluate    str(${ru_index})
    Set Test Variable    ${NSA_PA_RU_INDEX}    ${ru_index}
    [Teardown]    Teardown GNB and ENB Connections

Perform Special RU Power Action
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Param: ${action}--'power_off' or 'power_on'
    [Arguments]    ${action}=power_off    ${gnb_index}=${0}    ${du_index}=${0}
    Log To Console    \***start to perform ru power ${action}***\
    ${ru_list}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus}
    FOR    ${ru}    IN    @{ru_list}
        ${ru_index}    Get Index From List    ${ru_list}    ${ru}
        ${model}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].pdu_port.pdu.__class__.__name__}
        ${ru_pdu_ip}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].pdu_port.pdu.addr}
        ${ru_pdu_port}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].pdu_port.port_no}
        ${status}    Run Keyword And Return Status   Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type.value}
        ${ru_type}    Set Variable If    ${status}    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type.value}
        ...                                           ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type}
        Run Keyword If    '${action}'=='power_off'    Run Keywords
        ...        pdu.setup_pdu    model=${model}   host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}    AND
        ...        pdu.power_off    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}
        ...    ELSE IF    '${action}'=='power_on'    Run Keywords
        ...        pdu.setup_pdu    model=${model}   host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}    AND
        ...        pdu.power_on    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}
    END

Perform Lock Or Unlock Single Cell On Special RU and Make Non-CA L3 call
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${ru_type}=AEHC   ${cell_type}=nr    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM    ${ue_index}=${0}
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
     log    ${enb_connection}
    ${cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}
    FOR    ${cell_index}    IN    @{cell_list}
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=lock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=lock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Sleep    10sec
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unlock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unlock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Connect to gnb coam via ssl    connection=GNB_OAM
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${GNB_ALLOWED_FAULT}
        Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'    Check ENB On Air And Unexpect Alarm Should Not Exist
        Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'    Change cellBarred Parameter Value Of Lte Cells
        ...    list_cell_ids=all    exp_status=barred    enb_index=${0}
        ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
        @{nr_cell_list}    create list    ${cell_index}
        Verify Non-CA Basic L3 Call One By One    cell_list=${nr_cell_list}    ue_type=${ue_type}    ue_index=${ue_index}
        ...    enb_index=${fdd_enb_index}
    END

Perform Block Or Unblock Single Cell On Special RU and Make Non-CA L3 call
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${ru_type}=AEHC   ${cell_type}=nr    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM     ${ue_index}=${0}
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
     log    ${enb_connection}
    ${cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}
    FOR    ${cell_index}    IN    @{cell_list}
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Sleep    10sec
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Connect to gnb coam via ssl    connection=GNB_OAM
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${GNB_ALLOWED_FAULT}
        Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'    Check ENB On Air And Unexpect Alarm Should Not Exist
        Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'    Change cellBarred Parameter Value Of Lte Cells
        ...    list_cell_ids=all    exp_status=barred    enb_index=${0}
        ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
        @{nr_cell_list}    create list    ${cell_index}
        Verify Non-CA Basic L3 Call One By One    cell_list=${nr_cell_list}    ue_type=${ue_type}    ue_index=${ue_index}
        ...    enb_index=${fdd_enb_index}
    END


Perform Lock Or Unlock LTE Cell On Special RU and Make LTE L3 call
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${ru_type}=AEHC   ${cell_type}=lte    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    ...            ${dl_throughput}=2500MKbits/sec     ${ue_index}=0
     log    ${enb_connection}
    ${lte_cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}     enb_index=${enb_index}
    FOR    ${lte_cell_index}    IN    @{lte_cell_list}
        Lock Or Unlock Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=lock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=lock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Sleep    10sec
        Lock Or Unlock Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=unlock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=unlock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Connect to gnb coam via ssl    connection=GNB_OAM
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${GNB_ALLOWED_FAULT}
        Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'    Check ENB On Air And Unexpect Alarm Should Not Exist
        Change status for parameter cellBarred on GNB    exp_status=barred   list_cell_ids=all    timeout=${timeout}
        @{lte_cell_list_new}    create list    ${lte_cell_index}
        Verify 4G Non-CA Basic L3 Call One By One    cell_list=${lte_cell_list_new}   ue_type=${ue_type}   enb_index=${0}
        ...    whether_do_barred_action=${True}    dl_throughput=${dl_throughput}       ue_index=${ue_index}
    END

Perform Block Or Unblock LTE Cell On Special RU and Make LTE L3 call
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${ru_type}=AEHC   ${cell_type}=lte    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    ...            ${dl_throughput}=2500MKbits/sec       ${ue_index}=0
    log    ${enb_connection}
    log    ${dl_throughput}
    ${lte_cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}     enb_index=${enb_index}
    FOR    ${lte_cell_index}    IN    @{lte_cell_list}
        Lock Or Unlock Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Sleep    10sec
        Lock Or Unlock Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Connect to gnb coam via ssl    connection=GNB_OAM
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${GNB_ALLOWED_FAULT}
        Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'    Check ENB On Air And Unexpect Alarm Should Not Exist
        Change status for parameter cellBarred on GNB    exp_status=barred   list_cell_ids=all    timeout=${timeout}
        @{lte_cell_list_new}    create list    ${lte_cell_index}
        Verify 4G Non-CA Basic L3 Call One By One    cell_list=${lte_cell_list_new}   ue_type=${ue_type}   enb_index=${0}
        ...    whether_do_barred_action=${True}    dl_throughput=${dl_throughput}       ue_index=${ue_index}
    END

Perform Lock Or Unlock LTE Cell On Special RU and Make NSA L3 call
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${ru_type}=AEHC   ${cell_type}=lte    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM     ${ue_index}=${0}
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    ...            ${dl_throughput}=2500MKbits/sec    ${whether_do_stop_call}=${True}
    log many    ${enb_connection}    ${dl_throughput}
    ${lte_cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}
    FOR    ${lte_cell_index}    IN    @{lte_cell_list}
        Lock Or Unlock Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=lock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=lock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Sleep    10sec
        Lock Or Unlock Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=unlock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=unlock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Connect to gnb coam via ssl    connection=GNB_OAM
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${GNB_ALLOWED_FAULT}
        Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'    Check ENB On Air And Unexpect Alarm Should Not Exist
        ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
        Procedures.Verify CA Basic L3 Call    ue_mode=NSA
        ...                                   ul_throughput=150M
        ...                                   dl_throughput=2500MKbits/sec
        ...                                   notbarred_cell_index=all
        ...                                   b1_select_cell_index=${PCELL_INDEX}
        ...                                   list_cell_ids=${lte_cell_index}
        ...                                   exp_status=barred
        ...                                   whether_do_lte_barred_action=${True}
        ...                                   whether_check_scell_addition=${False}
        ...                                   tput_collect_duration=60
        ...                                   ignore_time=15sec
        ...                                   target_DL_avg_percent=0.01
        ...                                   target_UL_avg_percent=0.0
        ...                                   min_DL_percent=0.0
        ...                                   min_UL_percent=0.0
        ...                                   check_scell_tput=${False}
        ...                                   scell_mapping=${None}
        ...                                   ue_index=${ue_index}
        ...                                   enb_index=${fdd_enb_index}
        Run Keyword If    ${whether_do_stop_call}    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index}    ue_type=${ue_type}
    END


Perform Block Or Unblock LTE Cell On Special RU and Make NSA L3 call
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${ru_type}=AEHC   ${cell_type}=lte    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM       ${ue_index}=${0}
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    ...            ${dl_throughput}=2500MKbits/sec    ${whether_do_stop_call}=${True}
    log many    ${enb_connection}    ${dl_throughput}
    ${lte_cell_list}    Get Cell List For Special RU    cell_type=${cell_type}
    ...    whether_get_first_ru_only=${whether_get_first_ru_only}    ru_type=${ru_type}
    ...    ru_index=${ru_index}
    FOR    ${lte_cell_index}    IN    @{lte_cell_list}
        Lock Or Unlock Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=block
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Sleep    10sec
        Lock Or Unlock Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${lte_cell_index}    cell_type=${cell_type}    action=unblock
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Connect to gnb coam via ssl    connection=GNB_OAM
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${GNB_ALLOWED_FAULT}
        Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'    Check ENB On Air And Unexpect Alarm Should Not Exist
        ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
        Run Keyword And Continue On Failure    Procedures.Verify CA Basic L3 Call    ue_mode=NSA
        ...                                   ul_throughput=150M
        ...                                   dl_throughput=2500MKbits/sec
        ...                                   notbarred_cell_index=all
        ...                                   b1_select_cell_index=${PCELL_INDEX}
        ...                                   list_cell_ids=${lte_cell_index}
        ...                                   exp_status=barred
        ...                                   whether_do_lte_barred_action=${True}
        ...                                   whether_check_scell_addition=${False}
        ...                                   tput_collect_duration=60
        ...                                   ignore_time=15sec
        ...                                   target_DL_avg_percent=0.01
        ...                                   target_UL_avg_percent=0.0
        ...                                   min_DL_percent=0.00
        ...                                   min_UL_percent=0.00
        ...                                   check_scell_tput=${False}
        ...                                   scell_mapping=${None}
        ...                                   ue_index=${ue_index}
        ...                                   enb_index=${fdd_enb_index}
        Run Keyword If    ${whether_do_stop_call}    Procedures.Stop TMO L3 Call And Detach    ue_index=${ue_index}     ue_type=${ue_type}
    END

Unlock Cells On Special RU
    [Documentation]    Author: lei.jia@nokia-sbell.com
    [Arguments]    ${ru_type}=AEHC   ${cell_type}=nr    ${timeout}=300    ${action}=unlock
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ...            ${ru_index}=0    ${whether_get_first_ru_only}=${True}
    log    ${enb_connection}
    ${cell_list}    Get Cell List For Special RU    cell_type=${cell_type}    whether_get_first_ru_only=${whether_get_first_ru_only}
    ...      ru_type=${ru_type}      ru_index=${ru_index}
    FOR    ${cell_index}    IN    @{cell_list}
        Lock Or Unlock Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=${action}
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
        Verify The Status Of Single Cell    cell_index=${cell_index}    cell_type=${cell_type}    action=${action}
        ...    timeout=${timeout}    gnb_index=${gnb_index}    gnb_connection=${gnb_connection}    enb_index=${enb_index}
    END

Lock Or Unlock Single Cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Jia Lei: 20230217 add block and unblock status
    [Arguments]    ${cell_index}    ${cell_type}=nr    ${action}=lock    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_index}    gnb_connection=${gnb_connection}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${4g_whether_in_gnb}    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR   ${cell_dist_name}    IN     @{cell_list}
         ${cell}    Set Variable    ${cell_dist_name.split('/')[-1]}
         ${cell_idx}    Set Variable    ${cell.split('-')[-1]}
         ${distname}     Set Variable If    '${cell_index}'=='${cell_idx}'    ${cell_dist_name}    ${None}
         Exit For Loop If 	'${distname}' != '${None}'
    END
    Run Keyword If    '${action}'=='lock'
    ...        coam.lock    dist_name=${distname}    timeout=${timeout}    connection=${connection}
    ...    ELSE IF    '${action}'=='block'
    ...        coam.block    dist_name=${distname}    timeout=${timeout}    connection=${connection}
    ...    ELSE IF    '${action}'=='unlock'
    ...        coam.unlock    dist_name=${distname}    timeout=${timeout}    connection=${connection}
    ...    ELSE IF    '${action}'=='unblock'
    ...        coam.unblock_cell    dist_name=${distname}    timeout=${timeout}    connection=${connection}
    Sleep    60s
    [Teardown]    Teardown GNB and ENB Connections

Verify The Status Of Single Cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Jia Lei: 20230217 add block and unblock status
    [Arguments]    ${cell_index}    ${cell_type}=nr    ${action}=lock    ${timeout}=300
    ...            ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_index}    gnb_connection=${gnb_connection}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If
    ...    ${4g_whether_in_gnb}    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${cell_type}'=='nr'    ${gnb_connection}
    ...    ${4g_whether_in_gnb}==${False} and '${cell_type}'!='nr'    ${enb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR   ${cell_dist_name}    IN     @{cell_list}
         ${cell}    Set Variable    ${cell_dist_name.split('/')[-1]}
         ${cell_idx}    Set Variable    ${cell.split('-')[-1]}
         ${distname}     Set Variable If    '${cell_index}'=='${cell_idx}'    ${cell_dist_name}    ${None}
         Exit For Loop If 	'${distname}' != '${None}'
    END
    ${result}    Run Keyword And Return Status    Should Contain Any    ${stream_version}    12.400    14.400    22R1    22R2    21B
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${unlocked}    Set Variable If    '${cell_type}'=='nr' or '${cell_type}'=='gsm'    Unlocked    unlocked
    ${locked}    Set Variable If    '${cell_type}'=='nr' or '${cell_type}'=='gsm'    Locked    locked
    ${operationalState}    Set Variable If    '${action}'=='lock' or '${action}'=='block'    ${disabled}    ${enabled}
    ${administrativeState}    Set Variable If    '${action}'=='lock'    ${locked}    ${unlocked}
    ${blockingState}    Set Variable If    '${action}'=='block'    Blocked    Unblocked
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    FOR    ${item}    IN    @{cell_info}
        ${cell_status}    Run Keyword If    '${item['id']['configuration']}'=='${distname}'    Set Variable    ${item['status']}
        Exit For Loop If    '${item['id']['configuration']}'=='${distname}'
    END
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_status['operationalState']}    ${operationalState}
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_status['administrativeState']}    ${administrativeState}
    Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_status['blockingState']}    ${blockingState}
    [Teardown]    Teardown GNB and ENB Connections

Get All NR And LTE CellID List Of One Special RU
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param ${ru_type}:value like: "AEHC"
    ...                :param ${ru_index}: 0 means first AEHC, 1 means second AEHC, etc...
    [Arguments]    ${ru_index}=0    ${ru_type}=AEHC
    ${nr_cell_list}    Get Cell List For Special RU    cell_type=nr    ru_type=${ru_type}
    ...                                                ru_index=${ru_index}    whether_get_first_ru_only=${True}
    ${lte_cell_list}    Get Cell List For Special RU    cell_type=lte    ru_type=${ru_type}
    ...                                                 ru_index=${ru_index}    whether_get_first_ru_only=${True}
    Sort List    ${nr_cell_list}
    Sort List    ${lte_cell_list}
    [Return]    ${nr_cell_list}    ${lte_cell_list}

Do Type Cell Action Then Verify Status And Alarm
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    ...                ${cell_action}:value can be "locked"  or "unlocked"
    ...                ${cell_index}: value can be "None" means for all cells, if not "None" means for special cell
    [Arguments]    ${cell_index}    ${cell_action}=locked    ${cell_type}=nr
    ...            ${gnb_id}=0    ${enb_index}=${0}    ${is_check_cell_onAir}=${False}
    Do All Type Cells Action And Verify Status    cell_type=${cell_type}    gnb_id=${gnb_id}    enb_index=${enb_index}
    ...                                           cell_id=${cell_index}    cell_action=${cell_action}
    Check GNB On Air And Unexpect Alarm Should Not Exist    is_check_cell_onAir=${is_check_cell_onAir}
    Check ENB On Air And Unexpect Alarm Should Not Exist    is_check_cell_onAir=${is_check_cell_onAir}

Loop For Do Type Cell Action Then Verify Status And Alarm
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_list}    ${list_index}    ${cell_action}=locked    ${cell_type}=nr
    ...            ${gnb_id}=0    ${enb_index}=${0}    ${is_check_cell_onAir}=${False}
    ${length}    Get Length    ${cell_list}
    FOR    ${i}    IN RANGE    ${length}
        ${cell_id}    Remove From List    ${cell_list}    ${list_index}
        Do Type Cell Action Then Verify Status And Alarm    cell_index=${cell_id}    cell_action=${cell_action}
        ...                                                 cell_type=${cell_type}    gnb_id=${gnb_id}
        ...                                                 enb_index=${enb_index}    is_check_cell_onAir=${is_check_cell_onAir}
    END

Check All Cells Should Be On Air Except One Locked Cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_id}    ${gnb_id}=0    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    3min    2sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
    Wait Until Keyword Succeeds    20min    2sec    COAM Check GNB ABIL status    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    COAM Check GNB ASIK status    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    COAM Check GNB RU status    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    Verify all cells should be onair Except One Cell
    ...    cell_id=${cell_id}    connection=${connection}
    ${gnb_type}    Get gNbType SA or NSA via rest api    connection=${connection}
    Run Keyword If    'NSA' in '${gnb_type}'
    ...    Wait Until Keyword Succeeds    20min    2sec    COAM Check X2 link status from GNB    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    Verify Gnb Type Cells Should Be Onair    cell_type=lte    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    Verify Gnb Type Cells Should Be Onair    cell_type=wcdma    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    Verify Gnb Type Cells Should Be Onair    cell_type=gsm    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Verify all cells should be onair Except One Cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_id}    ${cell_type}=nr    ${connection}=GNB_OAM
    Log To Console    Verify all cells are on air except ${cell_id}
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${unlocked}    Set Variable If    ${result}==${False} and '${cell_type}'=='lte'    unlocked    ${unlocked}
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        ${cell_index}    Set Variable    ${cell['id']['configuration'].split('-')[-1]}
        ${admin_state}    Set Variable If    '${cell_index}'=='${cell_id}'    Locked     ${unlocked}
        ${opera_state}    Set Variable If    '${cell_index}'=='${cell_id}'    disabled     ${enabled}
        Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['administrativeState']}     ${admin_state}
        Run keyword and continue on failure    Should be equal as strings    ${cell['status']['operationalState']}    ${opera_state}
        run keyword if    ${result}    Run keyword and continue on failure
        ...    Should Be Equal As Strings    ${cell['status']['availabilityStatus']}   Online
    END

Check All Cells Should Be On Air Except Special RU Related Cells
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${ru_type}=AHFIG    ${cell_type}=nr     ${gnb_id}=0    ${connection}=GNB_OAM
    ${special_nr_cell_list}    Get Cell List For Special RU    cell_type=${cell_type}    ru_type=${ru_type}
    Wait Until Keyword Succeeds    3min    2sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
    Wait Until Keyword Succeeds    20min    2sec    COAM Check GNB ABIL status    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    COAM Check GNB ASIK status    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    COAM Check GNB RU status    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    Verify all cells should be onair Except Special RU Related Cells
    ...    special_nr_cell_list=${special_nr_cell_list}    connection=${connection}
    ${gnb_type}    Get gNbType SA or NSA via rest api    connection=${connection}
    Run Keyword If    'NSA' in '${gnb_type}'
    ...    Wait Until Keyword Succeeds    20min    2sec    COAM Check X2 link status from GNB    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    Verify Gnb Type Cells Should Be Onair    cell_type=lte    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    Verify Gnb Type Cells Should Be Onair    cell_type=wcdma    connection=${connection}
    Wait Until Keyword Succeeds    20min    2sec    Verify Gnb Type Cells Should Be Onair    cell_type=gsm    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Verify all cells should be onair Except Special RU Related Cells
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${special_nr_cell_list}    ${cell_type}=nr    ${connection}=GNB_OAM
    Log To Console    Verify all cells are on air except ${special_nr_cell_list}
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    FOR    ${cell}    IN    @{cells_info}
        ${cell_index}    Set Variable    ${cell['id']['configuration'].split('-')[-1]}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${special_nr_cell_list}    ${cell_index}
        ${opera_state}    Set Variable If    ${status}     disabled     ${enabled}
        Run keyword and continue on failure    Should be equal as strings    ${cell['status']['operationalState']}    ${opera_state}
    END

######2023.11.14  copy from 8360 for Guanghetong chips
Deployment SA And NSA Mode For 2UE Module
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...    para:${ue_mode}  value can be "NSA or SA"
    ...    please note, for SA mode, select ${nettpye}=SA+NSA; for NSA mode, select ${nettpye}=NSA
    [Arguments]    ${ue_mode}=SA      ${ue_index}=${0}
    ...            ${apn_address}=dxdata1
    log    ${apn_address}
    ${nettpye}    Set Variable If    '${ue_mode}'=='NSA'     NSA    SA+NSA
    Log To Console    \nStart to deployment UE${ue_index} to ${ue_mode} Mode.
    spark.config_5g_deployment    nettype=${nettpye}    ue_alias=UE_${ue_index}

Change Network Mode Between SA And NSA For 2UE Module
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...    para:${ue_mode}  value can be "NSA or SA"
    [Arguments]    ${ue_mode}    ${ue_index}=${0}     ${ue_alias}=UE_${ue_index}
    Run Keyword If   '${ue_mode}'=='NSA'    Run Keywords
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTSET="5GSACTR",0    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTACT=17    AND
    ...               Sleep    5s    AND
    ...               run keyword and ignore error    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=at+cfun=0    AND
    ...               Sleep    5s     AND
    ...               run keyword and ignore error    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=at+cfun=1    AND
    ...               Sleep    20s    AND
    ...               run keyword and ignore error    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=at$qcrmcall=1,1    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTAUTOCONNECT=0        AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+CGATT=0    AND
    ...               Sleep    5s
    Run Keyword If   '${ue_mode}'=='SA'    Run Keywords
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTSET="5GSACTR",1    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTACT=14    AND
    ...               Sleep    5s    AND
    ...               run keyword and ignore error    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=at+cfun=0    AND
    ...               Sleep    5s     AND
    ...               run keyword and ignore error    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=at+cfun=1    AND
    ...               Sleep    20s    AND
    ...               run keyword and ignore error    spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=at$qcrmcall=1,1    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTAUTOCONNECT=0        AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+CGATT=0    AND
    ...               Sleep    5s

# common keyword for 8UE module
Change Network Mode Between SA And NSA For 8UE Module
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    ...    para:${ue_mode}  value can be "NSA or SA"
    [Arguments]    ${ue_mode}  ${ue_index}=${0}     ${ue_alias}=UE_${ue_index}
    Run Keyword If   '${ue_mode}'=='NSA'    Run Keywords
    ...               spark.power_off    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.power_on    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTSET="5GSACTR",0    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTACT=10    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTACT=17    AND
    ...               Sleep    5s     AND
    ...               spark.power_off    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.power_on    ue_alias=${ue_alias}    AND
    ...               Sleep    5s
    Run Keyword If   '${ue_mode}'=='SA'    Run Keywords
    ...               spark.power_off    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.power_on    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTSET="5GSACTR",1    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTACT=10    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+GTACT=14    AND
    ...               Sleep    5s     AND
    ...               spark.power_off    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.power_on    ue_alias=${ue_alias}    AND
    ...               Sleep    5s

Change Network Mode Between SA And NSA and LTE For 8UE X65 Module
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    ...    para:${ue_mode}  value can be "NSA or SA"
    [Arguments]    ${ue_mode}  ${ue_index}=${0}     ${ue_alias}=UE_${ue_index}
    Run Keyword If   '${ue_mode}'=='NSA'    Run Keywords
    ...               spark.power_off    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.power_on    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+QNWPREFCFG="mode_pref",LTE:NR5G    AND
    ...               Sleep    5s     AND
    ...               spark.power_off    ue_alias=${ue_alias}    AND
    ...               Sleep    5s
    Run Keyword If   '${ue_mode}'=='SA'    Run Keywords
    ...               spark.power_off    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.power_on    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+QNWPREFCFG="mode_pref",NR5G    AND
    ...               Sleep    5s     AND
    ...               spark.power_off    ue_alias=${ue_alias}    AND
    ...               Sleep    5s
    Run Keyword If   '${ue_mode}'=='LTE'    Run Keywords
    ...               spark.power_off    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.power_on    ue_alias=${ue_alias}    AND
    ...               Sleep    5s     AND
    ...               spark.send_AT_command_CPE     ue_alias=${ue_alias}   param=AT+QNWPREFCFG="mode_pref",LTE    AND
    ...               Sleep    5s     AND
    ...               spark.power_off    ue_alias=${ue_alias}    AND
    ...               Sleep    5s


##--- 4G keywords for case steps---#
#Procedures.Verify Non-CA 4G L3 Call
#    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
#    [Arguments]   ${not_barried_lte_cell}   ${expect_dl_tput}=100   ${ignore_time}=15sec   ${ue_index}=${0}
#    ...           ${dl_throughput}=2500MKbits/sec   ${gnb_index}=0   ${du_index}=0   ${timeout}=${300}
#    ...           ${connection}=GNB_OAM    ${start_keep_on_duration}=1200   ${tput_collect_duration}=300
#    ...           ${ul_throughput}=50M     ${iperf_path}=/data/local/tmp/iperf      ${expect_ul_tput}=10
#    ...           ${process_num}=${2}     ${detach_request}=${true}    ${power_reset}=False
#    ${dl_throughput}    Convert Dl Tput based on Process num    process_num=${process_num}    dl_throughput=${dl_throughput}
#    Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=${not_barried_lte_cell}    exp_status=notBarred
#    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
#    ${gnb_nr_cell_id_mapping}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection}
#    ${all_cell_ids}    Get dictionary keys    ${gnb_nr_cell_id_mapping}
#    @{params_for_update}    Create list
#    FOR    ${cell_index}    IN    @{all_cell_ids}
#        ${dist_name}    set variable    MRBTS-${tl.gnbs[${0}].instance_id}/NRBTS-${tl.gnbs[${0}].global_bts_id}/NRCELL-${cell_index}
#        ${param}    create dictionary    dist_name=${dist_name}    parameter=cellBarred    value=barred
#        Append to list    ${params_for_update}    ${param}
#    END
#    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}    timeout=${timeout}
#    ...    connection=${connection}
#    Procedures.Start UE Prepare    ue_index=${ue_index}    detach_request=${true}      power_reset=true
#    Run Keyword And Ignore Error    spark.send_AT_command_CPE     ue_alias=UE_${ue_index}   param=AT+CFUN=0
#    Run Keyword And Ignore Error    spark.send_AT_command_CPE     ue_alias=UE_${ue_index}   param=AT+CFUN=1
#    Run Keyword And Continue On Failure      Change Network Mode Between SA And NSA For 8UE Module
#    ...                                         ue_mode=NSA   ue_index=${ue_index}
#    &{master_config}   create dictionary
#    ...    host=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
#    ...    user=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
#    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
#    Set Test Variable    ${executor_oam_vm}    ${master_config}
#    Set Test Variable    ${tcpdump_collector_name}    cpif_tcpdump
#    tcpdump.create_tcpdump_collector    name=${tcpdump_collector_name}
#    ...                                 options=-i any
#    ...                                 executor=${executor_oam_vm}
#    ...                                 container=CPIF
#    tcpdump.Set Suite Alias    ${tcpdump_collector_name}
#    core.setup_collectors    names=${tcpdump_collector_name}
#    core.start_collectors    names=${tcpdump_collector_name}
#    Log to console   start to attach
#    Procedures.Start UE Prepare    ue_index=${ue_index}    detach_request=${true}      power_reset=true
#    power_ue.UE Attach    ue_index=${ue_index}    power_reset=true
#    ${attach_time}    DateTime.Get Current Date    result_format=%Y-%m-%d%H:%M:%S
#    Sleep    15sec
#    ${cpif_attach_log_on_testPC}    Run Keyword And Continue On Failure    Stop tcpdump log collection
#    ...    tcpdump_collector_name=${tcpdump_collector_name}
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    ${attach_cell_index}   Get 4G Attach Cell Index From Wireshark   cpif_log_path=${cpif_attach_log_on_testPC}
#    ...                    enb_index=${fdd_enb_index}
#    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${attach_cell_index}    ${not_barried_lte_cell}
#    ${ue_ip_dict}    Wait Until Keyword Succeeds    3X    10sec    Get ALL PDU IP Address From Wireshark
#    ...    cpif_log_path=${cpif_attach_log_on_testPC}    mode=NSA
#    ${ul_throughput}   Run Keyword If    '${ue_type}'=='huawei_sigspark'
#    ...                                  Replace String      ${ul_throughput}      M        MKbits/sec
#    ...                ELSE   Set Variable   ${ul_throughput}
#    ${iperf_path}    Set Variable If    '${ue_type}'=='mtk' or '${ue_type}'=='samsung'    ${iperf_path}    iperf
#    Run Keyword If    '${ue_type}'=='huawei_sigspark'   power_ue.Start traffic
#    ...                                                      ue_type=${ue_type}
#    ...                                                      direction=ul
#    ...                                                      throughput=${ul_throughput}
#    ...                                                      duration=${start_keep_on_duration}
#    ...                                                      dt_name=DT_ul
#    ...                                                      apn_address=${apn_address}
#    ...                                                      ue_mode=NSA
#    ...                                                      ue_index=${ue_index}
#    ...     ELSE     traffic_via_iperf.Start UL traffic via iperf from andriod UE
#    ...                                        ue_index=${ue_index}
#    ...                                        ul_time=${start_keep_on_duration}
#    ...                                        ul_port=${56583}
#    ...                                        ul_throughput=${ul_throughput}
#    ...                                        ul_length=1400B
#    ...                                        appserver=APPserver
#    ...                                        protocol=udp
#    ...                                        iperf_path=${iperf_path}
#    ...                                        process_num=${1}
#    Start DL traffic via iperf on Appserver    ue_addr=${ue_ip_dict['data']}
#    ...                                                       dl_time=${start_keep_on_duration}
#    ...                                                       dl_port=${56883}
#    ...                                                       dl_throughput=${dl_throughput}
#    ...                                                       dl_length=1400B
#    ...                                                       appserver=APPserver
#    ...                                                       protocol=udp
#    ...                                                       ue_index=${ue_index}
#    ...                                                       process_num=${process_num}
#    ...                                                       seg_size=${1372}
#    ...                                                       window=2M
#    Check 4G Tput With Power UE    expect_dl_tput=${expect_dl_tput}
#    ...                            expect_ul_tput=${expect_ul_tput}
#    ...                            ignore_time=${ignore_time}
#    ...                            duration=${tput_collect_duration}
#    [Teardown]    Run keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections   AND
#    ...                           Run Keyword And Ignore Error    Csn.disconnect      connection=ASIK Master  AND
#    ...    Run Keyword And Ignore Error   Change Network Mode Between SA And NSA For 8UE Module   ue_mode=SA   ue_index=${ue_index}

Verify Whether FID10 Triggered On Enb
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    ...    In config.ini: need to  activate 'Monitoring_stop_with_file = stop_mon.log'
    [Arguments]    ${cell_index}=${12}
    ...            ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${gnb_index}=0
    ...            ${enb_index}=0
    ...            ${du_index}=0
    ...            ${connection}=GNB_OAM
    ...            ${timeout}=600
    ...            ${target_dir}=/home/ute/syslog
    log many    ${connection}    ${timeout}    ${target_dir}
    Log To Console    \***start to collect syslog***\
    ${enb_ip}    Set Variable    ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
#    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    ssh.send command    command=cd ${gnb_logs_script_path}/run&&rm syslog.tar.gz   connection=ute
#    ssh.send command    command=cd ${target_dir}&&rm syslog.tar.gz   connection=ute
    ${start_capture_command}     Catenate    ./gnb_logs ${enb_ip} -s -c5
#    ${start_capture_command}     Catenate    ./gnb_logs ${gnb_ip} -s -c5
    ssh.send command    command=cd ${gnb_logs_script_path}&&./${start_capture_command}   connection=ute
    sleep    10s
    Log To Console    \***start to one FDD RU in gnb***\
    Generate Pcell Mapping Info    pcell_index=${cell_index}
    ${ru_index}    Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    ${model}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].pdu_port.pdu.__class__.__name__}
    ${ru_pdu_ip}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].pdu_port.pdu.addr}
    ${ru_pdu_port}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].pdu_port.port_no}
    ${status}    Run Keyword And Return Status   Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type.value}
    ${ru_type}    Set Variable If    ${status}    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type.value}
    ...                                           ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type}
    pdu.setup_pdu    model=${model}   host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}
    pdu.power_off    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}
    sleep  200s
    pdu.setup_pdu    model=${model}   host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}
    pdu.power_on    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}
    Check TMO Gnb Ready And All Cell On Air
    Log To Console    \***stop collect syslog***\
    ssh.send command    command=pkill -9 gnb_logs    connection=ute
#    ssh.send command    command=cd ${gnb_logs_script_path}&&touch ./stop_mon.log   connection=ute
    ssh.send command    command=cd ${gnb_logs_script_path}/run&&tar czvf syslog.tar.gz BTS_SYSLOG   connection=ute
#    ssh.send command    command=cp ${gnb_logs_script_path}/run/syslog.tar.gz ${target_dir}    connection=ute
#    Copy Files    ${gnb_logs_script_path}/run/syslog.tar.gz    ${target_dir}
    sleep    30s
    Log To Console    \***start to check sysylog***\
    ${bts_gz_command} =  set variable
        ...   gunzip -c ${gnb_logs_script_path}/run/syslog.tar.gz | grep -i 'CONNECTION_CHECK_DEST_UNREACHABLE'
    ${syslog_check_output}   RUN    ${bts_gz_command}
    ${status}    run keyword and return status    Should Not Be Empty    ${syslog_check_output}    FID 10 not triggered on enb
    Should Be True    ${status}    msg=FID 10 not find in sysylog
    [Teardown]    Run keywords    Run Keyword And Ignore Error    ssh.disconnect    connection=ute   AND
    ...        run keyword and ignore error    COAM Teardown gnb connections

Execute Memory On ENB
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${enb_index}=${0}
    ssh.Connect to    hostname=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=ENB_${enb_index}
    ${output}    ssh.execute    command=date;cat /proc/meminfo |grep VmallocUsed     connection=ENB_${enb_index}
    ${valid_lines}    Get Lines Matching Regexp    ${output}    VmallocUsed    partial_match=true
    ${valid_lines_last}    Set variable    ${valid_lines.split(':')[-1]}
    ${VmallocUsed_value}     Set variable    ${valid_lines_last.split(' ')[-2]}
    [Return]     ${VmallocUsed_value}
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=ENB_${enb_index}

Modify Lss IP Adsress Paremeters
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${enb_index}=${0}
    ...            ${connection}=enblte
    ...            ${diagSnapDestination}=lss
    ...            ${actDefaultFaultSnapTriggers}=true
    ...            ${lssIPaddress}=10.38.198.255
    ...            ${timeout}=300
    Wait Until Keyword Succeeds   1 min   5 sec   Connect to eNB via ssl   enb_index=${enb_index}   connection=${connection}
    ${output}   coam.get_parameters_for_all    class_name=BTS    connection=${connection}
    ${btsid}    Set Variable   ${output[0]['btsId']}
    ${diagSnapDestination}    Create Dictionary    dist_name=MRBTS-${btsid}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                             parameter=diagSnapDestination
    ...                                             value=${diagSnapDestination}
    ${actDefaultFaultSnapTriggers}    Create Dictionary    dist_name=MRBTS-${btsid}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                                    parameter=actDefaultFaultSnapTriggers
    ...                                                    value=${actDefaultFaultSnapTriggers}
    &{value}   Create Dictionary   lssIPaddress=${lssIPaddress}
    ${lssIPaddress}     Evaluate
    ...    {'dist_name': 'MRBTS-${btsid}/MNL-1/MNLENT-1/TRBLCADM-1', 'parameter': 'lssConfig','value':[&{value}]}
    @{param_list}    Create List    ${diagSnapDestination}    ${actDefaultFaultSnapTriggers}   ${lssIPaddress}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}    timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    Enblte close down    connection=${connection}

Recover Collect Syslog On GNB
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    ...   after L3 call, execute  keyword to recover collecting syslog on control pc
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${type}=MCU
    ...    ${aa_sys_mode}=5    ${aa_sys_addr}=0xC0A8FF7E    ${aa_sys_udp_port}=0xC738
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${response}    Wait until keyword succeeds    60s    500ms    aasyslog realtime output configuration
    ...    host=${host}    username=${username}    password=${password}    type=${type}
    ...    aa_sys_mode=${aa_sys_mode}    aa_sys_addr=${aa_sys_addr}    aa_sys_udp_port=${aa_sys_udp_port}
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect   connection=${connection}

Delete CA Relation Based On CellIndex
    [Arguments]    ${pcell_index}=${PCELL_INDEX}
    ...            ${gnb_index}=${0}
    ...            ${connection}=GNB_OAM${gnb_index}
    ...            ${reserve_cell_indexs}=${${21}}
    ...            ${delete_all}=${True}
    log many    ${reserve_cell_indexs}    ${delete_all}
#    ${reserve_cell_indexs_type}    Evaluate    type(${reserve_cell_indexs}).__name__
#    ${convert_reserve_cell_indexs_to_list}    Create List    ${reserve_cell_indexs}
#    ${reserve_cell_indexs}    Set Variable If    'list' in '${reserve_cell_indexs_type}' or 'tuple' in '${reserve_cell_indexs_type}'
#    ...      ${reserve_cell_indexs}     ${convert_reserve_cell_indexs_to_list}
#    ${empty_list}    Create List
#    ${reserve_cell_indexs}    Set Variable If   ${delete_all}    ${empty_list}    ${reserve_cell_indexs}
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_index}].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_index}].global_bts_id}
    Get Pcell And Scell Mapping Info    pcell_index=${pcell_index}    source_gnb_id=${gnb_index}
    ${scell_mapping_items}    Get Dictionary Values     ${SCELL_MAPPING}
#    ${NRREL_indexs}    Evaluate    [x[1]['nrrel_id'] for x in ${scell_mapping_items} if x[0] not in ${reserve_cell_indexs}]
    ${NRREL_indexs}    Evaluate    [x['nrrel_id'] for x in ${scell_mapping_items}]
    ${all_delete_list}    Create List
    FOR   ${nrrel_id}   IN    @{NRREL_indexs}
        ${delete_params}    catenate
        ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${pcell_index}/NRREL-${nrrel_id}',
        ...    'parameter':'sCellOperationalMode'},
        ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${pcell_index}/NRREL-${nrrel_id}',
        ...    'parameter':'sCellAdditionMethod'},
        ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${pcell_index}/NRREL-${nrrel_id}',
        ...    'parameter':'sCellPrio'}
        ${delete_scell}    Evaluate     [${delete_params}]
        ${all_delete_list}    Combine Lists   ${delete_scell}    ${all_delete_list}
    END
    Delete Params Through RestApi    parameters_to_delete_via_api=${all_delete_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Reset UE Control PC If Connect Failed
    [Documentation]  To reset te UE control pc which is windows system.
    [Arguments]    ${ue_index}=${0}
    ${status}   Run Keyword And Return Status    Connect to control pc enhanced    ${ue_index}
    Run Keyword If   '${status}'==‘${False}’    csn.Send Command    command=shutdown -r -t 3
    ...     connection=cpc_${ue_index}    timeout=5
    Run Keyword If   '${status}'==‘${False}’    Wait Until Keyword Succeeds    10min    20sec
    ...    Connect to control pc enhanced    ${ue_index}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect      connection=cpc_${ue_index}

Login To WEBUI With Selenium
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}
    ...            ${timeout}=${120}
    ...            ${gnb_index}=${0}
    ...            ${url}=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...            ${version}=SBTS23R4
    ...            ${browser}=Chrome
    ...            ${login_loop}=${3}
    ${btsName}    ${gnb_version}     Get BtsName and SwVersion    gnb_id=${gnb_index}    connection=GNB_OAM${gnb_index}
    ${version}    Set Variable    ${gnb_version.split('_')[0]}
    selenium_coam.enable_virtual_display
    Wait Until Keyword Succeeds    ${login_loop}x    10s    selenium_coam.login    url=${url}
    ...                                                                            username=${username}
    ...                                                                            password=${password}
    ...                                                                            download_dir=${download_dir}
    ...                                                                            timeout=${timeout}
    ...                                                                            version=${version}
    ...                                                                            browser=${browser}
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock

Check SIB8 Scheduling in SIB1
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${bip_log}    ${cellid}=${0}
    ...            ${filter}=nr-rrc
    ...            ${alias}=parser
    ...            ${connection}=GNB_OAM
    log    ${cellid}
    Convert CPIF Pcap To Pdml       file_path=${bip_log}    filter=${filter}    alias=${alias}
    ${value}    Get Field Value From Pdml
    ...    xpath=.//_[1]/nr-rrc.SchedulingInfo_element/nr-rrc.sib_MappingInfo/_[1]/nr-rrc.SIB_TypeInfo_element/nr-rrc.type
    ...    filter_expression=nr-rrc.c1 == 1 and nr-rrc.type == 6
    should not be empty    ${value}
    ${sib_periodicity}   Get Field Value From Pdml   xpath=.//_[2]/nr-rrc.SchedulingInfo_element/nr-rrc.si_Periodicity
    ...    filter_expression=nr-rrc.c1 == 1 and nr-rrc.type == 6
    ${sib_periodicity}    Convert To Integer    ${sib_periodicity[0]}
    @{periodicity_para_list}    create list
    @{periodicity_value_list}    create list
    @{periodicity_value_list1}    create list
    @{periodicity_value_list2}    create list
    @{periodicity_value_list3}    create list
    @{periodicity_value_list4}    create list
    &{periodicitydict}    Create Dictionary    sibType=sibType2    sibPeriodicity=None
    &{periodicitydict1}    Create Dictionary    sibType=sibType3    sibPeriodicity=None
    &{periodicitydict2}    Create Dictionary    sibType=sibType4    sibPeriodicity=None
    &{periodicitydict3}    Create Dictionary    sibType=sibType5    sibPeriodicity=None
    &{periodicitydict4}    Create Dictionary    sibType=sibType8    sibPeriodicity=None
    Append To List   ${periodicity_value_list}   ${periodicitydict}  ${periodicitydict1}  ${periodicitydict2}
    ...                                          ${periodicitydict3}  ${periodicitydict4}
    &{sibPeriodicityList_dict}    Create Dictionary
    ...                  dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRSYSINFO_PROFILE-1
    ...                  parameter=sibSchedulingList
    ...                  value=${periodicity_value_list}
    Append To List   ${periodicity_para_list}   ${sibPeriodicityList_dict}
    Connect to gnb coam via ssl    connection=${connection}
    ${status}   ${sibPeriodicity_list}   Run keyword and ignore error   coam_parameter.get_list_values_from_scf_file
    ...                   parameters=${periodicity_para_list}
    ...                   connection=${connection}
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    @{sib8_periodicity_list}    Create List    8    16    32    64
    Set Test Variable   ${sibPeriodicity_value}   ${sibPeriodicity_list[0]}[value]
    Set Test Variable   ${coam_periodicity}  ${sibPeriodicity_value[4]}[sibPeriodicity]
    Should be Equal    rf${sib8_periodicity_list}[${sib_periodicity}]    ${coam_periodicity}
    [Return]    ${sib8_periodicity_list}[${sib_periodicity}]

Compare WMC and WAC in SIB8
    [Arguments]    ${bip_log}    ${filter_expression}    ${wmc}    ${wac}   ${alias}=parser
    Convert CPIF Pcap To Pdml   file_path=${bip_log}   filter=nr-rrc.sib_TypeAndInfo_item == 6
    pcap.filter_packets_by_expression    filter_expression=${filter_expression}   pcap_parser=${alias}
    @{segment_num}    pcap.get_field_value_by_name    field_name=nr-rrc.warningMessageSegmentNumber   pcap_parser=${alias}
    Sort List    ${segment_num}
    ${segment_num_new}    Convert To Integer    ${segment_num}[-1]
    ${segment_num_latest}    Evaluate    ${segment_num_new} + 1
    FOR  ${item}  IN RANGE  ${segment_num_latest}
        Convert CPIF Pcap To Pdml    file_path=${bip_log}   filter=nr-rrc.sib_TypeAndInfo_item == 6
        pcap.filter_packets_by_expression    filter_expression=${filter_expression} and nr-rrc.warningMessageSegmentNumber==${item}
        ...                                  pcap_parser=${alias}
        ${value_wmc}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.warningMessageSegment   pcap_parser=${alias}
        ${value_wac}    pcap.get_field_value_by_name    field_name=nr-rrc.warningAreaCoordinatesSegment   pcap_parser=${alias}
        ${status}    ${value}    Run Keyword And Ignore Error    Should Not Be Empty    ${value_wac}
        ${sib8_wmc}    Set Variable If    ${item} == 0    ${value_wmc[0]}    ${sib8_wmc}:${value_wmc[0]}
        Run Keyword If    '${status}' == 'FAIL'    Continue For Loop
        ${sib8_wac}    Set Variable If    ${item} == 0    ${value_wac[0]}    ${sib8_wac}:${value_wac[0]}
    END
    Should be Equal    ${sib8_wmc}    ${wmc}
    Should be Equal    ${sib8_wac}    ${wac}

Check UE Log for SIB8
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${wmc}
    ...            ${wac}
    ...            ${ue_index}=${0}
    ...            ${serial_number}=${default_serial_number}
    ...            ${message_identifier}=${default_message_identifier}
    ${wmc}    Remove String    ${wmc}    :
    ${wac}    Remove String    ${wac}    :
    spark.read_log    logname=${TS_CASE_LOG_PATH}/uelog_sigspark_UE${ue_index}.xml
    ${spark_messageIdentifier}    spark.get_expected_val    msg=NR SystemInformationBlocks    expression=messageIdentifier
    ${spark_messageIdentifier}    Convert To Integer    ${spark_messageIdentifier}
    ${spark_messageIdentifier}    Convert To String    ${spark_messageIdentifier}
    ${message_identifier}    Convert To Binary    ${message_identifier}
    ${spark_serialnumber}    spark.get_expected_val    msg=NR SystemInformationBlocks    expression=serialNumber
    ${spark_serialnumber}    Convert To Integer    ${spark_serialnumber}
    ${spark_serialnumber}    Convert To String    ${spark_serialnumber}
    ${serial_number}    Convert To Binary    ${serial_number}
    ${spark_segment_num}    spark.get_expected_val    msg=NR SystemInformationBlocks    expression=warningMessageSegmentNumber    type=all
    Sort List    ${spark_segment_num}
    ${spark_segment_num}    Convert To Integer    ${spark_segment_num}[-1]
    ${spark_segment_num}    Evaluate    ${spark_segment_num} + 1
    ${spark_segment}    spark.get_expected_val    msg=NR SystemInformationBlocks    expression=warningMessageSegment    type=all
    ${spark_segment}    Remove Duplicates    ${spark_segment}
    ${spark_wmc}    Set Variable
    ${spark_area}    spark.get_expected_val    msg=NR SystemInformationBlocks    expression=warningAreaCoordinatesSegment    type=all
    ${spark_area}    Remove Duplicates    ${spark_area}
    ${spark_area_num}    Get Length    ${spark_area}
    ${spark_wac}    Set Variable
    FOR  ${item}  IN RANGE  ${spark_segment_num}
        ${segment}    Remove String    ${spark_segment[${item}]}    \n
        ${segment}    Remove String    ${segment}    ${SPACE}
        ${spark_wmc}    Set Variable    ${spark_wmc}${segment}
    END
    FOR  ${item}  IN RANGE  ${spark_area_num}
        ${area}    Remove String    ${spark_area[${item}]}    ${SPACE}
        ${spark_wac}    Set Variable    ${spark_wac}${area}
    END
    ${spark_wmc}    Convert To Lower Case    ${spark_wmc}
    ${spark_wac}    Convert To Lower Case    ${spark_wac}
    ${spark_wmc}  Evaluate  '${spark_wmc.replace('\n', '')}'
    ${spark_wac}  Evaluate  '${spark_wac.replace('\n', '')}'
    Should be Equal    ${spark_wmc}    ${wmc}
    Should be Equal    ${spark_wac}    ${wac}
    Should be Equal    ${spark_messageIdentifier}    ${message_identifier}
    Should be Equal    ${spark_serialnumber}    ${serial_number}


#--- keywords for case steps---#
TOL_case_RRM_SA_1UE_LinkAdaption_TCP
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ul_throughput}=150M
    ...            ${dl_throughput}=1500MKbits/sec
    ...            ${tput_collect_duration}=120
    ...            ${whether_need_ue_log}=${False}
    ...            ${whether_check_scell_addition}=${True}
    ...            ${whether_start_ul_call}=${True}
    ...            ${whether_start_dl_call}=${True}
    ...            ${start_keep_on_duration}=2400
    ...            ${whether_check_tupt}=${False}
    ...            ${log_name}=tcp_LA
    ...            ${check_ul_pcell_tput_type}=not_peak
    ...            ${check_pcell_tput_type}=not_peak
    ...            ${check_scell_tput_type}=not_peak
    ...            ${min_DL_percent}=0.85
    ...            ${min_UL_percent}=0.85
    ...            ${min_scell_percent}=0.85
    ...            ${check_ul_pcell_tput_type_after_la}=not_peak
    ...            ${check_pcell_tput_type_after_la}=not_peak
    ...            ${check_scell_tput_type_after_la}=not_peak
    Log To Console    ${\n}INFO:-- start to do attach and start L3 call --
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Run Keyword And Continue On Failure    Procedures.Verify CA Basic L3 Call    ul_throughput=${ul_throughput}
    ...                                                                          dl_throughput=${dl_throughput}
    ...                                                                          protocol=tcp
    ...                                                                          tput_collect_duration=${tput_collect_duration}
    ...                                                                          whether_need_ue_log=${whether_need_ue_log}
    ...                                                                          whether_check_scell_addition=${whether_check_scell_addition}
    ...                                                                          whether_start_ul_call=${whether_start_ul_call}
    ...                                                                          whether_start_dl_call=${whether_start_dl_call}
    ...                                                                          start_keep_on_duration=${start_keep_on_duration}
    ...                                                                          whether_check_tupt=${whether_check_tupt}
    ...                                                                          enb_index=${fdd_enb_index}
    FOR    ${i}    IN RANGE    ${2}
        Log To Console    ${\n}INFO:-- start to do time_${i} LA action --
        TOL_case_SA_LinkAdaption_TCP_For_CA_And_Non_CA    log_name=${log_name}_${i}
        ...                                               check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
        ...                                               check_pcell_tput_type=${check_pcell_tput_type}
        ...                                               check_scell_tput_type=${check_scell_tput_type}
        ...                                               min_DL_percent=${min_DL_percent}
        ...                                               min_UL_percent=${min_UL_percent}
        ...                                               min_scell_percent=${min_scell_percent}
        ...                                               check_ul_pcell_tput_type_after_la=${check_ul_pcell_tput_type_after_la}
        ...                                               check_pcell_tput_type_after_la=${check_pcell_tput_type_after_la}
        ...                                               check_scell_tput_type_after_la=${check_scell_tput_type_after_la}
    END

TOL_case_SA_LinkAdaption_TCP_For_CA_And_Non_CA
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${log_name}=tcp_LA
    ...            ${check_ul_pcell_tput_type}=not_peak
    ...            ${check_pcell_tput_type}=not_peak
    ...            ${check_scell_tput_type}=not_peak
    ...            ${min_DL_percent}=0.85
    ...            ${min_UL_percent}=0.85
    ...            ${min_scell_percent}=0.85
    ...            ${check_ul_pcell_tput_type_after_la}=not_peak
    ...            ${check_pcell_tput_type_after_la}=not_peak
    ...            ${check_scell_tput_type_after_la}=not_peak
    Run Keyword And Continue On Failure    Procedures.Check TMO Throughput    ue_index=${0}
    ...                                                                       addition_scell_index_list=${SCELL_INDEX_LIST}
    ...                                                                       check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                                                                       check_pcell_tput_type=${check_pcell_tput_type}
    ...                                                                       check_scell_tput_type=${check_scell_tput_type}
    ...                                                                       tput_collect_duration=120
    ...                                                                       ignore_time=10sec
    ${host}   Start To Capture Aasyslog    gnb_index=${0}    du_index=${0}
    Sleep    5sec
    Run Keyword And Continue On Failure    Spark_common_keywords.Spark Start UE Log    ue_index=${0}
    ${ru_whether_connect_mcs}    Check RU Whether Connect Mcs    ru_index=${PCELL_MAPPING['ru_index_mapping']}
    FOR    ${attenuator}    IN    @{attenuator_list}
        ${modify_value}    ${modify_times}    Run Keyword If    '${attenuator}'=='pa'
        ...                    Modify PA Value By Steps For LA    origin_value=6    modify_ru_id=0    step=${1}
        ...    ELSE IF    '${attenuator}'=='mcs' and ${ru_whether_connect_mcs}
        ...                   Modify MCS Value By Steps For LA    origin_value=0    step=${1}
    END
    Sleep    3sec
    FOR    ${attenuator}    IN    @{attenuator_list}
        ${modify_value}    ${modify_times}    Run Keyword If    '${attenuator}'=='pa'
        ...        Modify PA Value By Steps For LA    origin_value=${modify_value}    times=${modify_times}    modify_ru_id=0    step=${-1}
        ...    ELSE IF    '${attenuator}'=='mcs' and ${ru_whether_connect_mcs}
        ...        Modify MCS Value By Steps For LA    origin_value=${modify_value}    times=${modify_times}    step=${-1}
    END
    Run Keyword And Ignore Error    Spark_common_keywords.Spark Stop UE Log    ue_index=${0}
    ...    log_name=${TS_CASE_LOG_PATH}/${log_name}.xml
    ${tupt_file_path}    Stop To Capture And Download Aasyslog    host=${host}
    Procedures.Check TMO Throughput    ue_index=${0}
    ...                                addition_scell_index_list=${SCELL_INDEX_LIST}
    ...                                whether_collect_tput=${False}
    ...                                tput_file_use_collected=${tupt_file_path}
    ...                                check_ul_pcell_tput_type=${check_ul_pcell_tput_type_after_la}
    ...                                check_pcell_tput_type=${check_pcell_tput_type_after_la}
    ...                                check_scell_tput_type=${check_scell_tput_type_after_la}
    ...                                min_DL_percent=${min_DL_percent}
    ...                                min_UL_percent=${min_UL_percent}
    ...                                min_scell_percent=${min_scell_percent}

General_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                The purpose of this test case is to collect Snapshot logs in WebUI
    ...                And check if RFSW logs from Radio Unit are included in Snapshot.
    [Arguments]    ${alais}=ASIK Master    ${connection}=GNB_OAM0    ${gnb_index}=${0}
    ...            ${snapshot_path}=${TS_CASE_LOG_PATH}    ${timeout}=900    ${is_get_snapshot_via_selenium}=${False}
    log    ${is_get_snapshot_via_selenium}
    Wait Until Keyword Succeeds    2 min    20 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Connect to Common Unit Master    alias=${alais}    gnb_index=${gnb_index}
    ${snapshot_log_path}    COAM Save snapshot via rest api    connection=${connection}    log_path=${snapshot_path}    timeout=1800
    ${rmod_index_list}  Get All RU Index    connection=${connection}
    ${rmod_bbmod_mapping}    gnbaction.get_rmod_bbmod_linkmode_mapping
    ${rmod_sn_mapping}    gnbaction.get_rmod_sn_mapping
    ${sn_ru_index_in_int_mapping}    gnbaction.get_sn_ru_index_in_int_mapping
    FOR    ${rmod_index}    IN    @{rmod_index_list}
        ${serial_number}    Set Variable    ${rmod_sn_mapping['${rmod_index}']}
        ${ru_index}    Set Variable    ${sn_ru_index_in_int_mapping['${serial_number}']}
#        Connect to RU Via Allocated IP    rmod_bbmod_mapping=${rmod_bbmod_mapping}
#        ...    rmod_index=${rmod_index}    ru_index=${ru_index}
#        ...    ru_alias=RU_${ru_index}    asik_alias=${alais}    connection=${connection}
#        ...    ru_username=${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.username}
#        ...    ru_password=${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.password}
        Verify RU Log Include In Snapshot    snapshot_path=${snapshot_log_path}    rmod_bbmod_mapping=${rmod_bbmod_mapping}
        ...    ru_index=${ru_index}    rmod_index=${rmod_index}    ru_alias=RU_${ru_index}    serial_number=${serial_number}
        ...                                  connection=${connection}    unzip_path=${snapshot_path}    timeout=${timeout}
        csn.disconnect  connection=RU_${ru_index}
    END
    [Teardown]  Run Keywords    Run Keyword And Ignore Error    csn.disconnect  connection=${alais}
    ...                  AND    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get RU IP Address Via File FRIps and remove incorrect ones
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    ...               Description: Get RU IP Address from log in ASIK : /rom/config/FRIps.txt
    [Arguments]   ${ru_serial_number}    ${connection}=ASIK Master
    ${get_ru_ip_command}   Set Variable   cat /rom/config/FRIps.txt
    ${output}   csn.execute   command=${get_ru_ip_command}  connection=${connection}
    @{ips}=  Split string    ${output}
    ${contained_ip_lines}    set variable
    FOR  ${item}  IN  @{ips}
      ${contains_ip}=     Run Keyword And Return Status       Should Not Contain 	${item} 	0.0.0.0
      ${contains_ru_no}    Run Keyword And Return Status
      ...    Run Keyword if   '${contains_ip}'=='${True}'    should contain    ${item}    ${ru_serial_number}
      ${contained_ip_lines}    Set Variable If    '${contains_ip}'=='${True}' and '${contains_ru_no}'=='${True}'    ${item}    ${output}
      Exit For Loop IF    '${contains_ip}'=='${True}' and '${contains_ru_no}'=='${True}'
    END
#    ${contained_ip_lines}   Get Lines Containing String   ${output}  ${ru_serial_number}   case-insensitive=${True}
    ${ru_ip_addr}  Set Variable    ${contained_ip_lines.split(';')}[2]
    [Return]   ${ru_ip_addr}

Connect to RU Via Allocated IP
    [Documentation]   Auther: jun.8.chen@nokia-sbell.com
    ...               Description: Get RU IP address In ASIK : Get RU IP Address from log in ASIK : /rom/config/FRIps.txt
    ...               2023.11.10 update Jia Lei for 0.0.0.0 in /rom/config/FRIps.txt
    [Arguments]    ${rmod_bbmod_mapping}    ${rmod_index}    ${ru_index}=${1}   ${ru_alias}=RU   ${connection}=GNB_OAM0
    ...            ${container_id}=0x1018    ${container_alias}=Container    ${fhnet_host_ip}=192.168.255.254
    ...            ${asik_alias_right}=ASIK Master Right   ${asik_alias}=ASIK Master
    ...            ${ru_username}=${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.username}
    ...            ${ru_password}=${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.password}
    ...            ${serial_number}=None
    ${ru_bbmod_mapping_lenget}    Get Length     ${rmod_bbmod_mapping['${rmod_index}']}
    ${target_rmod_index}      Set Variable If    ${ru_bbmod_mapping_lenget}==${1}     ${rmod_bbmod_mapping['${rmod_index}'][0]}
    ...                                          ${ru_bbmod_mapping_lenget}==${2}     ${rmod_bbmod_mapping['${rmod_index}'][-1]}
    ${status}    Evaluate    int(${target_rmod_index}) >= 4
#    ${status}    Evaluate    ${rmod_bbmod_mapping['${rmod_index}']} >= 4
    Run Keyword If    ${status}    ssh.Connect to    hostname=fct-4a
    ...                                              username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                                              password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                                              proxy=${asik_alias}
    ...                                              alias=${asik_alias_right}
    ${alias}    Set Variable If    ${status}    ${asik_alias_right}    ${asik_alias}
	${container_id}    Get FHNET Container ID    asik_alias=${alias}
    &{ru_info}    run keyword if    '${serial_number}'=='None'
    ...                             COAM get ru detial info by ru index     ru_index=${rmod_index}   connection=${connection}
    ${ru_serial_number}    Set Variable If    '${serial_number}'=='None'    ${ru_info['serialNumber']}    ${serial_number}
    ${ru_ip_addr}  Get RU IP Address Via File FRIps and remove incorrect ones    ru_serial_number=${ru_serial_number}
    ...                                                                          connection=${alias}
    ${output}    csn.execute    lxc-ls    connection=${alias}
    ${feature_1834_opened}    Run Keyword And Return Status    Should Contain    ${output}    ${container_id}
    Run Keyword If    ${feature_1834_opened}
    ...    Connect To RU Via FHNET Container    ru_ip_addr=${ru_ip_addr}
    ...                                         container_id=${container_id}
    ...                                         container_alias=${container_alias}
    ...                                         ru_alias=${ru_alias}
    ...                                         asik_alias=${alias}
    ...                                         fhnet_host_ip=${fhnet_host_ip}
    ...                                         ru_username=${ru_username}
    ...                                         ru_password=${ru_password}
    ...                                         ru_index=${rmod_index}
    ...                                         coam_connection=${connection}
    ...    ELSE    csn.connect to    hostname=${ru_ip_addr}
    ...                              username=${ru_username}
    ...                              password=${ru_password}
    ...                              alias=${ru_alias}
    ...                              proxy=${alias}


Delete All NRREL On CellIndex
    [Arguments]    ${cell_index}=301
    ...            ${gnb_index}=${0}
    ...            ${connection}=GNB_OAM${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_index}].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_index}].global_bts_id}
    ${cur_scf}    coam_parameter.get_current_scf_configuration_file    connection=${connection}
    ${ret}    Grep File    ${cur_scf}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRREL.*-\\d+    regexp=True
    ${objects}    Get Regexp Matches      ${ret}      MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRREL.*-\\d+
    log to console    ${objects}
    ${params_list}    Create List
    FOR    ${item}    IN     @{objects}
        ${params_dict}    Create Dictionary
        Set To Dictionary    ${params_dict}    dist_name    ${item}
        Append To List    ${params_list}    ${params_dict}
    END
    ${deleta_delta}    coam_parameter.create_delete_objects_delta    parameters=${params_list}    connection=${connection}
    log to console    ${deleta_delta}
    coam_parameter.perform_scf_delta_commission    delta_file=${deleta_delta['updated']}    connection=${connection}    timeout=240
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Set All NR Cell To Barred Status
    [Arguments]    ${gnb_index}=${0}
    ...            ${connection}=GNB_OAM${gnb_index}
    csn.reset_cache
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_index}].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_index}].global_bts_id}
    ${cur_scf}    coam_parameter.get_current_scf_configuration_file    connection=${connection}
    ${ret}    Grep File    ${cur_scf}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-\\d+   regexp=True
    ${objects}    Get Regexp Matches      ${ret}      MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-\\d+
    log to console    ${objects}
    ${params_list}    Create List
    FOR    ${item}    IN     @{objects}
        ${params_dict}    Create Dictionary
        Set To Dictionary    ${params_dict}    dist_name    ${item}    parameter    cellBarred    value   barred
        Append To List    ${params_list}    ${params_dict}
    END
    ${update_delta}    coam_parameter.create_update_parameters_delta    parameters=${params_list}    connection=${connection}
    log to console    ${update_delta}
    coam_parameter.perform_scf_delta_commission    delta_file=${update_delta['updated']}    connection=${connection}    timeout=240
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Set All LTE Cell To Barred Status
    [Arguments]    ${gnb_index}=${0}
    ...            ${connection}=GNB_OAM${gnb_index}
    csn.reset_cache
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_index}].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_index}].global_bts_id}
    ${cur_scf}    coam_parameter.get_current_scf_configuration_file    connection=${connection}
    ${ret}    Grep File    ${cur_scf}    MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}1/LNCEL-\\d+/SIB-0   regexp=True
    ${objects}    Get Regexp Matches      ${ret}      MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}1/LNCEL-\\d+/SIB-0
    log to console    ${objects}
    ${params_list}    Create List
    FOR    ${item}    IN     @{objects}
        ${params_dict}    Create Dictionary
        Set To Dictionary    ${params_dict}    dist_name    ${item}    parameter    cellBarred    value   barred
        Append To List    ${params_list}    ${params_dict}
    END
    ${update_delta}    coam_parameter.create_update_parameters_delta    parameters=${params_list}    connection=${connection}
    log to console    ${update_delta}
    coam_parameter.perform_scf_delta_commission    delta_file=${update_delta['updated']}    connection=${connection}    timeout=240
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get RF LOG Form RF
    [Documentation]   Auther: jun.8.chen@nokia-sbell.com
    ...               Description: Get RU IP address In ASIK : Get RU IP Address from log in ASIK : /rom/config/FRIps.txt
    ...               2023.11.10 update Jia Lei for 0.0.0.0 in /rom/config/FRIps.txt
    [Arguments]    ${rmod_bbmod_mapping}    ${rmod_index}    ${ru_index}=${1}   ${connection}=GNB_OAM0
    ...            ${container_id}=0x1018
    ...            ${asik_alias_right}=ASIK Master Right   ${asik_alias}=ASIK Master
    ...            ${ru_username}=${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.username}
    ...            ${ru_password}=${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.password}
    ...            ${serial_number}=None
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${rfsw_log_path}    Set Variable    /ram/rfsw_log_${timestamp}.zip
    ${ru_bbmod_mapping_lenget}    Get Length     ${rmod_bbmod_mapping['${rmod_index}']}
    ${target_rmod_index}      Set Variable If    ${ru_bbmod_mapping_lenget}==${1}     ${rmod_bbmod_mapping['${rmod_index}'][0]}
    ...                                          ${ru_bbmod_mapping_lenget}==${2}     ${rmod_bbmod_mapping['${rmod_index}'][-1]}
    ${status}    Evaluate    int(${target_rmod_index}) >= 4
#    ${status}    Evaluate    ${rmod_bbmod_mapping['${rmod_index}']} >= 4
    Run Keyword If    ${status}    ssh.Connect to    hostname=fct-4a
    ...                                              username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                                              password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                                              proxy=${asik_alias}
    ...                                              alias=${asik_alias_right}
    ${alias}    Set Variable If    ${status}    ${asik_alias_right}    ${asik_alias}
    ${container_id}    Get FHNET Container ID    asik_alias=${alias}
        &{ru_info}    run keyword if    '${serial_number}'=='None'
    ...                             COAM get ru detial info by ru index     ru_index=${rmod_index}   connection=${connection}
    ${ru_serial_number}    Set Variable If    '${serial_number}'=='None'    ${ru_info['serialNumber']}    ${serial_number}
    ${ru_ip_addr}  Get RU IP Address Via File FRIps and remove incorrect ones    ru_serial_number=${ru_serial_number}
    ...                                                                          connection=${alias}
    ${output}    csn.execute    lxc-ls    connection=${alias}
    ${smod_connection}    csn.get_connection_by_alias    alias=${alias}
    ${channel}    Call Method    ${smod_connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ssh ${ru_username}@${ru_ip_addr} -o StrictHostKeyChecking\=no\n
    Sleep    1 sec
    ${password_prompt_output}    Call Method    ${channel}    recv    ${65535}
    IF    "/user/toor4nsn/.ssh/known_hosts" in """${password_prompt_output}"""
        Call Method    ${channel}    send    rm /user/toor4nsn/.ssh/known_hosts\n
        Sleep    1 sec
        Call Method    ${channel}    recv    ${65535}
        Call Method    ${channel}    send    ssh ${ru_username}@${ru_ip_addr} -o StrictHostKeyChecking\=no\n
        Sleep    1 sec
        ${password_prompt_output}    Call Method    ${channel}    recv    ${65535}
    END
    IF    "password:" in """${password_prompt_output}"""
        Call Method    ${channel}    send    ${ru_password}\n
        Sleep    1 sec
        Call Method    ${channel}    recv    ${65535}
    END
    Sleep    2sec
    Call Method    ${channel}    send    cd /usr/bin;ccsShell.sh log -a -z ${rfsw_log_path}\n
    Sleep    3 sec
    ${command_output}    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    close
    [Return]    ${rfsw_log_path}