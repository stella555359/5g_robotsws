*** Settings ***
Documentation    This is for feature CB009881-W related common keywords.
...              Please do not modify the file without notification to author
...              Author:yishuang.wang@nokia-sbell.com
...              Squard: HZ PZ4 SG3

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/log_cap.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Variables    ../Resources/HBTE_PA_setting.py
Variables    ../Resources/variables.py
Library     ../Resources/upload_SFE_KPI_value_to_compass_cloud.py
Library     ../Resources/control_para.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library     Collections
Library       ../Resources/get_cloud_counters_from_pm_file.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/SFE_TMO_HO_common_keywords.py
Library       ../Resources/add_swconfig_cloud.py



*** Variables ***
${ue_type}    ${tl.ues[0].capabilities[1]}
${test_pc}    ${tl.test_pc.default_ssh_connection_details.addr}
${gnb1_id}    ${tl.gnbs[0].cu.instance_id}
${gnb2_id}    ${tl.gnbs[1].cu.instance_id}
${enb1_id}    ${tl.enbs[0].instance_id}
${tl_scf_path}    /opt/workspace/SCF
${VDU1_SCF}       TL239_VDU1_SCF.xml
${CU1_SCF}        TL239_CU1_SCF.xml
${CU2_SCF}        TL239_CU2_SCF.xml
${gnb0_scf_name_CU_0}    gnb1_scf_tl239_CU1.xml
${gnb0_scf_name_vDU_0}    gnb1_scf_tl239-vDU1.xml
${gnb0_scf_name_vDU_1}    gnb1_scf_tl239-vDU2.xml
${gnb1_scf_name_CU_1}    gnb2_scf_tl239_CU2.xml
${gnb1_scf_name_vDU_0}    gnb2_scf_tl239-vDU3.xml
${vcu_counter_file}       vcu_counter.txt
${vdu_counter_file}       vdu_counter.txt
${SCF_path}    /opt/workspace/SCF/
${data_send_ul}    30M
${data_send_dl}    100M
@{ue_action}    attach    detach
${control_pc_ip}    ${tl.ues[0].ssh_connection_details.addr}
${control_pc_username}    ${tl.ues[0].ssh_connection_details.username}
${control_pc_password}    ${tl.ues[0].ssh_connection_details.password}
${action}    Yes
@{list_}
@{counter_list_}
@{ue_list_}
@{vcu_ALLOWED_FAULT}    4655    4654    61524    61652    7104    7107
@{vdu_ALLOWED_FAULT}    4655    4654    61524    61652    7104    7107
${model}       ${tl.attenuator[0].model}

*** Keywords ***
Common Suite Setup for Cloud
    [Arguments]
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}
    Create suite log path
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${SUITE_LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}
    @{pm_allvcu_list}    Create List
    @{pm_allvdu_list}    Create List
    Set Suite Variable    ${pm_allvcu_list}
    Set Suite Variable    ${pm_allvdu_list}
    set_suite_documentation    doc=All test suite log will save in this VM IP:${test_pc} Path:${epc_log_path}
    ...    append=True

