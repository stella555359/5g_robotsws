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


*** Variables ***
${ue_type}                  ${tl.ues[0].capabilities[1]}
${test_pc}    ${tl.test_pc.default_ssh_connection_details.addr}
${tl_scf_path}    /opt/workspace/SCF/
${scf_name_CU_0}    scf_MRBTS-239_239-CU.xml
${scf_name_vDU_0}    scf_MRBTS-239_TL239-5gvDU1.xml
${scf_name_vDU_1}    scf_MRBTS-239_TL239-5gvDU2.xml
${data_send_ul}    30M
${data_send_dl}    100M
###PA###
${att_ipaddr}               ${tl.attenuator[0].ip_addr}
${att_port_1}         ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2}         ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3}         ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4}         ${tl.attenuator[0].attenuator_ports[4]}
${att_port_5}         ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6}         ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7}         ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8}         ${tl.attenuator[0].attenuator_ports[8]}
${att_port_9}         ${tl.attenuator[0].attenuator_ports[9]}
${att_port_10}        ${tl.attenuator[0].attenuator_ports[10]}
${att_port_11}        ${tl.attenuator[0].attenuator_ports[11]}
${att_port_12}        ${tl.attenuator[0].attenuator_ports[12]}
${att_port_13}        ${tl.attenuator[0].attenuator_ports[13]}
${att_port_14}        ${tl.attenuator[0].attenuator_ports[14]}
${att_port_15}        ${tl.attenuator[0].attenuator_ports[15]}
${att_port_16}        ${tl.attenuator[0].attenuator_ports[16]}



*** Keywords ***
Common Suite Setup for Cloud
    [Arguments]    ${timeout}=1min
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}
    Create suite log path    timeout=${timeout}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${SUITE_LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}
    set_suite_documentation    doc=All test suite log will save in this VM IP:${test_pc} Path:${epc_log_path}
    ...    append=True

Create suite log path
    [Documentation]    Create log directory with test suite level and open a common variable ${SUITE_LOG_PATH}
    [Arguments]    ${timeout}=1min    ${gnb_index}=${0}    ${vdu_index}=${0}
    ${cu_sw_version} =    CU Get SW Version    gnb_index=${gnb_index}
    ${vdu_sw_version} =    vDU Get SW Version    gnb_index=${gnb_index}    vdu_index=${vdu_index}
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

## BTS ##
BTS preparation per cu
    [Arguments]    ${vdu_count}=${2}    ${cu_count}=${1}    ${gnb_index}=${gnb_index}
    All vDUs Full Commission SCF    vdu_count=${vdu_count}    gnb_index=${gnb_index}
    CU Full Commission    path_of_commission_file=${tl_scf_path}${scf_name_CU_${gnb_index}}    gnb_index=${gnb_index}
    sleep    30s
    wait until keyword succeeds    5min    30s    All vDUs Verify All Cells Status Should Be Onair    vdu_count=${vdu_count}    gnb_index=${gnb_index}
    wait until keyword succeeds    5min    30s    CU Verify All DUs Status Are Available    gnb_index=${gnb_index}

BTS preparation
    [Arguments]    ${vdu_count}=${2}    ${cu_count}=${1}    ${vdu_from_gnb2}=${EMPTY}    ${vdu_count_gnb2}=${1}
    All vDUs Full Commission SCF    vdu_count=${vdu_count}    gnb_index=${0}
    Run Keyword If    "${vdu_from_gnb2}"!="${EMPTY}"    All vDUs Full Commission SCF    vdu_count=${vdu_count_gnb2}    gnb_index=${1}
    All CUs Full Commission SCF    cu_count=${cu_count}
    wait until keyword succeeds    5min    30s    All vDUs Verify All Cells Status Should Be Onair    vdu_count=${vdu_count}    gnb_index=${0}
    Run Keyword If    "${vdu_from_gnb2}"!="${EMPTY}"
    ...    wait until keyword succeeds    5min    30s    All vDUs Verify All Cells Status Should Be Onair
    ...    vdu_count=${vdu_count_gnb2}    gnb_index=${1}
	wait until keyword succeeds    5min    30s    CU Verify All DUs Status Are Available
	Run Keyword If    "${vdu_from_gnb2}"!="${EMPTY}"
    ...    wait until keyword succeeds    5min    30s    CU Verify All DUs Status Are Available    gnb_index=${1}

All vDUs Full Commission SCF
    [Arguments]    ${vdu_count}=${2}    ${gnb_index}=${0}
    FOR    ${index_vdu}    IN RANGE    ${vdu_count}
        vDU Full Commission SCF    scf_file=${tl_scf_path}${scf_name_vDU_${index_vdu}}    vdu_index=${index_vdu}    gnb_index=${gnb_index}
    END

All CUs Full Commission SCF
    [Arguments]    ${cu_count}=${1}
    FOR    ${index_cu}    IN RANGE    ${cu_count}
        CU Full Commission    path_of_commission_file=${tl_scf_path}${scf_name_CU_${index}}    gnb_index=${index_cu}
    END

All vDUs Verify All Cells Status Should Be Onair
    [Arguments]    ${vdu_count}=${2}    ${gnb_index}=${0}
    FOR    ${index_vdu}    IN RANGE    ${vdu_count}
        vDU Verify All Cells Status Should Be Onair    vdu_index=${index_vdu}    gnb_index=${gnb_index}
    END

## log ##
Start Capture Wireshark Logs on cu
    [Arguments]    ${f1log}    ${gnb_index}=${0}
    ${alias} =   Connect To CU K8S Master With Admin    gnb_index=${gnb_index}
    ${ns}=  Get CU Namespace From Testline    gnb_index=${gnb_index}
    set test variable    ${ns}
    ${start_log} =    Catenate    kubectl -n ${ns} exec -it po-${ns}-cpif-0 -c ctr-${ns}-nwmgmt -- tcpdump sctp -i any -s0 -w /tmp/${f1log}
    ${out} =    issh.execute_bare  command=${start_log}    alias=${alias}

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
	${log}    vDU End K8s Log      handle=${handle}     pod_abbr=up     container=${container_prefix}l2rt
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

## PA
Adjust the GNB1CELL1 HBTE attenuation value
    [Arguments]    ${gnb1_cell1_value}=${0}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1}    ${att_port_2}
    ...    ${att_port_3}    ${att_port_4}
    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1}    att_ipaddr=${att_ipaddr}

Adjust the GNB1CELL2 HBTE attenuation value
    [Arguments]    ${gnb1_cell2_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell2}    Create List    ${att_port_5}    ${att_port_6}
    ...    ${att_port_7}    ${att_port_8}
    ###create value list####
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1}    att_ipaddr=${att_ipaddr}

Adjust the GNB1CELL3 HBTE attenuation value
    [Arguments]    ${gnb1_cell3_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell3}    Create List    ${att_port_13}    ${att_port_14}
    ...    ${att_port_15}    ${att_port_16}
    ###create value list####
    @{values_gnb1_cell3}    Create List    ${gnb1_cell3_value}    ${gnb1_cell3_value}    ${gnb1_cell3_value}    ${gnb1_cell3_value}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell3}    values=${values_gnb1_cell3}
    ...    att_connection_port=${att_port_1}    att_ipaddr=${att_ipaddr}

Adjust the GNB2CELL1 HBTE attenuation value
    [Arguments]    ${gnb2_cell1_value}=${127}
    ####create cell list#####
    @{att_ports_gnb2_cell1}    Create List    ${att_port_9}    ${att_port_10}
    ...    ${att_port_11}    ${att_port_12}
    ###create value list####
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1}    att_ipaddr=${att_ipaddr}
