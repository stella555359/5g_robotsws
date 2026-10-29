*** Settings ***
Documentation    This test suite contains keywords for common commissioning operations for hz test line.
...              It supports both classical and cloud gnb, and can be used in both hz ci and ute cloud test lines.
Library     String
Library     Collections
Library     OperatingSystem
Library     taf.sbts.oam.coam.admin
Library     taf.gnb.oam.coam.cu
Library     taf.transport.ssh
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME   swconf

*** Variables ***
@{sw_directory}    ${TEMPDIR}    ~/output/build      ${TEMPDIR}/agent_5g_classical/output/build    ~/.ute-ca/cache/bts/{}
${pattern}    ^AirScale-{build}\\.zip$|^{build}_release_BTSSM_downloadable(_A\\d+)*\\.zip$
${scf_relative_dir}      commissionings${/}HGZ
@{hw_modules_need_to_be_checked}    systemModules    basebandModules    radioModules
&{cu_mapping}    0.400=0.200    12.400=12.200    14.400=14.200
${hz_artifactory}      https://artifactory-hz1.int.net.nokia.com/artifactory
${sbts_package_repository}    ${hz_artifactory}/mn-cosi-sran-central-public-remote/build/{}/{}/{}_release_BTSSM_downloadable_A54.zip
${5g_package_repository}    ${hz_artifactory}/mnp5g-central-public-remote/System_Release/{}/AirScale-{}.zip
@{rd_flags}    0x10041=5
${delete_netboot_cmd}    uboot_env del netboot