Create suite log path
    [Documentation]    Create log directory with test suite level and open a common variable ${SUITE_LOG_PATH}
    [Arguments]     ${gnb_index}=${0}    ${vdu_index}=${0}
    ${cu_sw_version} =    CU Get SW Version    gnb_index=${gnb_index}
    set suite variable    ${cu_sw_version}
    ${vdu_sw_version} =    vDU Get SW Version    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    set suite variable    ${vdu_sw_version}
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${cu_sw_version}_${vdu_sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Create directory    ${SUITE_LOG_PATH}

CU Get SW Version
    [Arguments]    ${gnb_index}=${0}
    CU Rest Login  gnb_index=${gnb_index}
    ${cu_sw_version}=  cu.get_active_software_version
    [Return]     ${cu_sw_version}
    [Teardown]    run keyword and ignore error   CU Logout

vDU Get SW Version
    [Arguments]  ${vdu_index}=0    ${gnb_index}=0
    vDU Rest Login    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${vdu_state_data}=  vdu.get_vdu_state_data
    ${vdu_sw_version}=    set variable    ${vdu_state_data['software_version']}
    [Return]     ${vdu_sw_version}
    [Teardown]  run keyword and ignore error    vDU Logout

Get golden scf path and control parameter
    @{rest}    String.Split String    string=${cu_sw_version}    separator=_
    ${release}    String.Fetch From Right    string=${rest}[0]    marker=CNF
    set suite variable    ${Golden_SCF_Path}    ${tl_scf_path}/${release}/
    set suite variable    ${control_para_file_path}   ${tl_scf_path}/${release}/TA_para_control.txt
    ${traffic_direction}=    get_control_para
    ...    file_path=${control_para_file_path}    control_para_name=traffic_direction
    ${ho_times}=    get_control_para
    ...    file_path=${control_para_file_path}    control_para_name=HO_times
    ${Import_SCF}=    get_control_para
    ...    file_path=${control_para_file_path}    control_para_name=Import_SCF
    set suite variable      ${traffic_direction}
    set suite variable      ${ho_times}
    set suite variable      ${Import_SCF}

## BTS ##
BTS preparation per cu
    [Arguments]    ${vdu_count}=${2}    ${gnb_index}=${gnb_index}
    All vDUs Full Commission SCF    vdu_count=${vdu_count}    gnb_index=${gnb_index}
    CU Full Commission    path_of_commission_file=${Golden_SCF_Path}${gnb${${gnb_index}}_scf_name_CU_${gnb_index}}    gnb_index=${gnb_index}
    sleep    30s
    wait until keyword succeeds    5min    30s    All vDUs Verify All Cells Status Should Be Onair    vdu_count=${vdu_count}    gnb_index=${gnb_index}
    wait until keyword succeeds    5min    30s    CU Verify All DUs Status Are Available    gnb_index=${gnb_index}

BTS preparation
    [Arguments]    ${vdu_count}=${2}    ${cu_count}=${2}    ${vdu_from_gnb2}=True   ${vdu_count_gnb2}=${1}
    All CUs Full Commission SCF    cu_count=${cu_count}
    All vDUs Full Commission SCF    vdu_count=${vdu_count}    gnb_index=${0}
    Run Keyword If    "${vdu_from_gnb2}"!="${EMPTY}"    All vDUs Full Commission SCF    vdu_count=${vdu_count_gnb2}    gnb_index=${1}
    wait until keyword succeeds    20min    30s    All vDUs Verify All Cells Status Should Be Onair    vdu_count=${vdu_count}    gnb_index=${0}
    Run Keyword If    "${vdu_from_gnb2}"!="${EMPTY}"
    ...    wait until keyword succeeds    10min    30s    All vDUs Verify All Cells Status Should Be Onair
    ...    vdu_count=${vdu_count_gnb2}    gnb_index=${1}
	wait until keyword succeeds    20min    30s    CU Verify All DUs Status Are Available
	Run Keyword If    "${vdu_from_gnb2}"!="${EMPTY}"
    ...    wait until keyword succeeds    10min    30s    CU Verify All DUs Status Are Available    gnb_index=${1}

Check and prepare for gnb
    [Arguments]    ${cell_type}=SA    ${vdu_count}=${2}    ${cu_count}=${2}    ${vdu_from_gnb2}=True   ${vdu_count_gnb2}=${1}
    run keyword if    '${Import_SCF}' == '${action}'    BTS preparation    vdu_count=${vdu_count}    cu_count=${cu_count}
    ...    vdu_from_gnb2=${vdu_from_gnb2}    vdu_count_gnb2=${vdu_count_gnb2}
#    run keyword if    '${cell_type}'=='SA'    run keyword and ignore error    Lock X2 Link
    run keyword if    '${cell_type}'=='NSA'    Check all enb x2link status avaliable
    run keyword if    '${cell_type}'=='NSA'    run keyword and ignore error    Lock unlock AMF
    run keyword if    '${cell_type}'=='NSA'    run keyword and ignore error    Lock unlock AMF    gnb_index=${1}
    run keyword if    '${cell_type}'=='SA'    run keyword and ignore error    Lock unlock AMF    value=Unlocked
    run keyword if    '${cell_type}'=='SA'    run keyword and ignore error    Lock unlock AMF    gnb_index=${1}    value=Unlocked

ALL cells status are onair
    [Arguments]
    ${VCU1_status}    Run Keyword And Return Status
    ...    VCU Verify All Cells Status Are Onair
    ${VCU2_status}    Run Keyword And Return Status
    ...    VCU Verify All Cells Status Are Onair    gnb_index=1
    ${ALL_VCU_status}    Evaluate    '${VCU1_status}' == 'True' and '${VCU2_status}' == 'True'
    Should Be True    '${ALL_VCU_status}' == 'True'



VCU Verify All Cells Status Are Onair
    [Arguments]  ${gnb_index}=0
    cu.connect_to     host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    port=443
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    secure=${True}
    ...    alias=vcu_${gnb_index}
    ${cells_summary}=   cu.get_cells_summary    connection=vcu_${gnb_index}
    should be equal as integers
    ...    ${cells_summary["basic_cells_summary"]["administrative_state"]["shutting_down"]}   0   Some cells are shutting down!
    should be equal as integers
    ...    ${cells_summary["basic_cells_summary"]["administrative_state"]["locked"]}   0   Some cells are locked!
    should be equal as integers
    ...    ${cells_summary["basic_cells_summary"]["operational_state"]["disabled"]}    0   Some cells are disabled!
    [Teardown]    run keyword and ignore error   cu.disconnect    connection=vcu_${gnb_index}


All vDUs Full Commission SCF
    [Arguments]    ${vdu_count}=${2}    ${gnb_index}=${0}
    FOR    ${index_vdu}    IN RANGE    ${vdu_count}
        vDU Full Commission SCF    scf_file=${Golden_SCF_Path}${gnb${${gnb_index}}_scf_name_vDU_${index_vdu}}
        ...    vdu_index=${index_vdu}    gnb_index=${gnb_index}
    END


All CUs Full Commission SCF
    [Arguments]    ${cu_count}=${1}
    FOR    ${index_cu}    IN RANGE    ${cu_count}
        CU Full Commission    path_of_commission_file=${Golden_SCF_Path}${gnb${${index_cu}}_scf_name_CU_${index_cu}}    gnb_index=${index_cu}
    END

All vDUs Verify All Cells Status Should Be Onair
    [Arguments]    ${vdu_count}=${2}    ${gnb_index}=${0}
    FOR    ${index_vdu}    IN RANGE    ${vdu_count}
        vDU Verify All Cells Status Should Be Onair    vdu_index=${index_vdu}    gnb_index=${gnb_index}
    END

VDU online modify parameters
    [Arguments]    ${dist_name_vdu}    ${parameter_vdu}    ${vdu_parameter_value}
    ...            ${operation_vdu}=update    ${gnb_index}=${0}    ${vdu_index}=${0}
    vdu.connect_to    host=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...    port=443
    ...    username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...    secure=${True}
    ...    connection_name=vdu_${gnb_index}_${vdu_index}
    vdu.perform_parameter_recommissioning    dist_name=${dist_name_vdu}
    ...                                      parameter=${parameter_vdu}
    ...                                      operation=${operation_vdu}
    ...                                      value=${vdu_parameter_value}
    ...                                      vdu_connection=vdu_${gnb_index}_${vdu_index}
    [Teardown]    run keyword and ignore error    vdu.disconnect    vdu_connection=vdu_${gnb_index}_${vdu_index}


CU online modify parameters
    [Arguments]    ${parameter_cu}    ${cu_parameter_value}    ${dist_name_cu}    ${gnb_index}=${0}
    ...            ${operation_cu}=update
    cu.connect_to     host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    port=443
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    secure=${True}
    ...    alias=vcu_${gnb_index}
    cu.perform_parameter_recommissioning    dist_name=${dist_name_cu}
    ...                                     parameter=${parameter_cu}
    ...                                     operation=${operation_cu}
    ...                                     value=${cu_parameter_value}
    ...                                     connection=vcu_${gnb_index}
    [Teardown]    run keyword and ignore error    cu.disconnect    connection=vcu_${gnb_index}



VDU_modify_parameter_commission_SCF
    [Arguments]    ${VDU_scf_name}    ${dist_name_vdu}    ${p_name_vdu}    ${value_vdu}
    ...            ${gnb_index}=${0}     ${vdu_index}=${0}
    ...            ${scf_path}=/opt/workspace/SCF/
    ...            ${wait_for_completion}=False
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    ${scf_file_path}    Join Path    ${scf_path}    ${VDU_scf_name}
    ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${epc_log_path}
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${scf_dir_path}    String.Replace string    ${scf_file_path}    /${scf_file_name}    ${EMPTY}
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    scf.Load scf    ${default_scf_file_path}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${scf_file_name_after_modify}    catenate  SEPARATOR=${EMPTY}    ${file_name_without_extention}    _${timestamp}_updated.xml
    ${modified_scf_file_path}    set variable    ${epc_log_path}/${scf_file_name_after_modify}
    scf.modify_scf_element    dist_name=${dist_name_vdu}    p_name=${p_name_vdu}    value=${value_vdu}
    scf.Save scf    ${modified_scf_file_path}
#    Cloud Perform VDU Full Scf    vdu_scf_path=${modified_scf_file_path}
    vdu.perform_commissioning    scf_file=${modified_scf_file_path}    vdu_connection=${conn_alias}    timeout=1200
    ...                          wait_for_completion=${wait_for_completion}
	sleep    1min
    wait until keyword succeeds     15min    30s     All Cells Should Be Onair For One Specific vDU
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}


CU_modify_parameter_commission_SCF
    [Arguments]    ${dist_name_cu}    ${p_name_cu}    ${value_cu}
    ...            ${gnb_index}=${0}
    ...            ${scf_path}=/opt/workspace/SCF/
    ...            ${wait_for_completion}=False
    CU Rest Login     gnb_index=${gnb_index}    cu_version='cuoam_25r2'
    cu.connect_to     host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    port=443
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    secure=${True}
    ${scf_file_path}    Join Path    ${scf_path}    ${CU_scf_name}
    ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${epc_log_path}
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${scf_dir_path}    String.Replace string    ${scf_file_path}    /${scf_file_name}    ${EMPTY}
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    scf.Load scf    ${default_scf_file_path}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${scf_file_name_after_modify}    catenate  SEPARATOR=${EMPTY}    ${file_name_without_extention}    _${timestamp}_updated.xml
    ${modified_scf_file_path}    set variable    ${epc_log_path}/${scf_file_name_after_modify}
    scf.modify_scf_element    dist_name=${dist_name_cu}    p_name=${p_name_cu}    value=${value_cu}
    scf.Save scf    ${modified_scf_file_path}
#    Cloud Perform VDU Full Scf    vdu_scf_path=${modified_scf_file_path}
    cu.perform_commissioning     scf_file=${modified_scf_file_path}        timeout=1200
    ...                          wait_for_completion=${wait_for_completion}
	sleep    1min
	[Teardown]    run keyword and ignore error   CU Logout

Wait VDU onair
    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}
    Wait Until Keyword Succeeds    10min    30s    vdu.connect_to    host=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...    port=443
    ...    username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...    secure=${True}
    ...    connection_name=vdu_${gnb_index}_${vdu_index}
    Wait Until Keyword Succeeds    10min    10s    check vdu cells status    vdu_connection=vdu_${gnb_index}_${vdu_index}
    [Teardown]    run keyword and ignore error    vdu.disconnect    vdu_connection=vdu_${gnb_index}_${vdu_index}

check vdu cells status
    [Arguments]    ${vdu_connection}
    ${vdu_cells_status}    vdu.get_vdu_cells_status    vdu_connection=${vdu_connection}
    should be true    '${vdu_cells_status}[0][availability_status]' == 'on line'

