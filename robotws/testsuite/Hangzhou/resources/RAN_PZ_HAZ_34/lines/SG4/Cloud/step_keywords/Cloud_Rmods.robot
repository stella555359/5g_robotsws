*** Settings ***
Library           taf.hw.fhgw.cli                       WITH NAME    issh
Library           taf/rfrl/cbts/utilities/time_convert.py
Resource          taf/rfrl/cbts/robot/ru/ru_operations.robot
Resource          taf/rfrl/cbts/robot/vdu/vdu_log.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Variables         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py

*** Keywords ***
Cloud Get Rmod Product Name
    [Arguments]    ${ru_index}=1    ${gnb_index}=0    ${vdu_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${rmods_status}    vdu.get_rmods_status    vdu_connection=${conn_alias}
    ${rmods}  create list
    FOR    ${rmod}    IN    @{rmods_status}
        return from keyword if    '${rmod['id']}'=='${ru_index}'    ${rmod['product_name']}
    END
    [Teardown]  vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Get Rmod Serial Number
    [Arguments]    ${ru_index}=1    ${gnb_index}=0    ${vdu_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${rmods_status}    vdu.get_rmods_status    vdu_connection=${conn_alias}
    ${rmods}  create list
    FOR    ${rmod}    IN    @{rmods_status}
        return from keyword if   '${rmod['id']}'=='${ru_index}'    ${rmod['serial_number']}
    END
    [Teardown]  vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Get Rmod Product Code
    [Arguments]    ${ru_index}=1    ${gnb_index}=0    ${vdu_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${rmods_status}    vdu.get_rmods_status    vdu_connection=${conn_alias}
    ${rmods}  create list
    FOR    ${rmod}    IN    @{rmods_status}
        return from keyword if   '${rmod['id']}'=='${ru_index}'    ${rmod['product_code']}
    END
    [Teardown]  vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud get BPF gz fileName
    [Arguments]    ${product_name}  ${product_code}
    ${prodName_str}=    convert to uppercase    ${product_name}
    ${prodName_tmp0}    string.get substring    ${product_name}    start=0    end=2
    ${prodName_tmp1}    string.get substring    ${product_name}    start=2
    ${uint}    set variable    ${prodName_tmp0}_${prodName_tmp1}
    @{tmp2}    string.split string    ${product_code}    separator=.
    ${version}    set variable    ${tmp2}[0]
    ${uint_gz}    set variable    ${uint}.gz
    [Return]    ${version}    ${uint_gz}

Cloud Get VDU Version
    [Arguments]    ${ru_index}=1    ${gnb_index}=0    ${vdu_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${version}    vdu_ope_base.get_vdu_sw_version_from_webem    conn_alias=${conn_alias}
    [Return]    ${version}
    [Teardown]  vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Check TargetBD exist and match
    [Arguments]  ${gnb_index}=0    ${vdu_index}=0    ${save_path}=${SAVE LOG DIRECTORY}
    ...    ${conn_prompt}=${EMPTY}
    ${version}    Cloud Get VDU Version
    ${alias}    generic_utils.get_unique_id_string
    ssh_conn.connect_to_vdu_cloud_hosting    using_tenant=${True}    prompt=${conn_prompt}
    ...  vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${alias}
    ${ns}    tl_config.get_vdu_namespace    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${pod_full_name}    ${container_full_name}    ssh_conn.get_full_pod_and_container_name    pod_abbr=oamfh
    ...    container_abbr=oamfh    namespace=${ns}    alias=${alias}
	${kubectl_cmd}    Set Variable    kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns}
	${targetdb_filename}    ssh_conn.execute_normal_cmd
	...    base_command=${kubectl_cmd} -- ls /ffs/run/RFSW/ | grep -E '.*TargetBD.*${version}.*' | tr -d '\\000-\\037\\177-\\377'
	...    alias=${alias}
	${matchs}   Get Regexp Matches   ${targetdb_filename}   (TargetBD_.*?${version}.*?xml)    1
	${targetdb_filename}    set variable    ${matchs[0]}
	${cp_cmd}    Set Variable    kubectl cp ${pod_full_name}:ffs/run/RFSW/${targetdb_filename} -c ${container_full_name} ./${targetdb_filename} -n ${ns}
	ssh_conn.execute_normal_cmd    base_command=${cp_cmd}    alias=${alias}
	ssh_conn.download_file   remote_path=/var/home/core/${targetdb_filename}    local_path=${save_path}/${targetdb_filename}    alias=${alias}
    [Return]  ${targetdb_filename}
    [Teardown]    run keyword and ignore error    ssh_conn.disconnect_all_vdu_cloud_hosting

Cloud Check RU registration info
    [Arguments]    ${targetdb_filename}  ${ru_index}=1  ${save_path}=${SAVE LOG DIRECTORY}
    ${product_name}    Cloud Get Rmod Product Name  ru_index=${ru_index}
    ${targetdb_content}    get file      path=${save_path}/${targetdb_filename}
    should contain    ${targetdb_content}   ${product_name}

Cloud Check BPF file exist and match
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${ru_index}=1  ${save_path}=${SAVE LOG DIRECTORY}
    ...    ${conn_prompt}=${EMPTY}
    ${product_name}    Cloud Get Rmod Product Name  ru_index=${ru_index}
    ${product_code}    Cloud Get Rmod Product Code  ru_index=${ru_index}
    ${version}    ${uint_gz}    Cloud get BPF gz fileName  product_name=${product_name}  product_code=${product_code}
    ${alias}    generic_utils.get_unique_id_string
    ssh_conn.connect_to_vdu_cloud_hosting    using_tenant=${True}    prompt=${conn_prompt}
    ...  vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${alias}
    ${ns}    tl_config.get_vdu_namespace    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${pod_full_name}    ${container_full_name}    ssh_conn.get_full_pod_and_container_name    pod_abbr=oamfh
    ...    container_abbr=oamfh    namespace=${ns}    alias=${alias}
	${kubectl_cmd}    Set Variable    kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns}
	${bpf_filename}    ssh_conn.execute_normal_cmd
	...    base_command=${kubectl_cmd} -- ls /tmp/bpf/ | grep ${version}_${uint_gz} | tr -d '\\000-\\037\\177-\\377'
	...    alias=${alias}
	${matchs}   Get Regexp Matches   ${bpf_filename}   (\\d{6}A.*?${version}.*?gz)    1
	${bpf_filename}    set variable    ${matchs[0]}
	${cp_cmd}    Set Variable    kubectl cp ${pod_full_name}:tmp/bpf/${bpf_filename} -c ${container_full_name} ./${bpf_filename} -n ${ns}
	ssh_conn.execute_normal_cmd    base_command=${cp_cmd}    alias=${alias}
	ssh_conn.download_file   remote_path=/var/home/core/${bpf_filename}    local_path=${save_path}/${bpf_filename}    alias=${alias}
	[Return]  ${bpf_filename}
    [Teardown]    run keyword and ignore error    ssh_conn.disconnect_all_vdu_cloud_hosting

Cloud get BPF file content
    [Arguments]    ${bpf_filename}  ${save_path}=${SAVE LOG DIRECTORY}
    OperatingSystem.File Should Exist    ${save_path}/${bpf_filename}
    process.run process    gunzip -k '${save_path}/${bpf_filename}'    timeout=30s    shell=True
    ${bpf_file}  ${ext}=    Split Extension    ${save_path}/${bpf_filename}
    ${bpf_content}    OperatingSystem.get file    ${bpf_file}
    [Return]    ${bpf_content}

Cloud verify BPF params
    [Arguments]   ${bpf_filename}   ${ru_index}=1    ${variable_from_CFAM}=${Variables_CFAM}  ${save_path}=${SAVE LOG DIRECTORY}
    ${bpf_content}    Cloud get BPF file content    bpf_filename=${bpf_filename}
    ${product_name}    Cloud Get Rmod Product Name  ru_index=${ru_index}
    ${Radio_Variables_CFAM}    get from dictionary  ${variable_from_CFAM}  ${product_name}
    ${key_list}  get dictionary keys   ${Radio_Variables_CFAM}
    FOR  ${item}  IN  @{key_list}
        ${item_content}    set variable      ${Radio_Variables_CFAM}[${item}]
        ${item_type}    Evaluate     type($item_content)
        run keyword if    "${item_type}"=="<class 'str'>" or "${item_type}"=="<type 'str'>"
        ...    should contain    ${bpf_content}    ${item_content}
        ...    ELSE IF     "${item_type}"=="<class 'list'>" or "${item_type}"=="<type 'list'>"
        ...    Cloud Check BPF content    ${bpf_content}    ${item_content}
        ...    ELSE    Fail    wrong type of bpf
    END

Cloud Check BPF content
    [Arguments]     ${bpf_content}    ${list_items}
    FOR    ${item}    IN    @{list_items}
        ${checked}    run keyword and return status    should contain    ${bpf_content}    ${item}
        return from keyword if    ${checked}
    END
    Fail

Cloud Rmod Status Should as Expect
    [Arguments]  ${ru_index}=${None}    ${vdu_index}=0
    ...    ${operational_state}=${None}    ${availability_status}=${None}    ${administrative_state}=${None}
    ...    ${blocking_state}=${None}    ${procedural_status}=${None}
    ${conn_alias}    generic_utils.get_unique_id_string
    ${rmods_status}    vdu.get_rmods_status    vdu_connection=${conn_alias}
    FOR  ${rmod}  IN  @{rmods_status}
        Run keyword if    '${ru_index}'!='${rmod}[id]' and ${ru_index}!=${None}    Continue For Loop
        Cloud Rmod Status Check    type=operational_state    status=${operational_state}    rmods_status_info=${rmod}
        Cloud Rmod Status Check    type=availability_status    status=${availability_status}    rmods_status_info=${rmod}
        Cloud Rmod Status Check    type=administrative_state    status=${administrative_state}    rmods_status_info=${rmod}
        Cloud Rmod Status Check    type=procedural_status    status=${procedural_status}    rmods_status_info=${rmod}
    END
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Rmod Status Check
    [Arguments]  ${type}    ${status}    ${rmods_status_info}
    Run Keyword If    '${status}'!='${None}'    run keywords
    ...    log to console    Rmod status ${type} should be ${status} real is ${Rmods_status_info}[${type}]   AND
    ...    Should Be Equal As Strings   ${Rmods_status_info}[${type}]     ${status}
    ...    msg=Rmod status of ${type} is ${Rmods_status_info}[${type}] not same as ${status}
    ...    ELSE    log    no need to check ${type}