*** Keywords ***
CI_commssion.common commissioning
    [Timeout]    120min
    [Documentation]  common commisioning for hz test line.
    ...   Keyword depends on variables from command line, keyword will return directly without them.
    ...   Keyword supports both classical and cloud gnb.
    ...   Keyword supports both hz ci and ute cloud test line.
    ...   For test line on ute cloud, keyword will install package again if fault 23 raises.
    ...   Keyword do normal commissioning for classical bts.
    ...   Keyword do cu and du commissioning for cloud bts.
    ...   Tester needs to put SCF to scf_base_path with particular name.
    [Arguments]   ${gnb_index}=${0}   ${du_index}=${0}    ${common_unit_index}=${0}
    ${var_status}    ${ci_var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
    ...    gnb_index=${gnb_index}   du_index=${du_index}    common_unit_index=${common_unit_index}
    run keyword if    '${var_status}'=='FAIL'    run keywords
    ...    Builtin.log    Not ute or ci command, will not do common commission.    level=WARN    AND
    ...    return from keyword
    run keyword if      ${ci_var_dict}[ute_env]
    ...    run keyword and ignore error     UTE Cloud Specific Steps    ${ci_var_dict}
    run keyword if      '${ci_var_dict}[gnb_type]'=='ClassicalBts'
    ...    CI_commssion.Do DU Commission    ${ci_var_dict}
    ...    ELSE IF    '${ci_var_dict}[gnb_type]'=='CloudBts'
    ...    Log    Don't do commissioning for vRAN here.
    ...    ELSE    Log    Don't do commissioning for unknown gnb type here.

CI_commssion.Do DU Commission
    [Arguments]         ${var_dict}     ${connection}=du_coam
    CI_commssion.Connect To Du With F1 Or LMP    connection=${connection}    du_host=${var_dict}[du_host]
    ...        username=${var_dict}[username]    password=${var_dict}[password]
    CI_commssion.Commisioning Custom DU Scf    connection=${connection}   testline=${var_dict}[testline]
    ...    stream=${var_dict}[stream]    gnb_type=${var_dict}[gnb_type]   ute_env=${var_dict}[ute_env]
    ...    gnb_index=${var_dict}[gnb_index]
    WAIT UNTIL KEYWORD SUCCEEDS    80x    15s    CI_commssion.All Hw Should Be Detected
    ...    testline=${var_dict}[testline]    build=${var_dict}[build]    stream=${var_dict}[stream]
    ...    ute_env=${var_dict}[ute_env]   connection=${connection}    var_dict=${var_dict}
    WAIT UNTIL KEYWORD SUCCEEDS    15min    15s    CI_commssion.gNB Is OnAir   build=${var_dict}[build]
    ...    stream=${var_dict}[stream]    ute_env=${var_dict}[ute_env]   connection=${connection}
    WAIT UNTIL KEYWORD SUCCEEDS    15min    15s    CI_commssion.Verify all cells should be Online   connection=${connection}
    [Teardown]  taf.sbts.oam.coam.admin.teardown   connection=${connection}

CI_commssion.Connect To Du With F1 Or LMP
    [Arguments]     ${du_host}    ${username}    ${password}    ${connection}=GNB_OAM    ${bts_port}=${443}
    wait until keyword succeeds    5x   5s
    ...   taf.sbts.oam.coam.admin.connect_to    bts_host=${du_host}    bts_port=${bts_port}
    ...   username=${username}    password=${password}   name=${connection}

CI_commssion.Commisioning Custom DU Scf
    [Arguments]    ${testline}    ${stream}    ${ute_env}=True    ${connection}=GNB_OAM
    ...    ${timeout}=${720}    ${skip_error}=${True}    ${gnb_type}=ClassicalBts    ${gnb_index}=0
    LOG TO CONSOLE   \nDU scf commissioning. UTE CLOUD: ${ute_env}
    ${scf_path}    CI_commssion.Get SCF File Path    testline=${testline}
    ...    stream=${stream}   gnb_type=${gnb_type}    cu_or_du=DU    gnb_index=${gnb_index}
    ${result}    taf.sbts.oam.coam.admin.perform_commissioning    scf_file=${scf_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${skip_error}    connection=${connection}
    Should be equal as strings
    ...    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}    Success

CI_commssion.All Hw Should Be Detected
    [Arguments]    ${testline}    ${build}    ${stream}    ${var_dict}={}    ${ute_env}=${False}    ${connection}=GNB_OAM
    Log        ${testline}
    ${ru_version_mismatch}    CI_commssion.Is fault Raised    faultId=23    connection=${connection}
    run keyword if     ${ru_version_mismatch} and ${ute_env}    Run Keywords
    ...    CI_commssion.Upgrade RU
    ...          build=${build}    stream=${stream}   connection=${connection}
    ...    AND  CI_commssion.Connect To Du With F1 Or LMP    connection=${connection}    du_host=${var_dict}[du_host]
    ...        username=${var_dict}[username]    password=${var_dict}[password]
    ${all_hw}    taf.sbts.oam.coam.admin.get_detected_hw_info    connection=${connection}
    FOR    ${module}    IN    @{hw_modules_need_to_be_checked}
           ${hw_infos}   Collections.Get From Dictionary    ${all_hw}    ${module}
           ${hw_info_list}    set variable if    "${module}"=="radioModules"    ${hw_infos}[rmod]    ${hw_infos}
           run keyword if    "${module}"!="basebandModules"    Should Not Be Empty	   ${hw_info_list}
           CI_commssion._procedural Status Should be configured    ${hw_info_list}
           ${index}    Collections.Get Index From List    ${hw_modules_need_to_be_checked}    ${module}
           Collections.remove from list    ${hw_modules_need_to_be_checked}    ${index}
           LOG TO CONSOLE    ${SPACE*2}${module} are configured.
    END

CI_commssion._Procedural Status Should be configured
    [Arguments]    ${hw_info_list}
    FOR    ${hw_info}   IN    @{hw_info_list}
           ${empty}     run keyword and return status    Should Be Empty    ${hw_info}
           Continue For Loop If    ${empty}
           ${status_dict}     Collections.Get From Dictionary    ${hw_info}    status
           Collections.Dictionary Should Contain Item    ${status_dict}    proceduralStatus    configured
    END

CI_commssion.Get SCF File Path
    [Arguments]    ${testline}    ${stream}    ${gnb_type}=ClassicalBts    ${cu_or_du}=DU    ${gnb_index}=0
    ...    ${cur_relative_dir}=testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations
    ${scf_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${scf_relative_dir}
    ${gnb_ext_index}    evaluate    ${gnb_index}+1
    ${gnb_ext}    set variable if    ${gnb_index}==0    ${EMPTY}    _gnb${gnb_ext_index}
    ${path}    run keyword if   '${gnb_type}'=='ClassicalBts'
    ...    Catenate    SEPARATOR=${/}    ${scf_base_path}    ${testline}    SCF_${stream}${gnb_ext}.xml
    ...    ELSE IF      '${gnb_type}'=='CloudBts'
    ...    Catenate    SEPARATOR=${/}    ${scf_base_path}    ${testline}    SCF_${stream}${gnb_ext}_${cu_or_du}.xml
    OperatingSystem.File Should Exist    ${path}
    log to console   ${SPACE*2}scf path: ${path}.
    [Return]    ${path}

CI_commssion.Get SW file Path
    [Arguments]   ${build}    ${stream}
    ${build_escape_dot}    Replace String    ${build}    .      \\.
    ${pattern}    Format String    ${pattern}    build=${build_escape_dot}
    FOR    ${dir}    IN    @{sw_directory}
           ${new_dir}    format string    ${dir}    ${build}
           ${package_file}    CI_commssion.Check SW in Path     ${new_dir}    ${pattern}
           return from keyword if    '${package_file}'!='None'     ${package_file}
    END
    Log To Console    Can't find package in VM, downloading...
    ${dir}    CI_commssion.Download Package    ${build}    ${stream}
    ${package_file}    CI_commssion.Check SW in Path     ${dir}    ${pattern}
    [Return]   ${package_file}

CI_commssion.Download Package
    [Arguments]    ${build}    ${stream}
    ${headers}    Set Variable    --header="X-JFrog-Art-Api: AKCp5ekHjrLLExc8Wa7MSZiKStNXNjfnyCmV5eAAk6m16dKiXWyLkrTkjd3UBCDXarokL5chh"
    ${url}    run keyword if    'SBTS' in '${stream}'    format string      ${sbts_package_repository}   ${stream}   ${build}   ${build}
    ...    ELSE    format string      ${5g_package_repository}    ${build}   ${build}
    Run     wget ${headers} ${url} -nv -P ${TEMPDIR}
    [Return]   ${TEMPDIR}

CI_commssion.Check SW in Path
    [Arguments]      ${path}    ${pattern}
    ${path}    Normalize Path    ${path}
    ${status}    ${files}    Run Keyword And Ignore Error    OperatingSystem.List Files In Directory    ${path}
    return from keyword if    '${status}'=='FAIL'    ${None}
    FOR    ${file}    IN    @{files}
           ${matches}    Get Regexp Matches    ${file}    ${pattern}
           ${is_package_file}    run keyword and return status   Should Not Be Empty    ${matches}
           ${package_file}    run keyword if      ${is_package_file}    Catenate    SEPARATOR=${/}    ${path}    ${file}
           return from keyword if    ${is_package_file}    ${package_file}
    END

CI_commssion._Set Variables For Test
    [Arguments]   ${gnb_index}=${0}    ${du_index}=${0}   ${common_unit_index}=${0}
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${testline}   run keyword if    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    set variable     ${testline_name}
    ${stream}    ${build}     run keyword if    ${ute_env}    CI_commssion._Get Stream From Variable    ${ENB_BUILD}
    ...    ELSE   CI_commssion._Get Stream From Variable    ${AF_PATH}
    ${du_host}    set variable if     ${ute_env}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${common_unit_index}].lmp_connection.addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ${var_dict}   create dictionary
    ...    ute_env    ${ute_env}
    ...    testline   ${testline}
    ...    stream     ${stream}
    ...    build      ${build}
    ...    du_host    ${du_host}
    ...    cu_host    ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    username   ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password   ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    gnb_type   ${tl.gnbs[${gnb_index}].__class__.__name__}
    ...    gnb_index  ${gnb_index}
    [Return]    ${var_dict}

CI_commssion._Get Stream From Variable
    [Arguments]    ${orignal_variable}
    ${Variable}    CI_commssion._Verify build    ${orignal_variable}
    ${sbts}    run keyword and return status    Should Contain    ${Variable}    SBTS
    ${stream}    ${build}    run keyword if    ${sbts}    CI_commssion._Get Stream And Build From SBTS    ${Variable}
    ...    ELSE    CI_commssion._Get Stream And Build From 5G    ${Variable}
    [Return]    ${stream}    ${build}

CI_commssion._Verify build
    [Arguments]    ${build}
    ${matches1}    Get Regexp Matches    ${build}    SBTS\\w+_ENB_\\d+_\\d+_\\d+
    ${matches2}    Get Regexp Matches    ${build}    \\d+\\.\\d+\\.\\d+
    ${build_list}    Combine Lists   ${matches1}    ${matches2}
    Should Not Be Empty    ${build_list}
    [Return]    ${build_list}[0]

CI_commssion._Get Stream And Build from SBTS
    [Arguments]    ${Variable}
    ${stream}    String.Fetch From Left    ${Variable}   marker=_
    [Return]    ${stream}      ${Variable}

CI_commssion._Get Stream And Build From 5G
    [Arguments]    ${Variable}
    ${build}    String.Fetch From Right     string=${Variable}    marker=_
    ${stream_list}   String.Split String From Right    string=${build}   separator=.    max_split=1
    [Return]    ${stream_list}[0]    ${build}

CI_commssion.Verify all cells should be Online
    [Arguments]    ${connection}=GNB_OAM
    ${cells_info}   taf.sbts.oam.coam.admin.get_cells_info    connection=${connection}
    FOR  ${cell_group}  IN   @{cells_info}
         Should contain    ${cell_group['status']['operationalState']}    Enabled    ignore_case=True
         ${status_keys}    Collections.get dictionary keys    ${cell_group['status']}
         ${availability_status}    run keyword and return status    should contain
         ...    ${status_keys}    availabilityStatus    ignore_case=True
         run keyword if    ${availability_status}    Should contain
         ...    ${cell_group['status']['availabilityStatus']}    Online
    END
    LOG TO CONSOLE    ${SPACE*2}All cells are Online.

CI_commssion.gNB Is OnAir
    [Arguments]     ${build}    ${stream}    ${ute_env}=${False}   ${connection}=GNB_OAM
    ${ru_version_mismatch}    CI_commssion.Is fault Raised    faultId=23    connection=${connection}
    run keyword if     ${ru_version_mismatch} and ${ute_env}    CI_commssion.Upgrade RU
    ...          build=${build}    stream=${stream}   connection=${connection}
    ${status}    taf.sbts.oam.coam.admin.get_bts_statuses    connection=${connection}
    Collections.Dictionary Should Contain Item    ${status}    proceduralState    OnAir
    ...   msg=proceduralState: ${status}[proceduralState]
    LOG TO CONSOLE    ${SPACE*2}gNB is OnAir.

CI_commssion.Is fault Raised
    [Arguments]    ${faultId}=23    ${connection}=GNB_OAM
    ${activate_alarms}    taf.sbts.oam.coam.admin.get_active_alarms    connection=${connection}
    FOR  ${alarm}  IN  @{activate_alarms}
         ${raised}    run keyword and return status
         ...    Collections.Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}
         return from keyword if   ${raised}    ${True}
    END
    [Return]   ${False}