Lock unlock AMF
    [Arguments]    ${gnb_index}=${0}    ${value}=Locked
    CU online modify parameters    parameter_cu=administrativeState    cu_parameter_value=${value}
    ...    dist_name_cu=MRBTS-${tl.gnbs[${gnb_index}].cu.instance_id}/NRBTS-${tl.gnbs[${gnb_index}].cu.instance_id}/SERVEDAMF-1
    ...    gnb_index=${gnb_index}


#Lock X2 Link
#    [Arguments]    ${gnb_index}=${0}
#    CU online modify parameters    param=x2LinkLock    value=locked
#    ...    MO=MRBTS-${tl.gnbs[${gnb_index}].cu.instance_id}/NRBTS-${tl.gnbs[${gnb_index}].cu.instance_id}/LTEENB-0
#    ...    gnb_index=${gnb_index}

Check all enb x2link status avaliable
    wait until keyword succeeds    5x    30s    Check the enb x2link status    enb_index=0    gnbid=0
    wait until keyword succeeds    5x    30s    Check the enb x2link status    enb_index=0    gnbid=1
    wait until keyword succeeds    5x    30s    Check the enb x2link status    enb_index=1    gnbid=0
    wait until keyword succeeds    5x    30s    Check the enb x2link status    enb_index=1    gnbid=1

Check the enb x2link status
    [Arguments]  ${enb_index}=0    ${gnbid}=0    ${adjGnbId}=${tl.gnbs[${gnbid}].cu.instance_id}
    Connect to eNB via ssl    enb_index=${enb_index}
    @{MOs}    enblte.get_managed_objects    class_name=LNADJGNB_A    connection=enblte
    FOR    ${list}    IN    @{MOs}
        ${status}    run keyword and return status    Should be equal as strings    ${list['parameters']['adjGnbId']}
        ...    ${adjGnbId}
        ${dist_name} =    set variable if    '${status}'=='${True}'    ${list['distName']}
        EXIT FOR LOOP IF    '${status}'=='${True}'
    END
    should be true    '${status}'=='${True}'    msg=there has no match adjGnb with provide adjGnbId
    &{x2_link_status}    enblte.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=x2ToGnbLinkStatus    connection=enblte
    Should be equal as strings    ${x2_link_status['x2ToGnbLinkStatus']}    available    msg=X2 link to gnb is unavailable
    [Teardown]    Enblte close down

CU Save Snapshot
    [Arguments]     ${gnb_index}=0    ${local_snapshot_location}=vcu1_snapshot
    [Documentation]    this kw is used to Gets local snapshot in vcu
    cu.connect_to     host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    port=443
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    secure=${True}
    ...    alias=vcu_${gnb_index}
    ${tc_name}=    Replace String    string=${TEST NAME}    search_for=${SPACE}    replace_with=_
    ${Snapshot_path}    create_a_directory    log_path=${epc_log_path}
    ...                 directory_name=${tc_name}/${local_snapshot_location}
    cu.Get_Local_Snapshot    directory=${Snapshot_path}    connection=vcu_${gnb_index}
    [Return]  ${Snapshot_path}
    [Teardown]    run keyword and ignore error    cu.disconnect    connection=vcu_${gnb_index}

Collect CU Snapshot Log
    run keyword and ignore error    CU Save Snapshot
    run keyword and ignore error    CU Save Snapshot    gnb_index=1    local_snapshot_location=vcu2_snapshot

vDU Save Snapshot
    [Arguments]     ${gnb_index}=0    ${vdu_index}=${0}    ${local_snapshot_location}=vDu1_snapshot
    [Documentation]    this kw is used to Gets local snapshot in vDu
    vdu.connect_to    host=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...    port=443
    ...    username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...    secure=${True}
    ...    connection_name=vdu_${gnb_index}_${vdu_index}
    ${tc_name}=    Replace String    string=${TEST NAME}    search_for=${SPACE}    replace_with=_
    ${Snapshot_path}    create_a_directory    log_path=${epc_log_path}
    ...                 directory_name=${tc_name}/${local_snapshot_location}
    vdu.Get_Local_Snapshot    directory=${Snapshot_path}     compressed_or_not=True    vdu_connection=vdu_${gnb_index}_${vdu_index}
    [Return]  ${Snapshot_path}
    [Teardown]    run keyword and ignore error    vdu.disconnect    vdu_connection=vdu_${gnb_index}_${vdu_index}

Collect GNB1 vDU Snapshot Log
    [Arguments]    ${vDu_num}=2
    FOR    ${n}    IN RANGE    0    ${vDu_num}
      vDU Save Snapshot    vdu_index=${n}    local_snapshot_location=vDu${n}_snapshot
    END

Collect vDU Snapshot Log
    [Arguments]    ${vDu_num}=2
    FOR    ${n}    IN RANGE    0    ${vDu_num}
      vDU Save Snapshot    vdu_index=${n}    local_snapshot_location=vDu${n}_snapshot
    END
    vDU Save Snapshot    gnb_index=1    vdu_index=${0}    local_snapshot_location=vDu2_snapshot

SCF recovery
    [Arguments]    ${celltype}=SA
    VDU online modify parameters    dist_name_vdu=MRBTS-${gnb1_id}/NRBTS-${gnb1_id}/NRCELL-2
    ...                             parameter_vdu=nrarfcn
    ...                             vdu_parameter_value=638000
    ...                             gnb_index=${0}    vdu_index=${0}
    Wait VDU onair    gnb_index=${0}    vdu_index=${0}
    CU online modify parameters     parameter_cu=handoverAllowedSA
    ...                             cu_parameter_value=allowed
    ...                             dist_name_cu=MRBTS-${gnb1_id}/NRBTS-${gnb1_id}/NRCELL-1/NRREL-3
    ...                             gnb_index=${0}
    CU online modify parameters     parameter_cu=handoverAllowedSA
    ...                             cu_parameter_value=allowed
    ...                             dist_name_cu=MRBTS-${gnb2_id}/NRBTS-${gnb2_id}/NRCELL-4/NRREL-1
    ...                             gnb_index=${1}
    CU online modify parameters     parameter_cu=nrarfcn
    ...                             cu_parameter_value=638000
    ...                             dist_name_cu=MRBTS-${gnb1_id}/NRBTS-${gnb1_id}/NRCELL-2
    ...                             gnb_index=${0}
    run keyword if    '${cell_type}'=='NSA'    run keyword and ignore error    Lock unlock AMF    value=Unlocked
    run keyword if    '${cell_type}'=='NSA'    run keyword and ignore error    Lock unlock AMF    gnb_index=${1}    value=Unlocked

CLOUD Check Unexpect Alarm whether exist
    [Arguments]    ${vcu_ALLOWED_FAULT}    ${vdu_ALLOWED_FAULT}
    @{vcu_alarm_list}    vCU Get Active Alarms
    FOR    ${vcu_alarms}    IN    @{vcu_alarm_list}
       List Should Contain Value    ${vcu_ALLOWED_FAULT}    ${vcu_alarms}
    END
    @{vdu_alarm_list}    VDU Get Active Alarms
    FOR    ${vdu_alarms}    IN    @{vdu_alarm_list}
       List Should Contain Value    ${vdu_ALLOWED_FAULT}    ${vdu_alarms}
    END

Check GNB status and collect logs
    [Arguments]      ${vcu_ALLOWED_FAULT}    ${vdu_ALLOWED_FAULT}
    ${cell_status}    Run Keyword And Return Status    ALL cells status are onair
    Run Keyword If     '${cell_status}' == 'False'    Run Keywords
    ...    Collect CU Snapshot Log    AND
    ...    Collect vDU Snapshot Log
    ${alarm_status}    Run Keyword And Return Status
    ...    CLOUD Check Unexpect Alarm whether exist    vcu_ALLOWED_FAULT=${vcu_ALLOWED_FAULT}    vdu_ALLOWED_FAULT=${vdu_ALLOWED_FAULT}
    ${GNB_status}    Evaluate    '${cell_status}' == 'True' and '${alarm_status}' == 'True'
    Run Keyword If     '${GNB_status}' == 'False'    Run Keywords
    ...    Collect CU Snapshot Log    AND
    ...    Collect vDU Snapshot Log