CI_commssion.Upgrade RU
    [Arguments]   ${build}   ${stream}    ${timeout}=${1800}     ${connection}=GNB_OAM
    LOG TO CONSOLE    ${SPACE*2}Fault 23 appears, try to upgrade ${build} again.
    ${sw_path}    CI_commssion.Get SW file Path    build=${build}    stream=${stream}
    Sleep    5s
    taf.sbts.oam.coam.admin.update_software     sw_package=${sw_path}     should_activate=True    timeout=${timeout}   connection=${connection}
    Sleep    10s
    LOG TO CONSOLE   ${SPACE*2}upgrade is done, waiting hw status.

CI_commssion.Do CU Commission
    [Arguments]   ${var_dict}    ${cu_version}=cuoam_19b
    Log To Console    Deprecated as no more cloud commissioning in HZ.
    Log    ${var_dict}
    Log    ${cu_version}
#    LOG TO CONSOLE   \nCU scf commissioning.
#    wait until keyword succeeds    5x   5s
#    ...   taf.gnb.oam.coam.cu.connect_to    host=${var_dict}[cu_host]    port=${EMPTY}    secure=${True}
#    ...   username=${var_dict}[username]    password=${var_dict}[password]    cu_version=${cu_version}
#    ${scf_path}    CI_commssion.Get CU SCF File Path    testline=${var_dict}[testline]
#    ...    orig_stream=${var_dict}[stream]
#    ${upload_info}    taf.gnb.oam.coam.cu.upload_plan_file    path_to_plan_file=${scf_path}
#    wait until keyword succeeds    10x   5s
#    ...    CI_commssion.CU Plan Upload Success    plan_id=${upload_info["action_id"]}
#    ${validate_info}  taf.gnb.oam.coam.cu.plan_validation    ${upload_info["plan_id"]}
#    wait until keyword succeeds    10x   5s
#    ...    CI_commssion.CU Plan Validate Success    plan_id=${upload_info["plan_id"]}    action_id=${validate_info["action_id"]}
#    ${activation_info}    taf.gnb.oam.coam.cu.plan_activation      plan_id=${upload_info["plan_id"]}
#    wait until keyword succeeds    20x   20s
#    ...    CI_commssion.CU Plan Activate Success    plan_id=${upload_info["plan_id"]}    activate_id=${activation_info["id"]}
#    [Teardown]    taf.gnb.oam.coam.cu.disconnect

CI_commssion.CU Plan Validate Success
    [Arguments]    ${plan_id}    ${action_id}
    ${operation_response}=  taf.gnb.oam.coam.cu.get_operation_state_of_validating_plan     ${plan_id}    ${action_id}
    Collections.Dictionary Should Contain Item    ${operation_response}    status    success

CI_commssion.CU Plan Upload Success
    [Arguments]    ${plan_id}
    ${operation_response}=  taf.gnb.oam.coam.cu.get_operation_state_of_uploading_plan    ${plan_id}
    Collections.Dictionary Should Contain Item    ${operation_response}    status    success

CI_commssion.CU Plan Activate Success
    [Arguments]    ${plan_id}    ${activate_id}
    ${operation_response}=  taf.gnb.oam.coam.cu.get_operation_state_of_activating_plan    ${plan_id}    ${activate_id}
    Collections.Dictionary Should Contain Item    ${operation_response}    status    success

CI_commission._Get Cu Stream
    [Arguments]    ${orig_stream}=12.400
    ${status}   ${vms}    run keyword and ignore error    taf.gnb.oam.coam.cu.get_vms
    Return From Keyword If   '${status}'=='FAIL'    ${cu_mapping}[${orig_stream}]
    FOR    ${vm}   IN    @{vms}
           ${status}    ${software_version}    run keyword and ignore error
           ...          Collections.Get From Dictionary    ${vm}    software_version
           Exit For Loop If	    '${status}'=='PASS' and '${software_version}'
    END
    ${stream}    ${build}    CI_commssion._Get Stream From Variable    ${software_version}
    [Return]    ${stream}