vCU Get Active Alarms
    [Arguments]  ${gnb_index}=0
    [Documentation]  Gets active alarms including faults from BTS and alarms from RCP.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:   <19-Nov-2019>, <f2huang>, <e.g. PR-Number, feature number>
        ...    | Input Parameters | Man. | Description |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default  |
        ...
        ...    *RETURN VALUE*
        ...    Active alarm list
        ...    Example
        ...    |  Get CU Active Alarm	 |    |
    cu.connect_to     host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    port=443
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    secure=${True}
    ...    alias=vcu_${gnb_index}
     ${active_alarm_list}=  cu.get_active_alarms    page_number=${1}     items_per_page=${1000}    connection=vcu_${gnb_index}
     ${num_of_alarms}=   get length     ${active_alarm_list["alarms"]}
     @{faultid_list}    create list
     FOR     ${i}    IN RANGE    ${num_of_alarms}
         Append to list    ${faultid_list}    ${active_alarm_list["alarms"][${i}]["fault_id"]}
     END
     ${active_faultID_list}    Remove Duplicates    ${faultid_list}
     [Return]    ${active_faultID_list}
     [Teardown]    run keyword and ignore error    cu.disconnect    connection=vcu_${gnb_index}

VDU Get Active Alarms
    [Arguments]  ${gnb_index}=0    ${vdu_index}=${0}
    [Documentation]  Gets active alarms including faults from BTS and alarms from RCP.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:   <19-Nov-2019>, <f2huang>, <e.g. PR-Number, feature number>
        ...    | Input Parameters | Man. | Description |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default  |
        ...
        ...    *RETURN VALUE*
        ...    Active alarm list
        ...    Example
        ...    |  Get CU Active Alarm	 |    |
     vdu.connect_to    host=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...    port=443
    ...    username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...    secure=${True}
    ...    connection_name=vdu_${gnb_index}_${vdu_index}
     ${active_alarm_list}=  vdu.vdu_get_active_alarms    page_number=${1}     items_per_page=${1000}    vdu_connection=vdu_${gnb_index}_${vdu_index}
     ${num_of_alarms}=   get length     ${active_alarm_list["alarms"]}
     @{faultid_list}    create list
     FOR     ${i}    IN RANGE    ${num_of_alarms}
         Append to list    ${faultid_list}    ${active_alarm_list["alarms"][${i}]["fault_id"]}
     END
     ${active_faultID_list}    Remove Duplicates    ${faultid_list}
     [Return]     ${active_faultID_list}
     [Teardown]  Run Keyword And Ignore Error    vdu.disconnect    vdu_connection=vdu_${gnb_index}_${vdu_index}

## log ##
Start Capture Wireshark Logs on cu
    [Arguments]    ${f1log}    ${gnb_index}=${0}
    ${alias1} =   Connect To CU K8S Master With Admin    gnb_index=${gnb_index}
    ${ns}=  Get CU Namespace From Testline    gnb_index=${gnb_index}
    set test variable    ${ns}
#    ${start_log} =    Catenate    kubectl -n ${ns} exec -it po-${ns}-cpif-0 -c ctr-${ns}-nwmgmt -- tcpdump sctp -i any -w /tmp/${f1log}
#    sleep    5s
#    ${out} =    issh.execute  command=${start_log}    alias=${alias}
    ${out} =    issh.execute_bare    command=kubectl -n ${ns} exec -it po-${ns}-cpif-0 -c ctr-${ns}-nwmgmt -- bash    alias=${alias1}
    sleep    5s
    ${out} =    issh.execute_bare    command=tcpdump sctp -i any -w /tmp/${f1log}    alias=${alias1}

Stop Capture Wireshark Logs on cu
    [Arguments]    ${f1log}    ${gnb_index}=${0}
    ${alias} =   Connect To CU K8S Master With Admin    gnb_index=${gnb_index}
    ${out} =    issh.execute    command=kubectl -n ${ns} exec -it po-${ns}-cpif-0 -c ctr-${ns}-nwmgmt -- bash -c 'ps -ef|grep ${f1log}|grep -v grep'
    ...    alias=${alias}
    ${out_tail} =    Get Line    ${out}    1
    ${pid} =    Split String    ${out_tail}
    ${out} =    issh.execute    command=kubectl -n ${ns} exec -it po-${ns}-cpif-0 -c ctr-${ns}-nwmgmt -- bash -c 'kill -9 ${pid[1]}'
    ...    alias=${alias}
    ${log_collect} =    Catenate    kubectl exec -n ${ns} po-${ns}-cpif-0 -c ctr-${ns}-nwmgmt
    ...    -- /bin/gzip -c /tmp/${f1log} |gunzip > /var/home/core/${ns}/${f1log}
    ${out}    issh.Execute  command=${log_collect}   alias=${alias}
	sleep    5s
    issh.Download_File    remote_path=/var/home/core/${ns}/${f1log}    local_path=${epc_log_path}    alias=${alias}
	[Teardown]    issh.Disconnect    alias=${alias}

## PM counter
Get all the counters and add in excel
    [Arguments]    ${celltype}    ${file_path}=${epc_log_path}${celltype}_HO_counter.xlsx
    create_excel_and_write_date_list    start_date=${start_date}    end_date=${end_date}
    ...                         filepath=${file_path}
    ...                         filesheet=${celltype}_HO_SFE
    FOR  ${pm_counter}  IN   @{pm_all_list}
        ${counter}    Get CU Counter    gnb_index=${pm_counter['gnb_id']}
        ...                                counter_id=${pm_counter['counter_id']}
        ...                                measurement_id=${pm_counter['meas_id']}
        ...                                dimension_dist_name=${pm_counter['dic_path']}
        ${counter_value}    set variable    ${counter['values']}
        ${counter_result}    Counter date convertion    ${counter_value}
        write_counter_to_excel    counter_value=${counter_result}    counter_prop=${pm_counter}
        ...                       filepath=${epc_log_path}${celltype}_HO_counter.xlsx
        ...                       filesheet=${celltype}_HO_SFE
    END

get the Counter dict from COAM
    [Arguments]    ${counter_id}    ${gnb_id}=1    ${dic_path}=full     ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_dict    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}    timeout=${timeout}
    [Teardown]    COAM Teardown gnb connections
    [Return]    ${counter_value}


Get CU Counter
    [Arguments]    ${counter_id}     ${measurement_id}    ${dimension_dist_name}    ${gnb_index}=0
    [Documentation]    Get latest counter value from webUI via rest API.
    ...    author: rita.feng@nokia-sbell.com
    ...    modified by:   <22-Oct-2020>, <rifeng>, <Initial creation>
    ...    modified by:   <23-Mar-2021>, <huilxu>, <trunk PM V2>
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id | Yes | PM counter ID |
    ...    | measurement_id | Yes | Measurement ID |
    ...    | dimension_dist_name | No | Aggregation dimension distName of the measurement you want to retrive. |
    ...    | how_many | No | How many counter values will be get , 1 in default |
    ...    | gnb_index | No |  gnb index to indicate which gnb will be used, 0 in default  |
    ...
    ...    *RETURN VALUE*
    ...    Latest counter value
    ...    Example
    ...    | ${value}= | Get CU Counter |  M55323C13001  |   55323   |   MRBTS-5226/NRBTS-5226  |
    CU Rest Login  gnb_index=${gnb_index}    cu_version=cuoam_21b
    ${res}=  cu.get_counter   ${measurement_id}    ${dimension_dist_name}    ${counter_id}
    [Return]     ${res}
    [Teardown]   CU Logout

Add the PM counter list
    [Arguments]    ${pm_counters}
    FOR  ${pm_counter}  IN   @{pm_counters}
        Append To List    ${PM_all_list}    ${pm_counter}
    END

Prepare with PM counter time caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    360-${utc0}%300
    sleep    ${left_timer}

Counter date convertion
    [Arguments]    ${counter_info}
    ${length}    get length    ${counter_info}
    ${counter_result}    create dictionary
    FOR    ${index}    IN RANGE    ${length}
        ${date}    DateTime.convert date    ${counter_info[${index}]['start_time']}    epoch
        ${date}    convert to integer    ${date}
        ${counter_date}    convert to string    ${date}
        ${value}    convert to integer    ${counter_info[${index}]['value']}
        Set To Dictionary     ${counter_result}    ${counter_date}=${value}
    END
    [Return]    ${counter_result}

upload_kpi_to_compass
    [Arguments]    ${celltype}
    FOR  ${id}  IN   @{${celltype}_KPI_ID}
        upload_execute_data    filepath=${epc_log_path}${celltype}_HO_counter.xlsx    filesheet=${celltype}_HO_SFE
        ...    KPI_ID=${id}    tl_id=${tl.gnbs[0].cu.instance_id}    time_list=@{list}    childern_list_len=${2}
        ...    ue_number=@{ue_num_list}
    END

set redundant value to 0
    [Arguments]    ${celltype}    ${inital}=7    ${total}=11    ${inital_13}=13    ${inital_14}=14
    FOR  ${index}    IN RANGE    ${inital}    ${total}
    remove_no_use_value    filepath=${epc_log_path}${celltype}_HO_counter.xlsx    filesheet=${celltype}_HO_SFE
    ...    start_time=${time${index}_start}    end_time=${time${index}_end}    counter_name=${counter_name${index}}
    END
    ${id}=    Convert To String    ${tl.gnbs[0].instance_id}
    ${instance_id}=    Get Substring    ${id}    0    3
    Set Suite Variable    ${testline_instance_id}    ${instance_id}
    Run Keyword If    '${testline_instance_id}' == '375'
    ...    remove_no_use_value    filepath=${epc_log_path}${celltype}_HO_counter.xlsx    filesheet=${celltype}_HO_SFE
    ...    start_time=${time${inital_13}_start}    end_time=${time${inital_13}_end}    counter_name=${counter_name${inital_13}}
    remove_no_use_value    filepath=${epc_log_path}${celltype}_HO_counter.xlsx    filesheet=${celltype}_HO_SFE
    ...    start_time=${time${inital_14}_start}    end_time=${time${inital_14}_end}    counter_name=${counter_name${inital_14}}

backup NSA counter excel
    [Arguments]    ${celltype}
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}    alias=ute
    sleep    2s
    csn.send command
    ...    command=cp -r ${epc_log_path}${celltype}_HO_counter.xlsx ${epc_log_path}${celltype}_HO_counter_backup.xlsx
    ...    connection=ute
    csn.disconnect     connection=ute

## UE ##
Precondition for power UE
    [Arguments]    ${ue_type}    ${ui_version}=S21UI3.1    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ui_version=${ui_version}    ue_index=${ue_index}
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}

Attach and check power UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${attach_mode}=5G_SA
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog    attach_mode=${attach_mode}

UE Detach with power UE
    [Arguments]    ${ue_index}=${0}
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}

Start traffic with power UE
    power_ue.Start traffic    ue_index=${0}    direction=ul    throughput=${data_send_ul}
    ...       duration=1400    ue_type=${ue_type}
    sleep    1s
    power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=${data_send_dl}
    ...       duration=1400    ue_type=${ue_type}   process_num=1
    sleep    20s

Stop traffic with power UE
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${ue_type}
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${ue_type}

Check throughput with power UE
    [Arguments]    ${ultarget_throughput}    ${dltarget_throughput}    ${gnb_index}=${0}    ${vdu_index}=${0}    ${ru_index}=${0}
	${handle}    vDU Begin K8s Log    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    Set test variable    ${handle}
    ${container_prefix}    vDU Get Container Name Prefix
	${log}    vDU End K8s Log      handle=${handle}     pod_abbr=l2rt     container=${container_prefix}l2rt
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${cell_id}    vDU get cells identity list    gnb_index=${gnb_index}    vdu_index=${vdu_index}    ru_index=${ru_index}
	Run keyword and continue on failure    power_ue.Check Tput
	...    direction=ul    ue_type=${ue_type}    log=${log}     cells=${cell_id}
    ...    target_throughput=${ultarget_throughput}
    Run keyword and continue on failure    power_ue.Check Tput
	...    direction=dl    ue_type=${ue_type}    log=${log}     cells=${cell_id}
    ...    target_throughput=${dltarget_throughput}

vDU get cells identity list
    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}    ${ru_index}=${0}
    vDU Rest Login    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${cells_identity_list}=   create list
    ${cells_info}=  vdu.get_vdu_cells_status
    FOR    ${cell_info}    IN    @{cells_info}
        append to list    ${cells_identity_list}    ${cell_info["nr_cell_identity"]}
    END
    ${cell_identity_list} =    Create list    ${cells_identity_list[${ru_index}]}
    [Return]   ${cell_identity_list}
    [Teardown]  vDU Logout

check actual UE num and which ue is not available
    [Arguments]    ${username}=${control_pc_username}    ${password}=${control_pc_password}    ${partial}=false
    @{ue_info_available}=    Wait Until Keyword Succeeds    3x    2m    get_available_ue_sn
    ...    control_pc_ip=${tl.ues[0].ssh_connection_details.addr}    username=${username}    password=${password}
    ${s23_count}=    get match count    ${ue_info_available[0]}    R*CW*
    Run Keyword If    '${partial}'=='true'    Set suite variable   ${actual_ue_num}    ${s23_count}
    ...    ELSE    Set suite variable   ${actual_ue_num}    ${ue_info_available[1]}
    [Return]    ${actual_ue_num}

check actual UE num
    [Arguments]    ${ue_index}=${0}    ${partial}=false
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send_command    command=taskkill /F /IM adb.exe    connection=cpc_${ue_index}
    ${count} =    csn.execute
    ...    command=adb devices |awk '{print $2}'
    ...    connection=cpc_${ue_index}
    ...    timeout=60
    ${all_ue_count} =    get count    ${count}    device
    ${count} =    csn.execute
    ...    command=adb devices |grep device
    ...    connection=cpc_${ue_index}
    ...    timeout=60
    ${s23_count1} =    get count    ${count}    R3CW
    ${s23_count2} =    get count    ${count}    RFCW
    ${s23_count}=   Evaluate     ${s23_count1} + ${s23_count2}
    Run Keyword If    '${partial}'=='true'    Set suite variable   ${actual_ue_num}    ${s23_count}
    ...    ELSE    Set suite variable   ${actual_ue_num}    ${all_ue_count}
    [Return]    ${actual_ue_num}

get actual ue info
   [Arguments]    ${username}=${control_pc_username}    ${password}=${control_pc_password}
    Set Suite Variable    ${control_pc_ip}    ${tl.ues[0].ssh_connection_details.addr}
    @{ue_info}=    Wait Until Keyword Succeeds    3x    2m
    ...    get_available_ue_sn    control_pc_ip=${control_pc_ip}    username=${username}    password=${password}
    Set Suite Variable    ${actual_ue_num}    ${ue_info[1]}
    Set Suite Variable    ${actual_ue_info}    ${ue_info[1]}

Prepare all online UE with data start
    [Arguments]    ${ue_number}=partial    ${action_index}=${0}     ${ue_sn_txt}=partial_ue_sn_14UE.txt
    ${ue_num}    get length    ${tl.ues}
    set suite variable    ${ue_num}
    Check all online UE network status and recover    action_index=${action_index}    ue_number=${ue_number}
    ...                                              ue_sn_txt=${ue_sn_txt}
    make_traffic_multi_ue    file_path=${ue_info_path}    direction=dl
    make_traffic_multi_ue    file_path=${ue_info_path}    direction=ul
#     Run Keyword If    '${traffic_direction}' == 'DL'
#     ...    Prepare all online UE with DL data start    ue_number=${ue_number}
#     ...    ELSE IF    '${traffic_direction}' == 'UL'
#     ...    Prepare all online UE with UL data start    ue_number=${ue_number}
#     ...    ELSE IF    '${traffic_direction}' == 'DLUL'
#     ...    Prepare all online UE with UL and DL data start    ue_number=${ue_number}