CI_commssion.Get CU SCF File Path
    [arguments]  ${testline}    ${orig_stream}=12.400
    ${status}    ${cu_stream}    run keyword and ignore error    CI_commission._Get Cu Stream    orig_stream=${orig_stream}
    ${status}    ${scf_path}    run keyword and ignore error    CI_commssion.Get SCF File Path    testline=${testline}
    ...    stream=${cu_stream}   gnb_type=CloudBts    cu_or_du=CU
    ${scf_path}    run keyword if    '${status}'=='FAIL'     CI_commssion.Get SCF File Path    testline=${testline}
    ...    stream=${orig_stream}   gnb_type=CloudBts    cu_or_du=CU
    ...    ELSE    set variable    ${scf_path}
    [Return]   ${scf_path}

Add Syslog Flag To Swconfig If Not Exist For UTE Cloud
    [arguments]    ${alias}
    ${local_path}    set variable    ${TEMPDIR}/ci_swconfig.txt
    OperatingSystem.Remove File    ${local_path}
    ${status}  ${res}  run keyword and ignore error
    ...    swconf.download_swConfig_file_from_asik_to_test_pc
    ...    localFilePath=${local_path}    remoteFilePath=/ffs/run/swconfig.txt    asik_alias=${alias}
	${file_not_exist}  run keyword and return status  should contain    ${res}    FileNotFoundError
	${size}    run keyword if    "${status}"=="PASS"    OperatingSystem.get file size    ${local_path}
	run keyword if    ${file_not_exist} or ${size}==0     create file
    ...    ${local_path}    ${rd_flags[0]}    ELSE    OperatingSystem.Get File    ${local_path}
    run keyword if    '${status}'=='PASS' or ${file_not_exist}    run keywords
    ...               swconf.modify_swConfig_file    ${rd_flags}    ${local_path}    AND
    ...               swconf.upload_swConfig_file_to_asik_and_crasign    ${local_path}    asik_alias=${alias}