Prepare all online UE with UL data start
    [Arguments]    ${action_index}=${0}    ${ue_number}=all
    ${ue_num}    get length    ${tl.ues}
    set suite variable    ${ue_num}
    Check all online UE network status and recover    action_index=${action_index}    ue_number=${ue_number}
    Start all online UE UL data transfer    ue_num=${ue_num}

Prepare all online UE with DL data start
    [Arguments]    ${action_index}=${0}    ${ue_number}=all
    ${ue_num}    get length    ${tl.ues}
    set suite variable    ${ue_num}
    Check all online UE network status and recover    action_index=${action_index}    ue_number=${ue_number}
    Start all online UE DL data transfer    ue_num=${ue_num}

Prepare all online UE with UL and DL data start
    [Arguments]    ${action_index}=${0}    ${ue_number}=partial
    ...            ${ue_sn_txt}=partial_ue_sn_14UE.txt
    ${ue_num}    get length    ${tl.ues}
    set suite variable    ${ue_num}
    Check all online UE network status and recover   action_index=${action_index}    ue_number=${ue_number}
    ...                                              ue_sn_txt=${ue_sn_txt}
    sleep    10s
    Start all online UE UL and DL data transfer    ue_num=${ue_num}

Check all online UE network status and recover
    [Arguments]     ${action_index}=${0}    ${ue_number}=partial
    ...            ${ue_sn_txt}=partial_ue_sn_14UE.txt
#    ${offline_ues}    set variable    ${0}
#    FOR  ${ue_index}    IN RANGE    ${ue_num}
#        Connect to control pc enhanced    ue_index=${ue_index}
#        csn.send command
#        ...    command=adb -s ${tl.ues[${ue_index}].serial_number} shell getprop gsm.network.type
#        ...    connection=cpc_${ue_index}
#        ...    timeout=15
#        sleep    1s
#        ${result} =    csn.read output    connection=cpc_${ue_index}
#        ${network_status}    run keyword and return status    should not contain    ${result}    Unknown
#        ${offline_ues}    set variable if    '${network_status}'=='False'    ${offline_ues+1}    ${offline_ues}
#        run keyword if    '${network_status}'=='False'    csn.send command
#        ...    command=adb -s ${tl.ues[${ue_index}].serial_number} reboot
#        ...    connection=cpc_${ue_index}
#        ...    timeout=15
#        sleep    1s
#    END
#    Log    total ${offline_ues}ues offline and ${offline_ues}ues do the reboot operation
#    run keyword if    ${offline_ues}>0    sleep    3min
#    multi_ues_network_operate    control_pc_ip=${control_pc_ip1}    username=${control_pc_username}
#    ...    password=${control_pc_password}    action=${ue_action}[${action_index}]
#    multi_ues_network_operate    control_pc_ip=${control_pc_ip2}    username=${control_pc_username}
#    ...    password=${control_pc_password}    action=${ue_action}[${action_index}]
    ${id}=    Convert To String    ${tl.gnbs[0].instance_id}
    ${instance_id}=    Get Substring    ${id}    0    3
    Set Suite Variable    ${testline_instance_id}    ${instance_id}
    multi_ues_operation_exe_with_threading    action=${ue_action}[${action_index}]    pc_ip=${control_pc_ip}    ue_number=${ue_number}
    ...                                       ue_sn_txt=${ue_sn_txt}
    sleep    10s

multi_ues_operation_exe_with_threading
    [Arguments]    ${action}    ${pc_ip}=${tl.ues[0].ssh_connection_details.addr}
    ...    ${ue_number}=partial    ${ue_sn_txt}=partial_ue_sn_14UE.txt
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}    alias=ute
    sleep    2s
    Wait Until Keyword Succeeds    2min    10s    csn.send command
    ...    command=chmod +x ${SCF_path}multi_ue_attach_threading.exe; chmod +x ${SCF_path}multi_ue_detach_threading.exe
    ...    connection=ute
    sleep    1s
    Wait Until Keyword Succeeds    2min    10s    csn.send command
    ...    command=chmod +x ${SCF_path}partial_ue_attach_threading.exe; chmod +x ${SCF_path}partial_ue_detach_threading.exe
    ...    connection=ute
    sleep    1s
    Run Keyword If    '${action}'=='attach'
    ...   operate_all_or_partial_ue_attach    ue_number=${ue_number}    pc_ip=${pc_ip}    ue_sn_txt=${ue_sn_txt}
    ...    ELSE IF    '${action}'=='detach'
    ...    operate_all_or_partial_ue_detach    ue_number=${ue_number}    pc_ip=${pc_ip}    ue_sn_txt=${ue_sn_txt}
    sleep    20s
    [Teardown]    csn.disconnect     connection=ute

multi_all_ues_network_operate
    [Arguments]    ${action_index}=${0}    ${ue_number}=all
#    multi_ues_network_operate    control_pc_ip=${control_pc_ip1}    username=${control_pc_username}
#    ...    password=${control_pc_password}    action=${ue_action}[${action_index}]
#    multi_ues_network_operate    control_pc_ip=${control_pc_ip2}    username=${control_pc_username}
#    ...    password=${control_pc_password}    action=${ue_action}[${action_index}]
    ${id}=    Convert To String    ${tl.gnbs[0].instance_id}
    ${instance_id}=    Get Substring    ${id}    0    3
    Set Suite Variable    ${testline_instance_id}    ${instance_id}
    multi_ues_operation_exe_with_threading    action=${ue_action}[${action_index}]    pc_ip=${control_pc_ip}    ue_number=${ue_number}

operate_all_or_partial_ue_attach
    [Arguments]    ${ue_number}=all    ${pc_ip}=${tl.ues[0].ssh_connection_details.addr}
    ...    ${pc_username}=${tl.ues[0].ssh_connection_details.username}
    ...    ${pc_password}=${tl.ues[0].ssh_connection_details.password}    ${ue_sn_txt}=partial_ue_sn.txt
    Run Keyword If    '${ue_number}' == 'all'
    ...    csn.send command
    ...    command=wine ${SCF_path}multi_ue_attach_threading.exe ${pc_ip} ${pc_username} ${pc_password}
    ...    connection=ute
    ...    ELSE IF    '${ue_number}' == 'partial'    Run Keywords
    ...    get sn of partial ues    ue_sn_txt=${ue_sn_txt}
    ...    AND    csn.send command
    ...    command=wine ${SCF_path}partial_ue_attach_threading.exe ${pc_ip} ${pc_username} ${pc_password} '${ue_sn}'
    ...    connection=ute

operate_all_or_partial_ue_detach
    [Arguments]    ${ue_number}=all    ${pc_ip}=${tl.ues[0].ssh_connection_details.addr}
    ...    ${pc_username}=${tl.ues[0].ssh_connection_details.username}
    ...    ${pc_password}=${tl.ues[0].ssh_connection_details.password}    ${ue_sn_txt}=partial_ue_sn.txt
    Run Keyword If    '${ue_number}' == 'all'
    ...    csn.send command
    ...    command=wine ${SCF_path}multi_ue_detach_threading.exe ${pc_ip} ${pc_username} ${pc_password}
    ...    connection=ute
    ...    ELSE IF    '${ue_number}' == 'partial'    Run Keywords
    ...    get sn of partial ues    ue_sn_txt=${ue_sn_txt}
    ...    AND    csn.send command
    ...    command=wine ${SCF_path}partial_ue_detach_threading.exe ${pc_ip} ${pc_username} ${pc_password} '${ue_sn}'
    ...    connection=ute

get sn of partial ues
    [Arguments]    ${ue_sn_txt}=partial_ue_sn.txt
    ${ue_sn}=    get_partial_ues_sn   file_path=${SCF_path}${ue_sn_txt}
    Set Suite Variable    ${ue_sn}