UTE Cloud Specific Steps
    [arguments]    ${var_dict}    ${alias}=ci
    taf.transport.ssh.connect_to    hostname=${var_dict}[du_host]    username=toor4nsn    password=oZPS0POrRieRtu    alias=${alias}
    Add Syslog Flag To Swconfig If Not Exist For UTE Cloud    alias=${alias}
    Delete netboot flag For UTE Cloud    connection=${alias}
    [Teardown]    taf.transport.ssh.disconnect     connection=${alias}

Delete netboot flag For UTE Cloud
    [arguments]    ${connection}
    ${fullrack_tl}  Run Keyword And Return Status    Should Contain    ${tl.tl_cloud_topology}    FULLRACK
    #run keyword if    ${fullrack_tl}    Delete Netboot Flag For Fullrack UTE Cloud
    run keyword if    ${fullrack_tl}    log to console   Don't delete Netboot Flag For Fullrack UTE Cloud
    ...    ELSE  taf.transport.ssh.execute    command=${delete_netboot_cmd}    connection=${connection}

Delete netboot flag for Fullrack UTE Cloud
    FOR    ${test_pc}    IN    @{tl.test_pcs}
           Delete netboot flag from test pc    ${test_pc}
    END

Delete netboot flag from test pc
    [arguments]    ${test_pc}
    ${ssh_details}    Set Variable    ${test_pc.default_ssh_connection_details}
    ${ip}    Set Variable    ${ssh_details.addr}
    taf.transport.ssh.connect_to
    ...    hostname=${ip}
    ...    username=${ssh_details.username}
    ...    password=${ssh_details.password}
    ...    alias=${ip}
    ${index}    Set Variable    0
    FOR    ${connection}  IN   @{test_pc.connections}
        taf.transport.ssh.connect_to    hostname=${connection.device.lmp_connection.addr}    username=toor4nsn    password=oZPS0POrRieRtu
        ...    alias=${index}    proxy=${ip}
        taf.transport.ssh.execute    command=${delete_netboot_cmd}    connection=${index}
        taf.transport.ssh.disconnect    connection=${index}
        ${index}    Evaluate    ${index} + 1
    END
    [Teardown]    taf.transport.ssh.disconnect    connection=${ip}