Start all online UE UL and DL data transfer
    [Arguments]    ${ue_num}    ${source_dl_port}=${tl.appserver.iperf_details.port}
    ...    ${source_ul_port}=${tl.appserver.iperf_details.port}
    Stop all online UE DL data transfer    ue_num=${3}
    Stop all online UE UL data transfer    ue_num=${3}
    sleep    3s
    FOR  ${ue_index}    IN RANGE    ${ue_num}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_dl_iperf.sh ${tl.ues[${ue_index}].serial_number} ${dl_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END
    sleep    3s
    FOR  ${ue_index}    IN RANGE    ${ue_num}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${ul_port} =    evaluate    ${source_ul_port} - (${ue_index} + ${1})
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_ul_iperf.sh ${tl.ues[${ue_index}].serial_number} ${ul_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END

Start all online UE UL data transfer
    [Arguments]    ${ue_num}    ${source_ul_port}=${tl.appserver.iperf_details.port}
    Stop all online UE UL data transfer    ue_num=${ue_num}
    sleep    3s
    FOR  ${ue_index}    IN RANGE    ${ue_num}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${ul_port} =    evaluate    ${source_ul_port} + ${ue_index}
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_ul_iperf.sh ${tl.ues[${ue_index}].serial_number} ${ul_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END

Start all online UE DL data transfer
    [Arguments]    ${ue_num}    ${source_dl_port}=${tl.appserver.iperf_details.port}
    Stop all online UE DL data transfer    ue_num=${ue_num}
    sleep    3s
    FOR  ${ue_index}    IN RANGE    ${ue_num}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_dl_iperf.sh ${tl.ues[${ue_index}].serial_number} ${dl_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END

Stop all online UE UL data transfer
    [Arguments]    ${ue_num}
    FOR  ${ue_index}    IN RANGE    ${ue_num}
        Connect to control pc enhanced    ue_index=${ue_index}
        csn.send command
#        ...    command=ps -ef | grep "adb" | grep -v grep | awk '{print $2}' | xargs kill -s 9
        ...    command=ps -ef |grep iperf3 |awk '{print $2}'|xargs kill -9
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    3s
        Csn.disconnect    connection=cpc_${ue_index}
    END

Stop all online UE DL data transfer
    [Arguments]    ${ue_num}
    FOR  ${ue_index}    IN RANGE    ${ue_num}
        Connect to control pc enhanced    ue_index=${ue_index}
        csn.send command
#        ...    command=ps -ef | grep "adb" | grep -v grep | awk '{print $2}' | xargs kill -s 9
        ...    command=ps -ef |grep iperf3 |awk '{print $2}'|xargs kill -9
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    3s
        Csn.disconnect    connection=cpc_${ue_index}
    END

Check actual UE num with pc reset
    [Arguments]    ${reset_times}=3    ${full_ue_num}=6    ${partial}=false
    FOR    ${index}    IN RANGE    ${reset_times}
        ${ue_num_tmp}=    check actual UE num and which ue is not available    partial=${partial}
        run keyword if    '${ue_num_tmp}' != '${full_ue_num}'    Run keywords    Reset UE Control PC    AND    sleep    20s
        run keyword if    '${ue_num_tmp}' != '${full_ue_num}'    wait until keyword succeeds    5min    30s    Connect to control pc enhanced
        ${ue_num}=    run keyword if    '${ue_num_tmp}' != '${full_ue_num}'    check actual UE num and which ue is not available
        ...    partial=${partial}
        ...    ELSE    set variable    ${ue_num_tmp}
        set test variable    ${ue_num}
        exit for loop if    '${ue_num}'>='${full_ue_num}'
    END
    [Return]    ${ue_num}

## PA
PA preparation
    [Arguments]    ${cell_type}=SA
    FOR  ${index}    ${pa_name}  IN ENUMERATE   @{all_cell_pa_name}
        Set SFE attenuation value    att_ipaddr=${pa_name}[pa_ip]    att_ports=${pa_name}[pa_ports]    values=${all_cell_pa_initial_values}[${index}]
    END
    Run Keyword If    '${cell_type}'=='NSA'    Set SFE attenuation value    att_ipaddr=${enb1_cell1_pa_info}[pa_ip]
    ...    att_ports=${enb1_cell1_pa_info}[pa_ports]    values=${enb1_cell1_pa_value}[min]


Set SFE attenuation value
    [Arguments]    ${att_ports}    ${values}    ${att_connection_port}=${att_connection_port}    ${att_ipaddr}=${att_ipaddr}
    ...    ${max_attenuation_value}=${127}
    [Documentation]    This keyword is to set the test environment PA values, HBTE and topyoung.
    ...    ${att_port}:List all the attenuator ports as int list
    ...    ${value}:List the value of attenuator ports  int list
    ...    ${att_connection_port}:if PA is HBTE, the port is any one port.
    ...                           if PA is topyoung, the port is a List all the attenuator ports as int list
    ${Num_att_port}=    get length    ${att_ports}
    FOR    ${Num}    IN RANGE    ${0}    ${Num_att_port}
        att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}     model=${model}
        ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
        att.set_attenuation     port=${att_ports[${Num}]}    value=${values[${Num}]}
#        sleep    1s
        ${value_port}    att.read_attenuation    port=${att_ports[${Num}]}
        ${value_port}=    Convert To Integer    ${value_port}
        should be equal    ${value_port}    ${values[${Num}]}
    END

PA recover
    FOR  ${index}    ${pa_name}  IN ENUMERATE   @{all_cell_pa_name}
        Set SFE attenuation value    att_ipaddr=${pa_name}[pa_ip]    att_ports=${pa_name}[pa_ports]    values=${all_cell_pa_max_values}[${index}]
    END

set PA port on one cell
    [Arguments]    ${pa_name}=${gnb1_cell1_pa_info}    ${value}=${gnb1_cell1_pa_value}[setup][0]
    Set SFE attenuation value    att_ipaddr=${pa_name}[pa_ip]    att_ports=${pa_name}[pa_ports]    values=${value}

set all PA ports and one cell set designated value
    [Arguments]    ${pa_name}=${gnb1_cell1_pa_info}    ${value}=${gnb1_cell1_pa_value}[setup][0]    ${cell_type}=SA
    Set SFE attenuation value    att_ipaddr=${pa_name}[pa_ip]    att_ports=${pa_name}[pa_ports]    values=${value}
    FOR  ${index}    ${pa_names}  IN ENUMERATE   @{all_cell_pa_name}
        Run Keyword If    ${pa_names}!=${pa_name}    Set SFE attenuation value
        ...    att_ipaddr=${pa_names}[pa_ip]    att_ports=${pa_names}[pa_ports]    values=${all_cell_pa_max_values}[${index}]
    END
    Run Keyword If    '${celltype}'=='NSA'    Set SFE attenuation value    att_ipaddr=${enb1_cell1_pa_info}[pa_ip]
        ...    att_ports=${enb1_cell1_pa_info}[pa_ports]    values=${enb1_cell1_pa_value}[min]

Adjust_HBTE_PA with loop
    [Arguments]    ${pa_name}    ${s_value}    ${e_value}    ${step}    ${ho_times}
    [Timeout]    10 hour
    ${length_s_value}=    get length    ${s_value}
    ${s_value}    Evaluate    float(${s_value}[0])
    ${e_value}    Evaluate    float(${e_value}[0])
    ${step}    Evaluate    float(${step})
    ${ho_times}    Evaluate    float(${ho_times}/2)
    ${step_value}    Evaluate    float((${e_value}-${s_value})/${step})
    ${sleep}    Evaluate    round((${interval}-${step}*${pa_settime})/${step},1)
    FOR  ${times}    IN RANGE    ${ho_times}
       loop for PA set value    pa_name=${pa_name}    s_value=${s_value}    step=${step}
       ...    step_value=${step_value}    sleep=${sleep}    port_num=${length_s_value}
    END

loop for PA set value
    [Arguments]    ${pa_name}    ${s_value}    ${step}     ${step_value}     ${sleep}    ${port_num}
    FOR  ${index}    IN RANGE    -${step}    ${step}    1
         ${index} =    evaluate    abs(${index})
         ${pa_value} =    evaluate    int(${s_value}+${step_value}*${index})
         ${pa_value}    Create List    ${pa_value}
         ${pa_value} =    evaluate    ${pa_value}*${port_num}
         ${pa_status}    run keyword and return status    set PA port on one cell     pa_name=${pa_name}    value=${pa_value}
         run keyword if  '${pa_status}'=='False'    PA error counter set
         sleep    ${sleep}s
    END

PA error counter set
    ${paerror_counter} =    Evaluate    ${paerror_counter}+1

Download new SFE counter from vcu
    [Arguments]      ${test_start}    ${test_end}
    ...    ${vcu_ip}=${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...    ${vcu_username}=${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...    ${vcu_password}=${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ...    ${namespace}=${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
    ...    ${local_path}=${epc_log_path}
    ...    ${connection}=vcu_ssh
    ...    ${folder_name}=vcu_counter
    ${vcu_counter_file_list}    get_pm_xml_file_from_cloud    ip=${vcu_ip}     username=${vcu_username}     password=${vcu_password}
    ...     connection=${connection}    local_path=${local_path}    namespace=${namespace}
    ...     test_start=${test_start}    test_end=${test_end}    folder_name=${folder_name}

    [Return]    ${vcu_counter_file_list}


Download new SFE counter from vdu
    [Arguments]          ${test_start}     ${test_end}
    ...    ${vdu_ip}=${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...    ${vdu_username}=${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...    ${vdu_password}=${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ...    ${namespace}=${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace}
    ...    ${local_path}=${epc_log_path}
    ...    ${connection}=vdu_ssh
    ...    ${folder_name}=vdu_counter
    ...    ${pm_xml_path}=/var/home/core/results/
    ${vdu_counter_file_list}    get_pm_xml_file_from_cloud    ip=${vdu_ip}    username=${vdu_username}    password=${vdu_password}
    ...     connection=${connection}    local_path=${local_path}    namespace=${namespace}    pm_xml_path=${pm_xml_path}
    ...     test_start=${test_start}    test_end=${test_end}    folder_name=${folder_name}
    [Return]    ${vdu_counter_file_list}

Caculate kpi and write into csv
    [Arguments]    ${pm_allvcu_list}    ${pm_allvdu_list}     ${csv_file}=${csv_file}
    ${vcu_counter_dic}    calculate_cloud_counter_from_pm_file
    ...                                          xml_folder_file_list=${pm_allvcu_list}    kpi_file=${CURDIR}/${vcu_counter_file}
    ${vdu_counter_dic}    calculate_cloud_counter_from_pm_file
    ...                                          xml_folder_file_list=${pm_allvdu_list}    kpi_file=${CURDIR}/${vdu_counter_file}
    ${counter_dic}    combine_vcu_vdu_dic    vcu_dic=${vcu_counter_dic}    vdu_dic=${vdu_counter_dic}
    ${kpi_result}    calculate_cloud_bts_kpis_by_counter    counter_dic_by_name=${counter_dic}    kpi_file=${CURDIR}/${kpi_list}
    write_value_into_csv    csv_file=${csv_file}    dict_kpi_key_value=${kpi_result}    case_kpi_path=${epc_log_path}/SFE_kpi.csv


Caculate kpi with kpi_file
    [Arguments]    ${pm_allvcu_list}    ${pm_allvdu_list}    ${kpi_list}
    ${vcu_counter_dic}    calculate_cloud_counter_from_pm_file
    ...                                          xml_folder_file_list=${pm_allvcu_list}    kpi_file=${CURDIR}/${vcu_counter_file}
    ${vdu_counter_dic}    calculate_cloud_counter_from_pm_file
    ...                                          xml_folder_file_list=${pm_allvdu_list}    kpi_file=${CURDIR}/${vdu_counter_file}
    ${counter_dic}    combine_vcu_vdu_dic    vcu_dic=${vcu_counter_dic}    vdu_dic=${vdu_counter_dic}
    ${kpi_result}    calculate_cloud_bts_kpis_by_counter    counter_dic_by_name=${counter_dic}    kpi_file=${CURDIR}/${kpi_list}
    [Return]    ${kpi_result}


Make mutil UE for VoNR Setup with special index
    slect specified index of ue for VONR
    FOR  ${index}  IN   @{ues_index_VONR}
      Make VoNR call(+6688)    ue_index=${index}
    END

Make mutil UE for EMC Setup with special index
    slect specified index of ue for EMC
    FOR  ${index}  IN   @{ues_index_EMC}
      Make EM call(+911)    ue_index=${index}
    END


slect specified index of ue for VONR
    @{ues_index_VONR}=    Create List    ${1}    ${3}
    Set Suite Variable    @{ues_index_VONR}
slect specified index of ue for EMC
    @{ues_index_EMC}=    Create List     ${9}    ${10}
    Set Suite Variable    @{ues_index_EMC}


Make EM call(+911)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    Wait Until Keyword Succeeds     3x    2m
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
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
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cpc_${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:${phone_number}
    ...    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 538 1959
    ...    connection=cpc_${ue_index}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect      connection=cpc_${ue_index}


Make VoNR call(+6688)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    Wait Until Keyword Succeeds     3x    2m
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
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
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cpc_${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cpc_${ue_index}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect      connection=cpc_${ue_index}

hang up mutil UE for VoNR Setup
    slect specified index of ue for VONR
    FOR  ${index}  IN   @{ues_index_VONR}
    hang up VoNR for SFE    ue_index=${index}
    check voice call disable    ue_index=${index}
    END

hang up mutil UE for EMC Setup
    slect specified index of ue for EMC
    FOR  ${index}  IN   @{ues_index_EMC}
    hang up EC call for SFE    ue_index=${index}
    check voice call disable    ue_index=${index}
    END

hang up VoNR for SFE
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
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cpc_${ue_index}
    sleep    5s
    csn.disconnect      connection=cpc_${ue_index}

hang up EC call for SFE
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
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 485 37    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 538 1959
    ...    connection=cpc_${ue_index}
    sleep    5s
    csn.disconnect      connection=cpc_${ue_index}

check voice call disable
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}    timeout=60
    sleep   3s
    ##### check voice call enable  #####
    ##### 0: the phone is in standby state. 1: the call is not answered. 2: the phone is busy  #####
    csn.send_command    command=adb -s ${serial_number} shell dumpsys telephony.registry |grep mCallState
    ...    connection=cpc_${ue_index}
    sleep   2s
    ${result} =    csn.read output    connection=cpc_${ue_index}
    sleep    1s
    csn.disconnect      connection=cpc_${ue_index}
    should contain    ${result}    mCallState=0

ADD Swconfig to vdu
    [Arguments]    ${vdu_host}=${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...            ${vdu_name}=${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...            ${vdu_pwd}=${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    modify_Dockerfile    vdu_host=${vdu_host}    vdu_name=${vdu_name}    vdu_pwd=${vdu_pwd}
    ...                  ute_file_name=/opt/workspace/SCF/swconfig.txt
    ...                  path_command_1=ADD swconfig.txt /opt/nokia/SS_RCPCCSMCU/swconfig.txt
    ...                  path_command_2=RUN chmod 755 /opt/nokia/SS_RCPCCSMCU/swconfig.txt
    ...                  dockerfile=Dockerfile-cprt
    delete_and_rebuild_vdu    vdu_host=${vdu_host}    vdu_name=${vdu_name}    vdu_pwd=${vdu_pwd}
    Wait Until Keyword Succeeds    20min    30s    Wait VDU onair
    check_swconfig_add_success    vdu_host=${vdu_host}    vdu_name=${vdu_name}    vdu_pwd=${vdu_pwd}

ADD 12810_flag to vdu
    [Arguments]    ${vdu_host}=${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...            ${vdu_name}=${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...            ${vdu_pwd}=${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ${swconfig_exist}    check_swconfig_add_success    vdu_host=${vdu_host}    vdu_name=${vdu_name}    vdu_pwd=${vdu_pwd}
    run keyword if    ${swconfig_exist} == False    ADD Swconfig to vdu
